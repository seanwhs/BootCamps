# Part 10: Memory Leak Detection and C Extension Basics

Memory optimization has two separate goals:

1. **Use less memory per object** when the application creates many objects.
2. **Release memory correctly** when objects are no longer useful.

`__slots__` helped with the first goal. This part focuses on the second.

We will build:

- a reusable `tracemalloc` snapshot comparison utility;
- a repeatable leak-detection workflow;
- a bounded result-retention store concept;
- a minimal native C extension;
- safe Python/C reference-ownership rules.

Before continuing, we need to correct one cancellation edge case in the retry worker from Part 7.

---

## Step 1: Correct Cancellation During Retry Backoff

### The Target

Ensure a task becomes `CANCELLED` if the worker is cancelled while it is sleeping between retry attempts.

### The Concept

In the previous worker implementation, cancellation was handled while the task function itself was executing:

```python
result = await task(...)
```

However, cancellation can also happen here:

```python
await asyncio.sleep(delay_seconds)
```

If cancellation happens during retry backoff, the task must not remain permanently in `RETRYING`.

Think of a retrying task as a package waiting in a dispatch area. If the warehouse closes while it waits, the package must be marked as cancelled—not left forever with a misleading “waiting” label.

### The Implementation

Replace the complete `src/pulsequeue/worker.py` file.

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
from pulsequeue.result import TaskResultSnapshot
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
        """Gracefully stop the worker, optionally enforcing a shutdown deadline."""
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

        await asyncio.gather(*self._consumer_tasks, return_exceptions=True)

        cancelled_queued_tasks = self._broker.cancel_pending()
        self._cancelled_tasks += cancelled_queued_tasks

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
                # Every broker get must have exactly one matching task_done call.
                self._broker.task_done()

    async def _execute_envelope(self, envelope: TaskEnvelope) -> None:
        """Execute one task, retrying configured transient failures."""
        task = self._app.get_task(envelope.task_name)

        try:
            while True:
                self._broker.mark_running(envelope.task_id)

                try:
                    result = await await_with_timeout(
                        task(*envelope.args, **dict(envelope.kwargs)),
                        timeout_seconds=task.options.timeout_seconds,
                        operation_name=envelope.task_name,
                    )
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

                    # This await is also cancellation-sensitive. The outer
                    # CancelledError handler below records terminal cancellation.
                    await asyncio.sleep(delay_seconds)
                else:
                    self._broker.mark_succeeded(envelope.task_id, result)
                    self._completed_tasks += 1
                    return
        except asyncio.CancelledError:
            # Cancellation can occur while executing user code or while waiting
            # for retry backoff. Both cases must wake receipt holders.
            self._broker.mark_cancelled(envelope.task_id)
            self._cancelled_tasks += 1
            raise

    def _result_snapshot(self, task_id: str) -> TaskResultSnapshot[object]:
        """Return one task result snapshot through the broker public API."""
        return self._broker.result_snapshot(task_id)
```

### The Verification

Add this test to the end of `tests/test_retries_and_shutdown.py`.

## `tests/test_retries_and_shutdown.py` — append

```python
def test_forced_shutdown_cancels_task_waiting_for_retry() -> None:
    """Cancellation during retry backoff must produce a terminal state."""

    async def run_test() -> None:
        app = PulseQueue("retry_backoff_shutdown")
        broker = InMemoryBroker()

        @app.task(
            queue="examples",
            max_retries=5,
            retry_delay_seconds=10.0,
        )
        async def always_fails() -> None:
            raise ConnectionError("retry later")

        worker = PulseQueueWorker(app, broker)
        await worker.start()

        receipt = await app.submit(broker, "examples.always_fails")

        for _ in range(100):
            if receipt.snapshot().state is TaskState.RETRYING:
                break

            await asyncio.sleep(0.001)
        else:
            raise AssertionError("Task never entered retrying state.")

        await worker.stop(timeout_seconds=0.01)

        assert receipt.snapshot().state is TaskState.CANCELLED

        with pytest.raises(TaskCancelledError):
            await receipt.result(timeout_seconds=0.1)

    asyncio.run(run_test())
