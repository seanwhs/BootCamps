# Part 12: Context Managers and Plugin-Aware Worker Lifecycle

In Part 11, we created a plugin system. It can start plugins, stop them safely, and deliver lifecycle events.

Now we will connect that system to the worker.

The goal is to make task execution observable without hard-coding logging, metrics, or audit behavior into `PulseQueueWorker`.

Instead of this:

```python
print("task started")
print("task succeeded")
```

we will use this architecture:

```text
Worker changes task state
        ↓
Worker creates immutable TaskEvent
        ↓
Plugin registry publishes event
        ↓
Console plugin, metrics plugin, audit plugin, or custom plugin reacts
```

This is a key framework design pattern:

> Core code performs core work. Plugins observe or extend behavior through explicit contracts.

---

## Step 1: Define Event Delivery Policy

### The Target

Decide what happens when an observability plugin fails while a task is running.

### The Concept

Suppose a task succeeds, but a console, metrics, or audit plugin raises an exception:

```text
Task completed successfully
        ↓
Metrics plugin has a bug
        ↓
Should the task be marked FAILED?
```

For this framework, the answer is:

> No. A plugin failure must not change a successfully executed task into a failed task.

Task execution and observability are different concerns.

Think of a package delivery service:

- The delivery driver successfully delivers the package.
- The dashboard display fails to refresh.
- The package was still delivered.

We will record plugin-delivery failures in worker statistics. This makes the problem visible without corrupting task-result semantics.

---

## Step 2: Extend Worker Statistics

### The Target

Add an `event_delivery_failures` counter to worker diagnostics.

### The Concept

Metrics are only useful when they distinguish different categories of failure.

These are not equivalent:

```text
Task failed because application code raised ValueError.
```

```text
Task succeeded, but metrics plugin failed to publish an event.
```

The first is a task-execution failure. The second is an observability failure.

Keeping separate counters allows operations teams to investigate the correct system boundary.

### The Implementation

We will update the worker completely in the next step. The revised `WorkerStats` model will contain:

```python
event_delivery_failures: int
```

No file change is needed yet because the next step replaces the full implementation.

### The Verification

Continue to the next step. The completed worker example later in this part verifies that plugin event failures are counted without failing task execution.

---

## Step 3: Integrate `PluginRegistry` into `PulseQueueWorker`

### The Target

Update `PulseQueueWorker` so it:

- optionally owns a `PluginRegistry`;
- starts plugins before worker consumers begin processing;
- stops consumers before plugin shutdown;
- publishes task lifecycle events;
- isolates plugin-event failures from task execution;
- uses its existing async context-manager lifecycle safely.

### The Concept

The startup sequence must be deliberate:

```text
Start plugins
        ↓
Start worker consumers
        ↓
Accept and execute queued work
```

The shutdown sequence reverses the dependency order:

```text
Stop accepting work
        ↓
Drain or cancel worker consumers
        ↓
Stop plugins
```

Why stop plugins last?

Because workers may still need to emit final events such as:

```text
task.succeeded
task.failed
task.cancelled
```

If plugins stopped first, those final events would be lost.

This is the same principle as shutting down a theater:

1. Let the show finish.
2. Turn off stage equipment.
3. Close the building.

Do not close the building while performers are still on stage.

### The Implementation

Replace the complete worker module.

## `src/pulsequeue/worker.py`

