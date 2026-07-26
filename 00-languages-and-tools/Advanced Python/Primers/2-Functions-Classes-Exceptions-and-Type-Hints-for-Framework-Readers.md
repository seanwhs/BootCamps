# Primer 2: Functions, Classes, Exceptions, and Type Hints for Framework Readers

Before working with descriptors, metaclasses, protocols, async tasks, and plugins, readers need a reliable mental model for four everyday Python tools:

1. Functions
2. Classes and instances
3. Exceptions
4. Type hints

These are ordinary Python features, but frameworks combine them in more deliberate ways.

Think of this primer as learning the names and jobs of basic workshop tools before building machinery from them.

---

# Step 1: Functions Are Reusable Units of Behavior

## The Target

Create and call a typed function with parameters and a return value.

## The Concept

A function groups reusable instructions under a name.

```python
def add(left: int, right: int) -> int:
    return left + right
```

This function has:

| Element | Meaning |
|---|---|
| `def` | Define a function |
| `add` | Function name |
| `left`, `right` | Parameters |
| `int` | Type hints |
| `-> int` | Expected return type |
| `return` | Send a value back to caller |

Think of a function as a small machine:

```text
Input values
    ↓
Function logic
    ↓
Output value
```

## The Implementation

Create this file.

## `primer_examples/02_functions.py`

```python
"""Primer 2: typed function basics."""

from __future__ import annotations


def add(left: int, right: int) -> int:
    """Return the sum of two integer values."""
    return left + right


def format_task_name(queue: str, name: str) -> str:
    """Return a stable queue-qualified task name."""
    normalized_queue = queue.strip()
    normalized_name = name.strip()

    if not normalized_queue:
        raise ValueError("queue cannot be empty.")

    if not normalized_name:
        raise ValueError("name cannot be empty.")

    return f"{normalized_queue}.{normalized_name}"


def main() -> None:
    """Run the function examples."""
    total = add(20, 22)
    task_name = format_task_name("emails", "send_welcome_email")

    print(f"20 + 22 = {total}")
    print(f"Task name: {task_name}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.02_functions
```

Expected output:

```text
20 + 22 = 42
Task name: emails.send_welcome_email
```

---

# Step 2: Understand Positional and Keyword Arguments

## The Target

Call a function using both positional and keyword arguments.

## The Concept

A **positional argument** is matched by order:

```python
send_email("ada@example.com", "Welcome")
```

A **keyword argument** is matched by parameter name:

```python
send_email(
    recipient="ada@example.com",
    subject="Welcome",
)
```

Keyword-only parameters are declared after `*`:

```python
def submit_task(task_name: str, *, timeout_seconds: float) -> None:
    ...
```

This requires callers to be explicit:

```python
submit_task("emails.send_welcome", timeout_seconds=5.0)
```

This is useful in framework APIs because configuration values are easier to read and harder to accidentally swap.

## The Implementation

Create this file.

## `primer_examples/03_function_arguments.py`

```python
"""Primer 2: positional, keyword, and keyword-only arguments."""

from __future__ import annotations


def submit_task(
    task_name: str,
    *args: object,
    timeout_seconds: float = 0.0,
    **kwargs: object,
) -> dict[str, object]:
    """Create a task-submission-shaped dictionary.

    *args collects extra positional values into a tuple.
    **kwargs collects extra named values into a dictionary.
    timeout_seconds is keyword-only because it appears after *args.
    """
    if timeout_seconds < 0:
        raise ValueError("timeout_seconds must be zero or greater.")

    return {
        "task_name": task_name,
        "args": args,
        "kwargs": kwargs,
        "timeout_seconds": timeout_seconds,
    }


def main() -> None:
    """Demonstrate several valid calling styles."""
    first_submission = submit_task(
        "emails.send_welcome",
        42,
        timeout_seconds=5.0,
        locale="en-GB",
    )

    second_submission = submit_task(
        task_name="maintenance.cleanup",
        timeout_seconds=0.0,
        max_age_days=30,
    )

    print(first_submission)
    print(second_submission)


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.03_function_arguments
```

Expected output includes:

```text
{'task_name': 'emails.send_welcome', 'args': (42,), 'kwargs': {'locale': 'en-GB'}, 'timeout_seconds': 5.0}
{'task_name': 'maintenance.cleanup', 'args': (), 'kwargs': {'max_age_days': 30}, 'timeout_seconds': 0.0}
```

---

# Step 3: Classes Create Structured Objects

## The Target

Create a class and instantiate it.

## The Concept

A **class** is a blueprint. An **instance** is one object created from that blueprint.

```python
class TaskInfo:
    ...
```

creates a blueprint.

```python
task = TaskInfo(...)
```

creates one instance.

Think of a class as a recipe and an instance as one prepared meal. Several meals can use the same recipe while containing different ingredients.

