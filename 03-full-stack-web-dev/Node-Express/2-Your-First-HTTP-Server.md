# Part 2: Your First HTTP Server

Welcome to Part 2! In Part 1, we learned what servers are, installed Node.js, and ran our first JavaScript program. Now we're going to build something much more exciting: **an actual HTTP server** that can respond to requests from a web browser.

By the end of this part, you'll understand how servers work under the hood, handle requests and responses manually, and appreciate why frameworks like Express exist. We'll use Node.js's built-in `http` module to build everything from scratch.

---

## What Is an HTTP Server?

Before we write code, let's understand what we're building. An **HTTP server** is a program that:

1. **Listens** for incoming network connections on a specific port (like a phone waiting for calls)
2. **Receives HTTP requests** from clients (browsers, mobile apps, other servers)
3. **Processes** those requests (figures out what the client wants)
4. **Sends HTTP responses** back to the client (the requested data or an error message)

**Think of an HTTP server like a restaurant receptionist:**
- They wait by the phone (listen on a port)
- When a call comes in (HTTP request), they answer it
- They figure out what the caller wants (process the request)
- They give the caller the information they need (HTTP response)

### What Is HTTP?

**HTTP** stands for **Hypertext Transfer Protocol**. It's the set of rules that govern how clients and servers communicate over the internet. Think of it as the language that browsers and servers use to talk to each other.

An HTTP request contains:

| Component | What It Is | Example |
|-----------|------------|---------|
| **HTTP Method** | What action the client wants to perform | GET, POST, PUT, DELETE |
| **URL** | What resource the client wants | `/about`, `/api/users`, `/index.html` |
| **Headers** | Additional information (like content type, authentication) | `Content-Type: application/json` |
| **Body** | Data sent with the request (for POST/PUT requests) | `{"username": "john"}` |

An HTTP response contains:

| Component | What It Is | Example |
|-----------|------------|---------|
| **Status Code** | A number indicating success or failure | 200 (OK), 404 (Not Found), 500 (Server Error) |
| **Headers** | Additional information about the response | `Content-Type: text/html` |
| **Body** | The actual content (HTML, JSON, images, etc.) | `<h1>Hello World!</h1>` |

---

## Node.js HTTP Module: The Foundation

Node.js comes with a built-in module called `http` that lets us create HTTP servers without installing anything else. This is important because:

1. **It shows you how servers actually work** — When you use frameworks later, you'll understand what they're doing for you.
2. **It's always available** — No installation needed, no dependency management.
3. **It's lightweight** — Sometimes you don't need a full framework.

### What the http Module Provides

The `http` module gives us three main things:

1. **`http.createServer()`** — Creates a server object that can listen for requests
2. **`http.request()`** — Creates HTTP requests (for making your server act as a client)
3. **`http.get()`** — A simpler version of `http.request()` for GET requests

We'll focus on `http.createServer()` in this part.

---

## Building Your First HTTP Server

Let's build a server step by step. We'll start simple and add features gradually.

### Step 1: Create Your Project Directory

If you're continuing from Part 1, you should already have a `node-express-tutorial` directory. If not, create it now:

```bash
mkdir node-express-tutorial
cd node-express-tutorial
```

### Step 2: Create the Server File

Create a new file called `server-http.js` in your project directory:

```bash
touch server-http.js  # macOS/Linux
# OR
echo "" > server-http.js  # Windows
```

### Step 3: Write Your First HTTP Server

Open `server-http.js` and add this code:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-http.js
// DESCRIPTION: Our first HTTP server using Node.js's built-in http module
// WHAT IT DOES: Listens for HTTP requests and sends back simple responses
// =====================================================

// Step 1: Import the http module
// Node.js modules are imported using require()
// The http module is built into Node.js, so we don't need to install anything
const http = require('http');

// Step 2: Define the port we want to listen on
// We'll use port 3000 because it's commonly used for development
// You can use any port number between 1024 and 65535 (but avoid common ports)
// Port 80 is for HTTP, 443 is for HTTPS - these need special permissions
const PORT = 3000;

