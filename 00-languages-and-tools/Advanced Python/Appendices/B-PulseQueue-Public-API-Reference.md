# Appendix B: PulseQueue Public API Reference

This appendix is a practical reference for the public interfaces built throughout the series.

Import most application-facing APIs from the package root:

```python
from pulsequeue import (
    InMemoryResultStore,
    PluginRegistry,
    PulseQueue,
    PulseQueueRuntime,
    PulseQueueSettings,
    PulseQueueWorker,
    TaskMetadata,
)
```

---

# 1. `PulseQueue`

```python
from pulsequeue import PulseQueue

app = PulseQueue("notifications")
```

`PulseQueue` is the application object. It owns task registration and validates task submission before work enters a broker.

## Constructor

```python
PulseQueue(name: str)
```

### Parameters

| Parameter | Description |
|---|---|
| `name` | Non-empty valid Python identifier for the application |

### Example

```python
app = PulseQueue("notifications")
```

Invalid:

```python
PulseQueue("notification-service")
```

The hyphen makes this invalid because application names are used in Python-facing namespaces.

---

## `@app.task(...)`

Registers an asynchronous I/O task.

```python
@app.task(
    queue="emails",
    name="send_welcome",
    max_retries=2,
    timeout_seconds=10.0,
    retry_delay_seconds=0.5,
    retry_backoff_multiplier=2.0,
)
async def send_welcome_email(user_id: int) -> str:
    return f"Sent welcome email to user {user_id}"
```

### Signature

```python
app.task(
    *,
    queue: str,
    name: str | None = None,
    max_retries: int = 0,
    timeout_seconds: float = 0.0,
    retry_delay_seconds: float = 0.1,
    retry_backoff_multiplier: float = 2.0,
    metadata: TaskMetadata | None = None,
)
```

### Requirements

- Decorated function must use `async def`.
- Queue name must be a valid Python identifier.
- Explicit task name, if supplied, must be a valid Python identifier.
- `max_retries` is the number of retries *after* the first attempt.

### Generated Stable Name

```python
@app.task(queue="emails")
async def send_welcome_email() -> None:
    ...
```

Creates:

```text
emails.send_welcome_email
```

---

## `@app.cpu_task(...)`

Registers a synchronous CPU-bound task.

```python
@app.cpu_task(queue="analytics", timeout_seconds=30.0)
def count_words(document: str) -> int:
    return len(document.split())
```

### Signature

```python
app.cpu_task(
    *,
    queue: str,
    name: str | None = None,
    max_retries: int = 0,
    timeout_seconds: float = 0.0,
    retry_delay_seconds: float = 0.1,
    retry_backoff_multiplier: float = 2.0,
    metadata: TaskMetadata | None = None,
)
```

### Requirements

CPU task functions must:

- use ordinary `def`, not `async def`;
- be defined at module scope;
- not be lambdas;
- use pickleable arguments and return values;
- be importable by worker child processes.

Good:

```python
# tasks/analytics.py

def count_primes(limit: int) -> int:
    ...
```

Unsafe:

```python
async def main() -> None:
    def count_primes(limit: int) -> int:
        ...
```

Nested functions cannot reliably be imported by spawned child processes.

---

## `app.submit(...)`

Submits a registered task through a broker.

```python
receipt = await app.submit(
    broker,
    "emails.send_welcome_email",
    42,
    locale="en-GB",
)
```

### Signature

```python
async def submit(
    broker: InMemoryBroker,
    task_name: str,
    /,
    *args: Any,
    **kwargs: Any,
) -> TaskReceipt[Any]
```

### Behavior

Before queueing, PulseQueue:

1. Looks up the task by stable name.
2. Validates arguments against the original function signature.
3. Creates a broker task envelope.
4. Returns a `TaskReceipt`.

---

## `app.get_task(...)`

Looks up a registered task.

```python
task = app.get_task("emails.send_welcome_email")
print(task.signature)
```

### Signature

```python
def get_task(name: str) -> Task[Any, Any] | CpuTask[Any, Any]
```

