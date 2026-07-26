# Part 8: Type Hints, `mypy`, and Production-Grade Error Boundaries

Automated tests answer this question:

> Does the program behave correctly for the scenarios we tested?

Static type checking answers a different question:

> Are we using values in ways that conflict with the interfaces we declared?

For example, a test may not cover every possible call to a method. But a type checker can spot this mistake before the program runs:

```python
library.search_title(123)
```

The method expects a string, not an integer.

Python remains dynamically typed at runtime: type hints do not automatically prevent every invalid value from being passed. But tools such as **mypy** inspect annotations and identify likely mistakes early.

In this part, we will:

- Improve a decorator so it is type-safe for instance methods.
- Remove a dynamic method replacement that static analyzers cannot safely reason about.
- Add explicit custom exceptions for catalog lookup and callback delivery.
- Add `py.typed`, declaring that the package ships type information.
- Run `mypy` and fix type-checking issues systematically.

---

## What You Will Build

The project gains a stronger production boundary:

```text
src/
└── library/
    ├── __init__.py
    ├── decorators.py       # Type-safe method-call logging decorator
    ├── exceptions.py       # Clear domain-specific exceptions
    ├── catalog.py          # Explicit typed error boundaries
    └── py.typed            # PEP 561 marker for packaged type hints
```

The package will expose errors such as:

```python
from library import ItemNotFoundError

try:
    library.find_item("MISSING-001")
except ItemNotFoundError as error:
    print(error)
```

This is clearer than forcing users to catch a broad built-in `KeyError`.

---

# Step 1: Define Domain-Specific Exceptions

## The Target

We are creating:

```text
src/library/exceptions.py
```

This module will contain exceptions that describe failures in the language of our application.

## The Concept

Built-in exceptions are useful, but they can be too broad at package boundaries.

For example:

```python
raise KeyError("No item exists.")
```

A caller can catch `KeyError`, but `KeyError` may also come from unrelated dictionary code.

A custom exception is like a clearly labeled alarm panel:

- `ItemNotFoundError` means a requested library catalog item was not found.
- `EventHandlerError` means an optional event observer failed.

This lets a caller choose exactly what to handle.

We will create a small exception hierarchy:

```text
LibraryError
├── ItemNotFoundError
└── EventHandlerError
```

All package-specific exceptions inherit from `LibraryError`, so callers may catch either one precise error or all library-domain errors.

## The Implementation

### `src/library/exceptions.py`

```python
"""Domain-specific exceptions for the library package."""

from __future__ import annotations


class LibraryError(Exception):
    """Base class for errors raised by the library package."""


class ItemNotFoundError(LibraryError):
    """Raised when a requested catalog identifier does not exist."""

    def __init__(self, identifier: str, library_name: str) -> None:
        """Create an error describing a missing catalog item."""
        self.identifier = identifier
        self.library_name = library_name

        super().__init__(
            f'No item with identifier "{identifier}" exists in {library_name}.'
        )


class EventHandlerError(LibraryError):
    """Raised when code explicitly chooses to re-raise callback failures.

    The current Library implementation records optional callback failures rather
    than raising them. This exception exists for integrations that need a
    typed error representing failed event delivery.
    """

    def __init__(self, handler_name: str, event_type: str) -> None:
        """Create an error describing a failed event-handler invocation."""
        self.handler_name = handler_name
        self.event_type = event_type

        super().__init__(
            f'Event handler "{handler_name}" failed while processing '
            f'event "{event_type}".'
        )
```

## The Verification

Run:

```bash
python -c "from library.exceptions import ItemNotFoundError; error = ItemNotFoundError('MISSING-001', 'City Library'); print(error)"
```

Expected output:

```text
No item with identifier "MISSING-001" exists in City Library.
```

---

# Step 2: Make Method Logging Type-Safe

## The Target

We are updating:

```text
src/library/decorators.py
```

We will add `log_method_calls`, a decorator intended for instance methods.

## The Concept

