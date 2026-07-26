# Part 5: `asyncio` Fundamentals for Reliable Concurrent Systems

We now know when threads and processes are appropriate. The next foundation is `asyncio`, Python’s built-in framework for high-concurrency asynchronous I/O.

`asyncio` is the execution model that will power the main PulseQueue worker loop.

A worker often spends much of its life waiting:

- waiting for a task to arrive;
- waiting for an HTTP response;
- waiting for a database query;
- waiting for a timeout;
- waiting for shutdown instructions.

Waiting is not inherently expensive. It becomes expensive when a program dedicates one operating-system thread to each waiting operation.

`asyncio` solves this by allowing one thread to coordinate many waiting operations. A coroutine voluntarily yields control whenever it reaches an `await` expression that waits for something external.

This part builds the concurrency tools we need before creating the actual broker and worker:

- coroutine and task lifecycle basics;
- concurrent execution with `asyncio.create_task`;
- timeout boundaries;
- cancellation-aware cleanup;
- bounded async queues;
- graceful draining of queued work.

---

## Step 1: Observe Cooperative Coroutine Scheduling

### The Target

Create a small program showing that coroutines make progress together only when they cooperate by awaiting.

### The Concept

An `async def` function creates a **coroutine function**.

Calling it creates a **coroutine object**:

```python
coroutine = fetch_profile(42)
```

The function body does not fully execute at that moment. An event loop must run the coroutine:

```python
result = await fetch_profile(42)
```

or:

```python
asyncio.run(main())
```

A coroutine gives control back to the event loop at an `await` point.

Think of an event loop as one restaurant server handling many tables:

1. The server takes an order from table A.
2. Table A is waiting for the kitchen.
3. Instead of standing beside table A, the server visits table B.
4. When food for table A is ready, the server returns.

A coroutine that performs long CPU work without `await` is like a server who refuses to leave one table until every detail is complete. Every other customer waits.

### The Implementation

Create this example.

## `examples/20_coroutine_scheduling.py`

```python
"""Demonstrate cooperative scheduling between asyncio coroutines."""

from __future__ import annotations

import asyncio


async def process_job(job_name: str, delay_seconds: float) -> str:
    """Simulate I/O work that cooperatively yields to the event loop."""
    print(f"{job_name}: started")

    # asyncio.sleep does not block the operating-system thread. Instead,
    # this coroutine pauses and allows the event loop to run other tasks.
    await asyncio.sleep(delay_seconds)

    print(f"{job_name}: completed")
    return f"{job_name} result"


async def main() -> None:
    """Create concurrent tasks and await all their results."""
    first_task = asyncio.create_task(
        process_job("email-job", 0.3),
        name="email-job",
    )
    second_task = asyncio.create_task(
        process_job("report-job", 0.1),
        name="report-job",
    )
    third_task = asyncio.create_task(
        process_job("cleanup-job", 0.2),
        name="cleanup-job",
    )

    results = await asyncio.gather(first_task, second_task, third_task)

    print(f"Results: {results}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/20_coroutine_scheduling.py
```

Expected output resembles:

```text
email-job: started
report-job: started
cleanup-job: started
report-job: completed
cleanup-job: completed
email-job: completed
Results: ['email-job result', 'report-job result', 'cleanup-job result']
```

The jobs start in creation order, but complete in delay order.

The total runtime should be around `0.3` seconds, not `0.6` seconds. The three coroutines overlap while waiting.

---

## Step 2: Create a Cancellation-Aware Resource

### The Target

Build an asynchronous context manager that records resource acquisition and release, including when a task is cancelled.

### The Concept

**Cancellation** is how `asyncio` asks a running task to stop.

For example:

```python
task.cancel()
```

At the next cancellation point—often an `await`—Python raises `asyncio.CancelledError` inside the task.

Cancellation is not a normal success result, and it is not an ordinary failure to ignore. It is a control-flow signal that means:

> “Stop this work as soon as it is safe to do so.”

A worker might receive cancellation during shutdown, after a timeout, or when a caller abandons a request.

Resources must still be released. An asynchronous context manager is the right tool:

```python
async with resource:
    await do_work()
```

It guarantees that `__aexit__` runs whether work succeeds, raises an exception, or is cancelled.

### The Implementation

Create this module.

