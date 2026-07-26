# Primer 4: Web, HTTP, JSON, and API Fundamentals

This primer prepares you for the asynchronous API examples in the main series.

You will learn:

- How browsers and servers communicate.
- What URLs contain.
- What HTTP requests and responses are.
- HTTP methods.
- HTTP status codes.
- Request and response headers.
- JSON data.
- The Fetch API.
- Network failures.
- HTTP failures.
- Same-origin rules.
- CORS.
- HTTPS.
- Why API responses must be validated.

The goal is not to build a backend. The goal is to understand the language used when a browser requests data from another system.

---

# 1. Browser and Server Roles

## The Target

Understand the difference between a browser and a server.

## The Concept

A browser is the client. It asks for resources or data.

A server receives requests and sends responses.

A simple exchange looks like this:

```text
Browser
   │
   │ Request
   ▼
Server
   │
   │ Response
   ▼
Browser
```

For a web page:

```text
Browser requests index.html
        ↓
Server returns HTML
        ↓
Browser parses HTML
        ↓
Browser requests CSS and JavaScript
        ↓
Server returns CSS and JavaScript
        ↓
Browser renders the application
```

For an API request:

```text
Browser requests task data
        ↓
Server processes the request
        ↓
Server returns JSON
        ↓
JavaScript parses and uses the JSON
```

## The Implementation

Start your local server from the project directory:

```bash
python3 -m http.server 8000
```

Or on Windows:

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

Open Developer Tools and select the **Network** panel.

Refresh the page.

## The Verification

Find the request for:

```text
/
```

or:

```text
/index.html
```

Inspect it.

You should see:

- Request method: `GET`
- Status: usually `200`
- Response type: HTML
- Response body: your `index.html`

The browser requested the page. The server returned it.

[COMPLETED: Step 1 — Browser/server roles observed]  
[STARTING: Step 2 — Understand URLs]

---

# 2. URLs

## The Target

Understand the parts of a web address.

## The Concept

A URL identifies a resource.

Consider:

```text
https://api.example.com:443/tasks?status=active#details
```

Its components are:

```text
https://              Scheme
api.example.com      Host
:443                 Port
/tasks               Path
?status=active       Query string
#details             Fragment
```

### Scheme

The communication protocol:

```text
http
https
```

### Host

The server’s address:

```text
localhost
api.example.com
```

### Port

The numbered network entrance:

```text
8000
443
```

### Path

The requested resource:

```text
/tasks
/tasks/42
```

### Query String

Additional parameters:

```text
?status=active&limit=10
```

### Fragment

A location inside a document:

```text
#details
```

The fragment is generally handled by the browser and is not sent to the server in the HTTP request.

## The Implementation

Open the browser console and run:

```javascript
const url = new URL(
  "https://api.example.com:443/tasks?status=active&limit=10#details"
);

console.log(url.protocol);
console.log(url.hostname);
console.log(url.port);
console.log(url.pathname);
console.log(url.search);
console.log(url.hash);
```

## The Verification

Expected output:

```text
https:
api.example.com
443
/tasks
?status=active&limit=10
#details
```

Use `URL` and `URLSearchParams` instead of manually concatenating complex URLs.

[COMPLETED: Step 2 — URL components inspected]  
[STARTING: Step 3 — Understand HTTP requests]

---

# 3. HTTP Requests

## The Target

Understand what a browser sends to a server.

## The Concept

An HTTP request is a message from a client to a server.

A request can contain:

- A method.
- A URL.
- Headers.
- A body.

Conceptually:

```text
GET /tasks HTTP/1.1
Host: api.example.com
Accept: application/json
```

A request body is commonly used for methods such as:

```text
POST
PUT
PATCH
```

Example JSON request body:

```json
{
  "title": "Study HTTP"
}
```

## The Implementation

Use `fetch()` to create a request:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1"
);
```

The default method is:

```text
GET
```

Add headers:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1",
  {
    headers: {
      Accept: "application/json",
    },
  }
);
```