Raises:

```python
UnknownTaskError
```

when no matching task exists.

---

## `app.tasks`

Exposes a read-only dynamic task namespace.

```python
task = app.tasks.emails.send_welcome_email
```

This is useful for introspection and direct local invocation:

```python
result = await app.tasks.emails.send_welcome_email(42)
```

For CPU tasks, submit them through a runtime rather than calling them as ordinary async functions.

---

## `app.describe()`

Returns application and task metadata.

```python
details = app.describe()
```

Example shape:

```python
{
    "name": "notifications",
    "task_count": 1,
    "tasks": {
        "emails.send_welcome_email": {
            "name": "emails.send_welcome_email",
            "queue": "emails",
            "max_retries": 2,
            "timeout_seconds": 10.0,
            "signature": "(user_id: int) -> str",
        }
    },
}
```

---

# 2. `Task` and `CpuTask`

## `Task`

Represents a registered `async def` task.

```python
from pulsequeue.task import Task
```

Useful properties:

```python
task.name
task.function
task.options
task.signature
task.source_file
task.source_line
```

Direct execution:

```python
result = await task(42)
```

Argument validation without execution:

```python
task.bind_arguments(42)
```

Diagnostics:

```python
print(task.describe())
```

---

## `CpuTask`

Represents a registered synchronous CPU task.

```python
from pulsequeue.cpu_task import CpuTask
```

Useful properties match `Task`:

```python
cpu_task.name
cpu_task.function
cpu_task.options
cpu_task.signature
cpu_task.source_file
cpu_task.source_line
```

CPU tasks should normally be submitted through:

```python
receipt = await runtime.submit("analytics.count_primes", 100_000)
```

They are executed through a process pool by the worker.

---

# 3. `TaskOptions`

```python
from pulsequeue.options import TaskOptions
```

`TaskOptions` holds validated configuration for one task.

## Constructor

```python
TaskOptions(
    *,
    name: str,
    queue: str,
    max_retries: int = 0,
    timeout_seconds: float = 0.0,
    retry_delay_seconds: float = 0.1,
    retry_backoff_multiplier: float = 2.0,
    metadata: TaskMetadata | None = None,
)
```

## Important Properties

| Property | Meaning |
|---|---|
| `qualified_name` | `<queue>.<name>` |
| `max_retries` | Extra attempts after initial execution |
| `max_attempts` | `1 + max_retries` |
| `timeout_seconds` | Per-attempt timeout; `0.0` means no timeout |
| `has_timeout` | Whether timeout enforcement is enabled |
| `metadata` | Controlled task metadata |

### Retry Delay

```python
delay = options.retry_delay_for_attempt(1)
```

With:

```python
retry_delay_seconds = 0.5
retry_backoff_multiplier = 2.0
```

delays are:

```text
Retry 1: 0.5 seconds
Retry 2: 1.0 seconds
Retry 3: 2.0 seconds
```

---

# 4. `TaskMetadata`

```python
from pulsequeue import TaskMetadata
```

`TaskMetadata` is a validated dynamic metadata container.

## Allowed Fields

| Field | Type |
|---|---|
| `owner` | `str` |
| `service` | `str` |
| `environment` | `str` |
| `priority` | `int` |
| `trace_id` | `str` |

### Example

```python
metadata = TaskMetadata(
    owner="platform-team",
    service="notifications",
    environment="production",
    priority=10,
)

metadata.trace_id = "trace-abc-123"
```

Read values:

```python
print(metadata.owner)
print(metadata.as_dict())
```

Unknown fields fail loudly:

```python
metadata.owenr = "platform-team"
```

Raises `AttributeError` instead of silently accepting a typo.

---

# 5. `PulseQueueRuntime`

```python
from pulsequeue import PulseQueueRuntime
```

`PulseQueueRuntime` composes:

- an application;
- an in-memory broker;
- a worker;
- optional plugins;
- optional custom result backend.

## Basic Use

