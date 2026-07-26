# Part 1: Python’s Class Creation Pipeline

Before building dynamic task registration for `pulsequeue`, we need to understand a foundational fact:

> In Python, a `class` statement is executable code that produces a class object at runtime.

A normal class creates **instances**:

```python
user = User()
```

A **metaclass** creates the `User` class itself.

This part builds a small, practical model framework that demonstrates:

- How Python executes a class body.
- How descriptors receive their attribute names.
- How a metaclass receives the completed class definition.
- How a base class can automatically collect subclasses.
- How runtime introspection exposes the resulting architecture.

We will use these same building blocks later to register task classes and framework plugins automatically.

---

## Step 1: Create the Project Package

### The Target

Create the initial installable Python package layout for the `pulsequeue` framework.

### The Concept

A Python package is a directory of Python modules that Python can import as one unit.

Think of the project root as a building and `src/pulsequeue/` as the secure workshop containing the actual framework code. Using a `src/` layout prevents Python from accidentally importing source files from the current directory instead of the installed package.

### The Implementation

From the `mastering-python/` directory created in Part 0, run:

```bash
mkdir -p src/pulsequeue
mkdir -p examples
mkdir -p tests
```

Create the following configuration file.

## `pyproject.toml`

```toml
[build-system]
requires = ["setuptools>=69"]
build-backend = "setuptools.build_meta"

[project]
name = "pulsequeue"
version = "0.1.0"
description = "An educational high-concurrency Python task framework."
requires-python = ">=3.12"
authors = [
    { name = "PulseQueue Tutorial" }
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.12",
]

[tool.setuptools]
package-dir = { "" = "src" }

[tool.setuptools.packages.find]
where = ["src"]
```

Now create the package initializer.

## `src/pulsequeue/__init__.py`

```python
"""PulseQueue: an educational high-concurrency task framework."""

__version__ = "0.1.0"
```

Install the package in **editable mode**. Editable mode means the environment points to your working source directory, so code changes are immediately reflected without reinstalling after every edit.

```bash
python -m pip install --editable .
```

### The Verification

Run this command:

```bash
python -c "import pulsequeue; print(pulsequeue.__version__)"
```

Expected output:

```text
0.1.0
```

Also confirm where Python imported the package from:

```bash
python -c "import pulsequeue; print(pulsequeue.__file__)"
```

The path should end in something similar to:

```text
mastering-python/src/pulsequeue/__init__.py
```

---

## Step 2: Observe That a Class Body Is Executed

### The Target

Create a small script that makes Python’s class execution behavior visible.

### The Concept

When Python encounters:

```python
class Example:
    ...
```

it does not simply store text for later. It performs a sequence roughly like this:

1. Determine which metaclass should create the class.
2. Ask the metaclass for a namespace—a dictionary-like workspace for the class body.
3. Execute the indented class body inside that namespace.
4. Give the completed namespace to the metaclass.
5. Receive a new class object.
6. Assign that class object to the name `Example`.

A class body can therefore run ordinary Python statements, including function calls.

This is similar to filling out an application form before it is processed. The body fills in the fields; the metaclass receives the completed form and creates the final class object.

### The Implementation

Create this example file.

## `examples/01_class_body_execution.py`

```python
"""Demonstrate that Python executes class bodies during class creation."""

from __future__ import annotations


def announce(message: str) -> str:
    """Print a message and return it so the call can be used in a class body."""
    print(f"[class-body] {message}")
    return message


print("[module] Before the class statement")


class Notification:
    """A class whose body contains ordinary executable Python statements."""

    print("[class-body] Entering Notification's class body")

    category = announce("Creating the 'category' class attribute")
    retry_limit = 3

    print("[class-body] Leaving Notification's class body")


print("[module] After the class statement")
print(f"[module] Notification is now a class object: {Notification!r}")
print(f"[module] Notification.category = {Notification.category!r}")
print(f"[module] Notification.retry_limit = {Notification.retry_limit}")
```

