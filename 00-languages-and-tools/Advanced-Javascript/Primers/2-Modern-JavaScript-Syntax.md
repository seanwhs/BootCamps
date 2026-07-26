# Primer 2: Modern JavaScript Syntax

Modern JavaScript provides concise syntax for expressing common programming patterns.

This primer covers:

- Strict mode and ECMAScript modules.
- `const` and `let`.
- Template literals.
- Destructuring.
- Spread and rest syntax.
- Default parameters.
- Optional chaining.
- Nullish coalescing.
- Logical assignment operators.
- Computed properties.
- Shorthand properties and methods.
- Arrow functions.
- Classes.
- Private fields.
- Static fields and methods.
- Getters and setters.
- Iterators and `for...of`.
- Symbols.
- Modern collection types.
- Dynamic imports.
- Top-level `await`.

The examples use Node.js 20 or newer and ECMAScript modules.

---

# 1. Prepare the Primer Workspace

## The Target

We will create a directory for modern syntax examples.

## The Concept

Modern syntax is not a different language. It is a collection of language features that make common patterns shorter, safer, or clearer.

Syntax should improve communication, not hide behavior.

## Implementation

Run:

```bash
mkdir -p primer-2/src
```

Add these scripts to `package.json`:

```json
{
  "primer2:strict": "node primer-2/src/strict-modules.js",
  "primer2:template": "node primer-2/src/template-literals.js",
  "primer2:destructure": "node primer-2/src/destructuring.js",
  "primer2:spread": "node primer-2/src/spread-rest.js",
  "primer2:optional": "node primer-2/src/optional-chaining.js",
  "primer2:logical": "node primer-2/src/logical-assignment.js",
  "primer2:computed": "node primer-2/src/computed-properties.js",
  "primer2:arrows": "node primer-2/src/arrow-functions.js",
  "primer2:classes": "node primer-2/src/classes.js",
  "primer2:private": "node primer-2/src/private-fields.js",
  "primer2:collections": "node primer-2/src/modern-collections.js",
  "primer2:dynamic": "node primer-2/src/dynamic-import.js",
  "primer2:top-level-await": "node primer-2/src/top-level-await.js"
}
```

## Verification

Confirm Node.js:

```bash
node --version
```

Expected version:

```text
v20.x.x
```

---

# 2. ECMAScript Modules Use Strict Mode

## The Target

We will verify that module files automatically run in strict mode.

## The Concept

Strict mode disables or rejects several unsafe behaviors.

ECMAScript modules use strict mode automatically, so this file does not need to include:

```js
"use strict";
```

Strict mode helps catch:

- Accidental global variables.
- Invalid assignments.
- Unsafe function behavior.
- Some legacy syntax problems.

## Implementation

### `primer-2/src/strict-modules.js`

```js
/*
 * ECMAScript modules are automatically strict.
 */

function inspectThis() {
  return this;
}

console.log("plain function this:", inspectThis());

try {
  /*
   * `accidentalGlobal` was never declared. Strict mode rejects this instead
   * of silently creating a global variable.
   */
  accidentalGlobal = "unsafe";
} catch (error) {
  console.log({
    name: error.name,
    message: error.message
  });
}

const configuration = Object.freeze({
  environment: "development"
});

try {
  configuration.environment = "production";
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
npm run primer2:strict
```

Expected output resembles:

```text
plain function this: undefined
{
  name: 'ReferenceError',
  message: 'accidentalGlobal is not defined'
}
{
  name: 'TypeError',
  message: 'Cannot assign to read only property ...'
}
```

---

# 3. `const` and `let`

## The Target

We will review when to use `const` and `let`.

## The Concept

Use `const` when the binding should not be reassigned.

Use `let` when the binding must be reassigned.

```js
const serviceName = "metrics";
let attempt = 0;

attempt += 1;
```

Avoid `var` in new code unless you are intentionally working with legacy behavior.

## Implementation

### `primer-2/src/const-let.js`

```js
const serviceName = "metrics";
let attempt = 0;

attempt += 1;
attempt += 1;

console.log({
  serviceName,
  attempt
});

const service = {
  name: serviceName,
  status: "loading"
};

service.status = "healthy";

console.log(service);

/*
 * The binding remains fixed, but object properties can change unless the
 * object is frozen.
 */
const frozenService = Object.freeze({
  name: "health",
  status: "healthy"
});

try {
  frozenService.status = "degraded";
} catch (error) {
  console.log("frozen object error:", error.name);
}

console.log(frozenService);
```

## Verification

Run:

```bash
node primer-2/src/const-let.js
```

Expected output:

```text
{ serviceName: 'metrics', attempt: 2 }
{ name: 'metrics', status: 'healthy' }
frozen object error: TypeError
{ name: 'health', status: 'healthy' }
```

---

# 4. Template Literals

## The Target

We will create formatted strings with interpolation and multiline content.

## The Concept

Template literals use backticks:

```js
`text`
```

They allow expressions inside `${...}`.

This is clearer than concatenation:

```js
"Service " + name + " is " + status
```

## Implementation

### `primer-2/src/template-literals.js`

```js
const serviceName = "metrics";
const status = "healthy";
const latencyMilliseconds = 42;

const summary =
  `${serviceName} is ${status} with ` +
  `latency ${latencyMilliseconds} ms`;

console.log(summary);

const detailedReport = `
Service report
--------------
Name: ${serviceName}
Status: ${status}
Latency: ${latencyMilliseconds} ms
`;

console.log(detailedReport);

function formatService(service) {
  return `${service.name}: ${service.status}`;
}

console.log(
  formatService({
    name: "health",
    status: "degraded"
  })
);
```

## Verification

Run:

```bash
npm run primer2:template
```

Expected output includes:

```text
metrics is healthy with latency 42 ms
health: degraded
```

## Important Rule

Template interpolation executes JavaScript expressions:

```js
const message = `total: ${2 + 3}`;
```

Output:

```text
total: 5
```

Do not place untrusted raw HTML into a template and assign it to `innerHTML`. Use safe DOM APIs or escape content.

---

# 5. Destructuring with Defaults and Renaming

## The Target

We will use object and array destructuring with default values and aliases.

## The Concept

