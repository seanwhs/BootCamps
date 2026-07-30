# LAB BOOK
## Mastering AI Integration with MCP and A2A Using JavaScript

# LAB BOOK INTRODUCTION

## About This Lab Book

This Lab Book provides structured, hands-on exercises for the "Mastering AI Integration with MCP and A2A Using JavaScript" tutorial series. Each lab corresponds to a specific part of the series and includes:

- **Lab Objectives** — What you'll achieve
- **Prerequisites** — What you need before starting
- **Step-by-Step Instructions** — Detailed guidance
- **Code Templates** — Starter code with placeholders
- **Verification Steps** — How to confirm it works
- **Challenge Extensions** — Additional practice
- **Troubleshooting Tips** — Common issues and solutions

## Lab Environment Setup

### Before You Begin

Verify your environment is ready:

```bash
# Check Node.js version (should be 20+)
node --version

# Check npm version (should be 9+)
npm --version

# Check Git
git --version

# Create working directory
mkdir mcp-labs
cd mcp-labs
```

### Lab Organization

```
mcp-labs/
├── lab-01-intro/
├── lab-02-first-server/
├── lab-03-json-rpc/
├── lab-04-sqlite/
├── lab-05-postgres/
├── lab-06-knowledge/
├── lab-07-client/
├── lab-08-agents/
├── lab-09-a2a/
├── lab-10-multi-agent/
├── lab-11-production/
└── lab-12-real-world/
```

---

# LAB 1: INTRODUCTION TO MCP

## Lab 1.1: Understanding the MCP Ecosystem

**Objective:** Explore the MCP ecosystem and understand the key components.

**Prerequisites:** None (conceptual lab)

### Step 1: Research MCP Hosts

Research and list 5 MCP hosts (applications that use MCP):

```
1. __________________________
2. __________________________
3. __________________________
4. __________________________
5. __________________________
```

### Step 2: Research MCP Servers

Research and list 5 ready-to-use MCP servers:

```
1. __________________________
2. __________________________
3. __________________________
4. __________________________
5. __________________________
```

### Step 3: Document the Three Pillars

Write one sentence describing each pillar of MCP:

1. Tools: _________________________________________________
2. Resources: _________________________________________________
3. Prompts: _________________________________________________

### Step 4: Draw the MCP Architecture

In the space below, draw the MCP client-server architecture:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Verification:** Share your answers with a partner and discuss any differences.

---

## Lab 1.2: Identifying MCP Use Cases

**Objective:** Identify real-world use cases for MCP.

### Step 1: Brainstorm Use Cases

List 5 scenarios where MCP would be beneficial:

```
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________
```

### Step 2: Classify by Domain

Categorize your use cases by domain:

| Domain | Use Case |
|--------|----------|
| Customer Support | |
| Development | |
| Data Analysis | |
| DevOps | |
| Enterprise | |

### Step 3: Identify Tools and Resources

For one use case, identify the tools and resources needed:

Use Case: _________________________________________________

**Tools:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Resources:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

**Prompts:**
1. _________________________________________________
2. _________________________________________________

**Verification:** Present your use case to the class and get feedback.

---

# LAB 2: BUILDING YOUR FIRST MCP SERVER

## Lab 2.1: Project Setup

**Objective:** Set up a TypeScript project for MCP server development.

**Prerequisites:** Node.js 20+, npm 9+

### Step 1: Create Project Directory

```bash
cd mcp-labs
mkdir lab-02-first-server
cd lab-02-first-server
```

### Step 2: Initialize npm Project

```bash
npm init -y
```

**Output:** A `package.json` file should be created.

### Step 3: Install Dependencies

```bash
npm install @modelcontextprotocol/sdk zod dotenv
npm install -D typescript @types/node tsx
```

**Expected Packages Installed:**
- `@modelcontextprotocol/sdk` — MCP SDK
- `zod` — Schema validation
- `dotenv` — Environment variables
- `typescript` — Type safety
- `@types/node` — Node.js types
- `tsx` — TypeScript execution

### Step 4: Create TypeScript Configuration

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
    "declaration": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Step 5: Create Environment Configuration

Create `.env`:

```env
MCP_SERVER_NAME=my-first-server
MCP_SERVER_VERSION=1.0.0
LOG_LEVEL=info
```

### Step 6: Create Directory Structure

```bash
mkdir -p src
```

**Verification:** Your directory should look like:

```
lab-02-first-server/
├── node_modules/
├── src/
├── .env
├── package.json
└── tsconfig.json
```

---

## Lab 2.2: Creating the Logger

**Objective:** Implement structured logging for your MCP server.

### Step 1: Install Pino

```bash
npm install pino pino-pretty
npm install -D @types/pino
```

### Step 2: Create the Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

export function createLogger() {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: process.env.MCP_SERVER_NAME || 'mcp-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0'
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

  return logger.child({
    requestId: randomUUID()
  });
}

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

### Step 3: Test the Logger

Create `src/test-logger.ts`:

```typescript
import { logger, createModuleLogger } from './logger.js';

const testLogger = createModuleLogger('test');

testLogger.info('Testing logger', { key: 'value' });
testLogger.warn('This is a warning');
testLogger.error('This is an error');
logger.debug('Debug message');
```

### Step 4: Run the Test

```bash
npx tsx src/test-logger.ts
```

**Expected Output:**
```
[INFO] Testing logger { key: 'value' }
[WARN] This is a warning
[ERROR] This is an error
[DEBUG] Debug message
```

**Verification:** Confirm all log messages appear with correct formatting and colors.

---

## Lab 2.3: Implementing Tools

**Objective:** Implement and register MCP tools.

### Step 1: Create the Tools Module

Create `src/tools.ts`:

```typescript
import { z } from 'zod';
import { promises as fs } from 'fs';
import path from 'path';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('tools');

// Arithmetic tools
export const arithmeticTools = {
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
        content: [{ type: 'text', text: `${a} + ${b} = ${result}` }]
      };
    }
  },

  subtract: {
    name: 'subtract',
    description: 'Subtract one number from another',
    schema: {
      a: z.number().describe('Number to subtract from'),
      b: z.number().describe('Number to subtract')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      const result = a - b;
      return {
        content: [{ type: 'text', text: `${a} - ${b} = ${result}` }]
      };
    }
  },

  multiply: {
    name: 'multiply',
    description: 'Multiply two numbers',
    schema: {
      a: z.number().describe('First number'),
      b: z.number().describe('Second number')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      const result = a * b;
      return {
        content: [{ type: 'text', text: `${a} × ${b} = ${result}` }]
      };
    }
  },

  divide: {
    name: 'divide',
    description: 'Divide one number by another',
    schema: {
      a: z.number().describe('Numerator'),
      b: z.number().describe('Denominator')
    },
    handler: async ({ a, b }: { a: number; b: number }) => {
      if (b === 0) {
        return {
          content: [{ type: 'text', text: 'Error: Cannot divide by zero' }],
          isError: true
        };
      }
      const result = a / b;
      return {
        content: [{ type: 'text', text: `${a} ÷ ${b} = ${result}` }]
      };
    }
  }
};

// File tools
export const fileTools = {
  readFile: {
    name: 'read_file',
    description: 'Read the contents of a file',
    schema: {
      path: z.string().describe('Path to the file')
    },
    handler: async ({ path: filePath }: { path: string }) => {
      logger.debug('Executing read_file', { filePath });
      
      try {
        // Security: Prevent path traversal
        const fullPath = path.join(process.cwd(), filePath);
        const normalized = path.normalize(fullPath);
        
        if (!normalized.startsWith(process.cwd())) {
          return {
            content: [{ type: 'text', text: 'Access denied' }],
            isError: true
          };
        }
        
        const content = await fs.readFile(normalized, 'utf-8');
        return {
          content: [{ type: 'text', text: content }]
        };
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        return {
          content: [{ type: 'text', text: `Error reading file: ${errorMsg}` }],
          isError: true
        };
      }
    }
  },

  listDirectory: {
    name: 'list_directory',
    description: 'List files and directories',
    schema: {
      path: z.string().optional().default('.').describe('Directory path')
    },
    handler: async ({ path: dirPath }: { path: string }) => {
      logger.debug('Executing list_directory', { dirPath });
      
      try {
        const fullPath = path.join(process.cwd(), dirPath);
        const entries = await fs.readdir(fullPath, { withFileTypes: true });
        
        const items = entries.map(entry => ({
          name: entry.name,
          type: entry.isDirectory() ? 'directory' : 'file'
        }));
        
        const text = items.map(item =>
          `${item.type === 'directory' ? '📁' : '📄'} ${item.name}`
        ).join('\n');
        
        return {
          content: [{ type: 'text', text: `Directory: ${dirPath}\n\n${text}` }]
        };
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        return {
          content: [{ type: 'text', text: `Error listing directory: ${errorMsg}` }],
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

### Step 2: Create the Server

Create `src/server.ts`:

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { createLogger, createModuleLogger } from './logger.js';
import { allTools } from './tools.js';
import { allResources } from './resources.js';
import { allPrompts } from './prompts.js';

const logger = createModuleLogger('server');

export class MyFirstServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing My First Server');

    this.server = new McpServer({
      name: process.env.MCP_SERVER_NAME || 'my-first-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0'
    });

    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Server initialized successfully');
  }

  private registerTools(): void {
    logger.info('Registering tools');

    for (const tool of Object.values(allTools)) {
      this.server.tool(tool.name, tool.schema, tool.handler);
      logger.debug(`Registered tool: ${tool.name}`);
    }

    logger.info('All tools registered');
  }

  private registerResources(): void {
    // TODO: Add resources
    logger.info('Registering resources');
  }

  private registerPrompts(): void {
    // TODO: Add prompts
    logger.info('Registering prompts');
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server is already running');
      return;
    }

    logger.info('Starting server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;
      logger.info('Server started successfully');
      console.error('🚀 My First MCP Server is running...');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start server', { error: errorMsg });
      throw error;
    }
  }

  async stop(): Promise<void> {
    if (!this.isRunning) {
      logger.warn('Server is not running');
      return;
    }

    logger.info('Stopping server...');
    this.isRunning = false;
    logger.info('Server stopped successfully');
  }
}
```

**Verification:** Check that the server compiles without errors:

```bash
npx tsc --noEmit
```

---

## Lab 2.4: Implementing Resources

**Objective:** Implement and register MCP resources.

### Step 1: Create Resources Module

Create `src/resources.ts`:

```typescript
import os from 'os';
import { createModuleLogger } from './logger.js';
import { promises as fs } from 'fs';
import path from 'path';

const logger = createModuleLogger('resources');

export const systemInfoResource = {
  uri: 'system://info',
  name: 'system_info',
  description: 'System information',
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
      nodeVersion: process.version
    };
    
    return {
      contents: [{
        uri: 'system://info',
        text: JSON.stringify(systemInfo, null, 2),
        mimeType: 'application/json'
      }]
    };
  }
};

export const serverStatusResource = {
  uri: 'server://status',
  name: 'server_status',
  description: 'Server status',
  mimeType: 'application/json',
  handler: async () => {
    logger.debug('Reading server status resource');
    
    const status = {
      name: process.env.MCP_SERVER_NAME || 'my-first-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0',
      status: 'running',
      startTime: new Date().toISOString(),
      tools: ['add', 'subtract', 'multiply', 'divide', 'read_file', 'list_directory'],
      resources: ['system://info', 'server://status']
    };
    
    return {
      contents: [{
        uri: 'server://status',
        text: JSON.stringify(status, null, 2),
        mimeType: 'application/json'
      }]
    };
  }
};

export const envConfigResource = {
  uri: 'config://environment',
  name: 'environment_config',
  description: 'Environment configuration',
  mimeType: 'application/json',
  handler: async () => {
    logger.debug('Reading config resource');
    
    const config = {
      nodeEnv: process.env.NODE_ENV || 'development',
      serverName: process.env.MCP_SERVER_NAME || 'my-first-server',
      serverVersion: process.env.MCP_SERVER_VERSION || '1.0.0'
    };
    
    return {
      contents: [{
        uri: 'config://environment',
        text: JSON.stringify(config, null, 2),
        mimeType: 'application/json'
      }]
    };
  }
};

export const allResources = [
  systemInfoResource,
  serverStatusResource,
  envConfigResource
];
```