```python
"""Asynchronous in-memory task workers for PulseQueue."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from enum import StrEnum
from types import TracebackType

from pulsequeue.app import PulseQueue
from pulsequeue.async_queue import STOP_SIGNAL
from pulsequeue.broker import InMemoryBroker
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.plugins import PluginRegistry
from pulsequeue.result import TaskResultSnapshot
from pulsequeue.timeouts import await_with_timeout


class WorkerState(StrEnum):
    """Represent the lifecycle state of a PulseQueueWorker."""

    CREATED = "created"
    RUNNING = "running"
    STOPPING = "stopping"
    STOPPED = "stopped"


@dataclass(frozen=True, slots=True)
class WorkerStats:
    """A snapshot of worker activity for logs, diagnostics, and metrics."""

    state: WorkerState
    concurrency: int
    completed_tasks: int
    failed_tasks: int
    cancelled_tasks: int
    retry_attempts: int
    event_delivery_failures: int


class PulseQueueWorker:
    """Consume in-memory broker tasks with optional lifecycle plugins.

    Plugins are started before consumer loops begin. During shutdown, consumer
    loops finish or are cancelled before plugins stop, allowing final task
    lifecycle events to reach event plugins.
    """

    def __init__(
        self,
        app: PulseQueue,
        broker: InMemoryBroker,
        *,
        concurrency: int = 1,
        plugins: PluginRegistry | None = None,
    ) -> None:
        """Configure a worker without starting plugins or consumers yet."""
        if concurrency < 1:
            raise ValueError("concurrency must be at least 1.")

        self._app = app
        self._broker = broker
        self._concurrency = concurrency
        self._plugins = plugins
        self._state = WorkerState.CREATED
        self._consumer_tasks: list[asyncio.Task[None]] = []

        self._completed_tasks = 0
        self._failed_tasks = 0
        self._cancelled_tasks = 0
        self._retry_attempts = 0
        self._event_delivery_failures = 0

    @property
    def state(self) -> WorkerState:
        """Return the current worker lifecycle state."""
        return self._state

    @property
    def is_running(self) -> bool:
        """Return whether consumer loops are actively receiving messages."""
        return self._state is WorkerState.RUNNING

    @property
    def plugins(self) -> PluginRegistry | None:
        """Return the optional plugin registry owned by this worker."""
        return self._plugins

    def stats(self) -> WorkerStats:
        """Return a stable snapshot of worker counters."""
        return WorkerStats(
            state=self._state,
            concurrency=self._concurrency,
            completed_tasks=self._completed_tasks,
            failed_tasks=self._failed_tasks,
            cancelled_tasks=self._cancelled_tasks,
            retry_attempts=self._retry_attempts,
            event_delivery_failures=self._event_delivery_failures,
        )

    async def start(self) -> None:
        """Start plugins first, then start one consumer per concurrency slot."""
        if self._state is not WorkerState.CREATED:
            raise RuntimeError(
                f"Worker cannot start from state {self._state!r}; "
                f"expected {WorkerState.CREATED!r}."
            )

        if self._broker.is_closed:
            raise RuntimeError("Cannot start worker because the broker is closed.")

        try:
            if self._plugins is not None:
                await self._plugins.start()

            self._consumer_tasks = [
                asyncio.create_task(
                    self._consume_forever(worker_number),
                    name=f"pulsequeue-worker-{self._app.name}-{worker_number}",
                )
                for worker_number in range(1, self._concurrency + 1)
            ]
        except BaseException:
            # If plugin startup succeeded but consumer setup fails, shut plugins
            # down before propagating the startup error to the caller.
            if self._plugins is not None:
                await self._plugins.stop()

            raise

        self._state = WorkerState.RUNNING

    async def stop(self, *, timeout_seconds: float = 0.0) -> None:
        """Gracefully stop consumers, then stop plugins.

        A timeout of zero waits indefinitely for accepted work to complete.
        A positive timeout forces cancellation after its deadline expires.
        """
        if timeout_seconds < 0:
            raise ValueError("timeout_seconds must be zero or greater.")

        if self._state is WorkerState.STOPPED:
            return

        if self._state is WorkerState.CREATED:
            self._state = WorkerState.STOPPED

            if self._plugins is not None:
                await self._plugins.stop()

            return

        if self._state is not WorkerState.RUNNING:
            raise RuntimeError(f"Worker cannot stop from state {self._state!r}.")

        self._state = WorkerState.STOPPING

        worker_shutdown_error: BaseException | None = None

        try:
            await self._broker.stop_workers(worker_count=self._concurrency)

            try:
                if timeout_seconds == 0:
                    await self._broker.join()
                else:
                    async with asyncio.timeout(timeout_seconds):
                        await self._broker.join()
            except TimeoutError:
                await self._force_stop()
            else:
                await asyncio.gather(*self._consumer_tasks)
        except BaseException as error:
            worker_shutdown_error = error
        finally:
            self._consumer_tasks.clear()
            self._state = WorkerState.STOPPED

            plugin_shutdown_error: BaseException | None = None

            if self._plugins is not None:
                try:
                    await self._plugins.stop()
                except BaseException as error:
                    plugin_shutdown_error = error

            if worker_shutdown_error is not None and plugin_shutdown_error is not None:
                raise BaseExceptionGroup(
                    "Worker and plugin shutdown both failed.",
                    [worker_shutdown_error, plugin_shutdown_error],
                )

            if worker_shutdown_error is not None:
                raise worker_shutdown_error

            if plugin_shutdown_error is not None:
                raise plugin_shutdown_error

    async def __aenter__(self) -> PulseQueueWorker:
        """Start the worker when entering an async context."""
        await self.start()
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Stop consumers and plugins when leaving an async context."""
        await self.stop()

    async def _force_stop(self) -> None:
        """Cancel active consumers and cancel still-queued task envelopes."""
        for consumer_task in self._consumer_tasks:
            consumer_task.cancel()

        await asyncio.gather(*self._consumer_tasks, return_exceptions=True)

        cancelled_queued_tasks = self._broker.cancel_pending()
        self._cancelled_tasks += cancelled_queued_tasks

        await self._broker.join()

    async def _consume_forever(self, worker_number: int) -> None:
        """Receive and execute task envelopes until a stop signal arrives."""
        while True:
            broker_item = await self._broker.get()

            try:
                if broker_item is STOP_SIGNAL:
                    return

                if not isinstance(broker_item, TaskEnvelope):
                    raise RuntimeError(
                        f"Worker {worker_number} received unexpected broker item "
                        f"{broker_item!r}."
                    )

                await self._execute_envelope(broker_item)
            finally:
                # Every broker get must have exactly one matching task_done call.
                self._broker.task_done()

    async def _execute_envelope(self, envelope: TaskEnvelope) -> None:
        """Execute one task and publish lifecycle events around state changes."""
        task = self._app.get_task(envelope.task_name)

        try:
            while True:
                self._broker.mark_running(envelope.task_id)

                running_snapshot = self._result_snapshot(envelope.task_id)

                await self._publish_event(
                    TaskEventType.STARTED,
                    running_snapshot,
                )

                try:
                    result = await await_with_timeout(
                        task(*envelope.args, **dict(envelope.kwargs)),
                        timeout_seconds=task.options.timeout_seconds,
                        operation_name=envelope.task_name,
                    )
                except Exception as error:
                    snapshot = self._result_snapshot(envelope.task_id)

                    if snapshot.attempt >= snapshot.max_attempts:
                        self._broker.mark_failed(envelope.task_id, error)

                        failed_snapshot = self._result_snapshot(envelope.task_id)

                        self._failed_tasks += 1

                        await self._publish_event(
                            TaskEventType.FAILED,
                            failed_snapshot,
                        )
                        return

                    retry_number = snapshot.attempt
                    delay_seconds = task.options.retry_delay_for_attempt(retry_number)

                    self._broker.mark_retrying(
                        envelope.task_id,
                        error,
                        delay_seconds=delay_seconds,
                    )

                    retrying_snapshot = self._result_snapshot(envelope.task_id)

                    self._retry_attempts += 1

                    await self._publish_event(
                        TaskEventType.RETRYING,
                        retrying_snapshot,
                        details={
                            "delay_seconds": delay_seconds,
                            "exception_type": type(error).__name__,
                            "exception_message": str(error),
                        },
                    )

                    # This wait is cancellation-sensitive. The outer
                    # CancelledError handler turns that state into CANCELLED.
                    await asyncio.sleep(delay_seconds)
                else:
                    self._broker.mark_succeeded(envelope.task_id, result)

                    succeeded_snapshot = self._result_snapshot(envelope.task_id)

                    self._completed_tasks += 1

                    await self._publish_event(
                        TaskEventType.SUCCEEDED,
                        succeeded_snapshot,
                        details={
                            "result_type": type(result).__name__,
                        },
                    )
                    return
        except asyncio.CancelledError:
            # A task may be cancelled while executing user code, during timeout
            # propagation, or while waiting for retry backoff.
            self._broker.mark_cancelled(envelope.task_id)

            cancelled_snapshot = self._result_snapshot(envelope.task_id)

            self._cancelled_tasks += 1

            await self._publish_event(
                TaskEventType.CANCELLED,
                cancelled_snapshot,
            )

            raise

    async def _publish_event(
        self,
        event_type: TaskEventType,
        snapshot: TaskResultSnapshot[object],
        *,
        details: dict[str, object] | None = None,
    ) -> None:
        """Publish one event without changing the task's execution outcome."""
        if self._plugins is None:
            return

        event = TaskEvent.create(
            event_type=event_type,
            task_id=snapshot.task_id,
            task_name=snapshot.task_name,
            attempt=snapshot.attempt,
            details=details,
        )

        try:
            await self._plugins.publish(event)
        except Exception:
            # Plugins are observability and extension boundaries. A plugin
            # failure must be visible through worker statistics but must not
            # change task success, failure, retry, or cancellation semantics.
            self._event_delivery_failures += 1

    def _result_snapshot(self, task_id: str) -> TaskResultSnapshot[object]:
        """Return one task result snapshot through the broker public API."""
        return self._broker.result_snapshot(task_id)
```

