# Primer 3: Node.js, Command Line, and Project Tooling

The main series uses Node.js to run JavaScript outside a browser.

This primer explains:

- What Node.js is.
- How to use the command line.
- How to create and run a project.
- How `package.json` works.
- How npm scripts work.
- How ECMAScript modules are configured.
- How to read environment variables.
- How to work with files.
- How to create a basic HTTP server.
- How to handle process signals.
- How to use the built-in test runner.
- How to organize a real project.

The goal is not to turn you into a system administrator. The goal is to make project setup and execution predictable before we study advanced runtime behavior.

---

# 1. What Is Node.js?

## The Target

We will run JavaScript from a terminal.

## The Concept

A browser provides JavaScript with browser features such as:

- `document`.
- `window`.
- User-interface events.
- Rendering.
- Browser storage.

Node.js provides JavaScript with server and operating-system capabilities such as:

- Filesystem access.
- HTTP servers.
- Process information.
- Environment variables.
- Streams.
- Worker threads.

Node.js uses the V8 JavaScript engine, but Node.js is more than V8. It also provides host APIs and a process runtime.

## Implementation

Create:

### `primer-3/hello.js`

```js
console.log("Hello from Node.js");

console.log({
  nodeVersion: process.version,
  platform: process.platform,
  architecture: process.arch
});
```

## Verification

Run:

```bash
node primer-3/hello.js
```

Expected output resembles:

```text
Hello from Node.js
{
  nodeVersion: 'v20.x.x',
  platform: 'linux',
  architecture: 'x64'
}
```

The exact platform and architecture depend on your machine.

---

# 2. Command-Line Basics

## The Target

We will use commands to navigate directories, inspect files, and run programs.

## The Concept

The command line is a text-based interface for operating your computer.

A terminal command usually contains:

```text
program   options   arguments
```

Example:

```bash
node --version
```

- `node` is the program.
- `--version` is an option.
- There are no additional arguments.

## Common Commands

### Print the Current Directory

macOS, Linux, and Git Bash:

```bash
pwd
```

PowerShell:

```powershell
Get-Location
```

### List Files

macOS, Linux, and Git Bash:

```bash
ls
```

PowerShell:

```powershell
Get-ChildItem
```

### Change Directory

```bash
cd primer-3
```

### Move to the Parent Directory

```bash
cd ..
```

### Create a Directory

macOS, Linux, and Git Bash:

```bash
mkdir -p primer-3/src
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path primer-3/src
```

### Clear the Terminal

macOS, Linux, and Git Bash:

```bash
clear
```

PowerShell:

```powershell
Clear-Host
```

## Verification

Run:

```bash
node --version
npm --version
```

Both commands should print version numbers.

---

# 3. Create a Node.js Project

## The Target

We will create a project directory and initialize npm.

## The Concept

A project directory is the application’s workspace.

`npm init` creates a `package.json` file containing project metadata and command definitions.

## Implementation

Run:

```bash
mkdir -p primer-3
cd primer-3
npm init -y
```

The generated file resembles:

### `primer-3/package.json`

