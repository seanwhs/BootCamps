# Part 3: Meet Express

Welcome to Part 3! In Part 2, we built HTTP servers using Node.js's built-in `http` module. We saw how much manual work is involved — parsing URLs, handling request bodies, matching routes, and managing responses. It works, but it's tedious and gets messy as projects grow.

Now we're going to meet **Express**, a web framework for Node.js that makes building servers dramatically easier. Express is the most popular Node.js framework, and for good reason. It reduces boilerplate code, adds powerful features, and provides a clean, intuitive API that beginners and experts alike love to use.

By the end of this part, you'll have built your first Express server, understand how it works, and appreciate why it's the go-to choice for Node.js web development.

---

## What Is Express?

**Express** is a lightweight, flexible web application framework for Node.js. It provides a robust set of features for building web and mobile applications, APIs, and microservices.

Think of Express as a **well-organized kitchen** compared to the `http` module's bare-bones pantry:

| HTTP Module | Express |
|-------------|---------|
| Like having ingredients but no recipes | Like having a chef's kitchen with prep stations, tools, and recipes |
| You figure out how to do everything yourself | Common tasks are already solved for you |
| More flexibility but more work | Less manual work but still plenty of flexibility |
| Good for learning fundamentals | Good for building real applications quickly |

### What Express Gives Us

| Feature | What It Does | Why It Matters |
|---------|--------------|----------------|
| **Routing** | Cleanly maps URLs and HTTP methods to handler functions | No more messy if-else statements |
| **Middleware** | Functions that run in sequence between request and response | Add logging, authentication, parsing, etc. |
| **Request Helpers** | Easy access to query strings, parameters, and body data | `req.query`, `req.params`, `req.body` |
| **Response Helpers** | Methods for sending JSON, HTML, files, and more | `res.json()`, `res.sendFile()`, `res.render()` |
| **Error Handling** | Built-in and custom error handling middleware | Catch errors in one place |
| **Static Serving** | Serve CSS, images, JavaScript with one line | No manual file reading needed |

### Installing Express

Express is an npm package, so we need to install it. Let's set up our project for Express.

#### Step 1: Initialize the Project (If Not Done Yet)

```bash
# Make sure you're in the project directory
cd node-express-tutorial

# If you haven't created package.json yet:
npm init -y
```

#### Step 2: Install Express

```bash
npm install express
```

You'll see output like:
```
added 50 packages, and audited 51 packages in 3s
```

#### Step 3: Verify Installation

Check your `package.json` — you should see `express` listed under dependencies:

```json
{
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

---

## Your First Express Server

Let's build the simplest possible Express server and see how it compares to the `http` module version.

### Step 1: Create the Server File

Create a new file called `server-express.js`:

```bash
touch server-express.js
```

### Step 2: Write the Express Server

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-express.js
// DESCRIPTION: Our first Express server
// WHAT IT DOES: Replicates the http module server with far less code
// =====================================================

// Step 1: Import Express
// Unlike the http module, we need to install express first
const express = require('express');

// Step 2: Create the Express application
// This is our app instance - it's like the http.createServer() function
const app = express();

// Step 3: Define the port
const PORT = 3000;

// Step 4: Define routes
// Express uses app.METHOD(path, handler) where METHOD is the HTTP method
// GET request to the root path ('/')
app.get('/', (req, res) => {
    // req = request object (similar to http module but with more features)
    // res = response object (similar but with more helpers)
    
    // Express provides res.send() which automatically:
    // 1. Sets the Content-Type based on what you send
    // 2. Sets the status code (200 by default)
    // 3. Sends the response
    res.send('Hello, World! This is my first Express server! 🚀');
});

// GET request to '/about'
app.get('/about', (req, res) => {
    // We can send HTML directly
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>About Express</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                h1 { color: #2c3e50; }
            </style>
        </head>
        <body>
            <h1>📖 About Express</h1>
            <p>Express is a web framework for Node.js.</p>
            <p>It makes building servers fast and easy!</p>
            <p><a href="/">← Back to Home</a></p>
        </body>
        </html>
    `);
});

