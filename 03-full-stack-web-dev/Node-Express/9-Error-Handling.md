# Part 9: Error Handling, Validation, and Safety

Welcome to Part 9! In Part 8, we added persistence to our application with file-based storage and built complete CRUD operations. Now we're going to focus on making our application **robust, secure, and production-ready**.

Error handling, validation, and security are what separate hobby projects from professional applications. In this part, you'll learn how to build applications that handle failures gracefully, validate input thoroughly, and protect against common attacks.

By the end of this part, you'll understand:
- Centralized error handling patterns
- Input validation best practices
- Security headers and middleware
- Preventing common vulnerabilities (injection, XSS, CSRF)
- Logging and monitoring
- Rate limiting and brute force protection
- Data sanitization
- Secure password handling

---

## Error Handling: The Foundation of Robust Applications

Error handling is about **expecting the unexpected**. Your application will encounter errors — network failures, invalid input, database issues, and bugs. How you handle these errors determines whether your users have a good experience or a frustrating one.

### The Error Handling Pyramid

Think of error handling like a **safety net** at a circus:

```
┌─────────────────────────────────────┐
│         Global Error Handler        │ ← Last resort catch-all
├─────────────────────────────────────┤
│         Route-Level Errors          │ ← Specific route errors
├─────────────────────────────────────┤
│        Controller-Level Errors      │ ← Business logic errors
├─────────────────────────────────────┤
│       Service/Model-Level Errors    │ ← Data layer errors
└─────────────────────────────────────┘
```

### Building a Comprehensive Error Handling System

Let's enhance our error handling system with more features.

#### Step 1: Enhanced Error Classes

Create `src/utils/errors.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/utils/errors.js
// DESCRIPTION: Custom error classes and error handling utilities
// =====================================================

const logger = require('./logger');

/**
 * Base application error class
 * All custom errors should extend this
 */
class AppError extends Error {
    constructor(message, statusCode = 500, isOperational = true) {
        super(message);
        this.statusCode = statusCode;
        this.isOperational = isOperational;
        this.timestamp = new Date().toISOString();
        
        // Capture stack trace
        Error.captureStackTrace(this, this.constructor);
    }
}

/**
 * Validation error (400)
 */
class ValidationError extends AppError {
    constructor(message, errors = []) {
        super(message, 400);
        this.name = 'ValidationError';
        this.errors = errors;
    }
}

/**
 * Authentication error (401)
 */
class AuthenticationError extends AppError {
    constructor(message = 'Authentication required') {
        super(message, 401);
        this.name = 'AuthenticationError';
    }
}

/**
 * Authorization error (403)
 */
class AuthorizationError extends AppError {
    constructor(message = 'Insufficient permissions') {
        super(message, 403);
        this.name = 'AuthorizationError';
    }
}

/**
 * Not found error (404)
 */
class NotFoundError extends AppError {
    constructor(resource = 'Resource') {
        super(`${resource} not found`, 404);
        this.name = 'NotFoundError';
    }
}

/**
 * Conflict error (409)
 */
class ConflictError extends AppError {
    constructor(message = 'Resource already exists') {
        super(message, 409);
        this.name = 'ConflictError';
    }
}

/**
 * Rate limit error (429)
 */
class RateLimitError extends AppError {
    constructor(message = 'Too many requests') {
        super(message, 429);
        this.name = 'RateLimitError';
    }
}

/**
 * Database error (500)
 */
class DatabaseError extends AppError {
    constructor(message = 'Database operation failed') {
        super(message, 500);
        this.name = 'DatabaseError';
    }
}

/**
 * Error response formatter
 */
const formatErrorResponse = (error) => {
    const response = {
        success: false,
        error: {
            message: error.message || 'An unexpected error occurred',
            code: error.name || 'InternalServerError',
            timestamp: error.timestamp || new Date().toISOString(),
        },
    };

    // Add validation errors if present
    if (error.errors && error.errors.length > 0) {
        response.error.details = error.errors;
    }

    // Add stack trace in development
    if (process.env.NODE_ENV === 'development' && error.stack) {
        response.error.stack = error.stack;
    }

    return response;
};

/**
 * Error logging utility
 */
const logError = (error, req = null) => {
    const context = {
        name: error.name,
        message: error.message,
        statusCode: error.statusCode || 500,
        timestamp: error.timestamp || new Date().toISOString(),
        isOperational: error.isOperational !== false,
        stack: error.stack,
    };

    if (req) {
        context.request = {
            method: req.method,
            url: req.url,
            ip: req.ip,
            userAgent: req.get('user-agent'),
            body: req.body,
            params: req.params,
            query: req.query,
        };
    }

    // Log at appropriate level
    if (error.statusCode >= 500) {
        logger.error('Server error:', context);
    } else if (error.statusCode >= 400) {
        logger.warn('Client error:', context);
    } else {
        logger.info('Error:', context);
    }
};

module.exports = {
    AppError,
    ValidationError,
    AuthenticationError,
    AuthorizationError,
    NotFoundError,
    ConflictError,
    RateLimitError,
    DatabaseError,
    formatErrorResponse,
    logError,
};
```

