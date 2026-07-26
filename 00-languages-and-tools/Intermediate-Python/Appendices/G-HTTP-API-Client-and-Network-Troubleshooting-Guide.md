# Appendix G: HTTP, API Client, and Network Troubleshooting Guide

HTTP clients sit at the boundary between your Python program and systems you do not fully control.

A request can fail because of:

- Invalid configuration
- Missing or expired credentials
- DNS problems
- TLS certificate issues
- Timeouts
- Server errors
- Malformed JSON
- Unexpected API schema changes
- Pagination bugs
- Rate limits

This appendix provides a practical troubleshooting reference for the `craftapi` package and similar Python API clients.

---

# G.1 Troubleshooting Order

When an API request fails, investigate in this order:

```text
1. Confirm local Python environment
2. Confirm package installation
3. Confirm configuration values exist
4. Confirm URL format and HTTPS
5. Confirm token is present without printing it
6. Identify exception category
7. Inspect safe response details
8. Reproduce with a minimal request
9. Check API documentation and server logs
```

Avoid immediately adding retries or broad exception handling. First determine what failed.

---

# G.2 Verify the Python Environment

Confirm the active Python interpreter:

### macOS or Linux

```bash
which python
python --version
```

### Windows PowerShell

```powershell
Get-Command python
python --version
```

The path should point to the project’s virtual environment:

```text
.../craftapi/.venv/...
```

Confirm the package is installed:

```bash
python -m pip show craftapi
```

Confirm imports work:

```bash
python -c "import craftapi; print(craftapi.__file__)"
```

Expected output should point to:

```text
.../craftapi/src/craftapi/__init__.py
```

when installed in editable mode.

---

# G.3 Verify Configuration Without Exposing Secrets

The client requires:

```text
CRAFTAPI_BASE_URL
CRAFTAPI_API_TOKEN
CRAFTAPI_TIMEOUT_SECONDS
```

Do **not** print the API token.

Safe configuration diagnostic:

```bash
python -c "import os; print('Base URL configured:', bool(os.getenv('CRAFTAPI_BASE_URL'))); print('API token configured:', bool(os.getenv('CRAFTAPI_API_TOKEN'))); print('Timeout:', os.getenv('CRAFTAPI_TIMEOUT_SECONDS', '10.0'))"
```

Expected output:

```text
Base URL configured: True
API token configured: True
Timeout: 10
```

If `Base URL configured` or `API token configured` is `False`, set the variables again.

### macOS or Linux

```bash
export CRAFTAPI_BASE_URL="https://api.example.com"
export CRAFTAPI_API_TOKEN="replace-with-real-token"
export CRAFTAPI_TIMEOUT_SECONDS="10"
```

### Windows PowerShell

```powershell
$env:CRAFTAPI_BASE_URL = "https://api.example.com"
$env:CRAFTAPI_API_TOKEN = "replace-with-real-token"
$env:CRAFTAPI_TIMEOUT_SECONDS = "10"
```

---

# G.4 Exception Map

The `craftapi` package translates low-level failures into domain-specific exceptions.

| Exception | Typical meaning | First action |
|---|---|---|
| `CraftApiConfigurationError` | URL, token, or timeout is invalid | Check environment variables |
| `CraftApiTransportError` | DNS, connection, TLS, or network failure | Check endpoint, network, proxy, DNS |
| `CraftApiAuthenticationError` | HTTP 401 or 403 | Check token, permissions, expiry |
| `CraftApiNotFoundError` | HTTP 404 | Check resource ID and endpoint path |
| `CraftApiServerError` | HTTP 5xx | Retry safe reads; inspect API status |
| `CraftApiResponseError` | Other unsuccessful HTTP response | Inspect status and safe body |
| `CraftApiValidationError` | Invalid JSON or schema mismatch | Compare response against API contract |

Recommended handling structure:

```python
from craftapi import (
    CraftApiAuthenticationError,
    CraftApiClient,
    CraftApiNotFoundError,
    CraftApiResponseError,
    CraftApiServerError,
    CraftApiTransportError,
    CraftApiValidationError,
)


def fetch_project_name(project_id: str) -> str:
    """Fetch a project and translate known API failures for the caller."""
    try:
        with CraftApiClient.from_environment() as client:
            project = client.get_project(project_id)
    except CraftApiAuthenticationError as error:
        raise RuntimeError("Craft API credentials were rejected.") from error
    except CraftApiNotFoundError as error:
        raise RuntimeError(f'Project "{project_id}" was not found.') from error
    except CraftApiTransportError as error:
        raise RuntimeError("The Craft API could not be reached.") from error
    except CraftApiServerError as error:
        raise RuntimeError("The Craft API is temporarily unavailable.") from error
    except CraftApiResponseError as error:
        raise RuntimeError(
            f"Craft API rejected the request with HTTP "
            f"{error.details.status_code}."
        ) from error
    except CraftApiValidationError as error:
        raise RuntimeError(
            "Craft API returned data that does not match the expected schema."
        ) from error

    return project.name
```

---

# G.5 HTTP Status-Code Reference

| Code | Meaning | Typical client action |
|---:|---|---|
| `200 OK` | Successful read/update | Parse response |
| `201 Created` | Resource created | Parse created resource |
| `204 No Content` | Successful operation with no body | Do not call JSON parser |
| `400 Bad Request` | Invalid request shape or parameters | Fix client input |
| `401 Unauthorized` | Missing or invalid authentication | Check token |
| `403 Forbidden` | Token lacks permission | Check scopes/roles |
| `404 Not Found` | Resource/path does not exist | Check ID and endpoint |
| `409 Conflict` | State conflict or duplicate | Refresh state; resolve conflict |
| `422 Unprocessable Content` | Validation failed | Inspect field-level API errors |
| `429 Too Many Requests` | Rate limited | Respect retry guidance/backoff |
| `500 Internal Server Error` | Server fault | Retry safe operations cautiously |
| `502 Bad Gateway` | Gateway/upstream failure | Retry safe operations |
| `503 Service Unavailable` | Temporary overload/maintenance | Retry safe operations |
| `504 Gateway Timeout` | Upstream timeout | Retry safe operations |

---

# G.6 `CraftApiConfigurationError`

Example:

```text
CraftApiConfigurationError: API base URL must use the https scheme.
```

Common causes:

- Using `http://` instead of `https://`
- Missing host name
- Blank token
- Non-numeric timeout
- Zero or negative timeout

Minimal configuration check:

```python
from craftapi import CraftApiConfig

config = CraftApiConfig(
    base_url="https://api.example.com",
    api_token="example-token",
    timeout_seconds=10.0,
)

print(config.base_url)
print(config.timeout_seconds)
```

Do not print:

```python
print(config.api_token)
```

---

# G.7 `CraftApiTransportError`

Example:

```text
CraftApiTransportError: Could not complete HTTP request to https://api.example.com/projects: [Errno ...]
```

This means the request could not be completed at the network layer. The server may not have received it at all.

Common causes:

- Wrong host name
- DNS failure
- No internet connection
- Corporate firewall
- Proxy requirement
- TLS certificate failure
- Connection reset
- Timeout

Inspect the affected URL safely:

```python
from craftapi import CraftApiTransportError

try:
    ...
except CraftApiTransportError as error:
    print(f"Request URL: {error.url}")
    print(f"Message: {error}")
```

Do not assume retrying is always correct. Retry only temporary failures and only idempotent operations by default.

---

# G.8 TLS and HTTPS Failures

Typical symptoms include errors mentioning:

```text
CERTIFICATE_VERIFY_FAILED
SSL
TLS
certificate
```

Possible causes:

- The endpoint uses a self-signed certificate.
- The host name does not match the certificate.
- Your operating system’s CA certificates are outdated.
- A proxy intercepts HTTPS traffic.
- The API endpoint is misconfigured.

Do not “fix” production TLS failures by disabling certificate verification.

Unsafe pattern:

```python
# Do not disable TLS validation for production requests.
ssl._create_unverified_context()
```

Correct options:

1. Use a properly configured HTTPS endpoint.
2. Install the organization’s trusted certificate authority correctly.
3. Use a local development-only transport or test server for local experiments.
4. Contact the API or infrastructure owner.

