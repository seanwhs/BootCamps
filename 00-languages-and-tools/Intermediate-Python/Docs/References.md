# Pythonic Craftsmanship  
## References and Resources Guide

This guide collects authoritative documentation, books, tools, practice resources, and recommended learning paths for the series.

Use it as a curated reference list rather than a requirement to read everything. The most valuable approach is:

```text
Read a focused resource
    ↓
Apply one idea in code
    ↓
Write a test
    ↓
Reflect on the result
```

---

# 1. Official Python Documentation

## Python Documentation Home

**Resource:** Python Documentation  
**URL:** https://docs.python.org/3/

Use it for:

- Built-in types
- Standard library modules
- Language syntax
- Exceptions
- Data model
- Virtual environments
- Packaging
- Type hints

---

## Python Tutorial

**Resource:** The Python Tutorial  
**URL:** https://docs.python.org/3/tutorial/

Recommended sections:

- An Informal Introduction to Python
- Control Flow Tools
- Data Structures
- Modules
- Input and Output
- Errors and Exceptions
- Classes
- Virtual Environments and Packages

Best for:

- Refreshing syntax
- Understanding Python’s standard language patterns
- Filling gaps before advanced topics

---

## Python Data Model

**Resource:** Data Model  
**URL:** https://docs.python.org/3/reference/datamodel.html

Best for:

- Dunder methods
- Object lifecycle
- `__repr__`
- `__str__`
- `__eq__`
- `__hash__`
- `__len__`
- `__iter__`
- `__contains__`
- Context manager methods

Read this alongside the OOP and dunder-method modules.

---

## Built-In Functions

**Resource:** Built-in Functions  
**URL:** https://docs.python.org/3/library/functions.html

Important functions:

```python
all()
any()
enumerate()
filter()
isinstance()
iter()
len()
map()
next()
print()
repr()
sorted()
sum()
type()
zip()
```

---

# 2. Standard Library References

## `collections`

**Resource:** `collections` — Container Datatypes  
**URL:** https://docs.python.org/3/library/collections.html

Focus on:

```python
Counter
defaultdict
deque
```

Use cases:

| Tool | Best Use |
|---|---|
| `Counter` | Count repeated values |
| `defaultdict` | Group values by key |
| `deque` | Efficient queue or bounded history |

---

## `itertools`

**Resource:** `itertools` — Functions Creating Iterators  
**URL:** https://docs.python.org/3/library/itertools.html

Focus on:

```python
chain()
filterfalse()
islice()
count()
cycle()
repeat()
batched()
```

Use this after learning generators and iterators.

---

## `functools`

**Resource:** `functools` — Higher-Order Functions  
**URL:** https://docs.python.org/3/library/functools.html

Focus on:

```python
wraps
lru_cache
cache
partial
reduce
```

Most important for this series:

```python
functools.wraps
```

Use it whenever writing decorators.

---

## `pathlib`

**Resource:** `pathlib` — Object-Oriented File System Paths  
**URL:** https://docs.python.org/3/library/pathlib.html

Focus on:

```python
Path.cwd()
Path.exists()
Path.mkdir()
Path.open()
Path.read_text()
Path.write_text()
Path.resolve()
```

Prefer `pathlib.Path` over manually combining file-system strings.

---

## `dataclasses`

**Resource:** `dataclasses`  
**URL:** https://docs.python.org/3/library/dataclasses.html

Focus on:

```python
@dataclass
frozen=True
slots=True
field()
default_factory
```

Recommended use cases:

- Configuration records
- API response models
- Event data
- Error detail objects
- Immutable value objects

---

## `typing`

**Resource:** Support for Type Hints  
**URL:** https://docs.python.org/3/library/typing.html

Focus on:

```python
Any
Callable
Literal
NewType
ParamSpec
Protocol
TypeAlias
TypedDict
TypeVar
runtime_checkable
```

Use alongside `mypy` documentation.

---

## `venv`

**Resource:** Creation of Virtual Environments  
**URL:** https://docs.python.org/3/library/venv.html

Core command:

```bash
python -m venv .venv
```

---

## `urllib`

**Resource:** `urllib.request`  
**URL:** https://docs.python.org/3/library/urllib.request.html

Relevant capstone topics:

- `Request`
- `urlopen`
- Headers
- Request body data
- Timeouts

Supporting resources:

- https://docs.python.org/3/library/urllib.error.html
- https://docs.python.org/3/library/urllib.parse.html

---

# 3. Testing Resources

## pytest Documentation

**Resource:** pytest Documentation  
**URL:** https://docs.pytest.org/

Recommended topics:

- Getting started
- Assertions
- Fixtures
- Parametrizing tests
- Temporary directories
- Monkeypatching
- Capturing output
- Markers

Important patterns:

```python
@pytest.fixture
```

```python
@pytest.mark.parametrize
```

```python
with pytest.raises(ValueError):
    ...
```

```python
def test_file_output(tmp_path: Path) -> None:
    ...
```

---

## pytest Good Practices

**Resource:** pytest Good Practices  
**URL:** https://docs.pytest.org/en/stable/explanation/goodpractices.html

Focus on:

- `src/` layout
- Test discovery
- Test organization
- Editable installs
- Naming conventions

---

## Python `unittest.mock`

**Resource:** `unittest.mock`  
**URL:** https://docs.python.org/3/library/unittest.mock.html

Even when using `pytest`, this is useful for understanding:

- `Mock`
- `MagicMock`
- `patch`
- `call`
- Side effects

Use fakes first when possible. Use mocks when interaction verification is genuinely necessary.

---

# 4. Type Checking Resources

## mypy Documentation

**Resource:** mypy Documentation  
**URL:** https://mypy.readthedocs.io/

Recommended sections:

- Getting Started
- Cheat Sheet
- Type Hints
- Generics
- Protocols
- Error Codes
- Configuration File

Useful command:

```bash
python -m mypy src tests
```

---

## mypy Cheat Sheet

**Resource:** mypy Cheat Sheet  
**URL:** https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html

Useful for quick syntax lookup:

```python
list[str]
dict[str, Project]
str | None
Callable[[Project], str]
Iterator[Project]
```

---

## PEP 484: Type Hints

**Resource:** PEP 484 — Type Hints  
**URL:** https://peps.python.org/pep-0484/

Useful for:

- Understanding why type hints exist
- Historical context
- Type-system vocabulary

---

## PEP 544: Protocols

**Resource:** PEP 544 — Protocols  
**URL:** https://peps.python.org/pep-0544/

Useful for:

- Structural typing
- `Protocol`
- Dependency injection
- Test doubles
- Interface-based design

---

## PEP 561: Typed Packages

**Resource:** PEP 561 — Distributing and Packaging Type Information  
**URL:** https://peps.python.org/pep-0561/

Useful for understanding:

```text
py.typed
```

---

# 5. Packaging and Distribution Resources

## Python Packaging User Guide

**Resource:** Python Packaging User Guide  
**URL:** https://packaging.python.org/

Recommended topics:

- Installing Packages
- Packaging Projects
- `pyproject.toml`
- Distribution Package vs Import Package
- Versioning
- Building and Publishing

---

## Packaging Python Projects

**Resource:** Packaging Python Projects  
**URL:** https://packaging.python.org/en/latest/tutorials/packaging-projects/

Use this when preparing your first publishable package.

---

## Build Frontend

**Resource:** PyPA build  
**URL:** https://build.pypa.io/

Core command:

```bash
python -m build
```

This generates:

```text
dist/
├── package_name-version-py3-none-any.whl
└── package_name-version.tar.gz
```

---

## Setuptools Documentation

**Resource:** setuptools Documentation  
**URL:** https://setuptools.pypa.io/

Useful for:

- `src/` layouts
- Package discovery
- Package data
- Editable installs
- `py.typed` inclusion

---

## Semantic Versioning

**Resource:** Semantic Versioning  
**URL:** https://semver.org/

Version format:

```text
MAJOR.MINOR.PATCH
```

Example:

```text
1.4.2
```

---

# 6. HTTP and API Resources

## HTTP Status Codes

**Resource:** MDN HTTP Response Status Codes  
**URL:** https://developer.mozilla.org/en-US/docs/Web/HTTP/Status

Use it for:

- `200 OK`
- `201 Created`
- `204 No Content`
- `400 Bad Request`
- `401 Unauthorized`
- `403 Forbidden`
- `404 Not Found`
- `409 Conflict`
- `422 Unprocessable Content`
- `429 Too Many Requests`
- `500 Internal Server Error`
- `503 Service Unavailable`

---

## HTTP Semantics

**Resource:** RFC 9110 — HTTP Semantics  
**URL:** https://www.rfc-editor.org/rfc/rfc9110

Best for deeper understanding of:

- HTTP methods
- Safe methods
- Idempotent methods
- Status codes
- Headers
- Request and response meaning

---

## JSON Standard

**Resource:** RFC 8259 — The JavaScript Object Notation Data Interchange Format  
**URL:** https://www.rfc-editor.org/rfc/rfc8259

Useful for understanding JSON boundaries and data shapes.

---

## URL Encoding

**Resource:** URL Parsing — Python Documentation  
**URL:** https://docs.python.org/3/library/urllib.parse.html

