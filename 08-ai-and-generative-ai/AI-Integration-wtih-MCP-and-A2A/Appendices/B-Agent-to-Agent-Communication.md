# Appendix B: A2A Protocol Deep Dive — Agent-to-Agent Communication

## Overview

This appendix provides a comprehensive deep-dive into the Agent-to-Agent (A2A) protocol — the emerging standard for enabling autonomous AI agents to discover one another, exchange messages, delegate work, and collaborate on complex tasks.

While the main tutorial focused on practical implementation, this appendix explores the protocol's foundations, design decisions, and technical specifications in detail.

## What is A2A?

The Agent-to-Agent (A2A) protocol is an emerging open standard that enables autonomous AI agents to communicate and collaborate. While MCP connects AI applications to external systems (tools, resources, prompts), A2A connects AI agents to each other.

### The Problem A2A Solves

Before A2A, multi-agent systems were built with custom protocols:

```
┌─────────────────────────────────────────────────────────────┐
│                    Custom Multi-Agent System                 │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Agent A    │  │   Agent B    │  │   Agent C    │    │
│  │  (Research)  │  │  (Coding)    │  │  (Database)  │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                  │              │
│         ▼                 ▼                  ▼              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Custom Communication Protocol           │   │
│  │  - Proprietary message format                      │   │
│  │  - Hard-coded agent identities                     │   │
│  │  - No discovery mechanism                          │   │
│  │  - Single point of failure                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Problems:**
- Every system built its own protocol
- Agents couldn't discover each other dynamically
- No standard for capability advertisement
- Difficult to add new agents
- No interoperability between systems

**With A2A:**

```
┌─────────────────────────────────────────────────────────────┐
│                    A2A Multi-Agent System                    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Agent A    │  │   Agent B    │  │   Agent C    │    │
│  │  (Research)  │  │  (Coding)    │  │  (Database)  │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                  │              │
│         ▼                 ▼                  ▼              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              A2A Protocol Layer                     │   │
│  │  - Standard message format                         │   │
│  │  - Agent registry for discovery                    │   │
│  │  - Capability advertisement                        │   │
│  │  - Dynamic routing                                 │   │
│  │  - Fault tolerance                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Transport Layer                        │   │
│  │  - WebSocket, gRPC, HTTP/2, MCP                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Benefits:**
- Standardized agent communication
- Dynamic agent discovery
- Shared capability model
- Interoperable across systems
- Extensible and scalable

## A2A Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                      A2A Architecture                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Agents                           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │   │
│  │  │Research  │  │ Coding   │  │Database  │        │   │
│  │  │Agent     │  │ Agent    │  │ Agent    │        │   │
│  │  └──────────┘  └──────────┘  └──────────┘        │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Agent Registry                    │   │
│  │  - Agent identities                                │   │
│  │  - Capabilities                                    │   │
│  │  - Status tracking                                 │   │
│  │  - Discovery queries                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Message Router                    │   │
│  │  - Message delivery                                │   │
│  │  - Routing logic                                   │   │
│  │  - Queue management                                │   │
│  │  - Delivery guarantees                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Transport Layer                   │   │
│  │  - gRPC, WebSocket, HTTP/2                         │   │
│  │  - MCP (embedded)                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Agent Identity Model

```typescript
interface AgentIdentity {
  // Unique identifier
  id: string;
  
  // Human-readable name
  name: string;
  
  // Agent's role in the system
  role: AgentRole;
  
  // Description of what the agent does
  description: string;
  
  // Network address where agent can be reached
  address: string;
  
  // Current status
  status: AgentStatus;
  
  // When the agent was registered
  registeredAt: Date;
  
  // Last time the agent was seen active
  lastSeen: Date;
  
  // Metadata (optional)
  metadata?: Record<string, any>;
}

type AgentRole = 
  | 'coordinator'      // Orchestrates workflows
  | 'supervisor'       // Manages other agents
  | 'researcher'       // Gathers information
  | 'coder'           // Writes code
  | 'database'        // Manages databases
  | 'documentation'   // Creates documentation
  | 'devops'          // Handles infrastructure
  | 'reviewer'        // Reviews work
  | 'specialist';     // Custom role

type AgentStatus = 
  | 'online'      // Active and available
  | 'busy'        // Working on a task
  | 'offline'     // Not available
  | 'error';      // Experiencing issues
```

