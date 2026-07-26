# Part 12: Production Hardening and Release Readiness

The `CraftApiClient` now supports authenticated project operations, typed models, pagination, context management, and testable transport injection.

This final part hardens the package for production use.

We will add:

- A safe retry policy for temporary transport failures.
- Exponential backoff between retry attempts.
- Structured logging that never logs API tokens.
- A correction for boolean pagination values.
- Robust tests for retry behavior and HTTP error bodies.
- Build configuration for creating distributable package artifacts.
- Final documentation and release verification.

---

# Step 1: Correct Boolean Pagination Validation

## The Target

We are correcting `ProjectPage.from_api_payload()` in:

```text
src/craftapi/models.py
```

## The Concept

In Python, `bool` is a subclass of `int`:

```python
isinstance(True, int)  # True
```

That means this validation is incomplete:

```python
isinstance(raw_next_page, int)
```

Without an explicit boolean check, this invalid API response would be accepted:

```json
{
  "items": [],
  "next_page": true
}
```

A page number must be an actual positive integer—not `True` or `False`.

## The Implementation

Replace the complete file.

### `src/craftapi/models.py`

```python
"""Validated immutable resource models returned by the Craft API."""

from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from datetime import datetime
from typing import Any

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


@dataclass(frozen=True, slots=True)
class ProjectPage:
    """One parsed page of projects returned by the remote API."""

    items: tuple[Project, ...]
    next_page: int | None

    @classmethod
    def from_api_payload(cls, payload: Mapping[str, Any]) -> ProjectPage:
        """Validate an API page object and construct a ProjectPage.

        Expected JSON shape:

        {
            "items": [{...project fields...}],
            "next_page": 2
        }

        `next_page` may be null when no additional result page exists.
        """
        raw_items = payload.get("items")

        if not isinstance(raw_items, list):
            raise CraftApiValidationError('API field "items" must be a list.')

        projects: list[Project] = []

        for item_index, raw_item in enumerate(raw_items):
            if not isinstance(raw_item, dict):
                raise CraftApiValidationError(
                    f'API field "items" entry {item_index} must be an object.'
                )

            projects.append(Project.from_api_payload(raw_item))

        raw_next_page = payload.get("next_page")

        if raw_next_page is None:
            next_page = None
        elif (
            not isinstance(raw_next_page, bool)
            and isinstance(raw_next_page, int)
            and raw_next_page >= 1
        ):
            next_page = raw_next_page
        else:
            raise CraftApiValidationError(
                'API field "next_page" must be a positive integer or null.'
            )

        return cls(items=tuple(projects), next_page=next_page)
```

## The Verification

Run:

```bash
python -c "from craftapi import CraftApiValidationError, ProjectPage; 
try:
    ProjectPage.from_api_payload({'items': [], 'next_page': True})
except CraftApiValidationError as error:
    print(error)"
```

Expected output:

```text
API field "next_page" must be a positive integer or null.
```

---

# Step 2: Add a Safe Retry Policy

## The Target

We are replacing:

```text
src/craftapi/transport.py
```

The new version adds a `RetryPolicy` and retry behavior to `UrllibTransport`.

## The Concept

Not every failure should be retried.

A retry is reasonable for temporary problems such as:

- DNS or connection failures
- Server overload (`503`)
- Temporary gateway errors (`502`, `504`)
- Rate limiting (`429`)

A retry is not normally appropriate for:

- Invalid client input (`400`)
- Authentication failure (`401`)
- Missing resources (`404`)
- Unsafe write operations such as an unprotected `POST`

To reduce the risk of duplicate writes, this transport retries only **idempotent** methods by default:

```text
GET, HEAD, OPTIONS, PUT, DELETE
```

An idempotent operation has the same intended end state whether it runs once or multiple times.

The retry delay uses **exponential backoff**:

```text
attempt 1 retry delay: 0.25 seconds
attempt 2 retry delay: 0.50 seconds
attempt 3 retry delay: 1.00 seconds
```