// Step 3: Create the server
// http.createServer() takes a request handler function
// This function will be called EVERY TIME a request comes in
const server = http.createServer((req, res) => {
    // This code runs for every request to our server
    
    // req = the request object (contains info about what the client wants)
    // res = the response object (used to send data back to the client)
    
    console.log('🔹 Received a request!');
    console.log('  - Method:', req.method);   // GET, POST, etc.
    console.log('  - URL:', req.url);         // The path the client requested
    
    // Step 4: Send a response
    // We need to:
    // 1. Set the status code (200 means "OK" / success)
    // 2. Set headers (like Content-Type)
    // 3. Send the response body (the actual content)
    
    // Write the status code and headers
    res.writeHead(200, {
        'Content-Type': 'text/plain',  // We're sending plain text
        'X-Custom-Header': 'Hello!',   // Custom headers are common in APIs
    });
    
    // Send the response body
    // res.end() tells Node.js that we're done sending the response
    // We can send text, HTML, JSON, or any other content
    res.end('Hello, World! This is my first HTTP server! 🚀');
    
    console.log('✅ Response sent!');
});

// Step 5: Start the server and listen for connections
// server.listen() tells the server to start accepting connections
// The callback function runs once the server is successfully started
server.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Server is running!`);
    console.log(`📡 Listening on: http://localhost:${PORT}`);
    console.log(`🔒 Press Ctrl+C to stop the server`);
    console.log(`===================================`);
});

// Step 6: Handle errors
// If something goes wrong with the server, we should handle it gracefully
server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        // EADDRINUSE means the port is already taken by another program
        console.error(`❌ Port ${PORT} is already in use.`);
        console.error(`   Try closing other programs or using a different port.`);
    } else {
        console.error('❌ Server error:', error);
    }
});

// Step 7: Graceful shutdown
// When the user presses Ctrl+C, we want to clean up properly
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down server...');
    server.close(() => {
        console.log('✅ Server closed gracefully');
        process.exit(0);
    });
});

console.log('💡 Server script loaded. Waiting for connections...');
```

### Step 4: Run Your Server

In your terminal, make sure you're in the `node-express-tutorial` directory and run:

```bash
node server-http.js
```

You should see output like:

```
💡 Server script loaded. Waiting for connections...
===================================
✅ Server is running!
📡 Listening on: http://localhost:3000
🔒 Press Ctrl+C to stop the server
===================================
```

Your server is now running! It's waiting for requests. Don't close this terminal window — the server needs to keep running.

### Step 5: Test Your Server in a Browser

Open your web browser and go to: **http://localhost:3000**

You should see:
```
Hello, World! This is my first HTTP server! 🚀
```

Look back at your terminal. You'll see log messages showing the request:

```
🔹 Received a request!
  - Method: GET
  - URL: /
✅ Response sent!
```

### Step 6: Try Different URLs

In your browser, try:
- http://localhost:3000/about
- http://localhost:3000/any-path-you-want
- http://localhost:3000/api/users

You'll see the same response (because we always send "Hello, World!") but look at the terminal logs — you'll see the different URLs being requested.

### Step 7: Try Using curl (Command Line)

Open a **new** terminal window (keep your server running in the first one) and try:

```bash
# GET request to the root path
curl http://localhost:3000/

# GET request with a custom path
curl http://localhost:3000/test

# See the headers in the response
curl -v http://localhost:3000/
```

The `-v` flag shows verbose output, including the headers.

### Step 8: Stop the Server

When you're done testing, stop the server by pressing `Ctrl+C` in the terminal where it's running.

---

## Making Our Server More Useful

A server that always sends the same response isn't very useful. Let's make it smarter by handling different URLs and serving different content.

### Enhanced Server: Handling Different Routes

Create a new file called `server-http-routes.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-http-routes.js
// DESCRIPTION: An HTTP server that handles different routes
// =====================================================

