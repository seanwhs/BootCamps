# Primer 5: Testing Fundamentals

Testing is how we turn assumptions into repeatable evidence.

A test answers a focused question:

> Given this input and these conditions, does the application produce the expected behavior?

This primer covers:

- Why tests matter.
- Unit tests.
- Integration tests.
- Test structure.
- Assertions.
- Synchronous tests.
- Asynchronous tests.
- Error testing.
- Test isolation.
- Test fixtures.
- Test doubles.
- Dependency injection.
- Cleanup.
- Coverage.
- Performance tests.
- Testing cancellation and retries.

We will use Node.js’s built-in test runner, so no external test framework is required.

---

# 1. Prepare the Workspace

## The Target

We will create a small testing project.

## The Concept

A test project should be easy to run from a clean checkout.

## Implementation

Run:

```bash
mkdir -p primer-5/src
mkdir -p primer-5/test
mkdir -p primer-5/test/fixtures
```

Create:

### `primer-5/package.json`

```json
{
  "name": "runtime-monitor-primer-5",
  "version": "1.0.0",
  "private": true,
  "description": "Testing fundamentals for modern JavaScript",
  "type": "module",
  "scripts": {
    "test": "node --test",
    "test:watch": "node --test --watch",
    "test:coverage": "node --experimental-test-coverage --test"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## Verification

Run:

```bash
cd primer-5
npm test
```

At this stage, Node may report that no tests were found. That is expected until we create a test file.

---

# 2. What Makes a Good Test?

## The Target

We will write a basic test with three explicit stages.

## The Concept

A clear test has three parts:

### Arrange

Prepare the inputs and dependencies.

### Act

Execute the behavior.

### Assert

Check the result.

The pattern is:

```text
Arrange → Act → Assert
```

Think of a test like a controlled experiment:

- Set up the laboratory.
- Run the experiment.
- Compare the observation with the expected result.

## Implementation

### `primer-5/test/basic.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

function add(first, second) {
  return first + second;
}

test("add returns the sum of two numbers", () => {
  // Arrange
  const first = 2;
  const second = 3;

  // Act
  const result = add(first, second);

  // Assert
  assert.equal(result, 5);
});
```

## Verification

Run:

```bash
npm test
```

Expected output indicates that one test passed.

---

# 3. Test Names

## The Target

We will write behavior-focused test names.

## The Concept

A test name should explain what the code promises, not how the implementation happens to work.

Good:

```text
retry stops after the maximum number of attempts
```

Weak:

```text
loop runs three times
```

The good name remains useful if the internal implementation changes.

## Implementation

### `primer-5/test/names.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

function isHealthy(status) {
  return status === "healthy";
}

test("healthy status is recognized as healthy", () => {
  assert.equal(isHealthy("healthy"), true);
});

test("degraded status is not recognized as healthy", () => {
  assert.equal(isHealthy("degraded"), false);
});

test("unknown status is not recognized as healthy", () => {
  assert.equal(isHealthy("unknown"), false);
});
```

## Verification

Run:

```bash
node --test test/names.test.js
```

---

# 4. Assertion Methods

## The Target

We will use the most common assertion types.

## The Concept

An assertion is a statement about what should be true.

If the assertion fails, the test fails.

## Implementation

### `primer-5/test/assertions.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

test("strict equality", () => {
  assert.equal(2 + 3, 5);
});

test("deep object equality", () => {
  assert.deepEqual(
    {
      name: "metrics",
      status: "healthy"
    },
    {
      name: "metrics",
      status: "healthy"
    }
  );
});

test("strict reference identity", () => {
  const state = {};

  assert.strictEqual(state, state);
  assert.notStrictEqual({}, {});
});

test("truthy values", () => {
  assert.ok("non-empty string");
  assert.ok(42);
});

test("arrays contain expected values", () => {
  assert.deepEqual(
    ["metrics", "health"],
    ["metrics", "health"]
  );
});
```

## Verification

Run:

```bash
node --test test/assertions.test.js
```

## Common Assertions

```js
assert.equal(actual, expected);
assert.notEqual(actual, unexpected);
assert.strictEqual(actual, expected);
assert.notStrictEqual(actual, unexpected);
assert.deepEqual(actual, expected);
assert.notDeepEqual(actual, unexpected);
assert.ok(value);
assert.throws(function);
assert.rejects(promise);
```

---

# 5. Testing a Pure Function

## The Target

We will test a pure service selector.

## The Concept

Pure functions are easy to test because:

- They do not depend on the clock.
- They do not use the network.
- They do not use global state.
- The same input should produce the same output.

## Implementation

### `primer-5/src/service-selectors.js`

```js
export function selectHealthyServices(services) {
  if (!Array.isArray(services)) {
    throw new TypeError(
      "services must be an array"
    );
  }

  return services.filter(
    (service) => service.status === "healthy"
  );
}

