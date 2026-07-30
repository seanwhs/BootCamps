# COMPREHENSIVE QUIZ AND TEST BANK
## Mastering AI Integration with MCP and A2A Using JavaScript

# ASSESSMENT GUIDE

## How to Use This Test Bank

This test bank includes questions for all 10 parts of the series. Questions are organized by:

1. **Part** — Which part of the series the question covers
2. **Type** — Multiple Choice, True/False, Fill-in-the-Blank, Short Answer, Code Writing, Scenario-Based
3. **Difficulty** — Basic, Intermediate, Advanced

### Question Types

| Type | Description | Points |
|------|-------------|--------|
| Multiple Choice | Select the best answer | 1 each |
| True/False | Determine if statement is correct | 1 each |
| Fill-in-the-Blank | Complete the sentence | 1 each |
| Short Answer | Write a brief response | 3-5 each |
| Code Writing | Write or complete code | 5-10 each |
| Scenario-Based | Apply knowledge to a scenario | 5-10 each |

### Assessment Options

- **Quick Quiz** — 10 questions (10 minutes)
- **Part Test** — 25 questions (30 minutes)
- **Midterm** — 50 questions (60 minutes)
- **Final Exam** — 100 questions (120 minutes)
- **Practical Exam** — Coding challenges (90 minutes)

---

# PART 1: INTRODUCTION TO MCP

## Multiple Choice Questions

**1.1 What does MCP stand for?**
- A) Model Communication Protocol
- B) Model Context Protocol
- C) Machine Control Protocol
- D) Message Communication Protocol

**Answer: B**

---

**1.2 What is the primary purpose of MCP?**
- A) To train AI models
- B) To standardize how AI applications connect to tools and data
- C) To replace all existing APIs
- D) To create new programming languages

**Answer: B**

---

**1.3 Which of the following is NOT one of the three pillars of MCP?**
- A) Tools
- B) Resources
- C) Prompts
- D) Models

**Answer: D**

---

**1.4 What communication protocol does MCP use?**
- A) HTTP
- B) WebSocket
- C) JSON-RPC
- D) gRPC

**Answer: C**

---

**1.5 In MCP architecture, what is the role of the client?**
- A) To expose tools and resources
- B) To discover capabilities and invoke tools
- C) To store all data
- D) To train AI models

**Answer: B**

---

**1.6 Which of the following is an example of a tool in MCP?**
- A) system://info
- B) welcome_prompt
- C) send_email(to, subject, body)
- D) code_review_template

**Answer: C**

---

**1.7 Which of the following is an example of a resource in MCP?**
- A) add(a, b)
- B) system://info
- C) help_prompt
- D) execute_query

**Answer: B**

---

**1.8 What is the analogy often used to describe MCP?**
- A) A restaurant menu
- B) USB-C for AI applications
- C) A dictionary
- D) A telephone system

**Answer: B**

---

**1.9 What is the purpose of prompts in MCP?**
- A) To execute functions
- B) To store data
- C) To guide AI behavior with reusable templates
- D) To handle authentication

**Answer: C**

---

**1.10 Which of the following is a valid MCP transport mechanism?**
- A) stdio
- B) Bluetooth
- C) USB
- D) HDMI

**Answer: A**

---

## True/False Questions

**1.11 MCP is a proprietary protocol owned by a single company.**

**Answer: False**

---

**1.12 Tools in MCP can have side effects like writing to a database.**

**Answer: True**

---

**1.13 Resources in MCP are executable functions that the AI can call.**

**Answer: False**

---

**1.14 MCP uses JSON-RPC 2.0 for communication.**

**Answer: True**

---

**1.15 Prompts in MCP are reusable templates that guide AI behavior.**

**Answer: True**

---

## Fill-in-the-Blank Questions

**1.16 The three pillars of MCP are ______, ______, and ______.**

**Answer: tools, resources, prompts**

---

**1.17 MCP uses ______ for communication between client and server.**

**Answer: JSON-RPC**

---

**1.18 The MCP client is responsible for discovering ______ and invoking ______.**

**Answer: capabilities, tools**

---

**1.19 The MCP server exposes ______, ______, and ______.**

**Answer: tools, resources, prompts**

---

## Short Answer Questions

**1.20 Explain the difference between a tool and a resource in MCP.**

**Answer:**
- Tools are executable functions that the AI can call (actions)
- Resources are data that the AI can read (information)
- Tools can have side effects, resources are read-only
- Tools use JSON-RPC calls, resources use URIs

---

**1.21 Why is dynamic discovery important in MCP?**

**Answer:**
- Allows AI to understand what capabilities are available
- Eliminates hard-coded integration points
- Enables runtime adaptability
- Makes the system extensible without code changes

---

**1.22 Describe the MCP client-server architecture.**

**Answer:**
- Client: AI application that initiates requests
- Server: Provides capabilities (tools, resources, prompts)
- Communication: JSON-RPC messages
- Transport: stdio, WebSocket, or HTTP
- Discovery: Client asks server what capabilities are available

---

## Scenario-Based Questions

**1.23 Scenario: You're building a customer support AI that needs to access a knowledge base, send emails, and query user data. How would you structure this using MCP?**

**Answer:**
- Create a Knowledge Server with tools for:
  - search_knowledge_base(query) → Tool
  - get_article(id) → Tool
- Create resources for:
  - knowledge://articles → Resource
  - knowledge://categories → Resource
- Create an Email Server with tools for:
  - send_email(to, subject, body) → Tool
- Create a User Data Server with:
  - get_user(id) → Tool
  - user://{id} → Resource
