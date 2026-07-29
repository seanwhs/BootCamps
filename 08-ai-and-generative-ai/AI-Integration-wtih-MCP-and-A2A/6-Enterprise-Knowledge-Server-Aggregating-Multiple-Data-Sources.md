# Part 6: Enterprise Knowledge Server — Aggregating Multiple Data Sources

## The Target

In this part, we're building the **Enterprise Knowledge Server** — a unified MCP server that aggregates multiple enterprise data sources into a single, coherent interface for AI agents. This server will connect to:

- **PostgreSQL** — Production database
- **SQLite** — Local/embedded database
- **REST APIs** — External services and internal APIs
- **GitHub** — Repositories, issues, pull requests
- **File System** — Documentation, configuration, logs
- **Internal Documentation** — Wikis, knowledge bases, Confluence

The Knowledge Server acts as a **single point of access** for AI agents, abstracting away the complexity of different data sources and providing a consistent MCP interface.

## The Concept

### The Knowledge Server Architecture

Think of the Enterprise Knowledge Server as a **unified library catalog system**. Instead of going to different libraries (data sources) with different rules and formats, the AI agent visits one place that knows how to find information everywhere.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Enterprise Knowledge Server                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    MCP Interface Layer                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │  │
│  │  │  Tools   │  │Resources │  │ Prompts  │  │ Events   │ │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                  Data Source Adapters                       │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │  │
│  │  │PostgreSQL│  │  SQLite  │  │  GitHub  │  │   REST   │ │  │
│  │  │ Adapter  │  │ Adapter  │  │ Adapter  │  │ Adapter  │ │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │  │
│  │  │  File    │  │  Doc     │  │  Cache   │              │  │
│  │  │ Adapter  │  │ Adapter  │  │ Manager  │              │  │
│  │  └──────────┘  └──────────┘  └──────────┘              │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              External Systems (Data Sources)                │  │
│  │  PostgreSQL  │  SQLite  │  GitHub  │  REST  │  Filesystem │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Source Adapters

Each adapter handles:
1. **Connection Management** — Connect to the data source
2. **Query Translation** — Convert MCP queries to native formats
3. **Result Normalization** — Return data in a consistent format
4. **Error Handling** — Graceful degradation
5. **Caching** — Performance optimization

## The Implementation

### Step 1: Project Setup

```bash
cd ai-integration-javascript/mcp-protocol/servers
mkdir -p knowledge-server
cd knowledge-server
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk sqlite3 pg axios @octokit/rest zod dotenv pino pino-pretty
npm install -D typescript @types/node @types/sqlite3 @types/pg @types/axios tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/.env.example`