### The Verification

Run:

```bash
python examples/01_class_body_execution.py
```

Expected output:

```text
[module] Before the class statement
[class-body] Entering Notification's class body
[class-body] Creating the 'category' class attribute
[class-body] Leaving Notification's class body
[module] After the class statement
[module] Notification is now a class object: <class '__main__.Notification'>
[module] Notification.category = "Creating the 'category' class attribute"
[module] Notification.retry_limit = 3
```

The important observation is the ordering:

- The `Notification` class body ran **before** the line after the class statement.
- `Notification` only became available as a class object after Python finished building it.

---

## Step 3: Create a Validating Descriptor

### The Target

Build a reusable `Field` descriptor that validates values assigned to class attributes.

### The Concept

A **descriptor** is an object stored on a class that controls access to an attribute.

For example, this assignment:

```python
job.name = "generate-report"
```

normally stores `"generate-report"` directly on `job`.

But if `name` is a descriptor, Python delegates the operation to the descriptor’s `__set__` method. The descriptor becomes a gatekeeper.

Think of a descriptor as a receptionist for a particular attribute:

- `__get__` handles read requests.
- `__set__` handles write requests.
- `__set_name__` tells the receptionist which office door it is responsible for.

This pattern is useful when a framework needs consistent validation, transformation, instrumentation, or lazy loading.

### The Implementation

Create the model module.

## `src/pulsequeue/model.py`

```python
"""Small metaprogramming primitives used throughout the PulseQueue tutorial."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any


class Field:
    """A validating data descriptor for model attributes.

    A data descriptor defines __set__ or __delete__. Data descriptors take
    priority over attributes stored directly in an instance's __dict__.
    That precedence lets this object reliably validate every assignment.
    """

    def __init__(
        self,
        expected_type: type[Any],
        *,
        required: bool = True,
        validator: Callable[[Any], None] | None = None,
    ) -> None:
        self.expected_type = expected_type
        self.required = required
        self.validator = validator

        # Python calls __set_name__ later, during class creation.
        self.name: str | None = None
        self.storage_name: str | None = None

    def __set_name__(self, owner: type[Any], name: str) -> None:
        """Receive the owning class and assigned attribute name.

        This hook runs once per descriptor assignment in a class body.
        We use a private, collision-resistant storage key for instance data.
        """
        self.name = name
        self.storage_name = f"_{owner.__name__}__field_{name}"

    def __get__(self, instance: object | None, owner: type[Any]) -> Any:
        """Return the descriptor itself from the class or a stored instance value."""
        if instance is None:
            # Access such as Job.name should expose descriptor metadata.
            return self

        if self.storage_name is None or self.name is None:
            raise RuntimeError("Field was accessed before __set_name__ completed.")

        try:
            return vars(instance)[self.storage_name]
        except KeyError as error:
            if self.required:
                raise AttributeError(
                    f"{owner.__name__}.{self.name} has not been assigned."
                ) from error
            return None

    def __set__(self, instance: object, value: Any) -> None:
        """Validate and store an assigned value."""
        if self.storage_name is None or self.name is None:
            raise RuntimeError("Field was assigned before __set_name__ completed.")

        if value is None:
            if self.required:
                raise TypeError(f"{self.name} is required and cannot be None.")
            vars(instance)[self.storage_name] = None
            return

        if not isinstance(value, self.expected_type):
            expected_name = self.expected_type.__name__
            actual_name = type(value).__name__
            raise TypeError(
                f"{self.name} must be a {expected_name}, not a {actual_name}."
            )

        if self.validator is not None:
            self.validator(value)

        vars(instance)[self.storage_name] = value


def positive_integer(value: int) -> None:
    """Reject zero and negative integer values."""
    if value <= 0:
        raise ValueError("Value must be greater than zero.")
```

Now create an executable demonstration.

