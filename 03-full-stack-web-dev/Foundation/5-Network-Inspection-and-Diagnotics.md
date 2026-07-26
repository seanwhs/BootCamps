# Web Mechanics, Architecture & Network Fundamentals

# Part 5 — Network Inspection and Diagnostic Workflows  
## DevTools, API Clients, cURL, Postman, Bruno, and Seeing the Network in Real Time

---

# Part 5 Overview

In the previous parts, we built the theory behind web applications:

- Part 1 explained frontend, backend, databases, and application architecture.
- Part 2 explained the Internet, IP addressing, DNS, routers, CDNs, and data centers.
- Part 3 explained HTTP, HTTPS, requests, responses, headers, bodies, status codes, and TLS.
- Part 4 explained APIs, REST, GraphQL, RPC, serialization, contracts, pagination, and error design.

Now we will turn those ideas into practical debugging skills.

The goal of this part is to help you answer questions such as:

- Did the browser send a request?
- What exact URL did it request?
- Which HTTP method was used?
- What headers were included?
- Was authentication sent?
- What request body was submitted?
- What status code came back?
- Did the server return JSON, HTML, or an error page?
- Was the request blocked by CORS?
- Was DNS slow?
- Was the server slow?
- Did the browser use a cached response?
- Is the problem in the frontend, network, backend, database, or third-party service?
- Can the request be reproduced outside the browser?
- How can an API be tested without building a user interface?

The most important practical tool is the browser’s **Network panel**.

```mermaid
flowchart TD
    A[User Action] --> B[Browser Creates Request]
    B --> C[Network Panel Captures Request]
    C --> D[Inspect URL, Method, Headers, Body]
    D --> E[Inspect Status, Response, Timing]
    E --> F[Identify Failing Layer]
```

A strong developer does not debug only by staring at source code.

They inspect evidence.

---

# 1. The Core Diagnostic Mindset

When a feature does not work, avoid beginning with:

> Which line of frontend code should I change?

Instead begin with:

> What exactly happened on the network?

A browser interaction can fail at many points:

```mermaid
flowchart TD
    U[User Action] --> F[Frontend Event Handler]
    F --> R[Request Created]
    R --> DNS[DNS Resolution]
    DNS --> C[Connection]
    C --> TLS[TLS Negotiation]
    TLS --> S[Server]
    S --> DB[(Database)]
    DB --> S
    S --> RESP[HTTP Response]
    RESP --> F2[Frontend Parses Response]
    F2 --> UI[Interface Updates]
```

A failure may occur at:

- User interaction
- Frontend JavaScript
- Request creation
- DNS
- Network connection
- TLS
- Server routing
- Authentication
- Authorization
- Database access
- External API access
- Response parsing
- UI rendering

The Network panel helps you determine which stages actually occurred.

---

# 2. A Layered Debugging Workflow

Use this general process:

```mermaid
flowchart TD
    A[Feature does not work] --> B{Was the UI event triggered?}
    B -->|No| C[Inspect frontend event and JavaScript]
    B -->|Yes| D{Does a network request appear?}
    D -->|No| E[Inspect request creation logic]
    D -->|Yes| F{Did the request complete?}
    F -->|No| G[Inspect DNS, connection, TLS, CORS, timeout]
    F -->|Yes| H{What status code returned?}
    H -->|2xx| I[Inspect response parsing and UI state]
    H -->|3xx| J[Inspect redirects]
    H -->|4xx| K[Inspect request, identity, permissions, route]
    H -->|5xx| L[Inspect backend, database, upstream services]
```

This simple workflow prevents many common debugging mistakes.

For example:

```text
No request in Network panel
→ likely frontend problem

Request returns 401
→ likely authentication problem

Request returns 403
→ likely permission problem

Request returns 404
→ likely URL or route problem

Request returns 500
→ likely server-side problem

Request returns 200 but UI is blank
→ likely response parsing or rendering problem
```

---

# 3. Opening Browser Developer Tools

Most modern browsers provide Developer Tools.

Common ways to open them:

- Right-click the page and choose **Inspect**
- Press `F12`
- Press `Ctrl + Shift + I` on Windows/Linux
- Press `Cmd + Option + I` on macOS

The exact layout varies, but common panels include:

- Elements
- Console
- Sources
- Network
- Application
- Performance
- Security
- Storage
- Lighthouse or Audits

For this series, the most important panels are:

```text
Console
Network
Application or Storage
Security
```

---

# 4. The Console and Network Panel Work Together

The Console shows frontend execution messages.

The Network panel shows communication with external resources.

For example, a frontend error may appear in the Console:

```text
TypeError: Cannot read properties of undefined
```

The Network panel may show no request at all.

That combination suggests:

```text
The frontend crashed before creating the request.
```

Another case:

```text
Console: no JavaScript error
Network: POST /api/orders → 500
```

That suggests:

```text
The frontend sent the request, but the backend failed.
```

Use both panels together.