```env
# Server Configuration
NODE_ENV=development
LOG_LEVEL=info
MCP_SERVER_NAME=knowledge-server
MCP_SERVER_VERSION=1.0.0

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DATABASE=postgres

# SQLite
SQLITE_PATH=./data/app.db

# GitHub
GITHUB_TOKEN=your_github_pat
GITHUB_REPO=your-org/your-repo

# REST APIs
REST_API_BASE_URL=https://api.example.com
REST_API_KEY=your_api_key

# Documentation
DOCS_PATH=./docs

# Cache
CACHE_TTL=300
CACHE_MAX_SIZE=1000

# Authentication
MCP_AUTH_ENABLED=false
MCP_API_KEYS=knowledge_mcp_key_123456
```

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/package.json`

```json
{
  "name": "mcp-knowledge-server",
  "version": "1.0.0",
  "description": "Enterprise Knowledge Server aggregating multiple data sources",
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
    "format": "prettier --write src/**/*.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "@octokit/rest": "^20.0.2",
    "axios": "^1.6.2",
    "pg": "^8.11.3",
    "sqlite3": "^5.1.6",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@types/pg": "^8.10.9",
    "@types/sqlite3": "^3.1.9",
    "@types/axios": "^0.14.0",
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

### Step 2: Create Logger and Base Classes

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/logger.ts`

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
    service: process.env.MCP_SERVER_NAME || 'knowledge-server',
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
          destination: path.join(config.baseLogDir, 'knowledge-server.log'),
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

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/adapters/base-adapter.ts`

```typescript
import { Logger, createModuleLogger } from '../logger.js';

/**
 * Base data source adapter interface
 * All adapters must implement these methods
 */
export interface DataSourceAdapter {
  /** Unique identifier for this data source */
  readonly id: string;
  /** Human-readable name */
  readonly name: string;
  /** Description of what this adapter provides */
  readonly description: string;
  
  /**
   * Initialize the adapter
   * Called when the server starts
   */
  initialize(): Promise<void>;
  
  /**
   * Execute a query against the data source
   * Returns normalized results
   */
  query(request: QueryRequest): Promise<QueryResult>;
  
  /**
   * Get a resource from the data source
   */
  getResource(uri: string): Promise<ResourceData>;
  
  /**
   * Get available resources
   */
  listResources(): Promise<ResourceList>;
  
  /**
   * Check if the adapter is healthy
   */
  healthCheck(): Promise<HealthStatus>;
  
  /**
   * Clean up and close connections
   */
  shutdown(): Promise<void>;
}

/**
 * Query request
 */
export interface QueryRequest {
  /** Query type */
  type: 'sql' | 'graphql' | 'rest' | 'search' | 'file';
  /** Query text or parameters */
  query: string | Record<string, any>;
  /** Additional options */
  options?: Record<string, any>;
  /** Limit results */
  limit?: number;
}

/**
 * Query result
 */
export interface QueryResult {
  /** Success flag */
  success: boolean;
  /** Error message if failed */
  error?: string;
  /** Result data */
  data: any[];
  /** Metadata about the result */
  metadata: {
    source: string;
    executionTime: number;
    rowCount: number;
    query: string;
    params?: any[];
  };
}

/**
 * Resource data
 */
export interface ResourceData {
  uri: string;
  content: string | Buffer;
  mimeType: string;
  metadata?: Record<string, any>;
}

/**
 * Resource list
 */
export interface ResourceList {
  resources: Array<{
    uri: string;
    name: string;
    description?: string;
    mimeType?: string;
  }>;
}

/**
 * Health status
 */
export interface HealthStatus {
  healthy: boolean;
  message?: string;
  details?: Record<string, any>;
}

/**
 * Base adapter class with common functionality
 */
export abstract class BaseAdapter implements DataSourceAdapter {
  abstract readonly id: string;
  abstract readonly name: string;
  abstract readonly description: string;
  
  protected logger: Logger;
  protected initialized: boolean = false;

  constructor() {
    this.logger = createModuleLogger(this.id);
  }

  abstract initialize(): Promise<void>;
  abstract query(request: QueryRequest): Promise<QueryResult>;
  abstract getResource(uri: string): Promise<ResourceData>;
  abstract listResources(): Promise<ResourceList>;
  abstract healthCheck(): Promise<HealthStatus>;
  abstract shutdown(): Promise<void>;

  /**
   * Check if adapter is initialized
   */
  isInitialized(): boolean {
    return this.initialized;
  }

  /**
   * Validate initialization state
   */
  protected ensureInitialized(): void {
    if (!this.initialized) {
      throw new Error(`${this.id} adapter not initialized`);
    }
  }

  /**
   * Normalize error for consistent error handling
   */
  protected normalizeError(error: unknown): string {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }

  /**
   * Create a success result
   */
  protected createSuccessResult(
    data: any[],
    query: string,
    executionTime: number,
    params?: any[]
  ): QueryResult {
    return {
      success: true,
      data,
      metadata: {
        source: this.id,
        executionTime,
        rowCount: data.length,
        query,
        params
      }
    };
  }

  /**
   * Create an error result
   */
  protected createErrorResult(
    error: string,
    query: string,
    executionTime: number
  ): QueryResult {
    return {
      success: false,
      error,
      data: [],
      metadata: {
        source: this.id,
        executionTime,
        rowCount: 0,
        query
      }
    };
  }
}
```

### Step 3: Implement Data Source Adapters

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/adapters/postgres-adapter.ts`

```typescript
import { Pool, PoolConfig } from 'pg';
import { BaseAdapter, QueryRequest, QueryResult, ResourceData, ResourceList, HealthStatus } from './base-adapter.js';

/**
 * PostgreSQL Adapter
 * Connects to PostgreSQL database
 */
export class PostgresAdapter extends BaseAdapter {
  readonly id = 'postgres';
  readonly name = 'PostgreSQL';
  readonly description = 'Production PostgreSQL database with schema introspection';
  
  private pool?: Pool;
  private config: {
    host: string;
    port: number;
    user: string;
    password: string;
    database: string;
    ssl: boolean;
    maxConnections: number;
  };

  constructor() {
    super();
    this.config = {
      host: process.env.POSTGRES_HOST || 'localhost',
      port: parseInt(process.env.POSTGRES_PORT || '5432'),
      user: process.env.POSTGRES_USER || 'postgres',
      password: process.env.POSTGRES_PASSWORD || '',
      database: process.env.POSTGRES_DATABASE || 'postgres',
      ssl: process.env.POSTGRES_SSL === 'true',
      maxConnections: parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '10')
    };
  }

  async initialize(): Promise<void> {
    this.logger.info('Initializing PostgreSQL adapter', { config: { ...this.config, password: '***' } });

    try {
      const poolConfig: PoolConfig = {
        host: this.config.host,
        port: this.config.port,
        user: this.config.user,
        password: this.config.password,
        database: this.config.database,
        max: this.config.maxConnections,
        ssl: this.config.ssl ? { rejectUnauthorized: false } : false
      };

      this.pool = new Pool(poolConfig);

      // Test connection
      const client = await this.pool.connect();
      const result = await client.query('SELECT version() as version');
      client.release();

      this.initialized = true;
      this.logger.info('PostgreSQL adapter initialized', {
        version: result.rows[0].version,
        database: this.config.database
      });

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to initialize PostgreSQL adapter', { error: errorMsg });
      throw error;
    }
  }

  async query(request: QueryRequest): Promise<QueryResult> {
    this.ensureInitialized();
    
    const startTime = Date.now();
    const queryText = typeof request.query === 'string' ? request.query : JSON.stringify(request.query);
    const params = request.options?.params || [];

    this.logger.debug('Executing PostgreSQL query', {
      query: queryText.substring(0, 100),
      paramCount: params.length
    });

    try {
      if (!this.pool) {
        throw new Error('PostgreSQL pool not initialized');
      }

      const result = await this.pool.query(queryText, params);
      const executionTime = Date.now() - startTime;

      this.logger.debug('PostgreSQL query executed', {
        rowCount: result.rowCount || 0,
        executionTime
      });

      return this.createSuccessResult(
        result.rows,
        queryText,
        executionTime,
        params
      );

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      const executionTime = Date.now() - startTime;
      this.logger.error('PostgreSQL query failed', { error: errorMsg });

      return this.createErrorResult(errorMsg, queryText, executionTime);
    }
  }

  async getResource(uri: string): Promise<ResourceData> {
    this.ensureInitialized();

    this.logger.debug('Getting PostgreSQL resource', { uri });

    try {
      if (!this.pool) {
        throw new Error('PostgreSQL pool not initialized');
      }

      // Parse URI: postgres://table/{table} or postgres://schema
      const parts = uri.replace('postgres://', '').split('/');
      const resourceType = parts[0];
      const resourceName = parts[1];

      let result;

      if (resourceType === 'table' && resourceName) {
        // Get table data
        result = await this.pool.query(
          `SELECT * FROM ${resourceName} LIMIT 100`
        );
      } else if (resourceType === 'schema') {
        // Get schema information
        result = await this.pool.query(
          `SELECT table_schema, table_name, column_name, data_type 
           FROM information_schema.columns 
           WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
           ORDER BY table_schema, table_name, ordinal_position`
        );
      } else {
        throw new Error(`Unknown PostgreSQL resource type: ${resourceType}`);
      }

      return {
        uri,
        content: JSON.stringify(result.rows, null, 2),
        mimeType: 'application/json',
        metadata: {
          rowCount: result.rowCount || 0,
          resourceType
        }
      };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to get PostgreSQL resource', { uri, error: errorMsg });
      throw new Error(`PostgreSQL resource error: ${errorMsg}`);
    }
  }

  async listResources(): Promise<ResourceList> {
    this.ensureInitialized();

    this.logger.debug('Listing PostgreSQL resources');

    try {
      if (!this.pool) {
        throw new Error('PostgreSQL pool not initialized');
      }

      // Get list of tables
      const result = await this.pool.query(
        `SELECT table_schema, table_name 
         FROM information_schema.tables 
         WHERE table_type = 'BASE TABLE'
           AND table_schema NOT IN ('information_schema', 'pg_catalog')
         ORDER BY table_schema, table_name`
      );

      const resources = result.rows.map((row: any) => ({
        uri: `postgres://table/${row.table_schema}/${row.table_name}`,
        name: `${row.table_schema}.${row.table_name}`,
        description: `Table ${row.table_name} in schema ${row.table_schema}`,
        mimeType: 'application/json'
      }));

      // Add schema resource
      resources.unshift({
        uri: 'postgres://schema',
        name: 'Database Schema',
        description: 'Complete database schema information',
        mimeType: 'application/json'
      });

      this.logger.debug('Listed PostgreSQL resources', { count: resources.length });

      return { resources };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to list PostgreSQL resources', { error: errorMsg });
      return { resources: [] };
    }
  }

  async healthCheck(): Promise<HealthStatus> {
    try {
      if (!this.pool) {
        return { healthy: false, message: 'Pool not initialized' };
      }

      const client = await this.pool.connect();
      await client.query('SELECT 1');
      client.release();

      return {
        healthy: true,
        message: 'Connected to PostgreSQL',
        details: {
          database: this.config.database,
          host: this.config.host,
          poolTotal: this.pool.totalCount
        }
      };
    } catch (error) {
      return {
        healthy: false,
        message: this.normalizeError(error)
      };
    }
  }

  async shutdown(): Promise<void> {
    this.logger.info('Shutting down PostgreSQL adapter');
    if (this.pool) {
      await this.pool.end();
    }
    this.initialized = false;
    this.logger.info('PostgreSQL adapter shut down');
  }
}
```

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/adapters/sqlite-adapter.ts`

