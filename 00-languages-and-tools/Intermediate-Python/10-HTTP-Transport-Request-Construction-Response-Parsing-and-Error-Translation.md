# Part 10: HTTP Transport, Request Construction, Response Parsing, and Error Translation

Our `craftapi` package can now validate configuration and turn raw project data into reliable `Project` objects.

The next layer is the **transport layer**.

A transport layer is responsible for the low-level mechanics of HTTP communication:

```text
CraftApiClient (high-level public interface)
        ↓
Transport layer (HTTP mechanics)
        ↓
Remote API server
```

The transport layer will know how to:

- Build HTTP requests.
- Apply headers.
- Encode JSON request bodies.
- Send requests through Python’s standard library.
- Decode response bodies.
- Translate HTTP status codes into meaningful `craftapi` exceptions.
- Avoid exposing `urllib` implementation details to package users.

The future `CraftApiClient` will use this layer, but it will not need to know how `urllib.request` works internally.

---

## What You Will Build

By the end of this part, the project will include:

```text
craftapi/
├── src/
│   └── craftapi/
│       ├── __init__.py
│       ├── config.py
│       ├── exceptions.py
│       ├── models.py
│       ├── transport.py
│       └── py.typed
└── tests/
    ├── conftest.py
    ├── test_config.py
    ├── test_exceptions.py
    ├── test_models.py
    └── test_transport.py
```

The new `transport.py` module will provide:

| Component | Responsibility |
|---|---|
| `HttpResponse` | Immutable representation of a completed HTTP response |
| `Transport` | Protocol describing the client transport contract |
| `UrllibTransport` | Standard-library implementation using `urllib.request` |
| `encode_json_body()` | Safe JSON encoding for request payloads |
| `raise_for_response_error()` | Converts unsuccessful responses into domain exceptions |

---

# Step 1: Correct the Runtime-Checkable Protocol in the Earlier Package

## The Target

We are correcting one small issue in the earlier tutorial package:

```text
pythonic-craftsmanship/src/library/decorators.py
```

This does not affect `craftapi` directly, but it corrects the `HasFunctionCallLog` protocol from Part 8.

## The Concept

`Protocol` types are normally intended for static type checkers such as `mypy`.

However, Part 8 also uses this runtime expression:

```python
isinstance(instance, HasFunctionCallLog)
```

For a protocol to support `isinstance()`, it must use the `@runtime_checkable` decorator.

Without it, Python raises:

```text
TypeError: Instance and class checks can only be used with @runtime_checkable protocols
```

This is a useful distinction:

- A normal protocol helps static analysis.
- A runtime-checkable protocol can also participate in `isinstance()` checks.

## The Implementation

In `src/library/decorators.py`, update the import.

### `src/library/decorators.py` — import correction

```python
from typing import ParamSpec, Protocol, TypeVar, runtime_checkable
```

Then add `@runtime_checkable` directly above `HasFunctionCallLog`.

### `src/library/decorators.py` — protocol correction

```python
@runtime_checkable
class HasFunctionCallLog(Protocol):
    """Describe an object that provides a per-instance function-call log."""

    def _get_function_call_log(self) -> InMemoryEventLog:
        """Return the instance-owned destination for call records."""
```

## The Verification

From the earlier `pythonic-craftsmanship` project root, run:

```bash
python -m pytest
python -m mypy src tests
```

Both commands should complete successfully.

Return to the `craftapi` project before continuing:

```bash
cd ../craftapi
```

---

# Step 2: Define the Transport Contract and HTTP Response Model

## The Target

We are creating:

```text
src/craftapi/transport.py
```

The first portion of this module defines:

- A `Transport` protocol.
- An immutable `HttpResponse` model.
- A JSON response-decoding method.

## The Concept

The client should depend on a stable transport interface, not directly on a particular HTTP library.

This is called **dependency inversion**.

Instead of this:

```text
CraftApiClient → urllib.request directly
```

we build this:

```text
CraftApiClient → Transport contract → UrllibTransport
```

That gives us two benefits:

1. The client can be tested with a fake transport that never makes real network requests.
2. The HTTP implementation can be replaced later without rewriting the public client API.

