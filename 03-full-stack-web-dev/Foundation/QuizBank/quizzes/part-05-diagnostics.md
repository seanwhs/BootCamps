# Part 5 Quiz — Network Inspection and Diagnostic Workflows  
## DevTools, cURL, API Clients, Timing, CORS, Authentication, Caching, and Troubleshooting

This quiz reviews:

- Browser Developer Tools
- Console and Network panels
- Request filtering
- Request and response inspection
- Headers and payloads
- Status codes
- Timing breakdowns
- DNS, connection, TLS, TTFB, and download time
- Waterfall analysis
- Initiators
- cURL
- Postman and Bruno
- CORS
- Authentication debugging
- Redirects
- Caching
- Service workers
- Environment mismatches
- Network errors versus HTTP errors
- Systematic troubleshooting

---

## Instructions

- Complete the quiz before reading the answer key.
- Explain your reasoning for scenario questions.
- Use only systems you own or are authorized to test.
- Redact cookies, tokens, passwords, API keys, and personal data before sharing requests.
- Do not replay destructive requests such as payments, deletions, or order creation without understanding the consequences.
- Some diagnostic situations may have multiple possible causes.

---

## Learning Objectives

After completing this quiz, you should be able to:

- Explain the purpose of browser Developer Tools.
- Use the Console and Network panels together.
- Filter and inspect requests.
- Analyze URLs, methods, headers, payloads, responses, and timing.
- Distinguish frontend, browser, network, backend, database, and dependency failures.
- Use cURL to reproduce requests.
- Explain the differences between browser requests and cURL requests.
- Diagnose common `401`, `403`, `404`, `422`, and `5xx` problems.
- Investigate CORS and authentication failures.
- Diagnose redirects and stale cache behavior.
- Understand service workers and browser storage.
- Use a layered troubleshooting workflow.
- Identify useful evidence before changing code.

---

# Part 1 — Multiple-Choice Quiz

Choose the best answer.

## Question 1

What is the primary purpose of the browser Network panel?

- [ ] To edit database tables
- [ ] To inspect requests and responses made by the browser
- [ ] To change operating-system permissions
- [ ] To compile backend code

---

## Question 2

What is the primary purpose of the browser Console?

- [ ] To display JavaScript messages, errors, and warnings
- [ ] To replace the DNS system
- [ ] To store database records
- [ ] To configure a CDN

---

## Question 3

Why should the Console and Network panels often be used together?

- [ ] They provide frontend execution evidence and HTTP/network evidence.
- [ ] They are both database management tools.
- [ ] They automatically fix every error.
- [ ] They are required only for CSS.

---

## Question 4

What does “Preserve log” help with?

- [ ] Keeping requests and messages visible across navigation
- [ ] Encrypting browser traffic
- [ ] Deleting all cache data
- [ ] Increasing CPU speed

---

## Question 5

What does “Disable cache” usually do in Developer Tools?

- [ ] Prevents caching while testing with Developer Tools open
- [ ] Deletes all server-side caches permanently
- [ ] Disables DNS
- [ ] Prevents the application from making requests

---

## Question 6

Which Network filter is commonly useful for API requests?

- [ ] Fetch/XHR
- [ ] Fonts only
- [ ] Images only
- [ ] Documents only

---

## Question 7

Which information is commonly available when inspecting a request?

- [ ] URL
- [ ] Method
- [ ] Headers
- [ ] All of the above

---

## Question 8

What should you inspect to determine what data a `POST` request sent?

- [ ] Request payload
- [ ] Browser theme
- [ ] DNS root server
- [ ] CSS box model only

---

## Question 9

What should you inspect to determine whether a response is JSON?

- [ ] `Content-Type` and response body
- [ ] Screen brightness
- [ ] Keyboard layout
- [ ] Filesystem permissions only

---

## Question 10

What does the request initiator show?

- [ ] What caused the request
- [ ] The server’s database password
- [ ] The user’s operating system license
- [ ] The DNS root zone

---

## Question 11

What does the Network waterfall show?

- [ ] Timing and overlap of requests
- [ ] Only database schemas
- [ ] User passwords
- [ ] Source-control branches

---

## Question 12

What is TTFB?

- [ ] Time to First Byte
- [ ] Total Transfer File Backup
- [ ] TLS Transfer Format Boundary
- [ ] Terminal File Transfer Buffer

---

## Question 13

High TTFB may indicate:

- [ ] Slow backend processing or database work
- [ ] Only a CSS color problem
- [ ] A missing keyboard
- [ ] A browser bookmark

---

## Question 14

A long content-download phase may indicate:

- [ ] A large response or slow transfer
- [ ] The server has no route
- [ ] The user is unauthorized
- [ ] The request method is always wrong

---

## Question 15

What does cURL allow you to do?

- [ ] Make and inspect network requests from a terminal
- [ ] Edit a browser’s DOM only
- [ ] Replace a database
- [ ] Design CSS layouts

