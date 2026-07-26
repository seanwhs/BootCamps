# Mastering Python: Architecture, Internals & Concurrency  
## Student Workbook

Use this workbook alongside the tutorial series. It is designed for active learning: predict behavior, write code, verify results, and reflect on design choices.

---

# How to Use This Workbook

For each part:

1. Read the relevant tutorial section.
2. Complete the exercises without copying answers first.
3. Run the verification commands.
4. Record failures and discoveries.
5. Complete the reflection prompts.

Recommended workspace:

```text
mastering-python/
├── notes/
│   ├── workbook.md
│   └── solutions/
├── primer_examples/
├── examples/
├── src/
│   └── pulsequeue/
└── tests/
```

Create a workbook notes directory:

```bash
mkdir -p notes/solutions
```

---

# Part 0: Introduction

## Learning Goals

By the end of the series, you should be able to:

- Explain Python class construction and attribute lookup.
- Build descriptor- and metaclass-powered APIs.
- Choose between `asyncio`, threads, and processes.
- Explain CPython reference counting and cyclic garbage collection.
- Profile memory and identify retention risks.
- Design protocol-based plugins.
- Build and operate a high-concurrency task framework.

## Exercise 0.1 — Architecture Labeling

Label the responsibilities in this pipeline:

```text
Application
    ↓
Task Registry
    ↓
Broker
    ↓
Worker
    ↓
Result Backend
    ↓
Plugins
```

Write one sentence for each component.

| Component | Responsibility |
|---|---|
| Application | |
| Task Registry | |
| Broker | |
| Worker | |
| Result Backend | |
| Plugins | |

## Exercise 0.2 — Workload Classification

Classify each workload.

| Workload | Async I/O | Blocking I/O | CPU Bound | Why? |
|---|---:|---:|---:|---|
| Calling an async HTTP client | | | | |
| Calling `requests.get(...)` | | | | |
| Counting primes in a Python loop | | | | |
| Waiting for an `asyncio.Queue` item | | | | |
| Reading a large file through a synchronous SDK | | | | |

---

# Primer 1: Runtime, Packages, and Project Execution

## Exercise 1.1 — Environment Verification

Run:

```bash
python --version
python -c "import platform; print(platform.python_implementation())"
python -c "import sys; print(sys.executable)"
```

Record your output:

```text
Python version:
Implementation:
Executable:
```

## Exercise 1.2 — Editable Install Check

Run:

```bash
python -m pip install --editable .
python -c "import pulsequeue; print(pulsequeue.__file__)"
```

Answer:

1. Does the printed package path include `src/pulsequeue`?
2. Why is that important?
3. What problem does the `src/` layout help expose?

## Exercise 1.3 — Module Execution

Which command is preferred for package modules, and why?

```bash
python examples/60_cpu_task_worker.py
```

```bash
python -m examples.60_cpu_task_worker
```

Answer:

```text
Preferred command:
Reason:
```

---

# Primer 2: Functions, Classes, Exceptions, and Type Hints

## Exercise 2.1 — Function Validation

Write a function named `validate_queue_name`.

Requirements:

- Accept one `str` argument.
- Reject an empty string.
- Reject names that are not valid Python identifiers.
- Return the validated queue name.

Starter signature:

```python
def validate_queue_name(queue_name: str) -> str:
    ...
```

Verification:

```python
assert validate_queue_name("emails") == "emails"
assert validate_queue_name("analytics_jobs") == "analytics_jobs"
```

Expected failures:

```python
validate_queue_name("")
validate_queue_name("email-jobs")
```

## Exercise 2.2 — Class State

Create a `TaskCounter` class.

Requirements:

- Constructor accepts `task_name: str`.
- Initial count is zero.
- `increment()` adds one.
- `report()` returns:

```text
Task emails.send_welcome_email ran 2 time(s).
```

## Exercise 2.3 — Exception Design

Choose the best exception type for each situation.

| Situation | Best Exception |
|---|---|
| Task name is missing | |
| Requested task is absent from registry | |
| Queue capacity is invalid | |
| A task result has timed out | |
| Plugin name duplicates an existing plugin | |

---

# Primer 3: Imports, Scope, and Decorators

## Exercise 3.1 — Import-Time Registration

Explain why this task is registered when the module is imported:

```python
@app.task(queue="emails")
async def send_welcome_email(user_id: int) -> str:
    return f"Sent welcome email to {user_id}"
```

Answer:

```text
1.
2.
3.
```

## Exercise 3.2 — Decorator Expansion

Rewrite this decorator syntax without `@`:

```python
@app.task(queue="emails", max_retries=2)
async def send_email(user_id: int) -> str:
    return f"Sent to {user_id}"
```

