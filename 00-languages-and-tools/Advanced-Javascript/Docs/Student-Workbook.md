# Advanced JavaScript Student Workbook

## Runtime Engines, Optimization & Architecture

**Student:** ____________________________________  
**Date started:** _________________________________  
**Date completed:** ______________________________  
**Instructor or mentor:** _________________________  

---

## How to Use This Workbook

For every exercise:

1. Read the related tutorial section.
2. Predict the result before running the code.
3. Implement the exercise without copying the final solution immediately.
4. Run the verification command.
5. Record what happened.
6. Explain why it happened in your own words.
7. Mark the checkpoint only after you can reproduce the result.

### Progress Symbols

- `[ ]` Not started
- `[-]` In progress
- `[x]` Completed
- `[!]` Needs review

---

# Learning Contract

By completing this workbook, I will be able to:

- [ ] Explain how JavaScript executes code.
- [ ] Explain closures and lexical scope.
- [ ] Predict common `this` behavior.
- [ ] Explain microtasks and tasks.
- [ ] Coordinate asynchronous operations.
- [ ] Cancel obsolete work.
- [ ] Build pure functions and immutable updates.
- [ ] Build reactive state.
- [ ] Identify memory leaks.
- [ ] Apply debouncing and throttling.
- [ ] Implement retries and circuit breakers.
- [ ] Test failure and cleanup behavior.
- [ ] Design a production-oriented application boundary.

---

# Workspace Setup

## Required Tools

- Node.js 20 or newer
- npm
- A code editor
- A terminal
- Git recommended

## Verification

```bash
node --version
npm --version
```

Record your versions:

```text
Node.js: ______________________________

npm: __________________________________
```

## Project Folder

```text
runtime-monitor/
├── src/
├── test/
├── public/
├── package.json
└── README.md
```

Create the project:

```bash
mkdir runtime-monitor
cd runtime-monitor
npm init -y
mkdir -p src test public
```

---

# Primer 1: JavaScript Essentials

## Checkpoint 1.1: Variables

### Task

Create variables for:

- Application name.
- Current retry attempt.
- A service configuration object.

Requirements:

- Use `const` for values that are not reassigned.
- Use `let` for the retry attempt.
- Explain why `const` does not make an object deeply immutable.

### Your Code

```js
// Write your implementation here.
```

### Verification

```bash
node src/primer-1-variables.js
```

### Reflection

Why can this work?

```js
const service = {
  status: "loading"
};

service.status = "healthy";
```

Answer:

```text
____________________________________________________________

____________________________________________________________
```

---

## Checkpoint 1.2: Pure Service Selector

### Task

Write:

```js
function selectHealthyServices(services) {
  // return only services whose status is "healthy"
}
```

Input:

```js
const services = [
  { name: "metrics", status: "healthy" },
  { name: "health", status: "degraded" },
  { name: "activity", status: "healthy" }
];
```

Expected result:

```js
[
  { name: "metrics", status: "healthy" },
  { name: "activity", status: "healthy" }
]
```

### Your Code

```js
```

### Verification

```bash
node src/primer-1-selectors.js
```

### Reflection

What makes this function pure?

```text
____________________________________________________________

____________________________________________________________
```

---

## Checkpoint 1.3: Immutable State Update

### Task

Write:

```js
function updateServiceStatus(
  state,
  serviceName,
  nextStatus
) {
  // return a new state
}
```

The original state must not change.

### Starting State

```js
const state = {
  services: {
    metrics: {
      status: "loading"
    }
  }
};
```

### Verification Requirements

- [ ] The returned state has the new status.
- [ ] The original state still says `"loading"`.
- [ ] The root object is a different reference.
- [ ] The changed service is a different reference.

### Your Code

```js
```

---

## Primer 1 Review

Explain each term:

| Term | Your explanation |
|---|---|
| Binding | |
| Primitive | |
| Object reference | |
| Pure function | |
| Mutation | |
| Module | |

---

# Primer 2: Modern JavaScript Syntax

## Checkpoint 2.1: Destructuring

### Task

Extract these values:

```js
const service = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42
};
```

Create variables named:

```text
serviceName
serviceStatus
latency
```

### Your Code

```js
```

---

## Checkpoint 2.2: Nullish Defaults

### Task

Implement:

```js
function getTimeout(configuration) {
  // return configured timeout or 5000
}
```

These values must behave as follows:

| Input | Expected |
|---|---:|
| `{ timeout: 2000 }` | `2000` |
| `{ timeout: 0 }` | `0` |
| `{}` | `5000` |
| `{ timeout: null }` | `5000` |

### Your Code

```js
```

### Reflection

Why is this potentially incorrect?

```js
const timeout = configuration.timeout || 5000;
```

```text
____________________________________________________________

____________________________________________________________
```

---

## Checkpoint 2.3: Private Class State

### Task

Create a `RequestCounter` class with:

- Private successful-request count.
- Private failed-request count.
- `recordSuccess()`.
- `recordFailure()`.
- `snapshot()`.

Expected result:

```js
{
  successfulRequests: 2,
  failedRequests: 1,
  totalRequests: 3
}
```

### Your Code

```js
```

### Verification

```bash
node src/primer-2-counter.js
```

---

# Primer 3: Node.js and Project Tooling

## Checkpoint 3.1: npm Scripts

Add these scripts:

```json
{
  "scripts": {
    "start": "node src/index.js",
    "test": "node --test",
    "dev": "node --watch src/index.js"
  }
}
```

### Verification

```bash
npm run
```

Record the available scripts:

```text
____________________________________________________________
```

---

## Checkpoint 3.2: Configuration Loader

### Task

Read and validate:

- `APP_ENV`
- `PORT`
- `REQUEST_TIMEOUT_MS`

Requirements:

- Use defaults.
- Convert numeric strings to numbers.
- Reject invalid ports.
- Return a frozen configuration object.

### Your Code

```js
```

### Verification

```bash
APP_ENV=production PORT=4000 REQUEST_TIMEOUT_MS=2000 node src/configuration.js
```

Expected:

```js
{
  appEnvironment: "production",
  port: 4000,
  requestTimeoutMilliseconds: 2000
}
```

---

## Checkpoint 3.3: Health Server

### Task

Create an HTTP server with:

```text
GET /live  → 200 {"status":"alive"}
GET /ready → 200 {"status":"ready"}
other      → 404
```

### Your Code

```js
```

### Verification

```bash
node src/server.js
```

In another terminal:

```bash
curl -i http://localhost:3000/live
curl -i http://localhost:3000/ready
curl -i http://localhost:3000/missing
```

---

# Primer 4: Asynchronous Foundations

## Checkpoint 4.1: Promise Delay

### Task

Implement:

```js
function delay(milliseconds, value) {
  // return a promise
}
```

### Verification

```js
console.log(await delay(25, "done"));
```

Expected:

```text
done
```

---

## Checkpoint 4.2: Sequential Versus Concurrent Work

### Task

Create three operations:

```text
metrics: 40 ms
health: 20 ms
activity: 30 ms
```

Measure:

1. Sequential execution.
2. `Promise.all()` execution.

Record your results:

```text
Sequential: __________ ms

Concurrent: __________ ms
```

### Reflection

Why is concurrent execution faster for independent operations?

```text
____________________________________________________________

____________________________________________________________
```

---

## Checkpoint 4.3: Partial Results

### Task

Use `Promise.allSettled()` with:

- Metrics succeeds.
- Health fails.
- Activity succeeds.

Create a result with this structure:

```js
{
  metrics: {
    status: "available",
    data: {}
  },
  health: {
    status: "unavailable",
    error: "..."
  },
  activity: {
    status: "available",
    data: {}
  }
}
```

### Your Code

```js
```

---

## Checkpoint 4.4: Cancellation

### Task

Create a cancellable delay:

```js
function cancellableDelay(
  milliseconds,
  value,
  signal
) {}
```

Requirements:

- Resolve if not cancelled.
- Reject with an `AbortError` if cancelled.
- Clear the timer.
- Remove the abort listener.

### Your Code

```js
```

### Verification

```js
const controller = new AbortController();

const operation = cancellableDelay(
  1000,
  "finished",
  controller.signal
);

controller.abort();

await operation;
```

Expected:

```text
AbortError
```

---

# Part 1: Engine Mechanics and Execution Context

## Module 1.1: Execution Context

### Prediction Exercise

What is the output?

```js
console.log("A");

function first() {
  console.log("B");
  second();
  console.log("C");
}

function second() {
  console.log("D");
}

first();

console.log("E");
```

Your prediction:

```text
____________________________________________________________
```

Actual output:

```text
____________________________________________________________
```

Explain the call-stack sequence:

```text
____________________________________________________________

____________________________________________________________
```

---

## Module 1.2: Hoisting

Predict each result.