Important function:

```python
from urllib.parse import quote

encoded_identifier = quote(project_id, safe="")
```

---

# 7. Security Resources

## OWASP Top 10

**Resource:** OWASP Top 10  
**URL:** https://owasp.org/www-project-top-ten/

Recommended for learning common web-application security risks.

Topics especially relevant to Python API clients:

- Authentication failures
- Sensitive-data exposure
- Security misconfiguration
- Logging and monitoring failures
- Dependency risks

---

## OWASP Secrets Management Cheat Sheet

**Resource:** Secrets Management Cheat Sheet  
**URL:** https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html

Use it for:

- Environment variables
- Secret rotation
- Secret storage
- Avoiding hard-coded credentials
- Incident response after a leak

---

## OWASP Logging Cheat Sheet

**Resource:** Logging Cheat Sheet  
**URL:** https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

Use it for safe logging design.

Never log:

```text
API tokens
Authorization headers
Passwords
Cookies
Private keys
Sensitive request bodies
Sensitive response bodies
```

---

# 8. Git and Collaboration Resources

## Pro Git Book

**Resource:** Pro Git  
**URL:** https://git-scm.com/book/en/v2

Recommended chapters:

- Getting Started
- Git Basics
- Git Branching
- Distributed Git
- Git Tools

---

## GitHub Skills

**Resource:** GitHub Skills  
**URL:** https://skills.github.com/

Hands-on practice for:

- Repositories
- Branches
- Pull requests
- Merge conflicts
- GitHub Actions

---

## Conventional Commits

**Resource:** Conventional Commits  
**URL:** https://www.conventionalcommits.org/

Optional commit format:

```text
feat: add project pagination
fix: reject boolean page sizes
test: add transport retry coverage
docs: document environment variables
```

Use this only if it fits your team workflow.

---

# 9. Recommended Books

## Fluent Python

**Author:** Luciano Ramalho  
**Title:** *Fluent Python, 2nd Edition*

Strong for:

- Python data model
- Functions as objects
- Decorators
- Iterators and generators
- Data classes
- Type hints
- Pythonic idioms

Best after completing this series.

---

## Effective Python

**Author:** Brett Slatkin  
**Title:** *Effective Python, 2nd Edition*

Strong for:

- Practical Python best practices
- Functions
- Classes
- Metaprogramming
- Concurrency
- Testing
- Maintainability

Useful as a “one lesson at a time” reference book.

---

## Python Distilled

**Author:** David M. Beazley  
**Title:** *Python Distilled*

Strong for:

- Core Python concepts
- Modern language features
- Clean explanations
- Intermediate-level development

---

## Architecture Patterns with Python

**Authors:** Harry Percival and Bob Gregory  
**Title:** *Architecture Patterns with Python*

Available online:  
https://www.cosmicpython.com/

Strong for:

- Domain modeling
- Repository pattern
- Service layers
- Dependency injection
- Testing architecture
- Ports and adapters

Especially useful after completing the `craftapi` capstone.

---

## Test-Driven Development with Python

**Author:** Harry J.W. Percival  
**Title:** *Test-Driven Development with Python*

Available online:  
https://www.obeythetestinggoat.com/

Strong for:

- Testing mindset
- Django/web development
- Functional tests
- Unit tests
- Incremental design

---

# 10. Modern Python Tools to Explore Next

These are not required for the core series but are valuable next steps.

| Tool | Purpose | Resource |
|---|---|---|
| Ruff | Linter and formatter | https://docs.astral.sh/ruff/ |
| Black | Opinionated code formatter | https://black.readthedocs.io/ |
| pre-commit | Git hook framework | https://pre-commit.com/ |
| coverage.py | Test coverage measurement | https://coverage.readthedocs.io/ |
| tox | Multi-environment test automation | https://tox.wiki/ |
| nox | Python-based automation | https://nox.thea.codes/ |
| uv | Fast Python package and environment tool | https://docs.astral.sh/uv/ |
| Poetry | Dependency and packaging tool | https://python-poetry.org/docs/ |
| pip-tools | Requirements management | https://pip-tools.readthedocs.io/ |
| httpx | Modern synchronous/asynchronous HTTP client | https://www.python-httpx.org/ |
| Pydantic | Runtime validation and settings models | https://docs.pydantic.dev/ |
| FastAPI | Typed web API framework | https://fastapi.tiangolo.com/ |

---

# 11. Recommended Tooling Path

## Stage 1: Core Series Tools

```text
Python
venv
pip
Git
pytest
mypy
build
```

## Stage 2: Code Quality Automation

```text
Ruff
pre-commit
coverage.py
```