## `examples/02_descriptor_validation.py`

```python
"""Demonstrate descriptor-based validation."""

from __future__ import annotations

from pulsequeue.model import Field, positive_integer


class RetryPolicy:
    """A simple object with validated attributes."""

    name = Field(str)
    max_attempts = Field(int, validator=positive_integer)
    backoff_seconds = Field(float, required=False)

    def __init__(
        self,
        name: str,
        max_attempts: int,
        backoff_seconds: float | None = None,
    ) -> None:
        self.name = name
        self.max_attempts = max_attempts
        self.backoff_seconds = backoff_seconds


policy = RetryPolicy(
    name="network-retry",
    max_attempts=3,
    backoff_seconds=0.5,
)

print(f"Policy name: {policy.name}")
print(f"Maximum attempts: {policy.max_attempts}")
print(f"Backoff: {policy.backoff_seconds}")
print(f"Descriptor attribute name: {RetryPolicy.name.name}")
print(f"Private storage key: {RetryPolicy.name.storage_name}")
print(f"Stored instance data: {vars(policy)}")

try:
    policy.max_attempts = 0
except ValueError as error:
    print(f"Validation error: {error}")

try:
    policy.name = 123
except TypeError as error:
    print(f"Type error: {error}")
```

### The Verification

Run:

```bash
python examples/02_descriptor_validation.py
```

Expected output should include:

```text
Policy name: network-retry
Maximum attempts: 3
Backoff: 0.5
Descriptor attribute name: name
Private storage key: _RetryPolicy__field_name
Stored instance data: {'_RetryPolicy__field_name': 'network-retry', ...}
Validation error: Value must be greater than zero.
Type error: name must be a str, not a int.
```

The exact ordering of keys in the displayed dictionary is not important.

Notice that assigning `policy.max_attempts = 0` did not silently accept an invalid value. Python called `Field.__set__`, which enforced the rule.

---

## Step 4: Create a Metaclass That Collects Fields and Registers Models

### The Target

Create a `ModelMeta` metaclass that automatically:

1. Collects `Field` descriptors from a class definition.
2. Includes inherited fields.
3. Registers concrete model classes by name.

### The Concept

A metaclass receives the entire completed class namespace before the class is finalized.

This is the right time to inspect declarations such as:

```python
class Task:
    task_name = Field(str)
    priority = Field(int)
```

The metaclass can recognize those fields and attach structured metadata to the resulting class.

Think of this as an airport check-in desk:

- The class body fills out the passenger’s details.
- The metaclass checks the completed details.
- It validates and organizes them.
- It records the result in a registry so other parts of the framework can find it later.

A **registry** is simply a mapping that lets code locate objects by a stable key. In a task framework, a registry will later map task names to runnable task definitions.

### The Implementation

Replace the full contents of `src/pulsequeue/model.py` with the following expanded version.

## `src/pulsequeue/model.py`

