# Part 4: Routing and URL Data

Welcome to Part 4! In Part 3, we built our first Express server and learned the basics of routing with `app.get()`, `app.post()`, and other methods. Now we're going to dive deep into routing — one of Express's most powerful features.

By the end of this part, you'll master:
- Route parameters (dynamic URL segments)
- Query strings (optional data in URLs)
- All HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Organizing routes with `express.Router()`
- Building a complete API with proper route structure

---

## Understanding URL Anatomy

Before we dive into routing, let's understand what makes up a URL. This will help you understand what Express gives you access to.

```
https://example.com:3000/users/123/posts?page=2&sort=recent#comments
\______/   \______/ \__/ \____/ \_/ \____/ \______________/ \______/
  protocol   domain   port  path   id   path    query string    fragment
                              segment       (optional)        (optional)

Full breakdown:
- protocol: https (or http)
- domain: example.com (or localhost)
- port: 3000 (optional, default is 80 for http, 443 for https)
- path: /users/123/posts (the route)
- query string: ?page=2&sort=recent (key-value pairs)
- fragment: #comments (client-side only, not sent to server)
```

Express gives us three ways to access data from the URL:

| Method | What It Accesses | Example |
|--------|------------------|---------|
| `req.params` | Route parameters (dynamic segments) | `/:userId` matches `123` |
| `req.query` | Query string parameters | `?page=2` gives `{ page: '2' }` |
| `req.path` | The full path (without query string) | `/users/123/posts` |

---

## Route Parameters

Route parameters are **dynamic segments** in your URL that capture values. They're defined with a colon (`:`) in the route path.

### Basic Route Parameters

```javascript
// Single parameter
// URL: /users/123
app.get('/users/:id', (req, res) => {
    const userId = req.params.id; // '123'
    res.json({ userId });
});

// Multiple parameters
// URL: /users/123/posts/456
app.get('/users/:userId/posts/:postId', (req, res) => {
    const userId = req.params.userId; // '123'
    const postId = req.params.postId; // '456'
    res.json({ userId, postId });
});

// Optional parameters (using ?)
// URL: /users/123 or /users
app.get('/users/:id?', (req, res) => {
    const userId = req.params.id; // '123' or undefined
    res.json({ userId: userId || 'all users' });
});

// Parameters with regex constraints
// Only match if id is numeric
app.get('/users/:id(\\d+)', (req, res) => {
    // This will only match /users/123, not /users/abc
    const userId = req.params.id;
    res.json({ userId });
});
```

### Complete Example: User API with Route Parameters

