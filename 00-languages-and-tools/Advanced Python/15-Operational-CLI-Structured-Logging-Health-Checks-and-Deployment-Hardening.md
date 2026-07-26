# Part 15: Operational CLI, Structured Logging, Health Checks, and Deployment Hardening

A framework is not complete when it can execute work. It must also be operable.

Operators need answers to questions such as:

- Is the runtime started?
- Is the worker accepting work?
- How many messages are queued?
- Are tasks succeeding or failing?
- Are plugins failing to receive events?
- Which application is loaded?
- Can deployment tooling verify configuration before starting a process?

This part adds:

- JSON structured logging;
- runtime health snapshots;
- an import-safe application factory contract;
- a command-line interface;
- signal-aware worker process startup;
- container-oriented deployment artifacts;
- final end-to-end verification.

> **Important:** `InMemoryBroker` remains process-local. The worker CLI is useful for lifecycle validation, local development, and demonstrating production process behavior, but another process cannot submit work into its in-memory queue. A durable transport backend is required for multi-process or multi-machine task submission.

---

## Step 1: Correct Forced Shutdown After Consumer Cancellation

### The Target

Fix a shutdown edge case in `PulseQueueWorker.stop(...)`.

### The Concept

In Part 14, forced shutdown cancels worker consumer tasks:

```python
consumer_task.cancel()
```

`_force_stop()` correctly gathers these cancelled tasks with:

```python
await asyncio.gather(..., return_exceptions=True)
```

However, `stop()` then attempted to gather the same tasks again *without* `return_exceptions=True`.

A cancelled `asyncio.Task` raises `CancelledError` when awaited. That could cause worker shutdown itself to appear cancelled after an otherwise successful forced-cleanup operation.

Think of this as checking a completed emergency evacuation list twice. The second check should recognize that everyone has already been handled, rather than treating “already evacuated” as a new emergency.

### The Implementation

Replace the complete worker module with this corrected version.

## `src/pulsequeue/worker.py`

