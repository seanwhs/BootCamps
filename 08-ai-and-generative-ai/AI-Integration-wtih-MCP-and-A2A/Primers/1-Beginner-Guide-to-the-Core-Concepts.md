# MCP & A2A Primer: A Beginner's Guide to the Core Concepts

## Welcome to the Future of AI

If you've ever wondered how AI applications actually **do things**—how they send emails, query databases, deploy code, or research complex topics—you're about to discover the answer. This primer will give you a solid foundation in the two protocols that are revolutionizing AI development: **MCP (Model Context Protocol)** and **A2A (Agent-to-Agent)**.

---

## The Big Picture: What Are We Building?

Before we dive into the details, let's understand the problem we're solving.

### The Problem: AI Has No "Hands"

Imagine you have a brilliant assistant who can think and reason but has no hands. To actually accomplish tasks, the assistant needs tools—ways to interact with the world.

Before MCP, every AI integration was custom:
- One tool for Slack: custom Slack API integration
- One tool for GitHub: custom GitHub integration
- One tool for databases: custom database integration

Each integration had its own format, authentication, and error handling. This made systems brittle and hard to maintain.

### The Solution: Two Protocols Working Together

**MCP (Model Context Protocol)** and **A2A (Agent-to-Agent)** work together to solve this problem:

| Protocol | What It Does | Analogy |
|----------|--------------|---------|
| **MCP** | Connects AI to external tools and data | Like a universal USB-C port for AI—standardized connections to any tool |
| **A2A** | Connects AI agents to each other | Like a team communication protocol—specialists working together |

Think of it this way:
- **MCP** is how AI gets "hands" (tools to interact with the world)
- **A2A** is how AI gets "teammates" (other AI agents to collaborate with)

---

## Part 1: Understanding MCP (Model Context Protocol)

### What is MCP?

MCP is an open protocol that standardizes how AI applications (clients) discover and interact with external capabilities (servers). It provides a standardized way for AI models to connect to different data sources and tools. 

**The official description:** "MCP is an open protocol that standardizes how applications provide context to LLMs. Think of MCP like a USB-C port for AI applications. Just as USB-C provides a standardized way to connect your devices to various peripherals and accessories, MCP provides a standardized way to connect AI models to different data sources and tools." 

### MCP Architecture: Client-Server Model

MCP uses a client-server architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Application                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              MCP Client                             │   │
│  │  - Discovers capabilities                          │   │
│  │  - Invokes tools                                   │   │
│  │  - Reads resources                                 │   │
│  │  - Executes prompts                                │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ▼                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           JSON-RPC over Transport                   │   │
│  │  (stdio, WebSocket, HTTP, or custom)               │   │
│  └─────────────────┬───────────────────────────────────┘   │
│                    │                                        │
│                    ▼                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              MCP Server                            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │
│  │  │  Tools   │  │Resources │  │ Prompts  │        │   │
│  │  └──────────┘  └──────────┘  └──────────┘        │   │
│  └─────────────────────────────────────────────────────┘   │
│                    │                                        │
│                    ▼                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            External Systems                         │   │
│  │  (APIs, Databases, Filesystems, Services)          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### The Three Pillars of MCP

MCP servers expose three types of capabilities :

#### 1. Tools (Actions)

Tools are executable functions that the AI can call. They represent **actions** the AI can take.

**Example:** A weather tool that gets current temperature

```typescript
// Tool definition
{
  name: "get_weather",
  description: "Gets the current temperature and wind speed for a given latitude and longitude",
  inputSchema: {
    type: "object",
    properties: {
      latitude: { type: "number", description: "The latitude of the location" },
      longitude: { type: "number", description: "The longitude of the location" }
    },
    required: ["latitude", "longitude"]
  }
}
```

#### 2. Resources (Data)

Resources are data that the AI can **read**. They represent information the AI can access.

**Example:** A system information resource

```
URI: system://info
Content: {"hostname": "server-01", "cpu": "8 cores", "memory": "16GB"}
```

#### 3. Prompts (Templates)

Prompts are reusable templates that **guide AI behavior**. They help structure AI interactions.

**Example:** A welcome prompt

```
"Welcome to the MCP server! I have access to the following tools: 
- get_weather(city) - Get current weather
- send_email(to, subject, body) - Send an email
- read_file(path) - Read a file from the filesystem"
```

### Communication: JSON-RPC

MCP uses JSON-RPC 2.0 for communication. Every message is a JSON object with: 

- `jsonrpc`: Always "2.0"
- `id`: A unique request ID
- `method`: The operation to perform
- `params`: The parameters for the operation

**Common Methods:**

| Method | Purpose |
|--------|---------|
| `initialize` | Handshake between client and server |
| `tools/list` | Get all available tools |
| `tools/call` | Execute a specific tool |
| `resources/list` | Get all available resources |
| `resources/read` | Read a specific resource |
| `prompts/list` | Get all available prompts |
| `prompts/get` | Get a specific prompt |

### Transport Mechanisms

