# Primer 7: Testing, Assertions, Fixtures, and Debugging Framework Code

Framework code needs tests because small mistakes can affect every application using the framework.

A mistake in one business function may affect one feature.

A mistake in a task registry, queue, worker lifecycle, or serialization boundary can affect every task.

This primer introduces:

- basic assertions;
- test naming;
- `pytest`;
- exception tests;
- async tests without extra plugins;
- test isolation;
- debugging failed tests;
- how PulseQueue tests framework behavior.

Think of tests as automated inspection stations on a production line. They do not guarantee perfection, but they catch regressions before defective behavior reaches users.

---

# Step 1: Write a Simple Assertion

## The Target

Create a test that verifies one deterministic function result.

## The Concept

An **assertion** states something that must be true.

```python
assert add(20, 22) == 42
```

If the expression is true, execution continues.

If it is false, Python raises `AssertionError`.

Tests are functions containing assertions.

A test should verify one clear behavior:

```text
Given input
    ↓
When code runs
    ↓
Then expected outcome occurs
```

This is often called the **Arrange, Act, Assert** pattern.

```text
Arrange: prepare input and dependencies
Act: call the behavior under test
Assert: check the observable result
```

## The Implementation

Create this test module.

## `tests/test_primer_basics.py`

```python
"""Primer 7: basic pytest examples."""

from __future__ import annotations


def add(left: int, right: int) -> int:
    """Return the sum of two integers."""
    return left + right


def test_add_returns_sum() -> None:
    """Verify the function returns expected arithmetic result."""
    # Arrange
    left = 20
    right = 22

    # Act
    result = add(left, right)

    # Assert
    assert result == 42
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_basics.py -q
```

Expected output:

```text
.                                                                        [100%]
1 passed
```

---

# Step 2: Test Expected Exceptions

## The Target

Verify that invalid input raises a meaningful exception.

## The Concept

Tests should verify failure behavior, not only success behavior.

A framework often needs to reject invalid states:

- empty task names;
- invalid queue names;
- negative retry counts;
- unsupported serialized values;
- duplicate task registrations.

`pytest.raises(...)` verifies that an expected exception occurs.

## The Implementation

Append this code to the existing file.

## `tests/test_primer_basics.py`

```python
"""Primer 7: basic pytest examples."""

from __future__ import annotations

import pytest


def add(left: int, right: int) -> int:
    """Return the sum of two integers."""
    return left + right


def calculate_retry_delay(
    retry_number: int,
    *,
    initial_delay_seconds: float,
) -> float:
    """Return a retry delay after input validation."""
    if retry_number < 1:
        raise ValueError("retry_number must be at least 1.")

    if initial_delay_seconds < 0:
        raise ValueError("initial_delay_seconds must be zero or greater.")

    return retry_number * initial_delay_seconds


def test_add_returns_sum() -> None:
    """Verify the function returns expected arithmetic result."""
    result = add(20, 22)

    assert result == 42


def test_retry_delay_rejects_zero_retry_number() -> None:
    """Verify invalid retry number raises useful validation error."""
    with pytest.raises(ValueError, match="at least 1"):
        calculate_retry_delay(
            0,
            initial_delay_seconds=0.5,
        )


def test_retry_delay_rejects_negative_initial_delay() -> None:
    """Verify negative delay does not silently enter retry logic."""
    with pytest.raises(ValueError, match="zero or greater"):
        calculate_retry_delay(
            1,
            initial_delay_seconds=-0.5,
        )
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_basics.py -q
```

Expected output:

```text
...                                                                      [100%]
3 passed
```

---

# Step 3: Test Real PulseQueue Registration

## The Target

Test that `@app.task(...)` creates and registers a task.

## The Concept

Framework tests should test public behavior.

Instead of testing private implementation details such as:

```python
app._registry._tasks
```

prefer public behavior:

```python
app.task_count
app.get_task(...)
app.tasks.queue_name.task_name
```

Private internals may change during refactoring. Public behavior is the contract users depend on.

## The Implementation

Create this test module.

## `tests/test_primer_task_registration.py`

```python
"""Primer 7: test public PulseQueue task registration behavior."""

from __future__ import annotations

from pulsequeue import PulseQueue


def test_task_decorator_registers_async_task() -> None:
    """A decorated coroutine should become available through public APIs."""
    app = PulseQueue("primer_test_app")

    @app.task(queue="messages")
    async def greet(name: str) -> str:
        return f"Hello, {name}."

    registered_task = app.get_task("messages.greet")

    assert app.task_count == 1
    assert registered_task is greet
    assert app.tasks.messages.greet is greet
    assert registered_task.name == "messages.greet"
    assert str(registered_task.signature) == "(name: str) -> str"
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_task_registration.py -q
```

