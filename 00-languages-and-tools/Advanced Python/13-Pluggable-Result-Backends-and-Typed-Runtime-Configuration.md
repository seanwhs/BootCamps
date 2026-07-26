# Part 13: Pluggable Result Backends and Typed Runtime Configuration

Our framework currently stores task results directly inside `InMemoryBroker`.

That works for local development, but it mixes two responsibilities:

```text
Broker responsibility:
- accept and deliver task messages

Result backend responsibility:
- record state transitions
- store results
- notify receipt holders
```

A production system may use different result-storage mechanisms:

| Environment | Possible result backend |
|---|---|
| Unit tests | In-memory store |
| Local development | In-memory store |
| Single-server deployment | SQLite or PostgreSQL |
| Distributed deployment | Redis, PostgreSQL, object storage, or a dedicated service |

We will now introduce a protocol-driven result backend boundary and typed environment configuration.

The final runtime construction will support this pattern:

```python
settings = PulseQueueSettings.from_environment()

async with PulseQueueRuntime.from_settings(
    app,
    settings,
    plugins=plugins,
) as runtime:
    receipt = await runtime.submit("emails.send_welcome_email", 42)
    result = await receipt.result()
```

---

## Step 1: Define a Result Backend Protocol

### The Target

Create a `ResultBackend` protocol that describes the operations required by:

- `TaskReceipt`;
- `InMemoryBroker`;
- future durable result backends.

### The Concept

A result backend is like a package-tracking database.

The broker and worker do not need to know whether tracking information is held in:

- memory;
- Redis;
- PostgreSQL;
- a remote API.

They only need a common set of operations:

```text
Create result record
Mark task running
Mark task retrying
Mark task succeeded
Mark task failed
Mark task cancelled
Read snapshot
Wait for terminal state
```

This is structural subtyping again. A future PostgreSQL backend does not need to inherit from an internal class. It only needs to provide the required methods.

### The Implementation

Replace the complete result module.

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
    """Represent the lifecycle state of one submitted task."""

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
    """A serializable summary of a task execution failure."""

    exception_type: str
    message: str


@dataclass(frozen=True, slots=True)
class TaskResultSnapshot(Generic[ResultT]):
    """An immutable point-in-time view of one submitted task."""

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
    """Raised when a caller requests the result of a failed task."""

    def __init__(self, *, task_id: str, task_name: str, failure: TaskFailure) -> None:
        super().__init__(
            f"Task {task_name!r} with id {task_id!r} failed with "
            f"{failure.exception_type}: {failure.message}"
        )
        self.task_id = task_id
        self.task_name = task_name
        self.failure = failure


class TaskCancelledError(asyncio.CancelledError):
    """Raised when a caller requests the result of a cancelled task."""


class UnknownTaskResultError(KeyError):
    """Raised when a task result is unavailable from its configured backend."""


