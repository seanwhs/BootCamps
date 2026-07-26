# Part 6: Building the In-Memory Broker, Task Envelopes, Result States, and Async Workers

So far, calling a task executes it immediately:

```python
result = await send_welcome_email(42)
```

That is useful for direct testing, but it is not a task queue.

A queue-based system separates the person submitting work from the worker performing work:

```text
Application submits task
        ↓
Broker stores task envelope
        ↓
Worker receives envelope
        ↓
Worker finds registered task
        ↓
Worker executes task
        ↓
Result is stored for caller
```

This part creates the first working PulseQueue execution pipeline:

```python
receipt = await app.submit(
    broker,
    "emails.send_welcome_email",
    42,
)

result = await receipt.result()
```

The system will remain intentionally in-memory for now. That means restarting the Python process loses queued tasks and results. A durable broker such as Redis, RabbitMQ, PostgreSQL, or Kafka would be needed for distributed production reliability.

However, the architecture we build now provides the correct boundaries for adding durable storage later.

---

## Step 1: Define Task Lifecycle States

### The Target

Create explicit task result states and structured failure information.

### The Concept

A queued task moves through a lifecycle:

```text
QUEUED → RUNNING → SUCCEEDED
                 ↘ FAILED
                 ↘ CANCELLED
```

A lifecycle state is like a package-tracking status:

| State | Meaning |
|---|---|
| `QUEUED` | The task has been accepted and is waiting for a worker. |
| `RUNNING` | A worker has started execution. |
| `SUCCEEDED` | The task completed and produced a result. |
| `FAILED` | The task raised an exception or exceeded a timeout. |
| `CANCELLED` | Execution was cancelled before normal completion. |

We will also store failures in a serializable form rather than retaining raw exception objects. Raw exceptions can hold large object graphs, file handles, stack frames, or sensitive local data. A small structured failure record is safer for logs, APIs, and future durable result backends.

### The Implementation

Create the result module.

## `src/pulsequeue/result.py`

```python
"""Task result state, receipts, and result-store primitives."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any, Generic, TypeVar

ResultT = TypeVar("ResultT")


class TaskState(StrEnum):
    """Represent the lifecycle state of one submitted task."""

    QUEUED = "queued"
    RUNNING = "running"
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
    """An immutable point-in-time view of a task's execution state."""

    task_id: str
    task_name: str
    state: TaskState
    submitted_at: datetime
    started_at: datetime | None
    completed_at: datetime | None
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
    """Raised when a receipt references a result no longer held by the broker."""


@dataclass(slots=True)
class _MutableTaskResult(Generic[ResultT]):
    """Internal mutable task state owned only by InMemoryResultStore."""

    task_id: str
    task_name: str
    state: TaskState
    submitted_at: datetime
    started_at: datetime | None = None
    completed_at: datetime | None = None
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
        """Wait for and return the final task result.

        A timeout of zero means wait indefinitely. Failed and cancelled tasks
        raise framework-specific exceptions instead of returning invalid data.
        """
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

    def create(self, *, task_id: str, task_name: str) -> None:
        """Create the initial QUEUED result record for a submitted task."""
        if task_id in self._results:
            raise ValueError(f"Task result {task_id!r} already exists.")

        self._results[task_id] = _MutableTaskResult(
            task_id=task_id,
            task_name=task_name,
            state=TaskState.QUEUED,
            submitted_at=datetime.now(UTC),
        )
        self._completion_events[task_id] = asyncio.Event()

    def mark_running(self, task_id: str) -> None:
        """Transition a queued task into RUNNING state."""
        result = self._get_mutable_result(task_id)

        if result.state is not TaskState.QUEUED:
            raise RuntimeError(
                f"Cannot mark task {task_id!r} running from state {result.state!r}."
            )

        result.state = TaskState.RUNNING
        result.started_at = datetime.now(UTC)

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store a successful result and notify waiting receipt holders."""
        result = self._get_mutable_result(task_id)
        self._assert_running(result)

        result.state = TaskState.SUCCEEDED
        result.value = value
        result.completed_at = datetime.now(UTC)
        self._completion_events[task_id].set()

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store safe failure details and notify waiting receipt holders."""
        result = self._get_mutable_result(task_id)
        self._assert_running(result)

        result.state = TaskState.FAILED
        result.failure = TaskFailure(
            exception_type=type(exception).__name__,
            message=str(exception),
        )
        result.completed_at = datetime.now(UTC)
        self._completion_events[task_id].set()

    def mark_cancelled(self, task_id: str) -> None:
        """Store cancellation state and notify waiting receipt holders."""
        result = self._get_mutable_result(task_id)
        self._assert_running(result)

        result.state = TaskState.CANCELLED
        result.completed_at = datetime.now(UTC)
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
        """Ensure terminal transitions happen only from RUNNING."""
        if result.state is not TaskState.RUNNING:
            raise RuntimeError(
                f"Cannot complete task {result.task_id!r} from state "
                f"{result.state!r}; expected {TaskState.RUNNING!r}."
            )
```

