# Part 14: Safe Task Serialization and CPU-Bound Task Execution

The in-memory worker is now capable of executing asynchronous I/O tasks with retries, results, plugins, configuration, and graceful shutdown.

Two important production boundaries remain:

1. **Task messages must be serializable** before they can travel through a durable broker or across a network.
2. **CPU-bound Python work must run outside the event loop** and, in CPython, outside the current process’s GIL.

This part adds both capabilities.

By the end, PulseQueue supports two explicit task categories:

```python
@app.task(queue="emails")
async def send_email(...) -> str:
    ...
```

```python
@app.cpu_task(queue="analytics")
def calculate_score(...) -> int:
    ...
```

The distinction is intentional:

| Task kind | Callable declaration | Execution location |
|---|---|---|
| Async I/O task | `async def` | `asyncio` worker event loop |
| CPU-bound task | ordinary `def` | `ProcessPoolExecutor` child process |

---

## Step 1: Define Safe JSON Task Payload Rules

### The Target

Create a serializer that converts task envelopes into JSON-compatible messages without using `pickle`.

### The Concept

A durable queue cannot store a live Python object such as this:

```python
TaskEnvelope(...)
```

Instead, it needs bytes or text:

```json
{
  "task_id": "task-123",
  "task_name": "emails.send_welcome_email",
  "args": [42],
  "kwargs": {
    "locale": "en-GB"
  }
}
```

It may be tempting to use Python’s `pickle` module because it can serialize many Python values.

Do not use `pickle` for messages received from a broker or external source.

`pickle` is not merely data encoding. Loading a malicious pickle can execute arbitrary code. JSON is more limited, but that limitation is a security advantage.

PulseQueue will allow only JSON-compatible values:

- `None`
- `bool`
- `int`
- finite `float`
- `str`
- lists
- dictionaries with string keys

### The Implementation

Create the serialization module.

## `src/pulsequeue/serialization.py`

```python
"""Safe JSON serialization for task envelopes and durable broker boundaries."""

from __future__ import annotations

import json
import math
from collections.abc import Mapping
from datetime import UTC, datetime
from typing import Any

from pulsequeue.envelope import TaskEnvelope


class TaskSerializationError(ValueError):
    """Raised when task arguments cannot safely become JSON message data."""


JsonScalar = None | bool | int | float | str
JsonValue = JsonScalar | list["JsonValue"] | dict[str, "JsonValue"]


def ensure_json_value(
    value: Any,
    *,
    path: str = "$",
) -> JsonValue:
    """Validate and normalize one JSON-compatible value recursively.

    The function rejects unsupported Python objects instead of converting them
    with str(...). Silent string conversion would lose type information and
    make task behavior depend on accidental formatting.
    """
    if value is None or isinstance(value, (bool, int, str)):
        return value

    if isinstance(value, float):
        if not math.isfinite(value):
            raise TaskSerializationError(
                f"Value at {path} must be a finite float, not {value!r}."
            )

        return value

    if isinstance(value, list | tuple):
        return [
            ensure_json_value(item, path=f"{path}[{index}]")
            for index, item in enumerate(value)
        ]

    if isinstance(value, Mapping):
        normalized_mapping: dict[str, JsonValue] = {}

        for key, item in value.items():
            if not isinstance(key, str):
                raise TaskSerializationError(
                    f"Mapping key at {path} must be str, not {type(key).__name__}."
                )

            normalized_mapping[key] = ensure_json_value(
                item,
                path=f"{path}.{key}",
            )

        return normalized_mapping

    raise TaskSerializationError(
        f"Value at {path} has unsupported type {type(value).__name__}. "
        "Task arguments must use JSON-compatible values."
    )


def envelope_to_json(envelope: TaskEnvelope) -> str:
    """Serialize an immutable task envelope to compact UTF-8-safe JSON text."""
    payload: dict[str, JsonValue] = {
        "task_id": envelope.task_id,
        "task_name": envelope.task_name,
        "args": ensure_json_value(list(envelope.args), path="$.args"),
        "kwargs": ensure_json_value(dict(envelope.kwargs), path="$.kwargs"),
        "submitted_at": envelope.submitted_at.astimezone(UTC).isoformat(),
    }

    return json.dumps(
        payload,
        ensure_ascii=False,
        separators=(",", ":"),
        sort_keys=True,
    )


def envelope_from_json(serialized: str) -> TaskEnvelope:
    """Deserialize and validate one JSON task-envelope message.

    This function validates shape and primitive value types before constructing
    a TaskEnvelope. It does not execute code and does not deserialize Python
    classes from untrusted message content.
    """
    try:
        raw_payload = json.loads(serialized)
    except json.JSONDecodeError as error:
        raise TaskSerializationError("Task message is not valid JSON.") from error

    if not isinstance(raw_payload, dict):
        raise TaskSerializationError("Task message root must be a JSON object.")

    expected_keys = {
        "task_id",
        "task_name",
        "args",
        "kwargs",
        "submitted_at",
    }

    actual_keys = set(raw_payload)

    if actual_keys != expected_keys:
        missing_keys = sorted(expected_keys - actual_keys)
        extra_keys = sorted(actual_keys - expected_keys)

        raise TaskSerializationError(
            "Task message must contain exactly the expected keys. "
            f"Missing: {missing_keys}; extra: {extra_keys}."
        )

    task_id = raw_payload["task_id"]
    task_name = raw_payload["task_name"]
    args = raw_payload["args"]
    kwargs = raw_payload["kwargs"]
    submitted_at_text = raw_payload["submitted_at"]

    if not isinstance(task_id, str) or not task_id:
        raise TaskSerializationError("task_id must be a non-empty string.")

    if not isinstance(task_name, str) or not task_name:
        raise TaskSerializationError("task_name must be a non-empty string.")

    if not isinstance(args, list):
        raise TaskSerializationError("args must be a JSON array.")

    if not isinstance(kwargs, dict):
        raise TaskSerializationError("kwargs must be a JSON object.")

    if not isinstance(submitted_at_text, str):
        raise TaskSerializationError("submitted_at must be an ISO-8601 string.")

    try:
        submitted_at = datetime.fromisoformat(submitted_at_text)
    except ValueError as error:
        raise TaskSerializationError(
            "submitted_at must be a valid ISO-8601 timestamp."
        ) from error

    if submitted_at.tzinfo is None:
        raise TaskSerializationError("submitted_at must include timezone information.")

    normalized_args = ensure_json_value(args, path="$.args")
    normalized_kwargs = ensure_json_value(kwargs, path="$.kwargs")

    if not isinstance(normalized_args, list):
        raise RuntimeError("Validated args unexpectedly did not remain a list.")

    if not isinstance(normalized_kwargs, dict):
        raise RuntimeError("Validated kwargs unexpectedly did not remain a dictionary.")

    return TaskEnvelope.create(
        task_id=task_id,
        task_name=task_name,
        args=tuple(normalized_args),
        kwargs=normalized_kwargs,
        submitted_at=submitted_at,
    )
```

