# Primer 5: Data Models, Dataclasses, Enums, and Immutable Task State

Task frameworks move data through many stages:

```text
Task submitted
    ↓
Task queued
    ↓
Task running
    ↓
Task retrying, succeeded, failed, or cancelled
```

That requires clear data models.

This primer introduces:

- ordinary classes used as data containers;
- `dataclass`;
- `Enum` and `StrEnum`;
- immutability with `frozen=True`;
- memory-conscious models with `slots=True`;
- why task systems use immutable snapshots instead of exposing mutable internal state.

> **Naming correction for prior primer examples:** Python module names cannot begin with a digit.  
> If you intend to run primer files with `python -m ...`, name them like:
>
> ```text
> primer_02_functions.py
> primer_03_function_arguments.py
> ```
>
> rather than:
>
> ```text
> 02_functions.py
> 03_function_arguments.py
> ```
>
> You can still execute a digit-prefixed file directly:
>
> ```bash
> python primer_examples/02_functions.py
> ```
>
> For the examples in this primer, we use valid module names beginning with `primer_`.

---

# Step 1: Build an Ordinary Data Container Class

## The Target

Create a simple class for holding task information.

## The Concept

A task record needs related values stored together:

```text
Task ID
Task name
Attempt count
```

An ordinary class can hold this information.

Think of it as a paper task card. Each card belongs to one task and has labeled fields.

## The Implementation

Create this file.

## `primer_examples/primer_05_plain_data_class.py`

```python
"""Primer 5: ordinary classes used as task data containers."""

from __future__ import annotations


class TaskRecord:
    """Store mutable information about one task execution."""

    def __init__(
        self,
        task_id: str,
        task_name: str,
        attempt: int,
    ) -> None:
        """Create one task record after basic validation."""
        if not task_id:
            raise ValueError("task_id cannot be empty.")

        if not task_name:
            raise ValueError("task_name cannot be empty.")

        if attempt < 0:
            raise ValueError("attempt must be zero or greater.")

        self.task_id = task_id
        self.task_name = task_name
        self.attempt = attempt

    def describe(self) -> str:
        """Return a readable task summary."""
        return (
            f"TaskRecord(task_id={self.task_id!r}, "
            f"task_name={self.task_name!r}, "
            f"attempt={self.attempt})"
        )


def main() -> None:
    """Create and modify one mutable task record."""
    record = TaskRecord(
        task_id="task-001",
        task_name="emails.send_welcome_email",
        attempt=1,
    )

    print(record.describe())

    record.attempt += 1

    print(f"After retry: {record.describe()}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_05_plain_data_class
```

Expected output:

```text
TaskRecord(task_id='task-001', task_name='emails.send_welcome_email', attempt=1)
After retry: TaskRecord(task_id='task-001', task_name='emails.send_welcome_email', attempt=2)
```

---

# Step 2: Replace Repetitive Data-Class Code with `@dataclass`

## The Target

Create the same kind of task record with Python’s `dataclass` decorator.

## The Concept

Many classes mainly store data.

Without `dataclass`, you often write repetitive code:

```python
def __init__(...):
    ...

def __repr__(...):
    ...

def __eq__(...):
    ...
```

A **dataclass** generates much of this boilerplate automatically.

Think of it as a form generator. You declare the fields, and Python creates the standard setup machinery.

## The Implementation

Create this file.

## `primer_examples/primer_06_dataclass_basics.py`

```python
"""Primer 5: use dataclass for structured task information."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class TaskRecord:
    """Store mutable task information with generated constructor and repr."""

    task_id: str
    task_name: str
    attempt: int = 0

    def start_next_attempt(self) -> None:
        """Increase mutable attempt state."""
        self.attempt += 1


def main() -> None:
    """Demonstrate generated dataclass behavior."""
    first_record = TaskRecord(
        task_id="task-001",
        task_name="emails.send_welcome_email",
    )

    second_record = TaskRecord(
        task_id="task-001",
        task_name="emails.send_welcome_email",
    )

    print(f"First record: {first_record}")
    print(f"Records initially equal: {first_record == second_record}")

    first_record.start_next_attempt()

    print(f"First record after retry: {first_record}")
    print(f"Records still equal: {first_record == second_record}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_06_dataclass_basics
```

Expected output:

```text
First record: TaskRecord(task_id='task-001', task_name='emails.send_welcome_email', attempt=0)
Records initially equal: True
First record after retry: TaskRecord(task_id='task-001', task_name='emails.send_welcome_email', attempt=1)
Records still equal: False
```

Notice that `@dataclass` provides a useful representation and value-based equality automatically.

---

# Step 3: Represent Finite States with `StrEnum`

## The Target

Create a task-state enumeration.

## The Concept

A task should not have arbitrary string state:

```python
state = "done"
state = "complete"
state = "finished"
```

Those values may all mean the same thing, but inconsistencies create bugs.

An **enumeration**, or enum, provides a fixed set of valid choices.

PulseQueue uses states such as:

```text
queued
running
retrying
succeeded
failed
cancelled
```

