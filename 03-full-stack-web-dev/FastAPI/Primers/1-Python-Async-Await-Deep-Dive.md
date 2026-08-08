# Primer 1: Python Async/Await Deep Dive

Welcome to the first primer in our FastAPI Masterclass series! This primer is designed to give you a comprehensive understanding of Python's asynchronous programming model. While we've used async/await throughout the main series, this deep dive will solidify your understanding of how it works under the hood, when to use it, and how to avoid common pitfalls.

## Table of Contents
1. [Introduction to Async Programming](#introduction-to-async-programming)
2. [The Event Loop](#the-event-loop)
3. [Async/Await Syntax](#asyncawait-syntax)
4. [Coroutines and Tasks](#coroutines-and-tasks)
5. [Concurrency vs Parallelism](#concurrency-vs-parallelism)
6. [Common Async Patterns](#common-async-patterns)
7. [Async Context Managers](#async-context-managers)
8. [Async Iterators and Generators](#async-iterators-and-generators)
9. [Debugging Async Code](#debugging-async-code)
10. [Performance Considerations](#performance-considerations)

---

## Introduction to Async Programming

### What is Asynchronous Programming?

Think of async programming like a restaurant kitchen:

**Synchronous (Traditional):**
```
Chef takes Order 1 → Prepares entire meal → Serves → Takes Order 2 → Prepares entire meal → Serves
```
The chef can only handle one order at a time. If they're waiting for something to cook, they just stand there.

**Asynchronous (Async):**
```
Chef takes Order 1 → Starts cooking → While waiting, takes Order 2 → Starts cooking → 
While waiting, checks Order 1 → Adds final touches → Serves → Checks Order 2 → Serves
```
The chef can handle multiple orders simultaneously, switching between tasks while waiting for things to happen.

### Why Use Async in Python?

```python
# Synchronous version - blocks while waiting
def fetch_data_sync():
    response = requests.get("https://api.example.com/data")  # Blocks here
    return response.json()

# Asynchronous version - doesn't block
async def fetch_data_async():
    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.example.com/data")  # Doesn't block
    return response.json()
```

**Benefits:**
- **Better Resource Utilization**: While waiting for I/O, the CPU can work on other tasks
- **Higher Throughput**: Handle more requests with fewer resources
- **Lower Latency**: Users get faster responses
- **Scalability**: Better handle thousands of concurrent connections

**Trade-offs:**
- **Learning Curve**: New concepts and patterns
- **Debugging Complexity**: Stack traces can be harder to follow
- **No CPU-Bound Benefits**: Async doesn't speed up CPU-intensive operations

---

## The Event Loop

### Understanding the Event Loop

The event loop is the heart of asynchronous programming in Python. It's like a traffic controller that manages all your async tasks.

```python
"""
The event loop in action - visualized
"""

import asyncio
import time

# ────────────────────────────────────────────────────────────────
# How the event loop works
# ────────────────────────────────────────────────────────────────

async def task(name, delay):
    """Simulate an async task."""
    print(f"Task {name}: Starting")
    await asyncio.sleep(delay)  # Simulate I/O
    print(f"Task {name}: Completed after {delay}s")
    return f"Result from {name}"

async def demonstrate_event_loop():
    """Demonstrate how the event loop schedules tasks."""
    print("Event Loop: Starting")
    
    # Create tasks
    tasks = [
        task("A", 2),
        task("B", 1),
        task("C", 3),
    ]
    
    # Event loop runs all tasks concurrently
    # When task A sleeps, it switches to task B
    # When task B sleeps, it switches to task C
    # And so on...
    results = await asyncio.gather(*tasks)
    
    print(f"Event Loop: All tasks completed")
    print(f"Results: {results}")

# Run the event loop
asyncio.run(demonstrate_event_loop())

# Output:
# Event Loop: Starting
# Task A: Starting
# Task B: Starting
# Task C: Starting
# Task B: Completed after 1s
# Task A: Completed after 2s
# Task C: Completed after 3s
# Event Loop: All tasks completed
# Results: ['Result from A', 'Result from B', 'Result from C']
```

### Event Loop Internals

```python
"""
Understanding the event loop internals
"""

import asyncio
import time
from typing import List, Dict, Any

class SimpleEventLoop:
    """
    A simplified event loop implementation for understanding.
    
    This is NOT production code - just for educational purposes.
    """
    
    def __init__(self):
        self.task_queue: List[Dict[str, Any]] = []
        self.running = False
    
    def add_task(self, coroutine):
        """Add a task to the queue."""
        self.task_queue.append({
            "coroutine": coroutine,
            "status": "pending",
            "result": None,
        })
    
    def run_until_complete(self):
        """Run the event loop until all tasks complete."""
        self.running = True
        
        while self.running and self.task_queue:
            # Process each task
            for task in self.task_queue:
                if task["status"] == "pending":
                    # Run the coroutine until it yields/sleeps
                    try:
                        result = next(task["coroutine"])
                        # If it yielded a sleep, we pause
                        if isinstance(result, float):
                            # In real event loop, we would schedule a timer
                            # For simplicity, we simulate the delay
                            time.sleep(result)
                        else:
                            task["status"] = "completed"
                            task["result"] = result
                    except StopIteration as e:
                        task["status"] = "completed"
                        task["result"] = e.value
            
            # Remove completed tasks
            self.task_queue = [
                t for t in self.task_queue 
                if t["status"] != "completed"
            ]
    
    def stop(self):
        """Stop the event loop."""
        self.running = False


def simple_coroutine(name, delay):
    """A simple coroutine that yields delays."""
    print(f"{name}: Starting")
    yield delay  # Simulate waiting
    print(f"{name}: After first delay")
    yield delay  # Simulate waiting again
    print(f"{name}: After second delay")
    return f"{name} complete"

# Simulate the event loop
loop = SimpleEventLoop()
loop.add_task(simple_coroutine("Task 1", 1))
loop.add_task(simple_coroutine("Task 2", 0.5))
print("Running event loop...")
loop.run_until_complete()
print("Event loop complete")
```

### Real Event Loop Operations

```python
"""
Common event loop operations
"""

import asyncio
import time

async def demo_event_loop_ops():
    """Demonstrate common event loop operations."""
    
    # ────────────────────────────────────────────────────────────────
    # 1. Getting the current event loop
    # ────────────────────────────────────────────────────────────────
    loop = asyncio.get_running_loop()
    print(f"Current loop: {loop}")
    
    # ────────────────────────────────────────────────────────────────
    # 2. Running in the event loop
    # ────────────────────────────────────────────────────────────────
    # run_until_complete is for synchronous contexts
    # In async contexts, use await
    
    # ────────────────────────────────────────────────────────────────
    # 3. Creating tasks
    # ────────────────────────────────────────────────────────────────
    async def my_task():
        await asyncio.sleep(0.1)
        return "Done"
    
    # Create a task - starts running immediately
    task = asyncio.create_task(my_task())
    result = await task
    print(f"Task result: {result}")
    
    # ────────────────────────────────────────────────────────────────
    # 4. Ensuring all tasks complete
    # ────────────────────────────────────────────────────────────────
    tasks = [asyncio.create_task(my_task()) for _ in range(3)]
    results = await asyncio.gather(*tasks)
    print(f"All tasks: {results}")
    
    # ────────────────────────────────────────────────────────────────
    # 5. Running in a separate thread (blocking operations)
    # ────────────────────────────────────────────────────────────────
    def blocking_function():
        time.sleep(0.5)
        return "Blocking result"
    
    # Run blocking function in thread pool
    result = await asyncio.to_thread(blocking_function)
    print(f"Thread result: {result}")

# Run the demo
asyncio.run(demo_event_loop_ops())
```

---

## Async/Await Syntax

### The Basics

```python
"""
Understanding async/await syntax
"""

import asyncio
from typing import Optional

# ────────────────────────────────────────────────────────────────
# 1. Defining Async Functions
# ────────────────────────────────────────────────────────────────

async def basic_async_function() -> str:
    """Basic async function."""
    await asyncio.sleep(0.1)  # Must await something
    return "Result"

# ────────────────────────────────────────────────────────────────
# 2. Calling Async Functions
# ────────────────────────────────────────────────────────────────

# CORRECT: Using await
async def correct_call():
    result = await basic_async_function()
    return result

# CORRECT: Creating and awaiting a task
async def correct_task():
    task = asyncio.create_task(basic_async_function())
    result = await task
    return result

# WRONG: Forgetting await
async def wrong_call():
    result = basic_async_function()  # This is a coroutine object, not the result!
    # result is <coroutine object basic_async_function at 0x...>
    return result

# ────────────────────────────────────────────────────────────────
# 3. Async Functions vs Regular Functions
# ────────────────────────────────────────────────────────────────

def regular_function():
    """Regular synchronous function."""
    return "Regular"

async def async_function():
    """Async function."""
    await asyncio.sleep(0.1)
    return "Async"

# ────────────────────────────────────────────────────────────────
# 4. Awaitable Types
# ────────────────────────────────────────────────────────────────

async def awaitable_demo():
    """Different things you can await."""
    
    # Coroutine
    result1 = await async_function()
    
    # Task
    task = asyncio.create_task(async_function())
    result2 = await task
    
    # Future
    future = asyncio.Future()
    # In real code, future would be set elsewhere
    # result3 = await future
    
    # Awaitable objects (custom classes with __await__)
    class MyAwaitable:
        def __await__(self):
            yield from asyncio.sleep(0.1).__await__()
            return "Custom awaitable"
    
    result4 = await MyAwaitable()
    
    return result1, result2, result4

# ────────────────────────────────────────────────────────────────
# 5. Return Types
# ────────────────────────────────────────────────────────────────

async def async_return() -> str:
    """Return type annotation works the same."""
    return "Hello"

async def async_optional() -> Optional[str]:
    """Optional return type."""
    await asyncio.sleep(0)
    return None

# ────────────────────────────────────────────────────────────────
# 6. Async Functions with Multiple Awaits
# ────────────────────────────────────────────────────────────────

async def multiple_awaits():
    """Function with multiple await points."""
    print("Step 1")
    await asyncio.sleep(0.1)
    
    print("Step 2")
    await asyncio.sleep(0.1)
    
    print("Step 3")
    await asyncio.sleep(0.1)
    
    return "All steps complete"

# ────────────────────────────────────────────────────────────────
# 7. Async Functions with Try/Except
# ────────────────────────────────────────────────────────────────

async def async_with_error_handling():
    """Async function with error handling."""
    try:
        await asyncio.sleep(0.1)
        raise ValueError("Something went wrong")
    except ValueError as e:
        print(f"Caught error: {e}")
        return "Handled error"
    finally:
        print("Cleanup")

# Run the examples
async def main():
    print("Basic:", await basic_async_function())
    print("Correct:", await correct_call())
    print("Multiple:", await multiple_awaits())
    print("Error handling:", await async_with_error_handling())

if __name__ == "__main__":
    asyncio.run(main())
```

### Awaiting Multiple Things

```python
"""
Patterns for awaiting multiple things
"""

import asyncio
import time

async def task(name: str, delay: float) -> str:
    """Simulate a task."""
    print(f"{name}: Starting (sleep {delay}s)")
    await asyncio.sleep(delay)
    print(f"{name}: Done")
    return f"{name} completed"

# ────────────────────────────────────────────────────────────────
# Pattern 1: Sequential Await (Slow)
# ────────────────────────────────────────────────────────────────

async def sequential_await():
    """Await tasks one after another."""
    print("Sequential:")
    
    start = time.time()
    
    result1 = await task("A", 2)
    result2 = await task("B", 1)
    result3 = await task("C", 3)
    
    duration = time.time() - start
    print(f"Total duration: {duration:.2f}s")
    return [result1, result2, result3]

# ────────────────────────────────────────────────────────────────
# Pattern 2: Concurrent with asyncio.gather (Fast)
# ────────────────────────────────────────────────────────────────

async def concurrent_gather():
    """Run tasks concurrently with gather."""
    print("Concurrent (gather):")
    
    start = time.time()
    
    results = await asyncio.gather(
        task("A", 2),
        task("B", 1),
        task("C", 3),
    )
    
    duration = time.time() - start
    print(f"Total duration: {duration:.2f}s")
    return results

# ────────────────────────────────────────────────────────────────
# Pattern 3: Concurrent with asyncio.create_task
# ────────────────────────────────────────────────────────────────

async def concurrent_create_task():
    """Run tasks concurrently with create_task."""
    print("Concurrent (create_task):")
    
    start = time.time()
    
    # Create tasks (they start running immediately)
    task_a = asyncio.create_task(task("A", 2))
    task_b = asyncio.create_task(task("B", 1))
    task_c = asyncio.create_task(task("C", 3))
    
    # Await each task
    results = await asyncio.gather(task_a, task_b, task_c)
    
    duration = time.time() - start
    print(f"Total duration: {duration:.2f}s")
    return results

# ────────────────────────────────────────────────────────────────
# Pattern 4: Handling Exceptions in gather
# ────────────────────────────────────────────────────────────────

async def failing_task(name: str):
    """Task that might fail."""
    await asyncio.sleep(0.1)
    if name == "B":
        raise ValueError(f"Task {name} failed")
    return f"{name} succeeded"

async def gather_with_exceptions():
    """Handle exceptions in gather."""
    print("Handling exceptions:")
    
    # Option 1: Let exceptions propagate (default)
    try:
        results = await asyncio.gather(
            failing_task("A"),
            failing_task("B"),
            failing_task("C"),
        )
    except ValueError as e:
        print(f"Caught exception: {e}")
    
    # Option 2: Return exceptions as results
    results = await asyncio.gather(
        failing_task("A"),
        failing_task("B"),
        failing_task("C"),
        return_exceptions=True,
    )
    
    for i, result in enumerate(results):
        if isinstance(result, Exception):
            print(f"Task {chr(65+i)} failed: {result}")
        else:
            print(f"Task {chr(65+i)} succeeded: {result}")
    
    return results

# ────────────────────────────────────────────────────────────────
# Pattern 5: Limiting Concurrency
# ────────────────────────────────────────────────────────────────

async def limited_concurrency(coros, max_concurrent):
    """Run coroutines with limited concurrency."""
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def sem_task(coro):
        async with semaphore:
            return await coro
    
    tasks = [sem_task(coro) for coro in coros]
    return await asyncio.gather(*tasks)

async def demo_limited():
    """Demonstrate limited concurrency."""
    print("Limited concurrency (max 2):")
    start = time.time()
    
    coros = [task(f"Task {i}", 1) for i in range(5)]
    results = await limited_concurrency(coros, 2)
    
    duration = time.time() - start
    print(f"Total duration: {duration:.2f}s")
    return results

# ────────────────────────────────────────────────────────────────
# Pattern 6: Timeout
# ────────────────────────────────────────────────────────────────

async def task_with_timeout():
    """Apply timeout to async operation."""
    try:
        # Wait for up to 2 seconds
        result = await asyncio.wait_for(task("Slow", 3), timeout=2.0)
        return result
    except asyncio.TimeoutError:
        return "Task timed out"

async def demo_timeout():
    print("Timeout demo:")
    result = await task_with_timeout()
    print(f"Result: {result}")

# Run all patterns
async def main():
    print("=" * 50)
    await sequential_await()
    print("=" * 50)
    await concurrent_gather()
    print("=" * 50)
    await concurrent_create_task()
    print("=" * 50)
    await gather_with_exceptions()
    print("=" * 50)
    await demo_limited()
    print("=" * 50)
    await demo_timeout()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Coroutines and Tasks

### Understanding Coroutines

```python
"""
Deep dive into coroutines
"""

import asyncio
import types

# ────────────────────────────────────────────────────────────────
# 1. What is a Coroutine?
# ────────────────────────────────────────────────────────────────

# A coroutine is an async function
async def my_coroutine():
    """This is a coroutine function."""
    await asyncio.sleep(0.1)
    return "Coroutine result"

# When called, it returns a coroutine object
coro = my_coroutine()
print(f"Type: {type(coro)}")  # <class 'coroutine'>
print(f"Is coroutine: {asyncio.iscoroutine(coro)}")  # True

# ────────────────────────────────────────────────────────────────
# 2. Coroutine States
# ────────────────────────────────────────────────────────────────

async def coroutine_states():
    """Demonstrate coroutine states."""
    
    # Coroutine is created
    coro = my_coroutine()
    print(f"Initial state: {coro.cr_running}")  # False
    
    # Coroutine is running (during execution)
    await coro
    
    # After completion, coroutine is done
    # (Can't be reused)

# ────────────────────────────────────────────────────────────────
# 3. Creating Coroutines Programmatically
# ────────────────────────────────────────────────────────────────

async def dynamic_coroutine(name: str):
    """A regular async function."""
    await asyncio.sleep(0.1)
    return f"Hello {name}"

# You can't create coroutines from regular functions
def regular_function():
    return "Regular"

# But you can use async functions as factories
async def coroutine_factory():
    """Factory that returns a coroutine."""
    return await dynamic_coroutine("Factory")

# ────────────────────────────────────────────────────────────────
# 4. Coroutine vs Generator
# ────────────────────────────────────────────────────────────────

# Generator (synchronous)
def my_generator():
    yield 1
    yield 2
    yield 3

# Async generator
async def my_async_generator():
    yield 1
    await asyncio.sleep(0.1)
    yield 2
    await asyncio.sleep(0.1)
    yield 3

# ────────────────────────────────────────────────────────────────
# 5. Coroutine Composition
# ────────────────────────────────────────────────────────────────

async def parent_coroutine():
    """Parent coroutine calls child coroutines."""
    print("Parent: Starting")
    
    # Child coroutine 1
    child1 = dynamic_coroutine("Child 1")
    result1 = await child1
    
    # Child coroutine 2
    child2 = dynamic_coroutine("Child 2")
    result2 = await child2
    
    print(f"Parent: Got {result1} and {result2}")
    return "Parent done"

# ────────────────────────────────────────────────────────────────
# 6. Validating Coroutine Types
# ────────────────────────────────────────────────────────────────

def is_coroutine_function(func):
    """Check if something is a coroutine function."""
    return asyncio.iscoroutinefunction(func)

def is_coroutine_object(obj):
    """Check if something is a coroutine object."""
    return asyncio.iscoroutine(obj)

# Demo
async def demo():
    print(f"my_coroutine is coroutine function: {is_coroutine_function(my_coroutine)}")  # True
    print(f"regular_function is coroutine function: {is_coroutine_function(regular_function)}")  # False
    
    coro = my_coroutine()
    print(f"coro is coroutine object: {is_coroutine_object(coro)}")  # True
    
    # Clean up
    await coro

# Run demo
asyncio.run(demo())
```

### Task Management

```python
"""
Advanced task management
"""

import asyncio
from typing import List, Dict, Any
import time

# ────────────────────────────────────────────────────────────────
# 1. Creating and Managing Tasks
# ────────────────────────────────────────────────────────────────

async def worker(name: str, delay: float):
    """Simulate a worker task."""
    print(f"Worker {name}: Started")
    await asyncio.sleep(delay)
    print(f"Worker {name}: Completed")
    return f"Worker {name} result"

async def task_management():
    """Demonstrate task management."""
    
    # Create tasks
    tasks = []
    for i in range(3):
        task = asyncio.create_task(worker(f"Task{i}", 1))
        tasks.append(task)
    
    # Check task status
    for task in tasks:
        print(f"Task done: {task.done()}")
        print(f"Task cancelled: {task.cancelled()}")
    
    # Wait for all tasks
    results = await asyncio.gather(*tasks)
    print(f"All results: {results}")
    
    # After completion
    for task in tasks:
        print(f"Task done: {task.done()}")
        if task.done():
            print(f"Result: {task.result()}")

# ────────────────────────────────────────────────────────────────
# 2. Task Cancellation
# ────────────────────────────────────────────────────────────────

async def cancellable_task(name: str):
    """A task that can be cancelled."""
    print(f"{name}: Starting")
    try:
        for i in range(5):
            print(f"{name}: Working... {i+1}/5")
            await asyncio.sleep(1)
        print(f"{name}: Completed")
        return f"{name} success"
    except asyncio.CancelledError:
        print(f"{name}: Cancelled!")
        raise

async def task_cancellation():
    """Demonstrate task cancellation."""
    
    # Create a task
    task = asyncio.create_task(cancellable_task("Cancellable"))
    
    # Cancel after 2 seconds
    await asyncio.sleep(2)
    task.cancel()
    print("Task cancellation requested")
    
    # Wait for task to complete (it will raise CancelledError)
    try:
        result = await task
        print(f"Result: {result}")
    except asyncio.CancelledError:
        print("Task was cancelled successfully")

# ────────────────────────────────────────────────────────────────
# 3. Task Group (Python 3.11+)
# ────────────────────────────────────────────────────────────────

async def task_group_demo():
    """Demonstrate TaskGroup (Python 3.11+)."""
    try:
        async with asyncio.TaskGroup() as tg:
            # Create tasks in the group
            task1 = tg.create_task(worker("TG1", 1))
            task2 = tg.create_task(worker("TG2", 2))
            task3 = tg.create_task(worker("TG3", 0.5))
            
            # All tasks run concurrently
            # When the context exits, it waits for all tasks
        
        # All tasks are complete here
        print("All TaskGroup tasks complete")
        print(f"TG1 result: {task1.result()}")
        print(f"TG2 result: {task2.result()}")
        print(f"TG3 result: {task3.result()}")
        
    except Exception as e:
        print(f"TaskGroup error: {e}")

# ────────────────────────────────────────────────────────────────
# 4. Task Monitoring
# ────────────────────────────────────────────────────────────────

class TaskMonitor:
    """Monitor task execution."""
    
    def __init__(self):
        self.tasks: List[asyncio.Task] = []
    
    def add_task(self, coro):
        """Add a task to monitor."""
        task = asyncio.create_task(coro)
        self.tasks.append(task)
        return task
    
    def get_status(self) -> Dict[str, int]:
        """Get task status summary."""
        running = 0
        done = 0
        cancelled = 0
        pending = 0
        
        for task in self.tasks:
            if task.cancelled():
                cancelled += 1
            elif task.done():
                done += 1
            elif task._state == 'PENDING':
                pending += 1
            else:
                running += 1
        
        return {
            "total": len(self.tasks),
            "running": running,
            "done": done,
            "cancelled": cancelled,
            "pending": pending,
        }
    
    def get_results(self):
        """Get results of completed tasks."""
        results = []
        for task in self.tasks:
            if task.done() and not task.cancelled():
                try:
                    results.append(task.result())
                except Exception as e:
                    results.append(f"Error: {e}")
        return results

async def task_monitor_demo():
    """Demonstrate task monitoring."""
    
    monitor = TaskMonitor()
    
    # Add tasks
    for i in range(5):
        monitor.add_task(worker(f"Monitored{i}", 0.5 if i % 2 == 0 else 1.5))
    
    # Check status periodically
    for _ in range(4):
        status = monitor.get_status()
        print(f"Status: {status}")
        await asyncio.sleep(0.5)
    
    # Final status
    status = monitor.get_status()
    print(f"Final status: {status}")
    results = monitor.get_results()
    print(f"Results: {results}")

# ────────────────────────────────────────────────────────────────
# 5. Task Cleanup
# ────────────────────────────────────────────────────────────────

async def task_cleanup():
    """Proper task cleanup."""
    
    tasks = []
    
    try:
        # Create tasks
        for i in range(3):
            task = asyncio.create_task(worker(f"Cleanup{i}", 2))
            tasks.append(task)
        
        # Wait with timeout
        done, pending = await asyncio.wait(
            tasks,
            timeout=3.0,
            return_when=asyncio.FIRST_COMPLETED
        )
        
        # Cancel pending tasks
        for task in pending:
            task.cancel()
        
        # Wait for cancellation
        if pending:
            await asyncio.gather(*pending, return_exceptions=True)
        
        print("All tasks cleaned up")
        
    except Exception as e:
        print(f"Error in cleanup: {e}")
        # Clean up on error
        for task in tasks:
            if not task.done():
                task.cancel()

# ────────────────────────────────────────────────────────────────
# Run all demos
# ────────────────────────────────────────────────────────────────

async def main():
    print("=" * 50)
    print("Task Management")
    await task_management()
    
    print("\n" + "=" * 50)
    print("Task Cancellation")
    await task_cancellation()
    
    if hasattr(asyncio, "TaskGroup"):
        print("\n" + "=" * 50)
        print("Task Group (Python 3.11+)")
        await task_group_demo()
    
    print("\n" + "=" * 50)
    print("Task Monitoring")
    await task_monitor_demo()
    
    print("\n" + "=" * 50)
    print("Task Cleanup")
    await task_cleanup()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Concurrency vs Parallelism

### Understanding the Difference

```python
"""
Concurrency vs Parallelism explained
"""

import asyncio
import time
import threading
import multiprocessing
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor

# ────────────────────────────────────────────────────────────────
# 1. Concurrency (Async) - Single thread, multiple tasks
# ────────────────────────────────────────────────────────────────

async def async_worker(name: str, delay: float):
    """Async worker (concurrent)."""
    print(f"Async {name}: Starting")
    await asyncio.sleep(delay)
    print(f"Async {name}: Completed")
    return f"Async {name} result"

async def demonstrate_concurrency():
    """Demonstrate concurrency with async."""
    print("=== Async Concurrency ===")
    print("Single thread, multiple tasks")
    start = time.time()
    
    # All tasks run on the same thread
    results = await asyncio.gather(
        async_worker("A", 2),
        async_worker("B", 1),
        async_worker("C", 3),
    )
    
    duration = time.time() - start
    print(f"Total time: {duration:.2f}s")
    print(f"Results: {results}")
    return duration

# ────────────────────────────────────────────────────────────────
# 2. Parallelism (Threads) - Multiple threads
# ────────────────────────────────────────────────────────────────

def thread_worker(name: str, delay: float):
    """Thread worker (parallel)."""
    print(f"Thread {name}: Starting")
    time.sleep(delay)
    print(f"Thread {name}: Completed")
    return f"Thread {name} result"

def demonstrate_threading():
    """Demonstrate parallelism with threads."""
    print("\n=== Threading Parallelism ===")
    print("Multiple threads, true parallelism (for I/O)")
    start = time.time()
    
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = [
            executor.submit(thread_worker, "A", 2),
            executor.submit(thread_worker, "B", 1),
            executor.submit(thread_worker, "C", 3),
        ]
        results = [f.result() for f in futures]
    
    duration = time.time() - start
    print(f"Total time: {duration:.2f}s")
    print(f"Results: {results}")
    return duration

# ────────────────────────────────────────────────────────────────
# 3. Parallelism (Processes) - Multiple processes
# ────────────────────────────────────────────────────────────────

def cpu_intensive_worker(name: str, count: int):
    """CPU-intensive worker (parallel)."""
    result = 0
    for i in range(count):
        result += i ** 2
    return f"Process {name}: {result}"

def demonstrate_multiprocessing():
    """Demonstrate parallelism with processes."""
    print("\n=== Multiprocessing Parallelism ===")
    print("Multiple processes, true parallelism (for CPU)")
    start = time.time()
    
    with ProcessPoolExecutor(max_workers=3) as executor:
        futures = [
            executor.submit(cpu_intensive_worker, "A", 1000000),
            executor.submit(cpu_intensive_worker, "B", 1000000),
            executor.submit(cpu_intensive_worker, "C", 1000000),
        ]
        results = [f.result() for f in futures]
    
    duration = time.time() - start
    print(f"Total time: {duration:.2f}s")
    print(f"Results: {results[:50]}")
    return duration

# ────────────────────────────────────────────────────────────────
# 4. When to Use What
# ────────────────────────────────────────────────────────────────

def when_to_use():
    """Guide for choosing concurrency/parallelism."""
    print("\n=== When to Use What ===")
    print("""
    Async (Concurrency):
    - I/O-bound operations (database, network, file)
    - Many concurrent connections
    - Web servers, API clients
    - Single-threaded with event loop
    
    Threading (Parallelism):
    - I/O-bound with blocking libraries
    - When async isn't available
    - CPU-bound with GIL release (some C extensions)
    
    Multiprocessing (Parallelism):
    - CPU-intensive operations
    - Heavy computation
    - Processing large datasets
    - Machine learning, data processing
    """)

# ────────────────────────────────────────────────────────────────
# 5. Real-World Example: Web Scraping
# ────────────────────────────────────────────────────────────────

import aiohttp
import requests
from typing import List, Dict

async def async_scrape(urls: List[str]) -> List[Dict]:
    """Async web scraping (concurrent)."""
    async with aiohttp.ClientSession() as session:
        tasks = []
        for url in urls:
            tasks.append(async_fetch(session, url))
        return await asyncio.gather(*tasks)

async def async_fetch(session, url):
    """Async fetch a URL."""
    try:
        async with session.get(url, timeout=10) as response:
            return {
                "url": url,
                "status": response.status,
                "length": len(await response.text()),
            }
    except Exception as e:
        return {
            "url": url,
            "error": str(e),
        }

def sync_scrape(urls: List[str]) -> List[Dict]:
    """Synchronous web scraping."""
    results = []
    for url in urls:
        try:
            response = requests.get(url, timeout=10)
            results.append({
                "url": url,
                "status": response.status_code,
                "length": len(response.text),
            })
        except Exception as e:
            results.append({
                "url": url,
                "error": str(e),
            })
    return results

async def demonstrate_scraping():
    """Compare async vs sync scraping."""
    urls = [
        "https://httpbin.org/delay/1",
        "https://httpbin.org/delay/1",
        "https://httpbin.org/delay/1",
        "https://httpbin.org/delay/1",
        "https://httpbin.org/delay/1",
    ]
    
    print("\n=== Web Scraping Comparison ===")
    
    # Sync
    print("Synchronous:")
    start = time.time()
    sync_results = sync_scrape(urls)
    sync_time = time.time() - start
    print(f"Sync time: {sync_time:.2f}s")
    print(f"Results: {len(sync_results)}")
    
    # Async
    print("\nAsynchronous:")
    start = time.time()
    async_results = await async_scrape(urls)
    async_time = time.time() - start
    print(f"Async time: {async_time:.2f}s")
    print(f"Results: {len(async_results)}")
    
    print(f"\nAsync is {sync_time/async_time:.2f}x faster")

# ────────────────────────────────────────────────────────────────
# Run all demos
# ────────────────────────────────────────────────────────────────

async def main():
    await demonstrate_concurrency()
    demonstrate_threading()
    demonstrate_multiprocessing()
    when_to_use()
    await demonstrate_scraping()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Common Async Patterns

### Async Patterns Reference

```python
"""
Common async patterns for FastAPI
"""

import asyncio
from typing import Optional, List, Dict, Any
from contextlib import asynccontextmanager
import time
import random

# ────────────────────────────────────────────────────────────────
# Pattern 1: Retry with Exponential Backoff
# ────────────────────────────────────────────────────────────────

async def retry_with_backoff(
    func,
    max_retries: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 30.0,
    backoff_factor: float = 2.0,
    exceptions: tuple = (Exception,),
):
    """
    Retry an async function with exponential backoff.
    
    Args:
        func: Async function to retry
        max_retries: Maximum number of retry attempts
        base_delay: Initial delay between retries
        max_delay: Maximum delay between retries
        backoff_factor: Multiplier for each retry
        exceptions: Tuple of exceptions to retry on
        
    Returns:
        Result of the function
    """
    delay = base_delay
    last_exception = None
    
    for attempt in range(max_retries):
        try:
            return await func()
        except exceptions as e:
            last_exception = e
            
            if attempt == max_retries - 1:
                break
            
            # Calculate delay with jitter
            jitter = random.uniform(0, 0.1 * delay)
            wait_time = min(delay + jitter, max_delay)
            
            print(f"Retry {attempt + 1}/{max_retries} failed: {e}. Waiting {wait_time:.2f}s")
            await asyncio.sleep(wait_time)
            
            delay = min(delay * backoff_factor, max_delay)
    
    raise last_exception

# Example usage
async def unstable_operation():
    """Simulate an unstable operation."""
    if random.random() < 0.7:
        raise ValueError("Random failure")
    return "Success!"

async def demo_retry():
    print("=== Retry Pattern ===")
    result = await retry_with_backoff(unstable_operation, max_retries=5)
    print(f"Result: {result}")

# ────────────────────────────────────────────────────────────────
# Pattern 2: Circuit Breaker
# ────────────────────────────────────────────────────────────────

class CircuitBreaker:
    """
    Circuit breaker pattern for fault tolerance.
    
    States:
    - CLOSED: Normal operation (calls go through)
    - OPEN: Failed too many times (calls fail fast)
    - HALF_OPEN: Testing if service recovered
    """
    
    def __init__(
        self,
        failure_threshold: int = 5,
        recovery_timeout: float = 30.0,
        half_open_timeout: float = 5.0,
    ):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.half_open_timeout = half_open_timeout
        
        self.failure_count = 0
        self.last_failure_time = 0
        self.state = "CLOSED"
        self._lock = asyncio.Lock()
    
    async def call(self, func, *args, **kwargs):
        """Execute a function with circuit breaker protection."""
        async with self._lock:
            # Check state
            if self.state == "OPEN":
                if time.time() - self.last_failure_time > self.recovery_timeout:
                    self.state = "HALF_OPEN"
                    print("Circuit: HALF_OPEN - Testing service")
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            elif self.state == "HALF_OPEN":
                # In half-open, only allow one request to test
                pass  # Allow one request to test
            
            # Execute the function
            try:
                result = await func(*args, **kwargs)
                
                # Success!
                if self.state == "HALF_OPEN":
                    print("Circuit: CLOSED - Service recovered")
                    self.state = "CLOSED"
                    self.failure_count = 0
                
                return result
                
            except Exception as e:
                # Failure!
                self.failure_count += 1
                self.last_failure_time = time.time()
                
                if self.state == "HALF_OPEN":
                    print("Circuit: OPEN - Service still failing")
                    self.state = "OPEN"
                
                elif self.failure_count >= self.failure_threshold:
                    print(f"Circuit: OPEN - Failed {self.failure_count} times")
                    self.state = "OPEN"
                
                raise

# Example usage
async def unreliable_service():
    """Simulate an unreliable service."""
    if random.random() < 0.6:
        raise ConnectionError("Service temporarily unavailable")
    return "Service response"

async def demo_circuit_breaker():
    print("\n=== Circuit Breaker Pattern ===")
    
    cb = CircuitBreaker(failure_threshold=3, recovery_timeout=5)
    
    for i in range(10):
        try:
            result = await cb.call(unreliable_service)
            print(f"Request {i+1}: {result}")
        except Exception as e:
            print(f"Request {i+1}: Failed - {e}")
        
        await asyncio.sleep(0.5)

# ────────────────────────────────────────────────────────────────
# Pattern 3: Rate Limiter
# ────────────────────────────────────────────────────────────────

class AsyncRateLimiter:
    """
    Rate limiter for async operations.
    
    Implements token bucket algorithm.
    """
    
    def __init__(self, max_requests: int, time_window: float):
        self.max_requests = max_requests
        self.time_window = time_window
        self.tokens = max_requests
        self.last_refill = time.time()
        self._lock = asyncio.Lock()
    
    async def acquire(self) -> bool:
        """Acquire a token."""
        async with self._lock:
            now = time.time()
            elapsed = now - self.last_refill
            
            # Refill tokens
            if elapsed > 0:
                new_tokens = elapsed / self.time_window * self.max_requests
                self.tokens = min(self.max_requests, self.tokens + new_tokens)
                self.last_refill = now
            
            # Check if we have a token
            if self.tokens >= 1:
                self.tokens -= 1
                return True
            
            return False
    
    async def wait_for_token(self, timeout: float = 5.0):
        """Wait until a token is available."""
        start = time.time()
        
        while True:
            if await self.acquire():
                return
            
            if time.time() - start > timeout:
                raise TimeoutError("Rate limiter timeout")
            
            await asyncio.sleep(0.1)

# Example usage
async def rate_limited_operation(limiter, operation_id):
    """Perform operation with rate limiting."""
    await limiter.wait_for_token()
    print(f"Operation {operation_id}: Executing")
    await asyncio.sleep(0.1)
    return f"Result {operation_id}"

async def demo_rate_limiter():
    print("\n=== Rate Limiter Pattern ===")
    
    limiter = AsyncRateLimiter(max_requests=3, time_window=2)
    
    tasks = [
        rate_limited_operation(limiter, i)
        for i in range(10)
    ]
    
    start = time.time()
    results = await asyncio.gather(*tasks)
    duration = time.time() - start
    
    print(f"Completed 10 operations in {duration:.2f}s")
    print(f"Results: {results}")

# ────────────────────────────────────────────────────────────────
# Pattern 4: Async Context Manager
# ────────────────────────────────────────────────────────────────

@asynccontextmanager
async def async_resource_manager():
    """Async context manager example."""
    print("Acquiring resource...")
    # Acquire resource (e.g., database connection)
    resource = {"id": 123, "status": "active"}
    
    try:
        yield resource
    finally:
        print("Releasing resource...")
        # Release resource
        resource["status"] = "released"

async def demo_async_context():
    print("\n=== Async Context Manager Pattern ===")
    
    async with async_resource_manager() as resource:
        print(f"Using resource: {resource}")
        await asyncio.sleep(0.5)
        print("Resource used successfully")

# ────────────────────────────────────────────────────────────────
# Pattern 5: Producer-Consumer
# ────────────────────────────────────────────────────────────────

class AsyncProducerConsumer:
    """Producer-consumer pattern with async queue."""
    
    def __init__(self, max_size: int = 10):
        self.queue = asyncio.Queue(maxsize=max_size)
        self._stop = False
    
    async def produce(self, producer_id: int, items: List[Any]):
        """Produce items to the queue."""
        for item in items:
            if self._stop:
                break
            await self.queue.put(item)
            print(f"Producer {producer_id}: Produced {item}")
            await asyncio.sleep(random.uniform(0.1, 0.5))
        
        print(f"Producer {producer_id}: Done")
    
    async def consume(self, consumer_id: int):
        """Consume items from the queue."""
        while not self._stop or not self.queue.empty():
            try:
                item = await asyncio.wait_for(self.queue.get(), timeout=1.0)
                print(f"Consumer {consumer_id}: Consumed {item}")
                self.queue.task_done()
                await asyncio.sleep(random.uniform(0.2, 0.8))
            except asyncio.TimeoutError:
                if self._stop:
                    break
    
    def stop(self):
        """Stop the producer-consumer."""
        self._stop = True

async def demo_producer_consumer():
    print("\n=== Producer-Consumer Pattern ===")
    
    pc = AsyncProducerConsumer(max_size=5)
    
    producers = [
        pc.produce(1, [f"A{i}" for i in range(5)]),
        pc.produce(2, [f"B{i}" for i in range(5)]),
    ]
    
    consumers = [
        pc.consume(1),
        pc.consume(2),
    ]
    
    # Run producers and consumers concurrently
    await asyncio.gather(
        *producers,
        *consumers,
    )
    
    pc.stop()

# ────────────────────────────────────────────────────────────────
# Run all demos
# ────────────────────────────────────────────────────────────────

async def main():
    await demo_retry()
    await demo_circuit_breaker()
    await demo_rate_limiter()
    await demo_async_context()
    await demo_producer_consumer()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Debugging Async Code

### Async Debugging Techniques

```python
"""
Debugging async code
"""

import asyncio
import logging
import time
import traceback
from typing import Optional

# ────────────────────────────────────────────────────────────────
# 1. Setup Debug Logging
# ────────────────────────────────────────────────────────────────

def setup_async_debugging():
    """Configure debugging for async code."""
    
    # Enable debug mode
    loop = asyncio.get_running_loop()
    loop.set_debug(True)
    
    # Configure logging
    logging.basicConfig(level=logging.DEBUG)
    
    # Show slow callbacks
    loop.slow_callback_duration = 0.1  # 100ms
    
    print("Async debugging enabled")

# ────────────────────────────────────────────────────────────────
# 2. Async Stack Traces
# ────────────────────────────────────────────────────────────────

async def debug_stack_trace():
    """Get stack trace from async functions."""
    
    try:
        async def inner():
            await asyncio.sleep(0.5)
            raise ValueError("Something went wrong")
        
        await inner()
    except ValueError as e:
        # Print full traceback
        print("Full traceback:")
        traceback.print_exc()
        
        # Get current task
        task = asyncio.current_task()
        print(f"Task: {task}")
        print(f"Task name: {task.get_name()}")

# ────────────────────────────────────────────────────────────────
# 3. Async Profiling
# ────────────────────────────────────────────────────────────────

class AsyncProfiler:
    """Profile async code execution."""
    
    def __init__(self):
        self.starts = {}
        self.timings = {}
    
    def start(self, name: str):
        """Start timing a section."""
        self.starts[name] = time.perf_counter()
    
    def stop(self, name: str):
        """Stop timing a section."""
        if name in self.starts:
            duration = time.perf_counter() - self.starts[name]
            if name not in self.timings:
                self.timings[name] = []
            self.timings[name].append(duration)
            del self.starts[name]
    
    def report(self):
        """Print profiling report."""
        print("\n=== Async Profiling Report ===")
        for name, times in self.timings.items():
            avg = sum(times) / len(times)
            total = sum(times)
            count = len(times)
            max_time = max(times)
            min_time = min(times)
            
            print(f"\n{name}:")
            print(f"  Calls: {count}")
            print(f"  Total: {total:.4f}s")
            print(f"  Avg:   {avg:.4f}s")
            print(f"  Min:   {min_time:.4f}s")
            print(f"  Max:   {max_time:.4f}s")

# Example usage
async def profiled_function(profiler: AsyncProfiler):
    """Function with profiling."""
    profiler.start("operation_1")
    await asyncio.sleep(0.3)
    profiler.stop("operation_1")
    
    profiler.start("operation_2")
    await asyncio.sleep(0.5)
    profiler.stop("operation_2")

async def demo_profiler():
    profiler = AsyncProfiler()
    
    for i in range(5):
        await profiled_function(profiler)
    
    profiler.report()

# ────────────────────────────────────────────────────────────────
# 4. Common Async Bugs
# ────────────────────────────────────────────────────────────────

async def demonstrate_async_bugs():
    """Demonstrate common async bugs and fixes."""
    
    print("\n=== Common Async Bugs ===")
    
    # ────────────────────────────────────────────────────────────────
    # Bug 1: Forgetting to await
    # ────────────────────────────────────────────────────────────────
    print("\nBug 1: Forgetting to await")
    
    async def get_data():
        await asyncio.sleep(0.1)
        return "Data"
    
    # WRONG
    result = get_data()  # This is a coroutine object, not the result
    print(f"Wrong: {result}")  # <coroutine object get_data at 0x...>
    
    # CORRECT
    result = await get_data()
    print(f"Correct: {result}")
    
    # ────────────────────────────────────────────────────────────────
    # Bug 2: Creating tasks without keeping references
    # ────────────────────────────────────────────────────────────────
    print("\nBug 2: Tasks without references")
    
    # WRONG - task may be garbage collected
    async def background_work():
        await asyncio.sleep(1)
        print("Background work done")
    
    # This may not run
    asyncio.create_task(background_work())
    print("Task created but may not execute")
    
    # CORRECT - keep reference
    task = asyncio.create_task(background_work())
    # Ensure task runs
    await asyncio.sleep(1.5)
    print("Task executed")
    
    # ────────────────────────────────────────────────────────────────
    # Bug 3: Blocking the event loop
    # ────────────────────────────────────────────────────────────────
    print("\nBug 3: Blocking the event loop")
    
    async def count():
        for i in range(5):
            print(f"Counting: {i}")
            await asyncio.sleep(0.5)  # Good - yields to event loop
    
    async def blocking():
        # WRONG - this blocks the event loop
        print("Starting blocking operation...")
        time.sleep(2)  # Blocks the event loop!
        print("Blocking operation done")
    
    async def non_blocking():
        # CORRECT - use asyncio.sleep
        print("Starting non-blocking operation...")
        await asyncio.sleep(2)
        print("Non-blocking operation done")
    
    async def run_with_blocking():
        # This will run sequentially because time.sleep blocks
        await asyncio.gather(
            count(),
            blocking(),
        )
    
    print("With blocking sleep:")
    await run_with_blocking()
    
    print("\nWith non-blocking sleep:")
    await asyncio.gather(
        count(),
        non_blocking(),
    )
    
    # ────────────────────────────────────────────────────────────────
    # Bug 4: Exception handling in tasks
    # ────────────────────────────────────────────────────────────────
    print("\nBug 4: Exception handling")
    
    async def failing_task():
        raise ValueError("Task failed")
    
    # WRONG - exception is unhandled
    task = asyncio.create_task(failing_task())
    # Exception is raised when task is awaited or garbage collected
    # Use asyncio.gather with return_exceptions=True
    
    # CORRECT - handle exceptions
    results = await asyncio.gather(
        failing_task(),
        return_exceptions=True,
    )
    for result in results:
        if isinstance(result, Exception):
            print(f"Caught: {result}")
        else:
            print(f"Result: {result}")

# ────────────────────────────────────────────────────────────────
# 5. Debugging Tools
# ────────────────────────────────────────────────────────────────

async def debug_tools():
    """Showcase debugging tools."""
    
    print("\n=== Async Debugging Tools ===")
    
    # Get current event loop
    loop = asyncio.get_running_loop()
    print(f"Event loop: {loop}")
    
    # Get current task
    task = asyncio.current_task()
    print(f"Current task: {task}")
    print(f"Task name: {task.get_name()}")
    
    # Set task name
    task.set_name("MainTask")
    print(f"Task renamed to: {task.get_name()}")
    
    # Get all tasks
    all_tasks = asyncio.all_tasks()
    print(f"All tasks: {len(all_tasks)}")
    for t in all_tasks:
        print(f"  - {t.get_name()}: {t._state}")

# ────────────────────────────────────────────────────────────────
# Run demos
# ────────────────────────────────────────────────────────────────

async def main():
    # Setup debugging
    try:
        loop = asyncio.get_running_loop()
        loop.set_debug(True)
        loop.slow_callback_duration = 0.1
    except:
        pass
    
    # Run demos
    await debug_stack_trace()
    await demo_profiler()
    await demonstrate_async_bugs()
    await debug_tools()

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Performance Considerations

### Async Performance Guide

```python
"""
Async performance optimization
"""

import asyncio
import time
import sys
from typing import List, Dict, Any

# ────────────────────────────────────────────────────────────────
# 1. Measuring Async Overhead
# ────────────────────────────────────────────────────────────────

async def measure_overhead():
    """Measure async overhead."""
    print("\n=== Async Overhead ===")
    
    # Measure function call overhead
    async def empty_async():
        pass
    
    def empty_sync():
        pass
    
    # Sync function
    start = time.perf_counter()
    for _ in range(10000):
        empty_sync()
    sync_time = time.perf_counter() - start
    
    # Async function (without await)
    start = time.perf_counter()
    for _ in range(10000):
        coro = empty_async()
        # Need to close coroutine to avoid warnings
        coro.close()
    async_create_time = time.perf_counter() - start
    
    # Async function (with await)
    start = time.perf_counter()
    for _ in range(1000):
        await empty_async()
    async_await_time = time.perf_counter() - start
    
    print(f"Sync function (10,000 calls): {sync_time:.4f}s")
    print(f"Async creation (10,000 calls): {async_create_time:.4f}s")
    print(f"Async await (1,000 calls): {async_await_time:.4f}s")
    
    # Average overhead
    if sync_time > 0:
        async_overhead = (async_create_time - sync_time) / 10000
        print(f"Async overhead per call: {async_overhead*1000:.2f}ms")

# ────────────────────────────────────────────────────────────────
# 2. Optimizing Async Code
# ────────────────────────────────────────────────────────────────

async def optimized_async():
    """Optimized async patterns."""
    
    print("\n=== Async Optimization ===")
    
    # ────────────────────────────────────────────────────────────────
    # Use asyncio.gather for parallel tasks
    # ────────────────────────────────────────────────────────────────
    async def task(name: str, delay: float):
        await asyncio.sleep(delay)
        return f"{name}: done"
    
    # Slow: sequential
    start = time.time()
    results = []
    for i in range(5):
        result = await task(f"Seq{i}", 0.1)
        results.append(result)
    seq_time = time.time() - start
    
    # Fast: parallel
    start = time.time()
    results = await asyncio.gather(*[
        task(f"Par{i}", 0.1) for i in range(5)
    ])
    par_time = time.time() - start
    
    print(f"Sequential (5 tasks, 0.1s each): {seq_time:.2f}s")
    print(f"Parallel (5 tasks, 0.1s each): {par_time:.2f}s")
    print(f"Speedup: {seq_time/par_time:.2f}x")
    
    # ────────────────────────────────────────────────────────────────
    # Batch processing
    # ────────────────────────────────────────────────────────────────
    async def process_item(item: int):
        await asyncio.sleep(0.01)
        return item * 2
    
    items = list(range(100))
    
    # Process one by one
    start = time.time()
    results = []
    for item in items:
        result = await process_item(item)
        results.append(result)
    batch_time = time.time() - start
    
    # Process in batches
    start = time.time()
    batch_size = 20
    results = []
    for i in range(0, len(items), batch_size):
        batch = items[i:i+batch_size]
        batch_results = await asyncio.gather(*[
            process_item(item) for item in batch
        ])
        results.extend(batch_results)
    batched_time = time.time() - start
    
    print(f"\nProcessing 100 items:")
    print(f"Sequential: {batch_time:.2f}s")
    print(f"Batched (size {batch_size}): {batched_time:.2f}s")
    print(f"Speedup: {batch_time/batched_time:.2f}x")

# ────────────────────────────────────────────────────────────────
# 3. When NOT to Use Async
# ────────────────────────────────────────────────────────────────

def cpu_bound_task(n: int) -> int:
    """CPU-intensive task."""
    result = 0
    for i in range(n):
        result += i ** 2
    return result

async def async_cpu_bound(n: int) -> int:
    """Async wrapper for CPU task (still blocks!)."""
    # This is WRONG - async doesn't speed up CPU tasks
    return cpu_bound_task(n)

async def async_cpu_bound_correct(n: int) -> int:
    """Correct way to handle CPU tasks."""
    # Use asyncio.to_thread to offload to thread pool
    return await asyncio.to_thread(cpu_bound_task, n)

async def compare_cpu_handling():
    """Compare different ways to handle CPU tasks."""
    print("\n=== CPU-Bound Tasks ===")
    
    # Run CPU task directly (blocks)
    print("Running CPU task directly (blocks)...")
    start = time.time()
    result = cpu_bound_task(1000000)
    direct_time = time.time() - start
    print(f"Direct: {direct_time:.2f}s")
    
    # Run CPU task with async (still blocks)
    print("Running CPU task with async (still blocks)...")
    start = time.time()
    result = await async_cpu_bound(1000000)
    async_time = time.time() - start
    print(f"Async wrapper: {async_time:.2f}s")
    
    # Run CPU task correctly in thread pool
    print("Running CPU task in thread pool...")
    start = time.time()
    result = await async_cpu_bound_correct(1000000)
    correct_time = time.time() - start
    print(f"Thread pool: {correct_time:.2f}s")
    
    # Run multiple CPU tasks in thread pool
    print("\nMultiple CPU tasks in thread pool...")
    start = time.time()
    results = await asyncio.gather(*[
        async_cpu_bound_correct(500000) for _ in range(4)
    ])
    multi_time = time.time() - start
    print(f"4 tasks in thread pool: {multi_time:.2f}s")
    
    # Compare to direct (should be similar, but async allows concurrency)
    print(f"\nDirect: {direct_time:.2f}s")
    print(f"Thread pool (4 tasks): {multi_time:.2f}s")
    if multi_time > direct_time:
        print("Thread pool has overhead but enables concurrency")

# ────────────────────────────────────────────────────────────────
# 4. Async Performance Tips
# ────────────────────────────────────────────────────────────────

async def performance_tips():
    """Async performance tips."""
    print("\n=== Async Performance Tips ===")
    
    tips = {
        "Use asyncio.gather for parallel I/O": """
            # Bad:
            result1 = await fetch_url(url1)
            result2 = await fetch_url(url2)
            
            # Good:
            results = await asyncio.gather(
                fetch_url(url1),
                fetch_url(url2),
            )
        """,
        
        "Set reasonable timeouts": """
            # Bad:
            result = await fetch_data()
            
            # Good:
            result = await asyncio.wait_for(
                fetch_data(),
                timeout=5.0
            )
        """,
        
        "Use asyncio.to_thread for blocking code": """
            # Bad:
            result = blocking_cpu_task(data)  # Blocks event loop
            
            # Good:
            result = await asyncio.to_thread(blocking_cpu_task, data)
        """,
        
        "Avoid creating too many tasks": """
            # Bad:
            tasks = [asyncio.create_task(process(item)) for item in huge_list]
            results = await asyncio.gather(*tasks)  # Memory heavy
            
            # Good:
            semaphore = asyncio.Semaphore(100)
            async def limited_process(item):
                async with semaphore:
                    return await process(item)
            tasks = [limited_process(item) for item in huge_list]
            results = await asyncio.gather(*tasks)
        """,
        
        "Use connection pooling": """
            # Bad:
            async with httpx.AsyncClient() as client:
                response = await client.get(url)  # Creates new client each time
            
            # Good:
            async with httpx.AsyncClient() as client:  # Reuse client
                responses = await asyncio.gather(*[
                    client.get(url) for url in urls
                ])
        """,
    }
    
    for tip, code in tips.items():
        print(f"\n{tip}:")
        print(code.strip())

# ────────────────────────────────────────────────────────────────
# 5. Async vs Sync Benchmarks
# ────────────────────────────────────────────────────────────────

async def async_sync_benchmark():
    """Benchmark async vs sync for I/O operations."""
    print("\n=== Async vs Sync Benchmarks ===")
    
    import aiohttp
    import requests
    
    async def async_fetch(session, url):
        async with session.get(url) as response:
            return response.status
    
    def sync_fetch(url):
        response = requests.get(url)
        return response.status_code
    
    urls = [
        "https://httpbin.org/delay/0.1" for _ in range(10)
    ]
    
    # Sync
    print("Synchronous:")
    start = time.time()
    results = []
    for url in urls:
        results.append(sync_fetch(url))
    sync_time = time.time() - start
    print(f"  Time: {sync_time:.2f}s")
    
    # Async (sequential with await)
    print("Async (sequential):")
    start = time.time()
    async with aiohttp.ClientSession() as session:
        results = []
        for url in urls:
            results.append(await async_fetch(session, url))
    async_seq_time = time.time() - start
    print(f"  Time: {async_seq_time:.2f}s")
    
    # Async (parallel)
    print("Async (parallel):")
    start = time.time()
    async with aiohttp.ClientSession() as session:
        tasks = [async_fetch(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
    async_par_time = time.time() - start
    print(f"  Time: {async_par_time:.2f}s")
    
    print(f"\nAsync (parallel) is {sync_time/async_par_time:.2f}x faster")

# ────────────────────────────────────────────────────────────────
# Run all benchmarks
# ────────────────────────────────────────────────────────────────

async def main():
    await measure_overhead()
    await optimized_async()
    await compare_cpu_handling()
    await performance_tips()
    await async_sync_benchmark()

if __name__ == "__main__":
    asyncio.run(main())
```

---

This primer has provided a comprehensive deep dive into Python's async/await system. You should now understand:

1. **The Event Loop**: How async code is scheduled and executed
2. **Async/Await Syntax**: Proper usage patterns and common mistakes
3. **Coroutines and Tasks**: Task management, cancellation, and monitoring
4. **Concurrency vs Parallelism**: When to use each approach
5. **Async Patterns**: Retry, circuit breaker, rate limiting, and more
6. **Debugging**: Techniques for debugging async code
7. **Performance**: Optimization strategies and when to use async

These concepts are fundamental to building high-performance FastAPI applications. Practice these patterns and refer back to this primer whenever you need to understand async behavior in your applications.

**[END OF PRIMER 1]**