### The Verification

Create the serializer demonstration.

## `examples/58_task_envelope_serialization.py`

```python
"""Serialize and deserialize a PulseQueue task message safely."""

from __future__ import annotations

from datetime import UTC, datetime

from pulsequeue.envelope import TaskEnvelope
from pulsequeue.serialization import (
    TaskSerializationError,
    envelope_from_json,
    envelope_to_json,
)


envelope = TaskEnvelope.create(
    task_id="task-serialization-001",
    task_name="emails.send_welcome_email",
    args=(42,),
    kwargs={
        "locale": "en-GB",
        "metadata": {
            "campaign": "onboarding",
            "priority": 10,
        },
    },
    submitted_at=datetime.now(UTC),
)

serialized = envelope_to_json(envelope)
restored = envelope_from_json(serialized)

print(f"Serialized JSON: {serialized}")
print(f"Restored task ID: {restored.task_id}")
print(f"Restored task name: {restored.task_name}")
print(f"Restored arguments: {restored.args}")
print(f"Restored keyword arguments: {dict(restored.kwargs)}")

try:
    invalid_envelope = TaskEnvelope.create(
        task_id="task-invalid-001",
        task_name="examples.invalid",
        args=({1, 2, 3},),
        kwargs={},
        submitted_at=datetime.now(UTC),
    )

    envelope_to_json(invalid_envelope)
except TaskSerializationError as error:
    print(f"Unsupported-value error: {error}")
```

### The Verification

Run:

```bash
python examples/58_task_envelope_serialization.py
```

Expected output includes:

```text
Restored task ID: task-serialization-001
Restored task name: emails.send_welcome_email
Restored arguments: (42,)
Restored keyword arguments: {'locale': 'en-GB', 'metadata': {'campaign': 'onboarding', 'priority': 10}}
Unsupported-value error: Value at $.args[0] has unsupported type set.
```

---

## Step 2: Create a CPU Task Definition

### The Target

Create `CpuTask`, a task wrapper for synchronous module-level CPU functions.

### The Concept

Our existing `Task` class requires `async def` because it runs inside the event loop.

A CPU task is different:

```python
def count_primes(limit: int) -> int:
    ...
```

It must run in a process worker.

A process worker cannot reliably execute:

- nested functions;
- lambda functions;
- closures;
- bound methods with non-pickleable state.

To keep the contract clear, PulseQueue requires CPU task functions to be:

1. ordinary synchronous functions;
2. defined at module scope;
3. importable by child processes;
4. supplied with pickleable arguments and return values.

### The Implementation

Create the CPU task module.

## `src/pulsequeue/cpu_task.py`

