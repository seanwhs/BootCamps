# Part 4: The GIL, Threads, Processes, and Choosing the Right Workload Model

Before we build an asynchronous task worker, we need to answer a critical architectural question:

> What kind of work is each task doing?

Python offers several ways to run work concurrently:

- ordinary synchronous execution;
- threads;
- processes;
- asynchronous I/O with `asyncio`.

They are not interchangeable. Choosing the wrong model can make a system slower, less reliable, and harder to operate.

This part explains the **Global Interpreter Lock (GIL)** and builds practical utilities for:

- running blocking I/O safely in threads;
- running CPU-heavy work in separate processes;
- selecting an execution strategy based on workload type;
- verifying that tasks do not accidentally block the event loop.

---

# Important Correction Before Continuing

Part 3 introduced a `Task` class with `__slots__` and then used `functools.update_wrapper(...)`.

`update_wrapper(...)` stores function-style metadata—including `__name__`, `__doc__`, and `__wrapped__`—on the wrapper object. A slot-only object cannot accept those attributes unless it has an instance dictionary.

We will preserve the memory-awareness of slots while allowing wrapper metadata by adding `__dict__` to `Task.__slots__`.

## The Target

Correct `Task` so task registration and introspection work correctly.

## The Concept

`__slots__` is like giving an object a fixed set of labeled storage drawers. It reduces memory use for many small objects because Python does not need to create a general-purpose attribute dictionary for every instance.

However, `functools.update_wrapper(...)` needs to add metadata dynamically. Adding `"__dict__"` gives the object one flexible drawer for that metadata.

We will examine the deeper memory trade-off in the CPython memory-management module.

## The Implementation

Replace the complete file below.

## `src/pulsequeue/task.py`

```python
"""Task definitions and introspection helpers for PulseQueue."""

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
    """A registered asynchronous callable and its validated configuration.

    The task remains directly callable. Calling it executes the wrapped
    coroutine function normally. In a later concurrency phase, delay(...)
    will submit the task to a broker instead of executing it immediately.
    """

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
        """Create a task after validating its callable and declared name."""
        if not inspect.iscoroutinefunction(function):
            raise TypeError(
                f"Task {function.__qualname__!r} must be declared with 'async def'."
            )

        if not options.name:
            raise ValueError("Task option 'name' cannot be empty.")

        self._function = function
        self._options = options
        self._signature = inspect.signature(function)

        source_file = inspect.getsourcefile(function)
        source_lines, source_line = inspect.getsourcelines(function)

        # getsourcefile can return None for unusual dynamically-created
        # functions. We retain a clear sentinel instead of failing registration.
        self._source_file = (
            Path(source_file).resolve() if source_file is not None else None
        )
        self._source_line = source_line if source_lines else None

        # Task is an object rather than a native Python function. update_wrapper
        # copies function-oriented metadata onto this object so IDEs, debuggers,
        # decorators, and inspect.signature continue to show useful details.
        #
        # __dict__ appears in __slots__ specifically to allow this metadata.
        functools.update_wrapper(self, function)

    @property
    def function(self) -> Callable[ParametersT, Awaitable[ResultT]]:
        """Return the original asynchronous Python function."""
        return self._function

    @property
    def options(self) -> TaskOptions:
        """Return validated task configuration."""
        return self._options

    @property
    def name(self) -> str:
        """Return the queue-qualified stable task name."""
        return self._options.qualified_name

    @property
    def signature(self) -> inspect.Signature:
        """Return the callable signature captured at registration time."""
        return self._signature

    @property
    def source_file(self) -> Path | None:
        """Return the resolved source file when Python can identify one."""
        return self._source_file

    @property
    def source_line(self) -> int | None:
        """Return the first source line for the task function when available."""
        return self._source_line

    def bind_arguments(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> inspect.BoundArguments:
        """Validate proposed arguments without executing the task."""
        return self._signature.bind(*args, **kwargs)

    async def __call__(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> ResultT:
        """Execute the underlying coroutine after validating its arguments."""
        self.bind_arguments(*args, **kwargs)
        return await self._function(*args, **kwargs)

    def describe(self) -> dict[str, Any]:
        """Return serializable task metadata for diagnostics and tooling."""
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
            "metadata": self._options.metadata.as_dict(),
        }

    def __repr__(self) -> str:
        """Return a concise representation suitable for debug logs."""
        return (
            f"{type(self).__name__}("
            f"name={self.name!r}, "
            f"signature={str(self._signature)!r}"
            f")"
        )
```

