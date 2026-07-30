# STUDENT WORKBOOK
## Mastering AI Integration with MCP and A2A Using JavaScript

# WORKBOOK INTRODUCTION

## Welcome Statement

Welcome to the **Mastering AI Integration with MCP and A2A Using JavaScript** Student Workbook. This workbook is designed to accompany the comprehensive tutorial series and provide you with hands-on exercises, code templates, debugging scenarios, and knowledge checks to reinforce your learning.

### How to Use This Workbook

1. **Read the corresponding tutorial part** before attempting exercises
2. **Complete exercises in order** — they build on each other
3. **Write your own code** — don't just copy solutions
4. **Use the debugging scenarios** to practice troubleshooting
5. **Track your progress** using the checklists
6. **Review knowledge checks** before moving to the next part

### Workbook Structure

Each part includes:
- **Learning Objectives** — What you should know after completing
- **Code Templates** — Starter code with TODOs
- **Exercises** — Hands-on practice problems
- **Challenge Questions** — Deeper thinking problems
- **Debugging Scenarios** — Real-world troubleshooting
- **Knowledge Checks** — Self-assessment questions
- **Solutions Reference** — Answer keys (separate section)

---

# PART 1: INTRODUCTION TO MCP

## Learning Objectives

After completing this part, you should be able to:
- Explain what MCP is and the problem it solves
- Identify the three pillars of MCP
- Understand the client-server architecture
- Describe the role of JSON-RPC in MCP

---

## Pre-Reading Questions

**Answer these before reading the tutorial:**

1. What do you think "Model Context Protocol" means?
   ```
   Your answer:
   ```

2. Why might AI applications need a standardized way to connect to tools?
   ```
   Your answer:
   ```

3. Can you name any AI applications you've used that interact with external systems?
   ```
   Your answer:
   ```

---

## Key Concepts Fill-in-the-Blank

Complete the following sentences using the words in the box:

**Word Bank:**
`tools`, `resources`, `prompts`, `JSON-RPC`, `client`, `server`, `discovery`, `invocation`

1. The three pillars of MCP are ________, ________, and ________.

2. MCP uses ________ for communication between client and server.

3. ________ are executable functions that the AI can call.

4. ________ are data that the AI can read.

5. The ________ is responsible for discovering capabilities and invoking tools.

6. The ________ exposes tools, resources, and prompts.

7. The process of asking "what can you do?" is called ________.

8. The process of executing a tool is called ________.

---

## Matching Exercise

Match the MCP concept to its correct description:

| Concept | Description |
|---------|-------------|
| 1. Tool | A. Data the AI can read |
| 2. Resource | B. Template that guides AI behavior |
| 3. Prompt | C. Executable function the AI can call |
| 4. URI | D. Standardized communication protocol |
| 5. JSON-RPC | E. Unique identifier for a resource |

| Concept | Answer |
|---------|--------|
| 1. Tool | ___ |
| 2. Resource | ___ |
| 3. Prompt | ___ |
| 4. URI | ___ |
| 5. JSON-RPC | ___ |

---

## Short Answer Questions

1. What problem does MCP solve that function calling alone doesn't address?
   ```
   Your answer:
   ```

2. Explain the difference between a tool and a resource in MCP.
   ```
   Your answer:
   ```

3. Why is dynamic discovery important in MCP?
   ```
   Your answer:
   ```

4. What are the three transport mechanisms supported by MCP?
   ```
   Your answer:
   ```

---

## Quick Check

**Circle True or False:**

1. MCP is a proprietary protocol owned by a single company.
   True / False

2. MCP uses JSON-RPC for communication.
   True / False

3. Tools in MCP can have side effects.
   True / False

4. Resources in MCP are executable functions.
   True / False

5. Prompts in MCP are reusable templates.
   True / False

---

# PART 2: BUILDING YOUR FIRST MCP SERVER

## Learning Objectives

After completing this part, you should be able to:
- Set up a TypeScript project for MCP development
- Create a simple MCP server with tools
- Register resources and prompts
- Start and test an MCP server

---

## Code Template: Basic Server Setup

**File:** `src/server.ts`

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger } from './logger.js';

const logger = createLogger();

