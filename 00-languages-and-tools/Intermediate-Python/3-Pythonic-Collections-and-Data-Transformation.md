# Part 3: Pythonic Collections and Data Transformation

So far, our library application can model different lending items and manage them in a catalog.

Now we will focus on a common real-world programming task:

> Take a collection of raw data, filter it, transform it, group it, count it, and present useful results.

This is especially relevant to the future API-client capstone. APIs commonly return JSON data shaped like lists and dictionaries. Python gives us expressive tools for turning that raw data into useful application data.

In this part, we will use:

- List comprehensions
- Dictionary comprehensions
- Set comprehensions
- `collections.Counter`
- `collections.defaultdict`
- `collections.deque`
- Sorting with `sorted()`
- Built-in functions such as `any()` and `all()`

We will extend the existing library package with a reporting service.

---

## What You Will Build

At the end of this part, the project will include:

```text
pythonic-craftsmanship/
├── src/
│   └── library/
│       ├── __init__.py
│       ├── book.py
│       ├── catalog.py
│       ├── digital_book.py
│       ├── lending_item.py
│       └── reports.py
└── examples/
    └── part_3_demo.py
```

The new `reports.py` module will generate useful catalog reports:

- Titles of available items
- A lookup dictionary indexed by title
- Distinct authors in the catalog
- Item counts by concrete item type
- Items grouped by author
- Recently added activity entries
- Availability checks across the catalog

---

# Step 1: Understand the Problem Before Using Comprehensions

## The Target

We are not creating a file yet. We are defining the data-transformation problem that the new `reports.py` module will solve.

## The Concept

A catalog holds objects:

```python
Book(...)
DigitalBook(...)
```

But a report usually needs a simpler result, such as:

```python
[
    "Clean Code by Robert C. Martin",
    "Python for Data Analysis by Wes McKinney (digital)",
]
```

There are two broad operations:

1. **Filtering**: keep only values that match a rule.
2. **Transformation**: convert each value into another form.

For example:

```text
All catalog items
    ↓ filter: currently available
Available catalog items
    ↓ transform: convert each object to display text
List of display strings
```

A traditional loop is perfectly valid:

```python
available_titles: list[str] = []

for item in library:
    if not item.is_checked_out:
        available_titles.append(str(item))
```

A list comprehension expresses the same pattern more compactly:

```python
available_titles = [
    str(item)
    for item in library
    if not item.is_checked_out
]
```

Read it from left to right:

> Create `str(item)` for every `item` in `library`, but only if the item is not checked out.

Comprehensions are helpful when the operation remains easy to read. If the logic becomes deeply nested or needs several statements, use a regular loop or a named helper function instead.

## The Implementation

Create a small scratch example.

### `examples/part_3_comprehension_preview.py`

```python
"""Preview the collection transformations used in Part 3."""

from library import Book, DigitalBook, Library


def main() -> None:
    """Create a mixed catalog and transform its contents."""
    library = Library(name="Preview Library")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="978-0132350884",
            shelf_location="A-12",
        )
    )
    library.add_item(
        DigitalBook(
            title="Python for Data Analysis",
            author="Wes McKinney",
            identifier="EBOOK-001",
            download_url="https://library.example/downloads/python-data-analysis",
            license_limit=2,
        )
    )

    library.check_out_item("978-0132350884")

    available_titles_with_loop: list[str] = []

    for item in library:
        if not item.is_checked_out:
            available_titles_with_loop.append(str(item))

    available_titles_with_comprehension = [
        str(item)
        for item in library
        if not item.is_checked_out
    ]

    print("Loop result:")
    print(available_titles_with_loop)

    print("\nComprehension result:")
    print(available_titles_with_comprehension)


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_3_comprehension_preview.py
```

Expected output:

```text
Loop result:
['Python for Data Analysis by Wes McKinney (digital)']

Comprehension result:
['Python for Data Analysis by Wes McKinney (digital)']
```

