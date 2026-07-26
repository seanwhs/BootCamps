# Primer 5: Reading Errors, Tracebacks, Documentation, and Debugging Python Programs

Errors are not evidence that you are bad at programming. They are information.

A Python error message usually tells you:

1. What failed.
2. Where it failed.
3. Which code path led there.
4. What Python expected instead.

This primer teaches a repeatable debugging process before the main tutorial begins.

By the end, you will be able to:

- Read a Python traceback from bottom to top.
- Recognize common exception types.
- Add temporary diagnostic output safely.
- Use the Python interactive interpreter.
- Inspect objects with `type()`, `repr()`, and `dir()`.
- Read built-in documentation with `help()`.
- Use assertions to identify broken assumptions.
- Create a small reproducible debugging example.

---

## What You Will Build

You will add these files to the learning project:

```text
pythonic-craftsmanship/
└── scripts/
    ├── debugging_demo.py
    └── inspect_demo.py
```

These are small, safe programs that intentionally demonstrate common errors and debugging tools.

---

# Step 1: Understand the Shape of a Traceback

## The Target

We are learning how Python reports an unhandled error.

## The Concept

A **traceback** is Python’s record of the path the program followed before an exception occurred.

Read a traceback from the bottom upward:

```text
Traceback ...
  earlier function call
  later function call
ExceptionType: final message
```

The final line is usually the most important starting point.

For example:

```text
ValueError: Project name cannot be blank.
```

This tells you:

- The exception type is `ValueError`.
- The message explains the invalid value.

The lines above it tell you which file and line caused the error.

Think of a traceback like a breadcrumb trail:

```text
main()
    ↓
create_project()
    ↓
normalize_project_name()
    ↓
ValueError
```

---

# Step 2: Create an Intentional Error Demonstration

## The Target

We are creating:

```text
scripts/debugging_demo.py
```

## The Concept

It is easier to learn error messages by seeing controlled examples.

This script deliberately triggers several common Python exceptions, catches them, and prints a readable traceback for each one.

Normally, an unhandled exception stops a program. Here, we catch expected demonstration failures so all examples can run in one execution.

## The Implementation

### `scripts/debugging_demo.py`

```python
"""Demonstrate common Python exceptions and readable traceback output."""

from __future__ import annotations

import traceback
from collections.abc import Callable


def normalize_project_name(name: str) -> str:
    """Return a cleaned project name or raise a useful validation error."""
    cleaned_name = name.strip()

    if not cleaned_name:
        raise ValueError("Project name cannot be blank.")

    return cleaned_name


def demonstrate_value_error() -> None:
    """Trigger a ValueError by supplying blank project-name text."""
    normalize_project_name("   ")


def demonstrate_key_error() -> None:
    """Trigger a KeyError by reading a missing dictionary key."""
    project_names = {
        "project-001": "Website Redesign",
    }

    print(project_names["project-999"])


def demonstrate_type_error() -> None:
    """Trigger a TypeError by combining incompatible value types."""
    project_count = 3
    project_name = "Website Redesign"

    print(project_count + project_name)  # type: ignore[operator]


def demonstrate_attribute_error() -> None:
    """Trigger an AttributeError by calling a missing method."""
    project_name = "Website Redesign"

    print(project_name.to_upper_case())  # type: ignore[attr-defined]


def run_example(name: str, action: Callable[[], None]) -> None:
    """Run one failing example and print its exception information."""
    print(f"\n--- {name} ---")

    try:
        action()
    except Exception as error:
        print(f"Exception type: {type(error).__name__}")
        print(f"Message: {error}")
        print("\nTraceback:")
        traceback.print_exc()


def main() -> None:
    """Run controlled examples of common exception types."""
    run_example("ValueError example", demonstrate_value_error)
    run_example("KeyError example", demonstrate_key_error)
    run_example("TypeError example", demonstrate_type_error)
    run_example("AttributeError example", demonstrate_attribute_error)


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python scripts/debugging_demo.py
```

You should see four labeled sections.

The output order may look unusual because tracebacks are typically written to standard error while normal `print()` output uses standard output. The important details are the exception types and messages.