```json
{
  "name": "primer-3",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

Replace it with:

### `primer-3/package.json`

```json
{
  "name": "runtime-monitor-primer-3",
  "version": "1.0.0",
  "private": true,
  "description": "Node.js and project tooling primer",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "hello": "node src/hello.js",
    "config": "node src/configuration.js",
    "files": "node src/files.js",
    "server": "node src/server.js",
    "test": "node --test",
    "test:watch": "node --test --watch"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## Why These Fields Matter

### `name`

The project’s package name.

### `version`

The project version.

### `private`

Prevents accidentally publishing the project to npm.

### `type`

```json
"type": "module"
```

Treats `.js` files as ECMAScript modules.

### `scripts`

Named commands that can be executed through npm.

### `engines`

Documents the supported Node.js version.

## Verification

Run:

```bash
npm run
```

Expected output lists:

```text
hello
config
files
server
test
test:watch
```

---

# 4. Run an ECMAScript Module

## The Target

We will create a module and execute it through an npm script.

## The Concept

An ECMAScript module is a JavaScript file with explicit imports and exports.

The `"type": "module"` setting tells Node.js to interpret `.js` files using modern module rules.

## Implementation

Create the directory:

```bash
mkdir -p src
```

### `primer-3/src/hello.js`

```js
export function createGreeting(name) {
  if (
    typeof name !== "string" ||
    name.trim() === ""
  ) {
    throw new TypeError(
      "name must be a non-empty string"
    );
  }

  return `Hello, ${name.trim()}!`;
}

console.log(createGreeting("Ada"));
```

### `primer-3/src/index.js`

```js
import { createGreeting } from "./hello.js";

console.log(createGreeting("Runtime Monitor"));
```

## Verification

Run:

```bash
npm run hello
npm start
```

Expected output:

```text
Hello, Ada!
```

for `npm run hello`, and:

```text
Hello, Runtime Monitor!
```

for `npm start`.

---

# 5. Import Paths and File Extensions

## The Target

We will use explicit relative import paths.

## The Concept

Node.js ECMAScript modules generally require the file extension for relative imports.

Correct:

```js
import { createGreeting } from "./hello.js";
```

Avoid:

```js
import { createGreeting } from "./hello";
```

The explicit extension makes module resolution predictable.

## Verification

Temporarily change `src/index.js` to:

```js
import { createGreeting } from "./hello";

console.log(createGreeting("Runtime Monitor"));
```

Run:

```bash
npm start
```

Node.js should report a module-resolution error.

Restore the import:

```js
import { createGreeting } from "./hello.js";
```

Run again:

```bash
npm start
```

The program should work.

---

# 6. Process Information

## The Target

We will inspect information about the running Node.js process.

## The Concept

The `process` object describes the current Node.js process.

Useful values include:

- `process.version`.
- `process.platform`.
- `process.arch`.
- `process.pid`.
- `process.cwd()`.
- `process.argv`.
- `process.env`.

## Implementation

### `primer-3/src/process-info.js`

```js
console.log({
  nodeVersion: process.version,
  platform: process.platform,
  architecture: process.arch,
  processId: process.pid,
  workingDirectory: process.cwd(),
  arguments: process.argv
});
```

## Verification

Run:

```bash
node src/process-info.js example --verbose
```

Expected output includes:

```text
arguments: [
  '.../node',
  '.../src/process-info.js',
  'example',
  '--verbose'
]
```

The first argument is usually the Node executable. The second is the script path. Additional values are user-provided arguments.

---

# 7. Command-Line Arguments

## The Target

We will parse simple command-line arguments.

## The Concept

Command-line arguments allow users or deployment scripts to configure a program when starting it.

Example:

```bash
node src/arguments.js --environment=production --verbose
```

## Implementation

### `primer-3/src/arguments.js`

```js
function parseArguments(argumentsList) {
  const options = {};

  for (const argument of argumentsList) {
    if (!argument.startsWith("--")) {
      continue;
    }

    const withoutPrefix = argument.slice(2);
    const separatorIndex = withoutPrefix.indexOf("=");

    if (separatorIndex === -1) {
      options[withoutPrefix] = true;
      continue;
    }

    const key = withoutPrefix.slice(0, separatorIndex);
    const value = withoutPrefix.slice(
      separatorIndex + 1
    );

    options[key] = value;
  }

  return options;
}

const options = parseArguments(
  process.argv.slice(2)
);

console.log(options);
```

## Verification

Run:

```bash
node src/arguments.js --environment=production --verbose --port=3000
```

Expected output:

```text
{
  environment: 'production',
  verbose: true,
  port: '3000'
}
```

Command-line values arrive as strings. Convert and validate numeric values explicitly.

---

# 8. Environment Variables

## The Target

We will read configuration from environment variables.

## The Concept

Environment variables are values provided by the operating environment rather than written directly into source code.

They are useful for:

- Deployment-specific URLs.
- Ports.
- Timeouts.
- Feature flags.
- Log levels.
- Secret references.

They are strings by default.

## Implementation

### `primer-3/src/configuration.js`

```js
function positiveInteger(
  value,
  fallback,
  name
) {
  const selectedValue =
    value === undefined
      ? fallback
      : Number(value);

  if (
    !Number.isInteger(selectedValue) ||
    selectedValue <= 0
  ) {
    throw new Error(
      `${name} must be a positive integer`
    );
  }

  return selectedValue;
}

function loadConfiguration(
  environment = process.env
) {
  return Object.freeze({
    appEnvironment:
      environment.APP_ENV ?? "development",

    port: positiveInteger(
      environment.PORT,
      3000,
      "PORT"
    ),

    requestTimeoutMilliseconds:
      positiveInteger(
        environment.REQUEST_TIMEOUT_MS,
        5_000,
        "REQUEST_TIMEOUT_MS"
      )
  });
}

const configuration = loadConfiguration();

console.log(configuration);
```

## Verification

macOS, Linux, and Git Bash:

```bash
APP_ENV=production PORT=4000 REQUEST_TIMEOUT_MS=3000 npm run config
```

PowerShell:

```powershell
$env:APP_ENV="production"
$env:PORT="4000"
$env:REQUEST_TIMEOUT_MS="3000"
npm run config
```

Expected output:

```text
{
  appEnvironment: 'production',
  port: 4000,
  requestTimeoutMilliseconds: 3000
}
```

---

# 9. Environment Variable Rules

## Important Rules

### Values Are Strings

```bash
PORT=4000
```

Node receives:

```js
process.env.PORT === "4000"
```

Convert it:

```js
const port = Number(process.env.PORT);
```

Then validate it.

### Environment Variables Are Not Automatically Secret

A secret stored in an environment variable can still be exposed through:

- Logs.
- Process inspection.
- Crash reports.
- Debugging tools.
- Child-process inheritance.

Do not print all of `process.env`.

Avoid:

```js
console.log(process.env);
```

### Validate at Startup

Fail early:

```js
if (!process.env.API_KEY) {
  throw new Error("API_KEY is required");
}
```

---

# 10. `.env.example`

## The Target

We will document expected environment variables without storing real secrets.

## The Concept

An `.env.example` file shows developers which variables are required.

It should contain safe placeholder values.

## Implementation

### `primer-3/.env.example`

```dotenv
APP_ENV=development
PORT=3000
REQUEST_TIMEOUT_MS=5000
API_BASE_URL=https://api.example.test
LOG_LEVEL=info
```

If using a real `.env` file locally, add it to `.gitignore`.

### `primer-3/.gitignore`

```gitignore
node_modules/
.env
coverage/
*.log
```

## Verification

Run:

```bash
git status --ignored
```

If `.env` exists, confirm Git marks it as ignored.

---

# 11. Filesystem Paths

## The Target

We will create portable paths.

## The Concept

Different operating systems use different path separators.

Do not manually build paths like this:

```js
const path = "data/" + fileName;
```

Use Node’s `node:path` module.

## Implementation

### `primer-3/src/paths.js`

```js
import path from "node:path";

const projectRoot = process.cwd();

const dataDirectory = path.join(
  projectRoot,
  "data"
);

const configurationFile = path.join(
  dataDirectory,
  "configuration.json"
);

console.log({
  projectRoot,
  dataDirectory,
  configurationFile,
  separator: path.sep
});
```

## Verification

Run:

```bash
node src/paths.js
```

The output should use the correct path separator for your operating system.

---

# 12. Module-Relative Paths

## The Target

We will create a path relative to the current module file.

## The Concept

`process.cwd()` depends on where the command was started.

For example, these commands may produce different working directories:

```bash
node src/file.js
```

```bash
cd src
node file.js
```

`import.meta.url` identifies the current module location and is more reliable for module-relative resources.

## Implementation

### `primer-3/src/module-path.js`

```js
import path from "node:path";
import { fileURLToPath } from "node:url";

const currentFilePath = fileURLToPath(import.meta.url);
const currentDirectory = path.dirname(
  currentFilePath
);

console.log({
  currentFilePath,
  currentDirectory
});
```

## Verification

Run:

```bash
node src/module-path.js
```

The output should identify the actual module file location regardless of the current working directory.

---

# 13. Reading Files Asynchronously

## The Target

We will read a text file using Node’s promise-based filesystem API.

## The Concept

Filesystem operations can take time, so prefer asynchronous APIs for application code.

The `node:fs/promises` module provides promise-based functions.

## Implementation

Create a data directory:

```bash
mkdir -p data
```

### `primer-3/data/service.json`

```json
{
  "name": "metrics",
  "status": "healthy",
  "latencyMilliseconds": 42
}
```

### `primer-3/src/files.js`

```js
import {
  readFile
} from "node:fs/promises";

import path from "node:path";

const filePath = path.join(
  process.cwd(),
  "data",
  "service.json"
);

try {
  const contents = await readFile(
    filePath,
    "utf8"
  );

  const service = JSON.parse(contents);

  console.log(service);
} catch (error) {
  console.error({
    name: error.name,
    message: error.message,
    filePath
  });

  process.exitCode = 1;
}
```

## Verification

Run:

```bash
npm run files
```

Expected output:

```text
{
  name: 'metrics',
  status: 'healthy',
  latencyMilliseconds: 42
}
```

---

# 14. Writing Files Asynchronously

## The Target

We will write JSON data to a file.

## The Concept

Writing should also be asynchronous.

Use `JSON.stringify()` to convert an object to text.

## Implementation

### `primer-3/src/write-file.js`

```js
import {
  mkdir,
  writeFile
} from "node:fs/promises";

import path from "node:path";

const dataDirectory = path.join(
  process.cwd(),
  "data"
);

const outputPath = path.join(
  dataDirectory,
  "generated-service.json"
);

const service = {
  name: "health",
  status: "degraded",
  latencyMilliseconds: 120
};

await mkdir(dataDirectory, {
  recursive: true
});

await writeFile(
  outputPath,
  `${JSON.stringify(service, null, 2)}\n`,
  "utf8"
);

console.log(`wrote ${outputPath}`);
```

## Verification

Run:

```bash
node src/write-file.js
cat data/generated-service.json
```

PowerShell alternative:

```powershell
Get-Content data/generated-service.json
```

Expected file contents:

```json
{
  "name": "health",
  "status": "degraded",
  "latencyMilliseconds": 120
}
```

---

# 15. File Error Handling

## The Target

We will distinguish a missing file from an invalid JSON file.

## Concept

Different failures need different responses.

A missing file may use a default. Invalid JSON usually indicates corruption or a deployment problem.

## Implementation

### `primer-3/src/read-json.js`

```js
import {
  readFile
} from "node:fs/promises";

export async function readJsonFile(
  filePath
) {
  let contents;

  try {
    contents = await readFile(
      filePath,
      "utf8"
    );
  } catch (error) {
    if (error.code === "ENOENT") {
      throw new Error(
        `file does not exist: ${filePath}`,
        {
          cause: error
        }
      );
    }

    throw new Error(
      `file could not be read: ${filePath}`,
      {
        cause: error
      }
    );
  }

  try {
    return JSON.parse(contents);
  } catch (error) {
    throw new Error(
      `file contains invalid JSON: ${filePath}`,
      {
        cause: error
      }
    );
  }
}

const service = await readJsonFile(
  "data/service.json"
);

console.log(service);
```

## Verification

Run:

```bash
node src/read-json.js
```

Then create an invalid file:

```bash
printf '{ invalid json\n' > data/invalid.json
```

Run:

```bash
node --input-type=module <<'EOF'
import { readJsonFile } from "./src/read-json.js";

try {
  await readJsonFile("data/invalid.json");
} catch (error) {
  console.log(error.message);
  console.log("cause:", error.cause?.name);
}
EOF
```

Expected output identifies invalid JSON.

---

# 16. Avoiding Path Traversal

## The Target

We will safely resolve a user-provided filename beneath a known directory.

## The Concept

Path traversal occurs when untrusted input escapes an intended directory:

```text
../../private-file
```

Do not concatenate user input directly into a path.

## Implementation

### `primer-3/src/safe-path.js`

```js
import path from "node:path";

export function resolveInsideDirectory(
  directory,
  userProvidedName
) {
  if (
    typeof directory !== "string" ||
    typeof userProvidedName !== "string"
  ) {
    throw new TypeError(
      "directory and name must be strings"
    );
  }

  const root = path.resolve(directory);
  const candidate = path.resolve(
    root,
    userProvidedName
  );

  const relative = path.relative(
    root,
    candidate
  );

  const escapesRoot =
    relative === ".." ||
    relative.startsWith(`..${path.sep}`) ||
    path.isAbsolute(relative);

  if (escapesRoot) {
    throw new Error(
      "requested path escapes the allowed directory"
    );
  }

  return candidate;
}

const safePath = resolveInsideDirectory(
  "data",
  "service.json"
);

console.log(safePath);

try {
  resolveInsideDirectory(
    "data",
    "../../private.txt"
  );
} catch (error) {
  console.log(error.message);
}
```

## Verification

Run:

```bash
node src/safe-path.js
```

Expected output includes:

```text
requested path escapes the allowed directory
```

---

# 17. Basic HTTP Server

## The Target

We will create an HTTP server with health endpoints.

## The Concept

An HTTP server receives requests and sends responses.

The basic flow is:

```text
client request
      │
      ▼
server request handler
      │
      ▼
status code + headers + body
```

## Implementation

### `primer-3/src/server.js`

```js
import http from "node:http";

const port = Number(
  process.env.PORT ?? 3000
);

if (
  !Number.isInteger(port) ||
  port <= 0 ||
  port > 65_535
) {
  throw new Error(
    "PORT must be a valid TCP port"
  );
}

const server = http.createServer(
  (request, response) => {
    const requestUrl = new URL(
      request.url ?? "/",
      `http://${request.headers.host ?? "localhost"}`
    );

    if (
      request.method === "GET" &&
      requestUrl.pathname === "/live"
    ) {
      response.writeHead(200, {
        "content-type": "application/json; charset=utf-8"
      });

      response.end(
        JSON.stringify({
          status: "alive"
        })
      );

      return;
    }

    if (
      request.method === "GET" &&
      requestUrl.pathname === "/ready"
    ) {
      response.writeHead(200, {
        "content-type": "application/json; charset=utf-8"
      });

      response.end(
        JSON.stringify({
          status: "ready"
        })
      );

      return;
    }

    response.writeHead(404, {
      "content-type": "application/json; charset=utf-8"
    });

    response.end(
      JSON.stringify({
        error: {
          code: "NOT_FOUND",
          message: "route not found"
        }
      })
    );
  }
);

