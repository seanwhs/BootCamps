# Appendix B: Asyncio & Concurrency Patterns

## B.1 Introduction to Asyncio

### What is Asyncio?

Asyncio is Python's built-in library for writing concurrent code using the `async`/`await` syntax. Think of it as a way to write code that can do multiple things at once without using multiple threads or processes.

### The Problem It Solves

Traditional synchronous code blocks the execution thread while waiting for I/O operations:

```python
# Synchronous - blocks while waiting
import requests

def fetch_urls():
    results = []
    for url in urls:
        response = requests.get(url)  # Blocks here!
        results.append(response.text)
    return results
```

Asynchronous code can handle multiple operations concurrently:

```python
# Asynchronous - non-blocking
import aiohttp
import asyncio

async def fetch_urls(urls):
    async with aiohttp.ClientSession() as session:
        tasks = []
        for url in urls:
            task = asyncio.create_task(session.get(url))
            tasks.append(task)
        responses = await asyncio.gather(*tasks)
        return [await r.text() for r in responses]
```

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Coroutine** | An `async def` function that can be paused and resumed |
| **Event Loop** | The core that manages and executes coroutines |
| **Task** | A wrapper for a coroutine that schedules it on the event loop |
| **Future** | A placeholder for a result that will be available later |
| **Awaitable** | Something that can be awaited (coroutine, Task, Future) |

---

## B.2 Core Asyncio Concepts

### Coroutines

```python
import asyncio

# Define a coroutine
async def my_coroutine():
    print("Starting...")
    await asyncio.sleep(1)  # Non-blocking sleep
    print("Done!")
    return "Result"

# Run a coroutine
result = asyncio.run(my_coroutine())

# Coroutine with parameters
async def greet(name, delay=1):
    await asyncio.sleep(delay)
    return f"Hello, {name}!"

# Await multiple coroutines
async def main():
    result1 = await greet("Alice", 1)
    result2 = await greet("Bob", 2)
    return result1, result2

asyncio.run(main())
```

### Tasks

```python
import asyncio

# Create a task
async def long_operation():
    await asyncio.sleep(5)
    return "Completed"

async def main():
    # Create task (starts immediately)
    task = asyncio.create_task(long_operation())
    
    # Do other work while task runs
    await asyncio.sleep(1)
    print("Still doing other work...")
    
    # Wait for task to complete
    result = await task
    print(f"Task result: {result}")

asyncio.run(main())
```

### Event Loop

```python
import asyncio

# Get the event loop
loop = asyncio.get_event_loop()

# Run until complete
loop.run_until_complete(my_coroutine())

# Run forever
loop.run_forever()

# Stop the loop
loop.stop()

# Close the loop
loop.close()

# Check if running
if loop.is_running():
    print("Loop is running")
```

---

## B.3 Async/Await Patterns

### Pattern 1: Sequential Execution

```python
async def sequential():
    result1 = await async_operation1()
    result2 = await async_operation2(result1)
    result3 = await async_operation3(result2)
    return result3
```

### Pattern 2: Concurrent Execution

```python
async def concurrent():
    # Run all tasks concurrently
    task1 = asyncio.create_task(async_operation1())
    task2 = asyncio.create_task(async_operation2())
    task3 = asyncio.create_task(async_operation3())
    
    # Wait for all to complete
    results = await asyncio.gather(task1, task2, task3)
    return results

# Alternative: gather without creating tasks
async def concurrent_gather():
    results = await asyncio.gather(
        async_operation1(),
        async_operation2(),
        async_operation3()
    )
    return results
```

### Pattern 3: Race Condition

```python
async def race():
    # Return first completed result
    result = await asyncio.wait_for(
        asyncio.gather(
            async_operation1(),
            async_operation2(),
            return_exceptions=True
        ),
        timeout=5.0
    )
    return result

# Wait for first completion
async def first_completed():
    tasks = [async_operation1(), async_operation2()]
    done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
    # Cancel remaining tasks
    for task in pending:
        task.cancel()
    return done.pop().result()
```

### Pattern 4: Producer-Consumer

```python
import asyncio
from asyncio import Queue

async def producer(queue: Queue, items: list):
    for item in items:
        await queue.put(item)
        await asyncio.sleep(0.1)
    await queue.put(None)  # Sentinel

async def consumer(queue: Queue):
    results = []
    while True:
        item = await queue.get()
        if item is None:
            break
        # Process item
        processed = await process_item(item)
        results.append(processed)
        queue.task_done()
    return results

async def main():
    queue = Queue(maxsize=10)
    
    # Start producer and consumer
    producer_task = asyncio.create_task(producer(queue, range(10)))
    consumer_task = asyncio.create_task(consumer(queue))
    
    # Wait for both
    await producer_task
    results = await consumer_task
    return results

asyncio.run(main())
```

