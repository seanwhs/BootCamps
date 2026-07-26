# Part 5: Capstone — Runtime Monitor

In this capstone, we will combine the entire series into one runnable application.

We will build **Runtime Monitor**, a small dashboard that:

- Loads multiple services concurrently.
- Preserves partial results.
- Retries temporary failures.
- Uses exponential backoff.
- Protects dependencies with a circuit breaker.
- Supports request cancellation.
- Uses a timeout for each refresh.
- Maintains reactive browser state.
- Debounces search.
- Batches rendering.
- Exposes liveness and readiness endpoints.
- Handles graceful shutdown.
- Includes automated tests.

The completed architecture will be:

```text
Browser
  │
  ├── reactive state
  ├── debounced filtering
  └── batched rendering
  │
  ▼
Node.js HTTP server
  │
  ├── /live
  ├── /ready
  └── /api/dashboard
  │
  ▼
Application workflow
  │
  ├── cancellation
  ├── timeout
  ├── Promise.allSettled
  └── partial results
  │
  ▼
Resilient service layer
  │
  ├── retry
  ├── backoff
  └── circuit breaker
  │
  ▼
Simulated external services
```

---

# Part 5.1: Create the Project

## The Target

We will create the capstone project structure.

## The Concept

The project is divided into three main areas:

```text
server/
  Node.js application and resilience logic

public/
  Browser dashboard

test/
  Automated tests
```

The browser does not directly know how the simulated services work. It only communicates with the application API.

## Implementation

Run:

```bash
mkdir -p runtime-monitor-capstone/src
mkdir -p runtime-monitor-capstone/public
mkdir -p runtime-monitor-capstone/test
cd runtime-monitor-capstone
```

### `package.json`

```json
{
  "name": "runtime-monitor-capstone",
  "version": "1.0.0",
  "private": true,
  "description": "Advanced JavaScript Runtime Monitor capstone",
  "type": "module",
  "scripts": {
    "start": "node src/server.js",
    "dev": "node --watch src/server.js",
    "test": "node --test",
    "test:coverage": "node --experimental-test-coverage --test"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

Create the environment template:

### `.env.example`

```dotenv
PORT=3000
REQUEST_TIMEOUT_MS=1500
RETRY_MAX_ATTEMPTS=3
RETRY_BASE_DELAY_MS=50
CIRCUIT_FAILURE_THRESHOLD=3
CIRCUIT_RESET_TIMEOUT_MS=3000
```

### `.gitignore`

```gitignore
node_modules/
.env
coverage/
*.log
```

## Verification

Run:

```bash
node --version
npm test
```

The test command may report no tests yet. That is expected.

---

# Part 5.2: Application Errors

## The Target

We will create typed errors used by timeouts, cancellation, dependencies, and circuit breakers.

## The Concept

An error message is written for humans. An error type or code is written for application logic.

This is fragile:

```js
if (error.message.includes("timeout")) {
  // ...
}
```

This is more reliable:

```js
if (error.name === "TimeoutError") {
  // ...
}
```

## Implementation

### `src/errors.js`

```js
export class TimeoutError extends Error {
  constructor(message) {
    super(message);
    this.name = "TimeoutError";
    this.retryable = true;
  }
}

export class CancellationError extends Error {
  constructor(message = "operation cancelled") {
    super(message);
    this.name = "AbortError";
    this.retryable = false;
  }
}

export class DependencyError extends Error {
  constructor(message, options = {}) {
    super(message);
    this.name = "DependencyError";
    this.retryable = options.retryable ?? true;
    this.status = options.status;
  }
}

export class CircuitOpenError extends Error {
  constructor(message = "circuit breaker is open") {
    super(message);
    this.name = "CircuitOpenError";
    this.retryable = false;
  }
}