server.listen(port, () => {
  console.log(`server listening on port ${port}`);
});
```

## Verification

Run:

```bash
npm run server
```

In another terminal:

```bash
curl -i http://localhost:3000/live
curl -i http://localhost:3000/ready
curl -i http://localhost:3000/missing
```

Expected results:

- `/live` returns `200`.
- `/ready` returns `200`.
- `/missing` returns `404`.

Stop the server with:

```text
Ctrl+C
```

---

# 18. HTTP Request Data

## The Target

We will inspect request methods, headers, and URL query parameters.

## Implementation

Replace `primer-3/src/server.js` with:

### `primer-3/src/server.js`

```js
import http from "node:http";

const port = Number(
  process.env.PORT ?? 3000
);

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8"
  });

  response.end(JSON.stringify(body));
}

const server = http.createServer(
  (request, response) => {
    const requestUrl = new URL(
      request.url ?? "/",
      `http://${request.headers.host ?? "localhost"}`
    );

    console.log({
      method: request.method,
      path: requestUrl.pathname,
      query: Object.fromEntries(
        requestUrl.searchParams
      ),
      userAgent: request.headers["user-agent"]
    });

    if (
      request.method === "GET" &&
      requestUrl.pathname === "/metrics"
    ) {
      sendJson(response, 200, {
        requestsPerSecond: 125,
        errorRate: 0.01
      });

      return;
    }

    sendJson(response, 404, {
      error: {
        code: "NOT_FOUND",
        message: "route not found"
      }
    });
  }
);