The `HttpResponse` class acts as a package-owned representation of a response. This prevents `urllib`-specific response objects from leaking into the rest of the package.

## The Implementation

Create the complete file below.

### `src/craftapi/transport.py`

```python
"""HTTP transport abstractions and urllib-based implementation for craftapi."""

from __future__ import annotations

import json
from collections.abc import Mapping
from dataclasses import dataclass
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

MAX_ERROR_RESPONSE_BODY_CHARACTERS = 4_000


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

    def json_object(self) -> Mapping[str, Any]:
        """Decode and validate a JSON object response body.

        Raises:
            CraftApiValidationError: If the body is invalid JSON or its root
                value is not a JSON object.
        """
        try:
            decoded_value = json.loads(self.text)
        except json.JSONDecodeError as error:
            raise CraftApiValidationError(
                "API response body is not valid JSON."
            ) from error

        if not isinstance(decoded_value, dict):
            raise CraftApiValidationError(
                "API response JSON root must be an object."
            )

        return decoded_value


def encode_json_body(payload: Mapping[str, object]) -> bytes:
    """Encode one request payload as compact UTF-8 JSON.

    Raises:
        CraftApiValidationError: If the payload cannot be represented as JSON.
    """
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
```

## The Verification

Run a small response-decoding example:

```bash
python -c "from craftapi.transport import HttpResponse; response = HttpResponse(status_code=200, url='https://api.example.test/projects/project-123', headers={'content-type': 'application/json'}, body=b'{\"id\":\"project-123\"}'); print(response.json_object()['id'])"
```

Expected output:

```text
project-123
```

Now verify invalid JSON handling:

```bash
python -c "from craftapi.transport import HttpResponse; response = HttpResponse(status_code=200, url='https://api.example.test', headers={}, body=b'not-json'); response.json_object()"
```

Expected result:

```text
craftapi.exceptions.CraftApiValidationError: API response body is not valid JSON.
```

---

# Step 3: Translate Unsuccessful HTTP Responses into Domain Errors

## The Target

We are extending:

```text
src/craftapi/transport.py
```

We will add a function that converts unsuccessful status codes into precise `craftapi` exceptions.

## The Concept

HTTP status codes communicate broad categories of outcomes:

| Status range | Meaning |
|---|---|
| `200–299` | Successful request |
| `401` | Authentication failed |
| `403` | Authenticated but not authorized |
| `404` | Resource does not exist |
| `500–599` | Server-side failure |
| Other `400–499` | Client request failure |

A caller should not need to write this logic repeatedly:

```python
if response.status_code == 404:
    ...
elif response.status_code == 401:
    ...
```

Instead, the transport layer translates HTTP language into the package’s domain language.

This creates a clean error boundary:

```text
HTTP 404 response
        ↓
CraftApiNotFoundError
        ↓
Caller handles a meaningful Python exception
```

## The Implementation

Replace the entire contents of `src/craftapi/transport.py` with the following version.

### `src/craftapi/transport.py`

```python
"""HTTP transport abstractions and urllib-based implementation for craftapi."""

from __future__ import annotations

import json
from collections.abc import Mapping
from dataclasses import dataclass
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

MAX_ERROR_RESPONSE_BODY_CHARACTERS = 4_000


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

    def json_object(self) -> Mapping[str, Any]:
        """Decode and validate a JSON object response body.

        Raises:
            CraftApiValidationError: If the body is invalid JSON or its root
                value is not a JSON object.
        """
        try:
            decoded_value = json.loads(self.text)
        except json.JSONDecodeError as error:
            raise CraftApiValidationError(
                "API response body is not valid JSON."
            ) from error

        if not isinstance(decoded_value, dict):
            raise CraftApiValidationError(
                "API response JSON root must be an object."
            )

        return decoded_value


def encode_json_body(payload: Mapping[str, object]) -> bytes:
    """Encode one request payload as compact UTF-8 JSON.

    Raises:
        CraftApiValidationError: If the payload cannot be represented as JSON.
    """
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
    """Raise a domain-specific error when response is not successful.

    Args:
        response: Completed HTTP response to inspect.
        method: HTTP method used for the request.

    Raises:
        CraftApiAuthenticationError: For HTTP 401 and 403.
        CraftApiNotFoundError: For HTTP 404.
        CraftApiServerError: For HTTP 5xx responses.
        CraftApiResponseError: For other unsuccessful HTTP statuses.
    """
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
```

