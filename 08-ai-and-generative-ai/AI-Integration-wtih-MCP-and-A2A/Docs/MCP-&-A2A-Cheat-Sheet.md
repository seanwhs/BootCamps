# Quick Reference: MCP & A2A Cheat Sheet

## MCP Core Concepts

### What is MCP?
**Model Context Protocol (MCP)** — An open protocol that standardizes how AI applications discover and interact with external capabilities (tools, resources, prompts).

### Architecture
```
AI Application → MCP Client → JSON-RPC → MCP Server → External Systems
```

### The Three Pillars

| Pillar | Purpose | Example |
|--------|---------|---------|
| **Tools** | Actions AI can perform | `get_weather(city)`, `send_email(to, subject)` |
| **Resources** | Data AI can read | `system://info`, `database://users` |
| **Prompts** | Templates guiding AI | `welcome_prompt`, `code_review_prompt` |

---

## MCP Quick Setup

### Install MCP SDK
```bash
npm install @modelcontextprotocol/sdk
```

### Basic Server
```typescript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

const server = new McpServer({ name: 'my-server', version: '1.0.0' });

// Register a tool
server.tool(
  'add',
  { a: z.number(), b: z.number() },
  async ({ a, b }) => ({
    content: [{ type: 'text', text: `${a} + ${b} = ${a + b}` }]
  })
);

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Basic Client
```typescript
import { McpClient } from '@modelcontextprotocol/sdk/client/mcp.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';

const client = new McpClient({ name: 'my-client', version: '1.0.0' });

const transport = new StdioClientTransport({
  command: 'node',
  args: ['server.js']
});

await client.connect(transport);
const { tools } = await client.listTools();
const result = await client.callTool('add', { a: 5, b: 3 });
await client.close();
```

---

## JSON-RPC Reference

### Request Format
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "method": "tools/call",
  "params": {
    "name": "add",
    "arguments": { "a": 5, "b": 3 }
  }
}
```

### Response Format
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "result": {
    "content": [{ "type": "text", "text": "5 + 3 = 8" }]
  }
}
```

### Error Format
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "error": {
    "code": -32601,
    "message": "Method not found"
  }
}
```

### Common Methods

| Method | Purpose |
|--------|---------|
| `tools/list` | Get all tools |
| `tools/call` | Execute a tool |
| `resources/list` | Get all resources |
| `resources/read` | Read a resource |
| `prompts/list` | Get all prompts |
| `prompts/get` | Get a prompt |
| `initialize` | Handshake |

---

## Error Codes

### JSON-RPC Errors
| Code | Name |
|------|------|
| -32700 | Parse Error |
| -32600 | Invalid Request |
| -32601 | Method Not Found |
| -32602 | Invalid Params |
| -32603 | Internal Error |

### MCP-Specific Errors
| Code | Name |
|------|------|
| -32001 | Tool Not Found |
| -32002 | Resource Not Found |
| -32003 | Prompt Not Found |
| -32004 | Tool Execution Error |
| -32005 | Resource Read Error |
| -32006 | Prompt Execution Error |
| -32007 | Transport Error |
| -32008 | Connection Error |
| -32009 | Authentication Error |
| -32010 | Authorization Error |

---

## A2A Core Concepts

### What is A2A?
**Agent-to-Agent (A2A)** — An open protocol that enables autonomous AI agents to discover one another, exchange messages, delegate work, and collaborate.

### Architecture
```
Coordinator Agent ──► Router ──► Research Agent
        │                            │
        └───────────◄────────────────┘
```

### Message Types
| Type | Purpose |
|------|---------|
| **Request** | Ask for information/action |
| **Response** | Reply to a request |
| **Delegation** | Assign a task |
| **Notification** | Inform of an event |
| **Broadcast** | Send to all agents |

### Agent Roles
| Role | Responsibility |
|------|---------------|
| **Coordinator** | Orchestrates workflows |
| **Supervisor** | Manages other agents |
| **Researcher** | Gathers information |
| **Coder** | Writes code |
| **Database** | Manages databases |
| **DevOps** | Handles infrastructure |

---

## A2A Quick Setup

### Basic Agent
```typescript
import { BaseAgent } from './base-agent.js';

class MyAgent extends BaseAgent {
  constructor(registry, router) {
    super(
      {
        id: `agent-${Date.now()}`,
        name: 'My Agent',
        role: 'specialist',
        description: 'My custom agent'
      },
      [
        {
          name: 'My Capability',
          description: 'What I can do',
          actions: ['action1', 'action2']
        }
      ],
      registry,
      router
    );
  }

  protected async processDelegation(task: any): Promise<any> {
    // Process the task
    return { result: 'Task completed' };
  }
}
```

