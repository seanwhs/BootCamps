# Part 10: Final Project and Deployment

Welcome to Part 10 — the final part of our Node.js + Express tutorial series! 🎉

You've come a long way. You started with the fundamentals of servers, learned Node.js and Express, mastered routing and middleware, built structured applications with persistence, and implemented robust error handling and security. Now it's time to bring everything together into a complete, production-ready application and deploy it to the internet.

By the end of this part, you'll have built and deployed a complete Task Management Application that you can show to friends, family, or potential employers.

---

## The Final Project: TaskMaster Pro

We're going to build **TaskMaster Pro** — a full-featured task management application with:

### Features

| Feature | Description |
|---------|-------------|
| **User Management** | Register, login, and manage user profiles |
| **Task Management** | Create, read, update, and delete tasks |
| **Task Organization** | Priority levels, completion status, filtering |
| **Dashboard** | Statistics and overview of tasks |
| **Responsive UI** | Works on desktop, tablet, and mobile |
| **REST API** | Complete API for frontend and third-party integration |
| **Authentication** | JWT-based authentication with secure password hashing |
| **Persistence** | File-based storage (ready for database integration) |
| **Security** | Headers, rate limiting, input validation, sanitization |
| **Deployment Ready** | Configuration for production deployment |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     TaskMaster Pro                          │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                     Frontend                         │  │
│  │  • HTML/CSS/JavaScript (served from public/)        │  │
│  │  • Dashboard with task statistics                   │  │
│  │  • Task list with filtering and sorting             │  │
│  │  • Task creation, editing, and deletion             │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    REST API                         │  │
│  │  • /api/auth    - Authentication (login/register)  │  │
│  │  • /api/users   - User management                  │  │
│  │  • /api/tasks   - Task CRUD operations             │  │
│  └──────────────────────────────────────────────────────┘  │
│                              │                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   Storage Layer                      │  │
│  │  • File-based JSON (production ready)               │  │
│  │  • Ready for database integration                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Setup

### Step 1: Create the Project Structure

```bash
# Create project directory
mkdir taskmaster-pro
cd taskmaster-pro

# Initialize npm
npm init -y

# Create directory structure
mkdir -p src/{routes,controllers,models,middleware,services,utils}
mkdir -p config public/{css,js}
mkdir -p data
```

### Step 2: Install Dependencies

```bash
npm install express dotenv helmet cors compression \
  express-rate-limit express-mongo-sanitize xss-clean \
  bcryptjs jsonwebtoken joi uuid

npm install nodemon --save-dev
```

### Step 3: Create .env File

```bash
# .env
PORT=3000
NODE_ENV=development
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=7d
API_KEY=your-api-key-here
ALLOWED_ORIGINS=http://localhost:3000
```

### Step 4: Configuration File

Create `config/config.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/config/config.js
// DESCRIPTION: Configuration management
// =====================================================

require('dotenv').config();

const Joi = require('joi');

const envSchema = Joi.object({
    PORT: Joi.number().default(3000),
    NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
    JWT_SECRET: Joi.string().required(),
    JWT_EXPIRES_IN: Joi.string().default('7d'),
    API_KEY: Joi.string().required(),
    ALLOWED_ORIGINS: Joi.string().default('http://localhost:3000'),
}).unknown().required();

const { error, value: env } = envSchema.validate(process.env);

if (error) {
    console.error('❌ Invalid environment configuration:');
    console.error(error.message);
    process.exit(1);
}

module.exports = {
    port: env.PORT,
    env: env.NODE_ENV,
    jwtSecret: env.JWT_SECRET,
    jwtExpiresIn: env.JWT_EXPIRES_IN,
    apiKey: env.API_KEY,
    allowedOrigins: env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim()),
    
    isProduction: env.NODE_ENV === 'production',
    isDevelopment: env.NODE_ENV === 'development',
    isTest: env.NODE_ENV === 'test',
};
```

---

## Core Files

### Storage Service (Reuse from Part 8)

Create `src/services/storage.service.js` (same as Part 8 but with enhanced error handling).

### Authentication Utilities

Create `src/utils/auth.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/utils/auth.js
// DESCRIPTION: Authentication utilities (JWT, password hashing)
// =====================================================

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../../config/config');
const { AppError } = require('./errors');

const SALT_ROUNDS = 12;

/**
 * Hash a password
 */
const hashPassword = async (password) => {
    try {
        return await bcrypt.hash(password, SALT_ROUNDS);
    } catch (error) {
        throw new AppError('Failed to hash password', 500);
    }
};

/**
 * Verify a password against a hash
 */
const verifyPassword = async (password, hashedPassword) => {
    try {
        return await bcrypt.compare(password, hashedPassword);
    } catch (error) {
        throw new AppError('Failed to verify password', 500);
    }
};

/**
 * Generate a JWT token
 */
const generateToken = (user) => {
    try {
        const payload = {
            id: user.id,
            email: user.email,
            name: user.name,
        };
        return jwt.sign(payload, config.jwtSecret, {
            expiresIn: config.jwtExpiresIn,
        });
    } catch (error) {
        throw new AppError('Failed to generate token', 500);
    }
};

/**
 * Verify a JWT token
 */
const verifyToken = (token) => {
    try {
        return jwt.verify(token, config.jwtSecret);
    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            throw new AppError('Invalid token', 401);
        }
        if (error.name === 'TokenExpiredError') {
            throw new AppError('Token expired', 401);
        }
        throw new AppError('Authentication failed', 401);
    }
};

/**
 * Extract token from Authorization header
 */
const extractToken = (req) => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return null;
    }
    
    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
        return null;
    }
    
    return parts[1];
};

module.exports = {
    hashPassword,
    verifyPassword,
    generateToken,
    verifyToken,
    extractToken,
};
```

### Error Handling (Reuse from Part 9)

Create `src/utils/errors.js` and `src/middleware/error.js` (reuse from Part 9).

### Validation Schemas

Create `src/utils/validators.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/utils/validators.js
// DESCRIPTION: Validation schemas
// =====================================================

const Joi = require('joi');

// User schemas
const registerSchema = Joi.object({
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
});

const loginSchema = Joi.object({
    email: Joi.string().email().required()
        .messages({
            'string.email': 'Please provide a valid email address',
            'any.required': 'Email is required',
        }),
    password: Joi.string().required()
        .messages({
            'any.required': 'Password is required',
        }),
});

const updateProfileSchema = Joi.object({
    name: Joi.string().min(2).max(50),
    email: Joi.string().email(),
    password: Joi.string().min(8),
}).min(1).messages({
    'object.min': 'At least one field must be provided',
});

// Task schemas
const createTaskSchema = Joi.object({
    title: Joi.string().min(1).max(100).required()
        .messages({
            'string.min': 'Title must be at least 1 character',
            'string.max': 'Title must be at most 100 characters',
            'any.required': 'Title is required',
        }),
    description: Joi.string().max(500).allow(''),
    priority: Joi.string().valid('low', 'medium', 'high').default('medium'),
    dueDate: Joi.date().iso().min('now').optional()
        .messages({
            'date.min': 'Due date must be in the future',
        }),
});

const updateTaskSchema = Joi.object({
    title: Joi.string().min(1).max(100),
    description: Joi.string().max(500).allow(''),
    completed: Joi.boolean(),
    priority: Joi.string().valid('low', 'medium', 'high'),
    dueDate: Joi.date().iso().min('now').optional(),
}).min(1).messages({
    'object.min': 'At least one field must be provided',
});

// ID parameter
const idParamSchema = Joi.object({
    id: Joi.number().integer().positive().required()
        .messages({
            'number.base': 'ID must be a number',
            'number.integer': 'ID must be an integer',
            'number.positive': 'ID must be a positive number',
            'any.required': 'ID is required',
        }),
});

// Task filters
const taskFiltersSchema = Joi.object({
    userId: Joi.number().integer().positive(),
    completed: Joi.boolean(),
    priority: Joi.string().valid('low', 'medium', 'high'),
    sort: Joi.string().valid('newest', 'oldest', 'priority'),
    limit: Joi.number().integer().min(1).max(100).default(50),
    page: Joi.number().integer().min(1).default(1),
});

module.exports = {
    registerSchema,
    loginSchema,
    updateProfileSchema,
    createTaskSchema,
    updateTaskSchema,
    idParamSchema,
    taskFiltersSchema,
};
```

