# Primer 16: Understanding Database Patterns & Data Management

## A Comprehensive Guide to Data Management in Distributed Systems

Welcome to the sixteenth primer! This is a comprehensive deep dive into database patterns and data management strategies for distributed systems. Think of this like managing inventory across multiple restaurant locations - you need to know where everything is, keep it consistent, and ensure it's available when needed.

### 1. The Big Picture

#### Database Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DATABASE ARCHITECTURE PATTERNS                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATABASE PER SERVICE                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   User       │  │   Task       │  │   Analytics  │              │   │
│  │  │   Database   │  │   Database   │  │   Database   │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATA REPLICATION PATTERNS                        │   │
│  │  • Primary-Replica • Multi-Master • Distributed • CQRS              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATA ACCESS PATTERNS                             │   │
│  │  • Repository Pattern • Data Mapper • Active Record                 │   │
│  │  • Unit of Work • Query Object • Specification Pattern              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Database Per Service Pattern

#### Service-Specific Database Configuration

```typescript
// Database Configuration for Each Service
interface DatabaseConfig {
    host: string;
    port: number;
    database: string;
    username: string;
    password: string;
    maxConnections: number;
    connectionTimeout: number;
    idleTimeout: number;
}

class DatabaseService {
    private pool: Pool;
    private logger: Logger;
    private config: DatabaseConfig;

    constructor(config: DatabaseConfig) {
        this.config = config;
        this.logger = createLogger({ 
            service: `database-${config.database}` 
        });
        
        this.pool = new Pool({
            host: config.host,
            port: config.port,
            database: config.database,
            user: config.username,
            password: config.password,
            max: config.maxConnections,
            connectionTimeoutMillis: config.connectionTimeout,
            idleTimeoutMillis: config.idleTimeout,
        });

        this.setupMonitoring();
    }

    private setupMonitoring(): void {
        // Monitor pool events
        this.pool.on('acquire', () => {
            this.logger.trace('Connection acquired', {
                total: this.pool.totalCount,
                idle: this.pool.idleCount,
                waiting: this.pool.waitingCount,
            });
        });

        this.pool.on('error', (error) => {
            this.logger.error({ error }, 'Database pool error');
        });
    }

    async query<T>(sql: string, params?: any[]): Promise<T[]> {
        const client = await this.pool.connect();
        try {
            const startTime = Date.now();
            const result = await client.query(sql, params);
            const duration = Date.now() - startTime;

            this.logger.debug({
                sql: sql.slice(0, 100),
                duration,
                rowCount: result.rowCount,
            }, 'Query executed');

            return result.rows as T[];
        } finally {
            client.release();
        }
    }

    async transaction<T>(
        callback: (client: PoolClient) => Promise<T>
    ): Promise<T> {
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');
            const result = await callback(client);
            await client.query('COMMIT');
            return result;
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    async getMetrics(): Promise<{
        totalConnections: number;
        idleConnections: number;
        activeConnections: number;
        waitingRequests: number;
    }> {
        return {
            totalConnections: this.pool.totalCount,
            idleConnections: this.pool.idleCount,
            activeConnections: this.pool.totalCount - this.pool.idleCount,
            waitingRequests: this.pool.waitingCount,
        };
    }
}

// User Service Database
const userDatabase = new DatabaseService({
    host: process.env.USER_DB_HOST || 'localhost',
    port: parseInt(process.env.USER_DB_PORT || '5432'),
    database: process.env.USER_DB_NAME || 'user_service',
    username: process.env.USER_DB_USER || 'user_service',
    password: process.env.USER_DB_PASSWORD || 'user_service_password',
    maxConnections: 10,
    connectionTimeout: 5000,
    idleTimeout: 30000,
});

// Task Service Database
const taskDatabase = new DatabaseService({
    host: process.env.TASK_DB_HOST || 'localhost',
    port: parseInt(process.env.TASK_DB_PORT || '5432'),
    database: process.env.TASK_DB_NAME || 'task_service',
    username: process.env.TASK_DB_USER || 'task_service',
    password: process.env.TASK_DB_PASSWORD || 'task_service_password',
    maxConnections: 20,
    connectionTimeout: 5000,
    idleTimeout: 30000,
});
```

### 3. Data Replication Patterns

#### Primary-Replica Replication

