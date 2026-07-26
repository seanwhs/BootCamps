# Appendix D: `this` Binding and Function Invocation Reference

The `this` keyword is one of JavaScript’s most misunderstood features.

The most important rule is:

> For ordinary functions, `this` is usually determined by how the function is called, not where the function was written.

This appendix provides:

- The four main binding rules.
- Arrow-function behavior.
- `call()`.
- `apply()`.
- `bind()`.
- Constructor calls with `new`.
- Classes.
- Method extraction.
- Callbacks.
- Prototypes.
- Strict mode.
- Modules.
- Practical design patterns.
- Common mistakes.
- Verification examples.

---

# D.1: A `this` Decision Tree

When analyzing an ordinary function call, inspect the call site in this order:

```text
Was the function called with `new`?
├── Yes → constructor binding
└── No
    Was it called with `call()`, `apply()`, or `bind()`?
    ├── Yes → explicit or hard binding
    └── No
        Is it called as object.method()?
        ├── Yes → implicit binding
        └── No
            Is it an arrow function?
            ├── Yes → lexical `this`
            └── No → default binding
```

This is a practical decision tree for most ordinary JavaScript code.

---

# D.2: Default Binding

## The Target

We will observe the value of `this` during a plain function call.

## Strict Mode Example

### `default-binding.js`

```js
"use strict";

function inspectThis() {
  return this;
}

console.log(inspectThis());
```

## Verification

Run:

```bash
node default-binding.js
```

Expected output:

```text
undefined
```

In strict mode, a plain call gives ordinary functions an `undefined` `this`.

---

## Non-Strict Example

### `default-binding-nonstrict.js`

```js
function inspectThis() {
  return this;
}

console.log(inspectThis() === globalThis);
```

## Verification

Run:

```bash
node default-binding-nonstrict.js
```

In a non-strict Node.js script, the result can depend on how the file is loaded and wrapped. In browsers, a non-strict script function may receive the global object.

Do not rely on this behavior. Use strict mode or ECMAScript modules.

---

# D.3: Strict Mode and Accidental Globals

Strict mode prevents certain silent errors.

Without strict mode:

```js
function createValue() {
  accidentalGlobal = 42;
}

createValue();

console.log(accidentalGlobal);
```

With strict mode:

```js
"use strict";

function createValue() {
  accidentalGlobal = 42;
}

createValue();
```

This throws a `ReferenceError` because `accidentalGlobal` was never declared.

ECMAScript modules are strict automatically:

```js
// module.js
function showThis() {
  return this;
}

console.log(showThis()); // undefined
```

---

# D.4: Implicit Binding

## The Target

We will observe how an object method receives its object as `this`.

## Implementation

### `implicit-binding.js`

```js
"use strict";

const user = {
  name: "Ada",

  describe() {
    return `User: ${this.name}`;
  }
};

console.log(user.describe());
```

## Verification

Run:

```bash
node implicit-binding.js
```

Expected output:

```text
User: Ada
```

The call site is:

```js
user.describe();
```

The object immediately before the dot becomes `this`.

---

# D.5: The Call Site Matters

## The Target

We will extract the method and observe the changed behavior.

## Implementation

### `method-extraction.js`

```js
"use strict";

const user = {
  name: "Ada",

  describe() {
    return `User: ${this.name}`;
  }
};

console.log("method call:", user.describe());

const extractedDescribe = user.describe;

try {
  console.log("plain call:", extractedDescribe());
} catch (error) {
  console.log({
    name: error.name,
    message: error.message
  });
}
```

## Verification

Run:

```bash
node method-extraction.js
```

Expected output resembles:

```text
method call: User: Ada
{
  name: 'TypeError',
  message: "Cannot read properties of undefined (reading 'name')"
}
```

The function is the same function object, but the call form changed:

```js
user.describe(); // implicit binding
extractedDescribe(); // default binding
```

---

# D.6: Nested Object Calls

## The Target

We will identify which object becomes `this` in a nested call.

## Implementation

### `nested-object-call.js`

```js
"use strict";

const outer = {
  name: "outer",

  inner: {
    name: "inner",

    describe() {
      return this.name;
    }
  }
};

console.log(outer.inner.describe());
```