```python
"""Synchronous CPU-bound task definitions for process-based execution."""

from __future__ import annotations

import functools
import inspect
from collections.abc import Callable
from pathlib import Path
from typing import Any, Generic, ParamSpec, TypeVar

from pulsequeue.options import TaskOptions

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class CpuTask(Generic[ParametersT, ResultT]):
    """A registered synchronous function intended for process-pool execution."""

    __slots__ = (
        "__dict__",
        "_function",
        "_options",
        "_signature",
        "_source_file",
        "_source_line",
    )

    def __init__(
        self,
        function: Callable[ParametersT, ResultT],
        options: TaskOptions,
    ) -> None:
        """Validate a module-level synchronous function and its task options."""
        if inspect.iscoroutinefunction(function):
            raise TypeError(
                f"CPU task {function.__qualname__!r} must use ordinary 'def', "
                "not 'async def'."
            )

        if "<locals>" in function.__qualname__:
            raise TypeError(
                f"CPU task {function.__qualname__!r} must be defined at module "
                "scope so child processes can import it."
            )

        if function.__name__ == "<lambda>":
            raise TypeError("CPU tasks cannot use lambda functions.")

        self._function = function
        self._options = options
        self._signature = inspect.signature(function)

        source_file = inspect.getsourcefile(function)
        source_lines, source_line = inspect.getsourcelines(function)

        self._source_file = (
            Path(source_file).resolve()
            if source_file is not None
            else None
        )
        self._source_line = source_line if source_lines else None

        functools.update_wrapper(self, function)

    @property
    def function(self) -> Callable[ParametersT, ResultT]:
        """Return the importable synchronous Python function."""
        return self._function

    @property
    def options(self) -> TaskOptions:
        """Return validated CPU task configuration."""
        return self._options

    @property
    def name(self) -> str:
        """Return the stable queue-qualified task name."""
        return self._options.qualified_name

    @property
    def signature(self) -> inspect.Signature:
        """Return the original callable signature."""
        return self._signature

    @property
    def source_file(self) -> Path | None:
        """Return source file path when discoverable."""
        return self._source_file

    @property
    def source_line(self) -> int | None:
        """Return source line when discoverable."""
        return self._source_line

    def bind_arguments(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> inspect.BoundArguments:
        """Validate a proposed CPU-task invocation before queue submission."""
        return self._signature.bind(*args, **kwargs)

    def describe(self) -> dict[str, Any]:
        """Return introspection metadata compatible with ordinary tasks."""
        return {
            "name": self.name,
            "function_name": self._function.__name__,
            "qualified_function_name": self._function.__qualname__,
            "module": self._function.__module__,
            "signature": str(self._signature),
            "source_file": str(self._source_file) if self._source_file else None,
            "source_line": self._source_line,
            "queue": self._options.queue,
            "max_retries": self._options.max_retries,
            "timeout_seconds": self._options.timeout_seconds,
            "execution_kind": "cpu_bound",
            "metadata": self._options.metadata.as_dict(),
        }

    def __repr__(self) -> str:
        """Return a compact debug representation."""
        return (
            f"{type(self).__name__}("
            f"name={self.name!r}, "
            f"signature={str(self._signature)!r}"
            f")"
        )
```

### The Verification

Create a module-level CPU function.

## `examples/capstone_cpu_functions.py`

```python
"""Importable CPU-bound functions used by the PulseQueue capstone."""

from __future__ import annotations


def count_primes(limit: int) -> int:
    """Count prime values below limit using intentionally CPU-heavy Python."""
    if limit < 2:
        return 0

    total = 0

    for candidate in range(2, limit):
        is_prime = True
        divisor = 2

        while divisor * divisor <= candidate:
            if candidate % divisor == 0:
                is_prime = False
                break

            divisor += 1

        if is_prime:
            total += 1

    return total
```

Create the demonstration.

## `examples/59_cpu_task_definition.py`

```python
"""Create and inspect one process-safe CPU task definition."""

from __future__ import annotations

from examples.capstone_cpu_functions import count_primes
from pulsequeue.cpu_task import CpuTask
from pulsequeue.options import TaskOptions


task = CpuTask(
    count_primes,
    TaskOptions(
        name="count_primes",
        queue="analytics",
        timeout_seconds=10.0,
    ),
)

print(f"CPU task: {task!r}")
print(f"Task name: {task.name}")
print(f"Task signature: {task.signature}")
print(f"Task details: {task.describe()}")
```

### The Verification

Because `examples` is not yet a package, add an initializer.

## `examples/__init__.py`

```python
"""Runnable examples and importable demonstration helpers for this tutorial."""
```

Run:

```bash
python -m examples.59_cpu_task_definition
```

Expected output includes:

```text
CPU task: CpuTask(name='analytics.count_primes', signature='(limit: int) -> int')
Task name: analytics.count_primes
Task signature: (limit: int) -> int
```

---

## Step 3: Expand the Registry for Async and CPU Tasks

### The Target

Allow one task registry to store both `Task` and `CpuTask` definitions.

