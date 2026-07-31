# Primer 2: Asynchronous Programming with Python

## P2.1 Introduction to Asynchronous Programming

### What is Asynchronous Programming?

Asynchronous programming is a way of writing code that can handle multiple tasks seemingly at the same time. Think of it like a chef cooking multiple dishes:
- **Synchronous** - The chef finishes one dish completely before starting the next
- **Asynchronous** - The chef starts a dish, lets it simmer, works on another dish, then comes back

### Why Async?

| Problem | Async Solution |
|---------|---------------|
| **Slow I/O** | Don't wait - do other work while waiting |
| **Many connections** | Handle thousands concurrently with few threads |
| **Real-time response** | Respond to events as they happen |
| **Resource efficiency** | Use less memory and CPU than threading |

### Async vs Threading vs Multiprocessing

```python
# SYNC - Blocking, simple
def sync_fetch(urls):
    results = []
    for url in urls:
        results.append(requests.get(url).text)
    return results

# THREADING - Parallel, complex
def thread_fetch(urls):
    with ThreadPoolExecutor(max_workers=10) as executor:
        return list(executor.map(requests.get, urls))

# ASYNC - Concurrent, efficient
async def async_fetch(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [session.get(url) for url in urls]
        responses = await asyncio.gather(*tasks)
        return [await r.text() for r in responses]
```

### Key Concepts

| Concept | Description | Analogy |
|---------|-------------|---------|
| **Coroutine** | `async def` function | A task that can be paused/resumed |
| **Event Loop** | Scheduler for coroutines | The kitchen manager |
| **Task** | Wrapped coroutine | An order being prepared |
| **Await** | Wait for something | Checking if a dish is ready |
| **Future** | Promise of a result | A ticket for a completed dish |

---

## P2.2 Basic Async Syntax

### Defining Coroutines

```python
import asyncio

# Basic coroutine
async def hello():
    print("Hello")
    await asyncio.sleep(1)  # Non-blocking sleep
    print("World")
    return "Done"

# Running a coroutine
async def main():
    result = await hello()
    print(f"Result: {result}")

# Entry point
asyncio.run(main())

# Coroutine with parameters
async def greet(name: str, delay: int = 1) -> str:
    await asyncio.sleep(delay)
    return f"Hello, {name}!"

# Multiple awaits
async def multi_await():
    result1 = await greet("Alice", 1)
    result2 = await greet("Bob", 2)
    return result1, result2
```

### Async Functions vs Regular Functions

```python
# Regular function
def regular_function():
    return "Hello"  # Returns immediately

# Async function
async def async_function():
    return "Hello"  # Returns a coroutine object

# Difference
regular_result = regular_function()  # "Hello"
async_result = async_function()  # <coroutine object async_function>
# Must use await to get the value

# Running async function
async def main():
    value = await async_function()  # "Hello"
    print(value)
```

### The await Keyword

```python
# await can only be used inside async functions
async def correct():
    result = await some_async_function()
    return result

# This is WRONG
def wrong():
    result = await some_async_function()  # SyntaxError
    return result

# What can be awaited?
# 1. Coroutines
# 2. Tasks
# 3. Futures
# 4. Things with __await__ method

async def await_examples():
    # Coroutine
    coro = asyncio.sleep(1)
    await coro
    
    # Task
    task = asyncio.create_task(asyncio.sleep(1))
    await task
    
    # Future
    future = asyncio.Future()
    # ... set future result later
    await future
```

---

## P2.3 Task Management

### Creating and Managing Tasks

```python
import asyncio

async def slow_operation(name: str, delay: int) -> str:
    print(f"Starting {name}...")
    await asyncio.sleep(delay)
    print(f"Finished {name}")
    return f"{name} completed"

async def task_demo():
    # Create tasks (they start immediately)
    task1 = asyncio.create_task(slow_operation("Task 1", 2))
    task2 = asyncio.create_task(slow_operation("Task 2", 1))
    
    # Do other work while tasks run
    print("Doing other work...")
    await asyncio.sleep(0.5)
    
    # Wait for tasks to complete
    result1 = await task1
    result2 = await task2
    
    print(f"Results: {result1}, {result2}")

asyncio.run(task_demo())
```

