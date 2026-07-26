# Pythonic Craftsmanship  
## Trainer Guide

**Course title:** Pythonic Craftsmanship: Writing Clean, Idiomatic Code  
**Audience:** Developers comfortable with Python basics who want to write modular, testable, typed, production-oriented Python.  
**Format:** Instructor-led workshop, self-paced cohort, or blended learning series.  
**Recommended delivery:** 12 technical parts plus 5 optional primers, delivered across 5–10 sessions.

---

# 1. Trainer Overview

## Course Purpose

This course helps learners move from:

```text
“I can write Python scripts.”
```

to:

```text
“I can design, test, type-check, package, and maintain a Python application.”
```

The course emphasizes practical engineering habits:

- Clear responsibilities
- Explicit validation
- Pythonic collection processing
- Safe error handling
- Testable dependency boundaries
- Type-aware interfaces
- Secure configuration
- Release readiness

## Core Teaching Principle

Use this pattern for every build step:

```text
Target
    ↓
Concept
    ↓
Implementation
    ↓
Verification
    ↓
Reflection
```

Do not present code before learners understand why the file, class, function, or tool is needed.

---

# 2. Recommended Delivery Formats

## Option A: Intensive Bootcamp

| Session | Coverage | Suggested Duration |
|---|---|---:|
| Day 1 | Primers, Part 0, Part 1 | 6–7 hours |
| Day 2 | Parts 2–4 | 6–7 hours |
| Day 3 | Parts 5–6 | 5–6 hours |
| Day 4 | Parts 7–8 | 5–6 hours |
| Day 5 | Parts 9–12 capstone | 7–8 hours |

## Option B: Weekly Cohort

| Week | Coverage |
|---|---|
| 1 | Primers and Part 0 |
| 2 | Parts 1–2: OOP |
| 3 | Parts 3–4: Pythonic mechanics |
| 4 | Parts 5–6: Functions and decorators |
| 5 | Parts 7–8: Packages, tests, types |
| 6 | Part 9: Capstone foundation |
| 7 | Parts 10–11: Transport and client |
| 8 | Part 12: Hardening, packaging, final review |

## Option C: Self-Paced With Office Hours

- Publish one part per week.
- Require the student workbook exercises before office hours.
- Use office hours for debugging, code review, and architecture questions.
- Require a final capstone extension before completion.

---

# 3. Trainer Preparation Checklist

Before the first session:

- [ ] Verify Python 3.11+ is installed on training machines.
- [ ] Verify Git is installed.
- [ ] Verify learners can open a terminal.
- [ ] Verify learners can create virtual environments.
- [ ] Prepare a working reference repository.
- [ ] Prepare a deliberately broken repository for debugging demonstrations.
- [ ] Install required tools:

```bash
python -m pip install pytest mypy build python-pptx
```

- [ ] Confirm test command works:

```bash
python -m pytest
```

- [ ] Confirm type-check command works:

```bash
python -m mypy src tests
```

- [ ] Confirm package build works:

```bash
python -m build
```

- [ ] Ensure no example files contain real tokens, passwords, or private URLs.

---

# 4. Learning Outcomes

By the end of the course, learners should be able to:

1. Create isolated Python project environments.
2. Use Git for small, meaningful commits.
3. Design classes with controlled state and clear responsibilities.
4. Apply inheritance only when an “is a” relationship exists.
5. Choose between lists, sets, dictionaries, generators, and iterators.
6. Create context managers for safe cleanup.
7. Use callbacks, closures, `*args`, and `**kwargs appropriately.
8. Build decorators with `functools.wraps`, `ParamSpec`, and `TypeVar`.
9. Structure an installable Python package with a `src/` layout.
10. Write unit tests using `pytest` fixtures and fakes.
11. Type-check packages with `mypy`.
12. Validate external JSON at system boundaries.
13. Build a modular API client with typed models and exception boundaries.
14. Implement safe retry behavior.
15. Build and install a wheel in a clean environment.

---

# 5. Facilitation Approach

## Recommended Teaching Ratio

Use this approximate session balance:

| Activity | Percentage |
|---|---:|
| Trainer explanation | 25% |
| Live coding | 25% |
| Guided learner implementation | 30% |
| Verification and debugging | 10% |
| Review and reflection | 10% |

Avoid long lecture-only blocks. Learners should type, run, break, inspect, and repair code.

## Live-Coding Rules

When live coding:

1. Start from a known clean Git commit.
2. Explain the target before creating a file.
3. Type code at a pace learners can follow.
4. Intentionally make one small mistake occasionally.
5. Read the error aloud.
6. Fix the root cause, not only the symptom.
7. Run the verification command immediately.
8. Commit completed milestones.

## Trainer Language

Prefer:

```text
“Let’s validate this at the boundary.”
“Let’s give this component one responsibility.”
“What would happen if this API returned malformed data?”
“Can we test this without a real network?”
“What does the public caller need to know?”
```

Avoid:

```text
“This is just how Python does it.”
“Trust me; we will explain it later.”
“Use this because it is more advanced.”
```

---

# 6. Primer Facilitation Guide

## Primer 1: Development Environment

### Goal

Ensure every learner can create and activate a virtual environment.

### Demonstration

```bash
python --version
python -m venv .venv
source .venv/bin/activate
python -m pip install pytest mypy
```

### Trainer Watch Points

Common issues:

- Learner uses global Python instead of `.venv`.
- Windows PowerShell blocks activation scripts.
- `pip` points to a different Python installation.
- Python version is below 3.11.

### Checkpoint Question

> Why do we use `python -m pip` instead of only `pip`?

Expected answer:

> It ensures the package installer belongs to the active Python interpreter.

---

## Primer 2: Terminal and Paths

### Goal

Learners can navigate directories and run scripts from the correct location.

### Demonstration

```bash
pwd
ls -la
cd scripts
python ../hello_python.py
cd ..
```

### Exercise

Ask learners to:

1. Create `notes/`.
2. Create `scripts/`.
3. Create a text file.
4. Run a script from the project root.
5. Run the same script from a subdirectory with a relative path.

### Checkpoint Question

> What is the difference between the current working directory and the script file location?

---

## Primer 3: Syntax Refresh

### Goal

Confirm learners can read and write basic Python before OOP begins.

### Focus Topics

- Strings
- Lists
- Dictionaries
- Functions
- Exceptions
- F-strings
- Loops
- Type annotations

### Trainer Tip

Use the syntax refresher to identify learners who need extra help before Part 1. Do not let basic syntax uncertainty become hidden frustration later.

---

## Primer 4: Git

### Goal

Learners can make small commits and use feature branches.

### Required Commands

```bash
git status
git diff
git add .
git diff --staged
git commit -m "Message"
git switch -c feature/example
git merge feature/example
```

### Trainer Emphasis

Teach this sequence repeatedly:

```text
status → diff → stage → staged diff → commit
```

### Common Mistake

Learners stage `.venv/` or `.env`.

Ask them to verify:

```bash
git check-ignore -v .venv/bin/python
```

---

## Primer 5: Debugging

### Goal

Learners read tracebacks calmly and methodically.

### Core Rule

Read tracebacks from the bottom upward.

### Trainer Activity

Show a controlled failure:

```python
normalize_project_name("   ")
```

Ask learners:

1. What exception occurred?
2. Which function raised it?
3. What input caused it?
4. Is this a bug or expected validation behavior?

---

# 7. Module Facilitation Guide

## Part 0: Introduction

### Main Message

The goal is not short code. The goal is code with low confusion cost.

### Trainer Prompts

- “What makes a script difficult to extend?”
- “What does production-ready mean in your current work?”
- “Which concerns belong inside an API client rather than every caller?”

### Activity

Have learners label this architecture:

```text
CraftApiClient
Configuration
Transport
Models
Exceptions
Tests
```

---

## Part 1: OOP Foundations

### Main Concepts

- Classes
- Instances
- `self`
- Constructors
- Encapsulation
- Properties
- Class attributes
- Class methods

### Live Coding Sequence

1. Create `Book`.
2. Add constructor validation.
3. Add checkout state.
4. Add `check_out()`.
5. Add `return_to_library()`.
6. Add read-only property.
7. Add class counter.

### Instructor Questions

- “What data belongs to one book?”
- “What behavior belongs to the book itself?”
- “Why should checkout state not be freely assignable?”
- “What invalid state are we preventing?”

### Assessment Exercise

Ask learners to add a `shelf_location` field with validation.

---

## Part 2: Inheritance and Dunder Methods

### Main Concepts

- Base classes
- Subclasses
- `super()`
- Method overriding
- Polymorphism
- `__repr__`
- `__str__`
- `__eq__`
- `__hash__`
- `__len__`
- `__iter__`
- `__contains__`

### Trainer Caution

Do not present inheritance as the default reuse tool.

Emphasize:

```text
Inheritance = is a
Composition = has a
```

### Demonstration

```python
class Book(LendingItem):
    ...

