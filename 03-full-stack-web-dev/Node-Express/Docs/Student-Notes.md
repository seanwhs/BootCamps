# Node.js + Express Tutorial Series
## Complete Student Notes

### A Comprehensive Reference Guide for the Entire Series

---

# PART 0: INTRODUCTION

## What This Series Is About

This tutorial series takes you from absolute beginner to building and deploying real web applications with Node.js and Express.

### Key Points

- **Starts from fundamentals** - No prior knowledge assumed
- **Explains every concept** - Plain language with real-world analogies
- **Complete code** - No placeholders, fully working examples
- **Hands-on learning** - Code along with every example
- **Builds a real app** - Complete task management application

### What You'll Need

1. A computer (Windows, macOS, or Linux)
2. Visual Studio Code (recommended code editor)
3. Node.js (JavaScript runtime)
4. Terminal/command prompt
5. A web browser
6. Curiosity and patience

### The Architecture You'll Build

```
Your Application
├── HTTP Server (Port 3000)
│   └── Listens for requests, sends responses
├── Express Application
│   ├── Middleware Pipeline
│   │   ├── Logger
│   │   ├── Static file server
│   │   ├── JSON parser
│   │   ├── URL-encoded parser
│   │   └── Error handler
│   ├── Routing Layer
│   │   ├── / → Homepage
│   │   ├── /about → About page
│   │   └── /api/tasks → Task API
│   ├── Controller Layer
│   │   ├── HomeController
│   │   └── TaskController
│   └── Storage Layer
│       ├── In-memory array
│       └── File-based persistence
└── Frontend (HTML/CSS/JS)
```

### Restaurant Analogy

| Component | Restaurant Equivalent |
|-----------|----------------------|
| Server | Restaurant's front door |
| Express Application | The restaurant itself |
| Middleware | Sequence of stations |
| Routing | The menu |
| Controller | Kitchen staff |
| Storage | The pantry |

### Learning Roadmap

| Part | Topic | What You'll Build |
|------|-------|-------------------|
| 1 | What Is a Server? | Hello World script |
| 2 | Your First HTTP Server | HTTP server with http module |
| 3 | Meet Express | Basic Express server |
| 4 | Routing and URL Data | Message board with routes |
| 5 | Middleware Explained | App with logging, auth |
| 6 | Handling Forms and JSON | Contact form with validation |
| 7 | Structuring a Real App | Organized codebase |
| 8 | Simple Persistence and CRUD | Task API with CRUD |
| 9 | Error Handling and Safety | Robust API with error handling |
| 10 | Final Project and Deployment | Complete task manager app |

### The Final Application: TaskMaster

**Frontend Features:**
- Clean HTML page listing tasks
- Form for creating new tasks
- Buttons to complete or delete tasks
- Ability to edit existing tasks

**Backend Features:**
- Serves HTML, CSS, JavaScript
- REST API for CRUD operations
- Validates incoming data
- Handles errors gracefully
- Stores tasks persistently

**Tech Stack:**
- Node.js - JavaScript runtime
- Express - Web framework
- Nodemon - Auto-restart server
- Dotenv - Environment variables
- File system (fs) - File storage

---

# PART 1: WHAT IS A SERVER?

## The Client-Server Model

### Definition
The client-server model is a distributed application structure where clients request services from servers.

### Restaurant Analogy
1. You enter the restaurant (Client)
2. You look at the menu (Website)
3. You tell the waiter your order (HTTP Request)
4. Waiter takes order to kitchen (Server)
5. Kitchen prepares food (Server processing)
6. Waiter brings food back (HTTP Response)
7. You enjoy your meal (Browser renders)

### Web Terms Version
1. You type a URL into your browser (Client)
2. Browser sends an HTTP request to the server
3. Server receives and processes the request
4. Server sends back an HTTP response (HTML, CSS, JS)
5. Browser receives the response and renders the webpage

## Why We Need Servers

1. **Hold the Data** - Central storage accessible from anywhere
2. **Do Heavy Lifting** - Complex calculations and processing
3. **Keep Things Consistent** - All users see the same data
4. **Handle Security** - Authentication, authorization, data protection
5. **Enable Sharing** - Multiple users access simultaneously

## What Is Node.js?

### Definition
Node.js is a JavaScript runtime that allows JavaScript to run outside the browser.

### History
- 1995: JavaScript created for browsers
- 2009: Ryan Dahl created Node.js
- Took Google's V8 JavaScript engine
- Made it work outside the browser

### What Node.js Gives Us
- Access files on the server's hard drive
- Create database connections
- Listen for incoming network requests
- Do everything servers need to do

### Why Node.js Is Popular

| Feature | Benefit |
|---------|---------|
| JavaScript Everywhere | Same language frontend and backend |
| Non-Blocking I/O | Handles many connections efficiently |
| Fast Execution | V8 engine compiles to machine code |
| Huge Ecosystem | npm has millions of packages |
| Active Community | Rapid evolution and support |

### Node.js Use Cases
- Web servers
- REST APIs
- Real-time applications
- Command-line tools
- Microservices
- Data processing

## Installing Node.js

1. Go to nodejs.org
2. Choose LTS version (stable, recommended)
3. Download installer for your OS
4. Run the installer
5. Verify installation:

```bash
node -v  # Should show version like v18.17.0
npm -v   # Should show version like 9.6.7
```

## Your First Node.js Program

### Create hello.js
```javascript
console.log("Hello, Node.js!");

const number1 = 10;
const number2 = 20;
const sum = number1 + number2;
console.log("The sum is:", sum);

console.log("Node version:", process.version);
console.log("Current directory:", process.cwd());
```

### Run the Program
```bash
node hello.js
```

### Key Node.js Global Objects

| Object | Description |
|--------|-------------|
| process | Information about the running process |
| console | Print to the terminal |
| __dirname | Current directory path |
| __filename | Current file path |
| global | Global object (like window in browsers) |

## Understanding npm

npm = Node Package Manager

### What Are Packages?
A package is a collection of reusable code written by someone else.

### Common npm Commands

| Command | Purpose |
|---------|---------|
| npm init -y | Initialize a new project |
| npm install express | Install a package |
| npm install --save-dev nodemon | Install a development package |
| npm install | Install all dependencies |
| npm uninstall express | Uninstall a package |
| npm update | Update all packages |

### package.json
The package.json file is your project's ID card. It tells Node.js and other developers what your project is, what it needs, and how to run it.

## Browser JavaScript vs Node.js

| Browser JavaScript | Node.js JavaScript |
|-------------------|-------------------|
| Runs in the browser | Runs on the server |
| Can access DOM, window | Cannot access DOM, window |
| Manipulates HTML/CSS | Cannot manipulate web pages |
| Limited file system access | Full file system access |
| Waits for user interaction | Runs as a service |
| Used for UI interactions | Used for data processing, APIs |

