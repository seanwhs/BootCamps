# Appendix C: Event Loop and Task Scheduling Reference

The event loop determines when asynchronous callbacks are allowed to run.

It explains why this code:

```js
console.log("A");

setTimeout(() => {
  console.log("B");
}, 0);

Promise.resolve().then(() => {
  console.log("C");
});

console.log("D");
```

prints:

```text
A
D
C
B
```

The timer does not interrupt the current synchronous code, and the promise callback runs before the timer callback.

This appendix provides:

- A practical event-loop model.
- Call-stack behavior.
- Microtasks.
- Tasks and macrotasks.
- Timers.
- Promise scheduling.
- `queueMicrotask()`.
- Browser rendering behavior.
- Node.js event-loop phases.
- `process.nextTick()`.
- `setImmediate()`.
- Starvation.
- Ordering experiments.
- Performance and debugging guidance.

---

# C.1: The Simplified Event-Loop Model

A useful simplified model is:

```text
1. Execute synchronous JavaScript
2. Drain the microtask queue
3. Run a later task
4. Drain microtasks created by that task
5. Possibly render in a browser
6. Repeat
```

Visualized:

```text
┌──────────────────────────────┐
│ Execute current task          │
│ synchronous JavaScript       │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Drain microtasks completely  │
│ Promise callbacks            │
│ queueMicrotask callbacks     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Browser may render           │
│ or runtime selects next task │
└──────────────┬───────────────┘
               │
               ▼
          Repeat cycle
```

This is a teaching model. Browser and Node.js runtimes have more detailed scheduling rules.

The most reliable general rule is:

> Synchronous code runs first. Microtasks run after the current synchronous work. Later tasks run afterward.

---

# C.2: The Call Stack

## The Target

We will observe nested function calls using a manually maintained call-depth counter.

## The Concept

The call stack records which functions are currently active.

For this code:

```js
function first() {
  second();
}

function second() {
  third();
}

function third() {
  console.log("third");
}

first();
```

The stack grows like this:

```text
third()
second()
first()
global code
```

When `third()` returns, it is removed:

```text
second()
first()
global code
```

## Implementation

### `event-loop-stack.js`

```js
"use strict";

let depth = 0;

function log(message) {
  console.log(`${"  ".repeat(depth)}${message}`);
}

function enter(name) {
  depth += 1;
  log(`enter ${name}`);
}

function leave(name) {
  log(`leave ${name}`);
  depth -= 1;
}

function first() {
  enter("first");

  second();

  leave("first");
}

function second() {
  enter("second");

  third();

  leave("second");
}

function third() {
  enter("third");

  log("third is executing");

  leave("third");
}

log("global code starts");
first();
log("global code ends");
```

## Verification

Run:

```bash
node event-loop-stack.js
```

Expected output:

```text
global code starts
  enter first
    enter second
      enter third
      third is executing
      leave third
    leave second
  leave first
global code ends
```

A callback cannot run while another synchronous function is still occupying the call stack.

---

# C.3: Synchronous Code Always Starts First

## Implementation

### `synchronous-first.js`

```js
"use strict";

console.log("1. synchronous start");

setTimeout(() => {
  console.log("4. timer callback");
}, 0);

Promise.resolve().then(() => {
  console.log("3. promise callback");
});

queueMicrotask(() => {
  console.log("3b. queueMicrotask callback");
});

console.log("2. synchronous end");
```

## Verification

Run:

```bash
node synchronous-first.js
```

Expected output:

```text
1. synchronous start
2. synchronous end
3. promise callback
3b. queueMicrotask callback
4. timer callback
```

The two synchronous logs run before either asynchronous callback.

---

# C.4: Promise Callbacks Are Microtasks

## The Target

We will observe that `.then()`, `.catch()`, and `.finally()` callbacks run as microtasks.

## Implementation

### `promise-microtasks.js`