```python
async with PulseQueueRuntime(app) as runtime:
    receipt = await runtime.submit("math.add", 20, 22)
    result = await receipt.result(timeout_seconds=5.0)
```

## Constructor

```python
PulseQueueRuntime(
    app: PulseQueue,
    *,
    broker_max_queue_size: int = 1_000,
    worker_concurrency: int = 1,
    cpu_processes: int | None = None,
    plugins: PluginRegistry | None = None,
    result_backend: ResultBackend | None = None,
    shutdown_timeout_seconds: float = 30.0,
)
```

## Key Properties

```python
runtime.app
runtime.broker
runtime.worker
runtime.is_running
```

## Methods

```python
await runtime.start()
await runtime.stop()
receipt = await runtime.submit("queue.task_name", ...)
```

---

## `PulseQueueRuntime.from_settings(...)`

Builds a runtime from typed configuration.

```python
settings = PulseQueueSettings.from_environment()

runtime = PulseQueueRuntime.from_settings(
    app,
    settings,
)
```

### Signature

```python
PulseQueueRuntime.from_settings(
    app: PulseQueue,
    settings: PulseQueueSettings,
    *,
    plugins: PluginRegistry | None = None,
    result_backend: ResultBackend | None = None,
)
```

---

# 6. `PulseQueueSettings`

```python
from pulsequeue import PulseQueueSettings
```

Immutable runtime configuration.

## Constructor

```python
PulseQueueSettings(
    worker_concurrency=1,
    broker_max_queue_size=1_000,
    cpu_processes=None,
    shutdown_timeout_seconds=30.0,
)
```

## Environment Loading

```python
settings = PulseQueueSettings.from_environment()
```

## Environment Variables

| Variable | Type | Default |
|---|---:|---:|
| `PULSEQUEUE_WORKER_CONCURRENCY` | Positive integer | `1` |
| `PULSEQUEUE_BROKER_MAX_QUEUE_SIZE` | Positive integer | `1000` |
| `PULSEQUEUE_CPU_PROCESSES` | Positive integer or unset | unset |
| `PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS` | Non-negative float | `30.0` |

Example:

```bash
export PULSEQUEUE_WORKER_CONCURRENCY=4
export PULSEQUEUE_BROKER_MAX_QUEUE_SIZE=5000
export PULSEQUEUE_CPU_PROCESSES=2
export PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS=25
```

---

# 7. `PulseQueueWorker`

```python
from pulsequeue import PulseQueueWorker
from pulsequeue.broker import InMemoryBroker
```

The worker consumes broker messages and executes task definitions.

## Constructor

```python
PulseQueueWorker(
    app: PulseQueue,
    broker: InMemoryBroker,
    *,
    concurrency: int = 1,
    cpu_processes: int | None = None,
    plugins: PluginRegistry | None = None,
)
```

## Typical Usage

```python
broker = InMemoryBroker()

async with PulseQueueWorker(
    app,
    broker,
    concurrency=4,
    cpu_processes=2,
) as worker:
    receipt = await app.submit(broker, "emails.send_welcome_email", 42)
    result = await receipt.result()
```

## Methods

```python
await worker.start()
await worker.stop(timeout_seconds=30.0)
```

## Properties

```python
worker.state
worker.is_running
worker.plugins
```

## Statistics

```python
stats = worker.stats()
```

`WorkerStats` fields:

```python
stats.state
stats.concurrency
stats.completed_tasks
stats.failed_tasks
stats.cancelled_tasks
stats.retry_attempts
stats.event_delivery_failures
```

---

# 8. `InMemoryBroker`

```python
from pulsequeue.broker import InMemoryBroker
```

The current broker implementation stores queued envelopes in memory.

## Constructor

```python
InMemoryBroker(
    *,
    max_queue_size: int = 1_000,
    result_backend: ResultBackend | None = None,
)
```

## Important Warning

This broker is:

- local to one Python process;
- non-durable;
- unsuitable for cross-process task submission;
- unsuitable for distributed production workloads.

It is appropriate for:

- local development;
- unit tests;
- demonstrations;
- learning framework architecture.