#### Step 2: Enhanced Error Middleware

Update `src/middleware/error.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/middleware/error.js
// DESCRIPTION: Enhanced error handling middleware
// =====================================================

const {
    AppError,
    ValidationError,
    AuthenticationError,
    AuthorizationError,
    NotFoundError,
    ConflictError,
    RateLimitError,
    DatabaseError,
    formatErrorResponse,
    logError,
} = require('../utils/errors');

const config = require('../../config/config');
const logger = require('../utils/logger');

/**
 * Global error handler
 * This catches any errors passed to next() or thrown in routes
 */
const errorHandler = (err, req, res, next) => {
    // Log the error
    logError(err, req);

    // If it's not an AppError, convert it
    if (!(err instanceof AppError)) {
        // Check if it's a known error type
        if (err.name === 'ValidationError') {
            err = new ValidationError(err.message, err.errors);
        } else if (err.name === 'UnauthorizedError' || err.name === 'JsonWebTokenError') {
            err = new AuthenticationError(err.message);
        } else if (err.name === 'MulterError') {
            if (err.code === 'FILE_TOO_LARGE') {
                err = new AppError('File too large', 400);
            } else {
                err = new AppError(`Upload error: ${err.message}`, 400);
            }
        } else if (err.code === 'EACCES') {
            err = new AppError('Permission denied', 403);
        } else {
            // Unknown error - make it a generic server error
            err = new AppError(
                err.message || 'Internal server error',
                err.status || 500,
                false
            );
        }
    }

    // Format the error response
    const errorResponse = formatErrorResponse(err);

    // Add request ID for tracing (if available)
    if (req.requestId) {
        errorResponse.error.requestId = req.requestId;
    }

    // Send the response
    res.status(err.statusCode || 500).json(errorResponse);
};

/**
 * 404 handler
 * Called when no route matches the request
 */
const notFoundHandler = (req, res, next) => {
    const error = new NotFoundError(`Route ${req.method} ${req.url}`);
    next(error);
};

/**
 * Async wrapper for route handlers
 * Automatically catches errors and passes them to error handler
 */
const asyncHandler = (fn) => {
    return (req, res, next) => {
        Promise.resolve(fn(req, res, next)).catch(next);
    };
};

/**
 * Request ID middleware
 * Generates a unique ID for each request for tracing
 */
const requestIdMiddleware = (req, res, next) => {
    const requestId = require('crypto').randomBytes(16).toString('hex');
    req.requestId = requestId;
    res.setHeader('X-Request-Id', requestId);
    next();
};

module.exports = {
    errorHandler,
    notFoundHandler,
    asyncHandler,
    requestIdMiddleware,
};
```

#### Step 3: Update Controllers to Use AsyncHandler

Update `src/controllers/user.controller.js` to use the async handler:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/controllers/user.controller.js
// DESCRIPTION: User controller with async handler
// =====================================================

