# Part 8: Agent-to-Agent (A2A) Collaboration — Building a Team of Specialized Agents

## The Target

In this part, we're building a **multi-agent system** where specialized AI agents collaborate using Agent-to-Agent (A2A) communication. We'll create:

- **A2A Protocol Layer** — Message routing, discovery, and coordination
- **Specialized Agents** — Research, Coding, Database, Documentation, and DevOps agents
- **Agent Registry** — Discovery and capability advertisement
- **Task Delegation** — Agents assigning work to each other
- **Collaborative Workflows** — Multiple agents working on a shared goal

This transforms our system from a single autonomous agent into a **team of AI collaborators** that can tackle complex, multi-faceted problems.

## The Concept

### From Single Agent to Agent Team

Think of the difference between a single researcher and a research team:

- **Single Agent** (Part 7): One person doing all the work
- **Agent Team** (This Part): Specialists working together

Each agent has:
1. **Expertise** — Specific capabilities and knowledge
2. **Identity** — Unique name and role
3. **Communication** — Can send and receive messages
4. **Autonomy** — Makes decisions about its work
5. **Collaboration** — Works with other agents

### A2A Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Multi-Agent System                           │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    A2A Protocol Layer                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │  │
│  │  │ Message  │  │ Router   │  │ Registry │  │ Workflow │ │  │
│  │  │ Handler  │  │          │  │          │  │ Manager  │ │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Research   │  │    Coding    │  │   Database   │           │
│  │    Agent     │◄─┼──►  Agent    │◄─┼──►  Agent    │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│  ┌──────────────┐  ┌──────────────┐                              │
│  │Documentation │  │   DevOps     │                              │
│  │    Agent     │◄─┼──►  Agent    │                              │
│  └──────────────┘  └──────────────┘                              │
│                              │                                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    MCP Protocol Layer                      │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │  │
│  │  │Knowledge │  │Database  │  │  GitHub  │  │   REST   │ │  │
│  │  │ Server   │  │ Servers  │  │ Adapter  │  │ Adapter  │ │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### A2A Communication Patterns

1. **Request-Response** — Agent A asks Agent B for something
2. **Broadcast** — Agent sends message to all agents
3. **Delegation** — Agent assigns a task to another agent
4. **Notification** — Agent informs others of an event
5. **Collaboration** — Multiple agents work on shared task

## The Implementation

### Step 1: Project Setup

```bash
cd ai-integration-javascript/a2a-protocol
mkdir -p a2a-library
cd a2a-library
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk openai zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/tsconfig.json`

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

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/.env.example`

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-4-turbo-preview

# A2A Configuration
A2A_AGENT_NAME=coordinator
A2A_AGENT_ROLE=coordinator
A2A_REGISTRY_PATH=./agent-registry.json

# MCP Servers
MCP_KNOWLEDGE_SERVER_PATH=../../mcp-protocol/servers/knowledge-server/dist/index.js
MCP_DATABASE_SERVER_PATH=../../mcp-protocol/servers/database-server/dist/index.js

# Logging
LOG_LEVEL=info
```

### Step 2: Create A2A Types

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/types.ts`

```typescript
/**
 * A2A Protocol Type Definitions
 * Defines the message formats and agent metadata for agent-to-agent communication
 */

/**
 * Agent identity and metadata
 */
export interface AgentIdentity {
  id: string;
  name: string;
  role: AgentRole;
  description: string;
  capabilities: AgentCapability[];
  status: AgentStatus;
  address: string; // MCP server address or identifier
  registeredAt: Date;
  lastSeen: Date;
}

/**
 * Agent roles in the system
 */
export type AgentRole = 
  | 'coordinator'      // Orchestrates multi-agent workflows
  | 'researcher'       // Gathers and analyzes information
  | 'coder'           // Writes and reviews code
  | 'database'        // Manages database operations
  | 'documentation'   // Creates and maintains documentation
  | 'devops'          // Handles deployment and infrastructure
  | 'reviewer'        // Reviews work from other agents
  | 'specialist';     // Custom role

/**
 * Agent capabilities
 */
export interface AgentCapability {
  name: string;
  description: string;
  tools: string[]; // MCP tool names this agent can use
  resources: string[]; // MCP resources this agent can access
  expertise: string[]; // Areas of expertise
}

/**
 * Agent status
 */
export type AgentStatus = 'online' | 'busy' | 'offline' | 'error';

/**
 * A2A Message
 */
export interface A2AMessage {
  id: string;
  type: MessageType;
  from: string; // Agent ID
  to: string | string[]; // Agent ID(s)
  subject: string;
  body: any; // Message payload
  context?: Record<string, any>;
  priority: MessagePriority;
  createdAt: Date;
  requiresResponse: boolean;
  responseTo?: string; // ID of message this responds to
  workflowId?: string; // Shared workflow identifier
}

/**
 * Message types
 */
export type MessageType = 
  | 'request'      // Request for information or action
  | 'response'     // Response to a request
  | 'delegation'   // Delegating a task to another agent
  | 'notification' // Notification of an event
  | 'broadcast'    // Message to all agents
  | 'workflow'     // Workflow coordination message
  | 'status'       // Status update
  | 'query';       // Information query

/**
 * Message priority
 */
export type MessagePriority = 'low' | 'medium' | 'high' | 'critical';

/**
 * Workflow definition
 */
export interface Workflow {
  id: string;
  name: string;
  description: string;
  steps: WorkflowStep[];
  status: WorkflowStatus;
  createdAt: Date;
  updatedAt: Date;
  metadata?: Record<string, any>;
}

/**
 * Workflow step
 */
export interface WorkflowStep {
  id: string;
  name: string;
  description: string;
  agentRole: AgentRole; // Which agent should execute this step
  tools: string[]; // Required tools
  dependencies: string[]; // Step IDs that must complete first
  status: WorkflowStepStatus;
  result?: any;
  error?: string;
  assignedTo?: string; // Agent ID
  startedAt?: Date;
  completedAt?: Date;
}

/**
 * Workflow status
 */
export type WorkflowStatus = 'pending' | 'active' | 'completed' | 'failed' | 'paused';

/**
 * Workflow step status
 */
export type WorkflowStepStatus = 'pending' | 'assigned' | 'in_progress' | 'completed' | 'failed' | 'skipped';

/**
 * Agent capability query
 */