---

## Question 16

What does `curl -i` usually do?

- [ ] Includes response headers in the output
- [ ] Follows every redirect automatically
- [ ] Deletes the response body
- [ ] Disables TLS verification

---

## Question 17

What does `curl -v` usually do?

- [ ] Shows verbose connection and protocol details
- [ ] Compresses every database table
- [ ] Opens a browser window
- [ ] Removes cookies

---

## Question 18

What does “Copy as cURL” in Developer Tools help with?

- [ ] Reproducing a browser request in a terminal
- [ ] Copying a CSS selector only
- [ ] Exporting a database
- [ ] Creating a DNS record

---

## Question 19

If no request appears in the Network panel after a button click, what is the most likely starting area of investigation?

- [ ] Frontend event handling or JavaScript execution
- [ ] The remote database only
- [ ] CDN cache invalidation only
- [ ] TLS certificate renewal only

---

## Question 20

A request returns `401 Unauthorized`. What should you inspect first?

- [ ] Authentication credentials, cookies, and tokens
- [ ] CSS grid columns
- [ ] Image dimensions
- [ ] Browser font settings

---

## Question 21

A request returns `403 Forbidden`. What does this usually indicate?

- [ ] The caller lacks permission
- [ ] DNS failed
- [ ] The response was cached
- [ ] The browser cannot parse HTML

---

## Question 22

A request returns `404 Not Found`. What should you inspect?

- [ ] URL, method, route, resource identifier, and environment
- [ ] Only the user’s screen resolution
- [ ] Only the TLS cipher
- [ ] Only the CPU temperature

---

## Question 23

A request returns `422 Unprocessable Content`. What does this commonly indicate?

- [ ] The request values failed validation or business rules
- [ ] The domain could not resolve
- [ ] The server has permanently moved
- [ ] The request was necessarily successful

---

## Question 24

A request returns `500 Internal Server Error`. Where should you investigate?

- [ ] Backend logs, database, dependencies, configuration, and recent deployments
- [ ] Only the browser’s color scheme
- [ ] Only the URL fragment
- [ ] Only the client’s mouse

---

## Question 25

What is CORS?

- [ ] A browser-enforced cross-origin access-control mechanism
- [ ] A database backup format
- [ ] A CPU scheduling algorithm
- [ ] A CSS layout mode

---

## Question 26

What request commonly appears as a CORS preflight?

- [ ] `OPTIONS`
- [ ] `PATCH` only
- [ ] `HEAD` only
- [ ] `TRACE` only

---

## Question 27

Why might cURL succeed while browser JavaScript fails with CORS?

- [ ] cURL does not enforce browser CORS response-access rules.
- [ ] cURL cannot send HTTP requests.
- [ ] Browsers cannot use HTTPS.
- [ ] The server necessarily returned different data.

---

## Question 28

What is a service worker capable of doing?

- [ ] Intercepting requests and serving cached responses
- [ ] Replacing the operating system
- [ ] Changing DNS globally
- [ ] Rewriting database schemas automatically

---

## Question 29

What can cause stale content in a browser?

- [ ] Browser cache
- [ ] CDN cache
- [ ] Service worker cache
- [ ] All of the above

---

## Question 30

What should you do before sharing a copied browser request?

- [ ] Redact cookies, tokens, API keys, and personal data
- [ ] Publish all headers unchanged
- [ ] Add your password to make it reproducible
- [ ] Disable HTTPS

---

## Question 31

What does `curl -L` do?

- [ ] Follows redirects
- [ ] Lists local files
- [ ] Disables authentication
- [ ] Clears browser storage

---

## Question 32

What is a network error?

- [ ] A failure to receive a usable HTTP response
- [ ] Any response with status `404`
- [ ] A successful JSON response
- [ ] A CSS warning only

---

## Question 33

What is an HTTP error?

- [ ] A valid HTTP response with a status indicating a problem
- [ ] A DNS lookup that never starts
- [ ] A laptop battery warning
- [ ] A missing source file only

---

## Question 34

Which tool is useful for testing an API independently of a frontend?

- [ ] cURL
- [ ] Postman
- [ ] Bruno
- [ ] All of the above

---

## Question 35

What can environment mismatch cause?

- [ ] The frontend may call the wrong API or use different credentials and data.
- [ ] It always improves performance.
- [ ] It removes the need for DNS.
- [ ] It guarantees identical behavior.

---

## Question 36

What does network throttling help you test?

- [ ] Loading, timeout, retry, and slow-network behavior
- [ ] Database schema naming only
- [ ] Git commit history
- [ ] File ownership only

---

## Question 37

What does offline testing help reveal?

- [ ] How the application behaves when network requests fail
- [ ] Whether all server code is correct
- [ ] Whether a DNS record is permanent
- [ ] Whether a database has no tables

---

## Question 38

What is a HAR file?

- [ ] An archive of recorded HTTP activity
- [ ] A password hash
- [ ] A database migration
- [ ] A Linux process

