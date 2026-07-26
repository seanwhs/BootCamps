# Mastering Python: Architecture, Internals & Concurrency  
## Student Notes

Use these notes as a compact companion to the tutorial and workbook.

---

# 1. Series Big Picture

## Main Goal

Understand how Python systems are:

- constructed;
- executed;
- extended;
- optimized;
- tested;
- operated under concurrent workload.

## Capstone

Build `pulsequeue`, an educational high-concurrency task framework.

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
Plugins / Logging / Health
```

## Core Rule

Choose technology based on workload:

| Workload | Preferred model |
|---|---|
| Fast local work | Normal synchronous function |
| Async network/database work | `asyncio` |
| Blocking I/O library | Thread |
| CPU-heavy pure Python | Process |
| Durable cross-machine work | Durable broker + worker fleet |

---

# 2. Python Runtime and Project Setup

## CPython

This series targets:

```text
CPython 3.12+
```

CPython is the standard Python implementation.

Important CPython-specific topics:

- Global Interpreter Lock;
- reference counting;
- cyclic garbage collection;
- C extension API;
- object memory layout.

## Virtual Environment

Create one per project:

```bash
python -m venv .venv
```

Activate on macOS/Linux:

```bash
source .venv/bin/activate
```

Activate on Windows PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

## Editable Install

Install the local package:

```bash
python -m pip install --editable .
```

Verify import source:

```bash
python -c "import pulsequeue; print(pulsequeue.__file__)"
```

Expected location:

```text
src/pulsequeue/__init__.py
```

## Preferred Command Style

Use:

```bash
python -m pip install ...
python -m pytest -q
python -m package.module
```

Avoid relying on ambiguous commands such as:

```bash
pip
pytest
python
```

when multiple Python environments may exist.

---

# 3. Functions, Classes, and Exceptions

## Function Shape

```python
def add(left: int, right: int) -> int:
    return left + right
```

- Parameters receive input.
- Return values provide output.
- Type hints document intended values.
- Runtime validation enforces untrusted input.

## Keyword-Only Configuration

```python
def submit(
    task_name: str,
    *,
    timeout_seconds: float,
) -> None:
    ...
```

Call:

```python
submit(
    "emails.send_welcome",
    timeout_seconds=5.0,
)
```

Use keyword-only arguments for configuration because they improve readability.

## Classes and Instances

```python
class TaskInfo:
    def __init__(self, task_id: str) -> None:
        self.task_id = task_id
```

```python
task = TaskInfo("task-001")
```

- Class: blueprint.
- Instance: one object created from blueprint.
- `self`: current instance.

## Exceptions

Raise clear errors:

```python
if timeout_seconds < 0:
    raise ValueError("timeout_seconds must be zero or greater.")
```

Catch expected errors:

```python
try:
    ...
except ValueError as error:
    print(error)
```

Always clean up resources:

```python
try:
    await perform_work()
finally:
    await close_resource()
```

---

# 4. Imports, Scope, and Decorators

## Imports Execute Module Code

When Python imports a module:

```python
import application.tasks
```

it runs top-level module code once per process.

This matters because decorators register tasks during import:

```python
@app.task(queue="emails")
async def send_email() -> str:
    ...
```

If the module is never imported, the task is never registered.

## Scope: LEGB

Python looks for names in this order:

```text
Local
Enclosing
Global
Built-in
```

Closures retain enclosing values:

```python
def make_prefix(queue: str):
    def format_name(task_name: str) -> str:
        return f"{queue}.{task_name}"

    return format_name
```

## Decorators

This:

```python
@decorator
def function() -> None:
    ...
```

means:

```python
def function() -> None:
    ...

function = decorator(function)
```

Decorator factory:

```python
@app.task(queue="emails")
async def send_email() -> str:
    ...
```

Conceptually:

```python
decorator = app.task(queue="emails")
send_email = decorator(send_email)
```

Use:

```python
functools.wraps(...)
```

to preserve function metadata.

---

# 5. Asyncio Notes

## Coroutine Function

```python
async def fetch_data() -> str:
    return "result"