const http = require('http');
const PORT = 3000;

// We'll use an object to map routes to their handlers
// This is like a simple router
const routes = {
    '/': (req, res) => {
        // Home page
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Home Page</title>
                <style>
                    body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                    h1 { color: #2c3e50; }
                </style>
            </head>
            <body>
                <h1>🏠 Welcome to My Server!</h1>
                <p>This is the home page. Try these paths:</p>
                <ul>
                    <li><a href="/about">About</a></li>
                    <li><a href="/api/users">API: Users</a></li>
                    <li><a href="/api/posts">API: Posts</a></li>
                    <li><a href="/not-found">404 Example</a></li>
                </ul>
            </body>
            </html>
        `);
    },
    
    '/about': (req, res) => {
        // About page
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>About Page</title>
                <style>
                    body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                    h1 { color: #3498db; }
                </style>
            </head>
            <body>
                <h1>📖 About This Server</h1>
                <p>This is a simple HTTP server built with Node.js's built-in http module.</p>
                <p>It demonstrates how servers handle different routes manually.</p>
                <p><a href="/">← Back to Home</a></p>
            </body>
            </html>
        `);
    },
    
    '/api/users': (req, res) => {
        // API endpoint returning JSON
        const users = [
            { id: 1, name: 'Alice', email: 'alice@example.com' },
            { id: 2, name: 'Bob', email: 'bob@example.com' },
            { id: 3, name: 'Charlie', email: 'charlie@example.com' },
        ];
        
        // We're returning JSON, so set the appropriate content type
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            count: users.length,
            data: users
        }));
    },
    
    '/api/posts': (req, res) => {
        // Another API endpoint
        const posts = [
            { id: 1, title: 'First Post', content: 'This is the first post' },
            { id: 2, title: 'Second Post', content: 'This is the second post' },
        ];
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            count: posts.length,
            data: posts
        }));
    }
};

