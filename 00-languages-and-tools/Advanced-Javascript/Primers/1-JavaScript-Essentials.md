# Primer 1: JavaScript Essentials

This primer covers the JavaScript fundamentals required for the main series.

You will learn and verify:

- Values and variables.
- Primitive values and objects.
- Operators and comparisons.
- Functions.
- Arrays and objects.
- Destructuring.
- Spread and rest syntax.
- Control flow.
- Error handling.
- Modules.
- Basic type validation.

The goal is not to cover every JavaScript feature. The goal is to build a reliable foundation before studying execution contexts, closures, promises, proxies, memory, and resilience architecture.

---

# 1. Create the Primer Workspace

## The Target

We will create a standalone directory containing executable examples.

## The Concept

Each example should be runnable independently. This makes learning easier because you can change one concept without breaking unrelated examples.

## Implementation

Run:

```bash
mkdir -p primer-1/src
```

If the project already contains a `package.json`, add these scripts to its `"scripts"` object:

```json
{
  "primer:variables": "node primer-1/src/variables.js",
  "primer:values": "node primer-1/src/values.js",
  "primer:functions": "node primer-1/src/functions.js",
  "primer:collections": "node primer-1/src/collections.js",
  "primer:destructuring": "node primer-1/src/destructuring.js",
  "primer:control-flow": "node primer-1/src/control-flow.js",
  "primer:errors": "node primer-1/src/errors.js",
  "primer:modules": "node primer-1/src/modules.js"
}
```

Alternatively, you can run each file directly with `node`.

## Verification

Confirm Node.js is available:

```bash
node --version
```

You should use Node.js 20 or newer.

---

# 2. Values and Variables

## The Target

We will create variables using `const`, `let`, and `var`.

## The Concept

A variable is a named binding to a value.

Think of a variable as a labeled container:

```text
label: userName
value: "Ada"
```

Modern JavaScript primarily uses:

- `const` when the binding should not be reassigned.
- `let` when the binding must be reassigned.
- `var` mainly when reading older code.

## Implementation

### `primer-1/src/variables.js`

```js
"use strict";

const applicationName = "Runtime Monitor";
let refreshCount = 0;

refreshCount += 1;
refreshCount += 1;

console.log("application:", applicationName);
console.log("refresh count:", refreshCount);

const configuration = {
  environment: "development",
  timeoutMilliseconds: 5_000
};

/*
 * `const` prevents replacing the configuration binding, but the object itself
 * is still mutable unless we explicitly freeze it.
 */
configuration.timeoutMilliseconds = 10_000;

console.log("updated configuration:", configuration);

/*
 * This would fail because the `configuration` binding cannot be replaced:
 *
 * configuration = {};
 */

console.log("typeof applicationName:", typeof applicationName);
console.log("typeof refreshCount:", typeof refreshCount);
console.log("typeof configuration:", typeof configuration);
```

## Verification

Run:

```bash
node primer-1/src/variables.js
```

Expected output:

```text
application: Runtime Monitor
refresh count: 2
updated configuration: { environment: 'development', timeoutMilliseconds: 10000 }
typeof applicationName: string
typeof refreshCount: number
typeof configuration: object
```

## Important Distinction

`const` protects the binding, not necessarily the object:

```js
const user = {
  name: "Ada"
};

user.name = "Grace"; // allowed

// user = {}; // not allowed
```

To prevent direct mutation of the object’s top-level properties:

```js
const user = Object.freeze({
  name: "Ada"
});
```

`Object.freeze()` is shallow. Nested objects require additional handling.

---

# 3. Primitive Values

## The Target

We will examine JavaScript’s primitive value types.

## The Concept

A primitive is a basic value that is not an object.

Common primitive types are:

- String.
- Number.
- BigInt.
- Boolean.
- Undefined.
- Symbol.
- Null.

## Implementation

### `primer-1/src/values.js`

```js
"use strict";

const serviceName = "metrics";
const requestCount = 125;
const largeIdentifier = 9_007_199_254_740_993n;
const serviceHealthy = true;
let pendingValue;
const missingValue = null;
const uniqueKey = Symbol("service-key");

const values = {
  serviceName,
  requestCount,
  largeIdentifier,
  serviceHealthy,
  pendingValue,
  missingValue,
  uniqueKey
};

for (const [name, value] of Object.entries(values)) {
  console.log(`${name}:`, {
    value: String(value),
    type: typeof value
  });
}

console.log(
  "null typeof result:",
  typeof missingValue
);

console.log(
  "large identifier:",
  largeIdentifier
);

console.log(
  "safe integer check:",
  Number.isSafeInteger(requestCount)
);
```

## Verification

Run:

```bash
node primer-1/src/values.js
```

You should see:

```text
serviceName: { value: 'metrics', type: 'string' }
requestCount: { value: '125', type: 'number' }
largeIdentifier: { value: '9007199254740993', type: 'bigint' }
serviceHealthy: { value: 'true', type: 'boolean' }
pendingValue: { value: 'undefined', type: 'undefined' }
missingValue: { value: 'null', type: 'object' }
uniqueKey: { value: 'Symbol(service-key)', type: 'symbol' }
```

## Important Edge Case: `typeof null`

JavaScript reports:

```js
typeof null === "object"
```

This is a historical language behavior. Do not use `typeof` alone to determine whether a value is a non-null object.

Use:

```js
function isObject(value) {
  return value !== null && typeof value === "object";
}
```

---

# 4. Equality and Comparisons

## The Target

We will compare strict and loose equality.

## The Concept

Strict equality compares values without automatically converting their types.

```js
5 === "5" // false
```

Loose equality may convert types:

```js
5 == "5" // true
```

Production code should normally prefer strict equality:

- `===`
- `!==`

## Implementation

### `primer-1/src/comparisons.js`

```js
"use strict";

const numericValue = 5;
const stringValue = "5";

console.log("strict equality:", numericValue === stringValue);
console.log("loose equality:", numericValue == stringValue);

console.log("strict inequality:", numericValue !== stringValue);

console.log("null equals undefined:", null == undefined);
console.log("null strictly equals undefined:", null === undefined);

console.log("NaN equals NaN:", NaN === NaN);
console.log("Object.is NaN:", Object.is(NaN, NaN));

console.log("positive zero equals negative zero:", 0 === -0);
console.log(
  "Object.is positive and negative zero:",
  Object.is(0, -0)
);
```

## Verification

Run:

```bash
node primer-1/src/comparisons.js
```

Expected output:

```text
strict equality: false
loose equality: true
strict inequality: true
null equals undefined: true
null strictly equals undefined: false
NaN equals NaN: false
Object.is NaN: true
positive zero equals negative zero: true
Object.is positive and negative zero: false
```

## Practical Rule

Prefer:

```js
if (status === "healthy") {
  // ...
}
```

Avoid relying on implicit conversion:

```js
if (status == true) {
  // ...
}
```

---

# 5. Truthy and Falsy Values

## The Target

We will identify values JavaScript treats as false in conditions.

## The Concept

A **truthy** value behaves like `true` in a condition. A **falsy** value behaves like `false`.

Common falsy values:

```js
false
0
-0
0n
""
null
undefined
NaN
```

Objects and arrays are truthy, even when empty:

```js
Boolean([]); // true
Boolean({}); // true
```

## Implementation

### `primer-1/src/truthiness.js`

```js
"use strict";

const values = [
  false,
  0,
  -0,
  0n,
  "",
  null,
  undefined,
  NaN,
  [],
  {},
  "text",
  42
];

for (const value of values) {
  console.log({
    value: String(value),
    truthy: Boolean(value)
  });
}

const services = [];

if (services) {
  console.log("an empty array is truthy");
}

if (services.length === 0) {
  console.log("the array contains no items");
}
```

## Verification

Run:

```bash
node primer-1/src/truthiness.js
```

Confirm that an empty array is truthy.

## Common Mistake

This checks whether the array exists:

```js
if (services) {
  // services is defined
}
```

This checks whether the array contains items:

```js
if (services.length > 0) {
  // services contains at least one item
}
```

---

# 6. Functions

## The Target

We will create function declarations, function expressions, and arrow functions.

## The Concept

A function is a reusable operation.

Functions can:

- Receive arguments.
- Return values.
- Be assigned to variables.
- Be passed to other functions.
- Be returned from other functions.

## Implementation

### `primer-1/src/functions.js`

```js
"use strict";

function add(first, second) {
  return first + second;
}

const multiply = function multiply(first, second) {
  return first * second;
};

const subtract = (first, second) => {
  return first - second;
};

const square = (value) => value * value;

console.log("add:", add(2, 3));
console.log("multiply:", multiply(2, 3));
console.log("subtract:", subtract(5, 2));
console.log("square:", square(4));

function createServiceLabel(name, status = "unknown") {
  return `${name}: ${status}`;
}

console.log(
  createServiceLabel("metrics", "healthy")
);

console.log(
  createServiceLabel("health")
);
```

## Verification

Run:

```bash
npm run primer:functions
```

or:

```bash
node primer-1/src/functions.js
```

Expected output:

```text
add: 5
multiply: 6
subtract: 3
square: 16
metrics: healthy
health: unknown
```

---

# 7. Parameters and Arguments

## The Target

We will use default parameters, rest parameters, and argument validation.

## The Concept

A **parameter** is the name declared in a function definition.

An **argument** is the value supplied when calling the function.

```js
function greet(name) {
  // name is a parameter
}

greet("Ada");
// "Ada" is an argument
```

## Implementation