### What They Share
- Same JavaScript language syntax
- ES6+ features (const, let, arrow functions)
- Core concepts (variables, loops, functions, objects)
- console.log() for debugging

---

# PART 2: YOUR FIRST HTTP SERVER

## What Is an HTTP Server?

An HTTP server is a program that:
1. Listens for incoming network connections on a specific port
2. Receives HTTP requests from clients
3. Processes those requests
4. Sends HTTP responses back to the client

### Analogy: Restaurant Receptionist
- Wait by the phone (listen on a port)
- Answer calls (HTTP request)
- Figure out what caller wants (process)
- Give information (HTTP response)

## What Is HTTP?

HTTP = Hypertext Transfer Protocol

The set of rules that govern how clients and servers communicate over the internet.

### HTTP Request Components

| Component | What It Is | Example |
|-----------|------------|---------|
| Method | Action to perform | GET, POST, PUT, DELETE |
| URL | Resource requested | /about, /api/users |
| Headers | Additional information | Content-Type: application/json |
| Body | Data sent with request | {"username": "john"} |

### HTTP Response Components

| Component | What It Is | Example |
|-----------|------------|---------|
| Status Code | Success/failure indicator | 200 (OK), 404 (Not Found) |
| Headers | Response metadata | Content-Type: text/html |
| Body | The actual content | <h1>Hello World!</h1> |

## Node.js HTTP Module

Node.js comes with a built-in http module.

### Key Functions
- `http.createServer()` - Creates a server object
- `http.request()` - Creates HTTP requests
- `http.get()` - Simplified GET requests

## Your First HTTP Server

```javascript
const http = require('http');
const PORT = 3000;

const server = http.createServer((req, res) => {
    console.log('Request received!');
    console.log('Method:', req.method);
    console.log('URL:', req.url);
    
    res.writeHead(200, {
        'Content-Type': 'text/plain',
    });
    
    res.end('Hello, World!');
});

server.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

### Understanding the Code

1. **Import http module** - `const http = require('http');`
2. **Define port** - `const PORT = 3000;`
3. **Create server** - `http.createServer((req, res) => { ... });`
4. **Send response** - `res.writeHead()` and `res.end()`
5. **Start listening** - `server.listen(PORT, () => { ... });`

### The Request Object (req)

| Property | Description |
|----------|-------------|
| req.method | HTTP method (GET, POST, etc.) |
| req.url | URL path with query string |
| req.headers | Headers as an object |
| req.httpVersion | HTTP version |
| req.socket.remoteAddress | Client IP address |

### The Response Object (res)

| Method | Description |
|--------|-------------|
| res.writeHead(status, headers) | Sets status code and headers |
| res.setHeader(name, value) | Sets a single header |
| res.write(data) | Writes part of the response body |
| res.end(data) | Finishes and sends the response |

## Common HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Everything worked |
| 201 | Created | New resource created |
| 400 | Bad Request | Request invalid/malformed |
| 401 | Unauthorized | Authentication required |
| 403 | Forbidden | Authenticated but not allowed |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Something went wrong |

## Handling Different Routes

```javascript
const http = require('http');
const PORT = 3000;

const routes = {
    '/': (req, res) => {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('<h1>Home Page</h1>');
    },
    '/about': (req, res) => {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('<h1>About Page</h1>');
    },
    '/api/users': (req, res) => {
        const users = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(users));
    }
};

const server = http.createServer((req, res) => {
    if (routes[req.url]) {
        routes[req.url](req, res);
    } else {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end('<h1>404 - Not Found</h1>');
    }
});

server.listen(PORT);
```

## Handling POST Requests

```javascript
const server = http.createServer((req, res) => {
    if (req.method === 'POST' && req.url === '/messages') {
        let body = '';
        
        req.on('data', (chunk) => {
            body += chunk.toString();
        });
        
        req.on('end', () => {
            const data = JSON.parse(body);
            res.writeHead(201, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: true, data }));
        });
    }
});
```

## Limitations of the http Module

1. **Manual Request Parsing** - Must parse body manually
2. **Manual Route Matching** - If-else statements for each route
3. **No Middleware Support** - Can't easily add logging, authentication
4. **No Helpers** - Must manually set headers, handle JSON
5. **No Project Structure** - No guidance on organizing code

---

# PART 3: MEET EXPRESS

## What Is Express?

Express is a lightweight, flexible web application framework for Node.js.

### Analogy
- HTTP Module = Bare-bones pantry with ingredients but no recipes
- Express = Well-organized kitchen with prep stations, tools, and recipes

### What Express Gives Us

| Feature | What It Does |
|---------|--------------|
| Routing | Maps URLs and methods to handlers |
| Middleware | Functions between request and response |
| Request Helpers | req.query, req.params, req.body |
| Response Helpers | res.json(), res.sendFile() |
| Error Handling | Built-in and custom error middleware |
| Static Serving | One-line static file serving |

## Installing Express

```bash
npm install express
```

## Your First Express Server

```javascript
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
    res.send('Hello, Express!');
});

app.get('/about', (req, res) => {
    res.send('<h1>About Express</h1>');
});

app.get('/api/users', (req, res) => {
    const users = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
    res.json({ success: true, data: users });
});