```js
"use strict";

console.log("1. start");

Promise.resolve("fulfilled").then((value) => {
  console.log("3. then:", value);
});

Promise.reject(new Error("rejected")).catch((error) => {
  console.log("4. catch:", error.message);
});

Promise.resolve().finally(() => {
  console.log("5. finally");
});

console.log("2. end");
```

## Verification

Run:

```bash
node promise-microtasks.js
```

Expected output:

```text
1. start
2. end
3. then: fulfilled
4. catch: rejected
5. finally
```

Promise handlers do not execute immediately during the call to `.then()` or `.catch()`. They are scheduled for a later microtask checkpoint.

---

# C.5: `queueMicrotask()`

## The Target

We will schedule work directly on the microtask queue.

## Implementation

### `queue-microtask.js`

```js
"use strict";

const events = [];

function record(label) {
  events.push(label);
  console.log(label);
}

record("synchronous start");

queueMicrotask(() => {
  record("microtask one");

  queueMicrotask(() => {
    record("nested microtask");
  });
});

queueMicrotask(() => {
  record("microtask two");
});

record("synchronous end");

setTimeout(() => {
  record("timer");

  console.log("\nFinal order:");
  console.log(events.join(" -> "));
}, 0);
```

## Verification

Run:

```bash
node queue-microtask.js
```

Expected order:

```text
synchronous start
synchronous end
microtask one
microtask two
nested microtask
timer
```

A microtask added while the queue is being drained joins the same queue and runs before the timer.

---

# C.6: Microtask Ordering

## The Target

We will compare Promise reactions and `queueMicrotask()` callbacks.

## The Concept

Both use the microtask queue.

They generally execute in the order they are queued.

## Implementation

### `microtask-order.js`

```js
"use strict";

const events = [];

function record(label) {
  events.push(label);
}

Promise.resolve().then(() => {
  record("promise one");
});

queueMicrotask(() => {
  record("queueMicrotask one");
});

Promise.resolve().then(() => {
  record("promise two");
});

queueMicrotask(() => {
  record("queueMicrotask two");
});

setTimeout(() => {
  record("timer");

  console.log(events);
}, 0);
```

## Verification

Run:

```bash
node microtask-order.js
```

Expected output:

```text
[
  'promise one',
  'queueMicrotask one',
  'promise two',
  'queueMicrotask two',
  'timer'
]
```

The key rule is not that promises always beat `queueMicrotask()`. The key rule is that both are microtasks, and their relative order follows when they were queued.

---

# C.7: Microtasks Created by Microtasks

## The Target

We will observe that microtasks created while draining the queue run before a later timer.

## Implementation

### `nested-microtasks.js`

```js
"use strict";

const events = [];

function record(label) {
  events.push(label);
}

queueMicrotask(() => {
  record("microtask A");

  queueMicrotask(() => {
    record("microtask A.1");
  });
});

queueMicrotask(() => {
  record("microtask B");

  Promise.resolve().then(() => {
    record("microtask B.1");
  });
});

setTimeout(() => {
  record("timer");

  console.log(events);
}, 0);
```

## Verification

Run:

```bash
node nested-microtasks.js
```

Expected output:

```text
[
  'microtask A',
  'microtask B',
  'microtask A.1',
  'microtask B.1',
  'timer'
]
```

The runtime drains the microtask queue until it is empty before moving to the timer task.

---

# C.8: Tasks and Timers

## The Concept

A timer schedules a callback for a later task.

A delay of zero means:

> Do not run before the current task and applicable scheduling conditions complete.

It does not mean:

> Run immediately.

## Implementation

### `timer-delay.js`

```js
"use strict";

const start = Date.now();

setTimeout(() => {
  const elapsed = Date.now() - start;

  console.log({
    elapsedMilliseconds: elapsed,
    message: "timer became eligible"
  });
}, 0);

const endOfSynchronousWork = Date.now() + 50;

while (Date.now() < endOfSynchronousWork) {
  /*
   * This intentionally blocks the JavaScript thread for demonstration.
   * Timers cannot interrupt this synchronous loop.
   */
}

console.log("synchronous work finished");
```

## Verification

Run:

```bash
node timer-delay.js
```

