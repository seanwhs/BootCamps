# Part 3: Functional Programming & Reactive Patterns

In the previous part, we learned how asynchronous operations are scheduled and coordinated.

Now we will focus on how data moves through an application.

The central question is:

> How can we transform data and update application state without creating confusing hidden behavior?

We will build a small functional and reactive toolkit containing:

- Pure functions.
- Immutable state updates.
- Side-effect boundaries.
- Function composition.
- Currying.
- Partial application.
- Higher-order functions.
- Proxy-based validation.
- Reflect-based property operations.
- Reactive state subscriptions.
- Batched state notifications.
- Derived selectors.

The final code will give us the foundation for the Runtime Monitor application’s state layer.

---

# Part 3.1: Prepare the Part 3 Workspace

## The Target

We will create the directory and add package commands for functional and reactive examples.

## The Concept

Each module should be executable by itself. This makes it easier to verify one idea before combining it with another.

## Implementation

Run:

```bash
mkdir -p src/part-3/functional
mkdir -p src/part-3/reactive
```

Update `package.json`:

### `package.json`

```json
{
  "name": "runtime-monitor",
  "version": "1.0.0",
  "private": true,
  "description": "Advanced JavaScript runtime and architecture learning project",
  "type": "module",
  "scripts": {
    "context": "node src/part-1/execution-contexts.js",
    "hoisting": "node src/part-1/hoisting.js",
    "closures": "node src/part-1/closures.js",
    "this": "node src/part-1/this-binding.js",
    "memory": "node --expose-gc src/part-1/memory-retention.js",
    "event-loop": "node src/part-2/event-loop-order.js",
    "microtasks": "node src/part-2/microtask-starvation.js",
    "concurrency": "node src/part-2/promise-concurrency.js",
    "cancellation": "node src/part-2/cancellation.js",
    "timeout": "node src/part-2/timeout.js",
    "workflow": "node src/part-2/async-workflow.js",
    "pure": "node src/part-3/functional/pure-functions.js",
    "compose": "node src/part-3/functional/compose.js",
    "curry": "node src/part-3/functional/curry.js",
    "immutable": "node src/part-3/functional/immutable.js",
    "proxy": "node src/part-3/reactive/validated-proxy.js",
    "reactive": "node src/part-3/reactive/reactive-state.js",
    "batched-state": "node src/part-3/reactive/batched-state.js",
    "selectors": "node src/part-3/reactive/selectors.js"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## Verification

Run:

```bash
npm run
```

Confirm that the Part 3 commands appear.

---

# Part 3.2: Pure Functions

## The Target

We will create pure data-transformation functions.

## The Concept

A **pure function** has two important properties:

1. The same inputs always produce the same output.
2. It does not change anything outside itself.

A pure function is like a calculator. If you enter `2 + 2`, it should return `4` regardless of what happened in another room.

This function is pure:

```js
function add(first, second) {
  return first + second;
}
```

This function is not pure because it depends on external mutable state:

```js
let taxRate = 0.2;

function calculateTax(price) {
  return price * taxRate;
}
```

The result can change even when the argument stays the same.

## Implementation

### `src/part-3/functional/pure-functions.js`

```js
"use strict";

function calculateTotal(price, quantity, taxRate) {
  if (!Number.isFinite(price) || price < 0) {
    throw new RangeError("price must be a non-negative number");
  }

  if (!Number.isInteger(quantity) || quantity < 0) {
    throw new RangeError("quantity must be a non-negative integer");
  }

  if (!Number.isFinite(taxRate) || taxRate < 0 || taxRate > 1) {
    throw new RangeError("taxRate must be between 0 and 1");
  }

  const subtotal = price * quantity;
  const tax = subtotal * taxRate;

  return {
    subtotal,
    tax,
    total: subtotal + tax
  };
}

function selectHealthyServices(services) {
  if (!Array.isArray(services)) {
    throw new TypeError("services must be an array");
  }

  /*
   * `filter()` creates a new array. It does not modify the input array.
   */
  return services.filter((service) => service.status === "healthy");
}

function calculateAverage(values) {
  if (!Array.isArray(values) || values.length === 0) {
    throw new TypeError("values must be a non-empty array");
  }

  if (!values.every(Number.isFinite)) {
    throw new TypeError("values must contain only finite numbers");
  }

  const total = values.reduce((sum, value) => sum + value, 0);

  return total / values.length;
}

const total = calculateTotal(25, 4, 0.2);

console.log("total calculation:", total);

const services = [
  { name: "metrics", status: "healthy" },
  { name: "health", status: "degraded" },
  { name: "activity", status: "healthy" }
];

const healthyServices = selectHealthyServices(services);

console.log("healthy services:", healthyServices);
console.log("original services:", services);

console.log("average:", calculateAverage([10, 20, 30]));
```

## Verification

Run:

```bash
npm run pure
```

Expected output resembles:

```text
total calculation: { subtotal: 100, tax: 20, total: 120 }
healthy services: [
  { name: 'metrics', status: 'healthy' },
  { name: 'activity', status: 'healthy' }
]
original services: [
  { name: 'metrics', status: 'healthy' },
  { name: 'health', status: 'degraded' },
  { name: 'activity', status: 'healthy' }
]
average: 20
```

The original array remains unchanged.

---

# Part 3.3: Side Effects and Architectural Boundaries

## The Target

We will separate pure formatting logic from an impure logging effect.

## The Concept

A **side effect** is an interaction with the world outside the function.

Examples include:

- Writing to the console.
- Changing the DOM.
- Updating a database.
- Sending a network request.
- Reading the current time.
- Mutating shared state.
- Writing a file.

Side effects are not inherently bad. Applications need them. The problem occurs when side effects are hidden inside transformations that appear to be pure.

A useful design is:

```text
Input data
   │
   ▼
