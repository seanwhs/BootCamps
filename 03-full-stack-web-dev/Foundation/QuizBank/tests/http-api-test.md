# HTTP and API Test  
## HTTP, HTTPS, URLs, Requests, Responses, Status Codes, REST, GraphQL, RPC, Authentication, and API Design

This test evaluates understanding of:

- HTTP and HTTPS
- URLs
- HTTP methods
- Request and response anatomy
- Headers and bodies
- Status codes
- Cookies and sessions
- TLS
- REST
- API resources
- CRUD
- Pagination
- Filtering and sorting
- Authentication and authorization
- GraphQL
- RPC and gRPC
- JSON and serialization
- API errors
- Idempotency
- Caching
- API contracts
- Synchronous and asynchronous operations

---

## Test Instructions

- Complete the test before reading the answer key.
- Explain your reasoning for short-answer and scenario questions.
- For API design questions, multiple answers may be valid if the tradeoffs are explained.
- Use only APIs and systems you own or are authorized to test.
- Do not use real passwords, tokens, payment information, or private data.
- Distinguish HTTP-level success from business-level success.
- Treat browser clients and API consumers as potentially untrusted.

---

## Learning Objectives

After completing this test, you should be able to:

- Explain HTTP and HTTPS.
- Parse URLs.
- Describe HTTP request and response structures.
- Select appropriate HTTP methods.
- Interpret headers and payloads.
- Interpret common status codes.
- Explain cookies, sessions, and bearer tokens.
- Explain TLS at a high level.
- Design resource-oriented REST endpoints.
- Explain statelessness and idempotency.
- Design pagination and filtering.
- Compare REST, GraphQL, and RPC.
- Explain JSON serialization.
- Design consistent API errors.
- Identify authentication and authorization boundaries.
- Design synchronous and asynchronous API workflows.
- Evaluate API tradeoffs and compatibility.

---

# Part 1 — Multiple-Choice Questions

Choose the best answer.

## Question 1

What is HTTP?

- [ ] A protocol for exchanging messages between web clients and servers
- [ ] A database engine
- [ ] A programming language
- [ ] A filesystem

---

## Question 2

What does HTTPS add to HTTP?

- [ ] TLS protection
- [ ] A database
- [ ] A CSS framework
- [ ] A new filesystem

---

## Question 3

Which part of this URL is the scheme?

```text
https://api.example.com/products
```

- [ ] `https`
- [ ] `api.example.com`
- [ ] `/products`
- [ ] `products`

---

## Question 4

Which part is the host?

```text
https://api.example.com/products
```

- [ ] `https`
- [ ] `api.example.com`
- [ ] `/products`
- [ ] `/`

---

## Question 5

Which part is the path?

```text
https://api.example.com/products/123
```

- [ ] `https`
- [ ] `api.example.com`
- [ ] `/products/123`
- [ ] `123` only

---

## Question 6

Which part is the query string?

```text
/products?category=keyboards&page=2
```

- [ ] `/products`
- [ ] `category=keyboards&page=2`
- [ ] `keyboards`
- [ ] `page`

---

## Question 7

What does the fragment usually identify?

```text
/docs/http#headers
```

- [ ] A browser-side location or application state
- [ ] A server port
- [ ] A DNS resolver
- [ ] An authentication token

---

## Question 8

Is the fragment normally sent to the server in an HTTP request?

- [ ] Yes, always
- [ ] No, it is usually handled by the browser
- [ ] Only with `POST`
- [ ] Only with HTTP/3

---

## Question 9

What does `GET` typically mean?

- [ ] Retrieve a resource
- [ ] Delete a resource
- [ ] Replace a resource
- [ ] Create a user

---

## Question 10

What does `POST` commonly do?

- [ ] Submit data, create a resource, or trigger processing
- [ ] Retrieve headers without a body
- [ ] Always delete a resource
- [ ] Resolve DNS

---

## Question 11

What does `PUT` commonly represent?

- [ ] Full replacement of a resource
- [ ] Partial modification only
- [ ] Reading a collection
- [ ] Cookie storage

---

## Question 12

What does `PATCH` commonly represent?

- [ ] Partial modification of a resource
- [ ] Permanent redirection
- [ ] DNS lookup
- [ ] Full replacement only

---

## Question 13

What does `DELETE` commonly request?

- [ ] Removal of a resource
- [ ] Creation of a resource
- [ ] Retrieval of headers
- [ ] Compression

---

## Question 14

Which method commonly retrieves headers without the normal response body?

- [ ] `HEAD`
- [ ] `POST`
- [ ] `PATCH`
- [ ] `DELETE`

---

## Question 15

Which method is commonly used for CORS preflight requests?

- [ ] `OPTIONS`
- [ ] `GET`
- [ ] `PATCH`
- [ ] `TRACE`