class ResultBackend(Protocol):
    """Contract implemented by task-result storage backends.

    A backend owns state transitions and completion notifications. It may be
    local memory, a database, a distributed cache, or a remote service.
    """

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        """Create the initial queued result record."""
        ...

    def mark_running(self, task_id: str) -> None:
        """Transition queued or retrying work into an active attempt."""
        ...

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Record a retryable failure."""
        ...

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store a successful terminal result."""
        ...

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store a failed terminal result."""
        ...

    def mark_cancelled(self, task_id: str) -> None:
        """Store a cancelled terminal result."""
        ...

    def snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        """Return the latest immutable result state."""
        ...

    async def wait_for_terminal_state(
        self,
        task_id: str,
        *,
        timeout_seconds: float,
    ) -> TaskResultSnapshot[Any]:
        """Wait for a terminal state and return its snapshot."""
        ...


@dataclass(slots=True)
class _MutableTaskResult(Generic[ResultT]):
    """Internal mutable state owned only by InMemoryResultStore."""

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
    """A caller-facing handle for observing one submitted task."""

    __slots__ = ("_result_backend", "task_id", "task_name")

    def __init__(
        self,
        result_backend: ResultBackend,
        *,
        task_id: str,
        task_name: str,
    ) -> None:
        """Associate a receipt with one result backend and task identifier."""
        self._result_backend = result_backend
        self.task_id = task_id
        self.task_name = task_name

    async def result(self, *, timeout_seconds: float = 0.0) -> ResultT:
        """Wait for a terminal task state and return or raise accordingly."""
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
            f"Task {self.task_name!r} reached non-terminal state "
            f"{snapshot.state!r} unexpectedly."
        )

    def snapshot(self) -> TaskResultSnapshot[ResultT]:
        """Return the current task state without waiting."""
        return self._result_backend.snapshot(self.task_id)

    def __repr__(self) -> str:
        """Return a concise receipt representation."""
        return (
            f"{type(self).__name__}("
            f"task_id={self.task_id!r}, "
            f"task_name={self.task_name!r}"
            f")"
        )


class InMemoryResultStore:
    """Process-local result backend for tests and single-process runtimes."""

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
        """Create an initial queued result record."""
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
                f"Cannot mark task {task_id!r} running from state {result.state!r}."
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
        """Record a retryable failure and its next retry timestamp."""
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
        """Store successful terminal state and wake receipt waiters."""
        result = self._get_result(task_id)
        self._assert_running(result)

        result.state = TaskState.SUCCEEDED
        result.value = value
        result.failure = None
        result.completed_at = datetime.now(UTC)
        result.next_retry_at = None
        self._completion_events[task_id].set()

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store failed terminal state and wake receipt waiters."""
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
        """Store cancelled terminal state and wake receipt waiters."""
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
        """Return an immutable copy of current result state."""
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
        """Wait for completion, optionally with a deadline."""
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
        """Return mutable backend state or a meaningful lookup error."""
        try:
            return self._results[task_id]
        except KeyError as error:
            raise UnknownTaskResultError(
                f"No result record exists for task id {task_id!r}."
            ) from error

    def _get_event(self, task_id: str) -> asyncio.Event:
        """Return completion event or a meaningful lookup error."""
        try:
            return self._completion_events[task_id]
        except KeyError as error:
            raise UnknownTaskResultError(
                f"No completion event exists for task id {task_id!r}."
            ) from error

    @staticmethod
    def _assert_running(result: _MutableTaskResult[Any]) -> None:
        """Require a RUNNING state for attempt completion transitions."""
        if result.state is not TaskState.RUNNING:
            raise RuntimeError(
                f"Cannot complete task {result.task_id!r} from state "
                f"{result.state!r}; expected {TaskState.RUNNING!r}."
            )
```

### The Verification

Run a direct backend lifecycle check:

```bash
python - <<'PY'
from pulsequeue.result import InMemoryResultStore, TaskState

backend = InMemoryResultStore()
backend.create(task_id="check-001", task_name="examples.check", max_attempts=1)
backend.mark_running("check-001")
backend.mark_succeeded("check-001", 42)

print(backend.snapshot("check-001").state)
print(backend.snapshot("check-001").value)
PY
```

Expected output:

```text
succeeded
42
```

---

## Step 2: Make `InMemoryBroker` Accept Any Result Backend

### The Target

Update the broker so callers can supply any object implementing `ResultBackend`.

### The Concept

The broker should depend on the **contract**, not a concrete storage class.

This is called **dependency inversion**:

```text
Old direction:
Broker → InMemoryResultStore