## The Verification

Run all existing tests:

```bash
python -m pytest -q
```

Expected result:

```text
..............                                                           [100%]
14 passed
```

Your count can be higher if you created additional tests.

---

## Step 1: Understand the Global Interpreter Lock

## The Target

Run a small experiment that compares CPU-bound work in one thread versus several threads.

## The Concept

**CPython**—the standard Python interpreter most developers use—has a mechanism called the **Global Interpreter Lock**, usually shortened to **GIL**.

The GIL allows only one thread at a time to execute Python bytecode in a single CPython process.

This does **not** mean threads are useless:

- Threads can work well when code mostly waits for network, disk, or other external operations.
- Many native libraries release the GIL while performing expensive work.
- Threads are often useful for integrating blocking libraries into an async application.

But for Python code doing continuous CPU calculations, several threads usually do not provide true multi-core parallel execution.

Think of the GIL as one shared marker in a meeting room. Several people can be present, but only the person holding the marker can write on the whiteboard. If everyone’s work requires writing constantly, adding people does not create more writing space.

## The Implementation

Create this demonstration.

## `examples/15_gil_threads.py`

```python
"""Demonstrate why CPU-bound Python work does not scale with threads."""

from __future__ import annotations

import threading
import time


def count_down(iterations: int) -> int:
    """Perform CPU-bound Python bytecode work."""
    total = 0

    for value in range(iterations):
        total += value % 7

    return total


def run_single_thread(iterations: int) -> float:
    """Measure one CPU-bound calculation in the current thread."""
    started_at = time.perf_counter()
    count_down(iterations)
    return time.perf_counter() - started_at


def run_two_threads(iterations_per_thread: int) -> float:
    """Measure two CPU-bound calculations using two Python threads."""
    threads = [
        threading.Thread(target=count_down, args=(iterations_per_thread,)),
        threading.Thread(target=count_down, args=(iterations_per_thread,)),
    ]

    started_at = time.perf_counter()

    for thread in threads:
        thread.start()

    for thread in threads:
        thread.join()

    return time.perf_counter() - started_at


def main() -> None:
    """Compare one thread with two threads performing equal total work."""
    iterations_per_thread = 10_000_000
    total_iterations = iterations_per_thread * 2

    one_thread_seconds = run_single_thread(total_iterations)
    two_thread_seconds = run_two_threads(iterations_per_thread)

    print(f"One thread, {total_iterations:,} iterations: {one_thread_seconds:.3f}s")
    print(
        "Two threads, "
        f"{iterations_per_thread:,} iterations each: {two_thread_seconds:.3f}s"
    )
    print(
        "Note: timings vary by machine. Two CPU-bound Python threads are "
        "normally similar to or slower than one thread doing the same total work."
    )


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/15_gil_threads.py
```

Typical output resembles:

```text
One thread, 20,000,000 iterations: 0.900s
Two threads, 10,000,000 iterations each: 0.960s
Note: timings vary by machine. Two CPU-bound Python threads are normally similar to or slower than one thread doing the same total work.
```

Do **not** compare exact timings with another computer. The meaningful observation is that two CPU-bound threads usually do not cut elapsed time in half.

---

## Step 2: Define Workload Categories

## The Target

Create explicit workload categories that future task definitions and worker logic can use.

## The Concept