Expected output:

```text
synchronous work finished
{
  elapsedMilliseconds: 50,
  message: 'timer became eligible'
}
```

The exact time varies, but the timer cannot run while the loop occupies the call stack.

---

# C.9: Timer Minimum Delay Is Not Execution Time

## The Concept

A timer’s delay is a minimum waiting period, not a guarantee of exact execution time.

This can happen:

```text
timer becomes eligible
        │
        ▼
another task is running
        │
        ▼
current task finishes
        │
        ▼
timer callback runs
```

Timers can be delayed by:

- Long synchronous work.
- Other queued tasks.
- Runtime scheduling.
- Operating-system load.
- Browser throttling.
- Background-tab policies.

---

# C.10: `setTimeout()` and `setInterval()`

## `setTimeout()`

Schedules a callback once.

```js
const timeoutId = setTimeout(() => {
  console.log("runs once");
}, 100);

clearTimeout(timeoutId);
```

## `setInterval()`

Schedules repeated callbacks.

```js
const intervalId = setInterval(() => {
  console.log("repeated");
}, 100);

setTimeout(() => {
  clearInterval(intervalId);
}, 500);
```

Always retain the identifier if the timer may need to be cancelled.

---

## Avoid Overlapping Intervals

An interval can start another callback even if the previous asynchronous operation is still running.

Potentially unsafe:

```js
setInterval(async () => {
  await pollService();
}, 1_000);
```

If `pollService()` takes longer than one second, calls overlap.

Prefer recursive scheduling:

```js
async function pollRepeatedly() {
  try {
    await pollService();
  } finally {
    setTimeout(pollRepeatedly, 1_000);
  }
}

pollRepeatedly();
```

This waits for one poll to finish before scheduling the next.

---

# C.11: Browser Rendering and the Event Loop

## The Concept

Browsers must coordinate:

- JavaScript.
- User input.
- Layout.
- Painting.
- Animation frames.
- Network callbacks.
- Timers.

A simplified browser cycle is:

```text
run a task
    │
    ▼
drain microtasks
    │
    ▼
possibly update rendering
    │
    ▼
run animation callbacks
    │
    ▼
continue
```

The exact order depends on the browser and scheduling context. Do not treat this diagram as a complete browser specification.

---

## `requestAnimationFrame()`

`requestAnimationFrame()` schedules a callback before the browser’s next visual update.

```js
requestAnimationFrame(() => {
  element.textContent = "updated before the next frame";
});
```

It is generally appropriate for visual updates because the browser can align the callback with rendering.

---

## Example: Batch Visual Updates

```js
let renderScheduled = false;
let latestState;

function requestRender(state) {
  latestState = state;

  if (renderScheduled) {
    return;
  }

  renderScheduled = true;

  requestAnimationFrame(() => {
    renderScheduled = false;

    render(latestState);
  });
}
```

Several synchronous state changes can produce one visual update.

---

# C.12: Browser Event Example

## Implementation

### `browser-event-order.js`

```js
"use strict";

const output = document.querySelector("#output");
const button = document.querySelector("#button");

function write(message) {
  output.textContent += `${message}\n`;
}

button.addEventListener("click", () => {
  write("event handler start");

  queueMicrotask(() => {
    write("microtask from event");
  });

  setTimeout(() => {
    write("timer from event");
  }, 0);

  requestAnimationFrame(() => {
    write("animation frame callback");
  });

  write("event handler end");
});
```

### `browser-event-order.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Browser Event Order</title>
  </head>
  <body>
    <button id="button" type="button">Run experiment</button>
    <pre id="output"></pre>

    <script type="module" src="./browser-event-order.js"></script>
  </body>
</html>
```

## Verification

Open the HTML file in a modern browser and click the button.

You should see:

```text
event handler start
event handler end
microtask from event
animation frame callback
timer from event
```

The exact relative placement of the animation-frame callback and timer can vary by browser and scheduling circumstances. The reliable observations are:

- Synchronous handler code finishes first.
- The microtask runs after the handler.
- The timer runs later.
- The animation callback is coordinated with rendering.

---

# C.13: Node.js Event-Loop Phases

Node.js uses an event loop with several phases.

A simplified phase model is:

```text
timers
   │
   ▼
