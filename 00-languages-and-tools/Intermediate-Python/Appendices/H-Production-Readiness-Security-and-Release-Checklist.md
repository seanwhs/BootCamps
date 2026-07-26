# Appendix H: Production Readiness, Security, and Release Checklist

A program that runs on one developer’s machine is not automatically ready for other developers, CI systems, or production workloads.

Production readiness means preparing for normal usage and predictable failures:

- Invalid configuration
- Missing credentials
- Unexpected API responses
- Network instability
- Dependency upgrades
- Package installation
- Future maintenance

This appendix provides a practical checklist for the `craftapi` package and similar Python services or libraries.

---

# H.1 Production Readiness Overview

A production-quality Python package should have these layers:

```text
Correctness
    ├── Automated tests
    ├── Type checks
    └── Input validation

Reliability
    ├── Timeouts
    ├── Clear exceptions
    ├── Safe retries
    └── Resource cleanup

Security
    ├── HTTPS
    ├── Secret handling
    ├── Safe logging
    └── Dependency review

Distribution
    ├── Buildable package
    ├── Versioning
    ├── Documentation
    └── Reproducible installation
```

No single checklist item guarantees quality. The value comes from consistently applying all of them.

---

# H.2 Pre-Commit Checklist

Before committing a change:

```bash
python -m pytest
python -m mypy src tests
```

Then review the diff:

```bash
git diff
```

Checklist:

- [ ] Tests pass.
- [ ] `mypy` passes.
- [ ] New behavior has tests.
- [ ] Error behavior has tests where relevant.
- [ ] No API tokens, passwords, or private URLs are in the diff.
- [ ] No generated files are being committed.
- [ ] Public API changes are documented.
- [ ] Version is updated if required by your release policy.

Search for likely secrets before committing:

```bash
git diff --cached | grep -Ei "token|secret|password|api[_-]?key|authorization"
```

On Windows PowerShell:

```powershell
git diff --cached | Select-String -Pattern "token|secret|password|api[_-]?key|authorization"
```

A match is not always a secret, but it should be reviewed deliberately.

---

# H.3 Pre-Release Verification Pipeline

From the package root:

```bash
python -m pip install --editable ".[dev]"
python -m pytest
python -m mypy src tests
python -m build
```

Expected outcome:

```text
... passed
Success: no issues found in ... source files
Successfully built craftapi-0.1.0.tar.gz and craftapi-0.1.0-py3-none-any.whl
```

Then inspect the generated artifacts:

```bash
ls -la dist/
```

Expected files:

```text
craftapi-0.1.0-py3-none-any.whl
craftapi-0.1.0.tar.gz
```

On Windows PowerShell:

```powershell
Get-ChildItem dist
```

---

# H.4 Test the Built Wheel in a Clean Environment

Editable installs can hide packaging mistakes. Always test the built wheel in a new environment.

## The Target

We are creating a temporary test environment outside the active development environment.

## The Concept

An editable install reads source files directly from your working directory.

A real user installs a wheel. Testing the wheel is like testing the sealed product box instead of testing a loose collection of parts on your workbench.

## The Implementation

Build the package first:

```bash
python -m build
```

Create a clean environment.

### macOS or Linux

```bash
python3 -m venv .wheel-test-venv
source .wheel-test-venv/bin/activate

python -m pip install --upgrade pip
python -m pip install dist/craftapi-0.1.0-py3-none-any.whl

python -c "from craftapi import CraftApiClient, Project, RetryPolicy; print(CraftApiClient.__name__); print(Project.__name__); print(RetryPolicy.__name__)"

deactivate
rm -rf .wheel-test-venv
```

### Windows PowerShell

```powershell
py -m venv .wheel-test-venv
.\.wheel-test-venv\Scripts\Activate.ps1

python -m pip install --upgrade pip
python -m pip install dist\craftapi-0.1.0-py3-none-any.whl

python -c "from craftapi import CraftApiClient, Project, RetryPolicy; print(CraftApiClient.__name__); print(Project.__name__); print(RetryPolicy.__name__)"

deactivate
Remove-Item -Recurse -Force .wheel-test-venv
```

## The Verification

Expected output:

```text
CraftApiClient
Project
RetryPolicy
```

The import must succeed without your project source directory being directly available on Python’s import path.

---

# H.5 Secret Management Checklist

Secrets include:

- API tokens
- Passwords
- Client secrets
- Private keys
- Session cookies
- Database URLs containing credentials

## Never Hard-Code Secrets

Do not do this:

```python
API_TOKEN = "real-production-secret"
```

Do this:

```python
config = CraftApiConfig.from_environment()
```

Use environment variables:

```text
CRAFTAPI_API_TOKEN
```

## Never Commit Secret Files

Ensure `.gitignore` contains:

```gitignore
.env
.env.*
!.env.example
```

Provide a safe template instead.

### `.env.example`

```dotenv
# Copy this file to .env and replace placeholder values locally.
# Never commit the resulting .env file.

CRAFTAPI_BASE_URL=https://api.example.com
CRAFTAPI_API_TOKEN=replace-with-your-token
CRAFTAPI_TIMEOUT_SECONDS=10
```

## Check Git History

A deleted secret may still exist in Git history.

Check current tracked files:

```bash
git ls-files | grep -E "\.env$|credentials|secrets"
```

If a real secret was committed:

1. Revoke or rotate it immediately.
2. Remove it from active configuration.
3. Consider rewriting repository history if required by your organization.
4. Inform the security owner according to policy.

Rotating the secret is the urgent step. Removing text from the newest commit alone is not enough.

---

# H.6 Logging Checklist

Logs should help answer:

- What happened?
- When did it happen?
- Which operation failed?
- Which safe identifier or request URL was involved?
- How often is it happening?

Logs should never reveal credentials.

## Safe Fields

```text
HTTP method
Status code
Request duration
Retry attempt
Safe resource identifier
Sanitized URL
Exception type
```

## Unsafe Fields

```text
Authorization header
Bearer token
Cookie header
Password
Full request body
Sensitive response body
Personally identifiable information
```

Safe transport log:

```python
LOGGER.info(
    "Craft API request succeeded: method=%s url=%s status_code=%s",
    method,
    url,
    response.status_code,
)
```

Unsafe transport log:

```python
LOGGER.debug("Request headers: %r", headers)
LOGGER.debug("Request body: %r", body)
```

## Libraries Should Not Configure Root Logging

Do not put this inside `craftapi` package modules:

```python
logging.basicConfig(level=logging.DEBUG)
```

The application using the library decides logging configuration.

The library should only obtain a module logger:

```python
import logging

LOGGER = logging.getLogger(__name__)
```

---

# H.7 Dependency Management

Dependencies introduce both capability and risk.

## Keep Runtime Dependencies Minimal

The tutorial client uses Python’s standard-library `urllib` transport. This means no extra runtime HTTP dependency.

Every third-party dependency adds:

- Upgrade work
- Security review surface
- Potential transitive dependencies
- Licensing considerations
- Compatibility risk

Add a dependency only when it provides a meaningful benefit.

## Keep Development Dependencies Explicit

Development tools belong in the development optional dependency group:

```toml
[project.optional-dependencies]
dev = [
  "build>=1.2",
  "mypy>=1.10",
  "pytest>=8.2",
]
```

Install them consistently:

```bash
python -m pip install --editable ".[dev]"
```

## Audit Dependencies

Inspect installed packages:

```bash
python -m pip list
```

Check outdated packages:

```bash
python -m pip list --outdated
```

For real production projects, use organization-approved vulnerability scanning tools in CI.

---

# H.8 Versioning Guidance

Use semantic versioning when publishing reusable packages:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.4.2
```

| Component | Increment when |
|---|---|
| `MAJOR` | Backward-incompatible public API change |
| `MINOR` | Backward-compatible new feature |
| `PATCH` | Backward-compatible bug fix |

Examples:

```text
0.1.0 → 0.1.1
```

Fix a timeout-validation bug.

```text
0.1.1 → 0.2.0
```

Add `update_project()` without breaking existing callers.

```text
0.2.0 → 1.0.0
```

Declare stable first public release.

```text
1.0.0 → 2.0.0
```

Rename or remove a public client method.

For pre-1.0 packages, teams sometimes treat minor releases as potentially breaking. Document your policy clearly.

---

# H.9 Public API Stability

A package’s public API includes more than function names.

For `craftapi`, public contracts include:

- Exported classes in `craftapi.__init__`
- Method names and parameter types
- Return types
- Exception types
- Configuration environment variable names
- Pagination behavior
- Retry defaults
- Model field meanings

Avoid breaking changes such as:

```python
# Old public API
client.get_project(project_id: str) -> Project
```

```python
# Breaking change
client.get_project(identifier: int) -> dict[str, object]
```

If a change is necessary, consider:

1. Adding a new method.
2. Deprecating the old method.
3. Documenting a migration path.
4. Removing the old method only in a major release.

---

# H.10 Deprecation Pattern

Use `warnings.warn()` to communicate a planned API change.

```python
import warnings


