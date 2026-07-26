# Appendix D: Decorator Patterns, Typing, and Common Pitfalls

Decorators are one of Python’s most powerful features—and one of the easiest ways to make code harder to understand when used carelessly.

This appendix is a reference for writing decorators that are:

- Readable
- Type-safe
- Testable
- Predictable
- Appropriate for production code

Use decorators to add reusable behavior around functions or methods, such as:

- Logging
- Timing
- Validation
- Retries
- Caching
- Access control
- Tracing

Do not use decorators simply because they are clever.

---

# D.1 Decorator Mental Model

A decorator receives a function and returns another callable.

```python
def decorate(function):
    def wrapper():
        return function()

    return wrapper
```

Applied with syntax:

```python
@decorate
def greet() -> str:
    return "Hello"
```

Python interprets that as:

```python
def greet() -> str:
    return "Hello"

greet = decorate(greet)
```

When you call:

```python
greet()
```

you are calling `wrapper()`, which can run extra code before and after calling the original function.

---

# D.2 Minimal Correct Decorator

A general-purpose decorator needs to forward arbitrary positional and keyword arguments.

```python
from collections.abc import Callable
from functools import wraps
from typing import Any


def announce_call(function: Callable[..., Any]) -> Callable[..., Any]:
    """Add a simple message before the wrapped function runs."""

    @wraps(function)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        """Run the wrapped function after announcing it."""
        print(f"Calling {function.__name__}...")
        return function(*args, **kwargs)

    return wrapper
```

Usage:

```python
@announce_call
def greet(name: str) -> str:
    """Return a greeting."""
    return f"Hello, {name}!"
```

```python
print(greet("Ada"))
```

Output:

```text
Calling greet...
Hello, Ada!
```

This is acceptable for a quick script, but `Callable[..., Any]` loses detailed type information. For reusable production decorators, use `ParamSpec` and `TypeVar`.

---

# D.3 Why `functools.wraps` Matters

Without `@wraps`, a decorated function loses metadata:

```python
def broken_decorator(function):
    def wrapper(*args, **kwargs):
        return function(*args, **kwargs)

    return wrapper
```

```python
@broken_decorator
def get_project(project_id: str) -> str:
    """Fetch one project."""
    return project_id

print(get_project.__name__)
print(get_project.__doc__)
```

Output:

```text
wrapper
None
```

With `@wraps`:

```python
from functools import wraps


def correct_decorator(function):
    @wraps(function)
    def wrapper(*args, **kwargs):
        return function(*args, **kwargs)

    return wrapper
```

Output:

```text
get_project
Fetch one project.
```

Always use `@wraps(function)` for conventional decorators.

It helps:

- Debuggers
- Tracebacks
- Documentation generators
- Dependency-injection frameworks
- Testing tools
- Type-aware tooling
- Introspection with `inspect`

---

# D.4 Type-Safe Function Decorators

Use `ParamSpec` to preserve function parameters and `TypeVar` to preserve return types.

```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def log_calls(
    function: Callable[Parameters, ReturnValue],
) -> Callable[Parameters, ReturnValue]:
    """Log calls while preserving the wrapped function's type signature."""

    @wraps(function)
    def wrapper(
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        """Call function after logging its name."""
        print(f"Calling {function.__qualname__}")
        return function(*args, **kwargs)

    return wrapper
```

Usage:

```python
@log_calls
def add(left: int, right: int) -> int:
    return left + right


result = add(2, 3)
```

A type checker understands:

```python
result: int
```

and will reject:

```python
add("two", "three")
```

---

# D.5 Decorator Factories

A decorator factory accepts configuration and returns a decorator.

```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def repeat(
    times: int,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that calls a function a configured number of times."""
    if times < 1:
        raise ValueError("Repeat count must be at least 1.")

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with repeated invocation behavior."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call the wrapped function repeatedly and return its last result."""
            result: ReturnValue | None = None

            for _ in range(times):
                result = function(*args, **kwargs)

            # times is validated as at least 1, so result is assigned.
            return result  # type: ignore[return-value]

        return wrapper

    return decorator
```

The final `type: ignore` is a sign that this example can be designed more clearly. Prefer this version:

```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def repeat(
    times: int,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that calls a function a configured number of times."""
    if times < 1:
        raise ValueError("Repeat count must be at least 1.")

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with repeated invocation behavior."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call once, then repeat remaining calls, returning the last value."""
            result = function(*args, **kwargs)

            for _ in range(times - 1):
                result = function(*args, **kwargs)

            return result

        return wrapper

    return decorator
```

Usage:

```python
@repeat(times=3)
def announce() -> str:
    print("Running")
    return "done"


print(announce())
```

Output:

```text
Running
Running
Running
done
```

---

# D.6 Validation Decorator Pattern

A decorator can enforce a repeated input rule.

```python
from collections.abc import Callable
from functools import wraps
from inspect import signature
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def require_non_blank_string(
    parameter_name: str,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Create a decorator that validates one named string parameter."""
    cleaned_parameter_name = parameter_name.strip()

    if not cleaned_parameter_name:
        raise ValueError("Parameter name cannot be blank.")

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Validate configured parameter before calling function."""
        function_signature = signature(function)

        if cleaned_parameter_name not in function_signature.parameters:
            raise ValueError(
                f'Function "{function.__qualname__}" has no parameter named '
                f'"{cleaned_parameter_name}".'
            )

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Bind arguments and validate the configured string."""
            bound_arguments = function_signature.bind(*args, **kwargs)
            bound_arguments.apply_defaults()

            value = bound_arguments.arguments[cleaned_parameter_name]

            if not isinstance(value, str):
                raise TypeError(
                    f'Parameter "{cleaned_parameter_name}" must be a string.'
                )

            if not value.strip():
                raise ValueError(
                    f'Parameter "{cleaned_parameter_name}" cannot be blank.'
                )

            return function(*args, **kwargs)

        return wrapper

    return decorator
```

Usage:

```python
@require_non_blank_string("project_id")
def get_project(project_id: str) -> str:
    return f"Fetching {project_id.strip()}"
```

```python
print(get_project("project-123"))
```

Output:

```text
Fetching project-123
```

---

# D.7 Logging Decorator Pattern

A logging decorator should record both success and failure, then re-raise original errors.

```python
import logging
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")

logger = logging.getLogger(__name__)


def log_outcome(
    function: Callable[Parameters, ReturnValue],
) -> Callable[Parameters, ReturnValue]:
    """Log whether a function succeeded or failed."""

    @wraps(function)
    def wrapper(
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        """Call function and log outcome without hiding real errors."""
        try:
            result = function(*args, **kwargs)
        except Exception:
            logger.exception("Function failed: %s", function.__qualname__)
            raise

        logger.info("Function succeeded: %s", function.__qualname__)
        return result

    return wrapper
```

Never log secrets accidentally:

```python
# Dangerous: args may contain tokens, passwords, or personal data.
logger.info("Calling %s with %r", function.__name__, args)
```

Prefer logging safe metadata:

```python
logger.info("Calling %s", function.__qualname__)
```

---

# D.8 Timing Decorator Pattern

Use `time.monotonic()` for elapsed durations.

```python
import logging
from collections.abc import Callable
from functools import wraps
from time import monotonic
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")

logger = logging.getLogger(__name__)


def measure_duration(
    function: Callable[Parameters, ReturnValue],
) -> Callable[Parameters, ReturnValue]:
    """Log elapsed execution time whether function succeeds or fails."""

    @wraps(function)
    def wrapper(
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        """Measure the wrapped function's full runtime."""
        started_at = monotonic()

        try:
            return function(*args, **kwargs)
        finally:
            elapsed_seconds = monotonic() - started_at
            logger.info(
                "Function completed: name=%s duration_seconds=%.6f",
                function.__qualname__,
                elapsed_seconds,
            )

    return wrapper
```

Why `monotonic()` rather than `datetime.now()`?

- Wall-clock time can jump because of system clock adjustments.
- Monotonic time only moves forward.
- Duration calculation needs elapsed time, not calendar time.

---

# D.9 Retry Decorator Pattern

A retry decorator must be restrictive.

