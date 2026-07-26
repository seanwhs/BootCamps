# Appendix I: PulseQueue Troubleshooting Guide

This appendix collects common errors, symptoms, causes, and fixes encountered while building and operating the tutorial framework.

Before troubleshooting individual errors, run these baseline checks from the project root:

```bash
python --version
python -m pip show pulsequeue
python -m compileall -q src
python -m pytest -q
```

Recommended Python version:

```text
Python 3.12+
```

---

# 1. `ModuleNotFoundError: No module named 'pulsequeue'`

## Symptom

```text
ModuleNotFoundError: No module named 'pulsequeue'
```

## Common Causes

- The virtual environment is not active.
- The project was not installed.
- You are running Python from a different environment.
- You are not in the expected project directory.

## Fix

Activate the virtual environment.

### macOS or Linux

```bash
source .venv/bin/activate
```

### Windows PowerShell

```powershell
.venv\Scripts\Activate.ps1
```

Install the package in editable mode:

```bash
python -m pip install --editable .
```

Verify the import path:

```bash
python -c "import pulsequeue; print(pulsequeue.__file__)"
```

Expected path shape:

```text
.../mastering-python/src/pulsequeue/__init__.py
```

---

# 2. `RuntimeError: no running event loop`

## Symptom

```text
RuntimeError: no running event loop
```

## Cause

You called an `asyncio` API that requires an active event loop outside `async def`.

Example:

```python
import asyncio

task = asyncio.create_task(some_coroutine())
```

at module level.

## Fix

Create tasks only inside a coroutine that is running under an event loop.

```python
from __future__ import annotations

import asyncio


async def some_coroutine() -> None:
    await asyncio.sleep(0)


async def main() -> None:
    task = asyncio.create_task(some_coroutine())
    await task


if __name__ == "__main__":
    asyncio.run(main())
```

For PulseQueue, use the runtime boundary:

```python
async with PulseQueueRuntime(app) as runtime:
    receipt = await runtime.submit("examples.task_name")
    result = await receipt.result()
```

---

# 3. `RuntimeError: asyncio.run() cannot be called from a running event loop`

## Symptom

```text
RuntimeError: asyncio.run() cannot be called from a running event loop
```

## Cause

You called:

```python
asyncio.run(...)
```

from inside an already-running async environment.

This often occurs in:

- Jupyter notebooks;
- async web handlers;
- test frameworks;
- other coroutines.

## Fix

Inside async code, use `await`.

Bad:

```python
async def handler() -> None:
    asyncio.run(do_work())
```

Correct:

```python
async def handler() -> None:
    await do_work()
```

---

# 4. Task Submission Fails with `UnknownTaskError`

## Symptom

```text
UnknownTaskError: "Task 'emails.send_email' is not registered..."
```

## Common Causes

- The task decorator never ran.
- The module defining tasks was never imported.
- The stable task name is incorrect.
- The queue name or explicit task name differs from the submitted name.

## Fix

Inspect registered tasks:

```bash
pulsequeue --app examples.worker_application:app inspect
```

Or inspect in Python:

```python
from examples.worker_application import app

print(sorted(app.registered_tasks()))
```

Check the stable task name.

```python
@app.task(queue="emails")
async def send_email() -> None:
    ...
```

The registered name is:

```text
emails.send_email
```

If you use an explicit name:

```python
@app.task(queue="emails", name="send_welcome")
async def send_email() -> None:
    ...
```

the registered name is:

```text
emails.send_welcome
```

---

# 5. `TypeError: missing a required argument`

## Symptom

```text
TypeError: missing a required argument: 'user_id'
```

## Cause

PulseQueue validates task arguments before queue submission using the original Python function signature.

Example task:

```python
@app.task(queue="emails")
async def send_email(user_id: int, *, locale: str = "en-US") -> str:
    ...
```

Invalid submission:

```python
await runtime.submit("emails.send_email", locale="en-GB")
```

## Fix

Supply all required arguments:

```python
receipt = await runtime.submit(
    "emails.send_email",
    42,
    locale="en-GB",
)
```

