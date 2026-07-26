# Part 1: Classes, Instances, and Object State

In this part, we will begin building the mental model behind object-oriented programming, usually shortened to **OOP**.

A class lets us group related **data** and **behavior** in one place.

For a real-world analogy, think about a class as a blueprint for a library book:

- The blueprint says every book has a title, author, and ISBN.
- The blueprint also says what a book can do, such as describe itself.
- An actual copy of *Python Crash Course* is an **instance** created from that blueprint.

In Python:

- A **class** defines a reusable blueprint.
- An **object** or **instance** is one concrete value created from that class.
- An **attribute** is data stored on an object.
- A **method** is a function defined inside a class. It usually operates on that object’s data.

Our eventual API client needs objects such as configuration records, API resources, HTTP responses, and client instances. Before building those production components, we will learn the core mechanics in a small, focused project.

---

## What You Will Build in This Part

By the end of this part, you will have a small `library` package containing:

- A `Book` class for modeling library books.
- Instance attributes such as title, author, and availability.
- Methods that safely change a book’s state.
- A class attribute that tracks how many books were created.
- A useful `__repr__` method for debugging.
- A `Library` class that manages many books.

The completed structure will be:

```text
pythonic-craftsmanship/
├── .gitignore
├── pyproject.toml
├── src/
│   └── library/
│       ├── __init__.py
│       ├── book.py
│       └── catalog.py
└── examples/
    └── part_1_demo.py
```

This is intentionally a small package. The same organization pattern will later grow into our API client capstone.

---

# Step 1: Create an Isolated Python Project Environment

## The Target

We are creating a project directory and a **virtual environment** named `.venv`.

A virtual environment is an isolated Python workspace. It keeps packages installed for this project separate from packages installed for other projects on your computer.

## The Concept

Imagine each Python project is a workshop.

Without a virtual environment, every workshop throws its tools into one giant shared toolbox. One project may upgrade a tool, remove a tool, or need a different version than another project.

A virtual environment gives each workshop its own toolbox.

We will not install external packages in this part, but establishing this habit now prevents problems later when we add `pytest`, `mypy`, and HTTP tooling.

## The Implementation

Open a terminal and run the following commands.

### macOS or Linux

```bash
mkdir pythonic-craftsmanship
cd pythonic-craftsmanship

python3 -m venv .venv
source .venv/bin/activate
```

### Windows PowerShell

```powershell
mkdir pythonic-craftsmanship
cd pythonic-craftsmanship

py -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### Windows Command Prompt

```bat
mkdir pythonic-craftsmanship
cd pythonic-craftsmanship

py -m venv .venv
.venv\Scripts\activate.bat
```

When the environment is active, your terminal prompt will normally include `(.venv)`.

Next, create the initial directories:

```bash
mkdir -p src/library examples
```

On Windows PowerShell, use:

```powershell
mkdir src\library
mkdir examples
```

On Windows Command Prompt, use:

```bat
mkdir src\library
mkdir examples
```

## The Verification

Run the following command:

```bash
python --version
```

You should see a Python version of 3.11 or newer, for example:

```text
Python 3.12.4
```

Then confirm which Python executable is active.

### macOS or Linux

```bash
which python
```

Expected output should include the project’s `.venv` directory:

```text
.../pythonic-craftsmanship/.venv/bin/python
```

### Windows PowerShell

```powershell
Get-Command python
```

Expected output should contain a path similar to:

```text
...\pythonic-craftsmanship\.venv\Scripts\python.exe
```

If the path does not include `.venv`, activate the environment again before continuing.

---

# Step 2: Configure the Project and Ignore Local Files

## The Target

We are creating two project-level files:

1. `.gitignore`, which tells Git not to track local and generated files.
2. `pyproject.toml`, which describes our Python project.

## The Concept

A project has two kinds of material:

- **Source material**, such as Python code and configuration, which should be shared with teammates.
- **Local or generated material**, such as virtual environments and cache files, which should stay on each developer’s machine.

A `.gitignore` file is like a shipping checklist that says: “Do not put these machine-specific items in the shared box.”

The `pyproject.toml` file is the project’s formal label. Python packaging tools read it to learn the package name, Python version requirements, and build configuration.

## The Implementation

### `.gitignore`

```gitignore
# Virtual environments are local to each developer machine.
.venv/