In Part 6, `Library.__init__` dynamically replaced `check_out_item` with a decorated version.

That works at runtime, but static analysis cannot easily prove that replacing a method on one object instance preserves its original interface.

A better design applies the decorator directly where the method is declared:

```python
@log_method_calls
def check_out_item(self, identifier: str) -> LendingItem:
    ...
```

The decorator needs a way to find each instance’s own `InMemoryEventLog`.

We will define a small `Protocol`.

A **protocol** is a type contract based on available behavior rather than inheritance. It is similar to saying:

> Any object is acceptable if it provides this required method.

Our protocol requires:

```python
def _get_function_call_log(self) -> InMemoryEventLog:
    ...
```

The `Library` class will implement that method.

## The Implementation

Replace the entire file.

### `src/library/decorators.py`

```python
"""Reusable decorators for logging, timing, validation, and retries."""

from __future__ import annotations

from collections import deque
from collections.abc import Callable
from dataclasses import dataclass
from datetime import UTC, datetime
from functools import wraps
from inspect import signature
from time import monotonic, sleep
from typing import ParamSpec, Protocol, TypeVar

Parameters = ParamSpec("Parameters")
MethodParameters = ParamSpec("MethodParameters")
ReturnValue = TypeVar("ReturnValue")


@dataclass(frozen=True, slots=True)
class FunctionCallRecord:
    """Describe one completed or failed decorated function call."""

    function_name: str
    occurred_at: datetime
    succeeded: bool
    duration_seconds: float
    error_type: str | None = None
    error_message: str | None = None


class InMemoryEventLog:
    """Store a bounded, immutable-view history of function call records."""

    def __init__(self, maximum_records: int = 100) -> None:
        """Create an empty bounded log.

        Raises:
            ValueError: If maximum_records is less than one.
        """
        if maximum_records < 1:
            raise ValueError("Maximum record count must be at least 1.")

        self._records: deque[FunctionCallRecord] = deque(maxlen=maximum_records)

    def record(self, call_record: FunctionCallRecord) -> None:
        """Add one call record to the bounded history."""
        self._records.append(call_record)

    def records(self) -> tuple[FunctionCallRecord, ...]:
        """Return an immutable snapshot of all retained call records."""
        return tuple(self._records)


class HasFunctionCallLog(Protocol):
    """Describe an object that provides a per-instance function-call log."""

    def _get_function_call_log(self) -> InMemoryEventLog:
        """Return the instance-owned destination for call records."""


def _create_success_record(
    function_name: str,
    started_at: float,
) -> FunctionCallRecord:
    """Build a call record for a successful invocation."""
    return FunctionCallRecord(
        function_name=function_name,
        occurred_at=datetime.now(UTC),
        succeeded=True,
        duration_seconds=monotonic() - started_at,
    )


def _create_failure_record(
    function_name: str,
    started_at: float,
    error: Exception,
) -> FunctionCallRecord:
    """Build a call record for a failed invocation."""
    return FunctionCallRecord(
        function_name=function_name,
        occurred_at=datetime.now(UTC),
        succeeded=False,
        duration_seconds=monotonic() - started_at,
        error_type=type(error).__name__,
        error_message=str(error),
    )


def log_calls(
    event_log: InMemoryEventLog,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that records successful and failed function calls."""

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with call-record creation."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call function, record its outcome, and preserve its exceptions."""
            started_at = monotonic()

            try:
                result = function(*args, **kwargs)
            except Exception as error:
                event_log.record(
                    _create_failure_record(
                        function_name=function.__qualname__,
                        started_at=started_at,
                        error=error,
                    )
                )
                raise

            event_log.record(
                _create_success_record(
                    function_name=function.__qualname__,
                    started_at=started_at,
                )
            )

            return result

        return wrapper

    return decorator


def log_method_calls(
    function: Callable[MethodParameters, ReturnValue],
) -> Callable[MethodParameters, ReturnValue]:
    """Decorate an instance method that receives an object with a call log.

    The method's first positional argument must implement
    `_get_function_call_log()`. `Library` satisfies that protocol.
    """

    @wraps(function)
    def wrapper(
        *args: MethodParameters.args,
        **kwargs: MethodParameters.kwargs,
    ) -> ReturnValue:
        """Call a method and store its outcome in its instance-owned log."""
        if not args:
            raise RuntimeError(
                f'Decorated method "{function.__qualname__}" received no instance.'
            )

        instance = args[0]

        if not isinstance(instance, HasFunctionCallLog):
            raise TypeError(
                f'Decorated method "{function.__qualname__}" must receive an '
                "instance implementing HasFunctionCallLog."
            )

        started_at = monotonic()

        try:
            result = function(*args, **kwargs)
        except Exception as error:
            instance._get_function_call_log().record(
                _create_failure_record(
                    function_name=function.__qualname__,
                    started_at=started_at,
                    error=error,
                )
            )
            raise

        instance._get_function_call_log().record(
            _create_success_record(
                function_name=function.__qualname__,
                started_at=started_at,
            )
        )

        return result

    return wrapper


def measure_duration(
    reporter: Callable[[str], None],
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that reports a function's elapsed execution time."""

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with duration measurement."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call function and report elapsed time even when it fails."""
            started_at = monotonic()

            try:
                return function(*args, **kwargs)
            finally:
                elapsed_seconds = monotonic() - started_at
                reporter(
                    f"{function.__qualname__} completed in "
                    f"{elapsed_seconds:.6f} seconds."
                )

        return wrapper

    return decorator


def require_non_blank_string(
    parameter_name: str,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that validates one named string argument."""
    cleaned_parameter_name = parameter_name.strip()

    if not cleaned_parameter_name:
        raise ValueError("Parameter name cannot be blank.")

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with named-argument validation."""
        function_signature = signature(function)

        if cleaned_parameter_name not in function_signature.parameters:
            raise ValueError(
                f'Function "{function.__qualname__}" has no parameter named '
                f'"{cleaned_parameter_name}".'
            )

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Bind call arguments and validate the configured parameter."""
            bound_arguments = function_signature.bind(*args, **kwargs)
            bound_arguments.apply_defaults()

            value = bound_arguments.arguments[cleaned_parameter_name]

            if not isinstance(value, str):
                raise TypeError(
                    f'Parameter "{cleaned_parameter_name}" must be a string.'
                )

            if not value.strip():
                raise ValueError(
                    f'Parameter "{cleaned_parameter_name}" cannot be blank.'
                )

            return function(*args, **kwargs)

        return wrapper

    return decorator


def retry(
    *,
    attempts: int,
    retry_on: tuple[type[Exception], ...],
    delay_seconds: float = 0.0,
    reporter: Callable[[str], None] | None = None,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that retries selected temporary failures."""
    if attempts < 1:
        raise ValueError("Retry attempts must be at least 1.")

    if not retry_on:
        raise TypeError("retry_on must contain at least one exception type.")

    if delay_seconds < 0:
        raise ValueError("Retry delay cannot be negative.")

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with selected-exception retry behavior."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call function until success or retry exhaustion."""
            for attempt_number in range(1, attempts + 1):
                try:
                    return function(*args, **kwargs)
                except retry_on as error:
                    if attempt_number == attempts:
                        raise

                    if reporter is not None:
                        reporter(
                            f"{function.__qualname__} failed on attempt "
                            f"{attempt_number}/{attempts} with "
                            f"{type(error).__name__}: {error}. Retrying."
                        )

                    if delay_seconds > 0:
                        sleep(delay_seconds)

            raise RuntimeError("Retry loop ended unexpectedly.")

        return wrapper

    return decorator
```

