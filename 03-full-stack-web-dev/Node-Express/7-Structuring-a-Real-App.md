# Part 7: Structuring a Real App

Welcome to Part 7! In Part 6, we learned how to handle user input through forms, JSON, and file uploads. Now we're going to take everything we've built and organize it professionally.

Up until now, we've been putting all our code in single files. While this works for learning, real applications need structure. In this part, you'll learn how to organize your Express application for maintainability, scalability, and team collaboration.

By the end of this part, you'll understand:
- Professional project structure
- Environment variables and configuration
- Separation of concerns (routes, controllers, models, services)
- Using environment variables for different deployment environments
- Setting up a development workflow with Nodemon

---

## Why Structure Matters

Think of a messy room vs. an organized room:

**Messy (no structure):**
- Everything is in one place
- Hard to find what you need
- Adding new things is confusing
- Hard for others to help

**Organized (with structure):**
- Everything has its place
- Easy to find what you need
- Adding new things is straightforward
- Others can easily understand and contribute

The same applies to code. A well-organized codebase:
- Makes it easier to find and fix bugs
- Enables multiple developers to work simultaneously
- Makes adding new features predictable
- Reduces mental overhead

---

## The Professional Project Structure

Here's the structure we'll build:

```
node-express-tutorial/
├── .env                    # Environment variables (not in git)
├── .gitignore              # What to exclude from git
├── package.json            # Project dependencies
├── package-lock.json       # Locked dependencies
├── server.js              # Main entry point
├── config/                # Configuration files
│   └── config.js
├── src/                   # Source code
│   ├── app.js            # Express app configuration
│   ├── routes/           # Route definitions
│   │   ├── index.js
│   │   ├── user.routes.js
│   │   └── task.routes.js
│   ├── controllers/      # Request handlers (business logic)
│   │   ├── user.controller.js
│   │   └── task.controller.js
│   ├── models/           # Data models
│   │   ├── user.model.js
│   │   └── task.model.js
│   ├── middleware/       # Custom middleware
│   │   ├── auth.js
│   │   ├── validation.js
│   │   └── error.js
│   ├── services/         # Business logic (optional)
│   │   └── storage.js
│   └── utils/            # Utility functions
│       ├── logger.js
│       └── validators.js
├── public/               # Static files (optional)
│   ├── css/
│   └── js/
└── tests/                # Tests (optional)
    └── ...
```

### Why This Structure?

