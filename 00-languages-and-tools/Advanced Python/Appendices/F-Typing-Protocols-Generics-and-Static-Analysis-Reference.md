# Appendix F: Typing, Protocols, Generics, and Static Analysis Reference

Python is dynamically typed: values carry types at runtime, and Python usually checks whether an operation is valid only when code executes.

Type hints add a second layer of communication:

```python
def add(left: int, right: int) -> int:
    return left + right
```

They help:

- readers understand APIs;
- IDEs offer accurate completion;
- refactoring tools detect incompatible changes;
- static type checkers find bugs before tests or production;
- framework extension points remain understandable.

Type hints do not replace runtime validation.

For example:

```python
def add(left: int, right: int) -> int:
    return left + right


add("20", "22")
```

Python can still call this function. A static type checker may report the error before execution, but runtime validation is still required at untrusted boundaries such as:

- environment variables;
- JSON messages;
- HTTP requests;
- database records;
- plugin loading;
- task payload deserialization.

---

# 1. Core Type-Hint Syntax

## Simple Values

```python
name: str = "Ada"
attempt: int = 1
timeout_seconds: float = 5.0
is_running: bool = True
payload: bytes = b"data"
```

## Optional Values

Use `| None` when a value may be absent.

```python
result: str | None = None
source_line: int | None = None
```

Avoid older syntax in new Python 3.12+ code unless compatibility requires it:

```python
from typing import Optional

result: Optional[str] = None
```

Modern equivalent:

```python
result: str | None = None
```

## Typed Containers

```python
task_names: list[str] = [
    "emails.send_welcome_email",
    "analytics.count_primes",
]

task_results: dict[str, int] = {
    "task-001": 42,
}

coordinates: tuple[float, float] = (51.5074, -0.1278)

allowed_states: set[str] = {
    "queued",
    "running",
    "succeeded",
}
```

---

# 2. Prefer Precise Types Over `Any`

`Any` means:

> “Do not type-check this value.”

Example:

```python
from typing import Any


def process(value: Any) -> Any:
    return value.not_a_real_method()
```

A static type checker may allow this because `Any` disables useful checking.

Prefer precise types:

```python
def normalize_task_name(task_name: str) -> str:
    return task_name.strip().lower()
```

Use `Any` only at truly dynamic boundaries.

Examples where `Any` can be reasonable:

```python
from typing import Any


def deserialize_untrusted_payload(raw_payload: dict[str, Any]) -> dict[str, Any]:
    ...
```

Even there, validate quickly and convert into stronger internal types.

```python
from typing import Any


def parse_task_id(raw_value: Any) -> str:
    if not isinstance(raw_value, str) or not raw_value:
        raise ValueError("task_id must be a non-empty string.")

    return raw_value
```

The design goal is:

```text
Dynamic data at system boundary
        ↓
Validation
        ↓
Typed internal representation
```

---

# 3. `TypeVar`: Relating Input and Output Types

A `TypeVar` represents a type that changes while preserving a relationship.

```python
from typing import TypeVar

ValueT = TypeVar("ValueT")
```

Example identity function:

```python
from typing import TypeVar

ValueT = TypeVar("ValueT")


def identity(value: ValueT) -> ValueT:
    """Return exactly the same value type that was received."""
    return value
```

A type checker can infer:

```python
number = identity(42)          # int
message = identity("hello")    # str
```

Without `TypeVar`, this loses useful information:

```python
def weak_identity(value: object) -> object:
    return value
```

Now callers receive only `object`, even if they passed an `int`.

---

# 4. Generic Classes

A generic class uses type variables to describe values it contains or returns.

Example typed container:

```python
from typing import Generic, TypeVar

ValueT = TypeVar("ValueT")


class Box(Generic[ValueT]):
    """Store one typed value."""

    def __init__(self, value: ValueT) -> None:
        self._value = value

    def get(self) -> ValueT:
        """Return the same type stored in this box."""
        return self._value
```

Usage:

```python
number_box = Box(42)
message_box = Box("hello")

number = number_box.get()
message = message_box.get()
```

Type checkers infer:

```text
number: int
message: str
```

PulseQueue uses this idea in:

```python
Task[ParametersT, ResultT]
CpuTask[ParametersT, ResultT]
TaskReceipt[ResultT]
TaskResultSnapshot[ResultT]
```

---

# 5. `ParamSpec`: Preserve Callable Parameters

A normal `TypeVar` represents a value type.

A `ParamSpec` represents the full parameter shape of a callable.

```python
from collections.abc import Awaitable, Callable
from typing import ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")
```

