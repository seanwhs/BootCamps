# Part 4: Performance, Memory & Production Architecture

The previous parts explained how JavaScript executes code, schedules asynchronous work, transforms data, and reacts to state changes.

Now we will turn those foundations into production-oriented engineering practices.

This part focuses on four questions:

1. **What happens to memory when objects are created and abandoned?**
2. **How can we avoid unnecessary work during frequent events?**
3. **How should an application respond to temporary dependency failures?**
4. **Where should unexpected errors be caught and reported?**

We will build:

- Memory-retention demonstrations.
- Cleanup-aware resource utilities.
- Debounce and throttle helpers.
- DOM-style update batching.
- Retry logic with exponential backoff and jitter.
- A circuit breaker.
- A global error boundary.
- A resilient service wrapper.
- A complete production workflow combining all layers.

---

# Part 4.1: Prepare the Workspace

## The Target

We will create directories and package commands for performance and resilience examples.

## The Concept

Separating performance, resilience, and application-boundary code makes the architecture easier to test and maintain.

## Implementation

Run:

```bash
mkdir -p src/part-4/performance
mkdir -p src/part-4/memory
mkdir -p src/part-4/resilience
mkdir -p src/part-4/app
```

Update `package.json`:

### `package.json`

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
    "cancellation": "node src/part-2/cancellation.js",
    "timeout": "node src/part-2/timeout.js",
    "workflow": "node src/part-2/async-workflow.js",
    "pure": "node src/part-3/functional/pure-functions.js",
    "compose": "node src/part-3/functional/compose.js",
    "curry": "node src/part-3/functional/curry.js",
    "immutable": "node src/part-3/functional/immutable.js",
    "proxy": "node src/part-3/reactive/validated-proxy.js",
    "reactive": "node src/part-3/reactive/reactive-state.js",
    "batched-state": "node src/part-3/reactive/batched-state.js",
    "selectors": "node src/part-3/reactive/selectors.js",
    "memory-cleanup": "node --expose-gc src/part-4/memory/cleanup.js",
    "debounce": "node src/part-4/performance/debounce.js",
    "throttle": "node src/part-4/performance/throttle.js",
    "batch-render": "node src/part-4/performance/batch-render.js",
    "retry": "node src/part-4/resilience/retry.js",
    "breaker": "node src/part-4/resilience/circuit-breaker.js",
    "error-boundary": "node src/part-4/app/error-boundary.js",
    "production": "node src/part-4/app/production-workflow.js"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## Verification

Run:

```bash
npm run
```

Confirm that the Part 4 scripts appear.

---

# Part 4.2: Garbage Collection and Reachability

## The Target

We will build a memory experiment that shows how references determine whether an object can be collected.

## The Concept

JavaScript uses automatic garbage collection. The runtime identifies objects that are no longer reachable from active roots and eventually reclaims their memory.

A simplified mark-and-sweep process looks like this:

1. Start at live roots.
2. Mark every object reachable from those roots.
3. Sweep away unmarked objects.

A reference graph might look like this:

```text
global registry
      │
      ▼
callback function
      │
      ▼
large payload
```

As long as the registry remains alive, the callback and payload remain reachable.

Removing the callback breaks the path:

```text
global registry ──X── callback ──X── large payload
```

The payload can then become eligible for collection.

Garbage collection is automatic, but object lifetime is still an application-design responsibility.

## Implementation

### `src/part-4/memory/cleanup.js`

```js
"use strict";

const registrations = new Set();

function createPayload(sizeInMegabytes) {
  if (!Number.isInteger(sizeInMegabytes) || sizeInMegabytes <= 0) {
    throw new RangeError("sizeInMegabytes must be a positive integer");
  }

  return Array.from(
    { length: sizeInMegabytes },
    (_, index) => `payload-${index}`.padEnd(1_000_000, "x")
  );
}

function createRegistration(name) {
  const payload = createPayload(10);

  function handleEvent() {
    return {
      name,
      payloadItems: payload.length
    };
  }

  registrations.add(handleEvent);

  let isClosed = false;

  return Object.freeze({
    handleEvent,

    close() {
      if (isClosed) {
        return;
      }

      isClosed = true;
      registrations.delete(handleEvent);
    }
  });
}

function printMemory(label) {
  const { heapUsed } = process.memoryUsage();
  const megabytes = heapUsed / 1024 / 1024;

  console.log(`${label}: ${megabytes.toFixed(2)} MB`);
}

if (typeof global.gc !== "function") {
  throw new Error(
    "Run this file with Node.js --expose-gc so the demonstration can request GC."
  );
}

global.gc();
printMemory("initial");

const registration = createRegistration("dashboard");

global.gc();
printMemory("after registration");

console.log("active registrations:", registrations.size);
console.log("event result:", registration.handleEvent());

registration.close();

global.gc();
printMemory("after close");
console.log("active registrations:", registrations.size);
```

## Verification

Run:

```bash
npm run memory-cleanup
```

Expected output will contain:

```text
active registrations: 1
event result: { name: 'dashboard', payloadItems: 10 }
active registrations: 0
```

Exact memory values vary by runtime and operating system.

The important verification is that `close()` removes the callback from the registry.

---

# Part 4.3: Cleanup-Aware Resource Ownership

## The Target

We will create a resource manager that owns timers and can shut them down.

## The Concept

A resource should have a clear owner.

If a module creates a timer, it should know:

- Why the timer exists.
- How long it should live.
- How it is stopped.
- What happens during application shutdown.

This is called **lifecycle management**.

The resource manager below uses `AbortController` as a shared shutdown signal. When the owner shuts down, all registered timers stop.

## Implementation

### `src/part-4/memory/resource-scope.js`

```js
"use strict";

export function createResourceScope() {
  const controller = new AbortController();
  const cleanupFunctions = new Set();
  let isClosed = false;

  function assertOpen() {
    if (isClosed) {
      throw new Error("resource scope is already closed");
    }
  }

  function addCleanup(cleanup) {
    assertOpen();

    if (typeof cleanup !== "function") {
      throw new TypeError("cleanup must be a function");
    }

    cleanupFunctions.add(cleanup);

    return () => {
      cleanupFunctions.delete(cleanup);
    };
  }

  function setIntervalWithCleanup(callback, milliseconds) {
    assertOpen();

    if (typeof callback !== "function") {
      throw new TypeError("callback must be a function");
    }

    if (!Number.isFinite(milliseconds) || milliseconds <= 0) {
      throw new RangeError(
        "milliseconds must be a positive finite number"
      );
    }

    const intervalId = setInterval(() => {
      if (!controller.signal.aborted) {
        callback();
      }
    }, milliseconds);

    addCleanup(() => {
      clearInterval(intervalId);
    });

    return intervalId;
  }

  function close() {
    if (isClosed) {
      return;
    }

    isClosed = true;
    controller.abort();

    const errors = [];

    for (const cleanup of cleanupFunctions) {
      try {
        cleanup();
      } catch (error) {
        errors.push(error);
      }
    }

    cleanupFunctions.clear();

    if (errors.length > 0) {
      throw new AggregateError(
        errors,
        "one or more resource cleanup operations failed"
      );
    }
  }

  return Object.freeze({
    signal: controller.signal,
    addCleanup,
    setIntervalWithCleanup,
    close
  });
}

const scope = createResourceScope();
let ticks = 0;

scope.setIntervalWithCleanup(() => {
  ticks += 1;
  console.log(`tick ${ticks}`);
}, 20);

setTimeout(() => {
  scope.close();
  console.log("scope closed");
}, 75);

setTimeout(() => {
  console.log("final ticks:", ticks);
}, 110);
```

## Verification