### Authentication Middleware

Create `src/middleware/auth.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/middleware/auth.js
// DESCRIPTION: Authentication middleware
// =====================================================

const { verifyToken, extractToken } = require('../utils/auth');
const { AppError } = require('../utils/errors');
const UserModel = require('../models/user.model');
const logger = require('../utils/logger');

/**
 * Authenticate a request using JWT
 */
const authenticate = async (req, res, next) => {
    try {
        const token = extractToken(req);
        if (!token) {
            throw new AppError('Authentication required: No token provided', 401);
        }

        const decoded = verifyToken(token);
        
        // Verify user still exists
        const user = UserModel.getById(decoded.id);
        if (!user) {
            throw new AppError('User no longer exists', 401);
        }

        // Attach user to request
        req.user = user;
        next();
    } catch (error) {
        next(error);
    }
};

/**
 * API Key authentication (for external services)
 */
const apiKeyAuth = (req, res, next) => {
    const apiKey = req.headers['x-api-key'];
    
    if (!apiKey) {
        return next(new AppError('API key required', 401));
    }
    
    if (apiKey !== config.apiKey) {
        return next(new AppError('Invalid API key', 401));
    }
    
    next();
};

/**
 * Optional authentication (try to authenticate but don't require it)
 */
const optionalAuth = async (req, res, next) => {
    try {
        const token = extractToken(req);
        if (token) {
            const decoded = verifyToken(token);
            const user = UserModel.getById(decoded.id);
            if (user) {
                req.user = user;
            }
        }
    } catch (error) {
        // Silently fail, user remains unauthenticated
    }
    next();
};

module.exports = {
    authenticate,
    apiKeyAuth,
    optionalAuth,
};
```

---

## Models

### User Model

Create `src/models/user.model.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/models/user.model.js
// DESCRIPTION: User model with authentication
// =====================================================

const storage = require('../services/storage.service');
const { hashPassword, verifyPassword } = require('../utils/auth');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');

class UserModel {
    // Get all users
    static getAll() {
        const users = storage.getCollection('users');
        return users.map(({ password, ...user }) => user);
    }

    // Get user by ID
    static getById(id) {
        const user = storage.findById('users', id);
        if (!user) return null;
        const { password, ...safeUser } = user;
        return safeUser;
    }

    // Get user by email (includes password)
    static getByEmail(email) {
        const users = storage.getCollection('users');
        return users.find(u => u.email.toLowerCase() === email.toLowerCase());
    }

    // Create a new user
    static async create(userData) {
        const { name, email, password } = userData;
        
        // Check if email exists
        const existing = this.getByEmail(email);
        if (existing) {
            throw new AppError('Email already registered', 409);
        }

        // Hash password
        const hashedPassword = await hashPassword(password);
        
        const newUser = await storage.create('users', {
            name,
            email: email.toLowerCase(),
            password: hashedPassword,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        });

        const { password: _, ...safeUser } = newUser;
        return safeUser;
    }

    // Update user
    static async update(id, updates) {
        // Don't allow updating id or createdAt
        const { id: _, createdAt, ...allowedUpdates } = updates;
        
        // If password is being updated, hash it
        if (allowedUpdates.password) {
            allowedUpdates.password = await hashPassword(allowedUpdates.password);
        }
        
        // If email is being updated, check if it exists
        if (allowedUpdates.email) {
            allowedUpdates.email = allowedUpdates.email.toLowerCase();
            const existing = this.getByEmail(allowedUpdates.email);
            if (existing && existing.id !== id) {
                throw new AppError('Email already registered', 409);
            }
        }

        const updatedUser = await storage.update('users', id, {
            ...allowedUpdates,
            updatedAt: new Date().toISOString(),
        });

        if (!updatedUser) return null;
        const { password, ...safeUser } = updatedUser;
        return safeUser;
    }

    // Delete user
    static async delete(id) {
        // Also delete user's tasks
        const TaskModel = require('./task.model');
        await TaskModel.deleteByUserId(id);
        
        return await storage.delete('users', id);
    }

    // Authenticate user
    static async authenticate(email, password) {
        const user = this.getByEmail(email);
        if (!user) {
            return null;
        }

        const isValid = await verifyPassword(password, user.password);
        if (!isValid) {
            return null;
        }

        const { password: _, ...safeUser } = user;
        return safeUser;
    }

    // Get user with statistics
    static async getWithStats(id) {
        const user = this.getById(id);
        if (!user) return null;

        const TaskModel = require('./task.model');
        const tasks = TaskModel.getByUserId(id);
        
        return {
            ...user,
            stats: {
                totalTasks: tasks.length,
                completedTasks: tasks.filter(t => t.completed).length,
                pendingTasks: tasks.filter(t => !t.completed).length,
                highPriorityTasks: tasks.filter(t => t.priority === 'high').length,
            }
        };
    }

    // Reset data (for testing)
    static async reset() {
        await storage.reset();
    }
}

module.exports = UserModel;
```

### Task Model

