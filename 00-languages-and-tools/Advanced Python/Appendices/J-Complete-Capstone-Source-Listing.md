# Appendix J: Complete Capstone Source Listing

This appendix consolidates the **final corrected framework source**.

> **Important correction:** The final `worker.py` listing in Part 15 contained a transcription defect:
>
> ```python
> self._broker.mark_failed(envelope.task_id)
> ```
>
> The correct call includes the caught exception:
>
> ```python
> self._broker.mark_failed(envelope.task_id, error)
> ```
>
> The listing below includes that correction.

This first section contains the runtime-critical files: package exports, application registration, task models, result state, queue, broker, execution helpers, and worker implementation.

---

## `src/pulsequeue/__init__.py`

```python
"""PulseQueue: an educational high-concurrency Python task framework."""

from pulsequeue.app import PulseQueue
from pulsequeue.config import PulseQueueSettings
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
    InMemoryResultStore,
    ResultBackend,
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
    "InMemoryResultStore",
    "PluginLifecycleError",
    "PluginRegistry",
    "PluginRegistryState",
    "PulseQueue",
    "PulseQueueRuntime",
    "PulseQueueSettings",
    "PulseQueueWorker",
    "ResultBackend",
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

---

## `src/pulsequeue/options.py`

```python
"""Validated task configuration with controlled dynamic metadata access."""

from __future__ import annotations

from typing import Any

from pulsequeue.descriptors import computed_property
from pulsequeue.metadata import TaskMetadata
from pulsequeue.model import Field, Model


def non_negative_integer(value: int) -> None:
    """Reject negative integer values while allowing zero."""
    if value < 0:
        raise ValueError("Value must be zero or greater.")


def non_negative_float(value: float) -> None:
    """Reject negative float values while allowing zero."""
    if value < 0:
        raise ValueError("Value must be zero or greater.")


def positive_float(value: float) -> None:
    """Reject zero and negative float values."""
    if value <= 0:
        raise ValueError("Value must be greater than zero.")


class TaskOptions(Model):
    """Validated configuration for one registered task."""

    name = Field(str)
    queue = Field(str)
    max_retries = Field(int, validator=non_negative_integer)
    timeout_seconds = Field(float, validator=non_negative_float)
    retry_delay_seconds = Field(float, validator=non_negative_float)
    retry_backoff_multiplier = Field(float, validator=positive_float)
    metadata = Field(TaskMetadata, required=False)

    def __init__(
        self,
        *,
        name: str,
        queue: str,
        max_retries: int = 0,
        timeout_seconds: float = 0.0,
        retry_delay_seconds: float = 0.1,
        retry_backoff_multiplier: float = 2.0,
        metadata: TaskMetadata | None = None,
    ) -> None:
        """Create validated task options."""
        super().__init__(
            name=name,
            queue=queue,
            max_retries=max_retries,
            timeout_seconds=timeout_seconds,
            retry_delay_seconds=retry_delay_seconds,
            retry_backoff_multiplier=retry_backoff_multiplier,
            metadata=metadata if metadata is not None else TaskMetadata(),
        )

    @computed_property
    def qualified_name(self) -> str:
        """Return a queue-qualified stable task identifier."""
        return f"{self.queue}.{self.name}"

    @computed_property
    def has_timeout(self) -> bool:
        """Return whether task execution uses a deadline."""
        return self.timeout_seconds > 0.0

    @computed_property
    def max_attempts(self) -> int:
        """Return initial attempt plus configured retries."""
        return 1 + self.max_retries

    def retry_delay_for_attempt(self, retry_number: int) -> float:
        """Return exponential backoff delay for a one-based retry number."""
        if retry_number < 1:
            raise ValueError("retry_number must be at least 1.")

        return self.retry_delay_seconds * (
            self.retry_backoff_multiplier ** (retry_number - 1)
        )

    def __getattr__(self, name: str) -> Any:
        """Resolve explicitly prefixed dynamic metadata reads."""
        prefix = "meta_"

        if not name.startswith(prefix):
            raise AttributeError(
                f"{type(self).__name__} has no attribute {name!r}. "
                "Dynamic metadata reads must use the 'meta_' prefix."
            )

        metadata_name = name.removeprefix(prefix)

        if not metadata_name:
            raise AttributeError(
                "Metadata attribute name cannot be empty; use a name such as "
                "'meta_owner'."
            )

        try:
            return getattr(self.metadata, metadata_name)
        except AttributeError as error:
            raise AttributeError(
                f"{type(self).__name__} could not resolve metadata attribute "
                f"{name!r}: {error}"
            ) from error

    def __setattr__(self, name: str, value: Any) -> None:
        """Reject dynamic metadata writes through the options object."""
        if name.startswith("meta_"):
            raise AttributeError(
                "Dynamic metadata is read-only through TaskOptions. "
                "Assign through the 'metadata' object instead."
            )

        super().__setattr__(name, value)
```

---

## `src/pulsequeue/task.py`

```python
"""Async task definitions and introspection helpers."""

from __future__ import annotations

import functools
import inspect
from collections.abc import Awaitable, Callable
from pathlib import Path
from typing import Any, Generic, ParamSpec, TypeVar