---

## Question 16

Which part of an HTTP request contains metadata?

- [ ] Headers
- [ ] Body only
- [ ] Fragment only
- [ ] Port only

---

## Question 17

Which header describes the format of the request body?

- [ ] `Content-Type`
- [ ] `Accept`
- [ ] `Location`
- [ ] `ETag`

---

## Question 18

Which header describes response formats preferred by the client?

- [ ] `Accept`
- [ ] `Content-Type`
- [ ] `Cookie`
- [ ] `Set-Cookie`

---

## Question 19

Which header commonly carries a bearer token?

- [ ] `Authorization`
- [ ] `Content-Length`
- [ ] `Origin`
- [ ] `Age`

---

## Question 20

Which header tells a browser to store a cookie?

- [ ] `Set-Cookie`
- [ ] `Cookie`
- [ ] `Session`
- [ ] `Store-Auth`

---

## Question 21

Which header sends stored cookies to a server?

- [ ] `Cookie`
- [ ] `Set-Cookie`
- [ ] `Authorization-Cookie`
- [ ] `Session`

---

## Question 22

What does `2xx` generally mean?

- [ ] Success
- [ ] Redirection
- [ ] Client error
- [ ] Server error

---

## Question 23

What does `3xx` generally mean?

- [ ] Redirection or cache-related behavior
- [ ] Successful creation only
- [ ] Authentication failure
- [ ] Database failure

---

## Question 24

What does `4xx` generally indicate?

- [ ] A request, authentication, authorization, or resource problem
- [ ] Server success
- [ ] TLS negotiation
- [ ] Cache hit only

---

## Question 25

What does `5xx` generally indicate?

- [ ] Server or upstream failure
- [ ] Client-side validation success
- [ ] Permanent redirect
- [ ] Successful creation

---

## Question 26

What does `201 Created` indicate?

- [ ] A new resource was created
- [ ] The request was malformed
- [ ] Authentication is required
- [ ] The resource was not found

---

## Question 27

What does `202 Accepted` indicate?

- [ ] The request was accepted, but work may finish later
- [ ] The response was not modified
- [ ] The server rejected the request
- [ ] A resource was permanently deleted

---

## Question 28

What does `204 No Content` indicate?

- [ ] Success without a response body
- [ ] The server is unavailable
- [ ] Authentication failed
- [ ] A redirect is required

---

## Question 29

What does `304 Not Modified` indicate?

- [ ] The client may reuse a cached response
- [ ] The request created a resource
- [ ] The server crashed
- [ ] The resource was permanently deleted

---

## Question 30

What does `401 Unauthorized` usually indicate?

- [ ] Missing, invalid, or expired authentication
- [ ] Insufficient permission after authentication
- [ ] Missing route only
- [ ] Server overload

---

## Question 31

What does `403 Forbidden` usually indicate?

- [ ] The caller lacks permission
- [ ] Authentication is always absent
- [ ] The resource was created
- [ ] The body is too large

---

## Question 32

What does `404 Not Found` usually indicate?

- [ ] The requested route or resource could not be found
- [ ] DNS necessarily failed
- [ ] TLS necessarily failed
- [ ] The database is definitely unavailable

---

## Question 33

What does `409 Conflict` commonly indicate?

- [ ] A conflict with the current resource state
- [ ] A successful login
- [ ] A DNS cache hit
- [ ] A response compression issue

---

## Question 34

What does `422 Unprocessable Content` commonly indicate?

- [ ] The request is understood but fails validation or business rules
- [ ] The host cannot be resolved
- [ ] A permanent redirect occurred
- [ ] The server returned a cache hit

---

## Question 35

What does `429 Too Many Requests` indicate?

- [ ] Rate limiting
- [ ] Resource creation
- [ ] TLS success
- [ ] A missing file

---

## Question 36

What does `500 Internal Server Error` indicate?

- [ ] An unexpected server-side failure
- [ ] A successful request
- [ ] A browser cache hit
- [ ] A valid redirect

---

## Question 37

What does `502 Bad Gateway` commonly indicate?

- [ ] A gateway received an invalid response from an upstream service
- [ ] The client created a resource
- [ ] The user entered an invalid password
- [ ] The browser used a cached response

---

## Question 38

What does `503 Service Unavailable` commonly indicate?

- [ ] The service is temporarily unable to handle the request
- [ ] A resource was deleted
- [ ] A request was cached
- [ ] The client is authenticated

---

## Question 39

What does `504 Gateway Timeout` commonly indicate?

- [ ] A gateway waited too long for an upstream service
- [ ] A resource was created
- [ ] The request was validated
- [ ] The URL fragment was invalid

---

## Question 40

What does TLS provide?

- [ ] Confidentiality, integrity, and server authentication
- [ ] Database schema design
- [ ] HTML structure
- [ ] UI state management

