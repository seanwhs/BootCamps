# Primer 3: Python Syntax Refresh for Intermediate Learners

This series assumes you know basic Python syntax, but it is useful to refresh the tools you will use constantly in the later parts.

This primer covers:

- Variables and common built-in types
- Conditionals
- Loops
- Functions
- Lists and dictionaries
- Imports
- Exceptions
- Basic type hints
- F-strings
- Truthiness

It is not a complete Python course. It is a practical refresher designed to make the main OOP, package, testing, and API-client lessons easier to follow.

---

## What You Will Build

Create this practice file:

```text
pythonic-craftsmanship/
└── scripts/
    └── syntax_refresh.py
```

It will contain working examples of the concepts in this primer.

---

# Step 1: Variables and Common Data Types

## The Target

We are learning how Python stores values in variables.

## The Concept

A variable is a label attached to a value.

Think of it as a labeled storage box:

```python
project_name = "Website Redesign"
```

The label is:

```text
project_name
```

The stored value is:

```text
"Website Redesign"
```

Python determines the value’s type at runtime.

## The Implementation

### `scripts/syntax_refresh.py`

```python
"""Refresh essential Python syntax used throughout this tutorial series."""

from __future__ import annotations


def demonstrate_basic_values() -> None:
    """Print examples of common Python value types."""
    project_name = "Website Redesign"
    project_count = 3
    timeout_seconds = 10.0
    is_active = True
    description = None

    print(f"Project name: {project_name}")
    print(f"Project count: {project_count}")
    print(f"Timeout: {timeout_seconds}")
    print(f"Is active: {is_active}")
    print(f"Description: {description}")

    print("\nValue types:")
    print(f"project_name: {type(project_name).__name__}")
    print(f"project_count: {type(project_count).__name__}")
    print(f"timeout_seconds: {type(timeout_seconds).__name__}")
    print(f"is_active: {type(is_active).__name__}")
    print(f"description: {type(description).__name__}")


def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected output:

```text
Project name: Website Redesign
Project count: 3
Timeout: 10.0
Is active: True
Description: None

Value types:
project_name: str
project_count: int
timeout_seconds: float
is_active: bool
description: NoneType
```

The five common types are:

| Type | Example | Meaning |
|---|---|---|
| `str` | `"Website Redesign"` | Text |
| `int` | `3` | Whole number |
| `float` | `10.0` | Decimal number |
| `bool` | `True` | True/false value |
| `None` | `None` | Intentional absence of a value |

---

# Step 2: Strings and F-Strings

## The Target

We are adding string formatting examples.

## The Concept

A string is text enclosed in quotes:

```python
project_name = "Website Redesign"
```

Python supports single or double quotes:

```python
single_quotes = 'hello'
double_quotes = "hello"
```

Use **f-strings** to insert values into text:

```python
message = f"Project name: {project_name}"
```

The `f` before the opening quote means:

> Evaluate expressions inside `{}` and insert their values.

## The Implementation

Add this function above `main()` in `scripts/syntax_refresh.py`.

### `scripts/syntax_refresh.py` — add this function

```python
def demonstrate_strings() -> None:
    """Print common string operations and f-string formatting."""
    project_name = " Website Redesign "
    cleaned_project_name = project_name.strip()
    normalized_project_name = cleaned_project_name.casefold()

    print("\nString examples:")
    print(f"Original value: {project_name!r}")
    print(f"Cleaned value: {cleaned_project_name!r}")
    print(f"Normalized value: {normalized_project_name!r}")
    print(f"Name length: {len(cleaned_project_name)}")
    print(f"Contains 'Website': {'Website' in cleaned_project_name}")
```

Update `main()`.

### `scripts/syntax_refresh.py` — replace `main()`

```python
def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected additional output:

```text
String examples:
Original value: ' Website Redesign '
Cleaned value: 'Website Redesign'
Normalized value: 'website redesign'
Name length: 16
Contains 'Website': True
```

Important string methods:

| Method | Example | Result |
|---|---|---|
| `.strip()` | `" text ".strip()` | `"text"` |
| `.lower()` | `"ACTIVE".lower()` | `"active"` |
| `.casefold()` | `"ACTIVE".casefold()` | `"active"` |
| `.startswith()` | `"project-1".startswith("project-")` | `True` |
| `.endswith()` | `"report.json".endswith(".json")` | `True` |
| `.split()` | `"a,b,c".split(",")` | `["a", "b", "c"]` |