pending callbacks
   │
   ▼
idle / prepare
   │
   ▼
poll
   │
   ▼
check
   │
   ▼
close callbacks
   │
   └── repeat
```

The exact implementation and behavior are runtime-specific.

Common phases:

### Timers

Processes callbacks scheduled by:

- `setTimeout()`.
- `setInterval()`.

### Poll

Processes many I/O callbacks and waits for new I/O when appropriate.

### Check

Processes `setImmediate()` callbacks.

### Close Callbacks

Processes close events such as socket close handlers.

---

# C.14: `process.nextTick()`

## The Concept

Node.js provides `process.nextTick()`, which schedules a callback in a special queue processed before the event loop continues to later phases.

```js
process.nextTick(() => {
  console.log("next tick");
});
```

`process.nextTick()` is not the same API as `queueMicrotask()`, although both run before ordinary timers in common situations.

A simplified Node.js priority model is:

```text
current JavaScript
        │
        ▼
process.nextTick queue
        │
        ▼
microtask queue
        │
        ▼
event-loop phases
```

Do not depend on this as a universal browser rule. `process.nextTick()` is Node.js-specific.

---

## Verification

### `node-next-tick.js`

```js
"use strict";

console.log("1. synchronous");

Promise.resolve().then(() => {
  console.log("4. Promise microtask");
});

queueMicrotask(() => {
  console.log("5. queueMicrotask");
});

process.nextTick(() => {
  console.log("3. process.nextTick");
});

setTimeout(() => {
  console.log("6. timer");
}, 0);

console.log("2. synchronous");
```

Run:

```bash
node node-next-tick.js
```

Typical Node.js output:

```text
1. synchronous
2. synchronous
3. process.nextTick
4. Promise microtask
5. queueMicrotask
6. timer
```

`process.nextTick()` should be used sparingly. An unbounded next-tick chain can starve the event loop.

---

# C.15: `setImmediate()`

## The Concept

`setImmediate()` is a Node.js API that schedules a callback during the check phase.

```js
setImmediate(() => {
  console.log("check phase callback");
});
```

The relative order of `setTimeout(..., 0)` and `setImmediate()` depends on where they are scheduled.

---

## Top-Level Ordering

### `top-level-order.js`

```js
"use strict";

setTimeout(() => {
  console.log("setTimeout");
}, 0);

setImmediate(() => {
  console.log("setImmediate");
});
```

Run:

```bash
node top-level-order.js
```

The order may vary.

Do not write logic that assumes one always runs first at top level.

---

## Inside I/O

When both are scheduled inside an I/O callback, `setImmediate()` commonly runs before a zero-delay timer.

### `io-order.js`

```js
"use strict";

import { readFile } from "node:fs";

readFile(new URL(import.meta.url), () => {
  setTimeout(() => {
    console.log("setTimeout inside I/O");
  }, 0);

  setImmediate(() => {
    console.log("setImmediate inside I/O");
  });
});
```

Run:

```bash
node io-order.js
```

Typical output:

```text
setImmediate inside I/O
setTimeout inside I/O
```

The result reflects Node.js event-loop phases. It should not be generalized to browsers.

---

# C.16: Microtask Starvation

## The Target

We will demonstrate that an unbounded microtask chain can prevent a timer from executing.

## Implementation

### `microtask-starvation.js`

```js
"use strict";

let microtasksProcessed = 0;
let timerExecuted = false;
const maximumMicrotasks = 100_000;

setTimeout(() => {
  timerExecuted = true;

  console.log({
    timerExecuted,
    microtasksProcessed
  });
}, 0);

function scheduleNextMicrotask() {
  microtasksProcessed += 1;

  if (microtasksProcessed < maximumMicrotasks) {
    queueMicrotask(scheduleNextMicrotask);
  }
}