Pure transformation
   │
   ▼
Side effect at the boundary
```

## Implementation

### `src/part-3/functional/side-effects.js`

```js
"use strict";

function formatServiceStatus(service) {
  if (
    service === null ||
    typeof service !== "object" ||
    typeof service.name !== "string" ||
    typeof service.status !== "string"
  ) {
    throw new TypeError("service must contain name and status strings");
  }

  return `${service.name}: ${service.status}`;
}

function createLogger(output = console) {
  if (typeof output.log !== "function") {
    throw new TypeError("output must provide a log function");
  }

  return Object.freeze({
    info(message) {
      output.log(`[INFO] ${message}`);
    }
  });
}

function reportServiceStatus(service, logger) {
  /*
   * Formatting remains pure. Logging is explicitly performed at the boundary.
   */
  const message = formatServiceStatus(service);
  logger.info(message);

  return message;
}

const logger = createLogger();

const service = {
  name: "metrics",
  status: "healthy"
};

const formatted = reportServiceStatus(service, logger);

console.log("returned message:", formatted);
```

## Verification

Run:

```bash
node src/part-3/functional/side-effects.js
```

Expected output:

```text
[INFO] metrics: healthy
returned message: metrics: healthy
```

The formatter can be tested without intercepting console output. The logger can be tested independently with a fake output object.

---

# Part 3.4: Immutability

## The Target

We will update nested application state without mutating the original object.

## The Concept

**Immutability** means treating existing data as fixed and creating a new value when something changes.

This does not mean values can never change. It means we replace the old state instead of modifying it in place.

Imagine a paper document:

- Mutation edits the existing document with an eraser.
- An immutable update creates a revised copy and leaves the old document intact.

Immutable updates make it easier to:

- Compare previous and next state.
- Undo changes.
- Debug transitions.
- Avoid accidental updates.
- Notify subscribers only when a reference changes.

## Implementation

### `src/part-3/functional/immutable.js`

```js
"use strict";

function updateServiceStatus(state, serviceName, status) {
  if (state === null || typeof state !== "object") {
    throw new TypeError("state must be an object");
  }

  if (typeof serviceName !== "string" || serviceName.trim() === "") {
    throw new TypeError("serviceName must be a non-empty string");
  }

  if (typeof status !== "string" || status.trim() === "") {
    throw new TypeError("status must be a non-empty string");
  }

  if (!state.services || typeof state.services !== "object") {
    throw new TypeError("state.services must be an object");
  }

  const existingService = state.services[serviceName];

  if (!existingService) {
    throw new Error(`unknown service: ${serviceName}`);
  }

  return {
    ...state,
    services: {
      ...state.services,
      [serviceName]: {
        ...existingService,
        status
      }
    }
  };
}

function addNotification(state, notification) {
  if (!notification || typeof notification !== "object") {
    throw new TypeError("notification must be an object");
  }

  return {
    ...state,
    notifications: [
      ...(state.notifications ?? []),
      {
        ...notification
      }
    ]
  };
}

const initialState = {
  services: {
    metrics: {
      status: "loading",
      latencyMilliseconds: 0
    },
    health: {
      status: "loading",
      latencyMilliseconds: 0
    }
  },
  notifications: []
};

const healthyState = updateServiceStatus(
  initialState,
  "metrics",
  "healthy"
);

const nextState = addNotification(healthyState, {
  level: "info",
  message: "Metrics service is healthy"
});

console.log("initial state:");
console.dir(initialState, { depth: null });

console.log("\nnext state:");
console.dir(nextState, { depth: null });

console.log("\nreference comparisons:");
console.log("root changed:", initialState !== nextState);
console.log(
  "services changed:",
  initialState.services !== nextState.services
);
console.log(
  "health preserved:",
  initialState.services.health === nextState.services.health
);
console.log(
  "original metrics status:",
  initialState.services.metrics.status
);
```

## Verification

Run:

```bash
npm run immutable
```

Expected output includes:

```text
root changed: true
services changed: true
health preserved: true
original metrics status: loading
```

Only the changed branches need new object references. Unchanged branches can be safely reused.

---

# Part 3.5: Function Composition

## The Target

We will create reusable `compose()` and `pipe()` functions.

## The Concept

A **higher-order function** is a function that:

- Accepts another function as an argument.
- Returns a function.
- Or does both.

Function composition combines small functions into a larger operation.

Suppose we have:

```js
trim
toLowerCase
addPrefix
```

A pipeline can connect them:

```text
input
  → trim
  → lowercase
  → prefix
  → output
```

There are two common directions:

- `pipe()` runs left to right.
- `compose()` traditionally runs right to left.

## Implementation

### `src/part-3/functional/compose.js`

```js
"use strict";

function assertFunctions(functions) {
  if (!functions.every((candidate) => typeof candidate === "function")) {
    throw new TypeError("all arguments must be functions");
  }
}

export function pipe(...functions) {
  assertFunctions(functions);

  return function pipedValue(initialValue) {
    return functions.reduce(
      (value, currentFunction) => currentFunction(value),
      initialValue
    );
  };
}

export function compose(...functions) {
  assertFunctions(functions);

  return function composedValue(initialValue) {
    return functions.reduceRight(
      (value, currentFunction) => currentFunction(value),
      initialValue
    );
  };
}

