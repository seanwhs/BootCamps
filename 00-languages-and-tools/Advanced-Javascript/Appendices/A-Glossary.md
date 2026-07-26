# Appendix A: JavaScript Runtime and Architecture Glossary

This appendix defines the main technical terms used throughout the series.

The definitions are intentionally practical. Each term includes:

- A beginner-friendly explanation.
- A short technical definition.
- A small code example where useful.
- The architectural reason the term matters.

---

## A.1 JavaScript Language and Runtime Terms

### JavaScript

**Beginner explanation:**  
JavaScript is a programming language used to describe logic, transform data, respond to events, and coordinate asynchronous work.

**Technical definition:**  
JavaScript is a dynamically typed, prototype-based programming language standardized by ECMA International through the ECMAScript specification.

JavaScript itself defines language features such as:

- Variables.
- Functions.
- Objects.
- Promises.
- Classes.
- Modules.
- Proxies.

The environment hosting JavaScript provides additional capabilities.

For example, browsers provide the DOM, while Node.js provides filesystem and process APIs.

---

### ECMAScript

**Beginner explanation:**  
ECMAScript is the formal specification that defines the JavaScript language.

**Technical definition:**  
ECMAScript is the standardized language specification from which JavaScript implementations derive their behavior.

JavaScript is the commonly used name for implementations of ECMAScript plus host-provided APIs.

---

### JavaScript Engine

**Beginner explanation:**  
A JavaScript engine is the program that reads and executes JavaScript code.

**Examples:**

- V8: used by Chrome and Node.js.
- SpiderMonkey: used by Firefox.
- JavaScriptCore: used by Safari.

The engine is responsible for activities such as:

- Parsing source code.
- Creating execution contexts.
- Executing instructions.
- Managing objects.
- Performing garbage collection.
- Optimizing frequently executed code.

---

### Runtime

**Beginner explanation:**  
A runtime is the complete environment in which JavaScript executes.

**Technical definition:**  
A runtime includes the JavaScript engine plus host APIs, scheduling mechanisms, resource handling, and environment-specific behavior.

For example:

```text
Node.js runtime
├── V8 JavaScript engine
├── timers
├── filesystem APIs
├── networking APIs
├── streams
├── process APIs
└── event-loop integration
```

A browser runtime includes:

```text
Browser runtime
├── JavaScript engine
├── DOM
├── timers
├── fetch
├── rendering pipeline
├── user-input events
└── Web APIs
```

---

### Host Environment

**Beginner explanation:**  
The host environment is the system that provides JavaScript with capabilities outside the language itself.

Examples include:

- A web browser.
- Node.js.
- Deno.
- Bun.
- An embedded JavaScript runtime.

The host environment provides APIs such as:

```js
setTimeout(() => {
  console.log("provided by the host environment");
}, 1000);
```

---

### ECMAScript Module

**Beginner explanation:**  
An ECMAScript module is a JavaScript file with explicit imports and exports.

**Example:**

```js
// math.js
export function add(first, second) {
  return first + second;
}
```

```js
// app.js
import { add } from "./math.js";

console.log(add(2, 3));
```

Modules help divide an application into focused files and prevent unrelated code from sharing accidental global variables.

---

### Strict Mode

**Beginner explanation:**  
Strict mode makes JavaScript less forgiving about certain unsafe operations.

**Example:**

```js
"use strict";

function showThis() {
  return this;
}

console.log(showThis()); // undefined
```

Strict mode helps reveal:

- Accidental global assignments.
- Invalid duplicate parameters.
- Unsafe `this` behavior.
- Certain silent failures.

ECMAScript modules use strict mode automatically.

---

## A.2 Execution and Scope Terms

### Execution Context

**Beginner explanation:**  
An execution context is the temporary environment JavaScript creates while running code.

It contains information such as:

- Variables.
- Function parameters.
- Available outer scopes.
- The current `this` value.
- Where execution should return.

Common execution contexts include:

- Global execution context.
- Function execution context.
- `eval` execution context.

---

### Global Execution Context

**Beginner explanation:**  
The global execution context is created when a JavaScript program starts.

It provides the outermost environment for the script or module.

Example:

```js
const applicationName = "Runtime Monitor";

console.log(applicationName);
```

The top-level code begins executing inside the global or module-level context.

---

### Function Execution Context

**Beginner explanation:**  
Every time a function is called, JavaScript creates a new execution context for that call.

```js
function greet(name) {
  const message = `Hello, ${name}`;
  return message;
}

greet("Ada");
```

The call to `greet()` creates a context containing:

- `name`.
- `message`.
- The function’s outer scope.
- The function’s `this` value.

---

### Call Stack

**Beginner explanation:**  
The call stack tracks active function calls.

It behaves like a stack of plates:

- New calls are placed on top.
- The top call completes first.
- JavaScript returns to the call beneath it.

```js
function first() {
  second();
}

function second() {
  third();
}

function third() {
  console.log("active");
}

first();
```

Conceptually:

```text
third()
second()
first()
global code
```

When `third()` finishes, it is removed. Then `second()` resumes.

---

### Stack Overflow

**Beginner explanation:**  
A stack overflow occurs when function calls grow beyond the runtime’s stack capacity.