Run:

```bash
node src/part-4/memory/resource-scope.js
```

Expected behavior:

```text
tick 1
tick 2
tick 3
scope closed
final ticks: 3
```

The interval does not continue after the scope closes.

---

# Part 4.4: Debouncing

## The Target

We will create a debounce utility.

## The Concept

**Debouncing** delays a function until activity stops for a specified period.

Imagine a person typing in a search box:

```text
j
ja
jav
java
```

Without debouncing, the application may send four searches.

With a 300-millisecond debounce delay, it waits until the user pauses and sends only the final search.

Debouncing is useful for:

- Search fields.
- Window resizing.
- Autosave.
- Validation after typing.
- Expensive calculations.

## Implementation

### `src/part-4/performance/debounce.js`

```js
"use strict";

export function debounce(callback, waitMilliseconds) {
  if (typeof callback !== "function") {
    throw new TypeError("callback must be a function");
  }

  if (
    !Number.isFinite(waitMilliseconds) ||
    waitMilliseconds < 0
  ) {
    throw new RangeError(
      "waitMilliseconds must be a non-negative finite number"
    );
  }

  let timerId = null;
  let latestArguments = null;
  let latestThis = null;

  function invoke() {
    const argumentsToUse = latestArguments;
    const thisToUse = latestThis;

    latestArguments = null;
    latestThis = null;
    timerId = null;

    return callback.apply(thisToUse, argumentsToUse);
  }

  function debounced(...argumentsReceived) {
    latestArguments = argumentsReceived;
    latestThis = this;

    if (timerId !== null) {
      clearTimeout(timerId);
    }

    timerId = setTimeout(invoke, waitMilliseconds);
  }

  debounced.cancel = () => {
    if (timerId !== null) {
      clearTimeout(timerId);
    }

    timerId = null;
    latestArguments = null;
    latestThis = null;
  };

  debounced.flush = () => {
    if (timerId === null) {
      return undefined;
    }

    clearTimeout(timerId);
    return invoke();
  };

  return debounced;
}

const events = [];

const saveSearch = debounce((query) => {
  events.push(query);
  console.log("search executed:", query);
}, 30);

saveSearch("j");
saveSearch("ja");
saveSearch("jav");
saveSearch("java");

setTimeout(() => {
  console.log("executions:", events);
}, 70);
```

## Verification

Run:

```bash
npm run debounce
```

Expected output:

```text
search executed: java
executions: [ 'java' ]
```

Only the final call executes.

---

# Part 4.5: Throttling

## The Target

We will create a throttle utility.

## The Concept

**Throttling** limits how often a function can execute during a period.

Unlike debouncing:

- Debouncing waits for activity to stop.
- Throttling allows execution at a controlled maximum frequency.

Throttling is useful for:

- Scroll events.
- Pointer movement.
- Dragging.
- Progress updates.
- Monitoring high-frequency signals.

## Implementation

### `src/part-4/performance/throttle.js`

```js
"use strict";

export function throttle(callback, intervalMilliseconds) {
  if (typeof callback !== "function") {
    throw new TypeError("callback must be a function");
  }

  if (
    !Number.isFinite(intervalMilliseconds) ||
    intervalMilliseconds <= 0
  ) {
    throw new RangeError(
      "intervalMilliseconds must be a positive finite number"
    );
  }

  let lastExecutionTime = 0;
  let timerId = null;
  let pendingArguments = null;
  let pendingThis = null;

  function execute() {
    lastExecutionTime = Date.now();
    timerId = null;

    const argumentsToUse = pendingArguments;
    const thisToUse = pendingThis;

    pendingArguments = null;
    pendingThis = null;

    callback.apply(thisToUse, argumentsToUse);
  }

  function throttled(...argumentsReceived) {
    const now = Date.now();
    const elapsed = now - lastExecutionTime;
    const remaining = intervalMilliseconds - elapsed;

    pendingArguments = argumentsReceived;
    pendingThis = this;

    if (remaining <= 0) {
      if (timerId !== null) {
        clearTimeout(timerId);
        timerId = null;
      }

      execute();
      return;
    }

    if (timerId === null) {
      timerId = setTimeout(execute, remaining);
    }
  }

  throttled.cancel = () => {
    if (timerId !== null) {
      clearTimeout(timerId);
    }

    timerId = null;
    pendingArguments = null;
    pendingThis = null;
  };

  return throttled;
}

const executions = [];

const reportPointerPosition = throttle((position) => {
  executions.push(position);
  console.log("reported:", position);
}, 30);

reportPointerPosition(1);
reportPointerPosition(2);
reportPointerPosition(3);

setTimeout(() => {
  reportPointerPosition(4);
}, 10);

setTimeout(() => {
  reportPointerPosition(5);
}, 20);

setTimeout(() => {
  console.log("execution count:", executions.length);
  console.log("executions:", executions);
}, 80);
```

## Verification

Run:

```bash
npm run throttle
```

You should see fewer executions than calls.

The exact values depend on timer timing, but the callback should not execute once per input call.

---

# Part 4.6: Debounce Versus Throttle

| Requirement | Technique |
|---|---|
| Wait until activity stops | Debounce |
| Run at most once per interval | Throttle |
| Search after typing ends | Debounce |
| Track scroll position | Throttle |
| Autosave after user pauses | Debounce |
| Limit telemetry frequency | Throttle |

Choosing the wrong technique creates a poor user experience:

- Debouncing scrolling can make updates feel delayed.
- Throttling search can issue requests while the user is still typing.
- Neither technique replaces cancellation. A previous asynchronous request may still need to be aborted.

---

# Part 4.7: DOM-Style Update Batching

## The Target

We will batch multiple rendering requests into one update.

## The Concept

Rendering is expensive when every small state change causes a separate update.

Instead, we can schedule one render per event-loop turn:

```text
state change 1 ─┐
state change 2 ─┼── one scheduled render
state change 3 ─┘
```

In a browser, `requestAnimationFrame()` is often appropriate for visual updates. In this Node.js example, we use a microtask to demonstrate the batching principle.

## Implementation

### `src/part-4/performance/batch-render.js`

```js
"use strict";

export function createBatchedRenderer(render) {
  if (typeof render !== "function") {
    throw new TypeError("render must be a function");
  }

  let renderScheduled = false;
  let latestValue;

  function requestRender(value) {
    latestValue = value;

    if (renderScheduled) {
      return;
    }

    renderScheduled = true;

    queueMicrotask(() => {
      renderScheduled = false;

      const valueToRender = latestValue;
      latestValue = undefined;

      render(valueToRender);
    });
  }

  return requestRender;
}

const render = createBatchedRenderer((state) => {
  console.log("rendering state:", state);
});

render({ status: "loading" });
render({ status: "loading", requestCount: 1 });
render({ status: "healthy", requestCount: 1 });

console.log("state changes completed synchronously");
```

## Verification

Run:

```bash
npm run batch-render
```

Expected output:

```text
state changes completed synchronously
rendering state: { status: 'healthy', requestCount: 1 }
```

Only the latest state is rendered.

---

# Part 4.8: Exponential Backoff

## The Target

We will create a retry delay calculator.

## The Concept

A retry loop should not immediately repeat a failed request many times.

Immediate retries can overload an already unhealthy service. **Exponential backoff** increases the delay between attempts:

```text
attempt 1 → 100 ms
attempt 2 → 200 ms
attempt 3 → 400 ms
attempt 4 → 800 ms
```

A maximum delay prevents the wait from growing without limit.

**Jitter** adds controlled randomness so many clients do not retry simultaneously.

Without jitter:

```text
1000 clients fail at 12:00:00
1000 clients retry at 12:00:01
1000 clients retry again at 12:00:03
```

With jitter, those retries spread across a range.

## Implementation

### `src/part-4/resilience/backoff.js`

```js
"use strict";

export function calculateBackoffDelay({
  attempt,
  baseDelayMilliseconds = 100,
  maximumDelayMilliseconds = 10_000,
  random = Math.random
}) {
  if (!Number.isInteger(attempt) || attempt < 1) {
    throw new RangeError("attempt must be a positive integer");
  }

  if (
    !Number.isFinite(baseDelayMilliseconds) ||
    baseDelayMilliseconds < 0
  ) {
    throw new RangeError(
      "baseDelayMilliseconds must be non-negative and finite"
    );
  }

  if (
    !Number.isFinite(maximumDelayMilliseconds) ||
    maximumDelayMilliseconds < baseDelayMilliseconds
  ) {
    throw new RangeError(
      "maximumDelayMilliseconds must be finite and at least the base delay"
    );
  }

  if (typeof random !== "function") {
    throw new TypeError("random must be a function");
  }

  const exponentialDelay = Math.min(
    maximumDelayMilliseconds,
    baseDelayMilliseconds * 2 ** (attempt - 1)
  );

  /*
   * Full jitter chooses a random delay between zero and the calculated cap.
   */
  const jitteredDelay = Math.floor(random() * (exponentialDelay + 1));

  return jitteredDelay;
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { calculateBackoffDelay } from "./src/part-4/resilience/backoff.js";

for (let attempt = 1; attempt <= 5; attempt += 1) {
  console.log({
    attempt,
    delay: calculateBackoffDelay({
      attempt,
      random: () => 0.5
    })
  });
}
EOF
```

Expected values are approximately:

```text
{ attempt: 1, delay: 50 }
{ attempt: 2, delay: 100 }
{ attempt: 3, delay: 200 }
{ attempt: 4, delay: 400 }
{ attempt: 5, delay: 800 }
```

---

# Part 4.9: Retry with Cancellation

## The Target

We will build a retry helper that supports:

- Maximum attempts.
- Retryable errors.
- Exponential backoff.
- Jitter.
- Cancellation.
- Retry hooks.

## The Concept

Not every failure should be retried.

Examples of generally non-retryable failures:

- Invalid input.
- Authentication failure.
- Permission denied.
- A malformed request.
- A missing resource when retrying cannot change the result.

Examples of potentially retryable failures:

- Timeout.
- Connection reset.
- Temporary service outage.
- Rate limiting, when a server-provided delay is respected.

The retry helper should not make business decisions secretly. It receives an `isRetryable` function from the caller.

## Implementation

### `src/part-4/resilience/retry.js`

```js
"use strict";

import { calculateBackoffDelay } from "./backoff.js";

function createAbortError() {
  const error = new Error("retry operation was cancelled");
  error.name = "AbortError";
  return error;
}

function wait(milliseconds, signal) {
  if (signal.aborted) {
    return Promise.reject(signal.reason ?? createAbortError());
  }

  return new Promise((resolve, reject) => {
    let settled = false;

    const cleanup = () => {
      clearTimeout(timerId);
      signal.removeEventListener("abort", handleAbort);
    };

    const finish = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      resolve();
    };

    const handleAbort = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      reject(signal.reason ?? createAbortError());
    };

    const timerId = setTimeout(finish, milliseconds);

    signal.addEventListener("abort", handleAbort, { once: true });
  });
}

export async function retry({
  operation,
  maximumAttempts = 3,
  isRetryable = () => true,
  baseDelayMilliseconds = 100,
  maximumDelayMilliseconds = 10_000,
  random = Math.random,
  signal = new AbortController().signal,
  onRetry = () => {}
}) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (!Number.isInteger(maximumAttempts) || maximumAttempts < 1) {
    throw new RangeError("maximumAttempts must be a positive integer");
  }

  if (typeof isRetryable !== "function") {
    throw new TypeError("isRetryable must be a function");
  }

  if (typeof onRetry !== "function") {
    throw new TypeError("onRetry must be a function");
  }

  if (!(signal instanceof AbortSignal)) {
    throw new TypeError("signal must be an AbortSignal");
  }

  let lastError;

  for (let attempt = 1; attempt <= maximumAttempts; attempt += 1) {
    if (signal.aborted) {
      throw signal.reason ?? createAbortError();
    }

    try {
      return await operation({
        attempt,
        signal
      });
    } catch (error) {
      lastError = error;

      if (error?.name === "AbortError") {
        throw error;
      }

      const hasAttemptsRemaining = attempt < maximumAttempts;

      if (!hasAttemptsRemaining || !isRetryable(error)) {
        throw error;
      }

      const delayMilliseconds = calculateBackoffDelay({
        attempt,
        baseDelayMilliseconds,
        maximumDelayMilliseconds,
        random
      });

      onRetry({
        attempt,
        nextAttempt: attempt + 1,
        delayMilliseconds,
        error
      });

      await wait(delayMilliseconds, signal);
    }
  }

  throw lastError;
}

let operationAttempts = 0;

const result = await retry({
  maximumAttempts: 4,
  random: () => 0,
  operation: async ({ attempt }) => {
    operationAttempts += 1;
    console.log("attempt:", attempt);

    if (operationAttempts < 3) {
      const error = new Error("temporary service failure");
      error.retryable = true;
      throw error;
    }

    return "successful result";
  },
  isRetryable: (error) => error.retryable === true,
  onRetry: ({ nextAttempt, delayMilliseconds }) => {
    console.log(
      `retrying with attempt ${nextAttempt} after ${delayMilliseconds} ms`
    );
  }
});

console.log(result);
```

## Verification

Run:

```bash
npm run retry
```

Expected output:

```text
attempt: 1
retrying with attempt 2 after 0 ms
attempt: 2
retrying with attempt 3 after 0 ms
attempt: 3
successful result
```

The zero-valued random function makes this verification fast and deterministic.

---

# Part 4.10: Circuit Breakers

## The Target

We will build a circuit breaker with three states:

- `CLOSED`.
- `OPEN`.
- `HALF_OPEN`.

## The Concept

A **circuit breaker** protects an unhealthy dependency.

It behaves like an electrical circuit:

### Closed

Requests flow normally.

```text
application ───────── dependency
```

### Open

Requests fail immediately without contacting the dependency.

```text
application ──X────── dependency
```

This gives the dependency time to recover and prevents the application from wasting resources on known failures.

### Half-open

After a cooldown period, the breaker permits a test request.

- If the test succeeds, the breaker closes.
- If the test fails, the breaker opens again.

## Implementation

### `src/part-4/resilience/circuit-breaker.js`