### The Verification

Create the following result-store demonstration.

## `examples/25_task_result_states.py`

```python
"""Demonstrate task-result lifecycle state transitions."""

from __future__ import annotations

import asyncio

from pulsequeue.result import InMemoryResultStore, TaskReceipt


async def main() -> None:
    """Create, complete, and retrieve one task result."""
    result_store = InMemoryResultStore()

    task_id = "demo-task-001"
    task_name = "examples.say_hello"

    result_store.create(
        task_id=task_id,
        task_name=task_name,
    )

    receipt = TaskReceipt[str](
        result_store,
        task_id=task_id,
        task_name=task_name,
    )

    print(f"Initial state: {receipt.snapshot().state}")

    result_store.mark_running(task_id)
    print(f"Running state: {receipt.snapshot().state}")

    result_store.mark_succeeded(task_id, "hello from PulseQueue")
    print(f"Final state: {receipt.snapshot().state}")

    result = await receipt.result()
    print(f"Final value: {result}")


if __name__ == "__main__":
    asyncio.run(main())
```

Run:

```bash
python examples/25_task_result_states.py
```

Expected output:

```text
Initial state: queued
Running state: running
Final state: succeeded
Final value: hello from PulseQueue
```

---

## Step 2: Create an Immutable Task Envelope

### The Target

Create the message object that travels through the broker queue.

### The Concept

A **task envelope** is the package carried through the queue.

It contains the information a worker needs to execute one submitted task:

```text
Task ID
Task name
Positional arguments
Keyword arguments
Submission timestamp
```

The envelope does not contain the actual Python `Task` object. That separation is intentional.

In a future distributed version, a producer and worker may run in different processes or on different machines. The worker should receive a compact task message, then use its own registry to look up the executable task definition by name.

Think of it like a restaurant ticket:

```text
Order number: 104
Dish: emails.send_welcome_email
Arguments: user_id=42
```

The ticket does not contain the chef. It tells the kitchen what the chef should prepare.

### The Implementation

Create the envelope module.

## `src/pulsequeue/envelope.py`

```python
"""Task messages that move from producers through the broker to workers."""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from datetime import datetime
from types import MappingProxyType
from typing import Any


@dataclass(frozen=True, slots=True)
class TaskEnvelope:
    """An immutable in-memory message describing one requested task execution."""

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
        """Create an envelope with defensive copies of caller-owned arguments."""
        if not task_id:
            raise ValueError("task_id cannot be empty.")

        if not task_name:
            raise ValueError("task_name cannot be empty.")

        # A tuple prevents later changes to the outer positional-argument
        # container. MappingProxyType prevents later changes to the outer
        # keyword-argument container. Nested mutable values remain the caller's
        # responsibility in this in-memory tutorial implementation.
        return cls(
            task_id=task_id,
            task_name=task_name,
            args=tuple(args),
            kwargs=MappingProxyType(dict(kwargs)),
            submitted_at=submitted_at,
        )
```

### The Verification

Create this example.

## `examples/26_task_envelope.py`

```python
"""Demonstrate immutable task-envelope construction."""

from __future__ import annotations

from datetime import UTC, datetime

from pulsequeue.envelope import TaskEnvelope


envelope = TaskEnvelope.create(
    task_id="task-123",
    task_name="emails.send_welcome_email",
    args=(42,),
    kwargs={"locale": "en-GB"},
    submitted_at=datetime.now(UTC),
)

print(f"Task ID: {envelope.task_id}")
print(f"Task name: {envelope.task_name}")
print(f"Arguments: {envelope.args}")
print(f"Keyword arguments: {dict(envelope.kwargs)}")

try:
    envelope.kwargs["locale"] = "fr-FR"
except TypeError as error:
    print(f"Immutable keyword-arguments error: {error}")
```

