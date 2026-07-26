# Appendix I: Common Python Mistakes, Anti-Patterns, and Corrective Patterns

Python is designed to be expressive, which means it is easy to write code that appears correct but behaves unexpectedly in edge cases.

This appendix collects common mistakes encountered when moving from scripts to maintainable packages.

Each entry includes:

- **The problem**
- **Why it happens**
- **The incorrect pattern**
- **The corrected pattern**

The goal is not to memorize every rule. It is to develop a habit of asking:

> What happens when this code receives unexpected input, runs twice, fails halfway through, or is used by another developer?

---

# I.1 Mutable Default Arguments

## The Problem

A function parameter uses a mutable object such as a list or dictionary as its default value.

## Incorrect Pattern

```python
def add_project(
    project_id: str,
    project_ids: list[str] = [],
) -> list[str]:
    """Add a project identifier to a list."""
    project_ids.append(project_id)

    return project_ids
```

```python
print(add_project("project-001"))
print(add_project("project-002"))
```

Unexpected output:

```text
['project-001']
['project-001', 'project-002']
```

The list is created once, when Python defines the function—not every time it is called.

## Correct Pattern

```python
def add_project(
    project_id: str,
    project_ids: list[str] | None = None,
) -> list[str]:
    """Add a project identifier to a caller-provided or new list."""
    if project_ids is None:
        project_ids = []

    project_ids.append(project_id)

    return project_ids
```

```python
print(add_project("project-001"))
print(add_project("project-002"))
```

Expected output:

```text
['project-001']
['project-002']
```

Use `None` as the default, then create a fresh mutable object inside the function.

---

# I.2 Mutable Class Attributes

## The Problem

A mutable attribute is declared on a class when it should belong to each instance.

## Incorrect Pattern

```python
class ProjectCache:
    """Incorrectly shares project IDs across all instances."""

    project_ids: list[str] = []

    def add(self, project_id: str) -> None:
        self.project_ids.append(project_id)
```

```python
first_cache = ProjectCache()
second_cache = ProjectCache()

first_cache.add("project-001")

print(second_cache.project_ids)
```

Unexpected output:

```text
['project-001']
```

## Correct Pattern

```python
class ProjectCache:
    """Stores project IDs separately for each cache instance."""

    def __init__(self) -> None:
        self.project_ids: list[str] = []

    def add(self, project_id: str) -> None:
        self.project_ids.append(project_id)
```

```python
first_cache = ProjectCache()
second_cache = ProjectCache()

first_cache.add("project-001")

print(second_cache.project_ids)
```

Expected output:

```text
[]
```

---

# I.3 Catching Every Exception

## The Problem

Broad exception handling hides bugs and makes failures difficult to diagnose.

## Incorrect Pattern

```python
def get_project_name(client: CraftApiClient, project_id: str) -> str | None:
    """Fetch a project name, hiding every possible failure."""
    try:
        return client.get_project(project_id).name
    except Exception:
        return None
```

This hides:

- Authentication failures
- Network outages
- Schema validation errors
- Programming errors
- Unexpected `AttributeError` or `TypeError`

## Correct Pattern

Catch only errors you understand and can handle.

```python
from craftapi import CraftApiNotFoundError, CraftApiTransportError


def get_project_name(
    client: CraftApiClient,
    project_id: str,
) -> str | None:
    """Return a project name or None for an absent project."""
    try:
        return client.get_project(project_id).name
    except CraftApiNotFoundError:
        return None
    except CraftApiTransportError as error:
        raise RuntimeError("The Craft API could not be reached.") from error
```

Unexpected failures should normally propagate so they can be investigated.

---

# I.4 Swallowing Exceptions During Cleanup

## The Problem

Cleanup code hides a meaningful original error.

## Incorrect Pattern

```python
def save_project(path: Path, content: str) -> None:
    """Write content while incorrectly suppressing all errors."""
    try:
        path.write_text(content, encoding="utf-8")
    except Exception:
        pass
```

The caller cannot tell whether the file was written.

## Correct Pattern

Let the failure propagate unless you have a specific recovery strategy.

```python
def save_project(path: Path, content: str) -> None:
    """Write content to a UTF-8 file."""
    path.write_text(content, encoding="utf-8")
```

