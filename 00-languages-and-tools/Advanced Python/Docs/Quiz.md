# Mastering Python: Architecture, Internals & Concurrency  
## Quiz Test Bank with Answer Keys

This test bank covers primers, metaprogramming, concurrency, CPython internals, typing, plugins, PulseQueue architecture, and production readiness.

---

# Section A: Multiple-Choice Questions

## A1. Python Runtime and Packaging

### 1. What is the main benefit of using a virtual environment?

A. It makes Python code execute faster.  
B. It isolates project dependencies from other projects.  
C. It automatically tests all Python files.  
D. It converts Python into compiled C code.

**Answer:** B

---

### 2. Which command best ensures that `pytest` runs using the currently active Python interpreter?

A. `pytest`  
B. `pip pytest`  
C. `python -m pytest`  
D. `python pytest`

**Answer:** C

---

### 3. Why is a `src/` layout often preferred for Python packages?

A. It prevents Python syntax errors.  
B. It ensures tests are more likely to import the installed package rather than accidentally importing local source files.  
C. It removes the need for `__init__.py`.  
D. It makes all package code asynchronous.

**Answer:** B

---

### 4. What does this command do?

```bash
python -m pip install --editable .
```

A. Deletes installed packages.  
B. Installs the project so source edits are immediately reflected without reinstalling.  
C. Builds a Docker image.  
D. Runs a static type checker.

**Answer:** B

---

### 5. Why is this command usually preferred for a package module?

```bash
python -m examples.worker_application
```

A. It disables imports.  
B. It runs code faster than Python scripts.  
C. It preserves package import context.  
D. It automatically creates a virtual environment.

**Answer:** C

---

## A2. Functions, Classes, and Decorators

### 6. What does `self` represent in an instance method?

A. The module containing the class.  
B. The current class definition.  
C. The current instance of the class.  
D. The parent class.

**Answer:** C

---

### 7. What is the purpose of a keyword-only parameter?

```python
def submit(task_name: str, *, timeout_seconds: float) -> None:
    ...
```

A. It can only receive integer values.  
B. It must be supplied by parameter name.  
C. It can never have a default value.  
D. It is shared by all function calls.

**Answer:** B

---

### 8. What does this decorator syntax mean conceptually?

```python
@app.task(queue="emails")
async def send_email() -> str:
    ...
```

A. Python creates a thread automatically.  
B. Python calls `app.task(queue="emails")`, then applies the returned decorator to `send_email`.  
C. Python compiles `send_email` into C.  
D. Python executes `send_email` immediately.

**Answer:** B

---

### 9. Why should decorators commonly use `functools.wraps(...)`?

A. It prevents all runtime exceptions.  
B. It copies function metadata such as name, documentation, and annotations.  
C. It converts a synchronous function into a process task.  
D. It makes code thread-safe.

**Answer:** B

---

### 10. Which statement about type hints is correct?

A. Python always enforces type hints at runtime.  
B. Type hints replace runtime validation.  
C. Type hints help tools and readers, but dynamic input still needs runtime validation.  
D. Type hints only work on classes.

**Answer:** C

---

## A3. Metaprogramming and Dynamic Behavior

### 11. What happens when Python executes a `class` statement?

A. Python only stores source text for later.  
B. Python executes the class body and constructs a class object.  
C. Python immediately creates one instance of the class.  
D. Python always creates a metaclass subclass.

**Answer:** B

---

### 12. What is a metaclass?

A. A function that always returns metadata dictionaries.  
B. A class whose instances are ordinary Python objects.  
C. A class that creates classes.  
D. A decorator for async functions.

**Answer:** C

---

### 13. Which descriptor method receives the final attribute name during class creation?

A. `__get__`  
B. `__set__`  
C. `__set_name__`  
D. `__getattr__`

**Answer:** C

---

### 14. What is the primary difference between `__getattr__` and `__getattribute__`?

A. They are identical.  
B. `__getattr__` runs only after normal attribute lookup fails; `__getattribute__` runs for every attribute read.  
C. `__getattribute__` only handles writes.  
D. `__getattr__` only works on classes, not instances.

**Answer:** B

---

### 15. Why are controlled dynamic prefixes such as `meta_owner` useful?

A. They make every attribute mutable.  
B. They prevent metadata from colliding silently with normal framework attributes.  
C. They remove the need for validation.  
D. They make metadata execute faster.

**Answer:** B

---

