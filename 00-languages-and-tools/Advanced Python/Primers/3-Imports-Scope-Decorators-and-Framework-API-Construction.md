# Primer 3: Imports, Scope, Decorators, and Framework API Construction

Frameworks often look magical:

```python
@app.task(queue="emails")
async def send_welcome_email(user_id: int) -> str:
    ...
```

But this is ordinary Python built from a few concepts:

- imports;
- names and scope;
- functions as objects;
- decorators;
- closures.

This primer explains those pieces before the metaprogramming modules.

---

# Step 1: Imports Execute Modules Once Per Process

## The Target

Understand what happens when Python imports a module.

## The Concept

When Python runs:

```python
import pulsequeue
```

it:

1. Locates the module or package.
2. Executes its top-level code.
3. Stores the resulting module object in `sys.modules`.
4. Reuses that module object for later imports.

This is why task registration decorators work. Importing a module containing:

```python
@app.task(queue="emails")
async def send_email() -> str:
    ...
```

executes the decorator and registers the task.

Think of importing a module as opening and setting up a workshop. The first visit sets everything up; later visits use the already-open workshop.

## The Implementation

Create this file.

## `primer_examples/import_demo.py`

```python
"""A module that visibly announces when Python imports it."""

from __future__ import annotations

print("import_demo module top-level code is running.")

MODULE_VALUE = "available after import"


def describe() -> str:
    """Return one module-owned value."""
    return MODULE_VALUE
```

Create the runner.

## `primer_examples/09_imports.py`

```python
"""Primer 3: demonstrate Python import caching."""

from __future__ import annotations

import importlib

import primer_examples.import_demo as import_demo


def main() -> None:
    """Import a module repeatedly and inspect its behavior."""
    print(f"First imported value: {import_demo.describe()}")

    import primer_examples.import_demo as imported_again

    print(
        "Both imports refer to the same module object: "
        f"{import_demo is imported_again}"
    )

    print("\nReloading explicitly:")
    importlib.reload(import_demo)


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.09_imports
```

Expected output:

```text
import_demo module top-level code is running.
First imported value: available after import
Both imports refer to the same module object: True

Reloading explicitly:
import_demo module top-level code is running.
```

The top-level message appears once during ordinary import and again only after explicit reload.

---

# Step 2: Understand Local and Module Scope

## The Target

Understand where Python names exist and why framework configuration often uses closures.

## The Concept

A **scope** is the region where a name is available.

Common scopes:

| Scope | Example |
|---|---|
| Local | Variable inside a function |
| Enclosing | Variable in an outer function used by an inner function |
| Global/module | Name defined at top level of a module |
| Built-in | Names like `len`, `str`, and `print` |

Python commonly searches names in this order:

```text
Local → Enclosing → Global → Built-in
```

This is sometimes called the **LEGB rule**.

A decorator factory uses enclosing scope to remember configuration.

## The Implementation

Create this file.

## `primer_examples/10_scope.py`

```python
"""Primer 3: local, enclosing, and module scope."""

from __future__ import annotations


APPLICATION_NAME = "notifications"


def create_task_label(queue_name: str):
    """Return a function that remembers queue_name from enclosing scope."""

    def label(task_name: str) -> str:
        """Build a task label using enclosing and global names."""
        local_prefix = "task"

        return (
            f"{local_prefix}:"
            f"{APPLICATION_NAME}:"
            f"{queue_name}:"
            f"{task_name}"
        )

    return label


def main() -> None:
    """Create functions with different remembered queue names."""
    email_label = create_task_label("emails")
    cleanup_label = create_task_label("maintenance")

    print(email_label("send_welcome_email"))
    print(cleanup_label("remove_expired_sessions"))


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.10_scope
```

Expected output:

```text
task:notifications:emails:send_welcome_email
task:notifications:maintenance:remove_expired_sessions
```

Each returned `label(...)` function remembers its own `queue_name`.

---

# Step 3: Functions Are Objects

## The Target

Pass a function into another function and return it later.

## The Concept

In Python, functions are objects.

That means you can:

