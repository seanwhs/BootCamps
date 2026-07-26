# Part 4: Iterators, Generators, and Context Managers

In Part 3, we used collection tools to transform catalog data. We also used generator expressions with `any()` and `all()`:

```python
any(not item.is_checked_out for item in library)
```

Now we will explore the mechanics beneath that syntax.

This part covers three closely related ideas:

1. **Iterators**: objects that provide values one at a time.
2. **Generators**: a convenient way to create iterators with `yield`.
3. **Context managers**: objects that set up and reliably clean up resources through `with` blocks.

These features are important in production Python because they help programs use memory efficiently and manage resources safely.

---

## What You Will Build

We will extend the library project with:

```text
pythonic-craftsmanship/
├── src/
│   └── library/
│       ├── __init__.py
│       ├── book.py
│       ├── catalog.py
│       ├── digital_book.py
│       ├── lending_item.py
│       ├── reports.py
│       ├── search.py
│       └── snapshots.py
└── examples/
    ├── part_4_context_manager_demo.py
    ├── part_4_generator_demo.py
    └── part_4_iterator_demo.py
```

By the end, you will have:

- A custom iterator that walks through a catalog in pages.
- Generator-based search methods that yield matching items lazily.
- A generator that streams checkout-ready item identifiers.
- A context manager that writes a catalog snapshot safely to disk.
- A practical understanding of when to use a list, an iterator, or a generator.

---

# Step 1: Understand the Iterator Protocol

## The Target

We are creating a small demonstration file:

```text
examples/part_4_iterator_demo.py
```

This file will show how `iter()` and `next()` work.

## The Concept

An **iterable** is an object you can loop over.

Examples include:

- Lists
- Tuples
- Dictionaries
- Strings
- Sets
- Files
- Our `Library` class, because it defines `__iter__`

An **iterator** is the object that produces the next value in a sequence.

When Python runs this loop:

```python
for item in library:
    print(item)
```

it performs a process conceptually similar to this:

```python
iterator = iter(library)

while True:
    try:
        item = next(iterator)
    except StopIteration:
        break

    print(item)
```

The `for` loop hides this machinery because the full version would be repetitive.

Think of an iterator as a ticket dispenser:

- Each call to `next()` gives you the next ticket.
- Eventually, there are no tickets left.
- At that point, the iterator raises `StopIteration`.

## The Implementation

Create the following file.

### `examples/part_4_iterator_demo.py`

```python
"""Demonstrate Python's iterable and iterator protocols."""

from library import Book, Library


def main() -> None:
    """Manually retrieve catalog items with iter() and next()."""
    library = Library(name="Iterator Demo Library")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="BOOK-001",
            shelf_location="A-01",
        )
    )
    library.add_item(
        Book(
            title="The Pragmatic Programmer",
            author="David Thomas and Andrew Hunt",
            isbn="BOOK-002",
            shelf_location="A-02",
        )
    )

    # Library.__iter__ returns an iterator over the catalog's values.
    item_iterator = iter(library)

    print("First item:")
    print(next(item_iterator))

    print("\nSecond item:")
    print(next(item_iterator))

    print("\nAttempting to read past the final item:")
    try:
        print(next(item_iterator))
    except StopIteration:
        print("The iterator is exhausted: no items remain.")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_4_iterator_demo.py
```

Expected output:

```text
First item:
Clean Code by Robert C. Martin

Second item:
The Pragmatic Programmer by David Thomas and Andrew Hunt

Attempting to read past the final item:
The iterator is exhausted: no items remain.
```

An iterator is normally consumed only once. Once it reaches the end, calling `next()` again will continue to raise `StopIteration`.

---

# Step 2: Build a Custom Page Iterator

## The Target

We are creating:

```text
src/library/search.py
```

This module will contain a `CatalogPageIterator` class. It will return catalog items in fixed-size pages.

For example, a catalog with five items and a page size of two produces:

```text
Page 1: items 1–2
Page 2: items 3–4
Page 3: item 5
```

## The Concept

A custom iterator is useful when you need to control how values are delivered.

In a future API client, a server may return results in pages:

```text
GET /projects?page=1
GET /projects?page=2
GET /projects?page=3
```

Rather than loading every page at once, an iterator can provide one page at a time.