### Task Groups (Python 3.11+)

```python
import asyncio

async def task_group_demo():
    async with asyncio.TaskGroup() as tg:
        task1 = tg.create_task(slow_operation("Task 1", 2))
        task2 = tg.create_task(slow_operation("Task 2", 1))
        task3 = tg.create_task(slow_operation("Task 3", 3))
    
    # All tasks are complete here
    print(f"Task 1 result: {task1.result()}")
    print(f"Task 2 result: {task2.result()}")
    print(f"Task 3 result: {task3.result()}")

asyncio.run(task_group_demo())
```

### Task Utilities

```python
import asyncio

# Get current task
async def current_task_demo():
    task = asyncio.current_task()
    print(f"Current task: {task.get_name()}")

# Get all tasks
async def all_tasks_demo():
    await asyncio.sleep(0.1)  # Let tasks start
    tasks = asyncio.all_tasks()
    for task in tasks:
        print(f"Task: {task.get_name()} - Done: {task.done()}")

# Task naming
async def named_task_demo():
    task = asyncio.create_task(asyncio.sleep(1), name="MyTask")
    print(f"Task name: {task.get_name()}")

# Task cancellation
async def cancellable_task():
    try:
        await asyncio.sleep(10)
    except asyncio.CancelledError:
        print("Task was cancelled")
        raise

async def cancel_demo():
    task = asyncio.create_task(cancellable_task())
    await asyncio.sleep(1)
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        print("Cancellation handled")

asyncio.run(cancel_demo())
```

---

## P2.4 Running Multiple Coroutines

### asyncio.gather()

```python
import asyncio

async def gather_demo():
    # Run multiple coroutines concurrently
    results = await asyncio.gather(
        slow_operation("A", 2),
        slow_operation("B", 1),
        slow_operation("C", 3)
    )
    print(f"All results: {results}")
    
    # With tasks
    tasks = [
        asyncio.create_task(slow_operation("D", 2)),
        asyncio.create_task(slow_operation("E", 1)),
    ]
    results = await asyncio.gather(*tasks)
    print(f"Task results: {results}")
    
    # Return exceptions instead of raising
    async def failing_task():
        raise ValueError("Something went wrong")
    
    results = await asyncio.gather(
        slow_operation("F", 1),
        failing_task(),
        slow_operation("G", 1),
        return_exceptions=True
    )
    print(f"Results with exceptions: {results}")

asyncio.run(gather_demo())
```

### asyncio.wait()

```python
import asyncio

async def wait_demo():
    tasks = [
        asyncio.create_task(slow_operation("A", 3)),
        asyncio.create_task(slow_operation("B", 1)),
        asyncio.create_task(slow_operation("C", 2)),
    ]
    
    # Wait for all tasks to complete
    done, pending = await asyncio.wait(tasks)
    print(f"All done: {len(done)}, pending: {len(pending)}")
    
    # Wait for first completion
    tasks = [
        asyncio.create_task(slow_operation("D", 3)),
        asyncio.create_task(slow_operation("E", 1)),
        asyncio.create_task(slow_operation("F", 2)),
    ]
    done, pending = await asyncio.wait(
        tasks,
        return_when=asyncio.FIRST_COMPLETED
    )
    
    # Cancel remaining tasks
    for task in pending:
        task.cancel()
    
    print(f"First completed: {done.pop().result()}")

asyncio.run(wait_demo())
```

### asyncio.as_completed()