### The Verification

Run:

```bash
python examples/26_task_envelope.py
```

Expected output includes:

```text
Task ID: task-123
Task name: emails.send_welcome_email
Arguments: (42,)
Keyword arguments: {'locale': 'en-GB'}
Immutable keyword-arguments error: 'mappingproxy' object does not support item assignment
```

---

## Step 3: Build the In-Memory Broker

### The Target

Create the broker that accepts task envelopes, applies queue backpressure, and creates receipts.

### The Concept

The broker is the loading dock between task producers and workers.

Its responsibilities are intentionally narrow:

1. Accept a validated task submission.
2. Create a unique task identifier.
3. Create a result record in `QUEUED` state.
4. Package the call into a `TaskEnvelope`.
5. Place the envelope into a bounded asynchronous queue.
6. Return a `TaskReceipt` to the caller.

The broker does **not** execute tasks. Workers do that.

Keeping these responsibilities separate is important because a future durable broker can replace only this component without rewriting task definitions or worker logic.

### The Implementation

Create the broker module.

## `src/pulsequeue/broker.py`

```python
"""An in-memory broker for PulseQueue task envelopes."""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from pulsequeue.async_queue import AsyncWorkQueue, QueueStats
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.result import InMemoryResultStore, TaskReceipt


class InMemoryBroker:
    """Queue task envelopes in memory and retain associated task results.

    This broker is process-local and non-durable. It is suitable for tutorial
    development, tests, and single-process demonstrations. Restarting Python
    loses pending messages and all stored results.
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
    ) -> TaskReceipt[Any]:
        """Create and enqueue one task envelope.

        The caller must validate task existence and callable arguments before
        submission. That responsibility belongs to the application layer,
        which owns the task registry.
        """
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
        )

        try:
            # This await provides backpressure when the bounded queue is full.
            await self._queue.put(envelope)
        except BaseException:
            # The result record would otherwise remain permanently QUEUED if
            # queue submission is cancelled or fails. This tutorial store has
            # no deletion API yet, so mark the record as a terminal failure
            # after moving it into RUNNING for its state-machine contract.
            self._result_store.mark_running(task_id)
            self._result_store.mark_failed(
                task_id,
                RuntimeError("Task submission failed before broker enqueue."),
            )
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

    def mark_running(self, task_id: str) -> None:
        """Mark a broker-owned task result as running."""
        self._result_store.mark_running(task_id)

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        """Store a successful worker result."""
        self._result_store.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        """Store a worker failure."""
        self._result_store.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        """Store worker cancellation."""
        self._result_store.mark_cancelled(task_id)
```

### The Verification

Create the broker-only demonstration.

## `examples/27_in_memory_broker.py`

```python
"""Submit a task envelope to the in-memory broker without a worker."""

from __future__ import annotations

import asyncio

from pulsequeue.broker import InMemoryBroker


async def main() -> None:
    """Submit one task and inspect the queued broker state."""
    broker = InMemoryBroker(max_queue_size=2)

    receipt = await broker.submit(
        task_name="emails.send_welcome_email",
        args=(42,),
        kwargs={"locale": "en-US"},
    )

    print(f"Receipt: {receipt!r}")
    print(f"Initial task state: {receipt.snapshot().state}")
    print(f"Broker stats: {broker.stats()}")

    # A worker would normally call broker.get(). We do so manually only to
    # inspect the queued task envelope in this broker-focused example.
    envelope = await broker.get()

    try:
        print(f"Retrieved envelope: {envelope!r}")
        print(f"Broker stats while processing: {broker.stats()}")
    finally:
        broker.task_done()

    await broker.join()
    print(f"Broker stats after completion accounting: {broker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/27_in_memory_broker.py
```

Expected output includes:

```text
Receipt: TaskReceipt(task_id='...', task_name='emails.send_welcome_email')
Initial task state: queued
Broker stats: QueueStats(max_size=2, queued_items=1, unfinished_tasks=1, is_closed=False)
Retrieved envelope: TaskEnvelope(...)
Broker stats after completion accounting: QueueStats(max_size=2, queued_items=0, unfinished_tasks=0, is_closed=False)
```

