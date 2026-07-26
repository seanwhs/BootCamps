# References and Resources Guide

## Advanced JavaScript: Runtime Engines, Optimization & Architecture

This guide provides a curated learning path for the series.

The resources are organized by:

- Topic.
- Difficulty.
- Purpose.
- Recommended order.
- Practical use.
- Verification exercises.
- Production references.

Prefer official documentation and standards for final authority. Tutorials are useful for explanations, but specifications and runtime documentation define actual behavior.

---

# 1. Recommended Reading Order

Use this order:

```text
JavaScript foundations
        │
        ▼
ECMAScript language reference
        │
        ▼
Browser and Node.js runtime APIs
        │
        ▼
Asynchronous execution
        │
        ▼
Functional and reactive patterns
        │
        ▼
Performance and memory
        │
        ▼
Resilience and production operations
```

Recommended progression:

1. MDN JavaScript Guide.
2. Node.js Learn documentation.
3. ECMAScript specification references.
4. V8 documentation and blog.
5. Browser performance documentation.
6. Node.js diagnostics documentation.
7. Resilience engineering references.
8. Testing and observability documentation.

---

# 2. Primary JavaScript References

## MDN JavaScript Guide

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide>

Best for:

- Syntax.
- Functions.
- Objects.
- Classes.
- Promises.
- Modules.
- Iterators.
- Meta programming.
- Memory concepts.
- Error handling.

Recommended sections:

- Grammar and types.
- Control flow and error handling.
- Functions.
- Expressions and operators.
- Numbers and strings.
- Collections.
- Objects.
- Classes.
- Promises.
- Iterators and generators.
- Modules.
- Meta programming.

Use MDN for practical explanations and browser API documentation.

---

## MDN JavaScript Reference

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference>

Best for precise lookup of:

- `Promise`.
- `Proxy`.
- `Reflect`.
- `AbortController`.
- `Map`.
- `Set`.
- `WeakMap`.
- `Symbol`.
- `structuredClone()`.
- `queueMicrotask()`.
- `async`.
- `await`.

Use this when you already understand the concept and need exact API behavior.

---

## ECMAScript Specification

**URL:**  
<https://tc39.es/ecma262/>

Best for:

- Execution contexts.
- Lexical environments.
- Environment records.
- Function invocation.
- Promise jobs.
- Proxy invariants.
- Property semantics.
- Language-level definitions.

Use the specification as the final authority, but do not begin there if you are still learning the basic concepts.

### Recommended Specification Search Terms

```text
Execution Contexts
Lexical Environments
Environment Records
GetThisBinding
EvaluateCall
Promise Objects
Jobs and Host Operations
Proxy Object Internal Methods
```

---

## TC39 Proposals

**URL:**  
<https://github.com/tc39/proposals>

Best for understanding upcoming or recently standardized JavaScript features.

Use proposal repositories to learn:

- Why a feature was introduced.
- Which problem it solves.
- Alternative designs that were considered.
- Current standardization status.

Do not use a proposal in production solely because it appears in a proposal repository. Confirm runtime support first.

---

# 3. JavaScript Runtime and Engine Resources

## V8 Documentation

**URL:**  
<https://v8.dev/docs>

Best for:

- JavaScript engine architecture.
- Ignition interpreter.
- TurboFan optimization.
- Garbage collection.
- WebAssembly.
- Performance behavior.
- Engine diagnostics.

Recommended topics:

- V8 overview.
- Ignition.
- TurboFan.
- Garbage collection.
- Performance tips.
- Code caching.
- WebAssembly integration.

---

## V8 Blog

**URL:**  
<https://v8.dev/blog>

Best for deeper articles about:

- JIT optimization.
- JavaScript performance.
- Garbage collection.
- New language features.
- Engine internals.
- Memory behavior.

Use it after completing Part 1 and Part 4.

---

## JavaScript Engine Fundamentals

**Resource:**  
*JavaScript: The Definitive Guide* by David Flanagan

Useful for:

- Language fundamentals.
- Objects.
- Functions.
- Asynchronous programming.
- Browser APIs.
- Modern syntax.

Use the current edition appropriate to your environment.

---

## You Don’t Know JS Yet

**Repository:**  
<https://github.com/getify/You-Dont-Know-JS>

Best for:

- Scope and closures.
- Types and coercion.
- Objects and classes.
- Async behavior.
- JavaScript mechanisms.

Particularly relevant books include:

- Scope & Closures.
- Types & Grammar.
- Objects & Classes.
- Async & Performance.

Use this series for mental models and detailed explanations. Cross-check browser and runtime-specific claims against current documentation.

---

# 4. Scope, Closures, and `this`

## MDN Closures

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures>

Use for:

- Closure definition.
- Lexical environment examples.
- Private state.
- Common closure patterns.
- Loop-related closure behavior.

---

## MDN `this`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this>

Use for:

- Default binding.
- Method calls.
- Constructors.
- Classes.
- Arrow functions.
- Strict mode.

---

## MDN `Function.prototype.call()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/call>

## MDN `Function.prototype.apply()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply>

## MDN `Function.prototype.bind()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind>

Use these together when studying invocation rules.

### Recommended Exercise

For each function, test:

```js
fn();
object.fn();
fn.call(object);
fn.apply(object, []);
fn.bind(object)();
new fn();
```

Record the observed `this` value.

---

# 5. Event Loop and Asynchronous JavaScript

## MDN Event Loop

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Event_loop>

Best for:

- Execution contexts.
- Stack behavior.
- Jobs and queues.
- Run-to-completion.
- Event-loop concepts.
- Concurrency explanations.

---

## HTML Standard: Event Loops

**URL:**  
<https://html.spec.whatwg.org/multipage/webappapis.html#event-loops>

Best for browser-specific details about:

- Tasks.
- Microtasks.
- Rendering opportunities.
- Event-loop processing.
- Browser host behavior.

Use this when you need more precision than a simplified event-loop diagram provides.

---

## Jake Archibald: Tasks, Microtasks, Queues and Schedules

**URL:**  
<https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/>

A well-known explanation of:

- Tasks.
- Microtasks.
- Promises.
- Timers.
- Browser event ordering.

Use it as a conceptual companion to the MDN and HTML Standard references.

---

## Node.js Event Loop Guide

**URL:**  
<https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick>

Best for:

- Node.js event-loop phases.
- Timers.
- Polling.
- `setImmediate()`.
- `process.nextTick()`.

---

## Node.js `process.nextTick()`

**URL:**  
<https://nodejs.org/api/process.html#processnexttickcallback-args>

Use for Node-specific scheduling behavior.

Be careful when teaching it. Learners should understand:

- It is Node-specific.
- It has special scheduling priority.
- Recursive use can starve the event loop.
- `queueMicrotask()` is often more portable.

---

## Node.js Timers

**URL:**  
<https://nodejs.org/api/timers.html>

Includes:

- `setTimeout()`.
- `setInterval()`.
- `setImmediate()`.
- Promise-based timers.
- Timer cancellation.

---

# 6. Promise and Cancellation References

## MDN Promise

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise>

Use for:

- Promise states.
- Promise methods.
- Resolution and rejection.
- Chaining.
- Combinators.

---

## MDN `Promise.all()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all>

## MDN `Promise.allSettled()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/allSettled>

## MDN `Promise.race()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/race>

## MDN `Promise.any()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/any>

Use the following decision table:

| Requirement | API |
|---|---|
| All operations required | `Promise.all()` |
| Preserve all outcomes | `Promise.allSettled()` |
| First settlement | `Promise.race()` |
| First successful result | `Promise.any()` |

---

## MDN `async function`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function>

## MDN `await`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await>

---

## MDN `AbortController`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/AbortController>

## MDN `AbortSignal`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal>

Important topics:

- `signal.aborted`.
- `signal.reason`.
- `abort()`.
- `AbortSignal.timeout()`.
- `AbortSignal.any()`.
- Passing signals to `fetch()`.

---

## Fetch Standard

**URL:**  
<https://fetch.spec.whatwg.org/>

Use for detailed behavior concerning:

- Requests.
- Responses.
- Headers.
- Body streams.
- Abort signals.
- Network failures.

---

# 7. Functional Programming Resources

## MDN Array Methods

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array>

Focus on:

- `map()`.
- `filter()`.
- `reduce()`.
- `find()`.
- `some()`.
- `every()`.
- `flatMap()`.

---

## Functional-Light JavaScript

**Repository:**  
<https://github.com/getify/Functional-Light-JS>

