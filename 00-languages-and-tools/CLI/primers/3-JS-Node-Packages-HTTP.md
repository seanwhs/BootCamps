# Primer 3: JavaScript, Node.js, Packages, and HTTP Fundamentals

Part 3 of the main series builds a Node.js HTTP service. Before working with Express, npm scripts, tests, and build automation, you need a small set of JavaScript and web-development concepts.

This primer explains:

- The relationship between JavaScript and Node.js
- How Node.js executes a file
- Values, variables, arrays, and objects
- Functions and return values
- Conditions and loops
- JSON serialization
- CommonJS modules
- Synchronous and asynchronous work
- Promises and `async`/`await`
- Error handling
- Processes, arguments, exit codes, and signals
- Packages and dependencies
- `package.json`, lockfiles, and `node_modules`
- HTTP clients, servers, methods, routes, status codes, and bodies
- How to build and test a small server using only Node.js

The goal is not to teach all of JavaScript. It is to establish the vocabulary and mental models required by Part 3.

---

# Primer Architecture

You will build this small laboratory:

```text
$HOME/
└── node-http-primer/
    ├── src/
    │   ├── config.js
    │   ├── math.js
    │   └── server.js
    ├── scripts/
    │   └── inspect-runtime.js
    ├── test/
    │   └── server.test.js
    ├── package.json
    └── package-lock.json
```

The final server will expose:

```text
GET  /         → service information
GET  /health   → health information
POST /echo     → return a JSON request body
GET  /missing  → structured 404 response
```

Only built-in Node.js modules will be used. No third-party package is required.

---

# P3.1 Distinguish JavaScript from Node.js

## The Target

Understand the relationship between the JavaScript language and the Node.js runtime.

## The Concept

**JavaScript** is a programming language. It defines syntax such as:

```javascript
const message = "Hello";
console.log(message);
```

**Node.js** is a runtime that executes JavaScript outside a browser.

A useful analogy is:

```text
JavaScript → written musical score
Node.js    → musician who performs it
```

The same language can run in different environments, but each environment supplies different capabilities.

A browser provides APIs such as:

```javascript
document.querySelector("button");
```

Node.js instead provides server and operating-system APIs such as:

```javascript
const fs = require("node:fs");
```

`document` is not normally available in Node.js because a Node.js process does not automatically have a web page.

## The Implementation

Verify Node.js:

```powershell
node --version
```

Execute JavaScript directly with `-e`:

```powershell
node -e 'console.log("JavaScript is running inside Node.js.");'
```

Inspect runtime information:

```powershell
node -e 'console.log({
  nodeVersion: process.version,
  platform: process.platform,
  architecture: process.arch
});'
```

Check whether browser and Node.js globals exist:

```powershell
node -e 'console.log({
  documentType: typeof document,
  processType: typeof process,
  requireType: typeof require
});'
```

Expected values include:

```text
documentType : undefined
processType  : object
requireType  : function
```

## The Verification

Run:

```powershell
node -e '
if (typeof process !== "object") {
  throw new Error("The Node.js process object is unavailable.");
}

if (typeof require !== "function") {
  throw new Error("CommonJS require is unavailable.");
}

console.log("The Node.js runtime check passed.");
'
```

Expected output:

```text
The Node.js runtime check passed.
```

---

# P3.2 Create the Primer Project

## The Target

Create:

```text
$HOME\node-http-primer
```

and initialize it as an npm project.

## The Concept

A Node.js project is a directory containing source code and a `package.json` manifest.

The manifest is the project’s control panel. It can describe:

- The project’s name and version
- Its supported Node.js version
- Its dependencies
- Its executable scripts
- Its module system

## The Implementation

Construct the project path:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "node-http-primer"
```

If a previous primer copy exists, inspect it before deciding whether to reset it:

```powershell
if (Test-Path -LiteralPath $primerRoot) {
    Get-ChildItem `
        -LiteralPath $primerRoot `
        -Recurse `
        -Force |
        Select-Object FullName
}
```

To create a clean disposable copy, run:

```powershell
$expectedPrimerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "node-http-primer"

if ($primerRoot -ne $expectedPrimerRoot) {
    throw "Unexpected primer path: $primerRoot"
}

if (Test-Path -LiteralPath $primerRoot) {
    Remove-Item `
        -LiteralPath $primerRoot `
        -Recurse `
        -Force `
        -ErrorAction Stop
}

$null = New-Item `
    -Path $primerRoot `
    -ItemType Directory `
    -ErrorAction Stop

Set-Location -LiteralPath $primerRoot
```

Initialize npm:

```powershell
npm.cmd init -y
```

Create source, script, and test directories:

```powershell
foreach ($directoryName in @(
    "src"
    "scripts"
    "test"
)) {
    $null = New-Item `
        -Path (Join-Path $primerRoot $directoryName) `
        -ItemType Directory `
        -Force `
        -ErrorAction Stop
}
```

## The Verification

Confirm the structure:

```powershell
[PSCustomObject]@{
    ProjectExists = Test-Path `
        -LiteralPath $primerRoot `
        -PathType Container
    PackageManifestExists = Test-Path `
        -LiteralPath "$primerRoot\package.json" `
        -PathType Leaf
    SourceDirectoryExists = Test-Path `
        -LiteralPath "$primerRoot\src" `
        -PathType Container
    TestDirectoryExists = Test-Path `
        -LiteralPath "$primerRoot\test" `
        -PathType Container
}
```

Every value should be `True`.

Parse the generated manifest:

```powershell
Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json |
    Select-Object Name, Version
```

---

# P3.3 Understand JavaScript Values and Types

## The Target

Recognize the primitive values used by the tutorial application.

## The Concept

A value is a piece of data.

Common JavaScript primitive types include:

| Type | Example |
|---|---|
| String | `"development"` |
| Number | `3000` |
| Boolean | `true` |
| Undefined | `undefined` |
| Null | `null` |
| BigInt | `9007199254740993n` |
| Symbol | `Symbol("id")` |

Applications also use composite values such as arrays and objects.

JavaScript is dynamically typed. A variable’s type comes from its current value rather than a separately declared static type.

## The Implementation

Run:

```powershell
node -e '
const environment = "development";
const port = 3000;
const enabled = true;
const missingValue = undefined;
const intentionallyEmpty = null;

console.log({
  environment,
  environmentType: typeof environment,
  port,
  portType: typeof port,
  enabled,
  enabledType: typeof enabled,
  missingValueType: typeof missingValue,
  intentionallyEmpty,
  nullType: typeof intentionallyEmpty,
});
'
```

Notice this historical JavaScript behavior:

```javascript
typeof null === "object"
```

Despite that result, `null` represents an intentional absence of value. It is not an ordinary application object.

Numbers do not distinguish integers and decimal values at the `typeof` level:

```powershell
node -e '
console.log({
  integerType: typeof 3000,
  decimalType: typeof 19.95,
  integerCheck: Number.isInteger(3000),
  decimalCheck: Number.isInteger(19.95),
});
'
```

## The Verification

Run:

```powershell
node -e '
const checks = {
  string: typeof "development" === "string",
  number: typeof 3000 === "number",
  boolean: typeof true === "boolean",
  undefined: typeof undefined === "undefined",
  integer: Number.isInteger(3000),
};

if (Object.values(checks).some((passed) => !passed)) {
  throw new Error(`Type check failed: ${JSON.stringify(checks)}`);
}

console.log("JavaScript value-type checks passed.");
'
```

---

# P3.4 Understand `const`, `let`, and Assignment

## The Target

Declare variables and understand when reassignment is allowed.

## The Concept

Use `const` when a variable should not be assigned a different value:

```javascript
const host = "127.0.0.1";
```

Use `let` when reassignment is intentional:

```javascript
let requestCount = 0;
requestCount += 1;
```

Avoid `var` in modern introductory code because its function-scoping and hoisting behavior is easier to misuse.

`const` prevents reassignment of the variable. It does not deeply freeze an object:

```javascript
const config = {
  port: 3000,
};

config.port = 4000; // Allowed.
```

The variable still references the same object.

## The Implementation

Run:

```powershell
node -e '
const serviceName = "node-http-primer";

let requestCount = 0;
requestCount += 1;
requestCount += 1;

console.log({
  serviceName,
  requestCount,
});
'
```

Observe object mutation:

```powershell
node -e '
const configuration = {
  port: 3000,
};

configuration.port = 3100;

console.log(configuration);
'
```

Create an immutable shallow object:

```powershell
node -e '
const configuration = Object.freeze({
  host: "127.0.0.1",
  port: 3000,
});

console.log({
  configuration,
  frozen: Object.isFrozen(configuration),
});
'
```

## The Verification

Run:

```powershell
node -e '
const serviceName = "node-http-primer";
let counter = 0;
counter += 1;

if (serviceName !== "node-http-primer") {
  throw new Error("Unexpected service name.");
}

if (counter !== 1) {
  throw new Error("Counter reassignment failed.");
}

console.log("Variable checks passed.");
'
```

---

# P3.5 Understand Arrays and Objects

## The Target

Store ordered collections and named properties.

## The Concept

An **array** is an ordered collection:

```javascript
const environments = [
  "development",
  "test",
  "production",
];
```

An **object** groups values under named keys:

```javascript
const configuration = {
  environment: "development",
  port: 3000,
};
```

Think of an array as a numbered shelf and an object as a labeled filing cabinet.

Array indexes begin at zero:

```javascript
environments[0]
```

Object properties can be read with dot notation:

```javascript
configuration.port
```

or bracket notation:

```javascript
configuration["port"]
```

## The Implementation

Run:

```powershell
node -e '
const environments = [
  "development",
  "test",
  "production",
];

const configuration = {
  serviceName: "node-http-primer",
  environment: environments[0],
  host: "127.0.0.1",
  port: 3000,
};

console.log({
  firstEnvironment: environments[0],
  environmentCount: environments.length,
  portFromDotNotation: configuration.port,
  portFromBracketNotation: configuration["port"],
});
'
```

Add an array element:

```powershell
node -e '
const routes = ["/", "/health"];

routes.push("/echo");

console.log(routes);
'
```

Use object-property shorthand:

```javascript
const host = "127.0.0.1";
const port = 3000;

const configuration = {
  host,
  port,
};
```

This is equivalent to:

```javascript
const configuration = {
  host: host,
  port: port,
};
```

## The Verification

Run:

```powershell
node -e '
const routes = ["/", "/health", "/echo"];

const configuration = {
  host: "127.0.0.1",
  port: 3000,
};

const checks = [
  routes.length === 3,
  routes.includes("/health"),
  configuration.host === "127.0.0.1",
  configuration.port === 3000,
];

if (!checks.every(Boolean)) {
  throw new Error("Array or object verification failed.");
}

console.log("Array and object checks passed.");
'
```

---

# P3.6 Understand Strict Equality and Conditions

## The Target

Use conditions to choose behavior.

## The Concept

An `if` statement executes code when its condition is true:

```javascript
if (port > 0) {
  console.log("The port is positive.");
}
```

Use strict equality:

```javascript
===
```

and strict inequality:

```javascript
!==
```

Strict comparison avoids automatic type conversion.

For example:

```javascript
"3000" == 3000  // true because conversion occurs
"3000" === 3000 // false because the types differ
```

Production-quality code generally prefers strict equality.

## The Implementation

Run:

```powershell
node -e '
const rawPort = "3000";
const parsedPort = Number(rawPort);

console.log({
  looseComparison: rawPort == parsedPort,
  strictComparison: rawPort === parsedPort,
  parsedStrictComparison: parsedPort === 3000,
});

if (!Number.isInteger(parsedPort)) {
  throw new Error("The port must be an integer.");
}

if (parsedPort < 1 || parsedPort > 65535) {
  throw new Error("The port must be between 1 and 65535.");
}

console.log("The port is valid.");
'
```

Logical operators include:

| Operator | Meaning |
|---|---|
| `&&` | Both conditions must be true |
| `\|\|` | At least one condition must be true |
| `!` | Reverse true and false |

## The Verification

Run:

```powershell
node -e '
const environment = "development";
const port = 3000;

const environmentIsAllowed = [
  "development",
  "test",
  "production",
].includes(environment);

const portIsAllowed =
  Number.isInteger(port) &&
  port >= 1 &&
  port <= 65535;

if (!environmentIsAllowed || !portIsAllowed) {
  throw new Error("Configuration validation failed.");
}

console.log("Conditional validation passed.");
'
```

---

# P3.7 Understand Functions and Return Values

## The Target

Create reusable JavaScript behavior with functions.

## The Concept

A function is a named or reusable block of behavior.

It can:

- Receive input through parameters
- Perform work
- Return a result

For example:

```javascript
function add(left, right) {
  return left + right;
}
```

Call it with arguments:

```javascript
const total = add(2, 3);
```

Here:

- `left` and `right` are parameters.
- `2` and `3` are arguments.
- `5` is the return value.

## The Implementation

Run:

```powershell
node -e '
function buildAddress(host, port) {
  return `http://${host}:${port}`;
}

const address = buildAddress("127.0.0.1", 3000);

console.log(address);
'
```

The backtick-delimited JavaScript string is a **template literal**. Expressions inside `${...}` are inserted into the string.

Create a function that validates a port:

```powershell
node -e '
function parsePort(rawValue) {
  if (!/^\d+$/.test(rawValue)) {
    throw new Error("Port must contain only digits.");
  }

  const port = Number(rawValue);

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error("Port must be from 1 through 65535.");
  }

  return port;
}

