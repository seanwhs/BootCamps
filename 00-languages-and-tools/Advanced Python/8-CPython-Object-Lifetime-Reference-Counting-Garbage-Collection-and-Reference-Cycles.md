# Part 8: CPython Object Lifetime, Reference Counting, Garbage Collection, and Reference Cycles

Long-running workers do not only need correct concurrency. They need predictable memory behavior.

A task framework may process millions of task envelopes, results, exceptions, callbacks, and metadata objects over its lifetime. If objects remain reachable accidentally, memory usage grows even when each individual task appears to finish correctly.

CPython—the standard Python implementation—primarily manages object lifetime through **reference counting**.

A reference is simply a connection from one Python name or object to another object:

```python
message = {"task": "emails.send_welcome"}
```

Here, `message` refers to a dictionary.

When CPython sees that an object has no remaining references, it can usually release that object immediately. But cycles require another mechanism: the cyclic garbage collector.

This part covers:

- reference counting;
- immediate destruction in CPython;
- reference cycles;
- `weakref` for non-owning references;
- garbage collector inspection;
- safe cleanup patterns for task systems.

---

## Step 1: Observe CPython Reference Counting

### The Target

Create a demonstration that observes an object’s reference count as names and containers point to it.

### The Concept

Reference counting works like a library book checkout count.

If one person has the only checkout record for a book, there is one reference. If the book is also placed in a cart and listed in a table, more references exist.

When the final reference disappears, CPython can usually release the object immediately.

Python exposes `sys.getrefcount(...)` for diagnostics. It intentionally reports one extra reference because passing an object into the function temporarily creates another reference.

Therefore:

```python
sys.getrefcount(value) - 1
```

is usually closer to the practical count you want to observe.

Do not use reference-count values as application logic. They are implementation details useful for debugging and education.

### The Implementation

Create this example.

## `examples/35_reference_counting.py`

```python
"""Observe CPython reference counts as object references are added and removed."""

from __future__ import annotations

import sys


class TaskPayload:
    """A small object used only for reference-counting demonstration."""

    def __init__(self, task_name: str) -> None:
        self.task_name = task_name


def visible_reference_count(value: object) -> int:
    """Return a diagnostic reference count excluding this function-call reference."""
    return sys.getrefcount(value) - 1


payload = TaskPayload("emails.send_welcome_email")

print(f"Initial visible references: {visible_reference_count(payload)}")

another_name = payload
print(f"After assigning another name: {visible_reference_count(payload)}")

container = [payload]
print(f"After placing in a list: {visible_reference_count(payload)}")

mapping = {"payload": payload}
print(f"After placing in a dictionary: {visible_reference_count(payload)}")

del another_name
print(f"After deleting another_name: {visible_reference_count(payload)}")

del container
print(f"After deleting list: {visible_reference_count(payload)}")

del mapping
print(f"After deleting dictionary: {visible_reference_count(payload)}")
```

### The Verification

Run:

```bash
python examples/35_reference_counting.py
```

Expected output resembles:

```text
Initial visible references: 1
After assigning another name: 2
After placing in a list: 3
After placing in a dictionary: 4
After deleting another_name: 3
After deleting list: 2
After deleting dictionary: 1
```

Exact counts can differ slightly by Python version and execution environment. The important pattern is that adding references increases the count and deleting references decreases it.

---

## Step 2: Observe Immediate Cleanup with `__del__`

### The Target

Demonstrate that CPython commonly destroys a non-cyclic object immediately when its last reference disappears.

### The Concept

`__del__` is a finalizer method that Python may call when an object is being destroyed.

It is useful for education, but it is **not** a reliable mechanism for important resource cleanup.

Why not?

- Program shutdown can occur in a partially torn-down interpreter state.
- Reference cycles complicate timing.
- Other Python implementations do not necessarily use CPython’s immediate reference counting.
- Exceptions inside `__del__` are difficult to handle safely.

Use context managers for files, network connections, worker pools, and other critical resources:

```python
with open("output.txt", "w", encoding="utf-8") as file:
    file.write("safe cleanup")
```

Use `__del__` only for diagnostic or defensive cleanup—not primary correctness.

### The Implementation

Create this example.

## `examples/36_immediate_cleanup.py`

```python
"""Demonstrate CPython's common immediate cleanup of non-cyclic objects."""

from __future__ import annotations

import gc


class TaskLease:
    """A diagnostic object that announces when Python destroys it."""

    def __init__(self, task_id: str) -> None:
        self.task_id = task_id
        print(f"Created lease for {self.task_id}")

    def __del__(self) -> None:
        """Print only for demonstration; do not use finalizers for critical cleanup."""
        print(f"Destroyed lease for {self.task_id}")


def create_and_release_lease() -> None:
    """Create a local object that becomes unreachable when this function ends."""
    lease = TaskLease("task-001")
    print(f"Using lease for {lease.task_id}")


print("Before function call")
create_and_release_lease()
print("After function call")

# Explicit collection is included only to make the example educational.
# The normal non-cyclic object has typically already been destroyed.
collected_count = gc.collect()
print(f"Objects collected by explicit gc.collect(): {collected_count}")
```