| Directory | Purpose |
|-----------|---------|
| `config/` | Configuration that changes between environments |
| `src/routes/` | URL routing definitions (what URL goes to what controller) |
| `src/controllers/` | Request handling (extracts data from request, calls services) |
| `src/models/` | Data structure definitions (what data looks like) |
| `src/middleware/` | Reusable middleware functions |
| `src/services/` | Business logic (complex operations that don't fit in controllers) |
| `src/utils/` | Helper functions used everywhere |
| `public/` | Static assets served directly |
| `tests/` | Automated tests |

---

## Building the Structured Application

Let's build our application step by step with this structure.

### Step 1: Create the Directory Structure

```bash
# Create the directory structure
mkdir -p src/routes src/controllers src/models src/middleware src/services src/utils config

# Create initial files
touch server.js
touch src/app.js
touch .env
touch .gitignore
```

### Step 2: Create Configuration Files

#### `.gitignore`

```bash
# .gitignore
# =====================================================
# FILE: /node-express-tutorial/.gitignore
# DESCRIPTION: Files and directories to exclude from version control
# =====================================================

# Node modules
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.*.local

# Uploaded files
uploads/
*.db

# Operating system files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Logs
logs/
*.log
```

#### `.env`

```bash
# .env
# =====================================================
# FILE: /node-express-tutorial/.env
# DESCRIPTION: Environment variables (DO NOT commit this file!)
# =====================================================

# Server
PORT=3000
NODE_ENV=development

# API
API_KEY=secret-key-123

# Database (we'll use these in Part 8)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=admin
DB_PASSWORD=password123

# Security
JWT_SECRET=your-super-secret-jwt-key-change-this
```

#### `config/config.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/config/config.js
// DESCRIPTION: Configuration management
// =====================================================

// Load environment variables from .env file
require('dotenv').config();

// We'll use Joi to validate environment variables
const Joi = require('joi');

// Define a schema for environment variables
const envSchema = Joi.object({
    PORT: Joi.number().default(3000),
    NODE_ENV: Joi.string()
        .valid('development', 'production', 'test')
        .default('development'),
    API_KEY: Joi.string().required(),
    JWT_SECRET: Joi.string().required(),
}).unknown().required();

// Validate environment variables
const { error, value: env } = envSchema.validate(process.env);

if (error) {
    console.error('❌ Invalid environment configuration:');
    console.error(error.message);
    process.exit(1);
}

// Export configuration
module.exports = {
    port: env.PORT,
    env: env.NODE_ENV,
    apiKey: env.API_KEY,
    jwtSecret: env.JWT_SECRET,
    
    // Helper to check if we're in production
    isProduction: env.NODE_ENV === 'production',
    isDevelopment: env.NODE_ENV === 'development',
    isTest: env.NODE_ENV === 'test',
};
```

### Step 3: Install Dependencies

```bash
npm install express dotenv joi
npm install nodemon --save-dev
```

### Step 4: Create Utility Modules

#### `src/utils/logger.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/utils/logger.js
// DESCRIPTION: Logging utility
// =====================================================

const config = require('../../config/config');

// Different log levels
const LEVELS = {
    ERROR: 'ERROR',
    WARN: 'WARN',
    INFO: 'INFO',
    DEBUG: 'DEBUG',
};

// Colors for console output
const COLORS = {
    ERROR: '\x1b[31m', // Red
    WARN: '\x1b[33m',  // Yellow
    INFO: '\x1b[36m',  // Cyan
    DEBUG: '\x1b[35m', // Magenta
    RESET: '\x1b[0m',  // Reset
};

class Logger {
    constructor() {
        this.level = config.isDevelopment ? LEVELS.DEBUG : LEVELS.INFO;
    }

    _log(level, message, ...args) {
        if (this._shouldLog(level)) {
            const timestamp = new Date().toISOString();
            const color = COLORS[level] || COLORS.RESET;
            const prefix = `${color}[${timestamp}] ${level}:${COLORS.RESET}`;
            
            if (typeof message === 'object') {
                console.log(prefix, JSON.stringify(message, null, 2));
            } else {
                console.log(prefix, message, ...args);
            }
        }
    }

    _shouldLog(level) {
        const levels = Object.values(LEVELS);
        return levels.indexOf(level) <= levels.indexOf(this.level);
    }

    error(message, ...args) {
        this._log(LEVELS.ERROR, message, ...args);
    }

    warn(message, ...args) {
        this._log(LEVELS.WARN, message, ...args);
    }

    info(message, ...args) {
        this._log(LEVELS.INFO, message, ...args);
    }

    debug(message, ...args) {
        this._log(LEVELS.DEBUG, message, ...args);
    }

    // Express middleware for request logging
    requestLogger() {
        return (req, res, next) => {
            this.debug(`${req.method} ${req.url}`, {
                ip: req.ip,
                userAgent: req.get('user-agent'),
            });
            next();
        };
    }
}

// Export a singleton instance
module.exports = new Logger();
```

#### `src/utils/validators.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/utils/validators.js
// DESCRIPTION: Common validation functions
// =====================================================

const Joi = require('joi');

// Schema definitions
const userSchema = Joi.object({
    name: Joi.string().min(2).max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
});

const taskSchema = Joi.object({
    title: Joi.string().min(1).max(100).required(),
    description: Joi.string().max(500).allow(''),
    completed: Joi.boolean().default(false),
    priority: Joi.string().valid('low', 'medium', 'high').default('medium'),
});

// Validation middleware factory
const validate = (schema) => {
    return (req, res, next) => {
        const { error, value } = schema.validate(req.body, {
            abortEarly: false,
            stripUnknown: true,
        });

        if (error) {
            const errors = error.details.map((detail) => ({
                field: detail.path[0],
                message: detail.message,
            }));

            return res.status(400).json({
                success: false,
                errors,
            });
        }

        // Replace body with validated data
        req.body = value;
        next();
    };
};

module.exports = {
    userSchema,
    taskSchema,
    validate,
};
```

### Step 5: Create Models

#### `src/models/user.model.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/models/user.model.js
// DESCRIPTION: User data model
// =====================================================

// In a real app, this would be a database model
// For now, we'll use an in-memory array

let users = [
    {
        id: 1,
        name: 'Alice',
        email: 'alice@example.com',
        password: 'hashed_password_1',
        createdAt: new Date().toISOString(),
    },
    {
        id: 2,
        name: 'Bob',
        email: 'bob@example.com',
        password: 'hashed_password_2',
        createdAt: new Date().toISOString(),
    },
];

// Current ID counter
let nextId = users.length + 1;

class UserModel {
    // Get all users
    static getAll() {
        // Don't return passwords
        return users.map(({ password, ...user }) => user);
    }

    // Get user by ID
    static getById(id) {
        const user = users.find((u) => u.id === id);
        if (!user) return null;
        // Don't return password
        const { password, ...safeUser } = user;
        return safeUser;
    }

    // Get user by email (includes password for authentication)
    static getByEmail(email) {
        return users.find((u) => u.email === email);
    }

    // Create a new user
    static create(userData) {
        const newUser = {
            id: nextId++,
            ...userData,
            createdAt: new Date().toISOString(),
        };
        users.push(newUser);
        
        // Return without password
        const { password, ...safeUser } = newUser;
        return safeUser;
    }

    // Update a user
    static update(id, userData) {
        const index = users.findIndex((u) => u.id === id);
        if (index === -1) return null;

        // Don't allow updating id or createdAt
        const { id: _, createdAt, ...updateData } = userData;
        users[index] = {
            ...users[index],
            ...updateData,
        };

        // Return without password
        const { password, ...safeUser } = users[index];
        return safeUser;
    }

    // Delete a user
    static delete(id) {
        const index = users.findIndex((u) => u.id === id);
        if (index === -1) return false;
        users.splice(index, 1);
        return true;
    }

    // Reset data (for testing)
    static reset() {
        users = [
            {
                id: 1,
                name: 'Alice',
                email: 'alice@example.com',
                password: 'hashed_password_1',
                createdAt: new Date().toISOString(),
            },
            {
                id: 2,
                name: 'Bob',
                email: 'bob@example.com',
                password: 'hashed_password_2',
                createdAt: new Date().toISOString(),
            },
        ];
        nextId = users.length + 1;
    }
}

module.exports = UserModel;
```

#### `src/models/task.model.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/models/task.model.js
// DESCRIPTION: Task data model
// =====================================================

let tasks = [
    {
        id: 1,
        userId: 1,
        title: 'Learn Express',
        description: 'Complete the Express tutorial series',
        completed: false,
        priority: 'high',
        createdAt: new Date().toISOString(),
    },
    {
        id: 2,
        userId: 1,
        title: 'Build a project',
        description: 'Build a task management app',
        completed: false,
        priority: 'medium',
        createdAt: new Date().toISOString(),
    },
    {
        id: 3,
        userId: 2,
        title: 'Review code',
        description: 'Review pull requests from the team',
        completed: true,
        priority: 'low',
        createdAt: new Date().toISOString(),
    },
];

let nextId = tasks.length + 1;

class TaskModel {
    // Get all tasks with optional filters
    static getAll(filters = {}) {
        let result = [...tasks];

        // Filter by userId
        if (filters.userId) {
            result = result.filter((t) => t.userId === parseInt(filters.userId));
        }

        // Filter by completed status
        if (filters.completed !== undefined) {
            const completed = filters.completed === 'true';
            result = result.filter((t) => t.completed === completed);
        }

        // Filter by priority
        if (filters.priority) {
            result = result.filter((t) => t.priority === filters.priority);
        }

        return result;
    }

    // Get a single task
    static getById(id) {
        return tasks.find((t) => t.id === id);
    }

    // Get tasks for a user
    static getByUserId(userId) {
        return tasks.filter((t) => t.userId === userId);
    }

    // Create a new task
    static create(taskData) {
        const newTask = {
            id: nextId++,
            ...taskData,
            completed: taskData.completed || false,
            priority: taskData.priority || 'medium',
            createdAt: new Date().toISOString(),
        };
        tasks.push(newTask);
        return newTask;
    }

    // Update a task
    static update(id, taskData) {
        const index = tasks.findIndex((t) => t.id === id);
        if (index === -1) return null;

        // Don't allow updating id, userId, or createdAt
        const { id: _, userId, createdAt, ...updateData } = taskData;
        tasks[index] = {
            ...tasks[index],
            ...updateData,
        };

        return tasks[index];
    }

    // Delete a task
    static delete(id) {
        const index = tasks.findIndex((t) => t.id === id);
        if (index === -1) return false;
        tasks.splice(index, 1);
        return true;
    }

    // Delete all tasks for a user
    static deleteByUserId(userId) {
        const userTasks = tasks.filter((t) => t.userId === userId);
        tasks = tasks.filter((t) => t.userId !== userId);
        return userTasks.length;
    }

    // Reset data
    static reset() {
        tasks = [
            {
                id: 1,
                userId: 1,
                title: 'Learn Express',
                description: 'Complete the Express tutorial series',
                completed: false,
                priority: 'high',
                createdAt: new Date().toISOString(),
            },
            {
                id: 2,
                userId: 1,
                title: 'Build a project',
                description: 'Build a task management app',
                completed: false,
                priority: 'medium',
                createdAt: new Date().toISOString(),
            },
            {
                id: 3,
                userId: 2,
                title: 'Review code',
                description: 'Review pull requests from the team',
                completed: true,
                priority: 'low',
                createdAt: new Date().toISOString(),
            },
        ];
        nextId = tasks.length + 1;
    }
}

module.exports = TaskModel;
```

### Step 6: Create Middleware

#### `src/middleware/auth.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/middleware/auth.js
// DESCRIPTION: Authentication middleware
// =====================================================

const config = require('../../config/config');
const logger = require('../utils/logger');

// Authentication middleware
const authenticate = (req, res, next) => {
    // Check for API key in headers
    const apiKey = req.headers['x-api-key'];

    if (!apiKey) {
        logger.warn('Authentication failed: No API key provided');
        return res.status(401).json({
            success: false,
            error: 'Authentication required: API key missing',
        });
    }

    if (apiKey !== config.apiKey) {
        logger.warn('Authentication failed: Invalid API key');
        return res.status(401).json({
            success: false,
            error: 'Authentication failed: Invalid API key',
        });
    }

    // Add user info to request (in a real app, this would come from a database)
    req.user = {
        id: 1,
        name: 'Authenticated User',
        role: 'user',
    };

    logger.debug('Authentication successful for user:', req.user.name);
    next();
};

// Authorization middleware (checks user roles)
const authorize = (roles = []) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                error: 'Authentication required',
            });
        }

        if (roles.length > 0 && !roles.includes(req.user.role)) {
            logger.warn(`Authorization failed: User ${req.user.name} doesn't have role ${roles.join(' or ')}`);
            return res.status(403).json({
                success: false,
                error: 'Insufficient permissions',
            });
        }

        next();
    };
};