export interface CapabilityQuery {
  role?: AgentRole;
  tool?: string;
  expertise?: string;
  status?: AgentStatus;
}

/**
 * Task delegation request
 */
export interface DelegationRequest {
  taskId: string;
  description: string;
  targetRole: AgentRole;
  parameters: Record<string, any>;
  priority: MessagePriority;
  requiredTools?: string[];
  deadline?: Date;
}

/**
 * Task delegation response
 */
export interface DelegationResponse {
  accepted: boolean;
  assignedTo?: string;
  estimatedTime?: number;
  message?: string;
}

/**
 * Agent registry entry
 */
export interface RegistryEntry {
  agent: AgentIdentity;
  capabilities: AgentCapability[];
  registeredAt: Date;
  lastUpdate: Date;
}
```

### Step 3: Create the Agent Registry

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/registry.ts`

```typescript
import { 
  AgentIdentity, 
  AgentCapability, 
  AgentStatus, 
  CapabilityQuery,
  RegistryEntry 
} from './types.js';
import { createModuleLogger } from './logger.js';
import fs from 'fs/promises';
import path from 'path';

const logger = createModuleLogger('agent-registry');

/**
 * Agent Registry
 * Manages agent discovery and capability advertisement
 */
export class AgentRegistry {
  private agents: Map<string, RegistryEntry> = new Map();
  private registryPath: string;

  constructor(registryPath?: string) {
    this.registryPath = registryPath || process.env.A2A_REGISTRY_PATH || './agent-registry.json';
    logger.info('Agent Registry initialized', { registryPath: this.registryPath });
  }

  /**
   * Register an agent
   */
  async register(agent: AgentIdentity, capabilities: AgentCapability[]): Promise<void> {
    logger.info('Registering agent', { agentId: agent.id, role: agent.role });

    const entry: RegistryEntry = {
      agent: {
        ...agent,
        status: 'online',
        registeredAt: new Date(),
        lastSeen: new Date()
      },
      capabilities,
      registeredAt: new Date(),
      lastUpdate: new Date()
    };

    this.agents.set(agent.id, entry);
    await this.persist();

    logger.info('Agent registered successfully', { agentId: agent.id });
  }

  /**
   * Unregister an agent
   */
  async unregister(agentId: string): Promise<void> {
    logger.info('Unregistering agent', { agentId });
    
    this.agents.delete(agentId);
    await this.persist();

    logger.info('Agent unregistered', { agentId });
  }

  /**
   * Update agent status
   */
  async updateStatus(agentId: string, status: AgentStatus): Promise<void> {
    const entry = this.agents.get(agentId);
    if (!entry) {
      throw new Error(`Agent ${agentId} not found`);
    }

    entry.agent.status = status;
    entry.agent.lastSeen = new Date();
    entry.lastUpdate = new Date();

    await this.persist();
    logger.debug('Agent status updated', { agentId, status });
  }

  /**
   * Update agent capabilities
   */
  async updateCapabilities(agentId: string, capabilities: AgentCapability[]): Promise<void> {
    const entry = this.agents.get(agentId);
    if (!entry) {
      throw new Error(`Agent ${agentId} not found`);
    }

    entry.capabilities = capabilities;
    entry.lastUpdate = new Date();

    await this.persist();
    logger.debug('Agent capabilities updated', { agentId, capabilityCount: capabilities.length });
  }

  /**
   * Get all registered agents
   */
  getAllAgents(): RegistryEntry[] {
    return Array.from(this.agents.values());
  }

  /**
   * Get a specific agent by ID
   */
  getAgent(agentId: string): RegistryEntry | undefined {
    return this.agents.get(agentId);
  }

  /**
   * Find agents matching a capability query
   */
  findAgents(query: CapabilityQuery): RegistryEntry[] {
    const results = Array.from(this.agents.values()).filter(entry => {
      const agent = entry.agent;

      // Filter by role
      if (query.role && agent.role !== query.role) {
        return false;
      }

      // Filter by status
      if (query.status && agent.status !== query.status) {
        return false;
      }

      // Filter by tool
      if (query.tool) {
        const hasTool = entry.capabilities.some(cap => 
          cap.tools.some(tool => tool.toLowerCase().includes(query.tool!.toLowerCase()))
        );
        if (!hasTool) {
          return false;
        }
      }

      // Filter by expertise
      if (query.expertise) {
        const hasExpertise = entry.capabilities.some(cap =>
          cap.expertise.some(exp => exp.toLowerCase().includes(query.expertise!.toLowerCase()))
        );
        if (!hasExpertise) {
          return false;
        }
      }

      return true;
    });

    logger.debug('Agent search completed', { 
      query, 
      results: results.length 
    });

    return results;
  }

  /**
   * Find the best agent for a task
   */
  findBestAgentForTask(
    requiredRole?: AgentRole,
    requiredTools?: string[],
    expertise?: string
  ): RegistryEntry | undefined {
    const candidates = Array.from(this.agents.values()).filter(entry => {
      // Must be online
      if (entry.agent.status !== 'online') {
        return false;
      }

      // Check role
      if (requiredRole && entry.agent.role !== requiredRole) {
        return false;
      }

      // Check tools
      if (requiredTools && requiredTools.length > 0) {
        const hasAllTools = requiredTools.every(tool =>
          entry.capabilities.some(cap => cap.tools.includes(tool))
        );
        if (!hasAllTools) {
          return false;
        }
      }

      // Check expertise
      if (expertise) {
        const hasExpertise = entry.capabilities.some(cap =>
          cap.expertise.some(exp => exp.toLowerCase().includes(expertise.toLowerCase()))
        );
        if (!hasExpertise) {
          return false;
        }
      }

      return true;
    });

    // Sort by capability score (more capabilities = better match)
    candidates.sort((a, b) => {
      const scoreA = a.capabilities.reduce((sum, cap) => sum + cap.tools.length + cap.expertise.length, 0);
      const scoreB = b.capabilities.reduce((sum, cap) => sum + cap.tools.length + cap.expertise.length, 0);
      return scoreB - scoreA;
    });

    const best = candidates[0];
    if (best) {
      logger.debug('Best agent found for task', {
        agentId: best.agent.id,
        role: best.agent.role,
        score: best.capabilities.reduce((sum, cap) => sum + cap.tools.length + cap.expertise.length, 0)
      });
    }

    return best;
  }

  /**
   * Persist registry to disk
   */
  private async persist(): Promise<void> {
    try {
      const data = {
        agents: Array.from(this.agents.entries()).map(([id, entry]) => ({
          id,
          ...entry
        })),
        timestamp: new Date().toISOString()
      };

      await fs.writeFile(this.registryPath, JSON.stringify(data, null, 2));
    } catch (error) {
      logger.error('Failed to persist registry', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  /**
   * Load registry from disk
   */
  async load(): Promise<void> {
    try {
      const data = await fs.readFile(this.registryPath, 'utf-8');
      const parsed = JSON.parse(data);

      this.agents.clear();
      for (const item of parsed.agents) {
        this.agents.set(item.id, item);
      }

      logger.info('Registry loaded from disk', {
        agentCount: this.agents.size
      });
    } catch (error) {
      logger.info('No existing registry found, starting fresh');
    }
  }

  /**
   * Get registry statistics
   */
  getStats(): {
    totalAgents: number;
    onlineAgents: number;
    offlineAgents: number;
    roles: Record<AgentRole, number>;
  } {
    const entries = Array.from(this.agents.values());
    const roles: Record<AgentRole, number> = {
      coordinator: 0,
      researcher: 0,
      coder: 0,
      database: 0,
      documentation: 0,
      devops: 0,
      reviewer: 0,
      specialist: 0
    };

    let online = 0;
    let offline = 0;

    for (const entry of entries) {
      if (entry.agent.status === 'online' || entry.agent.status === 'busy') {
        online++;
      } else {
        offline++;
      }
      roles[entry.agent.role] = (roles[entry.agent.role] || 0) + 1;
    }

    return {
      totalAgents: entries.length,
      onlineAgents: online,
      offlineAgents: offline,
      roles
    };
  }
}
```

