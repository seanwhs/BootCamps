# STUDENT NOTES
## Mastering AI Integration with MCP and A2A Using JavaScript

# NOTE-TAKING GUIDE

## How to Use These Notes

These notes are designed to accompany the tutorial series. Use them to:

1. **Take structured notes** during each session
2. **Record code snippets** and key concepts
3. **Track questions** for later discussion
4. **Document errors** and solutions
5. **Create personal reference** for future projects

### Note-Taking Template

Each section includes:
- **Key Concepts** — Main ideas to remember
- **Code Snippets** — Important implementations
- **My Notes** — Space for personal notes
- **Questions** — Space for questions
- **Action Items** — Tasks to complete

---

# PART 1: INTRODUCTION TO MCP

## 1.1 Key Concepts

### What is MCP?
```
MCP = Model Context Protocol
- Open protocol for AI-to-tool connections
- Standardizes how AI discovers and uses tools
- Like "USB-C for AI applications"
```

### The Problem MCP Solves
```
Before MCP:
- Every integration was custom code
- No standardization
- Hard to add new tools

With MCP:
- Standardized protocol
- Any tool can be integrated
- Easy to add new capabilities
```

### The Three Pillars of MCP
```
1. TOOLS: Actions AI can perform
   - Executable functions
   - Have input schema
   - Can have side effects

2. RESOURCES: Data AI can read
   - URI-based identification
   - Read-only access
   - Can be text or binary

3. PROMPTS: Templates guiding AI
   - Reusable templates
   - Variables for customization
   - Guide AI behavior
```

### MCP Architecture
```
Client-Server Model:
┌─────────────────────────────────────────┐
│           AI Application                │
│  ┌───────────────────────────────────┐ │
│  │          MCP Client               │ │
│  │  - Discovers capabilities         │ │
│  │  - Invokes tools                  │ │
│  │  - Reads resources                │ │
│  └───────────────┬───────────────────┘ │
│                  │                      │
│                  ▼                      │
│  ┌───────────────────────────────────┐ │
│  │    JSON-RPC Messages              │ │
│  └───────────────┬───────────────────┘ │
│                  │                      │
│                  ▼                      │
│  ┌───────────────────────────────────┐ │
│  │          MCP Server               │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────┐ │ │
│  │  │  Tools  │ │Resources│ │Prompts│ │ │
│  │  └─────────┘ └─────────┘ └─────┘ │ │
│  └───────────────┬───────────────────┘ │
│                  │                      │
│                  ▼                      │
│  ┌───────────────────────────────────┐ │
│  │       External Systems            │ │
│  │  APIs, Databases, Files, Services │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### JSON-RPC Communication
```
MCP uses JSON-RPC 2.0 for communication.

Request Format:
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "method": "tools/call",
  "params": { ... }
}

Response Format:
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "result": { ... }
}

Error Format:
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "error": {
    "code": -32601,
    "message": "Method not found"
  }
}
```

### Transport Mechanisms
```
1. stdio Transport
   - Local process execution
   - Client spawns server process
   - Communication via stdin/stdout

2. WebSocket Transport
   - Real-time web applications
   - Persistent bidirectional connection
   - Low latency

3. HTTP Transport
   - Production APIs
   - Stateless operations
   - REST-style requests
```

---

## 1.2 My Notes

### What I Learned
```
1. 
2. 
3. 
4. 
5. 
```

### Key Insights
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

### Action Items
```
1. Set up Node.js 20+
2. Install npm 9+
3. Create project directory
4. 
5. 
```

---

# PART 2: BUILDING YOUR FIRST MCP SERVER

## 2.1 Key Concepts

### Project Setup
```
Directory Structure:
mcp-first-server/
├── src/
│   ├── index.ts      # Entry point
│   ├── server.ts     # Server implementation
│   ├── logger.ts     # Logging utility
│   ├── tools.ts      # Tool definitions
│   ├── resources.ts  # Resource definitions
│   └── prompts.ts    # Prompt definitions
├── package.json
├── tsconfig.json
└── .env.example
```

### Dependencies
```json
{
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/node": "^20.10.5",
    "tsx": "^4.6.0"
  }
}
```

### Tool Definition Template
```typescript
const tool = {
  name: 'tool_name',
  description: 'What the tool does',
  schema: {
    param1: z.string().describe('Parameter description'),
    param2: z.number().describe('Parameter description')
  },
  handler: async ({ param1, param2 }) => {
    // Implementation
    return {
      content: [
        { type: 'text', text: 'Result text' }
      ]
    };
  }
};
```

### Resource Definition Template
```typescript
const resource = {
  uri: 'scheme://path',
  name: 'resource_name',
  description: 'What the resource provides',
  mimeType: 'application/json',
  handler: async () => {
    const data = { /* ... */ };
    return {
      contents: [{
        uri: 'scheme://path',
        text: JSON.stringify(data, null, 2),
        mimeType: 'application/json'
      }]
    };
  }
};
```

### Prompt Definition Template
```typescript
const prompt = {
  name: 'prompt_name',
  description: 'What the prompt does',
  schema: {
    param: z.string().optional()
  },
  handler: ({ param }) => {
    return {
      messages: [{
        role: 'assistant',
        content: {
          type: 'text',
          text: `Prompt text with ${param}`
        }
      }]
    };
  }
};
```

### Server Class Template
```typescript
export class MyServer {
  private server: McpServer;
  private isRunning: boolean = false;