Create `src/models/task.model.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/models/task.model.js
// DESCRIPTION: Task model with filtering and statistics
// =====================================================

const storage = require('../services/storage.service');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');

class TaskModel {
    // Get all tasks with optional filters
    static getAll(filters = {}) {
        let tasks = storage.getCollection('tasks');

        // Filter by userId
        if (filters.userId) {
            tasks = tasks.filter(t => t.userId === parseInt(filters.userId));
        }

        // Filter by completed status
        if (filters.completed !== undefined) {
            const completed = filters.completed === 'true' || filters.completed === true;
            tasks = tasks.filter(t => t.completed === completed);
        }

        // Filter by priority
        if (filters.priority) {
            tasks = tasks.filter(t => t.priority === filters.priority);
        }

        // Filter by due date (overdue)
        if (filters.overdue === 'true') {
            const now = new Date();
            tasks = tasks.filter(t => 
                !t.completed && 
                t.dueDate && 
                new Date(t.dueDate) < now
            );
        }

        // Search
        if (filters.search) {
            const search = filters.search.toLowerCase();
            tasks = tasks.filter(t => 
                t.title.toLowerCase().includes(search) ||
                (t.description && t.description.toLowerCase().includes(search))
            );
        }

        // Sort
        if (filters.sort === 'newest') {
            tasks.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
        } else if (filters.sort === 'oldest') {
            tasks.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
        } else if (filters.sort === 'priority') {
            const priorityOrder = { high: 3, medium: 2, low: 1 };
            tasks.sort((a, b) => priorityOrder[b.priority] - priorityOrder[a.priority]);
        } else if (filters.sort === 'dueDate') {
            tasks.sort((a, b) => {
                if (!a.dueDate) return 1;
                if (!b.dueDate) return -1;
                return new Date(a.dueDate) - new Date(b.dueDate);
            });
        }

        // Pagination
        const limit = parseInt(filters.limit) || 50;
        const page = parseInt(filters.page) || 1;
        const start = (page - 1) * limit;
        const end = start + limit;
        const paginated = tasks.slice(start, end);

        return {
            data: paginated,
            total: tasks.length,
            page,
            limit,
            totalPages: Math.ceil(tasks.length / limit),
        };
    }

    // Get a single task
    static getById(id) {
        return storage.findById('tasks', id);
    }

    // Get tasks for a user
    static getByUserId(userId) {
        const tasks = storage.getCollection('tasks');
        return tasks.filter(t => t.userId === userId);
    }

    // Create a new task
    static async create(taskData) {
        // Validate user exists
        const users = storage.getCollection('users');
        const userExists = users.some(u => u.id === taskData.userId);
        if (!userExists) {
            throw new AppError(`User with ID ${taskData.userId} not found`, 404);
        }

        const newTask = await storage.create('tasks', {
            ...taskData,
            completed: taskData.completed || false,
            priority: taskData.priority || 'medium',
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
        });

        return newTask;
    }

    // Update a task
    static async update(id, updates) {
        const task = this.getById(id);
        if (!task) return null;

        // If updating userId, validate new user exists
        if (updates.userId && updates.userId !== task.userId) {
            const users = storage.getCollection('users');
            const userExists = users.some(u => u.id === updates.userId);
            if (!userExists) {
                throw new AppError(`User with ID ${updates.userId} not found`, 404);
            }
        }

        const updatedTask = await storage.update('tasks', id, {
            ...updates,
            updatedAt: new Date().toISOString(),
        });

        return updatedTask;
    }

    // Delete a task
    static async delete(id) {
        return await storage.delete('tasks', id);
    }

    // Delete all tasks for a user
    static async deleteByUserId(userId) {
        const tasks = storage.getCollection('tasks');
        const userTasks = tasks.filter(t => t.userId === userId);
        const remainingTasks = tasks.filter(t => t.userId !== userId);
        storage.setCollection('tasks', remainingTasks);
        await storage.save();
        return userTasks.length;
    }

    // Get task statistics
    static getStats(userId = null) {
        let tasks = storage.getCollection('tasks');
        
        if (userId) {
            tasks = tasks.filter(t => t.userId === userId);
        }

        const now = new Date();
        const stats = {
            total: tasks.length,
            completed: tasks.filter(t => t.completed).length,
            pending: tasks.filter(t => !t.completed).length,
            byPriority: {
                high: tasks.filter(t => t.priority === 'high').length,
                medium: tasks.filter(t => t.priority === 'medium').length,
                low: tasks.filter(t => t.priority === 'low').length,
            },
            overdue: tasks.filter(t => 
                !t.completed && 
                t.dueDate && 
                new Date(t.dueDate) < now
            ).length,
            completionRate: tasks.length > 0 
                ? Math.round((tasks.filter(t => t.completed).length / tasks.length) * 100)
                : 0,
        };

        return stats;
    }

    // Reset data
    static async reset() {
        await storage.reset();
    }
}

module.exports = TaskModel;
```

---

## Controllers

### Auth Controller

Create `src/controllers/auth.controller.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/controllers/auth.controller.js
// DESCRIPTION: Authentication controller
// =====================================================

const UserModel = require('../models/user.model');
const { generateToken } = require('../utils/auth');
const { asyncHandler } = require('../middleware/error');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');

class AuthController {
    // Register a new user
    register = asyncHandler(async (req, res) => {
        const { name, email, password } = req.body;

        const user = await UserModel.create({ name, email, password });

        // Generate token
        const token = generateToken(user);

        logger.info(`User registered: ${user.email}`);

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                user,
                token,
            },
        });
    });

    // Login
    login = asyncHandler(async (req, res) => {
        const { email, password } = req.body;

        const user = await UserModel.authenticate(email, password);
        if (!user) {
            throw new AppError('Invalid email or password', 401);
        }

        // Generate token
        const token = generateToken(user);

        logger.info(`User logged in: ${user.email}`);

        res.json({
            success: true,
            message: 'Login successful',
            data: {
                user,
                token,
            },
        });
    });

    // Get current user profile
    getProfile = asyncHandler(async (req, res) => {
        const user = await UserModel.getWithStats(req.user.id);
        res.json({
            success: true,
            data: user,
        });
    });

    // Update profile
    updateProfile = asyncHandler(async (req, res) => {
        const user = await UserModel.update(req.user.id, req.body);
        if (!user) {
            throw new AppError('User not found', 404);
        }

        logger.info(`User updated profile: ${user.email}`);

        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: user,
        });
    });

    // Logout (client-side token removal, server just acknowledges)
    logout = asyncHandler(async (req, res) => {
        res.json({
            success: true,
            message: 'Logged out successfully',
        });
    });

    // Refresh token
    refreshToken = asyncHandler(async (req, res) => {
        const token = generateToken(req.user);
        res.json({
            success: true,
            data: { token },
        });
    });
}

module.exports = new AuthController();
```

### Task Controller

Create `src/controllers/task.controller.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/controllers/task.controller.js
// DESCRIPTION: Task controller
// =====================================================

const TaskModel = require('../models/task.model');
const UserModel = require('../models/user.model');
const { asyncHandler } = require('../middleware/error');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');

class TaskController {
    // Get all tasks (with filters)
    getTasks = asyncHandler(async (req, res) => {
        const filters = {
            ...req.query,
            userId: req.user.id, // Only get user's own tasks
        };

        const result = TaskModel.getAll(filters);

        res.json({
            success: true,
            data: result.data,
            pagination: {
                total: result.total,
                page: result.page,
                limit: result.limit,
                totalPages: result.totalPages,
            },
        });
    });

    // Get a single task
    getTaskById = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const task = TaskModel.getById(id);

        if (!task) {
            throw new AppError(`Task with ID ${id} not found`, 404);
        }

        // Ensure task belongs to user
        if (task.userId !== req.user.id) {
            throw new AppError('You do not have permission to view this task', 403);
        }

        res.json({
            success: true,
            data: task,
        });
    });

    // Create a new task
    createTask = asyncHandler(async (req, res) => {
        const taskData = {
            ...req.body,
            userId: req.user.id,
        };

        const newTask = await TaskModel.create(taskData);
        logger.info(`Task created by user ${req.user.id}: ${newTask.title}`);

        res.status(201).json({
            success: true,
            message: 'Task created successfully',
            data: newTask,
        });
    });

    // Update a task
    updateTask = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const task = TaskModel.getById(id);

        if (!task) {
            throw new AppError(`Task with ID ${id} not found`, 404);
        }

        if (task.userId !== req.user.id) {
            throw new AppError('You do not have permission to update this task', 403);
        }

        const updatedTask = await TaskModel.update(id, req.body);
        logger.info(`Task updated by user ${req.user.id}: ${updatedTask.title}`);

        res.json({
            success: true,
            message: 'Task updated successfully',
            data: updatedTask,
        });
    });

    // Delete a task
    deleteTask = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const task = TaskModel.getById(id);

        if (!task) {
            throw new AppError(`Task with ID ${id} not found`, 404);
        }

        if (task.userId !== req.user.id) {
            throw new AppError('You do not have permission to delete this task', 403);
        }

        await TaskModel.delete(id);
        logger.info(`Task deleted by user ${req.user.id}: ${task.title}`);

        res.json({
            success: true,
            message: 'Task deleted successfully',
            data: task,
        });
    });

    // Get task statistics
    getStats = asyncHandler(async (req, res) => {
        const stats = TaskModel.getStats(req.user.id);
        res.json({
            success: true,
            data: stats,
        });
    });

    // Bulk create tasks
    bulkCreateTasks = asyncHandler(async (req, res) => {
        const tasks = req.body;
        
        if (!Array.isArray(tasks) || tasks.length === 0) {
            throw new AppError('Tasks array is required', 400);
        }

        if (tasks.length > 50) {
            throw new AppError('Maximum 50 tasks per bulk operation', 400);
        }

        const createdTasks = [];
        for (const taskData of tasks) {
            const newTask = await TaskModel.create({
                ...taskData,
                userId: req.user.id,
            });
            createdTasks.push(newTask);
        }

        logger.info(`Bulk created ${createdTasks.length} tasks by user ${req.user.id}`);

        res.status(201).json({
            success: true,
            message: `${createdTasks.length} tasks created successfully`,
            data: createdTasks,
        });
    });
}

module.exports = new TaskController();
```