app.use((req, res) => {
    res.status(404).send('404 - Not Found');
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

## Express Route Methods

```javascript
app.get('/users', handler);      // GET - Retrieve data
app.post('/users', handler);     // POST - Create new data
app.put('/users/:id', handler);  // PUT - Replace entire resource
app.patch('/users/:id', handler);// PATCH - Partial update
app.delete('/users/:id', handler);// DELETE - Delete data
app.all('/test', handler);       // ALL - All HTTP methods
app.use(middleware);              // USE - Middleware
```

## Express Response Methods

| Method | Description |
|--------|-------------|
| res.send(data) | Send any type of data (auto-detects) |
| res.json(data) | Send JSON data |
| res.status(code) | Set HTTP status code |
| res.sendStatus(code) | Send status code with message |
| res.set(name, value) | Set headers |
| res.redirect(url) | Redirect to another URL |
| res.download(file) | Send a file as download |
| res.sendFile(path) | Send a file from the server |

## Express Request Methods

| Property | Description |
|----------|-------------|
| req.params | Route parameters |
| req.query | Query string parameters |
| req.body | Request body (with middleware) |
| req.headers | Request headers |
| req.ip | Client IP address |
| req.path | URL path |

## HTTP Module vs Express

| Aspect | HTTP Module | Express |
|--------|-------------|---------|
| Code length | Longer, manual | Shorter, declarative |
| Route definition | Manual if-else | app.get(), app.post() |
| Route parameters | Manual parsing | req.params |
| Query strings | Manual parsing | req.query |
| Request body | Manual chunk handling | Middleware auto-parses |
| JSON responses | res.end(JSON.stringify()) | res.json() |
| Status codes | res.writeHead() | res.status() |
| Error handling | Manual try-catch | Middleware-based |
| 404 handling | Manual | Dedicated middleware |
| Static files | Manual | One line |

---

# PART 4: ROUTING AND URL DATA

## URL Anatomy

```
https://example.com:3000/users/123/posts?page=2&sort=recent#comments
\______/ \______/ \__/ \____/ \_/ \____/ \______________/ \______/
protocol domain  port  path   id   path   query string    fragment
                      segment         (optional)      (optional)
```

### Accessing URL Data in Express

| Method | What It Accesses | Example |
|--------|------------------|---------|
| req.params | Route parameters | /:userId matches 123 |
| req.query | Query string parameters | ?page=2 gives { page: '2' } |
| req.path | Full path (without query string) | /users/123/posts |

## Route Parameters

Route parameters are dynamic segments in your URL that capture values.

```javascript
// Single parameter
app.get('/users/:id', (req, res) => {
    const userId = req.params.id; // '123'
});

// Multiple parameters
app.get('/users/:userId/posts/:postId', (req, res) => {
    const userId = req.params.userId;
    const postId = req.params.postId;
});

// Optional parameter
app.get('/users/:id?', (req, res) => {
    const userId = req.params.id; // '123' or undefined
});

// Parameters with regex constraints
app.get('/users/:id(\\d+)', (req, res) => {
    // Only matches /users/123, not /users/abc
    const userId = req.params.id;
});
```

## Query Strings

Query strings are captured in req.query.

```javascript
// Basic query strings
// URL: /posts?userId=1
app.get('/posts', (req, res) => {
    const userId = req.query.userId; // '1'
});

// Multiple query parameters
// URL: /search?q=hello&sort=recent&limit=5
app.get('/search', (req, res) => {
    const { q, sort, limit } = req.query;
});

// With defaults
app.get('/search', (req, res) => {
    const { q = '', sort = 'recent', limit = 10 } = req.query;
});
```

## HTTP Methods

| Method | Use Case | Idempotent? | Safe? |
|--------|----------|-------------|-------|
| GET | Retrieve data | Yes | Yes |
| POST | Create new data | No | No |
| PUT | Replace entire resource | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Delete data | Yes | No |

- **Idempotent**: Making the same request multiple times has the same effect as making it once
- **Safe**: The request doesn't modify data

## Complete User API

```javascript
const users = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];

// GET /users - Get all users
app.get('/users', (req, res) => {
    res.json({ success: true, data: users });
});

// GET /users/:id - Get a specific user
app.get('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const user = users.find(u => u.id === id);
    if (!user) {
        return res.status(404).json({ success: false, error: 'User not found' });
    }
    res.json({ success: true, data: user });
});

// POST /users - Create a new user
app.post('/users', (req, res) => {
    const { name } = req.body;
    const newUser = { id: users.length + 1, name };
    users.push(newUser);
    res.status(201).json({ success: true, data: newUser });
});

// PUT /users/:id - Update a user
app.put('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = users.findIndex(u => u.id === id);
    if (index === -1) {
        return res.status(404).json({ success: false, error: 'User not found' });
    }
    users[index] = { ...users[index], ...req.body };
    res.json({ success: true, data: users[index] });
});

// DELETE /users/:id - Delete a user
app.delete('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = users.findIndex(u => u.id === id);
    if (index === -1) {
        return res.status(404).json({ success: false, error: 'User not found' });
    }
    users.splice(index, 1);
    res.json({ success: true, message: 'User deleted' });
});
```

## Organizing Routes with express.Router()

### Create a Router
```javascript
// routes/users.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
    res.json({ success: true, data: users });
});

router.get('/:id', (req, res) => {
    // Get a specific user
});

router.post('/', (req, res) => {
    // Create a user
});

module.exports = router;
```

### Use a Router
```javascript
// app.js
const usersRouter = require('./routes/users');
app.use('/users', usersRouter);
```

### Router Features

1. **Router-Level Middleware**
```javascript
router.use((req, res, next) => {
    // Check authentication
    if (!req.headers.authorization) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    next();
});
```

2. **Nested Routers**
```javascript
app.use('/api/v1/users', usersRouter);
// Results in: GET /api/v1/users
```

---

# PART 5: MIDDLEWARE EXPLAINED

## What Is Middleware?

Middleware is a function that executes during the request-response cycle, in the middle between when the request arrives and when the response is sent.

### Analogy: Security Checkpoints at an Airport
```
You enter → Check-in (logging) → Security (authentication) → Gate (routing) → Board (response)
```

### The Middleware Pipeline
```
Request → Middleware 1 → Middleware 2 → Middleware 3 → Route Handler → Response
              ↓              ↓              ↓              ↓
            next()         next()         next()        res.send()
```

### Middleware Function Signature
```javascript
function middleware(req, res, next) {
    // Do something
    // Either:
    // 1. Send a response (end the cycle)
    // 2. Call next() (continue to the next middleware)
}
```

## Built-in Middleware

| Middleware | Purpose |
|------------|---------|
| express.json() | Parse JSON request bodies |
| express.urlencoded() | Parse URL-encoded form data |
| express.static() | Serve static files |
| express.text() | Parse text request bodies |
| express.raw() | Parse raw request bodies |

### Using Built-in Middleware
```javascript
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
```

## Custom Middleware Examples

### Logging Middleware
```javascript
const loggerMiddleware = (req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${req.method} ${req.url}`);
    next();
};

app.use(loggerMiddleware);
```

### Authentication Middleware
```javascript
const authMiddleware = (req, res, next) => {
    const apiKey = req.headers['x-api-key'];
    
    if (!apiKey || apiKey !== 'secret-key-123') {
        return res.status(401).json({
            success: false,
            error: 'Unauthorized'
        });
    }
    
    req.user = { id: 1, name: 'Authenticated User' };
    next();
};

app.get('/protected', authMiddleware, (req, res) => {
    res.json({ success: true, user: req.user });
});
```

### Validation Middleware
```javascript
const validateUserMiddleware = (req, res, next) => {
    const { name, email } = req.body;
    
    if (!name || name.trim() === '') {
        return res.status(400).json({ error: 'Name is required' });
    }
    
    if (!email || !email.includes('@')) {
        return res.status(400).json({ error: 'Valid email is required' });
    }
    
    req.body.name = name.trim();
    req.body.email = email.trim();
    next();
};

app.post('/api/users', validateUserMiddleware, (req, res) => {
    res.json({ success: true, data: req.body });
});
```

### Rate Limiting Middleware
```javascript
const rateLimiterMiddleware = (() => {
    const requests = new Map();
    const WINDOW_MS = 60 * 1000; // 1 minute
    const MAX_REQUESTS = 5;
    
    return (req, res, next) => {
        const ip = req.ip || req.connection.remoteAddress;
        const now = Date.now();
        
        if (!requests.has(ip)) {
            requests.set(ip, []);
        }
        
        const timestamps = requests.get(ip);
        const recentRequests = timestamps.filter(t => now - t < WINDOW_MS);
        
        if (recentRequests.length >= MAX_REQUESTS) {
            return res.status(429).json({
                success: false,
                error: 'Too many requests'
            });
        }
        
        recentRequests.push(now);
        requests.set(ip, recentRequests);
        next();
    };
})();

