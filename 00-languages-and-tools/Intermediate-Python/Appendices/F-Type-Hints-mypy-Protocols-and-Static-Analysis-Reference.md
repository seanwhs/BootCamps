# Appendix F: Type Hints, `mypy`, Protocols, and Static Analysis Reference

Type hints make Python code easier to understand and safer to change.

They answer questions such as:

- What kind of value should this function receive?
- What does it return?
- Can this value be `None`?
- What keys exist in this dictionary?
- What methods must a dependency provide?
- Will a decorator preserve a function’s signature?

Python does not enforce most hints at runtime. Instead, static analysis tools—especially `mypy`—inspect the source before execution.

Think of type checking as a blueprint review before construction begins. It cannot prove every real-world outcome, but it catches many interface mismatches early.

---

# F.1 Run `mypy`

From a project root:

```bash
python -m mypy src tests
```

If configured in `pyproject.toml`, this may also work:

```bash
python -m mypy
```

Check a focused module:

```bash
python -m mypy src/craftapi/client.py
```

Show error codes:

```bash
python -m mypy src tests --show-error-codes
```

Example successful output:

```text
Success: no issues found in 12 source files
```

---

# F.2 Basic Variable Annotations

```python
project_id: str = "project-123"
timeout_seconds: float = 10.0
attempt_count: int = 3
is_active: bool = True
```

Collections should include their item types:

```python
project_ids: list[str] = ["project-001", "project-002"]

projects_by_id: dict[str, Project] = {}

visited_page_numbers: set[int] = set()

headers: dict[str, str] = {
    "Accept": "application/json",
}
```

Tuples:

```python
coordinates: tuple[float, float] = (51.5072, -0.1276)

response_codes: tuple[int, ...] = (200, 201, 204)
```

The `...` means any number of integers.

---

# F.3 Function Annotations

Annotate both parameters and return type.

```python
def normalize_project_name(name: str) -> str:
    return name.strip()
```

A procedure that returns nothing:

```python
def print_project_name(name: str) -> None:
    print(name)
```

Multiple parameters:

```python
def build_project_url(base_url: str, project_id: str) -> str:
    return f"{base_url}/projects/{project_id}"
```

A function that may not find a value:

```python
def find_cached_project(
    project_id: str,
    cache: dict[str, Project],
) -> Project | None:
    return cache.get(project_id)
```

Do not promise `Project` if `None` is possible.

---

# F.4 Union Types and `None`

Modern Python uses `|` for unions:

```python
description: str | None
```

This means:

> `description` is either a string or `None`.

Equivalent older spelling:

```python
from typing import Optional

description: Optional[str]
```

Prefer the modern form for Python 3.10+ projects.

## Narrowing Optional Values

```python
def print_description(description: str | None) -> None:
    if description is None:
        print("No description provided.")
        return

    print(description.upper())
```

After this check, `mypy` knows `description` is a `str`.

Avoid:

```python
def print_description(description: str | None) -> None:
    print(description.upper())
```

A `None` value has no `.upper()` method.

---

# F.5 Collection Types

Use concrete collection types when callers receive or own a concrete collection.

```python
def collect_project_ids(projects: list[Project]) -> list[str]:
    return [project.id for project in projects]
```

Use abstract collection interfaces when you only need behavior.

```python
from collections.abc import Iterable, Iterator, Mapping, Sequence


def iter_project_ids(projects: Iterable[Project]) -> Iterator[str]:
    for project in projects:
        yield project.id
```

```python
def first_project(projects: Sequence[Project]) -> Project | None:
    if not projects:
        return None

    return projects[0]
```

```python
def authorization_header(config: Mapping[str, str]) -> str:
    return config["Authorization"]
```

Useful abstract types:

| Type | Use when you need |
|---|---|
| `Iterable[T]` | Values can be looped over |
| `Iterator[T]` | Values are yielded one at a time |
| `Sequence[T]` | Ordered, indexable collection |
| `Mapping[K, V]` | Read-only key/value lookup behavior |
| `MutableMapping[K, V]` | Key/value lookup and mutation |
| `Collection[T]` | Iteration, `len()`, and membership |
| `Callable[...]` | Function-like behavior |