---

## Routes

### Auth Routes

Create `src/routes/auth.routes.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/routes/auth.routes.js
// DESCRIPTION: Authentication routes
// =====================================================

const express = require('express');
const router = express.Router();

const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { registerSchema, loginSchema, updateProfileSchema } = require('../utils/validators');

// Public routes
router.post('/register', validate(registerSchema), authController.register);
router.post('/login', validate(loginSchema), authController.login);

// Protected routes
router.get('/profile', authenticate, authController.getProfile);
router.put('/profile', authenticate, validate(updateProfileSchema), authController.updateProfile);
router.post('/logout', authenticate, authController.logout);
router.post('/refresh-token', authenticate, authController.refreshToken);

module.exports = router;
```

### Task Routes

Create `src/routes/task.routes.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/routes/task.routes.js
// DESCRIPTION: Task routes
// =====================================================

const express = require('express');
const router = express.Router();

const taskController = require('../controllers/task.controller');
const { authenticate } = require('../middleware/auth');
const { validate, validateParams, validateQuery } = require('../middleware/validation');
const { createTaskSchema, updateTaskSchema, idParamSchema, taskFiltersSchema } = require('../utils/validators');

// All task routes require authentication
router.use(authenticate);

// GET /tasks/stats - Get statistics
router.get('/stats', taskController.getStats);

// GET /tasks - Get all tasks with filters
router.get('/', validateQuery(taskFiltersSchema), taskController.getTasks);

// POST /tasks/bulk - Bulk create tasks
router.post('/bulk', taskController.bulkCreateTasks);

// GET /tasks/:id - Get a specific task
router.get('/:id', validateParams(idParamSchema), taskController.getTaskById);

// POST /tasks - Create a new task
router.post('/', validate(createTaskSchema), taskController.createTask);

// PUT /tasks/:id - Update a task
router.put(
    '/:id',
    validateParams(idParamSchema),
    validate(updateTaskSchema),
    taskController.updateTask
);

// DELETE /tasks/:id - Delete a task
router.delete('/:id', validateParams(idParamSchema), taskController.deleteTask);

module.exports = router;
```

---

## Frontend

### HTML Template

Create `public/index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TaskMaster Pro</title>
    <link rel="stylesheet" href="/css/styles.css">
</head>
<body>
    <div id="app">
        <!-- Navigation -->
        <nav class="navbar">
            <div class="container">
                <div class="nav-brand">✅ TaskMaster Pro</div>
                <div class="nav-links" id="navLinks">
                    <a href="#" onclick="showDashboard()">Dashboard</a>
                    <a href="#" onclick="showTasks()">Tasks</a>
                    <a href="#" onclick="logout()" id="logoutBtn">Logout</a>
                </div>
                <div class="nav-links" id="navAuth">
                    <a href="#" onclick="showLogin()">Login</a>
                    <a href="#" onclick="showRegister()">Register</a>
                </div>
            </div>
        </nav>

        <!-- Main Content -->
        <main class="container">
            <!-- Login View -->
            <div id="loginView" class="view">
                <div class="card">
                    <h2>Login</h2>
                    <form id="loginForm">
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" id="loginEmail" required>
                        </div>
                        <div class="form-group">
                            <label>Password</label>
                            <input type="password" id="loginPassword" required>
                        </div>
                        <button type="submit">Login</button>
                    </form>
                    <p>Don't have an account? <a href="#" onclick="showRegister()">Register</a></p>
                </div>
            </div>

            <!-- Register View -->
            <div id="registerView" class="view" style="display:none;">
                <div class="card">
                    <h2>Register</h2>
                    <form id="registerForm">
                        <div class="form-group">
                            <label>Name</label>
                            <input type="text" id="registerName" required>
                        </div>
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" id="registerEmail" required>
                        </div>
                        <div class="form-group">
                            <label>Password</label>
                            <input type="password" id="registerPassword" required>
                        </div>
                        <button type="submit">Register</button>
                    </form>
                    <p>Already have an account? <a href="#" onclick="showLogin()">Login</a></p>
                </div>
            </div>

            <!-- Dashboard View -->
            <div id="dashboardView" class="view" style="display:none;">
                <h1>Dashboard</h1>
                <div class="stats-grid" id="statsGrid">
                    <div class="stat-card">
                        <div class="stat-value" id="statTotal">0</div>
                        <div class="stat-label">Total Tasks</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="statCompleted">0</div>
                        <div class="stat-label">Completed</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="statPending">0</div>
                        <div class="stat-label">Pending</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="statOverdue">0</div>
                        <div class="stat-label">Overdue</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="statCompletion">0%</div>
                        <div class="stat-label">Completion Rate</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value" id="statHighPriority">0</div>
                        <div class="stat-label">High Priority</div>
                    </div>
                </div>
                <div class="recent-tasks">
                    <h2>Recent Tasks</h2>
                    <div id="recentTasks"></div>
                </div>
            </div>

            <!-- Tasks View -->
            <div id="tasksView" class="view" style="display:none;">
                <div class="tasks-header">
                    <h1>My Tasks</h1>
                    <button onclick="showCreateTask()">+ New Task</button>
                </div>
                
                <div class="task-filters">
                    <select id="filterPriority" onchange="loadTasks()">
                        <option value="">All Priorities</option>
                        <option value="high">High</option>
                        <option value="medium">Medium</option>
                        <option value="low">Low</option>
                    </select>
                    <select id="filterCompleted" onchange="loadTasks()">
                        <option value="">All Tasks</option>
                        <option value="false">Pending</option>
                        <option value="true">Completed</option>
                    </select>
                    <input type="text" id="searchTasks" placeholder="Search tasks..." oninput="loadTasks()">
                    <select id="sortTasks" onchange="loadTasks()">
                        <option value="newest">Newest</option>
                        <option value="oldest">Oldest</option>
                        <option value="priority">Priority</option>
                        <option value="dueDate">Due Date</option>
                    </select>
                </div>

                <div id="taskList"></div>
                <div id="taskPagination" class="pagination"></div>
            </div>

            <!-- Create/Edit Task Modal -->
            <div id="taskModal" class="modal" style="display:none;">
                <div class="modal-content">
                    <span class="modal-close" onclick="closeModal()">&times;</span>
                    <h2 id="modalTitle">New Task</h2>
                    <form id="taskForm">
                        <input type="hidden" id="taskId">
                        <div class="form-group">
                            <label>Title *</label>
                            <input type="text" id="taskTitle" required>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <textarea id="taskDescription" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label>Priority</label>
                            <select id="taskPriority">
                                <option value="low">Low</option>
                                <option value="medium" selected>Medium</option>
                                <option value="high">High</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Due Date</label>
                            <input type="datetime-local" id="taskDueDate">
                        </div>
                        <div class="form-group">
                            <label>
                                <input type="checkbox" id="taskCompleted"> Completed
                            </label>
                        </div>
                        <button type="submit">Save Task</button>
                    </form>
                </div>
            </div>

            <!-- Alert/Notification -->
            <div id="alert" class="alert" style="display:none;"></div>
        </main>
    </div>

    <script src="/js/app.js"></script>
</body>
</html>
```