```js
"use strict";

export const CircuitState = Object.freeze({
  CLOSED: "CLOSED",
  OPEN: "OPEN",
  HALF_OPEN: "HALF_OPEN"
});

function createCircuitOpenError() {
  const error = new Error("circuit breaker is open");
  error.name = "CircuitOpenError";
  return error;
}

export function createCircuitBreaker({
  operation,
  failureThreshold = 3,
  resetTimeoutMilliseconds = 1_000,
  isFailure = () => true,
  now = () => Date.now(),
  onStateChange = () => {}
}) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (!Number.isInteger(failureThreshold) || failureThreshold < 1) {
    throw new RangeError(
      "failureThreshold must be a positive integer"
    );
  }

  if (
    !Number.isFinite(resetTimeoutMilliseconds) ||
    resetTimeoutMilliseconds < 0
  ) {
    throw new RangeError(
      "resetTimeoutMilliseconds must be non-negative and finite"
    );
  }

  if (typeof isFailure !== "function") {
    throw new TypeError("isFailure must be a function");
  }

  if (typeof now !== "function") {
    throw new TypeError("now must be a function");
  }

  if (typeof onStateChange !== "function") {
    throw new TypeError("onStateChange must be a function");
  }

  let state = CircuitState.CLOSED;
  let consecutiveFailures = 0;
  let openedAt = null;
  let halfOpenProbeInProgress = false;

  function changeState(nextState, reason) {
    const previousState = state;

    if (previousState === nextState) {
      return;
    }

    state = nextState;

    onStateChange({
      previousState,
      nextState,
      reason
    });
  }

  function canAttempt() {
    if (state === CircuitState.CLOSED) {
      return true;
    }

    if (state === CircuitState.OPEN) {
      const elapsed = now() - openedAt;

      if (elapsed >= resetTimeoutMilliseconds) {
        changeState(
          CircuitState.HALF_OPEN,
          "reset timeout elapsed"
        );

        return true;
      }

      return false;
    }

    return !halfOpenProbeInProgress;
  }

  async function execute(...argumentsReceived) {
    if (!canAttempt()) {
      throw createCircuitOpenError();
    }

    if (state === CircuitState.HALF_OPEN) {
      halfOpenProbeInProgress = true;
    }

    try {
      const result = await operation(...argumentsReceived);

      consecutiveFailures = 0;

      if (state === CircuitState.HALF_OPEN) {
        halfOpenProbeInProgress = false;
        changeState(
          CircuitState.CLOSED,
          "half-open probe succeeded"
        );
      }

      return result;
    } catch (error) {
      if (state === CircuitState.HALF_OPEN) {
        halfOpenProbeInProgress = false;
      }

      if (!isFailure(error)) {
        throw error;
      }

      consecutiveFailures += 1;

      if (
        state === CircuitState.HALF_OPEN ||
        consecutiveFailures >= failureThreshold
      ) {
        openedAt = now();
        changeState(state, "dependency failure");
        state = CircuitState.OPEN;

        onStateChange({
          previousState: CircuitState.HALF_OPEN,
          nextState: CircuitState.OPEN,
          reason: "half-open probe failed"
        });
      }

      throw error;
    }
  }

  return Object.freeze({
    execute,

    getState() {
      return state;
    },

    getFailureCount() {
      return consecutiveFailures;
    }
  });
}

let failuresRemaining = 3;

const breaker = createCircuitBreaker({
  failureThreshold: 2,
  resetTimeoutMilliseconds: 30,
  operation: async () => {
    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      throw new Error("dependency failed");
    }

    return "dependency succeeded";
  },
  onStateChange: (change) => {
    console.log("state change:", change);
  }
});

for (let attempt = 1; attempt <= 4; attempt += 1) {
  try {
    console.log("request", attempt, await breaker.execute());
  } catch (error) {
    console.log("request failed:", error.name, error.message);
  }
}

await new Promise((resolve) => setTimeout(resolve, 40));

try {
  console.log("probe:", await breaker.execute());
} catch (error) {
  console.log("probe failed:", error.message);
}

console.log("final state:", breaker.getState());
```

## Verification

Run:

```bash
npm run breaker
```

Expected behavior:

1. The first two dependency failures open the circuit.
2. Later calls fail immediately with `CircuitOpenError`.
3. After the reset timeout, a half-open probe is attempted.
4. The dependency eventually succeeds.
5. The circuit returns to `CLOSED`.

---

# Part 4.11: Correcting Circuit State Transition Logging

The previous implementation demonstrates the behavior, but the state transition code can be made clearer by centralizing every transition.

Replace the implementation with this production-clean version:

### `src/part-4/resilience/circuit-breaker.js`

```js
"use strict";

export const CircuitState = Object.freeze({
  CLOSED: "CLOSED",
  OPEN: "OPEN",
  HALF_OPEN: "HALF_OPEN"
});

function createCircuitOpenError() {
  const error = new Error("circuit breaker is open");
  error.name = "CircuitOpenError";
  return error;
}

export function createCircuitBreaker({
  operation,
  failureThreshold = 3,
  resetTimeoutMilliseconds = 1_000,
  isFailure = () => true,
  now = () => Date.now(),
  onStateChange = () => {}
}) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (!Number.isInteger(failureThreshold) || failureThreshold < 1) {
    throw new RangeError(
      "failureThreshold must be a positive integer"
    );
  }

  if (
    !Number.isFinite(resetTimeoutMilliseconds) ||
    resetTimeoutMilliseconds < 0
  ) {
    throw new RangeError(
      "resetTimeoutMilliseconds must be non-negative and finite"
    );
  }

  if (typeof isFailure !== "function") {
    throw new TypeError("isFailure must be a function");
  }

  let state = CircuitState.CLOSED;
  let consecutiveFailures = 0;
  let openedAt = null;
  let halfOpenProbeInProgress = false;

  function transitionTo(nextState, reason) {
    if (state === nextState) {
      return;
    }

    const previousState = state;
    state = nextState;

    onStateChange({
      previousState,
      nextState,
      reason
    });
  }

  function isResetTimeoutComplete() {
    return (
      openedAt !== null &&
      now() - openedAt >= resetTimeoutMilliseconds
    );
  }

  function allowRequest() {
    if (state === CircuitState.CLOSED) {
      return true;
    }

    if (state === CircuitState.OPEN) {
      if (!isResetTimeoutComplete()) {
        return false;
      }

      transitionTo(
        CircuitState.HALF_OPEN,
        "reset timeout elapsed"
      );
    }

    if (state === CircuitState.HALF_OPEN) {
      if (halfOpenProbeInProgress) {
        return false;
      }

      halfOpenProbeInProgress = true;
    }

    return true;
  }

  async function execute(...argumentsReceived) {
    if (!allowRequest()) {
      throw createCircuitOpenError();
    }

    try {
      const result = await operation(...argumentsReceived);

      consecutiveFailures = 0;
      openedAt = null;

      if (state === CircuitState.HALF_OPEN) {
        halfOpenProbeInProgress = false;
        transitionTo(
          CircuitState.CLOSED,
          "half-open probe succeeded"
        );
      }

      return result;
    } catch (error) {
      if (state === CircuitState.HALF_OPEN) {
        halfOpenProbeInProgress = false;
      }

      if (!isFailure(error)) {
        throw error;
      }

      consecutiveFailures += 1;

      if (
        state === CircuitState.HALF_OPEN ||
        consecutiveFailures >= failureThreshold
      ) {
        openedAt = now();
        halfOpenProbeInProgress = false;
        transitionTo(
          CircuitState.OPEN,
          "failure threshold reached"
        );
      }

      throw error;
    }
  }

  return Object.freeze({
    execute,

    getState() {
      return state;
    },

    getFailureCount() {
      return consecutiveFailures;
    }
  });
}

let failuresRemaining = 3;

const breaker = createCircuitBreaker({
  failureThreshold: 2,
  resetTimeoutMilliseconds: 30,
  operation: async () => {
    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      throw new Error("dependency failed");
    }

    return "dependency succeeded";
  },
  onStateChange: (change) => {
    console.log("state change:", change);
  }
});

for (let attempt = 1; attempt <= 4; attempt += 1) {
  try {
    console.log("request", attempt, await breaker.execute());
  } catch (error) {
    console.log("request failed:", error.name, error.message);
  }
}

await new Promise((resolve) => setTimeout(resolve, 40));

try {
  console.log("probe:", await breaker.execute());
} catch (error) {
  console.log("probe failed:", error.message);
}

console.log("final state:", breaker.getState());
```

## Verification

Run again:

```bash
npm run breaker
```