  constructor() {
    this.server = new McpServer({
      name: process.env.SERVER_NAME || 'my-server',
      version: process.env.SERVER_VERSION || '1.0.0'
    });
    this.registerTools();
    this.registerResources();
    this.registerPrompts();
  }

  private registerTools(): void {
    // Register tools here
  }

  private registerResources(): void {
    // Register resources here
  }

  private registerPrompts(): void {
    // Register prompts here
  }

  async start(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    this.isRunning = true;
  }

  async stop(): Promise<void> {
    this.isRunning = false;
  }
}
```

### Entry Point Template
```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { MyServer } from './server.js';

const main = async () => {
  const server = new MyServer();
  
  process.on('SIGINT', async () => {
    await server.stop();
    process.exit(0);
  });
  
  await server.start();
};

main();
```

### Security: Path Traversal Prevention
```typescript
// Always prevent path traversal
const fullPath = path.join(process.cwd(), filePath);
const normalized = path.normalize(fullPath);

if (!normalized.startsWith(process.cwd())) {
  return {
    content: [{ type: 'text', text: 'Access denied' }],
    isError: true
  };
}
```

---

## 2.2 My Notes

### Tools I Built
```
1. 
2. 
3. 
```

### Resources I Built
```
1. 
2. 
3. 
```

### Prompts I Built
```
1. 
2. 
```

### Code Snippets to Remember
```
1. 
2. 
3. 
```

### Errors Encountered
```
1. Error: 
   Solution: 
   
2. Error: 
   Solution: 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 3: UNDERSTANDING JSON-RPC

## 3.1 Key Concepts

### JSON-RPC Message Structure
```
Request:
{
  "jsonrpc": "2.0",    // Required: Protocol version
  "id": "req-123",     // Required: Request ID for responses
  "method": "tools/list", // Required: Method name
  "params": {}          // Optional: Parameters
}

Success Response:
{
  "jsonrpc": "2.0",    // Required: Protocol version
  "id": "req-123",     // Required: Matching request ID
  "result": { ... }    // Required: Result object
}

Error Response:
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "error": {
    "code": -32601,    // Required: Error code
    "message": "...",  // Required: Error message
    "data": { ... }    // Optional: Additional data
  }
}
```

### Common MCP Methods
```
Discovery Methods:
- tools/list      → Get all tools
- resources/list  → Get all resources
- prompts/list    → Get all prompts

Invocation Methods:
- tools/call      → Execute a tool
- resources/read  → Read a resource
- prompts/get     → Get a prompt

Lifecycle Methods:
- initialize      → Handshake
- shutdown        → Graceful shutdown
- ping            → Keep-alive
```

### Error Codes
```
JSON-RPC Errors:
-32700  Parse Error
-32600  Invalid Request
-32601  Method Not Found
-32602  Invalid Params
-32603  Internal Error

MCP Errors:
-32001  Tool Not Found
-32002  Resource Not Found
-32003  Prompt Not Found
-32004  Tool Execution Error
-32005  Resource Read Error
-32008  Connection Error
-32009  Authentication Error
-32010  Authorization Error
```

### The Handshake Flow
```
1. Client → Server: initialize
   {
     "protocolVersion": "2024-11-05",
     "clientInfo": { "name": "...", "version": "..." }
   }

2. Server → Client: initialize response
   {
     "protocolVersion": "2024-11-05",
     "serverInfo": { "name": "...", "version": "..." },
     "capabilities": { "tools": {}, "resources": {}, "prompts": {} }
   }

3. Client → Server: tools/list
   {}

4. Server → Client: tools/list response
   { "tools": [...] }

5. Client → Server: resources/list
   {}

6. Server → Client: resources/list response
   { "resources": [...] }

7. Client → Server: prompts/list
   {}

8. Server → Client: prompts/list response
   { "prompts": [...] }
```