### CSS

Create `public/css/styles.css`:

```css
/* =====================================================
   FILE: /taskmaster-pro/public/css/styles.css
   DESCRIPTION: TaskMaster Pro styles
   ===================================================== */

/* Reset & Base */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
    background: #f5f7fa;
    color: #2d3748;
    min-height: 100vh;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

/* Navigation */
.navbar {
    background: #2d3748;
    color: white;
    padding: 1rem 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.navbar .container {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.nav-brand {
    font-size: 1.25rem;
    font-weight: bold;
}

.nav-links a {
    color: #cbd5e0;
    text-decoration: none;
    margin-left: 1.5rem;
    padding: 0.5rem 0;
    border-bottom: 2px solid transparent;
    transition: all 0.2s;
}

.nav-links a:hover {
    color: white;
    border-bottom-color: #4299e1;
}

/* Views */
.view {
    animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

/* Cards */
.card {
    background: white;
    border-radius: 8px;
    padding: 2rem;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    max-width: 400px;
    margin: 2rem auto;
}

.card h2 {
    margin-bottom: 1.5rem;
    text-align: center;
    color: #2d3748;
}

/* Forms */
.form-group {
    margin-bottom: 1rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.25rem;
    font-weight: 500;
    color: #4a5568;
}

.form-group input,
.form-group textarea,
.form-group select {
    width: 100%;
    padding: 0.5rem 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.2s;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
    outline: none;
    border-color: #4299e1;
    box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.2);
}

button {
    width: 100%;
    padding: 0.5rem 1rem;
    background: #4299e1;
    color: white;
    border: none;
    border-radius: 4px;
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
}

button:hover {
    background: #3182ce;
}

button:active {
    transform: scale(0.98);
}

/* Stats Grid */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 1rem;
    margin: 1.5rem 0;
}

.stat-card {
    background: white;
    padding: 1.25rem;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    text-align: center;
}

.stat-value {
    font-size: 2rem;
    font-weight: bold;
    color: #2d3748;
}

.stat-label {
    font-size: 0.875rem;
    color: #718096;
    margin-top: 0.25rem;
}

/* Task List */
.tasks-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 1.5rem 0;
}

.tasks-header button {
    width: auto;
    padding: 0.5rem 1.5rem;
}

.task-filters {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
    margin: 1rem 0;
}

.task-filters input,
.task-filters select {
    padding: 0.5rem;
    border: 1px solid #e2e8f0;
    border-radius: 4px;
    font-size: 0.875rem;
}

.task-filters input {
    flex: 1;
    min-width: 150px;
}

.task-item {
    background: white;
    padding: 1rem;
    margin: 0.5rem 0;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    display: flex;
    justify-content: space-between;
    align-items: center;
    transition: box-shadow 0.2s;
}

.task-item:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.task-info {
    flex: 1;
}

.task-title {
    font-weight: 500;
    font-size: 1.1rem;
}

.task-title.completed {
    text-decoration: line-through;
    color: #a0aec0;
}

.task-meta {
    font-size: 0.875rem;
    color: #718096;
    margin-top: 0.25rem;
}

.task-meta span {
    margin-right: 0.75rem;
}

.tag {
    display: inline-block;
    padding: 0.125rem 0.5rem;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 500;
}

.tag-high { background: #fed7d7; color: #c53030; }
.tag-medium { background: #feebc8; color: #c05621; }
.tag-low { background: #c6f6d5; color: #276749; }
.tag-completed { background: #e2e8f0; color: #4a5568; }

.task-actions {
    display: flex;
    gap: 0.5rem;
}

.task-actions button {
    width: auto;
    padding: 0.25rem 0.75rem;
    font-size: 0.875rem;
}

.btn-edit {
    background: #48bb78;
}

.btn-edit:hover {
    background: #38a169;
}

.btn-delete {
    background: #fc8181;
}

.btn-delete:hover {
    background: #f56565;
}

.btn-toggle {
    background: #9f7aea;
}

.btn-toggle:hover {
    background: #805ad5;
}

/* Pagination */
.pagination {
    display: flex;
    justify-content: center;
    gap: 0.5rem;
    margin: 1.5rem 0;
}

.pagination button {
    width: auto;
    padding: 0.5rem 1rem;
}

.pagination .active {
    background: #2d3748;
}

/* Modal */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
}

.modal-content {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
}

.modal-close {
    float: right;
    font-size: 1.5rem;
    cursor: pointer;
    color: #a0aec0;
}

.modal-close:hover {
    color: #2d3748;
}

/* Alert */
.alert {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    background: #48bb78;
    color: white;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
    z-index: 2000;
    animation: slideIn 0.3s ease;
}

.alert-error {
    background: #fc8181;
}

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to { transform: translateX(0); opacity: 1; }
}

/* Responsive */
@media (max-width: 768px) {
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .task-item {
        flex-direction: column;
        align-items: stretch;
    }
    
    .task-actions {
        margin-top: 0.75rem;
    }
    
    .task-filters {
        flex-direction: column;
    }
    
    .navbar .container {
        flex-direction: column;
        gap: 0.5rem;
    }
    
    .nav-links a {
        margin: 0 0.75rem;
    }
}

/* Utility */
.text-center { text-align: center; }
.mt-1 { margin-top: 1rem; }
.mb-1 { margin-bottom: 1rem; }
.hidden { display: none; }
```

---

### JavaScript Frontend

