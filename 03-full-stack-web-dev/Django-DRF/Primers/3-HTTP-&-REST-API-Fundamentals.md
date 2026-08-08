# Primer 3: HTTP & REST API Fundamentals

## Essential HTTP and REST API Knowledge for the Masterclass

Welcome to **Primer 3** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to HTTP and REST API fundamentals before diving into the main series.

---

## Section 1: HTTP Fundamentals

### 1.1 What is HTTP?

HTTP (Hypertext Transfer Protocol) is the foundation of data communication on the web. It's a protocol that defines how messages are formatted and transmitted between clients and servers.

**Key Concepts:**
- **Client**: Makes requests (e.g., browser, mobile app)
- **Server**: Responds to requests (e.g., web server, API server)
- **Request**: Message sent from client to server
- **Response**: Message sent from server to client

### 1.2 HTTP Request Structure

```http
POST /api/v1/tasks/ HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36

{
    "title": "Complete API documentation",
    "status": "in_progress",
    "priority": "high"
}
```

**Parts of an HTTP Request:**
1. **Start Line**: Method + Path + HTTP Version
2. **Headers**: Metadata about the request
3. **Body**: Optional data (for POST, PUT, PATCH)

### 1.3 HTTP Response Structure

```http
HTTP/1.1 201 Created
Content-Type: application/json
Content-Length: 256
Cache-Control: no-cache

{
    "id": 123,
    "title": "Complete API documentation",
    "status": "in_progress",
    "priority": "high",
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

**Parts of an HTTP Response:**
1. **Status Line**: HTTP Version + Status Code + Status Message
2. **Headers**: Metadata about the response
3. **Body**: Optional data returned by the server

### 1.4 HTTP Methods

| Method | Purpose | Idempotent? | Safe? | Body |
|--------|---------|-------------|-------|------|
| **GET** | Retrieve data | Yes | Yes | No |
| **POST** | Create data | No | No | Yes |
| **PUT** | Replace data | Yes | No | Yes |
| **PATCH** | Partial update | No | No | Yes |
| **DELETE** | Remove data | Yes | No | No |
| **HEAD** | Get headers only | Yes | Yes | No |
| **OPTIONS** | Get supported methods | Yes | Yes | No |

**Idempotent**: Multiple identical requests have the same effect as one request.
**Safe**: Request doesn't modify server state.

### 1.5 HTTP Status Codes

**2xx - Success**
```
200 OK - Request succeeded
201 Created - Resource created
204 No Content - Success, no response body
```

**3xx - Redirection**
```
301 Moved Permanently - Resource moved permanently
302 Found - Resource moved temporarily
304 Not Modified - Use cached version
```

**4xx - Client Errors**
```
400 Bad Request - Invalid request
401 Unauthorized - Authentication required
403 Forbidden - Authenticated but not authorized
404 Not Found - Resource doesn't exist
405 Method Not Allowed - HTTP method not supported
409 Conflict - Conflict with current state
422 Unprocessable Entity - Validation error
429 Too Many Requests - Rate limit exceeded
```

**5xx - Server Errors**
```
500 Internal Server Error - Generic server error
502 Bad Gateway - Invalid upstream response
503 Service Unavailable - Server temporarily unavailable
504 Gateway Timeout - Upstream timeout
```

---

## Section 2: HTTP Headers

### 2.1 Request Headers

```http
# Authentication
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

# Content Type
Content-Type: application/json
Content-Type: application/x-www-form-urlencoded
Content-Type: multipart/form-data

# Accept (what the client can handle)
Accept: application/json
Accept: application/xml
Accept: text/html

# Language
Accept-Language: en-US,en;q=0.9

# Caching
Cache-Control: no-cache
Cache-Control: max-age=3600
If-None-Match: "etag-value"
If-Modified-Since: Wed, 21 Oct 2020 07:28:00 GMT

# User Information
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36

# Cookies
Cookie: session_id=abc123; user_pref=dark

# Cross-Origin
Origin: https://app.example.com
Referer: https://app.example.com/tasks
```

### 2.2 Response Headers

```http
# Content Information
Content-Type: application/json
Content-Length: 256
Content-Encoding: gzip

# Caching
Cache-Control: no-cache
Cache-Control: max-age=3600, must-revalidate
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2020 07:28:00 GMT

# Security
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
Strict-Transport-Security: max-age=31536000; includeSubDomains

# CORS
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
Access-Control-Max-Age: 86400

# Rate Limiting
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1700000000

# Cookies
Set-Cookie: session_id=abc123; HttpOnly; Secure; SameSite=Lax