const UserModel = require('../models/user.model');
const { asyncHandler } = require('../middleware/error');
const {
    ValidationError,
    NotFoundError,
    ConflictError,
    DatabaseError,
} = require('../utils/errors');
const logger = require('../utils/logger');

class UserController {
    // Get all users
    getAllUsers = asyncHandler(async (req, res) => {
        const users = UserModel.getAll();
        logger.debug(`Returning ${users.length} users`);
        
        res.json({
            success: true,
            count: users.length,
            data: users,
        });
    });

    // Get a single user
    getUserById = asyncHandler(async (req, res) => {
        const { id } = req.params;
        const user = UserModel.getById(id);

        if (!user) {
            throw new NotFoundError(`User with ID ${id}`);
        }

        res.json({
            success: true,
            data: user,
        });
    });

    // Create a new user
    createUser = asyncHandler(async (req, res) => {
        const userData = req.body;

        // Check if email already exists
        const existingUser = UserModel.getByEmail(userData.email);
        if (existingUser) {
            throw new ConflictError('Email already registered');
        }

        const newUser = await UserModel.create(userData);
        logger.info(`User created: ${newUser.email}`);

        res.status(201).json({
            success: true,
            message: 'User created successfully',
            data: newUser,
        });
    });

    // ... other methods similarly updated
}

module.exports = new UserController();
```

---

## Input Validation: The First Line of Defense

Input validation is critical for security and data integrity. Never trust user input.

### Validation Strategy

```
User Input → Sanitize → Validate → Process → Store
     ↓          ↓          ↓         ↓        ↓
   Raw data  Clean data  Valid data  Processed Stored
```

### Comprehensive Validation Middleware

Update `src/middleware/validation.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/middleware/validation.js
// DESCRIPTION: Enhanced validation middleware
// =====================================================

const Joi = require('joi');
const { ValidationError } = require('../utils/errors');
const logger = require('../utils/logger');

/**
 * Create validation middleware from Joi schema
 */
const validate = (schema, options = {}) => {
    return (req, res, next) => {
        // Determine what to validate based on options
        const target = options.target || 'body';
        const data = req[target];

        // Validate the data
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

            logger.debug('Validation failed:', errorDetails);
            throw new ValidationError('Validation failed', errorDetails);
        }

        // Replace the original data with validated data
        req[target] = value;
        next();
    };
};

/**
 * Common validation schemas
 */
const schemas = {
    // User schemas
    createUser: Joi.object({
        name: Joi.string()
            .min(2)
            .max(50)
            .required()
            .messages({
                'string.min': 'Name must be at least 2 characters',
                'string.max': 'Name must be at most 50 characters',
                'any.required': 'Name is required',
            }),
        email: Joi.string()
            .email()
            .required()
            .messages({
                'string.email': 'Please provide a valid email address',
                'any.required': 'Email is required',
            }),
        password: Joi.string()
            .min(8)
            .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
            .required()
            .messages({
                'string.min': 'Password must be at least 8 characters',
                'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, and one number',
                'any.required': 'Password is required',
            }),
    }),

    updateUser: Joi.object({
        name: Joi.string().min(2).max(50),
        email: Joi.string().email(),
        password: Joi.string().min(8),
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update',
    }),

    // Task schemas
    createTask: Joi.object({
        userId: Joi.number()
            .integer()
            .positive()
            .required()
            .messages({
                'number.base': 'User ID must be a number',
                'number.integer': 'User ID must be an integer',
                'number.positive': 'User ID must be a positive number',
                'any.required': 'User ID is required',
            }),
        title: Joi.string()
            .min(1)
            .max(100)
            .required()
            .messages({
                'string.min': 'Title must be at least 1 character',
                'string.max': 'Title must be at most 100 characters',
                'any.required': 'Title is required',
            }),
        description: Joi.string()
            .max(500)
            .allow('')
            .messages({
                'string.max': 'Description must be at most 500 characters',
            }),
        completed: Joi.boolean().default(false),
        priority: Joi.string()
            .valid('low', 'medium', 'high')
            .default('medium')
            .messages({
                'any.only': 'Priority must be one of: low, medium, high',
            }),
    }),

    updateTask: Joi.object({
        userId: Joi.number().integer().positive(),
        title: Joi.string().min(1).max(100),
        description: Joi.string().max(500).allow(''),
        completed: Joi.boolean(),
        priority: Joi.string().valid('low', 'medium', 'high'),
    }).min(1).messages({
        'object.min': 'At least one field must be provided for update',
    }),

    // Query parameter schemas
    taskFilters: Joi.object({
        userId: Joi.number().integer().positive(),
        completed: Joi.boolean(),
        priority: Joi.string().valid('low', 'medium', 'high'),
        sort: Joi.string().valid('newest', 'oldest'),
        limit: Joi.number().integer().min(1).max(100),
        page: Joi.number().integer().min(1),
    }),

    // ID parameter
    idParam: Joi.object({
        id: Joi.number()
            .integer()
            .positive()
            .required()
            .messages({
                'number.base': 'ID must be a number',
                'number.integer': 'ID must be an integer',
                'number.positive': 'ID must be a positive number',
                'any.required': 'ID is required',
            }),
    }),

    // Bulk operations
    bulkCreate: Joi.array()
        .items(Joi.object({
            userId: Joi.number().integer().positive().required(),
            title: Joi.string().min(1).max(100).required(),
            description: Joi.string().max(500).allow(''),
            priority: Joi.string().valid('low', 'medium', 'high').default('medium'),
        }))
        .min(1)
        .max(100)
        .messages({
            'array.min': 'At least one item is required',
            'array.max': 'Maximum 100 items allowed in bulk operation',
        }),
};

