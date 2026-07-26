# Appendix H: Resilience and Failure-Handling Reference

A production application must be designed for failure.

Networks disconnect. Services become slow. Credentials expire. Users cancel operations. Processes restart. Dependencies return malformed data. A request can succeed on the server while its response is lost on the network.

Resilience is the discipline of deciding what the application should do under those conditions.

This appendix covers:

- Failure classification.
- Error taxonomy.
- Timeouts.
- Retries.
- Exponential backoff.
- Jitter.
- Idempotency.
- Circuit breakers.
- Bulkheads.
- Rate limits.
- Fallbacks.
- Graceful degradation.
- Stale data.
- Cancellation.
- Error boundaries.
- Graceful shutdown.
- Resilience testing.
- Operational checklists.

---

# H.1: Resilience Vocabulary

## Resilience

Resilience is the ability of a system to continue providing acceptable behavior when components fail.

Resilience does not mean pretending failures do not happen. It means:

- Detecting failures.
- Limiting their impact.
- Recovering when appropriate.
- Providing honest fallback behavior.
- Preserving important work.
- Producing useful diagnostics.

---

## Fault

A fault is an underlying condition that can cause incorrect or failed behavior.

Examples:

- Network connection loss.
- Database outage.
- Invalid configuration.
- Memory pressure.
- Expired credential.
- Incorrect application state.

---

## Failure

A failure is the observable result of a fault.

Examples:

```text
request timed out
database returned 503
response body was invalid
```

---

## Incident

An incident is a production event requiring investigation or operational response.

A single failed request may not be an incident. A sustained dependency outage affecting many users may be.

---

## Dependency

A dependency is a component your application requires.

Examples:

- Database.
- External API.
- Queue.
- File system.
- Authentication provider.
- Browser storage.
- Worker thread.

Every dependency should have an explicit failure policy.

---

## Failure Domain

A failure domain is a boundary within which a failure can occur or spread.

Examples:

```text
dashboard panel
service API
database cluster
region
application process
```

A resilient design prevents one failure domain from unnecessarily taking down unrelated domains.

---

# H.2: Error Taxonomy

## The Target

We will create explicit error classes.

## The Concept

Error classes make failures easier to classify.

Instead of checking fragile message strings:

```js
if (error.message.includes("timeout")) {
  // ...
}
```

use stable names or classes:

```js
if (error instanceof TimeoutError) {
  // ...
}
```

## Implementation

### `src/part-4/resilience/errors.js`

```js
"use strict";

export class ApplicationError extends Error {
  constructor(message, options = {}) {
    super(message, options);

    this.name = new.target.name;
    this.code = options.code;
    this.retryable = options.retryable ?? false;
    this.exposeToUser = options.exposeToUser ?? false;
  }
}

export class ValidationError extends ApplicationError {
  constructor(message, options = {}) {
    super(message, {
      ...options,
      retryable: false,
      exposeToUser: true,
      code: options.code ?? "VALIDATION_ERROR"
    });
  }
}

export class TimeoutError extends ApplicationError {
  constructor(message, options = {}) {
    super(message, {
      ...options,
      retryable: true,
      code: options.code ?? "TIMEOUT"
    });
  }
}

export class CancellationError extends ApplicationError {
  constructor(message = "operation cancelled", options = {}) {
    super(message, {
      ...options,
      retryable: false,
      code: options.code ?? "CANCELLED"
    });
  }
}

export class DependencyError extends ApplicationError {
  constructor(message, options = {}) {
    super(message, {
      ...options,
      retryable: options.retryable ?? true,
      code: options.code ?? "DEPENDENCY_ERROR"
    });

    this.status = options.status;
  }
}

export class CircuitOpenError extends ApplicationError {
  constructor(message = "circuit is open", options = {}) {
    super(message, {
      ...options,
      retryable: false,
      code: options.code ?? "CIRCUIT_OPEN"
    });
  }
}

export function isCancellationError(error) {
  return (
    error instanceof CancellationError ||
    error?.name === "AbortError" ||
    error?.code === "ABORT_ERR"
  );
}

export function isRetryableError(error) {
  return error?.retryable === true;
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import {
  TimeoutError,
  ValidationError,
  isRetryableError
} from "./src/part-4/resilience/errors.js";

const timeout = new TimeoutError("request timed out");
const invalid = new ValidationError("invalid limit");

console.log({
  timeoutName: timeout.name,
  timeoutRetryable: isRetryableError(timeout),
  invalidName: invalid.name,
  invalidRetryable: isRetryableError(invalid)
});
EOF
```

Expected output:

```text
{
  timeoutName: 'TimeoutError',
  timeoutRetryable: true,
  invalidName: 'ValidationError',
  invalidRetryable: false
}
```