// The request handler function
const server = http.createServer((req, res) => {
    console.log(`📨 ${req.method} ${req.url}`);
    
    // Check if the requested URL is in our routes object
    if (routes[req.url]) {
        // If it is, call the handler function
        routes[req.url](req, res);
        console.log(`✅ Handled: ${req.url}`);
    } else {
        // If not, send a 404 Not Found response
        console.log(`❌ Not found: ${req.url}`);
        
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>404 - Page Not Found</title>
                <style>
                    body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
                    h1 { font-size: 72px; color: #e74c3c; margin: 0; }
                    p { font-size: 20px; color: #7f8c8d; }
                </style>
            </head>
            <body>
                <h1>404</h1>
                <p>Oops! The page "${req.url}" was not found.</p>
                <p><a href="/">Go to Home</a></p>
            </body>
            </html>
        `);
    }
});

server.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Enhanced server is running!`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available routes:`);
    Object.keys(routes).forEach(route => {
        console.log(`   - http://localhost:${PORT}${route}`);
    });
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});

// Error handling and graceful shutdown (same as before)
server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use.`);
    } else {
        console.error('❌ Server error:', error);
    }
});

process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down server...');
    server.close(() => {
        console.log('✅ Server closed gracefully');
        process.exit(0);
    });
});
```

Run this server:

```bash
node server-http-routes.js
```

Now test these URLs in your browser:
- http://localhost:3000/ — Shows the home page
- http://localhost:3000/about — Shows the about page
- http://localhost:3000/api/users — Shows JSON user data
- http://localhost:3000/api/posts — Shows JSON post data
- http://localhost:3000/anything-else — Shows a 404 page

---

## Understanding the Request and Response Objects

Let's dive deeper into the `req` (request) and `res` (response) objects. These are the heart of HTTP servers.

### The Request Object (req)

The request object contains everything about the incoming request:

```javascript
// These are the most important properties of the request object

// 1. req.method - The HTTP method (GET, POST, PUT, DELETE, etc.)
console.log('Method:', req.method);

// 2. req.url - The URL path (without the domain)
// Example: if the full URL is http://localhost:3000/users?page=2
// req.url would be "/users?page=2"
console.log('URL:', req.url);

// 3. req.headers - An object containing all the request headers
// Headers include things like content type, authentication tokens, etc.
console.log('Headers:', req.headers);

// 4. req.httpVersion - The HTTP version (usually "1.1" or "2.0")
console.log('HTTP Version:', req.httpVersion);

// 5. req.socket - Information about the network connection
console.log('Remote IP:', req.socket.remoteAddress);
console.log('Remote Port:', req.socket.remotePort);
```

### The Response Object (res)

The response object is used to send data back to the client:

```javascript
// 1. res.writeHead() - Sets the status code and headers
// Syntax: res.writeHead(statusCode, headersObject)
res.writeHead(200, {
    'Content-Type': 'text/html',
    'Cache-Control': 'no-cache'
});

// 2. res.setHeader() - Set individual headers (before sending the body)
res.setHeader('Content-Type', 'text/html');

// 3. res.write() - Write part of the response body
// You can call this multiple times for large responses
res.write('<html><body>');
res.write('<h1>Hello</h1>');

// 4. res.end() - Finish the response and send everything
// This must be called exactly once per request
res.end('</body></html>');

// 5. res.statusCode - Set the status code directly
// Alternative to writeHead()
res.statusCode = 200;
res.setHeader('Content-Type', 'text/plain');
res.end('Hello World');
```

### Common HTTP Status Codes

| Status Code | Meaning | When to Use |
|-------------|---------|-------------|
| 200 | OK | Everything went well, here's the data |
| 201 | Created | A new resource was successfully created |
| 204 | No Content | Success but nothing to return |
| 301 | Moved Permanently | The resource has a new URL |
| 302 | Found | Temporary redirect |
| 400 | Bad Request | The request is invalid or malformed |
| 401 | Unauthorized | Authentication is required |
| 403 | Forbidden | Authenticated but not allowed |
| 404 | Not Found | The requested resource doesn't exist |
| 500 | Internal Server Error | Something went wrong on the server |

---

## Handling Different HTTP Methods

So far, we've only handled GET requests. Let's add support for POST requests (sending data to the server).

### Server with POST Support

Create `server-http-post.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-http-post.js
// DESCRIPTION: HTTP server that handles POST requests
// =====================================================

const http = require('http');
const PORT = 3000;

// We'll store data in memory (this resets when the server restarts)
let messages = [
    { id: 1, text: 'Hello, world!', timestamp: Date.now() },
    { id: 2, text: 'Node.js is awesome!', timestamp: Date.now() },
];

// Helper function to parse JSON from the request body
function parseRequestBody(req) {
    return new Promise((resolve, reject) => {
        let body = '';
        
        // The 'data' event is emitted as chunks of data arrive
        req.on('data', (chunk) => {
            body += chunk.toString();
        });
        
        // The 'end' event is emitted when all data has been received
        req.on('end', () => {
            try {
                if (body) {
                    resolve(JSON.parse(body));
                } else {
                    resolve(null);
                }
            } catch (error) {
                reject(error);
            }
        });
        
        // Handle errors
        req.on('error', (error) => {
            reject(error);
        });
    });
}

const server = http.createServer(async (req, res) => {
    console.log(`📨 ${req.method} ${req.url}`);
    
    // Parse the URL to get the path (without query parameters)
    const urlParts = req.url.split('?');
    const path = urlParts[0];
    
    // Route: GET / - Show the home page with a form
    if (req.method === 'GET' && path === '/') {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Message Board</title>
                <style>
                    body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                    .message { border: 1px solid #ddd; padding: 10px; margin: 10px 0; border-radius: 5px; }
                    .form-group { margin: 10px 0; }
                    input, textarea { width: 100%; padding: 8px; }
                    button { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 5px; cursor: pointer; }
                    button:hover { background: #2980b9; }
                </style>
            </head>
            <body>
                <h1>📝 Message Board</h1>
                
                <h2>Add a Message</h2>
                <form action="/messages" method="POST">
                    <div class="form-group">
                        <label for="text">Your Message:</label>
                        <textarea id="text" name="text" rows="3" required></textarea>
                    </div>
                    <button type="submit">Post Message</button>
                </form>
                
                <h2>All Messages</h2>
                ${messages.map(msg => `
                    <div class="message">
                        <strong>Message ${msg.id}</strong>
                        <p>${msg.text}</p>
                        <small>Posted: ${new Date(msg.timestamp).toLocaleString()}</small>
                    </div>
                `).join('')}
                
                ${messages.length === 0 ? '<p>No messages yet. Be the first!</p>' : ''}
            </body>
            </html>
        `);
        console.log(`✅ Rendered home page with ${messages.length} messages`);
    }
    
    // Route: POST /messages - Create a new message
    else if (req.method === 'POST' && path === '/messages') {
        try {
            // For simplicity, we'll handle both JSON and form data
            let body = '';
            req.on('data', (chunk) => {
                body += chunk.toString();
            });
            
            req.on('end', () => {
                let text;
                
                // Check if it's JSON or form data
                if (req.headers['content-type'] === 'application/json') {
                    const data = JSON.parse(body);
                    text = data.text;
                } else {
                    // Form data: "text=Hello+World"
                    const params = new URLSearchParams(body);
                    text = params.get('text');
                }
                
                if (!text || text.trim() === '') {
                    res.writeHead(400, { 'Content-Type': 'text/plain' });
                    res.end('Error: Message text is required');
                    return;
                }
                
                // Create the new message
                const newMessage = {
                    id: messages.length + 1,
                    text: text.trim(),
                    timestamp: Date.now(),
                };
                messages.push(newMessage);
                
                // Send a success response
                if (req.headers['content-type'] === 'application/json') {
                    res.writeHead(201, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ success: true, message: newMessage }));
                } else {
                    // Redirect back to the home page (for form submissions)
                    res.writeHead(303, { 'Location': '/' });
                    res.end();
                }
                
                console.log(`✅ Added message ${newMessage.id}: "${newMessage.text}"`);
            });
        } catch (error) {
            console.error('❌ Error processing POST request:', error);
            res.writeHead(400, { 'Content-Type': 'text/plain' });
            res.end('Invalid request data');
        }
    }
    
    // Route: GET /api/messages - Get all messages as JSON
    else if (req.method === 'GET' && path === '/api/messages') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            count: messages.length,
            data: messages
        }));
        console.log(`✅ Returned ${messages.length} messages as JSON`);
    }
    
    // 404 - Not Found
    else {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end(`
            <!DOCTYPE html>
            <html>
            <head><title>404</title></head>
            <body>
                <h1>404 - Page Not Found</h1>
                <p>Path: ${path}</p>
                <p><a href="/">Go Home</a></p>
            </body>
            </html>
        `);
        console.log(`❌ 404 Not Found: ${path}`);
    }
});