Best for:

- Pure functions.
- Composition.
- Higher-order functions.
- Immutability.
- Practical functional programming without excessive abstraction.

---

## Professor Frisby’s Mostly Adequate Guide to Functional Programming

**Repository:**  
<https://github.com/MostlyAdequate/mostly-adequate-guide>

Best for:

- Functional vocabulary.
- Composition.
- Functors and monads.
- Declarative data processing.

Use selectively. Some concepts go beyond the needs of this series.

---

## Structure and Interpretation of Computer Programs

**Resource:**  
<https://sicp.sourceacademy.org/>

Best for:

- Abstraction.
- Evaluation.
- Higher-order procedures.
- Interpreter thinking.
- Programming-language fundamentals.

This is an advanced optional resource rather than a prerequisite.

---

# 8. Proxy, Reflect, and Metaprogramming

## MDN Proxy

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy>

Focus on:

- `get`.
- `set`.
- `has`.
- `deleteProperty`.
- `ownKeys`.
- Invariants.
- Target behavior.

---

## MDN Reflect

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect>

Focus on:

- `Reflect.get()`.
- `Reflect.set()`.
- `Reflect.has()`.
- `Reflect.deleteProperty()`.
- `Reflect.ownKeys()`.

---

## Recommended Proxy Exercises

Build progressively:

1. Logging proxy.
2. Validation proxy.
3. Read-only proxy.
4. Reactive proxy.
5. Deep reactive proxy.
6. Proxy with unsubscribe.
7. Proxy with batched notifications.

For each exercise, test:

- Property reads.
- Property writes.
- Deletion.
- Missing properties.
- Inherited properties.
- Nested objects.
- Frozen objects.

---

# 9. Memory and Garbage Collection Resources

## MDN Memory Management

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Memory_management>

Best for:

- Memory lifecycle.
- Reachability.
- Garbage collection.
- Memory leaks.
- Weak references.

---

## V8 Trash Talk

**URL:**  
<https://v8.dev/blog/trash-talk>

Useful for understanding garbage collection concepts and V8 behavior.

---

## Node.js Memory Usage

**URL:**  
<https://nodejs.org/api/process.html#processmemoryusage>

Use for:

- `rss`.
- `heapTotal`.
- `heapUsed`.
- `external`.
- `arrayBuffers`.

---

## Node.js V8 API

**URL:**  
<https://nodejs.org/api/v8.html>

Useful for:

- Heap statistics.
- Heap snapshots.
- V8 serialization.
- Heap-space information.

---

## Chrome DevTools Memory Documentation

**URL:**  
<https://developer.chrome.com/docs/devtools/memory-problems/>

Best for:

- Heap snapshots.
- Allocation timelines.
- Retaining paths.
- Detached DOM nodes.
- Memory leak investigation.

---

## Memory Investigation Workflow

Use:

```text
1. Reproduce repeated workload.
2. Record heap usage.
3. Take snapshot before.
4. Perform workload.
5. Release expected resources.
6. Take snapshot after.
7. Compare retained objects.
8. Inspect retaining paths.
9. Fix ownership or cleanup.
10. Repeat verification.
```

---

# 10. Performance Resources

## MDN Performance API

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/Performance>

Focus on:

- `performance.now()`.
- Marks.
- Measures.
- Resource timing.
- Navigation timing.

---

## User Timing API

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/User_Timing_API>

Use for named measurements:

```js
performance.mark("start");
// work
performance.mark("end");

performance.measure(
  "operation",
  "start",
  "end"
);
```

---

## Chrome DevTools Performance

**URL:**  
<https://developer.chrome.com/docs/devtools/performance/>

Best for:

- Long tasks.
- JavaScript execution.
- Layout.
- Paint.
- Rendering.
- User interaction latency.

---

## Chrome DevTools Rendering Performance

**URL:**  
<https://developer.chrome.com/docs/devtools/rendering/>

Useful for:

- Paint flashing.
- Layout shift.
- Frame rendering.
- Scrolling performance.
- Visual diagnostics.

---

## Node.js Performance Hooks

**URL:**  
<https://nodejs.org/api/perf_hooks.html>

Focus on:

- `performance.now()`.
- `PerformanceObserver`.
- `monitorEventLoopDelay()`.
- `eventLoopUtilization()`.

