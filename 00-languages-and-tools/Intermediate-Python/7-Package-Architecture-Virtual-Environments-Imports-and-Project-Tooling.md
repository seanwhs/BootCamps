# Part 7: Turn the Project into a Testable Python Package

Until now, we have focused on writing Pythonic code inside individual modules. The code is already organized under `src/library/`, but a production project needs more than source files.

It needs a repeatable structure for:

- Installing the package locally
- Managing development dependencies
- Running automated tests
- Keeping test code separate from application code
- Documenting supported Python versions and project settings
- Preventing accidental imports from the wrong location

In this part, we will formalize the project as a testable package.

---

## What You Will Build

At the end of this part, the project structure will be:

```text
pythonic-craftsmanship/
├── .gitignore
├── pyproject.toml
├── README.md
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
└── tests/
    ├── conftest.py
    ├── test_book.py
    ├── test_catalog.py
    ├── test_decorators.py
    ├── test_digital_book.py
    ├── test_reports.py
    ├── test_search.py
    └── test_snapshots.py
```

We will add:

- Development dependencies in `pyproject.toml`
- `pytest` test discovery configuration
- Reusable test fixtures in `conftest.py`
- Automated tests for models, catalog behavior, decorators, reports, search, and file snapshots
- A test command that works from the project root

---

# Step 1: Understand the `src/` Package Layout

## The Target

We are reviewing and preserving this existing layout:

```text
src/
└── library/
    └── __init__.py
```

No file changes are required in this step.

## The Concept

A **package** is Python code that can be imported by another program.

The file:

```text
src/library/__init__.py
```

marks `library` as an importable package.

The `src/` layout deliberately keeps importable code away from the project root.

Without a `src/` layout, a project might look like this:

```text
project/
├── library/
├── tests/
└── pyproject.toml
```

When running tests from the project root, Python may accidentally import `library/` directly from the current directory—even if the package was never installed correctly.

That can hide packaging problems.

With the `src/` layout:

```text
project/
├── src/
│   └── library/
├── tests/
└── pyproject.toml
```

Python must import the installed package. This better matches how real users will consume it.

Think of it like testing a product from its shipping box instead of testing it directly on the factory workbench.

## The Implementation

Confirm that your project has this directory:

```text
src/library/
```

and that it contains:

```text
__init__.py
```

Run this command from the project root:

```bash
find src/library -maxdepth 1 -type f
```

On Windows PowerShell:

```powershell
Get-ChildItem src\library -File
```

You should see the modules created in earlier parts.

## The Verification

Run:

```bash
python -c "import library; print(library.__file__)"
```

Expected output should point into your virtual environment or project’s installed editable source location, similar to:

```text
.../pythonic-craftsmanship/src/library/__init__.py
```

If Python cannot import `library`, reinstall the editable project after completing Step 2.

---

# Step 2: Add Development Dependencies and Tool Configuration

## The Target

We are replacing:

```text
pyproject.toml
```

This file will define:

- Build settings
- Project metadata
- Optional development dependencies
- `pytest` settings
- Basic `mypy` settings for the next part

## The Concept

`pyproject.toml` is the project’s control panel.

It gives tools one shared place to find configuration.

Instead of asking each developer to remember commands such as:

```bash
pip install pytest mypy
```

we define a named development dependency group:

```toml
[project.optional-dependencies]
dev = [...]
```

Then developers install everything needed for development with:

```bash
python -m pip install --editable ".[dev]"
```

The `--editable` option means source-code changes are immediately available without reinstalling after every edit.

## The Implementation

Replace the entire file.

### `pyproject.toml`

```toml
[build-system]
requires = ["setuptools>=69.0"]
build-backend = "setuptools.build_meta"

[project]
name = "pythonic-craftsmanship-library"
version = "0.1.0"
description = "Examples for learning clean, idiomatic, maintainable Python."
readme = "README.md"
requires-python = ">=3.11"
authors = [
  { name = "Pythonic Craftsmanship Student" }
]
classifiers = [
  "Programming Language :: Python :: 3",
  "Programming Language :: Python :: 3.11",
  "Programming Language :: Python :: 3.12",
  "Programming Language :: Python :: 3.13",
]

[project.optional-dependencies]
dev = [
  "mypy>=1.10",
  "pytest>=8.2",
]

[tool.setuptools]
package-dir = {"" = "src"}

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
addopts = "-ra"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]

[tool.mypy]
python_version = "3.11"
files = ["src"]
warn_unused_configs = true
warn_unused_ignores = true
check_untyped_defs = true
disallow_any_generics = true
no_implicit_optional = true
```