## The Implementation

Create this file.

## `primer_examples/04_classes_and_instances.py`

```python
"""Primer 2: class and instance basics."""

from __future__ import annotations


class TaskInfo:
    """Describe one task using ordinary Python instance attributes."""

    def __init__(self, task_id: str, task_name: str) -> None:
        """Create one task information object."""
        if not task_id:
            raise ValueError("task_id cannot be empty.")

        if not task_name:
            raise ValueError("task_name cannot be empty.")

        self.task_id = task_id
        self.task_name = task_name
        self.attempt = 0

    def start_attempt(self) -> None:
        """Record beginning of another task attempt."""
        self.attempt += 1

    def describe(self) -> str:
        """Return a readable description of this task."""
        return (
            f"Task id={self.task_id}, "
            f"name={self.task_name}, "
            f"attempt={self.attempt}"
        )


def main() -> None:
    """Create and use one class instance."""
    task = TaskInfo(
        task_id="task-001",
        task_name="emails.send_welcome_email",
    )

    print(task.describe())

    task.start_attempt()

    print(task.describe())


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.04_classes_and_instances
```

Expected output:

```text
Task id=task-001, name=emails.send_welcome_email, attempt=0
Task id=task-001, name=emails.send_welcome_email, attempt=1
```

---

# Step 4: Understand `self`

## The Target

Understand why instance methods receive `self`.

## The Concept

When you call:

```python
task.start_attempt()
```

Python effectively performs:

```python
TaskInfo.start_attempt(task)
```

The first method parameter, conventionally named `self`, refers to the current instance.

```python
def start_attempt(self) -> None:
    self.attempt += 1
```

This means:

> “Increase the attempt value belonging to this particular task object.”

Every instance receives its own values.

## The Implementation

Create this file.

## `primer_examples/05_self_and_instance_state.py`

```python
"""Primer 2: demonstrate independent instance state."""

from __future__ import annotations


class Counter:
    """Store a count independently for each instance."""

    def __init__(self, name: str) -> None:
        """Create one counter with an initial value of zero."""
        self.name = name
        self.value = 0

    def increment(self) -> None:
        """Increase only this counter's value."""
        self.value += 1

    def report(self) -> str:
        """Describe this counter."""
        return f"{self.name}: {self.value}"


def main() -> None:
    """Show that two instances do not share normal instance attributes."""
    email_counter = Counter("email tasks")
    cleanup_counter = Counter("cleanup tasks")

    email_counter.increment()
    email_counter.increment()
    cleanup_counter.increment()

    print(email_counter.report())
    print(cleanup_counter.report())


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.05_self_and_instance_state
```

Expected output:

```text
email tasks: 2
cleanup tasks: 1
```

---

# Step 5: Raise and Catch Exceptions

## The Target

Create validation errors and handle them safely.

## The Concept

An **exception** is Python’s way of signaling that normal execution cannot continue.

For example:

```python
raise ValueError("timeout_seconds must be zero or greater.")
```

This is like a production-line stop button. The function refuses to continue with invalid input.

A caller may handle expected failures:

```python
try:
    ...
except ValueError as error:
    ...
```

Frameworks should raise clear, specific exceptions instead of silently accepting invalid state.

## The Implementation

Create this file.

## `primer_examples/06_exceptions.py`

```python
"""Primer 2: raising and catching validation exceptions."""

from __future__ import annotations


def calculate_retry_delay(
    retry_number: int,
    *,
    initial_delay_seconds: float,
) -> float:
    """Return a simple linear retry delay after validating inputs."""
    if retry_number < 1:
        raise ValueError("retry_number must be at least 1.")

    if initial_delay_seconds < 0:
        raise ValueError("initial_delay_seconds must be zero or greater.")

    return retry_number * initial_delay_seconds


def main() -> None:
    """Run successful and failing validation examples."""
    delay = calculate_retry_delay(
        3,
        initial_delay_seconds=0.5,
    )

    print(f"Retry delay: {delay} seconds")

    try:
        calculate_retry_delay(
            0,
            initial_delay_seconds=0.5,
        )
    except ValueError as error:
        print(f"Validation failed: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.06_exceptions
```

Expected output:

```text
Retry delay: 1.5 seconds
Validation failed: retry_number must be at least 1.
```

---

# Step 6: Use `try` / `except` / `finally`

## The Target

Use `finally` to ensure cleanup runs whether work succeeds or fails.

## The Concept

A `finally` block always runs after the `try` block:

- if work succeeds;
- if work raises an exception;
- if a caller returns early;
- in async code, even during cancellation.

This is essential for cleanup.

Think of it as locking a building after a meeting. Whether the meeting went well or was interrupted, the final person still needs to lock the door.

## The Implementation

Create this file.