A task framework should not guess whether work is safe to run on the event loop.

We will classify work into three categories:

| Workload | Meaning | Preferred execution model |
|---|---|---|
| `ASYNC_IO` | Coroutine-based work that frequently awaits I/O | `asyncio` event loop |
| `BLOCKING_IO` | Synchronous code that waits on disk, network, or a legacy library | Thread |
| `CPU_BOUND` | Expensive computation written in Python | Process |

An **event loop** is the coordinator used by `asyncio`. It switches to another coroutine when the current coroutine reaches an `await` point.

A blocking function never yields control. Calling it directly from an event loop would freeze every other coroutine using that loop. We will later use threads to isolate blocking I/O and processes to isolate CPU-heavy Python work.

## The Implementation

Create the workload module.

## `src/pulsequeue/execution.py`

```python
"""Execution-model primitives for PulseQueue workers."""

from __future__ import annotations

from enum import StrEnum


class WorkloadKind(StrEnum):
    """Describe the dominant kind of work performed by a callable.

    Values inherit from str so they serialize naturally in JSON, logs, and
    configuration files while retaining enum validation in Python code.
    """

    ASYNC_IO = "async_io"
    BLOCKING_IO = "blocking_io"
    CPU_BOUND = "cpu_bound"
```

Update the package exports.

## `src/pulsequeue/__init__.py`

```python
"""PulseQueue: an educational high-concurrency Python task framework."""

from pulsequeue.app import PulseQueue
from pulsequeue.execution import WorkloadKind
from pulsequeue.metadata import TaskMetadata
from pulsequeue.registry import DuplicateTaskError, UnknownTaskError
from pulsequeue.task import Task

__all__ = [
    "DuplicateTaskError",
    "PulseQueue",
    "Task",
    "TaskMetadata",
    "UnknownTaskError",
    "WorkloadKind",
]

__version__ = "0.1.0"
```

Create a small verification example.

## `examples/16_workload_kinds.py`

```python
"""Demonstrate explicit workload classification."""

from __future__ import annotations

import json

from pulsequeue import WorkloadKind


workloads = {
    "fetch_user_profile": WorkloadKind.ASYNC_IO,
    "legacy_pdf_download": WorkloadKind.BLOCKING_IO,
    "generate_thumbnail_pixels": WorkloadKind.CPU_BOUND,
}

for task_name, workload_kind in workloads.items():
    print(f"{task_name}: {workload_kind.value}")

print("\nJSON-compatible values:")
print(json.dumps(workloads, indent=2))
```

## The Verification

Run:

```bash
python examples/16_workload_kinds.py
```

Expected output:

```text
fetch_user_profile: async_io
legacy_pdf_download: blocking_io
generate_thumbnail_pixels: cpu_bound

JSON-compatible values:
{
  "fetch_user_profile": "async_io",
  "legacy_pdf_download": "blocking_io",
  "generate_thumbnail_pixels": "cpu_bound"
}
```

---

## Step 3: Run Blocking I/O Safely in a Thread

## The Target

Create a helper that runs a synchronous blocking function in a worker thread without freezing the `asyncio` event loop.

## The Concept

Suppose an async service must call a legacy SDK:

```python
def legacy_sdk_call() -> str:
    time.sleep(2)
    return "done"
```

Calling it directly from an async function is harmful:

```python
async def bad() -> str:
    return legacy_sdk_call()  # Blocks the whole event loop.
```

Instead, Python 3.9+ provides:

```python
await asyncio.to_thread(legacy_sdk_call)
```

This sends the blocking function to a thread managed by Python’s default thread pool. While that thread waits for the external operation, the event loop remains free to run other coroutines.

Threads are appropriate here because the blocking work is mostly **waiting**, not continuously executing CPU-heavy Python code.

## The Implementation

Expand `src/pulsequeue/execution.py` to include thread execution.

## `src/pulsequeue/execution.py`

