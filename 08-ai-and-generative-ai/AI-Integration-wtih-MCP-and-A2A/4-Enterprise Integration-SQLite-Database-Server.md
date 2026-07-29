# Part 4: Enterprise Integration — SQLite Database Server

## The Target

In this part, we're building an enterprise-grade MCP server that provides AI-powered database access to SQLite. This server will expose:

- **Database Tools** — Query, insert, update, delete, and schema management
- **Database Resources** — Schema information, table data, query results as resources
- **Prompt Templates** — SQL generation, query optimization, data analysis

This server will demonstrate how MCP provides a consistent interface for enterprise databases, enabling AI applications to interact with production data safely and securely.

## The Concept

### AI and Databases: The Perfect Partnership

Think of the database server as a **knowledge vault** guarded by a librarian (the MCP server). The AI (patron) can:

1. **Ask questions** (queries) and get answers
2. **Request specific books** (table data) as resources
3. **Get help finding information** (prompts)
4. **Make changes** (updates) with proper authorization

The librarian ensures:
- Only authorized requests are fulfilled (security)
- Queries are efficient (performance)
- Data is returned in a usable format (standardization)

### Enterprise Database Integration Patterns

MCP tools for databases typically fall into patterns:

1. **Read-Only Queries** — SELECT statements for data retrieval
2. **Write Operations** — INSERT, UPDATE, DELETE with validation
3. **Schema Management** — Tables, indexes, views
4. **Analytics** — Aggregations, reporting
5. **Data Export** — Resources that provide data in various formats

## The Implementation

### Step 1: Project Setup

**Target:** Initialize the SQLite database server project

**The Concept:** We need a dedicated project with SQLite dependencies, proper security configuration, and connection management.

**Implementation:**

```bash
cd ai-integration-javascript/mcp-protocol/servers
mkdir -p database-server
cd database-server
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk sqlite3 zod dotenv pino pino-pretty
npm install -D typescript @types/node @types/sqlite3 tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "resolveJsonModule": true,
    "isolatedModules": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/.env.example`

