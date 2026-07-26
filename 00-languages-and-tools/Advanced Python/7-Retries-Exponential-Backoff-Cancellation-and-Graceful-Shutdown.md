# Part 7: Retries, Exponential Backoff, Cancellation, and Graceful Shutdown

A worker that executes a task once is useful, but real systems encounter temporary failures:

- a remote API returns a transient error;
- a database connection is briefly unavailable;
- a rate limit asks the caller to slow down;
- a service is restarting;
- a network packet is lost.

A retry gives temporary failures another chance.

However, retrying everything immediately is dangerous. If one external service is unhealthy and thousands of workers retry at once, the retry traffic can make the outage worse.

We will add:

- retry attempt tracking;
- configurable retry counts;
- exponential backoff;
- deterministic retry delays;
- cancellation-safe retry waiting;
- graceful shutdown deadlines;
- forced cancellation when graceful shutdown exceeds its deadline.

---

## Step 1: Define Retry Semantics Clearly

### The Target

Clarify what `max_retries` means and update task validation to allow zero retries.

### The Concept

A common source of confusion is whether a setting named `max_retries` includes the original task execution.

In PulseQueue, we will use this definition:

```text
max_retries = number of additional attempts after the first attempt
```

Examples:

| `max_retries` | Maximum total attempts |
|---:|---:|
| `0` | 1 |
| `1` | 2 |
| `2` | 3 |
| `3` | 4 |

A task with `max_retries=0` is valid. It means: “Run once; do not retry.”

We also need retry timing configuration:

- `retry_delay_seconds`: initial wait before the first retry.
- `retry_backoff_multiplier`: how quickly waits grow.

With a delay of `0.1` and multiplier of `2.0`, the delays are:

```text
Retry 1 → 0.1 seconds
Retry 2 → 0.2 seconds
Retry 3 → 0.4 seconds
Retry 4 → 0.8 seconds
```

This is **exponential backoff**.

Think of it as repeatedly calling a busy person. Calling again instantly is annoying and unlikely to help. Waiting progressively longer gives the other system time to recover.

### The Implementation

Replace `src/pulsequeue/options.py` with this complete version.

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
    """Reject negative floating-point values while allowing zero."""
    if value < 0:
        raise ValueError("Value must be zero or greater.")


def positive_float(value: float) -> None:
    """Reject zero and negative floating-point values."""
    if value <= 0:
        raise ValueError("Value must be greater than zero.")


class TaskOptions(Model):
    """Configuration for one task registered with PulseQueue.

    Core fields are declared directly and validated through Field descriptors.
    Optional metadata is held in a separate TaskMetadata object.

    Metadata can be read through explicit dynamic names such as meta_owner.
    The prefix keeps dynamic names from shadowing or colliding with the
    framework's regular public API.
    """

    name = Field(str)
    queue = Field(str)

    # max_retries means additional attempts after the initial execution.
    # Zero is valid and means the task runs only once.
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
        """Create validated task options with empty metadata by default."""
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
        """Return a stable queue-qualified task identifier."""
        return f"{self.queue}.{self.name}"

    @computed_property
    def has_timeout(self) -> bool:
        """Return whether execution should enforce a timeout."""
        return self.timeout_seconds > 0.0

    @computed_property
    def max_attempts(self) -> int:
        """Return initial attempt plus all configured retry attempts."""
        return 1 + self.max_retries

    def retry_delay_for_attempt(self, retry_number: int) -> float:
        """Return exponential-backoff delay for a one-based retry number.

        retry_number=1 means the first retry after the initial failed attempt.
        retry_number=2 means the second retry, and so on.
        """
        if retry_number < 1:
            raise ValueError("retry_number must be at least 1.")

        return self.retry_delay_seconds * (
            self.retry_backoff_multiplier ** (retry_number - 1)
        )

    def __getattr__(self, name: str) -> Any:
        """Resolve explicitly prefixed dynamic metadata reads."""
        metadata_prefix = "meta_"

        if not name.startswith(metadata_prefix):
            raise AttributeError(
                f"{type(self).__name__} has no attribute {name!r}. "
                "Dynamic metadata reads must use the 'meta_' prefix, "
                "for example 'meta_owner'."
            )

        metadata_name = name.removeprefix(metadata_prefix)

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
        """Reject dynamic metadata writes and preserve descriptor behavior."""
        if name.startswith("meta_"):
            raise AttributeError(
                "Dynamic metadata is read-only through TaskOptions. "
                "Assign metadata through the 'metadata' object, for example "
                "'options.metadata.owner = \"platform-team\"'."
            )

        super().__setattr__(name, value)
```

### The Verification

Create this example.

## `examples/31_retry_configuration.py`

```python
"""Demonstrate retry configuration and exponential-backoff calculations."""

from __future__ import annotations

from pulsequeue.options import TaskOptions


options = TaskOptions(
    name="fetch_partner_data",
    queue="integrations",
    max_retries=3,
    retry_delay_seconds=0.25,
    retry_backoff_multiplier=2.0,
)

print(f"Task name: {options.qualified_name}")
print(f"Configured retries: {options.max_retries}")
print(f"Maximum attempts: {options.max_attempts}")

for retry_number in range(1, options.max_retries + 1):
    delay = options.retry_delay_for_attempt(retry_number)
    print(f"Retry {retry_number} delay: {delay:.2f} seconds")

no_retry_options = TaskOptions(
    name="run_once",
    queue="examples",
    max_retries=0,
)

print(f"No-retry task maximum attempts: {no_retry_options.max_attempts}")

try:
    TaskOptions(
        name="invalid",
        queue="examples",
        max_retries=-1,
    )