# Python creates these cache folders when it runs imported modules.
__pycache__/

# Compiled Python files.
*.py[cod]

# Test and type-checker caches that we will add in later parts.
.pytest_cache/
.mypy_cache/

# Coverage reports, generated when test coverage is measured.
.coverage
htmlcov/

# Common operating-system and editor files.
.DS_Store
.vscode/
.idea/
```

### `pyproject.toml`

```toml
[build-system]
# setuptools builds our package into an installable distribution.
requires = ["setuptools>=69.0"]
build-backend = "setuptools.build_meta"

[project]
name = "pythonic-craftsmanship-library"
version = "0.1.0"
description = "Examples for learning clean, idiomatic Python."
readme = "README.md"
requires-python = ">=3.11"
authors = [
  { name = "Pythonic Craftsmanship Student" }
]

[tool.setuptools]
# This tells setuptools that importable packages live under src/.
package-dir = {"" = "src"}

[tool.setuptools.packages.find]
where = ["src"]
```

The configuration references a `README.md` file, so create it now.

### `README.md`

```md
# Pythonic Craftsmanship

Code examples for learning clean, idiomatic, maintainable Python.

## Part 1

Part 1 introduces object-oriented programming with a small library domain model.
```

Install the project in **editable mode**:

```bash
python -m pip install --editable .
```

Editable mode means Python uses your current source files directly. When you change a file under `src/`, you do not need to reinstall the package to use the updated code.

## The Verification

Run:

```bash
python -m pip show pythonic-craftsmanship-library
```

You should see information similar to this:

```text
Name: pythonic-craftsmanship-library
Version: 0.1.0
Editable project location: .../pythonic-craftsmanship
```

The exact path will differ on your computer.

---

# Step 3: Define the `Book` Class

## The Target

We are creating `src/library/book.py`.

This file will contain a `Book` class. Every `Book` instance will store:

- `title`
- `author`
- `isbn`
- `is_checked_out`

We will also provide methods to check a book out and return it.

## The Concept

A function is excellent when it performs one independent action.

For example:

```python
def add_tax(price: float) -> float:
    return price * 1.2
```

But a library book has multiple pieces of related data and several actions that depend on that data. Passing each value separately to every function quickly becomes confusing.

Without a class, code might look like this:

```python
title = "The Pragmatic Programmer"
author = "David Thomas and Andrew Hunt"
isbn = "978-0135957059"
is_checked_out = False
```

Then every operation must receive and return several loosely connected values.

A class keeps these values together. It creates one object that represents one meaningful thing in the program.

The `__init__` method is called when Python creates a new object. It initializes the object’s starting state.

The `self` parameter refers to the specific object currently being created or used. It is how a method accesses that object’s own attributes.

## The Implementation

### `src/library/book.py`

```python
"""Domain model for a book that can be stored in a library catalog."""

from __future__ import annotations


class Book:
    """Represent one book and its current lending state.

    Each Book instance owns its own title, author, ISBN, and checkout state.
    """

    def __init__(self, title: str, author: str, isbn: str) -> None:
        """Create a book that is initially available to borrow.

        Args:
            title: The human-readable title of the book.
            author: The name of the book's author.
            isbn: A stable identifier for this edition of the book.

        Raises:
            ValueError: If any required text value is blank.
        """
        cleaned_title = title.strip()
        cleaned_author = author.strip()
        cleaned_isbn = isbn.strip()

        # Validate at object creation time so every Book starts in a valid state.
        if not cleaned_title:
            raise ValueError("Book title cannot be blank.")

        if not cleaned_author:
            raise ValueError("Book author cannot be blank.")

        if not cleaned_isbn:
            raise ValueError("Book ISBN cannot be blank.")

        self.title = cleaned_title
        self.author = cleaned_author
        self.isbn = cleaned_isbn
        self.is_checked_out = False

    def check_out(self) -> None:
        """Mark this book as checked out.

        Raises:
            ValueError: If somebody tries to check out an unavailable book.
        """
        if self.is_checked_out:
            raise ValueError(f'"{self.title}" is already checked out.')

        self.is_checked_out = True

    def return_to_library(self) -> None:
        """Mark this book as available again.

        Raises:
            ValueError: If somebody tries to return a book that was not borrowed.
        """
        if not self.is_checked_out:
            raise ValueError(f'"{self.title}" is already in the library.')

        self.is_checked_out = False

    def status_message(self) -> str:
        """Return a human-friendly description of this book's current state."""
        availability = "checked out" if self.is_checked_out else "available"

        return f'"{self.title}" by {self.author} is currently {availability}.'