export class CalculatorServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Calculator Server');

    // TODO: Create McpServer instance with name and version
    // HINT: Use process.env for configuration
    this.server = new McpServer({
      // Your code here
    });

    // TODO: Register tools, resources, and prompts
    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Server initialized successfully');
  }

  private registerTools(): void {
    logger.info('Registering tools');

    // TODO: Register an 'add' tool with Zod schema
    // HINT: Use this.server.tool(name, schema, handler)
    this.server.tool(
      // Your code here
    );

    // TODO: Register a 'subtract' tool
    this.server.tool(
      // Your code here
    );

    // TODO: Register a 'multiply' tool
    this.server.tool(
      // Your code here
    );

    // TODO: Register a 'divide' tool with error handling for division by zero
    this.server.tool(
      // Your code here
    );

    // TODO: Register a 'read_file' tool with path traversal protection
    this.server.tool(
      // Your code here
    );

    logger.info('All tools registered');
  }

  private registerResources(): void {
    logger.info('Registering resources');

    // TODO: Register a system info resource (system://info)
    // HINT: Use this.server.resource(name, uri, options, handler)
    this.server.resource(
      // Your code here
    );

    // TODO: Register a server status resource (server://status)
    this.server.resource(
      // Your code here
    );

    logger.info('All resources registered');
  }

  private registerPrompts(): void {
    logger.info('Registering prompts');

    // TODO: Register a welcome prompt with optional name parameter
    this.server.prompt(
      // Your code here
    );

    // TODO: Register a help prompt with optional topic parameter
    this.server.prompt(
      // Your code here
    );

    logger.info('All prompts registered');
  }

  async start(): Promise<void> {
    // TODO: Implement start method
    // - Check if already running
    // - Create StdioServerTransport
    // - Connect server to transport
    // - Set isRunning = true
    // - Log success

    // Your code here
  }

  async stop(): Promise<void> {
    // TODO: Implement stop method
    // - Check if running
    // - Set isRunning = false
    // - Log success

    // Your code here
  }
}
```

**File:** `src/logger.ts`

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';

// TODO: Implement createLogger function
// - Use pino for structured logging
// - Include service name and version
// - Add request ID for tracing
// - Use pino-pretty for development

export function createLogger() {
  // Your code here
}

export const logger = createLogger();
```

**File:** `src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { CalculatorServer } from './server.js';
import { createLogger } from './logger.js';

const logger = createLogger();

// TODO: Implement graceful shutdown handler
// - Listen for SIGINT and SIGTERM signals
// - Stop the server cleanly

// TODO: Implement main function
// - Create server instance
// - Start server
// - Handle errors

// Your code here
```

---

## Exercise 2.1: Complete the Server

**Instructions:** Fill in the TODO sections in the code templates above.

**Checklist:**
- [ ] McpServer initialized with name and version
- [ ] Add tool registered with Zod schema
- [ ] Subtract tool registered
- [ ] Multiply tool registered
- [ ] Divide tool registered with error handling
- [ ] Read_file tool registered with security
- [ ] System info resource registered
- [ ] Server status resource registered
- [ ] Welcome prompt registered
- [ ] Help prompt registered
- [ ] Start method implemented
- [ ] Stop method implemented
- [ ] Entry point implemented

---

## Exercise 2.2: Add a New Tool

**Instructions:** Add a new tool called `calculate_discount` that calculates the discounted price of a product.

**Requirements:**
- Input: `price` (number), `discountPercent` (number, 0-100)
- Output: Discounted price and savings amount
- Validation: Price must be > 0, discount between 0 and 100

**Code:**

```typescript
// Add this tool to the registerTools method
this.server.tool(
  // Your code here
);
```

**Expected Output Example:**
```
Original price: $100.00
Discount: 20%
Discounted price: $80.00
You save: $20.00
```

---

## Exercise 2.3: Add a New Resource

**Instructions:** Add a new resource called `project_config` that returns the project configuration from environment variables.

**Requirements:**
- URI: `config://project`
- MIME Type: `application/json`
- Return: Server name, version, node environment, log level

**Code:**

```typescript
// Add this resource to the registerResources method
this.server.resource(
  // Your code here
);
```

**Expected Output Example:**
```json
{
  "serverName": "calculator-server",
  "version": "1.0.0",
  "nodeEnv": "development",
  "logLevel": "info"
}
```

---

## Debugging Scenario 2.1: Server Won't Start

**Scenario:** Your server compiles but won't start. You see this error:

```
Error: Cannot find module '@modelcontextprotocol/sdk'
```

**Diagnose the Problem:**

1. What could cause this error?
   ```
   Your diagnosis:
   ```

2. What commands would you run to fix it?
   ```
   Your solution:
   ```

3. How would you verify the fix?
   ```
   Verification steps:
   ```

---

## Debugging Scenario 2.2: Tool Not Found

**Scenario:** Your client can't find the `add` tool. The client reports:

```
Method not found: tools/call
```

**Diagnose the Problem:**

1. What could cause this error?
   ```
   Your diagnosis:
   ```

2. How would you check if the tool is actually registered?
   ```
   Your solution:
   ```

3. How would you verify the fix?
   ```
   Verification steps:
   ```

---

## Challenge Questions

1. How would you modify the `read_file` tool to also support listing directories?
   ```
   Your answer:
   ```

