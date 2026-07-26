# Appendix E: Testing and Verification Guide

A reliable application is not complete when its code runs once. It is complete when its important behavior can be verified repeatedly.

Testing gives us confidence that:

- Functions return correct values.
- Invalid input is rejected.
- Asynchronous operations settle correctly.
- Cancellation stops obsolete work.
- Retries stop at the correct attempt.
- Circuit breakers transition safely.
- State updates notify subscribers.
- Cleanup actually releases resources.
- Refactoring does not silently change behavior.

This appendix uses Node.js’s built-in test runner, so no external testing framework is required.

---

# E.1: Testing Vocabulary

## Unit Test

A unit test verifies one small unit of behavior, usually a function or module.

```text
input → function → output
```

Example:

```js
test("adds two numbers", () => {
  assert.equal(add(2, 3), 5);
});
```

---

## Integration Test

An integration test verifies that multiple modules work together.

Example:

```text
request client
      │
      ▼
retry policy
      │
      ▼
state store
```

The test may use a fake dependency but exercises the real application modules.

---

## End-to-End Test

An end-to-end test verifies a complete user-visible workflow.

Example:

```text
start application
      │
      ▼
perform refresh
      │
      ▼
request services
      │
      ▼
render dashboard
      │
      ▼
verify visible result
```

---

## Regression Test

A regression test protects behavior that previously broke.

When a bug is fixed:

1. Reproduce it with a failing test.
2. Fix the implementation.
3. Confirm the test now passes.
4. Keep the test permanently.

---

## Test Double

A test double replaces a real dependency.

Common types:

- **Stub:** Returns controlled data.
- **Spy:** Records how it was called.
- **Fake:** Working simplified implementation.
- **Mock:** Configured object used to verify interactions.

---

## Fixture

A fixture is controlled test data.

```js
const healthyService = {
  name: "metrics",
  status: "healthy"
};
```

Fixtures should be small and representative.

---

## Assertion

An assertion checks an expected condition.

```js
assert.equal(actual, expected);
```

If an assertion fails, the test fails.

---

## Test Isolation

A test is isolated when its result does not depend on another test’s execution order or leftover state.

Avoid:

- Shared mutable arrays.
- Global timers.
- Reused controllers.
- Persistent files.
- Network calls.
- Environment variables that are not restored.

---

# E.2: Create the Test Directory

## The Target

We will create a test structure that mirrors the application structure.

## Implementation

Run:

```bash
mkdir -p test/part-1
mkdir -p test/part-2
mkdir -p test/part-3
mkdir -p test/part-4
mkdir -p test/fixtures
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
    "test": "node --test",
    "test:watch": "node --test --watch",
    "test:coverage": "node --experimental-test-coverage --test",
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
npm test
```

At this point, Node may report that no tests were found. That is acceptable until we add the first test file.

---

# E.3: Node.js Built-In Test Runner

## The Target

We will create our first test.

## The Concept

Node.js provides the `node:test` module for defining tests and `node:assert/strict` for assertions.

A basic test has:

```js
test("description", () => {
  // Arrange
  // Act
  // Assert
});
```

The three stages are:

1. **Arrange:** Prepare inputs and dependencies.
2. **Act:** Execute the behavior.
3. **Assert:** Verify the result.

## Implementation

### `test/part-1/basic.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

function add(first, second) {
  return first + second;
}

test("add returns the sum of two numbers", () => {
  const first = 2;
  const second = 3;

  const result = add(first, second);

  assert.equal(result, 5);
});

test("add does not mutate its inputs", () => {
  const first = 10;
  const second = 20;

  add(first, second);

  assert.equal(first, 10);
  assert.equal(second, 20);
});
```

## Verification

Run:

```bash
npm test
```

Expected output indicates that two tests passed.

You can run one file directly:

```bash
node --test test/part-1/basic.test.js
```

---

# E.4: Assertion Methods

## Equality

```js
assert.equal(actual, expected);
```

Use strict equality when possible:

```js
assert.strictEqual(actual, expected);
```

With `node:assert/strict`, `equal()` uses strict comparison behavior.

---

## Deep Equality

Use `deepEqual()` for arrays and objects.

```js
assert.deepEqual(
  { name: "metrics" },
  { name: "metrics" }
);
```

This compares structure and values, not object identity.

---

## Strict Identity

Use `strictEqual()` when reference identity matters.

```js
const state = {};

assert.strictEqual(state, state);
```

Two separate objects are not identical:

```js
assert.notStrictEqual({}, {});
```

---

## Truthiness

```js
assert.ok(value);
```

Use this when the expected result should be truthy.

---

## Expected Failure

```js
assert.throws(
  () => {
    throw new TypeError("invalid input");
  },
  {
    name: "TypeError",
    message: "invalid input"
  }
);
```

---

## Expected Async Rejection

```js
await assert.rejects(
  Promise.reject(new Error("failed")),
  {
    message: "failed"
  }
);
```

---

# E.5: Testing Pure Functions

## The Target

We will test a pure service-status selector.

## Implementation

### `src/part-3/functional/service-selectors.js`

```js
"use strict";

export function selectHealthyServices(services) {
  if (!Array.isArray(services)) {
    throw new TypeError("services must be an array");
  }

  return services.filter(
    (service) => service.status === "healthy"
  );
}

export function calculateAverageLatency(services) {
  if (!Array.isArray(services)) {
    throw new TypeError("services must be an array");
  }

  const measuredServices = services.filter(
    (service) =>
      Number.isFinite(service.latencyMilliseconds)
  );

  if (measuredServices.length === 0) {
    return null;
  }

  const total = measuredServices.reduce(
    (sum, service) =>
      sum + service.latencyMilliseconds,
    0
  );

  return total / measuredServices.length;
}
```

### `test/part-3/service-selectors.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  selectHealthyServices,
  calculateAverageLatency
} from "../../src/part-3/functional/service-selectors.js";

test("selectHealthyServices returns only healthy services", () => {
  const services = [
    { name: "metrics", status: "healthy" },
    { name: "health", status: "unavailable" },
    { name: "activity", status: "healthy" }
  ];

  const result = selectHealthyServices(services);

  assert.deepEqual(result, [
    { name: "metrics", status: "healthy" },
    { name: "activity", status: "healthy" }
  ]);
});

test("selectHealthyServices does not mutate the original array", () => {
  const services = [
    { name: "metrics", status: "healthy" }
  ];

  const original = [...services];

  selectHealthyServices(services);

  assert.deepEqual(services, original);
});

test("calculateAverageLatency returns the average", () => {
  const services = [
    { latencyMilliseconds: 20 },
    { latencyMilliseconds: 40 },
    { latencyMilliseconds: 60 }
  ];

  assert.equal(
    calculateAverageLatency(services),
    40
  );
});