- All servers expose their capabilities via MCP
- The AI client discovers all capabilities dynamically

---

**1.24 Scenario: You need to expose system information to an AI. Should you use a tool or a resource? Why?**

**Answer:**
- Use a resource (system://info)
- Resources are designed for data that the AI needs to read
- System information is read-only data
- Tools are for actions, not data access
- Resources can be cached and discovered via resources/list

---

# PART 2: BUILDING YOUR FIRST MCP SERVER

## Multiple Choice Questions

**2.1 Which package is the official MCP SDK for JavaScript?**
- A) @modelcontextprotocol/sdk
- B) mcp-sdk
- C) model-context-protocol
- D) @mcp/sdk

**Answer: A**

---

**2.2 What is the purpose of Zod in MCP server development?**
- A) To handle HTTP requests
- B) To validate input schemas
- C) To manage database connections
- D) To format JSON responses

**Answer: B**

---

**2.3 Which method is used to register a tool in the MCP server?**
- A) server.addTool()
- B) server.register()
- C) server.tool()
- D) server.createTool()

**Answer: C**

---

**2.4 What transport is most commonly used for local MCP server development?**
- A) WebSocket
- B) HTTP
- C) stdio
- D) UDP

**Answer: C**

---

**2.5 How do you mark a tool response as an error?**
- A) Return an error object
- B) Use isError: true in the response
- C) Throw an exception
- D) Return null

**Answer: B**

---

**2.6 What does the `read_file` tool demonstrate in the first server example?**
- A) Database access
- B) File system operations with security
- C) API integration
- D) Authentication

**Answer: B**

---

**2.7 Which method is used to register a resource in the MCP server?**
- A) server.addResource()
- B) server.resource()
- C) server.registerResource()
- D) server.createResource()

**Answer: B**

---

**2.8 What is the primary purpose of the logger in the MCP server?**
- A) To handle errors
- B) To provide structured logging
- C) To manage configuration
- D) To format responses

**Answer: B**

---

**2.9 How do you prevent path traversal attacks in a file reading tool?**
- A) Use async/await
- B) Normalize and validate paths
- C) Use try/catch
- D) Add rate limiting

**Answer: B**

---

**2.10 What is the shebang line in index.ts used for?**
- A) To specify the runtime
- B) To import modules
- C) To define the entry point
- D) To configure TypeScript

**Answer: A**

---

## True/False Questions

**2.11 TypeScript is optional for MCP server development.**

**Answer: True**

---

**2.12 A tool must always return a successful response.**

**Answer: False**

---

**2.13 Resources in MCP can be accessed via URIs.**

**Answer: True**

---

**2.14 The server.tool() method automatically validates input using Zod schemas.**

**Answer: True**

---

**2.15 stdio transport uses standard input/output for communication.**

**Answer: True**

---

## Fill-in-the-Blank Questions

**2.16 The MCP server is created using the ______ class from the SDK.**

**Answer: McpServer**

---

**2.17 Tools are registered using the ______ method.**

**Answer: server.tool()**

---

**2.18 Resources are registered using the ______ method.**

**Answer: server.resource()**

---

**2.19 The ______ class from Zod is used for input validation.**

**Answer: z**

---

**2.20 The ______ transport is used for local process communication.**

**Answer: stdio**

---

## Code Writing Questions

**2.21 Write the code to register a "greet" tool that takes a name parameter and returns "Hello, {name}!".**

**Answer:**
```typescript
server.tool(
  'greet',
  { name: z.string().describe('The name to greet') },
  async ({ name }) => ({
    content: [{ type: 'text', text: `Hello, ${name}!` }]
  })
);
```

---

**2.22 Write the code to register a resource that returns the current server uptime.**

**Answer:**
```typescript
const startTime = Date.now();

server.resource(
  'uptime',
  'server://uptime',
  {
    description: 'Server uptime',
    mimeType: 'application/json'
  },
  async () => ({
    contents: [{
      uri: 'server://uptime',
      text: JSON.stringify({
        uptime: Date.now() - startTime,
        startTime: new Date(startTime).toISOString()
      }),
      mimeType: 'application/json'
    }]
  })
);
```

---

**2.23 Write the code for the main entry point that creates and starts the server.**

**Answer:**
```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { CalculatorServer } from './server.js';

const main = async () => {
  const server = new CalculatorServer();
  
  process.on('SIGINT', async () => {
    await server.stop();
    process.exit(0);
  });
  
  await server.start();
};

main();
```

---

## Scenario-Based Questions

**2.24 Scenario: Your file reading tool is allowing access to files outside the project directory. How would you fix this?**

**Answer:**
```typescript
const fullPath = path.join(process.cwd(), filePath);
const normalized = path.normalize(fullPath);

if (!normalized.startsWith(process.cwd())) {
  return {
    content: [{ type: 'text', text: 'Access denied: Path traversal detected' }],
    isError: true
  };
}
```

---

**2.25 Scenario: A tool call is failing with "Method not found". What are the possible causes and how would you debug?**

**Answer:**
Possible causes:
- Tool name is misspelled
- Tool wasn't registered before starting the server
- Different tool registration method used

Debugging steps:
1. Check the tool name spelling
2. Verify the tool is registered in the registerTools method
3. Check server logs for registration messages
4. Use tools/list to verify available tools
5. Ensure server.tool() is called before server.connect()

---

# PART 3: UNDERSTANDING JSON-RPC

## Multiple Choice Questions