module.exports = {
    authenticate,
    authorize,
};
```

#### `src/middleware/error.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/middleware/error.js
// DESCRIPTION: Error handling middleware
// =====================================================

const logger = require('../utils/logger');
const config = require('../../config/config');

// Global error handler
const errorHandler = (err, req, res, next) => {
    // Log the error
    logger.error('Error caught by error handler:', {
        message: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method,
        ip: req.ip,
    });

    // Determine status code
    const status = err.status || err.statusCode || 500;

    // Prepare error response
    const errorResponse = {
        success: false,
        error: err.message || 'Internal server error',
    };

    // Add stack trace in development
    if (config.isDevelopment) {
        errorResponse.stack = err.stack;
    }

    res.status(status).json(errorResponse);
};

// 404 handler
const notFoundHandler = (req, res) => {
    logger.debug(`404 Not found: ${req.method} ${req.url}`);
    res.status(404).json({
        success: false,
        error: `Route ${req.method} ${req.url} not found`,
    });
};

// Custom error class
class AppError extends Error {
    constructor(message, status = 500) {
        super(message);
        this.status = status;
        this.name = this.constructor.name;
        Error.captureStackTrace(this, this.constructor);
    }
}

module.exports = {
    errorHandler,
    notFoundHandler,
    AppError,
};
```

#### `src/middleware/validation.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/middleware/validation.js
// DESCRIPTION: Validation middleware
// =====================================================