Destructuring extracts values into local variables.

Defaults apply only when the property is `undefined`, not when it is `null`.

## Implementation

### `primer-2/src/destructuring.js`

```js
const service = {
  name: "metrics",
  status: "healthy",
  metadata: {
    region: "us-east"
  }
};

const {
  name: serviceName,
  status = "unknown",
  latencyMilliseconds = 0,
  metadata: {
    region = "unknown"
  } = {}
} = service;

console.log({
  serviceName,
  status,
  latencyMilliseconds,
  region
});

const configuration = {
  timeoutMilliseconds: undefined,
  retryAttempts: null
};

const {
  timeoutMilliseconds = 5_000,
  retryAttempts = 3
} = configuration;

console.log({
  timeoutMilliseconds,
  retryAttempts
});

const values = ["first", "second", "third"];

const [
  first,
  ,
  third,
  fourth = "default fourth"
] = values;

console.log({
  first,
  third,
  fourth
});
```

## Verification

Run:

```bash
npm run primer2:destructure
```

Expected output includes:

```text
{
  serviceName: 'metrics',
  status: 'healthy',
  latencyMilliseconds: 0,
  region: 'us-east'
}
{
  timeoutMilliseconds: 5000,
  retryAttempts: null
}
{
  first: 'first',
  third: 'third',
  fourth: 'default fourth'
}
```

The default value does not replace `null`.

---

# 6. Function Parameter Destructuring

## The Target

We will destructure an options object directly in a function parameter list.

## The Concept

Options objects make function calls readable:

```js
createClient({
  baseUrl,
  timeoutMilliseconds,
  retryAttempts
});
```

The function can destructure the options it needs.

## Implementation

### `primer-2/src/parameter-destructuring.js`

```js
function createRequestConfiguration({
  baseUrl,
  timeoutMilliseconds = 5_000,
  retryAttempts = 3
} = {}) {
  if (typeof baseUrl !== "string") {
    throw new TypeError(
      "baseUrl must be a string"
    );
  }

  return {
    baseUrl,
    timeoutMilliseconds,
    retryAttempts
  };
}

console.log(
  createRequestConfiguration({
    baseUrl: "https://api.example.test"
  })
);

try {
  createRequestConfiguration();
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
node primer-2/src/parameter-destructuring.js
```

Expected output:

```text
{
  baseUrl: 'https://api.example.test',
  timeoutMilliseconds: 5000,
  retryAttempts: 3
}
{
  name: 'TypeError',
  message: 'baseUrl must be a string'
}
```

The `= {}` after the parameter allows the function to be called without an argument.

---

# 7. Spread and Rest Syntax

## The Target

We will distinguish spreading values from collecting values.

## The Concept

**Spread** expands a value.

```js
const combined = [...first, ...second];
```

**Rest** collects remaining values.

```js
function collect(first, ...remaining) {}
```

The same three dots have different meanings depending on their position.

## Implementation

### `primer-2/src/spread-rest.js`

```js
const baseServices = [
  "metrics",
  "health"
];

const allServices = [
  ...baseServices,
  "activity"
];

console.log({
  baseServices,
  allServices
});

const baseConfiguration = {
  timeoutMilliseconds: 5_000,
  retryAttempts: 3
};

const productionConfiguration = {
  ...baseConfiguration,
  timeoutMilliseconds: 10_000
};

console.log({
  baseConfiguration,
  productionConfiguration
});

function summarize(firstValue, ...remainingValues) {
  return {
    firstValue,
    remainingValues,
    count: 1 + remainingValues.length
  };
}

console.log(
  summarize("first", "second", "third")
);

const {
  name,
  ...otherProperties
} = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42
};

console.log({
  name,
  otherProperties
});
```

## Verification

Run:

```bash
npm run primer2:spread
```

Expected output includes:

```text
{
  firstValue: 'first',
  remainingValues: [ 'second', 'third' ],
  count: 3
}
```

---

# 8. Optional Chaining

## The Target

We will safely access missing nested values and optionally call functions.

## The Concept

Optional chaining stops evaluation and returns `undefined` when the value before `?.` is `null` or `undefined`.

## Property Access

```js
service?.metadata?.region
```

## Function Calls

```js
logger?.info?.("message")
```

## Array Access

```js
services?.[0]?.name
```

## Implementation

### `primer-2/src/optional-chaining.js`

```js
const response = {
  service: {
    name: "metrics",
    metadata: {
      region: "us-east"
    }
  }
};

console.log(
  response?.service?.metadata?.region
);

console.log(
  response?.service?.metadata?.zone
);

const missingResponse = null;

console.log(
  missingResponse?.service?.name
);

const services = [
  {
    name: "metrics"
  }
];

console.log(services?.[0]?.name);
console.log(services?.[1]?.name);

const logger = {
  info(message) {
    console.log("INFO:", message);
  }
};

logger?.info?.("request completed");

const missingLogger = null;

missingLogger?.info?.("this does not throw");
```

## Verification

Run:

```bash
npm run primer2:optional
```

Expected output includes:

```text
us-east
undefined
undefined
metrics
undefined
INFO: request completed
```

Optional chaining is useful for optional dependencies, partial responses, and nested configuration.

---

# 9. Optional Chaining Does Not Hide Every Error

## The Target

We will distinguish a missing property from a broken function.

## The Concept

Optional chaining only stops when the value is `null` or `undefined`.

It does not make every operation safe.

## Implementation

### `primer-2/src/optional-chaining-errors.js`

```js
const object = {
  value: 42
};

console.log(object?.value);

try {
  /*
   * `value` exists, but it is not a function. Optional chaining does not
   * convert a number into a callable function.
   */
  object.value?.();
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
node primer-2/src/optional-chaining-errors.js
```

Expected output resembles:

```text
42
{
  name: 'TypeError',
  message: 'object.value is not a function'
}
```

---

# 10. Nullish Coalescing

## The Target

We will use `??` for defaults.

## The Concept

Nullish coalescing uses the right-hand value only when the left-hand value is:

- `null`
- `undefined`

It preserves valid values such as:

- `0`
- `false`
- `""`

## Implementation

### `primer-2/src/nullish-coalescing.js`

