# Appendix F: Browser and Node.js Runtime Differences

JavaScript is a language, but it does not run in isolation.

It runs inside a **host environment** that provides additional APIs and scheduling behavior.

The two most common host environments are:

- Web browsers.
- Node.js.

Both execute JavaScript, support ECMAScript features, and provide promises, modules, timers, and garbage collection. However, they differ significantly in:

- Global objects.
- File and network APIs.
- Rendering.
- Event-loop phases.
- Process lifecycle.
- Worker APIs.
- Security boundaries.
- Module loading.
- Timers.
- Streams.
- Error handling.
- Resource ownership.

Understanding these differences prevents code from accidentally depending on an API that exists only in one environment.

---

# F.1: Language Versus Host Environment

## JavaScript Language Features

These are language or standardized platform features:

```js
const value = 42;

function add(first, second) {
  return first + second;
}

const promise = Promise.resolve("done");

const object = new Proxy(
  {},
  {
    get(target, property, receiver) {
      return Reflect.get(target, property, receiver);
    }
  }
);
```

Both browsers and Node.js support these features in modern versions.

## Host APIs

These APIs are supplied by the environment:

```js
setTimeout(() => {
  console.log("timer");
}, 1000);
```

```js
fetch("https://example.com");
```

```js
document.querySelector("button");
```

```js
import fs from "node:fs/promises";
```

The browser provides `document`. Node.js provides `node:fs/promises`. They are not interchangeable.

---

# F.2: Global Objects

## Browser Global Object

In browser code, the traditional global object is `window`.

```js
console.log(window.location.href);
console.log(window.document);
```

The standardized universal reference is:

```js
console.log(globalThis);
```

## Node.js Global Object

Node.js exposes:

```js
console.log(global);
console.log(globalThis);
```

`globalThis` is the portable standard reference.

## Recommended Practice

Prefer:

```js
globalThis.setTimeout(() => {
  console.log("timer");
}, 100);
```

or simply:

```js
setTimeout(() => {
  console.log("timer");
}, 100);
```

Avoid writing application code that assumes `window` or `global` unless the environment is intentionally specific.

---

# F.3: Global API Comparison

| Capability | Browser | Node.js |
|---|---|---|
| Universal global reference | `globalThis` | `globalThis` |
| Browser global alias | `window` | Not normally available |
| Node global alias | Not available | `global` |
| DOM | Yes | No built-in DOM |
| Filesystem | Restricted browser APIs | `node:fs` and `node:fs/promises` |
| Process object | Not generally available | `process` |
| Web Storage | `localStorage`, `sessionStorage` | Not built in |
| Fetch | Modern browsers | Modern Node.js |
| WebSocket | Browser support | Version-dependent/global or package-based |
| Rendering | Yes | No |
| Web Workers | `Worker` | `worker_threads` |
| Timers | Browser timer APIs | Node timer APIs |
| Streams | Web Streams | Node streams and Web Streams |
| Cryptography | Web Crypto | Web Crypto plus Node crypto |

---

# F.4: Detecting the Runtime

## The Target

We will create a small runtime-detection utility.

## Concept

Runtime detection should be isolated in one module rather than scattered throughout the application.

## Implementation

### `src/runtime/environment.js`

```js
"use strict";

export const runtimeEnvironment = Object.freeze({
  isBrowser:
    typeof window !== "undefined" &&
    typeof document !== "undefined",

  isNode:
    typeof process !== "undefined" &&
    process.versions?.node !== undefined,

  isWorker:
    typeof self !== "undefined" &&
    typeof window === "undefined" &&
    typeof document === "undefined"
});

export function assertRuntime(
  expectedRuntime
) {
  if (
    !["browser", "node", "worker"].includes(
      expectedRuntime
    )
  ) {
    throw new RangeError(
      "expectedRuntime must be browser, node, or worker"
    );
  }

  const matches = {
    browser: runtimeEnvironment.isBrowser,
    node: runtimeEnvironment.isNode,
    worker: runtimeEnvironment.isWorker
  };

  if (!matches[expectedRuntime]) {
    throw new Error(
      `this module requires the ${expectedRuntime} runtime`
    );
  }
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { runtimeEnvironment } from "./src/runtime/environment.js";

console.log(runtimeEnvironment);
EOF
```

Expected output resembles:

```text
{ isBrowser: false, isNode: true, isWorker: false }
```

Runtime detection should be used only when behavior genuinely differs. Prefer portable APIs when possible.

---

# F.5: Browser DOM Versus Node.js No-DOM Environment

## Browser

Browsers expose the Document Object Model, or DOM.

```js
const button = document.querySelector("#refresh");

button.addEventListener("click", () => {
  document.body.dataset.status = "refreshing";
});
```

## Node.js

Node.js does not provide `document` or `window` by default.

This fails:

```js
console.log(document.querySelector("button"));
```

Typical error:

```text
ReferenceError: document is not defined
```

## Architecture Rule