app.use(rateLimiterMiddleware);
```

### Error Handling Middleware
```javascript
const errorHandlerMiddleware = (err, req, res, next) => {
    console.error('Error:', err);
    
    res.status(err.status || 500).json({
        success: false,
        error: err.message || 'Internal server error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};

app.use(errorHandlerMiddleware);
```

## Middleware Order Matters

```javascript
// CORRECT ORDER:
app.use(express.json());          // 1. Parse JSON
app.use(loggerMiddleware);        // 2. Log the request
app.use(authMiddleware);          // 3. Authenticate
app.get('/users', handler);       // 4. Handle the route
app.use(errorHandlerMiddleware);  // 5. Handle errors

// WRONG ORDER:
app.get('/users', handler);       // 1. Route handler runs first
app.use(express.json());          // 2. JSON parsing never runs!
// req.body would be undefined
```

## Third-Party Middleware

| Package | Purpose |
|---------|---------|
| cors | Enable CORS |
| helmet | Security headers |
| compression | Compress responses |
| morgan | HTTP request logger |
| express-rate-limit | Rate limiting |
| express-session | Session management |
| cookie-parser | Parse cookies |

### Using Third-Party Middleware
```javascript
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

app.use(helmet());
app.use(morgan('combined'));
app.use(compression());
app.use(cors());

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100
});
app.use(limiter);
```

## Advanced Middleware Patterns

### Middleware with Configuration
```javascript
const requireAuth = (roles = []) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        if (roles.length > 0 && !roles.includes(req.user.role)) {
            return res.status(403).json({ error: 'Forbidden' });
        }
        next();
    };
};

app.get('/admin', requireAuth(['admin']), handler);
app.get('/profile', requireAuth(), handler);
```

### Async Middleware
```javascript
const asyncHandler = (fn) => {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

app.get('/async-data', asyncHandler(async (req, res) => {
    const data = await fetchData();
    res.json({ data });
}));
```

---

# PART 6: HANDLING FORMS AND JSON

## Types of User Input

| Format | Content-Type | When Used | Example |
|--------|--------------|-----------|---------|
| URL-encoded | application/x-www-form-urlencoded | HTML forms | name=Alice&email=alice@example.com |
| JSON | application/json | REST APIs | {"name":"Alice","email":"alice@example.com"} |
| Multipart | multipart/form-data | File uploads | Binary data with boundaries |

## Processing URL-Encoded Form Data

```javascript
app.use(express.urlencoded({ extended: true }));

app.post('/form', (req, res) => {
    const { name, email, age } = req.body;
    console.log('Form data:', { name, email, age });
    res.send('Form received!');
});
```

### HTML Form Example
```html
<form action="/form" method="POST">
    <input type="text" name="name" required>
    <input type="email" name="email" required>
    <input type="number" name="age">
    <button type="submit">Submit</button>
</form>
```

## Processing JSON Data

```javascript
app.use(express.json());

app.post('/api/users', (req, res) => {
    const { name, email, age } = req.body;
    console.log('JSON data:', { name, email, age });
    res.json({ success: true, data: req.body });
});
```

## Data Validation

### Manual Validation
```javascript
app.post('/api/users', (req, res) => {
    const { name, email, age } = req.body;
    
    const errors = [];
    if (!name || name.trim() === '') {
        errors.push('Name is required');
    }
    if (!email || !email.includes('@')) {
        errors.push('Valid email is required');
    }
    if (age && (age < 18 || age > 120)) {
        errors.push('Age must be between 18 and 120');
    }
    
    if (errors.length > 0) {
        return res.status(400).json({ success: false, errors });
    }
    
    // Process valid data
});
```

### Validation with Joi
```bash
npm install joi
```

```javascript
const Joi = require('joi');

const userSchema = Joi.object({
    name: Joi.string().min(2).max(50).required(),
    email: Joi.string().email().required(),
    age: Joi.number().integer().min(18).max(120),
    role: Joi.string().valid('user', 'admin').default('user')
});

app.post('/api/users', (req, res) => {
    const { error, value } = userSchema.validate(req.body, {
        abortEarly: false,
        stripUnknown: true
    });
    
    if (error) {
        const errors = error.details.map(d => ({
            field: d.path[0],
            message: d.message
        }));
        return res.status(400).json({ success: false, errors });
    }
    
    res.json({ success: true, data: value });
});
```

## File Uploads with Multer

```bash
npm install multer
```

### Configure Multer
```javascript
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|gif|pdf/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);
        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error('Only images and PDFs are allowed'));
    }
});
```

### Single File Upload
```javascript
app.post('/upload', upload.single('file'), (req, res) => {
    console.log('File:', req.file);
    console.log('Body:', req.body);
    
    res.json({
        success: true,
        message: 'File uploaded',
        data: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            size: req.file.size
        }
    });
}, (error, req, res, next) => {
    if (error instanceof multer.MulterError) {
        if (error.code === 'FILE_TOO_LARGE') {
            return res.status(400).json({ error: 'File too large. Maximum 5MB.' });
        }
        return res.status(400).json({ error: error.message });
    }
    res.status(400).json({ error: error.message });
});
```

### Multiple File Upload
```javascript
app.post('/upload-multiple', upload.array('files', 5), (req, res) => {
    const fileDetails = req.files.map(file => ({
        originalName: file.originalname,
        filename: file.filename,
        size: file.size
    }));
    
    res.json({
        success: true,
        message: `${req.files.length} files uploaded`,
        files: fileDetails
    });
});
```

## Security Best Practices

1. **Validate Everything** - Never trust user input
2. **Sanitize Input** - Remove or escape dangerous characters
3. **Set Size Limits**
```javascript
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
```

4. **Validate Content-Type**
```javascript
app.post('/api/data', (req, res, next) => {
    if (!req.is('application/json')) {
        return res.status(415).json({ error: 'Content-Type must be application/json' });
    }
    next();
});
```

5. **Use Security Headers**
```bash
npm install helmet
```
```javascript
const helmet = require('helmet');
app.use(helmet());
```

6. **Rate Limiting**
```bash
npm install express-rate-limit
```
```javascript
const rateLimit = require('express-rate-limit');
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100
});
app.use('/api', limiter);
```

---

# PART 7: STRUCTURING A REAL APP

## Why Structure Matters

| Benefit | Explanation |
|---------|-------------|
| Maintainability | Easy to find and fix bugs |
| Scalability | Easy to add new features |
| Collaboration | Multiple developers can work together |
| Readability | Easy to understand the codebase |
| Reusability | Code can be reused across features |

## Professional Project Structure

```
node-express-tutorial/
├── .env                    # Environment variables (not in git)
├── .gitignore              # What to exclude from git
├── package.json            # Project dependencies
├── server.js              # Main entry point
├── config/                # Configuration files
│   └── config.js
├── src/                   # Source code
│   ├── app.js            # Express app configuration
│   ├── routes/           # Route definitions
│   │   ├── user.routes.js
│   │   └── task.routes.js
│   ├── controllers/      # Request handlers
│   │   ├── user.controller.js
│   │   └── task.controller.js
│   ├── models/           # Data models
│   │   ├── user.model.js
│   │   └── task.model.js
│   ├── middleware/       # Custom middleware
│   │   ├── auth.js
│   │   ├── validation.js
│   │   └── error.js
│   ├── services/         # Business logic
│   │   └── storage.js
│   └── utils/            # Utility functions
│       ├── logger.js
│       └── validators.js
├── public/               # Static files
│   ├── css/
│   └── js/
└── tests/                # Tests
```

## Directory Purposes

| Directory | Purpose |
|-----------|---------|
| config/ | Configuration that changes between environments |
| src/routes/ | URL routing definitions |
| src/controllers/ | Request handling (extracts data from request) |
| src/models/ | Data structure definitions |
| src/middleware/ | Reusable middleware functions |
| src/services/ | Business logic |
| src/utils/ | Helper functions used everywhere |
| public/ | Static assets served directly |
| tests/ | Automated tests |

## Configuration Module

```javascript
// config/config.js
require('dotenv').config();