except ValueError as error:
    print(f"Invalid retry count: {error}")
```

### The Verification

Run:

```bash
python examples/31_retry_configuration.py
```

Expected output:

```text
Task name: integrations.fetch_partner_data
Configured retries: 3
Maximum attempts: 4
Retry 1 delay: 0.25 seconds
Retry 2 delay: 0.50 seconds
Retry 3 delay: 1.00 seconds
No-retry task maximum attempts: 1
Invalid retry count: Value must be zero or greater.
```

---

## Step 2: Add Retry State and Attempt Tracking to Task Results

### The Target

Extend the task-result model so callers can see retry state, attempt count, and retry timing.

### The Concept

A task that is retrying is neither successfully finished nor permanently failed.

Its lifecycle now becomes:

```text
QUEUED
  ↓
RUNNING
  ↓ failure with attempts remaining
RETRYING
  ↓
RUNNING
  ↓
SUCCEEDED or FAILED or CANCELLED
```

We need to preserve enough state for callers and observability tools to answer:

- How many attempts have started?
- How many attempts are allowed?
- Is the task currently waiting for retry?
- What was the most recent failure?
- When will the next retry start?

### The Implementation

Replace `src/pulsequeue/result.py`.

## `src/pulsequeue/result.py`

```python
"""Task result state, receipts, retry tracking, and result-store primitives."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from enum import StrEnum
from typing import Any, Generic, TypeVar

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
        """Create an error containing safe task-failure details."""
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
    """Raised when a receipt references a result absent from the result store."""


@dataclass(slots=True)
class _MutableTaskResult(Generic[ResultT]):
    """Internal mutable task state owned only by InMemoryResultStore."""

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

    __slots__ = ("_result_store", "task_id", "task_name")

    def __init__(
        self,
        result_store: InMemoryResultStore,
        *,
        task_id: str,
        task_name: str,
    ) -> None:
        """Create a receipt associated with one broker-owned result record."""
        self._result_store = result_store
        self.task_id = task_id
        self.task_name = task_name

    async def result(self, *, timeout_seconds: float = 0.0) -> ResultT:
        """Wait for and return the final task result."""
        snapshot = await self._result_store.wait_for_terminal_state(
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
        """Return the latest result snapshot without waiting."""
        return self._result_store.snapshot(self.task_id)

    def __repr__(self) -> str:
        """Return a concise receipt representation for logs and debugging."""
        return (
            f"{type(self).__name__}("
            f"task_id={self.task_id!r}, "
            f"task_name={self.task_name!r}"
            f")"
        )


class InMemoryResultStore:
    """Store task state and completion notifications for one in-memory broker."""

    def __init__(self) -> None:
        """Create an empty result store."""
        self._results: dict[str, _MutableTaskResult[Any]] = {}
        self._completion_events: dict[str, asyncio.Event] = {}

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        """Create the initial queued result record."""
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
        """Transition queued or retrying work into another active attempt."""
        result = self._get_mutable_result(task_id)

        if result.state not in {TaskState.QUEUED, TaskState.RETRYING}:
            raise RuntimeError(
                f"Cannot mark task {task_id!r} running from state {result.state!r}."
            )

        if result.attempt >= result.max_attempts:
            raise RuntimeError(
                f"Task {task_id!r} cannot start attempt {result.attempt + 1}; "
                f"maximum is {result.max_attempts}."
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
        """Record a transient failure and transition to retry waiting state."""
        if delay_seconds < 0:
            raise ValueError("delay_seconds must be zero or greater.")

        result = self._get_mutable_result(task_id)
        self._assert_running(result)

        if result.attempt >= result.max_attempts:
            raise RuntimeError(
                f"Task {task_id!r} has no attempts remaining and cannot retry."
            )

        result.state = TaskState.RETRYING
        result.failure = TaskFailure(
            exception_type=type(exception).__name__,
            message=str(exception),
        )
        result.next_retry_at = datetime.now(UTC) + timedelta(
            seconds=delay_seconds
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store a successful result and notify waiting receipt holders."""
        result = self._get_mutable_result(task_id)
        self._assert_running(result)

        result.state = TaskState.SUCCEEDED
        result.value = value
        result.failure = None
        result.completed_at = datetime.now(UTC)
        result.next_retry_at = None
        self._completion_events[task_id].set()

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store final failure details and notify waiting receipt holders."""
        result = self._get_mutable_result(task_id)

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
        """Store cancellation state and notify waiting receipt holders."""
        result = self._get_mutable_result(task_id)

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
        """Return an immutable copy of the current state for one task."""
        result = self._get_mutable_result(task_id)

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
        """Wait for completion and return the final immutable result snapshot."""
        if timeout_seconds < 0:
            raise ValueError("timeout_seconds must be zero or greater.")

        current_snapshot = self.snapshot(task_id)

        if current_snapshot.state in TERMINAL_TASK_STATES:
            return current_snapshot

        completion_event = self._get_completion_event(task_id)

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

    def _get_mutable_result(self, task_id: str) -> _MutableTaskResult[Any]:
        """Return internal mutable state or raise a framework-specific error."""
        try:
            return self._results[task_id]
        except KeyError as error:
            raise UnknownTaskResultError(
                f"No result record exists for task id {task_id!r}."
            ) from error

    def _get_completion_event(self, task_id: str) -> asyncio.Event:
        """Return the completion event associated with one task."""
        try:
            return self._completion_events[task_id]
        except KeyError as error:
            raise UnknownTaskResultError(
                f"No completion event exists for task id {task_id!r}."
            ) from error

    @staticmethod
    def _assert_running(result: _MutableTaskResult[Any]) -> None:
        """Ensure attempt completion transitions happen only from RUNNING."""
        if result.state is not TaskState.RUNNING:
            raise RuntimeError(
                f"Cannot complete task {result.task_id!r} from state "
                f"{result.state!r}; expected {TaskState.RUNNING!r}."
            )
```

### The Verification

The broker will be updated in the next step to create result records with `max_attempts`. Do not run the full worker examples yet.

For now, verify that the module imports successfully:

```bash
python -c "from pulsequeue.result import TaskState; print(TaskState.RETRYING)"
```

Expected output:

```text
retrying
```

---

## Step 3: Allow the Broker to Carry Retry Configuration and Cancel Pending Work

### The Target

Update the broker so it:

- creates result records with maximum attempt counts;
- exposes retry transitions to workers;
- cancels queued envelopes during forced shutdown.

### The Concept

When graceful shutdown exceeds its deadline, a worker must not leave receipts permanently stuck in `QUEUED`.

The broker owns queued envelopes, so it is the correct place to cancel messages that have not started.

We will add a queue-draining operation:

```text
Broker queue contains pending envelopes
        ↓
Forced shutdown begins
        ↓
Broker removes waiting envelopes
        ↓
Broker marks their receipts CANCELLED
```

### The Implementation

First, replace `src/pulsequeue/async_queue.py`.

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
    """Raised when code submits work after a queue has begun closing."""


@dataclass(frozen=True, slots=True)
class QueueStats:
    """A snapshot of queue state for diagnostics and metrics."""

    max_size: int
    queued_items: int
    unfinished_tasks: int
    is_closed: bool


class _StopSignal:
    """Private sentinel placed into a queue to stop one consumer."""

    __slots__ = ()


STOP_SIGNAL = _StopSignal()


class AsyncWorkQueue(Generic[ItemT]):
    """A bounded queue with controlled submission and graceful consumer stops."""

    def __init__(self, *, max_size: int) -> None:
        """Create a queue with an explicit positive capacity."""
        if max_size < 1:
            raise ValueError("max_size must be at least 1.")

        self._queue: asyncio.Queue[ItemT | _StopSignal] = asyncio.Queue(
            maxsize=max_size
        )
        self._max_size = max_size
        self._is_closed = False

    @property
    def is_closed(self) -> bool:
        """Return whether the queue rejects new work submissions."""
        return self._is_closed

    async def put(self, item: ItemT) -> None:
        """Wait for capacity and submit one item."""
        if self._is_closed:
            raise QueueClosedError("Cannot submit work: queue is closed.")

        await self._queue.put(item)

    def put_nowait(self, item: ItemT) -> None:
        """Submit one item immediately or raise asyncio.QueueFull."""
        if self._is_closed:
            raise QueueClosedError("Cannot submit work: queue is closed.")

        self._queue.put_nowait(item)

    async def get(self) -> ItemT | _StopSignal:
        """Wait until an item or consumer stop signal becomes available."""
        return await self._queue.get()

    def get_nowait(self) -> ItemT | _StopSignal:
        """Retrieve one item immediately or raise asyncio.QueueEmpty."""
        return self._queue.get_nowait()

    def task_done(self) -> None:
        """Mark one previously retrieved queue entry as fully handled."""
        self._queue.task_done()

    async def join(self) -> None:
        """Wait until every submitted queue entry has task_done() called."""
        await self._queue.join()

    def close(self) -> None:
        """Prevent future work submissions without discarding queued work."""
        self._is_closed = True

    async def stop_consumers(self, *, consumer_count: int) -> None:
        """Enqueue one stop signal per consumer after closing submissions."""
        if consumer_count < 1:
            raise ValueError("consumer_count must be at least 1.")

        self.close()

        for _ in range(consumer_count):
            await self._queue.put(STOP_SIGNAL)

    def drain_nowait(self) -> Iterator[ItemT | _StopSignal]:
        """Remove all currently queued entries without waiting.

        This operation is used only during forced shutdown. Every yielded item
        has been retrieved and must therefore be paired with task_done().
        """
        while True:
            try:
                yield self.get_nowait()
            except asyncio.QueueEmpty:
                return

    def stats(self) -> QueueStats:
        """Return a point-in-time state snapshot."""
        return QueueStats(
            max_size=self._max_size,
            queued_items=self._queue.qsize(),
            unfinished_tasks=self._queue._unfinished_tasks,
            is_closed=self._is_closed,
        )
```

Now replace `src/pulsequeue/broker.py`.

## `src/pulsequeue/broker.py`

```python
"""An in-memory broker for PulseQueue task envelopes."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from pulsequeue.async_queue import (
    STOP_SIGNAL,
    AsyncWorkQueue,
    QueueStats,
)
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.result import InMemoryResultStore, TaskReceipt