Or add context while preserving the cause:

```python
def save_project(path: Path, content: str) -> None:
    """Write content and raise a useful application error on failure."""
    try:
        path.write_text(content, encoding="utf-8")
    except OSError as error:
        raise RuntimeError(f"Could not write project file: {path}") from error
```

---

# I.5 Using `print()` Instead of Structured Logging

## The Problem

`print()` is useful for short scripts and tutorials but does not scale well for applications.

## Incorrect Pattern

```python
def fetch_project(client: CraftApiClient, project_id: str) -> Project:
    print(f"Fetching project {project_id}")
    return client.get_project(project_id)
```

Problems:

- No log levels
- No timestamps by default
- No centralized configuration
- Harder redirection and aggregation
- Easy accidental leakage of sensitive values

## Correct Pattern

```python
import logging

LOGGER = logging.getLogger(__name__)


def fetch_project(client: CraftApiClient, project_id: str) -> Project:
    """Fetch a project and emit safe operational metadata."""
    LOGGER.info("Fetching project: project_id=%s", project_id)

    return client.get_project(project_id)
```

Do not log tokens:

```python
# Never do this.
LOGGER.debug("Using token: %s", api_token)
```

---

# I.6 Building URLs with String Concatenation

## The Problem

String concatenation can produce malformed URLs and unsafe paths.

## Incorrect Pattern

```python
def project_url(base_url: str, project_id: str) -> str:
    return base_url + "/projects/" + project_id
```

If `project_id` contains `/`, spaces, or reserved URL characters, the request path may change meaning.

## Correct Pattern

```python
from urllib.parse import quote


def project_url(base_url: str, project_id: str) -> str:
    """Build a safe URL for a project resource."""
    encoded_project_id = quote(project_id.strip(), safe="")

    return f"{base_url.rstrip('/')}/projects/{encoded_project_id}"
```

Example:

```python
print(project_url("https://api.example.test/", "project / 123"))
```

Output:

```text
https://api.example.test/projects/project%20%2F%20123
```

---

# I.7 Treating Remote JSON as Trusted

## The Problem

Code assumes all API JSON fields exist and have the expected type.

## Incorrect Pattern

```python
def parse_project(payload: dict[str, object]) -> str:
    return payload["name"].strip()  # type: ignore[union-attr]
```

This can fail if:

- `"name"` is absent
- `"name"` is `None`
- `"name"` is an integer
- `"name"` contains only whitespace

## Correct Pattern

Validate at the boundary.

```python
from collections.abc import Mapping
from typing import Any

from craftapi import CraftApiValidationError


def required_non_blank_string(
    payload: Mapping[str, Any],
    field_name: str,
) -> str:
    """Read a required non-blank API string field."""
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

---

# I.8 Returning Internal Mutable Collections

## The Problem

A class exposes an internal list or dictionary directly.

## Incorrect Pattern

```python
class ProjectRegistry:
    def __init__(self) -> None:
        self._projects: list[Project] = []

    def projects(self) -> list[Project]:
        return self._projects
```

A caller can mutate internal state:

```python
registry.projects().clear()
```

## Correct Pattern

Return an immutable snapshot:

```python
class ProjectRegistry:
    def __init__(self) -> None:
        self._projects: list[Project] = []

    def projects(self) -> tuple[Project, ...]:
        """Return a read-only snapshot of registered projects."""
        return tuple(self._projects)
```

Or return a copied dictionary:

```python
def projects_by_id(self) -> dict[str, Project]:
    return dict(self._projects_by_id)
```

---

# I.9 Modifying a Collection During Iteration

## The Problem

Removing values from a list while iterating over the same list can skip elements.

## Incorrect Pattern

```python
for project in projects:
    if project.status == "archived":
        projects.remove(project)
```

## Correct Pattern: Build a New List

```python
active_projects = [
    project
    for project in projects
    if project.status != "archived"
]
```

## Correct Pattern: Replace Contents In Place

Use this only when other code intentionally holds a reference to the original list object.

```python
projects[:] = [
    project
    for project in projects
    if project.status != "archived"
]
```

---

# I.10 Confusing `is` and `==`

## The Problem

`is` checks whether two names reference the same object. `==` checks value equality.

## Incorrect Pattern

```python
if project.status is "active":
    ...
