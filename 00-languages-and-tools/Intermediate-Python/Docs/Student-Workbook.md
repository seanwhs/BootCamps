# Pythonic Craftsmanship  
## Student Workbook

**Writing Clean, Idiomatic, Production-Ready Python**

Use this workbook alongside the tutorial series. Complete each section after its corresponding lesson. Write answers, run commands, implement exercises, and record verification evidence.

---

# How to Use This Workbook

For each lesson:

1. Read or watch the associated tutorial part.
2. Complete the knowledge checks without looking at notes.
3. Implement the coding exercise.
4. Run the verification command.
5. Record what worked, what failed, and what you learned.
6. Commit completed work to Git.

---

# Student Profile

| Field | Your Notes |
|---|---|
| Name |  |
| Start date |  |
| Python version |  |
| Operating system |  |
| Editor or IDE |  |
| Main learning goal |  |
| Capstone repository location |  |

---

# Part 0: Introduction

## Learning Goals

By the end of this series, I will be able to:

- [ ] Structure a Python package using a `src/` layout.
- [ ] Model domain concepts with classes and data classes.
- [ ] Use Pythonic collection, iterator, and generator patterns.
- [ ] Write decorators safely.
- [ ] Test code with `pytest`.
- [ ] Check type contracts with `mypy`.
- [ ] Build a typed API client with configuration, errors, pagination, and retries.
- [ ] Build and verify an installable Python wheel.

## Architecture Check

Label each capstone responsibility.

| File | Responsibility |
|---|---|
| `config.py` |  |
| `models.py` |  |
| `exceptions.py` |  |
| `transport.py` |  |
| `client.py` |  |
| `tests/` |  |
| `pyproject.toml` |  |

## Reflection

What is the difference between code that “works” and code that is maintainable?

```text
Your answer:
```

---

# Primer 1: Development Environment

## Setup Checklist

- [ ] Python 3.11 or newer installed.
- [ ] Project folder created.
- [ ] Virtual environment created at `.venv/`.
- [ ] Virtual environment activated.
- [ ] `pytest` installed.
- [ ] `mypy` installed.
- [ ] `hello_python.py` runs successfully.

## Commands

```bash
python --version
python -m venv .venv
python -m pip install --upgrade pip
python -m pip install pytest mypy
python -m pytest --version
python -m mypy --version
```

## Knowledge Check

1. Why should each Python project usually have its own virtual environment?

```text
Answer:
```

2. Why is this preferred?

```bash
python -m pip install pytest
```

over this?

```bash
pip install pytest
```

```text
Answer:
```

3. What should `which python` or `Get-Command python` show after activation?

```text
Answer:
```

---

# Primer 2: Terminal and Paths

## Commands Practice

| Goal | Command Used |
|---|---|
| Show current directory |  |
| List files |  |
| Enter a folder |  |
| Move up one folder |  |
| Run a Python script |  |
| Activate `.venv` |  |

## Knowledge Check

1. Explain the difference between an absolute path and a relative path.

```text
Answer:
```

2. If you are inside `scripts/`, what relative path points to `hello_python.py` in the project root?

```text
Answer:
```

3. What is the difference between `Path.cwd()` and `Path(__file__).resolve()`?

```text
Answer:
```

## Practice Task

Create this structure:

```text
notes/
scripts/
```

Then create:

```text
notes/terminal_practice.txt
```

Write the command you used:

```text
Command:
```

---

# Primer 3: Python Syntax Refresh

## Concept Check

Match the type to its purpose.

| Type | Purpose |
|---|---|
| `str` |  |
| `int` |  |
| `float` |  |
| `bool` |  |
| `None` |  |
| `list` |  |
| `dict` |  |
| `set` |  |
| `tuple` |  |

## Coding Exercise: Normalize a Project Name

Implement this function:

```python
def normalize_project_name(name: str) -> str:
    """Return a cleaned non-blank project name."""
```

Requirements:

- Remove outer whitespace.
- Raise `ValueError` for blank text.
- Return cleaned text otherwise.

### My Implementation

```python
# Write your solution here.
```

### Verification

```python
assert normalize_project_name(" Website Redesign ") == "Website Redesign"
```

```python
# Record result:
```

---

# Primer 4: Git Essentials

## Git Workflow

Complete this workflow:

```text
Edit
    ↓
git status
    ↓
git diff
    ↓
git add
    ↓
git diff --staged
    ↓
git commit
```

## Checklist