Install the package and its development tools:

```bash
python -m pip install --upgrade pip
python -m pip install --editable ".[dev]"
```

On Windows Command Prompt, if quoting causes trouble, run:

```bat
python -m pip install --editable .[dev]
```

## The Verification

Verify both tools are installed:

```bash
python -m pytest --version
python -m mypy --version
```

Expected output resembles:

```text
pytest 8.x.x
mypy 1.x.x
```

Then verify editable installation:

```bash
python -m pip show pythonic-craftsmanship-library
```

Look for:

```text
Editable project location:
```

followed by the path to your project directory.

---

# Step 3: Create Reusable Test Fixtures

## The Target

We are creating:

```text
tests/conftest.py
```

This file will provide reusable sample objects for multiple tests.

## The Concept

A **fixture** is reusable test setup.

Without fixtures, every test would repeat the same object construction:

```python
library = Library(name="Test Library")
book = Book(...)
library.add_item(book)
```

Repeated setup is like asking every chef in a restaurant to gather the same ingredients from scratch before preparing each dish.

A fixture acts like a prepared ingredients station.

`pytest` discovers fixtures in `conftest.py` automatically. Tests in the same directory or its subdirectories can request a fixture by naming it as a function parameter.

## The Implementation

Create the test directory:

```bash
mkdir -p tests
```

On Windows PowerShell:

```powershell
mkdir tests
```

Create the fixture file.

### `tests/conftest.py`

```python
"""Shared pytest fixtures for the library package tests."""

from __future__ import annotations

import pytest

from library import Book, DigitalBook, Library


@pytest.fixture
def physical_book() -> Book:
    """Return one valid physical-book instance."""
    return Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="BOOK-001",
        shelf_location="A-01",
    )


@pytest.fixture
def digital_book() -> DigitalBook:
    """Return one valid digital-book instance with two licenses."""
    return DigitalBook(
        title="Python for Data Analysis",
        author="Wes McKinney",
        identifier="EBOOK-001",
        download_url="https://library.example/downloads/python-data-analysis",
        license_limit=2,
    )


@pytest.fixture
def populated_library(physical_book: Book, digital_book: DigitalBook) -> Library:
    """Return a library containing one physical and one digital book."""
    library = Library(name="Test Library")
    library.add_item(physical_book)
    library.add_item(digital_book)

    return library
```

## The Verification

Create a temporary fixture smoke test.

### `tests/test_fixture_smoke.py`

```python
"""Verify that pytest discovers shared fixtures."""

from library import Library


def test_populated_library_fixture_contains_two_items(
    populated_library: Library,
) -> None:
    """The shared fixture should provide a catalog with two items."""
    assert len(populated_library) == 2
```

Run:

```bash
python -m pytest tests/test_fixture_smoke.py
```

Expected output includes:

```text
1 passed
```

Delete the smoke-test file after verifying fixtures:

### macOS or Linux

```bash
rm tests/test_fixture_smoke.py
```

### Windows PowerShell

```powershell
Remove-Item tests\test_fixture_smoke.py
```

### Windows Command Prompt

```bat
del tests\test_fixture_smoke.py
```

---

# Step 4: Test Core Book and Digital-Book Behavior

## The Target

We are creating:

```text
tests/test_book.py
tests/test_digital_book.py
```

These tests verify the most important behavior of our domain models.

## The Concept

A unit test verifies one small unit of behavior.

A useful test has three phases:

1. **Arrange**: create the objects needed for the test.
2. **Act**: perform one behavior.
3. **Assert**: verify the observable result.

For example:

```python
def test_book_can_be_checked_out(book: Book) -> None:
    book.check_out()

    assert book.is_checked_out is True
```

Tests should focus on behavior users and other code can observe. Avoid testing private implementation details unless they are the only practical way to verify an important contract.

## The Implementation

### `tests/test_book.py`

