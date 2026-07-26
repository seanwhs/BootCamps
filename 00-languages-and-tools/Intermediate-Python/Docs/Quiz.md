# Pythonic Craftsmanship  
## Quiz Bank with Answer Keys

This quiz bank covers Primers 1–5, Parts 0–12, and the `craftapi` capstone.

Formats include:

- Multiple choice
- True/false
- Short answer
- Code reading
- Applied design questions

---

# Section 1: Environment, Terminal, Git, and Debugging

## Questions

### 1. Multiple Choice

Why is a virtual environment useful?

A. It makes Python run faster.  
B. It isolates project dependencies from other Python projects.  
C. It encrypts source code.  
D. It automatically uploads code to GitHub.

---

### 2. Short Answer

Why is this command preferred?

```bash
python -m pip install pytest
```

instead of:

```bash
pip install pytest
```

---

### 3. True or False

The `.venv/` folder should usually be committed to Git.

---

### 4. Multiple Choice

Which command is most reliable for running `pytest` inside the active virtual environment?

A.

```bash
pytest
```

B.

```bash
pip pytest
```

C.

```bash
python -m pytest
```

D.

```bash
python pytest.py
```

---

### 5. Short Answer

What is the difference between an absolute path and a relative path?

---

### 6. Multiple Choice

What does this command do?

```bash
cd ..
```

A. Deletes the current directory  
B. Moves to the parent directory  
C. Creates a new directory  
D. Lists hidden files

---

### 7. True or False

`Path.cwd()` always identifies the physical location of the Python script currently running.

---

### 8. Multiple Choice

Which Git command shows unstaged changes?

A.

```bash
git log
```

B.

```bash
git diff
```

C.

```bash
git add
```

D.

```bash
git merge
```

---

### 9. Multiple Choice

Which Git command shows changes that have already been staged for the next commit?

A.

```bash
git diff --staged
```

B.

```bash
git status --commit
```

C.

```bash
git log --staged
```

D.

```bash
git merge --staged
```

---

### 10. Short Answer

Read the traceback from which direction first, and why?

```text
Traceback (most recent call last):
  ...
ValueError: Project name cannot be blank.
```

---

### 11. Multiple Choice

Which exception is most appropriate when a value has the correct type but invalid content?

A. `TypeError`  
B. `ValueError`  
C. `KeyError`  
D. `ImportError`

---

### 12. Multiple Choice

What does `repr(value)` help reveal that `print(value)` can hide?

A. Network latency  
B. Exact developer-facing representation, including whitespace or escape characters  
C. Package version  
D. Git commit history

---

## Answer Key: Section 1

1. **B** — It isolates dependencies for a single project.  
2. It ensures `pip` belongs to the same active Python interpreter being used to run the project.  
3. **False** — `.venv/` is local generated environment content and should be ignored.  
4. **C** — `python -m pytest`.  
5. An absolute path starts from the file-system root; a relative path starts from the current working directory.  
6. **B** — Moves to the parent directory.  
7. **False** — `Path.cwd()` is the current terminal working directory. Use `Path(__file__).resolve()` for the script location.  
8. **B** — `git diff`.  
9. **A** — `git diff --staged`.  
10. Start at the bottom because it gives the final exception type and message; then trace upward to find the call path.  
11. **B** — `ValueError`.  
12. **B** — It shows the exact representation, including quotes, whitespace, and escape characters.  

---

# Section 2: Python Syntax and Functions

## Questions

### 13. Multiple Choice

Which type annotation correctly describes an optional description?

A.

```python
description: str
```

B.

```python
description: str | None
```

C.

```python
description: bool
```

D.

```python
description: list[str]
```

---

### 14. Code Reading

What does this print?

```python
name = " Website Redesign "
print(name.strip())
```

---

### 15. Multiple Choice

What is the result of this expression?

```python
bool([])
```

A. `True`  
B. `False`  
C. `None`  
D. Raises `TypeError`

---

### 16. Short Answer

What is the difference between these two checks?

```python
if description is None:
```

```python
if not description:
```

---

### 17. Code Reading

What does this produce?

```python
project_ids = {"project-001", "project-001", "project-002"}
print(len(project_ids))
```

---

### 18. Multiple Choice

Which collection is most appropriate for fast lookup by project ID?