Both forms are correct. The comprehension is shorter because the work is a simple “filter and transform” operation.

---

# Step 2: Build a Reporting Service with List Comprehensions

## The Target

We are creating:

```text
src/library/reports.py
```

The first report will return display strings for all items currently available for checkout.

## The Concept

A reporting service should not own the catalog or change lending state. Its job is to inspect information and produce a useful view of it.

This is another example of separation of concerns:

| Component | Responsibility |
|---|---|
| `Book` / `DigitalBook` | Represent individual items and their lending rules |
| `Library` | Store and find catalog items |
| `CatalogReports` | Read catalog data and generate summaries |

Think of the `Library` as a warehouse and `CatalogReports` as the analyst who reads inventory records and prepares a report. The analyst does not move products around; they interpret what is already there.

## The Implementation

Create the reporting module.

### `src/library/reports.py`

```python
"""Reporting helpers for library catalog data."""

from __future__ import annotations

from library.catalog import Library


class CatalogReports:
    """Generate read-only reports from a Library catalog."""

    def __init__(self, library: Library) -> None:
        """Store the catalog that this report service reads from.

        Args:
            library: The Library whose items should be analyzed.
        """
        self._library = library

    def available_item_descriptions(self) -> list[str]:
        """Return display descriptions for every currently available item.

        A list comprehension is a clear fit here because the operation has one
        filter condition and one simple transformation.
        """
        return [
            str(item)
            for item in self._library
            if not item.is_checked_out
        ]

    def checked_out_item_descriptions(self) -> list[str]:
        """Return display descriptions for every unavailable item."""
        return [
            str(item)
            for item in self._library
            if item.is_checked_out
        ]

    def available_item_identifiers(self) -> list[str]:
        """Return identifiers for items that can currently be checked out."""
        return [
            item.identifier
            for item in self._library
            if not item.is_checked_out
        ]
```

Expose the report class through the package’s public interface.

### `src/library/__init__.py`

```python
"""A small library domain package used in the OOP tutorial modules."""

from library.book import Book
from library.catalog import Library
from library.digital_book import DigitalBook
from library.lending_item import LendingItem
from library.reports import CatalogReports

__all__ = ["Book", "CatalogReports", "DigitalBook", "LendingItem", "Library"]
```

Create a demonstration file.

### `examples/part_3_demo.py`

```python
"""Demonstrate Pythonic collection processing with a library catalog."""

from library import Book, CatalogReports, DigitalBook, Library


def build_demo_library() -> Library:
    """Create a catalog with physical and digital lending items."""
    library = Library(name="City Library")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="978-0132350884",
            shelf_location="A-12",
        )
    )
    library.add_item(
        Book(
            title="The Pragmatic Programmer",
            author="David Thomas and Andrew Hunt",
            isbn="978-0135957059",
            shelf_location="A-15",
        )
    )
    library.add_item(
        DigitalBook(
            title="Python for Data Analysis",
            author="Wes McKinney",
            identifier="EBOOK-001",
            download_url="https://library.example/downloads/python-data-analysis",
            license_limit=2,
        )
    )

    library.check_out_item("978-0132350884")
    library.check_out_item("EBOOK-001")

    return library


def main() -> None:
    """Print list-comprehension based reports."""
    library = build_demo_library()
    reports = CatalogReports(library)

    print("Available item descriptions:")
    for description in reports.available_item_descriptions():
        print(f"- {description}")

    print("\nChecked-out item descriptions:")
    for description in reports.checked_out_item_descriptions():
        print(f"- {description}")

    print("\nAvailable item identifiers:")
    for identifier in reports.available_item_identifiers():
        print(f"- {identifier}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_3_demo.py
```

Expected output:

```text
Available item descriptions:
- The Pragmatic Programmer by David Thomas and Andrew Hunt
- Python for Data Analysis by Wes McKinney (digital)

Checked-out item descriptions:
- Clean Code by Robert C. Martin

Available item identifiers:
- 978-0135957059
- EBOOK-001
```