```python
import asyncio

async def as_completed_demo():
    tasks = [
        slow_operation("A", 3),
        slow_operation("B", 1),
        slow_operation("C", 2),
    ]
    
    # Process results as they complete
    for coro in asyncio.as_completed(tasks):
        result = await coro
        print(f"Completed: {result}")
    
    # With timeout
    tasks = [
        slow_operation("D", 5),
        slow_operation("E", 1),
        slow_operation("F", 2),
    ]
    
    try:
        for coro in asyncio.as_completed(tasks, timeout=2):
            result = await coro
            print(f"Completed: {result}")
    except asyncio.TimeoutError:
        print("Some tasks timed out")

asyncio.run(as_completed_demo())
```

---

## P2.5 Async Context Managers

### Using Async Context Managers

```python
import aiohttp
import asyncio

# Built-in async context managers
async def builtin_examples():
    # aiohttp ClientSession
    async with aiohttp.ClientSession() as session:
        async with session.get('https://example.com') as response:
            data = await response.text()
            print(f"Got response: {len(data)} bytes")
    
    # asyncio locks
    lock = asyncio.Lock()
    async with lock:
        print("Lock acquired")
    
    # asyncio semaphores
    semaphore = asyncio.Semaphore(5)
    async with semaphore:
        print("Semaphore acquired")
    
    # asyncio timeout
    async with asyncio.timeout(5):
        await asyncio.sleep(1)
        print("Within timeout")

asyncio.run(builtin_examples())
```

### Creating Async Context Managers

```python
import asyncio
import time

# Using class with __aenter__ and __aexit__
class Timer:
    def __init__(self, name):
        self.name = name
        self.start_time = None
    
    async def __aenter__(self):
        self.start_time = time.time()
        print(f"Starting: {self.name}")
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        elapsed = time.time() - self.start_time
        print(f"Finished: {self.name} in {elapsed:.2f}s")
    
    async def do_work(self):
        await asyncio.sleep(1)

# Using @asynccontextmanager decorator
from contextlib import asynccontextmanager

@asynccontextmanager
async def timeout_context(seconds):
    print(f"Timeout: {seconds}s")
    try:
        yield await asyncio.sleep(seconds)
    except asyncio.CancelledError:
        print("Operation cancelled")
        raise

# Usage
async def context_demo():
    # Class-based
    async with Timer("Operation 1") as timer:
        await timer.do_work()
    
    # Decorator-based
    async with timeout_context(2):
        await asyncio.sleep(1)
        print("Operation complete")
    
    # Nested contexts
    async with Timer("Combined") as timer:
        async with aiohttp.ClientSession() as session:
            async with session.get('https://example.com') as response:
                data = await response.text()
                print(f"Fetched {len(data)} bytes")

asyncio.run(context_demo())
```

---

## P2.6 Async Queues

### Basic Queue Operations

```python
import asyncio
from asyncio import Queue

async def queue_basics():
    # Create queue
    queue = Queue(maxsize=5)
    
    # Put items
    await queue.put("Item 1")
    await queue.put("Item 2")
    
    # Get items
    item = await queue.get()
    print(f"Got: {item}")
    queue.task_done()
    
    # Check size
    print(f"Queue size: {queue.qsize()}")
    print(f"Empty: {queue.empty()}")
    print(f"Full: {queue.full()}")

asyncio.run(queue_basics())
```

### Producer-Consumer Pattern

```python
import asyncio
from asyncio import Queue
import random

async def producer(queue: Queue, name: str, count: int):
    """Produce items for the queue."""
    for i in range(count):
        item = f"{name}-{i}"
        await queue.put(item)
        print(f"Produced: {item}")
        await asyncio.sleep(random.uniform(0.1, 0.5))
    
    # Signal completion
    await queue.put(None)

async def consumer(queue: Queue, name: str):
    """Consume items from the queue."""
    results = []
    
    while True:
        item = await queue.get()
        if item is None:
            # Sentinel received
            queue.task_done()
            break
        
        # Process item
        print(f"Consumer {name} processing: {item}")
        await asyncio.sleep(random.uniform(0.2, 0.8))
        results.append(item)
        queue.task_done()
    
    return results

async def producer_consumer_demo():
    queue = Queue(maxsize=10)
    
    # Start producers
    producers = [
        asyncio.create_task(producer(queue, "A", 5)),
        asyncio.create_task(producer(queue, "B", 5)),
    ]
    
    # Start consumers
    consumers = [
        asyncio.create_task(consumer(queue, "1")),
        asyncio.create_task(consumer(queue, "2")),
    ]
    
    # Wait for producers to finish
    await asyncio.gather(*producers)
    
    # Wait for consumers to finish
    results = await asyncio.gather(*consumers)
    
    print(f"Consumer results: {results}")

asyncio.run(producer_consumer_demo())
```

