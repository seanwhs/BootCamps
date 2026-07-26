# Advanced JavaScript Trainer Guide

## Runtime Engines, Optimization & Architecture

This guide helps an instructor deliver the complete series as a practical, code-heavy training program.

It includes:

- Recommended audience.
- Prerequisites.
- Learning outcomes.
- Course formats.
- Session plans.
- Teaching strategies.
- Lab facilitation.
- Common misconceptions.
- Assessment rubrics.
- Capstone evaluation.
- Troubleshooting guidance.
- Instructor preparation checklists.
- Suggested pacing.

---

# 1. Course Overview

## Course Title

**Advanced JavaScript: Runtime Engines, Optimization & Architecture**

## Primary Goal

Enable learners to understand how JavaScript executes internally and apply that knowledge to build maintainable, responsive, testable, and resilient applications.

## Capstone

Learners build **Runtime Monitor**, a dashboard application that includes:

- Concurrent service loading.
- Partial-result handling.
- Cancellation.
- Timeouts.
- Retries.
- Exponential backoff.
- Circuit breakers.
- Reactive state.
- Debounced filtering.
- Batched rendering.
- Structured errors.
- Health endpoints.
- Graceful shutdown.
- Automated tests.

---

# 2. Target Audience

The course is suitable for:

- Junior-to-mid-level JavaScript developers.
- Frontend developers moving toward full-stack development.
- Node.js developers seeking stronger runtime knowledge.
- Developers preparing for senior engineering responsibilities.
- Engineers who understand syntax but struggle with runtime behavior.
- Technical leads who need practical architecture patterns.

---

# 3. Prerequisites

Learners should already understand:

- Basic JavaScript syntax.
- Variables and functions.
- Arrays and objects.
- Basic HTML and browser usage.
- Basic terminal commands.
- Basic Git usage recommended.
- Basic promise awareness helpful but not required if the primers are completed.

## Required Environment

- Node.js 20 or newer.
- npm.
- Code editor.
- Terminal.
- Browser.
- Git recommended.

## Instructor Verification

Before the course begins, ask learners to run:

```bash
node --version
npm --version
```

Record the minimum version:

```text
Node.js 20+
npm compatible with Node.js installation
```

---

# 4. Learning Outcomes

By the end of the course, learners should be able to:

## Runtime

- Explain execution contexts.
- Describe creation and execution phases.
- Explain lexical scope.
- Predict common hoisting behavior.
- Explain closures.
- Identify closure-related memory retention.
- Determine `this` binding from a call site.

## Asynchronous JavaScript

- Explain the call stack and event loop.
- Distinguish microtasks from later tasks.
- Explain why promise handlers run before timers.
- Choose the correct promise combinator.
- Coordinate concurrent operations.
- Implement cancellation with `AbortController`.
- Add cancellation-aware timeouts.

## Functional and Reactive Design

- Write pure functions.
- Separate side effects from transformations.
- Perform immutable updates.
- Compose functions.
- Use currying and partial application appropriately.
- Use `Proxy` and `Reflect`.
- Build reactive state and subscriptions.
- Design unsubscribe behavior.

## Performance and Memory

- Explain reachability and garbage collection.
- Identify common memory leaks.
- Implement resource cleanup.
- Apply debouncing and throttling.
- Batch updates.
- Measure before optimizing.
- Recognize event-loop blocking.

## Resilience

- Classify failures.
- Implement bounded retries.
- Use exponential backoff and jitter.
- Consider idempotency.
- Implement a circuit breaker.
- Add capacity limits.
- Design honest fallbacks.
- Implement graceful shutdown.

## Engineering Practice

- Structure modular JavaScript applications.
- Inject dependencies.
- Test success and failure paths.
- Use structured logging.
- Expose health and readiness endpoints.
- Review production readiness.

---

# 5. Recommended Course Formats

## Intensive Five-Day Format

### Day 1

- Primers review.
- Part 0.
- Part 1.
- Runtime laboratories.