test("calculateAverageLatency ignores unmeasured services", () => {
  const services = [
    { latencyMilliseconds: 20 },
    { status: "loading" },
    { latencyMilliseconds: 40 }
  ];

  assert.equal(
    calculateAverageLatency(services),
    30
  );
});

test("calculateAverageLatency returns null without measurements", () => {
  assert.equal(
    calculateAverageLatency([
      { status: "loading" }
    ]),
    null
  );
});

test("selectors reject invalid input", () => {
  assert.throws(
    () => selectHealthyServices(null),
    {
      name: "TypeError"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-3/service-selectors.test.js
```

Then run the full suite:

```bash
npm test
```

---

# E.6: Testing Immutability

## The Target

We will verify that an immutable state update:

- Changes the intended branch.
- Preserves unrelated branches.
- Does not mutate the original state.

## Implementation

### `src/part-3/functional/state-updates.js`

```js
"use strict";

export function updateServiceStatus(
  state,
  serviceName,
  status
) {
  if (
    state === null ||
    typeof state !== "object"
  ) {
    throw new TypeError("state must be an object");
  }

  if (
    typeof serviceName !== "string" ||
    serviceName.trim() === ""
  ) {
    throw new TypeError(
      "serviceName must be a non-empty string"
    );
  }

  const service = state.services?.[serviceName];

  if (!service) {
    throw new Error(
      `unknown service: ${serviceName}`
    );
  }

  return {
    ...state,

    services: {
      ...state.services,

      [serviceName]: {
        ...service,
        status
      }
    }
  };
}
```

### `test/part-3/state-updates.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  updateServiceStatus
} from "../../src/part-3/functional/state-updates.js";

function createState() {
  return {
    services: {
      metrics: {
        status: "loading",
        latencyMilliseconds: 42
      },
      health: {
        status: "healthy",
        latencyMilliseconds: 20
      }
    }
  };
}

test("updateServiceStatus changes the selected service", () => {
  const state = createState();

  const nextState = updateServiceStatus(
    state,
    "metrics",
    "healthy"
  );

  assert.equal(
    nextState.services.metrics.status,
    "healthy"
  );
});

test("updateServiceStatus does not mutate the original state", () => {
  const state = createState();

  updateServiceStatus(
    state,
    "metrics",
    "healthy"
  );

  assert.equal(
    state.services.metrics.status,
    "loading"
  );
});

test("updateServiceStatus creates new root and service references", () => {
  const state = createState();

  const nextState = updateServiceStatus(
    state,
    "metrics",
    "healthy"
  );

  assert.notStrictEqual(nextState, state);
  assert.notStrictEqual(
    nextState.services,
    state.services
  );
  assert.notStrictEqual(
    nextState.services.metrics,
    state.services.metrics
  );
});

test("updateServiceStatus preserves unrelated references", () => {
  const state = createState();

  const nextState = updateServiceStatus(
    state,
    "metrics",
    "healthy"
  );

  assert.strictEqual(
    nextState.services.health,
    state.services.health
  );
});

test("updateServiceStatus rejects an unknown service", () => {
  assert.throws(
    () =>
      updateServiceStatus(
        createState(),
        "unknown",
        "healthy"
      ),
    {
      message: "unknown service: unknown"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-3/state-updates.test.js
```

---

# E.7: Testing Promise-Based Code

## The Target

We will test a delay utility and promise ordering.

## Implementation

### `src/part-2/testable-delay.js`

```js
"use strict";

export function delay(milliseconds, value) {
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
```

### `test/part-2/promises.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  delay
} from "../../src/part-2/testable-delay.js";

test("delay resolves with its value", async () => {
  const result = await delay(1, "completed");

  assert.equal(result, "completed");
});

test("Promise.all preserves input order", async () => {
  const result = await Promise.all([
    delay(15, "slow"),
    delay(1, "fast")
  ]);

  assert.deepEqual(result, [
    "slow",
    "fast"
  ]);
});

test("Promise.all rejects when one operation rejects", async () => {
  await assert.rejects(
    Promise.all([
      Promise.resolve("success"),
      Promise.reject(
        new Error("expected failure")
      )
    ]),
    {
      message: "expected failure"
    }
  );
});

test("Promise.allSettled preserves every outcome", async () => {
  const result = await Promise.allSettled([
    Promise.resolve("success"),
    Promise.reject(
      new Error("expected failure")
    )
  ]);

  assert.equal(result[0].status, "fulfilled");
  assert.equal(result[0].value, "success");

  assert.equal(result[1].status, "rejected");
  assert.equal(
    result[1].reason.message,
    "expected failure"
  );
});

test("delay rejects invalid durations synchronously", () => {
  assert.throws(
    () => delay(-1, "invalid"),
    {
      name: "RangeError"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-2/promises.test.js
```

---

# E.8: Testing Cancellation

## The Target

We will test that cancellation:

- Rejects the operation.
- Uses `AbortError`.
- Clears the timer.
- Handles already-aborted signals.

## Implementation

### `src/part-2/testable-cancellation.js`

```js
"use strict";

function createAbortError(message) {
  const error = new Error(message);
  error.name = "AbortError";
  return error;
}

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
      "milliseconds must be non-negative and finite"
    );
  }

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
```

### `test/part-2/cancellation.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  cancellableDelay
} from "../../src/part-2/testable-cancellation.js";

test("cancellableDelay resolves when not cancelled", async () => {
  const controller = new AbortController();

  const result = await cancellableDelay(
    1,
    "completed",
    controller.signal
  );

  assert.equal(result, "completed");
});

test("cancellableDelay rejects with AbortError", async () => {
  const controller = new AbortController();

  const operation = cancellableDelay(
    1_000,
    "never completed",
    controller.signal
  );

  controller.abort();

  await assert.rejects(operation, {
    name: "AbortError"
  });
});

test("cancellableDelay rejects immediately for an aborted signal", async () => {
  const controller = new AbortController();

  controller.abort();

  await assert.rejects(
    cancellableDelay(
      1,
      "never completed",
      controller.signal
    ),
    {
      name: "AbortError"
    }
  );
});

test("cancellableDelay preserves a custom abort reason", async () => {
  const controller = new AbortController();

  const reason = new Error("superseded by newer request");
  reason.name = "AbortError";

  controller.abort(reason);

  await assert.rejects(
    cancellableDelay(
      1,
      "never completed",
      controller.signal
    ),
    {
      message: "superseded by newer request"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-2/cancellation.test.js
```

---

# E.9: Avoiding Slow Tests

## The Problem

This test works, but it wastes time:

```js
test("cancels a long operation", async () => {
  const controller = new AbortController();

  const promise = cancellableDelay(
    60_000,
    "value",
    controller.signal
  );

  controller.abort();

  await assert.rejects(promise);
});
```

The operation is cancelled, so this may finish quickly, but long timers can keep the process alive if cleanup is broken.

Prefer:

- Immediate cancellation.
- Small success delays.
- Injectable schedulers.
- Deterministic fake timers when a library provides them.
- Testing behavior rather than waiting for real time.

---

# E.10: Injecting a Clock

## The Target

We will make time-dependent code testable without waiting for real time.

## The Concept

Instead of calling `Date.now()` directly inside a module, pass a clock function as a dependency.

Production:

```js
now: () => Date.now()
```

Test:

```js
now: () => fakeTime
```

## Implementation

### `src/part-4/testable-clock.js`

```js
"use strict";

export function createExpirationChecker({
  now = () => Date.now()
} = {}) {
  if (typeof now !== "function") {
    throw new TypeError("now must be a function");
  }

  let expiresAt = null;

  return Object.freeze({
    start(durationMilliseconds) {
      if (
        !Number.isFinite(durationMilliseconds) ||
        durationMilliseconds < 0
      ) {
        throw new RangeError(
          "duration must be non-negative and finite"
        );
      }

      expiresAt = now() + durationMilliseconds;
    },

    isExpired() {
      if (expiresAt === null) {
        return false;
      }

      return now() >= expiresAt;
    }
  });
}
```

### `test/part-4/clock.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createExpirationChecker
} from "../../src/part-4/testable-clock.js";

test("expiration checker uses the injected clock", () => {
  let currentTime = 1_000;

  const checker = createExpirationChecker({
    now: () => currentTime
  });

  checker.start(500);

  assert.equal(checker.isExpired(), false);

  currentTime = 1_499;
  assert.equal(checker.isExpired(), false);

  currentTime = 1_500;
  assert.equal(checker.isExpired(), true);
});
```

## Verification

Run:

```bash
node --test test/part-4/clock.test.js
```

This approach is more deterministic than waiting 500 milliseconds.

---

# E.11: Testing Retry Behavior

## The Target

We will test that a retry operation:

- Retries retryable failures.
- Stops after success.
- Stops immediately for non-retryable errors.
- Does not exceed the attempt limit.

## Implementation

### `src/part-4/testable-retry.js`

```js
"use strict";

export async function retry({
  operation,
  maximumAttempts,
  isRetryable = () => true,
  wait = async () => {},
  onRetry = () => {}
}) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (
    !Number.isInteger(maximumAttempts) ||
    maximumAttempts < 1
  ) {
    throw new RangeError(
      "maximumAttempts must be a positive integer"
    );
  }

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

      const hasAttemptsRemaining =
        attempt < maximumAttempts;

      if (
        !hasAttemptsRemaining ||
        !isRetryable(error)
      ) {
        throw error;
      }

      const nextAttempt = attempt + 1;

      onRetry({
        attempt,
        nextAttempt
      });

      await wait();
    }
  }

  throw lastError;
}
```

### `test/part-4/retry.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  retry
} from "../../src/part-4/testable-retry.js";

test("retry succeeds after temporary failures", async () => {
  let attempts = 0;
  const retryEvents = [];

  const result = await retry({
    maximumAttempts: 3,

    operation: async () => {
      attempts += 1;

      if (attempts < 3) {
        const error = new Error("temporary");
        error.retryable = true;
        throw error;
      }

      return "success";
    },

    isRetryable: (error) =>
      error.retryable === true,

    wait: async () => {},

    onRetry: (event) => {
      retryEvents.push(event);
    }
  });

  assert.equal(result, "success");
  assert.equal(attempts, 3);
  assert.deepEqual(retryEvents, [
    {
      attempt: 1,
      nextAttempt: 2
    },
    {
      attempt: 2,
      nextAttempt: 3
    }
  ]);
});

test("retry stops on a non-retryable error", async () => {
  let attempts = 0;

  await assert.rejects(
    retry({
      maximumAttempts: 5,

      operation: async () => {
        attempts += 1;

        const error = new Error("invalid request");
        error.retryable = false;
        throw error;
      },

      isRetryable: (error) =>
        error.retryable === true,

      wait: async () => {}
    }),
    {
      message: "invalid request"
    }
  );

  assert.equal(attempts, 1);
});

test("retry stops after maximum attempts", async () => {
  let attempts = 0;

  await assert.rejects(
    retry({
      maximumAttempts: 3,

      operation: async () => {
        attempts += 1;

        const error = new Error("temporary");
        error.retryable = true;
        throw error;
      },

      isRetryable: () => true,

      wait: async () => {}
    }),
    {
      message: "temporary"
    }
  );

  assert.equal(attempts, 3);
});
```

## Verification

Run:

```bash
node --test test/part-4/retry.test.js
```

---

# E.12: Testing Circuit-Breaker Transitions

## The Target

We will test:

```text
CLOSED → OPEN → HALF_OPEN → CLOSED
```

## Implementation

### `src/part-4/testable-breaker.js`

```js
"use strict";

export const CircuitState = Object.freeze({
  CLOSED: "CLOSED",
  OPEN: "OPEN",
  HALF_OPEN: "HALF_OPEN"
});

export function createCircuitBreaker({
  operation,
  failureThreshold = 2,
  resetTimeoutMilliseconds = 100,
  now = () => Date.now(),
  onStateChange = () => {}
}) {
  let state = CircuitState.CLOSED;
  let failures = 0;
  let openedAt = null;

  function transition(nextState, reason) {
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

  async function execute() {
    if (state === CircuitState.OPEN) {
      if (
        now() - openedAt <
        resetTimeoutMilliseconds
      ) {
        const error = new Error(
          "circuit is open"
        );
        error.name = "CircuitOpenError";
        throw error;
      }

      transition(
        CircuitState.HALF_OPEN,
        "reset timeout elapsed"
      );
    }

    try {
      const result = await operation();

      failures = 0;

      if (state === CircuitState.HALF_OPEN) {
        openedAt = null;

        transition(
          CircuitState.CLOSED,
          "probe succeeded"
        );
      }

      return result;
    } catch (error) {
      failures += 1;

      if (
        state === CircuitState.HALF_OPEN ||
        failures >= failureThreshold
      ) {
        openedAt = now();

        transition(
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
    }
  });
}
```

### `test/part-4/circuit-breaker.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  CircuitState,
  createCircuitBreaker
} from "../../src/part-4/testable-breaker.js";

test("circuit opens after the failure threshold", async () => {
  let calls = 0;

  const breaker = createCircuitBreaker({
    failureThreshold: 2,

    operation: async () => {
      calls += 1;
      throw new Error("dependency failed");
    }
  });

  await assert.rejects(
    breaker.execute(),
    {
      message: "dependency failed"
    }
  );

  await assert.rejects(
    breaker.execute(),
    {
      message: "dependency failed"
    }
  );

  assert.equal(
    breaker.getState(),
    CircuitState.OPEN
  );

  await assert.rejects(
    breaker.execute(),
    {
      name: "CircuitOpenError"
    }
  );

  assert.equal(calls, 2);
});

test("circuit closes after a successful half-open probe", async () => {
  let currentTime = 0;
  let shouldFail = true;

  const breaker = createCircuitBreaker({
    failureThreshold: 1,
    resetTimeoutMilliseconds: 100,
    now: () => currentTime,

    operation: async () => {
      if (shouldFail) {
        throw new Error("temporary failure");
      }

      return "success";
    }
  });

  await assert.rejects(
    breaker.execute(),
    {
      message: "temporary failure"
    }
  );

  assert.equal(
    breaker.getState(),
    CircuitState.OPEN
  );

  currentTime = 100;
  shouldFail = false;

  const result = await breaker.execute();

  assert.equal(result, "success");
  assert.equal(
    breaker.getState(),
    CircuitState.CLOSED
  );
});
```

## Verification

Run:

```bash
node --test test/part-4/circuit-breaker.test.js
```

---

# E.13: Testing Reactive Subscriptions

## The Target

We will test:

- Subscriber notification.
- Unsubscription.
- No notification when a value is unchanged.
- Subscriber isolation.

## Implementation

### `src/part-3/reactive/testable-state.js`

```js
"use strict";

export function createReactiveState(initialState) {
  const target = { ...initialState };
  const subscribers = new Set();

  const state = new Proxy(target, {
    get(object, property, receiver) {
      if (property === "subscribe") {
        return (subscriber) => {
          if (typeof subscriber !== "function") {
            throw new TypeError(
              "subscriber must be a function"
            );
          }

          subscribers.add(subscriber);

          return () => {
            subscribers.delete(subscriber);
          };
        };
      }

      return Reflect.get(object, property, receiver);
    },

    set(object, property, value, receiver) {
      const previousValue = Reflect.get(
        object,
        property,
        receiver
      );

      if (Object.is(previousValue, value)) {
        return true;
      }

      const didSet = Reflect.set(
        object,
        property,
        value,
        receiver
      );

      if (didSet) {
        for (const subscriber of subscribers) {
          try {
            subscriber({
              property,
              previousValue,
              nextValue: value
            });
          } catch {
            /*
             * A subscriber must not prevent other subscribers from running.
             */
          }
        }
      }

      return didSet;
    }
  });

  return state;
}
```

### `test/part-3/reactive-state.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createReactiveState
} from "../../src/part-3/reactive/testable-state.js";

test("state notifies subscribers when a value changes", () => {
  const state = createReactiveState({
    status: "idle"
  });

  const changes = [];

  state.subscribe((change) => {
    changes.push(change);
  });

  state.status = "loading";

  assert.deepEqual(changes, [
    {
      property: "status",
      previousValue: "idle",
      nextValue: "loading"
    }
  ]);
});

test("state does not notify for an identical value", () => {
  const state = createReactiveState({
    status: "idle"
  });

  let notifications = 0;

  state.subscribe(() => {
    notifications += 1;
  });

  state.status = "idle";

  assert.equal(notifications, 0);
});

test("unsubscribe removes the subscriber", () => {
  const state = createReactiveState({
    status: "idle"
  });

  let notifications = 0;

  const unsubscribe = state.subscribe(() => {
    notifications += 1;
  });

  unsubscribe();

  state.status = "loading";

  assert.equal(notifications, 0);
});

test("one failing subscriber does not stop another", () => {
  const state = createReactiveState({
    status: "idle"
  });

  let successfulNotifications = 0;

  state.subscribe(() => {
    throw new Error("subscriber failure");
  });

  state.subscribe(() => {
    successfulNotifications += 1;
  });

  state.status = "loading";

  assert.equal(successfulNotifications, 1);
});
```

## Verification

Run:

```bash
node --test test/part-3/reactive-state.test.js
```

---

# E.14: Testing Debounced Functions

## The Problem

Debouncing depends on timers. Tests that wait for real time are slower and potentially flaky.

A useful approach is to inject a scheduler.

## Implementation

### `src/part-4/performance/testable-debounce.js`

```js
"use strict";

export function createDebouncer({
  callback,
  setTimer,
  clearTimer
}) {
  if (typeof callback !== "function") {
    throw new TypeError("callback must be a function");
  }

  if (typeof setTimer !== "function") {
    throw new TypeError("setTimer must be a function");
  }

  if (typeof clearTimer !== "function") {
    throw new TypeError("clearTimer must be a function");
  }

  let timerId = null;
  let latestArguments = [];

  function invoke() {
    timerId = null;

    const argumentsToUse = latestArguments;
    latestArguments = [];

    callback(...argumentsToUse);
  }

  function schedule(...argumentsReceived) {
    latestArguments = argumentsReceived;

    if (timerId !== null) {
      clearTimer(timerId);
    }

    timerId = setTimer(invoke);
  }

  schedule.cancel = () => {
    if (timerId !== null) {
      clearTimer(timerId);
    }

    timerId = null;
    latestArguments = [];
  };

  return schedule;
}
```

### `test/part-4/debounce.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createDebouncer
} from "../../src/part-4/performance/testable-debounce.js";

function createFakeScheduler() {
  let nextId = 1;
  const callbacks = new Map();

  return {
    setTimer(callback) {
      const id = nextId;
      nextId += 1;

      callbacks.set(id, callback);

      return id;
    },

    clearTimer(id) {
      callbacks.delete(id);
    },

    runAll() {
      const pendingCallbacks = [
        ...callbacks.values()
      ];

      callbacks.clear();

      for (const callback of pendingCallbacks) {
        callback();
      }
    },

    get size() {
      return callbacks.size;
    }
  };
}

test("debouncer invokes only the latest call", () => {
  const scheduler = createFakeScheduler();
  const received = [];

  const debounced = createDebouncer({
    callback: (value) => {
      received.push(value);
    },
    setTimer: scheduler.setTimer,
    clearTimer: scheduler.clearTimer
  });

  debounced("first");
  debounced("second");
  debounced("third");

  assert.deepEqual(received, []);
  assert.equal(scheduler.size, 1);

  scheduler.runAll();

  assert.deepEqual(received, ["third"]);
});

test("debouncer can be cancelled", () => {
  const scheduler = createFakeScheduler();
  const received = [];

  const debounced = createDebouncer({
    callback: (value) => {
      received.push(value);
    },
    setTimer: scheduler.setTimer,
    clearTimer: scheduler.clearTimer
  });

  debounced("value");
  debounced.cancel();
  scheduler.runAll();

  assert.deepEqual(received, []);
  assert.equal(scheduler.size, 0);
});
```

## Verification

Run:

```bash
node --test test/part-4/debounce.test.js
```

---

# E.15: Testing Error Boundaries

## The Target

We will verify that an error boundary:

- Rethrows the original error.
- Reports structured context.
- Does not replace the original error if reporting fails.

## Implementation

### `src/part-4/app/testable-error-boundary.js`

```js
"use strict";

export function createErrorBoundary({
  logger,
  reportError
}) {
  return {
    async run(operation, context = {}) {
      try {
        return await operation();
      } catch (error) {
        const structuredError = {
          name: error.name,
          message: error.message,
          context
        };

        logger.error(
          "operation failed",
          structuredError
        );

        try {
          await reportError(structuredError);
        } catch (reportingError) {
          logger.error(
            "error reporting failed",
            reportingError
          );
        }

        throw error;
      }
    }
  };
}
```

### `test/part-4/error-boundary.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createErrorBoundary
} from "../../src/part-4/app/testable-error-boundary.js";

test("error boundary reports context and rethrows original error", async () => {
  const logs = [];
  const reports = [];

  const boundary = createErrorBoundary({
    logger: {
      error(message, details) {
        logs.push({ message, details });
      }
    },

    reportError: async (error) => {
      reports.push(error);
    }
  });

  const originalError = new Error("database failed");

  await assert.rejects(
    boundary.run(
      async () => {
        throw originalError;
      },
      {
        operation: "load-dashboard"
      }
    ),
    (error) => error === originalError
  );

  assert.equal(logs.length, 1);
  assert.equal(reports.length, 1);
  assert.deepEqual(reports[0].context, {
    operation: "load-dashboard"
  });
});

test("reporting failure does not replace the original error", async () => {
  const boundary = createErrorBoundary({
    logger: {
      error() {}
    },

    reportError: async () => {
      throw new Error("reporting failed");
    }
  });

  const originalError = new Error("original failure");

  await assert.rejects(
    boundary.run(async () => {
      throw originalError;
    }),
    (error) => error === originalError
  );
});
```

## Verification

Run:

```bash
node --test test/part-4/error-boundary.test.js
```

---

# E.16: Testing Resource Cleanup

## The Target

We will verify that a resource owner closes timers and cleanup callbacks.

## Implementation

### `src/part-4/memory/testable-scope.js`

```js
"use strict";

export function createResourceScope({
  setIntervalFunction = setInterval,
  clearIntervalFunction = clearInterval
} = {}) {
  const cleanupFunctions = new Set();
  let closed = false;

  function addCleanup(cleanup) {
    if (closed) {
      throw new Error("scope is closed");
    }

    cleanupFunctions.add(cleanup);

    return () => {
      cleanupFunctions.delete(cleanup);
    };
  }

  function addInterval(callback, milliseconds) {
    if (typeof callback !== "function") {
      throw new TypeError("callback must be a function");
    }

    const intervalId = setIntervalFunction(
      callback,
      milliseconds
    );

    addCleanup(() => {
      clearIntervalFunction(intervalId);
    });

    return intervalId;
  }

  function close() {
    if (closed) {
      return;
    }

    closed = true;

    for (const cleanup of cleanupFunctions) {
      cleanup();
    }

    cleanupFunctions.clear();
  }

  return {
    addCleanup,
    addInterval,
    close
  };
}
```

### `test/part-4/resource-scope.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createResourceScope
} from "../../src/part-4/memory/testable-scope.js";

test("closing a resource scope runs cleanup", () => {
  const cleaned = [];

  const scope = createResourceScope({
    setIntervalFunction: () => "interval-1",
    clearIntervalFunction: (id) => {
      cleaned.push(id);
    }
  });

  scope.addInterval(() => {}, 100);
  scope.close();

  assert.deepEqual(cleaned, ["interval-1"]);
});

test("closing a scope is idempotent", () => {
  let cleanupCount = 0;

  const scope = createResourceScope();

  scope.addCleanup(() => {
    cleanupCount += 1;
  });

  scope.close();
  scope.close();

  assert.equal(cleanupCount, 1);
});

test("closed scopes reject new cleanup registrations", () => {
  const scope = createResourceScope();

  scope.close();

  assert.throws(
    () => scope.addCleanup(() => {}),
    {
      message: "scope is closed"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-4/resource-scope.test.js
```

---

# E.17: Testing HTTP Clients Without Real Network Calls

## The Target

We will create a request client that accepts an injected `fetch` implementation.

## The Concept

Tests should not depend on real external services because networks are:

- Slow.
- Unavailable.
- Variable.
- Difficult to control.
- Potentially expensive.

Injecting `fetch` lets tests provide a deterministic fake.

## Implementation

### `src/part-2/request-client.js`

```js
"use strict";

export function createRequestClient({
  fetchFunction = fetch,
  baseUrl
}) {
  if (typeof fetchFunction !== "function") {
    throw new TypeError(
      "fetchFunction must be a function"
    );
  }

  if (typeof baseUrl !== "string") {
    throw new TypeError("baseUrl must be a string");
  }

  return Object.freeze({
    async get(path, options = {}) {
      const response = await fetchFunction(
        new URL(path, baseUrl),
        {
          method: "GET",
          ...options
        }
      );

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
  });
}
```

### `test/part-2/request-client.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createRequestClient
} from "../../src/part-2/request-client.js";

test("request client calls the injected fetch function", async () => {
  const calls = [];

  const client = createRequestClient({
    baseUrl: "https://api.example.test",

    fetchFunction: async (url, options) => {
      calls.push({
        url: url.toString(),
        options
      });

      return {
        ok: true,
        status: 200,
        async json() {
          return {
            requestsPerSecond: 125
          };
        }
      };
    }
  });

  const result = await client.get("/metrics");

  assert.deepEqual(result, {
    requestsPerSecond: 125
  });

  assert.deepEqual(calls, [
    {
      url: "https://api.example.test/metrics",
      options: {
        method: "GET"
      }
    }
  ]);
});

test("request client throws for an unsuccessful response", async () => {
  const client = createRequestClient({
    baseUrl: "https://api.example.test",

    fetchFunction: async () => ({
      ok: false,
      status: 503
    })
  });

  await assert.rejects(
    client.get("/metrics"),
    {
      name: "HttpError",
      message: "request failed with status 503"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-2/request-client.test.js
```

---

# E.18: Testing Environment Configuration

## The Target

We will test configuration parsing without modifying the real process environment.

## Implementation

### `src/part-4/app/configuration.js`

```js
"use strict";

function parsePositiveInteger(
  value,
  fallback,
  name
) {
  const selectedValue =
    value === undefined ? fallback : Number(value);

  if (
    !Number.isInteger(selectedValue) ||
    selectedValue <= 0
  ) {
    throw new Error(
      `${name} must be a positive integer`
    );
  }

  return selectedValue;
}

export function loadConfiguration(
  environment = process.env
) {
  return Object.freeze({
    environment:
      environment.APP_ENV ?? "development",

    requestTimeoutMilliseconds:
      parsePositiveInteger(
        environment.REQUEST_TIMEOUT_MS,
        5_000,
        "REQUEST_TIMEOUT_MS"
      ),

    retryMaximumAttempts:
      parsePositiveInteger(
        environment.RETRY_MAX_ATTEMPTS,
        3,
        "RETRY_MAX_ATTEMPTS"
      )
  });
}
```

### `test/part-4/configuration.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  loadConfiguration
} from "../../src/part-4/app/configuration.js";

test("configuration uses defaults", () => {
  const configuration = loadConfiguration({});

  assert.deepEqual(configuration, {
    environment: "development",
    requestTimeoutMilliseconds: 5_000,
    retryMaximumAttempts: 3
  });
});

test("configuration parses valid values", () => {
  const configuration = loadConfiguration({
    APP_ENV: "production",
    REQUEST_TIMEOUT_MS: "2000",
    RETRY_MAX_ATTEMPTS: "5"
  });

  assert.deepEqual(configuration, {
    environment: "production",
    requestTimeoutMilliseconds: 2_000,
    retryMaximumAttempts: 5
  });
});

test("configuration rejects invalid values", () => {
  assert.throws(
    () =>
      loadConfiguration({
        REQUEST_TIMEOUT_MS: "invalid"
      }),
    {
      message:
        "REQUEST_TIMEOUT_MS must be a positive integer"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/part-4/configuration.test.js
```

Passing the environment object as an argument keeps the function easy to test.

---

# E.19: Integration Testing a Dashboard Workflow

## The Target

We will test several real application layers together:

- Fake services.
- Retry.
- Partial results.
- Store updates.

## Implementation

### `src/part-4/app/testable-dashboard.js`

```js
"use strict";

export async function loadDashboard({
  services,
  retry
}) {
  const entries = Object.entries(services);

  const results = await Promise.allSettled(
    entries.map(async ([name, service]) => {
      const value = await retry({
        operation: () => service.load(),
        isRetryable: (error) =>
          error.retryable === true
      });

      return {
        name,
        value
      };
    })
  );

  return Object.fromEntries(
    results.map((result, index) => {
      const name = entries[index][0];

      if (result.status === "fulfilled") {
        return [
          name,
          {
            status: "available",
            value: result.value.value
          }
        ];
      }

      return [
        name,
        {
          status: "unavailable",
          error: result.reason.message
        }
      ];
    })
  );
}
```

### `test/part-4/dashboard.integration.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  loadDashboard
} from "../../src/part-4/app/testable-dashboard.js";

test("dashboard preserves partial service results", async () => {
  let metricsAttempts = 0;

  const services = {
    metrics: {
      async load() {
        metricsAttempts += 1;

        if (metricsAttempts === 1) {
          const error = new Error("temporary metrics failure");
          error.retryable = true;
          throw error;
        }

        return {
          requestsPerSecond: 125
        };
      }
    },

    health: {
      async load() {
        throw new Error("health unavailable");
      }
    }
  };

  async function retry({
    operation,
    isRetryable
  }) {
    for (let attempt = 1; attempt <= 3; attempt += 1) {
      try {
        return await operation();
      } catch (error) {
        if (
          !isRetryable(error) ||
          attempt === 3
        ) {
          throw error;
        }
      }
    }

    throw new Error("retry unexpectedly ended");
  }

  const result = await loadDashboard({
    services,
    retry
  });

  assert.deepEqual(result, {
    metrics: {
      status: "available",
      value: {
        requestsPerSecond: 125
      }
    },

    health: {
      status: "unavailable",
      error: "health unavailable"
    }
  });

  assert.equal(metricsAttempts, 2);
});
```

## Verification

Run:

```bash
node --test test/part-4/dashboard.integration.test.js
```

---

# E.20: Test Hooks and Cleanup

## The Target

We will use `beforeEach`, `afterEach`, and related hooks.

## The Concept

Hooks prepare and clean up test state.

Available hooks include:

- `before()`: once before a suite.
- `after()`: once after a suite.
- `beforeEach()`: before every test.
- `afterEach()`: after every test.

## Implementation

### `test/fixtures/lifecycle.test.js`

```js
"use strict";

import test, {
  beforeEach,
  afterEach
} from "node:test";

import assert from "node:assert/strict";

let values;

beforeEach(() => {
  values = [];
});

afterEach(() => {
  values = null;
});

test("first test receives clean state", () => {
  values.push("first");

  assert.deepEqual(values, ["first"]);
});

test("second test also receives clean state", () => {
  assert.deepEqual(values, []);

  values.push("second");

  assert.deepEqual(values, ["second"]);
});
```

## Verification

Run:

```bash
node --test test/fixtures/lifecycle.test.js
```

Each test receives a fresh array.

---

# E.21: Test Context

Node’s test runner can provide a test context object.

```js
import test from "node:test";
import assert from "node:assert/strict";

test("context exposes test metadata", (t) => {
  assert.equal(typeof t.name, "string");
});
```

The context can also support features such as:

- Test diagnostics.
- Mocking in supported Node versions.
- Timers in supported Node versions.
- Nested tests.
- Cleanup registration.

Check the Node.js version documentation when using newer test-context APIs.

---

# E.22: Nested Tests

## Implementation

### `nested-tests.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

test("retry behavior", async (t) => {
  await t.test("succeeds on first attempt", () => {
    assert.equal(1 + 1, 2);
  });

  await t.test("can retry a temporary failure", () => {
    assert.equal("temporary".includes("temp"), true);
  });
});
```

## Verification

Run:

```bash
node --test nested-tests.test.js
```

Nested tests can group related behavior while preserving individual results.

---

# E.23: Test Name Filtering

Run all tests:

```bash
npm test
```

Run tests whose names match a pattern:

```bash
node --test --test-name-pattern="retry"
```

Run one file:

```bash
node --test test/part-4/retry.test.js
```

Run with watch mode:

```bash
npm run test:watch
```

Watch mode reruns tests when files change.

---

# E.24: Code Coverage

## The Target

We will run Node’s built-in coverage reporting.

## Verification

Run:

```bash
npm run test:coverage
```

Node will report coverage information such as:

- Line coverage.
- Branch coverage.
- Function coverage.
- Uncovered lines.

Coverage is useful, but it is not proof of quality.

This test:

```js
assert.equal(add(2, 3), 5);
```

may cover the implementation line without checking:

- Invalid inputs.
- Boundary values.
- Error behavior.
- State mutation.
- Cancellation.
- Cleanup.

Aim for meaningful behavior coverage, not merely a high percentage.

---

# E.25: Testing Error Paths

A production-grade test suite should test failure behavior explicitly.

## Invalid Input

```js
test("rejects invalid timeout", () => {
  assert.throws(
    () => createTimeout(-1),
    {
      name: "RangeError"
    }
  );
});
```

## Dependency Failure

```js
test("returns a controlled unavailable state", async () => {
  const result = await loadOptionalPanel({
    load: async () => {
      throw new Error("service unavailable");
    }
  });

  assert.deepEqual(result, {
    status: "unavailable"
  });
});
```

## Cancellation

```js
test("does not display cancelled work", async () => {
  const controller = new AbortController();

  const promise = loadData(controller.signal);

  controller.abort();

  await assert.rejects(promise, {
    name: "AbortError"
  });
});
```

## Cleanup Failure

```js
test("reports cleanup failure", async () => {
  await assert.rejects(
    shutdownApplication(),
    {
      message: "shutdown cleanup failed"
    }
  );
});
```

---

# E.26: Testing Logs Without Polluting Output

## The Target

We will inject a logger instead of testing `console.log()` directly.

## Implementation

### `test/fixtures/recording-logger.js`

```js
"use strict";

export function createRecordingLogger() {
  const entries = [];

  return {
    info(message, details) {
      entries.push({
        level: "info",
        message,
        details
      });
    },

    warn(message, details) {
      entries.push({
        level: "warn",
        message,
        details
      });
    },

    error(message, details) {
      entries.push({
        level: "error",
        message,
        details
      });
    },

    entries
  };
}
```

### `logger.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createRecordingLogger
} from "./recording-logger.js";

test("recording logger stores structured entries", () => {
  const logger = createRecordingLogger();

  logger.info("request started", {
    service: "metrics"
  });

  logger.error("request failed", {
    status: 503
  });

  assert.deepEqual(logger.entries, [
    {
      level: "info",
      message: "request started",
      details: {
        service: "metrics"
      }
    },
    {
      level: "error",
      message: "request failed",
      details: {
        status: 503
      }
    }
  ]);
});
```

This is preferable to intercepting global console methods because it keeps tests isolated.

---

# E.27: Testing Events

## The Target

We will test an event emitter using a promise.

## Implementation

### `event-helper.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";
import { EventEmitter } from "node:events";

function waitForEvent(
  emitter,
  eventName,
  timeoutMilliseconds = 100
) {
  return new Promise((resolve, reject) => {
    const timerId = setTimeout(() => {
      emitter.removeListener(
        eventName,
        handleEvent
      );

      reject(
        new Error(
          `timed out waiting for ${eventName}`
        )
      );
    }, timeoutMilliseconds);

    function handleEvent(value) {
      clearTimeout(timerId);
      resolve(value);
    }

    emitter.once(eventName, handleEvent);
  });
}

test("waitForEvent resolves with emitted data", async () => {
  const emitter = new EventEmitter();

  const resultPromise = waitForEvent(
    emitter,
    "ready"
  );

  emitter.emit("ready", {
    status: "healthy"
  });

  const result = await resultPromise;

  assert.deepEqual(result, {
    status: "healthy"
  });
});
```

## Verification

Run:

```bash
node --test event-helper.test.js
```

Event tests must clean up listeners and timers in both success and timeout paths.

---

# E.28: Testing Resource Leaks

Memory leaks are difficult to prove with one unit test, but tests can verify cleanup contracts.

## Test Cleanup Contract

```js
test("unsubscribe removes the listener", () => {
  const source = createSource();
  const listener = () => {};

  const unsubscribe = source.subscribe(listener);

  assert.equal(source.listenerCount(), 1);

  unsubscribe();

  assert.equal(source.listenerCount(), 0);
});
```

## Test Timer Cleanup

Inject timer functions or expose a `close()` method:

```js
const polling = createPollingService({
  setIntervalFunction,
  clearIntervalFunction
});

polling.start();
polling.stop();

assert.equal(activeIntervals.size, 0);
```

The test does not need to force garbage collection. It verifies that the application removed the references it owns.

---

# E.29: Testing Flaky Time-Dependent Behavior

Avoid assertions such as:

```js
assert.ok(elapsedMilliseconds < 10);
```

Machine load can make this test unreliable.

Prefer assertions about behavior:

```js
assert.equal(operationWasCancelled, true);
assert.equal(timerWasCleared, true);
```

If timing itself matters, use generous limits and test in a controlled environment.

Bad:

```js
assert.equal(elapsed, 20);
```

Better:

```js
assert.ok(elapsed >= 20);
```

Best when possible:

```js
assert.equal(fakeClock.currentTime, 20);
```

---

# E.30: Testing Randomized Backoff

Inject randomness.

## Implementation

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  calculateBackoffDelay
} from "../../src/part-4/resilience/backoff.js";

test("backoff is deterministic with injected random value", () => {
  const delay = calculateBackoffDelay({
    attempt: 3,
    baseDelayMilliseconds: 100,
    maximumDelayMilliseconds: 1_000,
    random: () => 0.5
  });

  assert.equal(delay, 200);
});
```

Do not test that a random value equals one exact result when using real randomness.

Test invariants instead:

```js
test("backoff stays within bounds", () => {
  for (let index = 0; index < 100; index += 1) {
    const delay = calculateBackoffDelay({
      attempt: 4
    });

    assert.ok(delay >= 0);
    assert.ok(delay <= 800);
  }
});
```

---

# E.31: Property-Based Thinking

Even without a property-testing library, test general rules.

For a pure function:

```text
same input → same output
```

For an average:

```text
average([x]) === x
```

For a bounded collection:

```text
length <= maximumSize
```

For a retry helper:

```text
attempts <= maximumAttempts
```

For a circuit breaker:

```text
state is always CLOSED, OPEN, or HALF_OPEN
```

Example:

```js
test("bounded history never exceeds its maximum", () => {
  const history = createBoundedHistory(3);

  for (let index = 0; index < 100; index += 1) {
    history.add(index);
  }

  assert.ok(history.values().length <= 3);
});
```

---

# E.32: Testing Module Boundaries

A module test should verify the public API rather than internal implementation details.

Prefer:

```js
const service = createService(dependencies);

const result = await service.load();

assert.deepEqual(result, expected);
```

Avoid testing private local variables directly.

This allows internal refactoring without rewriting tests, as long as the public behavior remains correct.

---

# E.33: Testing Dependency Injection

## The Target

We will test a service with a fake request client and recording logger.

## Implementation

### `src/part-3/data/metrics-service.js`

```js
"use strict";

export function createMetricsService({
  requestClient,
  logger
}) {
  if (!requestClient) {
    throw new TypeError(
      "requestClient is required"
    );
  }

  if (!logger) {
    throw new TypeError("logger is required");
  }

  return Object.freeze({
    async load() {
      logger.info("loading metrics");

      const metrics = await requestClient.get(
        "/metrics"
      );

      logger.info("metrics loaded");

      return metrics;
    }
  });
}
```

### `test/part-3/metrics-service.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

import {
  createMetricsService
} from "../../src/part-3/data/metrics-service.js";

test("metrics service uses injected dependencies", async () => {
  const calls = [];
  const logs = [];

  const service = createMetricsService({
    requestClient: {
      async get(path) {
        calls.push(path);

        return {
          requestsPerSecond: 125
        };
      }
    },

    logger: {
      info(message) {
        logs.push(message);
      }
    }
  });

  const result = await service.load();

  assert.deepEqual(result, {
    requestsPerSecond: 125
  });

  assert.deepEqual(calls, ["/metrics"]);

  assert.deepEqual(logs, [
    "loading metrics",
    "metrics loaded"
  ]);
});
```

## Verification

Run:

```bash
node --test test/part-3/metrics-service.test.js
```

---

# E.34: Test Naming Guidelines

Good test names explain behavior:

```text
retry stops after the maximum attempt count
```

Weak test names describe implementation:

```text
calls loop three times
```

Good names remain useful if the implementation changes.

Prefer:

- `returns stale data when refresh fails`
- `does not notify when the value is unchanged`
- `cancels the previous search when a new query starts`
- `opens the circuit after consecutive dependency failures`

---

# E.35: Test Organization

A useful project layout is:

```text
test/
├── part-1/
│   ├── closures.test.js
│   ├── hoisting.test.js
│   └── this-binding.test.js
├── part-2/
│   ├── promises.test.js
│   ├── cancellation.test.js
│   └── request-client.test.js
├── part-3/
│   ├── state-updates.test.js
│   ├── reactive-state.test.js
│   └── metrics-service.test.js
├── part-4/
│   ├── retry.test.js
│   ├── circuit-breaker.test.js
│   ├── debounce.test.js
│   └── error-boundary.test.js
└── fixtures/
    ├── recording-logger.js
    └── fake-clock.js
```

Keep unit tests close to the responsibility they verify.

---

# E.36: Full Test Commands

Run every test:

```bash
npm test
```

Watch tests:

```bash
npm run test:watch
```

Run with coverage:

```bash
npm run test:coverage
```

Run one test file:

```bash
node --test test/part-4/retry.test.js
```

Filter by test name:

```bash
node --test --test-name-pattern="circuit"
```

Run with verbose output:

```bash
node --test --test-reporter=spec
```

---

# E.37: Verification Checklist for Each Test

Before considering a test complete, ask:

## Arrange

- Are inputs explicit?
- Are dependencies controlled?
- Is shared state reset?
- Are timers and resources owned?

## Act

- Is the behavior under test obvious?
- Is the operation awaited when asynchronous?
- Could a rejected promise escape?

## Assert

- Is the result checked?
- Are error types and messages checked where useful?
- Are side effects checked?
- Is cleanup checked?
- Are reference identities checked when immutability matters?

## Cleanup

- Are subscriptions removed?
- Are timers cleared?
- Are temporary files deleted?
- Are environment variables restored?
- Are servers and workers closed?

---

# E.38: Full Verification Checklist for Runtime Monitor

Run:

```bash
npm test
npm run test:coverage
```

Then run the demonstration commands:

```bash
npm run context
npm run hoisting
npm run closures
npm run this
npm run event-loop
npm run cancellation
npm run timeout
npm run workflow
npm run pure
npm run compose
npm run curry
npm run immutable
npm run proxy
npm run reactive
npm run batched-state
npm run selectors
npm run debounce
npm run throttle
npm run batch-render
npm run retry
npm run breaker
npm run error-boundary
npm run production
```

Verify:

- Tests pass independently.
- Tests pass as a complete suite.
- Coverage runs without hanging timers.
- No unhandled rejections appear.
- No test depends on execution order.
- All asynchronous tests await their operations.
- Cleanup occurs after resource-based tests.
- Failure behavior is tested, not only success behavior.

---

# E.39: Testing Principles Summary

### Test Behavior, Not Implementation

Verify what callers can observe.

### Make Dependencies Replaceable

Inject:

- Clocks.
- Randomness.
- Fetch.
- Loggers.
- Timers.
- Storage.
- Network clients.

### Test Failure Paths

A service that works only when everything succeeds is not production-ready.

### Keep Tests Deterministic

Avoid unnecessary real time, real networks, and global state.

### Verify Cleanup

A passing result is not enough if the process retains timers or listeners.

### Use Integration Tests Strategically

Unit tests are fast and focused. Integration tests prove the modules connect correctly.

### Treat Coverage as Evidence, Not Proof

A percentage cannot replace thoughtful assertions.

---

# E.40: Final Testing Mental Model

For every important feature, verify this sequence:

```text
valid input
    │
    ▼
expected success
    │
    ▼
invalid input
    │
    ▼
expected failure
    │
    ▼
cancellation or timeout
    │
    ▼
cleanup
    │
    ▼
repeatability
```

For asynchronous production code, the minimum useful test matrix is often:

| Scenario | Expected behavior |
|---|---|
| Successful operation | Returns expected data |
| Invalid input | Rejects or throws clearly |
| Temporary failure | Retries when appropriate |
| Permanent failure | Stops without wasteful retries |
| Timeout | Cancels or rejects at the deadline |
| Cancellation | Stops without false failure reporting |
| Partial dependency failure | Preserves available results |
| Repeated invocation | Does not leak resources |
| Shutdown | Cleans up active work |
| Unexpected exception | Reaches an error boundary |

A strong test suite does not merely prove that the happy path works. It documents how the application behaves when time, dependencies, input, and lifecycle conditions become difficult.