// GET request to '/api/users' - returning JSON
app.get('/api/users', (req, res) => {
    const users = [
        { id: 1, name: 'Alice', email: 'alice@example.com' },
        { id: 2, name: 'Bob', email: 'bob@example.com' },
        { id: 3, name: 'Charlie', email: 'charlie@example.com' },
    ];
    
    // res.json() automatically:
    // 1. Converts the object to JSON
    // 2. Sets Content-Type to application/json
    // 3. Sends the response
    res.json({
        success: true,
        count: users.length,
        data: users
    });
});

// GET request to '/api/posts'
app.get('/api/posts', (req, res) => {
    const posts = [
        { id: 1, title: 'First Post', content: 'This is the first post' },
        { id: 2, title: 'Second Post', content: 'This is the second post' },
    ];
    
    res.json({
        success: true,
        count: posts.length,
        data: posts
    });
});

// 404 handler - This catches any request that hasn't been matched above
// Express matches routes in order, so this should be at the end
// We use app.use() for middleware, including 404 handling
app.use((req, res) => {
    // Express provides res.status() to set the status code
    res.status(404).send(`
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
            <p>Oops! The page was not found.</p>
            <p><a href="/">Go to Home</a></p>
        </body>
        </html>
    `);
});

// Step 5: Start the server
// app.listen() is a wrapper around http.createServer().listen()
app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Express server is running!`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available routes:`);
    console.log(`   GET  /           - Home page`);
    console.log(`   GET  /about      - About page`);
    console.log(`   GET  /api/users  - User API (JSON)`);
    console.log(`   GET  /api/posts  - Post API (JSON)`);
    console.log(`===================================`);
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});

// Step 6: Error handling
// Express has built-in error handling, but we can add custom handlers
app.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use.`);
    } else {
        console.error('❌ Server error:', error);
    }
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down Express server...');
    // We need to access the server instance to close it
    // We'll learn a better way to handle this later
    process.exit(0);
});
```

### Step 3: Run the Express Server

```bash
node server-express.js
```

You should see:
```
===================================
✅ Express server is running!
📡 http://localhost:3000
===================================
📋 Available routes:
   GET  /           - Home page
   GET  /about      - About page
   GET  /api/users  - User API (JSON)
   GET  /api/posts  - Post API (JSON)
===================================
🔒 Press Ctrl+C to stop
===================================
```

### Step 4: Test Your Express Server

Visit these URLs in your browser:
- http://localhost:3000/ — See "Hello, World!"
- http://localhost:3000/about — See the about page
- http://localhost:3000/api/users — See JSON user data
- http://localhost:3000/api/posts — See JSON post data
- http://localhost:3000/anything-else — See the 404 page

---

## Comparing HTTP Module vs. Express

Let's compare the code side by side and see what Express does for us:

### HTTP Module Version (from Part 2):
```javascript
const http = require('http');

const routes = {
    '/': (req, res) => {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end('<h1>Home</h1>');
    }
};

const server = http.createServer((req, res) => {
    if (routes[req.url]) {
        routes[req.url](req, res);
    } else {
        res.writeHead(404, { 'Content-Type': 'text/html' });
        res.end('Not Found');
    }
});

server.listen(3000);
```

### Express Version:
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('<h1>Home</h1>');
});

app.use((req, res) => {
    res.status(404).send('Not Found');
});