## Verification

Run:

```bash
node nested-object-call.js
```

Expected output:

```text
inner
```

The object immediately before `.describe()` is `outer.inner`, not `outer`.

---

# D.7: Losing `this` in Callbacks

## The Target

We will observe how passing a method as a callback loses implicit binding.

## Implementation

### `callback-this.js`

```js
"use strict";

const service = {
  name: "metrics",

  report() {
    return `${this.name} reported`;
  }
};

const callbacks = [
  service.report,
  service.report
];

for (const callback of callbacks) {
  try {
    console.log(callback());
  } catch (error) {
    console.log("callback failed:", error.name);
  }
}
```

## Verification

Run:

```bash
node callback-this.js
```

Expected output:

```text
callback failed: TypeError
callback failed: TypeError
```

The callback is called as:

```js
callback();
```

It is not called as:

```js
service.report();
```

---

# D.8: Fixing Callback Context with `bind()`

## Implementation

### `bound-callback.js`

```js
"use strict";

const service = {
  name: "metrics",

  report(prefix) {
    return `${prefix}: ${this.name} reported`;
  }
};

const boundReport = service.report.bind(service);

const callbacks = [
  boundReport,
  boundReport
];

for (const callback of callbacks) {
  console.log(callback("INFO"));
}
```

## Verification

Run:

```bash
node bound-callback.js
```

Expected output:

```text
INFO: metrics reported
INFO: metrics reported
```

`bind()` creates a new function with a fixed `this`.

---

# D.9: Explicit Binding with `call()`

## The Target

We will invoke a function with a chosen `this` object.

## Implementation

### `call-binding.js`

```js
"use strict";

function describeAccount(currency) {
  return `${this.owner}: ${this.balance} ${currency}`;
}

const account = {
  owner: "Ada",
  balance: 500
};

console.log(
  describeAccount.call(account, "USD")
);
```

## Verification

Run:

```bash
node call-binding.js
```

Expected output:

```text
Ada: 500 USD
```

The syntax is:

```js
function.call(thisArgument, argument1, argument2);
```

---

# D.10: Explicit Binding with `apply()`

## Implementation

### `apply-binding.js`

```js
"use strict";

function describeAccount(currency, includeStatus) {
  const status = includeStatus
    ? "active"
    : "status hidden";

  return `${this.owner}: ${this.balance} ${currency} (${status})`;
}

const account = {
  owner: "Ada",
  balance: 500
};

const argumentsToPass = ["EUR", true];

console.log(
  describeAccount.apply(account, argumentsToPass)
);
```

## Verification

Run:

```bash
node apply-binding.js
```

Expected output:

```text
Ada: 500 EUR (active)
```

The syntax is:

```js
function.apply(thisArgument, arrayOfArguments);
```

---

# D.11: `call()` Versus `apply()`

Both explicitly set `this`.

## `call()`

Arguments are supplied separately:

```js
operation.call(context, first, second, third);
```

## `apply()`

Arguments are supplied as an array:

```js
operation.apply(context, [first, second, third]);
```

Modern spread syntax often reduces the need for `apply()`:

```js
operation.call(context, ...argumentsArray);
```

However, `apply()` remains useful when reading older code and when its array-oriented form communicates intent.

---

# D.12: Hard Binding with `bind()`

## Implementation

### `hard-binding.js`

```js
"use strict";

function describeAccount(currency, includeStatus) {
  const status = includeStatus
    ? "active"
    : "status hidden";

  return `${this.owner}: ${this.balance} ${currency} (${status})`;
}

const account = {
  owner: "Ada",
  balance: 500
};

const describeInDollars = describeAccount.bind(
  account,
  "USD"
);

console.log(describeInDollars(true));
console.log(describeInDollars(false));
```

## Verification

Run:

```bash
node hard-binding.js
```

Expected output:

```text
Ada: 500 USD (active)
Ada: 500 USD (status hidden)
```

`bind()` can fix both:

- The `this` value.
- Leading arguments.

---

# D.13: Bound Functions and Later Calls

## The Target

We will confirm that a bound function keeps its `this` even when called through another object.

## Implementation

### `bound-function.js`

