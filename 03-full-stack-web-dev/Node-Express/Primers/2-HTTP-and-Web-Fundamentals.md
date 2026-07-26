# PRIMER 2: HTTP and Web Fundamentals

## Welcome to the HTTP Primer!

Before you build web applications with Express, you need to understand **HTTP** — the protocol that powers the entire web. This primer will give you a solid understanding of how clients and servers communicate, what HTTP requests and responses look like, and how to work with them in Node.js.

### What This Primer Covers

| Section | Topic | What You'll Learn |
|---------|-------|-------------------|
| 1 | What Is HTTP? | The foundation of web communication |
| 2 | HTTP Requests | Methods, URLs, headers, bodies |
| 3 | HTTP Responses | Status codes, headers, bodies |
| 4 | Common Status Codes | 200, 404, 500 and more |
| 5 | HTTP Methods | GET, POST, PUT, DELETE, PATCH |
| 6 | Headers Explained | Content-Type, Authorization, etc. |
| 7 | Request/Response Cycle | Full lifecycle of a web request |
| 8 | REST API Basics | What makes an API "RESTful" |
| 9 | Working with HTTP in Node.js | Built-in http module |

---

## Section 1: What Is HTTP?

**HTTP** stands for **Hypertext Transfer Protocol**. It's the set of rules that governs how clients and servers communicate on the web.

### A Simple Analogy

Imagine you're ordering food at a restaurant:

| Step | Restaurant Analogy | HTTP Analogy |
|------|-------------------|--------------|
| 1 | You sit at a table | Client (browser) connects to server |
| 2 | You look at the menu | Browser requests a webpage |
| 3 | You tell the waiter what you want | Browser sends an HTTP request |
| 4 | The waiter takes your order to the kitchen | Server receives and processes the request |
| 5 | The kitchen prepares your food | Server processes the request |
| 6 | The waiter brings your food back | Server sends an HTTP response |
| 7 | You eat your meal | Browser renders the webpage |

### HTTP Versions

| Version | Year | Key Features |
|---------|------|--------------|
| HTTP/1.0 | 1996 | Basic request/response, one request per connection |
| HTTP/1.1 | 1997 | Persistent connections, chunked transfer, caching |
| HTTP/2 | 2015 | Multiplexing, server push, header compression |
| HTTP/3 | 2022 | UDP-based, faster, more reliable |

For this tutorial series, we'll use **HTTP/1.1**, which is still the most common version.

---

## Section 2: HTTP Requests

An HTTP request is what a client (browser, mobile app, etc.) sends to a server. It has four main parts:

### Anatomy of an HTTP Request

```
GET /api/users?page=2 HTTP/1.1        ← Request Line
Host: example.com                      ← Headers
User-Agent: Mozilla/5.0
Accept: application/json
Authorization: Bearer token123
                                       ← Empty line (separator)
{                                      ← Body (optional)
    "name": "Alice"
}
```

### 1. The Request Line

The request line contains three parts:

```
METHOD PATH?query HTTP/version
```

| Component | What It Is | Example |
|-----------|------------|---------|
| **Method** | The action the client wants to perform | `GET`, `POST`, `PUT`, `DELETE` |
| **Path** | The resource the client wants | `/users`, `/api/tasks/123` |
| **Query String** | Optional parameters | `?page=2&limit=10` |
| **HTTP Version** | Which HTTP version to use | `HTTP/1.1` |

### 2. Headers

Headers provide additional information about the request:

```http
Host: example.com                    # Which server to contact
User-Agent: Mozilla/5.0              # Client software
Accept: application/json             # What formats the client can handle
Content-Type: application/json       # What format the body is in
Content-Length: 42                   # Size of the body
Authorization: Bearer token123       # Authentication credentials
Cookie: sessionId=abc123             # Session information
Cache-Control: no-cache              # Caching instructions
```

### 3. The Body

The body contains data sent with the request (for methods like POST, PUT, PATCH):

```json
{
    "name": "Alice",
    "email": "alice@example.com",
    "password": "secret123"
}
```

Not all requests have a body. GET and DELETE requests typically don't.

### Building an HTTP Request in Code

```javascript
// Using Node.js http module
const http = require('http');

const options = {
    hostname: 'example.com',
    port: 80,
    path: '/api/users',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token123',
    }
};

const req = http.request(options, (res) => {
    console.log('Status:', res.statusCode);
    // Handle response...
});

// Write the request body
req.write(JSON.stringify({
    name: 'Alice',
    email: 'alice@example.com'
}));
req.end();
```

---

## Section 3: HTTP Responses

