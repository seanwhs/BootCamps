# Part 3: Introspection, Decorators, and Dynamic Task Registration

A task framework needs a reliable answer to a simple question:

> “Given the name `emails.send_welcome_email`, what Python function should run?”

The answer cannot depend on manually maintained lists scattered around an application. That approach becomes fragile as the application grows.

Instead, we will let task functions register themselves at definition time:

```python
@app.task(queue="emails", max_retries=3)
async def send_welcome_email(user_id: int) -> str:
    return f"Welcome email queued for user {user_id}"
```

By the time Python has finished executing that function definition, the application will know:

- The stable task name.
- The queue it belongs to.
- Its validated configuration.
- Its Python function signature.
- Its parameter annotations.
- Whether it is asynchronous.
- Where the source code is defined.

This part introduces **introspection** and **decorators** as practical framework tools.

---

## Step 1: Inspect Functions and Their Signatures

### The Target

Create a script that inspects a normal asynchronous Python function.

### The Concept

A function is not merely executable code. At runtime, it is also an object containing useful metadata:

- `__name__`: its short name.
- `__module__`: the Python module where it was defined.
- `__qualname__`: its fully qualified name, including class nesting if applicable.
- `__annotations__`: type hints attached to parameters and return values.
- `inspect.signature(...)`: a structured representation of accepted arguments.
- `inspect.iscoroutinefunction(...)`: whether calling it creates a coroutine.

A **coroutine** is a function declared with `async def`. Calling it does not immediately complete the work. Instead, it creates a coroutine object that an `asyncio` event loop can run later.

Think of function introspection as reading a shipping label before loading a package onto a truck. The label tells you where the package came from, what it contains, and how it should be handled.

### The Implementation

Create the following example.

## `examples/10_function_introspection.py`

```python
"""Inspect Python function metadata and call signatures."""

from __future__ import annotations

import inspect
from typing import Any


async def send_welcome_email(
    user_id: int,
    *,
    locale: str = "en-US",
    send_marketing_content: bool = False,
) -> dict[str, Any]:
    """Prepare a welcome-email request for one user."""
    return {
        "user_id": user_id,
        "locale": locale,
        "send_marketing_content": send_marketing_content,
    }


function_signature = inspect.signature(send_welcome_email)

print(f"Function name: {send_welcome_email.__name__}")
print(f"Qualified name: {send_welcome_email.__qualname__}")
print(f"Module: {send_welcome_email.__module__}")
print(f"Is coroutine function: {inspect.iscoroutinefunction(send_welcome_email)}")
print(f"Signature: {function_signature}")
print(f"Annotations: {send_welcome_email.__annotations__}")

print("\nParameters:")
for parameter_name, parameter in function_signature.parameters.items():
    print(f"- Name: {parameter_name}")
    print(f"  Kind: {parameter.kind}")
    print(f"  Annotation: {parameter.annotation!r}")
    print(f"  Default: {parameter.default!r}")

print(f"\nReturn annotation: {function_signature.return_annotation!r}")

bound_arguments = function_signature.bind(
    42,
    locale="en-GB",
    send_marketing_content=True,
)

print("\nArguments bound to the function signature:")
print(bound_arguments.arguments)

try:
    function_signature.bind(locale="en-GB")
except TypeError as error:
    print(f"\nInvalid-call error: {error}")
```

### The Verification

Run:

```bash
python examples/10_function_introspection.py
```

Expected output includes:

```text
Function name: send_welcome_email
Qualified name: send_welcome_email
Is coroutine function: True
Signature: (user_id: int, *, locale: str = 'en-US', send_marketing_content: bool = False) -> dict[str, typing.Any]
```

You should also see the bound argument dictionary:

```text
{'user_id': 42, 'locale': 'en-GB', 'send_marketing_content': True}
```

The final error confirms that `inspect.Signature.bind(...)` can validate a proposed function call before the function executes.

---

## Step 2: Understand What a Decorator Returns

### The Target

Create a small decorator that wraps an asynchronous function while preserving its metadata.

### The Concept

A **decorator** is a callable that receives a function or class and returns a replacement object.

This syntax:

```python
@decorate
def example() -> None:
    ...
```

means:

```python
def example() -> None:
    ...

example = decorate(example)
```

Frameworks use decorators because they allow users to declare intent close to the code being configured.

For example:

```python
@app.task(queue="emails")
async def send_welcome_email(user_id: int) -> str:
    ...
```

The decorator communicates: “This function is not just a helper. It is a task managed by this application.”

When wrapping functions, use `functools.wraps`. Without it, the replacement object may lose important metadata such as the original function name, documentation, annotations, and wrapped-function reference.

### The Implementation

Create the demonstration below.

## `examples/11_async_decorator.py`

```python
"""Demonstrate metadata-preserving decoration of an async function."""

from __future__ import annotations

import asyncio
import functools
import inspect
from collections.abc import Awaitable, Callable
from typing import Any, ParamSpec, TypeVar

ParametersT = ParamSpec("ParametersT")
ReturnT = TypeVar("ReturnT")


def log_async_call(
    function: Callable[ParametersT, Awaitable[ReturnT]],
) -> Callable[ParametersT, Awaitable[ReturnT]]:
    """Wrap an async function with before-and-after logging."""

    @functools.wraps(function)
    async def wrapper(*args: ParametersT.args, **kwargs: ParametersT.kwargs) -> ReturnT:
        print(f"Starting {function.__qualname__} with args={args}, kwargs={kwargs}")

        result = await function(*args, **kwargs)

        print(f"Finished {function.__qualname__} with result={result!r}")
        return result

    return wrapper


@log_async_call
async def multiply(left: int, right: int) -> int:
    """Multiply two values after yielding to the event loop once."""
    await asyncio.sleep(0)
    return left * right


async def main() -> None:
    """Run the decorated function and inspect preserved metadata."""
    result = await multiply(6, 7)

    print(f"Final result: {result}")
    print(f"Preserved function name: {multiply.__name__}")
    print(f"Preserved documentation: {multiply.__doc__}")
    print(f"Preserved signature: {inspect.signature(multiply)}")
    print(f"Original wrapped function: {multiply.__wrapped__!r}")


asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/11_async_decorator.py
```

Expected output includes:

```text
Starting multiply with args=(6, 7), kwargs={}
Finished multiply with result=42
Final result: 42
Preserved function name: multiply
Preserved signature: (left: int, right: int) -> int
```

The output verifies that `functools.wraps` preserved the public identity of `multiply`, even though it is now represented by the decorator’s wrapper function.

---

## Step 3: Create a Typed `Task` Object

### The Target

Create a `Task` class that wraps a validated asynchronous Python function.

### The Concept

A task is more than a function. It is a function plus framework-specific information:

```text
Python callable
      +
Task name
      +
Task options
      +
Function signature
      +
Source location
      =
Task definition
```

We will use a generic class. A **generic** class is a reusable class whose type information can vary.

For example, a task that accepts:

```python
(user_id: int) -> str
```

has a different callable type from a task that accepts:

```python
(report_id: str, force: bool) -> dict[str, str]
```

Python’s `ParamSpec` type variable preserves the shape of callable parameters. This gives type checkers more information than using `Callable[..., object]`, which accepts any arguments and loses useful safety checks.

### The Implementation

Create the task module.

## `src/pulsequeue/task.py`

