# Part 6: Decorators for Reusable Logging, Validation, and Retries

In Part 5, we treated functions as values. That makes **decorators** possible.

A decorator is a function that receives another function and returns a new function with extra behavior.

Think of a decorator as a protective sleeve around a document:

- The document still contains the original information.
- The sleeve can add a label, validate access, or record when it was handled.
- The document’s essential purpose does not change.

In Python, decorator syntax:

```python
@decorator_name
def function_name() -> None:
    ...
```

is shorthand for:

```python
def function_name() -> None:
    ...

function_name = decorator_name(function_name)
```

Decorators are useful for behavior that appears repeatedly across many functions:

- Logging
- Timing
- Input validation
- Retrying temporary failures
- Authorization
- Caching
- Tracing

The key design rule is:

> Use decorators for cross-cutting behavior—behavior that applies in multiple places without being the core business purpose of each function.

Checking out a library item is core business behavior. Logging the duration of that checkout is cross-cutting behavior.

---

## What You Will Build

This part adds a decorator module and applies decorators safely to our library project.

```text
pythonic-craftsmanship/
├── src/
│   └── library/
│       ├── __init__.py
│       ├── book.py
│       ├── catalog.py
│       ├── decorators.py
│       ├── digital_book.py
│       ├── events.py
│       ├── lending_item.py
│       ├── reports.py
│       ├── search.py
│       └── snapshots.py
└── examples/
    ├── part_6_decorator_basics.py
    ├── part_6_logging_demo.py
    ├── part_6_retry_demo.py
    └── part_6_validation_demo.py
```

We will build:

- `log_calls`: records successful and failed function calls.
- `measure_duration`: reports elapsed execution time.
- `require_non_blank_string`: validates one named string argument.
- `retry`: retries only specified, temporary exception types.
- A small in-memory event log.
- Decorated catalog search and checkout methods.

---

# Step 1: See What a Decorator Actually Does

## The Target

We are creating:

```text
examples/part_6_decorator_basics.py
```

This example builds a decorator manually before we use production-quality versions.

## The Concept

A decorator normally contains an inner function called a **wrapper**.

```python
def decorator(function):
    def wrapper():
        # Extra behavior before.
        result = function()
        # Extra behavior after.
        return result

    return wrapper
```

The wrapper runs instead of the original function, but it can call the original function inside itself.

For decorators that support arbitrary functions, the wrapper uses:

```python
*args
**kwargs
```

That lets it forward any positional and named arguments to the wrapped function.

We also use:

```python
from functools import wraps
```

`@wraps(function)` preserves important metadata from the original function, including:

- Its name
- Its documentation string
- Its annotations
- Its `__wrapped__` reference for debugging and tooling

Without it, every decorated function misleadingly appears to be named `wrapper`.

## The Implementation

### `examples/part_6_decorator_basics.py`

```python
"""Demonstrate the mechanics of a basic decorator."""

from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def announce_call(
    function: Callable[Parameters, ReturnValue],
) -> Callable[Parameters, ReturnValue]:
    """Return a wrapper that announces calls to function."""

    @wraps(function)
    def wrapper(*args: Parameters.args, **kwargs: Parameters.kwargs) -> ReturnValue:
        """Run the original function with messages before and after it."""
        print(f"Starting {function.__name__}...")
        result = function(*args, **kwargs)
        print(f"Finished {function.__name__}.")
        return result

    return wrapper


@announce_call
def create_greeting(name: str) -> str:
    """Create a greeting for one person."""
    return f"Hello, {name}!"


def main() -> None:
    """Call a decorated function and inspect preserved metadata."""
    greeting = create_greeting("Ada")

    print(greeting)
    print(f"Function name: {create_greeting.__name__}")
    print(f"Function docstring: {create_greeting.__doc__}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_6_decorator_basics.py
```

Expected output:

```text
Starting create_greeting...
Finished create_greeting.
Hello, Ada!
Function name: create_greeting
Function docstring: Create a greeting for one person.
```

The name and docstring remain correct because the decorator used `@wraps`.

---

# Step 2: Build Production-Friendly Decorators

## The Target

We are creating:

```text
src/library/decorators.py
```

This module will contain reusable decorators with type-safe signatures.

## The Concept

Decorators must preserve more than runtime behavior. They should also preserve the type signature understood by editors and static type checkers.

We will use two typing tools:

```python
ParamSpec
TypeVar
```

`ParamSpec` represents an unknown function’s parameter list.

`TypeVar` represents an unknown function’s return type.