export function calculateAverageLatency(services) {
  if (!Array.isArray(services)) {
    throw new TypeError(
      "services must be an array"
    );
  }

  const measuredServices = services.filter(
    (service) =>
      Number.isFinite(
        service.latencyMilliseconds
      )
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

### `primer-5/test/service-selectors.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  selectHealthyServices,
  calculateAverageLatency
} from "../src/service-selectors.js";

test("selectHealthyServices returns healthy services", () => {
  const services = [
    {
      name: "metrics",
      status: "healthy"
    },
    {
      name: "health",
      status: "degraded"
    },
    {
      name: "activity",
      status: "healthy"
    }
  ];

  const result = selectHealthyServices(services);

  assert.deepEqual(result, [
    {
      name: "metrics",
      status: "healthy"
    },
    {
      name: "activity",
      status: "healthy"
    }
  ]);
});

test("selectHealthyServices does not mutate input", () => {
  const services = [
    {
      name: "metrics",
      status: "healthy"
    }
  ];

  const before = structuredClone(services);

  selectHealthyServices(services);

  assert.deepEqual(services, before);
});

test("calculateAverageLatency calculates the average", () => {
  const services = [
    {
      latencyMilliseconds: 20
    },
    {
      latencyMilliseconds: 40
    },
    {
      latencyMilliseconds: 60
    }
  ];

  assert.equal(
    calculateAverageLatency(services),
    40
  );
});

test("average ignores services without latency", () => {
  const services = [
    {
      latencyMilliseconds: 20
    },
    {
      status: "loading"
    },
    {
      latencyMilliseconds: 40
    }
  ];

  assert.equal(
    calculateAverageLatency(services),
    30
  );
});

test("average returns null without measured services", () => {
  assert.equal(
    calculateAverageLatency([
      {
        status: "loading"
      }
    ]),
    null
  );
});
```

## Verification

Run:

```bash
node --test test/service-selectors.test.js
```

---

# 6. Testing Invalid Input

## The Target

We will verify that invalid input produces the correct error.

## The Concept

A test suite should cover failure behavior, not only successful values.

## Implementation

### `primer-5/test/invalid-input.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  selectHealthyServices,
  calculateAverageLatency
} from "../src/service-selectors.js";

test("selectHealthyServices rejects non-arrays", () => {
  assert.throws(
    () => selectHealthyServices(null),
    {
      name: "TypeError",
      message: "services must be an array"
    }
  );
});

test("calculateAverageLatency rejects non-arrays", () => {
  assert.throws(
    () => calculateAverageLatency({}),
    {
      name: "TypeError",
      message: "services must be an array"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/invalid-input.test.js
```

---

# 7. Testing Custom Errors

## The Target

We will test error classes and properties.

## Implementation

### `primer-5/src/errors.js`

```js
export class ValidationError extends Error {
  constructor(message, field) {
    super(message);

    this.name = "ValidationError";
    this.field = field;
  }
}

export function validateServiceName(name) {
  if (
    typeof name !== "string" ||
    name.trim() === ""
  ) {
    throw new ValidationError(
      "service name is required",
      "name"
    );
  }

  return name.trim();
}
```

### `primer-5/test/errors.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  ValidationError,
  validateServiceName
} from "../src/errors.js";

test("valid service name is returned", () => {
  assert.equal(
    validateServiceName(" metrics "),
    "metrics"
  );
});

test("invalid service name throws ValidationError", () => {
  assert.throws(
    () => validateServiceName(""),
    (error) => {
      assert.equal(
        error instanceof ValidationError,
        true
      );

      assert.equal(
        error.name,
        "ValidationError"
      );

      assert.equal(error.field, "name");
      assert.equal(
        error.message,
        "service name is required"
      );

      return true;
    }
  );
});
```

## Verification

Run:

```bash
node --test test/errors.test.js
```

A predicate function gives you detailed control over error verification.

---

# 8. Testing Asynchronous Success

## The Target

We will test a promise-based delay.

## The Concept

An asynchronous test must use `async` and `await` or return the promise.

Otherwise, the test runner may finish before the operation completes.

## Implementation

### `primer-5/src/delay.js`

```js
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

### `primer-5/test/async-success.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import { delay } from "../src/delay.js";

test("delay resolves with the provided value", async () => {
  const result = await delay(5, "completed");

  assert.equal(result, "completed");
});

test("promise can be returned directly", () => {
  return delay(5, "completed").then((result) => {
    assert.equal(result, "completed");
  });
});
```

## Verification

Run:

```bash
node --test test/async-success.test.js
```

---

# 9. Testing Asynchronous Rejection

## The Target

We will test rejected promises with `assert.rejects()`.

## The Concept

`assert.rejects()` waits for a promise and verifies that it rejects.

## Implementation

### `primer-5/test/async-errors.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import { delay } from "../src/delay.js";

test("invalid delay throws synchronously", () => {
  assert.throws(
    () => delay(-1, "invalid"),
    {
      name: "RangeError",
      message:
        "milliseconds must be non-negative and finite"
    }
  );
});

test("rejected promise can be asserted", async () => {
  const operation = Promise.reject(
    new Error("service unavailable")
  );

  await assert.rejects(operation, {
    name: "Error",
    message: "service unavailable"
  });
});
```

## Verification

Run:

```bash
node --test test/async-errors.test.js
```

---

# 10. Testing Cancellation

## The Target

We will test a cancellation-aware operation.

## Implementation

### `primer-5/src/cancellable-delay.js`

```js
export function cancellableDelay(
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

    const handleAbort = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();

      const error = new Error("operation cancelled");
      error.name = "AbortError";

      reject(error);
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
      {
        once: true
      }
    );
  });
}
```

### `primer-5/test/cancellation.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  cancellableDelay
} from "../src/cancellable-delay.js";

