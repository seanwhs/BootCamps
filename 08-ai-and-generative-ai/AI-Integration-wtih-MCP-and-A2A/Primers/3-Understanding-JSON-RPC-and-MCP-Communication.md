# MCP & A2A Primer: Part 3 — Understanding JSON-RPC and MCP Communication

## Introduction

In Part 2, you built your first MCP server using the SDK. But what's actually happening under the hood? How does the client talk to the server? In this primer, we'll pull back the curtain and explore the actual messages that flow between MCP clients and servers.

By the end of this tutorial, you'll understand:
1. What JSON-RPC is and why MCP uses it
2. The exact format of every MCP message
3. How to inspect messages in real-time
4. How to debug MCP communication

---

## Part 1: What is JSON-RPC?

### The Problem JSON-RPC Solves

Imagine you have two programs that need to talk to each other. They need a common language. JSON-RPC is that language—a lightweight, standardized way for programs to make remote procedure calls.

**Think of it like making a phone call:**

| Phone Call Element | JSON-RPC Element |
|--------------------|------------------|
| Dialing a number | Sending a request |
| Speaking on the phone | The request body |
| The person on the other end | The server |
| Hanging up | The response |
| Caller ID | The request ID |

### JSON-RPC 2.0 Specification

JSON-RPC 2.0 defines three types of messages:

1. **Request** — A message that expects a response
2. **Response** — A reply to a request
3. **Notification** — A message that doesn't expect a response

**Request Format:**
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "method": "tools/list",
  "params": {}
}
```

**Response Format:**
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "result": { /* ... */ }
}
```

**Error Response Format:**
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

### Why MCP Uses JSON-RPC

MCP chose JSON-RPC because:
1. **Simple** — Easy to understand and implement
2. **Language-agnostic** — Works with any programming language
3. **Human-readable** — Easy to debug
4. **Standardized** — Well-defined specification
5. **Lightweight** — Minimal overhead

---

## Part 2: MCP Message Types

### The Three Categories of MCP Messages

MCP uses JSON-RPC for all communication. Here are the main message categories:

#### 1. Discovery Messages

These messages discover what the server can do.

| Method | Purpose |
|--------|---------|
| `initialize` | Handshake between client and server |
| `tools/list` | Get all available tools |
| `resources/list` | Get all available resources |
| `prompts/list` | Get all available prompts |

**Example: tools/list**
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "method": "tools/list",
  "params": {}
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "req-123",
  "result": {
    "tools": [
      {
        "name": "add",
        "description": "Add two numbers together",
        "inputSchema": {
          "type": "object",
          "properties": {
            "a": { "type": "number", "description": "First number" },
            "b": { "type": "number", "description": "Second number" }
          },
          "required": ["a", "b"]
        }
      }
    ]
  }
}
```

#### 2. Invocation Messages

These messages execute operations.

| Method | Purpose |
|--------|---------|
| `tools/call` | Execute a tool |
| `resources/read` | Read a resource |
| `prompts/get` | Get a prompt template |

**Example: tools/call**
```json
{
  "jsonrpc": "2.0",
  "id": "req-456",
  "method": "tools/call",
  "params": {
    "name": "add",
    "arguments": {
      "a": 10,
      "b": 5
    }
  }
}
```

**Success Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "req-456",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "10 + 5 = 15"
      }
    ]
  }
}
```

**Error Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "req-456",
  "error": {
    "code": -32001,
    "message": "Tool not found: multiply",
    "data": {
      "requestedTool": "multiply",
      "availableTools": ["add", "subtract", "divide"]
    }
  }
}
```

#### 3. Lifecycle Messages

These messages manage the connection.

| Method | Purpose |
|--------|---------|
| `initialize` | Handshake and capability exchange |
| `shutdown` | Graceful server shutdown |
| `ping` | Keep-alive check |

---

## Part 3: The Complete Handshake Flow

### Step-by-Step: What Happens When You Connect

Let's trace through what happens when an MCP client connects to a server.

#### Step 1: Client Connects to Server

The client establishes a transport (stdio, WebSocket, HTTP).

```
Client                    Server
   │                         │
   │  (Establish connection) │
   │────────────────────────►│
   │                         │
```

#### Step 2: Initialize

The client sends an `initialize` request to negotiate protocol version.

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "clientInfo": {
      "name": "calculator-client",
      "version": "1.0.0"
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "result": {
    "protocolVersion": "2024-11-05",
    "serverInfo": {
      "name": "calculator-server",
      "version": "1.0.0"
    },
    "capabilities": {
      "tools": {},
      "resources": {},
      "prompts": {}
    }
  }
}
```

#### Step 3: Client Discovers Tools