### 16. Why should a task registry reject duplicate stable task names?

A. Duplicate names improve load balancing.  
B. Silent replacement could cause the wrong task implementation to execute.  
C. Python does not permit dictionaries with duplicate keys.  
D. Duplicates are required for retry support.

**Answer:** B

---

## A4. Asyncio and Concurrency

### 17. What does calling an `async def` function return?

A. The final result immediately.  
B. A coroutine object.  
C. A process object.  
D. A thread object.

**Answer:** B

---

### 18. What does `await` do?

A. It permanently stops the event loop.  
B. It creates a new process.  
C. It pauses the current coroutine while allowing the event loop to run other ready work.  
D. It automatically retries a failed operation.

**Answer:** C

---

### 19. Which call blocks the event-loop thread?

A. `await asyncio.sleep(1)`  
B. `await asyncio.to_thread(function)`  
C. `time.sleep(1)` inside an async function  
D. `await queue.get()`

**Answer:** C

---

### 20. Which tool is most appropriate for a blocking legacy HTTP SDK called from async code?

A. `asyncio.to_thread(...)`  
B. `ProcessPoolExecutor` by default  
C. A metaclass  
D. `__slots__`

**Answer:** A

---

### 21. Which workload is usually the best candidate for a process pool?

A. Waiting for an async database response.  
B. A pure Python loop performing expensive image calculations.  
C. Waiting for an `asyncio.Event`.  
D. Parsing a short string.

**Answer:** B

---

### 22. What is the CPython GIL?

A. A permanent lock on all operating-system processes.  
B. A mechanism allowing only one thread at a time to execute Python bytecode in one CPython process.  
C. A distributed broker protocol.  
D. A garbage-collection algorithm.

**Answer:** B

---

### 23. Why should a CPU task function be defined at module scope?

A. Module-level functions always use less memory.  
B. Child processes need to import the function reliably.  
C. Nested functions cannot return values.  
D. Module-level functions bypass type checking.

**Answer:** B

---

### 24. What is backpressure in a bounded queue?

A. A method for deleting tasks immediately.  
B. A mechanism that makes producers wait when the queue is full.  
C. A method for increasing process count.  
D. A type of exception traceback.

**Answer:** B

---

### 25. Why must every `queue.get()` eventually have one `queue.task_done()`?

A. To enable metaclass registration.  
B. To let `queue.join()` know when all retrieved work has completed.  
C. To serialize task payloads.  
D. To release the GIL.

**Answer:** B

---

### 26. What should normally happen after catching `asyncio.CancelledError` for cleanup?

A. Ignore it and continue.  
B. Convert it to `ValueError`.  
C. Perform necessary cleanup and re-raise it.  
D. Start a new event loop.

**Answer:** C

---

## A5. Retries and Shutdown

### 27. In PulseQueue, what does `max_retries=2` mean?

A. The task executes exactly twice.  
B. The task has two total attempts.  
C. The task can make two additional attempts after the first attempt.  
D. The task retries forever.

**Answer:** C

---

### 28. A task has:

```python
retry_delay_seconds = 0.5
retry_backoff_multiplier = 2.0
```

What is the delay for retry number 3?

A. `0.5` seconds  
B. `1.0` seconds  
C. `1.5` seconds  
D. `2.0` seconds

**Answer:** D

---

### 29. Which error is most likely retryable?

A. `ValueError` caused by malformed input  
B. `PermissionError` caused by missing authorization  
C. `ConnectionError` caused by a temporary network interruption  
D. `SyntaxError` in application code

**Answer:** C

---

### 30. What is the first step of graceful worker shutdown?

A. Delete all task results.  
B. Close submissions so new work is rejected.  
C. Stop plugins before consumers finish.  
D. Kill the Python interpreter immediately.

**Answer:** B

---

### 31. Why should plugins typically stop after workers finish draining or cancelling tasks?

A. Final task lifecycle events may still need to be published.  
B. Plugins are faster when stopped last.  
C. It changes the GIL behavior.  
D. It removes the need for receipts.

**Answer:** A

---

### 32. What should happen to a receipt when forced shutdown cancels its active task?

A. It remains permanently `RUNNING`.  
B. It becomes `SUCCEEDED`.  
C. It becomes `CANCELLED` and wakes waiting callers.  
D. It silently disappears.

**Answer:** C

---

## A6. Memory and CPython Internals