```python
"""Asynchronous in-memory task workers for PulseQueue."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from enum import StrEnum
from types import TracebackType
from typing import Any

from pulsequeue.app import PulseQueue
from pulsequeue.async_queue import STOP_SIGNAL
from pulsequeue.broker import InMemoryBroker
from pulsequeue.cpu_task import CpuTask
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.execution import run_cpu_bound
from pulsequeue.executors import ProcessExecutorPool
from pulsequeue.plugins import PluginRegistry
from pulsequeue.result import TaskResultSnapshot
from pulsequeue.task import Task
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
    """Consume async and CPU task envelopes with lifecycle plugin support."""

    def __init__(
        self,
        app: PulseQueue,
        broker: InMemoryBroker,
        *,
        concurrency: int = 1,
        cpu_processes: int | None = None,
        plugins: PluginRegistry | None = None,
    ) -> None:
        """Configure a worker without starting resources yet."""
        if concurrency < 1:
            raise ValueError("concurrency must be at least 1.")

        self._app = app
        self._broker = broker
        self._concurrency = concurrency
        self._plugins = plugins
        self._cpu_pool = ProcessExecutorPool(max_workers=cpu_processes)
        self._state = WorkerState.CREATED
        self._consumer_tasks: list[asyncio.Task[None]] = []

        self._completed_tasks = 0
        self._failed_tasks = 0
        self._cancelled_tasks = 0
        self._retry_attempts = 0
        self._event_delivery_failures = 0

    @property
    def state(self) -> WorkerState:
        """Return the worker lifecycle state."""
        return self._state

    @property
    def is_running(self) -> bool:
        """Return whether the worker accepts broker messages."""
        return self._state is WorkerState.RUNNING

    @property
    def plugins(self) -> PluginRegistry | None:
        """Return the optional plugin registry."""
        return self._plugins

    def stats(self) -> WorkerStats:
        """Return a stable worker statistics snapshot."""
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
        """Start plugins, CPU process pool, and async consumer loops."""
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

            await self._cpu_pool.__aenter__()

            self._consumer_tasks = [
                asyncio.create_task(
                    self._consume_forever(worker_number),
                    name=f"pulsequeue-worker-{self._app.name}-{worker_number}",
                )
                for worker_number in range(1, self._concurrency + 1)
            ]
        except BaseException:
            if self._cpu_pool.is_running:
                await self._cpu_pool.__aexit__(None, None, None)

            if self._plugins is not None:
                await self._plugins.stop()

            raise

        self._state = WorkerState.RUNNING

    async def stop(self, *, timeout_seconds: float = 0.0) -> None:
        """Stop consumers, then release process and plugin resources."""
        if timeout_seconds < 0:
            raise ValueError("timeout_seconds must be zero or greater.")

        if self._state is WorkerState.STOPPED:
            return

        if self._state is WorkerState.CREATED:
            self._state = WorkerState.STOPPED
            await self._close_resources()
            return

        if self._state is not WorkerState.RUNNING:
            raise RuntimeError(f"Worker cannot stop from state {self._state!r}.")

        self._state = WorkerState.STOPPING
        shutdown_error: BaseException | None = None

        try:
            await self._broker.stop_workers(worker_count=self._concurrency)

            forced_shutdown = False

            if timeout_seconds == 0:
                await self._broker.join()
            else:
                try:
                    async with asyncio.timeout(timeout_seconds):
                        await self._broker.join()
                except TimeoutError:
                    forced_shutdown = True
                    await self._force_stop()

            # _force_stop already gathered cancelled consumers safely. A second
            # gather would re-raise CancelledError unless return_exceptions=True.
            if forced_shutdown:
                await asyncio.gather(
                    *self._consumer_tasks,
                    return_exceptions=True,
                )
            else:
                await asyncio.gather(*self._consumer_tasks)
        except BaseException as error:
            shutdown_error = error
        finally:
            self._consumer_tasks.clear()
            self._state = WorkerState.STOPPED

            try:
                await self._close_resources()
            except BaseException as resource_error:
                if shutdown_error is not None:
                    raise BaseExceptionGroup(
                        "Worker shutdown and resource cleanup both failed.",
                        [shutdown_error, resource_error],
                    ) from None

                raise resource_error

            if shutdown_error is not None:
                raise shutdown_error

    async def __aenter__(self) -> PulseQueueWorker:
        """Start worker resources through an async context manager."""
        await self.start()
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Stop worker resources on context exit."""
        await self.stop()

    async def _close_resources(self) -> None:
        """Close the process pool first, then stop event plugins."""
        resource_errors: list[BaseException] = []

        if self._cpu_pool.is_running:
            try:
                await self._cpu_pool.__aexit__(None, None, None)
            except BaseException as error:
                resource_errors.append(error)

        if self._plugins is not None:
            try:
                await self._plugins.stop()
            except BaseException as error:
                resource_errors.append(error)

        if len(resource_errors) == 1:
            raise resource_errors[0]

        if resource_errors:
            raise BaseExceptionGroup(
                "One or more worker resources failed to close.",
                resource_errors,
            )

    async def _force_stop(self) -> None:
        """Cancel active consumers and all queued task envelopes."""
        for consumer_task in self._consumer_tasks:
            consumer_task.cancel()

        await asyncio.gather(*self._consumer_tasks, return_exceptions=True)

        self._cancelled_tasks += self._broker.cancel_pending()
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
                        f"Worker {worker_number} received unexpected item "
                        f"{broker_item!r}."
                    )

                await self._execute_envelope(broker_item)
            finally:
                self._broker.task_done()

    async def _execute_envelope(self, envelope: TaskEnvelope) -> None:
        """Execute one async or CPU task, including retry behavior."""
        task = self._app.get_task(envelope.task_name)

        try:
            while True:
                self._broker.mark_running(envelope.task_id)
                running_snapshot = self._result_snapshot(envelope.task_id)

                await self._publish_event(TaskEventType.STARTED, running_snapshot)

                try:
                    result = await self._execute_task(task, envelope)
                except Exception as error:
                    snapshot = self._result_snapshot(envelope.task_id)

                    if snapshot.attempt >= snapshot.max_attempts:
                        self._broker.mark_failed(envelope.task_id)
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

                    delay_seconds = task.options.retry_delay_for_attempt(
                        snapshot.attempt
                    )

                    self._broker.mark_retrying(
                        envelope.task_id,
                        error,
                        delay_seconds=delay_seconds,
                    )
                    self._retry_attempts += 1

                    await self._publish_event(
                        TaskEventType.RETRYING,
                        self._result_snapshot(envelope.task_id),
                        details={
                            "delay_seconds": delay_seconds,
                            "exception_type": type(error).__name__,
                            "exception_message": str(error),
                        },
                    )

                    await asyncio.sleep(delay_seconds)
                else:
                    self._broker.mark_succeeded(envelope.task_id, result)
                    self._completed_tasks += 1

                    await self._publish_event(
                        TaskEventType.SUCCEEDED,
                        self._result_snapshot(envelope.task_id),
                        details={"result_type": type(result).__name__},
                    )
                    return
        except asyncio.CancelledError:
            self._broker.mark_cancelled(envelope.task_id)
            self._cancelled_tasks += 1

            await self._publish_event(
                TaskEventType.CANCELLED,
                self._result_snapshot(envelope.task_id),
            )
            raise

    async def _execute_task(
        self,
        task: Task[Any, Any] | CpuTask[Any, Any],
        envelope: TaskEnvelope,
    ) -> Any:
        """Run async work in the loop or CPU work through the process pool."""
        if isinstance(task, Task):
            return await await_with_timeout(
                task(*envelope.args, **dict(envelope.kwargs)),
                timeout_seconds=task.options.timeout_seconds,
                operation_name=envelope.task_name,
            )

        if isinstance(task, CpuTask):
            return await await_with_timeout(
                run_cpu_bound(
                    self._cpu_pool.executor,
                    task.function,
                    *envelope.args,
                    **dict(envelope.kwargs),
                ),
                timeout_seconds=task.options.timeout_seconds,
                operation_name=envelope.task_name,
            )

        raise RuntimeError(
            f"Task {envelope.task_name!r} has unsupported definition type "
            f"{type(task).__name__}."
        )

    async def _publish_event(
        self,
        event_type: TaskEventType,
        snapshot: TaskResultSnapshot[object],
        *,
        details: dict[str, object] | None = None,
    ) -> None:
        """Publish an event without plugin faults changing task state."""
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
            self._event_delivery_failures += 1

    def _result_snapshot(self, task_id: str) -> TaskResultSnapshot[object]:
        """Return a result snapshot through the broker boundary."""
        return self._broker.result_snapshot(task_id)
```

