# Appendix G: Performance Profiling and Diagnostics Guide

Performance work should begin with evidence, not guesses.

A program can be slow because of:

- Too much CPU work.
- Excessive memory allocation.
- Garbage-collection pressure.
- Network latency.
- Too many renders.
- Long synchronous tasks.
- Unbounded queues.
- Repeated parsing or serialization.
- Excessive logging.
- Slow external dependencies.

Profiling helps answer:

> Where is the application spending time, memory, and other resources?

This appendix covers:

- Measurement principles.
- Node.js timing APIs.
- Browser performance tools.
- CPU profiling.
- Memory profiling.
- Garbage-collection diagnostics.
- Event-loop delay.
- Benchmarking.
- HTTP and application latency.
- Rendering performance.
- Logging and observability.
- Common profiling mistakes.
- A practical investigation workflow.

---

# G.1: Measurement Before Optimization

## The Target

We will create a small timing helper.

## The Concept

A measurement should describe:

- What operation was measured.
- Which input was used.
- How long it took.
- Whether it was synchronous or asynchronous.
- Which runtime and environment were used.

A vague statement such as “this function is slow” is not enough.

Prefer:

```text
calculateDashboardSummary
input: 100,000 services
median: 14 ms
p95: 22 ms
runtime: Node.js 22
```

## Implementation

### `src/part-4/performance/measure-operation.js`

```js
"use strict";

export async function measureOperation(
  label,
  operation
) {
  if (typeof label !== "string" || label.trim() === "") {
    throw new TypeError(
      "label must be a non-empty string"
    );
  }

  if (typeof operation !== "function") {
    throw new TypeError(
      "operation must be a function"
    );
  }

  const startedAt = performance.now();

  let result;

  try {
    result = await operation();
  } finally {
    const elapsedMilliseconds =
      performance.now() - startedAt;

    console.log({
      label,
      elapsedMilliseconds: Number(
        elapsedMilliseconds.toFixed(3)
      )
    });
  }

  return result;
}

const result = await measureOperation(
  "example operation",
  async () => {
    await new Promise((resolve) => {
      setTimeout(resolve, 25);
    });

    return "completed";
  }
);

console.log(result);
```

## Verification

Run:

```bash
node src/part-4/performance/measure-operation.js
```

Expected output resembles:

```text
{ label: 'example operation', elapsedMilliseconds: 25.4 }
completed
```

The exact value varies.

---

# G.2: Wall-Clock Time Versus CPU Time

## Wall-Clock Time

Wall-clock time measures elapsed time from the observer’s perspective.

```text
request starts ───────── request finishes
              elapsed time
```

It includes:

- Waiting for network I/O.
- Waiting for timers.
- CPU execution.
- Queueing delays.
- External service time.

Use:

```js
const start = performance.now();
// operation
const elapsed = performance.now() - start;
```

## CPU Time

CPU time measures time spent actively using CPU resources.

An operation can have:

```text
wall-clock time: 100 ms
CPU time:        5 ms
```

The remaining 95 milliseconds may be network or I/O waiting.

This distinction matters:

- High wall-clock time with low CPU suggests waiting.
- High CPU time suggests computation or inefficient processing.
- Both high may indicate a combination of work and contention.

---

# G.3: `performance.now()`

`performance.now()` provides a high-resolution monotonic clock.

A **monotonic clock** moves forward consistently and is not affected by system clock changes.

```js
const startedAt = performance.now();

performWork();

const elapsedMilliseconds =
  performance.now() - startedAt;

console.log(elapsedMilliseconds);
```

Prefer `performance.now()` for durations.

Do not calculate durations with wall-clock dates:

```js
const start = Date.now();
// ...
const elapsed = Date.now() - start;
```

`Date.now()` is useful for timestamps but can be affected by clock adjustments.

---

# G.4: `process.hrtime.bigint()`

Node.js provides a high-resolution monotonic timer:

```js
const startedAt = process.hrtime.bigint();

performWork();

const elapsedNanoseconds =
  process.hrtime.bigint() - startedAt;

const elapsedMilliseconds =
  Number(elapsedNanoseconds) / 1_000_000;

console.log(elapsedMilliseconds);
```

Use this when:

- Measuring very short synchronous operations.
- Building a Node.js benchmark.
- Needing integer nanosecond values internally.

For most application-level measurements, `performance.now()` is easier to read.

---

# G.5: User Timing Marks and Measures

## The Target

We will create named performance marks.

## The Concept

A performance mark records a point in time.

A performance measure calculates the duration between marks.

This is more useful than scattered `console.log()` statements because measurements become named entries that tools can inspect.

## Implementation

### `src/part-4/performance/user-timing.js`

```js
"use strict";

import {
  performance,
  PerformanceObserver
} from "node:perf_hooks";

const observer = new PerformanceObserver(
  (list) => {
    for (const entry of list.getEntries()) {
      console.log({
        name: entry.name,
        entryType: entry.entryType,
        durationMilliseconds: Number(
          entry.duration.toFixed(3)
        ),
        startTimeMilliseconds: Number(
          entry.startTime.toFixed(3)
        )
      });
    }
  }
);

observer.observe({
  entryTypes: ["measure"]
});

performance.mark("dashboard-start");

await new Promise((resolve) => {
  setTimeout(resolve, 30);
});

performance.mark("dashboard-end");

performance.measure(
  "dashboard-refresh",
  "dashboard-start",
  "dashboard-end"
);

setTimeout(() => {
  observer.disconnect();
}, 10);
```

## Verification

Run:

```bash
node src/part-4/performance/user-timing.js
```

Expected output resembles:

```text
{
  name: 'dashboard-refresh',
  entryType: 'measure',
  durationMilliseconds: 30.8,
  startTimeMilliseconds: ...
}
```

---

# G.6: Instrumenting Application Phases

## The Target

We will measure separate workflow phases instead of measuring only the total duration.

## Concept

A total duration tells us that something is slow. Phase measurements help explain why.

```text
dashboard refresh
├── request metrics
├── request health
├── normalize responses
├── update state
└── render
```

## Implementation

### `src/part-4/performance/instrumented-workflow.js`

```js
"use strict";

import {
  performance,
  PerformanceObserver
} from "node:perf_hooks";

function sleep(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

const observer = new PerformanceObserver(
  (list) => {
    for (const entry of list.getEntries()) {
      console.log({
        phase: entry.name,
        durationMilliseconds: Number(
          entry.duration.toFixed(2)
        )
      });
    }
  }
);

observer.observe({
  entryTypes: ["measure"]
});

async function measurePhase(name, operation) {
  const startMark = `${name}:start`;
  const endMark = `${name}:end`;

  performance.mark(startMark);

  try {
    return await operation();
  } finally {
    performance.mark(endMark);

    performance.measure(
      name,
      startMark,
      endMark
    );

    performance.clearMarks(startMark);
    performance.clearMarks(endMark);
  }
}

async function refreshDashboard() {
  const metrics = await measurePhase(
    "metrics request",
    () => sleep(25).then(() => ({
      requestsPerSecond: 125
    }))
  );

  const health = await measurePhase(
    "health request",
    () => sleep(10).then(() => ({
      status: "healthy"
    }))
  );

  const normalized = await measurePhase(
    "response normalization",
    async () => ({
      metrics,
      health
    })
  );

  return measurePhase(
    "state update",
    async () => normalized
  );
}

console.log(await refreshDashboard());

setTimeout(() => {
  observer.disconnect();
}, 20);
```

## Verification

Run:

```bash
node src/part-4/performance/instrumented-workflow.js
```

You should see separate measurements for each workflow phase.

---

# G.7: Measuring Concurrent Operations

## The Target

We will compare sequential and concurrent service requests.

## Implementation

### `src/part-4/performance/concurrency-measurement.js`

```js
"use strict";

function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

async function measure(label, operation) {
  const startedAt = performance.now();
  const result = await operation();
  const elapsedMilliseconds =
    performance.now() - startedAt;

  console.log({
    label,
    elapsedMilliseconds: Number(
      elapsedMilliseconds.toFixed(2)
    ),
    result
  });
}

const services = [
  {
    name: "metrics",
    delayMilliseconds: 40
  },
  {
    name: "health",
    delayMilliseconds: 20
  },
  {
    name: "activity",
    delayMilliseconds: 30
  }
];

await measure("sequential", async () => {
  const results = [];

  for (const service of services) {
    results.push(
      await delay(
        service.delayMilliseconds,
        service.name
      )
    );
  }

  return results;
});

await measure("concurrent", async () => {
  return Promise.all(
    services.map((service) =>
      delay(
        service.delayMilliseconds,
        service.name
      )
    )
  );
});
```

## Verification

Run:

```bash
node src/part-4/performance/concurrency-measurement.js
```

Expected behavior:

```text
sequential: approximately 90 ms
concurrent: approximately 40 ms
```

The concurrent duration approaches the slowest individual operation.

---

# G.8: Benchmark Warm-Up

## The Concept

JavaScript engines may optimize frequently executed code.

A first execution may include:

- Parsing.
- Compilation.
- Initial object-shape setup.
- Runtime initialization.
- JIT optimization decisions.

A benchmark should usually:

1. Warm up the operation.
2. Run many measured iterations.
3. Report a distribution rather than one result.

Do not assume that one execution represents steady-state performance.

---

# G.9: A Simple Benchmark Harness

## The Target

We will create a benchmark utility that reports average, median, and percentile values.

## Implementation

### `src/part-4/performance/benchmark.js`

```js
"use strict";

function calculatePercentile(
  sortedValues,
  percentile
) {
  if (sortedValues.length === 0) {
    return null;
  }

  const index = Math.min(
    sortedValues.length - 1,
    Math.floor(
      sortedValues.length * percentile
    )
  );

  return sortedValues[index];
}

export async function benchmark({
  name,
  operation,
  warmupIterations = 100,
  measuredIterations = 1_000
}) {
  if (typeof name !== "string" || name.trim() === "") {
    throw new TypeError(
      "name must be a non-empty string"
    );
  }

  if (typeof operation !== "function") {
    throw new TypeError(
      "operation must be a function"
    );
  }

  if (
    !Number.isInteger(warmupIterations) ||
    warmupIterations < 0
  ) {
    throw new RangeError(
      "warmupIterations must be a non-negative integer"
    );
  }

  if (
    !Number.isInteger(measuredIterations) ||
    measuredIterations < 1
  ) {
    throw new RangeError(
      "measuredIterations must be a positive integer"
    );
  }

  for (
    let iteration = 0;
    iteration < warmupIterations;
    iteration += 1
  ) {
    await operation();
  }

  const durations = [];

  for (
    let iteration = 0;
    iteration < measuredIterations;
    iteration += 1
  ) {
    const startedAt = performance.now();

    await operation();

    durations.push(
      performance.now() - startedAt
    );
  }

  const sortedDurations = [...durations].sort(
    (first, second) => first - second
  );

  const total = durations.reduce(
    (sum, duration) => sum + duration,
    0
  );

  return {
    name,
    iterations: measuredIterations,
    averageMilliseconds: total / measuredIterations,
    medianMilliseconds: calculatePercentile(
      sortedDurations,
      0.5
    ),
    p95Milliseconds: calculatePercentile(
      sortedDurations,
      0.95
    ),
    minimumMilliseconds: sortedDurations[0],
    maximumMilliseconds:
      sortedDurations[sortedDurations.length - 1]
  };
}

function createNumbers(count) {
  return Array.from(
    { length: count },
    (_, index) => index
  );
}

const values = createNumbers(10_000);

const result = await benchmark({
  name: "map and reduce",
  measuredIterations: 200,
  operation: () => {
    const doubled = values.map(
      (value) => value * 2
    );

    return doubled.reduce(
      (sum, value) => sum + value,
      0
    );
  }
});

console.log({
  ...result,
  averageMilliseconds: Number(
    result.averageMilliseconds.toFixed(4)
  ),
  medianMilliseconds: Number(
    result.medianMilliseconds.toFixed(4)
  ),
  p95Milliseconds: Number(
    result.p95Milliseconds.toFixed(4)
  )
});
```

