# Mastering Python: Architecture, Internals & Concurrency  
## Trainer Guide

This guide is for instructors delivering the series as:

- instructor-led training;
- a multi-day workshop;
- an internal engineering academy;
- an advanced backend-development course;
- a self-paced cohort with guided labs.

The material is advanced, but the delivery approach should remain practical and beginner-friendly in explanation.

---

# 1. Training Overview

## Course Title

**Mastering Python: Architecture, Internals & Concurrency**

## Primary Outcome

Students build and understand `pulsequeue`, an educational high-concurrency Python task framework.

By the end, students should be able to:

- explain Python’s runtime object model;
- use descriptors, metaclasses, decorators, and introspection responsibly;
- choose between `asyncio`, threads, and processes;
- explain the CPython GIL accurately;
- build safe asynchronous workers;
- implement retries, cancellation, timeouts, and graceful shutdown;
- diagnose memory retention and reference cycles;
- use `__slots__` appropriately;
- design plugin systems with protocols;
- apply typed configuration and lifecycle composition;
- identify the difference between a local in-memory queue and a distributed production task platform.

---

# 2. Recommended Delivery Formats

| Format | Suggested Duration | Best For |
|---|---:|---|
| Intensive workshop | 5 days | Experienced engineering teams |
| Extended cohort | 8–10 weeks | Internal training programs |
| University-style course | 12–14 sessions | Deep practice and assessments |
| Self-paced guided series | Flexible | Senior developers with mentor support |
| Architecture bootcamp | 3 days | Leads, architects, framework maintainers |

---

# 3. Recommended Five-Day Workshop Agenda

## Day 1 — Python Runtime and Dynamic Object Model

| Block | Topic |
|---|---|
| Morning | Environment, package layout, imports, decorators |
| Morning | Class creation, metaclasses, descriptors |
| Afternoon | Dynamic attributes and controlled APIs |
| Afternoon | Introspection and dynamic task registration |
| Lab | Build descriptor-backed task options and registry |

## Day 2 — Asyncio and Concurrency

| Block | Topic |
|---|---|
| Morning | Event loops, coroutines, tasks, `await` |
| Morning | Cancellation, timeouts, async cleanup |
| Afternoon | GIL, threads, multiprocessing |
| Afternoon | Bounded queues and backpressure |
| Lab | Build in-memory broker and async worker |

## Day 3 — Reliability and Memory

| Block | Topic |
|---|---|
| Morning | Retries, backoff, task states, graceful shutdown |
| Morning | Receipt handling and failure isolation |
| Afternoon | CPython reference counting and cyclic garbage collection |
| Afternoon | `__slots__`, `tracemalloc`, weak references |
| Lab | Add retry policies and investigate memory retention |

## Day 4 — Typing, Plugins, and Architecture

| Block | Topic |
|---|---|
| Morning | Protocols, structural subtyping, generics |
| Morning | Plugin lifecycle and context managers |
| Afternoon | Result backend abstractions and typed settings |
| Afternoon | Runtime composition and operational boundaries |
| Lab | Add plugins and custom result backend decorators |

## Day 5 — Capstone and Production Thinking

| Block | Topic |
|---|---|
| Morning | CPU task execution and process pool boundaries |
| Morning | JSON serialization and safe message design |
| Afternoon | CLI, structured logging, health checks |
| Afternoon | Production architecture review and capstone demonstrations |
| Lab | Complete PulseQueue extension challenge |

---

# 4. Trainer Preparation Checklist

Before teaching, verify:

- [ ] Python 3.12 or newer is available.
- [ ] Every learner can create a virtual environment.
- [ ] `python -m pip install --editable .` works.
- [ ] `python -m pytest -q` works.
- [ ] Native extension build tooling is available, or the C extension section is clearly marked optional.
- [ ] Students understand that the broker is in-memory and process-local.
- [ ] Docker is optional, not required for core course completion.
- [ ] All source files use final corrected versions from Appendix J.
- [ ] Students have the Student Workbook and Student Notes.
- [ ] The PowerPoint deck is available for visual delivery.