def get_project_by_id(project_id: str) -> Project:
    """Deprecated compatibility wrapper."""
    warnings.warn(
        "get_project_by_id() is deprecated; use get_project() instead.",
        category=DeprecationWarning,
        stacklevel=2,
    )

    return get_project(project_id)
```

`stacklevel=2` points the warning at the caller’s code rather than the warning helper itself.

Test deprecations:

```python
import pytest


def test_deprecated_method_warns() -> None:
    with pytest.deprecated_call(
        match="use get_project\\(\\) instead"
    ):
        client.get_project_by_id("project-123")
```

---

# H.11 CI Pipeline Baseline

A continuous integration system should run the same checks developers run locally.

Example GitHub Actions workflow:

### `.github/workflows/ci.yml`

```yaml
name: Continuous Integration

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  test:
    name: Test Python ${{ matrix.python-version }}
    runs-on: ubuntu-latest

    strategy:
      fail-fast: false
      matrix:
        python-version:
          - "3.11"
          - "3.12"
          - "3.13"

    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install package and development dependencies
        run: python -m pip install --editable ".[dev]"

      - name: Run tests
        run: python -m pytest

      - name: Run static type checks
        run: python -m mypy src tests

      - name: Build distribution artifacts
        run: python -m build
```

This workflow verifies supported Python versions independently.

Before adopting a CI provider, follow your organization’s security and approval policies for external actions and credentials.

---

# H.12 Release Checklist

## Code Quality

- [ ] All tests pass.
- [ ] Static type checking passes.
- [ ] No temporary debug code remains.
- [ ] No broad exception swallowing remains.
- [ ] All public methods have docstrings and type annotations.
- [ ] New features include tests.
- [ ] Error behavior is intentional and documented.

## Security

- [ ] No secrets are committed.
- [ ] `.env` is ignored.
- [ ] `.env.example` contains placeholders only.
- [ ] HTTPS is required for production endpoints.
- [ ] Logs do not include tokens or authorization headers.
- [ ] Retry behavior does not duplicate unsafe writes.
- [ ] Dependencies have been reviewed.

## Packaging

- [ ] `pyproject.toml` metadata is accurate.
- [ ] Version number is correct.
- [ ] README installation instructions work.
- [ ] Wheel builds successfully.
- [ ] Source distribution builds successfully.
- [ ] Wheel installs in a clean virtual environment.
- [ ] `py.typed` is included in the wheel.

## Documentation

- [ ] README describes configuration variables.
- [ ] README includes a minimal working example.
- [ ] README documents exceptions users may need to handle.
- [ ] README documents retry behavior and limits.
- [ ] Breaking changes include migration notes.
- [ ] Changelog or release notes are updated.

---

# H.13 Minimal Release Command Sequence

Run this from the `craftapi` project root:

```bash
python -m pip install --editable ".[dev]"
python -m pytest
python -m mypy src tests
rm -rf dist build
python -m build
```

For Windows PowerShell:

```powershell
python -m pip install --editable ".[dev]"
python -m pytest
python -m mypy src tests
Remove-Item -Recurse -Force dist, build -ErrorAction SilentlyContinue
python -m build
```

Then test the wheel in a clean environment, as shown in Section H.4.

---

# H.14 Production Incident Checklist

If a release causes unexpected API-client failures:

1. **Stop guessing.** Capture safe symptoms and error categories.
2. **Identify scope.** Which versions, endpoints, users, or environments fail?
3. **Check recent changes.** Compare release version, dependency updates, configuration changes, and API changes.
4. **Inspect safe logs.** Look for status codes, exception types, request paths, retry counts, and duration changes.
5. **Protect secrets.** Do not add token-printing debug statements.
6. **Mitigate.** Roll back, disable an optional feature, reduce load, or update configuration.
7. **Fix and test.** Add a regression test for the root cause.
8. **Document.** Record what happened and how to prevent recurrence.

A good incident response improves the system rather than merely restoring it.