This gives an overloaded service time to recover.

## The Implementation

### `src/craftapi/transport.py`

```python
"""HTTP transport abstractions and urllib-based implementation for craftapi."""

from __future__ import annotations

import json
import logging
from collections.abc import Callable, Mapping
from dataclasses import dataclass
from time import sleep
from typing import Any, Protocol
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

from craftapi.exceptions import (
    ApiErrorDetails,
    CraftApiAuthenticationError,
    CraftApiNotFoundError,
    CraftApiResponseError,
    CraftApiServerError,
    CraftApiTransportError,
    CraftApiValidationError,
)

LOGGER = logging.getLogger(__name__)

MAX_ERROR_RESPONSE_BODY_CHARACTERS = 4_000
IDEMPOTENT_HTTP_METHODS = frozenset({"DELETE", "GET", "HEAD", "OPTIONS", "PUT"})
DEFAULT_RETRYABLE_STATUS_CODES = frozenset({429, 502, 503, 504})


class Transport(Protocol):
    """Describe the low-level HTTP behavior required by CraftApiClient."""

    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        """Send one HTTP request and return a package-owned response model."""

    def close(self) -> None:
        """Release transport-owned resources."""


@dataclass(frozen=True, slots=True)
class RetryPolicy:
    """Configuration for safe retries of temporary idempotent requests."""

    max_attempts: int = 3
    initial_delay_seconds: float = 0.25
    maximum_delay_seconds: float = 2.0
    retryable_status_codes: frozenset[int] = DEFAULT_RETRYABLE_STATUS_CODES

    def __post_init__(self) -> None:
        """Validate retry settings before any request uses them."""
        if self.max_attempts < 1:
            raise ValueError("Retry max_attempts must be at least 1.")

        if self.initial_delay_seconds < 0:
            raise ValueError("Retry initial_delay_seconds cannot be negative.")

        if self.maximum_delay_seconds < self.initial_delay_seconds:
            raise ValueError(
                "Retry maximum_delay_seconds cannot be less than "
                "initial_delay_seconds."
            )

        for status_code in self.retryable_status_codes:
            if isinstance(status_code, bool) or not 100 <= status_code <= 599:
                raise ValueError(
                    "Retryable HTTP status codes must be integers from 100 to 599."
                )

    def delay_for_retry(self, completed_attempt_number: int) -> float:
        """Return a capped exponential delay after a failed attempt."""
        if completed_attempt_number < 1:
            raise ValueError("Completed attempt number must be at least 1.")

        uncapped_delay = self.initial_delay_seconds * (
            2 ** (completed_attempt_number - 1)
        )

        return min(uncapped_delay, self.maximum_delay_seconds)


@dataclass(frozen=True, slots=True)
class HttpResponse:
    """An immutable HTTP response independent of a specific HTTP library."""

    status_code: int
    url: str
    headers: Mapping[str, str]
    body: bytes

    @property
    def text(self) -> str:
        """Decode the body as UTF-8, replacing invalid byte sequences safely."""
        return self.body.decode("utf-8", errors="replace")

    def json_value(self) -> Any:
        """Decode the response body as a JSON value."""
        try:
            return json.loads(self.text)
        except json.JSONDecodeError as error:
            raise CraftApiValidationError(
                "API response body is not valid JSON."
            ) from error

    def json_object(self) -> Mapping[str, Any]:
        """Decode and validate a JSON object response body."""
        decoded_value = self.json_value()

        if not isinstance(decoded_value, dict):
            raise CraftApiValidationError(
                "API response JSON root must be an object."
            )

        return decoded_value


def encode_json_body(payload: Mapping[str, object]) -> bytes:
    """Encode one request payload as compact UTF-8 JSON."""
    try:
        encoded_text = json.dumps(
            payload,
            ensure_ascii=False,
            separators=(",", ":"),
        )
    except (TypeError, ValueError) as error:
        raise CraftApiValidationError(
            "Request payload cannot be encoded as JSON."
        ) from error

    return encoded_text.encode("utf-8")


def raise_for_response_error(
    response: HttpResponse,
    *,
    method: str,
) -> None:
    """Raise a domain-specific error when response is not successful."""
    if 200 <= response.status_code < 300:
        return

    response_body = response.text[:MAX_ERROR_RESPONSE_BODY_CHARACTERS] or None

    details = ApiErrorDetails(
        status_code=response.status_code,
        method=method.upper(),
        url=response.url,
        response_body=response_body,
    )

    message = (
        f"Craft API request failed with HTTP {response.status_code}: "
        f"{method.upper()} {response.url}"
    )

    if response.status_code in {401, 403}:
        raise CraftApiAuthenticationError(message, details=details)

    if response.status_code == 404:
        raise CraftApiNotFoundError(message, details=details)

    if 500 <= response.status_code < 600:
        raise CraftApiServerError(message, details=details)

    raise CraftApiResponseError(message, details=details)


class UrllibTransport:
    """HTTP transport implementation backed by Python's urllib.request."""

    def __init__(
        self,
        *,
        retry_policy: RetryPolicy | None = None,
        sleeper: Callable[[float], None] = sleep,
    ) -> None:
        """Create a transport with an optional retry policy.

        Args:
            retry_policy: Optional policy for temporary idempotent failures.
                When omitted, every request has one attempt.
            sleeper: Delay function injected primarily for deterministic tests.
        """
        self._retry_policy = retry_policy
        self._sleeper = sleeper

    def __enter__(self) -> UrllibTransport:
        """Return this transport for context-manager usage."""
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        """Close transport resources without suppressing caller exceptions."""
        self.close()
        return False

    def close(self) -> None:
        """Release transport resources.

        urllib opens and closes each response per request. This method exists
        because all transports must provide a common cleanup contract.
        """

    def _can_retry(self, method: str, attempt_number: int) -> bool:
        """Return whether another attempt is available for an idempotent method."""
        return (
            self._retry_policy is not None
            and method in IDEMPOTENT_HTTP_METHODS
            and attempt_number < self._retry_policy.max_attempts
        )

    def _sleep_before_retry(
        self,
        *,
        method: str,
        url: str,
        attempt_number: int,
        reason: str,
    ) -> None:
        """Log safe retry metadata and wait according to the retry policy."""
        if self._retry_policy is None:
            return

        delay_seconds = self._retry_policy.delay_for_retry(attempt_number)

        # Deliberately omit request headers and body. They may contain secrets.
        LOGGER.warning(
            "Retrying Craft API request: method=%s url=%s attempt=%s/%s "
            "delay_seconds=%.3f reason=%s",
            method,
            url,
            attempt_number + 1,
            self._retry_policy.max_attempts,
            delay_seconds,
            reason,
        )

        if delay_seconds > 0:
            self._sleeper(delay_seconds)

    @staticmethod
    def _headers_from_urllib(
        headers: Mapping[str, str] | None,
    ) -> dict[str, str]:
        """Normalize urllib headers to lower-case dictionary keys."""
        if headers is None:
            return {}

        return {
            key.lower(): value
            for key, value in headers.items()
        }

    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        """Send one HTTP request using urllib and return HttpResponse.

        Temporary network failures and selected temporary HTTP statuses are
        retried only for idempotent methods when a RetryPolicy was supplied.
        """
        normalized_method = method.strip().upper()

        if not normalized_method:
            raise ValueError("HTTP method cannot be blank.")

        if timeout_seconds <= 0:
            raise ValueError("HTTP timeout must be greater than zero.")

        request = Request(
            url=url,
            data=body,
            headers=dict(headers or {}),
            method=normalized_method,
        )

        max_attempts = (
            self._retry_policy.max_attempts
            if self._retry_policy is not None
            else 1
        )

        for attempt_number in range(1, max_attempts + 1):
            try:
                with urlopen(request, timeout=timeout_seconds) as raw_response:
                    response = HttpResponse(
                        status_code=raw_response.status,
                        url=raw_response.geturl(),
                        headers=self._headers_from_urllib(raw_response.headers),
                        body=raw_response.read(),
                    )
            except HTTPError as error:
                response = HttpResponse(
                    status_code=error.code,
                    url=error.geturl(),
                    headers=self._headers_from_urllib(error.headers),
                    body=error.read(),
                )
            except URLError as error:
                if self._can_retry(normalized_method, attempt_number):
                    self._sleep_before_retry(
                        method=normalized_method,
                        url=url,
                        attempt_number=attempt_number,
                        reason=type(error.reason).__name__,
                    )
                    continue

                raise CraftApiTransportError(
                    f"Could not complete HTTP request to {url}: {error.reason}",
                    url=url,
                ) from error

            should_retry_status = (
                self._retry_policy is not None
                and response.status_code in self._retry_policy.retryable_status_codes
            )

            if should_retry_status and self._can_retry(
                normalized_method,
                attempt_number,
            ):
                self._sleep_before_retry(
                    method=normalized_method,
                    url=url,
                    attempt_number=attempt_number,
                    reason=f"HTTP {response.status_code}",
                )
                continue

            raise_for_response_error(response, method=normalized_method)

            LOGGER.debug(
                "Craft API request succeeded: method=%s url=%s status_code=%s",
                normalized_method,
                url,
                response.status_code,
            )

            return response

        raise RuntimeError("HTTP retry loop ended unexpectedly.")
```