An HTTP response is what the server sends back to the client. It also has four main parts:

### Anatomy of an HTTP Response

```
HTTP/1.1 200 OK                      ← Status Line
Content-Type: application/json       ← Headers
Content-Length: 52
X-Request-Id: 12345
Cache-Control: no-cache
                                       ← Empty line (separator)
{                                      ← Body
    "success": true,
    "data": {
        "id": 1,
        "name": "Alice"
    }
}
```

### 1. The Status Line

```
HTTP/version status-code status-message
```

| Component | What It Is | Example |
|-----------|------------|---------|
| **HTTP Version** | Which HTTP version was used | `HTTP/1.1` |
| **Status Code** | A numeric code indicating the result | `200`, `404`, `500` |
| **Status Message** | A brief text description | `OK`, `Not Found`, `Internal Server Error` |

### 2. Headers

Response headers provide information about the response:

```http
Content-Type: application/json       # What format the body is in
Content-Length: 52                   # Size of the body
X-Request-Id: 12345                  # Custom headers (often for debugging)
Cache-Control: max-age=3600          # How long to cache
Set-Cookie: sessionId=abc123         # Set a cookie
Access-Control-Allow-Origin: *       # CORS (Cross-Origin Resource Sharing)
```

### 3. The Body

The body contains the actual data the server is sending back:

```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Alice",
        "email": "alice@example.com"
    }
}
```

### Sending a Response in Node.js

```javascript
// Using Node.js http module
const http = require('http');

const server = http.createServer((req, res) => {
    // Set status code and headers
    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('X-Request-Id', '12345');
    
    // Send the body
    res.end(JSON.stringify({
        success: true,
        data: {
            id: 1,
            name: 'Alice'
        }
    }));
});

server.listen(3000);
```

---

## Section 4: Common HTTP Status Codes

Status codes are organized into five classes:

### 1xx: Informational

| Code | Meaning | When to Use |
|------|---------|-------------|
| 100 | Continue | The server has received the request headers |
| 101 | Switching Protocols | The server is switching protocols |

### 2xx: Success

| Code | Meaning | When to Use |
|------|---------|-------------|
| **200** | OK | Everything worked! |
| **201** | Created | A new resource was created |
| 202 | Accepted | The request was accepted but not yet processed |
| **204** | No Content | Success but no body to return |

### 3xx: Redirection

| Code | Meaning | When to Use |
|------|---------|-------------|
| 301 | Moved Permanently | The resource has a new permanent URL |
| 302 | Found | Temporary redirect (use 307 instead) |
| 303 | See Other | Redirect to a different URL (POST → GET) |
| 307 | Temporary Redirect | Temporary redirect, preserve method |
| 308 | Permanent Redirect | Permanent redirect, preserve method |

### 4xx: Client Errors

| Code | Meaning | When to Use |
|------|---------|-------------|
| **400** | Bad Request | The request is malformed or invalid |
| **401** | Unauthorized | Authentication is required |
| **403** | Forbidden | Authenticated but not allowed |
| **404** | Not Found | The resource doesn't exist |
| 405 | Method Not Allowed | HTTP method isn't supported for this resource |
| 409 | Conflict | There's a conflict with the current state |
| 429 | Too Many Requests | Rate limit exceeded |

### 5xx: Server Errors

| Code | Meaning | When to Use |
|------|---------|-------------|
| **500** | Internal Server Error | Something went wrong on the server |
| 502 | Bad Gateway | The server received an invalid response |
| 503 | Service Unavailable | The server is temporarily overloaded |
| 504 | Gateway Timeout | The server timed out waiting for a response |

### Choosing the Right Status Code

```javascript
// Success
res.status(200).json({ data: users });          // GET successful
res.status(201).json({ data: newUser });        // POST successful
res.status(204).send();                          // DELETE successful

// Client errors
res.status(400).json({ error: 'Invalid input' });
res.status(401).json({ error: 'Unauthorized' });
res.status(403).json({ error: 'Forbidden' });
res.status(404).json({ error: 'Not found' });

// Server errors
res.status(500).json({ error: 'Internal error' });
```

---

## Section 5: HTTP Methods

HTTP methods (also called verbs) indicate what action the client wants to perform.

### Method Comparison

| Method | Safe? | Idempotent? | Has Body? | Use Case |
|--------|-------|-------------|-----------|----------|
| **GET** | ✅ Yes | ✅ Yes | ❌ No | Retrieve data |
| **POST** | ❌ No | ❌ No | ✅ Yes | Create new data |
| **PUT** | ❌ No | ✅ Yes | ✅ Yes | Replace entire resource |
| **PATCH** | ❌ No | ❌ No | ✅ Yes | Partial update |
| **DELETE** | ❌ No | ✅ Yes | ❌ Optional | Delete data |
| **HEAD** | ✅ Yes | ✅ Yes | ❌ No | Get headers only |
| **OPTIONS** | ✅ Yes | ✅ Yes | ❌ No | Get supported methods |

