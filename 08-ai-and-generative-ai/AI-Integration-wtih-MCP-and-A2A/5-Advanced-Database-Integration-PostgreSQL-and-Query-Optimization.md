# Part 5: Advanced Database Integration — PostgreSQL and Query Optimization

## The Target

In this part, we're building a production-grade PostgreSQL MCP server that brings enterprise database capabilities to AI agents. This server will feature:

- **PostgreSQL Connection Management** — Connection pooling with transaction support
- **Query Tools** — Read and write operations with safety classifications
- **Schema Introspection** — Comprehensive table and column metadata
- **Query Optimization** — EXPLAIN analysis and index recommendations
- **Resources** — Schema data, table rows, and query results as AI-accessible resources
- **Prompts** — SQL generation, query tuning, and data migration guidance

## The Concept

### Why PostgreSQL for AI Applications

PostgreSQL is the world's most advanced open-source relational database, and it's a natural fit for AI applications. Here's why :

1. **Rich Data Types** — JSON, arrays, full-text search, geospatial data, and vector embeddings (pgvector)
2. **Advanced Indexing** — B-tree, hash, GiST, SP-GiST, GIN, and BRIN indexes
3. **Extensibility** — Custom functions, operators, and extensions
4. **ACID Compliance** — Reliable transaction support for critical operations
5. **Performance** — Query optimization, parallel execution, and partitioning

### Security Classifications for Database Operations

Production database servers should separate operations by risk level :

| Risk Level | Operations | Approval Required |
|------------|------------|-------------------|
| **Read-Only** | `SELECT`, `SHOW`, `EXPLAIN`, `VALUES` | Auto-approved |
| **Read-Write** | `INSERT`, `UPDATE`, `DELETE`, `MERGE` | User confirmation |
| **Admin/DDL** | `CREATE`, `ALTER`, `DROP`, `GRANT` | Elevated permission |

## The Implementation

### Step 1: Project Setup

```bash
cd ai-integration-javascript/mcp-protocol/servers
mkdir -p postgres-server
cd postgres-server
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk pg pg-pool zod dotenv pino pino-pretty
npm install -D typescript @types/node @types/pg tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/tsconfig.json`

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

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/.env.example`

```env
# Server Configuration
NODE_ENV=development
LOG_LEVEL=info
MCP_SERVER_NAME=postgres-server
MCP_SERVER_VERSION=1.0.0

# PostgreSQL Connection
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DATABASE=postgres
POSTGRES_SSL=false
POSTGRES_SCHEMA=public

# Connection Pool Settings
POSTGRES_MAX_CONNECTIONS=10
POSTGRES_IDLE_TIMEOUT_MS=10000
POSTGRES_CONNECTION_TIMEOUT_MS=5000
POSTGRES_MAX_USES=7500

# Security Settings
POSTGRES_READ_ONLY=false
POSTGRES_ALLOW_DDL=true
POSTGRES_REQUIRE_CONFIRMATION=true
POSTGRES_QUERY_TIMEOUT_MS=30000

# Authentication
MCP_AUTH_ENABLED=false
MCP_API_KEYS=pg_mcp_key_123456
```

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/package.json`

```json
{
  "name": "mcp-postgres-server",
  "version": "1.0.0",
  "description": "Enterprise PostgreSQL MCP server for AI agents",
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
    "db:seed": "tsx src/scripts/seed-db.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "pg": "^8.11.3",
    "pg-pool": "^3.6.1",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@types/pg": "^8.10.9",
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

### Step 2: Create the Logger Module

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/logger.ts`

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
    service: process.env.MCP_SERVER_NAME || 'postgres-server',
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
          destination: path.join(config.baseLogDir, 'postgres-server.log'),
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

### Step 3: Create the PostgreSQL Connection Manager

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/db/connection-manager.ts`

```typescript
import { Pool, PoolConfig, Client, QueryResult, QueryConfig } from 'pg';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('connection-manager');

/**
 * PostgreSQL connection configuration
 */
export interface PgConfig {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
  ssl: boolean | { rejectUnauthorized: boolean };
  schema: string;
  maxConnections: number;
  idleTimeoutMillis: number;
  connectionTimeoutMillis: number;
  maxUses: number;
  readOnly: boolean;
  queryTimeoutMs: number;
}

/**
 * Query result with metadata
 */
export interface QueryResultWithMetadata {
  rows: any[];
  rowCount: number;
  command: string;
  fields: Array<{ name: string; dataTypeID: number }>;
  executionTime: number;
  query: string;
  params: any[];
}

/**
 * Database operation risk level
 */
export type RiskLevel = 'read-only' | 'read-write' | 'admin' | 'critical';

/**
 * PostgreSQL Connection Manager
 * Handles connection pooling, query execution, and security
 */
export class PostgresConnectionManager {
  private pool: Pool;
  private config: PgConfig;
  private isConnected: boolean = false;
  private readonly logger = createModuleLogger('pg-connection-manager');

  constructor(config?: Partial<PgConfig>) {
    // Load from environment with defaults
    this.config = {
      host: config?.host || process.env.POSTGRES_HOST || 'localhost',
      port: config?.port || parseInt(process.env.POSTGRES_PORT || '5432'),
      user: config?.user || process.env.POSTGRES_USER || 'postgres',
      password: config?.password || process.env.POSTGRES_PASSWORD || '',
      database: config?.database || process.env.POSTGRES_DATABASE || 'postgres',
      ssl: config?.ssl ?? (process.env.POSTGRES_SSL === 'true'),
      schema: config?.schema || process.env.POSTGRES_SCHEMA || 'public',
      maxConnections: config?.maxConnections || parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '10'),
      idleTimeoutMillis: config?.idleTimeoutMillis || parseInt(process.env.POSTGRES_IDLE_TIMEOUT_MS || '10000'),
      connectionTimeoutMillis: config?.connectionTimeoutMillis || parseInt(process.env.POSTGRES_CONNECTION_TIMEOUT_MS || '5000'),
      maxUses: config?.maxUses || parseInt(process.env.POSTGRES_MAX_USES || '7500'),
      readOnly: config?.readOnly ?? (process.env.POSTGRES_READ_ONLY === 'true'),
      queryTimeoutMs: config?.queryTimeoutMs || parseInt(process.env.POSTGRES_QUERY_TIMEOUT_MS || '30000')
    };