---

## Question 41

What is REST?

- [ ] An architectural style for resource-oriented distributed systems
- [ ] A programming language
- [ ] A database engine
- [ ] A browser storage mechanism

---

## Question 42

What is a resource?

- [ ] Something represented or managed by an API
- [ ] Only a physical file
- [ ] A CPU process
- [ ] A shell variable

---

## Question 43

Which represents a product collection?

- [ ] `/products`
- [ ] `/product/123`
- [ ] `/create-product`
- [ ] `/products/123/edit-now`

---

## Question 44

Which represents one product?

- [ ] `/products`
- [ ] `/products/123`
- [ ] `/products?all=true`
- [ ] `/list-products`

---

## Question 45

What does CRUD stand for?

- [ ] Create, Read, Update, Delete
- [ ] Cache, Route, Upload, Download
- [ ] Client, Request, User, Database
- [ ] Compile, Run, Update, Deploy

---

## Question 46

What is GraphQL?

- [ ] A query language and runtime for APIs
- [ ] A database engine
- [ ] A CSS framework
- [ ] A command-line shell

---

## Question 47

What is RPC?

- [ ] Remote Procedure Call
- [ ] Resource Protocol Cache
- [ ] Request Permission Control
- [ ] Remote Page Content

---

## Question 48

What is serialization?

- [ ] Converting an in-memory value into transferable text or bytes
- [ ] Deleting a database row
- [ ] Resolving a DNS name
- [ ] Starting a server process

---

## Question 49

What is multipart form data useful for?

- [ ] Sending files and regular fields together
- [ ] Encrypting HTTP headers
- [ ] Creating DNS records
- [ ] Running database transactions

---

## Question 50

What is an API gateway?

- [ ] A service that can route, secure, transform, and aggregate API traffic
- [ ] A database table
- [ ] A browser tab
- [ ] A JSON object

---

# Part 2 — True or False

## Question 51

HTTP uses a request-response model.

- [ ] True
- [ ] False

## Question 52

HTTPS is HTTP protected by TLS.

- [ ] True
- [ ] False

## Question 53

The URL fragment is normally sent to the server.

- [ ] True
- [ ] False

## Question 54

A request body can contain JSON, form data, text, or binary content.

- [ ] True
- [ ] False

## Question 55

`Content-Type` describes the format of a message body.

- [ ] True
- [ ] False

## Question 56

`Accept` describes the request body format.

- [ ] True
- [ ] False

## Question 57

`401` and `403` generally describe different problems.

- [ ] True
- [ ] False

## Question 58

A `404` generally indicates that a reachable server could not find a route or resource.

- [ ] True
- [ ] False

## Question 59

A `500` proves DNS failed.

- [ ] True
- [ ] False

## Question 60

`304 Not Modified` is generally a normal cache-validation response.

- [ ] True
- [ ] False

## Question 61

A `POST` request is always idempotent.

- [ ] True
- [ ] False

## Question 62

`PUT` is generally intended to be idempotent.

- [ ] True
- [ ] False

## Question 63

A REST API can use pagination.

- [ ] True
- [ ] False

## Question 64

An API should expose all database columns by default.

- [ ] True
- [ ] False

## Question 65

Authentication and authorization are separate concerns.

- [ ] True
- [ ] False

## Question 66

A valid resource ID proves that the caller has access to that resource.

- [ ] True
- [ ] False

## Question 67

GraphQL commonly allows clients to select fields.

- [ ] True
- [ ] False

## Question 68

GraphQL may return an `errors` array even when the HTTP status is `200`.

- [ ] True
- [ ] False

## Question 69

RPC models communication around procedures or actions.

- [ ] True
- [ ] False

## Question 70

An asynchronous API may return before work is complete.

- [ ] True
- [ ] False

---

# Part 3 — Short-Answer Questions

## Question 71

What is HTTP?

---

## Question 72

What is the difference between HTTP and HTTPS?

---

## Question 73

Identify the components of:

```text
https://api.example.com:8443/v1/products/123?sort=price#details
```

---

## Question 74

What is the difference between a path parameter and a query parameter?

---

## Question 75

What does `GET /products` commonly represent?

---

## Question 76

What does `POST /products` commonly represent?

---

## Question 77

What does `PATCH /products/123` commonly represent?

---

## Question 78

What does `DELETE /products/123` commonly represent?

---

## Question 79

What is a request body?

---

## Question 80

What is a response body?

---

## Question 81

What is the difference between `401` and `403`?

---

## Question 82

What is the difference between `400` and `422`?

---

## Question 83

What is the difference between `404` and a DNS failure?

---

## Question 84

What does `201 Created` mean?

---

## Question 85

What does `202 Accepted` mean?

---

## Question 86

What does `304 Not Modified` mean?