Expected messages include:

```text
Exception type: ValueError
Message: Project name cannot be blank.
```

```text
Exception type: KeyError
Message: 'project-999'
```

```text
Exception type: TypeError
```

```text
Exception type: AttributeError
```

---

# Step 3: Recognize Common Exception Types

## The Target

We are learning the most common exception categories you will encounter in this series.

## The Concept

An exception type describes the category of failure.

| Exception | Typical meaning |
|---|---|
| `SyntaxError` | Python cannot understand the code structure |
| `IndentationError` | Python indentation is invalid |
| `NameError` | A variable or name does not exist |
| `TypeError` | A value has the wrong type for an operation |
| `ValueError` | A value has the right type but invalid content |
| `KeyError` | A dictionary key is missing |
| `IndexError` | A list or sequence index is out of range |
| `AttributeError` | An object does not have the requested attribute or method |
| `FileNotFoundError` | A requested file path does not exist |
| `ImportError` / `ModuleNotFoundError` | Python cannot import requested code |
| `AssertionError` | An `assert` condition was false |

Examples:

```python
int("not-a-number")
```

Raises:

```text
ValueError
```

because the input is a string, but its content cannot become an integer.

```python
"hello" + 5
```

Raises:

```text
TypeError
```

because adding a string and integer is not a supported operation.

---

# Step 4: Use a Repeatable Debugging Process

## The Target

We are defining a debugging workflow you can use throughout the series.

## The Concept

When a program fails, avoid random changes.

Use this process:

```text
1. Read the final exception line.
2. Find the relevant file and line number.
3. Identify the actual value and expected value.
4. Reproduce the smallest failing case.
5. Fix the cause, not only the symptom.
6. Run the focused verification again.
7. Add a test if the bug could return later.
```

For example, if you see:

```text
AttributeError: 'NoneType' object has no attribute 'strip'
```

translate it into plain language:

> The program expected a string-like value, but it received `None`, then attempted to call `.strip()`.

The fix is not necessarily “add `try/except AttributeError`.” The better fix is usually validating the input at the boundary.

---

# Step 5: Inspect Values with `type()` and `repr()`

## The Target

We are creating:

```text
scripts/inspect_demo.py
```

## The Concept

When behavior surprises you, inspect the value you actually have.

Two useful tools are:

```python
type(value)
repr(value)
```

`type(value)` answers:

> What kind of value is this?

`repr(value)` answers:

> What is the detailed developer-oriented representation of this value?

This is especially helpful with invisible characters.

For example:

```python
project_name = " Website Redesign \n"
```

Normal printing hides some detail:

```python
print(project_name)
```

But:

```python
print(repr(project_name))
```

shows:

```text
' Website Redesign \n'
```

## The Implementation

### `scripts/inspect_demo.py`

```python
"""Demonstrate safe object inspection with type(), repr(), and dir()."""

from __future__ import annotations


def inspect_value(label: str, value: object) -> None:
    """Print useful developer-facing details about one value."""
    print(f"\n{label}")
    print(f"Type: {type(value).__name__}")
    print(f"Representation: {value!r}")


def main() -> None:
    """Inspect common values and selected string capabilities."""
    project_name = " Website Redesign \n"
    page_number = 2
    missing_description = None
    project_ids = ["project-001", "project-002"]

    inspect_value("Project name", project_name)
    inspect_value("Page number", page_number)
    inspect_value("Missing description", missing_description)
    inspect_value("Project identifiers", project_ids)

    print("\nSelected string methods:")
    string_methods = [
        name
        for name in dir(project_name)
        if not name.startswith("_")
    ]

    print(", ".join(string_methods[:15]))
    print("\nUse help(str.strip) in the Python interpreter for documentation.")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python scripts/inspect_demo.py
```

Expected output includes:

```text
Project name
Type: str
Representation: ' Website Redesign \n'
```

and:

```text
Missing description
Type: NoneType
Representation: None
```

The exact selected string-method list may vary slightly by Python version.

---

# Step 6: Use the Python Interactive Interpreter

## The Target

We are practicing short experiments in Python’s interactive interpreter.