For this local catalog example, the iterator receives a snapshot of items and returns each page as a tuple.

A tuple is used because callers should be able to read a page but should not accidentally add or remove items from it.

To create an iterator class, implement:

```python
def __iter__(self) -> CatalogPageIterator:
    return self

def __next__(self) -> tuple[LendingItem, ...]:
    ...
```

- `__iter__` returns the iterator itself.
- `__next__` returns one next value or raises `StopIteration` when finished.

## The Implementation

Create the following file.

### `src/library/search.py`

```python
"""Lazy catalog searching and pagination helpers."""

from __future__ import annotations

from collections.abc import Iterator, Sequence

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

        # Store an immutable snapshot. This prevents later changes to a source
        # list from changing which objects this iterator will paginate.
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

        # Advance before returning so the iterator progresses on every call.
        self._current_index = page_end

        return self._items[page_start:page_end]
```

Now update the `Library` class so users can request this iterator through a clean method.

Replace `src/library/catalog.py` with the complete version below.

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections import deque
from collections.abc import Iterator
from datetime import UTC, datetime

from library.lending_item import LendingItem
from library.search import CatalogPageIterator


class Library:
    """Manage a collection of lending items indexed by identifier."""

    def __init__(self, name: str, activity_history_limit: int = 100) -> None:
        """Create an empty library catalog.

        Args:
            name: The public name of the library.
            activity_history_limit: Maximum number of recent actions to keep.

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

    def add_item(self, item: LendingItem) -> None:
        """Add a lending item to the catalog.

        Raises:
            TypeError: If item is not a LendingItem instance.
            ValueError: If another item already uses the same identifier.
        """
        if not isinstance(item, LendingItem):
            raise TypeError("Library items must inherit from LendingItem.")

        if item.identifier in self._items_by_identifier:
            raise ValueError(
                f'An item with identifier "{item.identifier}" already exists '
                f"in {self.name}."
            )

        self._items_by_identifier[item.identifier] = item
        self._record_activity(f'Added item "{item.identifier}".')

    def find_item(self, identifier: str) -> LendingItem:
        """Return the catalog item with the given identifier.

        Raises:
            KeyError: If the item does not exist.
        """
        cleaned_identifier = identifier.strip()

        try:
            return self._items_by_identifier[cleaned_identifier]
        except KeyError as error:
            raise KeyError(
                f'No item with identifier "{cleaned_identifier}" exists in {self.name}.'
            ) from error

    def available_items(self) -> list[LendingItem]:
        """Return all catalog items that can currently be checked out."""
        return [item for item in self if not item.is_checked_out]

    def iter_pages(self, page_size: int) -> CatalogPageIterator:
        """Return an iterator that yields catalog items in fixed-size pages.

        The iterator captures the catalog items that exist at creation time.
        Items added afterward will not appear in this iteration.
        """
        return CatalogPageIterator(items=tuple(self), page_size=page_size)

    def check_out_item(self, identifier: str) -> LendingItem:
        """Check out an item and return its updated object."""
        item = self.find_item(identifier)
        item.check_out()
        self._record_activity(f'Checked out item "{item.identifier}".')

        return item

    def return_item(self, identifier: str) -> LendingItem:
        """Return an item and return its updated object."""
        item = self.find_item(identifier)
        item.return_to_library()
        self._record_activity(f'Returned item "{item.identifier}".')

        return item

    def recent_activity(self) -> tuple[str, ...]:
        """Return an immutable snapshot of recent catalog activity."""
        return tuple(self._recent_activity)
```

Update the package exports.

### `src/library/__init__.py`

```python
"""A small library domain package used in the OOP tutorial modules."""

from library.book import Book
from library.catalog import Library
from library.digital_book import DigitalBook
from library.lending_item import LendingItem
from library.reports import CatalogReports
from library.search import CatalogPageIterator

__all__ = [
    "Book",
    "CatalogPageIterator",
    "CatalogReports",
    "DigitalBook",
    "LendingItem",
    "Library",
]
```

Create a demonstration file.

### `examples/part_4_page_iterator_demo.py`

```python
"""Demonstrate a custom iterator that yields catalog pages."""

from library import Book, Library


def main() -> None:
    """Print catalog items in pages of two."""
    library = Library(name="Paged Catalog")

    for number in range(1, 6):
        library.add_item(
            Book(
                title=f"Book {number}",
                author=f"Author {number}",
                isbn=f"BOOK-{number:03d}",
                shelf_location=f"A-{number:02d}",
            )
        )

    for page_number, page in enumerate(library.iter_pages(page_size=2), start=1):
        print(f"Page {page_number}:")
        for item in page:
            print(f"- {item}")
        print()


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_4_page_iterator_demo.py
```

Expected output:

```text
Page 1:
- Book 1 by Author 1
- Book 2 by Author 2

Page 2:
- Book 3 by Author 3
- Book 4 by Author 4

Page 3:
- Book 5 by Author 5
```

Now verify input validation:

```bash
python -c "from library import Library; Library('Test').iter_pages(0)"
```

Expected result:

```text
ValueError: Page size must be at least 1.
```

---

# Step 3: Create Lazy Search Generators

## The Target

We are extending:

```text
src/library/search.py
```

We will add generator functions that search for catalog items without creating a complete results list first.

## The Concept

A **generator function** uses `yield` instead of `return` to provide values gradually.

A regular function builds every result before it returns:

```python
def available_titles(library: Library) -> list[str]:
    return [
        item.title
        for item in library
        if not item.is_checked_out
    ]
```

A generator function provides one result at a time:

```python
def iter_available_items(library: Library):
    for item in library:
        if not item.is_checked_out:
            yield item
```

The word **lazy** means work happens only when the caller asks for the next result.

Think of the difference this way:

- A list is like preparing every meal for the week before anyone asks for lunch.
- A generator is like a kitchen that prepares one meal when an order arrives.

Generators are valuable when:

- A collection may be very large.
- Producing each result is expensive.
- A caller may stop early.
- Results come from a stream, file, database, or paginated API.

## The Implementation

Replace `src/library/search.py` with the complete file below.

### `src/library/search.py`

```python
"""Lazy catalog searching and pagination helpers."""

from __future__ import annotations

from collections.abc import Iterator, Sequence

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


def iter_available_items(items: Sequence[LendingItem]) -> Iterator[LendingItem]:
    """Yield each item that can currently be checked out.

    The function does not create a list of all available items. It evaluates
    each item only when the caller requests the next result.
    """
    for item in items:
        if not item.is_checked_out:
            yield item


def iter_items_matching_title(
    items: Sequence[LendingItem],
    query: str,
) -> Iterator[LendingItem]:
    """Yield items whose title contains query, case-insensitively.

    Args:
        items: Catalog items to search.
        query: A non-blank title fragment.

    Raises:
        ValueError: If query is blank.
    """
    normalized_query = query.strip().casefold()

    if not normalized_query:
        raise ValueError("Search query cannot be blank.")

    for item in items:
        if normalized_query in item.title.casefold():
            yield item


def iter_available_identifiers(
    items: Sequence[LendingItem],
) -> Iterator[str]:
    """Yield identifiers for items that can currently be checked out."""
    for item in iter_available_items(items):
        yield item.identifier
```

Update `Library` so callers can use the lazy search functions without manually converting the catalog to a sequence.

Replace `src/library/catalog.py` with this complete version.

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections import deque
from collections.abc import Iterator
from datetime import UTC, datetime

from library.lending_item import LendingItem
from library.search import (
    CatalogPageIterator,
    iter_available_identifiers,
    iter_available_items,
    iter_items_matching_title,
)


class Library:
    """Manage a collection of lending items indexed by identifier."""

    def __init__(self, name: str, activity_history_limit: int = 100) -> None:
        """Create an empty library catalog.

        Args:
            name: The public name of the library.
            activity_history_limit: Maximum number of recent actions to keep.

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

    def add_item(self, item: LendingItem) -> None:
        """Add a lending item to the catalog.

        Raises:
            TypeError: If item is not a LendingItem instance.
            ValueError: If another item already uses the same identifier.
        """
        if not isinstance(item, LendingItem):
            raise TypeError("Library items must inherit from LendingItem.")

        if item.identifier in self._items_by_identifier:
            raise ValueError(
                f'An item with identifier "{item.identifier}" already exists '
                f"in {self.name}."
            )

        self._items_by_identifier[item.identifier] = item
        self._record_activity(f'Added item "{item.identifier}".')

    def find_item(self, identifier: str) -> LendingItem:
        """Return the catalog item with the given identifier.

        Raises:
            KeyError: If the item does not exist.
        """
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
        return iter_available_items(tuple(self))

    def iter_available_identifiers(self) -> Iterator[str]:
        """Yield identifiers for items that can currently be checked out."""
        return iter_available_identifiers(tuple(self))

    def search_title(self, query: str) -> Iterator[LendingItem]:
        """Yield items with titles containing query, case-insensitively."""
        return iter_items_matching_title(tuple(self), query)

    def iter_pages(self, page_size: int) -> CatalogPageIterator:
        """Return an iterator that yields catalog items in fixed-size pages."""
        return CatalogPageIterator(items=tuple(self), page_size=page_size)

    def check_out_item(self, identifier: str) -> LendingItem:
        """Check out an item and return its updated object."""
        item = self.find_item(identifier)
        item.check_out()
        self._record_activity(f'Checked out item "{item.identifier}".')

        return item

    def return_item(self, identifier: str) -> LendingItem:
        """Return an item and return its updated object."""
        item = self.find_item(identifier)
        item.return_to_library()
        self._record_activity(f'Returned item "{item.identifier}".')

        return item

    def recent_activity(self) -> tuple[str, ...]:
        """Return an immutable snapshot of recent catalog activity."""
        return tuple(self._recent_activity)