---

## Question 87

What is a cookie?

---

## Question 88

What is a session?

---

## Question 89

What is a bearer token?

---

## Question 90

What do `Secure`, `HttpOnly`, and `SameSite` do for cookies?

---

## Question 91

What is REST?

---

## Question 92

What is statelessness?

---

## Question 93

What is idempotency?

---

## Question 94

Why are idempotency keys useful?

---

## Question 95

What is GraphQL?

---

## Question 96

What is a GraphQL schema?

---

## Question 97

What is RPC?

---

## Question 98

What is gRPC?

---

## Question 99

What is serialization?

---

## Question 100

What is the difference between synchronous and asynchronous API operations?

---

# Part 4 — API Design Questions

## Question 101

Classify each endpoint as primarily resource-oriented or action-oriented:

```text
GET /products
POST /products
POST /create-product
GET /orders/9001
POST /orders/9001/cancel
```

---

## Question 102

Map these operations to HTTP methods:

```text
List products
Retrieve product 123
Create a product
Partially update product 123
Delete product 123
```

---

## Question 103

Design an endpoint for products filtered by category and sorted by price.

---

## Question 104

Design an endpoint for page 3 with 20 products per page.

---

## Question 105

Design a cursor-based request for the next page of products.

---

## Question 106

What is wrong with this API response?

```json
{
  "id": 42,
  "email": "alex@example.com",
  "password_hash": "...",
  "internal_notes": "VIP",
  "role": "admin"
}
```

---

## Question 107

Why is this endpoint potentially dangerous?

```text
GET /delete-account
```

---

## Question 108

What is potentially problematic about this response?

```http
HTTP/1.1 200 OK
```

```json
{
  "error": "Payment failed"
}
```

---

## Question 109

Design a structured validation-error response for invalid `email` and `quantity` fields.

---

## Question 110

Design a response for an asynchronously generated report.

---

# Part 5 — Scenario Questions

## Question 111 — Resource-Oriented Design

A team creates:

```text
POST /get-products
POST /create-product
POST /update-product
POST /delete-product
```

What concerns might you raise?

Suggest a clearer design.

---

## Question 112 — Over-Fetching

A mobile client needs only a product’s name and thumbnail, but the API sends reviews, inventory history, internal metadata, and supplier information.

What problems can this cause?

What solutions are possible?

---

## Question 113 — Under-Fetching

A dashboard requires seven REST requests to display a user’s orders, products, and shipment status.

What problems might occur?

What solutions are possible?

---

## Question 114 — Duplicate Payment

A payment request times out after the provider may have processed it.

How can the API support safe retry behavior?

---

## Question 115 — Authorization

An authenticated user requests an order belonging to another user.

What must the backend check and return?

---

## Question 116 — Large Collection

An endpoint returns ten million products in one response.

What problems can this cause?

How should it be redesigned?

---

## Question 117 — GraphQL Query Abuse

A deeply nested GraphQL query causes excessive database work.

What protections could the server implement?

---

## Question 118 — RPC Operation

A service needs to expose:

```text
calculateShipping
```

Would RPC be reasonable? Could REST also model it? Explain.

---

## Question 119 — Public Developer API

A company is designing a public products-and-orders API.

Why might REST be attractive?

---

## Question 120 — Internal High-Volume Services

A company controls both sides of communication between internal services.

Why might gRPC be attractive?

---

## Question 121 — File Upload

A request contains:

```text
Product title
Product description
Product image
```

Which request format is appropriate?

---

## Question 122 — Breaking Change

An existing API returns:

```json
{
  "price": 79.99
}
```

The new API wants:

```json
{
  "price": {
    "amount": 7999,
    "currency": "USD"
  }
}
```

Why is this breaking?

What migration options exist?

---

## Question 123 — Database Table Exposure

A developer proposes exposing:

```text
/user_password_hashes
/internal_audit_events
/database_join_table
```

What concerns should you raise?

---

## Question 124 — Synchronous Dependencies

An order endpoint synchronously calls:

```text
Inventory
Payment
Tax
Email
Shipping
```

What risks does this create?

How could the design improve?

---

## Question 125 — API Gateway

Several services expose inconsistent public authentication and URL structures.

How might an API gateway help?

What risks or costs could it introduce?

---

# Part 6 — Practical Exercises

## Exercise 1 — REST Request

```bash
curl -i \
  -H "Accept: application/json" \
  https://api.example.com/products/123
```

Identify:

```text
Method
URL
Headers
Status
Response type
```

---

## Exercise 2 — Query Parameters

```bash
curl -G \
  -i \
  https://api.example.com/products \
  --data-urlencode "category=keyboards" \
  --data-urlencode "sort=price" \
  --data-urlencode "limit=20"
```

Explain the purpose of each parameter.

---