**3.1 What is the correct structure of a JSON-RPC request?**
- A) `{"jsonrpc":"2.0","method":"tools/list"}`
- B) `{"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}`
- C) `{"id":"1","method":"tools/list"}`
- D) `{"method":"tools/list","params":{}}`

**Answer: B**

---

**3.2 What is the correct structure of a JSON-RPC success response?**
- A) `{"jsonrpc":"2.0","result":{}}`
- B) `{"jsonrpc":"2.0","id":"1","result":{}}`
- C) `{"id":"1","result":{}}`
- D) `{"result":{}}`

**Answer: B**

---

**3.3 What error code indicates "Method Not Found"?**
- A) -32700
- B) -32600
- C) -32601
- D) -32602

**Answer: C**

---

**3.4 What error code indicates "Parse Error"?**
- A) -32700
- B) -32600
- C) -32601
- D) -32602

**Answer: A**

---

**3.5 What is the first method called in the MCP handshake?**
- A) tools/list
- B) resources/list
- C) initialize
- D) ping

**Answer: C**

---

**3.6 Which of the following is a valid JSON-RPC notification?**
- A) `{"jsonrpc":"2.0","id":"1","method":"notify"}`
- B) `{"jsonrpc":"2.0","method":"notify"}`
- C) `{"method":"notify"}`
- D) `{"jsonrpc":"2.0","id":"1","result":{}}`

**Answer: B**

---

**3.7 What does the `id` field in a JSON-RPC request do?**
- A) Identifies the server
- B) Matches requests with responses
- C) Specifies the protocol version
- D) Indicates the method name

**Answer: B**

---

**3.8 Which MCP method is used to execute a tool?**
- A) tools/execute
- B) tools/call
- C) tools/run
- D) tools/invoke

**Answer: B**

---

**3.9 What is the purpose of the `params` field in a JSON-RPC request?**
- A) To specify the method name
- B) To provide the request ID
- C) To pass arguments to the method
- D) To indicate the protocol version

**Answer: C**

---

**3.10 Which of the following is NOT a valid MCP method?**
- A) tools/list
- B) resources/list
- C) prompts/list
- D) models/list

**Answer: D**

---

## True/False Questions

**3.11 JSON-RPC 2.0 is the communication protocol used by MCP.**

**Answer: True**

---

**3.12 Notifications in JSON-RPC require a response.**

**Answer: False**

---

**3.13 The `result` field in a response is always an object.**

**Answer: False**

---

**3.14 Error code -32601 means "Invalid Request".**

**Answer: False** (It means "Method Not Found")

---

**3.15 The initialize method is called for every request.**

**Answer: False**

---

## Fill-in-the-Blank Questions

**3.16 The JSON-RPC protocol version specified in messages is ______.**

**Answer: 2.0**

---

**3.17 The field that matches a request with its response is the ______ field.**

**Answer: id**

---

**3.18 The method to get all available tools is ______.**

**Answer: tools/list**

---

**3.19 The method to execute a tool is ______.**

**Answer: tools/call**

---

**3.20 Error code -32700 means ______.**

**Answer: Parse Error**

---

## Short Answer Questions

**3.21 What is the difference between a JSON-RPC request and a notification?**

**Answer:**
- Request: Includes an `id` field and expects a response
- Notification: No `id` field, doesn't expect a response
- Notifications are used for one-way communication
- Requests are used for request-response patterns

---

**3.22 List the three message types in JSON-RPC and describe their purposes.**

**Answer:**
1. Request: Client asks server to perform an action (expects response)
2. Response: Server replies to a request (success or error)
3. Notification: Client sends one-way message (no response expected)

---

**3.23 Explain the MCP handshake process.**

**Answer:**
1. Client connects to server
2. Client sends initialize request with protocol version
3. Server responds with protocol version and capabilities
4. Client discovers tools (tools/list)
5. Client discovers resources (resources/list)
6. Client discovers prompts (prompts/list)
7. Client is now ready to use the server

---

## Scenario-Based Questions

**3.24 Scenario: You receive this error: `{"jsonrpc":"2.0","id":"1","error":{"code":-32601,"message":"Method not found"}}`. What could cause this and how would you fix it?**

**Answer:**
Causes:
- The requested method doesn't exist on the server
- Typo in method name
- Method not registered

Fixes:
- Check method name spelling
- Verify method is registered in the server
- Use tools/list to see available methods
- Ensure server is properly initialized

---

**3.25 Scenario: You need to send a large amount of data in a JSON-RPC message. What are the considerations and best practices?**

**Answer:**
Considerations:
- JSON serialization overhead
- Network bandwidth
- Memory usage
- Parsing time

Best practices:
- Use pagination for large result sets
- Stream data when possible
- Use compression (gzip)
- Consider alternative formats for very large data
- Set appropriate timeouts

---

# PART 4: SQLITE DATABASE SERVER

## Multiple Choice Questions

**4.1 What is the purpose of connection pooling in a database server?**
- A) To prevent SQL injection
- B) To reuse database connections efficiently
- C) To encrypt data
- D) To handle authentication

**Answer: B**

---

**4.2 Which SQLite pragma is used for write-ahead logging?**
- A) journal_mode
- B) synchronous
- C) foreign_keys
- D) cache_size

**Answer: A**

---

**4.3 What is the recommended journal mode for SQLite production use?**
- A) DELETE
- B) TRUNCATE
- C) WAL
- D) MEMORY

**Answer: C**

---

**4.4 How does parameterized queries prevent SQL injection?**
- A) By encrypting queries
- B) By separating SQL logic from data
- C) By validating all inputs
- D) By using stored procedures

**Answer: B**

---