The digital book remains available after one checkout because it has two licenses and only one active loan.

---

# Step 3: Add Dictionary and Set Comprehensions

## The Target

We are extending:

```text
src/library/reports.py
```

We will add:

- A title-indexed lookup dictionary.
- A set of distinct author names.

## The Concept

A list is useful when order matters and duplicate values are allowed.

A dictionary is useful when you need fast lookup by a key.

A set is useful when you only care about unique values.

Imagine a librarian answering these questions:

| Question | Appropriate structure |
|---|---|
| “Show every available item.” | List |
| “Find the item named *Clean Code*.” | Dictionary |
| “Which authors appear in the catalog?” | Set |

### Dictionary comprehension

A dictionary comprehension has this form:

```python
{
    key_expression: value_expression
    for value in collection
}
```

Example:

```python
items_by_identifier = {
    item.identifier: item
    for item in library
}
```

### Set comprehension

A set comprehension has this form:

```python
{
    expression
    for value in collection
}
```

Example:

```python
authors = {
    item.author
    for item in library
}
```

Our base `LendingItem` does not require an `author` attribute, even though `Book` and `DigitalBook` currently have one. To keep the report service safe for future `LendingItem` subclasses, we will use `getattr()`.

`getattr(object, "name", default)` means:

> Get the `name` attribute if it exists; otherwise use `default`.

## The Implementation

Replace `src/library/reports.py` with the following complete file.

### `src/library/reports.py`

```python
"""Reporting helpers for library catalog data."""

from __future__ import annotations

from library.catalog import Library
from library.lending_item import LendingItem


class CatalogReports:
    """Generate read-only reports from a Library catalog."""

    def __init__(self, library: Library) -> None:
        """Store the catalog that this report service reads from."""
        self._library = library

    def available_item_descriptions(self) -> list[str]:
        """Return display descriptions for every currently available item."""
        return [
            str(item)
            for item in self._library
            if not item.is_checked_out
        ]

    def checked_out_item_descriptions(self) -> list[str]:
        """Return display descriptions for every unavailable item."""
        return [
            str(item)
            for item in self._library
            if item.is_checked_out
        ]

    def available_item_identifiers(self) -> list[str]:
        """Return identifiers for items that can currently be checked out."""
        return [
            item.identifier
            for item in self._library
            if not item.is_checked_out
        ]

    def items_by_title(self) -> dict[str, LendingItem]:
        """Return a title-to-item lookup dictionary.

        Raises:
            ValueError: If multiple catalog items share the same title.

        Titles are convenient for people but are not stable unique identifiers.
        This report explicitly rejects duplicates rather than silently replacing
        one item with another in the resulting dictionary.
        """
        items_by_title: dict[str, LendingItem] = {}

        for item in self._library:
            if item.title in items_by_title:
                raise ValueError(
                    f'Cannot create title lookup: duplicate title "{item.title}".'
                )

            items_by_title[item.title] = item

        return items_by_title

    def distinct_authors(self) -> set[str]:
        """Return non-blank author names found on catalog items.

        getattr() keeps this report compatible with future LendingItem
        subclasses that may not have an author attribute.
        """
        return {
            author.strip()
            for item in self._library
            for author in [getattr(item, "author", "")]
            if isinstance(author, str) and author.strip()
        }
```

The `distinct_authors()` comprehension has two `for` clauses. The inner clause:

```python
for author in [getattr(item, "author", "")]
```

creates a one-value sequence so the `author` value can be cleaned and filtered within the comprehension.

This is valid, but it is close to the point where a normal loop might be easier to read. We will revisit readability guidelines in the reference section.

Update the demonstration file.

### `examples/part_3_demo.py`

