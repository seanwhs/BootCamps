# Appendix D: `asyncio` Failure, Cancellation, and Shutdown Cookbook

This appendix is a practical reference for the failure paths that matter most in asynchronous Python systems.

Use it when you need to answer questions such as:

- Why did my coroutine not run?
- Why did shutdown hang?
- Why did `CancelledError` escape?
- How do I enforce a timeout correctly?
- Why is a queue waiting forever?
- How should a worker clean up after cancellation?

---

# 1. Run an Async Program Correctly

Use `asyncio.run(...)` at the outermost boundary of a command-line application.

```python
from __future__ import annotations

import asyncio


async def main() -> None:
    """Run application startup and asynchronous work."""
    await asyncio.sleep(0)
    print("Application completed.")


if __name__ == "__main__":
    asyncio.run(main())
```

Run it:

```bash
python app.py
```

Expected output:

```text
Application completed.
```

Do not call `asyncio.run(...)` from inside another running event loop.

Bad:

```python
async def already_async() -> None:
    asyncio.run(other_async_function())
```

Correct:

```python
async def already_async() -> None:
    await other_async_function()
```

---

# 2. Create Concurrent Work Deliberately

Use `await` when work must finish before proceeding.

```python
result = await fetch_data()
```

Use `asyncio.create_task(...)` when work may progress concurrently.

```python
import asyncio


async def fetch_data(identifier: int) -> str:
    """Simulate asynchronous I/O."""
    await asyncio.sleep(0.1)
    return f"data-{identifier}"


async def main() -> None:
    """Start two operations concurrently."""
    first = asyncio.create_task(fetch_data(1), name="fetch-data-1")
    second = asyncio.create_task(fetch_data(2), name="fetch-data-2")

    first_result, second_result = await asyncio.gather(first, second)

    print(first_result)
    print(second_result)


asyncio.run(main())
```

Expected output:

```text
data-1
data-2
```

---

# 3. Avoid Fire-and-Forget Tasks

Bad:

```python
async def main() -> None:
    asyncio.create_task(send_notification())
    print("Main function ended.")
```

The event loop may close before `send_notification()` finishes. Exceptions may also be lost or logged only as warnings.

Better:

```python
async def main() -> None:
    notification_task = asyncio.create_task(
        send_notification(),
        name="send-notification",
    )

    await notification_task
```

If background tasks are truly required, retain them and supervise them.

```python
from __future__ import annotations

import asyncio


class BackgroundTaskManager:
    """Track background tasks and expose controlled shutdown."""

    def __init__(self) -> None:
        self._tasks: set[asyncio.Task[object]] = set()

    def create(self, coroutine: object, *, name: str) -> asyncio.Task[object]:
        """Schedule and retain a background task."""
        task = asyncio.create_task(coroutine, name=name)
        self._tasks.add(task)

        def remove_completed_task(completed_task: asyncio.Task[object]) -> None:
            """Remove finished task and surface unexpected exceptions."""
            self._tasks.discard(completed_task)

            if completed_task.cancelled():
                return

            exception = completed_task.exception()

            if exception is not None:
                print(
                    f"Background task {completed_task.get_name()!r} failed: "
                    f"{exception!r}"
                )

        task.add_done_callback(remove_completed_task)
        return task

    async def stop(self) -> None:
        """Cancel and wait for all still-running tasks."""
        for task in self._tasks:
            task.cancel()

        await asyncio.gather(*self._tasks, return_exceptions=True)
        self._tasks.clear()
```

---

# 4. Apply Timeouts with `asyncio.timeout(...)`

Python 3.11+ provides a clean timeout context manager.

```python
from __future__ import annotations

import asyncio


async def slow_operation() -> str:
    """Take longer than the allowed deadline."""
    await asyncio.sleep(10)
    return "finished"


async def main() -> None:
    """Cancel slow work after a short deadline."""
    try:
        async with asyncio.timeout(0.1):
            result = await slow_operation()
            print(result)
    except TimeoutError:
        print("Operation exceeded its deadline.")


asyncio.run(main())
```

Expected output:

```text
Operation exceeded its deadline.
```

PulseQueue wraps this behavior through:

```python
from pulsequeue.timeouts import await_with_timeout

result = await await_with_timeout(
    slow_operation(),
    timeout_seconds=0.1,
    operation_name="slow_operation",
)
```

---

## Important Timeout Rule

A timeout cancels the current awaitable. It does not guarantee that every kind of underlying external work stops instantly.

For example:

- an async coroutine usually receives `CancelledError`;
- a thread cannot be safely force-killed by ordinary Python;
- a running process-pool function may continue after the caller stops waiting;
- an HTTP library may need its own cancellation or connection-close behavior.

---

# 5. Handle Cancellation Correctly

Cancellation is represented by:

```python
asyncio.CancelledError
```

A coroutine should usually allow it to propagate.

Correct:

```python
from __future__ import annotations

import asyncio


async def worker() -> None:
    """Run until cancellation is requested."""
    try:
        while True:
            await asyncio.sleep(1)
    except asyncio.CancelledError:
        print("Worker received cancellation.")

        # Perform only necessary, short cleanup here.
        raise
```

The final `raise` matters. It preserves cancellation semantics.

Bad:

```python
async def worker() -> None:
    try:
        await asyncio.sleep(10)
    except asyncio.CancelledError:
        print("Cancellation ignored.")
```

This swallows cancellation. Callers may believe the task stopped even though the coroutine can continue executing.

---

# 6. Always Use `finally` for Cleanup

Use `finally` for cleanup that must happen on:

- success;
- ordinary failure;
- timeout;
- cancellation.

```python
from __future__ import annotations

import asyncio


class AsyncConnection:
    """A small resource with explicit open and close operations."""

    def __init__(self) -> None:
        self.is_open = False

    async def open(self) -> None:
        """Open the simulated connection."""
        await asyncio.sleep(0)
        self.is_open = True

    async def close(self) -> None:
        """Close the simulated connection."""
        await asyncio.sleep(0)
        self.is_open = False


async def use_connection(connection: AsyncConnection) -> None:
    """Open, use, and always close a resource."""
    await connection.open()

    try:
        await asyncio.sleep(10)
    finally:
        await connection.close()
```

Prefer an async context manager when the pattern repeats.

```python
from __future__ import annotations

import asyncio
from contextlib import asynccontextmanager
from collections.abc import AsyncIterator


@asynccontextmanager
async def open_connection() -> AsyncIterator[AsyncConnection]:
    """Yield an open connection and guarantee cleanup."""
    connection = AsyncConnection()
    await connection.open()

    try:
        yield connection
    finally:
        await connection.close()


async def main() -> None:
    """Use a connection safely."""
    async with open_connection() as connection:
        assert connection.is_open is True
        await asyncio.sleep(0)
```

---

# 7. Cancel a Task and Await It

Calling:

```python
task.cancel()
```

requests cancellation. It does not wait for cancellation to complete.

Correct shutdown sequence:

```python
from __future__ import annotations

import asyncio


async def long_task() -> None:
    """Wait until a caller requests cancellation."""
    try:
        await asyncio.sleep(60)
    finally:
        print("Cleaning up long task.")


async def main() -> None:
    """Cancel work and wait for its cleanup path."""
    task = asyncio.create_task(long_task(), name="long-task")

    await asyncio.sleep(0.01)

    task.cancel()

    try:
        await task
    except asyncio.CancelledError:
        print("Task cancellation completed.")


asyncio.run(main())
```

Expected output:

```text
Cleaning up long task.
Task cancellation completed.
```

---

# 8. Use `gather(...)` Carefully

Basic use:

```python
results = await asyncio.gather(
    first_operation(),
    second_operation(),
)
```

If one operation raises, `gather(...)` propagates its exception.

For controlled shutdown, use:

```python
results = await asyncio.gather(
    *tasks,
    return_exceptions=True,
)
```

This is appropriate when cleaning up multiple tasks because one failure should not prevent waiting for the rest.

Example:

```python
from __future__ import annotations

import asyncio


async def successful() -> str:
    """Return a normal result."""
    return "success"


async def failing() -> str:
    """Raise an ordinary failure."""
    raise RuntimeError("example failure")


async def main() -> None:
    """Collect both result and exception during controlled cleanup."""
    results = await asyncio.gather(
        successful(),
        failing(),
        return_exceptions=True,
    )

    for result in results:
        if isinstance(result, Exception):
            print(f"Operation failed: {result}")
        else:
            print(f"Operation result: {result}")


asyncio.run(main())
```