## Exercise 3 — JSON Creation

```bash
curl \
  -i \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Keyboard",
    "price": 79.99
  }' \
  https://api.example.com/products
```

Identify:

```text
Method
Body
Content type
Expected success status
Potential validation errors
```

---

## Exercise 4 — Validation Failure

Modify the body to:

```json
{
  "name": "",
  "price": -10
}
```

What should a well-designed API return?

---

## Exercise 5 — GraphQL Query

Construct a GraphQL query for:

```text
Product ID
Product name
Product price
Availability
```

Conceptual answer:

```graphql
query {
  product(id: "123") {
    id
    name
    price
    available
  }
}
```

Explain how it differs from REST.

---

## Exercise 6 — API Contract

Write a contract for:

```text
POST /api/orders
```

Include:

```text
Authentication
Request body
Success response
Validation errors
Authentication errors
Inventory conflicts
Idempotency behavior
```

---

# Answer Key

# Part 1 — Multiple-Choice Answers

| Question | Answer | Explanation |
|---:|---|---|
| 1 | A protocol for exchanging messages between web clients and servers | HTTP defines request and response communication. |
| 2 | TLS protection | HTTPS is HTTP over TLS. |
| 3 | `https` | This is the scheme. |
| 4 | `api.example.com` | This is the host. |
| 5 | `/products/123` | This is the path. |
| 6 | `category=keyboards&page=2` | This is the query string. |
| 7 | A browser-side location or application state | The fragment is usually client-side. |
| 8 | No, it is usually handled by the browser | Fragments are normally not sent to the server. |
| 9 | Retrieve a resource | `GET` is generally read-oriented. |
| 10 | Submit data, create a resource, or trigger processing | `POST` commonly submits or creates. |
| 11 | Full replacement of a resource | `PUT` commonly represents replacement. |
| 12 | Partial modification of a resource | `PATCH` commonly represents partial update. |
| 13 | Removal of a resource | `DELETE` requests removal. |
| 14 | `HEAD` | `HEAD` commonly retrieves headers without a body. |
| 15 | `OPTIONS` | Browsers commonly use it for preflight. |
| 16 | Headers | Headers contain metadata. |
| 17 | `Content-Type` | It describes the body format. |
| 18 | `Accept` | It describes preferred response formats. |
| 19 | `Authorization` | Bearer credentials are commonly sent there. |
| 20 | `Set-Cookie` | The server uses it to set browser cookies. |
| 21 | `Cookie` | The browser sends stored cookies there. |
| 22 | Success | `2xx` represents success. |
| 23 | Redirection or cache-related behavior | `3xx` tells the client to redirect or reuse a cache. |
| 24 | A request, authentication, authorization, or resource problem | `4xx` usually concerns the request or caller. |
| 25 | Server or upstream failure | `5xx` indicates server-side failure. |
| 26 | A new resource was created | `201` is common after creation. |
| 27 | Work was accepted but may finish later | `202` is useful for asynchronous operations. |
| 28 | Success without a response body | `204` contains no normal body. |
| 29 | Reuse a cached response | `304` means the cached representation remains valid. |
| 30 | Missing, invalid, or expired authentication | `401` concerns authentication. |
| 31 | The caller lacks permission | `403` concerns authorization. |
| 32 | The route or resource was not found | `404` is a valid server response. |
| 33 | A conflict with current resource state | `409` commonly represents conflicts. |
| 34 | Request values fail validation or business rules | `422` is a semantic validation error. |
| 35 | Rate limiting | `429` means too many requests. |
| 36 | Unexpected server-side failure | `500` is a general internal error. |
| 37 | Gateway received an invalid upstream response | `502` commonly involves a proxy or gateway. |
| 38 | Service temporarily cannot handle request | `503` may result from overload or maintenance. |
| 39 | Gateway waited too long for upstream | `504` indicates an upstream timeout. |
| 40 | Confidentiality, integrity, and server authentication | TLS protects the connection. |
| 41 | An architectural style for resource-oriented distributed systems | REST is not a programming language. |
| 42 | Something represented or managed by an API | Examples include users, products, and orders. |
| 43 | `/products` | This commonly identifies a collection. |
| 44 | `/products/123` | This commonly identifies one product. |
| 45 | Create, Read, Update, Delete | CRUD describes common operations. |
| 46 | A query language and runtime for APIs | GraphQL uses a typed schema. |
| 47 | Remote Procedure Call | RPC models remote actions or procedures. |
| 48 | Converting an in-memory value into transferable text or bytes | Serialization prepares data for transport. |
| 49 | Sending files and regular fields together | Multipart form data supports file uploads. |
| 50 | A service that can route, secure, transform, and aggregate API traffic | An API gateway is a controlled entry point. |

---

# Part 2 — True-or-False Answers