class DigitalBook(LendingItem):
    ...
```

Then show:

```python
item.check_out()
```

working differently for each subtype.

### Assessment Exercise

Ask learners to explain why this is incorrect:

```python
class Library(Book):
    ...
```

Expected answer:

> A library contains books; it is not a type of book.

---

## Part 3: Pythonic Collections

### Main Concepts

- List comprehensions
- Dictionary comprehensions
- Set comprehensions
- `Counter`
- `defaultdict`
- `deque`
- `any()`
- `all()`

### Trainer Activity

Show a loop first:

```python
available_titles: list[str] = []

for item in library:
    if not item.is_checked_out:
        available_titles.append(item.title)
```

Then show the comprehension:

```python
available_titles = [
    item.title
    for item in library
    if not item.is_checked_out
]
```

Ask:

> Which is clearer here, and why?

### Key Message

Pythonic does not mean “shortest.” It means “clear and idiomatic.”

---

## Part 4: Iterators, Generators, and Context Managers

### Main Concepts

- Iterable
- Iterator
- `iter()`
- `next()`
- `StopIteration`
- Generator functions
- `yield`
- `itertools`
- Context managers
- `with`

### Demonstration

```python
iterator = iter(library)
first_item = next(iterator)
```

Then:

```python
def iter_available_items(...) -> Iterator[LendingItem]:
    for item in items:
        if not item.is_checked_out:
            yield item
```

### Trainer Exercise

Ask learners to predict output:

```python
results = library.search_title("python")
print(next(results))
print(list(results))
print(list(results))
```

Expected discussion:

> The generator is consumed. The final list is empty.

---

## Part 5: First-Class Functions and Closures

### Main Concepts

- Functions as values
- Callbacks
- Closures
- Event handlers
- `*args`
- `**kwargs`
- Optional observer failures

### Demonstration

```python
library.subscribe(record_event)
library.add_item(book)
```

### Trainer Question

> Should an optional analytics callback failure undo a completed checkout?

Expected answer:

> Usually no. The catalog action already succeeded. Record the callback failure separately.

### Assessment Exercise

Have learners create a closure that prints only selected event types.

---

## Part 6: Decorators

### Main Concepts

- Wrapper functions
- `functools.wraps`
- Decorator factories
- Validation decorators
- Logging decorators
- Retry decorators
- Decorator order

### Trainer Emphasis

Always show:

```python
@decorator
def function():
    ...
