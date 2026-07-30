# Appendix C: Complete API Reference — MCP SDK for JavaScript/TypeScript

## Overview

This appendix provides a comprehensive API reference for the Model Context Protocol (MCP) SDK for JavaScript and TypeScript. It covers all classes, methods, types, and utilities available in the official `@modelcontextprotocol/sdk` package.

## Installation

```bash
npm install @modelcontextprotocol/sdk
```

## Core Modules

### Server Module

The server module provides classes for building MCP servers.

#### McpServer

The main server class that manages tools, resources, and prompts.

**Constructor:**

```typescript
new McpServer(options: McpServerOptions)
```

**McpServerOptions:**

```typescript
interface McpServerOptions {
  // Server identification
  name: string;
  version: string;
  
  // Capabilities (auto-detected from registered items)
  capabilities?: {
    tools?: {};
    resources?: {};
    prompts?: {};
  };
  
  // Optional logger
  logger?: Logger;
}
```

**Methods:**

```typescript
// Register a tool
server.tool(
  name: string,                    // Tool name
  schema: z.ZodSchema,             // Input schema (Zod)
  handler: (args: any) => Promise<ToolResult>  // Implementation
): void;

// Register a resource
server.resource(
  name: string,                    // Resource name
  uri: string | RegExp,            // URI pattern
  options: ResourceOptions,        // Resource configuration
  handler: (uri: string) => Promise<ResourceContents>  // Implementation
): void;

// Register a prompt
server.prompt(
  name: string,                    // Prompt name
  schema: z.ZodSchema,             // Input schema (Zod)
  handler: (args: any) => PromptResult  // Implementation
): void;

// Connect to a transport
server.connect(
  transport: Transport              // Transport instance
): Promise<void>;

// Close the server
server.close(): Promise<void>;
```

**Example:**

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

const server = new McpServer({
  name: 'my-server',
  version: '1.0.0'
});

server.tool(
  'add',
  {
    a: z.number().describe('First number'),
    b: z.number().describe('Second number')
  },
  async ({ a, b }) => {
    return {
      content: [
        {
          type: 'text',
          text: `${a} + ${b} = ${a + b}`
        }
      ]
    };
  }
);
```

#### ToolResult

**Type Definition:**

```typescript
interface ToolResult {
  // Content items
  content: ToolContent[];
  
  // Whether the tool execution resulted in an error
  isError?: boolean;
}

type ToolContent = 
  | TextContent
  | ImageContent
  | ResourceContent;

interface TextContent {
  type: 'text';
  text: string;
}

interface ImageContent {
  type: 'image';
  data: string;        // Base64 encoded
  mimeType: string;
}

interface ResourceContent {
  type: 'resource';
  uri: string;
  text?: string;
  blob?: string;
  mimeType?: string;
}
```

#### ResourceOptions

```typescript
interface ResourceOptions {
  // Human-readable description
  description?: string;
  
  // MIME type of the resource
  mimeType?: string;
  
  // Additional metadata
  metadata?: Record<string, any>;
}
```

#### ResourceContents

```typescript
interface ResourceContents {
  contents: Array<{
    uri: string;
    text?: string;
    blob?: string;
    mimeType?: string;
  }>;
}
```

#### PromptResult

```typescript
interface PromptResult {
  messages: Array<{
    role: 'assistant' | 'user' | 'system';
    content: {
      type: 'text';
      text: string;
    };
  }>;
}
```

### Transport Module

The transport module provides communication mechanisms.

#### StdioServerTransport

Standard input/output transport for local process communication.

```typescript
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const transport = new StdioServerTransport();
await server.connect(transport);
```

#### StdioClientTransport

Client-side stdio transport for spawning server processes.

```typescript
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const transport = new StdioClientTransport({
  command: 'node',
  args: ['server.js'],
  env: {
    NODE_ENV: 'production'
  },
  cwd: '/path/to/server'
});

await client.connect(transport);
```

**StdioClientTransportOptions:**

```typescript
interface StdioClientTransportOptions {
  // Command to execute
  command: string;
  
  // Command arguments
  args: string[];
  
  // Environment variables
  env?: Record<string, string>;
  
  // Working directory
  cwd?: string;
}
```

#### WebSocketTransport

WebSocket transport for real-time communication.

```typescript
// Server side
import { WebSocketServer } from 'ws';
import { WebSocketServerTransport } from '@modelcontextprotocol/sdk/server/websocket.js';