### The Verification

Compile all framework code:

```bash
python -m compileall -q src
```

No output means the source compiled successfully.

---

## Step 4: Run a Worker with Console and In-Memory Plugins

### The Target

Verify that a task worker publishes `STARTED`, `RETRYING`, and `SUCCEEDED` events to plugins.

### The Concept

The worker should remain focused on task execution. Plugins receive immutable event objects and decide what to do:

- print them;
- store them;
- send them to a metrics service;
- emit audit records;
- trigger local development debugging.

### The Implementation

Create this complete example.

## `examples/53_plugin_aware_worker.py`

```python
"""Execute retrying tasks while plugins observe worker lifecycle events."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueWorker
from pulsequeue.broker import InMemoryBroker
from pulsequeue.builtin_plugins import ConsoleEventPlugin, InMemoryEventPlugin
from pulsequeue.plugins import PluginRegistry


app = PulseQueue("plugin_worker_demo")

attempts = {"count": 0}


@app.task(
    queue="examples",
    max_retries=1,
    retry_delay_seconds=0.01,
)
async def fetch_partner_status(partner_id: str) -> dict[str, str]:
    """Fail once, then return a small successful partner-status payload."""
    attempts["count"] += 1

    if attempts["count"] == 1:
        raise ConnectionError("Partner service is temporarily unavailable.")

    await asyncio.sleep(0)

    return {
        "partner_id": partner_id,
        "status": "active",
    }


async def main() -> None:
    """Start plugins and worker, then inspect the collected event history."""
    broker = InMemoryBroker()
    plugins = PluginRegistry()
    memory_events = InMemoryEventPlugin()

    plugins.register(ConsoleEventPlugin())
    plugins.register(memory_events)

    async with PulseQueueWorker(
        app,
        broker,
        concurrency=1,
        plugins=plugins,
    ) as worker:
        receipt = await app.submit(
            broker,
            "examples.fetch_partner_status",
            "partner-123",
        )

        result = await receipt.result(timeout_seconds=1.0)

        print(f"\nTask result: {result}")
        print(f"Worker statistics: {worker.stats()}")

    print("\nCollected event types:")

    for event in memory_events.events:
        print(
            f"- {event.event_type.value} "
            f"attempt={event.attempt} "
            f"details={event.details_as_dict()}"
        )


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/53_plugin_aware_worker.py
```

