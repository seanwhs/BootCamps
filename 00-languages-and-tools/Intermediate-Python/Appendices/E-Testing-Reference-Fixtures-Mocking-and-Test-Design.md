# Appendix E: `pytest` Testing Reference, Fixtures, Mocking, and Test Design

Automated tests are a safety net for change.

They let you improve code without relying entirely on memory or manual clicking. When a test suite is fast and trustworthy, you can refactor with much more confidence.

This appendix is a practical reference for testing Python packages with `pytest`.

It covers:

- Test discovery
- Assertions
- Expected exceptions
- Fixtures
- Parameterization
- Temporary files and directories
- Fakes and mocks
- Test organization
- Common testing mistakes
- Commands for daily development and CI

---

# E.1 Install and Run `pytest`

Install development dependencies from the project root:

```bash
python -m pip install --editable ".[dev]"
```

Run every test:

```bash
python -m pytest
```

Run with detailed test names:

```bash
python -m pytest --verbose
```

Run one file:

```bash
python -m pytest tests/test_client.py
```

Run one test:

```bash
python -m pytest tests/test_client.py::test_get_project_builds_authorized_encoded_request
```

Run tests matching a phrase:

```bash
python -m pytest -k "pagination"
```

Stop at the first failure:

```bash
python -m pytest --maxfail=1
```

Drop into the debugger when a test fails:

```bash
python -m pytest --pdb
```

---

# E.2 Test Discovery

By default, `pytest` discovers files and functions matching common naming conventions.

Typical structure:

```text
project/
├── src/
│   └── package_name/
└── tests/
    ├── test_client.py
    └── test_models.py
```

Test files:

```text
test_*.py
```

Test functions:

```python
def test_something() -> None:
    ...
```

Example:

```python
def test_project_name_is_preserved() -> None:
    project = Project(
        id="project-123",
        name="Website Redesign",
        status="active",
        created_at=created_at,
    )

    assert project.name == "Website Redesign"
```

See what `pytest` discovers without running tests:

```bash
python -m pytest --collect-only
```

---

# E.3 The Arrange–Act–Assert Pattern

Most unit tests have three clear phases:

1. **Arrange**: create required objects and data.
2. **Act**: perform the behavior under test.
3. **Assert**: verify observable results.

```python
def test_create_project_sends_json_payload() -> None:
    # Arrange
    transport = FakeTransport(
        responses=[
            make_response(
                {
                    "id": "project-123",
                    "name": "Website Redesign",
                    "status": "active",
                    "created_at": "2026-07-24T10:30:00Z",
                }
            )
        ]
    )
    client = CraftApiClient(
        config=CraftApiConfig(
            base_url="https://api.example.test",
            api_token="test-token",
        ),
        transport=transport,
    )

    # Act
    project = client.create_project(name="Website Redesign")

    # Assert
    assert project.id == "project-123"
    assert transport.requests[0].method == "POST"
```

Comments are optional when the blocks are obvious, but helpful when a test is nontrivial.

---

# E.4 Basic Assertions

`pytest` uses ordinary Python `assert` statements.

```python
assert project.name == "Website Redesign"
assert project.status == "active"
assert project.description is None
assert "project-123" in project_ids
assert len(projects) == 3
```

When an assertion fails, `pytest` provides detailed comparison output.

```python
assert actual_projects == expected_projects
```

is usually more informative than:

```python
assert actual_projects is expected_projects
```

Use identity checks only when identity is the actual contract:

```python
assert library.find_item("BOOK-001") is physical_book
```

---

# E.5 Testing Expected Exceptions

Use `pytest.raises()` for expected error behavior.

```python
import pytest


def test_blank_project_id_is_rejected() -> None:
    client = build_client()

    with pytest.raises(ValueError, match="Project ID cannot be blank"):
        client.get_project("   ")
```

The `match` argument is a regular expression.

```python
with pytest.raises(ValueError, match="cannot be blank"):
    ...
```

Capture the exception object:

```python
def test_missing_project_error_contains_identifier() -> None:
    library = Library(name="Test Library")

    with pytest.raises(ItemNotFoundError) as captured_error:
        library.find_item("MISSING-001")

    assert captured_error.value.identifier == "MISSING-001"
    assert captured_error.value.library_name == "Test Library"
```

Test exceptions because error behavior is part of your public API contract.

---

# E.6 Fixtures

A fixture provides reusable test setup.

```python
import pytest


@pytest.fixture
def api_config() -> CraftApiConfig:
    """Return deterministic configuration for tests."""
    return CraftApiConfig(
        base_url="https://api.example.test",
        api_token="test-token",
        timeout_seconds=5.0,
    )
```

Use it by declaring a parameter with the fixture name:

```python
def test_config_has_expected_timeout(api_config: CraftApiConfig) -> None:
    assert api_config.timeout_seconds == 5.0
```

`pytest` creates and supplies the fixture automatically.

## Fixture Isolation

Function-scoped fixtures are recreated for each test by default.

```python
@pytest.fixture
def library() -> Library:
    return Library(name="Test Library")
```

This prevents state from one test leaking into another.

Good:

```python
def test_checkout(library: Library) -> None:
    ...
```

```python
def test_return(library: Library) -> None:
    ...
```

Each gets a fresh `Library`.

---

# E.7 Fixture Dependencies

Fixtures can use other fixtures.

```python
@pytest.fixture
def physical_book() -> Book:
    return Book(
        title="Clean Code",
        author="Robert C. Martin",
        isbn="BOOK-001",
        shelf_location="A-01",
    )


@pytest.fixture
def populated_library(physical_book: Book) -> Library:
    library = Library(name="Test Library")
    library.add_item(physical_book)
    return library
```

Then:

```python
def test_library_finds_book(
    populated_library: Library,
    physical_book: Book,
) -> None:
    assert populated_library.find_item("BOOK-001") is physical_book
```

---

# E.8 Fixture Scope

Fixtures may have different lifetimes.

| Scope | Created once per |
|---|---|
| `function` | Test function; default |
| `class` | Test class |
| `module` | Python test module |
| `package` | Python package |
| `session` | Entire test run |

Example:

```python
@pytest.fixture(scope="session")
def test_api_base_url() -> str:
    return "https://api.example.test"
```

Use broad scopes only for immutable or expensive setup.

Avoid shared mutable objects in session- or module-scoped fixtures unless every test carefully resets them.

---

# E.9 Fixture Cleanup with `yield`

A fixture can clean up resources after a test.

```python
from collections.abc import Iterator

import pytest


@pytest.fixture
def open_output_file(tmp_path) -> Iterator[Path]:
    """Provide a temporary output path and delete it after use."""
    output_path = tmp_path / "output.txt"

    yield output_path

    if output_path.exists():
        output_path.unlink()
```

Code before `yield` is setup.

Code after `yield` is teardown.

For many tests, `tmp_path` already handles cleanup, so manual deletion is unnecessary.

---

# E.10 Parameterization

Use `@pytest.mark.parametrize` to run the same test logic with multiple inputs.

```python
import pytest


@pytest.mark.parametrize(
    ("project_id", "expected_error"),
    [
        ("", "Project ID cannot be blank"),
        ("   ", "Project ID cannot be blank"),
    ],
)
def test_blank_project_ids_are_rejected(
    project_id: str,
    expected_error: str,
) -> None:
    client = build_client()

    with pytest.raises(ValueError, match=expected_error):
        client.get_project(project_id)
```

This is better than copying nearly identical tests.

## Multiple Parameters

```python
@pytest.mark.parametrize(
    ("page_size", "expected_error"),
    [
        (0, "between 1 and 100"),
        (-1, "between 1 and 100"),
        (101, "between 1 and 100"),
    ],
)
def test_invalid_page_size_is_rejected(
    page_size: int,
    expected_error: str,
) -> None:
    ...
```

## Named Test IDs

Use `ids=` for readable output:

```python
@pytest.mark.parametrize(
    ("status_code", "expected_exception"),
    [
        (401, CraftApiAuthenticationError),
        (404, CraftApiNotFoundError),
        (503, CraftApiServerError),
    ],
    ids=["unauthorized", "missing-project", "service-unavailable"],
)
def test_http_status_is_translated(
    status_code: int,
    expected_exception: type[Exception],
) -> None:
    ...
```