## The Verification

Run:

```bash
python -c "from library.decorators import HasFunctionCallLog, log_method_calls; print('Method decorator imports succeeded.')"
```

Expected output:

```text
Method decorator imports succeeded.
```

---

# Step 3: Update `Library` with Typed Exceptions and Static Decoration

## The Target

We are replacing:

```text
src/library/catalog.py
```

This version will:

- Use `ItemNotFoundError`.
- Use `@log_method_calls` directly on `check_out_item`.
- Keep one private log per `Library` instance.
- Remove runtime replacement of the `check_out_item` method.

## The Concept

The public method should be visible where it is defined.

This is clearer:

```python
@log_method_calls
def check_out_item(self, identifier: str) -> LendingItem:
    ...
```

than silently replacing it later in `__init__`.

We also convert `KeyError` into `ItemNotFoundError` at the public catalog boundary.

Internally, the dictionary naturally raises `KeyError`. That is fine. But callers should receive an exception that speaks the language of the library package.

This is an **error boundary**:

```text
Internal dictionary lookup
        ↓ KeyError
Library public API boundary
        ↓ ItemNotFoundError
Package caller
```

## The Implementation

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections import deque
from collections.abc import Callable, Iterator
from datetime import UTC, datetime
from itertools import islice

from library.decorators import (
    FunctionCallRecord,
    InMemoryEventLog,
    log_method_calls,
)
from library.events import (
    EventDispatchFailure,
    EventHandler,
    LibraryEvent,
    LibraryEventType,
)
from library.exceptions import ItemNotFoundError
from library.lending_item import LendingItem
from library.search import (
    CatalogPageIterator,
    iter_available_identifiers,
    iter_available_items,
    iter_items_excluding,
    iter_items_matching_title,
)


