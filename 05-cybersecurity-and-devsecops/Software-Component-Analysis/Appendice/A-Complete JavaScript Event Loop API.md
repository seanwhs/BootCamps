# Reference A: Complete JavaScript Event Loop API

Welcome to the first reference section of our tutorial series. This deep dive covers the complete JavaScript Event Loop API with visual diagrams, detailed explanations, and practical examples. Use this reference when you need to understand the exact behavior of asynchronous operations in Node.js and the browser.

---

## The Event Loop: A Visual Journey

### The Big Picture

```
┌───────────────────────────────┐
│   ┌─────────────────────┐     │
│   │    MICROTASK QUEUE   │     │
│   │  ┌─────────────────┐ │     │
│   │  │ process.nextTick │ │     │
│   │  │ Promise.then     │ │     │
│   │  │ queueMicrotask   │ │     │
│   │  └─────────────────┘ │     │
│   └─────────────────────┘     │
│               ↓                │
│   ┌─────────────────────┐     │
│   │    MACROTASK QUEUE   │     │
│   │  ┌─────────────────┐ │     │
│   │  │ setTimeout      │ │     │
│   │  │ setInterval     │ │     │
│   │  │ I/O Operations  │ │     │
│   │  │ setImmediate    │ │     │
│   │  └─────────────────┘ │     │
│   └─────────────────────┘     │
│               ↓                │
│   ┌─────────────────────┐     │
│   │    CALL STACK       │     │
│   │  ┌─────────────────┐ │     │
│   │  │ Function F      │ │     │
│   │  │ Function E      │ │     │
│   │  │ Function D      │ │     │
│   │  └─────────────────┘ │     │
│   └─────────────────────┘     │
└───────────────────────────────┘
```

### Node.js Event Loop Phases

```
   ┌───────────────────────────┐
┌─>│           timers          │
│  │  setTimeout, setInterval  │
│  └──────────┬────────────────┘
│  ┌──────────┴────────────────┐
│  │     pending callbacks     │
│  │  I/O callbacks deferred   │
│  └──────────┬────────────────┘
│  ┌──────────┴────────────────┐
│  │     idle, prepare         │
│  │  internal use only        │
│  └──────────┬────────────────┘
│  ┌──────────┴────────────────┐
│  │           poll            │
│  │  retrieve new I/O events  │
│  └──────────┬────────────────┘
│  ┌──────────┴────────────────┐
│  │           check           │
│  │     setImmediate          │
│  └──────────┬────────────────┘
│  ┌──────────┴────────────────┐
└──┤      close callbacks      │
   │  socket.on('close', ...)  │
   └───────────────────────────┘
```

---

## Complete API Reference

### 1. setTimeout and setInterval

**setTimeout(callback, delay, ...args)**

Schedules a callback to be executed after a minimum delay in milliseconds.

```javascript
// Basic usage
setTimeout(() => {
    console.log('Executed after ~1000ms');
}, 1000);

// With arguments
setTimeout((name, age) => {
    console.log(`Hello ${name}, you are ${age} years old`);
}, 1000, 'Alice', 30);

// Returns a Timeout object for cancellation
const timeout = setTimeout(() => {
    console.log('This will not run');
}, 1000);
clearTimeout(timeout);

// ⚠️ Important: setTimeout 0ms is NOT guaranteed to execute immediately
setTimeout(() => {
    console.log('This runs after all microtasks');
}, 0);

// 💡 Pro Tip: Use for yielding control to the event loop
function processLargeArray(array) {
    let index = 0;
    function processChunk() {
        const chunkSize = 100;
        const end = Math.min(index + chunkSize, array.length);
        
        for (let i = index; i < end; i++) {
            // Process array item
            console.log(array[i]);
        }
        
        index = end;
        
        if (index < array.length) {
            setTimeout(processChunk, 0); // Yield to event loop
        }
    }
    processChunk();
}
```

**setInterval(callback, delay, ...args)**