## `src/pulsequeue/lifecycle.py`

```python
"""Async lifecycle primitives for resource-safe PulseQueue components."""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager


class ResourceStateError(RuntimeError):
    """Raised when a lifecycle-managed resource is used in the wrong state."""


class AsyncResource:
    """A small cancellation-safe resource used for lifecycle demonstrations.

    Real framework components will use this same lifecycle pattern for broker
    connections, worker pools, telemetry clients, and application startup.
    """

    def __init__(self, name: str) -> None:
        """Create an initially closed resource."""
        if not name or not name.strip():
            raise ValueError("Resource name cannot be empty.")

        self._name = name
        self._is_open = False

    @property
    def name(self) -> str:
        """Return the human-readable resource name."""
        return self._name

    @property
    def is_open(self) -> bool:
        """Return whether the resource is currently available for use."""
        return self._is_open

    async def open(self) -> None:
        """Open the resource exactly once."""
        if self._is_open:
            raise ResourceStateError(f"Resource {self._name!r} is already open.")

        # This await represents a real asynchronous setup action such as
        # opening a connection or negotiating with a remote service.
        await __import__("asyncio").sleep(0)
        self._is_open = True

    async def close(self) -> None:
        """Close the resource safely; repeated close calls are harmless."""
        if not self._is_open:
            return

        try:
            # In real code this is where we would flush buffers, close a socket,
            # acknowledge shutdown, or release another external resource.
            await __import__("asyncio").sleep(0)
        finally:
            # finally guarantees local state remains accurate even if a future
            # close implementation raises an unexpected exception.
            self._is_open = False

    @asynccontextmanager
    async def session(self) -> AsyncIterator[AsyncResource]:
        """Open this resource for one context-managed unit of work."""
        await self.open()

        try:
            yield self
        finally:
            # This executes on success, exception, and cancellation.
            await self.close()
```

The code above is valid, but importing `asyncio` through `__import__` makes the module harder to read. Replace it with this clean final version.

## `src/pulsequeue/lifecycle.py`

```python
"""Async lifecycle primitives for resource-safe PulseQueue components."""

from __future__ import annotations

import asyncio
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager


class ResourceStateError(RuntimeError):
    """Raised when a lifecycle-managed resource is used in the wrong state."""


class AsyncResource:
    """A small cancellation-safe resource used for lifecycle demonstrations.

    Real framework components will use this same lifecycle pattern for broker
    connections, worker pools, telemetry clients, and application startup.
    """

    def __init__(self, name: str) -> None:
        """Create an initially closed resource."""
        if not name or not name.strip():
            raise ValueError("Resource name cannot be empty.")

        self._name = name
        self._is_open = False

    @property
    def name(self) -> str:
        """Return the human-readable resource name."""
        return self._name

    @property
    def is_open(self) -> bool:
        """Return whether the resource is currently available for use."""
        return self._is_open

    async def open(self) -> None:
        """Open the resource exactly once."""
        if self._is_open:
            raise ResourceStateError(f"Resource {self._name!r} is already open.")

        # This await represents a real asynchronous setup action such as
        # opening a connection or negotiating with a remote service.
        await asyncio.sleep(0)
        self._is_open = True

    async def close(self) -> None:
        """Close the resource safely; repeated close calls are harmless."""
        if not self._is_open:
            return

        try:
            # In real code this is where we would flush buffers, close a socket,
            # acknowledge shutdown, or release another external resource.
            await asyncio.sleep(0)
        finally:
            # finally guarantees local state remains accurate even if a future
            # close implementation raises an unexpected exception.
            self._is_open = False

    @asynccontextmanager
    async def session(self) -> AsyncIterator[AsyncResource]:
        """Open this resource for one context-managed unit of work."""
        await self.open()

        try:
            yield self
        finally:
            # This executes on success, exception, and cancellation.
            await self.close()
```

Now create a cancellation demonstration.

## `examples/21_cancellation_cleanup.py`

