# Phase 2, Part 2: PostgreSQL Integration & Testing

## Connecting Your Architecture to Reality

Now that we have a solid architectural foundation, it's time to connect it to a real database. Think of this like finally plumbing your beautifully designed kitchen - all the planning is worthless until water actually flows through the pipes!

### 1. The Target

**What we're building:** PostgreSQL integration for our Hexagonal Architecture:
- PostgreSQL repository implementations for User and Task entities
- Database migrations for schema management
- Connection pooling and error handling
- Integration tests that verify our architecture works with a real database
- Seamless swapping between in-memory (development) and PostgreSQL (production) repositories

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── persistence/
│   │   │   │   ├── postgres/              # NEW: PostgreSQL implementation
│   │   │   │   │   ├── user.repository.ts
│   │   │   │   │   ├── task.repository.ts
│   │   │   │   │   ├── connection.ts
│   │   │   │   │   └── migrations/        # NEW: Database migrations
│   │   │   │   │       ├── 001_initial_schema.sql
│   │   │   │   │       └── 002_add_indexes.sql
│   │   │   │   └── in-memory/
│   │   │   │       ├── user.repository.ts
│   │   │   │       └── task.repository.ts
│   │   │   └── http/
│   │   └── di/
│   │       └── container.ts (updated)
│   └── server.ts
│
├── tests/
│   ├── unit/
│   ├── integration/                       # NEW: Integration tests
│   │   ├── user.repository.test.ts
│   │   ├── task.repository.test.ts
│   │   └── setup.ts
│   └── e2e/
│
├── docker-compose.yml
├── Dockerfile
└── .env.example (updated)
```

### 2. The Concept: Database Persistence in Hexagonal Architecture

Think of your database as a specialized storage facility. The Hexagonal Architecture pattern treats it as just another adapter:

```
┌─────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                         │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  IUserRepository (Port)                            │    │
│  │  - save(user): Promise<User>                       │    │
│  │  - findById(id): Promise<User | null>             │    │
│  │  - findByEmail(email): Promise<User | null>       │    │
│  └─────────────────────────────────────────────────────┘    │
│                        ▲                                     │
│                        │                                     │
│                        │ (Implements)                        │
│                        │                                     │
├────────────────────────┼─────────────────────────────────────┤
│                        │                                     │
│      INFRASTRUCTURE LAYER                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  PostgreSQLUserRepository (Adapter)                 │    │
│  │  - Uses SQL queries                                 │    │
│  │  - Handles connection pooling                       │    │
│  │  - Maps database rows to domain entities            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  InMemoryUserRepository (Adapter)                   │    │
│  │  - Stores in Map<string, User>                     │    │
│  │  - Perfect for testing                             │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

**The Magic of Dependency Inversion:**
1. The Domain depends on `IUserRepository` (interface)
2. The Infrastructure provides `PostgreSQLUserRepository` (implementation)
3. The Container wires them together
4. The Domain never knows it's talking to PostgreSQL!

This means:
- **Testability:** You can test with in-memory repositories
- **Flexibility:** You can switch databases without changing business logic
- **Clarity:** The domain only knows what it needs, not how it gets it

### 3. The Implementation

#### Step 1: Database Dependencies

Update `packages/gateway/package.json`:

```json
{
  "dependencies": {
    "fastify": "^4.25.0",
    "dotenv": "^16.3.1",
    "pino": "^8.15.0",
    "pino-pretty": "^10.2.0",
    "zod": "^3.22.4",
    "pg": "^8.11.3",                    // PostgreSQL driver
    "pg-pool": "^3.6.1",                // Connection pooling
    "uuid": "^9.0.1"                    // UUID generation
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "@types/pg": "^8.10.9",             // TypeScript types for pg
    "@types/uuid": "^9.0.7",
    "tsx": "^4.6.0",
    "typescript": "^5.3.0",
    "vitest": "^1.0.0",
    "eslint": "^8.55.0",
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0"
  }
}
```

#### Step 2: Database Connection Manager

**File:** `packages/gateway/src/infrastructure/adapters/persistence/postgres/connection.ts`