```python
"""Task definitions and introspection helpers for PulseQueue."""

from __future__ import annotations

import functools
import inspect
from collections.abc import Awaitable, Callable
from pathlib import Path
from typing import Any, Generic, ParamSpec, TypeVar

from pulsequeue.options import TaskOptions

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class Task(Generic[ParametersT, ResultT]):
    """A registered asynchronous callable and its validated configuration.

    The task remains directly callable. Calling it executes the wrapped
    coroutine function normally. In a later concurrency phase, delay(...)
    will submit the task to a broker instead of executing it immediately.
    """

    __slots__ = (
        "_function",
        "_options",
        "_signature",
        "_source_file",
        "_source_line",
    )

    def __init__(
        self,
        function: Callable[ParametersT, Awaitable[ResultT]],
        options: TaskOptions,
    ) -> None:
        """Create a task after validating its callable and declared name."""
        if not inspect.iscoroutinefunction(function):
            raise TypeError(
                f"Task {function.__qualname__!r} must be declared with 'async def'."
            )

        if not options.name:
            raise ValueError("Task option 'name' cannot be empty.")

        self._function = function
        self._options = options
        self._signature = inspect.signature(function)

        source_file = inspect.getsourcefile(function)
        source_lines, source_line = inspect.getsourcelines(function)

        # getsourcefile can return None for unusual dynamically-created
        # functions. We retain a clear sentinel instead of failing registration.
        self._source_file = (
            Path(source_file).resolve() if source_file is not None else None
        )
        self._source_line = source_line if source_lines else None

        # functools.update_wrapper gives Task objects familiar function metadata:
        # __name__, __qualname__, __doc__, __annotations__, and __wrapped__.
        functools.update_wrapper(self, function)

    @property
    def function(self) -> Callable[ParametersT, Awaitable[ResultT]]:
        """Return the original asynchronous Python function."""
        return self._function

    @property
    def options(self) -> TaskOptions:
        """Return validated task configuration."""
        return self._options

    @property
    def name(self) -> str:
        """Return the queue-qualified stable task name."""
        return self._options.qualified_name

    @property
    def signature(self) -> inspect.Signature:
        """Return the callable signature captured at registration time."""
        return self._signature

    @property
    def source_file(self) -> Path | None:
        """Return the resolved source file when Python can identify one."""
        return self._source_file

    @property
    def source_line(self) -> int | None:
        """Return the first source line for the task function when available."""
        return self._source_line

    def bind_arguments(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> inspect.BoundArguments:
        """Validate proposed arguments without executing the task.

        Signature.bind raises TypeError if required arguments are absent,
        unknown keyword arguments are supplied, or positional arguments do
        not match the function declaration.
        """
        return self._signature.bind(*args, **kwargs)

    async def __call__(
        self,
        *args: ParametersT.args,
        **kwargs: ParametersT.kwargs,
    ) -> ResultT:
        """Execute the underlying coroutine after validating its arguments."""
        self.bind_arguments(*args, **kwargs)
        return await self._function(*args, **kwargs)

    def describe(self) -> dict[str, Any]:
        """Return serializable task metadata for diagnostics and tooling."""
        return {
            "name": self.name,
            "function_name": self._function.__name__,
            "qualified_function_name": self._function.__qualname__,
            "module": self._function.__module__,
            "signature": str(self._signature),
            "source_file": str(self._source_file) if self._source_file else None,
            "source_line": self._source_line,
            "queue": self._options.queue,
            "max_retries": self._options.max_retries,
            "timeout_seconds": self._options.timeout_seconds,
            "metadata": self._options.metadata.as_dict(),
        }

    def __repr__(self) -> str:
        """Return a concise representation suitable for debug logs."""
        return (
            f"{type(self).__name__}("
            f"name={self.name!r}, "
            f"signature={str(self._signature)!r}"
            f")"
        )
```

### The Verification

Before creating an application registry, verify that a `Task` object can execute directly.

Create this example.

## `examples/12_task_object.py`

```python
"""Create and run a Task object without a task registry."""

from __future__ import annotations

import asyncio

from pulsequeue.metadata import TaskMetadata
from pulsequeue.options import TaskOptions
from pulsequeue.task import Task


async def format_greeting(user_id: int, *, locale: str = "en-US") -> str:
    """Build a deterministic greeting for one user."""
    await asyncio.sleep(0)
    return f"Hello user {user_id}; locale={locale}"


task = Task(
    format_greeting,
    TaskOptions(
        name="format_greeting",
        queue="emails",
        max_retries=2,
        timeout_seconds=5.0,
        metadata=TaskMetadata(
            owner="platform-team",
            service="notifications",
            environment="development",
        ),
    ),
)


async def main() -> None:
    """Display task metadata and execute the task."""
    print(f"Task representation: {task!r}")
    print(f"Task name: {task.name}")
    print(f"Task signature: {task.signature}")
    print(f"Task details: {task.describe()}")

    result = await task(42, locale="en-GB")
    print(f"Task result: {result}")

    try:
        await task(locale="en-GB")
    except TypeError as error:
        print(f"Argument-validation error: {error}")


asyncio.run(main())
```

Run it:

```bash
python examples/12_task_object.py
```

Expected output includes:

```text
Task name: emails.format_greeting
Task signature: (user_id: int, *, locale: str = 'en-US') -> str
Task result: Hello user 42; locale=en-GB
Argument-validation error: missing a required argument: 'user_id'
```

The source file and line values in `Task details` will depend on your machine, which is expected.

---

## Step 4: Create a Task Registry

### The Target

Create a registry that stores task objects by their stable queue-qualified names.

### The Concept

A registry is like a dispatch board in a delivery center:

```text
emails.send_welcome_email  → Task object
reports.generate_daily      → Task object
maintenance.cleanup         → Task object
```

When a worker later receives a task name from a queue, it will use this registry to find the correct task definition.

The registry must protect against duplicate names. Without this protection, one registration could silently replace another task:

```python
@app.task(name="send_email", queue="emails")
async def first() -> None:
    ...

@app.task(name="send_email", queue="emails")
async def second() -> None:
    ...
```

Silent replacement is dangerous because the worker might execute the wrong code. We will fail immediately instead.

### The Implementation

Create the registry module.

## `src/pulsequeue/registry.py`

```python
"""Task registration and lookup for PulseQueue applications."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from types import MappingProxyType
from typing import Any

from pulsequeue.namespace import AttributeNamespace
from pulsequeue.task import Task


class DuplicateTaskError(ValueError):
    """Raised when an application attempts to register a duplicate task name."""


class UnknownTaskError(KeyError):
    """Raised when code requests a task that is not registered."""


class TaskRegistry:
    """Store tasks by stable name and expose safe inspection operations."""

    def __init__(self) -> None:
        self._tasks: dict[str, Task[Any, Any]] = {}

    def register(self, task: Task[Any, Any]) -> Task[Any, Any]:
        """Register one task and return it for decorator-friendly usage."""
        if task.name in self._tasks:
            existing_task = self._tasks[task.name]
            raise DuplicateTaskError(
                f"Task {task.name!r} is already registered by "
                f"{existing_task.function.__module__}."
                f"{existing_task.function.__qualname__}."
            )

        self._tasks[task.name] = task
        return task

    def get(self, name: str) -> Task[Any, Any]:
        """Return a task by name or raise a framework-specific lookup error."""
        try:
            return self._tasks[name]
        except KeyError as error:
            available = ", ".join(sorted(self._tasks)) or "<none>"
            raise UnknownTaskError(
                f"Task {name!r} is not registered. Available tasks: {available}."
            ) from error

    def contains(self, name: str) -> bool:
        """Return whether a task exists without raising an exception."""
        return name in self._tasks

    def all(self) -> Mapping[str, Task[Any, Any]]:
        """Return an immutable snapshot of registered tasks."""
        return MappingProxyType(self._tasks.copy())

    def __iter__(self) -> Iterator[Task[Any, Any]]:
        """Iterate over tasks in stable name order for deterministic diagnostics."""
        for task_name in sorted(self._tasks):
            yield self._tasks[task_name]

    def __len__(self) -> int:
        """Return the number of registered tasks."""
        return len(self._tasks)

    def namespace(self, *, name: str = "tasks") -> AttributeNamespace:
        """Build a nested read-only attribute namespace from task names.

        A registered task named 'emails.send_welcome_email' becomes available
        through namespace.emails.send_welcome_email.

        Every segment must be a valid public Python identifier because
        AttributeNamespace intentionally rejects invalid or private names.
        """
        tree: dict[str, Any] = {}

        for task_name, task in self._tasks.items():
            segments = task_name.split(".")

            if len(segments) < 2:
                raise ValueError(
                    f"Task name {task_name!r} must contain a queue and task name."
                )

            current_level = tree

            for segment in segments[:-1]:
                existing_value = current_level.get(segment)

                if existing_value is None:
                    next_level: dict[str, Any] = {}
                    current_level[segment] = next_level
                    current_level = next_level
                elif isinstance(existing_value, dict):
                    current_level = existing_value
                else:
                    raise ValueError(
                        f"Cannot create namespace for {task_name!r}: "
                        f"{segment!r} is already a task leaf."
                    )

            leaf_name = segments[-1]

            if leaf_name in current_level:
                raise ValueError(
                    f"Cannot create namespace for {task_name!r}: "
                    f"duplicate leaf {leaf_name!r}."
                )

            current_level[leaf_name] = task

        return self._build_namespace(tree, name=name)

    @classmethod
    def _build_namespace(
        cls,
        tree: Mapping[str, Any],
        *,
        name: str,
    ) -> AttributeNamespace:
        """Recursively convert a nested dictionary tree into namespaces."""
        namespace_values: dict[str, Any] = {}

        for key, value in tree.items():
            if isinstance(value, dict):
                namespace_values[key] = cls._build_namespace(
                    value,
                    name=f"{name}.{key}",
                )
            else:
                namespace_values[key] = value

        return AttributeNamespace(namespace_values, name=name)
```