```python
"""Execution-model primitives for PulseQueue workers."""

from __future__ import annotations

import asyncio
from collections.abc import Callable
from enum import StrEnum
from typing import ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class WorkloadKind(StrEnum):
    """Describe the dominant kind of work performed by a callable."""

    ASYNC_IO = "async_io"
    BLOCKING_IO = "blocking_io"
    CPU_BOUND = "cpu_bound"


async def run_blocking_io(
    function: Callable[ParametersT, ResultT],
    /,
    *args: ParametersT.args,
    **kwargs: ParametersT.kwargs,
) -> ResultT:
    """Run a blocking synchronous function in a worker thread.

    Use this for functions that spend significant time waiting on external
    resources, such as legacy HTTP clients, blocking database drivers, file
    operations, or SDKs without native asyncio support.

    Do not use it as a general CPU-parallelism mechanism. CPU-bound Python
    code in threads remains limited by the CPython Global Interpreter Lock.
    """
    return await asyncio.to_thread(function, *args, **kwargs)
```

Create this example.

## `examples/17_blocking_io_thread.py`

```python
"""Run blocking I/O-like work in a thread while the event loop stays responsive."""

from __future__ import annotations

import asyncio
import time

from pulsequeue.execution import run_blocking_io


def blocking_legacy_download(document_id: str) -> str:
    """Simulate a blocking SDK call that waits for a remote service."""
    time.sleep(1.0)
    return f"downloaded document {document_id}"


async def heartbeat() -> None:
    """Print periodic output to prove the event loop can still make progress."""
    for count in range(5):
        print(f"heartbeat {count}")
        await asyncio.sleep(0.2)


async def main() -> None:
    """Run blocking work and normal async work concurrently."""
    download_task = asyncio.create_task(
        run_blocking_io(blocking_legacy_download, "invoice-123")
    )
    heartbeat_task = asyncio.create_task(heartbeat())

    download_result, _ = await asyncio.gather(download_task, heartbeat_task)

    print(download_result)


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python examples/17_blocking_io_thread.py
```

Expected output resembles:

```text
heartbeat 0
heartbeat 1
heartbeat 2
heartbeat 3
heartbeat 4
downloaded document invoice-123
```

The exact order of the final download message can vary slightly. The important result is that heartbeats continue while the blocking function sleeps.

For comparison, temporarily replace this line:

```python
run_blocking_io(blocking_legacy_download, "invoice-123")
```

with this unsafe direct call:

```python
blocking_legacy_download("invoice-123")
```

The program will no longer behave correctly because `asyncio.create_task(...)` requires a coroutine. More importantly, if you called that blocking function directly inside `main`, heartbeats would not begin until after the one-second sleep finished.

Restore the original working version before moving on.

---

## Step 4: Run CPU-Bound Work in a Process

## The Target

Create a helper that runs synchronous CPU-heavy work in a separate process.

## The Concept

A **process** is an independently running Python interpreter with its own memory and its own GIL.

Because processes do not share a GIL, CPU-bound Python work can run on multiple CPU cores in parallel.

The trade-off is cost:

- Process creation and communication are more expensive than threads.
- Arguments and return values must usually be serialized—converted to transferable bytes—using Python’s pickle mechanism.
- Functions submitted to a process must be importable from a module-level location.

This last rule is especially important:

✅ Good:

```python
def calculate_checksum(data: bytes) -> str:
    ...
```

❌ Not portable across process-start methods:

```python
async def main() -> None:
    def calculate_checksum(data: bytes) -> str:
        ...
```

A nested function cannot reliably be imported by a newly created child process.

## The Implementation

Replace `src/pulsequeue/execution.py` with this complete version.

## `src/pulsequeue/execution.py`