```typescript
class ReplicationManager {
    private primary: DatabaseService;
    private replicas: DatabaseService[];
    private logger: Logger;
    private currentReplicaIndex: number = 0;

    constructor(primary: DatabaseService, replicas: DatabaseService[]) {
        this.primary = primary;
        this.replicas = replicas;
        this.logger = createLogger({ service: 'replication-manager' });
    }

    async write<T>(sql: string, params?: any[]): Promise<T[]> {
        // Always write to primary
        return await this.primary.query<T>(sql, params);
    }

    async read<T>(sql: string, params?: any[]): Promise<T[]> {
        // Read from replica with load balancing
        const replica = this.getReplica();
        try {
            return await replica.query<T>(sql, params);
        } catch (error) {
            this.logger.error({ error }, 'Replica read failed, falling back to primary');
            return await this.primary.query<T>(sql, params);
        }
    }

    private getReplica(): DatabaseService {
        if (this.replicas.length === 0) {
            return this.primary;
        }

        // Round-robin load balancing
        const replica = this.replicas[this.currentReplicaIndex];
        this.currentReplicaIndex = (this.currentReplicaIndex + 1) % this.replicas.length;
        return replica;
    }

    async transaction<T>(
        callback: (client: PoolClient) => Promise<T>
    ): Promise<T> {
        // Transactions must use primary
        return await this.primary.transaction(callback);
    }

    async checkReplicationLag(): Promise<{
        replica: string;
        lag: number;
    }[]> {
        const results = [];
        for (const replica of this.replicas) {
            try {
                const result = await replica.query<{
                    lag: number;
                }>(`
                    SELECT 
                        EXTRACT(EPOCH FROM (NOW() - pg_last_xact_replay_timestamp())) 
                        as lag
                `);
                results.push({
                    replica: replica.config.database,
                    lag: result[0]?.lag || 0,
                });
            } catch (error) {
                this.logger.error({ error }, 'Failed to check replication lag');
                results.push({
                    replica: replica.config.database,
                    lag: -1,
                });
            }
        }
        return results;
    }
}
```

#### Sharding Strategy

```typescript
class ShardManager {
    private shards: Map<number, DatabaseService> = new Map();
    private shardCount: number;
    private logger: Logger;

    constructor(shardCount: number) {
        this.shardCount = shardCount;
        this.logger = createLogger({ service: 'shard-manager' });
        this.initializeShards();
    }

    private initializeShards(): void {
        for (let i = 0; i < this.shardCount; i++) {
            const config: DatabaseConfig = {
                host: process.env[`SHARD_${i}_HOST`] || 'localhost',
                port: parseInt(process.env[`SHARD_${i}_PORT`] || '5432'),
                database: process.env[`SHARD_${i}_DB`] || `shard_${i}`,
                username: process.env[`SHARD_${i}_USER`] || 'postgres',
                password: process.env[`SHARD_${i}_PASSWORD`] || 'postgres',
                maxConnections: 10,
                connectionTimeout: 5000,
                idleTimeout: 30000,
            };
            this.shards.set(i, new DatabaseService(config));
        }
    }

    // Consistent hashing for shard selection
    getShardForKey(key: string | number): number {
        if (typeof key === 'number') {
            return key % this.shardCount;
        }
        
        // Use hash for string keys
        const hash = this.hashString(key);
        return hash % this.shardCount;
    }

    private hashString(str: string): number {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash);
    }

    async query<T>(
        key: string | number,
        sql: string,
        params?: any[]
    ): Promise<T[]> {
        const shardId = this.getShardForKey(key);
        const shard = this.shards.get(shardId);
        if (!shard) {
            throw new Error(`Shard ${shardId} not found`);
        }
        return await shard.query<T>(sql, params);
    }

    async queryAllShards<T>(
        sql: string,
        params?: any[]
    ): Promise<{ shardId: number; results: T[] }[]> {
        const results = [];
        for (const [shardId, shard] of this.shards) {
            try {
                const data = await shard.query<T>(sql, params);
                results.push({ shardId, results: data });
            } catch (error) {
                this.logger.error({ shardId, error }, 'Shard query failed');
                results.push({ shardId, results: [] });
            }
        }
        return results;
    }

    async transaction<T>(
        key: string | number,
        callback: (client: PoolClient) => Promise<T>
    ): Promise<T> {
        const shardId = this.getShardForKey(key);
        const shard = this.shards.get(shardId);
        if (!shard) {
            throw new Error(`Shard ${shardId} not found`);
        }
        return await shard.transaction(callback);
    }

    // Rebalance shards
    async rebalance(
        newShardCount: number,
        rebalanceFn: (oldShardId: number, key: string) => number
    ): Promise<void> {
        // Implementation for rebalancing data across shards
        this.logger.warn({ 
            oldCount: this.shardCount,
            newCount: newShardCount,
        }, 'Shard rebalance started');
        
        // This would involve data migration and would be complex
        // Usually done with zero-downtime strategies
        this.shardCount = newShardCount;
    }
}
```

