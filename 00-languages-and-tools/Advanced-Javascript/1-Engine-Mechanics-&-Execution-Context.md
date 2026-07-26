# Part 1: Engine Mechanics & Execution Context

In this part, we will build the runtime foundation for the rest of the series.

JavaScript code may look like a list of instructions, but the engine does more than read those instructions from top to bottom. Before executing code, it creates an environment that keeps track of variables, functions, and the current execution location.

Understanding that environment explains many behaviors that otherwise seem mysterious:

- Why function declarations can be called before they appear.
- Why `let` and `const` behave differently from `var`.
- Why a function can remember variables from a previous scope.
- Why extracting an object method can change `this`.
- Why `.call()`, `.apply()`, and `.bind()` exist.
- Why a closure can accidentally retain a large object in memory.

We will create a small runnable laboratory rather than relying only on diagrams.

---

## Part 1.1: Create the Runtime Laboratory

### The Target

We will create the initial project files and configure Node.js to use ECMAScript modules.

The project will contain executable examples for:

- Execution contexts.
- Hoisting.
- Closures.
- `this` binding.
- Memory-retention patterns.

### The Concept

A JavaScript project is like a workshop. Before testing individual tools, we need a stable workbench and a known way to run each experiment.

We will use:

- **Node.js** as the JavaScript runtime.
- **ECMAScript modules** for explicit imports and exports.
- **Strict mode**, which helps expose unsafe behavior instead of silently accepting it.

### Implementation

#### `package.json`

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
    "memory": "node --expose-gc src/part-1/memory-retention.js"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

The `"type": "module"` setting means files use modern `import` and `export` syntax.

The `--expose-gc` option in the memory script exposes a garbage-collection function for demonstration purposes. It must not be used as a normal production memory-management strategy.

Create the directories:

```bash
mkdir -p src/part-1
```

### Verification

Run:

```bash
node --version
```

You should see Node.js version 20 or newer.

Then verify that the project configuration is valid:

```bash
node -e "import('./package.json', { with: { type: 'json' } }).then(({ default: packageInfo }) => console.log(packageInfo.name))"
```

Expected output:

```text
runtime-monitor
```

---

# Part 1.2: Execution Contexts

## The Target

We will create a program that demonstrates:

- The global execution context.
- Function execution contexts.
- Local variables.
- Nested function calls.
- The call stack.

### The Concept

An **execution context** is the environment JavaScript creates while running code.

You can think of it as a temporary desk containing:

- Variables available to the current code.
- The function’s arguments.
- A reference to the surrounding scope.
- Information about the current `this` value.
- The location where execution should continue.

JavaScript commonly works with three kinds of execution contexts:

1. **Global execution context**  
   Created when the script starts.

2. **Function execution context**  
   Created every time a function is called.

3. **`eval` execution context**  
   Created when direct `eval()` executes code. This is generally discouraged because it complicates security, optimization, and reasoning.

The engine maintains active function contexts in a structure called the **call stack**.

A stack behaves like a pile of plates:

- A new function call is placed on top.
- The top function must finish before JavaScript returns to the one beneath it.
- The most recently called function finishes first.

### Implementation

#### `src/part-1/execution-contexts.js`