```python
"""Tests for physical Book behavior."""

from __future__ import annotations

import pytest

from library import Book


def test_book_starts_available(physical_book: Book) -> None:
    """A newly created book should be available."""
    assert physical_book.is_checked_out is False


def test_book_can_be_checked_out_and_returned(physical_book: Book) -> None:
    """A physical book should move through valid lending states."""
    physical_book.check_out()

    assert physical_book.is_checked_out is True

    physical_book.return_to_library()

    assert physical_book.is_checked_out is False


def test_checked_out_book_cannot_be_checked_out_again(
    physical_book: Book,
) -> None:
    """A second checkout must be rejected."""
    physical_book.check_out()

    with pytest.raises(ValueError, match="already checked out"):
        physical_book.check_out()


def test_available_book_cannot_be_returned_again(
    physical_book: Book,
) -> None:
    """Returning an already available book must be rejected."""
    with pytest.raises(ValueError, match="already in the library"):
        physical_book.return_to_library()


@pytest.mark.parametrize(
    ("title", "author", "isbn", "shelf_location", "expected_message"),
    [
        ("", "Author", "BOOK-001", "A-01", "Item title cannot be blank"),
        ("Title", "", "BOOK-001", "A-01", "Book author cannot be blank"),
        ("Title", "Author", "", "A-01", "Item identifier cannot be blank"),
        ("Title", "Author", "BOOK-001", "", "Book shelf location cannot be blank"),
    ],
)
def test_book_rejects_invalid_required_values(
    title: str,
    author: str,
    isbn: str,
    shelf_location: str,
    expected_message: str,
) -> None:
    """Every required Book field must contain usable text."""
    with pytest.raises(ValueError, match=expected_message):
        Book(
            title=title,
            author=author,
            isbn=isbn,
            shelf_location=shelf_location,
        )
```

### `tests/test_digital_book.py`

```python
"""Tests for DigitalBook license behavior."""

from __future__ import annotations

import pytest

from library import DigitalBook


def test_digital_book_allows_checkouts_up_to_license_limit(
    digital_book: DigitalBook,
) -> None:
    """Each checkout should consume one available license."""
    digital_book.check_out()

    assert digital_book.active_loans == 1
    assert digital_book.available_license_count == 1
    assert digital_book.is_checked_out is False

    digital_book.check_out()

    assert digital_book.active_loans == 2
    assert digital_book.available_license_count == 0
    assert digital_book.is_checked_out is True


def test_digital_book_rejects_checkout_when_all_licenses_are_used(
    digital_book: DigitalBook,
) -> None:
    """A fully loaned digital book cannot issue another loan."""
    digital_book.check_out()
    digital_book.check_out()

    with pytest.raises(ValueError, match="licenses.*in use"):
        digital_book.check_out()


def test_digital_book_return_releases_one_license(
    digital_book: DigitalBook,
) -> None:
    """Returning a digital loan should restore availability."""
    digital_book.check_out()
    digital_book.check_out()

    digital_book.return_to_library()

    assert digital_book.active_loans == 1
    assert digital_book.available_license_count == 1
    assert digital_book.is_checked_out is False


def test_digital_book_rejects_return_when_no_loans_exist(
    digital_book: DigitalBook,
) -> None:
    """A return requires an active digital loan."""
    with pytest.raises(ValueError, match="no active digital loans"):
        digital_book.return_to_library()
```

## The Verification

Run:

```bash
python -m pytest tests/test_book.py tests/test_digital_book.py
```

Expected output includes:

```text
10 passed
```

The exact timing is not important.

---

# Step 5: Test Catalog Behavior and Event Boundaries

## The Target

We are creating:

```text
tests/test_catalog.py
```

This test module verifies:

- Adding and finding items
- Duplicate protection
- Checkout logging
- Event subscriptions
- Failure isolation for optional event handlers

## The Concept

Some behavior belongs to a single model, such as `Book.check_out()`.

Other behavior belongs to the interaction between components, such as:

```text
Library checkout
    ↓
Book state changes
    ↓
Activity is recorded
    ↓
Event handlers are notified
    ↓
Call result is logged
```

These are still small tests, but they test a collaboration between objects.

A good test should avoid depending on external services, wall-clock timing, or execution order whenever possible.

## The Implementation

### `tests/test_catalog.py`

