# Part 2: Inheritance, Polymorphism, and Python Dunder Methods

In Part 1, we created `Book` and `Library` classes. Each class had a focused responsibility:

- `Book` represented one library book.
- `Library` managed a collection of books.

Now we will make the model more realistic.

Libraries do not lend only one kind of item. They may lend:

- Physical books
- E-books
- Audiobooks
- Magazines
- Equipment
- Digital courses

These items have shared behavior—they can be listed, checked out, and returned—but they may also have different rules.

For example:

- A physical book may have a shelf location.
- An e-book may have a download URL and a limited number of licenses.
- An audiobook may have a duration.

This is where **inheritance** and **polymorphism** become useful.

---

## What You Will Build in This Part

We will evolve the package from Part 1 into a more flexible lending model.

By the end of this part, the project will support:

```text
pythonic-craftsmanship/
├── src/
│   └── library/
│       ├── __init__.py
│       ├── book.py
│       ├── catalog.py
│       ├── lending_item.py
│       └── digital_book.py
└── examples/
    └── part_2_demo.py
```

The new architecture will include:

- A base `LendingItem` class for common lending behavior.
- A `Book` class that inherits from `LendingItem`.
- A `DigitalBook` class with license-aware checkout rules.
- Polymorphic catalog behavior: the `Library` can work with multiple item types through one shared interface.
- Dunder methods:
  - `__repr__`
  - `__str__`
  - `__eq__`
  - `__hash__`
  - `__len__`
  - `__iter__`
  - `__contains__`

---

# Step 1: Extract Shared Lending Behavior into a Base Class

## The Target

We are creating:

```text
src/library/lending_item.py
```

This file will contain a base class named `LendingItem`.

The base class will hold behavior shared by every item the library can lend:

- A unique identifier
- A title
- A checkout state
- Checkout and return methods
- String representations for people and developers

## The Concept

Inheritance is like designing a family of related tools.

Imagine a toolbox containing a hammer, screwdriver, and wrench:

- Each is different.
- Each has its own special purpose.
- But all are tools and share certain common qualities.

Likewise, a physical book and a digital book are different, but both are lending items.

Instead of copying this code into every class:

```python
def check_out(self) -> None:
    ...

def return_to_library(self) -> None:
    ...
```

we place shared behavior in one base class.

Then specialized classes inherit it.

```text
LendingItem
├── Book
└── DigitalBook
```

This avoids duplicated code and gives the catalog a shared interface to work with.

An **interface**, in this context, means the public methods and properties an object promises to provide.

Our shared interface will include:

```python
item.identifier
item.title
item.is_checked_out
item.check_out()
item.return_to_library()
item.status_message()
```

## The Implementation

Create the following file.

### `src/library/lending_item.py`

```python
"""Base domain model for items that a library can lend."""

from __future__ import annotations


class LendingItem:
    """Represent an item with a title, identifier, and lending state.

    This base class contains behavior shared by physical and digital library
    items. Specialized item types can inherit from it and add their own data
    or rules.
    """

    def __init__(self, identifier: str, title: str) -> None:
        """Create an item that is initially available.

        Args:
            identifier: A stable catalog identifier that uniquely identifies
                this item within the library.
            title: The human-readable title shown to library users.

        Raises:
            ValueError: If identifier or title is blank.
        """
        cleaned_identifier = identifier.strip()
        cleaned_title = title.strip()

        if not cleaned_identifier:
            raise ValueError("Item identifier cannot be blank.")

        if not cleaned_title:
            raise ValueError("Item title cannot be blank.")

        self.identifier = cleaned_identifier
        self.title = cleaned_title
        self._is_checked_out = False

    def __repr__(self) -> str:
        """Return a detailed representation intended for developers."""
        return (
            f"{type(self).__name__}("
            f"identifier={self.identifier!r}, "
            f"title={self.title!r}, "
            f"is_checked_out={self._is_checked_out!r}"
            f")"
        )

    def __str__(self) -> str:
        """Return a concise representation intended for library users."""
        return self.title

    @property
    def is_checked_out(self) -> bool:
        """Return whether this item is currently checked out."""
        return self._is_checked_out

    def check_out(self) -> None:
        """Mark this item as checked out.

        Raises:
            ValueError: If the item is already checked out.
        """
        if self._is_checked_out:
            raise ValueError(f'"{self.title}" is already checked out.')

        self._is_checked_out = True

    def return_to_library(self) -> None:
        """Mark this item as available again.

        Raises:
            ValueError: If the item is already available.
        """
        if not self._is_checked_out:
            raise ValueError(f'"{self.title}" is already in the library.')

        self._is_checked_out = False

    def status_message(self) -> str:
        """Return a human-friendly summary of this item's availability."""
        availability = "checked out" if self._is_checked_out else "available"

        return f'"{self.title}" is currently {availability}.'
```

## The Verification

Start a Python session:

```bash
python
```

Run the following code:

```python
from library.lending_item import LendingItem

item = LendingItem(identifier="ITEM-001", title="Library Orientation Guide")

print(item)
print(repr(item))
print(item.status_message())

item.check_out()
print(item.status_message())

item.return_to_library()
print(item.status_message())
```

Expected output:

```text
Library Orientation Guide
LendingItem(identifier='ITEM-001', title='Library Orientation Guide', is_checked_out=False)
"Library Orientation Guide" is currently available.
"Library Orientation Guide" is currently checked out.
"Library Orientation Guide" is currently available.
```

Exit the session:

```python
exit()
```

At this stage, `LendingItem` is usable on its own. In the next step, `Book` will inherit its common lending behavior from this class.

---

# Step 2: Refactor `Book` to Inherit from `LendingItem`

## The Target

We are replacing the current `Book` implementation in:

```text
src/library/book.py
```

The updated `Book` class will inherit from `LendingItem`.

A physical book will add information that only applies to physical books:

- `author`
- `isbn`
- `shelf_location`

## The Concept

A subclass is a more specialized version of a base class.

For example:

```python
class Book(LendingItem):
    ...
```

means:

> A `Book` is a kind of `LendingItem`.

Because a book is a lending item, it receives all public behavior from `LendingItem`:

```python
book.check_out()
book.return_to_library()
book.status_message()
book.is_checked_out
```

But `Book` also has physical-book-specific information:

```python
book.author
book.isbn
book.shelf_location
```

When a subclass defines its own `__init__`, it normally calls the base class constructor with `super()`:

```python
super().__init__(identifier=isbn, title=cleaned_title)
```

`super()` means: “Use the next implementation in this class hierarchy.”

Here, it lets `LendingItem` validate and initialize the shared `identifier`, `title`, and `_is_checked_out` attributes.

This prevents duplicate initialization logic.

## The Implementation

Replace the entire file.

### `src/library/book.py`

```python
"""Domain model for physical books in a library catalog."""

from __future__ import annotations

from library.lending_item import LendingItem


class Book(LendingItem):
    """Represent a physical book that can be borrowed from a library."""

    total_books_created = 0

    def __init__(
        self,
        title: str,
        author: str,
        isbn: str,
        shelf_location: str,
    ) -> None:
        """Create a physical book that is initially available.

        Args:
            title: The human-readable title of the book.
            author: The name of the book's author.
            isbn: The stable identifier for this book edition.
            shelf_location: The location where staff can find the book.

        Raises:
            ValueError: If author or shelf_location is blank. The base class
                also raises ValueError when title or ISBN is blank.
        """
        cleaned_author = author.strip()
        cleaned_shelf_location = shelf_location.strip()

        if not cleaned_author:
            raise ValueError("Book author cannot be blank.")

        if not cleaned_shelf_location:
            raise ValueError("Book shelf location cannot be blank.")

        # ISBN is both this physical book's ISBN and its catalog identifier.
        super().__init__(identifier=isbn, title=title)

        self.author = cleaned_author
        self.isbn = self.identifier
        self.shelf_location = cleaned_shelf_location

        type(self).total_books_created += 1

    def __repr__(self) -> str:
        """Return a detailed representation intended for developers."""
        return (
            f"Book("
            f"title={self.title!r}, "
            f"author={self.author!r}, "
            f"isbn={self.isbn!r}, "
            f"shelf_location={self.shelf_location!r}, "
            f"is_checked_out={self.is_checked_out!r}"
            f")"
        )

    def __str__(self) -> str:
        """Return a concise representation intended for library users."""
        return f"{self.title} by {self.author}"

    @classmethod
    def created_count(cls) -> int:
        """Return the number of Book instances created in this process."""
        return cls.total_books_created

    def status_message(self) -> str:
        """Return a user-friendly availability message for this physical book."""
        availability = "checked out" if self.is_checked_out else "available"

        return (
            f'"{self.title}" by {self.author} '
            f"(shelf: {self.shelf_location}) is currently {availability}."
        )
```

The `Book` constructor changed because physical books now require a shelf location. Update the package initializer so users can import the base class and the concrete book class from one place.

### `src/library/__init__.py`

```python
"""A small library domain package used in the OOP tutorial modules."""

from library.book import Book
from library.catalog import Library
from library.lending_item import LendingItem

__all__ = ["Book", "LendingItem", "Library"]
```

## The Verification

Run this command:

```bash
python -c "from library import Book, LendingItem; book = Book('Clean Code', 'Robert C. Martin', '978-0132350884', 'A-12'); print(isinstance(book, Book)); print(isinstance(book, LendingItem)); print(book); print(repr(book)); print(book.status_message())"
```

Expected output:

```text
True
True
Clean Code by Robert C. Martin
Book(title='Clean Code', author='Robert C. Martin', isbn='978-0132350884', shelf_location='A-12', is_checked_out=False)
"Clean Code" by Robert C. Martin (shelf: A-12) is currently available.
```