Inspect the signature:

```python
task = app.get_task("emails.send_email")
print(task.signature)
```

---

# 6. Task Receipt Waits Forever

## Symptom

This code never returns:

```python
result = await receipt.result()
```

## Common Causes

- The runtime or worker was never started.
- The worker stopped before processing the task.
- A consumer retrieved work but did not call `task_done()`.
- Worker execution crashed before terminal state was recorded.
- The task is blocked in long-running code.
- The task is waiting indefinitely for an external dependency.

## Diagnose

Use a receipt timeout:

```python
result = await receipt.result(timeout_seconds=5.0)
```

Inspect task state:

```python
print(receipt.snapshot())
```

Inspect runtime health:

```python
from pulsequeue.health import runtime_health

print(runtime_health(runtime).as_dict())
```

Inspect queue state:

```python
print(runtime.broker.stats())
```

## Fix

Start the runtime before submission:

```python
async with PulseQueueRuntime(app) as runtime:
    receipt = await runtime.submit("examples.task_name")
    result = await receipt.result(timeout_seconds=5.0)
```

Ensure every queue consumer follows this pattern:

```python
item = await queue.get()

try:
    await process(item)
finally:
    queue.task_done()
```

---

# 7. `QueueClosedError: Cannot submit work: queue is closed`

## Symptom

```text
QueueClosedError: Cannot submit work: queue is closed.
```

## Cause

The worker has begun shutdown, which closes broker submissions.

Typical sequence:

```text
runtime.stop()
        ↓
broker closes
        ↓
new task submission rejected
```

## Fix

Submit work only while the runtime is active:

```python
async with PulseQueueRuntime(app) as runtime:
    receipt = await runtime.submit("examples.task_name")
    result = await receipt.result()
```

Check:

```python
print(runtime.is_running)
print(runtime.broker.is_closed)
```

Do not attempt to restart the same in-memory broker after shutdown. Create a new runtime.

---

# 8. `TaskFailureError` from Task Code

## Symptom

```text
TaskFailureError: Task 'examples.do_work' ... failed with ValueError: ...
```

## Cause

The task reached terminal `FAILED` state after:

- raising an exception;
- exhausting retry attempts;
- exceeding a configured timeout.

## Diagnose

```python
from pulsequeue import TaskFailureError


try:
    result = await receipt.result(timeout_seconds=5.0)
except TaskFailureError as error:
    print(error.task_id)
    print(error.task_name)
    print(error.failure.exception_type)
    print(error.failure.message)
```

Also inspect the final snapshot:

```python
snapshot = receipt.snapshot()

print(snapshot.state)
print(snapshot.attempt)
print(snapshot.max_attempts)
print(snapshot.failure)
```

## Fix

- Correct application task logic.
- Increase timeout only if the task is legitimately slow.
- Configure retries only for transient failures.
- Validate arguments before task execution.
- Add structured logging around external dependencies.

---

# 9. `OperationTimeoutError`

## Symptom

```text
OperationTimeoutError: Operation 'examples.slow_task' exceeded its timeout...
```

## Cause

Task execution exceeded:

```python
timeout_seconds
```

configured on the task.

Example:

```python
@app.task(queue="examples", timeout_seconds=0.1)
async def slow_task() -> str:
    await asyncio.sleep(1)
    return "done"
```

## Fix Options

### Option A: Make the task faster

Use efficient I/O, smaller work units, or parallelizable subtasks.

### Option B: Increase the timeout

```python
@app.task(queue="examples", timeout_seconds=5.0)
async def slow_task() -> str:
    ...
```

### Option C: Split the task

Instead of one large task:

```text
generate_entire_report
```

use several smaller tasks:

```text
fetch_data
process_chunk_1
process_chunk_2
assemble_report
```

### Option D: Use a CPU task

If the task is CPU-heavy Python code, do not keep it in the async event loop.

```python
@app.cpu_task(queue="analytics", timeout_seconds=30.0)
def generate_report(...) -> dict[str, object]:
    ...
```