Create a new file called `server-params.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-params.js
// DESCRIPTION: Demonstrating route parameters and query strings
// =====================================================

const express = require('express');
const app = express();
const PORT = 3000;

// Sample data - users with their posts
const users = [
    { id: 1, name: 'Alice', email: 'alice@example.com' },
    { id: 2, name: 'Bob', email: 'bob@example.com' },
    { id: 3, name: 'Charlie', email: 'charlie@example.com' },
];

const posts = [
    { id: 1, userId: 1, title: 'Alice\'s First Post', content: 'Hello from Alice!' },
    { id: 2, userId: 1, title: 'Alice\'s Second Post', content: 'Another post from Alice' },
    { id: 3, userId: 2, title: 'Bob\'s Post', content: 'Bob is here!' },
    { id: 4, userId: 3, title: 'Charlie\'s Post', content: 'Charlie says hi' },
];

// =====================================================
// ROUTE PARAMETERS EXAMPLES
// =====================================================

// 1. Basic route parameter - Get a single user
// URL: /users/1
app.get('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const user = users.find(u => u.id === id);
    
    if (!user) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    res.json({
        success: true,
        data: user
    });
});

// 2. Multiple route parameters - Get a specific user's post
// URL: /users/1/posts/2
app.get('/users/:userId/posts/:postId', (req, res) => {
    const userId = parseInt(req.params.userId);
    const postId = parseInt(req.params.postId);
    
    // Find the post
    const post = posts.find(p => p.id === postId && p.userId === userId);
    
    if (!post) {
        return res.status(404).json({
            success: false,
            error: `Post ${postId} not found for user ${userId}`
        });
    }
    
    res.json({
        success: true,
        data: post
    });
});

// 3. Optional parameter - Get users with optional ID
// URL: /users (returns all) or /users/1 (returns one)
app.get('/users/:id?', (req, res) => {
    const id = req.params.id;
    
    if (id) {
        // Return specific user
        const user = users.find(u => u.id === parseInt(id));
        if (!user) {
            return res.status(404).json({
                success: false,
                error: `User with ID ${id} not found`
            });
        }
        return res.json({ success: true, data: user });
    } else {
        // Return all users
        return res.json({
            success: true,
            count: users.length,
            data: users
        });
    }
});

// 4. Parameter with regex - Only numeric IDs
// URL: /users/123 (works), /users/abc (404)
app.get('/users/:id(\\d+)/profile', (req, res) => {
    const id = parseInt(req.params.id);
    const user = users.find(u => u.id === id);
    
    if (!user) {
        return res.status(404).json({
            success: false,
            error: 'User not found'
        });
    }
    
    res.json({
        success: true,
        data: {
            ...user,
            profileUrl: `/users/${id}`,
            postCount: posts.filter(p => p.userId === id).length
        }
    });
});

// =====================================================
// QUERY STRING EXAMPLES
// =====================================================

// 5. Basic query strings - Filter posts
// URL: /posts?userId=1
app.get('/posts', (req, res) => {
    let filteredPosts = [...posts];
    
    // Filter by userId if provided
    if (req.query.userId) {
        const userId = parseInt(req.query.userId);
        filteredPosts = filteredPosts.filter(p => p.userId === userId);
    }
    
    // Filter by search term (in title or content)
    if (req.query.search) {
        const search = req.query.search.toLowerCase();
        filteredPosts = filteredPosts.filter(p => 
            p.title.toLowerCase().includes(search) ||
            p.content.toLowerCase().includes(search)
        );
    }
    
    // Pagination
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const start = (page - 1) * limit;
    const end = start + limit;
    const paginatedPosts = filteredPosts.slice(start, end);
    
    res.json({
        success: true,
        count: paginatedPosts.length,
        total: filteredPosts.length,
        page: page,
        limit: limit,
        totalPages: Math.ceil(filteredPosts.length / limit),
        data: paginatedPosts
    });
});

// 6. Multiple query parameters with defaults
// URL: /search?q=hello&sort=recent&limit=5
app.get('/search', (req, res) => {
    // Destructure query params with defaults
    const { q = '', sort = 'recent', limit = 10, page = 1 } = req.query;
    
    // Simulate search results
    const results = posts.filter(p => 
        p.title.includes(q) || p.content.includes(q)
    );
    
    // Sort
    if (sort === 'recent') {
        results.sort((a, b) => b.id - a.id);
    } else if (sort === 'oldest') {
        results.sort((a, b) => a.id - b.id);
    }
    
    // Paginate
    const start = (parseInt(page) - 1) * parseInt(limit);
    const paginated = results.slice(start, start + parseInt(limit));
    
    res.json({
        success: true,
        query: q,
        sort: sort,
        count: paginated.length,
        total: results.length,
        data: paginated
    });
});

// 7. Complex query parameters
// URL: /api/advanced?fields=id,name,email&include=posts&sort=name_asc
app.get('/api/advanced', (req, res) => {
    const { fields, include, sort } = req.query;
    
    let result = users.map(user => ({ ...user }));
    
    // Field selection
    if (fields) {
        const selectedFields = fields.split(',');
        result = result.map(user => {
            const filtered = {};
            selectedFields.forEach(field => {
                if (user[field] !== undefined) {
                    filtered[field] = user[field];
                }
            });
            return filtered;
        });
    }
    
    // Include relationships
    if (include && include.includes('posts')) {
        result = result.map(user => ({
            ...user,
            posts: posts.filter(p => p.userId === user.id)
        }));
    }
    
    // Sorting
    if (sort) {
        const [field, order] = sort.split('_');
        result.sort((a, b) => {
            if (a[field] < b[field]) return order === 'asc' ? -1 : 1;
            if (a[field] > b[field]) return order === 'asc' ? 1 : -1;
            return 0;
        });
    }
    
    res.json({
        success: true,
        count: result.length,
        data: result
    });
});

// =====================================================
// COMBINING PARAMETERS AND QUERY STRINGS
// =====================================================

// Get posts for a specific user with optional filters
// URL: /users/1/posts?search=hello&limit=5
app.get('/users/:userId/posts', (req, res) => {
    const userId = parseInt(req.params.userId);
    
    // Check if user exists
    const user = users.find(u => u.id === userId);
    if (!user) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${userId} not found`
        });
    }
    
    let userPosts = posts.filter(p => p.userId === userId);
    
    // Apply query filters
    if (req.query.search) {
        const search = req.query.search.toLowerCase();
        userPosts = userPosts.filter(p => 
            p.title.toLowerCase().includes(search) ||
            p.content.toLowerCase().includes(search)
        );
    }
    
    const limit = parseInt(req.query.limit) || userPosts.length;
    const page = parseInt(req.query.page) || 1;
    const start = (page - 1) * limit;
    const paginated = userPosts.slice(start, start + limit);
    
    res.json({
        success: true,
        user: {
            id: user.id,
            name: user.name
        },
        count: paginated.length,
        total: userPosts.length,
        page: page,
        limit: limit,
        data: paginated
    });
});