```

Calling it creates a coroutine object:

```python
coroutine = fetch_data()
```

Run it with:

```python
result = await fetch_data()
```

or at program entry:

```python
asyncio.run(main())
```

## `await`

`await` pauses the current coroutine and lets the event loop run other ready work.

```python
await asyncio.sleep(0.5)
```

This does not block the event-loop thread.

## Blocking Is Different

Bad inside async code:

```python
time.sleep(1)
```

Better for blocking I/O:

```python
await asyncio.to_thread(blocking_function)
```

## Concurrent Coroutines

```python
first = asyncio.create_task(fetch_first())
second = asyncio.create_task(fetch_second())

first_result, second_result = await asyncio.gather(first, second)
```

## Cancellation

```python
task.cancel()
```

Inside coroutine:

```python
try:
    await do_work()
except asyncio.CancelledError:
    await cleanup()
    raise
```

Do not swallow `CancelledError` unless you have a very deliberate reason.

---

# 6. Threads, Processes, and the GIL

## Threads

Threads share memory within one process.

Useful for:

- blocking SDKs;
- synchronous HTTP libraries;
- blocking database clients;
- ordinary file operations.

```python
await asyncio.to_thread(blocking_function)
```

## Processes

Processes have separate memory and separate interpreters.

Useful for CPU-heavy Python work:

```python
@app.cpu_task(queue="analytics")
def count_primes(limit: int) -> int:
    ...
```

## The GIL

The CPython Global Interpreter Lock means:

> Only one thread at a time executes Python bytecode in one CPython process.

The GIL does **not** mean:

- Python cannot do concurrent I/O;
- threads are useless;
- Python cannot use multiple cores;
- all shared state is automatically thread-safe.

## Process Requirements

CPU task functions should be:

- module-level;
- ordinary `def`;
- importable;
- non-lambda;
- supplied with pickleable inputs;
- returning pickleable outputs.

Always use:

```python
if __name__ == "__main__":
    asyncio.run(main())
```

for process-safe application entry points.

---

# 7. Data Models

## Dataclass

```python
from dataclasses import dataclass


@dataclass
class TaskRecord:
    task_id: str
    attempt: int = 0
```

Useful for structured data.

## Immutable Snapshot

```python
@dataclass(frozen=True, slots=True)
class TaskSnapshot:
    task_id: str
    state: str
```

Use immutable models for:

- task events;
- result snapshots;
- metrics records;
- historical state.

## `slots=True`

Benefits:

- reduced per-instance overhead;
- prevents arbitrary attributes;
- useful for high-volume fixed-shape records.

Trade-off:

- less flexible;
- inheritance requires care;
- some objects need `__dict__` for metadata.

## Enums

Use `StrEnum` for fixed lifecycle values:

```python
class TaskState(StrEnum):
    QUEUED = "queued"
    RUNNING = "running"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
```

Avoid arbitrary strings such as:

```text
done
complete
finished
success
```

---

# 8. Metaprogramming Notes

## Class Creation

A class statement runs code.

```python
class Example:
    value = create_value()
```

Python:

1. creates a namespace;
2. executes class body;
3. creates the class object;
4. assigns class to its name.

## Metaclass

A normal class creates instances.

A metaclass creates classes.

Use a metaclass when behavior must happen during class definition:

- collect fields;
- register subclasses;
- validate class configuration;
- construct declarative APIs.

## Descriptor

A descriptor controls attribute access.

```python
class Field:
    def __get__(self, instance, owner):
        ...

    def __set__(self, instance, value):
        ...
```

Use descriptors for:

- validation;
- computed attributes;
- lazy loading;
- instrumentation;
- reusable field rules.

## Attribute Hooks

| Hook | When it runs |
|---|---|
| `__getattribute__` | Every attribute read |
| `__getattr__` | Only after normal lookup fails |
| `__setattr__` | Every attribute assignment |

Prefer `__getattr__` for fallback dynamic APIs.

---

# 9. Task Framework Notes

## Task Registration

Async task:

```python
@app.task(queue="emails")
async def send_email(user_id: int) -> str:
    ...
```

CPU task:

```python
@app.cpu_task(queue="analytics")
def count_primes(limit: int) -> int:
    ...