```typescript
import { Pool, PoolConfig, PoolClient } from 'pg';
import { DATABASE_URL, DATABASE_MAX_CONNECTIONS, DATABASE_IDLE_TIMEOUT } from '../../../../config.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * PostgreSQL Connection Manager
 * 
 * Manages the connection pool to PostgreSQL.
 * Implements connection pooling, retry logic, and health checks.
 * 
 * In Hexagonal Architecture, this is part of the infrastructure
 * that supports the repository adapters.
 */
export class PostgresConnection {
  private pool: Pool | null = null;
  private readonly logger = createChildLogger({ module: 'PostgresConnection' });
  private isConnected = false;
  private connectionPromise: Promise<void> | null = null;

  /**
   * Initialize the connection pool
   * 
   * Connection pooling is critical for performance:
   * - Creates a pool of reusable connections
   * - Prevents connection overhead on each request
   * - Manages connection lifecycle
   */
  async connect(): Promise<void> {
    if (this.isConnected && this.pool) {
      return;
    }

    // Prevent multiple simultaneous connection attempts
    if (this.connectionPromise) {
      return this.connectionPromise;
    }

    this.logger.info('Connecting to PostgreSQL...');

    this.connectionPromise = new Promise<void>(async (resolve, reject) => {
      try {
        // Parse DATABASE_URL or use individual config
        const config: PoolConfig = this.getPoolConfig();

        // Create connection pool
        this.pool = new Pool(config);

        // Test the connection
        await this.pool.query('SELECT 1');
        
        this.isConnected = true;
        this.logger.info('✅ PostgreSQL connection established');

        // Setup event handlers
        this.setupEventHandlers();

        resolve();
      } catch (error) {
        this.logger.error({ error }, '❌ Failed to connect to PostgreSQL');
        this.pool = null;
        this.isConnected = false;
        reject(error);
      } finally {
        this.connectionPromise = null;
      }
    });

    return this.connectionPromise;
  }

  /**
   * Get pool configuration from environment
   */
  private getPoolConfig(): PoolConfig {
    // If DATABASE_URL is provided, use it
    if (DATABASE_URL) {
      return {
        connectionString: DATABASE_URL,
        max: DATABASE_MAX_CONNECTIONS,
        idleTimeoutMillis: DATABASE_IDLE_TIMEOUT,
        connectionTimeoutMillis: 10000,
        statement_timeout: 30000, // 30 seconds
        query_timeout: 30000,
      };
    }

    // Otherwise use individual configuration (for development)
    return {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      database: process.env.DB_NAME || 'orchestrator',
      user: process.env.DB_USER || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      max: DATABASE_MAX_CONNECTIONS,
      idleTimeoutMillis: DATABASE_IDLE_TIMEOUT,
      connectionTimeoutMillis: 10000,
      statement_timeout: 30000,
      query_timeout: 30000,
    };
  }

  /**
   * Setup pool event handlers for monitoring
   */
  private setupEventHandlers(): void {
    if (!this.pool) return;

    this.pool.on('connect', (client) => {
      this.logger.debug('New PostgreSQL client connected');
    });

    this.pool.on('remove', (client) => {
      this.logger.debug('PostgreSQL client removed from pool');
    });

    this.pool.on('error', (error, client) => {
      this.logger.error({ error }, 'PostgreSQL pool error');
      // The pool will automatically recover
    });

    // Handle connection errors
    this.pool.on('acquire', (client) => {
      this.logger.trace('PostgreSQL client acquired from pool');
    });

    this.pool.on('release', (client) => {
      this.logger.trace('PostgreSQL client released to pool');
    });
  }

  /**
   * Get a client from the pool
   * 
   * This is used by repositories to execute queries.
   * Always release the client back to the pool!
   */
  async getClient(): Promise<PoolClient> {
    if (!this.pool) {
      throw new Error('PostgreSQL not connected');
    }
    
    try {
      const client = await this.pool.connect();
      return client;
    } catch (error) {
      this.logger.error({ error }, 'Failed to get PostgreSQL client');
      throw new Error('Database connection unavailable');
    }
  }

  /**
   * Execute a query directly
   * 
   * Convenience method for simple queries.
   * For complex operations, use getClient() for transaction support.
   */
  async query<T = any>(
    text: string,
    params?: any[]
  ): Promise<{ rows: T[]; rowCount: number }> {
    if (!this.pool) {
      throw new Error('PostgreSQL not connected');
    }

    try {
      const result = await this.pool.query(text, params);
      return {
        rows: result.rows as T[],
        rowCount: result.rowCount || 0,
      };
    } catch (error) {
      this.logger.error({ error, query: text }, 'Query failed');
      throw error;
    }
  }

  /**
   * Execute a transaction
   * 
   * Transactions are critical for data consistency:
   * - All operations succeed or all fail
   * - Prevents partial updates
   * - Maintains referential integrity
   */
  async transaction<T>(
    callback: (client: PoolClient) => Promise<T>
  ): Promise<T> {
    const client = await this.getClient();
    
    try {
      // Begin transaction
      await client.query('BEGIN');
      
      // Execute the callback with the client
      const result = await callback(client);
      
      // Commit the transaction
      await client.query('COMMIT');
      
      return result;
    } catch (error) {
      // Rollback on error
      await client.query('ROLLBACK');
      throw error;
    } finally {
      // Always release the client back to the pool
      client.release();
    }
  }

  /**
   * Check if the database is healthy
   */
  async healthCheck(): Promise<boolean> {
    try {
      if (!this.pool) return false;
      await this.pool.query('SELECT 1');
      return true;
    } catch (error) {
      this.logger.error({ error }, 'Health check failed');
      return false;
    }
  }

  /**
   * Close the connection pool
   * 
   * Important for graceful shutdown:
   * - Waits for all queries to complete
   * - Prevents connection leaks
   */
  async disconnect(): Promise<void> {
    if (!this.pool) {
      return;
    }

    this.logger.info('Closing PostgreSQL connections...');
    
    try {
      await this.pool.end();
      this.isConnected = false;
      this.pool = null;
      this.logger.info('✅ PostgreSQL connections closed');
    } catch (error) {
      this.logger.error({ error }, '❌ Error closing PostgreSQL connections');
      throw error;
    }
  }

  /**
   * Get connection pool statistics
   */
  getStats() {
    if (!this.pool) {
      return { totalCount: 0, idleCount: 0, waitingCount: 0 };
    }

    return {
      totalCount: this.pool.totalCount,
      idleCount: this.pool.idleCount,
      waitingCount: this.pool.waitingCount,
    };
  }
}

// Singleton instance
export const postgresConnection = new PostgresConnection();
```

#### Step 3: PostgreSQL User Repository

**File:** `packages/gateway/src/infrastructure/adapters/persistence/postgres/user.repository.ts`