// =====================================================
// ALL HTTP METHODS WITH PARAMETERS
// =====================================================

// PUT - Update a user
app.put('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    // In a real app, we'd validate and update from req.body
    // For this demo, we'll simulate an update
    const updatedUser = {
        ...users[userIndex],
        name: req.body.name || users[userIndex].name,
        email: req.body.email || users[userIndex].email
    };
    
    users[userIndex] = updatedUser;
    
    res.json({
        success: true,
        message: `User ${id} updated`,
        data: updatedUser
    });
});

// PATCH - Partial update of a user
app.patch('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    // Only update fields that are provided
    const updatedUser = {
        ...users[userIndex],
        ...req.body
    };
    
    users[userIndex] = updatedUser;
    
    res.json({
        success: true,
        message: `User ${id} partially updated`,
        data: updatedUser
    });
});

// DELETE - Delete a user
app.delete('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    const deletedUser = users.splice(userIndex, 1)[0];
    
    // Also delete their posts
    const deletedPosts = posts.filter(p => p.userId === id);
    // In a real app, we'd remove these from the database
    
    res.json({
        success: true,
        message: `User ${id} deleted`,
        data: {
            user: deletedUser,
            deletedPosts: deletedPosts.length
        }
    });
});

// =====================================================
// START THE SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Express Routing Demo Server`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Parameter Examples:`);
    console.log(`   GET  /users/:id                - Get user`);
    console.log(`   GET  /users/:id/posts/:postId  - Get specific post`);
    console.log(`   GET  /users/:id(\\d+)/profile   - Numeric ID only`);
    console.log(`   GET  /users/:id?               - Optional parameter`);
    console.log(`   GET  /posts?userId=1&search=X  - Query filters`);
    console.log(`   GET  /search?q=hello&sort=recent`);
    console.log(`   GET  /api/advanced?fields=id,name`);
    console.log(`   PUT  /users/:id                - Update user`);
    console.log(`   PATCH /users/:id               - Partial update`);
    console.log(`   DELETE /users/:id              - Delete user`);
    console.log(`===================================`);
});
```

Run this server:

```bash
node server-params.js
```

Now test these URLs:

```bash
# Route parameters
curl http://localhost:3000/users/1
curl http://localhost:3000/users/1/posts/2
curl http://localhost:3000/users/999  # Returns 404

# Query strings
curl "http://localhost:3000/posts?userId=1"
curl "http://localhost:3000/posts?search=Alice&limit=1"
curl "http://localhost:3000/search?q=hello&sort=recent&limit=5"

# Advanced query
curl "http://localhost:3000/api/advanced?fields=id,name,email&include=posts&sort=name_asc"

# Combined
curl "http://localhost:3000/users/1/posts?search=First"
```

---

## Organizing Routes with express.Router()

As your application grows, putting all routes in one file becomes messy. Express provides `express.Router()` to create modular, mountable route handlers.

**Think of a router like a department in a company:**
- The main app is the company headquarters
- Each router is a department (HR, Finance, Engineering)
- Each department handles its own responsibilities
- The company directs requests to the right department

### Creating a Router

Create a new directory structure for our organized app:

```bash
mkdir -p routes
```

Create `routes/users.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/routes/users.js
// DESCRIPTION: User routes module
// =====================================================