2. What changes would you need to make to add authentication to this server?
   ```
   Your answer:
   ```

3. How could you implement caching for resources?
   ```
   Your answer:
   ```

---

## Knowledge Check

1. What is the purpose of Zod in MCP server development?
   ```
   Your answer:
   ```

2. What transport mechanism does this server use and why?
   ```
   Your answer:
   ```

3. How does the `isError` flag in tool responses affect the client?
   ```
   Your answer:
   ```

4. What security measures are implemented in the `read_file` tool?
   ```
   Your answer:
   ```

5. Why is structured logging important in MCP servers?
   ```
   Your answer:
   ```

---

# PART 3: UNDERSTANDING JSON-RPC

## Learning Objectives

After completing this part, you should be able to:
- Explain the structure of JSON-RPC messages
- Identify different message types
- Understand the MCP message flow
- Debug common communication issues

---

## Message Structure Exercise

**Instructions:** Fill in the missing parts of these JSON-RPC messages.

### Exercise 3.1: Tool List Request

Complete the following request to list tools:

```json
{
  "___": "2.0",
  "___": "req-123",
  "___": "tools/list",
  "___": {}
}
```

### Exercise 3.2: Tool Call Response

Complete the following response for the `add` tool:

```json
{
  "jsonrpc": "2.0",
  "id": "req-456",
  "___": {
    "content": [
      {
        "type": "___",
        "text": "___"
      }
    ]
  }
}
```

### Exercise 3.3: Error Response

Complete the following error response:

```json
{
  "jsonrpc": "2.0",
  "id": "req-789",
  "___": {
    "___": -32601,
    "___": "___",
    "___": {
      "requestedTool": "unknown_tool"
    }
  }
}
```

---

## Message Type Identification

**Instructions:** Identify whether each message is a Request, Response, or Error.

| Message | Type |
|---------|------|
| `{"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}` | |
| `{"jsonrpc":"2.0","id":"1","result":{"tools":[]}}` | |
| `{"jsonrpc":"2.0","id":"2","error":{"code":-32601,"message":"Method not found"}}` | |
| `{"jsonrpc":"2.0","method":"notifications/progress","params":{"progress":50}}` | |
| `{"jsonrpc":"2.0","id":"3","method":"resources/read","params":{"uri":"system://info"}}` | |

---

## Flow Diagram Exercise

**Instructions:** Complete the sequence diagram below by filling in the missing messages.

```
┌──────────┐                    ┌──────────┐
│  Client  │                    │  Server  │
└────┬─────┘                    └────┬─────┘
     │                               │
     │ 1. ___________                │
     │─────────────────────────────►│
     │                               │
     │ 2. initialize response       │
     │◄─────────────────────────────│
     │                               │
     │ 3. ___________                │
     │─────────────────────────────►│
     │                               │
     │ 4. tools/list response       │
     │◄─────────────────────────────│
     │                               │
     │ 5. ___________                │
     │─────────────────────────────►│
     │                               │
     │ 6. resources/list response   │
     │◄─────────────────────────────│
     │                               │
     │ 7. ___________                │
     │─────────────────────────────►│
     │                               │
     │ 8. prompts/list response     │
     │◄─────────────────────────────│
     │                               │
     │ 9. tools/call (add)          │
     │─────────────────────────────►│
     │                               │
     │ 10. ___________               │
     │◄─────────────────────────────│
```

---

## Common Error Codes

**Instructions:** Match the error code to its name and meaning.

| Code | Name | Meaning |
|------|------|---------|
| -32700 | | |
| -32600 | | |
| -32601 | | |
| -32602 | | |
| -32603 | | |
| -32001 | | |
| -32002 | | |
| -32003 | | |

**Options:**
- Parse Error
- Invalid Request
- Method Not Found
- Invalid Params
- Internal Error
- Tool Not Found
- Resource Not Found
- Prompt Not Found

---

## Debugging Exercise

**Scenario:** You run your test client and get the following output:

```
Sending: {"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}
Received: {"jsonrpc":"2.0","id":"1","error":{"code":-32601,"message":"Method not found"}}
```

**Questions:**

1. What does error code -32601 mean?
   ```
   Your answer:
   ```

2. What could cause this error?
   ```
   Possible causes:
   - 
   - 
   - 
   ```

3. How would you troubleshoot this issue?
   ```
   Steps:
   1.
   2.
   3.
   ```

---

## Code Writing Exercise

**Instructions:** Write a function that validates and parses a JSON-RPC message.