```

Create the generator demonstration.

### `examples/part_4_generator_demo.py`

```python
"""Demonstrate lazy searching and generator-based catalog processing."""

from library import Book, DigitalBook, Library


def build_library() -> Library:
    """Create a catalog suitable for lazy-search examples."""
    library = Library(name="Generator Demo Library")

    library.add_item(
        Book(
            title="Python Crash Course",
            author="Eric Matthes",
            isbn="BOOK-001",
            shelf_location="P-01",
        )
    )
    library.add_item(
        Book(
            title="Fluent Python",
            author="Luciano Ramalho",
            isbn="BOOK-002",
            shelf_location="P-02",
        )
    )
    library.add_item(
        DigitalBook(
            title="Python for Data Analysis",
            author="Wes McKinney",
            identifier="EBOOK-001",
            download_url="https://library.example/downloads/python-data-analysis",
            license_limit=1,
        )
    )

    library.check_out_item("BOOK-002")

    return library


def main() -> None:
    """Search lazily and consume only the values required."""
    library = build_library()

    matching_items = library.search_title("python")

    print("The search result is an iterator:")
    print(type(matching_items).__name__)

    print("\nFirst matching title:")
    first_match = next(matching_items)
    print(f"- {first_match}")

    print("\nRemaining matching titles:")
    for item in matching_items:
        print(f"- {item}")

    print("\nAvailable identifiers:")
    for identifier in library.iter_available_identifiers():
        print(f"- {identifier}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_4_generator_demo.py
```

Expected output:

```text
The search result is an iterator:
generator

First matching title:
- Python Crash Course by Eric Matthes

Remaining matching titles:
- Fluent Python by Luciano Ramalho
- Python for Data Analysis by Wes McKinney (digital)

Available identifiers:
- BOOK-001
- EBOOK-001
```

Notice that `first_match` is no longer printed in the “remaining” section. Calling `next(matching_items)` consumed the first generated value.

---

# Step 4: Use `itertools` to Compose Iterator Behavior

## The Target

We are extending:

```text
src/library/search.py
```

We will add iterator helpers using the `itertools` standard-library module.

## The Concept

`itertools` contains building blocks for efficient iterator processing.

Instead of manually writing common iterator patterns, `itertools` provides tested, expressive tools.

We will use:

| Tool | Purpose |
|---|---|
| `islice()` | Take a limited number of values from an iterator |
| `chain()` | Combine multiple iterables into one stream |
| `filterfalse()` | Keep values for which a condition is false |

For a real-world analogy, imagine a conveyor belt:

- `chain()` joins multiple belts into one longer belt.
- `islice()` allows only a limited number of boxes through.
- `filterfalse()` removes boxes that match an exclusion rule.

## The Implementation

Replace `src/library/search.py` with the complete file below.

### `src/library/search.py`

```python
"""Lazy catalog searching and pagination helpers."""

from __future__ import annotations

from collections.abc import Callable, Iterable, Iterator, Sequence
from itertools import chain, filterfalse, islice

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


def iter_items_matching_title(
    items: Iterable[LendingItem],
    query: str,
) -> Iterator[LendingItem]:
    """Yield items whose title contains query, case-insensitively.

    Raises:
        ValueError: If query is blank.
    """
    normalized_query = query.strip().casefold()

    if not normalized_query:
        raise ValueError("Search query cannot be blank.")

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

Add convenience methods to `Library`.

Replace `src/library/catalog.py` with the following complete version.

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections import deque
from collections.abc import Callable, Iterator
from datetime import UTC, datetime
from itertools import islice

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
            activity_history_limit: Maximum number of recent actions to keep.

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

    def add_item(self, item: LendingItem) -> None:
        """Add a lending item to the catalog.

        Raises:
            TypeError: If item is not a LendingItem instance.
            ValueError: If another item already uses the same identifier.
        """
        if not isinstance(item, LendingItem):
            raise TypeError("Library items must inherit from LendingItem.")

        if item.identifier in self._items_by_identifier:
            raise ValueError(
                f'An item with identifier "{item.identifier}" already exists '
                f"in {self.name}."
            )

        self._items_by_identifier[item.identifier] = item
        self._record_activity(f'Added item "{item.identifier}".')

    def find_item(self, identifier: str) -> LendingItem:
        """Return the catalog item with the given identifier.

        Raises:
            KeyError: If the item does not exist.
        """
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
        """Yield no more than limit catalog items.

        Raises:
            ValueError: If limit is negative.
        """
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

    def check_out_item(self, identifier: str) -> LendingItem:
        """Check out an item and return its updated object."""
        item = self.find_item(identifier)
        item.check_out()
        self._record_activity(f'Checked out item "{item.identifier}".')

        return item

    def return_item(self, identifier: str) -> LendingItem:
        """Return an item and return its updated object."""
        item = self.find_item(identifier)
        item.return_to_library()
        self._record_activity(f'Returned item "{item.identifier}".')

        return item

    def recent_activity(self) -> tuple[str, ...]:
        """Return an immutable snapshot of recent catalog activity."""
        return tuple(self._recent_activity)
```

Create an `itertools` demonstration.

### `examples/part_4_itertools_demo.py`

```python
"""Demonstrate useful itertools patterns for catalog streams."""

from library import Book, Library
from library.search import iter_all_items


def create_library(name: str, identifier_prefix: str) -> Library:
    """Create a small catalog with three physical books."""
    library = Library(name=name)

    for number in range(1, 4):
        library.add_item(
            Book(
                title=f"{name} Book {number}",
                author=f"Author {number}",
                isbn=f"{identifier_prefix}-{number}",
                shelf_location=f"A-{number}",
            )
        )

    return library


def main() -> None:
    """Compose and limit item streams without creating unnecessary lists."""
    north_library = create_library("North", "NORTH")
    south_library = create_library("South", "SOUTH")

    print("First two North catalog items:")
    for item in north_library.first_items(2):
        print(f"- {item}")

    print("\nAll items from both catalogs:")
    for item in iter_all_items(north_library, south_library):
        print(f"- {item.identifier}")

    print("\nNorth items excluding titles containing '2':")
    for item in north_library.iter_items_excluding(lambda value: "2" in value.title):
        print(f"- {item}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_4_itertools_demo.py
```

Expected output:

```text
First two North catalog items:
- North Book 1 by Author 1
- North Book 2 by Author 2

All items from both catalogs:
- NORTH-1
- NORTH-2
- NORTH-3
- SOUTH-1
- SOUTH-2
- SOUTH-3

North items excluding titles containing '2':
- North Book 1 by Author 1
- North Book 3 by Author 3
```

---

# Step 5: Create a Context Manager for Safe Catalog Snapshots

## The Target

We are creating:

```text
src/library/snapshots.py
```

This module will contain a `CatalogSnapshotWriter` context manager that writes catalog information to a UTF-8 text file.

## The Concept

A **context manager** is an object that handles setup and cleanup around a block of code.

The most familiar context manager is file handling:

```python
with open("report.txt", "w", encoding="utf-8") as file_handle:
    file_handle.write("Hello\n")
```

The `with` block ensures the file is closed, even if an error occurs while writing.

Without `with`, it is easy to forget cleanup:

```python
file_handle = open("report.txt", "w", encoding="utf-8")
file_handle.write("Hello\n")
file_handle.close()
```

If an exception occurs before `close()`, the resource may remain open longer than intended.

A context manager is like a hotel check-in and check-out process:

- `__enter__` checks in and prepares the room.
- The block does its work.
- `__exit__` checks out and handles cleanup no matter how the stay ended.

Our snapshot writer will:

1. Create parent directories if needed.
2. Open a destination file safely.
3. Write a heading and item information.
4. Close the file automatically.
5. Preserve exceptions rather than hiding them.

## The Implementation

Create the file below.

### `src/library/snapshots.py`

```python
"""Context-managed catalog snapshot writing."""

from __future__ import annotations

from pathlib import Path
from types import TracebackType
from typing import TextIO

from library.catalog import Library
from library.lending_item import LendingItem


class CatalogSnapshotWriter:
    """Write a human-readable catalog snapshot through a with block."""

    def __init__(self, destination: str | Path) -> None:
        """Store and validate the destination path.

        Args:
            destination: File path where the snapshot should be written.

        Raises:
            ValueError: If destination is empty or points to a directory-like
                path without a filename.
        """
        path = Path(destination)

        if not str(path).strip():
            raise ValueError("Snapshot destination cannot be blank.")

        if path.name in {"", "."}:
            raise ValueError("Snapshot destination must include a filename.")

        self._destination = path
        self._file_handle: TextIO | None = None

    def __enter__(self) -> CatalogSnapshotWriter:
        """Create parent folders, open the snapshot file, and return this writer."""
        self._destination.parent.mkdir(parents=True, exist_ok=True)

        # UTF-8 is explicit so output behaves consistently across platforms.
        self._file_handle = self._destination.open(
            mode="w",
            encoding="utf-8",
            newline="\n",
        )

        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: TracebackType | None,
    ) -> bool:
        """Close the open file and allow any exception to continue upward.

        Returning False tells Python not to suppress exceptions raised inside
        the with block.
        """
        if self._file_handle is not None:
            self._file_handle.close()
            self._file_handle = None

        return False

    def write_library(self, library: Library) -> None:
        """Write a complete snapshot of a library catalog.

        Raises:
            RuntimeError: If called outside an active with block.
        """
        file_handle = self._require_open_file()

        file_handle.write(f"Catalog snapshot: {library.name}\n")
        file_handle.write(f"Item count: {len(library)}\n")
        file_handle.write("\n")

        for item in library:
            self.write_item(item)

    def write_item(self, item: LendingItem) -> None:
        """Write one catalog item's essential details.

        Raises:
            RuntimeError: If called outside an active with block.
        """
        file_handle = self._require_open_file()

        availability = "unavailable" if item.is_checked_out else "available"

        file_handle.write(f"Identifier: {item.identifier}\n")
        file_handle.write(f"Title: {item.title}\n")
        file_handle.write(f"Type: {type(item).__name__}\n")
        file_handle.write(f"Availability: {availability}\n")
        file_handle.write("\n")

    def _require_open_file(self) -> TextIO:
        """Return the active file handle or raise a clear usage error."""
        if self._file_handle is None:
            raise RuntimeError(
                "CatalogSnapshotWriter must be used inside a with block."
            )

        return self._file_handle
```

Export the writer from the package.

### `src/library/__init__.py`

```python
"""A small library domain package used in the OOP tutorial modules."""

from library.book import Book
from library.catalog import Library
from library.digital_book import DigitalBook
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
    "LendingItem",
    "Library",
]
```

Create a context-manager demonstration.

### `examples/part_4_context_manager_demo.py`

```python
"""Demonstrate safe catalog snapshot writing with a context manager."""