The task remains in `queued` state because no worker executed it yet.

---

## Step 4: Add Submission Support to `PulseQueue`

### The Target

Extend `PulseQueue` so application code can submit registered tasks through a broker safely.

### The Concept

The application owns the task registry. Therefore, it is the correct place to validate:

- the requested task exists;
- submitted positional and keyword arguments match the function signature;
- the task name is canonical.

This gives callers an immediate, clear error:

```python
await app.submit(broker, "emails.send_welcome_email")
```

instead of accepting invalid work and discovering the problem later inside a worker.

Think of this layer as an airport check-in counter. It verifies the passenger’s ticket and destination before allowing luggage into the baggage system.

### The Implementation

Replace the complete application module.

## `src/pulsequeue/app.py`

```python
"""The public PulseQueue application object."""

from __future__ import annotations

from collections.abc import Awaitable, Callable, Mapping
from typing import Any, ParamSpec, TypeVar

from pulsequeue.broker import InMemoryBroker
from pulsequeue.metadata import TaskMetadata
from pulsequeue.namespace import AttributeNamespace
from pulsequeue.options import TaskOptions
from pulsequeue.registry import TaskRegistry
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
        """Expose registered tasks through a fresh read-only namespace snapshot."""
        return self._registry.namespace(name=f"{self._name}.tasks")

    @property
    def task_count(self) -> int:
        """Return the number of tasks currently registered."""
        return len(self._registry)

    def registered_tasks(self) -> Mapping[str, Task[Any, Any]]:
        """Return an immutable snapshot of all registered tasks."""
        return self._registry.all()

    def get_task(self, name: str) -> Task[Any, Any]:
        """Look up a registered task using its queue-qualified name."""
        return self._registry.get(name)

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
        )

    def task(
        self,
        *,
        queue: str,
        name: str | None = None,
        max_retries: int = 1,
        timeout_seconds: float = 0.0,
        metadata: TaskMetadata | None = None,
    ) -> Callable[
        [Callable[ParametersT, Awaitable[ResultT]]],
        Task[ParametersT, ResultT],
    ]:
        """Return a decorator that registers one asynchronous function."""
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

        def register_function(
            function: Callable[ParametersT, Awaitable[ResultT]],
        ) -> Task[ParametersT, ResultT]:
            """Convert one function into a validated and registered Task."""
            task_name = name if name is not None else function.__name__

            options = TaskOptions(
                name=task_name,
                queue=queue,
                max_retries=max_retries,
                timeout_seconds=timeout_seconds,
                metadata=metadata,
            )

            task_definition = Task(function, options)
            self._registry.register(task_definition)

            return task_definition

        return register_function

    def describe(self) -> dict[str, Any]:
        """Return application and task metadata for diagnostics."""
        return {
            "name": self._name,
            "task_count": self.task_count,
            "tasks": {
                task_name: task.describe()
                for task_name, task in self.registered_tasks().items()
            },
        }

    def __repr__(self) -> str:
        """Return a concise application representation for logs and debuggers."""
        return f"{type(self).__name__}(name={self._name!r}, task_count={self.task_count})"
```

### The Verification

Create this application-submission example.

## `examples/28_application_submission.py`

```python
"""Validate and submit a registered task without starting a worker."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker


app = PulseQueue("notifications")


@app.task(queue="emails")
async def send_welcome_email(user_id: int, *, locale: str = "en-US") -> str:
    """Return a welcome-email message when a worker eventually executes it."""
    return f"Welcome email for user={user_id}, locale={locale}"


async def main() -> None:
    """Submit valid work and demonstrate caller-side signature validation."""
    broker = InMemoryBroker()

    receipt = await app.submit(
        broker,
        "emails.send_welcome_email",
        42,
        locale="en-GB",
    )

    print(f"Submitted task receipt: {receipt!r}")
    print(f"Task state before worker start: {receipt.snapshot().state}")

    try:
        await app.submit(
            broker,
            "emails.send_welcome_email",
            locale="en-GB",
        )
    except TypeError as error:
        print(f"Invalid-call error: {error}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/28_application_submission.py
```