### The Verification

Run the existing forced-shutdown tests:

```bash
python -m pytest tests/test_retries_and_shutdown.py -q
```

Expected output:

```text
.....                                                                    [100%]
5 passed
```

---

## Step 2: Add Structured JSON Logging

### The Target

Create a logging configuration that emits either readable development logs or JSON logs for production log collectors.

### The Concept

Plain text logs are useful locally:

```text
INFO pulsequeue.worker Worker started
```

Production systems often need structured data:

```json
{
  "timestamp": "2026-07-24T12:00:00.000+00:00",
  "level": "INFO",
  "logger": "pulsequeue.worker",
  "message": "Worker started",
  "application": "notifications"
}
```

JSON logs are easier for systems such as Elasticsearch, Loki, Datadog, CloudWatch, and Splunk to search and aggregate.

### The Implementation

Create the logging module.

## `src/pulsequeue/logging.py`

```python
"""Structured logging configuration for PulseQueue processes."""

from __future__ import annotations

import json
import logging
import sys
from datetime import UTC, datetime
from typing import Any


class JsonLogFormatter(logging.Formatter):
    """Render standard logging records as one JSON object per line."""

    _standard_attributes = frozenset(
        {
            "args",
            "asctime",
            "created",
            "exc_info",
            "exc_text",
            "filename",
            "funcName",
            "levelname",
            "levelno",
            "lineno",
            "message",
            "module",
            "msecs",
            "msg",
            "name",
            "pathname",
            "process",
            "processName",
            "relativeCreated",
            "stack_info",
            "taskName",
            "thread",
            "threadName",
        }
    )

    def format(self, record: logging.LogRecord) -> str:
        """Convert one standard logging record into JSON-safe fields."""
        payload: dict[str, Any] = {
            "timestamp": datetime.now(UTC).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }

        if record.exc_info is not None:
            payload["exception"] = self.formatException(record.exc_info)

        if record.stack_info is not None:
            payload["stack"] = self.formatStack(record.stack_info)

        for key, value in record.__dict__.items():
            if key in self._standard_attributes or key.startswith("_"):
                continue

            try:
                json.dumps(value)
            except TypeError:
                payload[key] = repr(value)
            else:
                payload[key] = value

        return json.dumps(payload, ensure_ascii=False, sort_keys=True)


def configure_logging(
    *,
    level: str = "INFO",
    json_output: bool = True,
) -> None:
    """Configure the pulsequeue logger hierarchy with one stdout handler."""
    numeric_level = logging.getLevelNamesMapping().get(level.upper())

    if not isinstance(numeric_level, int):
        allowed = ", ".join(sorted(logging.getLevelNamesMapping()))
        raise ValueError(
            f"Unknown logging level {level!r}. Allowed levels: {allowed}."
        )

    handler = logging.StreamHandler(stream=sys.stdout)

    if json_output:
        handler.setFormatter(JsonLogFormatter())
    else:
        handler.setFormatter(
            logging.Formatter(
                "%(asctime)s %(levelname)s %(name)s %(message)s"
            )
        )

    logger = logging.getLogger("pulsequeue")
    logger.handlers.clear()
    logger.addHandler(handler)
    logger.setLevel(numeric_level)
    logger.propagate = False
```

Create a demonstration.

## `examples/61_structured_logging.py`

```python
"""Demonstrate development and JSON structured logging formats."""

from __future__ import annotations

import logging

from pulsequeue.logging import configure_logging


configure_logging(level="INFO", json_output=True)

logger = logging.getLogger("pulsequeue.examples")

logger.info(
    "Task submitted",
    extra={
        "task_id": "task-001",
        "task_name": "emails.send_welcome_email",
        "attempt": 1,
    },
)

try:
    raise ConnectionError("Example upstream connection failure.")
except ConnectionError:
    logger.exception(
        "Task execution failed",
        extra={
            "task_id": "task-001",
            "task_name": "emails.send_welcome_email",
        },
    )
```

### The Verification

Run:

```bash
python examples/61_structured_logging.py
```

Expected output contains two JSON lines. The first resembles:

```json
{"attempt": 1, "level": "INFO", "logger": "pulsequeue.examples", "message": "Task submitted", "task_id": "task-001", "task_name": "emails.send_welcome_email", "timestamp": "..."}
```

The second line includes an `"exception"` field.

---

## Step 3: Create Runtime Health Snapshots

### The Target

Expose a serializable health status object from `PulseQueueRuntime`.

### The Concept

A health check should be quick and should not mutate system state.