server.listen(port, () => {
  console.log(`server listening on port ${port}`);
});
```

## Verification

Run:

```bash
npm run server
```

In another terminal:

```bash
curl -i "http://localhost:3000/metrics?region=us-east"
```

The server terminal should log the method, path, query, and user-agent.

---

# 19. Graceful Server Shutdown

## The Target

We will close the HTTP server when the process receives a shutdown signal.

## The Concept

A production process should not stop abruptly while active requests or resources remain open.

A graceful shutdown usually:

1. Marks the process as shutting down.
2. Stops accepting new work.
3. Closes the server.
4. Releases resources.
5. Exits after cleanup.

## Implementation

### `primer-3/src/graceful-server.js`

```js
import http from "node:http";

const port = Number(
  process.env.PORT ?? 3000
);

let shuttingDown = false;

function sendJson(response, statusCode, body) {
  response.writeHead(statusCode, {
    "content-type": "application/json; charset=utf-8"
  });

  response.end(JSON.stringify(body));
}

const server = http.createServer(
  (request, response) => {
    if (shuttingDown) {
      sendJson(response, 503, {
        error: {
          code: "SHUTTING_DOWN",
          message: "server is shutting down"
        }
      });

      return;
    }

    if (
      request.method === "GET" &&
      request.url === "/live"
    ) {
      sendJson(response, 200, {
        status: "alive"
      });

      return;
    }

    sendJson(response, 404, {
      error: {
        code: "NOT_FOUND",
        message: "route not found"
      }
    });
  }
);

server.listen(port, () => {
  console.log(`server listening on port ${port}`);
});

let shutdownStarted = false;

function shutdown(signal) {
  if (shutdownStarted) {
    return;
  }

  shutdownStarted = true;
  shuttingDown = true;

  console.log(`received ${signal}`);

  server.close((error) => {
    if (error) {
      console.error("server close failed:", error);
      process.exitCode = 1;
      return;
    }

    console.log("server closed");
  });
}

process.on("SIGINT", () => {
  shutdown("SIGINT");
});