### `primer-1/src/parameters.js`

```js
"use strict";

function summarizeNumbers(...numbers) {
  if (numbers.length === 0) {
    return {
      count: 0,
      total: 0,
      average: null
    };
  }

  if (!numbers.every(Number.isFinite)) {
    throw new TypeError(
      "all arguments must be finite numbers"
    );
  }

  const total = numbers.reduce(
    (sum, number) => sum + number,
    0
  );

  return {
    count: numbers.length,
    total,
    average: total / numbers.length
  };
}

console.log(summarizeNumbers());
console.log(summarizeNumbers(10, 20, 30));

try {
  summarizeNumbers(10, "20");
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
node primer-1/src/parameters.js
```

Expected output:

```text
{ count: 0, total: 0, average: null }
{ count: 3, total: 60, average: 20 }
{
  name: 'TypeError',
  message: 'all arguments must be finite numbers'
}
```

---

# 8. Objects

## The Target

We will create and use objects.

## The Concept

An object groups related properties and behavior.

```js
const service = {
  name: "metrics",
  status: "healthy"
};
```

Properties can contain:

- Strings.
- Numbers.
- Booleans.
- Arrays.
- Other objects.
- Functions.

## Implementation

### `primer-1/src/objects.js`

```js
"use strict";

const service = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42,

  describe() {
    return `${this.name} is ${this.status}`;
  }
};

console.log("name:", service.name);
console.log("status:", service["status"]);
console.log("description:", service.describe());

service.status = "degraded";
service.errorRate = 0.05;

console.log("updated service:", service);

delete service.errorRate;

console.log("after deletion:", service);
```

## Verification

Run:

```bash
node primer-1/src/objects.js
```

Expected output includes:

```text
name: metrics
status: healthy
description: metrics is healthy
```

---

# 9. Optional Chaining and Nullish Coalescing

## The Target

We will safely read nested properties.

## The Concept

Optional chaining prevents an error when an intermediate value is `null` or `undefined`.

```js
user?.profile?.name
```

Nullish coalescing uses a fallback only when a value is `null` or `undefined`.

```js
const timeout = configuration.timeout ?? 5_000;
```

This differs from `||`, which also replaces valid falsy values such as `0` and `""`.

## Implementation

### `primer-1/src/safe-property-access.js`

```js
"use strict";

const response = {
  service: {
    name: "metrics",
    configuration: {
      timeoutMilliseconds: 2_000
    }
  }
};

const missingResponse = null;

console.log(
  response?.service?.configuration?.timeoutMilliseconds
);

console.log(
  missingResponse?.service?.configuration?.timeoutMilliseconds
);

const configuredTimeout =
  response.service.configuration.timeoutMilliseconds
  ?? 5_000;

const defaultTimeout =
  response.service.configuration.missingTimeout
  ?? 5_000;

console.log("configured timeout:", configuredTimeout);
console.log("default timeout:", defaultTimeout);

const zeroValue = 0;

console.log(
  "zero with ||:",
  zeroValue || 100
);

console.log(
  "zero with ?? :",
  zeroValue ?? 100
);
```

## Verification

Run:

```bash
node primer-1/src/safe-property-access.js
```

Expected output:

```text
2000
undefined
configured timeout: 2000
default timeout: 5000
zero with ||: 100
zero with ?? : 0
```

---

# 10. Arrays

## The Target

We will create and transform arrays.

## The Concept

An array is an ordered collection.

Important methods:

- `map()` transforms every item.
- `filter()` keeps matching items.
- `find()` returns the first matching item.
- `some()` checks whether at least one item matches.
- `every()` checks whether all items match.
- `reduce()` combines items into one result.
- `forEach()` performs an action for every item.

## Implementation

### `primer-1/src/collections.js`

```js
"use strict";

const services = [
  {
    name: "metrics",
    status: "healthy",
    latencyMilliseconds: 42
  },
  {
    name: "health",
    status: "degraded",
    latencyMilliseconds: 120
  },
  {
    name: "activity",
    status: "healthy",
    latencyMilliseconds: 30
  }
];

const names = services.map(
  (service) => service.name
);

const healthyServices = services.filter(
  (service) => service.status === "healthy"
);

const firstSlowService = services.find(
  (service) => service.latencyMilliseconds > 100
);

const hasUnavailableService = services.some(
  (service) => service.status === "unavailable"
);

const allHaveNames = services.every(
  (service) => typeof service.name === "string"
);

const totalLatency = services.reduce(
  (total, service) =>
    total + service.latencyMilliseconds,
  0
);

console.log("names:", names);
console.log("healthy services:", healthyServices);
console.log("first slow service:", firstSlowService);
console.log("has unavailable service:", hasUnavailableService);
console.log("all have names:", allHaveNames);
console.log("total latency:", totalLatency);
```

## Verification