```typescript
function parseJSONRPCMessage(message: string): any {
  // TODO: Parse the message and validate it's a valid JSON-RPC message
  // - Check for valid JSON
  // - Check for jsonrpc version
  // - Check for required fields (id, method, or result/error)
  
  // Your code here
  
  return parsed;
}

// Test with these messages:
const validRequest = '{"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}';
const validResponse = '{"jsonrpc":"2.0","id":"1","result":{"tools":[]}}';
const invalidMessage = '{"jsonrpc":"2.0","method":"tools/list"}'; // Missing id
const notJSON = 'not a JSON message';
```

---

# PART 4: SQLITE DATABASE SERVER

## Learning Objectives

After completing this part, you should be able to:
- Create a database connection manager
- Implement secure query execution
- Register database tools and resources
- Handle query validation and security

---

## Code Template: Connection Manager

**File:** `src/db/connection-manager.ts`

```typescript
import sqlite3 from 'sqlite3';
import { createModuleLogger } from '../logger.js';

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
    // TODO: Set default configuration from environment variables
    // - path: DB_PATH or ./data/app.db
    // - readOnly: DB_READ_ONLY or false
    // - maxConnections: DB_MAX_CONNECTIONS or 10
    // - queryTimeout: DB_QUERY_TIMEOUT or 30000
    
    // Your code here
  }

  async initialize(): Promise<void> {
    // TODO: Initialize connection pool
    // - Create initial connections
    // - Enable WAL mode
    // - Enable foreign keys
    
    // Your code here
  }

  async executeQuery(sql: string, params: any[] = []): Promise<QueryResult> {
    // TODO: Execute a query with the following steps:
    // 1. Validate query for security
    // 2. Get connection from pool
    // 3. Execute query with timeout
    // 4. Release connection
    // 5. Return result with metadata
    
    // Your code here
  }

  private validateQuery(sql: string): void {
    // TODO: Validate query for security
    // - Check for DROP, TRUNCATE
    // - Check for dangerous patterns
    // - Implement whitelist/blacklist
    
    // Your code here
  }

  async close(): Promise<void> {
    // TODO: Close all connections
    
    // Your code here
  }

  isConnectedToDatabase(): boolean {
    return this.isConnected;
  }
}

// TODO: Implement singleton pattern
export const getConnectionManager = (): ConnectionManager => {
  // Your code here
};
```

---

## Exercise 4.1: Complete the Connection Manager

**Instructions:** Fill in the TODO sections in the Connection Manager code.

**Checklist:**
- [ ] Configuration loaded from environment
- [ ] Initialize method creates connections
- [ ] WAL mode enabled
- [ ] Foreign keys enabled
- [ ] Query validation implemented
- [ ] Connection pooling works
- [ ] Query execution with timeout
- [ ] Close method releases resources
- [ ] Singleton pattern implemented

---

## Exercise 4.2: Add a Query Validation Blacklist

**Instructions:** Implement a query blacklist that blocks dangerous SQL statements.

```typescript
private validateQuery(sql: string): void {
  // TODO: Implement blacklist checking
  const blacklist = [
    // Add dangerous patterns here
  ];
  
  // Your code here
}
```

**Test Cases:**

| SQL | Should Block? |
|-----|---------------|
| `SELECT * FROM users` | No |
| `DROP TABLE users` | Yes |
| `DELETE FROM users WHERE id = 1` | Yes (if configured) |
| `UPDATE users SET name = 'test' WHERE id = 1` | Yes (if configured) |
| `TRUNCATE TABLE users` | Yes |

---

## Exercise 4.3: Create Database Tools

**Instructions:** Implement the following database tools.

### Tool 4.3.1: execute_query

```typescript
// TODO: Implement execute_query tool
// - Input: sql (string), params (array), limit (number)
// - Output: Query results with metadata
// - Security: Parameterized queries
```

### Tool 4.3.2: get_schema

```typescript
// TODO: Implement get_schema tool
// - Input: table (optional string)
// - Output: Table and column information
// - Returns: Tables, columns, indexes, views
```

### Tool 4.3.3: create_table

```typescript
// TODO: Implement create_table tool
// - Input: tableName (string), columns (array)
// - Output: Success confirmation
// - Security: Validate table name and column definitions
```

---

## Debugging Scenario 4.1: Query Timeout

**Scenario:** A query is taking too long and timing out. You see:

```
Error: Query timeout after 30000ms
```

**Diagnose the Problem:**

1. What could cause a query timeout?
   ```
   Possible causes:
   - 
   - 
   - 
   ```

2. How would you check if the query is the problem?
   ```
   Steps:
   1.
   2.
   3.
   ```

3. What are possible solutions?
   ```
   Solutions:
   - 
   - 
   - 
   ```

---

## Challenge Questions

1. How would you implement query result pagination for large datasets?
   ```
   Your answer:
   ```

2. What changes would you need to make to support PostgreSQL instead of SQLite?
   ```
   Your answer:
   ```