Expected state sequence:

```text
CLOSED → OPEN → HALF_OPEN → CLOSED
```

The breaker prevents repeated calls during the open state.

---

# Part 4.12: Global Error Boundaries

## The Target

We will create an application error boundary for synchronous and asynchronous failures.

## The Concept

An **error boundary** is a deliberate place where errors are:

- Caught.
- Classified.
- Logged.
- Reported.
- Converted into a safe fallback.
- Prevented from crashing unrelated parts of the application.

Error boundaries should not hide programming errors silently. They should preserve the original error and provide context.

We will distinguish:

- Expected operational failures.
- Cancellation.
- Unexpected failures.

## Implementation

### `src/part-4/app/error-boundary.js`

```js
"use strict";

function normalizeError(error) {
  if (error instanceof Error) {
    return error;
  }

  return new Error(String(error));
}

function createStructuredError(error, context = {}) {
  const normalizedError = normalizeError(error);

  return {
    name: normalizedError.name,
    message: normalizedError.message,
    stack: normalizedError.stack,
    context,
    timestamp: new Date().toISOString()
  };
}

export function createErrorBoundary({
  logger = console,
  reportError = async () => {}
} = {}) {
  if (typeof logger.error !== "function") {
    throw new TypeError("logger.error must be a function");
  }

  if (typeof reportError !== "function") {
    throw new TypeError("reportError must be a function");
  }

  async function run(operation, context = {}) {
    if (typeof operation !== "function") {
      throw new TypeError("operation must be a function");
    }

    try {
      return await operation();
    } catch (error) {
      const structuredError = createStructuredError(error, context);

      if (error?.name === "AbortError") {
        logger.error("operation cancelled", structuredError);
      } else {
        logger.error("operation failed", structuredError);
      }

      try {
        await reportError(structuredError);
      } catch (reportingError) {
        /*
         * Reporting failure must not replace the original application error.
         */
        logger.error(
          "error reporting failed",
          createStructuredError(reportingError, {
            originalError: structuredError
          })
        );
      }

      throw error;
    }
  }

  return Object.freeze({
    run
  });
}

const boundary = createErrorBoundary({
  reportError: async (structuredError) => {
    console.log("reported error:", {
      name: structuredError.name,
      context: structuredError.context
    });
  }
});

try {
  await boundary.run(
    async () => {
      throw new Error("database connection failed");
    },
    {
      operation: "load-dashboard",
      dependency: "database"
    }
  );
} catch (error) {
  console.log("caller received:", error.message);
}
```

## Verification

Run:

```bash
npm run error-boundary
```

Expected output includes:

```text
operation failed ...
reported error: { name: 'Error', context: ... }
caller received: database connection failed
```

The boundary logs and reports the failure, but it rethrows the original error so the caller can decide whether to show a fallback.

---

# Part 4.13: Process-Level Error Handlers

## The Target

We will create a process bootstrap module that catches unhandled Node.js errors.

## The Concept

Local error boundaries are preferred because they have context.

Process-level handlers are the final safety net for errors that escaped local boundaries.

They should:

- Log the error.
- Attempt graceful cleanup.
- Exit with a non-zero status when the process may be unsafe.

They should not be used to pretend the application is healthy after an unknown programming error.

## Implementation

### `src/part-4/app/process-bootstrap.js`

```js
"use strict";

export function installProcessErrorHandlers({
  logger = console,
  shutdown = async () => {}
} = {}) {
  if (typeof logger.error !== "function") {
    throw new TypeError("logger.error must be a function");
  }

  if (typeof shutdown !== "function") {
    throw new TypeError("shutdown must be a function");
  }

  let shutdownStarted = false;

  async function performShutdown(reason, error) {
    if (shutdownStarted) {
      return;
    }

    shutdownStarted = true;

    logger.error(reason, error);

    try {
      await shutdown();
    } catch (shutdownError) {
      logger.error("graceful shutdown failed", shutdownError);
    }
  }

  const unhandledRejectionHandler = (reason) => {
    void performShutdown("unhandled promise rejection", reason);
  };

  const uncaughtExceptionHandler = (error) => {
    void performShutdown("uncaught exception", error);
  };

  process.on("unhandledRejection", unhandledRejectionHandler);
  process.on("uncaughtException", uncaughtExceptionHandler);

  return () => {
    process.off("unhandledRejection", unhandledRejectionHandler);
    process.off("uncaughtException", uncaughtExceptionHandler);
  };
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { installProcessErrorHandlers } from "./src/part-4/app/process-bootstrap.js";

const uninstall = installProcessErrorHandlers({
  shutdown: async () => {
    console.log("shutdown completed");
  }
});

Promise.reject(new Error("simulated unhandled rejection"));

setTimeout(() => {
  uninstall();
  console.log("handlers removed");
}, 30);
EOF
```

Expected output includes:

```text
unhandled promise rejection
shutdown completed
handlers removed
```

In a real process, the shutdown policy should usually set an exit code and stop accepting new work.

---

# Part 4.14: Resilient Service Wrapper

## The Target

We will combine:

- Retry.
- Circuit breaking.
- Timeouts.
- Structured logging.

## The Concept

A resilience layer is like a set of gates around an unreliable bridge:

1. The timeout prevents one crossing from taking forever.
2. The retry policy allows temporary failures another chance.
3. The circuit breaker stops traffic when failures become persistent.
4. Logging records what happened.

The order of these layers matters.

A common arrangement is:

```text
caller
  │
  ▼
circuit breaker
  │
  ▼
retry policy
  │
  ▼
timeout-aware request
  │
  ▼
external dependency
```

The circuit breaker sees the final result of an operation attempt group. Depending on business requirements, it may count an entire exhausted retry sequence as one dependency failure or count every individual attempt.

## Implementation

### `src/part-4/resilience/resilient-service.js`

```js
"use strict";

import { retry } from "./retry.js";
import { createCircuitBreaker } from "./circuit-breaker.js";

export function createResilientService({
  name,
  operation,
  maximumAttempts = 3,
  failureThreshold = 3,
  resetTimeoutMilliseconds = 1_000,
  isRetryable = () => true,
  isCircuitFailure = () => true,
  logger = console,
  random = Math.random
}) {
  if (typeof name !== "string" || name.trim() === "") {
    throw new TypeError("name must be a non-empty string");
  }

  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (typeof logger.info !== "function") {
    throw new TypeError("logger.info must be a function");
  }

  const breaker = createCircuitBreaker({
    failureThreshold,
    resetTimeoutMilliseconds,
    isFailure: isCircuitFailure,
    onStateChange: (change) => {
      logger.info("circuit state changed", {
        service: name,
        ...change
      });
    },
    operation: async (input, signal) => {
      return retry({
        maximumAttempts,
        isRetryable,
        signal,
        random,
        operation: ({ attempt, signal: retrySignal }) => {
          logger.info("service attempt", {
            service: name,
            attempt
          });

          return operation(input, retrySignal);
        },
        onRetry: (retryInformation) => {
          logger.info("service retry scheduled", {
            service: name,
            ...retryInformation
          });
        }
      });
    }
  });

  return Object.freeze({
    execute(input, signal) {
      return breaker.execute(input, signal);
    },

    getState() {
      return breaker.getState();
    },

    getFailureCount() {
      return breaker.getFailureCount();
    }
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createResilientService } from "./src/part-4/resilience/resilient-service.js";

let attempts = 0;

const service = createResilientService({
  name: "metrics",
  operation: async () => {
    attempts += 1;

    if (attempts < 3) {
      const error = new Error("temporary outage");
      error.retryable = true;
      throw error;
    }

    return { requestsPerSecond: 125 };
  },
  isRetryable: (error) => error.retryable === true,
  isCircuitFailure: () => true,
  random: () => 0,
  logger: {
    info(message, details) {
      console.log(message, details);
    }
  }
});

const result = await service.execute(
  null,
  new AbortController().signal
);

console.log(result);
EOF
```