```

Now create the package initializer.

### `src/library/__init__.py`

```python
"""A small library domain package used in Part 1 of the tutorial."""

from library.book import Book

__all__ = ["Book"]
```

The `__all__` list documents the names this package intentionally exposes for `from library import *`. We will not use wildcard imports in our application code, but declaring a deliberate public interface is a useful package-design habit.

Create a demonstration script.

### `examples/part_1_demo.py`

```python
"""Run small examples for Part 1: classes, instances, and object state."""

from library import Book


def main() -> None:
    """Create books and demonstrate that each instance has separate state."""
    clean_code = Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="978-0132350884",
    )
    pragmatic_programmer = Book(
        title="The Pragmatic Programmer",
        author="David Thomas and Andrew Hunt",
        isbn="978-0135957059",
    )

    print(clean_code.status_message())
    print(pragmatic_programmer.status_message())

    clean_code.check_out()

    print(clean_code.status_message())
    print(pragmatic_programmer.status_message())


if __name__ == "__main__":
    main()
```

## The Verification

Run the demonstration:

```bash
python examples/part_1_demo.py
```

Expected output:

```text
"Clean Code" by Robert C. Martin is currently available.
"The Pragmatic Programmer" by David Thomas and Andrew Hunt is currently available.
"Clean Code" by Robert C. Martin is currently checked out.
"The Pragmatic Programmer" by David Thomas and Andrew Hunt is currently available.
```

Notice the key result: checking out `clean_code` does not change `pragmatic_programmer`.

They were both created from the same blueprint, but they are separate instances with separate state.

---

# Step 4: Make Object State Safer with Encapsulation

## The Target

We are improving `src/library/book.py` so callers cannot casually change the checkout status by assigning directly to `is_checked_out`.

Instead, callers must use `check_out()` and `return_to_library()`.

## The Concept

**Encapsulation** means an object manages its own internal details.

Imagine a bank account:

- You should be able to ask for the balance.
- You should be able to deposit or withdraw money through approved operations.
- You should not be able to set the balance to an arbitrary value by writing directly into the bank’s database.

A book’s checkout state has rules:

- An available book can be checked out.
- A checked-out book can be returned.
- A checked-out book cannot be checked out again.
- An available book cannot be returned again.

If code outside the object can freely run this:

```python
book.is_checked_out = True
```

it can bypass those rules.

In Python, a single leading underscore communicates that an attribute is **internal**:

```python
self._is_checked_out
```

This is a convention rather than an unbreakable security barrier. Python trusts developers more than many languages do. The convention says: “This is an implementation detail; use the public methods or properties instead.”

We will provide a read-only `is_checked_out` property using `@property`.

## The Implementation

Replace the complete contents of `src/library/book.py`.

### `src/library/book.py`

```python
"""Domain model for a book that can be stored in a library catalog."""

from __future__ import annotations