### The Concept

Both task types share operational behavior:

- stable task name;
- options;
- signature;
- argument binding;
- introspection.

They differ only in execution strategy.

We will define a `RegisteredTask` union. The registry stores either kind, while workers choose the correct execution path.

### The Implementation

Replace `src/pulsequeue/registry.py`.

## `src/pulsequeue/registry.py`

```python
"""Task registration and lookup for PulseQueue applications."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from types import MappingProxyType
from typing import Any, TypeAlias

from pulsequeue.cpu_task import CpuTask
from pulsequeue.namespace import AttributeNamespace
from pulsequeue.task import Task

RegisteredTask: TypeAlias = Task[Any, Any] | CpuTask[Any, Any]


class DuplicateTaskError(ValueError):
    """Raised when an application attempts to register a duplicate task name."""


class UnknownTaskError(KeyError):
    """Raised when code requests a task that is not registered."""


class TaskRegistry:
    """Store async and CPU task definitions by stable task name."""

    def __init__(self) -> None:
        self._tasks: dict[str, RegisteredTask] = {}

    def register(self, task: RegisteredTask) -> RegisteredTask:
        """Register a task and reject duplicate stable names."""
        if task.name in self._tasks:
            existing_task = self._tasks[task.name]
            raise DuplicateTaskError(
                f"Task {task.name!r} is already registered by "
                f"{existing_task.function.__module__}."
                f"{existing_task.function.__qualname__}."
            )

        self._tasks[task.name] = task
        return task

    def get(self, name: str) -> RegisteredTask:
        """Return a registered task or raise a clear lookup error."""
        try:
            return self._tasks[name]
        except KeyError as error:
            available = ", ".join(sorted(self._tasks)) or "<none>"
            raise UnknownTaskError(
                f"Task {name!r} is not registered. Available tasks: {available}."
            ) from error

    def contains(self, name: str) -> bool:
        """Return whether a stable task name exists."""
        return name in self._tasks

    def all(self) -> Mapping[str, RegisteredTask]:
        """Return an immutable snapshot of registered tasks."""
        return MappingProxyType(self._tasks.copy())

    def __iter__(self) -> Iterator[RegisteredTask]:
        """Iterate tasks in stable name order."""
        for task_name in sorted(self._tasks):
            yield self._tasks[task_name]

    def __len__(self) -> int:
        """Return the number of registered tasks."""
        return len(self._tasks)

    def namespace(self, *, name: str = "tasks") -> AttributeNamespace:
        """Build a nested read-only attribute namespace from task names."""
        tree: dict[str, Any] = {}

        for task_name, task in self._tasks.items():
            segments = task_name.split(".")

            if len(segments) < 2:
                raise ValueError(
                    f"Task name {task_name!r} must contain queue and task segments."
                )

            current_level = tree

            for segment in segments[:-1]:
                existing_value = current_level.get(segment)

                if existing_value is None:
                    child: dict[str, Any] = {}
                    current_level[segment] = child
                    current_level = child
                elif isinstance(existing_value, dict):
                    current_level = existing_value
                else:
                    raise ValueError(
                        f"Cannot create namespace for {task_name!r}; "
                        f"{segment!r} is already a task leaf."
                    )

            leaf_name = segments[-1]

            if leaf_name in current_level:
                raise ValueError(
                    f"Cannot create namespace for {task_name!r}; "
                    f"duplicate leaf {leaf_name!r}."
                )

            current_level[leaf_name] = task

        return self._build_namespace(tree, name=name)

    @classmethod
    def _build_namespace(
        cls,
        tree: Mapping[str, Any],
        *,
        name: str,
    ) -> AttributeNamespace:
        """Recursively convert nested dictionaries into namespaces."""
        values: dict[str, Any] = {}

        for key, value in tree.items():
            if isinstance(value, dict):
                values[key] = cls._build_namespace(value, name=f"{name}.{key}")
            else:
                values[key] = value

        return AttributeNamespace(values, name=name)
```

Now replace `src/pulsequeue/app.py`.

## `src/pulsequeue/app.py`