server.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Message Board Server running!`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available endpoints:`);
    console.log(`   GET  /              - Home page with form`);
    console.log(`   POST /messages      - Create a new message`);
    console.log(`   GET  /api/messages  - Get all messages as JSON`);
    console.log(`===================================`);
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});

// Error handling and graceful shutdown (same as before)
server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use.`);
    } else {
        console.error('❌ Server error:', error);
    }
});

process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down server...');
    server.close(() => {
        console.log('✅ Server closed gracefully');
        process.exit(0);
    });
});
```

Run this server:

```bash
node server-http-post.js
```

Now you can:
1. Go to http://localhost:3000/ to see the message board
2. Post messages using the form
3. See them appear on the page
4. Visit http://localhost:3000/api/messages to see the JSON API

---

## The Limitations of the Built-in http Module

Now that we've built a server with the http module, you might be thinking, "This works, but..." You're right. The built-in module has several limitations that make building real applications tedious:

### 1. Manual Request Parsing
We had to manually parse the request body, handling chunks of data and parsing JSON or form data. This is repetitive and error-prone.

### 2. Manual Route Matching
We had to write if-else statements to match URLs and HTTP methods. This gets messy quickly as the number of routes grows.

### 3. No Middleware Support
There's no concept of middleware (functions that run before the request handler). This means we can't easily add logging, authentication, or other cross-cutting concerns.

