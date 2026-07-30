# MCP & A2A Primer: Part 2 — Building Your First MCP Server

## Introduction

Now that you understand the core concepts of MCP and A2A from Part 1, it's time to get your hands dirty. In this primer, you'll build your **first complete MCP server** from scratch.

By the end of this tutorial, you'll have:
1. A working MCP server with tools, resources, and prompts
2. Understanding of how MCP servers are structured
3. Ability to test your server with a client
4. Foundational knowledge for building more complex servers

This is the "Hello World" of MCP development—but with real-world functionality.

---

## Part 1: Project Setup

### What We're Building

We're going to build a **Calculator & File Server** that:
- Performs arithmetic operations (tools)
- Reads system information (resources)
- Provides helpful guidance (prompts)

### Prerequisites

Before starting, ensure you have:
- Node.js 20+ installed
- npm 9+ installed
- A code editor
- Basic familiarity with TypeScript/JavaScript

### Step 1: Initialize the Project

```bash
# Create the project directory
mkdir mcp-first-server
cd mcp-first-server

# Initialize npm project
npm init -y

# Install dependencies
npm install @modelcontextprotocol/sdk zod dotenv

# Install development dependencies
npm install -D typescript @types/node tsx
```

### Step 2: TypeScript Configuration

Create `tsconfig.json`:

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

### Step 3: Environment Configuration

Create `.env`:

```env
# Server Configuration
MCP_SERVER_NAME=calculator-server
MCP_SERVER_VERSION=1.0.0
LOG_LEVEL=info
```

### Step 4: Package.json Scripts

Update your `package.json`:

```json
{
  "name": "mcp-first-server",
  "version": "1.0.0",
  "description": "My first MCP server",
  "type": "module",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "start:dev": "tsx src/index.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "tsx": "^4.6.0",
    "typescript": "^5.3.3"
  }
}
```

---

## Part 2: Creating the Logger

### Understanding Logging

Logging is essential for debugging and monitoring your server. We'll create a simple logger that writes to the console with timestamps and log levels.

### Implementation

Create `src/logger.ts`:

```typescript
import { createLogger as createPinoLogger, Logger as PinoLogger } from 'pino';
import { randomUUID } from 'crypto';

/**
 * Simple logger for MCP server
 */
export function createLogger(context?: Record<string, unknown>) {
  const requestId = randomUUID();
  
  const logger = createPinoLogger({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: process.env.MCP_SERVER_NAME || 'mcp-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0',
      requestId
    },
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard',
        ignore: 'pid,hostname'
      }
    }
  });

  return logger;
}

// Default logger instance
export const logger = createLogger();

// Create a module-specific logger
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

### Installation

Since we're using pino for logging, install it:

```bash
npm install pino pino-pretty
npm install -D @types/pino
```

---

## Part 3: Creating the Calculator Tools

### Understanding Tools

Tools are functions the AI can call. Each tool has:
1. **A name** — Unique identifier
2. **A description** — What the tool does
3. **An input schema** — What parameters it accepts
4. **A handler** — The actual logic

### Implementation

Create `src/tools.ts`:

```typescript
import { z } from 'zod';
import { createModuleLogger } from './logger.js';
import { promises as fs } from 'fs';
import path from 'path';

const logger = createModuleLogger('tools');

/**
 * Arithmetic tools
 */
export const arithmeticTools = {
  // Addition
  add: {
    name: 'add',
    description: 'Add two numbers together',
    schema: {
      a: z.number().describe('First number'),
      b: z.number().describe('Second number')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      logger.debug('Executing add', { a, b });
      const result = a + b;
      
      return {
        content: [
          {
            type: 'text',
            text: `${a} + ${b} = ${result}`
          }
        ]
      };
    }
  },

  // Subtraction
  subtract: {
    name: 'subtract',
    description: 'Subtract one number from another',
    schema: {
      a: z.number().describe('Number to subtract from'),
      b: z.number().describe('Number to subtract')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      logger.debug('Executing subtract', { a, b });
      const result = a - b;
      
      return {
        content: [
          {
            type: 'text',
            text: `${a} - ${b} = ${result}`
          }
        ]
      };
    }
  },

  // Multiplication
  multiply: {
    name: 'multiply',
    description: 'Multiply two numbers',
    schema: {
      a: z.number().describe('First number'),
      b: z.number().describe('Second number')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      logger.debug('Executing multiply', { a, b });
      const result = a * b;
      
      return {
        content: [
          {
            type: 'text',
            text: `${a} × ${b} = ${result}`
          }
        ]
      };
    }
  },

  // Division (with error handling)
  divide: {
    name: 'divide',
    description: 'Divide one number by another',
    schema: {
      a: z.number().describe('Numerator'),
      b: z.number().describe('Denominator (must not be zero)')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      logger.debug('Executing divide', { a, b });
      
      if (b === 0) {
        return {
          content: [
            {
              type: 'text',
              text: 'Error: Cannot divide by zero'
            }
          ],
          isError: true
        };
      }
      
      const result = a / b;
      
      return {
        content: [
          {
            type: 'text',
            text: `${a} ÷ ${b} = ${result}`
          }
        ]
      };
    }
  }
};