### Debugging with pino-pretty
```bash
# Run server with debug logging
LOG_LEVEL=debug npm start

# Output will show:
# - All requests received
# - All responses sent
# - Execution time
# - Error details
```

---

## 3.2 My Notes

### Message Formats to Remember
```
Request:
{
  "jsonrpc": "2.0",
  "id": "___",
  "method": "___",
  "params": {}
}

Response:
{
  "jsonrpc": "2.0",
  "id": "___",
  "result": {}
}

Error:
{
  "jsonrpc": "2.0",
  "id": "___",
  "error": {
    "code": ___,
    "message": "___"
  }
}
```

### Common Methods Reference
```
tools/list → Get all tools
tools/call → Execute a tool
resources/list → Get all resources
resources/read → Read a resource
prompts/list → Get all prompts
prompts/get → Get a prompt
initialize → Handshake
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 4: SQLITE DATABASE SERVER

## 4.1 Key Concepts

### Database Server Architecture
```
┌─────────────────────────────────────────────┐
│         MCP Database Server                 │
├─────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   Tools  │  │ Resources│  │  Prompts  │ │
│  └──────────┘  └──────────┘  └──────────┘ │
├─────────────────────────────────────────────┤
│         Connection Manager                  │
│     - Connection Pool                       │
│     - Query Execution                       │
│     - Timeout Protection                    │
│     - Automatic Backups                     │
├─────────────────────────────────────────────┤
│           SQLite Database                   │
└─────────────────────────────────────────────┘
```

### Connection Manager
```typescript
class ConnectionManager {
  private pool: ConnectionEntry[];
  private config: DBConfig;

  async executeQuery(sql: string, params: any[]): Promise<QueryResult> {
    // 1. Validate query
    this.validateQuery(sql);
    
    // 2. Get connection from pool
    const conn = await this.getConnection();
    
    try {
      // 3. Execute with timeout
      return await this.executeWithTimeout(conn, sql, params);
    } finally {
      // 4. Release connection
      this.releaseConnection(conn);
    }
  }

  private validateQuery(sql: string): void {
    // Prevent dangerous queries
    // - DROP TABLE
    // - TRUNCATE
    // - DELETE without WHERE
    // - UPDATE without WHERE
  }
}
```

### Security: Query Validation
```typescript
// Implement query blacklist
const blacklist = [
  'drop table',
  'drop index',
  'drop trigger',
  'drop view',
  'truncate table',
  'delete from',
  'update'
];

// Check each pattern
const normalized = sql.toLowerCase();
for (const pattern of blacklist) {
  if (normalized.includes(pattern)) {
    throw new Error(`Dangerous query detected: ${pattern}`);
  }
}
```

### Database Tools
```typescript
// 1. execute_query - Execute SQL queries
{
  name: 'execute_query',
  description: 'Execute a SQL query',
  inputSchema: {
    sql: { type: 'string' },
    params: { type: 'array' },
    limit: { type: 'integer' }
  }
}

// 2. get_schema - Get database schema
{
  name: 'get_schema',
  description: 'Get database schema',
  inputSchema: {
    table: { type: 'string' },
    includeData: { type: 'boolean' }
  }
}

// 3. create_table - Create new table
{
  name: 'create_table',
  description: 'Create a new table',
  inputSchema: {
    tableName: { type: 'string' },
    columns: { type: 'array' }
  }
}
```

### Database Resources
```typescript
// Table data resource
{
  uri: 'table://{tableName}',
  description: 'Table data',
  mimeType: 'application/json',
  handler: async (uri) => {
    const tableName = uri.replace('table://', '');
    const result = await db.executeQuery(`SELECT * FROM ${tableName} LIMIT 1000`);
    return { contents: [{ text: JSON.stringify(result) }] };
  }
}

// Schema resource
{
  uri: 'schema://info',
  description: 'Database schema',
  mimeType: 'application/json',
  handler: async () => {
    const schema = await db.getSchema();
    return { contents: [{ text: JSON.stringify(schema) }] };
  }
}
```

---

## 4.2 My Notes

### Configuration
```
DB_PATH: 
DB_READ_ONLY: 
DB_MAX_CONNECTIONS: 
DB_QUERY_TIMEOUT: 
```

### Tables I Created
```
1. 
2. 
3. 
```

### Queries I Tested
```
1. 
2. 
3. 
```

### Security Measures
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 5: POSTGRESQL SERVER

## 5.1 Key Concepts

### PostgreSQL Features for AI
```
1. Rich Data Types
   - JSON/JSONB for flexible data
   - Arrays for lists
   - Full-text search
   - Vector embeddings (pgvector)