from pathlib import Path

from library import Book, CatalogSnapshotWriter, DigitalBook, Library


def main() -> None:
    """Write a catalog snapshot and print the saved file contents."""
    library = Library(name="Snapshot Demo Library")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="BOOK-001",
            shelf_location="A-01",
        )
    )
    library.add_item(
        DigitalBook(
            title="Python for Data Analysis",
            author="Wes McKinney",
            identifier="EBOOK-001",
            download_url="https://library.example/downloads/python-data-analysis",
            license_limit=1,
        )
    )

    library.check_out_item("BOOK-001")

    destination = Path("output") / "catalog_snapshot.txt"

    # __enter__ opens the file. __exit__ closes it even if writing fails.
    with CatalogSnapshotWriter(destination) as writer:
        writer.write_library(library)

    print(f"Snapshot written to: {destination}")
    print("\nSnapshot contents:\n")
    print(destination.read_text(encoding="utf-8"), end="")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_4_context_manager_demo.py
```

Expected output:

```text
Snapshot written to: output/catalog_snapshot.txt

Snapshot contents:

Catalog snapshot: Snapshot Demo Library
Item count: 2

Identifier: BOOK-001
Title: Clean Code
Type: Book
Availability: unavailable

Identifier: EBOOK-001
Title: Python for Data Analysis
Type: DigitalBook
Availability: available
```

Also confirm the file exists:

### macOS or Linux

```bash
cat output/catalog_snapshot.txt
```

### Windows PowerShell

```powershell
Get-Content output\catalog_snapshot.txt
```

The printed contents should match the terminal output.

---

# Step 6: Verify Context Manager Error Boundaries

## The Target

We are verifying that `CatalogSnapshotWriter`:

- Rejects use outside a `with` block.
- Closes files when an error occurs in the `with` block.
- Does not hide the original exception.

## The Concept

Cleanup is most valuable when something goes wrong.

A context manager should not merely work on the happy path. It must correctly release resources if code raises an exception.

Our `__exit__` method returns:

```python
False
```

That tells Python:

> Close the resource, then continue raising the original error.

Silently swallowing unexpected exceptions makes debugging much harder. Production code should only suppress errors deliberately and with a clear reason.

## The Implementation

Create this verification program.

### `examples/part_4_context_manager_error_demo.py`

```python
"""Verify context-manager cleanup and error behavior."""