Keep DOM code at the UI boundary.

Prefer:

```text
core logic
  ├── works without DOM
  └── can run in Node tests

browser adapter
  ├── reads DOM
  ├── attaches events
  └── renders results
```

This makes core code testable in Node.js.

---

# F.6: Browser Entry Point

## Implementation

### `public/app.js`

```js
"use strict";

import { createDashboardView } from "./dashboard-view.js";

const root = document.querySelector("#app");

if (!root) {
  throw new Error("application root was not found");
}

const view = createDashboardView(root);

view.render({
  status: "ready",
  services: {
    metrics: {
      status: "healthy",
      value: {
        requestsPerSecond: 125
      }
    }
  }
});
```

### `public/dashboard-view.js`

```js
"use strict";

export function createDashboardView(root) {
  if (!(root instanceof HTMLElement)) {
    throw new TypeError(
      "root must be an HTMLElement"
    );
  }

  function render(state) {
    root.replaceChildren();

    const heading = document.createElement("h1");
    heading.textContent = "Runtime Monitor";

    const status = document.createElement("p");
    status.textContent = `Status: ${state.status}`;

    root.append(heading, status);

    for (const [name, service] of Object.entries(
      state.services
    )) {
      const serviceElement = document.createElement("section");
      serviceElement.dataset.service = name;

      const serviceHeading = document.createElement("h2");
      serviceHeading.textContent = name;

      const serviceStatus = document.createElement("p");
      serviceStatus.textContent =
        `Service status: ${service.status}`;

      serviceElement.append(
        serviceHeading,
        serviceStatus
      );

      root.append(serviceElement);
    }
  }

  return Object.freeze({
    render
  });
}
```

### `public/index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    >
    <title>Runtime Monitor</title>
  </head>
  <body>
    <main id="app"></main>
    <script
      type="module"
      src="./app.js"
    ></script>
  </body>
</html>
```

## Verification

A browser must serve module files over HTTP in many configurations. From the project root, run a static server such as:

```bash
npx serve public
```

Open the displayed URL in a browser.

Expected page content:

```text
Runtime Monitor
Status: ready
metrics
Service status: healthy
```

---

# F.7: Node.js Entry Point

## Implementation

### `src/node-entry.js`

```js
"use strict";

import { createDashboardSummary } from "./shared/dashboard-summary.js";

const state = {
  status: "ready",
  services: {
    metrics: {
      status: "healthy",
      requestsPerSecond: 125
    }
  }
};

console.log(createDashboardSummary(state));
```

### `src/shared/dashboard-summary.js`

```js
"use strict";

export function createDashboardSummary(state) {
  if (
    state === null ||
    typeof state !== "object"
  ) {
    throw new TypeError("state must be an object");
  }

  const services = Object.values(
    state.services ?? {}
  );

  const healthyCount = services.filter(
    (service) => service.status === "healthy"
  ).length;

  return {
    status: state.status,
    totalServices: services.length,
    healthyServices: healthyCount
  };
}
```

## Verification

Run:

```bash
node src/node-entry.js
```

Expected output:

```text
{
  status: 'ready',
  totalServices: 1,
  healthyServices: 1
}
```

The shared summary logic does not need the DOM and can run in both environments.

---

# F.8: Browser and Node.js Module Loading

## Browser Modules

Browser modules use URL-like paths:

```js
import { render } from "./render.js";
```

The file must usually be served with a JavaScript MIME type.

Browser imports are resolved relative to the importing module.

## Node.js ECMAScript Modules

Node.js uses file paths or package specifiers:

```js
import { readFile } from "node:fs/promises";
import { calculate } from "./calculate.js";
```

With `"type": "module"` in `package.json`, include file extensions for relative imports:

```js
import { calculate } from "./calculate.js";
```

Do not assume this works:

```js
import { calculate } from "./calculate";
```

## Node-Specific Built-In Modules

Use the `node:` prefix:

```js
import fs from "node:fs/promises";
import path from "node:path";
import { EventEmitter } from "node:events";
```

This makes it clear that the dependency is built into Node.js.

---

# F.9: CommonJS and ECMAScript Modules

Node.js supports two major module systems.

## ECMAScript Modules

```js
import { add } from "./math.js";

export function calculate() {
  return add(2, 3);
}
```

## CommonJS

```js
const { add } = require("./math.cjs");

module.exports = {
  calculate() {
    return add(2, 3);
  }
};
```

Do not casually mix module systems.

### Package Configuration

```json
{
  "type": "module"
}
```

This treats `.js` files as ECMAScript modules.

Use `.cjs` for CommonJS files when needed:

```text
legacy-config.cjs
```

Use `.mjs` for ECMAScript modules when a file must be explicit:

```text
modern-module.mjs
```

---

# F.10: Timers

## Shared Basic API

Both environments support:

```js
const timeoutId = setTimeout(() => {
  console.log("later");
}, 100);