3. How would you implement automatic database backups?
   ```
   Your answer:
   ```

---

# PART 5: POSTGRESQL SERVER

## Learning Objectives

After completing this part, you should be able to:
- Configure PostgreSQL connection pooling
- Implement read/write query separation
- Assess query risk levels
- Use EXPLAIN ANALYZE for optimization

---

## Exercise 5.1: Connection Pool Configuration

**Instructions:** Configure the PostgreSQL connection pool with optimal settings.

```typescript
const poolConfig: PoolConfig = {
  // TODO: Set these values from environment
  host: /* ... */,
  port: /* ... */,
  user: /* ... */,
  password: /* ... */,
  database: /* ... */,
  
  // TODO: Configure pool settings
  // max: Maximum connections
  // idleTimeoutMillis: Idle timeout
  // connectionTimeoutMillis: Connection timeout
  // maxUses: Max uses per connection
  // keepAlive: Keep connections alive
  
  // Your code here
};
```

**Recommended Values:**

| Setting | Production | Development |
|---------|------------|-------------|
| max | 20 | 5 |
| idleTimeoutMillis | 30000 | 10000 |
| connectionTimeoutMillis | 5000 | 2000 |
| maxUses | 7500 | 1000 |
| keepAlive | true | true |

---

## Exercise 5.2: Query Risk Assessment

**Instructions:** Implement the `getQueryRiskLevel` method.

```typescript
export type RiskLevel = 'read-only' | 'read-write' | 'admin' | 'critical';

function getQueryRiskLevel(sql: string): RiskLevel {
  // TODO: Classify the query by risk level
  // - SELECT, SHOW, EXPLAIN → read-only
  // - INSERT, UPDATE, DELETE (with WHERE) → read-write
  // - INSERT, UPDATE, DELETE (without WHERE) → critical
  // - CREATE, ALTER, DROP → admin
  
  // Your code here
}
```

**Test Cases:**

| SQL | Expected Risk Level |
|-----|-------------------|
| `SELECT * FROM users` | |
| `INSERT INTO users (name) VALUES ('test')` | |
| `DELETE FROM users` | |
| `DELETE FROM users WHERE id = 1` | |
| `DROP TABLE users` | |
| `EXPLAIN SELECT * FROM users` | |

---

## Exercise 5.3: EXPLAIN ANALYZE Tool

**Instructions:** Implement a tool that runs EXPLAIN ANALYZE on queries.

```typescript
// TODO: Create a tool that:
// 1. Takes a SQL query as input
// 2. Runs EXPLAIN ANALYZE on it
// 3. Returns the execution plan
// 4. Identifies potential optimizations

// Input: query (string), analyze (boolean)
// Output: Execution plan and optimization suggestions
```

---

## Debugging Scenario 5.1: Slow Query

**Scenario:** Users are reporting that a query is slow. The query is:

```sql
SELECT * FROM orders JOIN users ON orders.user_id = users.id
WHERE orders.created_at > '2024-01-01'
ORDER BY orders.total DESC;
```

**Questions:**

1. What would you check first to diagnose this?
   ```
   Your answer:
   ```

2. What EXPLAIN output would indicate a problem?
   ```
   Your answer:
   ```

3. What index would you recommend?
   ```
   Your answer:
   ```

---

## Knowledge Check

1. What is the purpose of connection pooling?
   ```
   Your answer:
   ```

2. Why should read and write queries be separated?
   ```
   Your answer:
   ```

3. What does EXPLAIN ANALYZE show that regular EXPLAIN doesn't?
   ```
   Your answer:
   ```

4. How does risk level assessment improve security?
   ```
   Your answer:
   ```

---

# PART 6: KNOWLEDGE SERVER

## Learning Objectives

After completing this part, you should be able to:
- Design a multi-source data adapter architecture
- Implement search across multiple sources
- Create unified resources and tools
- Handle source failures gracefully

---

## Exercise 6.1: Base Adapter Interface

**Instructions:** Implement the base adapter interface.

```typescript
export interface DataSourceAdapter {
  // TODO: Define the adapter interface
  // - id: string
  // - name: string
  // - description: string
  // - initialize(): Promise<void>
  // - query(request: QueryRequest): Promise<QueryResult>
  // - getResource(uri: string): Promise<ResourceData>
  // - listResources(): Promise<ResourceList>
  // - healthCheck(): Promise<HealthStatus>
  // - shutdown(): Promise<void>
  
  // Your code here
}
```

---

## Exercise 6.2: Implement a GitHub Adapter

**Instructions:** Implement a GitHub adapter that connects to the GitHub API.