Write the equivalent expanded code:

```python
# Your answer here
```

## Exercise 3.3 — Build a Mini Registry

Create a minimal decorator-based registry.

Requirements:

```python
registry = MiniRegistry()

@registry.register(group="math")
def add(left: int, right: int) -> int:
    return left + right
```

The registry should store:

```text
math.add → function
```

Verification:

```python
assert registry.tasks["math.add"](20, 22) == 42
```

---

# Primer 4: Asyncio Fundamentals

## Exercise 4.1 — Sequential Versus Concurrent

Predict the approximate total elapsed time.

```python
await asyncio.sleep(0.2)
await asyncio.sleep(0.3)
```

Prediction:

```text
Elapsed time:
```

Now predict:

```python
await asyncio.gather(
    asyncio.sleep(0.2),
    asyncio.sleep(0.3),
)
```

Prediction:

```text
Elapsed time:
```

Verify using `time.perf_counter()`.

## Exercise 4.2 — Fix the Blocking Task

This task blocks the event loop:

```python
import time


@app.task(queue="reports")
async def generate_report() -> str:
    time.sleep(1)
    return "report complete"
```

Rewrite it using `asyncio.to_thread(...)`.

```python
# Your answer here
```

## Exercise 4.3 — Cancellation

Write a coroutine that:

- prints `"started"`;
- waits repeatedly;
- catches `asyncio.CancelledError`;
- prints `"cleaning up"`;
- re-raises cancellation.

Verification target:

```text
started
cleaning up
caller observed cancellation
```

---

# Primer 5: Dataclasses, Enums, and Immutable State

## Exercise 5.1 — Task State Enum

Create this enum:

```python
class JobState(StrEnum):
    QUEUED = "queued"
    RUNNING = "running"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
```

Add a function:

```python
def is_terminal(state: JobState) -> bool:
    ...
```

Expected behavior:

```python
assert is_terminal(JobState.SUCCEEDED) is True
assert is_terminal(JobState.FAILED) is True
assert is_terminal(JobState.QUEUED) is False
```

## Exercise 5.2 — Immutable Snapshot

Create a frozen, slotted dataclass named `JobSnapshot`.

Fields:

```python
job_id: str
state: JobState
attempt: int
```

Verification:

```python
snapshot = JobSnapshot(
    job_id="job-001",
    state=JobState.QUEUED,
    attempt=0,
)

assert hasattr(snapshot, "__dict__") is False
```

Attempt to mutate `attempt`. What exception occurs?

```text
Exception:
```

## Exercise 5.3 — Mutable Default Trap

Why is this dangerous?

```python
@dataclass
class BadLog:
    messages: list[str] = []
```

Write the correct version.

```python
# Your answer here
```

---

# Primer 6: Threads, Processes, and the GIL

## Exercise 6.1 — Choose an Execution Strategy

Select the best execution model.

| Task | Direct | `asyncio` | Thread | Process |
|---|---:|---:|---:|---:|
| Validate a small JSON object | | | | |
| Call an async PostgreSQL driver | | | | |
| Call a blocking legacy SDK | | | | |
| Compute image pixels in pure Python | | | | |
| Run a NumPy operation that releases the GIL | | | | |

## Exercise 6.2 — Process Safety

Which functions are safe CPU task candidates?

```python
def top_level(value: int) -> int:
    return value * 2
```

```python
async def main() -> None:
    def nested(value: int) -> int:
        return value * 2
```

```python
multiply = lambda value: value * 2
```

| Function | Safe for `@app.cpu_task`? | Why? |
|---|---:|---|
| `top_level` | | |
| `nested` | | |
| `multiply` lambda | | |

## Exercise 6.3 — GIL Explanation

Complete this sentence:

> The GIL means that ________________________________________________.

Then complete this correction:

> The GIL does **not** mean that _____________________________________.

---

# Module 1: Metaprogramming and Dynamic Behavior

## Exercise M1.1 — Descriptor Validation

Create a descriptor named `PositiveInteger`.

Requirements:

- It accepts only integers greater than zero.
- It supports class access.
- It stores the value on the instance.
- It raises `TypeError` for non-integers.
- It raises `ValueError` for zero or negative values.

Usage target:

```python
class RetryPolicy:
    max_attempts = PositiveInteger()

    def __init__(self, max_attempts: int) -> None:
        self.max_attempts = max_attempts
```

Verification:

```python
policy = RetryPolicy(3)
assert policy.max_attempts == 3
```

## Exercise M1.2 — Dynamic Metadata

Why is this safer?

```python
options.meta_owner
```

than this?

```python
options.owner
```

Write two reasons:

1.  
2.  

## Exercise M1.3 — Introspection

Run:

```python
import inspect

task = app.get_task("emails.send_welcome_email")

print(task.name)
print(task.signature)
print(task.function.__module__)
print(task.function.__qualname__)
```

Record the answers for one of your own tasks:

```text
Task name:
Signature:
Module:
Qualified function name:
```

## Exercise M1.4 — Metaclass Decision

For each requirement, choose the simplest suitable tool.

| Requirement | Decorator | Descriptor | Metaclass | `__getattr__` |
|---|---:|---:|---:|---:|
| Register a function | | | | |
| Validate one attribute | | | | |
| Collect fields during class creation | | | | |
| Provide fallback dynamic metadata access | | | | |

---

# Module 2: Concurrent and Parallel Execution

## Exercise M2.1 — Bounded Queue Reasoning

A broker queue has:

```python
max_queue_size = 2
```

A producer submits three items while no consumer is running.

What happens?

```text
Item 1:
Item 2:
Item 3:
```

Why is this useful?

```text
Answer:
```

## Exercise M2.2 — Queue Accounting

Identify the bug:

```python
item = await queue.get()

if item == "stop":
    return

await process(item)
queue.task_done()
```

Fix it:

```python
# Your corrected code here
```

## Exercise M2.3 — Retry Calculation

A task has:

```python
max_retries = 3
retry_delay_seconds = 0.25
retry_backoff_multiplier = 2.0
```

Complete the table.

| Retry Number | Delay |
|---:|---:|
| 1 | |
| 2 | |
| 3 | |

How many total attempts are possible?

```text
Answer:
```

## Exercise M2.4 — Failure Classification

Classify each error.

| Error | Retry? | Why? |
|---|---:|---|
| `ConnectionError` | | |
| `PermissionError` | | |
| HTTP 429 | | |
| `ValueError` from invalid input | | |
| Temporary DNS failure | | |

## Exercise M2.5 — Graceful Shutdown Sequence

Put these in order:

```text
A. Stop plugins
B. Close broker submissions
C. Stop process pool
D. Drain or cancel consumers
E. Publish final task events
```

Correct order:

```text
1.
2.
3.
4.
5.
```

---

# Module 3: CPython Internals and Memory

## Exercise M3.1 — Reference Ownership

For each reference, choose the correct rule.

| Reference Type | Rule |
|---|---|
| New C API reference | |
| Borrowed C API reference | |

Complete:

```text
New reference:
Borrowed reference:
```

## Exercise M3.2 — Identify Retention Risks

Which code snippets may retain memory indefinitely?

```python
completed_results.append(result)
```

```python
cache[key] = value
```

```python
task.add_done_callback(background_tasks.discard)
```

```python
event_collector.events.append(event)
```

| Snippet | Risk? | Why? |
|---|---:|---|
| `completed_results.append(...)` | | |
| `cache[...] = ...` | | |
| `background_tasks.discard` callback | | |
| event collector append | | |

## Exercise M3.3 — Weak References

When should you prefer a weak reference?

```text
A.
B.
C.
```

## Exercise M3.4 — Memory Investigation Plan

You observe memory growth after processing 100,000 tasks.

Write a five-step investigation plan.

1.  
2.  
3.  
4.  
5.  

Suggested tools:

```text
tracemalloc
gc
MemorySnapshotSession
runtime metrics
bounded retention
```

---

# Module 4: Protocols, Plugins, and Typing

## Exercise M4.1 — Protocol Compatibility

Does this class satisfy `LifecyclePlugin` structurally?

```python
class AuditPlugin:
    name = "audit"

    async def start(self) -> None:
        pass

    async def stop(self) -> None:
        pass

    async def on_event(self, event: TaskEvent) -> None:
        pass
```

Answer:

```text
Yes or no:
Why:
```

## Exercise M4.2 — Plugin Lifecycle Order

Two plugins are registered:

```text
metrics
audit
```

Write the expected lifecycle order.

```text
Startup:
Event delivery:
Shutdown:
```

## Exercise M4.3 — Plugin Failure Policy

A task succeeds, but a metrics plugin fails while receiving `task.succeeded`.

Should the task receipt become failed?

```text
Answer:
Reason:
```

Where should the failure be visible?

```text
Answer:
```

## Exercise M4.4 — Result Backend Decorator

Explain the relationship:

```text
CountingResultBackend
        ↓
InMemoryResultStore
```

Answer:

```text
CountingResultBackend:
InMemoryResultStore:
Why this pattern is useful:
```

---

# Capstone Lab 1: Build a Local Task Application

## Goal

Build a minimal application with:

- one async task;
- one CPU task;
- a runtime;
- task submission;
- receipt inspection.

## File

## `labs/lab_01_application.py`

