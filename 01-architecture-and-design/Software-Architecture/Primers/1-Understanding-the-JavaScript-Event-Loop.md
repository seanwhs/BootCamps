# Primer 1: Understanding the JavaScript Event Loop

## A Deep Dive into JavaScript's Runtime Model

Welcome to the first primer! This is a comprehensive deep dive into the JavaScript event loop - the fundamental concept that powers all asynchronous JavaScript. Understanding this is like understanding the heartbeat of your application.

### 1. The Big Picture

Before we dive into the details, let's understand the complete picture of how JavaScript executes code.

#### The JavaScript Runtime Environment

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    JAVASCRIPT RUNTIME ENVIRONMENT                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         JAVASCRIPT ENGINE                          │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │   │
│  │  │   Memory Heap   │    │   Call Stack    │    │   Task Queue    │  │   │
│  │  │  (Objects,      │    │  (Functions     │    │  (Callbacks,    │  │   │
│  │  │   Functions,    │    │   being         │    │   Events,       │  │   │
│  │  │   Variables)    │    │   executed)     │    │   Promises)     │  │   │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────┘  │   │
│  │          ▲                      ▲                      ▲            │   │
│  │          │                      │                      │            │   │
│  │          ▼                      ▼                      ▼            │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    EVENT LOOP                              │   │   │
│  │  │  (Coordinates between call stack and task queue)          │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        LIBUV (C++ Library)                         │   │
│  │                                                                     │   │
│  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │   │
│  │  │   Thread Pool   │    │   Event         │    │   Async Work    │  │   │
│  │  │  (File I/O,     │    │   Demultiplexer │    │   (DNS, Crypto, │  │   │
│  │  │   DNS, Crypto)  │    │   (epoll/kqueue)│    │    FS, etc.)    │  │   │
│  │  └─────────────────┘    └─────────────────┘    └─────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. The Call Stack

The call stack is a LIFO (Last In, First Out) data structure that tracks function execution.

#### How the Call Stack Works

```javascript
// Example 1: Simple function calls
function multiply(a, b) {
    return a * b;
}

function square(n) {
    return multiply(n, n);
}

function printSquare(n) {
    const squared = square(n);
    console.log(squared);
}

printSquare(5);

// Call stack visualization:
// 1. [global]
// 2. [global, printSquare]
// 3. [global, printSquare, square]
// 4. [global, printSquare, square, multiply]
// 5. [global, printSquare, square] (multiply returns)
// 6. [global, printSquare] (square returns)
// 7. [global] (printSquare returns)
```

#### Stack Overflow

```javascript
// ❌ BAD: Recursion without base case
function infiniteRecursion() {
    return infiniteRecursion();
}
// RangeError: Maximum call stack size exceeded

// ✅ GOOD: Recursion with base case
function factorial(n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
```

### 3. The Event Loop in Detail

The event loop is the orchestrator that manages asynchronous operations.

#### Event Loop Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EVENT LOOP PHASES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        PHASE 1: TIMERS                             │   │
│  │  • Executes callbacks from setTimeout() and setInterval()          │   │
│  │  • Callbacks are executed in order of their scheduled time        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    PHASE 2: PENDING CALLBACKS                      │   │
│  │  • Executes I/O callbacks that were deferred                       │   │
│  │  • System-level callbacks (e.g., TCP errors)                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     PHASE 3: IDLE, PREPARE                         │   │
│  │  • Internal use only                                               │   │
│  │  • Used by Libuv for internal operations                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    PHASE 4: POLL (I/O)                             │   │
│  │  • Retrieves new I/O events                                        │   │
│  │  • Executes I/O callbacks                                          │   │
│  │  • Most time is spent here                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    PHASE 5: CHECK                                  │   │
│  │  • Executes setImmediate() callbacks                               │   │
│  │  • These run after I/O events                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                  PHASE 6: CLOSE CALLBACKS                          │   │
│  │  • Executes close event callbacks                                  │   │
│  │  • e.g., socket.on('close', ...)                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Microtasks vs Macrotasks

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MICROTASKS vs MACROTASKS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      MACROTASKS                                     │   │
│  │  • setTimeout, setInterval, setImmediate                           │   │
│  │  • I/O operations                                                  │   │
│  │  • UI rendering                                                    │   │
│  │  • Executed in event loop phases                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      MICROTASKS                                     │   │
│  │  • Promise.then, catch, finally                                    │   │
│  │  • process.nextTick (Node.js)                                      │   │
│  │  • queueMicrotask                                                  │   │
│  │  • Executed immediately after each macrotask                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  EXECUTION ORDER:                                                           │
│  1. Execute all microtasks in the queue                                     │
│  2. Execute one macrotask                                                   │
│  3. Repeat                                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4. Async Patterns Explained