const normalizeServiceName = pipe(
  (value) => value.trim(),
  (value) => value.toLowerCase(),
  (value) => value.replaceAll(" ", "-"),
  (value) => `service:${value}`
);

console.log(normalizeServiceName("  Metrics API  "));

const double = (value) => value * 2;
const addOne = (value) => value + 1;

const leftToRight = pipe(double, addOne);
const rightToLeft = compose(double, addOne);

console.log("pipe result:", leftToRight(3));
console.log("compose result:", rightToLeft(3));
```

## Verification

Run:

```bash
npm run compose
```

Expected output:

```text
service:metrics-api
pipe result: 7
compose result: 8
```

Why?

```text
pipe(double, addOne)(3)
→ double(3)
→ addOne(6)
→ 7
```

```text
compose(double, addOne)(3)
→ addOne(3)
→ double(4)
→ 8
```

---

# Part 3.6: Asynchronous Function Composition

## The Target

We will create a pipeline that supports asynchronous functions.

## The Concept

Normal composition assumes each function returns an immediate value.

Asynchronous functions return promises, so the next function must wait for the previous result.

The pipeline becomes:

```text
value
  → await function A
  → await function B
  → await function C
```

## Implementation

### `src/part-3/functional/async-pipe.js`

```js
"use strict";

export function asyncPipe(...functions) {
  if (!functions.every((candidate) => typeof candidate === "function")) {
    throw new TypeError("all arguments must be functions");
  }

  return async function runAsyncPipe(initialValue) {
    let value = initialValue;

    for (const currentFunction of functions) {
      value = await currentFunction(value);
    }

    return value;
  };
}

const loadRawService = async (name) => ({
  name,
  status: "healthy",
  latency: 42
});

const addDisplayLabel = async (service) => ({
  ...service,
  label: `${service.name} (${service.status})`
});

const selectPublicFields = async (service) => ({
  label: service.label,
  latency: service.latency
});

const createServiceView = asyncPipe(
  loadRawService,
  addDisplayLabel,
  selectPublicFields
);

console.log(await createServiceView("metrics"));
```

## Verification

Run:

```bash
node src/part-3/functional/async-pipe.js
```

Expected output:

```text
{ label: 'metrics (healthy)', latency: 42 }
```

---

# Part 3.7: Currying

## The Target

We will create a generic curry utility.

## The Concept

**Currying** transforms a function that accepts several arguments into a sequence of functions that each accept one or more arguments.

This:

```js
function addTax(price, taxRate) {
  return price + price * taxRate;
}
```

can become:

```js
const calculateWithTwentyPercentTax = curry(addTax)(0.2);

calculateWithTwentyPercentTax(100);
```

Currying is useful when one parameter is known earlier than another.

For example, the application may know the tax rate during configuration but receive prices later.

## Implementation

### `src/part-3/functional/curry.js`

```js
"use strict";

export function curry(functionToCurry, expectedArgumentCount) {
  if (typeof functionToCurry !== "function") {
    throw new TypeError("functionToCurry must be a function");
  }

  const requiredArguments =
    expectedArgumentCount ?? functionToCurry.length;

  if (!Number.isInteger(requiredArguments) || requiredArguments < 0) {
    throw new RangeError(
      "expectedArgumentCount must be a non-negative integer"
    );
  }

  function collectArguments(previousArguments) {
    return function curriedFunction(...nextArguments) {
      const allArguments = [...previousArguments, ...nextArguments];

      if (allArguments.length >= requiredArguments) {
        return functionToCurry(...allArguments);
      }

      return collectArguments(allArguments);
    };
  }

  return collectArguments([]);
}

function createRequestUrl(baseUrl, path, query) {
  const url = new URL(path, baseUrl);

  for (const [key, value] of Object.entries(query)) {
    url.searchParams.set(key, String(value));
  }

  return url.toString();
}

const curriedRequestUrl = curry(createRequestUrl);

const withApiBase = curriedRequestUrl("https://api.example.test/");
const withMetricsPath = withApiBase("metrics");

console.log(
  withMetricsPath({
    region: "us-east",
    limit: 10
  })
);

const add = curry((first, second, third) => first + second + third);

console.log(add(1)(2)(3));
console.log(add(1, 2)(3));
console.log(add(1)(2, 3));
```

## Verification

Run:

```bash
npm run curry
```

Expected output:

```text
https://api.example.test/metrics?region=us-east&limit=10
6
6
6
```

This implementation supports one or multiple arguments at each step.

---

# Part 3.8: Partial Application

## The Target

We will create a `partial()` utility.

## The Concept

**Partial application** fixes some arguments now and returns a function that accepts the remaining arguments later.

Currying and partial application are related but not identical:

- Currying transforms one multi-argument function into chained calls.
- Partial application pre-fills selected arguments.

## Implementation

### `src/part-3/functional/partial.js`

```js
"use strict";

export function partial(functionToPartiallyApply, ...presetArguments) {
  if (typeof functionToPartiallyApply !== "function") {
    throw new TypeError("functionToPartiallyApply must be a function");
  }

  return function partiallyApplied(...remainingArguments) {
    return functionToPartiallyApply(
      ...presetArguments,
      ...remainingArguments
    );
  };
}

function createLogMessage(serviceName, level, message) {
  return `[${level}] [${serviceName}] ${message}`;
}

const createMetricsInfoMessage = partial(
  createLogMessage,
  "metrics",
  "INFO"
);

console.log(
  createMetricsInfoMessage("request completed")
);

