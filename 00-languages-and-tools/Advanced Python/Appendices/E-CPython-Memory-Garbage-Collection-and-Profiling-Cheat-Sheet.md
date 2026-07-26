# Appendix E: CPython Memory, Garbage Collection, and Profiling Cheat Sheet

This appendix is a field guide for diagnosing memory behavior in long-running Python services.

Use it when you see:

- resident memory increasing over time;
- task workers retaining too much history;
- objects that should be gone but are still alive;
- large event or result collections;
- slow garbage-collection pauses;
- uncertainty about whether `__slots__` is worthwhile.

The core principle is:

> Memory is released only when objects become unreachable.

The garbage collector cannot reclaim an object if some live part of the program still references it.

---

# 1. CPython Object Lifetime in One Diagram

```text
Python name or container
        │
        ▼
      Object
        │
        ├── Reference count reaches zero
        │       │
        │       ▼
        │   Usually released immediately in CPython
        │
        └── Reference cycle remains
                │
                ▼
          Cyclic garbage collector detects unreachable cycle
```

Example:

```python
payload = {"task_id": "task-001"}
```

The name `payload` references the dictionary.

When the final reference disappears:

```python
del payload
```

CPython usually releases the dictionary immediately.

---

# 2. Reference Counts

Inspect a diagnostic reference count:

```python
import sys


def visible_reference_count(value: object) -> int:
    """Subtract the temporary reference created by getrefcount itself."""
    return sys.getrefcount(value) - 1
```

Example:

```python
payload = {"task_id": "task-001"}

print(visible_reference_count(payload))

another_name = payload

print(visible_reference_count(payload))

del another_name

print(visible_reference_count(payload))
```

Typical output:

```text
1
2
1
```

## Important Warning

Do not write application logic that depends on reference counts.

Reference counts are:

- CPython implementation details;
- affected by temporary interpreter references;
- different across Python implementations;
- useful for debugging, not correctness.

---

# 3. Why Objects Stay Alive

The most common cause of memory growth is a long-lived reference.

Examples:

```python
completed_tasks: list[object] = []

def process_task(task: object) -> None:
    completed_tasks.append(task)
```

Every processed task remains reachable through:

```python
completed_tasks
```

The garbage collector is behaving correctly. It cannot free objects that the application still owns.

Other common retention roots:

```text
Global variables
Module-level caches
Class-level dictionaries
Long-lived registries
Background task sets
Callback lists
Exception tracebacks
Logging handlers
Queue contents
Closure variables
Thread-local storage
```

---

# 4. Reference Cycles

A cycle occurs when objects refer to one another:

```python
class Node:
    def __init__(self) -> None:
        self.other: Node | None = None


first = Node()
second = Node()

first.other = second
second.other = first
```

Deleting outer names does not make either count zero:

```python
del first
del second
```

The cyclic garbage collector identifies cycles that are unreachable from live program roots.

Force a collection for diagnostics:

```python
import gc

collected = gc.collect()

print(collected)
```

Do not call `gc.collect()` in a tight request or task loop unless measurement proves it is necessary. It can introduce latency and hide the actual retention problem.

---

# 5. Inspect Garbage Collector Statistics

```python
import gc

print(gc.get_count())
print(gc.get_stats())
```

`gc.get_count()` returns generation counters.

`gc.get_stats()` returns per-generation collection statistics.

PulseQueue exposes a structured wrapper:

```python
from pulsequeue.memory import garbage_collection_stats

stats = garbage_collection_stats()

print(stats)
```

Useful fields include:

```python
stats.generation_zero_count
stats.generation_one_count
stats.generation_two_count
stats.generation_zero_collections
stats.generation_one_collections
stats.generation_two_collections
```

---

# 6. Use `weakref` for Non-Owning Relationships

A normal reference keeps an object alive.

```python
registry.listeners.append(listener)
```

If the registry lasts for the full process lifetime, so does `listener`.

A weak reference observes an object without owning it:

```python
import weakref

listener_reference = weakref.ref(listener)
```

Read it later:

```python
current_listener = listener_reference()

if current_listener is not None:
    current_listener.handle_event()
```

PulseQueue uses weak references for bound observer methods in:

```python
from pulsequeue.observers import TaskObserverRegistry
```

This prevents a long-lived observer registry from retaining short-lived worker or request objects.

---

## Weak References and Bound Methods

Do not store a bound method strongly if the object should be collectible:

```python
registry.callbacks.append(observer.on_event)
```