Expected output includes lines similar to:

```text
task.started task_id=...
task.retrying task_id=...
task.started task_id=...
task.succeeded task_id=...

Task result: {'partner_id': 'partner-123', 'status': 'active'}
```

The final collected event types should appear in this order:

```text
- task.started attempt=1 details={}
- task.retrying attempt=1 details={...}
- task.started attempt=2 details={}
- task.succeeded attempt=2 details={'result_type': 'dict'}
```

The exact timestamp and generated task ID naturally differ.

---

## Step 5: Verify Plugin Failures Do Not Fail Tasks

### The Target

Create a deliberately broken plugin and confirm that a successful task remains successful.

### The Concept

A plugin is an extension boundary. Extension code can contain bugs.

The worker should isolate those bugs from task execution.

This does **not** mean plugin failures should be ignored. The worker increments:

```python
event_delivery_failures
```

That counter can later feed alerts and metrics.

### The Implementation

Create this example.

## `examples/54_plugin_failure_isolation.py`

```python
"""Demonstrate that plugin failures do not change task execution results."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueWorker
from pulsequeue.broker import InMemoryBroker
from pulsequeue.events import TaskEvent
from pulsequeue.plugins import PluginRegistry


class BrokenEventPlugin:
    """A plugin that always fails while receiving lifecycle events."""

    name = "broken_events"

    async def start(self) -> None:
        """Start successfully so event delivery is the failing operation."""
        return None

    async def stop(self) -> None:
        """Stop successfully."""
        return None

    async def on_event(self, event: TaskEvent) -> None:
        """Raise an intentional plugin failure."""
        raise RuntimeError(
            f"Cannot publish {event.event_type.value} in this demonstration."
        )


app = PulseQueue("plugin_failure_demo")


@app.task(queue="examples")
async def double(value: int) -> int:
    """Return a successful result despite a broken observer plugin."""
    await asyncio.sleep(0)
    return value * 2


async def main() -> None:
    """Run one successful task with a plugin that fails on every event."""
    broker = InMemoryBroker()
    plugins = PluginRegistry()

    plugins.register(BrokenEventPlugin())

    async with PulseQueueWorker(
        app,
        broker,
        plugins=plugins,
    ) as worker:
        receipt = await app.submit(broker, "examples.double", 21)

        result = await receipt.result(timeout_seconds=1.0)

        print(f"Task result: {result}")
        print(f"Task state: {receipt.snapshot().state}")
        print(f"Worker statistics: {worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/54_plugin_failure_isolation.py
```