```mermaid
flowchart LR
    C[Console] --> F[Frontend Execution Evidence]
    N[Network] --> W[HTTP and Network Evidence]
    F --> D[Combined Diagnosis]
    W --> D
```

---

# 5. The Network Panel Interface

The Network panel commonly contains:

- Request list
- Filter controls
- Waterfall timeline
- Request details
- Response preview
- Headers
- Timing information
- Initiator information
- Cookies
- Security details

A simplified layout:

```text
---------------------------------------------------------
| Filter | Fetch/XHR | Doc | JS | CSS | Img | WS       |
---------------------------------------------------------
| Name       | Status | Type | Initiator | Size | Time |
---------------------------------------------------------
| products   | 200    | xhr  | app.js   | 4 KB | 120ms|
| app.js     | 200    | js   | document | 80KB | 50ms |
| logo.png   | 200    | png  | document | 8KB | 30ms |
---------------------------------------------------------
| Selected request details                              |
---------------------------------------------------------
```

The exact labels may differ, but the concepts are similar.

---

# 6. Preserve Logs

Normally, navigating to a new page may clear Network panel entries.

Enable **Preserve log** when debugging:

- Redirects
- Login flows
- Navigation problems
- Multi-page workflows
- Requests that happen before a page unloads

Without preserved logs, you may lose the most important request.

---

# 7. Disable Cache

Developer Tools often provide a **Disable cache** option.

This usually applies while Developer Tools are open.

Disable cache when testing:

- Fresh page loads
- Cache-control behavior
- Asset changes
- Deployment updates
- Whether a response is genuinely coming from the server

Be careful:

> Disabling cache changes normal browser behavior.

Use it for diagnosis, but also test under realistic caching conditions.

---

# 8. Reload and Record a Page Load

A useful first workflow is:

1. Open Developer Tools.
2. Select the Network panel.
3. Enable Preserve log if needed.
4. Optionally disable cache.
5. Clear existing requests.
6. Reload the page.
7. Observe the request sequence.

You may see:

```text
Document
Stylesheets
JavaScript
Fonts
Images
API calls
Analytics
Third-party resources
```

This shows that a page is usually assembled from many requests.

```mermaid
flowchart TD
    D[HTML Document] --> CSS[CSS Files]
    D --> JS[JavaScript Files]
    D --> IMG[Images]
    D --> FONT[Fonts]
    JS --> API[API Requests]
    API --> DATA[Dynamic Data]
```

---

# 9. Filtering Network Requests

A page may generate hundreds of requests.

Use filters to narrow the list.

Common categories include:

- All
- Fetch/XHR
- Documents
- JavaScript
- CSS
- Images
- Fonts
- Media
- WebSockets
- Manifest
- Other

When debugging an API call, start with:

```text
Fetch/XHR
```

The browser may call these requests:

- Fetch
- XHR
- API calls
- GraphQL requests
- Form submissions

You can also search by:

- URL
- Resource name
- Method
- Status
- Domain
- MIME type

Examples of useful filters:

```text
api
products
orders
graphql
status-code:404
method:POST
```

The exact filter syntax varies by browser.

---

# 10. Understanding the Request List

A request list may show columns such as:

| Column | Meaning |
|---|---|
| Name | Resource or request path |
| Status | HTTP status code |
| Method | `GET`, `POST`, etc. |
| Domain | Host receiving the request |
| Type | Document, fetch, xhr, script, image |
| Initiator | Code or resource that caused the request |
| Size | Transferred or decoded size |
| Time | Duration |
| Waterfall | Timing visualization |

The most important initial columns are:

```text
Name
Status
Method
Type
Time
```

---

# 11. Inspecting Request Headers

Click a request and open the **Headers** section.

You may see:

```text
Request URL
Request Method
Status Code
Remote Address
Referrer Policy
```

Then:

```text
Request Headers
```

Example:

```http
Accept: application/json
Authorization: Bearer ...
Content-Type: application/json
Origin: https://app.example.com
User-Agent: ...
```

Ask:

- Is the URL correct?
- Is the method correct?
- Is authentication included?
- Is the content type correct?
- Is the request coming from the expected origin?
- Are query parameters present?
- Is the request going to the correct environment?

A surprising number of bugs are caused by:

- Wrong host
- Wrong path
- Wrong HTTP method
- Missing token
- Incorrect content type
- Wrong query parameter name

---

# 12. Viewing Query Parameters

Browser tools usually display query parameters separately.

Example request URL:

```text
https://api.example.com/products?category=keyboard&page=2
```

The query section may show:

```text
category: keyboard
page: 2
```

Check:

- Whether parameters are present
- Whether values are correctly encoded
- Whether `page` is a number
- Whether filters are spelled correctly
- Whether the client sent empty values
- Whether the server expects a different parameter name

A frontend may send:

```text
?search=keyboard
```

while the backend expects:

```text
?q=keyboard
```

The request can be technically successful but produce incorrect results.

---

# 13. Viewing Request Payloads

For `POST`, `PUT`, and `PATCH` requests, inspect the payload.

Example JSON payload:

```json
{
  "productId": 123,
  "quantity": 2
}
```

Look for:

- Missing fields
- Incorrect field names
- Wrong data types
- Unexpected `null` values
- Empty strings
- Wrong nesting
- Incorrect identifiers
- Client-provided values that should be server-calculated

Common mistakes:

```json
{
  "product_id": 123
}
```

when the backend expects:

```json
{
  "productId": 123
}
```

Or:

```json
{
  "quantity": "2"
}
```

when the backend expects a number:

```json
{
  "quantity": 2
}
```

---

# 14. Viewing the Response

The Network panel usually provides several ways to view a response:

- Preview
- Response
- Headers
- Raw
- Timing

For JSON, **Preview** may show a structured tree.

Example:

```json
{
  "items": [
    {
      "id": 123,
      "name": "Keyboard"
    }
  ]
}
```

The **Response** tab shows the raw response text.

Check:

- Is the response actually JSON?
- Does the response contain the fields the frontend expects?
- Is the array empty?
- Is an error object present?
- Is HTML being returned unexpectedly?
- Is the response truncated or incomplete?

---

# 15. A Common HTML-Instead-of-JSON Problem

Suppose frontend code expects:

```javascript
const data = await response.json();
```

But the server returns:

```html
<!doctype html>
<html>
  <body>
    <h1>Not Found</h1>
  </body>
</html>
```

The JSON parser fails.

Possible causes:

- Wrong API URL
- Frontend sent request to the web server instead of API server
- Backend route does not exist
- Authentication redirect returned an HTML login page
- Reverse proxy misconfiguration
- Development server fallback behavior

The Network panel reveals the true response.

---

# 16. Inspecting Response Headers

Response headers may reveal:

```http
Content-Type: application/json
Cache-Control: no-store
Set-Cookie: ...
Access-Control-Allow-Origin: ...
Server: ...
Content-Encoding: br
ETag: ...
```

Important questions:

- Is `Content-Type` correct?
- Is the response being cached?
- Did the server set or clear a cookie?
- Is CORS configured?
- Was the response compressed?
- Did a redirect occur?
- Is security policy present?

A response claiming:

```http
Content-Type: application/json
```

should normally contain valid JSON.

---

# 17. Inspecting Status Codes

The status code is one of the fastest diagnostic clues.

## `200 OK`

The request succeeded.

Still inspect the body. A `200` does not guarantee that the desired business operation succeeded.

## `201 Created`

A resource was created.

## `204 No Content`

The operation succeeded without a body.

## `301`, `302`, `307`, `308`

A redirect occurred.

## `400`

The request was invalid.

## `401`

Authentication is missing or invalid.

## `403`

The user is authenticated but not permitted.

## `404`

The route or resource was not found.

## `409`

The request conflicts with current state.

## `422`

The data failed validation.

## `429`

The client was rate-limited.

## `500`

The backend encountered an internal error.

## `502`, `503`, `504`

A gateway, upstream service, or availability problem occurred.

---

# 18. Timing Information

The timing section breaks down how long each part of a request took.

Typical phases include:

```text
Queueing
Stalled
DNS Lookup
Initial Connection
SSL/TLS
Request Sent
Waiting for Server Response
Content Download
```

A conceptual timeline:

```mermaid
flowchart LR
    Q[Queueing] --> D[DNS]
    D --> C[Connection]
    C --> T[TLS]
    T --> S[Request Sent]
    S --> W[Waiting / TTFB]
    W --> R[Response Download]
```

---

# 19. DNS Lookup Time

DNS lookup time measures how long it took to resolve the hostname.

If DNS is slow, possible causes include:

- Resolver problems
- Cold DNS cache
- Network delay
- Misconfigured DNS
- Many third-party domains

If a request is slow only on the first visit but faster later, DNS caching may be involved.

---

# 20. Connection Time

Connection time includes establishing a network connection.

It may be affected by:

- Distance
- Routing
- Congestion
- Server availability
- Firewall behavior
- Network conditions
- Transport protocol

A failed connection may produce errors such as:

```text
ERR_CONNECTION_REFUSED
ERR_CONNECTION_TIMED_OUT
```

---

# 21. TLS Time

For HTTPS requests, the browser performs a TLS handshake.

TLS time may be affected by:

- Geographic distance
- Server configuration
- Certificate chain
- Connection reuse
- Protocol version
- Network conditions

If TLS fails, the browser may show a certificate or secure-connection error.

---

# 22. Time to First Byte

**TTFB** means **Time to First Byte**.

It measures approximately how long it takes before the browser receives the first response byte after sending the request.

TTFB includes:

- Network travel
- Server queueing
- Application processing
- Database queries
- Upstream service calls

A high TTFB may indicate:

- Slow backend code
- Slow database queries
- Server overload
- A slow external API
- Cache miss
- Geographic distance

TTFB does not tell you the exact cause, but it identifies delay before response data begins.

---

# 23. Content Download Time

Once the first byte arrives, the rest of the response must be downloaded.