```

This may appear to work but is incorrect.

## Correct Pattern

```python
if project.status == "active":
    ...
```

Use `is` for singleton values such as `None`:

```python
if project.description is None:
    print("No description.")
```

Do not use:

```python
if project.description == None:
    ...
```

---

# I.11 Using `type(value) is ...` Instead of `isinstance()`

## The Problem

Exact type checks reject subclasses unnecessarily.

## Incorrect Pattern

```python
if type(value) is str:
    ...
```

## Correct Pattern

```python
if isinstance(value, str):
    ...
```

Use exact type comparison only when that exact distinction is truly required.

One example is equality definitions that intentionally distinguish concrete resource types:

```python
return type(self) is type(other) and self.identifier == other.identifier
```

That is a domain rule, not general input validation.

---

# I.12 Forgetting That `bool` Is an `int`

## The Problem

Python considers booleans integers:

```python
isinstance(True, int)  # True
```

## Incorrect Pattern

```python
def validate_page_number(value: object) -> int:
    if not isinstance(value, int):
        raise ValueError("Page number must be an integer.")

    return value
```

This accepts `True`.

## Correct Pattern

```python
def validate_page_number(value: object) -> int:
    """Validate a positive non-boolean page number."""
    if isinstance(value, bool) or not isinstance(value, int):
        raise ValueError("Page number must be an integer.")

    if value < 1:
        raise ValueError("Page number must be positive.")

    return value
```

This matters especially when validating untrusted JSON.

---

# I.13 Losing Exceptions During Error Translation

## The Problem

A custom exception replaces the original error without preserving its cause.

## Incorrect Pattern

```python
try:
    response = payload["project"]
except KeyError:
    raise CraftApiValidationError("Project payload is missing.")
```

The traceback loses the original `KeyError`.

## Correct Pattern

```python
try:
    response = payload["project"]
except KeyError as error:
    raise CraftApiValidationError(
        "Project payload is missing."
    ) from error
```

Use `raise ... from error` when translating an implementation-level failure into a domain-level failure.

---

# I.14 Using `except:`

## The Problem

A bare `except:` catches nearly everything, including `KeyboardInterrupt` and `SystemExit`.

## Incorrect Pattern

```python
try:
    run_program()
except:
    print("Something failed.")
```

## Correct Pattern

```python
try:
    run_program()
except Exception as error:
    print(f"Program failed: {error}")
    raise
```

Better still, catch only expected exceptions:

```python
except CraftApiTransportError as error:
    ...
```

---

# I.15 Leaking Resources by Skipping `with`

## The Problem

Files, clients, and other resources are manually opened but not reliably closed.

## Incorrect Pattern

```python
file_handle = open("projects.txt", "w", encoding="utf-8")
file_handle.write("Website Redesign\n")
file_handle.close()
```

If writing raises an exception, `close()` is skipped.

## Correct Pattern

```python
from pathlib import Path

destination = Path("projects.txt")

with destination.open("w", encoding="utf-8") as file_handle:
    file_handle.write("Website Redesign\n")
```

For clients:

```python
with CraftApiClient.from_environment() as client:
    project = client.get_project("project-123")
```

---

# I.16 Retrying Unsafe Requests

## The Problem

A retry mechanism automatically repeats a non-idempotent operation.

## Incorrect Pattern

```python
@retry(
    attempts=3,
    retry_on=(ConnectionError,),
)
def create_project() -> Project:
    ...
```

If the server created the project but the response was lost, retrying may create duplicates.

## Correct Pattern

Use automatic retries for safe idempotent reads:

```python
def get_project(project_id: str) -> Project:
    ...
```

For writes, use an API-supported idempotency key if available:

```python
headers = {
    "Idempotency-Key": request_id,
}
```

The exact mechanism depends on the server’s documented API contract.

---

# I.17 Retrying Every Exception

## The Problem

Broad retry catches programming bugs and invalid requests.

## Incorrect Pattern

```python
try:
    return operation()
except Exception:
    return operation()
```

This may retry:

- `TypeError`
- `AttributeError`
- `ValueError`
- Authentication failures
- Bad request errors

## Correct Pattern

Retry narrow temporary failures only:

```python
except URLError:
    ...