### Step 4: Create the Message Router

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/router.ts`

```typescript
import { A2AMessage, MessageType, MessagePriority } from './types.js';
import { AgentRegistry } from './registry.js';
import { createModuleLogger } from './logger.js';
import { EventEmitter } from 'events';

const logger = createModuleLogger('message-router');

/**
 * Message handler function type
 */
export type MessageHandler = (message: A2AMessage, reply: (reply: A2AMessage) => Promise<void>) => Promise<void>;

/**
 * Message Router
 * Handles routing of messages between agents
 */
export class MessageRouter extends EventEmitter {
  private registry: AgentRegistry;
  private handlers: Map<MessageType, MessageHandler[]> = new Map();
  private messageQueue: A2AMessage[] = [];
  private processedMessages: Set<string> = new Set();
  private maxQueueSize: number = 1000;

  constructor(registry: AgentRegistry) {
    super();
    this.registry = registry;
    logger.info('Message Router initialized');
  }

  /**
   * Register a message handler
   */
  onMessage(type: MessageType, handler: MessageHandler): void {
    if (!this.handlers.has(type)) {
      this.handlers.set(type, []);
    }
    this.handlers.get(type)!.push(handler);
    logger.debug('Message handler registered', { type });
  }

  /**
   * Send a message
   */
  async send(message: A2AMessage): Promise<void> {
    logger.debug('Sending message', {
      id: message.id,
      type: message.type,
      from: message.from,
      to: message.to
    });

    // Check for duplicate processing
    if (this.processedMessages.has(message.id)) {
      logger.warn('Duplicate message detected', { id: message.id });
      return;
    }

    this.processedMessages.add(message.id);

    // If broadcast, send to all agents
    if (message.type === 'broadcast') {
      const allAgents = this.registry.getAllAgents();
      message.to = allAgents.map(entry => entry.agent.id);
      logger.debug('Broadcast message', { recipients: message.to.length });
    }

    // Convert to array if single recipient
    const recipients = Array.isArray(message.to) ? message.to : [message.to];

    // Filter recipients to online agents
    const onlineRecipients = recipients.filter(recipientId => {
      const agent = this.registry.getAgent(recipientId);
      return agent && (agent.agent.status === 'online' || agent.agent.status === 'busy');
    });

    if (onlineRecipients.length === 0) {
      logger.warn('No online recipients for message', {
        messageId: message.id,
        recipients: recipients
      });
      return;
    }

    // Queue message for each recipient
    for (const recipientId of onlineRecipients) {
      const recipientMessage = {
        ...message,
        to: recipientId
      };

      this.messageQueue.push(recipientMessage);
      
      // Process immediately if queue is small
      if (this.messageQueue.length <= 10) {
        await this.processQueue();
      }
    }

    // Emit event
    this.emit('messageSent', { message, recipients: onlineRecipients });
  }

  /**
   * Process the message queue
   */
  private async processQueue(): Promise<void> {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift()!;
      
      try {
        await this.deliverMessage(message);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.error('Message delivery failed', {
          messageId: message.id,
          error: errorMsg
        });

        // Emit delivery failure
        this.emit('deliveryFailed', { message, error: errorMsg });
      }
    }
  }

  /**
   * Deliver a message to its recipient
   */
  private async deliverMessage(message: A2AMessage): Promise<void> {
    const recipientId = message.to as string;
    const recipient = this.registry.getAgent(recipientId);

    if (!recipient) {
      throw new Error(`Recipient ${recipientId} not found`);
    }

    logger.debug('Delivering message', {
      messageId: message.id,
      recipient: recipientId
    });

    // Check if recipient is online
    if (recipient.agent.status === 'offline' || recipient.agent.status === 'error') {
      throw new Error(`Recipient ${recipientId} is offline`);
    }

    // Get handlers for this message type
    const handlers = this.handlers.get(message.type) || [];

    if (handlers.length === 0) {
      logger.warn('No handlers for message type', { type: message.type });
      return;
    }

    // Create reply function
    const reply = async (replyMessage: A2AMessage): Promise<void> => {
      replyMessage.responseTo = message.id;
      await this.send(replyMessage);
    };

    // Execute all handlers
    for (const handler of handlers) {
      try {
        await handler(message, reply);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.error('Handler execution failed', {
          messageId: message.id,
          handler: handler.name,
          error: errorMsg
        });
        throw error;
      }
    }

    // Emit event
    this.emit('messageDelivered', { message, recipient: recipientId });
  }

  /**
   * Get message queue statistics
   */
  getQueueStats(): {
    queueSize: number;
    processedCount: number;
  } {
    return {
      queueSize: this.messageQueue.length,
      processedCount: this.processedMessages.size
    };
  }

  /**
   * Clear processed messages history
   */
  clearHistory(): void {
    this.processedMessages.clear();
    logger.debug('Message history cleared');
  }

  /**
   * Clear the message queue
   */
  clearQueue(): void {
    this.messageQueue = [];
    logger.debug('Message queue cleared');
  }
}
```

### Step 5: Create the Base Agent Class

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/base-agent.ts`

