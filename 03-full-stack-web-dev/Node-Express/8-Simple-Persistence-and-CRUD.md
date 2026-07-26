# Part 8: Simple Persistence and CRUD

Welcome to Part 8! In Part 7, we structured our application professionally with clear separation of concerns. Now we're going to add **persistence** — the ability to save data so it survives server restarts.

Up until now, all our data has been stored in memory. This means every time you restart the server, all your data disappears. In this part, we'll implement file-based persistence and build complete CRUD (Create, Read, Update, Delete) operations.

By the end of this part, you'll understand:
- What persistence means and why it matters
- How to read and write JSON files with Node.js
- Building a complete storage service
- CRUD operations in a real application
- Error handling for file operations
- Data validation before persistence

---

## What Is Persistence?

**Persistence** means storing data in a way that outlasts the running program. When you save a file on your computer, that's persistence — the data remains even after you close the program.

In web applications, persistence typically means:
1. **In-memory** — Fast but temporary (server restart = data loss)
2. **File-based** — Simple, persistent, but limited for large applications
3. **Database** — Robust, scalable, and feature-rich (we'll cover this in a future series)

For this tutorial, we'll use **file-based persistence** with JSON files. This is perfect for learning because:
- It's simple to understand
- No external dependencies
- Data is human-readable
- Works on any platform

---

## Understanding JSON Files

JSON (JavaScript Object Notation) is a lightweight data format that's easy for humans to read and write, and easy for machines to parse and generate.

### JSON Structure

```json
{
  "users": [
    {
      "id": 1,
      "name": "Alice",
      "email": "alice@example.com",
      "createdAt": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": 2,
      "name": "Bob",
      "email": "bob@example.com",
      "createdAt": "2024-01-15T11:00:00.000Z"
    }
  ],
  "tasks": [
    {
      "id": 1,
      "userId": 1,
      "title": "Learn Express",
      "completed": false,
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

### Why JSON for Persistence?

| Feature | Why It's Good |
|---------|---------------|
| **Human-readable** | You can open the file and understand the data |
| **JavaScript-native** | Easy to parse with `JSON.parse()` and `JSON.stringify()` |
| **Portable** | Works on any platform |
| **Version-control friendly** | You can see changes in git diffs |
| **No dependencies** | Built into Node.js |

---

## Building the Storage Service

Let's create a storage service that handles reading and writing JSON files.

### Step 1: Create the Storage Service

Create `src/services/storage.service.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/services/storage.service.js
// DESCRIPTION: File-based storage service
// =====================================================

const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');

// Storage directory and file path
const STORAGE_DIR = path.join(__dirname, '../../data');
const STORAGE_FILE = path.join(STORAGE_DIR, 'db.json');

// Default data structure
const DEFAULT_DATA = {
    users: [],
    tasks: [],
};

class StorageService {
    constructor() {
        this.data = null;
        this.initialized = false;
    }

    /**
     * Initialize the storage service
     * Creates storage directory and file if they don't exist
     */
    async init() {
        if (this.initialized) return;

        try {
            // Create storage directory if it doesn't exist
            await fs.mkdir(STORAGE_DIR, { recursive: true });
            logger.debug(`Storage directory ready: ${STORAGE_DIR}`);

            // Check if storage file exists
            try {
                await fs.access(STORAGE_FILE);
                logger.debug(`Storage file found: ${STORAGE_FILE}`);
            } catch (error) {
                // File doesn't exist, create it with default data
                logger.info('Creating new storage file with default data');
                await this._writeData(DEFAULT_DATA);
            }

            // Load data into memory
            await this._loadData();
            this.initialized = true;
            logger.info(`Storage initialized: ${STORAGE_FILE}`);
        } catch (error) {
            logger.error('Failed to initialize storage:', error);
            throw error;
        }
    }

    /**
     * Load data from file into memory
     */
    async _loadData() {
        try {
            const fileContent = await fs.readFile(STORAGE_FILE, 'utf-8');
            this.data = JSON.parse(fileContent);
            logger.debug(`Data loaded: ${Object.keys(this.data).join(', ')}`);
        } catch (error) {
            logger.error('Failed to load data:', error);
            // If file is corrupted, reset to default
            this.data = { ...DEFAULT_DATA };
            await this._writeData(this.data);
        }
    }

    /**
     * Write data to file
     */
    async _writeData(data) {
        try {
            const content = JSON.stringify(data, null, 2);
            await fs.writeFile(STORAGE_FILE, content, 'utf-8');
            logger.debug('Data written to storage');
        } catch (error) {
            logger.error('Failed to write data:', error);
            throw error;
        }
    }

    /**
     * Save current data to file
     */
    async save() {
        if (!this.initialized) {
            await this.init();
        }
        await this._writeData(this.data);
    }

    /**
     * Get a collection (users, tasks, etc.)
     */
    getCollection(name) {
        if (!this.initialized) {
            throw new Error('Storage not initialized. Call init() first.');
        }
        if (!this.data[name]) {
            this.data[name] = [];
        }
        return this.data[name];
    }

    /**
     * Set a collection
     */
    setCollection(name, data) {
        if (!this.initialized) {
            throw new Error('Storage not initialized. Call init() first.');
        }
        this.data[name] = data;
    }

    /**
     * Find one item in a collection by ID
     */
    findById(collection, id) {
        const items = this.getCollection(collection);
        return items.find(item => item.id === id);
    }

    /**
     * Find items in a collection by a field
     */
    findByField(collection, field, value) {
        const items = this.getCollection(collection);
        return items.filter(item => item[field] === value);
    }

    /**
     * Create a new item in a collection
     */
    async create(collection, item) {
        const items = this.getCollection(collection);
        
        // Generate new ID
        const maxId = items.reduce((max, current) => {
            return current.id > max ? current.id : max;
        }, 0);
        
        const newItem = {
            ...item,
            id: maxId + 1,
            createdAt: new Date().toISOString(),
        };
        
        items.push(newItem);
        await this.save();
        return newItem;
    }

    /**
     * Update an item in a collection
     */
    async update(collection, id, updates) {
        const items = this.getCollection(collection);
        const index = items.findIndex(item => item.id === id);
        
        if (index === -1) {
            return null;
        }
        
        // Don't allow updating id or createdAt
        const { id: _, createdAt, ...allowedUpdates } = updates;
        items[index] = {
            ...items[index],
            ...allowedUpdates,
            updatedAt: new Date().toISOString(),
        };
        
        await this.save();
        return items[index];
    }

    /**
     * Delete an item from a collection
     */
    async delete(collection, id) {
        const items = this.getCollection(collection);
        const index = items.findIndex(item => item.id === id);
        
        if (index === -1) {
            return false;
        }
        
        items.splice(index, 1);
        await this.save();
        return true;
    }

    /**
     * Delete all items from a collection
     */
    async deleteAll(collection) {
        this.data[collection] = [];
        await this.save();
        return true;
    }

    /**
     * Get the count of items in a collection
     */
    count(collection) {
        const items = this.getCollection(collection);
        return items.length;
    }

    /**
     * Reset all data to default
     */
    async reset() {
        this.data = { ...DEFAULT_DATA };
        await this.save();
        logger.info('Data reset to default');
    }
}

// Export a singleton instance
module.exports = new StorageService();
```

### Step 2: Create the Data Directory

```bash
# Create the data directory
mkdir -p data
```

### Step 3: Update Models to Use Storage

Now let's update our models to use the storage service instead of in-memory arrays.

#### `src/models/user.model.js` (Updated)

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/models/user.model.js
// DESCRIPTION: User data model with file persistence
// =====================================================

const storage = require('../services/storage.service');
const logger = require('../utils/logger');

class UserModel {
    // Get all users
    static getAll() {
        try {
            const users = storage.getCollection('users');
            // Don't return passwords
            return users.map(({ password, ...user }) => user);
        } catch (error) {
            logger.error('Error getting users:', error);
            throw error;
        }
    }

    // Get user by ID
    static getById(id) {
        try {
            const user = storage.findById('users', id);
            if (!user) return null;
            // Don't return password
            const { password, ...safeUser } = user;
            return safeUser;
        } catch (error) {
            logger.error('Error getting user by ID:', error);
            throw error;
        }
    }

    // Get user by email (includes password for authentication)
    static getByEmail(email) {
        try {
            const users = storage.getCollection('users');
            return users.find(u => u.email === email);
        } catch (error) {
            logger.error('Error getting user by email:', error);
            throw error;
        }
    }

    // Create a new user
    static async create(userData) {
        try {
            const newUser = await storage.create('users', userData);
            // Return without password
            const { password, ...safeUser } = newUser;
            return safeUser;
        } catch (error) {
            logger.error('Error creating user:', error);
            throw error;
        }
    }

    // Update a user
    static async update(id, userData) {
        try {
            const updatedUser = await storage.update('users', id, userData);
            if (!updatedUser) return null;
            // Return without password
            const { password, ...safeUser } = updatedUser;
            return safeUser;
        } catch (error) {
            logger.error('Error updating user:', error);
            throw error;
        }
    }

    // Delete a user
    static async delete(id) {
        try {
            return await storage.delete('users', id);
        } catch (error) {
            logger.error('Error deleting user:', error);
            throw error;
        }
    }

    // Get all users with their tasks
    static async getUsersWithTasks() {
        try {
            const users = this.getAll();
            const tasks = storage.getCollection('tasks');
            
            return users.map(user => ({
                ...user,
                tasks: tasks.filter(task => task.userId === user.id)
            }));
        } catch (error) {
            logger.error('Error getting users with tasks:', error);
            throw error;
        }
    }

    // Reset data (for testing)
    static async reset() {
        await storage.reset();
    }
}

module.exports = UserModel;
```

#### `src/models/task.model.js` (Updated)

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/models/task.model.js
// DESCRIPTION: Task data model with file persistence
// =====================================================

const storage = require('../services/storage.service');
const logger = require('../utils/logger');

class TaskModel {
    // Get all tasks with optional filters
    static getAll(filters = {}) {
        try {
            let tasks = storage.getCollection('tasks');

            // Filter by userId
            if (filters.userId) {
                tasks = tasks.filter(t => t.userId === parseInt(filters.userId));
            }

            // Filter by completed status
            if (filters.completed !== undefined) {
                const completed = filters.completed === 'true';
                tasks = tasks.filter(t => t.completed === completed);
            }

            // Filter by priority
            if (filters.priority) {
                tasks = tasks.filter(t => t.priority === filters.priority);
            }

            // Sort by createdAt (newest first)
            if (filters.sort === 'newest') {
                tasks.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
            } else if (filters.sort === 'oldest') {
                tasks.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
            }

            return tasks;
        } catch (error) {
            logger.error('Error getting tasks:', error);
            throw error;
        }
    }

    // Get a single task
    static getById(id) {
        try {
            return storage.findById('tasks', id);
        } catch (error) {
            logger.error('Error getting task by ID:', error);
            throw error;
        }
    }

    // Get tasks for a user
    static getByUserId(userId) {
        try {
            const tasks = storage.getCollection('tasks');
            return tasks.filter(t => t.userId === userId);
        } catch (error) {
            logger.error('Error getting tasks by user:', error);
            throw error;
        }
    }

    // Create a new task
    static async create(taskData) {
        try {
            // Validate user exists
            const users = storage.getCollection('users');
            const userExists = users.some(u => u.id === taskData.userId);
            if (!userExists) {
                throw new Error(`User with ID ${taskData.userId} not found`);
            }

            return await storage.create('tasks', taskData);
        } catch (error) {
            logger.error('Error creating task:', error);
            throw error;
        }
    }

    // Update a task
    static async update(id, taskData) {
        try {
            return await storage.update('tasks', id, taskData);
        } catch (error) {
            logger.error('Error updating task:', error);
            throw error;
        }
    }

    // Delete a task
    static async delete(id) {
        try {
            return await storage.delete('tasks', id);
        } catch (error) {
            logger.error('Error deleting task:', error);
            throw error;
        }
    }

    // Delete all tasks for a user
    static async deleteByUserId(userId) {
        try {
            const tasks = storage.getCollection('tasks');
            const userTasks = tasks.filter(t => t.userId === userId);
            
            // Remove tasks for this user
            const remainingTasks = tasks.filter(t => t.userId !== userId);
            storage.setCollection('tasks', remainingTasks);
            await storage.save();
            
            return userTasks.length;
        } catch (error) {
            logger.error('Error deleting tasks by user:', error);
            throw error;
        }
    }

    // Get task statistics
    static getStats() {
        try {
            const tasks = storage.getCollection('tasks');
            
            return {
                total: tasks.length,
                completed: tasks.filter(t => t.completed).length,
                pending: tasks.filter(t => !t.completed).length,
                byPriority: {
                    high: tasks.filter(t => t.priority === 'high').length,
                    medium: tasks.filter(t => t.priority === 'medium').length,
                    low: tasks.filter(t => t.priority === 'low').length,
                }
            };
        } catch (error) {
            logger.error('Error getting task stats:', error);
            throw error;
        }
    }

    // Reset data (for testing)
    static async reset() {
        await storage.reset();
    }
}

module.exports = TaskModel;
```

### Step 4: Update Controllers for Async Operations

Now we need to update our controllers to handle async operations.

#### `src/controllers/user.controller.js` (Updated)

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/controllers/user.controller.js
// DESCRIPTION: User controller with async operations
// =====================================================

const UserModel = require('../models/user.model');
const logger = require('../utils/logger');
const { AppError } = require('../middleware/error');

class UserController {
    // Get all users
    async getAllUsers(req, res, next) {
        try {
            const users = UserModel.getAll();
            logger.debug(`Returning ${users.length} users`);
            
            res.json({
                success: true,
                count: users.length,
                data: users,
            });
        } catch (error) {
            next(error);
        }
    }

    // Get a single user
    async getUserById(req, res, next) {
        try {
            const { id } = req.params;
            const user = UserModel.getById(id);

            if (!user) {
                throw new AppError(`User with ID ${id} not found`, 404);
            }

            res.json({
                success: true,
                data: user,
            });
        } catch (error) {
            next(error);
        }
    }

    // Create a new user
    async createUser(req, res, next) {
        try {
            const userData = req.body;

            // Check if email already exists
            const existingUser = UserModel.getByEmail(userData.email);
            if (existingUser) {
                throw new AppError('Email already registered', 409);
            }

            const newUser = await UserModel.create(userData);
            logger.info(`User created: ${newUser.email}`);

            res.status(201).json({
                success: true,
                message: 'User created successfully',
                data: newUser,
            });
        } catch (error) {
            next(error);
        }
    }

    // Update a user
    async updateUser(req, res, next) {
        try {
            const { id } = req.params;
            const userData = req.body;

            // Check if user exists
            const existingUser = UserModel.getById(id);
            if (!existingUser) {
                throw new AppError(`User with ID ${id} not found`, 404);
            }

            const updatedUser = await UserModel.update(id, userData);
            logger.info(`User updated: ${updatedUser.email}`);

            res.json({
                success: true,
                message: 'User updated successfully',
                data: updatedUser,
            });
        } catch (error) {
            next(error);
        }
    }

    // Delete a user
    async deleteUser(req, res, next) {
        try {
            const { id } = req.params;

            // Check if user exists
            const existingUser = UserModel.getById(id);
            if (!existingUser) {
                throw new AppError(`User with ID ${id} not found`, 404);
            }

            // Also delete user's tasks
            const TaskModel = require('../models/task.model');
            const deletedTasks = await TaskModel.deleteByUserId(id);

            const deleted = await UserModel.delete(id);
            if (!deleted) {
                throw new AppError('Failed to delete user', 500);
            }

            logger.info(`User deleted: ${existingUser.email} (${deletedTasks} tasks deleted)`);
            res.json({
                success: true,
                message: `User ${id} deleted successfully`,
                data: {
                    user: existingUser,
                    deletedTasks: deletedTasks,
                },
            });
        } catch (error) {
            next(error);
        }
    }

    // Get users with their tasks
    async getUsersWithTasks(req, res, next) {
        try {
            const users = await UserModel.getUsersWithTasks();
            
            res.json({
                success: true,
                count: users.length,
                data: users,
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new UserController();
```

#### `src/controllers/task.controller.js` (Updated)

```javascript
// =====================================================
// FILE: /node-express-tutorial/src/controllers/task.controller.js
// DESCRIPTION: Task controller with async operations
// =====================================================

const TaskModel = require('../models/task.model');
const UserModel = require('../models/user.model');
const logger = require('../utils/logger');
const { AppError } = require('../middleware/error');

class TaskController {
    // Get all tasks with filters
    async getTasks(req, res, next) {
        try {
            const filters = req.query;
            
            // If filtering by userId, check if user exists
            if (filters.userId) {
                const user = UserModel.getById(parseInt(filters.userId));
                if (!user) {
                    throw new AppError(`User with ID ${filters.userId} not found`, 404);
                }
            }

            const tasks = TaskModel.getAll(filters);

            res.json({
                success: true,
                count: tasks.length,
                data: tasks,
            });
        } catch (error) {
            next(error);
        }
    }

    // Get a single task
    async getTaskById(req, res, next) {
        try {
            const { id } = req.params;
            const task = TaskModel.getById(id);

            if (!task) {
                throw new AppError(`Task with ID ${id} not found`, 404);
            }

            // Check if user exists
            const user = UserModel.getById(task.userId);
            if (!user) {
                // Clean up orphaned task
                await TaskModel.delete(id);
                throw new AppError(`Task referenced user that no longer exists`, 404);
            }

            res.json({
                success: true,
                data: task,
            });
        } catch (error) {
            next(error);
        }
    }

    // Create a new task
    async createTask(req, res, next) {
        try {
            const taskData = req.body;

            // Check if user exists
            const user = UserModel.getById(taskData.userId);
            if (!user) {
                throw new AppError(`User with ID ${taskData.userId} not found`, 404);
            }

            const newTask = await TaskModel.create(taskData);
            logger.info(`Task created for user ${taskData.userId}: ${newTask.title}`);

            res.status(201).json({
                success: true,
                message: 'Task created successfully',
                data: newTask,
            });
        } catch (error) {
            next(error);
        }
    }

    // Update a task
    async updateTask(req, res, next) {
        try {
            const { id } = req.params;
            const taskData = req.body;

            // Check if task exists
            const existingTask = TaskModel.getById(id);
            if (!existingTask) {
                throw new AppError(`Task with ID ${id} not found`, 404);
            }

            // If updating userId, check if new user exists
            if (taskData.userId) {
                const user = UserModel.getById(taskData.userId);
                if (!user) {
                    throw new AppError(`User with ID ${taskData.userId} not found`, 404);
                }
            }

            const updatedTask = await TaskModel.update(id, taskData);
            logger.info(`Task updated: ${updatedTask.title}`);

            res.json({
                success: true,
                message: 'Task updated successfully',
                data: updatedTask,
            });
        } catch (error) {
            next(error);
        }
    }

    // Delete a task
    async deleteTask(req, res, next) {
        try {
            const { id } = req.params;

            // Check if task exists
            const existingTask = TaskModel.getById(id);
            if (!existingTask) {
                throw new AppError(`Task with ID ${id} not found`, 404);
            }

            const deleted = await TaskModel.delete(id);
            if (!deleted) {
                throw new AppError('Failed to delete task', 500);
            }

            logger.info(`Task deleted: ${existingTask.title}`);
            res.json({
                success: true,
                message: `Task ${id} deleted successfully`,
                data: existingTask,
            });
        } catch (error) {
            next(error);
        }
    }

    // Get tasks for a specific user
    async getUserTasks(req, res, next) {
        try {
            const { userId } = req.params;
            const id = parseInt(userId);

            // Check if user exists
            const user = UserModel.getById(id);
            if (!user) {
                throw new AppError(`User with ID ${userId} not found`, 404);
            }

            const tasks = TaskModel.getByUserId(id);
            res.json({
                success: true,
                count: tasks.length,
                data: tasks,
            });
        } catch (error) {
            next(error);
        }
    }

    // Get task statistics
    async getTaskStats(req, res, next) {
        try {
            const stats = TaskModel.getStats();
            res.json({
                success: true,
                data: stats,
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = new TaskController();
```

### Step 5: Update Routes

Add new routes for the additional endpoints.

#### `src/routes/task.routes.js` (Updated)

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

// GET /tasks/stats - Get task statistics
router.get('/stats', taskController.getTaskStats);

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

#### `src/routes/user.routes.js` (Updated)

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

// GET /users/with-tasks - Get users with their tasks
router.get('/with-tasks', userController.getUsersWithTasks);

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

### Step 6: Update app.js to Initialize Storage

Update `src/app.js` to initialize the storage service:

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
const storage = require('./services/storage.service');

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
        storage: storage.initialized ? 'ready' : 'initializing',
    });
});