## The Verification

Run:

```bash
python -c "from craftapi.transport import RetryPolicy; policy = RetryPolicy(max_attempts=4, initial_delay_seconds=0.25, maximum_delay_seconds=1.0); print([policy.delay_for_retry(attempt) for attempt in (1, 2, 3, 4)])"
```

Expected output:

```text
[0.25, 0.5, 1.0, 1.0]
```

---

# Step 3: Expose Retry Types Through the Public API

## The Target

We are updating:

```text
src/craftapi/__init__.py
```

## The Concept

`RetryPolicy` is optional configuration that advanced package users may need when constructing their own transport:

```python
from craftapi import RetryPolicy, UrllibTransport
```

A public package interface should expose supported extension points deliberately.

## The Implementation

### `src/craftapi/__init__.py`

```python
"""Typed Python client package for the Craft project-management API."""

from craftapi.client import CraftApiClient
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
from craftapi.models import Project, ProjectPage
from craftapi.transport import (
    HttpResponse,
    RetryPolicy,
    Transport,
    UrllibTransport,
    encode_json_body,
)

__all__ = [
    "ApiErrorDetails",
    "CraftApiAuthenticationError",
    "CraftApiClient",
    "CraftApiConfig",
    "CraftApiConfigurationError",
    "CraftApiError",
    "CraftApiNotFoundError",
    "CraftApiResponseError",
    "CraftApiServerError",
    "CraftApiTransportError",
    "CraftApiValidationError",
    "HttpResponse",
    "Project",
    "ProjectPage",
    "RetryPolicy",
    "Transport",
    "UrllibTransport",
    "encode_json_body",
]
```