```js
"use strict";

const originalContext = {
  name: "original"
};

const otherContext = {
  name: "other"
};

function readName() {
  return this.name;
}

const boundReadName = readName.bind(originalContext);

console.log(boundReadName());
console.log(boundReadName.call(otherContext));
console.log(boundReadName.apply(otherContext));
```

## Verification

Run:

```bash
node bound-function.js
```

Expected output:

```text
original
original
original
```

Once bound, later `call()` and `apply()` calls cannot replace the bound `this`.

---

# D.14: Arrow Functions and Lexical `this`

## The Concept

Arrow functions do not create their own `this`.

They capture `this` from the surrounding scope.

## Implementation

### `arrow-this.js`

```js
"use strict";

const user = {
  name: "Ada",

  createReader() {
    return () => this.name;
  }
};

const reader = user.createReader();

console.log(reader());
```

## Verification

Run:

```bash
node arrow-this.js
```

Expected output:

```text
Ada
```

The arrow function captures `this` from `createReader()`.

Because `createReader()` was called as:

```js
user.createReader();
```

its `this` was the `user` object.

---

# D.15: Arrow Functions Ignore `call()`, `apply()`, and `bind()`

## Implementation

### `arrow-rebinding.js`

```js
"use strict";

const first = {
  name: "first"
};

const second = {
  name: "second"
};

const object = {
  name: "object",

  createArrow() {
    return () => this.name;
  }
};

const arrow = object.createArrow();

console.log("normal:", arrow());
console.log("call:", arrow.call(first));
console.log("apply:", arrow.apply(second));
console.log("bind:", arrow.bind(first)());
```

## Verification

Run:

```bash
node arrow-rebinding.js
```

Expected output:

```text
normal: object
call: object
apply: object
bind: object
```

The arrow’s `this` is lexical. Rebinding methods do not change it.

---

# D.16: Arrow Functions in Object Literals

## The Problem

An arrow function defined as an object property does not automatically receive the object as `this`.

## Implementation

### `arrow-object-property.js`

```js
"use strict";

const user = {
  name: "Ada",

  ordinaryMethod() {
    return this.name;
  },

  arrowMethod: () => {
    return this?.name;
  }
};

console.log("ordinary:", user.ordinaryMethod());
console.log("arrow:", user.arrowMethod());
```

## Verification

Run:

```bash
node arrow-object-property.js
```

Expected output:

```text
ordinary: Ada
arrow: undefined
```

Use ordinary method syntax when the method needs the receiving object:

```js
const user = {
  name: "Ada",

  describe() {
    return this.name;
  }
};
```

Use arrow functions when lexical `this` is desired, especially for nested callbacks.

---

# D.17: Arrow Functions Inside Methods

## The Target

We will preserve a method’s `this` inside a callback.

## Implementation

### `arrow-callback.js`

```js
"use strict";

const dashboard = {
  name: "Runtime Monitor",

  createMessages(names) {
    return names.map((name) => {
      return `${this.name}: ${name}`;
    });
  }
};

console.log(
  dashboard.createMessages(["metrics", "health"])
);
```

## Verification

Run:

```bash
node arrow-callback.js
```

Expected output:

```text
[ 'Runtime Monitor: metrics', 'Runtime Monitor: health' ]
```

The arrow callback captures `this` from `createMessages()`.

---

# D.18: Traditional Callback Alternative

Before arrow functions, developers often preserved `this` with a local variable:

```js
const dashboard = {
  name: "Runtime Monitor",

  createMessages(names) {
    const self = this;

    return names.map(function (name) {
      return `${self.name}: ${name}`;
    });
  }
};
```

Another option is binding:

```js
return names.map(function (name) {
  return `${this.name}: ${name}`;
}.bind(this));
```

Modern code usually prefers an arrow function for this specific lexical-capture pattern.

---

# D.19: Constructor Binding with `new`

## The Target

We will inspect the object created by a constructor call.

## Implementation

### `constructor-binding.js`

```js
"use strict";

function User(name) {
  this.name = name;
}

const user = new User("Ada");

console.log(user);
console.log(user instanceof User);
console.log(Object.getPrototypeOf(user) === User.prototype);
```

## Verification

Run:

```bash
node constructor-binding.js
```