const createHealthErrorMessage = partial(
  createLogMessage,
  "health",
  "ERROR"
);

console.log(
  createHealthErrorMessage("request failed")
);
```

## Verification

Run:

```bash
node src/part-3/functional/partial.js
```

Expected output:

```text
[INFO] [metrics] request completed
[ERROR] [health] request failed
```

---

# Part 3.9: Metaprogramming with `Proxy`

## The Target

We will create a validated object using `Proxy`.

## The Concept

A **proxy** is an object placed in front of another object.

It can intercept operations such as:

- Reading a property.
- Writing a property.
- Deleting a property.
- Checking whether a property exists.
- Calling a function.
- Constructing an object.

The original object is called the **target**.

A proxy is like a security desk in front of an office. Visitors still want to access rooms, but the desk can inspect and approve requests first.

## Implementation

### `src/part-3/reactive/validated-proxy.js`

```js
"use strict";

const serviceStatuses = new Set([
  "loading",
  "healthy",
  "degraded",
  "unavailable"
]);

function createValidatedService(initialService) {
  if (
    initialService === null ||
    typeof initialService !== "object"
  ) {
    throw new TypeError("initialService must be an object");
  }

  const target = {
    name: initialService.name,
    status: initialService.status,
    latencyMilliseconds: initialService.latencyMilliseconds
  };

  return new Proxy(target, {
    set(object, property, value, receiver) {
      if (property === "name") {
        if (typeof value !== "string" || value.trim() === "") {
          throw new TypeError("name must be a non-empty string");
        }

        return Reflect.set(
          object,
          property,
          value.trim(),
          receiver
        );
      }

      if (property === "status") {
        if (!serviceStatuses.has(value)) {
          throw new RangeError(
            `status must be one of: ${[...serviceStatuses].join(", ")}`
          );
        }
      }

      if (property === "latencyMilliseconds") {
        if (
          !Number.isFinite(value) ||
          value < 0
        ) {
          throw new RangeError(
            "latencyMilliseconds must be a non-negative number"
          );
        }
      }

      /*
       * Reflect.set performs the normal property assignment while preserving
       * JavaScript's receiver and prototype behavior.
       */
      return Reflect.set(object, property, value, receiver);
    },

    deleteProperty() {
      throw new Error("service properties cannot be deleted");
    }
  });
}

const service = createValidatedService({
  name: "metrics",
  status: "loading",
  latencyMilliseconds: 0
});

service.status = "healthy";
service.latencyMilliseconds = 42;

console.log("valid service:", service);

try {
  service.status = "unknown";
} catch (error) {
  console.log("invalid status:", error.message);
}

try {
  service.latencyMilliseconds = -1;
} catch (error) {
  console.log("invalid latency:", error.message);
}

try {
  delete service.name;
} catch (error) {
  console.log("invalid deletion:", error.message);
}
```

## Verification

Run:

```bash
npm run proxy
```

Expected output resembles:

```text
valid service: {
  name: 'metrics',
  status: 'healthy',
  latencyMilliseconds: 42
}
invalid status: status must be one of: loading, healthy, degraded, unavailable
invalid latency: latencyMilliseconds must be a non-negative number
invalid deletion: service properties cannot be deleted
```

---

# Part 3.10: Why `Reflect` Matters

## The Target

We will compare direct operations with `Reflect`.

## The Concept

`Reflect` provides methods corresponding to many internal object operations.

Examples include:

```js
Reflect.get(target, property, receiver);
Reflect.set(target, property, value, receiver);
Reflect.has(target, property);
Reflect.deleteProperty(target, property);
```

Using `Reflect` inside proxy traps is generally safer than manually reproducing ordinary object behavior.

For example, this is incomplete:

```js
set(target, property, value) {
  target[property] = value;
  return true;
}
```

It ignores the receiver and can behave incorrectly with inherited setters or special objects.

This is more faithful:

```js
set(target, property, value, receiver) {
  return Reflect.set(target, property, value, receiver);
}
```

## Implementation

### `src/part-3/reactive/reflect-demo.js`

```js
"use strict";

const target = {
  value: 10
};

const proxy = new Proxy(target, {
  get(object, property, receiver) {
    console.log(`reading property: ${String(property)}`);
    return Reflect.get(object, property, receiver);
  },

  set(object, property, value, receiver) {
    console.log(
      `writing property: ${String(property)} = ${String(value)}`
    );

    return Reflect.set(object, property, value, receiver);
  },

  has(object, property) {
    console.log(`checking property: ${String(property)}`);
    return Reflect.has(object, property);
  }
});

console.log(proxy.value);

proxy.value = 20;

console.log("value" in proxy);
console.log(proxy.value);
```

## Verification

Run:

```bash
node src/part-3/reactive/reflect-demo.js
```

Expected output:

```text
reading property: value
10
writing property: value = 20
checking property: value
true
reading property: value
20
```

---

# Part 3.11: Build a Reactive State Object

## The Target

We will build a state object that notifies subscribers when properties change.

## The Concept

**Reactive state** means that other parts of an application can respond when state changes.

A simple reactive system contains:

1. A state object.
2. A set of subscribers.
3. A way to detect changes.
4. A way to notify subscribers.
5. A cleanup function for removing subscriptions.

The proxy detects writes. The subscription set receives notifications.

The important lifecycle rule is:

> Every subscription must be removable.

Otherwise, old screens or components can remain in memory.

## Implementation

### `src/part-3/reactive/reactive-state.js`

```js
"use strict";

