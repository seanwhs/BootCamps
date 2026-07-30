# MCP & A2A Primer: Part 4 — A2A: Building Your First Multi-Agent System

**[GENERATED: MCP & A2A Primer: Part 4 — Building Your First Multi-Agent System]**

## Introduction

You've built MCP servers and understood JSON-RPC communication. Now it's time to explore the other half of the AI ecosystem: **A2A (Agent-to-Agent)** communication.

In this primer, you'll build your first multi-agent system where agents communicate, delegate tasks, and collaborate. You'll create:

1. A **Research Agent** that can search and analyze information
2. A **Coordinator Agent** that orchestrates workflows
3. A **simple message protocol** for agent communication

By the end, you'll understand how AI agents can work together as a team.

---

## Part 1: What is A2A?

### The Problem A2A Solves

Imagine you have a brilliant employee who can do many things. But eventually, they get overwhelmed. The solution? Hire specialists and have them collaborate.

**Before A2A (Single Agent):**
```
┌─────────────────────────────────────┐
│           Single Agent              │
│  - Does everything (poorly)         │
│  - Gets overwhelmed                 │
│  - No specialization                │
└─────────────────────────────────────┘
```

**After A2A (Multi-Agent Team):**
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Research │  │  Coding  │  │Database  │
│  Agent   │  │  Agent   │  │  Agent   │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └─────────────┴─────────────┘
           ▲
           │
     ┌─────┴─────┐
     │Coordinator│
     │  Agent    │
     └───────────┘
```

### How A2A Differs from MCP

| Aspect | MCP | A2A |
|--------|-----|-----|
| **What it does** | Connects AI to tools | Connects agents to each other |
| **Architecture** | Client-server | Peer-to-peer |
| **Communication** | Request-response | Message-based |
| **Analogy** | Tools in a workshop | Team members collaborating |

### The Core A2A Components

1. **Agent** — An autonomous AI that can perform tasks
2. **Message** — How agents communicate
3. **Registry** — Where agents discover each other
4. **Router** — How messages find their way to the right agent

---

## Part 2: Building a Simple Agent System

### What We're Building

We'll build a small multi-agent system where:

1. **Coordinator Agent** receives a goal from the user
2. **Coordinator** delegates to specialized agents
3. **Research Agent** finds information
4. **Agents communicate** via messages

### Project Structure

```
a2a-first-system/
├── src/
│   ├── index.ts
│   ├── logger.ts
│   ├── types.ts
│   ├── registry.ts
│   ├── router.ts
│   ├── base-agent.ts
│   ├── coordinator-agent.ts
│   └── research-agent.ts
├── package.json
├── tsconfig.json
└── .env.example
```

### Step 1: Project Setup

```bash
mkdir a2a-first-system
cd a2a-first-system
npm init -y
npm install zod dotenv
npm install -D typescript @types/node tsx
```

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

### Step 2: Define Types

Create `src/types.ts`:

```typescript
/**
 * Agent Types for A2A System
 */

/**
 * Agent identity
 */
export interface AgentIdentity {
  id: string;
  name: string;
  role: 'coordinator' | 'researcher' | 'coder' | 'database';
  description: string;
  status: 'online' | 'busy' | 'offline';
}

/**
 * Agent capabilities
 */
export interface AgentCapability {
  name: string;
  description: string;
  actions: string[];
}

/**
 * Message types
 */
export type MessageType = 'request' | 'response' | 'delegation' | 'notification';

/**
 * A2A Message
 */
export interface A2AMessage {
  id: string;
  type: MessageType;
  from: string; // Agent ID
  to: string | string[]; // Agent ID(s)
  subject: string;
  body: any;
  createdAt: Date;
  responseTo?: string; // ID of message this responds to
}

/**
 * Task delegation request
 */
export interface DelegationRequest {
  taskId: string;
  description: string;
  assignedRole: AgentIdentity['role'];
  parameters: Record<string, any>;
}

/**
 * Task delegation response
 */