```js
const values = {
  zero: 0,
  falseValue: false,
  emptyString: "",
  missing: undefined,
  emptyValue: null
};

console.log({
  zero: values.zero ?? 100,
  falseValue: values.falseValue ?? true,
  emptyString: values.emptyString ?? "default",
  missing: values.missing ?? "default",
  emptyValue: values.emptyValue ?? "default"
});

function getTimeout(configuration) {
  return configuration.timeoutMilliseconds ?? 5_000;
}

console.log(
  getTimeout({
    timeoutMilliseconds: 0
  })
);

console.log(
  getTimeout({})
);
```

## Verification

Run:

```bash
node primer-2/src/nullish-coalescing.js
```

Expected output includes:

```text
{
  zero: 0,
  falseValue: false,
  emptyString: '',
  missing: 'default',
  emptyValue: 'default'
}
0
5000
```

---

# 11. Logical Assignment Operators

## The Target

We will use:

- `||=`
- `&&=`
- `??=`

## The Concept

Logical assignment operators combine a logical check with assignment.

```js
value ||= fallback;
```

means:

```js
value = value || fallback;
```

but with short-circuit behavior.

## Implementation

### `primer-2/src/logical-assignment.js`

```js
let retryAttempts = 0;
retryAttempts ||= 3;

let configuredTimeout = null;
configuredTimeout ??= 5_000;

let logger = {
  info(message) {
    console.log("INFO:", message);
  }
};

logger &&= logger;
logger?.info?.("logger is available");

let optionalLogger = null;
optionalLogger &&= {
  info(message) {
    console.log(message);
  }
};

optionalLogger?.info?.("this does not print");

console.log({
  retryAttempts,
  configuredTimeout,
  loggerExists: logger !== null
});
```

## Verification

Run:

```bash
npm run primer2:logical
```

Expected output:

```text
INFO: logger is available
{
  retryAttempts: 3,
  configuredTimeout: 5000,
  loggerExists: true
}
```

## Important Difference

`||=` treats all falsy values as missing:

```js
let count = 0;
count ||= 10; // count becomes 10
```

`??=` treats only `null` and `undefined` as missing:

```js
let count = 0;
count ??= 10; // count remains 0
```

Use `??=` when zero, false, or an empty string are valid values.

---

# 12. Computed Property Names

## The Target

We will create object properties dynamically.

## The Concept

A computed property name uses an expression inside square brackets.

```js
const propertyName = "status";

const service = {
  [propertyName]: "healthy"
};
```

This is useful when building lookup tables, event maps, and dynamic state updates.

## Implementation

### `primer-2/src/computed-properties.js`

```js
const serviceName = "metrics";
const statusProperty = "status";

const service = {
  name: serviceName,
  [statusProperty]: "healthy",
  [`${serviceName}Latency`]: 42
};

console.log(service);

const eventHandlers = {
  [`${serviceName}:success`]() {
    return "metrics succeeded";
  },

  [`${serviceName}:failure`]() {
    return "metrics failed";
  }
};

console.log(
  eventHandlers["metrics:success"]()
);

const serviceStatuses = {};

function setStatus(
  statuses,
  name,
  status
) {
  return {
    ...statuses,
    [name]: status
  };
}

const nextStatuses = setStatus(
  serviceStatuses,
  "metrics",
  "healthy"
);

console.log(nextStatuses);
```

## Verification

Run:

```bash
npm run primer2:computed
```

Expected output includes:

```text
{
  name: 'metrics',
  status: 'healthy',
  metricsLatency: 42
}
metrics succeeded
{ metrics: 'healthy' }
```

---

# 13. Object Property Shorthand

## The Target

We will use concise object construction.

## The Concept

When a variable and property have the same name:

```js
const name = "metrics";

const service = {
  name
};
```

This is equivalent to:

```js
const service = {
  name: name
};
```

## Implementation

### `primer-2/src/object-shorthand.js`

```js
const name = "metrics";
const status = "healthy";
const latencyMilliseconds = 42;

const service = {
  name,
  status,
  latencyMilliseconds,

  describe() {
    return `${name}: ${status}`;
  }
};

console.log(service);
console.log(service.describe());
```

## Verification

Run:

```bash
node primer-2/src/object-shorthand.js
```

Expected output:

```text
{
  name: 'metrics',
  status: 'healthy',
  latencyMilliseconds: 42,
  describe: [Function: describe]
}
metrics: healthy
```

---

# 14. Arrow Functions

## The Target

We will use concise arrow functions and examine their return rules.

## The Concept

Arrow functions provide shorter syntax and capture `this` lexically.

## Single Expression

```js
const double = (value) => value * 2;
```

The expression is returned automatically.

## Block Body

```js
const double = (value) => {
  return value * 2;
};
```

A block body requires an explicit `return`.

## Returning an Object

Wrap the object in parentheses:

```js
const createService = (name) => ({
  name,
  status: "loading"
});
```

## Implementation

### `primer-2/src/arrow-functions.js`

```js
const double = (value) => value * 2;

const add = (first, second) => {
  return first + second;
};

const createService = (name) => ({
  name,
  status: "loading"
});

const names = [
  "metrics",
  "health",
  "activity"
];

const services = names.map((name) => ({
  name,
  status: "loading"
}));

console.log("double:", double(4));
console.log("add:", add(2, 3));
console.log("created service:", createService("metrics"));
console.log("services:", services);
```

## Verification

Run:

```bash
npm run primer2:arrows
```

Expected output includes:

```text
double: 8
add: 5
created service: { name: 'metrics', status: 'loading' }
```

---

# 15. Arrow Functions and `this`

## The Target

We will preserve a method’s `this` inside a callback.

## The Concept

Arrow functions do not create their own `this`. They use the surrounding function’s `this`.

## Implementation

### `primer-2/src/arrow-this.js`

```js
const dashboard = {
  name: "Runtime Monitor",

  createLabels(serviceNames) {
    return serviceNames.map((serviceName) => {
      return `${this.name}: ${serviceName}`;
    });
  }
};

console.log(
  dashboard.createLabels([
    "metrics",
    "health"
  ])
);
```

## Verification

Run:

```bash
node primer-2/src/arrow-this.js
```