**4.5 What is the purpose of the `isError` flag in tool responses?**
- A) To indicate authentication failure
- B) To mark a response as an error
- C) To indicate rate limiting
- D) To show connection status

**Answer: B**

---

## True/False Questions

**4.6 SQLite supports connection pooling natively.**

**Answer: False**

---

**4.7 WAL mode improves concurrent read/write performance in SQLite.**

**Answer: True**

---

**4.8 Query blacklisting is the recommended approach for database security.**

**Answer: False** (Whitelisting is more secure)

---

**4.9 Parameterized queries are the best defense against SQL injection.**

**Answer: True**

---

**4.10 SQLite supports foreign key constraints by default.**

**Answer: False** (Must be enabled)

---

## Fill-in-the-Blank Questions

**4.11 The SQLite database server uses ______ to manage database connections.**

**Answer: connection pooling**

---

**4.12 WAL stands for ______.**

**Answer: Write-Ahead Logging**

---

**4.13 The recommended journal mode for SQLite is ______.**

**Answer: WAL**

---

## Scenario-Based Questions

**4.14 Scenario: A user executed `DROP TABLE users` and deleted all data. How would you prevent this?**

**Answer:**
```typescript
private validateQuery(sql: string): void {
  const normalized = sql.toLowerCase();
  const dangerous = ['drop table', 'drop index', 'drop trigger', 'truncate'];
  for (const pattern of dangerous) {
    if (normalized.includes(pattern)) {
      throw new Error(`Dangerous query detected: ${pattern}`);
    }
  }
}
```

---

**4.15 Scenario: Queries are running slowly. What would you check and how would you optimize?**

**Answer:**
Check:
1. Query execution plans
2. Missing indexes
3. Unoptimized queries
4. Connection pool configuration

Optimization:
1. Add appropriate indexes
2. Use EXPLAIN QUERY PLAN
3. Optimize query structure
4. Increase connection pool size
5. Enable WAL mode
6. Use LIMIT for large result sets
7. Implement query caching

---

# PART 5: POSTGRESQL SERVER

## Multiple Choice Questions

**5.1 What PostgreSQL data type is recommended for flexible, schema-less data?**
- A) TEXT
- B) JSONB
- C) VARCHAR
- D) ARRAY

**Answer: B**

---

**5.2 What is the recommended index type for equality queries on high-cardinality columns?**
- A) GIN
- B) GiST
- C) B-tree
- D) BRIN

**Answer: C**

---

**5.3 Which PostgreSQL extension adds vector similarity search capabilities?**
- A) pgvector
- B) postgis
- C) fuzzystrmatch
- D) hstore

**Answer: A**

---

**5.4 What does EXPLAIN ANALYZE show that regular EXPLAIN doesn't?**
- A) The query plan
- B) Estimated costs
- C) Actual execution statistics
- D) Index usage

**Answer: C**

---

**5.5 What is the purpose of the pg_stat_statements extension?**
- A) To create indexes
- B) To track query performance statistics
- C) To manage connections
- D) To encrypt data

**Answer: B**

---

## True/False Questions

**5.6 PostgreSQL supports full-text search natively.**

**Answer: True**

---

**5.7 EXPLAIN ANALYZE can be used in production without performance impact.**

**Answer: False** (It executes the query, can impact performance)

---

**5.8 Connection pooling is recommended for production PostgreSQL applications.**

**Answer: True**

---

**5.9 DDL operations (CREATE, ALTER, DROP) should always be allowed in production.**

**Answer: False**

---

**5.10 Parameterized queries are sufficient to prevent all SQL injection attacks.**

**Answer: True** (When used properly)

---

## Short Answer Questions

**5.11 What are the benefits of PostgreSQL for AI applications compared to other databases?**

**Answer:**
- JSONB for flexible data storage
- Vector embeddings for AI features (pgvector)
- Full-text search
- Rich indexing options
- Extensibility
- ACID compliance
- Advanced analytical functions

---

**5.12 Explain the difference between B-tree, GIN, and GiST indexes.**

**Answer:**
- B-tree: Default index type, good for equality and range queries
- GIN: Good for array and full-text search queries
- GiST: Good for geometric and full-text search, supports custom operators

---

## Scenario-Based Questions

**5.13 Scenario: A query is taking 5 seconds to run. How would you use EXPLAIN to diagnose and fix it?**

**Answer:**
1. Run EXPLAIN ANALYZE on the query
2. Look for:
   - Sequential scans on large tables
   - Missing indexes
   - Expensive joins
   - Large row counts
3. Based on findings:
   - Add indexes on columns in WHERE clauses
   - Create covering indexes
   - Rewrite the query
   - Consider partitioning
4. Re-run EXPLAIN ANALYZE to verify improvement

---

**5.14 Scenario: You need to classify database operations by risk level. How would you implement this?**

**Answer:**
```typescript
type RiskLevel = 'read-only' | 'read-write' | 'admin' | 'critical';

function getRiskLevel(sql: string): RiskLevel {
  const normalized = sql.trim().toLowerCase();
  
  // Read-only
  if (['select', 'show', 'explain'].some(p => normalized.startsWith(p))) {
    return 'read-only';
  }
  
  // Read-write (with WHERE)
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
```

---

# PART 6: KNOWLEDGE SERVER

## Multiple Choice Questions

**6.1 What is the primary purpose of a data source adapter pattern?**
- A) To enhance performance
- B) To abstract different data sources behind a common interface
- C) To handle authentication
- D) To manage caching

**Answer: B**

---