```typescript
import sqlite3 from 'sqlite3';
import { BaseAdapter, QueryRequest, QueryResult, ResourceData, ResourceList, HealthStatus } from './base-adapter.js';
import fs from 'fs';
import path from 'path';

/**
 * SQLite Adapter
 * Connects to SQLite database
 */
export class SQLiteAdapter extends BaseAdapter {
  readonly id = 'sqlite';
  readonly name = 'SQLite';
  readonly description = 'Embedded SQLite database for local data';
  
  private db?: sqlite3.Database;
  private config: {
    path: string;
  };

  constructor() {
    super();
    this.config = {
      path: process.env.SQLITE_PATH || './data/app.db'
    };
  }

  async initialize(): Promise<void> {
    this.logger.info('Initializing SQLite adapter', { path: this.config.path });

    try {
      // Ensure directory exists
      const dir = path.dirname(this.config.path);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      this.db = new sqlite3.Database(this.config.path, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE);

      // Enable WAL mode and foreign keys
      await this.runQuery('PRAGMA journal_mode = WAL');
      await this.runQuery('PRAGMA foreign_keys = ON');

      this.initialized = true;
      this.logger.info('SQLite adapter initialized');
    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to initialize SQLite adapter', { error: errorMsg });
      throw error;
    }
  }

  async query(request: QueryRequest): Promise<QueryResult> {
    this.ensureInitialized();
    
    const startTime = Date.now();
    const queryText = typeof request.query === 'string' ? request.query : JSON.stringify(request.query);
    const params = request.options?.params || [];

    this.logger.debug('Executing SQLite query', {
      query: queryText.substring(0, 100),
      paramCount: params.length
    });

    try {
      const result = await this.runQuery(queryText, params);
      const executionTime = Date.now() - startTime;

      this.logger.debug('SQLite query executed', {
        rowCount: result.length || 0,
        executionTime
      });

      return this.createSuccessResult(
        result,
        queryText,
        executionTime,
        params
      );

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      const executionTime = Date.now() - startTime;
      this.logger.error('SQLite query failed', { error: errorMsg });

      return this.createErrorResult(errorMsg, queryText, executionTime);
    }
  }

  private runQuery(sql: string, params: any[] = []): Promise<any[]> {
    return new Promise((resolve, reject) => {
      if (!this.db) {
        reject(new Error('SQLite database not initialized'));
        return;
      }

      // Determine if it's a SELECT query
      const isSelect = sql.trim().toLowerCase().startsWith('select') ||
                       sql.trim().toLowerCase().startsWith('pragma') ||
                       sql.trim().toLowerCase().startsWith('explain');

      if (isSelect) {
        this.db.all(sql, params, (err, rows) => {
          if (err) reject(err);
          else resolve(rows || []);
        });
      } else {
        this.db.run(sql, params, function(err) {
          if (err) reject(err);
          else resolve([{ changes: this.changes, lastID: this.lastID }]);
        });
      }
    });
  }

  async getResource(uri: string): Promise<ResourceData> {
    this.ensureInitialized();

    this.logger.debug('Getting SQLite resource', { uri });

    try {
      // Parse URI: sqlite://table/{table}
      const tableName = uri.replace('sqlite://table/', '');
      
      const result = await this.runQuery(
        `SELECT * FROM ${tableName} LIMIT 100`
      );

      return {
        uri,
        content: JSON.stringify(result, null, 2),
        mimeType: 'application/json',
        metadata: {
          tableName,
          rowCount: result.length
        }
      };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to get SQLite resource', { uri, error: errorMsg });
      throw new Error(`SQLite resource error: ${errorMsg}`);
    }
  }

  async listResources(): Promise<ResourceList> {
    this.ensureInitialized();

    this.logger.debug('Listing SQLite resources');

    try {
      const result = await this.runQuery(
        `SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'`
      );

      const resources = result.map((row: any) => ({
        uri: `sqlite://table/${row.name}`,
        name: row.name,
        description: `SQLite table: ${row.name}`,
        mimeType: 'application/json'
      }));

      this.logger.debug('Listed SQLite resources', { count: resources.length });

      return { resources };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to list SQLite resources', { error: errorMsg });
      return { resources: [] };
    }
  }

  async healthCheck(): Promise<HealthStatus> {
    try {
      if (!this.db) {
        return { healthy: false, message: 'Database not initialized' };
      }

      await this.runQuery('SELECT 1');
      
      return {
        healthy: true,
        message: 'Connected to SQLite',
        details: {
          path: this.config.path
        }
      };
    } catch (error) {
      return {
        healthy: false,
        message: this.normalizeError(error)
      };
    }
  }

  async shutdown(): Promise<void> {
    this.logger.info('Shutting down SQLite adapter');
    if (this.db) {
      await new Promise((resolve) => this.db!.close(resolve));
    }
    this.initialized = false;
    this.logger.info('SQLite adapter shut down');
  }
}
```

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/adapters/github-adapter.ts`

