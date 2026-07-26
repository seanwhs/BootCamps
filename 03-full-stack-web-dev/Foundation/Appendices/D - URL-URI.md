# Appendix D — URL, URI, and Encoding Reference  
## Schemes, Hosts, Ports, Paths, Query Strings, Fragments, Percent-Encoding, and URL Design

URLs are among the most visible parts of web development.

You type a URL into a browser:

```text
https://www.example.com/products/123?color=blue#reviews
```

The browser uses that URL to determine:

- Which protocol to use
- Which host to contact
- Which port to use
- Which resource or route to request
- Which optional parameters to send
- Which location to display after the response arrives

A URL is not merely a piece of text. It is a structured instruction for locating and accessing a resource.

```mermaid
flowchart LR
    A[URL] --> B[Scheme]
    A --> C[Authority]
    A --> D[Path]
    A --> E[Query]
    A --> F[Fragment]
```

A URL may contain:

```text
scheme://authority/path?query#fragment
```

For example:

```text
https://www.example.com:443/products/123?color=blue&sort=price#reviews
```

can be decomposed as:

```text
Scheme:   https
Host:     www.example.com
Port:     443
Path:     /products/123
Query:    color=blue&sort=price
Fragment: reviews
```

---

# 1. URL, URI, and URN

These terms are related but not identical.

## URL

URL means:

```text
Uniform Resource Locator
```

A URL identifies a resource and provides information about how to locate or access it.

Example:

```text
https://example.com/products
```

## URI

URI means:

```text
Uniform Resource Identifier
```

A URI identifies a resource.

A URL is generally considered a type of URI.

## URN

URN means:

```text
Uniform Resource Name
```

A URN identifies something by name rather than by location.

In everyday web development, you will most often work with URLs.

A practical simplified distinction is:

```text
URI = General resource identifier
URL = Identifier that also describes where or how to access it
URN = Name-based identifier
```

---

# 2. Complete URL Structure

Consider this URL:

```text
https://user:password@api.example.com:8443/v1/products/123?sort=price&limit=20#details
```

It contains:

```mermaid
flowchart TD
    U[Complete URL] --> S[Scheme: https]
    U --> AUTH[User Information: user:password]
    U --> H[Host: api.example.com]
    U --> P[Port: 8443]
    U --> PATH[Path: /v1/products/123]
    U --> Q[Query: sort=price&limit=20]
    U --> F[Fragment: details]
```

The parts are:

```text
Scheme:
  https

User information:
  user:password

Host:
  api.example.com

Port:
  8443

Path:
  /v1/products/123

Query:
  sort=price&limit=20

Fragment:
  details
```

## Security warning

Avoid putting usernames, passwords, API keys, tokens, or other secrets in URLs.

URLs may be recorded in:

- Browser history
- Server logs
- Proxy logs
- Analytics systems
- Referrer information
- Monitoring tools
- Screenshots
- Support tickets

---

# 3. The Scheme

The scheme identifies the protocol or access method.

Common schemes include:

```text
http
https
ftp
mailto
file
ws
wss
```

For web applications, the most important are:

```text
http://
https://
```

## HTTP

```text
http://example.com
```

HTTP does not provide transport encryption by itself.

## HTTPS

```text
https://example.com
```

HTTPS uses HTTP over TLS.

## WebSocket schemes

```text
ws://example.com
wss://example.com
```

`wss` is the secure WebSocket equivalent of `https`.

```mermaid
flowchart TD
    S[URL Scheme] --> HTTP[http]
    S --> HTTPS[https]
    S --> WS[ws]
    S --> WSS[wss]
    HTTP --> U[Unencrypted HTTP]
    HTTPS --> T[HTTP over TLS]
    WS --> W[WebSocket]
    WSS --> WT[WebSocket over TLS]
```

---

# 4. The Authority

The authority is the portion after the scheme and before the path.

Example:

```text
https://api.example.com:8443/products
       └──────────────────┘
            authority
```

The authority may contain:

- User information
- Host
- Port

Most ordinary URLs contain only:

```text
host[:port]
```

Example:

```text
example.com
example.com:8080
```

---

# 5. User Information in URLs

A URL can technically contain user information:

```text
https://username:password@example.com
```

This is generally discouraged.

Reasons include:

- Credentials may appear in logs.
- Browsers may warn about the format.
- Passwords may be exposed through history.
- Security tools may record the URL.
- Users may accidentally share the complete URL.

Prefer:

- Secure login forms
- Authorization headers
- Secure cookies
- OAuth flows
- Dedicated authentication protocols

Do not put access tokens in URL user information.

---

# 6. The Host

The host identifies the destination.

It may be:

- A domain name
- A subdomain
- An IPv4 address
- An IPv6 address
- `localhost`

Examples:

```text
example.com
api.example.com
localhost
127.0.0.1
```

A hostname can direct traffic to:

- A web server
- A load balancer
- A CDN
- An API gateway
- A development server
- A proxy

The host does not necessarily identify one permanent physical computer.

---

# 7. Domain Names and Subdomains

Consider:

```text
api.shop.example.com
```

Possible components:

```text
api       = Host or service label
shop      = Subdomain
example   = Registered domain
com       = Top-level domain
```

Common subdomains include:

```text
www.example.com
api.example.com
admin.example.com
cdn.example.com
docs.example.com
staging.example.com
```

Subdomains are often used to separate services or environments.

```mermaid
flowchart TD
    D[example.com] --> W[www.example.com]
    D --> API[api.example.com]
    D --> ADMIN[admin.example.com]
    D --> DOCS[docs.example.com]
    D --> STAGE[staging.example.com]
```

A subdomain may point to a completely different infrastructure system.

---

# 8. IPv4 Addresses in URLs

An IPv4 address can appear directly in a URL:

```text
http://192.0.2.10
```

With a port:

```text
http://192.0.2.10:8080
```

This bypasses the need to resolve a domain name, but it may cause issues with:

- TLS certificates
- Host-based routing
- Virtual hosting
- Application configuration
- Security policies

A certificate issued for:

```text
example.com
```

does not necessarily validate:

```text
192.0.2.10
```

---

# 9. IPv6 Addresses in URLs

IPv6 addresses contain colons, so URLs wrap them in square brackets.

Correct:

```text
http://[2001:db8::1]:8080/
```

Incorrect or ambiguous:

```text
http://2001:db8::1:8080/
```

The brackets separate the IPv6 address from the port.

```mermaid
flowchart LR
    A[http://[2001:db8::1]:8080/] --> B[Scheme: http]
    A --> C[IPv6 Host: 2001:db8::1]
    A --> D[Port: 8080]
    A --> E[Path: /]
```

---

# 10. The Port

A port identifies the service on a host.

Examples:

```text
http://example.com:80
https://example.com:443
http://localhost:3000
http://localhost:8080
```

Standard ports are often omitted.

These are generally equivalent:

```text
https://example.com
https://example.com:443
```

And:

```text
http://example.com
http://example.com:80
```

Development applications often use nonstandard ports:

```text
http://localhost:3000
http://localhost:5173
http://localhost:8000
```

The port can be understood as:

```text
Host = Which computer or network destination?
Port = Which service on that destination?
```

---

# 11. The Path

The path identifies a resource, route, or location within the host.

Examples:

```text
/
/products
/products/123
/users/42/orders
/docs/http/headers
```

The path does not necessarily refer to a physical file.

For example:

```text
/products/123
```

may cause a backend to:

1. Match a route.
2. Extract product ID `123`.
3. Query a database.
4. Build a response.

```mermaid
flowchart TD
    U[GET /products/123] --> R[Route Matcher]
    R --> I[Extract ID: 123]
    I --> D[(Database Query)]
    D --> O[Build Response]
```

---

# 12. Path Segments

A path is made of segments separated by `/`.

Example:

```text
/users/42/orders/9001
```

Segments:

```text
users
42
orders
9001
```

A segment may represent:

- A collection
- An identifier
- A nested resource
- A route category
- A file or directory
- A version