Expected output:

```text
Operation result: success
Operation failed: example failure
```

Do not use `return_exceptions=True` casually in normal application flow. It can turn failures into ordinary values that callers forget to inspect.

---

# 9. Use `TaskGroup` for Structured Concurrency

Python 3.11+ includes `asyncio.TaskGroup`.

A **task group** gives related child tasks one parent lifecycle.

```python
from __future__ import annotations

import asyncio


async def fetch(identifier: int) -> str:
    """Simulate one asynchronous fetch."""
    await asyncio.sleep(0.05)
    return f"item-{identifier}"


async def main() -> None:
    """Run a group of related concurrent operations."""
    async with asyncio.TaskGroup() as group:
        first = group.create_task(fetch(1), name="fetch-1")
        second = group.create_task(fetch(2), name="fetch-2")

    print(first.result())
    print(second.result())


asyncio.run(main())
```

Expected output:

```text
item-1
item-2
```

If one child task fails, the task group cancels the remaining child tasks and raises an `ExceptionGroup`.

Use `TaskGroup` when:

- child tasks are one logical unit;
- all must complete successfully;
- sibling cancellation on failure is desirable.

Use `asyncio.gather(...)` when independent results or custom failure behavior are needed.

---

# 10. Queue Rule: Every `get()` Needs `task_done()`

For `asyncio.Queue` and PulseQueue’s `AsyncWorkQueue`, each successful `get()` must have exactly one corresponding `task_done()`.

Correct:

```python
from __future__ import annotations

import asyncio


async def consumer(queue: asyncio.Queue[str]) -> None:
    """Consume one item and always complete queue accounting."""
    item = await queue.get()

    try:
        print(f"Processing: {item}")
    finally:
        queue.task_done()
```

Incorrect:

```python
async def consumer(queue: asyncio.Queue[str]) -> None:
    item = await queue.get()

    if item == "bad":
        return

    queue.task_done()
```

If `"bad"` arrives, `queue.join()` can wait forever because unfinished task accounting never reaches zero.

PulseQueue worker consumers follow this pattern:

```python
broker_item = await broker.get()

try:
    await process(broker_item)
finally:
    broker.task_done()
```

---

# 11. Graceful Queue Shutdown Pattern

A safe worker shutdown sequence is:

```text
Stop accepting new work
        ↓
Allow accepted messages to finish
        ↓
Send one stop signal per consumer
        ↓
Wait for consumers to exit
```

Simplified example:

```python
from __future__ import annotations

import asyncio


STOP = object()


async def consumer(name: str, queue: asyncio.Queue[object]) -> None:
    """Process values until receiving a stop sentinel."""
    while True:
        item = await queue.get()

        try:
            if item is STOP:
                print(f"{name} stopped.")
                return

            print(f"{name} processed {item}")
            await asyncio.sleep(0.01)
        finally:
            queue.task_done()


async def main() -> None:
    """Drain queued work before stopping two consumers."""
    queue: asyncio.Queue[object] = asyncio.Queue()

    consumers = [
        asyncio.create_task(consumer("worker-1", queue)),
        asyncio.create_task(consumer("worker-2", queue)),
    ]

    for value in range(5):
        await queue.put(value)

    await queue.join()

    for _ in consumers:
        await queue.put(STOP)

    await queue.join()
    await asyncio.gather(*consumers)


asyncio.run(main())
```

---

# 12. Bounded Queues Provide Backpressure

An unbounded queue can accept work faster than workers process it.

```python
queue = asyncio.Queue()
```

A bounded queue limits queued work:

```python
queue = asyncio.Queue(maxsize=100)
```

When full:

```python
await queue.put(item)
```

waits until capacity becomes available.

This is **backpressure**.

PulseQueue uses:

```python
InMemoryBroker(max_queue_size=1_000)
```

Choose a capacity based on:

- memory per task payload;
- worker throughput;
- acceptable producer waiting;
- failure behavior;
- external request limits.

---

# 13. Detect Event Loop Blocking