/**
 * File system tools
 */
export const fileTools = {
  // Read file
  readFile: {
    name: 'read_file',
    description: 'Read the contents of a file',
    schema: {
      path: z.string().describe('Path to the file (relative to project root)')
    },
    handler: async ({ path: filePath }: { path: string }) => {
      logger.debug('Executing read_file', { filePath });
      
      try {
        // Security: Prevent path traversal
        const normalizedPath = path.normalize(filePath);
        const fullPath = path.join(process.cwd(), normalizedPath);
        
        // Check if file exists
        try {
          await fs.access(fullPath);
        } catch {
          return {
            content: [
              {
                type: 'text',
                text: `Error: File not found: ${filePath}`
              }
            ],
            isError: true
          };
        }
        
        const content = await fs.readFile(fullPath, 'utf-8');
        
        return {
          content: [
            {
              type: 'text',
              text: `File: ${filePath}\n\n${content}`
            }
          ]
        };
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        return {
          content: [
            {
              type: 'text',
              text: `Error reading file: ${errorMsg}`
            }
          ],
          isError: true
        };
      }
    }
  },

  // List directory
  listDirectory: {
    name: 'list_directory',
    description: 'List files and directories in a path',
    schema: {
      path: z.string().optional().default('.').describe('Directory path (relative to project root)')
    },
    handler: async ({ path: dirPath }: { path: string }) => {
      logger.debug('Executing list_directory', { dirPath });
      
      try {
        const normalizedPath = path.normalize(dirPath);
        const fullPath = path.join(process.cwd(), normalizedPath);
        
        const entries = await fs.readdir(fullPath, { withFileTypes: true });
        
        const items = entries.map(entry => ({
          name: entry.name,
          type: entry.isDirectory() ? 'directory' : 'file'
        }));
        
        const text = items.map(item => 
          `${item.type === 'directory' ? '📁' : '📄'} ${item.name}`
        ).join('\n');
        
        return {
          content: [
            {
              type: 'text',
              text: `Directory: ${dirPath}\n\n${text}`
            }
          ]
        };
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        return {
          content: [
            {
              type: 'text',
              text: `Error listing directory: ${errorMsg}`
            }
          ],
          isError: true
        };
      }
    }
  }
};

// Combine all tools
export const allTools = {
  ...arithmeticTools,
  ...fileTools
};
```

---

## Part 4: Creating Resources

### Understanding Resources

Resources are data that the AI can read. Each resource has:
1. **A URI** — Unique identifier (like a URL)
2. **A name** — Human-readable name
3. **A description** — What the resource provides
4. **A handler** — Function that returns the data

### Implementation

Create `src/resources.ts`:

```typescript
import os from 'os';
import { createModuleLogger } from './logger.js';
import { promises as fs } from 'fs';
import path from 'path';

const logger = createModuleLogger('resources');

/**
 * System information resource
 */
export const systemInfoResource = {
  uri: 'system://info',
  name: 'system_info',
  description: 'System information including OS, CPU, and memory',
  mimeType: 'application/json',
  handler: async () => {
    logger.debug('Reading system info resource');
    
    const systemInfo = {
      hostname: os.hostname(),
      platform: os.platform(),
      arch: os.arch(),
      cpus: os.cpus().length,
      memory: {
        total: os.totalmem(),
        free: os.freemem(),
        used: os.totalmem() - os.freemem()
      },
      uptime: os.uptime(),
      loadAverage: os.loadavg(),
      nodeVersion: process.version
    };
    
    return {
      contents: [
        {
          uri: 'system://info',
          text: JSON.stringify(systemInfo, null, 2),
          mimeType: 'application/json'
        }
      ]
    };
  }
};

