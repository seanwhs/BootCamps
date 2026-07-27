## Primer 0.3: The Async Boundary & Event-Driven Patterns

Welcome to **Primer 0.3**. Modern architectures rely on asynchronous flows—from non-blocking IO and database interactions to cross-context event streaming. This primer builds a solid foundation for handling asynchronous operations, failure propagation, and eventual consistency before we tackle Part 1.

```
┌───────────────────────────────────────────────────────────┐
│                 Asynchronous Seams Toolkit                │
│                                                           │
│  1. Non-Blocking Execution & Event Loop Mental Model      │
│  2. Promises, Async/Await & Cancellation (AbortSignal)    │
│  3. Async Event Emitters & Reactive Pipelines             │
└───────────────────────────────────────────────────────────┘

```

---

### 1. The Non-Blocking Boundary: Macrotasks vs. Microtasks

In JavaScript/TypeScript runtime environments (Node.js/Edge/Browser), single-threaded execution manages concurrency using the **Event Loop**. Understanding task priority prevents hidden latency spikes in asynchronous pipelines.

```
┌───────────────────────────────────────────────────────────┐
│                      Call Stack                           │
└─────────────────────────────┬─────────────────────────────┘
                              │
             ┌────────────────┴────────────────┐
             ▼                                 ▼
   ┌───────────────────┐             ┌───────────────────┐
   │  Microtask Queue  │             │  Macrotask Queue  │
   │ (Promises,        │             │ (setTimeout,      │
   │  queueMicrotask)  │             │  I/O, Timers)     │
   └─────────┬─────────┘             └─────────┬─────────┘
             │                                 │
             └────────► [ Executed First ] ◄───┘

```

#### Why It Matters for Architecture

In architectural patterns like the **Outbox Relay** or **In-Memory Event Bus**, domain events published inside a request cycle run on the **Microtask queue** (via Promises) before macrotasks (like network I/O or timers) execute.

```ts
export function queueDomainTask(taskName: string, action: () => Promise<void>) {
  console.log(`1. Synchronous log: Registering ${taskName}`);

  // Macrotask boundary
  setTimeout(() => {
    console.log(`4. Macrotask: Timer for ${taskName}`);
  }, 0);

  // Microtask boundary
  queueMicrotask(async () => {
    console.log(`3. Microtask: Flushing event for ${taskName}`);
    await action();
  });

  console.log(`2. Synchronous log: Registration complete`);
}

```

---

### 2. Cooperative Cancellation via `AbortSignal`

Long-running asynchronous operations (database queries, external payment requests, or retry loops) must be cancellable when HTTP requests disconnect or timeouts occur. Passing an `AbortSignal` through use-case boundaries ensures your system doesn't waste resources on abandoned operations.

```ts
// core/ordering/application/ports/PaymentGateway.ts
export interface ChargeOptions {
  signal?: AbortSignal;
}

export async function executeChargeWithTimeout(
  chargeFn: (signal: AbortSignal) => Promise<void>,
  timeoutMs: number
): Promise<void> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    await chargeFn(controller.signal);
  } catch (err: unknown) {
    if (err instanceof Error && err.name === "AbortError") {
      throw new Error(`Payment operation timed out after ${timeoutMs}ms`);
    }
    throw err;
  } finally {
    clearTimeout(timer);
  }
}

```

---

### 3. Async Event Emitters & Event-Driven Decoupling

To prevent synchronous coupling across Bounded Contexts (e.g., Ordering directly invoking Inventory or Notifications), we publish asynchronous domain events.

```ts
// core/shared-kernel/events/AsyncEventEmitter.ts
export type EventHandler<T = unknown> = (event: T) => Promise<void>;

export class AsyncEventEmitter {
  private handlers = new Map<string, EventHandler[]>();

  on<T>(eventType: string, handler: EventHandler<T>): void {
    const existing = this.handlers.get(eventType) ?? [];
    this.handlers.set(eventType, [...existing, handler as EventHandler]);
  }

  // Publishes events concurrently without blocking the main execution path
  async emit<T>(eventType: string, payload: T): Promise<void> {
    const handlers = this.handlers.get(eventType) ?? [];
    
    // Execute all subscribers asynchronously using Promise.allSettled
    const results = await Promise.allSettled(
      handlers.map((handler) => handler(payload))
    );

    // Collect errors for inspection without failing the entire batch immediately
    const failures = results.filter((r): r is PromiseRejectedResult => r.status === "rejected");
    if (failures.length > 0) {
      console.error(`[AsyncEventEmitter] ${failures.length} handler(s) failed for ${eventType}`);
    }
  }
}

```

---

### 4. Async Generators & Streaming Data Pipelines

When fetching large datasets across bounded contexts (e.g., auditing order histories or streaming product listings), loading entire arrays into memory causes spikes in memory consumption. **Async Generators** (`async function*`) enable memory-efficient, chunked processing.

```ts
export interface OrderRecord {
  id: string;
  totalCents: number;
}

// Simulated paginated database fetch adapter
export async function* fetchOrdersInBatches(
  pageSize: number
): AsyncGenerator<OrderRecord[], void, unknown> {
  let page = 0;
  let hasMore = true;

  while (hasMore) {
    // Simulate async database query
    const batch = await fakeDbQuery(page, pageSize); 
    if (batch.length === 0) {
      hasMore = false;
      return;
    }
    yield batch;
    page++;
  }
}

async function fakeDbQuery(page: number, size: number): Promise<OrderRecord[]> {
  if (page >= 3) return []; // Stop after 3 pages
  return Array.from({ length: size }, (_, i) => ({
    id: `ord_${page * size + i}`,
    totalCents: 5000,
  }));
}

// Consuming the async stream with `for await...of`
export async function processLargeOrderStream() {
  for await (const batch of fetchOrdersInBatches(50)) {
    console.log(`Processing batch of ${batch.length} orders...`);
  }
}

```

---

### Checkpoint Exercise

1. Implement a function `withTimeout<T>(promise: Promise<T>, ms: number): Promise<T>` using `Promise.race` and a cancellation signal.
2. Build an async event listener for an `OrderPlaced` event that retries up to 3 times before logging a failure.
3. Write an async generator `streamAuditLogs(startDate: Date)` that yields log entries item-by-item without pulling all logs into memory simultaneously.