```env
# Server Configuration
NODE_ENV=development
LOG_LEVEL=info
MCP_SERVER_NAME=database-server
MCP_SERVER_VERSION=1.0.0

# Database Configuration
DB_PATH=./data/app.db
DB_READ_ONLY=false
DB_BACKUP_INTERVAL=3600000
DB_MAX_CONNECTIONS=10
DB_QUERY_TIMEOUT=30000

# Security
DB_ALLOW_DDL=true
DB_ALLOW_DROP=false
DB_QUERY_WHITELIST_ENABLED=false
DB_QUERY_BLACKLIST_ENABLED=true

# Auth
MCP_AUTH_ENABLED=false
MCP_API_KEYS=db_mcp_key_123456
```

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/package.json`

```json
{
  "name": "mcp-database-server",
  "version": "1.0.0",
  "description": "Enterprise SQLite database MCP server",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "start": "node dist/index.js",
    "start:dev": "tsx src/index.ts",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "db:init": "tsx src/scripts/init-db.ts",
    "db:seed": "tsx src/scripts/seed-db.ts",
    "db:backup": "tsx src/scripts/backup-db.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "sqlite3": "^5.1.6",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@types/sqlite3": "^3.1.9",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "eslint": "^8.55.0",
    "prettier": "^3.1.1",
    "tsx": "^4.6.0",
    "typescript": "^5.3.3",
    "vitest": "^1.0.4",
    "@vitest/coverage-v8": "^1.0.4"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### Step 2: Create Database Connection Manager

**Target:** Create a robust database connection manager with connection pooling and monitoring

**The Concept:** The connection manager handles database connections, query execution, security, and monitoring. It's the foundation for all database operations.

**Implementation:**

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/logger.ts`

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';
import path from 'path';
import fs from 'fs';

interface LoggerConfig {
  level: string;
  prettyPrint: boolean;
  baseLogDir: string;
}

const getEnvironmentConfig = (): { level: string; prettyPrint: boolean } => {
  const env = process.env.NODE_ENV || 'development';
  switch (env) {
    case 'production':
    case 'staging':
      return { level: 'info', prettyPrint: false };
    case 'development':
    default:
      return { level: 'debug', prettyPrint: true };
  }
};

const ensureLogDirectory = (logDir: string): void => {
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
};

const config: LoggerConfig = {
  level: process.env.LOG_LEVEL || getEnvironmentConfig().level,
  prettyPrint: getEnvironmentConfig().prettyPrint,
  baseLogDir: path.join(process.cwd(), 'logs')
};

ensureLogDirectory(config.baseLogDir);

export const createLogger = (context?: Record<string, unknown>) => {
  const requestId = randomUUID();
  const baseBindings = {
    requestId,
    service: process.env.MCP_SERVER_NAME || 'database-server',
    version: process.env.MCP_SERVER_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    ...context
  };

  const transports = pino.transport({
    targets: [
      {
        target: 'pino-pretty',
        level: config.level,
        options: {
          colorize: config.prettyPrint,
          translateTime: 'SYS:standard',
          ignore: 'pid,hostname',
          singleLine: !config.prettyPrint,
          hideObject: false
        }
      },
      ...(process.env.NODE_ENV === 'production' ? [{
        target: 'pino/file',
        level: 'info',
        options: {
          destination: path.join(config.baseLogDir, 'database-server.log'),
          mkdir: true
        }
      }] : [])
    ]
  });

  const rootLogger = pino(
    {
      level: config.level,
      base: {
        pid: process.pid,
        hostname: require('os').hostname()
      }
    },
    transports
  );

  return rootLogger.child(baseBindings);
};

export const logger = createLogger();
export const createModuleLogger = (moduleName: string) => {
  return logger.child({ module: moduleName });
};
```

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/db/connection-manager.ts`

```typescript
import sqlite3 from 'sqlite3';
import { promisify } from 'util';
import { createModuleLogger } from '../logger.js';
import fs from 'fs';
import path from 'path';

const logger = createModuleLogger('connection-manager');

/**
 * Database connection configuration
 */
export interface DBConfig {
  /** Path to SQLite database file */
  path: string;
  /** Read-only mode */
  readOnly: boolean;
  /** Maximum connections in pool */
  maxConnections: number;
  /** Query timeout in milliseconds */
  queryTimeout: number;
  /** Enable foreign key constraints */
  enableForeignKeys: boolean;
  /** Journal mode (WAL, DELETE, etc.) */
  journalMode: 'WAL' | 'DELETE' | 'TRUNCATE' | 'PERSIST' | 'MEMORY' | 'OFF';
}

/**
 * Database connection pool entry
 */
interface ConnectionEntry {
  connection: sqlite3.Database;
  lastUsed: number;
  inUse: boolean;
}

/**
 * Query result with metadata
 */
export interface QueryResult {
  /** Query execution ID */
  id: string;
  /** Query text */
  query: string;
  /** Parameters used */
  params: any[];
  /** Result rows */
  rows: any[];
  /** Number of rows affected (for write operations) */
  changes?: number;
  /** Last insert row ID */
  lastInsertRowid?: number;
  /** Query execution time in milliseconds */
  executionTime: number;
  /** Query plan (if available) */
  queryPlan?: string;
}

/**
 * Database connection manager with connection pooling and monitoring
 */
export class ConnectionManager {
  private config: DBConfig;
  private pool: ConnectionEntry[] = [];
  private readonly logger = createModuleLogger('connection-manager');
  private isConnected: boolean = false;
  private queryCounter: number = 0;
  private backupTimer?: NodeJS.Timeout;

  constructor(config: Partial<DBConfig> = {}) {
    // Set default configuration
    this.config = {
      path: config.path || process.env.DB_PATH || './data/app.db',
      readOnly: config.readOnly ?? process.env.DB_READ_ONLY === 'true',
      maxConnections: config.maxConnections || parseInt(process.env.DB_MAX_CONNECTIONS || '10'),
      queryTimeout: config.queryTimeout || parseInt(process.env.DB_QUERY_TIMEOUT || '30000'),
      enableForeignKeys: config.enableForeignKeys ?? true,
      journalMode: config.journalMode || 'WAL'
    };

    // Ensure the directory exists
    const dbDir = path.dirname(this.config.path);
    if (!fs.existsSync(dbDir)) {
      fs.mkdirSync(dbDir, { recursive: true });
    }

    this.logger.info('Connection manager initialized', {
      dbPath: this.config.path,
      readOnly: this.config.readOnly,
      maxConnections: this.config.maxConnections
    });

    // Schedule periodic backups
    const backupInterval = parseInt(process.env.DB_BACKUP_INTERVAL || '3600000');
    if (backupInterval > 0 && !this.config.readOnly) {
      this.backupTimer = setInterval(() => {
        this.backup().catch(error => {
          this.logger.error('Scheduled backup failed', { error: error.message });
        });
      }, backupInterval);
      this.logger.info('Scheduled backups enabled', { interval: backupInterval });
    }
  }

  /**
   * Initialize the database connection
   */
  async initialize(): Promise<void> {
    this.logger.info('Initializing database connection');
    
    try {
      // Create initial connections
      const initialConnections = Math.min(this.config.maxConnections, 3);
      for (let i = 0; i < initialConnections; i++) {
        const connection = await this.createConnection();
        this.pool.push({
          connection,
          lastUsed: Date.now(),
          inUse: false
        });
      }

      this.isConnected = true;
      
      // Enable WAL mode for better performance
      await this.executePragma('journal_mode', this.config.journalMode);
      
      // Enable foreign keys
      if (this.config.enableForeignKeys) {
        await this.executePragma('foreign_keys', 'ON');
      }

      this.logger.info('Database initialized successfully', {
        poolSize: this.pool.length
      });

    } catch (error) {
      this.logger.error('Failed to initialize database', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw error;
    }
  }

  /**
   * Create a database connection
   */
  private createConnection(): Promise<sqlite3.Database> {
    return new Promise((resolve, reject) => {
      const db = new sqlite3.Database(
        this.config.path,
        this.config.readOnly ? sqlite3.OPEN_READONLY : sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE,
        (err) => {
          if (err) {
            reject(err);
          } else {
            resolve(db);
          }
        }
      );
    });
  }

  /**
   * Execute a PRAGMA statement
   */
  private async executePragma(key: string, value: string | number): Promise<void> {
    const connection = await this.getConnection();
    return new Promise((resolve, reject) => {
      connection.run(`PRAGMA ${key} = ${value}`, (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  /**
   * Get a connection from the pool
   */
  private async getConnection(): Promise<sqlite3.Database> {
    // Find an available connection
    const available = this.pool.find(entry => !entry.inUse);
    if (available) {
      available.inUse = true;
      available.lastUsed = Date.now();
      return available.connection;
    }

    // Create new connection if pool is not full
    if (this.pool.length < this.config.maxConnections) {
      const connection = await this.createConnection();
      this.pool.push({
        connection,
        lastUsed: Date.now(),
        inUse: true
      });
      this.logger.debug('Created new connection', {
        poolSize: this.pool.length
      });
      return connection;
    }

    // Wait for a connection to become available
    this.logger.debug('Waiting for available connection');
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error('Connection pool timeout'));
      }, this.config.queryTimeout);

      const checkPool = () => {
        const available = this.pool.find(entry => !entry.inUse);
        if (available) {
          clearTimeout(timeout);
          available.inUse = true;
          available.lastUsed = Date.now();
          resolve(available.connection);
        } else {
          setTimeout(checkPool, 100);
        }
      };

      checkPool();
    });
  }

  /**
   * Release a connection back to the pool
   */
  private releaseConnection(connection: sqlite3.Database): void {
    const entry = this.pool.find(e => e.connection === connection);
    if (entry) {
      entry.inUse = false;
      entry.lastUsed = Date.now();
    }
  }

  /**
   * Execute a query with parameter binding and timeout
   */
  async executeQuery(sql: string, params: any[] = []): Promise<QueryResult> {
    const startTime = Date.now();
    const queryId = `q-${++this.queryCounter}-${Date.now()}`;

    this.logger.debug('Executing query', {
      queryId,
      sql: sql.substring(0, 200),
      params,
      paramCount: params.length
    });

    // Security: Check for dangerous queries
    this.validateQuery(sql);

    let connection: sqlite3.Database | null = null;
    let timeoutId: NodeJS.Timeout | null = null;

    try {
      connection = await this.getConnection();

      // Set up timeout
      const queryPromise = new Promise<{ rows: any[]; changes?: number; lastInsertRowid?: number }>(
        (resolve, reject) => {
          const callback = (err: Error | null, rows?: any[]) => {
            if (err) {
              reject(err);
            } else {
              resolve({ rows: rows || [] });
            }
          };

          if (this.isReadOnlyQuery(sql)) {
            // For SELECT queries
            connection.all(sql, params, callback);
          } else {
            // For INSERT, UPDATE, DELETE queries
            const runCallback = function(this: sqlite3.Database, err: Error | null) {
              if (err) {
                reject(err);
              } else {
                resolve({
                  rows: [],
                  changes: this.changes,
                  lastInsertRowid: this.lastID
                });
              }
            };

            connection.run(sql, params, runCallback);
          }
        }
      );

      // Execute with timeout
      const timeoutPromise = new Promise((_, reject) => {
        timeoutId = setTimeout(() => {
          reject(new Error(`Query timeout after ${this.config.queryTimeout}ms`));
        }, this.config.queryTimeout);
      });

      const result = await Promise.race([queryPromise, timeoutPromise]) as any;

      // Clear timeout
      if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }

      const executionTime = Date.now() - startTime;

      const queryResult: QueryResult = {
        id: queryId,
        query: sql,
        params,
        rows: result.rows || [],
        changes: result.changes,
        lastInsertRowid: result.lastInsertRowid,
        executionTime
      };

      this.logger.debug('Query executed successfully', {
        queryId,
        rowCount: result.rows?.length || 0,
        executionTime,
        changes: result.changes
      });

      // Release the connection
      if (connection) {
        this.releaseConnection(connection);
        connection = null;
      }

      return queryResult;

    } catch (error) {
      // Clear timeout
      if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }

      // Release connection if we have one
      if (connection) {
        this.releaseConnection(connection);
        connection = null;
      }

      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Query execution failed', {
        queryId,
        sql: sql.substring(0, 200),
        error: errorMsg
      });

      throw new Error(`Query failed: ${errorMsg}`);
    }
  }

  /**
   * Validate query for security
   * Prevents dangerous operations based on configuration
   */
  private validateQuery(sql: string): void {
    const normalized = sql.toLowerCase();

    // Check for DROP statements
    if (!this.config.readOnly && !(process.env.DB_ALLOW_DROP === 'true')) {
      if (normalized.includes('drop table') || normalized.includes('drop index') || 
          normalized.includes('drop trigger') || normalized.includes('drop view')) {
        throw new Error('DROP statements are not allowed');
      }
    }

    // Check for DDL (CREATE, ALTER, DROP) if disabled
    if (!this.config.readOnly && !(process.env.DB_ALLOW_DDL === 'true')) {
      const ddlPattern = /\b(create|alter|drop)\s+(table|index|trigger|view)\b/i;
      if (ddlPattern.test(normalized)) {
        throw new Error('DDL operations are not allowed');
      }
    }

    // Check query whitelist
    if (process.env.DB_QUERY_WHITELIST_ENABLED === 'true') {
      const whitelist = (process.env.DB_QUERY_WHITELIST || '').split(',').filter(Boolean);
      if (whitelist.length > 0) {
        const allowed = whitelist.some(pattern => normalized.includes(pattern.toLowerCase()));
        if (!allowed) {
          throw new Error('Query not in whitelist');
        }
      }
    }

    // Check query blacklist
    if (process.env.DB_QUERY_BLACKLIST_ENABLED !== 'false') {
      const blacklist = (process.env.DB_QUERY_BLACKLIST || '').split(',').filter(Boolean);
      const defaultBlacklist = ['drop', 'truncate', 'delete from', 'update'];
      const allBlacklist = [...defaultBlacklist, ...blacklist];
      
      const blocked = allBlacklist.some(pattern => normalized.includes(pattern.toLowerCase()));
      if (blocked) {
        throw new Error('Query contains blacklisted pattern');
      }
    }
  }

  /**
   * Check if query is read-only
   */
  private isReadOnlyQuery(sql: string): boolean {
    const normalized = sql.trim().toLowerCase();
    return normalized.startsWith('select') || 
           normalized.startsWith('with') ||
           normalized.startsWith('pragma') ||
           normalized.startsWith('explain');
  }

  /**
   * Get database schema information
   */
  async getSchema(): Promise<{
    tables: Array<{ name: string; columns: Array<{ name: string; type: string; notNull: boolean; defaultValue: any; primaryKey: boolean }> }>;
    indexes: Array<{ name: string; table: string; columns: string[]; unique: boolean }>;
    views: Array<{ name: string; sql: string }>;
  }> {
    this.logger.debug('Fetching database schema');

    // Get tables
    const tablesResult = await this.executeQuery(
      `SELECT name, sql FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'`
    );

    const tables: any[] = [];

    for (const table of tablesResult.rows) {
      // Get table columns
      const pragmaResult = await this.executeQuery(`PRAGMA table_info(${table.name})`);
      
      const columns = pragmaResult.rows.map((col: any) => ({
        name: col.name,
        type: col.type,
        notNull: col.notnull === 1,
        defaultValue: col.dflt_value,
        primaryKey: col.pk === 1
      }));

      tables.push({
        name: table.name,
        columns,
        sql: table.sql
      });
    }

    // Get indexes
    const indexesResult = await this.executeQuery(
      `SELECT name, tbl_name, sql FROM sqlite_master WHERE type = 'index' AND name NOT LIKE 'sqlite_%'`
    );

    const indexes = [];
    for (const idx of indexesResult.rows) {
      const pragmaResult = await this.executeQuery(`PRAGMA index_info(${idx.name})`);
      indexes.push({
        name: idx.name,
        table: idx.tbl_name,
        columns: pragmaResult.rows.map((col: any) => col.name),
        unique: idx.sql?.toLowerCase().includes('unique') || false
      });
    }

    // Get views
    const viewsResult = await this.executeQuery(
      `SELECT name, sql FROM sqlite_master WHERE type = 'view' AND name NOT LIKE 'sqlite_%'`
    );

    this.logger.debug('Schema fetched', {
      tableCount: tables.length,
      indexCount: indexes.length,
      viewCount: viewsResult.rows.length
    });

    return {
      tables,
      indexes,
      views: viewsResult.rows
    };
  }

  /**
   * Backup the database
   */
  async backup(): Promise<string> {
    if (this.config.readOnly) {
      throw new Error('Cannot backup read-only database');
    }

    const backupDir = path.join(path.dirname(this.config.path), 'backups');
    if (!fs.existsSync(backupDir)) {
      fs.mkdirSync(backupDir, { recursive: true });
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const backupPath = path.join(backupDir, `backup-${timestamp}.db`);

    this.logger.info('Creating database backup', { backupPath });

    // Get a connection for backup
    const connection = await this.getConnection();
    
    try {
      // Use SQLite backup API
      const backupDb = await this.createConnection();
      
      return new Promise((resolve, reject) => {
        connection.backup(backupPath, (err) => {
          if (err) {
            reject(err);
          } else {
            this.logger.info('Backup created successfully', {
              backupPath,
              size: fs.statSync(backupPath).size
            });
            resolve(backupPath);
          }
        });
      });
    } catch (error) {
      this.logger.error('Backup failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw error;
    } finally {
      this.releaseConnection(connection);
    }
  }

  /**
   * Close all connections and cleanup
   */
  async close(): Promise<void> {
    this.logger.info('Closing all database connections');

    if (this.backupTimer) {
      clearInterval(this.backupTimer);
      this.backupTimer = undefined;
    }

    const closePromises = this.pool.map(entry => {
      return new Promise<void>((resolve) => {
        entry.connection.close((err) => {
          if (err) {
            this.logger.warn('Error closing connection', {
              error: err.message
            });
          }
          resolve();
        });
      });
    });

    await Promise.all(closePromises);
    this.pool = [];
    this.isConnected = false;

    this.logger.info('All connections closed');
  }

  /**
   * Check if connected to database
   */
  isConnectedToDatabase(): boolean {
    return this.isConnected;
  }

  /**
   * Get connection statistics
   */
  getStats(): {
    poolSize: number;
    activeConnections: number;
    totalQueries: number;
    isConnected: boolean;
    config: DBConfig;
  } {
    const activeConnections = this.pool.filter(e => e.inUse).length;
    
    return {
      poolSize: this.pool.length,
      activeConnections,
      totalQueries: this.queryCounter,
      isConnected: this.isConnected,
      config: { ...this.config }
    };
  }
}

/**
 * Singleton instance of the connection manager
 */
let connectionManager: ConnectionManager | null = null;

export const getConnectionManager = (): ConnectionManager => {
  if (!connectionManager) {
    connectionManager = new ConnectionManager();
  }
  return connectionManager;
};
```

### Step 3: Implement Database Tools

**Target:** Create MCP tools for database operations

**The Concept:** Each tool represents a specific database operation. We'll create tools for queries, schema management, and data export.

**Implementation:**

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/tools/query-tools.ts`

```typescript
import { z } from 'zod';
import { getConnectionManager } from '../db/connection-manager.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('query-tools');

/**
 * Create query execution tool
 * Allows AI to execute SQL queries with parameters
 */
export const createQueryTool = () => ({
  name: 'execute_query',
  description: 'Execute a SQL query against the database with parameter binding',
  inputSchema: {
    type: 'object',
    properties: {
      sql: {
        type: 'string',
        description: 'The SQL query to execute (SELECT, INSERT, UPDATE, or DELETE)'
      },
      params: {
        type: 'array',
        description: 'Parameters to bind to the query (use ? placeholders)',
        items: {
          type: 'any'
        }
      },
      limit: {
        type: 'integer',
        description: 'Maximum number of rows to return (for SELECT queries)',
        minimum: 1,
        maximum: 10000
      }
    },
    required: ['sql']
  },
  handler: async ({ sql, params = [], limit }: { sql: string; params?: any[]; limit?: number }) => {
    logger.debug('Executing query tool', { sql: sql.substring(0, 100), params, limit });

    const db = getConnectionManager();

    try {
      // If limit is provided and it's a SELECT query, add LIMIT clause
      let query = sql;
      if (limit && query.trim().toLowerCase().startsWith('select')) {
        query = `${query} LIMIT ${limit}`;
      }

      const result = await db.executeQuery(query, params);

      // Format response
      let responseText = `Query executed successfully in ${result.executionTime}ms\n`;
      responseText += `Rows returned: ${result.rows.length}\n`;

      if (result.changes !== undefined) {
        responseText += `Rows affected: ${result.changes}\n`;
      }

      if (result.lastInsertRowid) {
        responseText += `Last insert row ID: ${result.lastInsertRowid}\n`;
      }

      // Include the data
      if (result.rows.length > 0) {
        responseText += '\nData:\n';
        responseText += JSON.stringify(result.rows, null, 2);
      }

      return {
        content: [
          {
            type: 'text',
            text: responseText
          },
          {
            type: 'text',
            text: JSON.stringify({
              success: true,
              rowCount: result.rows.length,
              executionTime: result.executionTime,
              changes: result.changes,
              lastInsertRowid: result.lastInsertRowid,
              data: result.rows
            }, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Query execution failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Query execution failed: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});

/**
 * Create schema inspection tool
 * Gets information about database schema
 */
export const createSchemaTool = () => ({
  name: 'get_schema',
  description: 'Get database schema information including tables, columns, indexes, and views',
  inputSchema: {
    type: 'object',
    properties: {
      table: {
        type: 'string',
        description: 'Specific table to get schema for (optional)'
      },
      includeData: {
        type: 'boolean',
        description: 'Include sample data for each table',
        default: false
      }
    }
  },
  handler: async ({ table, includeData = false }: { table?: string; includeData?: boolean }) => {
    logger.debug('Getting schema', { table, includeData });

    const db = getConnectionManager();

    try {
      const schema = await db.getSchema();

      // Filter by table if specified
      let tables = schema.tables;
      if (table) {
        tables = tables.filter(t => t.name === table);
        if (tables.length === 0) {
          throw new Error(`Table '${table}' not found`);
        }
      }

      let responseText = `Database Schema\n`;
      responseText += `Total tables: ${schema.tables.length}\n`;
      responseText += `Total indexes: ${schema.indexes.length}\n`;
      responseText += `Total views: ${schema.views.length}\n\n`;

      // Include sample data if requested
      if (includeData) {
        for (const t of tables) {
          const sampleResult = await db.executeQuery(
            `SELECT * FROM ${t.name} LIMIT 5`
          );
          (t as any).sampleData = sampleResult.rows;
        }
      }

      responseText += JSON.stringify({ tables, indexes: schema.indexes, views: schema.views }, null, 2);

      return {
        content: [
          {
            type: 'text',
            text: responseText
          },
          {
            type: 'text',
            text: JSON.stringify({
              tables: tables,
              indexes: schema.indexes,
              views: schema.views
            }, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Schema retrieval failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Schema retrieval failed: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});

/**
 * Create table creation tool
 * Creates a new table with specified columns
 */
export const createTableTool = () => ({
  name: 'create_table',
  description: 'Create a new table in the database',
  inputSchema: {
    type: 'object',
    properties: {
      tableName: {
        type: 'string',
        description: 'Name of the table to create',
        pattern: '^[a-zA-Z_][a-zA-Z0-9_]*$'
      },
      columns: {
        type: 'array',
        description: 'Column definitions',
        items: {
          type: 'object',
          properties: {
            name: {
              type: 'string',
              description: 'Column name',
              pattern: '^[a-zA-Z_][a-zA-Z0-9_]*$'
            },
            type: {
              type: 'string',
              description: 'SQLite data type (TEXT, INTEGER, REAL, BLOB, etc.)'
            },
            nullable: {
              type: 'boolean',
              description: 'Whether the column can be NULL',
              default: true
            },
            primaryKey: {
              type: 'boolean',
              description: 'Whether this is a primary key',
              default: false
            },
            autoIncrement: {
              type: 'boolean',
              description: 'Whether the column auto-increments (requires primaryKey)',
              default: false
            },
            defaultValue: {
              type: 'any',
              description: 'Default value for the column'
            }
          },
          required: ['name', 'type']
        },
        minItems: 1
      }
    },
    required: ['tableName', 'columns']
  },
  handler: async ({ tableName, columns }: { tableName: string; columns: any[] }) => {
    logger.debug('Creating table', { tableName, columns });

    const db = getConnectionManager();

    try {
      // Build CREATE TABLE statement
      const columnDefs = columns.map(col => {
        let def = `${col.name} ${col.type}`;
        if (col.primaryKey) {
          def += ' PRIMARY KEY';
          if (col.autoIncrement) {
            def += ' AUTOINCREMENT';
          }
        }
        if (!col.nullable) {
          def += ' NOT NULL';
        }
        if (col.defaultValue !== undefined) {
          def += ` DEFAULT ${typeof col.defaultValue === 'string' ? `'${col.defaultValue}'` : col.defaultValue}`;
        }
        return def;
      });

      const sql = `CREATE TABLE IF NOT EXISTS ${tableName} (\n  ${columnDefs.join(',\n  ')}\n)`;

      await db.executeQuery(sql);

      logger.info('Table created successfully', { tableName });

      return {
        content: [
          {
            type: 'text',
            text: `Table '${tableName}' created successfully with ${columns.length} columns`
          },
          {
            type: 'text',
            text: JSON.stringify({
              success: true,
              tableName,
              columns,
              sql
            }, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Table creation failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Table creation failed: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});
```

### Step 4: Implement Database Resources

**Target:** Create MCP resources that provide database data as resources

**The Concept:** Resources allow AI to "read" database data like files. We'll expose table data and query results as resources.

**Implementation:**

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/resources/database-resources.ts`

```typescript
import { getConnectionManager } from '../db/connection-manager.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('database-resources');

/**
 * Create table data resource
 * Allows AI to read table data as a resource
 */
export const createTableResource = () => ({
  scheme: 'table',
  handler: async (uri: string) => {
    // Extract table name from URI: table://{tableName}
    const tableName = uri.replace('table://', '');
    
    logger.debug('Reading table resource', { uri, tableName });

    const db = getConnectionManager();

    try {
      // Get table schema
      const schema = await db.getSchema();
      const table = schema.tables.find(t => t.name === tableName);
      
      if (!table) {
        throw new Error(`Table '${tableName}' not found`);
      }

      // Get table data (limit to 1000 rows for safety)
      const result = await db.executeQuery(
        `SELECT * FROM ${tableName} LIMIT 1000`
      );

      // Format as JSON
      const data = {
        table: tableName,
        columns: table.columns,
        rowCount: result.rows.length,
        data: result.rows,
        schema: table
      };

      return {
        contents: [
          {
            uri,
            text: JSON.stringify(data, null, 2),
            mimeType: 'application/json'
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Table resource read failed', { uri, error: errorMsg });
      throw new Error(`Failed to read table resource: ${errorMsg}`);
    }
  }
});

/**
 * Create query result resource
 * Allows AI to execute a query and get results as a resource
 */
export const createQueryResource = () => ({
  scheme: 'query',
  handler: async (uri: string) => {
    // Parse URI: query://{encoded_query}
    const encodedQuery = uri.replace('query://', '');
    const query = decodeURIComponent(encodedQuery);
    
    logger.debug('Reading query resource', { uri, query });

    const db = getConnectionManager();

    try {
      // Execute the query with a limit
      const result = await db.executeQuery(
        `${query} LIMIT 1000`
      );

      const data = {
        query,
        rowCount: result.rows.length,
        executionTime: result.executionTime,
        data: result.rows
      };

      return {
        contents: [
          {
            uri,
            text: JSON.stringify(data, null, 2),
            mimeType: 'application/json'
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Query resource read failed', { uri, error: errorMsg });
      throw new Error(`Failed to read query resource: ${errorMsg}`);
    }
  }
});

/**
 * Create schema resource
 * Provides database schema as a resource
 */
export const createSchemaResource = () => ({
  scheme: 'schema',
  handler: async (uri: string) => {
    logger.debug('Reading schema resource', { uri });

    const db = getConnectionManager();

    try {
      const schema = await db.getSchema();

      return {
        contents: [
          {
            uri,
            text: JSON.stringify(schema, null, 2),
            mimeType: 'application/json'
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Schema resource read failed', { uri, error: errorMsg });
      throw new Error(`Failed to read schema resource: ${errorMsg}`);
    }
  }
});
```

### Step 5: Create the Server

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/server.ts`

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { createLogger, createModuleLogger } from './logger.js';
import { getConnectionManager } from './db/connection-manager.js';
import { createQueryTool, createSchemaTool, createTableTool } from './tools/query-tools.js';
import { createTableResource, createQueryResource, createSchemaResource } from './resources/database-resources.js';

const logger = createModuleLogger('database-server');

/**
 * Database MCP Server
 * Provides AI access to SQLite databases
 */
export class DatabaseServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Database Server');

    this.server = new McpServer({
      name: process.env.MCP_SERVER_NAME || 'database-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0',
      capabilities: {
        tools: {},
        resources: {},
        prompts: {}
      }
    });

    // Initialize database connection
    this.initializeDatabase();

    // Register tools, resources, and prompts
    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Database Server initialized successfully');
  }

  /**
   * Initialize the database connection
   */
  private async initializeDatabase(): Promise<void> {
    try {
      const db = getConnectionManager();
      await db.initialize();
      logger.info('Database initialized successfully');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Database initialization failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Register all database tools
   */
  private registerTools(): void {
    logger.info('Registering database tools');

    // Query execution tool
    this.server.tool(
      'execute_query',
      {
        sql: z.string().describe('The SQL query to execute'),
        params: z.array(z.any()).optional().describe('Query parameters'),
        limit: z.number().optional().describe('Maximum rows to return')
      },
      createQueryTool().handler
    );

    // Schema inspection tool
    this.server.tool(
      'get_schema',
      {
        table: z.string().optional().describe('Specific table to inspect'),
        includeData: z.boolean().optional().describe('Include sample data')
      },
      createSchemaTool().handler
    );

    // Table creation tool
    this.server.tool(
      'create_table',
      {
        tableName: z.string().describe('Name of the table to create'),
        columns: z.array(z.object({
          name: z.string(),
          type: z.string(),
          nullable: z.boolean().optional(),
          primaryKey: z.boolean().optional(),
          autoIncrement: z.boolean().optional(),
          defaultValue: z.any().optional()
        })).describe('Column definitions')
      },
      createTableTool().handler
    );

    logger.info('Database tools registered successfully');
  }

  /**
   * Register all database resources
   */
  private registerResources(): void {
    logger.info('Registering database resources');

    // Table data resources: table://{tableName}
    const tableResource = createTableResource();
    this.server.resource(
      'table_data',
      'table://*',
      {
        description: 'Table data resource',
        mimeType: 'application/json'
      },
      async (uri: string) => {
        return tableResource.handler(uri);
      }
    );

    // Query result resources: query://{encoded_query}
    const queryResource = createQueryResource();
    this.server.resource(
      'query_result',
      'query://*',
      {
        description: 'Query result resource',
        mimeType: 'application/json'
      },
      async (uri: string) => {
        return queryResource.handler(uri);
      }
    );

    // Schema resource: schema://info
    const schemaResource = createSchemaResource();
    this.server.resource(
      'schema_info',
      'schema://info',
      {
        description: 'Database schema information',
        mimeType: 'application/json'
      },
      async (uri: string) => {
        return schemaResource.handler(uri);
      }
    );

    logger.info('Database resources registered successfully');
  }

  /**
   * Register all database prompts
   */
  private registerPrompts(): void {
    logger.info('Registering database prompts');

    // SQL Generation prompt
    this.server.prompt(
      'generate_sql',
      {
        description: z.string().describe('Description of what the SQL should do'),
        tables: z.string().optional().describe('Relevant tables'),
        dialect: z.string().optional().default('sqlite').describe('SQL dialect')
      },
      ({ description, tables, dialect }) => {
        logger.debug('Generating SQL prompt', { description, tables, dialect });

        const prompt = `You are a SQL expert. Generate a SQL query for the following requirement:

Description: ${description}
${tables ? `Relevant tables: ${tables}` : ''}
Dialect: ${dialect}

Please provide:
1. The SQL query
2. Explanation of what it does
3. Any assumptions made
4. Sample output format

Make the query efficient and use appropriate indexes if needed.`;

        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: prompt
              }
            }
          ]
        };
      }
    );

    // Data Analysis prompt
    this.server.prompt(
      'analyze_data',
      {
        table: z.string().describe('Table to analyze'),
        columns: z.string().optional().describe('Columns to analyze (comma-separated)'),
        analysisType: z.enum(['summary', 'trends', 'anomalies', 'correlations']).describe('Type of analysis')
      },
      ({ table, columns, analysisType }) => {
        logger.debug('Generating analysis prompt', { table, columns, analysisType });

        const prompt = `You are a data analyst. Analyze the data from the '${table}' table${columns ? ` (columns: ${columns})` : ''}.

Analysis type: ${analysisType}

Please perform the following analysis:
1. ${analysisType === 'summary' ? 'Provide summary statistics (count, mean, median, min, max, distribution)' :
    analysisType === 'trends' ? 'Identify trends and patterns over time' :
    analysisType === 'anomalies' ? 'Detect anomalies and outliers' :
    'Find correlations between variables'}

2. Provide actionable insights
3. Suggest further analysis
4. Recommend visualizations

Use the available tools to query the database as needed.`;

        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: prompt
              }
            }
          ]
        };
      }
    );

    // Data Migration prompt
    this.server.prompt(
      'migrate_data',
      {
        sourceTable: z.string().describe('Source table'),
        targetTable: z.string().describe('Target table'),
        mapping: z.string().optional().describe('Column mapping'),
        batchSize: z.number().optional().default(1000).describe('Batch size for migration')
      },
      ({ sourceTable, targetTable, mapping, batchSize }) => {
        logger.debug('Generating migration prompt', { sourceTable, targetTable, mapping, batchSize });

        const prompt = `You are a database migration expert. Migrate data from '${sourceTable}' to '${targetTable}'.

${mapping ? `Column mapping: ${mapping}` : 'Use direct column mapping where column names match'}

Migration details:
- Batch size: ${batchSize} rows
- Preserve data integrity
- Handle conflicts appropriately
- Log progress

Please provide:
1. Migration SQL statements
2. Validation steps
3. Rollback plan
4. Performance considerations

Use the available tools to query and modify the database.`;

        return {
          messages: [
            {
              role: 'assistant',
              content: {
                type: 'text',
                text: prompt
              }
            }
          ]
        };
      }
    );

    logger.info('Database prompts registered successfully');
  }

  /**
   * Start the server
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server is already running');
      return;
    }

    logger.info('Starting Database Server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;

      logger.info('Database Server started successfully');
      console.error('MCP Database Server is running and waiting for connections...');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start Database Server', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Stop the server
   */
  async stop(): Promise<void> {
    if (!this.isRunning) {
      logger.warn('Server is not running');
      return;
    }

    logger.info('Stopping Database Server...');

    try {
      // Close database connections
      const db = getConnectionManager();
      await db.close();

      this.isRunning = false;
      logger.info('Database Server stopped successfully');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop Database Server', { error: errorMsg });
      throw error;
    }
  }
}
```

### Step 6: Create Entry Point and Database Initialization Scripts

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { DatabaseServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const handleShutdown = async (server: DatabaseServer): Promise<void> => {
  logger.info('Received shutdown signal, cleaning up...');
  try {
    await server.stop();
    setTimeout(() => process.exit(0), 100);
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Error during shutdown', { error: errorMsg });
    process.exit(1);
  }
};

const main = async (): Promise<void> => {
  logger.info('Starting Database Server entry point');

  try {
    const server = new DatabaseServer();

    process.on('SIGINT', () => void handleShutdown(server));
    process.on('SIGTERM', () => void handleShutdown(server));

    process.on('uncaughtException', (error) => {
      logger.fatal('Uncaught exception', { error: error.message, stack: error.stack });
      process.exit(1);
    });

    process.on('unhandledRejection', (reason) => {
      logger.fatal('Unhandled rejection', { reason });
      process.exit(1);
    });

    await server.start();

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

if (import.meta.url === `file://${process.argv[1]}`) {
  void main();
}

export { DatabaseServer };
```

**File:** `ai-integration-javascript/mcp-protocol/servers/database-server/src/scripts/init-db.ts`

```typescript
#!/usr/bin/env node

/**
 * Initialize the database with tables
 */
import dotenv from 'dotenv';
dotenv.config();

import { getConnectionManager } from '../db/connection-manager.js';
import { createLogger } from '../logger.js';

const logger = createLogger();

const initDb = async () => {
  logger.info('Initializing database schema');

  try {
    const db = getConnectionManager();
    await db.initialize();

    // Create sample tables
    const queries = [
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      `CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT,
        stock INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      `CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        total REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )`,

      `CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )`,

      `CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)`,
      `CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id)`,
      `CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id)`,
      `CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id)`
    ];

    for (const query of queries) {
      await db.executeQuery(query);
      logger.debug('Executed query', { query: query.substring(0, 100) });
    }

    logger.info('Database schema initialized successfully');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Database initialization failed', { error: errorMsg });
    process.exit(1);
  }
};

await initDb();
process.exit(0);
```