A. `list`  
B. `tuple`  
C. `dict`  
D. `set`

---

### 19. Code Writing

Write a function signature for a function that receives a project ID and returns either a `Project` or `None`.

---

### 20. True or False

A function annotated as returning `None` should return a meaningful value such as a string.

---

## Answer Key: Section 2

13. **B** — `description: str | None`.  
14. It prints:

```text
Website Redesign
```

15. **B** — An empty list is falsey.  
16. `is None` checks specifically for missing value `None`; `not description` is true for `None`, empty strings, empty lists, zero, and other falsey values.  
17. It prints:

```text
2
```

18. **C** — `dict`.  
19. Example:

```python
def find_project(project_id: str) -> Project | None:
    ...
```

20. **False** — A `None` return annotation means the function returns no meaningful value.  

---

# Section 3: OOP Foundations

## Questions

### 21. Short Answer

What is the difference between a class and an instance?

---

### 22. Multiple Choice

What does `self` represent in an instance method?

A. The entire Python program  
B. The current class definition  
C. The specific object receiving the method call  
D. A global variable

---

### 23. Code Reading

What is wrong with this design?

```python
class Library:
    books: list[str] = []
```

---

### 24. Multiple Choice

Which is the safest way to expose checkout state?

A.

```python
book._is_checked_out = True
```

B.

```python
book.is_checked_out = True
```

C.

```python
book.check_out()
```

D.

```python
Book.is_checked_out = True
```

---

### 25. Short Answer

What is encapsulation?

---

### 26. Code Writing

Write a read-only property named `is_checked_out` that returns an internal `_is_checked_out` boolean.

---

### 27. Multiple Choice

Which is a class attribute?

A.

```python
self.title = title
```

B.

```python
total_books_created = 0
```

C.

```python
def check_out(self) -> None:
```

D.

```python
@property
```

---

### 28. True or False

A class method receives `self` as its first parameter.

---

## Answer Key: Section 3

21. A class is a reusable blueprint; an instance is one concrete object created from that blueprint.  
22. **C** — The specific object receiving the method call.  
23. The list is shared by every `Library` instance. It should usually be created inside `__init__`.  
24. **C** — `book.check_out()` preserves object rules and validation.  
25. Encapsulation means an object controls access to and modification of its internal state through clear public methods or properties.  
26. Example:

```python
@property
def is_checked_out(self) -> bool:
    return self._is_checked_out
```

27. **B** — `total_books_created = 0`.  
28. **False** — A class method receives `cls`; an instance method receives `self`.  

---

# Section 4: Inheritance, Composition, and Dunder Methods

## Questions

### 29. Multiple Choice

Which statement best describes inheritance?

A. A library contains books.  
B. A book is a lending item.  
C. A project has an API token.  
D. A function uses a dictionary.

---

### 30. Short Answer

When should composition usually be preferred over inheritance?

---

### 31. Multiple Choice

What is `super()` commonly used for?

A. Deleting a parent object  
B. Calling behavior from a parent class  
C. Creating a global variable  
D. Preventing type checking

---

### 32. Match the Syntax to the Dunder Method

| Syntax | Dunder Method |
|---|---|
| `print(item)` |  |
| `repr(item)` |  |
| `len(library)` |  |
| `for item in library:` |  |
| `"BOOK-001" in library` |  |

Choices:

```text
__contains__
__iter__
__len__
__repr__
__str__
```

---

### 33. True or False

If you define `__eq__` for value equality and want objects in sets, `__hash__` must remain consistent with equality.

---

### 34. Code Reading

What should this rule guarantee?

```python
if first == second:
    assert hash(first) == hash(second)
```

---

### 35. Multiple Choice

Why might `Book` and `DigitalBook` with the same text identifier be considered unequal?

A. Python cannot compare subclasses.  
B. They represent different concrete resource types.  
C. Strings cannot be compared.  
D. Hashing is impossible.

---

## Answer Key: Section 4

29. **B** — A book is a lending item.  
30. Prefer composition when one component “has a” dependency or behavior rather than genuinely “is a” specialized form of another type.  
31. **B** — Calling or reusing parent-class behavior.  
32.  