### Step 2: Update the Server

Update `src/server.ts` to register resources:

```typescript
// Add this import
import { allResources } from './resources.js';

// Update registerResources method
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
```

**Verification:** Run `npx tsc --noEmit` to confirm no TypeScript errors.

---

## Lab 2.5: Implementing Prompts

**Objective:** Implement and register MCP prompts.

### Step 1: Create Prompts Module

Create `src/prompts.ts`:

```typescript
import { z } from 'zod';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('prompts');

export const welcomePrompt = {
  name: 'welcome',
  description: 'Welcome message with capabilities overview',
  schema: {
    name: z.string().optional().describe('User name')
  },
  handler: ({ name }: { name?: string }) => {
    logger.debug('Generating welcome prompt', { name });
    
    const userName = name || 'User';
    
    return {
      messages: [{
        role: 'assistant',
        content: {
          type: 'text',
          text: `Welcome to My First MCP Server, ${userName}!

I have the following capabilities:

**Tools** (actions I can perform):
- add(a, b) — Add two numbers
- subtract(a, b) — Subtract one number from another
- multiply(a, b) — Multiply two numbers
- divide(a, b) — Divide one number by another
- read_file(path) — Read a file from the filesystem
- list_directory(path) — List files and directories

**Resources** (data I can read):
- system://info — System information
- server://status — Server status
- config://environment — Environment configuration

**Prompts** (templates like this one):
- welcome — This welcome message

What would you like to do today?`
        }
      }]
    };
  }
};

export const helpPrompt = {
  name: 'help',
  description: 'Help with using the server',
  schema: {
    topic: z.string().optional().describe('Specific topic')
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
- "List files in src" → uses the list_directory tool

**Resources:**
- "What's the system info?" → reads system://info
- "Show me server status" → reads server://status`;

    if (topic) {
      helpText += `\n\n**Topic: ${topic}**\n`;
      helpText += `Please use the appropriate tool for this topic.`;
    }
    
    return {
      messages: [{
        role: 'assistant',
        content: {
          type: 'text',
          text: helpText
        }
      }]
    };
  }
};

export const allPrompts = [welcomePrompt, helpPrompt];
```

### Step 2: Update the Server

Update `src/server.ts` to register prompts:

```typescript
// Add this import
import { allPrompts } from './prompts.js';

// Update registerPrompts method
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
```

**Verification:** Run `npx tsc --noEmit` to confirm no TypeScript errors.

---

## Lab 2.6: Creating the Entry Point and Testing

**Objective:** Create the entry point and test your server.

### Step 1: Create the Entry Point

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { MyFirstServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const handleShutdown = async (server: MyFirstServer): Promise<void> => {
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
  logger.info('Starting My First MCP Server');

  try {
    const server = new MyFirstServer();

    process.on('SIGINT', () => {
      void handleShutdown(server);
    });

    process.on('SIGTERM', () => {
      void handleShutdown(server);
    });

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

    await server.start();

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

main();
```

### Step 2: Update Package.json

Update `package.json` scripts:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "start:dev": "tsx src/index.ts"
  }
}
```

### Step 3: Build and Run

```bash
# Build TypeScript
npm run build

# Run the server
npm start
```

**Expected Output:**
```
🚀 My First MCP Server is running...
```

### Step 4: Create a Test Client

Create `src/client-test.ts`:

```typescript
#!/usr/bin/env node

import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function testServer() {
  logger.info('Starting test client...');

  const client = new McpClient({
    name: 'test-client',
    version: '1.0.0'
  });

  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  try {
    await client.connect(transport);

    // List tools
    const { tools } = await client.listTools();
    logger.info('Available tools:', tools.map(t => t.name));

    // Call add tool
    const addResult = await client.callTool('add', { a: 10, b: 5 });
    logger.info('Add result:', addResult.content[0].text);

    // Read system info
    const systemInfo = await client.readResource('system://info');
    const info = JSON.parse(systemInfo.contents[0].text);
    logger.info('System info:', info.hostname);

    // Get welcome prompt
    const welcome = await client.getPrompt('welcome', { name: 'Developer' });
    logger.info('Welcome prompt:', welcome.messages[0].content.text.substring(0, 50) + '...');

    logger.info('✅ All tests passed!');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Test failed:', { error: errorMsg });
  } finally {
    await client.close();
    logger.info('Test client disconnected');
  }
}

testServer();
```

### Step 5: Run the Test Client

In a separate terminal:

```bash
npx tsx src/client-test.ts
```

**Expected Output:**
```
[INFO] Starting test client...
[INFO] Available tools: [ 'add', 'subtract', 'multiply', 'divide', 'read_file', 'list_directory' ]
[INFO] Add result: 10 + 5 = 15
[INFO] System info: your-hostname
[INFO] Welcome prompt: Welcome to My First MCP Server, Developer!...
[INFO] ✅ All tests passed!
[INFO] Test client disconnected
```

**Verification:** All tests should pass with no errors.

---

## Lab 2.7: Challenge — Add a New Tool

**Objective:** Add a new tool to the server.

### Step 1: Define the Tool

Add a `calculate_discount` tool to `src/tools.ts`:

```typescript
// Add to the arithmeticTools or create a new category
export const discountTools = {
  calculateDiscount: {
    name: 'calculate_discount',
    description: 'Calculate the discounted price of an item',
    schema: {
      price: z.number().min(0).describe('Original price'),
      discount: z.number().min(0).max(100).describe('Discount percentage')
    },
    handler: async ({ price, discount }: { price: number; discount: number }) => {
      const savings = price * (discount / 100);
      const finalPrice = price - savings;
      
      return {
        content: [
          { type: 'text', text: `Original price: $${price.toFixed(2)}` },
          { type: 'text', text: `Discount: ${discount}%` },
          { type: 'text', text: `You save: $${savings.toFixed(2)}` },
          { type: 'text', text: `Final price: $${finalPrice.toFixed(2)}` }
        ]
      };
    }
  }
};

// Update allTools
export const allTools = {
  ...arithmeticTools,
  ...fileTools,
  ...discountTools
};
```

### Step 2: Rebuild and Test

```bash
npm run build
npx tsx src/client-test.ts
```

### Step 3: Verify the Tool Works

The test client should now show `calculate_discount` in the list of tools.

**Challenge Extension:** Add a `calculate_tip` tool that takes a bill amount and tip percentage.

---

# LAB 3: JSON-RPC AND MCP COMMUNICATION

## Lab 3.1: Inspecting MCP Messages

**Objective:** Inspect the JSON-RPC messages exchanged between client and server.

### Step 1: Enable Debug Logging

Update your `.env` file:

```env
LOG_LEVEL=debug
```

### Step 2: Run the Server with Debug Logging

```bash
npm start
```

### Step 3: Capture and Analyze Messages

Run the client and capture the messages:

```bash
LOG_LEVEL=debug npx tsx src/client-test.ts 2>&1 | grep -E "(Sending|Received)"
```

### Step 4: Document Message Flow

Record the messages you observe:

**Initialize Request:**
```
{
  "jsonrpc": "2.0",
  "id": "...",
  "method": "initialize",
  "params": {
    "protocolVersion": "...",
    "clientInfo": { ... }
  }
}
```

**Initialize Response:**
```
{
  "jsonrpc": "2.0",
  "id": "...",
  "result": { ... }
}
```

**tools/list Request:**
```
{
  "jsonrpc": "2.0",
  "id": "...",
  "method": "tools/list",
  "params": {}
}
```

**tools/list Response:**
```
{
  "jsonrpc": "2.0",
  "id": "...",
  "result": {
    "tools": [ ... ]
  }
}
```

**tools/call Request:**
```
{
  "jsonrpc": "2.0",
  "id": "...",
  "method": "tools/call",
  "params": {
    "name": "add",
    "arguments": { "a": 10, "b": 5 }
  }
}
```

**tools/call Response:**
```
{
  "jsonrpc": "2.0",
  "id": "...",
  "result": {
    "content": [{ "type": "text", "text": "10 + 5 = 15" }]
  }
}
```

**Verification:** Confirm you can see all six message types in the logs.

---

## Lab 3.2: Sending Raw JSON-RPC Messages

**Objective:** Send raw JSON-RPC messages directly.

### Step 1: Create a Raw Client

Create `src/raw-client.ts`:

```typescript
#!/usr/bin/env node

import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import readline from 'readline';

async function rawClient() {
  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  await transport.start();

  // Set up message handler
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log('🔧 Raw JSON-RPC Client');
  console.log('Type a JSON-RPC message or "exit" to quit:');

  rl.on('line', async (line) => {
    if (line === 'exit') {
      await transport.close();
      process.exit(0);
    }

    if (!line.trim()) return;

    try {
      const msg = JSON.parse(line);
      console.log('📤 Sending:', JSON.stringify(msg, null, 2));
      await transport.send(line);

      // Read response
      for await (const response of transport.receive()) {
        console.log('📥 Received:', JSON.stringify(JSON.parse(response), null, 2));
        break;
      }
    } catch (error) {
      console.error('❌ Error:', error instanceof Error ? error.message : 'Unknown error');
    }
  });
}