`StrEnum` is useful because each enum member also behaves like a string for logging and JSON output.

Think of an enum as a controlled set of traffic lights. You can choose `RED`, `YELLOW`, or `GREEN`; you cannot silently invent `PURPLE`.

## The Implementation

Create this file.

## `primer_examples/primer_07_task_state_enum.py`

```python
"""Primer 5: represent task lifecycle values with StrEnum."""

from __future__ import annotations

from enum import StrEnum


class TaskState(StrEnum):
    """Allowed lifecycle states for one task."""

    QUEUED = "queued"
    RUNNING = "running"
    SUCCEEDED = "succeeded"
    FAILED = "failed"


def describe_state(state: TaskState) -> str:
    """Return a readable description for one known task state."""
    match state:
        case TaskState.QUEUED:
            return "Task is waiting for a worker."
        case TaskState.RUNNING:
            return "Task is currently executing."
        case TaskState.SUCCEEDED:
            return "Task completed successfully."
        case TaskState.FAILED:
            return "Task completed with an error."


def main() -> None:
    """Inspect enum names, values, and string compatibility."""
    state = TaskState.RUNNING

    print(f"Enum member: {state}")
    print(f"Enum name: {state.name}")
    print(f"Stable string value: {state.value}")
    print(f"Description: {describe_state(state)}")
    print(f"StrEnum compares to its string value: {state == 'running'}")

    print("\nAll available states:")

    for available_state in TaskState:
        print(f"- {available_state.name}: {available_state.value}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_07_task_state_enum
```

Expected output includes:

```text
Enum member: running
Enum name: RUNNING
Stable string value: running
Description: Task is currently executing.
StrEnum compares to its string value: True

All available states:
- QUEUED: queued
- RUNNING: running
- SUCCEEDED: succeeded
- FAILED: failed
```

---

# Step 4: Make Historical Data Immutable

## The Target

Create an immutable task event using `@dataclass(frozen=True)`.

## The Concept

Some data should change over time:

```text
Current worker count
Current queue size
Current retry attempt
```

Other data should represent history and must not change:

```text
Task started at 12:00
Task succeeded at 12:01
Task failed with ConnectionError
```

A task event is a historical record. If one plugin modifies an event after another plugin receives it, the system becomes hard to reason about.

Use:

```python
@dataclass(frozen=True)
```

This makes assignment to fields fail.

Think of it as sealing a completed shipping label under clear plastic. People can read it, but they should not rewrite it.

## The Implementation

Create this file.

## `primer_examples/primer_08_frozen_dataclass.py`

```python
"""Primer 5: immutable historical task events."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime

from pulsequeue.events import TaskEventType


@dataclass(frozen=True)
class SimpleTaskEvent:
    """Represent an immutable historical task event."""

    event_type: TaskEventType
    task_id: str
    task_name: str
    occurred_at: datetime
    attempt: int


def main() -> None:
    """Create an event and demonstrate mutation rejection."""
    event = SimpleTaskEvent(
        event_type=TaskEventType.STARTED,
        task_id="task-001",
        task_name="emails.send_welcome_email",
        occurred_at=datetime.now(UTC),
        attempt=1,
    )

    print(event)

    try:
        event.attempt = 2
    except Exception as error:
        print(f"Mutation rejected: {type(error).__name__}: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_08_frozen_dataclass
```

Expected output includes:

```text
SimpleTaskEvent(...)
Mutation rejected: FrozenInstanceError: cannot assign to field 'attempt'
```

---

# Step 5: Use `slots=True` for Fixed-Shape Internal Records

## The Target

Create a slot-based immutable task event.

## The Concept

Ordinary Python objects usually store attributes in a flexible dictionary:

```python
object.__dict__
```

That flexibility has memory cost.

For high-volume internal records with a known fixed shape, use:

```python
@dataclass(frozen=True, slots=True)
```

The `slots=True` option typically removes the normal instance dictionary.

PulseQueue uses this for records such as:

```python
TaskEvent
TaskResultSnapshot
WorkerStats
```

Think of normal objects as expandable filing cabinets. Slot-based objects are forms with a fixed number of printed boxes.

## The Implementation

Create this file.

## `primer_examples/primer_09_slotted_dataclass.py`

```python
"""Primer 5: compare a normal dataclass with a slot-based dataclass."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class StandardEvent:
    """Immutable event with ordinary instance dictionary storage."""

    task_id: str
    task_name: str
    attempt: int


@dataclass(frozen=True, slots=True)
class SlottedEvent:
    """Immutable event with fixed slot-based storage."""

    task_id: str
    task_name: str
    attempt: int


def main() -> None:
    """Compare attribute-storage capabilities."""
    standard = StandardEvent(
        task_id="task-standard",
        task_name="examples.standard",
        attempt=1,
    )

    slotted = SlottedEvent(
        task_id="task-slotted",
        task_name="examples.slotted",
        attempt=1,
    )

    print(f"Standard event has __dict__: {hasattr(standard, '__dict__')}")
    print(f"Slotted event has __dict__: {hasattr(slotted, '__dict__')}")

    print(f"Standard event: {standard}")
    print(f"Slotted event: {slotted}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_09_slotted_dataclass
```

