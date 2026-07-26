[GENERATED: Capstone, Part 10 — HTTP Transport, Request Construction, Response Parsing, and Error Translation]  
[STARTING: Capstone, Part 11 — Building `CraftApiClient`: Authentication, Project Operations, Pagination, and Context Management]

# Part 11: Build the Public `CraftApiClient`

The transport layer can now send requests and translate low-level HTTP failures into meaningful `craftapi` exceptions.

Now we build the package’s main public interface:

```python
from craftapi import CraftApiClient

with CraftApiClient.from_environment() as client:
    project = client.get_project("project-123")
    print(project.name)
```

The `CraftApiClient` will hide the mechanics of:

- Constructing resource URLs
- Adding authorization and API headers
- Encoding JSON request bodies
- Parsing API JSON
- Converting project payloads into `Project` models
- Paginating through project lists
- Managing the transport lifetime through `with`

The client should feel like a knowledgeable assistant. Callers state what they need—“get this project” or “iterate through projects”—and the client handles the HTTP details.

---

## What You Will Build

The package will grow into this structure:

```text
craftapi/
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

The public client will support:

```python
client.get_project("project-123")
client.create_project(name="Website Redesign", description="...")
client.iter_projects(page_size=25)
client.close()

with CraftApiClient(...) as client:
    ...
```

---

# Step 1: Extend Transport JSON Decoding for List Responses

## The Target

We are updating:

```text
src/craftapi/transport.py
```

The existing `HttpResponse.json_object()` method only accepts JSON objects:

```json
{
  "id": "project-123"
}
```

Pagination responses commonly contain arrays:

```json
[
  {
    "id": "project-123"
  }
]
```

We will add a general `json_value()` method while retaining `json_object()` for endpoints that specifically require an object.

## The Concept

Different endpoints return different JSON shapes:

| Endpoint type | Typical JSON shape |
|---|---|
| Get one project | Object |
| Create one project | Object |
| List projects | Object containing `items`, or an array |
| Error response | Usually object, but not guaranteed |

A response parser should not incorrectly assume all successful responses have the same shape.

Think of JSON as delivered packages:

- Some packages contain one item.
- Some contain a box of many items.
- The receiving code should inspect the package type before treating it as one thing or many things.

## The Implementation

Replace the complete file.

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

    def json_value(self) -> Any:
        """Decode the response body as a JSON value.

        Raises:
            CraftApiValidationError: If the response body is not valid JSON.
        """
        try:
            return json.loads(self.text)
        except json.JSONDecodeError as error:
            raise CraftApiValidationError(
                "API response body is not valid JSON."
            ) from error

    def json_object(self) -> Mapping[str, Any]:
        """Decode and validate a JSON object response body.

        Raises:
            CraftApiValidationError: If the body is invalid JSON or its root
                value is not a JSON object.
        """
        decoded_value = self.json_value()

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

        request = Request(
            url=url,
            data=body,
            headers=dict(headers or {}),
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
            raise CraftApiTransportError(
                f"Could not complete HTTP request to {url}: {error.reason}",
                url=url,
            ) from error

        raise_for_response_error(response, method=normalized_method)

        return response
```

## The Verification

Run:

```bash
python -c "from craftapi.transport import HttpResponse; response = HttpResponse(status_code=200, url='https://api.example.test/projects', headers={}, body=b'[{\"id\":\"project-123\"}]'); print(response.json_value()[0]['id'])"
```

Expected output:

```text
project-123
```

Then ensure object-only parsing still protects its contract:

```bash
python -c "from craftapi.transport import HttpResponse; response = HttpResponse(status_code=200, url='https://api.example.test/projects', headers={}, body=b'[]'); response.json_object()"
```

Expected result:

```text
craftapi.exceptions.CraftApiValidationError: API response JSON root must be an object.
```

---

# Step 2: Add a Paginated Project-Page Model

## The Target

We are extending:

```text
src/craftapi/models.py
```

We will add `ProjectPage`, an immutable model that represents one page of project results.

## The Concept

A large API response should not necessarily return every project in one request.

Instead, the server may return pages:

```text
GET /projects?page=1&page_size=2
GET /projects?page=2&page_size=2
GET /projects?page=3&page_size=2
```

A typical page response might be:

```json
{
  "items": [
    {
      "id": "project-001",
      "name": "Website Redesign",
      "status": "active",
      "created_at": "2026-07-24T10:30:00Z"
    }
  ],
  "next_page": 2
}
```

`ProjectPage` gives this response an explicit Python shape:

```python
ProjectPage(
    items=(Project(...),),
    next_page=2,
)
```

The `items` field is a tuple rather than a list. This communicates that a parsed API response is a stable snapshot, not a list that callers should mutate.

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
            raise CraftApiValidationError(
                'API field "items" must be a list.'
            )

        projects: list[Project] = []

        for item_index, raw_item in enumerate(raw_items):
            if not isinstance(raw_item, dict):
                raise CraftApiValidationError(
                    f"API field \"items\" entry {item_index} must be an object."
                )

            projects.append(Project.from_api_payload(raw_item))

        raw_next_page = payload.get("next_page")

        if raw_next_page is None:
            next_page = None
        elif isinstance(raw_next_page, int) and raw_next_page >= 1:
            next_page = raw_next_page
        else:
            raise CraftApiValidationError(
                'API field "next_page" must be a positive integer or null.'
            )

        return cls(
            items=tuple(projects),
            next_page=next_page,
        )