| Syntax | Dunder Method |
|---|---|
| `print(item)` | `__str__` |
| `repr(item)` | `__repr__` |
| `len(library)` | `__len__` |
| `for item in library:` | `__iter__` |
| `"BOOK-001" in library` | `__contains__` |

33. **True**.  
34. Equal objects must produce equal hashes; this is required for correct use in sets and dictionaries.  
35. **B** — They can represent different kinds of domain resources even if identifiers happen to match.  

---

# Section 5: Collections, Comprehensions, and Iteration

## Questions

### 36. Code Writing

Write a list comprehension that returns names of active projects.

Assume:

```python
projects: list[Project]
```

---

### 37. Code Writing

Write a dictionary comprehension mapping project IDs to `Project` objects.

---

### 38. Multiple Choice

Which tool is best for counting projects by status?

A. `deque`  
B. `Counter`  
C. `Path`  
D. `Protocol`

---

### 39. Multiple Choice

Which tool is best for grouping projects by status into lists?

A. `defaultdict(list)`  
B. `Counter`  
C. `set`  
D. `tuple`

---

### 40. True or False

A generator can usually be consumed repeatedly without recreation.

---

### 41. Code Reading

What does this print?

```python
values = (number * 2 for number in range(3))

print(list(values))
print(list(values))
```

---

### 42. Short Answer

Why is this often more efficient than a list comprehension?

```python
any(project.status == "archived" for project in projects)
```

---

### 43. Multiple Choice

What does `all([])` return?

A. `True`  
B. `False`  
C. `None`  
D. Raises `StopIteration`

---

### 44. Code Writing

Write a generator function that yields only active projects.

---

### 45. Multiple Choice

Which `itertools` function combines several iterables into one lazy stream?

A. `islice`  
B. `chain`  
C. `repeat`  
D. `filterfalse`

---

## Answer Key: Section 5

36. Example:

```python
active_names = [
    project.name
    for project in projects
    if project.status == "active"
]
```

37. Example:

```python
projects_by_id = {
    project.id: project
    for project in projects
}
```

38. **B** — `Counter`.  
39. **A** — `defaultdict(list)`.  
40. **False** — Generators and iterators are generally consumed once.  
41. It prints:

```text
[0, 2, 4]
[]
```

42. `any()` can stop as soon as it finds the first matching project and does not need to build a complete list.  
43. **A** — `True`. There is no false value in an empty iterable.  
44. Example:

```python
from collections.abc import Iterator


def iter_active_projects(
    projects: list[Project],
) -> Iterator[Project]:
    for project in projects:
        if project.status == "active":
            yield project
```

45. **B** — `chain`.  

---

# Section 6: Context Managers, Callbacks, and Decorators

## Questions

### 46. Short Answer

What problem does a context manager solve?

---

### 47. Multiple Choice

What does returning `False` from `__exit__()` usually mean?

A. Repeat the `with` block  
B. Suppress exceptions  
C. Do not suppress exceptions  
D. Delete the context object

---

### 48. Multiple Choice

What is a callback?

A. A variable that cannot change  
B. A function passed to code that will call it later  
C. A Python package installer  
D. A built-in exception

---

### 49. Short Answer

What is a closure?

---

### 50. Multiple Choice

Why should decorators normally use `functools.wraps`?

A. It speeds up all functions.  
B. It preserves original function metadata.  
C. It makes functions asynchronous.  
D. It validates JSON.

---

### 51. Code Reading

What does this decorator syntax mean?

```python
@log_calls
def get_project(project_id: str) -> Project:
    ...
```

---

### 52. Multiple Choice

Which exception type should a retry decorator normally avoid catching?

A. A known temporary network exception  
B. A narrow custom transient error  
C. `Exception` for every failure  
D. A documented timeout exception

---

### 53. True or False

Retrying a POST request is always safe because HTTP will prevent duplicate resources.

---

## Answer Key: Section 6

46. It guarantees setup and cleanup around a block, including cleanup when exceptions occur.  
47. **C** — Do not suppress exceptions.  
48. **B** — A function supplied for later invocation.  
49. A nested function that remembers values from the scope in which it was created.  
50. **B** — It preserves name, docstring, annotations, and other metadata.  
51. It is equivalent to:

```python
def get_project(project_id: str) -> Project:
    ...

get_project = log_calls(get_project)
```