## The Verification

Run:

```bash
python -c "from craftapi import RetryPolicy, UrllibTransport; transport = UrllibTransport(retry_policy=RetryPolicy(max_attempts=2)); print(type(transport).__name__)"
```

Expected output:

```text
UrllibTransport
```

---

# Step 4: Test Retries and Correct HTTP Error Simulation

## The Target

We are replacing:

```text
tests/test_transport.py
```

## The Concept

Retry tests must not actually wait.

The transport accepts an injected `sleeper` function:

```python
sleeper: Callable[[float], None]
```

In production, it defaults to `time.sleep`.

In tests, we provide:

```python
recorded_delays.append
```

This records the requested delays without pausing the test suite.

We also use `io.BytesIO` when constructing `HTTPError`. An `HTTPError` response body must be a readable file-like object—not `None`—when the transport calls `error.read()`.

## The Implementation

### `tests/test_transport.py`

```python
"""Tests for HTTP transport behavior without external network access."""

from __future__ import annotations

from io import BytesIO
from typing import Any
from urllib.error import HTTPError, URLError

import pytest

from craftapi import (
    CraftApiAuthenticationError,
    CraftApiNotFoundError,
    CraftApiServerError,
    CraftApiTransportError,
    HttpResponse,
    RetryPolicy,
    UrllibTransport,
    encode_json_body,
)
from craftapi.exceptions import CraftApiResponseError, CraftApiValidationError


class FakeUrlResponse:
    """Small context-manager-compatible stand-in for urllib responses."""

    def __init__(
        self,
        *,
        status: int,
        url: str,
        headers: dict[str, str],
        body: bytes,
    ) -> None:
        self.status = status
        self._url = url
        self.headers = headers
        self._body = body

    def __enter__(self) -> FakeUrlResponse:
        """Return this fake response when entering a with block."""
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        """Do not suppress exceptions from the with block."""
        return False

    def geturl(self) -> str:
        """Return the fake response URL."""
        return self._url

    def read(self) -> bytes:
        """Return the fake response body."""
        return self._body


def test_encode_json_body_creates_compact_utf8_json() -> None:
    """Request JSON should be compact and encoded as UTF-8 bytes."""
    assert encode_json_body({"name": "Website Redesign", "active": True}) == (
        b'{"name":"Website Redesign","active":true}'
    )


def test_http_response_rejects_json_array_when_object_is_required() -> None:
    """Object-specific response parsing should reject a JSON array root."""
    response = HttpResponse(
        status_code=200,
        url="https://api.example.test/projects",
        headers={"content-type": "application/json"},
        body=b"[]",
    )

    with pytest.raises(
        CraftApiValidationError,
        match="JSON root must be an object",
    ):
        response.json_object()


def test_urllib_transport_builds_expected_successful_request(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The transport should forward method, headers, body, and timeout."""
    captured_request: dict[str, Any] = {}
    captured_timeout: list[float] = []

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        captured_request["method"] = request.get_method()
        captured_request["url"] = request.full_url
        captured_request["authorization"] = request.get_header("Authorization")
        captured_request["content_type"] = request.get_header("Content-type")
        captured_request["body"] = request.data
        captured_timeout.append(timeout)

        return FakeUrlResponse(
            status=201,
            url=request.full_url,
            headers={"Content-Type": "application/json"},
            body=b'{"id":"project-123"}',
        )

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    response = UrllibTransport().request(
        method="post",
        url="https://api.example.test/projects",
        headers={
            "Authorization": "Bearer example-token",
            "Content-Type": "application/json",
        },
        body=b'{"name":"Website Redesign"}',
        timeout_seconds=4.5,
    )

    assert response.status_code == 201
    assert response.json_object() == {"id": "project-123"}
    assert captured_request == {
        "method": "POST",
        "url": "https://api.example.test/projects",
        "authorization": "Bearer example-token",
        "content_type": "application/json",
        "body": b'{"name":"Website Redesign"}',
    }
    assert captured_timeout == [4.5]


@pytest.mark.parametrize(
    ("status_code", "expected_exception"),
    [
        (401, CraftApiAuthenticationError),
        (403, CraftApiAuthenticationError),
        (404, CraftApiNotFoundError),
        (500, CraftApiServerError),
        (503, CraftApiServerError),
    ],
)
def test_urllib_transport_translates_http_errors(
    monkeypatch: pytest.MonkeyPatch,
    status_code: int,
    expected_exception: type[CraftApiResponseError],
) -> None:
    """HTTP error responses should become specific craftapi exceptions."""

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        raise HTTPError(
            url=request.full_url,
            code=status_code,
            msg="Simulated HTTP error",
            hdrs={"Content-Type": "application/json"},
            fp=BytesIO(b'{"error":"simulated"}'),
        )

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    with pytest.raises(expected_exception) as captured_error:
        UrllibTransport().request(
            method="GET",
            url="https://api.example.test/projects/project-123",
            timeout_seconds=2.0,
        )

    assert captured_error.value.details.status_code == status_code


def test_urllib_transport_translates_network_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Network-level urllib failures should become CraftApiTransportError."""

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        raise URLError("Simulated DNS failure")

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    with pytest.raises(CraftApiTransportError, match="Simulated DNS failure"):
        UrllibTransport().request(
            method="GET",
            url="https://api.example.test/projects",
            timeout_seconds=2.0,
        )


def test_transport_retries_temporary_network_failure_for_get(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """GET should retry a temporary URLError and eventually succeed."""
    call_count = 0
    recorded_delays: list[float] = []

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        nonlocal call_count
        call_count += 1

        if call_count < 3:
            raise URLError("Temporary connection reset.")

        return FakeUrlResponse(
            status=200,
            url=request.full_url,
            headers={"Content-Type": "application/json"},
            body=b'{"ok":true}',
        )

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    response = UrllibTransport(
        retry_policy=RetryPolicy(
            max_attempts=3,
            initial_delay_seconds=0.25,
            maximum_delay_seconds=1.0,
        ),
        sleeper=recorded_delays.append,
    ).request(
        method="GET",
        url="https://api.example.test/projects",
        timeout_seconds=2.0,
    )

    assert response.json_object() == {"ok": True}
    assert call_count == 3
    assert recorded_delays == [0.25, 0.5]


def test_transport_does_not_retry_post_network_failure(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """POST is not retried by default because repeating it may create duplicates."""
    call_count = 0

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        nonlocal call_count
        call_count += 1
        raise URLError("Temporary connection reset.")

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    with pytest.raises(CraftApiTransportError):
        UrllibTransport(
            retry_policy=RetryPolicy(max_attempts=3),
            sleeper=lambda delay: None,
        ).request(
            method="POST",
            url="https://api.example.test/projects",
            body=b'{"name":"Example"}',
            timeout_seconds=2.0,
        )

    assert call_count == 1


def test_transport_retries_selected_temporary_http_status(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """GET should retry HTTP 503 and return a later successful response."""
    call_count = 0
    recorded_delays: list[float] = []

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        nonlocal call_count
        call_count += 1

        if call_count == 1:
            raise HTTPError(
                url=request.full_url,
                code=503,
                msg="Service unavailable",
                hdrs={"Content-Type": "application/json"},
                fp=BytesIO(b'{"error":"busy"}'),
            )

        return FakeUrlResponse(
            status=200,
            url=request.full_url,
            headers={"Content-Type": "application/json"},
            body=b'{"ok":true}',
        )

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    response = UrllibTransport(
        retry_policy=RetryPolicy(
            max_attempts=2,
            initial_delay_seconds=0.5,
            maximum_delay_seconds=1.0,
        ),
        sleeper=recorded_delays.append,
    ).request(
        method="GET",
        url="https://api.example.test/projects",
        timeout_seconds=2.0,
    )

    assert response.status_code == 200
    assert call_count == 2
    assert recorded_delays == [0.5]


def test_retry_policy_rejects_invalid_configuration() -> None:
    """Invalid retry settings should fail at construction time."""
    with pytest.raises(ValueError, match="max_attempts must be at least 1"):
        RetryPolicy(max_attempts=0)

    with pytest.raises(ValueError, match="cannot be negative"):
        RetryPolicy(initial_delay_seconds=-0.1)

    with pytest.raises(ValueError, match="must be integers from 100 to 599"):
        RetryPolicy(retryable_status_codes=frozenset({True}))
```