Expected output:

```text
{ name: 'Ada' }
true
true
```

The `new` operator performs several conceptual steps:

1. Creates a new object.
2. Links it to the constructor’s prototype.
3. Calls the constructor with the new object as `this`.
4. Returns the object unless the constructor explicitly returns another object.

---

# D.20: Constructor Return Rules

## Primitive Return

A primitive return value is ignored by `new`.

```js
"use strict";

function Example() {
  this.value = 1;
  return 42;
}

const instance = new Example();

console.log(instance);
```

Output:

```text
Example { value: 1 }
```

## Object Return

An explicitly returned object can replace the constructed object.

```js
"use strict";

function Example() {
  this.value = 1;

  return {
    value: 2
  };
}

const instance = new Example();

console.log(instance);
```

Output:

```text
{ value: 2 }
```

Avoid surprising constructor returns. Prefer clear class or factory designs.

---

# D.21: Classes and `this`

## Implementation

### `class-this.js`

```js
"use strict";

class User {
  constructor(name) {
    this.name = name;
  }

  describe() {
    return `User: ${this.name}`;
  }
}

const user = new User("Ada");

console.log(user.describe());
```

## Verification

Run:

```bash
node class-this.js
```

Expected output:

```text
User: Ada
```

Class methods are ordinary functions with method-style behavior when called through an instance.

---

# D.22: Extracting a Class Method

## Implementation

### `class-method-extraction.js`

```js
"use strict";

class User {
  constructor(name) {
    this.name = name;
  }

  describe() {
    return `User: ${this.name}`;
  }
}

const user = new User("Ada");
const describe = user.describe;

try {
  console.log(describe());
} catch (error) {
  console.log(error.name);
}
```

## Verification

Run:

```bash
node class-method-extraction.js
```

Expected output:

```text
TypeError
```

Classes run in strict mode, so the extracted method receives `undefined` as `this`.

---

# D.23: Binding Class Methods

## Implementation

### `bound-class-method.js`

```js
"use strict";

class User {
  constructor(name) {
    this.name = name;

    this.describe = this.describe.bind(this);
  }

  describe() {
    return `User: ${this.name}`;
  }
}

const user = new User("Ada");
const describe = user.describe;

console.log(describe());
```

## Verification

Run:

```bash
node bound-class-method.js
```

Expected output:

```text
User: Ada
```

The constructor creates one bound function per instance. This is convenient, but it has memory and allocation costs for large numbers of instances.

---

# D.24: Class Fields with Arrow Functions

Modern class fields can define an arrow function per instance:

```js
"use strict";

class User {
  name;

  constructor(name) {
    this.name = name;
  }

  describe = () => {
    return `User: ${this.name}`;
  };
}

const user = new User("Ada");
const describe = user.describe;

console.log(describe());
```

The arrow function captures the instance’s `this`.

Use this pattern when callback-safe methods are more important than prototype sharing.

---

# D.25: Prototype Method Versus Instance Function

## Prototype Method

```js
class User {
  describe() {
    return this.name;
  }
}
```

The method is shared through the prototype.

## Instance Arrow Function

```js
class User {
  describe = () => {
    return this.name;
  };
}
```

Each instance receives its own function.

### Trade-Off

| Pattern | Advantages | Considerations |
|---|---|---|
| Prototype method | Shared function, lower per-instance allocation | Must preserve `this` |
| Bound method | Callback-safe | One bound function per instance |
| Arrow class field | Callback-safe, lexical `this` | One function per instance |

Choose intentionally based on object count, callback usage, and code clarity.

---

# D.26: `this` in Getters and Setters

## Implementation

### `getter-this.js`

```js
"use strict";

const user = {
  firstName: "Ada",
  lastName: "Lovelace",

  get fullName() {
    return `${this.firstName} ${this.lastName}`;
  },

  set fullName(value) {
    const [firstName, lastName] = value.split(" ");

    this.firstName = firstName;
    this.lastName = lastName;
  }
};

console.log(user.fullName);

user.fullName = "Grace Hopper";

console.log(user.fullName);
```

## Verification

Run:

```bash
node getter-this.js
```

Expected output:

```text
Ada Lovelace
Grace Hopper
```