**6.2 When searching across multiple sources, what should you do if one source fails?**
- A) Stop the entire search
- B) Continue with remaining sources and report the failure
- C) Retry indefinitely
- D) Ignore the failure

**Answer: B**

---

**6.3 What is the purpose of the health check in an adapter?**
- A) To monitor performance
- B) To verify the data source is available
- C) To check data quality
- D) To validate queries

**Answer: B**

---

## True/False Questions

**6.4 All adapters must support the same query interface.**

**Answer: True**

---

**6.5 The Knowledge Server should stop all operations if one adapter fails.**

**Answer: False**

---

## Fill-in-the-Blank Questions

**6.6 The pattern used to abstract different data sources is called the ______ pattern.**

**Answer: adapter**

---

## Short Answer Questions

**6.7 What are the benefits of the Knowledge Server architecture?**

**Answer:**
- Single interface for all data sources
- Consistent access patterns
- Extensible with new sources
- Fault tolerance
- Unified search and querying
- Caching and performance optimization
- Standardized error handling

---

**6.8 How would you handle different query capabilities across adapters?**

**Answer:**
- Define a common interface (DataSourceAdapter)
- Each adapter implements required methods
- Adapt query types to native formats
- Use capability checking
- Gracefully handle unsupported queries
- Provide detailed errors for unsupported operations

---

# PART 7: AUTONOMOUS RESEARCH ASSISTANT

## Multiple Choice Questions

**7.1 What is the first step in the agent loop?**
- A) Execute
- B) Plan
- C) Observe
- D) Reflect

**Answer: B**

---

**7.2 What is the purpose of reflection in the agent loop?**
- A) To execute tasks
- B) To evaluate progress and adjust
- C) To gather information
- D) To store memories

**Answer: B**

---

**7.3 In the memory system, which type moves from short-term to long-term memory?**
- A) All memories
- B) Only high-importance memories
- C) Only recent memories
- D) Only observation memories

**Answer: B**

---

**7.4 What is the purpose of the planner in an autonomous agent?**
- A) To execute tasks
- B) To break down goals into steps
- C) To store memories
- D) To reflect on progress

**Answer: B**

---

## True/False Questions

**7.5 An autonomous agent always completes its task on the first attempt.**

**Answer: False**

---

**7.6 Reflection helps the agent improve its performance over time.**

**Answer: True**

---

## Fill-in-the-Blank Questions

**7.7 The four steps of the agent loop are ______, ______, ______, and ______.**

**Answer: plan, execute, observe, reflect**

---

**7.8 In the memory system, ______ memories are stored long-term while ______ memories are short-term.**

**Answer: high-importance, recent**

---

## Short Answer Questions

**7.9 Describe the agent loop and its purpose.**

**Answer:**
- Plan: Break down the goal into steps
- Execute: Perform each step using tools
- Observe: Collect and analyze results
- Reflect: Evaluate progress and adjust
- Purpose: Enables autonomous operation and continuous improvement

---

**7.10 How does the memory system help the agent make better decisions?**

**Answer:**
- Stores past learnings and experiences
- Provides context for current decisions
- Enables pattern recognition
- Prevents repeating mistakes
- Builds knowledge over time
- Helps prioritize actions

---

## Scenario-Based Questions

**7.11 Scenario: Your agent is stuck in a loop, repeating the same actions. How would you diagnose and fix this?**

**Answer:**
Diagnosis:
1. Check if the plan is being updated
2. Verify reflection is working
3. Check for missing dependencies
4. Look for incomplete error handling

Fix:
1. Add max iteration limit
2. Implement plan adaptation
3. Add step completion detection
4. Add progress tracking
5. Implement early exit conditions
6. Add logging for debugging

---

# PART 8: A2A COLLABORATION

## Multiple Choice Questions

**8.1 What is the primary purpose of the A2A protocol?**
- A) To connect AI to tools
- B) To enable AI agents to communicate
- C) To handle authentication
- D) To manage data storage

**Answer: B**

---

**8.2 Which component handles agent discovery in A2A?**
- A) Message Router
- B) Agent Registry
- C) Message Queue
- D) Workflow Manager

**Answer: B**

---

**8.3 What is the role of the Coordinator Agent?**
- A) To write code
- B) To orchestrate workflows and delegate tasks
- C) To manage databases
- D) To handle authentication

**Answer: B**

---

**8.4 Which A2A message type is used for task assignment?**
- A) Request
- B) Response
- C) Delegation
- D) Notification

**Answer: C**

---

## True/False Questions

**8.5 A2A agents must always be connected to the same server.**

**Answer: False**

---

**8.6 A2A supports both synchronous and asynchronous communication.**

**Answer: True**

---

## Fill-in-the-Blank Questions

**8.7 The ______ handles routing of messages between agents.**

**Answer: Message Router**

---

**8.8 The ______ agent is responsible for orchestrating workflows.**

**Answer: Coordinator**

---

## Short Answer Questions

**8.9 Explain the difference between MCP and A2A.**

**Answer:**
- MCP: Connects AI to tools and data (AI ↔ External Systems)
- A2A: Connects AI agents to each other (Agent ↔ Agent)
- MCP: Client-server architecture
- A2A: Peer-to-peer architecture
- MCP: Tools, resources, prompts
- A2A: Messages, delegation, workflows

---

**8.10 Describe the delegation flow in A2A.**

**Answer:**
1. Coordinator receives task
2. Coordinator queries registry for suitable agent
3. Coordinator sends delegation message to agent
4. Agent processes the task
5. Agent returns result to coordinator
6. Coordinator returns final result to requester

---

## Scenario-Based Questions