---

## Node.js Diagnostics

**URL:**  
<https://nodejs.org/en/learn/diagnostics>

Best for:

- Debugging.
- Profiling.
- Memory analysis.
- Event-loop analysis.
- Production diagnosis.

---

## Node.js Profiling Documentation

**URL:**  
<https://nodejs.org/en/learn/diagnostics/diagnostics-flamegraph>

Useful for:

- Flame graphs.
- CPU profiles.
- Hot functions.
- Sampling profilers.

---

# 11. Debouncing, Throttling, and Rendering

## MDN `requestAnimationFrame()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/Window/requestAnimationFrame>

Use for browser visual updates.

---

## MDN `setTimeout()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/Window/setTimeout>

## MDN `setInterval()`

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/API/Window/setInterval>

---

## Recommended Practice

For every scheduling helper, test:

- Normal execution.
- Repeated calls.
- Cancellation.
- Latest arguments.
- `this` behavior.
- Cleanup.
- Long-running callbacks.
- Component teardown.

---

# 12. Node.js Testing Resources

## Node.js Test Runner

**URL:**  
<https://nodejs.org/api/test.html>

Best for:

- `test()`.
- Test hooks.
- Subtests.
- Assertions.
- Watch mode.
- Mocking support where available.
- Test coverage.

---

## Node.js Assertions

**URL:**  
<https://nodejs.org/api/assert.html>

Focus on:

```js
assert.equal()
assert.strictEqual()
assert.deepEqual()
assert.ok()
assert.throws()
assert.rejects()
```

---

## Node.js Test Coverage

**URL:**  
<https://nodejs.org/api/test.html#collecting-code-coverage>

Run:

```bash
node --experimental-test-coverage --test
```

Coverage should support testing decisions but should not replace thoughtful test design.

---

## Testing Library

**URL:**  
<https://testing-library.com/>

Useful for browser and UI tests that focus on user-visible behavior rather than implementation details.

---

## Playwright

**URL:**  
<https://playwright.dev/>

Useful for:

- Browser automation.
- End-to-end tests.
- Network interception.
- Cross-browser verification.
- User interaction testing.

---

## Web Platform Tests

**URL:**  
<https://github.com/web-platform-tests/wpt>

Useful for advanced browser-platform behavior and standards-oriented testing.

---

# 13. Node.js HTTP and Server Resources

## Node.js HTTP

**URL:**  
<https://nodejs.org/api/http.html>

Focus on:

- `http.createServer()`.
- Request objects.
- Response objects.
- Headers.
- Server shutdown.
- Connection behavior.

---

## Node.js HTTPS

**URL:**  
<https://nodejs.org/api/https.html>

Use when studying:

- TLS.
- Secure server connections.
- Certificates.
- HTTPS clients.

---

## Node.js URL

**URL:**  
<https://nodejs.org/api/url.html>

Use for:

- URL parsing.
- Search parameters.
- Safe URL construction.
- File URLs.

---

## Node.js Streams

**URL:**  
<https://nodejs.org/api/stream.html>

Best for:

- Large files.
- Backpressure.
- Incremental processing.
- Transform streams.
- Readable and writable resources.

---

# 14. Resilience Engineering Resources

## Release It!

**Book:**  
*Release It!* by Michael T. Nygard

Best for:

- Stability patterns.
- Circuit breakers.
- Bulkheads.
- Timeouts.
- Cascading failures.
- Production failure modes.

This is one of the most relevant books for Part 4.

---

## Site Reliability Engineering

**Book:**  
*Site Reliability Engineering: How Google Runs Production Systems*

**Free online edition:**  
<https://sre.google/sre-book/table-of-contents/>

Best for:

- Service-level objectives.
- Error budgets.
- Monitoring.
- Incident response.
- Capacity planning.
- Reliable operations.

---

## The Site Reliability Workbook

**Free online edition:**  
<https://sre.google/workbook/table-of-contents/>

Best for practical SRE implementation:

- SLO design.
- Monitoring.
- Incident management.
- Release engineering.
- Reliability practices.

---

## Microsoft Azure Architecture Center: Resiliency

**URL:**  
<https://learn.microsoft.com/en-us/azure/architecture/framework/resiliency/>

Useful for:

- Resilient application principles.
- Failure isolation.
- Recovery.
- Dependency design.
- Operational readiness.

