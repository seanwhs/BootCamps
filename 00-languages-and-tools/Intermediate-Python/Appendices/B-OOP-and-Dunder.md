# Appendix B: Object-Oriented Programming and Python Dunder Method Reference

This appendix is a practical reference for Python’s object-oriented programming tools and the special “dunder” methods used throughout the series.

A **dunder method** is a special method whose name begins and ends with two underscores:

```python
__init__
__repr__
__len__
```

“Dunder” is short for “double underscore.”

Python calls these methods automatically when you use familiar language syntax such as:

```python
print(book)
len(library)
for item in library:
    ...
```

The purpose is not to memorize every dunder method. The purpose is to recognize the ones that make a custom object behave naturally and clearly.

---

# B.1 Core OOP Vocabulary

| Term | Meaning | Example |
|---|---|---|
| Class | A reusable blueprint for objects | `class Book:` |
| Instance | One concrete object created from a class | `book = Book(...)` |
| Attribute | Data stored on an object or class | `book.title` |
| Method | A function defined inside a class | `book.check_out()` |
| Constructor | The initialization method, usually `__init__` | `def __init__(...)` |
| Instance method | A method that receives `self` | `def check_out(self)` |
| Class method | A method that receives `cls` | `def from_api_payload(cls, ...)` |
| Static method | A namespaced helper that receives neither `self` nor `cls` | `@staticmethod` |
| Inheritance | Creating a specialized class from a base class | `class Book(LendingItem)` |
| Composition | Storing one object inside another | `Library` has `LendingItem` objects |
| Encapsulation | Keeping internal state behind controlled methods/properties | `_is_checked_out` |
| Polymorphism | Different object types responding to the same interface | `item.check_out()` |

---

# B.2 Classes, Instances, and `self`

A class defines behavior and data shape:

```python
class Book:
    """Represent a physical book."""

    def __init__(self, title: str) -> None:
        self.title = title

    def describe(self) -> str:
        return f"Book: {self.title}"
```

Create instances:

```python
first_book = Book("Clean Code")
second_book = Book("The Pragmatic Programmer")

print(first_book.describe())
print(second_book.describe())
```

Output:

```text
Book: Clean Code
Book: The Pragmatic Programmer
```

`self` refers to the particular instance receiving the method call.

```python
first_book.describe()
```

is conceptually similar to:

```python
Book.describe(first_book)
```

You usually write the first form, but the second form explains why `self` is the first method parameter.

---

# B.3 Instance Attributes versus Class Attributes

## Instance Attributes

Instance attributes belong to one object:

```python
class Book:
    def __init__(self, title: str) -> None:
        self.title = title
```

Each instance has its own title:

```python
first = Book("Clean Code")
second = Book("Fluent Python")

print(first.title)
print(second.title)
```

Output:

```text
Clean Code
Fluent Python
```

## Class Attributes

Class attributes belong to the class:

```python
class Book:
    category = "book"
```

All instances can read the class attribute:

```python
first = Book()
second = Book()

print(first.category)
print(second.category)
```

Use class attributes for shared constants or intentionally shared state.

```python
class ApiDefaults:
    DEFAULT_TIMEOUT_SECONDS = 10.0
```

Avoid mutable class attributes for per-instance data.

### Dangerous Shared Mutable State

```python
class BadLibrary:
    items: list[str] = []
```

Every `BadLibrary` instance shares the same list.

```python
first = BadLibrary()
second = BadLibrary()

first.items.append("Clean Code")

print(second.items)
```

Output:

```text
['Clean Code']
```

### Correct Per-Instance Mutable State

```python
class GoodLibrary:
    def __init__(self) -> None:
        self.items: list[str] = []
```

Now each library has a separate list.

---

# B.4 `__init__`: Object Initialization

`__init__` prepares a newly created instance.

```python
class Project:
    def __init__(self, project_id: str, name: str) -> None:
        self.id = project_id
        self.name = name
```

Usage:

```python
project = Project("project-123", "Website Redesign")
```

`__init__` should usually:

- Normalize simple input.
- Validate required invariants.
- Set initial state.
- Avoid expensive network or file operations unless the class specifically represents that resource.

Example validation:

```python
class Project:
    def __init__(self, project_id: str, name: str) -> None:
        cleaned_project_id = project_id.strip()
        cleaned_name = name.strip()

        if not cleaned_project_id:
            raise ValueError("Project ID cannot be blank.")

        if not cleaned_name:
            raise ValueError("Project name cannot be blank.")

        self.id = cleaned_project_id
        self.name = cleaned_name
```