Expected output includes:

```text
Submitted task receipt: TaskReceipt(task_id='...', task_name='emails.send_welcome_email')
Task state before worker start: queued
Invalid-call error: missing a required argument: 'user_id'
```

---

## Step 5: Build the Async Worker

### The Target

Create a worker that consumes broker envelopes, finds registered tasks, applies timeouts, stores results, and shuts down cleanly.

### The Concept

A worker is the kitchen in the task-queue restaurant analogy.

The broker has tickets. The worker:

1. takes the next ticket;
2. finds the corresponding recipe;
3. prepares it;
4. records success or failure;
5. marks the ticket as completed;
6. takes the next ticket.

We will support configurable concurrency:

```python
PulseQueueWorker(
    app,
    broker,
    concurrency=4,
)
```

That starts four asynchronous consumer loops. They can efficiently overlap I/O-bound tasks.

This worker is intentionally for coroutine tasks only. CPU-bound and blocking-I/O execution paths will be integrated later using the explicit workload boundaries introduced in Part 4.

### The Implementation

Create the worker module.

## `src/pulsequeue/worker.py`

```python
"""Asynchronous in-memory task workers for PulseQueue."""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from enum import StrEnum
from typing import Any

from pulsequeue.app import PulseQueue
from pulsequeue.async_queue import STOP_SIGNAL
from pulsequeue.broker import InMemoryBroker
from pulsequeue.envelope import TaskEnvelope
from pulsequeue.registry import UnknownTaskError
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

    @property
    def state(self) -> WorkerState:
        """Return the current worker lifecycle state."""
        return self._state

    @property
    def is_running(self) -> bool:
        """Return whether consumer loops are actively accepting broker messages."""
        return self._state is WorkerState.RUNNING

    def stats(self) -> WorkerStats:
        """Return a stable snapshot of worker counters."""
        return WorkerStats(
            state=self._state,
            concurrency=self._concurrency,
            completed_tasks=self._completed_tasks,
            failed_tasks=self._failed_tasks,
            cancelled_tasks=self._cancelled_tasks,
        )

    async def start(self) -> None:
        """Start one consumer coroutine for each configured concurrency slot."""
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

    async def stop(self) -> None:
        """Stop accepting new work, drain queued messages, and end consumers."""
        if self._state is WorkerState.STOPPED:
            return

        if self._state is WorkerState.CREATED:
            self._state = WorkerState.STOPPED
            return

        if self._state is not WorkerState.RUNNING:
            raise RuntimeError(
                f"Worker cannot stop from state {self._state!r}."
            )

        self._state = WorkerState.STOPPING

        # stop_workers closes broker submissions and adds one stop signal per
        # consumer after already queued tasks. This produces graceful draining.
        await self._broker.stop_workers(worker_count=self._concurrency)

        # Wait until every normal message and every stop signal has been marked
        # task_done by a consumer loop.
        await self._broker.join()

        # If a consumer loop unexpectedly raised, gather propagates that error
        # instead of silently pretending shutdown succeeded.
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
        traceback: object | None,
    ) -> None:
        """Drain and stop the worker when leaving an async context."""
        await self.stop()

    async def _consume_forever(self, worker_number: int) -> None:
        """Receive and execute task envelopes until this consumer gets a stop signal."""
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
                # including stop signals and unexpected message types.
                self._broker.task_done()

    async def _execute_envelope(self, envelope: TaskEnvelope) -> None:
        """Resolve, execute, and record the outcome of one task envelope."""
        self._broker.mark_running(envelope.task_id)

        try:
            task = self._app.get_task(envelope.task_name)

            result = await await_with_timeout(
                task(*envelope.args, **dict(envelope.kwargs)),
                timeout_seconds=task.options.timeout_seconds,
                operation_name=envelope.task_name,
            )
        except asyncio.CancelledError:
            # Cancellation must propagate so asyncio can stop this consumer.
            # We still record the state first so receipt holders are not left
            # waiting forever.
            self._broker.mark_cancelled(envelope.task_id)
            self._cancelled_tasks += 1
            raise
        except (Exception, UnknownTaskError) as error:
            # UnknownTaskError is already an Exception subclass. It is listed
            # here for readability because task-registry mismatches are an
            # important operational failure mode in distributed systems.
            self._broker.mark_failed(envelope.task_id, error)
            self._failed_tasks += 1
        else:
            self._broker.mark_succeeded(envelope.task_id, result)
            self._completed_tasks += 1
```