```

Run:

```bash
python -m pytest tests/test_retries_and_shutdown.py -q
```

Expected result:

```text
.....                                                                    [100%]
5 passed
```

---

## Step 2: Build a Snapshot Comparison Tool

### The Target

Create a reusable utility that compares two `tracemalloc` snapshots.

### The Concept

A memory leak is not simply “memory is high.” It is memory that grows unexpectedly because objects remain reachable after work should be complete.

A useful workflow is:

```text
Take baseline snapshot
        ↓
Run workload repeatedly
        ↓
Force ordinary cleanup where appropriate
        ↓
Take comparison snapshot
        ↓
Inspect source locations with the largest growth
```

This is like weighing a delivery truck before and after unloading. If its weight rises after each delivery instead of returning toward baseline, something is remaining inside.

### The Implementation

Create the diagnostics module.

## `src/pulsequeue/memory_profiler.py`

```python
"""Repeatable tracemalloc-based memory-growth diagnostics."""

from __future__ import annotations

import gc
import tracemalloc
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class AllocationDifference:
    """One source location whose traced allocation changed between snapshots."""

    filename: str
    line_number: int
    size_difference_bytes: int
    count_difference: int
    source_line: str


@dataclass(frozen=True, slots=True)
class MemoryComparison:
    """A summarized comparison between two tracemalloc snapshots."""

    current_bytes: int
    peak_bytes: int
    largest_differences: tuple[AllocationDifference, ...]


class MemorySnapshotSession:
    """Own a tracemalloc session and compare allocations over a workload."""

    def __init__(self, *, traceback_limit: int = 10) -> None:
        """Configure tracing depth used to retain allocation traceback details."""
        if traceback_limit < 1:
            raise ValueError("traceback_limit must be at least 1.")

        self._traceback_limit = traceback_limit
        self._baseline: tracemalloc.Snapshot | None = None
        self._is_running = False

    def start(self) -> None:
        """Start tracing and capture a baseline after ordinary collection."""
        if self._is_running:
            raise RuntimeError("Memory tracing is already running.")

        gc.collect()
        tracemalloc.start(self._traceback_limit)
        self._baseline = tracemalloc.take_snapshot()
        self._is_running = True

    def compare(self, *, limit: int = 10) -> MemoryComparison:
        """Compare current allocations against the baseline snapshot."""
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
            traceback = difference.traceback
            frame = traceback[0]

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
        """Stop tracing and release tracer-held traceback information."""
        if not self._is_running:
            return

        tracemalloc.stop()
        self._baseline = None
        self._is_running = False
```

Create a demonstration.

## `examples/45_memory_snapshot_comparison.py`

```python
"""Compare traced memory before and after intentionally retained objects."""

from __future__ import annotations

from pulsequeue.memory_profiler import MemorySnapshotSession


retained_payloads: list[dict[str, str]] = []


def create_retained_payloads(count: int) -> None:
    """Intentionally retain objects to demonstrate allocation growth."""
    for index in range(count):
        retained_payloads.append(
            {
                "task_id": f"task-{index}",
                "task_name": "emails.send_welcome_email",
                "payload": "x" * 100,
            }
        )


def main() -> None:
    """Capture memory growth caused by an intentionally retained list."""
    session = MemorySnapshotSession(traceback_limit=5)
    session.start()

    create_retained_payloads(10_000)

    comparison = session.compare(limit=5)

    print(f"Current traced memory: {comparison.current_bytes:,} bytes")
    print(f"Peak traced memory: {comparison.peak_bytes:,} bytes")
    print("\nLargest allocation differences:")

    for difference in comparison.largest_differences:
        print(
            f"- {difference.filename}:{difference.line_number} "
            f"size_diff={difference.size_difference_bytes:+,} bytes "
            f"count_diff={difference.count_difference:+,} "
            f"source={difference.source_line!r}"
        )

    retained_payloads.clear()
    session.stop()


if __name__ == "__main__":
    main()
```

### The Verification

Run:

```bash
python examples/45_memory_snapshot_comparison.py
```

Expected output includes:

```text
Current traced memory: ... bytes
Peak traced memory: ... bytes