const logger = require('../utils/logger');

// Generic validation middleware
const validateRequest = (schema) => {
    return (req, res, next) => {
        const { error, value } = schema.validate(req.body, {
            abortEarly: false,
            stripUnknown: true,
        });

        if (error) {
            const errors = error.details.map((detail) => ({
                field: detail.path[0],
                message: detail.message,
            }));

            logger.debug('Validation failed:', errors);
            return res.status(400).json({
                success: false,
                errors,
            });
        }

        // Replace body with validated data
        req.body = value;
        next();
    };
};

// Validate ID parameter
const validateId = (req, res, next) => {
    const id = parseInt(req.params.id);
    if (isNaN(id) || id <= 0) {
        return res.status(400).json({
            success: false,
            error: 'Invalid ID. Must be a positive number.',
        });
    }
    req.params.id = id;
    next();
};

module.exports = {
    validateRequest,
    validateId,
};
```

### Step 7: Create Controllers

#### `src/controllers/user.controller.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/controllers/user.controller.js
// DESCRIPTION: User controller - handles user-related requests
// =====================================================

const UserModel = require('../models/user.model');
const logger = require('../utils/logger');

class UserController {
    // Get all users
    getAllUsers(req, res) {
        try {
            const users = UserModel.getAll();
            logger.debug(`Returning ${users.length} users`);
            res.json({
                success: true,
                count: users.length,
                data: users,
            });
        } catch (error) {
            logger.error('Error getting users:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch users',
            });
        }
    }

    // Get a single user
    getUserById(req, res) {
        try {
            const { id } = req.params;
            const user = UserModel.getById(id);

            if (!user) {
                return res.status(404).json({
                    success: false,
                    error: `User with ID ${id} not found`,
                });
            }

            res.json({
                success: true,
                data: user,
            });
        } catch (error) {
            logger.error('Error getting user:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch user',
            });
        }
    }

    // Create a new user
    createUser(req, res) {
        try {
            const userData = req.body;

            // Check if email already exists
            const existingUser = UserModel.getByEmail(userData.email);
            if (existingUser) {
                return res.status(409).json({
                    success: false,
                    error: 'Email already registered',
                });
            }

            // In a real app, hash the password here
            // userData.password = await bcrypt.hash(userData.password, 10);

            const newUser = UserModel.create(userData);
            logger.info(`User created: ${newUser.email}`);

            res.status(201).json({
                success: true,
                message: 'User created successfully',
                data: newUser,
            });
        } catch (error) {
            logger.error('Error creating user:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to create user',
            });
        }
    }

    // Update a user
    updateUser(req, res) {
        try {
            const { id } = req.params;
            const userData = req.body;

            // Check if user exists
            const existingUser = UserModel.getById(id);
            if (!existingUser) {
                return res.status(404).json({
                    success: false,
                    error: `User with ID ${id} not found`,
                });
            }

            const updatedUser = UserModel.update(id, userData);
            logger.info(`User updated: ${updatedUser.email}`);

            res.json({
                success: true,
                message: 'User updated successfully',
                data: updatedUser,
            });
        } catch (error) {
            logger.error('Error updating user:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to update user',
            });
        }
    }

    // Delete a user
    deleteUser(req, res) {
        try {
            const { id } = req.params;

            // Check if user exists
            const existingUser = UserModel.getById(id);
            if (!existingUser) {
                return res.status(404).json({
                    success: false,
                    error: `User with ID ${id} not found`,
                });
            }

            const deleted = UserModel.delete(id);
            if (!deleted) {
                return res.status(500).json({
                    success: false,
                    error: 'Failed to delete user',
                });
            }

            logger.info(`User deleted: ${existingUser.email}`);
            res.json({
                success: true,
                message: `User ${id} deleted successfully`,
            });
        } catch (error) {
            logger.error('Error deleting user:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to delete user',
            });
        }
    }
}