---

## B.4 Timeouts & Cancellation

### Timeouts

```python
import asyncio

async def with_timeout():
    try:
        # Timeout after 5 seconds
        result = await asyncio.wait_for(
            long_operation(),
            timeout=5.0
        )
        return result
    except asyncio.TimeoutError:
        print("Operation timed out")
        return None

# Timeout with default
async def with_default():
    try:
        result = await asyncio.wait_for(
            long_operation(),
            timeout=5.0
        )
        return result
    except asyncio.TimeoutError:
        return "default_value"

# Check if operation completed within timeout
async def check_timeout():
    try:
        result = await asyncio.wait_for(
            long_operation(),
            timeout=5.0
        )
        return result, True
    except asyncio.TimeoutError:
        return None, False
```

### Cancellation

```python
import asyncio

async def cancellable_operation():
    try:
        while True:
            await asyncio.sleep(1)
            print("Working...")
    except asyncio.CancelledError:
        print("Cancelled!")
        # Clean up resources
        raise

async def main():
    task = asyncio.create_task(cancellable_operation())
    await asyncio.sleep(3)
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        print("Task was cancelled")

asyncio.run(main())
```

---

## B.5 Synchronization Primitives

### Locks

```python
import asyncio

lock = asyncio.Lock()

async def critical_section():
    async with lock:
        # Only one coroutine can enter here at a time
        await asyncio.sleep(1)
        print("Critical section")

async def main():
    # Only one will execute at a time
    await asyncio.gather(
        critical_section(),
        critical_section(),
        critical_section()
    )

asyncio.run(main())
```

### Semaphores

```python
import asyncio

# Allow up to 3 concurrent operations
semaphore = asyncio.Semaphore(3)

async def limited_operation(name):
    async with semaphore:
        print(f"{name} starting")
        await asyncio.sleep(1)
        print(f"{name} done")

async def main():
    await asyncio.gather(
        *[limited_operation(f"Task {i}") for i in range(10)]
    )

asyncio.run(main())
```

### Events

```python
import asyncio

event = asyncio.Event()

async def waiter():
    print("Waiting for event...")
    await event.wait()
    print("Event received!")

async def setter():
    await asyncio.sleep(2)
    print("Setting event...")
    event.set()

async def main():
    await asyncio.gather(waiter(), setter())

asyncio.run(main())
```

### Conditions

```python
import asyncio

condition = asyncio.Condition()
shared_data = []

async def producer():
    async with condition:
        for i in range(5):
            shared_data.append(i)
            print(f"Produced: {i}")
            condition.notify()
            await asyncio.sleep(0.5)

async def consumer():
    async with condition:
        while len(shared_data) < 5:
            await condition.wait()
        print(f"Consumed: {shared_data}")

async def main():
    await asyncio.gather(producer(), consumer())

asyncio.run(main())
```

---

## B.6 Threading Integration

### Running Blocking Code

```python
import asyncio
import time
import threading

# Run blocking code in thread pool
async def run_blocking():
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(
        None,  # Default executor
        time.sleep,  # Blocking function
        1
    )
    return result

# With custom executor
import concurrent.futures

executor = concurrent.futures.ThreadPoolExecutor(max_workers=5)

async def run_with_executor():
    loop = asyncio.get_event_loop()
    result = await loop.run_in_executor(
        executor,
        blocking_function,
        arg1, arg2
    )
    return result
```

### Thread-Safe Queue

```python
import asyncio
import queue
import threading

class AsyncToSync:
    def __init__(self):
        self.queue = queue.Queue()
        self.loop = asyncio.get_event_loop()
    
    def put(self, item):
        """Thread-safe put"""
        self.queue.put(item)
        # Schedule processing in event loop
        self.loop.call_soon_threadsafe(self._process_queue)
    
    async def get(self):
        """Async get"""
        while True:
            try:
                return self.queue.get_nowait()
            except queue.Empty:
                await asyncio.sleep(0.01)
```

---

## B.7 Error Handling

### Catching Exceptions