## The Verification

### Step 1: Build the Server

```bash
cd ai-integration-javascript/mcp-protocol/servers/database-server
npm install
npm run build
```

### Step 2: Initialize the Database

```bash
npm run db:init
```

### Step 3: Start the Server

```bash
npm start
```

### Step 4: Test with Client

Create a test script:

**File:** `test-db-client.js`

```javascript
import { createMCPClient } from '../clients/mcp-client-lib/dist/index.js';

const client = createMCPClient({
  servers: [{
    id: 'db-server',
    transport: {
      type: 'stdio',
      command: 'node',
      args: ['dist/index.js']
    }
  }]
});

await client.connectAll();

// Test query
const result = await client.callTool('db-server', 'execute_query', {
  sql: 'SELECT * FROM users',
  limit: 5
});
console.log('Query result:', result);

// Test schema
const schema = await client.callTool('db-server', 'get_schema', {});
console.log('Schema:', schema);

// Create a table
const createResult = await client.callTool('db-server', 'create_table', {
  tableName: 'test_table',
  columns: [
    { name: 'id', type: 'INTEGER', primaryKey: true, autoIncrement: true },
    { name: 'name', type: 'TEXT', nullable: false },
    { name: 'value', type: 'REAL' }
  ]
});
console.log('Table creation:', createResult);

await client.disconnectAll();
```

Expected output showing successful database operations.

## What You've Built

You've built an enterprise-grade SQLite database MCP server with:

### Features
1. **Connection Pooling** — Efficient connection management
2. **Query Execution** — Parameterized queries with timeout protection
3. **Schema Management** — Table creation and inspection
4. **Security** — Query validation, whitelist/blacklist support
5. **Resources** — Table data, query results, schema as resources
6. **Prompts** — SQL generation, data analysis, migration
7. **Backup** — Automatic database backups
8. **Monitoring** — Connection statistics and logging

## Key Takeaways

1. **Security First** — Always validate and sanitize queries
2. **Connection Management** — Pooling improves performance
3. **Parameter Binding** — Prevents SQL injection
4. **Timeout Protection** — Prevents hung queries
5. **Resource Abstraction** — Data as resources simplifies access
6. **Production Ready** — Logging, monitoring, backup
7. **Flexible** — Works with any SQLite database

## What's Next?

In **Part 5**, we'll integrate PostgreSQL for production-grade databases, add advanced query optimization, and implement read replicas for scalability.