process.on("SIGTERM", () => {
  shutdown("SIGTERM");
});
```

## Verification

Run:

```bash
node src/graceful-server.js
```

In another terminal:

```bash
curl http://localhost:3000/live
```

Stop the server with:

```text
Ctrl+C
```

Expected logs:

```text
received SIGINT
server closed
```

---

# 20. Node.js Built-In Test Runner

## The Target

We will create and run a test using `node:test`.

## The Concept

Testing verifies behavior automatically.

A test usually has:

```text
arrange
  │
  ▼
act
  │
  ▼
assert
```

Node.js includes a test runner, so a basic project does not need a testing dependency.

## Implementation

Create:

```bash
mkdir -p test
```

### `primer-3/test/example.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

function add(first, second) {
  return first + second;
}

test("add returns the sum", () => {
  const result = add(2, 3);

  assert.equal(result, 5);
});

test("add handles negative numbers", () => {
  const result = add(-2, 3);

  assert.equal(result, 1);
});
```

## Verification

Run:

```bash
npm test
```

Expected output indicates that two tests passed.

Run only this test file:

```bash
node --test test/example.test.js
```

---

# 21. Testing Asynchronous Code

## The Target

We will test an asynchronous function.

## Concept

An asynchronous test must return or await the promise being tested. Otherwise, the test may finish before the operation completes.

## Implementation

### `primer-3/src/delay.js`

```js
export function delay(milliseconds, value) {
  if (
    !Number.isFinite(milliseconds) ||
    milliseconds < 0
  ) {
    throw new RangeError(
      "milliseconds must be non-negative and finite"
    );
  }

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}
```

### `primer-3/test/async.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import { delay } from "../src/delay.js";

test("delay resolves with its value", async () => {
  const result = await delay(5, "completed");

  assert.equal(result, "completed");
});

test("invalid delay rejects synchronously", () => {
  assert.throws(
    () => delay(-1, "invalid"),
    {
      name: "RangeError"
    }
  );
});

test("async rejection can be asserted", async () => {
  await assert.rejects(
    Promise.reject(
      new Error("expected failure")
    ),
    {
      message: "expected failure"
    }
  );
});
```

## Verification

Run:

```bash
npm test
```

Expected output indicates that all tests pass.

---

# 22. npm Dependencies

## The Target

We will distinguish production and development dependencies.

## The Concept

An npm package is reusable code distributed through npm.

Dependencies can be:

- **Production dependencies:** Required when the application runs.
- **Development dependencies:** Needed only for testing, linting, formatting, or building.

Install a production dependency:

```bash
npm install package-name
```

Install a development dependency:

```bash
npm install --save-dev package-name
```

For this primer, we use built-in Node.js APIs and do not need an external package.

## Verification

Inspect installed dependency metadata:

```bash
npm list --depth=0
```

At this point, the project may contain no external dependencies.

---

# 23. `package-lock.json`

## The Target

We will understand the lockfile.

## The Concept

`package-lock.json` records the exact dependency tree installed by npm.

It helps ensure that:

- Developers install consistent versions.
- CI installs the same dependency graph.
- Transitive dependency versions are known.
- Deployments are reproducible.

Commit the lockfile for applications.

Use:

```bash
npm ci
```

in CI or clean installation environments.

Use:

```bash
npm install
```

when intentionally changing dependency metadata.

---

# 24. npm Scripts

## The Target

We will create scripts for repeatable commands.

## The Concept

An npm script is a project-local command alias.

### `package.json`

```json
{
  "scripts": {
    "start": "node src/index.js",
    "test": "node --test",
    "check": "npm test"
  }
}
```

Run them:

```bash
npm start
npm test
npm run check
```

The `start` and `test` scripts can be invoked without `run`. Other scripts generally use:

```bash
npm run script-name
```

## Passing Arguments

```bash
npm run start -- --port=4000
```

The `--` separates npm arguments from program arguments.

---

# 25. Node.js Watch Mode

## The Target

We will rerun a program when its files change.

## Concept

Watch mode is useful during development. It is not normally a production process manager.

## Implementation

Add to `package.json`:

```json
{
  "scripts": {
    "dev": "node --watch src/index.js"
  }
}
```

## Verification

Run:

```bash
npm run dev
```

Change `src/index.js` and save it. Node.js should restart the program.

Stop watch mode with:

```text
Ctrl+C
```

---

# 26. Exit Codes

## The Target

We will set a non-zero exit code when a command fails.

## The Concept

Operating systems use exit codes to indicate whether a process completed successfully.

Common convention:

```text
0     success
non-0 failure
```

## Implementation

### `primer-3/src/exit-codes.js`

```js
function main() {
  const shouldFail =
    process.argv.includes("--fail");

  if (shouldFail) {
    console.error("operation failed");
    process.exitCode = 1;
    return;
  }

  console.log("operation succeeded");
}

main();
```

## Verification

Run:

```bash
node src/exit-codes.js
echo $?
```

On PowerShell:

```powershell
node src/exit-codes.js
$LASTEXITCODE
```

Expected exit code:

```text
0
```

Now run:

```bash
node src/exit-codes.js --fail
echo $?
```

Expected exit code:

```text
1
```

Prefer setting `process.exitCode` and allowing cleanup to finish instead of immediately calling `process.exit()`.

---

# 27. Streams and Standard Input

## The Target

We will read data from standard input.

## The Concept

Node.js exposes three standard streams:

- `process.stdin`: input.
- `process.stdout`: normal output.
- `process.stderr`: error output.

## Implementation

### `primer-3/src/stdin.js`

```js
let input = "";

process.stdin.setEncoding("utf8");

process.stdin.on("data", (chunk) => {
  input += chunk;
});