---

# B.5 Encapsulation and Properties

A single leading underscore communicates internal state:

```python
class Book:
    def __init__(self) -> None:
        self._is_checked_out = False
```

Python does not make `_is_checked_out` private in the strict sense. It signals:

> This attribute is an implementation detail. Use the public interface instead.

Expose safe read access with `@property`:

```python
class Book:
    def __init__(self) -> None:
        self._is_checked_out = False

    @property
    def is_checked_out(self) -> bool:
        return self._is_checked_out

    def check_out(self) -> None:
        if self._is_checked_out:
            raise ValueError("Book is already checked out.")

        self._is_checked_out = True
```

Usage:

```python
book = Book()

print(book.is_checked_out)
book.check_out()
print(book.is_checked_out)
```

Output:

```text
False
True
```

Callers can read the property but cannot accidentally assign it unless you define a setter.

```python
book.is_checked_out = True
```

Raises:

```text
AttributeError: property 'is_checked_out' of 'Book' object has no setter
```

## Property Setter Example

Use a setter only when direct assignment is a valid part of the public API.

```python
class Temperature:
    def __init__(self, celsius: float) -> None:
        self.celsius = celsius

    @property
    def celsius(self) -> float:
        return self._celsius

    @celsius.setter
    def celsius(self, value: float) -> None:
        if value < -273.15:
            raise ValueError("Temperature cannot be below absolute zero.")

        self._celsius = value
```

---

# B.6 Inheritance and `super()`

Inheritance models a genuine “is a” relationship.

```python
class LendingItem:
    def __init__(self, identifier: str, title: str) -> None:
        self.identifier = identifier
        self.title = title
        self._is_checked_out = False

    def check_out(self) -> None:
        if self._is_checked_out:
            raise ValueError("Item is already checked out.")

        self._is_checked_out = True
```

A physical book is a lending item:

```python
class Book(LendingItem):
    def __init__(
        self,
        identifier: str,
        title: str,
        author: str,
    ) -> None:
        super().__init__(identifier=identifier, title=title)
        self.author = author
```

Usage:

```python
book = Book(
    identifier="BOOK-001",
    title="Clean Code",
    author="Robert C. Martin",
)

book.check_out()
```

`Book` inherits `check_out()` from `LendingItem`.

## Method Overriding

A subclass can replace inherited behavior:

```python
class DigitalBook(LendingItem):
    def __init__(
        self,
        identifier: str,
        title: str,
        license_limit: int,
    ) -> None:
        super().__init__(identifier=identifier, title=title)
        self.license_limit = license_limit
        self._active_loans = 0

    def check_out(self) -> None:
        if self._active_loans >= self.license_limit:
            raise ValueError("All licenses are in use.")

        self._active_loans += 1
```

Both types support:

```python
item.check_out()
```

but each follows its own correct rule.

That is polymorphism.

---

# B.7 Composition versus Inheritance

Use inheritance for “is a”:

```text
Book is a LendingItem.
DigitalBook is a LendingItem.
```

Use composition for “has a”:

```text
Library has LendingItems.
CraftApiClient has a Transport.
```

Example composition:

```python
class CraftApiClient:
    def __init__(self, transport: Transport) -> None:
        self._transport = transport
```

A practical default:

> Prefer composition unless inheritance clearly models a stable “is a” relationship.

Composition usually makes components easier to replace, test, and evolve.

---

# B.8 Dunder Method Quick Reference

| Method | Triggered by | Typical purpose |
|---|---|---|
| `__init__` | `ClassName(...)` | Initialize object state |
| `__repr__` | `repr(value)`, interactive display | Developer-facing representation |
| `__str__` | `str(value)`, `print(value)` | Human-facing representation |
| `__eq__` | `left == right` | Value equality |
| `__hash__` | `hash(value)`, sets, dict keys | Hash-based collection compatibility |
| `__bool__` | `bool(value)`, `if value:` | Truthiness |
| `__len__` | `len(value)` | Collection size |
| `__iter__` | `iter(value)`, `for item in value:` | Start iteration |
| `__next__` | `next(iterator)` | Produce next iterator value |
| `__contains__` | `item in collection` | Membership check |
| `__getitem__` | `value[key]` | Index/key access |
| `__enter__` | `with value as x:` | Context setup |
| `__exit__` | End of `with` block | Context cleanup |
| `__call__` | `value(...)` | Make an object callable |

---

# B.9 `__repr__` and `__str__`

## `__repr__`: Developers

`__repr__` should help a developer identify and diagnose the object.