```python
import asyncio

async def risky_operation():
    raise ValueError("Something went wrong")

async def handle_errors():
    try:
        result = await risky_operation()
        return result
    except ValueError as e:
        print(f"Error: {e}")
        return None

# Handle exceptions in gather
async def gather_with_errors():
    results = await asyncio.gather(
        risky_operation(),
        asyncio.sleep(1),
        return_exceptions=True
    )
    for result in results:
        if isinstance(result, Exception):
            print(f"Task failed: {result}")
        else:
            print(f"Task succeeded: {result}")
```

### Task Groups (Python 3.11+)

```python
import asyncio

async def main():
    try:
        async with asyncio.TaskGroup() as tg:
            task1 = tg.create_task(long_operation1())
            task2 = tg.create_task(long_operation2())
            task3 = tg.create_task(long_operation3())
        
        # All tasks completed successfully
        result1 = task1.result()
        result2 = task2.result()
        result3 = task3.result()
        
    except* Exception as e:
        # Any task exception causes cancellation of all others
        print(f"Error: {e}")
```

---

## B.8 Performance Optimization

### Connection Pooling

```python
import aiohttp
import asyncio

class ConnectionPool:
    def __init__(self, limit=100):
        self.session = None
        self.connector = aiohttp.TCPConnector(limit=limit)
    
    async def get_session(self):
        if not self.session:
            self.session = aiohttp.ClientSession(connector=self.connector)
        return self.session
    
    async def close(self):
        if self.session:
            await self.session.close()
            await self.connector.close()

# Usage
pool = ConnectionPool()

async def fetch(url):
    session = await pool.get_session()
    async with session.get(url) as response:
        return await response.text()
```

### Rate Limiting

```python
import asyncio
import time

class RateLimiter:
    def __init__(self, rate, per_second=True):
        self.rate = rate
        self.per_second = per_second
        self._last_time = time.time()
        self._count = 0
        self._lock = asyncio.Lock()
    
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

# Usage
limiter = RateLimiter(rate=10)  # 10 requests per second

async def rate_limited_task():
    await limiter.acquire()
    # Do work
```

### Batching

```python
import asyncio

class BatchProcessor:
    def __init__(self, batch_size=10, flush_interval=1.0):
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.buffer = []
        self._lock = asyncio.Lock()
        self._task = None
    
    async def add(self, item):
        async with self._lock:
            self.buffer.append(item)
            if len(self.buffer) >= self.batch_size:
                await self.flush()
    
    async def flush(self):
        async with self._lock:
            if not self.buffer:
                return
            items = self.buffer.copy()
            self.buffer.clear()
            # Process batch
            await self.process_batch(items)
    
    async def start(self):
        async def periodic_flush():
            while True:
                await asyncio.sleep(self.flush_interval)
                await self.flush()
        
        self._task = asyncio.create_task(periodic_flush())
```

---

## B.9 Advanced Patterns

### Retry with Exponential Backoff

```python
import asyncio
import random

async def retry_with_backoff(
    func,
    max_retries=3,
    base_delay=1.0,
    max_delay=30.0,
    jitter=True
):
    delay = base_delay
    
    for attempt in range(max_retries):
        try:
            return await func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            
            # Calculate next delay
            if jitter:
                delay = delay * (1 + random.random())
            else:
                delay *= 2
            
            delay = min(delay, max_delay)
            
            print(f"Retry {attempt + 1}/{max_retries} in {delay:.2f}s")
            await asyncio.sleep(delay)

# Usage
async def unreliable_operation():
    if random.random() < 0.7:
        raise ValueError("Random failure")
    return "Success"

result = await retry_with_backoff(unreliable_operation)
```

### Circuit Breaker

```python
import asyncio
import time

class CircuitBreaker:
    def __init__(self, failure_threshold=3, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.state = "CLOSED"  # CLOSED, OPEN, HALF_OPEN
        self.last_failure_time = None
        self._lock = asyncio.Lock()
    
    async def call(self, func):
        async with self._lock:
            if self.state == "OPEN":
                if time.time() - self.last_failure_time > self.recovery_timeout:
                    self.state = "HALF_OPEN"
                    print("Circuit half-open: testing...")
                else:
                    raise Exception("Circuit breaker is open")
        
        try:
            result = await func()
            
            async with self._lock:
                if self.state == "HALF_OPEN":
                    print("Circuit closed: recovery successful")
                    self.state = "CLOSED"
                    self.failures = 0
                elif self.state == "CLOSED":
                    self.failures = 0
            
            return result
            
        except Exception as e:
            async with self._lock:
                if self.state in ["CLOSED", "HALF_OPEN"]:
                    self.failures += 1
                    self.last_failure_time = time.time()
                    
                    if self.failures >= self.failure_threshold:
                        self.state = "OPEN"
                        print("Circuit opened!")
            
            raise

# Usage
breaker = CircuitBreaker(failure_threshold=3)

async def main():
    for i in range(10):
        try:
            result = await breaker.call(unreliable_operation)
            print(f"Success: {result}")
        except Exception as e:
            print(f"Failed: {e}")
        await asyncio.sleep(1)
```