queueMicrotask(scheduleNextMicrotask);

setTimeout(() => {
  console.log({
    laterObservation: timerExecuted,
    microtasksProcessed
  });
}, 100);
```

## Verification

Run:

```bash
node microtask-starvation.js
```

The first timer runs only after the scheduled microtasks finish.

An infinite version would prevent the timer from running indefinitely:

```js
function neverYield() {
  queueMicrotask(neverYield);
}

neverYield();
```

Do not run the infinite version in a production process.

---

# C.17: Yielding to the Runtime

## The Target

We will process work in batches and periodically yield.

## Implementation

### `yielding-work.js`

```js
"use strict";

function yieldToRuntime() {
  return new Promise((resolve) => {
    setTimeout(resolve, 0);
  });
}

async function processInBatches(
  items,
  processItem,
  batchSize = 100
) {
  if (!Array.isArray(items)) {
    throw new TypeError("items must be an array");
  }

  if (typeof processItem !== "function") {
    throw new TypeError("processItem must be a function");
  }

  if (!Number.isInteger(batchSize) || batchSize < 1) {
    throw new RangeError(
      "batchSize must be a positive integer"
    );
  }

  for (
    let start = 0;
    start < items.length;
    start += batchSize
  ) {
    const end = Math.min(
      start + batchSize,
      items.length
    );

    for (let index = start; index < end; index += 1) {
      processItem(items[index], index);
    }

    if (end < items.length) {
      await yieldToRuntime();
    }
  }
}

const items = Array.from({ length: 500 }, (_, index) => index);

await processInBatches(
  items,
  (_, index) => {
    if (index % 100 === 0) {
      console.log("processed:", index);
    }
  },
  100
);

console.log("processing complete");
```

## Verification

Run:

```bash
node yielding-work.js
```

Expected output:

```text
processed: 0
processed: 100
processed: 200
processed: 300
processed: 400
processing complete
```

The yields allow other queued work to run between batches.

---

# C.18: Microtask Versus Task Yielding

## Microtask Yield

```js
await Promise.resolve();
```

This yields to other microtasks but generally does not allow timers or ordinary tasks to run first.

## Task Yield

```js
await new Promise((resolve) => {
  setTimeout(resolve, 0);
});
```

This gives the runtime an opportunity to process later tasks.

Use a microtask yield for short internal sequencing. Use a task or frame yield when long work must allow timers, input, or rendering to proceed.

---

# C.19: Event Loop Ordering Experiment

## Implementation

### `ordering-laboratory.js`

```js
"use strict";

const events = [];

function record(label) {
  events.push(label);
  console.log(`${events.length}. ${label}`);
}

record("synchronous A");

process.nextTick(() => {
  record("process.nextTick");
});

queueMicrotask(() => {
  record("queueMicrotask");

  Promise.resolve().then(() => {
    record("Promise created inside microtask");
  });
});

Promise.resolve().then(() => {
  record("Promise.then");
});

setTimeout(() => {
  record("setTimeout");

  queueMicrotask(() => {
    record("microtask created inside setTimeout");
  });
}, 0);

setImmediate(() => {
  record("setImmediate");
});

record("synchronous B");

setTimeout(() => {
  console.log("\nObserved order:");
  console.log(events.join(" -> "));
}, 50);
```

## Verification

Run:

```bash
node ordering-laboratory.js
```

Typical output begins:

```text
1. synchronous A
2. synchronous B
3. process.nextTick
4. queueMicrotask
5. Promise.then
6. Promise created inside microtask
```

The ordering between `setTimeout` and `setImmediate` may vary in this top-level experiment.

The important observations are:

- Synchronous code comes first.
- Node’s `process.nextTick()` queue has special priority.
- Promise and `queueMicrotask()` callbacks run before later timer or check callbacks.
- Microtasks created by a timer run before the next later phase.

---

# C.20: `process.nextTick()` Starvation

## The Target

We will demonstrate the danger of recursively scheduling `process.nextTick()`.

## Implementation

### `next-tick-starvation.js`

```js
"use strict";