class Book:
    """Represent one book and its current lending state.

    Each Book instance owns its own title, author, ISBN, and checkout state.
    Checkout state changes are controlled through explicit methods so the
    object can enforce its lending rules.
    """

    def __init__(self, title: str, author: str, isbn: str) -> None:
        """Create a book that is initially available to borrow.

        Args:
            title: The human-readable title of the book.
            author: The name of the book's author.
            isbn: A stable identifier for this edition of the book.

        Raises:
            ValueError: If any required text value is blank.
        """
        cleaned_title = title.strip()
        cleaned_author = author.strip()
        cleaned_isbn = isbn.strip()

        if not cleaned_title:
            raise ValueError("Book title cannot be blank.")

        if not cleaned_author:
            raise ValueError("Book author cannot be blank.")

        if not cleaned_isbn:
            raise ValueError("Book ISBN cannot be blank.")

        self.title = cleaned_title
        self.author = cleaned_author
        self.isbn = cleaned_isbn

        # A leading underscore marks this as internal state.
        # Public code reads it through the is_checked_out property below.
        self._is_checked_out = False

    @property
    def is_checked_out(self) -> bool:
        """Return whether this book is currently borrowed.

        This is a read-only property: callers can inspect the state but must
        call check_out() or return_to_library() to change it safely.
        """
        return self._is_checked_out

    def check_out(self) -> None:
        """Mark this book as checked out.

        Raises:
            ValueError: If somebody tries to check out an unavailable book.
        """
        if self._is_checked_out:
            raise ValueError(f'"{self.title}" is already checked out.')

        self._is_checked_out = True

    def return_to_library(self) -> None:
        """Mark this book as available again.

        Raises:
            ValueError: If somebody tries to return a book that was not borrowed.
        """
        if not self._is_checked_out:
            raise ValueError(f'"{self.title}" is already in the library.')

        self._is_checked_out = False

    def status_message(self) -> str:
        """Return a human-friendly description of this book's current state."""
        availability = "checked out" if self._is_checked_out else "available"

        return f'"{self.title}" by {self.author} is currently {availability}.'
```

Update the demonstration program to verify valid and invalid state transitions.

### `examples/part_1_demo.py`

```python
"""Run small examples for Part 1: classes, instances, and object state."""

from library import Book