## Useful Members

```python
broker.is_closed
broker.result_backend
broker.stats()
broker.result_snapshot(task_id)
```

---

# 9. `TaskReceipt`

```python
from pulsequeue import TaskReceipt
```

A receipt is a handle for observing one submitted task.

```python
receipt = await runtime.submit("math.add", 20, 22)
```

## Properties

```python
receipt.task_id
receipt.task_name
```

## Read Current State

```python
snapshot = receipt.snapshot()

print(snapshot.state)
print(snapshot.attempt)
print(snapshot.max_attempts)
```

## Wait for Final Result

```python
result = await receipt.result(timeout_seconds=5.0)
```

Possible outcomes:

| Task final state | Receipt behavior |
|---|---|
| `SUCCEEDED` | Returns task value |
| `FAILED` | Raises `TaskFailureError` |
| `CANCELLED` | Raises `TaskCancelledError` |
| Wait deadline exceeded | Raises `TimeoutError` |

---

# 10. Task Result Types

```python
from pulsequeue.result import (
    TaskFailure,
    TaskResultSnapshot,
    TaskState,
)
```

## `TaskState`

```python
TaskState.QUEUED
TaskState.RUNNING
TaskState.RETRYING
TaskState.SUCCEEDED
TaskState.FAILED
TaskState.CANCELLED
```

## `TaskResultSnapshot`

Important fields:

```python
snapshot.task_id
snapshot.task_name
snapshot.state
snapshot.submitted_at
snapshot.started_at
snapshot.completed_at
snapshot.attempt
snapshot.max_attempts
snapshot.next_retry_at
snapshot.value
snapshot.failure
```

Example:

```python
snapshot = receipt.snapshot()

if snapshot.state is TaskState.RETRYING:
    print(f"Next retry: {snapshot.next_retry_at}")
```

---

# 11. Result Backends

```python
from pulsequeue import InMemoryResultStore, ResultBackend
```

## `ResultBackend`

A protocol defining result storage behavior.

A compatible backend must provide:

```python
create(...)
mark_running(...)
mark_retrying(...)
mark_succeeded(...)
mark_failed(...)
mark_cancelled(...)
snapshot(...)
await wait_for_terminal_state(...)
```

## Default Backend

```python
backend = InMemoryResultStore()
```

## Counting Decorator

```python
from pulsequeue.result_backends import CountingResultBackend

backend = CountingResultBackend(InMemoryResultStore())
```

Retrieve transition counters:

```python
print(dict(backend.transition_counts()))
```

Expected shape:

```python
{
    "created": 10,
    "running": 12,
    "retrying": 2,
    "succeeded": 9,
    "failed": 1,
}
```

---

# 12. Plugin APIs

```python
from pulsequeue import PluginRegistry
```

## `PluginRegistry`

Registers and manages lifecycle plugins.

```python
plugins = PluginRegistry()
plugins.register(my_plugin)
```

Worker integration:

```python
runtime = PulseQueueRuntime(
    app,
    plugins=plugins,
)
```

## Plugin Contract

A compatible plugin needs:

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

No inheritance is required.

## Built-In Plugins

```python
from pulsequeue.builtin_plugins import (
    ConsoleEventPlugin,
    InMemoryEventPlugin,
)
```

### Console Plugin

```python
plugins.register(ConsoleEventPlugin())
```

### In-Memory Plugin

```python
collector = InMemoryEventPlugin()
plugins.register(collector)
```

After execution:

```python
for event in collector.events:
    print(event.event_type)
```

---

# 13. Event Types

```python
from pulsequeue.events import TaskEvent, TaskEventType
```

Available event types:

```python
TaskEventType.SUBMITTED
TaskEventType.STARTED
TaskEventType.RETRYING
TaskEventType.SUCCEEDED
TaskEventType.FAILED
TaskEventType.CANCELLED
```

Create an event manually:

```python
event = TaskEvent.create(
    event_type=TaskEventType.STARTED,
    task_id="task-001",
    task_name="emails.send_welcome_email",
    attempt=1,
    details={"queue": "emails"},
)
```