Run:

```bash
npm run primer:collections
```

Expected output includes:

```text
names: [ 'metrics', 'health', 'activity' ]
has unavailable service: false
all have names: true
total latency: 192
```

## Important Mutation Difference

These methods create new arrays:

```js
map()
filter()
slice()
```

These methods mutate the original array:

```js
push()
pop()
shift()
unshift()
splice()
sort()
reverse()
```

Be deliberate about whether an operation should mutate existing data.

---

# 11. Destructuring

## The Target

We will extract values from objects and arrays.

## The Concept

Destructuring is a concise way to unpack values.

Without destructuring:

```js
const name = service.name;
const status = service.status;
```

With destructuring:

```js
const { name, status } = service;
```

## Implementation

### `primer-1/src/destructuring.js`

```js
"use strict";

const service = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42
};

const {
  name,
  status,
  latencyMilliseconds
} = service;

console.log({
  name,
  status,
  latencyMilliseconds
});

const {
  name: serviceName,
  status: serviceStatus
} = service;

console.log({
  serviceName,
  serviceStatus
});

const services = [
  "metrics",
  "health",
  "activity"
];

const [
  firstService,
  secondService,
  thirdService
] = services;

console.log({
  firstService,
  secondService,
  thirdService
});

const [
  first,
  ...remainingServices
] = services;

console.log({
  first,
  remainingServices
});
```

## Verification

Run:

```bash
npm run primer:destructuring
```

Expected output includes:

```text
{
  name: 'metrics',
  status: 'healthy',
  latencyMilliseconds: 42
}
{
  serviceName: 'metrics',
  serviceStatus: 'healthy'
}
{
  firstService: 'metrics',
  secondService: 'health',
  thirdService: 'activity'
}
{
  first: 'metrics',
  remainingServices: [ 'health', 'activity' ]
}
```

---

# 12. Spread Syntax

## The Target

We will copy and combine arrays and objects.

## The Concept

Spread syntax expands the contents of an iterable or object.

## Arrays

```js
const combined = [...first, ...second];
```

## Objects

```js
const next = {
  ...previous,
  status: "healthy"
};
```

This is the foundation of many immutable-update patterns.

## Implementation

### `primer-1/src/spread.js`

```js
"use strict";

const originalServices = [
  "metrics",
  "health"
];

const allServices = [
  ...originalServices,
  "activity"
];

console.log("original:", originalServices);
console.log("all:", allServices);

const baseConfiguration = {
  timeoutMilliseconds: 5_000,
  retryAttempts: 3
};

const productionConfiguration = {
  ...baseConfiguration,
  timeoutMilliseconds: 10_000
};

console.log(
  "base configuration:",
  baseConfiguration
);

console.log(
  "production configuration:",
  productionConfiguration
);

const service = {
  name: "metrics",
  status: "loading"
};

const healthyService = {
  ...service,
  status: "healthy",
  latencyMilliseconds: 42
};

console.log("original service:", service);
console.log("healthy service:", healthyService);
```

## Verification

Run:

```bash
node primer-1/src/spread.js
```

Confirm that `service` remains unchanged while `healthyService` contains the new values.

---

# 13. Rest Parameters and Rest Properties

## The Target

We will collect remaining arguments and properties.

## The Concept

Rest syntax gathers multiple values into one array or object.

## Implementation

### `primer-1/src/rest.js`

```js
"use strict";

function createService(name, status, ...metadata) {
  return {
    name,
    status,
    metadata
  };
}

console.log(
  createService(
    "metrics",
    "healthy",
    {
      region: "us-east"
    },
    {
      owner: "platform"
    }
  )
);

const service = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42,
  region: "us-east"
};

const {
  name,
  status,
  ...details
} = service;

console.log({
  name,
  status,
  details
});
```

## Verification

Run:

```bash
node primer-1/src/rest.js
```

Expected output includes:

```text
{
  name: 'metrics',
  status: 'healthy',
  metadata: [
    { region: 'us-east' },
    { owner: 'platform' }
  ]
}
{
  name: 'metrics',
  status: 'healthy',
  details: { latencyMilliseconds: 42, region: 'us-east' }
}
```

---

# 14. Control Flow

## The Target

We will use conditionals, loops, and `switch`.

## The Concept

Control flow determines which instructions run and how often.

Use:

- `if` for conditions.
- `switch` for known discrete cases.
- `for...of` to iterate values.
- `for` when indexes or precise control are required.
- `while` when the number of iterations is not known in advance.

## Implementation

### `primer-1/src/control-flow.js`