def main() -> None:
    """Create a book and demonstrate controlled state changes."""
    clean_code = Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="978-0132350884",
    )

    print(clean_code.status_message())

    clean_code.check_out()
    print(clean_code.status_message())

    try:
        clean_code.check_out()
    except ValueError as error:
        print(f"Expected error: {error}")

    clean_code.return_to_library()
    print(clean_code.status_message())

    try:
        clean_code.return_to_library()
    except ValueError as error:
        print(f"Expected error: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_1_demo.py
```

Expected output:

```text
"Clean Code" by Robert C. Martin is currently available.
"Clean Code" by Robert C. Martin is currently checked out.
Expected error: "Clean Code" is already checked out.
"Clean Code" by Robert C. Martin is currently available.
Expected error: "Clean Code" is already in the library.
```

Now open a Python interactive session:

```bash
python
```

Paste this code:

```python
from library import Book

book = Book(
    title="Python Tricks",
    author="Dan Bader",
    isbn="978-1775093305",
)

print(book.is_checked_out)
book.is_checked_out = True
```

You should see:

```text
False
```

Then Python should raise an error similar to:

```text
AttributeError: property 'is_checked_out' of 'Book' object has no setter
```

Exit the interactive session:

```python
exit()
```

This confirms that the public property is readable but cannot be assigned directly.

---

# Step 5: Add a Class Attribute and a Class Method

## The Target

We are enhancing `Book` to track how many `Book` objects have been created.

We will add:

- `Book.total_books_created`, a **class attribute**
- `Book.created_count()`, a **class method**

## The Concept

An **instance attribute** belongs to one specific object.

For example:

```python
clean_code.title
```

The title belongs only to that one `Book` instance.

A **class attribute** belongs to the class itself and is shared by all instances.

Think of a library’s “total registered books” counter:

- It is not a property of any single book.
- It is a shared fact about all books created by the system.

A class method receives `cls` as its first parameter. `cls` refers to the class, just as `self` refers to a specific instance.

Use:

- `self` when you need one object’s data.
- `cls` when you need data shared by the whole class.

## The Implementation

Replace the complete contents of `src/library/book.py`.

### `src/library/book.py`

```python
"""Domain model for a book that can be stored in a library catalog."""

from __future__ import annotations


class Book:
    """Represent one book and its current lending state."""

    # This value belongs to the Book class, not to an individual Book instance.
    total_books_created = 0

    def __init__(self, title: str, author: str, isbn: str) -> None:
        """Create a book that is initially available to borrow.

        Args:
            title: The human-readable title of the book.
            author: The name of the book's author.
            isbn: A stable identifier for this edition of the book.

        Raises:
            ValueError: If any required text value is blank.
        """
        cleaned_title = title.strip()
        cleaned_author = author.strip()
        cleaned_isbn = isbn.strip()

        if not cleaned_title:
            raise ValueError("Book title cannot be blank.")

        if not cleaned_author:
            raise ValueError("Book author cannot be blank.")

        if not cleaned_isbn:
            raise ValueError("Book ISBN cannot be blank.")

        self.title = cleaned_title
        self.author = cleaned_author
        self.isbn = cleaned_isbn
        self._is_checked_out = False

        # type(self) is used instead of writing Book directly. This makes the
        # counter work correctly if a future class inherits from Book.
        type(self).total_books_created += 1

    @property
    def is_checked_out(self) -> bool:
        """Return whether this book is currently borrowed."""
        return self._is_checked_out

    @classmethod
    def created_count(cls) -> int:
        """Return the number of instances created for this class."""
        return cls.total_books_created

    def check_out(self) -> None:
        """Mark this book as checked out.

        Raises:
            ValueError: If somebody tries to check out an unavailable book.
        """
        if self._is_checked_out:
            raise ValueError(f'"{self.title}" is already checked out.')

        self._is_checked_out = True

    def return_to_library(self) -> None:
        """Mark this book as available again.

        Raises:
            ValueError: If somebody tries to return a book that was not borrowed.
        """
        if not self._is_checked_out:
            raise ValueError(f'"{self.title}" is already in the library.')

        self._is_checked_out = False

    def status_message(self) -> str:
        """Return a human-friendly description of this book's current state."""
        availability = "checked out" if self._is_checked_out else "available"

        return f'"{self.title}" by {self.author} is currently {availability}.'
```

Update the example.

### `examples/part_1_demo.py`

```python
"""Run small examples for Part 1: classes, instances, and object state."""

from library import Book


def main() -> None:
    """Create books and demonstrate instance versus class state."""
    print(f"Books created before this program: {Book.created_count()}")

    clean_code = Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="978-0132350884",
    )
    pragmatic_programmer = Book(
        title="The Pragmatic Programmer",
        author="David Thomas and Andrew Hunt",
        isbn="978-0135957059",
    )

    print(f"Books created after setup: {Book.created_count()}")
    print(clean_code.status_message())
    print(pragmatic_programmer.status_message())

    clean_code.check_out()

    print(clean_code.status_message())
    print(pragmatic_programmer.status_message())


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_1_demo.py
```

Expected output:

```text
Books created before this program: 0
Books created after setup: 2
"Clean Code" by Robert C. Martin is currently available.
"The Pragmatic Programmer" by David Thomas and Andrew Hunt is currently available.
"Clean Code" by Robert C. Martin is currently checked out.
"The Pragmatic Programmer" by David Thomas and Andrew Hunt is currently available.
```

Each run starts a fresh Python process, so the counter begins at `0`.

---

# Step 6: Add `__repr__` for Useful Debugging Output

## The Target

We are adding the `__repr__` **dunder method** to `Book`.

“Dunder” is informal shorthand for “double underscore.” A dunder method is a special method that Python calls in particular situations.

Python calls `__repr__` when it needs an unambiguous developer-facing representation of an object, such as when you inspect the object in the interactive interpreter or print a list containing it.

## The Concept

A plain object display is not useful:

```text
<library.book.Book object at 0x102d2df10>
```

It tells you that a `Book` exists, but not which book it is.

A good `__repr__` is like a clear label on a storage box. It should let a developer identify the object quickly while debugging.

For simple, stable objects, a `__repr__` value is often written so that it resembles the code that could recreate the object.

## The Implementation

Replace the complete contents of `src/library/book.py`.

### `src/library/book.py`

```python
"""Domain model for a book that can be stored in a library catalog."""

from __future__ import annotations