```typescript
import { Octokit } from '@octokit/rest';
import { BaseAdapter, QueryRequest, QueryResult, ResourceData, ResourceList, HealthStatus } from './base-adapter.js';

/**
 * GitHub Adapter
 * Connects to GitHub API for repositories, issues, PRs, and code
 */
export class GitHubAdapter extends BaseAdapter {
  readonly id = 'github';
  readonly name = 'GitHub';
  readonly description = 'GitHub repository data including issues, PRs, and code';
  
  private octokit?: Octokit;
  private config: {
    token: string;
    owner: string;
    repo: string;
  };

  constructor() {
    super();
    this.config = {
      token: process.env.GITHUB_TOKEN || '',
      owner: process.env.GITHUB_OWNER || '',
      repo: process.env.GITHUB_REPO || ''
    };
  }

  async initialize(): Promise<void> {
    this.logger.info('Initializing GitHub adapter', { 
      owner: this.config.owner, 
      repo: this.config.repo 
    });

    try {
      if (!this.config.token) {
        throw new Error('GitHub token is required');
      }

      this.octokit = new Octokit({
        auth: this.config.token
      });

      // Test authentication
      const { data } = await this.octokit.repos.get({
        owner: this.config.owner,
        repo: this.config.repo
      });

      this.initialized = true;
      this.logger.info('GitHub adapter initialized', {
        repo: data.full_name,
        defaultBranch: data.default_branch
      });

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to initialize GitHub adapter', { error: errorMsg });
      throw error;
    }
  }

  async query(request: QueryRequest): Promise<QueryResult> {
    this.ensureInitialized();
    
    const startTime = Date.now();
    const queryType = request.type;
    const query = typeof request.query === 'string' ? request.query : JSON.stringify(request.query);
    const options = request.options || {};

    this.logger.debug('Executing GitHub query', { queryType, query });

    try {
      if (!this.octokit) {
        throw new Error('GitHub client not initialized');
      }

      let data: any[] = [];
      let response;

      switch (queryType) {
        case 'issues':
          response = await this.octokit.issues.listForRepo({
            owner: this.config.owner,
            repo: this.config.repo,
            state: options.state || 'open',
            per_page: request.limit || 30
          });
          data = response.data;
          break;

        case 'pulls':
          response = await this.octokit.pulls.list({
            owner: this.config.owner,
            repo: this.config.repo,
            state: options.state || 'open',
            per_page: request.limit || 30
          });
          data = response.data;
          break;

        case 'code':
          const searchResponse = await this.octokit.search.code({
            q: `${options.query} repo:${this.config.owner}/${this.config.repo}`,
            per_page: request.limit || 10
          });
          data = searchResponse.data.items;
          break;

        case 'commits':
          response = await this.octokit.repos.listCommits({
            owner: this.config.owner,
            repo: this.config.repo,
            per_page: request.limit || 30
          });
          data = response.data;
          break;

        default:
          throw new Error(`Unsupported GitHub query type: ${queryType}`);
      }

      const executionTime = Date.now() - startTime;

      this.logger.debug('GitHub query executed', {
        rowCount: data.length,
        executionTime
      });

      return this.createSuccessResult(
        data,
        `${queryType}: ${query}`,
        executionTime,
        []
      );

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      const executionTime = Date.now() - startTime;
      this.logger.error('GitHub query failed', { error: errorMsg });

      return this.createErrorResult(errorMsg, query, executionTime);
    }
  }

  async getResource(uri: string): Promise<ResourceData> {
    this.ensureInitialized();

    this.logger.debug('Getting GitHub resource', { uri });

    try {
      if (!this.octokit) {
        throw new Error('GitHub client not initialized');
      }

      const resourceType = uri.replace('github://', '').split('/')[0];
      let content: any;

      switch (resourceType) {
        case 'issues':
          const issueNumber = parseInt(uri.split('/').pop() || '0');
          const issue = await this.octokit.issues.get({
            owner: this.config.owner,
            repo: this.config.repo,
            issue_number: issueNumber
          });
          content = issue.data;
          break;

        case 'readme':
          const readme = await this.octokit.repos.getReadme({
            owner: this.config.owner,
            repo: this.config.repo
          });
          content = Buffer.from(readme.data.content, 'base64').toString('utf-8');
          break;

        default:
          throw new Error(`Unknown GitHub resource type: ${resourceType}`);
      }

      return {
        uri,
        content: typeof content === 'string' ? content : JSON.stringify(content, null, 2),
        mimeType: typeof content === 'string' ? 'text/plain' : 'application/json',
        metadata: {
          resourceType,
          source: 'GitHub'
        }
      };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to get GitHub resource', { uri, error: errorMsg });
      throw new Error(`GitHub resource error: ${errorMsg}`);
    }
  }

  async listResources(): Promise<ResourceList> {
    this.ensureInitialized();

    this.logger.debug('Listing GitHub resources');

    try {
      const resources = [
        {
          uri: 'github://issues',
          name: 'Open Issues',
          description: 'List of open issues in the repository',
          mimeType: 'application/json'
        },
        {
          uri: 'github://pulls',
          name: 'Open Pull Requests',
          description: 'List of open pull requests in the repository',
          mimeType: 'application/json'
        },
        {
          uri: 'github://readme',
          name: 'README',
          description: 'Repository README file',
          mimeType: 'text/plain'
        },
        {
          uri: 'github://commits',
          name: 'Recent Commits',
          description: 'List of recent commits in the repository',
          mimeType: 'application/json'
        }
      ];

      // Add specific issue resources for open issues
      try {
        if (this.octokit) {
          const { data } = await this.octokit.issues.listForRepo({
            owner: this.config.owner,
            repo: this.config.repo,
            state: 'open',
            per_page: 10
          });

          for (const issue of data) {
            resources.push({
              uri: `github://issues/${issue.number}`,
              name: `Issue #${issue.number}: ${issue.title}`,
              description: issue.body?.substring(0, 100) || '',
              mimeType: 'application/json'
            });
          }
        }
      } catch (error) {
        this.logger.warn('Failed to get issue resources', { error: this.normalizeError(error) });
      }

      return { resources };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to list GitHub resources', { error: errorMsg });
      return { resources: [] };
    }
  }

  async healthCheck(): Promise<HealthStatus> {
    try {
      if (!this.octokit) {
        return { healthy: false, message: 'GitHub client not initialized' };
      }

      await this.octokit.repos.get({
        owner: this.config.owner,
        repo: this.config.repo
      });

      return {
        healthy: true,
        message: 'Connected to GitHub',
        details: {
          repo: `${this.config.owner}/${this.config.repo}`
        }
      };
    } catch (error) {
      return {
        healthy: false,
        message: this.normalizeError(error)
      };
    }
  }

  async shutdown(): Promise<void> {
    this.logger.info('Shutting down GitHub adapter');
    this.initialized = false;
    this.logger.info('GitHub adapter shut down');
  }
}
```

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/adapters/rest-api-adapter.ts`