---

# H.3: Error Classification Table

| Failure | Usually retry? | User-visible? | Circuit-breaker count? |
|---|---:|---:|---:|
| Invalid input | No | Yes | No |
| Authentication failure | No | Sometimes | Usually no |
| Permission denied | No | Yes | Usually no |
| Not found | No | Sometimes | Usually no |
| Timeout | Sometimes | Usually fallback | Often yes |
| Connection reset | Often | Usually fallback | Often yes |
| Rate limited | Later | Usually fallback | Sometimes |
| Server error 500 | Sometimes | Usually fallback | Often yes |
| Server error 400 | No | Yes | No |
| Cancellation | No | Usually no | No |
| Programming error | No | No direct detail | No |
| Circuit open | No immediate retry | Fallback | Already open |

The correct policy depends on the operation and dependency.

---

# H.4: Error Classification Function

## Implementation

### `src/part-4/resilience/classify-error.js`

```js
"use strict";

import {
  isCancellationError,
  isRetryableError,
  ValidationError,
  CircuitOpenError
} from "./errors.js";

export function classifyError(error) {
  if (isCancellationError(error)) {
    return "cancellation";
  }

  if (error instanceof ValidationError) {
    return "validation";
  }

  if (error instanceof CircuitOpenError) {
    return "circuit-open";
  }

  if (isRetryableError(error)) {
    return "retryable-dependency";
  }

  if (
    Number.isInteger(error?.status) &&
    error.status >= 400 &&
    error.status < 500
  ) {
    return "client-error";
  }

  if (
    Number.isInteger(error?.status) &&
    error.status >= 500
  ) {
    return "server-error";
  }

  return "unknown";
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import {
  TimeoutError,
  ValidationError,
  CancellationError
} from "./src/part-4/resilience/errors.js";

import { classifyError } from "./src/part-4/resilience/classify-error.js";

console.log(classifyError(new TimeoutError("slow")));
console.log(classifyError(new ValidationError("invalid")));
console.log(classifyError(new CancellationError()));
EOF
```

Expected output:

```text
retryable-dependency
validation
cancellation
```

---

# H.5: Timeouts

## The Concept

A timeout defines how long an operation may occupy resources before the caller stops waiting.

Without timeouts, a dependency can remain pending indefinitely:

```text
application request
        │
        ▼
external service never responds
        │
        ▼
resources remain occupied
```

Timeouts protect:

- Request slots.
- Memory.
- User-interface responsiveness.
- Connection pools.
- Worker capacity.
- Overall workflow deadlines.

A timeout should usually cancel the underlying work, not merely stop waiting for it.

---

# H.6: Timeout Budgets

A workflow may have one overall deadline:

```text
total budget: 2,000 ms
├── first attempt: 500 ms
├── retry delay: 100 ms
├── second attempt: 700 ms
└── remaining work: 700 ms
```

Do not give every retry a fresh, unlimited timeout:

```text
attempt 1: 5 seconds
attempt 2: 5 seconds
attempt 3: 5 seconds
```

That can turn a nominal five-second operation into a 15-second operation.

---

# H.7: Deadline-Aware Utility

## Implementation

### `src/part-4/resilience/deadline.js`

```js
"use strict";

import {
  TimeoutError,
  CancellationError
} from "./errors.js";

export function createDeadline(
  durationMilliseconds,
  now = () => Date.now()
) {
  if (
    !Number.isFinite(durationMilliseconds) ||
    durationMilliseconds <= 0
  ) {
    throw new RangeError(
      "durationMilliseconds must be positive and finite"
    );
  }

  const expiresAt = now() + durationMilliseconds;

  return Object.freeze({
    expiresAt,

    remainingMilliseconds() {
      return Math.max(0, expiresAt - now());
    },

    isExpired() {
      return now() >= expiresAt;
    },

    assertRemaining() {
      if (this.isExpired()) {
        throw new TimeoutError(
          "operation deadline expired"
        );
      }
    }
  });
}

export async function runWithDeadline(
  operation,
  deadline,
  signal
) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (!deadline) {
    throw new TypeError("deadline is required");
  }

  if (!(signal instanceof AbortSignal)) {
    throw new TypeError("signal must be an AbortSignal");
  }

  if (signal.aborted) {
    throw new CancellationError();
  }

  const remaining = deadline.remainingMilliseconds();

  if (remaining <= 0) {
    throw new TimeoutError(
      "operation deadline expired"
    );
  }

  const controller = new AbortController();

  const forwardAbort = () => {
    controller.abort(signal.reason);
  };

  signal.addEventListener(
    "abort",
    forwardAbort,
    { once: true }
  );

  const timerId = setTimeout(() => {
    controller.abort(
      new TimeoutError(
        "operation deadline expired"
      )
    );
  }, remaining);

  try {
    return await operation(controller.signal);
  } finally {
    clearTimeout(timerId);

    signal.removeEventListener(
      "abort",
      forwardAbort
    );
  }
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import {
  createDeadline,
  runWithDeadline
} from "./src/part-4/resilience/deadline.js";

const deadline = createDeadline(50);

try {
  await runWithDeadline(
    async (signal) => {
      await new Promise((resolve, reject) => {
        const timer = setTimeout(resolve, 1_000);

        signal.addEventListener("abort", () => {
          clearTimeout(timer);
          reject(signal.reason);
        }, { once: true });
      });
    },
    deadline,
    new AbortController().signal
  );
} catch (error) {
  console.log(error.name);
}
EOF
```