### Sending a Message
```typescript
await this.sendMessage(
  'recipient-id',           // To
  'request',                // Type
  'Subject',                // Subject
  { query: 'something' }    // Body
);
```

### Registering an Agent
```typescript
const registry = new AgentRegistry();
const router = new MessageRouter(registry);
const agent = new MyAgent(registry, router);
await agent.start();
```

---

## MCP vs A2A Comparison

| Aspect | MCP | A2A |
|--------|-----|-----|
| **Purpose** | Connect AI to tools | Connect agents to each other |
| **Architecture** | Client-Server | Peer-to-Peer |
| **Communication** | Request-Response | Message-based |
| **Analogy** | Tools in a workshop | Team members collaborating |
| **Transport** | stdio, WebSocket, HTTP | Message-based (over MCP/HTTP) |
| **Discovery** | Tools/Resources/Prompts | Agents and Capabilities |

---

## Common Patterns

### 1. Tool with Validation
```typescript
server.tool(
  'safe_operation',
  {
    input: z.string().min(1).max(1000),
    options: z.object({
      format: z.enum(['json', 'text']).default('text')
    })
  },
  async ({ input, options }) => {
    // Implementation
  }
);
```

### 2. Resource with Caching
```typescript
const cache = new Map();

server.resource(
  'cached_data',
  'data://*',
  { description: 'Cached data', mimeType: 'application/json' },
  async (uri: string) => {
    if (cache.has(uri)) {
      return cache.get(uri);
    }
    const data = await fetchData(uri);
    cache.set(uri, data);
    return data;
  }
);
```

### 3. Agent Delegation
```typescript
protected async processDelegation(task: any): Promise<any> {
  // Find suitable agent
  const agent = this.registry.findBestAgentForTask(
    'researcher',
    ['search', 'analyze']
  );
  
  // Delegate
  await this.sendMessage(
    agent.identity.id,
    'delegation',
    'Research Task',
    { query: task.query }
  );
  
  // Wait for response...
}
```

---

## Environment Variables

### MCP Server
```env
MCP_SERVER_NAME=my-server
MCP_SERVER_VERSION=1.0.0
LOG_LEVEL=info
MCP_AUTH_ENABLED=false
MCP_API_KEYS=key1,key2
```

### PostgreSQL
```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DATABASE=postgres
```

### OpenAI
```env
OPENAI_API_KEY=your-key
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_MAX_TOKENS=4096
```

---

## CLI Commands

### Build and Run
```bash
# Build TypeScript
npm run build

# Run server
npm start

# Development with auto-reload
npm run start:dev

# Run tests
npm test

# Lint
npm run lint
```

### Docker
```bash
# Build image
docker build -t my-server .

# Run container
docker run -d -p 3000:3000 my-server

# View logs
docker logs -f container-id
```

### Kubernetes
```bash
# Deploy
kubectl apply -f deployment.yaml

# Check status
kubectl get pods -n ai-platform

# View logs
kubectl logs pod-name -n ai-platform

# Scale
kubectl scale deployment my-server --replicas=3
```

---

## Monitoring Commands

### Metrics
```bash
# Prometheus
curl http://localhost:9090/metrics

# Health check
curl http://localhost:3000/health

# Readiness probe
curl http://localhost:3000/ready
```

### Logs
```bash
# Recent logs
kubectl logs --tail=100 pod-name

# Follow logs
kubectl logs -f pod-name

# Filter by error
kubectl logs pod-name | grep ERROR
```

---

## Quick Troubleshooting

| Issue | Check | Fix |
|-------|-------|-----|
| Connection refused | Server running? | Start server |
| Parse error | JSON format | Validate JSON |
| Tool not found | Tool registered? | Register tool |
| Method not found | Method name | Check spelling |
| Timeout | Server response | Increase timeout |
| Auth failed | API key | Check API key |
| 404 | Route exists? | Check path |

---

## Useful Resources

### Official Docs
- [MCP Specification](https://modelcontextprotocol.io)
- [MCP SDK Docs](https://github.com/modelcontextprotocol/sdk)
- [A2A Specification](https://a2a-protocol.org)

### Libraries
- `@modelcontextprotocol/sdk` — Official MCP SDK
- `zod` — Schema validation
- `pino` — Logging
- `dotenv` — Environment variables
- `pg` — PostgreSQL client
- `sqlite3` — SQLite client

### Tools
- `tsx` — TypeScript execution
- `vitest` — Testing
- `eslint` — Linting
- `prettier` — Code formatting

---

**This cheat sheet is a quick reference for the most common MCP and A2A patterns, commands, and concepts. Save it for quick access while building your AI systems!**