## The Verification

Run a 404 translation example:

```bash
python -c "from craftapi.exceptions import CraftApiNotFoundError; from craftapi.transport import HttpResponse, raise_for_response_error; response = HttpResponse(status_code=404, url='https://api.example.test/projects/missing', headers={}, body=b'{\"error\":\"not found\"}'); 
try:
    raise_for_response_error(response, method='GET')
except CraftApiNotFoundError as error:
    print(type(error).__name__)
    print(error.details.status_code)
    print(error.details.response_body)"
```

Expected output:

```text
CraftApiNotFoundError
404
{"error":"not found"}
```

---

# Step 4: Implement the Standard-Library `UrllibTransport`

## The Target

We are completing:

```text
src/craftapi/transport.py
```

The module will now include a concrete `UrllibTransport` implementation.

## The Concept

Python’s standard library includes `urllib.request`, which can make HTTP requests without installing another dependency.

The low-level flow is:

```text
Build Request object
        ↓
Open network connection
        ↓
Read bytes from response
        ↓
Convert to HttpResponse
        ↓
Translate failures at the package boundary
```

`urllib` raises exceptions for two important situations:

| `urllib` exception | Meaning in `craftapi` |
|---|---|
| `URLError` | The request could not reach or communicate with the server |
| `HTTPError` | The server responded with an unsuccessful HTTP status |

An `HTTPError` still contains a response body. We convert it into `HttpResponse` so `raise_for_response_error()` can produce our own package exception.

## The Implementation

Replace `src/craftapi/transport.py` with this complete file.

### `src/craftapi/transport.py`

```python
"""HTTP transport abstractions and urllib-based implementation for craftapi."""

from __future__ import annotations

import json
from collections.abc import Mapping
from dataclasses import dataclass
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

MAX_ERROR_RESPONSE_BODY_CHARACTERS = 4_000


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

    def json_object(self) -> Mapping[str, Any]:
        """Decode and validate a JSON object response body.

        Raises:
            CraftApiValidationError: If the body is invalid JSON or its root
                value is not a JSON object.
        """
        try:
            decoded_value = json.loads(self.text)
        except json.JSONDecodeError as error:
            raise CraftApiValidationError(
                "API response body is not valid JSON."
            ) from error

        if not isinstance(decoded_value, dict):
            raise CraftApiValidationError(
                "API response JSON root must be an object."
            )

        return decoded_value


def encode_json_body(payload: Mapping[str, object]) -> bytes:
    """Encode one request payload as compact UTF-8 JSON.

    Raises:
        CraftApiValidationError: If the payload cannot be represented as JSON.
    """
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

        urllib.request.urlopen() creates and closes a response per request, so
        this implementation has no persistent client resource to release.
        The method still exists to satisfy the shared Transport contract.
        """

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

        Raises:
            CraftApiTransportError: If the request cannot reach the server.
            CraftApiResponseError: If the server returns an unsuccessful status.
        """
        normalized_method = method.strip().upper()

        if not normalized_method:
            raise ValueError("HTTP method cannot be blank.")

        if timeout_seconds <= 0:
            raise ValueError("HTTP timeout must be greater than zero.")

        request_headers = dict(headers or {})

        request = Request(
            url=url,
            data=body,
            headers=request_headers,
            method=normalized_method,
        )

        try:
            with urlopen(request, timeout=timeout_seconds) as raw_response:
                response = HttpResponse(
                    status_code=raw_response.status,
                    url=raw_response.geturl(),
                    headers={
                        key.lower(): value
                        for key, value in raw_response.headers.items()
                    },
                    body=raw_response.read(),
                )
        except HTTPError as error:
            # HTTPError is also a readable response object. Its body contains
            # useful API error details, so preserve it before translation.
            response = HttpResponse(
                status_code=error.code,
                url=error.geturl(),
                headers={
                    key.lower(): value
                    for key, value in error.headers.items()
                },
                body=error.read(),
            )
        except URLError as error:
            reason = str(error.reason)

            raise CraftApiTransportError(
                f"Could not complete HTTP request to {url}: {reason}",
                url=url,
            ) from error

        raise_for_response_error(response, method=normalized_method)

        return response
```