The `!r` in an f-string asks Python to show the value’s representation. For strings, this includes quotation marks, making whitespace easier to see.

---

# Step 3: Lists, Dictionaries, Tuples, and Sets

## The Target

We are adding examples of Python’s most common collection types.

## The Concept

Collections hold multiple values.

| Collection | Main purpose |
|---|---|
| `list` | Ordered, mutable sequence |
| `tuple` | Ordered, usually immutable sequence |
| `dict` | Key-value lookup |
| `set` | Unique values and fast membership checks |

Think of them as different storage containers:

- A list is a numbered shelf.
- A tuple is a sealed numbered shelf.
- A dictionary is a filing cabinet indexed by labels.
- A set is a basket that automatically removes duplicates.

## The Implementation

Add this function above `main()`.

### `scripts/syntax_refresh.py` — add this function

```python
def demonstrate_collections() -> None:
    """Print examples of lists, dictionaries, tuples, and sets."""
    project_names = [
        "Website Redesign",
        "Mobile Application",
        "API Modernization",
    ]

    project_by_id = {
        "project-001": "Website Redesign",
        "project-002": "Mobile Application",
    }

    supported_statuses = ("active", "archived", "paused")

    unique_tags = {
        "python",
        "api",
        "python",
        "testing",
    }

    print("\nCollection examples:")
    print(f"First project: {project_names[0]}")
    print(f"Project count: {len(project_names)}")
    print(f"Project project-002: {project_by_id['project-002']}")
    print(f"Supported statuses: {supported_statuses}")
    print(f"Unique tags: {sorted(unique_tags)}")
```

Update `main()`.

### `scripts/syntax_refresh.py` — replace `main()`

```python
def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
    demonstrate_collections()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected additional output:

```text
Collection examples:
First project: Website Redesign
Project count: 3
Project project-002: Mobile Application
Supported statuses: ('active', 'archived', 'paused')
Unique tags: ['api', 'python', 'testing']
```

---

# Step 4: Conditionals and Truthiness

## The Target

We are adding `if`, `elif`, and `else` examples.

## The Concept

A conditional controls which code runs.

```python
if condition:
    ...
elif another_condition:
    ...
else:
    ...
```

Python also treats some values as false in conditionals:

| Value | Truthiness |
|---|---|
| `False` | False |
| `None` | False |
| `0` | False |
| `""` | False |
| `[]` | False |
| `{}` | False |
| `set()` | False |

Most other values are true.

## The Implementation

Add this function above `main()`.

### `scripts/syntax_refresh.py` — add this function

```python
def demonstrate_conditionals() -> None:
    """Print examples of conditional logic and truthy values."""
    project_status = "active"
    description = ""

    print("\nConditional examples:")

    if project_status == "active":
        print("The project is active.")
    elif project_status == "archived":
        print("The project is archived.")
    else:
        print("The project has another status.")

    if description:
        print(f"Description: {description}")
    else:
        print("No description was supplied.")
```

Update `main()`.

### `scripts/syntax_refresh.py` — replace `main()`

```python
def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
    demonstrate_collections()
    demonstrate_conditionals()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected additional output:

```text
Conditional examples:
The project is active.
No description was supplied.
```

Use explicit checks when the distinction matters.

For example:

```python
if description is None:
    print("Description was omitted.")
```

is different from:

```python
if not description:
    print("Description is empty, missing, zero, or otherwise false.")
```

---

# Step 5: Loops

## The Target

We are adding `for` loop examples.

## The Concept

A `for` loop processes values from an iterable one at a time.

```python
for project_name in project_names:
    print(project_name)
```

An **iterable** is a value that can produce items one at a time. Lists, tuples, dictionaries, strings, and sets are all iterable.

## The Implementation

Add this function above `main()`.

### `scripts/syntax_refresh.py` — add this function

```python
def demonstrate_loops() -> None:
    """Print examples of looping through lists and dictionaries."""
    project_names = [
        "Website Redesign",
        "Mobile Application",
        "API Modernization",
    ]

    project_statuses = {
        "project-001": "active",
        "project-002": "archived",
    }

    print("\nLoop examples:")

    for position, project_name in enumerate(project_names, start=1):
        print(f"{position}. {project_name}")

    print("\nProject statuses:")

    for project_id, status in project_statuses.items():
        print(f"{project_id}: {status}")
```

Update `main()`.

### `scripts/syntax_refresh.py` — replace `main()`

```python
def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
    demonstrate_collections()
    demonstrate_conditionals()
    demonstrate_loops()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected additional output:

```text
Loop examples:
1. Website Redesign
2. Mobile Application
3. API Modernization