### Priority Queue

```python
import asyncio
from asyncio import PriorityQueue

async def priority_queue_demo():
    queue = PriorityQueue()
    
    # Add items with priority (lower number = higher priority)
    await queue.put((3, "low priority"))
    await queue.put((1, "high priority"))
    await queue.put((2, "medium priority"))
    await queue.put((0, "critical priority"))
    
    # Get items (ordered by priority)
    while not queue.empty():
        priority, item = await queue.get()
        print(f"Priority {priority}: {item}")
        queue.task_done()

asyncio.run(priority_queue_demo())
```

### LIFO Queue (Stack)

```python
import asyncio
from asyncio import LifoQueue

async def lifo_queue_demo():
    queue = LifoQueue()
    
    # Add items
    await queue.put("First")
    await queue.put("Second")
    await queue.put("Third")
    
    # Get items (LIFO order)
    while not queue.empty():
        item = await queue.get()
        print(f"Got: {item}")
        queue.task_done()

asyncio.run(lifo_queue_demo())
```

---

## P2.7 Synchronization Primitives

### Locks

```python
import asyncio

class Counter:
    def __init__(self):
        self.value = 0
        self.lock = asyncio.Lock()
    
    async def increment(self):
        async with self.lock:
            current = self.value
            await asyncio.sleep(0.1)  # Simulate work
            self.value = current + 1
            return self.value

async def lock_demo():
    counter = Counter()
    
    # Try to increment concurrently
    tasks = [counter.increment() for _ in range(10)]
    results = await asyncio.gather(*tasks)
    
    print(f"Final value: {counter.value}")
    print(f"Results: {results}")

asyncio.run(lock_demo())
```

### Semaphores

```python
import asyncio
import random

async def semaphore_demo():
    # Limit to 3 concurrent operations
    semaphore = asyncio.Semaphore(3)
    
    async def limited_operation(name: str):
        async with semaphore:
            wait_time = random.uniform(0.5, 2)
            print(f"{name} starting (wait {wait_time:.2f}s)")
            await asyncio.sleep(wait_time)
            print(f"{name} done")
            return name
    
    # Start 10 operations
    tasks = [limited_operation(f"Task {i}") for i in range(10)]
    results = await asyncio.gather(*tasks)
    print(f"All results: {results}")

asyncio.run(semaphore_demo())
```

### Events

```python
import asyncio

async def event_demo():
    event = asyncio.Event()
    
    async def waiter(name: str):
        print(f"{name} waiting for event...")
        await event.wait()
        print(f"{name} received event!")
    
    async def setter():
        print("Setting event in 2 seconds...")
        await asyncio.sleep(2)
        event.set()
        print("Event set!")
    
    # Start waiters and setter
    await asyncio.gather(
        waiter("A"),
        waiter("B"),
        waiter("C"),
        setter()
    )

asyncio.run(event_demo())
```

### Conditions

```python
import asyncio

async def condition_demo():
    condition = asyncio.Condition()
    data = []
    
    async def producer():
        async with condition:
            for i in range(5):
                data.append(f"Item {i}")
                print(f"Produced: Item {i}")
                condition.notify()
                await asyncio.sleep(0.5)
    
    async def consumer():
        async with condition:
            while len(data) < 5:
                await condition.wait()
            print(f"Consumed all: {data}")
    
    await asyncio.gather(producer(), consumer())

asyncio.run(condition_demo())
```