```python
"""The public PulseQueue application object."""

from __future__ import annotations

from collections.abc import Awaitable, Callable, Mapping
from typing import Any, ParamSpec, TypeVar

from pulsequeue.broker import InMemoryBroker
from pulsequeue.cpu_task import CpuTask
from pulsequeue.metadata import TaskMetadata
from pulsequeue.namespace import AttributeNamespace
from pulsequeue.options import TaskOptions
from pulsequeue.registry import RegisteredTask, TaskRegistry
from pulsequeue.result import TaskReceipt
from pulsequeue.task import Task

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class PulseQueue:
    """Own task definitions and provide decorator-based registration."""

    def __init__(self, name: str) -> None:
        """Create an application with an isolated task registry."""
        if not name or not name.strip():
            raise ValueError("Application name cannot be empty.")

        if not name.isidentifier():
            raise ValueError(
                f"Application name {name!r} must be a valid Python identifier."
            )

        self._name = name
        self._registry = TaskRegistry()

    @property
    def name(self) -> str:
        """Return the application name."""
        return self._name

    @property
    def tasks(self) -> AttributeNamespace:
        """Expose registered tasks through a read-only namespace snapshot."""
        return self._registry.namespace(name=f"{self._name}.tasks")

    @property
    def task_count(self) -> int:
        """Return the number of registered task definitions."""
        return len(self._registry)

    def registered_tasks(self) -> Mapping[str, RegisteredTask]:
        """Return an immutable snapshot of registered task definitions."""
        return self._registry.all()

    def get_task(self, name: str) -> RegisteredTask:
        """Look up an async or CPU task by queue-qualified name."""
        return self._registry.get(name)

    async def submit(
        self,
        broker: InMemoryBroker,
        task_name: str,
        /,
        *args: Any,
        **kwargs: Any,
    ) -> TaskReceipt[Any]:
        """Validate and enqueue one registered task."""
        task = self.get_task(task_name)
        task.bind_arguments(*args, **kwargs)

        return await broker.submit(
            task_name=task.name,
            args=args,
            kwargs=kwargs,
            max_retries=task.options.max_retries,
        )

    def task(
        self,
        *,
        queue: str,
        name: str | None = None,
        max_retries: int = 0,
        timeout_seconds: float = 0.0,
        retry_delay_seconds: float = 0.1,
        retry_backoff_multiplier: float = 2.0,
        metadata: TaskMetadata | None = None,
    ) -> Callable[
        [Callable[ParametersT, Awaitable[ResultT]]],
        Task[ParametersT, ResultT],
    ]:
        """Return a decorator that registers an async I/O task."""
        self._validate_task_identity(queue=queue, name=name)

        def register_function(
            function: Callable[ParametersT, Awaitable[ResultT]],
        ) -> Task[ParametersT, ResultT]:
            task_name = name if name is not None else function.__name__

            task_definition = Task(
                function,
                TaskOptions(
                    name=task_name,
                    queue=queue,
                    max_retries=max_retries,
                    timeout_seconds=timeout_seconds,
                    retry_delay_seconds=retry_delay_seconds,
                    retry_backoff_multiplier=retry_backoff_multiplier,
                    metadata=metadata,
                ),
            )

            self._registry.register(task_definition)
            return task_definition

        return register_function

    def cpu_task(
        self,
        *,
        queue: str,
        name: str | None = None,
        max_retries: int = 0,
        timeout_seconds: float = 0.0,
        retry_delay_seconds: float = 0.1,
        retry_backoff_multiplier: float = 2.0,
        metadata: TaskMetadata | None = None,
    ) -> Callable[
        [Callable[ParametersT, ResultT]],
        CpuTask[ParametersT, ResultT],
    ]:
        """Return a decorator that registers a process-executed CPU task."""
        self._validate_task_identity(queue=queue, name=name)

        def register_function(
            function: Callable[ParametersT, ResultT],
        ) -> CpuTask[ParametersT, ResultT]:
            task_name = name if name is not None else function.__name__

            task_definition = CpuTask(
                function,
                TaskOptions(
                    name=task_name,
                    queue=queue,
                    max_retries=max_retries,
                    timeout_seconds=timeout_seconds,
                    retry_delay_seconds=retry_delay_seconds,
                    retry_backoff_multiplier=retry_backoff_multiplier,
                    metadata=metadata,
                ),
            )

            self._registry.register(task_definition)
            return task_definition

        return register_function

    @staticmethod
    def _validate_task_identity(*, queue: str, name: str | None) -> None:
        """Validate names used by task decorators and attribute namespaces."""
        if not queue or not queue.strip():
            raise ValueError("Task queue cannot be empty.")

        if not queue.isidentifier():
            raise ValueError(
                f"Task queue {queue!r} must be a valid Python identifier."
            )

        if name is not None and (not name or not name.isidentifier()):
            raise ValueError(
                "Task name must be a non-empty valid Python identifier when set."
            )

    def describe(self) -> dict[str, Any]:
        """Return task metadata for diagnostics and tooling."""
        return {
            "name": self._name,
            "task_count": self.task_count,
            "tasks": {
                task_name: task.describe()
                for task_name, task in self.registered_tasks().items()
            },
        }

    def __repr__(self) -> str:
        """Return a concise application representation."""
        return f"{type(self).__name__}(name={self._name!r}, task_count={self.task_count})"
```

### The Verification

Run the existing registration tests:

```bash
python -m pytest tests/test_task_registration.py -q
```

Expected output:

```text
......                                                                   [100%]
6 passed
```

---

## Step 4: Give the Worker a Process Executor

### The Target

Allow `PulseQueueWorker` to execute `CpuTask` objects using `ProcessExecutorPool`.

### The Concept