app.listen(3000);
```

### What Express Does For You:

| Feature | HTTP Module | Express |
|---------|-------------|---------|
| **Route matching** | Manual if-else statements | `app.get('/path', handler)` |
| **Status codes** | `res.writeHead(200)` | `res.status(200)` or just `res.send()` |
| **Content type** | Manual `Content-Type` header | Auto-detected by `res.send()` |
| **JSON** | `res.end(JSON.stringify(data))` | `res.json(data)` |
| **404 handling** | Manual in request handler | `app.use()` at the end |
| **Request parsing** | Manual body parsing | Built-in middleware (coming in Part 6) |
| **Readability** | Good for small apps | Clean and declarative |

---

## Express Route Methods

Express supports all HTTP methods. Here are the most common ones:

```javascript
// GET - Retrieve data
app.get('/users', (req, res) => {
    res.json({ users: [] });
});

// POST - Create new data
app.post('/users', (req, res) => {
    // Create a new user
    res.status(201).json({ message: 'User created' });
});

// PUT - Update data (replace entire resource)
app.put('/users/:id', (req, res) => {
    // Update user with ID
    res.json({ message: 'User updated' });
});

// PATCH - Partial update
app.patch('/users/:id', (req, res) => {
    // Partially update user with ID
    res.json({ message: 'User partially updated' });
});

// DELETE - Delete data
app.delete('/users/:id', (req, res) => {
    // Delete user with ID
    res.json({ message: 'User deleted' });
});

// ALL - All HTTP methods for a path
app.all('/test', (req, res) => {
    // This will handle GET, POST, PUT, DELETE, etc.
    res.send('This handles all methods');
});

// USE - Middleware (will be covered in detail in Part 5)
app.use((req, res, next) => {
    console.log('Middleware running');
    next(); // Pass control to the next handler
});
```

---

## Express Response Methods

Express adds powerful methods to the response object:

```javascript
// res.send() - Send any type of data (auto-detects content type)
res.send('Hello');                    // Sends as text/html
res.send({ message: 'Hello' });       // Sends as application/json
res.send('<h1>Hello</h1>');          // Sends as text/html

// res.json() - Force JSON response
res.json({ message: 'Hello' });

// res.status() - Set HTTP status code
res.status(201).json({ message: 'Created' });

// res.sendStatus() - Send status code with default message
res.sendStatus(404);  // Sends "Not Found" with status 404

// res.set() - Set headers
res.set('X-Custom-Header', 'Value');

// res.redirect() - Redirect to another URL
res.redirect('/new-page');
res.redirect(301, '/permanent-redirect');

// res.download() - Send a file as download
res.download('file.pdf');

// res.sendFile() - Send a file from the server
res.sendFile('/path/to/file.html');

// res.render() - Render a view template (with a view engine)
res.render('index', { title: 'Home' });
```

---

## Request Methods in Express

Express also adds useful properties to the request object:

```javascript
// req.params - Route parameters (from :id in the route)
app.get('/users/:id', (req, res) => {
    const userId = req.params.id;
    res.json({ userId });
});

// req.query - Query string parameters
// URL: /search?q=express&page=2
app.get('/search', (req, res) => {
    const searchTerm = req.query.q;    // 'express'
    const page = req.query.page;        // '2'
    res.json({ searchTerm, page });
});

// req.body - Request body (requires middleware, covered in Part 6)
app.post('/users', (req, res) => {
    const userData = req.body;
    res.json(userData);
});

// req.headers - Headers object
app.get('/headers', (req, res) => {
    const userAgent = req.headers['user-agent'];
    res.json({ userAgent });
});

// req.ip - Client IP address
app.get('/ip', (req, res) => {
    res.json({ ip: req.ip });
});

// req.path - URL path
app.get('/info', (req, res) => {
    res.json({ path: req.path });
});
```

---

## The Message Board App with Express

Let's rebuild our message board app from Part 2 using Express. This will show you how much cleaner the code becomes.

Create `server-express-board.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-express-board.js
// DESCRIPTION: Message board app rebuilt with Express
// =====================================================

const express = require('express');
const app = express();

// Import a helper to parse URL-encoded form data
// This is built into Express (we'll cover it in detail in Part 6)
app.use(express.urlencoded({ extended: true }));