Expected output includes:

```text
Task result: 42
Task state: succeeded
```

The worker statistics should include:

```text
completed_tasks=1
event_delivery_failures=2
```

There are two failed event deliveries:

1. `task.started`
2. `task.succeeded`

The task itself still succeeds.

---

## Step 6: Add a Context-Managed Application Runtime

### The Target

Create `PulseQueueRuntime`, a higher-level async context manager that owns:

- one application;
- one in-memory broker;
- one worker;
- optional plugins.

### The Concept

Creating all runtime components manually is flexible:

```python
broker = InMemoryBroker()
plugins = PluginRegistry()
worker = PulseQueueWorker(app, broker, plugins=plugins)

await worker.start()
```

But most applications need a simpler operational boundary:

```python
async with PulseQueueRuntime(app) as runtime:
    receipt = await runtime.submit("emails.send_welcome_email", 42)
    result = await receipt.result()
```

A runtime is like a pre-wired control room. It starts related components in the right order and shuts them down safely in reverse order.

### The Implementation

Create the runtime module.

## `src/pulsequeue/runtime.py`

```python
"""High-level async runtime composition for PulseQueue applications."""

from __future__ import annotations

from types import TracebackType
from typing import Any, Self

from pulsequeue.app import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.plugins import PluginRegistry
from pulsequeue.result import TaskReceipt
from pulsequeue.worker import PulseQueueWorker


class PulseQueueRuntime:
    """Own a broker, worker, and optional plugins for one application runtime."""

    def __init__(
        self,
        app: PulseQueue,
        *,
        broker_max_queue_size: int = 1_000,
        worker_concurrency: int = 1,
        plugins: PluginRegistry | None = None,
    ) -> None:
        """Configure a runtime without starting its worker yet."""
        self._app = app
        self._broker = InMemoryBroker(max_queue_size=broker_max_queue_size)
        self._worker = PulseQueueWorker(
            app,
            self._broker,
            concurrency=worker_concurrency,
            plugins=plugins,
        )
        self._is_running = False

    @property
    def app(self) -> PulseQueue:
        """Return the application whose tasks this runtime executes."""
        return self._app

    @property
    def broker(self) -> InMemoryBroker:
        """Return the runtime-owned in-memory broker."""
        return self._broker

    @property
    def worker(self) -> PulseQueueWorker:
        """Return the runtime-owned worker."""
        return self._worker

    @property
    def is_running(self) -> bool:
        """Return whether the worker runtime is active."""
        return self._is_running

    async def start(self) -> None:
        """Start plugins and worker consumers."""
        if self._is_running:
            raise RuntimeError("PulseQueueRuntime is already running.")

        await self._worker.start()
        self._is_running = True

    async def stop(self, *, timeout_seconds: float = 0.0) -> None:
        """Stop worker execution and owned plugins."""
        if not self._is_running:
            return

        try:
            await self._worker.stop(timeout_seconds=timeout_seconds)
        finally:
            self._is_running = False

    async def submit(
        self,
        task_name: str,
        /,
        *args: Any,
        **kwargs: Any,
    ) -> TaskReceipt[Any]:
        """Submit one registered task through this runtime's broker."""
        if not self._is_running:
            raise RuntimeError(
                "PulseQueueRuntime is not running. Use 'async with "
                "PulseQueueRuntime(app) as runtime:' before submitting work."
            )

        return await self._app.submit(
            self._broker,
            task_name,
            *args,
            **kwargs,
        )

    async def __aenter__(self) -> Self:
        """Start the composed runtime when entering an async context."""
        await self.start()
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Stop all runtime-owned components when leaving an async context."""
        await self.stop()
```