### Day 2

- Part 2.
- Event-loop experiments.
- Promise coordination.
- Cancellation workshop.

### Day 3

- Part 3.
- Functional transformations.
- Reactive state.
- Store implementation.

### Day 4

- Part 4.
- Memory and performance.
- Retry and circuit breaker.
- Error boundaries.

### Day 5

- Capstone implementation.
- Testing.
- Failure simulation.
- Presentations and assessment.

---

## Weekly Format

| Week | Content |
|---:|---|
| 1 | Primers and runtime foundations |
| 2 | Execution contexts, scope, closures, `this` |
| 3 | Event loop, promises, concurrency |
| 4 | Cancellation and timeout design |
| 5 | Functional programming |
| 6 | Reactive state and Proxy |
| 7 | Memory and performance |
| 8 | Retry and resilience |
| 9 | Testing and production architecture |
| 10 | Capstone implementation and review |

---

## Workshop Format

Each workshop follows:

```text
Concept explanation
        │
        ▼
Instructor demonstration
        │
        ▼
Learner prediction
        │
        ▼
Hands-on implementation
        │
        ▼
Verification
        │
        ▼
Reflection and discussion
```

Recommended ratio:

```text
30% explanation
50% implementation
20% review and discussion
```

---

# 6. Teaching Principles

## 6.1 Predict Before Running

Before executing code, ask learners:

> What do you think the output will be?

This is especially effective for:

- Hoisting.
- Closures.
- `this`.
- Promise ordering.
- Microtasks.
- Timers.
- Retry attempts.
- Circuit transitions.

Do not immediately correct incorrect predictions. Run the example first, then analyze the difference.

---

## 6.2 Make the Runtime Visible

Use logs that show:

- Function entry and exit.
- Attempt number.
- Timer registration.
- State transition.
- Circuit state.
- Cleanup.
- Request identifiers.

Example:

```js
console.log({
  event: "service_attempt",
  service: "metrics",
  attempt: 2
});
```

Visible logs help learners connect abstract concepts to execution.

---

## 6.3 Verify Every Step

Do not allow learners to build several modules before checking the earlier one.

Require:

```text
write code
   │
   ▼
run command
   │
   ▼
compare output
   │
   ▼
explain behavior
```

If a learner cannot explain the output, pause and investigate before continuing.

---

## 6.4 Separate Language From Architecture

Emphasize the difference between:

### Language Features

- Closures.
- Promises.
- Classes.
- Proxy.
- `async`.
- `await`.

### Runtime Features

- Timers.
- Event loop.
- Filesystem.
- Process signals.
- Rendering.

### Architecture Patterns

- Retry.
- Circuit breaker.
- Bulkhead.
- Error boundary.
- Resource scope.

This prevents learners from thinking that a language feature automatically solves a system-design problem.

---

## 6.5 Teach Failure as a Normal Path

For every successful example, ask:

- What if the operation fails?
- What if it is slow?
- What if the result is no longer needed?
- What if it is called twice?
- What if cleanup fails?
- What if the dependency remains unavailable?

---

# 7. Trainer Preparation

## Before the Course

- [ ] Run every code example.
- [ ] Verify Node.js version compatibility.
- [ ] Test commands on the target operating system.
- [ ] Confirm browser examples work.
- [ ] Prepare starter repository.
- [ ] Prepare completed reference repository.
- [ ] Confirm all test files pass.
- [ ] Test capstone server startup.
- [ ] Test graceful shutdown.
- [ ] Prepare backup code for troubleshooting.
- [ ] Prepare timing alternatives for slower machines.
- [ ] Remove secrets from sample configuration.

## Recommended Repositories

Maintain three branches:

```text
starter
solution
instructor-demo
```

### `starter`

Contains setup and incomplete exercises.

### `solution`

Contains completed code.

### `instructor-demo`

Contains intentional bugs for debugging exercises.

---

# 8. Classroom Setup

## Recommended Layout

Learners should have:

- Terminal visible.
- Code editor visible.
- Browser visible when using the capstone.
- Notes or student workbook available.

## Pair Programming

Use rotating roles:

### Driver

Types the code.

### Navigator

Predicts behavior, checks requirements, and watches for mistakes.

Switch roles every 15–20 minutes.

---

# 9. Primer Delivery Guide

## Primer 1: JavaScript Essentials

### Teaching Goal

Confirm that learners can read and write ordinary JavaScript before discussing runtime internals.

### Emphasize

- Bindings versus values.
- Objects are references.
- Functions are values.
- Pure transformations.
- Module boundaries.

### Demonstration

```js
const service = {
  status: "loading"
};

const nextService = {
  ...service,
  status: "healthy"
};

console.log(service.status);
console.log(nextService.status);
```

Ask:

> Which object changed?

### Common Misconceptions

- `const` makes objects immutable.
- Arrays are copied automatically.
- `typeof null` is `"null"`.
- `filter()` mutates the original array.
- A function declaration and function expression initialize identically.

### Exit Check

Learners should implement:

```js
function updateServiceStatus(
  services,
  name,
  status
) {}
```

without mutating the original object.

---

## Primer 2: Modern Syntax

### Teaching Goal

Make later code readable without making syntax the main topic.

### Emphasize

- Destructuring.
- Object spread.
- Optional chaining.
- Nullish coalescing.
- Arrow-function `this`.
- Private fields.

### Demonstration

```js
const timeout =
  configuration.timeout ?? 5_000;
```

Ask:

> What happens if timeout is zero?

Then compare:

```js
const timeout =
  configuration.timeout || 5_000;
```

### Common Misconceptions

- Spread is a deep copy.
- Optional chaining validates data.
- Arrow functions have dynamic `this`.
- Private fields are string-keyed properties.
- `??` and `||` mean the same thing.

---

## Primer 3: Node.js and Tooling

### Teaching Goal

Ensure learners can run and verify the course project independently.

### Emphasize

- `package.json`.
- npm scripts.
- Environment variables.
- Exit codes.
- Filesystem boundaries.
- Process signals.

### Demonstration

```bash
npm test
npm run dev
```

Ask learners to explain:

```json
{
  "type": "module"
}
```

### Common Misconceptions

- Environment variables are automatically secure.
- `fetch()` rejects on every HTTP error.
- `process.exit()` is always the best shutdown mechanism.
- `process.cwd()` always points to the module directory.
- Node.js and browsers expose the same globals.

---

## Primer 4: Async Foundations

### Teaching Goal

Build enough async fluency before introducing the event-loop internals.

### Emphasize

- Awaiting promises.
- Sequential versus concurrent work.
- Cancellation.
- Timeouts.
- Error handling.
- Cleanup.

### Demonstration

```js
const [metrics, health] =
  await Promise.all([
    loadMetrics(),
    loadHealth()
  ]);
```

Ask:

> Which operation starts first? Which completes first? In what order are results returned?

---

## Primer 5: Testing

### Teaching Goal

Make verification part of implementation rather than an afterthought.

### Emphasize

- Arrange, Act, Assert.
- Testing failure paths.
- Awaiting asynchronous tests.
- Dependency injection.
- Cleanup tests.
- Integration boundaries.

### Exit Check

Learners should write a test that verifies:

- A temporary failure is retried.
- A permanent failure is not retried.
- Cancellation stops the operation.

---

# 10. Part 0 Delivery Guide

## Teaching Goal

Introduce the complete architecture and create motivation.

## Instructor Narrative

Use this analogy:

> The application is like a restaurant. The UI is the dining room, services are the kitchen stations, the retry layer is a waiter returning after a temporary delay, and the circuit breaker is a closed kitchen door when a station is unsafe.

## Key Questions

Ask learners:

1. What makes a JavaScript application production-ready?
2. What happens when a network request never finishes?
3. What happens when a user starts a second search?
4. What happens when one dashboard panel fails?
5. Who cleans up a timer?
6. How do we know whether a service is unhealthy?