- [ ] Ran `git init`.
- [ ] Set primary branch to `main`.
- [ ] Confirmed `.venv/` is ignored.
- [ ] Created an initial commit.
- [ ] Created a feature branch.
- [ ] Merged a completed feature branch.
- [ ] Deleted the merged local branch.

## Knowledge Check

1. What is the staging area?

```text
Answer:
```

2. Why should you inspect `git diff --staged` before committing?

```text
Answer:
```

3. Write a good commit message for adding project pagination tests.

```text
Answer:
```

---

# Primer 5: Debugging and Tracebacks

## Traceback Reading Exercise

Given:

```text
Traceback (most recent call last):
  File "example.py", line 20, in <module>
    main()
  File "example.py", line 16, in main
    print(normalize_project_name("   "))
  File "example.py", line 9, in normalize_project_name
    raise ValueError("Project name cannot be blank.")
ValueError: Project name cannot be blank.
```

Answer:

1. What exception occurred?

```text
Answer:
```

2. In which function did it originate?

```text
Answer:
```

3. What was invalid?

```text
Answer:
```

## Debugging Checklist

- [ ] Read the final exception line first.
- [ ] Locate the relevant file and line number.
- [ ] Inspect values with `repr()` and `type()`.
- [ ] Reduce the problem to a minimal example.
- [ ] Fix the underlying cause.
- [ ] Add or update a test.

---

# Part 1: OOP Foundations

## Key Terms

| Term | Your Definition |
|---|---|
| Class |  |
| Instance |  |
| Attribute |  |
| Method |  |
| `self` |  |
| Constructor |  |
| Encapsulation |  |
| Property |  |

## Coding Exercise: `Book`

Create a `Book` class with:

```python
title: str
author: str
isbn: str
_is_checked_out: bool
```

Required methods:

```python
check_out() -> None
return_to_library() -> None
status_message() -> str
```

Rules:

- A blank title, author, or ISBN is invalid.
- A checked-out book cannot be checked out again.
- An available book cannot be returned.

## Verification Checklist

- [ ] New books are available.
- [ ] `check_out()` changes availability.
- [ ] A second checkout raises `ValueError`.
- [ ] `return_to_library()` restores availability.
- [ ] A second return raises `ValueError`.

## Reflection

Why is this safer than allowing callers to assign directly to:

```python
book.is_checked_out = True
```

```text
Your answer:
```

---

# Part 2: Inheritance and Dunder Methods

## Key Terms

| Term | Your Definition |
|---|---|
| Inheritance |  |
| Base class |  |
| Subclass |  |
| `super()` |  |
| Polymorphism |  |
| Composition |  |
| Dunder method |  |

## Coding Exercise: Lending Items

Create this hierarchy:

```text
LendingItem
├── Book
└── DigitalBook
```

### Required `LendingItem` Features

```python
identifier: str
title: str
is_checked_out: bool
check_out() -> None
return_to_library() -> None
```

### Required `DigitalBook` Features

```python
author: str
download_url: str
license_limit: int
active_loans: int
available_license_count: int
```

## Dunder Method Checklist

Implement and test:

- [ ] `__repr__`
- [ ] `__str__`
- [ ] `__eq__`
- [ ] `__hash__`
- [ ] `__len__` on `Library`
- [ ] `__iter__` on `Library`
- [ ] `__contains__` on `Library`

## Knowledge Check

When should you prefer composition over inheritance?

```text
Answer:
```

---

# Part 3: Pythonic Collections

## Quick Decision Table

| Requirement | Best Tool |
|---|---|
| Transform a small collection |  |
| Build lookup by ID |  |
| Keep unique values |  |
| Count repeated values |  |
| Group items by key |  |
| Keep recent fixed-size history |  |

## Coding Exercise: Catalog Reports

Implement methods that return:

```python
available_item_descriptions() -> list[str]
items_by_title() -> dict[str, LendingItem]
distinct_authors() -> set[str]
item_count_by_type() -> Counter[str]
items_by_author() -> dict[str, list[LendingItem]]
```

## Verification Prompts

1. Why should duplicate titles be validated when building a title-indexed dictionary?

```text
Answer:
```

2. Why should output from a set usually be sorted before display?

```text
Answer:
```

3. What does `deque(maxlen=3)` do when a fourth value is appended?

```text
Answer:
```

---

# Part 4: Iterators, Generators, and Context Managers

## Key Terms

| Term | Your Definition |
|---|---|
| Iterable |  |
| Iterator |  |
| Generator |  |
| Lazy evaluation |  |
| `yield` |  |
| `StopIteration` |  |
| Context manager |  |

## Coding Exercise: Lazy Search

Implement:

```python
def iter_items_matching_title(
    items: Iterable[LendingItem],
    query: str,
) -> Iterator[LendingItem]:
    ...
```

Requirements:

- Reject blank queries.
- Match title fragments case-insensitively.
- Yield one result at a time.

## Verification

- [ ] `type(result).__name__` is `generator`.
- [ ] The first `next()` call returns the first match.
- [ ] Remaining values are returned in a loop.
- [ ] A consumed generator does not restart automatically.

## Context-Manager Exercise

Create a `CatalogSnapshotWriter` that supports:

```python
with CatalogSnapshotWriter(destination) as writer:
    writer.write_library(library)
```

Record:

```text
What resource is opened in __enter__?
```

```text
What cleanup occurs in __exit__?
```

```text
Why should __exit__ return False here?
```

---

# Part 5: First-Class Functions and Closures

## Key Terms

| Term | Your Definition |
|---|---|
| First-class function |  |
| Callback |  |
| Closure |  |
| Higher-order function |  |
| `*args` |  |
| `**kwargs` |  |

## Coding Exercise: Event System

Create:

```python
@dataclass(frozen=True, slots=True)
class LibraryEvent:
    event_type: str
    item_identifier: str
    item_title: str
```

Then add these methods to `Library`:

```python
subscribe(handler) -> None
unsubscribe(handler) -> bool
```

## Verification Checklist

- [ ] A handler receives an event after `add_item()`.
- [ ] Multiple handlers receive the same event.
- [ ] Removing a handler prevents future calls.
- [ ] A failing optional handler does not undo the catalog action.
- [ ] Handler failures are recorded for review.

## Reflection

Why is it often better for optional analytics callbacks to fail independently of a successful checkout?

```text
Your answer:
```

---

# Part 6: Decorators

## Key Terms

| Term | Your Definition |
|---|---|
| Decorator |  |
| Wrapper |  |
| `functools.wraps` |  |
| Decorator factory |  |
| `ParamSpec` |  |
| `TypeVar` |  |
| Idempotency |  |

## Coding Exercise: Non-Blank String Validation

Create a decorator factory:

```python
def require_non_blank_string(
    parameter_name: str,
) -> Callable[..., Callable[..., object]]:
    ...
```

Use it on a function that searches by title.

## Verification Checklist

- [ ] A valid positional argument works.
- [ ] A valid keyword argument works.
- [ ] Blank string input raises `ValueError`.
- [ ] Non-string input raises `TypeError`.
- [ ] A missing decorator parameter name fails at definition time.

## Retry Safety Prompt

Should this automatically retry?

```python
POST /payments
```

```text
Answer:
```

Why?

```text
Answer:
```

---

# Part 7: Package Architecture and Testing

## Package Checklist

- [ ] `src/` layout exists.
- [ ] Package has `__init__.py`.
- [ ] `pyproject.toml` exists.
- [ ] Project installs with editable mode.
- [ ] `tests/` directory exists.
- [ ] `pytest` discovers tests.
- [ ] `.venv/` is ignored.

## Coding Exercise: Test a Model

Write tests for `Book` or `Project` covering:

- Valid construction
- Invalid blank value
- State transition
- Invalid repeated operation

### Test Names

```text
1.
2.
3.
4.
```

## Fixture Reflection

What setup do multiple tests repeat?

```text
Answer:
```

What fixture could remove that duplication?

```text
Answer:
```

---

# Part 8: Type Hints and Error Boundaries

## Type-Hint Practice

Annotate these values:

```python
project_ids = []
project_by_id = {}
optional_description = None
```

```python
project_ids:
```

```python
project_by_id:
```

```python
optional_description:
```

## Error-Boundary Exercise

Convert an internal `KeyError` into a domain error:

```python
class ItemNotFoundError(Exception):
    ...
```

Then complete:

```python
try:
    return self._items_by_identifier[identifier]
except KeyError as error:
    ...
```

## Reflection

Why is this better for package users?

```text
Your answer:
```

## Static Analysis Checklist

- [ ] `python -m mypy src tests` runs.
- [ ] No broad `# type: ignore` comments were added to hide real issues.
- [ ] External JSON is validated before becoming domain data.
- [ ] Optional values are annotated with `| None`.

---

# Capstone Part 9: `craftapi` Foundation

## Architecture Worksheet

Complete the purpose of each module.

| Module | Responsibility |
|---|---|
| `craftapi/config.py` |  |
| `craftapi/exceptions.py` |  |
| `craftapi/models.py` |  |
| `craftapi/transport.py` |  |
| `craftapi/client.py` |  |

## Configuration Exercise