Schedules a callback to be executed repeatedly at a specified interval.

```javascript
// Basic usage
const interval = setInterval(() => {
    console.log('Runs every 1000ms');
}, 1000);

// Cancellation
clearInterval(interval);

// ⚠️ Important: Intervals are not guaranteed to be exact
// They can be delayed by long-running operations
let counter = 0;
setInterval(() => {
    counter++;
    console.log(`Tick ${counter} - Actual: ${Date.now()}`);
}, 1000);
// Due to event loop delays, ticks may drift

// 💡 Pro Tip: Use recursive setTimeout for more reliable timing
function reliableInterval(callback, delay) {
    let expected = Date.now() + delay;
    
    function step() {
        const drift = Date.now() - expected;
        callback();
        expected += delay;
        setTimeout(step, Math.max(0, delay - drift));
    }
    setTimeout(step, delay);
}
```

### 2. setImmediate and process.nextTick

**setImmediate(callback, ...args)**

Schedules a callback to be executed in the "check" phase of the event loop.

```javascript
// Basic usage
setImmediate(() => {
    console.log('Executed in check phase');
});

// With arguments
setImmediate((name) => {
    console.log(`Hello ${name}`);
}, 'Bob');

// ⚠️ Important: setImmediate vs setTimeout(0)
setImmediate(() => {
    console.log('setImmediate runs in check phase');
});

setTimeout(() => {
    console.log('setTimeout(0) runs in timer phase');
}, 0);

// The order depends on when the code is executed
// In the main module, setTimeout(0) usually runs first
// In the poll phase, setImmediate runs first

// 💡 Pro Tip: Use setImmediate for I/O operations
const fs = require('fs');
fs.readFile('file.txt', () => {
    // This callback is in the poll phase
    setImmediate(() => {
        console.log('Runs immediately after I/O');
    });
});
```

**process.nextTick(callback, ...args)**

Schedules a callback to be executed on the next tick of the event loop, **before any I/O or timers**.

```javascript
// Basic usage
process.nextTick(() => {
    console.log('Executed on next tick');
});

// With arguments
process.nextTick((name) => {
    console.log(`Hello ${name}`);
}, 'Charlie');

// ⚠️ Important: process.nextTick has the HIGHEST priority
// It runs before ANY other asynchronous operations
console.log('1. Synchronous');
setTimeout(() => console.log('4. setTimeout'), 0);
Promise.resolve().then(() => console.log('3. Promise'));
process.nextTick(() => console.log('2. nextTick'));
// Output: 1, 2, 3, 4

// 💡 Pro Tip: Use for handling errors in callbacks
function asyncOperation(callback) {
    // Run operation
    const result = someOperation();
    if (result.error) {
        // Schedule error callback on next tick
        process.nextTick(() => callback(result.error));
        return;
    }
    process.nextTick(() => callback(null, result.data));
}

// ⚠️ WARNING: process.nextTick recursion can block the event loop
function recursiveNextTick(count) {
    if (count > 0) {
        process.nextTick(() => recursiveNextTick(count - 1));
    }
}
// This will starve the event loop if count is large
```

### 3. queueMicrotask

**queueMicrotask(callback)**

Schedules a callback to be executed as a microtask (similar to Promise.then).

```javascript
// Basic usage
queueMicrotask(() => {
    console.log('Executed as microtask');
});

// ⚠️ Important: queueMicrotask runs in the microtask queue
console.log('1. Synchronous');
Promise.resolve().then(() => console.log('3. Promise'));
queueMicrotask(() => console.log('4. queueMicrotask'));
setTimeout(() => console.log('5. setTimeout'), 0);
process.nextTick(() => console.log('2. nextTick'));
// Output: 1, 2, 3, 4, 5

// 💡 Pro Tip: Use queueMicrotask for scheduling cleanups
function createResource() {
    const resource = new Resource();
    let isCleanedUp = false;
    
    return {
        use: (callback) => {
            if (isCleanedUp) throw new Error('Resource cleaned up');
            return callback(resource);
        },
        cleanup: () => {
            if (!isCleanedUp) {
                isCleanedUp = true;
                queueMicrotask(() => {
                    resource.dispose();
                });
            }
        }
    };
}
```