Recommended instructor verification:

```bash
python --version
python -m pip install --editable .
python -m pytest -q
python -m compileall -q src
pulsequeue check-config
pulsequeue --app examples.worker_application:app inspect
```

---

# 5. Learner Prerequisites

Students should already be comfortable with:

- Python functions and classes;
- imports and packages;
- virtual environments;
- basic exceptions;
- command-line execution;
- dictionaries, lists, tuples, and loops;
- basic type hints;
- Git or source control basics.

Students do **not** need prior experience with:

- metaclasses;
- descriptors;
- `asyncio`;
- multiprocessing;
- CPython memory internals;
- protocols;
- C extensions.

---

# 6. Instructor Teaching Principles

## 6.1 Explain Before Abstracting

Do not begin with:

```python
class ModelMeta(type):
    ...
```

Begin with:

> “Python executes a class body, collects its attributes, and then creates a class object.”

Then show the metaclass.

## 6.2 Use Real-World Analogies Carefully

Recommended analogies:

| Topic | Analogy |
|---|---|
| Descriptor | Attribute receptionist or gatekeeper |
| Metaclass | Factory that builds class factories |
| Event loop | Restaurant server handling waiting tables |
| Queue | Loading dock with limited parking |
| Backpressure | Full loading dock makes trucks wait |
| Process | Separate workshop building |
| GIL | One shared whiteboard marker |
| Protocol | Electrical socket standard |
| Result backend | Package-tracking system |
| Plugin registry | Equipment rack with startup/shutdown order |

Avoid relying on analogies after students begin implementation. Return to exact technical behavior.

## 6.3 Teach the Failure Path

For each feature, ask:

```text
What happens when this fails?
```

Examples:

- What happens when a task argument is invalid?
- What happens when a retry exhausts?
- What happens when a plugin fails?
- What happens when shutdown occurs during retry sleep?
- What happens when a CPU task cannot be pickled?
- What happens when `task_done()` is forgotten?

---

# 7. Module-by-Module Trainer Notes

---

## Module 1: Metaprogramming and Dynamic Behavior

### Key Teaching Goal

Students should understand that Python classes and functions are runtime objects.

### Essential Concepts

- Class bodies execute.
- A class is an object.
- Metaclasses construct classes.
- Descriptors control attribute access.
- `__getattr__` is fallback lookup.
- `__getattribute__` intercepts all lookup.
- Decorators transform or register functions.
- Introspection supports framework behavior.

### Demonstration Sequence

1. Run class-body execution example.
2. Show descriptor validation.
3. Show `__set_name__`.
4. Show metaclass field collection.
5. Show task decorator registration.
6. Inspect function signature.
7. Show task namespace access.

### Instructor Prompt

Ask:

> “At what exact moment does a task become registered?”

Expected answer:

```text
When Python imports the module and executes the decorated function definition.
```

### Common Misconceptions

| Misconception | Correction |
|---|---|
| A class body is only a declaration | A class body is executable Python code |
| Metaclasses are required for all frameworks | Use them only for class-definition-time behavior |
| `__getattr__` runs for all attributes | It runs only after normal lookup fails |
| Dynamic APIs should accept every name | Dynamic APIs need schemas, prefixes, and clear errors |
| Decorators only log functions | Decorators can register, validate, wrap, cache, or transform functions |

### Recommended Lab

Students implement:

```python
class NonEmptyString:
    ...
```

Then use it in:

```python
class TaskDefinition:
    name = NonEmptyString()
    queue = NonEmptyString()
```

---

## Module 2: Concurrency and Parallel Execution

### Key Teaching Goal

Students should select execution models based on work type, not based on hype.

### Essential Concepts