Expected output:

```text
.                                                                        [100%]
1 passed
```

---

# Step 4: Test Async Code with `asyncio.run(...)`

## The Target

Test an asynchronous PulseQueue runtime without requiring an additional pytest async plugin.

## The Concept

A test function can be synchronous while internally running a coroutine:

```python
def test_something_async() -> None:
    asyncio.run(run_test())
```

This is useful for a tutorial because it keeps dependencies minimal.

The inner coroutine performs the actual async work.

Important rule:

> Do not call `asyncio.run(...)` from a test that is already running inside an event loop.

For ordinary synchronous pytest tests, it is safe.

## The Implementation

Create this file.

## `tests/test_primer_async_runtime.py`

```python
"""Primer 7: test asynchronous PulseQueue runtime behavior."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime
from pulsequeue.result import TaskState


def test_runtime_executes_async_task() -> None:
    """A submitted task should reach succeeded state and return its value."""

    async def run_test() -> None:
        app = PulseQueue("primer_async_test")

        @app.task(queue="math")
        async def multiply(left: int, right: int) -> int:
            await asyncio.sleep(0)
            return left * right

        async with PulseQueueRuntime(app) as runtime:
            receipt = await runtime.submit("math.multiply", 6, 7)

            result = await receipt.result(timeout_seconds=1.0)
            snapshot = receipt.snapshot()

            assert result == 42
            assert snapshot.state is TaskState.SUCCEEDED
            assert snapshot.attempt == 1
            assert runtime.worker.stats().completed_tasks == 1

    asyncio.run(run_test())
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_async_runtime.py -q
```

Expected output:

```text
.                                                                        [100%]
1 passed
```

---

# Step 5: Test Retry Behavior

## The Target

Test that a task retries a temporary failure and eventually succeeds.

## The Concept

Concurrency tests should avoid depending on vague timing whenever possible.

Bad test:

```python
await asyncio.sleep(1)
assert task_finished
```

This is slow and unreliable.

Better test:

```python
result = await receipt.result(timeout_seconds=1.0)
assert result == expected_value
```

The receipt is the framework’s completion contract.

For retries, use a tiny but nonzero retry delay:

```python
retry_delay_seconds=0.001
```

This keeps tests fast while still exercising real retry behavior.

## The Implementation

Create this file.

## `tests/test_primer_retries.py`

```python
"""Primer 7: test retry behavior through public task outcomes."""

from __future__ import annotations

import asyncio

from pulsequeue import PulseQueue, PulseQueueRuntime
from pulsequeue.result import TaskState


def test_task_succeeds_after_one_retry() -> None:
    """A transient failure should consume one retry and then succeed."""

    async def run_test() -> None:
        app = PulseQueue("primer_retry_test")
        attempts = {"count": 0}

        @app.task(
            queue="examples",
            max_retries=1,
            retry_delay_seconds=0.001,
        )
        async def transient_operation() -> str:
            attempts["count"] += 1

            if attempts["count"] == 1:
                raise ConnectionError("temporary failure")

            return "recovered"

        async with PulseQueueRuntime(app) as runtime:
            receipt = await runtime.submit("examples.transient_operation")

            result = await receipt.result(timeout_seconds=1.0)
            snapshot = receipt.snapshot()

            assert result == "recovered"
            assert attempts["count"] == 2
            assert snapshot.state is TaskState.SUCCEEDED
            assert snapshot.attempt == 2
            assert snapshot.max_attempts == 2
            assert runtime.worker.stats().retry_attempts == 1

    asyncio.run(run_test())
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_retries.py -q
```

Expected output:

```text
.                                                                        [100%]
1 passed
```

---

# Step 6: Understand Test Isolation

## The Target

Avoid tests that affect one another through shared global state.

## The Concept

A good test can run:

- by itself;
- before or after any other test;
- repeatedly;
- in parallel when test infrastructure supports it.

This is called **test isolation**.

Bad pattern:

```python
app = PulseQueue("global_app")


@app.task(queue="examples")
async def task() -> None:
    ...
```

If several tests import and modify the same global application, registrations can leak between tests.

Better:

```python
def test_something() -> None:
    app = PulseQueue("isolated_app")
```

Each test creates the state it needs.

Think of each test as a clean laboratory bench. A previous experiment should not leave chemicals behind for the next one.

## The Implementation

Create this file.

## `tests/test_primer_isolation.py`