- assign them to variables;
- put them in dictionaries;
- pass them to other functions;
- return them from functions;
- attach metadata to them.

This is the foundation of decorators.

## The Implementation

Create this file.

## `primer_examples/11_functions_are_objects.py`

```python
"""Primer 3: functions can be stored, passed, and returned."""

from __future__ import annotations

from collections.abc import Callable


def send_email(user_id: int) -> str:
    """Return a simulated email result."""
    return f"Email sent to user {user_id}"


def execute(
    operation: Callable[[int], str],
    value: int,
) -> str:
    """Call a function supplied by the caller."""
    return operation(value)


def choose_operation(name: str) -> Callable[[int], str]:
    """Return one callable based on a simple selector."""
    if name == "send_email":
        return send_email

    raise ValueError(f"Unknown operation {name!r}.")


def main() -> None:
    """Demonstrate functions as ordinary values."""
    stored_function = send_email

    print(stored_function(42))
    print(execute(send_email, 43))

    chosen_function = choose_operation("send_email")
    print(chosen_function(44))


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.11_functions_are_objects
```

Expected output:

```text
Email sent to user 42
Email sent to user 43
Email sent to user 44
```

---

# Step 4: Write a Basic Decorator

## The Target

Wrap a function with behavior that runs before and after the original function.

## The Concept

A decorator receives a function and returns a replacement callable.

This:

```python
@log_call
def greet(name: str) -> str:
    ...
```

means:

```python
def greet(name: str) -> str:
    ...

greet = log_call(greet)
```

The replacement function can add behavior such as logging, access control, timing, caching, validation, or task registration.

## The Implementation

Create this file.

## `primer_examples/12_basic_decorator.py`

```python
"""Primer 3: implement a basic function decorator."""

from __future__ import annotations

import functools
from collections.abc import Callable
from typing import ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


def log_call(
    function: Callable[ParametersT, ResultT],
) -> Callable[ParametersT, ResultT]:
    """Return a wrapper that logs before and after calling function."""

    @functools.wraps(function)
    def wrapper(
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> ResultT:
        """Execute original function with logging."""
        print(
            f"Starting {function.__qualname__} "
            f"with args={args}, kwargs={kwargs}"
        )

        result = function(*args, **kwargs)

        print(f"Finished {function.__qualname__} with result={result!r}")
        return result

    return wrapper


@log_call
def greet(name: str) -> str:
    """Return a greeting for one name."""
    return f"Hello, {name}."


def main() -> None:
    """Run decorated function and inspect preserved metadata."""
    print(greet("Ada"))
    print(f"Function name: {greet.__name__}")
    print(f"Documentation: {greet.__doc__}")


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.12_basic_decorator
```

Expected output includes:

```text
Starting greet with args=('Ada',), kwargs={}
Finished greet with result='Hello, Ada.'
Hello, Ada.
Function name: greet
Documentation: Return a greeting for one name.
```

`functools.wraps(...)` preserves the original function’s name and documentation.

Without it, Python would report the wrapper’s identity instead.

---

# Step 5: Build a Decorator Factory

## The Target

Create a decorator that first receives configuration, then receives a function.

## The Concept

PulseQueue uses this pattern:

```python
@app.task(queue="emails")
async def send_email() -> str:
    ...
```

This has two calls:

```python
decorator = app.task(queue="emails")
send_email = decorator(send_email)
```

The outer function remembers configuration such as `queue="emails"`.

The inner function receives the task function.

This is called a **decorator factory**.

## The Implementation

Create this file.

## `primer_examples/13_decorator_factory.py`