process.stdin.on("end", () => {
  console.log("received input:");
  console.log(input.trim());
});
```

## Verification

Run:

```bash
printf "hello from stdin\n" | node src/stdin.js
```

PowerShell alternative:

```powershell
"hello from stdin" | node src/stdin.js
```

Expected output:

```text
received input:
hello from stdin
```

For large input, process chunks rather than concatenating the entire stream into memory.

---

# 28. Reading Large Files as Streams

## The Target

We will read a file line by line without loading the entire file at once.

## Concept

Streams are useful when data may be larger than available memory.

## Implementation

### `primer-3/src/read-lines.js`

```js
import {
  createReadStream
} from "node:fs";

import {
  createInterface
} from "node:readline";

const input = createReadStream(
  "data/service.json",
  {
    encoding: "utf8"
  }
);

const lines = createInterface({
  input,
  crlfDelay: Infinity
});

for await (const line of lines) {
  console.log(line);
}
```

## Verification

Run:

```bash
node src/read-lines.js
```

The file contents should print one line at a time.

---

# 29. Basic `fetch()` from Node.js

## The Target

We will make an HTTP request using the built-in `fetch()` API.

## Concept

Modern Node.js includes a web-compatible `fetch()` implementation.

A successful network request does not guarantee an HTTP success status. Check `response.ok`.

## Implementation

### `primer-3/src/fetch-example.js`

```js
const response = await fetch(
  "https://example.com"
);

if (!response.ok) {
  throw new Error(
    `request failed with status ${response.status}`
  );
}

const body = await response.text();

console.log({
  status: response.status,
  bodyPreview: body.slice(0, 100)
});
```

## Verification

Run:

```bash
node src/fetch-example.js
```

Expected output resembles:

```text
{
  status: 200,
  bodyPreview: '<!doctype html>...'
}
```

This example requires network access. If the network is unavailable, the request may fail.

---

# 30. Fetch with Timeout and Cancellation

## The Target

We will add an abort signal to a fetch request.

## Concept

Network operations should have deadlines and cancellation.

## Implementation

### `primer-3/src/fetch-timeout.js`

```js
const controller = new AbortController();

const timeoutId = setTimeout(() => {
  const error = new Error(
    "request timed out"
  );

  error.name = "TimeoutError";
  controller.abort(error);
}, 5_000);

try {
  const response = await fetch(
    "https://example.com",
    {
      signal: controller.signal
    }
  );

  if (!response.ok) {
    throw new Error(
      `request failed with status ${response.status}`
    );
  }

  console.log("request succeeded");
} catch (error) {
  console.error({
    name: error.name,
    message: error.message
  });
} finally {
  clearTimeout(timeoutId);
}
```

## Verification

Run:

```bash
node src/fetch-timeout.js
```

Expected output is either:

```text
request succeeded
```

or a controlled error if the network or timeout fails.

---

# 31. HTTP Response Statuses

## The Target

We will classify common HTTP statuses.

## The Concept

HTTP status codes communicate the result of a request.

| Range | Meaning |
|---|---|
| 2xx | Success |
| 3xx | Redirection |
| 4xx | Client-side request problem |
| 5xx | Server or dependency failure |

Common statuses:

```text
200 OK
201 Created
204 No Content
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
408 Request Timeout
409 Conflict
429 Too Many Requests
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

## Implementation

### `primer-3/src/status-classification.js`

```js
function classifyStatus(status) {
  if (status >= 200 && status < 300) {
    return "success";
  }

  if (status >= 300 && status < 400) {
    return "redirect";
  }

  if (status >= 400 && status < 500) {
    return "client-error";
  }

  if (status >= 500 && status < 600) {
    return "server-error";
  }

  return "unknown";
}

for (const status of [
  200,
  404,
  429,
  503,
  700
]) {
  console.log(status, classifyStatus(status));
}
```

## Verification

Run:

```bash
node src/status-classification.js
```

Expected output:

```text
200 success
404 client-error
429 client-error
503 server-error
700 unknown
```

---

# 32. Basic Project Structure

## The Target

We will organize the primer project into clear layers.

## Concept

Directories communicate responsibility.

Create:

```bash
mkdir -p src/app
mkdir -p src/shared
mkdir -p src/infrastructure
mkdir -p test
```

Recommended structure:

```text
primer-3/
├── package.json
├── package-lock.json
├── .env.example
├── .gitignore
├── data/
├── src/
│   ├── app/
│   │   ├── configuration.js
│   │   └── bootstrap.js
│   ├── shared/
│   │   ├── validation.js
│   │   └── service-summary.js
│   ├── infrastructure/
│   │   ├── file-store.js
│   │   └── http-server.js
│   ├── arguments.js
│   ├── files.js
│   └── index.js
└── test/
    ├── configuration.test.js
    └── service-summary.test.js
```

A possible dependency direction:

```text
src/index.js
    │
    ▼
src/app/
    │
    ▼
src/shared/
    │
    ▼
infrastructure adapters
```

Shared domain logic should not depend on the HTTP server or filesystem.

---

# 33. Bootstrap Logic

## The Target

We will create an application bootstrap function.

## Concept

Bootstrap code initializes the application:

- Loads configuration.
- Creates dependencies.
- Starts services.
- Installs shutdown handlers.

Keep bootstrap separate from individual business modules.

## Implementation

### `primer-3/src/app/bootstrap.js`

```js
import {
  loadConfiguration
} from "./configuration.js";

export function bootstrap({
  environment = process.env,
  logger = console
} = {}) {
  const configuration =
    loadConfiguration(environment);

  logger.log("application configured", {
    environment:
      configuration.appEnvironment,
    port: configuration.port
  });

  return Object.freeze({
    configuration
  });
}
```