```python
"""Demonstrate Pythonic collection processing with a library catalog."""

from library import Book, CatalogReports, DigitalBook, Library


def build_demo_library() -> Library:
    """Create a catalog with physical and digital lending items."""
    library = Library(name="City Library")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="978-0132350884",
            shelf_location="A-12",
        )
    )
    library.add_item(
        Book(
            title="The Pragmatic Programmer",
            author="David Thomas and Andrew Hunt",
            isbn="978-0135957059",
            shelf_location="A-15",
        )
    )
    library.add_item(
        DigitalBook(
            title="Python for Data Analysis",
            author="Wes McKinney",
            identifier="EBOOK-001",
            download_url="https://library.example/downloads/python-data-analysis",
            license_limit=2,
        )
    )

    library.check_out_item("978-0132350884")
    library.check_out_item("EBOOK-001")

    return library


def main() -> None:
    """Print reports based on lists, dictionaries, and sets."""
    library = build_demo_library()
    reports = CatalogReports(library)

    print("Available item descriptions:")
    for description in reports.available_item_descriptions():
        print(f"- {description}")

    print("\nItems by title:")
    for title, item in reports.items_by_title().items():
        print(f'- "{title}" maps to identifier {item.identifier}')

    print("\nDistinct authors:")
    for author in sorted(reports.distinct_authors()):
        print(f"- {author}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_3_demo.py
```

Expected output:

```text
Available item descriptions:
- The Pragmatic Programmer by David Thomas and Andrew Hunt
- Python for Data Analysis by Wes McKinney (digital)

Items by title:
- "Clean Code" maps to identifier 978-0132350884
- "The Pragmatic Programmer" maps to identifier 978-0135957059
- "Python for Data Analysis" maps to identifier EBOOK-001

Distinct authors:
- David Thomas and Andrew Hunt
- Robert C. Martin
- Wes McKinney
```

The set itself does not guarantee a predictable display order. That is why the example uses:

```python
sorted(reports.distinct_authors())
```

before printing authors.

---

# Step 4: Count and Group Data with `Counter` and `defaultdict`

## The Target

We are extending:

```text
src/library/reports.py
```

We will add two standard-library-based reports:

- Item counts by concrete type, using `collections.Counter`.
- Items grouped by author, using `collections.defaultdict`.

## The Concept

The Python standard library is the toolbox that ships with Python. Before installing a third-party package, check whether the standard library already provides the behavior you need.

### `Counter`

A `Counter` counts repeated values.

For example:

```python
from collections import Counter

Counter(["Book", "Book", "DigitalBook"])
```

produces a mapping conceptually like:

```python
{
    "Book": 2,
    "DigitalBook": 1,
}
```

A `Counter` is excellent for questions like:

- How many items of each type are in the catalog?
- Which author has the most items?
- How many loans were made per day?

### `defaultdict`

A `defaultdict` is a dictionary that automatically creates a default value for missing keys.

Without `defaultdict`, grouping often looks like:

```python
items_by_author: dict[str, list[LendingItem]] = {}

for item in library:
    if item.author not in items_by_author:
        items_by_author[item.author] = []

    items_by_author[item.author].append(item)
```

With `defaultdict(list)`, Python creates an empty list automatically the first time it sees a new author:

```python
items_by_author = defaultdict(list)

for item in library:
    items_by_author[item.author].append(item)
```

It is like giving every new author their own empty folder automatically when the first item is filed.

## The Implementation

Replace `src/library/reports.py` with the following file.

### `src/library/reports.py`

