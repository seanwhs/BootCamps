# Appendix D: Common Recipes and Troubleshooting

## Overview

This appendix provides practical recipes for common scenarios and troubleshooting guides for issues you might encounter when building MCP and A2A systems. Each recipe includes a complete, copy-pasteable solution.

## Part 1: MCP Server Recipes

### Recipe 1: Server with Environment Configuration

**Problem:** You need to configure your MCP server based on environment variables.

**Solution:**

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

// Configuration with defaults
const config = {
  name: process.env.MCP_SERVER_NAME || 'my-server',
  version: process.env.MCP_SERVER_VERSION || '1.0.0',
  debug: process.env.DEBUG === 'true',
  port: parseInt(process.env.PORT || '3000'),
  databaseUrl: process.env.DATABASE_URL,
  apiKey: process.env.API_KEY,
  maxRetries: parseInt(process.env.MAX_RETRIES || '3')
};

export class ConfigurableServer {
  private server: McpServer;
  
  constructor() {
    this.server = new McpServer({
      name: config.name,
      version: config.version
    });
    
    this.registerTools();
    this.registerResources();
  }
  
  private registerTools(): void {
    // Tool with environment-specific behavior
    this.server.tool(
      'get_config',
      {
        key: z.string().describe('Configuration key to retrieve')
      },
      async ({ key }) => {
        // Only allow reading non-sensitive config
        const safeKeys = ['name', 'version', 'debug', 'maxRetries'];
        
        if (!safeKeys.includes(key)) {
          return {
            content: [
              {
                type: 'text',
                text: `Access denied: ${key} is not accessible`
              }
            ],
            isError: true
          };
        }
        
        const value = config[key as keyof typeof config];
        
        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify({ key, value }, null, 2)
            }
          ]
        };
      }
    );
  }
  
  private registerResources(): void {
    this.server.resource(
      'server_config',
      'config://server',
      {
        description: 'Server configuration (safe values only)',
        mimeType: 'application/json'
      },
      async () => {
        const safeConfig = {
          name: config.name,
          version: config.version,
          debug: config.debug,
          maxRetries: config.maxRetries
        };
        
        return {
          contents: [
            {
              uri: 'config://server',
              text: JSON.stringify(safeConfig, null, 2),
              mimeType: 'application/json'
            }
          ]
        };
      }
    );
  }
  
  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Server started with config:', config);
  }
}
```

### Recipe 2: Tool with Retry Logic

**Problem:** Your tool calls an unreliable external API and needs retry logic.

**Solution:**

```typescript
import { z } from 'zod';
import axios, { AxiosError } from 'axios';

interface RetryConfig {
  maxRetries: number;
  initialDelay: number;
  maxDelay: number;
  backoffMultiplier: number;
}

export function createRetryableTool(
  name: string,
  description: string,
  schema: z.ZodSchema,
  operation: (args: any) => Promise<any>,
  config: RetryConfig = {
    maxRetries: 3,
    initialDelay: 1000,
    maxDelay: 30000,
    backoffMultiplier: 2
  }
) {
  return {
    name,
    description,
    schema,
    handler: async (args: any) => {
      let lastError: Error | null = null;
      let delay = config.initialDelay;
      
      for (let attempt = 1; attempt <= config.maxRetries + 1; attempt++) {
        try {
          // Execute the operation
          const result = await operation(args);
          
          return {
            content: [
              {
                type: 'text',
                text: typeof result === 'string' ? result : JSON.stringify(result, null, 2)
              },
              {
                type: 'text',
                text: JSON.stringify({
                  success: true,
                  attempts: attempt,
                  result
                }, null, 2)
              }
            ]
          };
        } catch (error) {
          lastError = error as Error;
          
          // Check if error is retryable
          if (!isRetryable(error)) {
            break;
          }
          
          // Last attempt - don't retry
          if (attempt === config.maxRetries + 1) {
            break;
          }
          
          // Wait before retrying
          await sleep(delay);
          delay = Math.min(delay * config.backoffMultiplier, config.maxDelay);
        }
      }
      
      return {
        content: [
          {
            type: 'text',
            text: `Operation failed after retries: ${lastError?.message}`
          }
        ],
        isError: true
      };
    }
  };
}