The two `True` values are important:

- The object is a `Book`.
- The same object is also a `LendingItem`.

That is the core meaning of inheritance.

---

# Step 3: Create a `DigitalBook` with Its Own Checkout Rules

## The Target

We are creating:

```text
src/library/digital_book.py
```

This class will represent a downloadable e-book.

Unlike a physical book, a digital book can be checked out by multiple readers at once, up to a configured license limit.

## The Concept

Inheritance does not mean every subclass must behave exactly like its parent.

A parent class provides shared defaults. A child class can **override** a method when it needs a more specific rule.

A physical book has one physical copy in our model:

```text
Available → Checked out → Available
```

A digital book has a pool of licenses:

```text
0 active loans / 3 licenses
1 active loan  / 3 licenses
2 active loans / 3 licenses
3 active loans / 3 licenses  ← no more checkouts allowed
```

This is an example of **polymorphism**.

Polymorphism means different object types can respond to the same operation in their own appropriate way.

Both objects can receive:

```python
item.check_out()
```

But:

- `Book.check_out()` uses the base class’s one-copy checkout behavior.
- `DigitalBook.check_out()` uses license-counting behavior.

The caller does not need to manually decide which algorithm to use. Python chooses the correct method based on the object’s type.

## The Implementation

Create the following file.

### `src/library/digital_book.py`

```python
"""Domain model for digital books with limited simultaneous licenses."""

from __future__ import annotations

from library.lending_item import LendingItem


class DigitalBook(LendingItem):
    """Represent a downloadable book with a limited number of licenses."""

    def __init__(
        self,
        title: str,
        author: str,
        identifier: str,
        download_url: str,
        license_limit: int,
    ) -> None:
        """Create a digital book with no active loans.

        Args:
            title: The human-readable title of the digital book.
            author: The name of the book's author.
            identifier: A stable catalog identifier for the digital edition.
            download_url: The HTTPS URL used to obtain the digital content.
            license_limit: The maximum number of simultaneous borrowers.

        Raises:
            ValueError: If author, URL, or license_limit is invalid. The base
                class also validates identifier and title.
        """
        cleaned_author = author.strip()
        cleaned_download_url = download_url.strip()

        if not cleaned_author:
            raise ValueError("Digital book author cannot be blank.")

        if not cleaned_download_url.startswith("https://"):
            raise ValueError("Digital book download URL must start with https://.")

        if license_limit < 1:
            raise ValueError("Digital book license limit must be at least 1.")

        super().__init__(identifier=identifier, title=title)

        self.author = cleaned_author
        self.download_url = cleaned_download_url
        self.license_limit = license_limit
        self._active_loans = 0

    def __repr__(self) -> str:
        """Return a detailed representation intended for developers."""
        return (
            f"DigitalBook("
            f"title={self.title!r}, "
            f"author={self.author!r}, "
            f"identifier={self.identifier!r}, "
            f"download_url={self.download_url!r}, "
            f"license_limit={self.license_limit!r}, "
            f"active_loans={self._active_loans!r}"
            f")"
        )

    def __str__(self) -> str:
        """Return a concise representation intended for library users."""
        return f"{self.title} by {self.author} (digital)"

    @property
    def active_loans(self) -> int:
        """Return the number of licenses currently in use."""
        return self._active_loans

    @property
    def available_license_count(self) -> int:
        """Return the number of licenses that can still be checked out."""
        return self.license_limit - self._active_loans

    @property
    def is_checked_out(self) -> bool:
        """Return whether every available digital license is currently in use.

        This property intentionally has a different meaning from the physical
        Book version. A digital book is considered unavailable only when all
        of its licenses have active loans.
        """
        return self._active_loans >= self.license_limit

    def check_out(self) -> None:
        """Use one available digital license.

        Raises:
            ValueError: If all licenses are already in use.
        """
        if self.is_checked_out:
            raise ValueError(
                f'All {self.license_limit} licenses for "{self.title}" are in use.'
            )

        self._active_loans += 1

    def return_to_library(self) -> None:
        """Release one active digital loan.

        Raises:
            ValueError: If the digital book has no active loans.
        """
        if self._active_loans == 0:
            raise ValueError(f'"{self.title}" has no active digital loans to return.')

        self._active_loans -= 1

    def status_message(self) -> str:
        """Return a user-friendly digital availability message."""
        if self.is_checked_out:
            return (
                f'"{self.title}" by {self.author} is unavailable: all '
                f"{self.license_limit} digital licenses are in use."
            )

        return (
            f'"{self.title}" by {self.author} has '
            f"{self.available_license_count} of {self.license_limit} "
            "digital licenses available."
        )
```

Update the package initializer.

### `src/library/__init__.py`

```python
"""A small library domain package used in the OOP tutorial modules."""

from library.book import Book
from library.catalog import Library
from library.digital_book import DigitalBook
from library.lending_item import LendingItem

__all__ = ["Book", "DigitalBook", "LendingItem", "Library"]
```