**8.11 Scenario: A delegate agent fails to complete a task. How should the system handle this?**

**Answer:**
1. Detect failure (timeout or error response)
2. Log the failure for debugging
3. Try fallback agent if available
4. Notify coordinator of failure
5. Report to human if critical
6. Implement retry with backoff
7. Update agent status in registry

---

**8.12 Scenario: Two agents are competing for the same resource. How would you prevent conflicts?**

**Answer:**
1. Implement resource locking
2. Use a shared memory system
3. Implement priority queues
4. Use coordinator for resource allocation
5. Implement retry with backoff
6. Add conflict detection
7. Use versioning for shared state

---

# PART 9: ADVANCED MULTI-AGENT

## Multiple Choice Questions

**9.1 What is the benefit of hierarchical agent architecture?**
- A) Simpler communication
- B) Clear chain of command and scalability
- C) Faster execution
- D) Less code

**Answer: B**

---

**9.2 In a hierarchical architecture, which agent assigns tasks to workers?**
- A) Coordinator
- B) Supervisor
- C) Worker
- D) Registry

**Answer: B**

---

**9.3 What is shared memory used for in multi-agent systems?**
- A) Storing individual agent data
- B) Cross-agent context sharing
- C) Authentication
- D) Performance monitoring

**Answer: B**

---

**9.4 What is the role of a human-in-the-loop in multi-agent systems?**
- A) To write code
- B) To approve critical decisions
- C) To deploy the system
- D) To train the agents

**Answer: B**

---

## True/False Questions

**9.5 Shared memory can be used to store code artifacts.**

**Answer: True**

---

**9.6 Human-in-the-loop slows down the system unnecessarily.**

**Answer: False**

---

## Fill-in-the-Blank Questions

**9.7 In a hierarchical architecture, the ______ agent manages workers and the ______ agent orchestrates overall workflow.**

**Answer: supervisor, coordinator**

---

**9.8 Shared memory entries include a ______ field to track who created them.**

**Answer: createdBy**

---

## Short Answer Questions

**9.9 Describe the Coordinator-Supervisor-Worker pattern.**

**Answer:**
- Coordinator: Receives overall goal, creates high-level plan
- Supervisor: Breaks down plan into tasks, assigns to workers
- Workers: Execute individual tasks, report results
- Benefits: Separation of concerns, scalability, clear responsibility

---

**9.10 What are the benefits of shared memory in multi-agent systems?**

**Answer:**
- Cross-agent context sharing
- Versioned state management
- Artifact storage and retrieval
- Decision tracking
- Distributed reasoning
- Reduced duplication
- Historical context

---

# PART 10: PRODUCTION ENGINEERING

## Multiple Choice Questions

**10.1 What is the main advantage of multi-stage Docker builds?**
- A) Faster execution
- B) Smaller production images
- C) Simpler configuration
- D) Better logging

**Answer: B**

---

**10.2 Which Kubernetes resource automatically scales pods based on metrics?**
- A) Deployment
- B) Service
- C) Ingress
- D) HorizontalPodAutoscaler

**Answer: D**

---

**10.3 What is the purpose of Prometheus in production monitoring?**
- A) To collect logs
- B) To collect metrics
- C) To display dashboards
- D) To manage secrets

**Answer: B**

---

**10.4 Which tool is commonly used for centralized logging?**
- A) Prometheus
- B) Grafana
- C) ELK Stack
- D) Kubernetes

**Answer: C**

---

## True/False Questions

**10.5 Running containers as a non-root user improves security.**

**Answer: True**

---

**10.6 Health checks are optional in production deployments.**

**Answer: False**

---

## Fill-in-the-Blank Questions

**10.7 The ______ command is used to build a Docker image.**

**Answer: docker build**

---

**10.8 ______ is used for metric collection and ______ is used for dashboards.**

**Answer: Prometheus, Grafana**

---

## Short Answer Questions

**10.9 What are the key components of a production AI deployment?**

**Answer:**
- Containerization (Docker)
- Orchestration (Kubernetes)
- Load balancing
- Monitoring (Prometheus, Grafana)
- Logging (ELK Stack)
- CI/CD pipeline
- Security (Secrets management, RBAC)
- Auto-scaling (HPA)
- Health checks
- Backup and recovery

---

**10.10 Describe a typical CI/CD pipeline for AI applications.**

**Answer:**
1. Code commit triggers pipeline
2. Lint and type check
3. Run unit tests
4. Build Docker image
5. Push to registry
6. Deploy to staging
7. Run integration tests
8. Deploy to production
9. Run health checks
10. Monitor for issues

---

# FINAL EXAM

## Multiple Choice (30 questions)

**1. What does MCP stand for?**
- A) Model Communication Protocol
- B) Model Context Protocol
- C) Machine Control Protocol
- D) Message Communication Protocol

**Answer: B**

---

**2. Which of the following is NOT a pillar of MCP?**
- A) Tools
- B) Resources
- C) Prompts
- D) Databases

**Answer: D**

---

**3. What communication protocol does MCP use?**
- A) HTTP
- B) WebSocket
- C) JSON-RPC
- D) gRPC

**Answer: C**

---

**4. Which method is used to register a tool in MCP?**
- A) server.addTool()
- B) server.register()
- C) server.tool()
- D) server.createTool()

**Answer: C**

---

**5. How do you mark a tool response as an error?**
- A) Return an error object
- B) Use isError: true
- C) Throw an exception
- D) Return null

**Answer: B**

---