```js
"use strict";

/*
 * This file demonstrates how function calls create nested execution contexts.
 *
 * The indentation in the logs represents the current depth of the call stack.
 * JavaScript itself does not automatically print this indentation; we add it
 * so the stack movement is easier to see.
 */

let callDepth = 0;

function logWithDepth(message) {
  const indentation = "  ".repeat(callDepth);
  console.log(`${indentation}${message}`);
}

function enterFunction(functionName) {
  callDepth += 1;
  logWithDepth(`ENTER ${functionName}`);
}

function leaveFunction(functionName) {
  logWithDepth(`LEAVE ${functionName}`);
  callDepth -= 1;
}

function calculateTotal(price, quantity) {
  enterFunction("calculateTotal");

  /*
   * `price`, `quantity`, and `subtotal` belong to this function's execution
   * context. They are not directly available inside the global context.
   */
  const subtotal = price * quantity;
  const total = addTax(subtotal, 0.2);

  leaveFunction("calculateTotal");
  return total;
}

function addTax(amount, taxRate) {
  enterFunction("addTax");

  /*
   * This context has access to its own parameters and local variables.
   * `amount` and `taxRate` are not variables created by calculateTotal,
   * even though their values originated there.
   */
  const tax = amount * taxRate;
  const result = amount + tax;

  leaveFunction("addTax");
  return result;
}

/*
 * The global execution context begins running here.
 */
console.log("GLOBAL: script started");

const finalTotal = calculateTotal(100, 2);

console.log(`GLOBAL: final total is ${finalTotal}`);
console.log("GLOBAL: script finished");
```

### Verification

Run:

```bash
npm run context
```

Expected output:

```text
GLOBAL: script started
  ENTER calculateTotal
    ENTER addTax
    LEAVE addTax
  LEAVE calculateTotal
GLOBAL: final total is 240
GLOBAL: script finished
```

The execution order is:

1. The global context starts.
2. `calculateTotal()` creates a new function context.
3. `calculateTotal()` calls `addTax()`.
4. `addTax()` creates another function context.
5. `addTax()` returns.
6. `calculateTotal()` returns.
7. The global context resumes.

---

## Creation and Execution Phases

When a context is created, the engine conceptually performs two broad phases.

### Creation Phase

The engine prepares the environment:

- It creates bindings for declarations.
- It identifies function declarations.
- It establishes the outer-scope reference.
- It determines the initial `this` value.
- It prepares the context for execution.

### Execution Phase

The engine runs statements in order:

- Assignments happen.
- Function calls occur.
- Expressions are evaluated.
- Control-flow statements execute.
- The context eventually returns or throws.

These are conceptual phases rather than two separate user-visible passes you can directly invoke.

---

# Part 1.3: Hoisting and Binding Initialization

## The Target

We will compare:

- Function declaration hoisting.
- `var` hoisting.
- `let` and `const` temporal dead zones.
- Function expressions.
- Assignment timing.

### The Concept

**Hoisting** is a shorthand for the way declarations are processed before ordinary statement execution begins.

The word can be misleading. JavaScript does not literally move every line to the top of the file.

Different declarations receive different initial states:

| Declaration | Binding created early? | Initialized immediately? | Usable before declaration? |
|---|---:|---:|---:|
| Function declaration | Yes | Yes, with function | Usually yes |
| `var` | Yes | Yes, with `undefined` | Yes, but usually unsafe |
| `let` | Yes | No | No; temporal dead zone |
| `const` | Yes | No | No; temporal dead zone |
| Function expression with `var` | Variable only | `undefined` | Not callable |
| Function expression with `const` | Yes | No | No |

A **temporal dead zone**, or TDZ, is the period between entering a scope and reaching the declaration where a `let` or `const` binding becomes initialized.

It is called “temporal” because it concerns time during execution, not physical location.

### Implementation

#### `src/part-1/hoisting.js`