Possible interpretation:

```text
users       = collection
42          = user identifier
orders      = related collection
9001        = order identifier
```

---

# 13. Trailing Slashes

These URLs may be treated as different:

```text
https://example.com/products
https://example.com/products/
```

Some servers treat them as equivalent.

Others route them differently.

Inconsistent trailing-slash behavior can cause:

- Redirects
- Duplicate URLs
- Broken relative links
- Cache fragmentation
- API route mismatches

Choose a convention and apply it consistently.

---

# 14. Case Sensitivity in Paths

Hosts are generally handled case-insensitively.

Paths may be case-sensitive depending on the server and operating system.

These may be different:

```text
/products
/Products
/PRODUCTS
```

Likewise:

```text
/api/users
/api/Users
```

Do not assume that changing capitalization is harmless.

Use consistent lowercase paths unless the system specifically requires otherwise.

---

# 15. Path Parameters

A path parameter identifies a particular resource.

Example:

```text
/products/123
```

Here:

```text
123 = Product identifier
```

Another example:

```text
/users/42/orders/9001
```

Possible values:

```text
User ID: 42
Order ID: 9001
```

Path parameters are usually appropriate when the value identifies the primary resource being requested.

---

# 16. Query Strings

A query string begins with `?`.

Example:

```text
/products?category=keyboards&page=2
```

The query string contains:

```text
category=keyboards
page=2
```

Query parameters are commonly used for:

- Filtering
- Sorting
- Searching
- Pagination
- Optional behavior
- Feature selection
- Tracking

```mermaid
flowchart TD
    U[URL Query] --> A[category=keyboards]
    U --> B[page=2]
    U --> C[sort=price]
```

---

# 17. Query Parameter Names and Values

A query parameter usually follows:

```text
name=value
```

Multiple parameters are separated by `&`.

Example:

```text
/products?category=keyboards&sort=price&limit=20
```

Interpretation:

```text
category = keyboards
sort     = price
limit    = 20
```

The server should validate:

- Whether the parameter is supported
- Whether the value has the correct type
- Whether the value is within an allowed range
- Whether the caller is allowed to use it

---

# 18. Repeated Query Parameters

A query string may contain repeated parameter names:

```text
/products?tag=office&tag=wireless&tag=mechanical
```

This may represent:

```text
tag = ["office", "wireless", "mechanical"]
```

Some APIs instead use comma-separated values:

```text
/products?tag=office,wireless,mechanical
```

Others use array-style names:

```text
/products?tags[]=office&tags[]=wireless
```

There is no single universal convention. The API contract must define the expected format.

---

# 19. Query Parameters vs Request Bodies

Use query parameters when the data is:

- Small
- Non-sensitive
- Useful for identifying a variation of a request
- Suitable for bookmarking
- Suitable for caching

Examples:

```text
/search?q=networking
/products?page=2
/articles?sort=publishedAt
```

Use a request body when the data is:

- Larger
- Structured
- Sensitive
- State-changing
- A file or complex object

Examples:

```http
POST /api/orders
```

with:

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

Do not put passwords, access tokens, or sensitive personal data in query strings.

---

# 20. The Fragment

A fragment begins with `#`.

Example:

```text
https://example.com/docs#headers
```

The fragment usually identifies a location within the resource.

For a traditional webpage:

```text
#headers
```

may scroll the browser to:

```html
<section id="headers">
```

For a client-side application, the fragment may represent application state.

---

# 21. Fragments Are Usually Not Sent to the Server

Suppose the browser navigates to:

```text
https://example.com/page#section-2
```

The server generally receives:

```http
GET /page
```

It does not normally receive:

```text
#section-2
```

The browser uses the fragment after receiving the response.

```mermaid
sequenceDiagram
    participant U as User
    participant B as Browser
    participant S as Server

    U->>B: Opens /page#section-2
    B->>S: GET /page
    S-->>B: HTML response
    B->>B: Navigate to section-2
```

This is an important difference between query strings and fragments.

```text
Query string = Usually sent to server
Fragment     = Usually handled by browser
```