## Verification

Run:

```bash
node src/part-4/performance/benchmark.js
```

You should see a result containing:

```text
{
  name: 'map and reduce',
  iterations: 200,
  averageMilliseconds: ...,
  medianMilliseconds: ...,
  p95Milliseconds: ...,
  minimumMilliseconds: ...,
  maximumMilliseconds: ...
}
```

---

# G.10: Benchmarking Rules

A useful benchmark should:

- Use realistic input sizes.
- Warm up code.
- Run enough iterations.
- Report median and tail latency.
- Avoid excessive logging inside the measured operation.
- Separate setup time from measured time.
- Run on a mostly idle machine.
- Record Node.js or browser version.
- Compare equivalent behavior.
- Repeat the benchmark after changes.

Avoid conclusions such as:

```text
Implementation A is faster because one run took 2 ms.
```

Prefer:

```text
Across 1,000 iterations, Implementation A had:
median: 1.8 ms
p95:    2.4 ms
```

---

# G.11: CPU Profiling with Node.js Inspector

## The Target

We will start a Node.js process with the inspector enabled.

## Concept

CPU profiling records where the process spends execution time.

Use the inspector when you need to identify:

- Hot functions.
- Expensive loops.
- Repeated transformations.
- JSON parsing costs.
- Unexpected synchronous work.
- CPU-heavy callbacks.

## Implementation

### `src/part-4/performance/cpu-work.js`

```js
"use strict";

function calculateDashboardScore(values) {
  let score = 0;

  for (const value of values) {
    score += Math.sqrt(value) * Math.sin(value);
  }

  return score;
}

const values = Array.from(
  { length: 1_000_000 },
  (_, index) => index + 1
);

for (let iteration = 0; iteration < 100; iteration += 1) {
  calculateDashboardScore(values);
}

console.log("calculation complete");
```

## Verification

Start the process:

```bash
node --inspect src/part-4/performance/cpu-work.js
```

Node prints an inspector URL.

Open Chrome and navigate to:

```text
chrome://inspect
```

Choose the Node.js target, open DevTools, and use the **Profiler** or **Performance** tools to record CPU activity.

---

# G.12: CPU Profiling with `--cpu-prof`

Node.js can generate a CPU profile file directly.

Run:

```bash
node --cpu-prof src/part-4/performance/cpu-work.js
```

Node writes a file similar to:

```text
CPU.20260724.120000.12345.0.001.cpuprofile
```

Open the file in Chrome DevTools:

1. Open DevTools.
2. Select **More tools**.
3. Select **JavaScript Profiler**.
4. Load the `.cpuprofile` file.

The profile can show:

- Call hierarchy.
- Self time.
- Total time.
- Hot functions.
- Repeated call paths.

---

# G.13: Self Time Versus Total Time

## Self Time

Self time is time spent directly inside a function, excluding child function calls.

## Total Time

Total time includes:

- Time inside the function.
- Time inside functions called by it.

Example:

```js
function parent() {
  child();
}

function child() {
  expensiveWork();
}
```

If `parent()` has high total time but low self time, `child()` or one of its descendants is probably responsible.

---

# G.14: Flame Graph Interpretation

A flame graph represents call-stack activity.

A wide block usually means:

- The function consumed significant sampled execution time.
- Or many calls passed through that function.

Important considerations:

- Width represents time or samples, not call order.
- A wide parent may simply contain an expensive child.
- Self time helps identify where work is actually performed.
- Short spikes may not matter unless repeated or user-visible.

Look for:

- Wide application functions.
- Repeated serialization.
- Large parsing operations.
- Unexpected logging.
- Repeated selector calculations.
- Render functions called too frequently.

---

# G.15: Node.js `--prof`

Node.js can produce a V8 log:

```bash
node --prof src/part-4/performance/cpu-work.js
```

Process it with:

```bash
node --prof-process isolate-*.log > processed-profile.txt
```

The output can help identify:

- JavaScript hot functions.
- Native runtime work.
- Garbage-collection activity.
- External calls.

The inspector and `--cpu-prof` workflows are usually easier for beginners.

---

# G.16: Event-Loop Delay Monitoring

## The Target

We will monitor event-loop delay in Node.js.

## Concept

Event-loop delay measures how long scheduled work waits before the runtime can execute it.

A high value often indicates:

- Long synchronous loops.
- CPU-heavy JavaScript.
- Large JSON parsing.
- Blocking filesystem calls.
- Excessive garbage collection.
- Native operations delaying callback processing.

## Implementation

### `src/part-4/performance/monitor-event-loop.js`

