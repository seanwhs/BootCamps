# Part 9: `__slots__`, Object Layout, and Memory Profiling

A task queue may create a very large number of small objects:

- task envelopes;
- result snapshots;
- task failures;
- metrics events;
- retry records;
- lifecycle notifications.

For one object, a few hundred bytes rarely matters. For one million objects, it matters a great deal.

This part explains how Python normally stores object attributes, how `__slots__` can reduce overhead for fixed-shape objects, and how to measure memory rather than guessing.

---

## Step 1: Understand Instance Dictionaries

### The Target

Observe the default attribute-storage behavior of ordinary Python objects.

### The Concept

By default, most Python instances have a dictionary named `__dict__`.

```python
class TaskRecord:
    pass

record = TaskRecord()
record.task_id = "task-001"
```

Internally, Python commonly stores the attribute in:

```python
record.__dict__
```

That flexibility is convenient. New attributes can be added at any time:

```python
record.owner = "platform-team"
record.unexpected_debug_value = True
```

But each instance dictionary has memory cost.

Think of a normal Python object as a filing cabinet with an expandable drawer. You can add any label at any time, but every cabinet needs the drawer mechanism.

### The Implementation

Create this example.

## `examples/40_instance_dictionary.py`

```python
"""Demonstrate default Python instance attribute storage."""

from __future__ import annotations


class StandardTaskRecord:
    """A normal object with a per-instance attribute dictionary."""

    def __init__(self, task_id: str, task_name: str) -> None:
        self.task_id = task_id
        self.task_name = task_name


record = StandardTaskRecord(
    task_id="task-001",
    task_name="emails.send_welcome_email",
)

print(f"Initial instance dictionary: {record.__dict__}")

record.priority = 10

print(f"Dictionary after adding priority: {record.__dict__}")
print(f"Has __dict__: {hasattr(record, '__dict__')}")
```

### The Verification

Run:

```bash
python examples/40_instance_dictionary.py
```

Expected output:

```text
Initial instance dictionary: {'task_id': 'task-001', 'task_name': 'emails.send_welcome_email'}
Dictionary after adding priority: {'task_id': 'task-001', 'task_name': 'emails.send_welcome_email', 'priority': 10}
Has __dict__: True
```

---

## Step 2: Create a Slot-Based High-Volume Event Model

### The Target

Create a compact immutable task event model using `dataclass(..., slots=True)`.

### The Concept

`__slots__` declares the fixed attributes an instance may hold:

```python
class TaskEvent:
    __slots__ = ("task_id", "event_name")
```

This usually prevents Python from creating a normal per-instance `__dict__`.

A slot-based object is like a form with fixed labeled boxes:

```text
Task ID: [         ]
Event name: [      ]
Timestamp: [       ]
```

You cannot add random new fields unless the class explicitly permits an instance dictionary.

For framework events and internal records, this is often a good fit because their shape should be stable.

### The Implementation

Create the event module.

## `src/pulsequeue/events.py`

```python
"""Compact lifecycle event objects for high-volume task instrumentation."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any


class TaskEventType(StrEnum):
    """Describe significant task lifecycle transitions."""

    SUBMITTED = "task.submitted"
    STARTED = "task.started"
    RETRYING = "task.retrying"
    SUCCEEDED = "task.succeeded"
    FAILED = "task.failed"
    CANCELLED = "task.cancelled"


@dataclass(frozen=True, slots=True)
class TaskEvent:
    """A compact immutable task lifecycle event.

    slots=True removes the normal per-instance __dict__. frozen=True prevents
    observers from modifying historical event data after publication.
    """

    event_type: TaskEventType
    task_id: str
    task_name: str
    occurred_at: datetime
    attempt: int
    details: tuple[tuple[str, str], ...] = ()

    @classmethod
    def create(
        cls,
        *,
        event_type: TaskEventType,
        task_id: str,
        task_name: str,
        attempt: int,
        details: dict[str, Any] | None = None,
    ) -> TaskEvent:
        """Create an immutable event with safely normalized detail values."""
        if not task_id:
            raise ValueError("task_id cannot be empty.")

        if not task_name:
            raise ValueError("task_name cannot be empty.")

        if attempt < 0:
            raise ValueError("attempt must be zero or greater.")

        normalized_details = tuple(
            sorted(
                (str(key), str(value))
                for key, value in (details or {}).items()
            )
        )

        return cls(
            event_type=event_type,
            task_id=task_id,
            task_name=task_name,
            occurred_at=datetime.now(UTC),
            attempt=attempt,
            details=normalized_details,
        )

    def details_as_dict(self) -> dict[str, str]:
        """Return a mutable copy appropriate for JSON serialization."""
        return dict(self.details)
```