---

## P2.8 Timeouts & Cancellation

### Timeouts

```python
import asyncio

async def timeout_examples():
    # Basic timeout
    try:
        result = await asyncio.wait_for(
            asyncio.sleep(5),
            timeout=2
        )
        print("Operation completed")
    except asyncio.TimeoutError:
        print("Operation timed out")
    
    # Timeout with default value
    async def operation():
        await asyncio.sleep(3)
        return "Success"
    
    try:
        result = await asyncio.wait_for(operation(), timeout=1)
    except asyncio.TimeoutError:
        result = "Default value"
    
    print(f"Result: {result}")
    
    # Timeout context manager (Python 3.11+)
    try:
        async with asyncio.timeout(2):
            await asyncio.sleep(3)
            print("This won't run")
    except asyncio.TimeoutError:
        print("Timeout context expired")

asyncio.run(timeout_examples())
```

### Cancellation

```python
import asyncio

async def cancellable_operation():
    print("Starting operation...")
    try:
        for i in range(10):
            await asyncio.sleep(1)
            print(f"Step {i + 1}")
    except asyncio.CancelledError:
        print("Operation was cancelled!")
        # Clean up resources
        raise

async def cancel_demo():
    # Basic cancellation
    task = asyncio.create_task(cancellable_operation())
    await asyncio.sleep(3)
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        print("Task cancelled successfully")
    
    # Protected cancellation
    async def protected_operation():
        try:
            await asyncio.sleep(10)
        except asyncio.CancelledError:
            print("Cannot cancel this operation!")
            # Re-raise if needed
    
    task = asyncio.create_task(protected_operation())
    await asyncio.sleep(0.5)
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        print("Protected operation handled cancellation")

asyncio.run(cancel_demo())
```

### Shield (Protect from Cancellation)

```python
import asyncio

async def shield_demo():
    async def critical_operation():
        print("Critical operation starting...")
        await asyncio.sleep(5)
        print("Critical operation complete")
        return "Important data"
    
    # Shield from cancellation
    task = asyncio.create_task(
        asyncio.shield(critical_operation())
    )
    
    # Try to cancel
    await asyncio.sleep(1)
    task.cancel()
    
    try:
        # This will raise CancelledError
        await task
    except asyncio.CancelledError:
        print("Task was cancelled, but critical operation continues...")
    
    # Wait for the critical operation to complete
    # Note: You might want to use a different approach in real code
    await asyncio.sleep(4)

asyncio.run(shield_demo())
```

---

## P2.9 Async Iterators & Generators

### Async Iterators

```python
import asyncio

class AsyncCounter:
    def __init__(self, start, end):
        self.current = start
        self.end = end
    
    def __aiter__(self):
        return self
    
    async def __anext__(self):
        if self.current >= self.end:
            raise StopAsyncIteration
        
        await asyncio.sleep(0.5)
        value = self.current
        self.current += 1
        return value

async def async_iterator_demo():
    async for number in AsyncCounter(0, 5):
        print(f"Got: {number}")

asyncio.run(async_iterator_demo())
```

### Async Generators

```python
import asyncio

async def async_generator():
    for i in range(5):
        await asyncio.sleep(0.5)
        yield i

async def async_generator_demo():
    async for value in async_generator():
        print(f"Generated: {value}")

asyncio.run(async_generator_demo())

# Generator with streaming
async def stream_data(items):
    for item in items:
        await asyncio.sleep(0.1)
        yield f"Processed: {item}"

async def stream_demo():
    async for result in stream_data(range(10)):
        print(result)

asyncio.run(stream_demo())
```

---

## P2.10 Async HTTP Client (aiohttp)

### Basic HTTP Requests