```js
"use strict";

import {
  monitorEventLoopDelay
} from "node:perf_hooks";

const histogram = monitorEventLoopDelay({
  resolution: 10
});

histogram.enable();

function blockFor(milliseconds) {
  const end = Date.now() + milliseconds;

  while (Date.now() < end) {
    /*
     * Intentional blocking work for diagnostics.
     */
  }
}

setTimeout(() => {
  blockFor(100);
}, 50);

setTimeout(() => {
  histogram.disable();

  console.log({
    minimumMilliseconds: Number(
      histogram.min / 1_000_000
    ).toFixed(2),

    maximumMilliseconds: Number(
      histogram.max / 1_000_000
    ).toFixed(2),

    meanMilliseconds: Number(
      histogram.mean / 1_000_000
    ).toFixed(2),

    p99Milliseconds: Number(
      histogram.percentile(99) / 1_000_000
    ).toFixed(2)
  });
}, 300);
```

## Verification

Run:

```bash
node src/part-4/performance/monitor-event-loop.js
```

Expected output contains a noticeably elevated maximum or percentile value.

---

# G.17: Event-Loop Utilization

Node.js can report event-loop utilization.

## Implementation

### `src/part-4/performance/event-loop-utilization.js`

```js
"use strict";

import {
  performance
} from "node:perf_hooks";

const start = performance.eventLoopUtilization();

const endTime = Date.now() + 100;

while (Date.now() < endTime) {
  /*
   * Intentional CPU work.
   */
}

const result = performance.eventLoopUtilization(
  start
);

console.log({
  utilization: result.utilization,
  activeMilliseconds:
    result.active / 1_000_000,
  idleMilliseconds:
    result.idle / 1_000_000
});
```

## Verification

Run:

```bash
node src/part-4/performance/event-loop-utilization.js
```

A CPU-bound loop should produce high utilization.

Event-loop utilization is useful for understanding whether a Node.js process is:

- Mostly idle and waiting for I/O.
- Frequently occupied by JavaScript or runtime work.
- At risk of becoming CPU-bound.

---

# G.18: Garbage-Collection Diagnostics

## The Target

We will run Node.js with garbage-collection tracing.

## Concept

Garbage-collection logs can reveal:

- How often collection occurs.
- How long collection pauses last.
- Whether the heap is growing.
- Whether major collections reclaim memory.
- Whether allocation pressure is excessive.

## Implementation

### `src/part-4/memory/gc-pressure.js`

```js
"use strict";

const retainedValues = [];

for (let batch = 0; batch < 100; batch += 1) {
  const values = Array.from(
    { length: 10_000 },
    (_, index) => ({
      batch,
      index,
      text: `value-${batch}-${index}`
    })
  );

  if (batch % 10 === 0) {
    /*
     * Retaining some batches simulates a cache or registry that keeps data.
     */
    retainedValues.push(values);
  }
}

console.log({
  retainedBatches: retainedValues.length
});
```

## Verification

Run:

```bash
node --trace-gc src/part-4/memory/gc-pressure.js
```

The output contains runtime-specific garbage-collection information.

Do not interpret one GC event as a problem. Look for patterns:

- Frequent long pauses.
- Heap usage that grows continuously.
- Collections that reclaim very little memory.
- Allocation rates that exceed expected workload.

---

# G.19: Heap Snapshots

## The Target

We will take a heap snapshot of a Node.js process.

## Concept

A heap snapshot records objects currently retained in memory.

Use heap snapshots to investigate:

- Unexpected object growth.
- Retained closures.
- Large arrays.
- Unbounded caches.
- Event listeners.
- Detached application state.
- Duplicate data structures.

## Implementation

### `src/part-4/memory/heap-snapshot.js`

```js
"use strict";

import {
  writeHeapSnapshot
} from "node:v8";

const retainedCache = new Map();

for (let index = 0; index < 10_000; index += 1) {
  retainedCache.set(
    `key-${index}`,
    {
      index,
      data: "x".repeat(1_000)
    }
  );
}

const fileName = writeHeapSnapshot();

console.log({
  fileName,
  cacheSize: retainedCache.size
});
```

## Verification

Run:

```bash
node src/part-4/memory/heap-snapshot.js
```

Node writes a `.heapsnapshot` file.

Open it in Chrome DevTools:

1. Open DevTools.
2. Select the **Memory** panel.
3. Choose **Load profile**.
4. Select the `.heapsnapshot` file.

Look for:

- Large retained objects.
- Dominator trees.
- Retaining paths.
- Multiple copies of expected data.

Heap snapshots can contain sensitive data. Store and share them carefully.

---

# G.20: Heap Snapshot Terminology

## Shallow Size

The memory used directly by an object.

## Retained Size

The memory that could become collectible if the object were released, including objects reachable only through it.

## Retaining Path

The reference chain keeping an object alive.

```text
global registry
  → listener
    → closure
      → payload
```

## Dominator

An object that controls reachability for another group of objects. If the dominator is released, the dominated objects may become collectible.

---

# G.21: Memory Usage Metrics

## Implementation

### `src/part-4/memory/memory-usage.js`

```js
"use strict";

function megabytes(bytes) {
  return Number(
    (bytes / 1024 / 1024).toFixed(2)
  );
}

const memory = process.memoryUsage();

console.log({
  rssMegabytes: megabytes(memory.rss),
  heapTotalMegabytes: megabytes(memory.heapTotal),
  heapUsedMegabytes: megabytes(memory.heapUsed),
  externalMegabytes: megabytes(memory.external),
  arrayBuffersMegabytes: megabytes(
    memory.arrayBuffers
  )
});
```