### The Verification

Create this registry demonstration.

## `examples/13_task_registry.py`

```python
"""Demonstrate task registration, lookup, and attribute namespaces."""

from __future__ import annotations

import asyncio

from pulsequeue.options import TaskOptions
from pulsequeue.registry import DuplicateTaskError, TaskRegistry, UnknownTaskError
from pulsequeue.task import Task


async def send_welcome_email(user_id: int) -> str:
    """Return a deterministic email task result."""
    await asyncio.sleep(0)
    return f"welcome email for user {user_id}"


async def remove_expired_sessions(max_age_days: int) -> int:
    """Return a deterministic cleanup count."""
    await asyncio.sleep(0)
    return max_age_days * 2


registry = TaskRegistry()

welcome_task = registry.register(
    Task(
        send_welcome_email,
        TaskOptions(name="send_welcome_email", queue="emails"),
    )
)

cleanup_task = registry.register(
    Task(
        remove_expired_sessions,
        TaskOptions(name="remove_expired_sessions", queue="maintenance"),
    )
)

print(f"Registered task count: {len(registry)}")
print(f"Direct lookup: {registry.get('emails.send_welcome_email')!r}")

tasks = registry.namespace(name="app.tasks")

print(f"Namespace lookup: {tasks.emails.send_welcome_email!r}")
print(f"Namespace cleanup task: {tasks.maintenance.remove_expired_sessions!r}")

try:
    registry.get("emails.does_not_exist")
except UnknownTaskError as error:
    print(f"Unknown-task error: {error}")

try:
    registry.register(
        Task(
            send_welcome_email,
            TaskOptions(name="send_welcome_email", queue="emails"),
        )
    )
except DuplicateTaskError as error:
    print(f"Duplicate-task error: {error}")

print(f"Welcome task is registered: {registry.contains(welcome_task.name)}")
print(f"Cleanup task is registered: {registry.contains(cleanup_task.name)}")
```

### The Verification

Run:

```bash
python examples/13_task_registry.py
```

Expected output includes:

```text
Registered task count: 2
Namespace lookup: Task(name='emails.send_welcome_email', ...)
Unknown-task error: "Task 'emails.does_not_exist' is not registered.
Duplicate-task error: Task 'emails.send_welcome_email' is already registered
Welcome task is registered: True
Cleanup task is registered: True
```

The precise `Task(...)` representation includes the task signature and may differ slightly in formatting.

---

## Step 5: Build the `PulseQueue` Application and `@app.task` Decorator

### The Target

Create the public application object that owns a task registry and provides the decorator API.

### The Concept

An application object is the framework’s control center.

Instead of registering tasks into a hidden global variable, applications own their own independent registries:

```python
notifications_app = PulseQueue("notifications")
reporting_app = PulseQueue("reporting")
```

This avoids global-state problems in tests, command-line tools, and multi-application processes.

The decorator factory works in two stages:

```python
@app.task(queue="emails")
async def send_welcome_email(user_id: int) -> str:
    ...
```

Conceptually:

```python
decorator = app.task(queue="emails")
send_welcome_email = decorator(send_welcome_email)
```

The first call captures configuration. The second receives the function and turns it into a registered `Task`.

### The Implementation

Create the application module.

## `src/pulsequeue/app.py`