Expected output:

```text
TimeoutError
```

---

# H.8: Retry Policies

## The Concept

Retries are appropriate only when all of these questions have reasonable answers:

1. Could the failure recover soon?
2. Is repeating the operation safe?
3. Is the caller still waiting?
4. Is the dependency likely to benefit from another attempt?
5. Is there a maximum attempt count?
6. Is there a delay between attempts?

A retry policy is not simply:

```js
while (true) {
  try {
    return await operation();
  } catch {
    // Try again forever.
  }
}
```

That can amplify an outage.

---

# H.9: HTTP Retry Policy

## Implementation

### `src/part-4/resilience/http-policy.js`

```js
"use strict";

const idempotentMethods = new Set([
  "GET",
  "HEAD",
  "OPTIONS",
  "PUT",
  "DELETE"
]);

export function shouldRetryHttpRequest({
  method,
  status,
  error,
  attempt,
  maximumAttempts
}) {
  const normalizedMethod =
    method.toUpperCase();

  if (attempt >= maximumAttempts) {
    return false;
  }

  if (!idempotentMethods.has(normalizedMethod)) {
    return false;
  }

  if (error?.name === "AbortError") {
    return false;
  }

  if (error?.name === "TimeoutError") {
    return true;
  }

  if (status === 408 || status === 425) {
    return true;
  }

  if (status === 429) {
    return true;
  }

  if (Number.isInteger(status) && status >= 500) {
    return true;
  }

  return false;
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { shouldRetryHttpRequest } from "./src/part-4/resilience/http-policy.js";

console.log(shouldRetryHttpRequest({
  method: "GET",
  status: 503,
  attempt: 1,
  maximumAttempts: 3
}));

console.log(shouldRetryHttpRequest({
  method: "POST",
  status: 503,
  attempt: 1,
  maximumAttempts: 3
}));
EOF
```

Expected output:

```text
true
false
```

A `POST` may be retryable if the API supports idempotency keys, but the policy should require that explicitly.

---

# H.10: Exponential Backoff and Jitter

A typical capped exponential backoff is:

```js
delay = min(maximumDelay, baseDelay * 2 ** (attempt - 1));
```

With full jitter:

```js
actualDelay = random(0, delay);
```

Example:

```text
base delay: 100 ms
maximum:    10,000 ms

attempt 1: cap 100 ms
attempt 2: cap 200 ms
attempt 3: cap 400 ms
attempt 4: cap 800 ms
```

Jitter prevents synchronized clients from retrying together.

---

# H.11: Respecting `Retry-After`

## Concept

A server may tell the client when to retry:

```http
Retry-After: 30
```

or:

```http
Retry-After: Wed, 24 Jul 2026 12:00:00 GMT
```

The client should respect this value when safe and reasonable.

## Implementation

### `src/part-4/resilience/retry-after.js`

```js
"use strict";

export function parseRetryAfter(
  value,
  now = () => Date.now()
) {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();

  if (/^\d+$/.test(trimmed)) {
    return Number(trimmed) * 1_000;
  }

  const timestamp = Date.parse(trimmed);

  if (Number.isNaN(timestamp)) {
    return null;
  }

  return Math.max(0, timestamp - now());
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { parseRetryAfter } from "./src/part-4/resilience/retry-after.js";

console.log(parseRetryAfter("30"));
console.log(parseRetryAfter(
  "Wed, 24 Jul 2030 12:00:00 GMT",
  () => Date.parse("Wed, 24 Jul 2030 11:59:00 GMT")
));
EOF
```

Expected output:

```text
30000
60000
```

Always cap server-provided delays according to application policy.

---

# H.12: Idempotency

## The Concept

An operation is idempotent when repeating it produces the same intended final state.

Usually idempotent:

```text
GET /users/123
PUT /users/123
DELETE /users/123
```

Not automatically idempotent:

```text
POST /payments
POST /orders
POST /counter/increment
```