```python
"""Small metaprogramming primitives used throughout the PulseQueue tutorial."""

from __future__ import annotations

from collections.abc import Callable, Mapping
from types import MappingProxyType
from typing import Any


class Field:
    """A validating data descriptor for model attributes.

    A data descriptor defines __set__ or __delete__. Data descriptors take
    priority over attributes stored directly in an instance's __dict__.
    That precedence lets this object reliably validate every assignment.
    """

    def __init__(
        self,
        expected_type: type[Any],
        *,
        required: bool = True,
        validator: Callable[[Any], None] | None = None,
    ) -> None:
        self.expected_type = expected_type
        self.required = required
        self.validator = validator

        # Python calls __set_name__ later, during class creation.
        self.name: str | None = None
        self.storage_name: str | None = None

    def __set_name__(self, owner: type[Any], name: str) -> None:
        """Receive the owning class and assigned attribute name."""
        self.name = name
        self.storage_name = f"_{owner.__name__}__field_{name}"

    def __get__(self, instance: object | None, owner: type[Any]) -> Any:
        """Return the descriptor itself from the class or a stored instance value."""
        if instance is None:
            return self

        if self.storage_name is None or self.name is None:
            raise RuntimeError("Field was accessed before __set_name__ completed.")

        try:
            return vars(instance)[self.storage_name]
        except KeyError as error:
            if self.required:
                raise AttributeError(
                    f"{owner.__name__}.{self.name} has not been assigned."
                ) from error
            return None

    def __set__(self, instance: object, value: Any) -> None:
        """Validate and store an assigned value."""
        if self.storage_name is None or self.name is None:
            raise RuntimeError("Field was assigned before __set_name__ completed.")

        if value is None:
            if self.required:
                raise TypeError(f"{self.name} is required and cannot be None.")
            vars(instance)[self.storage_name] = None
            return

        if not isinstance(value, self.expected_type):
            expected_name = self.expected_type.__name__
            actual_name = type(value).__name__
            raise TypeError(
                f"{self.name} must be a {expected_name}, not a {actual_name}."
            )

        if self.validator is not None:
            self.validator(value)

        vars(instance)[self.storage_name] = value


class ModelMeta(type):
    """Create model classes and retain their declared Field descriptors."""

    _registry: dict[str, type[Model]] = {}

    def __new__(
        mcls,
        name: str,
        bases: tuple[type[Any], ...],
        namespace: dict[str, Any],
        **kwargs: Any,
    ) -> type[Model]:
        """Build a class, collect fields, and register non-abstract models."""
        # Gather inherited fields first. A child can intentionally replace an
        # inherited field by declaring another Field using the same name.
        inherited_fields: dict[str, Field] = {}
        for base in bases:
            base_fields = getattr(base, "__fields__", {})
            inherited_fields.update(base_fields)

        declared_fields = {
            attribute_name: attribute_value
            for attribute_name, attribute_value in namespace.items()
            if isinstance(attribute_value, Field)
        }

        all_fields = {**inherited_fields, **declared_fields}

        # type.__new__ performs the normal class construction process,
        # including calls to every descriptor's __set_name__ method.
        created_class = super().__new__(mcls, name, bases, namespace, **kwargs)

        # MappingProxyType creates a read-only view. Framework consumers may
        # inspect field metadata but cannot accidentally mutate it.
        created_class.__fields__ = MappingProxyType(all_fields)

        is_abstract = namespace.get("__abstract__", False)
        if not is_abstract:
            registry_key = f"{created_class.__module__}.{created_class.__qualname__}"

            if registry_key in mcls._registry:
                raise ValueError(
                    f"A model is already registered with key {registry_key!r}."
                )

            mcls._registry[registry_key] = created_class

        return created_class

    @classmethod
    def registered_models(mcls) -> Mapping[str, type[Model]]:
        """Return a read-only view of all concrete model classes."""
        return MappingProxyType(mcls._registry.copy())


class Model(metaclass=ModelMeta):
    """Base class for framework model objects."""

    __abstract__ = True
    __fields__: Mapping[str, Field]

    def __init__(self, **values: Any) -> None:
        """Assign declared fields and reject unknown or missing required values."""
        unknown_names = set(values) - set(self.__fields__)
        if unknown_names:
            formatted_names = ", ".join(sorted(unknown_names))
            raise TypeError(f"Unknown field(s): {formatted_names}")

        for field_name, field in self.__fields__.items():
            if field_name in values:
                setattr(self, field_name, values[field_name])
            elif field.required:
                raise TypeError(f"Missing required field: {field_name}")
            else:
                setattr(self, field_name, None)

    def as_dict(self) -> dict[str, Any]:
        """Return declared model values as an ordinary dictionary."""
        return {
            field_name: getattr(self, field_name)
            for field_name in self.__fields__
        }


def positive_integer(value: int) -> None:
    """Reject zero and negative integer values."""
    if value <= 0:
        raise ValueError("Value must be greater than zero.")
```