```python
import aiohttp
import asyncio

async def basic_http_demo():
    async with aiohttp.ClientSession() as session:
        # GET request
        async with session.get('https://httpbin.org/get') as response:
            print(f"Status: {response.status}")
            data = await response.json()
            print(f"Data: {data.get('url')}")
            
            # Read response content
            text = await response.text()
            print(f"Content length: {len(text)}")
    
    # POST request
    async with aiohttp.ClientSession() as session:
        data = {'name': 'John', 'age': 30}
        async with session.post(
            'https://httpbin.org/post',
            json=data
        ) as response:
            result = await response.json()
            print(f"POST result: {result.get('json')}")
    
    # Headers
    async with aiohttp.ClientSession() as session:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            'Accept': 'application/json'
        }
        async with session.get(
            'https://httpbin.org/headers',
            headers=headers
        ) as response:
            result = await response.json()
            print(f"Headers sent: {result.get('headers')}")

asyncio.run(basic_http_demo())
```

### Concurrent HTTP Requests

```python
import aiohttp
import asyncio
import time

async def fetch_url(session, url):
    try:
        async with session.get(url) as response:
            return {
                'url': url,
                'status': response.status,
                'size': len(await response.text())
            }
    except Exception as e:
        return {'url': url, 'error': str(e)}

async def concurrent_http_demo():
    urls = [
        'https://httpbin.org/delay/1',
        'https://httpbin.org/delay/2',
        'https://httpbin.org/delay/0.5',
    ] * 3  # 9 total requests
    
    start = time.time()
    
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
    
    elapsed = time.time() - start
    print(f"Completed {len(results)} requests in {elapsed:.2f}s")
    
    for result in results[:3]:
        print(f"  {result}")

asyncio.run(concurrent_http_demo())
```

### Streaming Responses

```python
import aiohttp
import asyncio

async def streaming_demo():
    async with aiohttp.ClientSession() as session:
        async with session.get('https://httpbin.org/stream/5') as response:
            # Stream JSON lines
            async for line in response.content:
                print(f"Streamed: {line[:50]}...")
            
            # Alternative: read in chunks
            async with session.get('https://httpbin.org/stream/3') as response:
                async for chunk in response.content.iter_chunks():
                    print(f"Chunk: {len(chunk[0])} bytes")

asyncio.run(streaming_demo())
```

---

## P2.11 Error Handling in Async Code

### Basic Error Handling

```python
import asyncio

async def error_handling_demo():
    # Try/except in async functions
    async def risky_operation():
        await asyncio.sleep(1)
        raise ValueError("Something went wrong")
    
    try:
        result = await risky_operation()
    except ValueError as e:
        print(f"Caught error: {e}")
    
    # Handle errors in gather
    async def operation_with_error():
        raise RuntimeError("Operation failed")
    
    results = await asyncio.gather(
        operation_with_error(),
        asyncio.sleep(1),
        return_exceptions=True
    )
    
    for result in results:
        if isinstance(result, Exception):
            print(f"Error: {result}")
        else:
            print(f"Success: {result}")

asyncio.run(error_handling_demo())
```

### Task Group Error Handling (Python 3.11+)

```python
import asyncio

async def task_group_error_demo():
    async def failing_operation():
        await asyncio.sleep(0.5)
        raise ValueError("Task failed")
    
    try:
        async with asyncio.TaskGroup() as tg:
            task1 = tg.create_task(asyncio.sleep(2))
            task2 = tg.create_task(failing_operation())
            task3 = tg.create_task(asyncio.sleep(1))
        
        # This won't be reached
        print("All tasks completed")
        
    except ExceptionGroup as eg:
        # ExceptionGroup wraps multiple exceptions
        print(f"Caught exception group with {len(eg.exceptions)} exceptions")
        for exc in eg.exceptions:
            print(f"  - {type(exc).__name__}: {exc}")

asyncio.run(task_group_error_demo())
```

### Graceful Shutdown

