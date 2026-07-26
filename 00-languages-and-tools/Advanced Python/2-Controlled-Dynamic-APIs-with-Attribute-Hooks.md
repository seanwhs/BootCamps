# Part 2: Controlled Dynamic APIs with Attribute Hooks

In Part 1, we used descriptors and a metaclass to control how classes are built.

Now we will control what happens **after** a class exists—when code reads or writes attributes on its instances.

This is important for framework development because dynamic APIs can make an interface pleasant to use:

```python
task.delay(42)
task.priority.high()
app.tasks.send_email
```

But dynamic behavior also creates risk. If every missing attribute is silently accepted, spelling mistakes become hidden bugs:

```python
task.delya(42)  # Typo that should fail loudly.
```

Our goal is not “make everything dynamic.” Our goal is:

> Make dynamic behavior explicit, inspectable, validated, and safe.

We will build a small task-configuration object that supports:

- Validated declared attributes through descriptors.
- Controlled dynamic metadata attributes.
- Read-only attribute namespaces.
- Helpful errors for invalid or unknown fields.
- Introspection-friendly behavior.

---

## Step 1: Understand `__getattr__`, `__getattribute__`, and `__setattr__`

### The Target

Create a small script that demonstrates the difference between Python’s three primary attribute hooks:

- `__getattribute__`
- `__getattr__`
- `__setattr__`

### The Concept

When Python evaluates:

```python
object.attribute
```

it normally starts with `__getattribute__`.

If ordinary lookup fails with `AttributeError`, Python may then call `__getattr__`.

When Python evaluates:

```python
object.attribute = value
```

it calls `__setattr__`.

A useful analogy is a hotel:

- `__getattribute__` is the front desk handling **every** guest request.
- `__getattr__` is the lost-and-found desk, used only when the front desk cannot find what was requested.
- `__setattr__` is the records clerk handling new or changed reservations.

Because `__getattribute__` handles every read, it is easy to break Python internals accidentally. Most frameworks should prefer `__getattr__` unless they specifically need to intercept all reads.

### The Implementation

Create the following demonstration file.

## `examples/05_attribute_hooks.py`

```python
"""Demonstrate Python's primary attribute access hooks."""

from __future__ import annotations

from typing import Any


class AttributeDemo:
    """A class that logs attribute reads, missing reads, and assignments."""

    def __init__(self) -> None:
        # object.__setattr__ bypasses this class's custom __setattr__ method.
        # It is useful during initialization when we need direct storage access.
        object.__setattr__(self, "known_value", "available")

    def __getattribute__(self, name: str) -> Any:
        """Run for every attribute read, including method lookups."""
        print(f"__getattribute__ received read request for: {name!r}")

        # Delegate to Python's normal implementation. Calling getattr(self, name)
        # here would recurse forever because getattr invokes __getattribute__ again.
        return object.__getattribute__(self, name)

    def __getattr__(self, name: str) -> str:
        """Run only after normal lookup fails with AttributeError."""
        print(f"__getattr__ received missing attribute: {name!r}")
        return f"<dynamic fallback for {name}>"

    def __setattr__(self, name: str, value: Any) -> None:
        """Run for every ordinary attribute assignment."""
        print(f"__setattr__ received assignment: {name!r} = {value!r}")

        # Delegate direct storage to object.__setattr__ to avoid recursion.
        object.__setattr__(self, name, value)


demo = AttributeDemo()

print("\nReading an existing attribute:")
print(demo.known_value)

print("\nReading a missing attribute:")
print(demo.missing_value)

print("\nAssigning a new attribute:")
demo.new_value = 123

print("\nReading the assigned attribute:")
print(demo.new_value)
```

### The Verification

Run:

```bash
python examples/05_attribute_hooks.py
```

Expected output includes lines similar to:

```text
Reading an existing attribute:
__getattribute__ received read request for: 'known_value'
available

Reading a missing attribute:
__getattribute__ received read request for: 'missing_value'
__getattr__ received missing attribute: 'missing_value'
<dynamic fallback for missing_value>

Assigning a new attribute:
__setattr__ received assignment: 'new_value' = 123
```