### 33. What is CPython’s primary object-lifetime mechanism?

A. Mark-and-sweep only  
B. Reference counting  
C. Manual free calls in Python code  
D. Thread-local garbage collection only

**Answer:** B

---

### 34. Why can two objects in a reference cycle remain alive after outer names are deleted?

A. They are always immortal objects.  
B. Each object still references the other.  
C. Python does not support garbage collection.  
D. They are automatically converted into global variables.

**Answer:** B

---

### 35. What is the safest preferred resource-cleanup pattern?

A. Depend on `__del__`.  
B. Use a context manager or explicit `close()` in `finally`.  
C. Call `gc.collect()` after every operation.  
D. Store every resource in a global list.

**Answer:** B

---

### 36. When are weak references useful?

A. When a registry should observe an object without preventing its cleanup.  
B. When values must never be garbage collected.  
C. When creating CPU processes.  
D. When serializing JSON.

**Answer:** A

---

### 37. What does `__slots__` commonly reduce?

A. The number of Python keywords.  
B. Per-instance attribute dictionary overhead for fixed-shape objects.  
C. The number of process workers.  
D. The number of exceptions raised.

**Answer:** B

---

### 38. What is a limitation of `sys.getsizeof(...)`?

A. It cannot inspect Python objects.  
B. It only works for integers.  
C. It reports shallow size and does not include all recursively referenced objects.  
D. It automatically identifies memory leaks.

**Answer:** C

---

### 39. Which tool is most appropriate for comparing Python allocation growth before and after a workload?

A. `tracemalloc`  
B. `functools.wraps`  
C. `inspect.signature`  
D. `asyncio.gather`

**Answer:** A

---

## A7. Typing, Protocols, and Plugins

### 40. What is structural subtyping?

A. Objects are compatible only if they inherit from the same class.  
B. Objects are compatible when they provide the required methods and attributes.  
C. Objects must have identical memory addresses.  
D. Objects automatically serialize to JSON.

**Answer:** B

---

### 41. Why use a `Protocol` for a plugin contract?

A. It requires every plugin to inherit from one framework base class.  
B. It allows independent implementations to satisfy a behavior contract.  
C. It prevents plugins from receiving events.  
D. It replaces all tests.

**Answer:** B

---

### 42. What does `@runtime_checkable` allow?

A. Automatic process-pool execution.  
B. Using a protocol with `isinstance(...)`.  
C. Guaranteed semantic correctness of a plugin.  
D. Automatic JSON serialization.

**Answer:** B

---

### 43. What does `ParamSpec` help preserve?

A. The full parameter shape of a callable.  
B. The memory address of an object.  
C. The number of worker processes.  
D. The garbage collector generation.

**Answer:** A

---

### 44. Why should an event plugin failure usually not turn a successful task into a failed task?

A. Plugins are unable to raise exceptions.  
B. Task execution and observability are separate concerns.  
C. The event loop ignores plugin errors automatically.  
D. Task receipts cannot represent failures.

**Answer:** B

---

## A8. Serialization and Production

### 45. Why should untrusted task messages not use `pickle`?

A. Pickle is too slow for Python lists.  
B. Pickle cannot store Python objects.  
C. Unpickling malicious data can execute arbitrary code.  
D. Pickle only works on Windows.

**Answer:** C

---

### 46. Which value is JSON-compatible?

A. `set(["a", "b"])`  
B. `datetime.now()`  
C. `lambda: None`  
D. `{"user_id": 42, "locale": "en-GB"}`

**Answer:** D

---

### 47. What does idempotency mean for a distributed task?

A. The task always executes only once.  
B. Repeated execution produces the same intended business outcome.  
C. The task never raises exceptions.  
D. The broker never redelivers messages.

**Answer:** B

---

### 48. What is a dead-letter queue used for?

A. Running CPU-bound tasks faster.  
B. Holding messages that cannot be processed normally.  
C. Replacing task signatures.  
D. Preventing garbage collection.

**Answer:** B

---

### 49. Why is a visibility timeout important in a durable broker?

A. It controls how long a worker temporarily owns a message before redelivery becomes possible.  
B. It changes task function annotations.  
C. It makes queue entries immutable.  
D. It disables retries.

**Answer:** A

---

### 50. Why can `submit-local` not send work to a separate `pulsequeue run` process when using `InMemoryBroker`?