The worker now chooses execution based on task type:

```text
Task instance
    ↓
await task(...)
```

```text
CpuTask instance
    ↓
await run_cpu_bound(process_pool.executor, task.function, ...)
```

The CPU pool starts with the worker and shuts down only after consumers stop. This avoids process startup cost for every task.

### The Implementation

Replace `src/pulsequeue/worker.py`.

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

            if timeout_seconds == 0:
                await self._broker.join()
            else:
                try:
                    async with asyncio.timeout(timeout_seconds):
                        await self._broker.join()
                except TimeoutError:
                    await self._force_stop()

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
                        details={
                            "result_type": type(result).__name__,
                        },
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
        """Run an async task on the event loop or CPU task in a process pool."""
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
        """Publish an event without allowing plugin faults to alter task state."""
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

Create the capstone CPU execution example.

## `examples/60_cpu_task_worker.py`

```python
"""Run a CPU-bound PulseQueue task in a separate process."""

from __future__ import annotations

import asyncio

from examples.capstone_cpu_functions import count_primes
from pulsequeue import PulseQueue, PulseQueueRuntime


app = PulseQueue("cpu_worker_demo")

# This function is imported from a module, rather than defined inside main().
# That makes it importable by child process workers.
app.cpu_task(
    queue="analytics",
    timeout_seconds=10.0,
)(count_primes)


async def heartbeat() -> None:
    """Show that the parent event loop remains responsive."""
    for number in range(5):
        print(f"Event-loop heartbeat {number}")
        await asyncio.sleep(0.05)


async def main() -> None:
    """Submit CPU work while unrelated async work continues."""
    async with PulseQueueRuntime(
        app,
        worker_concurrency=1,
    ) as runtime:
        receipt = await runtime.submit("analytics.count_primes", 100_000)

        result, _ = await asyncio.gather(
            receipt.result(timeout_seconds=15.0),
            heartbeat(),
        )

        print(f"Prime count below 100,000: {result}")
        print(f"Worker stats: {runtime.worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run it as a module:

```bash
python -m examples.60_cpu_task_worker
```

Expected output includes:

```text
Event-loop heartbeat 0
Event-loop heartbeat 1
Event-loop heartbeat 2
Event-loop heartbeat 3
Event-loop heartbeat 4
Prime count below 100,000: 9592
```

The heartbeat proves that CPU work does not freeze the parent event loop.

---

## Step 5: Add CPU Worker Configuration

### The Target

Add a process-count setting to runtime configuration.

### The Concept

Worker concurrency and CPU process count are different controls:

```text
worker_concurrency:
How many broker consumer coroutines receive task envelopes?

cpu_processes:
How many child processes execute CPU tasks?
```

For a mostly I/O-bound worker, you might choose:

```text
worker_concurrency = 50
cpu_processes = 2
```

For CPU-heavy workloads, process count should normally be no greater than the useful CPU core count available to the deployment.

### The Implementation

Replace `src/pulsequeue/config.py`.

## `src/pulsequeue/config.py`

```python
"""Validated environment-based configuration for PulseQueue runtimes."""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Mapping


def _read_positive_integer(
    environment: Mapping[str, str],
    name: str,
    *,
    default: int,
) -> int:
    """Read a positive integer environment variable."""
    raw_value = environment.get(name)

    if raw_value is None or raw_value == "":
        return default

    try:
        value = int(raw_value)
    except ValueError as error:
        raise ValueError(
            f"Environment variable {name} must be an integer, not {raw_value!r}."
        ) from error

    if value < 1:
        raise ValueError(f"Environment variable {name} must be at least 1.")

    return value


def _read_optional_positive_integer(
    environment: Mapping[str, str],
    name: str,
) -> int | None:
    """Read an optional positive integer; absent means use executor default."""
    raw_value = environment.get(name)

    if raw_value is None or raw_value == "":
        return None

    try:
        value = int(raw_value)
    except ValueError as error:
        raise ValueError(
            f"Environment variable {name} must be an integer, not {raw_value!r}."
        ) from error

    if value < 1:
        raise ValueError(f"Environment variable {name} must be at least 1.")

    return value


def _read_non_negative_float(
    environment: Mapping[str, str],
    name: str,
    *,
    default: float,
) -> float:
    """Read a non-negative float environment variable."""
    raw_value = environment.get(name)

    if raw_value is None or raw_value == "":
        return default

    try:
        value = float(raw_value)
    except ValueError as error:
        raise ValueError(
            f"Environment variable {name} must be a number, not {raw_value!r}."
        ) from error

    if value < 0:
        raise ValueError(
            f"Environment variable {name} must be zero or greater."
        )

    return value


