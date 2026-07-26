# Primer 4: `async def`, `await`, Coroutines, and the Event Loop

Before building concurrent workers, retries, queues, and graceful shutdown, readers need a solid model for asynchronous Python.

The most important idea is:

> `asyncio` is efficient when work spends time waiting.

For example, a task may wait for:

- an HTTP response;
- a database query;
- a timer;
- another task;
- a queue item;
- a network connection.

While one task waits, the event loop can run another task.

---

# Step 1: Define an Async Function

## The Target

Create and run a basic coroutine function.

## The Concept

A function declared with `async def` is an **asynchronous function**.

```python
async def greet(name: str) -> str:
    return f"Hello, {name}."
```

Calling it does not immediately return the final string.

Instead:

```python
coroutine = greet("Ada")
```

creates a **coroutine object**.

A coroutine is a paused plan for async work. An event loop must run it.

Think of it as receiving a numbered ticket at a service desk. The ticket represents work waiting to be handled; it is not the finished service itself.

## The Implementation

Create this file.

## `primer_examples/15_async_function_basics.py`

```python
"""Primer 4: create and run a coroutine."""

from __future__ import annotations

import asyncio


async def greet(name: str) -> str:
    """Return an asynchronous greeting."""
    return f"Hello, {name}."


async def main() -> None:
    """Create a coroutine and then await its result."""
    coroutine = greet("Ada")

    print(f"Created object type: {type(coroutine).__name__}")

    result = await coroutine

    print(f"Result: {result}")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.15_async_function_basics
```

Expected output:

```text
Created object type: coroutine
Result: Hello, Ada.
```

---

# Step 2: Understand `await`

## The Target

Use `await` to pause one coroutine until another async operation completes.

## The Concept

`await` means:

> “Pause this coroutine until the awaited operation has a result. Let the event loop run other ready work while waiting.”

Example:

```python
result = await fetch_profile(42)
```

The current coroutine pauses. It does not necessarily block the entire Python process.

This is the key distinction:

| Action | Effect |
|---|---|
| `await asyncio.sleep(1)` | Current coroutine pauses; event loop can run other tasks |
| `time.sleep(1)` | Current thread blocks; event loop cannot run other tasks |

## The Implementation

Create this file.

## `primer_examples/16_await_and_sleep.py`

```python
"""Primer 4: compare asynchronous waiting with ordinary blocking waiting."""

from __future__ import annotations

import asyncio
import time


async def async_wait_example() -> None:
    """Wait without blocking the event loop."""
    print("Async wait started.")
    await asyncio.sleep(0.1)
    print("Async wait completed.")


def blocking_wait_example() -> None:
    """Wait by blocking the current thread."""
    print("Blocking wait started.")
    time.sleep(0.1)
    print("Blocking wait completed.")


async def main() -> None:
    """Run both examples in sequence."""
    await async_wait_example()
    blocking_wait_example()


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.16_await_and_sleep
```

Expected output:

```text
Async wait started.
Async wait completed.
Blocking wait started.
Blocking wait completed.
```

The output looks similar, but the behavior differs dramatically when other async tasks exist.

---

# Step 3: Run Two Coroutines Concurrently

## The Target

Use `asyncio.create_task(...)` to let multiple coroutines make progress together.

## The Concept

This code is sequential:

```python
first_result = await first_operation()
second_result = await second_operation()
```

The second operation starts only after the first finishes.

To allow both operations to begin:

```python
first_task = asyncio.create_task(first_operation())
second_task = asyncio.create_task(second_operation())
```

Then wait for both:

```python
first_result, second_result = await asyncio.gather(
    first_task,
    second_task,
)
```

Think of the event loop as a restaurant server:

1. Take order from table A.
2. Table A waits for food.
3. Take order from table B.
4. Table B waits for food.
5. Return when food is ready.

The server is not doing two things at the exact same CPU instant. The server is switching efficiently while tables wait.

## The Implementation

Create this file.

## `primer_examples/17_concurrent_coroutines.py`