function isRetryable(error: any): boolean {
  if (axios.isAxiosError(error)) {
    const axiosError = error as AxiosError;
    
    // Network errors
    if (!axiosError.response) {
      return true;
    }
    
    // Server errors (5xx) or rate limiting (429)
    const status = axiosError.response.status;
    return status >= 500 || status === 429;
  }
  
  return false;
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Usage
const fetchApiTool = createRetryableTool(
  'fetch_api',
  'Fetch data from external API with retry logic',
  z.object({
    endpoint: z.string(),
    params: z.record(z.any()).optional()
  }),
  async ({ endpoint, params }) => {
    const response = await axios.get(endpoint, { params });
    return response.data;
  },
  {
    maxRetries: 5,
    initialDelay: 1000,
    maxDelay: 30000,
    backoffMultiplier: 2
  }
);
```

### Recipe 3: Resource with Pagination

**Problem:** Your resource returns large datasets and needs pagination.

**Solution:**

```typescript
import { z } from 'zod';

export class PaginatedResource {
  private data: any[];
  private pageSize: number = 100;
  
  constructor(data: any[], pageSize?: number) {
    this.data = data;
    if (pageSize) {
      this.pageSize = pageSize;
    }
  }
  
  getHandler() {
    return {
      scheme: 'paginated',
      handler: async (uri: string) => {
        // Parse URI: paginated://{resource}?page={page}&limit={limit}
        const url = new URL(uri);
        const resource = url.hostname;
        const page = parseInt(url.searchParams.get('page') || '1');
        const limit = parseInt(url.searchParams.get('limit') || String(this.pageSize));
        
        // Calculate pagination
        const start = (page - 1) * limit;
        const end = start + limit;
        const total = this.data.length;
        const items = this.data.slice(start, end);
        
        return {
          contents: [
            {
              uri,
              text: JSON.stringify({
                resource,
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
                items
              }, null, 2),
              mimeType: 'application/json'
            }
          ],
          // Add pagination metadata
          metadata: {
            'X-Total-Count': total,
            'X-Page': page,
            'X-Total-Pages': Math.ceil(total / limit)
          }
        };
      }
    };
  }
}

// Register the resource
const paginatedResource = new PaginatedResource(largeDataset);
server.resource(
  'paginated_data',
  'paginated://*',
  {
    description: 'Paginated data resource',
    mimeType: 'application/json'
  },
  paginatedResource.getHandler().handler
);
```

### Recipe 4: Tool with Rate Limiting

**Problem:** Your tool needs to respect rate limits from external services.

**Solution:**

```typescript
import { RateLimiter } from 'limiter';

export class RateLimitedTool {
  private limiters: Map<string, RateLimiter> = new Map();
  
  constructor(
    private toolName: string,
    private defaultTokensPerInterval: number = 10,
    private defaultInterval: number = 60000 // 1 minute
  ) {}
  
  createRateLimitedTool(
    name: string,
    schema: z.ZodSchema,
    handler: (args: any) => Promise<any>,
    tokensPerInterval?: number,
    interval?: number
  ) {
    return {
      name,
      schema,
      handler: async (args: any) => {
        // Get or create rate limiter for this user/tool
        const key = this.getRateLimitKey(args);
        const limiter = this.getLimiter(key, tokensPerInterval, interval);
        
        // Wait for token
        const remaining = await limiter.removeTokens(1);
        
        if (remaining < 0) {
          return {
            content: [
              {
                type: 'text',
                text: 'Rate limit exceeded. Please try again later.'
              }
            ],
            isError: true
          };
        }
        
        // Execute the handler
        try {
          const result = await handler(args);
          return {
            content: [
              {
                type: 'text',
                text: typeof result === 'string' ? result : JSON.stringify(result, null, 2)
              }
            ]
          };
        } catch (error) {
          return {
            content: [
              {
                type: 'text',
                text: `Tool execution failed: ${error instanceof Error ? error.message : 'Unknown error'}`
              }
            ],
            isError: true
          };
        }
      }
    };
  }
  
  private getRateLimitKey(args: any): string {
    // Use API key or IP address to differentiate users
    const apiKey = args.apiKey || args.user || 'default';
    return `${this.toolName}:${apiKey}`;
  }
  
  private getLimiter(
    key: string,
    tokensPerInterval?: number,
    interval?: number
  ): RateLimiter {
    if (!this.limiters.has(key)) {
      this.limiters.set(
        key,
        new RateLimiter({
          tokensPerInterval: tokensPerInterval || this.defaultTokensPerInterval,
          interval: interval || this.defaultInterval,
          fireImmediately: true
        })
      );
    }
    return this.limiters.get(key)!;
  }
}

// Usage
const rateLimitedTool = new RateLimitedTool('api-tool');

server.tool(
  'call_api',
  {
    endpoint: z.string(),
    params: z.record(z.any()).optional(),
    apiKey: z.string().optional()
  },
  rateLimitedTool.createRateLimitedTool(
    'call_api',
    {
      endpoint: z.string(),
      params: z.record(z.any()).optional()
    },
    async ({ endpoint, params }) => {
      // API call logic
      const response = await axios.get(endpoint, { params });
      return response.data;
    },
    5, // 5 requests
    60000 // per minute
  ).handler
);
```

### Recipe 5: Tool with Circuit Breaker

**Problem:** Your tool should fail fast when a downstream service is unhealthy.

**Solution:**

```typescript
export class CircuitBreaker {
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private failures: number = 0;
  private successes: number = 0;
  private lastFailure: number = 0;
  
  constructor(
    private threshold: number = 5,
    private timeout: number = 30000, // 30 seconds
    private halfOpenMaxSuccesses: number = 3
  ) {}
  
  async execute<T>(operation: () => Promise<T>): Promise<T> {
    // Check state
    if (this.state === 'open') {
      // Check if timeout has elapsed
      if (Date.now() - this.lastFailure >= this.timeout) {
        this.state = 'half-open';
        this.successes = 0;
        console.log('Circuit breaker: half-open');
      } else {
        throw new Error('Circuit breaker is open');
      }
    }
    
    try {
      const result = await operation();
      
      // Success handling
      if (this.state === 'half-open') {
        this.successes++;
        if (this.successes >= this.halfOpenMaxSuccesses) {
          this.reset();
          console.log('Circuit breaker: closed (recovered)');
        }
      }
      
      return result;
      
    } catch (error) {
      // Failure handling
      this.failures++;
      this.lastFailure = Date.now();
      
      if (this.state === 'closed' && this.failures >= this.threshold) {
        this.state = 'open';
        console.log('Circuit breaker: open');
      }
      
      throw error;
    }
  }
  
  private reset(): void {
    this.state = 'closed';
    this.failures = 0;
    this.successes = 0;
  }
  
  getState(): 'closed' | 'open' | 'half-open' {
    return this.state;
  }
  
  getStats(): { failures: number; successes: number; state: string } {
    return {
      failures: this.failures,
      successes: this.successes,
      state: this.state
    };
  }
}

// Tool with circuit breaker
export function createCircuitBreakerTool(
  name: string,
  schema: z.ZodSchema,
  operation: (args: any) => Promise<any>,
  circuitBreaker: CircuitBreaker
) {
  return {
    name,
    schema,
    handler: async (args: any) => {
      try {
        const result = await circuitBreaker.execute(() => operation(args));
        
        return {
          content: [
            {
              type: 'text',
              text: typeof result === 'string' ? result : JSON.stringify(result, null, 2)
            },
            {
              type: 'text',
              text: JSON.stringify({
                success: true,
                circuitState: circuitBreaker.getState(),
                stats: circuitBreaker.getStats()
              }, null, 2)
            }
          ]
        };
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Circuit breaker error: ${error instanceof Error ? error.message : 'Unknown error'}`
            },
            {
              type: 'text',
              text: JSON.stringify({
                success: false,
                circuitState: circuitBreaker.getState(),
                stats: circuitBreaker.getStats()
              }, null, 2)
            }
          ],
          isError: true
        };
      }
    }
  };
}

// Usage
const breaker = new CircuitBreaker(3, 30000);

server.tool(
  'unreliable_service',
  {
    input: z.string()
  },
  createCircuitBreakerTool(
    'unreliable_service',
    {
      input: z.string()
    },
    async ({ input }) => {
      // Simulate unreliable service
      if (Math.random() < 0.7) {
        throw new Error('Service temporarily unavailable');
      }
      return { processed: input, timestamp: new Date().toISOString() };
    },
    breaker
  ).handler
);
```

## Part 2: MCP Client Recipes

### Recipe 6: Client with Server Discovery

**Problem:** Your client needs to discover and connect to multiple servers dynamically.

**Solution:**

```typescript
import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import fs from 'fs/promises';

export interface ServerDiscovery {
  id: string;
  name: string;
  command: string;
  args: string[];
  env?: Record<string, string>;
  enabled?: boolean;
}

export class DiscoveryClient {
  private clients: Map<string, McpClient> = new Map();
  private servers: Map<string, ServerDiscovery> = new Map();
  
  constructor(private discoveryPath: string) {}
  
  async loadDiscovery(): Promise<void> {
    try {
      const content = await fs.readFile(this.discoveryPath, 'utf-8');
      const config = JSON.parse(content);
      
      for (const server of config.servers || []) {
        if (server.enabled !== false) {
          this.servers.set(server.id, server);
        }
      }
      
      console.log(`Loaded ${this.servers.size} servers from discovery`);
    } catch (error) {
      console.warn('Failed to load discovery file, using defaults:', error);
    }
  }
  
  async connectServer(serverId: string): Promise<McpClient> {
    const config = this.servers.get(serverId);
    if (!config) {
      throw new Error(`Server ${serverId} not found in discovery`);
    }
    
    if (this.clients.has(serverId)) {
      return this.clients.get(serverId)!;
    }
    
    const client = new McpClient({
      name: 'discovery-client',
      version: '1.0.0'
    });
    
    const transport = new StdioClientTransport({
      command: config.command,
      args: config.args,
      env: config.env
    });
    
    await client.connect(transport);
    this.clients.set(serverId, client);
    
    console.log(`Connected to server: ${config.name} (${serverId})`);
    return client;
  }
  
  async connectAll(): Promise<void> {
    const promises = Array.from(this.servers.keys()).map(id => 
      this.connectServer(id).catch(error => {
        console.error(`Failed to connect to server ${id}:`, error);
      })
    );
    
    await Promise.all(promises);
  }
  
  async disconnectAll(): Promise<void> {
    const promises = Array.from(this.clients.entries()).map(([id, client]) =>
      client.close().then(() => {
        console.log(`Disconnected from server: ${id}`);
      }).catch(error => {
        console.error(`Error disconnecting from server ${id}:`, error);
      })
    );
    
    await Promise.all(promises);
    this.clients.clear();
  }
  
  getClient(serverId: string): McpClient | undefined {
    return this.clients.get(serverId);
  }
  
  listServers(): string[] {
    return Array.from(this.servers.keys());
  }
  
  getServerInfo(serverId: string): ServerDiscovery | undefined {
    return this.servers.get(serverId);
  }
}

// discovery.json
{
  "servers": [
    {
      "id": "knowledge",
      "name": "Knowledge Server",
      "command": "node",
      "args": ["servers/knowledge-server/dist/index.js"],
      "enabled": true
    },
    {
      "id": "database",
      "name": "Database Server",
      "command": "node",
      "args": ["servers/database-server/dist/index.js"],
      "env": {
        "DB_PATH": "./data/app.db"
      },
      "enabled": true
    },
    {
      "id": "github",
      "name": "GitHub Server",
      "command": "node",
      "args": ["servers/github-server/dist/index.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "enabled": false
    }
  ]
}
```

### Recipe 7: Client with Retry and Reconnection

**Problem:** Your client needs to automatically reconnect when connections fail.

**Solution:**

```typescript
import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

export class ResilientClient {
  private client: McpClient;
  private transport: StdioClientTransport;
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectDelay: number = 1000;
  private isReconnecting: boolean = false;
  private heartbeatInterval?: NodeJS.Timeout;
  
  constructor(
    private serverConfig: {
      command: string;
      args: string[];
      env?: Record<string, string>;
    },
    private options: {
      maxReconnectAttempts?: number;
      reconnectDelay?: number;
      heartbeatInterval?: number;
    } = {}
  ) {
    this.maxReconnectAttempts = options.maxReconnectAttempts || 5;
    this.reconnectDelay = options.reconnectDelay || 1000;
    
    this.client = new McpClient({
      name: 'resilient-client',
      version: '1.0.0'
    });
    
    this.transport = new StdioClientTransport(serverConfig);
    
    // Setup connection monitoring
    this.setupMonitoring();
  }
  
  private setupMonitoring(): void {
    // Heartbeat to check connection
    if (this.options.heartbeatInterval) {
      this.heartbeatInterval = setInterval(() => {
        this.ping().catch(() => {
          console.log('Heartbeat failed, reconnecting...');
          this.reconnect();
        });
      }, this.options.heartbeatInterval);
    }
  }
  
  async connect(): Promise<void> {
    try {
      await this.client.connect(this.transport);
      this.reconnectAttempts = 0;
      console.log('Connected to server');
    } catch (error) {
      console.error('Initial connection failed:', error);
      await this.reconnect();
    }
  }
  
  async reconnect(): Promise<void> {
    if (this.isReconnecting) {
      console.log('Already reconnecting...');
      return;
    }
    
    this.isReconnecting = true;
    this.reconnectAttempts++;
    
    console.log(`Reconnection attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts}`);
    
    try {
      // Close existing connection
      try {
        await this.client.close();
      } catch (_) {}
      
      // Create new client and transport
      this.client = new McpClient({
        name: 'resilient-client',
        version: '1.0.0'
      });
      
      this.transport = new StdioClientTransport(this.serverConfig);
      await this.client.connect(this.transport);
      
      this.reconnectAttempts = 0;
      this.isReconnecting = false;
      console.log('Reconnected successfully');
      
    } catch (error) {
      console.error('Reconnection failed:', error);
      this.isReconnecting = false;
      
      if (this.reconnectAttempts < this.maxReconnectAttempts) {
        // Exponential backoff
        const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts);
        console.log(`Retrying in ${delay}ms...`);
        setTimeout(() => this.reconnect(), delay);
      } else {
        console.error('Max reconnection attempts reached');
        throw new Error('Failed to reconnect after max attempts');
      }
    }
  }
  
  async ping(): Promise<boolean> {
    try {
      // Try to list tools as a health check
      await this.client.listTools();
      return true;
    } catch (error) {
      return false;
    }
  }
  
  async callTool(name: string, args: any): Promise<any> {
    try {
      return await this.client.callTool(name, args);
    } catch (error) {
      // If connection is lost, attempt reconnect and retry
      if (error instanceof Error && error.message.includes('connection')) {
        await this.reconnect();
        return await this.client.callTool(name, args);
      }
      throw error;
    }
  }
  
  async close(): Promise<void> {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
    }
    await this.client.close();
  }
  
  getClient(): McpClient {
    return this.client;
  }
}
```

### Recipe 8: Client with Request Caching

**Problem:** Your client makes repeated identical requests and wants to cache results.

**Solution:**

```typescript
import NodeCache from 'node-cache';

export class CachingClient {
  private cache: NodeCache;
  private client: McpClient;
  
  constructor(
    client: McpClient,
    ttlSeconds: number = 300, // 5 minutes
    maxKeys: number = 100
  ) {
    this.client = client;
    this.cache = new NodeCache({
      stdTTL: ttlSeconds,
      maxKeys: maxKeys,
      checkperiod: 60
    });
  }
  
  async callTool(
    name: string,
    args: any,
    options: {
      cache?: boolean;
      ttl?: number;
      cacheKey?: string;
    } = {}
  ): Promise<any> {
    // Skip cache if disabled
    if (options.cache === false) {
      return this.client.callTool(name, args);
    }
    
    // Generate cache key
    const cacheKey = options.cacheKey || this.generateCacheKey(name, args);
    
    // Check cache
    const cached = this.cache.get(cacheKey);
    if (cached) {
      console.log(`Cache hit for ${name}: ${cacheKey}`);
      return cached;
    }
    
    console.log(`Cache miss for ${name}: ${cacheKey}`);
    
    // Execute tool
    const result = await this.client.callTool(name, args);
    
    // Cache result
    const ttl = options.ttl || this.cache.options.stdTTL;
    this.cache.set(cacheKey, result, ttl);
    
    return result;
  }
  
  async readResource(
    uri: string,
    options: {
      cache?: boolean;
      ttl?: number;
      cacheKey?: string;
    } = {}
  ): Promise<any> {
    if (options.cache === false) {
      return this.client.readResource(uri);
    }
    
    const cacheKey = options.cacheKey || `resource:${uri}`;
    
    const cached = this.cache.get(cacheKey);
    if (cached) {
      console.log(`Cache hit for resource: ${uri}`);
      return cached;
    }
    
    console.log(`Cache miss for resource: ${uri}`);
    
    const result = await this.client.readResource(uri);
    const ttl = options.ttl || this.cache.options.stdTTL;
    this.cache.set(cacheKey, result, ttl);
    
    return result;
  }
  
  private generateCacheKey(name: string, args: any): string {
    return `tool:${name}:${JSON.stringify(args)}`;
  }
  
  getStats(): { keys: number; hits: number; misses: number } {
    return this.cache.getStats();
  }
  
  clear(): void {
    this.cache.flushAll();
  }
  
  invalidate(pattern?: string): void {
    if (!pattern) {
      this.cache.flushAll();
      return;
    }
    
    const keys = this.cache.keys();
    const regex = new RegExp(pattern);
    const toDelete = keys.filter(k => regex.test(k));
    this.cache.del(toDelete);
  }
}

// Usage
const client = new McpClient({
  name: 'caching-client',
  version: '1.0.0'
});

const cachingClient = new CachingClient(client, 600); // 10 minutes TTL

// First call - cache miss
const result1 = await cachingClient.callTool('expensive_op', { id: 123 });

// Second call - cache hit
const result2 = await cachingClient.callTool('expensive_op', { id: 123 });

// Invalidate specific tool calls
cachingClient.invalidate('expensive_op');
```

## Part 3: A2A Recipes

### Recipe 9: A2A Message Validation

**Problem:** You need to validate A2A messages before processing.

**Solution:**

```typescript
import { z } from 'zod';
import { A2AMessage, MessageType, MessagePriority } from './types.js';

// Validation schemas
const MessageSchema = z.object({
  id: z.string().uuid(),
  type: z.enum(['request', 'response', 'delegation', 'notification', 'broadcast', 'workflow', 'status', 'query']),
  from: z.string().min(1),
  to: z.union([z.string(), z.array(z.string())]),
  subject: z.string().min(1).max(500),
  body: z.any(),
  priority: z.enum(['low', 'medium', 'high', 'critical']).default('medium'),
  createdAt: z.date(),
  requiresResponse: z.boolean().default(false),
  responseTo: z.string().uuid().optional(),
  workflowId: z.string().optional(),
  ttl: z.number().positive().optional()
});

export class MessageValidator {
  static validate(message: any): { valid: boolean; errors?: string[] } {
    try {
      MessageSchema.parse(message);
      return { valid: true };
    } catch (error) {
      if (error instanceof z.ZodError) {
        return {
          valid: false,
          errors: error.errors.map(e => `${e.path.join('.')}: ${e.message}`)
        };
      }
      return {
        valid: false,
        errors: ['Unknown validation error']
      };
    }
  }
  
  static validateMessageType(message: A2AMessage): boolean {
    // Specific validation based on message type
    switch (message.type) {
      case 'request':
        return this.validateRequest(message);
      case 'response':
        return this.validateResponse(message);
      case 'delegation':
        return this.validateDelegation(message);
      case 'notification':
        return this.validateNotification(message);
      default:
        return true;
    }
  }
  
  private static validateRequest(message: A2AMessage): boolean {
    // Request must have body
    if (!message.body) {
      return false;
    }
    
    // Request should expect a response by default
    if (message.requiresResponse !== true) {
      return false;
    }
    
    return true;
  }
  
  private static validateResponse(message: A2AMessage): boolean {
    // Response must have responseTo
    if (!message.responseTo) {
      return false;
    }
    
    // Response should not expect a response
    if (message.requiresResponse) {
      return false;
    }
    
    return true;
  }
  
  private static validateDelegation(message: A2AMessage): boolean {
    // Delegation must have task information
    if (!message.body || !message.body.taskId) {
      return false;
    }
    
    // Delegation should have high priority
    if (message.priority === 'low') {
      return false;
    }
    
    return true;
  }
  
  private static validateNotification(message: A2AMessage): boolean {
    // Notification should have body
    if (!message.body) {
      return false;
    }
    
    // Notification should not expect a response
    if (message.requiresResponse) {
      return false;
    }
    
    return true;
  }
}

// Usage in router
class ValidatingRouter extends MessageRouter {
  async send(message: A2AMessage): Promise<void> {
    // Validate before sending
    const validation = MessageValidator.validate(message);
    if (!validation.valid) {
      throw new Error(`Invalid message: ${validation.errors?.join(', ')}`);
    }
    
    await super.send(message);
  }
  
  async deliverMessage(message: A2AMessage): Promise<void> {
    // Validate again before delivery
    const validation = MessageValidator.validate(message);
    if (!validation.valid) {
      throw new Error(`Invalid message for delivery: ${validation.errors?.join(', ')}`);
    }
    
    await super.deliverMessage(message);
  }
}
```

### Recipe 10: A2A Workflow with Human Approval

**Problem:** You need a workflow that requires human approval at certain steps.

**Solution:**

```typescript
import { BaseAgent } from './base-agent.js';
import { A2AMessage } from './types.js';

export interface ApprovalRequest {
  stepId: string;
  action: string;
  description: string;
  data: any;
  status: 'pending' | 'approved' | 'rejected' | 'expired';
  requestedAt: Date;
  decidedAt?: Date;
  decidedBy?: string;
  reason?: string;
}

export class HumanApprovalAgent extends BaseAgent {
  private pendingApprovals: Map<string, ApprovalRequest> = new Map();
  
  // Override delegation handler to check for human approval
  protected async processDelegation(task: any): Promise<any> {
    // Check if this task requires human approval
    if (task.requiresApproval) {
      const approval = await this.requestApproval(task);
      
      if (approval.status !== 'approved') {
        throw new Error(`Task rejected by human: ${approval.reason || 'No reason provided'}`);
      }
    }
    
    // Continue with normal processing
    return super.processDelegation(task);
  }
  
  async requestApproval(task: any): Promise<ApprovalRequest> {
    const request: ApprovalRequest = {
      stepId: task.taskId || `approval-${Date.now()}`,
      action: task.description || 'Unknown action',
      description: task.details || 'No details provided',
      data: task,
      status: 'pending',
      requestedAt: new Date()
    };
    
    this.pendingApprovals.set(request.stepId, request);
    
    // Notify human through external channel (email, Slack, etc.)
    await this.notifyHuman(request);
    
    // Wait for approval (with timeout)
    const timeout = task.approvalTimeout || 3600000; // 1 hour default
    const approved = await this.waitForApproval(request.stepId, timeout);
    
    return approved;
  }
  
  private async notifyHuman(request: ApprovalRequest): Promise<void> {
    // Send notification to human
    console.log(`🔔 Approval Required:`);
    console.log(`   Step: ${request.action}`);
    console.log(`   Description: ${request.description}`);
    console.log(`   Data: ${JSON.stringify(request.data, null, 2)}`);
    console.log(`   To approve: respond to this message with 'approve ${request.stepId}'`);
    console.log(`   To reject: respond with 'reject ${request.stepId} [reason]'`);
    
    // In production, this would send an email, Slack message, etc.
  }
  
  private waitForApproval(stepId: string, timeout: number): Promise<ApprovalRequest> {
    return new Promise((resolve, reject) => {
      const startTime = Date.now();
      
      const checkInterval = setInterval(() => {
        // Check if approved
        const request = this.pendingApprovals.get(stepId);
        if (!request) {
          clearInterval(checkInterval);
          reject(new Error(`Approval request ${stepId} not found`));
          return;
        }
        
        if (request.status !== 'pending') {
          clearInterval(checkInterval);
          resolve(request);
          return;
        }
        
        // Check timeout
        if (Date.now() - startTime > timeout) {
          clearInterval(checkInterval);
          request.status = 'expired';
          this.pendingApprovals.set(stepId, request);
          reject(new Error(`Approval request ${stepId} timed out`));
        }
      }, 5000); // Check every 5 seconds
    });
  }
  
  // Method for human to approve a request
  approve(stepId: string, approver: string): boolean {
    const request = this.pendingApprovals.get(stepId);
    if (!request || request.status !== 'pending') {
      return false;
    }
    
    request.status = 'approved';
    request.decidedAt = new Date();
    request.decidedBy = approver;
    this.pendingApprovals.set(stepId, request);
    
    console.log(`✅ Approval granted for ${stepId} by ${approver}`);
    return true;
  }
  
  // Method for human to reject a request
  reject(stepId: string, approver: string, reason?: string): boolean {
    const request = this.pendingApprovals.get(stepId);
    if (!request || request.status !== 'pending') {
      return false;
    }
    
    request.status = 'rejected';
    request.decidedAt = new Date();
    request.decidedBy = approver;
    request.reason = reason;
    this.pendingApprovals.set(stepId, request);
    
    console.log(`❌ Approval rejected for ${stepId} by ${approver}: ${reason || 'No reason provided'}`);
    return true;
  }
  
  // Get pending approvals
  getPendingApprovals(): ApprovalRequest[] {
    return Array.from(this.pendingApprovals.values())
      .filter(req => req.status === 'pending');
  }
  
  // Setup message handlers for approval responses  protected setupHandlers(): void {
    super.setupHandlers();
    
    this.router.onMessage('notification', this.handleApprovalNotification.bind(this));
  }
  
  private async handleApprovalNotification(message: A2AMessage, reply: any): Promise<void> {
    // Handle approval messages from human interface
    const { action, stepId, reason } = message.body;
    
    if (action === 'approve') {
      const success = this.approve(stepId, message.from);
      if (success) {
        await reply({
          id: `reply-${Date.now()}`,
          type: 'response',
          from: this.identity.id,
          to: message.from,
          subject: 'Approval processed',
          body: { success: true, stepId, status: 'approved' },
          priority: 'medium',
          createdAt: new Date(),
          requiresResponse: false,
          responseTo: message.id
        });
      }
    } else if (action === 'reject') {
      const success = this.reject(stepId, message.from, reason);
      if (success) {
        await reply({
          id: `reply-${Date.now()}`,
          type: 'response',
          from: this.identity.id,
          to: message.from,
          subject: 'Rejection processed',
          body: { success: true, stepId, status: 'rejected', reason },
          priority: 'medium',
          createdAt: new Date(),
          requiresResponse: false,
          responseTo: message.id
        });
      }
    }
  }
}
```

## Part 4: Troubleshooting Guide

### Issue 1: Connection Refused

**Symptoms:** Client cannot connect to server, "ECONNREFUSED" errors.

**Solutions:**

1. **Check if server is running:**
```bash
ps aux | grep node
```

2. **Check port availability:**
```bash
netstat -tulpn | grep 3000
lsof -i :3000
```

3. **Verify transport configuration:**
```typescript
// Ensure correct command and args
const transport = new StdioClientTransport({
  command: 'node',
  args: ['dist/index.js'],
  cwd: '/absolute/path/to/server' // Use absolute path
});
```

4. **Check permissions:**
```bash
chmod +x server.js
```

### Issue 2: JSON Parse Error

**Symptoms:** "Unexpected token" or "SyntaxError: JSON.parse".

**Solutions:**

1. **Verify message format:**
```typescript
function logMessage(message: string) {
  console.log('Raw message:', message);
  try {
    console.log('Parsed:', JSON.parse(message));
  } catch (e) {
    console.error('Parse error:', e);
  }
}
```

2. **Check for trailing commas:**
```json
// Invalid
{"key": "value",}
// Valid
{"key": "value"}
```

3. **Handle non-JSON output:**
```typescript
// Server might output console logs that break JSON parsing
// Redirect stderr in transport
const transport = new StdioClientTransport({
  command: 'node',
  args: ['server.js'],
  stderr: 'pipe' // Capture stderr separately
});
```

### Issue 3: Tool Not Found

**Symptoms:** "Tool 'my_tool' not found", "METHOD_NOT_FOUND".

**Solutions:**

1. **List available tools:**
```typescript
const { tools } = await client.listTools();
console.log('Available tools:', tools.map(t => t.name));
```

2. **Check tool registration:**
```typescript
// Ensure tool is registered with correct name
server.tool(
  'my_tool', // Make sure this matches what you're calling
  { /* schema */ },
  async (/* args */) => { /* handler */ }
);
```

3. **Check for duplicate names:**
```typescript
// Tools must have unique names
const toolNames = new Set();
server.tool('add', {}, handler);
// This will override the first 'add' tool
server.tool('add', {}, handler2);
```

### Issue 4: TypeScript Compilation Errors

**Symptoms:** TypeScript errors when building.

**Solutions:**

1. **Check tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "strict": true
  }
}
```

2. **Install type definitions:**
```bash
npm install -D @types/node @types/sqlite3 @types/pg
```

3. **Use correct import syntax:**
```typescript
// ESM
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

// Not CommonJS
// const { McpServer } = require('@modelcontextprotocol/sdk');
```

### Issue 5: Memory Leaks

**Symptoms:** Memory usage grows over time.

**Solutions:**

1. **Clean up resources:**
```typescript
// Always close connections
await client.close();

// Clear intervals
if (interval) clearInterval(interval);

// Clear timeouts
if (timeout) clearTimeout(timeout);
```

2. **Use WeakMap for caches:**
```typescript
// Instead of Map, use WeakMap for automatic garbage collection
const cache = new WeakMap();
```

3. **Limit cache size:**
```typescript
class BoundedCache {
  private cache: Map<string, any> = new Map();
  private maxSize: number = 100;
  
  set(key: string, value: any): void {
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(key, value);
  }
}
```

### Issue 6: A2A Message Loops

**Symptoms:** Messages bouncing between agents infinitely.

**Solutions:**

1. **Track message IDs:**
```typescript
class LoopDetector {
  private processedIds: Set<string> = new Set();
  private maxHistory: number = 1000;
  
  isLoop(message: A2AMessage): boolean {
    // Check if we've seen this message before
    if (this.processedIds.has(message.id)) {
      return true;
    }
    
    this.processedIds.add(message.id);
    
    // Trim history
    if (this.processedIds.size > this.maxHistory) {
      const values = Array.from(this.processedIds).slice(-this.maxHistory);
      this.processedIds = new Set(values);
    }
    
    return false;
  }
}
```

2. **Implement message TTL:**
```typescript
function shouldProcessMessage(message: A2AMessage): boolean {
  // Check TTL
  if (message.ttl) {
    const age = Date.now() - message.createdAt.getTime();
    if (age > message.ttl) {
      console.log(`Message expired: ${message.id}`);
      return false;
    }
  }
  return true;
}
```

3. **Limit propagation depth:**
```typescript
function addPropagationDepth(message: A2AMessage, maxDepth: number = 5): boolean {
  const currentDepth = message.context?.depth || 0;
  
  if (currentDepth >= maxDepth) {
    return false;
  }
  
  message.context = {
    ...message.context,
    depth: currentDepth + 1
  };
  
  return true;
}
```

### Issue 7: Performance Bottlenecks

**Symptoms:** Slow response times, high CPU usage.

**Solutions:**

1. **Profile your code:**
```bash
node --inspect server.js
```

2. **Use async/await correctly:**
```typescript
// Bad: Sequential awaits
const result1 = await tool1();
const result2 = await tool2();
const result3 = await tool3();

// Good: Parallel execution
const [result1, result2, result3] = await Promise.all([
  tool1(),
  tool2(),
  tool3()
]);
```

3. **Implement connection pooling:**
```typescript
class PooledClient {
  private pool: McpClient[] = [];
  private maxPoolSize: number = 5;
  private current: number = 0;
  
  async getClient(): Promise<McpClient> {
    if (this.pool.length === 0) {
      for (let i = 0; i < this.maxPoolSize; i++) {
        const client = new McpClient({
          name: `client-${i}`,
          version: '1.0.0'
        });
        await client.connect(this.transport);
        this.pool.push(client);
      }
    }
    
    const client = this.pool[this.current % this.pool.length];
    this.current++;
    return client;
  }
}
```

## Quick Reference: Common Error Codes

| Code | Name | Common Cause | Solution |
|------|------|--------------|----------|
| -32700 | Parse Error | Invalid JSON | Validate message format |
| -32600 | Invalid Request | Missing fields | Check request structure |
| -32601 | Method Not Found | Wrong method name | List available methods |
| -32602 | Invalid Params | Wrong parameter types | Validate with Zod |
| -32603 | Internal Error | Server exception | Check server logs |
| -32001 | Tool Not Found | Missing tool | Register tool first |
| -32002 | Resource Not Found | Missing resource | Register resource first |
| -32003 | Prompt Not Found | Missing prompt | Register prompt first |
| -32004 | Tool Execution Error | Tool failure | Check tool implementation |
| -32008 | Connection Error | Network issue | Check connectivity |
| -32009 | Authentication Error | Invalid credentials | Check API key/token |

---

This appendix provides practical solutions for common scenarios and issues. For more complex problems, check the [official GitHub issues](https://github.com/modelcontextprotocol/sdk/issues) and [community discussions](https://github.com/modelcontextprotocol/sdk/discussions).