This retains `observer`.

Use:

```python
weakref.WeakMethod(observer.on_event)
```

The PulseQueue observer registry handles this distinction automatically.

---

# 7. `__slots__` Decision Table

| Object characteristic | Use slots? |
|---|---|
| Millions of fixed-shape internal event records | Usually yes |
| Immutable task snapshots | Usually yes |
| Open-ended user plugin objects | Usually no |
| Debug-heavy development objects | Usually no |
| Object must accept arbitrary attributes | No, unless including `__dict__` |
| Class hierarchy is complex or third-party extensible | Measure before deciding |

Example:

```python
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class TaskEvent:
    task_id: str
    task_name: str
    attempt: int
```

This avoids a normal per-instance `__dict__`.

---

## Slot Caveat: Wrapper Metadata

PulseQueue’s `Task` class uses:

```python
__slots__ = (
    "__dict__",
    "_function",
    "_options",
    "_signature",
    "_source_file",
    "_source_line",
)
```

Why include `__dict__`?

Because:

```python
functools.update_wrapper(...)
```

adds metadata such as:

```python
__name__
__doc__
__wrapped__
__annotations__
```

A fully slot-only object cannot receive those dynamic attributes.

This is a practical example of optimizing without breaking introspection.

---

# 8. Measure Shallow Object Size

Use:

```python
import sys

print(sys.getsizeof(value))
```

Example:

```python
import sys


class StandardRecord:
    def __init__(self) -> None:
        self.task_id = "task-001"


class SlottedRecord:
    __slots__ = ("task_id",)

    def __init__(self) -> None:
        self.task_id = "task-001"


standard = StandardRecord()
slotted = SlottedRecord()

print(sys.getsizeof(standard))
print(sys.getsizeof(standard.__dict__))
print(sys.getsizeof(slotted))
```

## Important Limitation

`sys.getsizeof(...)` is shallow.

For:

```python
payload = {
    "task_id": "task-001",
    "arguments": [1, 2, 3],
}
```

it does not recursively include the full size of nested strings, lists, and integers.

Use `tracemalloc` for allocation analysis.

---

# 9. Use `tracemalloc` for Allocation Growth

Minimal workflow:

```python
import tracemalloc

tracemalloc.start()

baseline = tracemalloc.take_snapshot()

run_workload()

current = tracemalloc.take_snapshot()

for difference in current.compare_to(baseline, "lineno")[:10]:
    print(difference)

tracemalloc.stop()
```

PulseQueue provides a wrapper:

```python
from pulsequeue.memory_profiler import MemorySnapshotSession

session = MemorySnapshotSession()
session.start()

run_workload()

comparison = session.compare(limit=10)

for difference in comparison.largest_differences:
    print(
        difference.filename,
        difference.line_number,
        difference.size_difference_bytes,
        difference.count_difference,
    )

session.stop()
```

---

# 10. Leak Detection Workflow

Use this repeatable process.

## Step 1: Reproduce the Workload

Run a realistic workload repeatedly.

```python
for _ in range(10_000):
    await runtime.submit("emails.send_welcome_email", 42)
```

For real investigations, do not only test synthetic object allocation. Include:

- representative task arguments;
- plugins;
- result storage;
- retries;
- logging;
- external-client wrappers.

---

## Step 2: Capture a Baseline

```python
session = MemorySnapshotSession()
session.start()
```

Perform ordinary cleanup before the baseline:

```python
import gc

gc.collect()
```

---

## Step 3: Run the Same Workload Several Times

Look for memory that continues growing after equivalent workload rounds.

```text
Round 1: 100 MB
Round 2: 104 MB
Round 3: 109 MB
Round 4: 115 MB
```

Growth may indicate retention.

But do not conclude too quickly. Python allocators may keep memory arenas reserved for reuse, even after objects are released.

Differentiate:

```text
Python object retention
```

from:

```text
Operating-system resident memory retained by allocator
```

`tracemalloc` is especially useful for Python-level allocations.

---

## Step 4: Compare Snapshots

Look for large positive allocation differences.

Common clues:

```text
A list append line
A cache assignment
A result-store dictionary assignment
An exception-recording location
A callback registration line
A global collection
```

---

## Step 5: Find the Owning Reference

Once you identify an object type or allocation line, inspect what keeps instances alive.

Useful tools include:

```python
import gc

referrers = gc.get_referrers(suspected_object)

for referrer in referrers:
    print(type(referrer), repr(referrer)[:300])
```