from pulsequeue.options import TaskOptions

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class Task(Generic[ParametersT, ResultT]):
    """A registered coroutine function and its validated configuration."""

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
        function: Callable[ParametersT, Awaitable[ResultT]],
        options: TaskOptions,
    ) -> None:
        """Wrap one coroutine function as a task."""
        if not inspect.iscoroutinefunction(function):
            raise TypeError(
                f"Task {function.__qualname__!r} must be declared with 'async def'."
            )

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

        # __dict__ is intentionally included in slots because update_wrapper
        # attaches function-style metadata such as __name__ and __wrapped__.
        functools.update_wrapper(self, function)

    @property
    def function(self) -> Callable[ParametersT, Awaitable[ResultT]]:
        """Return the wrapped coroutine function."""
        return self._function

    @property
    def options(self) -> TaskOptions:
        """Return validated task configuration."""
        return self._options

    @property
    def name(self) -> str:
        """Return queue-qualified stable task name."""
        return self._options.qualified_name

    @property
    def signature(self) -> inspect.Signature:
        """Return the original function signature."""
        return self._signature

    @property
    def source_file(self) -> Path | None:
        """Return task function source file when available."""
        return self._source_file

    @property
    def source_line(self) -> int | None:
        """Return task function source line when available."""
        return self._source_line

    def bind_arguments(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> inspect.BoundArguments:
        """Validate a proposed call without executing the task."""
        return self._signature.bind(*args, **kwargs)

    async def __call__(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> ResultT:
        """Validate and execute the wrapped coroutine."""
        self.bind_arguments(*args, **kwargs)
        return await self._function(*args, **kwargs)

    def describe(self) -> dict[str, Any]:
        """Return JSON-friendly task diagnostics."""
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
            "execution_kind": "async_io",
            "metadata": self._options.metadata.as_dict(),
        }

    def __repr__(self) -> str:
        """Return a concise debug representation."""
        return (
            f"{type(self).__name__}("
            f"name={self.name!r}, "
            f"signature={str(self._signature)!r}"
            f")"
        )
```

---

## `src/pulsequeue/cpu_task.py`

```python
"""Synchronous CPU-bound task definitions for process-pool execution."""

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
    """A synchronous module-level function intended for process execution."""

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
        """Validate and wrap an importable CPU-bound function."""
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
        """Return wrapped synchronous function."""
        return self._function

    @property
    def options(self) -> TaskOptions:
        """Return validated task configuration."""
        return self._options

    @property
    def name(self) -> str:
        """Return queue-qualified stable task name."""
        return self._options.qualified_name

    @property
    def signature(self) -> inspect.Signature:
        """Return original function signature."""
        return self._signature

    @property
    def source_file(self) -> Path | None:
        """Return source file when available."""
        return self._source_file

    @property
    def source_line(self) -> int | None:
        """Return source line when available."""
        return self._source_line

    def bind_arguments(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> inspect.BoundArguments:
        """Validate a proposed CPU-task call."""
        return self._signature.bind(*args, **kwargs)

    def describe(self) -> dict[str, Any]:
        """Return JSON-friendly task diagnostics."""
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
        """Return concise debug representation."""
        return (
            f"{type(self).__name__}("
            f"name={self.name!r}, "
            f"signature={str(self._signature)!r}"
            f")"
        )
```

---

## `src/pulsequeue/result.py`

```python
"""Task result state, receipts, and pluggable result-backend contracts."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from enum import StrEnum
from typing import Any, Generic, Protocol, TypeVar

ResultT = TypeVar("ResultT")


class TaskState(StrEnum):
    """Lifecycle states of one submitted task."""

    QUEUED = "queued"
    RUNNING = "running"
    RETRYING = "retrying"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
    CANCELLED = "cancelled"


TERMINAL_TASK_STATES = frozenset(
    {
        TaskState.SUCCEEDED,
        TaskState.FAILED,
        TaskState.CANCELLED,
    }
)


@dataclass(frozen=True, slots=True)
class TaskFailure:
    """Safe serializable task-failure information."""

    exception_type: str
    message: str


@dataclass(frozen=True, slots=True)
class TaskResultSnapshot(Generic[ResultT]):
    """Immutable point-in-time task result state."""

    task_id: str
    task_name: str
    state: TaskState
    submitted_at: datetime
    started_at: datetime | None
    completed_at: datetime | None
    attempt: int
    max_attempts: int
    next_retry_at: datetime | None
    value: ResultT | None
    failure: TaskFailure | None


class TaskFailureError(RuntimeError):
    """Raised when a receipt observes a terminal failed task."""

    def __init__(
        self,
        *,
        task_id: str,
        task_name: str,
        failure: TaskFailure,
    ) -> None:
        """Create an error containing safe failure details."""
        super().__init__(
            f"Task {task_name!r} with id {task_id!r} failed with "
            f"{failure.exception_type}: {failure.message}"
        )
        self.task_id = task_id
        self.task_name = task_name
        self.failure = failure


class TaskCancelledError(asyncio.CancelledError):
    """Raised when a receipt observes a cancelled task."""


class UnknownTaskResultError(KeyError):
    """Raised when a result backend cannot find a requested task ID."""


class ResultBackend(Protocol):
    """Contract implemented by task result storage backends."""

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        ...

    def mark_running(self, task_id: str) -> None:
        ...

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        ...

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        ...

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        ...

    def mark_cancelled(self, task_id: str) -> None:
        ...

    def snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        ...

    async def wait_for_terminal_state(
        self,
        task_id: str,
        *,
        timeout_seconds: float,
    ) -> TaskResultSnapshot[Any]:
        ...


@dataclass(slots=True)
class _MutableTaskResult(Generic[ResultT]):
    """Internal mutable state managed by InMemoryResultStore."""

    task_id: str
    task_name: str
    state: TaskState
    submitted_at: datetime
    max_attempts: int
    attempt: int = 0
    started_at: datetime | None = None
    completed_at: datetime | None = None
    next_retry_at: datetime | None = None
    value: ResultT | None = None
    failure: TaskFailure | None = None


class TaskReceipt(Generic[ResultT]):
    """Caller-facing handle for observing one task."""

    __slots__ = ("_result_backend", "task_id", "task_name")

    def __init__(
        self,
        result_backend: ResultBackend,
        *,
        task_id: str,
        task_name: str,
    ) -> None:
        self._result_backend = result_backend
        self.task_id = task_id
        self.task_name = task_name

    async def result(self, *, timeout_seconds: float = 0.0) -> ResultT:
        """Wait for terminal task outcome and return or raise."""
        snapshot = await self._result_backend.wait_for_terminal_state(
            self.task_id,
            timeout_seconds=timeout_seconds,
        )

        if snapshot.state is TaskState.SUCCEEDED:
            return snapshot.value  # type: ignore[return-value]

        if snapshot.state is TaskState.FAILED:
            if snapshot.failure is None:
                raise RuntimeError(
                    f"Task {self.task_name!r} failed without failure details."
                )

            raise TaskFailureError(
                task_id=self.task_id,
                task_name=self.task_name,
                failure=snapshot.failure,
            )

        if snapshot.state is TaskState.CANCELLED:
            raise TaskCancelledError(
                f"Task {self.task_name!r} with id {self.task_id!r} was cancelled."
            )

        raise RuntimeError(
            f"Task {self.task_name!r} reached unexpected non-terminal state "
            f"{snapshot.state!r}."
        )

    def snapshot(self) -> TaskResultSnapshot[ResultT]:
        """Return current state without waiting."""
        return self._result_backend.snapshot(self.task_id)

    def __repr__(self) -> str:
        return (
            f"{type(self).__name__}("
            f"task_id={self.task_id!r}, "
            f"task_name={self.task_name!r}"
            f")"
        )


class InMemoryResultStore:
    """Process-local result backend for tests and local runtimes."""

    def __init__(self) -> None:
        self._results: dict[str, _MutableTaskResult[Any]] = {}
        self._completion_events: dict[str, asyncio.Event] = {}

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        """Create initial queued state."""
        if task_id in self._results:
            raise ValueError(f"Task result {task_id!r} already exists.")

        if max_attempts < 1:
            raise ValueError("max_attempts must be at least 1.")

        self._results[task_id] = _MutableTaskResult(
            task_id=task_id,
            task_name=task_name,
            state=TaskState.QUEUED,
            submitted_at=datetime.now(UTC),
            max_attempts=max_attempts,
        )
        self._completion_events[task_id] = asyncio.Event()

    def mark_running(self, task_id: str) -> None:
        """Start an attempt from queued or retrying state."""
        result = self._get_result(task_id)

        if result.state not in {TaskState.QUEUED, TaskState.RETRYING}:
            raise RuntimeError(
                f"Cannot mark task {task_id!r} running from {result.state!r}."
            )

        if result.attempt >= result.max_attempts:
            raise RuntimeError(
                f"Task {task_id!r} has exhausted its maximum attempt count."
            )

        result.state = TaskState.RUNNING
        result.attempt += 1
        result.started_at = datetime.now(UTC)
        result.next_retry_at = None

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Record retryable failure and retry timestamp."""
        if delay_seconds < 0:
            raise ValueError("delay_seconds must be zero or greater.")

        result = self._get_result(task_id)
        self._assert_running(result)

        if result.attempt >= result.max_attempts:
            raise RuntimeError(f"Task {task_id!r} has no attempts remaining.")

        result.state = TaskState.RETRYING
        result.failure = TaskFailure(
            exception_type=type(exception).__name__,
            message=str(exception),
        )
        result.next_retry_at = datetime.now(UTC) + timedelta(
            seconds=delay_seconds
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store terminal success and wake waiters."""
        result = self._get_result(task_id)
        self._assert_running(result)

        result.state = TaskState.SUCCEEDED
        result.value = value
        result.failure = None
        result.completed_at = datetime.now(UTC)
        result.next_retry_at = None
        self._completion_events[task_id].set()

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store terminal failure and wake waiters."""
        result = self._get_result(task_id)

        if result.state not in {TaskState.QUEUED, TaskState.RUNNING}:
            raise RuntimeError(
                f"Cannot fail task {task_id!r} from state {result.state!r}."
            )

        result.state = TaskState.FAILED
        result.failure = TaskFailure(
            exception_type=type(exception).__name__,
            message=str(exception),
        )
        result.completed_at = datetime.now(UTC)
        result.next_retry_at = None
        self._completion_events[task_id].set()

    def mark_cancelled(self, task_id: str) -> None:
        """Store terminal cancellation and wake waiters."""
        result = self._get_result(task_id)

        if result.state in TERMINAL_TASK_STATES:
            return

        if result.state not in {
            TaskState.QUEUED,
            TaskState.RUNNING,
            TaskState.RETRYING,
        }:
            raise RuntimeError(
                f"Cannot cancel task {task_id!r} from state {result.state!r}."
            )

        result.state = TaskState.CANCELLED
        result.completed_at = datetime.now(UTC)
        result.next_retry_at = None
        self._completion_events[task_id].set()

    def snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        """Return immutable current result state."""
        result = self._get_result(task_id)

        return TaskResultSnapshot(
            task_id=result.task_id,
            task_name=result.task_name,
            state=result.state,
            submitted_at=result.submitted_at,
            started_at=result.started_at,
            completed_at=result.completed_at,
            attempt=result.attempt,
            max_attempts=result.max_attempts,
            next_retry_at=result.next_retry_at,
            value=result.value,
            failure=result.failure,
        )

    async def wait_for_terminal_state(
        self,
        task_id: str,
        *,
        timeout_seconds: float,
    ) -> TaskResultSnapshot[Any]:
        """Wait for terminal state, optionally with a deadline."""
        if timeout_seconds < 0:
            raise ValueError("timeout_seconds must be zero or greater.")

        snapshot = self.snapshot(task_id)

        if snapshot.state in TERMINAL_TASK_STATES:
            return snapshot

        completion_event = self._get_event(task_id)

        if timeout_seconds == 0:
            await completion_event.wait()
        else:
            try:
                async with asyncio.timeout(timeout_seconds):
                    await completion_event.wait()
            except TimeoutError as error:
                raise TimeoutError(
                    f"Timed out waiting {timeout_seconds:.3f} second(s) for "
                    f"task {task_id!r}."
                ) from error

        return self.snapshot(task_id)

    def _get_result(self, task_id: str) -> _MutableTaskResult[Any]:
        try:
            return self._results[task_id]
        except KeyError as error:
            raise UnknownTaskResultError(
                f"No result record exists for task id {task_id!r}."
            ) from error

    def _get_event(self, task_id: str) -> asyncio.Event:
        try:
            return self._completion_events[task_id]
        except KeyError as error:
            raise UnknownTaskResultError(
                f"No completion event exists for task id {task_id!r}."
            ) from error

    @staticmethod
    def _assert_running(result: _MutableTaskResult[Any]) -> None:
        if result.state is not TaskState.RUNNING:
            raise RuntimeError(
                f"Cannot complete task {result.task_id!r} from state "
                f"{result.state!r}; expected {TaskState.RUNNING!r}."
            )
```

---

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
    """Lifecycle states of PulseQueueWorker."""

    CREATED = "created"
    RUNNING = "running"
    STOPPING = "stopping"
    STOPPED = "stopped"


@dataclass(frozen=True, slots=True)
class WorkerStats:
    """Stable worker activity snapshot."""

    state: WorkerState
    concurrency: int
    completed_tasks: int
    failed_tasks: int
    cancelled_tasks: int
    retry_attempts: int
    event_delivery_failures: int


class PulseQueueWorker:
    """Consume async and CPU task envelopes with plugins and retries."""

    def __init__(
        self,
        app: PulseQueue,
        broker: InMemoryBroker,
        *,
        concurrency: int = 1,
        cpu_processes: int | None = None,
        plugins: PluginRegistry | None = None,
    ) -> None:
        """Configure the worker without starting resources."""
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
        """Return lifecycle state."""
        return self._state

    @property
    def is_running(self) -> bool:
        """Return whether consumers are accepting broker messages."""
        return self._state is WorkerState.RUNNING

    @property
    def plugins(self) -> PluginRegistry | None:
        """Return worker plugin registry, if configured."""
        return self._plugins

    def stats(self) -> WorkerStats:
        """Return immutable worker statistics."""
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
        """Start plugins, CPU pool, then consumer loops."""
        if self._state is not WorkerState.CREATED:
            raise RuntimeError(
                f"Worker cannot start from state {self._state!r}; "
                f"expected {WorkerState.CREATED!r}."
            )

        if self._broker.is_closed:
            raise RuntimeError("Cannot start worker because broker is closed.")

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
        """Gracefully stop, then force cancellation after deadline if required."""
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

            if forced_shutdown:
                # Consumers were already gathered after cancellation.
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
        """Start worker resources on async context entry."""
        await self.start()
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Stop worker resources on async context exit."""
        await self.stop()

    async def _close_resources(self) -> None:
        """Close process pool, then stop plugins."""
        errors: list[BaseException] = []

        if self._cpu_pool.is_running:
            try:
                await self._cpu_pool.__aexit__(None, None, None)
            except BaseException as error:
                errors.append(error)

        if self._plugins is not None:
            try:
                await self._plugins.stop()
            except BaseException as error:
                errors.append(error)

        if len(errors) == 1:
            raise errors[0]

        if errors:
            raise BaseExceptionGroup(
                "One or more worker resources failed to close.",
                errors,
            )

    async def _force_stop(self) -> None:
        """Cancel active consumers and all still-queued envelopes."""
        for consumer_task in self._consumer_tasks:
            consumer_task.cancel()

        await asyncio.gather(*self._consumer_tasks, return_exceptions=True)

        self._cancelled_tasks += self._broker.cancel_pending()
        await self._broker.join()

    async def _consume_forever(self, worker_number: int) -> None:
        """Process broker items until receiving a stop signal."""
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
                # Exactly one task_done call for every broker get call.
                self._broker.task_done()

    async def _execute_envelope(self, envelope: TaskEnvelope) -> None:
        """Execute one task with retries, timeout, and event publication."""
        task = self._app.get_task(envelope.task_name)

        try:
            while True:
                self._broker.mark_running(envelope.task_id)

                await self._publish_event(
                    TaskEventType.STARTED,
                    self._result_snapshot(envelope.task_id),
                )

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
        """Route async tasks to event loop and CPU tasks to process pool."""
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
        """Publish a lifecycle event without changing task outcome on failure."""
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
            # Plugin faults are observable through worker statistics but must
            # not turn successful business tasks into failures.
            self._event_delivery_failures += 1

    def _result_snapshot(self, task_id: str) -> TaskResultSnapshot[object]:
        """Retrieve current result state through broker abstraction."""
        return self._broker.result_snapshot(task_id)
```

---

## Consolidated Verification for Section J.1

After applying these final files, run:

```bash
python -m compileall -q src
python -m pytest -q
```

Then run a minimal local task:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  examples.greet \
  --args '["Ada"]'
```

Expected JSON includes:

```json
{
  "result": "Hello, Ada.",
  "state": "succeeded",
  "task_name": "examples.greet"
}
```

---

[GENERATED: Appendix J, Section J.1 — Final Core Runtime Files]  
[STARTING: Appendix J, Section J.2 — Registry, Broker, Queue, Runtime, Plugins, and Configuration]

# Appendix J, Section J.2: Registry, Broker, Queue, Runtime, Plugins, and Configuration

This section contains the supporting operational files required by the core task and worker files from Section J.1.

---

## `src/pulsequeue/async_queue.py`

```python
"""Bounded in-memory asynchronous queue primitives."""

from __future__ import annotations

import asyncio
from collections.abc import Iterator
from dataclasses import dataclass
from typing import Generic, TypeVar

ItemT = TypeVar("ItemT")


class QueueClosedError(RuntimeError):
    """Raised when work is submitted after a queue begins closing."""


@dataclass(frozen=True, slots=True)
class QueueStats:
    """A point-in-time queue diagnostic snapshot."""

    max_size: int
    queued_items: int
    unfinished_tasks: int
    is_closed: bool


class _StopSignal:
    """Private sentinel used to stop one consumer loop."""

    __slots__ = ()


STOP_SIGNAL = _StopSignal()


class AsyncWorkQueue(Generic[ItemT]):
    """A bounded queue with backpressure and controlled shutdown."""

    def __init__(self, *, max_size: int) -> None:
        """Create a queue with a positive capacity."""
        if max_size < 1:
            raise ValueError("max_size must be at least 1.")

        self._queue: asyncio.Queue[ItemT | _StopSignal] = asyncio.Queue(
            maxsize=max_size
        )
        self._max_size = max_size
        self._is_closed = False

    @property
    def is_closed(self) -> bool:
        """Return whether new producer submissions are rejected."""
        return self._is_closed

    async def put(self, item: ItemT) -> None:
        """Submit an item, waiting for capacity if the queue is full."""
        if self._is_closed:
            raise QueueClosedError("Cannot submit work: queue is closed.")

        await self._queue.put(item)

    def put_nowait(self, item: ItemT) -> None:
        """Submit immediately or raise QueueFull when capacity is unavailable."""
        if self._is_closed:
            raise QueueClosedError("Cannot submit work: queue is closed.")

        self._queue.put_nowait(item)

    async def get(self) -> ItemT | _StopSignal:
        """Wait for and retrieve one work item or stop signal."""
        return await self._queue.get()

    def get_nowait(self) -> ItemT | _StopSignal:
        """Retrieve an item immediately or raise asyncio.QueueEmpty."""
        return self._queue.get_nowait()

    def task_done(self) -> None:
        """Mark one retrieved queue entry as fully handled."""
        self._queue.task_done()

    async def join(self) -> None:
        """Wait until every retrieved item has matching task_done() accounting."""
        await self._queue.join()

    def close(self) -> None:
        """Reject future work submissions without discarding queued work."""
        self._is_closed = True

    async def stop_consumers(self, *, consumer_count: int) -> None:
        """Close producers and enqueue exactly one stop signal per consumer."""
        if consumer_count < 1:
            raise ValueError("consumer_count must be at least 1.")

        self.close()

        for _ in range(consumer_count):
            # Waiting is deliberate: existing work remains ahead of shutdown
            # signals, allowing consumers to drain accepted messages first.
            await self._queue.put(STOP_SIGNAL)

    def drain_nowait(self) -> Iterator[ItemT | _StopSignal]:
        """Remove all currently queued items during forced shutdown.

        Every yielded item has been retrieved and therefore requires a matching
        task_done() call by the caller.
        """
        while True:
            try:
                yield self.get_nowait()
            except asyncio.QueueEmpty:
                return

    def stats(self) -> QueueStats:
        """Return current bounded-queue diagnostics.

        _unfinished_tasks is an asyncio.Queue implementation detail. It is
        used only for local diagnostics in this educational broker wrapper.
        """
        return QueueStats(
            max_size=self._max_size,
            queued_items=self._queue.qsize(),
            unfinished_tasks=self._queue._unfinished_tasks,
            is_closed=self._is_closed,
        )
```

---

## `src/pulsequeue/envelope.py`

```python
"""Immutable task messages passed from producers to workers."""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from datetime import datetime
from types import MappingProxyType
from typing import Any


@dataclass(frozen=True, slots=True)
class TaskEnvelope:
    """One immutable request to execute a named registered task."""

    task_id: str
    task_name: str
    args: tuple[Any, ...]
    kwargs: Mapping[str, Any]
    submitted_at: datetime

    @classmethod
    def create(
        cls,
        *,
        task_id: str,
        task_name: str,
        args: tuple[Any, ...],
        kwargs: Mapping[str, Any],
        submitted_at: datetime,
    ) -> TaskEnvelope:
        """Create an envelope with defensive copies of argument containers."""
        if not task_id:
            raise ValueError("task_id cannot be empty.")

        if not task_name:
            raise ValueError("task_name cannot be empty.")

        return cls(
            task_id=task_id,
            task_name=task_name,
            args=tuple(args),
            kwargs=MappingProxyType(dict(kwargs)),
            submitted_at=submitted_at,
        )
```

---

## `src/pulsequeue/broker.py`

```python
"""An in-memory task-envelope broker with pluggable result storage."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from pulsequeue.async_queue import STOP_SIGNAL, AsyncWorkQueue, QueueStats
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.result import (
    InMemoryResultStore,
    ResultBackend,
    TaskReceipt,
    TaskResultSnapshot,
)


class InMemoryBroker:
    """Process-local, non-durable broker for local runtimes and tests."""

    def __init__(
        self,
        *,
        max_queue_size: int = 1_000,
        result_backend: ResultBackend | None = None,
    ) -> None:
        """Create a bounded broker and result backend."""
        self._queue = AsyncWorkQueue[TaskEnvelope](max_size=max_queue_size)
        self._result_backend = (
            result_backend if result_backend is not None else InMemoryResultStore()
        )

    @property
    def is_closed(self) -> bool:
        """Return whether broker submissions are closed."""
        return self._queue.is_closed

    @property
    def result_backend(self) -> ResultBackend:
        """Return configured task result backend."""
        return self._result_backend

    def stats(self) -> QueueStats:
        """Return current queue diagnostics."""
        return self._queue.stats()

    def result_snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        """Return current task result state."""
        return self._result_backend.snapshot(task_id)

    async def submit(
        self,
        *,
        task_name: str,
        args: tuple[Any, ...],
        kwargs: dict[str, Any],
        max_retries: int = 0,
    ) -> TaskReceipt[Any]:
        """Create a task result, package its message, and enqueue it."""
        if max_retries < 0:
            raise ValueError("max_retries must be zero or greater.")

        task_id = str(uuid4())
        submitted_at = datetime.now(UTC)

        envelope = TaskEnvelope.create(
            task_id=task_id,
            task_name=task_name,
            args=args,
            kwargs=kwargs,
            submitted_at=submitted_at,
        )

        self._result_backend.create(
            task_id=task_id,
            task_name=task_name,
            max_attempts=1 + max_retries,
        )

        try:
            await self._queue.put(envelope)
        except BaseException as error:
            # A result record already exists. Mark it terminal so a caller
            # never waits forever if enqueue is cancelled or fails.
            self._result_backend.mark_failed(task_id, error)
            raise

        return TaskReceipt(
            self._result_backend,
            task_id=task_id,
            task_name=task_name,
        )

    async def get(self) -> TaskEnvelope | object:
        """Retrieve next envelope or internal consumer stop signal."""
        return await self._queue.get()

    def task_done(self) -> None:
        """Complete accounting for a retrieved queue item."""
        self._queue.task_done()

    async def join(self) -> None:
        """Wait until all accepted queue entries are handled."""
        await self._queue.join()

    async def stop_workers(self, *, worker_count: int) -> None:
        """Close submissions and request graceful consumer termination."""
        await self._queue.stop_consumers(consumer_count=worker_count)

    def cancel_pending(self) -> int:
        """Cancel all envelopes still queued during forced shutdown."""
        cancelled_count = 0

        for item in self._queue.drain_nowait():
            try:
                if isinstance(item, TaskEnvelope):
                    self._result_backend.mark_cancelled(item.task_id)
                    cancelled_count += 1
                elif item is not STOP_SIGNAL:
                    raise RuntimeError(
                        f"Broker encountered unexpected queued item {item!r}."
                    )
            finally:
                self._queue.task_done()

        return cancelled_count

    def mark_running(self, task_id: str) -> None:
        """Record start of one task attempt."""
        self._result_backend.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Record retry state for one task attempt."""
        self._result_backend.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Record terminal task success."""
        self._result_backend.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Record terminal task failure."""
        self._result_backend.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        """Record terminal task cancellation."""
        self._result_backend.mark_cancelled(task_id)
```

---

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
    """Raised when a stable task name is registered more than once."""


class UnknownTaskError(KeyError):
    """Raised when a requested stable task name is absent."""


class TaskRegistry:
    """Store async and CPU tasks by queue-qualified stable name."""

    def __init__(self) -> None:
        self._tasks: dict[str, RegisteredTask] = {}

    def register(self, task: RegisteredTask) -> RegisteredTask:
        """Register a task or reject duplicate names."""
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
        """Retrieve one task by stable name."""
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
        """Return immutable snapshot of registered tasks."""
        return MappingProxyType(self._tasks.copy())

    def __iter__(self) -> Iterator[RegisteredTask]:
        """Iterate tasks in stable task-name order."""
        for task_name in sorted(self._tasks):
            yield self._tasks[task_name]

    def __len__(self) -> int:
        """Return number of registered tasks."""
        return len(self._tasks)

    def namespace(self, *, name: str = "tasks") -> AttributeNamespace:
        """Build a nested read-only namespace from queue-qualified task names."""
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
        """Convert nested mapping tree to nested AttributeNamespace objects."""
        values: dict[str, Any] = {}

        for key, value in tree.items():
            if isinstance(value, dict):
                values[key] = cls._build_namespace(
                    value,
                    name=f"{name}.{key}",
                )
            else:
                values[key] = value

        return AttributeNamespace(values, name=name)
```

---

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
        """Return application name."""
        return self._name

    @property
    def tasks(self) -> AttributeNamespace:
        """Return read-only task namespace snapshot."""
        return self._registry.namespace(name=f"{self._name}.tasks")

    @property
    def task_count(self) -> int:
        """Return total registered async and CPU task definitions."""
        return len(self._registry)

    def registered_tasks(self) -> Mapping[str, RegisteredTask]:
        """Return immutable registry snapshot."""
        return self._registry.all()

    def get_task(self, name: str) -> RegisteredTask:
        """Look up a task by stable queue-qualified name."""
        return self._registry.get(name)

    async def submit(
        self,
        broker: InMemoryBroker,
        task_name: str,
        /,
        *args: Any,
        **kwargs: Any,
    ) -> TaskReceipt[Any]:
        """Validate a call and enqueue it through a broker."""
        task = self.get_task(task_name)

        # Catch invalid argument usage before it consumes broker capacity.
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
        """Return decorator registering one coroutine-based task."""
        self._validate_task_identity(queue=queue, name=name)

        def register_function(
            function: Callable[ParametersT, Awaitable[ResultT]],
        ) -> Task[ParametersT, ResultT]:
            """Create and register task metadata around coroutine function."""
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
        """Return decorator registering one process-executed CPU task."""
        self._validate_task_identity(queue=queue, name=name)

        def register_function(
            function: Callable[ParametersT, ResultT],
        ) -> CpuTask[ParametersT, ResultT]:
            """Create and register task metadata around CPU function."""
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
        """Validate decorator names used by registry and namespaces."""
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
        """Return JSON-friendly application and task metadata."""
        return {
            "name": self._name,
            "task_count": self.task_count,
            "tasks": {
                task_name: task.describe()
                for task_name, task in self.registered_tasks().items()
            },
        }

    def __repr__(self) -> str:
        """Return concise application representation."""
        return (
            f"{type(self).__name__}("
            f"name={self._name!r}, "
            f"task_count={self.task_count}"
            f")"
        )
```

---

## `src/pulsequeue/execution.py`

```python
"""Execution-model primitives for async, blocking, and CPU work."""

from __future__ import annotations

import asyncio
from collections.abc import Callable
from concurrent.futures import ProcessPoolExecutor
from enum import StrEnum
from functools import partial
from typing import ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class WorkloadKind(StrEnum):
    """Dominant workload categories."""

    ASYNC_IO = "async_io"
    BLOCKING_IO = "blocking_io"
    CPU_BOUND = "cpu_bound"


async def run_blocking_io(
    function: Callable[ParametersT, ResultT],
    /,
    *args: ParametersT.args,
    **kwargs: ParametersT.kwargs,
) -> ResultT:
    """Run a blocking I/O-oriented function in a worker thread."""
    return await asyncio.to_thread(function, *args, **kwargs)


async def run_cpu_bound(
    executor: ProcessPoolExecutor,
    function: Callable[ParametersT, ResultT],
    /,
    *args: ParametersT.args,
    **kwargs: ParametersT.kwargs,
) -> ResultT:
    """Run CPU-bound synchronous work in an already-started process pool."""
    event_loop = asyncio.get_running_loop()

    # run_in_executor accepts positional arguments only. partial preserves
    # keyword arguments while retaining an importable module-level function.
    callable_with_arguments = partial(function, *args, **kwargs)

    return await event_loop.run_in_executor(executor, callable_with_arguments)
```

---

## `src/pulsequeue/executors.py`

```python
"""Lifecycle-managed process executor resources."""

from __future__ import annotations

import asyncio
from concurrent.futures import ProcessPoolExecutor
from types import TracebackType
from typing import Self


class ProcessExecutorPool:
    """Own one reusable ProcessPoolExecutor across worker lifetime."""

    def __init__(self, *, max_workers: int | None = None) -> None:
        """Configure pool without spawning child processes yet."""
        if max_workers is not None and max_workers < 1:
            raise ValueError("max_workers must be at least 1 when provided.")

        self._max_workers = max_workers
        self._executor: ProcessPoolExecutor | None = None

    @property
    def executor(self) -> ProcessPoolExecutor:
        """Return started executor or explain lifecycle misuse."""
        if self._executor is None:
            raise RuntimeError(
                "Process executor is not running. Use "
                "'async with ProcessExecutorPool(...) as pool:' first."
            )

        return self._executor

    @property
    def is_running(self) -> bool:
        """Return whether child process executor exists."""
        return self._executor is not None

    async def __aenter__(self) -> Self:
        """Start the process executor."""
        if self._executor is not None:
            raise RuntimeError("Process executor pool is already running.")

        self._executor = ProcessPoolExecutor(max_workers=self._max_workers)
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Shut down processes outside event-loop thread."""
        executor = self._executor
        self._executor = None

        if executor is not None:
            await asyncio.to_thread(
                executor.shutdown,
                wait=True,
                cancel_futures=True,
            )
```

---

## `src/pulsequeue/timeouts.py`

```python
"""Timeout helpers for bounded asynchronous operations."""

from __future__ import annotations

import asyncio
from collections.abc import Awaitable
from typing import TypeVar

ResultT = TypeVar("ResultT")


class OperationTimeoutError(TimeoutError):
    """Raised when PulseQueue operation exceeds configured deadline."""


async def await_with_timeout(
    awaitable: Awaitable[ResultT],
    *,
    timeout_seconds: float,
    operation_name: str,
) -> ResultT:
    """Await work with validated deadline and framework-specific error."""
    if timeout_seconds < 0:
        raise ValueError("timeout_seconds must be zero or greater.")

    if not operation_name or not operation_name.strip():
        raise ValueError("operation_name cannot be empty.")

    if timeout_seconds == 0:
        return await awaitable

    try:
        async with asyncio.timeout(timeout_seconds):
            return await awaitable
    except TimeoutError as error:
        raise OperationTimeoutError(
            f"Operation {operation_name!r} exceeded its timeout of "
            f"{timeout_seconds:.3f} second(s)."
        ) from error
```

---

## `src/pulsequeue/config.py`

```python
"""Validated environment-based runtime configuration."""

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
    """Read a positive integer environment value."""
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
    """Read optional positive integer or use executor default when absent."""
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
    """Read a non-negative float environment value."""
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
    """Typed runtime settings loaded from deployment configuration."""

    worker_concurrency: int = 1
    broker_max_queue_size: int = 1_000
    cpu_processes: int | None = None
    shutdown_timeout_seconds: float = 30.0

    @classmethod
    def from_environment(
        cls,
        environment: Mapping[str, str] | None = None,
    ) -> PulseQueueSettings:
        """Create settings from PULSEQUEUE_* environment variables."""
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

---

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
    """Own broker, worker, plugins, result backend, and shutdown policy."""

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
        """Configure runtime without starting worker resources."""
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
        """Compose runtime from validated settings object."""
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
        """Return runtime application."""
        return self._app

    @property
    def broker(self) -> InMemoryBroker:
        """Return runtime-owned broker."""
        return self._broker

    @property
    def worker(self) -> PulseQueueWorker:
        """Return runtime-owned worker."""
        return self._worker

    @property
    def is_running(self) -> bool:
        """Return whether worker runtime is active."""
        return self._is_running

    async def start(self) -> None:
        """Start worker and its owned resources."""
        if self._is_running:
            raise RuntimeError("PulseQueueRuntime is already running.")

        await self._worker.start()
        self._is_running = True

    async def stop(self, *, timeout_seconds: float | None = None) -> None:
        """Stop worker using configured or caller-provided shutdown deadline."""
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
        """Submit a task into this runtime's broker."""
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
        """Start runtime on context entry."""
        await self.start()
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Stop runtime on context exit."""
        await self.stop()
```

---

## `src/pulsequeue/plugins.py`

```python
"""Plugin registration, lifecycle management, and event delivery."""

from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass
from enum import StrEnum
from types import MappingProxyType
from typing import Mapping

from pulsequeue.events import TaskEvent
from pulsequeue.typing import LifecyclePlugin


class PluginRegistryState(StrEnum):
    """Plugin registry lifecycle states."""

    CREATED = "created"
    STARTING = "starting"
    STARTED = "started"
    STOPPING = "stopping"
    STOPPED = "stopped"


class DuplicatePluginError(ValueError):
    """Raised for duplicate plugin names."""


class PluginLifecycleError(RuntimeError):
    """Raised for invalid plugin registry lifecycle transitions."""


@dataclass(frozen=True, slots=True)
class PluginRegistryStats:
    """Plugin registry diagnostic state."""

    state: PluginRegistryState
    registered_plugins: int
    started_plugins: int


class PluginRegistry:
    """Own plugins and safely manage startup, shutdown, and event publishing."""

    def __init__(self) -> None:
        self._plugins: dict[str, LifecyclePlugin] = {}
        self._started_plugins: list[LifecyclePlugin] = []
        self._state = PluginRegistryState.CREATED

    @property
    def state(self) -> PluginRegistryState:
        """Return registry lifecycle state."""
        return self._state

    def stats(self) -> PluginRegistryStats:
        """Return immutable registry statistics."""
        return PluginRegistryStats(
            state=self._state,
            registered_plugins=len(self._plugins),
            started_plugins=len(self._started_plugins),
        )

    def register(self, plugin: LifecyclePlugin) -> LifecyclePlugin:
        """Register structurally compatible plugin before startup."""
        if self._state is not PluginRegistryState.CREATED:
            raise PluginLifecycleError(
                "Plugins can be registered only while registry is created."
            )

        if not isinstance(plugin, LifecyclePlugin):
            raise TypeError(
                "Plugin must provide name, async start(), async stop(), and "
                "async on_event(event) methods."
            )

        if not plugin.name or not plugin.name.strip():
            raise ValueError("Plugin name cannot be empty.")

        if plugin.name in self._plugins:
            raise DuplicatePluginError(
                f"Plugin {plugin.name!r} is already registered."
            )

        self._plugins[plugin.name] = plugin
        return plugin

    def registered(self) -> Mapping[str, LifecyclePlugin]:
        """Return immutable registered-plugin snapshot."""
        return MappingProxyType(self._plugins.copy())

    async def start(self) -> None:
        """Start plugins in order and roll back started plugins on failure."""
        if self._state is not PluginRegistryState.CREATED:
            raise PluginLifecycleError(
                f"Cannot start registry from state {self._state!r}."
            )

        self._state = PluginRegistryState.STARTING
        current_plugin: LifecyclePlugin | None = None

        try:
            for current_plugin in self._plugins.values():
                await current_plugin.start()
                self._started_plugins.append(current_plugin)
        except Exception as error:
            await self._stop_started_plugins_safely()
            self._state = PluginRegistryState.STOPPED

            plugin_name = (
                current_plugin.name
                if current_plugin is not None
                else "<unknown>"
            )

            raise PluginLifecycleError(
                f"Plugin startup failed for {plugin_name!r}."
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
                f"Cannot stop registry from state {self._state!r}."
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
        """Deliver event to all started plugins in registration order."""
        if self._state is not PluginRegistryState.STARTED:
            raise PluginLifecycleError(
                "Cannot publish events until plugin registry is started."
            )

        for plugin in self._started_plugins:
            await plugin.on_event(event)

    async def _stop_started_plugins_safely(self) -> list[Exception]:
        """Stop all started plugins in reverse order and collect errors."""
        errors: list[Exception] = []

        while self._started_plugins:
            plugin = self._started_plugins.pop()

            try:
                await plugin.stop()
            except Exception as error:
                errors.append(error)

        return errors

    def __iter__(self) -> Iterator[LifecyclePlugin]:
        """Iterate plugins in registration order."""
        return iter(self._plugins.values())

    def __len__(self) -> int:
        """Return registered plugin count."""
        return len(self._plugins)
```

---

## `src/pulsequeue/builtin_plugins.py`

```python
"""Built-in event plugins for local development and tests."""

from __future__ import annotations

from collections.abc import Callable

from pulsequeue.events import TaskEvent


class ConsoleEventPlugin:
    """Emit readable task lifecycle events through a callable output sink."""

    def __init__(
        self,
        *,
        name: str = "console_events",
        output: Callable[[str], None] = print,
    ) -> None:
        """Configure console event plugin."""
        if not name or not name.strip():
            raise ValueError("Plugin name cannot be empty.")

        self.name = name
        self._output = output
        self._started = False

    async def start(self) -> None:
        """Enable event emission."""
        self._started = True

    async def stop(self) -> None:
        """Disable event emission."""
        self._started = False

    async def on_event(self, event: TaskEvent) -> None:
        """Render one lifecycle event."""
        if not self._started:
            raise RuntimeError("ConsoleEventPlugin received event before start().")

        self._output(
            f"[{event.occurred_at.isoformat()}] "
            f"{event.event_type.value} "
            f"task_id={event.task_id} "
            f"task_name={event.task_name} "
            f"attempt={event.attempt} "
            f"details={event.details_as_dict()}"
        )


class InMemoryEventPlugin:
    """Retain events for tests and short-lived diagnostics."""

    def __init__(self, *, name: str = "in_memory_events") -> None:
        """Create empty event collector."""
        if not name or not name.strip():
            raise ValueError("Plugin name cannot be empty.")

        self.name = name
        self.events: list[TaskEvent] = []
        self._started = False

    async def start(self) -> None:
        """Enable event collection."""
        self._started = True

    async def stop(self) -> None:
        """Stop collecting while retaining history for inspection."""
        self._started = False

    async def on_event(self, event: TaskEvent) -> None:
        """Store immutable task event."""
        if not self._started:
            raise RuntimeError("InMemoryEventPlugin received event before start().")

        self.events.append(event)
```

---

## Verification for Section J.2

Run:

```bash
python -m compileall -q src
python -m pytest -q
```

Then validate a full local async task flow:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  examples.greet \
  --args '["Grace"]'
```

Expected result includes:

```json
{
  "result": "Hello, Grace.",
  "state": "succeeded",
  "task_name": "examples.greet"
}
```

---

[GENERATED: Appendix J, Section J.2 — Registry, Broker, Queue, Runtime, Plugins, and Configuration]  
[STARTING: Appendix J, Section J.3 — Metaprogramming, Serialization, Operations, Diagnostics, and Build Files]

# Appendix J, Section J.3: Metaprogramming, Serialization, Operations, Diagnostics, and Build Files

This final source-listing section contains the remaining framework modules and root build files.

---

## `src/pulsequeue/model.py`

```python
"""Descriptor and metaclass primitives used by PulseQueue models."""

from __future__ import annotations

from collections.abc import Callable, Mapping
from types import MappingProxyType
from typing import Any


class Field:
    """A validating data descriptor for a declared model field."""

    def __init__(
        self,
        expected_type: type[Any],
        *,
        required: bool = True,
        validator: Callable[[Any], None] | None = None,
    ) -> None:
        """Configure expected type, required state, and optional validation."""
        self.expected_type = expected_type
        self.required = required
        self.validator = validator
        self.name: str | None = None
        self.storage_name: str | None = None

    def __set_name__(self, owner: type[Any], name: str) -> None:
        """Receive final field name during class creation."""
        self.name = name
        self.storage_name = f"_{owner.__name__}__field_{name}"

    def __get__(self, instance: object | None, owner: type[Any]) -> Any:
        """Return descriptor metadata from class or validated value from instance."""
        if instance is None:
            return self

        if self.name is None or self.storage_name is None:
            raise RuntimeError("Field accessed before __set_name__ completed.")

        try:
            return vars(instance)[self.storage_name]
        except KeyError as error:
            if self.required:
                raise AttributeError(
                    f"{owner.__name__}.{self.name} has not been assigned."
                ) from error

            return None

    def __set__(self, instance: object, value: Any) -> None:
        """Validate and store a field value."""
        if self.name is None or self.storage_name is None:
            raise RuntimeError("Field assigned before __set_name__ completed.")

        if value is None:
            if self.required:
                raise TypeError(f"{self.name} is required and cannot be None.")

            vars(instance)[self.storage_name] = None
            return

        if not isinstance(value, self.expected_type):
            raise TypeError(
                f"{self.name} must be a {self.expected_type.__name__}, not "
                f"a {type(value).__name__}."
            )

        if self.validator is not None:
            self.validator(value)

        vars(instance)[self.storage_name] = value


class ModelMeta(type):
    """Collect Field declarations and create a read-only field mapping."""

    def __new__(
        mcls,
        name: str,
        bases: tuple[type[Any], ...],
        namespace: dict[str, Any],
        **kwargs: Any,
    ) -> type[Model]:
        """Build class and combine inherited and declared fields."""
        inherited_fields: dict[str, Field] = {}

        for base in bases:
            inherited_fields.update(getattr(base, "__fields__", {}))

        declared_fields = {
            field_name: field
            for field_name, field in namespace.items()
            if isinstance(field, Field)
        }

        created_class = super().__new__(mcls, name, bases, namespace, **kwargs)
        created_class.__fields__ = MappingProxyType(
            {
                **inherited_fields,
                **declared_fields,
            }
        )

        return created_class


class Model(metaclass=ModelMeta):
    """Base object with declared descriptor-backed field validation."""

    __fields__: Mapping[str, Field]

    def __init__(self, **values: Any) -> None:
        """Assign declared fields while rejecting missing and unknown values."""
        unknown_fields = set(values) - set(self.__fields__)

        if unknown_fields:
            formatted = ", ".join(sorted(unknown_fields))
            raise TypeError(f"Unknown field(s): {formatted}")

        for field_name, field in self.__fields__.items():
            if field_name in values:
                setattr(self, field_name, values[field_name])
            elif field.required:
                raise TypeError(f"Missing required field: {field_name}")
            else:
                setattr(self, field_name, None)

    def as_dict(self) -> dict[str, Any]:
        """Return declared values as ordinary dictionary."""
        return {
            field_name: getattr(self, field_name)
            for field_name in self.__fields__
        }
```

---

## `src/pulsequeue/descriptors.py`

```python
"""Reusable descriptor helpers."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any, Generic, TypeVar, overload

InstanceT = TypeVar("InstanceT")
ValueT = TypeVar("ValueT")


class computed_property(Generic[InstanceT, ValueT]):
    """A minimal read-only descriptor similar to built-in property."""

    def __init__(self, getter: Callable[[InstanceT], ValueT]) -> None:
        """Store a getter used to calculate the attribute value."""
        self._getter = getter
        self._name = getter.__name__
        self.__doc__ = getter.__doc__

    def __set_name__(self, owner: type[Any], name: str) -> None:
        """Store final class attribute name."""
        self._name = name

    @overload
    def __get__(
        self,
        instance: None,
        owner: type[InstanceT],
    ) -> computed_property[InstanceT, ValueT]:
        ...

    @overload
    def __get__(
        self,
        instance: InstanceT,
        owner: type[InstanceT],
    ) -> ValueT:
        ...

    def __get__(
        self,
        instance: InstanceT | None,
        owner: type[InstanceT],
    ) -> computed_property[InstanceT, ValueT] | ValueT:
        """Return descriptor from class or derived value from instance."""
        if instance is None:
            return self

        return self._getter(instance)

    def __set__(self, instance: InstanceT, value: ValueT) -> None:
        """Prevent assignment to derived data."""
        raise AttributeError(
            f"{self._name} is a read-only computed attribute and cannot be assigned."
        )
```

---

## `src/pulsequeue/metadata.py`

```python
"""Controlled dynamic metadata for task definitions."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from types import MappingProxyType
from typing import Any


class MetadataField:
    """Describe one allowed metadata field."""

    __slots__ = ("expected_type", "required")

    def __init__(self, expected_type: type[Any], *, required: bool = False) -> None:
        self.expected_type = expected_type
        self.required = required


class TaskMetadata:
    """A schema-controlled attribute container for task metadata."""

    _schema: Mapping[str, MetadataField] = MappingProxyType(
        {
            "owner": MetadataField(str),
            "service": MetadataField(str),
            "environment": MetadataField(str),
            "priority": MetadataField(int),
            "trace_id": MetadataField(str),
        }
    )

    def __init__(self, **values: Any) -> None:
        """Initialize metadata through normal schema validation."""
        object.__setattr__(self, "_values", {})

        for name, value in values.items():
            setattr(self, name, value)

        self._validate_required_fields()

    def __getattr__(self, name: str) -> Any:
        """Resolve declared metadata fields from internal value mapping."""
        schema = type(self)._schema

        if name not in schema:
            allowed = ", ".join(sorted(schema))
            raise AttributeError(
                f"{type(self).__name__} does not support metadata field {name!r}. "
                f"Allowed fields: {allowed}."
            )

        values: dict[str, Any] = object.__getattribute__(self, "_values")

        if name not in values:
            raise AttributeError(f"Metadata field {name!r} has not been assigned.")

        return values[name]

    def __setattr__(self, name: str, value: Any) -> None:
        """Validate assignment to a declared metadata field."""
        if name.startswith("_"):
            object.__setattr__(self, name, value)
            return

        schema = type(self)._schema

        if name not in schema:
            allowed = ", ".join(sorted(schema))
            raise AttributeError(
                f"{type(self).__name__} does not support metadata field {name!r}. "
                f"Allowed fields: {allowed}."
            )

        field = schema[name]

        if not isinstance(value, field.expected_type):
            raise TypeError(
                f"Metadata field {name!r} must be a "
                f"{field.expected_type.__name__}, not {type(value).__name__}."
            )

        values: dict[str, Any] = object.__getattribute__(self, "_values")
        values[name] = value

    def _validate_required_fields(self) -> None:
        """Validate any schema fields marked required."""
        values: dict[str, Any] = object.__getattribute__(self, "_values")

        missing = [
            name
            for name, field in type(self)._schema.items()
            if field.required and name not in values
        ]

        if missing:
            raise TypeError(
                f"Missing required metadata field(s): {', '.join(sorted(missing))}"
            )

    def as_dict(self) -> dict[str, Any]:
        """Return defensive copy suitable for serialization."""
        values: dict[str, Any] = object.__getattribute__(self, "_values")
        return values.copy()

    def keys(self) -> Iterator[str]:
        """Iterate assigned metadata names."""
        values: dict[str, Any] = object.__getattribute__(self, "_values")
        return iter(values)

    def __repr__(self) -> str:
        """Return developer-friendly representation."""
        return f"{type(self).__name__}({self.as_dict()!r})"
```

---

## `src/pulsequeue/namespace.py`

```python
"""Read-only dynamic attribute namespaces."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from types import MappingProxyType
from typing import Any


class AttributeNamespace:
    """Expose valid mapping keys as immutable public attributes."""

    __slots__ = ("_values", "_name")

    def __init__(self, values: Mapping[str, Any], *, name: str = "namespace") -> None:
        """Validate and retain an immutable copy of values."""
        normalized: dict[str, Any] = {}

        for key, value in values.items():
            self._validate_key(key)
            normalized[key] = value

        object.__setattr__(self, "_values", MappingProxyType(normalized))
        object.__setattr__(self, "_name", name)

    @staticmethod
    def _validate_key(key: str) -> None:
        """Require keys safe for public Python attribute access."""
        if not key.isidentifier():
            raise ValueError(
                f"Namespace key {key!r} is not a valid Python identifier."
            )

        if key.startswith("_"):
            raise ValueError(
                f"Namespace key {key!r} cannot begin with an underscore."
            )

    def __getattr__(self, name: str) -> Any:
        """Resolve namespace member or raise helpful error."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")

        try:
            return values[name]
        except KeyError as error:
            namespace_name: str = object.__getattribute__(self, "_name")
            available = ", ".join(sorted(values)) or "<empty>"

            raise AttributeError(
                f"{namespace_name} has no member {name!r}. "
                f"Available members: {available}."
            ) from error

    def __setattr__(self, name: str, value: Any) -> None:
        """Reject mutation after construction."""
        raise AttributeError(
            f"{type(self).__name__} is immutable; cannot assign {name!r}."
        )

    def __dir__(self) -> list[str]:
        """Support shell and IDE completion for dynamic members."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return sorted(set(super().__dir__()) | set(values))

    def __iter__(self) -> Iterator[str]:
        """Iterate member names."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return iter(values)

    def __contains__(self, name: object) -> bool:
        """Return whether member exists."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return name in values

    def as_dict(self) -> dict[str, Any]:
        """Return mutable shallow copy."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return dict(values)

    def __repr__(self) -> str:
        """Return concise debug representation."""
        namespace_name: str = object.__getattribute__(self, "_name")
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")

        return (
            f"{type(self).__name__}("
            f"name={namespace_name!r}, "
            f"values={dict(values)!r}"
            f")"
        )
```

---

## `src/pulsequeue/events.py`

```python
"""Compact immutable task lifecycle event objects."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any


class TaskEventType(StrEnum):
    """Important task lifecycle transitions."""

    SUBMITTED = "task.submitted"
    STARTED = "task.started"
    RETRYING = "task.retrying"
    SUCCEEDED = "task.succeeded"
    FAILED = "task.failed"
    CANCELLED = "task.cancelled"


@dataclass(frozen=True, slots=True)
class TaskEvent:
    """Immutable, memory-conscious event passed to plugins."""

    event_type: TaskEventType
    task_id: str
    task_name: str
    occurred_at: datetime
    attempt: int
    details: tuple[tuple[str, str], ...] = ()

    @classmethod
    def create(
        cls,
        *,
        event_type: TaskEventType,
        task_id: str,
        task_name: str,
        attempt: int,
        details: dict[str, Any] | None = None,
    ) -> TaskEvent:
        """Create event and normalize details to immutable string pairs."""
        if not task_id:
            raise ValueError("task_id cannot be empty.")

        if not task_name:
            raise ValueError("task_name cannot be empty.")

        if attempt < 0:
            raise ValueError("attempt must be zero or greater.")

        normalized_details = tuple(
            sorted(
                (str(key), str(value))
                for key, value in (details or {}).items()
            )
        )

        return cls(
            event_type=event_type,
            task_id=task_id,
            task_name=task_name,
            occurred_at=datetime.now(UTC),
            attempt=attempt,
            details=normalized_details,
        )

    def details_as_dict(self) -> dict[str, str]:
        """Return mutable mapping suitable for logs and JSON."""
        return dict(self.details)
```

---

## `src/pulsequeue/typing.py`

```python
"""Protocol and generic contracts for framework extensions."""

from __future__ import annotations

from typing import Protocol, TypeVar, runtime_checkable

from pulsequeue.events import TaskEvent

InputT = TypeVar("InputT")
OutputT = TypeVar("OutputT")


@runtime_checkable
class EventSink(Protocol):
    """A synchronous consumer of lifecycle events."""

    def emit(self, event: TaskEvent) -> None:
        """Consume an event."""
        ...


class ResultTransformer(Protocol[InputT, OutputT]):
    """Transform one input type into another output type."""

    def transform(self, value: InputT) -> OutputT:
        """Transform supplied value."""
        ...


@runtime_checkable
class LifecyclePlugin(Protocol):
    """Asynchronous plugin lifecycle contract."""

    name: str

    async def start(self) -> None:
        """Acquire plugin resources."""
        ...

    async def stop(self) -> None:
        """Release plugin resources."""
        ...

    async def on_event(self, event: TaskEvent) -> None:
        """Observe task lifecycle event."""
        ...
```

---

## `src/pulsequeue/serialization.py`

```python
"""Safe JSON serialization for task envelopes."""

from __future__ import annotations

import json
import math
from collections.abc import Mapping
from datetime import UTC, datetime
from typing import Any, TypeAlias

from pulsequeue.envelope import TaskEnvelope


class TaskSerializationError(ValueError):
    """Raised for non-JSON-safe task data or malformed task messages."""


JsonScalar: TypeAlias = None | bool | int | float | str
JsonValue: TypeAlias = JsonScalar | list["JsonValue"] | dict[str, "JsonValue"]


def ensure_json_value(value: Any, *, path: str = "$") -> JsonValue:
    """Validate and recursively normalize JSON-compatible values."""
    if value is None or isinstance(value, (bool, int, str)):
        return value

    if isinstance(value, float):
        if not math.isfinite(value):
            raise TaskSerializationError(
                f"Value at {path} must be a finite float, not {value!r}."
            )

        return value

    if isinstance(value, (list, tuple)):
        return [
            ensure_json_value(item, path=f"{path}[{index}]")
            for index, item in enumerate(value)
        ]

    if isinstance(value, Mapping):
        normalized: dict[str, JsonValue] = {}

        for key, item in value.items():
            if not isinstance(key, str):
                raise TaskSerializationError(
                    f"Mapping key at {path} must be str, not {type(key).__name__}."
                )

            normalized[key] = ensure_json_value(
                item,
                path=f"{path}.{key}",
            )

        return normalized

    raise TaskSerializationError(
        f"Value at {path} has unsupported type {type(value).__name__}. "
        "Task arguments must use JSON-compatible values."
    )


def envelope_to_json(envelope: TaskEnvelope) -> str:
    """Serialize task envelope to compact canonical JSON."""
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
    """Deserialize validated JSON text into immutable task envelope."""
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
        raise TaskSerializationError(
            "Task message must contain exactly expected keys. "
            f"Missing: {sorted(expected_keys - actual_keys)}; "
            f"extra: {sorted(actual_keys - expected_keys)}."
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
        raise RuntimeError(
            "Validated kwargs unexpectedly did not remain a dictionary."
        )

    return TaskEnvelope.create(
        task_id=task_id,
        task_name=task_name,
        args=tuple(normalized_args),
        kwargs=normalized_kwargs,
        submitted_at=submitted_at,
    )
```

---

## `src/pulsequeue/result_backends.py`

```python
"""Composable result backend decorators."""

from __future__ import annotations

from collections import Counter
from collections.abc import Mapping
from types import MappingProxyType
from typing import Any

from pulsequeue.result import ResultBackend, TaskResultSnapshot


class CountingResultBackend:
    """Count backend lifecycle transitions while delegating real storage."""

    def __init__(self, backend: ResultBackend) -> None:
        self._backend = backend
        self._transition_counts: Counter[str] = Counter()

    def transition_counts(self) -> Mapping[str, int]:
        """Return immutable transition-count snapshot."""
        return MappingProxyType(dict(self._transition_counts))

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        self._transition_counts["created"] += 1
        self._backend.create(
            task_id=task_id,
            task_name=task_name,
            max_attempts=max_attempts,
        )

    def mark_running(self, task_id: str) -> None:
        self._transition_counts["running"] += 1
        self._backend.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        self._transition_counts["retrying"] += 1
        self._backend.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        self._transition_counts["succeeded"] += 1
        self._backend.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        self._transition_counts["failed"] += 1
        self._backend.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        self._transition_counts["cancelled"] += 1
        self._backend.mark_cancelled(task_id)

    def snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        return self._backend.snapshot(task_id)

    async def wait_for_terminal_state(
        self,
        task_id: str,
        *,
        timeout_seconds: float,
    ) -> TaskResultSnapshot[Any]:
        return await self._backend.wait_for_terminal_state(
            task_id,
            timeout_seconds=timeout_seconds,
        )
```

---

## `src/pulsequeue/health.py`

```python
"""Serializable local runtime health diagnostics."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any

from pulsequeue.runtime import PulseQueueRuntime


@dataclass(frozen=True, slots=True)
class RuntimeHealth:
    """Point-in-time runtime health state."""

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
        """Return whether runtime and worker are actively operational."""
        return self.runtime_running and self.worker_state == "running"

    def as_dict(self) -> dict[str, Any]:
        """Return JSON-compatible health mapping."""
        result = asdict(self)
        result["is_healthy"] = self.is_healthy
        return result


def runtime_health(runtime: PulseQueueRuntime) -> RuntimeHealth:
    """Build health snapshot without mutating runtime state."""
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

---

## `src/pulsequeue/logging.py`

```python
"""Structured logging configuration for PulseQueue."""

from __future__ import annotations

import json
import logging
import sys
from datetime import UTC, datetime
from typing import Any


class JsonLogFormatter(logging.Formatter):
    """Render log records as JSON objects, one object per line."""

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
        """Convert standard logging record plus extras to safe JSON."""
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
    """Configure dedicated PulseQueue logger hierarchy."""
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
            logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")
        )

    logger = logging.getLogger("pulsequeue")
    logger.handlers.clear()
    logger.addHandler(handler)
    logger.setLevel(numeric_level)
    logger.propagate = False
```

---

## `src/pulsequeue/loader.py`

```python
"""Deployment-friendly PulseQueue application loading."""

from __future__ import annotations

import importlib

from pulsequeue.app import PulseQueue


class ApplicationLoadError(RuntimeError):
    """Raised when a configured application import path cannot be resolved."""


def load_application(import_path: str) -> PulseQueue:
    """Load PulseQueue instance using 'package.module:attribute' syntax."""
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

---

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
    """Build PulseQueue command-line parser."""
    parser = argparse.ArgumentParser(
        prog="pulsequeue",
        description="Operational commands for PulseQueue applications.",
    )

    parser.add_argument(
        "--app",
        default=os.environ.get("PULSEQUEUE_APP"),
        help=(
            "Application path in package.module:attribute format. "
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
        help="Use human-readable logs instead of JSON.",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser(
        "inspect",
        help="Print registered task metadata as JSON.",
    )
    subparsers.add_parser(
        "check-config",
        help="Validate environment configuration.",
    )

    run_parser = subparsers.add_parser(
        "run",
        help="Run a signal-aware local worker process.",
    )
    run_parser.add_argument(
        "--shutdown-timeout",
        type=float,
        default=None,
        help="Override configured graceful shutdown timeout.",
    )

    submit_parser = subparsers.add_parser(
        "submit-local",
        help="Execute one task in a temporary process-local runtime.",
    )
    submit_parser.add_argument("task_name")
    submit_parser.add_argument("--args", default="[]")
    submit_parser.add_argument("--kwargs", default="{}")
    submit_parser.add_argument(
        "--result-timeout",
        type=float,
        default=30.0,
    )

    return parser


def _require_app_import_path(parsed: argparse.Namespace) -> str:
    """Return configured application path or raise user-facing error."""
    if not parsed.app:
        raise ApplicationLoadError(
            "No application configured. Pass --app package.module:attribute "
            "or set PULSEQUEUE_APP."
        )

    return parsed.app


def _parse_json_arguments(
    raw_args: str,
    raw_kwargs: str,
) -> tuple[list[Any], dict[str, Any]]:
    """Parse and validate JSON command-line task arguments."""
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
    """Request cooperative shutdown in response to SIGINT or SIGTERM."""
    event_loop = asyncio.get_running_loop()

    def request_shutdown(signal_name: str) -> None:
        """Set shutdown event once."""
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
            # Windows and non-main-thread event loops do not always support
            # add_signal_handler. signal.signal covers CLI process behavior.
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
    """Run local worker until operating-system termination signal arrives."""
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
    """Start temporary runtime, execute task, and print JSON outcome."""
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
    """Run CLI and return process exit code."""
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

---

## `src/pulsequeue/memory.py`

```python
"""Garbage-collection diagnostics."""

from __future__ import annotations

import gc
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class GarbageCollectionStats:
    """Serializable cyclic-garbage-collector statistics."""

    generation_zero_count: int
    generation_one_count: int
    generation_two_count: int
    generation_zero_collections: int
    generation_one_collections: int
    generation_two_collections: int
    generation_zero_collected: int
    generation_one_collected: int
    generation_two_collected: int


def garbage_collection_stats() -> GarbageCollectionStats:
    """Return current CPython garbage collector snapshot."""
    counts = gc.get_count()
    generation_stats = gc.get_stats()

    return GarbageCollectionStats(
        generation_zero_count=counts[0],
        generation_one_count=counts[1],
        generation_two_count=counts[2],
        generation_zero_collections=generation_stats[0]["collections"],
        generation_one_collections=generation_stats[1]["collections"],
        generation_two_collections=generation_stats[2]["collections"],
        generation_zero_collected=generation_stats[0]["collected"],
        generation_one_collected=generation_stats[1]["collected"],
        generation_two_collected=generation_stats[2]["collected"],
    )


def collect_cycles() -> int:
    """Run complete cyclic garbage-collection pass."""
    return gc.collect()
```

---

## `src/pulsequeue/memory_profiler.py`

```python
"""Repeatable tracemalloc allocation-growth diagnostics."""

from __future__ import annotations

import gc
import tracemalloc
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class AllocationDifference:
    """One allocation source difference between snapshots."""

    filename: str
    line_number: int
    size_difference_bytes: int
    count_difference: int
    source_line: str


@dataclass(frozen=True, slots=True)
class MemoryComparison:
    """Comparison result between tracing baseline and current allocation state."""

    current_bytes: int
    peak_bytes: int
    largest_differences: tuple[AllocationDifference, ...]


class MemorySnapshotSession:
    """Own one tracemalloc session and baseline snapshot."""

    def __init__(self, *, traceback_limit: int = 10) -> None:
        if traceback_limit < 1:
            raise ValueError("traceback_limit must be at least 1.")

        self._traceback_limit = traceback_limit
        self._baseline: tracemalloc.Snapshot | None = None
        self._is_running = False

    def start(self) -> None:
        """Collect ordinary garbage, start tracing, and capture baseline."""
        if self._is_running:
            raise RuntimeError("Memory tracing is already running.")

        gc.collect()
        tracemalloc.start(self._traceback_limit)
        self._baseline = tracemalloc.take_snapshot()
        self._is_running = True

    def compare(self, *, limit: int = 10) -> MemoryComparison:
        """Compare current allocations against baseline."""
        if not self._is_running or self._baseline is None:
            raise RuntimeError("Call start() before compare().")

        if limit < 1:
            raise ValueError("limit must be at least 1.")

        current_snapshot = tracemalloc.take_snapshot()
        differences = current_snapshot.compare_to(
            self._baseline,
            key_type="lineno",
        )

        largest_differences: list[AllocationDifference] = []

        for difference in differences[:limit]:
            frame = difference.traceback[0]

            largest_differences.append(
                AllocationDifference(
                    filename=frame.filename,
                    line_number=frame.lineno,
                    size_difference_bytes=difference.size_diff,
                    count_difference=difference.count_diff,
                    source_line=frame.line.strip() if frame.line else "",
                )
            )

        current_bytes, peak_bytes = tracemalloc.get_traced_memory()

        return MemoryComparison(
            current_bytes=current_bytes,
            peak_bytes=peak_bytes,
            largest_differences=tuple(largest_differences),
        )

    def stop(self) -> None:
        """Stop tracing and release baseline references."""
        if not self._is_running:
            return

        tracemalloc.stop()
        self._baseline = None
        self._is_running = False
```

---

## `src/pulsequeue/retention.py`

```python
"""Bounded retention utilities for long-running services."""

from __future__ import annotations

from collections import OrderedDict
from collections.abc import Iterator
from typing import Generic, TypeVar

KeyT = TypeVar("KeyT")
ValueT = TypeVar("ValueT")


class BoundedRetentionStore(Generic[KeyT, ValueT]):
    """Keep newest values only, evicting oldest values beyond capacity."""

    def __init__(self, *, max_entries: int) -> None:
        if max_entries < 1:
            raise ValueError("max_entries must be at least 1.")

        self._max_entries = max_entries
        self._values: OrderedDict[KeyT, ValueT] = OrderedDict()

    @property
    def max_entries(self) -> int:
        """Return configured retention capacity."""
        return self._max_entries

    def put(self, key: KeyT, value: ValueT) -> None:
        """Insert or refresh value, evicting oldest entries as needed."""
        self._values.pop(key, None)
        self._values[key] = value

        while len(self._values) > self._max_entries:
            self._values.popitem(last=False)

    def get(self, key: KeyT) -> ValueT:
        """Return retained value or raise KeyError."""
        return self._values[key]

    def discard(self, key: KeyT) -> None:
        """Remove key if it exists."""
        self._values.pop(key, None)

    def __contains__(self, key: object) -> bool:
        return key in self._values

    def __len__(self) -> int:
        return len(self._values)

    def keys(self) -> Iterator[KeyT]:
        """Iterate retained keys from oldest to newest."""
        return iter(self._values)
```

---

## `src/pulsequeue/observers.py`

```python
"""Weak-reference observer registration."""

from __future__ import annotations

import weakref
from collections.abc import Callable
from typing import Any


class TaskObserverRegistry:
    """Notify callbacks without retaining bound-method owners forever."""

    def __init__(self) -> None:
        self._bound_methods: list[weakref.WeakMethod[Any]] = []
        self._functions: list[Callable[[str], None]] = []

    def add(self, observer: Callable[[str], None]) -> None:
        """Register function strongly or bound method weakly."""
        if getattr(observer, "__self__", None) is not None:
            self._bound_methods.append(weakref.WeakMethod(observer))
        else:
            self._functions.append(observer)

    def notify(self, event_name: str) -> None:
        """Notify live observers and prune dead weak method references."""
        for function in tuple(self._functions):
            function(event_name)

        live_methods: list[weakref.WeakMethod[Any]] = []

        for method_reference in self._bound_methods:
            method = method_reference()

            if method is None:
                continue

            method(event_name)
            live_methods.append(method_reference)

        self._bound_methods = live_methods

    @property
    def observer_count(self) -> int:
        """Return current live observer count."""
        return len(self._functions) + sum(
            reference() is not None
            for reference in self._bound_methods
        )
```

---

## `src/pulsequeue/transformers.py`

```python
"""Generic data transformers."""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Generic, TypeVar

from pulsequeue.events import TaskEvent
from pulsequeue.result import TaskResultSnapshot
from pulsequeue.typing import ResultTransformer

InputT = TypeVar("InputT")
OutputT = TypeVar("OutputT")


class IdentityTransformer(Generic[InputT]):
    """Return input without changing its type."""

    def transform(self, value: InputT) -> InputT:
        return value


class TaskEventDictionaryTransformer:
    """Transform immutable task event into JSON-friendly mapping."""

    def transform(self, value: TaskEvent) -> dict[str, Any]:
        return {
            "event_type": value.event_type.value,
            "task_id": value.task_id,
            "task_name": value.task_name,
            "occurred_at": value.occurred_at.isoformat(),
            "attempt": value.attempt,
            "details": value.details_as_dict(),
        }


class TaskResultDictionaryTransformer:
    """Transform task result snapshot into JSON-friendly mapping."""

    def transform(self, value: TaskResultSnapshot[Any]) -> dict[str, Any]:
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
            "failure": asdict(value.failure) if value.failure else None,
        }


def apply_transformer(
    transformer: ResultTransformer[InputT, OutputT],
    value: InputT,
) -> OutputT:
    """Apply structurally compatible transformer."""
    return transformer.transform(value)
```

---

## `src/pulsequeue/lifecycle.py`

```python
"""Small cancellation-safe async resource lifecycle examples."""

from __future__ import annotations

import asyncio
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager


class ResourceStateError(RuntimeError):
    """Raised when a resource is used from invalid lifecycle state."""


class AsyncResource:
    """A simple resource demonstrating async context-managed cleanup."""

    def __init__(self, name: str) -> None:
        if not name or not name.strip():
            raise ValueError("Resource name cannot be empty.")

        self._name = name
        self._is_open = False

    @property
    def name(self) -> str:
        return self._name

    @property
    def is_open(self) -> bool:
        return self._is_open

    async def open(self) -> None:
        """Open resource exactly once."""
        if self._is_open:
            raise ResourceStateError(f"Resource {self._name!r} is already open.")

        await asyncio.sleep(0)
        self._is_open = True

    async def close(self) -> None:
        """Close resource; duplicate close is harmless."""
        if not self._is_open:
            return

        try:
            await asyncio.sleep(0)
        finally:
            self._is_open = False

    @asynccontextmanager
    async def session(self) -> AsyncIterator[AsyncResource]:
        """Open resource for one scoped operation and guarantee close."""
        await self.open()

        try:
            yield self
        finally:
            await self.close()
```

---

## `src/pulsequeue/native/native_module.c`

```c
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <limits.h>


static PyObject *
fast_sum(PyObject *self, PyObject *args)
{
    PyObject *iterable;
    PyObject *iterator;
    PyObject *item;
    long long total = 0;

    if (!PyArg_ParseTuple(args, "O:fast_sum", &iterable)) {
        return NULL;
    }

    /*
     * PyObject_GetIter returns a new reference. This function owns it until
     * Py_DECREF(iterator) is called below.
     */
    iterator = PyObject_GetIter(iterable);

    if (iterator == NULL) {
        return NULL;
    }

    /*
     * PyIter_Next returns a new reference to each item. NULL means either
     * normal iterator exhaustion or an error, checked after the loop.
     */
    while ((item = PyIter_Next(iterator)) != NULL) {
        long long value = PyLong_AsLongLong(item);

        Py_DECREF(item);

        if (value == -1 && PyErr_Occurred()) {
            Py_DECREF(iterator);
            return NULL;
        }

        if (
            (value > 0 && total > LLONG_MAX - value) ||
            (value < 0 && total < LLONG_MIN - value)
        ) {
            Py_DECREF(iterator);
            PyErr_SetString(
                PyExc_OverflowError,
                "sum exceeds signed 64-bit integer range"
            );
            return NULL;
        }

        total += value;
    }

    Py_DECREF(iterator);

    if (PyErr_Occurred()) {
        return NULL;
    }

    /*
     * PyLong_FromLongLong returns a new reference. Returning it transfers
     * ownership to the Python interpreter.
     */
    return PyLong_FromLongLong(total);
}


static PyMethodDef native_methods[] = {
    {
        "fast_sum",
        fast_sum,
        METH_VARARGS,
        PyDoc_STR(
            "fast_sum(iterable, /)\n--\n\n"
            "Return signed 64-bit sum of iterable integer values."
        )
    },
    {NULL, NULL, 0, NULL}
};


static struct PyModuleDef native_module = {
    PyModuleDef_HEAD_INIT,
    "_native",
    "Optional native helpers for PulseQueue.",
    -1,
    native_methods
};


PyMODINIT_FUNC
PyInit__native(void)
{
    return PyModule_Create(&native_module);
}
```

---

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

[tool.mypy]
python_version = "3.12"
strict = true
warn_unused_configs = true
warn_return_any = true
warn_unreachable = true
disallow_any_generics = true
disallow_subclassing_any = true
no_implicit_reexport = true
```

---

## `setup.py`

```python
"""Setuptools extension configuration for optional PulseQueue native helpers."""

from __future__ import annotations

from setuptools import Extension, setup


setup(
    ext_modules=[
        Extension(
            name="pulsequeue._native",
            sources=["src/pulsequeue/native/native_module.c"],
        )
    ]
)
```

---

## `examples/worker_application.py`

```python
"""CLI-loadable example PulseQueue application."""

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
    """Return a synchronous CPU-bound demonstration result."""
    return value * value
```

---

## `Dockerfile`

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN apt-get update \
    && apt-get install --yes --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml setup.py ./
COPY src ./src
COPY examples ./examples

RUN python -m pip install --upgrade pip \
    && python -m pip install .

RUN useradd --create-home --uid 10001 pulsequeue
USER pulsequeue

ENV PULSEQUEUE_APP=examples.worker_application:app
ENV PULSEQUEUE_LOG_LEVEL=INFO
ENV PULSEQUEUE_WORKER_CONCURRENCY=2
ENV PULSEQUEUE_CPU_PROCESSES=2
ENV PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS=20

CMD ["pulsequeue", "run"]
```

---

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

---

# Final Verification

From the project root, install and validate the consolidated project:

```bash
python -m pip install --editable .
python -m compileall -q src
python -m pytest -q
```

Validate CLI configuration:

```bash
pulsequeue check-config
```

Inspect registered tasks:

```bash
pulsequeue --app examples.worker_application:app inspect
```

Run an async task locally:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  examples.greet \
  --args '["Ada"]'
```

Run a CPU task locally:

```bash
pulsequeue --app examples.worker_application:app submit-local \
  analytics.square \
  --args '[12]'
```

Expected CPU result:

```json
{
  "result": 144,
  "state": "succeeded",
  "task_name": "analytics.square"
}
```

---