    // Build pool configuration
    const poolConfig: PoolConfig = {
      host: this.config.host,
      port: this.config.port,
      user: this.config.user,
      password: this.config.password,
      database: this.config.database,
      max: this.config.maxConnections,
      idleTimeoutMillis: this.config.idleTimeoutMillis,
      connectionTimeoutMillis: this.config.connectionTimeoutMillis,
      maxUses: this.config.maxUses,
      ssl: this.config.ssl
    };

    // Handle SSL configuration
    if (this.config.ssl) {
      if (process.env.POSTGRES_SSL === 'verify-full') {
        poolConfig.ssl = { rejectUnauthorized: true };
      } else if (process.env.POSTGRES_SSL === 'true') {
        poolConfig.ssl = { rejectUnauthorized: false };
      }
    }

    this.pool = new Pool(poolConfig);

    // Set up pool event handlers 
    this.pool.on('error', (err, client) => {
      this.logger.error('Unexpected pool error', {
        error: err.message,
        clientId: (client as any)?.id
      });
    });

    this.pool.on('connect', (client) => {
      this.logger.debug('New client connected to pool');
    });

    this.pool.on('acquire', (client) => {
      this.logger.debug('Client acquired from pool');
    });

    this.logger.info('PostgreSQL connection manager initialized', {
      host: this.config.host,
      database: this.config.database,
      schema: this.config.schema,
      maxConnections: this.config.maxConnections,
      readOnly: this.config.readOnly
    });
  }

  /**
   * Initialize the connection pool
   */
  async initialize(): Promise<void> {
    this.logger.info('Initializing PostgreSQL connection pool');

    try {
      // Test the connection
      const client = await this.pool.connect();
      const result = await client.query('SELECT version() as version, current_database() as database, current_schema() as schema');
      client.release();

      this.isConnected = true;

      this.logger.info('PostgreSQL connection established', {
        version: result.rows[0].version,
        database: result.rows[0].database,
        schema: result.rows[0].schema
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to connect to PostgreSQL', { error: errorMsg });
      throw new Error(`PostgreSQL connection failed: ${errorMsg}`);
    }
  }

  /**
   * Execute a query with parameter binding
   */
  async executeQuery(sql: string, params: any[] = []): Promise<QueryResultWithMetadata> {
    const startTime = Date.now();

    this.logger.debug('Executing query', {
      sql: sql.substring(0, 200),
      paramCount: params.length
    });

    // Validate query for security
    this.validateQuery(sql);

    // Build query config
    const queryConfig: QueryConfig = {
      text: sql,
      values: params
    };

    try {
      // Execute with timeout
      const result = await this.executeWithTimeout(queryConfig);

      const executionTime = Date.now() - startTime;

      this.logger.debug('Query executed successfully', {
        rowCount: result.rowCount || 0,
        command: result.command,
        executionTime
      });

      return {
        rows: result.rows,
        rowCount: result.rowCount || 0,
        command: result.command,
        fields: result.fields?.map(f => ({
          name: f.name,
          dataTypeID: f.dataTypeID
        })) || [],
        executionTime,
        query: sql,
        params
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Query execution failed', {
        sql: sql.substring(0, 200),
        error: errorMsg
      });
      throw new Error(`Query failed: ${errorMsg}`);
    }
  }

  /**
   * Execute query with timeout protection
   */
  private async executeWithTimeout(queryConfig: QueryConfig): Promise<QueryResult> {
    const client = await this.pool.connect();

    try {
      // Set statement timeout
      await client.query(`SET statement_timeout = ${this.config.queryTimeoutMs}`);

      // Set schema search path
      await client.query(`SET search_path TO ${this.config.schema}, public`);

      // Set transaction isolation level
      if (this.config.readOnly) {
        await client.query('SET TRANSACTION READ ONLY');
      }

      // Execute the query
      const result = await client.query(queryConfig);

      // Reset timeout
      await client.query('SET statement_timeout = 0');

      return result;

    } finally {
      client.release();
    }
  }

  /**
   * Execute a read-only query (SELECT)
   */
  async readQuery(sql: string, params: any[] = []): Promise<QueryResultWithMetadata> {
    const normalized = sql.trim().toLowerCase();
    if (!normalized.startsWith('select') && !normalized.startsWith('with') && 
        !normalized.startsWith('show') && !normalized.startsWith('explain')) {
      throw new Error('readQuery only accepts SELECT, WITH, SHOW, or EXPLAIN statements');
    }
    return this.executeQuery(sql, params);
  }

  /**
   * Execute a write query (INSERT, UPDATE, DELETE)
   */
  async writeQuery(sql: string, params: any[] = []): Promise<QueryResultWithMetadata> {
    if (this.config.readOnly) {
      throw new Error('Database is in read-only mode');
    }

    const normalized = sql.trim().toLowerCase();
    const writeOperations = ['insert', 'update', 'delete', 'merge'];
    const isWrite = writeOperations.some(op => normalized.startsWith(op));

    if (!isWrite) {
      throw new Error('writeQuery only accepts INSERT, UPDATE, DELETE, or MERGE statements');
    }

    return this.executeQuery(sql, params);
  }

  /**
   * Get the risk level of a query
   */
  getQueryRiskLevel(sql: string): RiskLevel {
    const normalized = sql.trim().toLowerCase();

    // Read-only operations
    const readOnlyPatterns = ['select', 'show', 'explain', 'values'];
    if (readOnlyPatterns.some(p => normalized.startsWith(p))) {
      return 'read-only';
    }

    // Read-write operations
    const readWritePatterns = ['insert', 'update', 'delete', 'merge'];
    if (readWritePatterns.some(p => normalized.startsWith(p))) {
      // Check for dangerous patterns
      if (normalized.includes('delete') && !normalized.includes('where')) {
        return 'critical';
      }
      if (normalized.includes('update') && !normalized.includes('where')) {
        return 'critical';
      }
      return 'read-write';
    }

    // DDL operations (admin)
    const ddlPatterns = ['create', 'alter', 'drop', 'truncate', 'grant', 'revoke'];
    if (ddlPatterns.some(p => normalized.startsWith(p))) {
      if (normalized.includes('drop') || normalized.includes('truncate')) {
        return 'critical';
      }
      return 'admin';
    }

    return 'admin';
  }

  /**
   * Validate query for security 
   */
  private validateQuery(sql: string): void {
    const normalized = sql.trim().toLowerCase();

    // Check for dangerous operations
    const dangerousPatterns = [
      'drop database',
      'drop schema',
      'drop table',
      'truncate table',
      'delete from',
      'update'
    ];

    // Only allow DDL if configured
    if (!this.config.readOnly && !(process.env.POSTGRES_ALLOW_DDL === 'true')) {
      const ddlPattern = /\b(create|alter|drop|truncate)\s+(table|schema|database|index|view)\b/i;
      if (ddlPattern.test(normalized)) {
        throw new Error('DDL operations are not allowed');
      }
    }

    // Check for mass deletions without WHERE
    if (normalized.includes('delete') && !normalized.includes('where')) {
      throw new Error('DELETE without WHERE clause is not allowed');
    }

    // Check for mass updates without WHERE
    if (normalized.includes('update') && !normalized.includes('where')) {
      throw new Error('UPDATE without WHERE clause is not allowed');
    }

    // Check for SQL injection patterns (basic)
    const dangerousKeywords = [';', '--', '/*', '*/', 'xp_', 'exec', 'execute'];
    const hasDangerous = dangerousKeywords.some(keyword => 
      sql.toLowerCase().includes(keyword) && 
      !sql.toLowerCase().includes(keyword + ' ') &&
      !sql.toLowerCase().includes(' ' + keyword + ' ')
    );

    if (hasDangerous) {
      throw new Error('Potentially dangerous SQL pattern detected');
    }
  }

  /**
   * Get database schema information
   */
  async getSchema(): Promise<{
    schemas: string[];
    tables: Array<{ schema: string; name: string; columns: any[]; indexes: any[]; constraints: any[] }>;
  }> {
    this.logger.debug('Fetching database schema');

    // Get schemas
    const schemasResult = await this.executeQuery(
      `SELECT schema_name FROM information_schema.schemata
       WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
       ORDER BY schema_name`
    );
    const schemas = schemasResult.rows.map(r => r.schema_name);

    // Get tables
    const tablesResult = await this.executeQuery(
      `SELECT table_schema, table_name
       FROM information_schema.tables
       WHERE table_type = 'BASE TABLE'
         AND table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
       ORDER BY table_schema, table_name`
    );

    const tables = [];

    for (const row of tablesResult.rows) {
      const schema = row.table_schema;
      const name = row.table_name;

      // Get columns
      const columnsResult = await this.executeQuery(
        `SELECT column_name, data_type, is_nullable, column_default,
                (SELECT COUNT(*) FROM information_schema.key_column_usage
                 WHERE constraint_name = (SELECT constraint_name FROM information_schema.table_constraints
                                          WHERE constraint_type = 'PRIMARY KEY'
                                            AND table_schema = $1
                                            AND table_name = $2)
                   AND column_name = c.column_name) > 0 as is_primary_key
         FROM information_schema.columns c
         WHERE table_schema = $1 AND table_name = $2
         ORDER BY ordinal_position`,
        [schema, name]
      );

      // Get indexes
      const indexesResult = await this.executeQuery(
        `SELECT indexname, indexdef
         FROM pg_indexes
         WHERE schemaname = $1 AND tablename = $2`,
        [schema, name]
      );

      // Get constraints
      const constraintsResult = await this.executeQuery(
        `SELECT constraint_name, constraint_type
         FROM information_schema.table_constraints
         WHERE table_schema = $1 AND table_name = $2
           AND constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY', 'UNIQUE')`,
        [schema, name]
      );

      tables.push({
        schema,
        name,
        columns: columnsResult.rows,
        indexes: indexesResult.rows,
        constraints: constraintsResult.rows
      });
    }

    this.logger.debug('Schema fetched', {
      schemaCount: schemas.length,
      tableCount: tables.length
    });

    return { schemas, tables };
  }

  /**
   * Get database statistics
   */
  async getStats(): Promise<any> {
    this.logger.debug('Fetching database statistics');

    // Get table sizes
    const tableSizes = await this.executeQuery(
      `SELECT schemaname, tablename,
              pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
              pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
              pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size,
              pg_total_relation_size(schemaname||'.'||tablename) as size_bytes
       FROM pg_tables
       WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
       ORDER BY size_bytes DESC
       LIMIT 20`
    );

    // Get active connections
    const connections = await this.executeQuery(
      `SELECT pid, usename, application_name, client_addr, state,
              query, backend_start, query_start, state_change
       FROM pg_stat_activity
       WHERE state = 'active'
       ORDER BY query_start DESC`
    );

    // Get database size
    const dbSize = await this.executeQuery(
      `SELECT pg_size_pretty(pg_database_size(current_database())) as size`
    );

    return {
      databaseSize: dbSize.rows[0]?.size,
      tableSizes: tableSizes.rows,
      activeConnections: connections.rows,
      poolStats: {
        total: this.pool.totalCount,
        idle: this.pool.idleCount,
        waiting: this.pool.waitingCount
      }
    };
  }

  /**
   * Get query execution plan with EXPLAIN ANALYZE
   */
  async explainQuery(sql: string, analyze: boolean = false): Promise<any> {
    this.logger.debug('Generating query plan', { analyze });

    const query = analyze ? `EXPLAIN ANALYZE ${sql}` : `EXPLAIN ${sql}`;
    const result = await this.executeQuery(query);

    return result.rows.map(row => row['QUERY PLAN'] || row['explain']).join('\n');
  }

  /**
   * Get index recommendations based on query patterns
   */
  async getIndexRecommendations(): Promise<any[]> {
    this.logger.debug('Generating index recommendations');

    // Query pg_stat_statements for top queries (requires extension)
    const result = await this.executeQuery(
      `SELECT query, calls, total_time, mean_time, rows,
              substring(query, 1, 200) as query_sample
       FROM pg_stat_statements
       WHERE calls > 100
       ORDER BY mean_time DESC
       LIMIT 20`
    );

    // Basic analysis - look for full table scans
    const recommendations = [];
    for (const row of result.rows) {
      // Check if query has WHERE clause that could use an index
      if (row.query.includes('WHERE') && !row.query.includes('index')) {
        recommendations.push({
          type: 'potential_index',
          query: row.query_sample,
          calls: row.calls,
          mean_time: row.mean_time,
          suggestion: 'Consider adding an index on columns used in WHERE clause'
        });
      }
    }

    return recommendations;
  }

  /**
   * Close the connection pool
   */
  async close(): Promise<void> {
    this.logger.info('Closing PostgreSQL connection pool');
    await this.pool.end();
    this.isConnected = false;
    this.logger.info('Connection pool closed');
  }

  /**
   * Check if connected to database
   */
  isConnectedToDatabase(): boolean {
    return this.isConnected;
  }

  /**
   * Get the current configuration
   */
  getConfig(): PgConfig {
    return { ...this.config };
  }
}