### 4. Data Access Patterns

#### Repository Pattern

```typescript
interface User {
    id: string;
    email: string;
    username: string;
    firstName: string;
    lastName: string;
    createdAt: Date;
    updatedAt: Date;
}

interface UserRepository {
    save(user: User): Promise<User>;
    findById(id: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    findAll(limit?: number, offset?: number): Promise<User[]>;
    delete(id: string): Promise<boolean>;
}

class PostgresUserRepository implements UserRepository {
    private db: DatabaseService;
    private logger: Logger;

    constructor(db: DatabaseService) {
        this.db = db;
        this.logger = createLogger({ service: 'user-repository' });
    }

    async save(user: User): Promise<User> {
        const result = await this.db.query<User>(`
            INSERT INTO users (id, email, username, first_name, last_name, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT (id) DO UPDATE
            SET email = $2, username = $3, first_name = $4, last_name = $5, updated_at = $7
            RETURNING *
        `, [
            user.id,
            user.email,
            user.username,
            user.firstName,
            user.lastName,
            user.createdAt,
            user.updatedAt,
        ]);

        return result[0];
    }

    async findById(id: string): Promise<User | null> {
        const results = await this.db.query<User>(`
            SELECT * FROM users WHERE id = $1
        `, [id]);

        return results[0] || null;
    }

    async findByEmail(email: string): Promise<User | null> {
        const results = await this.db.query<User>(`
            SELECT * FROM users WHERE email = $1
        `, [email]);

        return results[0] || null;
    }

    async findAll(limit: number = 100, offset: number = 0): Promise<User[]> {
        return await this.db.query<User>(`
            SELECT * FROM users 
            ORDER BY created_at DESC 
            LIMIT $1 OFFSET $2
        `, [limit, offset]);
    }

    async delete(id: string): Promise<boolean> {
        const result = await this.db.query(`
            DELETE FROM users WHERE id = $1
        `, [id]);
        return result.length > 0;
    }
}
```

#### Specification Pattern

```typescript
interface Specification<T> {
    isSatisfiedBy(entity: T): boolean;
    toSQL(): { where: string; params: any[] };
}

class UserSpecification {
    static byEmail(email: string): Specification<User> {
        return {
            isSatisfiedBy: (user) => user.email === email,
            toSQL: () => ({
                where: 'email = $1',
                params: [email],
            }),
        };
    }

    static byUsername(username: string): Specification<User> {
        return {
            isSatisfiedBy: (user) => user.username === username,
            toSQL: () => ({
                where: 'username = $1',
                params: [username],
            }),
        };
    }

    static byActive(): Specification<User> {
        return {
            isSatisfiedBy: (user) => user.isActive === true,
            toSQL: () => ({
                where: 'is_active = true',
                params: [],
            }),
        };
    }

    static and(specs: Specification<User>[]): Specification<User> {
        return {
            isSatisfiedBy: (user) => specs.every(s => s.isSatisfiedBy(user)),
            toSQL: () => {
                const parts = specs.map(s => s.toSQL());
                return {
                    where: parts.map(p => p.where).join(' AND '),
                    params: parts.flatMap(p => p.params),
                };
            },
        };
    }

    static or(specs: Specification<User>[]): Specification<User> {
        return {
            isSatisfiedBy: (user) => specs.some(s => s.isSatisfiedBy(user)),
            toSQL: () => {
                const parts = specs.map(s => s.toSQL());
                return {
                    where: parts.map(p => p.where).join(' OR '),
                    params: parts.flatMap(p => p.params),
                };
            },
        };
    }
}

// Usage
class SpecificationUserRepository {
    constructor(private repository: UserRepository) {}

    async findOne(spec: Specification<User>): Promise<User | null> {
        const { where, params } = spec.toSQL();
        // This would require extending the repository to support specifications
        // Implementation depends on your repository layer
        return null;
    }

    async findAll(spec: Specification<User>): Promise<User[]> {
        const { where, params } = spec.toSQL();
        // Implementation depends on your repository layer
        return [];
    }
}
```

### 5. Eventual Consistency Patterns

#### Eventual Consistency Manager

```typescript
class EventualConsistencyManager {
    private pendingOperations: Map<string, PendingOperation> = new Map();
    private logger: Logger;
    private retryInterval: NodeJS.Timeout;

    constructor() {
        this.logger = createLogger({ service: 'eventual-consistency' });
        this.retryInterval = setInterval(() => this.processPending(), 5000);
    }

    async executeWithEventualConsistency<T>(
        operation: () => Promise<T>,
        compensation: () => Promise<void>,
        context: Record<string, any> = {}
    ): Promise<string> {
        const operationId = randomUUID();

        try {
            // Attempt operation
            const result = await operation();
            
            // Store successful operation
            this.pendingOperations.set(operationId, {
                id: operationId,
                status: 'pending',
                operation,
                compensation,
                context,
                result,
                attempts: 0,
                createdAt: new Date(),
                lastAttemptAt: new Date(),
            });

            this.logger.info({
                operationId,
                context,
            }, 'Operation queued for eventual consistency');

            return operationId;
        } catch (error) {
            this.logger.error({
                operationId,
                error,
                context,
            }, 'Operation failed, starting compensation');

            // Attempt compensation immediately
            try {
                await compensation();
            } catch (compensationError) {
                this.logger.error({
                    operationId,
                    error: compensationError,
                }, 'Compensation failed, manual intervention required');
            }

            throw error;
        }
    }

    private async processPending(): Promise<void> {
        for (const [id, operation] of this.pendingOperations) {
            if (operation.status === 'completed') {
                continue;
            }

            try {
                // Retry operation
                await operation.operation();
                operation.status = 'completed';
                operation.completedAt = new Date();

                this.logger.info({
                    operationId: id,
                    attempts: operation.attempts,
                }, 'Operation completed successfully');

            } catch (error) {
                operation.attempts++;
                operation.lastAttemptAt = new Date();

                this.logger.warn({
                    operationId: id,
                    attempts: operation.attempts,
                    error,
                }, 'Operation retry failed');

                if (operation.attempts >= 5) {
                    // Max retries exceeded, escalate to manual
                    operation.status = 'failed';
                    this.logger.error({
                        operationId: id,
                        error,
                    }, 'Operation failed, manual intervention required');

                    // Alert someone
                    await this.alertManualIntervention(id, error);
                }
            }
        }

        // Clean up completed operations after 1 hour
        const now = Date.now();
        for (const [id, operation] of this.pendingOperations) {
            if (operation.status === 'completed' && 
                operation.completedAt && 
                now - operation.completedAt.getTime() > 3600000) {
                this.pendingOperations.delete(id);
            }
        }
    }

    private async alertManualIntervention(
        operationId: string,
        error: unknown
    ): Promise<void> {
        // Send alert to monitoring system
        // Implementation depends on your alerting system
        console.error('Manual intervention required:', {
            operationId,
            error,
        });
    }

    getPendingOperations(): PendingOperation[] {
        return Array.from(this.pendingOperations.values());
    }

    getStatus(operationId: string): PendingOperation | null {
        return this.pendingOperations.get(operationId) || null;
    }

    async forceComplete(operationId: string): Promise<void> {
        const operation = this.pendingOperations.get(operationId);
        if (operation) {
            operation.status = 'completed';
            operation.completedAt = new Date();
        }
    }

    async forceRetry(operationId: string): Promise<void> {
        const operation = this.pendingOperations.get(operationId);
        if (operation) {
            operation.status = 'pending';
            operation.attempts = 0;
            operation.lastAttemptAt = new Date();
        }
    }
}

interface PendingOperation {
    id: string;
    status: 'pending' | 'completed' | 'failed';
    operation: () => Promise<any>;
    compensation: () => Promise<void>;
    context: Record<string, any>;
    result?: any;
    attempts: number;
    createdAt: Date;
    lastAttemptAt: Date;
    completedAt?: Date;
}
```

### 6. Key Takeaways

1. **Database Per Service:**
   - Each service owns its data
   - Independent schema evolution
   - Different databases for different services

2. **Data Replication:**
   - Primary-Replica for read scaling
   - Sharding for horizontal scaling
   - Multi-Master for high availability

3. **Data Access Patterns:**
   - Repository pattern abstracts data access
   - Specification pattern enables flexible queries
   - Unit of Work for transaction management

4. **Eventual Consistency:**
   - Accept that data may be stale
   - Design for compensation
   - Implement retry mechanisms
   - Monitor consistency lag

5. **Distributed Transactions:**
   - Use Sagas for multi-service transactions
   - Implement compensation logic
   - Handle partial failures

6. **Performance Considerations:**
   - Connection pooling
   - Query optimization
   - Indexing strategy
   - Caching layer

---

This primer provides a comprehensive understanding of database patterns and data management in distributed systems. Proper data management is critical for building scalable, reliable, and maintainable microservices.