## Verification

Run:

```bash
node src/part-4/memory/memory-usage.js
```

### Important Fields

- `rss`: Total resident memory held by the process.
- `heapTotal`: Memory reserved for the V8 heap.
- `heapUsed`: Memory currently used in the V8 heap.
- `external`: Memory managed outside the V8 heap but associated with JavaScript objects.
- `arrayBuffers`: Memory used by `ArrayBuffer` and related objects.

A rising `heapUsed` is not automatically a leak. Garbage collection may happen later. Look at trends across a representative workload.

---

# G.22: Detecting Growth Across Repeated Workloads

## The Target

We will sample heap usage after repeated operations.

## Implementation

### `src/part-4/memory/repeated-workload.js`

```js
"use strict";

const cache = new Map();

function megabytes(bytes) {
  return Number(
    (bytes / 1024 / 1024).toFixed(2)
  );
}

function printMemory(label) {
  const memory = process.memoryUsage();

  console.log({
    label,
    heapUsedMegabytes: megabytes(
      memory.heapUsed
    ),
    cacheSize: cache.size
  });
}

function runWorkload(batch) {
  for (let index = 0; index < 10_000; index += 1) {
    cache.set(
      `${batch}-${index}`,
      {
        batch,
        index,
        content: "x".repeat(100)
      }
    );
  }
}

printMemory("initial");

for (let batch = 0; batch < 10; batch += 1) {
  runWorkload(batch);
  printMemory(`after batch ${batch}`);
}
```

## Verification

Run:

```bash
node src/part-4/memory/repeated-workload.js
```

The cache size increases continuously. This does not prove a leak, but it identifies a collection with unbounded growth.

A production cache should define eviction or expiration.

---

# G.23: Sampling Memory Correctly

Memory values fluctuate because of:

- Garbage-collection timing.
- Runtime initialization.
- Allocator behavior.
- Operating-system scheduling.
- Native memory.
- Background tasks.

Use this process:

1. Start from a clean process.
2. Run a representative workload.
3. Record memory over multiple cycles.
4. Allow normal cleanup.
5. Compare after repeated cycles.
6. Take heap snapshots before and after.
7. Inspect retaining paths.

Avoid concluding that a leak exists from two immediate readings.

---

# G.24: Browser Performance Panel

The browser Performance panel can show:

- Main-thread tasks.
- JavaScript execution.
- Layout.
- Style recalculation.
- Paint.
- Composite layers.
- Network activity.
- User interactions.
- Long tasks.
- Animation frames.

## General Workflow

1. Open browser DevTools.
2. Open **Performance**.
3. Start recording.
4. Perform the slow interaction.
5. Stop recording.
6. Inspect long tasks.
7. Expand the call tree.
8. Identify expensive functions.
9. Repeat after changing the code.

Look for:

```text
long JavaScript task
      │
      ├── expensive event handler
      ├── repeated rendering
      ├── layout recalculation
      └── large serialization
```

---

# G.25: Browser Long Tasks

A long task can make an interface feel unresponsive.

Typical causes:

- Large synchronous loops.
- Rendering too much DOM.
- Repeated layout reads and writes.
- Expensive event handlers.
- Large JSON parsing.
- Excessive framework updates.

## Example of Blocking Work

```js
button.addEventListener("click", () => {
  const end = performance.now() + 200;

  while (performance.now() < end) {
    /*
     * Intentional blocking.
     */
  }
});
```

During the loop, input and rendering may be delayed.

---

# G.26: Browser Long Task Observer

## Implementation

### `public/long-task-observer.js`

```js
"use strict";

if (
  typeof PerformanceObserver !== "undefined"
) {
  const observer = new PerformanceObserver(
    (list) => {
      for (const entry of list.getEntries()) {
        console.warn({
          name: entry.name,
          durationMilliseconds: entry.duration,
          startTimeMilliseconds: entry.startTime
        });
      }
    }
  );

  observer.observe({
    type: "longtask",
    buffered: true
  });
}
```

## Verification

Load the script in a browser and perform a long synchronous operation.

Not every browser supports every performance entry type. Check feature availability before relying on it.

---

# G.27: Browser Memory Panel

The browser Memory panel commonly provides:

- Heap snapshots.
- Allocation instrumentation.
- Allocation sampling.

Use heap snapshots to compare object retention before and after an interaction.

Example investigation:

1. Take snapshot A.
2. Open a dashboard component.
3. Close or navigate away.
4. Force a relevant cleanup action.
5. Take snapshot B.
6. Compare retained component objects.

A component that should be gone but remains reachable may indicate:

- Forgotten event listener.
- Unremoved subscription.
- Active timer.
- Global registry reference.
- Closure retaining component state.

---

# G.28: DOM Update Performance

## Problem

Repeated DOM updates can cause unnecessary work:

```js
for (const service of services) {
  container.innerHTML += `
    <div>${service.name}</div>
  `;
}
```

This may repeatedly parse and update the DOM.

## Better Pattern

Build a fragment, then attach once:

```js
const fragment = document.createDocumentFragment();

for (const service of services) {
  const element = document.createElement("div");
  element.textContent = service.name;
  fragment.append(element);
}

container.replaceChildren(fragment);
```

This is not universally faster in every case, so measure with realistic data.

---

# G.29: Layout Thrashing

## The Problem

Alternating layout reads and writes can cause repeated layout calculations.

Potentially expensive:

```js
for (const element of elements) {
  element.style.width =
    `${element.offsetWidth + 10}px`;
}
```

Each read may force the browser to calculate layout after the previous write.

## Better Grouping

Read first:

```js
const widths = elements.map(
  (element) => element.offsetWidth
);
```

Then write:

```js
elements.forEach((element, index) => {
  element.style.width =
    `${widths[index] + 10}px`;
});
```

The browser can often handle grouped reads and writes more efficiently.

---

# G.30: Rendering with `requestAnimationFrame()`

## Implementation

### `public/batched-render.js`

```js
"use strict";

export function createFrameRenderer(render) {
  if (typeof render !== "function") {
    throw new TypeError(
      "render must be a function"
    );
  }

  let frameId = null;
  let latestState;

  function requestRender(state) {
    latestState = state;

    if (frameId !== null) {
      return;
    }

    frameId = requestAnimationFrame(() => {
      frameId = null;

      const stateToRender = latestState;
      latestState = undefined;

      render(stateToRender);
    });
  }

  requestRender.cancel = () => {
    if (frameId !== null) {
      cancelAnimationFrame(frameId);
    }

    frameId = null;
    latestState = undefined;
  };

  return requestRender;
}
```

## Verification

In a browser, call the renderer several times synchronously:

```js
const render = createFrameRenderer((state) => {
  console.log("rendered:", state);
});

render({ count: 1 });
render({ count: 2 });
render({ count: 3 });
```

Only the latest state should be rendered in the scheduled frame.

---

# G.31: Network Performance

Network latency is usually composed of several phases:

```text
DNS lookup
   │
   ▼
connection
   │
   ▼
TLS negotiation
   │
   ▼
request upload
   │
   ▼
server processing
   │
   ▼
response download
   │
   ▼
client parsing
```

The total request duration may hide which phase is slow.

Browser DevTools Network panels can expose:

- Queueing.
- DNS.
- Connection.
- SSL.
- Request sent.
- Waiting for response.
- Content download.

Server-side instrumentation should record:

- Request start.
- Dependency calls.
- Response status.
- Response size.
- Total duration.
- Retry count.
- Circuit state.

---

# G.32: HTTP Request Instrumentation

## Implementation

### `src/part-4/performance/instrumented-fetch.js`

```js
"use strict";

export function createInstrumentedFetch({
  fetchFunction = fetch,
  logger = console
} = {}) {
  if (typeof fetchFunction !== "function") {
    throw new TypeError(
      "fetchFunction must be a function"
    );
  }

  if (typeof logger.info !== "function") {
    throw new TypeError(
      "logger.info must be a function"
    );
  }

  return async function instrumentedFetch(
    input,
    options
  ) {
    const startedAt = performance.now();

    try {
      const response = await fetchFunction(
        input,
        options
      );

      const durationMilliseconds =
        performance.now() - startedAt;

      logger.info("http request completed", {
        url: String(input),
        status: response.status,
        durationMilliseconds: Number(
          durationMilliseconds.toFixed(2)
        )
      });

      return response;
    } catch (error) {
      const durationMilliseconds =
        performance.now() - startedAt;

      logger.info("http request failed", {
        url: String(input),
        errorName: error.name,
        durationMilliseconds: Number(
          durationMilliseconds.toFixed(2)
        )
      });

      throw error;
    }
  };
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createInstrumentedFetch } from "./src/part-4/performance/instrumented-fetch.js";

const request = createInstrumentedFetch({
  fetchFunction: async () => ({
    status: 200
  }),
  logger: {
    info(message, details) {
      console.log(message, details);
    }
  }
});

await request("https://api.example.test/metrics");
EOF
```

Expected output includes a request duration and status.

---

# G.33: Tail Latency

Average latency can hide bad user experiences.

Example:

```text
requests: 100
average:  100 ms
p95:      900 ms
```

Most requests are fast, but some users experience significant delays.

Useful measurements:

- p50: median.
- p90.
- p95.
- p99.
- Maximum.

For resilience work, tail latency is often more important than the average.

---

# G.34: Measuring Retry and Circuit Metrics

A resilient service should expose operational metrics such as:

```js
{
  requestsStarted: 1000,
  requestsSucceeded: 930,
  requestsFailed: 70,
  retries: 120,
  timeouts: 35,
  cancellations: 80,
  circuitOpenCount: 4,
  averageLatencyMilliseconds: 85,
  p95LatencyMilliseconds: 260
}
```

## Implementation

### `src/part-4/resilience/service-metrics.js`

```js
"use strict";

export function createServiceMetrics() {
  const counters = {
    requestsStarted: 0,
    requestsSucceeded: 0,
    requestsFailed: 0,
    retries: 0,
    timeouts: 0,
    cancellations: 0,
    circuitOpenCount: 0
  };

  const durations = [];

  return Object.freeze({
    recordStart() {
      counters.requestsStarted += 1;
    },

    recordSuccess(durationMilliseconds) {
      counters.requestsSucceeded += 1;
      durations.push(durationMilliseconds);
    },

    recordFailure(durationMilliseconds) {
      counters.requestsFailed += 1;
      durations.push(durationMilliseconds);
    },

    recordRetry() {
      counters.retries += 1;
    },

    recordTimeout() {
      counters.timeouts += 1;
    },

    recordCancellation() {
      counters.cancellations += 1;
    },

    recordCircuitOpen() {
      counters.circuitOpenCount += 1;
    },

    snapshot() {
      const sortedDurations = [...durations].sort(
        (first, second) => first - second
      );

      const percentile = (value) => {
        if (sortedDurations.length === 0) {
          return null;
        }

        const index = Math.min(
          sortedDurations.length - 1,
          Math.floor(
            sortedDurations.length * value
          )
        );

        return sortedDurations[index];
      };

      return {
        ...counters,
        averageLatencyMilliseconds:
          durations.length === 0
            ? null
            : durations.reduce(
                (sum, duration) =>
                  sum + duration,
                0
              ) / durations.length,
        p95LatencyMilliseconds: percentile(0.95)
      };
    }
  });
}

const metrics = createServiceMetrics();

metrics.recordStart();
metrics.recordSuccess(40);
metrics.recordRetry();
metrics.recordStart();
metrics.recordFailure(200);
metrics.recordTimeout();

console.log(metrics.snapshot());
```