The exact number of `__getattribute__` log lines can differ slightly because even looking up methods and internal implementation details involves attribute access.

---

## Step 2: Add a Safe Metadata Container

### The Target

Create a `TaskMetadata` class that allows only approved metadata keys and values.

### The Concept

Task metadata is extra descriptive information attached to a task:

```python
metadata.owner = "platform-team"
metadata.environment = "staging"
```

A plain dictionary works, but it provides weak guidance:

```python
metadata["owenr"] = "platform-team"  # Typo is accepted.
```

A controlled metadata container gives us:

- A fixed approved set of keys.
- Type validation.
- Attribute-style access.
- Explicit errors for misspelled keys.
- A clean dictionary export for logs or serialization.

Think of it as a labeled filing cabinet. You can place documents only in drawers that exist, and each drawer accepts only the appropriate kind of document.

### The Implementation

Create a new module.

## `src/pulsequeue/metadata.py`

```python
"""Controlled dynamic metadata for PulseQueue objects."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from types import MappingProxyType
from typing import Any


class MetadataField:
    """Describe one allowed metadata attribute."""

    __slots__ = ("expected_type", "required")

    def __init__(self, expected_type: type[Any], *, required: bool = False) -> None:
        self.expected_type = expected_type
        self.required = required


class TaskMetadata:
    """A validated, attribute-based container for task metadata.

    Only fields declared in _schema may be assigned. Internal attributes use
    names beginning with an underscore and are stored directly through
    object.__setattr__ to avoid recursive calls to this class's __setattr__.
    """

    _schema: Mapping[str, MetadataField] = MappingProxyType(
        {
            "owner": MetadataField(str),
            "service": MetadataField(str),
            "environment": MetadataField(str),
            "priority": MetadataField(int),
            "trace_id": MetadataField(str),
        }
    )

    def __init__(self, **values: Any) -> None:
        """Initialize the container using the same validation as later writes."""
        object.__setattr__(self, "_values", {})

        for name, value in values.items():
            setattr(self, name, value)

        self._validate_required_fields()

    def __getattr__(self, name: str) -> Any:
        """Return a declared stored value or raise a helpful AttributeError.

        Python invokes this only when ordinary attribute lookup did not find
        the requested name. That keeps methods such as as_dict available
        through normal lookup.
        """
        schema = type(self)._schema

        if name not in schema:
            allowed_fields = ", ".join(sorted(schema))
            raise AttributeError(
                f"{type(self).__name__} does not support metadata field {name!r}. "
                f"Allowed fields: {allowed_fields}."
            )

        values: dict[str, Any] = object.__getattribute__(self, "_values")

        if name not in values:
            raise AttributeError(
                f"Metadata field {name!r} has not been assigned."
            )

        return values[name]

    def __setattr__(self, name: str, value: Any) -> None:
        """Validate writes to declared metadata fields."""
        if name.startswith("_"):
            object.__setattr__(self, name, value)
            return

        schema = type(self)._schema

        if name not in schema:
            allowed_fields = ", ".join(sorted(schema))
            raise AttributeError(
                f"{type(self).__name__} does not support metadata field {name!r}. "
                f"Allowed fields: {allowed_fields}."
            )

        field = schema[name]

        if not isinstance(value, field.expected_type):
            raise TypeError(
                f"Metadata field {name!r} must be a "
                f"{field.expected_type.__name__}, not {type(value).__name__}."
            )

        values: dict[str, Any] = object.__getattribute__(self, "_values")
        values[name] = value

    def _validate_required_fields(self) -> None:
        """Ensure every schema field marked required was provided."""
        values: dict[str, Any] = object.__getattribute__(self, "_values")

        missing_required = [
            name
            for name, field in type(self)._schema.items()
            if field.required and name not in values
        ]

        if missing_required:
            formatted_names = ", ".join(sorted(missing_required))
            raise TypeError(f"Missing required metadata field(s): {formatted_names}")

    def as_dict(self) -> dict[str, Any]:
        """Return a defensive copy suitable for serialization or logging."""
        values: dict[str, Any] = object.__getattribute__(self, "_values")
        return values.copy()

    def keys(self) -> Iterator[str]:
        """Iterate over assigned metadata field names."""
        values: dict[str, Any] = object.__getattribute__(self, "_values")
        return iter(values)

    def __repr__(self) -> str:
        """Return a debugging-friendly representation."""
        return f"{type(self).__name__}({self.as_dict()!r})"
```