Largest allocation differences:
- .../examples/45_memory_snapshot_comparison.py:... size_diff=+... bytes ...
```

The exact byte counts and source lines differ by platform. The important result is that the allocation line inside `create_retained_payloads(...)` appears near the top.

---

## Step 3: Detect Growth Across Repeated Task Workloads

### The Target

Build a repeatable workload benchmark that distinguishes temporary allocations from retained allocations.

### The Concept

Not every allocation is a leak.

This is normal:

```text
Start task
Allocate temporary objects
Finish task
Temporary objects become unreachable
```

This is suspicious:

```text
Start task
Allocate objects
Store them in a global or long-lived registry
Finish task
Objects remain reachable
Repeat forever
```

We will compare two workloads:

- a healthy workload that releases objects;
- an intentionally leaky workload that retains objects.

### The Implementation

Create this example.

## `examples/46_memory_growth_workload.py`

```python
"""Compare temporary allocations with intentionally retained allocations."""

from __future__ import annotations

import gc

from pulsequeue.memory_profiler import MemorySnapshotSession


leaked_task_history: list[dict[str, object]] = []


def healthy_workload(iterations: int) -> None:
    """Create temporary task-shaped data that becomes unreachable each loop."""
    for index in range(iterations):
        temporary_record = {
            "task_id": f"healthy-{index}",
            "arguments": [index, index + 1, index + 2],
            "metadata": {"queue": "examples"},
        }

        # This use keeps the loop realistic while retaining nothing afterward.
        assert temporary_record["task_id"]


def intentionally_leaky_workload(iterations: int) -> None:
    """Retain every task-shaped record in a global list."""
    for index in range(iterations):
        leaked_task_history.append(
            {
                "task_id": f"leaked-{index}",
                "arguments": [index, index + 1, index + 2],
                "metadata": {"queue": "examples"},
            }
        )


def print_comparison(title: str, session: MemorySnapshotSession) -> None:
    """Display the largest allocation changes from one workload."""
    comparison = session.compare(limit=3)

    print(f"\n{title}")
    print(f"Current traced bytes: {comparison.current_bytes:,}")

    for difference in comparison.largest_differences:
        print(
            f"- {difference.filename}:{difference.line_number} "
            f"{difference.size_difference_bytes:+,} bytes"
        )


def main() -> None:
    """Run healthy and retained-object workloads under separate trace sessions."""
    iterations = 25_000

    healthy_session = MemorySnapshotSession()
    healthy_session.start()
    healthy_workload(iterations)
    gc.collect()
    print_comparison("Healthy temporary-allocation workload", healthy_session)
    healthy_session.stop()

    leaky_session = MemorySnapshotSession()
    leaky_session.start()
    intentionally_leaky_workload(iterations)
    gc.collect()
    print_comparison("Intentionally retained-object workload", leaky_session)
    leaky_session.stop()

    print(f"\nRetained records before cleanup: {len(leaked_task_history):,}")
    leaked_task_history.clear()
    gc.collect()
    print(f"Retained records after cleanup: {len(leaked_task_history):,}")


if __name__ == "__main__":
    main()
```

### The Verification

Run:

```bash
python examples/46_memory_growth_workload.py
```

Expected behavior:

- The healthy workload has comparatively small retained growth after `gc.collect()`.
- The intentionally leaky workload reports substantial positive allocation growth.
- The retained record count changes from `25,000` to `0` after cleanup.

---

## Step 4: Add Bounded Result Retention

### The Target

Introduce a bounded storage pattern for completed results.

### The Concept

The current in-memory result store retains every result forever:

```text
Task 1 result remains
Task 2 result remains
Task 3 result remains
...
```

That is useful for a tutorial but unsafe for a long-running process.

A production system commonly uses one or more of these strategies:

- time-to-live expiration;
- maximum retained result count;
- external database or cache;
- explicit deletion after clients consume results;
- archival storage.

We will create a small reusable bounded retention container. It keeps only the newest entries.

Think of it as a rolling security-camera buffer. New footage replaces the oldest footage once storage reaches capacity.

### The Implementation

Create this module.

## `src/pulsequeue/retention.py`

```python
"""Bounded in-memory retention primitives for long-running services."""