| Question | Answer | Explanation |
|---:|---|---|
| 51 | True | HTTP commonly uses request-response communication. |
| 52 | True | HTTPS is HTTP protected with TLS. |
| 53 | False | The fragment is normally handled by the browser. |
| 54 | True | Bodies can contain JSON, forms, text, or binary data. |
| 55 | True | `Content-Type` describes body format. |
| 56 | False | `Accept` describes preferred response formats. |
| 57 | True | `401` and `403` generally concern authentication and authorization respectively. |
| 58 | True | A reachable server may return `404` for a missing route or resource. |
| 59 | False | DNS may have succeeded before a server returned `500`. |
| 60 | True | `304` is a normal cache-validation response. |
| 61 | False | Repeated `POST` requests may create duplicates. |
| 62 | True | `PUT` is generally intended to be idempotent. |
| 63 | True | REST APIs commonly paginate collections. |
| 64 | False | APIs should expose only appropriate fields. |
| 65 | True | Identity and permission are separate concerns. |
| 66 | False | The server must check authorization independently. |
| 67 | True | GraphQL queries commonly select fields. |
| 68 | True | GraphQL may return `errors` alongside HTTP `200`. |
| 69 | True | RPC models communication around procedures. |
| 70 | True | Async operations may finish after the initial response. |

---

# Part 3 — Short-Answer Model Answers

## Question 71

HTTP is an application-layer protocol that defines how clients and servers exchange requests and responses.

---

## Question 72

HTTP does not provide the same transport protection as HTTPS. HTTPS is HTTP over TLS and provides confidentiality, integrity, and server authentication.

---

## Question 73

```text
Scheme:
  https

Host:
  api.example.com

Port:
  8443

Path:
  /v1/products/123

Query:
  sort=price

Fragment:
  details
```

---

## Question 74

A path parameter generally identifies a resource:

```text
/products/123
```

A query parameter generally filters, sorts, searches, or paginates:

```text
/products?sort=price
```

---

## Question 75

`GET /products` commonly represents the products collection.

---

## Question 76

`POST /products` commonly submits data to create a new product in the collection.

---

## Question 77

`PATCH /products/123` commonly partially updates product `123`.

---

## Question 78

`DELETE /products/123` commonly requests removal of product `123`.

---

## Question 79

A request body contains data sent by the client, such as JSON, form fields, uploaded files, plain text, or binary data.

---

## Question 80

A response body contains data returned by the server, such as JSON, HTML, text, images, PDFs, or other binary data.

---

## Question 81

`401` usually means authentication is missing, invalid, or expired. `403` usually means the caller is authenticated or identifiable but lacks permission.

---

## Question 82

`400` generally indicates malformed or invalid request structure. `422` generally indicates that the request is understood but values fail validation or business rules.

---

## Question 83

A `404` is a valid HTTP response from a reachable server indicating that a route or resource was not found. A DNS failure means the hostname could not be resolved, so an HTTP response may never have arrived.

---

## Question 84

`201 Created` indicates that the request succeeded and created a new resource. A `Location` header may identify it.

---

## Question 85

`202 Accepted` indicates that the request was accepted for processing but the operation may not yet be complete.

---

## Question 86

`304 Not Modified` tells the client to reuse its cached representation.

---

## Question 87

A cookie is a small value stored by a browser and sent with future matching requests. Cookies commonly store session identifiers and preferences.

---

## Question 88

A session represents an authenticated or ongoing interaction between a client and an application. It is often identified by a cookie containing a session ID.

---

## Question 89

A bearer token is a credential sent by a client, often through:

```http
Authorization: Bearer token
```

Possession of the token may grant access.

---

## Question 90

```text
Secure:
  Send only over HTTPS.

HttpOnly:
  Prevent normal page JavaScript from reading the cookie.

SameSite:
  Control cross-site cookie behavior.
```

---

## Question 91

REST is an architectural style that commonly models systems as resources identified by URLs, uses standard HTTP methods, and encourages stateless requests and cacheable responses.

---

## Question 92

Statelessness means each request includes enough information for the server to process it without depending on hidden temporary conversational state.

The application can still store users, orders, and other data.

---

## Question 93

Idempotency means repeating an operation produces the same intended final state.

---

## Question 94

Idempotency keys allow the server to recognize retries of the same logical operation and return the original result instead of repeating a payment, order, or reservation.

---

## Question 95

GraphQL is a query language and runtime that uses a schema and lets clients request a specific data shape.

---

## Question 96

A GraphQL schema defines available types, fields, arguments, queries, mutations, subscriptions, and relationships.

---

## Question 97

RPC, or Remote Procedure Call, models communication as calling a remote function or action.

---

## Question 98

gRPC is a strongly typed RPC framework commonly using Protocol Buffers, generated clients, HTTP/2, and streaming.