Now create an example.

## `examples/06_task_metadata.py`

```python
"""Demonstrate controlled dynamic task metadata."""

from __future__ import annotations

from pulsequeue.metadata import TaskMetadata


metadata = TaskMetadata(
    owner="platform-team",
    service="notification-service",
    environment="development",
    priority=10,
)

print(f"Metadata object: {metadata!r}")
print(f"Owner: {metadata.owner}")
print(f"Priority: {metadata.priority}")
print(f"Dictionary form: {metadata.as_dict()}")
print(f"Assigned keys: {list(metadata.keys())}")

metadata.trace_id = "trace-4c9a7e"

print(f"Trace ID after assignment: {metadata.trace_id}")

try:
    metadata.owenr = "platform-team"
except AttributeError as error:
    print(f"Unknown-field error: {error}")

try:
    metadata.priority = "high"
except TypeError as error:
    print(f"Type-validation error: {error}")

try:
    print(metadata.trace_parent)
except AttributeError as error:
    print(f"Missing-read error: {error}")
```

### The Verification

Run:

```bash
python examples/06_task_metadata.py
```

Expected output includes:

```text
Owner: platform-team
Priority: 10
Trace ID after assignment: trace-4c9a7e
Unknown-field error: TaskMetadata does not support metadata field 'owenr'.
Type-validation error: Metadata field 'priority' must be a int, not str.
Missing-read error: TaskMetadata does not support metadata field 'trace_parent'.
```

The key result is that a typo fails immediately instead of silently producing bad metadata.

---

## Step 3: Build an Immutable Attribute Namespace

### The Target

Create an immutable namespace object for nested task access patterns.

### The Concept

Frameworks often expose grouped objects:

```python
app.tasks.emails.send_welcome
```

At first glance, nested dynamic objects can seem like magic. In reality, they are often just a tree of names.

We will build an immutable `AttributeNamespace` that wraps a mapping and permits safe read-only access through attributes.

For example:

```python
namespace = AttributeNamespace(
    {
        "emails": AttributeNamespace(
            {
                "send_welcome": "task-reference",
            }
        )
    }
)

print(namespace.emails.send_welcome)
```

Immutability means it cannot be changed after construction. This is useful for runtime configuration and registries because accidental modification can otherwise create difficult-to-reproduce bugs.

Think of it as a printed airport map: travelers can look up terminal locations, but they cannot redraw the map while people are using it.

### The Implementation

Create this module.

## `src/pulsequeue/namespace.py`