class Book:
    """Represent one book and its current lending state."""

    total_books_created = 0

    def __init__(self, title: str, author: str, isbn: str) -> None:
        """Create a book that is initially available to borrow.

        Args:
            title: The human-readable title of the book.
            author: The name of the book's author.
            isbn: A stable identifier for this edition of the book.

        Raises:
            ValueError: If any required text value is blank.
        """
        cleaned_title = title.strip()
        cleaned_author = author.strip()
        cleaned_isbn = isbn.strip()

        if not cleaned_title:
            raise ValueError("Book title cannot be blank.")

        if not cleaned_author:
            raise ValueError("Book author cannot be blank.")

        if not cleaned_isbn:
            raise ValueError("Book ISBN cannot be blank.")

        self.title = cleaned_title
        self.author = cleaned_author
        self.isbn = cleaned_isbn
        self._is_checked_out = False

        type(self).total_books_created += 1

    def __repr__(self) -> str:
        """Return a detailed representation intended for developers."""
        return (
            f"Book(title={self.title!r}, author={self.author!r}, "
            f"isbn={self.isbn!r}, is_checked_out={self._is_checked_out!r})"
        )

    @property
    def is_checked_out(self) -> bool:
        """Return whether this book is currently borrowed."""
        return self._is_checked_out

    @classmethod
    def created_count(cls) -> int:
        """Return the number of instances created for this class."""
        return cls.total_books_created

    def check_out(self) -> None:
        """Mark this book as checked out.

        Raises:
            ValueError: If somebody tries to check out an unavailable book.
        """
        if self._is_checked_out:
            raise ValueError(f'"{self.title}" is already checked out.')

        self._is_checked_out = True

    def return_to_library(self) -> None:
        """Mark this book as available again.

        Raises:
            ValueError: If somebody tries to return a book that was not borrowed.
        """
        if not self._is_checked_out:
            raise ValueError(f'"{self.title}" is already in the library.')

        self._is_checked_out = False

    def status_message(self) -> str:
        """Return a human-friendly description of this book's current state."""
        availability = "checked out" if self._is_checked_out else "available"

        return f'"{self.title}" by {self.author} is currently {availability}.'
```

Update the example to print the object before and after its state changes.

### `examples/part_1_demo.py`

```python
"""Run small examples for Part 1: classes, instances, and object state."""

from library import Book


def main() -> None:
    """Create a book and inspect its developer-facing representation."""
    book = Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="978-0132350884",
    )

    print("New book:")
    print(book)

    book.check_out()

    print("\nChecked-out book:")
    print(book)

    print("\nHuman-friendly status:")
    print(book.status_message())


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_1_demo.py
```

Expected output:

```text
New book:
Book(title='Clean Code', author='Robert C. Martin', isbn='978-0132350884', is_checked_out=False)

Checked-out book:
Book(title='Clean Code', author='Robert C. Martin', isbn='978-0132350884', is_checked_out=True)

Human-friendly status:
"Clean Code" by Robert C. Martin is currently checked out.
```

The output from `print(book)` uses `__repr__` because we have not yet defined `__str__`.

Later in the OOP module, we will distinguish more deeply between `__repr__` and `__str__`, as well as add other special methods such as `__len__` and `__eq__`.

---

# Step 7: Create a `Library` Class That Manages Multiple Books

## The Target

We are creating `src/library/catalog.py` with a `Library` class.

The `Library` class will:

- Store a collection of `Book` objects.
- Add books while preventing duplicate ISBN values.
- Find books by ISBN.
- List available books.
- Check out and return books through one central interface.

## The Concept

A `Book` manages the rules for one book.

A `Library` manages the relationship between many books.

This separation is important. A `Book` should not need to know about every other book in the catalog. It only knows about itself.

Think of this as separating responsibilities:

- A book’s barcode label identifies one item.
- The library’s catalog desk tracks every item and helps people find them.

This is called **separation of concerns**: each class should own one focused responsibility.

We will store books in a dictionary:

```python
dict[str, Book]
```

The dictionary key will be the ISBN. This lets us look up a book efficiently using its identifier.

## The Implementation

### `src/library/catalog.py`

```python
"""Catalog services for managing a collection of library books."""

from __future__ import annotations

from library.book import Book