Create an example.

## `examples/41_slots_event_model.py`

```python
"""Demonstrate compact immutable slot-based task events."""

from __future__ import annotations

from pulsequeue.events import TaskEvent, TaskEventType


event = TaskEvent.create(
    event_type=TaskEventType.SUBMITTED,
    task_id="task-001",
    task_name="emails.send_welcome_email",
    attempt=0,
    details={
        "queue": "emails",
        "locale": "en-GB",
    },
)

print(f"Event: {event}")
print(f"Event details: {event.details_as_dict()}")
print(f"Has __dict__: {hasattr(event, '__dict__')}")

try:
    event.task_name = "changed"
except Exception as error:
    print(f"Immutable-event error: {type(error).__name__}: {error}")

try:
    event.extra_debug_value = "not allowed"
except Exception as error:
    print(f"Unexpected-attribute error: {type(error).__name__}: {error}")
```

### The Verification

Run:

```bash
python examples/41_slots_event_model.py
```

Expected output includes:

```text
Has __dict__: False
Immutable-event error: FrozenInstanceError:
Unexpected-attribute error: TypeError:
```

The precise exception messages vary by Python version.

---

## Step 3: Measure Shallow Object Size

### The Target

Compare ordinary and slot-based instance sizes using `sys.getsizeof`.

### The Concept

`sys.getsizeof(...)` reports the **shallow size** of an object: the memory directly owned by that object.

It does not recursively include every referenced object.

For example, the shallow size of a list does not include the full size of every object inside that list.

This means `sys.getsizeof` is useful for quick comparisons, but it is not a complete memory profiler.

### The Implementation

Create the example.

## `examples/42_slots_size_comparison.py`

```python
"""Compare shallow object sizes for dictionary-backed and slot-backed classes."""

from __future__ import annotations

import sys
from dataclasses import dataclass


class StandardRecord:
    """A normal object with an instance dictionary."""

    def __init__(self, task_id: str, task_name: str, attempt: int) -> None:
        self.task_id = task_id
        self.task_name = task_name
        self.attempt = attempt


@dataclass(slots=True)
class SlottedRecord:
    """An object with fixed slot-based storage."""

    task_id: str
    task_name: str
    attempt: int


standard = StandardRecord(
    task_id="task-001",
    task_name="emails.send_welcome_email",
    attempt=1,
)

slotted = SlottedRecord(
    task_id="task-001",
    task_name="emails.send_welcome_email",
    attempt=1,
)

print(f"Standard object shallow size: {sys.getsizeof(standard)} bytes")
print(f"Standard __dict__ size: {sys.getsizeof(standard.__dict__)} bytes")
print(
    "Standard combined shallow size: "
    f"{sys.getsizeof(standard) + sys.getsizeof(standard.__dict__)} bytes"
)

print(f"Slotted object shallow size: {sys.getsizeof(slotted)} bytes")
print(f"Slotted object has __dict__: {hasattr(slotted, '__dict__')}")
```

### The Verification

Run:

```bash
python examples/42_slots_size_comparison.py
```

Typical output resembles:

```text
Standard object shallow size: 56 bytes
Standard __dict__ size: 296 bytes
Standard combined shallow size: 352 bytes
Slotted object shallow size: 56 bytes
Slotted object has __dict__: False
```

Exact numbers differ by Python build and platform. The key observation is that the ordinary object has a separate dictionary allocation while the slot-based object does not.

---

## Step 4: Profile Allocations with `tracemalloc`

### The Target

Use `tracemalloc` to compare memory allocations for many standard versus slotted records.

### The Concept

`tracemalloc` is Python’s built-in allocation tracer.