## The Verification

Run:

```bash
python -m pytest tests/test_transport.py
```

Expected output includes:

```text
13 passed
```

---

# Step 5: Configure Package Builds and Release Documentation

## The Target

We are updating:

```text
pyproject.toml
README.md
```

## The Concept

An installable package should be tested the same way users will consume it.

A package build creates distributable artifacts:

- A source distribution (`.tar.gz`)
- A wheel (`.whl`)

The wheel is the normal installable format for Python users.

## The Implementation

Replace `pyproject.toml`.

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
  "Typing :: Typed",
]

[project.optional-dependencies]
dev = [
  "build>=1.2",
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

Replace the README.

### `README.md`

```md
# craftapi

`craftapi` is a typed, tested Python client package for a project-management HTTP API.

It demonstrates a production-oriented Python package architecture:

- Immutable validated configuration
- Environment-variable-based secret handling
- Typed, immutable API models
- HTTP transport abstraction
- Clear exception hierarchy
- Safe retry support for idempotent requests
- Lazy pagination
- Context-managed client cleanup
- `pytest` tests and `mypy` type checking

## Requirements

- Python 3.11 or newer
- An HTTPS-compatible Craft API endpoint
- A valid API token

## Installation

For local development:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install --editable ".[dev]"
```

On Windows PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install --editable ".[dev]"
```

## Configuration

Do not hard-code API tokens in source files.

Set these environment variables:

| Variable | Required | Description |
|---|---:|---|
| `CRAFTAPI_BASE_URL` | Yes | HTTPS API base URL, for example `https://api.example.com` |
| `CRAFTAPI_API_TOKEN` | Yes | Bearer token used for authentication |
| `CRAFTAPI_TIMEOUT_SECONDS` | No | Positive request timeout in seconds; defaults to `10.0` |

Example for macOS or Linux:

```bash
export CRAFTAPI_BASE_URL="https://api.example.com"
export CRAFTAPI_API_TOKEN="replace-with-a-real-token"
export CRAFTAPI_TIMEOUT_SECONDS="10"
```

Example for Windows PowerShell:

```powershell
$env:CRAFTAPI_BASE_URL = "https://api.example.com"
$env:CRAFTAPI_API_TOKEN = "replace-with-a-real-token"
$env:CRAFTAPI_TIMEOUT_SECONDS = "10"
```

## Basic Usage

```python
from craftapi import CraftApiClient

with CraftApiClient.from_environment() as client:
    project = client.get_project("project-123")

print(project.name)
print(project.status)
```

## Create a Project

```python
from craftapi import CraftApiClient

with CraftApiClient.from_environment() as client:
    project = client.create_project(
        name="Website Redesign",
        description="Modernize the public website.",
    )

print(project.id)
```

## Iterate Through Projects

`iter_projects()` is lazy. It requests the next API page only when iteration needs more values.

```python
from craftapi import CraftApiClient

with CraftApiClient.from_environment() as client:
    for project in client.iter_projects(page_size=50):
        print(f"{project.id}: {project.name}")
```

## Optional Retry Configuration

Retries are limited to idempotent methods such as `GET` and selected temporary failures such as HTTP `503`.

```python
from craftapi import (
    CraftApiClient,
    CraftApiConfig,
    RetryPolicy,
    UrllibTransport,
)

config = CraftApiConfig.from_environment()

transport = UrllibTransport(
    retry_policy=RetryPolicy(
        max_attempts=3,
        initial_delay_seconds=0.25,
        maximum_delay_seconds=2.0,
    )
)

with CraftApiClient(config=config, transport=transport) as client:
    project = client.get_project("project-123")
```

`POST` requests are not retried automatically because repeating a write can create duplicate resources unless the server supports idempotency keys.

## Error Handling

```python
from craftapi import (
    CraftApiAuthenticationError,
    CraftApiClient,
    CraftApiNotFoundError,
    CraftApiTransportError,
)

try:
    with CraftApiClient.from_environment() as client:
        project = client.get_project("project-123")
except CraftApiAuthenticationError:
    print("Check the configured API token.")
except CraftApiNotFoundError:
    print("The project does not exist.")
except CraftApiTransportError:
    print("The API endpoint could not be reached.")
else:
    print(project.name)
```

## Development Commands

Run automated tests:

```bash
python -m pytest
```

Run static type checks:

```bash
python -m mypy src tests
```

Build distributable artifacts:

```bash
python -m build
```

The generated source distribution and wheel are written to `dist/`.

## Security Notes

- Never commit `.env` files containing real tokens.
- Never write API tokens to logs, exception messages, screenshots, or test fixtures.
- Use HTTPS endpoints in all non-test environments.
- Rotate compromised tokens immediately.
```

Install the added build dependency:

```bash
python -m pip install --editable ".[dev]"
```

## The Verification

Build the package:

```bash
rm -rf dist build
python -m build
```

On Windows PowerShell:

```powershell
Remove-Item -Recurse -Force dist, build -ErrorAction SilentlyContinue
python -m build
```

Expected output includes artifacts similar to:

```text
dist/
├── craftapi-0.1.0-py3-none-any.whl
└── craftapi-0.1.0.tar.gz
```

Confirm the wheel includes the typing marker:

```bash
python -c "from zipfile import ZipFile; from pathlib import Path; wheel = next(Path('dist').glob('*.whl')); archive = ZipFile(wheel); names = archive.namelist(); print(any(name.endswith('craftapi/py.typed') for name in names))"
```

Expected output:

```text
True
```

---

# Step 6: Run the Final Production Verification Pipeline

## The Target

We are verifying the complete package before release.

## The Concept

A release pipeline is a repeatable checklist.

It is like an aircraft preflight inspection: a successful engine test alone is not enough. You verify every critical system before takeoff.

For this package, the production checklist is:

```text
Install dependencies
    ↓
Run tests
    ↓
Run static analysis
    ↓
Build distribution artifacts
    ↓
Inspect package contents
```

## The Implementation

Run these commands from the `craftapi` project root:

```bash
python -m pip install --editable ".[dev]"
python -m pytest
python -m mypy src tests
python -m build
```

Optionally inspect package metadata:

```bash
python -m pip show craftapi
```

## The Verification

Expected results:

```text
... passed
Success: no issues found in ... source files
Successfully built craftapi-0.1.0.tar.gz and craftapi-0.1.0-py3-none-any.whl
```

Your total test count may differ slightly if you added extra tests, but there should be:

- No failed tests
- No `mypy` errors
- A wheel and source distribution in `dist/`

---

# Part 12 Reference: Production Hardening Principles

## Retry Only Temporary and Safe Failures

Retries can make temporary outages less visible to users, but they can also create duplicate work.

Safe default:

```text
Retry GET requests after temporary network failures or 503 responses.
```

Unsafe default:

```text
Retry every exception and every POST request.
```

For write operations, use server-supported idempotency keys if available.

---

## Exponential Backoff

A fixed retry delay can cause many clients to retry at the same time.

Exponential backoff spreads retries over a larger time window:

```text
0.25s → 0.50s → 1.00s → 2.00s
```

In high-scale distributed systems, add random **jitter** too. Jitter is a small random variation that further reduces synchronized retry spikes.

---

## Logging Without Leaking Secrets

Safe log fields include:

- HTTP method
- URL, when it contains no credentials
- Status code
- Retry attempt number
- Retry delay
- Exception category

Unsafe log fields include:

- `Authorization` headers
- API tokens
- Passwords
- Cookies
- Full request bodies when they can contain sensitive data

The transport logs only safe request metadata.

---

## Final Capstone Architecture

```text
Application Code
      │
      ▼
CraftApiClient
  ├── Validates public input
  ├── Builds URLs and headers
  ├── Parses models
  ├── Handles pagination
  └── Owns transport lifetime
      │
      ▼
Transport Protocol
  ├── UrllibTransport
  ├── FakeTransport for tests
  └── Future custom adapters
      │
      ▼
HTTP API
```

This separation keeps each layer focused:

| Layer | Main responsibility |
|---|---|
| Configuration | Validate endpoint, token, timeout |
| Models | Validate remote JSON and expose typed data |
| Client | Provide domain-friendly project operations |
| Transport | Send HTTP requests and translate failures |
| Exceptions | Give callers precise failure categories |
| Tests | Prove behavior without depending on real networks |