let processed = 0;
const maximumTicks = 50_000;

setTimeout(() => {
  console.log("timer finally ran");
}, 0);

function scheduleNextTick() {
  processed += 1;

  if (processed < maximumTicks) {
    process.nextTick(scheduleNextTick);
  }
}

process.nextTick(scheduleNextTick);

setTimeout(() => {
  console.log("nextTick callbacks processed:", processed);
}, 100);
```

## Verification

Run:

```bash
node next-tick-starvation.js
```

The timer runs only after the next-tick chain finishes.

Use `process.nextTick()` for narrowly defined Node.js compatibility or API sequencing needs, not as a general-purpose scheduling tool.

---

# C.21: Event Loop and CPU-Bound Work

## The Problem

Promises do not make CPU-heavy work run on another thread.

This blocks the event loop:

```js
function expensiveWork() {
  let result = 0;

  for (let index = 0; index < 1_000_000_000; index += 1) {
    result += index;
  }

  return result;
}

Promise.resolve().then(() => {
  expensiveWork();
});
```

The promise callback runs on the same JavaScript thread and can block timers, input, and rendering.

---

## Move CPU Work to a Worker

In Node.js, use worker threads for CPU-heavy independent work.

### `worker-calculation.js`

```js
"use strict";

import { parentPort, workerData } from "node:worker_threads";

function calculateSum(limit) {
  let total = 0;

  for (let index = 0; index <= limit; index += 1) {
    total += index;
  }

  return total;
}

const result = calculateSum(workerData.limit);

parentPort.postMessage(result);
```

### `run-worker.js`

```js
"use strict";

import { Worker } from "node:worker_threads";

function runCalculation(limit) {
  return new Promise((resolve, reject) => {
    const worker = new Worker(
      new URL("./worker-calculation.js", import.meta.url),
      {
        workerData: { limit }
      }
    );

    worker.once("message", resolve);

    worker.once("error", reject);

    worker.once("exit", (exitCode) => {
      if (exitCode !== 0) {
        reject(
          new Error(`worker stopped with code ${exitCode}`)
        );
      }
    });
  });
}

console.log(
  await runCalculation(1_000_000)
);
```

## Verification

Run:

```bash
node run-worker.js
```

Expected output:

```text
500000500000
```

The calculation runs in a worker instead of occupying the main Node.js JavaScript thread.

---

# C.22: Event Loop Monitoring in Node.js

## The Target

We will measure event-loop delay.

## Concept

Event-loop delay indicates how long scheduled work waits before the runtime can execute it.

Large delays may indicate:

- CPU-heavy synchronous code.
- Excessive garbage collection.
- Blocking filesystem calls.
- Large JSON parsing.
- Long synchronous loops.

## Implementation

### `event-loop-delay.js`

```js
"use strict";

import {
  monitorEventLoopDelay
} from "node:perf_hooks";

const monitor = monitorEventLoopDelay({
  resolution: 10
});

monitor.enable();

setTimeout(() => {
  let total = 0;

  for (let index = 0; index < 50_000_000; index += 1) {
    total += index;
  }

  console.log("calculation result:", total);
}, 50);

setTimeout(() => {
  monitor.disable();

  console.log({
    minimumMilliseconds: Number(
      monitor.min
    ) / 1_000_000,

    maximumMilliseconds: Number(
      monitor.max
    ) / 1_000_000,

    meanMilliseconds: Number(
      monitor.mean
    ) / 1_000_000,

    percentile99Milliseconds: Number(
      monitor.percentile(99)
    ) / 1_000_000
  });
}, 500);
```

## Verification

Run:

```bash
node event-loop-delay.js
```

The exact measurements depend on the machine. The long calculation should create observable event-loop delay.

---

# C.23: Browser Event-Loop Performance

In browser applications, long JavaScript tasks can delay:

- Click handling.
- Keyboard input.
- Scrolling.
- Painting.
- Animation.
- Layout.

A useful browser pattern is to split large work:

```js
async function processItems(items) {
  for (let index = 0; index < items.length; index += 1) {
    process(items[index]);

    if (index % 100 === 0) {
      await new Promise((resolve) => {
        setTimeout(resolve, 0);
      });
    }
  }
}
```

For visual updates:

```js
requestAnimationFrame(() => {
  render(nextState);
});
```

For idle, non-urgent work, a browser may provide:

```js
requestIdleCallback(() => {
  performNonUrgentWork();
});
```

`requestIdleCallback()` is not uniformly available in every environment and should have a fallback when compatibility matters.

---

# C.24: Event Loop Ordering Rules

These rules are broadly useful:

## Rule 1: Current Synchronous Work Wins

```js
console.log("first");