This lets decorators preserve function signatures.

```python
from __future__ import annotations

import functools
from collections.abc import Awaitable, Callable
from typing import ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


def log_call(
    function: Callable[ParametersT, Awaitable[ResultT]],
) -> Callable[ParametersT, Awaitable[ResultT]]:
    """Wrap an async callable without losing its argument shape."""

    @functools.wraps(function)
    async def wrapper(
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> ResultT:
        print(f"Calling {function.__qualname__}")
        return await function(*args, **kwargs)

    return wrapper
```

Usage:

```python
@log_call
async def send_email(user_id: int, *, locale: str = "en-US") -> str:
    return f"email for {user_id} in {locale}"
```

A static checker can retain the original callable contract:

```python
await send_email(42, locale="en-GB")
```

and identify invalid calls:

```python
await send_email("not-an-int")
```

---

# 6. Protocols: Structural Subtyping

A protocol describes required behavior without requiring inheritance.

## Basic Protocol

```python
from typing import Protocol


class TaskLogger(Protocol):
    """Any object with this method shape can log task events."""

    def log_task(self, task_name: str, message: str) -> None:
        """Record one task message."""
        ...
```

A class does not need to inherit from `TaskLogger`.

```python
class ConsoleLogger:
    """A structurally compatible logger."""

    def log_task(self, task_name: str, message: str) -> None:
        print(f"{task_name}: {message}")
```

A static type checker accepts this:

```python
def report(logger: TaskLogger) -> None:
    logger.log_task("examples.greet", "started")


report(ConsoleLogger())
```

This is called **structural subtyping**.

---

## PulseQueue Protocols

PulseQueue defines these key extension contracts:

```python
from pulsequeue.typing import (
    EventSink,
    LifecyclePlugin,
    ResultTransformer,
)
```

### `EventSink`

```python
class EventSink(Protocol):
    def emit(self, event: TaskEvent) -> None:
        ...
```

### `LifecyclePlugin`

```python
class LifecyclePlugin(Protocol):
    name: str

    async def start(self) -> None:
        ...

    async def stop(self) -> None:
        ...

    async def on_event(self, event: TaskEvent) -> None:
        ...
```

### `ResultTransformer`

```python
class ResultTransformer(Protocol[InputT, OutputT]):
    def transform(self, value: InputT) -> OutputT:
        ...
```

---

# 7. `@runtime_checkable`

A normal protocol is intended mainly for static checking.

To use it with `isinstance(...)`, add:

```python
from typing import Protocol, runtime_checkable


@runtime_checkable
class EventSink(Protocol):
    def emit(self, event: object) -> None:
        ...
```

Then:

```python
class PrintSink:
    def emit(self, event: object) -> None:
        print(event)


sink = PrintSink()

print(isinstance(sink, EventSink))
```

Expected output:

```text
True
```

## Important Limitation

This runtime check is shallow.

It generally verifies attribute presence, not complete semantic compatibility.

It does not prove:

- method parameter annotations match;
- methods are truly asynchronous;
- values have correct types;
- plugin logic is correct;
- the object is safe for concurrent use.

Use runtime checks for defensive framework validation, but use static analysis and tests for deeper guarantees.

---

# 8. Generic Protocol Example

```python
from typing import Protocol, TypeVar

InputT = TypeVar("InputT")
OutputT = TypeVar("OutputT")


class Transformer(Protocol[InputT, OutputT]):
    """Transform one type of value into another."""

    def transform(self, value: InputT) -> OutputT:
        ...
```

Implementations:

```python
class IntegerToString:
    """Convert an integer to a string."""

    def transform(self, value: int) -> str:
        return str(value)


class EventToName:
    """Extract a task name from an event-like object."""

    def transform(self, value: object) -> str:
        return type(value).__name__
```

A typed helper:

```python
def apply_transformer(
    transformer: Transformer[InputT, OutputT],
    value: InputT,
) -> OutputT:
    """Apply a transformer while preserving input/output relationships."""
    return transformer.transform(value)
```

Usage:

```python
result = apply_transformer(IntegerToString(), 42)

print(result)
```

Expected output:

```text
42
```

The inferred result type is `str`.

---

# 9. `Self` for Fluent APIs and Context Managers

Use `typing.Self` when a method returns the same concrete class as the instance.

```python
from typing import Self


class Connection:
    """A resource that returns itself after opening."""

    async def open(self) -> Self:
        """Open the connection and return this concrete instance."""
        return self
```

This is useful for subclass-aware APIs.

PulseQueue uses `Self` in context-manager methods such as:

```python
async def __aenter__(self) -> Self:
    await self.start()
    return self
```

This tells type checkers that:

```python
async with PulseQueueRuntime(app) as runtime:
    ...
```

binds `runtime` as the concrete runtime class.

---

# 10. Type Aliases

A type alias gives a complex type a meaningful name.

```python
from typing import TypeAlias

TaskArguments: TypeAlias = tuple[object, ...]
TaskKeywordArguments: TypeAlias = dict[str, object]
```

PulseQueue uses:

```python
from typing import TypeAlias

RegisteredTask: TypeAlias = Task[Any, Any] | CpuTask[Any, Any]
```

This is clearer than repeating the union across registry methods.

---

# 11. `Literal` for Fixed Values

Use `Literal` when a value must be one of a small known set.

```python
from typing import Literal

LogFormat = Literal["json", "plain"]


def configure_output(format_name: LogFormat) -> None:
    if format_name == "json":
        print("JSON output configured.")
    else:
        print("Plain output configured.")
```

A static checker can flag:

```python
configure_output("xml")
```

For runtime state machines, an `Enum` is often better because it provides values and behavior.

PulseQueue uses enums such as:

```python
TaskState
WorkerState
TaskEventType
PluginRegistryState
WorkloadKind
```

---

# 12. `TypedDict` for Dictionary-Shaped Data

Use `TypedDict` when a dictionary has known keys but is still naturally represented as a mapping.

```python
from typing import TypedDict


class TaskMessage(TypedDict):
    """Expected shape of a JSON task message."""

    task_id: str
    task_name: str
    args: list[object]
    kwargs: dict[str, object]
    submitted_at: str
```

Example:

```python
message: TaskMessage = {
    "task_id": "task-001",
    "task_name": "emails.send_welcome_email",
    "args": [42],
    "kwargs": {"locale": "en-GB"},
    "submitted_at": "2026-07-24T12:00:00+00:00",
}
```

For stable internal framework data, prefer a dataclass:

```python
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class TaskEnvelope:
    task_id: str
    task_name: str
```

A dataclass provides:

- constructor validation opportunities;
- immutability;
- attribute access;
- clearer refactoring;
- lower overhead with `slots=True`.

Use `TypedDict` mainly at JSON and API boundaries.

---

# 13. `cast(...)` Is Not Runtime Validation

`typing.cast(...)` changes what a type checker believes. It does not convert or validate data.

```python
from typing import cast

value: object = "42"

number = cast(int, value)
```

At runtime:

```python
print(number)
```

still prints:

```text
42
```

and `number` is still actually a string.

Use runtime validation instead:

```python
value: object = "42"

if not isinstance(value, int):
    raise TypeError("Expected an integer.")

number = value
```

Use `cast(...)` only when you know more than the type checker and the runtime invariant is already guaranteed elsewhere.

---

# 14. Narrow Types with `isinstance(...)`

Static checkers understand narrowing.

```python
from typing import Any


def parse_attempt(raw_value: Any) -> int:
    """Validate dynamic input and return a strongly typed integer."""
    if not isinstance(raw_value, int):
        raise TypeError("attempt must be an integer.")

    if raw_value < 0:
        raise ValueError("attempt must be zero or greater.")

    return raw_value
```

After:

```python
if not isinstance(raw_value, int):
    raise TypeError(...)
```

the type checker understands that `raw_value` is an `int`.

This pattern is fundamental at deserialization boundaries.

---

# 15. Type Guards for Complex Validation

Use `TypeGuard` when a validation function narrows a complex type.

```python
from collections.abc import Mapping
from typing import Any, TypeGuard


def is_string_mapping(value: Any) -> TypeGuard[Mapping[str, str]]:
    """Return whether value is a mapping with string keys and values."""
    if not isinstance(value, Mapping):
        return False

    return all(
        isinstance(key, str) and isinstance(item, str)
        for key, item in value.items()
    )
```

Usage:

```python
raw_value: Any = {
    "queue": "emails",
    "owner": "platform-team",
}

if is_string_mapping(raw_value):
    print(raw_value["queue"])
```

This is useful for parsing JSON configuration and task payload metadata.

---

# 16. Recommended Static Type Checker Setup

Two common choices are:

- **mypy**
- **pyright**

You can use either. Pyright is often fast and has strong editor integration. Mypy is mature and widely used.

Install mypy:

```bash
python -m pip install mypy
```

Run it:

```bash
python -m mypy src tests
```

Add basic configuration to `pyproject.toml`.

## `pyproject.toml` — append

```toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_unused_configs = true
warn_return_any = true
warn_unreachable = true
disallow_any_generics = true
disallow_subclassing_any = true
no_implicit_reexport = true
```

For pyright, install:

```bash
python -m pip install pyright
```

Add configuration.

## `pyproject.toml` — alternative Pyright section

```toml
[tool.pyright]
pythonVersion = "3.12"
typeCheckingMode = "strict"
include = ["src", "tests"]
exclude = [
    ".venv",
    "build",
    "dist",
]
```

Run:

```bash
python -m pyright
```

Choose one primary checker initially. Running both is possible, but their strictness rules and inference can differ.

---

# 17. Typing Rules for PulseQueue Plugins

A good plugin should annotate all lifecycle methods.

```python
from __future__ import annotations

from pulsequeue.events import TaskEvent


class MetricsPlugin:
    """Record basic task lifecycle counts."""

    name = "metrics"

    def __init__(self) -> None:
        self._counts: dict[str, int] = {}

    async def start(self) -> None:
        """Initialize plugin resources."""
        return None

    async def stop(self) -> None:
        """Release plugin resources."""
        return None

    async def on_event(self, event: TaskEvent) -> None:
        """Count each event by stable event type."""
        event_name = event.event_type.value
        self._counts[event_name] = self._counts.get(event_name, 0) + 1
```

Register it:

```python
from pulsequeue import PluginRegistry

plugins = PluginRegistry()
plugins.register(MetricsPlugin())
```

The plugin does not need to inherit from `LifecyclePlugin`.

It satisfies the protocol structurally.

---

# 18. Typing Rules for Result Backends

A custom result backend should implement the `ResultBackend` protocol.

```python
from __future__ import annotations

from typing import Any

from pulsequeue.result import (
    InMemoryResultStore,
    TaskResultSnapshot,
)


class AuditingResultBackend:
    """Wrap another backend and record transition names."""

    def __init__(self) -> None:
        self._backend = InMemoryResultStore()
        self.transitions: list[str] = []

    def create(
        self,
        *,
        task_id: str,
        task_name: str,
        max_attempts: int,
    ) -> None:
        self.transitions.append("created")
        self._backend.create(
            task_id=task_id,
            task_name=task_name,
            max_attempts=max_attempts,
        )

    def mark_running(self, task_id: str) -> None:
        self.transitions.append("running")
        self._backend.mark_running(task_id)

    def mark_retrying(
        self,
        task_id: str,
        exception: BaseException,
        *,
        delay_seconds: float,
    ) -> None:
        self.transitions.append("retrying")
        self._backend.mark_retrying(
            task_id,
            exception,
            delay_seconds=delay_seconds,
        )

    def mark_succeeded(self, task_id: str, value: Any) -> None:
        self.transitions.append("succeeded")
        self._backend.mark_succeeded(task_id, value)

    def mark_failed(self, task_id: str, exception: BaseException) -> None:
        self.transitions.append("failed")
        self._backend.mark_failed(task_id, exception)

    def mark_cancelled(self, task_id: str) -> None:
        self.transitions.append("cancelled")
        self._backend.mark_cancelled(task_id)

    def snapshot(self, task_id: str) -> TaskResultSnapshot[Any]:
        return self._backend.snapshot(task_id)

    async def wait_for_terminal_state(
        self,
        task_id: str,
        *,
        timeout_seconds: float,
    ) -> TaskResultSnapshot[Any]:
        return await self._backend.wait_for_terminal_state(
            task_id,
            timeout_seconds=timeout_seconds,
        )
```

A static checker can verify compatibility when passing it to:

```python
PulseQueueRuntime(
    app,
    result_backend=AuditingResultBackend(),
)
```

---

# 19. Type-Hint Style Checklist

Use this checklist when writing framework or plugin code.

- [ ] Use `from __future__ import annotations`.
- [ ] Annotate public function parameters and return values.
- [ ] Use `str | None`, not `Optional[str]`, for new Python 3.12+ code.
- [ ] Prefer `list[str]`, `dict[str, int]`, and `tuple[...]`.
- [ ] Use `Protocol` for extension contracts.
- [ ] Use `TypeVar` when input and output types are related.
- [ ] Use `ParamSpec` when wrapping callables.
- [ ] Use `Self` for fluent APIs and context managers.
- [ ] Avoid `Any` except at validated dynamic boundaries.
- [ ] Validate dynamic data before turning it into internal types.
- [ ] Do not use `cast(...)` as a substitute for validation.
- [ ] Run a strict static type checker in CI.