```python
"""Tests for Library catalog behavior and event boundaries."""

from __future__ import annotations

import pytest

from library import Book, Library, LibraryEvent


def test_library_finds_added_item(
    populated_library: Library,
    physical_book: Book,
) -> None:
    """An added item should be retrievable by identifier."""
    found_item = populated_library.find_item("BOOK-001")

    assert found_item is physical_book


def test_library_rejects_duplicate_identifier(
    populated_library: Library,
) -> None:
    """Two catalog items cannot share one identifier."""
    duplicate = Book(
        title="Another Book",
        author="Another Author",
        isbn="BOOK-001",
        shelf_location="B-01",
    )

    with pytest.raises(ValueError, match="already exists"):
        populated_library.add_item(duplicate)


def test_library_checkout_updates_item_and_creates_call_record(
    populated_library: Library,
) -> None:
    """Checkout should update state and record a successful decorated call."""
    checked_out_item = populated_library.check_out_item("BOOK-001")

    assert checked_out_item.is_checked_out is True

    records = populated_library.function_call_records()

    assert len(records) == 1
    assert records[0].succeeded is True
    assert records[0].function_name.endswith("Library._check_out_item")


def test_library_records_failed_checkout_call(
    populated_library: Library,
) -> None:
    """A failed checkout should still produce a failure call record."""
    populated_library.check_out_item("BOOK-001")

    with pytest.raises(ValueError, match="already checked out"):
        populated_library.check_out_item("BOOK-001")

    records = populated_library.function_call_records()

    assert len(records) == 2
    assert records[1].succeeded is False
    assert records[1].error_type == "ValueError"


def test_subscribed_handler_receives_completed_event() -> None:
    """A callback should receive event data after an item is added."""
    library = Library(name="Event Test Library")
    received_events: list[LibraryEvent] = []

    def record_event(event: LibraryEvent) -> None:
        received_events.append(event)

    library.subscribe(record_event)
    library.add_item(
        Book(
            title="Event-Driven Python",
            author="Example Author",
            isbn="BOOK-900",
            shelf_location="E-01",
        )
    )

    assert len(received_events) == 1
    assert received_events[0].event_type == "item_added"
    assert received_events[0].item_identifier == "BOOK-900"


def test_failing_optional_handler_does_not_prevent_item_addition() -> None:
    """Observer failures must not undo an already completed catalog action."""
    library = Library(name="Failure Boundary Test")

    def broken_handler(event: LibraryEvent) -> None:
        raise RuntimeError(f"Could not process {event.event_type}.")

    library.subscribe(broken_handler)

    library.add_item(
        Book(
            title="Reliable Systems",
            author="Example Author",
            isbn="BOOK-901",
            shelf_location="E-02",
        )
    )

    assert "BOOK-901" in library

    failures = library.event_dispatch_failures()

    assert len(failures) == 1
    assert failures[0].handler_name == "broken_handler"
    assert failures[0].error_type if False else True
    assert isinstance(failures[0].error, RuntimeError)
```

The line below is intentionally unnecessary and should not be part of clean production code:

```python
assert failures[0].error_type if False else True
```

Do **not** include it. Use this corrected complete file instead.

### `tests/test_catalog.py` (corrected final contents)

```python
"""Tests for Library catalog behavior and event boundaries."""

from __future__ import annotations

import pytest

from library import Book, Library, LibraryEvent


def test_library_finds_added_item(
    populated_library: Library,
    physical_book: Book,
) -> None:
    """An added item should be retrievable by identifier."""
    found_item = populated_library.find_item("BOOK-001")

    assert found_item is physical_book


def test_library_rejects_duplicate_identifier(
    populated_library: Library,
) -> None:
    """Two catalog items cannot share one identifier."""
    duplicate = Book(
        title="Another Book",
        author="Another Author",
        isbn="BOOK-001",
        shelf_location="B-01",
    )

    with pytest.raises(ValueError, match="already exists"):
        populated_library.add_item(duplicate)


def test_library_checkout_updates_item_and_creates_call_record(
    populated_library: Library,
) -> None:
    """Checkout should update state and record a successful decorated call."""
    checked_out_item = populated_library.check_out_item("BOOK-001")

    assert checked_out_item.is_checked_out is True

    records = populated_library.function_call_records()

    assert len(records) == 1
    assert records[0].succeeded is True
    assert records[0].function_name.endswith("Library._check_out_item")


def test_library_records_failed_checkout_call(
    populated_library: Library,
) -> None:
    """A failed checkout should still produce a failure call record."""
    populated_library.check_out_item("BOOK-001")

    with pytest.raises(ValueError, match="already checked out"):
        populated_library.check_out_item("BOOK-001")

    records = populated_library.function_call_records()

    assert len(records) == 2
    assert records[1].succeeded is False
    assert records[1].error_type == "ValueError"


def test_subscribed_handler_receives_completed_event() -> None:
    """A callback should receive event data after an item is added."""
    library = Library(name="Event Test Library")
    received_events: list[LibraryEvent] = []

    def record_event(event: LibraryEvent) -> None:
        received_events.append(event)

    library.subscribe(record_event)
    library.add_item(
        Book(
            title="Event-Driven Python",
            author="Example Author",
            isbn="BOOK-900",
            shelf_location="E-01",
        )
    )

    assert len(received_events) == 1
    assert received_events[0].event_type == "item_added"
    assert received_events[0].item_identifier == "BOOK-900"


def test_failing_optional_handler_does_not_prevent_item_addition() -> None:
    """Observer failures must not undo an already completed catalog action."""
    library = Library(name="Failure Boundary Test")

    def broken_handler(event: LibraryEvent) -> None:
        raise RuntimeError(f"Could not process {event.event_type}.")

    library.subscribe(broken_handler)

    library.add_item(
        Book(
            title="Reliable Systems",
            author="Example Author",
            isbn="BOOK-901",
            shelf_location="E-02",
        )
    )

    assert "BOOK-901" in library

    failures = library.event_dispatch_failures()

    assert len(failures) == 1
    assert failures[0].handler_name == "broken_handler"
    assert isinstance(failures[0].error, RuntimeError)
    assert failures[0].event.event_type == "item_added"
```