A timeout does not prove that the server did not process the request.

```text
client sends payment
server processes payment
network response is lost
client sees timeout
client retries
```

This can create duplicate effects.

---

# H.13: Idempotency-Key Utility

## Implementation

### `src/part-4/resilience/idempotency.js`

```js
"use strict";

import { randomUUID } from "node:crypto";

export function createIdempotencyKey(
  operationName
) {
  if (
    typeof operationName !== "string" ||
    operationName.trim() === ""
  ) {
    throw new TypeError(
      "operationName must be a non-empty string"
    );
  }

  return `${operationName.trim()}:${randomUUID()}`;
}

export function withIdempotencyKey(
  headers,
  key
) {
  if (!headers || typeof headers !== "object") {
    throw new TypeError("headers must be an object");
  }

  if (typeof key !== "string" || key.length === 0) {
    throw new TypeError(
      "key must be a non-empty string"
    );
  }

  return {
    ...headers,
    "Idempotency-Key": key
  };
}

const key = createIdempotencyKey("create-payment");

console.log(
  withIdempotencyKey(
    {
      "content-type": "application/json"
    },
    key
  )
);
```

## Verification

Run:

```bash
node src/part-4/resilience/idempotency.js
```

Expected output includes an `Idempotency-Key` header.

---

# H.14: Circuit Breakers

## States

```text
CLOSED
  │ failures reach threshold
  ▼
OPEN
  │ cooldown completes
  ▼
HALF_OPEN
  ├── success → CLOSED
  └── failure → OPEN
```

## Closed

Requests are allowed. Failures are counted.

## Open

Requests fail immediately without contacting the dependency.

## Half-Open

A limited probe tests whether the dependency recovered.

Only one or a controlled number of probes should usually be allowed.

---

# H.15: Circuit-Breaker Design Rules

A circuit breaker should define:

- Failure threshold.
- Reset timeout.
- Which errors count.
- How success resets failures.
- Whether half-open allows one probe.
- How state transitions are logged.
- What callers receive when open.
- How metrics are recorded.
- Whether multiple application instances share state.

A process-local circuit breaker protects only one process. In a multi-instance system, each instance may have its own breaker. That can be appropriate, but it should be understood.

---

# H.16: Bulkheads

## Concept

A **bulkhead** limits how much one dependency or workload can consume.

The name comes from ships: watertight compartments prevent one flooded section from sinking the entire vessel.

Without bulkheads:

```text
dependency A consumes all request slots
dependency B cannot run
entire application appears unavailable
```

With bulkheads:

```text
dependency A: maximum 10 concurrent operations
dependency B: maximum 10 concurrent operations
```

Bulkheads can limit:

- Concurrent requests.
- Queue length.
- Worker count.
- Memory per workload.
- Connection-pool usage.

---

# H.17: Bulkhead Concurrency Limiter

## Implementation

### `src/part-4/resilience/bulkhead.js`

```js
"use strict";

export class BulkheadRejectedError extends Error {
  constructor(message = "bulkhead capacity exceeded") {
    super(message);
    this.name = "BulkheadRejectedError";
    this.retryable = true;
  }
}

export function createBulkhead({
  maximumConcurrency,
  maximumQueueSize = 0
}) {
  if (
    !Number.isInteger(maximumConcurrency) ||
    maximumConcurrency < 1
  ) {
    throw new RangeError(
      "maximumConcurrency must be a positive integer"
    );
  }

  if (
    !Number.isInteger(maximumQueueSize) ||
    maximumQueueSize < 0
  ) {
    throw new RangeError(
      "maximumQueueSize must be a non-negative integer"
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

  function execute(operation) {
    if (typeof operation !== "function") {
      return Promise.reject(
        new TypeError(
          "operation must be a function"
        )
      );
    }

    if (
      activeCount >= maximumConcurrency &&
      queue.length >= maximumQueueSize
    ) {
      return Promise.reject(
        new BulkheadRejectedError()
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
    execute,

    get activeCount() {
      return activeCount;
    },

    get queuedCount() {
      return queue.length;
    }
  });
}

const bulkhead = createBulkhead({
  maximumConcurrency: 2,
  maximumQueueSize: 1
});

function work(name) {
  return bulkhead.execute(async () => {
    console.log("started:", name);

    await new Promise((resolve) => {
      setTimeout(resolve, 20);
    });

    console.log("finished:", name);
    return name;
  });
}

const results = await Promise.allSettled([
  work("A"),
  work("B"),
  work("C"),
  work("D")
]);

console.dir(results, { depth: null });
```

## Verification

Run:

```bash
node src/part-4/resilience/bulkhead.js
```

Some operations should be rejected once active capacity and queue capacity are exhausted.

---