### The Verification

Create the first complete queue-and-worker example.

## `examples/29_first_async_worker.py`

```python
"""Submit several tasks and process them through a PulseQueue worker."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.worker import PulseQueueWorker


app = PulseQueue("notifications")


@app.task(queue="emails", timeout_seconds=1.0)
async def send_welcome_email(user_id: int, *, locale: str = "en-US") -> str:
    """Simulate a network-bound email submission."""
    await asyncio.sleep(0.05)
    return f"welcome email sent to user={user_id}, locale={locale}"


@app.task(queue="maintenance", timeout_seconds=1.0)
async def cleanup_expired_sessions(max_age_days: int) -> int:
    """Simulate a short maintenance operation."""
    await asyncio.sleep(0.02)
    return max_age_days * 3


async def main() -> None:
    """Start workers, submit work, await receipts, and stop gracefully."""
    broker = InMemoryBroker(max_queue_size=10)

    async with PulseQueueWorker(app, broker, concurrency=2) as worker:
        email_receipt = await app.submit(
            broker,
            "emails.send_welcome_email",
            42,
            locale="en-GB",
        )

        cleanup_receipt = await app.submit(
            broker,
            "maintenance.cleanup_expired_sessions",
            14,
        )

        email_result, cleanup_result = await asyncio.gather(
            email_receipt.result(timeout_seconds=2.0),
            cleanup_receipt.result(timeout_seconds=2.0),
        )

        print(f"Email result: {email_result}")
        print(f"Cleanup result: {cleanup_result}")
        print(f"Email state: {email_receipt.snapshot().state}")
        print(f"Cleanup state: {cleanup_receipt.snapshot().state}")
        print(f"Worker stats before shutdown: {worker.stats()}")

    print(f"Worker state after context exit: {worker.state}")
    print(f"Broker stats after context exit: {broker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/29_first_async_worker.py
```

Expected output includes:

```text
Email result: welcome email sent to user=42, locale=en-GB
Cleanup result: 42
Email state: succeeded
Cleanup state: succeeded
Worker stats before shutdown: WorkerStats(state=<WorkerState.RUNNING: 'running'>, concurrency=2, completed_tasks=2, failed_tasks=0, cancelled_tasks=0)
Worker state after context exit: stopped
Broker stats after context exit: QueueStats(max_size=10, queued_items=0, unfinished_tasks=0, is_closed=True)
```

The order in which results become available can vary because two workers execute concurrently.

---

## Step 6: Verify Failures and Timeouts

### The Target

Confirm that task failures and task timeouts become terminal result states instead of crashing the entire worker.

### The Concept

A worker must distinguish between:

- a task failing;
- the worker itself failing.

If one task raises an exception, that is normally a task-level failure. The worker should record it, continue processing later messages, and let the caller inspect the failure through its receipt.

Likewise, a task timeout should mark only that task as failed.

Think of a restaurant kitchen: one incorrect order should be reported and remade. It should not force every cook to leave the kitchen.

### The Implementation

Create this example.

## `examples/30_task_failures_and_timeouts.py`

```python
"""Demonstrate task failure and timeout result handling."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.result import TaskFailureError
from pulsequeue.worker import PulseQueueWorker


app = PulseQueue("failure_demo")


@app.task(queue="examples")
async def always_fails() -> str:
    """Raise a predictable application error."""
    await asyncio.sleep(0)
    raise ValueError("The example task failed intentionally.")


@app.task(queue="examples", timeout_seconds=0.02)
async def always_times_out() -> str:
    """Sleep longer than the task configuration allows."""
    await asyncio.sleep(0.2)
    return "This result is never returned."


@app.task(queue="examples")
async def succeeds_after_failures(value: int) -> int:
    """Show that the worker continues after previous task failures."""
    await asyncio.sleep(0)
    return value * 2


async def main() -> None:
    """Submit failing, timing-out, and successful work to one worker."""
    broker = InMemoryBroker()

    async with PulseQueueWorker(app, broker) as worker:
        failing_receipt = await app.submit(broker, "examples.always_fails")
        timeout_receipt = await app.submit(broker, "examples.always_times_out")
        success_receipt = await app.submit(
            broker,
            "examples.succeeds_after_failures",
            21,
        )

        for receipt in (failing_receipt, timeout_receipt):
            try:
                await receipt.result(timeout_seconds=1.0)
            except TaskFailureError as error:
                print(f"Task failure: {error}")
                print(f"Recorded failure type: {error.failure.exception_type}")

        successful_result = await success_receipt.result(timeout_seconds=1.0)

        print(f"Successful result after failures: {successful_result}")
        print(f"Worker stats: {worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/30_task_failures_and_timeouts.py
```