```python
"""Read-only attribute namespaces for framework-facing APIs."""

from __future__ import annotations

from collections.abc import Iterator, Mapping
from types import MappingProxyType
from typing import Any


class AttributeNamespace:
    """Expose a mapping through validated read-only attribute access."""

    __slots__ = ("_values", "_name")

    def __init__(self, values: Mapping[str, Any], *, name: str = "namespace") -> None:
        """Store an immutable copy after validating public attribute names."""
        normalized_values: dict[str, Any] = {}

        for key, value in values.items():
            self._validate_key(key)
            normalized_values[key] = value

        object.__setattr__(self, "_values", MappingProxyType(normalized_values))
        object.__setattr__(self, "_name", name)

    @staticmethod
    def _validate_key(key: str) -> None:
        """Reject names that cannot safely behave as public Python attributes."""
        if not key.isidentifier():
            raise ValueError(
                f"Namespace key {key!r} is not a valid Python identifier."
            )

        if key.startswith("_"):
            raise ValueError(
                f"Namespace key {key!r} cannot begin with an underscore."
            )

    def __getattr__(self, name: str) -> Any:
        """Resolve a public attribute from the immutable namespace mapping."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")

        try:
            return values[name]
        except KeyError as error:
            namespace_name: str = object.__getattribute__(self, "_name")
            available = ", ".join(sorted(values)) or "<empty>"
            raise AttributeError(
                f"{namespace_name} has no member {name!r}. "
                f"Available members: {available}."
            ) from error

    def __setattr__(self, name: str, value: Any) -> None:
        """Prevent external mutation after construction."""
        raise AttributeError(
            f"{type(self).__name__} is immutable; cannot assign {name!r}."
        )

    def __dir__(self) -> list[str]:
        """Make interactive completion tools show dynamically available names."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return sorted(set(super().__dir__()) | set(values))

    def __iter__(self) -> Iterator[str]:
        """Iterate through available public member names."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return iter(values)

    def __contains__(self, name: object) -> bool:
        """Return whether a member exists in the namespace."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return name in values

    def as_dict(self) -> dict[str, Any]:
        """Return a shallow mutable copy of namespace contents."""
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return dict(values)

    def __repr__(self) -> str:
        """Return a concise representation for debugging."""
        namespace_name: str = object.__getattribute__(self, "_name")
        values: Mapping[str, Any] = object.__getattribute__(self, "_values")
        return f"{type(self).__name__}(name={namespace_name!r}, values={dict(values)!r})"
```

Create a demonstration.

## `examples/07_attribute_namespace.py`

```python
"""Demonstrate a read-only namespace with nested task-like members."""

from __future__ import annotations

from pulsequeue.namespace import AttributeNamespace


email_tasks = AttributeNamespace(
    {
        "send_welcome": "pulsequeue.tasks.emails.send_welcome",
        "send_password_reset": "pulsequeue.tasks.emails.send_password_reset",
    },
    name="app.tasks.emails",
)

tasks = AttributeNamespace(
    {
        "emails": email_tasks,
        "cleanup": "pulsequeue.tasks.cleanup_expired_sessions",
    },
    name="app.tasks",
)

print(f"Welcome task: {tasks.emails.send_welcome}")
print(f"Cleanup task: {tasks.cleanup}")
print(f"Task groups: {list(tasks)}")
print(f"'emails' in tasks: {'emails' in tasks}")
print(f"Completion-friendly names: {[name for name in dir(tasks) if not name.startswith('_')]}")

try:
    print(tasks.billing)
except AttributeError as error:
    print(f"Missing-member error: {error}")

try:
    tasks.cleanup = "replacement"
except AttributeError as error:
    print(f"Immutability error: {error}")

try:
    AttributeNamespace({"not-valid": "value"})
except ValueError as error:
    print(f"Invalid-key error: {error}")
```

### The Verification

Run:

```bash
python examples/07_attribute_namespace.py
```

Expected output includes:

```text
Welcome task: pulsequeue.tasks.emails.send_welcome
Cleanup task: pulsequeue.tasks.cleanup_expired_sessions
'emails' in tasks: True
Missing-member error: app.tasks has no member 'billing'.
Immutability error: AttributeNamespace is immutable; cannot assign 'cleanup'.
Invalid-key error: Namespace key 'not-valid' is not a valid Python identifier.
```

Notice that `dir(tasks)` includes `emails` and `cleanup`. This is a small but important usability feature: it helps IDEs, debuggers, and interactive shells discover dynamic names.

---

## Step 4: Add a Descriptor for Read-Only Computed State

### The Target

Create a `computed_property` descriptor that computes a value when read and prevents accidental assignment.

### The Concept

A computed property is an attribute whose value is calculated from other state rather than stored independently.

For example, a task configuration might have a display label derived from its queue and task name:

```python
config.display_name
```

The value is not a separate piece of data. It is calculated from:

```python
config.queue
config.name
```

Python’s built-in `property` already solves this problem well. We will intentionally implement a compact version ourselves to understand the descriptor mechanism beneath it.

Think of this as a digital dashboard display. The display is not the engine itself; it shows a value calculated from the engine’s current state.

### The Implementation

Create the following module.

## `src/pulsequeue/descriptors.py`

```python
"""Reusable descriptors used by PulseQueue framework objects."""

from __future__ import annotations

from collections.abc import Callable
from typing import Any, Generic, TypeVar, overload

InstanceT = TypeVar("InstanceT")
ValueT = TypeVar("ValueT")


class computed_property(Generic[InstanceT, ValueT]):
    """A minimal read-only descriptor similar to Python's built-in property."""

    def __init__(self, getter: Callable[[InstanceT], ValueT]) -> None:
        self._getter = getter
        self._name = getter.__name__
        self.__doc__ = getter.__doc__

    def __set_name__(self, owner: type[Any], name: str) -> None:
        """Retain the final attribute name assigned in the class body."""
        self._name = name

    @overload
    def __get__(
        self,
        instance: None,
        owner: type[InstanceT],
    ) -> computed_property[InstanceT, ValueT]:
        ...

    @overload
    def __get__(self, instance: InstanceT, owner: type[InstanceT]) -> ValueT:
        ...

    def __get__(
        self,
        instance: InstanceT | None,
        owner: type[InstanceT],
    ) -> computed_property[InstanceT, ValueT] | ValueT:
        """Return descriptor metadata from the class or calculate an instance value."""
        if instance is None:
            return self

        return self._getter(instance)

    def __set__(self, instance: InstanceT, value: ValueT) -> None:
        """Reject assignment because this descriptor exposes derived state."""
        raise AttributeError(
            f"{self._name} is a read-only computed attribute and cannot be assigned."
        )
```

Now create an example that combines `Field` descriptors from Part 1 with the new descriptor.

## `examples/08_computed_property.py`

```python
"""Demonstrate a custom read-only computed-property descriptor."""

from __future__ import annotations

from pulsequeue.descriptors import computed_property
from pulsequeue.model import Field, Model, positive_integer


class TaskConfiguration(Model):
    """A task configuration with stored and derived attributes."""

    name = Field(str)
    queue = Field(str)
    max_retries = Field(int, validator=positive_integer)

    @computed_property
    def display_name(self) -> str:
        """Return a human-friendly identifier derived from stored fields."""
        return f"{self.queue}:{self.name}"

    @computed_property
    def retry_summary(self) -> str:
        """Describe the configured retry count."""
        return f"Task may run up to {self.max_retries} time(s)."


configuration = TaskConfiguration(
    name="send_welcome_email",
    queue="emails",
    max_retries=3,
)

print(f"Display name: {configuration.display_name}")
print(f"Retry summary: {configuration.retry_summary}")
print(f"Descriptor object: {TaskConfiguration.display_name!r}")
print(f"Descriptor documentation: {TaskConfiguration.display_name.__doc__}")

try:
    configuration.display_name = "not allowed"
except AttributeError as error:
    print(f"Read-only error: {error}")
```

### The Verification

Run:

```bash
python examples/08_computed_property.py
```

Expected output includes:

```text
Display name: emails:send_welcome_email
Retry summary: Task may run up to 3 time(s).
Read-only error: display_name is a read-only computed attribute and cannot be assigned.
```

This confirms a descriptor can provide derived state while preventing invalid writes.

---

## Step 5: Build a Dynamic Task Configuration Object

### The Target

Combine the tools from this part into `TaskOptions`, a realistic configuration object for future task definitions.

### The Concept

A task framework needs configuration that is both strict and flexible.

Some values should always be explicitly modeled:

- Task name.
- Queue name.
- Retry count.
- Timeout.

Other values may be optional operational metadata:

- Owning team.
- Service name.
- Trace identifier.
- Deployment environment.

We will combine:

- `Field` descriptors for core configuration.
- `TaskMetadata` for controlled optional metadata.
- `computed_property` for derived task identity.
- `__getattr__` to expose metadata through a deliberate `meta_` prefix.

The `meta_` prefix is an important guardrail:

```python
options.meta_owner
options.meta_environment
```

This prevents metadata names from accidentally colliding with real framework attributes such as `name`, `queue`, or `timeout_seconds`.

### The Implementation

Create the following module.

## `src/pulsequeue/options.py`

```python
"""Validated task configuration with controlled dynamic metadata access."""

from __future__ import annotations

from typing import Any

from pulsequeue.descriptors import computed_property
from pulsequeue.metadata import TaskMetadata
from pulsequeue.model import Field, Model, positive_integer


def non_negative_float(value: float) -> None:
    """Reject negative timeout values while allowing zero for no timeout."""
    if value < 0:
        raise ValueError("Value must be zero or greater.")


class TaskOptions(Model):
    """Configuration for one task registered with PulseQueue.

    Core fields are declared directly and validated through Field descriptors.
    Optional metadata is held in a separate TaskMetadata object.

    Metadata can be read through explicit dynamic names such as meta_owner.
    The prefix keeps dynamic names from shadowing or colliding with the
    framework's regular public API.
    """

    name = Field(str)
    queue = Field(str)
    max_retries = Field(int, validator=positive_integer)
    timeout_seconds = Field(float, validator=non_negative_float)
    metadata = Field(TaskMetadata, required=False)

    def __init__(
        self,
        *,
        name: str,
        queue: str,
        max_retries: int = 1,
        timeout_seconds: float = 0.0,
        metadata: TaskMetadata | None = None,
    ) -> None:
        """Create validated task options with an empty metadata object by default."""
        super().__init__(
            name=name,
            queue=queue,
            max_retries=max_retries,
            timeout_seconds=timeout_seconds,
            metadata=metadata if metadata is not None else TaskMetadata(),
        )

    @computed_property
    def qualified_name(self) -> str:
        """Return a stable queue-qualified task identifier."""
        return f"{self.queue}.{self.name}"

    @computed_property
    def has_timeout(self) -> bool:
        """Return whether execution should enforce a timeout."""
        return self.timeout_seconds > 0.0

    def __getattr__(self, name: str) -> Any:
        """Resolve explicitly prefixed dynamic metadata reads.

        This hook runs only after normal lookup fails. Therefore declared
        Field descriptors, methods, and computed properties remain ordinary,
        predictable attributes.
        """
        metadata_prefix = "meta_"

        if not name.startswith(metadata_prefix):
            raise AttributeError(
                f"{type(self).__name__} has no attribute {name!r}. "
                "Dynamic metadata reads must use the 'meta_' prefix, "
                "for example 'meta_owner'."
            )

        metadata_name = name.removeprefix(metadata_prefix)

        if not metadata_name:
            raise AttributeError(
                "Metadata attribute name cannot be empty; use a name such as "
                "'meta_owner'."
            )

        try:
            return getattr(self.metadata, metadata_name)
        except AttributeError as error:
            raise AttributeError(
                f"{type(self).__name__} could not resolve metadata attribute "
                f"{name!r}: {error}"
            ) from error

    def __setattr__(self, name: str, value: Any) -> None:
        """Reject dynamic metadata writes and preserve normal descriptor behavior."""
        if name.startswith("meta_"):
            raise AttributeError(
                "Dynamic metadata is read-only through TaskOptions. "
                "Assign metadata through the 'metadata' object, for example "
                "'options.metadata.owner = \"platform-team\"'."
            )

        # Model itself does not override __setattr__, so delegating to super()
        # preserves standard descriptor handling for declared Field objects.
        super().__setattr__(name, value)
```

Now add an example.

## `examples/09_task_options.py`