### Safe Methods

**Safe** methods don't modify data. GET, HEAD, OPTIONS are safe.

```javascript
// GET - Safe (doesn't change anything)
app.get('/users', (req, res) => {
    res.json(users); // Just reading data
});
```

### Idempotent Methods

**Idempotent** methods produce the same result regardless of how many times they're called.

```javascript
// DELETE - Idempotent
app.delete('/users/:id', (req, res) => {
    // Delete user with id 1
    // First call: user deleted
    // Second call: user already deleted (same result)
    res.sendStatus(204);
});

// PUT - Idempotent
app.put('/users/:id', (req, res) => {
    // Set user's name to "Alice"
    // First call: name = "Alice"
    // Second call: name = "Alice" (same result)
    res.json({ name: 'Alice' });
});

// POST - Not idempotent
app.post('/users', (req, res) => {
    // Create a new user
    // First call: creates user #1
    // Second call: creates user #2 (different result!)
    res.status(201).json({ id: newId });
});
```

### When to Use Which Method

```javascript
// GET - Retrieve
GET /users              // List all users
GET /users/1            // Get user with ID 1
GET /users/1/posts      // Get posts by user 1

// POST - Create
POST /users             // Create a new user
POST /users/1/posts     // Create a post for user 1

// PUT - Replace (full update)
PUT /users/1            // Replace entire user 1

// PATCH - Partial update
PATCH /users/1          // Update only some fields of user 1

// DELETE - Remove
DELETE /users/1         // Delete user 1
```

---

## Section 6: HTTP Headers

Headers are key-value pairs that provide metadata about the request or response.

### Common Request Headers

| Header | Example | Purpose |
|--------|---------|---------|
| `Host` | `example.com` | Which server to contact |
| `User-Agent` | `Mozilla/5.0` | Client software |
| `Accept` | `application/json` | What formats the client can handle |
| `Accept-Encoding` | `gzip, deflate` | What compression the client supports |
| `Content-Type` | `application/json` | Format of the request body |
| `Content-Length` | `42` | Size of the request body |
| `Authorization` | `Bearer token123` | Authentication credentials |
| `Cookie` | `sessionId=abc123` | Session information |
| `Cache-Control` | `no-cache` | Caching instructions |
| `Origin` | `https://example.com` | Where the request originated (CORS) |

### Common Response Headers

| Header | Example | Purpose |
|--------|---------|---------|
| `Content-Type` | `application/json` | Format of the response body |
| `Content-Length` | `52` | Size of the response body |
| `Set-Cookie` | `sessionId=abc123` | Set a cookie |
| `Cache-Control` | `max-age=3600` | How long to cache |
| `Location` | `/users/1` | Where the new resource is (for 201/301) |
| `Access-Control-Allow-Origin` | `*` | CORS |
| `X-Request-Id` | `12345` | Custom header (debugging) |

### Working with Headers in Express

```javascript
const express = require('express');
const app = express();

// Reading request headers
app.get('/headers', (req, res) => {
    const userAgent = req.get('User-Agent');
    const contentType = req.get('Content-Type');
    const auth = req.get('Authorization');
    
    console.log('User-Agent:', userAgent);
    console.log('Content-Type:', contentType);
    console.log('Authorization:', auth);
    
    // Check if client accepts JSON
    if (req.accepts('json')) {
        res.json({ message: 'JSON response' });
    } else if (req.accepts('html')) {
        res.send('<h1>HTML response</h1>');
    } else {
        res.send('Text response');
    }
});

// Setting response headers
app.get('/set-headers', (req, res) => {
    // Set individual headers
    res.set('X-Custom-Header', 'custom-value');
    res.set('X-Request-Id', '12345');
    
    // Or set multiple at once
    res.header({
        'X-Powered-By': 'Express',
        'X-Cache-Status': 'Miss'
    });
    
    res.json({ message: 'Headers set!' });
});

// Setting headers with status
app.get('/created', (req, res) => {
    res.status(201)
        .location('/users/1')
        .json({ message: 'Created' });
});
```

---

## Section 7: The Request/Response Cycle

Understanding the full lifecycle of a web request helps you debug and build better applications.