module.exports = new UserController();
```

#### `src/controllers/task.controller.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/controllers/task.controller.js
// DESCRIPTION: Task controller - handles task-related requests
// =====================================================

const TaskModel = require('../models/task.model');
const UserModel = require('../models/user.model');
const logger = require('../utils/logger');

class TaskController {
    // Get all tasks with filters
    getTasks(req, res) {
        try {
            const filters = req.query;
            const tasks = TaskModel.getAll(filters);

            // If filtering by userId, check if user exists
            if (filters.userId) {
                const user = UserModel.getById(parseInt(filters.userId));
                if (!user) {
                    return res.status(404).json({
                        success: false,
                        error: `User with ID ${filters.userId} not found`,
                    });
                }
            }

            res.json({
                success: true,
                count: tasks.length,
                data: tasks,
            });
        } catch (error) {
            logger.error('Error getting tasks:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch tasks',
            });
        }
    }

    // Get a single task
    getTaskById(req, res) {
        try {
            const { id } = req.params;
            const task = TaskModel.getById(id);

            if (!task) {
                return res.status(404).json({
                    success: false,
                    error: `Task with ID ${id} not found`,
                });
            }

            res.json({
                success: true,
                data: task,
            });
        } catch (error) {
            logger.error('Error getting task:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch task',
            });
        }
    }

    // Create a new task
    createTask(req, res) {
        try {
            const taskData = req.body;

            // Check if user exists
            const user = UserModel.getById(taskData.userId);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    error: `User with ID ${taskData.userId} not found`,
                });
            }

            const newTask = TaskModel.create(taskData);
            logger.info(`Task created for user ${taskData.userId}: ${newTask.title}`);

            res.status(201).json({
                success: true,
                message: 'Task created successfully',
                data: newTask,
            });
        } catch (error) {
            logger.error('Error creating task:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to create task',
            });
        }
    }

    // Update a task
    updateTask(req, res) {
        try {
            const { id } = req.params;
            const taskData = req.body;

            // Check if task exists
            const existingTask = TaskModel.getById(id);
            if (!existingTask) {
                return res.status(404).json({
                    success: false,
                    error: `Task with ID ${id} not found`,
                });
            }

            const updatedTask = TaskModel.update(id, taskData);
            logger.info(`Task updated: ${updatedTask.title}`);

            res.json({
                success: true,
                message: 'Task updated successfully',
                data: updatedTask,
            });
        } catch (error) {
            logger.error('Error updating task:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to update task',
            });
        }
    }

    // Delete a task
    deleteTask(req, res) {
        try {
            const { id } = req.params;

            // Check if task exists
            const existingTask = TaskModel.getById(id);
            if (!existingTask) {
                return res.status(404).json({
                    success: false,
                    error: `Task with ID ${id} not found`,
                });
            }

            const deleted = TaskModel.delete(id);
            if (!deleted) {
                return res.status(500).json({
                    success: false,
                    error: 'Failed to delete task',
                });
            }

            logger.info(`Task deleted: ${existingTask.title}`);
            res.json({
                success: true,
                message: `Task ${id} deleted successfully`,
            });
        } catch (error) {
            logger.error('Error deleting task:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to delete task',
            });
        }
    }

    // Get tasks for a specific user
    getUserTasks(req, res) {
        try {
            const { userId } = req.params;

            // Check if user exists
            const user = UserModel.getById(parseInt(userId));
            if (!user) {
                return res.status(404).json({
                    success: false,
                    error: `User with ID ${userId} not found`,
                });
            }

            const tasks = TaskModel.getByUserId(parseInt(userId));
            res.json({
                success: true,
                count: tasks.length,
                data: tasks,
            });
        } catch (error) {
            logger.error('Error getting user tasks:', error);
            res.status(500).json({
                success: false,
                error: 'Failed to fetch user tasks',
            });
        }
    }
}