Improved direction:
Broker → ResultBackend protocol
InMemoryResultStore → implements ResultBackend
```

The broker still uses `InMemoryResultStore` by default, so existing examples continue to work.

### The Implementation

Replace the complete broker module.

## `src/pulsequeue/broker.py`

```python
"""An in-memory broker for PulseQueue task envelopes."""

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
    """Queue task envelopes in memory and delegate results to a backend.

    The message queue is process-local and non-durable. A custom result backend
    may be durable, but queued messages are still lost if this Python process
    stops before workers consume them.
    """

    def __init__(
        self,
        *,
        max_queue_size: int = 1_000,
        result_backend: ResultBackend | None = None,
    ) -> None:
        """Create a bounded broker with a supplied or default result backend."""
        self._queue = AsyncWorkQueue[TaskEnvelope](max_size=max_queue_size)
        self._result_backend = (
            result_backend if result_backend is not None else InMemoryResultStore()
        )

    @property
    def is_closed(self) -> bool:
        """Return whether the broker has stopped accepting submissions."""
        return self._queue.is_closed

    @property
    def result_backend(self) -> ResultBackend:
        """Return the backend responsible for task result state."""
        return self._result_backend

    def stats(self) -> QueueStats:
        """Return a snapshot of queued work and broker lifecycle state."""
        return self._queue.stats()

    def result_snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        """Return current result state through the configured backend."""
        return self._result_backend.snapshot(task_id)

    async def submit(
        self,
        *,
        task_name: str,
        args: tuple[Any, ...],
        kwargs: dict[str, Any],
        max_retries: int = 0,
    ) -> TaskReceipt[Any]:
        """Create a task envelope, result record, and queue entry."""
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
            self._result_backend.mark_failed(task_id, error)
            raise

        return TaskReceipt(
            self._result_backend,
            task_id=task_id,
            task_name=task_name,
        )

    async def get(self) -> TaskEnvelope | object:
        """Retrieve the next envelope or one internal stop signal."""
        return await self._queue.get()

    def task_done(self) -> None:
        """Mark one retrieved broker entry as fully handled."""
        self._queue.task_done()

    async def join(self) -> None:
        """Wait until all accepted broker entries have been handled."""
        await self._queue.join()

    async def stop_workers(self, *, worker_count: int) -> None:
        """Close submission and enqueue one stop signal per consumer."""
        await self._queue.stop_consumers(consumer_count=worker_count)

    def cancel_pending(self) -> int:
        """Cancel queued envelopes during forced shutdown."""
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
        """Mark one task attempt as active."""
        self._result_backend.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Record retry state through the configured backend."""
        self._result_backend.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Record task success through the configured backend."""
        self._result_backend.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Record terminal failure through the configured backend."""
        self._result_backend.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        """Record cancellation through the configured backend."""
        self._result_backend.mark_cancelled(task_id)
```

### The Verification

Run the existing worker tests:

```bash
python -m pytest tests/test_broker_and_worker.py tests/test_retries_and_shutdown.py -q
```

Expected result:

```text
..........                                                               [100%]
10 passed
```

---

## Step 3: Build Typed Environment Configuration

### The Target

Create immutable runtime settings loaded from environment variables.

### The Concept

Configuration changes between environments:

```text
Developer laptop:
- low worker concurrency
- small queue
- verbose console events

Production:
- higher worker concurrency
- larger queue
- controlled graceful-shutdown timeout
```

Hard-coding these values forces code changes for operational changes.

Environment variables provide deployment-time configuration:

```bash
export PULSEQUEUE_WORKER_CONCURRENCY=4
export PULSEQUEUE_BROKER_MAX_QUEUE_SIZE=5000
export PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS=25
```

We will parse them once, validate them, and expose a typed immutable settings object.

### The Implementation

Create the configuration module.

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
    """Read a positive integer environment variable with a useful error."""
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


def _read_non_negative_float(
    environment: Mapping[str, str],
    name: str,
    *,
    default: float,
) -> float:
    """Read a non-negative float environment variable with a useful error."""
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
    shutdown_timeout_seconds: float = 30.0

    @classmethod
    def from_environment(
        cls,
        environment: Mapping[str, str] | None = None,
    ) -> PulseQueueSettings:
        """Create settings from PULSEQUEUE_* environment variables.

        Supported variables:

        - PULSEQUEUE_WORKER_CONCURRENCY
        - PULSEQUEUE_BROKER_MAX_QUEUE_SIZE
        - PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS
        """
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
            shutdown_timeout_seconds=_read_non_negative_float(
                source,
                "PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS",
                default=30.0,
            ),
        )
```

### The Verification

Run with explicit shell environment variables:

```bash
PULSEQUEUE_WORKER_CONCURRENCY=3 \
PULSEQUEUE_BROKER_MAX_QUEUE_SIZE=25 \
PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS=5.5 \
python - <<'PY'
from pulsequeue.config import PulseQueueSettings

print(PulseQueueSettings.from_environment())
PY
```

Expected output:

```text
PulseQueueSettings(worker_concurrency=3, broker_max_queue_size=25, shutdown_timeout_seconds=5.5)
```

Verify invalid input:

```bash
PULSEQUEUE_WORKER_CONCURRENCY=zero python - <<'PY'
from pulsequeue.config import PulseQueueSettings

PulseQueueSettings.from_environment()
PY
```

Expected output ends with:

```text
ValueError: Environment variable PULSEQUEUE_WORKER_CONCURRENCY must be an integer, not 'zero'.
```

---

## Step 4: Construct Runtimes from Typed Settings

### The Target

Add `PulseQueueRuntime.from_settings(...)`.

### The Concept

A runtime should not need to know how environment variables are named or parsed.

Instead:

```text
Environment variables
        ↓
PulseQueueSettings
        ↓
PulseQueueRuntime.from_settings(...)
        ↓
Broker and worker configuration
```

This separation makes settings easy to test because tests can construct `PulseQueueSettings(...)` directly without changing global environment state.

### The Implementation

Replace the complete runtime module.

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
        plugins: PluginRegistry | None = None,
        result_backend: ResultBackend | None = None,
        shutdown_timeout_seconds: float = 30.0,
    ) -> None:
        """Configure a runtime without starting its worker yet."""
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
        """Start the worker and its configured plugins."""
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

Update public exports.

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

### The Verification

Create this runtime configuration example.

## `examples/56_typed_runtime_configuration.py`

```python
"""Configure and run PulseQueue using immutable typed settings."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime, PulseQueueSettings