Now add an example that uses the metaclass.

## `examples/03_metaclass_registry.py`

```python
"""Demonstrate automatic field collection and model registration."""

from __future__ import annotations

from pulsequeue.model import Field, Model, ModelMeta, positive_integer


class TaskDefinition(Model):
    """A concrete framework model describing a task."""

    name = Field(str)
    queue = Field(str)
    max_retries = Field(int, validator=positive_integer)
    timeout_seconds = Field(float, required=False)


class EmailTaskDefinition(TaskDefinition):
    """A specialized task model that inherits TaskDefinition's fields."""

    sender_address = Field(str)


task = EmailTaskDefinition(
    name="send-welcome-email",
    queue="emails",
    max_retries=3,
    timeout_seconds=10.0,
    sender_address="noreply@example.com",
)

print("Task values:")
print(task.as_dict())

print("\nFields inherited and declared by EmailTaskDefinition:")
for field_name, field in EmailTaskDefinition.__fields__.items():
    print(
        f"- {field_name}: expected_type={field.expected_type.__name__}, "
        f"required={field.required}"
    )

print("\nRegistered concrete models:")
for registry_key, model_class in ModelMeta.registered_models().items():
    print(f"- {registry_key} -> {model_class.__name__}")

try:
    EmailTaskDefinition(
        name="broken-task",
        queue="emails",
        max_retries=1,
        sender_address="noreply@example.com",
        unknown_value="not allowed",
    )
except TypeError as error:
    print(f"\nUnknown-field error: {error}")

try:
    EmailTaskDefinition(
        name="missing-retries",
        queue="emails",
        sender_address="noreply@example.com",
    )
except TypeError as error:
    print(f"Missing-field error: {error}")
```

### The Verification

Run:

```bash
python examples/03_metaclass_registry.py
```

Expected output includes:

```text
Task values:
{'name': 'send-welcome-email', 'queue': 'emails', 'max_retries': 3, 'timeout_seconds': 10.0, 'sender_address': 'noreply@example.com'}

Fields inherited and declared by EmailTaskDefinition:
- name: expected_type=str, required=True
- queue: expected_type=str, required=True
- max_retries: expected_type=int, required=True
- timeout_seconds: expected_type=float, required=False
- sender_address: expected_type=str, required=True

Registered concrete models:
- __main__.TaskDefinition -> TaskDefinition
- __main__.EmailTaskDefinition -> EmailTaskDefinition
```

You should also see the unknown-field and missing-field errors.

This confirms that:

- `ModelMeta` collected fields automatically.
- `EmailTaskDefinition` inherited fields from `TaskDefinition`.
- Concrete subclasses were registered.
- The `Model` constructor enforced the declared schema.

---

## Step 5: Introspect the Class Creation Result

### The Target

Inspect the relationships between an instance, its class, and its metaclass.

### The Concept

**Introspection** means asking a running program about its own objects.

Python makes this unusually accessible:

- `type(instance)` returns the instance’s class.
- `type(class_object)` returns the class’s metaclass.
- `Class.__mro__` shows the method resolution order (MRO): the ordered list Python searches when looking up inherited attributes.
- `inspect` provides safe helpers for examining classes and functions.

Think of introspection as a building’s maintenance panel. It does not change the wiring; it lets you inspect how the wiring is arranged.

### The Implementation

Create the following file.

## `examples/04_introspection.py`

