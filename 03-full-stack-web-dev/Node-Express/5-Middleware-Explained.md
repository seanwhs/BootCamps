# Part 5: Middleware Explained

Welcome to Part 5! In Part 4, we mastered routing and organized our code with `express.Router()`. Now we're going to explore one of Express's most powerful and distinctive features: **middleware**.

Middleware is the secret sauce that makes Express so flexible and powerful. Understanding middleware is essential for building real-world applications, as it's used for everything from logging to authentication to error handling.

By the end of this part, you'll understand:
- What middleware is and how it works
- The middleware pipeline concept
- Built-in middleware (like `express.json()` and `express.static()`)
- Creating custom middleware
- Logging, authentication, and error handling middleware
- Third-party middleware

---

## What Is Middleware?

**Middleware** is a function that executes during the request-response cycle, **in the middle** between when the request arrives and when the response is sent.

Think of middleware like **security checkpoints at an airport**:

```
You enter → Check-in (logging) → Security (authentication) → Gate (routing) → Board (response)
```

Each checkpoint:
1. Receives you (the request)
2. Can examine you (check your data)
3. Can modify you (add information)
4. Can stop you (send an error response)
5. Can pass you to the next checkpoint (call `next()`)

### The Middleware Pipeline

In Express, middleware functions are arranged in a **pipeline**. When a request arrives, it flows through each middleware in order:

```
Request → Middleware 1 → Middleware 2 → Middleware 3 → Route Handler → Response
              ↓              ↓              ↓              ↓
            next()         next()         next()        res.send()
```

Each middleware can:
1. **Do something** (log, authenticate, parse data)
2. **Modify the request or response** (add properties, set headers)
3. **End the request-response cycle** (send a response)
4. **Call `next()`** to pass control to the next middleware

If a middleware doesn't call `next()` and doesn't send a response, the request will hang indefinitely.

### Middleware Function Signature

A middleware function has this signature:

```javascript
function middleware(req, res, next) {
    // req: Request object
    // res: Response object
    // next: Function to call the next middleware in the pipeline
    
    // Do something here
    
    // Either:
    // 1. Send a response (end the cycle)
    // 2. Call next() (continue to the next middleware)
}
```

---

## Built-in Middleware

Express comes with several built-in middleware functions:

| Middleware | Purpose | Code |
|------------|---------|------|
| `express.json()` | Parse JSON request bodies | `app.use(express.json())` |
| `express.urlencoded()` | Parse URL-encoded form data | `app.use(express.urlencoded({ extended: true }))` |
| `express.static()` | Serve static files | `app.use(express.static('public'))` |
| `express.text()` | Parse text request bodies | `app.use(express.text())` |
| `express.raw()` | Parse raw request bodies | `app.use(express.raw())` |

### Example: Using Built-in Middleware

```javascript
const express = require('express');
const app = express();

// 1. Parse JSON request bodies
// This adds parsed JSON to req.body
app.use(express.json());

// 2. Parse URL-encoded form data
// This adds parsed form data to req.body
app.use(express.urlencoded({ extended: true }));

// 3. Serve static files from 'public' directory
// Files in public/ are served automatically
app.use(express.static('public'));

// Now routes can access req.body
app.post('/api/users', (req, res) => {
    // req.body contains parsed JSON or form data
    console.log('Received data:', req.body);
    res.json({ received: req.body });
});
```

---

## Creating Custom Middleware

Let's create our own middleware functions to understand how they work.

### 1. Basic Logging Middleware