Expected output includes:

```text
Task failure: Task 'examples.always_fails' ... failed with ValueError: The example task failed intentionally.
Recorded failure type: ValueError
Task failure: Task 'examples.always_times_out' ... failed with OperationTimeoutError:
Recorded failure type: OperationTimeoutError
Successful result after failures: 42
```

The worker statistics should show:

```text
completed_tasks=1
failed_tasks=2
cancelled_tasks=0
```

This confirms the worker survived two task failures and processed the next task normally.

---

## Step 7: Add Automated Tests for Broker and Worker Behavior

### The Target

Protect the new execution pipeline with tests.

### The Concept

The broker-worker boundary is where framework correctness becomes operational correctness.

The following behaviors are essential:

- submitted tasks begin in `QUEUED`;
- workers execute registered tasks;
- successful results return to callers;
- failures become `TaskFailureError`;
- invalid submission arguments fail before enqueueing;
- graceful worker shutdown drains accepted work.

### The Implementation

Create the test module.

## `tests/test_broker_and_worker.py`

```python
"""Tests for in-memory task submission, execution, and result handling."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue import PulseQueue
from pulsequeue.broker import InMemoryBroker
from pulsequeue.result import TaskFailureError, TaskState
from pulsequeue.worker import PulseQueueWorker, WorkerState


def test_broker_submission_creates_queued_receipt() -> None:
    """Submitting directly to the broker should create a queued result record."""

    async def run_test() -> None:
        broker = InMemoryBroker(max_queue_size=2)

        receipt = await broker.submit(
            task_name="examples.noop",
            args=(),
            kwargs={},
        )

        assert receipt.snapshot().state is TaskState.QUEUED
        assert broker.stats().queued_items == 1

        item = await broker.get()

        try:
            assert item is not None
        finally:
            broker.task_done()

        await broker.join()

    asyncio.run(run_test())


def test_worker_executes_submitted_registered_task() -> None:
    """A running worker should resolve a task and store its successful result."""

    async def run_test() -> None:
        app = PulseQueue("worker_success")
        broker = InMemoryBroker()

        @app.task(queue="math")
        async def add(left: int, right: int) -> int:
            return left + right

        async with PulseQueueWorker(app, broker) as worker:
            receipt = await app.submit(broker, "math.add", 20, 22)

            assert await receipt.result(timeout_seconds=1.0) == 42
            assert receipt.snapshot().state is TaskState.SUCCEEDED
            assert worker.stats().completed_tasks == 1

        assert worker.state is WorkerState.STOPPED

    asyncio.run(run_test())


def test_worker_records_task_failure_without_crashing() -> None:
    """A task exception should become a receipt error while worker stays alive."""

    async def run_test() -> None:
        app = PulseQueue("worker_failure")
        broker = InMemoryBroker()

        @app.task(queue="examples")
        async def fail() -> None:
            raise RuntimeError("intentional failure")

        @app.task(queue="examples")
        async def succeed() -> str:
            return "still running"

        async with PulseQueueWorker(app, broker) as worker:
            failed_receipt = await app.submit(broker, "examples.fail")
            success_receipt = await app.submit(broker, "examples.succeed")

            with pytest.raises(TaskFailureError, match="intentional failure"):
                await failed_receipt.result(timeout_seconds=1.0)

            assert await success_receipt.result(timeout_seconds=1.0) == "still running"
            assert worker.stats().failed_tasks == 1
            assert worker.stats().completed_tasks == 1

    asyncio.run(run_test())


def test_application_rejects_invalid_arguments_before_enqueueing() -> None:
    """Bad calls should not consume broker capacity or create queued messages."""

    async def run_test() -> None:
        app = PulseQueue("argument_validation")
        broker = InMemoryBroker()

        @app.task(queue="examples")
        async def needs_value(value: int) -> int:
            return value

        with pytest.raises(TypeError, match="missing a required argument"):
            await app.submit(broker, "examples.needs_value")

        assert broker.stats().queued_items == 0
        assert broker.stats().unfinished_tasks == 0

    asyncio.run(run_test())


def test_worker_stop_drains_already_accepted_work() -> None:
    """Graceful stop should finish queued work before consumers terminate."""

    async def run_test() -> None:
        app = PulseQueue("graceful_stop")
        broker = InMemoryBroker()

        @app.task(queue="examples")
        async def double(value: int) -> int:
            await asyncio.sleep(0.01)
            return value * 2

        worker = PulseQueueWorker(app, broker, concurrency=2)
        await worker.start()

        receipts = [
            await app.submit(broker, "examples.double", value)
            for value in range(5)
        ]

        await worker.stop()

        results = [await receipt.result(timeout_seconds=1.0) for receipt in receipts]

        assert results == [0, 2, 4, 6, 8]
        assert worker.state is WorkerState.STOPPED
        assert broker.is_closed is True
        assert broker.stats().unfinished_tasks == 0

    asyncio.run(run_test())
```