### Example A

```js
console.log(value);
var value = 10;
```

Result:

```text
____________________________________________________________
```

### Example B

```js
run();

function run() {
  console.log("running");
}
```

Result:

```text
____________________________________________________________
```

### Example C

```js
console.log(value);
let value = 10;
```

Result:

```text
____________________________________________________________
```

### Key Explanation

```text
____________________________________________________________
```

---

## Module 1.3: Lexical Scope

### Task

Explain which variables `inner()` can access.

```js
const applicationName = "Runtime Monitor";

function outer() {
  const outerValue = "outer";

  function inner() {
    const innerValue = "inner";

    return {
      applicationName,
      outerValue,
      innerValue
    };
  }

  return inner();
}
```

Answer:

```text
____________________________________________________________

____________________________________________________________
```

---

## Module 1.4: Closures

### Task

Implement a private counter factory.

Requirements:

```js
const first = createCounter();
const second = createCounter();

first.increment();
first.increment();
second.increment();
```

Expected:

```text
first: 2
second: 1
```

### Your Code

```js
```

### Reflection

Where is the counter value stored?

```text
____________________________________________________________
```

---

## Module 1.5: Closure Memory

### Task

Identify the retained object.

```js
const registry = new Set();

function register() {
  const largePayload = createLargePayload();

  const callback = () => largePayload.length;

  registry.add(callback);
}
```

Answer:

```text
What retains the callback?

____________________________________________________________

What does the callback retain?

____________________________________________________________

How would you release it?

____________________________________________________________
```

---

## Module 1.6: `this` Binding

For each expression, identify the binding rule.

| Expression | Binding |
|---|---|
| `method()` | |
| `object.method()` | |
| `method.call(object)` | |
| `method.apply(object, args)` | |
| `method.bind(object)()` | |
| `new Constructor()` | |
| Arrow function | |

---

## Module 1.7: Method Extraction

### Task

Fix this code in two different ways:

```js
const service = {
  name: "metrics",

  describe() {
    return this.name;
  }
};

const callback = service.describe;

console.log(callback());
```

Solution A using `bind()`:

```js
```

Solution B avoiding dynamic `this`:

```js
```

---

# Part 2: Microtasks, Macrotasks, and Concurrency

## Module 2.1: Event-Loop Prediction

Predict the output:

```js
console.log("A");

setTimeout(() => {
  console.log("B");
}, 0);

Promise.resolve().then(() => {
  console.log("C");
});

queueMicrotask(() => {
  console.log("D");
});

console.log("E");
```

Prediction:

```text
____________________________________________________________
```

Actual output:

```text
____________________________________________________________
```

Explanation:

```text
____________________________________________________________
```

---

## Module 2.2: Nested Microtasks

What is the order?

```js
queueMicrotask(() => {
  console.log("A");

  queueMicrotask(() => {
    console.log("B");
  });
});

setTimeout(() => {
  console.log("C");
}, 0);
```

Answer:

```text
____________________________________________________________
```

---

## Module 2.3: Microtask Starvation

### Task

Write a bounded microtask chain that schedules 10,000 microtasks.

Then schedule a timer and observe when it runs.

### Your Code

```js
```

### Reflection

Why can an unbounded microtask chain harm responsiveness?

```text
____________________________________________________________

____________________________________________________________
```

---

## Module 2.4: Promise Combinator Selection

Choose the correct API.

| Requirement | API |
|---|---|
| Every service is required | |
| Preserve successful and failed panels | |
| First result, success or failure | |
| First successful replica | |

---

## Module 2.5: Latest Request Wins

### Task

Build a search manager that:

- Aborts the previous search.
- Starts the new search.
- Displays only the latest result.
- Ignores expected cancellation.

### Pseudocode

```js
function createSearchManager() {
  let activeController;

  return {
    async search(query) {
      // implement
    }
  };
}
```

### Verification

Start:

```text
j
javascript
```

Expected:

```text
first request: cancelled
second request: displayed
```

---

## Module 2.6: Concurrency Limit

### Task

Create a limiter allowing only two active operations.

```js
const limiter = createConcurrencyLimiter(2);
```

Schedule four operations and record:

```text
Maximum simultaneous operations: __________
```

Expected:

```text
2
```

---

# Part 3: Functional Programming and Reactive Patterns

## Module 3.1: Pure Function Identification

Classify each function as pure or impure.

### Function A

```js
function add(first, second) {
  return first + second;
}
```