Create `server-middleware.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-middleware.js
// DESCRIPTION: Demonstrating custom middleware
// =====================================================

const express = require('express');
const app = express();
const PORT = 3000;

// =====================================================
// CUSTOM MIDDLEWARE EXAMPLES
// =====================================================

// 1. Simple logging middleware
// This runs for EVERY request that comes in
const loggerMiddleware = (req, res, next) => {
    // Get the current timestamp
    const timestamp = new Date().toISOString();
    
    // Log request details
    console.log(`[${timestamp}] ${req.method} ${req.url}`);
    
    // Log headers (useful for debugging)
    console.log(`  Headers:`, req.headers);
    
    // Pass control to the next middleware or route handler
    // Without this, the request would hang
    next();
};

// Apply the logger middleware to all routes
// Order matters! This will run first for all requests
app.use(loggerMiddleware);

// 2. Request timing middleware
// Measures how long a request takes
const timingMiddleware = (req, res, next) => {
    // Record start time
    const start = Date.now();
    
    // Store the original end method
    const originalEnd = res.end;
    
    // Override res.end to add timing
    res.end = function(...args) {
        const duration = Date.now() - start;
        console.log(`⏱️ ${req.method} ${req.url} took ${duration}ms`);
        
        // Call the original end method
        originalEnd.apply(this, args);
    };
    
    next();
};

app.use(timingMiddleware);

// 3. Authentication middleware (simplified)
// Checks for an API key in headers
const authMiddleware = (req, res, next) => {
    const apiKey = req.headers['x-api-key'];
    
    // For demo purposes, only 'secret-key-123' is valid
    if (!apiKey || apiKey !== 'secret-key-123') {
        console.log('❌ Authentication failed');
        return res.status(401).json({
            success: false,
            error: 'Unauthorized: Invalid API key'
        });
    }
    
    console.log('✅ Authentication successful');
    
    // Add user info to the request for downstream use
    req.user = {
        id: 1,
        name: 'Authenticated User',
        apiKey: apiKey
    };
    
    next();
};

// 4. Validation middleware
// Validates request body for specific fields
const validateUserMiddleware = (req, res, next) => {
    const { name, email } = req.body;
    
    if (!name || name.trim() === '') {
        return res.status(400).json({
            success: false,
            error: 'Name is required and cannot be empty'
        });
    }
    
    if (!email || !email.includes('@')) {
        return res.status(400).json({
            success: false,
            error: 'Valid email is required'
        });
    }
    
    // Clean the data
    req.body.name = name.trim();
    req.body.email = email.trim();
    
    console.log('✅ Validation passed');
    next();
};

// 5. Rate limiting middleware (simplified)
// Limits requests from the same IP
const rateLimiterMiddleware = (() => {
    const requests = new Map(); // Store request counts per IP
    const WINDOW_MS = 60 * 1000; // 1 minute window
    const MAX_REQUESTS = 5; // Max requests per window
    
    return (req, res, next) => {
        const ip = req.ip || req.connection.remoteAddress;
        const now = Date.now();
        
        // Get or create request records for this IP
        if (!requests.has(ip)) {
            requests.set(ip, []);
        }
        
        const timestamps = requests.get(ip);
        
        // Remove timestamps older than the window
        const recentRequests = timestamps.filter(t => now - t < WINDOW_MS);
        
        if (recentRequests.length >= MAX_REQUESTS) {
            console.log(`❌ Rate limit exceeded for IP: ${ip}`);
            return res.status(429).json({
                success: false,
                error: 'Too many requests. Please try again later.'
            });
        }
        
        // Add current timestamp
        recentRequests.push(now);
        requests.set(ip, recentRequests);
        
        console.log(`✅ Rate limit OK for ${ip}: ${recentRequests.length}/${MAX_REQUESTS}`);
        next();
    };
})();

// 6. Response time header middleware
const responseHeaderMiddleware = (req, res, next) => {
    // Add a custom header to all responses
    res.setHeader('X-Powered-By', 'Express');
    res.setHeader('X-Response-Time', Date.now());
    next();
};

// 7. Error handling middleware
// This has four parameters (err, req, res, next)
// Express recognizes error-handling middleware by the 4 parameters
const errorHandlerMiddleware = (err, req, res, next) => {
    console.error('❌ Error caught by error handler:', err);
    
    // Log the stack trace in development
    console.error(err.stack);
    
    // Send a clean error response
    res.status(err.status || 500).json({
        success: false,
        error: err.message || 'Internal server error',
        // Only include stack in development
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};

// =====================================================
// APPLYING MIDDLEWARE
// =====================================================

// Apply middleware that runs for ALL routes
// Order matters - they run in the order defined
app.use(responseHeaderMiddleware);
app.use(rateLimiterMiddleware);

// Apply body parsing middleware (built-in)
// These need to be BEFORE routes that need req.body
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Apply logging middleware (we already defined this)
app.use(loggerMiddleware);

// =====================================================
// ROUTES
// =====================================================

// 1. Public route - No authentication required
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Middleware Demo</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
                .feature { background: #f4f4f4; padding: 10px; margin: 5px 0; border-radius: 5px; }
            </style>
        </head>
        <body>
            <h1>🛡️ Middleware Demo</h1>
            <p>This server demonstrates various middleware concepts.</p>
            
            <h2>Features</h2>
            <div class="feature">✅ Logging middleware</div>
            <div class="feature">✅ Request timing</div>
            <div class="feature">✅ Rate limiting (5 requests/min)</div>
            <div class="feature">✅ Authentication (API key required for /protected)</div>
            <div class="feature">✅ Validation for POST requests</div>
            <div class="feature">✅ Custom response headers</div>
            <div class="feature">✅ Error handling</div>
            
            <h2>Try It</h2>
            <p><code>curl http://localhost:${PORT}/public</code></p>
            <p><code>curl -H "x-api-key: secret-key-123" http://localhost:${PORT}/protected</code></p>
            <p><code>curl -X POST -H "Content-Type: application/json" -d '{"name":"Alice","email":"alice@example.com"}' http://localhost:${PORT}/api/users</code></p>
            <p><code>curl http://localhost:${PORT}/error-test</code></p>
        </body>
        </html>
    `);
});