setTimeout(() => {
  console.log("later");
}, 0);

console.log("second");
```

Output:

```text
first
second
later
```

## Rule 2: Microtasks Run Before Later Tasks

```js
queueMicrotask(() => {
  console.log("microtask");
});

setTimeout(() => {
  console.log("timer");
}, 0);
```

Output:

```text
microtask
timer
```

## Rule 3: Microtasks Drain Completely

A microtask that schedules another microtask does not yield to a timer automatically.

## Rule 4: Timers Are Not Exact Clocks

A timer callback runs when eligible and when the runtime can execute it.

## Rule 5: CPU Work Blocks the Current JavaScript Thread

Promises and timers do not interrupt a synchronous loop.

## Rule 6: Host Environments Differ

Node.js and browsers provide different APIs and event-loop phases.

## Rule 7: Avoid Depending on Unspecified Ordering

If the relative order of two mechanisms is not guaranteed, do not use that order as application logic.

---

# C.25: Debugging Event-Loop Behavior

## Add Explicit Labels

```js
console.log("before request");

const promise = fetchData();

console.log("after request");

promise.then(() => {
  console.log("request callback");
});
```

## Record Timestamps

```js
function log(message) {
  console.log(
    new Date().toISOString(),
    message
  );
}
```

## Record Relative Time

```js
const startedAt = performance.now();

function log(message) {
  console.log(
    `${(performance.now() - startedAt).toFixed(2)} ms: ${message}`
  );
}
```

## Track Queue Sources

Label callbacks by source:

```js
queueMicrotask(() => log("microtask"));

setTimeout(() => log("timer"), 0);

setImmediate(() => log("immediate"));
```

## Avoid Logging Too Much

Console output itself can affect timing, especially in development tools and large loops. Use logging for diagnosis, not as a precise benchmark instrument.

---

# C.26: Common Event-Loop Mistakes

## Mistake 1: Expecting `setTimeout(..., 0)` to Run Immediately

Incorrect assumption:

```text
timer registered → timer runs now
```

Correct model:

```text
timer registered
synchronous code finishes
microtasks drain
timer becomes eligible
timer callback runs when the runtime can schedule it
```

---

## Mistake 2: Assuming Promises Run in Parallel

Promises coordinate asynchronous work. They do not automatically make CPU-bound JavaScript parallel.

---

## Mistake 3: Creating Infinite Microtasks

```js
function loop() {
  queueMicrotask(loop);
}

loop();
```

This can starve timers and I/O.

---

## Mistake 4: Using `setInterval()` for Slow Async Work

```js
setInterval(async () => {
  await slowOperation();
}, 100);
```

Operations may overlap.

Use sequential scheduling when overlap is not intended.

---

## Mistake 5: Relying on `setTimeout()` and `setImmediate()` Ordering

At Node.js top level, their relative order may vary.

Use them based on intended semantics, not an assumed ordering accident.

---

## Mistake 6: Blocking with Synchronous APIs

Node.js synchronous operations can block the event loop:

```js
import fs from "node:fs";