test("operation completes when not cancelled", async () => {
  const controller = new AbortController();

  const result = await cancellableDelay(
    1,
    "completed",
    controller.signal
  );

  assert.equal(result, "completed");
});

test("operation rejects with AbortError after cancellation", async () => {
  const controller = new AbortController();

  const operation = cancellableDelay(
    1_000,
    "not completed",
    controller.signal
  );

  controller.abort();

  await assert.rejects(operation, {
    name: "AbortError",
    message: "operation cancelled"
  });
});

test("already-aborted signal rejects immediately", async () => {
  const controller = new AbortController();

  controller.abort();

  await assert.rejects(
    cancellableDelay(
      1,
      "not completed",
      controller.signal
    ),
    {
      name: "AbortError"
    }
  );
});
```

## Verification

Run:

```bash
node --test test/cancellation.test.js
```

---

# 11. Test Fixtures

## The Target

We will create reusable test data.

## The Concept

A fixture is controlled data used by tests.

Fixtures reduce duplication, but they should not hide important differences between tests.

## Implementation

### `primer-5/test/fixtures/services.js`

```js
export function createHealthyMetrics() {
  return {
    name: "metrics",
    status: "healthy",
    latencyMilliseconds: 42
  };
}

export function createDegradedHealth() {
  return {
    name: "health",
    status: "degraded",
    latencyMilliseconds: 120
  };
}

export function createServiceList() {
  return [
    createHealthyMetrics(),
    createDegradedHealth()
  ];
}
```

### `primer-5/test/fixtures.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createHealthyMetrics,
  createDegradedHealth,
  createServiceList
} from "./fixtures/services.js";

test("fixtures create independent service objects", () => {
  const first = createHealthyMetrics();
  const second = createHealthyMetrics();

  assert.notStrictEqual(first, second);

  first.status = "degraded";

  assert.equal(second.status, "healthy");
});

test("service list contains expected fixtures", () => {
  assert.deepEqual(createServiceList(), [
    createHealthyMetrics(),
    createDegradedHealth()
  ]);
});
```

## Verification

Run:

```bash
node --test test/fixtures.test.js
```

Factory functions create fresh values and prevent tests from sharing accidental mutable state.

---

# 12. Test Isolation

## The Target

We will demonstrate independent test state.

## The Concept

Tests should not depend on:

- Another test running first.
- A previous test’s mutations.
- A global timer.
- A shared cache.
- A modified environment variable.

## Implementation

### `primer-5/test/isolation.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

let values;

test.beforeEach(() => {
  values = [];
});

test.afterEach(() => {
  values = null;
});

test("first test receives a clean array", () => {
  values.push("first");

  assert.deepEqual(values, ["first"]);
});

test("second test also receives a clean array", () => {
  assert.deepEqual(values, []);

  values.push("second");

  assert.deepEqual(values, ["second"]);
});
```

## Verification

Run:

```bash
node --test test/isolation.test.js
```

Both tests should pass regardless of execution order.

---

# 13. Test Hooks

## The Target

We will use setup and cleanup hooks.

## The Concept

Node’s test runner supports:

- `before()`: once before a group.
- `after()`: once after a group.
- `beforeEach()`: before every test.
- `afterEach()`: after every test.

Use hooks for shared setup and cleanup, but avoid hiding the important test inputs.

## Implementation

### `primer-5/test/hooks.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