class Library:
    """Manage a collection of lending items indexed by identifier."""

    def __init__(self, name: str, activity_history_limit: int = 100) -> None:
        """Create an empty library catalog.

        Raises:
            ValueError: If name is blank or activity_history_limit is invalid.
        """
        cleaned_name = name.strip()

        if not cleaned_name:
            raise ValueError("Library name cannot be blank.")

        if activity_history_limit < 1:
            raise ValueError("Activity history limit must be at least 1.")

        self.name = cleaned_name
        self._items_by_identifier: dict[str, LendingItem] = {}
        self._recent_activity: deque[str] = deque(maxlen=activity_history_limit)
        self._event_handlers: list[EventHandler] = []
        self._event_dispatch_failures: deque[EventDispatchFailure] = deque(
            maxlen=activity_history_limit
        )
        self._function_call_log = InMemoryEventLog(
            maximum_records=activity_history_limit
        )

    def __repr__(self) -> str:
        """Return a detailed representation intended for developers."""
        return f"Library(name={self.name!r}, item_count={len(self)!r})"

    def __str__(self) -> str:
        """Return a concise representation intended for library users."""
        return self.name

    def __len__(self) -> int:
        """Return the number of items stored in the catalog."""
        return len(self._items_by_identifier)

    def __iter__(self) -> Iterator[LendingItem]:
        """Iterate over catalog items in the order they were added."""
        return iter(self._items_by_identifier.values())

    def __contains__(self, identifier: object) -> bool:
        """Return whether an identifier exists in this catalog."""
        return isinstance(identifier, str) and identifier in self._items_by_identifier

    def _get_function_call_log(self) -> InMemoryEventLog:
        """Return the instance-owned log used by log_method_calls."""
        return self._function_call_log

    def _record_activity(self, message: str) -> None:
        """Record one timestamped event in bounded activity history."""
        timestamp = datetime.now(UTC).isoformat(timespec="seconds")
        self._recent_activity.append(f"{timestamp} | {message}")

    def _emit_event(self, event_type: LibraryEventType, item: LendingItem) -> None:
        """Notify optional observers after a completed catalog action."""
        event = LibraryEvent(
            event_type=event_type,
            item_identifier=item.identifier,
            item_title=item.title,
            occurred_at=datetime.now(UTC),
        )

        for handler in tuple(self._event_handlers):
            try:
                handler(event)
            except Exception as error:
                handler_name = getattr(handler, "__name__", type(handler).__name__)

                self._event_dispatch_failures.append(
                    EventDispatchFailure(
                        handler_name=handler_name,
                        event=event,
                        error=error,
                    )
                )
                self._record_activity(
                    f'Event handler "{handler_name}" failed while processing '
                    f'"{event.event_type}".'
                )

    def subscribe(self, handler: EventHandler) -> None:
        """Register a callback unless it is already registered."""
        if not callable(handler):
            raise TypeError("Event handler must be callable.")

        if handler not in self._event_handlers:
            self._event_handlers.append(handler)

    def unsubscribe(self, handler: EventHandler) -> bool:
        """Remove a callback and report whether it was registered."""
        try:
            self._event_handlers.remove(handler)
        except ValueError:
            return False

        return True

    def event_dispatch_failures(self) -> tuple[EventDispatchFailure, ...]:
        """Return an immutable snapshot of optional callback failures."""
        return tuple(self._event_dispatch_failures)

    def function_call_records(self) -> tuple[FunctionCallRecord, ...]:
        """Return an immutable snapshot of checkout method call records."""
        return self._function_call_log.records()

    def add_item(self, item: LendingItem) -> None:
        """Add a lending item to the catalog."""
        if not isinstance(item, LendingItem):
            raise TypeError("Library items must inherit from LendingItem.")

        if item.identifier in self._items_by_identifier:
            raise ValueError(
                f'An item with identifier "{item.identifier}" already exists '
                f"in {self.name}."
            )

        self._items_by_identifier[item.identifier] = item
        self._record_activity(f'Added item "{item.identifier}".')
        self._emit_event("item_added", item)

    def find_item(self, identifier: str) -> LendingItem:
        """Return the item identified by identifier.

        Raises:
            ItemNotFoundError: If no matching item exists.
        """
        cleaned_identifier = identifier.strip()

        try:
            return self._items_by_identifier[cleaned_identifier]
        except KeyError as error:
            raise ItemNotFoundError(
                identifier=cleaned_identifier,
                library_name=self.name,
            ) from error

    def available_items(self) -> list[LendingItem]:
        """Return all items that can currently be checked out."""
        return list(self.iter_available_items())

    def iter_available_items(self) -> Iterator[LendingItem]:
        """Yield each item that can currently be checked out."""
        return iter_available_items(self)

    def iter_available_identifiers(self) -> Iterator[str]:
        """Yield identifiers for items that can currently be checked out."""
        return iter_available_identifiers(self)

    def search_title(self, query: str) -> Iterator[LendingItem]:
        """Yield items with titles containing query, case-insensitively."""
        return iter_items_matching_title(self, query)

    def first_items(self, limit: int) -> Iterator[LendingItem]:
        """Yield no more than limit catalog items."""
        if limit < 0:
            raise ValueError("Limit cannot be negative.")

        return islice(self, limit)

    def iter_items_excluding(
        self,
        predicate: Callable[[LendingItem], bool],
    ) -> Iterator[LendingItem]:
        """Yield catalog items that do not match predicate."""
        return iter_items_excluding(self, predicate)

    def iter_pages(self, page_size: int) -> CatalogPageIterator:
        """Return an iterator that yields catalog items in fixed-size pages."""
        return CatalogPageIterator(items=tuple(self), page_size=page_size)

    @log_method_calls
    def check_out_item(self, identifier: str) -> LendingItem:
        """Check out an item and return its updated object."""
        item = self.find_item(identifier)
        item.check_out()
        self._record_activity(f'Checked out item "{item.identifier}".')
        self._emit_event("item_checked_out", item)

        return item

    def return_item(self, identifier: str) -> LendingItem:
        """Return an item and return its updated object."""
        item = self.find_item(identifier)
        item.return_to_library()
        self._record_activity(f'Returned item "{item.identifier}".')
        self._emit_event("item_returned", item)

        return item

    def recent_activity(self) -> tuple[str, ...]:
        """Return an immutable snapshot of recent catalog activity."""
        return tuple(self._recent_activity)