export function isCancellation(error) {
  return (
    error?.name === "AbortError" ||
    error instanceof CancellationError
  );
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import {
  TimeoutError,
  CircuitOpenError
} from "./src/errors.js";

console.log(new TimeoutError("request timed out"));
console.log(new CircuitOpenError());
EOF
```

Expected output includes:

```text
TimeoutError: request timed out
CircuitOpenError: circuit breaker is open
```

---

# Part 5.3: Retry with Backoff

## The Target

We will create the retry engine.

## The Concept

The retry engine should not decide whether every error is retryable. The caller provides that policy.

The engine owns:

- Attempt counting.
- Waiting.
- Backoff.
- Jitter.
- Cancellation.
- Retry callbacks.

## Implementation

### `src/retry.js`

```js
import { TimeoutError } from "./errors.js";

function calculateBackoffDelay({
  attempt,
  baseDelayMilliseconds,
  random
}) {
  const maximumDelay =
    baseDelayMilliseconds * 2 ** (attempt - 1);

  return Math.floor(
    random() * (maximumDelay + 1)
  );
}

function wait(milliseconds, signal) {
  if (signal.aborted) {
    return Promise.reject(
      signal.reason ?? new Error("operation aborted")
    );
  }

  return new Promise((resolve, reject) => {
    let settled = false;

    const timerId = setTimeout(() => {
      if (settled) {
        return;
      }

      settled = true;
      signal.removeEventListener(
        "abort",
        handleAbort
      );

      resolve();
    }, milliseconds);

    function handleAbort() {
      if (settled) {
        return;
      }

      settled = true;
      clearTimeout(timerId);

      signal.removeEventListener(
        "abort",
        handleAbort
      );

      reject(
        signal.reason ?? new Error("operation aborted")
      );
    }

    signal.addEventListener(
      "abort",
      handleAbort,
      { once: true }
    );
  });
}

export async function retry({
  operation,
  maximumAttempts,
  baseDelayMilliseconds,
  signal,
  isRetryable,
  random = Math.random,
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

  if (!(signal instanceof AbortSignal)) {
    throw new TypeError("signal must be an AbortSignal");
  }

  let lastError;

  for (
    let attempt = 1;
    attempt <= maximumAttempts;
    attempt += 1
  ) {
    if (signal.aborted) {
      throw (
        signal.reason ??
        new Error("operation aborted")
      );
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

      const attemptsRemain =
        attempt < maximumAttempts;

      if (
        !attemptsRemain ||
        !isRetryable(error)
      ) {
        throw error;
      }

      const delayMilliseconds =
        calculateBackoffDelay({
          attempt,
          baseDelayMilliseconds,
          random
        });

      onRetry({
        attempt,
        nextAttempt: attempt + 1,
        delayMilliseconds,
        error
      });

      await wait(
        delayMilliseconds,
        signal
      );
    }
  }

  throw (
    lastError ??
    new TimeoutError("retry operation failed")
  );
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { retry } from "./src/retry.js";

let attempts = 0;

const result = await retry({
  maximumAttempts: 3,
  baseDelayMilliseconds: 0,
  random: () => 0,
  signal: new AbortController().signal,
  isRetryable: (error) => error.retryable === true,
  operation: async () => {
    attempts += 1;

    if (attempts < 3) {
      const error = new Error("temporary failure");
      error.retryable = true;
      throw error;
    }

    return "success";
  }
});

console.log({ result, attempts });
EOF
```

Expected output:

```text
{ result: 'success', attempts: 3 }
```

---

# Part 5.4: Circuit Breaker

## The Target

We will create a circuit breaker.

## The Concept

The breaker protects a dependency that is repeatedly failing.

```text
CLOSED
  │ repeated failures
  ▼
OPEN
  │ cooldown
  ▼
HALF_OPEN
  │
  ├── success → CLOSED
  └── failure → OPEN
```

While open, calls fail immediately instead of contacting the unhealthy dependency.

## Implementation

### `src/circuit-breaker.js`

```js
import { CircuitOpenError } from "./errors.js";

export const CircuitState = Object.freeze({
  CLOSED: "CLOSED",
  OPEN: "OPEN",
  HALF_OPEN: "HALF_OPEN"
});

export function createCircuitBreaker({
  operation,
  failureThreshold,
  resetTimeoutMilliseconds,
  isFailure,
  now = () => Date.now(),
  onStateChange = () => {}
}) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  let state = CircuitState.CLOSED;
  let consecutiveFailures = 0;
  let openedAt = null;
  let probeInProgress = false;

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

  function canExecute() {
    if (state === CircuitState.CLOSED) {
      return true;
    }

    if (state === CircuitState.OPEN) {
      const elapsed =
        now() - openedAt;

      if (
        elapsed <
        resetTimeoutMilliseconds
      ) {
        return false;
      }

      transition(
        CircuitState.HALF_OPEN,
        "reset timeout elapsed"
      );
    }

    if (state === CircuitState.HALF_OPEN) {
      if (probeInProgress) {
        return false;
      }

      probeInProgress = true;
    }

    return true;
  }

  async function execute(...args) {
    if (!canExecute()) {
      throw new CircuitOpenError();
    }

    try {
      const result = await operation(...args);

      consecutiveFailures = 0;
      openedAt = null;
      probeInProgress = false;

      if (state === CircuitState.HALF_OPEN) {
        transition(
          CircuitState.CLOSED,
          "probe succeeded"
        );
      }

      return result;
    } catch (error) {
      probeInProgress = false;

      if (isFailure(error)) {
        consecutiveFailures += 1;

        if (
          state === CircuitState.HALF_OPEN ||
          consecutiveFailures >= failureThreshold
        ) {
          openedAt = now();

          transition(
            CircuitState.OPEN,
            "failure threshold reached"
          );
        }
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
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import {
  createCircuitBreaker
} from "./src/circuit-breaker.js";

let calls = 0;

const breaker = createCircuitBreaker({
  failureThreshold: 2,
  resetTimeoutMilliseconds: 1000,
  isFailure: () => true,
  operation: async () => {
    calls += 1;
    throw new Error("dependency failed");
  }
});

for (let index = 0; index < 3; index += 1) {
  try {
    await breaker.execute();
  } catch (error) {
    console.log(error.name);
  }
}

console.log({
  state: breaker.getState(),
  calls
});
EOF
```

Expected output:

```text
Error
Error
CircuitOpenError
{ state: 'OPEN', calls: 2 }
```

---

# Part 5.5: Simulated External Services

## The Target

We will create deterministic fake services.

## The Concept

The capstone should be runnable without external APIs.

Each fake service can:

- Wait for a configured duration.
- Fail a configured number of times.
- Return a result.
- Respect cancellation.

## Implementation

### `src/fake-service.js`

```js
import {
  DependencyError
} from "./errors.js";

export function createFakeService({
  name,
  delayMilliseconds,
  result,
  failuresBeforeSuccess = 0
}) {
  let remainingFailures =
    failuresBeforeSuccess;

  async function load(signal) {
    if (signal.aborted) {
      throw (
        signal.reason ??
        new Error("operation aborted")
      );
    }

    await new Promise((resolve, reject) => {
      const timerId = setTimeout(
        resolve,
        delayMilliseconds
      );

      function handleAbort() {
        clearTimeout(timerId);

        signal.removeEventListener(
          "abort",
          handleAbort
        );

        reject(
          signal.reason ??
          new Error("operation aborted")
        );
      }

      signal.addEventListener(
        "abort",
        handleAbort,
        { once: true }
      );

      /*
       * Remove the listener when the normal timer completes. This prevents a
       * completed operation from retaining the signal listener.
       */
      setTimeout(() => {
        signal.removeEventListener(
          "abort",
          handleAbort
        );
      }, delayMilliseconds);
    });

    if (remainingFailures > 0) {
      remainingFailures -= 1;

      throw new DependencyError(
        `${name} temporary failure`,
        {
          retryable: true,
          status: 503
        }
      );
    }

    return {
      name,
      ...result,
      loadedAt: new Date().toISOString()
    };
  }

  return Object.freeze({
    name,
    load
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createFakeService } from "./src/fake-service.js";

const service = createFakeService({
  name: "metrics",
  delayMilliseconds: 10,
  result: {
    requestsPerSecond: 125
  }
});

console.log(
  await service.load(
    new AbortController().signal
  )
);
EOF
```

Expected output includes:

```text
{
  name: 'metrics',
  requestsPerSecond: 125,
  loadedAt: '...'
}
```

---

# Part 5.6: Service Registry

## The Target

We will define the three simulated services.

## Implementation

### `src/services.js`

```js
import { createFakeService } from "./fake-service.js";

export function createServices() {
  return {
    metrics: createFakeService({
      name: "metrics",
      delayMilliseconds: 180,
      failuresBeforeSuccess: 1,
      result: {
        requestsPerSecond: 125,
        errorRate: 0.01
      }
    }),

    health: createFakeService({
      name: "health",
      delayMilliseconds: 90,
      result: {
        status: "healthy",
        uptimeSeconds: 86_400
      }
    }),

    activity: createFakeService({
      name: "activity",
      delayMilliseconds: 240,
      result: {
        activeUsers: 42,
        eventsPerMinute: 310
      }
    })
  };
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createServices } from "./src/services.js";

const services = createServices();

console.log(Object.keys(services));
EOF
```

Expected output:

```text
[ 'metrics', 'health', 'activity' ]
```

---

# Part 5.7: Resilient Service Wrapper

## The Target

We will combine retry and circuit-breaking behavior around each fake service.

## The Concept

The service wrapper provides one consistent interface:

```js
service.load(signal)
```

Internally it applies:

```text
circuit breaker
      │
      ▼
retry policy
      │
      ▼
fake dependency
```

## Implementation

### `src/resilient-service.js`

```js
import {
  createCircuitBreaker
} from "./circuit-breaker.js";

import { retry } from "./retry.js";

export function createResilientService({
  service,
  retryMaximumAttempts,
  retryBaseDelayMilliseconds,
  circuitFailureThreshold,
  circuitResetTimeoutMilliseconds,
  logger = console
}) {
  const breaker = createCircuitBreaker({
    failureThreshold:
      circuitFailureThreshold,

    resetTimeoutMilliseconds:
      circuitResetTimeoutMilliseconds,

    isFailure: (error) =>
      error?.retryable === true,

    onStateChange: (change) => {
      logger.info("circuit state changed", {
        service: service.name,
        ...change
      });
    },

    operation: async (signal) => {
      return retry({
        maximumAttempts:
          retryMaximumAttempts,

        baseDelayMilliseconds:
          retryBaseDelayMilliseconds,

        signal,

        isRetryable: (error) =>
          error?.retryable === true,

        operation: ({ signal: retrySignal, attempt }) => {
          logger.info("service attempt", {
            service: service.name,
            attempt
          });

          return service.load(retrySignal);
        },

        onRetry: (retryInfo) => {
          logger.info("service retry", {
            service: service.name,
            ...retryInfo
          });
        }
      });
    }
  });

  return Object.freeze({
    load(signal) {
      return breaker.execute(signal);
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
import { createServices } from "./src/services.js";
import { createResilientService } from "./src/resilient-service.js";

const [service] = Object.values(createServices());

const resilient = createResilientService({
  service,
  retryMaximumAttempts: 3,
  retryBaseDelayMilliseconds: 0,
  circuitFailureThreshold: 3,
  circuitResetTimeoutMilliseconds: 1000
});

console.log(
  await resilient.load(
    new AbortController().signal
  )
);
EOF
```

The metrics service should fail once, retry, and then succeed.

---

# Part 5.8: Dashboard Workflow

## The Target

We will load all services concurrently and preserve partial results.

## The Concept

The dashboard should not fail completely if one optional panel fails.

Each result is converted into a UI-safe object:

```js
{
  status: "available",
  data: ...
}
```

or:

```js
{
  status: "unavailable",
  error: ...
}
```

## Implementation

### `src/dashboard-workflow.js`

```js
import {
  TimeoutError,
  isCancellation
} from "./errors.js";

function createTimeoutController(
  parentSignal,
  timeoutMilliseconds
) {
  const controller = new AbortController();

  let timeoutId;

  const abortFromParent = () => {
    controller.abort(
      parentSignal.reason ??
      new Error("parent operation aborted")
    );
  };

  if (parentSignal.aborted) {
    abortFromParent();
  } else {
    parentSignal.addEventListener(
      "abort",
      abortFromParent,
      { once: true }
    );
  }

  timeoutId = setTimeout(() => {
    controller.abort(
      new TimeoutError(
        `service timed out after ${timeoutMilliseconds} ms`
      )
    );
  }, timeoutMilliseconds);

  return {
    signal: controller.signal,

    cleanup() {
      clearTimeout(timeoutId);

      parentSignal.removeEventListener(
        "abort",
        abortFromParent
      );
    }
  };
}

function classifyFailure(error) {
  if (isCancellation(error)) {
    return {
      status: "cancelled",
      error: error.message
    };
  }

  if (error.name === "TimeoutError") {
    return {
      status: "timeout",
      error: error.message
    };
  }

  return {
    status: "unavailable",
    error: error.message
  };
}

export async function loadDashboard({
  services,
  signal,
  timeoutMilliseconds,
  logger = console
}) {
  const entries = Object.entries(services);

  const settledResults = await Promise.allSettled(
    entries.map(async ([name, service]) => {
      const scopedController =
        createTimeoutController(
          signal,
          timeoutMilliseconds
        );

      try {
        const data = await service.load(
          scopedController.signal
        );

        return {
          name,
          panel: {
            status: "available",
            data
          }
        };
      } finally {
        scopedController.cleanup();
      }
    })
  );

  const dashboard = Object.fromEntries(
    settledResults.map((result, index) => {
      const name = entries[index][0];

      if (result.status === "fulfilled") {
        return [
          name,
          result.value.panel
        ];
      }

      const failure = classifyFailure(
        result.reason
      );

      logger.error("dashboard panel failed", {
        service: name,
        ...failure
      });

      return [name, failure];
    })
  );

  return dashboard;
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createServices } from "./src/services.js";
import { createResilientService } from "./src/resilient-service.js";
import { loadDashboard } from "./src/dashboard-workflow.js";

const rawServices = createServices();

const services = Object.fromEntries(
  Object.entries(rawServices).map(
    ([name, service]) => [
      name,
      createResilientService({
        service,
        retryMaximumAttempts: 3,
        retryBaseDelayMilliseconds: 0,
        circuitFailureThreshold: 3,
        circuitResetTimeoutMilliseconds: 1000
      })
    ]
  )
);

const dashboard = await loadDashboard({
  services,
  signal: new AbortController().signal,
  timeoutMilliseconds: 500
});

console.dir(dashboard, { depth: null });
EOF
```

Expected output includes available panels.

---

# Part 5.9: Application State

## The Target

We will create a small server-side state store for the latest dashboard snapshot.

## The Concept

The server does not need a full reactive proxy for this state. An immutable replacement store is sufficient.

## Implementation

### `src/application-state.js`

```js
export function createApplicationState() {
  let currentState = {
    status: "idle",
    isRefreshing: false,
    lastUpdated: null,
    services: {},
    error: null
  };

  const subscribers = new Set();

  function notify(previousState, action) {
    for (const subscriber of subscribers) {
      try {
        subscriber(
          currentState,
          previousState,
          action
        );
      } catch (error) {
        console.error(
          "state subscriber failed:",
          error
        );
      }
    }
  }

  function update(updater, action) {
    const previousState = currentState;
    currentState = updater(currentState);

    notify(previousState, action);
  }

  return Object.freeze({
    getState() {
      return currentState;
    },

    subscribe(subscriber) {
      subscribers.add(subscriber);

      return () => {
        subscribers.delete(subscriber);
      };
    },

    refreshStarted() {
      update(
        (state) => ({
          ...state,
          status: "loading",
          isRefreshing: true,
          error: null
        }),
        {
          type: "REFRESH_STARTED"
        }
      );
    },

    refreshFinished(services) {
      update(
        (state) => ({
          ...state,
          status: "ready",
          isRefreshing: false,
          lastUpdated: new Date().toISOString(),
          services,
          error: null
        }),
        {
          type: "REFRESH_FINISHED"
        }
      );
    },

    refreshFailed(error) {
      update(
        (state) => ({
          ...state,
          status: "failed",
          isRefreshing: false,
          error: error.message
        }),
        {
          type: "REFRESH_FAILED"
        }
      );
    }
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createApplicationState } from "./src/application-state.js";

const state = createApplicationState();

const unsubscribe = state.subscribe(
  (nextState, previousState, action) => {
    console.log(action.type);
    console.log(previousState !== nextState);
  }
);

state.refreshStarted();
state.refreshFinished({
  metrics: {
    status: "available"
  }
});

unsubscribe();

console.log(state.getState());
EOF
```

---

# Part 5.10: Server Configuration

## The Target

We will create validated application configuration.

## Implementation

### `src/configuration.js`

```js
function positiveInteger(
  value,
  fallback,
  name
) {
  const selected =
    value === undefined
      ? fallback
      : Number(value);

  if (
    !Number.isInteger(selected) ||
    selected <= 0
  ) {
    throw new Error(
      `${name} must be a positive integer`
    );
  }

  return selected;
}

export function loadConfiguration(
  environment = process.env
) {
  return Object.freeze({
    port: positiveInteger(
      environment.PORT,
      3000,
      "PORT"
    ),

    requestTimeoutMilliseconds:
      positiveInteger(
        environment.REQUEST_TIMEOUT_MS,
        500,
        "REQUEST_TIMEOUT_MS"
      ),

    retryMaximumAttempts:
      positiveInteger(
        environment.RETRY_MAX_ATTEMPTS,
        3,
        "RETRY_MAX_ATTEMPTS"
      ),

    retryBaseDelayMilliseconds:
      positiveInteger(
        environment.RETRY_BASE_DELAY_MS,
        50,
        "RETRY_BASE_DELAY_MS"
      ),

    circuitFailureThreshold:
      positiveInteger(
        environment.CIRCUIT_FAILURE_THRESHOLD,
        3,
        "CIRCUIT_FAILURE_THRESHOLD"
      ),

    circuitResetTimeoutMilliseconds:
      positiveInteger(
        environment.CIRCUIT_RESET_TIMEOUT_MS,
        3_000,
        "CIRCUIT_RESET_TIMEOUT_MS"
      )
  });
}
```

## Verification

Run:

```bash
PORT=4000 REQUEST_TIMEOUT_MS=1000 node --input-type=module <<'EOF'
import { loadConfiguration } from "./src/configuration.js";

console.log(loadConfiguration());
EOF
```

Expected output includes:

```text
{
  port: 4000,
  requestTimeoutMilliseconds: 1000,
  ...
}
```

---

# Part 5.11: HTTP Server

## The Target

We will create the server that exposes:

```text
GET /live
GET /ready
GET /api/dashboard
```

## The Concept

The server is an adapter. It translates HTTP requests into application operations and application results into HTTP responses.

## Implementation

### `src/server.js`

```js
import http from "node:http";

import { loadConfiguration } from "./configuration.js";
import { createApplicationState } from "./application-state.js";
import { createServices } from "./services.js";
import { createResilientService } from "./resilient-service.js";
import { loadDashboard } from "./dashboard-workflow.js";

const configuration = loadConfiguration();
const state = createApplicationState();
const rawServices = createServices();

const services = Object.fromEntries(
  Object.entries(rawServices).map(
    ([name, service]) => [
      name,
      createResilientService({
        service,
        retryMaximumAttempts:
          configuration.retryMaximumAttempts,
        retryBaseDelayMilliseconds:
          configuration.retryBaseDelayMilliseconds,
        circuitFailureThreshold:
          configuration.circuitFailureThreshold,
        circuitResetTimeoutMilliseconds:
          configuration.circuitResetTimeoutMilliseconds
      })
    ]
  )
);

let shuttingDown = false;
let activeRefreshController = null;

function sendJson(
  response,
  statusCode,
  body
) {
  response.writeHead(statusCode, {
    "content-type":
      "application/json; charset=utf-8",
    "cache-control": "no-store"
  });

  response.end(JSON.stringify(body));
}

function requestUrl(request) {
  return new URL(
    request.url ?? "/",
    `http://${request.headers.host ?? "localhost"}`
  );
}

async function refreshDashboard() {
  if (activeRefreshController) {
    activeRefreshController.abort(
      new Error("refresh superseded")
    );
  }

  const controller = new AbortController();
  activeRefreshController = controller;

  state.refreshStarted();

  try {
    const dashboard = await loadDashboard({
      services,
      signal: controller.signal,
      timeoutMilliseconds:
        configuration.requestTimeoutMilliseconds
    });

    if (controller.signal.aborted) {
      return;
    }

    state.refreshFinished(dashboard);

    return dashboard;
  } catch (error) {
    if (error.name === "AbortError") {
      return;
    }

    state.refreshFailed(error);
    throw error;
  } finally {
    if (
      activeRefreshController === controller
    ) {
      activeRefreshController = null;
    }
  }
}

const server = http.createServer(
  async (request, response) => {
    const url = requestUrl(request);

    if (
      request.method === "GET" &&
      url.pathname === "/live"
    ) {
      sendJson(response, 200, {
        status: "alive"
      });

      return;
    }

    if (
      request.method === "GET" &&
      url.pathname === "/ready"
    ) {
      sendJson(
        response,
        shuttingDown ? 503 : 200,
        {
          status: shuttingDown
            ? "not-ready"
            : "ready"
        }
      );

      return;
    }

    if (
      request.method === "GET" &&
      url.pathname === "/api/dashboard"
    ) {
      if (shuttingDown) {
        sendJson(response, 503, {
          error: {
            code: "SHUTTING_DOWN",
            message: "server is shutting down"
          }
        });

        return;
      }

      try {
        const dashboard =
          await refreshDashboard();

        sendJson(response, 200, {
          status: state.getState().status,
          lastUpdated:
            state.getState().lastUpdated,
          services: dashboard
        });
      } catch (error) {
        console.error(
          "dashboard request failed:",
          error
        );

        sendJson(response, 500, {
          error: {
            code: "DASHBOARD_FAILED",
            message: "dashboard refresh failed"
          }
        });
      }

      return;
    }

    sendJson(response, 404, {
      error: {
        code: "NOT_FOUND",
        message: "route not found"
      }
    });
  }
);

server.listen(configuration.port, () => {
  console.log(
    `Runtime Monitor listening on port ${configuration.port}`
  );
});

let shutdownStarted = false;

function shutdown(signal) {
  if (shutdownStarted) {
    return;
  }

  shutdownStarted = true;
  shuttingDown = true;

  console.log(`received ${signal}`);

  if (activeRefreshController) {
    activeRefreshController.abort(
      new Error("application shutting down")
    );
  }

  server.close((error) => {
    if (error) {
      console.error(
        "server shutdown failed:",
        error
      );

      process.exitCode = 1;
      return;
    }

    console.log("server closed");
  });
}

process.on("SIGINT", () => {
  shutdown("SIGINT");
});

process.on("SIGTERM", () => {
  shutdown("SIGTERM");
});
```

## Verification

Start the server:

```bash
npm start
```

In another terminal:

```bash
curl -i http://localhost:3000/live
curl -i http://localhost:3000/ready
curl -i http://localhost:3000/api/dashboard
```

Expected dashboard response resembles:

```json
{
  "status": "ready",
  "lastUpdated": "2026-...",
  "services": {
    "metrics": {
      "status": "available",
      "data": {
        "name": "metrics",
        "requestsPerSecond": 125,
        "errorRate": 0.01,
        "loadedAt": "2026-..."
      }
    },
    "health": {
      "status": "available",
      "data": {
        "name": "health",
        "status": "healthy",
        "uptimeSeconds": 86400,
        "loadedAt": "2026-..."
      }
    },
    "activity": {
      "status": "available",
      "data": {
        "name": "activity",
        "activeUsers": 42,
        "eventsPerMinute": 310,
        "loadedAt": "2026-..."
      }
    }
  }
}
```

The first metrics attempt should fail and then succeed through retry.

Stop the server:

```text
Ctrl+C
```

Expected output:

```text
received SIGINT
server closed
```

---

# Part 5.12: Browser HTML

## The Target

We will create the dashboard page.

## Implementation

### `public/index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    >
    <title>Runtime Monitor</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 2rem;
      }

      button,
      input {
        font: inherit;
        padding: 0.5rem;
      }

      .toolbar {
        display: flex;
        gap: 0.75rem;
        margin-bottom: 1.5rem;
      }

      .service-grid {
        display: grid;
        gap: 1rem;
        grid-template-columns: repeat(
          auto-fit,
          minmax(220px, 1fr)
        );
      }

      .service-card {
        border: 1px solid black;
        padding: 1rem;
      }

      .muted {
        color: #555;
      }

      .error {
        border: 1px solid black;
        padding: 1rem;
      }

      [hidden] {
        display: none !important;
      }
    </style>
  </head>
  <body>
    <main>
      <h1>Runtime Monitor</h1>

      <div class="toolbar">
        <button
          id="refresh-button"
          type="button"
        >
          Refresh
        </button>

        <label>
          Filter services
          <input
            id="filter-input"
            type="search"
            autocomplete="off"
          >
        </label>
      </div>

      <p id="status" class="muted">
        Waiting for dashboard data.
      </p>

      <div
        id="error"
        class="error"
        hidden
      ></div>

      <section
        id="services"
        class="service-grid"
        aria-live="polite"
      ></section>
    </main>

    <script
      type="module"
      src="./app.js"
    ></script>
  </body>
</html>
```

## Verification

The server currently serves only API routes. We will add static-file handling next.

---

# Part 5.13: Static File Serving

## The Target

We will serve files from `public/`.

## The Concept

The server needs to translate:

```text
GET /
```

into:

```text
public/index.html
```

It must also prevent path traversal.

## Implementation

Create:

### `src/static-files.js`

```js
import path from "node:path";
import {
  readFile
} from "node:fs/promises";

const MIME_TYPES = Object.freeze({
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8"
});

export async function readPublicFile(
  publicDirectory,
  requestPath
) {
  const decodedPath =
    decodeURIComponent(requestPath);

  const normalizedPath =
    decodedPath === "/"
      ? "/index.html"
      : decodedPath;

  const root = path.resolve(publicDirectory);
  const filePath = path.resolve(
    root,
    `.${normalizedPath}`
  );

  const relative = path.relative(
    root,
    filePath
  );

  const escapesRoot =
    relative === ".." ||
    relative.startsWith(`..${path.sep}`) ||
    path.isAbsolute(relative);

  if (escapesRoot) {
    const error = new Error(
      "requested path escapes public directory"
    );

    error.code = "PATH_TRAVERSAL";
    throw error;
  }

  const contents = await readFile(filePath);
  const extension = path.extname(filePath);

  return {
    contents,
    contentType:
      MIME_TYPES[extension] ??
      "application/octet-stream"
  };
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { readPublicFile } from "./src/static-files.js";

const file = await readPublicFile(
  "./public",
  "/index.html"
);

console.log(file.contentType);
console.log(file.contents.length > 0);
EOF
```

Expected output:

```text
text/html; charset=utf-8
true
```

---

# Part 5.14: Update the Server for Static Files

## The Target

We will serve the browser dashboard from the same Node.js process.

## Implementation

Add these imports at the top of `src/server.js`:

```js
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  readPublicFile
} from "./static-files.js";
```

Add these constants after configuration:

```js
const currentFilePath = fileURLToPath(
  import.meta.url
);

const currentDirectory = path.dirname(
  currentFilePath
);

const publicDirectory = path.join(
  currentDirectory,
  "..",
  "public"
);
```

Before the final 404 response, add:

```js
    if (request.method === "GET") {
      try {
        const file = await readPublicFile(
          publicDirectory,
          url.pathname
        );

        response.writeHead(200, {
          "content-type": file.contentType,
          "cache-control": "no-store"
        });

        response.end(file.contents);
        return;
      } catch (error) {
        if (error.code === "ENOENT") {
          sendJson(response, 404, {
            error: {
              code: "NOT_FOUND",
              message: "file not found"
            }
          });

          return;
        }

        console.error(
          "static file failure:",
          error
        );

        sendJson(response, 500, {
          error: {
            code: "STATIC_FILE_FAILED",
            message: "static file could not be served"
          }
        });

        return;
      }
    }
```

The final order inside the request handler should be:

```text
/live
/ready
/api/dashboard
static files
404
```

## Verification

Start the server:

```bash
npm start
```

Open in a browser:

```text
http://localhost:3000
```

You should see the Runtime Monitor page.

---

# Part 5.15: Browser Reactive State

## The Target

We will create a small browser-side reactive state store.

## The Concept

The browser state should notify the renderer when it changes.

The renderer should not be called manually after every assignment. State changes become the source of truth.

## Implementation

### `public/reactive-state.js`

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

      if (!didSet) {
        return false;
      }

      for (const subscriber of subscribers) {
        try {
          subscriber({
            property,
            previousValue,
            nextValue: value,
            state
          });
        } catch (error) {
          console.error(
            "state subscriber failed:",
            error
          );
        }
      }

      return true;
    }
  });

  return state;
}
```

## Verification

The browser will verify this when `app.js` subscribes and renders state changes.

---

# Part 5.16: Browser Dashboard Application

## The Target

We will connect:

- Fetch.
- AbortController.
- Reactive state.
- Debounce.
- Batched rendering.
- DOM updates.

## The Concept

The browser application owns the current refresh controller.

When a new refresh starts:

1. Abort the old refresh.
2. Create a new controller.
3. Fetch the dashboard.
4. Update state.
5. Render the latest state.

## Implementation

### `public/app.js`

```js
import {
  createReactiveState
} from "./reactive-state.js";

const refreshButton =
  document.querySelector("#refresh-button");

const filterInput =
  document.querySelector("#filter-input");

const statusElement =
  document.querySelector("#status");

const errorElement =
  document.querySelector("#error");

const servicesElement =
  document.querySelector("#services");

if (
  !refreshButton ||
  !filterInput ||
  !statusElement ||
  !errorElement ||
  !servicesElement
) {
  throw new Error(
    "dashboard markup is incomplete"
  );
}

const state = createReactiveState({
  status: "idle",
  services: {},
  lastUpdated: null,
  error: null,
  filter: "",
  isLoading: false
});

let activeController = null;
let renderScheduled = false;

function scheduleRender() {
  if (renderScheduled) {
    return;
  }

  renderScheduled = true;

  queueMicrotask(() => {
    renderScheduled = false;
    render();
  });
}

function createElement(
  tagName,
  text
) {
  const element =
    document.createElement(tagName);

  element.textContent = text;

  return element;
}

function render() {
  statusElement.textContent =
    state.isLoading
      ? "Refreshing dashboard..."
      : `Status: ${state.status}` +
        (
          state.lastUpdated
            ? ` — Updated ${state.lastUpdated}`
            : ""
        );

  errorElement.hidden = !state.error;
  errorElement.textContent =
    state.error ?? "";

  servicesElement.replaceChildren();

  const normalizedFilter =
    state.filter.trim().toLowerCase();

  const services = Object.entries(
    state.services
  ).filter(([name]) => {
    return name
      .toLowerCase()
      .includes(normalizedFilter);
  });

  if (services.length === 0) {
    servicesElement.append(
      createElement(
        "p",
        "No matching services."
      )
    );

    return;
  }

  for (const [name, service] of services) {
    const card =
      document.createElement("article");

    card.className = "service-card";

    const heading =
      createElement("h2", name);

    const status =
      createElement(
        "p",
        `Status: ${service.status}`
      );

    card.append(heading, status);

    if (service.data) {
      const data =
        createElement(
          "pre",
          JSON.stringify(
            service.data,
            null,
            2
          )
        );

      card.append(data);
    }

    if (service.error) {
      const error =
        createElement(
          "p",
          `Error: ${service.error}`
        );

      card.append(error);
    }

    servicesElement.append(card);
  }
}

function subscribeToRendering() {
  state.subscribe(() => {
    scheduleRender();
  });
}

async function refreshDashboard() {
  if (activeController) {
    activeController.abort(
      new Error("refresh superseded")
    );
  }

  const controller = new AbortController();
  activeController = controller;

  state.isLoading = true;
  state.error = null;

  try {
    const response = await fetch(
      "/api/dashboard",
      {
        signal: controller.signal
      }
    );

    if (!response.ok) {
      throw new Error(
        `dashboard request failed with status ${response.status}`
      );
    }

    const dashboard =
      await response.json();

    if (controller.signal.aborted) {
      return;
    }

    state.status = dashboard.status;
    state.services = dashboard.services;
    state.lastUpdated =
      dashboard.lastUpdated;
  } catch (error) {
    if (
      error.name === "AbortError" ||
      controller.signal.aborted
    ) {
      return;
    }

    state.status = "failed";
    state.error = error.message;
  } finally {
    if (
      activeController === controller
    ) {
      activeController = null;
      state.isLoading = false;
    }
  }
}

let filterTimer = null;

function handleFilterInput(event) {
  const value = event.target.value;

  if (filterTimer !== null) {
    clearTimeout(filterTimer);
  }

  filterTimer = setTimeout(() => {
    state.filter = value;
    filterTimer = null;
  }, 250);
}

refreshButton.addEventListener(
  "click",
  () => {
    void refreshDashboard();
  }
);

filterInput.addEventListener(
  "input",
  handleFilterInput
);

subscribeToRendering();
render();
void refreshDashboard();
```

## Verification

Open:

```text
http://localhost:3000
```

Verify:

- [ ] Dashboard loads automatically.
- [ ] Services appear as cards.
- [ ] Refresh starts a new request.
- [ ] Typing filters service cards.
- [ ] Filtering is delayed by 250 milliseconds.
- [ ] Errors are displayed in the error area.

---

# Part 5.17: Capstone Tests

## The Target

We will test the retry engine and dashboard workflow.

## Implementation

### `test/retry.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import { retry } from "../src/retry.js";

test("retry succeeds after a temporary failure", async () => {
  let attempts = 0;

  const result = await retry({
    maximumAttempts: 3,
    baseDelayMilliseconds: 0,
    random: () => 0,
    signal: new AbortController().signal,
    isRetryable: (error) =>
      error.retryable === true,
    operation: async () => {
      attempts += 1;

      if (attempts === 1) {
        const error = new Error("temporary");
        error.retryable = true;
        throw error;
      }

      return "success";
    }
  });

  assert.equal(result, "success");
  assert.equal(attempts, 2);
});

test("retry does not retry a permanent error", async () => {
  let attempts = 0;

  await assert.rejects(
    retry({
      maximumAttempts: 3,
      baseDelayMilliseconds: 0,
      signal: new AbortController().signal,
      isRetryable: () => false,
      operation: async () => {
        attempts += 1;
        throw new Error("permanent");
      }
    }),
    {
      message: "permanent"
    }
  );

  assert.equal(attempts, 1);
});

test("retry responds to cancellation", async () => {
  const controller = new AbortController();

  const operation = retry({
    maximumAttempts: 5,
    baseDelayMilliseconds: 1000,
    signal: controller.signal,
    isRetryable: () => true,
    operation: async () => {
      const error = new Error("temporary");
      error.retryable = true;
      throw error;
    }
  });

  controller.abort();

  await assert.rejects(operation);
});
```

### `test/circuit-breaker.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  CircuitState,
  createCircuitBreaker
} from "../src/circuit-breaker.js";

test("breaker opens after threshold failures", async () => {
  let calls = 0;

  const breaker = createCircuitBreaker({
    failureThreshold: 2,
    resetTimeoutMilliseconds: 1000,
    isFailure: () => true,
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
```

## Verification

Run:

```bash
npm test
```

Expected output indicates all tests passed.

---

# Part 5.18: End-to-End Verification

## The Target

We will verify the complete application as a user would.

## Step 1: Start the Server

```bash
npm start
```

## Step 2: Verify Liveness

```bash
curl -i http://localhost:3000/live
```

Expected:

```http
HTTP/1.1 200 OK
```

Response:

```json
{
  "status": "alive"
}
```

## Step 3: Verify Readiness

```bash
curl -i http://localhost:3000/ready
```

Expected:

```json
{
  "status": "ready"
}
```

## Step 4: Request the Dashboard

```bash
curl -i http://localhost:3000/api/dashboard
```

Expected:

- HTTP 200.
- A `services` object.
- Each service has a status.
- Metrics may log one retry before succeeding.

## Step 5: Open the Browser

Navigate to:

```text
http://localhost:3000
```

Verify:

- [ ] The page loads.
- [ ] The dashboard refreshes automatically.
- [ ] Service cards appear.
- [ ] The filter works.
- [ ] The Refresh button works.

## Step 6: Stop Gracefully

Press:

```text
Ctrl+C
```

Expected server output:

```text
received SIGINT
server closed
```

---

# Part 5.19: Failure Scenario Verification

## Scenario A: Temporary Failure

The metrics service is configured with:

```js
failuresBeforeSuccess: 1
```

Expected behavior:

```text
attempt 1 → failure
retry
attempt 2 → success
```

Verify server logs contain:

```text
service attempt
service retry
service attempt
```

---

## Scenario B: Timeout

Change activity delay:

### `src/services.js`

```js
activity: createFakeService({
  name: "activity",
  delayMilliseconds: 2_000,
  result: {
    activeUsers: 42,
    eventsPerMinute: 310
  }
})
```

Keep the timeout at 500 milliseconds:

```bash
REQUEST_TIMEOUT_MS=500 npm start
```

Expected activity result:

```json
{
  "status": "timeout"
}
```

Restore the delay after testing:

```js
delayMilliseconds: 240
```

---

## Scenario C: Cancellation

Make two browser refreshes quickly:

1. Click Refresh.
2. Immediately click Refresh again.

Expected behavior:

- The first request is aborted.
- The second request remains current.
- Older data does not overwrite newer data.

---

## Scenario D: Circuit Breaker

Configure a service to fail repeatedly:

### `src/services.js`

```js
health: createFakeService({
  name: "health",
  delayMilliseconds: 90,
  failuresBeforeSuccess: 100,
  result: {
    status: "healthy",
    uptimeSeconds: 86400
  }
})
```

Set:

```bash
CIRCUIT_FAILURE_THRESHOLD=3 npm start
```

Repeatedly request:

```bash
curl http://localhost:3000/api/dashboard
```

Expected behavior:

- Health fails.
- After the threshold, its circuit opens.
- Further calls fail quickly.
- After the reset timeout, a probe is attempted.

Restore:

```js
failuresBeforeSuccess: 0
```

---

# Part 5.20: Capstone Architecture Review

Complete the following table.

| Layer | Responsibility | Does not own |
|---|---|---|
| Browser UI | | |
| Reactive state | | |
| Dashboard workflow | | |
| Retry policy | | |
| Circuit breaker | | |
| Fake service | | |
| HTTP server | | |
| Shutdown logic | | |

---

# Part 5.21: Capstone Quality Review

## Correctness

- [ ] All services are requested concurrently.
- [ ] Partial results are preserved.
- [ ] Response shape is consistent.
- [ ] Invalid configuration fails clearly.
- [ ] Error messages do not expose internal details.

## Asynchronous Control

- [ ] Refreshes can be cancelled.
- [ ] Timeouts abort underlying operations.
- [ ] Retry delays are cancellable.
- [ ] No overlapping obsolete refresh corrupts state.

## Memory

- [ ] Abort listeners are removed.
- [ ] Timers are cleared.
- [ ] Browser subscriptions can be removed.
- [ ] No unbounded collection grows during refresh.

## Performance

- [ ] Independent services run concurrently.
- [ ] Browser rendering is batched.
- [ ] Filtering is debounced.
- [ ] Service cards are not rendered unnecessarily.

## Resilience

- [ ] Temporary failures retry.
- [ ] Permanent failures stop.
- [ ] Circuit breakers open after repeated failures.
- [ ] Partial dashboard data remains available.
- [ ] Timeouts are visible in service state.

## Operations

- [ ] `/live` exists.
- [ ] `/ready` exists.
- [ ] Shutdown handles SIGINT.
- [ ] Shutdown handles SIGTERM.
- [ ] Logs identify service attempts.
- [ ] Tests run with `npm test`.

---

# Part 5.22: Extension Exercises

## Extension 1: Add a Notifications Service

Add:

```js
notifications: {
  status: "available",
  data: {
    unread: 3
  }
}
```

Requirements:

- Add a fake dependency.
- Add it to the resilient-service map.
- Render it in the browser.
- Add a test.

---

## Extension 2: Add a Manual Failure Toggle

Add a query parameter:

```text
/api/dashboard?fail=activity
```

When present, force the activity service to fail.

---

## Extension 3: Add Stale Data

Store the previous successful service result.

When the next refresh fails, return:

```json
{
  "status": "stale",
  "data": {},
  "loadedAt": "..."
}
```

Display:

```text
Showing stale data.
```

---

## Extension 4: Add Metrics

Track:

```text
requests started
requests succeeded
requests failed
retries
timeouts
cancellations
circuit opens
```

Expose:

```text
GET /api/metrics
```

---

## Extension 5: Add Server-Side Debounce

Prevent duplicate refreshes from arriving within a short interval.

Requirements:

- Return the current refresh promise when a refresh is already active.
- Do not start duplicate dependency requests.
- Preserve the same result for concurrent callers.

---

## Extension 6: Add Request IDs

Generate a request identifier per dashboard request.

Log:

```json
{
  "requestId": "request-123",
  "service": "metrics",
  "attempt": 2
}
```

Return the identifier in the response header:

```http
X-Request-ID: request-123
```

---

# Part 5.23: Final Capstone Commands

Run the complete sequence:

```bash
npm test
npm run test:coverage
npm start
```

In another terminal:

```bash
curl -i http://localhost:3000/live
curl -i http://localhost:3000/ready
curl -i http://localhost:3000/api/dashboard
```

Open:

```text
http://localhost:3000
```

Stop the application:

```text
Ctrl+C
```

Run the final project review:

```bash
git diff --check
git status
```

Confirm that no `.env`, secret, log, coverage, or diagnostic artifact is accidentally tracked.

---

# Part 5.24: Final Assessment

Answer without consulting the source code.

## 1. Why does the dashboard use `Promise.allSettled()`?

```text
____________________________________________________________

____________________________________________________________
```

## 2. Why does each refresh create a new `AbortController`?

```text
____________________________________________________________

____________________________________________________________
```

## 3. Why does the retry layer receive `isRetryable()`?

```text
____________________________________________________________

____________________________________________________________
```

## 4. What happens when the circuit is open?

```text
____________________________________________________________

____________________________________________________________
```

## 5. Why is rendering scheduled through a microtask?

```text
____________________________________________________________

____________________________________________________________
```

## 6. What prevents a stale request from replacing newer data?

```text
____________________________________________________________

____________________________________________________________
```

## 7. Which resources require cleanup?

```text
____________________________________________________________

____________________________________________________________
```

## 8. What is the difference between `/live` and `/ready`?

```text
____________________________________________________________

____________________________________________________________
```

---

# Part 5.25: Capstone Completion Checklist

The capstone is complete when:

- [ ] The project starts with `npm start`.
- [ ] The browser dashboard loads.
- [ ] `/live` returns 200.
- [ ] `/ready` returns 200.
- [ ] `/api/dashboard` returns service data.
- [ ] Three services load concurrently.
- [ ] Temporary failures retry.
- [ ] Retry attempts are bounded.
- [ ] Backoff is applied.
- [ ] Circuit state transitions work.
- [ ] Timeouts cancel slow operations.
- [ ] Refresh cancellation works.
- [ ] Partial results are preserved.
- [ ] Reactive state updates the UI.
- [ ] Filtering is debounced.
- [ ] Rendering is batched.
- [ ] Tests pass.
- [ ] Coverage runs.
- [ ] Shutdown is graceful.
- [ ] No secrets are committed.
- [ ] Known limitations are documented.

---

# Part 5.26: Series Completion

You have now connected the complete series:

```text
JavaScript syntax
        │
        ▼
Node.js tooling
        │
        ▼
Execution contexts
        │
        ▼
Closures and this
        │
        ▼
Event loop and promises
        │
        ▼
Concurrency and cancellation
        │
        ▼
Functional transformations
        │
        ▼
Reactive state
        │
        ▼
Memory ownership
        │
        ▼
Performance scheduling
        │
        ▼
Retries and circuit breakers
        │
        ▼
Testing and observability
        │
        ▼
Production-oriented application
```

The most important capstone lesson is that advanced JavaScript is not a collection of unrelated language tricks.

It is the disciplined coordination of:

- Values.
- Functions.
- Time.
- Memory.
- State.
- Dependencies.
- Failures.
- Resources.
- Users.
- Operations.