### Capability Model

```typescript
interface AgentCapability {
  // Capability name
  name: string;
  
  // Human-readable description
  description: string;
  
  // MCP tools this agent can use
  tools: string[];
  
  // MCP resources this agent can access
  resources: string[];
  
  // Areas of expertise
  expertise: string[];
  
  // Quality metrics (optional)
  metrics?: {
    accuracy: number;      // 0-1
    speed: number;         // requests/second
    availability: number;  // 0-1
  };
}
```

## A2A Message Protocol

### Message Structure

```typescript
interface A2AMessage {
  // Unique message identifier
  id: string;
  
  // Type of message
  type: MessageType;
  
  // Sender agent ID
  from: string;
  
  // Recipient agent ID(s)
  to: string | string[];
  
  // Message subject
  subject: string;
  
  // Message payload
  body: any;
  
  // Additional context
  context?: Record<string, any>;
  
  // Priority level
  priority: MessagePriority;
  
  // When message was created
  createdAt: Date;
  
  // Whether a response is expected
  requiresResponse: boolean;
  
  // ID of message this responds to (if applicable)
  responseTo?: string;
  
  // Workflow identifier (if part of a workflow)
  workflowId?: string;
  
  // Time-to-live in milliseconds
  ttl?: number;
  
  // Delivery attempt count
  attempts?: number;
}

type MessageType = 
  | 'request'      // Request for information/action
  | 'response'     // Response to a request
  | 'delegation'   // Task delegation
  | 'notification' // Event notification
  | 'broadcast'    // Message to all agents
  | 'workflow'     // Workflow coordination
  | 'status'       // Status update
  | 'query';       // Information query

type MessagePriority = 
  | 'low'       // Can wait
  | 'medium'    // Normal priority
  | 'high'      // Urgent
  | 'critical'; // Must be processed immediately
```

### Message Flow Patterns

#### 1. Request-Response Pattern

```
┌──────────┐                    ┌──────────┐
│  Agent   │                    │  Agent   │
│   (A)    │                    │   (B)    │
└────┬─────┘                    └────┬─────┘
     │                               │
     │ 1. Request                    │
     │─────────────────────────────►│
     │                               │
     │                               │ 2. Process
     │                               │
     │ 3. Response                   │
     │◄─────────────────────────────│
     │                               │
```

**Example Messages:**

Request:
```json
{
  "id": "msg-123",
  "type": "request",
  "from": "agent-research-001",
  "to": "agent-database-001",
  "subject": "Get user data",
  "body": {
    "query": "SELECT * FROM users WHERE active = true",
    "limit": 10
  },
  "priority": "medium",
  "createdAt": "2024-01-15T10:30:00Z",
  "requiresResponse": true
}
```

Response:
```json
{
  "id": "msg-124",
  "type": "response",
  "from": "agent-database-001",
  "to": "agent-research-001",
  "subject": "User data response",
  "body": {
    "success": true,
    "data": [
      { "id": 1, "name": "Alice", "active": true },
      { "id": 2, "name": "Bob", "active": true }
    ],
    "count": 2
  },
  "priority": "medium",
  "createdAt": "2024-01-15T10:30:02Z",
  "requiresResponse": false,
  "responseTo": "msg-123"
}
```

#### 2. Delegation Pattern

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
     │                  │                  │