## Stage 3: Modern Application Development

```text
httpx
Pydantic
FastAPI
SQLite or PostgreSQL
Docker
GitHub Actions
```

## Stage 4: Production Operations

```text
Structured logging
Metrics
Tracing
Secrets manager
Dependency scanning
Container deployment
```

---

# 12. Practice Resources

## Exercism Python Track

**URL:** https://exercism.org/tracks/python

Good for:

- Small focused exercises
- Mentoring
- Language idioms
- Incremental practice

---

## Advent of Code

**URL:** https://adventofcode.com/

Good for:

- Problem solving
- Iteration
- Parsing
- Data structures
- Algorithmic thinking

Use it to practice clean code, tests, and refactoring—not only puzzle completion.

---

## Real Python

**URL:** https://realpython.com/

Good for:

- Tutorials
- Python ecosystem topics
- Practical examples
- Tool introductions

Treat tutorials as starting points. Verify advice against official documentation for production decisions.

---

## Python Package Index

**Resource:** PyPI  
**URL:** https://pypi.org/

Use it to:

- Discover packages
- Inspect release history
- Read package metadata
- Check project links

Before adding a dependency, inspect:

- Maintenance activity
- Python version support
- License
- Documentation quality
- Security posture
- Dependency count

---

# 13. Suggested Practice Projects

## Project 1: Command-Line Task Tracker

Practice:

- Classes
- File persistence
- `argparse`
- Testing
- Type hints

Suggested features:

```text
Add task
List tasks
Mark task complete
Delete task
Save JSON file
Load JSON file
```

---

## Project 2: API Health Checker

Practice:

- HTTP requests
- Timeouts
- Retries
- Logging
- CLI arguments
- Result summaries

Suggested features:

```text
Read URLs from file
Check status codes
Measure duration
Retry transient failures
Write JSON report
```

---

## Project 3: CSV Import Validator

Practice:

- `csv`
- Generators
- Data validation
- Error reporting
- Dataclasses
- Tests

Suggested features:

```text
Read CSV lazily
Validate required columns
Reject invalid rows
Produce valid-record output
Write error report
```

---

## Project 4: Markdown Report Generator

Practice:

- `pathlib`
- Context managers
- Templates
- Data aggregation
- CLI tools

Suggested features:

```text
Read project JSON
Group by status
Generate Markdown report
Write report file
```

---

## Project 5: Extend `craftapi`

Practice:

- Public API design
- HTTP transport
- Models
- Tests
- Retry safety
- Documentation

Suggested extensions:

```text
update_project()
delete_project()
status filtering
rate-limit parsing
idempotency keys
async client
SQLite cache
CLI interface
```

---

# 14. Research Checklist Before Adding a Dependency

Before adding a third-party package, ask:

- [ ] Does the standard library already solve this problem?
- [ ] Is the package actively maintained?
- [ ] Does it support the Python versions we support?
- [ ] Is the license acceptable?
- [ ] Does it add many transitive dependencies?
- [ ] Does it have clear documentation?
- [ ] Does it have a stable release history?
- [ ] Can we test code that depends on it?
- [ ] What happens if the package is abandoned?
- [ ] Does it handle sensitive data safely?

---

# 15. Reference Cheat Sheet

## Development Commands

```bash
python -m venv .venv
python -m pip install --editable ".[dev]"
python -m pytest
python -m mypy src tests
python -m build
```

## Git Commands

```bash
git status
git diff
git add .
git diff --staged
git commit -m "Add feature"
git switch -c feature/name
git merge feature/name
```

## API Client Safety

```text
Validate environment configuration.
Require HTTPS for production endpoints.
URL encode identifiers.
Use timeouts.
Translate HTTP errors.
Validate JSON responses.
Avoid real-network unit tests.
Retry only safe temporary failures.
Never log secrets.
```

---

# 16. Recommended Ongoing Learning Routine

## Weekly Routine

```text
1. Read one focused resource.
2. Build one small feature.
3. Write tests.
4. Run mypy.
5. Review Git diff.
6. Commit a completed change.
7. Write one short reflection note.
```

## Monthly Routine

```text
1. Build or extend a small project.
2. Read another developer's Python code.
3. Refactor one earlier project.
4. Improve test coverage.
5. Review dependencies.
6. Practice explaining an architecture decision aloud.
```

---

# 17. Final Resource Strategy

Do not try to consume every resource in this guide.

Use this order:

```text
Official Python documentation
    ↓
pytest and mypy documentation
    ↓
One practical book
    ↓
One complete project extension
    ↓
Code review and refactoring
    ↓
Advanced ecosystem tools
```

The strongest learning comes from repeatedly applying ideas in working code.