```typescript
import axios, { AxiosInstance } from 'axios';
import { BaseAdapter, QueryRequest, QueryResult, ResourceData, ResourceList, HealthStatus } from './base-adapter.js';

/**
 * REST API Adapter
 * Connects to external REST APIs
 */
export class RestApiAdapter extends BaseAdapter {
  readonly id = 'rest-api';
  readonly name = 'REST API';
  readonly description = 'External REST API integration for various services';
  
  private client?: AxiosInstance;
  private config: {
    baseUrl: string;
    apiKey: string;
    timeout: number;
  };

  constructor() {
    super();
    this.config = {
      baseUrl: process.env.REST_API_BASE_URL || '',
      apiKey: process.env.REST_API_KEY || '',
      timeout: parseInt(process.env.REST_API_TIMEOUT || '30000')
    };
  }

  async initialize(): Promise<void> {
    this.logger.info('Initializing REST API adapter', { baseUrl: this.config.baseUrl });

    try {
      if (!this.config.baseUrl) {
        throw new Error('REST API base URL is required');
      }

      this.client = axios.create({
        baseURL: this.config.baseUrl,
        timeout: this.config.timeout,
        headers: {
          'Content-Type': 'application/json',
          ...(this.config.apiKey ? { 'X-API-Key': this.config.apiKey } : {})
        }
      });

      // Test connection
      await this.client.get('/health', { timeout: 5000 });

      this.initialized = true;
      this.logger.info('REST API adapter initialized');

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to initialize REST API adapter', { error: errorMsg });
      throw error;
    }
  }

  async query(request: QueryRequest): Promise<QueryResult> {
    this.ensureInitialized();
    
    const startTime = Date.now();
    const query = typeof request.query === 'string' ? request.query : JSON.stringify(request.query);
    const options = request.options || {};

    this.logger.debug('Executing REST API query', { query, method: options.method || 'GET' });

    try {
      if (!this.client) {
        throw new Error('REST API client not initialized');
      }

      const method = (options.method || 'GET').toLowerCase();
      const url = query;
      const data = options.data || {};
      const params = options.params || {};

      let response;

      switch (method) {
        case 'get':
          response = await this.client.get(url, { params });
          break;
        case 'post':
          response = await this.client.post(url, data);
          break;
        case 'put':
          response = await this.client.put(url, data);
          break;
        case 'delete':
          response = await this.client.delete(url);
          break;
        default:
          throw new Error(`Unsupported HTTP method: ${method}`);
      }

      const executionTime = Date.now() - startTime;
      const responseData = Array.isArray(response.data) ? response.data : [response.data];

      this.logger.debug('REST API query executed', {
        status: response.status,
        rowCount: responseData.length,
        executionTime
      });

      return this.createSuccessResult(
        responseData,
        `${method} ${url}`,
        executionTime,
        []
      );

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      const executionTime = Date.now() - startTime;
      this.logger.error('REST API query failed', { error: errorMsg });

      return this.createErrorResult(errorMsg, query, executionTime);
    }
  }

  async getResource(uri: string): Promise<ResourceData> {
    this.ensureInitialized();

    this.logger.debug('Getting REST API resource', { uri });

    try {
      if (!this.client) {
        throw new Error('REST API client not initialized');
      }

      // Extract endpoint from URI: rest://{endpoint}
      const endpoint = uri.replace('rest://', '');
      
      const response = await this.client.get(endpoint);

      return {
        uri,
        content: JSON.stringify(response.data, null, 2),
        mimeType: 'application/json',
        metadata: {
          endpoint,
          statusCode: response.status
        }
      };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to get REST API resource', { uri, error: errorMsg });
      throw new Error(`REST API resource error: ${errorMsg}`);
    }
  }

  async listResources(): Promise<ResourceList> {
    this.ensureInitialized();

    this.logger.debug('Listing REST API resources');

    try {
      // This would typically fetch from an OpenAPI/Swagger document
      // For now, return a static list based on configuration
      const resources = [
        {
          uri: 'rest://users',
          name: 'Users',
          description: 'User management endpoints',
          mimeType: 'application/json'
        },
        {
          uri: 'rest://products',
          name: 'Products',
          description: 'Product catalog',
          mimeType: 'application/json'
        },
        {
          uri: 'rest://orders',
          name: 'Orders',
          description: 'Order management',
          mimeType: 'application/json'
        }
      ];

      return { resources };

    } catch (error) {
      const errorMsg = this.normalizeError(error);
      this.logger.error('Failed to list REST API resources', { error: errorMsg });
      return { resources: [] };
    }
  }

  async healthCheck(): Promise<HealthStatus> {
    try {
      if (!this.client) {
        return { healthy: false, message: 'Client not initialized' };
      }

      await this.client.get('/health', { timeout: 5000 });

      return {
        healthy: true,
        message: 'Connected to REST API',
        details: {
          baseUrl: this.config.baseUrl
        }
      };
    } catch (error) {
      return {
        healthy: false,
        message: this.normalizeError(error)
      };
    }
  }

  async shutdown(): Promise<void> {
    this.logger.info('Shutting down REST API adapter');
    this.initialized = false;
    this.logger.info('REST API adapter shut down');
  }
}
```