// Also support JSON requests
app.use(express.json());

const PORT = 3000;

// In-memory storage
let messages = [
    { id: 1, text: 'Hello, world!', timestamp: Date.now() },
    { id: 2, text: 'Express is awesome!', timestamp: Date.now() },
];

// =====================================================
// ROUTES
// =====================================================

// GET / - Home page with message board
app.get('/', (req, res) => {
    // Generate HTML with all messages
    let messagesHtml = messages.map(msg => `
        <div class="message">
            <strong>Message ${msg.id}</strong>
            <p>${msg.text}</p>
            <small>Posted: ${new Date(msg.timestamp).toLocaleString()}</small>
        </div>
    `).join('');
    
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Message Board - Express</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                .message { border: 1px solid #ddd; padding: 10px; margin: 10px 0; border-radius: 5px; }
                .form-group { margin: 10px 0; }
                input, textarea { width: 100%; padding: 8px; box-sizing: border-box; }
                button { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 5px; cursor: pointer; }
                button:hover { background: #2980b9; }
                .container { display: flex; gap: 40px; align-items: flex-start; }
                .form-section { flex: 1; }
                .messages-section { flex: 2; }
                .stats { color: #7f8c8d; font-size: 14px; }
                .empty { color: #7f8c8d; font-style: italic; }
                .nav { margin: 20px 0; padding: 10px; background: #ecf0f1; border-radius: 5px; }
                .nav a { margin-right: 15px; color: #3498db; text-decoration: none; }
                .nav a:hover { text-decoration: underline; }
            </style>
        </head>
        <body>
            <h1>📝 Express Message Board</h1>
            
            <div class="nav">
                <a href="/">Home</a>
                <a href="/api/messages">API (JSON)</a>
                <a href="/stats">Stats</a>
            </div>
            
            <div class="container">
                <div class="form-section">
                    <h2>Add a Message</h2>
                    <form action="/messages" method="POST">
                        <div class="form-group">
                            <label for="text">Your Message:</label>
                            <textarea id="text" name="text" rows="3" placeholder="Write something..." required></textarea>
                        </div>
                        <button type="submit">Post Message</button>
                    </form>
                </div>
                
                <div class="messages-section">
                    <h2>All Messages</h2>
                    <div class="stats">${messages.length} messages</div>
                    ${messages.length > 0 ? messagesHtml : '<p class="empty">No messages yet. Be the first!</p>'}
                </div>
            </div>
        </body>
        </html>
    `);
});

// GET /stats - Show statistics
app.get('/stats', (req, res) => {
    const totalMessages = messages.length;
    const averageLength = messages.length > 0 
        ? messages.reduce((sum, msg) => sum + msg.text.length, 0) / messages.length
        : 0;
    
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Message Stats</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                .stat { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
                .stat-label { font-weight: bold; color: #2c3e50; }
                .stat-value { color: #3498db; font-size: 24px; }
            </style>
        </head>
        <body>
            <h1>📊 Message Statistics</h1>
            <a href="/">← Back to Board</a>
            
            <div class="stat">
                <div class="stat-label">Total Messages</div>
                <div class="stat-value">${totalMessages}</div>
            </div>
            <div class="stat">
                <div class="stat-label">Average Message Length</div>
                <div class="stat-value">${Math.round(averageLength)} characters</div>
            </div>
            <div class="stat">
                <div class="stat-label">Latest Message</div>
                <div class="stat-value">${messages.length > 0 ? messages[messages.length - 1].text : 'No messages'}</div>
            </div>
        </body>
        </html>
    `);
});

// POST /messages - Create a new message
app.post('/messages', (req, res) => {
    // Express automatically parses the form body into req.body
    const { text } = req.body;
    
    // Validation
    if (!text || text.trim() === '') {
        return res.status(400).send('Error: Message text is required');
    }
    
    // Create the new message
    const newMessage = {
        id: messages.length + 1,
        text: text.trim(),
        timestamp: Date.now(),
    };
    messages.push(newMessage);
    
    console.log(`✅ Added message ${newMessage.id}: "${newMessage.text}"`);
    
    // Redirect back to the home page
    // 303 See Other - tells the browser to GET the new URL
    res.redirect(303, '/');
});

// GET /api/messages - Get all messages as JSON
app.get('/api/messages', (req, res) => {
    // We can easily support query parameters
    const limit = parseInt(req.query.limit) || messages.length;
    const filteredMessages = messages.slice(-limit);
    
    res.json({
        success: true,
        count: filteredMessages.length,
        total: messages.length,
        data: filteredMessages
    });
});

// GET /api/messages/:id - Get a specific message
app.get('/api/messages/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const message = messages.find(msg => msg.id === id);
    
    if (!message) {
        return res.status(404).json({
            success: false,
            error: `Message with ID ${id} not found`
        });
    }
    
    res.json({
        success: true,
        data: message
    });
});

// DELETE /api/messages/:id - Delete a message
app.delete('/api/messages/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const index = messages.findIndex(msg => msg.id === id);
    
    if (index === -1) {
        return res.status(404).json({
            success: false,
            error: `Message with ID ${id} not found`
        });
    }
    
    const deleted = messages.splice(index, 1)[0];
    console.log(`🗑️ Deleted message ${id}: "${deleted.text}"`);
    
    res.json({
        success: true,
        message: `Message ${id} deleted`,
        data: deleted
    });
});

// 404 handler - Catch any request that wasn't matched
app.use((req, res) => {
    res.status(404).send(`
        <!DOCTYPE html>
        <html>
        <head><title>404 - Page Not Found</title></head>
        <body>
            <h1>404 - Page Not Found</h1>
            <p>The page you're looking for doesn't exist.</p>
            <a href="/">Go Home</a>
        </body>
        </html>
    `);
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('❌ Error:', err);
    res.status(500).json({
        success: false,
        error: 'Something went wrong on the server'
    });
});

// =====================================================
// START THE SERVER
// =====================================================

const server = app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Express Message Board running!`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available routes:`);
    console.log(`   GET     /                       - Message board`);
    console.log(`   GET     /stats                  - Statistics`);
    console.log(`   POST    /messages               - Create message`);
    console.log(`   GET     /api/messages           - Get all messages (JSON)`);
    console.log(`   GET     /api/messages/:id       - Get one message (JSON)`);
    console.log(`   DELETE  /api/messages/:id       - Delete message (JSON)`);
    console.log(`===================================`);
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});