A large download may take time because of:

- Large response size
- Low bandwidth
- Network congestion
- Slow server output
- Compression settings

A response with low TTFB but long download time may indicate a large payload.

A response with high TTFB but fast download may indicate slow server processing.

---

# 24. Waterfall Analysis

The waterfall shows requests over time.

```text
HTML       |████████
CSS           |██
JavaScript   |██████
API              |██████████
Image             |████
Font                |██
```

Look for:

- Long blank gaps
- Requests blocking others
- Large slow files
- Serial requests that could be parallel
- Repeated failed requests
- Slow third-party resources
- API calls occurring later than expected

A page may feel slow because:

```text
The browser is waiting for a slow API before rendering important content.
```

Or:

```text
A large JavaScript bundle delays application startup.
```

---

# 25. Initiator Information

The initiator tells you what caused a request.

Possible initiators:

- HTML document
- JavaScript file
- CSS file
- Another request
- User interaction
- Browser preload mechanism

If an unexpected request is occurring repeatedly, inspect its initiator.

This can reveal:

- A loop in frontend code
- A component fetching on every render
- A third-party script
- A redirect chain
- An image or font referenced by CSS

---

# 26. Copying Requests from DevTools

Most browsers allow you to right-click a request and choose options such as:

- Copy URL
- Copy as cURL
- Copy request headers
- Copy response
- Replay request
- Open in a new tab

**Copy as cURL** is especially useful.

It converts a browser request into a terminal command that can be tested outside the browser.

Conceptually:

```mermaid
flowchart LR
    B[Browser Request] --> C[Copy as cURL]
    C --> T[Terminal]
    T --> R[Reproduce Request]
```

This helps separate:

```text
Browser/UI problem
```

from:

```text
Backend/API problem
```

---

# 27. cURL Basics

cURL is a command-line tool for making network requests.

Basic GET request:

```bash
curl https://example.com
```

Display response headers:

```bash
curl -I https://example.com
```

Show verbose connection information:

```bash
curl -v https://example.com
```

Follow redirects:

```bash
curl -L http://example.com
```

Save response to a file:

```bash
curl https://example.com -o page.html
```

Show only the HTTP status code:

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://example.com
```

---

# 28. cURL GET Requests

Request JSON:

```bash
curl \
  -H "Accept: application/json" \
  https://api.example.com/products
```

Add query parameters:

```bash
curl \
  -G https://api.example.com/products \
  --data-urlencode "category=keyboards" \
  --data-urlencode "page=2"
```

The `-G` option tells cURL to place the data in the query string.

This is safer than manually constructing URLs when values contain spaces or special characters.

---

# 29. cURL POST Requests

Send form-encoded data:

```bash
curl \
  -X POST \
  -d "name=Alex&email=alex@example.com" \
  https://api.example.com/users
```

Send JSON:

```bash
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Alex","email":"alex@example.com"}' \
  https://api.example.com/users
```

Request JSON response:

```bash
curl \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name":"Alex"}' \
  https://api.example.com/users
```

---

# 30. cURL Authentication

Bearer token:

```bash
curl \
  -H "Authorization: Bearer example-token" \
  https://api.example.com/account
```

API key:

```bash
curl \
  -H "X-API-Key: example-key" \
  https://api.example.com/data
```

Basic authentication:

```bash
curl \
  -u username:password \
  https://api.example.com/private
```

Be careful with shell history.

Do not paste real secrets into shared terminals or commit them into scripts.

---

# 31. cURL Cookies

Send a cookie:

```bash
curl \
  -H "Cookie: session_id=abc123" \
  https://api.example.com/account
```

Store cookies from a response:

```bash
curl \
  -c cookies.txt \
  -X POST \
  -d "email=alex@example.com&password=example" \
  https://api.example.com/login
```

Reuse stored cookies:

```bash
curl \
  -b cookies.txt \
  https://api.example.com/account
```

This can help reproduce session-based flows.

---

# 32. cURL File Uploads

Upload a file using multipart form data:

```bash
curl \
  -X POST \
  -F "description=Profile photo" \
  -F "file=@profile.jpg" \
  https://api.example.com/uploads
```

cURL automatically constructs the multipart request.

---

# 33. cURL Debugging Options

Verbose mode:

```bash
curl -v https://example.com
```

This can show:

- DNS result
- Connection details
- TLS negotiation
- Request headers
- Response headers

Include response headers in output:

```bash
curl -i https://example.com
```

Trace the entire exchange:

```bash
curl --trace-ascii trace.txt https://example.com
```

Use a timeout:

```bash
curl --connect-timeout 5 --max-time 15 https://example.com
```

Be careful with traces because they may contain credentials or private data.

---

# 34. Postman and Bruno

Postman and Bruno are graphical API clients.

They allow you to create and send requests without building a frontend.

They commonly support:

- HTTP methods
- URLs
- Headers
- Query parameters
- Request bodies
- Authentication
- Cookies
- Environments
- Collections
- Tests
- Request history
- Saved examples

A conceptual workflow:

```mermaid
flowchart TD
    A[Create Request] --> B[Choose Method]
    B --> C[Enter URL]
    C --> D[Add Query Parameters]
    D --> E[Add Headers]
    E --> F[Add Body]
    F --> G[Send Request]
    G --> H[Inspect Response]