## Verification

Run:

```bash
node src/part-4/resilience/service-metrics.js
```

Expected output contains request counters and latency metrics.

---

# G.35: Logging Performance

Logging can become a performance problem when:

- Large objects are serialized.
- Logs are written synchronously.
- Logs are emitted inside hot loops.
- Debug logging remains enabled in production.
- Sensitive objects are repeatedly inspected.

Avoid:

```js
for (const item of millionsOfItems) {
  console.log(item);
}
```

Prefer aggregate diagnostics:

```js
console.log({
  processedItems: items.length,
  failures: failures.length,
  durationMilliseconds
});
```

Use log levels:

```js
logger.debug("detailed diagnostic");
logger.info("normal event");
logger.warn("recoverable problem");
logger.error("failure");
```

---

# G.36: Structured Logging

## Implementation

### `src/part-4/app/structured-logger.js`

```js
"use strict";

export function createStructuredLogger({
  output = console,
  minimumLevel = "info"
} = {}) {
  const levels = {
    debug: 10,
    info: 20,
    warn: 30,
    error: 40
  };

  if (!levels[minimumLevel]) {
    throw new RangeError(
      "minimumLevel must be debug, info, warn, or error"
    );
  }

  function write(level, message, details = {}) {
    if (
      levels[level] <
      levels[minimumLevel]
    ) {
      return;
    }

    const entry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...details
    };

    output.log(JSON.stringify(entry));
  }

  return Object.freeze({
    debug(message, details) {
      write("debug", message, details);
    },

    info(message, details) {
      write("info", message, details);
    },

    warn(message, details) {
      write("warn", message, details);
    },

    error(message, details) {
      write("error", message, details);
    }
  });
}

const logger = createStructuredLogger({
  minimumLevel: "info"
});

logger.debug("hidden diagnostic");
logger.info("request completed", {
  service: "metrics",
  durationMilliseconds: 42
});
```

## Verification

Run:

```bash
node src/part-4/app/structured-logger.js
```

The debug message should be filtered while the info message should be emitted.

---

# G.37: Redacting Sensitive Data

Never log:

- Passwords.
- Access tokens.
- Session cookies.
- Private keys.
- Full payment details.
- Authentication headers.

## Implementation

### `src/part-4/app/redact.js`

```js
"use strict";

const sensitiveKeys = new Set([
  "password",
  "token",
  "accessToken",
  "refreshToken",
  "authorization",
  "cookie",
  "secret"
]);

export function redact(
  value,
  seen = new WeakSet()
) {
  if (value === null || typeof value !== "object") {
    return value;
  }

  if (seen.has(value)) {
    return "[Circular]";
  }

  seen.add(value);

  if (Array.isArray(value)) {
    return value.map((item) =>
      redact(item, seen)
    );
  }

  const result = {};

  for (const [key, item] of Object.entries(value)) {
    if (sensitiveKeys.has(key)) {
      result[key] = "[REDACTED]";
    } else {
      result[key] = redact(item, seen);
    }
  }

  return result;
}

console.log(
  redact({
    user: "Ada",
    token: "secret-token",
    nested: {
      password: "secret-password"
    }
  })
);
```

## Verification

Run:

```bash
node src/part-4/app/redact.js
```

Expected output:

```text
{
  user: 'Ada',
  token: '[REDACTED]',
  nested: { password: '[REDACTED]' }
}
```

---

# G.38: Production Profiling Workflow

Use this sequence when investigating a performance issue.

## Step 1: Define the Symptom

Examples:

- Dashboard refresh takes too long.
- Browser input feels delayed.
- Memory grows after navigation.
- API p95 latency is increasing.
- Node.js event-loop delay is high.

## Step 2: Define the Measurement

Choose:

- Duration.
- CPU time.
- Heap usage.
- Event-loop delay.
- Render duration.
- Request latency.
- Allocation rate.
- Retry count.

## Step 3: Reproduce

Use:

- Realistic input size.
- Representative network behavior.
- Repeated workload.
- Same runtime and environment.
- A controlled scenario.

## Step 4: Profile

Use:

- Browser Performance panel.
- Browser Memory panel.
- Node inspector.
- CPU profiles.
- Heap snapshots.
- `monitorEventLoopDelay()`.
- Structured application metrics.

## Step 5: Identify the Bottleneck

Classify it:

```text
CPU
memory
I/O
network
rendering
scheduling
allocation
external dependency
```

## Step 6: Change One Important Variable

Avoid changing several unrelated parts simultaneously.

## Step 7: Re-measure

Compare the same workload before and after.

## Step 8: Add a Regression Check

Add:

- A benchmark.
- A performance assertion.
- A monitoring metric.
- A test for the underlying behavior.

---

# G.39: Avoiding Premature Optimization

Before optimizing, ask:

- Is this operation actually on a hot path?
- Does its duration affect users?
- Is the input size realistic?
- Is the bottleneck local or external?
- Will the optimization increase complexity?
- Can the behavior be measured after deployment?
- Does the change improve average latency or tail latency?
- Does it increase memory usage?

