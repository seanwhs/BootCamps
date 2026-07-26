# Part 11: Protocols, Structural Subtyping, Generics, and Plugin Contracts

A framework becomes difficult to maintain when every extension must inherit from one mandatory base class.

For example, imagine requiring every telemetry component, result backend, scheduler, or notification hook to inherit from this class:

```python
class RequiredPluginBase:
    ...
```

That approach tightly couples application code to framework internals.

Python provides a more flexible alternative: **protocols**.

A protocol defines the behavior an object must provide, rather than the class it must inherit from.

This is called **structural subtyping**.

> If an object has the required shape, it is compatible.

Think of a protocol as a power-outlet standard:

- A device does not need to be made by the same company as the building.
- It only needs the correct plug shape and electrical behavior.

For PulseQueue, this allows users to write plugins without importing or inheriting from internal framework base classes.

In this part, we will build:

- protocol-based event sinks;
- generic result transformers;
- lifecycle-managed plugins;
- a plugin registry with startup rollback and reverse-order shutdown;
- tests for structural compatibility and plugin lifecycle safety.

---

## Step 1: Create Protocol Contracts

### The Target

Create formal protocol interfaces for task event consumers, result transformers, and lifecycle plugins.

### The Concept

A protocol describes required attributes and methods.

For example:

```python
class EventSink(Protocol):
    def emit(self, event: TaskEvent) -> None:
        ...
```

Any object with a compatible `emit(...)` method can be used as an `EventSink`.

It does not need this inheritance:

```python
class MySink(EventSink):
    ...
```

In fact, inheriting from the protocol is optional.

We will use three contracts:

| Protocol | Responsibility |
|---|---|
| `EventSink` | Receives task lifecycle events |
| `ResultTransformer` | Converts one value type into another |
| `LifecyclePlugin` | Starts, stops, and receives task events |

### The Implementation

Create the typing module.

## `src/pulsequeue/typing.py`

```python
"""Protocol and generic contracts for PulseQueue extension points."""

from __future__ import annotations

from collections.abc import Awaitable
from typing import Generic, Protocol, TypeVar, runtime_checkable

from pulsequeue.events import TaskEvent

InputT = TypeVar("InputT")
OutputT = TypeVar("OutputT")


@runtime_checkable
class EventSink(Protocol):
    """Receive published immutable task lifecycle events.

    A compatible object only needs an emit(event) method. It does not need to
    inherit from EventSink.
    """

    def emit(self, event: TaskEvent) -> None:
        """Handle one published task event."""
        ...


class ResultTransformer(Protocol[InputT, OutputT]):
    """Transform a value from one type into another type."""

    def transform(self, value: InputT) -> OutputT:
        """Convert one input value into a result value."""
        ...


@runtime_checkable
class LifecyclePlugin(Protocol):
    """Define the minimum behavior required from a PulseQueue plugin.

    The name must be stable and unique within one PluginRegistry. start() and
    stop() allow plugins to acquire and release resources. on_event() receives
    task lifecycle notifications after a plugin has started.
    """

    name: str

    async def start(self) -> None:
        """Initialize resources needed by this plugin."""
        ...

    async def stop(self) -> None:
        """Release resources owned by this plugin."""
        ...

    async def on_event(self, event: TaskEvent) -> None:
        """Observe one task lifecycle event."""
        ...


PluginFactory = type[LifecyclePlugin]
PluginStartResult = Awaitable[None]
```

### The Verification

Create a small protocol demonstration.

## `examples/48_protocol_basics.py`

```python
"""Demonstrate structural subtyping with a PulseQueue protocol."""

from __future__ import annotations

from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.typing import EventSink


class PrintEventSink:
    """A class that satisfies EventSink without inheriting from it."""

    def emit(self, event: TaskEvent) -> None:
        """Print a readable event description."""
        print(
            f"Received event={event.event_type.value}, "
            f"task={event.task_name}, "
            f"attempt={event.attempt}"
        )


sink = PrintEventSink()

event = TaskEvent.create(
    event_type=TaskEventType.SUBMITTED,
    task_id="task-001",
    task_name="emails.send_welcome_email",
    attempt=0,
)

# EventSink is runtime-checkable, so this checks whether the required method
# exists. It does not deeply validate parameter annotations or method logic.
print(f"Structurally compatible with EventSink: {isinstance(sink, EventSink)}")

sink.emit(event)
```