The client asks what tools are available.

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": "list-1",
  "method": "tools/list",
  "params": {}
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "list-1",
  "result": {
    "tools": [
      {
        "name": "add",
        "description": "Add two numbers together",
        "inputSchema": { /* ... */ }
      },
      {
        "name": "subtract",
        "description": "Subtract one number from another",
        "inputSchema": { /* ... */ }
      },
      {
        "name": "multiply",
        "description": "Multiply two numbers",
        "inputSchema": { /* ... */ }
      },
      {
        "name": "divide",
        "description": "Divide one number by another",
        "inputSchema": { /* ... */ }
      }
    ]
  }
}
```

#### Step 4: Client Discovers Resources

The client asks what resources are available.

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": "list-2",
  "method": "resources/list",
  "params": {}
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "list-2",
  "result": {
    "resources": [
      {
        "uri": "system://info",
        "name": "system_info",
        "description": "System information including OS, CPU, and memory",
        "mimeType": "application/json"
      },
      {
        "uri": "server://status",
        "name": "server_status",
        "description": "Current server status and capabilities",
        "mimeType": "application/json"
      }
    ]
  }
}
```

#### Step 5: Client Discovers Prompts

The client asks what prompts are available.

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": "list-3",
  "method": "prompts/list",
  "params": {}
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "list-3",
  "result": {
    "prompts": [
      {
        "name": "welcome",
        "description": "Welcome message with server capabilities overview",
        "arguments": [
          {
            "name": "name",
            "description": "User name",
            "required": false
          }
        ]
      },
      {
        "name": "help",
        "description": "Help with using the server and its capabilities",
        "arguments": [
          {
            "name": "topic",
            "description": "Specific topic to get help with",
            "required": false
          }
        ]
      }
    ]
  }
}
```

#### Step 6: Client Executes a Tool

Now the client can call tools.

**Request:**
```json
{
  "jsonrpc": "2.0",
  "id": "call-1",
  "method": "tools/call",
  "params": {
    "name": "add",
    "arguments": {
      "a": 10,
      "b": 5
    }
  }
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "call-1",
  "result": {
    "content": [
      {
        "type": "text",
        "text": "10 + 5 = 15"
      }
    ]
  }
}
```

### Visual Timeline

```
┌──────────┐                    ┌──────────┐
│  Client  │                    │  Server  │
└────┬─────┘                    └────┬─────┘
     │                               │
     │  1. Connect                   │
     │──────────────────────────────►│
     │                               │
     │  2. initialize                │
     │──────────────────────────────►│
     │                               │
     │  3. initialize response       │
     │◄──────────────────────────────│
     │                               │
     │  4. tools/list               │
     │──────────────────────────────►│
     │                               │
     │  5. tools/list response      │
     │◄──────────────────────────────│
     │                               │
     │  6. resources/list           │
     │──────────────────────────────►│
     │                               │
     │  7. resources/list response  │
     │◄──────────────────────────────│
     │                               │
     │  8. prompts/list             │
     │──────────────────────────────►│
     │                               │
     │  9. prompts/list response    │
     │◄──────────────────────────────│
     │                               │
     │  10. tools/call (add)        │
     │──────────────────────────────►│
     │                               │
     │  11. tools/call response     │
     │◄──────────────────────────────│
     │                               │
```

---

## Part 4: Inspecting MCP Messages in Real-Time

### Method 1: Enable Debug Logging

Add debug logging to see all messages:

```typescript
// Add this to your server
import { logger } from './logger.js';

// Log all incoming messages
server.on('request', (request) => {
  logger.debug('Received request:', request);
});

// Log all responses
server.on('response', (response) => {
  logger.debug('Sending response:', response);
});
```

### Method 2: Use a Proxy to Log Messages

A simple proxy that logs all messages:

```typescript
#!/usr/bin/env node

/**
 * MCP Message Logger Proxy
 * Sits between client and server and logs all messages
 */

import { spawn } from 'child_process';
import readline from 'readline';

// Spawn the server
const server = spawn('node', ['dist/index.js']);
const rl = readline.createInterface({
  input: server.stdout,
  output: process.stdout
});

// Log all incoming messages (from server to client)
rl.on('line', (line) => {
  try {
    const msg = JSON.parse(line);
    console.error('\x1b[36m%s\x1b[0m', '📥 Server → Client:', JSON.stringify(msg, null, 2));
  } catch {
    console.error('\x1b[36m%s\x1b[0m', '📥 Server → Client (raw):', line);
  }
});

// Forward stdin to server
process.stdin.on('data', (data) => {
  const lines = data.toString().split('\n');
  for (const line of lines) {
    if (line.trim()) {
      try {
        const msg = JSON.parse(line);
        console.error('\x1b[33m%s\x1b[0m', '📤 Client → Server:', JSON.stringify(msg, null, 2));
      } catch {
        console.error('\x1b[33m%s\x1b[0m', '📤 Client → Server (raw):', line);
      }
      server.stdin.write(line + '\n');
    }
  }
});