```python
class Project:
    def __init__(self, project_id: str, name: str) -> None:
        self.id = project_id
        self.name = name

    def __repr__(self) -> str:
        return f"Project(id={self.id!r}, name={self.name!r})"
```

```python
project = Project("project-123", "Website Redesign")
print(repr(project))
```

Output:

```text
Project(id='project-123', name='Website Redesign')
```

Use `!r` in f-strings to show the value representation, including quotes around strings.

## `__str__`: People

`__str__` should be concise and user-friendly.

```python
class Project:
    def __init__(self, project_id: str, name: str) -> None:
        self.id = project_id
        self.name = name

    def __str__(self) -> str:
        return self.name
```

```python
print(project)
```

Output:

```text
Website Redesign
```

If `__str__` does not exist, Python may fall back to `__repr__`.

---

# B.10 `__eq__` and `__hash__`

## Equality

By default, custom objects compare by identity:

```python
first = Project("project-123", "Website Redesign")
second = Project("project-123", "Website Redesign")

print(first == second)
```

Without `__eq__`, output is:

```text
False
```

Define value-based equality when it makes domain sense:

```python
class Project:
    def __init__(self, project_id: str, name: str) -> None:
        self.id = project_id
        self.name = name

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Project):
            return NotImplemented

        return self.id == other.id
```

Now:

```python
print(first == second)
```

Output:

```text
True
```

Return `NotImplemented` for unrelated types. This lets Python try reflected comparison behavior and apply normal fallback rules.

## Hashing

If objects define value equality and must work in sets or as dictionary keys, define a matching hash:

```python
class Project:
    def __hash__(self) -> int:
        return hash(self.id)
```

Then:

```python
projects = {
    Project("project-123", "Website Redesign"),
    Project("project-123", "Duplicate Record"),
}

print(len(projects))
```

Output:

```text
1
```

## Hashing Rule

This must always hold:

```text
If a == b, then hash(a) == hash(b).
```

Only hash objects whose identity fields remain stable.

A frozen data class is often an excellent choice:

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class ProjectKey:
    id: str
```

Python can generate appropriate equality and hashing behavior for immutable data classes.

---

# B.11 `__len__`, `__iter__`, and `__contains__`

## `__len__`

Implement `__len__` when an object has a meaningful number of contained items:

```python
class Library:
    def __init__(self) -> None:
        self._items: dict[str, LendingItem] = {}

    def __len__(self) -> int:
        return len(self._items)
```

Usage:

```python
print(len(library))
```

## `__iter__`

Implement `__iter__` when users should naturally loop over your object:

```python
from collections.abc import Iterator


class Library:
    def __iter__(self) -> Iterator[LendingItem]:
        return iter(self._items.values())
```

Usage:

```python
for item in library:
    print(item)
```

## `__contains__`

Implement `__contains__` when membership has a clear meaning:

```python
class Library:
    def __contains__(self, identifier: object) -> bool:
        return isinstance(identifier, str) and identifier in self._items
```

Usage:

```python
if "BOOK-001" in library:
    print("Item exists.")
```

Using `object` as the parameter type is correct because Python permits any expression on the left side of `in`.

---

# B.12 Iterator Objects: `__iter__` and `__next__`

A custom iterator returns values one at a time.

```python
from collections.abc import Iterator


class NumberIterator(Iterator[int]):
    def __init__(self, maximum: int) -> None:
        self._current = 1
        self._maximum = maximum

    def __iter__(self) -> NumberIterator:
        return self

    def __next__(self) -> int:
        if self._current > self._maximum:
            raise StopIteration

        value = self._current
        self._current += 1

        return value
```

Usage:

```python
for number in NumberIterator(3):
    print(number)
```

Output:

```text
1
2
3
```

Use an iterator class when you need explicit state and reusable iteration machinery. Use a generator function when the logic can be expressed more simply with `yield`.

---

# B.13 Context Managers: `__enter__` and `__exit__`

A context manager manages setup and cleanup around a block.

```python
class Resource:
    def __enter__(self) -> Resource:
        print("Opening resource.")
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        print("Closing resource.")
        return False
```

Usage:

```python
with Resource() as resource:
    print("Using resource.")
```

Output:

```text
Opening resource.
Using resource.
Closing resource.
```

Returning `False` means:

> Do not suppress exceptions from inside the `with` block.

Use context managers for:

- Files
- Database connections
- API clients
- Locks
- Temporary directories
- Transactions
- Resource pools

---

# B.14 `__call__`: Callable Objects

An object becomes callable when it defines `__call__`.

```python
class PrefixFormatter:
    def __init__(self, prefix: str) -> None:
        self._prefix = prefix

    def __call__(self, message: str) -> str:
        return f"{self._prefix}: {message}"