```

---

# 35. Building a Request in an API Client

Suppose you want to test:

```http
POST /api/orders
```

Configure:

```text
Method:
  POST

URL:
  https://api.example.com/orders

Headers:
  Accept: application/json
  Content-Type: application/json
  Authorization: Bearer example-token

Body:
  Raw JSON
```

Body:

```json
{
  "items": [
    {
      "productId": 123,
      "quantity": 2
    }
  ]
}
```

Then inspect:

- Status code
- Response headers
- Response body
- Timing
- Cookies
- Error details

---

# 36. Query Parameters in API Clients

Most API clients provide a table for query parameters.

Example:

| Key | Value |
|---|---|
| `category` | `keyboards` |
| `page` | `2` |
| `limit` | `20` |

The client constructs:

```text
/products?category=keyboards&page=2&limit=20
```

Using a parameter table reduces encoding mistakes.

---

# 37. Authentication in API Clients

API clients commonly support:

- No authentication
- Basic authentication
- Bearer token
- API key
- OAuth 2.0
- AWS-style signatures
- Custom headers

For a bearer token, configure:

```text
Authorization: Bearer example-token
```

For an API key:

```text
X-API-Key: example-key
```

Avoid saving production secrets in shared collections or exporting them accidentally.

---

# 38. Environments

API clients often support environment variables.

Example environment:

```text
baseUrl = https://api.example.com
accessToken = example-token
userId = 42
```

Request:

```text
{{baseUrl}}/users/{{userId}}
```

Header:

```text
Authorization: Bearer {{accessToken}}
```

This allows the same request to work against:

```text
Local development
Testing
Staging
Production
```

```mermaid
flowchart LR
    R[Saved Request] --> DEV[Development Environment]
    R --> ST[Staging Environment]
    R --> PROD[Production Environment]
```

Be careful that production variables are not accidentally used for destructive tests.

---

# 39. Collections and Workflows

A collection groups related requests.

For an online store:

```text
Authentication
  POST /login

Products
  GET /products
  GET /products/:id

Cart
  GET /cart
  POST /cart/items

Orders
  POST /orders
  GET /orders/:id
```

Requests can be run in sequence:

```mermaid
flowchart TD
    L[Login] --> P[Get Product]
    P --> C[Add to Cart]
    C --> O[Create Order]
    O --> S[Check Order Status]
```

This allows testing a complete workflow independently of the frontend.

---

# 40. API Client Tests

API tools can automatically test responses.

Conceptual tests include:

```text
Status code equals 200
Response is JSON
Response contains an items array
Product ID is present
Response time is below 1000 ms
```

A simple test concept:

```javascript
pm.test("Status is 200", function () {
  pm.response.to.have.status(200);
});
```

The exact syntax depends on the tool.

Automated API tests help detect regressions when backend code changes.

---

# 41. Testing an API Without the Frontend

This is one of the most valuable debugging techniques.

Suppose the frontend fails.

Use the API client or cURL to send the same request manually.

```mermaid
flowchart LR
    F[Frontend Request] --> A[API]
    C[cURL or API Client Request] --> A
    A --> R[Compare Responses]
```

If the manual request also fails:

```text
Likely backend, data, authentication, or infrastructure problem.
```

If the manual request succeeds but the browser request fails:

```text
Likely frontend request construction, browser policy, cookie, CORS, or environment problem.
```

---

# 42. Comparing Browser and cURL Requests

When comparing requests, check:

- URL
- Method
- Query string
- Headers
- Cookies
- Authorization
- Origin
- Body
- Content type
- Redirect behavior

Two requests may look similar but differ in one crucial header.

Example:

```text
Browser includes session cookie.
cURL does not.
```

Result:

```text
Browser: 200 OK
cURL: 401 Unauthorized
```

Or:

```text
Browser sends Content-Type: application/json.
cURL sends form data.
```

Result:

```text
Browser: 201 Created
cURL: 400 Bad Request
```

---

# 43. CORS Diagnostics

CORS problems usually appear when browser JavaScript calls a different origin.

Example:

```text
Frontend:
https://app.example.com

API:
https://api.example.com
```

The browser may send an `OPTIONS` preflight request first.

```mermaid
sequenceDiagram
    participant B as Browser
    participant API as API Server

    B->>API: OPTIONS preflight
    API-->>B: Allowed origin and method
    B->>API: Actual request
    API-->>B: Response