export function createReactiveState(initialState) {
  if (
    initialState === null ||
    typeof initialState !== "object" ||
    Array.isArray(initialState)
  ) {
    throw new TypeError("initialState must be a plain object");
  }

  const target = { ...initialState };
  const subscribers = new Set();

  let isDestroyed = false;

  function notify(change) {
    for (const subscriber of subscribers) {
      try {
        subscriber(change);
      } catch (error) {
        /*
         * One broken subscriber should not prevent other subscribers from
         * receiving the state change.
         */
        console.error("reactive subscriber failed:", error);
      }
    }
  }

  const state = new Proxy(target, {
    get(object, property, receiver) {
      if (property === "subscribe") {
        return function subscribe(subscriber) {
          if (isDestroyed) {
            throw new Error("cannot subscribe to destroyed state");
          }

          if (typeof subscriber !== "function") {
            throw new TypeError("subscriber must be a function");
          }

          subscribers.add(subscriber);

          /*
           * Returning an unsubscribe function makes ownership explicit.
           */
          return () => {
            subscribers.delete(subscriber);
          };
        };
      }

      if (property === "destroy") {
        return function destroy() {
          isDestroyed = true;
          subscribers.clear();
        };
      }

      return Reflect.get(object, property, receiver);
    },

    set(object, property, value, receiver) {
      if (isDestroyed) {
        throw new Error("cannot update destroyed state");
      }

      const previousValue = Reflect.get(object, property, receiver);

      if (Object.is(previousValue, value)) {
        return true;
      }

      const didSet = Reflect.set(object, property, value, receiver);

      if (didSet) {
        notify({
          property,
          previousValue,
          nextValue: value,
          state
        });
      }

      return didSet;
    }
  });

  return state;
}

const state = createReactiveState({
  status: "idle",
  requestCount: 0
});

const unsubscribe = state.subscribe((change) => {
  console.log("state changed:", {
    property: change.property,
    previousValue: change.previousValue,
    nextValue: change.nextValue
  });
});

state.status = "loading";
state.requestCount = 1;

unsubscribe();

state.status = "healthy";

state.destroy();

try {
  state.status = "unavailable";
} catch (error) {
  console.log("destroyed state error:", error.message);
}
```

## Verification

Run:

```bash
npm run reactive
```

Expected behavior:

- The first two writes notify the subscriber.
- The write after `unsubscribe()` produces no subscriber output.
- Updating destroyed state throws an error.

---

# Part 3.12: Deep Reactive State

## The Target

We will make nested objects reactive.

## The Concept

A proxy only intercepts operations on the object it directly wraps.

This proxy:

```js
const state = new Proxy(
  { service: { status: "loading" } },
  handlers
);
```

does not automatically observe:

```js
state.service.status = "healthy";
```

because `state.service` returns the original nested object.

To support nested reactivity, we need to recursively wrap nested objects.

We will also cache proxies in a `WeakMap`.

A `WeakMap` is useful because it does not keep its object keys alive solely through the map. This helps avoid unnecessary retention.

## Implementation

### `src/part-3/reactive/deep-reactive.js`

```js
"use strict";

export function createDeepReactiveState(initialValue, onChange) {
  if (typeof onChange !== "function") {
    throw new TypeError("onChange must be a function");
  }

  const proxyCache = new WeakMap();

  function isObject(value) {
    return value !== null && typeof value === "object";
  }

  function wrap(value, path = []) {
    if (!isObject(value)) {
      return value;
    }

    if (proxyCache.has(value)) {
      return proxyCache.get(value);
    }

    const proxy = new Proxy(value, {
      get(target, property, receiver) {
        const result = Reflect.get(target, property, receiver);

        return isObject(result)
          ? wrap(result, [...path, property])
          : result;
      },

      set(target, property, nextValue, receiver) {
        const previousValue = Reflect.get(target, property, receiver);

        if (Object.is(previousValue, nextValue)) {
          return true;
        }

        const didSet = Reflect.set(
          target,
          property,
          nextValue,
          receiver
        );

        if (didSet) {
          onChange({
            path: [...path, property],
            previousValue,
            nextValue
          });
        }

        return didSet;
      },

      deleteProperty(target, property) {
        if (!Reflect.has(target, property)) {
          return true;
        }

        const previousValue = Reflect.get(target, property);
        const didDelete = Reflect.deleteProperty(target, property);

        if (didDelete) {
          onChange({
            path: [...path, property],
            previousValue,
            nextValue: undefined,
            deleted: true
          });
        }

        return didDelete;
      }
    });

    proxyCache.set(value, proxy);
    return proxy;
  }

  return wrap(initialValue);
}

const state = createDeepReactiveState(
  {
    dashboard: {
      status: "loading",
      metrics: {
        requestsPerSecond: 0
      }
    }
  },
  (change) => {
    console.log("change:", {
      path: change.path.map(String).join("."),
      previousValue: change.previousValue,
      nextValue: change.nextValue
    });
  }
);