```typescript
import { PoolClient } from 'pg';
import { User, UserProps } from '../../../../core/domain/entities/user.entity.js';
import { IUserRepository } from '../../../../core/domain/repositories/user.repository.port.js';
import { postgresConnection } from './connection.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * PostgreSQL User Repository
 * 
 * Implements the IUserRepository port using PostgreSQL.
 * Handles the mapping between domain entities and database rows.
 * 
 * Key responsibilities:
 * 1. Convert domain entities to database rows (serialization)
 * 2. Convert database rows to domain entities (deserialization)
 * 3. Handle database-specific errors gracefully
 * 4. Manage connection lifecycle
 */
export class PostgresUserRepository implements IUserRepository {
  private readonly logger = createChildLogger({ module: 'PostgresUserRepository' });

  /**
   * Save a user to the database
   * 
   * Uses INSERT ... ON CONFLICT DO UPDATE (UPSERT) pattern
   * Supports both create and update operations
   */
  async save(user: User): Promise<User> {
    const query = `
      INSERT INTO users (
        id, email, username, first_name, last_name, 
        password_hash, created_at, updated_at, is_active, last_login_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        username = EXCLUDED.username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        password_hash = EXCLUDED.password_hash,
        updated_at = EXCLUDED.updated_at,
        is_active = EXCLUDED.is_active,
        last_login_at = EXCLUDED.last_login_at
      RETURNING *
    `;

    const params = [
      user.id,
      user.email,
      user.username,
      user.firstName,
      user.lastName,
      user.passwordHash,
      user.createdAt,
      user.updatedAt,
      user.isActive,
      user.lastLoginAt,
    ];

    try {
      const result = await postgresConnection.query(query, params);
      
      if (result.rows.length === 0) {
        throw new Error('Failed to save user');
      }

      this.logger.debug({ userId: user.id }, 'User saved successfully');
      return user;
    } catch (error) {
      this.logger.error({ error, userId: user.id }, 'Failed to save user');
      
      // Handle duplicate key errors gracefully
      if (this.isDuplicateKeyError(error)) {
        throw new Error('A user with this email or username already exists');
      }
      
      throw error;
    }
  }

  /**
   * Find a user by ID
   */
  async findById(id: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE id = $1';
    
    try {
      const result = await postgresConnection.query<UserRow>(query, [id]);
      
      if (result.rows.length === 0) {
        return null;
      }

      return this.mapRowToUser(result.rows[0]);
    } catch (error) {
      this.logger.error({ error, userId: id }, 'Failed to find user by ID');
      throw error;
    }
  }

  /**
   * Find a user by email
   */
  async findByEmail(email: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE email = $1';
    
    try {
      const result = await postgresConnection.query<UserRow>(query, [email.toLowerCase()]);
      
      if (result.rows.length === 0) {
        return null;
      }

      return this.mapRowToUser(result.rows[0]);
    } catch (error) {
      this.logger.error({ error, email }, 'Failed to find user by email');
      throw error;
    }
  }

  /**
   * Find a user by username
   */
  async findByUsername(username: string): Promise<User | null> {
    const query = 'SELECT * FROM users WHERE username = $1';
    
    try {
      const result = await postgresConnection.query<UserRow>(query, [username]);
      
      if (result.rows.length === 0) {
        return null;
      }

      return this.mapRowToUser(result.rows[0]);
    } catch (error) {
      this.logger.error({ error, username }, 'Failed to find user by username');
      throw error;
    }
  }

  /**
   * Find users by criteria
   * 
   * Supports dynamic filtering with pagination
   */
  async findAll(
    criteria: Partial<UserProps>,
    limit: number = 100,
    offset: number = 0
  ): Promise<User[]> {
    // Build dynamic WHERE clause
    const conditions: string[] = [];
    const params: any[] = [];
    let paramIndex = 1;

    if (criteria.isActive !== undefined) {
      conditions.push(`is_active = $${paramIndex}`);
      params.push(criteria.isActive);
      paramIndex++;
    }

    if (criteria.email) {
      conditions.push(`email = $${paramIndex}`);
      params.push(criteria.email);
      paramIndex++;
    }

    if (criteria.username) {
      conditions.push(`username = $${paramIndex}`);
      params.push(criteria.username);
      paramIndex++;
    }

    const whereClause = conditions.length > 0 
      ? `WHERE ${conditions.join(' AND ')}` 
      : '';

    const query = `
      SELECT * FROM users 
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;

    params.push(limit, offset);

    try {
      const result = await postgresConnection.query<UserRow>(query, params);
      return result.rows.map(row => this.mapRowToUser(row));
    } catch (error) {
      this.logger.error({ error, criteria }, 'Failed to find users');
      throw error;
    }
  }

  /**
   * Delete a user by ID
   * 
   * Uses hard delete (not soft delete) for simplicity
   * Consider soft delete for production systems
   */
  async delete(id: string): Promise<boolean> {
    const query = 'DELETE FROM users WHERE id = $1 RETURNING id';
    
    try {
      const result = await postgresConnection.query(query, [id]);
      const deleted = result.rowCount > 0;
      
      if (deleted) {
        this.logger.debug({ userId: id }, 'User deleted successfully');
      }
      
      return deleted;
    } catch (error) {
      this.logger.error({ error, userId: id }, 'Failed to delete user');
      throw error;
    }
  }

  /**
   * Check if a user exists by email
   */
  async existsByEmail(email: string): Promise<boolean> {
    const query = 'SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)';
    
    try {
      const result = await postgresConnection.query<{ exists: boolean }>(
        query,
        [email.toLowerCase()]
      );
      
      return result.rows[0]?.exists || false;
    } catch (error) {
      this.logger.error({ error, email }, 'Failed to check email existence');
      throw error;
    }
  }

  /**
   * Check if a user exists by username
   */
  async existsByUsername(username: string): Promise<boolean> {
    const query = 'SELECT EXISTS(SELECT 1 FROM users WHERE username = $1)';
    
    try {
      const result = await postgresConnection.query<{ exists: boolean }>(
        query,
        [username]
      );
      
      return result.rows[0]?.exists || false;
    } catch (error) {
      this.logger.error({ error, username }, 'Failed to check username existence');
      throw error;
    }
  }

  /**
   * Count users matching criteria
   */
  async count(criteria: Partial<UserProps>): Promise<number> {
    const conditions: string[] = [];
    const params: any[] = [];
    let paramIndex = 1;

    if (criteria.isActive !== undefined) {
      conditions.push(`is_active = $${paramIndex}`);
      params.push(criteria.isActive);
      paramIndex++;
    }

    const whereClause = conditions.length > 0 
      ? `WHERE ${conditions.join(' AND ')}` 
      : '';

    const query = `SELECT COUNT(*) FROM users ${whereClause}`;

    try {
      const result = await postgresConnection.query<{ count: string }>(
        query,
        params
      );
      
      return parseInt(result.rows[0]?.count || '0');
    } catch (error) {
      this.logger.error({ error, criteria }, 'Failed to count users');
      throw error;
    }
  }

  /**
   * Map a database row to a User entity
   * 
   * This is where we decouple the database schema from the domain model.
   * The domain entity may have different names or structures than the database.
   */
  private mapRowToUser(row: UserRow): User {
    return new User({
      id: row.id,
      email: row.email,
      username: row.username,
      firstName: row.first_name,
      lastName: row.last_name,
      passwordHash: row.password_hash,
      createdAt: new Date(row.created_at),
      updatedAt: new Date(row.updated_at),
      isActive: row.is_active,
      lastLoginAt: row.last_login_at ? new Date(row.last_login_at) : undefined,
    });
  }

  /**
   * Detect duplicate key errors from PostgreSQL
   */
  private isDuplicateKeyError(error: unknown): boolean {
    if (error && typeof error === 'object' && 'code' in error) {
      // PostgreSQL error code for unique violation
      return error.code === '23505';
    }
    return false;
  }

  /**
   * Execute multiple operations in a transaction
   * 
   * Ensures data consistency when multiple operations need to succeed or fail together
   */
  async transaction<T>(
    callback: (repository: IUserRepository, client: PoolClient) => Promise<T>
  ): Promise<T> {
    return postgresConnection.transaction(async (client) => {
      // Create a repository instance that uses the transaction client
      const transactionalRepo = new PostgresUserRepository();
      // We would need to pass the client to methods
      // For simplicity, we'll use the connection directly
      return callback(this, client);
    });
  }
}