```typescript
export class GitHubAdapter implements DataSourceAdapter {
  // TODO: Implement GitHub adapter
  // - Initialize with GitHub token
  // - Query issues, PRs, and code
  // - Provide resources for repositories
  // - Health check for API status
  
  // Your code here
}
```

**Required Features:**
- List repository issues
- Search code in repository
- Read README as resource
- Health check

---

## Exercise 6.3: Unified Search Tool

**Instructions:** Implement a tool that searches across all adapters.

```typescript
// TODO: Create a search tool that:
// 1. Takes a query string
// 2. Searches all registered adapters
// 3. Aggregates results
// 4. Handles adapter failures gracefully
// 5. Returns unified results

// Input: query (string), sources (optional array)
// Output: Aggregated search results
```

---

## Debugging Scenario 6.1: Adapter Failure

**Scenario:** One adapter (GitHub) is failing with rate limiting errors.

```
Error: API rate limit exceeded
```

**Questions:**

1. How would you handle this failure in the knowledge server?
   ```
   Your answer:
   ```

2. What would you return to the client when one source fails?
   ```
   Your answer:
   ```

3. How could you prevent this from affecting other adapters?
   ```
   Your answer:
   ```

---

# PART 7: AUTONOMOUS RESEARCH ASSISTANT

## Learning Objectives

After completing this part, you should be able to:
- Design an autonomous agent architecture
- Implement planning and execution
- Manage agent memory
- Handle reflection and adaptation

---

## Exercise 7.1: Memory System

**Instructions:** Implement the semantic memory system.

```typescript
export class SemanticMemory {
  // TODO: Implement memory with:
  // - Short-term memory (limited size)
  // - Long-term memory (unlimited)
  // - Importance scoring
  // - Context retrieval
  // - Search functionality
  
  // Your code here
}
```

**Features Required:**
- Add memories with importance scores
- Retrieve recent memories
- Search memories by content
- Consolidate important memories to long-term

---

## Exercise 7.2: Planner Implementation

**Instructions:** Implement the planner that creates research plans.

```typescript
export class Planner {
  // TODO: Implement planner that:
  // 1. Takes a research goal
  // 2. Breaks it down into steps
  // 3. Identifies dependencies
  // 4. Assigns actions to steps
  // 5. Orders steps efficiently
  
  // Your code here
}
```

**Test Goal:** 
"Research best practices for API authentication and generate a report"

**Expected Steps:**
1. Research authentication methods
2. Compare authentication types
3. Analyze security considerations
4. Generate recommendations
5. Create report

---

## Exercise 7.3: Agent Loop

**Instructions:** Implement the main agent loop.

```typescript
class ResearchAssistant {
  // TODO: Implement agent loop that:
  // 1. Plans the research
  // 2. Executes steps
  // 3. Observes results
  // 4. Reflects on progress
  // 5. Adapts the plan
  // 6. Repeats until complete
  
  // Your code here
}
```

---

## Debugging Scenario 7.1: Infinite Loop

**Scenario:** The agent is stuck in an infinite loop, repeatedly performing the same actions.

```
Iteration 5: Executing step "Search for authentication methods"
Iteration 6: Executing step "Search for authentication methods"
Iteration 7: Executing step "Search for authentication methods"
```

**Questions:**

1. What could cause this infinite loop?
   ```
   Your answer:
   ```

2. How would you prevent infinite loops?
   ```
   Your answer:
   ```

3. What would you add to the agent to detect this condition?
   ```
   Your answer:
   ```

---

# PART 8: A2A COLLABORATION

## Learning Objectives

After completing this part, you should be able to:
- Design A2A message protocols
- Implement agent discovery
- Handle task delegation
- Manage multi-agent workflows

---

## Exercise 8.1: A2A Message Types

**Instructions:** Define the A2A message types and their schemas.

```typescript
// TODO: Define message types
export type MessageType = 
  /* Add types here */;

export interface A2AMessage {
  // TODO: Define message structure
  // - id: string
  // - type: MessageType
  // - from: string
  // - to: string | string[]
  // - subject: string
  // - body: any
  // - createdAt: Date
  // - responseTo?: string
  // - workflowId?: string
  
  // Your code here
}
```

---

## Exercise 8.2: Agent Registry

**Instructions:** Implement the agent registry for discovery.

```typescript
export class AgentRegistry {
  // TODO: Implement agent registry that:
  // - Registers agents with their capabilities
  // - Finds agents by role
  // - Finds best agent for a task
  // - Tracks agent status
  
  // Your code here
}
```

---

## Exercise 8.3: Message Router

**Instructions:** Implement the message router for agent communication.

```typescript
export class MessageRouter {
  // TODO: Implement message router that:
  // - Routes messages to agents
  // - Handles message queues
  // - Supports request-response pattern
  // - Handles message delivery failures
  
  // Your code here
}
```