from pathlib import Path

from library import CatalogSnapshotWriter


def main() -> None:
    """Demonstrate safe failure behavior."""
    destination = Path("output") / "error_boundary_snapshot.txt"
    writer = CatalogSnapshotWriter(destination)

    print("Attempting to write outside a with block:")
    try:
        writer.write_item(None)  # type: ignore[arg-type]
    except RuntimeError as error:
        print(f"Expected error: {error}")

    print("\nWriting inside a with block, then intentionally raising an error:")
    try:
        with CatalogSnapshotWriter(destination) as active_writer:
            active_writer._require_open_file().write("The file was opened safely.\n")
            raise ValueError("Demonstration failure after writing.")
    except ValueError as error:
        print(f"Expected error: {error}")

    print("\nThe file can be read after the failed with block because it was closed:")
    print(destination.read_text(encoding="utf-8"), end="")


if __name__ == "__main__":
    main()
```

The call to `_require_open_file()` is intentionally used only in this educational verification example to prove the file is active inside the context. Application code should use public methods such as `write_library()` and `write_item()`.

## The Verification

Run:

```bash
python examples/part_4_context_manager_error_demo.py
```

Expected output:

```text
Attempting to write outside a with block:
Expected error: CatalogSnapshotWriter must be used inside a with block.