@dataclass(frozen=True, slots=True)
class PulseQueueSettings:
    """Validated runtime settings loaded from environment variables."""

    worker_concurrency: int = 1
    broker_max_queue_size: int = 1_000
    cpu_processes: int | None = None
    shutdown_timeout_seconds: float = 30.0

    @classmethod
    def from_environment(
        cls,
        environment: Mapping[str, str] | None = None,
    ) -> PulseQueueSettings:
        """Create settings from supported PULSEQUEUE_* environment variables."""
        source = os.environ if environment is None else environment

        return cls(
            worker_concurrency=_read_positive_integer(
                source,
                "PULSEQUEUE_WORKER_CONCURRENCY",
                default=1,
            ),
            broker_max_queue_size=_read_positive_integer(
                source,
                "PULSEQUEUE_BROKER_MAX_QUEUE_SIZE",
                default=1_000,
            ),
            cpu_processes=_read_optional_positive_integer(
                source,
                "PULSEQUEUE_CPU_PROCESSES",
            ),
            shutdown_timeout_seconds=_read_non_negative_float(
                source,
                "PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS",
                default=30.0,
            ),
        )
```

Replace `src/pulsequeue/runtime.py`.

## `src/pulsequeue/runtime.py`

```python
"""High-level async runtime composition for PulseQueue applications."""

from __future__ import annotations

from types import TracebackType
from typing import Any, Self

from pulsequeue.app import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.config import PulseQueueSettings
from pulsequeue.plugins import PluginRegistry
from pulsequeue.result import ResultBackend, TaskReceipt
from pulsequeue.worker import PulseQueueWorker