### The Verification

Run:

```bash
python examples/48_protocol_basics.py
```

Expected output:

```text
Structurally compatible with EventSink: True
Received event=task.submitted, task=emails.send_welcome_email, attempt=0
```

The important result is that `PrintEventSink` never inherited from `EventSink`, but is still compatible.

---

## Step 2: Build Generic Result Transformers

### The Target

Create reusable, generic transformer implementations that keep type information across input and output values.

### The Concept

A generic type is a reusable type with one or more variable parts.

For example:

```python
ResultTransformer[int, str]
```

means:

```text
Input: integer
Output: string
```

This is more precise than writing:

```python
def transform(value: object) -> object:
    ...
```

Generic typing helps static type checkers catch mistakes before code runs.

Think of a transformer as a packaging machine:

```text
Raw value → transformation step → new representation
```

The machine may transform:

```text
TaskResultSnapshot → JSON-safe dictionary
TaskEvent → log line
int → str
```

### The Implementation

Create the transformer module.

## `src/pulsequeue/transformers.py`

```python
"""Generic value transformers for PulseQueue extension examples."""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Generic, TypeVar

from pulsequeue.events import TaskEvent
from pulsequeue.result import TaskResultSnapshot
from pulsequeue.typing import ResultTransformer

InputT = TypeVar("InputT")
OutputT = TypeVar("OutputT")


class IdentityTransformer(Generic[InputT]):
    """Return a value unchanged while preserving its static type."""

    def transform(self, value: InputT) -> InputT:
        """Return the exact input value."""
        return value


class TaskEventDictionaryTransformer:
    """Convert a TaskEvent into ordinary JSON-compatible values."""

    def transform(self, value: TaskEvent) -> dict[str, Any]:
        """Create a dictionary representation suitable for logging or JSON."""
        return {
            "event_type": value.event_type.value,
            "task_id": value.task_id,
            "task_name": value.task_name,
            "occurred_at": value.occurred_at.isoformat(),
            "attempt": value.attempt,
            "details": value.details_as_dict(),
        }


class TaskResultDictionaryTransformer:
    """Convert a task result snapshot into ordinary serializable values."""

    def transform(
        self,
        value: TaskResultSnapshot[Any],
    ) -> dict[str, Any]:
        """Create a dictionary with safely normalized date and enum fields."""
        failure = (
            asdict(value.failure)
            if value.failure is not None
            else None
        )

        return {
            "task_id": value.task_id,
            "task_name": value.task_name,
            "state": value.state.value,
            "submitted_at": value.submitted_at.isoformat(),
            "started_at": (
                value.started_at.isoformat()
                if value.started_at is not None
                else None
            ),
            "completed_at": (
                value.completed_at.isoformat()
                if value.completed_at is not None
                else None
            ),
            "attempt": value.attempt,
            "max_attempts": value.max_attempts,
            "next_retry_at": (
                value.next_retry_at.isoformat()
                if value.next_retry_at is not None
                else None
            ),
            "value": value.value,
            "failure": failure,
        }


def apply_transformer(
    transformer: ResultTransformer[InputT, OutputT],
    value: InputT,
) -> OutputT:
    """Apply a structurally compatible generic transformer."""
    return transformer.transform(value)
```

Create an example.

## `examples/49_generic_transformers.py`

```python
"""Demonstrate generic and protocol-compatible value transformers."""

from __future__ import annotations

from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.transformers import (
    IdentityTransformer,
    TaskEventDictionaryTransformer,
    apply_transformer,
)


event = TaskEvent.create(
    event_type=TaskEventType.SUCCEEDED,
    task_id="task-042",
    task_name="math.add",
    attempt=1,
    details={
        "result": 42,
        "queue": "math",
    },
)

identity = IdentityTransformer[int]()
event_transformer = TaskEventDictionaryTransformer()

unchanged_value = apply_transformer(identity, 42)
event_dictionary = apply_transformer(event_transformer, event)

print(f"Identity transformer result: {unchanged_value}")
print(f"Event dictionary: {event_dictionary}")
```