It answers whether the runtime is operational *right now*:

```text
Is the runtime started?
Is the worker running?
Is the broker closed?
How many items are queued?
How many workers are configured?
```

This is not the same as a deep business-health check. A healthy runtime can still have a failing upstream email provider.

Think of it as checking whether a restaurant is open, staffed, and has power. It does not guarantee every ingredient is in stock.

### The Implementation

Create the health module.

## `src/pulsequeue/health.py`

```python
"""Serializable runtime health snapshots."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any

from pulsequeue.runtime import PulseQueueRuntime


@dataclass(frozen=True, slots=True)
class RuntimeHealth:
    """A point-in-time health view of one PulseQueue runtime."""

    application_name: str
    runtime_running: bool
    worker_state: str
    worker_concurrency: int
    broker_closed: bool
    broker_queued_items: int
    broker_unfinished_tasks: int
    completed_tasks: int
    failed_tasks: int
    cancelled_tasks: int
    retry_attempts: int
    event_delivery_failures: int

    @property
    def is_healthy(self) -> bool:
        """Return whether core runtime components are actively operational."""
        return self.runtime_running and self.worker_state == "running"

    def as_dict(self) -> dict[str, Any]:
        """Return JSON-compatible health data."""
        data = asdict(self)
        data["is_healthy"] = self.is_healthy
        return data


def runtime_health(runtime: PulseQueueRuntime) -> RuntimeHealth:
    """Create a health snapshot without changing runtime state."""
    worker_stats = runtime.worker.stats()
    broker_stats = runtime.broker.stats()

    return RuntimeHealth(
        application_name=runtime.app.name,
        runtime_running=runtime.is_running,
        worker_state=worker_stats.state.value,
        worker_concurrency=worker_stats.concurrency,
        broker_closed=runtime.broker.is_closed,
        broker_queued_items=broker_stats.queued_items,
        broker_unfinished_tasks=broker_stats.unfinished_tasks,
        completed_tasks=worker_stats.completed_tasks,
        failed_tasks=worker_stats.failed_tasks,
        cancelled_tasks=worker_stats.cancelled_tasks,
        retry_attempts=worker_stats.retry_attempts,
        event_delivery_failures=worker_stats.event_delivery_failures,
    )
```

Create an example.

## `examples/62_runtime_health.py`

```python
"""Inspect PulseQueue runtime health before, during, and after execution."""

from __future__ import annotations

import asyncio
import json

from pulsequeue import PulseQueue, PulseQueueRuntime
from pulsequeue.health import runtime_health


app = PulseQueue("health_demo")


@app.task(queue="examples")
async def identity(value: int) -> int:
    """Return the provided value."""
    await asyncio.sleep(0)
    return value


async def main() -> None:
    """Print health snapshots across the runtime lifecycle."""
    runtime = PulseQueueRuntime(app)

    print("Before startup:")
    print(json.dumps(runtime_health(runtime).as_dict(), indent=2))

    async with runtime:
        print("\nDuring execution:")
        print(json.dumps(runtime_health(runtime).as_dict(), indent=2))

        receipt = await runtime.submit("examples.identity", 42)
        print(f"\nTask result: {await receipt.result(timeout_seconds=1.0)}")

        print("\nAfter task completion:")
        print(json.dumps(runtime_health(runtime).as_dict(), indent=2))

    print("\nAfter shutdown:")
    print(json.dumps(runtime_health(runtime).as_dict(), indent=2))


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/62_runtime_health.py
```

Expected observations:

- Before startup, `"is_healthy": false`.
- During execution, `"is_healthy": true`.
- After task completion, `"completed_tasks": 1`.
- After shutdown, `"is_healthy": false`.

---

## Step 4: Define an Application Factory Contract

### The Target

Create a safe utility that imports a configured PulseQueue application from:

```text
module.path:attribute_name
```

### The Concept

A command-line worker process needs to know which application contains task registrations.

For example:

```bash
PULSEQUEUE_APP=examples.worker_application:app
```

The worker imports that module, causing decorators to register tasks, then obtains the `app` object.

This pattern is used by many Python frameworks:

```text
package.module:object
```

It is explicit, inspectable, and deployment-friendly.

### The Implementation

Create the application loader.

## `src/pulsequeue/loader.py`

```python
"""Import PulseQueue applications from deployment-friendly import paths."""

from __future__ import annotations

import importlib

from pulsequeue.app import PulseQueue


class ApplicationLoadError(RuntimeError):
    """Raised when a configured PulseQueue application cannot be loaded."""


def load_application(import_path: str) -> PulseQueue:
    """Load one PulseQueue instance from 'package.module:attribute' syntax."""
    if ":" not in import_path:
        raise ApplicationLoadError(
            "Application import path must use 'package.module:attribute' syntax."
        )

    module_name, attribute_name = import_path.split(":", maxsplit=1)

    if not module_name or not attribute_name:
        raise ApplicationLoadError(
            "Application import path must include both module and attribute."
        )

    try:
        module = importlib.import_module(module_name)
    except Exception as error:
        raise ApplicationLoadError(
            f"Could not import application module {module_name!r}."
        ) from error

    try:
        application = getattr(module, attribute_name)
    except AttributeError as error:
        raise ApplicationLoadError(
            f"Module {module_name!r} has no attribute {attribute_name!r}."
        ) from error

    if not isinstance(application, PulseQueue):
        raise ApplicationLoadError(
            f"{import_path!r} resolved to {type(application).__name__}, "
            "not a PulseQueue application."
        )

    return application
```