## The Verification

Run a direct request against a public HTTPS endpoint:

```bash
python -c "from craftapi.transport import UrllibTransport; transport = UrllibTransport(); response = transport.request(method='GET', url='https://httpbin.org/status/200', timeout_seconds=10); print(response.status_code)"
```

Expected output:

```text
200
```

If your network blocks `httpbin.org`, do not treat that as a code failure. The automated tests in the next step use no real network connection.

---

# Step 5: Export Transport Components from the Public Interface

## The Target

We are updating:

```text
src/craftapi/__init__.py
```

## The Concept

The transport types are useful for advanced consumers and for tests.

For example, a caller may later supply a custom transport:

```python
client = CraftApiClient(
    config=config,
    transport=my_test_transport,
)
```

This requires the `Transport` contract to be part of the public API.

## The Implementation

Replace the complete contents of `src/craftapi/__init__.py`.

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
from craftapi.transport import (
    HttpResponse,
    Transport,
    UrllibTransport,
    encode_json_body,
)

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
    "HttpResponse",
    "Project",
    "Transport",
    "UrllibTransport",
    "encode_json_body",
]
```

## The Verification

Run:

```bash
python -c "from craftapi import HttpResponse, Transport, UrllibTransport, encode_json_body; print(HttpResponse.__name__); print(Transport.__name__); print(UrllibTransport.__name__); print(encode_json_body({'name': 'Example'}))"
```

Expected output:

```text
HttpResponse
Transport
UrllibTransport
b'{"name":"Example"}'
```

---

# Step 6: Test the Transport Layer Without a Real Network

## The Target

We are creating:

```text
tests/test_transport.py
```

## The Concept

Network tests are unreliable when they depend on a real external server.

A real server can be unavailable because of:

- Internet outages
- DNS failures
- API downtime
- Rate limits
- Firewall rules
- Changed server behavior

Instead, we test the `urllib` boundary by replacing `urlopen` with a controlled fake.

This is called **mocking** or **patching** a dependency.

Think of it as testing a delivery workflow with a simulated delivery truck rather than waiting for a real truck to arrive.

## The Implementation

### `tests/test_transport.py`

```python
"""Tests for HTTP transport behavior without external network access."""

from __future__ import annotations

from collections.abc import Iterator
from typing import Any
from urllib.error import HTTPError

import pytest

from craftapi import (
    CraftApiAuthenticationError,
    CraftApiNotFoundError,
    CraftApiServerError,
    CraftApiTransportError,
    HttpResponse,
    UrllibTransport,
    encode_json_body,
)
from craftapi.exceptions import CraftApiValidationError


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
        """Store controlled response values for one transport test."""
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
    encoded_body = encode_json_body(
        {
            "name": "Website Redesign",
            "active": True,
        }
    )

    assert encoded_body == b'{"name":"Website Redesign","active":true}'


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

    transport = UrllibTransport()

    response = transport.request(
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
    expected_exception: type[Exception],
) -> None:
    """HTTP error responses should become specific craftapi exceptions."""

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        raise HTTPError(
            url=request.full_url,
            code=status_code,
            msg="Simulated HTTP error",
            hdrs={"Content-Type": "application/json"},
            fp=None,
        )

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    transport = UrllibTransport()

    with pytest.raises(expected_exception) as captured_error:
        transport.request(
            method="GET",
            url="https://api.example.test/projects/project-123",
            timeout_seconds=2.0,
        )

    error = captured_error.value

    assert hasattr(error, "details")
    assert error.details.status_code == status_code  # type: ignore[union-attr]