---

# F.6 `Any` versus `object`

## `Any`

`Any` disables much static checking.

```python
from typing import Any

payload: Any = get_untyped_response()

project_id: str = payload["id"]
```

`mypy` often allows operations on `Any`, even when they may fail at runtime.

Use `Any` only at unavoidable dynamic boundaries, such as JSON decoding.

## `object`

`object` means “some value exists, but its specific type is unknown.”

```python
def describe(value: object) -> str:
    return repr(value)
```

You cannot call arbitrary methods on `object`:

```python
def unsafe(value: object) -> str:
    return value.upper()
```

`mypy` rejects that because not every object has `.upper()`.

Use `object` when you truly accept any value but do not need arbitrary operations.

Example:

```python
def __contains__(self, identifier: object) -> bool:
    return isinstance(identifier, str) and identifier in self._items
```

---

# F.7 JSON Boundaries and `Any`

`json.loads()` returns dynamic JSON data:

```python
import json
from typing import Any

decoded: Any = json.loads(response_text)
```

Do not spread `Any` through the codebase.

Validate it immediately:

```python
from collections.abc import Mapping
from typing import Any


def require_object(value: Any) -> Mapping[str, Any]:
    if not isinstance(value, dict):
        raise ValueError("Expected JSON object.")

    return value
```

Then convert it into typed domain models:

```python
payload = require_object(decoded)
project = Project.from_api_payload(payload)
```

Boundary rule:

```text
Untyped external data
    ↓ validate
Typed internal model
```

---

# F.8 `TypedDict` for Known Dictionary Shapes

A `TypedDict` describes a dictionary with known keys.

```python
from typing import NotRequired, TypedDict


class ProjectPayload(TypedDict):
    id: str
    name: str
    status: str
    created_at: str
    description: NotRequired[str]
```

Use it:

```python
def project_name(payload: ProjectPayload) -> str:
    return payload["name"]
```

A `TypedDict` is useful when you intentionally work with dictionaries after validation.

However, for stable domain objects, a data class is often better:

```python
@dataclass(frozen=True, slots=True)
class Project:
    id: str
    name: str
    status: str
    created_at: datetime
    description: str | None = None
```

Use `TypedDict` for structured dictionary payloads; use data classes for internal domain models.

---

# F.9 Data Classes and Type Checking

```python
from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True, slots=True)
class Project:
    id: str
    name: str
    status: str
    created_at: datetime
    description: str | None = None
```

`mypy` understands generated data-class constructors:

```python
project = Project(
    id="project-123",
    name="Website Redesign",
    status="active",
    created_at=datetime.now(),
)
```

It detects missing or incorrectly typed fields:

```python
Project(
    id=123,
    name="Website Redesign",
    status="active",
    created_at=datetime.now(),
)
```

---

# F.10 `Literal`

`Literal` limits a value to a known set of exact values.

```python
from typing import Literal

ProjectStatus = Literal["active", "archived", "paused"]


def is_open_status(status: ProjectStatus) -> bool:
    return status in {"active", "paused"}
```

Useful for:

- Event types
- Configuration modes
- Known status strings
- HTTP method wrappers
- Feature flags

Example:

```python
LibraryEventType = Literal[
    "item_added",
    "item_checked_out",
    "item_returned",
]
```

Avoid `Literal` for values controlled by an external API unless the API contract is truly stable and you have a strategy for unknown future values.

---

# F.11 `NewType`

`NewType` creates a distinct static type from an existing runtime type.

```python
from typing import NewType

ProjectId = NewType("ProjectId", str)
ApiToken = NewType("ApiToken", str)
```

Usage:

```python
def get_project(project_id: ProjectId) -> Project:
    ...


project_id = ProjectId("project-123")
```

This helps prevent accidental mixing:

```python
get_project(ApiToken("secret-token"))
```

At runtime, `NewType` values behave like their underlying type.

Use it when several strings represent different concepts and accidental mixing is costly.

---

# F.12 `Protocol` and Structural Typing

A `Protocol` specifies required behavior without requiring inheritance.

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

Any class that provides compatible methods satisfies this contract:

```python
class FakeTransport:
    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        return HttpResponse(
            status_code=200,
            url=url,
            headers={},
            body=b"{}",
        )

    def close(self) -> None:
        return None
```

`FakeTransport` does not need to inherit from `Transport`.

This is ideal for dependency injection and testing.

## Runtime-Checkable Protocols

If you use a protocol with `isinstance()`, add `@runtime_checkable`:

```python
from typing import Protocol, runtime_checkable


@runtime_checkable
class Closable(Protocol):
    def close(self) -> None:
        ...
```

Then:

```python
isinstance(value, Closable)
```

Without `@runtime_checkable`, Python raises `TypeError`.

Use runtime protocol checks sparingly. Prefer static typing and explicit dependencies when possible.

---

# F.13 `Callable`

`Callable` describes a function-like value.

```python
from collections.abc import Callable

EventHandler = Callable[[LibraryEvent], None]
```

Meaning:

```text
A callable accepting one LibraryEvent and returning None.
```

Examples:

```python
def print_event(event: LibraryEvent) -> None:
    print(event)


handler: EventHandler = print_event
```

A callback returning a string:

```python
Formatter = Callable[[Project], str]
```

```python
def format_project(project: Project) -> str:
    return f"{project.id}: {project.name}"
```

---

# F.14 Generics and `TypeVar`

A generic function preserves input type information.

```python
from typing import TypeVar

Item = TypeVar("Item")


def first_or_none(items: list[Item]) -> Item | None:
    if not items:
        return None

    return items[0]
```

Usage:

```python
first_name = first_or_none(["Ada", "Grace"])
```

`mypy` infers:

```python
first_name: str | None
```

Another example:

```python
from collections.abc import Iterable, Iterator
from typing import TypeVar

Item = TypeVar("Item")


def iter_non_none(items: Iterable[Item | None]) -> Iterator[Item]:
    for item in items:
        if item is not None:
            yield item
```

---

# F.15 `ParamSpec` for Decorators

A decorator needs to preserve a wrapped function’s parameter list.

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

Without `ParamSpec`, a decorator often degrades the type checker’s understanding of the wrapped function.

---

# F.16 Type Narrowing with `isinstance`

A type checker can refine a union after a runtime check.

```python
def normalize_identifier(value: str | int) -> str:
    if isinstance(value, int):
        return str(value)

    return value.strip()
```

After:

```python
if isinstance(value, int):
```

`mypy` knows the remaining branch contains a `str`.

For JSON:

```python
from typing import Any


def require_string(value: Any) -> str:
    if not isinstance(value, str):
        raise ValueError("Expected string.")

    return value
```

After the check, `value` is known to be `str`.

---

# F.17 `cast()`

`typing.cast()` tells the type checker to treat a value as a type without changing runtime behavior.

```python
from typing import Any, cast

raw_value: Any = "project-123"
project_id = cast(str, raw_value)
```

Use `cast()` only after you have independently proven the type through validation or an external guarantee.

Bad:

```python
project_id = cast(str, raw_value)
print(project_id.upper())
```

If `raw_value` is actually an integer, this still fails at runtime.

Better:

```python
if not isinstance(raw_value, str):
    raise ValueError("Expected project ID string.")

project_id = raw_value
```

Prefer runtime validation over `cast()` whenever possible.

---

# F.18 Type Aliases

A type alias gives a meaningful name to a complex type.

```python
from collections.abc import Mapping
from typing import Any, TypeAlias

JsonObject: TypeAlias = Mapping[str, Any]
```

Usage:

```python
def parse_project(payload: JsonObject) -> Project:
    return Project.from_api_payload(payload)
```