```python
from collections.abc import Callable
from functools import wraps
from time import sleep
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def retry(
    *,
    attempts: int,
    retry_on: tuple[type[Exception], ...],
    delay_seconds: float = 0.0,
) -> Callable[
    [Callable[Parameters, ReturnValue]],
    Callable[Parameters, ReturnValue],
]:
    """Retry only selected temporary failures."""
    if attempts < 1:
        raise ValueError("Retry attempts must be at least 1.")

    if not retry_on:
        raise ValueError("retry_on cannot be empty.")

    if delay_seconds < 0:
        raise ValueError("Retry delay cannot be negative.")

    def decorator(
        function: Callable[Parameters, ReturnValue],
    ) -> Callable[Parameters, ReturnValue]:
        """Wrap function with narrow retry behavior."""

        @wraps(function)
        def wrapper(
            *args: Parameters.args,
            **kwargs: Parameters.kwargs,
        ) -> ReturnValue:
            """Call function until success or retry exhaustion."""
            for attempt_number in range(1, attempts + 1):
                try:
                    return function(*args, **kwargs)
                except retry_on:
                    if attempt_number == attempts:
                        raise

                    if delay_seconds > 0:
                        sleep(delay_seconds)

            raise RuntimeError("Retry loop ended unexpectedly.")

        return wrapper

    return decorator
```

Use it only with operations safe to repeat:

```python
class TemporaryNetworkError(Exception):
    """Represent a temporary network failure."""


@retry(
    attempts=3,
    retry_on=(TemporaryNetworkError,),
    delay_seconds=0.25,
)
def fetch_project() -> str:
    return "project data"
```

Do not do this:

```python
@retry(
    attempts=5,
    retry_on=(Exception,),
)
def charge_credit_card() -> None:
    ...
```

Retrying broad exceptions can hide programming errors. Retrying unsafe writes can duplicate side effects.

---

# D.10 Decorator Order

Decorators apply from bottom to top.

```python
@outer
@inner
def process() -> None:
    ...
```

Means:

```python
process = outer(inner(process))
```

At call time:

1. `outer` wrapper starts.
2. `inner` wrapper starts.
3. Original `process()` runs.
4. `inner` wrapper finishes.
5. `outer` wrapper finishes.

## Logging Outside Retry

```python
@log_outcome
@retry(attempts=3, retry_on=(ConnectionError,))
def fetch() -> str:
    ...
```

The logger sees one overall result after retries finish.

## Logging Inside Retry

```python
@retry(attempts=3, retry_on=(ConnectionError,))
@log_outcome
def fetch() -> str:
    ...
```

The logger records each attempt.

Choose based on what you want operational logs to represent.

---

# D.11 Method Decorators

Methods have an instance as their first argument.

```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


def log_method(
    function: Callable[Parameters, ReturnValue],
) -> Callable[Parameters, ReturnValue]:
    """Log calls to an instance method."""

    @wraps(function)
    def wrapper(
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        """Log the method name then call the original method."""
        print(f"Calling {function.__qualname__}")
        return function(*args, **kwargs)

    return wrapper
```

Usage:

```python
class ProjectService:
    @log_method
    def get_project(self, project_id: str) -> str:
        return project_id
```

For decorators that need instance-specific state, use a protocol or define a decorator that deliberately expects `self`.

The capstone’s `log_method_calls` pattern is an example of this.

---

# D.12 Class-Based Decorators

A class can act as a decorator when it implements `__call__`.

```python
from collections.abc import Callable
from functools import wraps
from typing import ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")


class CallCounter:
    """Count how many times a decorated function is called."""

    def __init__(
        self,
        function: Callable[Parameters, ReturnValue],
    ) -> None:
        self._function = function
        self.call_count = 0

        wraps(function)(self)

    def __call__(
        self,
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        self.call_count += 1
        return self._function(*args, **kwargs)
```

Usage:

```python
@CallCounter
def greet(name: str) -> str:
    return f"Hello, {name}!"


print(greet("Ada"))
print(greet.call_count)
```

Output:

```text
Hello, Ada!
1
```

Use class-based decorators when the decorator itself owns substantial state or configuration. For simpler behavior, a function-based decorator is usually easier to read.

---

# D.13 Async Decorators

An `async def` function must be wrapped by another `async def` function.

```python
import logging
from collections.abc import Callable
from functools import wraps
from typing import Awaitable, ParamSpec, TypeVar

Parameters = ParamSpec("Parameters")
ReturnValue = TypeVar("ReturnValue")

logger = logging.getLogger(__name__)


def log_async_calls(
    function: Callable[Parameters, Awaitable[ReturnValue]],
) -> Callable[Parameters, Awaitable[ReturnValue]]:
    """Log calls to an asynchronous function."""

    @wraps(function)
    async def wrapper(
        *args: Parameters.args,
        **kwargs: Parameters.kwargs,
    ) -> ReturnValue:
        """Await the wrapped function and log its completion."""
        logger.info("Starting async function: %s", function.__qualname__)
        result = await function(*args, **kwargs)
        logger.info("Finished async function: %s", function.__qualname__)
        return result

    return wrapper
```