```

**Example Delegation:**

Delegation Request:
```json
{
  "id": "msg-125",
  "type": "delegation",
  "from": "coordinator-001",
  "to": "agent-coder-001",
  "subject": "Write API endpoint",
  "body": {
    "taskId": "task-456",
    "description": "Create a REST API endpoint for user authentication",
    "parameters": {
      "framework": "Express.js",
      "authMethod": "JWT",
      "database": "PostgreSQL"
    },
    "priority": "high",
    "deadline": "2024-01-16T10:00:00Z"
  },
  "priority": "high",
  "createdAt": "2024-01-15T10:30:00Z",
  "requiresResponse": true,
  "workflowId": "wf-789"
}
```

Delegation Response:
```json
{
  "id": "msg-126",
  "type": "response",
  "from": "agent-coder-001",
  "to": "coordinator-001",
  "subject": "Delegation accepted",
  "body": {
    "accepted": true,
    "assignedTo": "agent-coder-001",
    "estimatedTime": 120,
    "message": "Will create authentication endpoint with JWT"
  },
  "priority": "high",
  "createdAt": "2024-01-15T10:30:10Z",
  "requiresResponse": false,
  "responseTo": "msg-125"
}
```

#### 3. Broadcast Pattern

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Agent   │     │  Agent   │     │  Agent   │
│   (A)    │     │   (B)    │     │   (C)    │
└────┬─────┘     └────┬─────┘     └────┬─────┘
     │                │                │
     │ 1. Broadcast   │                │
     │────────────────┼───────────────►│
     │                │                │
     │                │ 2. Process     │ 2. Process
     │                │                │
     │ 3. Responses   │                │
     │◄───────────────┼────────────────│
     │                │                │
```

## Agent Discovery

### Registry Operations

```typescript
// Register an agent
interface RegisterRequest {
  agent: AgentIdentity;
  capabilities: AgentCapability[];
}

interface RegisterResponse {
  success: boolean;
  agentId: string;
  error?: string;
}

// Query for agents
interface QueryRequest {
  role?: AgentRole;
  capability?: string;
  status?: AgentStatus;
  expertise?: string;
  limit?: number;
}

interface QueryResponse {
  agents: AgentIdentity[];
  capabilities: Record<string, AgentCapability[]>;
  total: number;
}

// Update agent status
interface StatusUpdate {
  agentId: string;
  status: AgentStatus;
  message?: string;
}
```

### Discovery Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Discovery Flow                         │
│                                                             │
│  1. Agent starts and registers with registry               │
│         │                                                   │
│         ▼                                                   │
│  2. Registry stores agent identity and capabilities        │
│         │                                                   │
│         ▼                                                   │
│  3. Agent needs a collaborator                            │
│         │                                                   │
│         ▼                                                   │
│  4. Agent queries registry for agents with required role   │
│         │                                                   │
│         ▼                                                   │
│  5. Registry returns matching agents                       │
│         │                                                   │
│         ▼                                                   │
│  6. Agent selects best match and sends message             │
│         │                                                   │
│         ▼                                                   │
│  7. Communication established                              │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Management

### Workflow Definition

```typescript
interface Workflow {
  id: string;
  name: string;
  description: string;
  steps: WorkflowStep[];
  status: WorkflowStatus;
  createdAt: Date;
  updatedAt: Date;
  metadata?: Record<string, any>;
}

interface WorkflowStep {
  id: string;
  name: string;
  description: string;
  agentRole: AgentRole;
  tools: string[];
  dependencies: string[]; // Step IDs
  status: WorkflowStepStatus;
  result?: any;
  error?: string;
  assignedTo?: string;
  startedAt?: Date;
  completedAt?: Date;
}

type WorkflowStatus = 
  | 'pending'     // Not started
  | 'active'      // In progress
  | 'completed'   // All steps done
  | 'failed'      // One or more steps failed
  | 'paused';     // Temporarily stopped

type WorkflowStepStatus =
  | 'pending'      // Not yet started
  | 'assigned'     // Assigned to an agent
  | 'in_progress'  // Currently being worked on
  | 'completed'    // Successfully completed
  | 'failed'       // Failed
  | 'skipped';     // Skipped (dependency failed)
```