Writing inside a with block, then intentionally raising an error:
Expected error: Demonstration failure after writing.

The file can be read after the failed with block because it was closed:
The file was opened safely.
```

The original `ValueError` was preserved, and the file was still closed correctly.

---

# Part 4 Reference: Iterators, Generators, and Context Managers

## Iterable versus Iterator

An **iterable** can produce an iterator.

```python
library
```

An **iterator** produces individual values.

```python
iterator = iter(library)
next_item = next(iterator)
```

Most built-in collections are iterable. Calling `iter()` on them creates an iterator.

```python
names = ["Ada", "Grace", "Linus"]

iterator = iter(names)

print(next(iterator))  # Ada
print(next(iterator))  # Grace
print(next(iterator))  # Linus
```

Calling `next()` one more time raises:

```text
StopIteration
```

---

## Why `for` Loops Are Preferred

Manual iterator control is useful for learning and occasional specialized logic, but normal loops are clearer:

```python
for item in library:
    print(item)
```

Python handles:

- Calling `iter()`
- Repeatedly calling `next()`
- Stopping cleanly at `StopIteration`

You should not manually catch `StopIteration` inside a generator function. Let generators end naturally by reaching the end of the function or using a plain `return`.

---

## Generator Functions

A generator function contains `yield`.

```python
def iter_even_numbers(numbers: list[int]):
    for number in numbers:
        if number % 2 == 0:
            yield number
