# Advanced JavaScript Student Notes

## Runtime Engines, Optimization & Architecture

**Student:** ____________________________________  
**Course start date:** ___________________________  
**Course completion date:** ______________________  

---

# How to Use These Notes

For each topic, record:

1. **Definition:** What does the concept mean?
2. **Mechanism:** How does it work?
3. **Example:** What code demonstrates it?
4. **Failure mode:** What can go wrong?
5. **Architecture use:** Where would you use it in a real application?

Use the following notation:

```text
?  Question to investigate
!  Important rule
→  Cause and effect
⚠  Common pitfall
✓  Verified behavior
```

---

# 1. Series Architecture

## Final Application

The capstone application is:

```text
Runtime Monitor
```

Its main responsibilities are:

- [ ] Load service data.
- [ ] Coordinate asynchronous requests.
- [ ] Cancel obsolete work.
- [ ] Retry temporary failures.
- [ ] Stop calling unhealthy services.
- [ ] Preserve partial results.
- [ ] Manage reactive state.
- [ ] Render dashboard data.
- [ ] Measure performance.
- [ ] Shut down safely.

## Final Architecture

```text
Browser UI
    │
    ▼
Reactive state
    │
    ▼
Application workflow
    │
    ▼
Resilient services
    │
    ├── timeout
    ├── retry
    ├── circuit breaker
    └── concurrency control
    │
    ▼
External dependencies
```

### My Architecture Notes

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```

---

# 2. JavaScript Runtime Foundations

## JavaScript Engine

A JavaScript engine:

- Parses source code.
- Creates execution contexts.
- Executes instructions.
- Manages objects.
- Performs garbage collection.
- Optimizes frequently executed code.

Examples:

- V8.
- SpiderMonkey.
- JavaScriptCore.

### Notes

```text
____________________________________________________________

____________________________________________________________
```

---

## Runtime

A runtime includes:

```text
JavaScript engine
+ host APIs
+ scheduling
+ filesystem/network/process capabilities
```

### Browser Runtime Provides

- `window`
- `document`
- DOM
- Rendering
- Browser events
- Browser storage
- `requestAnimationFrame()`

### Node.js Runtime Provides

- `process`
- Filesystem
- HTTP server APIs
- Streams
- Worker threads
- Process signals
- `node:test`

### Notes

```text
____________________________________________________________
```

---

## Execution Context

An execution context contains information such as:

- Variables.
- Function parameters.
- Outer-scope reference.
- `this` binding.
- Execution state.
- Return location.

### Types

- Global execution context.
- Function execution context.
- `eval` execution context.

### Notes

```text
Definition:

____________________________________________________________

What it contains:

____________________________________________________________

Why it matters:

____________________________________________________________
```

---

## Call Stack

The call stack tracks active function calls.

```text
third()
second()
first()
global code
```

### Important Rule

The current synchronous function must finish before JavaScript returns to the function underneath it.

### Notes

```text
____________________________________________________________

____________________________________________________________
```

---

## Creation and Execution Phases

### Creation Phase

The engine prepares:

- Variable bindings.
- Function declarations.
- Scope references.
- `this` behavior.

### Execution Phase

The engine:

- Evaluates expressions.
- Performs assignments.
- Calls functions.
- Executes control flow.
- Returns or throws.

### Notes

```text
____________________________________________________________
```

---

# 3. Scope, Hoisting, and Closures

## Lexical Scope

Lexical scope is determined by where code is written.

Lookup usually proceeds outward:

```text
current function
      │
      ▼
outer function
      │
      ▼
module scope
      │
      ▼
global scope
```

### Notes

```text
____________________________________________________________