### `primer-3/src/app/main.js`

```js
import { bootstrap } from "./bootstrap.js";

const application = bootstrap();

console.log(
  "application started on port:",
  application.configuration.port
);
```

## Verification

Run:

```bash
API_BASE_URL="https://api.example.test" node src/app/main.js
```

If the configuration loader requires `API_BASE_URL`, provide it as shown.

---

# 34. Testing Project Configuration

## The Target

We will test configuration without changing the real process environment.

## Concept

Pass an environment object into the configuration function.

This is easier to test than reading `process.env` directly inside every function.

## Implementation

### `primer-3/test/configuration.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

import {
  loadConfiguration
} from "../src/configuration.js";

test("configuration uses defaults", () => {
  const configuration = loadConfiguration({});

  assert.equal(
    configuration.appEnvironment,
    "development"
  );

  assert.equal(configuration.port, 3000);
});

test("configuration parses environment values", () => {
  const configuration = loadConfiguration({
    APP_ENV: "production",
    PORT: "4000",
    REQUEST_TIMEOUT_MS: "2000"
  });

  assert.equal(
    configuration.appEnvironment,
    "production"
  );

  assert.equal(configuration.port, 4000);
  assert.equal(
    configuration.requestTimeoutMilliseconds,
    2000
  );
});

test("configuration rejects invalid ports", () => {
  assert.throws(
    () =>
      loadConfiguration({
        PORT: "invalid"
      }),
    {
      message: "PORT must be a positive integer"
    }
  );
});
```

## Verification

Run:

```bash
npm test
```

---

# 35. Test Environment Isolation

## The Target

We will demonstrate why tests should not modify global environment state permanently.

## Bad Pattern

```js
process.env.APP_ENV = "test";
```

If a test does this and does not restore the old value, later tests may behave differently.

## Safer Pattern

Pass an explicit object:

```js
const configuration = loadConfiguration({
  APP_ENV: "test"
});
```

If modifying global state is unavoidable, save and restore it:

```js
const previousValue = process.env.APP_ENV;

try {
  process.env.APP_ENV = "test";
  // test
} finally {
  if (previousValue === undefined) {
    delete process.env.APP_ENV;
  } else {
    process.env.APP_ENV = previousValue;
  }
}
```

---

# 36. Static Analysis and Formatting

## The Target

We will understand where linting and formatting fit.

## The Concept

A linter checks source code for likely mistakes and style violations.

A formatter applies consistent layout.

Typical commands might be:

```bash
npm run lint
npm run format:check
```

These tools are not substitutes for tests. They catch different classes of problems.

## Example Script Configuration

If you later install a linter and formatter:

### `package.json`

```json
{
  "scripts": {
    "lint": "eslint .",
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  }
}
```

## Verification

The commands require the corresponding packages to be installed. Do not add scripts for tools that are not installed.

---

# 37. Debugging Node.js Programs

## Console Debugging

```js
console.log({
  event: "request_started",
  requestId: "request-123"
});
```

Prefer structured objects over long concatenated strings.

## Debugger Statement

```js
function calculate(value) {
  debugger;

  return value * 2;
}
```

Run with:

```bash
node --inspect-brk src/debug-example.js
```

Then open Node.js inspection tools through Chrome:

```text
chrome://inspect
```

## Stack Traces

```js
try {
  throw new Error("diagnostic failure");
} catch (error) {
  console.error(error.stack);
}
```

Do not expose internal stack traces to end users in production HTTP responses.

---

# 38. Standard Output and Standard Error

## The Target

We will separate normal output from error output.

## Implementation

### `primer-3/src/output.js`

```js
console.log("normal application output");

console.error("diagnostic error output");

process.stdout.write("stdout without automatic newline\n");
process.stderr.write("stderr without automatic newline\n");
```

## Verification

Run:

```bash
node src/output.js
```

Redirect standard output:

```bash
node src/output.js > output.txt
```

Inspect:

```bash
cat output.txt
```

Standard error may still appear in the terminal because it is a separate stream.

---

# 39. Signal Handling

## The Target

We will observe process signals.

## The Concept

Operating systems send signals to processes.

Common signals:

- `SIGINT`: usually generated by `Ctrl+C`.
- `SIGTERM`: termination request, common during deployment.
- `SIGHUP`: terminal or configuration-related signal on some systems.

## Implementation

### `primer-3/src/signals.js`

```js
let shuttingDown = false;

function handleShutdown(signal) {
  if (shuttingDown) {
    return;
  }

  shuttingDown = true;

  console.log(`received ${signal}`);
  console.log("cleanup complete");

  process.exitCode = 0;
}

process.on("SIGINT", () => {
  handleShutdown("SIGINT");
});

process.on("SIGTERM", () => {
  handleShutdown("SIGTERM");
});

console.log(
  "process running; press Ctrl+C to stop"
);

setInterval(() => {
  console.log("still running");
}, 2_000);
```

## Verification

Run:

```bash
node src/signals.js
```

Press:

```text
Ctrl+C
```

Expected output includes:

```text
received SIGINT
cleanup complete
```

This example leaves an interval active until the process receives a signal. A production shutdown handler should also clear the interval.

---

# 40. Correct Signal Cleanup

## Implementation

### `primer-3/src/signals-cleanup.js`

```js
let shuttingDown = false;

const intervalId = setInterval(() => {
  console.log("still running");
}, 2_000);

function handleShutdown(signal) {
  if (shuttingDown) {
    return;
  }

  shuttingDown = true;

  clearInterval(intervalId);

  console.log(`received ${signal}`);
  console.log("interval cleared");
  console.log("cleanup complete");
}