2. Advanced Indexing
   - B-tree, Hash, GiST, GIN, BRIN

3. Extensibility
   - Custom functions
   - User-defined types
   - Extensions
```

### Connection Pool Configuration
```typescript
const poolConfig = {
  host: process.env.POSTGRES_HOST,
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DATABASE,
  max: 20,              // Maximum connections
  idleTimeoutMillis: 30000,  // Idle timeout
  connectionTimeoutMillis: 2000,  // Connection timeout
  maxUses: 7500,        // Max uses per connection
  keepAlive: true       // Keep connections alive
};
```

### Query Risk Classification
```
Risk Levels:
┌─────────────────────────────────────────────┐
│  read-only   │ SELECT, SHOW, EXPLAIN       │
│              │ Auto-approved                │
├─────────────────────────────────────────────┤
│  read-write  │ INSERT, UPDATE, DELETE      │
│              │ Requires confirmation        │
├─────────────────────────────────────────────┤
│  admin       │ CREATE, ALTER, DROP         │
│              │ Requires elevated permission │
├─────────────────────────────────────────────┤
│  critical    │ DELETE without WHERE        │
│              │ DROP TABLE                   │
└─────────────────────────────────────────────┘
```

### Read/Write Query Separation
```typescript
// Read-only queries (auto-approved)
async readQuery(sql: string, params: any[]) {
  // Only allows SELECT, WITH, SHOW, EXPLAIN
  const normalized = sql.trim().toLowerCase();
  const allowed = ['select', 'with', 'show', 'explain'];
  if (!allowed.some(p => normalized.startsWith(p))) {
    throw new Error('Only read-only queries allowed');
  }
  return this.executeQuery(sql, params);
}

// Write queries (requires confirmation)
async writeQuery(sql: string, params: any[], confirm: boolean) {
  if (!confirm) {
    throw new Error('Write operation requires confirmation');
  }
  return this.executeQuery(sql, params);
}
```

### Query Optimization Tools
```sql
-- EXPLAIN ANALYZE shows actual execution plan
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';

-- Index recommendations
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_users_created ON users(created_at);
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
```

---

## 5.2 My Notes

### Configuration
```
POSTGRES_HOST: 
POSTGRES_PORT: 
POSTGRES_USER: 
POSTGRES_PASSWORD: 
POSTGRES_DATABASE: 
```

### Queries I Optimized
```
1. 
2. 
3. 
```

### Indexes I Created
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 6: KNOWLEDGE SERVER

## 6.1 Key Concepts

### Data Source Adapter Pattern
```
┌─────────────────────────────────────────────┐
│         Base DataSourceAdapter              │
├─────────────────────────────────────────────┤
│  + id: string                               │
│  + name: string                             │
│  + description: string                      │
│  + initialize(): Promise<void>              │
│  + query(request): Promise<QueryResult>     │
│  + getResource(uri): Promise<ResourceData>  │
│  + listResources(): Promise<ResourceList>   │
│  + healthCheck(): Promise<HealthStatus>     │
│  + shutdown(): Promise<void>                │
└─────────────────────────────────────────────┘
         ▲          ▲          ▲
         │          │          │
    ┌────┴────┐┌────┴────┐┌────┴────┐
    │PostgreSQL││ SQLite  ││ GitHub  │
    │ Adapter ││ Adapter ││ Adapter │
    └─────────┘└─────────┘└─────────┘