class InMemoryBroker:
    """Queue task envelopes in memory and retain associated task results.

    This broker is process-local and non-durable. Restarting Python loses
    pending messages and all stored results.
    """

    def __init__(self, *, max_queue_size: int = 1_000) -> None:
        """Create a bounded broker with an empty result store."""
        self._queue = AsyncWorkQueue[TaskEnvelope](max_size=max_queue_size)
        self._result_store = InMemoryResultStore()

    @property
    def is_closed(self) -> bool:
        """Return whether the broker has stopped accepting submissions."""
        return self._queue.is_closed

    def stats(self) -> QueueStats:
        """Return a snapshot of queued work and lifecycle state."""
        return self._queue.stats()

    async def submit(
        self,
        *,
        task_name: str,
        args: tuple[Any, ...],
        kwargs: dict[str, Any],
        max_retries: int = 0,
    ) -> TaskReceipt[Any]:
        """Create and enqueue one task envelope."""
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

        self._result_store.create(
            task_id=task_id,
            task_name=task_name,
            max_attempts=1 + max_retries,
        )

        try:
            await self._queue.put(envelope)
        except BaseException as error:
            self._result_store.mark_failed(task_id, error)
            raise

        return TaskReceipt(
            self._result_store,
            task_id=task_id,
            task_name=task_name,
        )

    async def get(self) -> TaskEnvelope | object:
        """Retrieve the next task envelope or an internal worker stop signal."""
        return await self._queue.get()

    def task_done(self) -> None:
        """Mark one retrieved broker entry as fully handled."""
        self._queue.task_done()

    async def join(self) -> None:
        """Wait until all accepted broker entries have been handled."""
        await self._queue.join()

    async def stop_workers(self, *, worker_count: int) -> None:
        """Close submissions and request graceful termination of workers."""
        await self._queue.stop_consumers(consumer_count=worker_count)

    def cancel_pending(self) -> int:
        """Cancel queued envelopes during forced shutdown.

        Returns the number of task envelopes cancelled. Internal stop signals
        are accounted for but are not task cancellations.
        """
        cancelled_count = 0

        for item in self._queue.drain_nowait():
            try:
                if isinstance(item, TaskEnvelope):
                    self._result_store.mark_cancelled(item.task_id)
                    cancelled_count += 1
                elif item is not STOP_SIGNAL:
                    raise RuntimeError(
                        f"Broker encountered unexpected queued item {item!r}."
                    )
            finally:
                self._queue.task_done()

        return cancelled_count

    def mark_running(self, task_id: str) -> None:
        """Mark a broker-owned task result as running."""
        self._result_store.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Record a retryable task failure."""
        self._result_store.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store a successful worker result."""
        self._result_store.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store a terminal worker failure."""
        self._result_store.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        """Store worker cancellation."""
        self._result_store.mark_cancelled(task_id)
```

Finally, update the `submit(...)` method in `src/pulsequeue/app.py`.

Replace only that method with the version below.

## `src/pulsequeue/app.py` — replace `PulseQueue.submit`

```python
    async def submit(
        self,
        broker: InMemoryBroker,
        task_name: str,
        /,
        *args: Any,
        **kwargs: Any,
    ) -> TaskReceipt[Any]:
        """Validate and enqueue one registered task through an in-memory broker.

        Submission does not execute the task. A PulseQueueWorker must be
        running separately to consume the broker message and produce a result.
        """
        task = self.get_task(task_name)

        # Validate before the message enters the queue. This gives callers a
        # direct TypeError for invalid task arguments and avoids unexecutable
        # work occupying broker capacity.
        task.bind_arguments(*args, **kwargs)

        return await broker.submit(
            task_name=task.name,
            args=args,
            kwargs=kwargs,
            max_retries=task.options.max_retries,
        )
```

### The Verification

Run this import and syntax check:

```bash
python -m compileall -q src
```

No output means compilation succeeded.

---

## Step 4: Add Retry Execution to the Worker

### The Target

Update the worker so transient failures retry until success or attempt exhaustion.

### The Concept

The worker will now execute a task in a loop:

```text
Start attempt
    ↓
Task succeeds → record success
    ↓
Task fails with retries remaining → record RETRYING → wait → try again
    ↓
Task fails with no attempts remaining → record final failure
```

This tutorial worker keeps retry waiting inside the worker coroutine.

That is easy to understand and correct for an in-memory framework. A large distributed system would usually place delayed retries back into a durable delayed-message broker, so a worker slot is not occupied while waiting.

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

from pulsequeue.app import PulseQueue
from pulsequeue.async_queue import STOP_SIGNAL
from pulsequeue.broker import InMemoryBroker
from pulsequeue.envelope import TaskEnvelope
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


class PulseQueueWorker:
    """Consume in-memory broker tasks using a configurable async worker pool."""

    def __init__(
        self,
        app: PulseQueue,
        broker: InMemoryBroker,
        *,
        concurrency: int = 1,
    ) -> None:
        """Configure a worker without starting consumer loops yet."""
        if concurrency < 1:
            raise ValueError("concurrency must be at least 1.")

        self._app = app
        self._broker = broker
        self._concurrency = concurrency
        self._state = WorkerState.CREATED
        self._consumer_tasks: list[asyncio.Task[None]] = []

        self._completed_tasks = 0
        self._failed_tasks = 0
        self._cancelled_tasks = 0
        self._retry_attempts = 0

    @property
    def state(self) -> WorkerState:
        """Return the current worker lifecycle state."""
        return self._state

    @property
    def is_running(self) -> bool:
        """Return whether consumer loops are actively receiving messages."""
        return self._state is WorkerState.RUNNING

    def stats(self) -> WorkerStats:
        """Return a stable snapshot of worker counters."""
        return WorkerStats(
            state=self._state,
            concurrency=self._concurrency,
            completed_tasks=self._completed_tasks,
            failed_tasks=self._failed_tasks,
            cancelled_tasks=self._cancelled_tasks,
            retry_attempts=self._retry_attempts,
        )

    async def start(self) -> None:
        """Start one consumer coroutine for every configured concurrency slot."""
        if self._state is not WorkerState.CREATED:
            raise RuntimeError(
                f"Worker cannot start from state {self._state!r}; "
                f"expected {WorkerState.CREATED!r}."
            )

        if self._broker.is_closed:
            raise RuntimeError("Cannot start worker because the broker is closed.")

        self._state = WorkerState.RUNNING

        self._consumer_tasks = [
            asyncio.create_task(
                self._consume_forever(worker_number),
                name=f"pulsequeue-worker-{self._app.name}-{worker_number}",
            )
            for worker_number in range(1, self._concurrency + 1)
        ]

    async def stop(self, *, timeout_seconds: float = 0.0) -> None:
        """Gracefully stop the worker, optionally enforcing a shutdown deadline.

        A timeout of zero waits indefinitely for accepted work to finish.
        A positive timeout cancels active tasks and queued work if graceful
        draining does not complete before the deadline.
        """
        if timeout_seconds < 0:
            raise ValueError("timeout_seconds must be zero or greater.")

        if self._state is WorkerState.STOPPED:
            return

        if self._state is WorkerState.CREATED:
            self._state = WorkerState.STOPPED
            return

        if self._state is not WorkerState.RUNNING:
            raise RuntimeError(f"Worker cannot stop from state {self._state!r}.")

        self._state = WorkerState.STOPPING

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

        self._consumer_tasks.clear()
        self._state = WorkerState.STOPPED

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
        """Drain and stop the worker when leaving an async context."""
        await self.stop()

    async def _force_stop(self) -> None:
        """Cancel active consumers and cancel all still-queued task envelopes."""
        for consumer_task in self._consumer_tasks:
            consumer_task.cancel()

        # return_exceptions=True is appropriate here because shutdown must
        # collect cancellation outcomes instead of letting one cancelled
        # consumer prevent cleanup of remaining queued messages.
        await asyncio.gather(*self._consumer_tasks, return_exceptions=True)

        cancelled_queued_tasks = self._broker.cancel_pending()
        self._cancelled_tasks += cancelled_queued_tasks

        # Every active consumer calls broker.task_done() in its finally block.
        # cancel_pending() accounts for every still-queued item.
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
                # Every broker get must have exactly one task_done call,
                # including stop signals and cancellation paths.
                self._broker.task_done()

    async def _execute_envelope(self, envelope: TaskEnvelope) -> None:
        """Execute one task, retrying configured transient failures."""
        task = self._app.get_task(envelope.task_name)

        while True:
            self._broker.mark_running(envelope.task_id)

            try:
                result = await await_with_timeout(
                    task(*envelope.args, **dict(envelope.kwargs)),
                    timeout_seconds=task.options.timeout_seconds,
                    operation_name=envelope.task_name,
                )
            except asyncio.CancelledError:
                # Cancellation must continue propagating to the consumer task.
                # Recording terminal state first prevents receipt holders from
                # waiting forever after a forced shutdown.
                self._broker.mark_cancelled(envelope.task_id)
                self._cancelled_tasks += 1
                raise
            except Exception as error:
                snapshot = self._result_snapshot(envelope.task_id)

                if snapshot.attempt >= snapshot.max_attempts:
                    self._broker.mark_failed(envelope.task_id, error)
                    self._failed_tasks += 1
                    return

                retry_number = snapshot.attempt
                delay_seconds = task.options.retry_delay_for_attempt(retry_number)

                self._broker.mark_retrying(
                    envelope.task_id,
                    error,
                    delay_seconds=delay_seconds,
                )
                self._retry_attempts += 1

                # asyncio.sleep is cancellation-aware. If forced shutdown
                # happens while waiting, CancelledError reaches the outer
                # cancellation handler during the next loop iteration.
                await asyncio.sleep(delay_seconds)
            else:
                self._broker.mark_succeeded(envelope.task_id, result)
                self._completed_tasks += 1
                return

    def _result_snapshot(self, task_id: str):
        """Read one broker result snapshot through the task receipt store.

        In this in-memory framework, the worker has no need to expose the
        result store publicly. The broker's result state is accessed through
        this narrow helper to keep retry decisions local to worker execution.
        """
        return self._broker._result_store.snapshot(task_id)
```

The final helper above accesses a private broker attribute, which violates the framework boundary we established. Replace `src/pulsequeue/broker.py` with this corrected version that exposes a public snapshot method.

## `src/pulsequeue/broker.py`

```python
"""An in-memory broker for PulseQueue task envelopes."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from pulsequeue.async_queue import (
    STOP_SIGNAL,
    AsyncWorkQueue,
    QueueStats,
)
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.result import (
    InMemoryResultStore,
    TaskReceipt,
    TaskResultSnapshot,
)