clearTimeout(timeoutId);
```

```js
const intervalId = setInterval(() => {
  console.log("repeated");
}, 100);

clearInterval(intervalId);
```

## Browser Timer Identifiers

Browsers commonly return numeric timer identifiers.

## Node.js Timer Handles

Node.js returns timer objects.

```js
const timeout = setTimeout(() => {
  console.log("later");
}, 100);

console.log(timeout);
```

Do not write code that assumes timer identifiers are numbers.

Use the returned value opaquely:

```js
clearTimeout(timeout);
```

---

# F.11: Node.js Timer Promises

Node.js provides promise-based timers.

## Implementation

### `src/node-timer.js`

```js
"use strict";

import {
  setTimeout as delay
} from "node:timers/promises";

const controller = new AbortController();

const operation = delay(
  1_000,
  "completed",
  {
    signal: controller.signal
  }
);

setTimeout(() => {
  controller.abort();
}, 20);

try {
  console.log(await operation);
} catch (error) {
  console.log(error.name);
}
```

## Verification

Run:

```bash
node src/node-timer.js
```

Expected output resembles:

```text
AbortError
```

This is Node-specific. Browser code can use a custom cancellation-aware delay or compatible web APIs.

---

# F.12: Fetch Differences

Modern browsers and current Node.js versions provide `fetch()`.

```js
const response = await fetch(
  "https://example.com/data"
);
```

However, surrounding behavior can differ.

## Browser Fetch

Browser fetch is affected by:

- Same-origin policy.
- CORS.
- Cookies.
- Credentials mode.
- Service workers.
- Browser cache.
- Content security policy.

## Node.js Fetch

Node.js fetch is not governed by browser CORS restrictions.

Node.js has different defaults for:

- Proxy behavior.
- Certificate configuration.
- Cookie persistence.
- Connection pooling.
- File URL handling.
- Process lifecycle.

## Important Rule

`fetch()` does not reject merely because the server returns HTTP 404 or 500.

```js
const response = await fetch(url);

if (!response.ok) {
  throw new Error(
    `HTTP request failed: ${response.status}`
  );
}
```

Use this check in both environments.

---

# F.13: Portable HTTP Client

## Implementation

### `src/shared/http-client.js`

```js
"use strict";

export function createHttpClient({
  fetchFunction = globalThis.fetch,
  baseUrl,
  timeoutMilliseconds = 5_000
}) {
  if (typeof fetchFunction !== "function") {
    throw new TypeError(
      "fetchFunction must be a function"
    );
  }

  if (typeof baseUrl !== "string") {
    throw new TypeError("baseUrl must be a string");
  }

  if (
    !Number.isFinite(timeoutMilliseconds) ||
    timeoutMilliseconds <= 0
  ) {
    throw new RangeError(
      "timeoutMilliseconds must be positive and finite"
    );
  }

  async function get(path, parentSignal) {
    const controller = new AbortController();

    let timeoutId;

    const forwardAbort = () => {
      controller.abort(
        parentSignal.reason ??
        new Error("parent operation aborted")
      );
    };

    if (parentSignal) {
      if (parentSignal.aborted) {
        forwardAbort();
      } else {
        parentSignal.addEventListener(
          "abort",
          forwardAbort,
          { once: true }
        );
      }
    }

    timeoutId = setTimeout(() => {
      const error = new Error(
        `request timed out after ${timeoutMilliseconds} ms`
      );

      error.name = "TimeoutError";
      controller.abort(error);
    }, timeoutMilliseconds);

    try {
      const response = await fetchFunction(
        new URL(path, baseUrl),
        {
          method: "GET",
          signal: controller.signal
        }
      );

      if (!response.ok) {
        const error = new Error(
          `request failed with status ${response.status}`
        );

        error.name = "HttpError";
        error.status = response.status;

        throw error;
      }

      return response.json();
    } finally {
      clearTimeout(timeoutId);

      parentSignal?.removeEventListener(
        "abort",
        forwardAbort
      );
    }
  }

  return Object.freeze({
    get
  });
}
```

This client uses APIs common to modern browsers and Node.js.

---

# F.14: CORS

## Browser Behavior

A browser may block a cross-origin request unless the server permits it.

For example:

```text
application origin: https://dashboard.example
API origin:         https://api.example
```

The API must return appropriate headers, such as:

```http
Access-Control-Allow-Origin: https://dashboard.example
```

## Node.js Behavior

Node.js does not enforce browser CORS rules for server-side fetch calls.

A Node.js backend can request another origin without needing `Access-Control-Allow-Origin`.

## Architecture Implication

A common architecture is:

```text
browser
   │ same-origin request
   ▼
application server
   │ server-side request
   ▼
external API
```

The server becomes the browser-facing boundary and can handle:

- Authentication.
- CORS.
- Retries.
- Timeouts.
- Circuit breaking.
- Response validation.

---

# F.15: Browser Storage Versus Node.js Storage

## Browser Storage

```js
localStorage.setItem(
  "theme",
  "dark"
);