const Joi = require('joi');

const envSchema = Joi.object({
    PORT: Joi.number().default(3000),
    NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
    JWT_SECRET: Joi.string().required(),
    API_KEY: Joi.string().required(),
}).unknown().required();

const { error, value: env } = envSchema.validate(process.env);

if (error) {
    console.error('Invalid environment configuration:', error.message);
    process.exit(1);
}

module.exports = {
    port: env.PORT,
    env: env.NODE_ENV,
    jwtSecret: env.JWT_SECRET,
    apiKey: env.API_KEY,
    isProduction: env.NODE_ENV === 'production',
    isDevelopment: env.NODE_ENV === 'development',
};
```

## Environment Variables (.env)

```bash
# .env (DO NOT commit this file!)
PORT=3000
NODE_ENV=development
JWT_SECRET=your-super-secret-jwt-key
API_KEY=secret-key-123

DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=admin
DB_PASSWORD=password123
```

```bash
# .env.example (commit this!)
PORT=3000
NODE_ENV=development
JWT_SECRET=change-this-in-production
API_KEY=your-api-key-here
```

## Logger Utility

```javascript
// src/utils/logger.js
const config = require('../../config/config');

const LEVELS = {
    ERROR: 'ERROR',
    WARN: 'WARN',
    INFO: 'INFO',
    DEBUG: 'DEBUG',
};

const COLORS = {
    ERROR: '\x1b[31m',
    WARN: '\x1b[33m',
    INFO: '\x1b[36m',
    DEBUG: '\x1b[35m',
    RESET: '\x1b[0m',
};

class Logger {
    constructor() {
        this.level = config.isDevelopment ? LEVELS.DEBUG : LEVELS.INFO;
    }

    _log(level, message, ...args) {
        if (!this._shouldLog(level)) return;
        const timestamp = new Date().toISOString();
        const color = COLORS[level] || COLORS.RESET;
        console.log(`${color}[${timestamp}] ${level}:${COLORS.RESET}`, message, ...args);
    }

    error(message, ...args) { this._log(LEVELS.ERROR, message, ...args); }
    warn(message, ...args) { this._log(LEVELS.WARN, message, ...args); }
    info(message, ...args) { this._log(LEVELS.INFO, message, ...args); }
    debug(message, ...args) { this._log(LEVELS.DEBUG, message, ...args); }

    requestLogger() {
        return (req, res, next) => {
            this.debug(`${req.method} ${req.url}`);
            next();
        };
    }
}

module.exports = new Logger();
```

## Model Layer

```javascript
// src/models/user.model.js
const storage = require('../services/storage.service');
const { hashPassword } = require('../utils/auth');

class UserModel {
    static getAll() {
        const users = storage.getCollection('users');
        return users.map(({ password, ...user }) => user);
    }

    static getById(id) {
        const user = storage.findById('users', id);
        if (!user) return null;
        const { password, ...safeUser } = user;
        return safeUser;
    }

    static getByEmail(email) {
        const users = storage.getCollection('users');
        return users.find(u => u.email === email);
    }

    static async create(userData) {
        const { name, email, password } = userData;
        const hashedPassword = await hashPassword(password);
        const newUser = await storage.create('users', {
            name,
            email: email.toLowerCase(),
            password: hashedPassword,
            createdAt: new Date().toISOString()
        });
        const { password: _, ...safeUser } = newUser;
        return safeUser;
    }

    static async update(id, updates) {
        const updatedUser = await storage.update('users', id, updates);
        if (!updatedUser) return null;
        const { password, ...safeUser } = updatedUser;
        return safeUser;
    }

    static async delete(id) {
        return await storage.delete('users', id);
    }
}

module.exports = UserModel;
```

## Controller Layer

```javascript
// src/controllers/user.controller.js
const UserModel = require('../models/user.model');
const { asyncHandler } = require('../middleware/error');
const { AppError } = require('../utils/errors');

class UserController {
    getAllUsers = asyncHandler(async (req, res) => {
        const users = UserModel.getAll();
        res.json({ success: true, count: users.length, data: users });
    });

    getUserById = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const user = UserModel.getById(id);
        if (!user) {
            throw new AppError(`User with ID ${id} not found`, 404);
        }
        res.json({ success: true, data: user });
    });

    createUser = asyncHandler(async (req, res) => {
        const userData = req.body;
        const existingUser = UserModel.getByEmail(userData.email);
        if (existingUser) {
            throw new AppError('Email already registered', 409);
        }
        const newUser = await UserModel.create(userData);
        res.status(201).json({ success: true, data: newUser });
    });

    updateUser = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const userData = req.body;
        const existingUser = UserModel.getById(id);
        if (!existingUser) {
            throw new AppError(`User with ID ${id} not found`, 404);
        }
        const updatedUser = await UserModel.update(id, userData);
        res.json({ success: true, data: updatedUser });
    });

    deleteUser = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const existingUser = UserModel.getById(id);
        if (!existingUser) {
            throw new AppError(`User with ID ${id} not found`, 404);
        }
        await UserModel.delete(id);
        res.json({ success: true, message: `User ${id} deleted` });
    });
}

module.exports = new UserController();
```

## Route Layer

```javascript
// src/routes/user.routes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { userSchema } = require('../utils/validators');

router.use(authenticate);

router.get('/', userController.getAllUsers);
router.get('/:id', userController.getUserById);
router.post('/', validate(userSchema), userController.createUser);
router.put('/:id', validate(userSchema), userController.updateUser);
router.delete('/:id', userController.deleteUser);