Task events are immutable and slot-based.

---

# 14. Serialization APIs

```python
from pulsequeue.serialization import (
    TaskSerializationError,
    ensure_json_value,
    envelope_from_json,
    envelope_to_json,
)
```

## Serialize an Envelope

```python
serialized = envelope_to_json(envelope)
```

## Restore an Envelope

```python
restored = envelope_from_json(serialized)
```

## JSON-Safe Value Validation

```python
validated = ensure_json_value(
    {
        "user_id": 42,
        "locale": "en-GB",
    }
)
```

Allowed values:

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

Rejected examples:

```python
{"tags": {"one", "two"}}     # set
{"when": datetime.now()}     # datetime
{"file": open("x.txt")}      # file handle
{"callback": lambda: None}   # function
```

---

# 15. Health APIs

```python
from pulsequeue.health import runtime_health
```

Create a health snapshot:

```python
health = runtime_health(runtime)
```

Check simple readiness:

```python
if health.is_healthy:
    print("Runtime is active.")
```

JSON-safe output:

```python
print(health.as_dict())
```

Key fields include:

```python
health.application_name
health.runtime_running
health.worker_state
health.worker_concurrency
health.broker_closed
health.broker_queued_items
health.broker_unfinished_tasks
health.completed_tasks
health.failed_tasks
health.cancelled_tasks
health.retry_attempts
health.event_delivery_failures
```

---

# 16. CLI Reference

After installation:

```bash
python -m pip install --editable .
```

use:

```bash
pulsequeue --help
```

## Validate Configuration

```bash
pulsequeue check-config
```

## Inspect Registered Tasks

```bash
pulsequeue \
  --app examples.worker_application:app \
  inspect
```

## Start Worker Process

```bash
pulsequeue \
  --app examples.worker_application:app \
  run
```

## Execute a Local Async Task

```bash
pulsequeue \
  --app examples.worker_application:app \
  submit-local \
  examples.greet \
  --args '["Ada"]'
```

## Execute a Local CPU Task

```bash
pulsequeue \
  --app examples.worker_application:app \
  submit-local \
  analytics.square \
  --args '[12]'
```

## Relevant CLI Environment Variables

```text
PULSEQUEUE_APP
PULSEQUEUE_LOG_LEVEL
PULSEQUEUE_WORKER_CONCURRENCY
PULSEQUEUE_BROKER_MAX_QUEUE_SIZE
PULSEQUEUE_CPU_PROCESSES
PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS
```

---

# 17. Common Exceptions

| Exception | Meaning |
|---|---|
| `DuplicateTaskError` | A task name is already registered |
| `UnknownTaskError` | No registered task matches a requested name |
| `TaskFailureError` | A task reached terminal failed state |
| `TaskCancelledError` | A task was cancelled |
| `QueueClosedError` | Work was submitted after queue closure |
| `OperationTimeoutError` | A task attempt exceeded configured timeout |
| `DuplicatePluginError` | Plugin name already exists in registry |
| `PluginLifecycleError` | Plugin startup, shutdown, or usage state is invalid |
| `TaskSerializationError` | Task payload is not JSON-safe or message shape is invalid |
| `ApplicationLoadError` | CLI application import path could not be loaded |

---

# 18. Minimal End-to-End Example

```python
from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime


app = PulseQueue("demo")


@app.task(
    queue="messages",
    max_retries=1,
    timeout_seconds=5.0,
)
async def greet(name: str) -> str:
    await asyncio.sleep(0)
    return f"Hello, {name}."


async def main() -> None:
    async with PulseQueueRuntime(
        app,
        worker_concurrency=2,
    ) as runtime:
        receipt = await runtime.submit("messages.greet", "Ada")

        result = await receipt.result(timeout_seconds=10.0)

        print(result)
        print(receipt.snapshot())


if __name__ == "__main__":
    asyncio.run(main())
```

Expected output begins with:

```text
Hello, Ada.
```
