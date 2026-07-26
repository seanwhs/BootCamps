# Appendix C: Python Concurrency Decision Guide

Use this appendix when deciding whether work should run:

- directly in the current function;
- as an `asyncio` coroutine;
- in a thread;
- in a process;
- through an external queue or worker system.

The right choice depends on **what the work spends most of its time doing**.

---

## The Short Answer

| Work type | Usually choose | Why |
|---|---|---|
| Small, fast operation | Normal synchronous code | Lowest complexity and overhead |
| Many network/database requests using async client | `asyncio` | Efficiently overlaps waiting |
| Blocking SDK, blocking HTTP client, blocking file I/O | Thread | Keeps event loop responsive |
| CPU-heavy Python computation | Process pool | Bypasses one process’s GIL |
| Heavy work in a native library | Measure first | Library may release GIL |
| Durable background work | Broker + worker | Decouples work from request process |
| Multi-machine workload | Durable broker + worker fleet | Shared transport and failure recovery |

---

# 1. First Question: Does the Work Need Concurrency?

Do not add concurrency automatically.

This is often enough:

```python
def normalize_email(email: str) -> str:
    return email.strip().lower()
```

Running a tiny function in a thread or process adds more overhead than useful work.

Use ordinary code when the operation is:

- quick;
- local;
- deterministic;
- not waiting on external systems;
- not CPU-heavy at meaningful scale.

---

# 2. Async I/O: Use `asyncio`

Use `asyncio` when work spends most of its time waiting for I/O and the library supports async usage.

Examples:

- HTTP requests through an async client;
- async database drivers;
- WebSocket communication;
- async file or network abstractions;
- waiting on queues;
- timers and retries.

```python
import asyncio


async def fetch_profile(user_id: int) -> dict[str, str]:
    await asyncio.sleep(0.1)
    return {
        "user_id": str(user_id),
        "status": "active",
    }


async def main() -> None:
    results = await asyncio.gather(
        fetch_profile(1),
        fetch_profile(2),
        fetch_profile(3),
    )

    print(results)


asyncio.run(main())
```

The three requests overlap while waiting.

---

## PulseQueue Async Task

```python
@app.task(queue="profiles", timeout_seconds=5.0)
async def refresh_profile(user_id: int) -> dict[str, str]:
    await asyncio.sleep(0.1)

    return {
        "user_id": str(user_id),
        "status": "refreshed",
    }
```

Use `@app.task(...)` for async I/O work.

---

# 3. Blocking I/O: Use a Thread Boundary

Some libraries block the current thread:

```python
import time


def legacy_sdk_request() -> str:
    time.sleep(1)
    return "done"
```

Calling this directly inside an async task freezes the event loop:

```python
@app.task(queue="bad_example")
async def bad_task() -> str:
    return legacy_sdk_request()
```

During that one-second sleep, other async tasks on the same event loop cannot make progress.

Instead:

```python
from pulsequeue.execution import run_blocking_io


@app.task(queue="legacy_integrations")
async def fetch_from_legacy_service() -> str:
    return await run_blocking_io(legacy_sdk_request)
```

`run_blocking_io(...)` uses:

```python
await asyncio.to_thread(...)
```

The blocking function runs in a worker thread while the event loop continues scheduling other coroutines.

---

## Good Thread Candidates

Threads are often appropriate for:

- `requests`;
- legacy SOAP clients;
- blocking cloud SDK methods;
- ordinary file reads and writes;
- blocking database libraries;
- synchronous image uploads;
- blocking compression APIs.

---

## Thread Warning

Threads do **not** make CPU-bound pure Python code scale across cores in CPython.

This does not solve a CPU problem:

```python
await run_blocking_io(expensive_python_algorithm, large_input)
```

It may keep the event loop responsive, but the GIL still prevents true parallel execution of pure Python bytecode within one process.

---

# 4. CPU-Bound Python: Use Processes

CPU-bound work spends most of its time calculating rather than waiting.