```typescript
import { 
  AgentIdentity, 
  AgentCapability, 
  AgentRole, 
  A2AMessage,
  MessageType,
  MessagePriority
} from './types.js';
import { AgentRegistry } from './registry.js';
import { MessageRouter } from './router.js';
import { createModuleLogger, Logger } from './logger.js';
import { randomUUID } from 'crypto';

/**
 * Base Agent class
 * All specialized agents extend this class
 */
export abstract class BaseAgent {
  protected identity: AgentIdentity;
  protected registry: AgentRegistry;
  protected router: MessageRouter;
  protected logger: Logger;
  protected capabilities: AgentCapability[];
  protected isRunning: boolean = false;

  constructor(
    identity: Omit<AgentIdentity, 'registeredAt' | 'lastSeen' | 'status'>,
    capabilities: AgentCapability[],
    registry: AgentRegistry,
    router: MessageRouter
  ) {
    this.identity = {
      ...identity,
      status: 'offline',
      registeredAt: new Date(),
      lastSeen: new Date()
    };

    this.capabilities = capabilities;
    this.registry = registry;
    this.router = router;
    this.logger = createModuleLogger(`agent:${identity.id}`);

    this.logger.info('Agent created', {
      id: this.identity.id,
      role: this.identity.role,
      name: this.identity.name
    });
  }

  /**
   * Start the agent
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      this.logger.warn('Agent already running');
      return;
    }

    this.logger.info('Starting agent');

    try {
      // Register with the registry
      await this.registry.register(this.identity, this.capabilities);
      
      // Update status
      await this.registry.updateStatus(this.identity.id, 'online');
      this.identity.status = 'online';

      // Set up message handlers
      this.setupHandlers();

      this.isRunning = true;
      this.logger.info('Agent started successfully');

      // Emit startup notification
      await this.router.send({
        id: randomUUID(),
        type: 'notification',
        from: this.identity.id,
        to: [],
        subject: 'Agent Started',
        body: {
          agentId: this.identity.id,
          role: this.identity.role,
          name: this.identity.name
        },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false
      });

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to start agent', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Stop the agent
   */
  async stop(): Promise<void> {
    if (!this.isRunning) {
      this.logger.warn('Agent already stopped');
      return;
    }

    this.logger.info('Stopping agent');

    try {
      await this.registry.updateStatus(this.identity.id, 'offline');
      this.identity.status = 'offline';
      this.isRunning = false;

      this.logger.info('Agent stopped');
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Failed to stop agent', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Set up message handlers for this agent
   * Override in subclasses
   */
  protected setupHandlers(): void {
    // Handle delegation requests
    this.router.onMessage('delegation', this.handleDelegation.bind(this));

    // Handle requests
    this.router.onMessage('request', this.handleRequest.bind(this));

    // Handle notifications
    this.router.onMessage('notification', this.handleNotification.bind(this));

    // Handle queries
    this.router.onMessage('query', this.handleQuery.bind(this));

    this.logger.debug('Message handlers setup complete');
  }

  /**
   * Handle delegation messages
   * Override in subclasses
   */
  protected async handleDelegation(message: A2AMessage, reply: (msg: A2AMessage) => Promise<void>): Promise<void> {
    this.logger.info('Delegation received', {
      from: message.from,
      subject: message.subject,
      body: message.body
    });

    // Default: accept and process
    try {
      const result = await this.processDelegation(message.body);
      
      await reply({
        id: randomUUID(),
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: `Delegation completed: ${message.subject}`,
        body: { success: true, result },
        priority: message.priority,
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      
      await reply({
        id: randomUUID(),
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: `Delegation failed: ${message.subject}`,
        body: { success: false, error: errorMsg },
        priority: message.priority,
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    }
  }

  /**
   * Handle request messages
   * Override in subclasses
   */
  protected async handleRequest(message: A2AMessage, reply: (msg: A2AMessage) => Promise<void>): Promise<void> {
    this.logger.debug('Request received', {
      from: message.from,
      subject: message.subject
    });

    // Default: respond with capabilities
    await reply({
      id: randomUUID(),
      type: 'response',
      from: this.identity.id,
      to: message.from,
      subject: 'Capabilities',
      body: {
        capabilities: this.capabilities,
        status: this.identity.status
      },
      priority: 'low',
      createdAt: new Date(),
      requiresResponse: false,
      responseTo: message.id
    });
  }

  /**
   * Handle notification messages
   * Override in subclasses
   */
  protected async handleNotification(message: A2AMessage, reply: (msg: A2AMessage) => Promise<void>): Promise<void> {
    this.logger.debug('Notification received', {
      from: message.from,
      subject: message.subject
    });

    // Default: log and ignore
    // Subclasses may override to take action on notifications
  }

  /**
   * Handle query messages
   * Override in subclasses
   */
  protected async handleQuery(message: A2AMessage, reply: (msg: A2AMessage) => Promise<void>): Promise<void> {
    this.logger.debug('Query received', {
      from: message.from,
      subject: message.subject
    });

    // Default: respond with identity and capabilities
    await reply({
      id: randomUUID(),
      type: 'response',
      from: this.identity.id,
      to: message.from,
      subject: 'Agent Information',
      body: {
        identity: this.identity,
        capabilities: this.capabilities
      },
      priority: 'low',
      createdAt: new Date(),
      requiresResponse: false,
      responseTo: message.id
    });
  }

  /**
   * Process a delegation task
   * Override in subclasses
   */
  protected abstract processDelegation(task: any): Promise<any>;

  /**
   * Send a message to another agent
   */
  protected async sendMessage(
    to: string | string[],
    type: MessageType,
    subject: string,
    body: any,
    priority: MessagePriority = 'medium',
    requiresResponse: boolean = false
  ): Promise<void> {
    const message: A2AMessage = {
      id: randomUUID(),
      type,
      from: this.identity.id,
      to,
      subject,
      body,
      priority,
      createdAt: new Date(),
      requiresResponse
    };

    await this.router.send(message);
    this.logger.debug('Message sent', {
      to,
      type,
      subject
    });
  }

  /**
   * Send a delegation request to another agent
   */
  protected async delegate(
    targetRole: AgentRole,
    task: any,
    priority: MessagePriority = 'medium'
  ): Promise<void> {
    const targetAgent = this.registry.findBestAgentForTask(targetRole);
    
    if (!targetAgent) {
      throw new Error(`No suitable agent found for role: ${targetRole}`);
    }

    await this.sendMessage(
      targetAgent.agent.id,
      'delegation',
      'Task Delegation',
      task,
      priority,
      true
    );
  }

  /**
   * Get the agent's identity
   */
  getIdentity(): AgentIdentity {
    return { ...this.identity };
  }

  /**
   * Get the agent's capabilities
   */
  getCapabilities(): AgentCapability[] {
    return [...this.capabilities];
  }

  /**
   * Check if the agent is running
   */
  isActive(): boolean {
    return this.isRunning;
  }
}
```