```python
"""Inspect an instance, its class, and its metaclass."""

from __future__ import annotations

import inspect

from pulsequeue.model import Field, Model, ModelMeta


class AuditEvent(Model):
    """A model that could represent a task lifecycle event."""

    event_name = Field(str)
    task_id = Field(str)


event = AuditEvent(
    event_name="task.started",
    task_id="task-123",
)

print(f"Instance: {event!r}")
print(f"Instance type: {type(event).__name__}")
print(f"Class object: {AuditEvent!r}")
print(f"Metaclass: {type(AuditEvent).__name__}")
print(f"AuditEvent uses ModelMeta: {isinstance(AuditEvent, ModelMeta)}")

print("\nMethod resolution order:")
for class_in_mro in AuditEvent.__mro__:
    print(f"- {class_in_mro.__module__}.{class_in_mro.__qualname__}")

print("\nDeclared and inherited fields:")
for name, field in AuditEvent.__fields__.items():
    print(
        f"- {name}: descriptor={field!r}, "
        f"expected type={field.expected_type.__name__}"
    )

print("\nClass inspection:")
print(f"Is AuditEvent a class? {inspect.isclass(AuditEvent)}")
print(f"Is event a class? {inspect.isclass(event)}")
print(f"AuditEvent constructor signature: {inspect.signature(AuditEvent)}")
print(f"Model.as_dict signature: {inspect.signature(Model.as_dict)}")
```

### The Verification

Run:

```bash
python examples/04_introspection.py
```

Expected output includes:

```text
Instance type: AuditEvent
Metaclass: ModelMeta
AuditEvent uses ModelMeta: True
```

The method resolution order should list these classes in order:

```text
__main__.AuditEvent
pulsequeue.model.Model
builtins.object
```

The constructor signature may vary slightly depending on your Python version, but the command should complete without an exception.

---

# Phase 1 Reference: Class Creation and Attribute Access

## The Simplified Class-Creation Sequence

For this declaration:

```python
class EmailTaskDefinition(TaskDefinition):
    sender_address = Field(str)
```

Python performs a process conceptually similar to:

```python
namespace = ModelMeta.__prepare__(
    "EmailTaskDefinition",
    (TaskDefinition,),
)

exec(
    """
sender_address = Field(str)
""",
    globals(),
    namespace,
)

EmailTaskDefinition = ModelMeta(
    "EmailTaskDefinition",
    (TaskDefinition,),
    namespace,
)
```

Our `ModelMeta.__new__` runs during the final construction step.

The actual implementation details contain additional language-level behavior, but this model is sufficient for designing reliable framework code.

---

## Descriptor Lookup Priority

When Python evaluates:

```python
instance.attribute
```

its lookup behavior is more nuanced than a simple dictionary access.

A useful simplified order is:

1. A **data descriptor** on the class, such as our `Field`, gets first chance.
2. The instance dictionary is checked.
3. A non-data descriptor or ordinary class attribute is checked.
4. `__getattr__` is called if normal lookup failed and the class defines it.

Because `Field` defines `__set__`, it is a data descriptor. This is why validation cannot be bypassed by merely assigning a value with ordinary attribute syntax.

---

## Why `vars(instance)` Was Used

Our descriptor stores values using:

```python
vars(instance)[self.storage_name] = value
```

For normal objects, `vars(instance)` returns the same dictionary as:

```python
instance.__dict__
```

We use `vars()` because it clearly communicates that we are intentionally interacting with an object’s attribute storage.

Later, when we discuss `__slots__`, we will see that some memory-optimized objects intentionally do not have an instance dictionary. At that point, descriptor storage strategies need to change.

---

## When Not to Use a Metaclass

Metaclasses are appropriate when behavior must apply automatically at **class-definition time**, such as:

- Collecting declarative fields.
- Registering subclasses.
- Validating class-level configuration.
- Building framework APIs from class declarations.

Do not reach for a metaclass when a simpler tool will work:

| Need | Prefer |
|---|---|
| Wrap a function | Decorator |
| Initialize each instance | `__init__` |
| Validate one attribute | Descriptor or `property` |
| Register a class manually | Ordinary function call |
| Customize missing attributes | `__getattr__` |
| Customize every attribute read | Carefully considered `__getattribute__` |

A metaclass affects every class that uses it, which makes it powerful but also increases the mental cost for future maintainers.