state.dashboard.status = "healthy";
state.dashboard.metrics.requestsPerSecond = 125;
delete state.dashboard.metrics.requestsPerSecond;
```

## Verification

Run:

```bash
node src/part-3/reactive/deep-reactive.js
```

Expected output includes paths similar to:

```text
change: {
  path: 'dashboard.status',
  previousValue: 'loading',
  nextValue: 'healthy'
}
change: {
  path: 'dashboard.metrics.requestsPerSecond',
  previousValue: 0,
  nextValue: 125
}
change: {
  path: 'dashboard.metrics.requestsPerSecond',
  previousValue: 125,
  nextValue: undefined
}
```

---

# Part 3.13: Batching Reactive Notifications

## The Target

We will batch several synchronous state changes into one notification.

## The Concept

Suppose a dashboard refresh updates five fields:

```js
state.status = "healthy";
state.latency = 42;
state.lastUpdated = Date.now();
state.error = null;
```

Immediate notification may cause four separate renders.

**Batching** collects changes and schedules one notification for later.

We will use a microtask for batching:

- The first change schedules a flush.
- Later synchronous changes join the same batch.
- The microtask runs after the current synchronous code.
- Subscribers receive all changes together.

## Implementation

### `src/part-3/reactive/batched-state.js`

```js
"use strict";

export function createBatchedState(initialState) {
  if (
    initialState === null ||
    typeof initialState !== "object" ||
    Array.isArray(initialState)
  ) {
    throw new TypeError("initialState must be a plain object");
  }

  const target = { ...initialState };
  const subscribers = new Set();
  const pendingChanges = [];

  let flushScheduled = false;

  function scheduleFlush() {
    if (flushScheduled) {
      return;
    }

    flushScheduled = true;

    queueMicrotask(() => {
      flushScheduled = false;

      if (pendingChanges.length === 0) {
        return;
      }

      const changes = pendingChanges.splice(0);

      for (const subscriber of subscribers) {
        try {
          subscriber(changes);
        } catch (error) {
          console.error("batched subscriber failed:", error);
        }
      }
    });
  }

  const state = new Proxy(target, {
    get(object, property, receiver) {
      if (property === "subscribe") {
        return (subscriber) => {
          if (typeof subscriber !== "function") {
            throw new TypeError("subscriber must be a function");
          }

          subscribers.add(subscriber);

          return () => {
            subscribers.delete(subscriber);
          };
        };
      }

      return Reflect.get(object, property, receiver);
    },

    set(object, property, value, receiver) {
      const previousValue = Reflect.get(object, property, receiver);

      if (Object.is(previousValue, value)) {
        return true;
      }

      const didSet = Reflect.set(object, property, value, receiver);

      if (didSet) {
        pendingChanges.push({
          property,
          previousValue,
          nextValue: value
        });

        scheduleFlush();
      }

      return didSet;
    }
  });

  return state;
}

const state = createBatchedState({
  status: "idle",
  requestCount: 0,
  error: null
});

state.subscribe((changes) => {
  console.log("one batched notification:");
  console.dir(changes, { depth: null });
});

state.status = "loading";
state.requestCount = 1;
state.error = null;

console.log("synchronous updates finished");
```

## Verification

Run:

```bash
npm run batched-state
```

Expected order:

```text
synchronous updates finished
one batched notification:
[ ... ]
```

The notification runs after the synchronous assignments because it was scheduled as a microtask.

---

# Part 3.14: Derived State and Selectors

## The Target

We will build selector functions that derive values from application state.

## The Concept

A **selector** reads state and calculates a value needed by another part of the application.

Examples:

- Count healthy services.
- Calculate average latency.
- Select visible notifications.
- Determine whether the dashboard is loading.
- Format a summary for the UI.

Selectors should usually be pure. They should calculate without changing state.

## Implementation

### `src/part-3/reactive/selectors.js`

```js
"use strict";

function selectHealthyServices(state) {
  return Object.values(state.services).filter(
    (service) => service.status === "healthy"
  );
}

function selectAverageLatency(state) {
  const services = Object.values(state.services);

  const measuredServices = services.filter(
    (service) => Number.isFinite(service.latencyMilliseconds)
  );

  if (measuredServices.length === 0) {
    return null;
  }

  const total = measuredServices.reduce(
    (sum, service) => sum + service.latencyMilliseconds,
    0
  );

  return total / measuredServices.length;
}

function selectDashboardSummary(state) {
  const services = Object.values(state.services);

  return {
    totalServices: services.length,
    healthyServices: selectHealthyServices(state).length,
    averageLatencyMilliseconds: selectAverageLatency(state),
    hasErrors: services.some(
      (service) => service.status === "unavailable"
    )
  };
}

const state = {
  services: {
    metrics: {
      status: "healthy",
      latencyMilliseconds: 40
    },
    health: {
      status: "healthy",
      latencyMilliseconds: 20
    },
    activity: {
      status: "unavailable",
      latencyMilliseconds: 120
    }
  }
};

console.log("healthy services:", selectHealthyServices(state));
console.log("average latency:", selectAverageLatency(state));
console.log("summary:", selectDashboardSummary(state));
```

## Verification

Run:

```bash
npm run selectors
```

Expected output includes:

```text
average latency: 60
summary: {
  totalServices: 3,
  healthyServices: 2,
  averageLatencyMilliseconds: 60,
  hasErrors: true
}
```

---

# Part 3.15: Memoized Selectors

## The Target

We will avoid repeating a derived calculation when the same input reference is used.

## The Concept

**Memoization** stores a previous result and reuses it when the inputs have not changed.

A simple memoized selector can remember:

- The last state reference.
- The last calculated result.

This works well with immutable state because unchanged state can preserve object references.

## Implementation

### `src/part-3/reactive/memoize-selector.js`

```js
"use strict";

export function memoizeSelector(selector) {
  if (typeof selector !== "function") {
    throw new TypeError("selector must be a function");
  }

  let hasCachedResult = false;
  let previousInput;
  let previousResult;

  return function memoizedSelector(input) {
    if (hasCachedResult && Object.is(previousInput, input)) {
      return previousResult;
    }

    previousInput = input;
    previousResult = selector(input);
    hasCachedResult = true;

    return previousResult;
  };
}