```js
"use strict";

function describeStatus(status) {
  if (status === "healthy") {
    return "service is operating normally";
  }

  if (status === "degraded") {
    return "service is operating with reduced performance";
  }

  if (status === "unavailable") {
    return "service cannot be reached";
  }

  return "service status is unknown";
}

console.log(describeStatus("healthy"));
console.log(describeStatus("degraded"));
console.log(describeStatus("unavailable"));
console.log(describeStatus("other"));

const statuses = [
  "healthy",
  "degraded",
  "unavailable"
];

for (const status of statuses) {
  console.log(`${status}: ${describeStatus(status)}`);
}

for (let index = 0; index < statuses.length; index += 1) {
  console.log(`index ${index}: ${statuses[index]}`);
}

function statusCode(status) {
  switch (status) {
    case "healthy":
      return 200;

    case "degraded":
      return 206;

    case "unavailable":
      return 503;

    default:
      return 500;
  }
}

console.log("healthy code:", statusCode("healthy"));
console.log("unknown code:", statusCode("unknown"));
```

## Verification

Run:

```bash
npm run primer:control-flow
```

---

# 15. `for...of` Versus `for...in`

## The Target

We will distinguish values from property names.

## The Concept

Use `for...of` for iterable values:

```js
for (const service of services) {
  // service is an item
}
```

Use `for...in` for enumerable property names:

```js
for (const property in service) {
  // property is a string key
}
```

## Implementation

### `primer-1/src/iteration.js`

```js
"use strict";

const services = ["metrics", "health"];

for (const service of services) {
  console.log("for...of value:", service);
}

const service = {
  name: "metrics",
  status: "healthy"
};

for (const property in service) {
  console.log(
    "for...in property:",
    property,
    "value:",
    service[property]
  );
}
```

## Verification

Run:

```bash
node primer-1/src/iteration.js
```

Expected output includes:

```text
for...of value: metrics
for...of value: health
for...in property: name value: metrics
for...in property: status value: healthy
```

Use `Object.keys()`, `Object.values()`, or `Object.entries()` when you want explicit object iteration.

---

# 16. Error Handling

## The Target

We will throw, catch, and rethrow errors.

## The Concept

Errors are part of normal program design.

Use:

- `throw` to signal failure.
- `try` to wrap risky work.
- `catch` to handle failure.
- `finally` for cleanup that must always happen.

## Implementation

### `primer-1/src/errors.js`

```js
"use strict";

function parsePositiveInteger(value, fieldName) {
  const parsedValue = Number(value);

  if (
    !Number.isInteger(parsedValue) ||
    parsedValue <= 0
  ) {
    const error = new TypeError(
      `${fieldName} must be a positive integer`
    );

    error.code = "INVALID_INPUT";

    throw error;
  }

  return parsedValue;
}

function createRequestConfiguration(input) {
  try {
    const timeoutMilliseconds =
      parsePositiveInteger(
        input.timeoutMilliseconds,
        "timeoutMilliseconds"
      );

    return {
      timeoutMilliseconds
    };
  } catch (error) {
    /*
     * Preserve the original error while adding higher-level context.
     */
    throw new Error(
      "request configuration is invalid",
      {
        cause: error
      }
    );
  }
}

try {
  const configuration =
    createRequestConfiguration({
      timeoutMilliseconds: "5000"
    });

  console.log(configuration);
} catch (error) {
  console.error("unexpected configuration error:", error);
}

try {
  createRequestConfiguration({
    timeoutMilliseconds: "invalid"
  });
} catch (error) {
  console.log("handled error:", error.message);
  console.log(
    "original cause:",
    error.cause?.message
  );
} finally {
  console.log("validation attempt finished");
}
```

## Verification

Run:

```bash
npm run primer:errors
```

Expected output includes:

```text
{ timeoutMilliseconds: 5000 }
handled error: request configuration is invalid
original cause: timeoutMilliseconds must be a positive integer
validation attempt finished
```

---

# 17. Creating Custom Errors

## The Target

We will create an application-specific error class.

## The Concept

Custom errors allow callers to distinguish failure categories without parsing message text.

## Implementation

### `primer-1/src/custom-errors.js`

```js
"use strict";

class ValidationError extends Error {
  constructor(message, field) {
    super(message);

    this.name = "ValidationError";
    this.field = field;
  }
}

function validateServiceName(name) {
  if (
    typeof name !== "string" ||
    name.trim() === ""
  ) {
    throw new ValidationError(
      "service name must be a non-empty string",
      "name"
    );
  }

  return name.trim();
}

try {
  validateServiceName("");
} catch (error) {
  if (error instanceof ValidationError) {
    console.log({
      type: "validation",
      field: error.field,
      message: error.message
    });
  } else {
    throw error;
  }
}
```

## Verification

Run:

```bash
node primer-1/src/custom-errors.js
```

Expected output:

```text
{
  type: 'validation',
  field: 'name',
  message: 'service name must be a non-empty string'
}
```

---

# 18. Modules

## The Target

We will create an exported utility and import it from another module.

## The Concept

A module is a file with an explicit interface.