Expected output includes retry logs followed by:

```text
{ requestsPerSecond: 125 }
```

---

# Part 4.15: Complete Production Workflow

## The Target

We will build a full workflow that combines:

- Resource ownership.
- Cancellation.
- Timeout-aware operations.
- Retry.
- Circuit breaking.
- Partial results.
- Error boundaries.
- Structured state updates.

## The Concept

Production architecture is not one large function. It is a chain of focused components.

The application workflow should:

1. Receive a refresh request.
2. Cancel any obsolete refresh.
3. Start independent service operations.
4. Apply retries and timeouts.
5. Preserve partial results.
6. Update state through explicit transitions.
7. Report unexpected errors.
8. Clean up resources when shutting down.

## Implementation

### `src/part-4/app/production-workflow.js`

```js
"use strict";

import { retry } from "../resilience/retry.js";
import { createCircuitBreaker } from "../resilience/circuit-breaker.js";
import { createErrorBoundary } from "./error-boundary.js";

function createAbortError(message = "operation cancelled") {
  const error = new Error(message);
  error.name = "AbortError";
  return error;
}

function cancellableDelay(milliseconds, signal) {
  if (signal.aborted) {
    return Promise.reject(signal.reason ?? createAbortError());
  }

  return new Promise((resolve, reject) => {
    let settled = false;

    const cleanup = () => {
      clearTimeout(timerId);
      signal.removeEventListener("abort", handleAbort);
    };

    const finish = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      resolve();
    };

    const handleAbort = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      reject(signal.reason ?? createAbortError());
    };

    const timerId = setTimeout(finish, milliseconds);

    signal.addEventListener("abort", handleAbort, { once: true });
  });
}

function createFakeDependency({
  name,
  delayMilliseconds,
  result,
  failuresBeforeSuccess = 0
}) {
  let failuresRemaining = failuresBeforeSuccess;

  return async (signal) => {
    await cancellableDelay(delayMilliseconds, signal);

    if (failuresRemaining > 0) {
      failuresRemaining -= 1;

      const error = new Error(`${name} temporary failure`);
      error.retryable = true;
      throw error;
    }

    return result;
  };
}

function createService({
  name,
  operation,
  logger
}) {
  const breaker = createCircuitBreaker({
    operation: async (signal) => {
      return retry({
        maximumAttempts: 3,
        baseDelayMilliseconds: 0,
        maximumDelayMilliseconds: 0,
        random: () => 0,
        signal,
        isRetryable: (error) => error.retryable === true,
        operation: ({ signal: retrySignal, attempt }) => {
          logger.info("attempt", {
            service: name,
            attempt
          });

          return operation(retrySignal);
        },
        onRetry: ({ nextAttempt }) => {
          logger.info("retry", {
            service: name,
            nextAttempt
          });
        }
      });
    },
    failureThreshold: 2,
    resetTimeoutMilliseconds: 100,
    isFailure: (error) => error.retryable === true,
    onStateChange: (change) => {
      logger.info("circuit", {
        service: name,
        ...change
      });
    }
  });

  return Object.freeze({
    load(signal) {
      return breaker.execute(signal);
    }
  });
}

function createStore() {
  let state = {
    status: "idle",
    services: {},
    error: null
  };

  const subscribers = new Set();

  function update(updater) {
    const previousState = state;
    state = updater(state);

    for (const subscriber of subscribers) {
      subscriber(state, previousState);
    }
  }

  return Object.freeze({
    getState() {
      return state;
    },

    subscribe(subscriber) {
      subscribers.add(subscriber);

      return () => {
        subscribers.delete(subscriber);
      };
    },

    startRefresh() {
      update((current) => ({
        ...current,
        status: "loading",
        error: null
      }));
    },

    finishRefresh(services) {
      update((current) => ({
        ...current,
        status: "ready",
        services,
        error: null
      }));
    },

    failRefresh(error) {
      update((current) => ({
        ...current,
        status: "failed",
        error: error.message
      }));
    }
  });
}

async function loadWithTimeout(operation, milliseconds, parentSignal) {
  const controller = new AbortController();
  let timerId;

  const forwardAbort = () => {
    controller.abort(parentSignal.reason ?? createAbortError());
  };

  if (parentSignal.aborted) {
    forwardAbort();
  } else {
    parentSignal.addEventListener("abort", forwardAbort, { once: true });
  }

  timerId = setTimeout(() => {
    const timeoutError = new Error(
      `operation timed out after ${milliseconds} ms`
    );
    timeoutError.name = "TimeoutError";
    controller.abort(timeoutError);
  }, milliseconds);

  try {
    return await operation(controller.signal);
  } finally {
    clearTimeout(timerId);
    parentSignal.removeEventListener("abort", forwardAbort);
  }
}

function createApplication() {
  const logger = {
    info(message, details) {
      console.log(`[INFO] ${message}`, details ?? "");
    },

    error(message, details) {
      console.error(`[ERROR] ${message}`, details ?? "");
    }
  };

  const store = createStore();

  const services = {
    metrics: createService({
      name: "metrics",
      operation: createFakeDependency({
        name: "metrics",
        delayMilliseconds: 20,
        failuresBeforeSuccess: 1,
        result: {
          requestsPerSecond: 125
        }
      }),
      logger
    }),

    health: createService({
      name: "health",
      operation: createFakeDependency({
        name: "health",
        delayMilliseconds: 10,
        result: {
          status: "healthy"
        }
      }),
      logger
    }),

    activity: createService({
      name: "activity",
      operation: createFakeDependency({
        name: "activity",
        delayMilliseconds: 15,
        result: {
          activeUsers: 42
        }
      }),
      logger
    })
  };

  const boundary = createErrorBoundary({
    logger,
    reportError: async (error) => {
      logger.info("error report accepted", {
        errorName: error.name
      });
    }
  });

  let activeRefreshController = null;

  async function refresh() {
    if (activeRefreshController) {
      activeRefreshController.abort(
        createAbortError("refresh superseded")
      );
    }

    const controller = new AbortController();
    activeRefreshController = controller;

    store.startRefresh();

    try {
      const serviceEntries = Object.entries(services);

      const results = await boundary.run(
        () =>
          Promise.allSettled(
            serviceEntries.map(async ([name, service]) => {
              const value = await loadWithTimeout(
                (signal) => service.load(signal),
                100,
                controller.signal
              );

              return [name, value];
            })
          ),
        {
          operation: "dashboard-refresh"
        }
      );

      const nextServices = Object.fromEntries(
        results.map((result, index) => {
          const name = serviceEntries[index][0];

          if (result.status === "fulfilled") {
            return [
              name,
              {
                status: "healthy",
                data: result.value[1]
              }
            ];
          }

          if (result.reason?.name === "AbortError") {
            return [
              name,
              {
                status: "cancelled",
                error: result.reason.message
              }
            ];
          }

          return [
            name,
            {
              status: "unavailable",
              error: result.reason?.message ?? "unknown failure"
            }
          ];
        })
      );

      if (controller.signal.aborted) {
        return;
      }

      store.finishRefresh(nextServices);
    } catch (error) {
      if (error.name === "AbortError") {
        return;
      }

      store.failRefresh(error);
    } finally {
      if (activeRefreshController === controller) {
        activeRefreshController = null;
      }
    }
  }

  function shutdown() {
    if (activeRefreshController) {
      activeRefreshController.abort(
        createAbortError("application shutting down")
      );
      activeRefreshController = null;
    }
  }

  return Object.freeze({
    store,
    refresh,
    shutdown
  });
}

const application = createApplication();

application.store.subscribe((state) => {
  console.log("state:", state);
});

await application.refresh();

application.shutdown();
```