## The Verification

Open the Network panel before running the request.

Run this in the console:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1",
  {
    headers: {
      Accept: "application/json",
    },
  }
);

console.log(response);
```

Inspect the request in the Network panel.

Confirm:

- The request method is `GET`.
- The URL is correct.
- The request contains an `Accept` header.
- The response status is visible.

[COMPLETED: Step 3 — HTTP GET request inspected]  
[STARTING: Step 4 — Understand HTTP responses]

---

# 4. HTTP Responses

## The Target

Read the parts of an HTTP response.

## The Concept

A server response commonly contains:

- A status code.
- Headers.
- A body.

Conceptually:

```text
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "Study HTTP",
  "completed": false
}
```

The browser exposes response information through the `Response` object.

Important properties include:

```javascript
response.ok
response.status
response.statusText
response.headers
response.url
```

The response body is read asynchronously.

## The Implementation

Run:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1"
);

console.log("OK:", response.ok);
console.log("Status:", response.status);
console.log("Status text:", response.statusText);
console.log("URL:", response.url);

const data = await response.json();

console.log("Parsed data:", data);
```

## The Verification

Expected output should be similar to:

```text
OK: true
Status: 200
Status text: OK
Parsed data:
{
  userId: 1,
  id: 1,
  title: "...",
  completed: false
}
```

The exact response content may vary depending on the service.

[COMPLETED: Step 4 — HTTP response metadata and body read]  
[STARTING: Step 5 — Understand HTTP methods]

---

# 5. HTTP Methods

## The Target

Understand the common HTTP methods used by APIs.

## The Concept

An HTTP method describes the intended operation.

| Method | Typical purpose |
|---|---|
| `GET` | Read data |
| `POST` | Create data |
| `PUT` | Replace data |
| `PATCH` | Partially update data |
| `DELETE` | Delete data |

The method is a request instruction.

For example:

```text
GET /tasks
```

means:

> Return tasks.

```text
POST /tasks
```

means:

> Create a task.

## The Implementation

### GET

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1",
  {
    method: "GET",
  }
);
```

### POST

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos",
  {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({
      title: "Learn POST requests",
      completed: false,
      userId: 1,
    }),
  }
);

const data = await response.json();

console.log(data);
```

### PATCH

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1",
  {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({
      completed: true,
    }),
  }
);

const data = await response.json();

console.log(data);
```

### DELETE

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1",
  {
    method: "DELETE",
  }
);

console.log(response.status);
```

## The Verification

Open the Network panel and run each request.

Confirm:

- `GET` reads a resource.
- `POST` sends JSON.
- `PATCH` sends only changed fields.
- `DELETE` requests removal.

The demonstration service may simulate writes rather than permanently changing data. The important lesson is the request structure.

[COMPLETED: Step 5 — Common HTTP methods practiced]  
[STARTING: Step 6 — Understand HTTP status codes]

---

# 6. HTTP Status Codes

## The Target

Interpret response status codes.

## The Concept

Status codes communicate the result of a request.

They are grouped by the first digit:

```text
1xx — Informational
2xx — Success
3xx — Redirection
4xx — Client-side request problem
5xx — Server-side failure
```

Common codes:

| Status | Meaning |
|---|---|
| `200` | Successful request |
| `201` | Resource created |
| `204` | Success with no response body |
| `301` | Permanent redirect |
| `304` | Not modified |
| `400` | Bad request |
| `401` | Authentication required |
| `403` | Forbidden |
| `404` | Resource not found |
| `409` | Conflict |
| `422` | Validation failure |
| `429` | Too many requests |
| `500` | Internal server error |
| `502` | Bad gateway |
| `503` | Service unavailable |

## The Implementation

Create a reusable response checker:

```javascript
function assertSuccessfulResponse(response) {
  if (!response.ok) {
    throw new Error(
      `Request failed with HTTP ${response.status}.`
    );
  }
}
```