```js
"use strict";

console.log("=== Function declaration ===");

/*
 * Function declarations are initialized with their function value during
 * context creation. Therefore, this call works before the declaration appears.
 */
console.log(describeFunction());

function describeFunction() {
  return "Function declarations are available before their source position.";
}

console.log("\n=== var declaration ===");

/*
 * The `var` binding exists before this line executes, but its initial value is
 * `undefined`. JavaScript does not throw at this read.
 */
console.log(`var value before assignment: ${legacyValue}`);

var legacyValue = "assigned later";

console.log(`var value after assignment: ${legacyValue}`);

console.log("\n=== let and const temporal dead zone ===");

/*
 * We cannot directly read a `let` or `const` binding before its declaration.
 * To demonstrate this without stopping the entire script, the read occurs in
 * a separate function that catches the resulting ReferenceError.
 */
function demonstrateTemporalDeadZone() {
  try {
    console.log(tdzValue);
    const tdzValue = "initialized";
  } catch (error) {
    console.log(`let/const read before initialization: ${error.name}`);
  }

  try {
    console.log(constantValue);
    const constantValue = 42;
  } catch (error) {
    console.log(`const read before initialization: ${error.name}`);
  }
}

demonstrateTemporalDeadZone();

console.log("\n=== Function expression with var ===");

try {
  /*
   * The variable exists and currently contains undefined. Calling undefined
   * as a function produces a TypeError.
   */
  oldStyleFunction();
} catch (error) {
  console.log(`function expression with var: ${error.name}`);
}

var oldStyleFunction = function oldStyleFunction() {
  return "This function is assigned only when execution reaches the assignment.";
};

console.log(oldStyleFunction());

console.log("\n=== Function expression with const ===");

try {
  /*
   * Unlike the `var` example, this read is blocked by the temporal dead zone.
   */
  modernFunction();
} catch (error) {
  console.log(`function expression with const: ${error.name}`);
}

const modernFunction = function modernFunction() {
  return "This function is available after initialization.";
};

console.log(modernFunction());
```

### Verification

Run:

```bash
npm run hoisting
```

Expected output:

```text
=== Function declaration ===
Function declarations are available before their source position.

=== var declaration ===
var value before assignment: undefined
var value after assignment: assigned later

=== let and const temporal dead zone ===
let/const read before initialization: ReferenceError
const read before initialization: ReferenceError

=== Function expression with var ===
function expression with var: TypeError
This function is assigned only when execution reaches the assignment.

=== Function expression with const ===
function expression with const: ReferenceError
This function is available after initialization.
```

### Practical Rule

Do not use hoisting as a design technique.

Although function declarations can safely appear below their use in many cases, the clearest production code generally defines important functions before the code that invokes them or organizes them into modules with explicit exports.

Prefer:

```js
function createUser(name) {
  return {
    name
  };
}

const user = createUser("Ada");
```

over relying heavily on declaration order that readers must mentally reconstruct.

---

# Part 1.4: Lexical Scope

## The Target

We will create a scope example showing:

- Local scope.
- Outer scope.
- Nested scope.
- Shadowing.
- Scope lookup.

### The Concept

**Lexical scope** means that a variable’s available location is determined by where the code is written.

Imagine nested rooms:

- A function can use objects in its own room.
- If the object is not there, it looks in the room surrounding it.
- It continues outward until it reaches the global room.
- An outer room cannot automatically see private objects inside an inner room.

**Shadowing** occurs when an inner scope defines a variable with the same name as one in an outer scope.

### Implementation

#### `src/part-1/lexical-scope.js`

```js
"use strict";

const applicationName = "Runtime Monitor";

function createDashboardMessage(userName) {
  const greeting = "Welcome";

  function formatMessage() {
    /*
     * `formatMessage` can access:
     * - its own local variables,
     * - `greeting` from createDashboardMessage,
     * - `applicationName` from the module scope.
     */
    return `${greeting}, ${userName}. You are using ${applicationName}.`;
  }

  return formatMessage();
}

console.log(createDashboardMessage("Ada"));

const status = "module status";

function demonstrateShadowing() {
  const status = "function status";

  {
    const status = "block status";
    console.log(`inside block: ${status}`);
  }

  console.log(`inside function: ${status}`);
}

console.log(`outside function: ${status}`);
demonstrateShadowing();
```

### Verification

Run:

```bash
node src/part-1/lexical-scope.js
```

Expected output:

```text
Welcome, Ada. You are using Runtime Monitor.
outside function: module status
inside block: block status
inside function: function status
```

The inner `status` does not overwrite the outer values. It temporarily hides them while the inner scope is active.

---

# Part 1.5: Closures

## The Target

We will build a closure-based counter and a private configuration object.

### The Concept

A **closure** is a function together with access to variables from the lexical scope where that function was created.

A useful analogy is a function carrying a key ring:

- The function is the person.
- The outer variables are locked rooms.
- The closure gives the function access to those rooms.
- Code outside the function does not automatically receive the keys.

Closures are useful for:

- Private state.
- Factory functions.
- Callbacks.
- Memoization.
- Event handlers.
- Encapsulation.
- Configured functions.

A closure is not automatically a memory leak. It becomes a problem when a long-lived object retains a closure that retains more data than necessary.

### Implementation

#### `src/part-1/closures.js`

```js
"use strict";

/*
 * This factory creates a counter with private state.
 *
 * `count` is not returned directly. The returned methods close over it, which
 * means they retain access to the same lexical binding.
 */
function createCounter(initialValue = 0) {
  if (!Number.isInteger(initialValue)) {
    throw new TypeError("initialValue must be an integer");
  }

  let count = initialValue;

  return Object.freeze({
    increment() {
      count += 1;
      return count;
    },

    decrement() {
      count -= 1;
      return count;
    },

    current() {
      return count;
    }
  });
}

const counter = createCounter(10);

console.log(`initial count: ${counter.current()}`);
console.log(`after increment: ${counter.increment()}`);
console.log(`after increment: ${counter.increment()}`);
console.log(`after decrement: ${counter.decrement()}`);

console.log(`direct count property: ${String(counter.count)}`);

/*
 * This factory demonstrates a configured function. The returned function
 * remembers `taxRate` without requiring callers to provide it every time.
 */
function createTaxCalculator(taxRate) {
  if (!Number.isFinite(taxRate) || taxRate < 0 || taxRate > 1) {
    throw new RangeError("taxRate must be between 0 and 1");
  }

  return function calculateTotalWithTax(amount) {
    if (!Number.isFinite(amount) || amount < 0) {
      throw new RangeError("amount must be a non-negative number");
    }

    return amount + amount * taxRate;
  };
}

const calculateWithTwentyPercentTax = createTaxCalculator(0.2);

console.log(
  `total with tax: ${calculateWithTwentyPercentTax(100)}`
);
```

### Verification

Run:

```bash
npm run closures
```

Expected output:

```text
initial count: 10
after increment: 11
after increment: 12
after decrement: 11
direct count property: undefined
total with tax: 120
```

The `count` variable remains alive because the returned methods still reference it.

### Important Closure Detail

Each call to the factory creates a separate lexical environment:

```js
const firstCounter = createCounter(0);
const secondCounter = createCounter(0);

firstCounter.increment();

console.log(firstCounter.current());  // 1
console.log(secondCounter.current()); // 0
```

The counters do not share `count`.

---

# Part 1.6: Closures and Memory Retention

## The Target

We will demonstrate how a closure can retain an object and how cleanup can release that reference.

### The Concept

JavaScript uses **garbage collection** to reclaim memory that can no longer be reached by active code.

An object is generally eligible for collection when there is no path from a live root to that object.

Common roots include:

- Active execution contexts.
- Global variables.
- Module-level variables.
- Timers.
- Event listeners.
- Long-lived application objects.
- Objects referenced by active closures.

A closure can unintentionally retain memory like a storage locker whose key was never returned.

The most common pattern is:

1. A large object is created.
2. A callback closes over it.
3. The callback is stored in a long-lived registry.
4. The registry remains alive.
5. The large object remains reachable through the callback.

### Implementation

#### `src/part-1/memory-retention.js`