---

## Debugging Scenario 8.1: Lost Messages

**Scenario:** Messages are being sent but never received by the intended agent.

**Questions:**

1. What could cause messages to be lost?
   ```
   Possible causes:
   - 
   - 
   - 
   ```

2. How would you add message delivery guarantees?
   ```
   Your answer:
   ```

3. What would you add to make the system more resilient?
   ```
   Your answer:
   ```

---

# PART 9: ADVANCED MULTI-AGENT

## Learning Objectives

After completing this part, you should be able to:
- Design hierarchical architectures
- Implement supervisor agents
- Create shared memory systems
- Handle human-in-the-loop

---

## Exercise 9.1: Supervisor Agent

**Instructions:** Implement the supervisor agent.

```typescript
export class SupervisorAgent extends BaseAgent {
  // TODO: Implement supervisor that:
  // - Breaks down projects into tasks
  // - Assigns tasks to workers
  // - Reviews work
  // - Merges results
  
  // Your code here
}
```

---

## Exercise 9.2: Shared Memory

**Instructions:** Implement shared memory for cross-agent context.

```typescript
export class SharedMemory {
  // TODO: Implement shared memory that:
  // - Stores versioned entries
  // - Tracks who created each entry
  // - Allows searching
  // - Provides context building
  
  // Your code here
}
```

---

## Exercise 9.3: Human-in-the-Loop

**Instructions:** Add human approval to the workflow.

```typescript
export class ApprovalAgent extends BaseAgent {
  // TODO: Implement human approval that:
  // - Requests approval for critical steps
  // - Handles approval and rejection
  // - Has timeout for approval
  // - Notifies humans via external channels
  
  // Your code here
}
```

---

# PART 10: PRODUCTION ENGINEERING

## Learning Objectives

After completing this part, you should be able to:
- Containerize AI applications
- Deploy on Kubernetes
- Implement monitoring and alerting
- Set up CI/CD pipelines

---

## Exercise 10.1: Dockerfile

**Instructions:** Create a Dockerfile for the Knowledge Server.

```dockerfile
# TODO: Create multi-stage Dockerfile
# Stage 1: Builder
FROM node:20-alpine AS builder
# - Set working directory
# - Install dependencies
# - Copy source code
# - Build TypeScript

# Stage 2: Production
FROM node:20-alpine
# - Copy built artifacts
# - Create non-root user
# - Set environment variables
# - Define health check
# - Set startup command

# Your code here
```

---

## Exercise 10.2: Kubernetes Deployment

**Instructions:** Create a Kubernetes deployment manifest.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: knowledge-server
  namespace: ai-platform
spec:
  # TODO: Configure deployment
  # - Set replicas
  # - Define container image
  # - Set environment variables
  # - Configure health checks
  # - Set resource limits
  
  # Your code here
```

---

## Exercise 10.3: Prometheus Metrics

**Instructions:** Add Prometheus metrics to the server.

```typescript
// TODO: Add Prometheus metrics
// - Request count by endpoint
# - Request duration
# - Tool call count
# - Error count
# - Active connections

// Your code here
```

---

## Debugging Scenario 10.1: Container Crash

**Scenario:** The container is crashing on startup. The logs show:

```
Error: Cannot find module './dist/index.js'
```

**Questions:**

1. What could cause this error?
   ```
   Your answer:
   ```

2. How would you debug the container?
   ```
   Your answer:
   ```

3. What would you check in the Dockerfile?
   ```
   Your answer:
   ```

---

# SOLUTIONS REFERENCE

## Part 1 Solutions

### Fill-in-the-Blank
1. tools, resources, prompts
2. JSON-RPC
3. Tools
4. Resources
5. client
6. server
7. discovery
8. invocation

### Matching
1. C
2. A
3. B
4. E
5. D

### Quick Check
1. False
2. True
3. True
4. False
5. True

---

## Part 2 Solutions

### Complete Server

**File:** `src/server.ts` (Solution)

```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { createLogger } from './logger.js';
import { promises as fs } from 'fs';
import path from 'path';
import os from 'os';

const logger = createLogger();