# H.18: Rate Limiting

## Concept

A rate limiter controls how frequently operations may begin.

A concurrency limit controls simultaneous work:

```text
maximum active operations: 5
```

A rate limit controls starts over time:

```text
maximum starts: 100 per minute
```

These solve different problems.

Rate limits protect:

- External APIs.
- Database capacity.
- Internal services.
- Billing constraints.
- User quotas.

---

# H.19: Simple Token-Bucket Limiter

## Implementation

### `src/part-4/resilience/token-bucket.js`

```js
"use strict";

export function createTokenBucket({
  capacity,
  refillRatePerSecond,
  now = () => Date.now()
}) {
  if (
    !Number.isFinite(capacity) ||
    capacity <= 0
  ) {
    throw new RangeError(
      "capacity must be positive and finite"
    );
  }

  if (
    !Number.isFinite(refillRatePerSecond) ||
    refillRatePerSecond <= 0
  ) {
    throw new RangeError(
      "refillRatePerSecond must be positive and finite"
    );
  }

  let tokens = capacity;
  let lastRefillTime = now();

  function refill() {
    const currentTime = now();
    const elapsedSeconds =
      (currentTime - lastRefillTime) / 1_000;

    tokens = Math.min(
      capacity,
      tokens + elapsedSeconds * refillRatePerSecond
    );

    lastRefillTime = currentTime;
  }

  function tryConsume(amount = 1) {
    if (
      !Number.isFinite(amount) ||
      amount <= 0
    ) {
      throw new RangeError(
        "amount must be positive and finite"
      );
    }

    refill();

    if (tokens < amount) {
      return false;
    }

    tokens -= amount;
    return true;
  }

  return Object.freeze({
    tryConsume,

    get availableTokens() {
      refill();
      return tokens;
    }
  });
}

let currentTime = 0;

const bucket = createTokenBucket({
  capacity: 2,
  refillRatePerSecond: 1,
  now: () => currentTime
});

console.log(bucket.tryConsume());
console.log(bucket.tryConsume());
console.log(bucket.tryConsume());

currentTime = 1_000;

console.log(bucket.tryConsume());
```

## Verification

Run:

```bash
node src/part-4/resilience/token-bucket.js
```

Expected output:

```text
true
true
false
true
```

The bucket begins with two tokens and refills one token per second.

---

# H.20: Fallbacks

## The Concept

A fallback is an alternative response when the preferred operation fails.

Good fallback behavior is:

- Explicit.
- Bounded.
- Honest.
- Observable.
- Appropriate for the data’s freshness.
- Safe under repeated use.

Examples:

```js
{
  status: "stale",
  data: cachedData,
  updatedAt: previousTimestamp
}
```

```js
{
  status: "unavailable",
  reason: "activity service is temporarily unavailable"
}
```

Do not silently substitute fake current data for missing data.

---

# H.21: Stale-While-Revalidate

## Concept

Stale-while-revalidate returns cached data immediately while attempting a refresh in the background.

```text
request
  │
  ├── cached data available → return immediately
  │
  └── refresh in background
```

This reduces perceived latency but requires accurate freshness metadata.

## Implementation

### `src/part-4/resilience/stale-cache.js`

```js
"use strict";

export function createStaleCache({
  load,
  maxAgeMilliseconds,
  now = () => Date.now()
}) {
  if (typeof load !== "function") {
    throw new TypeError("load must be a function");
  }

  if (
    !Number.isFinite(maxAgeMilliseconds) ||
    maxAgeMilliseconds < 0
  ) {
    throw new RangeError(
      "maxAgeMilliseconds must be non-negative and finite"
    );
  }

  let cachedEntry = null;
  let refreshPromise = null;

  async function refresh() {
    if (refreshPromise) {
      return refreshPromise;
    }

    refreshPromise = Promise.resolve()
      .then(load)
      .then((value) => {
        cachedEntry = {
          value,
          loadedAt: now()
        };

        return cachedEntry;
      })
      .finally(() => {
        refreshPromise = null;
      });

    return refreshPromise;
  }

  async function get() {
    if (!cachedEntry) {
      const entry = await refresh();

      return {
        status: "fresh",
        value: entry.value,
        loadedAt: entry.loadedAt
      };
    }

    const age = now() - cachedEntry.loadedAt;

    if (age <= maxAgeMilliseconds) {
      return {
        status: "fresh",
        value: cachedEntry.value,
        loadedAt: cachedEntry.loadedAt
      };
    }

    void refresh().catch(() => {
      /*
       * The stale value remains available. The caller may observe the refresh
       * failure through logging or metrics in a production implementation.
       */
    });

    return {
      status: "stale",
      value: cachedEntry.value,
      loadedAt: cachedEntry.loadedAt
    };
  }

  return Object.freeze({
    get,
    refresh
  });
}

let currentTime = 0;
let loads = 0;

const cache = createStaleCache({
  maxAgeMilliseconds: 100,
  now: () => currentTime,
  load: async () => {
    loads += 1;
    return {
      requestsPerSecond: loads * 100
    };
  }
});

console.log(await cache.get());

currentTime = 200;

console.log(await cache.get());

await new Promise((resolve) => {
  setTimeout(resolve, 0);
});

console.log({
  loads
});
```