// 2. Public route - No auth required
app.get('/public', (req, res) => {
    res.json({
        success: true,
        message: 'This is a public endpoint',
        timestamp: new Date().toISOString()
    });
});

// 3. Protected route - Requires authentication
// This route uses the auth middleware
app.get('/protected', authMiddleware, (req, res) => {
    // req.user is available because authMiddleware added it
    res.json({
        success: true,
        message: 'You accessed a protected endpoint!',
        user: req.user
    });
});

// 4. Protected route with multiple middleware
// Middleware runs in order: authMiddleware, then the route handler
app.post('/protected-data', authMiddleware, (req, res) => {
    res.json({
        success: true,
        message: 'Protected data received',
        user: req.user,
        received: req.body
    });
});

// 5. Route with validation middleware
app.post('/api/users', validateUserMiddleware, (req, res) => {
    // req.body has been validated and cleaned by the middleware
    const { name, email } = req.body;
    
    // In a real app, we'd save to a database
    const newUser = {
        id: Date.now(),
        name,
        email,
        createdAt: new Date().toISOString()
    };
    
    res.status(201).json({
        success: true,
        message: 'User created successfully',
        data: newUser
    });
});

// 6. Route that triggers an error
app.get('/error-test', (req, res, next) => {
    try {
        // Simulate an error
        throw new Error('Something went wrong! This is a test error.');
    } catch (error) {
        // Pass the error to the error handling middleware
        next(error);
    }
});

// 7. Route that triggers a different error
app.get('/async-error', async (req, res, next) => {
    try {
        // Simulate an async error
        await new Promise((resolve, reject) => {
            setTimeout(() => reject(new Error('Async error!')), 100);
        });
    } catch (error) {
        next(error);
    }
});

// =====================================================
// 404 HANDLER
// =====================================================

// This should be after all routes but before error handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: `Route ${req.method} ${req.url} not found`
    });
});

// =====================================================
// ERROR HANDLING MIDDLEWARE
// =====================================================

// This must be the LAST middleware
// It catches any errors passed to next()
app.use(errorHandlerMiddleware);

// =====================================================
// START THE SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Middleware Demo Server`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available endpoints:`);
    console.log(`   GET  /                 - Home page`);
    console.log(`   GET  /public           - Public endpoint`);
    console.log(`   GET  /protected        - Requires API key`);
    console.log(`   POST /protected-data   - Requires API key`);
    console.log(`   POST /api/users        - Validates data`);
    console.log(`   GET  /error-test       - Triggers error`);
    console.log(`===================================`);
    console.log(`🔑 API Key: secret-key-123`);
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});
```

Run this server:

```bash
node server-middleware.js
```

Now test it:

```bash
# Public endpoint - No auth required
curl http://localhost:3000/public

