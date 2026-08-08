# Part 1: REST Architecture & HTTP Fundamentals

## Building the Foundation for Your API

Welcome to **Part 1** of the Django REST Framework & Next.js 16 masterclass. Before we write any code, we need to understand the fundamental concepts that power every REST API you'll ever build.

In this part, we'll cover:
- What an API is and why REST matters
- HTTP methods and their meanings
- HTTP status codes and when to use them
- Resource-oriented URL design
- JSON as the data exchange format

Think of this as learning the grammar of the language we'll speak between our frontend and backend. Just as you need to understand sentence structure before writing a novel, you need to understand HTTP and REST before building an API.

---

## What Is an API?

**API** stands for **Application Programming Interface**. In simple terms, it's a set of rules that allows different software applications to communicate with each other.

### The Restaurant Analogy

Imagine you're at a restaurant:
- **You (the client)** want food
- **The kitchen (the server)** has the food and knows how to prepare it
- **The waiter (the API)** takes your order, communicates it to the kitchen, and brings you your food

The API is the waiter. It knows:
- What you can order (the available endpoints)
- How to ask for it (the request format)
- What you'll get back (the response format)

### Why APIs Matter

APIs are everywhere in modern software:
- When your phone's weather app shows the forecast, it's calling a weather API
- When you log in to a website with Google, it's using Google's authentication API
- When a mobile app syncs your data, it's talking to a backend API

In this series, we're building our own API that will power both our web application and potentially mobile apps, desktop apps, or third-party integrations in the future.

---

## REST Principles

**REST** stands for **Representational State Transfer**. It's an architectural style for designing networked applications, not a protocol or standard.

### The 6 REST Constraints

REST defines 6 constraints that, when followed, create a well-designed API:

#### 1. Client-Server Separation
The client (frontend) and server (backend) are separate concerns. They can evolve independently as long as they agree on the API contract.

*In our application:* The Next.js frontend and Django backend can be updated separately as long as the API endpoints remain consistent.

#### 2. Statelessness
Each request from the client to the server must contain all the information needed to understand and process the request. The server doesn't store any session state between requests.

*Real-world analogy:* Every time you order at a restaurant, you give the waiter your full order. You don't say "bring me what I had last time."

*Implementation note:* This is why we'll use JWT tokens instead of Django sessions. Each request carries its own authentication.

#### 3. Cacheability
Responses must explicitly indicate whether they can be cached and for how long. Caching improves performance by reducing server load.

*Example:* A list of tasks might be cacheable for 5 minutes, but a task update request should never be cached.

#### 4. Uniform Interface
The API should have a consistent interface that makes it predictable and easy to use.