console.log(parsePort("3000"));
'
```

An arrow function provides another syntax:

```javascript
const double = (value) => value * 2;
```

For beginner-facing application code, use whichever form communicates intent most clearly.

## The Verification

Run:

```powershell
node -e '
function buildAddress(host, port) {
  return `http://${host}:${port}`;
}

const address = buildAddress("127.0.0.1", 3000);

if (address !== "http://127.0.0.1:3000") {
  throw new Error(`Unexpected address: ${address}`);
}

console.log("Function verification passed.");
'
```

---

# P3.8 Create and Import a CommonJS Module

## The Target

Create:

```text
src\math.js
```

and import it from another Node.js file.

## The Concept

A **module** is a file with a defined public interface.

Modules separate responsibilities. Instead of placing every function in one large file, one module can export specific functionality:

```javascript
module.exports = {
  add,
  multiply,
};
```

Another file imports that public interface:

```javascript
const { add } = require("./math");
```

This project uses **CommonJS**, Node.js’s established `require` and `module.exports` module system.

## The Implementation

Create the module.

### File: `node-http-primer/src/math.js`

```powershell
$mathModuleContent = @'
"use strict";

function add(left, right) {
  return left + right;
}

function multiply(left, right) {
  return left * right;
}

module.exports = {
  add,
  multiply,
};
'@

Set-Content `
    -LiteralPath "$primerRoot\src\math.js" `
    -Value $mathModuleContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Load it:

```powershell
node -e '
const { add, multiply } = require("./src/math");

console.log({
  sum: add(2, 3),
  product: multiply(4, 5),
});
'
```

The relative module path begins with:

```text
./
```

Without `./`, Node.js would interpret `math` as a built-in or installed package name rather than a nearby file.

## The Verification

Check syntax:

```powershell
node --check .\src\math.js
```

Verify behavior:

```powershell
node -e '
const { add, multiply } = require("./src/math");

if (add(2, 3) !== 5) {
  throw new Error("add returned an incorrect result.");
}

if (multiply(4, 5) !== 20) {
  throw new Error("multiply returned an incorrect result.");
}

console.log("CommonJS module verification passed.");
'
```

---

# P3.9 Understand JSON

## The Target

Convert between JavaScript objects and JSON text.

## The Concept

**JSON**, or JavaScript Object Notation, is a text format used to exchange structured data.

A JavaScript object exists in memory:

```javascript
const value = {
  status: "ok",
};
```

JSON is text:

```json
{
  "status": "ok"
}
```

Convert an object to JSON with:

```javascript
JSON.stringify(value)
```

Convert JSON text to an object with:

```javascript
JSON.parse(text)
```

JSON is not executable JavaScript. It supports data, not functions or comments.

## The Implementation

Run:

```powershell
node -e '
const responseObject = {
  status: "ok",
  ready: true,
  count: 3,
};

const jsonText = JSON.stringify(responseObject, null, 2);
const parsedObject = JSON.parse(jsonText);

console.log(jsonText);
console.log({
  parsedStatus: parsedObject.status,
  parsedReady: parsedObject.ready,
});
'
```

Observe that JSON property names and string values use double quotes.

## The Verification

Run:

```powershell
node -e '
const original = {
  service: "node-http-primer",
  status: "ok",
};

const text = JSON.stringify(original);
const restored = JSON.parse(text);

if (restored.service !== original.service) {
  throw new Error("JSON service property did not survive.");
}

if (restored.status !== original.status) {
  throw new Error("JSON status property did not survive.");
}

console.log("JSON round-trip verification passed.");
'
```

---

# P3.10 Understand Synchronous and Asynchronous Work

## The Target

Distinguish operations that complete immediately from operations that finish later.

## The Concept

**Synchronous** code completes one step before the next step begins.

```javascript
const total = 2 + 3;
console.log(total);
```

Some operations take time:

- Reading a large file
- Waiting for a timer
- Sending an HTTP request
- Querying a database

JavaScript represents many future results with a **Promise**.

A Promise is like a claim ticket:

> The final value is not ready yet, but this object represents the future outcome.

A Promise can:

- Fulfill with a value
- Reject with an error

## The Implementation

Observe execution order:

```powershell
node -e '
console.log("1. Start");

setTimeout(() => {
  console.log("3. Timer completed");
}, 100);

console.log("2. End of synchronous work");
'
```

Expected order:

```text
1. Start
2. End of synchronous work
3. Timer completed
```

Create a Promise:

```powershell
node -e '
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

delay(100).then(() => {
  console.log("The Promise fulfilled.");
});
'
```

## The Verification

Run:

```powershell
node -e '
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

const startedAt = Date.now();

delay(100).then(() => {
  const elapsed = Date.now() - startedAt;

  if (elapsed < 80) {
    throw new Error(`Delay finished unexpectedly early: ${elapsed}ms`);
  }

  console.log("Asynchronous verification passed.");
});
'
```

---

# P3.11 Understand `async` and `await`

## The Target

Write asynchronous code in a readable sequential style.

## The Concept

An `async` function always returns a Promise.

Inside it, `await` pauses that function until a Promise settles. It does not freeze the whole computer or Node.js runtime.

Compare:

```javascript
delay(100).then(() => {
  console.log("Finished");
});
```

with:

```javascript
await delay(100);
console.log("Finished");
```

The second form often reads more like ordinary step-by-step code.

## The Implementation

Run:

```powershell
node -e '
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function main() {
  console.log("Waiting...");
  await delay(100);
  console.log("Finished.");
}

main();
'
```

A top-level `await` is not available in every CommonJS file context, so the common pattern is:

```javascript
async function main() {
  // Await asynchronous operations here.
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Run that pattern:

```powershell
node -e '
async function main() {
  const value = await Promise.resolve("ready");
  console.log(value);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
'
```

## The Verification

Run:

```powershell
node -e '
async function calculate() {
  const left = await Promise.resolve(20);
  const right = await Promise.resolve(22);

  return left + right;
}

async function main() {
  const result = await calculate();

  if (result !== 42) {
    throw new Error(`Expected 42, received ${result}`);
  }

  console.log("async/await verification passed.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
'
```

---

# P3.12 Handle Errors

## The Target

Create, throw, catch, and report JavaScript errors.

## The Concept

An error represents a failed operation or invalid state.

Create and throw one:

```javascript
throw new Error("The port is invalid.");
```

Catch a synchronous or awaited failure:

```javascript
try {
  // Work that may fail.
} catch (error) {
  console.error(error.message);
}
```

Do not silently discard errors. Report enough context to diagnose the problem, but do not print secrets.

## The Implementation

Run:

```powershell
node -e '
function parsePort(rawValue) {
  if (!/^\d+$/.test(rawValue)) {
    throw new Error("PORT must contain only digits.");
  }

  const port = Number(rawValue);

  if (port < 1 || port > 65535) {
    throw new Error("PORT is outside the valid range.");
  }

  return port;
}

try {
  parsePort("invalid");
} catch (error) {
  console.error("Configuration error:", error.message);
}
'
```

Handle an asynchronous rejection:

```powershell
node -e '
async function failAsync() {
  throw new Error("Asynchronous operation failed.");
}

async function main() {
  try {
    await failAsync();
  } catch (error) {
    console.error("Handled:", error.message);
  }
}

main();
'
```

Set a failing process exit code:

```powershell
node -e '
try {
  throw new Error("Controlled failure.");
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
'

$LASTEXITCODE
```

Expected exit code:

```text
1
```

## The Verification

Run a successful child process:

```powershell
node -e 'process.exitCode = 0;'
$successExitCode = $LASTEXITCODE
```

Run a failing child process:

```powershell
node -e 'process.exitCode = 1;'
$failureExitCode = $LASTEXITCODE
```

Check both:

```powershell
[PSCustomObject]@{
    SuccessExitCode = $successExitCode
    FailureExitCode = $failureExitCode
    Passed = (
        $successExitCode -eq 0 -and
        $failureExitCode -eq 1
    )
}
```

`Passed` should be `True`.

---

# P3.13 Understand the Node.js Process

## The Target

Inspect command-line arguments, environment variables, the current working directory, and exit codes.

## The Concept

A **process** is a running instance of a program.

When PowerShell starts Node.js, the Node.js child process receives:

- Command-line arguments
- A working directory
- A copy of PowerShell’s environment
- Standard input and output streams
- A process identifier
- Operating-system signals

Node.js exposes this information through:

```javascript
process
```

## The Implementation

Create a runtime-inspection script.

### File: `node-http-primer/scripts/inspect-runtime.js`

```powershell
$runtimeScriptContent = @'
"use strict";

const path = require("node:path");

const userArguments = process.argv.slice(2);

const report = {
  nodeExecutable: process.execPath,
  scriptPath: path.resolve(__filename),
  currentWorkingDirectory: process.cwd(),
  processId: process.pid,
  platform: process.platform,
  nodeVersion: process.version,
  userArguments,
  primerMode: process.env.PRIMER_MODE ?? "[not set]",
};

console.log(JSON.stringify(report, null, 2));
'@

Set-Content `
    -LiteralPath "$primerRoot\scripts\inspect-runtime.js" `
    -Value $runtimeScriptContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Run it with arguments:

```powershell
node .\scripts\inspect-runtime.js alpha beta
```

Set a temporary environment variable and run it again:

```powershell
$env:PRIMER_MODE = "training"

try {
    node .\scripts\inspect-runtime.js one two three
}
finally {
    Remove-Item Env:PRIMER_MODE -ErrorAction SilentlyContinue
}
```

`process.argv` contains:

1. The Node.js executable path
2. The script path
3. User-supplied arguments

That is why the script uses:

```javascript
process.argv.slice(2)
```

## The Verification

Run:

```powershell
$output = node .\scripts\inspect-runtime.js verify 42
$report = $output -join "`n" | ConvertFrom-Json

[PSCustomObject]@{
    HasNodeExecutable = -not [string]::IsNullOrWhiteSpace(
        $report.nodeExecutable
    )
    HasScriptPath = -not [string]::IsNullOrWhiteSpace(
        $report.scriptPath
    )
    HasProcessId = $report.processId -gt 0
    FirstArgumentCorrect = $report.userArguments[0] -eq "verify"
    SecondArgumentCorrect = $report.userArguments[1] -eq "42"
}
```

Every value should be `True`.

---

# P3.14 Understand Packages and Dependencies

## The Target

Understand how npm packages fit into a Node.js application.

## The Concept

A **package** is a reusable unit of JavaScript code distributed with metadata.

A project may depend on packages directly:

```text
your application
└── express
```

Those packages may have dependencies of their own:

```text
your application
└── package A
    ├── package B
    └── package C
```

B and C are **transitive dependencies** because your project receives them through A.

npm manages four closely related resources:

```text
package.json
      ↓
package-lock.json
      ↓
npm install / npm ci
      ↓
node_modules
```

A useful analogy is:

| Resource | Analogy |
|---|---|
| `package.json` | Requested ingredients and project recipes |
| `package-lock.json` | Exact supplier receipt |
| `node_modules` | Ingredients currently on the workbench |
| npm | Supplier and task runner |
| npm scripts | Standardized project recipes |

## The Implementation

Inspect the generated `package.json`:

```powershell
Get-Content `
    -LiteralPath .\package.json `
    -Raw
```

Ask npm to generate a lockfile without adding external dependencies:

```powershell
npm.cmd install
```

Inspect the resulting files:

```powershell
Get-ChildItem `
    -LiteralPath $primerRoot `
    -Force |
    Select-Object Name, Length, Attributes
```

Parse the lockfile:

```powershell
$lockData = Get-Content `
    -LiteralPath .\package-lock.json `
    -Raw |
    ConvertFrom-Json

$lockData |
    Select-Object Name, Version, LockfileVersion
```

Because this project currently has no third-party packages, `node_modules` may be absent or nearly empty. That is acceptable.

## The Verification

Run:

```powershell
[PSCustomObject]@{
    ManifestExists = Test-Path `
        -LiteralPath .\package.json `
        -PathType Leaf
    LockfileExists = Test-Path `
        -LiteralPath .\package-lock.json `
        -PathType Leaf
    ManifestIsValidJson = $null -ne (
        Get-Content `
            -LiteralPath .\package.json `
            -Raw |
            ConvertFrom-Json
    )
    LockfileIsValidJson = $null -ne $lockData
}
```

Every value should be `True`.

---

# P3.15 Distinguish Runtime and Development Dependencies

## The Target

Understand where npm records different kinds of dependencies.

## The Concept

A **runtime dependency** is required while the application runs:

```text
dependencies
```

A **development dependency** supports development, testing, linting, or building:

```text
devDependencies
```

Examples:

```text
Express → usually a runtime dependency
ESLint  → usually a development dependency
```

Installation commands are:

```powershell
npm.cmd install express
npm.cmd install --save-dev eslint
```

This primer does not need either package, so you will not install them here.

## The Implementation

Display a representative manifest fragment without changing the project:

```powershell
$dependencyExample = @'
{
  "dependencies": {
    "express": "^5.0.0"
  },
  "devDependencies": {
    "eslint": "^9.0.0"
  }
}
'@

$parsedDependencyExample = $dependencyExample |
    ConvertFrom-Json

$parsedDependencyExample.dependencies |
    Format-List

$parsedDependencyExample.devDependencies |
    Format-List
```

Inspect this project’s currently declared dependencies:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    RuntimeDependencies = @(
        $packageData.dependencies.PSObject.Properties
    ).Count
    DevelopmentDependencies = @(
        $packageData.devDependencies.PSObject.Properties
    ).Count
}
```

Depending on how PowerShell represents absent properties, use this safer inspection:

```powershell
$hasRuntimeDependencies = (
    $null -ne $packageData.dependencies
)

$hasDevelopmentDependencies = (
    $null -ne $packageData.devDependencies
)

[PSCustomObject]@{
    HasRuntimeDependencies = $hasRuntimeDependencies
    HasDevelopmentDependencies = $hasDevelopmentDependencies
}
```

Both may be `False`, which is correct for this built-in-only primer.

## The Verification

Ask npm for the top-level dependency tree:

```powershell
npm.cmd list --depth=0
```

The command should complete without dependency errors.

---

# P3.16 Understand npm Scripts

## The Target

Replace the generated manifest with explicit scripts for syntax checking, testing, and starting the server.

## The Concept

An npm script is a named command stored in `package.json`.

Instead of requiring every developer to remember:

```powershell
node --test
```

the project provides:

```powershell
npm.cmd test
```

Scripts make the project itself the source of truth for routine operations.

## The Implementation

Replace the manifest.

### File: `node-http-primer/package.json`

```powershell
$packageJsonContent = @'
{
  "name": "node-http-primer",
  "version": "1.0.0",
  "description": "A small Node.js and HTTP fundamentals laboratory.",
  "private": true,
  "main": "src/server.js",
  "type": "commonjs",
  "engines": {
    "node": ">=20"
  },
  "scripts": {
    "check:syntax": "node --check src/math.js && node --check src/config.js && node --check src/server.js && node --check scripts/inspect-runtime.js && node --check test/server.test.js",
    "test": "node --test",
    "start": "node src/server.js",
    "check": "npm run check:syntax && npm test"
  },
  "keywords": [
    "node",
    "http",
    "primer"
  ],
  "license": "MIT"
}
'@

Set-Content `
    -LiteralPath "$primerRoot\package.json" `
    -Value $packageJsonContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

Update the lockfile to match the new manifest:

```powershell
npm.cmd install
```

List scripts:

```powershell
npm.cmd run
```

Do not run `check:syntax` yet because `config.js`, `server.js`, and the test file have not been created.

## The Verification

Parse and inspect the scripts:

```powershell
$packageData = Get-Content `
    -LiteralPath .\package.json `
    -Raw |
    ConvertFrom-Json

[PSCustomObject]@{
    CorrectName = $packageData.name -eq "node-http-primer"
    IsPrivate = $packageData.private -eq $true
    UsesCommonJs = $packageData.type -eq "commonjs"
    HasStartScript = $null -ne $packageData.scripts.start
    HasTestScript = $null -ne $packageData.scripts.test
    HasCheckScript = $null -ne $packageData.scripts.check
}
```

Every value should be `True`.

---

# P3.17 Understand HTTP

## The Target

Learn the components of an HTTP request and response.

## The Concept

**HTTP**, or Hypertext Transfer Protocol, is a request-response protocol.

A **client** sends a request:

```text
PowerShell, browser, mobile app, or another server
```

A **server** receives the request and returns a response.

Consider:

```text
GET http://127.0.0.1:3000/health
│   │         │      │
│   │         │      └─ path or route
│   │         └──────── port
│   └────────────────── host
└────────────────────── method
```

### Method

The method describes the request’s intent:

| Method | Typical purpose |
|---|---|
| `GET` | Retrieve data |
| `POST` | Submit or create data |
| `PUT` | Replace a resource |
| `PATCH` | Partially update a resource |
| `DELETE` | Remove a resource |

HTTP conventions do not enforce business authorization. A server must still validate every request.

### Host

The host identifies the machine or network interface:

```text
127.0.0.1
```

This is the IPv4 loopback address, which points back to the current computer.

### Port

The port identifies a listening application on that host:

```text
3000
```

A port is like a numbered door in a building.

### Route or path

The route identifies a resource or operation:

```text
/health
```

### Status code

The response status summarizes the result:

| Status | Meaning |
|---|---|
| `200` | Success |
| `201` | Created |
| `204` | Success with no response body |
| `400` | Bad request |
| `401` | Authentication required or failed |
| `403` | Request understood but forbidden |
| `404` | Resource not found |
| `409` | Conflict |
| `500` | Internal server error |
| `503` | Service unavailable |

### Headers

Headers carry metadata:

```text
Content-Type: application/json
```

### Body

A body carries request or response data:

```json
{
  "status": "ok"
}
```

## The Implementation

Construct a URI object in PowerShell:

```powershell
$uri = [System.Uri]"http://127.0.0.1:3000/health"

[PSCustomObject]@{
    Scheme = $uri.Scheme
    Host = $uri.Host
    Port = $uri.Port
    Path = $uri.AbsolutePath
}
```

Expected values:

```text
Scheme : http
Host   : 127.0.0.1
Port   : 3000
Path   : /health
```

## The Verification

Run:

```powershell
[PSCustomObject]@{
    SchemeIsHttp = $uri.Scheme -eq "http"
    HostIsLoopback = $uri.Host -eq "127.0.0.1"
    PortIs3000 = $uri.Port -eq 3000
    RouteIsHealth = $uri.AbsolutePath -eq "/health"
}
```

Every value should be `True`.

---

# P3.18 Create a Configuration Module

## The Target

Create:

```text
src\config.js
```

that validates host and port values.

## The Concept

Environment variables are strings. Applications should validate and convert them before use.

This module provides defaults for the primer:

```text
HOST=127.0.0.1
PORT=3000
```

A later primer covers environment variables and secrets in depth.

## The Implementation

Create the complete module.

### File: `node-http-primer/src/config.js`

```powershell
$configModuleContent = @'
"use strict";

function parsePort(rawValue) {
  if (!/^\d+$/.test(rawValue)) {
    throw new Error("PORT must contain only decimal digits.");
  }

  const port = Number(rawValue);

  if (!Number.isSafeInteger(port) || port < 1 || port > 65_535) {
    throw new Error("PORT must be an integer from 1 through 65535.");
  }

  return port;
}

function parseHost(rawValue) {
  const host = rawValue.trim();

  if (host.length === 0) {
    throw new Error("HOST cannot be empty.");
  }

  if (/\s/.test(host)) {
    throw new Error("HOST cannot contain whitespace.");
  }

  return host;
}

function loadConfiguration(environment = process.env) {
  const host = parseHost(environment.HOST ?? "127.0.0.1");
  const port = parsePort(environment.PORT ?? "3000");

  return Object.freeze({
    host,
    port,
  });
}

module.exports = {
  loadConfiguration,
  parseHost,
  parsePort,
};
'@

Set-Content `
    -LiteralPath "$primerRoot\src\config.js" `
    -Value $configModuleContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

## The Verification

Check syntax:

```powershell
node --check .\src\config.js
```

Test valid configuration:

```powershell
node -e '
const { loadConfiguration } = require("./src/config");

const configuration = loadConfiguration({
  HOST: "127.0.0.1",
  PORT: "3100",
});

console.log({
  configuration,
  portType: typeof configuration.port,
  frozen: Object.isFrozen(configuration),
});
'
```

Test invalid configuration:

```powershell
node -e '
const { parsePort } = require("./src/config");

try {
  parsePort("invalid");
  throw new Error("Invalid port was unexpectedly accepted.");
} catch (error) {
  if (!error.message.includes("decimal digits")) {
    throw error;
  }

  console.log("Invalid port was rejected correctly.");
}
'
```

---

# P3.19 Build a Node.js HTTP Server

## The Target

Create:

```text
src\server.js
```

using Node.js’s built-in `node:http` module.

## The Concept

An HTTP server:

1. Listens on a host and port.
2. Receives a request object.
3. Chooses behavior from the method and path.
4. Writes a status, headers, and body.
5. Ends the response.

The request body arrives as a stream of data chunks rather than one guaranteed complete string. The server must collect those chunks before parsing JSON.

To limit memory use, the echo route rejects bodies larger than 16 KiB.

## The Implementation

Create the complete server.

### File: `node-http-primer/src/server.js`

```powershell
$serverContent = @'
"use strict";

const http = require("node:http");
const { loadConfiguration } = require("./config");

const MAXIMUM_BODY_BYTES = 16 * 1024;
const SHUTDOWN_TIMEOUT_MS = 5_000;

function sendJson(response, statusCode, value) {
  const body = JSON.stringify(value);

  response.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8",
    "content-length": Buffer.byteLength(body),
  });

  response.end(body);
}

function readJsonBody(request) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let receivedBytes = 0;
    let settled = false;

    function rejectOnce(error) {
      if (settled) {
        return;
      }

      settled = true;
      reject(error);
    }

    request.on("data", (chunk) => {
      receivedBytes += chunk.length;

      if (receivedBytes > MAXIMUM_BODY_BYTES) {
        rejectOnce(new Error("REQUEST_BODY_TOO_LARGE"));
        request.destroy();
        return;
      }

      chunks.push(chunk);
    });

    request.on("end", () => {
      if (settled) {
        return;
      }

      try {
        const text = Buffer.concat(chunks).toString("utf8");
        const value = text.length === 0 ? {} : JSON.parse(text);

        settled = true;
        resolve(value);
      } catch {
        rejectOnce(new Error("INVALID_JSON"));
      }
    });

    request.on("error", rejectOnce);
  });
}

function createRequestHandler() {
  return async function handleRequest(request, response) {
    const requestUrl = new URL(
      request.url ?? "/",
      "http://localhost",
    );

    if (request.method === "GET" && requestUrl.pathname === "/") {
      sendJson(response, 200, {
        service: "node-http-primer",
        message: "The primer server is running.",
      });
      return;
    }

    if (
      request.method === "GET" &&
      requestUrl.pathname === "/health"
    ) {
      sendJson(response, 200, {
        status: "ok",
        uptimeSeconds: Math.floor(process.uptime()),
        timestamp: new Date().toISOString(),
      });
      return;
    }

    if (
      request.method === "POST" &&
      requestUrl.pathname === "/echo"
    ) {
      try {
        const requestBody = await readJsonBody(request);

        sendJson(response, 200, {
          received: requestBody,
        });
      } catch (error) {
        if (error.message === "INVALID_JSON") {
          sendJson(response, 400, {
            error: "The request body must contain valid JSON.",
          });
          return;
        }

        if (error.message === "REQUEST_BODY_TOO_LARGE") {
          if (!response.headersSent) {
            sendJson(response, 413, {
              error: "The request body is too large.",
            });
          }
          return;
        }

        console.error("Unexpected request-body error:", error);

        if (!response.headersSent) {
          sendJson(response, 500, {
            error: "Internal Server Error",
          });
        }
      }

      return;
    }

    sendJson(response, 404, {
      error: "Not Found",
      method: request.method,
      path: requestUrl.pathname,
    });
  };
}

function startServer(configuration = loadConfiguration()) {
  const requestHandler = createRequestHandler();
  const server = http.createServer(requestHandler);

  server.listen(
    configuration.port,
    configuration.host,
    () => {
      console.log(
        `node-http-primer listening at ` +
          `http://${configuration.host}:${configuration.port}`,
      );
    },
  );

  return server;
}