```

or use a controlled retry policy:

```python
RetryPolicy(
    max_attempts=3,
    retryable_status_codes=frozenset({429, 502, 503, 504}),
)
```

---

# I.18 Circular Imports

## The Problem

Two modules import each other.

```text
client.py imports models.py
models.py imports client.py
```

Python may report:

```text
ImportError: cannot import name ... from partially initialized module ...
```

## Incorrect Pattern

### `client.py`

```python
from craftapi.models import Project
```

### `models.py`

```python
from craftapi.client import CraftApiClient
```

## Correct Pattern

Keep dependency direction one-way:

```text
client.py → models.py
models.py → exceptions.py
transport.py → exceptions.py
```

Move shared concepts into a lower-level module if both modules need them.

For example:

```text
types.py
exceptions.py
models.py
```

---

# I.19 Importing from `__init__.py` Inside Package Modules

## The Problem

Internal modules import from the package’s public export file.

## Incorrect Pattern

### `src/craftapi/client.py`

```python
from craftapi import Project
```

This can create circular imports because `craftapi/__init__.py` itself may import `CraftApiClient`.

## Correct Pattern

Import directly from the defining module:

```python
from craftapi.models import Project
```

Use `from craftapi import Project` in application code, not in internal package modules.

---

# I.20 Relative Imports Versus Absolute Imports

Both forms can work inside packages.

Relative import:

```python
from .models import Project
```

Absolute package import:

```python
from craftapi.models import Project
```

For a package intended to be installed and maintained, absolute package imports are often easier to search and understand:

```python
from craftapi.models import Project
```

Do not run package modules directly as scripts:

```bash
python src/craftapi/client.py
```

This can break relative imports and bypass package behavior.

Instead, install the package and run a dedicated application or example module.

---

# I.21 Running a File Instead of a Module

## The Problem

A package module is executed as a file, so imports behave differently.

## Incorrect Pattern

```bash
python src/craftapi/client.py
```

## Correct Pattern

Create an entry point or example script:

```bash
python examples/part_11_client_preview.py
```

For runnable packages with a `__main__.py`, use:

```bash
python -m craftapi
```

The `-m` flag runs code in package-aware mode.

---

# I.22 Global Mutable State

## The Problem

Global variables create hidden coupling between code paths and tests.

## Incorrect Pattern

```python
ACTIVE_PROJECTS: list[str] = []


def add_project(project_id: str) -> None:
    ACTIVE_PROJECTS.append(project_id)
```

Tests can interfere with one another because they share `ACTIVE_PROJECTS`.

## Correct Pattern

Pass dependencies explicitly or store state in an instance:

```python
class ProjectRegistry:
    def __init__(self) -> None:
        self._project_ids: list[str] = []

    def add_project(self, project_id: str) -> None:
        self._project_ids.append(project_id)
```

---

# I.23 Defaulting to `Any`

## The Problem

Using `Any` everywhere removes the value of static checking.

## Incorrect Pattern

```python
from typing import Any


def parse_response(payload: Any) -> Any:
    return payload["items"][0]["name"]
```

## Correct Pattern

Keep `Any` at the JSON boundary and validate:

```python
from collections.abc import Mapping
from typing import Any


def require_payload_object(value: Any) -> Mapping[str, Any]:
    if not isinstance(value, dict):
        raise ValueError("Expected API response object.")

    return value
```

Then convert into typed models:

```python
project = Project.from_api_payload(payload)
```

---

# I.24 Excessive Use of `# type: ignore`

## The Problem

A broad type-ignore comment hides genuine issues.

## Incorrect Pattern

```python
project = client.get_project(123)  # type: ignore
```

The type checker was correctly identifying an invalid call.

## Correct Pattern

Fix the value:

```python
project = client.get_project("123")
```

If an ignore is unavoidable for a known third-party typing issue, use a narrow code and explain it:

```python
untyped_dependency.call()  # type: ignore[no-untyped-call]
```

Then revisit it when dependencies update.

---

# I.25 Premature Abstraction

## The Problem

A project creates frameworks, base classes, factories, and layers before a real need exists.

## Incorrect Pattern