### 4. Promises

**Promise.resolve(value)**

Creates a resolved promise, which schedules a microtask.

```javascript
// Basic usage
Promise.resolve('Hello')
    .then(value => console.log(value));

// ⚠️ Important: Promise.then schedules a microtask
console.log('1. Synchronous');
Promise.resolve().then(() => console.log('2. Microtask'));
console.log('3. Synchronous');
// Output: 1, 3, 2

// 💡 Pro Tip: Use Promise.resolve for consistent async behavior
function asyncFunction(value) {
    return Promise.resolve(value);
}

// Chaining multiple promises
Promise.resolve()
    .then(() => console.log('First microtask'))
    .then(() => console.log('Second microtask'));
// All microtasks execute before any macrotasks
```

**Promise.reject(reason)**

Creates a rejected promise, which schedules a microtask for the catch handler.

```javascript
// Basic usage
Promise.reject('Error')
    .catch(error => console.log('Caught:', error));

// ⚠️ Important: Rejected promises still schedule microtasks
Promise.reject('Error')
    .then(() => console.log('This runs'))
    .catch(() => console.log('This runs after microtask'));
```

**Promise.all(iterable)**

Waits for all promises to resolve, scheduling microtasks for each.

```javascript
// Basic usage
const promises = [
    Promise.resolve(1),
    Promise.resolve(2),
    Promise.resolve(3)
];

Promise.all(promises)
    .then(results => console.log(results)); // [1, 2, 3]

// 💡 Pro Tip: Use for parallel operations
async function parallelTasks() {
    const [result1, result2] = await Promise.all([
        fetchData1(),
        fetchData2()
    ]);
    return { result1, result2 };
}
```

### 5. Async/Await

**async function**

Declares an asynchronous function that returns a promise.

```javascript
// Basic usage
async function fetchData() {
    return 'Data';
}
fetchData().then(data => console.log(data));

// ⚠️ Important: async functions schedule microtasks
console.log('1. Synchronous');
async function test() {
    console.log('3. Inside async');
    return '4. Result';
}
test().then(result => console.log(result));
console.log('2. Synchronous');
// Output: 1, 2, 3, 4

// 💡 Pro Tip: await schedules a microtask
async function awaitExample() {
    console.log('1. Before await');
    await Promise.resolve();
    console.log('3. After await');
}
console.log('2. After function call');
```

**await expression**

Pauses execution until the promise resolves, scheduling a microtask.

```javascript
// Basic usage
async function example() {
    const result = await Promise.resolve('Hello');
    console.log(result);
}

// ⚠️ Important: await yields control to the event loop
async function fetchSequential() {
    console.log('1. Starting');
    const data1 = await fetchData1(); // Yields here
    console.log('2. Data1 received');
    const data2 = await fetchData2(); // Yields here
    console.log('3. Data2 received');
}

// 💡 Pro Tip: Use await in loops for serial execution
async function processItems(items) {
    const results = [];
    for (const item of items) {
        // Each iteration yields to the event loop
        const result = await processItem(item);
        results.push(result);
    }
    return results;
}
```

### 6. Event Loop Internals

**Understanding the Microtask Queue**

```javascript
// Visualizing microtask execution
console.log('🟢 Main script start');

// Microtask 1
Promise.resolve().then(() => {
    console.log('🟡 Microtask 1');
});

// Microtask 2
queueMicrotask(() => {
    console.log('🟡 Microtask 2');
});

// process.nextTick (highest priority microtask)
process.nextTick(() => {
    console.log('🟠 nextTick (highest priority)');
});

// Macrotask
setTimeout(() => {
    console.log('🔴 Macrotask (setTimeout)');
});

console.log('🟢 Main script end');

// Execution Order:
// 1. Synchronous code (Main script)
// 2. process.nextTick
// 3. Microtasks (Promises, queueMicrotask)
// 4. Macrotasks (setTimeout)
```