rawClient();
```

### Step 2: Test Raw Messages

Start the server in one terminal:

```bash
npm start
```

Run the raw client in another:

```bash
npx tsx src/raw-client.ts
```

### Step 3: Send Sample Messages

**Test 1: tools/list**
```json
{"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}
```

**Test 2: tools/call**
```json
{"jsonrpc":"2.0","id":"2","method":"tools/call","params":{"name":"add","arguments":{"a":5,"b":3}}}
```

**Test 3: resources/read**
```json
{"jsonrpc":"2.0","id":"3","method":"resources/read","params":{"uri":"system://info"}}
```

**Test 4: prompts/get**
```json
{"jsonrpc":"2.0","id":"4","method":"prompts/get","params":{"name":"welcome","arguments":{"name":"Test"}}}
```

**Verification:** Each test should return a valid JSON-RPC response.

---

# LAB 4: SQLITE DATABASE SERVER

## Lab 4.1: Connection Manager Implementation

**Objective:** Implement a SQLite connection manager.

### Step 1: Create Project

```bash
cd mcp-labs
mkdir lab-04-sqlite
cd lab-04-sqlite
npm init -y
npm install @modelcontextprotocol/sdk sqlite3 zod dotenv pino pino-pretty
npm install -D typescript @types/node @types/sqlite3 tsx
```

### Step 2: Create Configuration

Create `.env`:

```env
DB_PATH=./data/app.db
DB_READ_ONLY=false
DB_MAX_CONNECTIONS=10
DB_QUERY_TIMEOUT=30000
DB_BACKUP_INTERVAL=3600000
LOG_LEVEL=info
```

### Step 3: Implement Connection Manager

Create `src/db/connection-manager.ts`:

```typescript
import sqlite3 from 'sqlite3';
import { createModuleLogger } from '../logger.js';
import fs from 'fs';
import path from 'path';

const logger = createModuleLogger('connection-manager');

export interface DBConfig {
  path: string;
  readOnly: boolean;
  maxConnections: number;
  queryTimeout: number;
}

export interface QueryResult {
  id: string;
  query: string;
  params: any[];
  rows: any[];
  changes?: number;
  lastInsertRowid?: number;
  executionTime: number;
}

export class ConnectionManager {
  private config: DBConfig;
  private pool: any[] = [];
  private isConnected: boolean = false;

  constructor(config: Partial<DBConfig> = {}) {
    this.config = {
      path: config.path || process.env.DB_PATH || './data/app.db',
      readOnly: config.readOnly ?? process.env.DB_READ_ONLY === 'true',
      maxConnections: config.maxConnections || parseInt(process.env.DB_MAX_CONNECTIONS || '10'),
      queryTimeout: config.queryTimeout || parseInt(process.env.DB_QUERY_TIMEOUT || '30000')
    };

    // Ensure directory exists
    const dir = path.dirname(this.config.path);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    logger.info('Connection manager initialized', {
      dbPath: this.config.path,
      readOnly: this.config.readOnly,
      maxConnections: this.config.maxConnections
    });
  }

  async initialize(): Promise<void> {
    logger.info('Initializing database connection');

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
      await this.executePragma('journal_mode', 'WAL');
      await this.executePragma('foreign_keys', 'ON');

      logger.info('Database initialized successfully', {
        poolSize: this.pool.length
      });

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to initialize database', { error: errorMsg });
      throw error;
    }
  }

  private createConnection(): Promise<sqlite3.Database> {
    return new Promise((resolve, reject) => {
      const db = new sqlite3.Database(
        this.config.path,
        this.config.readOnly ? sqlite3.OPEN_READONLY : sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE,
        (err) => {
          if (err) reject(err);
          else resolve(db);
        }
      );
    });
  }

  private async executePragma(key: string, value: string | number): Promise<void> {
    const connection = await this.getConnection();
    return new Promise((resolve, reject) => {
      connection.run(`PRAGMA ${key} = ${value}`, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  private async getConnection(): Promise<sqlite3.Database> {
    const available = this.pool.find(entry => !entry.inUse);
    if (available) {
      available.inUse = true;
      available.lastUsed = Date.now();
      return available.connection;
    }

    if (this.pool.length < this.config.maxConnections) {
      const connection = await this.createConnection();
      this.pool.push({
        connection,
        lastUsed: Date.now(),
        inUse: true
      });
      return connection;
    }

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

  private releaseConnection(connection: sqlite3.Database): void {
    const entry = this.pool.find(e => e.connection === connection);
    if (entry) {
      entry.inUse = false;
      entry.lastUsed = Date.now();
    }
  }

  async executeQuery(sql: string, params: any[] = []): Promise<QueryResult> {
    const startTime = Date.now();
    const queryId = `q-${Date.now()}`;

    this.logger.debug('Executing query', {
      queryId,
      sql: sql.substring(0, 200),
      paramCount: params.length
    });

    // Validate query
    this.validateQuery(sql);

    let connection: sqlite3.Database | null = null;
    let timeoutId: NodeJS.Timeout | null = null;

    try {
      connection = await this.getConnection();

      const queryPromise = new Promise<{ rows: any[]; changes?: number; lastInsertRowid?: number }>(
        (resolve, reject) => {
          const callback = (err: Error | null, rows?: any[]) => {
            if (err) reject(err);
            else resolve({ rows: rows || [] });
          };

          if (this.isReadOnlyQuery(sql)) {
            connection!.all(sql, params, callback);
          } else {
            const runCallback = function(this: sqlite3.Database, err: Error | null) {
              if (err) reject(err);
              else {
                resolve({
                  rows: [],
                  changes: this.changes,
                  lastInsertRowid: this.lastID
                });
              }
            };
            connection!.run(sql, params, runCallback);
          }
        }
      );

      const timeoutPromise = new Promise((_, reject) => {
        timeoutId = setTimeout(() => {
          reject(new Error(`Query timeout after ${this.config.queryTimeout}ms`));
        }, this.config.queryTimeout);
      });

      const result = await Promise.race([queryPromise, timeoutPromise]) as any;

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
        executionTime
      });

      if (connection) {
        this.releaseConnection(connection);
        connection = null;
      }

      return queryResult;

    } catch (error) {
      if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }

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

  private validateQuery(sql: string): void {
    const normalized = sql.toLowerCase();

    // Prevent DROP TABLE, TRUNCATE, etc.
    const dangerous = ['drop table', 'drop index', 'drop trigger', 'truncate'];
    for (const pattern of dangerous) {
      if (normalized.includes(pattern)) {
        throw new Error(`Dangerous query detected: ${pattern}`);
      }
    }

    // Prevent DELETE and UPDATE without WHERE
    if (normalized.includes('delete') && !normalized.includes('where')) {
      throw new Error('DELETE without WHERE clause is not allowed');
    }
    if (normalized.includes('update') && !normalized.includes('where')) {
      throw new Error('UPDATE without WHERE clause is not allowed');
    }
  }

  private isReadOnlyQuery(sql: string): boolean {
    const normalized = sql.trim().toLowerCase();
    return normalized.startsWith('select') ||
           normalized.startsWith('pragma') ||
           normalized.startsWith('explain');
  }

  async close(): Promise<void> {
    this.logger.info('Closing all database connections');

    const closePromises = this.pool.map(entry => {
      return new Promise<void>((resolve) => {
        entry.connection.close((err) => {
          if (err) {
            this.logger.warn('Error closing connection', { error: err.message });
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

  isConnectedToDatabase(): boolean {
    return this.isConnected;
  }

  getConfig(): DBConfig {
    return { ...this.config };
  }
}

// Singleton
let connectionManager: ConnectionManager | null = null;

export const getConnectionManager = (): ConnectionManager => {
  if (!connectionManager) {
    connectionManager = new ConnectionManager();
  }
  return connectionManager;
};
```

### Step 4: Create Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

export function createLogger() {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: 'database-server',
      version: '1.0.0'
    },
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard'
      }
    }
  });

  return logger.child({ requestId: randomUUID() });
}

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

**Verification:** Compile and check for errors:

```bash
npx tsc --noEmit
```

---

## Lab 4.2: Creating Database Tools

**Objective:** Implement MCP tools for database operations.

### Step 1: Create Query Tools

Create `src/tools/query-tools.ts`:

```typescript
import { z } from 'zod';
import { getConnectionManager } from '../db/connection-manager.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('query-tools');

export const createQueryTool = () => ({
  name: 'execute_query',
  description: 'Execute a SQL query against the database',
  inputSchema: {
    type: 'object',
    properties: {
      sql: {
        type: 'string',
        description: 'The SQL query to execute'
      },
      params: {
        type: 'array',
        description: 'Query parameters (use ? placeholders)',
        items: { type: 'any' }
      },
      limit: {
        type: 'integer',
        description: 'Maximum rows to return',
        minimum: 1,
        maximum: 10000
      }
    },
    required: ['sql']
  },
  handler: async ({ sql, params = [], limit }: { sql: string; params?: any[]; limit?: number }) => {
    logger.debug('Executing query tool', { sql: sql.substring(0, 100) });

    const db = getConnectionManager();

    try {
      let query = sql;
      if (limit && query.trim().toLowerCase().startsWith('select')) {
        query = `${query} LIMIT ${limit}`;
      }

      const result = await db.executeQuery(query, params);

      let responseText = `Query executed in ${result.executionTime}ms\n`;
      responseText += `Rows: ${result.rows.length}\n`;
      if (result.changes !== undefined) {
        responseText += `Changes: ${result.changes}\n`;
      }
      if (result.lastInsertRowid) {
        responseText += `Last Insert ID: ${result.lastInsertRowid}\n`;
      }

      if (result.rows.length > 0) {
        responseText += '\nData:\n';
        responseText += JSON.stringify(result.rows, null, 2);
      }

      return {
        content: [
          { type: 'text', text: responseText },
          { type: 'text', text: JSON.stringify({
            success: true,
            rowCount: result.rows.length,
            executionTime: result.executionTime,
            changes: result.changes,
            lastInsertRowid: result.lastInsertRowid,
            data: result.rows
          }, null, 2) }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Query execution failed', { error: errorMsg });

      return {
        content: [{ type: 'text', text: `Query failed: ${errorMsg}` }],
        isError: true
      };
    }
  }
});
```

### Step 2: Create Server

Create `src/server.ts`:

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { getConnectionManager } from './db/connection-manager.js';
import { createQueryTool } from './tools/query-tools.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('database-server');

export class DatabaseServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Database Server');

    this.server = new McpServer({
      name: 'database-server',
      version: '1.0.0'
    });

    this.initializeDatabase();
    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Database Server initialized');
  }

  private async initializeDatabase(): Promise<void> {
    try {
      const db = getConnectionManager();
      await db.initialize();
      logger.info('Database initialized');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Database initialization failed', { error: errorMsg });
      throw error;
    }
  }

  private registerTools(): void {
    logger.info('Registering tools');

    const queryTool = createQueryTool();
    this.server.tool(
      queryTool.name,
      queryTool.inputSchema,
      queryTool.handler
    );

    logger.info('Tools registered');
  }

  private registerResources(): void {
    logger.info('Registering resources');
    // TODO: Add resources
  }

  private registerPrompts(): void {
    logger.info('Registering prompts');
    // TODO: Add prompts
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server already running');
      return;
    }

    logger.info('Starting server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;
      logger.info('Server started');
      console.error('🚀 Database Server running...');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start server', { error: errorMsg });
      throw error;
    }
  }

  async stop(): Promise<void> {
    if (!this.isRunning) {
      logger.warn('Server not running');
      return;
    }

    logger.info('Stopping server...');
    try {
      const db = getConnectionManager();
      await db.close();
      this.isRunning = false;
      logger.info('Server stopped');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop server', { error: errorMsg });
      throw error;
    }
  }
}
```

### Step 3: Create Entry Point

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { DatabaseServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const main = async () => {
  logger.info('Starting Database Server');

  try {
    const server = new DatabaseServer();

    process.on('SIGINT', async () => {
      await server.stop();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      await server.stop();
      process.exit(0);
    });

    await server.start();

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

main();
```

### Step 4: Build and Test

```bash
npm run build
npm start
```

**Verification:** Server should start without errors.

---

## Lab 4.3: Testing Database Operations

**Objective:** Test the database server with real queries.

### Step 1: Create Database Schema

Create `src/scripts/init-db.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { getConnectionManager } from '../db/connection-manager.js';
import { createLogger } from '../logger.js';

const logger = createLogger();

async function initDb() {
  logger.info('Initializing database schema');

  try {
    const db = getConnectionManager();
    await db.initialize();

    const queries = [
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      `CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,

      `CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)`
    ];

    for (const query of queries) {
      await db.executeQuery(query);
      logger.debug('Executed query:', query.substring(0, 50));
    }

    // Insert sample data
    await db.executeQuery(
      `INSERT OR IGNORE INTO users (name, email, age) VALUES
        ('Alice Johnson', 'alice@example.com', 30),
        ('Bob Smith', 'bob@example.com', 25),
        ('Charlie Brown', 'charlie@example.com', 35)`
    );

    await db.executeQuery(
      `INSERT OR IGNORE INTO products (name, price, stock) VALUES
        ('Laptop Pro', 1299.99, 50),
        ('Wireless Mouse', 29.99, 200),
        ('USB-C Hub', 49.99, 150)`
    );

    logger.info('Database schema initialized');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Database initialization failed', { error: errorMsg });
    process.exit(1);
  }
}

initDb();
```

### Step 2: Create Test Client

Create `src/client-test.ts`:

```typescript
#!/usr/bin/env node

import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function testDatabaseServer() {
  logger.info('Testing Database Server');

  const client = new McpClient({
    name: 'db-test-client',
    version: '1.0.0'
  });

  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  try {
    await client.connect(transport);

    // Test 1: Execute a SELECT query
    logger.info('Test 1: SELECT query');
    const result1 = await client.callTool('execute_query', {
      sql: 'SELECT * FROM users',
      limit: 5
    });
    logger.info('Users:', result1.content[1]?.text?.substring(0, 200));

    // Test 2: Execute an INSERT query
    logger.info('Test 2: INSERT query');
    const result2 = await client.callTool('execute_query', {
      sql: 'INSERT INTO users (name, email, age) VALUES (?, ?, ?)',
      params: ['Test User', 'test@example.com', 28]
    });
    logger.info('Insert result:', result2.content[0].text);

    // Test 3: Execute an UPDATE query
    logger.info('Test 3: UPDATE query');
    const result3 = await client.callTool('execute_query', {
      sql: 'UPDATE users SET age = ? WHERE name = ?',
      params: [29, 'Test User']
    });
    logger.info('Update result:', result3.content[0].text);

    // Test 4: Query the updated data
    logger.info('Test 4: Verify update');
    const result4 = await client.callTool('execute_query', {
      sql: 'SELECT * FROM users WHERE name = ?',
      params: ['Test User']
    });
    logger.info('Updated user:', result4.content[1]?.text);

    // Test 5: Test dangerous query (should fail)
    logger.info('Test 5: Dangerous query (should fail)');
    try {
      await client.callTool('execute_query', {
        sql: 'DROP TABLE users'
      });
    } catch (error) {
      logger.info('✅ Dangerous query blocked as expected');
    }

    logger.info('✅ All tests passed!');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Test failed:', { error: errorMsg });
  } finally {
    await client.close();
  }
}

testDatabaseServer();
```

### Step 3: Run the Tests

```bash
# Initialize database
npx tsx src/scripts/init-db.ts

# Build
npm run build

# Run test client
npx tsx src/client-test.ts
```

**Expected Output:**
```
[INFO] Testing Database Server
[INFO] Test 1: SELECT query
[INFO] Users: [{"id":1,"name":"Alice Johnson",...}]
[INFO] Test 2: INSERT query
[INFO] Insert result: Query executed in Xms...
[INFO] Test 3: UPDATE query
[INFO] Update result: Query executed in Xms...
[INFO] Test 4: Verify update
[INFO] Updated user: [{"id":4,"name":"Test User",...}]
[INFO] Test 5: Dangerous query (should fail)
[INFO] ✅ Dangerous query blocked as expected
[INFO] ✅ All tests passed!
```

**Verification:** All tests should pass. The dangerous query (DROP TABLE) should be blocked.

---

# LAB 5: POSTGRESQL SERVER

## Lab 5.1: PostgreSQL Connection Manager

**Objective:** Implement a PostgreSQL connection manager.

### Step 1: Setup PostgreSQL

```bash
# Start PostgreSQL (Docker)
docker run --name postgres-mcp -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine

# Wait for PostgreSQL to start
sleep 5

# Create database
docker exec -it postgres-mcp psql -U postgres -c "CREATE DATABASE ai_platform"
```

### Step 2: Create Project

```bash
cd mcp-labs
mkdir lab-05-postgres
cd lab-05-postgres
npm init -y
npm install @modelcontextprotocol/sdk pg pg-pool zod dotenv pino pino-pretty
npm install -D typescript @types/node @types/pg tsx
```

### Step 3: Create Environment Configuration

Create `.env`:

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DATABASE=ai_platform
POSTGRES_SSL=false
POSTGRES_MAX_CONNECTIONS=10
POSTGRES_QUERY_TIMEOUT_MS=30000
LOG_LEVEL=info
```

### Step 4: Create Connection Manager

Create `src/db/connection-manager.ts`:

```typescript
import { Pool, PoolConfig } from 'pg';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('pg-connection-manager');

export interface PgConfig {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
  ssl: boolean;
  maxConnections: number;
  queryTimeoutMs: number;
}

export type RiskLevel = 'read-only' | 'read-write' | 'admin' | 'critical';

export class PostgresConnectionManager {
  private pool: Pool;
  private config: PgConfig;
  private isConnected: boolean = false;

  constructor(config?: Partial<PgConfig>) {
    this.config = {
      host: config?.host || process.env.POSTGRES_HOST || 'localhost',
      port: config?.port || parseInt(process.env.POSTGRES_PORT || '5432'),
      user: config?.user || process.env.POSTGRES_USER || 'postgres',
      password: config?.password || process.env.POSTGRES_PASSWORD || '',
      database: config?.database || process.env.POSTGRES_DATABASE || 'postgres',
      ssl: config?.ssl ?? (process.env.POSTGRES_SSL === 'true'),
      maxConnections: config?.maxConnections || parseInt(process.env.POSTGRES_MAX_CONNECTIONS || '10'),
      queryTimeoutMs: config?.queryTimeoutMs || parseInt(process.env.POSTGRES_QUERY_TIMEOUT_MS || '30000')
    };

    const poolConfig: PoolConfig = {
      host: this.config.host,
      port: this.config.port,
      user: this.config.user,
      password: this.config.password,
      database: this.config.database,
      max: this.config.maxConnections,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
      ssl: this.config.ssl ? { rejectUnauthorized: false } : false
    };

    this.pool = new Pool(poolConfig);

    this.pool.on('error', (err) => {
      logger.error('Pool error', { error: err.message });
    });

    this.pool.on('connect', () => {
      logger.debug('New connection established');
    });

    logger.info('PostgreSQL connection manager initialized', {
      host: this.config.host,
      database: this.config.database,
      maxConnections: this.config.maxConnections
    });
  }

  async initialize(): Promise<void> {
    logger.info('Initializing connection pool');

    try {
      const client = await this.pool.connect();
      const result = await client.query('SELECT version() as version');
      client.release();

      this.isConnected = true;

      logger.info('PostgreSQL connection established', {
        version: result.rows[0].version
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to connect to PostgreSQL', { error: errorMsg });
      throw new Error(`PostgreSQL connection failed: ${errorMsg}`);
    }
  }

  async executeQuery(sql: string, params: any[] = []): Promise<any> {
    this.logger.debug('Executing query', {
      sql: sql.substring(0, 200),
      paramCount: params.length
    });

    // Validate query
    this.validateQuery(sql);

    const client = await this.pool.connect();

    try {
      // Set statement timeout
      await client.query(`SET statement_timeout = ${this.config.queryTimeoutMs}`);

      const result = await client.query(sql, params);

      // Reset timeout
      await client.query('SET statement_timeout = 0');

      return result;
    } finally {
      client.release();
    }
  }

  private validateQuery(sql: string): void {
    const normalized = sql.trim().toLowerCase();

    // Prevent DROP TABLE, TRUNCATE, etc.
    const dangerous = ['drop table', 'drop index', 'drop schema', 'truncate'];
    for (const pattern of dangerous) {
      if (normalized.includes(pattern)) {
        throw new Error(`Dangerous query detected: ${pattern}`);
      }
    }

    // Prevent DELETE and UPDATE without WHERE
    if (normalized.includes('delete') && !normalized.includes('where')) {
      throw new Error('DELETE without WHERE clause is not allowed');
    }
    if (normalized.includes('update') && !normalized.includes('where')) {
      throw new Error('UPDATE without WHERE clause is not allowed');
    }
  }

  getQueryRiskLevel(sql: string): RiskLevel {
    const normalized = sql.trim().toLowerCase();

    // Read-only
    if (['select', 'show', 'explain'].some(p => normalized.startsWith(p))) {
      return 'read-only';
    }

    // Read-write
    if (['insert', 'update', 'delete'].some(p => normalized.startsWith(p))) {
      if (normalized.includes('delete') && !normalized.includes('where')) {
        return 'critical';
      }
      if (normalized.includes('update') && !normalized.includes('where')) {
        return 'critical';
      }
      return 'read-write';
    }

    // DDL
    if (['create', 'alter', 'drop', 'truncate'].some(p => normalized.startsWith(p))) {
      return 'admin';
    }

    return 'admin';
  }

  async close(): Promise<void> {
    this.logger.info('Closing connection pool');
    await this.pool.end();
    this.isConnected = false;
    this.logger.info('Connection pool closed');
  }

  isConnectedToDatabase(): boolean {
    return this.isConnected;
  }

  getConfig(): PgConfig {
    return { ...this.config };
  }
}

let connectionManager: PostgresConnectionManager | null = null;

export const getConnectionManager = (): PostgresConnectionManager => {
  if (!connectionManager) {
    connectionManager = new PostgresConnectionManager();
  }
  return connectionManager;
};
```

### Step 5: Create Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

export function createLogger() {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: 'postgres-server',
      version: '1.0.0'
    },
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard'
      }
    }
  });

  return logger.child({ requestId: randomUUID() });
}

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

**Verification:** Compile and check for errors.

---

## Lab 5.2: Implementing PostgreSQL Tools

**Objective:** Implement MCP tools for PostgreSQL operations.

### Step 1: Create Query Tools

Create `src/tools/query-tools.ts`:

```typescript
import { z } from 'zod';
import { getConnectionManager } from '../db/connection-manager.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('pg-tools');

export const createReadQueryTool = () => ({
  name: 'read_query',
  description: 'Execute a read-only SELECT query',
  inputSchema: {
    type: 'object',
    properties: {
      query: { type: 'string', description: 'The SELECT query' },
      params: { type: 'array', description: 'Query parameters', items: { type: 'any' } },
      limit: { type: 'integer', description: 'Max rows', minimum: 1, maximum: 10000 }
    },
    required: ['query']
  },
  handler: async ({ query, params = [], limit }: { query: string; params?: any[]; limit?: number }) => {
    logger.debug('Executing read query', { query: query.substring(0, 100) });

    const db = getConnectionManager();

    try {
      let sql = query;
      if (limit && !sql.toLowerCase().includes('limit')) {
        sql = `${sql} LIMIT ${limit}`;
      }

      const result = await db.executeQuery(sql, params);

      return {
        content: [
          { type: 'text', text: `Query executed. ${result.rowCount} rows returned.` },
          { type: 'text', text: JSON.stringify(result.rows, null, 2) }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Read query failed', { error: errorMsg });
      return {
        content: [{ type: 'text', text: `Query failed: ${errorMsg}` }],
        isError: true
      };
    }
  }
});

export const createWriteQueryTool = () => ({
  name: 'write_query',
  description: 'Execute an INSERT, UPDATE, or DELETE query',
  inputSchema: {
    type: 'object',
    properties: {
      query: { type: 'string', description: 'The write query' },
      params: { type: 'array', description: 'Query parameters', items: { type: 'any' } },
      confirm: { type: 'boolean', description: 'Confirm this is a write operation' }
    },
    required: ['query']
  },
  handler: async ({ query, params = [], confirm = false }: { query: string; params?: any[]; confirm?: boolean }) => {
    logger.debug('Executing write query', { query: query.substring(0, 100) });

    const db = getConnectionManager();
    const riskLevel = db.getQueryRiskLevel(query);

    // Require confirmation for write operations
    if (riskLevel !== 'read-only' && !confirm) {
      return {
        content: [
          { type: 'text', text: `⚠️ This is a ${riskLevel} operation. Set "confirm": true to proceed.` }
        ],
        isError: true
      };
    }

    try {
      const result = await db.executeQuery(query, params);

      return {
        content: [
          { type: 'text', text: `Query executed. ${result.rowCount} rows affected.` },
          { type: 'text', text: JSON.stringify(result.rows || [], null, 2) }
        ]
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Write query failed', { error: errorMsg });
      return {
        content: [{ type: 'text', text: `Query failed: ${errorMsg}` }],
        isError: true
      };
    }
  }
});
```

### Step 2: Create Server

Create `src/server.ts`:

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { getConnectionManager } from './db/connection-manager.js';
import { createReadQueryTool, createWriteQueryTool } from './tools/query-tools.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('postgres-server');

export class PostgresServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing PostgreSQL Server');

    this.server = new McpServer({
      name: 'postgres-server',
      version: '1.0.0'
    });

    this.initializeDatabase();
    this.registerTools();

    logger.info('PostgreSQL Server initialized');
  }

  private async initializeDatabase(): Promise<void> {
    try {
      const db = getConnectionManager();
      await db.initialize();
      logger.info('Database initialized');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Database initialization failed', { error: errorMsg });
      throw error;
    }
  }

  private registerTools(): void {
    logger.info('Registering tools');

    const readQuery = createReadQueryTool();
    this.server.tool(readQuery.name, readQuery.inputSchema, readQuery.handler);

    const writeQuery = createWriteQueryTool();
    this.server.tool(writeQuery.name, writeQuery.inputSchema, writeQuery.handler);

    logger.info('Tools registered');
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server already running');
      return;
    }

    logger.info('Starting server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;
      logger.info('Server started');
      console.error('🚀 PostgreSQL Server running...');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start server', { error: errorMsg });
      throw error;
    }
  }

  async stop(): Promise<void> {
    if (!this.isRunning) {
      logger.warn('Server not running');
      return;
    }

    logger.info('Stopping server...');
    try {
      const db = getConnectionManager();
      await db.close();
      this.isRunning = false;
      logger.info('Server stopped');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop server', { error: errorMsg });
      throw error;
    }
  }
}
```

### Step 3: Create Entry Point

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { PostgresServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const main = async () => {
  logger.info('Starting PostgreSQL Server');

  try {
    const server = new PostgresServer();

    process.on('SIGINT', async () => {
      await server.stop();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      await server.stop();
      process.exit(0);
    });

    await server.start();

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

main();
```

**Verification:** Build and start the server:

```bash
npm run build
npm start
```

---

## Lab 5.3: Testing PostgreSQL Operations

**Objective:** Test the PostgreSQL server with real queries.

### Step 1: Initialize Database

Create `src/scripts/init-db.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { getConnectionManager } from '../db/connection-manager.js';
import { createLogger } from '../logger.js';

const logger = createLogger();

async function initDb() {
  logger.info('Initializing PostgreSQL schema');

  try {
    const db = getConnectionManager();
    await db.initialize();

    const queries = [
      `CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        age INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`,

      `CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        stock INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )`
    ];

    for (const query of queries) {
      await db.executeQuery(query);
    }

    // Insert sample data
    await db.executeQuery(
      `INSERT INTO users (name, email, age) VALUES
        ('Alice Johnson', 'alice@example.com', 30),
        ('Bob Smith', 'bob@example.com', 25),
        ('Charlie Brown', 'charlie@example.com', 35)
      ON CONFLICT (email) DO NOTHING`
    );

    await db.executeQuery(
      `INSERT INTO products (name, price, stock) VALUES
        ('Laptop Pro', 1299.99, 50),
        ('Wireless Mouse', 29.99, 200),
        ('USB-C Hub', 49.99, 150)
      ON CONFLICT (name) DO NOTHING`
    );

    logger.info('Database schema initialized');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Database initialization failed', { error: errorMsg });
    process.exit(1);
  }
}

initDb();
```

### Step 2: Create Test Client

Create `src/client-test.ts`:

```typescript
#!/usr/bin/env node

import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function testPostgresServer() {
  logger.info('Testing PostgreSQL Server');

  const client = new McpClient({
    name: 'pg-test-client',
    version: '1.0.0'
  });

  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  try {
    await client.connect(transport);

    // Test 1: Read query (SELECT)
    logger.info('Test 1: Read query');
    const result1 = await client.callTool('read_query', {
      query: 'SELECT * FROM users LIMIT 5'
    });
    logger.info('Users:', result1.content[1]?.text?.substring(0, 200));

    // Test 2: Write query (INSERT) — should require confirmation
    logger.info('Test 2: Write query without confirmation');
    const result2 = await client.callTool('write_query', {
      query: 'INSERT INTO users (name, email, age) VALUES ($1, $2, $3)',
      params: ['Test User', 'test@postgres.com', 28]
    });
    logger.info('Result:', result2.content[0]?.text);

    // Test 3: Write query with confirmation
    logger.info('Test 3: Write query with confirmation');
    const result3 = await client.callTool('write_query', {
      query: 'INSERT INTO users (name, email, age) VALUES ($1, $2, $3)',
      params: ['Test User 2', 'test2@postgres.com', 28],
      confirm: true
    });
    logger.info('Insert result:', result3.content[0]?.text);

    // Test 4: Read query to verify
    logger.info('Test 4: Verify insert');
    const result4 = await client.callTool('read_query', {
      query: "SELECT * FROM users WHERE email LIKE 'test%'"
    });
    logger.info('Test users:', result4.content[1]?.text);

    logger.info('✅ All tests passed!');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Test failed:', { error: errorMsg });
  } finally {
    await client.close();
  }
}

testPostgresServer();
```

### Step 3: Run the Tests

```bash
# Initialize database
npx tsx src/scripts/init-db.ts

# Build
npm run build

# Run test client
npx tsx src/client-test.ts
```

**Expected Output:**
```
[INFO] Testing PostgreSQL Server
[INFO] Test 1: Read query
[INFO] Users: [{"id":1,"name":"Alice Johnson",...}]
[INFO] Test 2: Write query without confirmation
[INFO] Result: ⚠️ This is a read-write operation. Set "confirm": true to proceed.
[INFO] Test 3: Write query with confirmation
[INFO] Insert result: Query executed. 1 rows affected.
[INFO] Test 4: Verify insert
[INFO] Test users: [{"id":4,"name":"Test User 2",...},{"id":5,"name":"Test User",...}]
[INFO] ✅ All tests passed!
```

**Verification:** The write query without confirmation should be rejected. The write query with confirmation should succeed.

---

# LAB 6: KNOWLEDGE SERVER

## Lab 6.1: Data Source Adapter Pattern

**Objective:** Implement the data source adapter pattern for multiple data sources.

### Step 1: Create Project

```bash
cd mcp-labs
mkdir lab-06-knowledge
cd lab-06-knowledge
npm init -y
npm install @modelcontextprotocol/sdk zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx
```

### Step 2: Create Base Adapter Interface

Create `src/adapters/base-adapter.ts`:

```typescript
export interface QueryRequest {
  type: 'sql' | 'search' | 'rest';
  query: string | Record<string, any>;
  options?: Record<string, any>;
  limit?: number;
}

export interface QueryResult {
  success: boolean;
  data: any[];
  error?: string;
  metadata: {
    source: string;
    executionTime: number;
    rowCount: number;
    query: string;
  };
}

export interface ResourceData {
  uri: string;
  content: string | Buffer;
  mimeType: string;
  metadata?: Record<string, any>;
}

export interface ResourceList {
  resources: Array<{
    uri: string;
    name: string;
    description?: string;
    mimeType?: string;
  }>;
}

export interface HealthStatus {
  healthy: boolean;
  message?: string;
  details?: Record<string, any>;
}

export interface DataSourceAdapter {
  readonly id: string;
  readonly name: string;
  readonly description: string;
  initialize(): Promise<void>;
  query(request: QueryRequest): Promise<QueryResult>;
  getResource(uri: string): Promise<ResourceData>;
  listResources(): Promise<ResourceList>;
  healthCheck(): Promise<HealthStatus>;
  shutdown(): Promise<void>;
  isInitialized(): boolean;
}
```

### Step 3: Create a Mock Adapter

Create `src/adapters/mock-adapter.ts`:

```typescript
import {
  DataSourceAdapter,
  QueryRequest,
  QueryResult,
  ResourceData,
  ResourceList,
  HealthStatus
} from './base-adapter.js';
import { createModuleLogger } from '../logger.js';

const logger = createModuleLogger('mock-adapter');

export class MockAdapter implements DataSourceAdapter {
  readonly id = 'mock';
  readonly name = 'Mock Data Source';
  readonly description = 'Mock adapter for testing';
  private initialized: boolean = false;
  private data: any[] = [];

  async initialize(): Promise<void> {
    logger.info('Initializing mock adapter');
    
    // Generate some mock data
    this.data = [
      { id: 1, name: 'Item 1', category: 'A', value: 100 },
      { id: 2, name: 'Item 2', category: 'B', value: 200 },
      { id: 3, name: 'Item 3', category: 'A', value: 150 },
      { id: 4, name: 'Item 4', category: 'C', value: 300 },
      { id: 5, name: 'Item 5', category: 'B', value: 250 }
    ];

    this.initialized = true;
    logger.info('Mock adapter initialized', { dataCount: this.data.length });
  }

  async query(request: QueryRequest): Promise<QueryResult> {
    this.ensureInitialized();
    
    const startTime = Date.now();

    try {
      let results: any[] = [];

      if (request.type === 'search') {
        const query = typeof request.query === 'string' ? request.query : '';
        const searchTerm = query.toLowerCase();
        results = this.data.filter(item =>
          Object.values(item).some(val =>
            String(val).toLowerCase().includes(searchTerm)
          )
        );
      } else if (request.type === 'sql') {
        // Simple SQL simulation
        const query = typeof request.query === 'string' ? request.query : '';
        if (query.toLowerCase().includes('select *')) {
          results = this.data;
        } else if (query.toLowerCase().includes('category')) {
          const category = query.match(/category\s*=\s*['"]([^'"]+)['"]/)?.[1];
          if (category) {
            results = this.data.filter(item => item.category === category);
          }
        }
      } else {
        results = this.data;
      }

      // Apply limit
      if (request.limit && results.length > request.limit) {
        results = results.slice(0, request.limit);
      }

      const executionTime = Date.now() - startTime;

      return {
        success: true,
        data: results,
        metadata: {
          source: this.id,
          executionTime,
          rowCount: results.length,
          query: typeof request.query === 'string' ? request.query : JSON.stringify(request.query)
        }
      };
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      return {
        success: false,
        data: [],
        error: errorMsg,
        metadata: {
          source: this.id,
          executionTime: Date.now() - startTime,
          rowCount: 0,
          query: typeof request.query === 'string' ? request.query : JSON.stringify(request.query)
        }
      };
    }
  }

  async getResource(uri: string): Promise<ResourceData> {
    this.ensureInitialized();

    // Simple resource handling
    if (uri === 'mock://data') {
      return {
        uri,
        content: JSON.stringify(this.data, null, 2),
        mimeType: 'application/json',
        metadata: { count: this.data.length }
      };
    }

    throw new Error(`Resource not found: ${uri}`);
  }

  async listResources(): Promise<ResourceList> {
    this.ensureInitialized();

    return {
      resources: [
        {
          uri: 'mock://data',
          name: 'Mock Data',
          description: 'All mock data',
          mimeType: 'application/json'
        }
      ]
    };
  }

  async healthCheck(): Promise<HealthStatus> {
    return {
      healthy: this.initialized,
      message: this.initialized ? 'Mock adapter is healthy' : 'Mock adapter not initialized',
      details: { dataCount: this.data.length }
    };
  }

  async shutdown(): Promise<void> {
    this.initialized = false;
    logger.info('Mock adapter shut down');
  }

  isInitialized(): boolean {
    return this.initialized;
  }

  private ensureInitialized(): void {
    if (!this.initialized) {
      throw new Error('Mock adapter not initialized');
    }
  }
}
```

### Step 4: Create Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

export function createLogger() {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: 'knowledge-server',
      version: '1.0.0'
    },
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard'
      }
    }
  });

  return logger.child({ requestId: randomUUID() });
}

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

**Verification:** Compile and check for errors.

---

## Lab 6.2: Knowledge Server Implementation

**Objective:** Implement the Knowledge Server that uses adapters.

### Step 1: Create Knowledge Server

Create `src/knowledge-server.ts`:

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { DataSourceAdapter } from './adapters/base-adapter.js';
import { MockAdapter } from './adapters/mock-adapter.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('knowledge-server');

export class KnowledgeServer {
  private server: McpServer;
  private adapters: Map<string, DataSourceAdapter> = new Map();
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Knowledge Server');

    this.server = new McpServer({
      name: 'knowledge-server',
      version: '1.0.0'
    });

    this.initializeAdapters();
    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Knowledge Server initialized', {
      adapterCount: this.adapters.size,
      adapters: Array.from(this.adapters.keys())
    });
  }

  private initializeAdapters(): void {
    logger.info('Initializing adapters');

    // Add mock adapter
    const mock = new MockAdapter();
    this.adapters.set('mock', mock);

    // Initialize all adapters
    for (const [id, adapter] of this.adapters) {
      try {
        adapter.initialize();
        logger.info(`Adapter initialized: ${id}`);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.error(`Failed to initialize adapter: ${id}`, { error: errorMsg });
      }
    }
  }

  private registerTools(): void {
    logger.info('Registering tools');

    // Search tool
    this.server.tool(
      'search_knowledge',
      {
        query: z.string().describe('The search query'),
        sources: z.array(z.string()).optional().describe('Sources to search'),
        limit: z.number().optional().default(10).describe('Max results per source')
      },
      async ({ query, sources = [], limit = 10 }) => {
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
              { type: 'text', text: 'No data sources available.' }
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
            const errorMsg = error instanceof Error ? error.message : 'Unknown error';
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
            { type: 'text', text: responseText },
            { type: 'text', text: JSON.stringify({
              query,
              results: validResults,
              errors
            }, null, 2) }
          ]
        };
      }
    );

    // Health check tool
    this.server.tool(
      'health_check',
      {},
      async () => {
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

    logger.info('Tools registered');
  }

  private registerResources(): void {
    logger.info('Registering resources');

    // Knowledge index resource
    this.server.resource(
      'knowledge_index',
      'knowledge://index',
      {
        description: 'Index of all available knowledge sources',
        mimeType: 'application/json'
      },
      async () => {
        const sources = Array.from(this.adapters.entries()).map(([id, adapter]) => ({
          id,
          name: adapter.name,
          description: adapter.description,
          status: adapter.isInitialized() ? 'online' : 'offline'
        }));

        return {
          contents: [{
            uri: 'knowledge://index',
            text: JSON.stringify({
              version: '1.0.0',
              sources,
              total: sources.length,
              online: sources.filter(s => s.status === 'online').length
            }, null, 2),
            mimeType: 'application/json'
          }]
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
                contents: [{
                  uri: data.uri,
                  text: typeof data.content === 'string' ? data.content : data.content.toString(),
                  mimeType: data.mimeType
                }]
              };
            }
          );
          logger.debug(`Registered resource: ${resource.uri}`);
        }
        logger.info(`Registered resources from ${adapter.name}`);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.warn(`Failed to register resources from ${adapter.name}`, { error: errorMsg });
      }
    }

    logger.info('Resources registered');
  }

  private registerPrompts(): void {
    logger.info('Registering prompts');

    // Discovery prompt
    this.server.prompt(
      'discover_knowledge',
      {
        topic: z.string().describe('The topic to research'),
        depth: z.enum(['brief', 'detailed', 'comprehensive']).optional().default('detailed')
      },
      ({ topic, depth }) => {
        const depthMapping = {
          brief: 'Provide a concise overview with key facts',
          detailed: 'Provide comprehensive information with examples and references',
          comprehensive: 'Provide exhaustive research with multiple perspectives and sources'
        };

        const prompt = `You are a Knowledge Discovery Assistant.

**Research Topic:** ${topic}
**Depth:** ${depth} (${depthMapping[depth]})

Available knowledge sources:
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
          messages: [{
            role: 'assistant',
            content: {
              type: 'text',
              text: prompt
            }
          }]
        };
      }
    );

    logger.info('Prompts registered');
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('Server already running');
      return;
    }

    logger.info('Starting server...');

    try {
      const transport = new StdioServerTransport();
      await this.server.connect(transport);
      this.isRunning = true;
      logger.info('Server started');
      console.error('🚀 Knowledge Server running...');
      console.error(`   Adapters: ${Array.from(this.adapters.keys()).join(', ')}`);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start server', { error: errorMsg });
      throw error;
    }
  }

  async stop(): Promise<void> {
    if (!this.isRunning) {
      logger.warn('Server not running');
      return;
    }

    logger.info('Stopping server...');

    try {
      // Shut down all adapters
      for (const [id, adapter] of this.adapters) {
        try {
          await adapter.shutdown();
          logger.debug(`Adapter shut down: ${id}`);
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : 'Unknown error';
          logger.error(`Failed to shut down adapter: ${id}`, { error: errorMsg });
        }
      }

      this.isRunning = false;
      logger.info('Server stopped');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop server', { error: errorMsg });
      throw error;
    }
  }
}
```

### Step 3: Create Entry Point

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { KnowledgeServer } from './knowledge-server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

const main = async () => {
  logger.info('Starting Knowledge Server');

  try {
    const server = new KnowledgeServer();

    process.on('SIGINT', async () => {
      await server.stop();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      await server.stop();
      process.exit(0);
    });

    await server.start();

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.fatal('Failed to start server', { error: errorMsg });
    process.exit(1);
  }
};

main();
```

### Step 4: Create Test Client

Create `src/client-test.ts`:

```typescript
#!/usr/bin/env node

import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function testKnowledgeServer() {
  logger.info('Testing Knowledge Server');

  const client = new McpClient({
    name: 'knowledge-test-client',
    version: '1.0.0'
  });

  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  try {
    await client.connect(transport);

    // Test 1: Health check
    logger.info('Test 1: Health check');
    const health = await client.callTool('health_check', {});
    logger.info('Health:', health.content[0]?.text?.substring(0, 100));

    // Test 2: Search
    logger.info('Test 2: Search knowledge');
    const search = await client.callTool('search_knowledge', {
      query: 'category A',
      limit: 5
    });
    logger.info('Search results:', search.content[1]?.text?.substring(0, 300));

    // Test 3: Knowledge index
    logger.info('Test 3: Knowledge index');
    const index = await client.readResource('knowledge://index');
    logger.info('Index:', index.contents[0]?.text?.substring(0, 300));

    // Test 4: Mock data resource
    logger.info('Test 4: Mock data resource');
    const data = await client.readResource('mock://data');
    logger.info('Mock data:', data.contents[0]?.text?.substring(0, 300));

    // Test 5: Discovery prompt
    logger.info('Test 5: Discovery prompt');
    const prompt = await client.getPrompt('discover_knowledge', {
      topic: 'data analysis',
      depth: 'brief'
    });
    logger.info('Prompt:', prompt.messages[0]?.content?.text?.substring(0, 200));

    logger.info('✅ All tests passed!');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Test failed:', { error: errorMsg });
  } finally {
    await client.close();
  }
}

testKnowledgeServer();
```

### Step 5: Run the Tests

```bash
npm run build
npm start
```

In another terminal:

```bash
npx tsx src/client-test.ts
```

**Expected Output:**
```
[INFO] Testing Knowledge Server
[INFO] Test 1: Health check
[INFO] Health: Health Check: ✅ All systems operational
[INFO] Test 2: Search knowledge
[INFO] Search results: {"query":"category A","results":[{"source":"mock",...}
[INFO] Test 3: Knowledge index
[INFO] Index: {"version":"1.0.0","sources":[{"id":"mock",...}
[INFO] Test 4: Mock data resource
[INFO] Mock data: [{"id":1,"name":"Item 1",...}
[INFO] Test 5: Discovery prompt
[INFO] Prompt: You are a Knowledge Discovery Assistant...
[INFO] ✅ All tests passed!
```

**Verification:** All tests should pass. The search should return items from the mock adapter.

---

# LAB 7: PRODUCTION MCP CLIENT

## Lab 7.1: MCP Client Library Implementation

**Objective:** Build a production-grade MCP client library.

### Step 1: Create Project

```bash
cd mcp-labs
mkdir lab-07-client
cd lab-07-client
npm init -y
npm install @modelcontextprotocol/sdk zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx
```

### Step 2: Create Types

Create `src/types.ts`:

```typescript
export interface MCPServerConfig {
  id: string;
  name?: string;
  version?: string;
  transport: {
    type: 'stdio' | 'websocket' | 'http';
    command?: string;
    args?: string[];
    env?: Record<string, string>;
    baseUrl?: string;
  };
  auth?: {
    type: 'apiKey' | 'bearer';
    token: string;
  };
  timeout?: number;
  autoReconnect?: boolean;
  maxReconnectAttempts?: number;
}

export interface MCPTool {
  name: string;
  description?: string;
  inputSchema?: {
    type: 'object';
    properties?: Record<string, any>;
    required?: string[];
  };
}

export interface MCPResource {
  uri: string;
  name?: string;
  description?: string;
  mimeType?: string;
}

export interface MCPPrompt {
  name: string;
  description?: string;
  arguments?: Array<{
    name: string;
    description?: string;
    required?: boolean;
  }>;
}

export interface MCPCapabilities {
  tools: MCPTool[];
  resources: MCPResource[];
  prompts: MCPPrompt[];
}

export interface ToolCallResult {
  success: boolean;
  content: Array<{
    type: 'text' | 'image' | 'resource';
    text?: string;
    data?: string;
    mimeType?: string;
    uri?: string;
  }>;
  error?: string;
}

export type ConnectionState = 'disconnected' | 'connecting' | 'connected' | 'reconnecting' | 'error';
```

### Step 3: Create Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

export function createLogger() {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: 'mcp-client',
      version: '1.0.0'
    },
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard'
      }
    }
  });

  return logger.child({ requestId: randomUUID() });
}

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

### Step 4: Create Server Manager

Create `src/server-manager.ts`:

```typescript
import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { MCPServerConfig, ConnectionState } from './types.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('server-manager');

export class ServerManager {
  private config: MCPServerConfig;
  private client: McpClient | null = null;
  private transport: StdioClientTransport | null = null;
  private state: ConnectionState = 'disconnected';
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number;
  private autoReconnect: boolean;
  private reconnectTimer: NodeJS.Timeout | null = null;

  constructor(config: MCPServerConfig) {
    this.config = config;
    this.maxReconnectAttempts = config.maxReconnectAttempts || 5;
    this.autoReconnect = config.autoReconnect !== false;

    logger.info('Server manager created', { id: config.id });
  }

  async connect(): Promise<void> {
    if (this.state === 'connected' || this.state === 'connecting') {
      logger.warn('Already connected or connecting');
      return;
    }

    this.state = 'connecting';
    logger.info('Connecting to server', { id: this.config.id });

    try {
      if (this.config.transport.type !== 'stdio') {
        throw new Error('Only stdio transport is supported in this demo');
      }

      this.client = new McpClient({
        name: this.config.name || 'mcp-client',
        version: this.config.version || '1.0.0'
      });

      this.transport = new StdioClientTransport({
        command: this.config.transport.command!,
        args: this.config.transport.args || [],
        env: this.config.transport.env || {}
      });

      await this.client.connect(this.transport);
      this.state = 'connected';
      this.reconnectAttempts = 0;

      logger.info('Connected to server', { id: this.config.id });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.state = 'error';
      logger.error('Failed to connect', { id: this.config.id, error: errorMsg });

      if (this.autoReconnect) {
        this.scheduleReconnect();
      }

      throw error;
    }
  }

  async disconnect(): Promise<void> {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    if (this.client) {
      try {
        await this.client.close();
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.warn('Error during disconnect', { id: this.config.id, error: errorMsg });
      }
    }

    this.client = null;
    this.transport = null;
    this.state = 'disconnected';
    logger.info('Disconnected from server', { id: this.config.id });
  }

  private scheduleReconnect(): void {
    if (this.reconnectTimer) {
      return;
    }

    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      logger.error('Max reconnection attempts reached', {
        id: this.config.id,
        attempts: this.reconnectAttempts
      });
      this.state = 'error';
      return;
    }

    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
    this.reconnectAttempts++;

    logger.info('Scheduling reconnection', {
      id: this.config.id,
      attempt: this.reconnectAttempts,
      delay
    });

    this.state = 'reconnecting';
    this.reconnectTimer = setTimeout(async () => {
      this.reconnectTimer = null;
      try {
        await this.connect();
      } catch (error) {
        this.scheduleReconnect();
      }
    }, delay);
  }

  async callTool(name: string, args: any): Promise<any> {
    if (!this.client || this.state !== 'connected') {
      throw new Error(`Not connected to server ${this.config.id}`);
    }

    try {
      return await this.client.callTool(name, args);
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      if (this.autoReconnect && this.state === 'connected') {
        logger.warn('Connection lost, reconnecting...');
        this.state = 'error';
        this.scheduleReconnect();
      }
      throw new Error(`Tool call failed: ${errorMsg}`);
    }
  }

  async listTools(): Promise<any> {
    if (!this.client || this.state !== 'connected') {
      throw new Error(`Not connected to server ${this.config.id}`);
    }
    return await this.client.listTools();
  }

  async readResource(uri: string): Promise<any> {
    if (!this.client || this.state !== 'connected') {
      throw new Error(`Not connected to server ${this.config.id}`);
    }
    return await this.client.readResource(uri);
  }

  getState(): ConnectionState {
    return this.state;
  }

  getConfig(): MCPServerConfig {
    return { ...this.config };
  }

  isConnected(): boolean {
    return this.state === 'connected';
  }
}
```

### Step 5: Create Main Client

Create `src/mcp-client.ts`:

```typescript
import { MCPServerConfig, MCPCapabilities } from './types.js';
import { ServerManager } from './server-manager.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('mcp-client');

export class MCPClient {
  private servers: Map<string, ServerManager> = new Map();
  private capabilities: Map<string, MCPCapabilities> = new Map();

  constructor(servers: MCPServerConfig[] = []) {
    for (const config of servers) {
      this.addServer(config);
    }
    logger.info('MCP Client initialized', { serverCount: servers.length });
  }

  addServer(config: MCPServerConfig): void {
    if (this.servers.has(config.id)) {
      throw new Error(`Server ${config.id} already exists`);
    }

    const manager = new ServerManager(config);
    this.servers.set(config.id, manager);
    logger.info('Server added', { id: config.id });
  }

  async connectAll(): Promise<void> {
    logger.info('Connecting to all servers');

    const promises = Array.from(this.servers.entries()).map(async ([id, manager]) => {
      try {
        await manager.connect();
        // Discover capabilities after connection
        await this.discoverCapabilities(id);
        logger.info(`Connected to server: ${id}`);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.error(`Failed to connect to server: ${id}`, { error: errorMsg });
      }
    });

    await Promise.all(promises);
  }

  async connectServer(id: string): Promise<void> {
    const manager = this.servers.get(id);
    if (!manager) {
      throw new Error(`Server ${id} not found`);
    }
    await manager.connect();
    await this.discoverCapabilities(id);
  }

  async disconnectAll(): Promise<void> {
    logger.info('Disconnecting from all servers');

    const promises = Array.from(this.servers.entries()).map(async ([id, manager]) => {
      try {
        await manager.disconnect();
        logger.info(`Disconnected from server: ${id}`);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.error(`Failed to disconnect from server: ${id}`, { error: errorMsg });
      }
    });

    await Promise.all(promises);
  }

  async discoverCapabilities(serverId: string): Promise<MCPCapabilities> {
    const manager = this.servers.get(serverId);
    if (!manager) {
      throw new Error(`Server ${serverId} not found`);
    }

    try {
      const toolsResult = await manager.listTools();
      const tools = toolsResult.tools || [];

      // Note: Resources and prompts would be discovered similarly
      // For brevity, we're only discovering tools in this demo

      const capabilities: MCPCapabilities = {
        tools,
        resources: [],
        prompts: []
      };

      this.capabilities.set(serverId, capabilities);
      logger.info('Capabilities discovered', {
        serverId,
        tools: tools.length
      });

      return capabilities;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to discover capabilities', { serverId, error: errorMsg });
      throw error;
    }
  }

  async callTool(serverId: string, name: string, args: any): Promise<any> {
    const manager = this.servers.get(serverId);
    if (!manager) {
      throw new Error(`Server ${serverId} not found`);
    }
    return await manager.callTool(name, args);
  }

  async readResource(serverId: string, uri: string): Promise<any> {
    const manager = this.servers.get(serverId);
    if (!manager) {
      throw new Error(`Server ${serverId} not found`);
    }
    return await manager.readResource(uri);
  }

  getCapabilities(serverId: string): MCPCapabilities | undefined {
    return this.capabilities.get(serverId);
  }

  listServers(): string[] {
    return Array.from(this.servers.keys());
  }

  getServerState(serverId: string): string {
    const manager = this.servers.get(serverId);
    return manager ? manager.getState() : 'unknown';
  }
}
```

**Verification:** Compile and check for errors.

---

## Lab 7.2: Testing the MCP Client

**Objective:** Test the MCP client with a real server.

### Step 1: Create Test Client

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { MCPClient } from './mcp-client.js';
import { MCPServerConfig } from './types.js';
import { createLogger } from './logger.js';

const logger = createLogger();

async function main() {
  logger.info('Starting MCP Client Test');

  const serverConfig: MCPServerConfig = {
    id: 'test-server',
    name: 'Test Server',
    version: '1.0.0',
    transport: {
      type: 'stdio',
      command: 'node',
      args: ['../../lab-02-first-server/dist/index.js'],
      env: {
        NODE_ENV: 'development',
        LOG_LEVEL: 'info'
      }
    },
    autoReconnect: true,
    maxReconnectAttempts: 3,
    timeout: 30000
  };

  const client = new MCPClient([serverConfig]);

  try {
    await client.connectAll();

    // List capabilities
    const caps = client.getCapabilities('test-server');
    if (caps) {
      logger.info('Available tools:', caps.tools.map(t => t.name));
    }

    // Call a tool
    logger.info('Calling add tool...');
    const result = await client.callTool('test-server', 'add', { a: 10, b: 5 });
    logger.info('Add result:', result.content[0]?.text);

    // Read a resource
    logger.info('Reading system info...');
    const resource = await client.readResource('test-server', 'system://info');
    logger.info('System info:', resource.contents[0]?.text?.substring(0, 100) + '...');

    logger.info('✅ Client test complete!');

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    logger.error('Test failed:', { error: errorMsg });
  } finally {
    await client.disconnectAll();
  }
}

main();
```

### Step 2: Run the Test

```bash
# First, build the test server
cd ../lab-02-first-server
npm run build

# Return to the client lab
cd ../lab-07-client
npm run build
npm start
```

**Expected Output:**
```
[INFO] Starting MCP Client Test
[INFO] Connecting to all servers
[INFO] Server manager created { id: 'test-server' }
[INFO] Connecting to server { id: 'test-server' }
[INFO] Connected to server { id: 'test-server' }
[INFO] Connected to server: test-server
[INFO] MCP Client initialized { serverCount: 1 }
[INFO] Available tools: [ 'add', 'subtract', 'multiply', 'divide', 'read_file', 'list_directory' ]
[INFO] Calling add tool...
[INFO] Add result: 10 + 5 = 15
[INFO] Reading system info...
[INFO] System info: {...
[INFO] ✅ Client test complete!
[INFO] Disconnecting from all servers
[INFO] Disconnected from server: test-server
```

**Verification:** All tests should pass. The client should connect to the server, discover capabilities, and call tools.

---

# LAB 8: AUTONOMOUS RESEARCH ASSISTANT

## Lab 8.1: Memory System

**Objective:** Implement a memory system for the research assistant.

### Step 1: Create Project

```bash
cd mcp-labs
mkdir lab-08-agents
cd lab-08-agents
npm init -y
npm install zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx
```

### Step 2: Create Memory System

Create `src/memory.ts`:

```typescript
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('memory');

export interface MemoryEntry {
  id: string;
  content: string;
  type: 'observation' | 'conclusion' | 'plan' | 'reflection' | 'result';
  timestamp: Date;
  importance: number; // 1-10
  metadata?: Record<string, any>;
}

export class SemanticMemory {
  private shortTerm: MemoryEntry[] = [];
  private longTerm: MemoryEntry[] = [];
  private maxShortTerm: number = 10;
  private maxLongTerm: number = 100;

  constructor(maxShortTerm?: number, maxLongTerm?: number) {
    this.maxShortTerm = maxShortTerm || 10;
    this.maxLongTerm = maxLongTerm || 100;
    logger.info('Semantic memory initialized', {
      maxShortTerm: this.maxShortTerm,
      maxLongTerm: this.maxLongTerm
    });
  }

  add(content: string, type: MemoryEntry['type'], importance: number = 5, metadata?: Record<string, any>): MemoryEntry {
    const entry: MemoryEntry = {
      id: `mem-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`,
      content,
      type,
      timestamp: new Date(),
      importance: Math.min(10, Math.max(1, importance)),
      metadata
    };

    // Add to short-term
    this.shortTerm.unshift(entry);

    // Move important entries to long-term
    if (this.shortTerm.length > this.maxShortTerm) {
      const moved = this.shortTerm.pop()!;
      if (moved.importance >= 4) {
        this.longTerm.unshift(moved);
        logger.debug('Moved memory to long-term', {
          content: moved.content.substring(0, 30),
          importance: moved.importance
        });
      }
    }

    // Trim long-term
    if (this.longTerm.length > this.maxLongTerm) {
      this.longTerm = this.longTerm.slice(0, this.maxLongTerm);
    }

    logger.debug('Memory added', { type, content: content.substring(0, 30), importance });
    return entry;
  }

  getRecent(count: number = 5): MemoryEntry[] {
    return this.shortTerm.slice(0, count);
  }

  search(query: string, limit: number = 10): MemoryEntry[] {
    const results = [...this.shortTerm, ...this.longTerm]
      .filter(entry => entry.content.toLowerCase().includes(query.toLowerCase()))
      .sort((a, b) => b.importance - a.importance)
      .slice(0, limit);

    logger.debug('Memory search completed', { query, results: results.length });
    return results;
  }

  getByType(type: MemoryEntry['type'], limit: number = 10): MemoryEntry[] {
    return [...this.shortTerm, ...this.longTerm]
      .filter(entry => entry.type === type)
      .sort((a, b) => b.importance - a.importance)
      .slice(0, limit);
  }

  getAll(): MemoryEntry[] {
    return [...this.shortTerm, ...this.longTerm];
  }

  getContext(limit: number = 10): string {
    const entries = this.shortTerm.slice(0, limit);
    if (entries.length === 0) {
      return 'No recent memories.';
    }
    return entries.map(e =>
      `[${e.type}] ${e.content} (${e.timestamp.toISOString()})`
    ).join('\n');
  }

  clearShortTerm(): void {
    this.shortTerm = [];
    logger.debug('Short-term memory cleared');
  }

  clearAll(): void {
    this.shortTerm = [];
    this.longTerm = [];
    logger.debug('All memory cleared');
  }

  getStats(): {
    shortTermCount: number;
    longTermCount: number;
    totalCount: number;
    types: Record<MemoryEntry['type'], number>;
  } {
    const all = this.getAll();
    const types: Record<MemoryEntry['type'], number> = {
      observation: 0,
      conclusion: 0,
      plan: 0,
      reflection: 0,
      result: 0
    };

    for (const entry of all) {
      types[entry.type] = (types[entry.type] || 0) + 1;
    }

    return {
      shortTermCount: this.shortTerm.length,
      longTermCount: this.longTerm.length,
      totalCount: all.length,
      types
    };
  }
}
```

### Step 3: Create Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

export function createLogger() {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: 'research-agent',
      version: '1.0.0'
    },
    transport: {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:standard'
      }
    }
  });

  return logger.child({ requestId: randomUUID() });
}

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

### Step 4: Test the Memory System

Create `src/test-memory.ts`:

```typescript
#!/usr/bin/env node

import { SemanticMemory } from './memory.js';
import { createLogger } from './logger.js';

const logger = createLogger();

function testMemory() {
  logger.info('Testing memory system');

  const memory = new SemanticMemory(3, 5);

  // Add some memories
  memory.add('User asked about database optimization', 'observation', 7);
  memory.add('Database has 10,000 users', 'observation', 5);
  memory.add('Need to create indexes on email and name columns', 'plan', 8);
  memory.add('Indexes should improve query performance by 80%', 'conclusion', 9);
  memory.add('User confirmed the approach', 'observation', 6);
  memory.add('Will implement indexes in the next sprint', 'plan', 7);

  logger.info('Memory stats:', memory.getStats());

  // Get context
  logger.info('Context:', memory.getContext(3));

  // Search
  logger.info('Search "index":', memory.search('index'));
  logger.info('Search "performance":', memory.search('performance'));

  // Get by type
  logger.info('Plans:', memory.getByType('plan'));
  logger.info('Conclusions:', memory.getByType('conclusion'));

  logger.info('✅ Memory test complete!');
}

testMemory();
```

### Step 5: Run the Test

```bash
npx tsx src/test-memory.ts
```

**Expected Output:**
```
[INFO] Testing memory system
[INFO] Memory stats: { shortTermCount: 3, longTermCount: 2, totalCount: 5, types: { ... } }
[INFO] Context: [plan] Will implement indexes in the next sprint...
[INFO] Search "index": [ { id: '...', content: 'Need to create indexes...', ... } ]
[INFO] Plans: [ { content: 'Will implement indexes...' }, { content: 'Need to create indexes...' } ]
[INFO] Conclusions: [ { content: 'Indexes should improve query performance...' } ]
[INFO] ✅ Memory test complete!
```

**Verification:** The memory system should store, retrieve, and search memories correctly.

---

## Lab 8.2: Planner Implementation

**Objective:** Implement the planner that creates research plans.

### Step 1: Create Planner

Create `src/planner.ts`:

```typescript
import { SemanticMemory } from './memory.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('planner');

export interface PlanStep {
  id: string;
  description: string;
  action: string;
  parameters: Record<string, any>;
  dependencies: string[];
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  result?: any;
  error?: string;
}

export interface ResearchPlan {
  id: string;
  goal: string;
  steps: PlanStep[];
  status: 'planning' | 'executing' | 'completed' | 'failed';
  createdAt: Date;
  updatedAt: Date;
}

export class Planner {
  private memory: SemanticMemory;

  constructor(memory: SemanticMemory) {
    this.memory = memory;
    logger.info('Planner initialized');
  }

  createPlan(goal: string): ResearchPlan {
    logger.info('Creating research plan', { goal });

    // Store goal in memory
    this.memory.add(`Goal: ${goal}`, 'plan', 8);

    const plan: ResearchPlan = {
      id: `plan-${Date.now()}`,
      goal,
      steps: this.generateSteps(goal),
      status: 'planning',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    this.memory.add(
      `Created plan with ${plan.steps.length} steps`,
      'plan',
      7,
      { stepCount: plan.steps.length }
    );

    logger.info('Research plan created', {
      planId: plan.id,
      stepCount: plan.steps.length
    });

    return plan;
  }

  private generateSteps(goal: string): PlanStep[] {
    const steps: PlanStep[] = [];

    // Step 1: Understand the request
    steps.push({
      id: 'step-1',
      description: 'Understand the research request and identify key requirements',
      action: 'reflect',
      parameters: { focus: 'requirements' },
      dependencies: [],
      status: 'pending'
    });

    // Step 2: Determine data sources
    steps.push({
      id: 'step-2',
      description: 'Determine which data sources are needed for the research',
      action: 'search_knowledge',
      parameters: { query: `Data sources for: ${goal}` },
      dependencies: ['step-1'],
      status: 'pending'
    });

    // Step 3: Query data sources
    steps.push({
      id: 'step-3',
      description: 'Query data sources for relevant information',
      action: 'execute_query',
      parameters: { query: goal },
      dependencies: ['step-2'],
      status: 'pending'
    });

    // Step 4: Analyze results
    steps.push({
      id: 'step-4',
      description: 'Analyze and synthesize research findings',
      action: 'analyze_results',
      parameters: { context: goal, format: 'summary' },
      dependencies: ['step-3'],
      status: 'pending'
    });

    // Step 5: Draw conclusions
    steps.push({
      id: 'step-5',
      description: 'Draw conclusions and provide recommendations',
      action: 'reflect',
      parameters: { focus: 'conclusions' },
      dependencies: ['step-4'],
      status: 'pending'
    });

    return steps;
  }

  getNextStep(plan: ResearchPlan): PlanStep | null {
    const pending = plan.steps.filter(step =>
      step.status === 'pending' &&
      step.dependencies.every(depId => {
        const dep = plan.steps.find(s => s.id === depId);
        return dep && dep.status === 'completed';
      })
    );

    return pending.length > 0 ? pending[0] : null;
  }

  updateStep(plan: ResearchPlan, stepId: string, status: PlanStep['status'], result?: any, error?: string): void {
    const step = plan.steps.find(s => s.id === stepId);
    if (!step) {
      throw new Error(`Step ${stepId} not found in plan`);
    }

    step.status = status;
    if (result !== undefined) step.result = result;
    if (error !== undefined) step.error = error;

    plan.updatedAt = new Date();

    logger.debug('Step updated', {
      planId: plan.id,
      stepId,
      status,
      hasResult: result !== undefined,
      hasError: error !== undefined
    });

    if (status === 'completed') {
      this.memory.add(
        `Completed step: ${step.description}`,
        'result',
        6,
        { stepId }
      );
    }

    if (status === 'failed') {
      this.memory.add(
        `Failed step: ${step.description}`,
        'reflection',
        7,
        { stepId, error }
      );
    }

    this.updatePlanStatus(plan);
  }

  private updatePlanStatus(plan: ResearchPlan): void {
    const statuses = plan.steps.map(s => s.status);

    if (statuses.every(s => s === 'completed')) {
      plan.status = 'completed';
      this.memory.add(`Research plan completed: ${plan.goal}`, 'conclusion', 9);
    } else if (statuses.some(s => s === 'failed')) {
      plan.status = 'failed';
      this.memory.add(`Research plan failed: ${plan.goal}`, 'reflection', 8);
    } else if (statuses.some(s => s === 'pending' || s === 'in_progress')) {
      plan.status = 'executing';
    }

    plan.updatedAt = new Date();
  }

  getPlanSummary(plan: ResearchPlan): string {
    const total = plan.steps.length;
    const completed = plan.steps.filter(s => s.status === 'completed').length;
    const failed = plan.steps.filter(s => s.status === 'failed').length;
    const pending = plan.steps.filter(s => s.status === 'pending').length;

    let summary = `Plan: ${plan.goal}\n`;
    summary += `Status: ${plan.status}\n`;
    summary += `Progress: ${completed}/${total} steps completed`;

    if (failed > 0) summary += `, ${failed} failed`;
    if (pending > 0) summary += `, ${pending} pending`;

    summary += '\n\nSteps:\n';
    for (const step of plan.steps) {
      const icon = step.status === 'completed' ? '✅' :
                   step.status === 'failed' ? '❌' :
                   step.status === 'in_progress' ? '🔄' :
                   '⏳';
      summary += `${icon} ${step.description}`;
      if (step.status === 'failed' && step.error) {
        summary += ` (${step.error})`;
      }
      summary += '\n';
    }

    return summary;
  }
}
```

### Step 2: Test the Planner

Create `src/test-planner.ts`:

```typescript
#!/usr/bin/env node

import { SemanticMemory } from './memory.js';
import { Planner } from './planner.js';
import { createLogger } from './logger.js';

const logger = createLogger();

function testPlanner() {
  logger.info('Testing planner');

  const memory = new SemanticMemory();
  const planner = new Planner(memory);

  // Create a plan
  const plan = planner.createPlan(
    'Research best practices for API authentication and security'
  );

  logger.info('Plan created:', {
    id: plan.id,
    status: plan.status,
    stepCount: plan.steps.length
  });

  // Execute the plan step by step
  let step = planner.getNextStep(plan);
  let iteration = 0;

  while (step && iteration < 10) {
    iteration++;
    logger.info(`Executing step: ${step.description}`);

    planner.updateStep(plan, step.id, 'in_progress');

    // Simulate execution
    if (step.id === 'step-1') {
      // Simulate reflection
      planner.updateStep(plan, step.id, 'completed', { reflection: 'Understood requirements' });
    } else if (step.id === 'step-2') {
      // Simulate search
      planner.updateStep(plan, step.id, 'completed', { sources: ['knowledge-base', 'api-docs'] });
    } else if (step.id === 'step-3') {
      // Simulate query
      planner.updateStep(plan, step.id, 'completed', { results: ['OAuth 2.0', 'JWT', 'API Keys'] });
    } else if (step.id === 'step-4') {
      // Simulate analysis
      planner.updateStep(plan, step.id, 'completed', { analysis: 'OAuth 2.0 recommended for production' });
    } else if (step.id === 'step-5') {
      // Simulate conclusions
      planner.updateStep(plan, step.id, 'completed', { conclusions: 'Use OAuth 2.0 with JWT' });
    }

    logger.info('Step status:', { id: step.id, status: step.status });

    step = planner.getNextStep(plan);
  }

  logger.info('Plan summary:\n', planner.getPlanSummary(plan));

  logger.info('Memory stats:', memory.getStats());

  logger.info('✅ Planner test complete!');
}

testPlanner();
```

### Step 3: Run the Test

```bash
npx tsx src/test-planner.ts
```

**Expected Output:**
```
[INFO] Testing planner
[INFO] Planner initialized
[INFO] Creating research plan { goal: 'Research best practices for API authentication...' }
[INFO] Research plan created { planId: 'plan-...', stepCount: 5 }
[INFO] Plan created: { id: 'plan-...', status: 'planning', stepCount: 5 }
[INFO] Executing step: Understand the research request...
[INFO] Step status: { id: 'step-1', status: 'completed' }
[INFO] Executing step: Determine which data sources are needed...
[INFO] Step status: { id: 'step-2', status: 'completed' }
[INFO] Executing step: Query data sources...
[INFO] Step status: { id: 'step-3', status: 'completed' }
[INFO] Executing step: Analyze and synthesize research findings...
[INFO] Step status: { id: 'step-4', status: 'completed' }
[INFO] Executing step: Draw conclusions...
[INFO] Step status: { id: 'step-5', status: 'completed' }
[INFO] Plan summary: Plan: Research best practices...
[INFO] ✅ Planner test complete!
```

**Verification:** The planner should create a plan with 5 steps and execute them in order.

---

# APPENDIX: TROUBLESHOOTING GUIDE

## Common Issues and Solutions

### Node.js Version Issues

**Issue:** `SyntaxError: Unexpected token '?'`

**Solution:** Ensure you're using Node.js 20+:
```bash
node --version
# If less than v20, upgrade using nvm:
nvm install 20
nvm use 20
```

### TypeScript Compilation Errors

**Issue:** `Cannot find module '@modelcontextprotocol/sdk'`

**Solution:** Install the missing package:
```bash
npm install @modelcontextprotocol/sdk
```

**Issue:** `Cannot find module './logger.js'`

**Solution:** Ensure the import path is correct and the file exists:
```bash
ls src/logger.ts
```

### Connection Issues

**Issue:** `Error: spawn node ENOENT`

**Solution:** The server path is incorrect. Check the path in the client configuration:
```typescript
const serverConfig: MCPServerConfig = {
  transport: {
    type: 'stdio',
    command: 'node',
    args: ['dist/index.js'] // Make sure this path is correct
  }
};
```

**Issue:** `Error: Connection timed out`

**Solution:** Increase the timeout or check if the server is running:
```bash
# Check if server is running
ps aux | grep node
# Start the server in a separate terminal
npm start
```

### Tool Call Issues

**Issue:** `Error: Tool not found: add`

**Solution:** Ensure the tool is registered and the name is correct:
```typescript
// Check registered tools
const tools = await client.listTools();
console.log('Available tools:', tools.map(t => t.name));
```

**Issue:** `Error: Invalid params`

**Solution:** Check the tool's input schema and provide correct parameters:
```typescript
// Check tool schema
const tools = await client.listTools();
const tool = tools.find(t => t.name === 'add');
console.log('Tool schema:', tool.inputSchema);
```

### Database Issues

**Issue:** `Error: SQLITE_CANTOPEN: unable to open database file`

**Solution:** Ensure the database directory exists and is writable:
```bash
mkdir -p data
chmod 755 data
```

**Issue:** `Error: SQLITE_CONSTRAINT: UNIQUE constraint failed`

**Solution:** The data violates a unique constraint. Handle duplicates or use `INSERT OR IGNORE`:
```sql
INSERT OR IGNORE INTO users (name, email) VALUES (?, ?)
```

---

**[END OF LAB BOOK]**