```

Update package exports.

### `src/library/__init__.py`

```python
"""A small library domain package used in the OOP tutorial modules."""

from library.book import Book
from library.catalog import Library
from library.decorators import (
    FunctionCallRecord,
    HasFunctionCallLog,
    InMemoryEventLog,
)
from library.digital_book import DigitalBook
from library.events import (
    EventDispatchFailure,
    EventHandler,
    LibraryEvent,
    LibraryEventType,
)
from library.exceptions import EventHandlerError, ItemNotFoundError, LibraryError
from library.lending_item import LendingItem
from library.reports import CatalogReports
from library.search import CatalogPageIterator
from library.snapshots import CatalogSnapshotWriter

__all__ = [
    "Book",
    "CatalogPageIterator",
    "CatalogReports",
    "CatalogSnapshotWriter",
    "DigitalBook",
    "EventDispatchFailure",
    "EventHandler",
    "EventHandlerError",
    "FunctionCallRecord",
    "HasFunctionCallLog",
    "InMemoryEventLog",
    "ItemNotFoundError",
    "LendingItem",
    "Library",
    "LibraryError",
    "LibraryEvent",
    "LibraryEventType",
]
```

## The Verification

Run:

```bash
python -c "from library import Library, ItemNotFoundError; library = Library('Type Demo'); 
try:
    library.find_item('MISSING-001')