## The Concept

The Python interpreter provides a prompt where you can run one expression or statement at a time.

Start it with:

```bash
python
```

You should see something similar to:

```text
Python 3.12.4 ...
Type "help", "copyright", "credits" or "license" for more information.
>>>
```

The `>>>` prompt means Python is ready for code.

This is ideal for quickly testing an idea without creating a file.

## The Implementation

From the project root, run:

```bash
python
```

Then enter these commands one at a time:

```python
project_name = " Website Redesign "
```

```python
project_name.strip()
```

Expected output:

```text
'Website Redesign'
```

Try:

```python
type(project_name)
```

Expected output:

```text
<class 'str'>
```

Try an invalid value:

```python
int("not-a-number")
```

Expected output ends with:

```text
ValueError: invalid literal for int() with base 10: 'not-a-number'
```

Exit the interpreter:

```python
exit()
```

## The Verification

You should return to your normal terminal prompt.

---

# Step 7: Read Built-In Documentation with `help()`

## The Target

We are using Python’s built-in documentation system.

## The Concept

Python includes documentation for built-in types, modules, functions, and methods.

Use:

```python
help(name)
```

For example:

```python
help(str.strip)
```

This is useful when you know a method exists but need to confirm:

- What it does
- Which arguments it accepts
- What it returns
- Any edge cases described in its documentation

## The Implementation

Start the interpreter:

```bash
python
```

Then run:

```python
help(str.strip)
```

Read the displayed documentation.

Depending on your terminal, press:

```text
q
```

to leave the documentation viewer.

Then run:

```python
help(dict.get)
```

Exit when finished:

```python
exit()
```

## The Verification

You should see documentation explaining that:

```python
dict.get(key, default=None, /)
```

returns the value for a key if it exists, otherwise a default value.

Example:

```python
project_names = {
    "project-001": "Website Redesign",
}

print(project_names.get("project-001"))
print(project_names.get("project-999"))
print(project_names.get("project-999", "Unknown project"))
```

Output:

```text
Website Redesign
None
Unknown project
```

---

# Step 8: Use Assertions to Check Assumptions

## The Target

We are learning the `assert` statement.

## The Concept

An assertion checks an assumption in code.

```python
assert condition
```

If the condition is false, Python raises:

```text
AssertionError
```

You can provide a message:

```python
assert page_size > 0, "Page size must be positive."
```

Assertions are useful in tests and internal sanity checks.

Do not use `assert` as the only validation for untrusted external input because Python can run with optimization flags that disable assertions.

For public input validation, use an explicit exception:

```python
if page_size < 1:
    raise ValueError("Page size must be at least 1.")
```

## The Implementation

Create this small assertion function in `scripts/inspect_demo.py`, above `main()`.

### `scripts/inspect_demo.py` — add this function

```python
def demonstrate_assertions() -> None:
    """Show successful and failing internal assumptions."""
    page_size = 25

    assert page_size > 0, "Page size must be positive."
    print("\nThe positive page-size assertion passed.")

    try:
        invalid_page_size = 0

        assert invalid_page_size > 0, "Page size must be positive."
    except AssertionError as error:
        print(f"Expected assertion failure: {error}")
```

Update `main()`.

### `scripts/inspect_demo.py` — replace `main()`

```python
def main() -> None:
    """Inspect common values and selected string capabilities."""
    project_name = " Website Redesign \n"
    page_number = 2
    missing_description = None
    project_ids = ["project-001", "project-002"]

    inspect_value("Project name", project_name)
    inspect_value("Page number", page_number)
    inspect_value("Missing description", missing_description)
    inspect_value("Project identifiers", project_ids)

    print("\nSelected string methods:")
    string_methods = [
        name
        for name in dir(project_name)
        if not name.startswith("_")
    ]

    print(", ".join(string_methods[:15]))
    print("\nUse help(str.strip) in the Python interpreter for documentation.")

    demonstrate_assertions()
```

## The Verification

Run:

```bash
python scripts/inspect_demo.py
```

Expected final output includes:

```text
The positive page-size assertion passed.
Expected assertion failure: Page size must be positive.
```

---