### Complete Cycle Diagram

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────▶│  Network │────▶│  Server  │
│ (Browser)│     │          │     │  (Node)  │
└──────────┘     └──────────┘     └──────────┘
      │               │                  │
      │ 1. User types URL               │
      │─────────────────────────────────▶│
      │ 2. Browser parses URL           │
      │ 3. DNS lookup                   │
      │ 4. TCP connection               │
      │ 5. HTTP request                 │
      │─────────────────────────────────▶│
      │                                 │ 6. Receives request
      │                                 │ 7. Parse request
      │                                 │ 8. Process request
      │                                 │ 9. Generate response
      │ 10. HTTP response               │
      │◀─────────────────────────────────│
      │ 11. Parse response              │
      │ 12. Render page                 │
      │◀─────────────────────────────────│
```

### Step-by-Step Breakdown

```javascript
// 1. User types a URL (or clicks a link)
// URL: https://example.com:3000/users/1?include=posts

// 2. Browser parses the URL
// Protocol: https
// Domain: example.com
// Port: 3000
// Path: /users/1
// Query: include=posts

// 3. DNS Lookup
// Browser asks DNS server: "What is the IP address of example.com?"
// DNS responds: "93.184.216.34"

// 4. TCP Connection
// Browser establishes a TCP connection to 93.184.216.34:3000

// 5. HTTP Request
// Browser sends an HTTP request:

GET /users/1?include=posts HTTP/1.1
Host: example.com:3000
User-Agent: Mozilla/5.0
Accept: application/json
Connection: keep-alive

// 6. Server receives the request
const server = http.createServer((req, res) => {
    // req.url = '/users/1?include=posts'
    // req.method = 'GET'
    // req.headers = { host: 'example.com:3000', ... }
    
    // 7. Parse the request
    const url = require('url').parse(req.url, true);
    const pathname = url.pathname; // '/users/1'
    const query = url.query; // { include: 'posts' }
    
    // 8. Process the request
    if (pathname === '/users/1') {
        const user = findUser(1);
        if (query.include === 'posts') {
            user.posts = findPostsByUser(1);
        }
        
        // 9. Generate response
        res.writeHead(200, {
            'Content-Type': 'application/json'
        });
        res.end(JSON.stringify(user));
    }
});

// 10. Client receives the response
// Status: 200 OK
// Headers: Content-Type: application/json
// Body: {"id":1,"name":"Alice",...}

// 11. Browser parses the response
// 12. Browser renders the page
```

---

## Section 8: REST API Basics

**REST** (Representational State Transfer) is an architectural style for designing web APIs.

### REST Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| **Resources** | Everything is a resource (nouns) | `users`, `posts`, `tasks` |
| **HTTP Methods** | Use HTTP methods to perform actions | GET, POST, PUT, DELETE |
| **Stateless** | Each request contains all needed info | No server-side session state |
| **Representations** | Resources can have multiple formats | JSON, XML, HTML |

### RESTful URL Design

```
Bad URL Design
GET /getAllUsers
POST /createUser
GET /getUserById?id=123
POST /updateUser/123
POST /deleteUser/123

Good RESTful Design
GET /users          → List all users
GET /users/123      → Get user 123
POST /users         → Create a user
PUT /users/123      → Replace user 123
PATCH /users/123    → Update user 123
DELETE /users/123   → Delete user 123
GET /users/123/posts → Get posts by user 123
POST /users/123/posts → Create post for user 123
```

### Example REST API Endpoints

```javascript
// User endpoints
GET    /api/users              // List users
GET    /api/users/:id          // Get user
POST   /api/users              // Create user
PUT    /api/users/:id          // Replace user
PATCH  /api/users/:id          // Update user
DELETE /api/users/:id          // Delete user

// Task endpoints (nested)
GET    /api/users/:id/tasks    // Get user's tasks
POST   /api/users/:id/tasks    // Create task for user
GET    /api/tasks/:id          // Get task
PUT    /api/tasks/:id          // Replace task
PATCH  /api/tasks/:id          // Update task
DELETE /api/tasks/:id          // Delete task

// Filtering and pagination
GET    /api/tasks?userId=1     // Filter by user
GET    /api/tasks?completed=true // Filter by status
GET    /api/tasks?page=2&limit=10 // Pagination
GET    /api/tasks?sort=createdAt // Sorting
GET    /api/tasks?search=express // Search
```

### REST Response Structure

```javascript
// Successful response
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Alice",
        "email": "alice@example.com"
    }
}

// List response with pagination
{
    "success": true,
    "data": [
        { "id": 1, "name": "Alice" },
        { "id": 2, "name": "Bob" }
    ],
    "pagination": {
        "page": 1,
        "limit": 10,
        "total": 42,
        "totalPages": 5
    }
}