---

## AWS Builders’ Library

**URL:**  
<https://aws.amazon.com/builders-library/>

Best for:

- Timeouts.
- Retries.
- Backoff.
- Jitter.
- Load shedding.
- Distributed-system failure modes.
- Control-plane and data-plane design.

Highly recommended readings include topics related to:

- Timeouts, retries, and backoff.
- Fairness in request scheduling.
- Avoiding overload.
- Static stability.
- Workload isolation.

---

## Martin Fowler: Circuit Breaker

**URL:**  
<https://martinfowler.com/bliki/CircuitBreaker.html>

A concise explanation of:

- Circuit-breaker purpose.
- Closed and open behavior.
- Failure prevention.
- Recovery probing.

---

## Martin Fowler: Transactional Outbox

**URL:**  
<https://microservices.io/patterns/data/transactional-outbox.html>

Useful when studying reliable event publication and non-idempotent side effects.

---

# 15. Distributed Systems and Idempotency

## Designing Data-Intensive Applications

**Book:**  
*Designing Data-Intensive Applications* by Martin Kleppmann

Best for:

- Distributed systems.
- Consistency.
- Replication.
- Partitioning.
- Streams.
- Fault tolerance.
- Data-processing architecture.

This is an advanced reference for learners continuing beyond the capstone.

---

## Enterprise Integration Patterns

**Website:**  
<https://www.enterpriseintegrationpatterns.com/>

Useful for:

- Messaging.
- Queues.
- Routing.
- Reliability.
- Transaction boundaries.
- Integration architecture.

---

## HTTP Semantics

**RFC 9110:**  
<https://www.rfc-editor.org/rfc/rfc9110>

Use for authoritative HTTP semantics:

- Methods.
- Status codes.
- Headers.
- Caching.
- Idempotency.
- Request and response semantics.

---

# 16. Security Resources

## OWASP Top Ten

**URL:**  
<https://owasp.org/www-project-top-ten/>

Best for:

- Injection.
- Broken access control.
- Cryptographic failures.
- Security misconfiguration.
- Vulnerable components.
- Authentication failures.

---

## OWASP Cheat Sheet Series

**URL:**  
<https://cheatsheetseries.owasp.org/>

Recommended topics:

- Input validation.
- Cross-site scripting prevention.
- Authentication.
- Session management.
- Logging.
- Secrets management.
- File upload security.
- SSRF prevention.

---

## Node.js Security Best Practices

**URL:**  
<https://nodejs.org/en/learn/getting-started/security-best-practices>

Use for:

- Dependency security.
- Permission boundaries.
- Process safety.
- Input handling.
- Secure configuration.

---

## MDN Web Security

**URL:**  
<https://developer.mozilla.org/en-US/docs/Web/Security>

Focus on:

- Same-origin policy.
- CORS.
- Content Security Policy.
- Secure cookies.
- Transport security.
- Web authentication.

---

# 17. Observability Resources

## OpenTelemetry

**URL:**  
<https://opentelemetry.io/docs/>

Best for:

- Traces.
- Metrics.
- Logs.
- Context propagation.
- Instrumentation.
- Vendor-neutral observability.

---

## OpenTelemetry JavaScript

**URL:**  
<https://opentelemetry.io/docs/languages/js/>

Useful for implementing observability in JavaScript and Node.js applications.

---

## Prometheus

**URL:**  
<https://prometheus.io/docs/introduction/overview/>

Best for:

- Metrics collection.
- Counters.
- Gauges.
- Histograms.
- Alerting concepts.

---

## Grafana

**URL:**  
<https://grafana.com/docs/>

Useful for:

- Dashboards.
- Visualization.
- Alerting.
- Operational monitoring.

---

## Logging Guidance

When designing logs, include:

```text
timestamp
level
requestId
operation
service
attempt
duration
status
errorCode
```

Do not include:

```text
password
access token
private key
session cookie
unredacted personal data
```

---

# 18. Books by Topic

## JavaScript Language

- *JavaScript: The Definitive Guide* — David Flanagan.
- *You Don’t Know JS Yet* — Kyle Simpson.
- *Effective JavaScript* — David Herman.

## Functional Programming

- *Functional-Light JavaScript* — Kyle Simpson.
- *Professor Frisby’s Mostly Adequate Guide to Functional Programming*.
- *Structure and Interpretation of Computer Programs*.