```

Usage:

```python
format_info = PrefixFormatter("INFO")

print(format_info("Connected"))
```

Output:

```text
INFO: Connected
```

Callable objects are useful when a callback needs state but creating a closure is not sufficiently clear.

---

# B.15 `@classmethod` and Alternate Constructors

A class method receives `cls`, the class itself.

```python
class Project:
    def __init__(self, project_id: str, name: str) -> None:
        self.id = project_id
        self.name = name

    @classmethod
    def from_mapping(cls, payload: dict[str, str]) -> Project:
        return cls(
            project_id=payload["id"],
            name=payload["name"],
        )
```

Usage:

```python
project = Project.from_mapping(
    {
        "id": "project-123",
        "name": "Website Redesign",
    }
)
```

This pattern is useful for:

- JSON/API parsing
- Database row parsing
- Environment-based construction
- File deserialization
- Named construction modes

The capstone uses this pattern:

```python
Project.from_api_payload(payload)
CraftApiConfig.from_environment()
```

---

# B.16 `@staticmethod`

A static method belongs in a class namespace but does not use instance or class state.

```python
class ProjectValidator:
    @staticmethod
    def is_valid_identifier(value: str) -> bool:
        return bool(value.strip())
```

Usage:

```python
print(ProjectValidator.is_valid_identifier("project-123"))
```

A static method can sometimes be appropriate, but do not use it merely to avoid creating a module-level function.

A simple rule:

- Use an instance method when behavior uses object state.
- Use a class method when behavior uses class state or constructs instances.
- Use a static method only when the helper conceptually belongs to the class.
- Use a module-level function when it does not need class association.

---

# B.17 Data Classes

A data class reduces repetitive boilerplate for objects that mainly store data.

```python
from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class ApiErrorDetails:
    status_code: int
    method: str
    url: str
    response_body: str | None = None
```

Python generates:

- `__init__`
- `__repr__`
- `__eq__`

With `frozen=True`, it also prevents mutation.

```python
details = ApiErrorDetails(
    status_code=404,
    method="GET",
    url="https://api.example.test/projects/missing",
)

details.status_code = 200
```

This raises an error because the object is immutable.

Use data classes for stable records such as:

- API response models
- Configuration objects
- Event records
- Error details
- Value objects

Avoid using a data class automatically for every class. Classes with substantial business behavior may be clearer as ordinary classes.

---

# B.18 OOP Design Checklist

Before creating a new class, ask:

1. Does this represent a meaningful domain concept?
2. Does it own related data and behavior?
3. Is there a clear invariant it should protect?
4. Should it be mutable or immutable?
5. Is inheritance truly an “is a” relationship?
6. Would composition make the design simpler?
7. Which methods are part of the public interface?
8. Which attributes should remain internal?
9. Which dunder methods make normal usage clearer?
10. Can the class be constructed and tested without hidden global state?

---

# B.19 Common OOP Mistakes

## Mistake: God Objects

A “god object” does too much:

```python
class EverythingManager:
    def fetch_api_data(self) -> None:
        ...

    def write_files(self) -> None:
        ...

    def send_emails(self) -> None:
        ...

    def validate_projects(self) -> None:
        ...

    def calculate_payroll(self) -> None:
        ...
```

Fix: separate responsibilities into focused components.

---

## Mistake: Inheritance Only to Reuse Code

Do not inherit merely because two classes share a helper method.

Bad reasoning:

> `EmailSender` and `PdfGenerator` both need logging, so one should inherit from the other.

Better approaches:

- A shared module-level helper
- Composition
- A dedicated service
- A focused mixin, used sparingly

---

## Mistake: Public Mutable Internal Collections

Avoid this:

```python
class Library:
    def __init__(self) -> None:
        self.items: list[Book] = []
```

Callers can mutate the internal collection:

```python
library.items.clear()
```

Prefer internal storage and deliberate access methods:

```python
class Library:
    def __init__(self) -> None:
        self._items: list[Book] = []

    def items(self) -> tuple[Book, ...]:
        return tuple(self._items)
```

---

## Mistake: Overloading Dunder Methods for Cleverness

Do not implement a dunder method unless its behavior is intuitive.

For example, `len(library)` makes sense.

But making this mean “check out an item” does not:

```python
library + book
```

Pythonic design favors predictable, conventional behavior.