```

A failed preflight may involve headers such as:

```http
Access-Control-Allow-Origin
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Access-Control-Allow-Credentials
```

Important point:

> A request may reach the server while the browser still prevents JavaScript from reading the response.

The Network panel may show the request and response, while the Console reports a CORS error.

---

# 44. CORS vs Authentication

CORS and authentication are separate concerns.

A request may fail because:

- The server rejects the user’s credentials.
- The browser refuses to expose the response because the origin was not allowed.
- Cookies were not included.
- Credentials were included but the server did not allow credentialed CORS.

When debugging, inspect:

- `Origin`
- `Access-Control-Allow-Origin`
- `Access-Control-Allow-Credentials`
- Cookie settings
- Whether the preflight succeeded
- Whether the actual request was sent

---

# 45. Redirect Diagnostics

A request may pass through several URLs:

```mermaid
flowchart LR
    A[http://example.com] -->|301| B[https://example.com]
    B -->|302| C[https://www.example.com]
    C -->|200| D[Final Page]
```

Too many redirects can indicate:

- HTTP/HTTPS configuration problems
- `www` canonicalization issues
- Login loops
- Misconfigured reverse proxies
- Cookie or session problems
- Routing mistakes

Inspect the redirect chain in the Network panel.

Also check the `Location` response header.

---

# 46. Authentication Debugging

If a request returns `401`, inspect:

- Was a cookie sent?
- Was an `Authorization` header sent?
- Is the token expired?
- Is the token for the correct environment?
- Did the login response set a cookie?
- Is the cookie marked for the correct domain?
- Is `Secure` preventing transmission over HTTP?
- Is `SameSite` affecting cross-site requests?

If a request returns `403`, inspect:

- User role
- Resource ownership
- Organization membership
- Required permission
- Server authorization logic

Do not solve a `403` by simply hiding the frontend button. The server must enforce the permission.

---

# 47. Reproducing a `500` Error

When an endpoint returns `500`:

1. Copy the request as cURL.
2. Reproduce it locally or in an API client.
3. Confirm the failure is consistent.
4. Inspect backend logs.
5. Identify the request ID if available.
6. Check database queries.
7. Check external service calls.
8. Check environment configuration.
9. Check recent deployments.

```mermaid
flowchart TD
    A[500 Response] --> B[Copy Request]
    B --> C[Reproduce Manually]
    C --> D[Find Request ID]
    D --> E[Inspect Server Logs]
    E --> F[Check Database and Dependencies]
    F --> G[Fix and Retest]
```

A generic `500` response is not enough to diagnose the root cause. Server-side logs are usually required.

---

# 48. Slow Request Diagnostics

If a request is slow, inspect:

```text
DNS time
Connection time
TLS time
Waiting / TTFB
Download time
```

Possible interpretation:

| Symptom | Possible cause |
|---|---|
| Slow DNS | Resolver or uncached lookup |
| Slow connection | Network distance, congestion, unavailable server |
| Slow TLS | Connection setup or certificate chain |
| High TTFB | Backend, database, or upstream service |
| Long download | Large response or low bandwidth |
| Repeated requests | Frontend loop or bad caching |
| Many serial requests | Request waterfall or inefficient data loading |

Do not optimize blindly. Measure first.

---

# 49. Request Size and Response Size

Large payloads can slow applications.

Inspect:

- Request body size
- Response size
- Transferred size
- Decoded size
- Compression
- Image dimensions
- JavaScript bundle size

A response may be large because:

- Too many records were returned
- Pagination is missing
- Related resources are embedded excessively
- Images are unoptimized
- Debug information is included
- Compression is disabled
- The frontend requests fields it does not need

---

# 50. Network Throttling

Browser Developer Tools often allow simulated network conditions:

- Fast 3G
- Slow 3G
- Offline
- Custom latency
- Custom download speed
- Custom upload speed

This helps test:

- Loading states
- Error states
- Timeouts
- Retry behavior
- Offline behavior
- Slow-device experience
- Rendering before all resources arrive

```mermaid
flowchart TD
    A[Network Throttling] --> B[Slow Response]
    B --> C[Loading State]
    C --> D{Response succeeds?}
    D -->|Yes| E[Display Content]
    D -->|No| F[Display Error and Retry]
```

A page that works only on a fast developer connection may still provide a poor real-world experience.

---

# 51. Offline Testing

Set the browser to offline mode and observe:

- Which resources are cached
- Whether the application displays a useful message
- Whether requests fail gracefully
- Whether unsaved input is preserved
- Whether retry behavior works
- Whether a service worker serves cached content

Offline handling is especially important for:

- Mobile applications
- Progressive web apps
- Field tools
- Travel applications
- Messaging systems
- Forms used in unreliable networks

---

# 52. WebSockets and Real-Time Connections

The Network panel may include a WebSocket category.

A WebSocket connection differs from ordinary request-response traffic.

After connection establishment, inspect messages such as:

```text
→ {"type":"join","room":"general"}
← {"type":"message","text":"Hello"}
```

A WebSocket problem may involve:

- Connection failure
- Authentication
- Incorrect upgrade headers
- Proxy configuration
- Reconnection loops
- Server disconnects
- Message format errors

---

# 53. Security Inspection

The Security panel can provide information about:

- Certificate validity
- HTTPS usage
- TLS protocol
- Mixed content
- Security origin
- Certificate chain

For a secure page, verify:

```text
https://
Valid certificate
No blocked mixed content
Expected host
```

Do not ignore browser certificate warnings in real applications.

---

# 54. Application and Storage Inspection

The Application or Storage panel commonly lets you inspect:

- Cookies
- Local storage
- Session storage
- IndexedDB
- Cache storage
- Service workers
- Web app manifests

This helps debug:

- Missing session cookies
- Stale local data
- Incorrect feature flags
- Authentication state
- Service worker caching
- Offline behavior

Be careful when inspecting or editing authentication data. Changes may affect the current session.

---

# 55. Local Storage vs Cookies

Local storage:

```javascript
localStorage.setItem("theme", "dark");
```

Cookies:

```text
session_id=abc123
```

General differences:

| Feature | Local storage | Cookies |
|---|---|---|
| Automatically sent with requests | No | Usually yes, when applicable |
| Accessible to JavaScript | Usually yes | Not if `HttpOnly` |
| Typical use | Preferences, client state | Sessions, server communication |
| Size | Larger than cookies in many browsers | Smaller |
| Security handling | Must protect against script access | Can use `HttpOnly`, `Secure`, `SameSite` |

Neither should be used casually for sensitive information.

---

# 56. Service Workers and Cache Confusion

A service worker can intercept requests and return cached responses.

This can cause confusion:

```text
You changed the backend,
but the browser continues displaying old data.
```

Possible causes:

- Browser cache
- CDN cache
- Service worker cache
- Application-level cache
- Backend cache

When debugging, identify which layer served the response.

```mermaid
flowchart TD
    R[Browser Request] --> SW{Service Worker?}
    SW -->|Cached| C[Cache Storage Response]
    SW -->|Not cached| N[Network Request]
    N --> CDN[CDN Cache]
    CDN -->|Miss| ORIGIN[Origin Server]
```

---

# 57. A Complete Frontend-to-Backend Investigation

Suppose clicking “Load Profile” produces no visible profile.

Use this sequence:

## Step 1: Check Console

Look for:

- JavaScript exceptions
- JSON parsing failures
- CORS errors
- Permission errors
- Failed module loading

## Step 2: Check Network panel

Filter by:

```text
Fetch/XHR
```

## Step 3: Find the profile request

Check:

```text
GET /api/profile
```

## Step 4: Inspect status

- No request: frontend issue
- `401`: authentication issue
- `403`: authorization issue
- `404`: route or resource issue
- `500`: backend issue
- `200`: inspect response and rendering

## Step 5: Inspect request headers

Check cookies or authorization.

## Step 6: Inspect response body

Verify the expected fields exist.

## Step 7: Inspect timing

Determine whether the server or network is slow.

## Step 8: Reproduce with cURL

Copy the request and test it independently.

## Step 9: Compare environments

Check whether the browser is calling:

```text
localhost
staging
production
```

by mistake.

---

# 58. Environment Mismatch Problems

A frequent issue is that the frontend and backend point to different environments.

For example:

```text
Frontend: production
API: local development
```

or:

```text
Frontend: localhost
API: production
```

Inspect the full Request URL.

Check:

- Protocol
- Host
- Port
- Path
- Environment variables
- Proxy configuration

```mermaid
flowchart LR
    F[Frontend Environment] --> URL[Configured API Base URL]
    URL --> DEV[Development API]
    URL --> STAGE[Staging API]
    URL --> PROD[Production API]
```

A request that works locally may fail in staging because:

- Credentials differ
- Database data differs
- CORS differs
- API versions differ
- Environment variables differ
- External services are configured differently

---

# 59. Browser Network Tools vs cURL vs API Clients

Each tool is useful for different questions.

| Tool | Best for |
|---|---|
| Browser Network panel | Seeing what the real frontend sends |
| Browser Console | Frontend errors and browser policy errors |
| cURL | Reproducible command-line requests |
| Postman | Interactive requests, environments, collections |
| Bruno | Local, file-based API collections |
| Server logs | Backend internals and failures |
| Database tools | Query and data investigation |

A practical workflow often combines them:

```mermaid
flowchart LR
    N[Network Panel] --> C[Copy Request]
    C --> CURL[cURL or API Client]
    CURL --> L[Compare with Server Logs]
    L --> DB[Inspect Data Layer]
```

---

# 60. The Evidence Hierarchy

When debugging, prioritize direct evidence.

Useful evidence includes:

1. Exact request URL
2. Exact HTTP method
3. Request headers
4. Request body
5. Status code
6. Response headers
7. Response body
8. Timing
9. Server logs
10. Database logs
11. External-service logs

Avoid relying only on assumptions such as:

```text
The button seems to be doing nothing.
```

Replace it with:

```text
The click handler runs, but no request is created.
```

or:

```text
POST /api/orders is sent, but the server returns 422 because quantity is a string.
```

Precise observations make solutions much faster.

---

# 61. Common Diagnostic Mistakes

## Mistake 1: Looking only at the Console

The Console may show a generic frontend error, while the Network panel reveals the real server response.

## Mistake 2: Looking only at the status code

A `200` response may contain invalid or unexpected application data.

## Mistake 3: Ignoring the request body

Many backend failures come from malformed payloads.

## Mistake 4: Assuming a `500` is a frontend problem

A `500` means the server or an upstream dependency failed.

## Mistake 5: Assuming no visible UI change means no request occurred

The request may have succeeded while the rendering logic failed.

## Mistake 6: Testing only through the UI

Manual API testing isolates the backend from frontend behavior.

## Mistake 7: Ignoring cookies and authentication headers

The browser may be authenticated while your manual request is not.

## Mistake 8: Sharing copied requests containing secrets

Redact:

- Cookies
- Bearer tokens
- API keys
- Passwords
- Personal information

---

# 62. Safe Redaction

Before sharing a request, replace secrets:

Original:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Cookie: session_id=real-secret
```

Redacted:

```http
Authorization: Bearer REDACTED
Cookie: session_id=REDACTED
```

Also redact:

- Email addresses
- Phone numbers
- User IDs where sensitive
- Payment information
- Private URLs
- Internal IP addresses
- Database connection strings

---

# 63. A Practical Diagnostic Checklist

When an API request fails, record:

```text
Request URL:
HTTP method:
Query parameters:
Status code:
Request headers:
Authentication present:
Request body:
Response headers:
Response body:
Timing:
Browser console errors:
Environment:
```

Then classify the failure:

```text
Frontend
Browser policy
DNS/network
TLS
Authentication
Authorization
Routing
Validation
Backend
Database
External service
Performance
Caching
```

This checklist is useful in personal debugging and when reporting an issue to another developer.

---

# 64. Final End-to-End Workflow

```mermaid
flowchart TD
    A[Reproduce the problem] --> B[Open Console and Network]
    B --> C[Clear old requests]
    C --> D[Perform one controlled action]
    D --> E[Find relevant request]
    E --> F[Inspect URL and method]
    F --> G[Inspect headers and body]
    G --> H[Inspect status and response]
    H --> I[Inspect timing and initiator]
    I --> J[Copy as cURL]
    J --> K[Reproduce outside browser]
    K --> L[Compare with server logs]
    L --> M[Identify failing layer]
    M --> N[Fix, retest, and verify]
```

The phrase **one controlled action** matters.

If you click repeatedly while inspecting many unrelated requests, it becomes difficult to identify which request corresponds to which behavior.

---

# 65. Part 5 Summary

In this part, we moved from theory to practical network inspection and diagnostics.

The most important ideas are:

- Network debugging begins with evidence.
- The browser Network panel shows the actual requests made by the frontend.
- The Console and Network panel should be used together.
- Preserve logs when debugging navigation and redirect flows.
- Disable cache when testing fresh resource behavior.
- Filter requests by Fetch/XHR, document, script, image, and other types.
- Inspect request URLs, methods, headers, query parameters, and payloads.
- Inspect response status codes, headers, body, and timing.
- A missing request often indicates a frontend problem.
- A `401` usually indicates missing or invalid authentication.
- A `403` usually indicates insufficient permission.
- A `404` usually indicates a missing route or resource.
- A `422` usually indicates validation failure.
- A `429` indicates rate limiting.
- A `500` or `5xx` response indicates a backend, gateway, or dependency problem.
- Network errors are different from HTTP error responses.
- TTFB helps identify delay before the server begins responding.
- Long download times may indicate large payloads or bandwidth limitations.
- cURL reproduces requests from the command line.
- Postman and Bruno provide interactive API testing environments.
- Copying a browser request as cURL helps isolate frontend problems from backend problems.
- Environment mismatches are common sources of failure.
- Cookies, tokens, CORS, redirects, service workers, and caches can affect results.
- API clients and browser tools complement each other.
- Secrets must be redacted before sharing requests.
- A disciplined workflow identifies the failing layer instead of relying on guesswork.

The central diagnostic model is:

```mermaid
flowchart TD
    U[User Action] --> F[Frontend]
    F --> R[HTTP Request]
    R --> N[Browser and Network]
    N --> S[Server]
    S --> D[(Database and Dependencies)]
    D --> S
    S --> RESP[HTTP Response]
    RESP --> F2[Frontend Processing]
    F2 --> UI[User Interface]

    R -.-> I1[Inspect Request]
    RESP -.-> I2[Inspect Response]
    S -.-> I3[Inspect Server Logs]
    D -.-> I4[Inspect Data and Dependencies]
```

A reliable debugging habit is:

```text
Observe the request.
Inspect the response.
Measure the timing.
Reproduce the behavior.
Identify the failing layer.
Then change the code.
```

That completes the core five-part series on:

```text
Web Mechanics
Architecture
Network Fundamentals
HTTP and HTTPS
API Design
Network Diagnostics
```

You now have a foundation for understanding what happens from the moment a user interacts with a browser to the moment a backend processes a request and returns a result.