from __future__ import annotations

from collections import OrderedDict
from collections.abc import Iterator
from typing import Generic, TypeVar

KeyT = TypeVar("KeyT")
ValueT = TypeVar("ValueT")


class BoundedRetentionStore(Generic[KeyT, ValueT]):
    """Retain only the most recently inserted values up to a fixed capacity."""

    def __init__(self, *, max_entries: int) -> None:
        """Create an empty bounded store."""
        if max_entries < 1:
            raise ValueError("max_entries must be at least 1.")

        self._max_entries = max_entries
        self._values: OrderedDict[KeyT, ValueT] = OrderedDict()

    @property
    def max_entries(self) -> int:
        """Return the configured retention capacity."""
        return self._max_entries

    def put(self, key: KeyT, value: ValueT) -> None:
        """Insert or replace a value and evict oldest entries if necessary."""
        self._values.pop(key, None)
        self._values[key] = value

        while len(self._values) > self._max_entries:
            self._values.popitem(last=False)

    def get(self, key: KeyT) -> ValueT:
        """Return one retained value or raise KeyError."""
        return self._values[key]

    def discard(self, key: KeyT) -> None:
        """Remove a value if present."""
        self._values.pop(key, None)

    def __contains__(self, key: object) -> bool:
        """Return whether a key is currently retained."""
        return key in self._values

    def __len__(self) -> int:
        """Return the current number of retained values."""
        return len(self._values)

    def keys(self) -> Iterator[KeyT]:
        """Iterate from oldest retained key to newest retained key."""
        return iter(self._values)
```

Create an example.

## `examples/47_bounded_retention.py`

```python
"""Demonstrate capacity-based eviction for completed task records."""

from __future__ import annotations

from pulsequeue.retention import BoundedRetentionStore


results = BoundedRetentionStore[str, str](max_entries=3)

for task_number in range(1, 6):
    task_id = f"task-{task_number}"
    results.put(task_id, f"result-{task_number}")

    print(f"Stored {task_id}; retained keys now: {list(results.keys())}")

print(f"\nFinal retained count: {len(results)}")
print(f"task-1 retained: {'task-1' in results}")
print(f"task-3 retained: {'task-3' in results}")
print(f"task-5 result: {results.get('task-5')}")
```

### The Verification

Run:

```bash
python examples/47_bounded_retention.py
```

Expected output:

```text
Stored task-1; retained keys now: ['task-1']
Stored task-2; retained keys now: ['task-1', 'task-2']
Stored task-3; retained keys now: ['task-1', 'task-2', 'task-3']
Stored task-4; retained keys now: ['task-2', 'task-3', 'task-4']
Stored task-5; retained keys now: ['task-3', 'task-4', 'task-5']

Final retained count: 3
task-1 retained: False
task-3 retained: True
task-5 result: result-5
```

This utility is not yet wired into `InMemoryResultStore`, because result expiration changes receipt semantics. Later, we will make result-backend retention a configurable plugin boundary rather than silently deleting records from the default tutorial broker.

---

## Step 5: Build a Minimal C Extension

### The Target

Add an optional native C extension named `pulsequeue._native`.

### The Concept

A C extension is compiled native code that Python imports like a module:

```python
from pulsequeue import _native

_native.fast_sum([1, 2, 3])
```

C extensions can help when:

- a tight algorithm is proven to be a bottleneck;
- the work benefits from native libraries;
- you need access to platform APIs;
- you need to release the GIL around safe native work.

But C extensions add complexity:

- compilation tooling;
- platform-specific builds;
- memory ownership rules;
- potential interpreter crashes;
- careful error handling.

The rule is:

> Profile first. Write native code only for a measured bottleneck that cannot be solved cleanly in Python.

### The Implementation

Create the native source directory:

```bash
mkdir -p src/pulsequeue/native
```

Create the C extension source.

## `src/pulsequeue/native/native_module.c`

```c
/*
 * Minimal CPython extension for the PulseQueue tutorial.
 *
 * This module exposes:
 *
 *     pulsequeue._native.fast_sum(iterable_of_ints) -> int
 *
 * The implementation demonstrates critical CPython C API rules:
 *
 * 1. Every new reference returned by a C API function must eventually be
 *    decremented with Py_DECREF(), unless ownership is transferred.
 * 2. If a C API function returns NULL, an exception is already set or must
 *    be set before returning NULL to Python.
 * 3. The extension must never retain borrowed references beyond the lifetime
 *    guaranteed by the API call that provided them.
 */