```

Calling it does not execute the whole function immediately:

```python
even_numbers = iter_even_numbers([1, 2, 3, 4])
```

Instead, it creates a generator object. Work happens later:

```python
print(next(even_numbers))  # 2
print(next(even_numbers))  # 4
```

This makes generators memory-efficient for large or endless streams.

---

## Generator Expressions

A generator expression is the lazy counterpart to a list comprehension.

List comprehension:

```python
titles = [item.title for item in library]
```

Generator expression:

```python
titles = (item.title for item in library)
```

The list creates every title immediately.

The generator produces titles one at a time.

For functions such as `any()`, `all()`, `sum()`, `min()`, and `max()`, pass a generator expression directly:

```python
has_available_items = any(
    not item.is_checked_out
    for item in library
)
```

The outer parentheses are optional when the generator expression is the only function argument:

```python
has_available_items = any(
    not item.is_checked_out
    for item in library
)
```

---

## Iterator Consumption

Generators and iterators are generally consumed once.

```python
results = library.search_title("python")

print(list(results))
print(list(results))
```

The first `list(results)` contains the search results. The second is empty because the generator has already reached the end.

If you need to process results multiple times, create a new generator or materialize the data intentionally:

```python
results = list(library.search_title("python"))

print(results)
print(results)
```

Use a list only when holding all values in memory is acceptable and repeated access is needed.

---

## `itertools` Quick Reference

### `islice`

Take a limited portion of an iterable:

```python
from itertools import islice