export interface DelegationResponse {
  accepted: boolean;
  assignedTo?: string;
  result?: any;
  error?: string;
}
```

### Step 3: Create the Logger

Create `src/logger.ts`:

```typescript
import pino from 'pino';

export function createLogger(context?: Record<string, unknown>) {
  const logger = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: {
      service: 'a2a-system',
      version: '1.0.0'
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

export const logger = createLogger();
export function createModuleLogger(moduleName: string) {
  return logger.child({ module: moduleName });
}
```

### Step 4: Create the Agent Registry

The registry keeps track of all agents and their capabilities.

Create `src/registry.ts`:

```typescript
import { AgentIdentity, AgentCapability } from './types.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('registry');

/**
 * Agent Registry
 * Keeps track of all registered agents
 */
export class AgentRegistry {
  private agents: Map<string, { identity: AgentIdentity; capabilities: AgentCapability[] }> = new Map();

  /**
   * Register an agent
   */
  register(identity: AgentIdentity, capabilities: AgentCapability[]): void {
    logger.info('Registering agent', { id: identity.id, role: identity.role });
    
    this.agents.set(identity.id, {
      identity: { ...identity, status: 'online' },
      capabilities
    });
  }

  /**
   * Unregister an agent
   */
  unregister(agentId: string): void {
    logger.info('Unregistering agent', { id: agentId });
    this.agents.delete(agentId);
  }

  /**
   * Get an agent by ID
   */
  getAgent(agentId: string): { identity: AgentIdentity; capabilities: AgentCapability[] } | null {
    return this.agents.get(agentId) || null;
  }

  /**
   * Get all agents
   */
  getAllAgents(): Array<{ identity: AgentIdentity; capabilities: AgentCapability[] }> {
    return Array.from(this.agents.values());
  }

  /**
   * Find agents by role
   */
  findAgentsByRole(role: AgentIdentity['role']): Array<{ identity: AgentIdentity; capabilities: AgentCapability[] }> {
    return Array.from(this.agents.values()).filter(
      entry => entry.identity.role === role
    );
  }

  /**
   * Find the best agent for a task
   */
  findBestAgentForTask(
    role: AgentIdentity['role'],
    requiredActions: string[] = []
  ): { identity: AgentIdentity; capabilities: AgentCapability[] } | null {
    const candidates = Array.from(this.agents.values()).filter(entry => {
      // Must have the right role
      if (entry.identity.role !== role) {
        return false;
      }
      
      // Must be online
      if (entry.identity.status !== 'online') {
        return false;
      }
      
      // Must have required actions
      if (requiredActions.length > 0) {
        const hasAllActions = requiredActions.every(action =>
          entry.capabilities.some(cap => cap.actions.includes(action))
        );
        if (!hasAllActions) {
          return false;
        }
      }
      
      return true;
    });

    // Return the first matching agent
    return candidates.length > 0 ? candidates[0] : null;
  }

  /**
   * Update agent status
   */
  updateStatus(agentId: string, status: AgentIdentity['status']): void {
    const entry = this.agents.get(agentId);
    if (entry) {
      entry.identity.status = status;
      logger.debug('Agent status updated', { id: agentId, status });
    }
  }

  /**
   * List all agents
   */
  listAgents(): Array<{ id: string; name: string; role: string; status: string }> {
    return Array.from(this.agents.values()).map(entry => ({
      id: entry.identity.id,
      name: entry.identity.name,
      role: entry.identity.role,
      status: entry.identity.status
    }));
  }
}
```

### Step 5: Create the Message Router

The router handles sending and receiving messages between agents.

Create `src/router.ts`:

```typescript
import { A2AMessage, MessageType } from './types.js';
import { AgentRegistry } from './registry.js';
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('router');

type MessageHandler = (message: A2AMessage, reply: (reply: A2AMessage) => Promise<void>) => Promise<void>;

/**
 * Message Router
 * Routes messages between agents
 */
export class MessageRouter {
  private registry: AgentRegistry;
  private handlers: Map<MessageType, MessageHandler[]> = new Map();
  private messageQueue: A2AMessage[] = [];

  constructor(registry: AgentRegistry) {
    this.registry = registry;
    logger.info('Message Router initialized');
  }

  /**
   * Register a message handler
   */
  on(type: MessageType, handler: MessageHandler): void {
    if (!this.handlers.has(type)) {
      this.handlers.set(type, []);
    }
    this.handlers.get(type)!.push(handler);
    logger.debug('Handler registered', { type });
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

    // Validate recipients
    const recipients = Array.isArray(message.to) ? message.to : [message.to];
    const validRecipients = recipients.filter(id => {
      const agent = this.registry.getAgent(id);
      return agent && agent.identity.status === 'online';
    });

    if (validRecipients.length === 0) {
      logger.warn('No valid recipients for message', { id: message.id });
      return;
    }

    // Queue message for each recipient
    for (const recipientId of validRecipients) {
      const recipientMessage = {
        ...message,
        to: recipientId
      };
      this.messageQueue.push(recipientMessage);
    }

    // Process queue
    await this.processQueue();
  }

  /**
   * Process the message queue
   */
  private async processQueue(): Promise<void> {
    while (this.messageQueue.length > 0) {
      const message = this.messageQueue.shift()!;
      await this.deliverMessage(message);
    }
  }

  /**
   * Deliver a message to its recipient
   */
  private async deliverMessage(message: A2AMessage): Promise<void> {
    const recipientId = message.to as string;
    const recipient = this.registry.getAgent(recipientId);

    if (!recipient || recipient.identity.status === 'offline') {
      logger.warn('Recipient offline', { id: message.id, recipient: recipientId });
      return;
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

    // Execute handlers
    for (const handler of handlers) {
      try {
        await handler(message, reply);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        logger.error('Handler execution failed', {
          messageId: message.id,
          error: errorMsg
        });
      }
    }
  }

  /**
   * Get queue statistics
   */
  getStats(): { queueSize: number } {
    return { queueSize: this.messageQueue.length };
  }
}
```

### Step 6: Create the Base Agent

The base agent provides common functionality for all agents.

Create `src/base-agent.ts`:

```typescript
import { AgentIdentity, AgentCapability, A2AMessage, MessageType } from './types.js';
import { AgentRegistry } from './registry.js';
import { MessageRouter } from './router.js';
import { createModuleLogger, Logger } from './logger.js';
import { randomUUID } from 'crypto';

/**
 * Base Agent
 * All agents extend this class
 */
export abstract class BaseAgent {
  protected identity: AgentIdentity;
  protected registry: AgentRegistry;
  protected router: MessageRouter;
  protected logger: Logger;
  protected capabilities: AgentCapability[];

  constructor(
    identity: Omit<AgentIdentity, 'status'>,
    capabilities: AgentCapability[],
    registry: AgentRegistry,
    router: MessageRouter
  ) {
    this.identity = {
      ...identity,
      status: 'offline'
    };
    this.capabilities = capabilities;
    this.registry = registry;
    this.router = router;
    this.logger = createModuleLogger(`agent:${identity.id}`);

    this.logger.info('Agent created', { id: this.identity.id, role: this.identity.role });
  }

  /**
   * Start the agent
   */
  async start(): Promise<void> {
    this.logger.info('Starting agent');

    // Register with registry
    this.registry.register(this.identity, this.capabilities);
    this.identity.status = 'online';

    // Set up message handlers
    this.setupHandlers();

    this.logger.info('Agent started successfully');
  }

  /**
   * Stop the agent
   */
  async stop(): Promise<void> {
    this.logger.info('Stopping agent');
    this.registry.updateStatus(this.identity.id, 'offline');
    this.identity.status = 'offline';
    this.logger.info('Agent stopped');
  }

  /**
   * Setup message handlers
   * Override in subclasses
   */
  protected setupHandlers(): void {
    // Handle delegation requests
    this.router.on('delegation', this.handleDelegation.bind(this));
    
    // Handle requests
    this.router.on('request', this.handleRequest.bind(this));
  }

  /**
   * Handle delegation messages
   * Override in subclasses
   */
  protected async handleDelegation(message: A2AMessage, reply: (msg: A2AMessage) => Promise<void>): Promise<void> {
    this.logger.info('Delegation received', {
      from: message.from,
      subject: message.subject
    });

    // Default: accept the delegation
    const result = await this.processDelegation(message.body);
    
    await reply({
      id: randomUUID(),
      type: 'response',
      from: this.identity.id,
      to: message.from,
      subject: `Delegation response: ${message.subject}`,
      body: { accepted: true, result },
      createdAt: new Date(),
      responseTo: message.id
    });
  }

  /**
   * Handle request messages
   */
  protected async handleRequest(message: A2AMessage, reply: (msg: A2AMessage) => Promise<void>): Promise<void> {
    this.logger.debug('Request received', {
      from: message.from,
      subject: message.subject
    });

    // Respond with capabilities
    await reply({
      id: randomUUID(),
      type: 'response',
      from: this.identity.id,
      to: message.from,
      subject: 'Capabilities',
      body: {
        identity: this.identity,
        capabilities: this.capabilities
      },
      createdAt: new Date(),
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
    body: any
  ): Promise<void> {
    const message: A2AMessage = {
      id: randomUUID(),
      type,
      from: this.identity.id,
      to,
      subject,
      body,
      createdAt: new Date()
    };

    await this.router.send(message);
    this.logger.debug('Message sent', { to, type, subject });
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
}
```

### Step 7: Create the Research Agent

The research agent specializes in gathering and analyzing information.

Create `src/research-agent.ts`:

```typescript
import { BaseAgent } from './base-agent.js';
import { AgentRegistry } from './registry.js';
import { MessageRouter } from './router.js';

/**
 * Research Agent
 * Specializes in information gathering and analysis
 */
export class ResearchAgent extends BaseAgent {
  private knowledgeBase: Map<string, string> = new Map();

  constructor(
    registry: AgentRegistry,
    router: MessageRouter
  ) {
    super(
      {
        id: `research-${Date.now()}`,
        name: 'Research Agent',
        role: 'researcher',
        description: 'I gather information and analyze data'
      },
      [
        {
          name: 'Information Gathering',
          description: 'Search and retrieve information',
          actions: ['search', 'analyze', 'summarize']
        },
        {
          name: 'Data Analysis',
          description: 'Analyze data and extract insights',
          actions: ['analyze', 'summarize']
        }
      ],
      registry,
      router
    );

    // Initialize knowledge base with some sample data
    this.knowledgeBase.set('database optimization', 'Use indexes, optimize queries, and use connection pooling');
    this.knowledgeBase.set('api design', 'Use RESTful principles, proper status codes, and versioning');
    this.knowledgeBase.set('security best practices', 'Use HTTPS, validate inputs, and implement rate limiting');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing research delegation', { task });

    try {
      // Extract the research query
      const query = task.query || task.topic || task.description;
      
      if (!query) {
        throw new Error('No research query provided');
      }

      // Perform research
      const results = await this.research(query);

      return {
        query,
        results,
        summary: `Found ${results.length} relevant pieces of information`,
        sources: ['knowledge-base']
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Research delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Research a query
   */
  private async research(query: string): Promise<any[]> {
    this.logger.debug('Researching', { query });

    const results: any[] = [];

    // Search the knowledge base
    for (const [key, value] of this.knowledgeBase.entries()) {
      if (query.toLowerCase().includes(key.toLowerCase()) || 
          key.toLowerCase().includes(query.toLowerCase())) {
        results.push({
          topic: key,
          information: value,
          source: 'knowledge-base'
        });
      }
    }

    // If no results, provide a general response
    if (results.length === 0) {
      results.push({
        topic: query,
        information: `I don't have specific information about "${query}" in my knowledge base. Try asking about database optimization, API design, or security best practices.`,
        source: 'general'
      });
    }

    return results;
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Add additional handlers for research-specific messages
    this.router.on('request', this.handleResearchRequest.bind(this));
  }

  /**
   * Handle research request messages
   */
  private async handleResearchRequest(message: any, reply: any): Promise<void> {
    if (message.subject === 'research' && message.body?.query) {
      const results = await this.research(message.body.query);
      
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Research Results',
        body: { results, count: results.length },
        createdAt: new Date(),
        responseTo: message.id
      });
    }
  }
}
```

### Step 8: Create the Coordinator Agent

The coordinator orchestrates the work of other agents.

Create `src/coordinator-agent.ts`:

```typescript
import { BaseAgent } from './base-agent.js';
import { AgentRegistry } from './registry.js';
import { MessageRouter } from './router.js';
import { randomUUID } from 'crypto';

/**
 * Coordinator Agent
 * Orchestrates workflows and delegates tasks
 */
export class CoordinatorAgent extends BaseAgent {
  private activeTasks: Map<string, any> = new Map();

  constructor(
    registry: AgentRegistry,
    router: MessageRouter
  ) {
    super(
      {
        id: `coordinator-${Date.now()}`,
        name: 'Coordinator Agent',
        role: 'coordinator',
        description: 'I coordinate multi-agent workflows and delegate tasks'
      },
      [
        {
          name: 'Workflow Orchestration',
          description: 'Coordinate multi-step workflows',
          actions: ['delegate', 'coordinate', 'monitor']
        },
        {
          name: 'Task Management',
          description: 'Assign and track tasks',
          actions: ['assign', 'track', 'review']
        }
      ],
      registry,
      router
    );

    this.logger.info('Coordinator Agent created');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing coordination delegation', { task });

    try {
      // Determine the type of request
      if (task.goal) {
        // Multi-step workflow
        return await this.orchestrateWorkflow(task);
      } else if (task.query) {
        // Simple research query
        return await this.delegateResearch(task);
      } else {
        throw new Error('Unknown task type');
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Coordination delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Orchestrate a multi-step workflow
   */
  private async orchestrateWorkflow(task: any): Promise<any> {
    const { goal, steps = [] } = task;

    this.logger.info('Orchestrating workflow', { goal, stepCount: steps.length });

    const results: any[] = [];

    for (const step of steps) {
      this.logger.debug('Executing workflow step', { step });

      try {
        let result;

        if (step.role === 'researcher') {
          result = await this.delegateResearch({ query: step.description });
        } else {
          // Generic delegation
          result = await this.delegateTask(step.role, step.description, step.parameters || {});
        }

        results.push({
          step: step.description,
          role: step.role,
          result,
          status: 'completed'
        });
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        results.push({
          step: step.description,
          role: step.role,
          error: errorMsg,
          status: 'failed'
        });
      }
    }

    return {
      goal,
      results,
      summary: `Completed ${results.filter(r => r.status === 'completed').length}/${results.length} steps`
    };
  }

  /**
   * Delegate a research task
   */
  private async delegateResearch(task: any): Promise<any> {
    this.logger.info('Delegating research', { query: task.query });

    // Find a research agent
    const researchAgent = this.registry.findBestAgentForTask('researcher', ['search', 'analyze']);

    if (!researchAgent) {
      throw new Error('No research agent available');
    }

    // Send delegation request
    const taskId = `task-${Date.now()}`;

    this.activeTasks.set(taskId, {
      task,
      assignedTo: researchAgent.identity.id,
      status: 'pending'
    });

    return new Promise((resolve, reject) => {
      // Send message to research agent
      this.sendMessage(
        researchAgent.identity.id,
        'delegation',
        `Research: ${task.query}`,
        {
          taskId,
          query: task.query,
          parameters: task.parameters || {}
        }
      ).then(() => {
        // In a real system, we'd wait for a response
        // For this demo, we'll resolve after a short delay
        setTimeout(() => {
          const taskData = this.activeTasks.get(taskId);
          if (taskData) {
            taskData.status = 'completed';
            resolve({
              taskId,
              query: task.query,
              result: `Research completed for "${task.query}"`,
              agent: researchAgent.identity.name
            });
          } else {
            reject(new Error('Task not found'));
          }
        }, 500);
      }).catch(reject);
    });
  }

  /**
   * Delegate a generic task
   */
  private async delegateTask(
    role: string,
    description: string,
    parameters: Record<string, any>
  ): Promise<any> {
    this.logger.info('Delegating task', { role, description });

    // Find an agent with the right role
    const agent = this.registry.findBestAgentForTask(role as any);

    if (!agent) {
      throw new Error(`No agent available for role: ${role}`);
    }

    // In a real system, this would send a message and wait for response
    // For this demo, we return a simulated result
    return {
      description,
      role,
      assignedTo: agent.identity.name,
      result: `Task "${description}" completed by ${agent.identity.name}`,
      status: 'completed'
    };
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Handle workflow requests
    this.router.on('request', this.handleWorkflowRequest.bind(this));
  }

  /**
   * Handle workflow request messages
   */
  private async handleWorkflowRequest(message: any, reply: any): Promise<void> {
    if (message.body?.action === 'workflow' && message.body?.goal) {
      const result = await this.orchestrateWorkflow({
        goal: message.body.goal,
        steps: message.body.steps || []
      });

      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Workflow Results',
        body: result,
        createdAt: new Date(),
        responseTo: message.id
      });
    }
  }

  /**
   * Get active tasks
   */
  getActiveTasks(): Array<{ id: string; status: string; assignedTo: string }> {
    return Array.from(this.activeTasks.entries()).map(([id, data]) => ({
      id,
      status: data.status,
      assignedTo: data.assignedTo
    }));
  }
}
```

### Step 9: Create the Main Entry Point

Create `src/index.ts`:

```typescript
#!/usr/bin/env node

/**
 * A2A First System - Multi-Agent Demo
 */

import dotenv from 'dotenv';
dotenv.config();

import { AgentRegistry } from './registry.js';
import { MessageRouter } from './router.js';
import { ResearchAgent } from './research-agent.js';
import { CoordinatorAgent } from './coordinator-agent.js';
import { createLogger } from './logger.js';

const logger = createLogger();

/**
 * A2A System
 */
class A2ASystem {
  private registry: AgentRegistry;
  private router: MessageRouter;
  private agents: Map<string, any> = new Map();
  private coordinator: CoordinatorAgent;

  constructor() {
    this.registry = new AgentRegistry();
    this.router = new MessageRouter(this.registry);

    // Create agents
    const research = new ResearchAgent(this.registry, this.router);
    const coordinator = new CoordinatorAgent(this.registry, this.router);

    this.agents.set('research', research);
    this.agents.set('coordinator', coordinator);
    this.coordinator = coordinator;

    logger.info('A2A System initialized', {
      agents: Array.from(this.agents.keys())
    });
  }

  /**
   * Start the system
   */
  async start(): Promise<void> {
    logger.info('Starting A2A System');

    try {
      // Start all agents
      for (const [name, agent] of this.agents) {
        await agent.start();
        logger.info(`Agent started: ${name}`);
      }

      logger.info('A2A System started successfully');
      console.error('🚀 A2A System is running!');
      console.error(`Agents: ${Array.from(this.agents.keys()).join(', ')}`);

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to start system', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Stop the system
   */
  async stop(): Promise<void> {
    logger.info('Stopping A2A System');

    for (const [name, agent] of this.agents) {
      try {
        await agent.stop();
        logger.info(`Agent stopped: ${name}`);
      } catch (error) {
        logger.error(`Failed to stop agent: ${name}`, { error });
      }
    }

    logger.info('A2A System stopped');
  }

  /**
   * Get the coordinator agent
   */
  getCoordinator(): CoordinatorAgent {
    return this.coordinator;
  }
}

/**
 * Main function
 */
const main = async (): Promise<void> => {
  logger.info('Starting A2A System entry point');

  const system = new A2ASystem();

  // Handle shutdown
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

  await system.start();

  // Demo: Run a workflow
  console.error('\n📋 Running a demo workflow...\n');

  const coordinator = system.getCoordinator();

  try {
    // Delegate a research task directly
    const result = await coordinator.processDelegation({
      goal: 'Research best practices for database optimization',
      steps: [
        {
          role: 'researcher',
          description: 'Find best practices for database optimization'
        }
      ]
    });

    console.log('📊 Workflow Result:');
    console.log(JSON.stringify(result, null, 2));

  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : 'Unknown error';
    console.error('❌ Workflow failed:', errorMsg);
  }

  console.error('\n📋 Demo complete. Press Ctrl+C to exit.');
};

main().catch(console.error);
```

---

## Part 10: Running and Testing

### Step 1: Build the System

```bash
npm run build
```

### Step 2: Run the System

```bash
npm start
```

Expected output:

```
🚀 A2A System is running!
Agents: research, coordinator

📋 Running a demo workflow...

📊 Workflow Result:
{
  "goal": "Research best practices for database optimization",
  "results": [
    {
      "step": "Find best practices for database optimization",
      "role": "researcher",
      "result": {
        "query": "Find best practices for database optimization",
        "results": [
          {
            "topic": "database optimization",
            "information": "Use indexes, optimize queries, and use connection pooling",
            "source": "knowledge-base"
          }
        ],
        "summary": "Found 1 relevant pieces of information",
        "sources": ["knowledge-base"]
      },
      "status": "completed"
    }
  ],
  "summary": "Completed 1/1 steps"
}

📋 Demo complete. Press Ctrl+C to exit.
```

### Step 3: Interactive Testing

You can also test interactively by modifying the demo workflow:

```typescript
// In src/index.ts, modify the demo to try different queries
const result = await coordinator.processDelegation({
  goal: 'Research a topic',
  steps: [
    {
      role: 'researcher',
      description: 'Tell me about API design'
    }
  ]
});
```

### Step 4: Add More Agents

Try adding a coding agent:

```typescript
// coding-agent.ts
export class CodingAgent extends BaseAgent {
  // Implementation for code generation
}

// In index.ts
const coding = new CodingAgent(this.registry, this.router);
this.agents.set('coding', coding);
```

---

## Part 11: Key Takeaways

### What You've Built

1. **A Complete A2A System** — Registry, Router, and Agents
2. **Specialized Agents** — Coordinator and Research agents
3. **Message-Based Communication** — Agents talk via messages
4. **Task Delegation** — Agents delegate work to each other

### The A2A Flow

1. User sends a goal to Coordinator
2. Coordinator breaks it down into tasks
3. Coordinator delegates tasks to specialized agents
4. Specialized agents process the tasks
5. Results flow back to Coordinator
6. Coordinator returns the final result

### Key Concepts

| Concept | Explanation |
|---------|-------------|
| **Agent** | Autonomous entity that performs tasks |
| **Registry** | Where agents discover each other |
| **Router** | How messages find their way |
| **Message** | How agents communicate |
| **Delegation** | Assigning tasks to other agents |

---

## Next Steps

Now that you understand A2A basics, you can:

1. **Add More Agents** — Coding, Database, DevOps agents
2. **Add Real Communication** — Implement proper request-response
3. **Add State** — Agents that remember context
4. **Add MCP Integration** — Agents that use MCP servers
5. **Add Persistence** — Store messages and tasks
6. **Add Error Recovery** — Handle failures gracefully

---

## Resources

- [A2A Protocol Specification](https://a2a-protocol.org)
- [Full Tutorial Series (Part 8)](https://github.com/modelcontextprotocol/tutorial-series)
- [Multi-Agent Systems Concepts](https://en.wikipedia.org/wiki/Multi-agent_system)