```python
"""Execution-model primitives for PulseQueue workers."""

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
    """Describe the dominant kind of work performed by a callable."""

    ASYNC_IO = "async_io"
    BLOCKING_IO = "blocking_io"
    CPU_BOUND = "cpu_bound"


async def run_blocking_io(
    function: Callable[ParametersT, ResultT],
    /,
    *args: ParametersT.args,
    **kwargs: ParametersT.kwargs,
) -> ResultT:
    """Run a blocking synchronous function in a worker thread.

    Use this for functions that spend significant time waiting on external
    resources, such as legacy HTTP clients, blocking database drivers, file
    operations, or SDKs without native asyncio support.

    Do not use it as a general CPU-parallelism mechanism. CPU-bound Python
    code in threads remains limited by the CPython Global Interpreter Lock.
    """
    return await asyncio.to_thread(function, *args, **kwargs)


async def run_cpu_bound(
    executor: ProcessPoolExecutor,
    function: Callable[ParametersT, ResultT],
    /,
    *args: ParametersT.args,
    **kwargs: ParametersT.kwargs,
) -> ResultT:
    """Run CPU-bound synchronous work in a separate interpreter process.

    The function must be defined at module scope in an importable module.
    Its arguments and return value must be pickleable.

    The caller owns executor lifecycle management. Keeping the executor alive
    across many tasks avoids paying process-startup cost for every submission.
    """
    event_loop = asyncio.get_running_loop()

    # run_in_executor accepts positional arguments only. partial preserves
    # keyword arguments while producing a zero-argument callable.
    callable_with_arguments = partial(function, *args, **kwargs)

    return await event_loop.run_in_executor(executor, callable_with_arguments)
```

Now create a module-level CPU function that is safe for process execution.

## `examples/cpu_functions.py`

```python
"""Importable CPU-bound functions used by multiprocessing demonstrations."""

from __future__ import annotations


def count_primes(limit: int) -> int:
    """Count prime numbers smaller than limit using a simple CPU-heavy algorithm."""
    if limit < 2:
        return 0

    prime_count = 0

    for candidate in range(2, limit):
        is_prime = True
        divisor = 2

        while divisor * divisor <= candidate:
            if candidate % divisor == 0:
                is_prime = False
                break

            divisor += 1

        if is_prime:
            prime_count += 1

    return prime_count
```

Create the process demonstration.

## `examples/18_cpu_bound_process.py`

```python
"""Run CPU-bound work in process workers without blocking the event loop."""

from __future__ import annotations

import asyncio
from concurrent.futures import ProcessPoolExecutor
import os

from cpu_functions import count_primes
from pulsequeue.execution import run_cpu_bound


async def heartbeat() -> None:
    """Show that the parent event loop stays responsive during CPU work."""
    for count in range(5):
        print(f"parent event-loop heartbeat {count}")
        await asyncio.sleep(0.2)


async def main() -> None:
    """Submit two CPU-bound calculations to separate process workers."""
    worker_count = min(2, os.cpu_count() or 1)

    # The context manager shuts worker processes down cleanly, including if
    # task execution raises an exception.
    with ProcessPoolExecutor(max_workers=worker_count) as executor:
        first_calculation = asyncio.create_task(
            run_cpu_bound(executor, count_primes, 100_000)
        )
        second_calculation = asyncio.create_task(
            run_cpu_bound(executor, count_primes, 105_000)
        )
        heartbeat_task = asyncio.create_task(heartbeat())

        first_result, second_result, _ = await asyncio.gather(
            first_calculation,
            second_calculation,
            heartbeat_task,
        )

    print(f"Primes below 100,000: {first_result}")
    print(f"Primes below 105,000: {second_result}")


if __name__ == "__main__":
    # This guard is mandatory for multiprocessing-safe scripts, especially on
    # Windows and macOS where child processes commonly import the main module.
    asyncio.run(main())
```

## The Verification

Run the example from the project root:

```bash
python examples/18_cpu_bound_process.py
```

Expected output includes:

```text
parent event-loop heartbeat 0
parent event-loop heartbeat 1
parent event-loop heartbeat 2
parent event-loop heartbeat 3
parent event-loop heartbeat 4
Primes below 100,000: 9592
Primes below 105,000: 10024
```

The heartbeat output proves that the parent event loop remains responsive while CPU-heavy work runs elsewhere.

The exact interleaving may vary. On a one-core machine, the process work will not become faster, but it still remains isolated from the parent event loop.

---

## Step 5: Add an Executor Lifecycle Manager

## The Target

Create a context-managed process executor that future workers can start and stop safely.

## The Concept

Creating a new `ProcessPoolExecutor` for every task is inefficient. It repeatedly starts Python interpreter processes, which is expensive.

A long-lived worker should instead:

1. Create a pool during startup.
2. Reuse it for CPU-bound submissions.
3. Shut it down cleanly during application shutdown.

A **context manager** is Python’s resource-lifecycle tool. It is like checking equipment out of a workshop:

```python
with resource:
    use_resource()
```

When the block ends—even if an exception occurs—Python performs cleanup.

Because our eventual worker is asynchronous, we will use an **asynchronous context manager**:

```python
async with resource:
    await use_resource()
```

## The Implementation

Create this module.

## `src/pulsequeue/executors.py`

```python
"""Lifecycle-managed executor resources for PulseQueue workers."""

from __future__ import annotations

from concurrent.futures import ProcessPoolExecutor
from typing import Self


class ProcessExecutorPool:
    """Own a reusable ProcessPoolExecutor with explicit async lifecycle."""

    def __init__(self, *, max_workers: int | None = None) -> None:
        """Configure a pool without starting child processes yet."""
        if max_workers is not None and max_workers < 1:
            raise ValueError("max_workers must be at least 1 when provided.")

        self._max_workers = max_workers
        self._executor: ProcessPoolExecutor | None = None

    @property
    def executor(self) -> ProcessPoolExecutor:
        """Return the started executor or explain the lifecycle mistake."""
        if self._executor is None:
            raise RuntimeError(
                "Process executor is not running. Use 'async with "
                "ProcessExecutorPool(...) as pool:' before accessing it."
            )

        return self._executor

    @property
    def is_running(self) -> bool:
        """Return whether the process pool has been started."""
        return self._executor is not None

    async def __aenter__(self) -> Self:
        """Start child worker processes lazily when entering the async context."""
        if self._executor is not None:
            raise RuntimeError("Process executor pool is already running.")

        self._executor = ProcessPoolExecutor(max_workers=self._max_workers)
        return self

    async def __aexit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: object | None,
    ) -> None:
        """Stop process workers and wait for submitted work to finish."""
        executor = self._executor
        self._executor = None

        if executor is not None:
            # shutdown is blocking because it waits for process cleanup.
            # We move that wait to a thread so the event loop remains usable
            # during graceful shutdown.
            await __import__("asyncio").to_thread(
                executor.shutdown,
                wait=True,
                cancel_futures=True,
            )
```

The use of `__import__("asyncio")` is technically valid but unnecessarily unclear. Replace the full file with this cleaner production version:

## `src/pulsequeue/executors.py`

```python
"""Lifecycle-managed executor resources for PulseQueue workers."""

from __future__ import annotations

import asyncio
from concurrent.futures import ProcessPoolExecutor
from types import TracebackType
from typing import Self


class ProcessExecutorPool:
    """Own a reusable ProcessPoolExecutor with explicit async lifecycle."""

    def __init__(self, *, max_workers: int | None = None) -> None:
        """Configure a pool without starting child processes yet."""
        if max_workers is not None and max_workers < 1:
            raise ValueError("max_workers must be at least 1 when provided.")

        self._max_workers = max_workers
        self._executor: ProcessPoolExecutor | None = None

    @property
    def executor(self) -> ProcessPoolExecutor:
        """Return the started executor or explain the lifecycle mistake."""
        if self._executor is None:
            raise RuntimeError(
                "Process executor is not running. Use "
                "'async with ProcessExecutorPool(...) as pool:' before "
                "accessing it."
            )

        return self._executor

    @property
    def is_running(self) -> bool:
        """Return whether the process pool has been started."""
        return self._executor is not None

    async def __aenter__(self) -> Self:
        """Start child worker processes lazily when entering the async context."""
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
        """Stop process workers and wait for submitted work to finish."""
        executor = self._executor
        self._executor = None

        if executor is not None:
            # ProcessPoolExecutor.shutdown blocks while processes finish and
            # terminate. Run that blocking cleanup outside the event loop.
            await asyncio.to_thread(
                executor.shutdown,
                wait=True,
                cancel_futures=True,
            )
```