```

### Unified Search Implementation
```typescript
async function searchAcrossSources(query: string, sources: string[]) {
  const results = [];
  const errors = [];

  // Determine which adapters to query
  const adapters = sources.length > 0
    ? adapters.filter(a => sources.includes(a.id))
    : adapters;

  // Query each adapter in parallel
  const promises = adapters.map(async (adapter) => {
    try {
      const result = await adapter.query({
        type: 'search',
        query,
        limit: 10
      });
      results.push({
        source: adapter.id,
        name: adapter.name,
        results: result.data,
        count: result.data.length
      });
    } catch (error) {
      errors.push({
        source: adapter.id,
        error: error.message
      });
    }
  });

  await Promise.allSettled(promises);

  return {
    results,
    errors,
    total: results.reduce((sum, r) => sum + r.count, 0)
  };
}
```

### Health Monitoring
```typescript
async function checkAllHealth(): Promise<HealthReport> {
  const checks = await Promise.all(
    adapters.map(async (adapter) => ({
      source: adapter.id,
      name: adapter.name,
      healthy: await adapter.healthCheck()
    }))
  );

  return {
    healthy: checks.every(c => c.healthy),
    checks,
    timestamp: new Date().toISOString()
  };
}
```

---

## 6.2 My Notes

### Adapters I Implemented
```
1. 
2. 
3. 
```

### Search Queries I Tested
```
1. 
2. 
3. 
```

### Errors Encountered
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 7: AUTONOMOUS RESEARCH ASSISTANT

## 7.1 Key Concepts

### Agent Architecture
```
┌─────────────────────────────────────────────┐
│           Research Assistant                │
├─────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ Planner  │  │Executor  │  │ Reflector│ │
│  └──────────┘  └──────────┘  └──────────┘ │
│  ┌──────────┐  ┌──────────┐               │
│  │ Memory   │  │ Context  │               │
│  │ Manager  │  │ Manager  │               │
│  └──────────┘  └──────────┘               │
├─────────────────────────────────────────────┤
│           MCP Client Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │Knowledge │  │Database  │  │  GitHub  │ │
│  │ Server   │  │ Server   │  │ Adapter  │ │
│  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────┘
```

### The Agent Loop
```
1. PLAN
   ┌─────────────────────────────────────────┐
   │  Break goal into steps                  │
   │  Identify dependencies                  │
   │  Order steps efficiently                │
   └─────────────────────────────────────────┘
              ↓
2. EXECUTE
   ┌─────────────────────────────────────────┐
   │  Perform each step                      │
   │  Use tools to complete tasks           │
   │  Collect results                        │
   └─────────────────────────────────────────┘
              ↓
3. OBSERVE
   ┌─────────────────────────────────────────┐
   │  Analyze results                        │
   │  Check progress                         │
   │  Identify issues                        │
   └─────────────────────────────────────────┘
              ↓
4. REFLECT
   ┌─────────────────────────────────────────┐
   │  Evaluate what worked                   │
   │  Identify what didn't                   │
   │  Adjust the plan                        │
   └─────────────────────────────────────────┘
              ↓
5. REPEAT until goal achieved
```

### Memory System
```
Memory Types:
┌─────────────────────────────────────────────┐
│  observation  │  Facts the agent discovered │
├─────────────────────────────────────────────┤
│  conclusion   │  Insights from observations │
├─────────────────────────────────────────────┤
│  plan         │  Steps to achieve goals     │
├─────────────────────────────────────────────┤
│  reflection   │  Analysis of progress       │
├─────────────────────────────────────────────┤
│  result       │  Outcomes of actions        │
└─────────────────────────────────────────────┘

Short-term Memory:
- Recent conversations
- Current context
- Limited size (10 entries)

Long-term Memory:
- Important information
- Past learnings
- Unlimited size
```

### Planner Implementation
```typescript
class Planner {
  createPlan(goal: string): ResearchPlan {
    const steps = this.generateSteps(goal);
    
    return {
      id: `plan-${Date.now()}`,
      goal,
      steps,
      status: 'planning',
      createdAt: new Date()
    };
  }

  private generateSteps(goal: string): PlanStep[] {
    const steps = [];
    
    // Step 1: Understand the request
    steps.push({
      id: 'step-1',
      description: 'Understand the research request',
      action: 'reflect',
      dependencies: []
    });
    
    // Step 2: Determine data sources
    steps.push({
      id: 'step-2',
      description: 'Determine needed data sources',
      action: 'search_knowledge',
      dependencies: ['step-1']
    });
    
    // Step 3: Query data sources
    steps.push({
      id: 'step-3',
      description: 'Query data sources',
      action: 'execute_query',
      dependencies: ['step-2']
    });
    
    // Step 4: Analyze results
    steps.push({
      id: 'step-4',
      description: 'Analyze research findings',
      action: 'analyze_results',
      dependencies: ['step-3']
    });
    
    return steps;
  }
}
```

---

## 7.2 My Notes

### Agent Loop Examples
```
Goal: 
Steps:
1. 
2. 
3. 

Results:
```

### Memory System
```
Short-term memories:
1. 
2. 
3. 