### Step 6: Create Specialized Agents

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/agents/research-agent.ts`

```typescript
import { BaseAgent } from '../base-agent.js';
import { AgentRole, AgentCapability } from '../types.js';
import { AgentRegistry } from '../registry.js';
import { MessageRouter } from '../router.js';
import { MCPClient } from '../../../mcp-protocol/clients/mcp-client-lib/dist/index.js';

/**
 * Research Agent
 * Specializes in gathering and analyzing information
 */
export class ResearchAgent extends BaseAgent {
  private mcpClient: MCPClient;

  constructor(
    registry: AgentRegistry,
    router: MessageRouter,
    mcpClient: MCPClient
  ) {
    const identity = {
      id: `research-agent-${Date.now()}`,
      name: 'Research Agent',
      role: 'researcher' as AgentRole,
      description: 'Specialized in information gathering, analysis, and research',
      address: 'research-agent',
      status: 'offline' as any
    };

    const capabilities: AgentCapability[] = [
      {
        name: 'Information Gathering',
        description: 'Search and retrieve information from various sources',
        tools: ['search_knowledge', 'read_query', 'get_resource'],
        resources: ['knowledge://index', 'table://*', 'query://*'],
        expertise: ['research', 'information_gathering', 'data_analysis']
      },
      {
        name: 'Data Analysis',
        description: 'Analyze data and extract insights',
        tools: ['analyze_results', 'reflect'],
        resources: ['knowledge://index'],
        expertise: ['analysis', 'statistics', 'insights']
      }
    ];

    super(identity, capabilities, registry, router);
    this.mcpClient = mcpClient;
    this.logger.info('Research Agent created');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing research delegation', { task });

    try {
      // Validate task
      if (!task.query && !task.topic) {
        throw new Error('Task requires query or topic');
      }

      const query = task.query || task.topic;
      const depth = task.depth || 'detailed';

      // Perform research
      const results = await this.performResearch(query, depth);

      // Generate insights
      const insights = await this.generateInsights(results, task.focus);

      return {
        query,
        depth,
        results,
        insights,
        summary: `Research completed on "${query}" with ${results.length} findings`
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Research delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Perform research on a query
   */
  private async performResearch(query: string, depth: string): Promise<any[]> {
    this.logger.debug('Performing research', { query, depth });

    try {
      // Use knowledge server to search
      const result = await this.mcpClient.callTool('knowledge-server', 'search_knowledge', {
        query,
        sources: [],
        limit: depth === 'brief' ? 5 : depth === 'comprehensive' ? 30 : 15
      });

      // Parse results
      const results = result.content?.length > 0 ? 
        JSON.parse(result.content[0]?.text || '{}') : 
        { results: [] };

      return results.results || results.data || [];
      
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Research failed', { error: errorMsg });
      return [];
    }
  }

  /**
   * Generate insights from research results
   */
  private async generateInsights(results: any[], focus?: string): Promise<any> {
    this.logger.debug('Generating insights', { resultCount: results.length, focus });

    // In a real implementation, this would use an LLM to analyze results
    // For now, return a summary
    return {
      findings: results.length > 0 ? 
        `Found ${results.length} relevant items${focus ? ` related to ${focus}` : ''}` :
        'No findings available',
      sources: results.length > 0 ? 
        results.slice(0, 5).map((r: any) => r.source || 'unknown') :
        []
    };
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Add additional handlers for research-specific messages
    this.router.onMessage('query', this.handleResearchQuery.bind(this));
  }

  /**
   * Handle research query messages
   */
  private async handleResearchQuery(message: any, reply: any): Promise<void> {
    this.logger.debug('Research query received', {
      from: message.from,
      query: message.body.query
    });

    const query = message.body.query || message.body.topic;
    
    if (!query) {
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Research Query Error',
        body: { error: 'Query or topic required' },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
      return;
    }

    // Perform research and respond
    const results = await this.performResearch(query, 'brief');
    
    await reply({
      id: `msg-${Date.now()}`,
      type: 'response',
      from: this.identity.id,
      to: message.from,
      subject: `Research: ${query}`,
      body: { results, count: results.length },
      priority: 'medium',
      createdAt: new Date(),
      requiresResponse: false,
      responseTo: message.id
    });
  }
}
```

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/agents/database-agent.ts`

```typescript
import { BaseAgent } from '../base-agent.js';
import { AgentRole, AgentCapability } from '../types.js';
import { AgentRegistry } from '../registry.js';
import { MessageRouter } from '../router.js';
import { MCPClient } from '../../../mcp-protocol/clients/mcp-client-lib/dist/index.js';

/**
 * Database Agent
 * Specializes in database operations and data management
 */
export class DatabaseAgent extends BaseAgent {
  private mcpClient: MCPClient;

  constructor(
    registry: AgentRegistry,
    router: MessageRouter,
    mcpClient: MCPClient
  ) {
    const identity = {
      id: `database-agent-${Date.now()}`,
      name: 'Database Agent',
      role: 'database' as AgentRole,
      description: 'Specialized in database operations, queries, and data management',
      address: 'database-agent',
      status: 'offline' as any
    };

    const capabilities: AgentCapability[] = [
      {
        name: 'Query Execution',
        description: 'Execute SQL queries and retrieve data',
        tools: ['execute_query', 'read_query', 'write_query'],
        resources: ['table://*', 'query://*', 'schema://info'],
        expertise: ['sql', 'database', 'data_management']
      },
      {
        name: 'Schema Management',
        description: 'Manage database schema and structure',
        tools: ['get_schema', 'describe_table', 'list_tables'],
        resources: ['schema://info'],
        expertise: ['schema', 'database_design']
      },
      {
        name: 'Data Analysis',
        description: 'Analyze data and generate insights',
        tools: ['database_stats', 'explain_query'],
        resources: ['table://*'],
        expertise: ['analysis', 'performance']
      }
    ];

    super(identity, capabilities, registry, router);
    this.mcpClient = mcpClient;
    this.logger.info('Database Agent created');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing database delegation', { task });

    try {
      // Validate task
      if (!task.query && !task.action) {
        throw new Error('Task requires query or action');
      }

      let result: any;

      if (task.query) {
        result = await this.mcpClient.callTool('knowledge-server', 'execute_query', {
          sql: task.query,
          params: task.params || [],
          limit: task.limit || 100
        });
      } else if (task.action === 'schema') {
        result = await this.mcpClient.callTool('knowledge-server', 'get_schema', {
          table: task.table,
          includeData: task.includeData || false
        });
      } else if (task.action === 'stats') {
        result = await this.mcpClient.callTool('knowledge-server', 'database_stats', {});
      } else {
        throw new Error(`Unknown action: ${task.action}`);
      }

      return {
        action: task.action || 'query',
        result,
        summary: `Database operation completed successfully`
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Database delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Add additional handlers for database-specific messages
    this.router.onMessage('query', this.handleDatabaseQuery.bind(this));
  }

  /**
   * Handle database query messages
   */
  private async handleDatabaseQuery(message: any, reply: any): Promise<void> {
    this.logger.debug('Database query received', {
      from: message.from,
      query: message.body.query
    });

    const query = message.body.query || message.body.sql;

    if (!query) {
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Database Query Error',
        body: { error: 'SQL query required' },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
      return;
    }

    try {
      const result = await this.mcpClient.callTool('knowledge-server', 'execute_query', {
        sql: query,
        params: message.body.params || [],
        limit: message.body.limit || 50
      });

      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: `Database Query Result`,
        body: { result, success: true },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Database Query Error',
        body: { error: errorMsg, success: false },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    }
  }
}
```

### Step 7: Create the Coordinator Agent

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/agents/coordinator-agent.ts`

```typescript
import { BaseAgent } from '../base-agent.js';
import { AgentRole, AgentCapability, Workflow, WorkflowStep } from '../types.js';
import { AgentRegistry } from '../registry.js';
import { MessageRouter } from '../router.js';
import { randomUUID } from 'crypto';

/**
 * Coordinator Agent
 * Orchestrates multi-agent workflows and task delegation
 */
export class CoordinatorAgent extends BaseAgent {
  private activeWorkflows: Map<string, Workflow> = new Map();

  constructor(
    registry: AgentRegistry,
    router: MessageRouter
  ) {
    const identity = {
      id: `coordinator-${Date.now()}`,
      name: 'Coordinator Agent',
      role: 'coordinator' as AgentRole,
      description: 'Orchestrates multi-agent workflows and delegation',
      address: 'coordinator-agent',
      status: 'offline' as any
    };

    const capabilities: AgentCapability[] = [
      {
        name: 'Workflow Orchestration',
        description: 'Create and manage multi-step workflows across agents',
        tools: ['create_workflow', 'delegate_task'],
        resources: ['workflow://active', 'workflow://history'],
        expertise: ['orchestration', 'planning', 'delegation']
      },
      {
        name: 'Agent Coordination',
        description: 'Coordinate communication between specialized agents',
        tools: ['broadcast', 'delegate'],
        resources: ['registry://agents'],
        expertise: ['coordination', 'communication']
      }
    ];

    super(identity, capabilities, registry, router);
    this.logger.info('Coordinator Agent created');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing coordination delegation', { task });

    try {
      // Validate task
      if (!task.goal && !task.workflow) {
        throw new Error('Task requires goal or workflow');
      }

      let result: any;

      if (task.workflow) {
        result = await this.runWorkflow(task.workflow);
      } else {
        result = await this.createAndRunWorkflow(task.goal, task.steps || []);
      }

      return {
        workflowId: result.id,
        status: result.status,
        summary: `Workflow completed with ${result.steps?.length || 0} steps`
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Coordination delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Create and run a workflow
   */
  async createAndRunWorkflow(goal: string, steps: WorkflowStep[]): Promise<Workflow> {
    this.logger.info('Creating workflow', { goal, stepCount: steps.length });

    const workflow: Workflow = {
      id: `wf-${Date.now()}`,
      name: goal.substring(0, 50),
      description: goal,
      steps,
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    this.activeWorkflows.set(workflow.id, workflow);
    return this.runWorkflow(workflow);
  }

  /**
   * Run an existing workflow
   */
  async runWorkflow(workflow: Workflow): Promise<Workflow> {
    this.logger.info('Running workflow', { 
      workflowId: workflow.id, 
      stepCount: workflow.steps.length 
    });

    workflow.status = 'active';
    workflow.updatedAt = new Date();

    // Process each step in order
    const steps = workflow.steps.sort((a, b) => {
      // Simple dependency-based ordering
      return a.dependencies.length - b.dependencies.length;
    });

    for (const step of steps) {
      // Check if dependencies are completed
      const depsMet = step.dependencies.every(depId => {
        const dep = workflow.steps.find(s => s.id === depId);
        return dep && dep.status === 'completed';
      });

      if (!depsMet) {
        step.status = 'skipped';
        continue;
      }

      // Assign to appropriate agent
      step.status = 'assigned';
      step.assignedTo = await this.assignStep(step);
      
      if (step.assignedTo) {
        step.status = 'in_progress';
        step.startedAt = new Date();

        try {
          // Delegate to the agent
          await this.delegateStep(step);
          step.status = 'completed';
          step.completedAt = new Date();
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : 'Unknown error';
          step.status = 'failed';
          step.error = errorMsg;
        }
      }

      workflow.updatedAt = new Date();
    }

    // Check final status
    const failed = workflow.steps.some(s => s.status === 'failed');
    const pending = workflow.steps.some(s => s.status === 'pending' || s.status === 'assigned');

    if (failed) {
      workflow.status = 'failed';
    } else if (pending) {
      workflow.status = 'active';
    } else {
      workflow.status = 'completed';
    }

    this.logger.info('Workflow completed', {
      workflowId: workflow.id,
      status: workflow.status
    });

    return workflow;
  }

  /**
   * Assign a step to an agent
   */
  private async assignStep(step: WorkflowStep): Promise<string | undefined> {
    const agent = this.registry.findBestAgentForTask(
      step.agentRole,
      step.tools
    );

    if (!agent) {
      this.logger.warn('No suitable agent found for step', {
        stepId: step.id,
        role: step.agentRole
      });
      return undefined;
    }

    return agent.agent.id;
  }

  /**
   * Delegate a step to an assigned agent
   */
  private async delegateStep(step: WorkflowStep): Promise<void> {
    if (!step.assignedTo) {
      throw new Error(`Step ${step.id} has no assigned agent`);
    }

    await this.sendMessage(
      step.assignedTo,
      'delegation',
      step.description,
      {
        taskId: step.id,
        description: step.description,
        parameters: {},
        priority: 'high'
      },
      'high',
      true
    );
  }

  /**
   * Get workflow status
   */
  getWorkflow(workflowId: string): Workflow | undefined {
    return this.activeWorkflows.get(workflowId);
  }

  /**
   * List active workflows
   */
  listActiveWorkflows(): Workflow[] {
    return Array.from(this.activeWorkflows.values())
      .filter(w => w.status === 'active' || w.status === 'pending');
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Handle workflow requests
    this.router.onMessage('request', this.handleWorkflowRequest.bind(this));
  }

  /**
   * Handle workflow request messages
   */
  private async handleWorkflowRequest(message: any, reply: any): Promise<void> {
    this.logger.debug('Workflow request received', {
      from: message.from,
      subject: message.subject
    });

    const body = message.body;

    if (body.action === 'create_workflow') {
      const workflow = await this.createAndRunWorkflow(
        body.goal,
        body.steps || []
      );

      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Workflow Created',
        body: { workflow, success: true },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    } else if (body.action === 'get_workflow' && body.workflowId) {
      const workflow = this.getWorkflow(body.workflowId);

      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Workflow Status',
        body: { workflow, success: true },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    }
  }
}
```

### Step 8: Create the A2A System Entry Point

**File:** `ai-integration-javascript/a2a-protocol/a2a-library/src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { AgentRegistry } from './registry.js';
import { MessageRouter } from './router.js';
import { CoordinatorAgent } from './agents/coordinator-agent.js';
import { ResearchAgent } from './agents/research-agent.js';
import { DatabaseAgent } from './agents/database-agent.js';
import { createLogger } from './logger.js';
import { MCPClient } from '../../../mcp-protocol/clients/mcp-client-lib/dist/index.js';

const logger = createLogger();

/**
 * A2A System
 * Manages the multi-agent system lifecycle
 */
export class A2ASystem {
  private registry: AgentRegistry;
  private router: MessageRouter;
  private coordinator: CoordinatorAgent;
  private agents: Map<string, any> = new Map();
  private mcpClient: MCPClient;

  constructor() {
    this.registry = new AgentRegistry();
    this.router = new MessageRouter(this.registry);
    this.mcpClient = this.initializeMCPClient();
    
    // Initialize agents
    this.initAgents();
    
    logger.info('A2A System initialized', {
      agentCount: this.agents.size
    });
  }

  /**
   * Initialize MCP client
   */
  private initializeMCPClient(): MCPClient {
    const knowledgeServerPath = process.env.MCP_KNOWLEDGE_SERVER_PATH || 
      '../../mcp-protocol/servers/knowledge-server/dist/index.js';

    const serverConfig = {
      id: 'knowledge-server',
      name: 'Knowledge Server',
      version: '1.0.0',
      transport: {
        type: 'stdio',
        command: 'node',
        args: [knowledgeServerPath],
        env: {
          NODE_ENV: process.env.NODE_ENV || 'development',
          LOG_LEVEL: process.env.LOG_LEVEL || 'info'
        }
      },
      autoReconnect: true,
      maxReconnectAttempts: 3,
      timeout: 30000
    };

    const { MCPClient } = require('../../../mcp-protocol/clients/mcp-client-lib/dist/index.js');
    return new MCPClient({
      servers: [serverConfig],
      defaultTimeout: 30000,
      debug: process.env.DEBUG === 'true'
    });
  }

  /**
   * Initialize all agents
   */
  private initAgents(): void {
    logger.info('Initializing agents');

    // Coordinator Agent
    const coordinator = new CoordinatorAgent(this.registry, this.router);
    this.agents.set('coordinator', coordinator);
    this.coordinator = coordinator;

    // Research Agent
    const research = new ResearchAgent(this.registry, this.router, this.mcpClient);
    this.agents.set('research', research);

    // Database Agent
    const database = new DatabaseAgent(this.registry, this.router, this.mcpClient);
    this.agents.set('database', database);

    logger.info('Agents initialized', {
      agents: Array.from(this.agents.keys())
    });
  }

  /**
   * Start the A2A system
   */
  async start(): Promise<void> {
    logger.info('Starting A2A System');

    try {
      // Connect to MCP servers
      await this.mcpClient.connectAll();
      logger.info('Connected to MCP servers');

      // Load registry from disk
      await this.registry.load();

      // Start all agents
      for (const [name, agent] of this.agents) {
        try {
          await agent.start();
          logger.info(`Agent started: ${name}`);
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : 'Unknown error';
          logger.error(`Failed to start agent: ${name}`, { error: errorMsg });
        }
      }

      logger.info('A2A System started successfully', {
        activeAgents: this.agents.size
      });

      console.error('A2A Multi-Agent System is running...');
      console.error(`Agents: ${Array.from(this.agents.keys()).join(', ')}`);

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start A2A System', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Stop the A2A system
   */
  async stop(): Promise<void> {
    logger.info('Stopping A2A System');

    try {
      // Stop all agents
      for (const [name, agent] of this.agents) {
        try {
          await agent.stop();
          logger.info(`Agent stopped: ${name}`);
        } catch (error) {
          const errorMsg = error instanceof Error ? error.message : 'Unknown error';
          logger.error(`Failed to stop agent: ${name}`, { error: errorMsg });
        }
      }

      // Disconnect MCP client
      await this.mcpClient.disconnectAll();

      logger.info('A2A System stopped successfully');

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop A2A System', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Get system status
   */
  getStatus(): {
    agents: { name: string; running: boolean; status: string }[];
    registry: ReturnType<AgentRegistry['getStats']>;
  } {
    const agents = Array.from(this.agents.entries()).map(([name, agent]) => ({
      name,
      running: agent.isActive(),
      status: agent.getIdentity().status
    }));

    return {
      agents,
      registry: this.registry.getStats()
    };
  }

  /**
   * Get the coordinator agent
   */
  getCoordinator(): CoordinatorAgent {
    return this.coordinator;
  }
}

/**
 * Main entry point
 */
const main = async (): Promise<void> => {
  logger.info('Starting A2A System entry point');

  const system = new A2ASystem();

  // Handle shutdown signals
  process.on('SIGINT', async () => {
    logger.info('Received SIGINT, shutting down...');
    await system.stop();
    process.exit(0);
  });

  process.on('SIGTERM', async () => {
    logger.info('Received SIGTERM, shutting down...');
    await system.stop();
    process.exit(0);
  });

  process.on('uncaughtException', (error) => {
    logger.fatal('Uncaught exception', { error: error.message, stack: error.stack });
    process.exit(1);
  });

  process.on('unhandledRejection', (reason) => {
    logger.fatal('Unhandled rejection', { reason });
    process.exit(1);
  });

  await system.start();

  // Keep the process alive
  console.error('Press Ctrl+C to stop');
};

if (import.meta.url === `file://${process.argv[1]}`) {
  void main();
}

export { A2ASystem };
```

## The Verification

### Step 1: Build the A2A Library

```bash
cd ai-integration-javascript/a2a-protocol/a2a-library
npm install
npm run build
```

### Step 2: Start the A2A System

```bash
npm start
```

### Step 3: Test Multi-Agent Coordination

Create a test script:

**File:** `test-multi-agent.js`

```javascript
import { A2ASystem } from './dist/index.js';
import { randomUUID } from 'crypto';

const system = new A2ASystem();
await system.start();

console.log('=== Multi-Agent System Test ===\n');

// Get the coordinator
const coordinator = system.getCoordinator();

// Create a workflow
console.log('Creating workflow...');
const workflow = await coordinator.createAndRunWorkflow(
  'Analyze user data and generate report',
  [
    {
      id: 'step-1',
      name: 'Research Data',
      description: 'Research user data patterns and trends',
      agentRole: 'researcher',
      tools: ['search_knowledge'],
      dependencies: [],
      status: 'pending'
    },
    {
      id: 'step-2',
      name: 'Query Database',
      description: 'Extract user data from database',
      agentRole: 'database',
      tools: ['execute_query'],
      dependencies: ['step-1'],
      status: 'pending'
    },
    {
      id: 'step-3',
      name: 'Generate Report',
      description: 'Generate comprehensive report',
      agentRole: 'researcher',
      tools: ['analyze_results'],
      dependencies: ['step-2'],
      status: 'pending'
    }
  ]
);

console.log('Workflow created:', {
  id: workflow.id,
  status: workflow.status,
  steps: workflow.steps.map(s => ({ id: s.id, status: s.status, assignedTo: s.assignedTo }))
});

// Get system status
const status = system.getStatus();
console.log('\nSystem Status:', {
  agents: status.agents,
  registry: status.registry
});

await system.stop();
console.log('\n✅ Multi-agent test complete!');
```

### Step 4: Expected Output

```
A2A Multi-Agent System is running...
Agents: coordinator, research, database

=== Multi-Agent System Test ===

Creating workflow...
Workflow created: {
  id: 'wf-1234567890',
  status: 'completed',
  steps: [
    { id: 'step-1', status: 'completed', assignedTo: 'research-agent-123456' },
    { id: 'step-2', status: 'completed', assignedTo: 'database-agent-123456' },
    { id: 'step-3', status: 'completed', assignedTo: 'research-agent-123456' }
  ]
}

System Status: {
  agents: [
    { name: 'coordinator', running: true, status: 'online' },
    { name: 'research', running: true, status: 'online' },
    { name: 'database', running: true, status: 'online' }
  ],
  registry: {
    totalAgents: 3,
    onlineAgents: 3,
    offlineAgents: 0,
    roles: {
      coordinator: 1,
      researcher: 1,
      database: 1,
      ...
    }
  }
}

✅ Multi-agent test complete!
```

## What You've Built

You've built a complete Agent-to-Agent (A2A) collaboration system with:

### Core Components
1. **Agent Registry** — Discovery and capability advertisement
2. **Message Router** — Reliable message delivery between agents
3. **Base Agent** — Common agent functionality
4. **Coordinator Agent** — Workflow orchestration and delegation
5. **Research Agent** — Information gathering and analysis
6. **Database Agent** — Database operations and data management

### A2A Features
1. **Agent Discovery** — Find agents by role, capability, or expertise
2. **Message Routing** — Direct, broadcast, and workflow messages
3. **Task Delegation** — Assign tasks to appropriate agents
4. **Workflow Orchestration** — Multi-step workflows with dependencies
5. **Capability Advertisement** — Agents announce their capabilities
6. **Status Monitoring** — Real-time agent status tracking

### Architecture Benefits
1. **Scalability** — Add new agents without changing existing code
2. **Specialization** — Each agent focuses on its expertise
3. **Resilience** — Agent failures don't break the whole system
4. **Flexibility** — Workflows can be dynamically created
5. **Observability** — Comprehensive logging and status reporting

## Key Takeaways

1. **A2A Enables Teamwork** — Agents can collaborate on complex tasks
2. **Specialization Improves Quality** — Each agent masters its domain
3. **Workflows Provide Structure** — Clear steps with dependencies
4. **Discovery is Essential** — Agents need to find each other
5. **Communication is Key** — Messages must be reliable and trackable
6. **Registry Enables Flexibility** — Dynamic agent discovery

## What's Next?

In **Part 9**, we'll explore **Multi-Agent Architectures** — advanced patterns including:
- **Coordinator-Supervisor** hierarchies
- **Planner-Worker** execution models
- **Event-Driven Workflows**
- **Swarm Intelligence**
- **Human-in-the-Loop** systems
- **Distributed Reasoning** and shared memory

We'll transform our agent team into a sophisticated software development organization capable of planning, building, testing, and deploying complete applications.
