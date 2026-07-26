# Pythonic Craftsmanship  
## Student Notes

A compact reference companion for the full tutorial series.

---

# 1. Core Mindset

Pythonic code is not simply short code. It is code that:

- Clearly communicates intent.
- Uses Python’s built-in strengths.
- Validates inputs at system boundaries.
- Keeps responsibilities separate.
- Raises meaningful errors.
- Is easy to test and change.
- Avoids unnecessary complexity.

A useful engineering principle:

> Make invalid states difficult to create, and make correct usage easy to discover.

---

# 2. Project Workflow

A reliable Python development loop:

```text
Create or update code
    ↓
Run focused verification
    ↓
Run tests
    ↓
Run type checks
    ↓
Review Git diff
    ↓
Commit focused change
```

Common commands:

```bash
python -m pytest
python -m pytest --verbose
python -m mypy src tests
python -m pip install --editable ".[dev]"
python -m build
git status
git diff
git diff --staged
```

---

# 3. Virtual Environments

A virtual environment isolates dependencies for one project.

Create one:

```bash
python -m venv .venv
```

Activate it.

### macOS or Linux

```bash
source .venv/bin/activate
```

### Windows PowerShell

```powershell
.\.venv\Scripts\Activate.ps1
```

Install dependencies through the active interpreter:

```bash
python -m pip install --editable ".[dev]"
```

Verify that the correct Python is active.

### macOS or Linux

```bash
which python
```

### Windows PowerShell

```powershell
Get-Command python
```

The path should include `.venv`.

---

# 4. Python Syntax Essentials

## Common Types

```python
name: str = "Website Redesign"
count: int = 3
timeout: float = 10.0
is_active: bool = True
description: str | None = None
```

## Collections

```python
project_ids: list[str] = ["project-001", "project-002"]

projects_by_id: dict[str, str] = {
    "project-001": "Website Redesign",
}

statuses: set[str] = {"active", "archived"}

coordinates: tuple[float, float] = (51.5072, -0.1276)
```

## F-Strings

```python
project_name = "Website Redesign"

message = f"Project: {project_name}"
```

Use `!r` when debugging:

```python
print(f"Raw value: {project_name!r}")
```

---

# 5. Functions

A function should have one focused job.

```python
def normalize_project_name(name: str) -> str:
    """Return cleaned non-blank project text."""
    cleaned_name = name.strip()

    if not cleaned_name:
        raise ValueError("Project name cannot be blank.")

    return cleaned_name
```

Good functions usually:

- Have descriptive names.
- Validate relevant input.
- Return a predictable type.
- Avoid hidden global state.
- Keep side effects obvious.

---

# 6. Classes and Instances

A class is a blueprint. An instance is one object created from it.

```python
class Book:
    """Represent one physical library book."""

    def __init__(self, title: str, author: str, isbn: str) -> None:
        self.title = title
        self.author = author
        self.isbn = isbn
```

Create instances:

```python
book = Book(
    title="Clean Code",
    author="Robert C. Martin",
    isbn="978-0132350884",
)
```

`self` means the specific object receiving the method call.

---

# 7. Encapsulation and Properties

Keep internal state protected behind clear methods.

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

Use:

```python
book.check_out()
```

instead of:

```python
book._is_checked_out = True
```

The first preserves the object’s rules.

---

# 8. Inheritance and Composition

## Inheritance: “Is A”

```python
class LendingItem:
    ...

class Book(LendingItem):
    ...
```

Read:

> A `Book` is a `LendingItem`.

Use inheritance when subclasses share a stable conceptual contract.

## Composition: “Has A”

```python
class CraftApiClient:
    def __init__(self, transport: Transport) -> None:
        self._transport = transport
```

Read:

> A `CraftApiClient` has a `Transport`.

Default guideline:

> Prefer composition unless inheritance clearly represents an “is a” relationship.

---

# 9. Important Dunder Methods

| Method | Used By | Purpose |
|---|---|---|
| `__init__` | `ClassName(...)` | Initialize object |
| `__repr__` | `repr(value)` | Developer representation |
| `__str__` | `print(value)` | Human representation |
| `__eq__` | `a == b` | Equality comparison |
| `__hash__` | `set`, dict keys | Hashable values |
| `__len__` | `len(value)` | Collection size |
| `__iter__` | `for item in value` | Iteration |
| `__contains__` | `item in value` | Membership |
| `__enter__` | `with value as x` | Setup resource |
| `__exit__` | End of `with` | Cleanup resource |