class InMemoryBroker:
    """Queue task envelopes in memory and retain associated task results."""

    def __init__(self, *, max_queue_size: int = 1_000) -> None:
        """Create a bounded broker with an empty result store."""
        self._queue = AsyncWorkQueue[TaskEnvelope](max_size=max_queue_size)
        self._result_store = InMemoryResultStore()

    @property
    def is_closed(self) -> bool:
        """Return whether the broker has stopped accepting submissions."""
        return self._queue.is_closed

    def stats(self) -> QueueStats:
        """Return a snapshot of queued work and lifecycle state."""
        return self._queue.stats()

    def result_snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        """Return the current result state for one broker-owned task."""
        return self._result_store.snapshot(task_id)

    async def submit(
        self,
        *,
        task_name: str,
        args: tuple[Any, ...],
        kwargs: dict[str, Any],
        max_retries: int = 0,
    ) -> TaskReceipt[Any]:
        """Create and enqueue one task envelope."""
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

        self._result_store.create(
            task_id=task_id,
            task_name=task_name,
            max_attempts=1 + max_retries,
        )

        try:
            await self._queue.put(envelope)
        except BaseException as error:
            self._result_store.mark_failed(task_id, error)
            raise

        return TaskReceipt(
            self._result_store,
            task_id=task_id,
            task_name=task_name,
        )

    async def get(self) -> TaskEnvelope | object:
        """Retrieve the next task envelope or an internal worker stop signal."""
        return await self._queue.get()

    def task_done(self) -> None:
        """Mark one retrieved broker entry as fully handled."""
        self._queue.task_done()

    async def join(self) -> None:
        """Wait until all accepted broker entries have been handled."""
        await self._queue.join()

    async def stop_workers(self, *, worker_count: int) -> None:
        """Close submissions and request graceful worker termination."""
        await self._queue.stop_consumers(consumer_count=worker_count)

    def cancel_pending(self) -> int:
        """Cancel queued envelopes during forced shutdown."""
        cancelled_count = 0

        for item in self._queue.drain_nowait():
            try:
                if isinstance(item, TaskEnvelope):
                    self._result_store.mark_cancelled(item.task_id)
                    cancelled_count += 1
                elif item is not STOP_SIGNAL:
                    raise RuntimeError(
                        f"Broker encountered unexpected queued item {item!r}."
                    )
            finally:
                self._queue.task_done()

        return cancelled_count

    def mark_running(self, task_id: str) -> None:
        """Mark a broker-owned task result as running."""
        self._result_store.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        """Record a retryable task failure."""
        self._result_store.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store a successful worker result."""
        self._result_store.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store a terminal worker failure."""
        self._result_store.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        """Store worker cancellation."""
        self._result_store.mark_cancelled(task_id)