**Understanding the Event Loop Phases**

```javascript
const fs = require('fs');

// Timers phase
setTimeout(() => {
    console.log('1. Timer');
}, 0);

// I/O callbacks phase
fs.readFile('file.txt', () => {
    console.log('2. I/O callback');
});

// Idle/Prepare phase (internal)

// Poll phase (I/O events)
// This is where file reading happens

// Check phase
setImmediate(() => {
    console.log('3. Check (setImmediate)');
});

// Close callbacks phase
// socket.on('close', ...)

// ⚠️ Important: The order of setTimeout vs setImmediate
// depends on the execution context
```

---

## Practical Patterns and Anti-Patterns

### Pattern 1: Throttling with setTimeout

```javascript
function throttle(func, delay) {
    let timeoutId = null;
    let lastArgs = null;
    let lastThis = null;
    
    return function(...args) {
        if (timeoutId) {
            // Store for later execution
            lastArgs = args;
            lastThis = this;
            return;
        }
        
        // Execute immediately
        func.apply(this, args);
        
        // Schedule next execution
        timeoutId = setTimeout(() => {
            timeoutId = null;
            
            if (lastArgs) {
                // Execute stored call
                func.apply(lastThis, lastArgs);
                lastArgs = null;
                lastThis = null;
            }
        }, delay);
    };
}

// Usage
const throttledLog = throttle((message) => {
    console.log(message);
}, 1000);

throttledLog('Call 1'); // Executes immediately
throttledLog('Call 2'); // Throttled
throttledLog('Call 3'); // Throttled
// After 1 second, the last call executes
```

### Pattern 2: Debouncing with setTimeout

```javascript
function debounce(func, delay) {
    let timeoutId = null;
    
    return function(...args) {
        // Clear previous timeout
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
        
        // Schedule new execution
        timeoutId = setTimeout(() => {
            func.apply(this, args);
            timeoutId = null;
        }, delay);
    };
}

// Usage
const debouncedSearch = debounce((query) => {
    console.log('Searching for:', query);
}, 500);

debouncedSearch('a');
debouncedSearch('ab');
debouncedSearch('abc');
// Only 'abc' executes after 500ms
```

### Pattern 3: Rate Limiting with setInterval

```javascript
class RateLimiter {
    constructor(limit, windowMs) {
        this.limit = limit;
        this.windowMs = windowMs;
        this.tokens = limit;
        this.lastRefill = Date.now();
    }
    
    async acquire() {
        return new Promise((resolve) => {
            const tryAcquire = () => {
                // Refill tokens
                const now = Date.now();
                const timePassed = now - this.lastRefill;
                const tokensToAdd = Math.floor(timePassed / this.windowMs);
                
                if (tokensToAdd > 0) {
                    this.tokens = Math.min(this.limit, this.tokens + tokensToAdd);
                    this.lastRefill = now;
                }
                
                if (this.tokens > 0) {
                    this.tokens--;
                    resolve();
                } else {
                    // Wait for next token
                    const waitTime = this.windowMs - (now - this.lastRefill);
                    setTimeout(tryAcquire, waitTime);
                }
            };
            
            tryAcquire();
        });
    }
}

// Usage
const limiter = new RateLimiter(5, 1000); // 5 requests per second

async function makeRequest(data) {
    await limiter.acquire();
    return fetch('/api', { method: 'POST', body: JSON.stringify(data) });
}
```

### Pattern 4: Promise Timeout with AbortController