/**
 * Singleton instance of the connection manager
 */
let connectionManager: PostgresConnectionManager | null = null;

export const getConnectionManager = (): PostgresConnectionManager => {
  if (!connectionManager) {
    connectionManager = new PostgresConnectionManager();
  }
  return connectionManager;
};
```

### Step 4: Create PostgreSQL Tools

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/tools/query-tools.ts`

```typescript
import { z } from 'zod';
import { getConnectionManager, RiskLevel } from '../db/connection-manager.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('postgres-tools');

/**
 * Create the read query tool
 * Executes SELECT statements with safety checks
 */
export const createReadQueryTool = () => ({
  name: 'read_query',
  description: 'Execute a SELECT query on the PostgreSQL database. Auto-approved for read-only operations.',
  inputSchema: {
    type: 'object',
    properties: {
      query: {
        type: 'string',
        description: 'The SELECT, SHOW, or EXPLAIN query to execute'
      },
      params: {
        type: 'array',
        description: 'Query parameters for parameterized queries',
        items: {
          type: 'any'
        }
      },
      limit: {
        type: 'integer',
        description: 'Maximum number of rows to return',
        minimum: 1,
        maximum: 10000
      }
    },
    required: ['query']
  },
  handler: async ({ query, params = [], limit }: { query: string; params?: any[]; limit?: number }) => {
    logger.debug('Executing read query', { query: query.substring(0, 100), params, limit });

    const db = getConnectionManager();

    try {
      // Add limit if provided and not already present
      let sql = query;
      if (limit && !sql.toLowerCase().includes('limit')) {
        sql = `${sql} LIMIT ${limit}`;
      }

      const result = await db.readQuery(sql, params);

      let responseText = `Query executed successfully in ${result.executionTime}ms\n`;
      responseText += `Rows returned: ${result.rowCount}\n`;

      if (result.rowCount > 0) {
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
              rowCount: result.rowCount,
              executionTime: result.executionTime,
              data: result.rows
            }, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Read query failed', { error: errorMsg });

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
 * Create the write query tool
 * Executes INSERT, UPDATE, DELETE with risk assessment
 */
export const createWriteQueryTool = () => ({
  name: 'write_query',
  description: 'Execute INSERT, UPDATE, or DELETE query. Requires confirmation for modifications.',
  inputSchema: {
    type: 'object',
    properties: {
      query: {
        type: 'string',
        description: 'The INSERT, UPDATE, or DELETE query to execute'
      },
      params: {
        type: 'array',
        description: 'Query parameters for parameterized queries',
        items: {
          type: 'any'
        }
      },
      confirm: {
        type: 'boolean',
        description: 'Confirmation that you understand this is a write operation',
        default: false
      }
    },
    required: ['query']
  },
  handler: async ({ query, params = [], confirm = false }: { query: string; params?: any[]; confirm?: boolean }) => {
    logger.debug('Executing write query', { query: query.substring(0, 100), params, confirm });

    const db = getConnectionManager();

    // Check risk level
    const riskLevel = db.getQueryRiskLevel(query);
    const requiresConfirmation = riskLevel === 'read-write' && 
      (process.env.POSTGRES_REQUIRE_CONFIRMATION !== 'false');

    if (requiresConfirmation && !confirm) {
      return {
        content: [
          {
            type: 'text',
            text: `⚠️ This is a write operation with risk level: ${riskLevel}. To proceed, set "confirm": true in the arguments.`
          }
        ],
        isError: false
      };
    }

    try {
      const result = await db.writeQuery(query, params);

      let responseText = `Query executed successfully in ${result.executionTime}ms\n`;
      responseText += `Rows affected: ${result.rowCount}\n`;
      responseText += `Command: ${result.command}\n`;

      if (result.rowCount > 0) {
        responseText += '\nAffected rows:\n';
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
              rowCount: result.rowCount,
              command: result.command,
              executionTime: result.executionTime,
              data: result.rows
            }, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Write query failed', { error: errorMsg });

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
 * Create the schema tools
 */
export const createSchemaTools = () => ({
  name: 'list_tables',
  description: 'List all tables in the database with schema information',
  inputSchema: {
    type: 'object',
    properties: {
      schema: {
        type: 'string',
        description: 'Filter tables by schema name (defaults to configured schema)'
      }
    }
  },
  handler: async ({ schema }: { schema?: string }) => {
    logger.debug('Listing tables', { schema });

    const db = getConnectionManager();
    const config = db.getConfig();
    const schemaFilter = schema || config.schema;

    try {
      const result = await db.executeQuery(
        `SELECT table_schema, table_name, 
                (SELECT COUNT(*) FROM information_schema.columns 
                 WHERE table_schema = t.table_schema AND table_name = t.table_name) as column_count
         FROM information_schema.tables t
         WHERE table_type = 'BASE TABLE'
           AND table_schema NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
           AND table_schema = $1
         ORDER BY table_name`,
        [schemaFilter]
      );

      let responseText = `Tables in schema '${schemaFilter}':\n`;
      responseText += `Total: ${result.rowCount}\n\n`;

      for (const row of result.rows) {
        responseText += `- ${row.table_name} (${row.column_count} columns)\n`;
      }

      return {
        content: [
          {
            type: 'text',
            text: responseText
          },
          {
            type: 'text',
            text: JSON.stringify(result.rows, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('List tables failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Failed to list tables: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});

/**
 * Create the describe table tool
 */
export const createDescribeTableTool = () => ({
  name: 'describe_table',
  description: 'Get comprehensive metadata for a specific table including columns, indexes, and constraints',
  inputSchema: {
    type: 'object',
    properties: {
      table: {
        type: 'string',
        description: 'Table name to describe'
      },
      schema: {
        type: 'string',
        description: 'Schema name (defaults to configured schema)'
      }
    },
    required: ['table']
  },
  handler: async ({ table, schema }: { table: string; schema?: string }) => {
    logger.debug('Describing table', { table, schema });

    const db = getConnectionManager();
    const config = db.getConfig();
    const schemaFilter = schema || config.schema;

    try {
      // Get full schema info
      const fullSchema = await db.getSchema();
      
      // Find the table
      const tableInfo = fullSchema.tables.find(
        t => t.name === table && t.schema === schemaFilter
      );

      if (!tableInfo) {
        throw new Error(`Table '${table}' not found in schema '${schemaFilter}'`);
      }

      let responseText = `Table: ${schemaFilter}.${table}\n`;
      responseText += `Columns: ${tableInfo.columns.length}\n`;
      responseText += `Indexes: ${tableInfo.indexes.length}\n`;
      responseText += `Constraints: ${tableInfo.constraints.length}\n\n`;

      responseText += 'Columns:\n';
      for (const col of tableInfo.columns) {
        const pk = col.is_primary_key ? ' 🔑' : '';
        const nullable = col.is_nullable === 'YES' ? 'nullable' : 'NOT NULL';
        responseText += `  - ${col.column_name}: ${col.data_type} ${nullable}${pk}\n`;
        if (col.column_default) {
          responseText += `    default: ${col.column_default}\n`;
        }
      }

      if (tableInfo.indexes.length > 0) {
        responseText += '\nIndexes:\n';
        for (const idx of tableInfo.indexes) {
          responseText += `  - ${idx.indexname}: ${idx.indexdef}\n`;
        }
      }

      if (tableInfo.constraints.length > 0) {
        responseText += '\nConstraints:\n';
        for (const con of tableInfo.constraints) {
          responseText += `  - ${con.constraint_name}: ${con.constraint_type}\n`;
        }
      }

      return {
        content: [
          {
            type: 'text',
            text: responseText
          },
          {
            type: 'text',
            text: JSON.stringify(tableInfo, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Describe table failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Failed to describe table: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});

/**
 * Create the explain query tool
 */
export const createExplainTool = () => ({
  name: 'explain_query',
  description: 'Get query execution plan for performance analysis',
  inputSchema: {
    type: 'object',
    properties: {
      query: {
        type: 'string',
        description: 'The query to explain'
      },
      analyze: {
        type: 'boolean',
        description: 'Include ANALYZE for actual execution statistics',
        default: false
      }
    },
    required: ['query']
  },
  handler: async ({ query, analyze = false }: { query: string; analyze?: boolean }) => {
    logger.debug('Explaining query', { query: query.substring(0, 100), analyze });

    const db = getConnectionManager();

    try {
      const plan = await db.explainQuery(query, analyze);

      const responseText = `Query Execution Plan:\n\n${plan}\n\n`;
      const tipText = analyze ? 
        '💡 Tip: Use EXPLAIN (ANALYZE, BUFFERS) for more detailed statistics' :
        '💡 Tip: Add analyze: true to get actual execution statistics';

      return {
        content: [
          {
            type: 'text',
            text: responseText
          },
          {
            type: 'text',
            text: JSON.stringify({ plan, analyze }, null, 2)
          },
          {
            type: 'text',
            text: tipText
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Explain query failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Failed to explain query: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});

/**
 * Create the database stats tool
 */
export const createStatsTool = () => ({
  name: 'database_stats',
  description: 'Get database statistics including table sizes, connections, and performance metrics',
  inputSchema: {
    type: 'object',
    properties: {}
  },
  handler: async () => {
    logger.debug('Getting database stats');

    const db = getConnectionManager();

    try {
      const stats = await db.getStats();

      let responseText = `Database Statistics\n`;
      responseText += `==================\n\n`;
      responseText += `Database Size: ${stats.databaseSize}\n`;
      responseText += `Active Connections: ${stats.activeConnections.length}\n`;
      responseText += `Pool: ${stats.poolStats.total} total, ${stats.poolStats.idle} idle, ${stats.poolStats.waiting} waiting\n\n`;

      if (stats.tableSizes.length > 0) {
        responseText += 'Largest Tables:\n';
        for (const row of stats.tableSizes) {
          responseText += `  - ${row.schemaname}.${row.tablename}: ${row.total_size}\n`;
        }
      }

      return {
        content: [
          {
            type: 'text',
            text: responseText
          },
          {
            type: 'text',
            text: JSON.stringify(stats, null, 2)
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Get stats failed', { error: errorMsg });

      return {
        content: [
          {
            type: 'text',
            text: `Failed to get database stats: ${errorMsg}`
          }
        ],
        isError: true
      };
    }
  }
});
```