app = PulseQueue("configured_runtime")


@app.task(queue="examples")
async def format_message(name: str) -> str:
    """Return a simple task result."""
    await asyncio.sleep(0)
    return f"Hello, {name}."


async def main() -> None:
    """Create settings directly, then use them to compose a runtime."""
    settings = PulseQueueSettings(
        worker_concurrency=2,
        broker_max_queue_size=10,
        shutdown_timeout_seconds=2.0,
    )

    async with PulseQueueRuntime.from_settings(app, settings) as runtime:
        receipt = await runtime.submit("examples.format_message", "Ada")

        print(f"Task result: {await receipt.result(timeout_seconds=1.0)}")
        print(f"Worker concurrency: {runtime.worker.stats().concurrency}")
        print(f"Broker maximum size: {runtime.broker.stats().max_size}")


if __name__ == "__main__":
    asyncio.run(main())
```

Run:

```bash
python examples/56_typed_runtime_configuration.py
```

Expected output:

```text
Task result: Hello, Ada.
Worker concurrency: 2
Broker maximum size: 10
```

---

## Step 5: Create a Transparent Result Backend Decorator

### The Target

Build a result backend wrapper that records state-transition counts without modifying storage behavior.

### The Concept

A backend decorator wraps another backend:

```text
Broker
  ↓
CountingResultBackend
  ↓
InMemoryResultStore
```

The wrapper implements the same protocol while adding one focused responsibility: counting transitions.

This is the **decorator pattern**. It is useful for:

- metrics;
- auditing;
- tracing;
- encryption;
- caching;
- instrumentation.

The wrapped backend still owns actual result storage.

### The Implementation

Create the backend decorator module.

## `src/pulsequeue/result_backends.py`

```python
"""Composable result-backend implementations and decorators."""