```python
"""Reporting helpers for library catalog data."""

from __future__ import annotations

from collections import Counter, defaultdict

from library.catalog import Library
from library.lending_item import LendingItem


class CatalogReports:
    """Generate read-only reports from a Library catalog."""

    def __init__(self, library: Library) -> None:
        """Store the catalog that this report service reads from."""
        self._library = library

    def available_item_descriptions(self) -> list[str]:
        """Return display descriptions for every currently available item."""
        return [
            str(item)
            for item in self._library
            if not item.is_checked_out
        ]

    def checked_out_item_descriptions(self) -> list[str]:
        """Return display descriptions for every unavailable item."""
        return [
            str(item)
            for item in self._library
            if item.is_checked_out
        ]

    def available_item_identifiers(self) -> list[str]:
        """Return identifiers for items that can currently be checked out."""
        return [
            item.identifier
            for item in self._library
            if not item.is_checked_out
        ]

    def items_by_title(self) -> dict[str, LendingItem]:
        """Return a title-to-item lookup dictionary.

        Raises:
            ValueError: If multiple catalog items share the same title.
        """
        items_by_title: dict[str, LendingItem] = {}

        for item in self._library:
            if item.title in items_by_title:
                raise ValueError(
                    f'Cannot create title lookup: duplicate title "{item.title}".'
                )

            items_by_title[item.title] = item

        return items_by_title

    def distinct_authors(self) -> set[str]:
        """Return non-blank author names found on catalog items."""
        return {
            author.strip()
            for item in self._library
            for author in [getattr(item, "author", "")]
            if isinstance(author, str) and author.strip()
        }

    def item_count_by_type(self) -> Counter[str]:
        """Return the number of catalog items for each concrete class name."""
        return Counter(type(item).__name__ for item in self._library)

    def items_by_author(self) -> dict[str, list[LendingItem]]:
        """Group catalog items by author name.

        Items without a usable author attribute are grouped under
        "Unknown author" so that no catalog item is silently omitted.
        """
        grouped_items: defaultdict[str, list[LendingItem]] = defaultdict(list)

        for item in self._library:
            raw_author = getattr(item, "author", "Unknown author")

            if isinstance(raw_author, str) and raw_author.strip():
                author = raw_author.strip()
            else:
                author = "Unknown author"

            grouped_items[author].append(item)

        # Returning a standard dict prevents callers from accidentally relying
        # on defaultdict's auto-creation behavior outside this report method.
        return dict(grouped_items)
```

Update the example.

### `examples/part_3_demo.py`

```python
"""Demonstrate Pythonic collection processing with a library catalog."""

from library import Book, CatalogReports, DigitalBook, Library


def build_demo_library() -> Library:
    """Create a catalog with physical and digital lending items."""
    library = Library(name="City Library")

    library.add_item(
        Book(
            title="Clean Code",
            author="Robert C. Martin",
            isbn="978-0132350884",
            shelf_location="A-12",
        )
    )
    library.add_item(
        Book(
            title="The Clean Coder",
            author="Robert C. Martin",
            isbn="978-0137081073",
            shelf_location="A-13",
        )
    )
    library.add_item(
        Book(
            title="The Pragmatic Programmer",
            author="David Thomas and Andrew Hunt",
            isbn="978-0135957059",
            shelf_location="A-15",
        )
    )
    library.add_item(
        DigitalBook(
            title="Python for Data Analysis",
            author="Wes McKinney",
            identifier="EBOOK-001",
            download_url="https://library.example/downloads/python-data-analysis",
            license_limit=2,
        )
    )

    library.check_out_item("978-0132350884")
    library.check_out_item("EBOOK-001")

    return library


def main() -> None:
    """Print reports built with comprehensions and collection helpers."""
    library = build_demo_library()
    reports = CatalogReports(library)

    print("Item count by type:")
    for item_type, count in sorted(reports.item_count_by_type().items()):
        print(f"- {item_type}: {count}")

    print("\nItems grouped by author:")
    for author, items in sorted(reports.items_by_author().items()):
        descriptions = ", ".join(str(item) for item in items)
        print(f"- {author}: {descriptions}")

    print("\nAvailable item descriptions:")
    for description in reports.available_item_descriptions():
        print(f"- {description}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_3_demo.py
```

Expected output:

```text
Item count by type:
- Book: 3
- DigitalBook: 1

Items grouped by author:
- David Thomas and Andrew Hunt: The Pragmatic Programmer by David Thomas and Andrew Hunt
- Robert C. Martin: Clean Code by Robert C. Martin, The Clean Coder by Robert C. Martin
- Wes McKinney: Python for Data Analysis by Wes McKinney (digital)

Available item descriptions:
- The Clean Coder by Robert C. Martin
- The Pragmatic Programmer by David Thomas and Andrew Hunt
- Python for Data Analysis by Wes McKinney (digital)
```