### Fan-Out/Fan-In Pattern

```python
import asyncio

async def fan_out_fan_in(
    tasks,
    max_concurrent=None,
    timeout=None
):
    """
    Process tasks with controlled concurrency.
    
    Args:
        tasks: List of coroutines
        max_concurrent: Max concurrent tasks
        timeout: Global timeout
    """
    semaphore = asyncio.Semaphore(max_concurrent or len(tasks))
    
    async def limited_task(coro):
        async with semaphore:
            return await coro
    
    # Create tasks with semaphore
    task_list = [asyncio.create_task(limited_task(task)) for task in tasks]
    
    # Wait for all with timeout
    if timeout:
        try:
            results = await asyncio.wait_for(
                asyncio.gather(*task_list, return_exceptions=True),
                timeout=timeout
            )
        except asyncio.TimeoutError:
            # Cancel remaining tasks
            for task in task_list:
                if not task.done():
                    task.cancel()
            raise
    else:
        results = await asyncio.gather(*task_list, return_exceptions=True)
    
    # Process results
    success_results = []
    errors = []
    
    for result in results:
        if isinstance(result, Exception):
            errors.append(result)
        else:
            success_results.append(result)
    
    return success_results, errors
```

---

## B.10 Common Pitfalls & Best Practices

### Pitfall 1: Forgetting to Await

```python
# WRONG - doesn't execute the coroutine
async def main():
    coroutine = my_coroutine()  # Returns coroutine object
    # coroutine never runs!

# CORRECT
async def main():
    result = await my_coroutine()
```

### Pitfall 2: Mixing Sync and Async Code

```python
import asyncio

# WRONG - blocks the event loop
async def main():
    time.sleep(1)  # Blocks!
    await asyncio.sleep(1)  # Non-blocking

# CORRECT - use asyncio.sleep
async def main():
    await asyncio.sleep(1)

# CORRECT - run blocking code in executor
async def main():
    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, time.sleep, 1)
```

### Pitfall 3: Not Using Timeouts

```python
# WRONG - could hang forever
async def main():
    result = await slow_operation()

# CORRECT - with timeout
async def main():
    try:
        result = await asyncio.wait_for(
            slow_operation(),
            timeout=5.0
        )
    except asyncio.TimeoutError:
        result = None
```

### Pitfall 4: Resource Leaks

```python
# WRONG - resource leak
async def main():
    session = aiohttp.ClientSession()
    async with session.get(url) as response:
        return await response.text()
    # Session not closed!

# CORRECT - use context manager
async def main():
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            return await response.text()

# CORRECT - manual cleanup
async def main():
    session = aiohttp.ClientSession()
    try:
        async with session.get(url) as response:
            return await response.text()
    finally:
        await session.close()
```

### Best Practices Checklist

- [ ] Always await coroutines
- [ ] Use `asyncio.run()` for top-level entry
- [ ] Set appropriate timeouts
- [ ] Use context managers for resources
- [ ] Handle exceptions properly
- [ ] Cancel tasks when no longer needed
- [ ] Use semaphores for rate limiting
- [ ] Monitor task count and memory usage
- [ ] Test with `pytest-asyncio`
- [ ] Use type hints for async functions

---

## B.11 Testing Async Code

### Using pytest-asyncio

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_async_function():
    result = await my_async_function()
    assert result == expected

# Testing timeouts
@pytest.mark.asyncio
async def test_timeout():
    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(
            slow_operation(),
            timeout=0.1
        )

# Testing with fixtures
@pytest.fixture
async def client():
    async with aiohttp.ClientSession() as session:
        yield session

@pytest.mark.asyncio
async def test_with_fixture(client):
    async with client.get(url) as response:
        assert response.status == 200
```

### Mocking

```python
from unittest.mock import AsyncMock, patch

async def test_with_mock():
    mock = AsyncMock(return_value="mocked result")
    result = await mock()
    assert result == "mocked result"
    mock.assert_awaited_once()

@patch('module.external_api', new_callable=AsyncMock)
async def test_with_patch(mock_api):
    mock_api.return_value = "test data"
    result = await my_function()
    assert result == "test data"