Create a lifecycle example.

## `examples/19_process_pool_lifecycle.py`

```python
"""Demonstrate lifecycle-safe reuse of a process worker pool."""

from __future__ import annotations

import asyncio

from cpu_functions import count_primes
from pulsequeue.execution import run_cpu_bound
from pulsequeue.executors import ProcessExecutorPool


async def main() -> None:
    """Start one pool, submit multiple jobs, then shut it down safely."""
    pool = ProcessExecutorPool(max_workers=2)

    print(f"Before startup, pool running: {pool.is_running}")

    async with pool:
        print(f"Inside context, pool running: {pool.is_running}")

        results = await asyncio.gather(
            run_cpu_bound(pool.executor, count_primes, 50_000),
            run_cpu_bound(pool.executor, count_primes, 60_000),
        )

        print(f"Primes below 50,000: {results[0]}")
        print(f"Primes below 60,000: {results[1]}")

    print(f"After shutdown, pool running: {pool.is_running}")

    try:
        _ = pool.executor
    except RuntimeError as error:
        print(f"Lifecycle protection: {error}")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python examples/19_process_pool_lifecycle.py
```

Expected output includes:

```text
Before startup, pool running: False
Inside context, pool running: True
Primes below 50,000: 5133
Primes below 60,000: 6057
After shutdown, pool running: False
Lifecycle protection: Process executor is not running.
```

---

## Step 6: Test Thread and Process Execution Helpers

## The Target

Add tests that confirm the framework chooses the correct execution boundary for blocking and CPU-bound work.

## The Concept

Concurrency bugs are often timing-dependent. A test suite cannot prove every scheduling outcome, but it can verify core contracts:

- Blocking work runs without preventing unrelated coroutine progress.
- CPU functions run through a process executor.
- Executor lifecycle is enforced.
- Invalid pool configuration fails early.

For process tests, module-level functions are necessary because worker processes must import them.

## The Implementation

Create the following test helper module.

## `tests/process_functions.py`

```python
"""Importable functions used by multiprocessing tests."""

from __future__ import annotations


def multiply(left: int, right: int) -> int:
    """Return a simple CPU-process test value."""
    return left * right
```

Create the test module.

## `tests/test_execution.py`

```python
"""Tests for thread and process execution helpers."""

from __future__ import annotations

import asyncio
import time

import pytest

from pulsequeue.execution import WorkloadKind, run_blocking_io, run_cpu_bound
from pulsequeue.executors import ProcessExecutorPool
from tests.process_functions import multiply


def blocking_add(left: int, right: int) -> int:
    """Simulate a short blocking operation."""
    time.sleep(0.05)
    return left + right


def test_workload_kind_values_are_json_friendly_strings() -> None:
    """Workload categories should preserve their stable string values."""
    assert WorkloadKind.ASYNC_IO == "async_io"
    assert WorkloadKind.BLOCKING_IO == "blocking_io"
    assert WorkloadKind.CPU_BOUND == "cpu_bound"


def test_run_blocking_io_returns_synchronous_result() -> None:
    """Blocking work should execute in a thread and return its result."""
    result = asyncio.run(run_blocking_io(blocking_add, 20, 22))

    assert result == 42


def test_process_executor_pool_requires_started_lifecycle() -> None:
    """Accessing a process executor before startup must fail clearly."""
    pool = ProcessExecutorPool(max_workers=1)

    with pytest.raises(RuntimeError, match="not running"):
        _ = pool.executor


def test_process_executor_pool_rejects_zero_workers() -> None:
    """Invalid process-pool sizes should fail during configuration."""
    with pytest.raises(ValueError, match="at least 1"):
        ProcessExecutorPool(max_workers=0)


def test_run_cpu_bound_returns_process_result() -> None:
    """CPU work should execute through the reusable process pool."""

    async def run_test() -> int:
        async with ProcessExecutorPool(max_workers=1) as pool:
            return await run_cpu_bound(pool.executor, multiply, 6, 7)

    assert asyncio.run(run_test()) == 42
```