```

Then replace only `_result_snapshot(...)` in `src/pulsequeue/worker.py`.

## `src/pulsequeue/worker.py` — replace `_result_snapshot`

```python
    def _result_snapshot(self, task_id: str):
        """Return a task result snapshot through the broker's public API."""
        return self._broker.result_snapshot(task_id)
```

### The Verification

Run a compilation check:

```bash
python -m compileall -q src
```

No output means all framework modules compile.

---

## Step 5: Verify Successful Retry Behavior

### The Target

Create a task that fails twice and succeeds on its third attempt.

### The Concept

A retrying task must retain state between attempts for this demonstration.

In production, retryable state is commonly stored in a database, external service, or task payload. Here, we use a small closure dictionary only to make the behavior observable.

The task will behave like this:

```text
Attempt 1 → fail
Attempt 2 → fail
Attempt 3 → succeed
```

With `max_retries=2`, three total attempts are allowed.

### The Implementation

Create this example.

## `examples/32_successful_retry.py`

```python
"""Demonstrate a task that succeeds after retry attempts."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.worker import PulseQueueWorker


app = PulseQueue("retry_demo")

attempt_counter = {"count": 0}


@app.task(
    queue="examples",
    max_retries=2,
    retry_delay_seconds=0.02,
    retry_backoff_multiplier=2.0,
)
async def eventually_succeeds(value: int) -> int:
    """Fail twice, then succeed on the third total attempt."""
    await asyncio.sleep(0)

    attempt_counter["count"] += 1
    current_attempt = attempt_counter["count"]

    print(f"Task function running attempt {current_attempt}")

    if current_attempt < 3:
        raise ConnectionError(f"Temporary upstream failure on attempt {current_attempt}")

    return value * 2


async def main() -> None:
    """Run a retrying task through one worker."""
    broker = InMemoryBroker()

    async with PulseQueueWorker(app, broker) as worker:
        receipt = await app.submit(
            broker,
            "examples.eventually_succeeds",
            21,
        )

        while receipt.snapshot().state.value not in {
            "succeeded",
            "failed",
            "cancelled",
        }:
            snapshot = receipt.snapshot()
            print(
                "Observed state: "
                f"{snapshot.state}, attempt={snapshot.attempt}/"
                f"{snapshot.max_attempts}"
            )
            await asyncio.sleep(0.01)

        result = await receipt.result(timeout_seconds=1.0)

        print(f"Final result: {result}")
        print(f"Final snapshot: {receipt.snapshot()}")
        print(f"Worker statistics: {worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/32_successful_retry.py
```

Expected output includes:

```text
Task function running attempt 1
Task function running attempt 2
Task function running attempt 3
Final result: 42
```

The final snapshot should show:

```text
state=<TaskState.SUCCEEDED: 'succeeded'>
attempt=3
max_attempts=3
```

Worker statistics should include:

```text
completed_tasks=1
failed_tasks=0
retry_attempts=2
```

---

## Step 6: Verify Final Failure After Retry Exhaustion

### The Target

Confirm that a permanently failing task becomes `FAILED` after all attempts are used.

### The Concept

Retries are not permission to retry forever.

A system that retries forever can:

- overload a broken dependency;
- fill queues indefinitely;
- consume money through repeated external requests;
- hide a permanent programming error;
- prevent clean shutdown.

After the final allowed attempt fails, PulseQueue records the last exception as the terminal failure.

### The Implementation

Create this example.

## `examples/33_retry_exhaustion.py`

```python
"""Demonstrate terminal failure after all retry attempts are exhausted."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.result import TaskFailureError
from pulsequeue.worker import PulseQueueWorker