---

## Question 99

Serialization converts an in-memory value into transferable text or bytes. Deserialization converts it back into an in-memory value.

---

## Question 100

A synchronous operation waits for an immediate result. An asynchronous operation accepts work that may finish later, often using a queue, worker, and status endpoint.

---

# Part 4 — API Design Answers

## Question 101

```text
GET /products:
  Resource-oriented

POST /products:
  Resource-oriented

POST /create-product:
  Action-oriented

GET /orders/9001:
  Resource-oriented

POST /orders/9001/cancel:
  Action-oriented workflow
```

Action-oriented endpoints can be appropriate when a domain action does not fit ordinary CRUD cleanly.

---

## Question 102

```text
List products:
  GET /products

Retrieve product 123:
  GET /products/123

Create a product:
  POST /products

Partially update product 123:
  PATCH /products/123

Delete product 123:
  DELETE /products/123
```

---

## Question 103

One reasonable design:

```http
GET /products?category=keyboards&sort=price&order=asc
```

The API should document allowed fields and sorting behavior.

---

## Question 104

```http
GET /products?page=3&limit=20
```

---

## Question 105

```http
GET /products?limit=20&after=cursor_abc123
```

The cursor should normally be treated as an opaque server-generated value.

---

## Question 106

The response exposes sensitive and internal information:

```text
password_hash
internal_notes
possibly privileged role data
```

The API should map internal database records to a safe public representation.

---

## Question 107

`GET` should generally be safe and should not perform destructive operations. Browsers, crawlers, prefetchers, or accidental navigation could trigger account deletion.

Use an intentional state-changing method with authentication and appropriate CSRF protections.

---

## Question 108

The API returns an HTTP success status while communicating a business failure. Clients, caches, and monitoring systems may incorrectly interpret the request as successful.

Use a consistent documented error strategy, potentially with an appropriate non-2xx status.

---

## Question 109

Example:

```http
HTTP/1.1 422 Unprocessable Content
Content-Type: application/json
```

```json
{
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "One or more fields are invalid.",
    "fields": {
      "email": "Enter a valid email address.",
      "quantity": "Quantity must be greater than zero."
    }
  }
}
```

---

## Question 110

Example:

```http
HTTP/1.1 202 Accepted
Content-Type: application/json
Location: /api/jobs/job_123
```

```json
{
  "jobId": "job_123",
  "status": "queued"
}
```

The client can later request the job status.

---

# Part 5 — Scenario Model Answers

## Question 111 — Resource-Oriented Design

Concerns:

```text
The URLs use action verbs unnecessarily.
The HTTP method does not communicate the intended operation consistently.
Standard tools and caching semantics become less predictable.
```

A clearer design:

```http
GET    /products
POST   /products
GET    /products/123
PATCH  /products/123
DELETE /products/123
```

---

## Question 112 — Over-Fetching

Problems:

```text
Larger mobile payloads
Slower transfer
More parsing and memory use
Unnecessary data exposure
More backend work
```

Possible solutions:

```text
Field selection
Smaller representations
GraphQL
Backend-for-frontend
Dedicated mobile endpoint
Separate related-resource requests
```

---

## Question 113 — Under-Fetching

Problems:

```text
More round trips
Higher latency
More loading states
More partial-failure paths
More complicated client coordination
```

Solutions:

```text
Aggregation endpoint
Backend-for-frontend
GraphQL
Expanded REST representation
Client caching
```

---

## Question 114 — Duplicate Payment

Use an idempotency key:

```http
Idempotency-Key: payment-attempt-123
```

The server or payment provider should associate the key with the original result and return that result on a retry.

Use bounded retries, timeouts, and payment-status reconciliation.

---

## Question 115 — Authorization

The backend must verify:

```text
Authenticated identity
Resource ownership
Organization membership
Role or permission
```

It should deny access, commonly with `403 Forbidden` or a deliberately safe `404 Not Found`.

---

## Question 116 — Large Collection

Ten million products can cause:

```text
Huge response bodies
High database and serialization work
Memory pressure
Long download time
Browser failure
Increased cost
```

Use pagination, filters, sorting, indexes, and maximum page sizes.

---

## Question 117 — GraphQL Query Abuse

Use:

```text
Maximum query depth
Query complexity limits
Pagination
Timeouts
Rate limits
Resolver batching
Field authorization
Persisted queries
```

---

## Question 118 — RPC Operation

RPC is reasonable because `calculateShipping` is naturally an action.

REST could also model it as:

```http
POST /shipping-quotes
```

Both approaches can work. The choice depends on public API style, resource modeling, caching, and client expectations.

---

## Question 119 — Public Developer API

REST may be attractive because it offers:

```text
Familiar HTTP semantics
Simple resource URLs
Easy cURL access
Standard status codes
Broad tooling
Straightforward documentation
Useful caching behavior
```