### The Verification

Run:

```bash
python examples/36_immediate_cleanup.py
```

Typical CPython output:

```text
Before function call
Created lease for task-001
Using lease for task-001
Destroyed lease for task-001
After function call
Objects collected by explicit gc.collect(): 0
```

The `Destroyed lease...` line usually appears before `After function call`, showing CPython released the local object as soon as its final reference disappeared.

---

## Step 3: Create and Collect a Reference Cycle

### The Target

Build a cycle and show why reference counting alone cannot release it.

### The Concept

A reference cycle happens when objects keep references to one another:

```text
Task A → Task B
Task B → Task A
```

Even if the rest of the application no longer needs either task, each still has one reference: the reference from the other object.

Reference counting alone sees:

```text
Task A count = 1
Task B count = 1
```

Neither count reaches zero.

CPython’s cyclic garbage collector periodically searches for groups of objects that are unreachable from the application, even though they refer to one another.

Think of two people holding each other’s coats in an empty room. Each coat appears “owned,” but nobody outside the room can use either coat. The garbage collector identifies that the entire group is unreachable.

### The Implementation

Create this example.

## `examples/37_reference_cycles.py`

```python
"""Create a reference cycle and collect it with CPython's cyclic garbage collector."""

from __future__ import annotations

import gc
import weakref


class TaskNode:
    """A graph node that can point to another node."""

    def __init__(self, name: str) -> None:
        self.name = name
        self.next_node: TaskNode | None = None

    def __repr__(self) -> str:
        return f"TaskNode(name={self.name!r})"


def create_cycle() -> tuple[weakref.ReferenceType[TaskNode], weakref.ReferenceType[TaskNode]]:
    """Create two nodes that refer to each other and return non-owning weak refs."""
    first = TaskNode("first")
    second = TaskNode("second")

    first.next_node = second
    second.next_node = first

    return weakref.ref(first), weakref.ref(second)


gc.disable()

try:
    first_reference, second_reference = create_cycle()

    print(f"First node alive before collection: {first_reference() is not None}")
    print(f"Second node alive before collection: {second_reference() is not None}")

    # The function has returned, so no ordinary strong references remain.
    # The two objects remain alive only because they reference each other.
    collected_count = gc.collect()

    print(f"Objects collected: {collected_count}")
    print(f"First node alive after collection: {first_reference() is not None}")
    print(f"Second node alive after collection: {second_reference() is not None}")
finally:
    gc.enable()
```

### The Verification

Run:

```bash
python examples/37_reference_cycles.py
```

Expected output:

```text
First node alive before collection: True
Second node alive before collection: True
Objects collected: 2
First node alive after collection: False
Second node alive after collection: False
```

The exact collected count may be greater than `2` in some environments, but both weak references should return `None` after collection.

---

## Step 4: Use Weak References for Non-Owning Relationships

### The Target

Create a callback registry that does not accidentally keep listener objects alive forever.

### The Concept

A **weak reference** points to an object without keeping it alive.

Normal references are ownership-like:

```text
Registry → Listener
```

As long as the registry exists, the listener exists.

A weak reference is observational:

```text
Registry - - > Listener
```

The registry can use the listener while something else owns it, but the registry does not prevent cleanup.

This is valuable for:

- event listeners;
- caches;
- parent links in object graphs;
- plugin observers;
- metrics subscribers;
- debug instrumentation.

A common memory leak occurs when a long-lived application object stores callbacks bound to short-lived request or task objects.

### The Implementation

Create the module.

## `src/pulsequeue/observers.py`

```python
"""Weak-reference-backed observer registration for long-lived framework objects."""

from __future__ import annotations

import weakref
from collections.abc import Callable
from typing import Any


class TaskObserverRegistry:
    """Notify observers without extending observer object lifetimes.

    Bound instance methods are stored as weak references. Plain module-level
    functions are stored strongly because they generally live for the complete
    process lifetime and cannot be weakly referenced through WeakMethod.
    """

    def __init__(self) -> None:
        self._bound_methods: list[weakref.WeakMethod[Any]] = []
        self._functions: list[Callable[[str], None]] = []

    def add(self, observer: Callable[[str], None]) -> None:
        """Register a function or bound instance method."""
        if getattr(observer, "__self__", None) is not None:
            self._bound_methods.append(weakref.WeakMethod(observer))
        else:
            self._functions.append(observer)

    def notify(self, event_name: str) -> None:
        """Notify live observers and remove dead weak references."""
        for function in tuple(self._functions):
            function(event_name)

        live_bound_methods: list[weakref.WeakMethod[Any]] = []

        for method_reference in self._bound_methods:
            method = method_reference()

            if method is None:
                continue

            method(event_name)
            live_bound_methods.append(method_reference)

        self._bound_methods = live_bound_methods

    @property
    def observer_count(self) -> int:
        """Return live function and bound-method observer count."""
        live_bound_method_count = sum(
            method_reference() is not None
            for method_reference in self._bound_methods
        )
        return len(self._functions) + live_bound_method_count
```