---

## Question 39

What should you inspect first when a response is unexpectedly HTML?

- [ ] URL, redirect chain, status, `Content-Type`, and response body
- [ ] Only the CSS file
- [ ] Only the screen size
- [ ] Only the CPU usage

---

## Question 40

What is the most reliable general troubleshooting approach?

- [ ] Observe the request and response, identify the failing layer, then change code
- [ ] Change multiple unrelated files immediately
- [ ] Guess based only on the visible symptom
- [ ] Restart every system without collecting evidence

---

# Part 2 — True or False

## Question 41

The Network panel can show requests for HTML, JavaScript, CSS, images, fonts, and APIs.

- [ ] True
- [ ] False

---

## Question 42

A `200 OK` response guarantees that the frontend will display the expected data.

- [ ] True
- [ ] False

---

## Question 43

A request may succeed at the HTTP level while the business operation fails.

- [ ] True
- [ ] False

---

## Question 44

If no request appears in the Network panel, the request definitely reached the backend.

- [ ] True
- [ ] False

---

## Question 45

Preserve log is useful for debugging redirects and navigation flows.

- [ ] True
- [ ] False

---

## Question 46

The request payload shows data sent in the request body.

- [ ] True
- [ ] False

---

## Question 47

The response body can reveal that a supposedly JSON response is actually HTML.

- [ ] True
- [ ] False

---

## Question 48

High TTFB can indicate slow backend or database work.

- [ ] True
- [ ] False

---

## Question 49

A long download phase always indicates slow database processing.

- [ ] True
- [ ] False

---

## Question 50

The initiator can help identify which script or resource caused a request.

- [ ] True
- [ ] False

---

## Question 51

A browser may block JavaScript from reading a response even if the server received the request.

- [ ] True
- [ ] False

---

## Question 52

CORS is a replacement for server-side authorization.

- [ ] True
- [ ] False

---

## Question 53

cURL normally enforces browser CORS restrictions.

- [ ] True
- [ ] False

---

## Question 54

A service worker can cause old content to be served from cache.

- [ ] True
- [ ] False

---

## Question 55

A `401` usually concerns authentication.

- [ ] True
- [ ] False

---

## Question 56

A `403` usually concerns authorization or permission.

- [ ] True
- [ ] False

---

## Question 57

A `404` necessarily means the Internet connection is broken.

- [ ] True
- [ ] False

---

## Question 58

A `500` response usually warrants server-side investigation.

- [ ] True
- [ ] False

---

## Question 59

Copied requests may contain sensitive credentials.

- [ ] True
- [ ] False

---

## Question 60

Disabling browser cache changes the behavior being observed.

- [ ] True
- [ ] False

---

# Part 3 — Short-Answer Quiz

Answer in complete sentences.

## Question 61

What is the purpose of the browser Network panel?

---

## Question 62

What is the purpose of the browser Console?

---

## Question 63

Why should the Console and Network panels be used together?

---

## Question 64

What does Preserve log help with?

---

## Question 65

What does Disable cache help test?

---

## Question 66

What information should you inspect in a request?

---

## Question 67

What information should you inspect in a response?

---

## Question 68

What is a request payload?

---

## Question 69

What is a response body?

---

## Question 70

What is an initiator?

---

## Question 71

What does the Network waterfall show?

---

## Question 72

What is DNS timing?

---

## Question 73

What is connection timing?

---

## Question 74

What is TLS timing?

---

## Question 75

What is TTFB?

---

## Question 76

What does a long content-download time suggest?

---

## Question 77

Why is copying a request as cURL useful?

---

## Question 78

What is the difference between a network error and an HTTP error?

---

## Question 79

What should you inspect when a request returns `401`?

---

## Question 80

What should you inspect when a request returns `403`?

---

## Question 81

What should you inspect when a request returns `404`?

---

## Question 82

What should you inspect when a request returns `500`?

---

## Question 83

What is CORS?

---

## Question 84

What is a CORS preflight request?

---

## Question 85

Why might a service worker affect debugging?

---

# Part 4 — Request Inspection Quiz

## Question 86

A request appears as:

```text
Name: /api/products
Method: GET
Status: 200
Type: fetch
```

What does this tell you?

---

## Question 87

A request appears as:

```text
POST /api/orders
Content-Type: application/json
```

Where would you inspect the order data sent by the browser?

---

## Question 88

The request contains:

```http
Authorization: Bearer REDACTED
Cookie: session_id=REDACTED
```

What does this suggest?

---

## Question 89

The response contains:

```http
Content-Type: text/html
```

but the frontend expects JSON.

What should you inspect?

---

## Question 90

The response contains:

```http
Content-Type: application/json
```

but the body is:

```html
<h1>Server Error</h1>
```

What does this indicate?

---

## Question 91

The response contains:

```http
Location: /login
```

What does this suggest?

---

## Question 92

The response contains:

```http
Cache-Control: max-age=3600
ETag: "products-v5"
```

What behavior might occur later?

---

## Question 93

A response contains:

```http
Access-Control-Allow-Origin: https://app.example.com
```

What does this header communicate to a browser?

---

## Question 94

The request contains:

```http
Origin: https://app.example.com
```

What does this identify?

---

## Question 95

A request has:

```text
Low TTFB
Large response size
Long content download
```

What is a likely performance issue?

---

# Part 5 — Scenario Quiz

## Question 96 — Button Does Nothing

A user clicks “Load Products.” Nothing changes. No request appears in the Network panel.

What should you investigate?

---

## Question 97 — JavaScript Error Before Request

The Console shows:

```text
TypeError: Cannot read properties of undefined
```

No API request appears.

What is the likely failure layer?

---

## Question 98 — Request Returns `401`

A browser request returns:

```http
401 Unauthorized
```

What should you inspect?

---

## Question 99 — Request Returns `403`

A logged-in user cannot access an administrator endpoint.

What does this likely mean?

---

## Question 100 — Request Returns `404`

The request URL is:

```text
/api/order/123
```

The backend documentation says:

```text
/api/orders/123
```

What is likely wrong?

---

## Question 101 — Request Returns `422`

The request body is:

```json
{
  "quantity": -1
}
```

What should the frontend and backend do?

---

## Question 102 — Request Returns `500`

The browser receives:

```http
500 Internal Server Error
```

What evidence should you collect before changing frontend code?

---

## Question 103 — Browser Shows HTML

The frontend expects JSON, but the response is an HTML login page.

What could have happened?

---

## Question 104 — CORS Error

The browser Console reports a CORS error. cURL receives the response successfully.

What explains the difference?

---

## Question 105 — Redirect Loop

The browser repeatedly redirects between:

```text
/account
/login
```

What might cause this?

---

## Question 106 — Stale Content

A developer changes a JavaScript file, but the browser continues running the old version.

What layers could be caching the old content?

---

## Question 107 — Service Worker

The server returns the new response using cURL, but the browser still displays old data.

What should you inspect?

---

## Question 108 — Slow First Request

The first request to a domain is slow, but later requests are much faster.

What could explain the difference?

---

## Question 109 — High TTFB

A request has low DNS, connection, and TLS timing but very high TTFB.

What should you investigate?

---

## Question 110 — Slow Download

A request has low TTFB but takes several seconds to download.

What could cause this?

---

## Question 111 — Repeated Requests

The same API request appears repeatedly after one page load.

What could cause this?

---

## Question 112 — Search Race Condition

A user types quickly. The older search response arrives after the newer response and overwrites the results.

How could this be addressed?

---

## Question 113 — Duplicate Form Submission

A user double-clicks “Place Order,” and two orders are created.

What frontend and backend protections could help?

---

## Question 114 — Environment Mismatch

The frontend works locally but calls a staging API in a production build.

What should you inspect?

---

## Question 115 — Failed cURL Reproduction

A request copied from the browser works in the browser but fails in cURL.

What should you compare?

---

## Question 116 — Authentication Cookie Missing

The login response appears successful, but later requests contain no session cookie.

What should you inspect?

---

## Question 117 — Network Failure

A request appears in Network but has no HTTP status and shows `(failed)`.

What layers might be involved?

---

## Question 118 — Redirected API Response

An API request returns a login page after several redirects.

What might the frontend be doing incorrectly?

---

## Question 119 — Large Payload

An API returns thousands of records when the page displays only ten.

What performance improvements could help?

---

## Question 120 — Production `503`

Many users receive:

```http
503 Service Unavailable
```

What production systems should you investigate?

---

# Part 6 — Practical Diagnostic Exercises

Use systems you own or are authorized to inspect.

## Exercise 1 — Inspect a Page Load

1. Open Developer Tools.
2. Select Network.
3. Enable Preserve log.
4. Reload a page.
5. Filter by:
   - Document
   - Fetch/XHR
   - JS
   - CSS
   - Img
6. Identify:
   - Main document
   - JavaScript bundles
   - API requests
   - Images
   - Fonts

Record:

```text
Number of requests:
Largest request:
Slowest request:
Any failed request:
```

---

## Exercise 2 — Inspect an API Request

Find a Fetch/XHR request and record:

```text
Request URL
Method
Query parameters
Request headers
Request payload
Status code
Response headers
Response body
Timing
Initiator
```

Redact credentials before saving notes.

---

## Exercise 3 — Copy as cURL

1. Select a request.
2. Choose **Copy as cURL**.
3. Redact:
   - Cookies
   - Authorization
   - API keys
   - Personal data
4. Run the command.
5. Compare:
   - Status
   - Response body
   - Timing
   - Headers

---

## Exercise 4 — Test Caching

1. Load a static resource.
2. Inspect response headers.
3. Reload the page.
4. Compare:
   - Request status
   - `Cache-Control`
   - `ETag`
   - Transfer size
   - Timing