Together, they let this decorator say:

> I accept a function with any valid parameter list and any return type, and I return a function with the same parameter list and return type.

That is much safer than annotating everything as `Callable[..., Any]`.

We will also define an `InMemoryEventLog` class. It provides a simple destination for log entries during examples and tests. In a production application, you would usually integrate Python’s `logging` module or an observability platform; we will cover logging APIs in a later reference section.

## The Implementation

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
from typing import Any, ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
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


def log_calls(
    event_log: InMemoryEventLog,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that records successful and failed function calls.

    The decorated function's original exception is always re-raised after the
    failure record is stored. Logging must not hide a real application failure.
    """

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with call-record creation."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call function and record its outcome."""
            started_at = monotonic()

            try:
                result = function(*args, **kwargs)
            except Exception as error:
                event_log.record(
                    FunctionCallRecord(
                        function_name=function.__qualname__,
                        occurred_at=datetime.now(UTC),
                        succeeded=False,
                        duration_seconds=monotonic() - started_at,
                        error_type=type(error).__name__,
                        error_message=str(error),
                    )
                )
                raise

            event_log.record(
                FunctionCallRecord(
                    function_name=function.__qualname__,
                    occurred_at=datetime.now(UTC),
                    succeeded=True,
                    duration_seconds=monotonic() - started_at,
                )
            )

            return result

        return wrapper

    return decorator


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
    """Create a decorator that validates one named string argument.

    The parameter may be supplied by position or keyword. It must exist, be a
    string, and contain non-whitespace text.
    """
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
    """Create a decorator that retries selected temporary failures.

    Args:
        attempts: Total calls allowed, including the first attempt.
        retry_on: Exception types that are safe and meaningful to retry.
        delay_seconds: Delay before each retry.
        reporter: Optional destination for retry messages.

    Raises:
        ValueError: If attempts is less than one or delay is negative.
        TypeError: If retry_on is empty.

    Important:
        Retry only operations that are safe to repeat. Retrying a non-idempotent
        operation, such as an unprotected payment request, can create duplicates.
    """
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
            """Call function until it succeeds or allowed attempts are exhausted."""
            for attempt_number in range(1, attempts + 1):
                try:
                    return function(*args, **kwargs)
                except retry_on as error:
                    is_final_attempt = attempt_number == attempts

                    if is_final_attempt:
                        raise

                    if reporter is not None:
                        reporter(
                            f"{function.__qualname__} failed on attempt "
                            f"{attempt_number}/{attempts} with "
                            f"{type(error).__name__}: {error}. Retrying."
                        )

                    if delay_seconds > 0:
                        sleep(delay_seconds)

            # Python cannot reach this line: every loop branch returns or raises.
            raise RuntimeError("Retry loop ended unexpectedly.")

        return wrapper

    return decorator
```

## The Verification

Run this import check:

```bash
python -c "from library.decorators import InMemoryEventLog, log_calls, measure_duration, require_non_blank_string, retry; print('Decorator imports succeeded.')"
```

Expected output:

```text
Decorator imports succeeded.
```

---

# Step 3: Use a Validation Decorator for Search Input

## The Target

We are updating:

```text
src/library/search.py
```

We will apply `@require_non_blank_string("query")` to the title-search generator.

## The Concept

`iter_items_matching_title()` already validates its `query` parameter manually.

That is correct, but this exact kind of validation can appear in many functions:

- Search by title
- Search by author
- Find by identifier
- Fetch a remote resource by ID

A decorator can enforce this shared boundary rule consistently.

However, decorators are not always the best choice. A decorator hides logic away from the function body, so use it only when the behavior is genuinely reusable and unsurprising.

Here, the function name and decorator make the contract explicit:

```python
@require_non_blank_string("query")
def iter_items_matching_title(...):
```

## The Implementation

Replace `src/library/search.py` with this complete version.

### `src/library/search.py`

```python
"""Lazy catalog searching and pagination helpers."""

from __future__ import annotations

from collections.abc import Callable, Iterable, Iterator, Sequence
from itertools import chain, filterfalse, islice

from library.decorators import require_non_blank_string
from library.lending_item import LendingItem


class CatalogPageIterator(Iterator[tuple[LendingItem, ...]]):
    """Iterate over catalog items in fixed-size immutable pages."""

    def __init__(
        self,
        items: Sequence[LendingItem],
        page_size: int,
    ) -> None:
        """Create an iterator that yields pages from an item sequence.

        Args:
            items: The catalog items to paginate.
            page_size: The maximum number of items in each returned page.

        Raises:
            ValueError: If page_size is less than 1.
        """
        if page_size < 1:
            raise ValueError("Page size must be at least 1.")

        self._items = tuple(items)
        self._page_size = page_size
        self._current_index = 0

    def __iter__(self) -> CatalogPageIterator:
        """Return this iterator object."""
        return self

    def __next__(self) -> tuple[LendingItem, ...]:
        """Return the next page, or stop when every item has been returned."""
        if self._current_index >= len(self._items):
            raise StopIteration

        page_start = self._current_index
        page_end = page_start + self._page_size
        self._current_index = page_end

        return self._items[page_start:page_end]


def iter_available_items(items: Iterable[LendingItem]) -> Iterator[LendingItem]:
    """Yield each item that can currently be checked out."""
    for item in items:
        if not item.is_checked_out:
            yield item


@require_non_blank_string("query")
def iter_items_matching_title(
    items: Iterable[LendingItem],
    query: str,
) -> Iterator[LendingItem]:
    """Yield items whose title contains query, case-insensitively."""
    normalized_query = query.strip().casefold()

    for item in items:
        if normalized_query in item.title.casefold():
            yield item


def iter_available_identifiers(
    items: Iterable[LendingItem],
) -> Iterator[str]:
    """Yield identifiers for items that can currently be checked out."""
    for item in iter_available_items(items):
        yield item.identifier


def take_items(
    items: Iterable[LendingItem],
    limit: int,
) -> Iterator[LendingItem]:
    """Yield no more than limit items from an iterable.

    Raises:
        ValueError: If limit is negative.
    """
    if limit < 0:
        raise ValueError("Limit cannot be negative.")

    return islice(items, limit)


def iter_all_items(
    *catalogs: Iterable[LendingItem],
) -> Iterator[LendingItem]:
    """Yield items from each supplied catalog in argument order."""
    return chain.from_iterable(catalogs)


def iter_items_excluding(
    items: Iterable[LendingItem],
    predicate: Callable[[LendingItem], bool],
) -> Iterator[LendingItem]:
    """Yield items for which predicate returns False."""
    return filterfalse(predicate, items)
```

Create a focused validation example.

### `examples/part_6_validation_demo.py`

```python
"""Demonstrate reusable decorator-based string validation."""

from library import Book, Library


def main() -> None:
    """Search with valid and invalid query values."""
    library = Library(name="Validation Decorator Demo")

    library.add_item(
        Book(
            title="Python Crash Course",
            author="Eric Matthes",
            isbn="BOOK-001",
            shelf_location="P-01",
        )
    )

    print("Valid search:")
    for item in library.search_title("python"):
        print(f"- {item}")

    print("\nBlank search:")
    try:
        list(library.search_title("   "))
    except ValueError as error:
        print(f"Expected error: {error}")

    print("\nNon-string search:")
    try:
        list(library.search_title(123))  # type: ignore[arg-type]
    except TypeError as error:
        print(f"Expected error: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_6_validation_demo.py
```

Expected output:

```text
Valid search:
- Python Crash Course by Eric Matthes

Blank search:
Expected error: Parameter "query" cannot be blank.

Non-string search:
Expected error: Parameter "query" must be a string.
```

---

# Step 4: Add Call Logging to Checkout Operations

## The Target

We are updating:

```text
src/library/catalog.py
```

We will add an `InMemoryEventLog` to each `Library` instance and apply `@log_calls` to the internal checkout implementation.

## The Concept

A decorator is evaluated when Python creates the class or function, but our call log belongs to each individual `Library` instance.

That means this would be incorrect:

```python
class Library:
    _event_log = InMemoryEventLog()

    @log_calls(_event_log)
    def check_out_item(...):
        ...
```

That log would be shared by every `Library` instance. Shared mutable class state is a common source of bugs.

Instead, we will decorate a **bound method dynamically** inside `__init__`.

The design is:

1. Construct each library’s private event log.
2. Keep the real implementation in `_check_out_item`.
3. Replace the public `check_out_item` callable with a decorated version bound to that specific instance.

This gives each library an independent log.

## The Implementation

Replace `src/library/catalog.py` with the following complete file.

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections import deque
from collections.abc import Callable, Iterator
from datetime import UTC, datetime
from itertools import islice

from library.decorators import FunctionCallRecord, InMemoryEventLog, log_calls
from library.events import EventDispatchFailure, EventHandler, LibraryEvent, LibraryEventType
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

        Args:
            name: The public name of the library.
            activity_history_limit: Maximum number of retained activity records,
                callback failures, and function-call records.

        Raises:
            ValueError: If name is blank or the history limit is less than 1.
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

        # _check_out_item is already bound to this particular Library instance.
        # Decorating it here ensures each Library owns an independent call log.
        self.check_out_item = log_calls(self._function_call_log)(
            self._check_out_item
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

    def _record_activity(self, message: str) -> None:
        """Record one timestamped event in the bounded activity history."""
        timestamp = datetime.now(UTC).isoformat(timespec="seconds")
        self._recent_activity.append(f"{timestamp} | {message}")

    def _emit_event(self, event_type: LibraryEventType, item: LendingItem) -> None:
        """Notify subscribed handlers after a completed catalog action."""
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
        """Register an event handler if it is not already registered.

        Raises:
            TypeError: If handler is not callable.
        """
        if not callable(handler):
            raise TypeError("Event handler must be callable.")

        if handler not in self._event_handlers:
            self._event_handlers.append(handler)

    def unsubscribe(self, handler: EventHandler) -> bool:
        """Remove a registered handler."""
        try:
            self._event_handlers.remove(handler)
        except ValueError:
            return False

        return True

    def event_dispatch_failures(self) -> tuple[EventDispatchFailure, ...]:
        """Return an immutable snapshot of optional callback failures."""
        return tuple(self._event_dispatch_failures)

    def function_call_records(self) -> tuple[FunctionCallRecord, ...]:
        """Return an immutable snapshot of decorated checkout call records."""
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
        """Return the catalog item with the given identifier."""
        cleaned_identifier = identifier.strip()

        try:
            return self._items_by_identifier[cleaned_identifier]
        except KeyError as error:
            raise KeyError(
                f'No item with identifier "{cleaned_identifier}" exists in {self.name}.'
            ) from error

    def available_items(self) -> list[LendingItem]:
        """Return all catalog items that can currently be checked out."""
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

    def _check_out_item(self, identifier: str) -> LendingItem:
        """Perform the actual checkout operation for the decorated public API."""
        item = self.find_item(identifier)
        item.check_out()
        self._record_activity(f'Checked out item "{item.identifier}".')
        self._emit_event("item_checked_out", item)

        return item

    def check_out_item(self, identifier: str) -> LendingItem:
        """Check out an item.

        This method is replaced in __init__ with a per-instance, log_calls-
        decorated version of _check_out_item.
        """
        return self._check_out_item(identifier)

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
from library.decorators import FunctionCallRecord, InMemoryEventLog
from library.digital_book import DigitalBook
from library.events import EventDispatchFailure, EventHandler, LibraryEvent, LibraryEventType
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
    "FunctionCallRecord",
    "InMemoryEventLog",
    "LendingItem",
    "Library",
    "LibraryEvent",
    "LibraryEventType",
]
```

Create a demonstration.

### `examples/part_6_logging_demo.py`

```python
"""Demonstrate decorator-based function-call logging."""

from library import Book, Library


def main() -> None:
    """Perform successful and failed checkouts, then inspect call records."""
    library = Library(name="Logging Decorator Demo")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="BOOK-001",
            shelf_location="A-01",
        )
    )

    library.check_out_item("BOOK-001")

    try:
        library.check_out_item("BOOK-001")
    except ValueError as error:
        print(f"Expected checkout error: {error}")

    print("\nCheckout call records:")
    for record in library.function_call_records():
        print(f"- Function: {record.function_name}")
        print(f"  Succeeded: {record.succeeded}")
        print(f"  Duration: {record.duration_seconds:.6f} seconds")

        if not record.succeeded:
            print(f"  Error type: {record.error_type}")
            print(f"  Error message: {record.error_message}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_6_logging_demo.py
```

Expected output resembles:

```text
Expected checkout error: "Clean Code" is already checked out.

Checkout call records:
- Function: Library._check_out_item
  Succeeded: True
  Duration: 0.0000xx seconds
- Function: Library._check_out_item
  Succeeded: False
  Duration: 0.0000xx seconds
  Error type: ValueError
  Error message: "Clean Code" is already checked out.
```

The exact durations vary by computer.

---

# Step 5: Create a Safe Retry Decorator Example

## The Target

We are creating:

```text
examples/part_6_retry_demo.py
```

This example will simulate a temporary service failure and recover through `@retry`.

## The Concept

Retrying is useful only for failures that are likely temporary.

Examples that may be temporary:

- A network connection reset
- A remote server returning a transient overload error
- A short-lived lock conflict

Examples that are usually not fixed by retrying:

- Invalid input
- Authentication failure
- A missing resource
- A syntax error
- A permission denial

The retry decorator requires the caller to explicitly name retryable exception types:

```python
@retry(
    attempts=3,
    retry_on=(TemporaryServiceError,),
)
```

This prevents the dangerous pattern of retrying every exception.

A further concern is **idempotency**.

An operation is idempotent when repeating it produces the same end state as performing it once.

Reading a resource is usually idempotent:

```text
GET /projects/123
```

Creating a payment may not be idempotent unless the server supports idempotency keys:

```text
POST /payments
```

Retry only operations that can safely repeat, or use a server-supported idempotency mechanism.

## The Implementation

### `examples/part_6_retry_demo.py`

```python
"""Demonstrate retry behavior for a deliberately temporary failure."""

from library.decorators import retry


class TemporaryCatalogServiceError(Exception):
    """Represent a temporary service failure that is safe to retry."""


class DemoCatalogService:
    """Simulate a service that fails a configured number of initial requests."""

    def __init__(self, failures_before_success: int) -> None:
        """Create a service with a controlled temporary failure count."""
        if failures_before_success < 0:
            raise ValueError("Failure count cannot be negative.")

        self._failures_remaining = failures_before_success

    @retry(
        attempts=3,
        retry_on=(TemporaryCatalogServiceError,),
        reporter=print,
    )
    def fetch_catalog_status(self) -> str:
        """Return status after temporary failures have been exhausted."""
        if self._failures_remaining > 0:
            self._failures_remaining -= 1
            raise TemporaryCatalogServiceError("Service is warming up.")

        return "Catalog service is healthy."


def main() -> None:
    """Show successful recovery and eventual retry exhaustion."""
    recovers = DemoCatalogService(failures_before_success=2)

    print("Recovery scenario:")
    print(recovers.fetch_catalog_status())

    fails_permanently = DemoCatalogService(failures_before_success=3)

    print("\nExhausted-retry scenario:")
    try:
        fails_permanently.fetch_catalog_status()
    except TemporaryCatalogServiceError as error:
        print(f"Final expected error: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_6_retry_demo.py
```

Expected output:

```text
Recovery scenario:
DemoCatalogService.fetch_catalog_status failed on attempt 1/3 with TemporaryCatalogServiceError: Service is warming up.. Retrying.
DemoCatalogService.fetch_catalog_status failed on attempt 2/3 with TemporaryCatalogServiceError: Service is warming up.. Retrying.
Catalog service is healthy.

Exhausted-retry scenario:
DemoCatalogService.fetch_catalog_status failed on attempt 1/3 with TemporaryCatalogServiceError: Service is warming up.. Retrying.
DemoCatalogService.fetch_catalog_status failed on attempt 2/3 with TemporaryCatalogServiceError: Service is warming up.. Retrying.
Final expected error: Service is warming up.
```

The final failed call does not produce a “Retrying” message because there is no retry remaining.

---

# Step 6: Verify Decorator Configuration Errors

## The Target

We are verifying that decorators fail early when configured incorrectly.

## The Concept

A decorator factory runs when Python defines a function, not when the function is called.

For example:

```python
@require_non_blank_string("missing_parameter")
def example(actual_parameter: str) -> None:
    ...
```

This should fail immediately because the decorator refers to a parameter that does not exist.

Failing early is better than waiting until production traffic reaches the function.

Likewise, retry configuration should reject invalid values such as zero attempts or an empty retryable-exception list.

## The Implementation

Create this verification script.

### `examples/part_6_decorator_configuration_demo.py`

```python
"""Verify that invalid decorator configuration fails early and clearly."""

from library.decorators import require_non_blank_string, retry


def main() -> None:
    """Attempt invalid decorator configurations."""
    try:

        @require_non_blank_string("missing_parameter")
        def valid_function(actual_parameter: str) -> str:
            return actual_parameter

    except ValueError as error:
        print(f"Expected validation-decorator error: {error}")

    try:

        @retry(
            attempts=0,
            retry_on=(RuntimeError,),
        )
        def invalid_retry_count() -> None:
            return None

    except ValueError as error:
        print(f"Expected retry-attempt error: {error}")

    try:

        @retry(
            attempts=2,
            retry_on=(),
        )
        def missing_retry_types() -> None:
            return None

    except TypeError as error:
        print(f"Expected retry-type error: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_6_decorator_configuration_demo.py
```

Expected output:

```text
Expected validation-decorator error: Function "main.<locals>.valid_function" has no parameter named "missing_parameter".
Expected retry-attempt error: Retry attempts must be at least 1.
Expected retry-type error: retry_on must contain at least one exception type.
```

The exact qualified function name can vary slightly by Python version, but it will include `valid_function`.

---

# Part 6 Reference: Decorator Design and API Guide

## Basic Decorator Shape

A decorator receives a function and returns a function:

```python
def decorator(function):
    def wrapper(*args, **kwargs):
        return function(*args, **kwargs)

    return wrapper
```

Applied with:

```python
@decorator
def greet(name):
    return f"Hello, {name}"
```

Equivalent to:

```python
def greet(name):
    return f"Hello, {name}"

greet = decorator(greet)
```

---

## Decorator Factories

A decorator factory receives configuration and returns a decorator.

```python
def repeat(times: int):
    def decorator(function):
        def wrapper(*args, **kwargs):
            result = None

            for _ in range(times):
                result = function(*args, **kwargs)

            return result

        return wrapper

    return decorator
```

Usage:

```python
@repeat(times=3)
def greet() -> None:
    print("Hello")
```

Our `retry`, `log_calls`, `measure_duration`, and `require_non_blank_string` functions are decorator factories.

---

## Why `functools.wraps` Is Required

Always use `@wraps` when writing a normal decorator.

Without it:

```python
@my_decorator
def fetch_project() -> None:
    """Fetch one project."""
```

may appear as:

```python
fetch_project.__name__ == "wrapper"
fetch_project.__doc__ is None
```

With it:

```python
@wraps(function)
def wrapper(...):
    ...
```

the wrapped function retains its useful metadata.

This matters to:

- Debuggers
- Error reports
- API documentation generators
- Test frameworks
- Dependency injection frameworks
- Type-inspection tools

---

## Decorator Order

When multiple decorators appear, Python applies the lowest decorator first.

```python
@outer
@inner
def function():
    ...
```

is equivalent to:

```python
function = outer(inner(function))
```

At call time, the outer wrapper runs first.

This matters for logging, retries, authorization, caching, and validation.

For example:

```python
@log_calls(log)
@retry(attempts=3, retry_on=(TemporaryError,))
def fetch_data() -> str:
    ...
```

means the logger wraps the retry behavior. It sees one overall success or failure after all retry attempts.

But:

```python
@retry(attempts=3, retry_on=(TemporaryError,))
@log_calls(log)
def fetch_data() -> str:
    ...
```

means logging occurs inside the retry behavior. It records each individual attempt.

Neither ordering is universally correct. Choose based on what your operational data should mean.

---

## `finally` for Timing and Cleanup

The timing decorator uses:

```python
try:
    return function(*args, **kwargs)
finally:
    reporter(...)
```

The `finally` block runs whether the function:

- Returns normally
- Raises an exception
- Is interrupted by an error

This makes it appropriate for behavior that should always happen, such as timing, cleanup, and releasing resources.

---

## Decorator Pitfalls

### Hiding Important Logic

This is too opaque:

```python
@validate_everything
@do_security
@handle_errors
@do_magic
def process_request():
    ...
```

A reader cannot easily see what the function actually does or where behavior comes from.

Use decorators sparingly and give them precise names.

### Retrying Unsafe Operations

Avoid blindly retrying writes that may produce duplicates.

Bad default:

```python
@retry(attempts=5, retry_on=(Exception,))
def charge_credit_card():
    ...
```

Better:

- Retry only known temporary network errors.
- Use an idempotency key if the external API supports one.
- Ensure the server can identify duplicate requests.

### Catching `BaseException`

Do not normally catch `BaseException`.

It includes control-flow signals such as:

- `KeyboardInterrupt`
- `SystemExit`

Catch `Exception` or a narrow, domain-specific exception instead.

### Mutable Shared Decorator State

Avoid mutable state stored globally in decorators unless sharing is explicitly intended and safely synchronized.

Our `Library` creates one `InMemoryEventLog` per instance, avoiding cross-library log contamination.

---

## When Not to Use a Decorator

Use ordinary code instead when:

- The behavior applies only once.
- The extra behavior is core to the function’s purpose.
- The decorator would need too much hidden context.
- Debugging the wrapper chain would be harder than explicit code.
- The decorator alters control flow in a surprising way.

A decorator should simplify repeated, well-understood behavior—not turn code into a puzzle.
