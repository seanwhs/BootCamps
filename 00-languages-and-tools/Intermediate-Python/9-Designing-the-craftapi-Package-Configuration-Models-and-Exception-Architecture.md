# Part 9: Designing the `craftapi` Package

The earlier `library` package taught the language and architecture patterns we need for a production package.

Now we begin the capstone: **`craftapi`**, a modular API client package.

An API client is a small library that gives Python code a safe, readable way to communicate with a remote HTTP API.

Instead of making callers build URLs, attach authorization headers, parse JSON, and interpret error responses themselves, the package will provide a focused interface:

```python
from craftapi import CraftApiClient

with CraftApiClient.from_environment() as client:
    project = client.get_project("project-123")
    print(project.name)
```

This part builds the foundation:

- Package configuration
- Environment-variable loading
- Validated immutable models
- Domain-specific exceptions
- A clean public package interface
- Tests for every foundational behavior

We will not send network requests yet. A stable API client starts by defining what valid configuration, successful data, and meaningful failures look like.

---

## What You Will Build

Create a new project beside the tutorial package:

```text
craftapi/
├── .gitignore
├── README.md
├── pyproject.toml
├── src/
│   └── craftapi/
│       ├── __init__.py
│       ├── config.py
│       ├── exceptions.py
│       ├── models.py
│       └── py.typed
└── tests/
    ├── conftest.py
    ├── test_config.py
    ├── test_exceptions.py
    └── test_models.py
```

The responsibility map is:

| Module | Responsibility |
|---|---|
| `config.py` | Validate base URLs, tokens, timeouts, and environment variables |
| `models.py` | Convert validated API JSON into immutable Python objects |
| `exceptions.py` | Provide clear, catchable API-client error types |
| `__init__.py` | Define the supported public imports |
| `tests/` | Prove the package foundation behaves correctly |

---

# Step 1: Create the Capstone Project and Virtual Environment

## The Target

We are creating a separate project directory named `craftapi`.

## The Concept

The earlier `library` package is a learning project. The capstone should be its own installable package with its own configuration, tests, and dependencies.

Think of it as moving from a practice workshop into a new product workspace.

## The Implementation

From the directory containing `pythonic-craftsmanship`, run:

### macOS or Linux

```bash
mkdir craftapi
cd craftapi

python3 -m venv .venv
source .venv/bin/activate

mkdir -p src/craftapi tests
```

### Windows PowerShell

```powershell
mkdir craftapi
cd craftapi

py -m venv .venv
.\.venv\Scripts\Activate.ps1

mkdir src\craftapi
mkdir tests
```

Create `.gitignore`.

### `.gitignore`

```gitignore
.venv/
__pycache__/
*.py[cod]

.pytest_cache/
.mypy_cache/
.coverage
htmlcov/

.env
.env.*
!.env.example

.DS_Store
.vscode/
.idea/
```

The `.env` entries are important. Environment files frequently contain API tokens and must not be committed to source control.

## The Verification

Run:

```bash
python --version
```

Then verify the active Python executable points to `.venv`.

### macOS or Linux

```bash
which python
```

### Windows PowerShell

```powershell
Get-Command python
```

The displayed path should include:

```text
craftapi/.venv/
```

---

# Step 2: Define Package Metadata and Development Tooling

## The Target

We are creating:

```text
pyproject.toml
README.md
```

## The Concept

`pyproject.toml` is the package contract with Python tooling.

It tells build tools:

- What the package is called
- Which Python versions it supports
- Where source files live
- Which development tools are required
- How tests and static type checks should run

## The Implementation

### `pyproject.toml`

```toml
[build-system]
requires = ["setuptools>=69.0"]
build-backend = "setuptools.build_meta"

[project]
name = "craftapi"
version = "0.1.0"
description = "A typed, testable Python client for a project-management HTTP API."
readme = "README.md"
requires-python = ">=3.11"
authors = [
  { name = "Pythonic Craftsmanship Student" }
]
classifiers = [
  "Programming Language :: Python :: 3",
  "Programming Language :: Python :: 3.11",
  "Programming Language :: Python :: 3.12",
  "Programming Language :: Python :: 3.13",
]

[project.optional-dependencies]
dev = [
  "mypy>=1.10",
  "pytest>=8.2",
]

[tool.setuptools]
package-dir = {"" = "src"}

[tool.setuptools.packages.find]
where = ["src"]

[tool.setuptools.package-data]
craftapi = ["py.typed"]

[tool.pytest.ini_options]
addopts = "-ra"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]

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

### `README.md`

```md
# craftapi