# Server
Server: nginx/1.24.0
X-Powered-By: Django/6.0
```

---

## Section 3: REST API Fundamentals

### 3.1 What is REST?

REST (Representational State Transfer) is an architectural style for designing networked applications. It's not a protocol or standard, but a set of principles.

**Six REST Constraints:**
1. **Client-Server**: Separation of concerns
2. **Stateless**: No client context stored on server
3. **Cacheable**: Responses must indicate cacheability
4. **Uniform Interface**: Consistent API design
5. **Layered System**: Multiple layers (load balancers, caches)
6. **Code on Demand** (Optional): Server can extend client functionality

### 3.2 REST Principles in Practice

**Resource Identification:**
```http
# Resources are identified by URIs
GET /api/users/1
GET /api/projects/5
GET /api/tasks/3
GET /api/comments/12
```

**Resource Representations:**
```json
{
    "id": 1,
    "title": "Complete API documentation",
    "status": "in_progress",
    "created_at": "2026-01-15T12:00:00Z",
    "links": {
        "self": "/api/tasks/1",
        "project": "/api/projects/5",
        "comments": "/api/tasks/1/comments"
    }
}
```

**Stateless Communication:**
```http
# Each request contains all needed information
GET /api/tasks/1
Authorization: Bearer token
```

### 3.3 Resource-Oriented URLs

**Good URL Design:**
```
GET    /api/users              - List users
POST   /api/users              - Create user
GET    /api/users/{id}         - Get user
PUT    /api/users/{id}         - Replace user
PATCH  /api/users/{id}         - Update user
DELETE /api/users/{id}         - Delete user