5. Disable cache and test again.

---

## Exercise 5 — Test Slow Network Behavior

Use Network throttling to simulate a slow connection.

Observe:

```text
Loading indicators
Timeouts
Retry behavior
User interaction
Image loading
API timing
Error states
```

---

## Exercise 6 — Inspect Storage

Open the Application or Storage panel.

Inspect:

```text
Cookies
Local Storage
Session Storage
Cache Storage
Service Workers
```

Record:

```text
Which values are stored?
Which are sent automatically?
Which are accessible to JavaScript?
Which values appear sensitive?
```

Do not copy or share real credentials.

---

# Answer Key

# Part 1 — Multiple-Choice Answers

| Question | Answer | Explanation |
|---:|---|---|
| 1 | To inspect requests and responses made by the browser | The Network panel displays HTTP and resource traffic. |
| 2 | To display JavaScript messages, errors, and warnings | The Console provides frontend execution evidence. |
| 3 | They provide frontend execution evidence and HTTP/network evidence. | Together they help locate the failing layer. |
| 4 | Keeping requests and messages visible across navigation | This helps with redirects and page transitions. |
| 5 | Prevents caching while testing with Developer Tools open | It helps test fresh resource behavior. |
| 6 | Fetch/XHR | API requests commonly appear there. |
| 7 | All of the above | Requests expose URL, method, headers, and more. |
| 8 | Request payload | The payload contains request-body data. |
| 9 | `Content-Type` and response body | These reveal the format and actual content. |
| 10 | What caused the request | The initiator may be a script, document, or user action. |
| 11 | Timing and overlap of requests | Waterfalls show request timing. |
| 12 | Time to First Byte | TTFB measures delay before the first response byte. |
| 13 | Slow backend processing or database work | High TTFB indicates delay before response data begins. |
| 14 | A large response or slow transfer | Download time occurs after the first byte arrives. |
| 15 | Make and inspect network requests from a terminal | cURL is useful for API testing. |
| 16 | Includes response headers in the output | `-i` includes headers and body. |
| 17 | Shows verbose connection and protocol details | `-v` displays diagnostic information. |
| 18 | Reproducing a browser request in a terminal | This helps isolate browser-specific problems. |
| 19 | Frontend event handling or JavaScript execution | No request means failure likely occurred before network transmission. |
| 20 | Authentication credentials, cookies, and tokens | `401` usually indicates an identity problem. |
| 21 | The caller lacks permission | `403` usually indicates authorization failure. |
| 22 | URL, method, route, resource identifier, and environment | These commonly cause `404`. |
| 23 | The request values failed validation or business rules | `422` commonly represents semantic validation failure. |
| 24 | Backend logs, database, dependencies, configuration, and recent deployments | `500` is a server-side failure. |
| 25 | A browser-enforced cross-origin access-control mechanism | CORS controls browser access to cross-origin responses. |
| 26 | `OPTIONS` | Browsers commonly use `OPTIONS` for preflight. |
| 27 | cURL does not enforce browser CORS response-access rules. | cURL can read responses that browser JavaScript cannot. |
| 28 | Intercepting requests and serving cached responses | Service workers can control request behavior. |
| 29 | All of the above | Multiple cache layers can serve stale content. |
| 30 | Redact cookies, tokens, API keys, and personal data | Copied requests may contain sensitive values. |
| 31 | Follows redirects | `-L` follows `Location` headers. |
| 32 | A failure to receive a usable HTTP response | Network errors differ from HTTP status errors. |
| 33 | A valid HTTP response with a status indicating a problem | Examples include `404` and `500`. |
| 34 | All of the above | cURL, Postman, and Bruno can test APIs independently. |
| 35 | The frontend may call the wrong API or use different credentials and data. | Environment configuration affects behavior. |
| 36 | Loading, timeout, retry, and slow-network behavior | Throttling simulates constrained conditions. |
| 37 | How the application behaves when network requests fail | Offline mode tests failure handling. |
| 38 | An archive of recorded HTTP activity | HAR files store network evidence. |
| 39 | URL, redirect chain, status, `Content-Type`, and response body | These reveal why HTML was returned. |
| 40 | Observe the request and response, identify the failing layer, then change code | Evidence-based debugging is more reliable than guessing. |

---

# Part 2 — True-or-False Answers