The test package needs an initializer so `tests.process_functions` is reliably importable. Create it now.

## `tests/__init__.py`

```python
"""Test support package for the PulseQueue tutorial."""
```

## The Verification

Run the full suite:

```bash
python -m pytest -q
```

Expected output:

```text
...................                                                      [100%]
19 passed
```

The exact test count may differ, but all tests must pass.

---

# Phase 2 Reference: Selecting an Execution Model

## Decision Table

Use this table when deciding where a unit of work should run.

| Work type | Example | Recommended model | Why |
|---|---|---|---|
| Fast ordinary code | Parsing a small request | Run directly | Concurrency overhead is unnecessary |
| Native async I/O | `asyncio` HTTP or database client | `asyncio` task | Efficiently handles many waiting operations |
| Blocking I/O | Legacy SDK using `requests`, blocking file API | Thread via `asyncio.to_thread` | Keeps event loop responsive while waiting |
| CPU-heavy Python | Image transforms, simulation, prime calculation | Process pool | Separate GILs can use multiple cores |
| CPU-heavy native library | NumPy, compression library | Measure first | Libraries may release the GIL internally |
| External durable background work | Email delivery, report generation | Queue + workers | Decouples request lifecycle from work lifecycle |

---

## Thread Safety Is Not the Same as GIL Safety

The GIL prevents multiple threads from executing Python bytecode simultaneously in one process. It does **not** automatically make every operation logically thread-safe.

For example, this read-modify-write sequence can still be unsafe:

```python
shared_counter = 0

def increment() -> None:
    global shared_counter
    shared_counter += 1
```

If multiple threads perform operations that depend on shared state, use appropriate synchronization such as:

- `threading.Lock`
- `queue.Queue`
- immutable data
- message passing
- a single owner for mutable state

Our future async worker will minimize shared mutable state by using queues and explicit task envelopes.

---

## Process Serialization Constraints

When submitting to `ProcessPoolExecutor`, assume these constraints:

1. The function must be importable by a child process.
2. Arguments must be pickleable.
3. Return values must be pickleable.
4. Open network connections, locks, event loops, file handles, and most framework objects should not be passed to processes.
5. Process startup has nontrivial overhead.

This is why a process worker typically receives simple data:

```python
await run_cpu_bound(pool.executor, count_primes, 100_000)
```

rather than a live database session or an entire application object.

---

## Why We Will Keep Async and CPU Task APIs Separate

It may be tempting to make one decorator accept every kind of callable:

```python
@app.task
def anything() -> object:
    ...
```

But then the framework has to guess whether the function:

- blocks;
- consumes CPU;
- requires a process;
- is safe in a thread;
- is a coroutine;
- can be serialized.

Guessing is dangerous.

Our initial `@app.task(...)` API intentionally accepts `async def` functions only. In later parts, CPU execution will be introduced through an explicit and separately validated path.

Clear boundaries are a feature:

```text
async task       → event-loop worker
blocking I/O     → thread boundary
CPU-bound task   → process boundary
```

That design makes performance behavior understandable instead of surprising.