#### Callbacks (Traditional)

```javascript
// Callback hell - the pyramid of doom
fs.readFile('file1.txt', (err, data1) => {
    if (err) throw err;
    fs.readFile('file2.txt', (err, data2) => {
        if (err) throw err;
        fs.readFile('file3.txt', (err, data3) => {
            if (err) throw err;
            // Process all data
            console.log(data1, data2, data3);
        });
    });
});
```

#### Promises (Better)

```javascript
// Promise chaining - flatter
fs.promises.readFile('file1.txt')
    .then(data1 => {
        return fs.promises.readFile('file2.txt')
            .then(data2 => [data1, data2]);
    })
    .then(([data1, data2]) => {
        return fs.promises.readFile('file3.txt')
            .then(data3 => [data1, data2, data3]);
    })
    .then(([data1, data2, data3]) => {
        console.log(data1, data2, data3);
    })
    .catch(err => console.error(err));
```

#### Async/Await (Best)

```javascript
// Async/await - synchronous-looking
async function readFiles() {
    try {
        const data1 = await fs.promises.readFile('file1.txt');
        const data2 = await fs.promises.readFile('file2.txt');
        const data3 = await fs.promises.readFile('file3.txt');
        console.log(data1, data2, data3);
    } catch (err) {
        console.error(err);
    }
}
```

### 5. Common Pitfalls and Solutions

#### Blocking the Event Loop

```javascript
// ❌ BAD: This blocks the event loop
function heavyComputation() {
    let sum = 0;
    for (let i = 0; i < 1e9; i++) {
        sum += i;
    }
    return sum;
}

// ✅ GOOD: Use setImmediate to yield
function heavyComputationBatch(callback) {
    let sum = 0;
    const batchSize = 100000;
    let i = 0;
    
    function processBatch() {
        for (let j = 0; j < batchSize && i < 1e9; j++, i++) {
            sum += i;
        }
        if (i < 1e9) {
            setImmediate(processBatch);
        } else {
            callback(sum);
        }
    }
    processBatch();
}

// ✅ GOOD: Use worker threads
const { Worker } = require('worker_threads');

function heavyComputationWorker() {
    return new Promise((resolve) => {
        const worker = new Worker(`
            const { parentPort } = require('worker_threads');
            let sum = 0;
            for (let i = 0; i < 1e9; i++) {
                sum += i;
            }
            parentPort.postMessage(sum);
        `, { eval: true });
        worker.on('message', resolve);
    });
}
```

#### Promise Resolution Order

```javascript
// ❌ BAD: Not understanding microtask order
console.log('1');

setTimeout(() => console.log('2'), 0);

Promise.resolve()
    .then(() => console.log('3'))
    .then(() => console.log('4'));

console.log('5');

// Output: 1, 5, 3, 4, 2
// Explanation:
// 1. console.log('1') - Synchronous
// 2. setTimeout - Macrotask (queued)
// 3. Promise.then - Microtask (queued)
// 4. console.log('5') - Synchronous
// 5. Microtasks run: 3, 4
// 6. Macrotasks run: 2

// ✅ GOOD: Understanding the order
// Use queueMicrotask for microtasks
// Use setImmediate for immediate macrotasks
```

#### Memory Leaks with Async Code

```javascript
// ❌ BAD: Not cleaning up
async function processFile(filePath) {
    const fileStream = fs.createReadStream(filePath);
    // Stream stays open, causing memory leak
}

// ✅ GOOD: Clean up resources
async function processFile(filePath) {
    const fileStream = fs.createReadStream(filePath);
    try {
        // Process stream
    } finally {
        fileStream.destroy();
    }
}

// ❌ BAD: Infinite loop with async
async function pollData() {
    while (true) {
        const data = await fetchData();
        // Never stops, prevents garbage collection
    }
}

// ✅ GOOD: Controlled polling
let polling = true;
async function pollData() {
    while (polling) {
        const data = await fetchData();
        // Process data
        await new Promise(resolve => setTimeout(resolve, 1000));
    }
}
```