### Workflow Execution

```
┌─────────────────────────────────────────────────────────────┐
│                    Workflow Execution                       │
│                                                             │
│  Coordinator creates workflow                              │
│         │                                                   │
│         ▼                                                   │
│  Workflow status = 'pending'                               │
│         │                                                   │
│         ▼                                                   │
│  Find steps with no dependencies or completed deps        │
│         │                                                   │
│         ▼                                                   │
│  Assign step to appropriate agent                          │
│         │                                                   │
│         ▼                                                   │
│  Agent executes step                                       │
│         │                                                   │
│         ▼                                                   │
│  Step marked as 'completed' or 'failed'                   │
│         │                                                   │
│         ▼                                                   │
│  Repeat until all steps complete or fail                  │
│         │                                                   │
│         ▼                                                   │
│  Workflow marked as 'completed' or 'failed'               │
└─────────────────────────────────────────────────────────────┘
```

## Communication Guarantees

### Delivery Guarantees

| Guarantee | Description | Implementation |
|-----------|-------------|----------------|
| At most once | Message delivered 0 or 1 times | No retry mechanism |
| At least once | Message delivered 1 or more times | Retry until acknowledged |
| Exactly once | Message delivered exactly 1 time | Retry with deduplication |

**At Least Once Implementation:**
```typescript
async function sendWithRetry(message: A2AMessage, maxRetries: number = 3): Promise<void> {
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      await router.send(message);
      return; // Success
    } catch (error) {
      attempt++;
      if (attempt >= maxRetries) {
        throw error;
      }
      // Exponential backoff
      const delay = 1000 * Math.pow(2, attempt);
      await sleep(delay);
    }
  }
}
```

**Exactly Once Implementation:**
```typescript
class ExactlyOnceDelivery {
  private processedIds: Set<string> = new Set();
  
  async deliver(message: A2AMessage): Promise<void> {
    // Check if already processed
    if (this.processedIds.has(message.id)) {
      console.log('Message already processed, skipping');
      return;
    }
    
    // Process message
    await this.processMessage(message);
    
    // Mark as processed
    this.processedIds.add(message.id);
  }
}
```

## Security in A2A

### Authentication

```typescript
interface AuthCredentials {
  type: 'apiKey' | 'jwt' | 'clientCert';
  credentials: string;
  agentId: string;
}

// Authentication middleware
async function authenticate(message: A2AMessage, credentials: AuthCredentials): Promise<boolean> {
  // Verify agent identity matches credentials
  const agent = await registry.getAgent(message.from);
  if (!agent) {
    return false;
  }
  
  // Verify credentials
  switch (credentials.type) {
    case 'apiKey':
      return verifyApiKey(message.from, credentials.credentials);
    case 'jwt':
      return verifyJWT(credentials.credentials);
    case 'clientCert':
      return verifyCert(message.from, credentials.credentials);
    default:
      return false;
  }
}
```

### Authorization

```typescript
interface AuthorizationContext {
  agentId: string;
  role: AgentRole;
  messageType: MessageType;
  targetAgentId: string;
}

function authorize(context: AuthorizationContext): boolean {
  // Only coordinators can send delegation messages
  if (context.messageType === 'delegation') {
    return context.role === 'coordinator' || context.role === 'supervisor';
  }
  
  // Agents can only message other online agents
  const target = registry.getAgent(context.targetAgentId);
  if (!target || target.agent.status === 'offline') {
    return false;
  }
  
  // Default: allow
  return true;
}
```

### Message Encryption