### The Verification

Run:

```bash
python examples/49_generic_transformers.py
```

Expected output includes:

```text
Identity transformer result: 42
Event dictionary: {'event_type': 'task.succeeded', 'task_id': 'task-042', ...}
```

---

## Step 3: Build a Lifecycle-Safe Plugin Registry

### The Target

Create a plugin registry that:

- validates plugin compatibility;
- rejects duplicate names;
- starts plugins in registration order;
- rolls back already-started plugins if startup fails;
- stops plugins in reverse order;
- publishes events to started plugins.

### The Concept

Plugin lifecycle order matters.

Suppose plugins depend on resources initialized by earlier plugins:

```text
Metrics plugin starts
        ↓
Tracing plugin starts
        ↓
Application begins publishing events
```

Shutdown should happen in reverse order:

```text
Tracing plugin stops
        ↓
Metrics plugin stops
```

This is similar to assembling and disassembling scaffolding:

- Build lower supporting layers first.
- Remove upper layers first.

If startup fails halfway through, the registry must clean up plugins that already started.

### The Implementation

Create the plugin registry module.

## `src/pulsequeue/plugins.py`

```python
"""Plugin registration, lifecycle management, and event publication."""

from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass
from enum import StrEnum
from types import MappingProxyType
from typing import Mapping

from pulsequeue.events import TaskEvent
from pulsequeue.typing import LifecyclePlugin


class PluginRegistryState(StrEnum):
    """Represent the lifecycle state of a PluginRegistry."""

    CREATED = "created"
    STARTING = "starting"
    STARTED = "started"
    STOPPING = "stopping"
    STOPPED = "stopped"


class DuplicatePluginError(ValueError):
    """Raised when two plugins use the same registry name."""


class PluginLifecycleError(RuntimeError):
    """Raised when a plugin startup or shutdown operation fails."""


@dataclass(frozen=True, slots=True)
class PluginRegistryStats:
    """A stable diagnostic snapshot of registered plugin state."""

    state: PluginRegistryState
    registered_plugins: int
    started_plugins: int


class PluginRegistry:
    """Own plugins and coordinate safe startup, shutdown, and event delivery."""

    def __init__(self) -> None:
        """Create an empty registry in its initial state."""
        self._plugins: dict[str, LifecyclePlugin] = {}
        self._started_plugins: list[LifecyclePlugin] = []
        self._state = PluginRegistryState.CREATED

    @property
    def state(self) -> PluginRegistryState:
        """Return the registry lifecycle state."""
        return self._state

    def stats(self) -> PluginRegistryStats:
        """Return a snapshot suitable for diagnostics."""
        return PluginRegistryStats(
            state=self._state,
            registered_plugins=len(self._plugins),
            started_plugins=len(self._started_plugins),
        )

    def register(self, plugin: LifecyclePlugin) -> LifecyclePlugin:
        """Register one structurally compatible plugin before startup."""
        if self._state is not PluginRegistryState.CREATED:
            raise PluginLifecycleError(
                "Plugins can be registered only while the registry is created."
            )

        if not isinstance(plugin, LifecyclePlugin):
            raise TypeError(
                "Plugin must provide name, async start(), async stop(), and "
                "async on_event(event) methods."
            )

        plugin_name = plugin.name

        if not plugin_name or not plugin_name.strip():
            raise ValueError("Plugin name cannot be empty.")

        if plugin_name in self._plugins:
            raise DuplicatePluginError(
                f"Plugin {plugin_name!r} is already registered."
            )

        self._plugins[plugin_name] = plugin
        return plugin

    def registered(self) -> Mapping[str, LifecyclePlugin]:
        """Return a read-only snapshot of registered plugins."""
        return MappingProxyType(self._plugins.copy())

    async def start(self) -> None:
        """Start registered plugins in order and roll back on startup failure."""
        if self._state is not PluginRegistryState.CREATED:
            raise PluginLifecycleError(
                f"Cannot start plugin registry from state {self._state!r}."
            )

        self._state = PluginRegistryState.STARTING

        try:
            for plugin in self._plugins.values():
                await plugin.start()
                self._started_plugins.append(plugin)
        except Exception as error:
            await self._stop_started_plugins_safely()
            self._state = PluginRegistryState.STOPPED

            raise PluginLifecycleError(
                f"Plugin startup failed for {plugin.name!r}."
            ) from error

        self._state = PluginRegistryState.STARTED

    async def stop(self) -> None:
        """Stop started plugins in reverse registration order."""
        if self._state is PluginRegistryState.STOPPED:
            return

        if self._state is PluginRegistryState.CREATED:
            self._state = PluginRegistryState.STOPPED
            return

        if self._state is not PluginRegistryState.STARTED:
            raise PluginLifecycleError(
                f"Cannot stop plugin registry from state {self._state!r}."
            )

        self._state = PluginRegistryState.STOPPING

        errors = await self._stop_started_plugins_safely()
        self._state = PluginRegistryState.STOPPED

        if errors:
            raise ExceptionGroup(
                "One or more plugins failed during shutdown.",
                errors,
            )

    async def publish(self, event: TaskEvent) -> None:
        """Deliver an event to every started plugin in registration order."""
        if self._state is not PluginRegistryState.STARTED:
            raise PluginLifecycleError(
                "Cannot publish events until the plugin registry is started."
            )

        for plugin in self._started_plugins:
            await plugin.on_event(event)

    async def _stop_started_plugins_safely(self) -> list[Exception]:
        """Stop started plugins in reverse order and collect shutdown errors."""
        errors: list[Exception] = []

        while self._started_plugins:
            plugin = self._started_plugins.pop()

            try:
                await plugin.stop()
            except Exception as error:
                errors.append(error)

        return errors

    def __iter__(self) -> Iterator[LifecyclePlugin]:
        """Iterate registered plugins in registration order."""
        return iter(self._plugins.values())

    def __len__(self) -> int:
        """Return the number of registered plugins."""
        return len(self._plugins)
```