| Question | Answer | Explanation |
|---:|---|---|
| 41 | True | The Network panel records many resource types. |
| 42 | False | The response may have an unexpected body or frontend parsing problem. |
| 43 | True | Transport success does not guarantee business success. |
| 44 | False | No request means it may not have been created or captured; it does not prove backend receipt. |
| 45 | True | Preserve log retains entries through navigation. |
| 46 | True | The payload shows request-body data. |
| 47 | True | The response body may reveal unexpected HTML. |
| 48 | True | Backend or database processing can delay the first byte. |
| 49 | False | Long download time may indicate payload size, bandwidth, or compression issues. |
| 50 | True | The initiator identifies the source of the request. |
| 51 | True | Browser policy may prevent JavaScript from reading a response. |
| 52 | False | CORS does not replace server-side authorization. |
| 53 | False | cURL generally does not enforce browser CORS restrictions. |
| 54 | True | A service worker may serve old cached data. |
| 55 | True | `401` usually concerns authentication. |
| 56 | True | `403` usually concerns authorization. |
| 57 | False | A `404` is a valid HTTP response and usually indicates a missing route or resource. |
| 58 | True | `500` requires backend or dependency investigation. |
| 59 | True | Requests may contain cookies, tokens, and other private data. |
| 60 | True | Disabling cache changes observed browser behavior. |

---

# Part 3 — Short-Answer Model Answers

## Question 61

The Network panel records resources and HTTP requests made by the browser. It shows URLs, methods, headers, payloads, responses, statuses, sizes, initiators, and timing.

---

## Question 62

The Console displays JavaScript logs, exceptions, warnings, browser policy errors, CORS messages, and other diagnostic information.

---

## Question 63

The Console shows what frontend code and browser policies did. The Network panel shows what requests and responses occurred. Together they help distinguish frontend failures from network, API, and server failures.

---

## Question 64

Preserve log keeps Console and Network entries across navigation and reloads. It is useful for redirects, login flows, form submissions, and page transitions.

---

## Question 65

Disable cache helps test whether resources are being served freshly from the network rather than from browser cache. It is useful for debugging stale assets and cache behavior.

---

## Question 66

Inspect:

```text
Request URL
HTTP method
Query parameters
Headers
Cookies
Authorization
Request payload
Origin
Initiator
```

---

## Question 67

Inspect:

```text
Status code
Response headers
Content-Type
Response body
Cookies
Cache headers
Redirect location
Timing
```

---

## Question 68

A request payload is the data sent in the request body, such as JSON, form fields, or uploaded file data.

---

## Question 69

A response body is the data returned by the server, such as JSON, HTML, text, images, or other binary data.

---

## Question 70

An initiator identifies what caused a request, such as a document, script, stylesheet, user action, or another request.

---

## Question 71

The waterfall displays when requests start, wait, connect, receive data, and complete. It helps reveal serial requests, long delays, large downloads, and slow dependencies.

---

## Question 72

DNS timing measures the time required to resolve the request hostname into an address.

---

## Question 73

Connection timing measures the time required to establish a network connection to the destination.

---

## Question 74

TLS timing measures the time required to negotiate the secure HTTPS connection after the network connection is established.

---

## Question 75

TTFB means Time to First Byte. It measures approximately how long it takes before the client receives the first response byte.

---

## Question 76

Long content-download time may indicate:

```text
Large response
Slow network
Missing compression
Large images or files
Slow streaming
```

---

## Question 77

Copying as cURL allows you to reproduce the exact browser request outside the browser. This helps separate frontend or browser-policy problems from backend or API problems.

---

## Question 78

A network error means a usable HTTP response was not received. An HTTP error means a valid HTTP response arrived with a status such as `400`, `404`, or `500`.

---

## Question 79

Inspect:

```text
Cookies
Authorization header
Token expiration
Login response
Cookie domain and path
Secure and SameSite attributes
Correct environment
```

---

## Question 80

Inspect:

```text
User role
Resource ownership
Organization membership
Subscription
Account status
Backend authorization rules
```

---

## Question 81

Inspect:

```text
Request URL
Method
Path spelling
Path parameter
API version
Environment
Whether the resource exists
```

---

## Question 82

Inspect:

```text
Response body
Request ID
Server logs
Database logs
External dependency logs
Recent deployments
Configuration
```

---

## Question 83

CORS is a browser-enforced mechanism controlling whether frontend JavaScript can read responses from another origin.

---

## Question 84

A CORS preflight is usually an `OPTIONS` request that asks whether a cross-origin request’s method and headers are allowed.

---

## Question 85

A service worker may intercept requests and return cached responses. It can therefore cause old content to appear even when the origin server has newer data.

---

# Part 4 — Request Inspection Answers

## Question 86

The browser made a `GET` Fetch request to `/api/products`. It received an HTTP `200` response. This suggests the HTTP operation succeeded, but the response body and frontend rendering still need inspection.

---

## Question 87

Inspect the **Payload** or **Request Payload** section of the Network request.

---

## Question 88

The request includes both bearer-token and cookie-based authentication information. The exact authentication behavior depends on the backend, but both values should be treated as sensitive.

---

## Question 89

Inspect:

```text
Response body
Redirect chain
Request URL
API base URL
Server route
Authentication behavior
```

A JSON endpoint may have returned an HTML fallback or login page.

---

## Question 90

The response is inconsistent with its declared content type. The server or proxy may be misconfigured, or the response may have been transformed incorrectly. The client should not blindly assume the body is valid JSON.