first_three = islice(library, 3)
```

Unlike list slicing, `islice()` can work with any iterable, including generators.

### `chain`

Combine iterables:

```python
from itertools import chain

all_items = chain(north_library, south_library)
```

### `filterfalse`

Keep values for which a predicate returns false:

```python
from itertools import filterfalse

available_items = filterfalse(
    lambda item: item.is_checked_out,
    library,
)
```

Use a named function instead of a lambda if the condition has meaningful complexity.

---

## Context Manager Protocol

A class-based context manager defines:

```python
def __enter__(self):
    ...

def __exit__(self, exception_type, exception_value, traceback):
    ...
```

Python transforms:

```python
with CatalogSnapshotWriter("output.txt") as writer:
    writer.write_library(library)
```

into behavior conceptually similar to:

```python
writer = CatalogSnapshotWriter("output.txt")
entered_writer = writer.__enter__()

try:
    entered_writer.write_library(library)
except BaseException as error:
    suppress_error = writer.__exit__(
        type(error),
        error,
        error.__traceback__,
    )

    if not suppress_error:
        raise
else:
    writer.__exit__(None, None, None)
```

You do not need to write this expanded form in real code. The `with` statement exists so cleanup behavior is explicit, reliable, and concise.

---

## `pathlib.Path`

We used `pathlib.Path` instead of manually joining strings:

```python
destination = Path("output") / "catalog_snapshot.txt"
```

This is safer and more readable than:

```python
destination = "output/catalog_snapshot.txt"
```

or platform-specific alternatives involving backslashes.

`Path` handles platform differences correctly.

Useful methods include:

```python
path.exists()
path.mkdir(parents=True, exist_ok=True)
path.read_text(encoding="utf-8")
path.write_text("content", encoding="utf-8")
path.open(mode="w", encoding="utf-8")
```

---

## When to Use Which Tool

| Need | Best default tool |
|---|---|
| You need every result now and will reuse it | `list` |
| You want to transform/filter a small collection clearly | Comprehension |
| You want results one at a time | Generator |
| You need custom stateful iteration behavior | Iterator class |
| You need reliable setup and cleanup | Context manager with `with` |
| You need a bounded stream history | `deque(maxlen=...)` |
| You need to process huge or external datasets | Generator / iterator |

The goal is not to use generators everywhere. The goal is to choose the simplest structure that matches the amount of data, the cost of processing it, and how callers need to consume it.