### The Verification

Create a plugin lifecycle demonstration.

## `examples/50_plugin_lifecycle.py`

```python
"""Demonstrate structural plugins, events, and lifecycle ordering."""

from __future__ import annotations

import asyncio

from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.plugins import PluginRegistry


class RecordingPlugin:
    """A plugin that records each lifecycle operation in a shared list."""

    def __init__(self, name: str, log: list[str]) -> None:
        self.name = name
        self._log = log

    async def start(self) -> None:
        """Record startup."""
        self._log.append(f"start:{self.name}")

    async def stop(self) -> None:
        """Record shutdown."""
        self._log.append(f"stop:{self.name}")

    async def on_event(self, event: TaskEvent) -> None:
        """Record event delivery."""
        self._log.append(f"event:{self.name}:{event.event_type.value}")


async def main() -> None:
    """Start plugins, publish an event, and stop them."""
    log: list[str] = []
    registry = PluginRegistry()

    registry.register(RecordingPlugin("metrics", log))
    registry.register(RecordingPlugin("audit", log))

    await registry.start()

    await registry.publish(
        TaskEvent.create(
            event_type=TaskEventType.SUBMITTED,
            task_id="task-001",
            task_name="emails.send_welcome_email",
            attempt=0,
        )
    )

    await registry.stop()

    print(f"Registry statistics: {registry.stats()}")

    print("Lifecycle log:")
    for line in log:
        print(f"- {line}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/50_plugin_lifecycle.py
```

Expected output:

```text
Registry statistics: PluginRegistryStats(state=<PluginRegistryState.STOPPED: 'stopped'>, registered_plugins=2, started_plugins=0)
Lifecycle log:
- start:metrics
- start:audit
- event:metrics:task.submitted
- event:audit:task.submitted
- stop:audit
- stop:metrics
```

Notice that startup follows registration order, while shutdown follows reverse order.

---

## Step 4: Build Useful Event Plugins

### The Target

Create two reusable plugins:

- `ConsoleEventPlugin` for readable development output;
- `InMemoryEventPlugin` for tests and diagnostics.

### The Concept

Plugins should have narrow, single-purpose responsibilities.

A console plugin should print events. It should not also store results, manage workers, and alter retry behavior.

A small plugin is easier to test, replace, and compose.

### The Implementation

Create the plugin implementations.

## `src/pulsequeue/builtin_plugins.py`

```python
"""Built-in protocol-compatible plugins for development and testing."""

from __future__ import annotations

from collections.abc import Callable

from pulsequeue.events import TaskEvent


class ConsoleEventPlugin:
    """Print task lifecycle events to a caller-provided output function."""

    def __init__(
        self,
        *,
        name: str = "console_events",
        output: Callable[[str], None] = print,
    ) -> None:
        """Configure a development-friendly event printer."""
        if not name or not name.strip():
            raise ValueError("Plugin name cannot be empty.")

        self.name = name
        self._output = output
        self._started = False

    async def start(self) -> None:
        """Mark the plugin ready to receive events."""
        self._started = True

    async def stop(self) -> None:
        """Mark the plugin stopped."""
        self._started = False

    async def on_event(self, event: TaskEvent) -> None:
        """Print one event after checking lifecycle correctness."""
        if not self._started:
            raise RuntimeError("ConsoleEventPlugin received an event before start().")

        details = event.details_as_dict()

        self._output(
            f"[{event.occurred_at.isoformat()}] "
            f"{event.event_type.value} "
            f"task_id={event.task_id} "
            f"task_name={event.task_name} "
            f"attempt={event.attempt} "
            f"details={details}"
        )


class InMemoryEventPlugin:
    """Retain events in memory for tests, local inspection, and demos."""

    def __init__(self, *, name: str = "in_memory_events") -> None:
        """Create an initially empty event collector."""
        if not name or not name.strip():
            raise ValueError("Plugin name cannot be empty.")

        self.name = name
        self.events: list[TaskEvent] = []
        self._started = False

    async def start(self) -> None:
        """Permit event collection."""
        self._started = True

    async def stop(self) -> None:
        """Stop accepting new events while retaining history for inspection."""
        self._started = False

    async def on_event(self, event: TaskEvent) -> None:
        """Store one immutable event."""
        if not self._started:
            raise RuntimeError("InMemoryEventPlugin received an event before start().")

        self.events.append(event)
```

Create an example.

## `examples/51_builtin_plugins.py`

```python
"""Use built-in PulseQueue event plugins through the plugin registry."""

from __future__ import annotations

import asyncio

from pulsequeue.builtin_plugins import ConsoleEventPlugin, InMemoryEventPlugin
from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.plugins import PluginRegistry


async def main() -> None:
    """Publish one event to a console plugin and in-memory plugin."""
    registry = PluginRegistry()
    memory_plugin = InMemoryEventPlugin()

    registry.register(ConsoleEventPlugin())
    registry.register(memory_plugin)

    await registry.start()

    event = TaskEvent.create(
        event_type=TaskEventType.RETRYING,
        task_id="task-123",
        task_name="integrations.fetch_partner_data",
        attempt=1,
        details={
            "delay_seconds": 0.5,
            "exception_type": "ConnectionError",
        },
    )

    await registry.publish(event)

    print(f"In-memory event count: {len(memory_plugin.events)}")
    print(f"Stored event type: {memory_plugin.events[0].event_type.value}")

    await registry.stop()


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/51_builtin_plugins.py
```

Expected output includes:

```text
[2026-...] task.retrying task_id=task-123 task_name=integrations.fetch_partner_data attempt=1 details={'delay_seconds': '0.5', 'exception_type': 'ConnectionError'}
In-memory event count: 1
Stored event type: task.retrying
```

The timestamp naturally differs on your machine.

---

## Step 5: Verify Startup Rollback

### The Target

Demonstrate that plugins already started are stopped if a later plugin fails during startup.

### The Concept

Partial startup is dangerous.

Suppose:

```text
Plugin A starts successfully.
Plugin B fails to start.
Application exits without stopping Plugin A.
```

Plugin A may retain open connections, background tasks, files, or memory.