____________________________________________________________
```

---

## Hoisting Reference

| Declaration | Binding created early? | Initial value | TDZ? |
|---|---:|---|---:|
| Function declaration | Yes | Function | No |
| `var` | Yes | `undefined` | No |
| `let` | Yes | Uninitialized | Yes |
| `const` | Yes | Uninitialized | Yes |
| Class | Yes | Uninitialized | Yes |

### Important Rule

Hoisting does not literally move source lines. It describes how declarations are initialized during context creation.

### Notes

```text
____________________________________________________________
```

---

## Temporal Dead Zone

The TDZ is the period between entering a scope and reaching a `let`, `const`, or class declaration.

```js
console.log(value); // ReferenceError
const value = 10;
```

### Notes

```text
____________________________________________________________
```

---

## Closure

A closure is:

```text
function + access to its lexical environment
```

Example:

```js
function createCounter() {
  let count = 0;

  return function increment() {
    count += 1;
    return count;
  };
}
```

### Closures Are Useful For

- Private state.
- Factory functions.
- Callbacks.
- Memoization.
- Encapsulation.
- Configured functions.

### Closure Memory Risk

```text
long-lived registry
        │
        ▼
callback
        │
        ▼
large closed-over object
```

### Notes

```text
What is retained?

____________________________________________________________

How is cleanup performed?

____________________________________________________________
```

---

# 4. `this` Binding

## Binding Decision Tree

```text
Called with new?
├── Yes → constructor binding
└── No
    call/apply/bind?
    ├── Yes → explicit or hard binding
    └── No
        object.method()?
        ├── Yes → implicit binding
        └── No
            arrow function?
            ├── Yes → lexical this
            └── No → default binding
```

## Reference Table

| Call form | Binding |
|---|---|
| `fn()` | Default |
| `object.fn()` | Implicit |
| `fn.call(object)` | Explicit |
| `fn.apply(object, args)` | Explicit |
| `fn.bind(object)()` | Hard |
| `new Fn()` | Constructor |
| Arrow function | Lexical |

### Notes

```text
____________________________________________________________

____________________________________________________________
```

---

## Method Extraction

```js
const callback = service.describe;
callback();
```

The call is no longer:

```js
service.describe();
```

Therefore, implicit binding is lost.

### Fixes

```js
const callback = service.describe.bind(service);
```

or:

```js
const callback = () => service.describe();
```

### Notes

```text
____________________________________________________________
```

---

# 5. Event Loop and Scheduling

## Simplified Model

```text
current synchronous code
        │
        ▼
drain microtasks
        │
        ▼
run a later task
        │
        ▼
drain new microtasks
        │
        ▼
continue
```

## Microtasks

Examples:

- Promise handlers.
- `queueMicrotask()`.
- Browser mutation observers.

## Tasks

Examples:

- `setTimeout()`.
- Some I/O callbacks.
- User events.
- Message events.

### Important Rule

Microtasks run after the current synchronous code and before later tasks.

### Notes

```text
____________________________________________________________

____________________________________________________________
```

---

## Event-Loop Prediction

Predict:

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

Expected order:

```text
____________________________________________________________
```

Explanation:

```text
____________________________________________________________
```

---

## Microtask Starvation

A microtask that continually schedules another microtask can prevent timers and I/O from running.

```js
function loop() {
  queueMicrotask(loop);
}
```

### Prevention

Process work in batches and yield:

```js
await new Promise((resolve) => {
  setTimeout(resolve, 0);
});
```

### Notes

```text
____________________________________________________________
```

---

# 6. Promises and Async Functions

## Promise States

```text
pending
   │
   ├── fulfilled
   └── rejected
```

A promise settles only once.

### Notes

```text
____________________________________________________________
```

---

## Promise Methods

| Method | Purpose |
|---|---|
| `.then()` | Handle successful result |
| `.catch()` | Handle rejection |
| `.finally()` | Always perform cleanup |

### Important Rule

Returning from `.then()` passes the value to the next promise.

Throwing from `.then()` rejects the next promise.

---

## `async` and `await`

An `async` function always returns a promise.

```js
async function getValue() {
  return 42;
}
```

`await` pauses only the current async function. It does not block the entire runtime.

### Notes

```text
____________________________________________________________
```

---

## Promise Combinators

| Requirement | API |
|---|---|
| All operations required | `Promise.all()` |
| Preserve every outcome | `Promise.allSettled()` |
| First settlement wins | `Promise.race()` |
| First success wins | `Promise.any()` |

### Selection Notes

```text
Promise.all:

____________________________________________________________

Promise.allSettled:

____________________________________________________________

Promise.race:

____________________________________________________________

Promise.any:

____________________________________________________________
```

---

# 7. Cancellation and Timeouts

## AbortController Model

```text
caller creates controller
        │
        ▼
caller passes signal
        │
        ▼
operation listens for abort
        │
        ▼
caller calls controller.abort()
```

### Important Properties

- A controller is one-shot.
- A signal can be passed through multiple layers.
- Cancellation should usually be distinguishable from failure.
- Abort listeners must be removed.
- Timers must be cleared.

### Notes

```text
____________________________________________________________
```

---

## Timeout Design

A production timeout should:

1. Set a deadline.
2. Abort the underlying operation.
3. Reject with a meaningful error.
4. Clear the timer.
5. Remove listeners.

### Notes

```text
____________________________________________________________
```

---

## Latest-Request-Wins Pattern

```text
new request starts
        │
        ▼
abort previous controller
        │
        ▼
create new controller
        │
        ▼
publish only newest result
```

### Use Cases

- Search.
- Filters.
- Route changes.
- Refresh buttons.
- Autocomplete.

---

# 8. Functional Programming

## Pure Function

A pure function:

1. Produces the same output for the same input.
2. Does not change external state.

```js
function add(first, second) {
  return first + second;
}
```

### Notes

```text
____________________________________________________________
```

---

## Side Effect

Examples:

- Logging.
- Network requests.
- DOM updates.
- Database writes.
- Reading current time.
- Mutating global state.

### Architecture

```text
input
  │
  ▼
pure transformation
  │
  ▼
side effect at boundary
```

### Notes

```text
____________________________________________________________
```

---

## Immutability

Immutable updates replace changed data instead of modifying the original.

```js
const nextState = {
  ...state,
  status: "healthy"
};
```

For nested updates:

```js
const nextState = {
  ...state,
  services: {
    ...state.services,
    metrics: {
      ...state.services.metrics,
      status: "healthy"
    }
  }
};
```

### Notes

```text
____________________________________________________________
```

---

## Function Composition

Composition connects functions:

```text
input
  → trim
  → lowercase
  → normalize
  → output
```

### `pipe`

Runs left to right.

### `compose`

Usually runs right to left.

### Notes

```text
____________________________________________________________
```

---

# 9. Currying and Partial Application

## Currying

Transforms:

```js
f(a, b, c)
```

into:

```js
f(a)(b)(c)
```

## Partial Application

Pre-fills selected arguments:

```js
const specialized = partial(
  generalFunction,
  fixedValue
);
```

### Difference

```text
currying:
  one function → sequence of calls

partial application:
  general function → specialized function
```

### Notes

```text
____________________________________________________________
```

---

# 10. Proxy and Reflect

## Proxy

A proxy intercepts operations on a target object.

Common traps:

| Trap | Operation |
|---|---|
| `get` | Property read |
| `set` | Property assignment |
| `has` | `in` operator |
| `deleteProperty` | Property deletion |
| `ownKeys` | Key enumeration |
| `apply` | Function call |
| `construct` | `new` |

## Reflect

Use `Reflect` to delegate normal object behavior:

```js
return Reflect.set(
  target,
  property,
  value,
  receiver
);
```

### Notes

```text
____________________________________________________________
```

---

## Reactive State

A basic reactive state system contains:

```text
state
  │
  ▼
change detection
  │
  ▼
subscriber notification
  │
  ▼