MCP supports different transport methods for communication :

| Transport | Use Case | Description |
|-----------|----------|-------------|
| **stdio** | Local development | Communicates via standard input/output streams |
| **WebSocket** | Real-time web apps | Persistent bidirectional connection |
| **HTTP** | Production APIs | REST-style requests |
| **SSE** | Streaming (deprecated) | Server-sent events |

### Practical Example: Your First MCP Server

Here's the simplest MCP server you can build—a weather server that exposes a single tool. 

**Step 1: Set up your project**

```bash
mkdir mcp-weather-server
cd mcp-weather-server
npm init -y
npm install @modelcontextprotocol/sdk
```

**Step 2: Create the server**

```javascript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({ name: "weather-server" });

// List available tools
server.setRequestHandler("ListToolsRequest", async () => ({
  tools: [{
    name: "get_weather",
    description: "Gets the current temperature for a given latitude and longitude.",
    inputSchema: {
      type: "object",
      properties: {
        latitude: { type: "number" },
        longitude: { type: "number" }
      },
      required: ["latitude", "longitude"]
    }
  }]
}));

// Execute tool calls
server.setRequestHandler("CallToolRequest", async (request) => {
  if (request.params.name === "get_weather") {
    const { latitude, longitude } = request.params.arguments;
    const response = await fetch(
      `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current_weather=true`
    );
    const data = await response.json();
    return {
      content: [{
        type: "text",
        text: `Temperature: ${data.current_weather.temperature}°C`
      }]
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

**Step 3: Connect to an AI Client**

Add the server to your Gemini CLI settings (`~/.gemini/settings.json`):

```json
{
  "mcpServers": {
    "weather-server": {
      "command": "node",
      "args": ["/path/to/your/server.js"]
    }
  }
}
```

Now you can simply ask "What's the weather in New York?" and the AI will use your server to get the answer! 

---

## Part 2: Understanding A2A (Agent-to-Agent)

### What is A2A?

**Agent-to-Agent (A2A)** is an emerging open protocol that enables autonomous AI agents to discover one another, exchange messages, delegate work, and collaborate on complex tasks. 

**The Problem A2A Solves:**
- Before A2A, every multi-agent system built its own custom communication protocol
- Agents couldn't discover each other dynamically
- No standard for capability advertisement
- Difficult to add new agents to a system
- No interoperability between different agent systems

**The Solution: A2A provides a common language for agents to talk to each other.**

### MCP vs A2A: What's the Difference?

| Aspect | MCP | A2A |
|--------|-----|-----|
| **What it connects** | AI to external tools and data | AI agents to each other |
| **Analogy** | USB-C for AI—universal tool connections | Team communication protocol |
| **Interaction** | Client-server (AI → Tool) | Peer-to-peer (Agent ↔ Agent) |
| **Use Case** | Getting "hands" (tools) | Getting "teammates" (collaborators) |

Think of it this way:
- **MCP** is like each agent having a toolkit (tools, resources, prompts)
- **A2A** is like agents being able to talk to each other and share their toolkits

### A2A Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Multi-Agent System                     │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Research   │  │    Coding    │  │   Database   │    │
│  │    Agent     │◄─┼──►  Agent    │◄─┼──►  Agent    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│         ▲                 ▲                 ▲              │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              A2A Protocol Layer                     │   │
│  │  - Message routing                                  │   │
│  │  - Agent discovery                                  │   │
│  │  - Capability advertisement                        │   │
│  │  - Task delegation                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│         ▲                 ▲                 ▲              │
│         │                 │                 │              │
│         ▼                 ▼                 ▼              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    MCP Layer                        │   │
│  │  - Knowledge Server  - Database Server             │   │
│  │  - GitHub Adapter   - REST API Adapter            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### A2A Message Types

Agents communicate using different types of messages :

| Message Type | Purpose |
|--------------|---------|
| **Request** | Asking another agent for information or action |
| **Response** | Replying to a request |
| **Delegation** | Assigning a task to another agent |
| **Notification** | Informing others of an event |
| **Broadcast** | Sending a message to all agents |

### Agent Identity and Capabilities

Each agent has a unique identity and capabilities that it advertises:

```typescript
interface AgentIdentity {
  id: string;           // Unique identifier
  name: string;         // Human-readable name
  role: AgentRole;      // What the agent does
  description: string;  // What the agent is for
  capabilities: AgentCapability[];  // What the agent can do
}

interface AgentCapability {
  name: string;          // Capability name
  description: string;   // What it does
  tools: string[];       // MCP tools the agent can use
  resources: string[];   // MCP resources the agent can access
  expertise: string[];   // Areas of expertise
}
```

### Example: A2A Message Flow

**Delegation Pattern** :

```
┌──────────┐     ┌─────────────┐     ┌──────────┐
│  Agent   │     │ Coordinator │     │  Agent   │
│   (A)    │     │    Agent    │     │   (C)    │
└────┬─────┘     └──────┬──────┘     └────┬─────┘
     │                  │                  │
     │ 1. Delegate      │                  │
     │─────────────────►│                  │
     │                  │ 2. Find best     │
     │                  │    agent         │
     │                  │                  │
     │                  │ 3. Delegate      │
     │                  │─────────────────►│
     │                  │                  │
     │                  │ 4. Process       │
     │                  │                  │
     │                  │ 5. Result        │
     │                  │◄─────────────────│
     │                  │                  │
     │ 6. Result        │                  │
     │◄─────────────────│                  │