Examples:

- pure-Python image processing;
- large numerical loops;
- cryptographic calculations written in Python;
- parsing very large data structures;
- simulation;
- expensive report generation;
- video or audio transformation without a GIL-releasing native library.

Use:

```python
@app.cpu_task(queue="analytics")
def count_primes(limit: int) -> int:
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
```

Submit through a runtime:

```python
receipt = await runtime.submit("analytics.count_primes", 100_000)
result = await receipt.result(timeout_seconds=30.0)
```

PulseQueue routes CPU tasks through `ProcessPoolExecutor`.

Each process has its own interpreter and its own GIL, allowing multiple CPU cores to work in parallel.

---

## CPU Task Requirements

A CPU task function must be:

- module-level;
- importable;
- synchronous;
- free of closures;
- supplied with pickleable arguments;
- returning pickleable values.

Good:

```python
# analytics/tasks.py

def calculate_score(values: list[int]) -> int:
    return sum(value * value for value in values)
```

Bad:

```python
async def main() -> None:
    multiplier = 2

    def calculate_score(value: int) -> int:
        return value * multiplier
```

The nested function captures local state and cannot reliably run in a spawned process.

---

# 5. Native Libraries: Measure Before Choosing

Some native libraries release the GIL while doing expensive work.

Examples may include operations in:

- NumPy;
- SciPy;
- compression libraries;
- cryptography libraries;
- image-processing libraries;
- database drivers.

If a library releases the GIL, threads may provide useful parallelism.

But do not assume this. Measure with a representative workload.

A useful experiment compares:

1. single-thread elapsed time;
2. multi-thread elapsed time;
3. process-pool elapsed time;
4. memory and startup overhead.

---

# 6. Decision Flowchart

```text
Start
  │
  ▼
Is the work small and fast?
  │
  ├── Yes → Run normally.
  │
  └── No
       │
       ▼
Does it mostly wait for network, disk, queue, or timer I/O?
       │
       ├── Yes
       │    │
       │    ▼
       │ Does the library provide an async API?
       │    │
       │    ├── Yes → Use asyncio and async task.
       │    │
       │    └── No → Use a thread boundary.
       │
       └── No
            │
            ▼
Is it CPU-heavy Python code?
            │
            ├── Yes → Use a CPU task and process pool.
            │
            └── No
                 │
                 ▼
Does it use a native library that releases the GIL?
                 │
                 ├── Unknown → Profile and benchmark.
                 ├── Yes → Threads may work well.
                 └── No → Prefer processes for parallel CPU work.
```

---

# 7. Common Mistakes

## Mistake: Blocking the Event Loop

Bad:

```python
import time


@app.task(queue="emails")
async def send_email() -> str:
    time.sleep(2)
    return "sent"
```

Better:

```python
import time

from pulsequeue.execution import run_blocking_io


def blocking_send_email() -> str:
    time.sleep(2)
    return "sent"


@app.task(queue="emails")
async def send_email() -> str:
    return await run_blocking_io(blocking_send_email)
```

Best, when available: use a native async client.

```python
@app.task(queue="emails")
async def send_email() -> str:
    return await async_email_client.send(...)
```

---

## Mistake: CPU Work Inside `async def`

Bad:

```python
@app.task(queue="analytics")
async def calculate() -> int:
    total = 0

    for value in range(100_000_000):
        total += value

    return total
```

Even though this function uses `async def`, it does not contain meaningful `await` points. It blocks the event loop.

Better:

```python
@app.cpu_task(queue="analytics")
def calculate() -> int:
    total = 0

    for value in range(100_000_000):
        total += value

    return total
```

---

## Mistake: Creating One Process Per Task

Bad conceptual design:

```python
async def execute_cpu_task() -> int:
    with ProcessPoolExecutor(max_workers=1) as executor:
        return await loop.run_in_executor(executor, expensive_function)
```

This repeatedly starts and stops processes.