render or side effect
```

### Required Lifecycle

```text
subscribe → use → unsubscribe
```

### Notes

```text
____________________________________________________________
```

---

# 11. Memory and Garbage Collection

## Reachability

An object can be collected when no live root can reach it.

```text
global root
    │
    ▼
registry
    │
    ▼
callback
    │
    ▼
large object
```

If the registry remains alive, the entire chain remains reachable.

### Notes

```text
____________________________________________________________
```

---

## Common Memory-Leak Sources

- [ ] Forgotten event listeners.
- [ ] Forgotten timers.
- [ ] Long-lived closures.
- [ ] Unbounded arrays.
- [ ] Unbounded caches.
- [ ] Unremoved subscriptions.
- [ ] Detached DOM references.
- [ ] Active workers.
- [ ] Unclosed streams.

### Cleanup Contract

```js
const unsubscribe = subscribe(listener);

// later
unsubscribe();
```

### Notes

```text
____________________________________________________________
```

---

# 12. Performance

## Debounce

Waits until activity stops.

```text
input input input input
                    │
                    ▼
                 execute
```

Use for:

- Search.
- Autosave.
- Validation.
- Resize completion.

## Throttle

Limits execution frequency.

```text
input input input input input
  execute       execute
```

Use for:

- Scroll.
- Pointer movement.
- Telemetry.
- Progress updates.

## Batching

Groups several changes into one update.

### Notes

```text
Debounce:

____________________________________________________________

Throttle:

____________________________________________________________

Batching:

____________________________________________________________
```

---

## Performance Measurement

Measure before optimizing.

Useful measurements:

- Latency.
- CPU time.
- Heap usage.
- Event-loop delay.
- Render duration.
- Retry count.
- Queue depth.
- p95 and p99 latency.

### Notes

```text
____________________________________________________________
```

---

# 13. Retry and Backoff

## Retry Decision

Before retrying, ask:

1. Is the error temporary?
2. Is the operation safe to repeat?
3. Is the caller still waiting?
4. Are attempts bounded?
5. Is backoff applied?
6. Is cancellation supported?

### Notes

```text
____________________________________________________________
```

---

## Exponential Backoff

```text
attempt 1 → 100 ms
attempt 2 → 200 ms
attempt 3 → 400 ms
attempt 4 → 800 ms
```

## Jitter

Jitter adds randomness to prevent synchronized retry storms.

## Idempotency

An operation is idempotent when repeating it produces the same intended final state.

### Notes

```text
____________________________________________________________
```

---

# 14. Circuit Breakers

## States

### CLOSED

Requests flow normally.

### OPEN

Requests fail immediately.

### HALF_OPEN

A controlled probe tests recovery.

```text
CLOSED
  │ threshold reached
  ▼
OPEN
  │ cooldown elapsed
  ▼
HALF_OPEN
  ├── success → CLOSED
  └── failure → OPEN