```python
class AbstractProjectFactory:
    def create(self) -> Project:
        raise NotImplementedError


class DefaultProjectFactory(AbstractProjectFactory):
    def create(self) -> Project:
        ...
```

If there is only one construction path, this makes the code harder to follow.

## Correct Pattern

Start directly:

```python
def create_project(name: str) -> Project:
    return Project(
        id="generated-id",
        name=name,
        status="active",
        created_at=datetime.now(UTC),
    )
```

Introduce abstractions when repeated variation or testing needs prove they are valuable.

---

# I.26 Overly Clever One-Liners

## The Problem

Concise syntax becomes harder to maintain than explicit code.

## Incorrect Pattern

```python
project_names = list(
    map(
        lambda project: project.name,
        filter(lambda project: project.status == "active", projects),
    )
)
```

## Correct Pattern

```python
project_names = [
    project.name
    for project in projects
    if project.status == "active"
]
```

Or use a loop if behavior grows:

```python
project_names: list[str] = []

for project in projects:
    if project.status != "active":
        continue

    project_names.append(project.name)
```

Pythonic code optimizes for clear intent, not minimum character count.

---

# I.27 Forgetting Generator Laziness

## The Problem

A generator does not execute until consumed.

## Incorrect Pattern

```python
projects = client.iter_projects(page_size=25)

print("Downloaded all projects.")
```

No projects were downloaded yet.

## Correct Pattern

Consume the iterator:

```python
projects = list(client.iter_projects(page_size=25))

print(f"Downloaded {len(projects)} projects.")
```

Or process values incrementally:

```python
for project in client.iter_projects(page_size=25):
    print(project.name)
```

---

# I.28 Reusing an Exhausted Iterator

## The Problem

An iterator is consumed once.

## Incorrect Pattern

```python
projects = client.iter_projects()

active_projects = [
    project
    for project in projects
    if project.status == "active"
]

archived_projects = [
    project
    for project in projects
    if project.status == "archived"
]
```

The second list is empty because the iterator was consumed.

## Correct Pattern: Materialize Intentionally

```python
projects = list(client.iter_projects())

active_projects = [
    project
    for project in projects
    if project.status == "active"
]

archived_projects = [
    project
    for project in projects
    if project.status == "archived"
]
```

Or create two fresh iterators if repeated network requests are acceptable.

---

# I.29 Comparing Floating-Point Values Exactly

## The Problem

Floating-point arithmetic may not represent decimal values exactly.

## Incorrect Pattern

```python
assert 0.1 + 0.2 == 0.3
```

This can be false.

## Correct Pattern

For tests, use an approximate comparison:

```python
import pytest

assert 0.1 + 0.2 == pytest.approx(0.3)
```

For money, avoid binary floating point entirely. Use `decimal.Decimal` or integer minor units.

```python
from decimal import Decimal

price = Decimal("0.10")
tax = Decimal("0.20")

print(price + tax)
```

---

# I.30 Datetime Timezone Confusion

## The Problem

A datetime without timezone information is ambiguous.

## Incorrect Pattern

```python
from datetime import datetime

created_at = datetime.now()
```

This creates a naive datetime.

## Correct Pattern

```python
from datetime import UTC, datetime

created_at = datetime.now(UTC)
```

For API timestamps, require explicit timezone information:

```python
if timestamp.tzinfo is None:
    raise CraftApiValidationError(
        "API timestamp must include timezone information."
    )
```

---

# I.31 Final Anti-Pattern Review Checklist

Before shipping code, ask:

- [ ] Are mutable defaults avoided?
- [ ] Are mutable class attributes intentional?
- [ ] Are exceptions caught narrowly and re-raised appropriately?
- [ ] Are resources managed through `with` where applicable?
- [ ] Are remote values validated before use?
- [ ] Are identifiers URL encoded?
- [ ] Are booleans rejected when an external integer is required?
- [ ] Are retry operations safe and narrow?
- [ ] Are internal collections protected from accidental mutation?
- [ ] Are iterators consumed intentionally?
- [ ] Are imports directed from high-level modules to lower-level modules?
- [ ] Are logs free of tokens and secrets?
- [ ] Does `pytest` pass?
- [ ] Does `mypy` pass?