---

# E.11 `tmp_path` for File-System Tests

`tmp_path` is a built-in fixture that provides a temporary `pathlib.Path`.

```python
from pathlib import Path


def test_snapshot_writer_creates_file(tmp_path: Path) -> None:
    destination = tmp_path / "snapshots" / "catalog.txt"

    with CatalogSnapshotWriter(destination) as writer:
        writer.write_item(example_book)

    assert destination.exists()
    assert "Clean Code" in destination.read_text(encoding="utf-8")
```

Benefits:

- Tests do not modify source-controlled files.
- Each test receives its own temporary directory.
- `pytest` cleans it up afterward.

Avoid tests that write into project folders such as:

```text
output/
dist/
examples/
```

unless the test explicitly verifies packaging or generated-output behavior.

---

# E.12 `monkeypatch`

`monkeypatch` safely replaces attributes or environment variables for one test.

## Replace a Function

```python
def test_transport_uses_fake_urlopen(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    def fake_urlopen(request, *, timeout):
        return FakeUrlResponse(...)

    monkeypatch.setattr("craftapi.transport.urlopen", fake_urlopen)
```

After the test finishes, `pytest` restores the original `urlopen`.

## Set Environment Variables

```python
def test_config_loads_environment(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("CRAFTAPI_BASE_URL", "https://api.example.test")
    monkeypatch.setenv("CRAFTAPI_API_TOKEN", "test-token")

    config = CraftApiConfig.from_environment()

    assert config.api_token == "test-token"
```

## Remove Environment Variables

```python
def test_missing_token_is_rejected(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.delenv("CRAFTAPI_API_TOKEN", raising=False)

    with pytest.raises(CraftApiConfigurationError):
        CraftApiConfig.from_environment()
```

---

# E.13 Fakes versus Mocks

A **fake** is a small working replacement for a dependency.

A **mock** is usually an object that records interactions or has configured expectations.

In most application tests, simple fakes are easier to understand.

## Fake Transport Example

```python
from collections.abc import Mapping

from craftapi import HttpResponse


class FakeTransport:
    """Return prepared responses and record requests."""

    def __init__(self, responses: list[HttpResponse]) -> None:
        self._responses = list(responses)
        self.requests: list[tuple[str, str]] = []
        self.closed = False

    def request(
        self,
        *,
        method: str,
        url: str,
        headers: Mapping[str, str] | None = None,
        body: bytes | None = None,
        timeout_seconds: float,
    ) -> HttpResponse:
        self.requests.append((method, url))

        if not self._responses:
            raise AssertionError(f"Unexpected request: {method} {url}")

        return self._responses.pop(0)

    def close(self) -> None:
        self.closed = True
```

This is ideal for testing `CraftApiClient`, because it implements the same contract as production transport.

---

# E.14 Testing External Boundaries

External boundaries include:

- HTTP requests
- File systems
- Databases
- Clocks
- Randomness
- Environment variables
- Message queues

Tests should control these boundaries.

## Bad: Real Network in Unit Test

```python
def test_get_project() -> None:
    client = CraftApiClient.from_environment()
    project = client.get_project("project-123")

    assert project.id == "project-123"
```

Problems:

- Requires credentials.
- Depends on a real server.
- Can fail because of networking.
- May change real data.
- Is slow.

## Better: Fake Transport

```python
def test_get_project() -> None:
    transport = FakeTransport(
        responses=[
            make_response(
                {
                    "id": "project-123",
                    "name": "Website Redesign",
                    "status": "active",
                    "created_at": "2026-07-24T10:30:00Z",
                }
            )
        ]
    )
    client = CraftApiClient(config=test_config, transport=transport)

    project = client.get_project("project-123")

    assert project.id == "project-123"
```

---

# E.15 Testing Time and Retries

Avoid real delays in tests.

Bad:

```python
time.sleep(2)
```

Better: inject a sleeper function.