## Node.js

- *Node.js Design Patterns* — Mario Casciaro and Luciano Mammino.
- *Node.js in Action* — older but useful for foundational concepts; verify APIs against current Node.js documentation.

## Performance

- *High Performance Browser Networking* — Ilya Grigorik.
- *Web Performance in Action* — Jeremy Wagner.
- *Effective JavaScript* — performance and language design sections.

## Distributed Systems and Reliability

- *Release It!* — Michael T. Nygard.
- *Designing Data-Intensive Applications* — Martin Kleppmann.
- *Site Reliability Engineering* — Google.
- *The Site Reliability Workbook* — Google.

---

# 19. Recommended Resource by Course Part

## Part 1: Engine Mechanics

Read:

1. MDN Closures.
2. MDN `this`.
3. MDN Functions.
4. ECMAScript execution-context sections.
5. You Don’t Know JS Yet: Scope & Closures.

Practice:

- Draw call stacks.
- Predict hoisting.
- Build closure factories.
- Test extracted methods.

---

## Part 2: Async Execution

Read:

1. MDN Promises.
2. MDN Event Loop.
3. Node.js Event Loop Guide.
4. MDN AbortController.
5. Jake Archibald’s event-loop article.

Practice:

- Promise ordering.
- Microtask experiments.
- `Promise.allSettled()`.
- Cancellation-aware delays.
- Latest-request-wins search.

---

## Part 3: Functional and Reactive Design

Read:

1. MDN Array reference.
2. MDN Proxy.
3. MDN Reflect.
4. Functional-Light JavaScript.
5. Mostly Adequate Guide.

Practice:

- Pure selectors.
- Immutable transitions.
- Composed pipelines.
- Reactive state.
- Subscription cleanup.

---

## Part 4: Performance and Resilience

Read:

1. MDN Memory Management.
2. Node.js Diagnostics.
3. Chrome DevTools Performance.
4. *Release It!*
5. AWS Builders’ Library.
6. Google SRE Workbook.

Practice:

- Heap snapshots.
- Event-loop delay.
- Retry policies.
- Circuit breakers.
- Bulkheads.
- Graceful shutdown.

---

## Part 5: Capstone

Read:

1. Node.js HTTP documentation.
2. Node.js Test Runner documentation.
3. OpenTelemetry JavaScript.
4. OWASP Node.js security guidance.
5. SRE health-check and operational guidance.

Practice:

- Add a service.
- Add a failure mode.
- Add a metric.
- Add a test.
- Add a runbook.
- Demonstrate graceful shutdown.

---

# 20. Browser Tools

## Chrome DevTools

Useful panels:

- Console.
- Sources.
- Network.
- Performance.
- Memory.
- Application.
- Security.
- Lighthouse.

## Firefox Developer Tools

Useful for:

- Debugging.
- Network inspection.
- Performance.
- Memory.
- Accessibility.

## Recommended Browser Exercises

- Observe promise and timer order.
- Record a long task.
- Inspect network timing.
- Take a heap snapshot.
- Inspect event listeners.
- Test page lifecycle behavior.
- Compare rendering before and after batching.

---

# 21. Node.js Tools

## Built-In Tools

```bash
node --inspect
node --inspect-brk
node --cpu-prof
node --trace-gc
node --trace-events-enabled
node --test
node --experimental-test-coverage
```

## Useful Commands

```bash
npm ci
npm test
npm audit
npm outdated
npm ls
```

## Process Inspection

Use operating-system tools to inspect:

- CPU.
- Memory.
- Open files.
- Network connections.
- Process signals.

Be cautious when collecting production diagnostics because profiles and heap snapshots may contain sensitive information.

---

# 22. Practice Project Ideas

## Beginner Extension

Build a command-line service monitor that:

- Reads service names.
- Simulates health checks.
- Prints statuses.
- Retries failures.

## Intermediate Extension

Build a browser search application with:

- Debounce.
- Cancellation.
- Latest-request-wins.
- Loading states.
- Error states.

## Advanced Extension

Build a multi-service dashboard with:

- Concurrency limits.
- Circuit breakers.
- Stale cache.
- Metrics endpoint.
- Structured logs.
- Graceful shutdown.

## Expert Extension