Do not use a synchronous wrapper around an async function unless you deliberately want to return the coroutine object unchanged.

---

# D.14 Caching Decorators

Python provides `functools.cache` and `functools.lru_cache`.

```python
from functools import lru_cache


@lru_cache(maxsize=128)
def normalize_project_name(name: str) -> str:
    return name.strip().casefold()
```

Caching is useful for deterministic, pure functions.

A **pure function**:

- Returns the same output for the same input.
- Does not modify external state.
- Does not depend on changing external state.

Do not cache functions that depend on changing remote data unless you explicitly design cache expiration and invalidation.

Dangerous example:

```python
@lru_cache
def get_project(project_id: str) -> Project:
    # This may return stale remote data forever.
    ...
```

---

# D.15 Testing Decorators

Test decorators directly and through representative decorated functions.

## Test Success

```python
def test_logging_decorator_returns_original_result() -> None:
    @log_outcome
    def add(left: int, right: int) -> int:
        return left + right

    assert add(2, 3) == 5
```

## Test Error Preservation

```python
import pytest


def test_logging_decorator_reraises_original_error() -> None:
    @log_outcome
    def fail() -> None:
        raise ValueError("Expected failure.")

    with pytest.raises(ValueError, match="Expected failure"):
        fail()
```

## Test Metadata

```python
def test_decorator_preserves_function_name() -> None:
    @log_outcome
    def fetch_project() -> None:
        """Fetch one project."""

    assert fetch_project.__name__ == "fetch_project"
    assert fetch_project.__doc__ == "Fetch one project."
```

## Test Retries Without Waiting

Inject a sleeper function:

```python
def test_retry_records_expected_delays() -> None:
    delays: list[float] = []
    calls = 0

    def sleeper(delay: float) -> None:
        delays.append(delay)

    # Build retry logic with sleeper injection in real implementations.
```

Avoid test suites that sleep for real retry delays.

---

# D.16 Common Decorator Pitfalls

## Forgetting `@wraps`

Symptom:

```text
wrapper
None
```

for function metadata.

Fix:

```python
@wraps(function)
def wrapper(...):
    ...
```

---

## Catching `BaseException`

Avoid:

```python
except BaseException:
    ...
```

It catches control-flow exceptions such as:

- `KeyboardInterrupt`
- `SystemExit`

Prefer narrow exception types or `Exception`.

---

## Retrying Every Exception

Avoid:

```python
except Exception:
    retry()
```

This can retry programming mistakes such as:

- `TypeError`
- `AttributeError`
- Incorrect parsing logic

Retry only expected transient failures.

---

## Logging Secrets

Avoid:

```python
logger.debug("Headers: %r", headers)
```

Headers may contain:

```text
Authorization: Bearer secret-token
```

Log only approved metadata.

---

## Hidden Side Effects

Avoid decorators that silently:

- Open transactions
- Modify global state
- Change return types
- Swallow exceptions
- Start background threads

unless the behavior is highly explicit and well documented.

---

## Decorating Too Much

This is a warning sign:

```python
@authenticate
@authorize
@validate
@retry
@cache
@trace
@log
@measure_duration
def process() -> None:
    ...
```

A reader must now understand eight wrappers before understanding one function.

Prefer a small number of clear, focused decorators. Put substantial workflow logic in explicit code.

---

# D.17 Decorator Decision Checklist

Before introducing a decorator, ask:

1. Is this behavior repeated across multiple functions?
2. Is it truly separate from core business logic?
3. Will the decorator’s name make behavior obvious at the call site?
4. Does it preserve the function’s type signature?
5. Does it use `functools.wraps`?
6. Does it preserve or intentionally transform exceptions?
7. Can it accidentally expose secrets in logs?
8. Is the decorator order documented when stacked?
9. Can it be tested without time delays, network access, or global state?
10. Would explicit code be easier to understand?

If the answer to the final question is yes, skip the decorator.[STARTING NEXT: Appendix E — `pytest` Testing Reference, Fixtures, Mocking, and Test Design]