Long-term memories:
1. 
2. 
3. 
```

### Plans I Created
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 8: A2A COLLABORATION

## 8.1 Key Concepts

### A2A Architecture
```
┌─────────────────────────────────────────────┐
│           Multi-Agent System                │
│                                             │
│  ┌──────────────┐  ┌──────────────┐        │
│  │   Research   │  │    Coding    │        │
│  │    Agent     │◄─┼──►  Agent    │        │
│  └──────────────┘  └──────────────┘        │
│  ┌──────────────┐  ┌──────────────┐        │
│  │   Database   │  │    DevOps    │        │
│  │    Agent     │◄─┼──►  Agent    │        │
│  └──────────────┘  └──────────────┘        │
│         ▲                 ▲                 │
│         │                 │                 │
│         ▼                 ▼                 │
│  ┌─────────────────────────────────────────┐│
│  │           A2A Protocol Layer            ││
│  │  ┌──────────┐  ┌──────────┐            ││
│  │  │ Registry │  │  Router  │            ││
│  │  └──────────┘  └──────────┘            ││
│  └─────────────────────────────────────────┘│
│         ▲                 ▲                 │
│         │                 │                 │
│         ▼                 ▼                 │
│  ┌─────────────────────────────────────────┐│
│  │              MCP Layer                  ││
│  │  ┌──────────┐  ┌──────────┐            ││
│  │  │Knowledge │  │Database  │            ││
│  │  │ Server   │  │ Server   │            ││
│  │  └──────────┘  └──────────┘            ││
│  └─────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

### Agent Identity
```typescript
interface AgentIdentity {
  id: string;           // Unique identifier
  name: string;         // Human-readable name
  role: AgentRole;      // coordinator | researcher | coder | database
  description: string;  // What the agent does
  status: 'online' | 'busy' | 'offline';
}

interface AgentCapability {
  name: string;          // Capability name
  description: string;   // What it does
  tools: string[];       // MCP tools this agent can use
  resources: string[];   // MCP resources this agent can access
  expertise: string[];   // Areas of expertise
}
```

### A2A Message Types
```
┌─────────────────────────────────────────────┐
│  REQUEST    │  Ask for information/action   │
├─────────────────────────────────────────────┤
│  RESPONSE   │  Reply to a request           │
├─────────────────────────────────────────────┤
│  DELEGATION │  Assign a task to another     │
├─────────────────────────────────────────────┤
│  NOTIFICATION│ Inform of an event           │
├─────────────────────────────────────────────┤
│  BROADCAST  │  Send to all agents           │
└─────────────────────────────────────────────┘
```

### Message Structure
```typescript
interface A2AMessage {
  id: string;
  type: MessageType;
  from: string;           // Agent ID
  to: string | string[];  // Agent ID(s)
  subject: string;
  body: any;
  priority: 'low' | 'medium' | 'high' | 'critical';
  createdAt: Date;
  requiresResponse: boolean;
  responseTo?: string;    // ID of message this responds to
  workflowId?: string;    // Shared workflow identifier
}
```

### Agent Registry
```typescript
class AgentRegistry {
  private agents: Map<string, RegistryEntry> = new Map();

  register(agent: AgentIdentity, capabilities: AgentCapability[]): void {
    this.agents.set(agent.id, { agent, capabilities });
  }

  findBestAgentForTask(
    role: AgentRole,
    requiredTools: string[]
  ): AgentIdentity | null {
    const candidates = Array.from(this.agents.values())
      .filter(entry => {
        if (entry.agent.status !== 'online') return false;
        if (entry.agent.role !== role) return false;
        if (requiredTools.length > 0) {
          const hasAllTools = requiredTools.every(tool =>
            entry.capabilities.some(cap => cap.tools.includes(tool))
          );
          if (!hasAllTools) return false;
        }
        return true;
      });
    
    return candidates.length > 0 ? candidates[0].agent : null;
  }
}
```

### Delegation Flow
```
1. Coordinator receives task
2. Coordinator finds best agent for task
3. Coordinator sends delegation message
4. Agent receives delegation
5. Agent processes task
6. Agent returns result
7. Coordinator returns final result
```

---

## 8.2 My Notes

### Agents I Created
```
1. 
2. 
3. 
```

### Message Examples
```
Request:
{
  "type": "request",
  "from": "___",
  "to": "___",
  "subject": "___",
  "body": "___"
}

Response:
{
  "type": "response",
  "from": "___",
  "to": "___",
  "subject": "___",
  "body": "___",
  "responseTo": "___"
}
```

### Delegation Examples
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 9: ADVANCED MULTI-AGENT

## 9.1 Key Concepts