---

# Step 5: Track Recent Activity with `deque`

## The Target

We are adding a new class to:

```text
src/library/catalog.py
```

The `Library` will record recent checkout and return activity in a bounded history.

## The Concept

A regular list is good for many tasks, but removing the first element of a large list can be inefficient because every remaining element must shift one position.

A `deque`, pronounced “deck,” means **double-ended queue**.

It efficiently adds and removes elements from both ends.

```python
from collections import deque
```

Think of a `deque` as a line of people with doors at both the front and back.

For activity history, we want:

- New events added at the end.
- Oldest events automatically discarded after a fixed limit.

A bounded deque does that directly:

```python
deque(maxlen=100)
```

Once it reaches 100 entries, adding a new entry removes the oldest one automatically.

This is useful for logs, recent searches, recently viewed items, message history, and rate-limiting windows.

## The Implementation

Replace `src/library/catalog.py` with this complete version.

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections import deque
from collections.abc import Iterator
from datetime import UTC, datetime

from library.lending_item import LendingItem


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

        # maxlen automatically discards the oldest event when the queue is full.
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
        """Return an immutable snapshot of recent catalog activity.

        A tuple prevents callers from changing Library's internal history.
        """
        return tuple(self._recent_activity)
```

Create an activity-specific demonstration.

### `examples/part_3_deque_demo.py`

```python
"""Demonstrate bounded recent activity tracking with collections.deque."""

from library import Book, Library


def main() -> None:
    """Show that a bounded deque retains only the newest activity entries."""
    library = Library(name="Activity Demo Library", activity_history_limit=3)

    library.add_item(
        Book(
            title="First Book",
            author="Author One",
            isbn="BOOK-001",
            shelf_location="A-01",
        )
    )
    library.add_item(
        Book(
            title="Second Book",
            author="Author Two",
            isbn="BOOK-002",
            shelf_location="A-02",
        )
    )
    library.check_out_item("BOOK-001")
    library.return_item("BOOK-001")

    print("Recent activity entries:")
    for event in library.recent_activity():
        print(event)


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_3_deque_demo.py
```

You will see timestamps that depend on the current time. The important behavior is that only **three** entries remain:

```text
Recent activity entries:
2026-... | Added item "BOOK-002".
2026-... | Checked out item "BOOK-001".
2026-... | Returned item "BOOK-001".
```

The first `Added item "BOOK-001".` event is no longer present because the history limit was `3`.

---

# Step 6: Use `any()` and `all()` for Clear Collection-Wide Questions

## The Target

We are extending:

```text
src/library/reports.py
```

We will add methods that answer collection-wide yes/no questions:

- Does the library have any available items?
- Are all items currently available?
- Does the library contain any digital item with all licenses used?

## The Concept

Two built-in functions make collection-wide conditions very readable:

### `any()`

`any()` returns `True` if at least one value is truthy.

```python
any(item.is_checked_out for item in library)
```

Read it as:

> Is any item checked out?

### `all()`

`all()` returns `True` only if every value is truthy.

```python
all(not item.is_checked_out for item in library)
```

Read it as:

> Is every item not checked out?

These functions work especially well with **generator expressions**, which use parentheses rather than square brackets:

```python
any(item.is_checked_out for item in library)
```

We will study generators in depth in the next part. For now, the key benefit is that `any()` and `all()` can stop early:

- `any()` stops as soon as it finds one true value.
- `all()` stops as soon as it finds one false value.

They do not need to build a complete list first.

## The Implementation

Replace `src/library/reports.py` with the complete file below.

### `src/library/reports.py`

```python
"""Reporting helpers for library catalog data."""

from __future__ import annotations

from collections import Counter, defaultdict

from library.catalog import Library
from library.digital_book import DigitalBook
from library.lending_item import LendingItem