def test_urllib_transport_translates_network_error(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Network-level urllib failures should become CraftApiTransportError."""

    def fake_urlopen(request: Any, *, timeout: float) -> FakeUrlResponse:
        raise URLError("Simulated DNS failure")

    from urllib.error import URLError

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    transport = UrllibTransport()

    with pytest.raises(CraftApiTransportError, match="Simulated DNS failure"):
        transport.request(
            method="GET",
            url="https://api.example.test/projects",
            timeout_seconds=2.0,
        )
```

There are two issues in this initial test file:

1. `URLError` is used before its local import.
2. The type-ignore comment is avoidable.

Use the corrected complete file below.

### `tests/test_transport.py` (corrected final contents)

```python
"""Tests for HTTP transport behavior without external network access."""

from __future__ import annotations

from typing import Any
from urllib.error import HTTPError, URLError

import pytest

from craftapi import (
    CraftApiAuthenticationError,
    CraftApiNotFoundError,
    CraftApiServerError,
    CraftApiTransportError,
    HttpResponse,
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
        """Store controlled response values for one transport test."""
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
    encoded_body = encode_json_body(
        {
            "name": "Website Redesign",
            "active": True,
        }
    )

    assert encoded_body == b'{"name":"Website Redesign","active":true}'


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

    transport = UrllibTransport()

    response = transport.request(
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
            fp=None,
        )

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)

    transport = UrllibTransport()

    with pytest.raises(expected_exception) as captured_error:
        transport.request(
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

    transport = UrllibTransport()

    with pytest.raises(CraftApiTransportError, match="Simulated DNS failure"):
        transport.request(
            method="GET",
            url="https://api.example.test/projects",
            timeout_seconds=2.0,
        )
```

## The Verification

Run the new tests:

```bash
python -m pytest tests/test_transport.py
```

Expected output:

```text
9 passed
```

Then run the full suite:

```bash
python -m pytest
```

Expected output includes:

```text
... passed
```

Finally, run static type checking:

```bash
python -m mypy src tests
```

Expected output:

```text
Success: no issues found in ... source files
```

---

# Part 10 Reference: HTTP Transport Design

## Why Use a Transport Protocol?

The `Transport` protocol lets high-level code depend on behavior instead of implementation details.

Any object implementing these methods is compatible:

```python
def request(...) -> HttpResponse:
    ...

def close() -> None:
    ...
```

This means the future client can use:

- `UrllibTransport` in production.
- `FakeTransport` in unit tests.
- A custom `httpx` or `requests` transport adapter if a project needs it.

---

## Why Return `HttpResponse` Instead of `urllib` Objects?

Returning raw `urllib` objects would spread low-level implementation details throughout the package.

Instead, the transport returns:

```python
HttpResponse(
    status_code=200,
    url="https://api.example.test/projects/project-123",
    headers={"content-type": "application/json"},
    body=b"...",
)
```

This object is:

- Immutable
- Easy to construct in tests
- Independent of `urllib`
- Safe for the model and client layers to consume

---

## Why Use `urllib` Instead of a Third-Party HTTP Package?

`urllib.request` is in Python’s standard library, so it adds no runtime dependency.

It is sufficient for this educational API client.

In many production teams, developers choose `httpx` or `requests` because they offer richer ergonomics, connection pooling, async support, and middleware ecosystems.

The architecture remains useful regardless of the HTTP library because the rest of the package depends on `Transport`, not on `urllib`.

---

## Error Translation Rules

The transport translates responses as follows:

| HTTP status | Exception |
|---|---|
| `200–299` | No exception |
| `401`, `403` | `CraftApiAuthenticationError` |
| `404` | `CraftApiNotFoundError` |
| `500–599` | `CraftApiServerError` |
| Other non-success status | `CraftApiResponseError` |
| Connection, DNS, or low-level request failure | `CraftApiTransportError` |

This allows calling code to handle expected categories precisely:

```python
from craftapi import (
    CraftApiAuthenticationError,
    CraftApiNotFoundError,
    CraftApiTransportError,
)

try:
    ...
except CraftApiAuthenticationError:
    print("Check the API token.")
except CraftApiNotFoundError:
    print("The project does not exist.")
except CraftApiTransportError:
    print("The API could not be reached.")
```

---

## Do Not Log Authorization Headers or Tokens

The request contains an authorization header such as:

```text
Authorization: Bearer secret-token
```

Never include authorization headers, raw tokens, passwords, or cookies in:

- Exception messages
- Debug output
- Test snapshots
- Analytics events
- Application logs

Our transport errors contain the method, URL, status code, and a bounded response body—but not request headers.