This includes:
- Resource identification in URLs (e.g., `/api/tasks/1/`)
- Manipulation through representations (we use JSON)
- Self-descriptive messages (HTTP methods and status codes)
- Hypermedia as the engine of application state (HATEOAS - we'll touch on this)

#### 5. Layered System
The architecture can have multiple layers (e.g., load balancers, caching servers, API gateways). Each layer only knows about the layer it's directly communicating with.

*In our architecture:* Nginx acts as a reverse proxy, forwarding requests to Django. Django talks to PostgreSQL and Redis. Each layer is isolated.

#### 6. Code on Demand (Optional)
Servers can extend client functionality by sending executable code. This is optional and rarely used in REST APIs.

### RESTful Resource Design

In REST, everything is a **resource**. A resource is any information that can be named:
- A user
- A project
- A task
- A comment

Resources are identified by **URIs** (Uniform Resource Identifiers), typically URLs.

#### Good URL Design
```
GET /api/users/              # List all users
GET /api/users/123/          # Get user 123
GET /api/users/123/projects/ # Get user 123's projects
GET /api/projects/456/tasks/ # Get tasks for project 456
```

#### Poor URL Design (Avoid This)
```
GET /api/getUser?id=123
GET /api/getUserProjects?userId=123
GET /api/api.php?action=getTasks&projectId=456
```

**Key Rule:** URLs should be nouns (resources), not verbs (actions).

---

## HTTP Fundamentals

HTTP (Hypertext Transfer Protocol) is the foundation of data communication on the web. It defines how messages are formatted and transmitted.

### The HTTP Request

Every HTTP request consists of:

1. **Method** (what action to perform)
2. **URL** (what resource to act on)
3. **Headers** (metadata about the request)
4. **Body** (optional data to send)

```
GET /api/tasks/ HTTP/1.1
Host: localhost:8000
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Accept: application/json
```

### The HTTP Response

Every HTTP response consists of:

1. **Status Code** (the result of the request)
2. **Headers** (metadata about the response)
3. **Body** (optional data returned)

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 512

{
    "id": 1,
    "title": "Build Django API",
    "status": "pending"
}
```

---

## HTTP Methods (Verbs)

HTTP defines several methods that indicate the desired action on a resource.

### GET - Retrieve Data

**Purpose:** Retrieve a representation of a resource
**Request Body:** No
**Response Body:** Yes (the representation)
**Idempotent:** Yes (multiple identical requests have the same effect)

```http
GET /api/tasks/ HTTP/1.1
Accept: application/json
```

**When to use:** Reading data, listing resources, fetching details

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

[
    {
        "id": 1,
        "title": "Build Django API",
        "completed": false
    },
    {
        "id": 2,
        "title": "Create Next.js frontend",
        "completed": false
    }
]
```

### POST - Create Data

**Purpose:** Create a new resource
**Request Body:** Yes (the resource data)
**Response Body:** Yes (the created resource, including server-generated IDs)
**Idempotent:** No (multiple POST requests create multiple resources)

```http
POST /api/tasks/ HTTP/1.1
Content-Type: application/json

{
    "title": "New task",
    "description": "Build the API"
}
```

**When to use:** Creating new resources, submitting forms

**Response:**
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
    "id": 3,
    "title": "New task",
    "description": "Build the API",
    "created_at": "2026-01-15T10:30:00Z"
}
```

### PUT - Replace Data

**Purpose:** Replace an entire resource or create it if it doesn't exist
**Request Body:** Yes (complete resource data)
**Response Body:** Optional
**Idempotent:** Yes

```http
PUT /api/tasks/3/ HTTP/1.1
Content-Type: application/json

{
    "title": "Updated task title",
    "description": "Updated description",
    "status": "completed"
}
```

**When to use:** Full updates where you replace the entire resource

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "id": 3,
    "title": "Updated task title",
    "description": "Updated description",
    "status": "completed"
}
```

### PATCH - Partial Update

**Purpose:** Partially update a resource
**Request Body:** Yes (partial data to update)
**Response Body:** Optional
**Idempotent:** No (in practice, yes if applied correctly)

```http
PATCH /api/tasks/3/ HTTP/1.1
Content-Type: application/json

{
    "status": "completed"
}
```