```python
"""Primer 7: demonstrate isolated PulseQueue application state."""

from __future__ import annotations

from pulsequeue import PulseQueue


def test_first_application_has_its_own_registry() -> None:
    """One app should not share task registrations with another app."""
    app = PulseQueue("first_app")

    @app.task(queue="examples")
    async def first_task() -> str:
        return "first"

    assert app.task_count == 1
    assert app.get_task("examples.first_task") is first_task


def test_second_application_starts_with_empty_registry() -> None:
    """A newly created app should not inherit another test's tasks."""
    app = PulseQueue("second_app")

    assert app.task_count == 0
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_isolation.py -q
```

Expected output:

```text
..                                                                       [100%]
2 passed
```

---

# Step 7: Use Useful Assertion Messages

## The Target

Write assertions that make failures easier to diagnose.

## The Concept

This assertion is valid:

```python
assert result == 42
```

But if several values matter, a helpful message explains the intended contract:

```python
assert result == 42, "Expected math.add to return the product of 6 and 7."
```

For collections and structured objects, pytest often gives good comparison output automatically.

Use explicit messages when they clarify business or framework intent, not just to repeat the expression.

## The Implementation

Create this file.

## `tests/test_primer_assertion_messages.py`

```python
"""Primer 7: use clear assertions for framework expectations."""

from __future__ import annotations

from pulsequeue.events import TaskEvent, TaskEventType


def test_task_event_preserves_normalized_details() -> None:
    """Task event details should remain stable and sorted after creation."""
    event = TaskEvent.create(
        event_type=TaskEventType.SUCCEEDED,
        task_id="task-001",
        task_name="math.multiply",
        attempt=1,
        details={
            "result_type": "int",
            "queue": "math",
        },
    )

    assert event.details_as_dict() == {
        "queue": "math",
        "result_type": "int",
    }, "Event details should preserve normalized task execution metadata."
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_assertion_messages.py -q
```

Expected output:

```text
.                                                                        [100%]
1 passed
```

---

# Step 8: Debug a Failing Test

## The Target

Learn practical commands for inspecting test failures.

## The Concept

When a test fails, do not immediately edit random code.

Use the failure output to identify:

1. The failing assertion.
2. The actual value.
3. The expected value.
4. The stack trace.
5. The smallest reproduction.

Useful pytest options:

| Command | Purpose |
|---|---|
| `-q` | Quiet, concise output |
| `-v` | Verbose test names |
| `-x` | Stop after first failure |
| `--tb=short` | Shorter traceback |
| `-k text` | Run tests matching text |
| `-s` | Show `print(...)` output |
| `--maxfail=1` | Stop after one failure |

## The Implementation

Temporarily create this intentionally failing test.

## `tests/test_primer_debugging_example.py`

```python
"""Primer 7: intentionally failing test for pytest debugging practice."""

from __future__ import annotations


def multiply(left: int, right: int) -> int:
    """Return product of two integers."""
    return left * right


def test_debugging_example() -> None:
    """This assertion is intentionally wrong for demonstration."""
    result = multiply(6, 7)

    assert result == 40
```

## The Verification

Run:

```bash
python -m pytest tests/test_primer_debugging_example.py -v
```

Expected failure output includes:

```text
E       assert 42 == 40
```

Now fix the test.

## `tests/test_primer_debugging_example.py`

```python
"""Primer 7: corrected pytest debugging example."""

from __future__ import annotations


def multiply(left: int, right: int) -> int:
    """Return product of two integers."""
    return left * right


def test_debugging_example() -> None:
    """Verify multiplication result after correcting expected value."""
    result = multiply(6, 7)

    assert result == 42
```

Run again:

```bash
python -m pytest tests/test_primer_debugging_example.py -q
```

Expected output:

```text
.                                                                        [100%]
1 passed
```

---

# Primer 7 Reference: Useful Test Commands

Run all tests:

```bash
python -m pytest -q
```

Run one file:

```bash
python -m pytest tests/test_primer_retries.py -q
```

Run one named test:

```bash
python -m pytest \
  tests/test_primer_retries.py::test_task_succeeds_after_one_retry \
  -q
```

Run tests matching a keyword:

```bash
python -m pytest -k retry -q
```

Show print output:

```bash
python -m pytest -s -q
```

Stop on first failure:

```bash
python -m pytest -x -q
```

Use short tracebacks:

```bash
python -m pytest --tb=short -q
```

---

# Primer 7 Completion Checklist

Before relying on the capstone test suite, confirm that you can:

- [ ] Write a test function beginning with `test_`.
- [ ] Use `assert` to verify behavior.
- [ ] Use `pytest.raises(...)` for expected exceptions.
- [ ] Test an async workflow through `asyncio.run(...)`.
- [ ] Test task registration through public APIs.
- [ ] Test receipt state and task result behavior.
- [ ] Avoid shared application state between tests.
- [ ] Use `python -m pytest -q`.
- [ ] Run one test file or one named test.
- [ ] Read and fix a failing assertion.