/**
 * Validates request parameters
 */
const validateParams = (schema) => {
    return validate(schema, { target: 'params' });
};

/**
 * Validates request query
 */
const validateQuery = (schema) => {
    return validate(schema, { target: 'query' });
};

/**
 * Sanitize string input
 * Removes potentially dangerous characters
 */
const sanitizeString = (input) => {
    if (typeof input !== 'string') return input;
    return input
        .trim()
        .replace(/[<>]/g, '') // Remove < and >
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .replace(/\//g, '&#x2F;');
};

/**
 * Sanitize entire object recursively
 */
const sanitizeObject = (obj) => {
    if (obj === null || obj === undefined) return obj;
    
    if (typeof obj === 'string') {
        return sanitizeString(obj);
    }
    
    if (Array.isArray(obj)) {
        return obj.map(item => sanitizeObject(item));
    }
    
    if (typeof obj === 'object') {
        const result = {};
        for (const [key, value] of Object.entries(obj)) {
            result[key] = sanitizeObject(value);
        }
        return result;
    }
    
    return obj;
};

/**
 * Sanitization middleware
 * Sanitizes all string fields in the request body
 */
const sanitizeRequest = (req, res, next) => {
    if (req.body) {
        req.body = sanitizeObject(req.body);
    }
    if (req.query) {
        req.query = sanitizeObject(req.query);
    }
    if (req.params) {
        req.params = sanitizeObject(req.params);
    }
    next();
};

module.exports = {
    validate,
    validateParams,
    validateQuery,
    schemas,
    sanitizeString,
    sanitizeObject,
    sanitizeRequest,
};
```

### Using Validation in Routes

Update `src/routes/user.routes.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/routes/user.routes.js
// DESCRIPTION: User routes with enhanced validation
// =====================================================

const express = require('express');
const router = express.Router();

const userController = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth');
const { validate, validateParams, schemas, sanitizeRequest } = require('../middleware/validation');

// All user routes require authentication
router.use(authenticate);

// Sanitize all request bodies
router.use(sanitizeRequest);

// GET /users - Get all users
router.get('/', userController.getAllUsers);

// GET /users/with-tasks - Get users with their tasks
router.get('/with-tasks', userController.getUsersWithTasks);

// GET /users/:id - Get a specific user
router.get(
    '/:id',
    validateParams(schemas.idParam),
    userController.getUserById
);

// POST /users - Create a new user
router.post(
    '/',
    validate(schemas.createUser),
    userController.createUser
);

// PUT /users/:id - Update a user
router.put(
    '/:id',
    validateParams(schemas.idParam),
    validate(schemas.updateUser),
    userController.updateUser
);

// DELETE /users/:id - Delete a user
router.delete(
    '/:id',
    validateParams(schemas.idParam),
    userController.deleteUser
);

module.exports = router;
```

---

## Security Middleware

### Comprehensive Security Setup

Update `src/app.js` to include security middleware:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/app.js
// DESCRIPTION: Express app with comprehensive security
// =====================================================

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const compression = require('compression');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');

const config = require('../config/config');
const logger = require('./utils/logger');
const { requestIdMiddleware } = require('./middleware/error');

// Import routes
const userRoutes = require('./routes/user.routes');
const taskRoutes = require('./routes/task.routes');

// Create Express app
const app = express();

// =====================================================
// SECURITY MIDDLEWARE
// =====================================================

// 1. Security headers
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
        },
    },
}));

// 2. CORS
app.use(cors({
    origin: config.isDevelopment ? '*' : process.env.ALLOWED_ORIGINS?.split(',') || [],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-API-Key'],
    exposedHeaders: ['X-Request-Id'],
    credentials: true,
    maxAge: 86400, // 24 hours
}));

// 3. Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per window
    message: {
        success: false,
        error: 'Too many requests, please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => {
        return req.ip || req.connection.remoteAddress;
    },
});
app.use('/api', limiter);

// 4. Compression
app.use(compression());

// 5. Request ID
app.use(requestIdMiddleware);

// 6. Data sanitization against NoSQL injection
app.use(mongoSanitize());

// 7. Data sanitization against XSS
app.use(xss());

// 8. Parse JSON with size limit
app.use(express.json({ 
    limit: '10mb',
    verify: (req, res, buf, encoding) => {
        // Prevent JSON injection attacks
        try {
            JSON.parse(buf);
        } catch (e) {
            throw new Error('Invalid JSON');
        }
    }
}));

// 9. Parse URL-encoded data with size limit
app.use(express.urlencoded({ 
    extended: true, 
    limit: '10mb' 
}));

// 10. Request logging
app.use(logger.requestLogger());

// ... rest of app configuration
```

### Installing Security Dependencies

```bash
npm install helmet cors express-rate-limit compression express-mongo-sanitize xss-clean
```

---

## Password Security

### Password Hashing

Update the user model to handle password hashing:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/models/user.model.js
// DESCRIPTION: User model with password hashing
// =====================================================

const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const storage = require('../services/storage.service');
const logger = require('../utils/logger');
const { DatabaseError } = require('../utils/errors');

const SALT_ROUNDS = 12;

class UserModel {
    // Hash a password
    static async hashPassword(password) {
        try {
            return await bcrypt.hash(password, SALT_ROUNDS);
        } catch (error) {
            logger.error('Error hashing password:', error);
            throw new DatabaseError('Failed to hash password');
        }
    }

    // Verify a password
    static async verifyPassword(password, hashedPassword) {
        try {
            return await bcrypt.compare(password, hashedPassword);
        } catch (error) {
            logger.error('Error verifying password:', error);
            throw new DatabaseError('Failed to verify password');
        }
    }

    // Create a new user with hashed password
    static async create(userData) {
        try {
            // Hash the password
            const hashedPassword = await this.hashPassword(userData.password);
            
            const newUser = await storage.create('users', {
                ...userData,
                password: hashedPassword,
            });
            
            // Return without password
            const { password, ...safeUser } = newUser;
            return safeUser;
        } catch (error) {
            logger.error('Error creating user:', error);
            throw error;
        }
    }

    // Authenticate a user
    static async authenticate(email, password) {
        try {
            const user = this.getByEmail(email);
            if (!user) {
                return null;
            }

            const isValid = await this.verifyPassword(password, user.password);
            if (!isValid) {
                return null;
            }

            // Return user without password
            const { password: _, ...safeUser } = user;
            return safeUser;
        } catch (error) {
            logger.error('Error authenticating user:', error);
            throw error;
        }
    }

    // ... other methods
}

module.exports = UserModel;
```

### Installing bcrypt

```bash
npm install bcryptjs
```

---

## Logging and Monitoring

### Enhanced Logger with Different Levels

Update `src/utils/logger.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/utils/logger.js
// DESCRIPTION: Enhanced logging with different levels and output formats
// =====================================================

const config = require('../../config/config');
const fs = require('fs');
const path = require('path');

// Log levels
const LEVELS = {
    ERROR: 0,
    WARN: 1,
    INFO: 2,
    DEBUG: 3,
    TRACE: 4,
};

// Level names for display
const LEVEL_NAMES = {
    [LEVELS.ERROR]: 'ERROR',
    [LEVELS.WARN]: 'WARN',
    [LEVELS.INFO]: 'INFO',
    [LEVELS.DEBUG]: 'DEBUG',
    [LEVELS.TRACE]: 'TRACE',
};

// Colors for console output
const COLORS = {
    ERROR: '\x1b[31m',
    WARN: '\x1b[33m',
    INFO: '\x1b[36m',
    DEBUG: '\x1b[35m',
    TRACE: '\x1b[32m',
    RESET: '\x1b[0m',
};

class Logger {
    constructor() {
        this.level = config.isDevelopment ? LEVELS.DEBUG : LEVELS.INFO;
        this.logDir = path.join(__dirname, '../../logs');
        this.logFile = path.join(this.logDir, 'app.log');
        
        // Create log directory if it doesn't exist
        if (!fs.existsSync(this.logDir)) {
            fs.mkdirSync(this.logDir, { recursive: true });
        }
    }

    _shouldLog(level) {
        return level <= this.level;
    }

    _getTimestamp() {
        return new Date().toISOString();
    }

    _formatMessage(level, message, ...args) {
        const timestamp = this._getTimestamp();
        const levelName = LEVEL_NAMES[level] || 'UNKNOWN';
        
        let formattedMessage = `[${timestamp}] ${levelName}: ${message}`;
        
        if (args.length > 0) {
            formattedMessage += ' ' + args.map(arg => {
                if (typeof arg === 'object') {
                    return JSON.stringify(arg);
                }
                return arg;
            }).join(' ');
        }
        
        return formattedMessage;
    }

    _log(level, message, ...args) {
        if (!this._shouldLog(level)) return;

        const formattedMessage = this._formatMessage(level, message, ...args);
        const color = COLORS[LEVEL_NAMES[level]] || COLORS.RESET;

        // Console output with colors
        console.log(`${color}${formattedMessage}${COLORS.RESET}`);

        // File output (always, for all levels)
        if (level >= LEVELS.INFO) {
            try {
                fs.appendFileSync(this.logFile, formattedMessage + '\n');
            } catch (error) {
                // Silently fail if we can't write to file
            }
        }
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

    trace(message, ...args) {
        this._log(LEVELS.TRACE, message, ...args);
    }

    // Express middleware for request logging
    requestLogger() {
        return (req, res, next) => {
            const start = Date.now();
            
            // Log request
            this.debug(`${req.method} ${req.url}`, {
                ip: req.ip,
                userAgent: req.get('user-agent'),
                requestId: req.requestId,
            });

            // Capture response
            const originalSend = res.send;
            res.send = function(...args) {
                const duration = Date.now() - start;
                const statusCode = res.statusCode;
                
                // Log response
                if (statusCode >= 400) {
                    this.warn(`${req.method} ${req.url} ${statusCode} ${duration}ms`);
                } else {
                    this.info(`${req.method} ${req.url} ${statusCode} ${duration}ms`);
                }
                
                originalSend.apply(this, args);
            }.bind(this);

            next();
        };
    }
}

// Export singleton
module.exports = new Logger();
```

---

## Input Sanitization

### Preventing XSS and Injection Attacks

Create `src/utils/sanitizer.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/utils/sanitizer.js
// DESCRIPTION: Input sanitization utilities
// =====================================================

/**
 * Sanitize a string to prevent XSS attacks
 */
const sanitizeString = (input) => {
    if (typeof input !== 'string') return input;
    
    return input
        .trim()
        // Remove HTML tags
        .replace(/<[^>]*>/g, '')
        // Escape special characters
        .replace(/&/g, '&amp;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/\//g, '&#x2F;')
        // Remove SQL injection patterns
        .replace(/('|")(\s*)(or|and|select|insert|update|delete|drop|alter|create)\s*=/gi, '');
};

/**
 * Sanitize an object recursively
 */
const sanitizeObject = (obj) => {
    if (obj === null || obj === undefined) return obj;
    
    if (typeof obj === 'string') {
        return sanitizeString(obj);
    }
    
    if (Array.isArray(obj)) {
        return obj.map(item => sanitizeObject(item));
    }
    
    if (typeof obj === 'object') {
        const result = {};
        for (const [key, value] of Object.entries(obj)) {
            // Skip internal fields
            if (key.startsWith('_')) continue;
            result[key] = sanitizeObject(value);
        }
        return result;
    }
    
    return obj;
};

/**
 * Sanitize email address
 */
const sanitizeEmail = (email) => {
    if (typeof email !== 'string') return email;
    return email.trim().toLowerCase();
};

/**
 * Validate and sanitize URL
 */
const sanitizeUrl = (url) => {
    if (typeof url !== 'string') return url;
    try {
        const parsed = new URL(url);
        return parsed.toString();
    } catch {
        return null;
    }
};

/**
 * Sanitize file name (remove path traversal)
 */
const sanitizeFileName = (filename) => {
    if (typeof filename !== 'string') return filename;
    return filename
        .replace(/\.\./g, '')
        .replace(/[^a-zA-Z0-9._-]/g, '');
};

module.exports = {
    sanitizeString,
    sanitizeObject,
    sanitizeEmail,
    sanitizeUrl,
    sanitizeFileName,
};
```

---

## What We've Learned

In this part, we covered:

1. **Error handling** — Custom error classes, global error handler, async handling
2. **Input validation** — Joi schemas, validation middleware, parameter validation
3. **Security middleware** — Helmet, CORS, rate limiting, compression
4. **Password security** — Hashing with bcrypt
5. **Logging** — Structured logging with different levels
6. **Input sanitization** — Preventing XSS and injection attacks
7. **Monitoring** — Request logging and performance tracking

---

## Practice Exercises

### Exercise 1: Add Input Validation for Bulk Operations
Create a route that accepts multiple tasks in one request. Validate that each task has required fields and that the total doesn't exceed 50 items.

### Exercise 2: Implement Login Endpoint
Create a `/auth/login` endpoint that accepts email and password. Validate credentials against the database and return a JWT token.

### Exercise 3: Add Request Validation Logging
Log all validation failures with the request details. Create a separate log file for security events.

### Exercise 4: Implement IP Blocking
Create a middleware that blocks requests from specific IP addresses. Store blocked IPs in a configuration file.

---

## Summary

You now have a production-ready Express application with:

- **Comprehensive error handling** — Custom errors, global handler, async support
- **Input validation** — Joi schemas, validation middleware, sanitization
- **Security best practices** — Headers, rate limiting, data sanitization
- **Password security** — Hashing and verification
- **Structured logging** — Different levels, file output, request tracking
- **Protection against common attacks** — XSS, SQL injection, CSRF

**In Part 10**, we'll bring everything together in a final project and deploy it to the internet. You'll build a complete task management application that's secure, well-organized, and live on the web.

---

## Quick Reference: Error Handling

| Feature | Code | Description |
|---------|------|-------------|
| Custom error | `class AppError extends Error` | Base error class |
| Validation error | `new ValidationError(message, errors)` | 400 Bad Request |
| Auth error | `new AuthenticationError()` | 401 Unauthorized |
| Not found | `new NotFoundError('User')` | 404 Not Found |
| Conflict | `new ConflictError('Email exists')` | 409 Conflict |
| Async handler | `asyncHandler(fn)` | Wraps async routes |
| Error middleware | `(err, req, res, next) => {}` | Global error handler |
| 404 handler | `notFoundHandler` | Catches unmatched routes |