Getters and setters receive `this` based on the object through which the property operation occurs.

---

# D.27: `this` in Accessor Inheritance

## Implementation

### `inherited-getter-this.js`

```js
"use strict";

const parent = {
  value: 10,

  get doubled() {
    return this.value * 2;
  }
};

const child = Object.create(parent);
child.value = 20;

console.log(child.doubled);
```

## Verification

Run:

```bash
node inherited-getter-this.js
```

Expected output:

```text
40
```

The getter was found on `parent`, but it was called with `child` as `this`.

---

# D.28: `super` and `this`

## Implementation

### `super-this.js`

```js
"use strict";

class BaseService {
  describe() {
    return `service: ${this.name}`;
  }
}

class MetricsService extends BaseService {
  constructor(name) {
    super();
    this.name = name;
  }

  describe() {
    return `${super.describe()} (metrics)`;
  }
}

const service = new MetricsService("metrics");

console.log(service.describe());
```

## Verification

Run:

```bash
node super-this.js
```

Expected output:

```text
service: metrics (metrics)
```

`super.describe()` calls the parent method while preserving the current instance as `this`.

---

# D.29: Manual Method Binding Utility

## The Target

We will implement a simplified version of `bind()` to understand the mechanism.

## Implementation

### `manual-bind.js`

```js
"use strict";

function bindFunction(functionToBind, thisArg, ...presetArguments) {
  if (typeof functionToBind !== "function") {
    throw new TypeError("functionToBind must be a function");
  }

  return function boundFunction(...remainingArguments) {
    return functionToBind.apply(
      thisArg,
      [...presetArguments, ...remainingArguments]
    );
  };
}

const account = {
  owner: "Ada",
  balance: 500
};

function describe(currency, suffix) {
  return `${this.owner}: ${this.balance} ${currency}${suffix}`;
}

const describeAccount = bindFunction(
  describe,
  account,
  "USD"
);

console.log(describeAccount(" (active)"));
```

## Verification

Run:

```bash
node manual-bind.js
```

Expected output:

```text
Ada: 500 USD (active)
```

The native `bind()` implementation also handles constructor behavior and function metadata more completely, so use the native method in production.

---

# D.30: Method Design Without `this`

Sometimes the clearest design avoids dynamic `this` entirely.

## Closure-Based Factory

```js
function createMetricsService(name) {
  return {
    describe() {
      return `service: ${name}`;
    }
  };
}
```

## Explicit Parameter

```js
function describeService(service) {
  return `service: ${service.name}`;
}
```

## Dependency Object

```js
function createReporter({ serviceName, logger }) {
  return {
    report(message) {
      logger.info(`[${serviceName}] ${message}`);
    }
  };
}
```

Avoiding `this` can improve:

- Callback safety.
- Testability.
- Dependency visibility.
- Refactoring simplicity.

Use `this` when object identity and method behavior naturally belong together. Do not use it merely because a function is inside an object.

---

# D.31: Common `this` Mistakes

## Mistake 1: Extracting a Method

```js
const handler = object.method;
handler();
```

Fix:

```js
const handler = object.method.bind(object);
```

or use a closure-based API.

---

## Mistake 2: Using an Arrow for an Object Method

```js
const object = {
  value: 10,

  getValue: () => this.value
};
```

The arrow does not receive `object` as `this`.

Fix:

```js
const object = {
  value: 10,

  getValue() {
    return this.value;
  }
};
```

---

## Mistake 3: Passing an Unbound Method to a Timer

```js
setTimeout(service.refresh, 1_000);
```

Fix:

```js
setTimeout(() => {
  service.refresh();
}, 1_000);
```

or:

```js
setTimeout(service.refresh.bind(service), 1_000);
```

---

## Mistake 4: Assuming `this` Is Lexical for Ordinary Functions

```js
function callback() {
  console.log(this);
}
```

Ordinary functions use call-site binding.

---

## Mistake 5: Binding an Arrow Function

```js
const arrow = () => this.value;

const bound = arrow.bind(object);
```

Binding does not change an arrow’s lexical `this`.

---

## Mistake 6: Using `this` in a Static Context

```js
class Utility {
  static create() {
    return new this();
  }
}
```