The most common cause is unbounded recursion.

```js
function callForever() {
  callForever();
}

callForever();
```

Eventually, the runtime throws an error such as:

```text
RangeError: Maximum call stack size exceeded
```

---

### Lexical Scope

**Beginner explanation:**  
Lexical scope determines which variables a function can access based on where the function is written.

```js
const outerValue = "outer";

function outerFunction() {
  const innerValue = "inner";

  function innerFunction() {
    console.log(outerValue);
    console.log(innerValue);
  }

  innerFunction();
}

outerFunction();
```

`innerFunction()` can access variables in:

1. Its own scope.
2. The surrounding `outerFunction()` scope.
3. The module or global scope.

---

### Scope Chain

**Beginner explanation:**  
The scope chain is the sequence of environments JavaScript searches when looking for a variable.

```text
inner function scope
        │
        ▼
outer function scope
        │
        ▼
module scope
        │
        ▼
global environment
```

If a name is not found in the current scope, JavaScript looks outward.

---

### Lexical Environment

**Beginner explanation:**  
A lexical environment stores variable bindings and a reference to the surrounding environment.

A simplified model is:

```text
Lexical Environment
├── local variables
├── function declarations
├── outer environment reference
└── private bindings
```

Lexical environments are central to closures.

---

### Variable Binding

**Beginner explanation:**  
A binding connects a variable name to a value.

```js
const userName = "Ada";
```

Here, `userName` is a binding associated with the value `"Ada"`.

The binding and the value are related but conceptually different:

- The binding is the named location.
- The value is what that location currently contains.

---

### Shadowing

**Beginner explanation:**  
Shadowing occurs when an inner scope declares a variable with the same name as an outer variable.

```js
const status = "global";

function showStatus() {
  const status = "local";
  console.log(status);
}

showStatus(); // local
console.log(status); // global
```

The inner variable temporarily hides the outer variable.

---

### Hoisting

**Beginner explanation:**  
Hoisting describes how JavaScript creates certain declarations before executing ordinary statements.

Different declarations are initialized differently.

```js
showMessage();

function showMessage() {
  console.log("hello");
}
```

Function declarations are initialized with their function value during context creation.

By contrast:

```js
console.log(value); // undefined

var value = 10;
```

The `var` binding exists early, but the assignment happens later.

---

### Temporal Dead Zone

**Beginner explanation:**  
The temporal dead zone is the period between entering a scope and reaching a `let`, `const`, or `class` declaration.

```js
console.log(value); // ReferenceError

const value = 10;
```

The binding exists conceptually, but it cannot be accessed before initialization.

---

### Closure

**Beginner explanation:**  
A closure is a function that remembers variables from the scope where it was created.

```js
function createCounter() {
  let count = 0;

  return function increment() {
    count += 1;
    return count;
  };
}

const counter = createCounter();

console.log(counter()); // 1
console.log(counter()); // 2
```

The returned function retains access to `count` even after `createCounter()` has finished.

---

### Encapsulation

**Beginner explanation:**  
Encapsulation means keeping implementation details private and exposing only controlled operations.

```js
function createAccount() {
  let balance = 0;

  return {
    deposit(amount) {
      balance += amount;
    },

    getBalance() {
      return balance;
    }
  };
}
```

Code outside the factory cannot directly assign to `balance`.

---

### Private State

**Beginner explanation:**  
Private state is data that outside code cannot modify directly.

Private state can be implemented with:

- Closures.
- Private class fields.
- Module boundaries.
- Controlled stores.

Using a closure:

```js
function createSession() {
  let token = "private-token";

  return {
    getToken() {
      return token;
    }
  };
}
```

---

## A.3 Function and Object Terms

### First-Class Function

**Beginner explanation:**  
A first-class function can be stored, passed, and returned like any other value.

```js
function greet(name) {
  return `Hello, ${name}`;
}

const handler = greet;

function run(operation, value) {
  return operation(value);
}

console.log(run(handler, "Ada"));
```

JavaScript functions are objects with callable behavior.

---

### Higher-Order Function

**Beginner explanation:**  
A higher-order function accepts another function, returns a function, or does both.

Examples:

```js
const doubled = [1, 2, 3].map((value) => value * 2);
```

`map()` is higher-order because it accepts a function.

Another example:

```js
function createMultiplier(factor) {
  return (value) => value * factor;
}
```

`createMultiplier()` returns a function.

---

### Callback

**Beginner explanation:**  
A callback is a function passed to another function so it can be called later.

```js
setTimeout(() => {
  console.log("called later");
}, 100);
```

The arrow function is a callback.

Callbacks may run:

- Immediately.
- Later through a timer.
- After an I/O operation.
- When an event occurs.
- When a promise settles.

---

### Function Expression

**Beginner explanation:**  
A function expression creates a function as part of another expression.

```js
const greet = function (name) {
  return `Hello, ${name}`;
};
```

The function is assigned to `greet` only when execution reaches the assignment.

---

### Function Declaration

**Beginner explanation:**  
A function declaration defines a named function using declaration syntax.

```js
function greet(name) {
  return `Hello, ${name}`;
}
```

Function declarations are initialized differently from function expressions.

---

### Arrow Function

