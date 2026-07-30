# Phase 2, Part 3: Caching & Complete API

## Supercharging Performance with Redis

Now that we have a solid database foundation, it's time to add caching to make our system faster. Think of caching like a chef's mise en place - having frequently used ingredients prepped and ready to go dramatically speeds up service!

### 1. The Target

**What we're building:** Redis caching layer and complete task management API:
- Redis connection management with caching strategies
- Cache-aside pattern implementation
- Complete Task CRUD operations with HTTP endpoints
- Cache invalidation strategies
- Comprehensive end-to-end testing

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── cache/                      # NEW: Caching layer
│   │   │   │   ├── redis/
│   │   │   │   │   ├── connection.ts
│   │   │   │   │   ├── cache.service.ts
│   │   │   │   │   └── cache.strategies.ts
│   │   │   │   └── in-memory/
│   │   │   │       └── cache.service.ts
│   │   │   ├── persistence/
│   │   │   │   └── postgres/
│   │   │   │       ├── user.repository.ts
│   │   │   │       └── task.repository.ts
│   │   │   └── http/
│   │   │       ├── user.controller.ts
│   │   │       └── task.controller.ts      # NEW: Task controller
│   │   └── di/
│   │       └── container.ts (updated)
│   ├── core/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   └── application/
│   │       ├── commands/
│   │       │   ├── create-user.command.ts
│   │       │   ├── create-task.command.ts  # NEW
│   │       │   └── update-task.command.ts  # NEW
│   │       └── handlers/
│   │           ├── user.handlers.ts
│   │           └── task.handlers.ts        # NEW
│   └── server.ts
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/                                # NEW: End-to-end tests
│       ├── user-api.test.ts
│       └── task-api.test.ts
│
└── docker-compose.yml (updated)
```

### 2. The Concept: Caching Strategies

Think of caching like having a whiteboard in the kitchen:

**Cache-Aside Pattern (Lazy Loading):**
1. Check the whiteboard (cache) first
2. If not there, ask the chef (database)
3. Write it on the whiteboard for next time
4. Erase (invalidate) when the dish changes

```
┌─────────────┐    1. Check Cache     ┌─────────────┐
│             │──────────────────────▶│             │
│  API Layer  │                       │   Redis     │
│             │◀──────────────────────│   Cache     │
└─────────────┘    2. Cache Miss      └─────────────┘
       │                                      │
       │ 3. Query Database                     │
       ▼                                      │
┌─────────────┐                               │
│             │    4. Store in Cache           │
│ PostgreSQL  │───────────────────────────────┘
│  Database   │
└─────────────┘
```

**Cache Invalidation Strategies:**
- **Write-Through:** Update cache immediately when database changes
- **Write-Behind:** Update cache asynchronously
- **Cache-Aside (Lazy):** Update cache only when needed (we'll use this)

### 3. The Implementation

#### Step 1: Redis Dependencies

Update `packages/gateway/package.json`:

```json
{
  "dependencies": {
    "fastify": "^4.25.0",
    "dotenv": "^16.3.1",
    "pino": "^8.15.0",
    "pino-pretty": "^10.2.0",
    "zod": "^3.22.4",
    "pg": "^8.11.3",
    "pg-pool": "^3.6.1",
    "uuid": "^9.0.1",
    "ioredis": "^5.3.2"                // Redis client
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/pg": "^8.10.9",
    "@types/uuid": "^9.0.7",
    "@types/ioredis": "^5.3.0",
    "tsx": "^4.6.0",
    "typescript": "^5.3.0",
    "vitest": "^1.0.0",
    "supertest": "^6.3.3",              // For E2E testing
    "@types/supertest": "^6.0.2",
    "eslint": "^8.55.0",
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0"
  }
}
```

#### Step 2: Redis Connection Manager

**File:** `packages/gateway/src/infrastructure/adapters/cache/redis/connection.ts`

```typescript
import Redis from 'ioredis';
import { REDIS_URL, REDIS_MAX_RETRIES } from '../../../../config.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * Redis Connection Manager
 * 
 * Manages connection to Redis with:
 * - Connection pooling (built into ioredis)
 * - Retry logic
 * - Health checks
 * - Event monitoring
 * 
 * Redis in Hexagonal Architecture:
 * Acts as a cache adapter, providing fast read access
 * to frequently accessed data.
 */
export class RedisConnection {
  private client: Redis | null = null;
  private readonly logger = createChildLogger({ module: 'RedisConnection' });
  private isConnected = false;
  private connectionPromise: Promise<void> | null = null;

  /**
   * Connect to Redis
   */
  async connect(): Promise<void> {
    if (this.isConnected && this.client) {
      return;
    }

    if (this.connectionPromise) {
      return this.connectionPromise;
    }

    this.logger.info('Connecting to Redis...');

    this.connectionPromise = new Promise<void>((resolve, reject) => {
      try {
        // Create Redis client
        this.client = new Redis(REDIS_URL || 'redis://localhost:6379', {
          // Retry strategy - exponential backoff
          retryStrategy: (times: number) => {
            if (times > REDIS_MAX_RETRIES) {
              this.logger.error(`Redis connection failed after ${times} retries`);
              return null; // Stop retrying
            }
            const delay = Math.min(times * 100, 3000);
            this.logger.debug(`Redis retry ${times} in ${delay}ms`);
            return delay;
          },
          
          // Enable ready check
          enableReadyCheck: true,
          
          // Keep alive
          keepAlive: 30000,
          
          // Connection timeout
          connectTimeout: 10000,
          
          // Command timeout
          commandTimeout: 5000,
        });

        // Set up event handlers
        this.client.on('connect', () => {
          this.logger.info('Redis connection established');
        });

        this.client.on('ready', () => {
          this.isConnected = true;
          this.logger.info('✅ Redis ready');
          resolve();
        });

        this.client.on('error', (error) => {
          this.logger.error({ error }, 'Redis error');
          if (!this.isConnected) {
            reject(error);
          }
        });

        this.client.on('close', () => {
          this.isConnected = false;
          this.logger.warn('Redis connection closed');
        });

        this.client.on('reconnecting', () => {
          this.logger.debug('Redis reconnecting...');
        });

        // If Redis is already ready
        if (this.client.status === 'ready') {
          this.isConnected = true;
          resolve();
        }
      } catch (error) {
        this.logger.error({ error }, 'Failed to connect to Redis');
        reject(error);
      } finally {
        this.connectionPromise = null;
      }
    });

    return this.connectionPromise;
  }

