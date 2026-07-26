# Primer 6: Threads, Processes, the GIL, and Safe Multiprocessing Entry Points

`asyncio` handles many waiting operations efficiently, but it is not the only concurrency tool in Python.

This primer explains:

- what threads are;
- what processes are;
- what the CPython Global Interpreter Lock (GIL) does;
- why threads help with blocking I/O;
- why processes help with CPU-heavy Python work;
- why process code needs a module-level function;
- why `if __name__ == "__main__":` matters.

---

# Step 1: Understand Threads and Processes

## The Target

Build a basic mental model for two ways Python can run work concurrently.

## The Concept

A **thread** is an execution path inside one process.

Threads share:

- the same memory;
- the same Python objects;
- the same open process resources.

A **process** is a separate running Python interpreter.

Processes have separate:

- memory;
- Python objects;
- interpreter state;
- Global Interpreter Locks.

Think of a process as a separate workshop building. Threads are several workers inside one workshop.

| Property | Thread | Process |
|---|---|---|
| Memory | Shared | Separate |
| Startup cost | Lower | Higher |
| Data exchange | Direct shared objects, with synchronization | Serialization and inter-process communication |
| Best common use | Blocking I/O | CPU-heavy Python work |
| GIL relationship | Shares one process GIL | Each process has its own GIL |

---

# Step 2: Run a Small Function in a Thread

## The Target

Create and join a Python thread.

## The Concept

A thread can run a normal synchronous function while the main thread continues.

This is useful for blocking work such as:

- legacy HTTP clients;
- file I/O;
- blocking SDKs;
- synchronous database drivers.

Threads should not be used casually for shared mutable state. Several threads changing the same data can create race conditions.

A **race condition** happens when the final outcome depends on unpredictable timing between workers.

## The Implementation

Create this file.

## `primer_examples/primer_12_threads.py`

```python
"""Primer 6: create and join a Python thread."""

from __future__ import annotations

import threading
import time


def download_document(document_id: str) -> None:
    """Simulate a blocking document download."""
    print(f"Download started for {document_id}.")
    time.sleep(0.2)
    print(f"Download finished for {document_id}.")


def main() -> None:
    """Run blocking work in a separate thread."""
    worker_thread = threading.Thread(
        target=download_document,
        args=("invoice-123",),
        name="document-download-thread",
    )

    print("Starting thread.")
    worker_thread.start()

    print("Main thread can continue while download waits.")
    worker_thread.join()

    print("Thread has finished.")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_12_threads
```

Expected output resembles:

```text
Starting thread.
Download started for invoice-123.
Main thread can continue while download waits.
Download finished for invoice-123.
Thread has finished.
```

The order of the two middle lines can vary slightly because thread scheduling is nondeterministic.

---

# Step 3: Observe a Thread Race Condition

## The Target

See why shared mutable state needs synchronization.

## The Concept

This operation looks simple:

```python
counter += 1
```

But it is conceptually several steps:

```text
Read counter
Add one
Write counter
```

If multiple threads interleave those steps, updates can be lost.

A `threading.Lock` is like a single key to a locked storage room. Only one thread may enter the critical section at a time.

## The Implementation

Create this file.

## `primer_examples/primer_13_thread_lock.py`

```python
"""Primer 6: protect shared mutable thread state with a lock."""

from __future__ import annotations

import threading


class SafeCounter:
    """A counter whose updates are protected by one mutex lock."""

    def __init__(self) -> None:
        self._value = 0
        self._lock = threading.Lock()

    @property
    def value(self) -> int:
        """Return current counter value safely."""
        with self._lock:
            return self._value

    def increment(self) -> None:
        """Add one while holding the lock."""
        with self._lock:
            self._value += 1


def increment_many_times(counter: SafeCounter, count: int) -> None:
    """Increment shared counter repeatedly."""
    for _ in range(count):
        counter.increment()


def main() -> None:
    """Start several threads that safely update shared state."""
    counter = SafeCounter()
    increments_per_thread = 50_000

    threads = [
        threading.Thread(
            target=increment_many_times,
            args=(counter, increments_per_thread),
            name=f"counter-thread-{number}",
        )
        for number in range(4)
    ]

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()

    expected = len(threads) * increments_per_thread

    print(f"Expected count: {expected}")
    print(f"Actual count: {counter.value}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_13_thread_lock
```

Expected output:

```text
Expected count: 200000
Actual count: 200000
```

The lock ensures every increment is accounted for.

---

# Step 4: Understand the GIL

## The Target

Understand why CPU-bound Python code usually does not become faster with multiple threads.

## The Concept

CPython has a **Global Interpreter Lock**, called the **GIL**.

Within one CPython process, only one thread can execute Python bytecode at a time.

This does **not** mean threads are useless.

Threads are useful when they mostly wait:

```text
Thread A waits for network response.
Thread B waits for disk read.
Thread C waits for external service.
```

While one thread waits in a blocking system call, another can often run.

But for CPU-heavy pure Python loops, several threads generally compete for the same GIL rather than using several CPU cores in parallel.

Think of the GIL as one shared whiteboard marker. Many people can be in the room, but only one can write Python instructions on the board at a time.

## The Implementation

Create this file.

## `primer_examples/primer_14_gil_cpu_threads.py`

```python
"""Primer 6: compare one CPU-bound thread with two CPU-bound threads."""

from __future__ import annotations

import threading
import time


def calculate(iterations: int) -> int:
    """Perform intentionally CPU-bound Python arithmetic."""
    total = 0

    for value in range(iterations):
        total += value % 7

    return total


def run_single_thread(total_iterations: int) -> float:
    """Measure all work in the current thread."""
    started_at = time.perf_counter()

    calculate(total_iterations)

    return time.perf_counter() - started_at


def run_two_threads(iterations_per_thread: int) -> float:
    """Measure equal total work split between two Python threads."""
    threads = [
        threading.Thread(target=calculate, args=(iterations_per_thread,)),
        threading.Thread(target=calculate, args=(iterations_per_thread,)),
    ]

    started_at = time.perf_counter()

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()

    return time.perf_counter() - started_at


def main() -> None:
    """Compare elapsed time for equal total CPU work."""
    iterations_per_thread = 5_000_000
    total_iterations = iterations_per_thread * 2

    single_thread_time = run_single_thread(total_iterations)
    two_thread_time = run_two_threads(iterations_per_thread)

    print(f"One thread: {single_thread_time:.3f} seconds")
    print(f"Two threads: {two_thread_time:.3f} seconds")
    print(
        "Exact values vary by machine. For pure Python CPU work, two threads "
        "are usually similar to or slower than one thread doing equal work."
    )


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_14_gil_cpu_threads
```

Expected output resembles:

```text
One thread: 0.450 seconds
Two threads: 0.490 seconds
Exact values vary by machine. For pure Python CPU work, two threads are usually similar to or slower than one thread doing equal work.
```

Do not compare exact timings across machines. The key observation is that two CPU-bound Python threads do not usually halve elapsed time.

---

# Step 5: Run CPU Work in a Separate Process

## The Target

Use `ProcessPoolExecutor` to execute CPU-bound work outside the current interpreter process.

## The Concept

Each process has:

- its own Python interpreter;
- its own GIL;
- its own memory.

That allows separate CPU cores to run pure Python calculations in parallel.

The cost is that processes need data copied or serialized between them.

This means process tasks should use simple inputs and outputs:

```python
int
str
list[int]
dict[str, str]
```

Avoid passing:

```text
Open files
Database connections
Sockets
Event loops
Locks
Live framework objects
```

## The Implementation

Create this file.

## `primer_examples/primer_15_process_pool.py`

```python
"""Primer 6: run CPU-bound work through a process pool."""

from __future__ import annotations

from concurrent.futures import ProcessPoolExecutor
import os


def count_primes(limit: int) -> int:
    """Count prime numbers below limit using CPU-heavy pure Python work."""
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


def main() -> None:
    """Submit CPU work to one or more process workers."""
    worker_count = min(2, os.cpu_count() or 1)

    with ProcessPoolExecutor(max_workers=worker_count) as executor:
        first_future = executor.submit(count_primes, 50_000)
        second_future = executor.submit(count_primes, 60_000)

        first_result = first_future.result()
        second_result = second_future.result()

    print(f"Primes below 50,000: {first_result}")
    print(f"Primes below 60,000: {second_result}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_15_process_pool
```

Expected output:

```text
Primes below 50,000: 5133
Primes below 60,000: 6057
```

---

# Step 6: Understand the `__main__` Guard

## The Target

Understand why multiprocessing examples use:

```python
if __name__ == "__main__":
```

## The Concept