The registry prevents this by rolling back already-started plugins.

### The Implementation

Create this example.

## `examples/52_plugin_startup_rollback.py`

```python
"""Demonstrate cleanup of already-started plugins after startup failure."""

from __future__ import annotations

import asyncio

from pulsequeue.plugins import PluginLifecycleError, PluginRegistry


class WorkingPlugin:
    """A plugin that starts and stops normally."""

    def __init__(self, log: list[str]) -> None:
        self.name = "working"
        self._log = log

    async def start(self) -> None:
        self._log.append("working:start")

    async def stop(self) -> None:
        self._log.append("working:stop")

    async def on_event(self, event: object) -> None:
        self._log.append("working:event")


class BrokenStartupPlugin:
    """A plugin that fails while acquiring startup resources."""

    def __init__(self, log: list[str]) -> None:
        self.name = "broken"
        self._log = log

    async def start(self) -> None:
        self._log.append("broken:start")
        raise ConnectionError("Cannot connect to the demonstration service.")

    async def stop(self) -> None:
        self._log.append("broken:stop")

    async def on_event(self, event: object) -> None:
        self._log.append("broken:event")


async def main() -> None:
    """Show that the first plugin is stopped after the second fails."""
    log: list[str] = []
    registry = PluginRegistry()

    registry.register(WorkingPlugin(log))
    registry.register(BrokenStartupPlugin(log))

    try:
        await registry.start()
    except PluginLifecycleError as error:
        print(f"Startup error: {error}")

    print(f"Registry state: {registry.state}")
    print(f"Lifecycle log: {log}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/52_plugin_startup_rollback.py
```

Expected output:

```text
Startup error: Plugin startup failed for 'broken'.
Registry state: stopped
Lifecycle log: ['working:start', 'broken:start', 'working:stop']
```

The working plugin was stopped even though startup did not complete.

---

## Step 6: Add Tests for Protocols and Plugins

### The Target

Add automated tests for structural protocol compatibility, lifecycle ordering, duplicate prevention, and startup rollback.

### The Concept

Plugins are extension code. Extension points must be stricter than ordinary internal code because framework authors cannot control every plugin implementation.

The registry must protect the application from predictable lifecycle errors.

### The Implementation

Create the test file.

## `tests/test_plugins_and_protocols.py`