## The Verification

Run the following command:

```bash
python -c "from library import DigitalBook; book = DigitalBook('Python for Data Analysis', 'Wes McKinney', 'EBOOK-001', 'https://library.example/downloads/python-data-analysis', 2); print(book.status_message()); book.check_out(); print(book.status_message()); book.check_out(); print(book.status_message())"
```

Expected output:

```text
"Python for Data Analysis" by Wes McKinney has 2 of 2 digital licenses available.
"Python for Data Analysis" by Wes McKinney has 1 of 2 digital licenses available.
"Python for Data Analysis" by Wes McKinney is unavailable: all 2 digital licenses are in use.
```

Now verify that the license limit is enforced:

```bash
python -c "from library import DigitalBook; book = DigitalBook('Python for Data Analysis', 'Wes McKinney', 'EBOOK-001', 'https://library.example/downloads/python-data-analysis', 1); book.check_out(); book.check_out()"
```

Expected result:

```text
ValueError: All 1 licenses for "Python for Data Analysis" are in use.
```

---

# Step 4: Update the `Library` to Work with Any `LendingItem`

## The Target

We are replacing:

```text
src/library/catalog.py
```

The updated `Library` will accept any object that is a `LendingItem`, including both `Book` and `DigitalBook`.

We will also add dunder methods that make a `Library` feel natural to use in Python:

- `len(library)` calls `Library.__len__`
- `for item in library` calls `Library.__iter__`
- `"ISBN" in library` calls `Library.__contains__`

## The Concept

This is where polymorphism becomes especially valuable.

Suppose the catalog accepts a common base type:

```python
LendingItem
```

Then it can accept both:

```python
Book(...)
DigitalBook(...)
```

The catalog can call shared operations:

```python
item.check_out()
item.return_to_library()
item.status_message()
```

without asking:

```python
if type(item) is Book:
    ...
elif type(item) is DigitalBook:
    ...
```

Avoiding type-based branching is often cleaner because each class owns its own rules.

We are also adding more dunder methods.

Python provides built-in syntax for common actions:

```python
len(library)
for item in library:
    ...
"978-0132350884" in library
```

Dunder methods let our custom class participate in that syntax.

| Natural Python syntax | Method Python calls |
|---|---|
| `len(library)` | `library.__len__()` |
| `for item in library` | `library.__iter__()` |
| `"ISBN" in library` | `library.__contains__("ISBN")` |

This makes our class easier to learn because it behaves like familiar built-in collections.

## The Implementation

Replace the entire file.

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of lending items."""

from __future__ import annotations

from collections.abc import Iterator

from library.lending_item import LendingItem


class Library:
    """Manage a collection of lending items indexed by identifier."""

    def __init__(self, name: str) -> None:
        """Create an empty library catalog.

        Args:
            name: The public name of the library.

        Raises:
            ValueError: If name is blank.
        """
        cleaned_name = name.strip()

        if not cleaned_name:
            raise ValueError("Library name cannot be blank.")

        self.name = cleaned_name
        self._items_by_identifier: dict[str, LendingItem] = {}

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
        """Return whether an identifier exists in this catalog.

        The parameter is typed as object because Python may call `in` with any
        value. Values that are not strings are simply not valid identifiers.
        """
        return isinstance(identifier, str) and identifier in self._items_by_identifier

    def add_item(self, item: LendingItem) -> None:
        """Add a lending item to the catalog.

        Args:
            item: A Book, DigitalBook, or another LendingItem subclass.

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
        """Check out an item and return its updated object.

        Each concrete item class applies its own checkout rule. For example,
        Book marks one physical copy as unavailable, while DigitalBook uses a
        single available license.
        """
        item = self.find_item(identifier)
        item.check_out()

        return item

    def return_item(self, identifier: str) -> LendingItem:
        """Return an item and return its updated object."""
        item = self.find_item(identifier)
        item.return_to_library()

        return item