Create `public/js/app.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/public/js/app.js
// DESCRIPTION: Frontend JavaScript
// =====================================================

// Configuration
const API_URL = '/api';

// State
let state = {
    token: localStorage.getItem('token') || null,
    user: null,
    tasks: [],
    currentPage: 1,
    totalPages: 1,
    editingTask: null,
};

// DOM Elements
const elements = {
    // Views
    loginView: document.getElementById('loginView'),
    registerView: document.getElementById('registerView'),
    dashboardView: document.getElementById('dashboardView'),
    tasksView: document.getElementById('tasksView'),
    
    // Forms
    loginForm: document.getElementById('loginForm'),
    registerForm: document.getElementById('registerForm'),
    taskForm: document.getElementById('taskForm'),
    
    // Navigation
    navLinks: document.getElementById('navLinks'),
    navAuth: document.getElementById('navAuth'),
    logoutBtn: document.getElementById('logoutBtn'),
    
    // Task list
    taskList: document.getElementById('taskList'),
    taskPagination: document.getElementById('taskPagination'),
    recentTasks: document.getElementById('recentTasks'),
    
    // Filters
    filterPriority: document.getElementById('filterPriority'),
    filterCompleted: document.getElementById('filterCompleted'),
    searchTasks: document.getElementById('searchTasks'),
    sortTasks: document.getElementById('sortTasks'),
    
    // Modal
    taskModal: document.getElementById('taskModal'),
    modalTitle: document.getElementById('modalTitle'),
    taskId: document.getElementById('taskId'),
    taskTitle: document.getElementById('taskTitle'),
    taskDescription: document.getElementById('taskDescription'),
    taskPriority: document.getElementById('taskPriority'),
    taskDueDate: document.getElementById('taskDueDate'),
    taskCompleted: document.getElementById('taskCompleted'),
    
    // Stats
    statTotal: document.getElementById('statTotal'),
    statCompleted: document.getElementById('statCompleted'),
    statPending: document.getElementById('statPending'),
    statOverdue: document.getElementById('statOverdue'),
    statCompletion: document.getElementById('statCompletion'),
    statHighPriority: document.getElementById('statHighPriority'),
    
    // Alert
    alert: document.getElementById('alert'),
};

// =====================================================
// API HELPERS
// =====================================================

const api = {
    async request(endpoint, options = {}) {
        const url = `${API_URL}${endpoint}`;
        const headers = {
            'Content-Type': 'application/json',
            ...options.headers,
        };
        
        if (state.token) {
            headers['Authorization'] = `Bearer ${state.token}`;
        }
        
        const response = await fetch(url, {
            ...options,
            headers,
            body: options.body ? JSON.stringify(options.body) : undefined,
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || data.message || 'Request failed');
        }
        
        return data;
    },
    
    auth: {
        login(email, password) {
            return api.request('/auth/login', {
                method: 'POST',
                body: { email, password },
            });
        },
        
        register(name, email, password) {
            return api.request('/auth/register', {
                method: 'POST',
                body: { name, email, password },
            });
        },
        
        logout() {
            return api.request('/auth/logout', { method: 'POST' });
        },
        
        getProfile() {
            return api.request('/auth/profile');
        },
        
        updateProfile(data) {
            return api.request('/auth/profile', {
                method: 'PUT',
                body: data,
            });
        },
    },
    
    tasks: {
        getAll(params = {}) {
            const query = new URLSearchParams(params).toString();
            return api.request(`/tasks?${query}`);
        },
        
        getById(id) {
            return api.request(`/tasks/${id}`);
        },
        
        create(data) {
            return api.request('/tasks', {
                method: 'POST',
                body: data,
            });
        },
        
        update(id, data) {
            return api.request(`/tasks/${id}`, {
                method: 'PUT',
                body: data,
            });
        },
        
        delete(id) {
            return api.request(`/tasks/${id}`, {
                method: 'DELETE',
            });
        },
        
        getStats() {
            return api.request('/tasks/stats');
        },
        
        bulkCreate(tasks) {
            return api.request('/tasks/bulk', {
                method: 'POST',
                body: tasks,
            });
        },
    },
};

// =====================================================
// UI HELPERS
// =====================================================

function showView(viewId) {
    const views = ['loginView', 'registerView', 'dashboardView', 'tasksView'];
    views.forEach(id => {
        const el = document.getElementById(id);
        el.style.display = id === viewId ? 'block' : 'none';
    });
}

function showAlert(message, type = 'success') {
    const alert = elements.alert;
    alert.textContent = message;
    alert.className = `alert ${type === 'error' ? 'alert-error' : ''}`;
    alert.style.display = 'block';
    
    setTimeout(() => {
        alert.style.display = 'none';
    }, 3000);
}

function updateNav() {
    const isAuthenticated = !!state.token;
    elements.navLinks.style.display = isAuthenticated ? 'flex' : 'none';
    elements.navAuth.style.display = isAuthenticated ? 'none' : 'flex';
}

// =====================================================
// AUTH FUNCTIONS
// =====================================================

async function login(email, password) {
    try {
        const response = await api.auth.login(email, password);
        state.token = response.data.token;
        state.user = response.data.user;
        localStorage.setItem('token', state.token);
        updateNav();
        await loadDashboard();
        showView('dashboardView');
        showAlert('Login successful!');
    } catch (error) {
        showAlert(error.message, 'error');
    }
}

async function register(name, email, password) {
    try {
        const response = await api.auth.register(name, email, password);
        state.token = response.data.token;
        state.user = response.data.user;
        localStorage.setItem('token', state.token);
        updateNav();
        await loadDashboard();
        showView('dashboardView');
        showAlert('Registration successful!');
    } catch (error) {
        showAlert(error.message, 'error');
    }
}

async function logout() {
    try {
        await api.auth.logout();
    } catch (error) {
        // Ignore errors on logout
    }
    state.token = null;
    state.user = null;
    localStorage.removeItem('token');
    updateNav();
    showView('loginView');
    showAlert('Logged out');
}

// =====================================================
// TASK FUNCTIONS
// =====================================================

async function loadTasks(page = 1) {
    try {
        const params = {
            page,
            limit: 10,
            sort: elements.sortTasks.value || 'newest',
        };
        
        if (elements.filterPriority.value) {
            params.priority = elements.filterPriority.value;
        }
        
        if (elements.filterCompleted.value !== '') {
            params.completed = elements.filterCompleted.value;
        }
        
        if (elements.searchTasks.value) {
            params.search = elements.searchTasks.value;
        }
        
        const response = await api.tasks.getAll(params);
        state.tasks = response.data;
        state.currentPage = response.pagination.page;
        state.totalPages = response.pagination.totalPages;
        
        renderTasks();
        renderPagination();
    } catch (error) {
        showAlert('Failed to load tasks: ' + error.message, 'error');
    }
}

function renderTasks() {
    const container = elements.taskList;
    
    if (state.tasks.length === 0) {
        container.innerHTML = '<p class="text-center">No tasks found. Create your first task!</p>';
        return;
    }
    
    container.innerHTML = state.tasks.map(task => `
        <div class="task-item">
            <div class="task-info">
                <div class="task-title ${task.completed ? 'completed' : ''}">
                    ${task.title}
                </div>
                <div class="task-meta">
                    <span class="tag tag-${task.priority}">${task.priority}</span>
                    ${task.completed ? '<span class="tag tag-completed">✓ Completed</span>' : ''}
                    ${task.dueDate ? `<span>📅 ${new Date(task.dueDate).toLocaleDateString()}</span>` : ''}
                    <span>📝 ${task.description || 'No description'}</span>
                </div>
            </div>
            <div class="task-actions">
                <button class="btn-toggle" onclick="toggleTask(${task.id})">
                    ${task.completed ? '↺' : '✓'}
                </button>
                <button class="btn-edit" onclick="editTask(${task.id})">✎</button>
                <button class="btn-delete" onclick="deleteTask(${task.id})">✕</button>
            </div>
        </div>
    `).join('');
}

function renderPagination() {
    const container = elements.taskPagination;
    const { currentPage, totalPages } = state;
    
    if (totalPages <= 1) {
        container.innerHTML = '';
        return;
    }
    
    let html = '';
    for (let i = 1; i <= totalPages; i++) {
        html += `<button class="${i === currentPage ? 'active' : ''}" onclick="loadTasks(${i})">${i}</button>`;
    }
    container.innerHTML = html;
}

async function createTask(data) {
    try {
        await api.tasks.create(data);
        await loadTasks(state.currentPage);
        closeModal();
        showAlert('Task created successfully!');
    } catch (error) {
        showAlert('Failed to create task: ' + error.message, 'error');
    }
}

async function updateTask(id, data) {
    try {
        await api.tasks.update(id, data);
        await loadTasks(state.currentPage);
        closeModal();
        showAlert('Task updated successfully!');
    } catch (error) {
        showAlert('Failed to update task: ' + error.message, 'error');
    }
}

async function deleteTask(id) {
    if (!confirm('Are you sure you want to delete this task?')) return;
    
    try {
        await api.tasks.delete(id);
        await loadTasks(state.currentPage);
        showAlert('Task deleted successfully!');
    } catch (error) {
        showAlert('Failed to delete task: ' + error.message, 'error');
    }
}

async function toggleTask(id) {
    const task = state.tasks.find(t => t.id === id);
    if (!task) return;
    
    try {
        await api.tasks.update(id, { completed: !task.completed });
        await loadTasks(state.currentPage);
        showAlert('Task updated!');
    } catch (error) {
        showAlert('Failed to update task: ' + error.message, 'error');
    }
}

function editTask(id) {
    const task = state.tasks.find(t => t.id === id);
    if (!task) return;
    
    state.editingTask = task;
    elements.modalTitle.textContent = 'Edit Task';
    elements.taskId.value = task.id;
    elements.taskTitle.value = task.title;
    elements.taskDescription.value = task.description || '';
    elements.taskPriority.value = task.priority;
    elements.taskDueDate.value = task.dueDate ? task.dueDate.slice(0, 16) : '';
    elements.taskCompleted.checked = task.completed;
    elements.taskModal.style.display = 'flex';
}

function showCreateTask() {
    state.editingTask = null;
    elements.modalTitle.textContent = 'New Task';
    elements.taskId.value = '';
    elements.taskTitle.value = '';
    elements.taskDescription.value = '';
    elements.taskPriority.value = 'medium';
    elements.taskDueDate.value = '';
    elements.taskCompleted.checked = false;
    elements.taskModal.style.display = 'flex';
}

function closeModal() {
    elements.taskModal.style.display = 'none';
}

// =====================================================
// DASHBOARD FUNCTIONS
// =====================================================

async function loadDashboard() {
    try {
        const [statsResponse, tasksResponse] = await Promise.all([
            api.tasks.getStats(),
            api.tasks.getAll({ limit: 5, sort: 'newest' }),
        ]);
        
        const stats = statsResponse.data;
        const recentTasks = tasksResponse.data;
        
        elements.statTotal.textContent = stats.total;
        elements.statCompleted.textContent = stats.completed;
        elements.statPending.textContent = stats.pending;
        elements.statOverdue.textContent = stats.overdue || 0;
        elements.statCompletion.textContent = stats.completionRate + '%';
        elements.statHighPriority.textContent = stats.byPriority?.high || 0;
        
        // Recent tasks
        const container = elements.recentTasks;
        if (recentTasks.length === 0) {
            container.innerHTML = '<p>No recent tasks.</p>';
        } else {
            container.innerHTML = recentTasks.map(task => `
                <div class="task-item">
                    <div class="task-info">
                        <div class="task-title ${task.completed ? 'completed' : ''}">
                            ${task.title}
                        </div>
                        <div class="task-meta">
                            <span class="tag tag-${task.priority}">${task.priority}</span>
                            ${task.completed ? '<span class="tag tag-completed">✓ Completed</span>' : ''}
                        </div>
                    </div>
                </div>
            `).join('');
        }
    } catch (error) {
        showAlert('Failed to load dashboard: ' + error.message, 'error');
    }
}

// =====================================================
// VIEW FUNCTIONS
// =====================================================

function showLogin() {
    showView('loginView');
}

function showRegister() {
    showView('registerView');
}

function showDashboard() {
    loadDashboard();
    showView('dashboardView');
}

function showTasks() {
    loadTasks();
    showView('tasksView');
}

// =====================================================
// EVENT HANDLERS
// =====================================================

// Login form
elements.loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    await login(email, password);
});

// Register form
elements.registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const name = document.getElementById('registerName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    await register(name, email, password);
});

// Task form
elements.taskForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const data = {
        title: elements.taskTitle.value,
        description: elements.taskDescription.value,
        priority: elements.taskPriority.value,
        dueDate: elements.taskDueDate.value || null,
        completed: elements.taskCompleted.checked,
    };
    
    const id = elements.taskId.value;
    if (id) {
        await updateTask(parseInt(id), data);
    } else {
        await createTask(data);
    }
});

// Modal close on outside click
elements.taskModal.addEventListener('click', (e) => {
    if (e.target === elements.taskModal) {
        closeModal();
    }
});

// Keyboard shortcut: Escape to close modal
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeModal();
    }
});

// =====================================================
// INITIALIZATION
// =====================================================

async function init() {
    // Check for existing token
    const token = localStorage.getItem('token');
    if (token) {
        state.token = token;
        try {
            const response = await api.auth.getProfile();
            state.user = response.data;
            updateNav();
            await loadDashboard();
            showView('dashboardView');
            return;
        } catch (error) {
            // Token is invalid, clear it
            state.token = null;
            localStorage.removeItem('token');
        }
    }
    
    updateNav();
    showView('loginView');
}

// Start the app
init();

// Expose functions to global scope
window.showLogin = showLogin;
window.showRegister = showRegister;
window.showDashboard = showDashboard;
window.showTasks = showTasks;
window.showCreateTask = showCreateTask;
window.closeModal = closeModal;
window.loadTasks = loadTasks;
window.editTask = editTask;
window.deleteTask = deleteTask;
window.toggleTask = toggleTask;
window.logout = logout;
```