```

is equivalent to:

```python
function = decorator(function)
```

### Common Learner Mistakes

- Forgetting `@wraps`.
- Forgetting to return the wrapped function result.
- Catching all exceptions.
- Retrying unsafe `POST` operations.
- Losing type information.

### Assessment Exercise

Ask learners to write a timing decorator that uses:

```python
time.monotonic()
```

---

## Part 7: Package Architecture and pytest

### Main Concepts

- `src/` layout
- `pyproject.toml`
- Editable installs
- Tests
- Fixtures
- Parameterization
- `tmp_path`
- Fakes

### Trainer Demonstration

```bash
python -m pip install --editable ".[dev]"
python -m pytest
```

### Important Question

> Why do we prefer `python -m pytest`?

Expected answer:

> It uses the `pytest` installed for the active Python interpreter and virtual environment.

### Assessment Exercise

Have learners write a fixture for a valid `Project` payload.

---

## Part 8: Type Hints and Error Boundaries

### Main Concepts

- `str | None`
- Generic collections
- `Callable`
- `Protocol`
- `ParamSpec`
- Domain exceptions
- `raise ... from error`
- `mypy`

### Demonstration

```python
try:
    return self._items_by_identifier[identifier]
except KeyError as error:
    raise ItemNotFoundError(identifier, self.name) from error