```python
"""Demonstrate that async context managers clean up after cancellation."""

from __future__ import annotations

import asyncio

from pulsequeue.lifecycle import AsyncResource


async def long_running_operation(resource: AsyncResource) -> None:
    """Use a resource until a caller cancels this coroutine."""
    async with resource.session():
        print(f"Resource open inside operation: {resource.is_open}")

        # This is intentionally longer than the caller's cancellation delay.
        await asyncio.sleep(10)


async def main() -> None:
    """Start work, cancel it, and confirm the resource closes."""
    resource = AsyncResource("demo-connection")

    operation = asyncio.create_task(
        long_running_operation(resource),
        name="long-running-operation",
    )

    await asyncio.sleep(0.05)

    print("Requesting cancellation...")
    operation.cancel()

    try:
        await operation
    except asyncio.CancelledError:
        print("Operation acknowledged cancellation.")

    print(f"Resource open after cancellation: {resource.is_open}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/21_cancellation_cleanup.py
```

Expected output:

```text
Resource open inside operation: True
Requesting cancellation...
Operation acknowledged cancellation.
Resource open after cancellation: False
```

The last line is the important result. Even though the operation did not complete normally, the resource was closed.

---

## Step 3: Add a Reusable Timeout Helper

### The Target

Create a timeout helper that gives framework code a consistent error type and message.

### The Concept

A timeout is a deadline. It prevents a task from waiting forever for an operation that may never complete.

For example:

- An external API may stop responding.
- A database connection may hang.
- A task may contain an accidental infinite wait.
- A shutdown process may wait too long for work to finish.

Python 3.11+ provides `asyncio.timeout(...)`, an asynchronous context manager that cancels the enclosed operation when a deadline expires.

We will wrap it in a small helper so PulseQueue has one framework-specific timeout exception rather than exposing low-level `TimeoutError` behavior everywhere.

Think of a timeout like a delivery window. If the package has not arrived by the agreed time, the receiving team stops waiting and follows a fallback procedure.

### The Implementation

Create the timeout module.

## `src/pulsequeue/timeouts.py`

```python
"""Timeout helpers for bounded asynchronous operations."""

from __future__ import annotations

import asyncio
from collections.abc import Awaitable
from typing import TypeVar

ResultT = TypeVar("ResultT")


class OperationTimeoutError(TimeoutError):
    """Raised when a PulseQueue operation exceeds its configured deadline."""


async def await_with_timeout(
    awaitable: Awaitable[ResultT],
    *,
    timeout_seconds: float,
    operation_name: str,
) -> ResultT:
    """Await work with a validated deadline and a useful framework error.

    A timeout of zero means "no timeout" for task configuration consistency.
    Negative timeout values are always invalid.
    """
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

Create this example.

## `examples/22_timeouts.py`

```python
"""Demonstrate successful and timed-out asynchronous operations."""

from __future__ import annotations

import asyncio

from pulsequeue.timeouts import OperationTimeoutError, await_with_timeout


async def complete_quickly() -> str:
    """Return before the configured timeout."""
    await asyncio.sleep(0.02)
    return "completed successfully"


async def complete_slowly() -> str:
    """Take longer than the example timeout."""
    await asyncio.sleep(0.2)
    return "this result should never be returned"