Expected output:

```text
[ 'Runtime Monitor: metrics', 'Runtime Monitor: health' ]
```

Do not use an arrow function as an object method when the method needs the object as `this`.

Use:

```js
const service = {
  name: "metrics",

  describe() {
    return this.name;
  }
};
```

---

# 16. Classes

## The Target

We will create a class with a constructor and methods.

## The Concept

A class is syntax for creating objects with shared behavior.

A class can define:

- Constructor logic.
- Instance methods.
- Getters.
- Setters.
- Static methods.
- Private fields.

## Implementation

### `primer-2/src/classes.js`

```js
class Service {
  constructor(name, status = "loading") {
    if (
      typeof name !== "string" ||
      name.trim() === ""
    ) {
      throw new TypeError(
        "name must be a non-empty string"
      );
    }

    this.name = name.trim();
    this.status = status;
  }

  describe() {
    return `${this.name}: ${this.status}`;
  }

  markHealthy() {
    this.status = "healthy";
  }
}

const service = new Service("metrics");

console.log(service.describe());

service.markHealthy();

console.log(service.describe());
console.log(service instanceof Service);
```

## Verification

Run:

```bash
npm run primer2:classes
```

Expected output:

```text
metrics: loading
metrics: healthy
true
```

Class methods are placed on the prototype and shared by instances.

---

# 17. Class Inheritance

## The Target

We will create a specialized class that extends a base class.

## The Concept

Inheritance allows one class to reuse behavior from another class.

Use inheritance when the relationship is genuinely “is a.”

```text
MetricsService is a Service
```

Do not use inheritance merely to share unrelated utilities.

## Implementation

### `primer-2/src/inheritance.js`

```js
class Service {
  constructor(name) {
    this.name = name;
  }

  describe() {
    return `${this.name}: generic service`;
  }
}

class MetricsService extends Service {
  constructor(name, requestsPerSecond = 0) {
    super(name);

    this.requestsPerSecond = requestsPerSecond;
  }

  describe() {
    return `${super.describe()}, ` +
      `requests/sec: ${this.requestsPerSecond}`;
  }
}

const service = new MetricsService(
  "metrics",
  125
);

console.log(service.describe());
console.log(service instanceof MetricsService);
console.log(service instanceof Service);
```

## Verification

Run:

```bash
node primer-2/src/inheritance.js
```

Expected output:

```text
metrics: generic service, requests/sec: 125
true
true
```

`super()` must be called before using `this` in a derived constructor.

---

# 18. Private Class Fields

## The Target

We will create a class with private state.

## The Concept

A private field begins with `#`.

It can only be accessed inside the class that declares it.

This differs from a convention such as:

```js
this._count
```

An underscore does not create true privacy.

## Implementation

### `primer-2/src/private-fields.js`

```js
class RequestCounter {
  #successfulRequests = 0;
  #failedRequests = 0;

  recordSuccess() {
    this.#successfulRequests += 1;
  }

  recordFailure() {
    this.#failedRequests += 1;
  }

  snapshot() {
    return {
      successfulRequests: this.#successfulRequests,
      failedRequests: this.#failedRequests,
      totalRequests:
        this.#successfulRequests +
        this.#failedRequests
    };
  }
}

const counter = new RequestCounter();

counter.recordSuccess();
counter.recordSuccess();
counter.recordFailure();

console.log(counter.snapshot());

try {
  /*
   * This is intentionally invalid syntax and cannot be dynamically accessed.
   * Private fields are not normal string-keyed properties.
   */
  console.log(counter.#successfulRequests);
} catch (error) {
  console.log(error.name);
}
```

## Verification

The file cannot be parsed because direct access to `counter.#successfulRequests` is invalid outside the class.

To demonstrate privacy without making the whole file fail during parsing, use this version:

### `primer-2/src/private-fields-safe.js`

```js
class RequestCounter {
  #successfulRequests = 0;

  recordSuccess() {
    this.#successfulRequests += 1;
  }

  snapshot() {
    return {
      successfulRequests: this.#successfulRequests
    };
  }
}

const counter = new RequestCounter();

counter.recordSuccess();

console.log(counter.snapshot());
console.log("public keys:", Object.keys(counter));
console.log(
  "string property access:",
  counter["#successfulRequests"]
);
```

Run:

```bash
node primer-2/src/private-fields-safe.js
```

Expected output:

```text
{ successfulRequests: 1 }
public keys: []
string property access: undefined
```

Private fields are useful for invariants and encapsulated state.

---

# 19. Private Methods and Static Private Fields

## The Target

We will use private methods and static private state.

## Implementation

### `primer-2/src/private-methods.js`

```js
class ServiceRegistry {
  static #createdRegistries = 0;

  #services = new Map();

  constructor() {
    ServiceRegistry.#createdRegistries += 1;
  }

  #normalizeName(name) {
    return name.trim().toLowerCase();
  }

  register(name, service) {
    const normalizedName =
      this.#normalizeName(name);

    if (normalizedName === "") {
      throw new TypeError(
        "service name must not be empty"
      );
    }

    this.#services.set(normalizedName, service);
  }

  get(name) {
    return this.#services.get(
      this.#normalizeName(name)
    );
  }

  list() {
    return [...this.#services.keys()];
  }

  static registryCount() {
    return ServiceRegistry.#createdRegistries;
  }
}

const registry = new ServiceRegistry();

registry.register(" Metrics ", {
  status: "healthy"
});

console.log(registry.get("metrics"));
console.log(registry.list());
console.log(ServiceRegistry.registryCount());
```

## Verification

Run:

```bash
node primer-2/src/private-methods.js
```

Expected output:

```text
{ status: 'healthy' }
[ 'metrics' ]
1
```

---

# 20. Getters and Setters

## The Target

We will expose property-like access while validating assignments.

## The Concept

A getter calculates a value when a property is read.

A setter validates or transforms a value when a property is assigned.

## Implementation

### `primer-2/src/getters-setters.js`