Use it:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1"
);

assertSuccessfulResponse(response);

const data = await response.json();

console.log(data);
```

## The Verification

Test a missing resource:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/999999"
);

console.log(response.status);
console.log(response.ok);
```

Depending on the service, you should see a failed status such as:

```text
404
false
```

Important: `fetch()` does not automatically reject for every HTTP error. You must inspect `response.ok`.

[COMPLETED: Step 6 — HTTP status handling implemented]  
[STARTING: Step 7 — Work with JSON]

---

# 7. JSON Data

## The Target

Convert between JavaScript values and JSON text.

## The Concept

JSON is a text format used to exchange structured data.

Example JSON:

```json
{
  "id": 1,
  "title": "Learn JSON",
  "completed": false
}
```

JSON supports:

- Objects.
- Arrays.
- Strings.
- Numbers.
- Booleans.
- `null`.

JSON does not directly preserve:

- Functions.
- Class methods.
- Prototypes.
- `Date` objects.
- `undefined`.

## The Implementation

Convert an object to JSON text:

```javascript
const task = {
  id: 1,
  title: "Learn JSON",
  completed: false,
};

const jsonText = JSON.stringify(task);

console.log(jsonText);
console.log(typeof jsonText);
```

Convert JSON text back to a JavaScript object:

```javascript
const parsedTask = JSON.parse(jsonText);

console.log(parsedTask);
console.log(parsedTask.title);
```

Format JSON for readability:

```javascript
const formattedJSON = JSON.stringify(
  task,
  null,
  2
);

console.log(formattedJSON);
```

## The Verification

Expected compact output:

```json
{"id":1,"title":"Learn JSON","completed":false}
```

Expected formatted output:

```json
{
  "id": 1,
  "title": "Learn JSON",
  "completed": false
}
```

Confirm:

```javascript
parsedTask.title === "Learn JSON";
```

The result should be:

```text
true
```

[COMPLETED: Step 7 — JSON serialization and parsing practiced]  
[STARTING: Step 8 — Handle invalid JSON]

---

# 8. Handle Invalid JSON

## The Target

Prevent malformed JSON from crashing the application.

## The Concept

`JSON.parse()` throws a `SyntaxError` when its input is not valid JSON.

External data should always be treated as untrusted.

## The Implementation

Create a safe parser:

```javascript
function parseJSONSafely(rawText) {
  try {
    return JSON.parse(rawText);
  } catch (error) {
    throw new Error(
      "The response did not contain valid JSON.",
      { cause: error }
    );
  }
}
```

Test valid JSON:

```javascript
const validValue = parseJSONSafely(
  '{"title":"Valid JSON"}'
);

console.log(validValue);
```

Test invalid JSON:

```javascript
try {
  parseJSONSafely("{invalid json");
} catch (error) {
  console.error(error.message);
  console.error("Original cause:", error.cause);
}
```

## The Verification

The valid value should print:

```javascript
{
  title: "Valid JSON"
}
```

The invalid value should produce:

```text
The response did not contain valid JSON.
```

The application should continue running after the error is handled.

[COMPLETED: Step 8 — Invalid JSON handling practiced]  
[STARTING: Step 9 — Validate response shapes]

---

# 9. Validate API Response Shapes

## The Target

Verify that parsed data has the structure the application expects.

## The Concept

Valid JSON is not necessarily valid application data.

This is valid JSON:

```json
{
  "message": "Unexpected response"
}
```

But it is not a valid task list if the application expects:

```json
[
  {
    "id": 1,
    "title": "Learn APIs",
    "completed": false
  }
]
```

Parsing answers:

> Is this text valid JSON?

Validation answers:

> Does the JSON contain the data shape our application requires?

## The Implementation

Create a task validator:

```javascript
function validateTaskRecord(value) {
  if (
    typeof value !== "object" ||
    value === null
  ) {
    throw new Error(
      "A task record must be an object."
    );
  }

  if (!Number.isInteger(value.id)) {
    throw new Error(
      "A task ID must be an integer."
    );
  }

  if (typeof value.title !== "string") {
    throw new Error(
      "A task title must be a string."
    );
  }

  if (typeof value.completed !== "boolean") {
    throw new Error(
      "A task completion state must be a Boolean."
    );
  }

  return value;
}
```

Validate an array:

```javascript
function validateTaskList(value) {
  if (!Array.isArray(value)) {
    throw new Error(
      "The API response must be an array."
    );
  }

  return value.map(validateTaskRecord);
}
```

## The Verification

Test valid data:

```javascript
const validTasks = validateTaskList([
  {
    id: 1,
    title: "Validate this task",
    completed: false,
  },
]);

console.log(validTasks);
```

Test invalid data:

```javascript
try {
  validateTaskList({
    tasks: [],
  });
} catch (error) {
  console.error(error.message);
}
```

Expected message:

```text
The API response must be an array.
```

Test an invalid record:

```javascript
try {
  validateTaskList([
    {
      id: "wrong",
      title: "Invalid task",
      completed: false,
    },
  ]);
} catch (error) {
  console.error(error.message);
}
```

[COMPLETED: Step 9 — API response validation introduced]  
[STARTING: Step 10 — Build a complete Fetch helper]

---

# 10. Build a Complete JSON Request Helper

## The Target

Create a reusable function for JSON API requests.

## The Concept

A request helper centralizes common behavior:

- Sending the request.
- Adding headers.
- Handling network errors.
- Checking HTTP status.
- Checking response content type.
- Parsing JSON.
- Producing consistent errors.

Without a helper, every API function may duplicate the same logic.

## The Implementation

Create:

### `api-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>API Helper Demo</title>
  </head>

  <body>
    <h1>Open the browser console</h1>

    <script type="module">
      async function requestJSON(
        url,
        {
          method = "GET",
          body,
          signal,
          headers = {},
        } = {}
      ) {
        let response;

        try {
          response = await fetch(url, {
            method,
            signal,
            headers: {
              Accept: "application/json",
              ...(
                body === undefined
                  ? {}
                  : {
                      "Content-Type":
                        "application/json",
                    }
              ),
              ...headers,
            },
            ...(body === undefined
              ? {}
              : {
                  body: JSON.stringify(body),
                }),
          });
        } catch (error) {
          if (error.name === "AbortError") {
            throw error;
          }

          throw new Error(
            "The network request could not be completed.",
            { cause: error }
          );
        }

        if (!response.ok) {
          throw new Error(
            `The server returned HTTP ${response.status}.`
          );
        }

        const contentType =
          response.headers.get("content-type") ?? "";

        if (!contentType.includes("application/json")) {
          throw new Error(
            "The server returned a non-JSON response."
          );
        }

        try {
          return await response.json();
        } catch (error) {
          throw new Error(
            "The server returned invalid JSON.",
            { cause: error }
          );
        }
      }

      try {
        const task = await requestJSON(
          "https://jsonplaceholder.typicode.com/todos/1"
        );

        console.log("Received task:", task);
      } catch (error) {
        console.error(
          "Request failed:",
          error.message
        );
      }
    </script>
  </body>
</html>
```

## The Verification

Serve the project:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000/api-demo.html
```

The console should show a JSON task object.

Inspect the Network panel and confirm:

- The request method is `GET`.
- The `Accept` header is present.
- The response has a successful status.
- The response is JSON.

Delete `api-demo.html` after testing.

[COMPLETED: Step 10 — Complete JSON request helper created]  
[STARTING: Step 11 — Use query parameters safely]

---

# 11. Query Parameters

## The Target

Construct URLs with encoded query parameters.

## The Concept

Query parameters communicate optional request details:

```text
/tasks?status=active&limit=10
```

Do not manually concatenate untrusted values:

```javascript
const url = `/tasks?search=${searchValue}`;
```

Special characters can change the meaning of the URL.

Use `URLSearchParams`.

## The Implementation

```javascript
const parameters = new URLSearchParams({
  search: "JavaScript & APIs",
  status: "active",
  limit: "10",
});

const url = `/tasks?${parameters.toString()}`;

console.log(url);
```

Use it with `fetch()`:

```javascript
const response = await fetch(
  `https://api.example.com/tasks?${parameters}`
);
```

## The Verification

Run:

```javascript
const parameters = new URLSearchParams({
  search: "JavaScript & APIs",
});

console.log(parameters.toString());
```

The result should encode the special characters:

```text
search=JavaScript+%26+APIs
```

The `&` inside the search value is encoded instead of being mistaken for another parameter.

[COMPLETED: Step 11 — Query parameters safely encoded]  
[STARTING: Step 12 — Understand network errors and HTTP errors]

---

# 12. Network Errors Versus HTTP Errors

## The Target

Distinguish connection failures from server responses.

## The Concept

A **network error** means the browser could not complete the request.

Possible causes:

- No network connection.
- DNS failure.
- Server unreachable.
- Request blocked by the browser.
- CORS failure.
- Request cancellation.

An **HTTP error** means the server responded, but the status indicates a problem:

```text
404
500
503
```

`fetch()` commonly rejects for network errors, but it does not automatically reject for every HTTP error.

## The Implementation

Use separate handling:

```javascript
async function loadTask() {
  let response;

  try {
    response = await fetch(
      "https://jsonplaceholder.typicode.com/todos/1"
    );
  } catch (error) {
    throw new Error(
      "The server could not be reached.",
      { cause: error }
    );
  }

  if (!response.ok) {
    throw new Error(
      `The server returned HTTP ${response.status}.`
    );
  }

  return response.json();
}
```

Consume it:

```javascript
try {
  const task = await loadTask();
  console.log(task);
} catch (error) {
  console.error(error.message);
}
```

## The Verification

Test a valid URL:

```javascript
await loadTask();
```

Test a missing resource by changing the URL:

```javascript
"https://jsonplaceholder.typicode.com/todos/999999"
```

Inspect:

- The status code.
- Whether `fetch()` itself rejected.
- Whether your `response.ok` check produced the error.

Then use Developer Tools to enable offline mode and test again.

[COMPLETED: Step 12 — Network and HTTP failures distinguished]  
[STARTING: Step 13 — Understand same-origin rules]

---

# 13. Same-Origin Policy

## The Target

Understand why browsers restrict some cross-origin requests.

## The Concept

An origin is generally:

```text
scheme + host + port
```

These are different origins:

```text
http://localhost:8000
http://localhost:3000
https://localhost:8000
http://127.0.0.1:8000
```

The browser’s same-origin policy prevents a page from freely reading data from every other origin.

This protects users from malicious pages silently reading private information from other sites.

## The Implementation

Inspect the current origin:

```javascript
console.log(location.origin);
```

Create URLs with different origins:

```javascript
const currentOrigin = location.origin;

const differentPort =
  "http://localhost:3000";

const differentScheme =
  "https://localhost:8000";