Project statuses:
project-001: active
project-002: archived
```

`enumerate()` gives both a position and a value.

```python
for position, project_name in enumerate(project_names, start=1):
    ...
```

This is clearer than manually maintaining a counter.

---

# Step 6: Functions and Return Values

## The Target

We are adding reusable functions with parameters and return values.

## The Concept

A function groups instructions behind a meaningful name.

```python
def normalize_project_name(name: str) -> str:
    return name.strip()
```

The function receives an input parameter:

```python
name: str
```

and returns a string:

```python
-> str
```

Type hints describe the expected contract. They do not replace runtime validation.

## The Implementation

Add these functions above `main()`.

### `scripts/syntax_refresh.py` — add these functions

```python
def normalize_project_name(name: str) -> str:
    """Remove surrounding whitespace from a project name."""
    cleaned_name = name.strip()

    if not cleaned_name:
        raise ValueError("Project name cannot be blank.")

    return cleaned_name


def build_project_label(project_id: str, name: str) -> str:
    """Build a readable label from a project identifier and name."""
    normalized_project_id = project_id.strip()
    normalized_name = normalize_project_name(name)

    return f"{normalized_project_id}: {normalized_name}"


def demonstrate_functions() -> None:
    """Call reusable functions and print their returned values."""
    print("\nFunction examples:")

    label = build_project_label(
        project_id="project-001",
        name=" Website Redesign ",
    )

    print(label)

    try:
        normalize_project_name("   ")
    except ValueError as error:
        print(f"Expected error: {error}")
```

Update `main()`.

### `scripts/syntax_refresh.py` — replace `main()`

```python
def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
    demonstrate_collections()
    demonstrate_conditionals()
    demonstrate_loops()
    demonstrate_functions()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected additional output:

```text
Function examples:
project-001: Website Redesign
Expected error: Project name cannot be blank.
```

---

# Step 7: Imports

## The Target

We are learning the import statement used at the top of Python files.

## The Concept

An import gives your program access to code from another module.

For example:

```python
from pathlib import Path
```

means:

> Import the `Path` class from Python’s built-in `pathlib` module.

Later, you will import from your own packages:

```python
from craftapi import CraftApiClient
```

Imports normally belong near the top of a file.

## The Implementation

Add this import near the existing imports.

### `scripts/syntax_refresh.py` — update imports

```python
from __future__ import annotations

from pathlib import Path
```

Add this function above `main()`.

### `scripts/syntax_refresh.py` — add this function

```python
def demonstrate_imports() -> None:
    """Use pathlib.Path from Python's standard library."""
    current_directory = Path.cwd()

    print("\nImport examples:")
    print(f"Current directory name: {current_directory.name}")
```

Update `main()`.

### `scripts/syntax_refresh.py` — replace `main()`

```python
def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
    demonstrate_collections()
    demonstrate_conditionals()
    demonstrate_loops()
    demonstrate_functions()
    demonstrate_imports()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

Expected final output includes:

```text
Import examples:
Current directory name: pythonic-craftsmanship
```

The exact folder name depends on the directory from which you run the program.

---

# Step 8: Complete Final File

## The Target

We are consolidating every example into one complete, copy-pasteable script.

## The Concept

When learning, it is useful to build code gradually. When reviewing, it is useful to have the complete final file in one place.

## The Implementation

### `scripts/syntax_refresh.py`

```python
"""Refresh essential Python syntax used throughout this tutorial series."""

from __future__ import annotations

from pathlib import Path


def demonstrate_basic_values() -> None:
    """Print examples of common Python value types."""
    project_name = "Website Redesign"
    project_count = 3
    timeout_seconds = 10.0
    is_active = True
    description = None

    print(f"Project name: {project_name}")
    print(f"Project count: {project_count}")
    print(f"Timeout: {timeout_seconds}")
    print(f"Is active: {is_active}")
    print(f"Description: {description}")

    print("\nValue types:")
    print(f"project_name: {type(project_name).__name__}")
    print(f"project_count: {type(project_count).__name__}")
    print(f"timeout_seconds: {type(timeout_seconds).__name__}")
    print(f"is_active: {type(is_active).__name__}")
    print(f"description: {type(description).__name__}")