```js
class Service {
  #status = "loading";

  constructor(name) {
    this.name = name;
  }

  get status() {
    return this.#status;
  }

  set status(value) {
    const validStatuses = new Set([
      "loading",
      "healthy",
      "degraded",
      "unavailable"
    ]);

    if (!validStatuses.has(value)) {
      throw new RangeError(
        `invalid service status: ${value}`
      );
    }

    this.#status = value;
  }

  get summary() {
    return `${this.name}: ${this.status}`;
  }
}

const service = new Service("metrics");

console.log(service.status);
service.status = "healthy";

console.log(service.summary);

try {
  service.status = "unknown";
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
node primer-2/src/getters-setters.js
```

Expected output:

```text
loading
metrics: healthy
{
  name: 'RangeError',
  message: 'invalid service status: unknown'
}
```

Use getters and setters when property-style syntax improves clarity. Otherwise, explicit methods such as `setStatus()` may make side effects more obvious.

---

# 21. Static Fields and Methods

## The Target

We will attach behavior to the class itself rather than individual instances.

## The Concept

Instance members belong to each object:

```js
service.describe()
```

Static members belong to the class:

```js
Service.isValidStatus("healthy")
```

## Implementation

### `primer-2/src/static-members.js`

```js
class Service {
  static supportedStatuses = Object.freeze([
    "loading",
    "healthy",
    "degraded",
    "unavailable"
  ]);

  static isValidStatus(status) {
    return Service.supportedStatuses.includes(status);
  }

  constructor(name, status) {
    if (!Service.isValidStatus(status)) {
      throw new RangeError(
        `invalid status: ${status}`
      );
    }

    this.name = name;
    this.status = status;
  }
}

console.log(Service.supportedStatuses);
console.log(Service.isValidStatus("healthy"));
console.log(Service.isValidStatus("unknown"));

const service = new Service(
  "metrics",
  "healthy"
);

console.log(service);
```

## Verification

Run:

```bash
node primer-2/src/static-members.js
```

Expected output includes:

```text
true
false
{ name: 'metrics', status: 'healthy' }
```

Static methods are useful for factories, validation, and behavior that does not belong to one instance.

---

# 22. `Object.hasOwn()`

## The Target

We will safely check whether an object owns a property.

## The Concept

`Object.hasOwn(object, property)` checks whether a property belongs directly to the object rather than coming from its prototype.

## Implementation

### `primer-2/src/has-own.js`

```js
const service = {
  name: "metrics"
};

console.log(
  Object.hasOwn(service, "name")
);

console.log(
  Object.hasOwn(service, "toString")
);

console.log(
  "name" in service
);

console.log(
  "toString" in service
);
```

## Verification

Run:

```bash
node primer-2/src/has-own.js
```

Expected output:

```text
true
false
true
true
```

The `in` operator includes inherited properties. `Object.hasOwn()` checks only direct properties.

---

# 23. `Object.entries()`, `Object.keys()`, and `Object.values()`

## The Target

We will convert object properties into iterable arrays.

## Implementation

### `primer-2/src/object-iteration.js`

```js
const service = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42
};

console.log(Object.keys(service));
console.log(Object.values(service));
console.log(Object.entries(service));

for (const [property, value] of Object.entries(service)) {
  console.log(`${property} = ${value}`);
}
```

## Verification

Run:

```bash
node primer-2/src/object-iteration.js
```

Expected output includes:

```text
[ 'name', 'status', 'latencyMilliseconds' ]
[ 'metrics', 'healthy', 42 ]
[
  [ 'name', 'metrics' ],
  [ 'status', 'healthy' ],
  [ 'latencyMilliseconds', 42 ]
]
```

---

# 24. `Map`

## The Target

We will store values using a `Map`.

## The Concept

A `Map` stores key-value pairs and supports keys of any type.

Unlike ordinary objects:

- Keys can be objects, functions, or primitives.
- `Map` has a clear `.size`.
- It is designed specifically for key-value storage.

## Implementation

### `primer-2/src/modern-collections.js`

```js
const serviceMetadata = new Map();

const service = {
  name: "metrics"
};

serviceMetadata.set(service, {
  owner: "platform",
  region: "us-east"
});

serviceMetadata.set("metrics", {
  status: "healthy"
});

console.log(
  serviceMetadata.get(service)
);

console.log(
  serviceMetadata.get("metrics")
);

console.log(
  serviceMetadata.has("metrics")
);

console.log(
  serviceMetadata.size
);

for (const [key, value] of serviceMetadata) {
  console.log({
    key,
    value
  });
}
```

## Verification

Run:

```bash
npm run primer2:collections
```

Expected output includes:

```text
{ owner: 'platform', region: 'us-east' }
{ status: 'healthy' }
true
2
```

Use `Map` when the data is conceptually a dictionary or lookup table.

---

# 25. `Set`

## The Target

We will store unique values with a `Set`.

## The Concept

A `Set` stores values without duplicates.

## Implementation

### `primer-2/src/set.js`

```js
const statuses = new Set([
  "healthy",
  "degraded",
  "healthy",
  "loading"
]);

console.log([...statuses]);
console.log(statuses.has("healthy"));
console.log(statuses.has("unavailable"));
console.log(statuses.size);

statuses.add("unavailable");
statuses.delete("loading");

console.log([...statuses]);
```

## Verification

Run:

```bash
node primer-2/src/set.js
```

Expected output:

```text
[ 'healthy', 'degraded', 'loading' ]
true
false
3
[ 'healthy', 'degraded', 'unavailable' ]
```

Use a `Set` for:

- Unique identifiers.
- Subscriber collections.
- Allowed values.
- Visited nodes.
- Deduplication.

---

# 26. `WeakMap` and `WeakSet`

## The Target

We will associate metadata with objects without creating a strong key reference.

## The Concept

A `WeakMap` or `WeakSet` does not keep object keys alive solely because they are stored there.

This is useful for metadata tied to object lifetime.

## Implementation

### `primer-2/src/weak-collections.js`

```js
const metadata = new WeakMap();
const processedObjects = new WeakSet();

let service = {
  name: "metrics"
};

metadata.set(service, {
  createdAt: Date.now()
});

processedObjects.add(service);

console.log(metadata.get(service));
console.log(processedObjects.has(service));

service = null;

/*
 * The original service object may now become collectible if no other
 * references exist. Collection timing cannot be observed deterministically.
 */
console.log("strong reference released");
```