Example:

```python
class Library:
    def __len__(self) -> int:
        return len(self._items_by_identifier)
```

Then:

```python
len(library)
```

works naturally.

---

# 10. Comprehensions

## List Comprehension

```python
active_names = [
    project.name
    for project in projects
    if project.status == "active"
]
```

## Dictionary Comprehension

```python
projects_by_id = {
    project.id: project
    for project in projects
}
```

## Set Comprehension

```python
statuses = {
    project.status
    for project in projects
}
```

Use comprehensions when the operation remains easy to read.

Prefer loops when you need:

- Logging
- Error handling
- Multiple statements
- Complex branches
- Duplicate validation

---

# 11. `collections`

## `Counter`

Count repeated values.

```python
from collections import Counter

status_counts = Counter(
    project.status
    for project in projects
)
```

## `defaultdict`

Group values by a key.

```python
from collections import defaultdict

projects_by_status: defaultdict[str, list[Project]] = defaultdict(list)

for project in projects:
    projects_by_status[project.status].append(project)
```

## `deque`

Keep a bounded history or efficient queue.

```python
from collections import deque

recent_events: deque[str] = deque(maxlen=100)
recent_events.append("Project created")
```

---

# 12. Iterators and Generators

An iterable can be looped over:

```python
for project in projects:
    print(project.name)
```

An iterator produces one value at a time:

```python
iterator = iter(projects)
first_project = next(iterator)
```

A generator function uses `yield`:

```python
from collections.abc import Iterator


def iter_active_projects(
    projects: list[Project],
) -> Iterator[Project]:
    for project in projects:
        if project.status == "active":
            yield project
```

Generators are lazy:

```python
results = iter_active_projects(projects)
```

No values are processed until you consume `results`:

```python
first_result = next(results)
```

---

# 13. `itertools`

Useful iterator tools:

```python
from itertools import chain, filterfalse, islice
```

## Combine Streams

```python
all_projects = chain(first_projects, second_projects)
```

## Take First N Items

```python
first_five = islice(projects, 5)
```

## Exclude Matching Values

```python
available_projects = filterfalse(
    lambda project: project.status == "archived",
    projects,
)
```

---

# 14. Context Managers

Use `with` for resources that must always be cleaned up.

```python
from pathlib import Path

with Path("report.txt").open("w", encoding="utf-8") as file_handle:
    file_handle.write("Report content\n")
```

Custom context manager structure:

```python
class Resource:
    def __enter__(self) -> Resource:
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        self.close()
        return False
```

Returning `False` means exceptions are not suppressed.

---

# 15. Functions as First-Class Objects

Functions can be stored and passed around.

```python
def print_event(message: str) -> None:
    print(message)


handler = print_event
handler("Project created")
```

Callback type:

```python
from collections.abc import Callable

EventHandler = Callable[[LibraryEvent], None]
```

A callback receives an event later:

```python
def record_event(event: LibraryEvent) -> None:
    print(event.event_type)
```

---

# 16. Closures

A closure remembers values from its enclosing scope.

```python
from collections.abc import Callable


def build_prefix_printer(prefix: str) -> Callable[[str], None]:
    def print_message(message: str) -> None:
        print(f"{prefix}: {message}")

    return print_message
```

Usage:

```python
info = build_prefix_printer("INFO")
info("Connected")
```

Output:

```text
INFO: Connected
```

---

# 17. `*args` and `**kwargs`

## `*args`

Collect extra positional arguments into a tuple.

```python
def describe_projects(*project_ids: str) -> None:
    for project_id in project_ids:
        print(project_id)
```

## `**kwargs`

Collect extra named arguments into a dictionary.

```python
def configure_client(**options: object) -> None:
    print(options)
```

Validate flexible arguments. Do not silently accept misspelled options.

```python
allowed_keys = {"timeout_seconds"}
unknown_keys = set(options) - allowed_keys

if unknown_keys:
    raise TypeError(f"Unsupported options: {unknown_keys}")
```

---