### Step 5: Create PostgreSQL Resources

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/resources/postgres-resources.ts`

```typescript
import { getConnectionManager } from '../db/connection-manager.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('postgres-resources');

/**
 * Create table data resource
 */
export const createTableResource = () => ({
  scheme: 'table',
  handler: async (uri: string) => {
    const parts = uri.replace('postgres://table/', '').split('/');
    const schema = parts[0] || 'public';
    const table = parts[1];

    logger.debug('Reading table resource', { uri, schema, table });

    const db = getConnectionManager();

    try {
      // Get table data
      const result = await db.executeQuery(
        `SELECT * FROM ${schema}.${table} LIMIT 1000`
      );

      return {
        contents: [
          {
            uri,
            text: JSON.stringify({
              schema,
              table,
              rowCount: result.rowCount,
              fields: result.fields,
              data: result.rows
            }, null, 2),
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
 */
export const createQueryResource = () => ({
  scheme: 'query',
  handler: async (uri: string) => {
    const encodedQuery = uri.replace('postgres://query/', '');
    const query = decodeURIComponent(encodedQuery);

    logger.debug('Reading query resource', { uri, query });

    const db = getConnectionManager();

    try {
      const result = await db.readQuery(`${query} LIMIT 1000`);

      return {
        contents: [
          {
            uri,
            text: JSON.stringify({
              query,
              rowCount: result.rowCount,
              executionTime: result.executionTime,
              data: result.rows
            }, null, 2),
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

### Step 6: Create PostgreSQL Prompts

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/prompts/postgres-prompts.ts`

```typescript
import { z } from 'zod';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('postgres-prompts');

/**
 * Create the SQL generation prompt
 */
export const createSqlGenerationPrompt = () => ({
  name: 'generate_sql',
  description: 'Generate optimized SQL queries for PostgreSQL with explanations',
  inputSchema: {
    type: 'object',
    properties: {
      description: {
        type: 'string',
        description: 'Description of what the SQL should do'
      },
      tables: {
        type: 'string',
        description: 'Relevant table names (comma-separated)'
      },
      output: {
        type: 'string',
        description: 'Desired output format'
      }
    },
    required: ['description']
  },
  handler: ({ description, tables, output }: { description: string; tables?: string; output?: string }) => {
    logger.debug('Generating SQL prompt', { description, tables });

    const prompt = `You are a PostgreSQL expert. Generate a SQL query for the following requirement.

**Requirement:** ${description}
${tables ? `**Tables:** ${tables}` : ''}
${output ? `**Output format:** ${output}` : ''}

Please provide:
1. The SQL query (PostgreSQL syntax)
2. Explanation of what the query does
3. Performance considerations (index usage, query plan)
4. Alternative approaches if applicable

**PostgreSQL best practices to follow:**
- Use parameterized queries ($1, $2, ...)
- Add appropriate indexes
- Use EXPLAIN ANALYZE for optimization
- Consider using CTEs for complex queries
- Use RETURNING clause for INSERT/UPDATE/DELETE

**Return the SQL query in a code block with 'sql' annotation.**`;

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
});

/**
 * Create the query tuning prompt
 */
export const createQueryTuningPrompt = () => ({
  name: 'tune_query',
  description: 'Analyze and optimize slow PostgreSQL queries',
  inputSchema: {
    type: 'object',
    properties: {
      slowQuery: {
        type: 'string',
        description: 'The slow SQL query to optimize'
      },
      executionTime: {
        type: 'string',
        description: 'Current execution time (e.g., "5 seconds")'
      }
    },
    required: ['slowQuery']
  },
  handler: ({ slowQuery, executionTime }: { slowQuery: string; executionTime?: string }) => {
    logger.debug('Generating query tuning prompt', { slowQuery: slowQuery.substring(0, 100) });

    const prompt = `You are a PostgreSQL performance expert. Analyze and optimize the following slow query.

**Slow Query:**
\`\`\`sql
${slowQuery}
\`\`\`

${executionTime ? `**Current execution time:** ${executionTime}` : ''}

Please provide:
1. **Query Analysis:**
   - What's causing the slowdown?
   - What is the query doing (full scan, join, etc.)?

2. **Optimization Recommendations:**
   - Index suggestions (include CREATE INDEX statements)
   - Query rewrites
   - Configuration changes
   - Materialized views if applicable

3. **Expected performance improvement**

4. **Monitoring approach** to verify the fix

**Use EXPLAIN ANALYZE to verify the plan.**`;

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
});

/**
 * Create the data migration prompt
 */
export const createMigrationPrompt = () => ({
  name: 'migrate_data',
  description: 'Plan and execute data migration between PostgreSQL tables',
  inputSchema: {
    type: 'object',
    properties: {
      source: {
        type: 'string',
        description: 'Source table (schema.table)'
      },
      target: {
        type: 'string',
        description: 'Target table (schema.table)'
      },
      mapping: {
        type: 'string',
        description: 'Column mapping (e.g., "source_col = target_col")'
      },
      batchSize: {
        type: 'integer',
        description: 'Number of rows per batch',
        default: 10000
      }
    },
    required: ['source', 'target']
  },
  handler: ({ source, target, mapping, batchSize = 10000 }: { 
    source: string; 
    target: string; 
    mapping?: string; 
    batchSize?: number 
  }) => {
    logger.debug('Generating migration prompt', { source, target });

    const prompt = `You are a database migration expert. Migrate data from '${source}' to '${target}'.

**Source:** ${source}
**Target:** ${target}
${mapping ? `**Column mapping:** ${mapping}` : ''}
**Batch size:** ${batchSize} rows

Please provide:
1. **Migration SQL statements:**
   - INSERT with ON CONFLICT handling
   - Data validation queries
   - Verification queries

2. **Migration Plan:**
   - Step-by-step execution order
   - Backup recommendations
   - Rollback strategy

3. **Performance Considerations:**
   - Use batch processing (${batchSize} rows)
   - Disable triggers/constraints if needed
   - Use COPY for large datasets
   - Monitor progress

4. **Validation steps** to ensure data integrity

**Return complete migration script with comments.**`;

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
});
```

### Step 7: Create the Server

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/server.ts`

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger, createModuleLogger } from './logger.js';
import { getConnectionManager } from './db/connection-manager.js';
import {
  createReadQueryTool,
  createWriteQueryTool,
  createSchemaTools,
  createDescribeTableTool,
  createExplainTool,
  createStatsTool
} from './tools/query-tools.js';
import {
  createTableResource,
  createQueryResource,
  createSchemaResource
} from './resources/postgres-resources.js';
import {
  createSqlGenerationPrompt,
  createQueryTuningPrompt,
  createMigrationPrompt
} from './prompts/postgres-prompts.js';

const logger = createModuleLogger('postgres-server');

/**
 * PostgreSQL MCP Server
 * Provides AI access to PostgreSQL databases
 */
export class PostgresServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing PostgreSQL Server');

    this.server = new McpServer({
      name: process.env.MCP_SERVER_NAME || 'postgres-server',
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

    logger.info('PostgreSQL Server initialized successfully');
  }

  /**
   * Initialize the database connection
   */
  private async initializeDatabase(): Promise<void> {
    try {
      const db = getConnectionManager();
      await db.initialize();
      logger.info('PostgreSQL database initialized successfully');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('PostgreSQL initialization failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Register all PostgreSQL tools
   */
  private registerTools(): void {
    logger.info('Registering PostgreSQL tools');

    // Read query tool
    const readQuery = createReadQueryTool();
    this.server.tool(
      readQuery.name,
      {
        query: z.string(),
        params: z.array(z.any()).optional(),
        limit: z.number().optional()
      },
      readQuery.handler
    );

    // Write query tool
    const writeQuery = createWriteQueryTool();
    this.server.tool(
      writeQuery.name,
      {
        query: z.string(),
        params: z.array(z.any()).optional(),
        confirm: z.boolean().optional()
      },
      writeQuery.handler
    );

    // List tables tool
    const listTables = createSchemaTools();
    this.server.tool(
      listTables.name,
      {
        schema: z.string().optional()
      },
      listTables.handler
    );

    // Describe table tool
    const describeTable = createDescribeTableTool();
    this.server.tool(
      describeTable.name,
      {
        table: z.string(),
        schema: z.string().optional()
      },
      describeTable.handler
    );

    // Explain query tool
    const explain = createExplainTool();
    this.server.tool(
      explain.name,
      {
        query: z.string(),
        analyze: z.boolean().optional()
      },
      explain.handler
    );

    // Database stats tool
    const stats = createStatsTool();
    this.server.tool(
      stats.name,
      {},
      stats.handler
    );

    logger.info('PostgreSQL tools registered successfully');
  }

  /**
   * Register all PostgreSQL resources
   */
  private registerResources(): void {
    logger.info('Registering PostgreSQL resources');

    // Table resource: postgres://table/{schema}/{table}
    const tableResource = createTableResource();
    this.server.resource(
      'table_data',
      'postgres://table/*',
      {
        description: 'PostgreSQL table data resource',
        mimeType: 'application/json'
      },
      async (uri: string) => {
        return tableResource.handler(uri);
      }
    );

    // Query resource: postgres://query/{encoded_query}
    const queryResource = createQueryResource();
    this.server.resource(
      'query_result',
      'postgres://query/*',
      {
        description: 'PostgreSQL query result resource',
        mimeType: 'application/json'
      },
      async (uri: string) => {
        return queryResource.handler(uri);
      }
    );

    // Schema resource: postgres://schema
    const schemaResource = createSchemaResource();
    this.server.resource(
      'schema_info',
      'postgres://schema',
      {
        description: 'PostgreSQL schema information',
        mimeType: 'application/json'
      },
      async (uri: string) => {
        return schemaResource.handler(uri);
      }
    );

    logger.info('PostgreSQL resources registered successfully');
  }

  /**
   * Register all PostgreSQL prompts
   */
  private registerPrompts(): void {
    logger.info('Registering PostgreSQL prompts');

    // SQL generation prompt
    const sqlGen = createSqlGenerationPrompt();
    this.server.prompt(
      sqlGen.name,
      {
        description: z.string(),
        tables: z.string().optional(),
        output: z.string().optional()
      },
      sqlGen.handler
    );

    // Query tuning prompt
    const queryTune = createQueryTuningPrompt();
    this.server.prompt(
      queryTune.name,
      {
        slowQuery: z.string(),
        executionTime: z.string().optional()
      },
      queryTune.handler
    );

    // Data migration prompt
    const migration = createMigrationPrompt();
    this.server.prompt(
      migration.name,
      {
        source: z.string(),
        target: z.string(),
        mapping: z.string().optional(),
        batchSize: z.number().optional()
      },
      migration.handler
    );

    logger.info('PostgreSQL prompts registered successfully');
  }

  /**
   * Start the server
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server is already running');
      return;
    }

    logger.info('Starting PostgreSQL Server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;

      logger.info('PostgreSQL Server started successfully');
      console.error('MCP PostgreSQL Server is running and waiting for connections...');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start PostgreSQL Server', { error: errorMsg });
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

    logger.info('Stopping PostgreSQL Server...');

    try {
      const db = getConnectionManager();
      await db.close();

      this.isRunning = false;
      logger.info('PostgreSQL Server stopped successfully');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop PostgreSQL Server', { error: errorMsg });
      throw error;
    }
  }
}
```

### Step 8: Create Entry Point

**File:** `ai-integration-javascript/mcp-protocol/servers/postgres-server/src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { PostgresServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const handleShutdown = async (server: PostgresServer): Promise<void> => {
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
  logger.info('Starting PostgreSQL Server entry point');

  try {
    const server = new PostgresServer();

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

export { PostgresServer };
```

## The Verification

### Step 1: Build the Server

```bash
cd ai-integration-javascript/mcp-protocol/servers/postgres-server
npm install
npm run build
```

### Step 2: Start PostgreSQL (Using Docker)

```bash
docker run --name postgres-mcp -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine
```

### Step 3: Initialize the Database

```bash
# Wait for PostgreSQL to start
sleep 5

# Create test tables
psql -h localhost -U postgres -d postgres -c "
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  age INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email, age) VALUES 
  ('Alice', 'alice@example.com', 30),
  ('Bob', 'bob@example.com', 25),
  ('Charlie', 'charlie@example.com', 35);
"
```

### Step 4: Start the MCP Server

```bash
npm start
```

### Step 5: Test with the MCP Client

Create a test script:

**File:** `test-postgres-client.js`

```javascript
import { createMCPClient } from '../clients/mcp-client-lib/dist/index.js';

const client = createMCPClient({
  servers: [{
    id: 'postgres',
    transport: {
      type: 'stdio',
      command: 'node',
      args: ['dist/index.js']
    }
  }]
});

await client.connectAll();

// Test read query
const result = await client.callTool('postgres', 'read_query', {
  query: 'SELECT * FROM users WHERE age > $1',
  params: [20],
  limit: 5
});
console.log('Read query:', result);

// Test list tables
const tables = await client.callTool('postgres', 'list_tables', {
  schema: 'public'
});
console.log('Tables:', tables);

// Test describe table
const describe = await client.callTool('postgres', 'describe_table', {
  table: 'users'
});
console.log('Table description:', describe);

// Test explain
const explain = await client.callTool('postgres', 'explain_query', {
  query: 'SELECT * FROM users WHERE age > 20'
});
console.log('Explain plan:', explain);

// Test database stats
const stats = await client.callTool('postgres', 'database_stats', {});
console.log('Stats:', stats);

await client.disconnectAll();
```

Expected output showing successful PostgreSQL operations with query results, schema information, and performance analysis.

## What You've Built

You've built a production-grade PostgreSQL MCP server with:

### Features
1. **Connection Pooling** — Efficient connection management with pg-pool 
2. **Read/Write Separation** — Auto-approved reads, confirmed writes 
3. **Risk Classification** — Read-only, read-write, admin, critical
4. **Schema Introspection** — Tables, columns, indexes, constraints
5. **Query Optimization** — EXPLAIN ANALYZE support
6. **Database Statistics** — Table sizes, connections, performance metrics
7. **Resources** — Table data, query results, schema
8. **Prompts** — SQL generation, query tuning, data migration

### Security Features
1. **Parameterized Queries** — SQL injection protection
2. **Read-Only Mode** — Prevent accidental writes
3. **DDL Control** — Optional DDL execution
4. **Risk Assessment** — Confirm critical operations

## Key Takeaways

1. **PostgreSQL is Production-Ready** — With connection pooling and monitoring
2. **Security is Paramount** — Separate read/write operations
3. **Performance Matters** — EXPLAIN and index recommendations
4. **Schema Access** — Table introspection is essential for AI
5. **Risk-Based Approval** — Different operations need different safeguards

## What's Next?

In **Part 6**, we'll connect multiple enterprise systems with the **Enterprise Knowledge Server** — a unified MCP interface that aggregates PostgreSQL, SQLite, REST APIs, GitHub, and Docker into a single AI-accessible platform.