const wss = new WebSocketServer({ port: 3000 });
wss.on('connection', (ws) => {
  const transport = new WebSocketServerTransport(ws);
  server.connect(transport);
});

// Client side
import { WebSocketClientTransport } from '@modelcontextprotocol/sdk/client/websocket.js';

const ws = new WebSocket('ws://localhost:3000');
const transport = new WebSocketClientTransport(ws);
await client.connect(transport);
```

#### InMemoryTransport

In-memory transport for testing.

```typescript
import { InMemoryTransport } from '@modelcontextprotocol/sdk/test/inmemory.js';

// Create client and server
const client = new McpClient();
const server = new McpServer();

// Create in-memory transport
const [clientTransport, serverTransport] = InMemoryTransport.create();

// Connect both sides
await client.connect(clientTransport);
await server.connect(serverTransport);
```

### Client Module

The client module provides classes for building MCP clients.

#### McpClient

The main client class for interacting with MCP servers.

**Constructor:**

```typescript
new McpClient(options: McpClientOptions)
```

**McpClientOptions:**

```typescript
interface McpClientOptions {
  // Client identification
  name: string;
  version: string;
  
  // Optional logger
  logger?: Logger;
}
```

**Methods:**

```typescript
// Connect to a server
client.connect(
  transport: Transport
): Promise<void>;

// Disconnect from the server
client.close(): Promise<void>;

// List all tools
client.listTools(): Promise<{
  tools: Array<{
    name: string;
    description?: string;
    inputSchema: any;
  }>;
}>;

// Call a tool
client.callTool(
  name: string,
  arguments?: Record<string, any>
): Promise<ToolResult>;

// List all resources
client.listResources(): Promise<{
  resources: Array<{
    uri: string;
    name?: string;
    description?: string;
    mimeType?: string;
  }>;
}>;

// Read a resource
client.readResource(
  uri: string
): Promise<ResourceContents>;

// List all prompts
client.listPrompts(): Promise<{
  prompts: Array<{
    name: string;
    description?: string;
    arguments?: Array<{
      name: string;
      description?: string;
      required?: boolean;
    }>;
  }>;
}>;

// Get a prompt
client.getPrompt(
  name: string,
  arguments?: Record<string, string>
): Promise<PromptResult>;
```

**Example:**

```typescript
import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const client = new McpClient({
  name: 'my-client',
  version: '1.0.0'
});

const transport = new StdioClientTransport({
  command: 'node',
  args: ['server.js']
});

await client.connect(transport);

// List tools
const { tools } = await client.listTools();
console.log('Available tools:', tools);

// Call a tool
const result = await client.callTool('add', { a: 5, b: 3 });
console.log('Result:', result.content[0].text);

await client.close();
```

### Types Module

The types module provides TypeScript type definitions.

#### Core Types

```typescript
// Tool definition
interface Tool {
  name: string;
  description?: string;
  inputSchema?: {
    type: 'object';
    properties?: Record<string, any>;
    required?: string[];
  };
}

// Resource definition
interface Resource {
  uri: string;
  name?: string;
  description?: string;
  mimeType?: string;
}

// Prompt definition
interface Prompt {
  name: string;
  description?: string;
  arguments?: PromptArgument[];
}

interface PromptArgument {
  name: string;
  description?: string;
  required?: boolean;
}

// Message
interface Message {
  role: 'assistant' | 'user' | 'system';
  content: {
    type: 'text' | 'image' | 'resource';
    text?: string;
    data?: string;
    mimeType?: string;
    uri?: string;
  };
}

// Request
interface Request<T> {
  method: string;
  params: T;
}

// Response
interface Response<T> {
  result: T;
}

// Error
interface Error {
  code: number;
  message: string;
  data?: any;
}
```

### Zod Schemas

The SDK exports Zod schemas for validation.

```typescript
import { z } from 'zod';

// Tool schema
const ToolSchema = z.object({
  name: z.string(),
  description: z.string().optional(),
  inputSchema: z.object({
    type: z.literal('object'),
    properties: z.record(z.any()).optional(),
    required: z.array(z.string()).optional()
  }).optional()
});

// Resource schema
const ResourceSchema = z.object({
  uri: z.string(),
  name: z.string().optional(),
  description: z.string().optional(),
  mimeType: z.string().optional()
});