console.error('🔍 MCP Proxy Started - Logging all messages');
```

### Method 3: Manual Inspection with a Simple Client

Create a client that prints all messages:

```typescript
#!/usr/bin/env node

/**
 * Debug Client that shows all messages
 */

import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import readline from 'readline';

async function debugClient() {
  const transport = new StdioClientTransport({
    command: 'node',
    args: ['dist/index.js']
  });

  await transport.start();

  // Log incoming messages
  for await (const message of transport.receive()) {
    console.log('\x1b[36m%s\x1b[0m', '📥 Received:', message);
  }

  // Log outgoing messages
  const originalSend = transport.send.bind(transport);
  transport.send = async (message: string) => {
    console.log('\x1b[33m%s\x1b[0m', '📤 Sending:', message);
    return originalSend(message);
  };

  // Interactive prompt
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  console.log('🔍 Debug Client Started');
  console.log('Type a JSON-RPC message to send:');

  rl.on('line', async (line) => {
    if (line.trim()) {
      try {
        await transport.send(line);
      } catch (error) {
        console.error('Error sending:', error);
      }
    }
  });
}

debugClient();
```

---

## Part 5: Common Error Codes

### JSON-RPC Error Codes

| Code | Name | Description |
|------|------|-------------|
| -32700 | Parse Error | Invalid JSON was received |
| -32600 | Invalid Request | The JSON sent is not a valid Request object |
| -32601 | Method Not Found | The method does not exist |
| -32602 | Invalid Params | Invalid method parameter(s) |
| -32603 | Internal Error | Internal JSON-RPC error |

### MCP-Specific Error Codes

| Code | Name | Description |
|------|------|-------------|
| -32001 | Tool Not Found | The requested tool was not found |
| -32002 | Resource Not Found | The requested resource was not found |
| -32003 | Prompt Not Found | The requested prompt was not found |
| -32004 | Tool Execution Error | Tool execution failed |
| -32005 | Resource Read Error | Resource read failed |
| -32006 | Prompt Execution Error | Prompt execution failed |
| -32007 | Transport Error | Transport error |
| -32008 | Connection Error | Connection error |
| -32009 | Authentication Error | Authentication failed |
| -32010 | Authorization Error | Authorization failed |

### Example Error Responses

**Tool Not Found:**
```json
{
  "jsonrpc": "2.0",
  "id": "call-1",
  "error": {
    "code": -32001,
    "message": "Tool not found: unknown_tool",
    "data": {
      "requestedTool": "unknown_tool",
      "availableTools": ["add", "subtract", "multiply", "divide"]
    }
  }
}
```

**Invalid Parameters:**
```json
{
  "jsonrpc": "2.0",
  "id": "call-1",
  "error": {
    "code": -32602,
    "message": "Invalid params",
    "data": {
      "validationErrors": [
        {
          "path": ["b"],
          "message": "Expected number, received string",
          "value": "not-a-number"
        }
      ]
    }
  }
}
```

**Internal Error:**
```json
{
  "jsonrpc": "2.0",
  "id": "call-1",
  "error": {
    "code": -32603,
    "message": "Internal error",
    "data": {
      "error": "Database connection failed",
      "stack": "Error: Database connection failed\n    at ..."
    }
  }
}
```

---

## Part 6: Debugging Common Issues

### Issue 1: "Parse Error" (-32700)

**Symptom:** The server receives invalid JSON.

**Common Causes:**
- Missing quotes around strings
- Trailing commas in objects or arrays
- Invalid escape sequences
- Binary data in the message

**Debugging:**
```typescript
function safeParse(message: string) {
  try {
    return JSON.parse(message);
  } catch (error) {
    console.error('❌ JSON Parse Error:');
    console.error('   Message:', message);
    console.error('   Error:', error);
    console.error('   Position:', error.message.match(/position (\d+)/)?.[1]);
    return null;
  }
}
```

### Issue 2: "Method Not Found" (-32601)

**Symptom:** The client calls a method that doesn't exist.

**Common Causes:**
- Typo in method name
- Method not registered on the server
- Using a different protocol version

**Debugging:**
```typescript
// On the server, log all incoming requests
server.on('request', (request) => {
  if (!this.hasMethod(request.method)) {
    console.error('❌ Method not found:', request.method);
    console.error('   Available methods:', this.getAvailableMethods());
  }
});
```

### Issue 3: "Invalid Params" (-32602)

**Symptom:** The client sends the wrong parameters.

**Common Causes:**
- Missing required parameters
- Incorrect parameter types
- Invalid parameter values

**Debugging:**
```typescript
function validateParams(params: any, schema: any) {
  const errors = [];
  
  // Check required fields
  for (const required of schema.required || []) {
    if (!(required in params)) {
      errors.push(`Missing required parameter: ${required}`);
    }
  }
  
  // Check types
  for (const [key, value] of Object.entries(params)) {
    const expectedType = schema.properties[key]?.type;
    if (expectedType && typeof value !== expectedType) {
      errors.push(`Parameter ${key} expected ${expectedType}, got ${typeof value}`);
    }
  }
  
  return errors;
}
```

### Issue 4: Timeout

**Symptom:** The client never receives a response.

**Common Causes:**
- Server is stuck processing
- Network issues
- The server crashed

**Debugging:**
```typescript
// Client-side timeout
const TIMEOUT_MS = 30000;