Better: reuse a long-lived pool, as `PulseQueueWorker` does through:

```python
ProcessExecutorPool
```

---

## Mistake: Using Unlimited Concurrency

Bad:

```python
tasks = [
    asyncio.create_task(process(item))
    for item in millions_of_items
]
```

This can create millions of task objects and exhaust memory.

Better:

```python
queue = AsyncWorkQueue[WorkItem](max_size=1_000)
```

Use bounded queues and a fixed number of consumers.

---

# 8. Concurrency and Cancellation

Every execution model has different cancellation behavior.

| Model | Cancellation behavior |
|---|---|
| Ordinary function | Cannot be interrupted safely by `asyncio` |
| Async coroutine | Receives `CancelledError` at an await point |
| Thread function | Cannot be safely force-killed in standard Python |
| Process task | Future can be cancelled before start; running process work may continue |
| Durable broker task | Cancellation requires explicit message and state semantics |

Important implication:

> A timeout around a CPU process task may stop waiting for the result, but it may not instantly terminate the already-running calculation in the child process.

Design CPU tasks to be:

- bounded;
- idempotent where possible;
- safe to retry;
- small enough to avoid excessively long worker occupation.

---

# 9. Recommended PulseQueue Patterns

## Many HTTP Calls

```python
@app.task(queue="http")
async def refresh_remote_resource(resource_id: str) -> dict[str, str]:
    response = await async_http_client.get(
        f"https://api.example.com/resources/{resource_id}"
    )
    return response.json()
```

Use `@app.task`.

---

## Legacy Blocking SDK

```python
from pulsequeue.execution import run_blocking_io


def legacy_fetch(customer_id: str) -> dict[str, str]:
    return legacy_sdk.fetch_customer(customer_id)


@app.task(queue="legacy")
async def fetch_customer(customer_id: str) -> dict[str, str]:
    return await run_blocking_io(legacy_fetch, customer_id)
```

Use `@app.task` plus a thread boundary.

---

## CPU-Heavy Report

```python
@app.cpu_task(queue="reports")
def generate_statistics(values: list[int]) -> dict[str, float]:
    total = sum(values)

    return {
        "count": float(len(values)),
        "mean": total / len(values),
    }
```

Use `@app.cpu_task`.

---

## Hybrid Workflow

```python
@app.task(queue="workflows")
async def import_customer_data(customer_id: str) -> dict[str, object]:
    raw_data = await fetch_customer_from_api(customer_id)

    # Submit CPU work as a separate task in a durable architecture.
    # In this in-memory tutorial, both tasks share the same runtime process.
    return raw_data
```

For a production distributed system, use separate task boundaries when:

- CPU work is expensive;
- retries differ;
- scaling characteristics differ;
- task ownership differs.

---

# 10. Capacity Planning Starting Points

These are starting points, not universal values.

| Workload | Start with | Then measure |
|---|---|---|
| I/O-heavy async tasks | 10–100 async consumers | latency, connection limits, external API rate limits |
| Blocking I/O threads | Small bounded thread pool | blocking duration, thread memory, library safety |
| CPU tasks | `os.cpu_count()` or fewer processes | CPU saturation, memory per process, queue backlog |
| Mixed workloads | Separate queues and worker types | per-queue latency and saturation |

Separate queues are often clearer:

```text
emails.send_welcome
analytics.generate_report
maintenance.cleanup
```

This avoids CPU-heavy work delaying latency-sensitive email or API tasks.

---

# 11. The GIL: Accurate Summary

The CPython GIL means:

- one thread at a time executes Python bytecode within one process;
- threads remain useful for blocking I/O;
- threads may parallelize native work when the native library releases the GIL;
- processes provide true parallelism for pure Python CPU work.

The GIL does **not** mean:

- Python cannot perform concurrent work;
- `asyncio` is useless;
- threads never help;
- Python cannot use multiple cores;
- every operation is automatically thread-safe.