  /**
   * Get the Redis client
   */
  getClient(): Redis {
    if (!this.client) {
      throw new Error('Redis client not initialized');
    }
    return this.client;
  }

  /**
   * Execute a Redis command
   */
  async execute<T>(
    operation: (client: Redis) => Promise<T>
  ): Promise<T> {
    if (!this.client) {
      throw new Error('Redis not connected');
    }

    try {
      return await operation(this.client);
    } catch (error) {
      this.logger.error({ error }, 'Redis command failed');
      throw error;
    }
  }

  /**
   * Health check
   */
  async healthCheck(): Promise<boolean> {
    try {
      if (!this.client) return false;
      await this.client.ping();
      return true;
    } catch (error) {
      this.logger.error({ error }, 'Redis health check failed');
      return false;
    }
  }

  /**
   * Close the Redis connection
   */
  async disconnect(): Promise<void> {
    if (!this.client) {
      return;
    }

    this.logger.info('Closing Redis connection...');
    
    try {
      await this.client.quit();
      this.isConnected = false;
      this.client = null;
      this.logger.info('✅ Redis connection closed');
    } catch (error) {
      this.logger.error({ error }, 'Error closing Redis connection');
      // Force close if quit fails
      if (this.client) {
        this.client.disconnect();
      }
      throw error;
    }
  }

  /**
   * Get connection status
   */
  getStatus(): string {
    return this.client?.status || 'disconnected';
  }
}

// Singleton instance
export const redisConnection = new RedisConnection();
```

#### Step 3: Cache Service

**File:** `packages/gateway/src/infrastructure/adapters/cache/redis/cache.service.ts`

```typescript
import { redisConnection } from './connection.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * Cache Service
 * 
 * Provides caching functionality with:
 * - TTL support
 * - JSON serialization/deserialization
 * - Cache-aside pattern implementation
 * - Batch operations
 * 
 * This service implements the cache port for the application.
 */
export class CacheService {
  private readonly logger = createChildLogger({ module: 'CacheService' });
  
  // Default TTL: 5 minutes
  private readonly defaultTTL = 300;

  /**
   * Get a value from cache
   * 
   * Returns null if the key doesn't exist
   */
  async get<T>(key: string): Promise<T | null> {
    try {
      const client = redisConnection.getClient();
      const value = await client.get(key);
      
      if (!value) {
        this.logger.debug({ key }, 'Cache miss');
        return null;
      }

      this.logger.debug({ key }, 'Cache hit');
      return JSON.parse(value) as T;
    } catch (error) {
      this.logger.error({ error, key }, 'Failed to get from cache');
      // Return null on error to fall back to database
      return null;
    }
  }

  /**
   * Set a value in cache
   */
  async set<T>(
    key: string,
    value: T,
    ttl: number = this.defaultTTL
  ): Promise<void> {
    try {
      const client = redisConnection.getClient();
      const serialized = JSON.stringify(value);
      
      if (ttl > 0) {
        await client.setex(key, ttl, serialized);
      } else {
        await client.set(key, serialized);
      }
      
      this.logger.debug({ key, ttl }, 'Cached value');
    } catch (error) {
      this.logger.error({ error, key }, 'Failed to set cache');
      // Don't throw - cache failures shouldn't break the app
    }
  }

  /**
   * Delete a value from cache
   */
  async delete(key: string): Promise<void> {
    try {
      const client = redisConnection.getClient();
      await client.del(key);
      this.logger.debug({ key }, 'Deleted from cache');
    } catch (error) {
      this.logger.error({ error, key }, 'Failed to delete from cache');
    }
  }

  /**
   * Delete multiple keys
   */
  async deleteMany(keys: string[]): Promise<void> {
    if (keys.length === 0) return;
    
    try {
      const client = redisConnection.getClient();
      await client.del(...keys);
      this.logger.debug({ keys }, 'Deleted multiple keys from cache');
    } catch (error) {
      this.logger.error({ error, keys }, 'Failed to delete multiple keys from cache');
    }
  }

  /**
   * Delete keys by pattern
   * 
   * Warning: This uses SCAN to avoid blocking, but can be slow for large datasets
   */
  async deleteByPattern(pattern: string): Promise<number> {
    let deletedCount = 0;
    
    try {
      const client = redisConnection.getClient();
      let cursor = '0';
      
      do {
        const [nextCursor, keys] = await client.scan(
          cursor,
          'MATCH',
          pattern,
          'COUNT',
          100
        );
        
        cursor = nextCursor;
        
        if (keys.length > 0) {
          await client.del(...keys);
          deletedCount += keys.length;
        }
      } while (cursor !== '0');
      
      this.logger.debug({ pattern, deletedCount }, 'Deleted keys by pattern');
      return deletedCount;
    } catch (error) {
      this.logger.error({ error, pattern }, 'Failed to delete keys by pattern');
      return deletedCount;
    }
  }

  /**
   * Get or set cache (cache-aside pattern)
   * 
   * This implements the cache-aside pattern:
   * 1. Check cache for the key
   * 2. If found, return the value
   * 3. If not found, call the fetch function
   * 4. Cache the result and return it
   */
  async getOrSet<T>(
    key: string,
    fetchFn: () => Promise<T>,
    ttl: number = this.defaultTTL
  ): Promise<T> {
    // Try to get from cache
    const cached = await this.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // Cache miss - fetch the data
    this.logger.debug({ key }, 'Cache miss - fetching data');
    const value = await fetchFn();
    
    // Cache the result (even if null/undefined)
    if (value !== null && value !== undefined) {
      await this.set(key, value, ttl);
    }
    
    return value;
  }

  /**
   * Check if a key exists in cache
   */
  async exists(key: string): Promise<boolean> {
    try {
      const client = redisConnection.getClient();
      const result = await client.exists(key);
      return result === 1;
    } catch (error) {
      this.logger.error({ error, key }, 'Failed to check cache existence');
      return false;
    }
  }

  /**
   * Get TTL for a key
   */
  async getTTL(key: string): Promise<number> {
    try {
      const client = redisConnection.getClient();
      return await client.ttl(key);
    } catch (error) {
      this.logger.error({ error, key }, 'Failed to get TTL');
      return -1;
    }
  }