// Error handling
server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        console.error(`❌ Port ${PORT} is already in use.`);
        console.error(`   Try closing other programs or using a different port.`);
    } else {
        console.error('❌ Server error:', error);
    }
});

// Graceful shutdown
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
node server-express-board.js
```

Now test it:
1. http://localhost:3000/ — See the message board with form
2. Post a message and see it appear
3. http://localhost:3000/stats — See message statistics
4. http://localhost:3000/api/messages — Get messages as JSON
5. http://localhost:3000/api/messages/1 — Get a specific message
6. Test the DELETE endpoint with curl:
   ```bash
   curl -X DELETE http://localhost:3000/api/messages/1
   ```

---

## Key Differences: HTTP Module vs. Express

Let's explicitly compare the two implementations:

| Aspect | HTTP Module | Express |
|--------|-------------|---------|
| **Code length** | Longer, more manual | Shorter, more declarative |
| **Route definition** | Manual if-else matching | `app.get()`, `app.post()`, etc. |
| **Route parameters** | Manual parsing | `req.params` object |
| **Query strings** | Manual parsing | `req.query` object |
| **Request body** | Manual chunk handling | Middleware auto-parses |
| **JSON responses** | `res.end(JSON.stringify())` | `res.json()` |
| **Status codes** | `res.writeHead()` or `res.statusCode` | `res.status()` method |
| **Error handling** | Manual try-catch | Middleware-based error handlers |
| **404 handling** | Manual in request handler | Dedicated middleware |
| **Static files** | Manual reading and sending | One line: `app.use(express.static())` |
| **Learning curve** | Steeper (more manual work) | Gentler (abstracts complexity) |

---

## What We've Learned

In this part, we covered:

1. **What Express is** — A web framework that builds on Node.js's http module
2. **Installing Express** — Using npm to install the package
3. **Creating an Express app** — `const app = express()`
4. **Defining routes** — `app.get()`, `app.post()`, etc.
5. **Sending responses** — `res.send()`, `res.json()`, `res.status()`
6. **Accessing request data** — `req.params`, `req.query`, `req.body`
7. **Handling 404 errors** — Using `app.use()` as a catch-all
8. **Comparing HTTP module vs. Express** — Understanding what Express simplifies

---

## Practice Exercises

### Exercise 1: Add a New Route
Add a `/api/messages/stats` endpoint that returns JSON statistics about messages (total count, average length, oldest, newest).

### Exercise 2: Add Query Parameters
Modify the `/api/messages` endpoint to support sorting. Add a `sort` parameter that can be `oldest` or `newest`.

### Exercise 3: Add a PUT Endpoint
Add a `PUT /api/messages/:id` endpoint that updates a message's text. Return the updated message or a 404 if not found.

### Exercise 4: Create a Simple API
Build an API with Express that manages a list of books:
- GET /books — List all books
- GET /books/:id — Get a specific book
- POST /books — Add a new book
- PUT /books/:id — Update a book
- DELETE /books/:id — Delete a book

---

## Summary

Express is a game-changer for Node.js development. It takes the manual work we did with the http module and automates it with clean, intuitive methods. With Express, you can build a complete web application or API with far less code, and that code is much more readable and maintainable.

**Key takeaways:**
- Express is a framework, not a replacement — it sits on top of the http module
- Routes are defined with `app.METHOD(path, handler)`
- Response helpers like `res.json()` and `res.send()` simplify sending data
- Request helpers like `req.params`, `req.query`, and `req.body` make data access easy
- Middleware (which we'll explore fully in Part 5) enables powerful extensibility

**In Part 4**, we'll dive deeper into routing, exploring route parameters, query strings, HTTP methods, and organizing routes into separate files. We'll build a more complex application that demonstrates the full power of Express routing.

---

## Quick Reference: Express Basics

| Method | Description | Example |
|--------|-------------|---------|
| `express()` | Create an Express app | `const app = express()` |
| `app.get(path, handler)` | Handle GET requests | `app.get('/', (req, res) => {})` |
| `app.post(path, handler)` | Handle POST requests | `app.post('/users', (req, res) => {})` |
| `app.put(path, handler)` | Handle PUT requests | `app.put('/users/:id', (req, res) => {})` |
| `app.delete(path, handler)` | Handle DELETE requests | `app.delete('/users/:id', (req, res) => {})` |
| `app.use(handler)` | Middleware | `app.use(express.json())` |
| `app.listen(port, callback)` | Start the server | `app.listen(3000, () => {})` |
| `res.send(data)` | Send response (auto-detects type) | `res.send('Hello')` |
| `res.json(data)` | Send JSON response | `res.json({ message: 'Hi' })` |
| `res.status(code)` | Set status code | `res.status(404).json({ error: 'Not found' })` |
| `res.redirect(url)` | Redirect | `res.redirect('/home')` |
| `req.params` | Route parameters | `{ id: '123' }` |
| `req.query` | Query string parameters | `{ page: '2', limit: '10' }` |
| `req.body` | Request body (with middleware) | `{ username: 'john' }` |
| `req.headers` | Headers object | `{ 'user-agent': 'Mozilla/...' }` |