Create an example.

## `examples/38_weak_observers.py`

```python
"""Demonstrate observer registration without retaining short-lived objects."""

from __future__ import annotations

import gc

from pulsequeue.observers import TaskObserverRegistry


class ConsoleObserver:
    """An observer that records task lifecycle notifications."""

    def __init__(self, name: str) -> None:
        self.name = name

    def on_event(self, event_name: str) -> None:
        """Print one event notification."""
        print(f"{self.name} received event: {event_name}")


def module_level_observer(event_name: str) -> None:
    """A normal function observer."""
    print(f"module observer received event: {event_name}")


registry = TaskObserverRegistry()

observer = ConsoleObserver("temporary observer")

registry.add(observer.on_event)
registry.add(module_level_observer)

print(f"Observer count before notification: {registry.observer_count}")
registry.notify("task.started")

del observer
gc.collect()

print(f"Observer count after deleting instance: {registry.observer_count}")
registry.notify("task.succeeded")
```

### The Verification

Run:

```bash
python examples/38_weak_observers.py
```

Expected output:

```text
Observer count before notification: 2
temporary observer received event: task.started
module observer received event: task.started
Observer count after deleting instance: 1
module observer received event: task.succeeded
```

The deleted `ConsoleObserver` instance does not receive the second event because the registry did not keep it alive.

---

## Step 5: Inspect Garbage-Collection Behavior

### The Target

Create a diagnostic utility that reports garbage-collector generation statistics.

### The Concept

CPython’s cyclic garbage collector organizes tracked objects into generations.

The general idea is:

- New objects are checked more frequently.
- Long-lived objects are checked less frequently.
- Most objects die young, so checking young objects often is efficient.

You do not usually tune garbage collection first. Measure memory behavior before changing defaults.

The `gc` module gives diagnostic access:

```python
gc.get_count()
gc.get_stats()
gc.collect()
```

This is like checking maintenance counters on a machine. It helps identify unusual behavior, but it is not a substitute for understanding what your application retains.

### The Implementation

Create this diagnostic module.

## `src/pulsequeue/memory.py`

```python
"""Memory and garbage-collection diagnostics for PulseQueue development."""

from __future__ import annotations

import gc
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class GarbageCollectionStats:
    """A serializable snapshot of CPython garbage-collection statistics."""

    generation_zero_count: int
    generation_one_count: int
    generation_two_count: int
    generation_zero_collections: int
    generation_one_collections: int
    generation_two_collections: int
    generation_zero_collected: int
    generation_one_collected: int
    generation_two_collected: int


def garbage_collection_stats() -> GarbageCollectionStats:
    """Return a stable snapshot of cyclic-garbage-collector activity."""
    counts = gc.get_count()
    generation_stats = gc.get_stats()

    return GarbageCollectionStats(
        generation_zero_count=counts[0],
        generation_one_count=counts[1],
        generation_two_count=counts[2],
        generation_zero_collections=generation_stats[0]["collections"],
        generation_one_collections=generation_stats[1]["collections"],
        generation_two_collections=generation_stats[2]["collections"],
        generation_zero_collected=generation_stats[0]["collected"],
        generation_one_collected=generation_stats[1]["collected"],
        generation_two_collected=generation_stats[2]["collected"],
    )


def collect_cycles() -> int:
    """Run a full cyclic garbage-collection pass and return collected count."""
    return gc.collect()
```

Create an example.

## `examples/39_gc_diagnostics.py`

```python
"""Inspect CPython cyclic-garbage-collector statistics."""

from __future__ import annotations

from pulsequeue.memory import collect_cycles, garbage_collection_stats


class CyclicObject:
    """A simple object that can participate in a reference cycle."""

    def __init__(self) -> None:
        self.other: CyclicObject | None = None


print(f"GC stats before allocations: {garbage_collection_stats()}")

objects: list[CyclicObject] = []

for _ in range(1_000):
    first = CyclicObject()
    second = CyclicObject()

    first.other = second
    second.other = first

    objects.extend([first, second])

del objects
del first
del second

print(f"GC stats before explicit collection: {garbage_collection_stats()}")

collected = collect_cycles()

print(f"Explicitly collected objects: {collected}")
print(f"GC stats after collection: {garbage_collection_stats()}")
```