Here, `this` refers to the constructor associated with the static call. This can be useful, but it should be understood before using inheritance-sensitive factory patterns.

---

# D.32: `this` with Event Listeners

In browser event listeners registered with ordinary functions, `this` commonly refers to the element receiving the listener.

```js
button.addEventListener("click", function () {
  console.log(this === button);
});
```

With an arrow function, `this` is lexical:

```js
button.addEventListener("click", () => {
  console.log(this);
});
```

Use the event parameter when the target is what you need:

```js
button.addEventListener("click", (event) => {
  console.log(event.currentTarget);
});
```

This is often clearer than relying on event-listener `this` behavior.

---

# D.33: `this` and DOM Event Delegation

## Implementation

### `event-delegation.js`

```js
"use strict";

const list = document.querySelector("#service-list");

list.addEventListener("click", (event) => {
  const button = event.target.closest(
    "button[data-service]"
  );

  if (!button || !list.contains(button)) {
    return;
  }

  console.log({
    clickedService: button.dataset.service,
    currentTarget: event.currentTarget.id
  });
});
```

This uses explicit event properties rather than depending on `this`.

---

# D.34: `this` Verification Laboratory

## Implementation

### `this-laboratory.js`

```js
"use strict";

function ordinaryFunction() {
  return this;
}

const object = {
  name: "object",

  method() {
    return this;
  },

  createArrow() {
    return () => this;
  }
};

const arrow = object.createArrow();

console.log("default:", ordinaryFunction());
console.log("implicit:", object.method() === object);
console.log("call:", ordinaryFunction.call(object) === object);
console.log("apply:", ordinaryFunction.apply(object) === object);
console.log("bound:", ordinaryFunction.bind(object)() === object);
console.log("arrow:", arrow() === object);
console.log("arrow call:", arrow.call({ name: "other" }) === object);
console.log("constructor:", new ordinaryFunction() instanceof ordinaryFunction);
```

## Verification

Run:

```bash
node this-laboratory.js
```

Expected output:

```text
default: undefined
implicit: true
call: true
apply: true
bound: true
arrow: true
arrow call: true
constructor: true
```

---

# D.35: Invocation Reference Table

| Call form | `this` behavior |
|---|---|
| `function()` | Default binding |
| `object.method()` | `object` |
| `function.call(object)` | Explicit `object` |
| `function.apply(object, args)` | Explicit `object` |
| `function.bind(object)()` | Permanently bound `object` |
| `new Function()` | Newly created instance |
| Arrow function | Lexically captured `this` |

---

# D.36: Choosing a Function Style

## Use an Ordinary Function When:

- The function needs dynamic `this`.
- It is an object method.
- It may be used as a constructor.
- It should receive a caller-provided context.

## Use an Arrow Function When:

- The function should capture surrounding `this`.
- It is a short transformation callback.
- It is a nested callback inside a method.
- It should not be used as a constructor.

## Avoid Dynamic `this` When:

- Explicit dependencies are clearer.
- The function is passed through many layers.
- Callback extraction is common.
- The method does not need object context.

---

# D.37: Production Checklist for `this`

Before shipping code that uses `this`, ask:

- How is this function called?
- Is it an ordinary function or an arrow function?
- Could the method be extracted?
- Will it be passed as a callback?
- Should it be bound?
- Would explicit parameters be clearer?
- Is the function used as a constructor?
- Does a class method need callback-safe behavior?
- Is the code running in strict mode?
- Does an inherited getter or method rely on the receiver?

---

# D.38: Final `this` Mental Model

Analyze the call site:

```js
object.method();
```

The object before the dot supplies `this`.

```js
const method = object.method;
method();
```

The method is now a plain function call.

```js
method.call(otherObject);
```

The caller explicitly supplies `this`.

```js
const bound = method.bind(object);
bound();
```

The function receives the bound object.

```js
const arrow = () => this;
```

The arrow captures `this` from where it was created and cannot be rebound through `call()`, `apply()`, or `bind()`.

The key distinction is:

```text
ordinary function → dynamic call-site binding
arrow function    → lexical surrounding binding
```

Once that distinction is clear, most `this` behavior becomes predictable.