except ItemNotFoundError as error:
    print(type(error).__name__)
    print(error)"
```

Expected output:

```text
ItemNotFoundError
No item with identifier "MISSING-001" exists in Type Demo.
```

Then verify existing tests still pass:

```bash
python -m pytest
```

Expected result:

```text
... passed
```

---

# Step 4: Add Type-Checking Tests and Run `mypy`

## The Target

We are updating tests that expect a missing catalog entry to raise `KeyError`, then running static type checking.

## The Concept

Tests and type hints are complementary:

| Tool | Best at catching |
|---|---|
| `pytest` | Incorrect runtime behavior |
| `mypy` | Incorrect usage of declared interfaces |

When an exception type changes, tests must document the new public contract.

## The Implementation

Create a new test file.

### `tests/test_exceptions.py`

```python
"""Tests for public library exception boundaries."""

from __future__ import annotations

import pytest

from library import ItemNotFoundError, Library


def test_find_item_raises_domain_specific_error_for_missing_identifier() -> None:
    """Missing catalog entries should raise ItemNotFoundError, not KeyError."""
    library = Library(name="Exception Test Library")

    with pytest.raises(ItemNotFoundError) as captured_error:
        library.find_item("MISSING-001")

    assert captured_error.value.identifier == "MISSING-001"
    assert captured_error.value.library_name == "Exception Test Library"
```

Now run the test suite:

```bash
python -m pytest
```

Then run `mypy`:

```bash
python -m mypy src
```

## The Verification

Expected `pytest` result:

```text
... passed
```

Expected `mypy` result:

```text
Success: no issues found in ... source files
```

If your installed mypy version reports an issue around the generic `log_method_calls` decorator, use the focused package command below to identify the exact file and line:

```bash
python -m mypy src/library/decorators.py src/library/catalog.py --show-error-codes
```

The important workflow is:

1. Read the reported file and line.
2. Understand the mismatch.
3. Improve the annotation or implementation.
4. Run `mypy` again.
5. Do not hide real issues with broad `# type: ignore` comments.

---

# Step 5: Mark the Package as Typed

## The Target

We are creating:

```text
src/library/py.typed
```

## The Concept