```python
"""Primer 4: schedule concurrent coroutine work."""

from __future__ import annotations

import asyncio
import time


async def simulated_request(name: str, delay_seconds: float) -> str:
    """Simulate a request that spends time waiting for I/O."""
    print(f"{name}: started")

    await asyncio.sleep(delay_seconds)

    print(f"{name}: completed")
    return f"{name} result"


async def main() -> None:
    """Run two waiting operations concurrently."""
    started_at = time.perf_counter()

    first_task = asyncio.create_task(
        simulated_request("first request", 0.2),
        name="first-request",
    )
    second_task = asyncio.create_task(
        simulated_request("second request", 0.1),
        name="second-request",
    )

    first_result, second_result = await asyncio.gather(
        first_task,
        second_task,
    )

    elapsed_seconds = time.perf_counter() - started_at

    print(f"Results: {first_result!r}, {second_result!r}")
    print(f"Elapsed: {elapsed_seconds:.3f} seconds")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.17_concurrent_coroutines
```

Expected output resembles:

```text
first request: started
second request: started
second request: completed
first request: completed
Results: 'first request result', 'second request result'
Elapsed: 0.200 seconds
```

The elapsed time should be near `0.2` seconds, not `0.3` seconds, because waiting overlaps.

---

# Step 4: See Why Blocking Code Is Dangerous

## The Target

Observe how a blocking function prevents unrelated coroutines from progressing.

## The Concept

The event loop normally runs in one thread.

If a coroutine calls blocking code:

```python
time.sleep(1)
```

the whole event-loop thread stops.

No other coroutine can run during that period.

This is why PulseQueue distinguishes:

```text
Async I/O task
```

from:

```text
Blocking I/O task moved to a thread
```

and:

```text
CPU-bound task moved to a process
```

## The Implementation

Create this file.

## `primer_examples/18_event_loop_blocking.py`

```python
"""Primer 4: show how a blocking call freezes the event loop."""

from __future__ import annotations

import asyncio
import time


async def heartbeat() -> None:
    """Print periodic output while event loop remains responsive."""
    for count in range(5):
        print(f"Heartbeat {count}")
        await asyncio.sleep(0.05)


def blocking_operation() -> None:
    """Block the event-loop thread for a short demonstration."""
    print("Blocking operation started.")
    time.sleep(0.2)
    print("Blocking operation completed.")


async def main() -> None:
    """Start heartbeat, then intentionally block the event loop."""
    heartbeat_task = asyncio.create_task(
        heartbeat(),
        name="heartbeat",
    )

    await asyncio.sleep(0.06)

    blocking_operation()

    await heartbeat_task


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.18_event_loop_blocking
```

Expected output resembles:

```text
Heartbeat 0
Heartbeat 1
Blocking operation started.
Blocking operation completed.
Heartbeat 2
Heartbeat 3
Heartbeat 4
```

Notice the pause between heartbeat `1` and heartbeat `2`.

That pause exists because `time.sleep(...)` blocked the only event-loop thread.

---

# Step 5: Move Blocking Work to a Thread

## The Target

Use `asyncio.to_thread(...)` so blocking work does not freeze the event loop.

## The Concept

A thread is another execution path inside the same process.

For blocking I/O, we can move a synchronous function to a thread:

```python
result = await asyncio.to_thread(blocking_operation)
```

The event loop waits for the thread result, but it remains free to run other coroutines.

This does not make CPU-heavy Python code scale across multiple cores due to the CPython GIL. It is primarily useful for blocking operations that spend time waiting.

## The Implementation

Create this file.

## `primer_examples/19_to_thread.py`

```python
"""Primer 4: move blocking work away from the event loop."""

from __future__ import annotations

import asyncio
import time


async def heartbeat() -> None:
    """Print periodic output while event loop remains responsive."""
    for count in range(5):
        print(f"Heartbeat {count}")
        await asyncio.sleep(0.05)


def blocking_operation() -> str:
    """Simulate a synchronous blocking library call."""
    print("Blocking operation started.")
    time.sleep(0.2)
    print("Blocking operation completed.")
    return "blocking work result"


async def main() -> None:
    """Run heartbeat alongside blocking work in a thread."""
    heartbeat_task = asyncio.create_task(
        heartbeat(),
        name="heartbeat",
    )

    result = await asyncio.to_thread(blocking_operation)

    await heartbeat_task

    print(f"Result: {result}")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.19_to_thread
```

Expected output resembles:

```text
Blocking operation started.
Heartbeat 0
Heartbeat 1
Heartbeat 2
Heartbeat 3
Blocking operation completed.
Heartbeat 4
Result: blocking work result
```

The exact order can vary, but heartbeats should continue while the blocking operation runs.

---

# Step 6: Handle Cancellation Safely

## The Target

Cancel a coroutine and ensure it runs cleanup logic.

## The Concept

Cancellation is cooperative.

When code calls:

```python
task.cancel()
```