```python
import asyncio
import signal

async def graceful_shutdown_demo():
    # Flag for graceful shutdown
    shutdown = False
    
    async def worker(name: str):
        while not shutdown:
            print(f"Worker {name} running...")
            await asyncio.sleep(1)
        print(f"Worker {name} shutting down")
    
    # Signal handler
    def signal_handler():
        nonlocal shutdown
        print("\nReceived shutdown signal")
        shutdown = True
    
    # Setup signal handler (Unix only)
    loop = asyncio.get_running_loop()
    loop.add_signal_handler(signal.SIGINT, signal_handler)
    loop.add_signal_handler(signal.SIGTERM, signal_handler)
    
    # Start workers
    tasks = [worker(i) for i in range(3)]
    
    try:
        await asyncio.gather(*tasks)
    except asyncio.CancelledError:
        print("Tasks cancelled")
    
    print("Shutdown complete")

# Note: This won't work on Windows (signals not supported)
# asyncio.run(graceful_shutdown_demo())
```

---

## P2.12 Performance Tips

### Connection Pooling

```python
import aiohttp
import asyncio

class ConnectionPool:
    def __init__(self, limit=100, limit_per_host=20):
        self.connector = aiohttp.TCPConnector(
            limit=limit,
            limit_per_host=limit_per_host,
            ttl_dns_cache=300,
            enable_cleanup_closed=True
        )
        self.session = None
    
    async def get_session(self):
        if not self.session:
            self.session = aiohttp.ClientSession(
                connector=self.connector,
                timeout=aiohttp.ClientTimeout(total=30)
            )
        return self.session
    
    async def close(self):
        if self.session:
            await self.session.close()
        await self.connector.close()

async def connection_pool_demo():
    pool = ConnectionPool()
    session = await pool.get_session()
    
    try:
        # Use session...
        async with session.get('https://httpbin.org/get') as response:
            data = await response.json()
            print("Request successful")
    finally:
        await pool.close()

asyncio.run(connection_pool_demo())
```

### Rate Limiting

```python
import asyncio
import time

class AsyncRateLimiter:
    def __init__(self, rate, per_second=True):
        self.rate = rate
        self.per_second = per_second
        self._lock = asyncio.Lock()
        self._last_time = time.time()
        self._count = 0
    
    async def acquire(self):
        async with self._lock:
            now = time.time()
            period = 1.0 if self.per_second else 60.0
            
            if now - self._last_time >= period:
                self._count = 0
                self._last_time = now
            
            if self._count < self.rate:
                self._count += 1
                return True
            
            wait_time = period - (now - self._last_time)
            await asyncio.sleep(wait_time)
            self._count = 0
            self._last_time = time.time()
            return True

async def rate_limit_demo():
    limiter = AsyncRateLimiter(5)  # 5 per second
    
    async def limited_request(i):
        await limiter.acquire()
        print(f"Request {i} at {time.time():.2f}")
        await asyncio.sleep(0.1)
    
    tasks = [limited_request(i) for i in range(20)]
    await asyncio.gather(*tasks)

asyncio.run(rate_limit_demo())
```

### Avoid Blocking the Event Loop

```python
import asyncio
import time

async def blocking_operation():
    # This blocks the event loop!
    time.sleep(2)  # Bad!
    print("Blocking operation done")

async def non_blocking_operation():
    # This is non-blocking
    await asyncio.sleep(2)  # Good!
    print("Non-blocking operation done")

async def blocking_with_executor():
    # Run blocking code in executor
    loop = asyncio.get_running_loop()
    result = await loop.run_in_executor(
        None,  # Default executor (ThreadPoolExecutor)
        time.sleep,
        2
    )
    print("Blocking operation in executor done")

# Usage
async def compare():
    print("Bad:")
    await blocking_operation()  # Blocks
    
    print("\nGood:")
    await non_blocking_operation()  # Non-blocking
    
    print("\nBlocking with executor:")
    await blocking_with_executor()  # Non-blocking

asyncio.run(compare())
```

---

## P2.13 Common Pitfalls