```javascript
function promiseTimeout(promise, timeoutMs) {
    return new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
            reject(new Error(`Promise timed out after ${timeoutMs}ms`));
        }, timeoutMs);
        
        promise
            .then(result => {
                clearTimeout(timeoutId);
                resolve(result);
            })
            .catch(error => {
                clearTimeout(timeoutId);
                reject(error);
            });
    });
}

// With AbortController
function promiseWithTimeout(promise, timeoutMs, abortSignal) {
    return new Promise((resolve, reject) => {
        const timeoutId = setTimeout(() => {
            reject(new Error(`Promise timed out after ${timeoutMs}ms`));
        }, timeoutMs);
        
        const abortHandler = () => {
            clearTimeout(timeoutId);
            reject(new Error('Aborted'));
        };
        
        if (abortSignal) {
            abortSignal.addEventListener('abort', abortHandler);
        }
        
        promise
            .then(result => {
                clearTimeout(timeoutId);
                if (abortSignal) {
                    abortSignal.removeEventListener('abort', abortHandler);
                }
                resolve(result);
            })
            .catch(error => {
                clearTimeout(timeoutId);
                if (abortSignal) {
                    abortSignal.removeEventListener('abort', abortHandler);
                }
                reject(error);
            });
    });
}

// Usage
const controller = new AbortController();
const result = await promiseWithTimeout(
    fetchData(),
    5000,
    controller.signal
);
```

---

## Event Loop Debugging

### Monitoring Event Loop Delay

```javascript
function monitorEventLoopDelay(intervalMs = 1000) {
    let lastCheck = Date.now();
    
    setInterval(() => {
        const now = Date.now();
        const delay = now - lastCheck - intervalMs;
        lastCheck = now;
        
        if (delay > 10) {
            console.warn(`Event loop delayed by ${delay}ms`);
        }
    }, intervalMs);
}

// Advanced monitoring
class EventLoopMonitor {
    constructor() {
        this.delays = [];
        this.maxDelays = 100;
    }
    
    start(intervalMs = 1000) {
        let lastCheck = Date.now();
        
        this.interval = setInterval(() => {
            const now = Date.now();
            const delay = now - lastCheck - intervalMs;
            lastCheck = now;
            
            this.delays.push(delay);
            if (this.delays.length > this.maxDelays) {
                this.delays.shift();
            }
            
            if (delay > 100) {
                console.warn(`⚠️ Event loop blocked for ${delay}ms`);
            }
        }, intervalMs);
    }
    
    stop() {
        if (this.interval) {
            clearInterval(this.interval);
            this.interval = null;
        }
    }
    
    getStats() {
        const sorted = [...this.delays].sort((a, b) => a - b);
        return {
            min: sorted[0] || 0,
            max: sorted[sorted.length - 1] || 0,
            average: this.delays.reduce((a, b) => a + b, 0) / this.delays.length || 0,
            p95: sorted[Math.floor(sorted.length * 0.95)] || 0,
            count: this.delays.length
        };
    }
}
```

### Detecting Blocking Code

```javascript
function detectBlocking() {
    let eventLoopLag = 0;
    
    // Start monitoring
    const interval = setInterval(() => {
        const start = Date.now();
        setImmediate(() => {
            const delay = Date.now() - start;
            if (delay > 20) {
                console.warn(`Blocking code detected: ${delay}ms delay`);
            }
            eventLoopLag = delay;
        });
    }, 100);
    
    // Return cleanup function
    return () => clearInterval(interval);
}

// Usage
const cleanup = detectBlocking();
// ... run code
cleanup();
```

### Profiling Event Loop

```javascript
const { performance, PerformanceObserver } = require('perf_hooks');

function profileEventLoop() {
    const obs = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        for (const entry of entries) {
            if (entry.name === 'EventLoopUtilization') {
                console.log({
                    idle: entry.idle,
                    active: entry.active,
                    utilization: entry.utilization
                });
            }
        }
    });
    
    obs.observe({ entryTypes: ['eventlooputilization'] });
    
    setInterval(() => {
        performance.eventLoopUtilization();
    }, 1000);
    
    return () => obs.disconnect();
}
```

---

## Complete Event Loop API Reference Table