process.on("SIGINT", () => {
  handleShutdown("SIGINT");
});

process.on("SIGTERM", () => {
  handleShutdown("SIGTERM");
});

console.log(
  "process running; press Ctrl+C to stop"
);
```

## Verification

Run:

```bash
node src/signals-cleanup.js
```

Press `Ctrl+C`.

The process should stop without leaving the interval active.

---

# 41. Node.js Permission and File Boundaries

Node.js applications can access operating-system resources.

When handling external input:

- Validate filenames.
- Restrict directories.
- Limit file sizes.
- Avoid executing untrusted commands.
- Validate URLs.
- Avoid unsafe shell interpolation.

Never do this with untrusted input:

```js
import { exec } from "node:child_process";

exec(`grep ${userInput} file.txt`);
```

If a subprocess is required, prefer APIs that separate arguments from the command:

```js
import { execFile } from "node:child_process";

execFile(
  "grep",
  [userInput, "file.txt"],
  callback
);
```

Even then, validate arguments according to the application’s requirements.

---

# 42. Child Processes

## The Target

We will run a child process safely with explicit arguments.

## Concept

A child process is a separate operating-system process.

Use child processes when:

- Running an external command.
- Isolating work.
- Integrating with system tools.
- Executing a separate application.

## Implementation

### `primer-3/src/child-process.js`

```js
import {
  execFile
} from "node:child_process";

const command =
  process.platform === "win32"
    ? "node.exe"
    : "node";

execFile(
  command,
  [
    "--version"
  ],
  {
    encoding: "utf8"
  },
  (error, stdout, stderr) => {
    if (error) {
      console.error({
        message: error.message,
        stderr
      });

      process.exitCode = 1;
      return;
    }

    console.log("child Node.js version:");
    console.log(stdout.trim());
  }
);
```

## Verification

Run:

```bash
node src/child-process.js
```

Expected output displays the child process’s Node.js version.

---

# 43. Worker Threads Versus Child Processes

Use **worker threads** when:

- You need JavaScript parallelism.
- Shared process resources are appropriate.
- The task is CPU-heavy.
- Lower startup overhead matters.

Use **child processes** when:

- You need process isolation.
- You are running another executable.
- A failure should not directly corrupt the parent process.
- Separate memory and permissions are useful.

Both require explicit lifecycle cleanup.

---

# 44. Project Readiness Checklist

You are ready for the main series when you can:

## Node.js

- [ ] Explain what Node.js provides beyond the JavaScript language.
- [ ] Run a JavaScript file with `node`.
- [ ] Read `process.argv`.
- [ ] Read and validate environment variables.
- [ ] Understand `process.exitCode`.
- [ ] Handle `SIGINT` and `SIGTERM`.

## npm

- [ ] Create a project with `npm init`.
- [ ] Explain `package.json`.
- [ ] Run npm scripts.
- [ ] Understand `package-lock.json`.
- [ ] Use `npm ci`.
- [ ] Distinguish production and development dependencies.

## Filesystem

- [ ] Build paths with `node:path`.
- [ ] Read files asynchronously.
- [ ] Write files asynchronously.
- [ ] Parse JSON safely.
- [ ] Handle missing files.
- [ ] Prevent path traversal.

## HTTP

- [ ] Create a basic HTTP server.
- [ ] Return status codes and headers.
- [ ] Parse URLs and query parameters.
- [ ] Check `fetch()` response status.
- [ ] Add request timeouts.
- [ ] Shut down a server gracefully.

## Testing

- [ ] Write a Node.js test.
- [ ] Use strict assertions.
- [ ] Test asynchronous code.
- [ ] Test expected errors.
- [ ] Keep tests isolated.

---

# 45. Complete Verification Commands

From the `primer-3` directory, run:

```bash
npm run hello
npm run config
npm run files
npm test
```

Run the additional examples:

```bash
node src/process-info.js
node src/arguments.js --environment=production --verbose
node src/paths.js
node src/module-path.js
node src/write-file.js
node src/read-json.js
node src/safe-path.js
node src/status-classification.js
node src/fetch-example.js
node src/fetch-timeout.js
node src/output.js
node src/child-process.js
```

Start the server:

```bash
npm run server
```

Verify it:

```bash
curl -i http://localhost:3000/metrics
```

Stop it with:

```text
Ctrl+C
```

---

# 46. Primer Summary

Node.js provides the host environment needed to build and run the main tutorial project:

```text
JavaScript language
        │
        ▼
V8 engine
        │
        ▼
Node.js runtime
        │
        ├── filesystem
        ├── HTTP
        ├── process lifecycle
        ├── environment variables
        ├── streams
        ├── workers
        └── testing tools
```

The main project workflow is:

```text
create project
    │
    ▼
configure package.json
    │
    ▼
write ECMAScript modules
    │
    ▼
validate environment configuration
    │
    ▼
run with npm scripts
    │
    ▼
test with node:test
    │
    ▼
start server or application
    │
    ▼
handle signals and cleanup
```

The most important habits are:

1. Use ECMAScript modules with explicit import paths.
2. Keep configuration outside source code.
3. Validate environment variables before using them.
4. Use asynchronous filesystem APIs.
5. Build paths with `node:path`.
6. Check HTTP response status explicitly.
7. Add timeouts and cancellation to network work.
8. Keep secrets out of source control and logs.
9. Set `process.exitCode` instead of terminating abruptly when cleanup matters.
10. Test asynchronous behavior by awaiting it.
11. Separate shared logic from Node.js-specific adapters.
12. Handle process shutdown explicitly.