Update package exports.

## `src/pulsequeue/__init__.py`

```python
"""PulseQueue: an educational high-concurrency Python task framework."""

from pulsequeue.app import PulseQueue
from pulsequeue.execution import WorkloadKind
from pulsequeue.metadata import TaskMetadata
from pulsequeue.plugins import (
    DuplicatePluginError,
    PluginLifecycleError,
    PluginRegistry,
    PluginRegistryState,
)
from pulsequeue.registry import DuplicateTaskError, UnknownTaskError
from pulsequeue.result import (
    TaskCancelledError,
    TaskFailureError,
    TaskReceipt,
    TaskState,
)
from pulsequeue.runtime import PulseQueueRuntime
from pulsequeue.task import Task
from pulsequeue.worker import PulseQueueWorker

__all__ = [
    "DuplicatePluginError",
    "DuplicateTaskError",
    "PluginLifecycleError",
    "PluginRegistry",
    "PluginRegistryState",
    "PulseQueue",
    "PulseQueueRuntime",
    "PulseQueueWorker",
    "Task",
    "TaskCancelledError",
    "TaskFailureError",
    "TaskMetadata",
    "TaskReceipt",
    "TaskState",
    "UnknownTaskError",
    "WorkloadKind",
]

__version__ = "0.1.0"
```

### The Verification

Create a runtime demonstration.

## `examples/55_runtime_context_manager.py`

```python
"""Run a PulseQueue application through its high-level async runtime."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime
from pulsequeue.builtin_plugins import InMemoryEventPlugin
from pulsequeue.plugins import PluginRegistry


app = PulseQueue("runtime_demo")


@app.task(queue="math")
async def multiply(left: int, right: int) -> int:
    """Return one multiplication result."""
    await asyncio.sleep(0)
    return left * right


async def main() -> None:
    """Start the runtime, submit a task, and inspect lifecycle events."""
    plugins = PluginRegistry()
    event_collector = InMemoryEventPlugin()

    plugins.register(event_collector)

    async with PulseQueueRuntime(
        app,
        worker_concurrency=2,
        plugins=plugins,
    ) as runtime:
        print(f"Runtime started: {runtime.is_running}")

        receipt = await runtime.submit("math.multiply", 6, 7)
        result = await receipt.result(timeout_seconds=1.0)

        print(f"Task result: {result}")
        print(f"Worker stats: {runtime.worker.stats()}")

    print(f"Runtime started after exit: {runtime.is_running}")
    print(
        "Collected events: "
        f"{[event.event_type.value for event in event_collector.events]}"
    )


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/55_runtime_context_manager.py
```

Expected output includes:

```text
Runtime started: True
Task result: 42
Runtime started after exit: False
Collected events: ['task.started', 'task.succeeded']
```

---

## Step 7: Add Tests for Plugin-Aware Workers and Runtime Lifecycle

### The Target

Add regression tests for:

- worker event publishing;
- plugin failure isolation;
- runtime context-manager startup and shutdown;
- rejection of submissions before runtime startup.

### The Concept

The runtime and worker now coordinate several components:

```text
Application
Broker
Worker
Plugin registry
Plugins
Receipts
```

Tests ensure that lifecycle ordering stays correct when later changes add more capabilities.

### The Implementation

Create this test module.

## `tests/test_worker_plugins_and_runtime.py`