const theme = localStorage.getItem("theme");
```

Browser storage is:

- Synchronous.
- Origin-specific.
- Limited in size.
- User-controlled.
- Not a secure secret store.

Do not store sensitive tokens in local storage without understanding the XSS risks.

## Node.js Storage

Node.js can read files:

```js
import {
  readFile,
  writeFile
} from "node:fs/promises";

await writeFile(
  "configuration.json",
  JSON.stringify({ environment: "production" }),
  "utf8"
);

const content = await readFile(
  "configuration.json",
  "utf8"
);

console.log(content);
```

Filesystem access must be protected against:

- Path traversal.
- Unauthorized access.
- Excessive file size.
- Concurrent writes.
- Sensitive-data exposure.

---

# F.16: Browser and Node.js Security Boundaries

## Browser Security Model

Browsers isolate web pages using:

- Same-origin policy.
- Sandboxing.
- Permissions.
- Content security policy.
- User gesture requirements.
- Cross-origin restrictions.

## Node.js Security Model

Node.js runs with operating-system privileges granted to the process.

A Node.js application may access:

- Files.
- Network sockets.
- Environment variables.
- Child processes.
- System resources.

This means server-side code must validate untrusted input carefully.

Never assume that moving code from the browser to Node.js automatically makes it safe.

---

# F.17: Process Lifecycle in Node.js

## Node.js Process

Node.js applications have a process lifecycle.

Useful events include:

```js
process.on("SIGTERM", () => {
  console.log("termination requested");
});
```

```js
process.on("SIGINT", () => {
  console.log("interrupt requested");
});
```

A server should stop accepting new work and close resources.

## Browser Lifecycle

Browsers do not expose an equivalent process lifecycle.

Browser applications respond to events such as:

```js
window.addEventListener("pagehide", () => {
  console.log("page is being hidden");
});
```

```js
window.addEventListener("beforeunload", () => {
  console.log("page is unloading");
});
```

Do not depend on asynchronous cleanup completing during page unload. Use appropriate browser mechanisms such as:

- `navigator.sendBeacon()`.
- `fetch()` with `keepalive` where appropriate.
- Server-side session expiration.
- Explicit component cleanup before navigation.

---

# F.18: Graceful Shutdown in Node.js

## Implementation

### `src/node-shutdown.js`

```js
"use strict";

import http from "node:http";

const server = http.createServer(
  (_request, response) => {
    response.writeHead(200, {
      "content-type": "text/plain"
    });

    response.end("healthy\n");
  }
);

server.listen(3_000, () => {
  console.log("server listening on port 3000");
});

let shuttingDown = false;