from __future__ import annotations

from collections import Counter
from collections.abc import Mapping
from types import MappingProxyType
from typing import Any

from pulsequeue.result import ResultBackend, TaskResultSnapshot


class CountingResultBackend:
    """Decorate another result backend with transition counters."""

    def __init__(self, backend: ResultBackend) -> None:
        """Wrap one backend without changing its state semantics."""
        self._backend = backend
        self._transition_counts: Counter[str] = Counter()

    def transition_counts(self) -> Mapping[str, int]:
        """Return an immutable snapshot of observed transition counts."""
        return MappingProxyType(dict(self._transition_counts))

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        """Create a result record and count submission."""
        self._transition_counts["created"] += 1
        self._backend.create(
            task_id=task_id,
            task_name=task_name,
            max_attempts=max_attempts,
        )

    def mark_running(self, task_id: str) -> None:
        """Delegate a running transition and count it."""
        self._transition_counts["running"] += 1
        self._backend.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Delegate a retry transition and count it."""
        self._transition_counts["retrying"] += 1
        self._backend.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Delegate a successful terminal transition and count it."""
        self._transition_counts["succeeded"] += 1
        self._backend.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Delegate a failed terminal transition and count it."""
        self._transition_counts["failed"] += 1
        self._backend.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        """Delegate a cancelled terminal transition and count it."""
        self._transition_counts["cancelled"] += 1
        self._backend.mark_cancelled(task_id)

    def snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        """Return the wrapped backend's current snapshot."""
        return self._backend.snapshot(task_id)

    async def wait_for_terminal_state(
        self,
        task_id: str,
        *,
        timeout_seconds: float,
    ) -> TaskResultSnapshot[Any]:
        """Delegate terminal-state waiting to the wrapped backend."""
        return await self._backend.wait_for_terminal_state(
            task_id,
            timeout_seconds=timeout_seconds,
        )
```

### The Verification

Create this example.

## `examples/57_counting_result_backend.py`

```python
"""Decorate in-memory task result storage with transition counting."""

from __future__ import annotations

import asyncio

from pulsequeue import (
    InMemoryResultStore,
    PulseQueue,
    PulseQueueRuntime,
)
from pulsequeue.result_backends import CountingResultBackend


app = PulseQueue("counting_backend_demo")


@app.task(queue="math")
async def add(left: int, right: int) -> int:
    """Return a simple asynchronous sum."""
    await asyncio.sleep(0)
    return left + right