---

# 22. URL Fragments and Single-Page Applications

Some older single-page applications use fragments for client-side routing:

```text
https://example.com/#/products/123
```

The server receives only:

```text
/
```

The frontend JavaScript reads:

```text
#/products/123
```

and decides which interface to display.

Modern applications often use the History API instead:

```text
https://example.com/products/123
```

This creates cleaner URLs but requires server configuration so direct navigation still returns the application shell.

---

# 23. Reserved Characters

Some characters have special meanings in URLs.

Examples:

```text
: / ? # [ ] @
! $ & ' ( ) * + , ; =
```

Their meaning depends on where they appear.

For example:

```text
?
```

starts the query string.

```text
#
```

starts the fragment.

```text
&
```

separates query parameters.

If you need to use these characters as ordinary data, encode them.

---

# 24. Percent-Encoding

Percent-encoding represents characters using `%` followed by two hexadecimal digits.

Examples:

```text
Space       → %20
@           → %40
?           → %3F
#           → %23
&           → %26
/           → %2F
```

Example:

```text
/search?q=web%20fundamentals
```

represents:

```text
q = "web fundamentals"
```

Another example:

```text
/profile?email=alex%40example.com
```

represents:

```text
email = "alex@example.com"
```

```mermaid
flowchart LR
    A[Human Text] --> B[URL Encoding]
    B --> C[Percent-Encoded URL]
    C --> D[Server Decoding]
    D --> E[Original Value]
```

---

# 25. Why Encoding Is Necessary

Without encoding, data characters could be mistaken for URL structure.

Suppose a search value is:

```text
red & blue
```

If inserted incorrectly:

```text
/search?q=red & blue
```

the `&` may be interpreted as the beginning of another parameter.

Correct encoding:

```text
/search?q=red%20%26%20blue
```

The server decodes it as:

```text
red & blue
```

---

# 26. Spaces in URLs

Spaces are commonly encoded as:

```text
%20
```

Example:

```text
/search?q=web%20mechanics
```

In form-style query encoding, spaces may also appear as `+`:

```text
/search?q=web+mechanics
```

The exact behavior depends on the encoding function and context.

When using programming tools, prefer built-in URL and query-encoding utilities rather than manually replacing characters.

---

# 27. `encodeURIComponent` and `encodeURI`

In JavaScript, these functions have different purposes.

## `encodeURIComponent`

Use it to encode an individual component such as a query value.

```javascript
const query = encodeURIComponent("red & blue");
```

Result:

```text
red%20%26%20blue
```

Example:

```javascript
const url = `/search?q=${encodeURIComponent(searchText)}`;
```

## `encodeURI`

Use it for a larger URI while preserving some characters that form URI structure.

```javascript
const url = encodeURI("https://example.com/search?q=red blue");
```

For most query parameters, `URLSearchParams` is often clearer and safer.

---

# 28. `URL` and `URLSearchParams`

Modern JavaScript provides structured URL tools.

```javascript
const url = new URL("https://example.com/products");

url.searchParams.set("category", "mechanical keyboards");
url.searchParams.set("page", "2");

console.log(url.toString());
```

Possible result:

```text
https://example.com/products?category=mechanical+keyboards&page=2
```

Reading parameters:

```javascript
const category = url.searchParams.get("category");
```

Adding repeated values:

```javascript
url.searchParams.append("tag", "office");
url.searchParams.append("tag", "wireless");
```

This is safer than manually concatenating strings.

---

# 29. URL Encoding in Python

Python provides utilities for URL encoding.

```python
from urllib.parse import urlencode

params = {
    "category": "mechanical keyboards",
    "page": 2
}

query = urlencode(params)
print(query)
```

Possible result:

```text
category=mechanical+keyboards&page=2
```

Building a URL:

```python
url = f"https://example.com/products?{query}"
```

Use standard library functions rather than manually replacing spaces and symbols.

---

# 30. Query Parameter Injection Problems

Bad string concatenation can create incorrect or unsafe URLs.

Problematic example:

```javascript
const url = "/search?q=" + userInput;
```

If `userInput` contains:

```text
red & blue
```

the resulting URL may be interpreted incorrectly.

Safer:

```javascript
const params = new URLSearchParams({
  q: userInput
});

const url = `/search?${params}`;
```

Encoding protects URL structure, but it does not replace server-side validation.

---

# 31. URL Normalization

Different URLs may refer to equivalent or similar resources:

```text
https://example.com/products
https://example.com/products/
https://EXAMPLE.com/products
https://example.com:443/products
```

Applications may normalize:

- Host capitalization
- Default ports
- Trailing slashes
- Duplicate slashes
- Percent-encoding
- Dot segments

Normalization helps with:

- Consistent caching
- Canonical URLs
- Search indexing
- Duplicate-content prevention
- Routing

---

# 32. Dot Segments

Paths can contain special segments:

```text
.
..
```

Example:

```text
/a/b/../c
```

may normalize to:

```text
/a/c
```

And:

```text
/a/./b
```

may normalize to:

```text
/a/b
```

Applications and servers should handle path normalization carefully to avoid routing and security problems.

---

# 33. Double Encoding

Double encoding occurs when already encoded data is encoded again.

Original:

```text
red & blue
```

Encoded once:

```text
red%20%26%20blue
```

Encoded again:

```text
red%2520%2526%2520blue
```

Why?

```text
% becomes %25
```

Double encoding can cause:

- Incorrect search results
- Route mismatches
- Security filter bypasses
- File path confusion
- Authentication bugs

Encode once at the correct boundary and decode once at the correct boundary.

---

# 34. Path Encoding vs Query Encoding

Path and query components have different rules.

Example resource identifier:

```text
products/red & blue
```

The identifier should be encoded as a path segment:

```text
/products/red%20%26%20blue
```

A query value uses query encoding:

```text
/products?name=red+%26+blue
```

Do not treat an entire URL as one unstructured string.

Build each component appropriately.

---

# 35. Slugs

A slug is a human-readable identifier used in a URL.

Example:

```text
/articles/web-networking-fundamentals
```

Instead of:

```text
/articles/123
```

Slugs can improve readability and search visibility.

Potential concerns:

- Slug collisions
- Renaming
- Unicode characters
- Case normalization
- Long slugs
- Reserved words
- Historical redirects

A database may store both:

```text
id: 123
slug: web-networking-fundamentals
```

The ID remains stable while the slug may change.

---

# 36. Query Parameters for Filtering

Example:

```text
/products?category=keyboards&available=true
```

Possible interpretation:

```text
category = keyboards
available = true
```

The server should define:

- Supported filters
- Boolean formatting
- Case sensitivity
- Multiple-filter behavior
- Unknown-parameter behavior

---

# 37. Query Parameters for Pagination

Page-based:

```text
/products?page=2&limit=20
```

Offset-based:

```text
/products?offset=20&limit=20
```

Cursor-based:

```text
/products?after=cursor_abc&limit=20
```

```mermaid
flowchart LR
    A[Collection Request] --> B[Page Pagination]
    A --> C[Offset Pagination]
    A --> D[Cursor Pagination]
```

Cursor pagination is often more stable for changing datasets.

---

# 38. Query Parameters for Sorting

Examples:

```text
/products?sort=price
/products?sort=-price
/articles?sort=publishedAt&order=desc
```

The server should whitelist allowed sort fields.

Never assume that arbitrary query values can safely become database expressions.

---

# 39. Query Parameters for Searching

Example:

```text
/search?q=networking+fundamentals
```

A search API might support:

```text
/search?q=networking&language=en&limit=20
```

The API should define:

- Search syntax
- Maximum query length
- Case sensitivity
- Pagination
- Ranking
- Special characters
- Empty-search behavior

---

# 40. Sensitive Data in URLs

Avoid placing sensitive values in:

```text
Query strings
Path parameters
Fragments when sharing or logging is possible
```

Examples to avoid:

```text
/reset-password?token=secret
/account?ssn=123456789
/payment?cardNumber=...
```