## Activity

Have learners draw the capstone architecture before seeing the completed diagram.

---

# 11. Part 1 Delivery Guide: Engine Mechanics

## Session Goal

Learners should be able to explain how JavaScript creates contexts, resolves variables, retains closures, and binds `this`.

---

## Lab 1: Execution Contexts

### Demonstration

```js
function calculateTotal(price, quantity) {
  const subtotal = price * quantity;
  return addTax(subtotal, 0.2);
}

function addTax(amount, rate) {
  return amount + amount * rate;
}

console.log(calculateTotal(100, 2));
```

### Ask

- Which context exists first?
- When is `calculateTotal` created?
- When is `addTax` called?
- Which variables belong to each function?
- What is on the call stack during `addTax()`?

### Expected Understanding

```text
global
  → calculateTotal
      → addTax
```

---

## Lab 2: Hoisting

Have learners predict:

```js
console.log(value);
var value = 10;
```

Then:

```js
console.log(value);
let value = 10;
```

### Teaching Point

Do not describe hoisting as “moving code.” Explain declaration initialization states.

---

## Lab 3: Closures

### Demonstration

```js
function createCounter() {
  let count = 0;

  return {
    increment() {
      count += 1;
      return count;
    },

    current() {
      return count;
    }
  };
}
```

### Ask

- Where does `count` live after `createCounter()` returns?
- Why do two counters not share state?
- What could keep this counter alive?
- How could a closure retain too much data?

---

## Lab 4: `this`

Use four call forms:

```js
show();
object.show();
show.call(object);
show.bind(object)();
```

Have learners complete a binding table.

### Common Teaching Mistake

Do not say simply:

> "`this` refers to the object."

That is incomplete.

Say:

> In this call form, the object immediately before the dot supplies `this`.

---

## Part 1 Exit Assessment

Learners must explain:

```js
const method = object.method;
method();
```

without running it.

---

# 12. Part 2 Delivery Guide: Async Execution

## Session Goal

Learners should predict event-loop behavior and choose appropriate concurrency and cancellation strategies.

---

## Lab 1: Event-Loop Prediction

Use:

```js
console.log("A");

setTimeout(() => console.log("B"), 0);

Promise.resolve().then(() => {
  console.log("C");
});

queueMicrotask(() => {
  console.log("D");
});

console.log("E");
```

### Ask Before Running

- Which lines are synchronous?
- Which callbacks are microtasks?
- Which callback is a later task?
- What is the expected output?

---

## Lab 2: Microtask Starvation

Use a bounded loop first:

```js
let count = 0;

function schedule() {
  count += 1;

  if (count < 10000) {
    queueMicrotask(schedule);
  }
}

schedule();
```

Then discuss why an infinite version is dangerous.

### Teaching Point

Microtasks are not “free.” They still consume runtime execution time.

---

## Lab 3: Combinator Selection

Give learners scenarios:

1. Load required user and permissions.
2. Load optional dashboard panels.
3. Race primary and backup configuration sources.
4. Time out a request.
5. Accept the first successful replica.

Expected answers:

```text
1. Promise.all
2. Promise.allSettled
3. Promise.race or Promise.any depending on failure meaning
4. Promise.race plus cancellation
5. Promise.any
```

---

## Lab 4: Cancellation

Have learners implement a cancellable delay.

### Review Questions

- Who creates the controller?
- Who receives the signal?
- What does the operation clean up?
- How is cancellation distinguished from failure?
- What happens if the signal was already aborted?

---

## Part 2 Exit Assessment

Learners must:

- Predict a callback order.
- Choose a combinator.
- Explain why `Promise.race()` alone does not cancel the losing operation.
- Implement a cancellation-aware timeout.

---

# 13. Part 3 Delivery Guide: Functional and Reactive Design

## Session Goal

Learners should separate pure logic from side effects and build predictable state updates.

---

## Lab 1: Pure Function Classification

Show:

```js
function calculateTotal(price, quantity) {
  return price * quantity;
}
```

and:

```js
let taxRate = 0.2;

function calculateTax(price) {
  return price * taxRate;
}
```

Ask which is easier to test and why.

---

## Lab 2: Immutable Updates

Start with:

```js
const state = {
  services: {
    metrics: {
      status: "loading"
    }
  }
};
```

Ask learners to update the nested status without mutation.

### Review

Check:

```js
nextState !== state
nextState.services !== state.services
nextState.services.metrics !==
  state.services.metrics
```

Also check that unrelated branches remain shared where appropriate.

---

## Lab 3: Composition

Have learners create:

```js
trim
lowercase
replaceSpaces
prefix
```

Then build a pipeline.

### Discussion

Ask:

- Is the pipeline easier to test?
- Where should logging occur?
- What happens if a stage throws?
- How would an async pipeline differ?

---

## Lab 4: Proxy and Reflect

Use a proxy to reject invalid statuses.

### Teaching Point

A proxy is an interception mechanism, not a complete state-management architecture.

Ask learners:

- What does the proxy detect?
- What does it not detect?
- How would nested objects behave?
- What cleanup does a subscriber need?

---

## Part 3 Exit Assessment

Learners must:

- Write one pure selector.
- Write one immutable state transition.
- Explain one side effect.
- Build a subscription with unsubscribe.
- Explain why `Reflect.set()` is preferable inside a proxy trap.

---

# 14. Part 4 Delivery Guide: Production Architecture

## Session Goal

Learners should design software that handles memory, performance, failure, and shutdown conditions intentionally.

---

## Lab 1: Memory Ownership

List resources:

```text
timer
event listener
subscription
worker
server
cache
```

For each, ask:

- Who creates it?
- Who uses it?
- Who releases it?
- What happens if release fails?

---

## Lab 2: Debounce and Throttle

Give scenarios and ask learners to choose.

### Debounce

- Search input.
- Autosave.
- Validation after typing.

### Throttle

- Scroll.
- Pointer movement.
- Telemetry.

### Batching

- Multiple synchronous state updates.
- DOM rendering.
- Notifications.

---

## Lab 3: Retry Policy

Present errors:

```text
400 invalid input
401 unauthorized
404 missing resource
408 timeout
429 rate limited
500 server error
503 unavailable
AbortError cancelled
```

Ask learners to classify:

```text
retry
do not retry
retry only with conditions
ignore as cancellation
```

---

## Lab 4: Circuit Breaker

Use a state-transition diagram.

Have learners implement a fake dependency with:

```js
failuresBeforeSuccess
```

Then verify:

```text
CLOSED → OPEN → HALF_OPEN → CLOSED
```

---

## Lab 5: Error Boundary

Have learners deliberately create:

- A validation error.
- A timeout.
- A cancellation.
- A dependency error.
- An unexpected programming error.

Discuss where each should be handled.

---

## Part 4 Exit Assessment

Learners must:

- Identify one memory leak.
- Choose debounce or throttle.
- Define a retryable error.
- Explain idempotency.
- Implement or explain a circuit breaker.
- Describe graceful shutdown.

---

# 15. Capstone Facilitation Guide

## Capstone Goal

Learners integrate the entire course into Runtime Monitor.

## Recommended Milestones

### Milestone 1: Basic Server

Requirements:

- [ ] Start HTTP server.
- [ ] Add `/live`.
- [ ] Add `/ready`.
- [ ] Return JSON.
- [ ] Handle 404.

### Milestone 2: Fake Services

Requirements:

- [ ] Metrics.
- [ ] Health.
- [ ] Activity.
- [ ] Configurable delays.
- [ ] Configurable failures.
- [ ] Abort support.

### Milestone 3: Concurrent Workflow

Requirements:

- [ ] Use `Promise.allSettled()`.
- [ ] Preserve partial results.
- [ ] Add service-level status.

### Milestone 4: Resilience

Requirements:

- [ ] Add retry.
- [ ] Add backoff.
- [ ] Add circuit breaker.
- [ ] Add timeout.
- [ ] Add cancellation.

### Milestone 5: Browser UI

Requirements:

- [ ] Render service cards.
- [ ] Add Refresh button.
- [ ] Add filter input.
- [ ] Add debouncing.
- [ ] Add batched rendering.

### Milestone 6: Testing

Requirements:

- [ ] Unit tests.
- [ ] Retry tests.
- [ ] Circuit tests.
- [ ] Cancellation tests.
- [ ] Integration test.
- [ ] Cleanup test.

### Milestone 7: Production Review

Requirements:

- [ ] Configuration validation.
- [ ] Structured logs.
- [ ] Health endpoints.
- [ ] Graceful shutdown.
- [ ] README.
- [ ] Runbook.

---

# 16. Capstone Mentoring Questions

Ask learners:

## Workflow

- Which operations are independent?
- What happens if one service fails?
- What happens if one service never responds?
- How does a new refresh affect an old refresh?

## Resilience

- Which errors are retryable?
- Is the operation idempotent?
- When should the circuit open?
- How does the circuit recover?

## State

- Who owns state?
- Who can modify it?
- How are subscribers removed?
- What happens when a subscriber throws?

## Performance

- What work is repeated unnecessarily?
- What work can be batched?
- Where should debouncing happen?
- Is the bottleneck CPU, network, memory, or rendering?

## Operations

- How do we know the server is alive?
- How do we know it is ready?
- What happens during deployment shutdown?
- What would the on-call engineer see?

---

# 17. Common Learner Misconceptions

## Misconception 1

> JavaScript is single-threaded, so asynchronous operations run one at a time.

### Correction

JavaScript execution is generally single-threaded per main context, but the runtime can coordinate overlapping I/O and asynchronous operations.

---

## Misconception 2

> `setTimeout(fn, 0)` runs immediately.

### Correction

It becomes eligible later. Current synchronous work and microtasks run first.

---

## Misconception 3

> `await` blocks the application.

### Correction

`await` pauses the current async function, not the entire runtime.

---

## Misconception 4

> `Promise.all()` cancels remaining promises after one rejects.

### Correction

It rejects its returned promise. Underlying operations may continue unless explicitly cancelled.

---

## Misconception 5

> Every closure is a memory leak.

### Correction

A closure is normal. It becomes a problem when a long-lived reference retains unnecessary data.

---

## Misconception 6

> `const` makes objects immutable.

### Correction

`const` prevents rebinding. Object properties can still mutate unless protected.

---

## Misconception 7

> Arrow functions receive the object as `this`.

### Correction

Arrow functions capture lexical `this`.

---

## Misconception 8

> Retrying makes an operation reliable.

### Correction

Retries can amplify outages and duplicate side effects unless bounded and safe.

---

## Misconception 9

> A circuit breaker is just a retry loop.

### Correction

A circuit breaker prevents calls during known dependency failure. Retry and circuit breaking solve different problems.

---

## Misconception 10

> High test coverage proves correctness.

### Correction

Coverage shows executed code, not necessarily meaningful behavior.

---

# 18. Assessment Strategy

## Formative Assessment

Use during teaching:

- Prediction questions.
- Pair explanations.
- Small code modifications.
- Output ordering exercises.
- Error classification.
- Architecture diagrams.
- Code reviews.

## Summative Assessment

Use at the end:

- Written runtime assessment.
- Practical implementation.
- Capstone demonstration.
- Failure scenario exercise.
- Code review.
- Architecture explanation.

---

# 19. Assessment Rubric

## Runtime Understanding — 20 Points

| Criteria | Points |
|---|---:|
| Execution contexts | 4 |
| Lexical scope and closures | 4 |
| Hoisting | 4 |
| `this` binding | 4 |
| Call-stack reasoning | 4 |

## Async Control Flow — 20 Points