### 4. No Helpers for Common Tasks
We had to manually set headers, handle JSON, deal with static files, and implement redirects. Frameworks provide helpers for all of these.

### 5. No Project Structure
There's no guidance on how to organize code. As the project grows, it becomes hard to maintain.

**This is where Express comes in.** In Part 3, we'll rebuild the same server with Express and see how it solves all these problems with cleaner, more readable, and more maintainable code.

---

## What We've Learned

In this part, we covered:

1. **What an HTTP server is** — A program that listens for and responds to HTTP requests
2. **How HTTP works** — Requests and responses with methods, URLs, headers, and bodies
3. **Node.js's http module** — Built-in module for creating servers
4. **Creating a basic server** — Using `http.createServer()` and `server.listen()`
5. **Handling different routes** — Matching URLs and sending different responses
6. **Working with the request object** — Reading methods, URLs, and headers
7. **Working with the response object** — Setting status codes, headers, and sending bodies
8. **Handling POST requests** — Reading and parsing request bodies
9. **Serving HTML and JSON** — Different content types for different purposes
10. **Limitations of the http module** — Why we need frameworks like Express

---

## Practice Exercises

### Exercise 1: Add a New Route
Add a new route to `server-http-routes.js` called `/api/books` that returns a list of books (with `id`, `title`, and `author`). Test it in the browser.

### Exercise 2: Add a DELETE Endpoint
Add a DELETE endpoint to `server-http-post.js` that deletes a message by ID. The endpoint should be `/api/messages/:id` (e.g., `/api/messages/1`). Use `curl` to test it.

**Hint:** Parse the URL to get the ID: `const id = parseInt(path.split('/')[3])`

### Exercise 3: Query Parameters
Modify `/api/messages` to accept a `limit` query parameter. For example, `/api/messages?limit=2` should return only the last 2 messages.

**Hint:** Check out the `url` module: `const url = require('url'); const parsed = url.parse(req.url, true); const limit = parsed.query.limit;`

### Exercise 4: Create a Simple Counter
Create a new endpoint `/counter` that:
- On GET: Returns the current count
- On POST: Increments the count
- On DELETE: Resets the count to 0

---

## Summary

You've now built HTTP servers using Node.js's built-in `http` module. You understand:

- How servers handle requests and send responses
- How to parse URLs and request methods
- How to serve different content types (HTML, JSON)
- How to handle POST requests and read request bodies
- The limitations that make Express a better choice for real applications

**In Part 3**, we'll install Express and rebuild our server with far less code. You'll see firsthand how a framework simplifies development while giving you more power and flexibility.

---

## Quick Reference: http Module

| Method/Property | Description |
|-----------------|-------------|
| `http.createServer(handler)` | Creates an HTTP server |
| `server.listen(port, callback)` | Starts the server listening |
| `server.close(callback)` | Stops the server |
| `req.method` | The HTTP method (GET, POST, etc.) |
| `req.url` | The full URL path with query string |
| `req.headers` | Request headers as an object |
| `req.on('data', callback)` | Handles chunks of request body |
| `req.on('end', callback)` | Called when request body is complete |
| `res.writeHead(status, headers)` | Sets status code and headers |
| `res.setHeader(name, value)` | Sets a single header |
| `res.write(data)` | Writes part of the response body |
| `res.end(data)` | Finishes and sends the response |
| `res.statusCode` | Sets the status code directly |
In Part 3, we'll meet Express — the framework that will make building servers much easier. You'll see how Express reduces our code by about 70% while adding powerful features like routing, middleware, and better error handling. Ready to level up? Let's go!