Update public exports.

## `src/pulsequeue/__init__.py`

```python
"""PulseQueue: an educational high-concurrency Python task framework."""

from pulsequeue.app import PulseQueue
from pulsequeue.execution import WorkloadKind
from pulsequeue.metadata import TaskMetadata
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
    "DuplicateTaskError",
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

Run the entire test suite:

```bash
python -m pytest -q
```

Expected result:

```text
...............................                                        [100%]
31 passed
```

The exact total may vary depending on your existing local tests. All tests must pass.

---

# Phase 2 Reference: Broker and Worker Architecture

## What Is In Memory?

The current implementation stores all of the following inside the current Python process:

```text
Task envelopes
Task results
Completion events
Task registry
Worker counters
```

This means the following is true:

```text
Python process exits → queued tasks are lost
Python process exits → results are lost
```

That is acceptable for learning, tests, single-process tools, and local development.

It is not sufficient for production workloads requiring durability.

---

## Why the Worker Uses a Task Name Instead of a Function Object

The broker envelope contains:

```python
task_name="emails.send_welcome_email"
```

instead of:

```python
task=<Python function object>
```

That design is essential for future scaling.

A durable broker must transmit data between processes or machines. Python function objects generally cannot be safely sent as task messages across those boundaries.

The worker instead performs this lookup:

```python
task = self._app.get_task(envelope.task_name)
```

This is the same broad pattern used by distributed job systems:

```text
Message says what should run
Worker registry knows how to run it
```

---

## Why Result Receipts Use Events

A `TaskReceipt` waits on an `asyncio.Event`.

An event begins unset:

```text
Task has not reached terminal state
```

The worker sets it after success, failure, or cancellation:

```text
Task has reached a terminal state
```

Many callers can wait on the same receipt concurrently:

```python
await asyncio.gather(
    receipt.result(),
    receipt.result(),
)
```

Both callers are notified when the worker records a terminal result.

---

## Task Failure Versus Worker Failure

These are different categories:

| Situation | Expected behavior |
|---|---|
| User task raises `ValueError` | Record task as failed; worker continues |
| User task exceeds configured timeout | Record task as failed; worker continues |
| Worker receives stop signal | Consumer exits gracefully |
| Worker process is forcibly terminated | In-memory work may be lost |
| Broker implementation crashes | Queue availability is compromised |

A robust system should isolate ordinary task failures from infrastructure failures. We have done that here by catching task exceptions inside `_execute_envelope(...)`.

---

## Known Limitation: No Retry Yet

Although `TaskOptions` already contains:

```python
max_retries
```

the worker does not yet retry failed tasks.

That is deliberate. Retrying safely requires additional concepts:

- attempt numbers;
- retry delay;
- retryable versus non-retryable exceptions;
- backoff strategies;
- cancellation behavior during delays;
- terminal failure after the final allowed attempt.

Those concerns will be implemented in the next concurrency layer rather than hidden behind incomplete retry behavior.