module.exports = new TaskController();
```

### Step 8: Create Routes

#### `src/routes/user.routes.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/routes/user.routes.js
// DESCRIPTION: User routes
// =====================================================

const express = require('express');
const router = express.Router();

const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');
const { validateRequest, validateId } = require('../middleware/validation');
const { userSchema } = require('../utils/validators');

// All user routes require authentication
router.use(authenticate);

// GET /users - Get all users
router.get('/', userController.getAllUsers);

// GET /users/:id - Get a specific user
router.get('/:id', validateId, userController.getUserById);

// POST /users - Create a new user
router.post('/', validateRequest(userSchema), userController.createUser);

// PUT /users/:id - Update a user
router.put(
    '/:id',
    validateId,
    validateRequest(userSchema),
    userController.updateUser
);

// DELETE /users/:id - Delete a user
router.delete('/:id', validateId, userController.deleteUser);

module.exports = router;
```

#### `src/routes/task.routes.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/routes/task.routes.js
// DESCRIPTION: Task routes
// =====================================================

const express = require('express');
const router = express.Router();

const taskController = require('../controllers/task.controller');
const { authenticate } = require('../middleware/auth');
const { validateRequest, validateId } = require('../middleware/validation');
const { taskSchema } = require('../utils/validators');

// All task routes require authentication
router.use(authenticate);

// GET /tasks - Get all tasks with filters
router.get('/', taskController.getTasks);

// GET /tasks/:id - Get a specific task
router.get('/:id', validateId, taskController.getTaskById);

// POST /tasks - Create a new task
router.post('/', validateRequest(taskSchema), taskController.createTask);

// PUT /tasks/:id - Update a task
router.put(
    '/:id',
    validateId,
    validateRequest(taskSchema),
    taskController.updateTask
);

// DELETE /tasks/:id - Delete a task
router.delete('/:id', validateId, taskController.deleteTask);

// GET /users/:userId/tasks - Get tasks for a specific user
router.get(
    '/users/:userId/tasks',
    validateId,
    taskController.getUserTasks
);

module.exports = router;
```

### Step 9: Create the Main App

#### `src/app.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/app.js
// DESCRIPTION: Express app configuration
// =====================================================

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');

const config = require('../config/config');
const logger = require('./utils/logger');

// Import middleware
const { errorHandler, notFoundHandler } = require('./middleware/error');