---

# G.9 `CraftApiAuthenticationError`

This represents HTTP `401` or `403`.

```python
from craftapi import CraftApiAuthenticationError

try:
    ...
except CraftApiAuthenticationError as error:
    print(error.details.status_code)
```

Interpretation:

| Status | Likely cause |
|---:|---|
| `401` | Token missing, malformed, expired, or invalid |
| `403` | Token is valid but lacks required permission |

Checklist:

- Is `CRAFTAPI_API_TOKEN` set?
- Does it contain accidental quotes or whitespace?
- Has it expired or been revoked?
- Does it have access to this environment?
- Does it have required scopes/roles?
- Are you accidentally calling production with a staging token?

Never paste a token into logs, screenshots, tickets, or chat messages.

---

# G.10 `CraftApiNotFoundError`

A `404` may mean more than “the ID is wrong.”

Possible causes:

- Incorrect project ID
- Wrong API environment
- Incorrect base URL version, such as `/v1`
- Resource exists but is hidden from the current token
- Endpoint path differs from the client’s assumed API contract

Safe diagnostics:

```python
from craftapi import CraftApiNotFoundError

try:
    ...
except CraftApiNotFoundError as error:
    print(f"Method: {error.details.method}")
    print(f"URL: {error.details.url}")
    print(f"Status: {error.details.status_code}")
```

The response body may help, but treat it as untrusted external text:

```python
print(error.details.response_body)
```

Do not parse error-message text to control application logic. Prefer status codes and documented API error fields.

---

# G.11 `CraftApiValidationError`

This error means JSON was invalid or did not match the expected model contract.

Examples:

```text
API response body is not valid JSON.
```

```text
API field "created_at" must be an ISO 8601 timestamp.
```

```text
API field "items" must be a list.
```

Common causes:

- Server returned HTML instead of JSON, often due to proxy or error page.
- API contract changed.
- Endpoint returned a different schema.
- A request hit the wrong URL.
- The API omitted a required field.
- The client expects a JSON object but received an array.

Safe response inspection:

```python
from craftapi import CraftApiResponseError, CraftApiValidationError

try:
    ...
except CraftApiValidationError as error:
    print(f"Schema issue: {error}")
except CraftApiResponseError as error:
    print(error.details.response_body)
```

For successful but malformed responses, add temporary safe logging at the transport boundary only if it excludes secrets and personal data.

---

# G.12 Pagination Failures

The client expects pages shaped like:

```json
{
  "items": [
    {
      "id": "project-123",
      "name": "Website Redesign",
      "status": "active",
      "created_at": "2026-07-24T10:30:00Z"
    }
  ],
  "next_page": 2
}
```

Final page:

```json
{
  "items": [],
  "next_page": null
}
```

## Repeated Page Number

The client protects against this unsafe server response:

```json
{
  "items": [],
  "next_page": 1
}
```

when page `1` has already been processed.

Expected failure:

```text
CraftApiValidationError: API pagination repeated a page number.
```

This prevents an infinite request loop.

## Empty Page with a Next Page

This is not always invalid:

```json
{
  "items": [],
  "next_page": 3
}
```

Some APIs may allow it. Whether to reject it depends on the documented API contract.

## Page Size Errors

The tutorial client supports:

```text
1 <= page_size <= 100
```

Valid:

```python
client.iter_projects(page_size=50)
```

Invalid:

```python
client.iter_projects(page_size=0)
client.iter_projects(page_size=101)
client.iter_projects(page_size=True)
```

The explicit boolean rejection matters because:

```python
isinstance(True, int)  # True
```

---

# G.13 Retry Troubleshooting

The default `UrllibTransport()` has no retry policy:

```python
transport = UrllibTransport()
```

To enable retries for idempotent requests:

```python
from craftapi import RetryPolicy, UrllibTransport

transport = UrllibTransport(
    retry_policy=RetryPolicy(
        max_attempts=3,
        initial_delay_seconds=0.25,
        maximum_delay_seconds=2.0,
    )
)
```

The transport retries only idempotent methods:

```text
DELETE
GET
HEAD
OPTIONS
PUT
```