  /**
   * Clear all cache (use with caution!)
   */
  async clear(): Promise<void> {
    this.logger.warn('Clearing entire cache');
    try {
      const client = redisConnection.getClient();
      await client.flushdb();
    } catch (error) {
      this.logger.error({ error }, 'Failed to clear cache');
    }
  }
}

// Singleton instance
export const cacheService = new CacheService();
```

#### Step 4: Cache Key Strategies

**File:** `packages/gateway/src/infrastructure/adapters/cache/redis/cache.strategies.ts`

```typescript
/**
 * Cache Key Strategies
 * 
 * Centralizes cache key generation to ensure consistency.
 * Following the principle of "write once, use everywhere",
 * these functions define how cache keys are structured.
 * 
 * Cache Key Patterns:
 * - Single entity: {prefix}:{entity}:{id}
 * - Collection: {prefix}:{entity}:{collection}:{criteria}
 * - Relationship: {prefix}:{entity}:{id}:{relation}
 */
export class CacheKeys {
  /**
   * User cache keys
   */
  static user(id: string): string {
    return `user:${id}`;
  }

  static userByEmail(email: string): string {
    return `user:email:${email.toLowerCase()}`;
  }

  static userByUsername(username: string): string {
    return `user:username:${username.toLowerCase()}`;
  }

  static userTasks(userId: string): string {
    return `user:${userId}:tasks`;
  }

  /**
   * Task cache keys
   */
  static task(id: string): string {
    return `task:${id}`;
  }

  static userTasksByStatus(userId: string, status: string): string {
    return `user:${userId}:tasks:status:${status}`;
  }

  static userTasksByPriority(userId: string, priority: string): string {
    return `user:${userId}:tasks:priority:${priority}`;
  }

  /**
   * Invalidation patterns
   * 
   * Used to delete multiple related cache entries at once
   */
  static userPattern(userId: string): string {
    return `user:${userId}:*`;
  }

  static userTasksPattern(userId: string): string {
    return `user:${userId}:tasks:*`;
  }

  /**
   * Get all keys for a user (for invalidation)
   */
  static getUserKeys(userId: string): string[] {
    return [
      this.user(userId),
      this.userByEmail('*'), // Can't predict email without lookup
      this.userByUsername('*'), // Can't predict username without lookup
      this.userTasks(userId),
    ];
  }

  /**
   * Get all keys for a task
   */
  static getTaskKeys(taskId: string): string[] {
    return [this.task(taskId)];
  }

  /**
   * Generate a cache key with parameters
   */
  static generate(prefix: string, ...parts: (string | number)[]): string {
    return `${prefix}:${parts.join(':')}`;
  }

  /**
   * Format a key for display (redact sensitive parts)
   */
  static toDisplayKey(key: string): string {
    // Redact emails and usernames in logs
    return key.replace(/email:[^:]+/, 'email:***')
              .replace(/username:[^:]+/, 'username:***');
  }
}
```

#### Step 5: Task Command & Query

**File:** `packages/gateway/src/core/application/commands/create-task.command.ts`

```typescript
import { z } from 'zod';
import { TaskPriority } from '../../domain/entities/task.entity.js';

/**
 * Create Task Command
 * 
 * Command for creating a new task
 */
export class CreateTaskCommand {
  public readonly title: string;
  public readonly description: string;
  public readonly userId: string;
  public readonly priority: TaskPriority;
  public readonly dueDate?: Date;

  private constructor(props: {
    title: string;
    description: string;
    userId: string;
    priority: TaskPriority;
    dueDate?: Date;
  }) {
    this.title = props.title;
    this.description = props.description;
    this.userId = props.userId;
    this.priority = props.priority;
    this.dueDate = props.dueDate;
  }

  static create(data: unknown): CreateTaskCommand {
    const schema = z.object({
      title: z.string()
        .min(3, 'Title must be at least 3 characters')
        .max(255, 'Title must be at most 255 characters'),
      
      description: z.string()
        .min(10, 'Description must be at least 10 characters')
        .max(5000, 'Description is too long'),
      
      userId: z.string()
        .uuid('Invalid user ID format'),
      
      priority: z.enum(['low', 'medium', 'high', 'critical'])
        .default('medium'),
      
      dueDate: z.coerce.date()
        .optional()
        .refine(
          (date) => !date || date > new Date(),
          'Due date must be in the future'
        ),
    });

    const validated = schema.parse(data);
    
    return new CreateTaskCommand({
      title: validated.title,
      description: validated.description,
      userId: validated.userId,
      priority: validated.priority,
      dueDate: validated.dueDate,
    });
  }

  toObject() {
    return {
      title: this.title,
      description: this.description,
      userId: this.userId,
      priority: this.priority,
      dueDate: this.dueDate,
    };
  }
}
```

**File:** `packages/gateway/src/core/application/commands/update-task.command.ts`

```typescript
import { z } from 'zod';
import { TaskStatus, TaskPriority } from '../../domain/entities/task.entity.js';

/**
 * Update Task Command
 * 
 * Command for updating an existing task
 * All fields are optional - only provided fields will be updated
 */
export class UpdateTaskCommand {
  public readonly taskId: string;
  public readonly userId: string;
  public readonly title?: string;
  public readonly description?: string;
  public readonly status?: TaskStatus;
  public readonly priority?: TaskPriority;
  public readonly dueDate?: Date;

  private constructor(props: {
    taskId: string;
    userId: string;
    title?: string;
    description?: string;
    status?: TaskStatus;
    priority?: TaskPriority;
    dueDate?: Date;
  }) {
    this.taskId = props.taskId;
    this.userId = props.userId;
    this.title = props.title;
    this.description = props.description;
    this.status = props.status;
    this.priority = props.priority;
    this.dueDate = props.dueDate;
  }

  static create(data: unknown): UpdateTaskCommand {
    const schema = z.object({
      taskId: z.string()
        .uuid('Invalid task ID format'),
      
      userId: z.string()
        .uuid('Invalid user ID format'),
      
      title: z.string()
        .min(3, 'Title must be at least 3 characters')
        .max(255, 'Title must be at most 255 characters')
        .optional(),
      
      description: z.string()
        .min(10, 'Description must be at least 10 characters')
        .max(5000, 'Description is too long')
        .optional(),
      
      status: z.enum(['pending', 'in_progress', 'completed', 'failed', 'cancelled'])
        .optional(),
      
      priority: z.enum(['low', 'medium', 'high', 'critical'])
        .optional(),
      
      dueDate: z.coerce.date()
        .optional()
        .refine(
          (date) => !date || date > new Date(),
          'Due date must be in the future'
        ),
    });

    const validated = schema.parse(data);
    
    return new UpdateTaskCommand({
      taskId: validated.taskId,
      userId: validated.userId,
      title: validated.title,
      description: validated.description,
      status: validated.status,
      priority: validated.priority,
      dueDate: validated.dueDate,
    });
  }