Use this carefully:

- `gc.get_referrers(...)` itself creates temporary references;
- debugger and inspection code can change observed lifetimes;
- output can be large.

---

# 11. Task-System Retention Risks

## Unbounded Result Storage

Current in-memory result storage is intentionally educational.

A production system should not keep all results forever.

Use:

- TTL expiration;
- max-entry retention;
- a durable backend with cleanup jobs;
- explicit result deletion;
- result archival.

PulseQueue includes:

```python
from pulsequeue.retention import BoundedRetentionStore
```

Example:

```python
store = BoundedRetentionStore[str, object](max_entries=1_000)
```

When entry `1001` arrives, the oldest retained value is evicted.

---

## Exception Tracebacks

Exceptions can retain stack frames.

Stack frames may retain:

- large request payloads;
- database records;
- local variables;
- closures;
- task envelopes.

Avoid storing raw exception objects indefinitely:

```python
failed_exceptions.append(error)
```

Prefer safe summaries:

```python
{
    "exception_type": type(error).__name__,
    "message": str(error),
}
```

PulseQueue uses:

```python
TaskFailure(
    exception_type=...,
    message=...,
)
```

rather than permanently retaining raw exception objects in result snapshots.

---

## Background Task Registries

This leaks completed tasks:

```python
background_tasks: set[asyncio.Task[object]] = set()

def launch(coroutine: object) -> None:
    task = asyncio.create_task(coroutine)
    background_tasks.add(task)
```

Correct it by removing completed tasks:

```python
def launch(coroutine: object) -> None:
    task = asyncio.create_task(coroutine)
    background_tasks.add(task)
    task.add_done_callback(background_tasks.discard)
```

Also inspect task exceptions so failures do not disappear.

---

## Plugin Event History

An in-memory event plugin is useful for tests:

```python
collector = InMemoryEventPlugin()
```

But this retains every event:

```python
collector.events.append(event)
```

Use it only for:

- tests;
- short-lived local demos;
- bounded diagnostic sessions.

For long-running production telemetry, send events to an external metrics or logging backend, or cap retention.

---

# 12. Memory Metrics Worth Monitoring

For a real worker deployment, monitor:

| Metric | Why it matters |
|---|---|
| Process RSS memory | Actual memory visible to operating system |
| Python traced allocations | Python-level allocation growth |
| Queue depth | Pending work and possible retention |
| Result count | Unbounded result backend growth |
| Event count | In-memory plugin retention |
| Active task count | Worker saturation |
| Retry count | Repeated task-object churn |
| Process pool count | CPU worker memory multiplication |
| GC collection count | Unusual allocation pressure |

---

# 13. CPython Allocator Behavior

A useful distinction:

```text
Object freed by Python
```

does not always mean:

```text
Operating system immediately receives memory back
```

CPython’s allocator may keep memory arenas for future Python allocations.

This can make process RSS appear stable or high even when object counts are no longer growing.

Investigate both:

1. object and allocation growth using `tracemalloc`;
2. operating-system memory using container or process metrics.

Do not repeatedly call `gc.collect()` just to force RSS down. It may not achieve that goal and may increase latency.

---

# 14. Memory Investigation Commands

Run a small Python allocation diagnostic:

```bash
python - <<'PY'
from pulsequeue.memory import garbage_collection_stats

print(garbage_collection_stats())
PY
```

Run the tutorial leak-comparison example:

```bash
python examples/46_memory_growth_workload.py
```

Run slot allocation comparison:

```bash
python examples/43_tracemalloc_slots.py
```

Run all memory-related tests:

```bash
python -m pytest \
  tests/test_memory_and_observers.py \
  tests/test_memory_profiler_and_retention.py \
  tests/test_events.py \
  -q
```

---

# 15. Quick Memory Checklist

Before optimizing:

- [ ] Is memory actually growing across repeated equivalent workloads?
- [ ] Is the growth in Python allocations, process RSS, or both?
- [ ] Is a long-lived object retaining results, events, callbacks, or tasks?
- [ ] Are exception objects or tracebacks stored indefinitely?
- [ ] Are caches bounded and evicting correctly?
- [ ] Are weak references appropriate for observers?
- [ ] Is `__slots__` justified by volume and fixed object shape?
- [ ] Has the workload been profiled with `tracemalloc`?
- [ ] Could a process pool be multiplying memory use per worker process?
- [ ] Is a durable result backend configured with retention policies?