```

### Trainer Prompt

> Why should package users catch `ItemNotFoundError` instead of `KeyError`?

Expected answer:

> The package exposes a domain-level failure rather than leaking its dictionary implementation detail.

---

# 8. Capstone Facilitation Guide

## Part 9: `craftapi` Foundation

### Deliverables

- `CraftApiConfig`
- API exception hierarchy
- `Project`
- `ProjectPage`
- Environment loading
- Model tests

### Trainer Focus

Reinforce boundary validation:

```text
Environment variables → validated config
JSON payload → validated model
```

### Critical Demonstration

```python
CraftApiConfig(
    base_url="https://api.example.test/",
    api_token=" token ",
)
```

Expected normalized values:

```text
https://api.example.test
token
```

---

## Part 10: HTTP Transport

### Deliverables

- `Transport` protocol
- `HttpResponse`
- `UrllibTransport`
- JSON body encoding
- HTTP error translation
- Offline transport tests

### Trainer Focus

Keep layers separate:

```text
Client = domain operations
Transport = HTTP mechanics
Models = data validation
```

### Common Mistake

Learners may write real-network tests.

Redirect them to fake or mocked `urlopen` tests.

---

## Part 11: Public Client and Pagination

### Deliverables

- `CraftApiClient`
- `get_project()`
- `create_project()`
- `iter_projects()`
- Context manager
- Fake transport tests

### Trainer Demonstration

Show lazy behavior:

```python
projects = client.iter_projects(page_size=25)
```

Then ask:

> How many network requests have happened?

Expected answer:

> Zero, until the iterator is consumed.

### Important Security Topic

Show safe path encoding:

```python
quote(project_id, safe="")
```

Explain why raw user input must not be concatenated into URL paths.

---

## Part 12: Production Hardening

### Deliverables

- `RetryPolicy`
- Idempotent-method retry behavior
- Safe structured logging
- Package builds
- Clean wheel installation
- Release checklist

### Trainer Focus

Teach that retries are a risk-management decision, not a default cure.

Prompt:

> Why does the client not retry POST automatically?

Expected answer:

> A failed response does not prove the server did not create the resource. Retrying can duplicate side effects.

---

# 9. Assessment Strategy

## Formative Assessment

Use short checks throughout the course:

- Explain a traceback.
- Choose between list and generator.
- Identify correct exception type.
- Predict code output.
- Review a small broken snippet.
- Write one test.
- Explain a design choice aloud.

## Summative Assessment

Require learners to complete:

1. All core exercises in the workbook.
2. A passing package test suite.
3. A passing `mypy` check.
4. A `craftapi` extension.
5. A short architecture explanation.

## Suggested Rubric

| Criterion | Emerging | Competent | Strong |
|---|---|---|---|
| Package structure | Files work but are disorganized | Uses `src/`, tests, config | Clear modular boundaries and documentation |
| OOP design | Classes mix responsibilities | Classes own focused behavior | Strong encapsulation and composition choices |
| Testing | Few happy-path tests | Tests success and failures | Uses fixtures, fakes, and boundary tests |
| Type hints | Partial annotations | Public interfaces typed | Precise generic types and protocols |
| Error handling | Broad catches or unclear errors | Domain exceptions used | Clear boundaries and chained causes |
| API design | Raw HTTP details leak to callers | Domain client methods exist | Safe pagination, retries, and clean lifecycle |
| Security | Secrets may be exposed | Env configuration and ignored files | Safe logs, token discipline, release checks |

---

# 10. Common Learner Problems and Trainer Responses

| Learner Problem | Likely Cause | Trainer Response |
|---|---|---|
| `ModuleNotFoundError` | Environment inactive or package not installed | Activate `.venv`, run editable install |
| `pytest` command differs from expected | Global tool used instead of environment tool | Use `python -m pytest` |
| `mypy` errors seem confusing | Missing or inaccurate annotations | Read error from file and line; fix contract |
| Tests affect each other | Shared mutable state | Use function-scoped fixtures |
| Generator returns nothing second time | Iterator was consumed | Recreate generator or materialize into list |
| `True` accepted as page number | `bool` is subclass of `int` | Explicitly reject booleans |
| API token appears in output | Unsafe debug logging | Remove it; rotate token if real |
| Circular import | Internal modules import from package `__init__` | Import from defining module directly |
| Retry duplicates operations | Retrying unsafe writes | Limit retries to idempotent operations |
| Learner copies code without understanding | Pace is too fast | Pause for prediction and explanation questions |

---

# 11. Recommended Breakpoints

Use regular breaks during live sessions.

| After | Recommended Activity |
|---|---|
| Primer 1 | Confirm every learner has an active virtual environment |
| Part 1 | Learners independently add one `Book` validation rule |
| Part 2 | Ask learners to choose inheritance or composition for a scenario |
| Part 4 | Have learners explain generator consumption |
| Part 6 | Review decorator order with a prediction exercise |
| Part 7 | Run first complete test suite |
| Part 8 | Run first complete `mypy` check |
| Part 10 | Test transport without real network access |
| Part 12 | Build wheel and conduct release review |

---

# 12. Final Capstone Extension Options

Assign one extension per learner or team.

## Beginner Extension

### Add `delete_project()`

Requirements:

- Validate project ID.
- Send `DELETE`.
- Handle `204 No Content`.
- Add fake transport tests.
- Document exceptions.

## Intermediate Extension

### Add `update_project()`

Requirements:

- Validate at least one update field.
- Use `PATCH` or `PUT` according to defined API contract.
- Parse response into `Project`.
- Add tests for blank input and invalid payloads.

## Advanced Extension

### Add Rate-Limit Support

Requirements:

- Parse rate-limit headers.
- Create immutable `RateLimitInfo`.
- Expose latest response rate-limit information safely.
- Add tests for valid, missing, and invalid headers.

## Advanced Extension

### Add Async Client Variant

Requirements:

- Use an async transport abstraction.
- Support `async with`.
- Add async tests.
- Preserve model, config, and exception boundaries.

---

# 13. Trainer Closing Script

Use or adapt this closing message:

> You now have more than a set of Python syntax tricks. You have a process for building software: isolate dependencies, validate boundaries, model concepts clearly, test behavior, type-check contracts, protect secrets, and package work so others can use it confidently.  
>
> The next step is repetition. Build a smaller package from memory, add one meaningful feature, write tests first when possible, and keep improving the clarity of your code.

---

# 14. Final Trainer Checklist

- [ ] Learners can activate a virtual environment.
- [ ] Learners can run `pytest` and `mypy`.
- [ ] Learners understand class versus instance state.
- [ ] Learners can explain inheritance versus composition.
- [ ] Learners can write a generator and context manager.
- [ ] Learners can explain callback and decorator behavior.
- [ ] Learners can use fixtures and fake dependencies.
- [ ] Learners can identify a domain error boundary.
- [ ] Learners can explain safe retry behavior.
- [ ] Learners can build and test a wheel.
- [ ] Learners completed a capstone extension.
- [ ] Learners have a next-project plan.