app = PulseQueue("retry_exhaustion")

attempt_counter = {"count": 0}


@app.task(
    queue="examples",
    max_retries=2,
    retry_delay_seconds=0.01,
)
async def permanently_fails() -> None:
    """Always fail so the worker eventually exhausts all attempts."""
    await asyncio.sleep(0)

    attempt_counter["count"] += 1
    print(f"Running attempt {attempt_counter['count']}")

    raise RuntimeError("The remote system remains unavailable.")


async def main() -> None:
    """Run and inspect a task that exhausts its retry budget."""
    broker = InMemoryBroker()

    async with PulseQueueWorker(app, broker) as worker:
        receipt = await app.submit(broker, "examples.permanently_fails")

        try:
            await receipt.result(timeout_seconds=1.0)
        except TaskFailureError as error:
            snapshot = receipt.snapshot()

            print(f"Terminal task error: {error}")
            print(f"Failure type: {error.failure.exception_type}")
            print(f"Attempt count: {snapshot.attempt}/{snapshot.max_attempts}")
            print(f"Worker statistics: {worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/33_retry_exhaustion.py
```

Expected output includes:

```text
Running attempt 1
Running attempt 2
Running attempt 3
Terminal task error: Task 'examples.permanently_fails' ...
Failure type: RuntimeError
Attempt count: 3/3
```

Worker statistics should include:

```text
completed_tasks=0
failed_tasks=1
retry_attempts=2
```

---

## Step 7: Verify Graceful and Forced Shutdown

### The Target

Demonstrate both shutdown modes:

1. graceful drain with enough time;
2. forced cancellation when the shutdown deadline expires.

### The Concept

A robust service needs a shutdown policy.

### Graceful shutdown

```text
Stop accepting new work
        ↓
Finish already accepted work
        ↓
Stop consumers
```

### Forced shutdown

```text
Graceful shutdown begins
        ↓
Deadline expires
        ↓
Cancel active work
        ↓
Cancel still-queued work
        ↓
Stop consumers
```

A shutdown deadline is essential in deployments. Container orchestrators such as Kubernetes and process managers eventually terminate applications that do not stop.

### The Implementation

Create this example.

## `examples/34_shutdown_modes.py`

```python
"""Demonstrate graceful draining and forced worker cancellation."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.result import TaskCancelledError, TaskState
from pulsequeue.worker import PulseQueueWorker


app = PulseQueue("shutdown_demo")


@app.task(queue="examples")
async def short_task(value: int) -> int:
    """Finish quickly enough for graceful shutdown."""
    await asyncio.sleep(0.02)
    return value * 2


@app.task(queue="examples")
async def long_task() -> str:
    """Run long enough to exceed the forced-shutdown deadline."""
    await asyncio.sleep(5)
    return "completed"


async def graceful_shutdown_demo() -> None:
    """Stop after accepted short work has drained."""
    print("\n--- Graceful shutdown ---")

    broker = InMemoryBroker()
    worker = PulseQueueWorker(app, broker, concurrency=2)

    await worker.start()

    receipts = [
        await app.submit(broker, "examples.short_task", value)
        for value in range(3)
    ]

    await worker.stop(timeout_seconds=1.0)

    results = [
        await receipt.result(timeout_seconds=1.0)
        for receipt in receipts
    ]

    print(f"Graceful results: {results}")
    print(f"Worker state: {worker.state}")
    print(f"Worker statistics: {worker.stats()}")


async def forced_shutdown_demo() -> None:
    """Cancel long-running work when the shutdown deadline expires."""
    print("\n--- Forced shutdown ---")

    broker = InMemoryBroker()
    worker = PulseQueueWorker(app, broker, concurrency=1)

    await worker.start()

    receipt = await app.submit(broker, "examples.long_task")

    # Give the consumer a brief opportunity to begin task execution.
    await asyncio.sleep(0.02)

    await worker.stop(timeout_seconds=0.05)

    snapshot = receipt.snapshot()

    print(f"Task state after forced shutdown: {snapshot.state}")
    print(f"Worker state: {worker.state}")
    print(f"Worker statistics: {worker.stats()}")

    try:
        await receipt.result(timeout_seconds=0.1)
    except TaskCancelledError:
        print("Receipt correctly reported task cancellation.")

    assert snapshot.state is TaskState.CANCELLED


async def main() -> None:
    """Run both shutdown demonstrations."""
    await graceful_shutdown_demo()
    await forced_shutdown_demo()


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/34_shutdown_modes.py
```

Expected output includes:

```text
--- Graceful shutdown ---
Graceful results: [0, 2, 4]
Worker state: stopped

--- Forced shutdown ---
Task state after forced shutdown: cancelled
Worker state: stopped
Receipt correctly reported task cancellation.
```

The exact counter values depend on timing, but the forced task must finish in `cancelled` state.

---

## Step 8: Add Tests for Retries and Shutdown

### The Target

Add automated regression tests for retry behavior and forced cancellation.

### The Concept

Retry and shutdown logic contains state transitions that are easy to break:

- a retry may fail to increment attempts;
- a successful retry may still retain failure state;
- retry exhaustion may never become terminal;
- cancellation may leave receipt holders waiting;
- shutdown may leave queue accounting incomplete.

Tests make these contracts executable.

### The Implementation

Create this test module.

## `tests/test_retries_and_shutdown.py`

```python
"""Tests for retry, backoff, graceful drain, and forced cancellation."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.result import TaskCancelledError, TaskFailureError, TaskState
from pulsequeue.worker import PulseQueueWorker, WorkerState


def test_task_succeeds_after_retry() -> None:
    """A transient failure should succeed within the configured retry budget."""

    async def run_test() -> None:
        app = PulseQueue("retry_success")
        broker = InMemoryBroker()
        attempts = {"count": 0}

        @app.task(
            queue="examples",
            max_retries=2,
            retry_delay_seconds=0.001,
        )
        async def transient_failure() -> str:
            attempts["count"] += 1

            if attempts["count"] < 3:
                raise ConnectionError("temporary failure")

            return "recovered"

        async with PulseQueueWorker(app, broker) as worker:
            receipt = await app.submit(broker, "examples.transient_failure")

            assert await receipt.result(timeout_seconds=1.0) == "recovered"

            snapshot = receipt.snapshot()
            assert snapshot.state is TaskState.SUCCEEDED
            assert snapshot.attempt == 3
            assert snapshot.max_attempts == 3
            assert worker.stats().retry_attempts == 2

    asyncio.run(run_test())


def test_task_fails_after_retry_budget_exhaustion() -> None:
    """A permanent failure should become terminal after all attempts run."""

    async def run_test() -> None:
        app = PulseQueue("retry_failure")
        broker = InMemoryBroker()
        attempts = {"count": 0}

        @app.task(
            queue="examples",
            max_retries=1,
            retry_delay_seconds=0.001,
        )
        async def permanent_failure() -> None:
            attempts["count"] += 1
            raise RuntimeError("still broken")

        async with PulseQueueWorker(app, broker):
            receipt = await app.submit(broker, "examples.permanent_failure")

            with pytest.raises(TaskFailureError, match="still broken"):
                await receipt.result(timeout_seconds=1.0)

            snapshot = receipt.snapshot()
            assert snapshot.state is TaskState.FAILED
            assert snapshot.attempt == 2
            assert snapshot.max_attempts == 2
            assert attempts["count"] == 2

    asyncio.run(run_test())


def test_zero_retries_means_one_total_attempt() -> None:
    """A task with zero retries should fail immediately after one attempt."""

    async def run_test() -> None:
        app = PulseQueue("zero_retries")
        broker = InMemoryBroker()
        attempts = {"count": 0}

        @app.task(queue="examples", max_retries=0)
        async def fail_once() -> None:
            attempts["count"] += 1
            raise RuntimeError("no retry allowed")

        async with PulseQueueWorker(app, broker):
            receipt = await app.submit(broker, "examples.fail_once")

            with pytest.raises(TaskFailureError):
                await receipt.result(timeout_seconds=1.0)

            assert attempts["count"] == 1
            assert receipt.snapshot().max_attempts == 1

    asyncio.run(run_test())


def test_forced_shutdown_cancels_active_task() -> None:
    """A shutdown deadline should cancel work that does not finish in time."""

    async def run_test() -> None:
        app = PulseQueue("forced_shutdown")
        broker = InMemoryBroker()

        @app.task(queue="examples")
        async def long_running_task() -> None:
            await asyncio.sleep(10)

        worker = PulseQueueWorker(app, broker)
        await worker.start()

        receipt = await app.submit(broker, "examples.long_running_task")

        await asyncio.sleep(0.01)
        await worker.stop(timeout_seconds=0.01)

        assert worker.state is WorkerState.STOPPED
        assert receipt.snapshot().state is TaskState.CANCELLED

        with pytest.raises(TaskCancelledError):
            await receipt.result(timeout_seconds=0.1)

    asyncio.run(run_test())
```

### The Verification

Run the complete test suite:

```bash
python -m pytest -q
```

Expected result:

```text
...................................                                    [100%]
35 passed
```

The exact count may vary if you created additional tests. The required outcome is that all tests pass.

---

# Phase 2 Reference: Retry and Shutdown Design

## Retryable Errors Versus Permanent Errors

The current tutorial worker retries every ordinary `Exception`.

That is intentionally simple, but a production worker should normally retry only specific errors.

Usually retryable:

```text
ConnectionError
TimeoutError
Temporary DNS failure
HTTP 429 rate limiting
HTTP 503 service unavailable
Database connection reset
```

Usually not retryable:

```text
TypeError caused by invalid application code
ValueError from invalid input
Authentication failure
Permission failure
Schema validation failure
Unknown task name
```

A future production extension should support a task policy such as:

```python
retry_for=(ConnectionError, TimeoutError)
do_not_retry_for=(ValueError, PermissionError)
```

The key principle is:

> Retrying a permanent failure wastes capacity and delays useful error reporting.

---

## Why Exponential Backoff Matters

Without backoff, many workers can repeatedly hit an unhealthy dependency:

```text
1,000 tasks fail
        ↓
1,000 immediate retries
        ↓
Dependency receives another spike
        ↓
Outage becomes worse
```

Backoff spreads retry traffic over time.

In distributed systems, add **jitter**, a small random adjustment to delay values. Jitter prevents many workers from retrying in synchronized waves.

For example:

```text
Base delay: 1.0 second
Jittered delays: 0.84, 1.12, 0.93, 1.07 seconds
```

This tutorial intentionally uses deterministic delays so verification output remains predictable.

---

## Graceful Shutdown Guarantees

The worker’s shutdown behavior is:

| Situation | Behavior |
|---|---|
| `stop()` with no timeout | Wait indefinitely for accepted work and retries to finish |
| `stop(timeout_seconds=5)` and work finishes in time | Drain work normally |
| Deadline expires | Cancel active consumers |
| Active task is cancelled | Receipt becomes `CANCELLED` |
| Queued task was not started | Broker marks receipt `CANCELLED` |
| Broker receives stop signal | Consumer exits cleanly |

A real deployment must choose a timeout appropriate for its environment. For example, if Kubernetes grants a pod 30 seconds to terminate, configure the worker deadline to be slightly shorter than 30 seconds.

---

## Important Limitation of In-Memory Retries

PulseQueue currently waits for retry delays inside a worker coroutine.

This is suitable for a learning framework but has an operational drawback:

```text
Worker slot starts task
        ↓
Task fails
        ↓
Worker slot waits during backoff
        ↓
That slot cannot process another task
```

A production distributed queue commonly uses delayed messages:

```text
Task fails
        ↓
Broker schedules message for future delivery
        ↓
Worker slot becomes available immediately
```

That design requires durable message storage and clock-aware scheduling, which we will revisit as the architecture evolves.