class Library:
    """Manage a collection of books indexed by ISBN."""

    def __init__(self, name: str) -> None:
        """Create an empty library catalog.

        Args:
            name: The public name of the library.

        Raises:
            ValueError: If the library name is blank.
        """
        cleaned_name = name.strip()

        if not cleaned_name:
            raise ValueError("Library name cannot be blank.")

        self.name = cleaned_name

        # The dictionary keeps each ISBN unique and makes lookup fast.
        self._books_by_isbn: dict[str, Book] = {}

    def add_book(self, book: Book) -> None:
        """Add a Book to the catalog.

        Raises:
            ValueError: If another book with the same ISBN already exists.
        """
        if book.isbn in self._books_by_isbn:
            raise ValueError(
                f'A book with ISBN "{book.isbn}" already exists in {self.name}.'
            )

        self._books_by_isbn[book.isbn] = book

    def find_book(self, isbn: str) -> Book:
        """Return the book with the given ISBN.

        Raises:
            KeyError: If no book with the supplied ISBN exists.
        """
        cleaned_isbn = isbn.strip()

        try:
            return self._books_by_isbn[cleaned_isbn]
        except KeyError as error:
            raise KeyError(
                f'No book with ISBN "{cleaned_isbn}" exists in {self.name}.'
            ) from error

    def available_books(self) -> list[Book]:
        """Return all books that are not currently checked out."""
        return [
            book
            for book in self._books_by_isbn.values()
            if not book.is_checked_out
        ]

    def check_out_book(self, isbn: str) -> Book:
        """Check out a catalog book and return the updated object."""
        book = self.find_book(isbn)
        book.check_out()

        return book

    def return_book(self, isbn: str) -> Book:
        """Return a catalog book and return the updated object."""
        book = self.find_book(isbn)
        book.return_to_library()

        return book

    def book_count(self) -> int:
        """Return the number of books in this library's catalog."""
        return len(self._books_by_isbn)
```

Update the package’s public interface.

### `src/library/__init__.py`

```python
"""A small library domain package used in Part 1 of the tutorial."""

from library.book import Book
from library.catalog import Library

__all__ = ["Book", "Library"]
```

Replace the demonstration script.

### `examples/part_1_demo.py`

```python
"""Run small examples for Part 1: classes, instances, and object state."""

from library import Book, Library