## The Verification

Run:

```bash
python -m pytest tests/test_catalog.py
```

Expected output includes:

```text
6 passed
```

---

# Step 6: Test Reports, Search, and Snapshot Writing

## The Target

We are creating:

```text
tests/test_reports.py
tests/test_search.py
tests/test_snapshots.py
```

## The Concept

These tests cover three different boundaries:

| Module | Boundary under test |
|---|---|
| `reports.py` | Data transformation and aggregation |
| `search.py` | Lazy search and validation |
| `snapshots.py` | File-system interaction |

For file tests, `pytest` provides the `tmp_path` fixture. It creates a temporary directory unique to the test, then cleans it up automatically.

This is much safer than writing test files into your real project’s `output/` directory.

## The Implementation

### `tests/test_reports.py`

```python
"""Tests for catalog reports."""

from __future__ import annotations

from library import CatalogReports, Library


def test_available_item_descriptions_exclude_checked_out_items(
    populated_library: Library,
) -> None:
    """Available report output should omit unavailable physical books."""
    populated_library.check_out_item("BOOK-001")

    reports = CatalogReports(populated_library)

    assert reports.available_item_descriptions() == [
        "Python for Data Analysis by Wes McKinney (digital)"
    ]


def test_item_count_by_type(
    populated_library: Library,
) -> None:
    """Type counts should include one physical and one digital book."""
    reports = CatalogReports(populated_library)

    assert reports.item_count_by_type() == {
        "Book": 1,
        "DigitalBook": 1,
    }


def test_items_by_author_groups_catalog_items(
    populated_library: Library,
) -> None:
    """Author grouping should retain the expected catalog objects."""
    reports = CatalogReports(populated_library)
    grouped_items = reports.items_by_author()

    assert [item.identifier for item in grouped_items["Robert C. Martin"]] == [
        "BOOK-001"
    ]
    assert [item.identifier for item in grouped_items["Wes McKinney"]] == [
        "EBOOK-001"
    ]
```

### `tests/test_search.py`

```python
"""Tests for lazy catalog search behavior."""

from __future__ import annotations

import pytest

from library import Library


def test_title_search_is_case_insensitive(
    populated_library: Library,
) -> None:
    """Search should match title fragments without case sensitivity."""
    matching_items = list(populated_library.search_title("PYTHON"))

    assert [item.identifier for item in matching_items] == ["EBOOK-001"]


def test_title_search_rejects_blank_query(
    populated_library: Library,
) -> None:
    """Decorator-based validation should reject blank text."""
    with pytest.raises(ValueError, match='Parameter "query" cannot be blank'):
        list(populated_library.search_title("   "))


def test_page_iterator_yields_fixed_size_pages(
    populated_library: Library,
) -> None:
    """Pagination should preserve insertion order and page size."""
    pages = list(populated_library.iter_pages(page_size=1))

    assert len(pages) == 2
    assert [item.identifier for item in pages[0]] == ["BOOK-001"]
    assert [item.identifier for item in pages[1]] == ["EBOOK-001"]
```