# Step 9: Debug with a Minimal Reproducible Example

## The Target

We are learning how to reduce a bug to its smallest useful form.

## The Concept

A **minimal reproducible example** is the smallest piece of code that still demonstrates a problem.

Instead of showing someone an entire package with 20 files, reduce the issue:

```python
def normalize_project_name(name: str) -> str:
    return name.strip()


normalize_project_name(None)
```

This fails because `None` has no `.strip()` method.

A smaller example makes it easier to:

- Understand the root cause
- Search documentation
- Write a test
- Ask for help
- Confirm a fix

## The Implementation

Create this file.

### `scripts/minimal_bug_example.py`

```python
"""Demonstrate reducing an input-validation bug to a small example."""

from __future__ import annotations


def normalize_project_name(name: str) -> str:
    """Normalize a required project name."""
    if not isinstance(name, str):
        raise TypeError("Project name must be a string.")

    cleaned_name = name.strip()

    if not cleaned_name:
        raise ValueError("Project name cannot be blank.")

    return cleaned_name


def main() -> None:
    """Demonstrate valid and invalid input cases."""
    print(normalize_project_name(" Website Redesign "))

    for invalid_name in ("   ", None):
        try:
            print(normalize_project_name(invalid_name))  # type: ignore[arg-type]
        except (TypeError, ValueError) as error:
            print(f"Expected error: {type(error).__name__}: {error}")


if __name__ == "__main__":
    main()
```

The `# type: ignore[arg-type]` comment is intentional in this learning example. We deliberately pass `None` to demonstrate runtime validation. In normal application code, `mypy` should prevent that invalid call before runtime.

## The Verification

Run:

```bash
python scripts/minimal_bug_example.py
```

Expected output:

```text
Website Redesign
Expected error: ValueError: Project name cannot be blank.
Expected error: TypeError: Project name must be a string.
```

Then run static checking:

```bash
python -m mypy scripts/minimal_bug_example.py
```

Expected output:

```text
Success: no issues found in 1 source file
```

---

# Primer 5 Reference: Traceback Reading Example

Consider this traceback:

```text
Traceback (most recent call last):
  File ".../scripts/example.py", line 18, in <module>
    main()
  File ".../scripts/example.py", line 14, in main
    print(normalize_project_name("   "))
  File ".../scripts/example.py", line 9, in normalize_project_name
    raise ValueError("Project name cannot be blank.")
ValueError: Project name cannot be blank.
```

Read it bottom-up:

1. **What failed?**

   ```text
   ValueError: Project name cannot be blank.
   ```

2. **Where did the error originate?**

   ```text
   normalize_project_name
   line 9
   ```

3. **Who called it?**

   ```text
   main
   line 14
   ```

4. **What started the program?**

   ```text
   main()
   line 18
   ```

This tells you the code behaved as designed: it rejected blank text. The next question is whether the caller should have prevented blank input earlier.

---

# Primer 5 Reference: Debugging Checklist

When you see an error:

- [ ] Read the final exception type and message.
- [ ] Find the file and line number nearest the bottom of the traceback.
- [ ] Inspect the actual values with `repr()` and `type()`.
- [ ] Check whether the program is running from the expected directory.
- [ ] Confirm the active virtual environment.
- [ ] Reduce the problem to a minimal example.
- [ ] Read documentation with `help()` or official docs.
- [ ] Fix the underlying assumption or validation boundary.
- [ ] Add a test if the bug could return.
- [ ] Re-run the focused command, then the full test suite.

---

# Primer 5 Reference: Useful Debugging Tools

| Tool | Use |
|---|---|
| `print(value)` | Quick human-facing output |
| `print(repr(value))` | Reveal whitespace and exact representation |
| `type(value)` | Identify runtime type |
| `dir(value)` | List attributes and methods |
| `help(value)` | Read built-in documentation |
| `assert condition` | Check internal assumptions |
| `python -m pytest -x` | Stop tests after the first failure |
| `python -m pytest --pdb` | Open debugger after a failed test |
| `python -m mypy src tests` | Find type-contract problems before execution |
| `git diff` | Review recent code changes |