---

# 10. Retry Behavior Is Unexpected

## Symptom

A task runs more or fewer times than expected.

## Rule

PulseQueue defines:

```text
max_retries = additional attempts after the first attempt
```

| `max_retries` | Maximum attempts |
|---:|---:|
| `0` | 1 |
| `1` | 2 |
| `2` | 3 |

Example:

```python
@app.task(queue="examples", max_retries=2)
async def retrying_task() -> None:
    ...
```

This task can run up to three times.

## Diagnose

```python
snapshot = receipt.snapshot()

print(f"State: {snapshot.state}")
print(f"Attempt: {snapshot.attempt}")
print(f"Maximum attempts: {snapshot.max_attempts}")
print(f"Next retry: {snapshot.next_retry_at}")
```

## Fix

Set retry configuration deliberately:

```python
@app.task(
    queue="integrations",
    max_retries=3,
    retry_delay_seconds=0.5,
    retry_backoff_multiplier=2.0,
)
async def fetch_partner_data() -> dict[str, str]:
    ...
```

---

# 11. Retry Wait Is Occupying a Worker Slot

## Symptom

A worker with low concurrency appears idle or slow while tasks are retrying.

## Cause

The tutorial implementation waits for retry delay inside the worker consumer:

```python
await asyncio.sleep(delay_seconds)
```

That is correct for the in-memory learning framework, but it occupies the consumer slot during the delay.

## Mitigation

Increase worker concurrency cautiously:

```python
PulseQueueRuntime(
    app,
    worker_concurrency=4,
)
```

For distributed production systems, use a durable delayed-message feature:

```text
Task fails
        ↓
Broker schedules delayed retry
        ↓
Worker slot returns immediately
```

---

# 12. `CancelledError` During Shutdown

## Symptom

A receipt raises:

```text
TaskCancelledError
```

or logs show cancellation during shutdown.

## Cause

The worker shutdown deadline expired, causing forced cancellation of active or queued work.

Example:

```python
await runtime.stop(timeout_seconds=0.1)
```

## Fix

If graceful completion is expected, increase the shutdown deadline:

```python
await runtime.stop(timeout_seconds=30.0)
```

Or set environment configuration:

```bash
export PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS=30
```

For long-running tasks, consider:

- breaking work into smaller tasks;
- checkpointing progress;
- using idempotent operations;
- adding resumable task payloads;
- moving CPU workloads to dedicated worker pools.

---

# 13. Important Correction: `mark_failed()` Must Receive the Exception

## Symptom

During a terminal task failure, you may see:

```text
TypeError: InMemoryBroker.mark_failed() missing 1 required positional argument: 'exception'
```

## Cause

The Part 15 `worker.py` listing contains a transcription defect in the terminal-failure branch.

Incorrect line:

```python
self._broker.mark_failed(envelope.task_id)
```

The broker API requires the actual exception:

```python
self._broker.mark_failed(
    task_id: str,
    exception: BaseException,
)
```

## Fix

In `src/pulsequeue/worker.py`, replace:

```python
self._broker.mark_failed(envelope.task_id)
```

with:

```python
self._broker.mark_failed(envelope.task_id, error)
```

The complete corrected branch is:

```python
if snapshot.attempt >= snapshot.max_attempts:
    self._broker.mark_failed(envelope.task_id, error)
    self._failed_tasks += 1

    await self._publish_event(
        TaskEventType.FAILED,
        self._result_snapshot(envelope.task_id),
        details={
            "exception_type": type(error).__name__,
            "exception_message": str(error),
        },
    )
    return
```

Verify immediately:

```bash
python -m pytest tests/test_broker_and_worker.py tests/test_retries_and_shutdown.py -q
```

Then run:

```bash
python -m pytest -q
```

This correction is required for task failures to be recorded correctly.

---

# 14. CPU Task Fails with Pickling Errors

## Symptom

Errors may resemble:

```text
AttributeError: Can't pickle local object ...
```

or:

```text
PicklingError: Can't pickle ...
```