## Verification

Run:

```bash
npm run production
```

Expected behavior:

- The application enters the `loading` state.
- Metrics fails once and retries.
- Metrics eventually succeeds.
- Health and activity succeed.
- The store enters the `ready` state.
- The application shuts down without leaving active work.

---

# Part 4.16: Performance Measurement

## The Target

We will create a small measurement utility.

## The Concept

Optimization should be based on evidence.

A **benchmark** measures execution time under controlled conditions. It is not a perfect representation of user experience, but it can reveal obvious differences.

Use high-resolution timers for short operations.

## Implementation

### `src/part-4/performance/measure.js`

```js
"use strict";

export async function measure(label, operation) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  const start = process.hrtime.bigint();

  const result = await operation();

  const end = process.hrtime.bigint();
  const elapsedMilliseconds = Number(end - start) / 1_000_000;

  console.log({
    label,
    elapsedMilliseconds: Number(elapsedMilliseconds.toFixed(3))
  });

  return result;
}

function buildNumbers(count) {
  return Array.from({ length: count }, (_, index) => index + 1);
}

const values = buildNumbers(100_000);

await measure("map and reduce", () => {
  const doubled = values.map((value) => value * 2);
  return doubled.reduce((total, value) => total + value, 0);
});

await measure("single loop", () => {
  let total = 0;

  for (const value of values) {
    total += value * 2;
  }

  return total;
});
```

## Verification

Run:

```bash
node src/part-4/performance/measure.js
```

You will see timings for both approaches.

Do not automatically conclude that the faster result is the better production choice. Readability, memory usage, input size, and actual application bottlenecks also matter.

---

# Part 4.17: Common Memory-Leak Sources

## Forgotten Event Listeners

```js
function mount(element) {
  const handleClick = () => {
    console.log("clicked");
  };

  element.addEventListener("click", handleClick);

  return () => {
    element.removeEventListener("click", handleClick);
  };
}
```

## Forgotten Intervals

```js
function startPolling() {
  const intervalId = setInterval(poll, 5_000);

  return () => {
    clearInterval(intervalId);
  };
}
```

## Unbounded Collections

```js
const history = [];

function record(event) {
  history.push(event);
}
```

Use a size limit:

```js
function createBoundedHistory(maximumSize) {
  const history = [];

  return {
    add(event) {
      history.push(event);

      while (history.length > maximumSize) {
        history.shift();
      }
    },

    values() {
      return [...history];
    }
  };
}
```

## Long-Lived Closures

```js
const globalCallbacks = [];

function register(data) {
  const callback = () => data;
  globalCallbacks.push(callback);

  return () => {
    const index = globalCallbacks.indexOf(callback);

    if (index >= 0) {
      globalCallbacks.splice(index, 1);
    }
  };
}
```

## Caches Without Expiration

Caches need policies such as:

- Maximum number of entries.
- Time-to-live.
- Explicit invalidation.
- Least-recently-used eviction.
- Weak references where appropriate.

---

# Part 4.18: WeakMap and WeakRef

## The Target

We will demonstrate why `WeakMap` is useful for metadata associated with objects.

## The Concept

A normal `Map` keeps its keys strongly reachable:

```js
const metadata = new Map();
```

If an object is used as a key, the map can keep that object alive.

A `WeakMap` does not keep object keys alive solely through the map. This makes it useful for metadata connected to the lifetime of another object.

## Implementation

### `src/part-4/memory/weak-map.js`

```js
"use strict";

const metadata = new WeakMap();

function attachMetadata(object, value) {
  if (object === null || typeof object !== "object") {
    throw new TypeError("object must be an object");
  }

  metadata.set(object, value);
}

function getMetadata(object) {
  return metadata.get(object);
}

const service = {
  name: "metrics"
};

attachMetadata(service, {
  createdAt: new Date().toISOString(),
  internalId: "service-1"
});

console.log(getMetadata(service));

/*
 * Once there are no other references to the service object, the WeakMap entry
 * does not by itself prevent collection. Garbage collection timing cannot be
 * observed deterministically in ordinary application code.
 */
```

## Verification

Run:

```bash
node src/part-4/memory/weak-map.js
```

Expected output resembles:

```text
{
  createdAt: '...',
  internalId: 'service-1'
}
```

Do not use `WeakRef` merely to hide a lifecycle problem. Explicit cleanup is usually clearer.

---

# Part 4.19: Production Error Categories

A resilient application should distinguish error types.

### Validation Error

The caller supplied invalid data.

```js
error.name = "ValidationError";
```

Usually do not retry.

### Authentication or Authorization Error

The caller lacks valid credentials or permission.

Usually do not retry automatically.

### Timeout Error

The operation exceeded its deadline.

May be retryable, depending on the dependency and request safety.

### Cancellation Error

The caller intentionally stopped the operation.

Do not present it as an unexpected failure.

### Dependency Error

An external service failed.

May be retryable.

### Programming Error

The application violated its own assumptions.

Usually do not retry. Log enough context to fix the code.

A retry policy should be explicit:

```js
function isRetryable(error) {
  return (
    error.name === "TimeoutError" ||
    error.name === "TemporaryDependencyError"
  );
}
```

---

# Part 4.20: Idempotency and Safe Retries

## The Target

We will define a safe operation policy.

## The Concept

An operation is **idempotent** if repeating it produces the same intended final result.

Examples:

- Replacing a resource with a complete representation is often idempotent.
- Reading data is usually idempotent.
- Incrementing a counter is not idempotent unless protected by a request identifier.

Retrying a non-idempotent operation can create duplicates.

For example:

```text
create payment
request times out
client retries
two payments may be created
```

A production API should use an idempotency key:

```js
const requestHeaders = {
  "Idempotency-Key": "unique-operation-id"
};
```

The server can recognize repeated requests and return the original result instead of performing the operation again.

Retries are not safe merely because the code can technically repeat a function.

---

# Part 4.21: Graceful Shutdown

## The Target

We will create an application shutdown coordinator.

## The Concept

Graceful shutdown means:

1. Stop accepting new work.
2. Cancel or finish active work.
3. Close subscriptions.
4. Stop timers.
5. Flush important logs.
6. Close database and network connections.
7. Exit only after cleanup completes or a deadline is reached.

## Implementation

### `src/part-4/app/shutdown.js`

```js
"use strict";

export function createShutdownCoordinator({
  logger = console,
  timeoutMilliseconds = 5_000
} = {}) {
  if (typeof logger.info !== "function") {
    throw new TypeError("logger.info must be a function");
  }

  if (
    !Number.isFinite(timeoutMilliseconds) ||
    timeoutMilliseconds <= 0
  ) {
    throw new RangeError(
      "timeoutMilliseconds must be positive and finite"
    );
  }

  const cleanupFunctions = [];
  let shuttingDown = false;

  function addCleanup(cleanup) {
    if (typeof cleanup !== "function") {
      throw new TypeError("cleanup must be a function");
    }

    if (shuttingDown) {
      throw new Error("cannot add cleanup during shutdown");
    }

    cleanupFunctions.push(cleanup);
  }

  async function shutdown(reason = "unknown") {
    if (shuttingDown) {
      return;
    }

    shuttingDown = true;
    logger.info("shutdown started", { reason });

    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => {
        reject(
          new Error(
            `shutdown exceeded ${timeoutMilliseconds} milliseconds`
          )
        );
      }, timeoutMilliseconds);
    });

    const cleanupPromise = (async () => {
      const errors = [];

      for (const cleanup of [...cleanupFunctions].reverse()) {
        try {
          await cleanup();
        } catch (error) {
          errors.push(error);
        }
      }

      if (errors.length > 0) {
        throw new AggregateError(
          errors,
          "shutdown cleanup failed"
        );
      }
    })();

    try {
      await Promise.race([cleanupPromise, timeoutPromise]);
      logger.info("shutdown completed");
    } catch (error) {
      logger.error("shutdown incomplete", error);
      throw error;
    }
  }

  return Object.freeze({
    addCleanup,
    shutdown
  });
}

const coordinator = createShutdownCoordinator({
  timeoutMilliseconds: 100
});

coordinator.addCleanup(async () => {
  console.log("closing subscriptions");
});

coordinator.addCleanup(async () => {
  console.log("closing timers");
});

await coordinator.shutdown("verification");
```