module.exports = router;
```

## App Configuration

```javascript
// src/app.js
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const config = require('../config/config');
const logger = require('./utils/logger');

const app = express();

// Security
app.use(helmet());
app.use(cors());

// Parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
app.use(logger.requestLogger());

// Static files
app.use(express.static('public'));

// Routes
app.use('/users', require('./routes/user.routes'));
app.use('/tasks', require('./routes/task.routes'));

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 404 handler
app.use(require('./middleware/error').notFoundHandler);

// Error handler
app.use(require('./middleware/error').errorHandler);

module.exports = app;
```

## Server Entry Point

```javascript
// server.js
require('dotenv').config();

const config = require('./config/config');
const app = require('./src/app');
const logger = require('./src/utils/logger');
const storage = require('./src/services/storage.service');

async function startServer() {
    try {
        await storage.init();
        logger.info('Storage initialized');

        const server = app.listen(config.port, () => {
            console.log(`========================================`);
            console.log(`✅ Server running!`);
            console.log(`📡 http://localhost:${config.port}`);
            console.log(`🔧 Environment: ${config.env}`);
            console.log(`========================================`);
        });

        server.on('error', (error) => {
            if (error.code === 'EADDRINUSE') {
                logger.error(`Port ${config.port} is already in use`);
                process.exit(1);
            }
        });

        process.on('SIGINT', () => {
            logger.info('Shutting down...');
            server.close(() => process.exit(0));
        });
    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
}

startServer();
```

---

# PART 8: SIMPLE PERSISTENCE AND CRUD

## What Is Persistence?

Persistence means storing data so it outlasts the running program.

### Types of Storage
1. **In-memory** - Fast but temporary (server restart = data loss)
2. **File-based** - Simple, persistent, limited for large applications
3. **Database** - Robust, scalable, feature-rich

## Why JSON for Persistence?

| Feature | Why It's Good |
|---------|---------------|
| Human-readable | Open and understand the data |
| JavaScript-native | Easy to parse with JSON.parse() |
| Portable | Works on any platform |
| Version-control friendly | See changes in git diffs |
| No dependencies | Built into Node.js |

## Storage Service

```javascript
// src/services/storage.service.js
const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');

const STORAGE_DIR = path.join(__dirname, '../../data');
const STORAGE_FILE = path.join(STORAGE_DIR, 'db.json');

const DEFAULT_DATA = {
    users: [],
    tasks: [],
};

class StorageService {
    constructor() {
        this.data = null;
        this.initialized = false;
    }

    async init() {
        if (this.initialized) return;
        try {
            await fs.mkdir(STORAGE_DIR, { recursive: true });
            try {
                await fs.access(STORAGE_FILE);
            } catch (error) {
                await this._writeData(DEFAULT_DATA);
            }
            await this._loadData();
            this.initialized = true;
            logger.info('Storage initialized');
        } catch (error) {
            logger.error('Failed to initialize storage:', error);
            throw error;
        }
    }

    async _loadData() {
        try {
            const fileContent = await fs.readFile(STORAGE_FILE, 'utf-8');
            this.data = JSON.parse(fileContent);
        } catch (error) {
            this.data = { ...DEFAULT_DATA };
            await this._writeData(this.data);
        }
    }

    async _writeData(data) {
        const content = JSON.stringify(data, null, 2);
        await fs.writeFile(STORAGE_FILE, content, 'utf-8');
    }

    async save() {
        await this._writeData(this.data);
    }

    getCollection(name) {
        if (!this.data[name]) this.data[name] = [];
        return this.data[name];
    }

    findById(collection, id) {
        const items = this.getCollection(collection);
        return items.find(item => item.id === id);
    }

    async create(collection, item) {
        const items = this.getCollection(collection);
        const maxId = items.reduce((max, current) => 
            current.id > max ? current.id : max, 0
        );
        const newItem = {
            ...item,
            id: maxId + 1,
            createdAt: new Date().toISOString()
        };
        items.push(newItem);
        await this.save();
        return newItem;
    }

    async update(collection, id, updates) {
        const items = this.getCollection(collection);
        const index = items.findIndex(item => item.id === id);
        if (index === -1) return null;
        const { id: _, createdAt, ...allowedUpdates } = updates;
        items[index] = {
            ...items[index],
            ...allowedUpdates,
            updatedAt: new Date().toISOString()
        };
        await this.save();
        return items[index];
    }

    async delete(collection, id) {
        const items = this.getCollection(collection);
        const index = items.findIndex(item => item.id === id);
        if (index === -1) return false;
        items.splice(index, 1);
        await this.save();
        return true;
    }

    count(collection) {
        return this.getCollection(collection).length;
    }
}

module.exports = new StorageService();
```

## CRUD Operations Explained

### Create (POST)
```
POST /api/users
Body: { "name": "Alice", "email": "alice@example.com" }
Response: { "success": true, "data": { "id": 1, "name": "Alice", ... } }
```

### Read (GET)
```
GET /api/users
Response: { "success": true, "data": [ ... ] }

GET /api/users/1
Response: { "success": true, "data": { "id": 1, ... } }
```

### Update (PUT)
```
PUT /api/users/1
Body: { "name": "Alice Updated" }
Response: { "success": true, "data": { "id": 1, ... } }
```

### Delete (DELETE)
```
DELETE /api/users/1
Response: { "success": true, "message": "User 1 deleted" }
```

## Data Validation Before Persistence

```javascript
async createUser(req, res, next) {
    try {
        const userData = req.body;
        
        if (!userData.name || !userData.email || !userData.password) {
            throw new AppError('Name, email, and password are required', 400);
        }
        
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(userData.email)) {
            throw new AppError('Invalid email format', 400);
        }
        
        if (userData.password.length < 8) {
            throw new AppError('Password must be at least 8 characters', 400);
        }
        
        const existingUser = UserModel.getByEmail(userData.email);
        if (existingUser) {
            throw new AppError('Email already registered', 409);
        }
        
        const newUser = await UserModel.create(userData);
        res.status(201).json({ success: true, data: newUser });
    } catch (error) {
        next(error);
    }
}
```

---

# PART 9: ERROR HANDLING, VALIDATION, AND SAFETY

## The Error Handling Pyramid

```
┌─────────────────────────────────────────────────────────────┐
│               Global Error Handler                         │
│           (Last resort catch-all)                          │
├─────────────────────────────────────────────────────────────┤
│               Route-Level Errors                           │
│           (Specific route errors)                          │
├─────────────────────────────────────────────────────────────┤
│               Controller-Level Errors                      │
│           (Business logic errors)                          │
├─────────────────────────────────────────────────────────────┤
│               Service/Model-Level Errors                   │
│           (Data layer errors)                              │
└─────────────────────────────────────────────────────────────┘
```

## Custom Error Classes

```javascript
// src/utils/errors.js
class AppError extends Error {
    constructor(message, statusCode = 500, isOperational = true) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = isOperational;
        this.timestamp = new Date().toISOString();
        Error.captureStackTrace(this, this.constructor);
    }
}