**6. What is the correct JSON-RPC request structure?**
- A) `{"jsonrpc":"2.0","method":"tools/list"}`
- B) `{"jsonrpc":"2.0","id":"1","method":"tools/list","params":{}}`
- C) `{"id":"1","method":"tools/list"}`
- D) `{"method":"tools/list","params":{}}`

**Answer: B**

---

**7. What does error code -32601 mean?**
- A) Parse Error
- B) Invalid Request
- C) Method Not Found
- D) Internal Error

**Answer: C**

---

**8. What is the first method called in the MCP handshake?**
- A) tools/list
- B) resources/list
- C) initialize
- D) ping

**Answer: C**

---

**9. What is the recommended SQLite journal mode for production?**
- A) DELETE
- B) TRUNCATE
- C) WAL
- D) MEMORY

**Answer: C**

---

**10. How do parameterized queries prevent SQL injection?**
- A) By encrypting queries
- B) By separating SQL logic from data
- C) By validating inputs
- D) By using stored procedures

**Answer: B**

---

**11. What PostgreSQL extension adds vector similarity search?**
- A) pgvector
- B) postgis
- C) fuzzystrmatch
- D) hstore

**Answer: A**

---

**12. What does EXPLAIN ANALYZE show that regular EXPLAIN doesn't?**
- A) The query plan
- B) Estimated costs
- C) Actual execution statistics
- D) Index usage

**Answer: C**

---

**13. What is the purpose of a data source adapter?**
- A) To enhance performance
- B) To abstract different data sources
- C) To handle authentication
- D) To manage caching

**Answer: B**

---

**14. What is the first step in the agent loop?**
- A) Execute
- B) Plan
- C) Observe
- D) Reflect

**Answer: B**

---

**15. In the memory system, what moves from short-term to long-term memory?**
- A) All memories
- B) High-importance memories
- C) Recent memories
- D) Observation memories

**Answer: B**

---

**16. What is the purpose of A2A protocol?**
- A) Connect AI to tools
- B) Enable AI agents to communicate
- C) Handle authentication
- D) Manage data storage

**Answer: B**

---

**17. Which component handles agent discovery in A2A?**
- A) Message Router
- B) Agent Registry
- C) Message Queue
- D) Workflow Manager

**Answer: B**

---

**18. What is the role of the Coordinator Agent?**
- A) To write code
- B) To orchestrate workflows
- C) To manage databases
- D) To handle authentication

**Answer: B**

---

**19. In a hierarchical architecture, which agent assigns tasks?**
- A) Coordinator
- B) Supervisor
- C) Worker
- D) Registry

**Answer: B**

---

**20. What is shared memory used for?**
- A) Storing individual agent data
- B) Cross-agent context sharing
- C) Authentication
- D) Performance monitoring

**Answer: B**

---

**21. What is the advantage of multi-stage Docker builds?**
- A) Faster execution
- B) Smaller production images
- C) Simpler configuration
- D) Better logging

**Answer: B**

---

**22. Which Kubernetes resource auto-scales pods?**
- A) Deployment
- B) Service
- C) Ingress
- D) HorizontalPodAutoscaler

**Answer: D**

---

**23. What is the purpose of Prometheus?**
- A) To collect logs
- B) To collect metrics
- C) To display dashboards
- D) To manage secrets

**Answer: B**

---

**24. Which tool is used for centralized logging?**
- A) Prometheus
- B) Grafana
- C) ELK Stack
- D) Kubernetes

**Answer: C**

---

**25. Running containers as a non-root user improves what?**
- A) Performance
- B) Security
- C) Speed
- D) Reliability

**Answer: B**

---

**26. What is the recommended approach for database security?**
- A) Blacklisting
- B) Whitelisting
- C) Both
- D) Neither

**Answer: B**

---

**27. What is the purpose of the health check?**
- A) Monitor performance
- B) Verify service availability
- C) Check data quality
- D) Validate queries

**Answer: B**

---

**28. What is the role of the Message Router?**
- A) Store messages
- B) Route messages between agents
- C) Validate messages
- D) Encrypt messages

**Answer: B**

---

**29. What is the purpose of reflection in the agent loop?**
- A) Execute tasks
- B) Evaluate progress and adjust
- C) Gather information
- D) Store memories

**Answer: B**

---

**30. What is the human-in-the-loop used for?**
- A) Writing code
- B) Approving critical decisions
- C) Deploying the system
- D) Training the agents

**Answer: B**

---

## Short Answer (10 questions)

**31. Explain the difference between Tools, Resources, and Prompts in MCP.**

**Answer:**
- Tools: Executable functions the AI can call (actions)
- Resources: Data the AI can read (information)
- Prompts: Templates that guide AI behavior (guidance)

---

**32. Describe the MCP handshake process.**

**Answer:**
1. Client connects to server
2. initialize request with protocol version
3. Server responds with capabilities
4. Client discovers tools (tools/list)
5. Client discovers resources (resources/list)
6. Client discovers prompts (prompts/list)

---

**33. How would you secure a SQLite MCP server?**

**Answer:**
1. Use parameterized queries
2. Implement query validation (whitelist)
3. Prevent DDL operations
4. Use read-only mode when possible
5. Implement connection pooling
6. Set query timeouts
7. Regular backups
8. Input validation with Zod

---

**34. Explain how you would implement a search across multiple data sources.**

**Answer:**
1. Define a common adapter interface
2. Implement adapters for each source
3. Query all adapters in parallel
4. Aggregate results
5. Handle failures gracefully
6. Return unified results

---

**35. Describe the autonomous agent loop.**