---

## Question 91

The server is redirecting the request to `/login`. The session may be missing, expired, invalid, or not being sent.

---

## Question 92

The browser or another cache may reuse the response for up to 3,600 seconds. It may later send the ETag in `If-None-Match` and receive `304 Not Modified`.

---

## Question 93

The server is telling the browser that frontend JavaScript from `https://app.example.com` may read the response, subject to other CORS and credential rules.

---

## Question 94

The `Origin` header identifies the origin that initiated the browser request:

```text
Scheme + Host + Port
```

---

## Question 95

The response is likely too large, insufficiently compressed, or being transferred over a slow connection. Inspect response size, compression, and download speed.

---

# Part 5 — Scenario Model Answers

## Question 96 — Button Does Nothing

Investigate:

```text
Console errors
Button disabled state
Event listener
Form behavior
Frontend validation
JavaScript initialization
Request construction
```

Because no request appears, the failure likely occurred before network transmission.

---

## Question 97 — JavaScript Error Before Request

The likely failure is in frontend JavaScript execution. The code crashed before it could create the API request.

Inspect:

```text
Stack trace
Variables
Event handler
Data initialization
Response assumptions from earlier code
```

---

## Question 98 — Request Returns `401`

Inspect:

```text
Session cookie
Authorization header
Token expiration
Login result
Cookie domain
Cookie path
Secure and SameSite attributes
Environment
```

---

## Question 99 — Request Returns `403`

The caller is likely authenticated but lacks permission to access the administrator endpoint.

Check:

```text
Role
Resource ownership
Organization
Subscription
Account status
```

---

## Question 100 — Request Returns `404`

The frontend is likely using the wrong route path. Compare:

```text
Actual:
  /api/order/123

Documented:
  /api/orders/123
```

Also check method, environment, API version, and whether the resource exists.

---

## Question 101 — Request Returns `422`

The value violates validation or business rules.

The backend should reject it with a structured validation error. The frontend should display a clear message, such as:

```text
Quantity must be greater than zero.
```

The backend must enforce this even if the frontend already validates it.

---

## Question 102 — Request Returns `500`

Collect:

```text
Request URL
Method
Headers
Payload
Status
Response body
Request ID
Server logs
Database logs
Dependency logs
Recent deployment history
```

Do not immediately change frontend code without confirming whether the backend failed.

---

## Question 103 — Browser Shows HTML

Possible causes:

```text
Authentication redirect
Wrong API base URL
Missing route
Reverse proxy fallback
Server error page
Environment mismatch
```

Inspect `Content-Type`, redirects, response body, and request URL.

---

## Question 104 — CORS Error

cURL can read the response without enforcing browser CORS restrictions. The browser may receive the response but prevent frontend JavaScript from accessing it because the server did not authorize the origin, method, headers, or credentials.

---

## Question 105 — Redirect Loop

Possible causes:

```text
Session cookie not stored
Cookie domain mismatch
Cookie path mismatch
SameSite issue
Secure cookie sent over HTTP
Reverse proxy does not recognize HTTPS
Login callback configuration
Session store failure
```

Inspect `Location`, `Set-Cookie`, `Cookie`, protocol, and host.

---

## Question 106 — Stale Content

Possible cache layers include:

```text
Browser cache
CDN cache
Reverse proxy cache
Application cache
Service worker cache
```

Inspect `Cache-Control`, `ETag`, `Age`, transfer source, and deployment asset names.

---

## Question 107 — Service Worker

Inspect:

```text
Application panel
Service worker registration
Cache Storage
Active worker
Request interception
```

Try testing after clearing site data or unregistering the worker in a safe development environment.

---

## Question 108 — Slow First Request

Possible causes:

```text
Cold DNS cache
New connection
TLS handshake
CDN cache miss
Application cold start
Database cache miss
```

Later requests may reuse connections or cached results.

---

## Question 109 — High TTFB

Investigate:

```text
Backend processing
Database query
Cache miss
External API
Connection pool
Server queue
Cold start
```

Use server logs, traces, and database timing.

---

## Question 110 — Slow Download

Possible causes:

```text
Large response
Large images
Missing compression
Slow bandwidth
Too many records
Streaming response
```

Inspect transferred size, decoded size, `Content-Encoding`, and download speed.

---

## Question 111 — Repeated Requests

Possible causes:

```text
Component render loop
Repeated event listener
Polling
Retry loop
Double-click
Multiple tabs
Service worker behavior
Frontend effect dependency
```

Inspect the Initiator column and JavaScript call stack.

---

## Question 112 — Search Race Condition

Possible solutions:

```text
Debounce input
Cancel previous requests
Track request IDs
Ignore stale responses
Use sequence numbers
```

The frontend should ensure an older response cannot overwrite newer search results.

---

## Question 113 — Duplicate Form Submission

Frontend protections:

```text
Disable the submit button while processing.
Prevent double submission.
Show progress.
Cancel or ignore duplicate clicks.
```