# 18. Decorators

A decorator wraps a function with reusable behavior.

```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def log_calls(
    function: Callable[Parameters, ReturnValue],
) -> Callable[Parameters, ReturnValue]:
    @wraps(function)
    def wrapper(
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        print(f"Calling {function.__qualname__}")
        return function(*args, **kwargs)

    return wrapper
```

Use:

```python
@log_calls
def get_project(project_id: str) -> str:
    return project_id
```

Always use:

```python
@wraps(function)
```

for normal decorators.

---

# 19. Testing with `pytest`

Run all tests:

```bash
python -m pytest
```

Test structure:

```python
def test_project_name_is_preserved() -> None:
    project = Project(...)
    assert project.name == "Website Redesign"
```

Test expected exceptions:

```python
import pytest


def test_blank_name_is_rejected() -> None:
    with pytest.raises(ValueError, match="cannot be blank"):
        normalize_project_name("   ")
```

Use fixtures for reusable setup:

```python
import pytest


@pytest.fixture
def api_config() -> CraftApiConfig:
    return CraftApiConfig(
        base_url="https://api.example.test",
        api_token="test-token",
    )
```

---

# 20. Type Hints and `mypy`

Run static analysis:

```bash
python -m mypy src tests
```

Annotate public functions:

```python
def get_project(project_id: str) -> Project:
    ...
```

Optional values:

```python
description: str | None
```

Use abstract interfaces for dependencies:

```python
from collections.abc import Mapping


def build_headers(
    values: Mapping[str, str],
) -> dict[str, str]:
    return dict(values)
```

Avoid spreading `Any` through your application. Validate dynamic JSON data at the boundary.

---

# 21. Protocols and Dependency Injection

A `Protocol` describes required behavior.

```python
from collections.abc import Mapping
from typing import Protocol


class Transport(Protocol):
    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        ...

    def close(self) -> None:
        ...
```

Dependency injection:

```python
client = CraftApiClient(
    config=config,
    transport=transport,
)
```

Benefits:

- Easy offline tests
- Replaceable implementations
- Clear dependencies
- Less hidden global state

---

# 22. API Client Architecture

```text
Application
    ↓
CraftApiClient
    ↓
Transport Protocol
    ↓
UrllibTransport
    ↓
HTTPS API
```

## Configuration Layer

Responsible for:

- Base URL
- API token
- Timeout
- Environment variables
- Validation

## Model Layer

Responsible for:

- Converting JSON to typed Python objects
- Validating fields
- Parsing timestamps
- Preventing malformed data from spreading

## Transport Layer

Responsible for:

- HTTP requests
- Request bodies
- Response bodies
- Network errors
- HTTP status translation
- Retry policy

## Client Layer

Responsible for:

- User-friendly methods
- URL construction
- Authorization headers
- Pagination
- Context management
- Model creation

---

# 23. Configuration and Secrets

Use environment variables:

```text
CRAFTAPI_BASE_URL
CRAFTAPI_API_TOKEN
CRAFTAPI_TIMEOUT_SECONDS
```

Never hard-code a real token:

```python
# Never do this.
api_token = "real-secret-token"
```

Safe configuration:

```python
config = CraftApiConfig.from_environment()
```

Never commit:

```text
.env
tokens
passwords
private keys
authorization headers
```

---

# 24. API Exceptions

| Exception | Meaning |
|---|---|
| `CraftApiConfigurationError` | Invalid URL, token, or timeout |
| `CraftApiTransportError` | Network, DNS, TLS, or connection failure |
| `CraftApiAuthenticationError` | HTTP 401 or 403 |
| `CraftApiNotFoundError` | HTTP 404 |
| `CraftApiServerError` | HTTP 5xx |
| `CraftApiResponseError` | Other unsuccessful HTTP response |
| `CraftApiValidationError` | Invalid JSON or schema mismatch |

Example handling:

```python
try:
    project = client.get_project("project-123")
except CraftApiNotFoundError:
    print("Project does not exist.")
except CraftApiAuthenticationError:
    print("Check API credentials.")
except CraftApiTransportError:
    print("API could not be reached.")
```

---

# 25. JSON Validation

External JSON is untrusted.