Create a CLI-loadable application.

## `examples/worker_application.py`

```python
"""A module-level application intended for PulseQueue CLI demonstrations."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue


app = PulseQueue("cli_demo")


@app.task(queue="examples")
async def greet(name: str) -> str:
    """Return a simple asynchronous greeting."""
    await asyncio.sleep(0)
    return f"Hello, {name}."


@app.cpu_task(queue="analytics")
def square(value: int) -> int:
    """Return a small CPU task result."""
    return value * value
```

### The Verification

Run:

```bash
python - <<'PY'
from pulsequeue.loader import load_application

app = load_application("examples.worker_application:app")

print(app)
print(sorted(app.registered_tasks()))
PY
```

Expected output includes:

```text
PulseQueue(name='cli_demo', task_count=2)
['analytics.square', 'examples.greet']
```

---

## Step 5: Build the PulseQueue CLI

### The Target

Create a command-line interface with:

- `inspect` — list registered tasks;
- `check-config` — validate environment settings;
- `run` — start a signal-aware worker process;
- `submit-local` — submit and execute one task inside a local runtime.

### The Concept

The CLI separates operational jobs:

| Command | Purpose |
|---|---|
| `inspect` | Validate task registration and deployment import path |
| `check-config` | Fail early if environment settings are malformed |
| `run` | Start a long-running worker lifecycle |
| `submit-local` | Demonstrate one fully local task execution |

`submit-local` is intentionally local. It starts its own runtime and does not communicate with a separate `run` process because the current broker is in-memory.

### The Implementation

Create the CLI module.

## `src/pulsequeue/cli.py`