```js
"use strict";

/*
 * This example is intentionally small enough to run on ordinary machines.
 * It demonstrates reachability, not a precise measurement of process memory.
 */

const listenerRegistry = new Set();

function createLargePayload() {
  /*
   * Each string is approximately one megabyte. The resulting array occupies
   * a noticeable amount of memory while remaining reasonable for a demo.
   */
  return Array.from(
    { length: 20 },
    (_, index) => `payload-${index}-`.padEnd(1_000_000, "x")
  );
}

function registerLeakingListener() {
  const largePayload = createLargePayload();

  /*
   * The callback closes over `largePayload`. As long as this callback remains
   * in listenerRegistry, the payload remains reachable.
   */
  const listener = () => largePayload.length;

  listenerRegistry.add(listener);

  return listener;
}

function registerCleanableListener() {
  const largePayload = createLargePayload();

  /*
   * The returned object gives the owner a clear cleanup operation. The owner
   * can remove the listener when the related feature is destroyed.
   */
  const listener = () => largePayload.length;

  listenerRegistry.add(listener);

  return {
    remove() {
      listenerRegistry.delete(listener);
    }
  };
}

function printMemory(label) {
  const memory = process.memoryUsage();
  const heapUsedInMegabytes = memory.heapUsed / 1024 / 1024;

  console.log(`${label}: ${heapUsedInMegabytes.toFixed(2)} MB`);
}

if (typeof global.gc !== "function") {
  throw new Error(
    "This example requires Node.js to run with the --expose-gc option."
  );
}

global.gc();
printMemory("initial heap");

const leakedListener = registerLeakingListener();
const cleanableRegistration = registerCleanableListener();

global.gc();
printMemory("after registrations");

cleanableRegistration.remove();

global.gc();
printMemory("after cleanable registration removal");

/*
 * We intentionally keep `leakedListener` in scope until this function ends.
 * The listener is also still in listenerRegistry, so its payload remains
 * reachable.
 */
console.log(`registered listeners: ${listenerRegistry.size}`);
console.log(`leaked listener result: ${leakedListener()}`);
```

### Verification

Run:

```bash
npm run memory
```

The exact memory values vary by Node.js version and operating system. You should see three memory readings and:

```text
registered listeners: 1
leaked listener result: 20
```

The important observation is architectural:

- The cleanable listener can be removed.
- The leaking listener remains in the registry.
- The registry keeps its callback alive.
- The callback keeps the payload reachable.

### Production Pattern

Whenever code registers a callback, return a cleanup function:

```js
function subscribe(subscriber, callback) {
  subscriber.add(callback);

  return () => {
    subscriber.delete(callback);
  };
}
```

The caller can then pair creation and destruction:

```js
const unsubscribe = subscribe(eventSource, handleEvent);

unsubscribe();
```

This pattern will become important later when we build reactive state and UI subscriptions.

---

# Part 1.7: Understanding `this`

## The Target

We will create examples for:

- Default binding.
- Implicit binding.
- Explicit binding.
- Hard binding.
- Arrow-function behavior.

### The Concept

`this` is not determined only by where a function is written. For ordinary functions, it is primarily determined by how the function is called.

There are four important binding rules.

---

## Rule 1: Default Binding

A plain function call uses default binding.

In strict mode, `this` is `undefined`.

```js
"use strict";

function showThis() {
  return this;
}

console.log(showThis()); // undefined
```

In non-strict browser scripts, default `this` may refer to the global object. Strict mode is safer because accidental global mutation becomes an error instead of a hidden side effect.

---

## Rule 2: Implicit Binding

When a function is called as an object method, the object before the dot becomes `this`.

```js
const account = {
  owner: "Ada",

  describe() {
    return this.owner;
  }
};

console.log(account.describe()); // Ada
```

The important part is the call site:

```js
account.describe();
```

If the method is extracted, the call form changes:

```js
const describe = account.describe;
describe();
```

Now it is a plain function call, not an object-method call.

---

## Rule 3: Explicit Binding

`call()` and `apply()` let you specify `this` directly.

```js
function describeAccount(currency) {
  return `${this.owner} has a balance in ${currency}.`;
}

const account = {
  owner: "Ada"
};

console.log(describeAccount.call(account, "USD"));
console.log(describeAccount.apply(account, ["EUR"]));
```

The difference is argument syntax:

- `call(thisArg, arg1, arg2)`
- `apply(thisArg, [arg1, arg2])`

---

## Rule 4: Hard Binding

`bind()` creates a new function whose `this` value is permanently associated with the supplied object.