`craftapi` is a typed and testable Python client package for a project-management HTTP API.

## Development setup

Create and activate a virtual environment, then install the package in editable mode:

```bash
python -m pip install --editable ".[dev]"
```

Run tests:

```bash
python -m pytest
```

Run static type checks:

```bash
python -m mypy src tests
```

## Configuration

The client will support explicit configuration and environment-based configuration.

Expected environment variables:

- `CRAFTAPI_BASE_URL`
- `CRAFTAPI_API_TOKEN`
- `CRAFTAPI_TIMEOUT_SECONDS` (optional)
```

Install the package and development dependencies:

```bash
python -m pip install --upgrade pip
python -m pip install --editable ".[dev]"
```

Create the typing marker.

### `src/craftapi/py.typed`

```text

```

## The Verification

Run:

```bash
python -m pip show craftapi
python -m pytest --version
python -m mypy --version
```

Expected results:

- `pip show` lists `craftapi`
- `pytest` prints its version
- `mypy` prints its version

---

# Step 3: Define a Domain-Specific Exception Hierarchy

## The Target

We are creating:

```text
src/craftapi/exceptions.py
```

## The Concept

A remote API can fail in several different ways:

- The configuration is invalid.
- The network is unavailable.
- The server responds with an error.
- Authentication fails.
- A requested project does not exist.
- The server returns malformed JSON.

Callers should be able to handle these situations precisely.

A custom hierarchy is like an organized set of emergency alarms:

```text
CraftApiError
├── CraftApiConfigurationError
├── CraftApiTransportError
├── CraftApiResponseError
│   ├── CraftApiAuthenticationError
│   ├── CraftApiNotFoundError
│   └── CraftApiServerError
└── CraftApiValidationError
```

## The Implementation

### `src/craftapi/exceptions.py`

```python
"""Domain-specific exceptions exposed by the craftapi package."""

from __future__ import annotations

from dataclasses import dataclass


class CraftApiError(Exception):
    """Base class for all errors raised by the craftapi package."""


class CraftApiConfigurationError(CraftApiError):
    """Raised when client configuration is invalid or incomplete."""


class CraftApiValidationError(CraftApiError):
    """Raised when API data does not match the expected schema."""


class CraftApiTransportError(CraftApiError):
    """Raised when an HTTP request cannot be completed."""

    def __init__(self, message: str, *, url: str) -> None:
        """Create a transport error with the affected URL."""
        self.url = url
        super().__init__(message)


@dataclass(frozen=True, slots=True)
class ApiErrorDetails:
    """Structured details extracted from an unsuccessful HTTP response."""

    status_code: int
    method: str
    url: str
    response_body: str | None = None


class CraftApiResponseError(CraftApiError):
    """Raised when the API responds with an unsuccessful HTTP status."""

    def __init__(self, message: str, *, details: ApiErrorDetails) -> None:
        """Create an HTTP-response error with structured request context."""
        self.details = details
        super().__init__(message)


class CraftApiAuthenticationError(CraftApiResponseError):
    """Raised for HTTP 401 or 403 authentication and authorization failures."""


class CraftApiNotFoundError(CraftApiResponseError):
    """Raised for HTTP 404 responses."""


class CraftApiServerError(CraftApiResponseError):
    """Raised for HTTP 5xx responses."""