const content = fs.readFileSync("large-file.txt", "utf8");
```

Use asynchronous APIs when the work may be slow and the process must remain responsive.

---

# C.27: Choosing a Scheduling Mechanism

| Need | Suggested mechanism |
|---|---|
| Run immediately as part of current logic | Normal synchronous call |
| Run after current synchronous code before timers | `queueMicrotask()` |
| Run a later timer task | `setTimeout()` |
| Repeat at intervals | `setInterval()` with lifecycle cleanup |
| Run after an asynchronous operation | Promise continuation or `await` |
| Node.js check-phase scheduling | `setImmediate()` |
| Node.js next-tick sequencing | `process.nextTick()` sparingly |
| Browser visual update | `requestAnimationFrame()` |
| Browser non-urgent idle work | `requestIdleCallback()` with fallback |
| Move CPU-heavy work off the main thread | Worker |

---

# C.28: Complete Event-Loop Laboratory

## Implementation

### `complete-event-loop-lab.js`

```js
"use strict";

const startedAt = performance.now();
const events = [];

function record(label) {
  const elapsed = performance.now() - startedAt;
  const entry = {
    label,
    elapsedMilliseconds: Number(elapsed.toFixed(2))
  };

  events.push(entry);
  console.log(entry);
}

record("synchronous start");

process.nextTick(() => {
  record("process.nextTick");
});

queueMicrotask(() => {
  record("queueMicrotask");

  queueMicrotask(() => {
    record("nested queueMicrotask");
  });
});

Promise.resolve().then(() => {
  record("Promise.then");
});

setTimeout(() => {
  record("setTimeout");

  queueMicrotask(() => {
    record("microtask inside setTimeout");
  });
}, 0);

setImmediate(() => {
  record("setImmediate");
});

record("synchronous end");

setTimeout(() => {
  console.log("\nAll events:");
  console.dir(events, { depth: null });
}, 50);
```

## Verification

Run:

```bash
node complete-event-loop-lab.js
```

The first entries should be:

```text
synchronous start
synchronous end
process.nextTick
queueMicrotask
Promise.then
nested queueMicrotask
```

The relative order of `setTimeout` and `setImmediate` may vary.

---

# C.29: Event-Loop Verification Checklist

Run:

```bash
node event-loop-stack.js
node synchronous-first.js
node promise-microtasks.js
node queue-microtask.js
node microtask-order.js
node nested-microtasks.js
node timer-delay.js
node node-next-tick.js
node io-order.js
node microtask-starvation.js
node yielding-work.js
node event-loop-delay.js
node complete-event-loop-lab.js
```

Confirm that:

- Function calls grow and shrink the call stack.
- Synchronous code runs before asynchronous callbacks.
- Promise handlers run as microtasks.
- `queueMicrotask()` callbacks run before later timer tasks.
- Nested microtasks are drained before timers.
- Timers are delayed by long synchronous work.
- `process.nextTick()` is Node-specific.
- `setImmediate()` belongs to Node’s scheduling model.
- Microtask chains can starve later tasks.
- Batched work can yield to the runtime.
- CPU-heavy work can create event-loop delay.
- Worker threads can move CPU-heavy work off the main thread.

---

# C.30: Final Event-Loop Mental Model

Use this model when analyzing asynchronous JavaScript:

```text
A. What is currently on the call stack?
B. Which callbacks have been queued?
C. Which callbacks are microtasks?
D. Which callbacks are later tasks?
E. Will the current code finish quickly?
F. Could a microtask chain starve other work?
G. Is this a browser or Node.js runtime?
H. Can the operation be cancelled?
I. Is the callback allowed to run after the owning component is destroyed?
```

The most important sequence is:

```text
current synchronous task
        │
        ▼
microtask queue completely drains
        │
        ▼
runtime selects a later task
        │
        ▼
new microtasks completely drain
        │
        ▼
browser may render or Node.js advances phases
```

The event loop is not a mysterious background thread. It is a scheduling system that decides when queued JavaScript callbacks can use the call stack.

Once that model is clear, many asynchronous behaviors become predictable:

- Why promises run before zero-delay timers.
- Why timers cannot interrupt loops.
- Why `await` pauses only one async function.
- Why infinite microtasks freeze progress.
- Why CPU-heavy work needs workers.
- Why cancellation and cleanup must be designed explicitly.