A. The CLI rejects all tasks.  
B. CPU tasks cannot be submitted from a terminal.  
C. Each process has its own independent in-memory broker.  
D. JSON cannot represent task names.

**Answer:** C

---

# Section B: True or False

### 51. A metaclass is the class of a class object.

**Answer:** True

---

### 52. `__getattr__` runs before all normal attribute lookup.

**Answer:** False

---

### 53. A descriptor can validate attribute assignment.

**Answer:** True

---

### 54. `asyncio.sleep(...)` blocks the operating-system thread just like `time.sleep(...)`.

**Answer:** False

---

### 55. A coroutine without meaningful `await` points can block the event loop.

**Answer:** True

---

### 56. Threads are always the best choice for CPU-heavy pure Python loops.

**Answer:** False

---

### 57. A process pool normally requires functions and arguments to be pickleable.

**Answer:** True

---

### 58. A queue consumer may safely omit `task_done()` when it receives a stop signal.

**Answer:** False

---

### 59. `max_retries=0` means a task never receives an initial attempt.

**Answer:** False

---

### 60. A task receipt can expose immutable result snapshots.

**Answer:** True

---

### 61. `__slots__` is always appropriate for any Python class.

**Answer:** False

---

### 62. A weak reference prevents its target object from being garbage collected.

**Answer:** False

---

### 63. `tracemalloc` can help compare Python allocation growth between snapshots.

**Answer:** True

---

### 64. A protocol requires all compatible classes to inherit from it.

**Answer:** False

---

### 65. Plugin startup rollback helps prevent already-started plugins from leaking resources after a later plugin fails.

**Answer:** True

---

### 66. JSON serialization is safe for arbitrary live Python objects such as database connections.

**Answer:** False

---

### 67. At-least-once delivery means duplicate task execution is possible.

**Answer:** True

---

### 68. A graceful shutdown policy should be tested under active task load.

**Answer:** True

---

# Section C: Short-Answer Questions

### 69. Explain the difference between concurrency and parallelism.

**Answer Key:**  
Concurrency is the organization of multiple tasks so they can make progress over time. Parallelism is actual simultaneous execution, often on multiple CPU cores or processes.

---

### 70. Why is `__getattribute__` more dangerous than `__getattr__`?

**Answer Key:**  
`__getattribute__` runs for every attribute read, including internal method and property lookups. Incorrect implementation can cause recursion or break normal object behavior. `__getattr__` is only a fallback after normal lookup fails.

---

### 71. Why does PulseQueue validate task arguments before broker submission?

**Answer Key:**  
It gives the caller an immediate clear error, prevents invalid messages from occupying queue capacity, and avoids workers receiving tasks they cannot execute.

---

### 72. Why is a bounded queue important in a long-running task system?

**Answer Key:**  
It provides backpressure, prevents unlimited queued messages from consuming memory, and exposes overload rather than hiding it until the process fails.

---

### 73. What is the correct cleanup pattern after receiving `CancelledError`?

**Answer Key:**  

```python
except asyncio.CancelledError:
    await cleanup()
    raise
```

Perform necessary cleanup, then re-raise cancellation.

---

### 74. Why are task events immutable?

**Answer Key:**  
Events represent historical lifecycle records. Plugins and observers should not be able to alter the meaning of past events after publication.

---

### 75. Give two examples of objects that should not be passed to a process pool.

**Answer Key:**  
Any two:

- database connection;
- socket;
- file handle;
- event loop;
- lock;
- live framework runtime;
- thread object;
- coroutine object.

---

### 76. Why should result backends be represented by a protocol rather than hard-coded to `InMemoryResultStore`?

**Answer Key:**  
A protocol allows replacement storage implementations such as Redis, PostgreSQL, or a remote result service without changing broker, receipt, or worker code.

---

### 77. What is a reference cycle?

**Answer Key:**  
A group of objects that refer to one another, so reference counts may remain nonzero even when no live program code can reach the group.

---

### 78. Why is `pickle` unsafe for untrusted task messages?

**Answer Key:**  
Unpickling data can invoke code during deserialization, which can allow arbitrary code execution from malicious input.

---

# Section D: Code Reading and Debugging Questions

### 79. What is wrong with this queue consumer?

```python
async def consumer(queue: asyncio.Queue[str]) -> None:
    item = await queue.get()

    if item == "stop":
        return

    await process(item)
    queue.task_done()
```

**Answer Key:**  
If `item == "stop"` or if `process(item)` raises, `task_done()` is not called. This can cause `queue.join()` to hang.