/**
 * Database row shape
 * 
 * This represents how the data is actually stored in PostgreSQL.
 * Notice the snake_case column names vs camelCase domain properties.
 */
interface UserRow {
  id: string;
  email: string;
  username: string;
  first_name: string;
  last_name: string;
  password_hash: string;
  created_at: Date;
  updated_at: Date;
  is_active: boolean;
  last_login_at: Date | null;
}
```

#### Step 4: PostgreSQL Task Repository

**File:** `packages/gateway/src/infrastructure/adapters/persistence/postgres/task.repository.ts`

```typescript
import { PoolClient } from 'pg';
import { Task, TaskProps, TaskStatus, TaskPriority } from '../../../../core/domain/entities/task.entity.js';
import { ITaskRepository } from '../../../../core/domain/repositories/task.repository.port.js';
import { postgresConnection } from './connection.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * PostgreSQL Task Repository
 * 
 * Implements the ITaskRepository port using PostgreSQL.
 * Handles complex queries for tasks including filtering and sorting.
 */
export class PostgresTaskRepository implements ITaskRepository {
  private readonly logger = createChildLogger({ module: 'PostgresTaskRepository' });

  /**
   * Save a task to the database
   */
  async save(task: Task): Promise<Task> {
    const query = `
      INSERT INTO tasks (
        id, title, description, user_id, status, priority,
        due_date, created_at, updated_at, completed_at, metadata
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        description = EXCLUDED.description,
        status = EXCLUDED.status,
        priority = EXCLUDED.priority,
        due_date = EXCLUDED.due_date,
        updated_at = EXCLUDED.updated_at,
        completed_at = EXCLUDED.completed_at,
        metadata = EXCLUDED.metadata
      RETURNING *
    `;

    const taskData = task.toJSON();
    const params = [
      task.id,
      taskData.title,
      taskData.description,
      taskData.userId,
      taskData.status,
      taskData.priority,
      taskData.dueDate || null,
      task.createdAt,
      task.updatedAt,
      task.completedAt || null,
      JSON.stringify(task.metadata || {}),
    ];

    try {
      await postgresConnection.query(query, params);
      this.logger.debug({ taskId: task.id }, 'Task saved successfully');
      return task;
    } catch (error) {
      this.logger.error({ error, taskId: task.id }, 'Failed to save task');
      throw error;
    }
  }

  /**
   * Find a task by ID
   */
  async findById(id: string): Promise<Task | null> {
    const query = 'SELECT * FROM tasks WHERE id = $1';
    
    try {
      const result = await postgresConnection.query<TaskRow>(query, [id]);
      
      if (result.rows.length === 0) {
        return null;
      }

      return this.mapRowToTask(result.rows[0]);
    } catch (error) {
      this.logger.error({ error, taskId: id }, 'Failed to find task by ID');
      throw error;
    }
  }

  /**
   * Find all tasks for a user
   */
  async findByUserId(userId: string): Promise<Task[]> {
    const query = `
      SELECT * FROM tasks 
      WHERE user_id = $1 
      ORDER BY created_at DESC
    `;
    
    try {
      const result = await postgresConnection.query<TaskRow>(query, [userId]);
      return result.rows.map(row => this.mapRowToTask(row));
    } catch (error) {
      this.logger.error({ error, userId }, 'Failed to find tasks by user');
      throw error;
    }
  }

  /**
   * Find tasks by user and status
   */
  async findByUserAndStatus(userId: string, status: TaskStatus): Promise<Task[]> {
    const query = `
      SELECT * FROM tasks 
      WHERE user_id = $1 AND status = $2 
      ORDER BY created_at DESC
    `;
    
    try {
      const result = await postgresConnection.query<TaskRow>(query, [userId, status]);
      return result.rows.map(row => this.mapRowToTask(row));
    } catch (error) {
      this.logger.error({ error, userId, status }, 'Failed to find tasks by user and status');
      throw error;
    }
  }

  /**
   * Find tasks by user and priority
   */
  async findByUserAndPriority(userId: string, priority: TaskPriority): Promise<Task[]> {
    const query = `
      SELECT * FROM tasks 
      WHERE user_id = $1 AND priority = $2 
      ORDER BY created_at DESC
    `;
    
    try {
      const result = await postgresConnection.query<TaskRow>(query, [userId, priority]);
      return result.rows.map(row => this.mapRowToTask(row));
    } catch (error) {
      this.logger.error({ error, userId, priority }, 'Failed to find tasks by user and priority');
      throw error;
    }
  }

  /**
   * Find overdue tasks for a user
   */
  async findOverdueByUser(userId: string): Promise<Task[]> {
    const query = `
      SELECT * FROM tasks 
      WHERE user_id = $1 
        AND due_date < NOW() 
        AND status IN ($2, $3, $4)
      ORDER BY due_date ASC
    `;
    
    try {
      const result = await postgresConnection.query<TaskRow>(
        query,
        [userId, TaskStatus.PENDING, TaskStatus.IN_PROGRESS, TaskStatus.FAILED]
      );
      return result.rows.map(row => this.mapRowToTask(row));
    } catch (error) {
      this.logger.error({ error, userId }, 'Failed to find overdue tasks');
      throw error;
    }
  }