class CatalogReports:
    """Generate read-only reports from a Library catalog."""

    def __init__(self, library: Library) -> None:
        """Store the catalog that this report service reads from."""
        self._library = library

    def available_item_descriptions(self) -> list[str]:
        """Return display descriptions for every currently available item."""
        return [
            str(item)
            for item in self._library
            if not item.is_checked_out
        ]

    def checked_out_item_descriptions(self) -> list[str]:
        """Return display descriptions for every unavailable item."""
        return [
            str(item)
            for item in self._library
            if item.is_checked_out
        ]

    def available_item_identifiers(self) -> list[str]:
        """Return identifiers for items that can currently be checked out."""
        return [
            item.identifier
            for item in self._library
            if not item.is_checked_out
        ]

    def items_by_title(self) -> dict[str, LendingItem]:
        """Return a title-to-item lookup dictionary.

        Raises:
            ValueError: If multiple catalog items share the same title.
        """
        items_by_title: dict[str, LendingItem] = {}

        for item in self._library:
            if item.title in items_by_title:
                raise ValueError(
                    f'Cannot create title lookup: duplicate title "{item.title}".'
                )

            items_by_title[item.title] = item

        return items_by_title

    def distinct_authors(self) -> set[str]:
        """Return non-blank author names found on catalog items."""
        return {
            author.strip()
            for item in self._library
            for author in [getattr(item, "author", "")]
            if isinstance(author, str) and author.strip()
        }

    def item_count_by_type(self) -> Counter[str]:
        """Return the number of catalog items for each concrete class name."""
        return Counter(type(item).__name__ for item in self._library)

    def items_by_author(self) -> dict[str, list[LendingItem]]:
        """Group catalog items by author name."""
        grouped_items: defaultdict[str, list[LendingItem]] = defaultdict(list)

        for item in self._library:
            raw_author = getattr(item, "author", "Unknown author")

            if isinstance(raw_author, str) and raw_author.strip():
                author = raw_author.strip()
            else:
                author = "Unknown author"

            grouped_items[author].append(item)

        return dict(grouped_items)

    def has_available_items(self) -> bool:
        """Return whether at least one catalog item is available."""
        return any(not item.is_checked_out for item in self._library)

    def are_all_items_available(self) -> bool:
        """Return whether every catalog item is available.

        For an empty catalog, all() returns True because there is no unavailable
        item that could disprove the statement. This is known as vacuous truth.
        """
        return all(not item.is_checked_out for item in self._library)

    def has_fully_loaned_digital_book(self) -> bool:
        """Return whether any digital book has exhausted its license pool."""
        return any(
            isinstance(item, DigitalBook) and item.is_checked_out
            for item in self._library
        )
```

Create a small verification script.

### `examples/part_3_any_all_demo.py`

```python
"""Demonstrate any() and all() with library reports."""

from library import Book, CatalogReports, DigitalBook, Library


def main() -> None:
    """Ask collection-wide availability questions."""
    library = Library(name="Availability Demo")

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

    reports = CatalogReports(library)

    print(f"Has available items: {reports.has_available_items()}")
    print(f"Are all items available: {reports.are_all_items_available()}")
    print(
        "Has a fully loaned digital book: "
        f"{reports.has_fully_loaned_digital_book()}"
    )

    library.check_out_item("BOOK-001")
    library.check_out_item("EBOOK-001")

    print("\nAfter checking out both items:")
    print(f"Has available items: {reports.has_available_items()}")
    print(f"Are all items available: {reports.are_all_items_available()}")
    print(
        "Has a fully loaned digital book: "
        f"{reports.has_fully_loaned_digital_book()}"
    )


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_3_any_all_demo.py
```

Expected output:

```text
Has available items: True
Are all items available: True
Has a fully loaned digital book: False