It can answer questions such as:

- Which source lines allocated the most memory?
- Did a code path allocate more after a change?
- Does creating many events retain more memory than expected?

Think of it as a warehouse inventory scanner. Instead of estimating where boxes went, it records where allocations originated.

### The Implementation

Create this example.

## `examples/43_tracemalloc_slots.py`

```python
"""Compare allocations of normal and slot-based task records."""

from __future__ import annotations

import gc
import tracemalloc
from dataclasses import dataclass


class StandardRecord:
    """Dictionary-backed record."""

    def __init__(self, task_id: str, task_name: str, attempt: int) -> None:
        self.task_id = task_id
        self.task_name = task_name
        self.attempt = attempt


@dataclass(slots=True)
class SlottedRecord:
    """Slot-backed record."""

    task_id: str
    task_name: str
    attempt: int


def allocated_bytes_for_standard_records(count: int) -> int:
    """Allocate records and return memory attributed to current tracing."""
    records = [
        StandardRecord(
            task_id=f"task-{index}",
            task_name="emails.send_welcome_email",
            attempt=1,
        )
        for index in range(count)
    ]

    current_bytes, _peak_bytes = tracemalloc.get_traced_memory()

    # Keep records alive until after the measurement.
    assert len(records) == count

    return current_bytes


def allocated_bytes_for_slotted_records(count: int) -> int:
    """Allocate slot-based records and return current traced allocation size."""
    records = [
        SlottedRecord(
            task_id=f"task-{index}",
            task_name="emails.send_welcome_email",
            attempt=1,
        )
        for index in range(count)
    ]

    current_bytes, _peak_bytes = tracemalloc.get_traced_memory()

    assert len(records) == count

    return current_bytes


def measure(creator_name: str, creator, count: int) -> None:
    """Measure one allocation strategy in a fresh tracing session."""
    gc.collect()
    tracemalloc.start()

    allocated_bytes = creator(count)

    tracemalloc.stop()

    print(
        f"{creator_name}: approximately {allocated_bytes:,} traced bytes "
        f"for {count:,} records"
    )


def main() -> None:
    """Compare allocations for a meaningful number of internal objects."""
    record_count = 100_000

    measure(
        "Standard dictionary-backed records",
        allocated_bytes_for_standard_records,
        record_count,
    )

    measure(
        "Slotted records",
        allocated_bytes_for_slotted_records,
        record_count,
    )


if __name__ == "__main__":
    main()
```

### The Verification

Run:

```bash
python examples/43_tracemalloc_slots.py
```

Expected output resembles:

```text
Standard dictionary-backed records: approximately 20,000,000 traced bytes for 100,000 records
Slotted records: approximately 15,000,000 traced bytes for 100,000 records
```

The exact allocation values depend on Python version and platform. The slotted version should generally allocate less memory for this fixed-shape model.

---

## Step 5: Understand Inheritance and `__slots__`

### The Target

Demonstrate the inheritance rule that every class in a hierarchy must cooperate with slots to avoid reintroducing an instance dictionary.

### The Concept

Slots are not automatically inherited in the way beginners often expect.

If a base class has slots but a child class does not, the child commonly receives an instance dictionary:

```python
class Base:
    __slots__ = ("task_id",)

class Child(Base):
    pass
```

The child can now have arbitrary attributes, which reduces the memory benefit.

To maintain a fixed layout, each subclass should define its own slots.

### The Implementation

Create this example.

## `examples/44_slots_inheritance.py`

```python
"""Demonstrate how inheritance affects __slots__ behavior."""

from __future__ import annotations


class SlottedBase:
    """A base class with one fixed field."""

    __slots__ = ("task_id",)

    def __init__(self, task_id: str) -> None:
        self.task_id = task_id


class ChildWithoutSlots(SlottedBase):
    """This child receives a normal instance dictionary."""


class ChildWithSlots(SlottedBase):
    """This child preserves fixed-shape storage."""

    __slots__ = ("task_name",)

    def __init__(self, task_id: str, task_name: str) -> None:
        super().__init__(task_id)
        self.task_name = task_name


without_slots = ChildWithoutSlots("task-001")
with_slots = ChildWithSlots("task-002", "emails.send_welcome_email")

print(f"ChildWithoutSlots has __dict__: {hasattr(without_slots, '__dict__')}")
print(f"ChildWithSlots has __dict__: {hasattr(with_slots, '__dict__')}")

without_slots.debug_note = "allowed because it has a dictionary"
print(f"ChildWithoutSlots debug note: {without_slots.debug_note}")

try:
    with_slots.debug_note = "not allowed"
except AttributeError as error:
    print(f"ChildWithSlots attribute error: {error}")
```