## Verification

Run:

```bash
node src/part-4/resilience/stale-cache.js
```

The second read should initially return stale data while a refresh is scheduled.

---

# H.22: Graceful Degradation

A dashboard may contain independent panels:

```text
metrics       available
health        available
activity      unavailable
notifications available
```

The correct result is not necessarily a blank page.

Use a panel-level status:

```js
{
  status: "unavailable",
  error: "activity service failed"
}
```

The interface can show:

```text
Activity temporarily unavailable.
Other dashboard sections remain available.
```

---

# H.23: Fallback Decision Table

| Situation | Recommended fallback |
|---|---|
| Fresh cache exists | Return fresh cache |
| Stale cache exists | Return stale cache with timestamp |
| Optional panel fails | Show panel-level error |
| Required authentication fails | Ask user to authenticate |
| Validation fails | Show actionable input error |
| Request cancelled | Stop silently or preserve current UI |
| Dependency circuit open | Return known fallback immediately |
| No fallback exists | Show controlled unavailable state |
| Programming error | Error boundary and diagnostic report |

---

# H.24: Error Boundaries

## Local Boundary

Handle failures where context is available:

```js
try {
  const metrics = await metricsService.load();
  renderMetrics(metrics);
} catch (error) {
  renderMetricsError(error);
}
```

## Application Boundary

Handle failures that escape individual components:

```js
try {
  await application.start();
} catch (error) {
  showFatalApplicationError(error);
  reportError(error);
}
```

## Process Boundary

Node.js provides final safety handlers, but an uncaught programming error may leave the process unsafe. Log, clean up, and restart through a supervisor.

---

# H.25: Cancellation Is Not Failure

Cancellation means the caller no longer wants the result.

```js
try {
  await request(signal);
} catch (error) {
  if (error.name === "AbortError") {
    return;
  }

  showError(error);
}
```

Do not:

- Retry cancellation.
- Count cancellation as a dependency outage.
- Show “server failed” when the user navigated away.
- Report normal cancellation as an unexpected production incident.

---

# H.26: Graceful Shutdown

## Shutdown Sequence

```text
receive shutdown signal
        │
        ▼
stop accepting new work
        │
        ▼
cancel obsolete background operations
        │
        ▼
finish or cancel active requests
        │
        ▼
close subscriptions and timers
        │
        ▼
flush logs and metrics
        │
        ▼
close connections
        │
        ▼
exit
```

A shutdown deadline prevents cleanup from hanging forever.

---

# H.27: Shutdown Coordinator

## Implementation

### `src/part-4/resilience/shutdown-coordinator.js`

```js
"use strict";

export function createShutdownCoordinator({
  timeoutMilliseconds = 5_000,
  logger = console
} = {}) {
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
    if (shuttingDown) {
      throw new Error(
        "cannot register cleanup during shutdown"
      );
    }

    if (typeof cleanup !== "function") {
      throw new TypeError(
        "cleanup must be a function"
      );
    }

    cleanupFunctions.push(cleanup);
  }

  async function shutdown(reason) {
    if (shuttingDown) {
      return;
    }

    shuttingDown = true;

    logger.info("shutdown started", { reason });

    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => {
        reject(
          new Error(
            "shutdown deadline exceeded"
          )
        );
      }, timeoutMilliseconds);
    });

    const cleanupPromise = (async () => {
      const errors = [];

      for (
        let index = cleanupFunctions.length - 1;
        index >= 0;
        index -= 1
      ) {
        try {
          await cleanupFunctions[index]();
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

    await Promise.race([
      cleanupPromise,
      timeoutPromise
    ]);

    logger.info("shutdown completed");
  }

  return Object.freeze({
    addCleanup,
    shutdown
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createShutdownCoordinator } from "./src/part-4/resilience/shutdown-coordinator.js";

const coordinator = createShutdownCoordinator({
  logger: {
    info(message, details) {
      console.log(message, details ?? "");
    }
  }
});

coordinator.addCleanup(async () => {
  console.log("closing dependency");
});

coordinator.addCleanup(async () => {
  console.log("closing subscriptions");
});

await coordinator.shutdown("verification");
EOF
```

Expected output:

```text
shutdown started { reason: 'verification' }
closing subscriptions
closing dependency
shutdown completed
```

---

# H.28: Resilience Metrics

Track resilience behavior explicitly:

```js
{
  requestCount: 1000,
  successCount: 920,
  failureCount: 80,
  timeoutCount: 20,
  cancellationCount: 100,
  retryCount: 145,
  retryExhaustionCount: 15,
  circuitOpenCount: 3,
  fallbackCount: 70,
  staleResponseCount: 42,
  bulkheadRejectionCount: 5
}
```

Metrics help answer:

- Are retries helping?
- Are timeouts too short?
- Is a dependency frequently unavailable?
- Are users receiving stale data?
- Is a circuit breaker opening too often?
- Is capacity too small?

---

# H.29: Resilience Testing

A resilient system must be tested under failure.

Test scenarios include:

- Dependency returns 500.
- Dependency returns 429.
- Request times out.
- Request is cancelled.
- Response body is malformed.
- Retry succeeds on the second attempt.
- Retry exhausts all attempts.
- Circuit opens.
- Circuit half-open probe succeeds.
- Circuit half-open probe fails.
- Bulkhead rejects excess work.
- Cache returns stale data.
- Shutdown occurs during active work.

---

# H.30: Failure Injection

## The Target

We will create a dependency that fails according to a controlled plan.

## Implementation

### `src/part-4/resilience/failure-injection.js`

```js
"use strict";

export function createFailurePlan(
  outcomes
) {
  if (!Array.isArray(outcomes)) {
    throw new TypeError(
      "outcomes must be an array"
    );
  }

  let index = 0;

  return async function execute() {
    const outcome =
      outcomes[Math.min(index, outcomes.length - 1)];

    index += 1;

    if (!outcome) {
      return {
        status: "success"
      };
    }

    if (outcome.type === "success") {
      return outcome.value;
    }

    if (outcome.type === "failure") {
      throw outcome.error;
    }

    throw new Error(
      `unknown failure-plan outcome: ${outcome.type}`
    );
  };
}

const temporaryError = new Error(
  "temporary dependency failure"
);

const operation = createFailurePlan([
  {
    type: "failure",
    error: temporaryError
  },
  {
    type: "success",
    value: {
      status: "healthy"
    }
  }
]);

try {
  await operation();
} catch (error) {
  console.log("first attempt:", error.message);
}

console.log("second attempt:", await operation());
```

## Verification

Run:

```bash
node src/part-4/resilience/failure-injection.js
```

Expected output:

```text
first attempt: temporary dependency failure
second attempt: { status: 'healthy' }
```

This lets tests simulate failures without depending on a real outage.

---

# H.31: Resilience Test Matrix

| Scenario | Expected behavior |
|---|---|
| First attempt succeeds | No retry |
| First attempt times out | Retry if policy allows |
| All attempts fail | Return final error |
| Validation fails | No retry |
| Request is cancelled | Stop immediately |
| Circuit is closed | Operation runs |
| Circuit is open | Operation is rejected immediately |
| Reset timeout expires | One probe is allowed |
| Probe succeeds | Circuit closes |
| Probe fails | Circuit opens again |
| Queue is full | Bulkhead rejects |
| Cache is fresh | Return fresh data |
| Cache is stale | Return stale data and refresh |
| No fallback exists | Return controlled unavailable state |
| Shutdown starts | New work rejected and active work cleaned up |

---

# H.32: Resilience Anti-Patterns

## Infinite Retries

```js
while (true) {
  await operation();
}
```

Problem: consumes resources and amplifies outages.

---

## Immediate Retries

```js
for (let attempt = 0; attempt < 100; attempt += 1) {
  await operation();
}
```

Problem: creates a retry storm.

---

## Retrying Non-Idempotent Operations

```js
await retry(() => createPayment());
```

Problem: may create duplicate payments.

---

## Timeout Without Cancellation

```js
await Promise.race([
  slowOperation(),
  timeout()
]);
```

Problem: the losing operation may continue.

---

## Circuit Breaker Without Recovery

A circuit that opens but never allows a half-open probe becomes permanently unavailable.

---

## Fallback Without Freshness

```js
return cachedData;
```

Problem: users may believe stale data is current.

Prefer:

```js
return {
  status: "stale",
  data: cachedData,
  loadedAt
};
```

---

## Catching Everything as a Generic Error

```js
catch {
  return "service unavailable";
}
```

Problem: hides cancellation, validation, authentication, and programming errors.

---

## Logging Sensitive Errors

```js
logger.error(error);
```

Problem: error objects may contain request headers, tokens, or user data.

Redact before logging.

---

# H.33: Resilience Configuration

Use explicit configuration:

```text
REQUEST_TIMEOUT_MS=5000
RETRY_MAX_ATTEMPTS=3
RETRY_BASE_DELAY_MS=100
RETRY_MAX_DELAY_MS=5000
CIRCUIT_FAILURE_THRESHOLD=5
CIRCUIT_RESET_TIMEOUT_MS=30000
BULKHEAD_MAX_CONCURRENCY=20
BULKHEAD_MAX_QUEUE=100
STALE_CACHE_MAX_AGE_MS=60000
SHUTDOWN_TIMEOUT_MS=10000
```

Validate every value at startup.

Do not silently accept:

```text
REQUEST_TIMEOUT_MS=banana
```

---

# H.34: Resilience Configuration Validation

## Implementation

### `src/part-4/resilience/resilience-config.js`

```js
"use strict";

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

export function loadResilienceConfig(
  environment = process.env
) {
  const config = {
    requestTimeoutMilliseconds:
      positiveInteger(
        environment.REQUEST_TIMEOUT_MS,
        5_000,
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
        100,
        "RETRY_BASE_DELAY_MS"
      ),

    circuitFailureThreshold:
      positiveInteger(
        environment.CIRCUIT_FAILURE_THRESHOLD,
        5,
        "CIRCUIT_FAILURE_THRESHOLD"
      )
  };

  if (
    config.retryBaseDelayMilliseconds >
    config.requestTimeoutMilliseconds
  ) {
    throw new Error(
      "retry base delay cannot exceed request timeout"
    );
  }

  return Object.freeze(config);
}

console.log(
  loadResilienceConfig({
    REQUEST_TIMEOUT_MS: "5000",
    RETRY_MAX_ATTEMPTS: "3",
    RETRY_BASE_DELAY_MS: "100",
    CIRCUIT_FAILURE_THRESHOLD: "5"
  })
);
```

## Verification

Run:

```bash
node src/part-4/resilience/resilience-config.js
```

---

# H.35: Operational Resilience Checklist

## Requests

- Does every external request have a timeout?
- Can it be cancelled?
- Is the response status checked?
- Is the response body validated?
- Are duplicate requests avoided?

## Retries

- Is the error retryable?
- Is the operation idempotent?
- Are attempts bounded?
- Is exponential backoff used?
- Is jitter used?
- Is `Retry-After` respected?
- Does the retry loop honor an overall deadline?

## Circuit Breakers

- Is the failure threshold appropriate?
- Is the reset timeout configured?
- Is a half-open probe allowed?
- Are state changes logged?
- Are open-circuit responses measured?

## Capacity

- Is concurrency bounded?
- Is queue size bounded?
- Can one dependency consume all resources?
- Are rate limits respected?

## Fallbacks

- Is fallback data marked stale?
- Is the fallback safe?
- Does the user know what is unavailable?
- Can the system recover automatically?

## Errors

- Are cancellation and failure distinct?
- Are validation errors retried accidentally?
- Are programming errors hidden?
- Are logs redacted?
- Is the original error preserved as a cause?

## Shutdown

- Does shutdown stop new work?
- Are active operations cancelled or completed?
- Are timers and subscriptions released?
- Is cleanup bounded by a deadline?
- Does the process exit safely?

---

# H.36: Final Resilience Architecture

A robust dependency call often follows this structure:

```text
caller
  │
  ▼
overall deadline
  │
  ▼
bulkhead / concurrency limit
  │
  ▼
circuit breaker
  │
  ▼
retry policy
  │
  ▼
per-attempt timeout
  │
  ▼
cancellable request
  │
  ▼
dependency
```

The result flows back through:

```text
dependency result
  │
  ├── success → return data
  │
  ├── temporary failure → retry if safe
  │
  ├── repeated failure → open circuit
  │
  ├── timeout → cancel and classify
  │
  ├── cancellation → stop without false failure
  │
  └── permanent failure → fallback or controlled error
```

---

# H.37: Final Resilience Mental Model

When a dependency fails, ask:

```text
1. What kind of failure is this?
2. Can repeating the operation help?
3. Is repeating it safe?
4. How long should the caller wait?
5. Can the operation be cancelled?
6. How many retries are allowed?
7. Should the dependency be protected by a circuit breaker?
8. Could this workload consume all available capacity?
9. Is fallback data available?
10. How will the failure be measured and reported?
```

Resilience is not achieved by adding retries everywhere.

It comes from combining:

```text
classification
  + deadlines
  + cancellation
  + safe retries
  + backoff and jitter
  + idempotency
  + circuit breakers
  + bulkheads
  + honest fallbacks
  + error boundaries
  + graceful shutdown
```

A resilient system does not promise that failures will never happen. It ensures that failures are bounded, visible, recoverable where possible, and communicated honestly.