Exports define what other files may use. Imports declare dependencies.

This is better than relying on global variables because dependencies are visible.

## Implementation

### `primer-1/src/format-service.js`

```js
"use strict";

export function formatService(service) {
  if (
    service === null ||
    typeof service !== "object"
  ) {
    throw new TypeError(
      "service must be an object"
    );
  }

  if (
    typeof service.name !== "string" ||
    typeof service.status !== "string"
  ) {
    throw new TypeError(
      "service must have name and status strings"
    );
  }

  return `${service.name}: ${service.status}`;
}

export const supportedStatuses = Object.freeze([
  "loading",
  "healthy",
  "degraded",
  "unavailable"
]);
```

### `primer-1/src/modules.js`

```js
"use strict";

import {
  formatService,
  supportedStatuses
} from "./format-service.js";

const service = {
  name: "metrics",
  status: "healthy"
};

console.log(formatService(service));
console.log(supportedStatuses);
```

## Verification

Run:

```bash
npm run primer:modules
```

Expected output:

```text
metrics: healthy
[ 'loading', 'healthy', 'degraded', 'unavailable' ]
```

---

# 19. Default Exports

## The Target

We will create and import a default export.

## Concept

A module can have one default export:

```js
export default value;
```

Import it without braces:

```js
import value from "./module.js";
```

Named exports use braces:

```js
import { namedValue } from "./module.js";
```

## Implementation

### `primer-1/src/default-service.js`

```js
"use strict";

export default function createService(name) {
  if (
    typeof name !== "string" ||
    name.trim() === ""
  ) {
    throw new TypeError(
      "name must be a non-empty string"
    );
  }

  return Object.freeze({
    name: name.trim(),
    status: "loading"
  });
}
```

### `primer-1/src/default-import.js`

```js
"use strict";

import createService from "./default-service.js";

console.log(createService("metrics"));
```

## Verification

Run:

```bash
node primer-1/src/default-import.js
```

Expected output:

```text
{ name: 'metrics', status: 'loading' }
```

Use named exports when a module exposes several related public functions. Use default exports when a module has one central concept.

---

# 20. Type Validation

## The Target

We will create reusable validation helpers.

## The Concept

JavaScript is dynamically typed. This means values do not need a declared type before execution.

Dynamic typing is flexible, but production code must validate values at boundaries.

Boundaries include:

- Function arguments.
- HTTP responses.
- Environment variables.
- Files.
- User input.
- Database results.
- Message queues.

## Implementation

### `primer-1/src/validation.js`

```js
"use strict";

export function assertNonEmptyString(
  value,
  fieldName
) {
  if (
    typeof value !== "string" ||
    value.trim() === ""
  ) {
    throw new TypeError(
      `${fieldName} must be a non-empty string`
    );
  }

  return value.trim();
}

export function assertFiniteNumber(
  value,
  fieldName
) {
  if (!Number.isFinite(value)) {
    throw new TypeError(
      `${fieldName} must be a finite number`
    );
  }

  return value;
}

export function assertNonNegativeNumber(
  value,
  fieldName
) {
  assertFiniteNumber(value, fieldName);

  if (value < 0) {
    throw new RangeError(
      `${fieldName} must be non-negative`
    );
  }

  return value;
}

export function assertPlainObject(
  value,
  fieldName
) {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new TypeError(
      `${fieldName} must be a plain object`
    );
  }

  return value;
}
```

### `primer-1/src/validation-example.js`

```js
"use strict";

import {
  assertNonEmptyString,
  assertNonNegativeNumber,
  assertPlainObject
} from "./validation.js";

const serviceName = assertNonEmptyString(
  "metrics",
  "serviceName"
);

const latency = assertNonNegativeNumber(
  42,
  "latency"
);

const configuration = assertPlainObject(
  {
    timeoutMilliseconds: 5_000
  },
  "configuration"
);

console.log({
  serviceName,
  latency,
  configuration
});
```

## Verification

Run:

```bash
node primer-1/src/validation-example.js
```

Expected output:

```text
{
  serviceName: 'metrics',
  latency: 42,
  configuration: { timeoutMilliseconds: 5000 }
}
```

---

# 21. JSON Serialization

## The Target

We will convert JavaScript values to JSON and back.

## The Concept

JSON is a text format commonly used for APIs and configuration.

JavaScript object:

```js
{
  name: "metrics"
}
```

JSON text:

```json
{
  "name": "metrics"
}
```

Use:

- `JSON.stringify()` to create JSON text.
- `JSON.parse()` to read JSON text.

## Implementation

### `primer-1/src/json.js`

```js
"use strict";

const service = {
  name: "metrics",
  status: "healthy",
  latencyMilliseconds: 42
};

const serialized = JSON.stringify(service);

console.log("serialized:", serialized);

const parsed = JSON.parse(serialized);

console.log("parsed:", parsed);
console.log(
  "parsed is a separate object:",
  parsed !== service
);

try {
  JSON.parse("{ invalid json");
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
node primer-1/src/json.js
```