```python
"""Command-line operations for PulseQueue applications."""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import signal
from collections.abc import Sequence
from typing import Any

from pulsequeue.config import PulseQueueSettings
from pulsequeue.health import runtime_health
from pulsequeue.loader import ApplicationLoadError, load_application
from pulsequeue.logging import configure_logging
from pulsequeue.runtime import PulseQueueRuntime
from pulsequeue.serialization import TaskSerializationError, ensure_json_value


def build_parser() -> argparse.ArgumentParser:
    """Create the complete PulseQueue command-line parser."""
    parser = argparse.ArgumentParser(
        prog="pulsequeue",
        description="Operational commands for PulseQueue applications.",
    )

    parser.add_argument(
        "--app",
        default=os.environ.get("PULSEQUEUE_APP"),
        help=(
            "Application import path in 'package.module:attribute' format. "
            "Defaults to PULSEQUEUE_APP."
        ),
    )
    parser.add_argument(
        "--log-level",
        default=os.environ.get("PULSEQUEUE_LOG_LEVEL", "INFO"),
        help="Logging level, defaulting to PULSEQUEUE_LOG_LEVEL or INFO.",
    )
    parser.add_argument(
        "--plain-logs",
        action="store_true",
        help="Use human-readable logs instead of JSON logs.",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser(
        "inspect",
        help="Print application and registered task metadata as JSON.",
    )

    subparsers.add_parser(
        "check-config",
        help="Validate PULSEQUEUE_* environment configuration and print JSON.",
    )

    run_parser = subparsers.add_parser(
        "run",
        help="Start a signal-aware local worker until SIGINT or SIGTERM.",
    )
    run_parser.add_argument(
        "--shutdown-timeout",
        type=float,
        default=None,
        help="Override configured graceful shutdown timeout in seconds.",
    )

    submit_parser = subparsers.add_parser(
        "submit-local",
        help="Start a local runtime, submit one JSON-compatible task call, and wait.",
    )
    submit_parser.add_argument(
        "task_name",
        help="Queue-qualified task name, for example examples.greet.",
    )
    submit_parser.add_argument(
        "--args",
        default="[]",
        help="JSON array of positional task arguments.",
    )
    submit_parser.add_argument(
        "--kwargs",
        default="{}",
        help="JSON object of keyword task arguments.",
    )
    submit_parser.add_argument(
        "--result-timeout",
        type=float,
        default=30.0,
        help="Maximum seconds to wait for the task result.",
    )

    return parser


def _require_app_import_path(parsed: argparse.Namespace) -> str:
    """Return the application path or raise a user-facing configuration error."""
    if not parsed.app:
        raise ApplicationLoadError(
            "No application configured. Pass --app package.module:attribute "
            "or set PULSEQUEUE_APP."
        )

    return parsed.app


def _parse_json_arguments(raw_args: str, raw_kwargs: str) -> tuple[list[Any], dict[str, Any]]:
    """Parse CLI JSON arguments and enforce task serializer constraints."""
    try:
        parsed_args = json.loads(raw_args)
    except json.JSONDecodeError as error:
        raise TaskSerializationError("--args must be valid JSON.") from error

    try:
        parsed_kwargs = json.loads(raw_kwargs)
    except json.JSONDecodeError as error:
        raise TaskSerializationError("--kwargs must be valid JSON.") from error

    if not isinstance(parsed_args, list):
        raise TaskSerializationError("--args must be a JSON array.")

    if not isinstance(parsed_kwargs, dict):
        raise TaskSerializationError("--kwargs must be a JSON object.")

    normalized_args = ensure_json_value(parsed_args, path="$.args")
    normalized_kwargs = ensure_json_value(parsed_kwargs, path="$.kwargs")

    if not isinstance(normalized_args, list):
        raise RuntimeError("Validated CLI args unexpectedly did not remain a list.")

    if not isinstance(normalized_kwargs, dict):
        raise RuntimeError(
            "Validated CLI kwargs unexpectedly did not remain a dictionary."
        )

    return normalized_args, normalized_kwargs


def _install_shutdown_signal_handlers(
    shutdown_event: asyncio.Event,
    logger: logging.Logger,
) -> None:
    """Register SIGINT and SIGTERM handlers that request graceful shutdown."""
    event_loop = asyncio.get_running_loop()

    def request_shutdown(signal_name: str) -> None:
        """Schedule shutdown event mutation safely on the active event loop."""
        if shutdown_event.is_set():
            return

        logger.info(
            "Shutdown signal received",
            extra={"signal": signal_name},
        )
        shutdown_event.set()

    for signal_value in (signal.SIGINT, signal.SIGTERM):
        try:
            event_loop.add_signal_handler(
                signal_value,
                request_shutdown,
                signal_value.name,
            )
        except (NotImplementedError, RuntimeError):
            # Windows and non-main-thread loops may not support add_signal_handler.
            # signal.signal is still enough for the CLI process case.
            signal.signal(
                signal_value,
                lambda _number, _frame, name=signal_value.name: (
                    event_loop.call_soon_threadsafe(request_shutdown, name)
                ),
            )


async def _run_worker_command(
    *,
    app_import_path: str,
    shutdown_timeout_override: float | None,
) -> int:
    """Run one local worker process until an operating-system stop signal."""
    logger = logging.getLogger("pulsequeue.cli")
    app = load_application(app_import_path)
    settings = PulseQueueSettings.from_environment()

    runtime = PulseQueueRuntime.from_settings(app, settings)
    shutdown_event = asyncio.Event()

    _install_shutdown_signal_handlers(shutdown_event, logger)

    await runtime.start()

    logger.info(
        "PulseQueue worker started",
        extra={
            "application": app.name,
            "worker_concurrency": settings.worker_concurrency,
            "cpu_processes": settings.cpu_processes,
        },
    )

    try:
        await shutdown_event.wait()
    finally:
        await runtime.stop(timeout_seconds=shutdown_timeout_override)

        logger.info(
            "PulseQueue worker stopped",
            extra=runtime_health(runtime).as_dict(),
        )

    return 0


async def _run_submit_local_command(
    *,
    app_import_path: str,
    task_name: str,
    raw_args: str,
    raw_kwargs: str,
    result_timeout: float,
) -> int:
    """Run one task inside a temporary local runtime and print JSON result."""
    if result_timeout < 0:
        raise ValueError("--result-timeout must be zero or greater.")

    app = load_application(app_import_path)
    settings = PulseQueueSettings.from_environment()
    args, kwargs = _parse_json_arguments(raw_args, raw_kwargs)

    async with PulseQueueRuntime.from_settings(app, settings) as runtime:
        receipt = await runtime.submit(task_name, *args, **kwargs)
        result = await receipt.result(timeout_seconds=result_timeout)

        print(
            json.dumps(
                {
                    "task_id": receipt.task_id,
                    "task_name": receipt.task_name,
                    "state": receipt.snapshot().state.value,
                    "result": result,
                    "health": runtime_health(runtime).as_dict(),
                },
                ensure_ascii=False,
                default=str,
                sort_keys=True,
            )
        )

    return 0


def main(arguments: Sequence[str] | None = None) -> int:
    """Parse command-line input, run requested operation, and return exit code."""
    parser = build_parser()
    parsed = parser.parse_args(arguments)

    try:
        configure_logging(
            level=parsed.log_level,
            json_output=not parsed.plain_logs,
        )

        if parsed.command == "check-config":
            settings = PulseQueueSettings.from_environment()
            print(
                json.dumps(
                    {
                        "status": "valid",
                        "settings": {
                            "worker_concurrency": settings.worker_concurrency,
                            "broker_max_queue_size": settings.broker_max_queue_size,
                            "cpu_processes": settings.cpu_processes,
                            "shutdown_timeout_seconds": (
                                settings.shutdown_timeout_seconds
                            ),
                        },
                    },
                    sort_keys=True,
                )
            )
            return 0

        app_import_path = _require_app_import_path(parsed)

        if parsed.command == "inspect":
            app = load_application(app_import_path)
            print(json.dumps(app.describe(), indent=2, default=str, sort_keys=True))
            return 0

        if parsed.command == "run":
            return asyncio.run(
                _run_worker_command(
                    app_import_path=app_import_path,
                    shutdown_timeout_override=parsed.shutdown_timeout,
                )
            )

        if parsed.command == "submit-local":
            return asyncio.run(
                _run_submit_local_command(
                    app_import_path=app_import_path,
                    task_name=parsed.task_name,
                    raw_args=parsed.args,
                    raw_kwargs=parsed.kwargs,
                    result_timeout=parsed.result_timeout,
                )
            )

        raise RuntimeError(f"Unsupported command {parsed.command!r}.")
    except (
        ApplicationLoadError,
        TaskSerializationError,
        ValueError,
        RuntimeError,
        TimeoutError,
    ) as error:
        logging.getLogger("pulsequeue.cli").error(
            "PulseQueue command failed",
            extra={
                "error_type": type(error).__name__,
                "error_message": str(error),
            },
        )
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
```