# Protected endpoint - Missing API key (should fail)
curl http://localhost:3000/protected

# Protected endpoint - With API key (should succeed)
curl -H "x-api-key: secret-key-123" http://localhost:3000/protected

# Rate limiting - Make 6 requests quickly to see rate limiting
for i in {1..6}; do curl http://localhost:3000/public; done

# Validation - Missing email (should fail)
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice"}'

# Validation - Valid data (should succeed)
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}'

# Error handling
curl http://localhost:3000/error-test
```

---

## Middleware Order Matters!

The order in which you apply middleware is crucial. Middleware runs in the order it's defined:

```javascript
// CORRECT ORDER:
app.use(express.json());          // 1. Parse JSON
app.use(loggerMiddleware);        // 2. Log the request
app.use(authMiddleware);          // 3. Authenticate
app.get('/users', handler);       // 4. Handle the route
app.use(errorHandlerMiddleware);  // 5. Handle errors

// WRONG ORDER (common mistakes):
app.get('/users', handler);       // 1. Route handler runs first
app.use(express.json());          // 2. JSON parsing never runs!
// The route handler would run before JSON is parsed, so req.body is undefined
```

### Common Middleware Order Best Practices:

1. **Third-party/global middleware** first (cors, helmet, compression)
2. **Parsing middleware** (json, urlencoded)
3. **Logging middleware** (to log after parsing)
4. **Authentication middleware** (to check before routes)
5. **Routes** (specific route handlers)
6. **404 handler** (catch-all for unmatched routes)
7. **Error handler** (last, catches all errors)

---

## Third-Party Middleware

The Express ecosystem has many useful third-party middleware packages:

| Package | Purpose | Installation |
|---------|---------|--------------|
| `cors` | Enable Cross-Origin Resource Sharing | `npm install cors` |
| `helmet` | Security headers | `npm install helmet` |
| `compression` | Compress responses | `npm install compression` |
| `morgan` | HTTP request logger | `npm install morgan` |
| `express-rate-limit` | Rate limiting | `npm install express-rate-limit` |
| `express-session` | Session management | `npm install express-session` |
| `cookie-parser` | Parse cookies | `npm install cookie-parser` |

### Example: Using Third-Party Middleware

```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const app = express();

// Security: Add security headers
app.use(helmet());

// Logging: Log HTTP requests
app.use(morgan('combined'));

// Performance: Compress responses
app.use(compression());

// CORS: Enable cross-origin requests
app.use(cors());

// Rate limiting: Limit repeated requests
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Now your routes...
app.get('/api/data', (req, res) => {
    res.json({ data: 'Protected data' });
});
```

---

## Advanced Middleware Patterns

### 1. Middleware with Configuration

```javascript
// Middleware factory - returns a configured middleware function
const requireAuth = (roles = []) => {
    return (req, res, next) => {
        // Check if user is authenticated
        if (!req.user) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        
        // Check if user has required role
        if (roles.length > 0 && !roles.includes(req.user.role)) {
            return res.status(403).json({ error: 'Forbidden' });
        }
        
        next();
    };
};

// Usage:
app.get('/admin', requireAuth(['admin']), (req, res) => {
    res.json({ message: 'Admin only' });
});