## Verification

Run:

```bash
node src/part-4/app/shutdown.js
```

Expected output:

```text
closing timers
closing subscriptions
```

Cleanup runs in reverse registration order, similar to unwinding nested resource ownership.

---

# Part 4.22: Reference — Performance Principles

## Reduce Work

The fastest operation is the one that never runs.

Examples:

- Skip rendering when state did not change.
- Avoid duplicate requests.
- Use selectors to calculate only required data.
- Cancel obsolete operations.
- Cache carefully.

## Reduce Frequency

Use:

- Debouncing.
- Throttling.
- Batching.
- Sampling.

## Reduce Allocation

Avoid creating unnecessary temporary objects inside extremely hot loops, but measure before optimizing.

## Keep the Main Thread Responsive

Break large work into batches and yield periodically.

## Use Appropriate Workers

Move CPU-heavy independent work to workers instead of expecting promises to create parallel execution.

## Measure User-Visible Effects

Useful measurements include:

- Time to interactive.
- Request latency.
- Render duration.
- Memory growth.
- Error rate.
- Retry rate.
- Circuit-open duration.
- Queue depth.

---

# Part 4.23: Reference — Retry and Circuit-Breaker Rules

## Retry Only What May Recover

Do not retry validation or permission failures.

## Respect Server Guidance

If a service returns a `Retry-After` value, use it when appropriate.

## Add Jitter

Avoid synchronized retry storms.

## Cap Attempts

A retry loop without a maximum is an outage amplifier.

## Use Deadlines

Retries should fit within the caller’s overall deadline.

## Make Cancellation Propagate

The caller must be able to stop both the operation and its retry delays.

## Protect Dependencies

A circuit breaker prevents repeated calls to a known unhealthy service.

## Provide Fallbacks Carefully

A fallback should be honest:

```js
{
  status: "stale",
  data: cachedData,
  refreshedAt: previousTimestamp
}
```

Do not label stale data as current data.

---

# Part 4.24: Complete Verification Checklist

Run:

```bash
npm run memory-cleanup
node src/part-4/memory/resource-scope.js
npm run debounce
npm run throttle
npm run batch-render
node src/part-4/performance/measure.js
npm run retry
npm run breaker
npm run error-boundary
node src/part-4/app/process-bootstrap.js
node src/part-4/memory/weak-map.js
node src/part-4/app/shutdown.js
npm run production
```

Confirm that:

- Registered callbacks can be removed.
- Timers stop when their resource scope closes.
- Debounce executes only after activity stops.
- Throttle limits execution frequency.
- Multiple rendering requests become one update.
- Retry attempts use bounded backoff.
- Cancellation stops retry delays.
- Circuit breakers open after repeated failures.
- Half-open probes can restore a circuit.
- Error boundaries log and report failures.
- Process-level handlers provide a final safety net.
- Shutdown executes cleanup in reverse order.
- The complete workflow retries temporary failures and reaches a healthy state.

---

# Part 4.25: Final Architecture

The complete Runtime Monitor architecture now looks like this:

```text
┌──────────────────────────────────────────────────────────────┐
│                        Application UI                         │
│  debounced search, throttled signals, batched rendering       │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                       Reactive Store                          │
│  immutable transitions, subscriptions, selectors, cleanup     │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                    Application Workflows                      │
│  cancellation, partial results, explicit error boundaries     │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                  Resilient Service Layer                      │
│  circuit breaker → retry → timeout → cancellable operation   │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                    External Dependencies                      │
│             APIs, databases, queues, remote services           │
└──────────────────────────────────────────────────────────────┘

Cross-cutting controls:
- structured logging
- process-level error handling
- resource ownership
- graceful shutdown
- memory cleanup
- performance measurement
```

The runtime concepts from earlier parts support every layer:

```text
Execution contexts
        │
        ▼
Closures and lexical scope
        │
        ▼
Promise microtasks and task queues
        │
        ▼
Cancellation and concurrency
        │
        ▼
Pure transformations and immutable state
        │
        ▼
Reactive updates
        │
        ▼
Memory ownership and cleanup
        │
        ▼
Performance controls and resilience layers
```

---

# Part 4.26: Final Engineering Checklist

Before calling the application production-ready, ask:

## Runtime

- Can I explain why each asynchronous callback runs when it does?
- Could a microtask chain starve timers or input handling?
- Are CPU-heavy operations blocking the main thread?

## State

- Are state transitions predictable?
- Are selectors pure?
- Are subscriptions removable?
- Are updates batched when appropriate?

## Memory

- Who owns every timer?
- Who removes every listener?
- Can a closure retain an unnecessarily large object?
- Are caches bounded?
- Are long-lived registries cleaned up?

## Performance

- Is frequent work debounced or throttled appropriately?
- Are render updates batched?
- Are obsolete requests cancelled?
- Have performance claims been measured?

## Resilience

- Which failures are retryable?
- Is the retry count bounded?
- Is backoff jittered?
- Is the operation idempotent?
- Does the circuit breaker protect an unhealthy dependency?
- Is stale fallback data labeled honestly?

## Errors

- Where is the nearest meaningful error boundary?
- Are cancellation and failure distinguished?
- Are reporting failures prevented from hiding original failures?
- Does the process shut down safely after an uncaught programming error?

## Shutdown

- Does the application stop accepting new work?
- Are active operations cancelled or completed?
- Are timers and subscriptions released?
- Is shutdown bounded by a deadline?

---

## Part 4 Summary

Production JavaScript architecture combines language knowledge with lifecycle discipline.

The core patterns are:

### Memory ownership

```text
create resource
      │
      ▼
use resource
      │
      ▼
release resource
```

### Performance control

```text
many inputs
    │
    ├── debounce → one action after quiet period
    ├── throttle → limited actions over time
    └── batch    → one update for many changes
```

### Resilience

```text
request
  │
  ▼
timeout
  │
  ▼
retry temporary failures
  │
  ▼
open circuit during prolonged failure
  │
  ▼
recover through a half-open probe
```

### Error handling

```text
local operation boundary
        │
        ▼
application error boundary
        │
        ▼
process-level safety net
        │
        ▼
graceful shutdown
```

The most important lesson is that performance and reliability are not isolated utilities. They are properties of the entire system.

A debounce helper cannot fix an architecture that leaks subscriptions. A retry helper cannot make a non-idempotent operation safe. A circuit breaker cannot replace meaningful fallback behavior. A global error handler cannot repair an application that has no ownership model.

Strong JavaScript architecture comes from connecting:

- Runtime behavior.
- Explicit control flow.
- Predictable state transitions.
- Resource cleanup.
- Measured performance.
- Intentional failure handling.