```

## The Verification

Run:

```bash
python -c "from craftapi.exceptions import ApiErrorDetails, CraftApiNotFoundError; details = ApiErrorDetails(status_code=404, method='GET', url='https://api.example.test/projects/missing'); error = CraftApiNotFoundError('Project was not found.', details=details); print(type(error).__name__); print(error); print(error.details.status_code)"
```

Expected output:

```text
CraftApiNotFoundError
Project was not found.
404
```

---

# Step 4: Create Validated Immutable Client Configuration

## The Target

We are creating:

```text
src/craftapi/config.py
```

## The Concept

Configuration is the API client’s control panel.

It contains values such as:

- Base URL: where requests are sent
- API token: credentials for authorization
- Timeout: how long a request may wait

Configuration should be validated before the first request is sent.

A bad base URL or missing token is like trying to mail a package without an address or stamp. Failing early produces a clear error instead of a confusing network failure later.

We will use a frozen data class. A frozen data class is immutable after creation, which prevents accidental changes such as replacing a production URL halfway through a program run.

## The Implementation

### `src/craftapi/config.py`

```python
"""Configuration models and environment loading for craftapi."""

from __future__ import annotations

import os
from dataclasses import dataclass
from urllib.parse import urlparse

from craftapi.exceptions import CraftApiConfigurationError

DEFAULT_TIMEOUT_SECONDS = 10.0


@dataclass(frozen=True, slots=True)
class CraftApiConfig:
    """Validated immutable configuration for CraftApiClient."""

    base_url: str
    api_token: str
    timeout_seconds: float = DEFAULT_TIMEOUT_SECONDS

    def __post_init__(self) -> None:
        """Normalize and validate all configuration values."""
        normalized_base_url = self.base_url.strip().rstrip("/")
        normalized_api_token = self.api_token.strip()

        if not normalized_base_url:
            raise CraftApiConfigurationError("API base URL cannot be blank.")

        parsed_url = urlparse(normalized_base_url)

        if parsed_url.scheme != "https":
            raise CraftApiConfigurationError(
                "API base URL must use the https scheme."
            )

        if not parsed_url.netloc:
            raise CraftApiConfigurationError(
                "API base URL must include a host name."
            )

        if not normalized_api_token:
            raise CraftApiConfigurationError("API token cannot be blank.")

        if self.timeout_seconds <= 0:
            raise CraftApiConfigurationError(
                "Request timeout must be greater than zero."
            )

        # Frozen dataclasses require object.__setattr__ during normalization.
        object.__setattr__(self, "base_url", normalized_base_url)
        object.__setattr__(self, "api_token", normalized_api_token)

    @classmethod
    def from_environment(
        cls,
        *,
        environment: dict[str, str] | None = None,
    ) -> CraftApiConfig:
        """Create configuration from environment variables.

        Args:
            environment: Optional explicit environment mapping. Supplying it
                makes tests deterministic; production callers normally omit it.

        Raises:
            CraftApiConfigurationError: If required variables are absent or
                timeout text is invalid.
        """
        source_environment = os.environ if environment is None else environment

        base_url = source_environment.get("CRAFTAPI_BASE_URL", "")
        api_token = source_environment.get("CRAFTAPI_API_TOKEN", "")
        raw_timeout = source_environment.get(
            "CRAFTAPI_TIMEOUT_SECONDS",
            str(DEFAULT_TIMEOUT_SECONDS),
        )

        try:
            timeout_seconds = float(raw_timeout)
        except ValueError as error:
            raise CraftApiConfigurationError(
                "CRAFTAPI_TIMEOUT_SECONDS must be a valid number."
            ) from error

        return cls(
            base_url=base_url,
            api_token=api_token,
            timeout_seconds=timeout_seconds,
        )
```

## The Verification

Run a valid configuration example:

```bash
python -c "from craftapi.config import CraftApiConfig; config = CraftApiConfig(base_url='https://api.example.test/', api_token=' demo-token ', timeout_seconds=5); print(config.base_url); print(config.api_token); print(config.timeout_seconds)"
```

Expected output:

```text
https://api.example.test
demo-token
5
```

Run an invalid base URL example:

```bash
python -c "from craftapi.config import CraftApiConfig; CraftApiConfig(base_url='http://api.example.test', api_token='demo-token')"
```

Expected result:

```text
craftapi.exceptions.CraftApiConfigurationError: API base URL must use the https scheme.
```

---

# Step 5: Define Immutable API Resource Models

## The Target

We are creating:

```text
src/craftapi/models.py
```

## The Concept

An API typically sends JSON objects such as:

```json
{
  "id": "project-123",
  "name": "Website Redesign",
  "status": "active",
  "created_at": "2026-07-24T10:30:00Z"
}
```

Raw JSON is untrusted input. It may be incomplete, malformed, or unexpectedly shaped.

Our model layer converts raw dictionaries into safe Python objects.

Think of this layer as a quality-control station:

```text
Remote JSON
    ↓ validate fields and types