#define PY_SSIZE_T_CLEAN
#include <Python.h>


static PyObject *
fast_sum(PyObject *self, PyObject *args)
{
    PyObject *iterable;
    PyObject *iterator;
    PyObject *item;
    long long total = 0;

    /*
     * Parse one Python object argument. "O" means any Python object.
     * PyArg_ParseTuple returns 0 and sets an exception on invalid input.
     */
    if (!PyArg_ParseTuple(args, "O:fast_sum", &iterable)) {
        return NULL;
    }

    /*
     * PyObject_GetIter returns a NEW reference. We own it and must release it.
     */
    iterator = PyObject_GetIter(iterable);

    if (iterator == NULL) {
        return NULL;
    }

    /*
     * PyIter_Next returns:
     * - a NEW reference to the next item;
     * - NULL with no exception when iteration is complete;
     * - NULL with an exception set if iteration fails.
     */
    while ((item = PyIter_Next(iterator)) != NULL) {
        long long value = PyLong_AsLongLong(item);

        /*
         * item is a new reference from PyIter_Next, so release it on every
         * path after extracting its value.
         */
        Py_DECREF(item);

        if (value == -1 && PyErr_Occurred()) {
            Py_DECREF(iterator);
            return NULL;
        }

        /*
         * Detect signed integer overflow before performing addition.
         * LLONG_MAX comes from limits.h.
         */
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

    /*
     * Release our owned iterator reference after iteration completes.
     */
    Py_DECREF(iterator);

    /*
     * If PyIter_Next stopped because of an iteration error, preserve it.
     */
    if (PyErr_Occurred()) {
        return NULL;
    }

    /*
     * PyLong_FromLongLong returns a NEW reference. Returning it transfers
     * ownership to the Python interpreter.
     */
    return PyLong_FromLongLong(total);
}


static PyMethodDef native_methods[] = {
    {
        "fast_sum",
        fast_sum,
        METH_VARARGS,
        PyDoc_STR("fast_sum(iterable, /)\n--\n\n"
                  "Return the signed 64-bit sum of iterable integer values.")
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

The C compiler needs integer boundary constants. Add the missing standard header by replacing the complete file with this final version.

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

    iterator = PyObject_GetIter(iterable);

    if (iterator == NULL) {
        return NULL;
    }

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

    return PyLong_FromLongLong(total);
}


static PyMethodDef native_methods[] = {
    {
        "fast_sum",
        fast_sum,
        METH_VARARGS,
        PyDoc_STR(
            "fast_sum(iterable, /)\n--\n\n"
            "Return the signed 64-bit sum of iterable integer values."
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

Create `setup.py` in the project root. This supplements `pyproject.toml` with extension-build configuration.

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

### The Verification

Reinstall the editable package, which builds the extension:

```bash
python -m pip install --editable .
```

Verify the extension:

```bash
python -c "from pulsequeue import _native; print(_native.fast_sum([10, 20, 12]))"
```

Expected output:

```text
42
```

Also verify invalid input handling:

```bash
python -c "from pulsequeue import _native; print(_native.fast_sum([1, 'two']))"
```

Expected output ends with:

```text
TypeError: 'str' object cannot be interpreted as an integer
```

### Build Requirements

If compilation fails, install the appropriate compiler toolchain:

| Platform | Typical requirement |
|---|---|
| Ubuntu/Debian | `sudo apt install build-essential python3-dev` |
| Fedora | `sudo dnf install gcc python3-devel` |
| macOS | `xcode-select --install` |
| Windows | Visual Studio Build Tools with Desktop development with C++ |

Do not continue using the extension if it fails to build. The pure-Python framework remains fully functional without it.

---

## Step 6: Add Native Extension Tests

### The Target

Add tests for correct native behavior and error propagation.

### The Concept

Native code can crash the interpreter if it mishandles pointers or reference counts. Unit tests cannot prove C memory safety, but they can verify API behavior and make regressions visible.

### The Implementation

Create this test module.

## `tests/test_native_extension.py`

```python
"""Tests for the optional PulseQueue C extension."""

from __future__ import annotations

import pytest

native = pytest.importorskip("pulsequeue._native")


def test_fast_sum_returns_expected_total() -> None:
    """The native helper should sum ordinary Python integers."""
    assert native.fast_sum([10, 20, 12]) == 42
    assert native.fast_sum((-5, 5, 10)) == 10


def test_fast_sum_accepts_generators() -> None:
    """Any iterable should work because the extension uses PyObject_GetIter."""
    assert native.fast_sum(value for value in range(10)) == 45


def test_fast_sum_rejects_non_integer_items() -> None:
    """Invalid values should raise Python exceptions instead of crashing."""
    with pytest.raises(TypeError):
        native.fast_sum([1, "two", 3])
```

Add tests for the new Python utilities.

## `tests/test_memory_profiler_and_retention.py`

```python
"""Tests for memory comparison and bounded retention utilities."""

from __future__ import annotations

from pulsequeue.memory_profiler import MemorySnapshotSession
from pulsequeue.retention import BoundedRetentionStore


def test_bounded_retention_evicts_oldest_entry() -> None:
    """The store should retain only the most recently inserted values."""
    store = BoundedRetentionStore[str, int](max_entries=2)

    store.put("first", 1)
    store.put("second", 2)
    store.put("third", 3)

    assert list(store.keys()) == ["second", "third"]
    assert "first" not in store
    assert store.get("third") == 3


def test_memory_snapshot_session_reports_comparison() -> None:
    """A tracing session should report allocations created after its baseline."""
    session = MemorySnapshotSession()
    session.start()

    values = [f"value-{index}" for index in range(1_000)]

    comparison = session.compare(limit=3)

    assert comparison.current_bytes > 0
    assert len(comparison.largest_differences) > 0

    # Retain values until after comparison so allocations remain observable.
    assert len(values) == 1_000

    session.stop()
```

### The Verification

Run all tests:

```bash
python -m pytest -q
```

Expected result resembles:

```text
..............................................                         [100%]
46 passed
```

The exact count depends on your environment:

- If the extension built successfully, native tests run.
- If it did not build, `pytest.importorskip(...)` skips those native tests.

---

# Phase 3 Reference: CPython C API Ownership Rules

## New Reference

A **new reference** means your C code owns one reference and must release it unless ownership is transferred.

Example:

```c
PyObject *iterator = PyObject_GetIter(iterable);
```

`iterator` is a new reference.

You must later do:

```c
Py_DECREF(iterator);
```

unless you return it to Python or pass ownership to another API that explicitly steals it.

---

## Borrowed Reference

A **borrowed reference** is owned by someone else. You may use it only while the owning object guarantees it remains alive.

Do not store a borrowed reference for later unless you first increment it:

```c
Py_INCREF(object);
```

A useful rule:

```text
New reference     → you must eventually DECREF it.
Borrowed reference → do not DECREF it unless you first INCREF it.
```

---

## Error Contract

Most CPython C API functions follow this pattern:

```text
Success → non-NULL pointer or non-negative value
Failure → NULL pointer or -1, with Python exception set
```

When your C function detects an error, set a Python exception and return `NULL`:

```c
PyErr_SetString(PyExc_ValueError, "explanation");
return NULL;
```

Never return a normal Python value while an exception remains set.

---

## When to Release the GIL in C

Long-running native code can allow other Python threads to run by releasing the GIL:

```c
Py_BEGIN_ALLOW_THREADS

/* Long-running native code that does not use Python objects. */

Py_END_ALLOW_THREADS
```

This is safe only when the enclosed native code:

- does not access Python objects;
- does not call Python C API functions;
- does not manipulate Python reference counts;
- is independently thread-safe.

Do not release the GIL merely because native code exists. Incorrect GIL handling can corrupt interpreter state or crash the process.