### Hierarchical Architecture
```
┌─────────────────────────────────────────────┐
│         COORDINATOR AGENT                   │
│  - Receives project requirements           │
│  - Creates high-level plan                 │
│  - Monitors overall progress               │
└─────────────────────────────────────────────┘
                    │
┌─────────────────────────────────────────────┐
│         SUPERVISOR AGENT                    │
│  - Breaks down into tasks                  │
│  - Assigns to workers                      │
│  - Reviews and merges work                 │
└─────────────────────────────────────────────┘
                    │
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Research │  │  Coding  │  │  Review  │
│  Agent   │  │  Agent   │  │  Agent   │
└──────────┘  └──────────┘  └──────────┘
```

### Shared Memory
```typescript
interface MemoryEntry {
  id: string;
  key: string;
  value: any;
  type: 'context' | 'artifact' | 'decision' | 'result' | 'state';
  version: number;
  createdBy: string;    // Agent ID
  createdAt: Date;
  updatedAt: Date;
}

class SharedMemory {
  private entries: Map<string, MemoryEntry[]> = new Map();

  set(key: string, value: any, type: MemoryEntry['type'], createdBy: string): void {
    const existing = this.entries.get(key) || [];
    const version = existing.length + 1;
    
    const entry: MemoryEntry = {
      id: `mem-${Date.now()}`,
      key,
      value,
      type,
      version,
      createdBy,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    existing.push(entry);
    this.entries.set(key, existing);
  }

  get(key: string): MemoryEntry | undefined {
    const existing = this.entries.get(key);
    return existing ? existing[existing.length - 1] : undefined;
  }

  getContext(keys: string[]): Record<string, any> {
    const context: Record<string, any> = {};
    for (const key of keys) {
      const entry = this.get(key);
      if (entry) {
        context[key] = entry.value;
      }
    }
    return context;
  }
}
```

### Human-in-the-Loop
```
┌─────────────────────────────────────────────┐
│         Human Approval Workflow             │
├─────────────────────────────────────────────┤
│  1. Agent requests approval for action      │
│  2. Human receives notification             │
│  3. Human reviews request                   │
│  4. Human approves or rejects               │
│  5. Agent proceeds based on decision        │
│  6. Decision is logged for audit            │
└─────────────────────────────────────────────┘
```

---

## 9.2 My Notes

### Architecture Pattern
```
Pattern used: 
Components:
1. 
2. 
3. 
```

### Shared Memory Entries
```
Keys:
1. 
2. 
3. 
```

### Human-in-the-Loop Scenarios
```
1. 
2. 
3. 
```

### Questions
```
1. 
2. 
3. 
```

---

# PART 10: PRODUCTION ENGINEERING

## 10.1 Key Concepts

### Production Architecture
```
┌─────────────────────────────────────────────┐
│              LOAD BALANCER                  │
│         (HAProxy / NGINX)                   │
├─────────────────────────────────────────────┤
│         KUBERNETES CLUSTER                  │
│  ┌─────────────────────────────────────┐   │
│  │        INGRESS CONTROLLER           │   │
│  └─────────────────────────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │Knowledge │  │  Agent   │  │  A2A     │ │
│  │ Service  │  │ Service  │  │ Service  │ │
│  └──────────┘  └──────────┘  └──────────┘ │
├─────────────────────────────────────────────┤
│         OBSERVABILITY STACK                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │Prometheus│  │ Grafana  │  │   ELK    │ │
│  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────┘
```

### Dockerfile Multi-Stage
```dockerfile
# Stage 1: Builder
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY src/ ./src/
RUN npm run build

# Stage 2: Production
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/health')"
CMD ["node", "dist/index.js"]
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: knowledge-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: knowledge-server
  template:
    metadata:
      labels:
        app: knowledge-server
    spec:
      containers:
      - name: knowledge-server
        image: ${REGISTRY}/knowledge-server:${TAG}
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
```

### HPA Configuration
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: knowledge-server-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: knowledge-server
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Prometheus Metrics
```typescript
import prometheus from 'prom-client';

// Create a Registry
const register = new prometheus.Registry();

// Request counter
const httpRequestsTotal = new prometheus.Counter({
  name: 'mcp_http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [register]
});

// Request duration
const httpRequestDuration = new prometheus.Histogram({
  name: 'mcp_http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'path'],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
  registers: [register]
});

// Tool calls
const toolCallsTotal = new prometheus.Counter({
  name: 'mcp_tool_calls_total',
  help: 'Total tool calls',
  labelNames: ['tool', 'success'],
  registers: [register]
});
```