### Step 4: Create the Knowledge Server

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/knowledge-server.ts`

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger, createModuleLogger } from './logger.js';
import { DataSourceAdapter } from './adapters/base-adapter.js';
import { PostgresAdapter } from './adapters/postgres-adapter.js';
import { SQLiteAdapter } from './adapters/sqlite-adapter.js';
import { GitHubAdapter } from './adapters/github-adapter.js';
import { RestApiAdapter } from './adapters/rest-api-adapter.js';

const logger = createModuleLogger('knowledge-server');

/**
 * Enterprise Knowledge Server
 * Aggregates multiple data sources into a unified MCP interface
 */
export class KnowledgeServer {
  private server: McpServer;
  private adapters: Map<string, DataSourceAdapter> = new Map();
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Enterprise Knowledge Server');

    this.server = new McpServer({
      name: process.env.MCP_SERVER_NAME || 'knowledge-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0',
      capabilities: {
        tools: {},
        resources: {},
        prompts: {}
      }
    });

    // Initialize adapters
    this.initializeAdapters();

    // Register capabilities
    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Knowledge Server initialized successfully', {
      adapterCount: this.adapters.size,
      adapters: Array.from(this.adapters.keys())
    });
  }

  /**
   * Initialize all data source adapters
   */
  private initializeAdapters(): void {
    logger.info('Initializing data source adapters');

    // PostgreSQL adapter
    try {
      const postgres = new PostgresAdapter();
      this.adapters.set('postgres', postgres);
      logger.info('PostgreSQL adapter registered');
    } catch (error) {
      logger.warn('Failed to register PostgreSQL adapter', { error: this.normalizeError(error) });
    }

    // SQLite adapter
    try {
      const sqlite = new SQLiteAdapter();
      this.adapters.set('sqlite', sqlite);
      logger.info('SQLite adapter registered');
    } catch (error) {
      logger.warn('Failed to register SQLite adapter', { error: this.normalizeError(error) });
    }

    // GitHub adapter
    try {
      const github = new GitHubAdapter();
      this.adapters.set('github', github);
      logger.info('GitHub adapter registered');
    } catch (error) {
      logger.warn('Failed to register GitHub adapter', { error: this.normalizeError(error) });
    }

    // REST API adapter
    try {
      const restApi = new RestApiAdapter();
      this.adapters.set('rest-api', restApi);
      logger.info('REST API adapter registered');
    } catch (error) {
      logger.warn('Failed to register REST API adapter', { error: this.normalizeError(error) });
    }

    // Initialize all adapters
    const initPromises = Array.from(this.adapters.values()).map(async (adapter) => {
      try {
        await adapter.initialize();
        logger.info(`Adapter initialized: ${adapter.id}`);
      } catch (error) {
        logger.error(`Failed to initialize adapter: ${adapter.id}`, {
          error: this.normalizeError(error)
        });
      }
    });

    // Wait for all adapters to initialize (or fail)
    Promise.allSettled(initPromises).then((results) => {
      const succeeded = results.filter(r => r.status === 'fulfilled').length;
      const failed = results.filter(r => r.status === 'rejected').length;
      logger.info('Adapter initialization complete', { succeeded, failed, total: results.length });
    });
  }

  /**
   * Normalize error for logging
   */
  private normalizeError(error: unknown): string {
    if (error instanceof Error) {
      return error.message;
    }
    return String(error);
  }

  /**
   * Register all MCP tools
   */
  private registerTools(): void {
    logger.info('Registering knowledge server tools');

    // Query tool - search across all data sources
    this.server.tool(
      'search_knowledge',
      {
        query: z.string().describe('The search query'),
        sources: z.array(z.string()).optional().describe('Specific data sources to search (e.g., ["postgres", "github"])'),
        limit: z.number().optional().default(20).describe('Maximum results per source')
      },
      async ({ query, sources = [], limit = 20 }) => {
        logger.debug('Executing knowledge search', { query, sources, limit });

        const results: any[] = [];
        const errors: string[] = [];

        // Determine which adapters to use
        const adapters = sources.length > 0
          ? Array.from(this.adapters.entries()).filter(([id]) => sources.includes(id))
          : Array.from(this.adapters.entries());

        if (adapters.length === 0) {
          return {
            content: [
              {
                type: 'text',
                text: 'No data sources available. Please check adapter configurations.'
              }
            ]
          };
        }

        // Query each adapter in parallel
        const queryPromises = adapters.map(async ([id, adapter]) => {
          try {
            const result = await adapter.query({
              type: 'search',
              query,
              limit
            });

            if (result.success) {
              return {
                source: id,
                name: adapter.name,
                results: result.data,
                count: result.data.length,
                executionTime: result.metadata.executionTime
              };
            } else {
              errors.push(`${adapter.name}: ${result.error}`);
              return null;
            }
          } catch (error) {
            const errorMsg = this.normalizeError(error);
            errors.push(`${adapter.name}: ${errorMsg}`);
            return null;
          }
        });

        const queryResults = await Promise.all(queryPromises);
        const validResults = queryResults.filter(r => r !== null);

        // Build response
        let responseText = `Search Results for: "${query}"\n`;
        responseText += `================================\n\n`;

        if (validResults.length === 0) {
          responseText += 'No results found.\n';
          if (errors.length > 0) {
            responseText += '\nErrors encountered:\n';
            responseText += errors.map(e => `- ${e}`).join('\n');
          }
        } else {
          for (const result of validResults) {
            responseText += `[${result.source}] ${result.count} results (${result.executionTime}ms)\n`;
            if (result.results.length > 0) {
              responseText += JSON.stringify(result.results, null, 2);
              responseText += '\n\n';
            }
          }

          if (errors.length > 0) {
            responseText += '\nErrors encountered:\n';
            responseText += errors.map(e => `- ${e}`).join('\n');
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
              text: JSON.stringify({
                query,
                results: validResults,
                errors
              }, null, 2)
            }
          ]
        };
      }
    );

    // Health check tool - check all adapters
    this.server.tool(
      'health_check',
      {},
      async () => {
        logger.debug('Performing health check');

        const checks = await Promise.all(
          Array.from(this.adapters.entries()).map(async ([id, adapter]) => {
            const status = await adapter.healthCheck();
            return {
              source: id,
              name: adapter.name,
              healthy: status.healthy,
              message: status.message,
              details: status.details
            };
          })
        );

        const allHealthy = checks.every(c => c.healthy);

        return {
          content: [
            {
              type: 'text',
              text: `Health Check:\n${allHealthy ? '✅ All systems operational' : '⚠️ Some systems have issues'}\n\n${checks.map(c => 
                `- ${c.name}: ${c.healthy ? '✅' : '❌'} ${c.message}`
              ).join('\n')}`
            },
            {
              type: 'text',
              text: JSON.stringify({
                healthy: allHealthy,
                checks
              }, null, 2)
            }
          ]
        };
      }
    );

    logger.info('Knowledge server tools registered successfully');
  }

  /**
   * Register all MCP resources
   */
  private registerResources(): void {
    logger.info('Registering knowledge server resources');

    // Knowledge index resource
    this.server.resource(
      'knowledge_index',
      'knowledge://index',
      {
        description: 'Index of all available knowledge sources',
        mimeType: 'application/json'
      },
      async () => {
        logger.debug('Getting knowledge index');

        const sources = Array.from(this.adapters.entries()).map(([id, adapter]) => ({
          id,
          name: adapter.name,
          description: adapter.description,
          status: adapter.isInitialized() ? 'online' : 'offline'
        }));

        return {
          contents: [
            {
              uri: 'knowledge://index',
              text: JSON.stringify({
                version: process.env.MCP_SERVER_VERSION || '1.0.0',
                sources,
                total: sources.length,
                online: sources.filter(s => s.status === 'online').length
              }, null, 2),
              mimeType: 'application/json'
            }
          ]
        };
      }
    );

    // Forward adapter resources
    for (const [id, adapter] of this.adapters) {
      try {
        const resources = await adapter.listResources();
        for (const resource of resources.resources) {
          this.server.resource(
            `${id}_${resource.uri}`,
            resource.uri,
            {
              description: resource.description || `${adapter.name} resource: ${resource.name}`,
              mimeType: resource.mimeType || 'application/json'
            },
            async (uri: string) => {
              const data = await adapter.getResource(uri);
              return {
                contents: [
                  {
                    uri: data.uri,
                    text: typeof data.content === 'string' ? data.content : data.content.toString(),
                    mimeType: data.mimeType
                  }
                ]
              };
            }
          );
          logger.debug(`Registered resource: ${resource.uri}`);
        }
        logger.info(`Registered ${resources.resources.length} resources from ${adapter.name}`);
      } catch (error) {
        logger.warn(`Failed to register resources from ${adapter.name}`, {
          error: this.normalizeError(error)
        });
      }
    }

    logger.info('Knowledge server resources registered successfully');
  }

  /**
   * Register all MCP prompts
   */
  private registerPrompts(): void {
    logger.info('Registering knowledge server prompts');

    // Knowledge discovery prompt
    this.server.prompt(
      'discover_knowledge',
      {
        topic: z.string().describe('The topic to research'),
        depth: z.enum(['brief', 'detailed', 'comprehensive']).optional().default('detailed').describe('Research depth')
      },
      ({ topic, depth }) => {
        logger.debug('Generating knowledge discovery prompt', { topic, depth });

        const depthMapping = {
          brief: 'Provide a concise overview with key facts',
          detailed: 'Provide comprehensive information with examples and references',
          comprehensive: 'Provide exhaustive research with multiple perspectives and sources'
        };

        const prompt = `You are a Knowledge Discovery Assistant for the Enterprise Knowledge Server.