```python
"""Tests for protocol-based extension contracts and plugin lifecycle behavior."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue.builtin_plugins import InMemoryEventPlugin
from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.plugins import (
    DuplicatePluginError,
    PluginLifecycleError,
    PluginRegistry,
    PluginRegistryState,
)
from pulsequeue.typing import EventSink


class RecordingPlugin:
    """A structurally compatible plugin that records lifecycle operations."""

    def __init__(self, name: str, log: list[str]) -> None:
        self.name = name
        self._log = log

    async def start(self) -> None:
        self._log.append(f"start:{self.name}")

    async def stop(self) -> None:
        self._log.append(f"stop:{self.name}")

    async def on_event(self, event: TaskEvent) -> None:
        self._log.append(f"event:{self.name}:{event.event_type.value}")


class FailingPlugin(RecordingPlugin):
    """A plugin that fails during startup after recording its attempt."""

    async def start(self) -> None:
        await super().start()
        raise RuntimeError("startup failed")


class SimpleSink:
    """A class satisfying EventSink without explicit protocol inheritance."""

    def __init__(self) -> None:
        self.received: list[TaskEvent] = []

    def emit(self, event: TaskEvent) -> None:
        self.received.append(event)


def test_structural_event_sink_compatibility() -> None:
    """A matching method shape should satisfy the runtime-checkable protocol."""
    sink = SimpleSink()

    assert isinstance(sink, EventSink)


def test_plugin_lifecycle_order_and_event_delivery() -> None:
    """Plugins should start forward, receive events forward, and stop backward."""

    async def run_test() -> None:
        log: list[str] = []
        registry = PluginRegistry()

        registry.register(RecordingPlugin("first", log))
        registry.register(RecordingPlugin("second", log))

        await registry.start()

        await registry.publish(
            TaskEvent.create(
                event_type=TaskEventType.SUCCEEDED,
                task_id="task-001",
                task_name="math.add",
                attempt=1,
            )
        )

        await registry.stop()

        assert log == [
            "start:first",
            "start:second",
            "event:first:task.succeeded",
            "event:second:task.succeeded",
            "stop:second",
            "stop:first",
        ]
        assert registry.state is PluginRegistryState.STOPPED

    asyncio.run(run_test())


def test_plugin_registry_rejects_duplicate_names() -> None:
    """Plugin names must be unique within one registry."""
    registry = PluginRegistry()
    log: list[str] = []

    registry.register(RecordingPlugin("metrics", log))

    with pytest.raises(DuplicatePluginError, match="already registered"):
        registry.register(RecordingPlugin("metrics", log))


def test_plugin_startup_failure_rolls_back_started_plugins() -> None:
    """Already-started plugins should stop after a later startup failure."""

    async def run_test() -> None:
        log: list[str] = []
        registry = PluginRegistry()

        registry.register(RecordingPlugin("first", log))
        registry.register(FailingPlugin("second", log))

        with pytest.raises(PluginLifecycleError, match="second"):
            await registry.start()

        assert log == [
            "start:first",
            "start:second",
            "stop:first",
        ]
        assert registry.state is PluginRegistryState.STOPPED

    asyncio.run(run_test())


def test_in_memory_event_plugin_stores_immutable_events() -> None:
    """The built-in plugin should retain events while it is started."""

    async def run_test() -> None:
        plugin = InMemoryEventPlugin()
        registry = PluginRegistry()
        registry.register(plugin)

        await registry.start()

        event = TaskEvent.create(
            event_type=TaskEventType.FAILED,
            task_id="task-002",
            task_name="examples.fail",
            attempt=1,
        )

        await registry.publish(event)
        await registry.stop()

        assert plugin.events == [event]

    asyncio.run(run_test())
```

Update the public package exports.

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
from pulsequeue.task import Task
from pulsequeue.worker import PulseQueueWorker

__all__ = [
    "DuplicatePluginError",
    "DuplicateTaskError",
    "PluginLifecycleError",
    "PluginRegistry",
    "PluginRegistryState",
    "PulseQueue",
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

Run:

```bash
python -m pytest -q
```

Expected result resembles:

```text
...................................................                    [100%]
51 passed
```

The exact total varies according to whether the optional native extension built successfully. All tests should pass.

---

# Phase 4 Reference: Protocols and Generic Typing

## Protocols Versus Abstract Base Classes

An abstract base class typically requires inheritance:

```python
class RequiredBase:
    ...
```

A protocol requires behavior:

```python
class EventSink(Protocol):
    def emit(self, event: TaskEvent) -> None:
        ...
```

Use a protocol when:

- you want third-party implementations without framework inheritance;
- you need lightweight interfaces;
- tests need simple fake implementations;
- runtime ownership should remain independent.

Use an abstract base class when:

- the framework provides required shared implementation;
- inheritance is part of the intended public design;
- subclasses need protected helper methods or state.

---

## What `@runtime_checkable` Does—and Does Not Do

We used:

```python
@runtime_checkable
class LifecyclePlugin(Protocol):
    ...
```

This allows:

```python
isinstance(plugin, LifecyclePlugin)
```

But it only checks that expected attributes exist.

It does **not** prove:

- that `start()` is really asynchronous;
- that parameter types are correct;
- that `on_event()` handles events safely;
- that plugin behavior is logically correct.

Static type checking is still valuable. Later, we will add tooling such as `mypy` or `pyright` to validate type contracts before runtime.

---

## Generic Type Variables

These type variables:

```python
InputT = TypeVar("InputT")
OutputT = TypeVar("OutputT")
```

allow one interface to preserve relationships between values:

```python
ResultTransformer[int, str]
ResultTransformer[TaskEvent, dict[str, object]]
```

This is safer than using `Any` everywhere.

`Any` means:

> “Disable type checking here.”

Use it carefully at unavoidable dynamic boundaries, such as deserialized task payloads. Prefer precise generic types inside your own framework code.