async function shutdown(signal) {
  if (shuttingDown) {
    return;
  }

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

process.on("SIGTERM", () => {
  void shutdown("SIGTERM");
});

process.on("SIGINT", () => {
  void shutdown("SIGINT");
});
```

## Verification

Run:

```bash
node src/node-shutdown.js
```

In another terminal:

```bash
curl http://localhost:3000
```

Stop the process with:

```bash
Ctrl+C
```

Expected logs:

```text
received SIGINT
server closed
```

---

# F.19: Browser Page Lifecycle

## Implementation

### `public/page-lifecycle.js`

```js
"use strict";

const controller = new AbortController();

window.addEventListener(
  "pagehide",
  () => {
    controller.abort(
      new Error("page is no longer active")
    );
  },
  {
    signal: controller.signal
  }
);

window.addEventListener(
  "visibilitychange",
  () => {
    if (document.visibilityState === "hidden") {
      console.log("page is hidden");
    } else {
      console.log("page is visible");
    }
  },
  {
    signal: controller.signal
  }
);
```

The `signal` option automatically removes the event listeners when the controller aborts.

This is a useful browser cleanup pattern.

---

# F.20: Web Workers Versus Node.js Worker Threads

## Browser Web Worker

A browser worker runs JavaScript away from the page’s main thread.

### `public/browser-worker.js`

```js
"use strict";

self.addEventListener("message", (event) => {
  const { limit } = event.data;

  let total = 0;

  for (let index = 0; index <= limit; index += 1) {
    total += index;
  }

  self.postMessage({
    total
  });
});
```

### Browser Caller

```js
"use strict";

const worker = new Worker(
  "./browser-worker.js",
  {
    type: "module"
  }
);

worker.addEventListener("message", (event) => {
  console.log(event.data.total);
});

worker.postMessage({
  limit: 1_000_000
});
```

## Node.js Worker Thread

Node.js uses the `worker_threads` module.

```js
import {
  Worker
} from "node:worker_threads";
```

Workers have different APIs and lifecycle rules, but the architectural purpose is similar:

> Move CPU-heavy work away from the main JavaScript execution thread.

---

# F.21: Worker Communication

Both browser workers and Node.js workers commonly communicate through messages.

```text
main thread
    │ postMessage()
    ▼
worker
    │ postMessage()
    ▼
main thread
```

Data is commonly transferred using structured cloning.

Some large binary objects can be transferred rather than copied:

```js
worker.postMessage(
  arrayBuffer,
  [arrayBuffer]
);
```

After transfer, the original owner may no longer be able to use the transferred buffer.

---

# F.22: Web Streams and Node.js Streams

## Web Streams

Browsers and modern Node.js versions support Web Streams APIs:

```js
const stream = new ReadableStream({
  start(controller) {
    controller.enqueue("first");
    controller.enqueue("second");
    controller.close();
  }
});
```

## Node.js Streams

Node.js has a mature stream system:

```js
import {
  createReadStream
} from "node:fs";

const stream = createReadStream(
  "large-file.txt",
  "utf8"
);

stream.on("data", (chunk) => {
  console.log(chunk);
});
```

Node.js streams are important for processing large data without loading everything into memory.

---

# F.23: Backpressure

**Backpressure** occurs when a producer creates data faster than a consumer can process it.

Without backpressure:

```text
fast producer ─────────► memory grows
slow consumer
```

With backpressure:

```text
fast producer ── waits ─► controlled memory usage
slow consumer
```

Node.js streams provide backpressure mechanisms. In browser code, `ReadableStream` and `WritableStream` offer related control.

The architectural lesson is:

> Never assume a producer can run at unlimited speed without affecting memory.

---

# F.24: Node.js Event Loop Versus Browser Event Loop

## Browser

The browser coordinates:

- Tasks.
- Microtasks.
- Rendering.
- Animation frames.
- User input.
- Network events.
- Layout and painting.

## Node.js

Node.js coordinates:

- Timers.
- Pending callbacks.
- Polling for I/O.
- Check callbacks.
- Close callbacks.
- `process.nextTick()`.
- Promise microtasks.

## Shared Rule

Both environments generally follow:

```text
current synchronous code
        │
        ▼
microtasks
        │
        ▼
later host-managed work
```

## Important Difference

Node.js has APIs that browsers do not:

```js
process.nextTick();
setImmediate();
```

Browsers have APIs that Node.js does not provide by default:

```js
requestAnimationFrame();
document.querySelector();
window.addEventListener();
```

---

# F.25: `process.nextTick()` Versus `queueMicrotask()`

## Node.js

```js
process.nextTick(() => {
  console.log("Node-specific priority callback");
});
```

## Portable Microtask

```js
queueMicrotask(() => {
  console.log("portable microtask");
});
```

Prefer `queueMicrotask()` when you need a standard microtask and do not require Node-specific next-tick semantics.

Use `process.nextTick()` only when its Node.js scheduling behavior is intentional.

---

# F.26: Browser `requestAnimationFrame()` Versus Node.js Scheduling

## Browser Visual Work

```js
requestAnimationFrame(() => {
  render();
});
```

This aligns work with the browser’s visual frame.

## Node.js Non-Visual Work

Node.js has no browser rendering pipeline. Use:

```js
setImmediate(() => {
  processNextBatch();
});
```

or:

```js
setTimeout(() => {
  processNextBatch();
}, 0);
```

The correct choice depends on whether you want:

- A later timer task.
- A check-phase callback.
- A bounded batch.
- A scheduled idle period.

---

# F.27: Environment-Neutral Scheduling Adapter

## The Target

We will create a scheduler that chooses a browser frame or a Node.js task.

## Implementation

### `src/shared/scheduler.js`

```js
"use strict";

export function createScheduler({
  requestAnimationFrameFunction =
    globalThis.requestAnimationFrame,
  setImmediateFunction =
    globalThis.setImmediate,
  setTimeoutFunction =
    globalThis.setTimeout
} = {}) {
  function scheduleVisualUpdate(callback) {
    if (typeof callback !== "function") {
      throw new TypeError(
        "callback must be a function"
      );
    }

    if (
      typeof requestAnimationFrameFunction ===
      "function"
    ) {
      return requestAnimationFrameFunction(callback);
    }

    if (
      typeof setImmediateFunction ===
      "function"
    ) {
      return setImmediateFunction(callback);
    }

    return setTimeoutFunction(callback, 0);
  }

  return Object.freeze({
    scheduleVisualUpdate
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createScheduler } from "./src/shared/scheduler.js";

const scheduler = createScheduler();

scheduler.scheduleVisualUpdate(() => {
  console.log("scheduled update");
});
EOF
```

Expected output:

```text
scheduled update
```

This adapter keeps environment checks in one place.

---

# F.28: Environment-Specific Package Exports

Larger packages can expose different files for different environments.

Conceptually:

```json
{
  "exports": {
    ".": {
      "browser": "./dist/browser.js",
      "node": "./dist/node.js",
      "default": "./dist/shared.js"
    }
  }
}
```

This lets consumers import one package path while the resolver selects the appropriate environment implementation.

Use this only when the distinction is valuable. Environment-specific exports increase packaging complexity.

---

# F.29: Browser Bundling Versus Node.js Deployment

## Browser

Browser applications are often:

1. Authored as modules.
2. Bundled or served directly.
3. Minified.
4. Split into chunks.
5. Delivered over HTTP.
6. Cached by the browser.

Browser build systems may provide:

- Tree shaking.
- Code splitting.
- Asset hashing.
- CSS processing.
- Environment replacement.

## Node.js

Node.js applications are often:

1. Installed with dependencies.
2. Started as server processes.
3. Configured through environment variables.
4. Deployed in containers or virtual machines.
5. Kept running as long-lived processes.

Node.js bundling is optional and depends on deployment goals.

---

# F.30: Environment Variables

## Browser Configuration

Never assume browser environment variables are private.

Values embedded in a browser bundle are visible to users.

Safe browser configuration may include:

```text
PUBLIC_API_BASE_URL=https://api.example.com
```

Do not embed:

```text
DATABASE_PASSWORD=secret
PRIVATE_API_KEY=secret
```

## Node.js Configuration

Node.js can read server-side environment variables:

```js
const databasePassword =
  process.env.DATABASE_PASSWORD;
```

Do not log secrets or expose them in responses.

---

# F.31: Browser Storage and Node.js Secrets

## Browser

Avoid storing sensitive credentials in:

```js
localStorage
```

An XSS vulnerability may allow injected code to read local storage.

Use secure, appropriately configured cookies or other authentication architectures where possible.

## Node.js

Environment variables are not automatically secure. They can be exposed through:

- Process inspection.
- Debug logs.
- Crash reports.
- Misconfigured containers.
- Child-process inheritance.

Secret handling is an operational concern in both environments.

---

# F.32: File URLs and Paths

## Browser

Browser module URLs use URL syntax:

```text
/assets/app.js
```

## Node.js

Node.js filesystem paths vary by operating system.

Use Node’s path utilities:

```js
import path from "node:path";

const filePath = path.join(
  process.cwd(),
  "data",
  "metrics.json"
);
```

For module-relative resources:

```js
const fileUrl = new URL(
  "./data/metrics.json",
  import.meta.url
);
```

Then:

```js
import {
  readFile
} from "node:fs/promises";

const content = await readFile(
  fileUrl,
  "utf8"
);
```

Do not concatenate filesystem paths manually:

```js
const unsafePath =
  process.cwd() + "/" + userInput;
```

Validate user input and use safe path handling.

---

# F.33: Browser and Node.js Event APIs

## Browser EventTarget

```js
const controller = new AbortController();

window.addEventListener(
  "resize",
  handleResize,
  {
    signal: controller.signal
  }
);

controller.abort();
```

## Node.js EventEmitter

```js
import {
  EventEmitter
} from "node:events";

const emitter = new EventEmitter();

emitter.on("ready", handleReady);
emitter.emit("ready");
emitter.off("ready", handleReady);
```

They are conceptually similar but not identical.

| Feature | EventTarget | EventEmitter |
|---|---|---|
| Listener method | `addEventListener()` | `on()` |
| Remove method | `removeEventListener()` | `off()` / `removeListener()` |
| Event object | Standard event object | Arbitrary arguments |
| Abort signal option | Commonly supported | Not universally equivalent |
| Error behavior | Event-specific | Special `"error"` event |

---

# F.34: Node.js EventEmitter Error Events

An EventEmitter `"error"` event must be handled carefully.

```js
import {
  EventEmitter
} from "node:events";

const emitter = new EventEmitter();

emitter.on("error", (error) => {
  console.error("handled emitter error:", error);
});

emitter.emit(
  "error",
  new Error("stream failed")
);
```

Without an `"error"` listener, Node.js may treat the error as uncaught and terminate the process.

---

# F.35: Browser Unhandled Errors

Browsers provide global error events.

```js
window.addEventListener("error", (event) => {
  console.error("uncaught browser error:", event.error);
});
```

Unhandled promise rejections:

```js
window.addEventListener(
  "unhandledrejection",
  (event) => {
    console.error(
      "unhandled rejection:",
      event.reason
    );
  }
);
```

These are final safety nets, not replacements for local error handling.

---

# F.36: Node.js Unhandled Errors

Node.js provides process-level handlers:

```js
process.on(
  "unhandledRejection",
  (reason) => {
    console.error(
      "unhandled rejection:",
      reason
    );
  }
);

process.on(
  "uncaughtException",
  (error) => {
    console.error(
      "uncaught exception:",
      error
    );
  }
);
```

After an uncaught exception, continuing may be unsafe. Production services should normally:

1. Log the error.
2. Stop accepting new requests.
3. Close resources.
4. Exit.
5. Restart through a supervisor.

---

# F.37: Console Differences

Both environments provide `console.log()` and related methods, but output behavior differs.

## Browser Console

Browser developer tools may provide:

- Interactive object inspection.
- Source links.
- Styled output.
- Filtering.
- Performance timelines.

## Node.js Console

Node.js writes to stdout and stderr.

```js
console.log("stdout");
console.error("stderr");
```

When logging structured data, prefer:

```js
console.log({
  event: "request_completed",
  service: "metrics",
  durationMilliseconds: 42
});
```

For production, use a structured logger with redaction and log levels.

---

# F.38: Web Crypto and Node.js Crypto

## Browser Web Crypto

```js
const bytes = new Uint8Array(16);
crypto.getRandomValues(bytes);

console.log(bytes);
```

## Node.js Web Crypto

Modern Node.js versions expose Web Crypto through `globalThis.crypto` or `node:crypto` APIs depending on usage.

Node-specific cryptographic APIs include:

```js
import {
  randomBytes
} from "node:crypto";

console.log(randomBytes(16));
```

Do not use `Math.random()` for security-sensitive values in either environment.

---

# F.39: Browser Network Lifecycle

Browser requests can be affected by:

- User navigation.
- Page visibility.
- Network changes.
- Service workers.
- Browser suspension.
- Mobile operating-system policies.

Use cancellation:

```js
const controller = new AbortController();

fetch("/api/metrics", {
  signal: controller.signal
});

window.addEventListener(
  "pagehide",
  () => {
    controller.abort();
  },
  {
    once: true
  }
);
```

Do not assume a browser request will finish after the user leaves the page.

---

# F.40: Node.js Server Network Lifecycle

Node.js servers must handle:

- New connections.
- Active requests.
- Keep-alive sockets.
- Shutdown signals.
- Backpressure.
- Request timeouts.
- Dependency failures.

A server should not simply call:

```js
process.exit(0);
```

during ordinary shutdown because active cleanup may be skipped.

Prefer an orderly shutdown coordinator.

---

# F.41: Browser and Node.js Test Strategies

## Browser Tests

Browser-specific tests may need:

- A real browser.
- A DOM implementation.
- Browser automation.
- Visual verification.
- Network interception.
- User-event simulation.

## Node.js Tests

Node tests can directly test:

- Filesystem modules.
- Process behavior.
- Worker threads.
- HTTP servers.
- Streams.
- Retry and resilience logic.

## Shared Core Tests

Place portable logic in modules that require neither `window` nor `process`.

```text
src/shared/
├── selectors.js
├── validation.js
├── retry-policy.js
└── state-transitions.js
```

Then test them in Node.js.

---

# F.42: Portable Browser/Node.js API Design

## Avoid Direct Global Access at Module Load

Problem:

```js
const root = document.querySelector("#app");
```

This module cannot even be imported in Node.js.

Better:

```js
export function createView(root) {
  if (!root) {
    throw new TypeError("root is required");
  }

  return {
    render(state) {
      root.textContent = state.status;
    }
  };
}
```

The caller supplies the browser-specific element.

---

## Inject Environment-Specific Dependencies

```js
export function createFileBackedStore({
  readFile,
  writeFile
}) {
  return {
    async load(path) {
      return readFile(path, "utf8");
    },

    async save(path, data) {
      return writeFile(path, data, "utf8");
    }
  };
}
```

Node.js can provide filesystem functions. Tests can provide fakes. Browser code can use another storage adapter.

---

# F.43: Shared Application Architecture

A portable architecture can look like this:

```text
src/
├── shared/
│   ├── state/
│   ├── selectors/
│   ├── validation/
│   ├── retry/
│   └── domain/
├── browser/
│   ├── app.js
│   ├── dom-renderer.js
│   ├── browser-storage.js
│   └── browser-scheduler.js
└── node/
    ├── server.js
    ├── file-storage.js
    ├── process-signals.js
    └── node-scheduler.js
```

The shared layer contains business logic. Environment-specific layers adapt the host APIs.

---

# F.44: Environment-Neutral Storage Interface

## Implementation

### `src/shared/storage.js`

```js
"use strict";

export function createSettingsService({
  storage
}) {
  if (
    !storage ||
    typeof storage.get !== "function" ||
    typeof storage.set !== "function"
  ) {
    throw new TypeError(
      "storage must provide get and set functions"
    );
  }

  return Object.freeze({
    async getTheme() {
      return storage.get("theme") ?? "light";
    },

    async setTheme(theme) {
      if (!["light", "dark"].includes(theme)) {
        throw new RangeError(
          "theme must be light or dark"
        );
      }

      await storage.set("theme", theme);
    }
  });
}
```

### Browser Adapter

```js
"use strict";

export const browserStorage = {
  async get(key) {
    return localStorage.getItem(key);
  },

  async set(key, value) {
    localStorage.setItem(key, value);
  }
};
```

### Node.js Adapter

```js
"use strict";

const values = new Map();

export const memoryStorage = {
  async get(key) {
    return values.get(key);
  },

  async set(key, value) {
    values.set(key, value);
  }
};
```

The shared service does not know which environment provides storage.

---

# F.45: Browser and Node.js Runtime Checklist

Before sharing a module between browsers and Node.js, check:

## Global APIs

- Does it use `window`?
- Does it use `document`?
- Does it use `process`?
- Does it use `Buffer`?
- Does it use `global`?

## Modules

- Are import paths valid in both environments?
- Are file extensions required?
- Is the module bundled for browsers?
- Does the module import a Node-only built-in?

## Scheduling

- Does it depend on `requestAnimationFrame()`?
- Does it depend on `setImmediate()`?
- Does it use `process.nextTick()`?
- Could timers overlap?

## Storage and Files

- Does it use `localStorage`?
- Does it read from the filesystem?
- Is the path safe?
- Are secrets exposed to the browser?

## Networking

- Could CORS block browser requests?
- Does the client check `response.ok`?
- Are cookies and credentials handled correctly?
- Are timeouts and cancellation supported?

## Lifecycle

- What happens when the page is hidden?
- What happens when the process receives `SIGTERM`?
- Are listeners and timers removed?
- Are workers terminated?

---

# F.46: Runtime Portability Decision Table

| Requirement | Shared implementation? | Environment-specific adapter? |
|---|---:|---:|
| Pure validation | Yes | No |
| State reducer | Yes | No |
| Selector | Yes | No |
| DOM rendering | No | Browser |
| Filesystem access | No | Node.js |
| `localStorage` | No | Browser |
| Process signals | No | Node.js |
| Fetch request logic | Usually | Sometimes |
| Retry policy | Yes | No |
| Circuit breaker | Yes | No |
| Browser animation scheduling | No | Browser |
| CPU worker execution | Usually adapter | Both, different APIs |
| Logging abstraction | Interface shared | Implementation varies |
| Configuration loading | Interface shared | Environment-specific |

---

# F.47: Complete Portability Example

## Shared Domain Logic

### `src/shared/service-health.js`

```js
"use strict";

export function summarizeServices(services) {
  if (!Array.isArray(services)) {
    throw new TypeError(
      "services must be an array"
    );
  }

  return {
    total: services.length,

    healthy: services.filter(
      (service) => service.status === "healthy"
    ).length,

    unavailable: services.filter(
      (service) => service.status === "unavailable"
    ).length
  };
}
```

## Browser Entry Point

### `src/browser-entry.js`

```js
"use strict";

import {
  summarizeServices
} from "./shared/service-health.js";

const services = [
  {
    name: "metrics",
    status: "healthy"
  }
];

document.querySelector("#summary").textContent =
  JSON.stringify(
    summarizeServices(services)
  );
```

## Node.js Entry Point

### `src/node-entry.js`

```js
"use strict";

import {
  summarizeServices
} from "./shared/service-health.js";

const services = [
  {
    name: "metrics",
    status: "healthy"
  }
];

console.log(
  summarizeServices(services)
);
```

The domain logic is shared. Only the output boundary differs.

---

# F.48: Final Comparison

## Browser Strengths

Browsers provide:

- User-interface rendering.
- DOM events.
- Animation scheduling.
- User interaction.
- Web storage.
- Browser-managed networking.
- Web workers.
- Security isolation from the operating system.

## Node.js Strengths

Node.js provides:

- Filesystem access.
- Server networking.
- Process lifecycle control.
- Child processes.
- Worker threads.
- Streams.
- Operating-system integration.
- Long-running service execution.

## Shared Strengths

Both provide:

- JavaScript execution.
- Modules.
- Promises.
- Async functions.
- Timers.
- `AbortController`.
- `Proxy`.
- `Reflect`.
- Garbage collection.
- Web-standard APIs in modern versions.

---

# F.49: Final Runtime Selection Guide

Use a browser when the application needs:

- Rich interactive UI.
- Direct user input.
- Rendering.
- Animation.
- Browser storage.
- Device APIs.

Use Node.js when the application needs:

- Server endpoints.
- Filesystem operations.
- Process control.
- Background workers.
- Database connections.
- Long-running services.
- Server-side integration.

Use both when building a complete product:

```text
browser frontend
       │
       ▼
Node.js backend
       │
       ▼
databases and external services
```

---

# F.50: Final Portability Mental Model

Ask four questions when writing JavaScript intended for multiple environments:

```text
1. Is this a language feature or a host API?
2. Which runtime provides this global?
3. Can the dependency be injected behind an interface?
4. Does lifecycle behavior differ between browser and Node.js?
```

The most maintainable architecture is usually:

```text
portable domain logic
        │
        ├── browser adapters
        │     ├── DOM
        │     ├── rendering
        │     ├── browser storage
        │     └── page lifecycle
        │
        └── Node.js adapters
              ├── filesystem
              ├── process signals
              ├── server networking
              └── worker threads
```

The browser and Node.js are not competing versions of the same runtime. They are different hosts for the JavaScript language, each with different capabilities, scheduling behavior, security boundaries, and lifecycle responsibilities.