Project model
    ↓
Reliable application data
```

## The Implementation

### `src/craftapi/models.py`

```python
"""Validated immutable resource models returned by the Craft API."""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import Any, Mapping

from craftapi.exceptions import CraftApiValidationError


def _required_non_blank_string(
    payload: Mapping[str, Any],
    field_name: str,
) -> str:
    """Read a required non-blank string from an API payload."""
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


def _optional_non_blank_string(
    payload: Mapping[str, Any],
    field_name: str,
) -> str | None:
    """Read an optional string, returning None when the field is absent."""
    value = payload.get(field_name)

    if value is None:
        return None

    if not isinstance(value, str):
        raise CraftApiValidationError(
            f'API field "{field_name}" must be a string when provided.'
        )

    cleaned_value = value.strip()

    if not cleaned_value:
        raise CraftApiValidationError(
            f'API field "{field_name}" cannot be blank when provided.'
        )

    return cleaned_value


def _parse_timestamp(payload: Mapping[str, Any], field_name: str) -> datetime:
    """Parse one required ISO 8601 timestamp from an API payload."""
    raw_timestamp = _required_non_blank_string(payload, field_name)

    normalized_timestamp = raw_timestamp.replace("Z", "+00:00")

    try:
        timestamp = datetime.fromisoformat(normalized_timestamp)
    except ValueError as error:
        raise CraftApiValidationError(
            f'API field "{field_name}" must be an ISO 8601 timestamp.'
        ) from error

    if timestamp.tzinfo is None:
        raise CraftApiValidationError(
            f'API field "{field_name}" must include timezone information.'
        )

    return timestamp


@dataclass(frozen=True, slots=True)
class Project:
    """A project resource returned by the remote API."""

    id: str
    name: str
    status: str
    created_at: datetime
    description: str | None = None

    @classmethod
    def from_api_payload(cls, payload: Mapping[str, Any]) -> Project:
        """Validate API JSON and construct a Project instance."""
        return cls(
            id=_required_non_blank_string(payload, "id"),
            name=_required_non_blank_string(payload, "name"),
            status=_required_non_blank_string(payload, "status"),
            created_at=_parse_timestamp(payload, "created_at"),
            description=_optional_non_blank_string(payload, "description"),
        )
```

## The Verification

Run:

```bash
python -c "from craftapi.models import Project; project = Project.from_api_payload({'id': 'project-123', 'name': 'Website Redesign', 'status': 'active', 'created_at': '2026-07-24T10:30:00Z', 'description': 'Modernize the public site.'}); print(project.id); print(project.created_at.isoformat()); print(project.description)"
```

Expected output:

```text
project-123
2026-07-24T10:30:00+00:00
Modernize the public site.
```

Now verify invalid payload handling:

```bash
python -c "from craftapi.models import Project; Project.from_api_payload({'id': 'project-123', 'name': 'Website Redesign', 'status': 'active', 'created_at': 'not-a-timestamp'})"
```

Expected result:

```text
craftapi.exceptions.CraftApiValidationError: API field "created_at" must be an ISO 8601 timestamp.
```

---

# Step 6: Define the Public Package Interface

## The Target

We are creating:

```text
src/craftapi/__init__.py
```

## The Concept

A package should expose a deliberate public interface.

Users should not need to know which internal file contains each class. They should be able to import from one stable location:

```python
from craftapi import CraftApiConfig, Project
```

This is like a building’s front entrance. Internal rooms can be rearranged later without forcing every visitor to learn a new path.

## The Implementation

### `src/craftapi/__init__.py`

```python
"""Typed Python client package for the Craft project-management API."""

from craftapi.config import CraftApiConfig
from craftapi.exceptions import (
    ApiErrorDetails,
    CraftApiAuthenticationError,
    CraftApiConfigurationError,
    CraftApiError,
    CraftApiNotFoundError,
    CraftApiResponseError,
    CraftApiServerError,
    CraftApiTransportError,
    CraftApiValidationError,
)
from craftapi.models import Project