```

### Notes

```text
____________________________________________________________
```

---

## Circuit-Breaker Configuration

| Setting | Value |
|---|---:|
| Failure threshold | |
| Reset timeout | |
| Failure types counted | |
| Half-open probe policy | |
| Open-state response | |

---

# 15. Bulkheads and Capacity

## Bulkhead

A bulkhead limits how much capacity one workload can consume.

Examples:

- Maximum concurrent requests.
- Maximum queue size.
- Maximum worker count.
- Maximum cache size.

### Notes

```text
____________________________________________________________
```

---

## Concurrency Versus Rate Limit

| Control | Limits |
|---|---|
| Concurrency limit | Simultaneous active work |
| Rate limit | Work started over time |
| Queue limit | Waiting work |
| Cache limit | Retained data |

---

# 16. Error Boundaries

## Error Categories

| Category | Typical response |
|---|---|
| Validation error | Show actionable input error |
| Authentication error | Request authentication |
| Permission error | Deny access |
| Timeout | Retry or fallback |
| Cancellation | Stop quietly |
| Dependency failure | Retry, breaker, or fallback |
| Programming error | Log, report, fix |
| Unknown error | Preserve context and fail safely |

### Notes

```text
____________________________________________________________
```

---

## Error Boundary Responsibilities

- [ ] Catch errors at the correct boundary.
- [ ] Add context.
- [ ] Preserve the original error.
- [ ] Report safely.
- [ ] Avoid exposing secrets.
- [ ] Distinguish cancellation.
- [ ] Return a controlled fallback.
- [ ] Avoid swallowing errors.

---

# 17. Graceful Shutdown

## Shutdown Sequence

```text
1. Stop accepting new work.
2. Mark readiness as false.
3. Abort obsolete active operations.
4. Finish or cancel current work.
5. Remove subscriptions.
6. Clear timers.
7. Close servers and connections.
8. Flush important logs.
9. Exit.
```

### Notes

```text
____________________________________________________________
```

---

# 18. Testing

## Test Types

| Test type | Purpose |
|---|---|
| Unit | One function or module |
| Integration | Multiple modules together |
| End-to-end | Complete user workflow |
| Regression | Protect a previous bug fix |
| Performance | Detect measurable slowdown |
| Contract | Verify external interface |

### Notes

```text
____________________________________________________________
```

---

## Arrange, Act, Assert

```text
Arrange
  prepare inputs and dependencies

Act
  execute behavior

Assert
  verify outcome
```

### Notes

```text
____________________________________________________________
```

---

## Test Matrix

| Scenario | Tested? |
|---|---:|
| Success | [ ] |
| Invalid input | [ ] |
| Dependency failure | [ ] |
| Timeout | [ ] |
| Cancellation | [ ] |
| Retry exhaustion | [ ] |
| Circuit open | [ ] |
| Partial result | [ ] |
| Cleanup | [ ] |
| Shutdown | [ ] |

---

# 19. Browser and Node.js

## Shared Logic

Should generally avoid direct use of:

```js
window
document
process
node:fs
```

## Browser Adapter

Owns:

- DOM.
- Rendering.
- User events.
- Browser storage.
- Animation frames.
- Page lifecycle.

## Node.js Adapter

Owns:

- Filesystem.
- HTTP server.
- Process signals.
- Workers.
- Server configuration.
- Shutdown.

### Notes

```text
____________________________________________________________
```

---

# 20. Production Readiness

## Configuration

- [ ] Validated at startup.
- [ ] Defaults documented.
- [ ] Secrets excluded.
- [ ] Numeric values parsed.
- [ ] Bounds enforced.

## Security

- [ ] Inputs validated.
- [ ] Logs redacted.
- [ ] File paths protected.
- [ ] Browser secrets avoided.
- [ ] HTTPS used in production.
- [ ] Dependencies scanned.

## Observability

- [ ] Structured logs.
- [ ] Request identifiers.
- [ ] Latency metrics.
- [ ] Error metrics.
- [ ] Retry metrics.
- [ ] Circuit metrics.
- [ ] Health checks.
- [ ] Alerts.

## Recovery

- [ ] Rollback procedure.
- [ ] Backup procedure.
- [ ] Restore test.
- [ ] Incident runbook.
- [ ] Ownership defined.

---

# 21. Capstone Notes

## Application Name

```text
Runtime Monitor
```

## Service List

```text
1. ______________________________________
2. ______________________________________
3. ______________________________________
```

## State Shape

```js
{
  status: "idle",
  isRefreshing: false,
  lastUpdated: null,
  services: {},
  notifications: [],
  error: null
}
```

## Main API Routes

| Route | Purpose |
|---|---|
| `/live` | |
| `/ready` | |
| `/api/dashboard` | |
| `/api/metrics` | |

## Capstone Dependencies

```text
____________________________________________________________