const express = require('express');
const router = express.Router();

// Sample user data
const users = [
    { id: 1, name: 'Alice', email: 'alice@example.com' },
    { id: 2, name: 'Bob', email: 'bob@example.com' },
    { id: 3, name: 'Charlie', email: 'charlie@example.com' },
];

// Middleware that runs only for this router
router.use((req, res, next) => {
    console.log(`🔹 Users Router: ${req.method} ${req.url}`);
    next(); // Pass to the next handler
});

// GET /users - Get all users
router.get('/', (req, res) => {
    res.json({
        success: true,
        count: users.length,
        data: users
    });
});

// GET /users/:id - Get a specific user
router.get('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const user = users.find(u => u.id === id);
    
    if (!user) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    res.json({
        success: true,
        data: user
    });
});

// POST /users - Create a new user
// Note: In a real app, we'd validate input first
router.post('/', (req, res) => {
    const { name, email } = req.body;
    
    if (!name || !email) {
        return res.status(400).json({
            success: false,
            error: 'Name and email are required'
        });
    }
    
    const newUser = {
        id: users.length + 1,
        name,
        email
    };
    
    users.push(newUser);
    
    res.status(201).json({
        success: true,
        message: 'User created',
        data: newUser
    });
});

// PUT /users/:id - Update a user
router.put('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    const { name, email } = req.body;
    users[userIndex] = {
        ...users[userIndex],
        name: name || users[userIndex].name,
        email: email || users[userIndex].email
    };
    
    res.json({
        success: true,
        message: `User ${id} updated`,
        data: users[userIndex]
    });
});

// DELETE /users/:id - Delete a user
router.delete('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const userIndex = users.findIndex(u => u.id === id);
    
    if (userIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `User with ID ${id} not found`
        });
    }
    
    const deletedUser = users.splice(userIndex, 1)[0];
    
    res.json({
        success: true,
        message: `User ${id} deleted`,
        data: deletedUser
    });
});

// Export the router to be used in the main app
module.exports = router;
```

Create `routes/posts.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/routes/posts.js
// DESCRIPTION: Posts routes module
// =====================================================

const express = require('express');
const router = express.Router();

// Sample post data
const posts = [
    { id: 1, userId: 1, title: 'Alice\'s First Post', content: 'Hello from Alice!' },
    { id: 2, userId: 1, title: 'Alice\'s Second Post', content: 'Another post from Alice' },
    { id: 3, userId: 2, title: 'Bob\'s Post', content: 'Bob is here!' },
    { id: 4, userId: 3, title: 'Charlie\'s Post', content: 'Charlie says hi' },
];

// Router-specific middleware
router.use((req, res, next) => {
    console.log(`🔹 Posts Router: ${req.method} ${req.url}`);
    next();
});

// GET /posts - Get all posts
router.get('/', (req, res) => {
    let result = [...posts];
    
    // Filter by userId
    if (req.query.userId) {
        const userId = parseInt(req.query.userId);
        result = result.filter(p => p.userId === userId);
    }
    
    res.json({
        success: true,
        count: result.length,
        data: result
    });
});

// GET /posts/:id - Get a specific post
router.get('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const post = posts.find(p => p.id === id);
    
    if (!post) {
        return res.status(404).json({
            success: false,
            error: `Post with ID ${id} not found`
        });
    }
    
    res.json({
        success: true,
        data: post
    });
});

// POST /posts - Create a new post
router.post('/', (req, res) => {
    const { userId, title, content } = req.body;
    
    if (!userId || !title || !content) {
        return res.status(400).json({
            success: false,
            error: 'userId, title, and content are required'
        });
    }
    
    const newPost = {
        id: posts.length + 1,
        userId,
        title,
        content
    };
    
    posts.push(newPost);
    
    res.status(201).json({
        success: true,
        message: 'Post created',
        data: newPost
    });
});

// PUT /posts/:id - Update a post
router.put('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const postIndex = posts.findIndex(p => p.id === id);
    
    if (postIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `Post with ID ${id} not found`
        });
    }
    
    const { title, content } = req.body;
    posts[postIndex] = {
        ...posts[postIndex],
        title: title || posts[postIndex].title,
        content: content || posts[postIndex].content
    };
    
    res.json({
        success: true,
        message: `Post ${id} updated`,
        data: posts[postIndex]
    });
});