// Import routes
const userRoutes = require('./routes/user.routes');
const taskRoutes = require('./routes/task.routes');

// Create Express app
const app = express();

// =====================================================
// MIDDLEWARE
// =====================================================

// Security headers
app.use(helmet());

// CORS
app.use(cors());

// Parse JSON
app.use(express.json({ limit: '10mb' }));

// Parse URL-encoded data
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
app.use(logger.requestLogger());

// =====================================================
// STATIC FILES
// =====================================================

// Serve static files from public directory
app.use(express.static('public'));

// =====================================================
// ROUTES
// =====================================================

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        environment: config.env,
    });
});

// API welcome
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>API - Structured App</title>
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
            <h1>🚀 Structured Express API</h1>
            <p>This is a professionally structured Express application.</p>
            
            <h2>Available Endpoints</h2>
            <p><em>All endpoints require API key: <code>${config.apiKey}</code></em></p>
            
            <h3>Users</h3>
            <div class="endpoint"><span class="method get">GET</span> /users</div>
            <div class="endpoint"><span class="method get">GET</span> /users/:id</div>
            <div class="endpoint"><span class="method post">POST</span> /users</div>
            <div class="endpoint"><span class="method put">PUT</span> /users/:id</div>
            <div class="endpoint"><span class="method delete">DELETE</span> /users/:id</div>
            
            <h3>Tasks</h3>
            <div class="endpoint"><span class="method get">GET</span> /tasks</div>
            <div class="endpoint"><span class="method get">GET</span> /tasks/:id</div>
            <div class="endpoint"><span class="method post">POST</span> /tasks</div>
            <div class="endpoint"><span class="method put">PUT</span> /tasks/:id</div>
            <div class="endpoint"><span class="method delete">DELETE</span> /tasks/:id</div>
            <div class="endpoint"><span class="method get">GET</span> /users/:userId/tasks</div>
            
            <h3>System</h3>
            <div class="endpoint"><span class="method get">GET</span> /health</div>
        </body>
        </html>
    `);
});

// Mount route modules
app.use('/users', userRoutes);
app.use('/tasks', taskRoutes);

// =====================================================
// ERROR HANDLING
// =====================================================

// 404 handler - must be after all routes
app.use(notFoundHandler);

// Global error handler - must be last
app.use(errorHandler);

module.exports = app;
```

### Step 10: Create the Entry Point

#### `server.js`

```javascript
// =====================================================
// FILE: /node-express-tutorial/server.js
// DESCRIPTION: Server entry point
// =====================================================

// Load environment variables first
require('dotenv').config();

const config = require('./config/config');
const app = require('./src/app');
const logger = require('./src/utils/logger');

// Start the server
const server = app.listen(config.port, () => {
    console.log(`===================================`);
    console.log(`✅ Server running!`);
    console.log(`📡 http://localhost:${config.port}`);
    console.log(`🔧 Environment: ${config.env}`);
    console.log(`🔑 API Key: ${config.apiKey}`);
    console.log(`===================================`);
    console.log(`📋 Available routes:`);
    console.log(`   GET  /                - API documentation`);
    console.log(`   GET  /health          - Health check`);
    console.log(`   GET  /users           - User routes`);
    console.log(`   GET  /tasks           - Task routes`);
    console.log(`===================================`);
    console.log(`🔒 Press Ctrl+C to stop`);
    console.log(`===================================`);
});

// Handle server errors
server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
        logger.error(`❌ Port ${config.port} is already in use.`);
        process.exit(1);
    } else {
        logger.error('❌ Server error:', error);
        process.exit(1);
    }
});

// Graceful shutdown
process.on('SIGINT', () => {
    logger.info('\n🛑 Shutting down server...');
    server.close(() => {
        logger.info('✅ Server closed gracefully');
        process.exit(0);
    });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
    logger.error('❌ Uncaught exception:', error);
    process.exit(1);
});

// Handle unhandled rejections
process.on('unhandledRejection', (reason, promise) => {
    logger.error('❌ Unhandled rejection:', reason);
});