### CI/CD Pipeline
```
┌─────────────────────────────────────────────────────────────┐
│                      CI/CD PIPELINE                        │
├─────────────────────────────────────────────────────────────┤
│  1. Git Push                                               │
│     ↓                                                     │
│  2. Lint & Test                                            │
│     ↓                                                     │
│  3. Build Docker Image                                     │
│     ↓                                                     │
│  4. Push to Registry                                       │
│     ↓                                                     │
│  5. Deploy to Staging                                      │
│     ↓                                                     │
│  6. Run E2E Tests                                          │
│     ↓                                                     │
│  7. Deploy to Production                                   │
│     ↓                                                     │
│  8. Post-Deployment Verification                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 10.2 My Notes

### Docker Commands
```
Build: docker build -t my-server .
Run: docker run -d -p 3000:3000 my-server
Logs: docker logs -f container-id
```

### Kubernetes Commands
```
Deploy: kubectl apply -f deployment.yaml
Status: kubectl get pods -n ai-platform
Logs: kubectl logs pod-name -n ai-platform
Scale: kubectl scale deployment my-server --replicas=3
```

### Monitoring Commands
```
Prometheus: curl http://localhost:9090/metrics
Health: curl http://localhost:3000/health
Readiness: curl http://localhost:3000/ready
```

### Questions
```
1. 
2. 
3. 
```

---

# APPENDIX A: COMMAND REFERENCE

## Development Commands
```bash
# Project Setup
npm init -y
npm install @modelcontextprotocol/sdk zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx

# Build & Run
npm run build       # Build TypeScript
npm start           # Run production
npm run start:dev   # Run development

# Testing
npm test
npm run test:coverage

# Linting
npm run lint
npm run lint:fix
```

## Docker Commands
```bash
# Build
docker build -t my-server .

# Run
docker run -d -p 3000:3000 --name my-server my-server

# Manage
docker ps
docker logs -f my-server
docker stop my-server
docker rm my-server
```

## Kubernetes Commands
```bash
# Apply
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Manage
kubectl get pods -n ai-platform
kubectl get services -n ai-platform
kubectl get deployments -n ai-platform

# Debug
kubectl logs pod-name -n ai-platform
kubectl describe pod pod-name -n ai-platform
kubectl exec -it pod-name -- /bin/sh
```

---

# APPENDIX B: TROUBLESHOOTING GUIDE

## Common Issues & Solutions

### Connection Issues
```
Issue: Connection refused
Solution: Check server is running, port is accessible

Issue: Connection timeout
Solution: Check network, increase timeout

Issue: Connection reset
Solution: Check for server crashes, restart
```

### JSON-RPC Issues
```
Issue: Parse Error (-32700)
Solution: Validate JSON format, check for trailing commas

Issue: Method Not Found (-32601)
Solution: Check method name spelling, ensure registered

Issue: Invalid Params (-32602)
Solution: Check parameter types, validate with Zod
```

### Tool Issues
```
Issue: Tool Not Found (-32001)
Solution: Ensure tool is registered, check name spelling

Issue: Tool Execution Error (-32004)
Solution: Check tool implementation, handle errors

Issue: Tool Timeout
Solution: Increase timeout, optimize tool logic
```

### Database Issues
```
Issue: Connection refused
Solution: Check database is running, credentials

Issue: Query timeout
Solution: Optimize query, add indexes, increase timeout

Issue: SQL Injection
Solution: Use parameterized queries, validate input
```

---

# APPENDIX C: QUICK REFERENCE

## MCP Methods
```
Discovery:
  tools/list      → Get all tools
  resources/list  → Get all resources
  prompts/list    → Get all prompts

Invocation:
  tools/call      → Execute a tool
  resources/read  → Read a resource
  prompts/get     → Get a prompt

Lifecycle:
  initialize      → Handshake
  shutdown        → Shutdown
  ping            → Keep-alive
```

## Error Codes
```
-32700  Parse Error
-32600  Invalid Request
-32601  Method Not Found
-32602  Invalid Params
-32603  Internal Error
-32001  Tool Not Found
-32002  Resource Not Found
-32003  Prompt Not Found
```

## Environment Variables
```
General:
  NODE_ENV        development/staging/production
  LOG_LEVEL       debug/info/warn/error

Database:
  DB_PATH         ./data/app.db
  DB_READ_ONLY    true/false
  DB_MAX_CONNECTIONS  10

PostgreSQL:
  POSTGRES_HOST   localhost
  POSTGRES_PORT   5432
  POSTGRES_USER   postgres
  POSTGRES_PASSWORD   postgres
  POSTGRES_DATABASE   postgres

Security:
  MCP_AUTH_ENABLED    true/false
  MCP_API_KEYS        key1,key2
  JWT_SECRET          your-secret
```

---

**[END OF STUDENT NOTES]**