| Criteria | Points |
|---|---:|
| Event-loop reasoning | 4 |
| Promise combinators | 4 |
| Concurrency | 4 |
| Cancellation | 4 |
| Timeout behavior | 4 |

## Functional and Reactive Design — 20 Points

| Criteria | Points |
|---|---:|
| Pure functions | 4 |
| Immutable updates | 4 |
| Composition | 3 |
| Proxy and Reflect | 3 |
| Reactive subscriptions | 6 |

## Performance and Resilience — 20 Points

| Criteria | Points |
|---|---:|
| Memory ownership | 4 |
| Debounce/throttle/batching | 4 |
| Retry and backoff | 4 |
| Circuit breaker | 4 |
| Error handling | 4 |

## Capstone Quality — 20 Points

| Criteria | Points |
|---|---:|
| Functional application | 4 |
| Tests | 4 |
| Configuration and security | 3 |
| Observability | 3 |
| Shutdown and operations | 3 |
| Code organization | 3 |

### Total

```text
Score: ______ / 100
```

---

# 20. Practical Assessment Tasks

Assign one or more tasks.

## Task A: Event-Loop Explanation

Given:

```js
console.log("start");

setTimeout(() => {
  console.log("timer");
}, 0);

Promise.resolve().then(() => {
  console.log("promise");
});

console.log("end");
```

Learner must:

- Predict output.
- Explain the call stack.
- Explain the microtask queue.
- Explain the timer task.

---

## Task B: Cancellation Implementation

Learner must implement a cancellable delay with:

- Abort signal.
- AbortError.
- Timer cleanup.
- Listener cleanup.
- Already-aborted handling.

---

## Task C: Retry Review

Provide a retry helper with one intentional bug:

```js
while (true) {
  try {
    return await operation();
  } catch {
    await delay(100);
  }
}
```

Learner must identify:

- Infinite retries.
- No classification.
- No cancellation.
- No backoff.
- No idempotency consideration.

---

## Task D: Circuit Breaker Design

Learner must draw and explain:

```text
CLOSED → OPEN → HALF_OPEN → CLOSED
```

Then describe what happens when the half-open probe fails.

---

## Task E: Memory Leak Diagnosis

Provide:

```js
const handlers = [];

function mount(data) {
  handlers.push(() => data);
}
```

Learner must explain:

- What is retained.
- Why the registry matters.
- How to return cleanup.
- How to test cleanup.

---

# 21. Code Review Checklist for Trainers

## Readability

- [ ] Names express intent.
- [ ] Functions have focused responsibilities.
- [ ] Async boundaries are visible.
- [ ] Error paths are clear.
- [ ] Comments explain why, not merely what.

## Correctness

- [ ] Inputs are validated.
- [ ] Promises are awaited.
- [ ] Rejections are handled.
- [ ] Cancellation is propagated.
- [ ] Timers are cleaned up.
- [ ] State updates are predictable.

## Architecture

- [ ] Dependencies are explicit.
- [ ] UI is separated from domain logic.
- [ ] Resilience is not embedded everywhere.
- [ ] Modules have clear boundaries.
- [ ] No unnecessary circular dependencies.

## Operations

- [ ] Configuration is externalized.
- [ ] Logs are structured.
- [ ] Secrets are redacted.
- [ ] Health endpoints exist.
- [ ] Shutdown is graceful.
- [ ] Metrics identify important failures.

---

# 22. Trainer Troubleshooting Guide

## `document is not defined`

Cause:

- Browser-specific code was executed in Node.js.

Fix:

- Move DOM access to a browser adapter.
- Inject DOM dependencies.
- Serve the application through a browser.

---

## `Cannot use import statement outside a module`

Cause:

- Missing `"type": "module"`.
- Wrong file extension.
- Incorrect project configuration.

Fix:

```json
{
  "type": "module"
}
```

Use explicit imports:

```js
import { value } from "./module.js";
```

---

## Test Hangs

Likely causes:

- Active interval.
- Open server.
- Worker not terminated.
- Pending promise.
- Unclosed stream.
- Forgotten event listener.

Ask learners:

> What resource did the test create, and where is its cleanup?

---

## Timer Output Differs

Explain:

- Timer delays are minimum delays.
- Machine load affects timing.
- Long synchronous work delays timers.
- Exact ordering may vary between runtimes.

---

## Circuit Breaker Never Recovers

Check:

- Is `openedAt` recorded?
- Is reset timeout checked?
- Is a half-open probe allowed?
- Does success transition to closed?
- Is the breaker counting cancellation incorrectly?

---

## Retry Runs Too Often

Check:

- Maximum attempts.
- Backoff calculation.
- Whether the error is actually retryable.
- Whether the caller has cancelled.
- Whether multiple workflows are retrying independently.

---

## Browser Filter Feels Slow

Check:

- Is input debounced?
- Is rendering batched?
- Are unnecessary DOM nodes recreated?
- Is filtering done on every keystroke?
- Is the dataset too large for the current approach?

---

# 23. Suggested Homework

## Homework 1: Runtime Prediction

Write five event-loop examples and predict each output before running.

## Homework 2: Closure Factory

Build a private cache with:

- `get()`.
- `set()`.
- `clear()`.
- Maximum size.

## Homework 3: Cancellation

Add cancellation to a paginated request workflow.

## Homework 4: Reactive Store

Build a store with:

- State.
- Dispatch.
- Subscribe.
- Unsubscribe.
- Selectors.

## Homework 5: Resilience

Add:

- Retry.
- Circuit breaker.
- Stale fallback.
- Metrics.

## Homework 6: Testing

Write tests for:

- Success.
- Validation failure.
- Timeout.
- Cancellation.
- Retry exhaustion.
- Cleanup.

---

# 24. Trainer Discussion Prompts

Use these prompts to encourage deeper reasoning:

1. When is sequential work more correct than concurrent work?
2. When is a closure better than a class?
3. When is a proxy too much abstraction?
4. What is the cost of immutable updates?
5. When should stale data be shown?
6. Can a retry make an outage worse?
7. Should every timeout be retried?
8. What should happen when an error reporter fails?
9. How do you know whether a memory issue is a leak?
10. What should an application do when the process is shutting down?
11. How would this design change for multiple server instances?
12. Which metrics would help an on-call engineer first?

---

# 25. Final Trainer Review

Before completing the course, verify that learners can:

- [ ] Predict important runtime behavior.
- [ ] Explain their predictions.
- [ ] Write complete implementations.
- [ ] Test failure paths.
- [ ] Identify lifecycle ownership.
- [ ] Distinguish concurrency from parallelism.
- [ ] Choose promise combinators intentionally.
- [ ] Implement cancellation.
- [ ] Protect dependencies.
- [ ] Design for partial failure.
- [ ] Explain the capstone architecture.
- [ ] Demonstrate graceful shutdown.
- [ ] Discuss trade-offs rather than reciting rules.

---

# 26. Recommended Final Demonstration

Ask each learner or team to present:

1. Their architecture diagram.
2. Their most important module.
3. One failure scenario.
4. One performance decision.
5. One cleanup contract.
6. One test they consider essential.
7. One trade-off they made.
8. A live capstone demonstration.
9. A graceful shutdown demonstration.
10. A short explanation of how the runtime supports the architecture.

---

# 27. Final Trainer Notes

The strongest learning outcomes come from requiring learners to explain cause and effect.

Do not accept only:

```text
"It works."
```

Ask for:

```text
"Why does it work?"
"What would make it fail?"
"Who owns the resource?"
"Which queue runs this callback?"
"Which layer should handle this error?"
"How would we verify that?"
```

The course should leave learners with a practical engineering habit:

```text
observe
  │
  ▼
predict
  │
  ▼
implement
  │
  ▼
verify
  │
  ▼
measure
  │
  ▼
refine
```

Advanced JavaScript is best learned by connecting runtime behavior to design decisions.