// Prompt schema
const PromptSchema = z.object({
  name: z.string(),
  description: z.string().optional(),
  arguments: z.array(z.object({
    name: z.string(),
    description: z.string().optional(),
    required: z.boolean().optional()
  })).optional()
});
```

## Utility Functions

### Logging

```typescript
import { createLogger } from '@modelcontextprotocol/sdk/logger.js';

const logger = createLogger({
  level: 'info',
  name: 'my-server'
});

logger.info('Server started', { port: 3000 });
logger.error('Error occurred', { error: err.message });
```

### Error Handling

```typescript
import { 
  McpError, 
  ErrorCode 
} from '@modelcontextprotocol/sdk/error.js';

try {
  // Some operation
} catch (error) {
  if (error instanceof McpError) {
    // MCP-specific error
    console.log('Error code:', error.code);
    console.log('Error message:', error.message);
    console.log('Error data:', error.data);
  }
}

// Common error codes
const codes = {
  PARSE_ERROR: -32700,
  INVALID_REQUEST: -32600,
  METHOD_NOT_FOUND: -32601,
  INVALID_PARAMS: -32602,
  INTERNAL_ERROR: -32603,
  TOOL_NOT_FOUND: -32001,
  RESOURCE_NOT_FOUND: -32002,
  PROMPT_NOT_FOUND: -32003,
};
```

### Validation Helpers

```typescript
import { validateToolInput } from '@modelcontextprotocol/sdk/validation.js';

const result = validateToolInput(
  toolSchema,
  inputData
);

if (!result.valid) {
  console.error('Validation errors:', result.errors);
}
```

## Testing Utilities

### Mock Server

```typescript
import { createMockServer } from '@modelcontextprotocol/sdk/test/mock.js';

const mockServer = createMockServer({
  tools: [
    {
      name: 'add',
      handler: async ({ a, b }) => ({
        content: [{ type: 'text', text: `${a + b}` }]
      })
    }
  ]
});

// Connect client to mock server
const transport = InMemoryTransport.create();
await mockServer.connect(transport.server);
await client.connect(transport.client);
```

### Test Client

```typescript
import { createTestClient } from '@modelcontextprotocol/sdk/test/client.js';

const client = createTestClient({
  server: myServer
});

const result = await client.callTool('add', { a: 5, b: 3 });
expect(result.content[0].text).toBe('8');
```

## Advanced Usage

### Custom Transport

```typescript
import { Transport } from '@modelcontextprotocol/sdk/shared/transport.js';

class MyCustomTransport implements Transport {
  private messageHandler?: (message: string) => void;
  
  send(message: string): Promise<void> {
    // Implement send logic
  }
  
  receive(handler: (message: string) => void): void {
    this.messageHandler = handler;
  }
  
  close(): Promise<void> {
    // Implement close logic
  }
}
```

### Progress Reporting

```typescript
server.tool(
  'long_running',
  { /* schema */ },
  async (args, context) => {
    // Report progress
    await context.reportProgress({
      current: 0,
      total: 100,
      message: 'Starting'
    });
    
    for (let i = 0; i < 100; i++) {
      // Do work
      await doWork(i);
      
      // Update progress
      await context.reportProgress({
        current: i + 1,
        total: 100,
        message: `Processed ${i + 1} items`
      });
    }
    
    return {
      content: [
        {
          type: 'text',
          text: 'Done!'
        }
      ]
    };
  }
);
```

### Streaming Responses

```typescript
server.tool(
  'stream',
  { /* schema */ },
  async (args, context) => {
    // Create a stream
    const stream = new ReadableStream({
      async start(controller) {
        for (let i = 0; i < 10; i++) {
          controller.enqueue(new TextEncoder().encode(`Item ${i}\n`));
          await sleep(100);
        }
        controller.close();
      }
    });
    
    return {
      content: [
        {
          type: 'resource',
          uri: 'stream://result',
          mimeType: 'text/plain',
          stream
        }
      ]
    };
  }
);
```

## Error Codes Reference

| Code | Name | Description |
|------|------|-------------|
| -32700 | PARSE_ERROR | Invalid JSON was received |
| -32600 | INVALID_REQUEST | The JSON sent is not a valid Request object |
| -32601 | METHOD_NOT_FOUND | The method does not exist |
| -32602 | INVALID_PARAMS | Invalid method parameter(s) |
| -32603 | INTERNAL_ERROR | Internal JSON-RPC error |
| -32001 | TOOL_NOT_FOUND | Tool not found |
| -32002 | RESOURCE_NOT_FOUND | Resource not found |
| -32003 | PROMPT_NOT_FOUND | Prompt not found |
| -32004 | TOOL_EXECUTION_ERROR | Tool execution failed |
| -32005 | RESOURCE_READ_ERROR | Resource read failed |
| -32006 | PROMPT_EXECUTION_ERROR | Prompt execution failed |
| -32007 | TRANSPORT_ERROR | Transport error |
| -32008 | CONNECTION_ERROR | Connection error |
| -32009 | AUTHENTICATION_ERROR | Authentication failed |
| -32010 | AUTHORIZATION_ERROR | Authorization failed |

## Common Patterns

### Singleton Server

```typescript
class MCPServerSingleton {
  private static instance: McpServer;
  