```python
"""Demonstrate task options with explicit dynamic metadata reads."""

from __future__ import annotations

from pulsequeue.metadata import TaskMetadata
from pulsequeue.options import TaskOptions


options = TaskOptions(
    name="send_welcome_email",
    queue="emails",
    max_retries=3,
    timeout_seconds=15.0,
    metadata=TaskMetadata(
        owner="platform-team",
        service="notifications",
        environment="development",
        priority=5,
    ),
)

print(f"Qualified task name: {options.qualified_name}")
print(f"Has timeout: {options.has_timeout}")
print(f"Task owner through dynamic API: {options.meta_owner}")
print(f"Task environment through dynamic API: {options.meta_environment}")
print(f"Full metadata: {options.metadata.as_dict()}")

options.metadata.trace_id = "trace-001"
print(f"Trace ID through dynamic API: {options.meta_trace_id}")

try:
    print(options.owner)
except AttributeError as error:
    print(f"Unprefixed dynamic-read error: {error}")

try:
    options.meta_owner = "another-team"
except AttributeError as error:
    print(f"Dynamic-write error: {error}")

try:
    print(options.meta_missing_value)
except AttributeError as error:
    print(f"Missing-metadata error: {error}")
```

### The Verification

Run:

```bash
python examples/09_task_options.py
```

Expected output includes:

```text
Qualified task name: emails.send_welcome_email
Has timeout: True
Task owner through dynamic API: platform-team
Task environment through dynamic API: development
Trace ID through dynamic API: trace-001
Unprefixed dynamic-read error: TaskOptions has no attribute 'owner'.
Dynamic-write error: Dynamic metadata is read-only through TaskOptions.
Missing-metadata error: TaskOptions could not resolve metadata attribute 'meta_missing_value':
```

The final error message continues with details about the allowed metadata fields. That detail is useful because it helps a developer correct a mistake without searching through source code.

---

## Step 6: Add Tests for Dynamic Behavior

### The Target

Add automated tests for the dynamic API rules we just built.

### The Concept

Dynamic behavior is convenient, but it is also easy to break during refactoring.

Tests act like safety rails on a mountain road. They do not drive the car for you, but they prevent small mistakes from becoming a dangerous fall.

We will use `pytest`, a popular Python test framework.

### The Implementation

Install the development dependency:

```bash
python -m pip install pytest
```

Create the test file.

## `tests/test_dynamic_attributes.py`

```python
"""Tests for controlled dynamic attribute behavior."""

from __future__ import annotations

import pytest

from pulsequeue.metadata import TaskMetadata
from pulsequeue.namespace import AttributeNamespace
from pulsequeue.options import TaskOptions


def test_metadata_accepts_declared_fields() -> None:
    """Declared metadata fields should be writable and readable."""
    metadata = TaskMetadata(owner="platform-team", priority=10)

    assert metadata.owner == "platform-team"
    assert metadata.priority == 10
    assert metadata.as_dict() == {
        "owner": "platform-team",
        "priority": 10,
    }


def test_metadata_rejects_unknown_fields() -> None:
    """A spelling mistake must fail instead of creating arbitrary data."""
    metadata = TaskMetadata()

    with pytest.raises(AttributeError, match="does not support metadata field"):
        metadata.owenr = "platform-team"


def test_metadata_rejects_invalid_value_type() -> None:
    """Metadata fields should validate their declared types."""
    metadata = TaskMetadata()

    with pytest.raises(TypeError, match="must be a int"):
        metadata.priority = "high"


def test_namespace_exposes_members_through_attributes() -> None:
    """A namespace should expose valid configured keys as attributes."""
    namespace = AttributeNamespace(
        {"send_email": "task-reference"},
        name="app.tasks",
    )

    assert namespace.send_email == "task-reference"
    assert "send_email" in namespace
    assert list(namespace) == ["send_email"]


def test_namespace_rejects_mutation() -> None:
    """A namespace must remain immutable after construction."""
    namespace = AttributeNamespace({"send_email": "task-reference"})

    with pytest.raises(AttributeError, match="immutable"):
        namespace.send_email = "replacement"


def test_task_options_expose_prefixed_metadata() -> None:
    """TaskOptions should allow deliberate prefixed metadata reads."""
    options = TaskOptions(
        name="send_email",
        queue="emails",
        metadata=TaskMetadata(owner="platform-team"),
    )

    assert options.qualified_name == "emails.send_email"
    assert options.meta_owner == "platform-team"


def test_task_options_reject_unprefixed_dynamic_metadata() -> None:
    """Metadata must not silently shadow the regular task-options API."""
    options = TaskOptions(
        name="send_email",
        queue="emails",
        metadata=TaskMetadata(owner="platform-team"),
    )

    with pytest.raises(AttributeError, match="Dynamic metadata reads must use"):
        _ = options.owner


def test_task_options_reject_dynamic_metadata_assignment() -> None:
    """TaskOptions should direct metadata writes to its metadata object."""
    options = TaskOptions(name="send_email", queue="emails")

    with pytest.raises(AttributeError, match="read-only through TaskOptions"):
        options.meta_owner = "platform-team"
```