```

Notice that we renamed several methods:

| Part 1 method | Part 2 replacement | Why |
|---|---|---|
| `add_book` | `add_item` | The catalog now supports more than physical books. |
| `find_book` | `find_item` | The lookup can return any lending item. |
| `check_out_book` | `check_out_item` | The action works for all item types. |
| `return_book` | `return_item` | The action works for all item types. |
| `book_count` | `len(library)` | Python’s built-in `len()` is a natural collection interface. |

## The Verification

Run this command:

```bash
python -c "from library import Book, DigitalBook, Library; library = Library('City Library'); library.add_item(Book('Clean Code', 'Robert C. Martin', '978-0132350884', 'A-12')); library.add_item(DigitalBook('Python for Data Analysis', 'Wes McKinney', 'EBOOK-001', 'https://library.example/downloads/python-data-analysis', 2)); print(len(library)); print('978-0132350884' in library); print('MISSING' in library); [print(item) for item in library]"
```

Expected output:

```text
2
True
False
Clean Code by Robert C. Martin
Python for Data Analysis by Wes McKinney (digital)
```

The exact order reflects the order in which items were added.

You have now made `Library` behave like a Python collection:

- `len(library)` works.
- Iteration works.
- Membership checks work.

---

# Step 5: Define Equality with `__eq__` and Hashing with `__hash__`

## The Target

We are enhancing:

```text
src/library/lending_item.py
```

We will define how Python decides whether two lending items are equal.

Two items will be considered equal when:

1. They have the same concrete type.
2. They have the same catalog identifier.

We will also add `__hash__` so equal items can be stored safely in sets and used as dictionary keys.

## The Concept

Python’s default equality behavior compares object identity.

In other words, without `__eq__`, Python asks:

> Are these two variable names pointing to the exact same object in memory?

Example:

```python
first = Book("Clean Code", "Robert C. Martin", "978-0132350884", "A-12")
second = Book("Clean Code", "Robert C. Martin", "978-0132350884", "A-12")

print(first == second)
```

Without custom equality, this would be `False`, because Python created two separate objects.

But in our domain, two physical-book records with the same ISBN represent the same catalog item. It is useful to define equality based on the stable identifier.

A **hash** is an integer Python uses to organize values efficiently in hash-based collections:

- `set`
- `dict`

Python requires an important rule:

> If `a == b` is true, then `hash(a) == hash(b)` must also be true.

That is why we define both methods using the same identity information: the concrete type and identifier.

## The Implementation

Replace the entire file.

### `src/library/lending_item.py`

```python
"""Base domain model for items that a library can lend."""

from __future__ import annotations


class LendingItem:
    """Represent an item with a title, identifier, and lending state.

    This base class contains behavior shared by physical and digital library
    items. Specialized item types can inherit from it and add their own data
    or rules.
    """

    def __init__(self, identifier: str, title: str) -> None:
        """Create an item that is initially available.

        Args:
            identifier: A stable catalog identifier that uniquely identifies
                this item within the library.
            title: The human-readable title shown to library users.

        Raises:
            ValueError: If identifier or title is blank.
        """
        cleaned_identifier = identifier.strip()
        cleaned_title = title.strip()

        if not cleaned_identifier:
            raise ValueError("Item identifier cannot be blank.")

        if not cleaned_title:
            raise ValueError("Item title cannot be blank.")

        self.identifier = cleaned_identifier
        self.title = cleaned_title
        self._is_checked_out = False

    def __repr__(self) -> str:
        """Return a detailed representation intended for developers."""
        return (
            f"{type(self).__name__}("
            f"identifier={self.identifier!r}, "
            f"title={self.title!r}, "
            f"is_checked_out={self._is_checked_out!r}"
            f")"
        )

    def __str__(self) -> str:
        """Return a concise representation intended for library users."""
        return self.title

    def __eq__(self, other: object) -> bool:
        """Return whether two items represent the same catalog record.

        Items must have the same concrete type and identifier. A Book and a
        DigitalBook with the same text identifier are not considered equal,
        because they represent different kinds of catalog resources.
        """
        if not isinstance(other, LendingItem):
            return NotImplemented

        return type(self) is type(other) and self.identifier == other.identifier

    def __hash__(self) -> int:
        """Return a hash consistent with the equality definition."""
        return hash((type(self), self.identifier))

    @property
    def is_checked_out(self) -> bool:
        """Return whether this item is currently checked out."""
        return self._is_checked_out

    def check_out(self) -> None:
        """Mark this item as checked out.

        Raises:
            ValueError: If the item is already checked out.
        """
        if self._is_checked_out:
            raise ValueError(f'"{self.title}" is already checked out.')

        self._is_checked_out = True

    def return_to_library(self) -> None:
        """Mark this item as available again.

        Raises:
            ValueError: If the item is already available.
        """
        if not self._is_checked_out:
            raise ValueError(f'"{self.title}" is already in the library.')

        self._is_checked_out = False

    def status_message(self) -> str:
        """Return a human-friendly summary of this item's availability."""
        availability = "checked out" if self._is_checked_out else "available"

        return f'"{self.title}" is currently {availability}.'