**Beginner explanation:**  
An arrow function is a compact function syntax that captures `this` from its surrounding scope.

```js
const add = (first, second) => first + second;
```

Arrow functions do not create their own:

- `this`.
- `arguments`.
- `super`.
- `new.target`.

They should not normally be used as constructors.

---

### Method

**Beginner explanation:**  
A method is a function stored as a property of an object or class.

```js
const user = {
  name: "Ada",

  greet() {
    return `Hello, ${this.name}`;
  }
};
```

`greet` is a method.

---

### `this`

**Beginner explanation:**  
For ordinary functions, `this` usually depends on how the function is called.

```js
const user = {
  name: "Ada",

  greet() {
    return this.name;
  }
};

user.greet(); // Ada
```

The important detail is the call site:

```js
user.greet();
```

---

### Default Binding

**Beginner explanation:**  
Default binding applies to a plain function call.

```js
"use strict";

function showThis() {
  return this;
}

console.log(showThis()); // undefined
```

In strict mode, `this` is `undefined`.

---

### Implicit Binding

**Beginner explanation:**  
Implicit binding occurs when a function is called as an object method.

```js
user.greet();
```

Here, `user` becomes `this`.

---

### Explicit Binding

**Beginner explanation:**  
Explicit binding means manually supplying `this`.

```js
function describe() {
  return this.name;
}

const user = { name: "Ada" };

console.log(describe.call(user));
```

`call()` and `apply()` provide explicit binding.

---

### Hard Binding

**Beginner explanation:**  
Hard binding creates a new function whose `this` value is fixed.

```js
const boundDescribe = describe.bind(user);

console.log(boundDescribe());
```

The returned function keeps the bound `this` value when passed as a callback.

---

### `call()`

Calls a function with a specified `this` and separate arguments.

```js
function addToBase(value) {
  return this.base + value;
}

console.log(addToBase.call({ base: 10 }, 5)); // 15
```

---

### `apply()`

Calls a function with a specified `this` and an array of arguments.

```js
function add(first, second) {
  return this.base + first + second;
}

console.log(add.apply({ base: 10 }, [2, 3])); // 15
```

---

### `bind()`

Creates a new function with a fixed `this` value and optionally pre-filled arguments.

```js
const addToTen = add.bind({ base: 10 });

console.log(addToTen(2, 3)); // 15
```

---

### Constructor

**Beginner explanation:**  
A constructor creates and initializes an object.

```js
function User(name) {
  this.name = name;
}

const user = new User("Ada");
```

The `new` operator creates a new object and binds it as `this` during the constructor call.

---

### Prototype

**Beginner explanation:**  
A prototype is an object from which another object can inherit properties and methods.

```js
const parent = {
  greet() {
    return "hello";
  }
};

const child = Object.create(parent);

console.log(child.greet());
```

JavaScript uses prototype-based inheritance.

---

### Object Reference

**Beginner explanation:**  
Objects are assigned and passed by reference value.

```js
const first = { count: 1 };
const second = first;

second.count = 2;

console.log(first.count); // 2
```

Both variables refer to the same object.

Primitive values behave differently:

```js
let first = 1;
let second = first;

second = 2;

console.log(first); // 1
```

---

### Shallow Copy

**Beginner explanation:**  
A shallow copy copies only the outer object. Nested objects remain shared.

```js
const original = {
  name: "service",
  configuration: {
    timeout: 1000
  }
};

const copy = { ...original };

copy.configuration.timeout = 2000;

console.log(original.configuration.timeout); // 2000
```

---

### Deep Copy

**Beginner explanation:**  
A deep copy creates independent copies of nested data.

Modern JavaScript provides:

```js
const copy = structuredClone(original);
```

Deep copying has limitations and costs. It may not preserve functions, class instances, or special resources.

---

## A.4 Asynchronous Runtime Terms

### Synchronous Code

**Beginner explanation:**  
Synchronous code runs immediately and in order.

```js
console.log("first");
console.log("second");
console.log("third");
```

Output:

```text
first
second
third
```

---

### Asynchronous Code

**Beginner explanation:**  
Asynchronous code starts work that completes later, allowing the current code to continue.

```js
setTimeout(() => {
  console.log("later");
}, 0);

console.log("now");
```

Output:

```text
now
later
```

---

### Event Loop

**Beginner explanation:**  
The event loop coordinates when JavaScript callbacks are allowed to run.

A simplified model is:

```text
run synchronous code
        │
        ▼
process microtasks
        │
        ▼
process a later task
        │
        ▼
process new microtasks
        │
        ▼
continue
```

The exact phases differ between browsers and Node.js, but the core purpose is the same: schedule deferred work around the call stack.

---

### Task

**Beginner explanation:**  
A task is a unit of scheduled work that runs after the current code.

Timer callbacks and many I/O callbacks are tasks.

The term “macrotask” is commonly used in tutorials, although modern specifications generally use “task.”

---

### Microtask

**Beginner explanation:**  
A microtask is deferred work that runs after current synchronous code but before the runtime proceeds to a later task.

Common microtask sources:

```js
Promise.resolve().then(() => {
  console.log("promise microtask");
});

queueMicrotask(() => {
  console.log("explicit microtask");
});
```