### The Verification

Run:

```bash
python examples/44_slots_inheritance.py
```

Expected output includes:

```text
ChildWithoutSlots has __dict__: True
ChildWithSlots has __dict__: False
ChildWithoutSlots debug note: allowed because it has a dictionary
ChildWithSlots attribute error:
```

---

## Step 6: Add Event Tests

### The Target

Add tests for the immutable slot-based event model.

### The Concept

Events may become operational records, metrics inputs, or audit signals. They should be stable after publication.

Tests verify:

- required values are validated;
- details are normalized;
- event objects are immutable;
- event objects do not unexpectedly gain a dictionary.

### The Implementation

Create the test file.

## `tests/test_events.py`

```python
"""Tests for compact immutable task lifecycle events."""

from __future__ import annotations

from dataclasses import FrozenInstanceError

import pytest

from pulsequeue.events import TaskEvent, TaskEventType


def test_task_event_normalizes_details() -> None:
    """Event details should become stable sorted immutable pairs."""
    event = TaskEvent.create(
        event_type=TaskEventType.SUBMITTED,
        task_id="task-001",
        task_name="emails.send_welcome_email",
        attempt=0,
        details={
            "queue": "emails",
            "priority": 10,
        },
    )

    assert event.details == (
        ("priority", "10"),
        ("queue", "emails"),
    )
    assert event.details_as_dict() == {
        "priority": "10",
        "queue": "emails",
    }


def test_task_event_uses_slots_and_is_immutable() -> None:
    """Events should avoid instance dictionaries and reject mutation."""
    event = TaskEvent.create(
        event_type=TaskEventType.SUCCEEDED,
        task_id="task-002",
        task_name="examples.double",
        attempt=1,
    )

    assert hasattr(event, "__dict__") is False

    with pytest.raises(FrozenInstanceError):
        event.task_name = "changed"  # type: ignore[misc]


def test_task_event_rejects_invalid_fields() -> None:
    """Core event identifiers and attempts must be valid."""
    with pytest.raises(ValueError, match="task_id cannot be empty"):
        TaskEvent.create(
            event_type=TaskEventType.STARTED,
            task_id="",
            task_name="examples.task",
            attempt=1,
        )

    with pytest.raises(ValueError, match="attempt must be zero or greater"):
        TaskEvent.create(
            event_type=TaskEventType.STARTED,
            task_id="task-003",
            task_name="examples.task",
            attempt=-1,
        )
```

### The Verification

Run all tests:

```bash
python -m pytest -q
```

Expected result:

```text
..........................................                             [100%]
42 passed
```

The exact total may vary. All tests should pass.

---

# Phase 3 Reference: When to Use `__slots__`

## Good Candidates

Use slots for high-volume objects with a fixed schema:

- task envelopes;
- task events;
- result snapshots;
- immutable configuration records;
- parser tokens;
- AST nodes;
- telemetry messages.

## Poor Candidates

Avoid slots when objects need open-ended attributes:

- user extension objects;
- ad hoc request state;
- ORM entities with dynamic fields;
- debugging-heavy prototypes;
- plugin objects expected to accept arbitrary metadata.

## Important Trade-Offs

| Benefit | Cost |
|---|---|
| Lower per-instance overhead | Less flexible attributes |
| Faster attribute access in some cases | Inheritance requires care |
| Prevents accidental fields | Some libraries expect `__dict__` |
| Better fit for fixed internal records | Wrapper metadata may require `__dict__` |

Recall the earlier `Task` class:

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

It keeps known internal fields compact while still allowing `functools.update_wrapper(...)` to attach function metadata.

That is a deliberate compromise: memory optimization should not break the public framework API.