// API welcome (same as before)
app.get('/', (req, res) => {
    // ... (same as before)
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

### Step 7: Update server.js to Initialize Storage

```javascript
// =====================================================
// FILE: /node-express-tutorial/server.js
// DESCRIPTION: Server entry point with storage initialization
// =====================================================

// Load environment variables first
require('dotenv').config();

const config = require('./config/config');
const app = require('./src/app');
const logger = require('./src/utils/logger');
const storage = require('./src/services/storage.service');

// =====================================================
// INITIALIZE STORAGE
// =====================================================

async function startServer() {
    try {
        // Initialize storage first
        await storage.init();
        logger.info('Storage initialized successfully');

        // Start the server
        const server = app.listen(config.port, () => {
            console.log(`===================================`);
            console.log(`✅ Server running!`);
            console.log(`📡 http://localhost:${config.port}`);
            console.log(`🔧 Environment: ${config.env}`);
            console.log(`💾 Storage: ${storage.data ? 'Loaded' : 'Not loaded'}`);
            console.log(`📊 Users: ${storage.count('users')}`);
            console.log(`📊 Tasks: ${storage.count('tasks')}`);
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

        return server;
    } catch (error) {
        logger.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}

// Start the server
startServer();

module.exports = app;
```

### Step 8: Install Additional Dependencies

```bash
npm install cors helmet
```

### Step 9: Run and Test

```bash
# Start the server with persistence
npm run dev
```

Now test the persistence:

```bash
# Create a user
curl -X POST http://localhost:3000/users \
  -H "x-api-key: secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"name":"Charlie","email":"charlie@example.com","password":"password123"}'

# Create a task
curl -X POST http://localhost:3000/tasks \
  -H "x-api-key: secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"userId":3,"title":"Test Persistence","description":"This should survive a restart","priority":"high"}'

# Check the data file
cat data/db.json

# Now restart the server (Ctrl+C, then npm run dev)

# Verify data persisted
curl -H "x-api-key: secret-key-123" http://localhost:3000/users
curl -H "x-api-key: secret-key-123" http://localhost:3000/tasks
```

---

## CRUD Operations Explained

CRUD stands for Create, Read, Update, Delete — the four basic operations for data management.

### Create (POST)

```javascript
// Creating a new user
POST /users
Body: { "name": "Alice", "email": "alice@example.com", "password": "secret" }

// Response
{
  "success": true,
  "message": "User created successfully",
  "data": {
    "id": 3,
    "name": "Alice",
    "email": "alice@example.com",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### Read (GET)

```javascript
// Get all users
GET /users

// Get a specific user
GET /users/1

// Get tasks for a user
GET /users/1/tasks

// Get tasks with filters
GET /tasks?userId=1&completed=false&priority=high
```

### Update (PUT)

```javascript
// Full update (replace entire resource)
PUT /users/1
Body: { "name": "Alice Updated", "email": "alice_new@example.com" }

// Partial update (PATCH)
PATCH /users/1
Body: { "name": "Alice Updated" }
```

### Delete (DELETE)

```javascript
// Delete a user
DELETE /users/1

// Response
{
  "success": true,
  "message": "User 1 deleted successfully"
}
```

---

## Data Validation Before Persistence

Always validate data before saving it:

```javascript
// In user.controller.js
async createUser(req, res, next) {
    try {
        const userData = req.body;
        
        // Validate required fields
        if (!userData.name || !userData.email || !userData.password) {
            throw new AppError('Name, email, and password are required', 400);
        }
        
        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(userData.email)) {
            throw new AppError('Invalid email format', 400);
        }
        
        // Validate password strength
        if (userData.password.length < 8) {
            throw new AppError('Password must be at least 8 characters', 400);
        }
        
        // ... create user
    } catch (error) {
        next(error);
    }
}
```

---

## Error Handling for File Operations

File operations can fail for many reasons. Always handle errors:

```javascript
// In storage.service.js
async _writeData(data) {
    try {
        const content = JSON.stringify(data, null, 2);
        await fs.writeFile(STORAGE_FILE, content, 'utf-8');
    } catch (error) {
        if (error.code === 'EACCES') {
            logger.error('Permission denied when writing to storage');
            throw new Error('Storage permission denied');
        } else if (error.code === 'ENOSPC') {
            logger.error('No space left on device');
            throw new Error('Storage full');
        } else {
            logger.error('Failed to write data:', error);
            throw new Error('Failed to save data');
        }
    }
}
```

---

## What We've Learned

In this part, we covered:

1. **What persistence is** — Storing data beyond program execution
2. **JSON file storage** — Using JSON files for simple persistence
3. **Storage service** — A service that handles file operations
4. **CRUD operations** — Create, Read, Update, Delete
5. **Async operations** — Using async/await for file operations
6. **Data validation** — Validating data before saving
7. **Error handling** — Handling file operation errors
8. **Data relationships** — Managing users and their tasks

---

## Practice Exercises

### Exercise 1: Add Search Functionality
Add a search feature to the task model that searches by title and description. Add a `/tasks/search?q=keyword` route.

### Exercise 2: Add Data Export
Add a route that exports all data as a JSON file. Create `/api/export` that returns a downloadable JSON file.

### Exercise 3: Add Data Import
Add a route that imports data from a JSON file. Create `/api/import` that accepts a JSON file and replaces the current data.

### Exercise 4: Add Pagination
Add pagination to the task list. Support `page` and `limit` query parameters. Return metadata about total pages and count.

---

## Summary

You now have a fully persistent Express application with:

- **File-based storage** — Data survives server restarts
- **CRUD operations** — Full Create, Read, Update, Delete functionality
- **Async operations** — Using async/await for file operations
- **Data validation** — Validating data before saving
- **Error handling** — Graceful handling of file errors
- **Data relationships** — Users and their tasks

**In Part 9**, we'll focus on error handling, validation, and safety. You'll learn how to build robust applications that handle errors gracefully and protect against common security vulnerabilities.

---

## Quick Reference: Storage Service

| Method | Description |
|--------|-------------|
| `init()` | Initialize storage |
| `getCollection(name)` | Get a collection |
| `setCollection(name, data)` | Set a collection |
| `findById(collection, id)` | Find by ID |
| `findByField(collection, field, value)` | Find by field |
| `create(collection, item)` | Create new item |
| `update(collection, id, updates)` | Update item |
| `delete(collection, id)` | Delete item |
| `deleteAll(collection)` | Delete all items |
| `count(collection)` | Count items |
| `save()` | Save to file |
| `reset()` | Reset data |