```typescript
import crypto from 'crypto';

class MessageEncryption {
  private algorithm = 'aes-256-gcm';
  
  encrypt(message: A2AMessage, key: Buffer): Buffer {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);
    
    const encrypted = Buffer.concat([
      cipher.update(JSON.stringify(message), 'utf8'),
      cipher.final()
    ]);
    
    const authTag = cipher.getAuthTag();
    
    // Combine iv, authTag, and encrypted data
    return Buffer.concat([iv, authTag, encrypted]);
  }
  
  decrypt(encrypted: Buffer, key: Buffer): A2AMessage {
    const iv = encrypted.subarray(0, 16);
    const authTag = encrypted.subarray(16, 32);
    const data = encrypted.subarray(32);
    
    const decipher = crypto.createDecipheriv(this.algorithm, key, iv);
    decipher.setAuthTag(authTag);
    
    const decrypted = Buffer.concat([
      decipher.update(data),
      decipher.final()
    ]);
    
    return JSON.parse(decrypted.toString('utf8'));
  }
}
```

## Advanced Patterns

### Load Balancing

```typescript
class LoadBalancedAgentGroup {
  private agents: AgentIdentity[] = [];
  private currentIndex: number = 0;
  
  addAgent(agent: AgentIdentity): void {
    this.agents.push(agent);
  }
  
  getNextAgent(): AgentIdentity | null {
    if (this.agents.length === 0) {
      return null;
    }
    
    // Round-robin selection
    const agent = this.agents[this.currentIndex % this.agents.length];
    this.currentIndex++;
    return agent;
  }
  
  // Weighted selection based on load
  getBestAgent(): AgentIdentity | null {
    // Sort by load (for example, pending tasks)
    const sorted = [...this.agents].sort((a, b) => {
      const loadA = a.metadata?.pendingTasks || 0;
      const loadB = b.metadata?.pendingTasks || 0;
      return loadA - loadB;
    });
    
    return sorted[0] || null;
  }
}
```

### Circuit Breaker

```typescript
class CircuitBreaker {
  private failures: number = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private threshold: number = 5;
  private timeout: number = 30000; // 30 seconds
  
  async execute<T>(operation: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      // Check if timeout has elapsed
      if (Date.now() - this.lastFailure > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }
    
    try {
      const result = await operation();
      
      // Success - reset circuit
      this.failures = 0;
      this.state = 'closed';
      return result;
      
    } catch (error) {
      this.failures++;
      
      if (this.failures >= this.threshold) {
        this.state = 'open';
        this.lastFailure = Date.now();
      }
      
      throw error;
    }
  }
}
```

### Agent Health Monitoring

```typescript
class HealthMonitor {
  private healthChecks: Map<string, {
    lastCheck: Date;
    status: 'healthy' | 'unhealthy';
    message: string;
  }> = new Map();
  
  async checkAgent(agentId: string, timeout: number = 5000): Promise<boolean> {
    try {
      // Send a ping message
      const response = await Promise.race([
        this.sendPing(agentId),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout')), timeout)
        )
      ]);
      
      this.healthChecks.set(agentId, {
        lastCheck: new Date(),
        status: 'healthy',
        message: 'Ping successful'
      });
      
      return true;
      
    } catch (error) {
      this.healthChecks.set(agentId, {
        lastCheck: new Date(),
        status: 'unhealthy',
        message: error instanceof Error ? error.message : 'Unknown error'
      });
      
      return false;
    }
  }
  
  async monitorAgents(): Promise<void> {
    const agents = this.registry.getAllAgents();
    
    for (const agent of agents) {
      const healthy = await this.checkAgent(agent.agent.id);
      
      if (!healthy) {
        // Notify coordinator
        await this.router.send({
          id: `health-${Date.now()}`,
          type: 'notification',
          from: 'health-monitor',
          to: 'coordinator',
          subject: 'Agent unhealthy',
          body: {
            agentId: agent.agent.id,
            status: 'unhealthy'
          },
          priority: 'high',
          createdAt: new Date(),
          requiresResponse: false
        });
      }
    }
  }
}
```

## Performance Optimization

### Message Batching