Add an executable script entry point to `pyproject.toml`.

## `pyproject.toml`

```toml
[build-system]
requires = ["setuptools>=69"]
build-backend = "setuptools.build_meta"

[project]
name = "pulsequeue"
version = "0.1.0"
description = "An educational high-concurrency Python task framework."
requires-python = ">=3.12"
authors = [
    { name = "PulseQueue Tutorial" }
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.12",
]

[project.scripts]
pulsequeue = "pulsequeue.cli:main"

[tool.setuptools]
package-dir = { "" = "src" }

[tool.setuptools.packages.find]
where = ["src"]
```

Reinstall editable mode so the `pulsequeue` command is generated:

```bash
python -m pip install --editable .
```

### The Verification

Validate settings:

```bash
pulsequeue check-config
```

Expected output resembles:

```json
{"settings": {"broker_max_queue_size": 1000, "cpu_processes": null, "shutdown_timeout_seconds": 30.0, "worker_concurrency": 1}, "status": "valid"}
```

Inspect the CLI example application:

```bash
pulsequeue --app examples.worker_application:app inspect
```

Expected output includes both registered tasks:

```json
{
  "name": "cli_demo",
  "task_count": 2,
  "tasks": {
    "analytics.square": {
      "execution_kind": "cpu_bound"
    },
    "examples.greet": {
      "signature": "(name: str) -> str"
    }
  }
}
```

Run one local async task:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  examples.greet \
  --args '["Ada"]'
```

Expected output includes:

```json
{"result": "Hello, Ada.", "state": "succeeded", "task_name": "examples.greet", ...}
```

Run one local CPU task:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  analytics.square \
  --args '[12]'
```

Expected output includes:

```json
{"result": 144, "state": "succeeded", "task_name": "analytics.square", ...}
```

---

## Step 6: Add Container Deployment Files

### The Target

Create a minimal container image and Compose configuration for running the CLI worker process.

### The Concept

Containers package an application and its runtime dependencies into an immutable deployment unit.

For a Python worker, a safe baseline includes:

- a pinned Python image family;
- no root process user;
- unbuffered Python output for immediate logs;
- a health check;
- a graceful stop period longer than the application shutdown deadline.

Because the current broker is in-memory, this Compose setup demonstrates process lifecycle and configuration only. It does **not** create a distributed queue.

### The Implementation

Create the Dockerfile.

## `Dockerfile`

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install only build tools needed for the optional C extension, then remove
# package-index data in the same layer to reduce final image size.
RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml setup.py ./
COPY src ./src
COPY examples ./examples

RUN python -m pip install --upgrade pip \
    && python -m pip install .

# A non-root process reduces impact if application code is compromised.
RUN useradd --create-home --uid 10001 pulsequeue
USER pulsequeue

ENV PULSEQUEUE_APP=examples.worker_application:app
ENV PULSEQUEUE_LOG_LEVEL=INFO
ENV PULSEQUEUE_WORKER_CONCURRENCY=2
ENV PULSEQUEUE_CPU_PROCESSES=2
ENV PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS=20

CMD ["pulsequeue", "run"]
```

Create Compose configuration.

## `compose.yaml`

```yaml
services:
  pulsequeue-worker:
    build:
      context: .
    environment:
      PULSEQUEUE_APP: examples.worker_application:app
      PULSEQUEUE_LOG_LEVEL: INFO
      PULSEQUEUE_WORKER_CONCURRENCY: "2"
      PULSEQUEUE_CPU_PROCESSES: "2"
      PULSEQUEUE_BROKER_MAX_QUEUE_SIZE: "1000"
      PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS: "20"
    stop_grace_period: 30s
    healthcheck:
      test:
        [
          "CMD",
          "pulsequeue",
          "--app",
          "examples.worker_application:app",
          "inspect"
        ]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

### The Verification

Build the image:

```bash
docker compose build
```

Validate container configuration:

```bash
docker compose run --rm pulsequeue-worker pulsequeue check-config
```

Expected output includes:

```json
{"status": "valid", ...}
```

Start the worker:

```bash
docker compose up
```

Expected JSON log line resembles:

```json
{"application":"cli_demo","level":"INFO","logger":"pulsequeue.cli","message":"PulseQueue worker started",...}
```

Stop it with `Ctrl+C`. Docker Compose sends a stop signal, and the worker should log its graceful shutdown.

---

## Step 7: Add Operational Tests

### The Target

Test health snapshots, application loading, CLI task submission, and forced worker shutdown.

### The Concept

Operational code needs tests just as much as task code. A broken CLI can prevent incident response; a broken health snapshot can cause deployment systems to make incorrect restart decisions.

### The Implementation

Create this test module.

## `tests/test_operations.py`

```python
"""Tests for operational health, application loading, and CLI behavior."""

from __future__ import annotations

import asyncio
import json
import sys
import types

from pulsequeue import PulseQueue, PulseQueueRuntime
from pulsequeue.cli import main
from pulsequeue.health import runtime_health
from pulsequeue.loader import load_application


def test_runtime_health_changes_with_lifecycle() -> None:
    """Health should report active runtime state only while the worker runs."""

    async def run_test() -> None:
        app = PulseQueue("health_test")

        @app.task(queue="examples")
        async def noop() -> None:
            return None

        runtime = PulseQueueRuntime(app)

        assert runtime_health(runtime).is_healthy is False

        async with runtime:
            active_health = runtime_health(runtime)

            assert active_health.is_healthy is True
            assert active_health.application_name == "health_test"

            receipt = await runtime.submit("examples.noop")
            await receipt.result(timeout_seconds=1.0)

            completed_health = runtime_health(runtime)
            assert completed_health.completed_tasks == 1

        assert runtime_health(runtime).is_healthy is False

    asyncio.run(run_test())


def test_load_application_loads_module_attribute() -> None:
    """The app loader should retrieve a PulseQueue object from an import path."""
    module_name = "test_dynamic_pulsequeue_app"
    module = types.ModuleType(module_name)
    module.app = PulseQueue("loaded_app")
    sys.modules[module_name] = module

    try:
        loaded = load_application(f"{module_name}:app")

        assert loaded is module.app
    finally:
        del sys.modules[module_name]


def test_cli_check_config_returns_json(capsys) -> None:
    """The configuration command should print machine-readable validation data."""
    exit_code = main(["check-config"])

    captured = capsys.readouterr()

    assert exit_code == 0
    assert json.loads(captured.out)["status"] == "valid"


def test_cli_submit_local_executes_registered_task(capsys) -> None:
    """The CLI should run one local task from an importable app module."""
    module_name = "test_cli_pulsequeue_app"
    module = types.ModuleType(module_name)
    module.app = PulseQueue("cli_test_app")

    @module.app.task(queue="examples")
    async def add(left: int, right: int) -> int:
        return left + right

    sys.modules[module_name] = module

    try:
        exit_code = main(
            [
                "--app",
                f"{module_name}:app",
                "submit-local",
                "examples.add",
                "--args",
                "[20, 22]",
            ]
        )

        captured = capsys.readouterr()
        response = json.loads(captured.out)

        assert exit_code == 0
        assert response["result"] == 42
        assert response["state"] == "succeeded"
    finally:
        del sys.modules[module_name]
```

### The Verification

Run:

```bash
python -m pytest tests/test_operations.py -q
```

Expected output:

```text
....                                                                     [100%]
4 passed
```

Then run the full suite:

```bash
python -m pytest -q
```

Expected result: all tests pass.

---

# Final Production Checklist

Before treating a task system as production-ready, verify each category.

## Security

- [ ] Do not use `pickle` for untrusted task messages.
- [ ] Validate task names and arguments before enqueueing.
- [ ] Use TLS for real broker and result-backend network connections.
- [ ] Authenticate producers and workers.
- [ ] Run worker processes as non-root users.
- [ ] Avoid logging secrets, access tokens, raw request bodies, or sensitive task arguments.
- [ ] Enforce message-size limits in a durable broker implementation.

## Reliability

- [ ] Use durable broker messages for cross-process work.
- [ ] Define acknowledgement and visibility-timeout semantics.
- [ ] Configure retries only for transient failures.
- [ ] Use exponential backoff with jitter in distributed deployments.
- [ ] Add dead-letter queue behavior for permanently failing messages.
- [ ] Set graceful shutdown timeout lower than the orchestrator’s termination grace period.
- [ ] Monitor cancellation, failure, retry, and event-delivery counters.

## Performance

- [ ] Use `async def` tasks for I/O-bound work.
- [ ] Use process execution only for measured CPU-bound work.
- [ ] Do not block the event loop with synchronous network or disk calls.
- [ ] Bound broker queues to apply backpressure.
- [ ] Profile memory before applying `__slots__` or native extensions.
- [ ] Reuse process pools rather than creating one process per task.

## Observability

- [ ] Emit structured logs.
- [ ] Publish task lifecycle events.
- [ ] Expose health snapshots.
- [ ] Track task duration in a future metrics plugin.
- [ ] Track queue depth and worker saturation.
- [ ] Alert on sustained retry rates and failed task counts.