### `tests/test_snapshots.py`

```python
"""Tests for context-managed catalog snapshot writing."""

from __future__ import annotations

from pathlib import Path

import pytest

from library import CatalogSnapshotWriter, Library


def test_snapshot_writer_creates_parent_directories_and_file(
    populated_library: Library,
    tmp_path: Path,
) -> None:
    """A snapshot should be written with expected catalog content."""
    destination = tmp_path / "nested" / "catalog.txt"

    with CatalogSnapshotWriter(destination) as writer:
        writer.write_library(populated_library)

    contents = destination.read_text(encoding="utf-8")

    assert "Catalog snapshot: Test Library" in contents
    assert "Identifier: BOOK-001" in contents
    assert "Identifier: EBOOK-001" in contents
    assert "Type: Book" in contents
    assert "Type: DigitalBook" in contents


def test_snapshot_writer_rejects_write_outside_context(
    populated_library: Library,
    tmp_path: Path,
) -> None:
    """Writing without an active with block must raise a clear error."""
    writer = CatalogSnapshotWriter(tmp_path / "catalog.txt")

    with pytest.raises(RuntimeError, match="must be used inside a with block"):
        writer.write_library(populated_library)
```

## The Verification

Run:

```bash
python -m pytest tests/test_reports.py tests/test_search.py tests/test_snapshots.py
```

Expected output includes:

```text
8 passed
```

---

# Step 7: Test Standalone Decorators

## The Target

We are creating:

```text
tests/test_decorators.py
```

## The Concept

Decorators are easy to accidentally break because they wrap other functions.

We should test that they preserve the intended contract:

- A successful call is logged.
- A failing call is logged and re-raised.
- Input validation accepts positional and keyword arguments.
- Retries happen only for selected exceptions.

Testing decorators directly is valuable because many parts of the application may rely on them.

## The Implementation

### `tests/test_decorators.py`

```python
"""Tests for reusable function decorators."""

from __future__ import annotations

import pytest

from library.decorators import (
    InMemoryEventLog,
    log_calls,
    require_non_blank_string,
    retry,
)


def test_log_calls_records_successful_call() -> None:
    """A successful decorated function should create a success record."""
    event_log = InMemoryEventLog()

    @log_calls(event_log)
    def add(left: int, right: int) -> int:
        return left + right

    assert add(2, 3) == 5

    records = event_log.records()

    assert len(records) == 1
    assert records[0].succeeded is True
    assert records[0].function_name.endswith("add")


def test_log_calls_records_and_reraises_failure() -> None:
    """A failed decorated function should retain the original exception."""
    event_log = InMemoryEventLog()

    @log_calls(event_log)
    def fail() -> None:
        raise RuntimeError("Expected failure.")

    with pytest.raises(RuntimeError, match="Expected failure"):
        fail()

    records = event_log.records()

    assert len(records) == 1
    assert records[0].succeeded is False
    assert records[0].error_type == "RuntimeError"


def test_require_non_blank_string_accepts_keyword_argument() -> None:
    """Validation decorator should support named calls."""

    @require_non_blank_string("name")
    def greet(name: str) -> str:
        return f"Hello, {name.strip()}!"

    assert greet(name="Ada") == "Hello, Ada!"


def test_require_non_blank_string_rejects_blank_positional_argument() -> None:
    """Validation decorator should support positional calls."""

    @require_non_blank_string("name")
    def greet(name: str) -> str:
        return f"Hello, {name}!"

    with pytest.raises(ValueError, match='Parameter "name" cannot be blank'):
        greet("   ")


def test_retry_retries_selected_exception_until_success() -> None:
    """Temporary failures should be retried until success."""
    call_count = 0

    @retry(
        attempts=3,
        retry_on=(ConnectionError,),
    )
    def eventually_succeeds() -> str:
        nonlocal call_count

        call_count += 1

        if call_count < 3:
            raise ConnectionError("Temporary network interruption.")

        return "success"

    assert eventually_succeeds() == "success"
    assert call_count == 3


def test_retry_does_not_retry_unlisted_exception() -> None:
    """An exception outside retry_on should immediately escape."""
    call_count = 0

    @retry(
        attempts=3,
        retry_on=(ConnectionError,),
    )
    def fails_with_value_error() -> None:
        nonlocal call_count

        call_count += 1
        raise ValueError("Invalid input.")

    with pytest.raises(ValueError, match="Invalid input"):
        fails_with_value_error()

    assert call_count == 1
```