### The Verification

Run:

```bash
python examples/39_gc_diagnostics.py
```

Expected output includes three `GarbageCollectionStats(...)` lines and an object collection count.

The exact numbers are machine- and timing-dependent. The important result is that explicit collection reports objects collected after the cyclic objects become unreachable.

---

## Step 6: Add Tests for Memory Utilities and Weak Observers

### The Target

Add tests that verify weak observer cleanup and memory diagnostics.

### The Concept

Memory behavior is often difficult to test perfectly because the interpreter controls collection timing.

Instead of asserting fragile reference counts, test stable application guarantees:

- deleted weak observers are not notified;
- diagnostics return valid structured information;
- explicit collection returns a non-negative integer.

### The Implementation

Create the test file.

## `tests/test_memory_and_observers.py`

```python
"""Tests for weak observers and garbage-collection diagnostics."""

from __future__ import annotations

import gc

from pulsequeue.memory import collect_cycles, garbage_collection_stats
from pulsequeue.observers import TaskObserverRegistry


class RecordingObserver:
    """Store received events for observer-registry tests."""

    def __init__(self) -> None:
        self.events: list[str] = []

    def on_event(self, event_name: str) -> None:
        """Record one lifecycle event."""
        self.events.append(event_name)


def test_weak_bound_observer_is_not_retained() -> None:
    """Deleting an observer should remove its live weak callback."""
    registry = TaskObserverRegistry()

    observer = RecordingObserver()
    registry.add(observer.on_event)

    registry.notify("task.started")

    assert observer.events == ["task.started"]
    assert registry.observer_count == 1

    del observer
    gc.collect()

    registry.notify("task.succeeded")

    assert registry.observer_count == 0


def test_normal_function_observer_remains_registered() -> None:
    """Module-level functions should remain strongly registered."""
    registry = TaskObserverRegistry()
    received_events: list[str] = []

    def observer(event_name: str) -> None:
        received_events.append(event_name)

    registry.add(observer)
    registry.notify("task.completed")

    assert received_events == ["task.completed"]
    assert registry.observer_count == 1


def test_garbage_collection_stats_are_non_negative() -> None:
    """GC diagnostic values should be valid non-negative counters."""
    stats = garbage_collection_stats()

    assert stats.generation_zero_count >= 0
    assert stats.generation_one_count >= 0
    assert stats.generation_two_count >= 0
    assert stats.generation_zero_collections >= 0
    assert stats.generation_one_collections >= 0
    assert stats.generation_two_collections >= 0


def test_collect_cycles_returns_non_negative_count() -> None:
    """Explicit cyclic collection should return an integer count."""
    collected = collect_cycles()

    assert isinstance(collected, int)
    assert collected >= 0
```

### The Verification

Run the full suite:

```bash
python -m pytest -q
```

Expected result:

```text
.......................................                                [100%]
39 passed
```

Your exact count may differ if you added tests in earlier parts. All tests should pass.

---

# Phase 3 Reference: CPython Memory Management

## Reference Counting in One Sentence

CPython generally destroys an object when its reference count reaches zero.

This is why resource-like diagnostic output often appears immediately after:

```python
del object_name
```

or after a local variable goes out of scope.

---

## Cycles Need Garbage Collection

Reference counting cannot solve:

```python
first.other = second
second.other = first
```

because each object still has a reference from the other.

CPython’s cyclic garbage collector identifies unreachable groups and releases them.

---

## Avoid `__del__` for Important Cleanup

Avoid designs such as:

```python
class DatabaseConnection:
    def __del__(self) -> None:
        self.close()
```

Prefer explicit context managers:

```python
class DatabaseConnection:
    def close(self) -> None:
        ...

    def __enter__(self) -> DatabaseConnection:
        return self

    def __exit__(self, exception_type, exception, traceback) -> None:
        self.close()
```

Or asynchronous equivalents:

```python
async with connection:
    await connection.query(...)
```

The framework already follows this philosophy with:

```python
async with PulseQueueWorker(app, broker):
    ...
```

---

## Common Long-Running-Service Memory Leaks

Watch for these patterns:

| Pattern | Why it leaks |
|---|---|
| Global list of completed task objects | Objects remain intentionally reachable forever |
| Callback registry holding bound methods | Registry retains short-lived instances |
| Exception objects retained indefinitely | Tracebacks can retain stack frames and local variables |
| Cache without eviction | Useful data accumulates forever |
| Background task set never pruned | Completed `asyncio.Task` objects remain referenced |
| Parent-child object cycles with external roots | A root prevents an entire graph from being collected |

The correct question is usually not:

> “Why did the garbage collector not run?”

It is:

> “What still holds a reference to this object?”