Different operating systems create processes differently.

On systems using the **spawn** process start method, a child process imports the original module to locate the target function.

Without this guard:

```python
main()
```

could run again inside every child process.

That can cause:

- recursive process creation;
- repeated startup;
- duplicate task submission;
- confusing runtime failures.

The guard means:

> “Run this startup code only when this file is executed as the program entry point, not when it is imported by a child process.”

## The Implementation

Create this intentionally safe process example.

## `primer_examples/primer_16_main_guard.py`

```python
"""Primer 6: demonstrate a multiprocessing-safe program entry point."""

from __future__ import annotations

from concurrent.futures import ProcessPoolExecutor


def square(value: int) -> int:
    """Return square of one integer in a child-process-safe function."""
    return value * value


def main() -> None:
    """Create a process pool only from the main program entry point."""
    with ProcessPoolExecutor(max_workers=1) as executor:
        future = executor.submit(square, 12)
        result = future.result()

    print(f"Square result: {result}")


if __name__ == "__main__":
    # Child processes may import this module, but they do not invoke main().
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_16_main_guard
```

Expected output:

```text
Square result: 144
```

---

# Step 7: Connect Process Work to PulseQueue CPU Tasks

## The Target

Register and execute a CPU task through `PulseQueueRuntime`.

## The Concept

PulseQueue makes the execution boundary explicit.

For async I/O:

```python
@app.task(queue="emails")
async def send_email() -> str:
    ...
```

For CPU-bound Python work:

```python
@app.cpu_task(queue="analytics")
def calculate() -> int:
    ...
```

The second form is not merely stylistic. It tells the worker to execute the function through its process pool.

## The Implementation

Create this file.

## `primer_examples/primer_17_pulsequeue_cpu_task.py`

```python
"""Primer 6: execute CPU-bound work through PulseQueue."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime


app = PulseQueue("primer_cpu_demo")


@app.cpu_task(queue="analytics", timeout_seconds=5.0)
def calculate_sum_of_squares(limit: int) -> int:
    """Perform CPU-bound pure Python calculation."""
    total = 0

    for value in range(limit):
        total += value * value

    return total


async def heartbeat() -> None:
    """Show parent event loop remains responsive during CPU process work."""
    for number in range(4):
        print(f"Event-loop heartbeat {number}")
        await asyncio.sleep(0.05)


async def main() -> None:
    """Submit one CPU task and await it alongside async work."""
    async with PulseQueueRuntime(
        app,
        worker_concurrency=1,
        cpu_processes=1,
    ) as runtime:
        receipt = await runtime.submit(
            "analytics.calculate_sum_of_squares",
            1_000_000,
        )

        result, _ = await asyncio.gather(
            receipt.result(timeout_seconds=10.0),
            heartbeat(),
        )

        print(f"CPU task result: {result}")
        print(f"Worker stats: {runtime.worker.stats()}")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.primer_17_pulsequeue_cpu_task
```

Expected output includes:

```text
Event-loop heartbeat 0
Event-loop heartbeat 1
Event-loop heartbeat 2
Event-loop heartbeat 3
CPU task result: 333332833333500000
```

The exact ordering can vary, but heartbeat messages should continue while the CPU task executes.

---

# Primer 6 Reference: Choosing a Concurrency Tool

| Work type | Best starting choice |
|---|---|
| Fast local calculation | Ordinary synchronous code |
| Async HTTP/database client | `asyncio` coroutine |
| Blocking external SDK | `asyncio.to_thread(...)` |
| Blocking file or network call | Thread boundary |
| CPU-heavy pure Python loop | Process pool |
| Long-lived durable background work | Broker plus worker fleet |
| Native library computation | Benchmark; it may release the GIL |

---

# Primer 6 Completion Checklist

Before continuing to advanced concurrent worker architecture, confirm that you can:

- [ ] Explain the difference between a thread and a process.
- [ ] Explain why threads share memory.
- [ ] Use `threading.Lock` for shared mutable state.
- [ ] Explain the CPython GIL accurately.
- [ ] Explain why CPU-bound Python threads do not normally scale across cores.
- [ ] Use `ProcessPoolExecutor` for CPU-bound functions.
- [ ] Define process functions at module scope.
- [ ] Explain why `if __name__ == "__main__":` is required.
- [ ] Distinguish `@app.task(...)` from `@app.cpu_task(...)`.