## Common Causes

- CPU task function is nested inside another function.
- Function is a lambda.
- Arguments include unpickleable values.
- Return value includes an unpickleable value.
- The task captures closure state.
- A database connection, file handle, socket, or event loop is passed as an argument.

## Fix

Define CPU functions at module scope.

Correct:

## `my_application/cpu_tasks.py`

```python
from __future__ import annotations


def calculate_score(values: list[int]) -> int:
    """Calculate a simple CPU-bound score."""
    return sum(value * value for value in values)
```

Register from an application module:

```python
from my_application.cpu_tasks import calculate_score


app.cpu_task(queue="analytics")(calculate_score)
```

Submit only simple serializable values:

```python
receipt = await runtime.submit(
    "analytics.calculate_score",
    [1, 2, 3, 4],
)
```

Do not pass this:

```python
await runtime.submit(
    "analytics.calculate_score",
    database_connection,
)
```

---

# 15. CPU Task Appears to Ignore Cancellation

## Symptom

A CPU task continues consuming CPU after the caller times out or a worker begins shutdown.

## Cause

A process-pool function that has already started cannot be safely interrupted by ordinary `asyncio` cancellation.

Cancellation may stop the parent from waiting, but the child process can continue until the native or Python function returns.

## Mitigation

- Keep CPU tasks bounded.
- Split large CPU jobs into chunks.
- Add cooperative checkpoints where possible.
- Use OS-level process supervision only when necessary.
- Avoid very large monolithic calculations.
- Make tasks idempotent because retries or restarts may occur.

Example chunking approach:

```python
@app.cpu_task(queue="analytics")
def process_chunk(values: list[int]) -> int:
    return sum(value * value for value in values)
```

Submit several chunks instead of one enormous list.

---

# 16. `TypeError: CPU task ... must be defined at module scope`

## Symptom

```text
TypeError: CPU task 'main.<locals>.calculate' must be defined at module scope...
```

## Cause

The function was defined inside another function or method.

Bad:

```python
async def main() -> None:
    def calculate(value: int) -> int:
        return value * 2
```

## Fix

Move it to an importable module:

## `my_application/tasks.py`

```python
def calculate(value: int) -> int:
    return value * 2
```

Then import and register it.

---

# 17. CPU Process Pool Does Not Start on Windows or macOS

## Symptom

Unexpected repeated execution, recursive startup, or multiprocessing errors.

## Cause

Windows and macOS commonly use process-spawn behavior. Child processes import the module again.

## Fix

Protect top-level executable code:

```python
from __future__ import annotations

import asyncio


async def main() -> None:
    ...


if __name__ == "__main__":
    asyncio.run(main())
```

Do not start runtimes or submit CPU tasks at module import time.

Correct:

```python
app = PulseQueue("demo")


@app.cpu_task(queue="analytics")
def square(value: int) -> int:
    return value * value


async def main() -> None:
    async with PulseQueueRuntime(app) as runtime:
        receipt = await runtime.submit("analytics.square", 12)
        print(await receipt.result())


if __name__ == "__main__":
    asyncio.run(main())
```

---

# 18. `TaskSerializationError`

## Symptom

```text
TaskSerializationError: Value at $.args[0] has unsupported type set.
```

## Cause

The task envelope serializer allows only JSON-compatible values.

Unsupported examples:

```python
set()
datetime.now()
open("file.txt")
lambda: None
database_connection
```

## Fix

Convert values deliberately.

### Set to List

```python
sorted_tags = sorted({"priority", "onboarding"})
```

### Datetime to ISO-8601 String

```python
from datetime import UTC, datetime

created_at = datetime.now(UTC).isoformat()
```

### Domain Object to Dictionary

```python
payload = {
    "user_id": user.id,
    "email": user.email,
}
```

Do not serialize live objects such as database sessions, sockets, or callbacks.

---

# 19. CLI Cannot Load Application

## Symptom

```text
ApplicationLoadError: Could not import application module ...
```

or:

```text
ApplicationLoadError: Module ... has no attribute ...
```