```python
"""The public PulseQueue application object."""

from __future__ import annotations

from collections.abc import Awaitable, Callable, Mapping
from typing import Any, ParamSpec, TypeVar

from pulsequeue.metadata import TaskMetadata
from pulsequeue.namespace import AttributeNamespace
from pulsequeue.options import TaskOptions
from pulsequeue.registry import TaskRegistry
from pulsequeue.task import Task

ParametersT = ParamSpec("ParametersT")
ResultT = TypeVar("ResultT")


class PulseQueue:
    """Own task definitions and provide decorator-based registration."""

    def __init__(self, name: str) -> None:
        """Create an application with an isolated task registry."""
        if not name or not name.strip():
            raise ValueError("Application name cannot be empty.")

        if not name.isidentifier():
            raise ValueError(
                f"Application name {name!r} must be a valid Python identifier."
            )

        self._name = name
        self._registry = TaskRegistry()

    @property
    def name(self) -> str:
        """Return the application name."""
        return self._name

    @property
    def tasks(self) -> AttributeNamespace:
        """Expose registered tasks through a fresh read-only namespace snapshot."""
        return self._registry.namespace(name=f"{self._name}.tasks")

    @property
    def task_count(self) -> int:
        """Return the number of tasks currently registered."""
        return len(self._registry)

    def registered_tasks(self) -> Mapping[str, Task[Any, Any]]:
        """Return an immutable snapshot of all registered tasks."""
        return self._registry.all()

    def get_task(self, name: str) -> Task[Any, Any]:
        """Look up a registered task using its queue-qualified name."""
        return self._registry.get(name)

    def task(
        self,
        *,
        queue: str,
        name: str | None = None,
        max_retries: int = 1,
        timeout_seconds: float = 0.0,
        metadata: TaskMetadata | None = None,
    ) -> Callable[
        [Callable[ParametersT, Awaitable[ResultT]]],
        Task[ParametersT, ResultT],
    ]:
        """Return a decorator that registers one asynchronous function.

        The task's short name defaults to the Python function's __name__.
        Its stable registry name is constructed by TaskOptions as:
        '<queue>.<name>'.
        """
        if not queue or not queue.strip():
            raise ValueError("Task queue cannot be empty.")

        if not queue.isidentifier():
            raise ValueError(
                f"Task queue {queue!r} must be a valid Python identifier."
            )

        if name is not None and (not name or not name.isidentifier()):
            raise ValueError(
                "Task name must be a non-empty valid Python identifier when set."
            )

        def register_function(
            function: Callable[ParametersT, Awaitable[ResultT]],
        ) -> Task[ParametersT, ResultT]:
            """Convert one function into a validated and registered Task."""
            task_name = name if name is not None else function.__name__

            options = TaskOptions(
                name=task_name,
                queue=queue,
                max_retries=max_retries,
                timeout_seconds=timeout_seconds,
                metadata=metadata,
            )

            task_definition = Task(function, options)

            # register returns the same object, preserving useful generic type
            # information for callers and static analysis tools.
            self._registry.register(task_definition)

            return task_definition

        return register_function

    def describe(self) -> dict[str, Any]:
        """Return application and task metadata for diagnostics."""
        return {
            "name": self._name,
            "task_count": self.task_count,
            "tasks": {
                task_name: task.describe()
                for task_name, task in self.registered_tasks().items()
            },
        }

    def __repr__(self) -> str:
        """Return a concise application representation for logs and debuggers."""
        return f"{type(self).__name__}(name={self._name!r}, task_count={self.task_count})"
```

Update the public package exports.

## `src/pulsequeue/__init__.py`

```python
"""PulseQueue: an educational high-concurrency Python task framework."""

from pulsequeue.app import PulseQueue
from pulsequeue.metadata import TaskMetadata
from pulsequeue.registry import DuplicateTaskError, UnknownTaskError
from pulsequeue.task import Task

__all__ = [
    "DuplicateTaskError",
    "PulseQueue",
    "Task",
    "TaskMetadata",
    "UnknownTaskError",
]

__version__ = "0.1.0"
```

Now create a complete decorator-based example.

## `examples/14_decorator_registration.py`