  /**
   * Find tasks by criteria with pagination
   */
  async findAll(
    criteria: Partial<TaskProps>,
    limit: number = 100,
    offset: number = 0
  ): Promise<Task[]> {
    const conditions: string[] = [];
    const params: any[] = [];
    let paramIndex = 1;

    if (criteria.userId) {
      conditions.push(`user_id = $${paramIndex}`);
      params.push(criteria.userId);
      paramIndex++;
    }

    if (criteria.status) {
      conditions.push(`status = $${paramIndex}`);
      params.push(criteria.status);
      paramIndex++;
    }

    if (criteria.priority) {
      conditions.push(`priority = $${paramIndex}`);
      params.push(criteria.priority);
      paramIndex++;
    }

    if (criteria.title) {
      conditions.push(`title ILIKE $${paramIndex}`);
      params.push(`%${criteria.title}%`);
      paramIndex++;
    }

    const whereClause = conditions.length > 0 
      ? `WHERE ${conditions.join(' AND ')}` 
      : '';

    const query = `
      SELECT * FROM tasks 
      ${whereClause}
      ORDER BY 
        priority = 'critical' DESC,
        priority = 'high' DESC,
        due_date ASC NULLS LAST,
        created_at DESC
      LIMIT $${paramIndex} OFFSET $${paramIndex + 1}
    `;

    params.push(limit, offset);

    try {
      const result = await postgresConnection.query<TaskRow>(query, params);
      return result.rows.map(row => this.mapRowToTask(row));
    } catch (error) {
      this.logger.error({ error, criteria }, 'Failed to find tasks');
      throw error;
    }
  }

  /**
   * Delete a task by ID
   */
  async delete(id: string): Promise<boolean> {
    const query = 'DELETE FROM tasks WHERE id = $1 RETURNING id';
    
    try {
      const result = await postgresConnection.query(query, [id]);
      const deleted = result.rowCount > 0;
      
      if (deleted) {
        this.logger.debug({ taskId: id }, 'Task deleted successfully');
      }
      
      return deleted;
    } catch (error) {
      this.logger.error({ error, taskId: id }, 'Failed to delete task');
      throw error;
    }
  }

  /**
   * Count tasks for a user
   */
  async countByUser(userId: string, status?: TaskStatus): Promise<number> {
    let query = 'SELECT COUNT(*) FROM tasks WHERE user_id = $1';
    const params: any[] = [userId];
    
    if (status) {
      query += ' AND status = $2';
      params.push(status);
    }

    try {
      const result = await postgresConnection.query<{ count: string }>(
        query,
        params
      );
      
      return parseInt(result.rows[0]?.count || '0');
    } catch (error) {
      this.logger.error({ error, userId, status }, 'Failed to count tasks');
      throw error;
    }
  }

  /**
   * Execute multiple operations in a transaction
   */
  async transaction<T>(
    callback: (repository: ITaskRepository, client: PoolClient) => Promise<T>
  ): Promise<T> {
    return postgresConnection.transaction(async (client) => {
      return callback(this, client);
    });
  }

  /**
   * Map a database row to a Task entity
   */
  private mapRowToTask(row: TaskRow): Task {
    return new Task({
      id: row.id,
      title: row.title,
      description: row.description,
      userId: row.user_id,
      status: row.status as TaskStatus,
      priority: row.priority as TaskPriority,
      dueDate: row.due_date ? new Date(row.due_date) : undefined,
      createdAt: new Date(row.created_at),
      updatedAt: new Date(row.updated_at),
      completedAt: row.completed_at ? new Date(row.completed_at) : undefined,
      metadata: row.metadata || {},
    });
  }
}

/**
 * Database row shape for tasks
 */
interface TaskRow {
  id: string;
  title: string;
  description: string;
  user_id: string;
  status: string;
  priority: string;
  due_date: Date | null;
  created_at: Date;
  updated_at: Date;
  completed_at: Date | null;
  metadata: Record<string, unknown> | null;
}
```

#### Step 5: Database Migrations

**File:** `packages/gateway/src/infrastructure/adapters/persistence/postgres/migrations/001_initial_schema.sql`

```sql
-- 001_initial_schema.sql
-- Initial database schema for the Orchestrator system

-- Enable UUID extension for generating IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Comment on columns for documentation
COMMENT ON TABLE users IS 'User accounts for the Orchestrator system';
COMMENT ON COLUMN users.id IS 'Unique identifier for the user';
COMMENT ON COLUMN users.email IS 'User email address (unique)';
COMMENT ON COLUMN users.username IS 'Unique username for display';
COMMENT ON COLUMN users.password_hash IS 'Bcrypt hash of the password';
COMMENT ON COLUMN users.is_active IS 'Whether the user account is active';
COMMENT ON COLUMN users.last_login_at IS 'Timestamp of the last successful login';

-- ============================================
-- TASKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes for common queries
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC);
CREATE INDEX idx_tasks_completed_at ON tasks(completed_at);

-- Composite indexes for performance
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);
CREATE INDEX idx_tasks_user_priority ON tasks(user_id, priority);

-- GIN index for JSONB metadata queries
CREATE INDEX idx_tasks_metadata ON tasks USING GIN(metadata);

-- Comment on columns for documentation
COMMENT ON TABLE tasks IS 'Tasks created by users in the Orchestrator system';
COMMENT ON COLUMN tasks.id IS 'Unique identifier for the task';
COMMENT ON COLUMN tasks.user_id IS 'The user who owns this task';
COMMENT ON COLUMN tasks.status IS 'Current status: pending, in_progress, completed, failed, cancelled';
COMMENT ON COLUMN tasks.priority IS 'Priority level: low, medium, high, critical';
COMMENT ON COLUMN tasks.metadata IS 'Flexible JSON metadata for task extensions';

-- ============================================
-- TRIGGERS FOR AUTOMATIC UPDATED_AT
-- ============================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply to tasks table
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

**File:** `packages/gateway/src/infrastructure/adapters/persistence/postgres/migrations/002_add_indexes.sql`

```sql
-- 002_add_indexes.sql
-- Additional indexes for performance optimization

-- Partial index for active users only
CREATE INDEX IF NOT EXISTS idx_users_active_email 
ON users(email) 
WHERE is_active = true;

-- Partial index for pending tasks
CREATE INDEX IF NOT EXISTS idx_tasks_pending_due 
ON tasks(due_date) 
WHERE status = 'pending' OR status = 'in_progress';

-- Covering index for frequently accessed columns
CREATE INDEX IF NOT EXISTS idx_tasks_covering 
ON tasks(user_id, status, priority, due_date) 
INCLUDE (title, created_at);

-- Index for task count queries
CREATE INDEX IF NOT EXISTS idx_tasks_user_status_created 
ON tasks(user_id, status, created_at DESC);

-- Index for overdue tasks
CREATE INDEX IF NOT EXISTS idx_tasks_overdue 
ON tasks(user_id, due_date) 
WHERE due_date < NOW() AND status IN ('pending', 'in_progress', 'failed');

-- Full-text search index (optional)
-- For production, consider using PostgreSQL full-text search
CREATE INDEX IF NOT EXISTS idx_tasks_search 
ON tasks USING GIN (to_tsvector('english', title || ' ' || description));
```