def main() -> None:
    """Create a catalog and use it to manage multiple books."""
    city_library = Library(name="City Library")

    clean_code = Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="978-0132350884",
    )
    pragmatic_programmer = Book(
        title="The Pragmatic Programmer",
        author="David Thomas and Andrew Hunt",
        isbn="978-0135957059",
    )

    city_library.add_book(clean_code)
    city_library.add_book(pragmatic_programmer)

    print(f"{city_library.name} has {city_library.book_count()} books.\n")

    print("Available books before checkout:")
    for book in city_library.available_books():
        print(f"- {book.title}")

    checked_out_book = city_library.check_out_book("978-0132350884")
    print(f'\nChecked out: "{checked_out_book.title}"')

    print("\nAvailable books after checkout:")
    for book in city_library.available_books():
        print(f"- {book.title}")

    returned_book = city_library.return_book("978-0132350884")
    print(f'\nReturned: "{returned_book.title}"')

    print("\nAvailable books after return:")
    for book in city_library.available_books():
        print(f"- {book.title}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_1_demo.py
```

Expected output:

```text
City Library has 2 books.

Available books before checkout:
- Clean Code
- The Pragmatic Programmer

Checked out: "Clean Code"

Available books after checkout:
- The Pragmatic Programmer

Returned: "Clean Code"

Available books after return:
- Clean Code
- The Pragmatic Programmer
```

Now verify the duplicate ISBN rule with this command:

```bash
python -c "from library import Book, Library; library = Library('Test Library'); library.add_book(Book('First Book', 'Author One', '123')); library.add_book(Book('Duplicate Book', 'Author Two', '123'))"
```

Expected result: Python raises a `ValueError` containing:

```text
A book with ISBN "123" already exists in Test Library.
```

This is a useful example of an object protecting the validity of the data it manages.

---

# Part 1 Reference: Core OOP Vocabulary

This reference section collects the concepts introduced in this part.

## Class

A class is a blueprint that defines data and behavior.

```python
class Book:
    ...
```

The class itself does not represent a particular book. It describes what all books in this program should look like.

---

## Instance

An instance is one object created from a class.

```python
book = Book(
    title="Clean Code",
    author="Robert C. Martin",
    isbn="978-0132350884",
)
```

`book` is an instance of `Book`.

You can confirm this with:

```python
print(isinstance(book, Book))
```

Output:

```text
True
```

---

## Constructor: `__init__`

The `__init__` method initializes a new instance.

```python
def __init__(self, title: str, author: str, isbn: str) -> None:
    self.title = title
    self.author = author
    self.isbn = isbn
```

Python runs it when you call the class:

```python
book = Book("Clean Code", "Robert C. Martin", "978-0132350884")
```

The call creates the object, then Python passes that newly created object as `self` to `__init__`.

---

## `self`

`self` means “this particular instance.”

```python
def check_out(self) -> None:
    self._is_checked_out = True
```

If you have two books:

```python
first_book = Book("First", "Author A", "111")
second_book = Book("Second", "Author B", "222")
```

then:

```python
first_book.check_out()
```

changes `first_book._is_checked_out`, not `second_book._is_checked_out`.

---

## Instance Attributes

Instance attributes hold data specific to one object:

```python
self.title = cleaned_title
self.author = cleaned_author
self.isbn = cleaned_isbn
```

Each `Book` gets its own values.

---

## Class Attributes

Class attributes belong to the class and are shared across instances:

```python
class Book:
    total_books_created = 0
```

Access one with:

```python
print(Book.total_books_created)
```

Use a class attribute only for data that logically belongs to the whole class. Do not use mutable class attributes such as lists or dictionaries as per-instance storage.

This is dangerous:

```python
class DangerousExample:
    names: list[str] = []
```

Every instance would share the same list.

Use instance attributes instead:

```python
class SafeExample:
    def __init__(self) -> None:
        self.names: list[str] = []
```

Now every instance gets a separate list.

---

## Instance Methods

An instance method operates on a particular object and receives `self`:

```python
def status_message(self) -> str:
    availability = "checked out" if self._is_checked_out else "available"
    return f"{self.title} is {availability}"
```

Call it through an instance:

```python
print(book.status_message())
```

---

## Class Methods

A class method operates on the class and receives `cls`:

```python
@classmethod
def created_count(cls) -> int:
    return cls.total_books_created
```

Call it through the class:

```python
print(Book.created_count())
```

Class methods are often used for:

- Alternate constructors
- Class-wide counters or settings
- Logic that needs to work correctly with subclasses

---

## Encapsulation

Encapsulation means the object controls how its internal state is changed.

In our example, external code can ask:

```python
print(book.is_checked_out)
```

But it must use approved operations to change state:

```python
book.check_out()
book.return_to_library()
```

This lets the class prevent invalid changes.

---

## Properties

A property lets code access a method with attribute-like syntax.

```python
@property
def is_checked_out(self) -> bool:
    return self._is_checked_out
```

Callers write:

```python
print(book.is_checked_out)
```

not:

```python
print(book.is_checked_out())
```

Properties are valuable when you want a simple public interface while retaining control over how a value is calculated, validated, or exposed.

---

## `__repr__`

`__repr__` returns a developer-oriented representation:

```python
def __repr__(self) -> str:
    return f"Book(title={self.title!r}, isbn={self.isbn!r})"
```

The `!r` conversion in an f-string uses each value’s representation. For strings, this includes quotation marks and escape sequences where needed, making debugging output less ambiguous.

For example:

```python
title = "A Tale\nof Two Cities"
print(f"{title!r}")
```

Output:

```text
'A Tale\nof Two Cities'
```

---

## Type Hints

We used annotations such as:

```python
def find_book(self, isbn: str) -> Book:
```

They mean:

- `isbn` is expected to be a string.
- The method returns a `Book`.

Python does not automatically enforce most type hints while the program runs. Their main value is communication and support from tools such as `mypy`, which we will add in a later module.

---

## Why Validation Happens in `__init__`

We validate titles, authors, and ISBN values when a `Book` is created:

```python
if not cleaned_title:
    raise ValueError("Book title cannot be blank.")
```

This follows an important design principle:

> Make invalid states difficult—or impossible—to create.

If blank-title books are disallowed at creation time, every later method can trust that a valid `Book` has a meaningful title.