Microtasks are drained completely before the next task begins.

---

### Macrotask

**Beginner explanation:**  
“Macrotask” is a common informal term for ordinary event-loop tasks such as timers and some I/O callbacks.

Example:

```js
setTimeout(() => {
  console.log("timer task");
}, 0);
```

---

### Microtask Starvation

**Beginner explanation:**  
Microtask starvation occurs when an endless stream of microtasks prevents timers, rendering, or I/O callbacks from running.

```js
function scheduleAgain() {
  queueMicrotask(scheduleAgain);
}

scheduleAgain();
```

This pattern should be avoided.

---

### Promise

**Beginner explanation:**  
A promise represents the eventual result of an asynchronous operation.

A promise has three states:

- Pending.
- Fulfilled.
- Rejected.

```js
const result = Promise.resolve("done");

result.then((value) => {
  console.log(value);
});
```

A promise settles only once.

---

### Fulfilled

A promise is fulfilled when its operation completes successfully.

```js
Promise.resolve("success");
```

---

### Rejected

A promise is rejected when its operation fails.

```js
Promise.reject(new Error("failure"));
```

---

### Settled

A promise is settled when it is either:

- Fulfilled.
- Rejected.

A pending promise is not settled.

---

### `async` Function

**Beginner explanation:**  
An `async` function always returns a promise.

```js
async function getValue() {
  return 42;
}

getValue().then(console.log);
```

Even though the function returns `42`, the caller receives a promise that fulfills with `42`.

---

### `await`

**Beginner explanation:**  
`await` pauses the current async function until a promise settles.

```js
async function run() {
  const value = await Promise.resolve(42);
  console.log(value);
}
```

`await` does not block the entire JavaScript runtime. It pauses only the current async function.

---

### Promise Reaction

A promise reaction is the callback registered by methods such as:

```js
promise.then(onFulfilled);
promise.catch(onRejected);
promise.finally(onSettled);
```

These callbacks are scheduled as microtasks when the promise settles.

---

### Promise Combinator

A promise combinator coordinates multiple promises.

Main combinators:

- `Promise.all()`.
- `Promise.allSettled()`.
- `Promise.race()`.
- `Promise.any()`.

---

### `Promise.all()`

Fulfills when every input promise fulfills.

Rejects when the first input promise rejects.

```js
const [user, permissions] = await Promise.all([
  loadUser(),
  loadPermissions()
]);
```

Use it when every result is required.

---

### `Promise.allSettled()`

Waits until every promise settles and returns every outcome.

```js
const results = await Promise.allSettled([
  loadMetrics(),
  loadHealth(),
  loadActivity()
]);
```

Use it when partial results are valuable.

---

### `Promise.race()`

Settles when the first input promise settles.

```js
const result = await Promise.race([
  request(),
  timeout()
]);
```

It does not automatically cancel the losing operations.

---

### `Promise.any()`

Fulfills when the first input promise fulfills.

It rejects only if all input promises reject.

```js
const response = await Promise.any([
  loadFromPrimary(),
  loadFromBackup()
]);
```

---

### Concurrency

**Beginner explanation:**  
Concurrency means multiple operations overlap in time.

```js
await Promise.all([
  loadMetrics(),
  loadHealth()
]);
```

The operations can make progress independently even though one JavaScript thread coordinates the callbacks.

---

### Parallelism

**Beginner explanation:**  
Parallelism means multiple operations execute physically at the same moment, usually on separate threads or CPU cores.

Promises alone do not make CPU-heavy JavaScript parallel.

Use workers or separate processes for CPU parallelism.

---

### Cancellation

**Beginner explanation:**  
Cancellation means asking an operation to stop because its result is no longer needed.

JavaScript promises do not universally support cancellation. `AbortController` provides a standard cancellation signal.

---

### `AbortController`

Creates and sends an abort signal.

```js
const controller = new AbortController();

fetch("/api/data", {
  signal: controller.signal
});

controller.abort();
```

---

### `AbortSignal`

The signal passed to an operation so it can observe cancellation.

```js
async function loadData(signal) {
  return fetch("/api/data", { signal });
}
```

---

### Timeout

**Beginner explanation:**  
A timeout is a deadline after which an operation should stop or be considered unsuccessful.

A robust timeout should ideally:

1. Reject or report the timeout.
2. Cancel the underlying work.

---

### Race Condition

**Beginner explanation:**  
A race condition occurs when the result depends on the timing or order of operations.

Example:

```text
request A starts
request B starts
request B finishes
request A finishes later
```

If request A overwrites newer data from request B, the application displays stale state.

---

### Latest-Request-Wins

A coordination pattern in which a newer request cancels or supersedes an older request.

Useful for:

- Search.
- Filtering.
- Route changes.
- Repeated refresh actions.

---

## A.5 Functional Programming Terms

### Functional Programming

**Beginner explanation:**  
Functional programming emphasizes transforming values with functions and controlling side effects.

Common principles include:

- Pure functions.
- Immutability.
- Function composition.
- Explicit data flow.
- Higher-order functions.

---

### Pure Function

A pure function:

1. Returns the same output for the same input.
2. Does not change external state.

```js
function multiply(first, second) {
  return first * second;
}
```

---

### Impure Function