async def main() -> None:
    """Exercise both timeout outcomes."""
    fast_result = await await_with_timeout(
        complete_quickly(),
        timeout_seconds=1.0,
        operation_name="quick example",
    )
    print(f"Fast operation: {fast_result}")

    try:
        await await_with_timeout(
            complete_slowly(),
            timeout_seconds=0.05,
            operation_name="slow example",
        )
    except OperationTimeoutError as error:
        print(f"Timeout error: {error}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/22_timeouts.py
```

Expected output:

```text
Fast operation: completed successfully
Timeout error: Operation 'slow example' exceeded its timeout of 0.050 second(s).
```

The slow coroutine is cancelled by the timeout context before it reaches its return statement.

---

## Step 4: Build a Bounded Asynchronous Queue

### The Target

Create a bounded in-memory queue with clear lifecycle rules.

### The Concept

A queue separates producers from consumers:

```text
Producer submits work → Queue stores work → Worker consumes work
```

This separation is fundamental to task systems.

A bounded queue has a maximum number of waiting items. The limit provides **backpressure**.

**Backpressure** means a fast producer cannot add unlimited work faster than consumers can process it.

Without a limit, a service under load can keep accepting work until it exhausts memory.

Think of a queue as a loading dock with a fixed number of parking spaces:

- If space exists, a truck can unload.
- If the dock is full, another truck must wait or be turned away.
- The dock prevents an unlimited traffic jam from spreading inside the warehouse.

We will create an `AsyncWorkQueue` wrapper around `asyncio.Queue` that adds:

- explicit closing;
- rejection of submissions after closing;
- queue statistics;
- `join()` support for graceful draining;
- a sentinel object for consumers to stop cleanly.

### The Implementation

Create the queue module.

## `src/pulsequeue/async_queue.py`

```python
"""Bounded in-memory asynchronous queue primitives."""

from __future__ import annotations

import asyncio
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
        """Wait for capacity and submit one item.

        This method intentionally waits when the queue is full. That waiting
        applies backpressure to cooperative producers instead of consuming
        unbounded memory.
        """
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
            # Waiting here is intentional. If the queue is full, existing work
            # must make space before consumers can receive their stop signals.
            await self._queue.put(STOP_SIGNAL)

    def stats(self) -> QueueStats:
        """Return a point-in-time state snapshot."""
        return QueueStats(
            max_size=self._max_size,
            queued_items=self._queue.qsize(),
            unfinished_tasks=self._queue._unfinished_tasks,
            is_closed=self._is_closed,
        )
```

### The Verification

Create a producer-consumer example.

## `examples/23_bounded_async_queue.py`

```python
"""Demonstrate bounded queue processing and graceful worker shutdown."""

from __future__ import annotations

import asyncio

from pulsequeue.async_queue import AsyncWorkQueue, STOP_SIGNAL


async def producer(queue: AsyncWorkQueue[int]) -> None:
    """Submit a small known set of work items."""
    for value in range(1, 6):
        print(f"Producer submitting {value}")
        await queue.put(value)

    print("Producer finished submitting work.")


async def consumer(
    worker_name: str,
    queue: AsyncWorkQueue[int],
) -> None:
    """Process items until this consumer receives its stop signal."""
    while True:
        item = await queue.get()

        try:
            if item is STOP_SIGNAL:
                print(f"{worker_name} stopping.")
                return

            print(f"{worker_name} processing {item}")
            await asyncio.sleep(0.05)
        finally:
            # Every get() must be paired with task_done(), including the stop
            # signal. Otherwise queue.join() would wait forever.
            queue.task_done()


async def main() -> None:
    """Run a producer and two consumers, then drain and stop safely."""
    queue = AsyncWorkQueue[int](max_size=2)

    consumers = [
        asyncio.create_task(consumer("worker-1", queue)),
        asyncio.create_task(consumer("worker-2", queue)),
    ]

    await producer(queue)

    print(f"Queue before drain: {queue.stats()}")

    # Wait until all normal submitted work has completed.
    await queue.join()

    print(f"Queue after work drain: {queue.stats()}")

    # Add one stop signal for each consumer, then wait for clean termination.
    await queue.stop_consumers(consumer_count=len(consumers))
    await queue.join()
    await asyncio.gather(*consumers)

    print(f"Queue after shutdown: {queue.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/23_bounded_async_queue.py
```

Expected output resembles:

```text
Producer submitting 1
Producer submitting 2
Producer submitting 3
worker-1 processing 1
worker-2 processing 2
Producer submitting 4
Producer submitting 5
Producer finished submitting work.
Queue before drain: QueueStats(...)
worker-1 processing 3
worker-2 processing 4
worker-1 processing 5
Queue after work drain: QueueStats(max_size=2, queued_items=0, unfinished_tasks=0, is_closed=False)
worker-1 stopping.
worker-2 stopping.
Queue after shutdown: QueueStats(max_size=2, queued_items=0, unfinished_tasks=0, is_closed=True)
```

Worker assignment and output order can vary. The required outcomes are:

- all values from `1` through `5` are processed;
- consumers stop only after normal work drains;
- the final queue has zero unfinished tasks;
- the queue rejects future submissions after shutdown begins.

---

## Step 5: Demonstrate Queue Backpressure

### The Target

Prove that a bounded queue makes a producer wait instead of allowing unlimited pending work.

### The Concept

Backpressure is easier to understand when observed.

Our queue capacity will be one item:

```python
queue = AsyncWorkQueue[int](max_size=1)
```

The producer can submit the first item immediately. When it attempts to submit the second item, it must wait until a consumer removes an item.

This behavior is desirable. It lets slow workers influence the speed at which producers submit work.

### The Implementation

Create this example.

## `examples/24_queue_backpressure.py`

```python
"""Measure producer waiting caused by bounded queue backpressure."""

from __future__ import annotations

import asyncio
import time

from pulsequeue.async_queue import AsyncWorkQueue, STOP_SIGNAL


async def slow_consumer(queue: AsyncWorkQueue[int]) -> None:
    """Remove one item only after a deliberate delay."""
    await asyncio.sleep(0.2)

    item = await queue.get()

    try:
        if item is not STOP_SIGNAL:
            print(f"Consumer received item: {item}")
    finally:
        queue.task_done()


async def main() -> None:
    """Fill a one-slot queue and measure wait time for a second submission."""
    queue = AsyncWorkQueue[int](max_size=1)

    await queue.put(1)
    print("Submitted first item immediately.")

    consumer_task = asyncio.create_task(slow_consumer(queue))

    started_at = time.perf_counter()

    # This cannot complete until the consumer removes item 1.
    await queue.put(2)

    elapsed_seconds = time.perf_counter() - started_at

    print(f"Second submission waited approximately {elapsed_seconds:.3f} seconds.")

    # Drain the second item ourselves so the demonstration exits cleanly.
    second_item = await queue.get()

    try:
        print(f"Main coroutine received remaining item: {second_item}")
    finally:
        queue.task_done()

    await consumer_task
    await queue.join()


if __name__ == "__main__":
    asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/24_queue_backpressure.py
```

Expected output resembles:

```text
Submitted first item immediately.
Consumer received item: 1
Second submission waited approximately 0.200 seconds.
Main coroutine received remaining item: 2
```

The exact elapsed time varies, but it should be close to `0.2` seconds.

That wait is backpressure working correctly.

---

## Step 6: Add Tests for Lifecycle, Timeouts, and Queues

### The Target

Protect the new asynchronous building blocks with tests.

### The Concept

Asynchronous code can appear correct while hiding cleanup mistakes:

- an item is retrieved but never marked done;
- a timeout does not cancel work;
- a resource remains open after cancellation;
- a closed queue accepts new submissions;
- stop signals are not accounted for.

Tests verify the contracts that later worker code will depend on.

### The Implementation

Create the test module.

## `tests/test_async_primitives.py`

```python
"""Tests for async lifecycle, timeout, and bounded-queue primitives."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue.async_queue import (
    AsyncWorkQueue,
    QueueClosedError,
    STOP_SIGNAL,
)
from pulsequeue.lifecycle import AsyncResource, ResourceStateError
from pulsequeue.timeouts import OperationTimeoutError, await_with_timeout


def test_async_resource_opens_and_closes_in_context() -> None:
    """A context-managed resource should always close after normal completion."""

    async def run_test() -> None:
        resource = AsyncResource("test-resource")

        assert resource.is_open is False

        async with resource.session():
            assert resource.is_open is True

        assert resource.is_open is False

    asyncio.run(run_test())


def test_async_resource_rejects_double_open() -> None:
    """Opening an already open resource should produce a clear lifecycle error."""

    async def run_test() -> None:
        resource = AsyncResource("test-resource")

        await resource.open()

        with pytest.raises(ResourceStateError, match="already open"):
            await resource.open()

        await resource.close()

    asyncio.run(run_test())


def test_timeout_returns_completed_result() -> None:
    """A fast awaitable should return normally before its deadline."""

    async def run_test() -> str:
        return await await_with_timeout(
            asyncio.sleep(0, result="done"),
            timeout_seconds=1.0,
            operation_name="fast-operation",
        )

    assert asyncio.run(run_test()) == "done"


def test_timeout_raises_framework_error() -> None:
    """A slow awaitable should raise the framework timeout exception."""

    async def run_test() -> None:
        with pytest.raises(OperationTimeoutError, match="slow-operation"):
            await await_with_timeout(
                asyncio.sleep(0.1),
                timeout_seconds=0.001,
                operation_name="slow-operation",
            )

    asyncio.run(run_test())


def test_queue_processes_item_and_tracks_completion() -> None:
    """A retrieved item must be marked done before join can complete."""

    async def run_test() -> None:
        queue = AsyncWorkQueue[str](max_size=2)

        await queue.put("task-1")

        item = await queue.get()

        try:
            assert item == "task-1"
        finally:
            queue.task_done()

        await queue.join()

        stats = queue.stats()
        assert stats.queued_items == 0
        assert stats.unfinished_tasks == 0
        assert stats.is_closed is False

    asyncio.run(run_test())


def test_closed_queue_rejects_new_items() -> None:
    """Closing a queue must prevent future producer submissions."""

    async def run_test() -> None:
        queue = AsyncWorkQueue[int](max_size=1)
        queue.close()

        with pytest.raises(QueueClosedError, match="queue is closed"):
            await queue.put(1)

    asyncio.run(run_test())


def test_stop_consumers_enqueues_expected_signals() -> None:
    """One stop signal should be supplied for each consumer."""

    async def run_test() -> None:
        queue = AsyncWorkQueue[int](max_size=3)

        await queue.stop_consumers(consumer_count=2)

        first_signal = await queue.get()
        second_signal = await queue.get()

        try:
            assert first_signal is STOP_SIGNAL
            assert second_signal is STOP_SIGNAL
        finally:
            queue.task_done()
            queue.task_done()

        await queue.join()
        assert queue.is_closed is True

    asyncio.run(run_test())
```

### The Verification

Run the complete suite:

```bash
python -m pytest -q
```

Expected result:

```text
..........................                                               [100%]
26 passed
```

Your exact count may differ based on prior local changes. Every test should pass.

---

# Phase 2 Reference: Core `asyncio` APIs

## `asyncio.run(...)`

Use this at the top level of a command-line program:

```python
asyncio.run(main())
```

It creates an event loop, runs `main()`, finalizes asynchronous generators, and closes the loop.

Do not call it from code that is already inside a running event loop, such as:

- an existing async function;
- Jupyter notebook environments that manage their own loop;
- many ASGI web-framework handlers.

Inside async code, use `await` or `asyncio.create_task(...)` instead.

---

## `await`

Use `await` when the current coroutine needs a result before continuing:

```python
result = await fetch_data()
```

While waiting, the current coroutine yields control to the event loop.

---

## `asyncio.create_task(...)`

Use `create_task(...)` to schedule concurrent work:

```python
task = asyncio.create_task(fetch_data(), name="fetch-data")
```

Later, await it:

```python
result = await task
```

Named tasks improve diagnostics because stack traces and debugging tools can identify them.

Do not create tasks and forget them. “Fire-and-forget” work can hide exceptions and complicate shutdown. Framework code should retain task references and await or cancel them deliberately.

---

## `asyncio.gather(...)`

Use `gather(...)` when several operations should run concurrently and their results are all needed:

```python
first, second = await asyncio.gather(
    fetch_first(),
    fetch_second(),
)
```

By default, if one coroutine raises an exception, `gather(...)` propagates it to the caller.

Avoid using `return_exceptions=True` casually. It turns failures into result values, which can make real errors easier to overlook.

---

## `asyncio.timeout(...)`

Use a timeout boundary around an operation that must not wait forever:

```python
async with asyncio.timeout(5):
    result = await external_call()
```

When the deadline expires, Python cancels the enclosed work and raises `TimeoutError` outside the context.

PulseQueue wraps this behavior with `await_with_timeout(...)` so the framework exposes a consistent `OperationTimeoutError`.

---

## Cancellation Rules

When catching exceptions around async work, do not accidentally swallow cancellation.

This is risky:

```python
try:
    await do_work()
except BaseException:
    pass
```

It catches `asyncio.CancelledError` and prevents cancellation from propagating.

Prefer catching expected operational exceptions only:

```python
try:
    await do_work()
except ConnectionError:
    recover()
```

If code must perform cleanup during cancellation, use `finally`:

```python
try:
    await do_work()
finally:
    await close_resource()
```

This is why context managers are so valuable for worker lifecycle management.

---

## One Caution About Queue Internals

`AsyncWorkQueue.stats()` currently reads:

```python
self._queue._unfinished_tasks
```

The leading underscore means it is an internal implementation detail of `asyncio.Queue`.

We use it only for tutorial diagnostics. Production code that must depend on queue accounting should maintain its own explicit counter or expose metrics through a carefully controlled wrapper.

Later, when building PulseQueue’s broker metrics, we will maintain framework-owned counters rather than relying on a private standard-library field.