let started;
let cleanedUp;

test.before(() => {
  started = true;
});

test.after(() => {
  cleanedUp = true;
});

test.beforeEach(() => {
  cleanedUp = false;
});

test.afterEach(() => {
  cleanedUp = true;
});

test("before hook ran", () => {
  assert.equal(started, true);
});

test("each test can observe its own setup", () => {
  assert.equal(cleanedUp, false);
});
```

## Verification

Run:

```bash
node --test test/hooks.test.js
```

---

# 14. Test Doubles

## The Target

We will replace a real dependency with a controlled fake.

## The Concept

A test double stands in for a real dependency.

### Stub

Returns controlled values.

### Spy

Records calls.

### Fake

Provides a simplified working implementation.

### Mock

Defines expected interactions.

For this series, simple fakes and recording spies are usually enough.

---

# 15. Dependency Injection

## The Target

We will create a service that receives its dependencies from the caller.

## The Concept

Dependency injection means a module does not secretly create the services it needs.

This:

```js
function createMetricsService({
  requestClient,
  logger
}) {}
```

is easier to test than a module that directly imports a global HTTP client and logger.

## Implementation

### `primer-5/src/metrics-service.js`

```js
export function createMetricsService({
  requestClient,
  logger
}) {
  if (
    !requestClient ||
    typeof requestClient.get !== "function"
  ) {
    throw new TypeError(
      "requestClient.get is required"
    );
  }

  if (
    !logger ||
    typeof logger.info !== "function"
  ) {
    throw new TypeError(
      "logger.info is required"
    );
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

### `primer-5/test/metrics-service.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createMetricsService
} from "../src/metrics-service.js";

test("metrics service loads through injected client", async () => {
  const requests = [];
  const logs = [];

  const service = createMetricsService({
    requestClient: {
      async get(path) {
        requests.push(path);

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

  assert.deepEqual(requests, ["/metrics"]);

  assert.deepEqual(logs, [
    "loading metrics",
    "metrics loaded"
  ]);
});
```

## Verification

Run:

```bash
node --test test/metrics-service.test.js
```

---

# 16. Recording Logger Fixture

## The Target

We will create a reusable logger that records messages.

## Implementation

### `primer-5/test/fixtures/recording-logger.js`

```js
export function createRecordingLogger() {
  const entries = [];

  return {
    entries,

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
    }
  };
}
```

### `primer-5/test/recording-logger.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createRecordingLogger
} from "./fixtures/recording-logger.js";

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

## Verification

Run:

```bash
node --test test/recording-logger.test.js
```

---

# 17. Testing HTTP Clients Without a Network

## The Target

We will inject `fetch()` into a client.

## The Concept

Real network calls are poor unit-test dependencies because they are:

- Slow.
- Unreliable.
- External.
- Difficult to control.
- Potentially expensive.

Injecting `fetch` lets the test control the response.

## Implementation

### `primer-5/src/http-client.js`

```js
export function createHttpClient({
  fetchFunction = fetch,
  baseUrl
}) {
  if (typeof fetchFunction !== "function") {
    throw new TypeError(
      "fetchFunction must be a function"
    );
  }

  if (typeof baseUrl !== "string") {
    throw new TypeError(
      "baseUrl must be a string"
    );
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

### `primer-5/test/http-client.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createHttpClient
} from "../src/http-client.js";

test("HTTP client parses successful JSON", async () => {
  const calls = [];

  const client = createHttpClient({
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

test("HTTP client throws for failed response", async () => {
  const client = createHttpClient({
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
node --test test/http-client.test.js
```

---

# 18. Integration Tests

## The Target

We will test two real modules working together.

## The Concept

A unit test isolates one function. An integration test verifies that multiple modules connect correctly.

We will combine:

```text
HTTP client
      │
      ▼
metrics service
```

## Implementation

### `primer-5/test/metrics-integration.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createHttpClient
} from "../src/http-client.js";

import {
  createMetricsService
} from "../src/metrics-service.js";

import {
  createRecordingLogger
} from "./fixtures/recording-logger.js";

test("metrics service integrates with HTTP client", async () => {
  const logger = createRecordingLogger();

  const requestClient = createHttpClient({
    baseUrl: "https://api.example.test",

    fetchFunction: async (url, options) => {
      assert.equal(
        url.toString(),
        "https://api.example.test/metrics"
      );

      assert.deepEqual(options, {
        method: "GET"
      });

      return {
        ok: true,
        status: 200,

        async json() {
          return {
            requestsPerSecond: 125,
            errorRate: 0.01
          };
        }
      };
    }
  });

  const service = createMetricsService({
    requestClient,
    logger
  });

  const result = await service.load();

  assert.deepEqual(result, {
    requestsPerSecond: 125,
    errorRate: 0.01
  });

  assert.equal(logger.entries.length, 2);
});
```

## Verification

Run:

```bash
node --test test/metrics-integration.test.js
```

This test uses a fake network boundary but real HTTP-client and service modules.

---

# 19. Testing State Transitions

## The Target

We will test immutable state updates.

## Implementation

### `primer-5/src/state.js`

```js
export function updateServiceStatus(
  state,
  serviceName,
  status
) {
  if (!state.services?.[serviceName]) {
    throw new Error(
      `unknown service: ${serviceName}`
    );
  }

  return {
    ...state,

    services: {
      ...state.services,

      [serviceName]: {
        ...state.services[serviceName],
        status
      }
    }
  };
}
```

### `primer-5/test/state.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  updateServiceStatus
} from "../src/state.js";

function createState() {
  return {
    services: {
      metrics: {
        status: "loading"
      },
      health: {
        status: "healthy"
      }
    }
  };
}

test("state transition updates selected service", () => {
  const nextState = updateServiceStatus(
    createState(),
    "metrics",
    "healthy"
  );

  assert.equal(
    nextState.services.metrics.status,
    "healthy"
  );
});

test("state transition does not mutate original state", () => {
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

test("state transition preserves unrelated service reference", () => {
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

test("unknown services are rejected", () => {
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
node --test test/state.test.js
```

---

# 20. Testing Reactive Subscriptions

## The Target

We will test notification and unsubscribe behavior.

## Implementation

### `primer-5/src/reactive-state.js`

```js
export function createReactiveState(
  initialState
) {
  const target = {
    ...initialState
  };

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
          subscriber({
            property,
            previousValue,
            nextValue: value
          });
        }
      }

      return didSet;
    }
  });

  return state;
}
```

### `primer-5/test/reactive-state.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createReactiveState
} from "../src/reactive-state.js";

test("subscriber receives a state change", () => {
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

test("unchanged values do not notify", () => {
  const state = createReactiveState({
    status: "idle"
  });

  let count = 0;

  state.subscribe(() => {
    count += 1;
  });

  state.status = "idle";

  assert.equal(count, 0);
});

test("unsubscribe stops notifications", () => {
  const state = createReactiveState({
    status: "idle"
  });

  let count = 0;

  const unsubscribe = state.subscribe(() => {
    count += 1;
  });

  unsubscribe();

  state.status = "loading";

  assert.equal(count, 0);
});
```

## Verification

Run:

```bash
node --test test/reactive-state.test.js
```

---

# 21. Testing Retry Logic

## The Target

We will test retry success and retry exhaustion.

## Implementation

### `primer-5/src/retry.js`

```js
export async function retry({
  operation,
  maximumAttempts,
  isRetryable = () => true,
  wait = async () => {}
}) {
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

      if (
        attempt >= maximumAttempts ||
        !isRetryable(error)
      ) {
        throw error;
      }

      await wait();
    }
  }

  throw lastError;
}
```

### `primer-5/test/retry.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import { retry } from "../src/retry.js";

test("retry succeeds after temporary failures", async () => {
  let attempts = 0;

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

    wait: async () => {}
  });

  assert.equal(result, "success");
  assert.equal(attempts, 3);
});

test("retry stops on non-retryable errors", async () => {
  let attempts = 0;

  await assert.rejects(
    retry({
      maximumAttempts: 5,

      operation: async () => {
        attempts += 1;

        const error = new Error("invalid input");
        error.retryable = false;
        throw error;
      },

      isRetryable: (error) =>
        error.retryable === true,

      wait: async () => {}
    }),
    {
      message: "invalid input"
    }
  );

  assert.equal(attempts, 1);
});

test("retry stops at maximum attempts", async () => {
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
node --test test/retry.test.js
```

---

# 22. Testing Time-Dependent Code with an Injected Clock

## The Target

We will avoid waiting for real time in tests.

## The Concept

Time-dependent code is easier to test when it receives a clock function.

Production:

```js
now: () => Date.now()
```

Test:

```js
now: () => fakeTime
```

## Implementation

### `primer-5/src/expiration.js`

```js
export function createExpirationChecker({
  now = () => Date.now()
} = {}) {
  let expiresAt = null;

  return {
    start(durationMilliseconds) {
      if (
        !Number.isFinite(durationMilliseconds) ||
        durationMilliseconds < 0
      ) {
        throw new RangeError(
          "duration must be non-negative and finite"
        );
      }

      expiresAt =
        now() + durationMilliseconds;
    },

    isExpired() {
      return (
        expiresAt !== null &&
        now() >= expiresAt
      );
    }
  };
}
```

### `primer-5/test/expiration.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createExpirationChecker
} from "../src/expiration.js";

test("expiration uses the injected clock", () => {
  let currentTime = 1_000;

  const expiration =
    createExpirationChecker({
      now: () => currentTime
    });

  expiration.start(500);

  assert.equal(expiration.isExpired(), false);

  currentTime = 1_499;

  assert.equal(expiration.isExpired(), false);

  currentTime = 1_500;

  assert.equal(expiration.isExpired(), true);
});
```

## Verification

Run:

```bash
node --test test/expiration.test.js
```

This test completes immediately and does not wait 500 milliseconds.

---

# 23. Testing Randomness

## The Target

We will inject a random-number function.

## The Concept

Random behavior is difficult to assert exactly.

Inject randomness when deterministic behavior matters.

## Implementation

### `primer-5/src/backoff.js`

```js
export function calculateBackoff({
  attempt,
  baseDelayMilliseconds = 100,
  random = Math.random
}) {
  const maximumDelay =
    baseDelayMilliseconds *
    2 ** (attempt - 1);

  return Math.floor(
    random() * (maximumDelay + 1)
  );
}
```

### `primer-5/test/backoff.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  calculateBackoff
} from "../src/backoff.js";

test("backoff can be deterministic with injected randomness", () => {
  const delay = calculateBackoff({
    attempt: 3,
    baseDelayMilliseconds: 100,
    random: () => 0.5
  });

  assert.equal(delay, 200);
});

test("backoff stays within expected bounds", () => {
  const maximumDelay = 800;

  for (let index = 0; index < 100; index += 1) {
    const delay = calculateBackoff({
      attempt: 4
    });

    assert.ok(delay >= 0);
    assert.ok(delay <= maximumDelay);
  }
});
```

## Verification

Run:

```bash
node --test test/backoff.test.js
```

---

# 24. Testing Cleanup

## The Target

We will verify that a subscription can be removed.

## The Concept

A test that only checks output may miss a memory leak.

Test the cleanup contract directly:

```text
subscribe → listener count increases
unsubscribe → listener count decreases
```

## Implementation

### `primer-5/src/event-source.js`

```js
export function createEventSource() {
  const listeners = new Set();

  return {
    emit(value) {
      for (const listener of listeners) {
        listener(value);
      }
    },

    subscribe(listener) {
      listeners.add(listener);

      return () => {
        listeners.delete(listener);
      };
    },

    listenerCount() {
      return listeners.size;
    }
  };
}
```

### `primer-5/test/cleanup.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  createEventSource
} from "../src/event-source.js";

test("unsubscribe removes listener", () => {
  const source = createEventSource();
  const received = [];

  const unsubscribe = source.subscribe((value) => {
    received.push(value);
  });

  assert.equal(source.listenerCount(), 1);

  source.emit("first");

  unsubscribe();

  assert.equal(source.listenerCount(), 0);

  source.emit("second");

  assert.deepEqual(received, ["first"]);
});
```

## Verification

Run:

```bash
node --test test/cleanup.test.js
```

---

# 25. Testing Logging

## The Target

We will verify structured logs without intercepting global `console` methods.

## The Concept

Inject a logger and provide a recording implementation in tests.

This is cleaner than replacing:

```js
console.log = fakeFunction;
```

## Implementation

### `primer-5/src/logged-operation.js`

```js
export async function runLoggedOperation({
  operation,
  logger
}) {
  logger.info("operation started");

  try {
    const result = await operation();

    logger.info("operation completed");

    return result;
  } catch (error) {
    logger.error("operation failed", {
      name: error.name,
      message: error.message
    });

    throw error;
  }
}
```

### `primer-5/test/logged-operation.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  runLoggedOperation
} from "../src/logged-operation.js";

test("successful operation logs start and completion", async () => {
  const logs = [];

  const result = await runLoggedOperation({
    operation: async () => "success",

    logger: {
      info(message, details) {
        logs.push({
          level: "info",
          message,
          details
        });
      },

      error() {}
    }
  });

  assert.equal(result, "success");

  assert.deepEqual(
    logs.map((entry) => entry.message),
    [
      "operation started",
      "operation completed"
    ]
  );
});

test("failed operation logs a structured error", async () => {
  const errors = [];

  const failure = new Error("service failed");

  await assert.rejects(
    runLoggedOperation({
      operation: async () => {
        throw failure;
      },

      logger: {
        info() {},

        error(message, details) {
          errors.push({
            message,
            details
          });
        }
      }
    }),
    (error) => error === failure
  );

  assert.deepEqual(errors, [
    {
      message: "operation failed",
      details: {
        name: "Error",
        message: "service failed"
      }
    }
  ]);
});
```

## Verification

Run:

```bash
node --test test/logged-operation.test.js
```

---

# 26. Integration Test Structure

## The Target

We will define an integration test for a dashboard workflow.

## The Concept

An integration test exercises multiple real modules while replacing only external boundaries.

For example:

```text
dashboard workflow
   │
   ├── metrics service
   ├── health service
   └── fake request client
```

## Implementation

### `primer-5/src/dashboard.js`

```js
export async function loadDashboard({
  metricsService,
  healthService
}) {
  const results = await Promise.allSettled([
    metricsService.load(),
    healthService.load()
  ]);

  return {
    metrics:
      results[0].status === "fulfilled"
        ? {
            status: "available",
            data: results[0].value
          }
        : {
            status: "unavailable",
            error: results[0].reason.message
          },

    health:
      results[1].status === "fulfilled"
        ? {
            status: "available",
            data: results[1].value
          }
        : {
            status: "unavailable",
            error: results[1].reason.message
          }
  };
}
```

### `primer-5/test/dashboard.integration.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  loadDashboard
} from "../src/dashboard.js";

test("dashboard preserves partial service results", async () => {
  const dashboard = await loadDashboard({
    metricsService: {
      async load() {
        return {
          requestsPerSecond: 125
        };
      }
    },

    healthService: {
      async load() {
        throw new Error("health service unavailable");
      }
    }
  });

  assert.deepEqual(dashboard, {
    metrics: {
      status: "available",
      data: {
        requestsPerSecond: 125
      }
    },

    health: {
      status: "unavailable",
      error: "health service unavailable"
    }
  });
});
```

## Verification

Run:

```bash
node --test test/dashboard.integration.test.js
```

---

# 27. Test Filtering

Run all tests:

```bash
npm test
```

Run one file:

```bash
node --test test/retry.test.js
```

Run tests whose names contain a phrase:

```bash
node --test --test-name-pattern="cancellation"
```

Run in watch mode:

```bash
npm run test:watch
```

Use filtering while developing, then run the full suite before committing.

---

# 28. Code Coverage

## The Target

We will run Node.js’s built-in coverage report.

## The Concept

Coverage reports which parts of the code were executed by tests.

Coverage can include:

- Line coverage.
- Branch coverage.
- Function coverage.

## Verification

Run:

```bash
npm run test:coverage
```

Coverage is useful, but a high percentage does not guarantee good tests.

This test:

```js
assert.equal(add(2, 3), 5);
```

does not prove that `add()` handles:

- Invalid types.
- Very large values.
- Negative values.
- Unexpected objects.

Good tests verify meaningful behavior and boundaries.

---

# 29. Testing Performance Budgets

## The Target

We will write a cautious performance test.

## The Concept

Performance tests can be affected by:

- Machine load.
- Operating-system scheduling.
- Runtime version.
- Garbage collection.
- Virtualized CI environments.

Use generous thresholds and focus on obvious regressions.

## Implementation

### `primer-5/test/performance.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

function summarizeServices(services) {
  return services.reduce(
    (summary, service) => {
      summary.total += 1;

      if (service.status === "healthy") {
        summary.healthy += 1;
      }

      return summary;
    },
    {
      total: 0,
      healthy: 0
    }
  );
}

test("summary stays within a generous performance budget", () => {
  const services = Array.from(
    { length: 10_000 },
    (_, index) => ({
      status:
        index % 2 === 0
          ? "healthy"
          : "unavailable"
    })
  );

  const startedAt = performance.now();

  const result = summarizeServices(services);

  const elapsedMilliseconds =
    performance.now() - startedAt;

  assert.deepEqual(result, {
    total: 10_000,
    healthy: 5_000
  });

  assert.ok(
    elapsedMilliseconds < 500,
    `operation took ${elapsedMilliseconds} ms`
  );
});
```

## Verification

Run:

```bash
node --test test/performance.test.js
```

Do not use extremely strict thresholds unless the test environment is controlled.

---

# 30. Test Organization

A useful testing structure is:

```text
test/
├── fixtures/
│   ├── services.js
│   └── recording-logger.js
├── service-selectors.test.js
├── state.test.js
├── reactive-state.test.js
├── metrics-service.test.js
├── http-client.test.js
├── retry.test.js
├── cancellation.test.js
├── cleanup.test.js
├── dashboard.integration.test.js
└── performance.test.js
```

Use `.test.js` or `.spec.js` consistently so the test runner discovers files predictably.

---

# 31. Common Testing Mistakes

## Mistake 1: Not Awaiting an Async Operation

Incorrect:

```js
test("operation succeeds", () => {
  operation().then((result) => {
    assert.equal(result, "success");
  });
});
```

The test may finish before the callback executes.

Correct:

```js
test("operation succeeds", async () => {
  const result = await operation();

  assert.equal(result, "success");
});
```

---

## Mistake 2: Testing Only the Happy Path

Add tests for:

- Invalid input.
- Dependency failures.
- Timeouts.
- Cancellation.
- Empty results.
- Boundary values.
- Cleanup.

---

## Mistake 3: Using Real Network Calls in Unit Tests

Real network calls cause slow and flaky tests.

Inject a fake client or fetch implementation.

---

## Mistake 4: Sharing Mutable Fixtures

Incorrect:

```js
const sharedService = {
  status: "healthy"
};
```

If one test changes it, another test sees the mutation.

Prefer a factory:

```js
function createService() {
  return {
    status: "healthy"
  };
}
```

---

## Mistake 5: Asserting Implementation Details

Avoid tests that require:

```js
assert.equal(internalLoopCount, 3);
```

Prefer observable behavior:

```js
assert.equal(result, "success");
```

Implementation-focused tests make refactoring unnecessarily expensive.

---

## Mistake 6: Forgetting Cleanup

Tests can hang or interfere with one another if they leave behind:

- Timers.
- Servers.
- Workers.
- Event listeners.
- Open files.
- Subscriptions.

Every created resource needs a cleanup path.

---

## Mistake 7: Testing Exact Timing

Avoid:

```js
assert.equal(elapsedMilliseconds, 20);
```

Timers are not exact.

Prefer injected clocks or broad behavior assertions.

---

# 32. Test Readiness Checklist

You are ready for the main series when you can:

- [ ] Create a test with `node:test`.
- [ ] Use `node:assert/strict`.
- [ ] Structure tests as Arrange, Act, Assert.
- [ ] Test synchronous return values.
- [ ] Test thrown errors.
- [ ] Test resolved promises.
- [ ] Test rejected promises.
- [ ] Test cancellation.
- [ ] Test immutable state transitions.
- [ ] Create fixtures.
- [ ] Inject dependencies.
- [ ] Replace network calls with fakes.
- [ ] Record logs without replacing global console methods.
- [ ] Test cleanup.
- [ ] Write an integration test.
- [ ] Run tests selectively.
- [ ] Run the complete suite.
- [ ] Interpret coverage appropriately.
- [ ] Avoid flaky timing assertions.

---

# 33. Complete Verification Commands

From the `primer-5` directory, run:

```bash
npm test
npm run test:coverage
```

Run focused test files:

```bash
node --test test/basic.test.js
node --test test/service-selectors.test.js
node --test test/async-success.test.js
node --test test/async-errors.test.js
node --test test/cancellation.test.js
node --test test/metrics-service.test.js
node --test test/http-client.test.js
node --test test/retry.test.js
node --test test/expiration.test.js
node --test test/cleanup.test.js
node --test test/dashboard.integration.test.js
node --test test/performance.test.js
```

Run filtered tests:

```bash
node --test --test-name-pattern="retry"
node --test --test-name-pattern="cancellation"
node --test --test-name-pattern="cleanup"
```

---

# 34. Primer Summary

A useful test architecture looks like this:

```text
pure function tests
        │
        ▼
module tests with injected dependencies
        │
        ▼
integration tests across real modules
        │
        ▼
end-to-end tests across the complete application
```

The most important testing habits are:

1. Test observable behavior.
2. Keep tests deterministic.
3. Test failure paths deliberately.
4. Await asynchronous work.
5. Inject clocks, randomness, network clients, and loggers.
6. Use fresh fixtures for each test.
7. Verify cleanup explicitly.
8. Avoid real network dependencies in unit tests.
9. Use integration tests to verify module boundaries.
10. Treat coverage as evidence, not proof.
11. Keep performance thresholds generous unless the environment is controlled.
12. Run the full suite before considering a change complete.