An impure function depends on or changes external state.

```js
let total = 0;

function addToTotal(value) {
  total += value;
  return total;
}
```

Impure functions are necessary at application boundaries but should be isolated where possible.

---

### Side Effect

A side effect is an interaction with something outside the function’s local calculation.

Examples:

- Logging.
- Network requests.
- Database writes.
- DOM updates.
- Reading the current time.
- Changing a global variable.
- Mutating shared objects.

---

### Immutability

Immutability means treating an existing value as unchanged and creating a replacement value when data changes.

```js
const nextState = {
  ...state,
  status: "healthy"
};
```

---

### Mutation

Mutation changes an existing object or array.

```js
state.status = "healthy";
```

Mutation is not always wrong, but uncontrolled mutation makes state history and ownership harder to reason about.

---

### Referential Equality

Two references are referentially equal if they point to the same object.

```js
const first = {};
const second = first;

console.log(first === second); // true
```

Two separate objects with the same fields are not referentially equal:

```js
console.log({ value: 1 } === { value: 1 }); // false
```

---

### Function Composition

Composition combines functions so one function’s output becomes another function’s input.

```js
const pipeline = (value) => addPrefix(toLowerCase(trim(value)));
```

A reusable `pipe()` utility usually executes from left to right.

---

### Pipe

A pipe applies functions from left to right:

```js
pipe(trim, toLowerCase, addPrefix);
```

---

### Compose

Composition traditionally applies functions from right to left:

```js
compose(addPrefix, toLowerCase, trim);
```

---

### Currying

Currying transforms a function with multiple arguments into a sequence of calls.

```js
const add = (first) => (second) => first + second;

console.log(add(2)(3)); // 5
```

---

### Partial Application

Partial application fixes some arguments and returns a function for the remaining arguments.

```js
function createMessage(prefix, message) {
  return `${prefix}: ${message}`;
}

const createInfoMessage = (message) =>
  createMessage("INFO", message);
```

---

### Reducer

A reducer is a function that calculates a new state from current state and an action.

```js
function reducer(state, action) {
  if (action.type === "INCREMENT") {
    return {
      ...state,
      count: state.count + 1
    };
  }

  return state;
}
```

Reducers should usually be pure.

---

### Selector

A selector derives a value from state.

```js
function selectHealthyServices(state) {
  return state.services.filter(
    (service) => service.status === "healthy"
  );
}
```

Selectors should generally not mutate state.

---

### Memoization

Memoization caches a previous result so repeated calculations can be avoided.

```js
function memoizeOne(selector) {
  let previousInput;
  let previousResult;

  return (input) => {
    if (input === previousInput) {
      return previousResult;
    }

    previousInput = input;
    previousResult = selector(input);

    return previousResult;
  };
}
```

---

## A.6 Metaprogramming and Reactivity Terms

### Metaprogramming

**Beginner explanation:**  
Metaprogramming means writing code that observes or controls the behavior of other code.

Examples:

- `Proxy`.
- `Reflect`.
- Property descriptors.
- Decorators.
- Dynamic function wrappers.

---

### Proxy

A proxy is an object placed in front of another object to intercept operations.

```js
const target = {};

const proxy = new Proxy(target, {
  set(object, property, value, receiver) {
    console.log("setting", property);
    return Reflect.set(object, property, value, receiver);
  }
});
```

---

### Target

The target is the original object or function wrapped by a proxy.

```js
const target = {
  value: 1
};

const proxy = new Proxy(target, handlers);
```

---

### Proxy Trap

A trap is a handler method that intercepts an operation.

Common traps include:

- `get`.
- `set`.
- `has`.
- `deleteProperty`.
- `ownKeys`.
- `apply`.
- `construct`.

---

### Reflect

`Reflect` provides methods for performing standard object operations.

```js
Reflect.get(object, property);
Reflect.set(object, property, value);
Reflect.has(object, property);
Reflect.deleteProperty(object, property);
```

Using `Reflect` inside proxy traps helps preserve normal JavaScript behavior.

---

### Reactive State

Reactive state automatically informs subscribers when state changes.

A simple reactive design contains:

```text
state
  │
  ▼
change detection
  │
  ▼
subscriber notification
```

---

### Subscriber

A subscriber is a function that receives notifications when a reactive value changes.

```js
const unsubscribe = state.subscribe((change) => {
  console.log(change);
});

unsubscribe();
```

---

### Subscription

A subscription connects a listener to a source of changes.

Subscriptions must have a cleanup mechanism to prevent stale listeners and memory leaks.

---

### Unsubscribe

An unsubscribe function removes a previously registered subscriber.

```js
const unsubscribe = store.subscribe(listener);

// When the owner no longer needs updates:
unsubscribe();
```

---

### Batching

Batching combines multiple updates into one notification or render.

```text
change 1 ─┐
change 2 ─┼── one render
change 3 ─┘
```

Batching reduces repeated work.

---

### Derived State

Derived state is calculated from existing state rather than stored independently.

```js
const healthyCount = services.filter(
  (service) => service.status === "healthy"
).length;
```

Storing values that can be derived can create synchronization problems.

---

## A.7 Memory Terms

### Heap

The heap is the memory area where dynamically created objects, arrays, functions, and other values are stored.