console.log(currentOrigin);
console.log(differentPort);
console.log(differentScheme);
```

## The Verification

Confirm that changing any of these can create a different origin:

- Scheme.
- Host.
- Port.

The local application at:

```text
http://localhost:8000
```

is not the same origin as:

```text
http://localhost:3000
```

[COMPLETED: Step 13 — Same-origin concepts understood]  
[STARTING: Step 14 — Understand CORS]

---

# 14. Cross-Origin Resource Sharing

## The Target

Understand CORS errors.

## The Concept

**CORS**, or Cross-Origin Resource Sharing, is a server-controlled mechanism that allows a browser page to read selected cross-origin responses.

If your page is served from:

```text
http://localhost:8000
```

and requests:

```text
https://api.example.com/tasks
```

the API server must provide appropriate CORS response headers.

A typical header is:

```http
Access-Control-Allow-Origin: http://localhost:8000
```

CORS is enforced by the browser. It is not fixed by adding a random request header in frontend code.

## The Implementation

Try a request from your local page:

```javascript
const response = await fetch(
  "https://api.example.com/tasks"
);
```

If the server is not configured to allow your origin, the browser may report a CORS error.

Do not attempt to fix it with:

```javascript
headers: {
  "Access-Control-Allow-Origin": "*"
}
```

That header belongs in the server’s response, not the browser’s request.

## The Verification

Use the Network and Console panels.

A CORS failure may show:

- A browser console CORS message.
- A blocked request.
- A missing `Access-Control-Allow-Origin` response header.
- A failed fetch Promise.

The correct fix is generally server configuration or using a same-origin backend proxy.

[COMPLETED: Step 14 — CORS behavior identified]  
[STARTING: Step 15 — Understand HTTPS]

---

# 15. HTTP and HTTPS

## The Target

Understand why production APIs should use HTTPS.

## The Concept

HTTPS encrypts communication between the browser and server.

Without HTTPS, network observers may read or modify data in transit.

Use:

```text
https://
```

for production pages and APIs.

Avoid:

```text
HTTPS page → HTTP API
```

This is mixed content and may be blocked by the browser.

Prefer:

```text
HTTPS page → HTTPS API
```

## The Implementation

Inspect the current page protocol:

```javascript
console.log(location.protocol);
```

Inspect an API URL:

```javascript
const apiURL = new URL(
  "https://api.example.com/tasks"
);

console.log(apiURL.protocol);
```

## The Verification

The production application should use:

```text
https:
```

for both the page and API.

Local development commonly uses:

```text
http://localhost:8000
```

because browsers treat `localhost` as a trusted development context for many APIs.

[COMPLETED: Step 15 — HTTPS and mixed-content concepts understood]  
[STARTING: Step 16 — Add timeout and cancellation concepts]

---

# 16. Request Timeouts and Cancellation

## The Target

Prevent requests from waiting indefinitely.

## The Concept

A request may become slow because:

- The network is unreliable.
- The server is overloaded.
- A connection is interrupted.
- The response is very large.

`AbortController` can cancel a request.

## The Implementation

Create:

### `request-cancellation.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>Request Cancellation</title>
  </head>

  <body>
    <button id="load-button" type="button">
      Start request
    </button>

    <button
      id="cancel-button"
      type="button"
      disabled
    >
      Cancel request
    </button>

    <p id="status">Ready.</p>

    <script type="module">
      const loadButton = document.querySelector(
        "#load-button"
      );

      const cancelButton = document.querySelector(
        "#cancel-button"
      );

      const status = document.querySelector(
        "#status"
      );

      let controller = null;

      async function loadTask() {
        controller = new AbortController();

        loadButton.disabled = true;
        cancelButton.disabled = false;
        status.textContent = "Loading...";

        try {
          const response = await fetch(
            "https://jsonplaceholder.typicode.com/todos/1",
            {
              signal: controller.signal,
            }
          );

          if (!response.ok) {
            throw new Error(
              `HTTP ${response.status}`
            );
          }

          const task = await response.json();

          status.textContent =
            `Loaded: ${task.title}`;
        } catch (error) {
          if (error.name === "AbortError") {
            status.textContent =
              "Request cancelled.";
            return;
          }

          status.textContent = error.message;
        } finally {
          controller = null;
          loadButton.disabled = false;
          cancelButton.disabled = true;
        }
      }

      loadButton.addEventListener("click", () => {
        loadTask();
      });

      cancelButton.addEventListener("click", () => {
        controller?.abort();
      });
    </script>
  </body>