Expected output includes:

```text
serialized: {"name":"metrics","status":"healthy","latencyMilliseconds":42}
parsed is a separate object: true
```

## Important Limitations

JSON does not preserve every JavaScript value:

```js
JSON.stringify({
  missing: undefined,
  functionValue: () => {},
  symbolValue: Symbol("value")
});
```

Those properties may be omitted.

JSON also does not preserve:

- Functions.
- Symbols.
- `BigInt` without custom handling.
- Class prototypes.
- `Map` and `Set` structure automatically.
- `undefined` object properties.

---

# 22. Immutability Basics

## The Target

We will compare mutation and immutable updates.

## The Concept

Mutation edits an existing value.

Immutable updates create a replacement value.

## Implementation

### `primer-1/src/immutability.js`

```js
"use strict";

const originalState = {
  status: "loading",
  requestCount: 0
};

const mutatedState = originalState;

mutatedState.status = "healthy";

console.log(
  "original after mutation:",
  originalState
);

const initialState = {
  status: "loading",
  requestCount: 0
};

const nextState = {
  ...initialState,
  status: "healthy",
  requestCount: initialState.requestCount + 1
};

console.log("initial state:", initialState);
console.log("next state:", nextState);
console.log(
  "different root references:",
  initialState !== nextState
);
```

## Verification

Run:

```bash
node primer-1/src/immutability.js
```

Expected output includes:

```text
different root references: true
```

Immutable updates are especially useful for state management, undo functionality, change detection, and predictable tests.

---

# 23. Shallow Copies and Nested Objects

## The Target

We will see why spread syntax creates only a shallow copy.

## Implementation

### `primer-1/src/shallow-copy.js`

```js
"use strict";

const original = {
  service: {
    name: "metrics",
    status: "loading"
  }
};

const copy = {
  ...original
};

copy.service.status = "healthy";

console.log("original:", original);
console.log("copy:", copy);
console.log(
  "nested object shared:",
  original.service === copy.service
);
```

## Verification

Run:

```bash
node primer-1/src/shallow-copy.js
```

Expected output:

```text
original: { service: { name: 'metrics', status: 'healthy' } }
copy: { service: { name: 'metrics', status: 'healthy' } }
nested object shared: true
```

For nested immutable updates, copy every changed level:

```js
const next = {
  ...original,
  service: {
    ...original.service,
    status: "healthy"
  }
};
```

---

# 24. Complete Essentials Example

## The Target

We will combine:

- Validation.
- Objects.
- Arrays.
- Pure functions.
- Immutable updates.
- Modules.

## Implementation

### `primer-1/src/complete-example.js`

```js
"use strict";

function assertNonEmptyString(value, fieldName) {
  if (
    typeof value !== "string" ||
    value.trim() === ""
  ) {
    throw new TypeError(
      `${fieldName} must be a non-empty string`
    );
  }

  return value.trim();
}

function assertStatus(status) {
  const validStatuses = new Set([
    "loading",
    "healthy",
    "degraded",
    "unavailable"
  ]);

  if (!validStatuses.has(status)) {
    throw new RangeError(
      `invalid service status: ${status}`
    );
  }

  return status;
}

function createService({
  name,
  status = "loading",
  latencyMilliseconds = null
}) {
  const normalizedName = assertNonEmptyString(
    name,
    "name"
  );

  const normalizedStatus = assertStatus(status);

  if (
    latencyMilliseconds !== null &&
    (
      !Number.isFinite(latencyMilliseconds) ||
      latencyMilliseconds < 0
    )
  ) {
    throw new RangeError(
      "latencyMilliseconds must be null or non-negative"
    );
  }

  return Object.freeze({
    name: normalizedName,
    status: normalizedStatus,
    latencyMilliseconds
  });
}

function updateServiceStatus(
  services,
  serviceName,
  status
) {
  const normalizedName = assertNonEmptyString(
    serviceName,
    "serviceName"
  );

  assertStatus(status);

  if (!services[normalizedName]) {
    throw new Error(
      `unknown service: ${normalizedName}`
    );
  }

  return {
    ...services,

    [normalizedName]: {
      ...services[normalizedName],
      status
    }
  };
}

function selectHealthyServices(services) {
  return Object.values(services).filter(
    (service) => service.status === "healthy"
  );
}

function createSummary(services) {
  const allServices = Object.values(services);
  const healthyServices =
    selectHealthyServices(services);

  return {
    totalServices: allServices.length,
    healthyServices: healthyServices.length,
    unavailableServices: allServices.filter(
      (service) =>
        service.status === "unavailable"
    ).length
  };
}

const services = {
  metrics: createService({
    name: "metrics",
    status: "loading",
    latencyMilliseconds: null
  }),

  health: createService({
    name: "health",
    status: "healthy",
    latencyMilliseconds: 20
  })
};

const updatedServices = updateServiceStatus(
  services,
  "metrics",
  "healthy"
);

console.log("original services:", services);
console.log("updated services:", updatedServices);
console.log("summary:", createSummary(updatedServices));
```