Build a distributed worker system with:

- Queue backpressure.
- Idempotency keys.
- Retry budgets.
- Dead-letter handling.
- Distributed tracing.
- Per-dependency SLOs.

---

# 23. Resource Evaluation Checklist

Before adopting a resource, ask:

- [ ] Is it current enough for the runtime version?
- [ ] Does it distinguish browser and Node.js behavior?
- [ ] Does it cite standards or official documentation?
- [ ] Are examples complete?
- [ ] Does it explain failure behavior?
- [ ] Does it discuss trade-offs?
- [ ] Is the source maintained?
- [ ] Does it avoid overly simplified claims?
- [ ] Does it include security considerations?
- [ ] Can the examples be reproduced locally?

Be especially careful with old tutorials that discuss:

- Callback APIs no longer preferred.
- Deprecated Node.js modules.
- Browser APIs with changed behavior.
- Obsolete package versions.
- Unmaintained resilience libraries.
- Legacy module systems.

---

# 24. Personal Resource Log

## Resource

```text
Title: ___________________________________________________

URL or book: _____________________________________________

Topic: __________________________________________________

Date reviewed: ___________________________________________

Most useful idea:

__________________________________________________________
```

## Resource

```text
Title: ___________________________________________________

URL or book: _____________________________________________

Topic: __________________________________________________

Date reviewed: ___________________________________________

Most useful idea:

__________________________________________________________
```

## Resource

```text
Title: ___________________________________________________

URL or book: _____________________________________________

Topic: __________________________________________________

Date reviewed: ___________________________________________

Most useful idea:

__________________________________________________________
```

---

# 25. Recommended Ongoing Practice

After completing the series, continue with this weekly routine:

## Week 1: Runtime

- Read one engine or specification article.
- Run one execution-order experiment.
- Explain the result in writing.

## Week 2: Async

- Build one cancellation-aware workflow.
- Compare sequential and concurrent timing.
- Test a timeout.

## Week 3: Functional Design

- Refactor one transformation into pure functions.
- Add tests.
- Remove hidden global dependencies.

## Week 4: Memory and Performance

- Profile one workflow.
- Inspect heap usage.
- Identify one avoidable allocation or repeated operation.

## Week 5: Resilience

- Add a retry policy.
- Simulate dependency failure.
- Add a circuit breaker or fallback.

## Week 6: Operations

- Add metrics.
- Improve structured logs.
- Write a runbook.
- Test graceful shutdown.

---

# 26. Final Reference Map

```text
Language behavior
    ├── MDN JavaScript Guide
    ├── ECMAScript specification
    └── You Don’t Know JS Yet

Runtime behavior
    ├── V8 documentation
    ├── Node.js Learn
    ├── Node.js API reference
    └── HTML Standard

Browser behavior
    ├── MDN Web APIs
    ├── Chrome DevTools
    └── Web Platform Tests

Performance
    ├── Node.js Diagnostics
    ├── V8 profiling
    ├── Chrome Performance panel
    └── MDN Performance API

Reliability
    ├── Release It!
    ├── AWS Builders’ Library
    ├── Google SRE books
    └── Circuit-breaker references

Security
    ├── OWASP Top Ten
    ├── OWASP Cheat Sheets
    ├── Node.js security guidance
    └── MDN Web Security

Observability
    ├── OpenTelemetry
    ├── Prometheus
    └── Grafana
```

---

# 27. Final Resource Strategy

Use resources in three modes.

## Learn

Read conceptual explanations:

- MDN.
- Books.
- Tutorials.
- SRE material.

## Verify

Check authoritative behavior:

- ECMAScript specification.
- HTML Standard.
- Node.js API documentation.
- Fetch Standard.

## Investigate

Diagnose actual applications:

- Browser DevTools.
- Node.js Inspector.
- CPU profiles.
- Heap snapshots.
- Event-loop monitoring.
- Logs and metrics.

The strongest learning cycle is:

```text
learn concept
    │
    ▼
write prediction
    │
    ▼
implement experiment
    │
    ▼
run and observe
    │
    ▼
check authoritative reference
    │
    ▼
apply to architecture
```

The purpose of these resources is not to collect links. It is to develop the ability to move from:

```text
What happened?
```

to:

```text
Why did it happen?
```

and then to:

```text
How should the application be designed because of it?
```