**When to use:** Partial updates where you only change specific fields

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
    "id": 3,
    "title": "Updated task title",
    "description": "Updated description",
    "status": "completed"
}
```

### DELETE - Remove Data

**Purpose:** Delete a resource
**Request Body:** No
**Response Body:** Optional
**Idempotent:** Yes

```http
DELETE /api/tasks/3/ HTTP/1.1
```

**When to use:** Removing resources

**Response:**
```http
HTTP/1.1 204 No Content
```

### Method Comparison Table

| Method | Action          | Body | Idempotent | Safe |
|--------|-----------------|------|------------|------|
| GET    | Retrieve        | No   | Yes        | Yes  |
| POST   | Create          | Yes  | No         | No   |
| PUT    | Replace/Create  | Yes  | Yes        | No   |
| PATCH  | Update          | Yes  | No*        | No   |
| DELETE | Delete          | No   | Yes        | No   |

*PATCH is not idempotent by standard, but a correctly implemented PATCH operation should be idempotent.

**Important terms:**
- **Safe:** The method doesn't modify resources (GET, HEAD, OPTIONS)
- **Idempotent:** Making the same request multiple times has the same effect as making it once

---

## HTTP Status Codes

Status codes indicate the result of the client's request. They're grouped by hundreds:

### 2xx - Success (The request worked)

| Code | Name                    | Meaning |
|------|-------------------------|---------|
| 200  | OK                      | The request succeeded |
| 201  | Created                 | A new resource was created |
| 204  | No Content              | Success but no response body |

### 3xx - Redirection (Further action needed)

| Code | Name                    | Meaning |
|------|-------------------------|---------|
| 301  | Moved Permanently      | Resource has a new URL |
| 302  | Found                   | Temporary redirect |
| 304  | Not Modified           | Cached version is still valid |

### 4xx - Client Error (The client made a mistake)

| Code | Name                    | Meaning |
|------|-------------------------|---------|
| 400  | Bad Request            | Malformed request |
| 401  | Unauthorized           | Authentication required |
| 403  | Forbidden              | Authenticated but not authorized |
| 404  | Not Found              | Resource doesn't exist |
| 405  | Method Not Allowed     | HTTP method not supported |
| 409  | Conflict               | Conflict with current state |
| 422  | Unprocessable Entity   | Validation errors |
| 429  | Too Many Requests      | Rate limit exceeded |

### 5xx - Server Error (The server made a mistake)

| Code | Name                    | Meaning |
|------|-------------------------|---------|
| 500  | Internal Server Error  | Generic server error |
| 502  | Bad Gateway            | Invalid upstream response |
| 503  | Service Unavailable    | Server is temporarily unavailable |
| 504  | Gateway Timeout        | Upstream timeout |

---

## JSON - JavaScript Object Notation

JSON is the format we'll use for data exchange between our frontend and backend. It's lightweight, human-readable, and language-agnostic.

### JSON Data Types

```json
{
    "string": "Hello World",
    "number": 42,
    "boolean": true,
    "null": null,
    "array": [1, 2, 3, "mixed"],
    "object": {
        "nested": "value"
    }
}
```

### JSON for API Responses

Our API will return JSON responses with a consistent structure:

```json
{
    "id": 1,
    "title": "Build Django API",
    "description": "Create the backend with DRF",
    "status": "pending",
    "priority": "high",
    "due_date": "2026-01-30T12:00:00Z",
    "created_at": "2026-01-15T10:30:00Z",
    "updated_at": "2026-01-15T10:30:00Z",
    "project": {
        "id": 5,
        "name": "Masterclass Project"
    },
    "assignee": {
        "id": 42,
        "username": "john_doe"
    }
}
```

### Error Response Format

A consistent error format helps frontend developers handle errors predictably:

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

---

## Designing Resource-Oriented URLs

### Collections and Items

Use plural nouns for collections:

```
/api/tasks/              # Collection of tasks
/api/tasks/1/            # Specific task (item)
/api/projects/           # Collection of projects
/api/projects/42/        # Specific project (item)
```

### Nested Resources

Nest resources that belong to others:

```
/api/projects/42/tasks/              # Tasks in project 42
/api/projects/42/tasks/1/            # Task 1 in project 42
/api/tasks/1/comments/               # Comments on task 1
```

### Filtering and Search

Use query parameters for filtering:

```
/api/tasks/?status=completed          # Filter by status
/api/tasks/?priority=high             # Filter by priority
/api/tasks/?search=deployment         # Search for deployment
/api/tasks/?ordering=-created_at      # Order by newest first
```

### API Versioning

Include version numbers for future compatibility:

```
/api/v1/tasks/
/api/v1/projects/
```

Or use headers:
```
Accept: application/vnd.myapi.v1+json
```

We'll use URL versioning in this series for clarity.

---

## The API Design Standards We'll Follow

Throughout this series, we'll design APIs that are:

### 1. Predictable
- Consistent naming conventions
- Similar patterns across resources

### 2. Resource-Oriented
- Nouns for URLs, not verbs
- HTTP methods for actions

### 3. Stateless
- Each request contains authentication
- No session state on the server

### 4. Well-Documented
- Clear endpoint descriptions
- Example requests and responses
- Error scenarios documented

### 5. Secure
- Authentication required for protected endpoints
- Authorization checks on every request
- Input validation
- Rate limiting

### 6. Testable
- Clear expected behaviors
- Consistent error responses

---

## HTTP Request/Response Flow Example

Let's trace a complete request from frontend to backend:

### 1. Frontend Makes a Request

```javascript
// Next.js component makes a request
const response = await fetch('http://localhost:8000/api/v1/tasks/', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIs...'
    },
    body: JSON.stringify({
        title: 'Complete Part 1',
        description: 'Finish HTTP fundamentals',
        priority: 'high',
        project_id: 5
    })
});
```

### 2. Backend Processes the Request

```python
# Django REST Framework view processes the request
def create(self, request):
    # 1. Authenticate the user from the token
    # 2. Validate the data
    # 3. Create the task in the database
    # 4. Return the response