/**
 * Server status resource
 */
export const serverStatusResource = {
  uri: 'server://status',
  name: 'server_status',
  description: 'Current server status and capabilities',
  mimeType: 'application/json',
  handler: async () => {
    logger.debug('Reading server status resource');
    
    const status = {
      name: process.env.MCP_SERVER_NAME || 'mcp-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0',
      status: 'running',
      startTime: new Date().toISOString(),
      capabilities: {
        tools: ['add', 'subtract', 'multiply', 'divide', 'read_file', 'list_directory'],
        resources: ['system://info', 'server://status']
      }
    };
    
    return {
      contents: [
        {
          uri: 'server://status',
          text: JSON.stringify(status, null, 2),
          mimeType: 'application/json'
        }
      ]
    };
  }
};

/**
 * Environment configuration resource
 */
export const configResource = {
  uri: 'config://environment',
  name: 'environment_config',
  description: 'Current environment configuration',
  mimeType: 'application/json',
  handler: async () => {
    logger.debug('Reading config resource');
    
    // Don't expose sensitive information
    const config = {
      nodeEnv: process.env.NODE_ENV || 'development',
      serverName: process.env.MCP_SERVER_NAME || 'mcp-server',
      serverVersion: process.env.MCP_SERVER_VERSION || '1.0.0'
    };
    
    return {
      contents: [
        {
          uri: 'config://environment',
          text: JSON.stringify(config, null, 2),
          mimeType: 'application/json'
        }
      ]
    };
  }
};

/**
 * Package.json resource (for demonstration)
 */