Answer:

```text
____________________________________________________________
```

### Function B

```js
let total = 0;

function addToTotal(value) {
  total += value;
  return total;
}
```

Answer:

```text
____________________________________________________________
```

### Function C

```js
function formatService(service) {
  return `${service.name}: ${service.status}`;
}
```

Answer:

```text
____________________________________________________________
```

### Function D

```js
function logService(service) {
  console.log(service);
}
```

Answer:

```text
____________________________________________________________
```

---

## Module 3.2: Function Composition

### Task

Create:

```js
trim
toLowerCase
replaceSpaces
addPrefix
```

Compose them into:

```text
service:metrics-api
```

Input:

```text
"  Metrics API  "
```

### Your Code

```js
```

---

## Module 3.3: Currying

### Task

Curry this function:

```js
function createUrl(baseUrl, path, query) {
  // implement
}
```

Expected use:

```js
const withBase =
  curriedCreateUrl("https://api.example.test");

const withPath =
  withBase("metrics");

const url = withPath({
  limit: 10
});
```

Expected:

```text
https://api.example.test/metrics?limit=10
```

---

## Module 3.4: Immutable State

### Task

Write an immutable update for:

```js
const state = {
  services: {
    metrics: {
      status: "loading",
      latency: 0
    }
  }
};
```

Change:

```text
status → healthy
latency → 42
```

Verify:

- [ ] Original root is unchanged.
- [ ] Original service is unchanged.
- [ ] New root exists.
- [ ] New metrics service exists.

---

## Module 3.5: Proxy Validation

### Task

Create a proxy that validates:

```text
status: loading | healthy | degraded | unavailable
latency: non-negative finite number
```

Reject:

```js
service.status = "unknown";
service.latency = -1;
```

### Your Code

```js
```

---

## Module 3.6: Reactive State

### Task

Create:

```js
const state = createReactiveState({
  status: "idle"
});

const unsubscribe = state.subscribe((change) => {
  console.log(change);
});
```

Requirements:

- Notify on changed values.
- Do not notify identical values.
- Return an unsubscribe function.
- Isolate subscriber errors.

### Verification Table

| Action | Should notify? |
|---|---:|
| `state.status = "loading"` | |
| `state.status = "loading"` | |
| `unsubscribe()` | |
| `state.status = "healthy"` | |

---

# Part 4: Performance, Memory, and Production Architecture

## Module 4.1: Memory Ownership

For each resource, identify the owner and cleanup action.

| Resource | Owner | Cleanup |
|---|---|---|
| `setInterval()` | | |
| Event listener | | |
| Subscription | | |
| Worker | | |
| HTTP server | | |
| Cache entry | | |

---

## Module 4.2: Debounce or Throttle?

Choose the correct technique.

| Scenario | Choice |
|---|---|
| Search after typing stops | |
| Scroll position reporting | |
| Autosave after a pause | |
| Pointer movement updates | |
| Group several state changes | |

---

## Module 4.3: Debounce Implementation

### Task

Implement:

```js
const saveSearch = debounce(
  save,
  300
);
```

Requirements:

- Only the latest call runs.
- A pending call can be cancelled.
- Arguments are preserved.
- `this` behavior is deliberate.

### Verification

Call:

```js
saveSearch("j");
saveSearch("ja");
saveSearch("javascript");
```

Expected save:

```text
javascript
```

---

## Module 4.4: Throttle Implementation

### Task

Implement a throttle that allows execution at most once every 100 milliseconds.

Record:

```text
Calls received: __________

Calls executed: __________
```

Explain why throttling is suitable for scroll events:

```text
____________________________________________________________
```

---

## Module 4.5: Retry Policy

### Task

Design a retry policy for:

```text
GET /metrics
```

Requirements:

- Maximum attempts: 3.
- Base delay: 100 ms.
- Exponential backoff.
- Jitter.
- Retry timeouts and 5xx errors.
- Do not retry validation errors.

### Policy

```js
function isRetryable(error) {
  // implement
}
```

### Reflection

Why is retrying a non-idempotent payment request more dangerous?

```text
____________________________________________________________

____________________________________________________________
```

---

## Module 4.6: Circuit Breaker

### Task

Implement these states:

```text
CLOSED
OPEN
HALF_OPEN
```

State transitions:

```text
CLOSED --threshold--> OPEN
OPEN --cooldown--> HALF_OPEN
HALF_OPEN --success--> CLOSED
HALF_OPEN --failure--> OPEN
```