GET    /api/users/{id}/projects - Get user's projects
GET    /api/projects/{id}/tasks - Get project's tasks
GET    /api/tasks/{id}/comments - Get task's comments
```

**Poor URL Design (Avoid):**
```
GET    /api/getUser?id=1
POST   /api/createUser
POST   /api/updateUser
POST   /api/deleteUser
GET    /api/getUserProjects?userId=1
```

### 3.4 API Versioning

**URL Versioning:**
```
GET /api/v1/tasks
GET /api/v2/tasks
```

**Header Versioning:**
```
Accept: application/vnd.myapi.v1+json
Accept: application/vnd.myapi.v2+json
```

**Query Parameter Versioning:**
```
GET /api/tasks?version=1
GET /api/tasks?version=2
```

### 3.5 Request and Response Formats

**JSON Request:**
```json
{
    "title": "Complete API documentation",
    "status": "in_progress",
    "priority": "high"
}
```

**JSON Response:**
```json
{
    "id": 123,
    "title": "Complete API documentation",
    "status": "in_progress",
    "priority": "high",
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

**Error Response:**
```json
{
    "success": false,
    "error": {
        "code": "validation_error",
        "message": "The request contained invalid data",
        "fields": {
            "title": ["This field is required."],
            "due_date": ["Date must be in the future."]
        }
    }
}
```

### 3.6 CRUD Operations with REST

| Operation | HTTP Method | URL | Request Body | Response |
|-----------|-------------|-----|--------------|----------|
| **Create** | POST | `/api/tasks/` | Task data | 201 Created |
| **Read (List)** | GET | `/api/tasks/` | None | 200 OK |
| **Read (Detail)** | GET | `/api/tasks/1/` | None | 200 OK |
| **Update (Full)** | PUT | `/api/tasks/1/` | Complete task | 200 OK |
| **Update (Partial)** | PATCH | `/api/tasks/1/` | Partial data | 200 OK |
| **Delete** | DELETE | `/api/tasks/1/` | None | 204 No Content |

### 3.7 Query Parameters (Filtering, Sorting, Pagination)

```http
# Filtering
GET /api/tasks?status=done
GET /api/tasks?priority=high
GET /api/tasks?status=in_progress&priority=high

# Search
GET /api/tasks?search=documentation

# Sorting
GET /api/tasks?ordering=-created_at
GET /api/tasks?ordering=priority,-created_at

# Pagination
GET /api/tasks?page=2
GET /api/tasks?page=2&page_size=50
GET /api/tasks?limit=20&offset=40

# Field Selection
GET /api/tasks?fields=id,title,status

# Combined
GET /api/tasks?status=done&search=api&ordering=-created_at&page=2
```

### 3.8 REST API Best Practices

**1. Use Nouns, Not Verbs**
```
✅ /api/users
✅ /api/users/1/projects
❌ /api/getUsers
❌ /api/getUserProjects
```

**2. Use Plural Nouns for Collections**
```
✅ /api/tasks
✅ /api/projects
❌ /api/task
❌ /api/project
```

**3. Use Proper HTTP Methods**
```
✅ GET /api/tasks/1
❌ POST /api/tasks/get/1
```

**4. Use Proper Status Codes**
```
✅ 201 Created
✅ 400 Bad Request
✅ 404 Not Found
❌ 200 with error body
```

**5. Use Consistent Error Format**
```json
{
    "success": false,
    "error": {
        "code": "error_code",
        "message": "Human readable message",
        "fields": {}
    }
}
```

**6. Use Versioning**
```
✅ /api/v1/tasks
✅ Accept: application/vnd.myapi.v1+json
```

**7. Use HATEOAS (Hypermedia)**
```json
{
    "id": 1,
    "title": "Task",
    "links": {
        "self": "/api/tasks/1",
        "project": "/api/projects/5",
        "comments": "/api/tasks/1/comments"
    }
}
```

### 3.9 REST vs Other API Styles

| Aspect | REST | GraphQL | gRPC |
|--------|------|---------|------|
| **Protocol** | HTTP | HTTP | HTTP/2 |
| **Data Format** | JSON/XML | JSON | Protocol Buffers |
| **Endpoint** | Multiple | Single | Multiple |
| **Over-fetching** | Common | Rare | Rare |
| **Under-fetching** | Common | Rare | Rare |
| **Caching** | Built-in | Not built-in | Not built-in |
| **Tooling** | Mature | Growing | Good |
| **Complexity** | Simple | Complex | Medium |

---

## Section 4: JSON Fundamentals

### 4.1 JSON Structure

```json
{
    "string": "Hello World",
    "number": 42,
    "boolean": true,
    "null": null,
    "array": [1, 2, 3, "mixed"],
    "object": {
        "nested": "value",
        "array_in_object": [1, 2, 3]
    }
}
```

### 4.2 JSON vs XML

**JSON:**
```json
{
    "user": {
        "name": "John Doe",
        "email": "john@example.com",
        "age": 30
    }
}
```

**XML:**
```xml
<user>
    <name>John Doe</name>
    <email>john@example.com</email>
    <age>30</age>
</user>
```

### 4.3 Working with JSON in Python

```python
import json

# JSON to Python (deserialization)
json_string = '{"name": "John", "age": 30}'
python_dict = json.loads(json_string)
print(python_dict["name"])  # John

# Python to JSON (serialization)
python_dict = {"name": "John", "age": 30}
json_string = json.dumps(python_dict)
print(json_string)  # {"name": "John", "age": 30}

# Pretty print
json_string = json.dumps(python_dict, indent=2)
print(json_string)
```

### 4.4 Working with JSON in JavaScript

```javascript
// JSON to JavaScript (parsing)
const jsonString = '{"name": "John", "age": 30}';
const jsObject = JSON.parse(jsonString);
console.log(jsObject.name); // John

// JavaScript to JSON (stringifying)
const jsObject = { name: "John", age: 30 };
const jsonString = JSON.stringify(jsObject);
console.log(jsonString); // {"name":"John","age":30}

// Pretty print
const jsonString = JSON.stringify(jsObject, null, 2);
```

---

## Section 5: Common API Patterns

### 5.1 Authentication Patterns

**Bearer Token:**
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**API Key:**
```http
X-API-Key: your-api-key
```

**Basic Authentication:**
```http
Authorization: Basic base64(username:password)
```

### 5.2 Rate Limiting Headers

```http
X-RateLimit-Limit: 100        # Max requests per window
X-RateLimit-Remaining: 95     # Requests remaining
X-RateLimit-Reset: 1700000000 # Reset time (Unix timestamp)
```

### 5.3 Pagination Formats

**Page-based:**
```json
{
    "count": 100,
    "next": "https://api.example.com/tasks?page=3",
    "previous": "https://api.example.com/tasks?page=1",
    "results": [...]
}
```

**Cursor-based:**
```json
{
    "next": "cursor-value",
    "previous": null,
    "results": [...]
}
```

### 5.4 Error Response Formats

```json
// Single error
{
    "error": "Invalid email format"
}

// Multiple errors
{
    "errors": {
        "email": ["Email is required", "Invalid email format"],
        "password": ["Password must be at least 8 characters"]
    }
}

// Standard error format
{
    "success": false,
    "error": {
        "code": "validation_error",
        "message": "Validation failed",
        "fields": {
            "email": ["Invalid email format"]
        }
    }
}
```

---

## Quick Reference Cards

### HTTP Status Codes

```
2xx Success
200 OK
201 Created
204 No Content

3xx Redirection
301 Moved Permanently
302 Found
304 Not Modified

4xx Client Error
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
405 Method Not Allowed
422 Unprocessable Entity
429 Too Many Requests

5xx Server Error
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

### Common HTTP Headers

```
Request:
Authorization
Content-Type
Accept
Cache-Control
User-Agent
Cookie
Origin

Response:
Content-Type
Content-Length
Cache-Control
ETag
Last-Modified
Set-Cookie
Access-Control-Allow-Origin
```

---

*This concludes Primer 3. You now have the essential HTTP and REST API knowledge needed for the masterclass.*