```js
const describeBoundAccount = describeAccount.bind(account, "GBP");

console.log(describeBoundAccount());
```

Hard binding is useful when passing methods as callbacks.

---

## Arrow Functions

Arrow functions do not create their own `this`.

Instead, they capture `this` lexically from the surrounding scope.

This makes them useful inside methods when a callback should preserve the method’s `this` value.

### Implementation

#### `src/part-1/this-binding.js`

```js
"use strict";

function describeThisValue(value) {
  if (value === undefined) {
    return "undefined";
  }

  if (value === null) {
    return "null";
  }

  if (value === globalThis) {
    return "globalThis";
  }

  return value.constructor?.name ?? typeof value;
}

function showDefaultBinding() {
  return describeThisValue(this);
}

console.log("=== Default binding ===");
console.log(showDefaultBinding());

const user = {
  name: "Ada",

  describe() {
    return `User: ${this.name}`;
  },

  createArrowReader() {
    /*
     * The arrow function captures `this` from createArrowReader.
     * When createArrowReader is called as user.createArrowReader(), that
     * surrounding `this` is the user object.
     */
    return () => `Arrow user: ${this.name}`;
  }
};

console.log("\n=== Implicit binding ===");
console.log(user.describe());

const extractedDescribe = user.describe;

try {
  /*
   * This is now a plain function call. In strict mode, `this` is undefined,
   * so reading `this.name` throws a TypeError.
   */
  console.log(extractedDescribe());
} catch (error) {
  console.log(`extracted method error: ${error.name}`);
}

console.log("\n=== Explicit binding ===");

function describeAccount(currency, includeStatus) {
  const status = includeStatus ? "active" : "status hidden";
  return `${this.owner}: ${this.balance} ${currency} (${status})`;
}

const account = {
  owner: "Ada",
  balance: 500
};

console.log(describeAccount.call(account, "USD", true));
console.log(describeAccount.apply(account, ["EUR", false]));

console.log("\n=== Hard binding ===");

const describeInPounds = describeAccount.bind(account, "GBP", true);

console.log(describeInPounds());

console.log("\n=== Arrow lexical binding ===");

const arrowReader = user.createArrowReader();

console.log(arrowReader());

console.log("\n=== Constructor binding ===");

function User(name) {
  /*
   * When called with `new`, JavaScript creates a new object and binds `this`
   * to that object during the constructor call.
   */
  this.name = name;
}

const constructedUser = new User("Grace");

console.log(constructedUser.name);
```

### Verification

Run:

```bash
npm run this
```

Expected output:

```text
=== Default binding ===
undefined

=== Implicit binding ===
User: Ada
extracted method error: TypeError

=== Explicit binding ===
Ada: 500 USD (active)
Ada: 500 EUR (status hidden)

=== Hard binding ===
Ada: 500 GBP (active)

=== Arrow lexical binding ===
Arrow user: Ada

=== Constructor binding ===
Grace
```

---

# Part 1.8: Method Extraction and Safe APIs

## The Target

We will create a service object whose methods remain safe when passed as callbacks.

### The Concept

A method that depends on `this` can break when another API calls it as a plain function.

This often occurs with:

- Timer callbacks.
- Event listeners.
- Array callbacks.
- Promise handlers.
- Framework lifecycle functions.

There are three common solutions:

1. Use an arrow function property.
2. Bind the method in the constructor or factory.
3. Avoid `this` and use closures or explicit parameters.

For a small service, a factory with closures often makes dependencies clearer.

### Implementation

#### `src/part-1/safe-service.js`

```js
"use strict";

function createLogger(serviceName) {
  /*
   * `serviceName` is private state held by the returned functions.
   * The functions do not depend on dynamic `this` binding.
   */
  function format(level, message) {
    return `[${level}] [${serviceName}] ${message}`;
  }

  return Object.freeze({
    info(message) {
      console.log(format("INFO", message));
    },

    error(message) {
      console.error(format("ERROR", message));
    }
  });
}

const logger = createLogger("metrics-service");

const messages = ["request started", "request finished"];

messages.forEach(logger.info);
```