## Verification

Run:

```bash
node primer-2/src/weak-collections.js
```

Expected output includes:

```text
{ createdAt: ... }
true
strong reference released
```

Do not use weak collections as a replacement for explicit lifecycle cleanup when the application owns the resource.

---

# 27. Iterables and `for...of`

## The Target

We will iterate over arrays, sets, maps, and strings.

## The Concept

An iterable is a value that can provide an iterator.

`for...of` consumes values from an iterable.

## Implementation

### `primer-2/src/iterables.js`

```js
const services = ["metrics", "health"];

for (const service of services) {
  console.log("array value:", service);
}

const uniqueStatuses = new Set([
  "healthy",
  "degraded",
  "healthy"
]);

for (const status of uniqueStatuses) {
  console.log("set value:", status);
}

const serviceMap = new Map([
  ["metrics", "healthy"],
  ["health", "degraded"]
]);

for (const entry of serviceMap) {
  console.log("map entry:", entry);
}

for (const [name, status] of serviceMap) {
  console.log(`${name}: ${status}`);
}

for (const character of "API") {
  console.log("character:", character);
}
```

## Verification

Run:

```bash
node primer-2/src/iterables.js
```

---

# 28. Generators

## The Target

We will create a generator function.

## The Concept

A generator can pause and resume execution using `yield`.

A generator function uses:

```js
function* name() {
  yield value;
}
```

It returns an iterator.

## Implementation

### `primer-2/src/generators.js`

```js
function* serviceNames() {
  yield "metrics";
  yield "health";
  yield "activity";
}

const iterator = serviceNames();

console.log(iterator.next());
console.log(iterator.next());
console.log(iterator.next());
console.log(iterator.next());

for (const name of serviceNames()) {
  console.log("service:", name);
}
```

## Verification

Run:

```bash
node primer-2/src/generators.js
```

Expected output:

```text
{ value: 'metrics', done: false }
{ value: 'health', done: false }
{ value: 'activity', done: false }
{ value: undefined, done: true }
service: metrics
service: health
service: activity
```

Generators are useful for lazy sequences, custom iterables, and controlled data production.

---

# 29. Symbols

## The Target

We will use symbols as unique property keys.

## The Concept

A `Symbol` creates a unique primitive value.

```js
const first = Symbol("id");
const second = Symbol("id");

first === second; // false
```

Symbols can avoid property-name collisions.

## Implementation

### `primer-2/src/symbols.js`

```js
const internalId = Symbol("internalId");

const service = {
  name: "metrics",
  [internalId]: "service-123"
};

console.log(service.name);
console.log(service[internalId]);
console.log(Object.keys(service));
console.log(Object.getOwnPropertySymbols(service));
```

## Verification

Run:

```bash
node primer-2/src/symbols.js
```

Expected output:

```text
metrics
service-123
[ 'name' ]
[ Symbol(internalId) ]
```

Symbol-keyed properties are not returned by ordinary `Object.keys()`.

Symbols are not a security mechanism. Code with access to the symbol can read the property.

---

# 30. `BigInt`

## The Target

We will represent integers larger than JavaScript’s safe number range.

## The Concept

The `number` type cannot precisely represent every integer beyond:

```js
Number.MAX_SAFE_INTEGER
```

`BigInt` supports arbitrary-size integers.

## Implementation

### `primer-2/src/bigint.js`

```js
const safeNumber = Number.MAX_SAFE_INTEGER;
const largeInteger = 9_007_199_254_740_993n;

console.log({
  safeNumber,
  largeInteger,
  type: typeof largeInteger
});

const first = 10n;
const second = 3n;

console.log("sum:", first + second);
console.log("product:", first * second);
console.log("integer division:", first / second);

try {
  console.log(first + 3);
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
node primer-2/src/bigint.js
```

Expected output includes:

```text
sum: 13n
product: 30n
integer division: 3n
```

Do not mix `BigInt` and `number` directly. Convert deliberately.

---

# 31. Dynamic `import()`

## The Target

We will load a module only when needed.

## The Concept

Static imports are loaded as part of module initialization:

```js
import { formatService } from "./format.js";
```

Dynamic imports return a promise:

```js
const module = await import("./format.js");
```

Dynamic imports are useful for:

- Feature-based loading.
- Lazy application sections.
- Optional dependencies.
- Environment-specific modules.
- Reducing initial browser work.

## Implementation

### `primer-2/src/dynamic-module.js`

```js
export function formatService(service) {
  return `${service.name}: ${service.status}`;
}
```

### `primer-2/src/dynamic-import.js`

```js
const module = await import(
  "./dynamic-module.js"
);

const formatted = module.formatService({
  name: "metrics",
  status: "healthy"
});

console.log(formatted);
console.log(Object.keys(module));
```

## Verification

Run:

```bash
npm run primer2:dynamic
```

Expected output:

```text
metrics: healthy
[ 'formatService' ]
```

Dynamic imports can fail asynchronously, so handle errors when loading optional modules.

---

# 32. Dynamic Import Error Handling

## Implementation

### `primer-2/src/dynamic-import-error.js`

```js
try {
  const module = await import(
    "./does-not-exist.js"
  );

  console.log(module);
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
node primer-2/src/dynamic-import-error.js
```

Expected output contains a module-not-found error.

---

# 33. Top-Level `await`

## The Target

We will use `await` directly in an ECMAScript module.

## The Concept

Top-level `await` allows a module to wait for asynchronous initialization before completing its evaluation.

## Implementation

### `primer-2/src/top-level-await.js`

```js
function loadConfiguration() {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({
        environment: "development",
        timeoutMilliseconds: 5_000
      });
    }, 10);
  });
}

const configuration = await loadConfiguration();

console.log("configuration loaded:", configuration);
```

## Verification

Run:

```bash
npm run primer2:top-level-await
```

Expected output:

```text
configuration loaded: { environment: 'development', timeoutMilliseconds: 5000 }
```

## Caution

A module using top-level `await` delays modules that depend on it.

Use it for genuine module initialization, not for ordinary application workflow logic.

---

# 34. Tagged Template Literals

## The Target

We will process a template literal through a custom function.

## The Concept

A tagged template receives:

- An array of static string portions.
- The interpolated values.

This enables custom formatting, localization, and safe string-processing utilities.

## Implementation

### `primer-2/src/tagged-template.js`

```js
function describe(strings, ...values) {
  return strings.reduce(
    (result, string, index) => {
      const value =
        index < values.length
          ? String(values[index])
          : "";

      return result + string + value;
    },
    ""
  );
}

const serviceName = "metrics";
const status = "healthy";

const message = describe`
Service ${serviceName}
Status ${status}
`;

console.log(message);
```

## Verification

Run:

```bash
node primer-2/src/tagged-template.js
```

Expected output:

```text

Service metrics
Status healthy
```

A tag does not automatically make untrusted content safe. Security still depends on the implementation.

---

# 35. Logical Operators and Short-Circuiting

## The Target

We will use logical operators to control evaluation.

## The Concept

JavaScript logical operators return operands, not necessarily booleans.

- `a && b` returns `a` if falsy, otherwise `b`.
- `a || b` returns `a` if truthy, otherwise `b`.
- `a ?? b` returns `a` unless it is nullish.

## Implementation

### `primer-2/src/short-circuiting.js`

```js
function logIfAvailable(logger, message) {
  logger && logger.info(message);
}

const logger = {
  info(message) {
    console.log("INFO:", message);
  }
};

logIfAvailable(logger, "service started");
logIfAvailable(null, "this is skipped");

const configuredValue = "";
const fallbackValue = "default";

console.log(
  "using ||:",
  configuredValue || fallbackValue
);

console.log(
  "using ??:",
  configuredValue ?? fallbackValue
);
```

## Verification

Run:

```bash
node primer-2/src/short-circuiting.js
```

Expected output:

```text
INFO: service started
using ||: default
using ??: 
```

---

# 36. `Object.freeze()` and `Object.seal()`

## The Target

We will compare frozen and sealed objects.

## The Concept

`Object.freeze()` prevents:

- Adding properties.
- Removing properties.
- Changing existing properties.

`Object.seal()` prevents:

- Adding properties.
- Removing properties.

But sealed properties may still be changed.

Both are shallow.

## Implementation

### `primer-2/src/object-integrity.js`

```js
const frozen = Object.freeze({
  status: "healthy"
});

const sealed = Object.seal({
  status: "healthy"
});

try {
  frozen.status = "degraded";
} catch (error) {
  console.log("frozen update:", error.name);
}

try {
  frozen.extra = true;
} catch (error) {
  console.log("frozen add:", error.name);
}

sealed.status = "degraded";

try {
  sealed.extra = true;
} catch (error) {
  console.log("sealed add:", error.name);
}

console.log({
  frozen,
  sealed
});
```

## Verification

Run:

```bash
node primer-2/src/object-integrity.js
```

Expected output includes:

```text
frozen update: TypeError
frozen add: TypeError
sealed add: TypeError
```

`Object.freeze()` is useful for protecting configuration and public API surfaces, but it does not create deep immutability.

---

# 37. `structuredClone()`

## The Target

We will create a deep clone of cloneable data.

## The Concept

`structuredClone()` creates a deep copy of many built-in data types.

## Implementation

### `primer-2/src/structured-clone.js`

```js
const original = {
  service: {
    name: "metrics",
    status: "loading"
  },
  tags: new Set(["api", "critical"]),
  createdAt: new Date("2026-01-01T00:00:00Z")
};

const copy = structuredClone(original);

copy.service.status = "healthy";
copy.tags.add("production");

console.log("original:", original);
console.log("copy:", copy);
console.log(
  "nested references differ:",
  original.service !== copy.service
);
console.log(
  "date preserved:",
  copy.createdAt instanceof Date
);
console.log(
  "set preserved:",
  copy.tags instanceof Set
);
```

## Verification

Run:

```bash
node primer-2/src/structured-clone.js
```

Expected output includes:

```text
nested references differ: true
date preserved: true
set preserved: true
```

`structuredClone()` does not clone every value. Functions, certain class instances, and runtime resources require other approaches.

---

# 38. Modern Syntax Review Example

## The Target

We will combine the most important modern syntax features in one module.

## Implementation

### `primer-2/src/complete-example.js`

```js
const validStatuses = new Set([
  "loading",
  "healthy",
  "degraded",
  "unavailable"
]);

class Service {
  #status;

  constructor({
    name,
    status = "loading",
    latencyMilliseconds = null,
    metadata = {}
  } = {}) {
    if (
      typeof name !== "string" ||
      name.trim() === ""
    ) {
      throw new TypeError(
        "name must be a non-empty string"
      );
    }

    if (!validStatuses.has(status)) {
      throw new RangeError(
        `invalid status: ${status}`
      );
    }

    this.name = name.trim();
    this.#status = status;
    this.latencyMilliseconds = latencyMilliseconds;
    this.metadata = {
      ...metadata
    };
  }

  get status() {
    return this.#status;
  }

  set status(value) {
    if (!validStatuses.has(value)) {
      throw new RangeError(
        `invalid status: ${value}`
      );
    }

    this.#status = value;
  }

  get summary() {
    const region =
      this.metadata?.region ?? "unknown";

    const latency =
      this.latencyMilliseconds ?? "unknown";

    return `${this.name}: ${this.status}; ` +
      `region=${region}; latency=${latency} ms`;
  }

  toJSON() {
    return {
      name: this.name,
      status: this.status,
      latencyMilliseconds:
        this.latencyMilliseconds,
      metadata: {
        ...this.metadata
      }
    };
  }
}

const service = new Service({
  name: "metrics",
  metadata: {
    region: "us-east"
  }
});

service.status = "healthy";
service.latencyMilliseconds = 42;

console.log(service.summary);
console.log(JSON.stringify(service));

const services = [
  service,
  new Service({
    name: "health",
    status: "degraded",
    latencyMilliseconds: 120
  })
];

const healthyServices = services
  .filter(({ status }) => status === "healthy")
  .map(({ name, latencyMilliseconds }) => ({
    name,
    latencyMilliseconds
  }));

console.log(healthyServices);
```

## Verification

Run:

```bash
node primer-2/src/complete-example.js
```

Expected output includes:

```text
metrics: healthy; region=us-east; latency=42 ms
[{"name":"metrics","status":"healthy","latencyMilliseconds":42,"metadata":{"region":"us-east"}}]
[ { name: 'metrics', latencyMilliseconds: 42 } ]
```

This example combines:

- Classes.
- Private fields.
- Getters and setters.
- Default parameters.
- Destructuring.
- Spread syntax.
- Optional chaining.
- Nullish coalescing.
- `Set`.
- Array methods.
- Object serialization.

---

# 39. Common Modern-Syntax Mistakes

## Mistake 1: Forgetting Parentheses Around Object Returns

Incorrect:

```js
const createService = (name) => {
  name,
  status: "loading"
};
```

Correct:

```js
const createService = (name) => ({
  name,
  status: "loading"
});
```

---

## Mistake 2: Using `||` When Zero Is Valid

Incorrect:

```js
const timeout = configuredTimeout || 5_000;
```

If `configuredTimeout` is `0`, it becomes `5_000`.

Correct when zero is valid:

```js
const timeout =
  configuredTimeout ?? 5_000;
```

---

## Mistake 3: Assuming Spread Is Deep

Incorrect assumption:

```js
const copy = { ...original };
copy.nested.value = 2;
```

The nested object may still be shared.

---

## Mistake 4: Treating Private Fields as Normal Properties

This does not work:

```js
object["#privateField"];
```

Private fields are accessed only from within the declaring class.

---

## Mistake 5: Using `for...in` for Array Values

Incorrect:

```js
for (const item in services) {
  console.log(item);
}
```

This prints indexes.

Correct:

```js
for (const service of services) {
  console.log(service);
}
```

---

## Mistake 6: Assuming Optional Chaining Validates Types

This prevents missing-property errors:

```js
logger?.info?.("message");
```

It does not validate that the method behaves correctly or that its arguments are valid.

---

## Mistake 7: Overusing Dynamic Imports

Dynamic imports add asynchronous control flow and can complicate startup behavior. Use them when lazy loading or environment-specific loading provides a real benefit.

---

# 40. Modern Syntax Readiness Checklist

You are ready for the next primer when you can explain and use:

## Core Syntax

- [ ] ECMAScript modules.
- [ ] Strict mode.
- [ ] `const` and `let`.
- [ ] Template literals.
- [ ] Arrow functions.
- [ ] Default parameters.
- [ ] Rest parameters.
- [ ] Spread syntax.

## Objects and Arrays

- [ ] Object shorthand.
- [ ] Computed properties.
- [ ] Destructuring.
- [ ] Optional chaining.
- [ ] Nullish coalescing.
- [ ] Logical assignment.
- [ ] `Object.entries()`.
- [ ] `Object.hasOwn()`.

## Classes

- [ ] Constructors.
- [ ] Instance methods.
- [ ] Inheritance.
- [ ] `super`.
- [ ] Getters and setters.
- [ ] Private fields.
- [ ] Static methods and fields.

## Collections

- [ ] `Map`.
- [ ] `Set`.
- [ ] `WeakMap`.
- [ ] `WeakSet`.
- [ ] Iterables.
- [ ] Generators.
- [ ] Symbols.
- [ ] `BigInt`.

## Modules

- [ ] Named imports and exports.
- [ ] Default imports and exports.
- [ ] Dynamic imports.
- [ ] Top-level `await`.

---

# 41. Complete Verification Commands

Run:

```bash
node primer-2/src/strict-modules.js
node primer-2/src/const-let.js
node primer-2/src/template-literals.js
node primer-2/src/destructuring.js
node primer-2/src/parameter-destructuring.js
node primer-2/src/spread-rest.js
node primer-2/src/optional-chaining.js
node primer-2/src/optional-chaining-errors.js
node primer-2/src/nullish-coalescing.js
node primer-2/src/logical-assignment.js
node primer-2/src/computed-properties.js
node primer-2/src/object-shorthand.js
node primer-2/src/arrow-functions.js
node primer-2/src/arrow-this.js
node primer-2/src/classes.js
node primer-2/src/inheritance.js
node primer-2/src/private-fields-safe.js
node primer-2/src/private-methods.js
node primer-2/src/getters-setters.js
node primer-2/src/static-members.js
node primer-2/src/has-own.js
node primer-2/src/object-iteration.js
node primer-2/src/modern-collections.js
node primer-2/src/set.js
node primer-2/src/weak-collections.js
node primer-2/src/iterables.js
node primer-2/src/generators.js
node primer-2/src/symbols.js
node primer-2/src/bigint.js
node primer-2/src/dynamic-import.js
node primer-2/src/dynamic-import-error.js
node primer-2/src/top-level-await.js
node primer-2/src/tagged-template.js
node primer-2/src/short-circuiting.js
node primer-2/src/object-integrity.js
node primer-2/src/structured-clone.js
node primer-2/src/complete-example.js
```

Every command should complete without an unexpected error.

---

# 42. Primer Summary

Modern JavaScript syntax gives us better tools for expressing application logic:

```text
destructuring
    │
    ▼
clear data extraction

spread and rest
    │
    ▼
controlled data copying and collection

optional chaining
    │
    ▼
safe access to optional values

nullish coalescing
    │
    ▼
correct defaults for null and undefined

classes and private fields
    │
    ▼
encapsulation and reusable behavior

Map and Set
    │
    ▼
purpose-built collections

dynamic import
    │
    ▼
lazy and conditional module loading
```

The most important practical rules are:

1. Use `const` by default.
2. Use `let` only when reassignment is required.
3. Prefer explicit modules.
4. Use `??` when falsy values such as `0` and `false` are valid.
5. Use optional chaining for optional structure, not as a replacement for validation.
6. Remember that object spread is shallow.
7. Use ordinary methods when dynamic `this` is needed.
8. Use arrow functions for lexical `this`.
9. Use private fields when class invariants require real encapsulation.
10. Use `Map` and `Set` when their semantics fit the data.
11. Use dynamic imports intentionally because they introduce asynchronous loading.
12. Keep syntax concise only when the result remains readable.

The next primer will cover Node.js, the command line, npm, project setup, environment variables, and the tools used to run the main series.