```js
const user = {
  name: "Ada"
};
```

The object generally resides in managed heap memory.

---

### Garbage Collection

Garbage collection automatically reclaims memory that is no longer reachable by the application.

The developer still influences memory lifetime by controlling references.

---

### Reachability

An object is reachable if the runtime can follow references from a live root to that object.

```text
global variable
      │
      ▼
object
      │
      ▼
nested object
```

All objects in the chain remain reachable.

---

### Mark-and-Sweep

A simplified garbage-collection strategy:

1. Mark objects reachable from roots.
2. Sweep away unmarked objects.

```text
live root ──► reachable object
                 │
                 ▼
             reachable child

unreferenced object → eligible for collection
```

---

### Garbage-Collection Root

A root is a value from which the runtime begins reachability analysis.

Examples include:

- Global variables.
- Active stack variables.
- Module-level bindings.
- Active timers.
- Event-listener registries.
- Runtime-managed handles.

---

### Memory Leak

A memory leak occurs when an application retains memory that it no longer needs.

Common causes:

- Forgotten event listeners.
- Unreleased timers.
- Global arrays that grow forever.
- Long-lived closures.
- Unbounded caches.
- Subscriptions that are never removed.

---

### Retained Object

A retained object remains reachable through one or more references.

A closure can retain an object:

```js
function createHandler() {
  const largeData = createLargeData();

  return () => largeData.length;
}
```

The returned function retains `largeData`.

---

### WeakMap

A `WeakMap` associates metadata with object keys without strongly retaining those keys solely because of the map.

```js
const metadata = new WeakMap();

const object = {};
metadata.set(object, {
  createdAt: Date.now()
});
```

`WeakMap` keys must be objects.

---

### Cache

A cache stores previously calculated or loaded values for reuse.

A production cache should define:

- Maximum size.
- Expiration policy.
- Invalidation behavior.
- Memory ownership.
- What happens when the cache is unavailable.

---

### Bounded Collection

A bounded collection has a maximum size.

```js
function createBoundedList(maximumSize) {
  const values = [];

  return {
    add(value) {
      values.push(value);

      while (values.length > maximumSize) {
        values.shift();
      }
    }
  };
}
```

Bounded collections prevent unbounded memory growth.

---

## A.8 Performance Terms

### Performance

Performance describes how efficiently an application uses time and resources.

Relevant measures include:

- Latency.
- Throughput.
- CPU usage.
- Memory usage.
- Render duration.
- Event-loop delay.
- Startup time.

---

### Latency

Latency is the time between initiating an operation and receiving its result.

```text
request starts ───────── response arrives
              latency
```

---

### Throughput

Throughput is the amount of work completed per unit of time.

Examples:

- Requests per second.
- Messages processed per minute.
- Records handled per batch.

---

### Debouncing

Debouncing delays execution until activity stops.

```text
input input input input ─── quiet period ─── execute
```

Useful for:

- Search.
- Autosave.
- Resize handling.
- Validation.

---

### Throttling

Throttling limits execution frequency.

```text
input input input input input
  execute        execute
```

Useful for:

- Scroll handling.
- Pointer movement.
- Telemetry.
- Progress reporting.

---

### Batching

Batching combines several operations into one larger operation.

Examples:

- One render for several state changes.
- One database write for several records.
- One network request containing multiple items.

---

### Yielding

Yielding voluntarily gives the runtime an opportunity to process other tasks.

```js
await new Promise((resolve) => {
  setTimeout(resolve, 0);
});
```

Yielding can keep the application responsive during large workloads.

---

### Long Task

A long task is a task that occupies the main thread long enough to delay other work.

In browser applications, long tasks can delay:

- User input.
- Rendering.
- Timers.
- Network callbacks.

---

### Benchmark

A benchmark measures performance under a defined scenario.

Benchmarks should control:

- Input size.
- Runtime version.
- Warm-up behavior.
- Number of iterations.
- Garbage-collection effects.
- Hardware conditions.

---

### Profiling

Profiling identifies where time or memory is being spent.

Profiling tools can reveal:

- Hot functions.
- Expensive allocations.
- Long tasks.
- Retained objects.
- Slow rendering.
- Event-loop delays.

---

## A.9 Resilience Terms

### Resilience

Resilience is the ability of a system to continue operating acceptably when parts of its environment fail.

A resilient system may:

- Retry temporary failures.
- Use fallback data.
- Cancel obsolete work.
- Open a circuit around an unhealthy service.
- Degrade partially instead of failing completely.
- Recover automatically.

---

### Failure Domain

A failure domain is a component or boundary where a failure can occur.

Examples:

- Database.
- External API.
- Network connection.
- Browser storage.
- Worker thread.
- Rendering component.

Understanding failure domains helps determine where to place error boundaries and fallback behavior.

---

### Retry

A retry repeats an operation after a failure.

Retries should be:

- Bounded.
- Selective.
- Delayed.
- Cancellation-aware.
- Safe for the operation being repeated.

---

### Retryable Error

A retryable error is a failure that may succeed if attempted again later.

Examples:

- Temporary network failure.
- Timeout.
- Service unavailable.
- Rate limiting after an appropriate delay.

---