## `primer_examples/07_finally_cleanup.py`

```python
"""Primer 2: ensure cleanup with try/finally."""

from __future__ import annotations


class DemoConnection:
    """A small resource object with explicit open and close operations."""

    def __init__(self) -> None:
        self.is_open = False

    def open(self) -> None:
        """Open the simulated resource."""
        self.is_open = True
        print("Connection opened.")

    def close(self) -> None:
        """Close the simulated resource."""
        self.is_open = False
        print("Connection closed.")


def use_connection(*, should_fail: bool) -> None:
    """Open a connection and always close it."""
    connection = DemoConnection()
    connection.open()

    try:
        print("Performing work.")

        if should_fail:
            raise RuntimeError("Simulated operation failure.")

        print("Work completed.")
    finally:
        connection.close()


def main() -> None:
    """Demonstrate cleanup after both success and failure."""
    print("--- Successful operation ---")
    use_connection(should_fail=False)

    print("\n--- Failing operation ---")

    try:
        use_connection(should_fail=True)
    except RuntimeError as error:
        print(f"Caller received error: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.07_finally_cleanup
```

Expected output includes:

```text
--- Successful operation ---
Connection opened.
Performing work.
Work completed.
Connection closed.

--- Failing operation ---
Connection opened.
Performing work.
Connection closed.
Caller received error: Simulated operation failure.
```

Notice that `Connection closed.` appears in both paths.

---

# Step 7: Read Type Hints Correctly

## The Target

Understand that type hints improve tooling but do not automatically validate runtime values.

## The Concept

This function says it expects two integers:

```python
def add(left: int, right: int) -> int:
    return left + right
```

But Python does not automatically enforce that contract.

This call is allowed by Python:

```python
add("20", "22")
```

It returns:

```text
2022
```

because string addition means concatenation.

Type hints are like labels on storage boxes. Labels help people and inventory systems put the right things in the right places, but a label alone does not physically stop someone from putting a wrench into a box labeled “screws.”

Use both:

1. Type hints for static tooling.
2. Runtime validation at external or dynamic boundaries.

## The Implementation

Create this file.

## `primer_examples/08_type_hints_and_runtime_validation.py`

```python
"""Primer 2: type hints communicate intent; validation enforces it."""

from __future__ import annotations

from typing import Any


def add(left: int, right: int) -> int:
    """Return sum according to Python's runtime addition behavior."""
    return left + right


def parse_positive_integer(value: Any, *, field_name: str) -> int:
    """Validate dynamic input and return a trustworthy integer."""
    if not isinstance(value, int):
        raise TypeError(
            f"{field_name} must be an integer, not {type(value).__name__}."
        )

    if value <= 0:
        raise ValueError(f"{field_name} must be greater than zero.")

    return value


def main() -> None:
    """Demonstrate type hints and runtime validation separately."""
    print(f"Typed integer addition: {add(20, 22)}")

    # Python permits this despite annotations because annotations are not
    # automatic runtime enforcement.
    print(f"String addition at runtime: {add('20', '22')}")

    parsed_value = parse_positive_integer(42, field_name="worker_concurrency")
    print(f"Validated worker concurrency: {parsed_value}")

    try:
        parse_positive_integer("four", field_name="worker_concurrency")
    except TypeError as error:
        print(f"Type validation error: {error}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.08_type_hints_and_runtime_validation
```

Expected output:

```text
Typed integer addition: 42
String addition at runtime: 2022
Validated worker concurrency: 42
Type validation error: worker_concurrency must be an integer, not str.
```

---

# Primer 2 Reference: Important Definitions

| Term | Meaning |
|---|---|
| Function | Reusable named behavior |
| Parameter | Variable declared in a function definition |
| Argument | Value supplied when calling a function |
| Class | Blueprint for objects |
| Instance | Object created from a class |
| Method | Function defined inside a class |
| `self` | Conventional name for current instance |
| Exception | Signal that normal execution cannot continue |
| `try` | Block containing work that may fail |
| `except` | Block handling expected failure |
| `finally` | Block that runs regardless of success or failure |
| Type hint | Annotation describing intended value type |
| Runtime validation | Actual checks performed while program executes |

---

# Primer 2 Completion Checklist

Before continuing to advanced object behavior, confirm that you can:

- [ ] Define and call typed functions.
- [ ] Explain positional, keyword, and keyword-only arguments.
- [ ] Create a class and instantiate it.
- [ ] Explain why methods receive `self`.
- [ ] Raise a meaningful exception for invalid input.
- [ ] Catch an expected exception.
- [ ] Use `finally` for cleanup.
- [ ] Explain why type hints do not replace runtime validation.
- [ ] Distinguish `Any` from a validated internal value.
[STARTING: Primer 3 — Imports, Scope, Decorators, and How Python Builds Framework APIs]