```

### 3. Backend Returns a Response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
    "id": 123,
    "title": "Complete Part 1",
    "description": "Finish HTTP fundamentals",
    "priority": "high",
    "status": "pending",
    "created_at": "2026-01-15T12:00:00Z",
    "project": {
        "id": 5,
        "name": "Masterclass Project"
    },
    "assignee": {
        "id": 42,
        "username": "john_doe"
    }
}
```

### 4. Frontend Receives and Processes the Response

```javascript
if (response.ok) {
    const data = await response.json();
    // Update UI with the new task
    addTaskToList(data);
    showSuccess('Task created successfully!');
} else {
    const error = await response.json();
    // Display validation errors
    showErrors(error.fields);
}
```

---

## Key Takeaways

1. **REST is an architectural style**, not a standard. It's about principles:
   - Client-server separation
   - Statelessness
   - Cacheability
   - Uniform interface
   - Layered system

2. **Resources are the center of REST.** Everything is a noun: users, projects, tasks.

3. **HTTP methods are your verbs:**
   - GET = Read
   - POST = Create
   - PUT = Replace
   - PATCH = Update
   - DELETE = Delete

4. **Status codes tell you what happened:**
   - 2xx = Success
   - 4xx = Client error
   - 5xx = Server error

5. **JSON is our data format** for API requests and responses.

6. **URL design matters:** Use nouns, plurals for collections, and nested resources for relationships.

---

## Verification: Test Your Understanding

Before moving to Part 2, let's verify you understand these concepts.

### Concept Check Questions

1. **What HTTP method would you use to:**
   - Fetch a list of tasks? → `GET`
   - Create a new project? → `POST`
   - Update only the status field of a task? → `PATCH`
   - Delete a comment? → `DELETE`

2. **What status code would you expect:**
   - When a task is created successfully? → `201 Created`
   - When a client submits invalid data? → `422 Unprocessable Entity`
   - When a user is not authenticated? → `401 Unauthorized`
   - When a resource doesn't exist? → `404 Not Found`

3. **Which URL design is better and why:**
   ```
   a) /api/getTaskById?task_id=123
   b) /api/tasks/123/
   ```
   → **B is better** because it uses nouns (resources) rather than verbs, and uses the resource ID in the URL path.

4. **What's the difference between PUT and PATCH?**
   - `PUT` replaces the entire resource
   - `PATCH` updates only specified fields

### Hands-On Verification

Open your terminal and use `curl` to test a real API:

```bash
# Test the public JSONPlaceholder API
# This is a fake API for testing

# GET a list of todos
curl -X GET https://jsonplaceholder.typicode.com/todos/1

# POST a new todo
curl -X POST https://jsonplaceholder.typicode.com/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Test todo", "completed": false}'

# PUT to replace a todo
curl -X PUT https://jsonplaceholder.typicode.com/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated todo", "completed": true}'

# DELETE a todo
curl -X DELETE https://jsonplaceholder.typicode.com/todos/1
```

**Expected output:**
- GET should return a todo object with status 200
- POST should return the created todo with status 201
- PUT should return the updated todo with status 200
- DELETE should return empty response with status 200

---

## What's Next

In **Part 2**, we'll start building our Django backend. You'll learn:

- How to set up a Django project with proper configuration
- Configure PostgreSQL as our database
- Create our data models for users, projects, tasks, and comments
- Set up relationships between models
- Run migrations to create our database schema

We'll build the foundation that our API will be built on.

---

**End of Part 1**

*Next: Part 2 - Django 6 Backend Foundations*