- Concurrency is not the same as parallelism.
- `asyncio` is excellent for cooperative I/O waiting.
- Blocking calls freeze the event loop.
- Threads are useful for blocking I/O.
- Processes are useful for CPU-heavy pure Python.
- The GIL limits CPU-bound threads in CPython.
- Bounded queues provide backpressure.
- Cancellation must propagate.
- Shutdown is a lifecycle design problem.

### Demonstration Sequence

1. Run concurrent coroutine example.
2. Run event-loop blocking example.
3. Fix it with `asyncio.to_thread`.
4. Run CPU-bound thread experiment.
5. Run process pool example.
6. Build queue consumer with `task_done()`.
7. Demonstrate retry and shutdown.

### Instructor Prompt

Ask:

> “Why is `async def` alone not enough to make CPU-heavy code non-blocking?”

Expected answer:

```text
An async function only cooperates when it reaches await points. A long CPU loop without await blocks the event loop.
```

### Common Misconceptions

| Misconception | Correction |
|---|---|
| `async def` automatically makes code parallel | It only creates coroutine behavior |
| Threads solve all performance problems | Threads help blocking I/O; GIL limits CPU-bound Python threads |
| Processes share normal Python objects | Processes have separate memory |
| Cancellation instantly kills every operation | Cancellation is cooperative and model-dependent |
| Queue size is only a performance setting | Queue capacity is also a memory and reliability setting |

### Recommended Lab

Students build:

```python
AsyncWorkQueue
```

Requirements:

- bounded capacity;
- `put`;
- `get`;
- `task_done`;
- `join`;
- stop sentinels;
- graceful consumer shutdown.

---

## Module 3: CPython Internals and Memory

### Key Teaching Goal

Students should learn to ask:

> “What still references this object?”

rather than:

> “Why did garbage collection fail?”

### Essential Concepts

- CPython uses reference counting.
- Cycles require cyclic garbage collection.
- `__del__` is not reliable resource management.
- Weak references avoid accidental ownership.
- `__slots__` can reduce object overhead.
- `tracemalloc` identifies allocation growth.
- Process pools multiply memory use.
- Native extensions require strict ownership rules.

### Demonstration Sequence

1. Run reference counting example.
2. Run cycle collection example.
3. Demonstrate weak observers.
4. Compare slotted and non-slotted objects.
5. Run `tracemalloc` workload comparison.
6. Discuss result/event retention.
7. Optionally build and test native extension.

### Instructor Prompt

Ask:

> “If an object is still in memory, what is the most likely explanation?”

Expected answer:

```text
A live reference still exists somewhere in the object graph.
```

### Common Misconceptions

| Misconception | Correction |
|---|---|
| `gc.collect()` fixes memory leaks | It cannot collect reachable objects |
| `__del__` is a cleanup strategy | Use context managers and explicit close methods |
| `__slots__` always makes code better | Use only for high-volume fixed-shape objects |
| Low RSS means no memory issue | Python allocation and OS memory behavior differ |
| Weak references always solve leaks | Use only for relationships that should not own objects |

### Recommended Lab

Students create a deliberately leaky event collector, profile it with `tracemalloc`, then replace it with bounded retention.

---

## Module 4: Advanced Typing and Plugin Architecture

### Key Teaching Goal

Students should design extension points around behavior contracts rather than framework inheritance.

### Essential Concepts

- `Protocol`
- structural subtyping;
- `runtime_checkable`;
- `TypeVar`;
- `ParamSpec`;
- result backend protocol;
- plugin lifecycle;
- startup rollback;
- reverse shutdown;
- runtime composition.

### Demonstration Sequence

1. Show protocol-compatible class without inheritance.
2. Show generic transformer.
3. Register plugins.
4. Demonstrate plugin startup failure rollback.
5. Demonstrate event plugin failure isolation.
6. Wrap result backend with counter.
7. Build runtime from settings.

### Instructor Prompt