A less elegant optimization that solves a measured bottleneck may be worthwhile. An unmeasured optimization can create complexity without meaningful benefit.

---

# G.40: Performance Budgets

A performance budget defines acceptable limits.

Examples:

```text
dashboard refresh p95:        < 500 ms
initial JavaScript bundle:    < 250 KB compressed
main-thread long task:        < 50 ms
heap after 100 refreshes:     no unbounded growth
error rate:                   < 1%
circuit-open duration:        < 30 seconds
```

Budgets turn vague goals into measurable engineering constraints.

---

# G.41: Performance Regression Test

## Implementation

### `test/part-4/performance-regression.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

function summarizeServices(services) {
  return services.reduce(
    (summary, service) => {
      summary.total += 1;

      if (service.status === "healthy") {
        summary.healthy += 1;
      }

      return summary;
    },
    {
      total: 0,
      healthy: 0
    }
  );
}

test("service summary stays within the performance budget", () => {
  const services = Array.from(
    { length: 10_000 },
    (_, index) => ({
      status:
        index % 2 === 0
          ? "healthy"
          : "unavailable"
    })
  );

  const startedAt = performance.now();

  const result = summarizeServices(services);

  const elapsedMilliseconds =
    performance.now() - startedAt;

  assert.deepEqual(result, {
    total: 10_000,
    healthy: 5_000
  });

  /*
   * This threshold is intentionally generous. Performance assertions should
   * avoid becoming flaky across different development and CI machines.
   */
  assert.ok(
    elapsedMilliseconds < 500,
    `operation took ${elapsedMilliseconds} ms`
  );
});
```

## Verification

Run:

```bash
node --test test/part-4/performance-regression.test.js
```

Use performance tests carefully. A local threshold may not be appropriate for every CI environment.

---

# G.42: Profiling Checklist

## CPU

- Which functions have the highest self time?
- Which functions have the highest total time?
- Are loops processing more data than necessary?
- Is serialization repeated?
- Is logging inside a hot path?
- Can work be batched or moved to a worker?

## Memory

- Does heap usage stabilize after repeated workloads?
- Are listeners and subscriptions removed?
- Are timers cleared?
- Are caches bounded?
- What retaining path keeps large objects alive?
- Are duplicate data structures being created?

## Event Loop

- Is event-loop delay elevated?
- Are there long synchronous tasks?
- Is JSON parsing large?
- Are synchronous Node.js APIs being used?
- Is a microtask or next-tick chain starving tasks?

## Browser Rendering

- Are updates batched?
- Are layout reads and writes interleaved?
- Are too many DOM nodes rendered?
- Are event handlers expensive?
- Are animations using `requestAnimationFrame()`?

## Network

- Is DNS, connection, server processing, or download slow?
- Is retry behavior increasing latency?
- Is a dependency causing tail latency?
- Are requests duplicated?
- Can obsolete requests be cancelled?

---

# G.43: Useful Diagnostic Commands

## Node.js Inspector

```bash
node --inspect src/server.js
```

## Break on First Line

```bash
node --inspect-brk src/server.js
```

## CPU Profile

```bash
node --cpu-prof src/server.js
```

## Garbage Collection Logs

```bash
node --trace-gc src/server.js
```

## Heap Snapshot Signal

Depending on Node.js version and operating-system support:

```bash
node --heapsnapshot-signal=SIGUSR2 src/server.js
```

Then send the signal from another terminal:

```bash
kill -USR2 <process-id>
```

## Trace Events

```bash
node --trace-events-enabled src/server.js
```

Use these diagnostics carefully in production because profiling and tracing may add overhead or expose sensitive information.

---

# G.44: Performance and Privacy

Performance artifacts can contain sensitive information:

- Heap snapshots may contain tokens and user data.
- CPU profiles may contain function names and paths.
- Logs may contain identifiers.
- Network captures may contain request headers.
- Browser recordings may contain page content.

Before sharing diagnostic artifacts:

- Remove credentials.
- Redact personal data.
- Restrict file access.
- Use secure storage.
- Delete artifacts after investigation.
- Avoid profiling production users unnecessarily.

---

# G.45: Final Diagnostic Architecture

A production application should expose several layers of evidence:

```text
user-visible behavior
        │
        ▼
application metrics
latency, failures, retries, queue sizes
        │
        ▼
structured logs
request IDs, service names, error categories
        │
        ▼
runtime diagnostics
CPU, memory, GC, event-loop delay
        │
        ▼
deep profiling
CPU profiles, heap snapshots, browser traces
```

Each layer answers a different question:

| Layer | Question |
|---|---|
| User experience | What does the user feel? |
| Metrics | How often and how severely does it happen? |
| Logs | What happened for this specific operation? |
| Runtime metrics | Is the process CPU-, memory-, or event-loop-bound? |
| Profiles | Which functions or objects are responsible? |

---

# G.46: Final Performance Mental Model

When something is slow, avoid immediately changing code.

Use this sequence:

```text
symptom
  │
  ▼
measurement
  │
  ▼
classification
  ├── CPU
  ├── memory
  ├── I/O
  ├── network
  ├── rendering
  └── scheduling
  │
  ▼
profile
  │
  ▼
targeted change
  │
  ▼
repeat measurement
  │
  ▼
regression protection
```

The strongest performance engineering practice is not memorizing optimization tricks. It is learning to connect user-visible symptoms to measurable runtime behavior.

A reliable investigation should be able to answer:

- What became slow?
- Under what workload?
- For which users or inputs?
- In which runtime?
- How often?
- Which phase consumes the time?
- What retains the memory?
- What changed after the fix?
- How will we know if the problem returns?