It does not retry `POST` automatically.

## Why Is My `POST` Not Retried?

This is intentional.

A repeated `POST` may create duplicates:

```text
POST /projects
```

A network failure after the server creates a resource can leave the client unsure whether creation succeeded. Retrying blindly can create a second resource.

Safer alternatives:

- Use an API-supported idempotency key.
- Query for the resource after a timeout.
- Design the API to accept a client-generated unique identifier.
- Use a server-side deduplication mechanism.

---

# G.14 Structured Logging

Enable basic logging during local development:

```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)
```

Then run your application.

The transport logs safe success and retry metadata:

```text
Craft API request succeeded: method=GET url=https://api.example.com/projects status_code=200
```

Retry logging includes:

- Method
- URL
- Attempt number
- Delay
- Failure category

It should not include:

- Authorization headers
- Tokens
- Cookies
- Full request bodies
- Passwords
- Sensitive API response fields

## Safe Logger Setup Example

```python
import logging


def configure_logging() -> None:
    """Configure application logging for local development."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
```

Call it only from your application entry point:

```python
if __name__ == "__main__":
    configure_logging()
    main()
```

Do not call `logging.basicConfig()` inside an installable library. Applications—not libraries—should choose logging destinations and formats.

---

# G.15 Minimal Reproduction Script

When debugging a client issue, create a small isolated script.

### `debug_get_project.py`

```python
"""Minimal diagnostic script for one Craft API project request."""

from craftapi import (
    CraftApiAuthenticationError,
    CraftApiClient,
    CraftApiNotFoundError,
    CraftApiResponseError,
    CraftApiTransportError,
    CraftApiValidationError,
)


def main() -> None:
    """Fetch one project and print only safe diagnostic details."""
    project_id = "project-123"

    try:
        with CraftApiClient.from_environment() as client:
            project = client.get_project(project_id)
    except CraftApiAuthenticationError as error:
        print("Authentication or authorization failed.")
        print(f"Status: {error.details.status_code}")
        print(f"URL: {error.details.url}")
    except CraftApiNotFoundError as error:
        print("Project was not found.")
        print(f"URL: {error.details.url}")
    except CraftApiTransportError as error:
        print("Network transport failed.")
        print(f"URL: {error.url}")
        print(f"Reason: {error}")
    except CraftApiResponseError as error:
        print("API returned an unsuccessful response.")
        print(f"Status: {error.details.status_code}")
        print(f"URL: {error.details.url}")
        print(f"Body: {error.details.response_body}")
    except CraftApiValidationError as error:
        print("API returned invalid or unexpected JSON.")
        print(f"Reason: {error}")
    else:
        print("Request succeeded.")
        print(f"Project ID: {project.id}")
        print(f"Project name: {project.name}")


if __name__ == "__main__":
    main()
```

Run it:

```bash
python debug_get_project.py
```

Before sharing output externally, remove:

- Tokens
- Internal host names
- Customer identifiers
- Sensitive response bodies
- Private URLs with query parameters

---

# G.16 API Client Troubleshooting Checklist

## Configuration

- [ ] Virtual environment is active.
- [ ] `craftapi` is installed in the active environment.
- [ ] Base URL is present and uses HTTPS.
- [ ] API token is present but never printed.
- [ ] Timeout is numeric and greater than zero.

## Connectivity

- [ ] Host name is correct.
- [ ] DNS resolves.
- [ ] Network or VPN is available.
- [ ] Proxy configuration is correct.
- [ ] TLS certificate is valid.

## Authentication

- [ ] Token has not expired.
- [ ] Token belongs to the correct environment.
- [ ] Token has required scopes/permissions.
- [ ] Authorization header uses expected scheme.

## API Contract

- [ ] Endpoint path is correct.
- [ ] HTTP method is correct.
- [ ] Request JSON field names are correct.
- [ ] Response JSON matches expected schema.
- [ ] Pagination response includes expected `items` and `next_page` fields.

## Reliability

- [ ] Retries are enabled only for safe operations.
- [ ] Retry delays are bounded.
- [ ] Logs do not contain secrets.
- [ ] Tests use fake transports rather than real network calls.