Python injects `asyncio.CancelledError` into the coroutine at its next `await` point.

A well-behaved coroutine should:

1. perform necessary cleanup;
2. re-raise cancellation.

```python
except asyncio.CancelledError:
    cleanup()
    raise
```

Do not swallow `CancelledError` accidentally. If you do, shutdown logic may hang because callers believe cancellation completed while the coroutine continues.

## The Implementation

Create this file.

## `primer_examples/20_cancellation.py`

```python
"""Primer 4: cancellation-aware coroutine cleanup."""

from __future__ import annotations

import asyncio


async def long_running_task() -> None:
    """Run until cancellation, then clean up and propagate cancellation."""
    print("Task started.")

    try:
        while True:
            print("Task is working.")
            await asyncio.sleep(0.1)
    except asyncio.CancelledError:
        print("Task received cancellation request.")
        print("Task cleanup completed.")
        raise


async def main() -> None:
    """Start, cancel, and await a long-running coroutine."""
    task = asyncio.create_task(
        long_running_task(),
        name="long-running-task",
    )

    await asyncio.sleep(0.25)

    print("Requesting cancellation.")
    task.cancel()

    try:
        await task
    except asyncio.CancelledError:
        print("Caller confirmed cancellation.")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.20_cancellation
```

Expected output resembles:

```text
Task started.
Task is working.
Task is working.
Task is working.
Requesting cancellation.
Task received cancellation request.
Task cleanup completed.
Caller confirmed cancellation.
```

---

# Step 7: Connect Async Basics to PulseQueue

## The Target

Register and execute a small I/O-style task using `PulseQueueRuntime`.

## The Concept

A PulseQueue async task is an ordinary coroutine function wrapped in framework behavior.

```python
@app.task(queue="messages")
async def greet(name: str) -> str:
    await asyncio.sleep(0)
    return f"Hello, {name}."
```

The worker later runs that coroutine using the event loop.

The receipt provides a separate handle for task completion:

```python
receipt = await runtime.submit("messages.greet", "Ada")
result = await receipt.result(timeout_seconds=1.0)
```

## The Implementation

Create this file.

## `primer_examples/21_pulsequeue_async_task.py`

```python
"""Primer 4: execute one async task through PulseQueue."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime


app = PulseQueue("primer_async_demo")


@app.task(queue="messages", timeout_seconds=1.0)
async def greet(name: str) -> str:
    """Simulate asynchronous work, then return a greeting."""
    await asyncio.sleep(0.05)
    return f"Hello, {name}."


async def main() -> None:
    """Start a runtime and await one submitted task result."""
    async with PulseQueueRuntime(
        app,
        worker_concurrency=2,
    ) as runtime:
        receipt = await runtime.submit("messages.greet", "Ada")

        print(f"Initial state: {receipt.snapshot().state}")

        result = await receipt.result(timeout_seconds=1.0)

        print(f"Final state: {receipt.snapshot().state}")
        print(f"Result: {result}")
        print(f"Worker stats: {runtime.worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.21_pulsequeue_async_task
```

Expected output includes:

```text
Initial state: queued
Final state: succeeded
Result: Hello, Ada.
```

---

# Primer 4 Reference: Key Terms

| Term | Meaning |
|---|---|
| Coroutine function | Function declared with `async def` |
| Coroutine object | Object created by calling a coroutine function |
| Event loop | Coordinator that schedules ready coroutines |
| `await` | Pause current coroutine while waiting for an awaitable |
| Awaitable | Object that can be awaited, such as coroutine or task |
| `asyncio.Task` | Scheduled coroutine managed by the event loop |
| Cancellation | Cooperative stop request delivered as `CancelledError` |
| Blocking call | Call that prevents the event-loop thread from running others |
| `asyncio.to_thread` | Run blocking synchronous work in a thread |

---

# Primer 4 Completion Checklist

Before continuing to advanced concurrency and task workers, confirm that you can:

- [ ] Explain the difference between an async function and coroutine object.
- [ ] Use `await` inside `async def`.
- [ ] Use `asyncio.run(...)` only at a program boundary.
- [ ] Start concurrent work with `asyncio.create_task(...)`.
- [ ] Wait for related tasks with `asyncio.gather(...)`.
- [ ] Explain why `time.sleep(...)` blocks the event loop.
- [ ] Use `asyncio.to_thread(...)` for blocking I/O-style functions.
- [ ] Cancel a task and re-raise `CancelledError` after cleanup.
- [ ] Submit and await an async PulseQueue task.