```python
"""Register and execute tasks through the PulseQueue application API."""

from __future__ import annotations

import asyncio
import json

from pulsequeue import PulseQueue, TaskMetadata


app = PulseQueue("notifications")


@app.task(
    queue="emails",
    max_retries=3,
    timeout_seconds=10.0,
    metadata=TaskMetadata(
        owner="platform-team",
        service="notifications",
        environment="development",
        priority=10,
    ),
)
async def send_welcome_email(user_id: int, *, locale: str = "en-US") -> str:
    """Return a deterministic welcome-email result."""
    await asyncio.sleep(0)
    return f"welcome email scheduled for user={user_id}, locale={locale}"


@app.task(
    queue="maintenance",
    name="cleanup_sessions",
    max_retries=2,
)
async def remove_expired_sessions(max_age_days: int) -> int:
    """Return a deterministic cleanup result."""
    await asyncio.sleep(0)
    return max_age_days * 5


async def main() -> None:
    """Inspect registered tasks and run them directly for this phase."""
    print(f"Application: {app!r}")
    print(f"Task count: {app.task_count}")

    print("\nTask namespace:")
    print(f"- Email task: {app.tasks.emails.send_welcome_email!r}")
    print(f"- Cleanup task: {app.tasks.maintenance.cleanup_sessions!r}")

    email_result = await send_welcome_email(42, locale="en-GB")
    cleanup_result = await app.tasks.maintenance.cleanup_sessions(14)

    print("\nTask results:")
    print(f"- {email_result}")
    print(f"- Removed {cleanup_result} sessions")

    print("\nApplication diagnostics:")
    print(json.dumps(app.describe(), indent=2, default=str))


asyncio.run(main())
```

### The Verification

Run:

```bash
python examples/14_decorator_registration.py
```

Expected output includes:

```text
Application: PulseQueue(name='notifications', task_count=2)
Task count: 2

Task namespace:
- Email task: Task(name='emails.send_welcome_email', ...)
- Cleanup task: Task(name='maintenance.cleanup_sessions', ...)

Task results:
- welcome email scheduled for user=42, locale=en-GB
- Removed 70 sessions
```

The diagnostic JSON includes task signatures, module names, source locations, configuration, and metadata.

At this stage, calling a task executes it directly:

```python
await send_welcome_email(42)
```

In the concurrency module, we will add a separate submission API so code can place work onto an asynchronous queue rather than immediately running it.

---

## Step 6: Add Tests for Registration and Introspection

### The Target

Add automated tests for task validation, registration, namespaced lookup, and argument validation.

### The Concept

Registration is framework infrastructure. If it behaves incorrectly, every feature built above it becomes unreliable.

We therefore test both the happy path and the important failure paths:

- Async tasks register successfully.
- Synchronous functions are rejected.
- Duplicate names are rejected.
- Namespaced lookups resolve the right task.
- Invalid call arguments fail before execution.

### The Implementation

Create this test module.

## `tests/test_task_registration.py`

```python
"""Tests for task construction, introspection, and application registration."""

from __future__ import annotations

import asyncio

import pytest

from pulsequeue import DuplicateTaskError, PulseQueue, TaskMetadata
from pulsequeue.options import TaskOptions
from pulsequeue.task import Task


def test_task_executes_and_exposes_signature() -> None:
    """A Task should validate and execute its wrapped coroutine function."""

    async def add(left: int, right: int) -> int:
        return left + right

    task = Task(
        add,
        TaskOptions(name="add", queue="math"),
    )

    assert task.name == "math.add"
    assert str(task.signature) == "(left: int, right: int) -> int"
    assert asyncio.run(task(20, 22)) == 42


def test_task_rejects_synchronous_function() -> None:
    """PulseQueue tasks must be async functions for the async worker model."""

    def synchronous_function() -> None:
        return None

    with pytest.raises(TypeError, match="must be declared with 'async def'"):
        Task(
            synchronous_function,
            TaskOptions(name="synchronous_function", queue="invalid"),
        )


def test_task_validates_arguments_before_execution() -> None:
    """Missing or invalid arguments should fail before task execution."""

    async def greet(name: str, *, locale: str = "en-US") -> str:
        return f"{locale}: {name}"

    task = Task(
        greet,
        TaskOptions(name="greet", queue="messages"),
    )

    with pytest.raises(TypeError, match="missing a required argument"):
        asyncio.run(task(locale="en-GB"))


def test_application_decorator_registers_task() -> None:
    """The decorator should return a Task and add it to the application."""

    app = PulseQueue("test_app")

    @app.task(
        queue="emails",
        metadata=TaskMetadata(owner="test-team"),
    )
    async def send_email(user_id: int) -> str:
        return f"sent to {user_id}"

    assert send_email.name == "emails.send_email"
    assert app.task_count == 1
    assert app.get_task("emails.send_email") is send_email
    assert app.tasks.emails.send_email is send_email
    assert send_email.options.meta_owner == "test-team"


def test_application_rejects_duplicate_task_names() -> None:
    """Duplicate stable task names must fail rather than silently overwrite."""

    app = PulseQueue("test_app")

    @app.task(queue="emails", name="send")
    async def first_task() -> None:
        return None

    assert first_task.name == "emails.send"

    with pytest.raises(DuplicateTaskError, match="already registered"):

        @app.task(queue="emails", name="send")
        async def second_task() -> None:
            return None


def test_application_rejects_invalid_queue_name() -> None:
    """Queue names must be usable as namespace attributes."""
    app = PulseQueue("test_app")

    with pytest.raises(ValueError, match="valid Python identifier"):
        app.task(queue="email-jobs")
```