## Cause

The CLI expects:

```text
package.module:attribute
```

Example:

```bash
pulsequeue --app examples.worker_application:app inspect
```

## Fix

Verify module import manually:

```bash
python -c "import examples.worker_application"
```

Verify attribute:

```bash
python - <<'PY'
from examples.worker_application import app

print(app)
PY
```

Verify the path uses a colon:

```text
examples.worker_application:app
```

Not:

```text
examples.worker_application.app
```

---

# 20. CLI `run` Cannot Receive Work Submitted from Another Terminal

## Symptom

You start:

```bash
pulsequeue --app examples.worker_application:app run
```

Then in another terminal you run:

```bash
pulsequeue --app examples.worker_application:app submit-local examples.greet --args '["Ada"]'
```

The worker process does not receive the submitted task.

## Cause

`InMemoryBroker` exists only inside one Python process.

The `run` command and `submit-local` command each create separate Python processes, each with a separate broker in memory.

## Fix

This is expected behavior for the tutorial broker.

Use `submit-local` only as a local complete execution demonstration.

For multi-process work, replace `InMemoryBroker` with a durable broker transport such as:

- Redis;
- RabbitMQ;
- Amazon SQS;
- PostgreSQL-backed queue;
- another authenticated shared transport.

Use the JSON task envelope serializer as the safe message boundary.

---

# 21. `pulsequeue: command not found`

## Symptom

```text
pulsequeue: command not found
```

## Cause

The package entry point has not been installed into the active environment.

## Fix

Activate the virtual environment:

```bash
source .venv/bin/activate
```

Reinstall:

```bash
python -m pip install --editable .
```

Verify:

```bash
python -m pip show pulsequeue
```

Use the module directly if needed:

```bash
python -m pulsequeue.cli check-config
```

---

# 22. Native Extension Build Fails

## Symptom

Installation fails near:

```text
native_module.c
```

or a compiler command fails.

## Cause

The optional extension requires a C compiler and Python development headers.

## Fix

### Ubuntu or Debian

```bash
sudo apt update
sudo apt install build-essential python3-dev
```

### Fedora

```bash
sudo dnf install gcc python3-devel
```

### macOS

```bash
xcode-select --install
```

### Windows

Install Visual Studio Build Tools with:

```text
Desktop development with C++
```

Then reinstall:

```bash
python -m pip install --editable .
```

The pure-Python framework can still function if you remove or disable the optional native extension configuration.

---

# 23. `ImportError: cannot import name '_native'`

## Symptom

```text
ImportError: cannot import name '_native' from 'pulsequeue'
```

## Cause

The extension did not build successfully, or the package was installed before the extension source/configuration existed.

## Fix

Rebuild:

```bash
python -m pip uninstall pulsequeue
python -m pip install --editable .
```

Verify compiled extension files:

```bash
find src/pulsequeue -name "_native*.so" -o -name "_native*.pyd"
```

On Windows, look for `.pyd`. On Linux or macOS, look for `.so`.

---

# 24. Plugin Does Not Receive Events

## Symptom

A plugin starts, but expected task events are absent.

## Common Causes

- Plugin registry was not passed to the worker or runtime.
- Plugin was not registered.
- Worker did not start successfully.
- Plugin event delivery raised an exception.
- The task was never executed.

## Correct Setup

```python
from pulsequeue import PluginRegistry, PulseQueueRuntime
from pulsequeue.builtin_plugins import InMemoryEventPlugin


plugins = PluginRegistry()
collector = InMemoryEventPlugin()

plugins.register(collector)

async with PulseQueueRuntime(
    app,
    plugins=plugins,
) as runtime:
    receipt = await runtime.submit("examples.task_name")
    await receipt.result()
```

Inspect event delivery failures:

```python
print(runtime.worker.stats().event_delivery_failures)
```

Inspect collected events:

```python
print([event.event_type.value for event in collector.events])
```

---

# 25. Plugin Failure Does Not Fail the Task

## Symptom

A task succeeds even though a plugin raises an exception.

## Cause