A `py.typed` file is a marker defined by [PEP 561](https://peps.python.org/pep-0561/).

It tells type checkers:

> This installed package includes type information that consumers can use.

The file is intentionally empty.

Think of it as a label on the package box:

```text
Type hints included.
```

Without the marker, a type checker may treat an installed third-party package as untyped, even when its source files contain annotations.

## The Implementation

Create an empty file.

### `src/library/py.typed`

```text

```

The file has no content.

To ensure package data includes it in a built distribution, add the following section to `pyproject.toml`.

### `pyproject.toml` (append this section)

```toml
[tool.setuptools.package-data]
library = ["py.typed"]
```

The complete `pyproject.toml` should now end with:

```toml
[tool.mypy]
python_version = "3.11"
files = ["src"]
warn_unused_configs = true
warn_unused_ignores = true
check_untyped_defs = true
disallow_any_generics = true
no_implicit_optional = true

[tool.setuptools.package-data]
library = ["py.typed"]
```

Reinstall the editable package:

```bash
python -m pip install --editable ".[dev]"
```

## The Verification

Confirm the marker exists:

### macOS or Linux

```bash
ls -l src/library/py.typed
```

### Windows PowerShell

```powershell
Get-Item src\library\py.typed
```

Then run:

```bash
python -m mypy src
python -m pytest
```

Both commands should complete successfully.

---

# Part 8 Reference: Type Hints and Error Boundaries

## Type Hints Are Contracts

A type hint communicates what a function expects and returns:

```python
def find_item(self, identifier: str) -> LendingItem:
    ...
```

This says:

- Callers should provide `identifier` as a string.
- On success, the method returns a `LendingItem`.

It does not mean the method can never raise an exception. The docstring documents that behavior:

```python
Raises:
    ItemNotFoundError: If no matching item exists.
```

A complete interface includes:

- Parameter types
- Return type
- Mutation behavior
- Exceptions
- Side effects

---

## `Optional[T]` and `T | None`

These are equivalent in modern Python:

```python
from typing import Optional

value: Optional[str]
```

```python
value: str | None
```

This series uses the newer union syntax:

```python
error_message: str | None
```

It means the value may be either a string or `None`.

Never write this if `None` is possible:

```python
def find_name() -> str:
    return None
```

Instead:

```python
def find_name() -> str | None:
    return None
```

Or raise a domain-specific exception if absence is exceptional.

---

## Prefer Precise Collection Types

Use:

```python
list[str]
dict[str, LendingItem]
tuple[FunctionCallRecord, ...]
```

rather than broad, vague types such as:

```python
list
dict
```

Precise types explain what the collection contains and help `mypy` catch misuse.

---

## `Protocol` and Structural Typing

Traditional inheritance says:

> You are this type because you inherit from this base class.

A protocol says:

> You are accepted if you provide the required behavior.

Our decorator protocol requires:

```python
class HasFunctionCallLog(Protocol):
    def _get_function_call_log(self) -> InMemoryEventLog:
        ...
```

`Library` does not need to inherit from `HasFunctionCallLog`. It simply provides the method.

This is called **structural typing** or sometimes “duck typing with static verification.”

---

## Exception Chaining

The catalog converts an internal `KeyError` to a public `ItemNotFoundError`:

```python
try:
    return self._items_by_identifier[cleaned_identifier]
except KeyError as error:
    raise ItemNotFoundError(
        identifier=cleaned_identifier,
        library_name=self.name,
    ) from error
```

The `from error` portion preserves the original cause.

This is useful while debugging because traceback output shows:

```text
KeyError
    ↓
ItemNotFoundError
```

The package caller receives a clear domain error, while developers retain the internal diagnostic trail.

---

## Avoid Excessive `Any`

`Any` disables much of static type checking.

For example:

```python
value: Any = "hello"
number: int = value
```

`mypy` may allow this even if `value` later becomes an incompatible object.

Use `Any` only at unavoidable boundaries, such as:

- Untyped third-party library APIs
- Arbitrary JSON before validation
- Highly dynamic plugin systems

Then convert unknown data into validated, precise types as early as possible.

---

## Type Checking Is Not Runtime Validation

This code may pass `mypy`:

```python
library.search_title("python")
```

But external input is still untrusted:

```python
query = request.query_params["q"]
```

At runtime, that value may be blank, malformed, or absent.

Use both:

- Type hints for developer-facing contracts.
- Runtime validation for data entering from files, users, networks, environment variables, and external services.