Backend protections:

```text
Idempotency keys
Unique constraints
Duplicate detection
Transactional processing
```

The backend must remain safe even if the client sends duplicates.

---

## Question 114 — Environment Mismatch

Inspect:

```text
Production API base URL
Build-time environment variables
Generated frontend bundle
DNS
CORS allowed origins
Cookie domains
Authentication provider
Deployment configuration
```

Do not assume the `.env` file used locally is the one used in production.

---

## Question 115 — Failed cURL Reproduction

Compare:

```text
URL
Method
Query parameters
Headers
Cookies
Authorization
Origin
Content-Type
Request body
Redirect handling
Proxy
Environment
```

The browser may include cookies or headers that the copied command lost or that were redacted incorrectly.

---

## Question 116 — Authentication Cookie Missing

Inspect:

```text
Set-Cookie response header
Cookie domain
Cookie path
Secure
SameSite
Expiration
HTTPS
Browser storage
Cross-origin credentials
```

Also check whether the browser blocked the cookie.

---

## Question 117 — Network Failure

Possible layers include:

```text
DNS
Network routing
Firewall
Connection
TLS
CORS
Browser extension
Offline state
Request cancellation
Timeout
Service worker
```

Because no HTTP status exists, investigate before the normal HTTP response stage.

---

## Question 118 — Redirected API Response

The frontend may be calling a protected endpoint without valid authentication. It may also be using the wrong cookie domain or API environment.

An API request returning an HTML login page often indicates an authentication redirect that the frontend was not prepared to handle.

---

## Question 119 — Large Payload

Possible improvements:

```text
Pagination
Field selection
Filtering
Compression
Smaller representations
Lazy loading
Separate related-resource requests
Optimized database queries
```

---

## Question 120 — Production `503`

Investigate:

```text
Application instance health
Load balancer health checks
Deployment status
Autoscaling
Capacity
Database availability
External dependencies
Circuit breakers
Infrastructure metrics
Recent configuration changes
```

A `503` may result from overload, maintenance, failed readiness checks, or unavailable dependencies.

---

# Part 6 — Practical Exercise Guidance

## Exercise 1

The exact values depend on the page. Identify:

```text
Document request
JavaScript files
CSS files
Images
Fonts
Fetch/XHR requests
Failed requests
Largest request
Slowest request
```

---

## Exercise 2

Record the request and response details. Redact:

```text
Cookies
Authorization
API keys
Personal information
```

---

## Exercise 3

The cURL command should reproduce the request approximately. Differences may occur because:

```text
Service workers are not involved.
Browser policies differ.
Some headers may be omitted.
Credentials may be redacted.
```

---

## Exercise 4

Compare:

```text
Cache-Control
ETag
Age
Status
Transfer size
Response source
Timing
```

A cached response may show little or no network transfer.

---

## Exercise 5

Observe how throttling affects:

```text
Loading indicators
TTFB
Download time
Timeouts
Retries
UI responsiveness
```

---

## Exercise 6

Inspect:

```text
Cookies
Local Storage
Session Storage
IndexedDB
Cache Storage
Service workers
```

Do not copy or share real credentials.

---

# Scoring Guidance

## Multiple choice and true/false

```text
1 point per correct answer
```

## Short-answer questions

```text
2 points:
  Correct core definition.

3 points:
  Correct definition plus a diagnostic example.

4 points:
  Correct explanation, evidence source, and likely failure layer.
```

## Request-inspection questions

Evaluate:

```text
Correct interpretation of request and response data
Understanding of headers
Understanding of status codes
Recognition of caching or authentication behavior
```

## Scenario questions

Evaluate whether the learner:

```text
Starts with evidence
Identifies the correct layer
Uses appropriate diagnostic tools
Distinguishes browser from server behavior
Protects secrets
Suggests a safe fix
```

---

# Review Recommendations

If you struggled with:

```text
Developer Tools:
  Part 5, Sections 1–15
  Appendix F

Timing and performance:
  Part 5, Sections 16–25
  Appendix J

cURL and API clients:
  Part 5, Sections 26–40
  Appendix E
  Appendix G

CORS and authentication:
  Part 5, Sections 41–50
  Primer 8
  Appendix I

Caching and service workers:
  Part 5, Sections 51–57
  Appendix C
  Appendix F

Troubleshooting:
  Part 5, Sections 58–65
  Appendix K
```

---

# Completion Criteria

You are ready to continue when you can:

```text
Open and use Developer Tools.
Inspect requests and responses.
Read request headers and payloads.
Interpret response status and body.
Understand timing phases.
Use cURL to reproduce requests.
Distinguish network failures from HTTP errors.
Diagnose 401, 403, 404, 422, and 5xx responses.
Investigate CORS.
Investigate cookies and authentication.
Recognize stale cache and service-worker problems.
Identify environment mismatches.
Use evidence before changing code.
```