#### Step 6: Migration Runner

**File:** `packages/gateway/src/admin/db-migrate.ts` (Updated)

```typescript
#!/usr/bin/env node

import { postgresConnection } from '../infrastructure/adapters/persistence/postgres/connection.js';
import { createChildLogger } from '../logger.js';
import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const logger = createChildLogger({ module: 'MigrationRunner' });

/**
 * Database Migration Runner
 * 
 * 12-Factor: Admin processes run as one-off tasks (Factor 12)
 * 
 * Runs SQL migrations in order to set up the database schema.
 * Tracks which migrations have been run in a migration table.
 */
class MigrationRunner {
  private readonly migrationsPath = resolve(__dirname, '../infrastructure/adapters/persistence/postgres/migrations');

  /**
   * Run all pending migrations
   */
  async runMigrations(): Promise<void> {
    logger.info('Starting database migrations...');

    try {
      // Connect to database
      await postgresConnection.connect();

      // Ensure migration table exists
      await this.ensureMigrationTable();

      // Get list of pending migrations
      const migrations = await this.getPendingMigrations();

      if (migrations.length === 0) {
        logger.info('✅ No pending migrations');
        return;
      }

      logger.info(`📦 Found ${migrations.length} pending migrations`);

      // Run each migration in order
      for (const migration of migrations) {
        await this.runMigration(migration);
      }

      logger.info('✅ All migrations completed successfully');
    } catch (error) {
      logger.error({ error }, '❌ Migration failed');
      throw error;
    } finally {
      await postgresConnection.disconnect();
    }
  }

  /**
   * Create the migrations table if it doesn't exist
   */
  private async ensureMigrationTable(): Promise<void> {
    const query = `
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        executed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
      )
    `;

    await postgresConnection.query(query);
    logger.debug('Migration table ensured');
  }

  /**
   * Get list of pending migrations
   */
  private async getPendingMigrations(): Promise<string[]> {
    // Get all migration files from the migrations directory
    const fs = await import('fs');
    const path = await import('path');
    
    const files = fs.readdirSync(this.migrationsPath)
      .filter(file => file.endsWith('.sql'))
      .sort(); // Ensure files are in order

    // Get executed migrations
    const result = await postgresConnection.query<{ name: string }>(
      'SELECT name FROM migrations'
    );
    
    const executedMigrations = new Set(result.rows.map(row => row.name));

    // Return only pending migrations
    return files.filter(file => !executedMigrations.has(file));
  }

  /**
   * Run a single migration
   */
  private async runMigration(filename: string): Promise<void> {
    logger.info(`🔄 Running migration: ${filename}`);

    try {
      // Read the migration file
      const filePath = resolve(this.migrationsPath, filename);
      const sql = readFileSync(filePath, 'utf-8');

      // Execute the migration in a transaction
      await postgresConnection.transaction(async (client) => {
        // Execute the migration SQL
        await client.query(sql);

        // Record that the migration was run
        await client.query(
          'INSERT INTO migrations (name) VALUES ($1)',
          [filename]
        );
      });

      logger.info(`✅ Migration completed: ${filename}`);
    } catch (error) {
      logger.error({ error, filename }, `❌ Migration failed: ${filename}`);
      throw error;
    }
  }

  /**
   * Rollback to a specific migration (optional)
   */
  async rollback(): Promise<void> {
    logger.warn('Rollback not implemented in this version');
    // In production, you would implement rollback logic here
  }
}

// Run the migrations
if (import.meta.url === `file://${process.argv[1]}`) {
  const runner = new MigrationRunner();
  
  runner.runMigrations()
    .then(() => {
      process.exit(0);
    })
    .catch((error) => {
      console.error('Migration failed:', error);
      process.exit(1);
    });
}

export { MigrationRunner };
```

#### Step 7: Update Dependency Injection Container

**File:** `packages/gateway/src/infrastructure/di/container.ts` (Updated)

```typescript
import { UserDomainService } from '../../core/domain/services/user.service.js';
import { TaskDomainService } from '../../core/domain/services/task.service.js';
import { UserCommandHandler, UserQueryHandler } from '../../core/application/handlers/user.handlers.js';
import { UserController } from '../adapters/http/user.controller.js';
import { IUserRepository, USER_REPOSITORY } from '../../core/domain/repositories/user.repository.port.js';
import { ITaskRepository, TASK_REPOSITORY } from '../../core/domain/repositories/task.repository.port.js';
import { InMemoryUserRepository } from '../adapters/persistence/in-memory/user.repository.js';
import { InMemoryTaskRepository } from '../adapters/persistence/in-memory/task.repository.js';
import { PostgresUserRepository } from '../adapters/persistence/postgres/user.repository.js';
import { PostgresTaskRepository } from '../adapters/persistence/postgres/task.repository.js';
import { postgresConnection } from '../adapters/persistence/postgres/connection.js';
import { NODE_ENV, IS_TEST } from '../../config.js';

/**
 * Dependency Injection Container
 * 
 * Decides which repository implementation to use based on environment:
 * - Production/Development: PostgreSQL
 * - Test: In-memory (for speed and isolation)
 */
export class Container {
  private static instance: Container;
  
  // Dependencies
  private userRepository!: IUserRepository;
  private taskRepository!: ITaskRepository;
  private userDomainService!: UserDomainService;
  private taskDomainService!: TaskDomainService;
  private userCommandHandler!: UserCommandHandler;
  private userQueryHandler!: UserQueryHandler;
  private userController!: UserController;

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
    // Choose repository implementation based on environment
    const usePostgres = NODE_ENV !== 'test';
    
    this.logger.info(`Using ${usePostgres ? 'PostgreSQL' : 'In-Memory'} repositories`);