```

### How MCP and A2A Work Together

MCP and A2A are complementary protocols that work together:

1. **Agents use MCP** to access tools and data
2. **Agents use A2A** to communicate with each other

**Example Workflow:**
1. User asks: "Find the best practices for database optimization and create a report"
2. **Coordinator Agent** receives the request
3. **Coordinator** delegates research to **Research Agent** (A2A)
4. **Research Agent** uses MCP to query the Knowledge Server and GitHub
5. **Research Agent** sends findings back to Coordinator (A2A)
6. **Coordinator** delegates writing to **Documentation Agent** (A2A)
7. **Documentation Agent** uses MCP to create the report
8. **Coordinator** returns the final result

---

## Part 3: Why This Matters

### The Power of Standardization

Before MCP, building an AI integration meant writing custom code for every single tool:

```
Custom Integration → Slack API → Custom Code
Custom Integration → GitHub API → Custom Code
Custom Integration → Database → Custom Code
```

With MCP, all tools use the same interface:

```
MCP → Standard Protocol → Any Tool
```

This means:
- **You write tool integrations once**
- **Any AI application can use them**
- **The ecosystem grows organically**

### Real-World Applications

| Application | MCP Role | A2A Role |
|-------------|----------|----------|
| **Coding Assistant** | Connect to GitHub, filesystem, linters | Code review agents collaborate |
| **DevOps Engineer** | Connect to Docker, Kubernetes, cloud APIs | Agents coordinate deployments |
| **Research Assistant** | Connect to databases, APIs, documentation | Research agents share findings |
| **Customer Support** | Connect to CRM, knowledge base, ticketing | Support agents escalate to specialists |

---

## Part 4: Getting Started (Next Steps)

### 1. Try Existing MCP Servers

Before building your own, try existing MCP servers:

- **Playwright** — Browser automation 
- **Fetch** — Web data retrieval 
- **Memory** — Conversation memory 
- **Sequential Thinking** — Step-by-step reasoning 

### 2. Try MCP Hosts

Connect MCP servers to these AI applications:

- **Cursor** — AI code editor 
- **GitHub Copilot** — AI pair programmer 
- **Claude Code** — CLI coding assistant 
- **Gemini CLI** — Google's AI assistant 

### 3. Build Your Own

Use the libraries and tools from this series:

- **@modelcontextprotocol/sdk** — Official MCP SDK 
- **mcp-agent** — TypeScript framework for building agents 
- **@agenticforge/protocols** — MCP + A2A + ANP implementations 

### 4. Recommended Learning Path

1. **Start with MCP** — Build a simple tool server
2. **Add resources and prompts** — Make your server more capable
3. **Build an MCP client** — Connect your server to an AI
4. **Add A2A** — Make your agents talk to each other
5. **Build multi-agent systems** — Create specialized agent teams

---

## Quick Reference: Key Terms

| Term | Definition |
|------|------------|
| **MCP** | Protocol for connecting AI to tools and data |
| **A2A** | Protocol for agents to communicate with each other |
| **Tool** | An action an AI can perform (MCP) |
| **Resource** | Data an AI can read (MCP) |
| **Prompt** | Template that guides AI behavior (MCP) |
| **Agent** | Autonomous AI system that can use tools and communicate |
| **JSON-RPC** | Communication protocol used by MCP |
| **Stdio** | Standard input/output transport for local development |

---

## Summary

You've learned the fundamentals of:
- **MCP (Model Context Protocol)** — A standardized way for AI to connect to tools and data
- **A2A (Agent-to-Agent)** — A standardized way for AI agents to communicate and collaborate
- **How they work together** — Agents use MCP for tools and A2A for communication
- **How to get started** — Try existing servers, hosts, and build your own

**The key insight:** MCP and A2A together create an ecosystem where AI agents can have both "hands" (tools via MCP) and "teammates" (collaborators via A2A). This is the foundation for building the next generation of intelligent, autonomous AI systems.

---

## Resources

### Official Documentation
- [MCP Specification](https://modelcontextprotocol.io) 
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk) 

### Community Learning
- [mcp-for-beginners Curriculum](https://github.com/EngBuilds/mcp-for-beginners) 
- [Google Codelabs: MCP, ADK, A2A](https://codelabs.developers.google.com) 

### Libraries
- `@modelcontextprotocol/sdk` — Official MCP SDK 
- `@agenticforge/protocols` — MCP, A2A, ANP in TypeScript 
- `mcp-agent` — Lightweight MCP agent framework 

---

**[END OF PRIMER]**