  static getInstance(): McpServer {
    if (!MCPServerSingleton.instance) {
      MCPServerSingleton.instance = new McpServer({
        name: 'my-server',
        version: '1.0.0'
      });
    }
    return MCPServerSingleton.instance;
  }
}
```

### Tool Factory

```typescript
function createTool(
  name: string,
  description: string,
  schema: z.ZodSchema,
  handler: (args: any) => Promise<any>
) {
  return {
    name,
    description,
    schema,
    handler
  };
}

// Usage
const addTool = createTool(
  'add',
  'Add two numbers',
  z.object({ a: z.number(), b: z.number() }),
  async ({ a, b }) => ({ result: a + b })
);

server.tool(addTool.name, addTool.schema, addTool.handler);
```

### Middleware Pattern

```typescript
function withLogging(handler: Function) {
  return async function(...args: any[]) {
    console.log('Calling handler with args:', args);
    try {
      const result = await handler(...args);
      console.log('Handler returned:', result);
      return result;
    } catch (error) {
      console.error('Handler failed:', error);
      throw error;
    }
  };
}

server.tool(
  'add',
  schema,
  withLogging(async ({ a, b }) => ({ result: a + b }))
);
```

## Performance Tips

### Reuse Connections

```typescript
// Good: Reuse a single client instance
const client = new McpClient({ name: 'my-client', version: '1.0.0' });
await client.connect(transport);

// Use for multiple requests
const result1 = await client.callTool('tool1', {});
const result2 = await client.callTool('tool2', {});

// Bad: Create new client for each request
const client1 = new McpClient({ name: 'my-client', version: '1.0.0' });
await client1.connect(transport);
const result1 = await client1.callTool('tool1', {});
await client1.close();

const client2 = new McpClient({ name: 'my-client', version: '1.0.0' });
await client2.connect(transport);
const result2 = await client2.callTool('tool2', {});
await client2.close();
```

### Batch Operations

```typescript
// Good: Batch operations
async function batchCallTools(client: McpClient, operations: Array<{name: string, args: any}>) {
  return Promise.all(
    operations.map(op => client.callTool(op.name, op.args))
  );
}

// Bad: Sequential operations
async function sequentialCallTools(client: McpClient, operations: Array<{name: string, args: any}>) {
  const results = [];
  for (const op of operations) {
    results.push(await client.callTool(op.name, op.args));
  }
  return results;
}
```

### Enable Caching

```typescript
import NodeCache from 'node-cache';

const toolCache = new NodeCache({ stdTTL: 300 });

server.tool(
  'expensive',
  schema,
  async (args) => {
    const cacheKey = JSON.stringify(args);
    const cached = toolCache.get(cacheKey);
    if (cached) {
      return cached;
    }
    
    const result = await expensiveOperation(args);
    toolCache.set(cacheKey, result);
    return result;
  }
);
```

## Migration Guide

### From v0.5 to v1.0

```typescript
// v0.5
server.setRequestHandler('tools/call', async (request) => {
  // ...
});

// v1.0
server.tool('name', schema, async (args) => {
  // ...
});

// v0.5
server.setRequestHandler('resources/read', async (request) => {
  // ...
});

// v1.0
server.resource('name', uri, options, async (uri) => {
  // ...
});
```

## Version Compatibility

| Package Version | Node.js Version | TypeScript Version |
|-----------------|-----------------|-------------------|
| 0.5.x           | 18+             | 5.0+              |
| 1.0.x           | 20+             | 5.3+              |

---

This appendix provides a complete API reference for the MCP SDK. For the latest updates and changes, refer to the [official documentation](https://github.com/modelcontextprotocol/sdk).