### Verification

Run:

```bash
node src/part-1/safe-service.js
```

Expected output:

```text
[INFO] [metrics-service] request started
[INFO] [metrics-service] request finished
```

Because the returned methods use a closure instead of dynamic `this`, extracting `logger.info` does not break its access to `serviceName`.

---

# Part 1.9: Complete Part 1 Demonstration

## The Target

We will create one integrated example that combines:

- Closures.
- Explicit method context.
- Private state.
- Safe callback handling.
- Input validation.

### Concept

The separate examples showed individual mechanisms. This final example combines them into a small reusable component.

The component will represent a request counter:

- Its count is private.
- Its public methods validate inputs.
- Its callback-safe method uses a closure.
- Its public API is frozen so callers cannot replace methods accidentally.

### Implementation

#### `src/part-1/request-counter.js`

```js
"use strict";

function createRequestCounter(name) {
  if (typeof name !== "string" || name.trim() === "") {
    throw new TypeError("name must be a non-empty string");
  }

  const counterName = name.trim();
  let successfulRequests = 0;
  let failedRequests = 0;

  function recordSuccess() {
    successfulRequests += 1;
  }

  function recordFailure() {
    failedRequests += 1;
  }

  function getSnapshot() {
    return Object.freeze({
      name: counterName,
      successfulRequests,
      failedRequests,
      totalRequests: successfulRequests + failedRequests
    });
  }

  /*
   * The returned object is frozen, but the closed-over counters can still
   * change through these controlled functions. Object.freeze prevents changing
   * the API surface; it does not freeze private variables in the closure.
   */
  return Object.freeze({
    recordSuccess,
    recordFailure,
    getSnapshot
  });
}

const counter = createRequestCounter("dashboard");

const recordSuccess = counter.recordSuccess;
const recordFailure = counter.recordFailure;

recordSuccess();
recordSuccess();
recordFailure();

console.log(counter.getSnapshot());
```

### Verification

Run:

```bash
node src/part-1/request-counter.js
```

Expected output will resemble:

```text
{
  name: 'dashboard',
  successfulRequests: 2,
  failedRequests: 1,
  totalRequests: 3
}
```

The methods continue to work after extraction because they do not rely on dynamic `this`.

---

# Part 1.10: Reference — Execution Context Internals

An execution context can be modeled conceptually as:

```text
Execution Context
├── LexicalEnvironment
│   ├── let bindings
│   ├── const bindings
│   ├── class bindings
│   └── outer environment reference
├── VariableEnvironment
│   ├── var bindings
│   └── function declarations
├── Function information
│   ├── parameters
│   ├── function body
│   └── this binding
└── Execution state
    ├── current instruction
    └── return location
```

The exact specification terminology is more detailed, but this model is useful when reasoning about code.

A function’s lexical environment explains closures:

```js
function outer() {
  const message = "hello";

  return function inner() {
    return message;
  };
}
```

The returned `inner` function retains access to `message` because its lexical environment points outward to the environment created by `outer()`.

---

# Part 1.11: Reference — Hoisting Details

## Function Declarations

```js
run();

function run() {
  console.log("running");
}
```

This usually works because the function declaration is initialized during context creation.

## `var`

```js
console.log(value); // undefined

var value = 10;
```

Conceptually similar to:

```js
var value;
console.log(value);

value = 10;
```

The assignment does not move. Only the binding creation is available earlier.

## `let` and `const`

```js
console.log(value); // ReferenceError

let value = 10;
```

The binding exists but remains uninitialized until execution reaches the declaration.

## Classes

Classes also have a temporal dead zone:

```js
const instance = new Example(); // ReferenceError

class Example {}
```

Use declarations in an order that makes dependencies clear, even when the language technically permits another order.

---

# Part 1.12: Reference — `call`, `apply`, and `bind`

## `call`

Use when arguments are already separate values:

```js
function sum(first, second) {
  return this.base + first + second;
}

const context = { base: 10 };

const result = sum.call(context, 2, 3);

console.log(result); // 15
```

## `apply`

Use when arguments are already in an array:

```js
const values = [2, 3];

const result = sum.apply(context, values);

console.log(result); // 15
```

## `bind`

Use when creating a reusable function:

```js
const addToContextBase = sum.bind(context);

console.log(addToContextBase(2, 3)); // 15
```

`bind()` can also pre-fill arguments:

```js
const addTwoNumbersToBase = sum.bind(context, 2, 3);

console.log(addTwoNumbersToBase()); // 15
```

## Important Limitation

Arrow functions ignore attempts to rebind their lexical `this`:

```js
const arrow = () => this;

console.log(arrow.call({ value: 1 }) === this); // true in the same lexical context
```

Do not use `.bind()` to fix an arrow function’s `this`. If a function must have dynamic `this`, use an ordinary function.

---

# Part 1.13: Reference — Common Memory-Leak Patterns

## Forgotten Event Listener

```js
const button = document.querySelector("button");

function handleClick() {
  console.log("clicked");
}

button.addEventListener("click", handleClick);

// Later, when the feature is destroyed:
button.removeEventListener("click", handleClick);
```

The same function reference must be passed to `removeEventListener()`.

This does not work:

```js
button.removeEventListener("click", () => {
  console.log("clicked");
});
```

That creates a new function object, which is different from the originally registered callback.

## Forgotten Timer

```js
const timerId = setInterval(() => {
  console.log("polling");
}, 1000);

clearInterval(timerId);
```

## Unbounded Cache

A cache that never removes entries can grow indefinitely:

```js
const cache = new Map();

function cacheValue(key, value) {
  cache.set(key, value);
}
```

A production cache needs a policy such as:

- Maximum size.
- Expiration time.
- Least-recently-used eviction.
- Explicit invalidation.

## Long-Lived Closure

```js
const globalHandlers = [];

function registerHandler(data) {
  globalHandlers.push(() => data);
}
```

If `data` is large, every handler retains it for as long as `globalHandlers` remains alive.

Prefer a cleanup mechanism:

```js
function registerHandler(data) {
  const handler = () => data;
  globalHandlers.push(handler);

  return () => {
    const index = globalHandlers.indexOf(handler);

    if (index >= 0) {
      globalHandlers.splice(index, 1);
    }
  };
}
```

---

# Part 1.14: Final Verification Checklist

Run each command:

```bash
npm run context
npm run hoisting
npm run closures
npm run this
npm run memory
node src/part-1/lexical-scope.js
node src/part-1/safe-service.js
node src/part-1/request-counter.js
```

You should verify that:

- Nested function contexts execute in stack order.
- Function declarations are initialized before ordinary execution.
- `var` reads as `undefined` before assignment.
- `let` and `const` reads throw `ReferenceError` before initialization.
- Closures preserve access to private state.
- Extracted methods can lose their implicit `this`.
- `call()` and `apply()` supply explicit context.
- `bind()` creates a reusable hard-bound function.
- Cleanup removes a retained callback from a registry.
- Closure-based services can safely be passed as callbacks.

---

## Part 1 Summary

JavaScript execution becomes easier to understand when we separate four ideas:

1. **Execution contexts**  
   The temporary environments created while code runs.

2. **Lexical scope**  
   The structure determined by where code is written.

3. **Closures**  
   Functions that retain access to surrounding lexical environments.

4. **Call-site-based `this` binding**  
   The rules that determine the receiver for ordinary functions.

These concepts are connected:

```text
Function creation
        │
        ▼
Lexical environment reference
        │
        ▼
Closure retention
        │
        ▼
Private state or retained memory
```

And for `this`:

```text
How the function is called
        │
        ├── plain call       → default binding
        ├── object.method()  → implicit binding
        ├── call/apply       → explicit binding
        ├── bind()           → hard binding
        └── new              → constructor binding
```

The next part will build on this foundation by examining asynchronous execution.