```

No changes are required in `Book` or `DigitalBook`. They inherit these equality and hash rules.

## The Verification

Run:

```bash
python -c "from library import Book, DigitalBook; first = Book('Clean Code', 'Robert C. Martin', '978-0132350884', 'A-12'); second = Book('Clean Code: Second Record', 'Different Author Field', '978-0132350884', 'B-99'); ebook = DigitalBook('Clean Code', 'Robert C. Martin', '978-0132350884', 'https://library.example/downloads/clean-code', 3); print(first == second); print(first == ebook); print(len({first, second, ebook}))"
```

Expected output:

```text
True
False
2
```

Why is the set length `2`?

- `first` and `second` are both `Book` objects with the same ISBN, so they are equal.
- `ebook` has the same identifier text but is a `DigitalBook`, so it is not equal to a physical `Book`.

---

# Step 6: Build a Complete Polymorphism Demonstration

## The Target

We are creating:

```text
examples/part_2_demo.py
```

This script will demonstrate that one `Library` can manage physical and digital books without separate catalog code for each type.

## The Concept

A key sign of good polymorphic design is that high-level code can operate on a shared base type.

The library code calls:

```python
item.check_out()
```

It does not need to know whether `item` is:

```python
Book(...)
```

or:

```python
DigitalBook(...)
```

The object itself decides which implementation runs.

This resembles a universal charging station with different device adapters:

- The station follows one standard connection process.
- Each device handles its own internal electrical details.

The catalog uses the shared lending interface. Each item class handles its own lending rules.

## The Implementation

Create this complete example file.

### `examples/part_2_demo.py`

```python
"""Demonstrate inheritance, polymorphism, and dunder methods."""

from library import Book, DigitalBook, Library, LendingItem


def print_catalog_status(library: Library) -> None:
    """Print each item's status through the shared LendingItem interface."""
    print(f"\nCatalog status for {library}:")

    for item in library:
        # Book and DigitalBook both implement status_message(), either directly
        # or through inheritance from LendingItem.
        print(f"- {item.status_message()}")


def check_out_every_available_item(library: Library) -> None:
    """Check out every currently available item.

    This function only depends on the LendingItem interface. It does not need
    separate logic for Book versus DigitalBook.
    """
    for item in library.available_items():
        checked_out_item: LendingItem = library.check_out_item(item.identifier)
        print(f'Checked out: "{checked_out_item}"')


def main() -> None:
    """Create a mixed catalog and demonstrate polymorphic behavior."""
    city_library = Library(name="City Library")

    physical_book = Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="978-0132350884",
        shelf_location="A-12",
    )
    digital_book = DigitalBook(
        title="Python for Data Analysis",
        author="Wes McKinney",
        identifier="EBOOK-001",
        download_url="https://library.example/downloads/python-data-analysis",
        license_limit=2,
    )

    city_library.add_item(physical_book)
    city_library.add_item(digital_book)

    print(repr(city_library))
    print(f"Catalog contains {len(city_library)} items.")
    print(f'Contains physical book? {"978-0132350884" in city_library}')
    print(f'Contains missing item? {"MISSING-001" in city_library}')

    print_catalog_status(city_library)

    print("\nChecking out every available item once:")
    check_out_every_available_item(city_library)

    print_catalog_status(city_library)

    print("\nChecking out the digital book one additional time:")
    city_library.check_out_item("EBOOK-001")

    print_catalog_status(city_library)

    print("\nAttempting to check out unavailable items:")
    for identifier in ("978-0132350884", "EBOOK-001"):
        try:
            city_library.check_out_item(identifier)
        except ValueError as error:
            print(f"Expected error: {error}")

    print("\nReturning one digital license and the physical book:")
    city_library.return_item("EBOOK-001")
    city_library.return_item("978-0132350884")

    print_catalog_status(city_library)


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_2_demo.py
```

Expected output:

```text
Library(name='City Library', item_count=2)
Catalog contains 2 items.
Contains physical book? True
Contains missing item? False

Catalog status for City Library:
- "Clean Code" by Robert C. Martin (shelf: A-12) is currently available.
- "Python for Data Analysis" by Wes McKinney has 2 of 2 digital licenses available.

Checking out every available item once:
Checked out: "Clean Code by Robert C. Martin"
Checked out: "Python for Data Analysis by Wes McKinney (digital)"

Catalog status for City Library:
- "Clean Code" by Robert C. Martin (shelf: A-12) is currently checked out.
- "Python for Data Analysis" by Wes McKinney has 1 of 2 digital licenses available.

Checking out the digital book one additional time:

Catalog status for City Library:
- "Clean Code" by Robert C. Martin (shelf: A-12) is currently checked out.
- "Python for Data Analysis" by Wes McKinney is unavailable: all 2 digital licenses are in use.

Attempting to check out unavailable items:
Expected error: "Clean Code" is already checked out.
Expected error: All 2 licenses for "Python for Data Analysis" are in use.

Returning one digital license and the physical book:

Catalog status for City Library:
- "Clean Code" by Robert C. Martin (shelf: A-12) is currently available.
- "Python for Data Analysis" by Wes McKinney has 1 of 2 digital licenses available.
```

The most important detail is that the `Library` class has no code that explicitly checks whether an item is a `Book` or `DigitalBook` before checking it out.

Each class owns its own checkout behavior.

---

# Step 7: Check for Common Errors at the Object Boundary

## The Target

We are verifying that the object model rejects invalid data and invalid usage early.

No files are added in this step. Instead, we will run targeted checks against the code already built.

## The Concept

An **object boundary** is the point where data enters an object or where an operation requests a state change.

Examples:

- Creating a `Book` is a boundary.
- Adding an item to `Library` is a boundary.
- Checking out an item is a boundary.

Validation at these boundaries is like a ticket scanner at a venue entrance. It is better to reject an invalid ticket at the door than to discover the problem later after the person is already inside.

Our classes already validate:

- Blank identifiers
- Blank titles
- Invalid URLs
- Invalid license limits
- Duplicate catalog identifiers
- Items that do not inherit from `LendingItem`
- Invalid checkout and return operations

## The Implementation

Run the following command exactly as written:

```bash
python -c "from library import Book, DigitalBook, Library; checks = [lambda: Book('', 'Author', '123', 'A-1'), lambda: DigitalBook('Title', 'Author', 'EBOOK-1', 'http://unsafe.example/file', 1), lambda: DigitalBook('Title', 'Author', 'EBOOK-1', 'https://library.example/file', 0), lambda: Library('')]; [print(f'{type(error).__name__}: {error}') for check in checks for error in [None] if False]"
```

The command above intentionally does not execute the checks; it only demonstrates that shell one-liners become difficult to read quickly. For clear validation, use a temporary Python script instead.

Create the file below.

### `examples/part_2_validation_demo.py`

```python
"""Demonstrate validation at object boundaries."""

from collections.abc import Callable

from library import Book, DigitalBook, Library


def print_expected_error(description: str, action: Callable[[], object]) -> None:
    """Run an action and print the expected validation error."""
    try:
        action()
    except (TypeError, ValueError) as error:
        print(f"{description}: {type(error).__name__}: {error}")
    else:
        print(f"{description}: ERROR — expected an exception but none was raised.")


def main() -> None:
    """Run a set of invalid operations against the library model."""
    print_expected_error(
        "Blank physical-book title",
        lambda: Book(
            title="",
            author="An Author",
            isbn="978-0000000001",
            shelf_location="A-01",
        ),
    )

    print_expected_error(
        "Non-HTTPS digital-book URL",
        lambda: DigitalBook(
            title="Secure Downloads",
            author="An Author",
            identifier="EBOOK-INVALID-URL",
            download_url="http://library.example/download",
            license_limit=1,
        ),
    )

    print_expected_error(
        "Zero digital licenses",
        lambda: DigitalBook(
            title="No Licenses",
            author="An Author",
            identifier="EBOOK-ZERO-LICENSES",
            download_url="https://library.example/download",
            license_limit=0,
        ),
    )

    print_expected_error(
        "Blank library name",
        lambda: Library(name="   "),
    )

    library = Library(name="Validation Library")
    library.add_item(
        Book(
            title="First Book",
            author="Author One",
            isbn="978-0000000002",
            shelf_location="B-02",
        )
    )

    print_expected_error(
        "Duplicate catalog identifier",
        lambda: library.add_item(
            Book(
                title="Duplicate Identifier",
                author="Author Two",
                isbn="978-0000000002",
                shelf_location="C-03",
            )
        ),
    )

    print_expected_error(
        "Unsupported catalog item",
        lambda: library.add_item("This is not a LendingItem"),  # type: ignore[arg-type]
    )


if __name__ == "__main__":
    main()
```

The `# type: ignore[arg-type]` comment is intentional. The example deliberately passes an incorrect value to prove that runtime validation works. In a normal, correctly typed program, you would not need that comment.

## The Verification

Run:

```bash
python examples/part_2_validation_demo.py
```

Expected output:

```text
Blank physical-book title: ValueError: Item title cannot be blank.
Non-HTTPS digital-book URL: ValueError: Digital book download URL must start with https://.
Zero digital licenses: ValueError: Digital book license limit must be at least 1.
Blank library name: ValueError: Library name cannot be blank.
Duplicate catalog identifier: ValueError: An item with identifier "978-0000000002" already exists in Validation Library.
Unsupported catalog item: TypeError: Library items must inherit from LendingItem.
```

The exact wording should match the messages in the source files.

---

# Part 2 Reference: Inheritance, Polymorphism, and Dunder Methods

## Inheritance

Inheritance lets a specialized class reuse and extend a more general class.

```python
class LendingItem:
    ...

class Book(LendingItem):
    ...
```

Read this as:

> A `Book` is a `LendingItem`.

This relationship is appropriate because every `Book` can use the common lending-item interface.

Inheritance is not appropriate merely because two things happen to share some fields. Use it when the “is a” relationship is genuinely true.

Good:

```text
DigitalBook is a LendingItem.
```

Usually not good:

```text
Library is a Book.
```

A library *contains* books; it is not a type of book.

That is a **has-a** relationship, which we modeled with:

```python
self._items_by_identifier: dict[str, LendingItem] = {}
```

---

## `super()`

`super()` gives a subclass access to behavior from its parent class.

```python
super().__init__(identifier=isbn, title=title)
```

This allows `Book` to reuse the base class validation and initialization.