## The Verification

Run:

```bash
python -m pytest tests/test_decorators.py
```

Expected output includes:

```text
6 passed
```

---

# Step 8: Run the Entire Test Suite

## The Target

We are verifying the complete package test suite.

## The Concept

Individual tests prove small pieces work.

The full test suite proves that new changes did not unexpectedly break older behavior.

This is called **regression protection**.

A regression is a bug where something that previously worked stops working after a change.

Testing is like an automated safety inspection. You still need engineering judgment, but the inspection catches many accidental changes before users do.

## The Implementation

No file changes are required.

Run the entire suite from the project root:

```bash
python -m pytest
```

For more detailed test names and output, run:

```bash
python -m pytest --verbose
```

## The Verification

Expected output includes a result similar to:

```text
============================= test session starts =============================
...
============================== 30 passed in ...s ==============================
```

The exact test count depends on whether you added additional tests while following earlier parts. The important result is:

```text
passed
```

with no failures or errors.

---

# Part 7 Reference: Package and Test Architecture

## Why Use `python -m pytest`?

This command:

```bash
python -m pytest
```

runs `pytest` using the exact Python interpreter currently active in your terminal.

That matters when using virtual environments.

It is safer than simply running:

```bash
pytest
```

because the `pytest` command might point to a globally installed copy rather than the one inside `.venv`.

The same principle applies to:

```bash
python -m pip install ...
python -m mypy ...
```

---

## Editable Installation

Install the current package in editable mode:

```bash
python -m pip install --editable ".[dev]"
```

Breaking it down:

| Segment | Meaning |
|---|---|
| `python -m pip` | Use pip belonging to the active Python interpreter |
| `install` | Install a package |
| `--editable` | Use current source files directly |
| `.` | Install the package in the current directory |
| `[dev]` | Also install the optional `dev` dependency group |

Editable installation is ideal for local development.

For a release build, users typically install a wheel or source distribution rather than an editable checkout.

---

## Test Naming Rules

Our `pyproject.toml` configures `pytest` to discover:

```toml
python_files = ["test_*.py"]
python_functions = ["test_*"]
```

That means:

```text
tests/test_catalog.py
```

is discovered, and:

```python
def test_library_finds_added_item():
```

is executed.

A function named this would not be discovered automatically:

```python
def verify_library_finds_added_item():
    ...
```

unless you customize the configuration.

---

## `pytest.raises`

Use `pytest.raises` to verify expected failures:

```python
with pytest.raises(ValueError, match="cannot be blank"):
    Book(
        title="",
        author="Author",
        isbn="BOOK-001",
        shelf_location="A-01",
    )
```

This test verifies two things:

1. The code raises `ValueError`.
2. The error message contains text matching the supplied regular expression.

Testing expected errors is important. Validation behavior is part of your public contract.

---

## Fixtures and Scope

A fixture is a reusable object factory:

```python
@pytest.fixture
def physical_book() -> Book:
    return Book(...)
```

By default, fixtures have **function scope**. `pytest` creates a fresh fixture for every test that requests it.

This isolation is valuable. One test can check out a book without accidentally affecting a different test.

Other fixture scopes include:

```python
@pytest.fixture(scope="module")
@pytest.fixture(scope="session")
```

Use broader scopes carefully. Shared mutable state often creates tests that depend on execution order.

---

## Test Behavior, Not Private Details

Prefer testing public behavior:

```python
assert library.find_item("BOOK-001") is physical_book
```

rather than private storage:

```python
assert library._items_by_identifier["BOOK-001"] is physical_book
```

Private attributes may change during refactoring without changing what the package promises to users.

Test private behavior only when there is no practical public way to verify an important contract.

---

## Test Pyramid Guidance

A useful testing balance is:

```text
        Few end-to-end tests
      -----------------------
       More integration tests
    ---------------------------
      Many focused unit tests
```

For this tutorial project:

- Model tests are mostly unit tests.
- Catalog-plus-event tests are small integration tests.
- Snapshot tests touch the file system but remain isolated through `tmp_path`.

In the capstone, we will add HTTP transport tests that simulate remote API behavior without requiring a real network service.