URLs may appear in:

- Browser history
- Access logs
- Analytics
- Monitoring
- Referrer headers
- Proxy logs
- Screenshots

Prefer:

- POST bodies
- Secure cookies
- Authorization headers
- Short-lived, carefully managed links
- One-time tokens with appropriate controls

Even password-reset links require careful handling because they must be transmitted somehow. Use short-lived, single-use tokens and avoid unnecessary logging.

---

# 41. URL Length

There is no single universal maximum URL length across all browsers, servers, proxies, and tools.

Very long URLs may fail because of:

- Browser limits
- Proxy limits
- Web server limits
- CDN limits
- Logging limits
- Header size limits

Avoid placing large JSON structures in query strings.

Use a request body for complex or large submissions.

Bad:

```text
/search?filters={"category":"keyboards","price":{"min":10,"max":100}}
```

Better for complex operations:

```http
POST /search
Content-Type: application/json
```

with:

```json
{
  "filters": {
    "category": "keyboards",
    "price": {
      "min": 10,
      "max": 100
    }
  }
}
```

---

# 42. Relative URLs

A relative URL does not include the full scheme and host.

Examples:

```text
/products
/images/logo.png
../shared/styles.css
```

The browser resolves it relative to the current document.

If the current page is:

```text
https://example.com/shop/index.html
```

then:

```text
products
```

may resolve to:

```text
https://example.com/shop/products
```

Relative URLs are useful for same-site resources but can behave unexpectedly when the current path changes.

---

# 43. Absolute URLs

An absolute URL includes the complete location:

```text
https://cdn.example.com/images/logo.png
```

Absolute URLs are useful when:

- Referring to another domain
- Generating canonical links
- Sending links in emails
- Providing download URLs
- Communicating between services

---

# 44. Protocol-Relative URLs

An older style is:

```text
//example.com/resource.js
```

The browser uses the current page’s scheme.

If the page uses HTTPS, it becomes:

```text
https://example.com/resource.js
```

If the page uses HTTP, it becomes:

```text
http://example.com/resource.js
```

This pattern is generally less preferred today. Explicit HTTPS URLs are clearer and safer.

---

# 45. URL Design for REST APIs

Common resource-oriented patterns:

```text
GET    /products
GET    /products/123
POST   /products
PUT    /products/123
PATCH  /products/123
DELETE /products/123
```

Use paths to identify resources:

```text
/products/123
```

Use methods to communicate operations:

```text
GET
POST
PATCH
DELETE
```

Avoid unnecessary action names when ordinary HTTP semantics are sufficient:

```text
POST /create-product
POST /update-product
POST /delete-product
```

Some business actions do require explicit action routes:

```text
POST /orders/9001/cancellation
POST /invoices/42/approval
```

---

# 46. Versioning in URLs

Common URL versioning:

```text
/api/v1/products
/api/v2/products
```

Advantages:

- Easy to understand
- Easy to test
- Visible in logs
- Easy to route

Tradeoffs:

- Versions may multiply
- Clients may remain on old versions
- Shared resource URLs become more complex

Other approaches include header-based versioning and content negotiation.

---

# 47. Canonical URLs

A canonical URL is the preferred URL for a resource.

Possible duplicates:

```text
/products/123
/products?id=123
/products/123/
```

Applications may redirect alternatives to one canonical form:

```http
HTTP/1.1 301 Moved Permanently
Location: /products/123
```

Canonical URLs help with:

- Search indexing
- Caching
- Analytics
- Bookmark consistency
- Duplicate-content management

---

# 48. URL Debugging Checklist

When a request appears incorrect, inspect:

```text
Scheme:
Host:
Port:
Path:
Path parameters:
Query parameters:
Encoding:
Trailing slash:
Capitalization:
Redirects:
Environment:
```

Ask:

1. Is the scheme correct?
2. Is the request using HTTP or HTTPS as intended?
3. Is the host development, staging, or production?
4. Is the port correct?
5. Is the path spelled correctly?
6. Are identifiers present?
7. Are query parameters encoded?
8. Is the fragment being mistaken for a server parameter?
9. Is a redirect changing the URL?
10. Is a proxy rewriting the request?