---

## Question 120 — Internal High-Volume Services

gRPC may be attractive because it offers:

```text
Strong typing
Generated clients
Efficient binary serialization
HTTP/2
Streaming
Clear service contracts
```

---

## Question 121 — File Upload

Use:

```text
multipart/form-data
```

For large files, consider generating a presigned object-storage upload URL.

---

## Question 122 — Breaking Change

Existing clients expect `price` to be a number. Changing it to an object can cause parsing and calculation failures.

Migration options:

```text
Add a new field.
Support both forms temporarily.
Create an API v2.
Use content negotiation.
Deprecate the old field gradually.
Provide migration documentation.
```

---

## Question 123 — Database Table Exposure

Concerns include:

```text
Password hashes are highly sensitive.
Audit events may expose internal information.
Join tables are implementation details.
Database schema becomes public.
Authorization may be bypassed.
Clients become coupled to storage design.
```

Design API resources around domain needs instead.

---

## Question 124 — Synchronous Dependencies

Risks include:

```text
High latency
More timeout paths
Cascading failures
Partial-success complexity
Retry problems
Poor user experience
```

Improve the design by:

```text
Keeping only essential checks synchronous.
Moving email and analytics to queues.
Using bounded timeouts.
Using circuit breakers.
Tracking order state.
Using reconciliation for payment and shipping.
```

---

## Question 125 — API Gateway

A gateway can provide:

```text
One public entry point
Consistent authentication
Rate limiting
TLS termination
Routing
Versioning
Logging
Response aggregation
```

Costs and risks include:

```text
Bottleneck
Single failure point
More configuration
Centralized authorization risk
Harder debugging
Additional operational dependency
```

---

# Part 6 — Practical Exercise Guidance

## Exercise 1

```text
Method:
  GET

URL:
  https://api.example.com/products/123

Headers:
  Accept: application/json

Status:
  Depends on the API

Response type:
  Expected to be JSON if the API honors the request
```

---

## Exercise 2

```text
category=keyboards:
  Filters products.

sort=price:
  Selects the sort field.

limit=20:
  Limits the number of results.
```

The API should document ordering direction and maximum limits.

---

## Exercise 3

```text
Method:
  POST

Body:
  Product name and price

Content type:
  application/json

Expected success:
  Commonly 201 Created

Potential errors:
  400 malformed request
  401 authentication required
  403 permission denied
  422 validation failure
```

---

## Exercise 4

A well-designed API should generally return:

```http
422 Unprocessable Content
```

with structured field errors for empty name and negative price.

---

## Exercise 5

GraphQL allows the client to request selected fields in a query sent to a GraphQL endpoint. A REST client typically requests a representation through a resource-specific URL and receives the representation defined by that endpoint.

---

## Exercise 6

Example contract:

```text
Endpoint:
  POST /api/orders

Authentication:
  Required

Request:
  {
    "items": [
      {
        "productId": "123",
        "quantity": 2
      }
    ]
  }

Success:
  201 Created

Validation:
  422 Unprocessable Content

Authentication:
  401 Unauthorized

Authorization:
  403 Forbidden where applicable

Inventory conflict:
  409 Conflict

Idempotency:
  Idempotency-Key required or recommended for retries
```

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
  Correct definition with an example.

4 points:
  Correct explanation, example, tradeoff, and security or compatibility consideration.
```

## API design questions

Evaluate:

```text
Resource clarity
HTTP method semantics
Parameter placement
Validation
Authentication
Authorization
Error handling
Pagination
Versioning
Caching
Idempotency
```

## Scenario questions

Evaluate whether the learner:

```text
Identifies the API boundary
Treats consumers as untrusted
Recognizes authoritative data
Understands retry risks
Considers failure behavior
Explains tradeoffs
```

---

# Review Recommendations

If you struggled with:

```text
HTTP and HTTPS:
  Part 3
  Appendix B
  Appendix C
  Appendix D

REST and API design:
  Part 4, Sections 1–35

GraphQL:
  Part 4, Sections 36–46

RPC and gRPC:
  Part 4, Sections 47–57

Serialization:
  Part 4, Sections 58–72

API testing:
  Appendix G

REST, GraphQL, and RPC comparison:
  Appendix H
```

---

# Completion Criteria

You are ready to continue when you can:

```text
Explain HTTP and HTTPS.
Parse URLs.
Interpret methods, headers, bodies, and status codes.
Design resource-oriented REST endpoints.
Explain authentication and authorization.
Explain statelessness and idempotency.
Design pagination and filtering.
Design consistent errors.
Compare REST, GraphQL, and RPC.
Explain JSON serialization.
Design synchronous and asynchronous API workflows.
Identify API compatibility risks.
Avoid exposing internal database structure.
```