```

## The Verification

Run:

```bash
python -c "from craftapi.models import ProjectPage; page = ProjectPage.from_api_payload({'items': [{'id': 'project-001', 'name': 'Website Redesign', 'status': 'active', 'created_at': '2026-07-24T10:30:00Z'}], 'next_page': None}); print(page.items[0].name); print(page.next_page)"
```

Expected output:

```text
Website Redesign
None
```

---

# Step 3: Build the Client’s Request and URL Helpers

## The Target

We are creating:

```text
src/craftapi/client.py
```

The first version will include:

- `CraftApiClient`
- Context-manager support
- Request-header construction
- URL construction
- A protected `_request_json_object()` helper

## The Concept

The public client should have one place where it performs standard HTTP setup.

Every request needs consistent headers:

```text
Authorization: Bearer <token>
Accept: application/json
User-Agent: craftapi/0.1.0
```

Requests that send JSON also need:

```text
Content-Type: application/json
```

If each public method builds headers separately, behavior can drift over time. One method may forget authorization, another may use a different user agent, and another may accidentally expose a token in logs.

Instead, use one central helper.

The same principle applies to URL construction. A project identifier may contain spaces, slashes, or other reserved URL characters. We must encode it safely.

## The Implementation

Create the following file.

### `src/craftapi/client.py`

```python
"""High-level public API client for Craft project-management resources."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from typing import Any
from urllib.parse import quote, urlencode

from craftapi.config import CraftApiConfig
from craftapi.exceptions import CraftApiValidationError
from craftapi.transport import (
    HttpResponse,
    Transport,
    UrllibTransport,
    encode_json_body,
)


class CraftApiClient:
    """A typed client for interacting with Craft project resources."""

    def __init__(
        self,
        *,
        config: CraftApiConfig,
        transport: Transport | None = None,
    ) -> None:
        """Create a client with validated configuration and optional transport.

        Args:
            config: Validated endpoint, token, and timeout configuration.
            transport: Optional custom transport. When omitted, the standard
                library UrllibTransport implementation is used.
        """
        self._config = config
        self._transport = transport if transport is not None else UrllibTransport()
        self._is_closed = False

    @classmethod
    def from_environment(
        cls,
        *,
        environment: dict[str, str] | None = None,
        transport: Transport | None = None,
    ) -> CraftApiClient:
        """Create a client from CRAFTAPI_* environment variables."""
        return cls(
            config=CraftApiConfig.from_environment(environment=environment),
            transport=transport,
        )

    def __enter__(self) -> CraftApiClient:
        """Return this active client for use inside a with block."""
        self._ensure_open()
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        """Close the transport without suppressing caller exceptions."""
        self.close()
        return False

    def close(self) -> None:
        """Close the underlying transport exactly once."""
        if self._is_closed:
            return

        self._transport.close()
        self._is_closed = True

    def _ensure_open(self) -> None:
        """Raise a clear error when callers use a closed client."""
        if self._is_closed:
            raise RuntimeError(
                "CraftApiClient is closed and cannot send additional requests."
            )

    def _build_url(
        self,
        path: str,
        *,
        query_parameters: Mapping[str, str | int] | None = None,
    ) -> str:
        """Build one URL below the configured API base URL.

        Args:
            path: API-relative path beginning with a slash.
            query_parameters: Optional query-string values.

        Raises:
            ValueError: If path does not begin with a slash.
        """
        if not path.startswith("/"):
            raise ValueError("API path must begin with '/'.")

        url = f"{self._config.base_url}{path}"

        if query_parameters:
            encoded_query = urlencode(query_parameters)
            url = f"{url}?{encoded_query}"

        return url

    def _request_headers(
        self,
        *,
        includes_json_body: bool,
    ) -> dict[str, str]:
        """Create standard headers without exposing the token elsewhere."""
        headers = {
            "Accept": "application/json",
            "Authorization": f"Bearer {self._config.api_token}",
            "User-Agent": "craftapi/0.1.0",
        }

        if includes_json_body:
            headers["Content-Type"] = "application/json"

        return headers

    def _request_json_object(
        self,
        *,
        method: str,
        path: str,
        query_parameters: Mapping[str, str | int] | None = None,
        json_payload: Mapping[str, object] | None = None,
    ) -> Mapping[str, Any]:
        """Send one request expected to return a JSON object.

        Raises:
            RuntimeError: If the client was closed.
            CraftApiValidationError: If response JSON is malformed or not an
                object. Transport-related exceptions come from the transport.
        """
        self._ensure_open()

        includes_json_body = json_payload is not None
        body = encode_json_body(json_payload) if json_payload is not None else None
        url = self._build_url(path, query_parameters=query_parameters)

        response: HttpResponse = self._transport.request(
            method=method,
            url=url,
            headers=self._request_headers(includes_json_body=includes_json_body),
            body=body,
            timeout_seconds=self._config.timeout_seconds,
        )

        return response.json_object()

    def _require_non_blank_identifier(
        self,
        identifier: str,
        *,
        label: str,
    ) -> str:
        """Validate an identifier provided by a public client method."""
        if not isinstance(identifier, str):
            raise TypeError(f"{label} must be a string.")

        cleaned_identifier = identifier.strip()

        if not cleaned_identifier:
            raise ValueError(f"{label} cannot be blank.")

        return cleaned_identifier
```

## The Verification

Run a basic client construction check:

```bash
python -c "from craftapi.client import CraftApiClient; from craftapi.config import CraftApiConfig; client = CraftApiClient(config=CraftApiConfig(base_url='https://api.example.test', api_token='demo-token')); print(client._build_url('/projects', query_parameters={'page': 2, 'page_size': 25})); client.close()"
```

Expected output:

```text
https://api.example.test/projects?page=2&page_size=25
```

The command accesses `_build_url()` only for this learning verification. External application code should use public methods such as `get_project()` and `iter_projects()`.

---

# Step 4: Add `get_project()` and `create_project()`

## The Target

We are extending:

```text
src/craftapi/client.py
```

We will add the first public API operations:

- `get_project(project_id)`
- `create_project(name, description=None)`

## The Concept

Public methods should use domain names, not HTTP implementation terms.

Good public API:

```python
client.get_project("project-123")
client.create_project(name="Website Redesign")
```

Less helpful public API:

```python
client.send_request("GET", "/projects/project-123")
```

The latter pushes HTTP complexity back onto every caller. The client should encapsulate it.

We also validate user-provided input before sending it over the network. This prevents requests such as:

```text
GET /projects/
```

when a project ID is blank.

## The Implementation

Replace the complete file.

### `src/craftapi/client.py`

```python
"""High-level public API client for Craft project-management resources."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from typing import Any
from urllib.parse import quote, urlencode