Correct version:

```python
async def consumer(queue: asyncio.Queue[str]) -> None:
    item = await queue.get()

    try:
        if item == "stop":
            return

        await process(item)
    finally:
        queue.task_done()
```

---

### 80. What is wrong with this cancellation handler?

```python
async def worker() -> None:
    try:
        await asyncio.sleep(60)
    except asyncio.CancelledError:
        print("Cancelled.")
```

**Answer Key:**  
It swallows cancellation. It should clean up and re-raise:

```python
async def worker() -> None:
    try:
        await asyncio.sleep(60)
    except asyncio.CancelledError:
        print("Cancelled.")
        raise
```

---

### 81. Why is this CPU task unsafe?

```python
async def main() -> None:
    multiplier = 2

    @app.cpu_task(queue="math")
    def double(value: int) -> int:
        return value * multiplier
```

**Answer Key:**  
The function is nested inside `main()` and closes over `multiplier`. Spawned child processes cannot reliably import this local function. CPU task functions should be module-level.

---

### 82. What is the likely result of this code?

```python
@app.task(queue="reports")
async def calculate_report() -> int:
    total = 0

    for value in range(100_000_000):
        total += value

    return total
```

**Answer Key:**  
The task blocks the event loop because it performs CPU-heavy work without meaningful `await` points. It should likely be an `@app.cpu_task(...)`.

---

### 83. Identify the retention problem.

```python
class EventCollector:
    def __init__(self) -> None:
        self.events: list[TaskEvent] = []

    async def on_event(self, event: TaskEvent) -> None:
        self.events.append(event)
```

**Answer Key:**  
The event list grows forever in a long-running process. Use bounded retention, external telemetry, TTL cleanup, or a deliberate export-and-clear strategy.

---

### 84. Fix this terminal failure line.

```python
self._broker.mark_failed(envelope.task_id)
```

**Answer Key:**

```python
self._broker.mark_failed(envelope.task_id, error)
```

The result backend needs the exception to create failure details.

---

# Section E: Scenario-Based Questions

### 85. Scenario: Legacy Payment SDK

You have a legacy payment SDK with this API:

```python
def charge_customer(customer_id: str, amount_cents: int) -> str:
    ...
```

It blocks for several seconds while waiting for a remote API.

Which PulseQueue task type should you use, and what additional execution boundary is required?

**Answer Key:**  
Use `@app.task(...)` because the workflow is I/O-oriented, then call the blocking SDK through `asyncio.to_thread(...)` or `run_blocking_io(...)`. Do not run it directly in the event loop.

---

### 86. Scenario: Duplicate Billing Risk

A worker charges a customer, then crashes before acknowledging the durable broker message. The broker redelivers the task.

What property must the billing task have?

**Answer Key:**  
Idempotency. Use a stable business-level idempotency key, such as invoice ID, so duplicate delivery does not create duplicate charges.

---

### 87. Scenario: Queue Overload

A producer can submit 10,000 tasks per second, while workers complete only 500 tasks per second.

What should happen if the queue is bounded?

**Answer Key:**  
The queue fills, then producers wait or receive an explicit queue-full failure depending on API choice. This is backpressure. It prevents unlimited memory growth.

---

### 88. Scenario: Plugin Failure

A metrics plugin raises an exception while handling `task.succeeded`.

What should happen to:

1. The task result?  
2. The worker diagnostic state?

**Answer Key:**  

1. The successful task should remain successful.  
2. The worker should increment `event_delivery_failures` and log or expose the plugin issue.

---

### 89. Scenario: Memory Growth

A worker’s memory increases after every task. `tracemalloc` points to a list append in an event plugin.

What is the likely cause and first fix?

**Answer Key:**  
The plugin retains all events indefinitely. Use bounded retention, external event export, TTL cleanup, or avoid in-memory history in long-running production workers.

---

### 90. Scenario: CPU Task Timeout

A CPU task running in a process pool exceeds its timeout.

Why might the calculation continue consuming CPU even after the caller stops waiting?

**Answer Key:**  
Cancelling the asyncio wait does not necessarily terminate a process-pool function that has already started. Running CPU work requires separate process-level lifecycle management and should be bounded or chunked.

---

# Section F: Practical Coding Assessment Prompts

## Assessment 1 — Descriptor

Implement a descriptor named `NonEmptyString`.

Requirements:

- Only accepts strings.
- Rejects empty or whitespace-only strings.
- Uses `__set_name__`.
- Allows reading from instances.
- Returns itself when accessed on the class.

**Answer Key Outline:**

```python
class NonEmptyString:
    def __init__(self) -> None:
        self.name: str | None = None
        self.storage_name: str | None = None

    def __set_name__(self, owner: type[object], name: str) -> None:
        self.name = name
        self.storage_name = f"_{owner.__name__}_{name}"

    def __get__(self, instance: object | None, owner: type[object]) -> object:
        if instance is None:
            return self

        if self.storage_name is None:
            raise RuntimeError("Descriptor not initialized.")

        return vars(instance)[self.storage_name]

    def __set__(self, instance: object, value: object) -> None:
        if not isinstance(value, str):
            raise TypeError("Value must be a string.")

        if not value.strip():
            raise ValueError("Value cannot be empty.")

        if self.storage_name is None:
            raise RuntimeError("Descriptor not initialized.")

        vars(instance)[self.storage_name] = value
```

---

## Assessment 2 — Async Retry Task

Create a PulseQueue task that:

- fails twice with `ConnectionError`;
- succeeds on third attempt;
- uses `max_retries=2`;
- uses small retry delays;
- returns `"recovered"`.

**Answer Key Outline:**

```python
attempts = {"count": 0}


@app.task(
    queue="examples",
    max_retries=2,
    retry_delay_seconds=0.001,
)
async def transient_operation() -> str:
    attempts["count"] += 1

    if attempts["count"] < 3:
        raise ConnectionError("temporary failure")

    return "recovered"
```

Expected final state:

```text
SUCCEEDED
attempt = 3
max_attempts = 3
```

---

## Assessment 3 — Plugin

Create a plugin that records event types.

**Answer Key Outline:**

```python
class EventCountPlugin:
    name = "event_count"

    def __init__(self) -> None:
        self.counts: dict[str, int] = {}
        self.started = False

    async def start(self) -> None:
        self.started = True

    async def stop(self) -> None:
        self.started = False

    async def on_event(self, event: TaskEvent) -> None:
        if not self.started:
            raise RuntimeError("Plugin not started.")

        name = event.event_type.value
        self.counts[name] = self.counts.get(name, 0) + 1
```

---

## Assessment 4 — JSON Validation

Which values should `ensure_json_value(...)` reject?

```python
{
    "user_id": 42,
    "tags": {"priority", "onboarding"},
}
```

```python
{
    "created_at": "2026-07-24T12:00:00+00:00",
}
```

```python
{
    "callback": lambda: None,
}
```

```python
{
    "active": True,
    "priority": 10,
}
```

**Answer Key:**

| Value | Accept or Reject |
|---|---|
| Set in `tags` | Reject |
| ISO-8601 string timestamp | Accept |
| Lambda callback | Reject |
| Boolean and integer values | Accept |

---

# Section G: Answer Summary

## Multiple Choice

```text
1 B
2 C
3 B
4 B
5 C
6 C
7 B
8 B
9 B
10 C
11 B
12 C
13 C
14 B
15 B
16 B
17 B
18 C
19 C
20 A
21 B
22 B
23 B
24 B
25 B
26 C
27 C
28 D
29 C
30 B
31 A
32 C
33 B
34 B
35 B
36 A
37 B
38 C
39 A
40 B
41 B
42 B
43 A
44 B
45 C
46 D
47 B
48 B
49 A
50 C
```

## True / False

```text
51 True
52 False
53 True
54 False
55 True
56 False
57 True
58 False
59 False
60 True
61 False
62 False
63 True
64 False
65 True
66 False
67 True
68 True
```

---

# Suggested Scoring

| Section | Points |
|---|---:|
| Multiple choice: 50 × 1 | 50 |
| True/False: 18 × 1 | 18 |
| Short answer: 10 × 3 | 30 |
| Code reading: 6 × 4 | 24 |
| Scenario questions: 6 × 4 | 24 |
| Practical assessments: 4 × 10 | 40 |
| **Total** | **186** |

Suggested interpretation:

| Score | Interpretation |
|---:|---|
| 165–186 | Strong mastery |
| 140–164 | Proficient; ready for capstone extensions |
| 115–139 | Understands fundamentals; review weak modules |
| 90–114 | Needs targeted practice |
| Below 90 | Revisit primers and core concurrency concepts |