async def main() -> None:
    """Run one task and inspect backend transition metrics."""
    backend = CountingResultBackend(InMemoryResultStore())

    async with PulseQueueRuntime(
        app,
        result_backend=backend,
    ) as runtime:
        receipt = await runtime.submit("math.add", 20, 22)

        print(f"Task result: {await receipt.result(timeout_seconds=1.0)}")

    print(f"Transition counts: {dict(backend.transition_counts())}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/57_counting_result_backend.py
```

Expected output:

```text
Task result: 42
Transition counts: {'created': 1, 'running': 1, 'succeeded': 1}
```

---

## Step 6: Add Tests for Settings and Result Backend Composition

### The Target

Add regression tests for typed environment configuration and custom result backend use.

### The Concept

Configuration and backend injection are production boundaries. Tests ensure:

- malformed deployment configuration fails at startup;
- runtime settings reach the correct components;
- a custom backend receives expected transitions;
- existing task semantics remain unchanged.

### The Implementation

Create this test module.

## `tests/test_configuration_and_result_backends.py`

```python
"""Tests for typed settings and pluggable result backend composition."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue import (
    InMemoryResultStore,
    PulseQueue,
    PulseQueueRuntime,
    PulseQueueSettings,
)
from pulsequeue.result_backends import CountingResultBackend


def test_settings_read_valid_environment_values() -> None:
    """Typed settings should parse configured environment values."""
    settings = PulseQueueSettings.from_environment(
        {
            "PULSEQUEUE_WORKER_CONCURRENCY": "4",
            "PULSEQUEUE_BROKER_MAX_QUEUE_SIZE": "250",
            "PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS": "12.5",
        }
    )

    assert settings.worker_concurrency == 4
    assert settings.broker_max_queue_size == 250
    assert settings.shutdown_timeout_seconds == 12.5


def test_settings_reject_invalid_environment_values() -> None:
    """Malformed environment configuration must fail before worker startup."""
    with pytest.raises(ValueError, match="must be an integer"):
        PulseQueueSettings.from_environment(
            {"PULSEQUEUE_WORKER_CONCURRENCY": "many"}
        )

    with pytest.raises(ValueError, match="zero or greater"):
        PulseQueueSettings.from_environment(
            {"PULSEQUEUE_SHUTDOWN_TIMEOUT_SECONDS": "-1"}
        )


def test_runtime_from_settings_uses_configured_worker_and_broker_values() -> None:
    """Runtime composition should use validated settings values."""

    async def run_test() -> None:
        app = PulseQueue("settings_runtime")

        @app.task(queue="examples")
        async def identity(value: int) -> int:
            return value

        settings = PulseQueueSettings(
            worker_concurrency=2,
            broker_max_queue_size=7,
            shutdown_timeout_seconds=1.0,
        )

        async with PulseQueueRuntime.from_settings(app, settings) as runtime:
            assert runtime.worker.stats().concurrency == 2
            assert runtime.broker.stats().max_size == 7

            receipt = await runtime.submit("examples.identity", 42)
            assert await receipt.result(timeout_seconds=1.0) == 42

    asyncio.run(run_test())


def test_counting_backend_observes_task_transitions() -> None:
    """A protocol-compatible backend decorator should observe worker changes."""

    async def run_test() -> None:
        app = PulseQueue("counting_backend")
        backend = CountingResultBackend(InMemoryResultStore())

        @app.task(queue="examples")
        async def double(value: int) -> int:
            return value * 2

        async with PulseQueueRuntime(
            app,
            result_backend=backend,
        ) as runtime:
            receipt = await runtime.submit("examples.double", 21)
            assert await receipt.result(timeout_seconds=1.0) == 42

        assert dict(backend.transition_counts()) == {
            "created": 1,
            "running": 1,
            "succeeded": 1,
        }

    asyncio.run(run_test())
```

### The Verification

Run the entire test suite:

```bash
python -m pytest -q
```

Expected result resembles:

```text
...........................................................              [100%]
59 passed
```

The total can vary based on whether your optional native extension was built. The important requirement is that every test passes.

---

# Phase 4 Reference: Production Boundaries

## What Is Now Pluggable?

The framework has explicit interfaces for:

| Component | Current default | Future replacement |
|---|---|---|
| Result storage | `InMemoryResultStore` | Redis, PostgreSQL, SQLite, remote service |
| Event observation | `PluginRegistry` | Custom metrics, audit, tracing plugins |
| Runtime settings | `PulseQueueSettings` | Environment, config file, secret manager |
| Task execution | Async worker | Later: process and thread execution adapters |

## What Is Still In-Memory?

Even with a durable result backend, `InMemoryBroker` remains process-local:

```text
Process exits before worker consumes envelope
        ↓
Queued task is lost
```

A production distributed system needs a durable broker replacement.

That broker must define:

- atomic enqueue;
- message acknowledgement;
- visibility timeout or lease behavior;
- delayed-message support for retries;
- producer/consumer authentication;
- serialization;
- delivery guarantees;
- dead-letter handling.

We now have clean boundaries for building that layer without rewriting task registration, receipts, worker lifecycle, plugin contracts, or configuration parsing.