---

## Main Application Files

### App Configuration

Create `src/app.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/src/app.js
// DESCRIPTION: Express app configuration
// =====================================================

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const path = require('path');

const config = require('../config/config');
const logger = require('./utils/logger');
const { requestIdMiddleware } = require('./middleware/error');
const { errorHandler, notFoundHandler } = require('./middleware/error');

// Import routes
const authRoutes = require('./routes/auth.routes');
const taskRoutes = require('./routes/task.routes');

// Create app
const app = express();

// =====================================================
// SECURITY MIDDLEWARE
// =====================================================

app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", "data:"],
        },
    },
}));

app.use(cors({
    origin: config.allowedOrigins,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
    exposedHeaders: ['X-Request-Id'],
    credentials: true,
}));

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: {
        success: false,
        error: 'Too many requests, please try again later.',
    },
});
app.use('/api', limiter);

app.use(compression());
app.use(requestIdMiddleware);
app.use(mongoSanitize());
app.use(xss());

// =====================================================
// PARSING MIDDLEWARE
// =====================================================

app.use(express.json({ 
    limit: '10mb',
    verify: (req, res, buf) => {
        try {
            JSON.parse(buf);
        } catch (e) {
            throw new Error('Invalid JSON');
        }
    }
}));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// =====================================================
// STATIC FILES
// =====================================================

app.use(express.static(path.join(__dirname, '../public')));

// =====================================================
// LOGGING
// =====================================================

app.use(logger.requestLogger());

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

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);

// Serve frontend
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/index.html'));
});

// =====================================================
// ERROR HANDLING
// =====================================================

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
```