const selectServiceNames = memoizeSelector((state) => {
  console.log("calculating service names");

  return Object.keys(state.services);
});

const firstState = {
  services: {
    metrics: {},
    health: {}
  }
};

const secondState = {
  ...firstState,
  otherValue: true
};

console.log(selectServiceNames(firstState));
console.log(selectServiceNames(firstState));
console.log(selectServiceNames(secondState));
```

## Verification

Run:

```bash
node src/part-3/reactive/memoize-selector.js
```

Expected output:

```text
calculating service names
[ 'metrics', 'health' ]
[ 'metrics', 'health' ]
calculating service names
[ 'metrics', 'health' ]
```

The second call with the same object reference reuses the result.

---

# Part 3.16: A Complete Reactive Dashboard Store

## The Target

We will combine immutable-style actions, reactive notifications, and selectors into a small application store.

## The Concept

A **store** is an object responsible for:

- Holding application state.
- Applying state transitions.
- Notifying subscribers.
- Exposing read-only access.
- Managing cleanup.

We will keep state transitions centralized in reducer-like functions.

A **reducer** is a function that receives the current state and an action, then returns the next state.

```js
nextState = reducer(currentState, action);
```

The reducer should be pure. The store handles mutation of its internal current-state reference and subscriber notification.

## Implementation

### `src/part-3/reactive/dashboard-store.js`

```js
"use strict";

function createInitialState() {
  return {
    services: {},
    isRefreshing: false,
    lastUpdated: null,
    notifications: []
  };
}

function dashboardReducer(state, action) {
  switch (action.type) {
    case "REFRESH_STARTED":
      return {
        ...state,
        isRefreshing: true
      };

    case "SERVICE_UPDATED": {
      const { serviceName, service } = action;

      return {
        ...state,
        services: {
          ...state.services,
          [serviceName]: {
            ...service
          }
        }
      };
    }

    case "REFRESH_FINISHED":
      return {
        ...state,
        isRefreshing: false,
        lastUpdated: action.timestamp
      };

    case "NOTIFICATION_ADDED":
      return {
        ...state,
        notifications: [
          ...state.notifications,
          {
            id: action.id,
            level: action.level,
            message: action.message
          }
        ]
      };

    case "NOTIFICATIONS_CLEARED":
      return {
        ...state,
        notifications: []
      };

    default:
      throw new Error(`unknown action type: ${action.type}`);
  }
}

export function createDashboardStore() {
  let currentState = createInitialState();
  const subscribers = new Set();

  function getState() {
    return currentState;
  }

  function subscribe(subscriber) {
    if (typeof subscriber !== "function") {
      throw new TypeError("subscriber must be a function");
    }

    subscribers.add(subscriber);

    return () => {
      subscribers.delete(subscriber);
    };
  }

  function dispatch(action) {
    if (
      action === null ||
      typeof action !== "object" ||
      typeof action.type !== "string"
    ) {
      throw new TypeError("action must contain a string type");
    }

    const previousState = currentState;
    const nextState = dashboardReducer(currentState, action);

    if (Object.is(previousState, nextState)) {
      return nextState;
    }

    currentState = nextState;

    for (const subscriber of subscribers) {
      try {
        subscriber(currentState, previousState, action);
      } catch (error) {
        console.error("store subscriber failed:", error);
      }
    }

    return currentState;
  }

  return Object.freeze({
    getState,
    subscribe,
    dispatch
  });
}

const store = createDashboardStore();

const unsubscribe = store.subscribe(
  (nextState, previousState, action) => {
    console.log("action:", action.type);
    console.log("state changed:", previousState !== nextState);
  }
);

store.dispatch({
  type: "REFRESH_STARTED"
});

store.dispatch({
  type: "SERVICE_UPDATED",
  serviceName: "metrics",
  service: {
    status: "healthy",
    latencyMilliseconds: 42
  }
});

store.dispatch({
  type: "NOTIFICATION_ADDED",
  id: "notification-1",
  level: "info",
  message: "Metrics service is healthy"
});

store.dispatch({
  type: "REFRESH_FINISHED",
  timestamp: new Date().toISOString()
});

console.dir(store.getState(), { depth: null });

unsubscribe();
```

## Verification

Run:

```bash
node src/part-3/reactive/dashboard-store.js
```

Expected behavior:

- Each dispatch changes the state.
- The subscriber sees the action type.
- `getState()` returns the latest state.
- Calling the returned unsubscribe function removes the subscriber.

---

# Part 3.17: Functional Error Handling

## The Target

We will represent success and failure as values instead of throwing at every transformation step.

## The Concept

A common functional pattern is to use a result object:

```js
{
  ok: true,
  value: ...
}
```

or:

```js
{
  ok: false,
  error: ...
}
```

This can be useful when a workflow expects validation failures as part of normal control flow.

Exceptions remain appropriate for unexpected programming errors and failures that should escape the current boundary.

## Implementation

### `src/part-3/functional/result.js`

```js
"use strict";

export function success(value) {
  return Object.freeze({
    ok: true,
    value
  });
}

export function failure(error) {
  if (!(error instanceof Error)) {
    throw new TypeError("error must be an Error");
  }

  return Object.freeze({
    ok: false,
    error
  });
}

export function mapResult(result, transform) {
  if (typeof transform !== "function") {
    throw new TypeError("transform must be a function");
  }

  if (!result.ok) {
    return result;
  }

  return success(transform(result.value));
}