if (require.main === module) {
  let configuration;

  try {
    configuration = loadConfiguration();
  } catch (error) {
    console.error("Configuration error:", error.message);
    process.exit(1);
  }

  const server = startServer(configuration);
  let shutdownStarted = false;

  function shutdown(signal) {
    if (shutdownStarted) {
      return;
    }

    shutdownStarted = true;
    console.log(`Received ${signal}. Closing the server.`);

    const timer = setTimeout(() => {
      console.error("Graceful shutdown timed out.");
      process.exit(1);
    }, SHUTDOWN_TIMEOUT_MS);

    timer.unref();

    server.close((error) => {
      clearTimeout(timer);

      if (error) {
        console.error("Server shutdown failed:", error);
        process.exit(1);
      }

      console.log("Server closed.");
      process.exit(0);
    });
  }

  process.on("SIGINT", () => {
    shutdown("SIGINT");
  });

  process.on("SIGTERM", () => {
    shutdown("SIGTERM");
  });
}

module.exports = {
  createRequestHandler,
  startServer,
};
'@

Set-Content `
    -LiteralPath "$primerRoot\src\server.js" `
    -Value $serverContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

The condition:

```javascript
if (require.main === module)
```

means:

> Start listening only when this file is executed directly.

If a test imports the module, the server does not start automatically.