A common sign of event-loop blocking is that unrelated periodic tasks stop running.

Example detector:

```python
from __future__ import annotations

import asyncio
import time


async def heartbeat() -> None:
    """Print regular ticks while the event loop remains responsive."""
    while True:
        print(f"Heartbeat at {time.monotonic():.3f}")
        await asyncio.sleep(0.1)


def blocking_function() -> None:
    """Block the current thread for demonstration."""
    time.sleep(2)


async def bad_main() -> None:
    """Demonstrate a blocked event loop."""
    heartbeat_task = asyncio.create_task(heartbeat())

    await asyncio.sleep(0.2)

    # This blocks the entire event-loop thread.
    blocking_function()

    heartbeat_task.cancel()

    try:
        await heartbeat_task
    except asyncio.CancelledError:
        pass
```

Fix:

```python
async def good_main() -> None:
    """Move blocking work outside the event-loop thread."""
    heartbeat_task = asyncio.create_task(heartbeat())

    await asyncio.sleep(0.2)

    await asyncio.to_thread(blocking_function)

    heartbeat_task.cancel()

    try:
        await heartbeat_task
    except asyncio.CancelledError:
        pass
```

---

# 14. Handle Exceptions from Background Tasks

A task exception can be missed if no code awaits it.

Bad:

```python
asyncio.create_task(failing_operation())
```

Better:

```python
from __future__ import annotations

import asyncio


def report_failure(task: asyncio.Task[object]) -> None:
    """Log unexpected background task failures."""
    if task.cancelled():
        return

    exception = task.exception()

    if exception is not None:
        print(
            f"Background task {task.get_name()!r} failed: "
            f"{type(exception).__name__}: {exception}"
        )


async def failing_operation() -> None:
    """Raise one example failure."""
    await asyncio.sleep(0)
    raise RuntimeError("background failure")


async def main() -> None:
    """Attach completion reporting to a supervised background task."""
    task = asyncio.create_task(
        failing_operation(),
        name="failing-operation",
    )

    task.add_done_callback(report_failure)

    await asyncio.sleep(0.01)


asyncio.run(main())
```

Expected output:

```text
Background task 'failing-operation' failed: RuntimeError: background failure
```

---

# 15. Shutdown Recipe for an Async Service

Use this high-level pattern:

```python
from __future__ import annotations

import asyncio
import signal


async def serve_until_stopped() -> None:
    """Run service work until SIGINT or SIGTERM requests shutdown."""
    shutdown_event = asyncio.Event()
    event_loop = asyncio.get_running_loop()

    def request_shutdown() -> None:
        """Set a cooperative shutdown signal."""
        shutdown_event.set()

    for signal_value in (signal.SIGINT, signal.SIGTERM):
        event_loop.add_signal_handler(signal_value, request_shutdown)

    background_task = asyncio.create_task(
        background_loop(),
        name="background-loop",
    )

    try:
        await shutdown_event.wait()
    finally:
        background_task.cancel()

        await asyncio.gather(
            background_task,
            return_exceptions=True,
        )


async def background_loop() -> None:
    """Perform periodic service work until cancelled."""
    while True:
        await asyncio.sleep(1)


if __name__ == "__main__":
    asyncio.run(serve_until_stopped())
```

PulseQueue’s CLI uses the same overall idea:

```text
Install signal handlers
        ↓
Start runtime
        ↓
Wait for shutdown event
        ↓
Stop worker with graceful timeout
        ↓
Close process pool and plugins
```

---

# 16. Cancellation Checklist

When writing an async worker, verify all of the following:

- [ ] Every long-running coroutine reaches cancellation points through `await`.
- [ ] `CancelledError` is re-raised after required cleanup.
- [ ] Every queue `get()` has a `task_done()` in `finally`.
- [ ] Resources use `async with` or explicit `try/finally`.
- [ ] Background tasks are retained and supervised.
- [ ] Timeouts wrap only the work that should have a deadline.
- [ ] Forced shutdown records cancellation state for waiting callers.
- [ ] Worker shutdown waits for cleanup before closing the event loop.
- [ ] Plugin or metrics failures do not silently hide task failures.
- [ ] Blocking calls are moved to threads or processes.