module.exports = server;
```

### Step 11: Update package.json

Update your `package.json` with the correct scripts:

```json
{
  "name": "node-express-tutorial",
  "version": "1.0.0",
  "description": "A structured Express application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["express", "nodejs", "tutorial"],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "helmet": "^7.0.0",
    "joi": "^17.9.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
```

### Step 12: Install All Dependencies

```bash
npm install
```

### Step 13: Run the Structured Application

```bash
# Development mode (with nodemon)
npm run dev

# Production mode
npm start
```

### Step 14: Test the Application

```bash
# Health check
curl http://localhost:3000/health

# Get users (requires API key)
curl -H "x-api-key: secret-key-123" http://localhost:3000/users

# Get a user
curl -H "x-api-key: secret-key-123" http://localhost:3000/users/1

# Create a user
curl -X POST http://localhost:3000/users \
  -H "x-api-key: secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"name":"Charlie","email":"charlie@example.com","password":"password123"}'

# Get tasks
curl -H "x-api-key: secret-key-123" http://localhost:3000/tasks

# Get tasks with filters
curl -H "x-api-key: secret-key-123" "http://localhost:3000/tasks?userId=1&completed=false"

# Create a task
curl -X POST http://localhost:3000/tasks \
  -H "x-api-key: secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"userId":1,"title":"New Task","description":"This is a new task","priority":"high"}'

# Get user's tasks
curl -H "x-api-key: secret-key-123" http://localhost:3000/users/1/tasks
```

---

## Environment Variables with .env

### Why Use Environment Variables?

Environment variables allow you to:

1. **Keep secrets out of code** — API keys, passwords, and tokens
2. **Configure different environments** — Development, testing, production
3. **Change settings without changing code** — Port, database URLs
4. **Follow the Twelve-Factor App methodology** — Best practices for modern apps

### Common Environment Variables

```bash
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=admin
DB_PASSWORD=password123

# Authentication
JWT_SECRET=your-super-secret-key
JWT_EXPIRES_IN=7d

# APIs
API_KEY=secret-key
GOOGLE_API_KEY=xxx
```

### Using .env in Production

1. Never commit `.env` to version control
2. Create a `.env.example` file with example values
3. Set environment variables in your hosting platform

```bash
# .env.example
PORT=3000
NODE_ENV=development
API_KEY=your-api-key-here
JWT_SECRET=change-this-in-production
```

---

## Nodemon for Development

Nodemon automatically restarts your server when files change.

### Install Nodemon

```bash
npm install nodemon --save-dev
```

### Using Nodemon

```json
{
  "scripts": {
    "dev": "nodemon server.js",
    "start": "node server.js"
  }
}
```

### Custom Nodemon Configuration

Create `nodemon.json`:

```json
{
  "watch": ["src", "config"],
  "ext": "js,json",
  "ignore": ["node_modules", "uploads"],
  "env": {
    "NODE_ENV": "development"
  }
}
```

---

## What We've Learned

In this part, we covered:

1. **Why structure matters** — Organization improves maintainability
2. **Professional project structure** — Separate concerns into directories
3. **Environment variables** — Using `.env` for configuration
4. **Configuration management** — Validating and accessing configuration
5. **MVC pattern** — Models, Views (routes), Controllers
6. **Custom middleware** — Authentication, validation, error handling
7. **Route organization** — Using `express.Router()` for modular routes
8. **Development workflow** — Using Nodemon for hot reloading

---

## Practice Exercises

### Exercise 1: Add a Task Status
Add a `status` field to tasks with values: `pending`, `in-progress`, `completed`. Update the task schema, model, and controller to support this.

### Exercise 2: Add Comment Routes
Create `comment.routes.js`, `comment.controller.js`, and `comment.model.js` to manage comments on tasks.

### Exercise 3: Add Environment Validation
Add validation for `DB_HOST` and `DB_PORT` environment variables. Update `config.js` to validate them.

### Exercise 4: Add API Versioning
Add API versioning by moving routes to `/api/v1/` and preparing for `/api/v2/`.

---

## Summary

You now have a professionally structured Express application with:

- **Clear separation of concerns** — Routes, controllers, models
- **Environment-based configuration** — Different settings for different environments
- **Modular middleware** — Reusable authentication and validation
- **Proper error handling** — Centralized error handling
- **Development workflow** — Hot reloading with Nodemon
- **Security practices** — Environment variables, helmet, CORS

This structure will serve you well as your application grows. In Part 8, we'll add persistence with a simple data store and build CRUD operations.

---

## Quick Reference: Project Structure

| Directory/File | Purpose |
|----------------|---------|
| `server.js` | Entry point |
| `config/config.js` | Configuration |
| `src/app.js` | Express app setup |
| `src/routes/` | Route definitions |
| `src/controllers/` | Request handlers |
| `src/models/` | Data models |
| `src/middleware/` | Custom middleware |
| `src/utils/` | Utility functions |
| `.env` | Environment variables |
| `.gitignore` | Git ignore patterns |
| `package.json` | Dependencies and scripts |