```python
from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime


app = PulseQueue("workbook_lab")


@app.task(queue="messages")
async def greet(name: str) -> str:
    await asyncio.sleep(0.01)
    return f"Hello, {name}."


@app.cpu_task(queue="math")
def cube(value: int) -> int:
    return value * value * value


async def main() -> None:
    async with PulseQueueRuntime(
        app,
        worker_concurrency=2,
        cpu_processes=1,
    ) as runtime:
        greeting_receipt = await runtime.submit("messages.greet", "Ada")
        cube_receipt = await runtime.submit("math.cube", 4)

        greeting = await greeting_receipt.result(timeout_seconds=2.0)
        cube_result = await cube_receipt.result(timeout_seconds=2.0)

        print(greeting)
        print(cube_result)
        print(runtime.worker.stats())


if __name__ == "__main__":
    asyncio.run(main())
```

## Verification

Run:

```bash
python labs/lab_01_application.py
```

Expected output includes:

```text
Hello, Ada.
64
```

---

# Capstone Lab 2: Add Retry Behavior

## Goal

Create a task that fails once and succeeds on retry.

## Requirements

- Queue name: `integrations`
- Task name: `fetch_status`
- `max_retries=1`
- `retry_delay_seconds=0.01`
- First attempt raises `ConnectionError`
- Second attempt returns a dictionary

Expected final result:

```python
{
    "status": "active",
}
```

## Reflection

1. What is the final `snapshot.attempt`?
2. What is the final `snapshot.max_attempts`?
3. How many worker retry attempts should be recorded?

```text
Answer 1:
Answer 2:
Answer 3:
```

---

# Capstone Lab 3: Add an Event Plugin

## Goal

Create a plugin that counts task event types.

Starter design:

```python
class EventCountPlugin:
    name = "event_count"

    def __init__(self) -> None:
        self.counts: dict[str, int] = {}

    async def start(self) -> None:
        ...

    async def stop(self) -> None:
        ...

    async def on_event(self, event: TaskEvent) -> None:
        ...
```

Expected outcome after one successful task:

```python
{
    "task.started": 1,
    "task.succeeded": 1,
}
```

Bonus: run a retrying task and verify:

```python
{
    "task.started": 2,
    "task.retrying": 1,
    "task.succeeded": 1,
}
```

---

# Capstone Lab 4: Add a Custom Result Backend Decorator

## Goal

Create a result backend wrapper that prints every state transition.

Expected output pattern:

```text
created task-...
running task-...
succeeded task-...
```

Hint: implement the `ResultBackend` protocol by delegating to `InMemoryResultStore`.

Reflection:

```text
Why should the wrapper delegate storage instead of reimplementing all state logic?
```

---

# Capstone Lab 5: Serialize a Task Envelope

## Goal

Create a `TaskEnvelope`, serialize it to JSON, then restore it.

Required checks:

```python
assert restored.task_id == envelope.task_id
assert restored.task_name == envelope.task_name
assert restored.args == envelope.args
assert dict(restored.kwargs) == dict(envelope.kwargs)
```

Try these invalid values:

```python
{1, 2, 3}
datetime.now()
lambda: None
```

Record which exception type is raised:

```text
Exception:
```

---

# Final Self-Assessment

Rate each item from 1 to 5.

| Skill | Rating |
|---|---:|
| I can explain Python class creation. | |
| I can write a descriptor. | |
| I can explain metaclass use cases. | |
| I can distinguish `__getattr__` and `__getattribute__`. | |
| I can choose `asyncio`, threads, or processes deliberately. | |
| I can explain the GIL accurately. | |
| I can build cancellation-safe async code. | |
| I can use bounded queues and backpressure. | |
| I can explain retries and exponential backoff. | |
| I can explain CPython reference counting. | |
| I can investigate memory growth with `tracemalloc`. | |
| I can use protocols for plugin contracts. | |
| I can compose a runtime with plugins and result backends. | |
| I can describe why the current broker is not distributed. | |
| I can identify production requirements for durable task systems. | |

---

# Suggested Final Project Challenge

Build a `ReportPipeline` application with:

```text
Queue: reports
Task 1: fetch_report_data
Task 2: transform_report_data
Task 3: generate_summary
Task 4: save_report
```

Requirements:

- `fetch_report_data` is async I/O.
- `transform_report_data` is CPU-bound.
- `save_report` retries `ConnectionError`.
- Add an `InMemoryEventPlugin`.
- Add a `CountingResultBackend`.
- Print final health state.
- Serialize one task envelope.
- Add at least five pytest tests.

Success criteria:

```text
All tests pass.
Async and CPU work use separate execution paths.
Retries are visible in events.
Final results are readable through receipts.
No task is submitted after shutdown begins.
```