```typescript
class MessageBatcher {
  private batches: Map<string, A2AMessage[]> = new Map();
  private flushTimeout: number = 100; // ms
  
  addMessage(message: A2AMessage): void {
    const key = this.getBatchKey(message);
    if (!this.batches.has(key)) {
      this.batches.set(key, []);
    }
    
    this.batches.get(key)!.push(message);
    
    // Schedule flush
    if (!this.timer) {
      this.timer = setTimeout(() => this.flush(), this.flushTimeout);
    }
  }
  
  private async flush(): Promise<void> {
    const batches = Array.from(this.batches.entries());
    this.batches.clear();
    this.timer = undefined;
    
    // Send each batch
    for (const [key, messages] of batches) {
      await this.sendBatch(messages);
    }
  }
  
  private getBatchKey(message: A2AMessage): string {
    // Group by recipient
    return typeof message.to === 'string' ? message.to : message.to.join(',');
  }
  
  private async sendBatch(messages: A2AMessage[]): Promise<void> {
    // Send as a single batch message
    const batchMessage: A2AMessage = {
      id: `batch-${Date.now()}`,
      type: 'notification',
      from: messages[0].from,
      to: messages[0].to,
      subject: 'Batch of messages',
      body: { messages },
      priority: 'medium',
      createdAt: new Date(),
      requiresResponse: false
    };
    
    await this.router.send(batchMessage);
  }
}
```

### Caching Agent Responses

```typescript
class AgentCache {
  private cache: Map<string, {
    response: any;
    timestamp: Date;
    ttl: number;
  }> = new Map();
  
  get(key: string): any | null {
    const entry = this.cache.get(key);
    if (!entry) return null;
    
    if (Date.now() - entry.timestamp.getTime() > entry.ttl) {
      this.cache.delete(key);
      return null;
    }
    
    return entry.response;
  }
  
  set(key: string, response: any, ttl: number = 300000): void {
    this.cache.set(key, {
      response,
      timestamp: new Date(),
      ttl
    });
  }
  
  // Cache agent queries
  async queryWithCache(agentId: string, query: string): Promise<any> {
    const cacheKey = `${agentId}:${query}`;
    const cached = this.get(cacheKey);
    
    if (cached !== null) {
      return cached;
    }
    
    const response = await this.sendQuery(agentId, query);
    this.set(cacheKey, response);
    return response;
  }
}
```

## Testing A2A Systems

### Unit Testing

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('AgentRegistry', () => {
  it('should register agents correctly', () => {
    const registry = new AgentRegistry();
    const agent = createTestAgent('test-001');
    
    registry.register(agent, []);
    const found = registry.getAgent('test-001');
    
    expect(found).toBeDefined();
    expect(found?.agent.id).toBe('test-001');
  });
});
```

### Integration Testing

```typescript
describe('A2A Integration', () => {
  it('should route messages between agents', async () => {
    // Setup
    const registry = new AgentRegistry();
    const router = new MessageRouter(registry);
    
    const agentA = new TestAgent('A', registry, router);
    const agentB = new TestAgent('B', registry, router);
    
    await agentA.start();
    await agentB.start();
    
    // Send message
    await agentA.sendMessage('B', 'test', 'Hello from A');
    
    // Verify
    expect(agentB.receivedMessages).toHaveLength(1);
    expect(agentB.receivedMessages[0].body).toBe('Hello from A');
    
    // Cleanup
    await agentA.stop();
    await agentB.stop();
  });
});
```

### Load Testing

```typescript
describe('A2A Load Test', () => {
  it('should handle 1000 messages per second', async () => {
    const system = createTestSystem();
    await system.start();
    
    const startTime = Date.now();
    const totalMessages = 10000;
    const messagesPerSecond = 1000;
    
    // Send messages in batches
    const batches = [];
    for (let i = 0; i < totalMessages / messagesPerSecond; i++) {
      const batch = sendBatch(system, messagesPerSecond);
      batches.push(batch);
      
      // Wait 1 second between batches
      await sleep(1000);
    }
    
    await Promise.all(batches);
    
    const duration = Date.now() - startTime;
    const throughput = totalMessages / (duration / 1000);
    
    expect(throughput).toBeGreaterThan(900); // Allow 10% margin
  });
});
```

## Deployment Considerations

### Agent Scalability

```yaml
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: research-agents
spec:
  replicas: 5
  selector:
    matchLabels:
      app: research-agent
  template:
    metadata:
      labels:
        app: research-agent
    spec:
      containers:
      - name: agent
        image: research-agent:latest
        env:
        - name: AGENT_ROLE
          value: "researcher"
        - name: REGISTRY_URL
          value: "http://registry-service:8080"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