export class CalculatorServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    logger.info('Initializing Calculator Server');

    this.server = new McpServer({
      name: process.env.MCP_SERVER_NAME || 'calculator-server',
      version: process.env.MCP_SERVER_VERSION || '1.0.0'
    });

    this.registerTools();
    this.registerResources();
    this.registerPrompts();

    logger.info('Server initialized successfully');
  }

  private registerTools(): void {
    logger.info('Registering tools');

    this.server.tool(
      'add',
      { a: z.number().describe('First number'), b: z.number().describe('Second number') },
      async ({ a, b }) => {
        const result = a + b;
        return {
          content: [{ type: 'text', text: `${a} + ${b} = ${result}` }]
        };
      }
    );

    this.server.tool(
      'subtract',
      { a: z.number().describe('First number'), b: z.number().describe('Second number') },
      async ({ a, b }) => {
        const result = a - b;
        return {
          content: [{ type: 'text', text: `${a} - ${b} = ${result}` }]
        };
      }
    );

    this.server.tool(
      'multiply',
      { a: z.number().describe('First number'), b: z.number().describe('Second number') },
      async ({ a, b }) => {
        const result = a * b;
        return {
          content: [{ type: 'text', text: `${a} × ${b} = ${result}` }]
        };
      }
    );

    this.server.tool(
      'divide',
      { a: z.number().describe('Numerator'), b: z.number().describe('Denominator') },
      async ({ a, b }) => {
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
    );

    this.server.tool(
      'read_file',
      { path: z.string().describe('Path to the file') },
      async ({ path: filePath }) => {
        try {
          const fullPath = path.join(process.cwd(), filePath);
          const normalized = path.normalize(fullPath);
          
          if (!normalized.startsWith(process.cwd())) {
            return {
              content: [{ type: 'text', text: 'Access denied: Path traversal detected' }],
              isError: true
            };
          }
          
          const content = await fs.readFile(normalized, 'utf-8');
          return {
            content: [{ type: 'text', text: content }]
          };
        } catch (error) {
          return {
            content: [{ type: 'text', text: `Error reading file: ${error instanceof Error ? error.message : 'Unknown error'}` }],
            isError: true
          };
        }
      }
    );

    logger.info('All tools registered');
  }

  private registerResources(): void {
    logger.info('Registering resources');

    this.server.resource(
      'system_info',
      'system://info',
      {
        description: 'System information',
        mimeType: 'application/json'
      },
      async () => {
        const systemInfo = {
          hostname: os.hostname(),
          platform: os.platform(),
          arch: os.arch(),
          cpus: os.cpus().length,
          memory: {
            total: os.totalmem(),
            free: os.freemem()
          }
        };
        return {
          contents: [{
            uri: 'system://info',
            text: JSON.stringify(systemInfo, null, 2),
            mimeType: 'application/json'
          }]
        };
      }
    );

    this.server.resource(
      'server_status',
      'server://status',
      {
        description: 'Server status',
        mimeType: 'application/json'
      },
      async () => {
        const status = {
          name: process.env.MCP_SERVER_NAME || 'calculator-server',
          version: process.env.MCP_SERVER_VERSION || '1.0.0',
          status: this.isRunning ? 'running' : 'stopped',
          startTime: new Date().toISOString()
        };
        return {
          contents: [{
            uri: 'server://status',
            text: JSON.stringify(status, null, 2),
            mimeType: 'application/json'
          }]
        };
      }
    );

    logger.info('All resources registered');
  }

  private registerPrompts(): void {
    logger.info('Registering prompts');

    this.server.prompt(
      'welcome',
      { name: z.string().optional().describe('User name') },
      ({ name }) => {
        const userName = name || 'User';
        return {
          messages: [{
            role: 'assistant',
            content: {
              type: 'text',
              text: `Welcome to the MCP Calculator Server, ${userName}! I can help you with arithmetic operations and file operations.`
            }
          }]
        };
      }
    );

    this.server.prompt(
      'help',
      { topic: z.string().optional().describe('Help topic') },
      ({ topic }) => {
        let helpText = 'I can help you with:\n- Arithmetic (add, subtract, multiply, divide)\n- File operations (read_file)\n- System information (resources)';
        if (topic) {
          helpText += `\n\nTopic: ${topic}\nUse the appropriate tool to help with this topic.`;
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
    );

    logger.info('All prompts registered');
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
      console.error('🚀 MCP Calculator Server is running...');
    } catch (error) {
      logger.error('Failed to start server', { error });
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

---

# APPENDIX: ADDITIONAL RESOURCES

## Recommended Reading

1. **MCP Specification** — modelcontextprotocol.io
2. **JSON-RPC 2.0 Specification** — jsonrpc.org
3. **Zod Documentation** — zod.dev
4. **Pino Logging** — getpino.io
5. **Kubernetes Documentation** — kubernetes.io

## Community Resources

1. **MCP Discord** — discord.gg/modelcontextprotocol
2. **MCP GitHub** — github.com/modelcontextprotocol
3. **A2A Community** — a2a-protocol.org/community

## Project Templates

1. **MCP Server Template** — github.com/modelcontextprotocol/server-template
2. **MCP Client Template** — github.com/modelcontextprotocol/client-template
3. **A2A Agent Template** — github.com/a2a-protocol/agent-template

---

**[END OF STUDENT WORKBOOK]**