## The Verification

Check syntax:

```powershell
node --check .\src\server.js
```

Load the module without opening a port:

```powershell
node -e '
const {
  createRequestHandler,
  startServer,
} = require("./src/server");

console.log({
  requestHandlerFactory: typeof createRequestHandler,
  serverStarter: typeof startServer,
});
'
```

Expected values:

```text
requestHandlerFactory : function
serverStarter         : function
```

---

# P3.20 Run and Call the HTTP Server

## The Target

Start the server and send HTTP requests from PowerShell.

## The Concept

The server terminal and client terminal play different roles:

```text
Terminal 1: Node.js server
Terminal 2: PowerShell HTTP client
```

The server remains active while waiting for requests. Therefore, use a second terminal for verification.

## The Implementation

In the first terminal, ensure no temporary overrides remain:

```powershell
Remove-Item Env:HOST -ErrorAction SilentlyContinue
Remove-Item Env:PORT -ErrorAction SilentlyContinue
```

Start the server:

```powershell
npm.cmd start
```

Expected output:

```text
node-http-primer listening at http://127.0.0.1:3000
```

In a second PowerShell terminal, call the root route:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/" `
    -Method Get
```

Call the health route:

```powershell
$health = Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get

$health |
    Format-List
```

Call the echo route:

```powershell
$requestBody = @{
    message = "Hello from PowerShell"
    ready = $true
} | ConvertTo-Json

$echoResponse = Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $requestBody

$echoResponse.received |
    Format-List
```

Call an unknown route:

```powershell
try {
    Invoke-RestMethod `
        -Uri "http://127.0.0.1:3000/missing" `
        -Method Get `
        -ErrorAction Stop
}
catch {
    Write-Host "The unknown route returned an HTTP error as expected." `
        -ForegroundColor Green

    Write-Host $_.Exception.Message
}
```

Return to the server terminal and press `Ctrl+C`.

## The Verification

Before stopping the server, verify the response objects in the client terminal:

```powershell
[PSCustomObject]@{
    HealthIsOk = $health.status -eq "ok"
    HasUptime = $null -ne $health.uptimeSeconds
    HasTimestamp = -not [string]::IsNullOrWhiteSpace(
        $health.timestamp
    )
    EchoMessageMatches = (
        $echoResponse.received.message -eq
        "Hello from PowerShell"
    )
    EchoReadyMatches = (
        $echoResponse.received.ready -eq $true
    )
}
```

Every value should be `True`.

---

# P3.21 Understand Graceful Shutdown and Signals

## The Target

Understand why the server handles `SIGINT` and `SIGTERM`.

## The Concept

A signal is an operating-system notification sent to a process.

Two common termination signals are:

| Signal | Common source |
|---|---|
| `SIGINT` | Interactive interruption such as `Ctrl+C` |
| `SIGTERM` | Request from an operating system or process manager to terminate |

A graceful shutdown:

1. Stops accepting new connections.
2. Closes the server.
3. Allows the process to exit.
4. Uses a timeout in case shutdown stalls.

This is like closing a shop by locking the entrance and completing existing transactions instead of switching off the electricity.

## The Implementation

Start the server:

```powershell
npm.cmd start
```

Press:

```text
Ctrl+C
```

Expected output includes:

```text
Received SIGINT. Closing the server.
Server closed.
```

The code responsible is:

```javascript
process.on("SIGINT", () => {
  shutdown("SIGINT");
});

process.on("SIGTERM", () => {
  shutdown("SIGTERM");
});
```

and:

```javascript
server.close((error) => {
  // Exit after the server has closed.
});
```

## The Verification

Start it again, call `/health`, and stop it:

```powershell
npm.cmd start
```

From a second terminal:

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health"
```

Return to the server and press `Ctrl+C`. Confirm that the terminal returns to its PowerShell prompt after printing the shutdown messages.

---

# P3.22 Create Automated HTTP Tests

## The Target

Create:

```text
test\server.test.js
```

using Node.js’s built-in test runner.

## The Concept

An automated test is an executable claim about behavior.

The test server listens on port `0`:

```javascript
server.listen(0, "127.0.0.1");
```

Port `0` tells Windows to assign an available temporary port. This avoids conflicts with an existing development server.

Each test:

1. Starts a server.
2. Sends a real HTTP request.
3. Checks the response.
4. Closes the server.

## The Implementation

Create the complete test file.

### File: `node-http-primer/test/server.test.js`

```powershell
$serverTestContent = @'
"use strict";

const assert = require("node:assert/strict");
const http = require("node:http");
const { afterEach, test } = require("node:test");
const { createRequestHandler } = require("../src/server");

const activeServers = new Set();

async function startTestServer() {
  const server = http.createServer(createRequestHandler());

  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });

  activeServers.add(server);

  const address = server.address();

  if (address === null || typeof address === "string") {
    throw new Error("The server did not expose a TCP address.");
  }

  return {
    server,
    baseUrl: `http://127.0.0.1:${address.port}`,
  };
}

async function closeServer(server) {
  if (!activeServers.has(server)) {
    return;
  }

  await new Promise((resolve, reject) => {
    server.close((error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });

  activeServers.delete(server);
}

afterEach(async () => {
  await Promise.all(
    [...activeServers].map((server) => closeServer(server)),
  );
});

test("GET / returns service information", async () => {
  const { server, baseUrl } = await startTestServer();

  const response = await fetch(`${baseUrl}/`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.service, "node-http-primer");
  assert.equal(body.message, "The primer server is running.");

  await closeServer(server);
});

test("GET /health returns health information", async () => {
  const { server, baseUrl } = await startTestServer();

  const response = await fetch(`${baseUrl}/health`);
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.status, "ok");
  assert.equal(typeof body.uptimeSeconds, "number");
  assert.match(body.timestamp, /^\d{4}-\d{2}-\d{2}T/);

  await closeServer(server);
});

test("POST /echo returns a JSON request body", async () => {
  const { server, baseUrl } = await startTestServer();

  const requestBody = {
    message: "Automated test",
    ready: true,
  };

  const response = await fetch(`${baseUrl}/echo`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(requestBody),
  });

  const body = await response.json();

  assert.equal(response.status, 200);
  assert.deepEqual(body.received, requestBody);

  await closeServer(server);
});

test("POST /echo rejects malformed JSON", async () => {
  const { server, baseUrl } = await startTestServer();

  const response = await fetch(`${baseUrl}/echo`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: "{invalid-json",
  });

  const body = await response.json();

  assert.equal(response.status, 400);
  assert.equal(
    body.error,
    "The request body must contain valid JSON.",
  );

  await closeServer(server);
});

test("an unknown route returns status 404", async () => {
  const { server, baseUrl } = await startTestServer();

  const response = await fetch(`${baseUrl}/missing`);
  const body = await response.json();

  assert.equal(response.status, 404);
  assert.equal(body.error, "Not Found");
  assert.equal(body.method, "GET");
  assert.equal(body.path, "/missing");

  await closeServer(server);
});
'@

Set-Content `
    -LiteralPath "$primerRoot\test\server.test.js" `
    -Value $serverTestContent `
    -Encoding UTF8 `
    -ErrorAction Stop
```

## The Verification

Run syntax checking:

```powershell
npm.cmd run check:syntax
```

Run tests:

```powershell
npm.cmd test
```

Expected summary includes:

```text
tests 5
pass 5
fail 0
```

Run the complete project check:

```powershell
npm.cmd run check
```

Inspect the exit code:

```powershell
$LASTEXITCODE
```

Expected result:

```text
0
```

---

# P3.23 Understand `npm`, `npx`, and `pnpm`

## The Target

Distinguish the package-management tools introduced in Part 3.

## The Concept

### `npm`

npm manages project dependencies and scripts:

```powershell
npm.cmd install
npm.cmd test
npm.cmd run check
npm.cmd start
```

### `npx`

npx runs executables supplied by npm packages:

```powershell
npx.cmd some-tool
```

It can use a locally installed tool or download one temporarily.

npx is not a security sandbox. Any package it executes runs with your user’s permissions.

### `pnpm`

pnpm is an alternative package manager that reuses package content through a shared content-addressable store.

npm and pnpm use different lockfiles:

```text
npm  → package-lock.json
pnpm → pnpm-lock.yaml
```

Do not mix them casually in one project.

## The Implementation

Inspect tool availability:

```powershell
$packageTools = @(
    "npm.cmd"
    "npx.cmd"
    "pnpm"
)