__all__ = [
    "ApiErrorDetails",
    "CraftApiAuthenticationError",
    "CraftApiConfig",
    "CraftApiConfigurationError",
    "CraftApiError",
    "CraftApiNotFoundError",
    "CraftApiResponseError",
    "CraftApiServerError",
    "CraftApiTransportError",
    "CraftApiValidationError",
    "Project",
]
```

## The Verification

Run:

```bash
python -c "from craftapi import CraftApiConfig, Project; print(CraftApiConfig.__name__); print(Project.__name__)"
```

Expected output:

```text
CraftApiConfig
Project
```

---

# Step 7: Add Automated Tests for the Foundation

## The Target

We are creating:

```text
tests/conftest.py
tests/test_config.py
tests/test_exceptions.py
tests/test_models.py
```

## The Concept

Configuration and model validation are package boundaries. They are especially important to test because they protect the rest of the application from invalid input.

We will use:

- `pytest.raises` to test expected errors
- A fixture for a valid API payload
- Explicit environment dictionaries instead of changing the real operating-system environment

## The Implementation

### `tests/conftest.py`

```python
"""Shared pytest fixtures for craftapi tests."""

from __future__ import annotations

from typing import Any

import pytest


@pytest.fixture
def valid_project_payload() -> dict[str, Any]:
    """Return a valid project-shaped API response payload."""
    return {
        "id": "project-123",
        "name": "Website Redesign",
        "status": "active",
        "created_at": "2026-07-24T10:30:00Z",
        "description": "Modernize the public website.",
    }
```

### `tests/test_config.py`

```python
"""Tests for CraftApiConfig."""

from __future__ import annotations

import pytest

from craftapi import CraftApiConfig, CraftApiConfigurationError


def test_config_normalizes_base_url_and_token() -> None:
    """Configuration should remove surrounding whitespace and trailing slash."""
    config = CraftApiConfig(
        base_url=" https://api.example.test/ ",
        api_token=" token-value ",
        timeout_seconds=5.0,
    )

    assert config.base_url == "https://api.example.test"
    assert config.api_token == "token-value"
    assert config.timeout_seconds == 5.0


@pytest.mark.parametrize(
    ("base_url", "api_token", "timeout_seconds", "message"),
    [
        ("", "token", 10.0, "base URL cannot be blank"),
        ("http://api.example.test", "token", 10.0, "https scheme"),
        ("https://", "token", 10.0, "host name"),
        ("https://api.example.test", "", 10.0, "token cannot be blank"),
        ("https://api.example.test", "token", 0.0, "greater than zero"),
    ],
)
def test_config_rejects_invalid_values(
    base_url: str,
    api_token: str,
    timeout_seconds: float,
    message: str,
) -> None:
    """Invalid configuration should fail before any network operation."""
    with pytest.raises(CraftApiConfigurationError, match=message):
        CraftApiConfig(
            base_url=base_url,
            api_token=api_token,
            timeout_seconds=timeout_seconds,
        )


def test_config_loads_from_explicit_environment_mapping() -> None:
    """Environment loading should work without changing process environment."""
    config = CraftApiConfig.from_environment(
        environment={
            "CRAFTAPI_BASE_URL": "https://api.example.test/",
            "CRAFTAPI_API_TOKEN": "environment-token",
            "CRAFTAPI_TIMEOUT_SECONDS": "7.5",
        }
    )

    assert config.base_url == "https://api.example.test"
    assert config.api_token == "environment-token"
    assert config.timeout_seconds == 7.5


def test_config_rejects_invalid_environment_timeout() -> None:
    """Timeout text must be parseable as a number."""
    with pytest.raises(
        CraftApiConfigurationError,
        match="CRAFTAPI_TIMEOUT_SECONDS must be a valid number",
    ):
        CraftApiConfig.from_environment(
            environment={
                "CRAFTAPI_BASE_URL": "https://api.example.test",
                "CRAFTAPI_API_TOKEN": "environment-token",
                "CRAFTAPI_TIMEOUT_SECONDS": "fast",
            }
        )
```

### `tests/test_exceptions.py`

```python
"""Tests for craftapi exception types."""