app.get('/profile', requireAuth(), (req, res) => {
    res.json({ message: 'Any authenticated user' });
});
```

### 2. Middleware with Async/Await

```javascript
// Async middleware wrapper
const asyncHandler = (fn) => {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

// Usage:
app.get('/async-data', asyncHandler(async (req, res) => {
    const data = await fetchDataFromDatabase();
    res.json({ data });
}));
```

### 3. Conditional Middleware

```javascript
// Only run middleware in development
if (process.env.NODE_ENV === 'development') {
    app.use((req, res, next) => {
        console.log('🔧 Development mode - detailed logging');
        console.log('  Body:', req.body);
        next();
    });
}

// Only run middleware for specific paths
const adminLogger = (req, res, next) => {
    console.log(`🔹 Admin access: ${req.method} ${req.url}`);
    next();
};

// Only applies to /admin routes
app.use('/admin', adminLogger);
```

---

## Common Middleware Use Cases

### 1. Logging

```javascript
const requestLogger = (req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    console.log(`  IP: ${req.ip}`);
    console.log(`  User-Agent: ${req.get('User-Agent')}`);
    next();
};
```

### 2. Authentication

```javascript
const authenticate = (req, res, next) => {
    const token = req.headers['authorization'];
    
    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }
    
    try {
        // In real app: verify JWT
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
};
```

### 3. Data Validation

```javascript
const validateUser = (req, res, next) => {
    const { email, password } = req.body;
    
    if (!email || !email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
        return res.status(400).json({ error: 'Invalid email' });
    }
    
    if (!password || password.length < 8) {
        return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }
    
    next();
};
```

### 4. Error Handling

```javascript
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);
    
    const status = err.status || 500;
    const message = err.message || 'Internal server error';
    
    res.status(status).json({
        success: false,
        error: message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};
```

---

## What We've Learned

In this part, we covered:

1. **What middleware is** — Functions that run in the request-response pipeline
2. **The middleware pipeline** — How requests flow through middleware
3. **Built-in middleware** — `express.json()`, `express.urlencoded()`, `express.static()`
4. **Creating custom middleware** — Logging, timing, authentication, validation, rate limiting
5. **Middleware order** — The importance of ordering in the pipeline
6. **Third-party middleware** — cors, helmet, morgan, compression
7. **Advanced patterns** — Configurable middleware, async middleware, conditional middleware
8. **Common use cases** — Logging, authentication, validation, error handling

---

## Practice Exercises

### Exercise 1: Request ID Middleware
Create a middleware that generates a unique ID for each request and adds it to the request object as `req.requestId`. Also add it to the response headers as `X-Request-Id`. Log the request ID with each request.

### Exercise 2: Slow Down Middleware
Create a middleware that adds a 1-second delay to all requests in development mode (but not in production). This simulates a slow network connection.

### Exercise 3: Compression Middleware
Implement a middleware that compresses responses if the client accepts compression (check the `Accept-Encoding` header). Use Node.js's built-in `zlib` module.

### Exercise 4: API Version Middleware
Create a middleware that checks for an API version in the URL or headers. If the version isn't supported, return a 400 error with a message listing supported versions.

---

## Summary

Middleware is the foundation of Express's power and flexibility. It allows you to:

- **Process requests** before they reach route handlers
- **Add cross-cutting concerns** like logging and authentication
- **Parse and validate data** consistently
- **Handle errors** in a centralized way
- **Organize code** into reusable, modular pieces

With middleware, you can build complex applications with clean, maintainable code. Every feature you've seen — from logging to authentication to rate limiting — can be implemented as middleware.

**In Part 6**, we'll apply what we've learned about middleware to handle forms and JSON requests, building a complete user input system with validation and error handling.

---

## Quick Reference: Middleware

| Concept | Code | Description |
|---------|------|-------------|
| Middleware function | `(req, res, next) => {}` | Standard middleware signature |
| Apply middleware | `app.use(middleware)` | Applies to all routes |
| Apply to specific route | `app.get('/path', middleware, handler)` | Applies only to that route |
| Apply to router | `router.use(middleware)` | Applies to all routes in router |
| Error middleware | `(err, req, res, next) => {}` | 4 parameters = error handler |
| Skip to next | `next()` | Continue to next middleware |
| Skip to error | `next(error)` | Jump to error handler |
| End the cycle | `res.send()` or `res.json()` | Send response, don't call next |
| JSON parser | `app.use(express.json())` | Parse JSON bodies |
| URL parser | `app.use(express.urlencoded())` | Parse form data |
| Static files | `app.use(express.static('public'))` | Serve static files |