### Verification Table

| Event | Expected state |
|---|---|
| Initial | |
| First failure | |
| Threshold reached | |
| Request while open | |
| Cooldown elapsed | |
| Probe succeeds | |

---

## Module 4.7: Error Boundary

### Task

Create an error boundary that:

- Logs structured information.
- Reports the error.
- Preserves the original error.
- Handles report failure.
- Distinguishes `AbortError`.

### Your Code

```js
```

---

## Module 4.8: Graceful Shutdown

### Task

Create a shutdown coordinator that:

- Stops accepting work.
- Aborts active operations.
- Clears timers.
- Removes subscriptions.
- Closes the HTTP server.
- Has a shutdown deadline.

### Shutdown Order

```text
1. ______________________________________
2. ______________________________________
3. ______________________________________
4. ______________________________________
5. ______________________________________
```

---

# Capstone Project: Runtime Monitor

## Capstone Goal

Build a dashboard that loads service information concurrently and remains responsive when dependencies fail.

## Required Features

- [ ] Three independent services.
- [ ] Concurrent loading.
- [ ] Partial results.
- [ ] Cancellation.
- [ ] Request timeout.
- [ ] Retry policy.
- [ ] Circuit breaker.
- [ ] Reactive state.
- [ ] Pure selectors.
- [ ] Debounced search.
- [ ] Throttled telemetry.
- [ ] Batched rendering.
- [ ] Structured logging.
- [ ] Health endpoints.
- [ ] Graceful shutdown.
- [ ] Automated tests.

---

## Capstone State Shape

```js
const initialState = {
  status: "idle",
  isRefreshing: false,
  lastUpdated: null,
  services: {},
  notifications: [],
  error: null
};
```

---

## Capstone Service Shape

```js
{
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42,
  data: {
    requestsPerSecond: 125,
    errorRate: 0.01
  },
  loadedAt: "2026-01-01T00:00:00.000Z"
}
```

---

## Capstone Error Shape

```js
{
  name: "TimeoutError",
  code: "TIMEOUT",
  retryable: true,
  service: "metrics",
  message: "request timed out"
}
```

---

## Capstone Architecture

```text
Browser UI
    │
    ▼
Dashboard workflow
    │
    ▼
Reactive store
    │
    ▼
Selectors
    │
    ▼
Resilient services
    │
    ├── timeout
    ├── retry
    ├── circuit breaker
    └── request client
    │
    ▼
External dependencies
```

---

## Capstone Verification

### Success Scenario

- [ ] All services respond.
- [ ] Dashboard shows healthy data.
- [ ] State becomes ready.
- [ ] Metrics are logged.

### Partial Failure Scenario

- [ ] One service fails.
- [ ] Other panels remain visible.
- [ ] Failed panel says unavailable.
- [ ] Failure is measured.

### Timeout Scenario

- [ ] Slow service times out.
- [ ] Underlying operation is cancelled.
- [ ] Timeout is distinguished from cancellation.

### Retry Scenario

- [ ] Temporary failure retries.
- [ ] Retry delay increases.
- [ ] Retry stops after success or exhaustion.

### Circuit Scenario

- [ ] Repeated failures open the circuit.
- [ ] Requests fail fast while open.
- [ ] Half-open probe tests recovery.
- [ ] Successful probe closes the circuit.

### Cancellation Scenario

- [ ] Starting a new refresh cancels the old refresh.
- [ ] Old results cannot overwrite new results.
- [ ] Cancellation is not reported as an outage.

### Shutdown Scenario

- [ ] Server stops accepting work.
- [ ] Active refreshes are cancelled.
- [ ] Timers are cleared.
- [ ] Subscribers are removed.
- [ ] Process exits cleanly.

---

# Testing Workbook

## Unit-Test Matrix

| Module | Success | Failure | Cancellation | Cleanup |
|---|---:|---:|---:|---:|
| Validation | [ ] | [ ] | N/A | N/A |
| Selectors | [ ] | [ ] | N/A | N/A |
| State transitions | [ ] | [ ] | N/A | [ ] |
| Request client | [ ] | [ ] | [ ] | [ ] |
| Retry | [ ] | [ ] | [ ] | N/A |
| Circuit breaker | [ ] | [ ] | N/A | N/A |
| Debounce | [ ] | N/A | [ ] | [ ] |
| Reactive state | [ ] | [ ] | N/A | [ ] |
| Error boundary | [ ] | [ ] | [ ] | [ ] |
| Shutdown | [ ] | [ ] | [ ] | [ ] |