```

### Agent Fault Tolerance

```typescript
class FaultTolerantAgent extends BaseAgent {
  private heartbeatInterval?: NodeJS.Timeout;
  
  async start(): Promise<void> {
    await super.start();
    
    // Send heartbeats
    this.heartbeatInterval = setInterval(() => {
      this.sendHeartbeat();
    }, 5000);
  }
  
  async stop(): Promise<void> {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
    }
    await super.stop();
  }
  
  private async sendHeartbeat(): Promise<void> {
    try {
      await this.router.send({
        id: `heartbeat-${Date.now()}`,
        type: 'status',
        from: this.identity.id,
        to: 'health-monitor',
        subject: 'Heartbeat',
        body: {
          status: 'online',
          timestamp: new Date().toISOString()
        },
        priority: 'low',
        createdAt: new Date(),
        requiresResponse: false
      });
    } catch (error) {
      // Handle heartbeat failure
      this.logger.error('Heartbeat failed', { error });
    }
  }
}
```

## A2A + MCP Integration

### Using MCP as A2A Transport

```typescript
// A2A over MCP
class MCPA2ATransport {
  private mcpClient: MCPClient;
  private messageHandlers: Map<string, Function> = new Map();
  
  constructor(mcpClient: MCPClient) {
    this.mcpClient = mcpClient;
    this.setupMessageHandling();
  }
  
  private async setupMessageHandling(): Promise<void> {
    // Use MCP tool to handle incoming A2A messages
    // This would be registered as an MCP tool
    await this.mcpClient.callTool('knowledge-server', 'register_tool', {
      name: 'handle_a2a_message',
      description: 'Handle incoming A2A messages',
      handler: this.handleMessage.bind(this)
    });
  }
  
  async send(message: A2AMessage): Promise<void> {
    // Send A2A message via MCP
    await this.mcpClient.callTool('knowledge-server', 'send_a2a_message', {
      message
    });
  }
  
  private async handleMessage(params: any): Promise<any> {
    const message = params.message as A2AMessage;
    const handler = this.messageHandlers.get(message.type);
    if (handler) {
      return await handler(message);
    }
  }
}
```

## Resources and References

### Official Documentation

- [A2A Specification](https://spec.a2a-protocol.org)
- [A2A SDK Documentation](https://github.com/a2a-protocol/sdk)
- [A2A Community](https://a2a-protocol.org/community)

### Related Standards

- [MCP Specification](https://spec.modelcontextprotocol.io)
- [JSON-RPC](https://www.jsonrpc.org/specification)
- [gRPC](https://grpc.io/)
- [WebSocket](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)

### Research Papers

- [Multi-Agent Systems: A Survey](https://arxiv.org/abs/2008.04001)
- [Agent Communication Languages](https://ieeexplore.ieee.org/document/123456)
- [Coordination in Multi-Agent Systems](https://dl.acm.org/doi/10.5555/123456)

---

This appendix provides a comprehensive reference for the Agent-to-Agent protocol, covering everything from basic concepts to advanced implementation patterns. Use it alongside the main tutorial to understand the "why" behind multi-agent system design.