### Server Entry Point

Create `server.js`:

```javascript
// =====================================================
// FILE: /taskmaster-pro/server.js
// DESCRIPTION: Server entry point
// =====================================================

require('dotenv').config();

const config = require('./config/config');
const app = require('./src/app');
const logger = require('./src/utils/logger');
const storage = require('./src/services/storage.service');

async function startServer() {
    try {
        // Initialize storage
        await storage.init();
        logger.info('Storage initialized');

        // Start server
        const server = app.listen(config.port, () => {
            console.log(`========================================`);
            console.log(`🚀 TaskMaster Pro`);
            console.log(`📡 http://localhost:${config.port}`);
            console.log(`🔧 Environment: ${config.env}`);
            console.log(`========================================`);
            console.log(`📊 Users: ${storage.count('users')}`);
            console.log(`📊 Tasks: ${storage.count('tasks')}`);
            console.log(`========================================`);
            console.log(`🔒 Press Ctrl+C to stop`);
            console.log(`========================================`);
        });

        // Error handling
        server.on('error', (error) => {
            if (error.code === 'EADDRINUSE') {
                logger.error(`Port ${config.port} is already in use`);
                process.exit(1);
            } else {
                logger.error('Server error:', error);
                process.exit(1);
            }
        });

        // Graceful shutdown
        process.on('SIGINT', () => {
            logger.info('\nShutting down...');
            server.close(() => {
                logger.info('Server closed');
                process.exit(0);
            });
        });

        process.on('SIGTERM', () => {
            logger.info('Received SIGTERM, shutting down...');
            server.close(() => {
                logger.info('Server closed');
                process.exit(0);
            });
        });

        // Uncaught exceptions
        process.on('uncaughtException', (error) => {
            logger.error('Uncaught exception:', error);
            process.exit(1);
        });

        process.on('unhandledRejection', (reason) => {
            logger.error('Unhandled rejection:', reason);
            process.exit(1);
        });

    } catch (error) {
        logger.error('Failed to start server:', error);
        process.exit(1);
    }
}

startServer();
```

### Update package.json

```json
{
  "name": "taskmaster-pro",
  "version": "1.0.0",
  "description": "A complete task management application built with Node.js and Express",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["express", "nodejs", "tasks", "api", "tutorial"],
  "author": "Your Name",
  "license": "MIT",
  "dependencies": {
    "bcryptjs": "^2.4.3",
    "compression": "^1.7.4",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3",
    "express": "^4.18.2",
    "express-mongo-sanitize": "^2.2.0",
    "express-rate-limit": "^6.7.0",
    "helmet": "^7.0.0",
    "joi": "^17.9.1",
    "jsonwebtoken": "^9.0.0",
    "uuid": "^9.0.0",
    "xss-clean": "^0.1.1"
  },
  "devDependencies": {
    "nodemon": "^2.0.22"
  }
}
```

---

## Running the Application

### Development

```bash
npm run dev
```

### Production

```bash
npm start
```

### Testing

```bash
# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"password123"}'

# Get token from response and use it
TOKEN="your-token-here"

# Get tasks
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/api/tasks

# Create task
curl -X POST http://localhost:3000/api/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Complete project","description":"Finish TaskMaster Pro","priority":"high"}'
```

---

## Deployment

### Option 1: Deploy to Render

1. Push your code to GitHub
2. Sign up at [Render.com](https://render.com)
3. Click "New +" → "Web Service"
4. Connect your GitHub repository
5. Configure:
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Environment Variables:
     - `NODE_ENV=production`
     - `JWT_SECRET=your-secret-key`
     - `API_KEY=your-api-key`
6. Click "Create Web Service"

### Option 2: Deploy to Railway

1. Push your code to GitHub
2. Sign up at [Railway.app](https://railway.app)
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Add environment variables
6. Railway will automatically deploy

### Option 3: Deploy to Heroku

```bash
# Install Heroku CLI and login
heroku login

# Create app
heroku create taskmaster-pro

# Set environment variables
heroku config:set JWT_SECRET=your-secret-key
heroku config:set API_KEY=your-api-key
heroku config:set NODE_ENV=production

# Deploy
git push heroku main

# Open app
heroku open
```

### Option 4: Deploy to VPS (DigitalOcean, AWS, etc.)

```bash
# On your server
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone your repo
git clone https://github.com/yourusername/taskmaster-pro.git
cd taskmaster-pro

# Install dependencies
npm install --production

# Set environment variables
export NODE_ENV=production
export JWT_SECRET=your-secret-key
export API_KEY=your-api-key
export PORT=3000

# Start with PM2
npm install -g pm2
pm2 start server.js --name taskmaster-pro
pm2 save
pm2 startup
```

---

## Monitoring and Maintenance

### Logs

```bash
# Check logs
cat logs/app.log

# With PM2
pm2 logs taskmaster-pro
```

### Health Check

```bash
curl http://your-domain.com/health
```

### Backup Data

```bash
# Backup the database file
cp data/db.json data/db_backup_$(date +%Y%m%d).json
```

### Update the Application

```bash
# Pull latest changes
git pull

# Install new dependencies
npm install

# Restart
pm2 restart taskmaster-pro
```

---

## What You've Built

Congratulations! You've built a complete, production-ready task management application with:

| Feature | Implemented |
|---------|-------------|
| User authentication | ✅ JWT with bcrypt |
| Task CRUD operations | ✅ Create, Read, Update, Delete |
| Task filtering & sorting | ✅ Priority, status, search, sort |
| Dashboard with statistics | ✅ Real-time stats |
| Responsive UI | ✅ Works on all devices |
| REST API | ✅ Complete API endpoints |
| File-based persistence | ✅ Data survives restarts |
| Security | ✅ Headers, rate limiting, validation |
| Error handling | ✅ Global error handler |
| Logging | ✅ Structured logging |
| Deployment ready | ✅ Multiple deployment options |

---

## Next Steps

Here's what you can explore next:

1. **Add a database** — Replace file storage with PostgreSQL, MongoDB, or SQLite
2. **Add more features** — Tags, attachments, sharing, collaboration
3. **Write tests** — Unit tests and integration tests
4. **Add API documentation** — Swagger/OpenAPI
5. **Add real-time features** — WebSocket notifications
6. **Build a mobile app** — React Native or Flutter
7. **Add CI/CD** — GitHub Actions or GitLab CI

---

## Congratulations! 🎉

You've completed the entire Node.js + Express tutorial series! You started with absolutely no knowledge of backend development and now you've built and deployed a complete, secure, well-structured web application.

You've learned:
- What servers are and how they work
- Node.js and the http module
- Express framework fundamentals
- Routing and URL data handling
- Middleware and its power
- Form and JSON data handling
- Project structure and organization
- Persistence and CRUD operations
- Error handling and security
- Building and deploying a complete application

**You're now ready to build your own backend applications!**