## Verification

Run:

```bash
node primer-1/src/complete-example.js
```

Expected output includes:

```text
summary: {
  totalServices: 2,
  healthyServices: 2,
  unavailableServices: 0
}
```

---

# 25. Primer Readiness Exercises

Before continuing to Part 1, complete these exercises.

## Exercise 1: Add a Service

Add an `activity` service:

```js
activity: createService({
  name: "activity",
  status: "degraded",
  latencyMilliseconds: 150
})
```

Verify that:

```js
createSummary(updatedServices)
```

reports three total services.

---

## Exercise 2: Select Fast Services

Write:

```js
function selectFastServices(services, maximumLatency) {
  // return services with latency <= maximumLatency
}
```

Expected behavior:

```js
selectFastServices(services, 50);
```

should return services with latency at most 50 milliseconds.

---

## Exercise 3: Create a Notification

Write an immutable function:

```js
function addNotification(state, notification) {
  // return a new state
}
```

It must not mutate the original state.

---

## Exercise 4: Validate Configuration

Create:

```js
function createConfiguration(input) {
  // validate timeoutMilliseconds
  // validate retryAttempts
  // return a frozen configuration
}
```

Reject:

- Negative timeout.
- Zero retry attempts.
- Non-numeric values.
- Missing required fields.

---

# 26. Readiness Checklist

You are ready for Part 1 when you can explain and use:

## Variables

- [ ] Difference between `const`, `let`, and `var`.
- [ ] Difference between a binding and an object value.
- [ ] Why `const` does not automatically freeze objects.

## Values

- [ ] Primitive values.
- [ ] Objects and arrays.
- [ ] Why `typeof null` reports `"object"`.
- [ ] Why strict equality is preferred.

## Functions

- [ ] Parameters and arguments.
- [ ] Function declarations.
- [ ] Function expressions.
- [ ] Arrow functions.
- [ ] Default and rest parameters.
- [ ] Returning values.

## Collections

- [ ] `map()`.
- [ ] `filter()`.
- [ ] `find()`.
- [ ] `some()`.
- [ ] `every()`.
- [ ] `reduce()`.
- [ ] Mutation versus non-mutating methods.

## Objects

- [ ] Property access.
- [ ] Methods.
- [ ] Object spread.
- [ ] Optional chaining.
- [ ] Nullish coalescing.
- [ ] Shallow copying.

## Errors

- [ ] `throw`.
- [ ] `try`.
- [ ] `catch`.
- [ ] `finally`.
- [ ] Custom error classes.
- [ ] Error causes.

## Modules

- [ ] Named exports.
- [ ] Default exports.
- [ ] Relative import paths.
- [ ] Explicit dependencies.

---

# 27. Complete Verification Commands

Run each example:

```bash
node primer-1/src/variables.js
node primer-1/src/values.js
node primer-1/src/comparisons.js
node primer-1/src/truthiness.js
node primer-1/src/functions.js
node primer-1/src/parameters.js
node primer-1/src/objects.js
node primer-1/src/safe-property-access.js
node primer-1/src/collections.js
node primer-1/src/destructuring.js
node primer-1/src/spread.js
node primer-1/src/rest.js
node primer-1/src/control-flow.js
node primer-1/src/iteration.js
node primer-1/src/errors.js
node primer-1/src/custom-errors.js
node primer-1/src/modules.js
node primer-1/src/default-import.js
node primer-1/src/validation-example.js
node primer-1/src/json.js
node primer-1/src/immutability.js
node primer-1/src/shallow-copy.js
node primer-1/src/complete-example.js
```

If all examples run successfully, the JavaScript essentials foundation is ready.

---

# 28. Primer Summary

The foundational JavaScript model is:

```text
values
  │
  ▼
variables and bindings
  │
  ▼
functions
  │
  ▼
objects and collections
  │
  ▼
transformations
  │
  ▼
validated state
  │
  ▼
modules
```

The most important habits are:

1. Prefer `const` unless reassignment is required.
2. Use strict equality.
3. Validate values at boundaries.
4. Keep functions focused.
5. Use immutable updates when state history matters.
6. Avoid hidden mutation.
7. Separate pure transformations from side effects.
8. Make module dependencies explicit.
9. Handle expected errors intentionally.
10. Test behavior rather than relying on assumptions.

These fundamentals prepare you for the next primer, which will cover modern JavaScript syntax in more detail.