from craftapi.config import CraftApiConfig
from craftapi.models import Project
from craftapi.transport import (
    HttpResponse,
    Transport,
    UrllibTransport,
    encode_json_body,
)


class CraftApiClient:
    """A typed client for interacting with Craft project resources."""

    def __init__(
        self,
        *,
        config: CraftApiConfig,
        transport: Transport | None = None,
    ) -> None:
        """Create a client with validated configuration and optional transport."""
        self._config = config
        self._transport = transport if transport is not None else UrllibTransport()
        self._is_closed = False

    @classmethod
    def from_environment(
        cls,
        *,
        environment: dict[str, str] | None = None,
        transport: Transport | None = None,
    ) -> CraftApiClient:
        """Create a client from CRAFTAPI_* environment variables."""
        return cls(
            config=CraftApiConfig.from_environment(environment=environment),
            transport=transport,
        )

    def __enter__(self) -> CraftApiClient:
        """Return this active client for use inside a with block."""
        self._ensure_open()
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        """Close the transport without suppressing caller exceptions."""
        self.close()
        return False

    def close(self) -> None:
        """Close the underlying transport exactly once."""
        if self._is_closed:
            return

        self._transport.close()
        self._is_closed = True

    def _ensure_open(self) -> None:
        """Raise a clear error when callers use a closed client."""
        if self._is_closed:
            raise RuntimeError(
                "CraftApiClient is closed and cannot send additional requests."
            )

    def _build_url(
        self,
        path: str,
        *,
        query_parameters: Mapping[str, str | int] | None = None,
    ) -> str:
        """Build one URL below the configured API base URL."""
        if not path.startswith("/"):
            raise ValueError("API path must begin with '/'.")

        url = f"{self._config.base_url}{path}"

        if query_parameters:
            url = f"{url}?{urlencode(query_parameters)}"

        return url

    def _request_headers(
        self,
        *,
        includes_json_body: bool,
    ) -> dict[str, str]:
        """Create standard headers without exposing the token elsewhere."""
        headers = {
            "Accept": "application/json",
            "Authorization": f"Bearer {self._config.api_token}",
            "User-Agent": "craftapi/0.1.0",
        }

        if includes_json_body:
            headers["Content-Type"] = "application/json"

        return headers

    def _request_json_object(
        self,
        *,
        method: str,
        path: str,
        query_parameters: Mapping[str, str | int] | None = None,
        json_payload: Mapping[str, object] | None = None,
    ) -> Mapping[str, Any]:
        """Send one request expected to return a JSON object."""
        self._ensure_open()

        includes_json_body = json_payload is not None
        body = encode_json_body(json_payload) if json_payload is not None else None
        url = self._build_url(path, query_parameters=query_parameters)

        response: HttpResponse = self._transport.request(
            method=method,
            url=url,
            headers=self._request_headers(includes_json_body=includes_json_body),
            body=body,
            timeout_seconds=self._config.timeout_seconds,
        )

        return response.json_object()

    @staticmethod
    def _require_non_blank_string(value: str, *, label: str) -> str:
        """Validate and normalize a required user-provided string."""
        if not isinstance(value, str):
            raise TypeError(f"{label} must be a string.")

        cleaned_value = value.strip()

        if not cleaned_value:
            raise ValueError(f"{label} cannot be blank.")

        return cleaned_value

    def get_project(self, project_id: str) -> Project:
        """Fetch one project by its stable identifier.

        Raises:
            ValueError: If project_id is blank.
            CraftApiNotFoundError: If the remote API returns HTTP 404.
            CraftApiValidationError: If response data is malformed.
        """
        cleaned_project_id = self._require_non_blank_string(
            project_id,
            label="Project ID",
        )

        # quote(..., safe="") ensures even slash characters become data rather
        # than accidentally changing the URL path structure.
        encoded_project_id = quote(cleaned_project_id, safe="")

        payload = self._request_json_object(
            method="GET",
            path=f"/projects/{encoded_project_id}",
        )

        return Project.from_api_payload(payload)

    def create_project(
        self,
        *,
        name: str,
        description: str | None = None,
    ) -> Project:
        """Create one remote project and return its validated model.

        Raises:
            ValueError: If name or supplied description is blank.
            TypeError: If name or description has the wrong runtime type.
            CraftApiResponseError: If the remote API rejects creation.
            CraftApiValidationError: If the response is malformed.
        """
        cleaned_name = self._require_non_blank_string(name, label="Project name")

        payload: dict[str, object] = {"name": cleaned_name}

        if description is not None:
            cleaned_description = self._require_non_blank_string(
                description,
                label="Project description",
            )
            payload["description"] = cleaned_description

        response_payload = self._request_json_object(
            method="POST",
            path="/projects",
            json_payload=payload,
        )

        return Project.from_api_payload(response_payload)