class ValidationError extends AppError {
    constructor(message, errors = []) {
        super(message, 400);
        this.name = 'ValidationError';
        this.errors = errors;
    }
}

class AuthenticationError extends AppError {
    constructor(message = 'Authentication required') {
        super(message, 401);
        this.name = 'AuthenticationError';
    }
}

class AuthorizationError extends AppError {
    constructor(message = 'Insufficient permissions') {
        super(message, 403);
        this.name = 'AuthorizationError';
    }
}

class NotFoundError extends AppError {
    constructor(resource = 'Resource') {
        super(`${resource} not found`, 404);
        this.name = 'NotFoundError';
    }
}

class ConflictError extends AppError {
    constructor(message = 'Resource already exists') {
        super(message, 409);
        this.name = 'ConflictError';
    }
}
```

## Error Handling Middleware

```javascript
// src/middleware/error.js
const {
    AppError,
    ValidationError,
    AuthenticationError,
    NotFoundError,
    formatErrorResponse,
    logError,
} = require('../utils/errors');

const errorHandler = (err, req, res, next) => {
    logError(err, req);

    if (!(err instanceof AppError)) {
        if (err.name === 'ValidationError') {
            err = new ValidationError(err.message, err.errors);
        } else if (err.name === 'UnauthorizedError') {
            err = new AuthenticationError(err.message);
        } else {
            err = new AppError(
                err.message || 'Internal server error',
                err.status || 500,
                false
            );
        }
    }

    const errorResponse = formatErrorResponse(err);
    res.status(err.statusCode || 500).json(errorResponse);
};

const notFoundHandler = (req, res, next) => {
    const error = new NotFoundError(`Route ${req.method} ${req.url}`);
    next(error);
};

const asyncHandler = (fn) => {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

module.exports = {
    errorHandler,
    notFoundHandler,
    asyncHandler,
};
```

## Input Validation with Joi

```javascript
const Joi = require('joi');

const schemas = {
    createUser: Joi.object({
        name: Joi.string().min(2).max(50).required()
            .messages({
                'string.min': 'Name must be at least 2 characters',
                'string.max': 'Name must be at most 50 characters',
                'any.required': 'Name is required',
            }),
        email: Joi.string().email().required()
            .messages({
                'string.email': 'Please provide a valid email address',
                'any.required': 'Email is required',
            }),
        password: Joi.string().min(8).required()
            .messages({
                'string.min': 'Password must be at least 8 characters',
                'any.required': 'Password is required',
            }),
    }),
};

const validate = (schema, options = {}) => {
    return (req, res, next) => {
        const target = options.target || 'body';
        const data = req[target];

        const { error, value } = schema.validate(data, {
            abortEarly: false,
            stripUnknown: true,
            ...options,
        });

        if (error) {
            const errorDetails = error.details.map((detail) => ({
                field: detail.path.join('.'),
                message: detail.message,
                type: detail.type,
            }));

            throw new ValidationError('Validation failed', errorDetails);
        }

        req[target] = value;
        next();
    };
};
```

## Security Middleware

```javascript
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');

const app = express();

// Security headers
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
        },
    },
}));

// CORS
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
    credentials: true,
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: { success: false, error: 'Too many requests' },
});
app.use('/api', limiter);

// Compression
app.use(compression());

// NoSQL injection protection
app.use(mongoSanitize());

// XSS protection
app.use(xss());

// JSON parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
```

## Password Security

```javascript
const bcrypt = require('bcryptjs');
const SALT_ROUNDS = 12;

class UserModel {
    static async hashPassword(password) {
        return await bcrypt.hash(password, SALT_ROUNDS);
    }

    static async verifyPassword(password, hashedPassword) {
        return await bcrypt.compare(password, hashedPassword);
    }

    static async create(userData) {
        const hashedPassword = await this.hashPassword(userData.password);
        const newUser = await storage.create('users', {
            ...userData,
            password: hashedPassword,
        });
        const { password, ...safeUser } = newUser;
        return safeUser;
    }

    static async authenticate(email, password) {
        const user = this.getByEmail(email);
        if (!user) return null;
        const isValid = await this.verifyPassword(password, user.password);
        if (!isValid) return null;
        const { password: _, ...safeUser } = user;
        return safeUser;
    }
}
```

## JWT Authentication

```javascript
const jwt = require('jsonwebtoken');
const config = require('../config/config');

const generateToken = (user) => {
    const payload = {
        id: user.id,
        email: user.email,
        name: user.name,
    };
    return jwt.sign(payload, config.jwtSecret, {
        expiresIn: config.jwtExpiresIn || '7d',
    });
};

const verifyToken = (token) => {
    try {
        return jwt.verify(token, config.jwtSecret);
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            throw new AuthenticationError('Invalid token');
        }
        if (error.name === 'TokenExpiredError') {
            throw new AuthenticationError('Token expired');
        }
        throw new AuthenticationError('Authentication failed');
    }
};

const authenticate = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        if (!token) {
            throw new AuthenticationError('No token provided');
        }
        const decoded = verifyToken(token);
        const user = UserModel.getById(decoded.id);
        if (!user) {
            throw new AuthenticationError('User no longer exists');
        }
        req.user = user;
        next();
    } catch (error) {
        next(error);
    }
};
```

---

# PART 10: FINAL PROJECT AND DEPLOYMENT

## TaskMaster Pro Features

| Feature | Description |
|---------|-------------|
| User Management | Register, login, manage profiles |
| Task Management | Create, read, update, delete tasks |
| Task Organization | Priority, completion status, filtering |
| Dashboard | Statistics and overview |
| Responsive UI | Desktop, tablet, mobile |
| REST API | Complete API for frontend |
| Authentication | JWT with secure password hashing |
| Persistence | File-based storage |
| Security | Headers, rate limiting, validation |
| Deployment | Ready for production |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     TaskMaster Pro                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐  │
│  │                     Frontend                         │  │
│  │  • HTML/CSS/JavaScript                              │  │
│  │  • Dashboard with stats                             │  │
│  │  • Task list with filters                           │  │
│  │  • Task creation/editing/deletion                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    REST API                         │  │
│  │  • /api/auth    - Authentication                    │  │
│  │  • /api/users   - User management                  │  │
│  │  • /api/tasks   - Task CRUD operations             │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   Storage Layer                      │  │
│  │  • File-based JSON                                  │  │
│  │  • CRUD operations                                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Project Setup

```bash
# Create project
mkdir taskmaster-pro
cd taskmaster-pro
npm init -y

# Install dependencies
npm install express dotenv helmet cors compression \
  express-rate-limit bcryptjs jsonwebtoken joi

# Install dev dependencies
npm install nodemon --save-dev