```

## Stable Task Name

```text
<queue>.<task_name>
```

Example:

```text
emails.send_email
analytics.count_primes
```

## Task Lifecycle

```text
QUEUED
  ↓
RUNNING
  ↓
RETRYING
  ↓
SUCCEEDED / FAILED / CANCELLED
```

## Task Submission

```python
receipt = await runtime.submit(
    "emails.send_email",
    42,
    locale="en-GB",
)
```

## Task Result

```python
result = await receipt.result(timeout_seconds=5.0)
```

Inspect state:

```python
snapshot = receipt.snapshot()

print(snapshot.state)
print(snapshot.attempt)
print(snapshot.max_attempts)
print(snapshot.failure)
```

---

# 10. Broker and Queue Notes

## Broker Responsibilities

The broker:

- creates task ID;
- creates task envelope;
- creates result record;
- queues the envelope;
- returns receipt.

The broker does not execute task code.

## Queue Backpressure

A bounded queue prevents unlimited memory growth.

```python
InMemoryBroker(max_queue_size=1_000)
```

When full:

```python
await queue.put(item)
```

waits for capacity.

## Queue Rule

Every:

```python
item = await queue.get()
```

must eventually have exactly one:

```python
queue.task_done()
```

Correct pattern:

```python
item = await queue.get()

try:
    await process(item)
finally:
    queue.task_done()
```

---

# 11. Retry Notes

## Meaning of `max_retries`

```text
max_retries = extra attempts after initial attempt
```

| `max_retries` | Total attempts |
|---:|---:|
| 0 | 1 |
| 1 | 2 |
| 2 | 3 |
| 3 | 4 |

## Exponential Backoff

```python
delay = retry_delay_seconds * (
    retry_backoff_multiplier ** (retry_number - 1)
)
```

Example:

```python
retry_delay_seconds = 0.25
retry_backoff_multiplier = 2.0
```

| Retry | Delay |
|---:|---:|
| 1 | 0.25 seconds |
| 2 | 0.50 seconds |
| 3 | 1.00 seconds |

## Retry Only Transient Failures

Usually retry:

```text
ConnectionError
TimeoutError
Temporary DNS failures
HTTP 429
HTTP 503
```

Usually do not retry:

```text
ValueError
PermissionError
Authentication failure
Malformed input
Unknown task name
```

---

# 12. Shutdown Notes

## Graceful Shutdown

```text
Close new submissions
    ↓
Drain accepted work
    ↓
Stop consumers
    ↓
Close process pool
    ↓
Stop plugins
```

## Forced Shutdown

```text
Graceful deadline expires
    ↓
Cancel active consumers
    ↓
Cancel pending queue messages
    ↓
Mark receipts cancelled
    ↓
Close resources
```

## Important Principle

Shutdown is not an afterthought.

A service must deliberately define:

- whether queued work drains;
- whether active work is cancelled;
- how long shutdown may take;
- what callers observe afterward.

---

# 13. CPython Memory Notes

## Reference Counting

CPython usually releases an object when its reference count reaches zero.

```python
value = {"task_id": "task-001"}

del value
```

## Cycles

Cycles need garbage collection:

```python
first.other = second
second.other = first
```

Use:

```python
gc.collect()
```

for diagnostics, not as normal application control flow.

## Common Memory Retention Sources

```text
Global lists
Unbounded result stores
Event history lists
Caches without eviction
Strong callback references
Stored exception objects
Completed background tasks
Queue contents
```

## Weak References

Use weak references when a registry should observe an object without owning it.

Useful for:

- callbacks;
- observers;
- parent links;
- caches.

## Memory Profiling

Use:

```python
from pulsequeue.memory_profiler import MemorySnapshotSession
```

Workflow:

```text
Start tracing
    ↓
Capture baseline
    ↓
Run workload
    ↓
Compare snapshots
    ↓
Find largest growth
    ↓
Find owning references
```

---

# 14. Typing and Protocol Notes

## Protocols

A protocol specifies required behavior.

```python
class LifecyclePlugin(Protocol):
    name: str

    async def start(self) -> None:
        ...

    async def stop(self) -> None:
        ...

    async def on_event(self, event: TaskEvent) -> None:
        ...
