# Appendix A: Complete Project Source Trees

This appendix provides final reference layouts for both projects built throughout the series:

1. The learning-oriented **`library`** package.
2. The production-oriented **`craftapi`** capstone package.

Use this appendix when you need to:

- Compare your local folder structure with the expected result.
- Find the intended location of a file.
- Verify which files belong to application code versus tests.
- Confirm which files should be committed to Git.
- Review the package architecture without rereading every tutorial part.

> **Important:** The main tutorial remains the best place to learn *why* each file exists. This appendix is a structural reference, not a replacement for the step-by-step build.

---

# A.1 `pythonic-craftsmanship` Learning Project

The `pythonic-craftsmanship` project contains the evolving `library` package used to practice OOP, iterators, decorators, testing, typing, and package organization.

## Final Directory Tree

```text
pythonic-craftsmanship/
├── .gitignore
├── pyproject.toml
├── README.md
├── examples/
│   ├── part_1_demo.py
│   ├── part_2_demo.py
│   ├── part_2_validation_demo.py
│   ├── part_3_any_all_demo.py
│   ├── part_3_comprehension_preview.py
│   ├── part_3_demo.py
│   ├── part_3_deque_demo.py
│   ├── part_4_context_manager_demo.py
│   ├── part_4_context_manager_error_demo.py
│   ├── part_4_generator_demo.py
│   ├── part_4_iterator_demo.py
│   ├── part_4_itertools_demo.py
│   ├── part_4_page_iterator_demo.py
│   ├── part_5_callback_failure_demo.py
│   ├── part_5_callbacks_demo.py
│   ├── part_5_callbacks_preview.py
│   ├── part_5_closures_demo.py
│   ├── part_5_variadic_arguments_demo.py
│   ├── part_6_decorator_basics.py
│   ├── part_6_decorator_configuration_demo.py
│   ├── part_6_logging_demo.py
│   ├── part_6_retry_demo.py
│   └── part_6_validation_demo.py
├── src/
│   └── library/
│       ├── __init__.py
│       ├── book.py
│       ├── catalog.py
│       ├── decorators.py
│       ├── digital_book.py
│       ├── events.py
│       ├── exceptions.py
│       ├── lending_item.py
│       ├── reports.py
│       ├── search.py
│       ├── snapshots.py
│       └── py.typed
└── tests/
    ├── conftest.py
    ├── test_book.py
    ├── test_catalog.py
    ├── test_decorators.py
    ├── test_digital_book.py
    ├── test_exceptions.py
    ├── test_reports.py
    ├── test_search.py
    └── test_snapshots.py
```

## Architecture Map

```text
library/
├── lending_item.py
│   └── Base class for lendable resources.
│
├── book.py
│   └── Physical Book implementation.
│
├── digital_book.py
│   └── DigitalBook implementation with license limits.
│
├── catalog.py
│   └── Library catalog, checkout behavior, events, and activity history.
│
├── events.py
│   └── Typed library-event records and handler contracts.
│
├── decorators.py
│   └── Logging, validation, timing, and retry decorators.
│
├── exceptions.py
│   └── Public, domain-specific error types.
│
├── reports.py
│   └── Read-only catalog reports and aggregations.
│
├── search.py
│   └── Lazy search, custom pagination iterator, and itertools helpers.
│
├── snapshots.py
│   └── Context-managed catalog snapshot writing.
│
└── __init__.py
    └── Stable public import interface.
```

---

## A.1.1 Files That Should Be Committed

These are source-controlled project files:

```text
.gitignore
README.md
pyproject.toml
src/library/
tests/
examples/
```

These should **not** be committed:

```text
.venv/
__pycache__/
.pytest_cache/
.mypy_cache/
.coverage
htmlcov/
output/
```

The existing `.gitignore` should already prevent most generated files from being tracked.

---

## A.1.2 Install and Verify the Learning Project

From the `pythonic-craftsmanship` project root:

```bash
python -m pip install --editable ".[dev]"
python -m pytest
python -m mypy src tests
```

Expected outcome:

```text
... passed
Success: no issues found in ... source files
```

Run an example program:

```bash
python examples/part_6_logging_demo.py
```

---

# A.2 `craftapi` Capstone Project

The `craftapi` project is the final modular, typed, testable API-client package.

## Final Directory Tree

```text
craftapi/
├── .gitignore
├── README.md
├── pyproject.toml
├── examples/
│   ├── part_11_client_preview.py
│   ├── part_11_environment_client.py
│   └── part_11_pagination_preview.py
├── src/
│   └── craftapi/
│       ├── __init__.py
│       ├── client.py
│       ├── config.py
│       ├── exceptions.py
│       ├── models.py
│       ├── transport.py
│       └── py.typed
└── tests/
    ├── conftest.py
    ├── test_client.py
    ├── test_config.py
    ├── test_exceptions.py
    ├── test_models.py
    └── test_transport.py
```

## Architecture Map