foreach ($toolName in $packageTools) {
    $command = Get-Command `
        -Name $toolName `
        -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Tool = $toolName
        Available = $null -ne $command
        Location = if ($null -ne $command) {
            $command.Source
        }
        else {
            "[not installed]"
        }
    }
}
```

Display versions:

```powershell
npm.cmd --version
npx.cmd --version

if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    pnpm --version
}
```

## The Verification

Confirm this primer remains npm-managed:

```powershell
[PSCustomObject]@{
    NpmLockExists = Test-Path `
        -LiteralPath .\package-lock.json `
        -PathType Leaf
    PnpmLockIsAbsent = -not (
        Test-Path -LiteralPath .\pnpm-lock.yaml
    )
}
```

Both values should be `True`.

---

# Primer 3 Reference A: JavaScript Syntax Map

| Syntax | Meaning |
|---|---|
| `"text"` | String |
| `3000` | Number |
| `true` | Boolean |
| `null` | Intentional absence |
| `undefined` | Missing or unassigned value |
| `const name = value` | Declare a non-reassignable variable |
| `let count = 0` | Declare a reassignable variable |
| `[]` | Array |
| `{}` | Object or code block, depending on context |
| `object.name` | Read a property |
| `array[0]` | Read the first array item |
| `function name() {}` | Function declaration |
| `return value` | Return a result from a function |
| `condition ? a : b` | Conditional expression |
| `===` | Strict equality |
| `!==` | Strict inequality |
| `&&` | Logical AND |
| `\|\|` | Logical OR |
| `!value` | Logical negation |
| `` `Hello ${name}` `` | Template literal |
| `require("./module")` | Import a CommonJS module |
| `module.exports = {...}` | Export a CommonJS interface |
| `async function` | Function that returns a Promise |
| `await promise` | Wait for a Promise inside an async function |
| `throw new Error(...)` | Report a failure |
| `try/catch` | Handle a thrown or rejected error |
| `JSON.stringify(value)` | Convert a JavaScript value to JSON text |
| `JSON.parse(text)` | Convert JSON text to a JavaScript value |
| `// comment` | Single-line comment |
| `/* comment */` | Block comment |

---

# Primer 3 Reference B: CommonJS Modules

## Export several functions

```javascript
"use strict";

function add(left, right) {
  return left + right;
}

function subtract(left, right) {
  return left - right;
}

module.exports = {
  add,
  subtract,
};
```

## Import selected exports

```javascript
const {
  add,
  subtract,
} = require("./math");
```

## Import a built-in Node.js module

Built-in module names commonly use the `node:` prefix:

```javascript
const http = require("node:http");
const path = require("node:path");
const fs = require("node:fs");
```

The prefix makes it clear that the module belongs to Node.js rather than `node_modules`.

## Import a third-party package

After installing a package:

```powershell
npm.cmd install express
```

application code can load it:

```javascript
const express = require("express");
```

## Import a nearby file

Use a relative path:

```javascript
const configuration = require("./config");
```

Without `./`, Node.js searches for a built-in or installed package.

## Execute only when run directly

```javascript
if (require.main === module) {
  startServer();
}
```

This prevents an imported module from automatically performing its command-line startup behavior.

---

# Primer 3 Reference C: Promises and `async`/`await`

## Return a Promise

```javascript
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}
```

## Consume it with `.then()`

```javascript
delay(100).then(() => {
  console.log("Finished");
});
```

## Consume it with `await`

```javascript
async function main() {
  await delay(100);
  console.log("Finished");
}
```

## Handle rejection

```javascript
async function main() {
  try {
    await operationThatMayFail();
  } catch (error) {
    console.error("Operation failed:", error.message);
  }
}
```

## Top-level CommonJS pattern

```javascript
async function main() {
  // Perform asynchronous work.
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exitCode = 1;
});
```

## Return versus await

These both return a Promise:

```javascript
async function first() {
  return Promise.resolve("ready");
}
```

```javascript
async function second() {
  return await Promise.resolve("ready");
}
```

In straightforward code, avoid unnecessary `return await` unless it is needed for local `try`/`catch` behavior or stack-trace considerations.

---

# Primer 3 Reference D: Error Handling

## Validate input synchronously

```javascript
function parsePort(rawValue) {
  if (!/^\d+$/.test(rawValue)) {
    throw new Error("PORT must contain only digits.");
  }

  return Number(rawValue);
}
```

## Catch a synchronous failure

```javascript
try {
  const port = parsePort("invalid");
  console.log(port);
} catch (error) {
  console.error("Configuration error:", error.message);
}
```

## Catch an awaited failure

```javascript
try {
  const response = await fetch(url);
  console.log(response.status);
} catch (error) {
  console.error("Request failed:", error.message);
}
```

## Set a failing exit code

```javascript
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

Setting `process.exitCode` allows the event loop to finish pending work naturally. Calling:

```javascript
process.exit(1);
```

terminates more abruptly and can prevent buffered output or cleanup from completing.

There are situations where an explicit exit is appropriate, but use it deliberately.

## Avoid exposing secrets

Unsafe:

```javascript
console.error({
  environment: process.env,
});
```

Safer:

```javascript
console.error({
  environment: configuration.environment,
  host: configuration.host,
  port: configuration.port,
});
```

Do not include secret values in logs or errors.

---

# Primer 3 Reference E: Process Fundamentals

## Current process identifier

```javascript
process.pid
```

## Node.js version

```javascript
process.version
```

## Executable path

```javascript
process.execPath
```

## Current working directory

```javascript
process.cwd()
```

The current working directory is where the process was launched, not necessarily the directory containing the script.

## Current file directory

In CommonJS:

```javascript
__dirname
```

This identifies the directory containing the current module.

## Command-line arguments

```javascript
process.argv
```

User-supplied arguments normally begin at index `2`:

```javascript
const userArguments = process.argv.slice(2);
```

## Environment variable

```javascript
process.env.PORT
```

Environment values are strings or absent:

```javascript
typeof process.env.PORT === "string"
```

when defined.

## Exit status

```javascript
process.exitCode = 1;
```

Conventionally:

```text
0    → success
nonzero → failure
```

## Signals

```javascript
process.on("SIGINT", () => {
  // Handle Ctrl+C.
});

process.on("SIGTERM", () => {
  // Handle a termination request.
});
```

---

# Primer 3 Reference F: npm Project Files

## `package.json`

Declares project metadata, dependencies, and scripts:

```json
{
  "name": "example-service",
  "private": true,
  "scripts": {
    "test": "node --test",
    "start": "node src/server.js"
  }
}
```

## `package-lock.json`

Records the exact dependency tree chosen by npm.

It improves reproducibility and should normally be committed to Git.

## `node_modules`

Contains installed package files.

It is generated and should normally be excluded from Git:

```gitignore
node_modules/
```

## Source files

Application code belongs in a directory such as:

```text
src/
```

## Tests

Automated tests commonly belong in:

```text
test/
```

## Scripts

Project automation can live in:

```text
scripts/
```

---

# Primer 3 Reference G: npm Commands

## Initialize a project

```powershell
npm.cmd init -y
```

## Install declared dependencies

```powershell
npm.cmd install
```

## Perform a clean lockfile-based installation

```powershell
npm.cmd ci
```

`npm ci` requires `package-lock.json` and is suited to reproducible installations.

## Add a runtime dependency

```powershell
npm.cmd install express
```

## Add a development dependency

```powershell
npm.cmd install --save-dev eslint
```

Short form:

```powershell
npm.cmd install -D eslint
```

## Remove a dependency

```powershell
npm.cmd uninstall package-name
```

## List top-level dependencies

```powershell
npm.cmd list --depth=0
```

## List project scripts

```powershell
npm.cmd run
```

## Run a custom script

```powershell
npm.cmd run check
```

## Run conventional scripts

```powershell
npm.cmd test
npm.cmd start
```

## Run a package executable

```powershell
npx.cmd eslint .
```

`npx` executes code with your user account’s permissions. Review unfamiliar packages before running them.

---

# Primer 3 Reference H: HTTP Request Anatomy

Consider:

```text
POST http://127.0.0.1:3000/echo
Content-Type: application/json

{
  "message": "Hello"
}
```

Its components are:

```text
POST             → method
http             → protocol scheme
127.0.0.1        → host
3000             → port
/echo            → path
Content-Type     → request header
{...}            → request body
```

A response might be:

```text
HTTP/1.1 200 OK
Content-Type: application/json