____________________________________________________________
```

## Failure Policies

| Failure | Policy |
|---|---|
| Temporary service failure | |
| Timeout | |
| Cancellation | |
| Permanent failure | |
| Circuit open | |
| Shutdown | |

---

# 22. Capstone Verification Log

## Server Start

Command:

```bash
npm start
```

Result:

```text
____________________________________________________________
```

## Liveness

Command:

```bash
curl -i http://localhost:3000/live
```

Result:

```text
____________________________________________________________
```

## Readiness

Command:

```bash
curl -i http://localhost:3000/ready
```

Result:

```text
____________________________________________________________
```

## Dashboard API

Command:

```bash
curl -i http://localhost:3000/api/dashboard
```

Result:

```text
____________________________________________________________
```

## Browser

URL:

```text
http://localhost:3000
```

Observations:

```text
____________________________________________________________

____________________________________________________________
```

---

# 23. Failure Testing Notes

## Temporary Failure

Observed behavior:

```text
____________________________________________________________
```

## Timeout

Observed behavior:

```text
____________________________________________________________
```

## Cancellation

Observed behavior:

```text
____________________________________________________________
```

## Circuit Open

Observed behavior:

```text
____________________________________________________________
```

## Graceful Shutdown

Observed behavior:

```text
____________________________________________________________
```

---

# 24. Final Review Questions

## Runtime

What is the difference between the call stack and the event loop?

```text
____________________________________________________________

____________________________________________________________
```

## Closures

Why can a closure both enable encapsulation and retain memory?

```text
____________________________________________________________

____________________________________________________________
```

## Async

Why does `Promise.allSettled()` fit an optional dashboard panel?

```text
____________________________________________________________

____________________________________________________________
```

## Cancellation

Who should own an `AbortController`, and why?

```text
____________________________________________________________

____________________________________________________________
```

## Functional Design

Why are pure functions easier to test?

```text
____________________________________________________________

____________________________________________________________
```

## Reactivity

Why should a subscription return an unsubscribe function?

```text
____________________________________________________________

____________________________________________________________
```

## Resilience

Why should retries use exponential backoff and jitter?

```text
____________________________________________________________

____________________________________________________________
```

## Circuit Breaker

What problem does an open circuit solve?

```text
____________________________________________________________

____________________________________________________________
```

## Production

What is the difference between liveness and readiness?

```text
____________________________________________________________

____________________________________________________________
```

---

# 25. Personal Summary

## Three Concepts I Understand Well

```text
1. ________________________________________________________

2. ________________________________________________________

3. ________________________________________________________
```

## Three Concepts I Need to Practice

```text
1. ________________________________________________________

2. ________________________________________________________

3. ________________________________________________________
```

## One Experiment I Want to Run

```text
____________________________________________________________

____________________________________________________________
```

## One Design Decision I Would Change

```text
____________________________________________________________

____________________________________________________________
```

## One Production Failure I Can Now Diagnose

```text
____________________________________________________________

____________________________________________________________
```

---

# 26. Final Completion Checklist

- [ ] All primer exercises completed.
- [ ] Runtime experiments executed.
- [ ] Event-loop predictions verified.
- [ ] Promise combinators practiced.
- [ ] Cancellation implemented.
- [ ] Reactive state implemented.
- [ ] Memory cleanup verified.
- [ ] Debounce implemented.
- [ ] Throttle implemented.
- [ ] Retry policy implemented.
- [ ] Circuit breaker implemented.
- [ ] Error boundary implemented.
- [ ] Automated tests pass.
- [ ] Capstone server starts.
- [ ] Browser dashboard loads.
- [ ] Failure scenarios tested.
- [ ] Graceful shutdown verified.
- [ ] Production checklist reviewed.

---

# Final Student Statement

Complete the sentence:

> Advanced JavaScript is not only about syntax. It is about controlling...

```text
____________________________________________________________

____________________________________________________________

____________________________________________________________
```