def demonstrate_strings() -> None:
    """Print common string operations and f-string formatting."""
    project_name = " Website Redesign "
    cleaned_project_name = project_name.strip()
    normalized_project_name = cleaned_project_name.casefold()

    print("\nString examples:")
    print(f"Original value: {project_name!r}")
    print(f"Cleaned value: {cleaned_project_name!r}")
    print(f"Normalized value: {normalized_project_name!r}")
    print(f"Name length: {len(cleaned_project_name)}")
    print(f"Contains 'Website': {'Website' in cleaned_project_name}")


def demonstrate_collections() -> None:
    """Print examples of lists, dictionaries, tuples, and sets."""
    project_names = [
        "Website Redesign",
        "Mobile Application",
        "API Modernization",
    ]

    project_by_id = {
        "project-001": "Website Redesign",
        "project-002": "Mobile Application",
    }

    supported_statuses = ("active", "archived", "paused")

    unique_tags = {
        "python",
        "api",
        "python",
        "testing",
    }

    print("\nCollection examples:")
    print(f"First project: {project_names[0]}")
    print(f"Project count: {len(project_names)}")
    print(f"Project project-002: {project_by_id['project-002']}")
    print(f"Supported statuses: {supported_statuses}")
    print(f"Unique tags: {sorted(unique_tags)}")


def demonstrate_conditionals() -> None:
    """Print examples of conditional logic and truthy values."""
    project_status = "active"
    description = ""

    print("\nConditional examples:")

    if project_status == "active":
        print("The project is active.")
    elif project_status == "archived":
        print("The project is archived.")
    else:
        print("The project has another status.")

    if description:
        print(f"Description: {description}")
    else:
        print("No description was supplied.")


def demonstrate_loops() -> None:
    """Print examples of looping through lists and dictionaries."""
    project_names = [
        "Website Redesign",
        "Mobile Application",
        "API Modernization",
    ]

    project_statuses = {
        "project-001": "active",
        "project-002": "archived",
    }

    print("\nLoop examples:")

    for position, project_name in enumerate(project_names, start=1):
        print(f"{position}. {project_name}")

    print("\nProject statuses:")

    for project_id, status in project_statuses.items():
        print(f"{project_id}: {status}")


def normalize_project_name(name: str) -> str:
    """Remove surrounding whitespace from a project name."""
    cleaned_name = name.strip()

    if not cleaned_name:
        raise ValueError("Project name cannot be blank.")

    return cleaned_name


def build_project_label(project_id: str, name: str) -> str:
    """Build a readable label from a project identifier and name."""
    normalized_project_id = project_id.strip()
    normalized_name = normalize_project_name(name)

    return f"{normalized_project_id}: {normalized_name}"


def demonstrate_functions() -> None:
    """Call reusable functions and print their returned values."""
    print("\nFunction examples:")

    label = build_project_label(
        project_id="project-001",
        name=" Website Redesign ",
    )

    print(label)

    try:
        normalize_project_name("   ")
    except ValueError as error:
        print(f"Expected error: {error}")


def demonstrate_imports() -> None:
    """Use pathlib.Path from Python's standard library."""
    current_directory = Path.cwd()

    print("\nImport examples:")
    print(f"Current directory name: {current_directory.name}")


def main() -> None:
    """Run syntax refresher examples."""
    demonstrate_basic_values()
    demonstrate_strings()
    demonstrate_collections()
    demonstrate_conditionals()
    demonstrate_loops()
    demonstrate_functions()
    demonstrate_imports()


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python scripts/syntax_refresh.py
```

You should see all sections run without errors.

Then check the script with `mypy`:

```bash
python -m mypy scripts/syntax_refresh.py
```

Expected output:

```text
Success: no issues found in 1 source file
```

---

# Primer 3 Reference: Python Syntax Quick Sheet

## Assignment

```python
project_name = "Website Redesign"
```

## Conditional

```python
if project.status == "active":
    print("Active")
elif project.status == "archived":
    print("Archived")
else:
    print("Other")
```

## Loop

```python
for project in projects:
    print(project.name)
```

## Function

```python
def get_project_name(project_id: str) -> str:
    return project_id.strip()
```

## List

```python
project_ids = ["project-001", "project-002"]
```

## Dictionary

```python
project_names = {
    "project-001": "Website Redesign",
}
```

## Set

```python
statuses = {"active", "archived"}
```

## Tuple

```python
coordinates = (51.5072, -0.1276)
```

## Exception Handling

```python
try:
    value = int("not-a-number")
except ValueError as error:
    print(f"Could not convert value: {error}")
```

## Import

```python
from pathlib import Path
```

## Main Guard

```python
if __name__ == "__main__":
    main()
```