</html>
```

## The Verification

1. Open the file through the local server.
2. Click **Start request**.
3. Click **Cancel request** quickly.
4. Confirm that:
   - The request is aborted.
   - The status says `Request cancelled.`
   - The buttons return to their normal state.

Delete the file after testing.

[COMPLETED: Step 16 — Request cancellation implemented]  
[STARTING: Step 17 — Use a local API fixture]

---

# 17. Use a Local JSON Fixture

## The Target

Load JSON from a file served by the local server.

## The Concept

A fixture is static data used during development or testing.

It behaves like a small fake API response without requiring a backend server.

## The Implementation

Create a directory:

### macOS/Linux

```bash
mkdir -p data
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path data
```

Create:

### `data/tasks.json`

```json
[
  {
    "id": 1,
    "title": "Read a local JSON fixture",
    "completed": false
  },
  {
    "id": 2,
    "title": "Validate an API-shaped response",
    "completed": true
  }
]
```

Create:

### `fixture-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>JSON Fixture Demo</title>
  </head>

  <body>
    <h1>Open the console</h1>

    <script type="module">
      async function loadFixture() {
        const response = await fetch(
          "./data/tasks.json"
        );

        if (!response.ok) {
          throw new Error(
            `Fixture request failed with HTTP ${response.status}.`
          );
        }

        return response.json();
      }

      try {
        const tasks = await loadFixture();
        console.table(tasks);
      } catch (error) {
        console.error(error);
      }
    </script>
  </body>
</html>
```

## The Verification

Open:

```text
http://localhost:8000/fixture-demo.html
```

The console should display two task records.

Inspect the Network panel and confirm:

```text
GET /data/tasks.json
```

Delete `fixture-demo.html` and the `data` directory after testing if they are not needed for the main project.

[COMPLETED: Step 17 — Local JSON fixture loaded through HTTP]  
[STARTING: Step 18 — Understand API design for the main series]

---

# 18. Design an API Module

## The Target

Understand the role of an API module in the final application.

## The Concept

The API module should hide transport details from the rest of the application.

The application coordinator should be able to write:

```javascript
const tasks = await fetchExampleTasks();
```

It should not need to know:

- Which URL was used.
- Which headers were added.
- How the response was parsed.
- How HTTP failures were handled.
- How records were validated.

This is separation of concerns.

## The Implementation

A production-style API module could look like:

### `js/api/task-api.js`

```javascript
"use strict";

import { Task } from "../models/task.js";

function validateApiTask(value) {
  if (
    typeof value !== "object" ||
    value === null ||
    !Number.isInteger(value.id) ||
    typeof value.title !== "string" ||
    typeof value.completed !== "boolean"
  ) {
    throw new Error(
      "The API returned an invalid task record."
    );
  }

  return new Task({
    id: value.id,
    title: value.title,
    completed: value.completed,
    createdAt: value.createdAt ?? new Date(),
  });
}