Ask:

> “Why is a protocol often better than a required base class for plugins?”

Expected answer:

```text
A protocol allows independent implementations as long as they provide the required behavior.
```

### Common Misconceptions

| Misconception | Correction |
|---|---|
| Protocols enforce runtime correctness completely | They primarily support static contracts; runtime checks are shallow |
| Every plugin should inherit a framework base class | Structural compatibility is often less coupled |
| A metrics plugin failure should fail a task | Observability failures should usually remain separate |
| Startup order and shutdown order are identical | Shutdown typically reverses startup dependency order |

### Recommended Lab

Students implement a `MetricsPlugin` that counts:

```text
task.started
task.retrying
task.succeeded
task.failed
task.cancelled
```

---

# 8. Capstone Delivery Guide

## Capstone Goal

Students integrate all major concepts into a functioning PulseQueue application.

## Required Capstone Features

- [ ] Async task registration.
- [ ] CPU task registration.
- [ ] Task signature validation.
- [ ] In-memory broker.
- [ ] Bounded queue.
- [ ] Worker concurrency.
- [ ] Task receipt.
- [ ] Retry logic.
- [ ] Timeout handling.
- [ ] Cancellation and forced shutdown.
- [ ] Event plugin registry.
- [ ] Typed runtime settings.
- [ ] JSON task serialization.
- [ ] Structured logging.
- [ ] Health snapshot.
- [ ] Tests.

## Suggested Capstone Scenario

Build a report-generation service.

```text
reports.fetch_data
reports.transform_data
reports.generate_summary
reports.save_report
```

Suggested mapping:

| Task | Execution Model |
|---|---|
| Fetch report data | Async I/O task |
| Transform large dataset | CPU task |
| Generate summary | Async or CPU depending on work |
| Save report to remote storage | Async I/O or blocking-I/O thread boundary |

## Required Reflection Questions

1. Why is `transform_data` a CPU task?
2. Which failures should retry?
3. What must be idempotent?
4. What happens if the worker stops during a retry delay?
5. What data should not enter the serialized task envelope?
6. What would need to change for multi-process submission?

---

# 9. Assessment Strategy

## Knowledge Checks

Use short oral or written questions during each module.

Examples:

1. What is the difference between `__getattr__` and `__getattribute__`?
2. Why does a process-pool function need module-level definition?
3. What does `max_retries=2` mean?
4. Why does every queue `get()` need `task_done()`?
5. Why should a plugin failure not usually fail a successful task?
6. Why is `pickle` unsafe for untrusted messages?
7. Why can a garbage collector not collect a reachable object?

## Practical Assessment

Ask learners to implement:

```text
A retrying task
A CPU task
A plugin
A custom result backend decorator
A health check
Five tests
```

## Rubric

| Category | Excellent | Satisfactory | Needs Work |
|---|---|---|---|
| Runtime design | Clear boundaries and correct lifecycle | Works with minor coupling | Unclear ownership or hidden global state |
| Concurrency choice | Correct async/thread/process choice | Mostly correct | CPU work blocks event loop or unsafe processes |
| Reliability | Retries, timeouts, cancellation handled | Partial failure handling | Missing cleanup or hung receipts |
| Typing | Precise public contracts | Basic hints present | Excessive `Any`, unclear APIs |
| Testing | Success and failure paths tested | Main path tested | Little or no automated testing |
| Operations | Health, logs, shutdown considered | Partial operational design | No lifecycle or observability thinking |

---

# 10. Suggested Instructor Demos

## Demo A — Event Loop Freeze

Show:

```python
time.sleep(1)
```

inside `async def`.

Then replace with:

```python
await asyncio.to_thread(...)
```

Teaching point:

```text
Async code is only responsive when it yields control.
```

---

## Demo B — Duplicate Task Registration

Show two tasks with same stable name.

Expected result:

```text
DuplicateTaskError
```