**Research Topic:** ${topic}
**Depth:** ${depth} (${depthMapping[depth]})

**Available Knowledge Sources:**
${Array.from(this.adapters.values()).map(a => `- ${a.name}: ${a.description}`).join('\n')}

Please:
1. Search across all available knowledge sources
2. Synthesize information from multiple sources
3. ${depth === 'brief' ? 'Provide key findings and summary' : 
   depth === 'detailed' ? 'Provide detailed findings with supporting evidence' :
   'Provide comprehensive analysis with all relevant details'}
4. Identify gaps in the knowledge
5. Suggest follow-up research questions

Use the search_knowledge tool to query the knowledge sources.`;

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

    // Data analysis prompt
    this.server.prompt(
      'analyze_data',
      {
        dataSource: z.string().describe('The data source to analyze'),
        analysisType: z.enum(['summary', 'trends', 'correlations', 'anomalies']).describe('Type of analysis'),
        query: z.string().optional().describe('Specific query to run')
      },
      ({ dataSource, analysisType, query }) => {
        logger.debug('Generating data analysis prompt', { dataSource, analysisType });

        const prompt = `You are a Data Analysis Assistant for the Enterprise Knowledge Server.

**Data Source:** ${dataSource}
**Analysis Type:** ${analysisType}
${query ? `**Query:** ${query}` : ''}

Available data sources:
${Array.from(this.adapters.values()).map(a => `- ${a.name}: ${a.description}`).join('\n')}

Please:
1. Access the specified data source
2. ${analysisType === 'summary' ? 'Generate summary statistics and distributions' :
   analysisType === 'trends' ? 'Identify trends and patterns over time' :
   analysisType === 'correlations' ? 'Find correlations between variables' :
   'Detect anomalies and outliers'}
3. Provide actionable insights
4. Suggest further analysis

Use the appropriate tools to query the data source and analyze the results.`;

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

    // Cross-source insight prompt
    this.server.prompt(
      'cross_source_insights',
      {
        topic: z.string().describe('The topic to investigate across sources'),
        sources: z.array(z.string()).optional().describe('Specific sources to include')
      },
      ({ topic, sources = [] }) => {
        logger.debug('Generating cross-source insights prompt', { topic, sources });

        const sourceList = sources.length > 0 
          ? sources.map(s => `- ${s}`).join('\n')
          : 'All available sources';

        const prompt = `You are a Cross-Source Analyst for the Enterprise Knowledge Server.

**Topic:** ${topic}
**Sources:** ${sourceList}

Please:
1. Query multiple knowledge sources about the topic
2. Compare and contrast information from different sources
3. Identify consensus and contradictions
4. Synthesize a unified understanding
5. Highlight unique insights from each source

**Available Knowledge Sources:**
${Array.from(this.adapters.values()).map(a => `- ${a.name}: ${a.description}`).join('\n')}