### The Verification

Run the complete test suite:

```bash
python -m pytest -q
```

Expected output:

```text
........                                                                 [100%]
8 passed
```

If you have added additional tests locally, your test count may be higher. The important result is that all tests pass.

---

# Phase 1 Reference: Dynamic Attribute APIs

## `__getattr__` Versus `__getattribute__`

Use `__getattr__` when you need a fallback only for missing attributes:

```python
def __getattr__(self, name: str) -> object:
    ...
```

This is usually the safer option for dynamic APIs because normal methods, descriptors, and real instance fields continue to work normally.

Use `__getattribute__` only when you deliberately need to intercept every read:

```python
def __getattribute__(self, name: str) -> object:
    ...
```

If you override it, delegate with:

```python
return object.__getattribute__(self, name)
```

Do **not** write this inside `__getattribute__`:

```python
return getattr(self, name)
```

That code recursively invokes `__getattribute__` until Python raises a `RecursionError`.

---

## The Difference Between `setattr` and `object.__setattr__`

These two operations are not interchangeable:

```python
setattr(instance, "name", "value")
```

This uses ordinary attribute rules and can invoke:

- `instance.__setattr__`
- descriptor `__set__` methods

By contrast:

```python
object.__setattr__(instance, "name", "value")
```

writes using the base object implementation and bypasses a custom `__setattr__` method.

Use `object.__setattr__` carefully for internal state in objects that override attribute assignment. It is an internal escape hatch, not a general replacement for ordinary assignment.

---

## Why Dynamic APIs Need Clear Boundaries

Unbounded dynamic APIs are tempting:

```python
def __getattr__(self, name: str) -> object:
    return self._anything[name]
```

But they can create several problems:

1. **Typos become runtime behavior** instead of immediate errors.
2. **IDE completion becomes poor** because valid names are invisible.
3. **Name collisions happen** when a dynamic key matches a real method.
4. **Refactoring becomes dangerous** because adding a method may change existing dynamic lookups.
5. **Security boundaries blur** when user-controlled names influence attribute access.

The guardrails in this part solve those issues:

- A declared schema in `TaskMetadata`.
- Explicit `meta_` prefixes in `TaskOptions`.
- Validation for namespace member names.
- Read-only namespace objects.
- `__dir__` support for discoverability.
- Tests for failure paths, not only success paths.

---

## Descriptor Precedence Matters

Our `TaskOptions` class has both descriptors and `__getattr__`.

When code runs:

```python
options.name
```

Python finds `name` as a `Field` descriptor first.

When code runs:

```python
options.qualified_name
```

Python finds `qualified_name` as a `computed_property` descriptor.

When code runs:

```python
options.meta_owner
```

normal lookup fails, so Python calls `TaskOptions.__getattr__`.

That sequence gives us a clean hierarchy:

```text
Declared framework API
        ↓
Descriptor-backed fields and computed values
        ↓
Explicit dynamic fallback API
        ↓
Helpful AttributeError
```

This is the pattern we will carry into the framework’s later task registry and application interface.