Other useful aliases:

```python
Headers: TypeAlias = Mapping[str, str]
QueryParameters: TypeAlias = Mapping[str, str | int]
```

Use aliases when the concept is used repeatedly and naming it improves understanding.

---

# F.19 `mypy` Configuration

A practical `pyproject.toml` setup:

```toml
[tool.mypy]
python_version = "3.11"
files = ["src", "tests"]
warn_unused_configs = true
warn_unused_ignores = true
check_untyped_defs = true
disallow_any_generics = true
disallow_untyped_defs = true
no_implicit_optional = true
strict_equality = true
```

Key options:

| Option | Purpose |
|---|---|
| `disallow_untyped_defs` | Require function parameter and return annotations |
| `check_untyped_defs` | Analyze bodies of untyped functions |
| `no_implicit_optional` | Require explicit `T \| None` |
| `disallow_any_generics` | Reject vague `list` and `dict` without type arguments |
| `warn_unused_ignores` | Detect stale `# type: ignore` comments |
| `strict_equality` | Flag suspicious equality comparisons |

You can enable strict mode gradually:

```toml
[tool.mypy]
strict = true
```

This is excellent for new projects, but may produce many findings in older codebases.

---

# F.20 `# type: ignore` Is a Last Resort

Sometimes a third-party library has incomplete types.

Use narrow ignore comments with an error code:

```python
untyped_library.do_work()  # type: ignore[no-untyped-call]
```

Do not use broad ignores casually:

```python
untyped_library.do_work()  # type: ignore
```

Every ignore is a small hole in static verification. Document why it is necessary and revisit it after dependency updates.

---

# F.21 Type Checking versus Runtime Validation

Type hints cannot protect you from untrusted runtime input.

This may type-check:

```python
def get_project(project_id: str) -> Project:
    ...
```

But an external HTTP request may still supply:

```python
project_id = ""
```

or:

```python
project_id = "   "
```

Use runtime validation too:

```python
def normalize_project_id(project_id: str) -> str:
    cleaned_project_id = project_id.strip()

    if not cleaned_project_id:
        raise ValueError("Project ID cannot be blank.")

    return cleaned_project_id
```

Use both layers:

```text
Static type checking
    ↓ catches developer misuse
Runtime validation
    ↓ catches untrusted external data
```

---

# F.22 Common Type-Hint Mistakes

## Missing Return Type

```python
def create_project(name: str):
    ...
```

Prefer:

```python
def create_project(name: str) -> Project:
    ...
```

---

## Implicit Optional Value

```python
def find_project(project_id: str = None) -> Project:
    ...
```

Incorrect because `None` is not a string.

Prefer:

```python
def find_project(project_id: str | None = None) -> Project | None:
    ...
```

Or use a separate required method if absence is not valid.

---

## Unparameterized Collections

```python
projects: list = []
```

Prefer:

```python
projects: list[Project] = []
```

---

## Using `dict` for Everything

```python
def get_project() -> dict[str, object]:
    ...
```

A dictionary may be appropriate at a JSON boundary, but internal code is usually safer with a model:

```python
def get_project() -> Project:
    ...
```

---

## Treating `bool` as a Normal `int`

```python
isinstance(True, int)  # True
```

When validating integer values from external input, explicitly reject booleans:

```python
if isinstance(value, bool) or not isinstance(value, int):
    raise ValueError("Expected integer.")
```

---

# F.23 Type-Hinting Checklist

Before finishing a module, ask:

- Are all public functions and methods annotated?
- Do return types include `None` when absence is possible?
- Are containers parameterized?
- Are external JSON values validated before reaching domain code?
- Is `Any` limited to unavoidable boundaries?
- Would `Protocol` make a dependency easier to test?
- Are decorators using `ParamSpec` and `TypeVar`?
- Are custom exceptions documented in method docstrings?
- Does `mypy` pass without unnecessary ignores?
[STARTING NEXT: Appendix G — HTTP, API Client, and Network Troubleshooting Guide]