After checking out both items:
Has available items: False
Are all items available: False
Has a fully loaned digital book: True
```

---

# Part 3 Reference: Pythonic Collection Tools

## List Comprehensions

Use a list comprehension when you want a list built from an iterable.

```python
titles = [item.title for item in library]
```

Filter values with `if`:

```python
available_titles = [
    item.title
    for item in library
    if not item.is_checked_out
]
```

Equivalent loop:

```python
available_titles: list[str] = []

for item in library:
    if not item.is_checked_out:
        available_titles.append(item.title)
```

Both are valid. Prefer the version that remains easiest to understand.

---

## Dictionary Comprehensions

Use a dictionary comprehension when each input value becomes a key-value pair.

```python
items_by_identifier = {
    item.identifier: item
    for item in library
}
```

Be careful with duplicate keys. The last value silently wins:

```python
{
    "same-key": "first",
    "same-key": "second",
}
```

Result:

```python
{"same-key": "second"}
```

When duplicates would indicate bad data, validate them explicitly as `items_by_title()` does.

---

## Set Comprehensions

Use a set comprehension to keep unique values.

```python
authors = {
    item.author
    for item in library
}
```

Sets:

- Remove duplicates automatically.
- Do not preserve insertion order as a public contract for your business logic.
- Require values to be hashable.

For display, sort the result:

```python
for author in sorted(authors):
    print(author)
```

---

## `Counter`

`Counter` is a dictionary-like collection designed for counting.

```python
from collections import Counter

counts = Counter(["Book", "Book", "DigitalBook"])
print(counts)
```

Typical output:

```text
Counter({'Book': 2, 'DigitalBook': 1})
```

Useful methods include:

```python
counts.most_common()
counts.most_common(1)
```

Example:

```python
print(counts.most_common(1))
```

Output:

```text
[('Book', 2)]
```

---

## `defaultdict`

A `defaultdict` provides a default value for missing keys.

```python
from collections import defaultdict

items_by_author: defaultdict[str, list[str]] = defaultdict(list)
items_by_author["Wes McKinney"].append("Python for Data Analysis")
```

Without `defaultdict`, you would need to initialize the list manually.

Use it internally when grouping data, but consider returning a normal `dict` from public methods. Doing so keeps the public API simple and prevents callers from accidentally creating new entries merely by reading a missing key.

---

## `deque`

A `deque` is optimized for adding and removing from both ends.

```python
from collections import deque

recent_events = deque(maxlen=3)
recent_events.append("first")
recent_events.append("second")
recent_events.append("third")
recent_events.append("fourth")

print(recent_events)
```

Output:

```text
deque(['second', 'third', 'fourth'], maxlen=3)
```

Use a `deque` for:

- Recent activity histories
- Queues
- Breadth-first search
- Sliding windows
- Rate-limiting event history

---

## `any()` and `all()`

Use `any()` when one matching value is enough:

```python
has_checked_out_item = any(
    item.is_checked_out
    for item in library
)
```

Use `all()` when every value must match:

```python
all_available = all(
    not item.is_checked_out
    for item in library
)
```

### Empty Collections

These results can surprise beginners:

```python
any([])  # False
all([])  # True
```

Why is `all([])` true?

Because there is no false value in the empty collection. No item violates the condition.

If your business rule says an empty catalog should not count as “all available,” add an explicit length check:

```python
all_available = len(library) > 0 and all(
    not item.is_checked_out
    for item in library
)
```

---

## Readability Rule for Comprehensions

A comprehension is best when it tells a simple story:

```python
available_titles = [
    item.title
    for item in library
    if not item.is_checked_out
]
```

Use a normal loop when you need:

- Multiple independent statements
- Complex error handling
- Logging
- Several nested conditions
- Intermediate names that explain the logic

For example, this is clearer as a loop:

```python
items_by_title: dict[str, LendingItem] = {}

for item in library:
    if item.title in items_by_title:
        raise ValueError(f"Duplicate title: {item.title}")

    items_by_title[item.title] = item
```

Pythonic code is not “the shortest possible code.” It is code that communicates its intent clearly.