Use the search_knowledge tool to query all relevant sources and provide comprehensive analysis.`;

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

    logger.info('Knowledge server prompts registered successfully');
  }

  /**
   * Start the server
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server is already running');
      return;
    }

    logger.info('Starting Enterprise Knowledge Server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;

      logger.info('Knowledge Server started successfully');
      console.error('Enterprise Knowledge Server is running and waiting for connections...');
    } catch (error) {
      const errorMsg = this.normalizeError(error);
      logger.error('Failed to start Knowledge Server', { error: errorMsg });
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

    logger.info('Stopping Enterprise Knowledge Server...');

    try {
      // Shut down all adapters
      const shutdownPromises = Array.from(this.adapters.values()).map(async (adapter) => {
        try {
          await adapter.shutdown();
          logger.debug(`Adapter shut down: ${adapter.id}`);
        } catch (error) {
          logger.error(`Failed to shut down adapter: ${adapter.id}`, {
            error: this.normalizeError(error)
          });
        }
      });

      await Promise.allSettled(shutdownPromises);

      this.isRunning = false;
      logger.info('Knowledge Server stopped successfully');
    } catch (error) {
      const errorMsg = this.normalizeError(error);
      logger.error('Failed to stop Knowledge Server', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Get the status of all adapters
   */
  async getStatus(): Promise<Record<string, any>> {
    const status: Record<string, any> = {};

    for (const [id, adapter] of this.adapters) {
      const health = await adapter.healthCheck();
      status[id] = {
        name: adapter.name,
        initialized: adapter.isInitialized(),
        healthy: health.healthy,
        message: health.message,
        details: health.details
      };
    }

    return status;
  }
}
```

### Step 5: Create Entry Point

**File:** `ai-integration-javascript/mcp-protocol/servers/knowledge-server/src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { KnowledgeServer } from './knowledge-server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const handleShutdown = async (server: KnowledgeServer): Promise<void> => {
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
  logger.info('Starting Enterprise Knowledge Server entry point');

  try {
    const server = new KnowledgeServer();

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

    // Log status after startup
    const status = await server.getStatus();
    logger.info('Server status', { status });

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

if (import.meta.url === `file://${process.argv[1]}`) {
  void main();
}

export { KnowledgeServer };
```

## The Verification

### Step 1: Build the Knowledge Server

```bash
cd ai-integration-javascript/mcp-protocol/servers/knowledge-server
npm install
npm run build
```

### Step 2: Ensure Required Services are Running

```bash
# Start PostgreSQL (if needed)
docker run --name postgres-mcp -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine

# Create SQLite data directory
mkdir -p data
```

### Step 3: Start the Knowledge Server

```bash
npm start
```

### Step 4: Test with the MCP Client

Create a comprehensive test script:

**File:** `test-knowledge-server.js`

```javascript
import { createMCPClient } from '../clients/mcp-client-lib/dist/index.js';

const client = createMCPClient({
  servers: [{
    id: 'knowledge',
    transport: {
      type: 'stdio',
      command: 'node',
      args: ['dist/index.js']
    }
  }],
  debug: true
});

await client.connectAll();

console.log('=== Testing Knowledge Server ===\n');

// Test health check
const health = await client.callTool('knowledge', 'health_check', {});
console.log('Health Check:', health.content[0].text);

// Test knowledge search
const search = await client.callTool('knowledge', 'search_knowledge', {
  query: 'SELECT * FROM users LIMIT 5',
  sources: ['postgres', 'sqlite'],
  limit: 5
});
console.log('\nSearch Results:', search.content[0].text.substring(0, 500));

// Test knowledge index resource
const index = await client.readResource('knowledge', 'knowledge://index');
console.log('\nKnowledge Index:', index.contents[0].text.substring(0, 300));

// Test discovery prompt
const prompt = await client.executePrompt('knowledge', 'discover_knowledge', {
  topic: 'Database schema',
  depth: 'brief'
});
console.log('\nDiscovery Prompt:', prompt.messages[0].content.text.substring(0, 300));

await client.disconnectAll();
console.log('\n✅ Knowledge Server test complete!');
```

### Step 5: Expected Output

```
=== Testing Knowledge Server ===

Health Check: Health Check:
✅ All systems operational

- PostgreSQL: ✅ Connected to PostgreSQL
- SQLite: ✅ Connected to SQLite
- GitHub: ❌ GitHub token is required
- REST API: ❌ REST API base URL is required

Search Results: Search Results for: "SELECT * FROM users LIMIT 5"
================================

[postgres] 5 results (45ms)
[
  { "id": 1, "name": "Alice", "email": "alice@example.com", "age": 30 },
  { "id": 2, "name": "Bob", "email": "bob@example.com", "age": 25 },
  ...

Knowledge Index: {
  "version": "1.0.0",
  "sources": [
    { "id": "postgres", "name": "PostgreSQL", "status": "online" },
    { "id": "sqlite", "name": "SQLite", "status": "online" },
    { "id": "github", "name": "GitHub", "status": "offline" },
    { "id": "rest-api", "name": "REST API", "status": "offline" }
  ],
  "total": 4,
  "online": 2
}

Discovery Prompt: You are a Knowledge Discovery Assistant for the Enterprise Knowledge Server.

**Research Topic:** Database schema
**Depth:** brief (Provide a concise overview with key facts)

**Available Knowledge Sources:**
- PostgreSQL: Production PostgreSQL database with schema introspection
- SQLite: Embedded SQLite database for local data
...
```

## What You've Built

You've built the **Enterprise Knowledge Server** — a unified MCP server that aggregates multiple data sources:

### Components
1. **Adapter Architecture** — Pluggable data source adapters
2. **PostgreSQL Adapter** — Production database integration
3. **SQLite Adapter** — Local database support
4. **GitHub Adapter** — Repository, issue, and code access
5. **REST API Adapter** — External service integration

### Features
1. **Unified Search** — Search across all data sources simultaneously
2. **Resource Aggregation** — All data sources exposed as MCP resources
3. **Health Monitoring** — Check status of all data sources
4. **Cross-Source Analysis** — Combine insights from multiple sources
5. **Knowledge Discovery** — AI-driven research across all sources

### Architecture Benefits
1. **Single Access Point** — AI agents connect to one server
2. **Consistent Interface** — Same tools/resources/prompts for all data
3. **Extensible** — Add new adapters easily
4. **Fault Tolerant** — Individual source failures don't break the server
5. **Scalable** — Add more data sources over time

## Key Takeaways

1. **Abstraction is Powerful** — Hide complexity behind a unified interface
2. **Adapters Enable Integration** — Each data source gets its own adapter
3. **Fault Tolerance Matters** — One failing source shouldn't break everything
4. **Search is the Gateway** — Unified search makes all data accessible
5. **Resources Provide Discovery** — AI can discover what's available
6. **Prompts Guide Analysis** — Help AI use the system effectively

## What's Next?

In **Part 7**, we'll build an **Autonomous Research Assistant** — an AI agent that uses the Knowledge Server to independently plan, execute, and analyze research tasks. This is where we transition from infrastructure to true AI agents.