**Answer:**
1. Plan: Break down goal into steps
2. Execute: Perform steps using tools
3. Observe: Collect and analyze results
4. Reflect: Evaluate progress and adjust
5. Repeat until goal achieved

---

**36. Explain the A2A delegation flow.**

**Answer:**
1. Coordinator receives task
2. Finds best agent via registry
3. Sends delegation message
4. Agent processes task
5. Agent returns result
6. Coordinator returns final result

---

**37. Describe the benefits of hierarchical multi-agent architecture.**

**Answer:**
- Clear chain of command
- Scalable architecture
- Specialization at each level
- Efficient delegation
- Centralized monitoring
- Easy to add new agents

---

**38. What are the key components of a production AI deployment?**

**Answer:**
- Containerization (Docker)
- Orchestration (Kubernetes)
- Monitoring (Prometheus, Grafana)
- Logging (ELK Stack)
- CI/CD pipeline
- Security (Secrets management)
- Auto-scaling
- Health checks

---

**39. Explain how you would implement human-in-the-loop in an agent system.**

**Answer:**
1. Define approval points
2. Create approval requests
3. Notify human via external channels
4. Implement approval timeout
5. Handle approval/rejection
6. Audit all decisions
7. Provide clear context for decisions

---

**40. How would you handle a failed adapter in the Knowledge Server?**

**Answer:**
1. Catch the failure
2. Log the error
3. Continue with remaining adapters
4. Report the failure in results
5. Implement retry with backoff
6. Update health status
7. Alert if critical

---

# ANSWER KEY SUMMARY

## Part 1: Introduction to MCP
| Q# | Answer | Type |
|----|--------|------|
| 1.1 | B | MC |
| 1.2 | B | MC |
| 1.3 | D | MC |
| 1.4 | C | MC |
| 1.5 | B | MC |
| 1.6 | C | MC |
| 1.7 | B | MC |
| 1.8 | B | MC |
| 1.9 | C | MC |
| 1.10 | A | MC |
| 1.11 | False | TF |
| 1.12 | True | TF |
| 1.13 | False | TF |
| 1.14 | True | TF |
| 1.15 | True | TF |

## Part 2: Building Your First MCP Server
| Q# | Answer | Type |
|----|--------|------|
| 2.1 | A | MC |
| 2.2 | B | MC |
| 2.3 | C | MC |
| 2.4 | C | MC |
| 2.5 | B | MC |
| 2.6 | B | MC |
| 2.7 | B | MC |
| 2.8 | B | MC |
| 2.9 | B | MC |
| 2.10 | A | MC |
| 2.11 | True | TF |
| 2.12 | False | TF |
| 2.13 | True | TF |
| 2.14 | True | TF |
| 2.15 | True | TF |

## Part 3: Understanding JSON-RPC
| Q# | Answer | Type |
|----|--------|------|
| 3.1 | B | MC |
| 3.2 | B | MC |
| 3.3 | C | MC |
| 3.4 | A | MC |
| 3.5 | C | MC |
| 3.6 | B | MC |
| 3.7 | B | MC |
| 3.8 | B | MC |
| 3.9 | C | MC |
| 3.10 | D | MC |
| 3.11 | True | TF |
| 3.12 | False | TF |
| 3.13 | False | TF |
| 3.14 | False | TF |
| 3.15 | False | TF |

## Part 4: SQLite Database Server
| Q# | Answer | Type |
|----|--------|------|
| 4.1 | B | MC |
| 4.2 | A | MC |
| 4.3 | C | MC |
| 4.4 | B | MC |
| 4.5 | B | MC |
| 4.6 | False | TF |
| 4.7 | True | TF |
| 4.8 | False | TF |
| 4.9 | True | TF |
| 4.10 | False | TF |

## Part 5: PostgreSQL Server
| Q# | Answer | Type |
|----|--------|------|
| 5.1 | B | MC |
| 5.2 | C | MC |
| 5.3 | A | MC |
| 5.4 | C | MC |
| 5.5 | B | MC |
| 5.6 | True | TF |
| 5.7 | False | TF |
| 5.8 | True | TF |
| 5.9 | False | TF |
| 5.10 | True | TF |

## Part 6: Knowledge Server
| Q# | Answer | Type |
|----|--------|------|
| 6.1 | B | MC |
| 6.2 | B | MC |
| 6.3 | B | MC |
| 6.4 | True | TF |
| 6.5 | False | TF |

## Part 7: Autonomous Research Assistant
| Q# | Answer | Type |
|----|--------|------|
| 7.1 | B | MC |
| 7.2 | B | MC |
| 7.3 | B | MC |
| 7.4 | B | MC |
| 7.5 | False | TF |
| 7.6 | True | TF |

## Part 8: A2A Collaboration
| Q# | Answer | Type |
|----|--------|------|
| 8.1 | B | MC |
| 8.2 | B | MC |
| 8.3 | B | MC |
| 8.4 | C | MC |
| 8.5 | False | TF |
| 8.6 | True | TF |

## Part 9: Advanced Multi-Agent
| Q# | Answer | Type |
|----|--------|------|
| 9.1 | B | MC |
| 9.2 | B | MC |
| 9.3 | B | MC |
| 9.4 | B | MC |
| 9.5 | True | TF |
| 9.6 | False | TF |

## Part 10: Production Engineering
| Q# | Answer | Type |
|----|--------|------|
| 10.1 | B | MC |
| 10.2 | D | MC |
| 10.3 | B | MC |
| 10.4 | C | MC |
| 10.5 | True | TF |
| 10.6 | False | TF |

---

**[END OF QUIZ AND TEST BANK]**