```python
"""Primer 3: build a decorator factory resembling task registration."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any, ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class SimpleTaskRegistry:
    """Store decorated functions by stable queue-qualified name."""

    def __init__(self) -> None:
        self.tasks: dict[str, Callable[..., Any]] = {}

    def task(
        self,
        *,
        queue: str,
    ) -> Callable[
        [Callable[ParametersT, ResultT]],
        Callable[ParametersT, ResultT],
    ]:
        """Return a decorator configured for one queue."""
        if not queue:
            raise ValueError("queue cannot be empty.")

        def register(
            function: Callable[ParametersT, ResultT],
        ) -> Callable[ParametersT, ResultT]:
            """Store function and return it unchanged."""
            task_name = f"{queue}.{function.__name__}"

            if task_name in self.tasks:
                raise ValueError(f"Task {task_name!r} is already registered.")

            self.tasks[task_name] = function

            print(f"Registered task: {task_name}")
            return function

        return register


registry = SimpleTaskRegistry()


@registry.task(queue="emails")
def send_welcome_email(user_id: int) -> str:
    """Return one simulated email result."""
    return f"Welcome email sent to user {user_id}"


def main() -> None:
    """Inspect registration and call the original decorated function."""
    print(f"Registered names: {sorted(registry.tasks)}")
    print(send_welcome_email(42))


if __name__ == "__main__":
    main()
```

## The Verification

Run:

```bash
python -m primer_examples.13_decorator_factory
```

Expected output:

```text
Registered task: emails.send_welcome_email
Registered names: ['emails.send_welcome_email']
Welcome email sent to user 42
```

The registration happens while Python executes the module and reaches the decorated function definition.

---

# Step 6: Connect This Primer to `PulseQueue`

## The Target

Use the real task decorator and inspect the resulting registered task.

## The Concept

The real framework extends the simple example:

```text
Simple registry:
Function → dictionary entry

PulseQueue:
Function → Task object → validated options → registry entry → worker execution
```

The user-facing syntax remains simple because decorators hide the registration plumbing.

## The Implementation

Create this file.

## `primer_examples/14_pulsequeue_decorator_connection.py`

```python
"""Primer 3: connect decorator concepts to real PulseQueue registration."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime


app = PulseQueue("primer_decorator_demo")


@app.task(queue="messages")
async def greet(name: str) -> str:
    """Return one asynchronous greeting."""
    await asyncio.sleep(0)
    return f"Hello, {name}."


async def main() -> None:
    """Inspect task registration and run it through the runtime."""
    registered_task = app.get_task("messages.greet")

    print(f"Task object type: {type(registered_task).__name__}")
    print(f"Task stable name: {registered_task.name}")
    print(f"Task signature: {registered_task.signature}")
    print(f"Registered names: {sorted(app.registered_tasks())}")

    async with PulseQueueRuntime(app) as runtime:
        receipt = await runtime.submit("messages.greet", "Ada")
        result = await receipt.result(timeout_seconds=1.0)

        print(f"Task result: {result}")


if __name__ == "__main__":
    asyncio.run(main())
```

## The Verification

Run:

```bash
python -m primer_examples.14_pulsequeue_decorator_connection
```

Expected output includes:

```text
Task object type: Task
Task stable name: messages.greet
Task signature: (name: str) -> str
Registered names: ['messages.greet']
Task result: Hello, Ada.
```

---

# Primer 3 Reference: Decorator Execution Order

For this code:

```python
@app.task(queue="emails")
async def send_email(user_id: int) -> str:
    return f"Sent to {user_id}"
```

Python conceptually does this:

```python
async def send_email(user_id: int) -> str:
    return f"Sent to {user_id}"

decorator = app.task(queue="emails")

send_email = decorator(send_email)
```

The resulting `send_email` name refers to a `Task` object, not the original raw function.

PulseQueue preserves useful function metadata through:

```python
functools.update_wrapper(...)
```

This is why task objects can still expose familiar values such as:

```python
send_email.__name__
send_email.__doc__
send_email.__annotations__
```

---

# Primer 3 Completion Checklist

Before moving into metaprogramming, confirm that you can:

- [ ] Explain that importing a module executes its top-level code.
- [ ] Explain why task modules must be imported for registration to occur.
- [ ] Describe local, enclosing, and module scope.
- [ ] Explain what a closure remembers.
- [ ] Pass a function as an argument.
- [ ] Return a function from another function.
- [ ] Explain what a decorator does.
- [ ] Explain why `functools.wraps(...)` is useful.
- [ ] Explain how a decorator factory captures configuration.
- [ ] Connect `@app.task(...)` syntax to ordinary function calls.