from __future__ import annotations

from craftapi import ApiErrorDetails, CraftApiNotFoundError


def test_response_error_exposes_structured_request_context() -> None:
    """Response errors should preserve useful troubleshooting details."""
    details = ApiErrorDetails(
        status_code=404,
        method="GET",
        url="https://api.example.test/projects/missing",
        response_body='{"error": "not found"}',
    )

    error = CraftApiNotFoundError("Project was not found.", details=details)

    assert str(error) == "Project was not found."
    assert error.details.status_code == 404
    assert error.details.method == "GET"
    assert error.details.response_body == '{"error": "not found"}'
```

### `tests/test_models.py`

```python
"""Tests for validated Craft API resource models."""

from __future__ import annotations

from datetime import timezone
from typing import Any

import pytest

from craftapi import CraftApiValidationError, Project


def test_project_is_created_from_valid_api_payload(
    valid_project_payload: dict[str, Any],
) -> None:
    """A valid payload should become an immutable Project model."""
    project = Project.from_api_payload(valid_project_payload)

    assert project.id == "project-123"
    assert project.name == "Website Redesign"
    assert project.status == "active"
    assert project.created_at.tzinfo == timezone.utc
    assert project.description == "Modernize the public website."


def test_project_allows_missing_optional_description(
    valid_project_payload: dict[str, Any],
) -> None:
    """Description is optional and should become None when absent."""
    del valid_project_payload["description"]

    project = Project.from_api_payload(valid_project_payload)

    assert project.description is None


@pytest.mark.parametrize(
    ("field_name", "invalid_value", "message"),
    [
        ("id", "", 'field "id" cannot be blank'),
        ("name", 123, 'field "name" must be a string'),
        ("status", None, 'field "status" must be a string'),
        ("created_at", "not-a-date", "ISO 8601 timestamp"),
    ],
)
def test_project_rejects_invalid_required_fields(
    valid_project_payload: dict[str, Any],
    field_name: str,
    invalid_value: object,
    message: str,
) -> None:
    """Malformed remote API data should not enter the application model."""
    valid_project_payload[field_name] = invalid_value

    with pytest.raises(CraftApiValidationError, match=message):
        Project.from_api_payload(valid_project_payload)


def test_project_rejects_timestamp_without_timezone(
    valid_project_payload: dict[str, Any],
) -> None:
    """Remote timestamps must be explicit about their timezone."""
    valid_project_payload["created_at"] = "2026-07-24T10:30:00"

    with pytest.raises(CraftApiValidationError, match="timezone information"):
        Project.from_api_payload(valid_project_payload)
```

## The Verification

Run:

```bash
python -m pytest
```

Expected output includes:

```text
15 passed
```

Then run static checks:

```bash
python -m mypy src tests
```

Expected output:

```text
Success: no issues found in ... source files
```

---

# Part 9 Reference: Capstone Architecture Decisions

## Why Immutable Configuration?

`CraftApiConfig` uses:

```python
@dataclass(frozen=True, slots=True)
```

`frozen=True` prevents accidental reassignment:

```python
config.base_url = "https://different.example.test"
```

This raises an error.

`slots=True` reduces per-instance memory overhead and prevents undeclared attributes from being added accidentally.

---

## Why Validate JSON in Models?

Remote data is not trustworthy merely because it is JSON.

This could arrive from a server:

```json
{
  "id": 123,
  "name": null,
  "status": "",
  "created_at": "sometime"
}
```

Without validation, invalid data spreads through the application and causes failures far from the real source.

Validate at the boundary:

```text
External response
    ↓
Model validation
    ↓
Safe internal object
```

---

## Why Require HTTPS?

Tokens sent over plain HTTP can be exposed to network observers.

The configuration layer rejects:

```text
http://api.example.test
```

and requires:

```text
https://api.example.test
```

For local development servers, later transport code may allow an explicit testing-only override. The secure default remains HTTPS.

---

## Why Keep Exception Details Structured?

A plain message is helpful:

```text
Project was not found.
```

Structured details are better for diagnostics:

```python
error.details.status_code
error.details.method
error.details.url
error.details.response_body
```

This supports logging, monitoring, and programmatic error handling without parsing strings.