Teaching point:

```text
Silent replacement is dangerous in framework registries.
```

---

## Demo C — Retry Lifecycle

Use a task that fails once, then succeeds.

Show event order:

```text
task.started
task.retrying
task.started
task.succeeded
```

Teaching point:

```text
A retry is a new attempt, not a continuation of the old one.
```

---

## Demo D — Forced Shutdown

Submit a long-running task.

Call:

```python
await worker.stop(timeout_seconds=0.01)
```

Show:

```text
TaskCancelledError
```

Teaching point:

```text
Receipts must not wait forever after forced shutdown.
```

---

## Demo E — Memory Retention

Create a list that retains task events.

Use `tracemalloc`.

Then replace with `BoundedRetentionStore`.

Teaching point:

```text
The key question is ownership and reachability.
```

---

# 11. Common Student Problems

| Problem | Instructor Response |
|---|---|
| Student runs wrong Python interpreter | Use `python -m ...`; verify `sys.executable` |
| `pulsequeue` cannot import | Editable install; verify package path |
| CPU task pickling error | Move function to module scope |
| Event loop freezes | Find blocking call; use async client, thread, or process |
| Queue hangs | Check missing `task_done()` |
| Receipt never completes | Inspect worker state, queue stats, task state |
| Retry runs too many times | Explain `max_retries` means extra attempts |
| Plugin does not receive events | Confirm plugin registry passed into runtime |
| Memory grows | Identify retained list, cache, result store, or event collector |
| Student uses `pickle` for messages | Explain code execution risk and JSON boundary |

---

# 12. Recommended Homework

## Homework 1 — Dynamic Task Metadata

Extend `TaskMetadata` with:

```text
team
region
request_id
```

Requirements:

- validate types;
- reject unknown fields;
- add tests.

## Homework 2 — Retry Policy

Add a retry policy that retries only:

```python
ConnectionError
TimeoutError
```

Do not retry:

```python
ValueError
PermissionError
```

## Homework 3 — Metrics Plugin

Build a plugin that tracks:

```text
task count by event type
task count by task name
retry count
failure count
```

## Homework 4 — Result Retention

Implement a time-to-live result retention strategy.

Discuss:

- what happens when a receipt asks for an expired result;
- how to expose an `UnknownTaskResultError`;
- how to test expiration deterministically.

## Homework 5 — Durable Broker Design

Write a design document for replacing `InMemoryBroker` with Redis or RabbitMQ.

Include:

- message format;
- acknowledgements;
- retry scheduling;
- dead-letter queue;
- security;
- idempotency;
- observability.

---

# 13. Trainer Closing Discussion

Use these prompts at the end of the course.

1. Which part of Python’s runtime model was most surprising?
2. When would metaprogramming improve a system, and when would it make it worse?
3. What workload in your current systems is incorrectly using threads, async code, or processes?
4. Where might your systems retain memory unexpectedly?
5. Which extension points should be protocols rather than inheritance trees?
6. What would be required before deploying PulseQueue-like behavior across multiple machines?
7. Which production guarantees are business requirements rather than technical defaults?

---

# 14. Final Trainer Checklist

Before closing the training, verify that learners can:

- [ ] create and activate a virtual environment;
- [ ] install a project in editable mode;
- [ ] explain package imports and decorator registration;
- [ ] use descriptors and understand metaclass purpose;
- [ ] choose async, thread, or process execution;
- [ ] explain the GIL accurately;
- [ ] build cancellation-safe async code;
- [ ] use bounded queues and queue accounting;
- [ ] implement retries and backoff;
- [ ] explain CPython reference counting and cyclic GC;
- [ ] use `tracemalloc`;
- [ ] write protocol-compatible plugins;
- [ ] use runtime context managers;
- [ ] serialize task payloads safely;
- [ ] identify why the tutorial broker is not distributed;
- [ ] propose production durability and idempotency requirements.