### Exponential Backoff

Exponential backoff increases the delay between retries.

```text
attempt 1 → 100 ms
attempt 2 → 200 ms
attempt 3 → 400 ms
attempt 4 → 800 ms
```

---

### Jitter

Jitter adds controlled randomness to a retry delay.

It prevents many clients from retrying at exactly the same time.

---

### Retry Storm

A retry storm occurs when many clients repeatedly retry an unhealthy dependency and make the outage worse.

Backoff, jitter, maximum attempts, and circuit breakers help prevent retry storms.

---

### Circuit Breaker

A circuit breaker stops requests to a failing dependency for a period of time.

It commonly has three states:

```text
CLOSED
  │ repeated failures
  ▼
OPEN
  │ reset timeout
  ▼
HALF_OPEN
  │ successful probe
  └──────────────► CLOSED
```

---

### Closed Circuit

The circuit is operating normally and permits requests.

---

### Open Circuit

The circuit blocks requests immediately because the dependency has recently failed too often.

---

### Half-Open Circuit

The circuit permits a limited test request to determine whether the dependency has recovered.

---

### Fallback

A fallback is an alternative response used when the preferred operation fails.

Examples:

- Cached data.
- A reduced feature set.
- A default configuration.
- A degraded user-interface panel.

Fallback data should be labeled accurately:

```js
{
  status: "stale",
  data: cachedData,
  updatedAt: previousTimestamp
}
```

---

### Graceful Degradation

Graceful degradation means reducing functionality while preserving the most important parts of the application.

For example:

- Show health and metrics even if activity is unavailable.
- Display cached data while a refresh is attempted.
- Disable an optional feature instead of crashing the whole application.

---

### Idempotency

An operation is idempotent when repeating it produces the same intended final result.

Reading a resource is generally idempotent:

```js
GET /users/123
```

Incrementing a counter may not be:

```js
POST /counter/increment
```

Retries of non-idempotent operations require special protection, such as an idempotency key.

---

### Idempotency Key

An idempotency key identifies a logical operation so a server can recognize duplicate requests.

```js
const headers = {
  "Idempotency-Key": "payment-operation-123"
};
```

If the client retries because it did not receive a response, the server can return the original result instead of creating a duplicate operation.

---

### Timeout Budget

A timeout budget is the total time available for an operation, including retries.

For example:

```text
overall deadline: 2 seconds
attempt 1: 500 ms
retry delay: 100 ms
attempt 2: 500 ms
retry delay: 200 ms
attempt 3: remaining time
```

Retries should respect the caller’s overall deadline.

---

## A.10 Error-Handling Terms

### Error

An error represents a failure or invalid condition.

```js
throw new Error("operation failed");
```

---

### Exception

An exception is a value thrown during execution.

```js
throw new Error("failure");
```

An exception may be caught:

```js
try {
  throw new Error("failure");
} catch (error) {
  console.error(error.message);
}
```

---

### Error Boundary

An error boundary is an intentional place where errors are caught, logged, reported, and converted into controlled behavior.

A boundary should have enough context to make the error useful.

---

### Operational Error

An operational error is an expected failure caused by the environment or an external dependency.

Examples:

- Network timeout.
- Service unavailable.
- Invalid user input.
- Rate limiting.

Operational errors may be recoverable.

---

### Programming Error

A programming error indicates that the application violated an internal assumption.

Examples:

- Accessing a missing required property.
- Calling a function with an invalid internal state.
- Violating an invariant.
- Using an undefined dependency.

Programming errors should generally be fixed rather than blindly retried.

---

### Error Classification

Error classification assigns meaning to a failure.

```js
function isRetryable(error) {
  return (
    error.name === "TimeoutError" ||
    error.name === "TemporaryDependencyError"
  );
}
```

Classification determines whether to:

- Retry.
- Display a validation message.
- Log at warning or error level.
- Open a circuit.
- Ignore intentional cancellation.

---

### Error Cause

An error cause preserves the original error while adding context.

```js
throw new Error("failed to load dashboard", {
  cause: originalError
});
```

This is preferable to replacing the original error with an uninformative message.

---

### Unhandled Rejection

An unhandled rejection occurs when a promise rejects without an appropriate rejection handler.

```js
Promise.reject(new Error("not handled"));
```

Unhandled rejections should be avoided. A process-level handler can provide a final safety net, but local handling is preferable.

---

### Uncaught Exception

An uncaught exception is a thrown error that reaches the runtime without being caught.

At the process level, the application may no longer be in a safe state. Logging and graceful shutdown are usually safer than continuing indefinitely.

---

## A.11 Application Architecture Terms

### Architecture

Architecture is the structure of an application and the relationships between its parts.

A useful architecture defines:

- Responsibilities.
- Dependencies.
- Data flow.
- Error boundaries.
- Lifecycle ownership.
- Testing boundaries.

---

### Module

A module is a focused unit of code with an explicit interface.

```js
export function calculateAverage(values) {
  // ...
}
```

Good modules usually have:

- A clear purpose.
- A small public API.
- Minimal hidden state.
- Explicit dependencies.

---

### Separation of Concerns

Separation of concerns means keeping different responsibilities in different parts of the system.

For example:

```text
request client → makes requests
retry policy   → decides whether to retry
state store    → manages state
UI renderer    → displays state
```

---

### Single Responsibility

A component has a single responsibility when it has one primary reason to change.

A function that fetches data, retries failures, updates state, and renders HTML has too many responsibilities.

---

### Dependency Injection

Dependency injection means supplying dependencies from outside instead of creating them secretly inside a module.

```js
function createMetricsService({ requestClient, logger }) {
  return {
    async load() {
      logger.info("loading metrics");
      return requestClient.get("/metrics");
    }
  };
}
```

This improves testing and makes dependencies visible.

---

### Inversion of Control

Inversion of control means a component does not decide everything about when and how it is called. Another component or framework controls that flow.

Event listeners and callbacks are examples:

```js
button.addEventListener("click", handleClick);
```

The browser controls when `handleClick` runs.

---

### Invariant

An invariant is a condition that should always remain true.

Examples:

```text
latency must never be negative
circuit state must be one of three valid states
subscriber collection must contain functions only
```

Invariants should be enforced near the boundary where invalid data enters.

---

### Lifecycle

Lifecycle describes the stages of a resource or component:

```text
created → active → updated → stopped → destroyed
```

Timers, subscriptions, requests, components, and application processes all have lifecycles.

---

### Resource Ownership

Resource ownership identifies which component is responsible for releasing a resource.

For every created resource, ask:

```text
Who created it?
Who uses it?
Who stops it?
When is it released?
```

---

### Graceful Shutdown

Graceful shutdown stops an application in an orderly way:

1. Stop accepting new work.
2. Cancel or finish active work.
3. Remove subscriptions.
4. Stop timers.
5. Close connections.
6. Flush important logs.
7. Exit.

---

### Configuration

Configuration is runtime behavior supplied from outside the source code.

Examples:

- Request timeout.
- Retry limit.
- Circuit threshold.
- Log level.
- API endpoint.

Configuration should be validated and should not contain hard-coded secrets.

---

### Environment Variable

An environment variable is a configuration value supplied by the operating environment.

```js
const timeout = Number(process.env.REQUEST_TIMEOUT_MS);
```

Always validate environment variables before use.

---

## A.12 Quick Concept Map

The major ideas in the series connect like this:

```text
JavaScript engine
      │
      ▼
execution contexts and lexical scope
      │
      ▼
closures and function behavior
      │
      ▼
call stack and event loop
      │
      ▼
promises and asynchronous coordination
      │
      ▼
cancellation and timeouts
      │
      ▼
pure functions and immutable state
      │
      ▼
reactive subscriptions and selectors
      │
      ▼
memory ownership and cleanup
      │
      ▼
debouncing, throttling, and batching
      │
      ▼
retries, backoff, and circuit breakers
      │
      ▼
error boundaries and graceful shutdown
```

---

## A.13 Fast Review Tables

### Declaration Behavior

| Declaration | Early binding | Initial value before assignment | TDZ |
|---|---:|---:|---:|
| Function declaration | Yes | Function | No |
| `var` | Yes | `undefined` | No |
| `let` | Yes | Uninitialized | Yes |
| `const` | Yes | Uninitialized | Yes |
| Class | Yes | Uninitialized | Yes |

### Promise Combinators

| Method | Success condition | Failure condition |
|---|---|---|
| `Promise.all()` | All fulfill | First rejection |
| `Promise.allSettled()` | All settle | Does not normally reject |
| `Promise.race()` | First settlement | First result rejects |
| `Promise.any()` | First fulfillment | All reject |

### Event Scheduling

| Mechanism | Queue or phase | Typical priority |
|---|---|---:|
| Current function call | Call stack | Highest while active |
| `queueMicrotask()` | Microtask queue | Before later tasks |
| Promise continuation | Microtask queue | Before later tasks |
| `setTimeout()` | Task/timer queue | Later task |
| I/O callback | Host-specific task phase | Runtime-dependent |
| `setImmediate()` | Node.js check phase | Context-dependent |

### Resilience Choice

| Problem | Common solution |
|---|---|
| User types rapidly | Debounce |
| User scrolls rapidly | Throttle |
| Many updates occur together | Batch |
| Temporary failure | Retry with backoff |
| Persistent dependency failure | Circuit breaker |
| Obsolete request | Cancellation |
| Optional panel fails | Partial-result handling |
| Unexpected application failure | Error boundary |
| Process cannot safely continue | Graceful shutdown |

---

## A.14 Final Glossary Checklist

A reader completing the series should be able to explain:

- What an execution context contains.
- How the call stack works.
- How lexical scope differs from dynamic lookup.
- Why closures retain variables.
- How `this` is selected.
- Why microtasks run before timer tasks.
- How concurrency differs from parallelism.
- Which promise combinator fits a requirement.
- How `AbortController` enables cancellation.
- Why pure functions are easier to test.
- How immutable updates preserve previous state.
- What `Proxy` and `Reflect` do.
- Why subscriptions need cleanup.
- How garbage collection uses reachability.
- How debouncing differs from throttling.
- Why retries need backoff and jitter.
- What each circuit-breaker state means.
- Why idempotency matters for retries.
- Where errors should be caught.
- How graceful shutdown protects application resources.