Expected output:

```text
Standard event has __dict__: True
Slotted event has __dict__: False
Standard event: StandardEvent(task_id='task-standard', task_name='examples.standard', attempt=1)
Slotted event: SlottedEvent(task_id='task-slotted', task_name='examples.slotted', attempt=1)
```

---

# Step 6: Use `default_factory` for Mutable Fields

## The Target

Avoid accidentally sharing one mutable list or dictionary between all dataclass instances.

## The Concept

This is dangerous:

```python
@dataclass
class BadTaskLog:
    messages: list[str] = []
```

The list is created once when Python builds the class, not once per instance.

That means different instances share one list.

Use:

```python
from dataclasses import field

messages: list[str] = field(default_factory=list)
```

A **default factory** is a callable Python invokes separately for each new instance.

Think of it as telling a hotel to provide a new notebook for every guest, instead of placing one shared notebook in every room.

## The Implementation

Create this file.

## `primer_examples/primer_10_default_factory.py`

```python
"""Primer 5: create independent mutable defaults with default_factory."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class TaskLog:
    """Store event messages independently for each task."""

    task_id: str
    messages: list[str] = field(default_factory=list)

    def add(self, message: str) -> None:
        """Append one task log message."""
        self.messages.append(message)


def main() -> None:
    """Demonstrate that each instance receives its own list."""
    first_log = TaskLog(task_id="task-001")
    second_log = TaskLog(task_id="task-002")

    first_log.add("task started")

    print(f"First task messages: {first_log.messages}")
    print(f"Second task messages: {second_log.messages}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_10_default_factory
```

Expected output:

```text
First task messages: ['task started']
Second task messages: []
```

---

# Step 7: Inspect Real PulseQueue State Models

## The Target

Create and inspect actual PulseQueue task events and result snapshots.

## The Concept

The framework uses two different data-model styles:

| Model | Mutability | Why |
|---|---|---|
| Internal result store state | Mutable | Worker changes task lifecycle over time |
| `TaskResultSnapshot` | Immutable | Callers need stable observations |
| `TaskEvent` | Immutable | Plugins receive trustworthy history |

This is a common architecture pattern:

```text
Mutable internal machinery
        ↓
Immutable external snapshots
```

## The Implementation

Create this file.

## `primer_examples/primer_11_pulsequeue_data_models.py`

```python
"""Primer 5: inspect real immutable PulseQueue event and result models."""

from __future__ import annotations

from pulsequeue.events import TaskEvent, TaskEventType
from pulsequeue.result import InMemoryResultStore


def main() -> None:
    """Create framework data models and inspect their stable state."""
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

    print(f"Event: {event}")
    print(f"Event details: {event.details_as_dict()}")
    print(f"Event has __dict__: {hasattr(event, '__dict__')}")

    result_store = InMemoryResultStore()

    result_store.create(
        task_id="task-001",
        task_name="emails.send_welcome_email",
        max_attempts=2,
    )

    queued_snapshot = result_store.snapshot("task-001")

    print(f"\nQueued snapshot: {queued_snapshot}")

    result_store.mark_running("task-001")
    result_store.mark_succeeded("task-001", "email accepted")

    succeeded_snapshot = result_store.snapshot("task-001")

    print(f"Succeeded snapshot: {succeeded_snapshot}")

    try:
        succeeded_snapshot.attempt = 999
    except Exception as error:
        print(f"Snapshot mutation rejected: {type(error).__name__}: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.primer_11_pulsequeue_data_models
```

Expected output includes:

```text
Event has __dict__: False
Queued snapshot: TaskResultSnapshot(...)
Succeeded snapshot: TaskResultSnapshot(...)
Snapshot mutation rejected: FrozenInstanceError:
```

---

# Primer 5 Reference: Choosing a Model Style

| Need | Prefer |
|---|---|
| Behavior-heavy object with custom lifecycle | Ordinary class |
| Primarily data with generated constructor and repr | `@dataclass` |
| Historical record that must not change | `@dataclass(frozen=True)` |
| High-volume fixed-shape internal record | `@dataclass(frozen=True, slots=True)` |
| Fixed set of state values | `Enum` or `StrEnum` |
| Per-instance mutable list or dictionary | `field(default_factory=...)` |
| Dynamic JSON-like external payload | Validate then convert to dataclass |

---

# Primer 5 Completion Checklist

Before continuing to descriptors, metaclasses, and framework state machines, confirm that you can:

- [ ] Explain why a dataclass reduces repetitive data-container code.
- [ ] Use `StrEnum` for fixed state values.
- [ ] Explain why task states should not be arbitrary strings.
- [ ] Use `frozen=True` for immutable historical records.
- [ ] Explain when `slots=True` is useful.
- [ ] Use `field(default_factory=list)` for mutable fields.
- [ ] Distinguish mutable internal state from immutable snapshots.
- [ ] Read a `TaskEvent` and `TaskResultSnapshot`.