export async function fetchExampleTasks({
  endpoint = "./data/tasks.json",
  signal,
} = {}) {
  const response = await fetch(endpoint, {
    method: "GET",
    signal,
    headers: {
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(
      `Task API returned HTTP ${response.status}.`
    );
  }

  const responseData = await response.json();

  if (!Array.isArray(responseData)) {
    throw new Error(
      "Task API response must be an array."
    );
  }

  return responseData.map(validateApiTask);
}
```

## The Verification

Review the module and identify:

- Where the request begins.
- Where the HTTP status is checked.
- Where JSON is parsed.
- Where response data is validated.
- Where plain data becomes a `Task` instance.
- What the caller receives.

The caller receives:

```javascript
Task[]
```

rather than raw, unvalidated JSON.

[COMPLETED: Step 18 — API module boundary understood]  
[STARTING: Primer 4 Reference — Web and API quick reference]

---

# Web and API Quick Reference

## Browser Request

```javascript
const response = await fetch(url);
```

## Check HTTP Status

```javascript
if (!response.ok) {
  throw new Error(
    `HTTP ${response.status}`
  );
}
```

## Read JSON

```javascript
const data = await response.json();
```

## Send JSON

```javascript
const response = await fetch(url, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
  body: JSON.stringify(payload),
});
```

## Build Query Parameters

```javascript
const parameters = new URLSearchParams({
  search: "task",
  status: "active",
});

const url = `/tasks?${parameters}`;
```

## Catch Network Errors

```javascript
try {
  const response = await fetch(url);
} catch (error) {
  console.error(
    "Network request failed:",
    error
  );
}
```

## Cancel a Request

```javascript
const controller = new AbortController();

fetch(url, {
  signal: controller.signal,
});

controller.abort();
```

## Parse JSON Safely

```javascript
function parseJSONSafely(text) {
  try {
    return JSON.parse(text);
  } catch (error) {
    throw new Error(
      "Invalid JSON.",
      { cause: error }
    );
  }
}
```

## Validate a List

```javascript
if (!Array.isArray(value)) {
  throw new Error(
    "Expected an array."
  );
}
```

---

# Common API Mistakes

## Mistake 1: Assuming `fetch()` Rejects on HTTP Errors

Incorrect:

```javascript
const response = await fetch(url);
const data = await response.json();
```

Better:

```javascript
const response = await fetch(url);

if (!response.ok) {
  throw new Error(
    `HTTP ${response.status}`
  );
}

const data = await response.json();
```

## Mistake 2: Forgetting to Return the Promise

Incorrect:

```javascript
function loadTasks() {
  fetch("/tasks");
}
```

Better:

```javascript
function loadTasks() {
  return fetch("/tasks");
}
```

## Mistake 3: Forgetting to Parse JSON

Incorrect:

```javascript
const response = await fetch(url);
console.log(response.title);
```

Better:

```javascript
const response = await fetch(url);
const task = await response.json();

console.log(task.title);
```

## Mistake 4: Trusting the Response Shape

Incorrect:

```javascript
const tasks = await response.json();
tasks.map((task) => task.title);
```

Better:

```javascript
const tasks = await response.json();

if (!Array.isArray(tasks)) {
  throw new Error(
    "Expected a task array."
  );
}
```

## Mistake 5: Manually Concatenating Query Values

Incorrect:

```javascript
const url = `/tasks?search=${query}`;
```

Better:

```javascript
const parameters = new URLSearchParams({
  search: query,
});

const url = `/tasks?${parameters}`;
```

## Mistake 6: Trying to Fix CORS in Frontend Headers

Incorrect:

```javascript
headers: {
  "Access-Control-Allow-Origin": "*"
}
```

CORS permission is normally provided by the server response.

## Mistake 7: Sending Secrets to the Browser

Never place private credentials in frontend JavaScript. Anything delivered to the browser can be inspected.

---

# Primer 4 Completion Checklist

Before beginning Part 0, confirm that you can:

- [ ] Explain the difference between a browser and a server.
- [ ] Identify the parts of a URL.
- [ ] Explain an HTTP request.
- [ ] Explain an HTTP response.
- [ ] Use `fetch()` for a GET request.
- [ ] Send JSON with a POST request.
- [ ] Read JSON with `response.json()`.
- [ ] Serialize data with `JSON.stringify()`.
- [ ] Parse data with `JSON.parse()`.
- [ ] Check `response.ok`.
- [ ] Interpret common HTTP status codes.
- [ ] Distinguish network failures from HTTP failures.
- [ ] Validate an API response shape.
- [ ] Build query parameters with `URLSearchParams`.
- [ ] Explain same-origin policy.
- [ ] Explain the purpose of CORS.
- [ ] Explain why production uses HTTPS.
- [ ] Cancel a request with `AbortController`.
- [ ] Load a local JSON fixture.
- [ ] Explain the responsibility of an API module.
- [ ] Avoid trusting raw external data.
- [ ] Avoid putting secrets in browser code.