### 6. Performance Optimizations

#### Microtask Optimization

```javascript
// ❌ BAD: Too many microtasks
async function processItems(items) {
    for (const item of items) {
        await processItem(item); // Creates a new microtask for each item
    }
}

// ✅ GOOD: Batch processing
async function processItems(items) {
    const batches = chunk(items, 100);
    for (const batch of batches) {
        await Promise.all(batch.map(processItem)); // One microtask per batch
    }
}
```

#### Event Loop Utilization

```javascript
// Monitor event loop health
const eventLoopLag = require('event-loop-lag')();

setInterval(() => {
    const lag = eventLoopLag();
    if (lag > 50) {
        console.warn(`Event loop lag: ${lag}ms`);
    }
}, 1000);

// Detect and fix blocking
const { performance } = require('perf_hooks');

function measureEventLoopBlocking(fn) {
    const start = performance.now();
    fn();
    const end = performance.now();
    if (end - start > 100) {
        console.warn(`Blocking operation detected: ${end - start}ms`);
    }
}
```

### 7. Visualizing the Event Loop

```javascript
// Demo: Visualize event loop phases
function demoEventLoop() {
    console.log('1. Start');

    setTimeout(() => {
        console.log('2. setTimeout (Timer Phase)');
    }, 0);

    setImmediate(() => {
        console.log('3. setImmediate (Check Phase)');
    });

    Promise.resolve()
        .then(() => {
            console.log('4. Promise (Microtask)');
        });

    process.nextTick(() => {
        console.log('5. process.nextTick (Microtask - Highest Priority)');
    });

    fs.readFile(__filename, () => {
        console.log('6. fs.readFile (Poll Phase)');
    });

    console.log('7. End');

    // Output order:
    // 1. Start
    // 7. End
    // 5. process.nextTick
    // 4. Promise
    // 2. setTimeout (or 3, depending on timing)
    // 3. setImmediate (or 2)
    // 6. fs.readFile
}

// Understanding the output:
// 1. Synchronous code runs first (1, 7)
// 2. Microtasks run (process.nextTick, Promise)
// 3. Macrotasks run (setTimeout, setImmediate, I/O)
//    - setImmediate and setTimeout order depends on when the loop starts
//    - I/O callbacks run in the poll phase
```

### 8. Best Practices

#### Always Handle Errors

```javascript
// ❌ BAD: Unhandled promise rejection
async function riskyOperation() {
    const data = await fetchData(); // Could reject
    // Error goes unhandled
}

// ✅ GOOD: Always handle errors
async function safeOperation() {
    try {
        const data = await fetchData();
        return data;
    } catch (error) {
        console.error('Operation failed:', error);
        // Either rethrow or return a safe default
        return null;
    }
}

// ✅ GOOD: Global error handlers
process.on('unhandledRejection', (error) => {
    console.error('Unhandled rejection:', error);
});

process.on('uncaughtException', (error) => {
    console.error('Uncaught exception:', error);
    process.exit(1); // Clean exit
});
```

#### Use Async/Await Over Callbacks

```javascript
// ❌ BAD: Nested callbacks
fs.readFile('a.txt', (err, a) => {
    fs.readFile('b.txt', (err, b) => {
        fs.readFile('c.txt', (err, c) => {
            console.log(a, b, c);
        });
    });
});

// ✅ GOOD: Async/await
async function readFiles() {
    const [a, b, c] = await Promise.all([
        fs.promises.readFile('a.txt'),
        fs.promises.readFile('b.txt'),
        fs.promises.readFile('c.txt'),
    ]);
    console.log(a, b, c);
}
```

### 9. Key Takeaways

1. **JavaScript is Single-Threaded:** It has one call stack, but can handle concurrency through the event loop.

2. **Non-Blocking I/O:** The event loop allows JavaScript to perform I/O operations without blocking the main thread.

3. **Microtasks vs Macrotasks:** Microtasks (Promises, process.nextTick) run before macrotasks (setTimeout, setImmediate).

4. **Don't Block the Event Loop:** Long-running synchronous operations will block everything.

5. **Use Worker Threads for CPU-Intensive Work:** Offload heavy computation to worker threads.

6. **Always Handle Async Errors:** Unhandled rejections can crash your application.

---

This primer provides a comprehensive understanding of the JavaScript event loop. It's the foundation for understanding how Node.js handles concurrency and why certain patterns are more efficient than others.