---

# 49. Practical Browser Examples

Inspect the current page URL:

```javascript
console.log(window.location.href);
```

Read the path:

```javascript
console.log(window.location.pathname);
```

Read the query string:

```javascript
console.log(window.location.search);
```

Read the fragment:

```javascript
console.log(window.location.hash);
```

Parse query parameters:

```javascript
const params = new URLSearchParams(window.location.search);

console.log(params.get("page"));
console.log(params.get("category"));
```

Build a URL safely:

```javascript
const url = new URL("/products", window.location.origin);

url.searchParams.set("category", "mechanical keyboards");
url.searchParams.set("page", "2");

console.log(url.toString());
```

---

# 50. Practical cURL Examples

Request a URL:

```bash
curl "https://example.com/products?page=2"
```

Use a query parameter safely:

```bash
curl -G "https://example.com/products" \
  --data-urlencode "category=mechanical keyboards" \
  --data-urlencode "page=2"
```

Inspect redirects:

```bash
curl -I -L "http://example.com"
```

Request an IPv6 host:

```bash
curl "http://[2001:db8::1]:8080/"
```

Send JSON in a body instead of a long query string:

```bash
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"networking fundamentals"}' \
  "https://api.example.com/search"
```

---

# 51. Common URL Mistakes

## Mistake 1: Forgetting the scheme

```text
example.com/products
```

may be interpreted as a relative path in some contexts.

Use:

```text
https://example.com/products
```

## Mistake 2: Forgetting IPv6 brackets

Incorrect:

```text
http://2001:db8::1:8080
```

Correct:

```text
http://[2001:db8::1]:8080
```

## Mistake 3: Manually concatenating unencoded values

Bad:

```javascript
"/search?q=" + query
```

when `query` may contain `&`, `?`, `#`, or spaces.

## Mistake 4: Putting secrets in query strings

Query strings are widely logged.

## Mistake 5: Treating fragments as server parameters

The server usually does not receive the fragment.

## Mistake 6: Confusing path and query parameters

These may map to different backend routes:

```text
/products/123
/products?id=123
```

## Mistake 7: Ignoring trailing slash behavior

These may trigger different routes or redirects:

```text
/api/products
/api/products/
```

## Mistake 8: Double encoding values

Avoid encoding an already encoded string.

---

# 52. Complete URL Analysis Exercise

Analyze this URL:

```text
https://api.shop.example.com:8443/v2/users/42/orders?status=pending&limit=10#summary
```

Breakdown:

```text
Scheme:
  https

Host:
  api.shop.example.com

Port:
  8443

Path:
  /v2/users/42/orders

Path values:
  Version: v2
  User ID: 42

Query parameters:
  status = pending
  limit = 10

Fragment:
  summary
```

The server likely receives:

```http
GET /v2/users/42/orders?status=pending&limit=10 HTTP/1.1
Host: api.shop.example.com
```

The fragment is normally used only by the client:

```text
#summary
```

---

# 53. Final URL Mental Model

A URL is structured data:

```mermaid
flowchart TD
    U[URL] --> S[Scheme]
    U --> A[Authority]
    U --> P[Path]
    U --> Q[Query]
    U --> F[Fragment]

    A --> I[Optional User Info]
    A --> H[Host]
    A --> PO[Optional Port]
```

The browser uses it approximately like this:

```text
1. Read the scheme.
2. Identify the host and port.
3. Resolve the host through DNS if necessary.
4. Establish a connection.
5. Send the path and query in an HTTP request.
6. Keep the fragment for browser-side navigation.
```

The most important distinction is:

```text
Path:
  Usually identifies the resource or route.

Query:
  Usually modifies, filters, or configures the request.

Fragment:
  Usually identifies a client-side location within the response.
```

A well-designed URL is:

```text
Readable
Predictable
Consistent
Properly encoded
Free of secrets
Stable where possible
Compatible with the API contract
```