```python
delays: list[float] = []

transport = UrllibTransport(
    retry_policy=RetryPolicy(
        max_attempts=3,
        initial_delay_seconds=0.25,
    ),
    sleeper=delays.append,
)
```

Then verify:

```python
assert delays == [0.25, 0.5]
```

This proves the retry policy requested the correct delays without slowing the test suite.

---

# E.16 Test Public Behavior

Prefer tests that use public interfaces.

Good:

```python
assert client.get_project("project-123").name == "Website Redesign"
```

Less desirable:

```python
assert client._transport._responses[0].status_code == 200
```

Private structure may change during refactoring without changing the package’s public contract.

Test private methods only when:

- They contain complex logic that cannot be verified reasonably through public behavior.
- They are effectively stable internal contracts.
- The alternative is an excessively slow or unclear test.

---

# E.17 Common Test Smells

## One Test Verifies Too Much

Bad:

```python
def test_everything() -> None:
    ...
```

A failure gives little information.

Better:

```python
def test_project_payload_is_parsed() -> None:
    ...


def test_missing_project_returns_not_found_error() -> None:
    ...


def test_pagination_requests_following_page() -> None:
    ...
```

---

## Tests Depend on Execution Order

Bad:

```python
def test_create_project() -> None:
    global_project_ids.append("project-123")


def test_project_exists() -> None:
    assert "project-123" in global_project_ids
```

Tests should create their own required state.

---

## Shared Mutable Fixtures

Bad:

```python
@pytest.fixture(scope="session")
def library() -> Library:
    return Library(name="Shared Library")
```

One test may add or check out an item, affecting later tests.

Use function-scoped fixtures by default.

---

## Testing Implementation, Not Behavior

Bad:

```python
assert client._is_closed is True
```

Better:

```python
client.close()

with pytest.raises(RuntimeError, match="closed"):
    client.get_project("project-123")
```

The second test verifies externally meaningful behavior.

---

## Overusing Mocks

A test with many mock calls can become fragile:

```python
mock.assert_has_calls(
    [
        call.prepare_url(...),
        call.serialize_body(...),
        call.send(...),
        call.parse(...),
    ]
)
```

This often tests internal implementation order rather than user-visible results.

Prefer a fake dependency and assert the final request or response.

---

# E.18 Markers

Markers label tests.

```python
import pytest


@pytest.mark.slow
def test_large_import() -> None:
    ...
```

Register custom markers in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
markers = [
  "slow: marks tests that take longer than normal",
  "integration: marks tests that require external services",
]
```

Run only non-slow tests:

```bash
python -m pytest -m "not slow"
```

Run integration tests:

```bash
python -m pytest -m integration
```

For the tutorial’s default suite, all tests should remain fast and offline.

---

# E.19 Useful `pytest` Configuration

Example `pyproject.toml` configuration:

```toml
[tool.pytest.ini_options]
addopts = "-ra"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
```

Meaning:

| Setting | Purpose |
|---|---|
| `addopts = "-ra"` | Show a short summary for skipped, failed, and other non-passing tests |
| `testpaths` | Look for tests in `tests/` |
| `python_files` | Discover files matching `test_*.py` |
| `python_functions` | Discover functions matching `test_*` |

---

# E.20 Daily Testing Workflow

During development:

```bash
python -m pytest tests/test_client.py
```

Before committing:

```bash
python -m pytest
python -m mypy src tests
```

Before releasing:

```bash
python -m pytest
python -m mypy src tests
python -m build
```

A reliable sequence:

```text
Change code
    ↓
Run focused tests
    ↓
Run full tests
    ↓
Run type checks
    ↓
Build package
```

---

# E.21 Testing Checklist

Before considering a feature complete, ask:

- Does the normal success case have a test?
- Does invalid input have a test?
- Does expected exception behavior have a test?
- Does the test avoid real network access?
- Does the test avoid real waiting and clocks where possible?
- Does the test isolate file-system work with `tmp_path`?
- Does the test use public behavior where practical?
- Is the test name specific about the behavior?
- Would a failure message tell another developer what broke?
- Does the full suite pass with tests in random order?