Without `super()`, the subclass would need to duplicate this logic:

```python
if not isbn.strip():
    raise ValueError(...)
if not title.strip():
    raise ValueError(...)
```

Duplicated validation creates maintenance risk. If the rule changes, developers must remember every copied location.

---

## Method Overriding

A subclass overrides a parent method by defining a method with the same name.

`DigitalBook` overrides `check_out()`:

```python
def check_out(self) -> None:
    if self.is_checked_out:
        raise ValueError(...)
    self._active_loans += 1
```

This method is different from `LendingItem.check_out()`, because a digital book supports multiple simultaneous loans.

Method overriding gives subclasses the flexibility to customize behavior while preserving a shared public interface.

---

## Polymorphism

Polymorphism allows code to use different object types through a common interface.

```python
def check_out_every_available_item(library: Library) -> None:
    for item in library.available_items():
        library.check_out_item(item.identifier)
```

The function does not need separate paths for `Book` and `DigitalBook`.

At runtime:

```python
item.check_out()
```

calls the correct version for the actual object:

- `LendingItem.check_out()` for physical books that inherit it unchanged.
- `DigitalBook.check_out()` for digital books that override it.

---

## `__str__` versus `__repr__`

### `__str__`

`__str__` is for people using the application.

```python
def __str__(self) -> str:
    return f"{self.title} by {self.author}"
```

It should be concise and readable.

```python
print(book)
```

Example output:

```text
Clean Code by Robert C. Martin
```

### `__repr__`

`__repr__` is for developers debugging the application.

```python
def __repr__(self) -> str:
    return f"Book(title={self.title!r}, isbn={self.isbn!r})"
```

It should contain enough detail to identify the object and diagnose problems.

```python
print(repr(book))
```

Example output:

```text
Book(title='Clean Code', isbn='978-0132350884')
```

If `__str__` is not defined, Python often falls back to `__repr__` for `print(object)`.

---

## `__eq__`

`__eq__` controls `==`.

```python
def __eq__(self, other: object) -> bool:
    if not isinstance(other, LendingItem):
        return NotImplemented

    return type(self) is type(other) and self.identifier == other.identifier
```

Returning `NotImplemented` is the correct protocol when the other value is not a compatible type. It gives Python an opportunity to try the reverse comparison or eventually return `False`.

Do not return `False` immediately for every unfamiliar type unless that is truly the intended comparison rule.

---

## `__hash__`

`__hash__` allows an object to be used in a `set` or as a dictionary key.

```python
def __hash__(self) -> int:
    return hash((type(self), self.identifier))
```

Because equality is based on concrete type and identifier, hashing must use the same values.

This is valid:

```python
items = {
    Book("Clean Code", "Robert C. Martin", "978-0132350884", "A-12"),
    Book("Another Record", "Other Author", "978-0132350884", "B-10"),
}

print(len(items))
```

Output:

```text
1
```

The set considers the two objects equal because they represent the same physical-book identifier.

### Important Hashing Rule

Only hash objects whose identity fields do not change after creation.

Our `identifier` is assigned during initialization and is treated as stable. If you change fields used by `__hash__` after putting an object into a set, Python may no longer be able to find it correctly.

---

## `__len__`

`__len__` allows your object to work with `len()`.

```python
def __len__(self) -> int:
    return len(self._items_by_identifier)
```

Then:

```python
len(library)
```

is clearer than:

```python
library.item_count()
```

when the object conceptually behaves like a collection.

---

## `__iter__`

`__iter__` makes an object iterable.

```python
def __iter__(self) -> Iterator[LendingItem]:
    return iter(self._items_by_identifier.values())
```

Then this works naturally:

```python
for item in library:
    print(item)
```

An **iterator** is an object that yields one value at a time during iteration.

We will study iterators and generators in much more detail in the Pythonic Mechanics module.

---

## `__contains__`

`__contains__` powers the `in` operator.

```python
def __contains__(self, identifier: object) -> bool:
    return isinstance(identifier, str) and identifier in self._items_by_identifier
```

Then:

```python
if "EBOOK-001" in library:
    print("The catalog contains that item.")
```

Using `object` as the parameter type is intentional. Python allows callers to write:

```python
123 in library
```

Our method safely returns `False` rather than assuming the caller provided a string.

---

## Composition versus Inheritance

Two common ways to connect objects are:

### Inheritance: “is a”

```text
Book is a LendingItem.
DigitalBook is a LendingItem.
```

Implemented with:

```python
class Book(LendingItem):
    ...
```

### Composition: “has a”

```text
Library has lending items.
```

Implemented with:

```python
self._items_by_identifier: dict[str, LendingItem] = {}
```

A practical design guideline:

> Prefer composition by default. Use inheritance when subclasses genuinely share a stable conceptual contract with the base class.

Inheritance can become difficult to maintain if it is used only to avoid writing a few lines of repeated code. Composition often keeps classes more independent.