// Error response
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid input provided",
        "details": [
            { "field": "email", "message": "Email is required" }
        ]
    }
}
```

---

## Section 9: Working with HTTP in Node.js

### The Built-in http Module

```javascript
// Simple HTTP server
const http = require('http');

const server = http.createServer((req, res) => {
    // Parse the URL
    const url = new URL(req.url, `http://${req.headers.host}`);
    
    console.log(`${req.method} ${url.pathname}`);
    console.log('Query:', url.searchParams);
    
    // Route handling
    if (req.method === 'GET' && url.pathname === '/') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('<h1>Home Page</h1>');
    } else if (req.method === 'GET' && url.pathname === '/api/users') {
        const users = [
            { id: 1, name: 'Alice' },
            { id: 2, name: 'Bob' }
        ];
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(users));
    } else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
    }
});

server.listen(3000, () => {
    console.log('Server running on http://localhost:3000');
});
```

### Making HTTP Requests

```javascript
// GET request
const http = require('http');

function getUsers() {
    return new Promise((resolve, reject) => {
        const req = http.get('http://example.com/api/users', (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    resolve(JSON.parse(data));
                } catch (error) {
                    reject(error);
                }
            });
        });
        
        req.on('error', reject);
        req.end();
    });
}

// POST request
function createUser(userData) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify(userData);
        const options = {
            hostname: 'example.com',
            port: 80,
            path: '/api/users',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length,
            },
        };
        
        const req = http.request(options, (res) => {
            let responseData = '';
            
            res.on('data', (chunk) => {
                responseData += chunk;
            });
            
            res.on('end', () => {
                try {
                    resolve(JSON.parse(responseData));
                } catch (error) {
                    reject(error);
                }
            });
        });
        
        req.on('error', reject);
        req.write(data);
        req.end();
    });
}
```

### Using Fetch in Node.js (v18+)

```javascript
// Node.js v18+ has built-in fetch
async function fetchUsers() {
    try {
        const response = await fetch('https://example.com/api/users');
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const users = await response.json();
        console.log('Users:', users);
        return users;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

// POST with fetch
async function createUser(userData) {
    const response = await fetch('https://example.com/api/users', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(userData),
    });
    
    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    return response.json();
}
```

---

## Practice Exercises

### Exercise 1: HTTP Request Analyzer

```javascript
// Create a function that analyzes an HTTP request
// and returns information about it

function analyzeRequest(req) {
    // Your code here
    // Return: { method, path, query, headers, hasBody }
}

// Test with a sample request object
const sampleReq = {
    method: 'POST',
    url: '/api/users?page=2',
    headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer token123'
    },
    // ... (body would be in req.body)
};

console.log(analyzeRequest(sampleReq));
```

### Exercise 2: Status Code Quiz

```javascript
// Write a function that takes a status code
// and returns the appropriate message

function getStatusMessage(code) {
    // Your code here
    // Examples:
    // 200 → "OK: Request successful"
    // 404 → "Not Found: Resource not found"
    // 500 → "Internal Server Error: Something went wrong"
}

console.log(getStatusMessage(200)); // OK: Request successful
console.log(getStatusMessage(404)); // Not Found: Resource not found
```

### Exercise 3: Simple HTTP Client

```javascript
// Create a simple HTTP client with retry logic

async function fetchWithRetry(url, options = {}, retries = 3) {
    // Your code here
    // Should retry on network errors and 5xx status codes
}

// Test
const data = await fetchWithRetry('https://api.example.com/users');
console.log(data);
```

### Exercise 4: REST API Design

```javascript
// Design RESTful endpoints for a blog application
// Describe the endpoints for:
// - Authors
// - Posts
// - Comments

// Your answer:
// GET  /api/authors
// GET  /api/authors/:id
// POST /api/authors
// ...

// Include:
// - HTTP method
// - URL pattern
// - Purpose
// - Request body (if any)
// - Response format
```

---

## Summary

You now have a solid understanding of HTTP and web fundamentals:

| Concept | Key Points |
|---------|------------|
| **HTTP** | Protocol for web communication |
| **Requests** | Method, URL, headers, body |
| **Responses** | Status code, headers, body |
| **Status Codes** | 2xx: Success, 4xx: Client errors, 5xx: Server errors |
| **Methods** | GET (read), POST (create), PUT (replace), PATCH (update), DELETE |
| **Headers** | Metadata for requests and responses |
| **REST** | Resources + HTTP methods = API design |
| **Node.js HTTP** | Built-in module for web servers |