```text
craftapi/
├── config.py
│   └── Immutable endpoint, token, and timeout configuration.
│
├── exceptions.py
│   └── API-client-specific exception hierarchy.
│
├── models.py
│   └── Validated Project and ProjectPage API models.
│
├── transport.py
│   └── HTTP abstraction, urllib implementation, JSON encoding,
│       response handling, retry policy, and HTTP error translation.
│
├── client.py
│   └── High-level project operations, URL construction, headers,
│       pagination, lifecycle management, and transport use.
│
├── __init__.py
│   └── Public import interface.
│
└── py.typed
    └── Declares that package type information is included.
```

---

## A.2.1 Dependency Direction

The dependency direction is intentionally one-way:

```text
Application code
      │
      ▼
CraftApiClient
      │
      ├── CraftApiConfig
      ├── Project / ProjectPage
      ├── Transport protocol
      └── craftapi exceptions
              │
              ▼
       UrllibTransport
              │
              ▼
       urllib.request
              │
              ▼
         HTTPS API
```

Internal modules should not depend on `CraftApiClient` unless they genuinely need the high-level client interface.

For example:

- `models.py` should not import `client.py`.
- `config.py` should not import `transport.py`.
- `transport.py` should not import `client.py`.

Keeping lower-level modules independent prevents circular imports and makes each layer easier to test.

---

## A.2.2 Public Imports

The package should expose a stable API from `craftapi/__init__.py`.

Recommended imports for application code:

```python
from craftapi import (
    CraftApiAuthenticationError,
    CraftApiClient,
    CraftApiConfig,
    CraftApiNotFoundError,
    CraftApiResponseError,
    CraftApiServerError,
    CraftApiTransportError,
    CraftApiValidationError,
    Project,
    ProjectPage,
    RetryPolicy,
    UrllibTransport,
)
```

Avoid making application code depend on internal module paths unless needed for a specialized use case:

```python
# Prefer this:
from craftapi import CraftApiClient

# Over this:
from craftapi.client import CraftApiClient
```

The first import uses the package’s supported front door.

---

## A.2.3 Test Layers

The test suite is intentionally split by responsibility.

```text
tests/
├── test_config.py
│   └── Configuration normalization, environment variables, invalid settings.
│
├── test_exceptions.py
│   └── Structured exception context.
│
├── test_models.py
│   └── API-payload validation and immutable data models.
│
├── test_transport.py
│   └── HTTP construction, error translation, JSON handling, retries.
│
└── test_client.py
    └── Public client operations, headers, URLs, context cleanup, pagination.
```

This layout helps diagnose failures quickly.

For example:

- A malformed API payload issue belongs in `test_models.py`.
- A `404` translation issue belongs in `test_transport.py`.
- An incorrectly encoded project ID belongs in `test_client.py`.

---

# A.3 Standard Project Commands

These commands apply to either project, with the correct project folder active.

## Activate the Virtual Environment

### macOS or Linux

```bash
source .venv/bin/activate
```

### Windows PowerShell

```powershell
.\.venv\Scripts\Activate.ps1
```

### Windows Command Prompt

```bat
.venv\Scripts\activate.bat
```

---

## Install Development Dependencies

```bash
python -m pip install --editable ".[dev]"
```

---

## Run Tests

```bash
python -m pytest
```

Verbose test output:

```bash
python -m pytest --verbose
```

Run one test module:

```bash
python -m pytest tests/test_client.py
```

Run one named test:

```bash
python -m pytest tests/test_client.py::test_get_project_builds_authorized_encoded_request
```

---

## Run Static Type Checks

```bash
python -m mypy src tests
```

For the learning package, depending on your configured `pyproject.toml`, this may also work:

```bash
python -m mypy
```

---

## Build the `craftapi` Distribution

From the `craftapi` root:

```bash
python -m build
```

Expected generated files:

```text
dist/
├── craftapi-0.1.0-py3-none-any.whl
└── craftapi-0.1.0.tar.gz
```

---

# A.4 Quick Structural Troubleshooting

## `ModuleNotFoundError: No module named 'craftapi'`

Check that:

1. Your virtual environment is activated.
2. You are in the project root.
3. You installed the project:

```bash
python -m pip install --editable ".[dev]"
```

4. Your source code is under:

```text
src/craftapi/
```

not directly under the root.

---

## `pytest` Finds Zero Tests

Check the test names:

```text
tests/test_*.py
```

and function names:

```python
def test_something() -> None:
    ...
```

Then run:

```bash
python -m pytest --collect-only
```

This lists every test `pytest` discovered.

---

## `mypy` Cannot Find Package Types

Confirm this marker exists:

```text
src/craftapi/py.typed
```

Then reinstall:

```bash
python -m pip install --editable ".[dev]"
```

---

## Circular Import Error

If Python reports a partially initialized module or circular import, inspect dependency direction.

For the capstone, this direction is safe:

```text
client.py → config.py, models.py, transport.py
transport.py → exceptions.py
models.py → exceptions.py
config.py → exceptions.py
```

This direction is unsafe:

```text
models.py → client.py
client.py → models.py
```

Move shared types or utilities into a lower-level module when two modules need each other.