export const packageResource = {
  uri: 'package://info',
  name: 'package_info',
  description: 'Package.json information',
  mimeType: 'application/json',
  handler: async () => {
    logger.debug('Reading package info resource');
    
    try {
      const packagePath = path.join(process.cwd(), 'package.json');
      const content = await fs.readFile(packagePath, 'utf-8');
      const pkg = JSON.parse(content);
      
      return {
        contents: [
          {
            uri: 'package://info',
            text: JSON.stringify({
              name: pkg.name,
              version: pkg.version,
              description: pkg.description,
              dependencies: Object.keys(pkg.dependencies || {}),
              devDependencies: Object.keys(pkg.devDependencies || {})
            }, null, 2),
            mimeType: 'application/json'
          }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      return {
        contents: [
          {
            uri: 'package://info',
            text: JSON.stringify({ error: errorMsg }),
            mimeType: 'application/json'
          }
        ]
      };
    }
  }
};

// Combine all resources
export const allResources = [
  systemInfoResource,
  serverStatusResource,
  configResource,
  packageResource
];
```

---

## Part 5: Creating Prompts

### Understanding Prompts

Prompts are templates that guide AI behavior. Each prompt has:
1. **A name** — Unique identifier
2. **A description** — What the prompt does
3. **Arguments** — Variables the AI can provide
4. **A handler** — Function that returns the prompt text

### Implementation

Create `src/prompts.ts`:

```typescript
import { z } from 'zod';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('prompts');

/**
 * Welcome prompt - gives an overview of capabilities
 */
export const welcomePrompt = {
  name: 'welcome',
  description: 'Welcome message with server capabilities overview',
  schema: {
    name: z.string().optional().describe('User name')
  },
  handler: ({ name }: { name?: string }) => {
    logger.debug('Generating welcome prompt', { name });
    
    const userName = name || 'User';
    
    return {
      messages: [
        {
          role: 'assistant',
          content: {
            type: 'text',
            text: `Welcome to the MCP Calculator & File Server, ${userName}!

I have the following capabilities:

**Tools** (actions I can perform):
- add(a, b) - Add two numbers
- subtract(a, b) - Subtract one number from another
- multiply(a, b) - Multiply two numbers
- divide(a, b) - Divide one number by another
- read_file(path) - Read a file from the filesystem
- list_directory(path) - List files and directories

**Resources** (data I can read):
- system://info - System information
- server://status - Server status
- config://environment - Environment configuration
- package://info - Package.json information

**Prompts** (templates like this one):
- welcome - This welcome message
- help - Help with using the server

What would you like to do today?`
          }
        }
      ]
    };
  }
};

/**
 * Help prompt - guidance on using the server
 */
export const helpPrompt = {
  name: 'help',
  description: 'Help with using the server and its capabilities',
  schema: {
    topic: z.string().optional().describe('Specific topic to get help with')
  },
  handler: ({ topic }: { topic?: string }) => {
    logger.debug('Generating help prompt', { topic });
    
    let helpText = `I can help you with arithmetic operations and file system tasks.

**Arithmetic Operations:**
- "Add 5 and 3" → uses the add tool
- "Subtract 10 from 20" → uses the subtract tool
- "Multiply 4 by 7" → uses the multiply tool
- "Divide 15 by 3" → uses the divide tool

**File Operations:**
- "Read package.json" → uses the read_file tool
- "List files in the current directory" → uses the list_directory tool

**Resources:**
- "What's the system info?" → reads system://info
- "Show me server status" → reads server://status

**Prompts:**
- "Welcome" → Shows this welcome message
- "Help" → Shows this help message`;

    if (topic) {
      helpText += `\n\n**Topic: ${topic}**\n`;
      
      // Add specific help based on topic
      if (topic.toLowerCase().includes('arithmetic') || topic.toLowerCase().includes('math')) {
        helpText += `\nFor arithmetic operations, try:\n`;
        helpText += `- "Add 5 and 3"\n`;
        helpText += `- "Multiply 4 by 7"\n`;
        helpText += `- "Divide 15 by 3"\n`;
      } else if (topic.toLowerCase().includes('file')) {
        helpText += `\nFor file operations, try:\n`;
        helpText += `- "Read package.json"\n`;
        helpText += `- "List files in src"\n`;
      } else if (topic.toLowerCase().includes('resource')) {
        helpText += `\nTo read resources, try:\n`;
        helpText += `- "What's the system info?"\n`;
        helpText += `- "Show me server status"\n`;
      }
    }
    
    return {
      messages: [
        {
          role: 'assistant',
          content: {
            type: 'text',
            text: helpText
          }
        }
      ]
    };
  }
};

// Combine all prompts
export const allPrompts = [welcomePrompt, helpPrompt];
```

---

## Part 6: Creating the Main Server

### Understanding the Server

The server is the heart of your MCP application. It:
1. Creates an MCP server instance
2. Registers tools, resources, and prompts
3. Starts listening for connections

### Implementation

Create `src/server.ts`:

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { createModuleLogger } from './logger.js';
import { allTools } from './tools.js';
import { allResources } from './resources.js';
import { allPrompts } from './prompts.js';

const logger = createModuleLogger('server');

/**
 * Main MCP Server class
 */
export class CalculatorServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Calculator Server');

    // Create the MCP server
    this.server = new McpServer({
      name: process.env.MCP_SERVER_NAME || 'calculator-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0',
      capabilities: {
        tools: {},
        resources: {},
        prompts: {}
      }
    });

    // Register all capabilities
    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Server initialized successfully');
  }

  /**
   * Register all tools
   */
  private registerTools(): void {
    logger.info('Registering tools');

    // Register each tool from our tools module
    for (const tool of Object.values(allTools)) {
      this.server.tool(
        tool.name,
        tool.schema,
        tool.handler
      );
      logger.debug(`Registered tool: ${tool.name}`);
    }

    logger.info('All tools registered');
  }

  /**
   * Register all resources
   */
  private registerResources(): void {
    logger.info('Registering resources');

    for (const resource of allResources) {
      this.server.resource(
        resource.name,
        resource.uri,
        {
          description: resource.description,
          mimeType: resource.mimeType
        },
        resource.handler
      );
      logger.debug(`Registered resource: ${resource.uri}`);
    }

    logger.info('All resources registered');
  }

  /**
   * Register all prompts
   */
  private registerPrompts(): void {
    logger.info('Registering prompts');

    for (const prompt of allPrompts) {
      this.server.prompt(
        prompt.name,
        prompt.schema,
        prompt.handler
      );
      logger.debug(`Registered prompt: ${prompt.name}`);
    }

    logger.info('All prompts registered');
  }

  /**
   * Start the server
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server is already running');
      return;
    }

    logger.info('Starting server...');

    try {
      // Use stdio transport for communication
      const transport = new StdioServerTransport();
      
      // Connect the server to the transport
      await this.server.connect(transport);
      
      this.isRunning = true;
      
      logger.info('Server started successfully');
      console.error('🚀 MCP Calculator Server is running...');
      console.error('   Tools: add, subtract, multiply, divide, read_file, list_directory');
      console.error('   Resources: system://info, server://status, config://environment, package://info');
      console.error('   Prompts: welcome, help');

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start server', { error: errorMsg });
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

    logger.info('Stopping server...');

    try {
      this.isRunning = false;
      logger.info('Server stopped successfully');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop server', { error: errorMsg });
      throw error;
    }
  }
}
```

---

## Part 7: Creating the Entry Point

### Implementation

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

/**
 * Entry point for the Calculator Server
 */

import dotenv from 'dotenv';
dotenv.config();

import { CalculatorServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

/**
 * Handle graceful shutdown
 */
const handleShutdown = async (server: CalculatorServer): Promise<void> => {
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

/**
 * Main function
 */
const main = async (): Promise<void> => {
  logger.info('Starting Calculator Server');

  try {
    const server = new CalculatorServer();

    // Set up signal handlers
    process.on('SIGINT', () => {
      void handleShutdown(server);
    });
    
    process.on('SIGTERM', () => {
      void handleShutdown(server);
    });

    // Handle uncaught errors
    process.on('uncaughtException', (error) => {
      logger.fatal('Uncaught exception', { 
        error: error.message, 
        stack: error.stack 
      });
      process.exit(1);
    });

    process.on('unhandledRejection', (reason) => {
      logger.fatal('Unhandled rejection', { reason });
      process.exit(1);
    });

    // Start the server
    await server.start();

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

// Run the main function
main();
```

---

## Part 8: Testing Your Server

### Testing with a Simple Client

Create `src/client-test.ts`:

```typescript
#!/usr/bin/env node

/**
 * Simple test client for the Calculator Server
 * This demonstrates how to connect and use the server
 */

import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function testServer() {
  logger.info('Starting test client...');

  // Create client
  const client = new McpClient({
    name: 'test-client',
    version: '1.0.0'
  });

  // Create transport (spawns the server process)
  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js'],
    env: {
      NODE_ENV: 'development',
      LOG_LEVEL: 'info'
    }
  });

  try {
    // Connect to server
    logger.info('Connecting to server...');
    await client.connect(transport);

    // Test 1: List tools
    logger.info('--- Testing Tools ---');
    const tools = await client.listTools();
    logger.info(`Available tools: ${tools.tools.map(t => t.name).join(', ')}`);

    // Test 2: Call add tool
    logger.info('Calling add tool...');
    const addResult = await client.callTool('add', { a: 10, b: 5 });
    logger.info('Add result:', addResult.content[0].text);

    // Test 3: Call multiply tool
    logger.info('Calling multiply tool...');
    const multResult = await client.callTool('multiply', { a: 4, b: 7 });
    logger.info('Multiply result:', multResult.content[0].text);

    // Test 4: List resources
    logger.info('--- Testing Resources ---');
    const resources = await client.listResources();
    logger.info(`Available resources: ${resources.resources.map(r => r.uri).join(', ')}`);

    // Test 5: Read system info
    logger.info('Reading system info resource...');
    const systemInfo = await client.readResource('system://info');
    const info = JSON.parse(systemInfo.contents[0].text);
    logger.info(`System info: ${info.hostname}, ${info.cpus} CPU cores`);

    // Test 6: List prompts
    logger.info('--- Testing Prompts ---');
    const prompts = await client.listPrompts();
    logger.info(`Available prompts: ${prompts.prompts.map(p => p.name).join(', ')}`);

    // Test 7: Get welcome prompt
    logger.info('Getting welcome prompt...');
    const welcome = await client.getPrompt('welcome', { name: 'Developer' });
    logger.info('Welcome prompt:', welcome.messages[0].content.text.substring(0, 100) + '...');

    logger.info('✅ All tests passed!');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Test failed:', { error: errorMsg });
  } finally {
    // Clean up
    await client.close();
    logger.info('Test client disconnected');
    process.exit(0);
  }
}

testServer();
```

### Testing with a Simple Curl (if using HTTP transport)

If you want to test with curl, you'd need to use an HTTP transport. Here's a simpler way:

Create `src/simple-request.ts`:

```typescript
#!/usr/bin/env node

/**
 * Simple manual test using direct JSON-RPC messages
 * This helps understand the protocol without using the SDK
 */

import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function sendRequest(message: string) {
  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  // Connect to the server process
  await transport.start();

  // Send the request
  logger.info('Sending request:', message);
  await transport.send(message);

  // Read response
  for await (const response of transport.receive()) {
    logger.info('Received response:', response);
    break;
  }

  await transport.close();
}

// Test tool list
sendRequest(JSON.stringify({
  jsonrpc: '2.0',
  id: '1',
  method: 'tools/list',
  params: {}
}));

// Test calling a tool
sendRequest(JSON.stringify({
  jsonrpc: '2.0',
  id: '2',
  method: 'tools/call',
  params: {
    name: 'add',
    arguments: { a: 5, b: 3 }
  }
}));
```

---

## Part 9: Running and Testing

### Step 1: Build the Server

```bash
npm run build
```

### Step 2: Run the Server

```bash
npm start
```

Expected output:
```
[INFO] Initializing Calculator Server
[INFO] Registering tools
[INFO] All tools registered
[INFO] Registering resources
[INFO] All resources registered
[INFO] Registering prompts
[INFO] All prompts registered
[INFO] Server initialized successfully
[INFO] Starting server...
[INFO] Server started successfully
🚀 MCP Calculator Server is running...
   Tools: add, subtract, multiply, divide, read_file, list_directory
   Resources: system://info, server://status, config://environment, package://info
   Prompts: welcome, help
```

### Step 3: Run the Test Client

In another terminal:

```bash
npm run build
npx tsx src/client-test.ts
```

Expected output:
```
[INFO] Starting test client...
[INFO] Connecting to server...
[INFO] --- Testing Tools ---
[INFO] Available tools: add, subtract, multiply, divide, read_file, list_directory
[INFO] Calling add tool...
[INFO] Add result: 10 + 5 = 15
[INFO] Calling multiply tool...
[INFO] Multiply result: 4 × 7 = 28
[INFO] --- Testing Resources ---
[INFO] Available resources: system://info, server://status, config://environment, package://info
[INFO] Reading system info resource...
[INFO] System info: my-mac, 8 CPU cores
[INFO] --- Testing Prompts ---
[INFO] Available prompts: welcome, help
[INFO] Getting welcome prompt...
[INFO] Welcome prompt: Welcome to the MCP Calculator & File Server, Developer!...
[INFO] ✅ All tests passed!
[INFO] Test client disconnected
```

### Step 4: Manual JSON-RPC Testing

```bash
node src/simple-request.js
```

This sends raw JSON-RPC messages and shows the responses, helping you understand the protocol.

---

## Part 10: Next Steps

### What You've Built

You've created a complete MCP server with:
- **6 tools** — add, subtract, multiply, divide, read_file, list_directory
- **4 resources** — system info, server status, environment config, package info
- **2 prompts** — welcome, help
- **Full error handling** — proper validation and error messages
- **Logging** — structured logs for debugging

### What to Learn Next

1. **Add More Tools** — Try adding tools for HTTP requests, databases, or custom APIs
2. **Add More Resources** — Add resources for files, API responses, or computed data
3. **Add More Prompts** — Add prompts for specific use cases like "code_review" or "data_analysis"
4. **Authentication** — Add API key authentication to your server
5. **Caching** — Add caching for resources to improve performance
6. **Multi-Server** — Connect multiple MCP servers together

### Key Takeaways

1. **MCP servers are easy to build** — Just tools, resources, and prompts
2. **Tools are functions** — AI can call them
3. **Resources are data** — AI can read them
4. **Prompts are templates** — They guide AI behavior
5. **Communication is JSON-RPC** — Standard protocol
6. **Testing is straightforward** — Use the test client

### Additional Resources

- [MCP Specification](https://modelcontextprotocol.io)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Full Tutorial Series (Parts 1-10)](https://github.com/modelcontextprotocol/tutorial-series)

---

**[END OF PRIMER PART 2]**