---

# Debugging Log

Use this page whenever an experiment behaves differently from your prediction.

## Experiment

```text
____________________________________________________________
```

## Expected Behavior

```text
____________________________________________________________
```

## Actual Behavior

```text
____________________________________________________________
```

## Difference

```text
____________________________________________________________
```

## Explanation

```text
____________________________________________________________

____________________________________________________________
```

## Fix or New Understanding

```text
____________________________________________________________

____________________________________________________________
```

---

# Architecture Review Worksheet

## Responsibility Review

For each module, answer:

| Question | Answer |
|---|---|
| What does this module own? | |
| What does it not own? | |
| What dependencies does it need? | |
| Can it be tested without the network? | |
| Can its resources be cleaned up? | |
| What errors can it produce? | |
| What metrics should it emit? | |

---

# Production Readiness Worksheet

## Correctness

- [ ] Success behavior verified.
- [ ] Invalid input verified.
- [ ] Partial failure verified.
- [ ] Cancellation verified.
- [ ] Timeout verified.
- [ ] Cleanup verified.

## Security

- [ ] No secrets committed.
- [ ] Logs redacted.
- [ ] External data validated.
- [ ] File paths protected.
- [ ] Browser boundaries reviewed.

## Performance

- [ ] Main workflow measured.
- [ ] Tail latency considered.
- [ ] Memory growth checked.
- [ ] Event-loop delay checked.
- [ ] Rendering batched.
- [ ] Queues bounded.

## Reliability

- [ ] Retry policy defined.
- [ ] Idempotency reviewed.
- [ ] Backoff and jitter added.
- [ ] Circuit breaker tested.
- [ ] Fallback behavior documented.
- [ ] Shutdown tested.

## Operations

- [ ] Liveness endpoint exists.
- [ ] Readiness endpoint exists.
- [ ] Structured logs exist.
- [ ] Metrics exist.
- [ ] Alerts exist.
- [ ] Runbook exists.
- [ ] Rollback exists.

---

# Final Assessment

## Explain Without Looking It Up

### 1. What is a closure?

```text
____________________________________________________________

____________________________________________________________
```

### 2. Why do promise callbacks run before timers?

```text
____________________________________________________________

____________________________________________________________
```

### 3. When should you use `Promise.allSettled()`?

```text
____________________________________________________________
```

### 4. What does `AbortController` do?

```text
____________________________________________________________
```

### 5. What is a pure function?

```text
____________________________________________________________
```

### 6. Why can a closure cause a memory leak?

```text
____________________________________________________________
```

### 7. When should you debounce?

```text
____________________________________________________________
```

### 8. When should you throttle?

```text
____________________________________________________________
```

### 9. Why should retries use backoff and jitter?

```text
____________________________________________________________

____________________________________________________________
```

### 10. What is the purpose of a circuit breaker?

```text
____________________________________________________________

____________________________________________________________
```

### 11. What is graceful shutdown?

```text
____________________________________________________________

____________________________________________________________
```

---

# Final Student Submission Checklist

- [ ] Source code submitted.
- [ ] Tests submitted.
- [ ] Capstone runs locally.
- [ ] README included.
- [ ] Environment template included.
- [ ] No secrets committed.
- [ ] Failure scenarios demonstrated.
- [ ] Cancellation demonstrated.
- [ ] Performance measurements included.
- [ ] Architecture diagram included.
- [ ] Production-readiness checklist completed.
- [ ] Known limitations documented.

---

# Final Reflection

## Most Valuable Concept

```text
____________________________________________________________

____________________________________________________________
```

## Most Difficult Concept

```text
____________________________________________________________

____________________________________________________________
```

## Concept Requiring More Practice

```text
____________________________________________________________

____________________________________________________________
```

## One Production Problem I Can Now Diagnose

```text
____________________________________________________________

____________________________________________________________
```

## One Architectural Pattern I Will Reuse

```text
____________________________________________________________

____________________________________________________________
```

## Final Statement

Complete this sentence:

> I now understand advanced JavaScript as a system of...

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# Completion Certificate

This certifies that:

```text
____________________________________________________________
```

completed the **Advanced JavaScript: Runtime Engines, Optimization & Architecture** student workbook.

Date:

```text
____________________________________________________________
```

Instructor or mentor:

```text
____________________________________________________________
```

Signature:

```text
____________________________________________________________
```