export function flatMapResult(result, transform) {
  if (typeof transform !== "function") {
    throw new TypeError("transform must be a function");
  }

  if (!result.ok) {
    return result;
  }

  return transform(result.value);
}

function parsePositiveInteger(value) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return failure(new Error("value must be a positive integer"));
  }

  return success(parsed);
}

function createLimitQuery(limit) {
  return success({
    limit,
    endpoint: `/metrics?limit=${limit}`
  });
}

const result = flatMapResult(
  parsePositiveInteger("25"),
  createLimitQuery
);

console.log(result);

const invalidResult = flatMapResult(
  parsePositiveInteger("not-a-number"),
  createLimitQuery
);

console.log({
  ok: invalidResult.ok,
  error: invalidResult.ok ? null : invalidResult.error.message
});
```

## Verification

Run:

```bash
node src/part-3/functional/result.js
```

Expected output resembles:

```text
{ ok: true, value: { limit: 25, endpoint: '/metrics?limit=25' } }
{ ok: false, error: 'value must be a positive integer' }
```

---

# Part 3.18: Reference — Functional Programming Vocabulary

## Pure Function

A function with deterministic output and no external mutation.

## Immutability

Creating replacement values instead of changing existing values in place.

## Higher-Order Function

A function that accepts or returns another function.

Examples:

```js
array.map(transform);
array.filter(predicate);
array.reduce(reducer, initialValue);
```

## Composition

Combining functions so the output of one becomes the input of another.

## Currying

Transforming:

```js
f(a, b, c)
```

into:

```js
f(a)(b)(c)
```

## Partial Application

Pre-filling some arguments:

```js
const specialized = partial(generalFunction, fixedArgument);
```

## Referential Transparency

An expression is referentially transparent when it can be replaced by its result without changing program behavior.

This is easier when functions are pure.

---

# Part 3.19: Reference — Proxy Traps

Common proxy traps include:

| Trap | Intercepts |
|---|---|
| `get` | Reading a property |
| `set` | Assigning a property |
| `has` | The `in` operator |
| `deleteProperty` | `delete object[property]` |
| `ownKeys` | `Object.keys()` and related operations |
| `getOwnPropertyDescriptor` | Property descriptor lookup |
| `apply` | Calling a proxied function |
| `construct` | Calling a proxied constructor with `new` |

A proxy should preserve normal object invariants. For example, it should not claim that a non-configurable property was deleted when JavaScript forbids that operation.

Use `Reflect` to delegate ordinary behavior whenever possible.

---

# Part 3.20: Reference — Reactive System Design Rules

## Notify Only on Actual Changes

Avoid notifying when a value is unchanged:

```js
if (Object.is(previousValue, nextValue)) {
  return true;
}
```

## Return Unsubscribe Functions

```js
const unsubscribe = state.subscribe(listener);

unsubscribe();
```

## Protect Subscribers from One Another

A broken subscriber should not prevent all other subscribers from receiving updates.

Use isolated error handling:

```js
for (const subscriber of subscribers) {
  try {
    subscriber(change);
  } catch (error) {
    console.error(error);
  }
}
```

## Batch Frequent Changes

Use a microtask or another scheduler to combine synchronous updates.

## Keep Selectors Pure

Selectors should calculate values without dispatching actions or changing state.

## Avoid Deep Proxy Work Unless Needed

Deep proxies can add complexity and overhead. For some applications, immutable updates plus shallow comparison are simpler and faster.

---

# Part 3.21: Complete Verification Checklist

Run:

```bash
npm run pure
node src/part-3/functional/side-effects.js
npm run immutable
npm run compose
node src/part-3/functional/async-pipe.js
npm run curry
node src/part-3/functional/partial.js
npm run proxy
node src/part-3/reactive/reflect-demo.js
npm run reactive
node src/part-3/reactive/deep-reactive.js
npm run batched-state
npm run selectors
node src/part-3/reactive/memoize-selector.js
node src/part-3/reactive/dashboard-store.js
node src/part-3/functional/result.js
```

Confirm that:

- Pure functions return deterministic results.
- Side effects occur at explicit boundaries.
- Immutable updates preserve the old state.
- Composition creates predictable pipelines.
- Async pipelines await each stage.
- Curried functions accept arguments incrementally.
- Partial application creates specialized functions.
- Proxies validate assignments.
- Reflect delegates ordinary object behavior.
- Reactive subscribers receive changes.
- Unsubscribe functions stop future notifications.
- Nested changes can be observed.
- Synchronous changes can be batched.
- Selectors derive values without mutating state.
- Memoized selectors reuse results for the same input reference.
- Store actions create predictable state transitions.

---

## Part 3 Summary

Functional programming helps us make data transformations predictable:

```text
input
  │
  ▼
pure transformation
  │
  ▼
new output
```

Reactive programming helps other parts of the application respond to state changes:

```text
state update
    │
    ▼
change detection
    │
    ▼
subscriber notification
    │
    ▼
derived view update
```

The combined architecture is:

```text
Action
  │
  ▼
Pure state transition
  │
  ▼
New state
  │
  ▼
Reactive notification
  │
  ▼
Pure selectors
  │
  ▼
UI or other side effects
```

The most important engineering boundaries are:

- Keep transformations pure where possible.
- Isolate side effects.
- Treat existing state as immutable.
- Make subscriptions removable.
- Use proxies for controlled interception, not as magic replacements for architecture.
- Use `Reflect` to preserve normal object semantics.
- Batch updates when many changes occur together.