  toObject() {
    return {
      taskId: this.taskId,
      userId: this.userId,
      title: this.title,
      description: this.description,
      status: this.status,
      priority: this.priority,
      dueDate: this.dueDate,
    };
  }
}
```

#### Step 6: Task Handlers with Caching

**File:** `packages/gateway/src/core/application/handlers/task.handlers.ts`

```typescript
import { Task } from '../../domain/entities/task.entity.js';
import { TaskDomainService } from '../../domain/services/task.service.js';
import { TaskStatus, TaskPriority } from '../../domain/entities/task.entity.js';
import { CreateTaskCommand } from '../commands/create-task.command.js';
import { UpdateTaskCommand } from '../commands/update-task.command.js';
import { cacheService } from '../../../infrastructure/adapters/cache/redis/cache.service.js';
import { CacheKeys } from '../../../infrastructure/adapters/cache/redis/cache.strategies.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Task Command Handler
 * 
 * Handles write operations for tasks with cache invalidation
 */
export class TaskCommandHandler {
  private readonly logger = createChildLogger({ module: 'TaskCommandHandler' });

  constructor(private readonly taskService: TaskDomainService) {}

  /**
   * Handle CreateTaskCommand
   */
  async handleCreateTask(command: CreateTaskCommand): Promise<Task> {
    this.logger.info({ command }, 'Handling CreateTaskCommand');
    
    const task = await this.taskService.createTask(command.toObject());
    
    // Invalidate user's task cache
    await this.invalidateUserTaskCache(task.userId);
    
    this.logger.info({ taskId: task.id }, 'Task created successfully');
    return task;
  }

  /**
   * Start a task
   */
  async handleStartTask(taskId: string, userId: string): Promise<Task> {
    this.logger.info({ taskId, userId }, 'Handling start task');
    
    const task = await this.taskService.startTask(taskId, userId);
    
    // Invalidate caches
    await this.invalidateTaskCache(taskId, userId);
    
    return task;
  }

  /**
   * Complete a task
   */
  async handleCompleteTask(taskId: string, userId: string): Promise<Task> {
    this.logger.info({ taskId, userId }, 'Handling complete task');
    
    const task = await this.taskService.completeTask(taskId, userId);
    
    // Invalidate caches
    await this.invalidateTaskCache(taskId, userId);
    
    return task;
  }

  /**
   * Fail a task
   */
  async handleFailTask(taskId: string, userId: string, reason?: string): Promise<Task> {
    this.logger.info({ taskId, userId, reason }, 'Handling fail task');
    
    const task = await this.taskService.failTask(taskId, userId, reason);
    
    // Invalidate caches
    await this.invalidateTaskCache(taskId, userId);
    
    return task;
  }

  /**
   * Cancel a task
   */
  async handleCancelTask(taskId: string, userId: string, reason?: string): Promise<Task> {
    this.logger.info({ taskId, userId, reason }, 'Handling cancel task');
    
    const task = await this.taskService.cancelTask(taskId, userId, reason);
    
    // Invalidate caches
    await this.invalidateTaskCache(taskId, userId);
    
    return task;
  }

  /**
   * Update a task
   */
  async handleUpdateTask(command: UpdateTaskCommand): Promise<Task> {
    this.logger.info({ command }, 'Handling UpdateTaskCommand');
    
    const { taskId, userId, title, description, status, priority, dueDate } = command.toObject();
    
    let task = await this.taskService.getTaskById(taskId, userId);
    
    // Apply updates
    if (title || description) {
      task = await this.taskService.updateTaskDetails(
        taskId,
        userId,
        title || task.title,
        description || task.description
      );
    }
    
    if (priority) {
      task = await this.taskService.updateTaskPriority(taskId, userId, priority);
    }
    
    if (dueDate) {
      task = await this.taskService.updateTaskDueDate(taskId, userId, dueDate);
    }
    
    if (status) {
      switch (status) {
        case TaskStatus.IN_PROGRESS:
          task = await this.taskService.startTask(taskId, userId);
          break;
        case TaskStatus.COMPLETED:
          task = await this.taskService.completeTask(taskId, userId);
          break;
        case TaskStatus.FAILED:
          task = await this.taskService.failTask(taskId, userId);
          break;
        case TaskStatus.CANCELLED:
          task = await this.taskService.cancelTask(taskId, userId);
          break;
        // PENDING doesn't need special handling
      }
    }
    
    // Invalidate caches
    await this.invalidateTaskCache(taskId, userId);
    
    return task;
  }

  /**
   * Delete a task
   */
  async handleDeleteTask(taskId: string, userId: string): Promise<boolean> {
    this.logger.info({ taskId, userId }, 'Handling delete task');
    
    const deleted = await this.taskService.deleteTask(taskId, userId);
    
    // Invalidate caches
    await this.invalidateTaskCache(taskId, userId);
    
    return deleted;
  }

  /**
   * Invalidate task caches
   */
  private async invalidateTaskCache(taskId: string, userId: string): Promise<void> {
    try {
      // Delete specific task cache
      await cacheService.delete(CacheKeys.task(taskId));
      
      // Delete user's task collections
      await cacheService.delete(CacheKeys.userTasks(userId));
      
      // Delete status-based collections (wildcard)
      await cacheService.deleteByPattern(
        CacheKeys.userTasksPattern(userId)
      );
      
      this.logger.debug({ taskId, userId }, 'Task cache invalidated');
    } catch (error) {
      this.logger.error({ error, taskId, userId }, 'Failed to invalidate cache');
      // Don't throw - cache invalidation shouldn't break the operation
    }
  }

  /**
   * Invalidate user's task cache
   */
  private async invalidateUserTaskCache(userId: string): Promise<void> {
    try {
      await cacheService.delete(CacheKeys.userTasks(userId));
      await cacheService.deleteByPattern(
        CacheKeys.userTasksPattern(userId)
      );
      this.logger.debug({ userId }, 'User task cache invalidated');
    } catch (error) {
      this.logger.error({ error, userId }, 'Failed to invalidate user task cache');
    }
  }
}