```python
from collections.abc import Mapping
from typing import Any


def required_non_blank_string(
    payload: Mapping[str, Any],
    field_name: str,
) -> str:
    value = payload.get(field_name)

    if not isinstance(value, str):
        raise CraftApiValidationError(
            f'API field "{field_name}" must be a string.'
        )

    cleaned_value = value.strip()

    if not cleaned_value:
        raise CraftApiValidationError(
            f'API field "{field_name}" cannot be blank.'
        )

    return cleaned_value
```

Boundary principle:

```text
External JSON
    ↓ validate
Typed domain model
```

---

# 26. HTTP Status Handling

| Status | Meaning | Client Response |
|---:|---|---|
| 200–299 | Success | Parse response |
| 401 | Invalid/missing authentication | Raise authentication error |
| 403 | Insufficient permission | Raise authentication error |
| 404 | Missing resource | Raise not-found error |
| 429 | Rate limited | Consider safe retry/backoff |
| 500–599 | Server failure | Raise server error; retry safe reads cautiously |

---

# 27. URL Encoding

Never place user-controlled identifiers directly into paths.

```python
from urllib.parse import quote

encoded_id = quote(project_id, safe="")
```

Example:

```python
quote("project / 123", safe="")
```

Output:

```text
project%20%2F%20123
```

This prevents slashes and spaces from changing the URL path structure.

---

# 28. Pagination

A paginated API may return:

```json
{
  "items": [],
  "next_page": 2
}
```

Use a generator for lazy page consumption:

```python
def iter_projects(
    self,
    *,
    page_size: int = 100,
) -> Iterator[Project]:
    ...
```

Protect against repeated page numbers:

```python
visited_page_numbers: set[int] = set()

if page_number in visited_page_numbers:
    raise CraftApiValidationError(
        "API pagination repeated a page number."
    )
```

Reject booleans when validating integer page values:

```python
if isinstance(page_size, bool) or not isinstance(page_size, int):
    raise TypeError("Page size must be an integer.")
```

---

# 29. Safe Retries

Retry only temporary failures and safe operations.

Good default retry candidates:

```text
GET
HEAD
OPTIONS
PUT
DELETE
```

Avoid automatic retries for:

```text
POST
Payments
Resource creation
Irreversible actions
```

Exponential backoff:

```text
0.25 seconds
0.50 seconds
1.00 seconds
2.00 seconds
```

A retry policy should define:

```python
RetryPolicy(
    max_attempts=3,
    initial_delay_seconds=0.25,
    maximum_delay_seconds=2.0,
)
```

---

# 30. Logging Safely

Safe log fields:

```text
HTTP method
Status code
Request duration
Retry attempt
Safe URL
Exception type
```

Unsafe log fields:

```text
Authorization header
API token
Password
Cookie
Private request body
Sensitive response data
```

Libraries should create module loggers:

```python
import logging

LOGGER = logging.getLogger(__name__)
```

Applications configure logging:

```python
logging.basicConfig(level=logging.INFO)
```

---

# 31. Packaging and Release Commands

Install development dependencies:

```bash
python -m pip install --editable ".[dev]"
```

Test:

```bash
python -m pytest
```

Type check:

```bash
python -m mypy src tests
```

Build:

```bash
python -m build
```

Expected release artifacts:

```text
dist/
├── craftapi-0.1.0-py3-none-any.whl
└── craftapi-0.1.0.tar.gz
```

Test the wheel in a fresh virtual environment before release.

---

# 32. Final Engineering Checklist

Before shipping:

- [ ] Project uses a virtual environment.
- [ ] Package uses `src/` layout.
- [ ] Tests pass.
- [ ] Type checks pass.
- [ ] Configuration validates inputs.
- [ ] Secrets are not in source control.
- [ ] Logs do not expose credentials.
- [ ] External JSON is validated.
- [ ] Errors are domain-specific and meaningful.
- [ ] Retries are safe and narrow.
- [ ] Package builds successfully.
- [ ] Wheel installs in a clean environment.
- [ ] README documents installation and configuration.
- [ ] Git working tree is clean.

---

# Personal Notes

## Concepts I Need to Revisit

```text
1.
2.
3.
```

## Commands I Use Most Often

```bash
```

```bash
```

```bash
```

## My Next Python Project

```text
```