{
  "received": {
    "message": "Hello"
  }
}
```

Its components are:

```text
200              → status code
OK               → conventional reason phrase
Content-Type     → response header
{...}            → response body
```

---

# Primer 3 Reference I: HTTP Methods

| Method | Common intent | Usually has a body? |
|---|---|---:|
| `GET` | Retrieve a resource | Usually no |
| `POST` | Submit or create data | Often |
| `PUT` | Replace a resource | Often |
| `PATCH` | Partially update a resource | Often |
| `DELETE` | Remove a resource | Sometimes |
| `HEAD` | Retrieve headers without a response body | No |
| `OPTIONS` | Discover communication options | Usually no |

Methods communicate intent but do not provide authorization.

A request such as:

```text
DELETE /users/42
```

must still be authenticated, authorized, validated, and audited by the application.

---

# Primer 3 Reference J: HTTP Status Codes

## Successful responses

| Code | Meaning |
|---:|---|
| `200` | Request succeeded |
| `201` | Resource created |
| `202` | Request accepted for later processing |
| `204` | Request succeeded with no body |

## Client-side request problems

| Code | Meaning |
|---:|---|
| `400` | Request is invalid |
| `401` | Authentication is required or failed |
| `403` | Request is understood but forbidden |
| `404` | Resource was not found |
| `409` | Request conflicts with current state |
| `413` | Request body is too large |
| `415` | Unsupported media type |
| `422` | Request syntax is valid, but semantic validation failed |
| `429` | Too many requests |

## Server-side failures

| Code | Meaning |
|---:|---|
| `500` | Unexpected internal failure |
| `502` | Invalid response from an upstream service |
| `503` | Service is unavailable |
| `504` | Upstream service timed out |

A status code should reflect the result accurately. Do not return `200` for every outcome while placing an error only in the JSON body.

---

# Primer 3 Reference K: PowerShell HTTP Clients

## GET request

```powershell
Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get
```

`Invoke-RestMethod` parses JSON responses into PowerShell objects.

## POST JSON

```powershell
$body = @{
    message = "Hello"
    ready = $true
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://127.0.0.1:3000/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

## Inspect raw response details

Use `Invoke-WebRequest` when you need headers and raw response information:

```powershell
$response = Invoke-WebRequest `
    -Uri "http://127.0.0.1:3000/health" `
    -Method Get

$response.StatusCode
$response.Headers
$response.Content
```

## Handle non-success responses

```powershell
try {
    Invoke-RestMethod `
        -Uri "http://127.0.0.1:3000/missing" `
        -ErrorAction Stop
}
catch {
    Write-Host $_.Exception.Message
}
```

PowerShell behavior around HTTP error responses differs somewhat between Windows PowerShell 5.1 and PowerShell 7. Use explicit `try`/`catch` when testing failure responses interactively.

---

# Primer 3 Reference L: HTTP Server Concepts

## Request object

Contains information such as:

```javascript
request.method
request.url
request.headers
```

## Response object

Controls the reply:

```javascript
response.writeHead(200, {
  "content-type": "application/json",
});

response.end('{"status":"ok"}');
```

## Route matching

The primer performs explicit matching:

```javascript
if (
  request.method === "GET" &&
  requestUrl.pathname === "/health"
) {
  // Return health information.
}
```

Frameworks such as Express provide a higher-level routing API:

```javascript
app.get("/health", (request, response) => {
  response.json({
    status: "ok",
  });
});
```

## Request bodies are streams

A request body may arrive in multiple chunks:

```javascript
request.on("data", (chunk) => {
  chunks.push(chunk);
});

request.on("end", () => {
  const body = Buffer.concat(chunks);
});
```

Production servers should enforce body-size limits.

## Always end a response

Every handled request must eventually call something that completes the response, such as:

```javascript
response.end();
```

A framework’s `response.json(...)` normally performs that completion for you.

---

# Primer 3 Reference M: Common Beginner Mistakes

## Mistake 1: Confusing JavaScript with Node.js

JavaScript is the language. Node.js is a runtime that executes it and supplies server-side APIs.

## Mistake 2: Forgetting that environment variables are strings

This is a string:

```javascript
process.env.PORT
```

Convert and validate it before treating it as a number.

## Mistake 3: Using loose equality

Avoid:

```javascript
rawPort == 3000
```

Prefer:

```javascript
rawPort === "3000"
```

or convert first:

```javascript
Number(rawPort) === 3000
```

## Mistake 4: Forgetting to return after sending a response

Risky:

```javascript
if (request.url === "/health") {
  sendJson(response, 200, {
    status: "ok",
  });
}

// Execution continues and may attempt another response.
```

Safer:

```javascript
if (request.url === "/health") {
  sendJson(response, 200, {
    status: "ok",
  });

  return;
}
```

## Mistake 5: Parsing JSON without handling malformed input

Risky:

```javascript
const value = JSON.parse(text);
```

At a request boundary, catch parsing failures and return an appropriate `400` response.

## Mistake 6: Allowing unlimited request bodies

Collecting an unbounded body can consume excessive memory. Enforce a limit or use a framework parser configured with one.

## Mistake 7: Starting a server merely because a module was imported

Guard direct startup:

```javascript
if (require.main === module) {
  startServer();
}
```

This makes testing easier.

## Mistake 8: Leaving test servers open

Unclosed servers keep network resources and event-loop handles active. Tests should close them in cleanup hooks.

## Mistake 9: Editing `node_modules`

Treat it as generated output. Change source or declared dependencies instead.

## Mistake 10: Deleting `package-lock.json` casually

The lockfile records exact dependency resolution. Keep it unless you deliberately intend to regenerate dependency state.

## Mistake 11: Installing every tool globally

Project-local development tools provide more reproducible versions:

```powershell
npm.cmd install --save-dev eslint
npm.cmd run lint
```

## Mistake 12: Assuming npx is safe because installation is temporary

Temporary execution still runs third-party code. Verify the package name, publisher, source repository, and version.

## Mistake 13: Logging complete request bodies or environment objects

Requests and environment variables can contain secrets or personal data. Log only necessary, approved fields.

## Mistake 14: Calling `process.exit()` during ordinary asynchronous cleanup

An immediate exit can interrupt output and unfinished operations. Prefer graceful shutdown and `process.exitCode` when possible.

---

# P3.24 Run the Complete Quality Check

## The Target

Verify the syntax and behavior of the completed primer project.

## The Concept

A quality check should exercise several independent concerns:

```text
JavaScript syntax
        ↓
module loading
        ↓
configuration validation
        ↓
HTTP route behavior
        ↓
resource cleanup
```

No single successful request proves all of those properties.

## The Implementation

Return to the primer root:

```powershell
Set-Location -LiteralPath $primerRoot
```

Ensure the manifest and lockfile agree:

```powershell
npm.cmd install
```

Run syntax checks:

```powershell
npm.cmd run check:syntax
```

Run automated tests:

```powershell
npm.cmd test
```

Run the combined check:

```powershell
npm.cmd run check
```

Capture the exit code immediately:

```powershell
$qualityCheckExitCode = $LASTEXITCODE
```

## The Verification

Run:

```powershell
if ($qualityCheckExitCode -ne 0) {
    throw (
        "The Primer 3 quality check failed with exit code " +
        "$qualityCheckExitCode."
    )
}

Write-Host "Primer 3 quality check passed." `
    -ForegroundColor Green
```

Expected message:

```text
Primer 3 quality check passed.
```

---

# Primer 3 Readiness Challenge

## The Target

Prove that you can explain and operate the complete Node.js and HTTP workflow.

The challenge will:

1. Validate the project structure.
2. Run JavaScript syntax checks.
3. Run automated tests.
4. Start the real server on an isolated port.
5. Poll its health endpoint.
6. Submit a JSON echo request.
7. Check a 404 response.
8. Stop the server.
9. Verify that the child process exited.

## The Concept

The challenge combines the entire primer:

```text
PowerShell
    ↓ starts
Node.js process
    ↓ loads
CommonJS modules
    ↓ validates
runtime configuration
    ↓ opens
HTTP server
    ↓ receives
client requests
    ↓ returns
JSON responses
    ↓ closes through
process signal
```

## The Implementation

Reconstruct the project path so the challenge does not depend on transient variables:

```powershell
$primerRoot = Join-Path `
    -Path $HOME `
    -ChildPath "node-http-primer"

Set-Location -LiteralPath $primerRoot
```

Validate the required files:

```powershell
$requiredFiles = @(
    ".\package.json"
    ".\package-lock.json"
    ".\src\math.js"
    ".\src\config.js"
    ".\src\server.js"
    ".\scripts\inspect-runtime.js"
    ".\test\server.test.js"
)

$missingFiles = @(
    $requiredFiles |
        Where-Object {
            -not (
                Test-Path `
                    -LiteralPath $_ `
                    -PathType Leaf
            )
        }
)

if ($missingFiles.Count -gt 0) {
    throw "Missing primer files: $($missingFiles -join ', ')"
}
```

Run the quality check:

```powershell
npm.cmd run check

if ($LASTEXITCODE -ne 0) {
    throw "The project quality check failed."
}
```

Choose an isolated challenge port:

```powershell
$challengeHost = "127.0.0.1"
$challengePort = 43140
```

Prepare standard-output and standard-error logs:

```powershell
$stdoutLog = Join-Path `
    -Path $env:TEMP `
    -ChildPath "node-http-primer.stdout.log"

$stderrLog = Join-Path `
    -Path $env:TEMP `
    -ChildPath "node-http-primer.stderr.log"

Remove-Item `
    -LiteralPath $stdoutLog, $stderrLog `
    -Force `
    -ErrorAction SilentlyContinue
```

Temporarily set configuration for the child process:

```powershell
$previousHost = $env:HOST
$previousPort = $env:PORT

$env:HOST = $challengeHost
$env:PORT = [string] $challengePort
```

Start the server:

```powershell
$serverProcess = $null

try {
    $serverProcess = Start-Process `
        -FilePath (Get-Command node).Source `
        -ArgumentList @(
            "$primerRoot\src\server.js"
        ) `
        -WorkingDirectory $primerRoot `
        -RedirectStandardOutput $stdoutLog `
        -RedirectStandardError $stderrLog `
        -WindowStyle Hidden `
        -PassThru
}
finally {
    if ($null -eq $previousHost) {
        Remove-Item Env:HOST -ErrorAction SilentlyContinue
    }
    else {
        $env:HOST = $previousHost
    }

    if ($null -eq $previousPort) {
        Remove-Item Env:PORT -ErrorAction SilentlyContinue
    }
    else {
        $env:PORT = $previousPort
    }
}
```

Poll the health endpoint:

```powershell
$baseUrl = "http://${challengeHost}:$challengePort"
$healthResponse = $null
$serviceReady = $false