/**
 * Task Query Handler
 * 
 * Handles read operations for tasks with caching
 */
export class TaskQueryHandler {
  private readonly logger = createChildLogger({ module: 'TaskQueryHandler' });
  
  // Cache TTL: 5 minutes for tasks
  private readonly CACHE_TTL = 300;

  constructor(private readonly taskService: TaskDomainService) {}

  /**
   * Get a task by ID with caching
   */
  async handleGetTask(taskId: string, userId: string): Promise<Task | null> {
    this.logger.debug({ taskId, userId }, 'Handling GetTask');
    
    const cacheKey = CacheKeys.task(taskId);
    
    // Try cache first
    const cachedTask = await cacheService.get<Task>(cacheKey);
    if (cachedTask) {
      // Verify the task belongs to the user
      if (cachedTask.userId === userId) {
        this.logger.debug({ taskId }, 'Task cache hit');
        return cachedTask;
      }
      // If it doesn't belong, don't use the cache
      this.logger.debug({ taskId }, 'Task cache hit but belongs to different user');
    }
    
    // Cache miss or belongs to different user
    const task = await this.taskService.getTaskById(taskId, userId);
    
    if (task) {
      // Cache the task
      await cacheService.set(cacheKey, task, this.CACHE_TTL);
    }
    
    return task;
  }

  /**
   * Get all tasks for a user with caching
   */
  async handleGetUserTasks(userId: string): Promise<Task[]> {
    this.logger.debug({ userId }, 'Handling GetUserTasks');
    
    const cacheKey = CacheKeys.userTasks(userId);
    
    // Try cache first
    const cachedTasks = await cacheService.get<Task[]>(cacheKey);
    if (cachedTasks) {
      this.logger.debug({ userId }, 'User tasks cache hit');
      return cachedTasks;
    }
    
    // Cache miss
    const tasks = await this.taskService.getUserTasks(userId);
    
    // Cache the result
    await cacheService.set(cacheKey, tasks, this.CACHE_TTL);
    
    return tasks;
  }

  /**
   * Get tasks by status with caching
   */
  async handleGetTasksByStatus(
    userId: string,
    status: TaskStatus
  ): Promise<Task[]> {
    this.logger.debug({ userId, status }, 'Handling GetTasksByStatus');
    
    const cacheKey = CacheKeys.userTasksByStatus(userId, status);
    
    const cachedTasks = await cacheService.get<Task[]>(cacheKey);
    if (cachedTasks) {
      return cachedTasks;
    }
    
    const tasks = await this.taskService.getTasksByStatus(userId, status);
    
    await cacheService.set(cacheKey, tasks, this.CACHE_TTL);
    
    return tasks;
  }

  /**
   * Get overdue tasks with caching
   */
  async handleGetOverdueTasks(userId: string): Promise<Task[]> {
    this.logger.debug({ userId }, 'Handling GetOverdueTasks');
    
    // Overdue tasks change frequently, use shorter cache TTL
    const cacheKey = CacheKeys.generate('tasks', userId, 'overdue');
    
    const cachedTasks = await cacheService.get<Task[]>(cacheKey);
    if (cachedTasks) {
      return cachedTasks;
    }
    
    const tasks = await this.taskService.getOverdueTasks(userId);
    
    // Shorter TTL for overdue tasks (1 minute)
    await cacheService.set(cacheKey, tasks, 60);
    
    return tasks;
  }
}
```

#### Step 7: Task Controller

**File:** `packages/gateway/src/infrastructure/adapters/http/task.controller.ts`

```typescript
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { TaskCommandHandler, TaskQueryHandler } from '../../../core/application/handlers/task.handlers.js';
import { CreateTaskCommand } from '../../../core/application/commands/create-task.command.js';
import { UpdateTaskCommand } from '../../../core/application/commands/update-task.command.js';
import { createChildLogger } from '../../../logger.js';
import { z } from 'zod';

/**
 * Task HTTP Controller
 * 
 * HTTP adapter for task management endpoints
 */
export class TaskController {
  private readonly logger = createChildLogger({ module: 'TaskController' });

  constructor(
    private readonly commandHandler: TaskCommandHandler,
    private readonly queryHandler: TaskQueryHandler
  ) {}

  registerRoutes(server: FastifyInstance): void {
    server.post('/api/tasks', this.createTask.bind(this));
    server.get('/api/tasks/:taskId', this.getTask.bind(this));
    server.put('/api/tasks/:taskId', this.updateTask.bind(this));
    server.delete('/api/tasks/:taskId', this.deleteTask.bind(this));
    server.post('/api/tasks/:taskId/start', this.startTask.bind(this));
    server.post('/api/tasks/:taskId/complete', this.completeTask.bind(this));
    server.post('/api/tasks/:taskId/fail', this.failTask.bind(this));
    server.post('/api/tasks/:taskId/cancel', this.cancelTask.bind(this));
    server.get('/api/users/:userId/tasks', this.getUserTasks.bind(this));
    server.get('/api/users/:userId/tasks/overdue', this.getOverdueTasks.bind(this));
  }