class PulseQueueRuntime:
    """Own a broker, worker, optional plugins, and result backend."""

    def __init__(
        self,
        app: PulseQueue,
        *,
        broker_max_queue_size: int = 1_000,
        worker_concurrency: int = 1,
        cpu_processes: int | None = None,
        plugins: PluginRegistry | None = None,
        result_backend: ResultBackend | None = None,
        shutdown_timeout_seconds: float = 30.0,
    ) -> None:
        """Configure a runtime without starting its worker."""
        if shutdown_timeout_seconds < 0:
            raise ValueError("shutdown_timeout_seconds must be zero or greater.")

        self._app = app
        self._shutdown_timeout_seconds = shutdown_timeout_seconds
        self._broker = InMemoryBroker(
            max_queue_size=broker_max_queue_size,
            result_backend=result_backend,
        )
        self._worker = PulseQueueWorker(
            app,
            self._broker,
            concurrency=worker_concurrency,
            cpu_processes=cpu_processes,
            plugins=plugins,
        )
        self._is_running = False

    @classmethod
    def from_settings(
        cls,
        app: PulseQueue,
        settings: PulseQueueSettings,
        *,
        plugins: PluginRegistry | None = None,
        result_backend: ResultBackend | None = None,
    ) -> PulseQueueRuntime:
        """Create a runtime using validated typed settings."""
        return cls(
            app,
            broker_max_queue_size=settings.broker_max_queue_size,
            worker_concurrency=settings.worker_concurrency,
            cpu_processes=settings.cpu_processes,
            shutdown_timeout_seconds=settings.shutdown_timeout_seconds,
            plugins=plugins,
            result_backend=result_backend,
        )

    @property
    def app(self) -> PulseQueue:
        """Return the application whose tasks this runtime executes."""
        return self._app

    @property
    def broker(self) -> InMemoryBroker:
        """Return the runtime-owned broker."""
        return self._broker

    @property
    def worker(self) -> PulseQueueWorker:
        """Return the runtime-owned worker."""
        return self._worker

    @property
    def is_running(self) -> bool:
        """Return whether the runtime worker is active."""
        return self._is_running

    async def start(self) -> None:
        """Start worker resources and optional plugins."""
        if self._is_running:
            raise RuntimeError("PulseQueueRuntime is already running.")

        await self._worker.start()
        self._is_running = True

    async def stop(self, *, timeout_seconds: float | None = None) -> None:
        """Stop the worker using configured or caller-provided deadline."""
        if not self._is_running:
            return

        actual_timeout = (
            self._shutdown_timeout_seconds
            if timeout_seconds is None
            else timeout_seconds
        )

        if actual_timeout < 0:
            raise ValueError("timeout_seconds must be zero or greater.")

        try:
            await self._worker.stop(timeout_seconds=actual_timeout)
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
        """Start runtime resources on async-context entry."""
        await self.start()
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Stop runtime resources on async-context exit."""
        await self.stop()
```

### The Verification

Run:

```bash
PULSEQUEUE_CPU_PROCESSES=2 python - <<'PY'
from pulsequeue.config import PulseQueueSettings

settings = PulseQueueSettings.from_environment()

print(settings.cpu_processes)
PY
```

Expected output:

```text
2
```

---

## Step 6: Add Tests for Serialization and CPU Tasks

### The Target

Protect message serialization and process-executed task behavior with automated tests.

### The Concept

The two most important guarantees are:

1. Unsupported objects never silently enter a durable-message boundary.
2. CPU tasks execute successfully through the process pool.

### The Implementation

Create importable CPU test helpers.

## `tests/cpu_functions.py`

```python
"""Module-level CPU functions used by process-executor tests."""

from __future__ import annotations


def multiply(left: int, right: int) -> int:
    """Return a CPU-task test result."""
    return left * right
```

Create the test module.

## `tests/test_serialization_and_cpu_tasks.py`

```python
"""Tests for safe task serialization and process-executed CPU tasks."""

from __future__ import annotations

import asyncio
from datetime import UTC, datetime

import pytest

from pulsequeue import PulseQueue, PulseQueueRuntime
from pulsequeue.cpu_task import CpuTask
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.options import TaskOptions
from pulsequeue.serialization import (
    TaskSerializationError,
    envelope_from_json,
    envelope_to_json,
)
from tests.cpu_functions import multiply


def test_task_envelope_json_round_trip() -> None:
    """A JSON-compatible envelope should retain its meaningful contents."""
    envelope = TaskEnvelope.create(
        task_id="task-001",
        task_name="math.add",
        args=(20, 22),
        kwargs={"label": "answer"},
        submitted_at=datetime.now(UTC),
    )

    restored = envelope_from_json(envelope_to_json(envelope))

    assert restored.task_id == envelope.task_id
    assert restored.task_name == envelope.task_name
    assert restored.args == (20, 22)
    assert dict(restored.kwargs) == {"label": "answer"}


def test_task_envelope_rejects_unsupported_values() -> None:
    """Sets and arbitrary objects must not cross the JSON task boundary."""
    envelope = TaskEnvelope.create(
        task_id="task-unsupported",
        task_name="examples.unsupported",
        args=({1, 2},),
        kwargs={},
        submitted_at=datetime.now(UTC),
    )

    with pytest.raises(TaskSerializationError, match="unsupported type set"):
        envelope_to_json(envelope)


def test_cpu_task_rejects_nested_function() -> None:
    """Nested functions are unsafe for spawn-based child process imports."""

    def nested_cpu_function() -> int:
        return 42

    with pytest.raises(TypeError, match="module scope"):
        CpuTask(
            nested_cpu_function,
            TaskOptions(name="nested", queue="examples"),
        )


def test_runtime_executes_cpu_task_in_process_pool() -> None:
    """A module-level synchronous function should execute through CPU workers."""

    async def run_test() -> None:
        app = PulseQueue("cpu_task_test")

        app.cpu_task(queue="math")(multiply)

        async with PulseQueueRuntime(
            app,
            cpu_processes=1,
        ) as runtime:
            receipt = await runtime.submit("math.multiply", 6, 7)

            assert await receipt.result(timeout_seconds=5.0) == 42

    asyncio.run(run_test())
```

### The Verification

Run the focused tests:

```bash
python -m pytest tests/test_serialization_and_cpu_tasks.py -q
```

Expected output:

```text
....                                                                     [100%]
4 passed
```

Then run the whole suite:

```bash
python -m pytest -q
```

All tests should pass.

---

# Capstone Reference: Final Architecture at This Stage

```text
                           ┌─────────────────────┐
                           │   PulseQueue App    │
                           │                     │
                           │ @app.task           │
                           │ @app.cpu_task       │
                           └──────────┬──────────┘
                                      │
                                      ▼
                         ┌────────────────────────┐
                         │     Task Registry      │
                         │ Async Task / CpuTask   │
                         └──────────┬─────────────┘
                                    │
                                    ▼
                         ┌────────────────────────┐
                         │   InMemoryBroker       │
                         │                        │
                         │ • TaskEnvelope queue   │
                         │ • ResultBackend        │
                         └──────────┬─────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │       PulseQueueWorker         │
                    │                               │
                    │ • Async consumers              │
                    │ • Retries / backoff            │
                    │ • Timeouts / cancellation      │
                    │ • Event publishing             │
                    └─────────┬───────────┬─────────┘
                              │           │
                              ▼           ▼
              ┌────────────────────┐  ┌──────────────────────┐
              │ Async I/O Task     │  │ CPU Task             │
              │                    │  │                      │
              │ asyncio event loop │  │ ProcessPoolExecutor  │
              └────────────────────┘  └──────────────────────┘
                              │           │
                              └─────┬─────┘
                                    ▼
                     ┌────────────────────────────┐
                     │      Plugin Registry       │
                     │ Console / Metrics / Audit  │
                     └────────────────────────────┘
```

## Current Production Limitations

The architecture is production-minded, but the broker remains intentionally in-memory.

For true distributed production use, the next layer must replace `InMemoryBroker` with a durable broker that supports:

- authenticated producer and worker connections;
- durable messages;
- acknowledgements;
- delayed retry delivery;
- visibility timeouts;
- dead-letter queues;
- cross-process and cross-machine transport;
- payload-size limits;
- message schema versioning.

The message serializer created in this part is the foundation for that future transport boundary.