# Create directory structure
mkdir -p src/{routes,controllers,models,middleware,services,utils}
mkdir -p config public/{css,js}
```

## Deployment Options

### Option 1: Render.com
```bash
# Push to GitHub
# Sign up at render.com
# Click "New +" → "Web Service"
# Connect GitHub repository
# Configure:
#   Build Command: npm install
#   Start Command: npm start
#   Environment Variables:
#     NODE_ENV=production
#     JWT_SECRET=your-secret-key
#     API_KEY=your-api-key
```

### Option 2: Railway
```bash
# Push to GitHub
# Sign up at railway.app
# Click "New Project" → "Deploy from GitHub repo"
# Select repository
# Add environment variables
# Railway automatically deploys
```

### Option 3: Heroku
```bash
heroku login
heroku create taskmaster-pro
heroku config:set JWT_SECRET=your-secret-key
heroku config:set API_KEY=your-api-key
heroku config:set NODE_ENV=production
git push heroku main
heroku open
```

### Option 4: VPS (DigitalOcean, AWS)
```bash
# On server
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

git clone https://github.com/yourusername/taskmaster-pro.git
cd taskmaster-pro
npm install --production

export NODE_ENV=production
export JWT_SECRET=your-secret-key
export API_KEY=your-api-key
export PORT=3000

npm install -g pm2
pm2 start server.js --name taskmaster-pro
pm2 save
pm2 startup
```

## Deployment Checklist

- [ ] Environment variables configured
- [ ] NODE_ENV=production set
- [ ] PORT configured for hosting platform
- [ ] JWT_SECRET set to secure value
- [ ] API_KEY set (if used)
- [ ] Error handling working
- [ ] Logging configured
- [ ] Security headers (helmet) enabled
- [ ] CORS configured
- [ ] Rate limiting configured
- [ ] Validation working
- [ ] Static files served correctly
- [ ] Code pushed to repository
- [ ] Build process tested
- [ ] Application starts correctly
- [ ] Health check endpoint working
- [ ] Frontend accessible
- [ ] API endpoints working
- [ ] Authentication working

---

# QUICK REFERENCE

## Express Setup
```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.json({ message: 'Hello, World!' });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

## Routing
```javascript
app.get('/users/:id', (req, res) => {
    const id = req.params.id;
});

app.get('/search', (req, res) => {
    const { q, page } = req.query;
});

app.post('/users', handler);
app.put('/users/:id', handler);
app.patch('/users/:id', handler);
app.delete('/users/:id', handler);
```

## Middleware
```javascript
// Built-in
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// Custom
app.use((req, res, next) => {
    console.log(`${req.method} ${req.url}`);
    next();
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).json({ error: err.message });
});
```

## CRUD Operations
```javascript
// Model
const items = [];
let nextId = 1;

function create(item) {
    const newItem = { id: nextId++, ...item };
    items.push(newItem);
    return newItem;
}

function getAll() { return items; }
function getById(id) { return items.find(i => i.id === id); }

function update(id, updates) {
    const index = items.findIndex(i => i.id === id);
    if (index === -1) return null;
    items[index] = { ...items[index], ...updates };
    return items[index];
}

function delete(id) {
    const index = items.findIndex(i => i.id === id);
    if (index === -1) return false;
    items.splice(index, 1);
    return true;
}
```

## Validation
```javascript
const Joi = require('joi');
const schema = Joi.object({
    name: Joi.string().min(2).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required()
});

const { error, value } = schema.validate(data);
```

## Authentication
```javascript
// Hash password
const hashedPassword = await bcrypt.hash(password, 12);

// Verify password
const isValid = await bcrypt.compare(password, hashedPassword);

// JWT
const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
    expiresIn: '7d'
});
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

## Environment Variables
```bash
PORT=3000
NODE_ENV=production
JWT_SECRET=your-secret-key
DB_URL=your-database-url
```

```javascript
const config = {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development',
    jwtSecret: process.env.JWT_SECRET,
};
```

---

# GLOSSARY

**API** - Application Programming Interface. A set of rules for building and interacting with software applications.

**Authentication** - The process of verifying the identity of a user or system.

**Authorization** - The process of determining what permissions an authenticated user has.

**Backend** - The server-side part of a web application that handles data processing, storage, and business logic.

**Client** - A device or program that requests services from a server.

**Controller** - A component that handles HTTP requests and coordinates between routes and models.

**CRUD** - Create, Read, Update, Delete. The four basic operations for data management.

**CORS** - Cross-Origin Resource Sharing. A security mechanism that allows web pages from one domain to access resources from another domain.

**Deployment** - The process of making an application available for use.

**Environment Variables** - Dynamic values that affect how a program runs, often used for configuration.

**Express** - A web framework for Node.js that simplifies building web applications.

**Framework** - A set of tools, libraries, and patterns for building applications.

**HTTP** - Hypertext Transfer Protocol. The protocol used for communication on the web.

**Idempotent** - An operation that produces the same result regardless of how many times it's performed.

**JSON** - JavaScript Object Notation. A lightweight data format that is easy for humans to read and write.

**JWT** - JSON Web Token. A compact, URL-safe token format used for authentication.

**Middleware** - Functions that execute during the request-response cycle, between when a request arrives and when a response is sent.

**Model** - A component that represents data and business logic.

**MVC** - Model-View-Controller. A pattern that separates an application into three interconnected components.

**Node.js** - A JavaScript runtime that allows JavaScript to run on servers.

**npm** - Node Package Manager. The package manager for Node.js.

**Persistence** - The ability of data to survive beyond the execution of a program.

**Rate Limiting** - The practice of limiting the number of requests a client can make in a given time period.

**REST** - Representational State Transfer. An architectural style for designing web APIs.

**Route** - A URL path that responds to HTTP requests.

**Router** - A component that defines and organizes routes.

**Sanitization** - The process of cleaning input data to make it safe.

**Server** - A program that processes requests and sends responses.

**Status Code** - A number in an HTTP response that indicates the result of the request.

**Validation** - The process of checking data for correctness and completeness.

---

# FURTHER RESOURCES

## Official Documentation
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [Express Documentation](https://expressjs.com/)
- [npm Documentation](https://docs.npmjs.com/)

## Books
- "Node.js Design Patterns" by Mario Casciaro
- "Express.js Guide" by Azat Mardan

## Online Courses
- [Node.js and Express (freeCodeCamp)](https://www.freecodecamp.org/)
- [The Complete Node.js Developer Course](https://www.udemy.com/course/the-complete-nodejs-developer-course-2/)

## Tools
- [Postman](https://www.postman.com/) - API testing
- [VS Code](https://code.visualstudio.com/) - Code editor
- [GitHub](https://github.com/) - Version control

## Community
- [Stack Overflow](https://stackoverflow.com/questions/tagged/node.js)
- [Express GitHub](https://github.com/expressjs/express)
- [Node.js Discord](https://discord.com/invite/nodejs)

---

**End of Student Notes**

*Keep building, keep learning, and keep sharing!* 🚀