async function callWithTimeout(request: any) {
  const timeout = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Request timeout')), TIMEOUT_MS);
  });
  
  const response = this.send(request);
  return Promise.race([response, timeout]);
}
```

---

## Part 7: Protocol Version Compatibility

### Checking Protocol Version

When connecting, the client and server negotiate the protocol version:

**Client Request:**
```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05"
  }
}
```

**Server Response:**
```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "result": {
    "protocolVersion": "2024-11-05"
  }
}
```

**Server Responds with Error (if incompatible):**
```json
{
  "jsonrpc": "2.0",
  "id": "init-1",
  "error": {
    "code": -32000,
    "message": "Protocol version not supported",
    "data": {
      "requested": "2024-11-05",
      "supported": ["2024-10-01", "2024-09-01"]
    }
  }
}
```

---

## Part 8: Performance Considerations

### Message Size

Large messages can affect performance:

| Message Size | Impact |
|--------------|--------|
| < 1KB | Fast |
| 1-10KB | Moderate |
| 10-100KB | Slow |
| > 100KB | Very slow, consider pagination |

**Optimization Tip:** Use compression for large messages.

### Message Frequency

Too many messages can overwhelm the server:

| Messages/Second | Impact |
|-----------------|--------|
| < 10 | Minimal |
| 10-100 | Moderate |
| 100-1000 | High |
| > 1000 | Very high, consider batching |

**Optimization Tip:** Batch related operations.

---

## Part 9: Security Considerations

### Never Log Sensitive Data

```typescript
function sanitizeMessage(message: any): any {
  const sensitiveFields = ['password', 'token', 'apiKey', 'secret', 'authorization'];
  
  if (typeof message !== 'object' || message === null) {
    return message;
  }
  
  const sanitized = { ...message };
  
  for (const field of sensitiveFields) {
    if (field in sanitized) {
      sanitized[field] = '***REDACTED***';
    }
  }
  
  if (sanitized.params && typeof sanitized.params === 'object') {
    sanitized.params = sanitizeMessage(sanitized.params);
  }
  
  return sanitized;
}
```

### Authentication in Messages

MCP doesn't define authentication, but you can add it:

```json
{
  "jsonrpc": "2.0",
  "id": "call-1",
  "method": "tools/call",
  "params": {
    "name": "add",
    "arguments": { "a": 10, "b": 5 },
    "auth": {
      "type": "apiKey",
      "key": "mcp_1234567890abcdef"
    }
  }
}
```

Or use HTTP headers when using HTTP transport.

---

## Part 10: Summary

### Key Takeaways

1. **MCP uses JSON-RPC 2.0** — A simple, standardized protocol
2. **Messages are JSON objects** — Human-readable and easy to debug
3. **Three message types** — Requests, Responses, Notifications
4. **Three MCP categories** — Discovery, Invocation, Lifecycle
5. **Error handling is standardized** — Error codes and messages
6. **Debugging is straightforward** — Log messages, use proxies

### Quick Reference

| Concept | Format |
|---------|--------|
| Request | `{ "jsonrpc": "2.0", "id": "...", "method": "...", "params": {...} }` |
| Response | `{ "jsonrpc": "2.0", "id": "...", "result": {...} }` |
| Error | `{ "jsonrpc": "2.0", "id": "...", "error": { "code": ..., "message": "..." } }` |
| Notification | `{ "jsonrpc": "2.0", "method": "...", "params": {...} }` |

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

## Next Steps

Now that you understand MCP communication at the protocol level, you can:
1. Build custom transports
2. Debug complex issues
3. Create your own MCP clients
4. Add authentication and security
5. Build monitoring and observability

### Additional Resources

- [JSON-RPC 2.0 Specification](https://www.jsonrpc.org/specification)
- [MCP Protocol Specification](https://modelcontextprotocol.io)
- [MCP TypeScript SDK Source Code](https://github.com/modelcontextprotocol/typescript-sdk)

---

**[END OF PRIMER PART 3]**