for ($attempt = 1; $attempt -le 40; $attempt++) {
    if ($serverProcess.HasExited) {
        break
    }

    try {
        $healthResponse = Invoke-RestMethod `
            -Uri "$baseUrl/health" `
            -Method Get `
            -TimeoutSec 1 `
            -ErrorAction Stop

        if ($healthResponse.status -eq "ok") {
            $serviceReady = $true
            break
        }
    }
    catch {
        Start-Sleep -Milliseconds 250
    }
}
```

Require successful startup:

```powershell
if (-not $serviceReady) {
    $standardOutput = if (
        Test-Path -LiteralPath $stdoutLog
    ) {
        Get-Content -LiteralPath $stdoutLog -Raw
    }
    else {
        ""
    }

    $standardError = if (
        Test-Path -LiteralPath $stderrLog
    ) {
        Get-Content -LiteralPath $stderrLog -Raw
    }
    else {
        ""
    }

    if (
        $null -ne $serverProcess -and
        -not $serverProcess.HasExited
    ) {
        Stop-Process `
            -Id $serverProcess.Id `
            -Force `
            -ErrorAction SilentlyContinue
    }

    throw (
        "The challenge server did not become healthy." +
        [Environment]::NewLine +
        "Standard output:" +
        [Environment]::NewLine +
        $standardOutput +
        [Environment]::NewLine +
        "Standard error:" +
        [Environment]::NewLine +
        $standardError
    )
}
```

Call the root route:

```powershell
$rootResponse = Invoke-RestMethod `
    -Uri "$baseUrl/" `
    -Method Get `
    -ErrorAction Stop
```

Call the echo route:

```powershell
$challengeRequest = @{
    message = "Primer 3 readiness challenge"
    ready = $true
    number = 42
} | ConvertTo-Json

$echoResponse = Invoke-RestMethod `
    -Uri "$baseUrl/echo" `
    -Method Post `
    -ContentType "application/json" `
    -Body $challengeRequest `
    -ErrorAction Stop
```

Verify a missing route using `Invoke-WebRequest`:

```powershell
$missingStatusCode = $null

try {
    $missingResponse = Invoke-WebRequest `
        -Uri "$baseUrl/missing" `
        -Method Get `
        -ErrorAction Stop

    $missingStatusCode = [int] $missingResponse.StatusCode
}
catch {
    if ($null -ne $_.Exception.Response) {
        $missingStatusCode = [int](
            $_.Exception.Response.StatusCode
        )
    }
}
```

Stop the server in a guaranteed cleanup block:

```powershell
try {
    $challengeResults = [PSCustomObject]@{
        ServiceBecameHealthy = $serviceReady
        HealthStatusIsOk = (
            $healthResponse.status -eq "ok"
        )
        RootServiceNameIsCorrect = (
            $rootResponse.service -eq
            "node-http-primer"
        )
        EchoMessageMatches = (
            $echoResponse.received.message -eq
            "Primer 3 readiness challenge"
        )
        EchoBooleanMatches = (
            $echoResponse.received.ready -eq $true
        )
        EchoNumberMatches = (
            $echoResponse.received.number -eq 42
        )
        MissingRouteReturned404 = (
            $missingStatusCode -eq 404
        )
    }

    $challengeResults |
        Format-List
}
finally {
    if (
        $null -ne $serverProcess -and
        -not $serverProcess.HasExited
    ) {
        Stop-Process `
            -Id $serverProcess.Id `
            -ErrorAction SilentlyContinue

        $null = $serverProcess.WaitForExit(5000)
    }
}
```

> `Stop-Process` on Windows may terminate the process directly rather than exercising Node.js’s `SIGTERM` handler exactly as a Unix process manager would. The interactive `Ctrl+C` exercise already verified the graceful-shutdown path. This readiness challenge focuses on reliable test cleanup.

Confirm process termination:

```powershell
$serverExited = (
    $null -eq $serverProcess -or
    $serverProcess.HasExited
)
```

## The Verification

Combine every result:

```powershell
$finalReadinessResults = [PSCustomObject]@{
    RequiredFilesExist = $missingFiles.Count -eq 0
    ServiceBecameHealthy = (
        $challengeResults.ServiceBecameHealthy
    )
    HealthStatusIsOk = (
        $challengeResults.HealthStatusIsOk
    )
    RootServiceNameIsCorrect = (
        $challengeResults.RootServiceNameIsCorrect
    )
    EchoMessageMatches = (
        $challengeResults.EchoMessageMatches
    )
    EchoBooleanMatches = (
        $challengeResults.EchoBooleanMatches
    )
    EchoNumberMatches = (
        $challengeResults.EchoNumberMatches
    )
    MissingRouteReturned404 = (
        $challengeResults.MissingRouteReturned404
    )
    ServerProcessExited = $serverExited
}

$finalReadinessResults |
    Format-List
```

Find failed checks:

```powershell
$failedReadinessChecks = @(
    $finalReadinessResults.PSObject.Properties |
        Where-Object {
            $_.Value -ne $true
        }
)
```

Report the outcome:

```powershell
if ($failedReadinessChecks.Count -eq 0) {
    Write-Host "Primer 3 readiness check passed." `
        -ForegroundColor Green
}
else {
    $failedReadinessChecks |
        Select-Object Name, Value |
        Format-Table -AutoSize

    throw "Primer 3 readiness check failed."
}
```

Expected message:

```text
Primer 3 readiness check passed.
```

Remove temporary logs after successful verification:

```powershell
Remove-Item `
    -LiteralPath $stdoutLog, $stderrLog `
    -Force `
    -ErrorAction SilentlyContinue
```

---

# Primer 3 Optional Cleanup

## The Target

Remove the disposable primer project if you no longer need it.

## The Concept

The project contains no personal source code if you followed the primer exactly. Even so, apply the filesystem safety process from Primer 2:

```text
Locate → Resolve → Inspect → Preview → Execute → Verify
```

## The Implementation

Leave the project before deleting it:

```powershell
Set-Location -LiteralPath $HOME
```

Reconstruct and validate the exact path:

```powershell
$cleanupTarget = Join-Path `
    -Path $HOME `
    -ChildPath "node-http-primer"

$expectedCleanupTarget = Join-Path `
    -Path $HOME `
    -ChildPath "node-http-primer"

if ($cleanupTarget -ne $expectedCleanupTarget) {
    throw "Unexpected cleanup target: $cleanupTarget"
}
```

Inspect it:

```powershell
Get-ChildItem `
    -LiteralPath $cleanupTarget `
    -Recurse `
    -Force |
    Select-Object FullName
```

Preview:

```powershell
Remove-Item `
    -LiteralPath $cleanupTarget `
    -Recurse `
    -Force `
    -WhatIf
```

If you want to keep the project for reference, stop here.

Otherwise, remove it:

```powershell
Remove-Item `
    -LiteralPath $cleanupTarget `
    -Recurse `
    -Force `
    -Confirm
```

Enter `Y` only after confirming the displayed target.

## The Verification

If removed:

```powershell
Test-Path -LiteralPath $cleanupTarget
```

Expected result:

```text
False
```

If retained:

```powershell
Test-Path `
    -LiteralPath $cleanupTarget `
    -PathType Container
```

Expected result:

```text
True
```

---

# Primer 3 Key Takeaways

## JavaScript and Node.js are related but different

JavaScript is the language:

```javascript
const message = "Hello";
```

Node.js is the runtime:

```powershell
node .\src\server.js
```

## Variables hold values

Use `const` by default:

```javascript
const port = 3000;
```

Use `let` when reassignment is intentional:

```javascript
let requestCount = 0;
requestCount += 1;
```

## Arrays and objects organize data

```javascript
const routes = [
  "/",
  "/health",
];

const configuration = {
  host: "127.0.0.1",
  port: 3000,
};
```

## Functions encapsulate behavior

```javascript
function buildAddress(host, port) {
  return `http://${host}:${port}`;
}
```

## CommonJS modules separate responsibilities

Export:

```javascript
module.exports = {
  loadConfiguration,
};
```

Import:

```javascript
const {
  loadConfiguration,
} = require("./config");
```

## JSON is a text interchange format

Serialize:

```javascript
JSON.stringify(value);
```

Parse:

```javascript
JSON.parse(text);
```

## Promises represent future outcomes

```javascript
const result = await asynchronousOperation();
```

Handle rejection:

```javascript
try {
  await operation();
} catch (error) {
  console.error(error.message);
}
```

## A process is a running program

Node.js exposes:

```javascript
process.argv
process.env
process.pid
process.cwd()
process.exitCode
```

## npm manages dependencies and scripts

```powershell
npm.cmd install
npm.cmd test
npm.cmd run check
npm.cmd start
```

The core project resources are:

```text
package.json      → declared project metadata and requirements
package-lock.json → exact npm dependency resolution
node_modules      → installed package files
```

## HTTP follows a request-response model

```text
client request
      ↓
HTTP server
      ↓
status + headers + body
```

A request address contains:

```text
method + scheme + host + port + path
```

Example:

```text
GET http://127.0.0.1:3000/health
```

## Servers must validate boundaries

A server should validate:

- Configuration
- Methods
- Paths
- JSON syntax
- Request-body size
- Expected data types

## Tests should use isolated resources

Using port `0` lets the operating system assign a free test port:

```javascript
server.listen(0, "127.0.0.1");
```

Tests must close servers after use.

## Graceful shutdown matters

Handle termination requests and close the listener:

```javascript
process.on("SIGINT", () => {
  server.close();
});
```

## The essential development workflow is

```powershell
npm.cmd install
npm.cmd run check
npm.cmd start
```

You are now prepared to understand why Part 3 introduces Express, npm dependencies, package scripts, automated tests, builds, process lifecycle handling, and HTTP health checks.