    // Repositories (Infrastructure)
    if (usePostgres) {
      // Connect to PostgreSQL
      postgresConnection.connect().catch((error) => {
        this.logger.error({ error }, 'Failed to connect to PostgreSQL');
        // In development, we might want to fallback to in-memory
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
      // Use in-memory for testing
      this.userRepository = new InMemoryUserRepository();
      this.taskRepository = new InMemoryTaskRepository();
    }

    // Domain Services (Domain Layer)
    this.userDomainService = new UserDomainService(this.userRepository);
    this.taskDomainService = new TaskDomainService(this.taskRepository, this.userRepository);

    // Application Handlers (Application Layer)
    this.userCommandHandler = new UserCommandHandler(this.userDomainService);
    this.userQueryHandler = new UserQueryHandler(this.userDomainService);

    // HTTP Controllers (Infrastructure - Adapters)
    this.userController = new UserController(
      this.userCommandHandler,
      this.userQueryHandler
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

  getUserCommandHandler(): UserCommandHandler {
    return this.userCommandHandler;
  }

  getUserQueryHandler(): UserQueryHandler {
    return this.userQueryHandler;
  }

  /**
   * Reset the container (for testing)
   */
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

#### Step 8: Update Environment Configuration

**File:** `packages/gateway/.env.example` (Updated)

```env
# ============================================
# APPLICATION CONFIGURATION
# ============================================
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
SERVICE_NAME=gateway
SERVICE_VERSION=1.0.0

# ============================================
# DATABASE CONFIGURATION (PostgreSQL)
# ============================================
# Option 1: Connection URL (recommended)
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/orchestrator

# Option 2: Individual settings (alternative)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=orchestrator
DB_USER=postgres
DB_PASSWORD=postgres

# Connection Pool Settings
DATABASE_MAX_CONNECTIONS=10
DATABASE_IDLE_TIMEOUT=30000

# ============================================
# REDIS CONFIGURATION (Optional)
# ============================================
REDIS_URL=redis://localhost:6379

# ============================================
# EXTERNAL SERVICES
# ============================================
AUTH_SERVICE_URL=http://auth-service:3001
USER_SERVICE_URL=http://user-service:3002

# ============================================
# SECURITY
# ============================================
JWT_SECRET=dev-secret-key-change-in-production
API_KEY=dev-api-key

# ============================================
# CORS
# ============================================
CORS_ORIGINS=http://localhost:3000,http://localhost:5173

# ============================================
# MONITORING
# ============================================
METRICS_ENABLED=true
METRICS_PORT=9090
HEALTH_CHECK_INTERVAL=30000

# ============================================
# RATE LIMITING
# ============================================
RATE_LIMIT_ENABLED=true
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX_REQUESTS=100
```

### 4. The Verification

#### Step 1: Start PostgreSQL

```bash
# Using Docker Compose
cd packages/gateway
docker-compose up -d postgres
```

#### Step 2: Run Database Migrations

```bash
# Run migrations
npm run admin:db-migrate
```

Expected output:
```
[INFO] Starting database migrations...
[INFO] Connecting to PostgreSQL...
[INFO] ✅ PostgreSQL connection established
[INFO] 📦 Found 2 pending migrations
[INFO] 🔄 Running migration: 001_initial_schema.sql
[INFO] ✅ Migration completed: 001_initial_schema.sql
[INFO] 🔄 Running migration: 002_add_indexes.sql
[INFO] ✅ Migration completed: 002_add_indexes.sql
[INFO] ✅ All migrations completed successfully
[INFO] Closing PostgreSQL connections...
[INFO] ✅ PostgreSQL connections closed
```

#### Step 3: Verify Database Schema

Connect to PostgreSQL to verify the schema:

```bash
docker exec -it orchestrator-gateway-postgres-1 psql -U postgres -d orchestrator
```

Then run:

```sql
\dt
\d users
\d tasks
\d migrations
```

Expected output:
```
              List of relations
 Schema |      Name       | Type  |  Owner   
--------+-----------------+-------+----------
 public | migrations      | table | postgres
 public | tasks           | table | postgres
 public | users           | table | postgres
(3 rows)
```

#### Step 4: Run Integration Tests

**File:** `packages/gateway/tests/integration/setup.ts`

```typescript
import { beforeAll, afterAll, afterEach } from 'vitest';
import { postgresConnection } from '../../src/infrastructure/adapters/persistence/postgres/connection.js';
import { Container } from '../../src/infrastructure/di/container.js';

beforeAll(async () => {
  // Connect to PostgreSQL
  await postgresConnection.connect();
});

afterEach(async () => {
  // Clean up between tests
  const container = Container.getInstance();
  container.reset();
});

afterAll(async () => {
  // Disconnect after all tests
  await postgresConnection.disconnect();
});
```

**File:** `packages/gateway/tests/integration/user.repository.test.ts`

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { PostgresUserRepository } from '../../src/infrastructure/adapters/persistence/postgres/user.repository.js';
import { User } from '../../src/core/domain/entities/user.entity.js';
import { postgresConnection } from '../../src/infrastructure/adapters/persistence/postgres/connection.js';

describe('PostgresUserRepository Integration Tests', () => {
  let repository: PostgresUserRepository;

  beforeAll(async () => {
    repository = new PostgresUserRepository();
  });

  afterAll(async () => {
    // Clean up
    await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
  });

  it('should save and find a user', async () => {
    // Arrange
    const user = new User({
      email: 'test@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      passwordHash: 'hashed_password_123',
    });

    // Act
    await repository.save(user);
    const foundUser = await repository.findById(user.id);

    // Assert
    expect(foundUser).toBeDefined();
    expect(foundUser?.id).toBe(user.id);
    expect(foundUser?.email).toBe(user.email);
    expect(foundUser?.username).toBe(user.username);
  });

  it('should find user by email', async () => {
    // Arrange
    const user = new User({
      email: 'findbyemail@example.com',
      username: 'finduser',
      firstName: 'Find',
      lastName: 'User',
      passwordHash: 'hashed_password_123',
    });
    await repository.save(user);

    // Act
    const foundUser = await repository.findByEmail('findbyemail@example.com');

    // Assert
    expect(foundUser).toBeDefined();
    expect(foundUser?.id).toBe(user.id);
    expect(foundUser?.email).toBe('findbyemail@example.com');
  });

  it('should update a user', async () => {
    // Arrange
    const user = new User({
      email: 'update@example.com',
      username: 'updateuser',
      firstName: 'Original',
      lastName: 'User',
      passwordHash: 'hashed_password_123',
    });
    await repository.save(user);

    // Act
    user.updateProfile('Updated', 'Name');
    await repository.save(user);
    const updatedUser = await repository.findById(user.id);

    // Assert
    expect(updatedUser?.firstName).toBe('Updated');
    expect(updatedUser?.lastName).toBe('Name');
  });

  it('should delete a user', async () => {
    // Arrange
    const user = new User({
      email: 'delete@example.com',
      username: 'deleteuser',
      firstName: 'Delete',
      lastName: 'User',
      passwordHash: 'hashed_password_123',
    });
    await repository.save(user);

    // Act
    const deleted = await repository.delete(user.id);
    const foundUser = await repository.findById(user.id);

    // Assert
    expect(deleted).toBe(true);
    expect(foundUser).toBeNull();
  });

  it('should handle duplicate email errors', async () => {
    // Arrange
    const user1 = new User({
      email: 'duplicate@example.com',
      username: 'user1',
      firstName: 'User',
      lastName: 'One',
      passwordHash: 'hashed_password_123',
    });
    await repository.save(user1);

    const user2 = new User({
      email: 'duplicate@example.com', // Same email
      username: 'user2',
      firstName: 'User',
      lastName: 'Two',
      passwordHash: 'hashed_password_123',
    });

    // Act & Assert
    await expect(repository.save(user2)).rejects.toThrow(
      'A user with this email or username already exists'
    );
  });
});
```

Run the integration tests:

```bash
npm test tests/integration/
```

Expected output:
```
✓ PostgresUserRepository Integration Tests (5 tests) 245ms
```

#### Step 5: Test the API with PostgreSQL

Start the service:

```bash
# Make sure PostgreSQL is running
docker-compose up -d postgres

# Start the service
npm run dev
```

**Create a user:**
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "production@example.com",
    "username": "production_user",
    "password": "SecurePass123",
    "firstName": "Production",
    "lastName": "User"
  }'
```

**Verify in the database:**
```bash
docker exec -it orchestrator-gateway-postgres-1 psql -U postgres -d orchestrator \
  -c "SELECT id, email, username, first_name, last_name FROM users WHERE email = 'production@example.com';"
```

Expected output:
```
                  id                  |        email         |   username    | first_name | last_name 
--------------------------------------+----------------------+---------------+---------------+-----------
 550e8400-e29b-41d4-a716-446655440000 | production@example.com | production_user | Production  | User
(1 row)
```

### 5. Deep Dive: Database Patterns & Best Practices

#### Connection Pooling

Connection pooling is critical for production performance:

**Why It Matters:**
- Creating a database connection takes time (handshake, auth, etc.)
- Each connection uses server resources (memory, file descriptors)
- Too many connections can overload the database

**How It Works:**
```typescript
// Pool configuration
{
  max: 10,        // Maximum connections
  idleTimeout: 30000, // Close idle connections after 30s
  connectionTimeout: 10000, // Wait 10s for a connection
}
```

**Best Practices:**
1. Set `max` based on your database's capacity
2. Monitor connection usage with `pool.totalCount`
3. Always release connections back to the pool
4. Handle connection errors gracefully

#### Transaction Management

Transactions ensure data consistency:

**When to Use Transactions:**
```typescript
// Example: Creating a user with tasks
await connection.transaction(async (client) => {
  // 1. Create user
  await client.query('INSERT INTO users ...', [userData]);
  
  // 2. Create initial tasks
  for (const task of initialTasks) {
    await client.query('INSERT INTO tasks ...', [task, userData.id]);
  }
  
  // If either fails, everything is rolled back!
});
```

**Transaction Best Practices:**
1. Keep transactions short (fast operations)
2. Avoid long-running transactions (they hold locks)
3. Handle rollback scenarios
4. Use appropriate isolation levels

#### Migration Strategy

Database migrations manage schema evolution:

**Migration Flow:**
1. Developer creates a new SQL file in `migrations/`
2. Migration runner executes files in order
3. Each migration is recorded in the `migrations` table
4. Rollbacks can revert changes if needed

**Migration Best Practices:**
1. Migrations should be idempotent (can be run multiple times)
2. Test migrations before production
3. Include rollback scripts
4. Monitor migration performance

#### Repository Pattern Benefits

The repository pattern provides several advantages:

**1. Abstraction:**
```typescript
// Domain depends on interface
interface IUserRepository { ... }

// Infrastructure provides implementation
class PostgresUserRepository implements IUserRepository { ... }
```

**2. Testing:**
```typescript
// Use in-memory for fast tests
const repo = new InMemoryUserRepository();

// Use PostgreSQL for integration tests
const repo = new PostgresUserRepository();
```

**3. Flexibility:**
```typescript
// Switch databases without changing business logic
const repo = process.env.USE_POSTGRES 
  ? new PostgresUserRepository()
  : new InMemoryUserRepository();
```

### 6. Summary

**What We Built:**
- ✅ PostgreSQL connection manager with connection pooling
- ✅ PostgreSQL repository implementations for User and Task
- ✅ Database migrations for schema management
- ✅ Integration tests with real PostgreSQL
- ✅ Proper error handling for database operations
- ✅ Transaction support for data consistency
- ✅ Environment-based repository selection

**Key Concepts Learned:**
- Connection pooling and its importance
- Repository pattern implementation with PostgreSQL
- Database migration strategies
- Integration testing with real infrastructure
- Transaction management
- Error handling for database operations

**What's Next:**
In Part 3 of Phase 2, we'll add caching with Redis, implement a task controller, and build out the complete CRUD operations for the task management system. We'll also add more comprehensive integration and end-to-end tests.

**Verification Checklist:**
- [ ] PostgreSQL migrations run successfully
- [ ] User repository operations work with PostgreSQL
- [ ] Task repository operations work with PostgreSQL
- [ ] Integration tests pass
- [ ] API endpoints work with PostgreSQL
- [ ] Connection pooling is configured correctly
- [ ] Transactions work properly