// DELETE /posts/:id - Delete a post
router.delete('/:id', (req, res) => {
    const id = parseInt(req.params.id);
    const postIndex = posts.findIndex(p => p.id === id);
    
    if (postIndex === -1) {
        return res.status(404).json({
            success: false,
            error: `Post with ID ${id} not found`
        });
    }
    
    const deletedPost = posts.splice(postIndex, 1)[0];
    
    res.json({
        success: true,
        message: `Post ${id} deleted`,
        data: deletedPost
    });
});

module.exports = router;
```

Now create the main app file `server-router.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-router.js
// DESCRIPTION: Express app using routers for organization
// =====================================================

const express = require('express');
const app = express();

// Import our route modules
const usersRouter = require('./routes/users');
const postsRouter = require('./routes/posts');

const PORT = 3000;

// =====================================================
// MIDDLEWARE (We'll cover this deeply in Part 5)
// =====================================================

// Parse JSON request bodies
app.use(express.json());

// Parse URL-encoded form data
app.use(express.urlencoded({ extended: true }));

// Logging middleware for all requests
app.use((req, res, next) => {
    console.log(`📨 ${req.method} ${req.url}`);
    next();
});

// =====================================================
// ROUTES
// =====================================================

// Welcome route
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>API - Organized Routes</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
                .endpoint { background: #f4f4f4; padding: 10px; margin: 5px 0; border-radius: 5px; font-family: monospace; }
                .method { display: inline-block; padding: 2px 8px; border-radius: 3px; font-weight: bold; margin-right: 10px; }
                .get { background: #61affe; color: white; }
                .post { background: #49cc90; color: white; }
                .put { background: #fca130; color: white; }
                .delete { background: #f93e3e; color: white; }
            </style>
        </head>
        <body>
            <h1>🚀 Organized Express API</h1>
            <p>This API demonstrates route organization with <code>express.Router()</code></p>
            
            <h2>Available Endpoints</h2>
            
            <h3>Users</h3>
            <div class="endpoint"><span class="method get">GET</span> /users - Get all users</div>
            <div class="endpoint"><span class="method get">GET</span> /users/:id - Get a specific user</div>
            <div class="endpoint"><span class="method post">POST</span> /users - Create a user</div>
            <div class="endpoint"><span class="method put">PUT</span> /users/:id - Update a user</div>
            <div class="endpoint"><span class="method delete">DELETE</span> /users/:id - Delete a user</div>
            
            <h3>Posts</h3>
            <div class="endpoint"><span class="method get">GET</span> /posts - Get all posts</div>
            <div class="endpoint"><span class="method get">GET</span> /posts/:id - Get a specific post</div>
            <div class="endpoint"><span class="method post">POST</span> /posts - Create a post</div>
            <div class="endpoint"><span class="method put">PUT</span> /posts/:id - Update a post</div>
            <div class="endpoint"><span class="method delete">DELETE</span> /posts/:id - Delete a post</div>
            
            <h3>Try It</h3>
            <p>Use <code>curl</code> or a tool like Postman to test the API endpoints.</p>
            <p>Example: <code>curl http://localhost:${PORT}/users</code></p>
        </body>
        </html>
    `);
});

// Mount the user routes at /users
// All routes in usersRouter will be prefixed with /users
app.use('/users', usersRouter);

// Mount the post routes at /posts
app.use('/posts', postsRouter);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Endpoint not found'
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('❌ Server error:', err);
    res.status(500).json({
        success: false,
        error: 'Internal server error'
    });
});

// =====================================================
// START THE SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Organized Express Server running`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Routes mounted:`);
    console.log(`   /users  - User routes`);
    console.log(`   /posts  - Post routes`);
    console.log(`===================================`);
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});
```

Run the organized server:

```bash
node server-router.js
```

Test it:

```bash
# User routes
curl http://localhost:3000/users
curl http://localhost:3000/users/1

# Post routes
curl http://localhost:3000/posts
curl "http://localhost:3000/posts?userId=1"

# Create a user (POST)
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Diana","email":"diana@example.com"}'

# Create a post
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"title":"New Post","content":"This is a new post"}'

# Update a user
curl -X PUT http://localhost:3000/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Updated"}'

# Delete a post
curl -X DELETE http://localhost:3000/posts/1
```

---

## Router Features and Best Practices

### Router-Level Middleware

You can add middleware that runs only for routes in a specific router:

```javascript
// routes/admin.js
const router = express.Router();

// This middleware runs for all routes in this router
router.use((req, res, next) => {
    // Check if user is admin
    if (!req.headers.authorization) {
        return res.status(401).json({ error: 'Unauthorized' });
    }
    next();
});

router.get('/dashboard', (req, res) => {
    res.json({ message: 'Admin dashboard' });
});
```

### Nested Routers

Routers can be nested for deeper organization:

```javascript
// routes/api/v1/users.js
const router = express.Router();
router.get('/', (req, res) => { /* ... */ });

// In main app
app.use('/api/v1/users', usersRouter);
// Results in: GET /api/v1/users
```

### Route Groups

You can group routes that share a common prefix:

```javascript
// All admin routes under /admin
const adminRouter = express.Router();
adminRouter.get('/users', adminUsersHandler);
adminRouter.get('/settings', adminSettingsHandler);
app.use('/admin', adminRouter);
```

### Parameter Validation

Always validate route parameters:

```javascript
app.get('/users/:id', (req, res) => {
    const id = parseInt(req.params.id);
    
    // Validate that id is a number
    if (isNaN(id)) {
        return res.status(400).json({
            error: 'Invalid user ID. Must be a number.'
        });
    }
    
    // Validate that id is positive
    if (id <= 0) {
        return res.status(400).json({
            error: 'User ID must be a positive number'
        });
    }
    
    // ... proceed with logic
});
```

---

## HTTP Methods Quick Reference

| Method | Use Case | Idempotent? | Safe? |
|--------|----------|-------------|-------|
| GET | Retrieve data | Yes | Yes |
| POST | Create new data | No | No |
| PUT | Replace entire resource | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Delete data | Yes | No |

**Idempotent:** Making the same request multiple times has the same effect as making it once.
**Safe:** The request doesn't modify data (GET, HEAD, OPTIONS are safe).

---

## What We've Learned

In this part, we covered:

1. **URL Anatomy** — Understanding paths, parameters, and query strings
2. **Route Parameters** — Dynamic segments in URLs using `:param`
3. **Query Strings** — Optional key-value pairs in URLs
4. **All HTTP Methods** — GET, POST, PUT, PATCH, DELETE
5. **express.Router()** — Organizing routes into separate modules
6. **Parameter Validation** — Ensuring data is valid before processing
7. **Router Best Practices** — Structure, middleware, and organization

---

## Practice Exercises

### Exercise 1: Add Comments Router
Create a `routes/comments.js` router with CRUD operations for comments. Each comment should have `id`, `postId`, `author`, and `text`. Mount it at `/comments`.

### Exercise 2: Add Query Parameter for Sorting
Modify the GET `/posts` route to accept a `sort` parameter that can be `oldest` or `newest`. Default to `newest`.

### Exercise 3: Add Route for User's Posts
Add a route `/users/:id/posts` that returns all posts for a specific user. Use the existing users and posts data.

### Exercise 4: Add Search Endpoint
Create a search endpoint `/search` that searches across both users and posts. Accept a `q` query parameter and return matching users and posts.

---

## Summary

Routing is the backbone of any Express application. You now know:

- **Route parameters** capture dynamic values from URLs
- **Query strings** provide optional filtering and pagination
- **HTTP methods** define the action to perform
- **express.Router()** helps organize code into maintainable modules
- **Parameter validation** ensures data integrity

This organization will serve you well as your applications grow. In Part 5, we'll explore **middleware** — one of Express's most powerful features that lets you add functionality to your request-response pipeline.

---

## Quick Reference: Routing

| Feature | Code | Example URL |
|---------|------|-------------|
| Route parameter | `:id` | `/users/123` → `req.params.id = '123'` |
| Optional param | `:id?` | `/users/123` or `/users` |
| Regex constraint | `:id(\\d+)` | `/users/123` only |
| Query string | `req.query` | `?page=2` → `req.query.page = '2'` |
| Router | `express.Router()` | Modular route groups |
| Mount router | `app.use('/path', router)` | All routes prefixed |
| All methods | `app.all('/path', handler)` | Handles any HTTP method |
| Route chaining | `app.route('/users').get().post()` | Chain handlers |