| API | Queue | Phase | Priority | When to Use |
|-----|-------|-------|----------|-------------|
| **process.nextTick** | Microtask | Next Tick | 1 (Highest) | Error handling, immediate callbacks |
| **Promise.then** | Microtask | Microtask | 2 | Async operations, chaining |
| **queueMicrotask** | Microtask | Microtask | 3 | Scheduling cleanup operations |
| **setTimeout** | Macrotask | Timer | 4 | Delayed execution, throttling |
| **setInterval** | Macrotask | Timer | 4 | Periodic operations |
| **setImmediate** | Macrotask | Check | 5 | I/O-bound operations |
| **I/O Operations** | Macrotask | Poll | 6 | File operations, network requests |
| **close callbacks** | Macrotask | Close | 7 | Cleanup operations |

---

## Common Event Loop Pitfalls

### Pitfall 1: Blocking the Event Loop

```javascript
// ❌ BAD: Blocks the event loop
function processLargeArray(array) {
    for (let i = 0; i < array.length; i++) {
        // Heavy processing
        array[i] = heavyOperation(array[i]);
    }
    return array;
}

// ✅ GOOD: Yield to the event loop
async function processLargeArray(array) {
    const results = [];
    const chunkSize = 100;
    
    for (let i = 0; i < array.length; i += chunkSize) {
        const chunk = array.slice(i, i + chunkSize);
        for (const item of chunk) {
            results.push(heavyOperation(item));
        }
        // Yield to the event loop
        await new Promise(resolve => setImmediate(resolve));
    }
    return results;
}
```

### Pitfall 2: Recursive process.nextTick

```javascript
// ❌ BAD: Starves the event loop
function recursiveNextTick(count) {
    if (count > 0) {
        process.nextTick(() => recursiveNextTick(count - 1));
    }
}
recursiveNextTick(10000); // Blocks event loop

// ✅ GOOD: Use setImmediate for recursion
function recursiveImmediate(count) {
    if (count > 0) {
        setImmediate(() => recursiveImmediate(count - 1));
    }
}
recursiveImmediate(10000); // Allows I/O to interleave
```

### Pitfall 3: Unhandled Promise Rejections

```javascript
// ❌ BAD: Unhandled rejection blocks microtask queue
Promise.reject('Error');
// UnhandledPromiseRejectionWarning

// ✅ GOOD: Always handle rejections
Promise.reject('Error').catch(() => {});
// Or:
Promise.reject('Error').then(null, () => {});
```

---

## Testing Event Loop Behavior

```javascript
const assert = require('assert');

describe('Event Loop Behavior', () => {
    it('process.nextTick runs before Promises', (done) => {
        const order = [];
        
        order.push('1');
        
        process.nextTick(() => {
            order.push('2');
        });
        
        Promise.resolve().then(() => {
            order.push('3');
        });
        
        order.push('4');
        
        setTimeout(() => {
            assert.deepStrictEqual(order, ['1', '4', '2', '3']);
            done();
        }, 0);
    });
    
    it('setImmediate runs after I/O', (done) => {
        const fs = require('fs');
        const order = [];
        
        fs.readFile(__filename, () => {
            order.push('1');
            setImmediate(() => {
                order.push('2');
                setTimeout(() => {
                    order.push('3');
                    assert.deepStrictEqual(order, ['1', '2', '3']);
                    done();
                }, 0);
            });
        });
    });
});
```

---

## Summary

| Concept | Key Takeaway |
|---------|--------------|
| **Microtasks** | Run immediately after the current stack, before macrotasks |
| **Macrotasks** | Run one per iteration of the event loop |
| **process.nextTick** | Highest priority, use sparingly |
| **setTimeout** | Minimum delay, not guaranteed exact timing |
| **setImmediate** | Runs in check phase, after I/O |
| **Promises** | Schedule microtasks |
| **Async/Await** | Syntactic sugar for promises |
| **Event Loop** | Single-threaded, non-blocking |