52. **C** — Catching every `Exception` can retry programming errors and unsafe failures.  
53. **False** — Retrying POST can duplicate side effects unless the server supports idempotency protection.  

---

# Section 7: Testing and Type Checking

## Questions

### 54. Multiple Choice

What is the main purpose of a `pytest` fixture?

A. Delete project files  
B. Reuse test setup  
C. Build a Python wheel  
D. Encrypt secrets

---

### 55. Code Writing

Write a `pytest` assertion that verifies a blank project name raises `ValueError`.

---

### 56. Multiple Choice

Which fixture should be used for isolated temporary file tests?

A. `tmp_path`  
B. `monkeypatch`  
C. `capsys`  
D. `request`

---

### 57. Short Answer

Why should unit tests avoid calling a real external API?

---

### 58. Multiple Choice

What does `mypy` primarily check?

A. Runtime network speed  
B. Type contract consistency  
C. Git branch names  
D. Python bytecode optimization

---

### 59. Code Writing

Write a type annotation for a function that receives an iterable of projects and yields project IDs one at a time.

---

### 60. Short Answer

What is a `Protocol` useful for?

---

### 61. True or False

`Any` provides strong static safety because `mypy` checks every operation performed on it.

---

## Answer Key: Section 7

54. **B** — Reusable test setup.  
55. Example:

```python
import pytest


with pytest.raises(ValueError, match="cannot be blank"):
    normalize_project_name("   ")
```

56. **A** — `tmp_path`.  
57. Real APIs make tests slow, unreliable, credential-dependent, potentially destructive, and sensitive to network or server outages.  
58. **B** — Type contract consistency.  
59. Example:

```python
from collections.abc import Iterable, Iterator


def iter_project_ids(
    projects: Iterable[Project],
) -> Iterator[str]:
    for project in projects:
        yield project.id
```

60. It defines required behavior structurally, allowing implementations such as production and fake transports without requiring inheritance.  
61. **False** — `Any` disables much static checking.  

---

# Section 8: API Client Architecture

## Questions

### 62. Match the Module to Its Responsibility

| Module | Responsibility |
|---|---|
| `config.py` |  |
| `models.py` |  |
| `transport.py` |  |
| `client.py` |  |
| `exceptions.py` |  |

Choices:

```text
High-level domain operations and pagination
Configuration validation and environment loading
HTTP mechanics and error translation
Validated immutable API data models
Domain-specific failure types
```

---

### 63. Multiple Choice

Why should API JSON be validated before becoming a `Project` model?

A. JSON is always invalid.  
B. External data may be malformed, incomplete, or changed unexpectedly.  
C. Python cannot read dictionaries.  
D. It makes HTTP requests faster.

---

### 64. Multiple Choice

Which HTTP status should normally become `CraftApiNotFoundError`?

A. 200  
B. 401  
C. 404  
D. 503

---

### 65. Short Answer

Why should an API token not be included in logs or exception messages?

---

### 66. Code Reading

Why is this safer than string concatenation?

```python
encoded_project_id = quote(project_id, safe="")
url = f"{base_url}/projects/{encoded_project_id}"
```

---

### 67. Multiple Choice

Why does `CraftApiClient` accept an optional `Transport` dependency?

A. To avoid type hints  
B. To support injection of fake transports for tests and alternate implementations  
C. To remove all error handling  
D. To prevent configuration validation

---

### 68. True or False

A `404` response usually means the network connection failed before reaching the server.

---

## Answer Key: Section 8

62.  

| Module | Responsibility |
|---|---|
| `config.py` | Configuration validation and environment loading |
| `models.py` | Validated immutable API data models |
| `transport.py` | HTTP mechanics and error translation |
| `client.py` | High-level domain operations and pagination |
| `exceptions.py` | Domain-specific failure types |

63. **B** — External data can be malformed, incomplete, or inconsistent with assumptions.  
64. **C** — 404.  
65. Tokens are credentials; exposing them in logs can allow unauthorized access and create a security incident.  
66. It percent-encodes spaces, slashes, and reserved characters so an identifier cannot alter the intended URL path.  
67. **B** — It enables dependency injection, fakes, and alternate transport implementations.  
68. **False** — A 404 is an HTTP response from the server, meaning the server was reached.  

---

# Section 9: Pagination, Retries, and Production Readiness

## Questions

### 69. Short Answer