```python
"""Tests for plugin-aware workers and composed PulseQueue runtimes."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue import PulseQueue, PulseQueueRuntime, PulseQueueWorker
from pulsequeue.broker import InMemoryBroker
from pulsequeue.builtin_plugins import InMemoryEventPlugin
from pulsequeue.events import TaskEvent
from pulsequeue.plugins import PluginRegistry
from pulsequeue.result import TaskState


class FailingEventPlugin:
    """A plugin that fails only while handling published events."""

    name = "failing_event_plugin"

    async def start(self) -> None:
        """Start normally."""
        return None

    async def stop(self) -> None:
        """Stop normally."""
        return None

    async def on_event(self, event: TaskEvent) -> None:
        """Raise for every event delivery."""
        raise RuntimeError("event publishing failed")


def test_worker_publishes_lifecycle_events() -> None:
    """Successful task execution should publish started and succeeded events."""

    async def run_test() -> None:
        app = PulseQueue("worker_events")
        broker = InMemoryBroker()
        plugins = PluginRegistry()
        collector = InMemoryEventPlugin()

        plugins.register(collector)

        @app.task(queue="examples")
        async def double(value: int) -> int:
            return value * 2

        async with PulseQueueWorker(
            app,
            broker,
            plugins=plugins,
        ) as worker:
            receipt = await app.submit(broker, "examples.double", 21)

            assert await receipt.result(timeout_seconds=1.0) == 42
            assert receipt.snapshot().state is TaskState.SUCCEEDED
            assert worker.stats().event_delivery_failures == 0

        assert [event.event_type.value for event in collector.events] == [
            "task.started",
            "task.succeeded",
        ]

    asyncio.run(run_test())


def test_plugin_event_failure_does_not_fail_task() -> None:
    """A plugin exception should increment diagnostics without changing result."""

    async def run_test() -> None:
        app = PulseQueue("plugin_isolation")
        broker = InMemoryBroker()
        plugins = PluginRegistry()

        plugins.register(FailingEventPlugin())

        @app.task(queue="examples")
        async def identity(value: int) -> int:
            return value

        async with PulseQueueWorker(
            app,
            broker,
            plugins=plugins,
        ) as worker:
            receipt = await app.submit(broker, "examples.identity", 42)

            assert await receipt.result(timeout_seconds=1.0) == 42
            assert receipt.snapshot().state is TaskState.SUCCEEDED
            assert worker.stats().event_delivery_failures == 2

    asyncio.run(run_test())


def test_runtime_starts_and_stops_worker() -> None:
    """The runtime context manager should own worker lifecycle correctly."""

    async def run_test() -> None:
        app = PulseQueue("runtime_lifecycle")

        @app.task(queue="examples")
        async def add(left: int, right: int) -> int:
            return left + right

        runtime = PulseQueueRuntime(app)

        assert runtime.is_running is False

        async with runtime:
            assert runtime.is_running is True

            receipt = await runtime.submit("examples.add", 20, 22)
            assert await receipt.result(timeout_seconds=1.0) == 42

        assert runtime.is_running is False
        assert runtime.worker.state.value == "stopped"

    asyncio.run(run_test())


def test_runtime_rejects_submission_before_start() -> None:
    """Submitting before startup must fail instead of leaving work unprocessed."""

    async def run_test() -> None:
        app = PulseQueue("runtime_not_started")

        @app.task(queue="examples")
        async def noop() -> None:
            return None

        runtime = PulseQueueRuntime(app)

        with pytest.raises(RuntimeError, match="not running"):
            await runtime.submit("examples.noop")

    asyncio.run(run_test())
```

### The Verification

Run the complete suite:

```bash
python -m pytest -q
```

Expected result resembles:

```text
.......................................................                  [100%]
55 passed
```

The count may differ depending on whether the optional C extension tests were built and discovered. Every test should pass.

---

# Phase 4 Reference: Context Managers and Lifecycle Composition

## Why Async Context Managers Matter

This:

```python
async with PulseQueueRuntime(app) as runtime:
    ...
```

is not only cleaner than manual startup and shutdown.

It also handles exceptions:

```python
async with PulseQueueRuntime(app) as runtime:
    raise RuntimeError("something failed")
```

Python still calls:

```python
await runtime.__aexit__(...)
```

That causes the runtime to stop workers and plugins before the exception continues outward.

This is critical for:

- tests;
- command-line tools;
- service startup;
- graceful deployment shutdown;
- avoiding leaked worker tasks.

---

## Lifecycle Order

PulseQueue runtime startup:

```text
PluginRegistry.start()
        ↓
PulseQueueWorker starts consumer tasks
        ↓
Runtime accepts submissions
```

PulseQueue runtime shutdown:

```text
Broker closes submissions
        ↓
Worker drains or cancels task consumers
        ↓
PluginRegistry.stop()
        ↓
Runtime reports stopped
```

The reverse shutdown order preserves final task events.

---

## Plugin Failure Policy

The current framework applies two different policies:

| Plugin phase | Failure behavior |
|---|---|
| `plugin.start()` | Worker startup fails; already-started plugins roll back |
| `plugin.on_event(...)` | Task continues; worker increments `event_delivery_failures` |
| `plugin.stop()` | Shutdown reports the plugin failure |

This is a deliberate reliability boundary:

- Startup failures mean the configured runtime is not ready.
- Event-delivery failures should not retroactively change task execution.
- Shutdown failures must remain visible to operators.