```

A class does not need to inherit from the protocol.

It only needs compatible methods and fields.

## Generics

Use generics to preserve type relationships:

```python
TaskReceipt[ResultT]
TaskResultSnapshot[ResultT]
```

## `ParamSpec`

Use `ParamSpec` when wrapping callables:

```python
ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")
```

This helps decorators preserve original function parameter shapes.

## `Any`

`Any` disables meaningful static type checking.

Use it only at dynamic boundaries, then validate and convert data quickly.

---

# 15. Plugin Notes

## Plugin Lifecycle

```text
Register plugins
    ↓
Start plugins in registration order
    ↓
Publish task events
    ↓
Stop plugins in reverse order
```

## Plugin Contract

```python
class ExamplePlugin:
    name = "example"

    async def start(self) -> None:
        ...

    async def stop(self) -> None:
        ...

    async def on_event(self, event: TaskEvent) -> None:
        ...
```

## Plugin Failure Policy

| Plugin phase | Expected policy |
|---|---|
| Startup fails | Runtime startup fails |
| Event handling fails | Task result remains unchanged; count diagnostic failure |
| Shutdown fails | Surface shutdown error |

---

# 16. Serialization Notes

## Safe Message Format

Task envelopes use JSON-compatible values.

Allowed:

```text
None
bool
int
finite float
str
list
tuple
dict with string keys
```

Rejected:

```text
set
datetime
function
lambda
database connection
file handle
socket
event loop
```

## Security Rule

Do not use `pickle` for untrusted task messages.

Why:

```text
Unpickling malicious data can execute arbitrary code.
```

Use JSON, MessagePack, Protobuf, Avro, or another deliberate data format.

---

# 17. Production Notes

## Current Limitation

`InMemoryBroker` is:

```text
Process-local
Non-durable
Not shared between terminals
Not shared between containers
Not shared between machines
```

## Production Requirements

A durable task system needs:

```text
Shared broker
Durable messages
Authentication
TLS
Acknowledgements
Visibility timeout / leases
Delayed retries
Dead-letter queue
Result retention
Metrics
Tracing
Idempotency
Schema versioning
```

## Idempotency

At-least-once delivery can run work more than once.

Use a stable business key:

```python
idempotency_key = f"invoice:{invoice_id}"
```

A task should produce the same business outcome even if redelivered.

---

# 18. Testing Notes

## Run Tests

```bash
python -m pytest -q
```

## Test Public Behavior

Prefer:

```python
assert app.task_count == 1
assert app.get_task("emails.send_email") is task
assert await receipt.result() == expected_value
```

Avoid tests that depend heavily on private internals:

```python
app._registry._tasks
```

## Test Failure Paths

Test:

- invalid task arguments;
- duplicate registration;
- retry success;
- retry exhaustion;
- timeout;
- cancellation;
- queue closure;
- plugin startup failure;
- serialization failure;
- graceful shutdown.

---

# 19. Command Cheat Sheet

Install project:

```bash
python -m pip install --editable .
```

Run tests:

```bash
python -m pytest -q
```

Compile source:

```bash
python -m compileall -q src
```

Inspect task app:

```bash
pulsequeue --app examples.worker_application:app inspect
```

Check configuration:

```bash
pulsequeue check-config
```

Run local async task:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  examples.greet \
  --args '["Ada"]'
```

Run local CPU task:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  analytics.square \
  --args '[12]'
```

---

# 20. Final Mental Model

```text
Python source
    ↓
CPython runtime
    ↓
Classes, functions, descriptors, decorators
    ↓
Task registration
    ↓
Validated task envelope
    ↓
Bounded broker queue
    ↓
Async worker or process worker
    ↓
Result state and receipt
    ↓
Events, plugins, logs, health
    ↓
Graceful shutdown and operational monitoring
```

## Final Rule Set

1. Validate at boundaries.
2. Keep internal contracts explicit.
3. Use `asyncio` for waiting.
4. Use threads for blocking I/O.
5. Use processes for CPU-heavy Python.
6. Bound queues and retention.
7. Make retries deliberate.
8. Make shutdown deliberate.
9. Measure memory and performance.
10. Treat distributed reliability as a separate engineering layer.