```

---

## B.12 Performance Monitoring

### Measuring Performance

```python
import asyncio
import time

async def measure_time(coro, *args, **kwargs):
    start = time.perf_counter()
    result = await coro(*args, **kwargs)
    elapsed = time.perf_counter() - start
    return result, elapsed

# Usage
result, elapsed = await measure_time(my_coroutine)
print(f"Completed in {elapsed:.3f}s")
```

### Profiling

```python
import asyncio
import cProfile
import pstats

async def profile_async(coro, *args, **kwargs):
    profiler = cProfile.Profile()
    profiler.enable()
    result = await coro(*args, **kwargs)
    profiler.disable()
    
    stats = pstats.Stats(profiler)
    stats.sort_stats('cumtime')
    stats.print_stats(10)
    
    return result

# Usage
result = asyncio.run(profile_async(my_coroutine))
```

---

## B.13 Quick Reference

### Common Async Functions

| Function | Purpose |
|----------|---------|
| `asyncio.run(coro)` | Run a coroutine until complete |
| `asyncio.create_task(coro)` | Schedule a task on the event loop |
| `asyncio.gather(*coros)` | Run multiple coroutines concurrently |
| `asyncio.wait(tasks)` | Wait for tasks with conditions |
| `asyncio.wait_for(coro, timeout)` | Wait with timeout |
| `asyncio.sleep(seconds)` | Non-blocking sleep |
| `asyncio.shield(coro)` | Protect from cancellation |
| `asyncio.current_task()` | Get current task |
| `asyncio.all_tasks()` | Get all tasks |

### Common Awaitable Types

| Type | Description |
|------|-------------|
| `Coroutine` | `async def` function result |
| `Task` | Wrapped coroutine scheduled on loop |
| `Future` | Container for a result |
| `asyncio.Queue.get()` | Get item from queue |
| `asyncio.Lock.acquire()` | Acquire lock |
| `asyncio.Event.wait()` | Wait for event |

### Async Context Managers

```python
# Custom async context manager
class AsyncContext:
    async def __aenter__(self):
        await self.setup()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.cleanup()

# Usage
async with AsyncContext() as context:
    await context.do_work()
```

### Async Iterators

```python
class AsyncIterator:
    def __init__(self, data):
        self.data = data
        self.index = 0
    
    def __aiter__(self):
        return self
    
    async def __anext__(self):
        if self.index >= len(self.data):
            raise StopAsyncIteration
        await asyncio.sleep(0.1)
        value = self.data[self.index]
        self.index += 1
        return value

# Usage
async for item in AsyncIterator(range(10)):
    print(item)
```

---

```
[COMPLETED: Appendix B - Asyncio & Concurrency Patterns]
```

**Next Appendix:** [Appendix C - Security Best Practices] (Available on request)

---

## Series Completion

You've now completed the entire **"Python for Hackers — Advanced Engineering & Defensive Architecture"** series including:

- **Part 0:** Introduction
- **Part 1:** Infrastructure Automation & Protocol Analysis
- **Part 2:** High-Speed Packet Sniffing & Asynchronous Integration
- **Part 3:** Stealth Reconnaissance & Asynchronous Tooling
- **Part 4:** Advanced Tooling Design, Obfuscation & Hardening
- **Appendix A:** Scapy Deep Dive
- **Appendix B:** Asyncio & Concurrency Patterns

### What You've Built

A complete, production-ready offensive security framework called **PyHack Suite** with:

- ✅ Unified connection management
- ✅ High-performance packet sniffing
- ✅ Stealth reconnaissance tools
- ✅ Plugin-based architecture
- ✅ Code obfuscation capabilities
- ✅ Security hardening
- ✅ Professional CLI
- ✅ Comprehensive documentation

### Key Takeaways

1. **Think like a defender** - Understanding attacks makes you a better defender
2. **Use async for networking** - Concurrent I/O is essential for performance
3. **Build modular systems** - Plugins enable rapid capability expansion
4. **Practice defense in depth** - Multiple layers of security
5. **Test everything** - Verification ensures reliability
6. **Document as you go** - Good documentation is invaluable

### Next Steps

- **Deploy** - Use the framework in authorized testing
- **Extend** - Write your own plugins and modules
- **Share** - Contribute to the community
- **Learn** - Explore advanced topics in security

### Final Note

> **"The best way to predict the future is to create it."** - Peter Drucker

You now have the tools and knowledge to create powerful security tools. Use them wisely, ethically, and responsibly.

---

**[END OF APPENDIX B]**