This is intentional.

PulseQueue isolates event-plugin failures from task execution. The worker records the count in:

```python
worker.stats().event_delivery_failures
```

## When to Change This Policy

For some compliance or audit workloads, you may require event persistence before accepting a completed task outcome.

That is a different reliability model and needs an explicit durable transactional design.

Do not casually change the worker so a console logging failure causes business task failure.

---

# 26. Worker Shutdown Hangs

## Symptom

The process remains alive during shutdown.

## Common Causes

- Task is blocked in non-cooperative synchronous code.
- A queue item was not marked `task_done()`.
- A retry wait is still pending.
- Process-pool work is still running.
- Plugin `stop()` never returns.
- External operation has no timeout.

## Diagnose

Check:

```python
print(runtime.worker.stats())
print(runtime.broker.stats())
```

Use a bounded shutdown:

```python
await runtime.stop(timeout_seconds=30.0)
```

Ensure task code uses timeouts around external calls.

```python
@app.task(queue="integrations", timeout_seconds=10.0)
async def call_partner() -> str:
    ...
```

Ensure plugin shutdown is bounded and does not wait forever.

---

# 27. Queue `join()` Hangs Forever

## Symptom

```python
await queue.join()
```

never completes.

## Cause

At least one retrieved item did not receive exactly one:

```python
queue.task_done()
```

## Fix

Always use `finally`.

```python
item = await queue.get()

try:
    await process(item)
finally:
    queue.task_done()
```

For stop sentinels, call `task_done()` too.

```python
if item is STOP_SIGNAL:
    return
```

must still execute inside a `try/finally` block.

---

# 28. Memory Grows Over Time

## Symptom

Worker process RSS or traced allocations increase during repeated workloads.

## Common Causes

- Results retained forever.
- Events retained forever.
- Background tasks never removed.
- Callback registry stores bound methods strongly.
- Raw exceptions or tracebacks are stored.
- Queue has unbounded capacity.
- Process pool has high per-process memory cost.

## Diagnose

Run:

```bash
python examples/46_memory_growth_workload.py
```

Use:

```python
from pulsequeue.memory_profiler import MemorySnapshotSession
```

Inspect retained collections:

```python
len(result_store._results)
len(event_collector.events)
len(background_tasks)
```

For production, avoid direct access to private fields; expose controlled metrics instead.

## Fix

- Add TTL or capacity limits to result storage.
- Use bounded retention.
- Use weak references for observers.
- Prune completed background tasks.
- Store exception summaries instead of raw exception objects.
- Bound queue sizes.

---

# 29. `FrozenInstanceError` When Modifying an Event

## Symptom

```text
dataclasses.FrozenInstanceError: cannot assign to field ...
```

## Cause

`TaskEvent` is intentionally immutable.

```python
@dataclass(frozen=True, slots=True)
class TaskEvent:
    ...
```

## Fix

Create a new event rather than modifying an old one.

```python
new_event = TaskEvent.create(
    event_type=TaskEventType.RETRYING,
    task_id=event.task_id,
    task_name=event.task_name,
    attempt=event.attempt + 1,
)
```

Historical events should remain stable after publication.

---

# 30. Quick Incident Triage Sequence

When a task system behaves unexpectedly, inspect in this order.

## 1. Confirm Process and Runtime State

```python
from pulsequeue.health import runtime_health

print(runtime_health(runtime).as_dict())
```

## 2. Inspect Worker Counters

```python
print(runtime.worker.stats())
```

## 3. Inspect Broker Queue State

```python
print(runtime.broker.stats())
```

## 4. Inspect Specific Receipt

```python
print(receipt.snapshot())
```

## 5. Inspect Registered Tasks

```python
print(sorted(app.registered_tasks()))
```

## 6. Inspect Structured Logs

Search by:

```text
task_id
task_name
attempt
state
exception_type
```

## 7. Reproduce with a Focused Test

```bash
python -m pytest tests/test_broker_and_worker.py -q
```

Then run the full suite:

```bash
python -m pytest -q
```