What makes `iter_projects()` lazy?

---

### 70. Multiple Choice

When does a generator function usually begin executing its body?

A. At import time  
B. When the generator object is created  
C. When the generator is consumed with `next()` or iteration  
D. Only after `close()`

---

### 71. Multiple Choice

Why does the client track visited page numbers?

A. To make page numbers alphabetical  
B. To prevent a malformed API response from causing an infinite pagination loop  
C. To reduce JSON size  
D. To remove authorization headers

---

### 72. True or False

`True` should usually be accepted as a valid page number because it is an `int` subclass.

---

### 73. Multiple Choice

Which request is safest to retry by default after a temporary network failure?

A. `POST /payments`  
B. `POST /projects`  
C. `GET /projects/project-123`  
D. `POST /password-reset`

---

### 74. Short Answer

What is exponential backoff?

---

### 75. Multiple Choice

Which data should be safe to log during retry behavior?

A. Authorization header  
B. API token  
C. HTTP method, URL, attempt number, and delay  
D. Entire request body without review

---

### 76. Short Answer

Why should a wheel be installed and tested in a clean virtual environment before release?

---

## Answer Key: Section 9

69. It returns a generator; requests are made only when the caller consumes values through `next()` or iteration.  
70. **C** — When consumed.  
71. **B** — To prevent an infinite loop caused by repeated page references.  
72. **False** — Even though `bool` subclasses `int`, it should be explicitly rejected for page-number validation.  
73. **C** — A GET request is normally idempotent and safe to retry.  
74. A retry delay strategy where the delay increases after each failed attempt, commonly doubling until a maximum limit.  
75. **C** — Safe operational metadata.  
76. Editable installs can hide packaging problems; a clean wheel installation verifies users can install and import the actual built artifact.  

---

# Section 10: Applied Design Questions

## Questions

### 77. Scenario

You need to expose a collection of projects from a class, but callers must not be able to mutate the internal list.

Which return type is a good choice?

A. Return the internal list directly  
B. Return a tuple snapshot  
C. Return `None`  
D. Return the class itself

---

### 78. Scenario

A remote API response returns:

```json
{
  "id": 123,
  "name": null,
  "status": "",
  "created_at": "sometime"
}
```

What should happen?

---

### 79. Scenario

A test needs to verify that a client sends an authorization header but must not perform a real network request.

What should the test use?

---

### 80. Scenario

A team wants to add retry behavior to every request automatically, including project creation.

What design concern should you raise?

---

### 81. Scenario

A learner writes:

```python
except Exception:
    return None
```

around an API call.

Name two problems with this pattern.

---

### 82. Scenario

A package method internally uses a dictionary lookup and gets a `KeyError`. What is the preferred public API behavior?

---

### 83. Scenario

A method accepts `page_size: int`, but external JSON or callers may provide `True`.

What validation check is appropriate?

---

### 84. Scenario

You need a class that has a name and contains many `Book` objects. Should it inherit from `Book`?

Explain.

---

## Answer Key: Section 10

77. **B** — Return a tuple snapshot.  
78. The model boundary should reject it with a validation error because required fields have invalid types or content and the timestamp is malformed.  
79. Use a fake transport or mock transport implementation that records the request and returns a controlled `HttpResponse`.  
80. Retrying writes such as POST can duplicate resources if the server completed the original request but the client did not receive the response. Use idempotency keys or avoid automatic retry.  
81. It hides expected and unexpected failures, and it can swallow programming bugs such as `AttributeError` or `TypeError`.  
82. Translate the internal `KeyError` into a domain-specific exception such as `ItemNotFoundError`, preserving the original cause with `raise ... from error`.  
83. Example:

```python
if isinstance(page_size, bool) or not isinstance(page_size, int):
    raise TypeError("Page size must be an integer.")
```

84. No. A library **has** books; it is not a kind of book. Use composition by storing books in an internal collection.  

---

# Optional Practical Grading Guide

| Score Range | Interpretation |
|---:|---|
| 0–35 | Review primers and core syntax before advancing |
| 36–55 | Basic understanding; revisit OOP, testing, and typing |
| 56–68 | Strong intermediate foundation |
| 69–78 | Ready to build and extend the capstone independently |
| 79–84 | Strong mastery of course concepts and production practices |