### The Verification

Run all tests:

```bash
python -m pytest -q
```

Expected output:

```text
..............                                                           [100%]
14 passed
```

The exact count may be higher if you created additional tests, but every test should pass.

---

# Phase 1 Reference: Introspection and Decorator APIs

## `inspect.signature(...)`

`inspect.signature(function)` returns an `inspect.Signature` object.

It supports useful operations:

```python
signature = inspect.signature(send_welcome_email)
```

Read a string representation:

```python
print(signature)
```

Validate arguments:

```python
bound = signature.bind(42, locale="en-GB")
```

Apply defaults:

```python
bound.apply_defaults()
```

Inspect parameters:

```python
for name, parameter in signature.parameters.items():
    print(name, parameter.kind, parameter.annotation)
```

This is valuable for a task framework because task calls may eventually be submitted remotely. Validating arguments early produces clear errors close to the caller instead of obscure failures inside a worker.

---

## Why `Task` Uses `functools.update_wrapper`

The `Task` object is not technically a Python function. It is an instance of our `Task` class.

Without metadata copying, users and tools would see less useful information:

```python
send_welcome_email.__name__
send_welcome_email.__doc__
send_welcome_email.__annotations__
```

`functools.update_wrapper(self, function)` copies standard wrapper metadata onto the task object and sets:

```python
task.__wrapped__
```

to the original function.

Tools such as `inspect.signature(...)` understand `__wrapped__`, allowing them to continue presenting the original function signature.

---

## Why We Require `async def` Tasks

This initial framework intentionally accepts only coroutine functions:

```python
@app.task(queue="emails")
async def send_email(user_id: int) -> str:
    ...
```

It rejects:

```python
@app.task(queue="emails")
def send_email(user_id: int) -> str:
    ...
```

This restriction gives the framework a predictable execution model before we introduce workers:

- Every task is awaitable.
- Every task can cooperate with the event loop.
- Timeout and cancellation behavior can be designed consistently.
- The application does not accidentally block the event loop with ordinary synchronous code.

Later, we will deliberately add a separate execution path for CPU-bound synchronous workloads using worker processes. That separation is important: CPU-heavy code should not silently run in the event loop.

---

## Stable Names Versus Python Function Names

A function has a Python identity:

```python
send_welcome_email.__module__
send_welcome_email.__qualname__
```

A framework task also needs a stable operational identity:

```text
emails.send_welcome_email
```

The operational identity is useful for:

- Queue routing.
- Worker lookup.
- Metrics.
- Retry records.
- Logs.
- Configuration.
- External API requests.

In this phase, task names are constructed from:

```text
<queue>.<task_name>
```

For example:

```python
@app.task(queue="emails", name="send_welcome")
async def send_welcome_email(user_id: int) -> str:
    ...
```

creates this framework task name:

```text
emails.send_welcome
```

The Python function name and task name do not have to be identical. That distinction will become useful when code is renamed but an operational task identifier must remain stable.