  /**
   * POST /api/tasks - Create a new task
   */
  private async createTask(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    try {
      this.logger.debug({ body: request.body }, 'Creating task');
      
      const command = CreateTaskCommand.create(request.body);
      const task = await this.commandHandler.handleCreateTask(command);
      
      reply.code(201).send({
        success: true,
        data: task.toJSON(),
        message: 'Task created successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to create task');
      throw error;
    }
  }

  /**
   * GET /api/tasks/:taskId - Get a task by ID
   */
  private async getTask(
    request: FastifyRequest<{ Params: { taskId: string }, Querystring: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const { userId } = request.query;
      
      if (!userId) {
        reply.code(400).send({
          success: false,
          message: 'userId query parameter is required',
        });
        return;
      }
      
      const task = await this.queryHandler.handleGetTask(taskId, userId);
      
      if (!task) {
        reply.code(404).send({
          success: false,
          message: 'Task not found',
        });
        return;
      }
      
      reply.code(200).send({
        success: true,
        data: task.toJSON(),
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to get task');
      throw error;
    }
  }

  /**
   * PUT /api/tasks/:taskId - Update a task
   */
  private async updateTask(
    request: FastifyRequest<{ Params: { taskId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const body = request.body as any;
      
      const command = UpdateTaskCommand.create({
        ...body,
        taskId,
      });
      
      const task = await this.commandHandler.handleUpdateTask(command);
      
      reply.code(200).send({
        success: true,
        data: task.toJSON(),
        message: 'Task updated successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to update task');
      throw error;
    }
  }

  /**
   * DELETE /api/tasks/:taskId - Delete a task
   */
  private async deleteTask(
    request: FastifyRequest<{ Params: { taskId: string }, Querystring: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const { userId } = request.query;
      
      if (!userId) {
        reply.code(400).send({
          success: false,
          message: 'userId query parameter is required',
        });
        return;
      }
      
      const deleted = await this.commandHandler.handleDeleteTask(taskId, userId);
      
      if (!deleted) {
        reply.code(404).send({
          success: false,
          message: 'Task not found',
        });
        return;
      }
      
      reply.code(200).send({
        success: true,
        message: 'Task deleted successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to delete task');
      throw error;
    }
  }

  /**
   * POST /api/tasks/:taskId/start - Start a task
   */
  private async startTask(
    request: FastifyRequest<{ Params: { taskId: string }, Body: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const { userId } = request.body;
      
      if (!userId) {
        reply.code(400).send({
          success: false,
          message: 'userId is required in request body',
        });
        return;
      }
      
      const task = await this.commandHandler.handleStartTask(taskId, userId);
      
      reply.code(200).send({
        success: true,
        data: task.toJSON(),
        message: 'Task started successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to start task');
      throw error;
    }
  }

  /**
   * POST /api/tasks/:taskId/complete - Complete a task
   */
  private async completeTask(
    request: FastifyRequest<{ Params: { taskId: string }, Body: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const { userId } = request.body;
      
      if (!userId) {
        reply.code(400).send({
          success: false,
          message: 'userId is required in request body',
        });
        return;
      }
      
      const task = await this.commandHandler.handleCompleteTask(taskId, userId);
      
      reply.code(200).send({
        success: true,
        data: task.toJSON(),
        message: 'Task completed successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to complete task');
      throw error;
    }
  }

  /**
   * POST /api/tasks/:taskId/fail - Fail a task
   */
  private async failTask(
    request: FastifyRequest<{ Params: { taskId: string }, Body: { userId: string; reason?: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const { userId, reason } = request.body;
      
      if (!userId) {
        reply.code(400).send({
          success: false,
          message: 'userId is required in request body',
        });
        return;
      }
      
      const task = await this.commandHandler.handleFailTask(taskId, userId, reason);
      
      reply.code(200).send({
        success: true,
        data: task.toJSON(),
        message: 'Task failed successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to fail task');
      throw error;
    }
  }

  /**
   * POST /api/tasks/:taskId/cancel - Cancel a task
   */
  private async cancelTask(
    request: FastifyRequest<{ Params: { taskId: string }, Body: { userId: string; reason?: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { taskId } = request.params;
      const { userId, reason } = request.body;
      
      if (!userId) {
        reply.code(400).send({
          success: false,
          message: 'userId is required in request body',
        });
        return;
      }
      
      const task = await this.commandHandler.handleCancelTask(taskId, userId, reason);
      
      reply.code(200).send({
        success: true,
        data: task.toJSON(),
        message: 'Task cancelled successfully',
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to cancel task');
      throw error;
    }
  }

  /**
   * GET /api/users/:userId/tasks - Get all tasks for a user
   */
  private async getUserTasks(
    request: FastifyRequest<{ Params: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { userId } = request.params;
      
      const tasks = await this.queryHandler.handleGetUserTasks(userId);
      
      reply.code(200).send({
        success: true,
        data: tasks.map(task => task.toJSON()),
        count: tasks.length,
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to get user tasks');
      throw error;
    }
  }

  /**
   * GET /api/users/:userId/tasks/overdue - Get overdue tasks for a user
   */
  private async getOverdueTasks(
    request: FastifyRequest<{ Params: { userId: string } }>,
    reply: FastifyReply
  ): Promise<void> {
    try {
      const { userId } = request.params;
      
      const tasks = await this.queryHandler.handleGetOverdueTasks(userId);
      
      reply.code(200).send({
        success: true,
        data: tasks.map(task => task.toJSON()),
        count: tasks.length,
      });
    } catch (error) {
      this.logger.error({ error }, 'Failed to get overdue tasks');
      throw error;
    }
  }
}
```

#### Step 8: Update DI Container

**File:** `packages/gateway/src/infrastructure/di/container.ts` (Updated)

```typescript
import { UserDomainService } from '../../core/domain/services/user.service.js';
import { TaskDomainService } from '../../core/domain/services/task.service.js';
import { UserCommandHandler, UserQueryHandler } from '../../core/application/handlers/user.handlers.js';
import { TaskCommandHandler, TaskQueryHandler } from '../../core/application/handlers/task.handlers.js';
import { UserController } from '../adapters/http/user.controller.js';
import { TaskController } from '../adapters/http/task.controller.js';
import { IUserRepository, USER_REPOSITORY } from '../../core/domain/repositories/user.repository.port.js';
import { ITaskRepository, TASK_REPOSITORY } from '../../core/domain/repositories/task.repository.port.js';
import { InMemoryUserRepository } from '../adapters/persistence/in-memory/user.repository.js';
import { InMemoryTaskRepository } from '../adapters/persistence/in-memory/task.repository.js';
import { PostgresUserRepository } from '../adapters/persistence/postgres/user.repository.js';
import { PostgresTaskRepository } from '../adapters/persistence/postgres/task.repository.js';
import { postgresConnection } from '../adapters/persistence/postgres/connection.js';
import { redisConnection } from '../adapters/cache/redis/connection.js';
import { NODE_ENV, IS_TEST } from '../../config.js';
import { createChildLogger } from '../../logger.js';

export class Container {
  private static instance: Container;
  
  private userRepository!: IUserRepository;
  private taskRepository!: ITaskRepository;
  private userDomainService!: UserDomainService;
  private taskDomainService!: TaskDomainService;
  private userCommandHandler!: UserCommandHandler;
  private userQueryHandler!: UserQueryHandler;
  private taskCommandHandler!: TaskCommandHandler;
  private taskQueryHandler!: TaskQueryHandler;
  private userController!: UserController;
  private taskController!: TaskController;

  private constructor() {
    this.build();
  }

  static getInstance(): Container {
    if (!Container.instance) {
      Container.instance = new Container();
    }
    return Container.instance;
  }

  private build(): void {
    const usePostgres = NODE_ENV !== 'test';
    
    this.logger.info(`Using ${usePostgres ? 'PostgreSQL' : 'In-Memory'} repositories`);

    // Connect to Redis (if not in test mode)
    if (!IS_TEST) {
      redisConnection.connect().catch((error) => {
        this.logger.warn({ error }, 'Failed to connect to Redis - continuing without cache');
      });
    }

    // Repositories
    if (usePostgres) {
      postgresConnection.connect().catch((error) => {
        this.logger.error({ error }, 'Failed to connect to PostgreSQL');
        if (NODE_ENV === 'development') {
          this.logger.warn('Falling back to in-memory repositories');
          this.userRepository = new InMemoryUserRepository();
          this.taskRepository = new InMemoryTaskRepository();
          return;
        }
        throw error;
      });
      
      this.userRepository = new PostgresUserRepository();
      this.taskRepository = new PostgresTaskRepository();
    } else {
      this.userRepository = new InMemoryUserRepository();
      this.taskRepository = new InMemoryTaskRepository();
    }

    // Domain Services
    this.userDomainService = new UserDomainService(this.userRepository);
    this.taskDomainService = new TaskDomainService(this.taskRepository, this.userRepository);

    // Application Handlers
    this.userCommandHandler = new UserCommandHandler(this.userDomainService);
    this.userQueryHandler = new UserQueryHandler(this.userDomainService);
    this.taskCommandHandler = new TaskCommandHandler(this.taskDomainService);
    this.taskQueryHandler = new TaskQueryHandler(this.taskDomainService);

    // HTTP Controllers
    this.userController = new UserController(
      this.userCommandHandler,
      this.userQueryHandler
    );
    this.taskController = new TaskController(
      this.taskCommandHandler,
      this.taskQueryHandler
    );
  }

  get<T>(token: symbol): T {
    switch (token) {
      case USER_REPOSITORY:
        return this.userRepository as T;
      case TASK_REPOSITORY:
        return this.taskRepository as T;
      default:
        throw new Error(`No dependency found for token: ${token.toString()}`);
    }
  }

  getUserController(): UserController {
    return this.userController;
  }

  getTaskController(): TaskController {
    return this.taskController;
  }

  getUserCommandHandler(): UserCommandHandler {
    return this.userCommandHandler;
  }

  getUserQueryHandler(): UserQueryHandler {
    return this.userQueryHandler;
  }

  getTaskCommandHandler(): TaskCommandHandler {
    return this.taskCommandHandler;
  }

  getTaskQueryHandler(): TaskQueryHandler {
    return this.taskQueryHandler;
  }

  reset(): void {
    if (this.userRepository instanceof InMemoryUserRepository) {
      this.userRepository.clear();
    }
    if (this.taskRepository instanceof InMemoryTaskRepository) {
      this.taskRepository.clear();
    }
  }

  private get logger() {
    return createChildLogger({ module: 'Container' });
  }
}
```

#### Step 9: Update Server

**File:** `packages/gateway/src/server.ts` (Add to setupControllers)

```typescript
// In setupControllers method, add:
const taskController = container.getTaskController();
taskController.registerRoutes(this.app);
```

#### Step 10: E2E Tests

**File:** `packages/gateway/tests/e2e/task-api.test.ts`

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { Server } from '../../src/server.js';
import { postgresConnection } from '../../src/infrastructure/adapters/persistence/postgres/connection.js';
import { redisConnection } from '../../src/infrastructure/adapters/cache/redis/connection.js';

describe('Task API E2E Tests', () => {
  let server: Server;
  let app: any;
  let userId: string;
  let taskId: string;

  beforeAll(async () => {
    // Start the server
    server = new Server();
    app = server.getApp();
    await server.start();

    // Create a test user
    const userResponse = await request(app)
      .post('/api/users')
      .send({
        email: 'task-test@example.com',
        username: 'tasktest',
        password: 'SecurePass123',
        firstName: 'Task',
        lastName: 'Tester',
      });
    
    userId = userResponse.body.data.id;
  });

  afterAll(async () => {
    // Clean up
    await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
    await postgresConnection.disconnect();
    await redisConnection.disconnect();
  });

  it('should create a task', async () => {
    const response = await request(app)
      .post('/api/tasks')
      .send({
        title: 'Test Task',
        description: 'This is a test task description',
        userId: userId,
        priority: 'high',
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.title).toBe('Test Task');
    expect(response.body.data.userId).toBe(userId);
    expect(response.body.data.status).toBe('pending');
    
    taskId = response.body.data.id;
  });

  it('should get a task by ID', async () => {
    const response = await request(app)
      .get(`/api/tasks/${taskId}`)
      .query({ userId });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.id).toBe(taskId);
    expect(response.body.data.title).toBe('Test Task');
  });

  it('should start a task', async () => {
    const response = await request(app)
      .post(`/api/tasks/${taskId}/start`)
      .send({ userId });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.status).toBe('in_progress');
  });

  it('should complete a task', async () => {
    const response = await request(app)
      .post(`/api/tasks/${taskId}/complete`)
      .send({ userId });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.status).toBe('completed');
    expect(response.body.data.completedAt).toBeDefined();
  });

  it('should get all tasks for a user', async () => {
    const response = await request(app)
      .get(`/api/users/${userId}/tasks`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.count).toBeGreaterThan(0);
    expect(response.body.data[0].userId).toBe(userId);
  });

  it('should handle validation errors', async () => {
    const response = await request(app)
      .post('/api/tasks')
      .send({
        title: 'T', // Too short
        description: 'Short', // Too short
        userId: 'invalid-uuid',
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toBe('Validation Error');
  });

  it('should handle not found errors', async () => {
    const response = await request(app)
      .get('/api/tasks/non-existent-id')
      .query({ userId });

    expect(response.status).toBe(404);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toBe('Task not found');
  });

  it('should delete a task', async () => {
    const response = await request(app)
      .delete(`/api/tasks/${taskId}`)
      .query({ userId });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.message).toBe('Task deleted successfully');

    // Verify it's deleted
    const getResponse = await request(app)
      .get(`/api/tasks/${taskId}`)
      .query({ userId });

    expect(getResponse.status).toBe(404);
  });
});
```

### 4. The Verification

#### Step 1: Start Services

```bash
# Start all services with Docker Compose
cd packages/gateway
docker-compose up -d

# Or start individually
docker-compose up -d postgres redis
npm run dev
```

#### Step 2: Test Task API Endpoints

**Create a user first:**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "taskuser@example.com",
    "username": "taskuser",
    "password": "SecurePass123",
    "firstName": "Task",
    "lastName": "User"
  }'
```

Save the `userId` from the response.

**Create a task:**
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Build the API",
    "description": "Complete the Hexagonal Architecture implementation",
    "userId": "YOUR_USER_ID",
    "priority": "high",
    "dueDate": "2024-12-31T23:59:59Z"
  }'
```

Expected response:
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Build the API",
    "description": "Complete the Hexagonal Architecture implementation",
    "userId": "YOUR_USER_ID",
    "status": "pending",
    "priority": "high",
    "dueDate": "2024-12-31T23:59:59.000Z",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "completedAt": null
  },
  "message": "Task created successfully"
}
```

**Start the task:**
```bash
curl -X POST http://localhost:3000/api/tasks/TASK_ID/start \
  -H "Content-Type: application/json" \
  -d '{"userId": "YOUR_USER_ID"}'
```

**Complete the task:**
```bash
curl -X POST http://localhost:3000/api/tasks/TASK_ID/complete \
  -H "Content-Type: application/json" \
  -d '{"userId": "YOUR_USER_ID"}'
```

**Get all tasks for user:**
```bash
curl http://localhost:3000/api/users/YOUR_USER_ID/tasks
```

Expected response:
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Build the API",
      "description": "Complete the Hexagonal Architecture implementation",
      "userId": "YOUR_USER_ID",
      "status": "completed",
      "priority": "high",
      "dueDate": "2024-12-31T23:59:59.000Z",
      "createdAt": "2024-01-15T10:30:50.123Z",
      "updatedAt": "2024-01-15T10:31:20.456Z",
      "completedAt": "2024-01-15T10:31:20.456Z"
    }
  ],
  "count": 1
}
```

#### Step 3: Verify Caching

Check Redis cache:

```bash
# Connect to Redis
docker exec -it orchestrator-gateway-redis-1 redis-cli

# Get task cache
GET task:TASK_ID

# Get user tasks cache
KEYS user:YOUR_USER_ID:*

# Check TTL
TTL task:TASK_ID
```

Expected: You should see cached data with a TTL of 300 seconds.

#### Step 4: Test Cache Invalidation

After completing a task, the cache should be invalidated. Try:

```bash
# Get task (should be cached)
curl http://localhost:3000/api/tasks/TASK_ID?userId=YOUR_USER_ID

# Complete the task again (should invalidate cache)
curl -X POST http://localhost:3000/api/tasks/TASK_ID/complete \
  -H "Content-Type: application/json" \
  -d '{"userId": "YOUR_USER_ID"}'

# Get task again (should fetch fresh data)
curl http://localhost:3000/api/tasks/TASK_ID?userId=YOUR_USER_ID
```

#### Step 5: Run E2E Tests

```bash
npm test tests/e2e/
```

Expected output:
```
✓ Task API E2E Tests (9 tests) 845ms
```

### 5. Deep Dive: Caching Patterns & Redis

#### Cache-Aside Pattern Implementation

The cache-aside pattern we implemented:

```typescript
async getOrSet<T>(key: string, fetchFn: () => Promise<T>): Promise<T> {
  // 1. Check cache
  const cached = await this.get<T>(key);
  if (cached !== null) return cached;
  
  // 2. Cache miss - fetch from database
  const value = await fetchFn();
  
  // 3. Store in cache
  await this.set(key, value);
  
  return value;
}
```

**When to Use:**
- Read-heavy workloads
- Data that changes infrequently
- When you can accept eventual consistency

**When NOT to Use:**
- Write-heavy workloads
- Data that changes frequently
- When strong consistency is required

#### Cache Invalidation Strategies

**1. Time-Based Invalidation (TTL):**
```typescript
await cacheService.set(key, value, 300); // 5 minutes
```

**2. Event-Based Invalidation:**
```typescript
// When data changes
await cacheService.delete(CacheKeys.task(taskId));
await cacheService.deleteByPattern(CacheKeys.userTasksPattern(userId));
```

**3. Version-Based Invalidation:**
```typescript
// Include version in cache key
const key = `task:${taskId}:v${version}`;
```

#### Redis Data Structures

Redis offers more than just key-value storage:

**Strings:** Simple key-value
```redis
SET user:123 '{"name":"John"}'
GET user:123
```

**Hashes:** Like JavaScript objects
```redis
HSET user:123 name "John" email "john@example.com"
HGET user:123 name
```

**Lists:** Ordered collections
```redis
LPUSH tasks:user:123 "Task 1" "Task 2"
LRANGE tasks:user:123 0 -1
```

**Sets:** Unordered unique values
```redis
SADD tags:task:456 "important" "urgent"
SMEMBERS tags:task:456
```

**Sorted Sets:** Ordered unique values with scores
```redis
ZADD tasks:by:due 1704067200 "Task 1"
ZRANGE tasks:by:due 0 -1
```

### 6. Summary

**What We Built:**
- ✅ Redis connection manager with retry logic
- ✅ Cache service with cache-aside pattern
- ✅ Cache key strategies for consistency
- ✅ Complete Task CRUD operations
- ✅ Task command and query handlers
- ✅ HTTP task controller with all endpoints
- ✅ Cache invalidation on data changes
- ✅ Comprehensive E2E tests

**Key Concepts Learned:**
- Cache-aside pattern implementation
- Cache invalidation strategies
- Redis connection management
- Command-Query Responsibility Segregation (CQRS)
- End-to-end testing with supertest
- Cache key design patterns

**What's Next:**
In Phase 3, we'll move to distributed systems - translating local async patterns to distributed coordination, implementing sagas, circuit breakers, and request cancellation propagation.

**Verification Checklist:**
- [ ] Redis connection works
- [ ] Cache service stores and retrieves data
- [ ] Task creation works with validation
- [ ] Task status transitions work (start → complete)
- [ ] User tasks query returns correct data
- [ ] Cache invalidation works on updates
- [ ] E2E tests pass
- [ ] All validation errors are handled