```

## The Verification

The client now requires a fake transport for local verification because we do not have a real Craft API server.

Create this example.

### `examples/part_11_client_preview.py`

```python
"""Preview CraftApiClient behavior using a local fake transport."""

from __future__ import annotations

from collections.abc import Mapping

from craftapi import CraftApiClient, CraftApiConfig, HttpResponse


class PreviewTransport:
    """Return controlled responses without making network requests."""

    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        """Return one response matching the requested endpoint."""
        if method == "GET" and url.endswith("/projects/project-123"):
            return HttpResponse(
                status_code=200,
                url=url,
                headers={"content-type": "application/json"},
                body=(
                    b'{"id":"project-123","name":"Website Redesign",'
                    b'"status":"active",'
                    b'"created_at":"2026-07-24T10:30:00Z"}'
                ),
            )

        if method == "POST" and url.endswith("/projects"):
            return HttpResponse(
                status_code=201,
                url=url,
                headers={"content-type": "application/json"},
                body=(
                    b'{"id":"project-124","name":"New Project",'
                    b'"status":"active",'
                    b'"created_at":"2026-07-24T11:00:00Z"}'
                ),
            )

        raise AssertionError(f"Unexpected request: {method} {url}")

    def close(self) -> None:
        """Satisfy the transport contract."""
        return None


def main() -> None:
    """Call client methods without a real server."""
    client = CraftApiClient(
        config=CraftApiConfig(
            base_url="https://api.example.test",
            api_token="example-token",
        ),
        transport=PreviewTransport(),
    )

    project = client.get_project("project-123")
    print(f"Fetched: {project.id} — {project.name}")

    created_project = client.create_project(
        name="New Project",
        description="Created by the preview program.",
    )
    print(f"Created: {created_project.id} — {created_project.name}")

    client.close()


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_11_client_preview.py
```

Expected output:

```text
Fetched: project-123 — Website Redesign
Created: project-124 — New Project
```

---

# Step 5: Add Lazy Pagination with `iter_projects()`

## The Target

We are extending:

```text
src/craftapi/client.py
```

We will add:

```python
client.iter_projects(page_size=100)
```

This method returns an iterator that fetches pages only as the caller consumes results.

## The Concept

A client may have thousands of projects.

This is inefficient:

```python
all_projects = list(client.iter_projects())
```

when the caller only needs the first five.

A generator allows lazy behavior:

```python
for project in client.iter_projects(page_size=50):
    process(project)