### Pitfall 1: Forgetting to Await

```python
# WRONG - Doesn't execute
async def wrong():
    task = my_async_function()  # Returns coroutine, never runs
    return "Done"

# CORRECT
async def correct():
    result = await my_async_function()
    return result

# WRONG - Creating task without storing
async def wrong_task():
    asyncio.create_task(my_async_function())  # Task may be garbage collected
    return "Done"

# CORRECT
async def correct_task():
    task = asyncio.create_task(my_async_function())
    # Keep reference to task
    return "Done"
```

### Pitfall 2: Not Cancelling Tasks

```python
# WRONG - Leaves tasks running
async def wrong_cleanup():
    task = asyncio.create_task(long_operation())
    await task  # Wait forever...
    # No cleanup

# CORRECT
async def correct_cleanup():
    task = asyncio.create_task(long_operation())
    try:
        await asyncio.wait_for(task, timeout=5)
    except asyncio.TimeoutError:
        task.cancel()
        try:
            await task
        except asyncio.CancelledError:
            pass
```

### Pitfall 3: Using Async in Sync Code

```python
# WRONG - Can't call async from sync
def wrong_sync():
    result = async_function()  # TypeError

# CORRECT - Use asyncio.run()
def correct_sync():
    result = asyncio.run(async_function())
    return result

# CORRECT - Use event loop if already running
def correct_from_async():
    loop = asyncio.get_event_loop()
    if loop.is_running():
        # Running in async context
        return asyncio.create_task(async_function())
    else:
        return asyncio.run(async_function())
```

### Pitfall 4: Mixing Async and Sync I/O

```python
# WRONG - Uses sync I/O in async function
async def wrong():
    import requests
    response = requests.get('https://example.com')  # Blocks!
    return response.text

# CORRECT - Uses async I/O
async def correct():
    import aiohttp
    async with aiohttp.ClientSession() as session:
        async with session.get('https://example.com') as response:
            return await response.text()
```

---

## P2.14 Quick Reference

### Async Function Reference

| Function | Description |
|----------|-------------|
| `asyncio.run(coro)` | Run coroutine until complete |
| `asyncio.create_task(coro)` | Schedule task on event loop |
| `asyncio.gather(*coros)` | Run multiple coroutines concurrently |
| `asyncio.wait(tasks)` | Wait for tasks with conditions |
| `asyncio.wait_for(coro, timeout)` | Wait with timeout |
| `asyncio.sleep(seconds)` | Non-blocking sleep |
| `asyncio.shield(coro)` | Protect from cancellation |
| `asyncio.current_task()` | Get current task |
| `asyncio.all_tasks()` | Get all tasks |

### Async Context Managers

| Context Manager | Description |
|-----------------|-------------|
| `async with asyncio.timeout(5)` | Timeout context (3.11+) |
| `async with asyncio.Lock()` | Mutex lock |
| `async with asyncio.Semaphore(n)` | Semaphore |
| `async with aiohttp.ClientSession()` | HTTP session |
| `async with asyncio.TaskGroup()` | Task group (3.11+) |

### Async Types Reference

| Type | Description |
|------|-------------|
| `Coroutine` | `async def` function result |
| `Task` | Wrapped coroutine scheduled on loop |
| `Future` | Container for a result |
| `asyncio.Queue` | Async queue |
| `asyncio.Event` | Async event |
| `asyncio.Lock` | Async lock |

### Async Patterns Checklist

- [ ] Use `asyncio.run()` for top-level entry
- [ ] Always await coroutines
- [ ] Use `asyncio.create_task()` for background tasks
- [ ] Set timeouts for long operations
- [ ] Use async context managers for resources
- [ ] Handle exceptions properly
- [ ] Cancel tasks when no longer needed
- [ ] Use semaphores for rate limiting
- [ ] Avoid blocking the event loop
- [ ] Use connection pooling for HTTP

---

[COMPLETED: Primer 2 - Asynchronous Programming with Python]