Create a frozen configuration object:

```python
@dataclass(frozen=True, slots=True)
class CraftApiConfig:
    base_url: str
    api_token: str
    timeout_seconds: float = 10.0
```

Validation rules:

- [ ] Base URL is non-blank.
- [ ] Base URL uses HTTPS.
- [ ] Base URL includes a hostname.
- [ ] Token is non-blank.
- [ ] Timeout is greater than zero.
- [ ] Trailing slash is removed.

## Model Exercise

Create a `Project` model from this payload:

```json
{
  "id": "project-123",
  "name": "Website Redesign",
  "status": "active",
  "created_at": "2026-07-24T10:30:00Z",
  "description": "Modernize the public website."
}
```

Questions:

1. Which fields are required?

```text
Answer:
```

2. Which field is optional?

```text
Answer:
```

3. Why should timestamps include timezone information?

```text
Answer:
```

---

# Capstone Part 10: HTTP Transport

## Transport Contract

Complete the protocol:

```python
class Transport(Protocol):
    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> __________________:
        ...

    def close(self) -> None:
        ...
```

## HTTP Status Translation

| HTTP Status | `craftapi` Exception |
|---:|---|
| 401 |  |
| 403 |  |
| 404 |  |
| 500 |  |
| DNS failure |  |
| Invalid JSON |  |

## Security Check

Which values must never appear in logs?

- [ ] API token
- [ ] Authorization header
- [ ] HTTP method
- [ ] Request URL
- [ ] Password
- [ ] Cookies
- [ ] Status code

## Testing Exercise

Write a fake transport that:

- Records requests.
- Returns queued `HttpResponse` values.
- Raises an error for unexpected requests.
- Implements `close()`.

```python
# Your FakeTransport implementation:
```

---

# Capstone Part 11: Public Client and Pagination

## Public Client API

Write expected signatures:

```python
def get_project(...):
    ...
```

```python
def create_project(...):
    ...
```

```python
def iter_projects(...):
    ...
```

## Pagination Flow

Fill in the sequence:

```text
Create generator
    ↓
________________________
    ↓
Fetch page 1
    ↓
Yield project items
    ↓
________________________
    ↓
Fetch next page or stop
```

## Safety Checks

- [ ] Page size is an integer.
- [ ] Boolean values are rejected as page sizes.
- [ ] Page size range is enforced.
- [ ] Repeated page numbers are detected.
- [ ] Project IDs are URL encoded.
- [ ] Closed clients reject new requests.
- [ ] Context-manager exit closes the transport.

## Reflection

Why is this lazy?

```python
projects = client.iter_projects(page_size=25)
```

```text
Your answer:
```

When does the first request occur?

```text
Your answer:
```

---

# Capstone Part 12: Production Hardening

## Retry Policy Worksheet

Fill in the safe retry defaults.

| Question | Answer |
|---|---|
| Which request type is normally safe to retry? |  |
| Why is POST not retried by default? |  |
| What is exponential backoff? |  |
| Why cap retry delay? |  |
| Why inject a sleeper in tests? |  |

## Release Checklist

- [ ] `python -m pytest` passes.
- [ ] `python -m mypy src tests` passes.
- [ ] `python -m build` succeeds.
- [ ] A wheel exists in `dist/`.
- [ ] The wheel installs in a clean virtual environment.
- [ ] `py.typed` is inside the wheel.
- [ ] README documents installation and configuration.
- [ ] No secrets are committed.
- [ ] Retry policy is documented.
- [ ] Public exceptions are documented.

---

# Final Capstone Challenge

Build an extension to `craftapi`.

Choose one:

- [ ] `update_project()`
- [ ] `delete_project()`
- [ ] Project filtering by status
- [ ] Rate-limit header parsing
- [ ] Idempotency-key support
- [ ] Request hooks
- [ ] Async API client
- [ ] SQLite project cache
- [ ] CLI interface using `argparse`

## Feature Proposal

### Feature Name

```text
```

### User Story

```text
As a user of craftapi, I want to...
```

### Public API Design

```python
# Write your intended method or class interface.
```

### Validation Rules

```text
1.
2.
3.
```

### Failure Modes

```text
1.
2.
3.
```

### Tests to Write

```text
1.
2.
3.
4.
```

### Verification Command

```bash
```

---

# Final Reflection

1. Which Python concept changed how you write code most?

```text
Answer:
```

2. Which topic needs more practice?

```text
Answer:
```

3. What production-quality habit will you use in every future Python project?

```text
Answer:
```

4. What will you build next?

```text
Answer:
```