```

The client fetches page one. When the loop needs more items, it fetches page two. It continues only as needed.

The server contract for this tutorial is:

```text
GET /projects?page=<positive integer>&page_size=<1–100>
```

Response body:

```json
{
  "items": [...],
  "next_page": 2
}
```

The final page returns:

```json
{
  "items": [...],
  "next_page": null
}
```

We will also detect an unsafe server response that repeats a page number. Without that protection, a malformed API could make our iterator loop forever.

## The Implementation

Replace the complete file.

### `src/craftapi/client.py`

```python
"""High-level public API client for Craft project-management resources."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from typing import Any
from urllib.parse import quote, urlencode

from craftapi.config import CraftApiConfig
from craftapi.exceptions import CraftApiValidationError
from craftapi.models import Project, ProjectPage
from craftapi.transport import (
    HttpResponse,
    Transport,
    UrllibTransport,
    encode_json_body,
)

MINIMUM_PAGE_SIZE = 1
MAXIMUM_PAGE_SIZE = 100


class CraftApiClient:
    """A typed client for interacting with Craft project resources."""

    def __init__(
        self,
        *,
        config: CraftApiConfig,
        transport: Transport | None = None,
    ) -> None:
        """Create a client with validated configuration and optional transport."""
        self._config = config
        self._transport = transport if transport is not None else UrllibTransport()
        self._is_closed = False

    @classmethod
    def from_environment(
        cls,
        *,
        environment: dict[str, str] | None = None,
        transport: Transport | None = None,
    ) -> CraftApiClient:
        """Create a client from CRAFTAPI_* environment variables."""
        return cls(
            config=CraftApiConfig.from_environment(environment=environment),
            transport=transport,
        )

    def __enter__(self) -> CraftApiClient:
        """Return this active client for use inside a with block."""
        self._ensure_open()
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception_value: BaseException | None,
        traceback: object | None,
    ) -> bool:
        """Close the transport without suppressing caller exceptions."""
        self.close()
        return False

    def close(self) -> None:
        """Close the underlying transport exactly once."""
        if self._is_closed:
            return

        self._transport.close()
        self._is_closed = True

    def _ensure_open(self) -> None:
        """Raise a clear error when callers use a closed client."""
        if self._is_closed:
            raise RuntimeError(
                "CraftApiClient is closed and cannot send additional requests."
            )

    def _build_url(
        self,
        path: str,
        *,
        query_parameters: Mapping[str, str | int] | None = None,
    ) -> str:
        """Build one URL below the configured API base URL."""
        if not path.startswith("/"):
            raise ValueError("API path must begin with '/'.")

        url = f"{self._config.base_url}{path}"

        if query_parameters:
            url = f"{url}?{urlencode(query_parameters)}"

        return url

    def _request_headers(
        self,
        *,
        includes_json_body: bool,
    ) -> dict[str, str]:
        """Create standard headers without exposing the token elsewhere."""
        headers = {
            "Accept": "application/json",
            "Authorization": f"Bearer {self._config.api_token}",
            "User-Agent": "craftapi/0.1.0",
        }

        if includes_json_body:
            headers["Content-Type"] = "application/json"

        return headers

    def _request_json_object(
        self,
        *,
        method: str,
        path: str,
        query_parameters: Mapping[str, str | int] | None = None,
        json_payload: Mapping[str, object] | None = None,
    ) -> Mapping[str, Any]:
        """Send one request expected to return a JSON object."""
        self._ensure_open()

        includes_json_body = json_payload is not None
        body = encode_json_body(json_payload) if json_payload is not None else None
        url = self._build_url(path, query_parameters=query_parameters)

        response: HttpResponse = self._transport.request(
            method=method,
            url=url,
            headers=self._request_headers(includes_json_body=includes_json_body),
            body=body,
            timeout_seconds=self._config.timeout_seconds,
        )

        return response.json_object()

    @staticmethod
    def _require_non_blank_string(value: str, *, label: str) -> str:
        """Validate and normalize a required user-provided string."""
        if not isinstance(value, str):
            raise TypeError(f"{label} must be a string.")

        cleaned_value = value.strip()

        if not cleaned_value:
            raise ValueError(f"{label} cannot be blank.")

        return cleaned_value

    @staticmethod
    def _validate_page_size(page_size: int) -> int:
        """Validate one requested page size."""
        if isinstance(page_size, bool) or not isinstance(page_size, int):
            raise TypeError("Page size must be an integer.")

        if not MINIMUM_PAGE_SIZE <= page_size <= MAXIMUM_PAGE_SIZE:
            raise ValueError(
                f"Page size must be between {MINIMUM_PAGE_SIZE} and "
                f"{MAXIMUM_PAGE_SIZE}."
            )

        return page_size

    def get_project(self, project_id: str) -> Project:
        """Fetch one project by its stable identifier."""
        cleaned_project_id = self._require_non_blank_string(
            project_id,
            label="Project ID",
        )
        encoded_project_id = quote(cleaned_project_id, safe="")

        payload = self._request_json_object(
            method="GET",
            path=f"/projects/{encoded_project_id}",
        )

        return Project.from_api_payload(payload)

    def create_project(
        self,
        *,
        name: str,
        description: str | None = None,
    ) -> Project:
        """Create one remote project and return its validated model."""
        cleaned_name = self._require_non_blank_string(name, label="Project name")

        payload: dict[str, object] = {"name": cleaned_name}

        if description is not None:
            payload["description"] = self._require_non_blank_string(
                description,
                label="Project description",
            )

        response_payload = self._request_json_object(
            method="POST",
            path="/projects",
            json_payload=payload,
        )

        return Project.from_api_payload(response_payload)

    def iter_projects(self, *, page_size: int = 100) -> Iterator[Project]:
        """Yield projects lazily across every API result page.

        Raises:
            TypeError: If page_size is not an integer.
            ValueError: If page_size is outside the supported range.
            CraftApiValidationError: If the API sends an invalid page response
                or a repeated page number that could cause an infinite loop.
        """
        validated_page_size = self._validate_page_size(page_size)
        page_number = 1
        visited_page_numbers: set[int] = set()

        while True:
            if page_number in visited_page_numbers:
                raise CraftApiValidationError(
                    "API pagination repeated a page number."
                )

            visited_page_numbers.add(page_number)

            payload = self._request_json_object(
                method="GET",
                path="/projects",
                query_parameters={
                    "page": page_number,
                    "page_size": validated_page_size,
                },
            )

            page = ProjectPage.from_api_payload(payload)

            yield from page.items

            if page.next_page is None:
                return

            page_number = page.next_page
```

## The Verification

Create a pagination example.

### `examples/part_11_pagination_preview.py`

```python
"""Demonstrate lazy Craft API project pagination with a fake transport."""

from __future__ import annotations

from collections.abc import Mapping

from craftapi import CraftApiClient, CraftApiConfig, HttpResponse


class PaginationPreviewTransport:
    """Serve two deterministic API pages without network access."""

    def __init__(self) -> None:
        """Track each URL requested by the client."""
        self.requested_urls: list[str] = []

    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        """Return a response based on the requested page query string."""
        self.requested_urls.append(url)

        if url.endswith("/projects?page=1&page_size=2"):
            body = (
                b'{"items":['
                b'{"id":"project-001","name":"One","status":"active",'
                b'"created_at":"2026-07-24T10:00:00Z"},'
                b'{"id":"project-002","name":"Two","status":"active",'
                b'"created_at":"2026-07-24T10:01:00Z"}'
                b'],"next_page":2}'
            )
        elif url.endswith("/projects?page=2&page_size=2"):
            body = (
                b'{"items":['
                b'{"id":"project-003","name":"Three","status":"archived",'
                b'"created_at":"2026-07-24T10:02:00Z"}'
                b'],"next_page":null}'
            )
        else:
            raise AssertionError(f"Unexpected request URL: {url}")

        return HttpResponse(
            status_code=200,
            url=url,
            headers={"content-type": "application/json"},
            body=body,
        )

    def close(self) -> None:
        """Satisfy the transport contract."""
        return None


def main() -> None:
    """Iterate over a paginated response sequence."""
    transport = PaginationPreviewTransport()
    client = CraftApiClient(
        config=CraftApiConfig(
            base_url="https://api.example.test",
            api_token="example-token",
        ),
        transport=transport,
    )

    for project in client.iter_projects(page_size=2):
        print(f"{project.id}: {project.name}")

    print("\nURLs requested:")
    for requested_url in transport.requested_urls:
        print(requested_url)

    client.close()


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python examples/part_11_pagination_preview.py
```

Expected output:

```text
project-001: One
project-002: Two
project-003: Three

URLs requested:
https://api.example.test/projects?page=1&page_size=2
https://api.example.test/projects?page=2&page_size=2
```

---

# Step 6: Export Client and Page Types

## The Target

We are updating:

```text
src/craftapi/__init__.py
```

## The Concept

The package’s public interface should expose the types users need without requiring knowledge of module internals.

After this step, callers can write:

```python
from craftapi import CraftApiClient, CraftApiConfig, Project, ProjectPage
```

## The Implementation

Replace the complete file.

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
    "Transport",
    "UrllibTransport",
    "encode_json_body",
]
```

## The Verification

Run:

```bash
python -c "from craftapi import CraftApiClient, Project, ProjectPage; print(CraftApiClient.__name__); print(Project.__name__); print(ProjectPage.__name__)"
```

Expected output:

```text
CraftApiClient
Project
ProjectPage
```

---

# Step 7: Add Client Tests with a Fake Transport

## The Target

We are completing:

```text
tests/test_models.py
tests/test_client.py
```

The tests will verify:

- Project-page parsing
- Correct request URL construction
- Authorization and JSON headers
- JSON request body construction
- Project ID URL encoding
- Lazy pagination
- Pagination-loop protection
- Context-manager cleanup
- Closed-client protection

## The Concept

The client should be tested without contacting an external service.

A **fake transport** is a small in-memory implementation of the same `Transport` contract used by production code. It returns predetermined responses and records each request it receives.

Think of it as a flight simulator:

- The pilot—the `CraftApiClient`—performs real actions.
- The simulator—the fake transport—provides predictable conditions.
- No real airplane—or remote API—is required.

This makes tests fast, deterministic, and safe.

## The Implementation

Replace the complete contents of `tests/test_models.py`.

### `tests/test_models.py`

```python
"""Tests for validated Craft API resource models."""

from __future__ import annotations

from datetime import timezone
from typing import Any

import pytest

from craftapi import CraftApiValidationError, Project, ProjectPage


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


def test_project_page_is_created_from_valid_payload(
    valid_project_payload: dict[str, Any],
) -> None:
    """A page should parse project items and a following page number."""
    page = ProjectPage.from_api_payload(
        {
            "items": [valid_project_payload],
            "next_page": 2,
        }
    )

    assert len(page.items) == 1
    assert page.items[0].id == "project-123"
    assert page.next_page == 2


@pytest.mark.parametrize(
    "next_page",
    [
        0,
        -1,
        "2",
        2.5,
        True,
    ],
)
def test_project_page_rejects_invalid_next_page_values(
    valid_project_payload: dict[str, Any],
    next_page: object,
) -> None:
    """next_page must be a positive integer or null."""
    with pytest.raises(
        CraftApiValidationError,
        match='API field "next_page" must be a positive integer or null',
    ):
        ProjectPage.from_api_payload(
            {
                "items": [valid_project_payload],
                "next_page": next_page,
            }
        )


def test_project_page_rejects_non_object_item() -> None:
    """Every item in a project page must be a JSON object."""
    with pytest.raises(
        CraftApiValidationError,
        match='API field "items" entry 0 must be an object',
    ):
        ProjectPage.from_api_payload(
            {
                "items": ["not a project object"],
                "next_page": None,
            }
        )
```

Now create the client test module.

### `tests/test_client.py`

```python
"""Tests for CraftApiClient using an in-memory fake transport."""

from __future__ import annotations

import json
from collections.abc import Mapping
from dataclasses import dataclass
from typing import Any

import pytest

from craftapi import (
    CraftApiClient,
    CraftApiConfig,
    CraftApiValidationError,
    HttpResponse,
)


@dataclass(frozen=True, slots=True)
class RecordedRequest:
    """Capture one request received by FakeTransport."""

    method: str
    url: str
    headers: Mapping[str, str]
    body: bytes | None
    timeout_seconds: float


class FakeTransport:
    """A deterministic Transport implementation for client tests."""

    def __init__(self, responses: list[HttpResponse]) -> None:
        """Create a fake transport with responses returned in request order."""
        self._responses = list(responses)
        self.requests: list[RecordedRequest] = []
        self.close_call_count = 0

    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        """Record one request and return the next configured response."""
        self.requests.append(
            RecordedRequest(
                method=method,
                url=url,
                headers=dict(headers or {}),
                body=body,
                timeout_seconds=timeout_seconds,
            )
        )

        if not self._responses:
            raise AssertionError(
                f"Unexpected request with no configured response: {method} {url}"
            )

        return self._responses.pop(0)

    def close(self) -> None:
        """Record transport cleanup."""
        self.close_call_count += 1


def make_response(
    payload: Mapping[str, object],
    *,
    status_code: int = 200,
    url: str = "https://api.example.test/response",
) -> HttpResponse:
    """Create a JSON HttpResponse for use in a test."""
    return HttpResponse(
        status_code=status_code,
        url=url,
        headers={"content-type": "application/json"},
        body=json.dumps(payload).encode("utf-8"),
    )


@pytest.fixture
def config() -> CraftApiConfig:
    """Return valid, deterministic client configuration."""
    return CraftApiConfig(
        base_url="https://api.example.test",
        api_token="test-token",
        timeout_seconds=7.5,
    )


@pytest.fixture
def project_payload() -> dict[str, object]:
    """Return a valid remote project response payload."""
    return {
        "id": "project-123",
        "name": "Website Redesign",
        "status": "active",
        "created_at": "2026-07-24T10:30:00Z",
        "description": "Modernize the public website.",
    }


def test_get_project_builds_authorized_encoded_request(
    config: CraftApiConfig,
    project_payload: dict[str, object],
) -> None:
    """Project lookup should URL-encode identifiers and send standard headers."""
    transport = FakeTransport([make_response(project_payload)])
    client = CraftApiClient(config=config, transport=transport)

    project = client.get_project(" project / 123 ")

    assert project.id == "project-123"
    assert len(transport.requests) == 1

    request = transport.requests[0]

    assert request.method == "GET"
    assert request.url == "https://api.example.test/projects/project%20%2F%20123"
    assert request.headers == {
        "Accept": "application/json",
        "Authorization": "Bearer test-token",
        "User-Agent": "craftapi/0.1.0",
    }
    assert request.body is None
    assert request.timeout_seconds == 7.5


def test_create_project_encodes_json_body_and_content_type(
    config: CraftApiConfig,
    project_payload: dict[str, object],
) -> None:
    """Project creation should send a JSON request body and parse the response."""
    transport = FakeTransport(
        [
            make_response(
                project_payload,
                status_code=201,
                url="https://api.example.test/projects",
            )
        ]
    )
    client = CraftApiClient(config=config, transport=transport)

    project = client.create_project(
        name=" Website Redesign ",
        description=" Modernize the public website. ",
    )

    assert project.name == "Website Redesign"

    request = transport.requests[0]

    assert request.method == "POST"
    assert request.url == "https://api.example.test/projects"
    assert request.headers["Content-Type"] == "application/json"
    assert request.headers["Authorization"] == "Bearer test-token"
    assert request.body is not None
    assert json.loads(request.body.decode("utf-8")) == {
        "name": "Website Redesign",
        "description": "Modernize the public website.",
    }


@pytest.mark.parametrize(
    ("method_name", "arguments", "message"),
    [
        ("get_project", ("   ",), "Project ID cannot be blank"),
        ("create_project", (), "Project name cannot be blank"),
    ],
)
def test_client_rejects_blank_public_input(
    config: CraftApiConfig,
    method_name: str,
    arguments: tuple[str, ...],
    message: str,
) -> None:
    """Client validation should reject bad input before transport use."""
    transport = FakeTransport([])
    client = CraftApiClient(config=config, transport=transport)

    if method_name == "get_project":
        with pytest.raises(ValueError, match=message):
            client.get_project(*arguments)
    else:
        with pytest.raises(ValueError, match=message):
            client.create_project(name="   ")

    assert transport.requests == []


def test_iter_projects_is_lazy_and_fetches_subsequent_pages(
    config: CraftApiConfig,
) -> None:
    """No request occurs until iteration begins; pages are fetched as needed."""
    first_page = make_response(
        {
            "items": [
                {
                    "id": "project-001",
                    "name": "One",
                    "status": "active",
                    "created_at": "2026-07-24T10:00:00Z",
                }
            ],
            "next_page": 2,
        }
    )
    second_page = make_response(
        {
            "items": [
                {
                    "id": "project-002",
                    "name": "Two",
                    "status": "archived",
                    "created_at": "2026-07-24T10:01:00Z",
                }
            ],
            "next_page": None,
        }
    )

    transport = FakeTransport([first_page, second_page])
    client = CraftApiClient(config=config, transport=transport)

    projects = client.iter_projects(page_size=25)

    assert transport.requests == []

    first_project = next(projects)

    assert first_project.id == "project-001"
    assert len(transport.requests) == 1
    assert (
        transport.requests[0].url
        == "https://api.example.test/projects?page=1&page_size=25"
    )

    remaining_projects = list(projects)

    assert [project.id for project in remaining_projects] == ["project-002"]
    assert len(transport.requests) == 2
    assert (
        transport.requests[1].url
        == "https://api.example.test/projects?page=2&page_size=25"
    )


@pytest.mark.parametrize(
    "page_size",
    [
        0,
        101,
        -1,
    ],
)
def test_iter_projects_rejects_invalid_page_size_range(
    config: CraftApiConfig,
    page_size: int,
) -> None:
    """Page size must remain inside the documented server-compatible range."""
    client = CraftApiClient(config=config, transport=FakeTransport([]))

    with pytest.raises(ValueError, match="Page size must be between 1 and 100"):
        next(client.iter_projects(page_size=page_size))


def test_iter_projects_rejects_boolean_page_size(
    config: CraftApiConfig,
) -> None:
    """bool is an int subclass, so it requires an explicit rejection rule."""
    client = CraftApiClient(config=config, transport=FakeTransport([]))

    with pytest.raises(TypeError, match="Page size must be an integer"):
        next(client.iter_projects(page_size=True))  # type: ignore[arg-type]


def test_iter_projects_detects_repeated_page_number(
    config: CraftApiConfig,
) -> None:
    """A malformed repeated next_page value must not create an infinite loop."""
    repeating_page = make_response(
        {
            "items": [],
            "next_page": 1,
        }
    )
    transport = FakeTransport([repeating_page])
    client = CraftApiClient(config=config, transport=transport)

    with pytest.raises(
        CraftApiValidationError,
        match="pagination repeated a page number",
    ):
        list(client.iter_projects(page_size=10))

    # The repeated page is detected before a second request is sent.
    assert len(transport.requests) == 1


def test_context_manager_closes_transport_once(
    config: CraftApiConfig,
) -> None:
    """Leaving a with block should close the injected transport."""
    transport = FakeTransport([])

    with CraftApiClient(config=config, transport=transport) as client:
        assert client is not None

    assert transport.close_call_count == 1


def test_closed_client_rejects_new_requests(
    config: CraftApiConfig,
) -> None:
    """A closed client should fail clearly instead of using its transport."""
    transport = FakeTransport([])
    client = CraftApiClient(config=config, transport=transport)

    client.close()
    client.close()

    assert transport.close_call_count == 1

    with pytest.raises(RuntimeError, match="CraftApiClient is closed"):
        client.get_project("project-123")
```

## The Verification

Run the client and model tests:

```bash
python -m pytest tests/test_client.py tests/test_models.py
```

Expected output includes:

```text
17 passed
```

Then run the complete test suite:

```bash
python -m pytest
```

Finally, run static checks:

```bash
python -m mypy src tests
```

Expected results:

```text
... passed
Success: no issues found in ... source files
```

---

# Step 8: Add a Realistic Environment-Based Client Example

## The Target

We are creating:

```text
examples/part_11_environment_client.py
```

This example shows the intended production-style construction flow without exposing secrets in source code.

## The Concept

API tokens should not be hard-coded:

```python
# Never do this.
api_token = "real-secret-token"
```

Instead, the environment supplies sensitive values at runtime.

A shell environment is like a secure handoff envelope: the operating system provides the configuration to the process, while source control never receives the secret.

## The Implementation

### `examples/part_11_environment_client.py`

```python
"""Show intended production-style CraftApiClient construction."""

from craftapi import (
    CraftApiAuthenticationError,
    CraftApiClient,
    CraftApiNotFoundError,
    CraftApiTransportError,
)


def main() -> None:
    """Read configuration from the environment and request one project."""
    project_id = "project-123"

    try:
        with CraftApiClient.from_environment() as client:
            project = client.get_project(project_id)
    except CraftApiAuthenticationError:
        print("Authentication failed. Check CRAFTAPI_API_TOKEN.")
    except CraftApiNotFoundError:
        print(f'Project "{project_id}" does not exist.')
    except CraftApiTransportError:
        print("The Craft API could not be reached.")
    else:
        print(f"Project: {project.name}")
        print(f"Status: {project.status}")
        print(f"Created: {project.created_at.isoformat()}")


if __name__ == "__main__":
    main()
```

Before running this against a real compatible API, set environment variables.

### macOS or Linux

```bash
export CRAFTAPI_BASE_URL="https://api.example.test"
export CRAFTAPI_API_TOKEN="replace-with-a-real-token"
export CRAFTAPI_TIMEOUT_SECONDS="10"

python examples/part_11_environment_client.py
```

### Windows PowerShell

```powershell
$env:CRAFTAPI_BASE_URL = "https://api.example.test"
$env:CRAFTAPI_API_TOKEN = "replace-with-a-real-token"
$env:CRAFTAPI_TIMEOUT_SECONDS = "10"

python examples\part_11_environment_client.py
```

## The Verification

Do **not** run this example against `https://api.example.test`; it is intentionally a documentation domain, not a real API.

Instead, verify the environment-loading path with this safe command:

```bash
python -c "from craftapi import CraftApiClient, CraftApiConfig, HttpResponse; from collections.abc import Mapping; 
class SafeTransport:
    def request(self, *, method: str, url: str, headers: Mapping[str, str] | None = None, body: bytes | None = None, timeout_seconds: float) -> HttpResponse:
        return HttpResponse(status_code=200, url=url, headers={}, body=b'{\"id\":\"project-123\",\"name\":\"Demo\",\"status\":\"active\",\"created_at\":\"2026-07-24T10:30:00Z\"}')
    def close(self) -> None:
        return None
client = CraftApiClient.from_environment(environment={'CRAFTAPI_BASE_URL':'https://api.example.test','CRAFTAPI_API_TOKEN':'demo-token'}, transport=SafeTransport()); print(client.get_project('project-123').name); client.close()"
```

Expected output:

```text
Demo
```

---

# Part 11 Reference: Client Design and Pagination

## Public Client Methods Should Express Domain Actions

A package user should call:

```python
client.get_project("project-123")
client.create_project(name="Website Redesign")
client.iter_projects()
```

They should not need to manage:

- URL paths
- URL encoding
- Request headers
- JSON serialization
- HTTP status translation
- Pagination loops

That complexity belongs inside the client and transport layers.

---

## Why URL-Encoding Matters

Suppose an identifier is:

```text
project / 123
```

If inserted directly into a URL path:

```text
/projects/project / 123
```

spaces and slashes can change the URL meaning.

This code:

```python
quote(cleaned_project_id, safe="")
```

creates:

```text
project%20%2F%20123
```

The server receives the identifier as data, not as extra path separators.

---

## Why the Client Uses a Context Manager

The preferred usage style is:

```python
with CraftApiClient.from_environment() as client:
    project = client.get_project("project-123")
```

The `with` statement guarantees `close()` is called even when an exception occurs.

The current `UrllibTransport` does not own persistent connections, but the interface is designed for future transports that may own:

- Connection pools
- Socket sessions
- Background workers
- Trace exporters

The cleanup contract is established now rather than bolted on later.

---

## Lazy Pagination

`iter_projects()` is a generator.

This code does **not** fetch data immediately:

```python
projects = client.iter_projects(page_size=25)
```

The first request occurs only when the caller consumes the iterator:

```python
first_project = next(projects)
```

This saves work when callers:

- Need only the first few projects
- Stop after finding a matching project
- Process projects one at a time
- Work with large result sets

---

## Pagination Safety

A malformed API response could return:

```json
{
  "items": [],
  "next_page": 1
}
```

when the client is already processing page `1`.

Without protection, the client would request page `1` forever.

The client tracks visited page numbers:

```python
visited_page_numbers: set[int] = set()
```

and raises `CraftApiValidationError` if the server repeats one.

This is an example of validating not only individual fields, but also the *sequence of states* supplied by an external system.


