# Phase 6, Part 1: AI Systems & Agentic Loops

## Building Intelligent Systems

Welcome to Phase 6! We're building AI systems that can think, plan, and act autonomously. Think of this like hiring an incredibly smart assistant who can understand complex tasks, break them down into steps, use tools to accomplish them, and learn from the results.

### 1. The Target

**What we're building:** AI agent system with LLM integration:
- Agentic loop with planning, execution, and reflection
- LLM integration for natural language understanding
- Tool use and function calling
- Stateful agent memory and context management
- Multi-step planning and execution
- Agent coordination and collaboration

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   │   ├── domain/
│   │   │   ├── agents/                        # NEW: AI Agents
│   │   │   │   ├── agent.interface.ts
│   │   │   │   ├── base-agent.ts
│   │   │   │   ├── planner-agent.ts
│   │   │   │   ├── executor-agent.ts
│   │   │   │   └── reflector-agent.ts
│   │   │   ├── tools/                        # NEW: Agent Tools
│   │   │   │   ├── tool.interface.ts
│   │   │   │   ├── task-tool.ts
│   │   │   │   ├── user-tool.ts
│   │   │   │   └── search-tool.ts
│   │   │   └── memory/                       # NEW: Agent Memory
│   │   │       ├── memory.interface.ts
│   │   │       └── vector-memory.ts
│   │   └── application/
│   │       └── handlers/
│   │           └── agent-handler.ts          # NEW: Agent request handler
│   │
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── ai/                           # NEW: AI Integration
│   │   │   │   ├── llm/
│   │   │   │   │   ├── openai-adapter.ts
│   │   │   │   │   ├── anthropic-adapter.ts
│   │   │   │   │   └── llm.interface.ts
│   │   │   │   └── embeddings/
│   │   │   │       ├── embedding-service.ts
│   │   │   │       └── vector-store.ts
│   │   │   └── agents/                       # NEW: Agent implementations
│   │   │       └── orchestrator-agent.ts
│   │   └── di/
│   │       └── container.ts (updated)
│   └── server.ts (updated)
│
├── tests/
│   ├── unit/
│   │   └── agent.test.ts
│   └── integration/
│       └── agent-flow.test.ts
│
└── infrastructure/
    └── terraform/
        └── ai.tf                            # NEW: AI infrastructure
```

### 2. The Concept: Agentic Systems

**Agentic Loop:**
An AI agent operates in a continuous cycle:

```
┌─────────────────────────────────────────────────────────────────┐
│                     AGENTIC LOOP                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                                                          │  │
│  │  ┌─────────────┐     ┌─────────────┐     ┌───────────┐  │  │
│  │  │   PERCEIVE  │────▶│    PLAN     │────▶│  EXECUTE  │  │  │
│  │  │   (Observe) │     │   (Think)   │     │  (Act)    │  │  │
│  │  └─────────────┘     └─────────────┘     └───────────┘  │  │
│  │         │                    │                  │        │  │
│  │         │                    ▼                  ▼        │  │
│  │         │            ┌─────────────┐     ┌───────────┐  │  │
│  │         └────────────│   REFLECT   │────▶│   TOOLS   │  │  │
│  │                      │   (Learn)   │     │   (Use)   │  │  │
│  │                      └─────────────┘     └───────────┘  │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Memory: Context, History, Knowledge                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Agent Components:**
1. **Perception:** Understanding the current state and user input
2. **Planning:** Breaking down goals into actionable steps
3. **Execution:** Performing actions using tools
4. **Reflection:** Evaluating results and learning

### 3. The Implementation

#### Step 1: AI Dependencies

Update `packages/gateway/package.json`:

```json
{
  "dependencies": {
    // ... existing dependencies
    "openai": "^4.24.0",
    "langchain": "^0.1.0",
    "@anthropic-ai/sdk": "^0.9.0",
    "chromadb": "^1.7.0"
  },
  "devDependencies": {
    // ... existing dev dependencies
    "@types/langchain": "^0.1.0"
  }
}
```

#### Step 2: LLM Interface

**File:** `packages/gateway/src/infrastructure/adapters/ai/llm/llm.interface.ts`

```typescript
/**
 * LLM Message
 */
export interface LLMMessage {
  role: 'system' | 'user' | 'assistant' | 'tool';
  content: string;
  name?: string;
  toolCalls?: LLMToolCall[];
  toolCallId?: string;
}

/**
 * LLM Tool Call
 */
export interface LLMToolCall {
  id: string;
  type: 'function';
  function: {
    name: string;
    arguments: string;
  };
}

/**
 * LLM Response
 */
export interface LLMResponse {
  id: string;
  content: string;
  toolCalls: LLMToolCall[];
  usage: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  finishReason: 'stop' | 'tool_calls' | 'length' | 'error';
}

/**
 * LLM Completion Options
 */
export interface LLMCompletionOptions {
  temperature?: number;
  maxTokens?: number;
  topP?: number;
  stopSequences?: string[];
  tools?: LLMToolDefinition[];
  toolChoice?: 'auto' | 'none' | { type: 'function'; function: { name: string } };
}

/**
 * LLM Tool Definition
 */
export interface LLMToolDefinition {
  type: 'function';
  function: {
    name: string;
    description: string;
    parameters: {
      type: 'object';
      properties: Record<string, any>;
      required?: string[];
    };
  };
}

/**
 * LLM Adapter Interface
 * 
 * Defines the contract for LLM integration.
 * This allows us to swap between different LLM providers.
 */
export interface ILLMAdapter {
  /**
   * Generate a completion from messages
   */
  complete(
    messages: LLMMessage[],
    options?: LLMCompletionOptions
  ): Promise<LLMResponse>;

  /**
   * Stream a completion
   */
  stream(
    messages: LLMMessage[],
    options?: LLMCompletionOptions
  ): AsyncIterable<LLMResponse>;

  /**
   * Get embedding for text
   */
  embed(text: string): Promise<number[]>;

  /**
   * Get embedding for multiple texts
   */
  embedBatch(texts: string[]): Promise<number[][]>;
}
```

#### Step 3: OpenAI Adapter

**File:** `packages/gateway/src/infrastructure/adapters/ai/llm/openai-adapter.ts`

```typescript
import OpenAI from 'openai';
import {
  ILLMAdapter,
  LLMMessage,
  LLMResponse,
  LLMCompletionOptions,
  LLMToolCall,
  LLMToolDefinition,
} from './llm.interface.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * OpenAI Adapter
 * 
 * Implements the LLM interface for OpenAI's API.
 */
export class OpenAIAdapter implements ILLMAdapter {
  private client: OpenAI;
  private readonly logger = createChildLogger({ module: 'OpenAIAdapter' });
  private model: string;

  constructor(options?: {
    apiKey?: string;
    model?: string;
    organization?: string;
  }) {
    this.model = options?.model || 'gpt-4-turbo-preview';
    
    this.client = new OpenAI({
      apiKey: options?.apiKey || process.env.OPENAI_API_KEY,
      organization: options?.organization || process.env.OPENAI_ORGANIZATION,
    });
  }

  /**
   * Generate a completion
   */
  async complete(
    messages: LLMMessage[],
    options?: LLMCompletionOptions
  ): Promise<LLMResponse> {
    this.logger.debug({
      messageCount: messages.length,
      model: this.model,
    }, 'Generating completion');

    try {
      const response = await this.client.chat.completions.create({
        model: this.model,
        messages: this.mapMessages(messages),
        temperature: options?.temperature ?? 0.7,
        max_tokens: options?.maxTokens ?? 1000,
        top_p: options?.topP ?? 1,
        stop: options?.stopSequences,
        tools: options?.tools?.map(t => this.mapTool(t)),
        tool_choice: options?.toolChoice as any,
      });

      const choice = response.choices[0];
      const message = choice.message;

      return {
        id: response.id,
        content: message.content || '',
        toolCalls: message.tool_calls?.map(tc => ({
          id: tc.id,
          type: 'function' as const,
          function: {
            name: tc.function.name,
            arguments: tc.function.arguments,
          },
        })) || [],
        usage: {
          promptTokens: response.usage?.prompt_tokens || 0,
          completionTokens: response.usage?.completion_tokens || 0,
          totalTokens: response.usage?.total_tokens || 0,
        },
        finishReason: choice.finish_reason as 'stop' | 'tool_calls' | 'length' | 'error',
      };
    } catch (error) {
      this.logger.error({ error }, 'OpenAI completion failed');
      throw error;
    }
  }

  /**
   * Stream a completion
   */
  async *stream(
    messages: LLMMessage[],
    options?: LLMCompletionOptions
  ): AsyncIterable<LLMResponse> {
    this.logger.debug({
      messageCount: messages.length,
      model: this.model,
    }, 'Streaming completion');

    try {
      const stream = await this.client.chat.completions.create({
        model: this.model,
        messages: this.mapMessages(messages),
        temperature: options?.temperature ?? 0.7,
        max_tokens: options?.maxTokens ?? 1000,
        top_p: options?.topP ?? 1,
        stop: options?.stopSequences,
        tools: options?.tools?.map(t => this.mapTool(t)),
        tool_choice: options?.toolChoice as any,
        stream: true,
      });

      for await (const chunk of stream) {
        const choice = chunk.choices[0];
        const delta = choice.delta;

        yield {
          id: chunk.id,
          content: delta.content || '',
          toolCalls: delta.tool_calls?.map(tc => ({
            id: tc.id || '',
            type: 'function' as const,
            function: {
              name: tc.function?.name || '',
              arguments: tc.function?.arguments || '',
            },
          })) || [],
          usage: {
            promptTokens: chunk.usage?.prompt_tokens || 0,
            completionTokens: chunk.usage?.completion_tokens || 0,
            totalTokens: chunk.usage?.total_tokens || 0,
          },
          finishReason: choice.finish_reason as 'stop' | 'tool_calls' | 'length' | 'error',
        };
      }
    } catch (error) {
      this.logger.error({ error }, 'OpenAI stream failed');
      throw error;
    }
  }

  /**
   * Get embedding for text
   */
  async embed(text: string): Promise<number[]> {
    try {
      const response = await this.client.embeddings.create({
        model: 'text-embedding-3-small',
        input: text,
      });

      return response.data[0].embedding;
    } catch (error) {
      this.logger.error({ error }, 'Embedding generation failed');
      throw error;
    }
  }

  /**
   * Get embeddings for multiple texts
   */
  async embedBatch(texts: string[]): Promise<number[][]> {
    try {
      const response = await this.client.embeddings.create({
        model: 'text-embedding-3-small',
        input: texts,
      });

      return response.data.map(item => item.embedding);
    } catch (error) {
      this.logger.error({ error }, 'Batch embedding generation failed');
      throw error;
    }
  }

  /**
   * Map internal messages to OpenAI format
   */
  private mapMessages(messages: LLMMessage[]): any[] {
    return messages.map(msg => {
      const base: any = {
        role: msg.role,
        content: msg.content,
      };

      if (msg.name) {
        base.name = msg.name;
      }

      if (msg.toolCalls) {
        base.tool_calls = msg.toolCalls.map(tc => ({
          id: tc.id,
          type: tc.type,
          function: {
            name: tc.function.name,
            arguments: tc.function.arguments,
          },
        }));
      }

      if (msg.toolCallId) {
        base.tool_call_id = msg.toolCallId;
      }

      return base;
    });
  }

  /**
   * Map internal tool definition to OpenAI format
   */
  private mapTool(tool: LLMToolDefinition): any {
    return {
      type: tool.type,
      function: {
        name: tool.function.name,
        description: tool.function.description,
        parameters: tool.function.parameters,
      },
    };
  }
}
```

#### Step 4: Agent Tools

**File:** `packages/gateway/src/core/domain/tools/tool.interface.ts`

```typescript
/**
 * Tool Definition
 */
export interface ToolDefinition {
  name: string;
  description: string;
  parameters: {
    type: 'object';
    properties: Record<string, any>;
    required?: string[];
  };
}

/**
 * Tool Result
 */
export interface ToolResult {
  success: boolean;
  data?: any;
  error?: string;
  metadata?: Record<string, any>;
}

/**
 * Tool Interface
 * 
 * Defines a tool that an agent can use.
 * Tools are the agent's hands - they allow the agent
 * to interact with the world.
 */
export interface ITool {
  /**
   * Get the tool definition for LLM
   */
  getDefinition(): ToolDefinition;

  /**
   * Execute the tool
   */
  execute(params: Record<string, any>): Promise<ToolResult>;

  /**
   * Validate parameters
   */
  validate(params: Record<string, any>): boolean;
}

/**
 * Tool Registry
 * 
 * Manages available tools for agents.
 */
export class ToolRegistry {
  private tools: Map<string, ITool> = new Map();

  /**
   * Register a tool
   */
  register(tool: ITool): void {
    this.tools.set(tool.getDefinition().name, tool);
  }

  /**
   * Get a tool by name
   */
  get(name: string): ITool | undefined {
    return this.tools.get(name);
  }

  /**
   * Get all tool definitions
   */
  getDefinitions(): ToolDefinition[] {
    return Array.from(this.tools.values()).map(t => t.getDefinition());
  }

  /**
   * Execute a tool by name
   */
  async execute(name: string, params: Record<string, any>): Promise<ToolResult> {
    const tool = this.tools.get(name);
    if (!tool) {
      return {
        success: false,
        error: `Tool '${name}' not found`,
      };
    }

    if (!tool.validate(params)) {
      return {
        success: false,
        error: `Invalid parameters for tool '${name}'`,
      };
    }

    try {
      return await tool.execute(params);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }
}
```

**File:** `packages/gateway/src/core/domain/tools/task-tool.ts`

```typescript
import { ITool, ToolDefinition, ToolResult } from './tool.interface.js';
import { TaskDomainService } from '../services/task.service.js';

/**
 * Task Tool
 * 
 * Allows the agent to create, update, and manage tasks.
 */
export class TaskTool implements ITool {
  constructor(private readonly taskService: TaskDomainService) {}

  getDefinition(): ToolDefinition {
    return {
      name: 'manage_task',
      description: 'Create, update, or manage tasks in the system',
      parameters: {
        type: 'object',
        properties: {
          action: {
            type: 'string',
            enum: ['create', 'update', 'complete', 'delete'],
            description: 'The action to perform on the task',
          },
          taskId: {
            type: 'string',
            description: 'The task ID (required for update, complete, delete)',
          },
          title: {
            type: 'string',
            description: 'The task title (required for create, optional for update)',
          },
          description: {
            type: 'string',
            description: 'The task description (required for create, optional for update)',
          },
          priority: {
            type: 'string',
            enum: ['low', 'medium', 'high', 'critical'],
            description: 'Task priority',
          },
          dueDate: {
            type: 'string',
            format: 'date-time',
            description: 'Task due date in ISO format',
          },
          userId: {
            type: 'string',
            description: 'The user ID (required for create)',
          },
        },
        required: ['action', 'userId'],
      },
    };
  }

  validate(params: Record<string, any>): boolean {
    const { action, userId } = params;
    
    if (!userId) return false;
    
    switch (action) {
      case 'create':
        return !!(params.title && params.description);
      case 'update':
        return !!(params.taskId && (params.title || params.description || params.priority));
      case 'complete':
      case 'delete':
        return !!params.taskId;
      default:
        return false;
    }
  }

  async execute(params: Record<string, any>): Promise<ToolResult> {
    const { action, userId, taskId, title, description, priority, dueDate } = params;

    try {
      switch (action) {
        case 'create':
          const task = await this.taskService.createTask({
            userId,
            title,
            description,
            priority: priority || 'medium',
            dueDate: dueDate ? new Date(dueDate) : undefined,
          });
          return {
            success: true,
            data: task.toJSON(),
            metadata: { action: 'create' },
          };

        case 'update':
          let updatedTask = await this.taskService.getTaskById(taskId, userId);
          if (!updatedTask) {
            return { success: false, error: 'Task not found' };
          }

          if (title || description) {
            updatedTask = await this.taskService.updateTaskDetails(
              taskId,
              userId,
              title || updatedTask.title,
              description || updatedTask.description
            );
          }

          if (priority) {
            updatedTask = await this.taskService.updateTaskPriority(taskId, userId, priority);
          }

          if (dueDate) {
            updatedTask = await this.taskService.updateTaskDueDate(taskId, userId, new Date(dueDate));
          }

          return {
            success: true,
            data: updatedTask.toJSON(),
            metadata: { action: 'update' },
          };

        case 'complete':
          const completedTask = await this.taskService.completeTask(taskId, userId);
          return {
            success: true,
            data: completedTask.toJSON(),
            metadata: { action: 'complete' },
          };

        case 'delete':
          const deleted = await this.taskService.deleteTask(taskId, userId);
          return {
            success: deleted,
            data: { deleted },
            metadata: { action: 'delete' },
          };

        default:
          return {
            success: false,
            error: `Unknown action: ${action}`,
          };
      }
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error),
      };
    }
  }
}
```

#### Step 5: Agent Memory

**File:** `packages/gateway/src/core/domain/memory/memory.interface.ts`

```typescript
/**
 * Memory Entry
 */
export interface MemoryEntry {
  id: string;
  content: string;
  type: 'observation' | 'thought' | 'action' | 'reflection';
  timestamp: Date;
  metadata?: Record<string, any>;
  embedding?: number[];
}

/**
 * Memory Search Result
 */
export interface MemorySearchResult {
  entry: MemoryEntry;
  score: number;
}

/**
 * Memory Interface
 * 
 * Agent memory stores past experiences, knowledge, and context.
 * It allows agents to learn from past actions and build knowledge.
 */
export interface IMemory {
  /**
   * Store a memory entry
   */
  store(entry: Omit<MemoryEntry, 'id' | 'timestamp'>): Promise<string>;

  /**
   * Get a memory entry
   */
  get(id: string): Promise<MemoryEntry | null>;

  /**
   * Search for memories
   */
  search(query: string, limit?: number): Promise<MemorySearchResult[]>;

  /**
   * Get recent memories
   */
  getRecent(limit?: number, type?: string[]): Promise<MemoryEntry[]>;

  /**
   * Get context for a conversation
   */
  getContext(maxTokens?: number): Promise<string>;

  /**
   * Clear all memories (for testing)
   */
  clear(): Promise<void>;

  /**
   * Get memory statistics
   */
  getStats(): Promise<{
    totalEntries: number;
    types: Record<string, number>;
    lastUpdated: Date;
  }>;
}
```

**File:** `packages/gateway/src/core/domain/memory/vector-memory.ts`

```typescript
import { MemoryEntry, MemorySearchResult, IMemory } from './memory.interface.js';
import { ILLMAdapter } from '../../../infrastructure/adapters/ai/llm/llm.interface.js';
import { createChildLogger } from '../../../logger.js';
import { randomUUID } from 'crypto';

/**
 * Vector Memory
 * 
 * Memory implementation using vector embeddings.
 * 
 * This allows semantic search of memories using LLM embeddings.
 * Memories are stored with their embeddings for efficient similarity search.
 */
export class VectorMemory implements IMemory {
  private readonly logger = createChildLogger({ module: 'VectorMemory' });
  private memories: Map<string, MemoryEntry> = new Map();
  private readonly maxContextTokens = 4000;

  constructor(private readonly llm: ILLMAdapter) {}

  /**
   * Store a memory entry
   */
  async store(entry: Omit<MemoryEntry, 'id' | 'timestamp'>): Promise<string> {
    const id = randomUUID();
    const timestamp = new Date();

    // Generate embedding for the content
    const embedding = await this.llm.embed(entry.content);

    const memoryEntry: MemoryEntry = {
      ...entry,
      id,
      timestamp,
      embedding,
    };

    this.memories.set(id, memoryEntry);

    this.logger.debug({
      id,
      type: entry.type,
      contentLength: entry.content.length,
    }, 'Memory stored');

    return id;
  }

  /**
   * Get a memory entry
   */
  async get(id: string): Promise<MemoryEntry | null> {
    return this.memories.get(id) || null;
  }

  /**
   * Search for memories
   */
  async search(query: string, limit: number = 10): Promise<MemorySearchResult[]> {
    // Get embedding for the query
    const queryEmbedding = await this.llm.embed(query);

    // Calculate similarity scores
    const results: MemorySearchResult[] = [];

    for (const entry of this.memories.values()) {
      if (!entry.embedding) continue;

      const score = this.cosineSimilarity(queryEmbedding, entry.embedding);
      results.push({ entry, score });
    }

    // Sort by score (highest first)
    results.sort((a, b) => b.score - a.score);

    // Return top results
    return results.slice(0, limit);
  }

  /**
   * Get recent memories
   */
  async getRecent(limit: number = 10, types?: string[]): Promise<MemoryEntry[]> {
    let entries = Array.from(this.memories.values());

    // Filter by type
    if (types && types.length > 0) {
      entries = entries.filter(e => types.includes(e.type));
    }

    // Sort by timestamp (newest first)
    entries.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());

    return entries.slice(0, limit);
  }

  /**
   * Get context for a conversation
   */
  async getContext(maxTokens: number = this.maxContextTokens): Promise<string> {
    // Get recent memories
    const recent = await this.getRecent(50);

    // Build context from memories
    const context = recent
      .filter(m => m.type !== 'reflection')
      .map(m => {
        const timestamp = m.timestamp.toISOString();
        return `[${timestamp}] ${m.type.toUpperCase()}: ${m.content}`;
      })
      .join('\n');

    // Truncate to max tokens (approximate)
    const words = context.split(' ');
    const truncated = words.slice(0, maxTokens / 2).join(' ');

    return truncated;
  }

  /**
   * Clear all memories
   */
  async clear(): Promise<void> {
    this.memories.clear();
    this.logger.info('Memory cleared');
  }

  /**
   * Get memory statistics
   */
  async getStats(): Promise<{
    totalEntries: number;
    types: Record<string, number>;
    lastUpdated: Date;
  }> {
    const types: Record<string, number> = {};
    let lastUpdated = new Date(0);

    for (const entry of this.memories.values()) {
      types[entry.type] = (types[entry.type] || 0) + 1;
      if (entry.timestamp > lastUpdated) {
        lastUpdated = entry.timestamp;
      }
    }

    return {
      totalEntries: this.memories.size,
      types,
      lastUpdated,
    };
  }

  /**
   * Calculate cosine similarity between two vectors
   */
  private cosineSimilarity(a: number[], b: number[]): number {
    if (a.length !== b.length) {
      throw new Error('Vectors must have the same length');
    }

    let dotProduct = 0;
    let normA = 0;
    let normB = 0;

    for (let i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA === 0 || normB === 0) {
      return 0;
    }

    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }
}
```

#### Step 6: Base Agent

**File:** `packages/gateway/src/core/domain/agents/base-agent.ts`

```typescript
import { IMemory } from '../memory/memory.interface.js';
import { ToolRegistry } from '../tools/tool.interface.js';
import { ILLMAdapter, LLMMessage, LLMCompletionOptions } from '../../../infrastructure/adapters/ai/llm/llm.interface.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Agent Configuration
 */
export interface AgentConfig {
  name: string;
  description?: string;
  systemPrompt: string;
  maxIterations?: number;
  temperature?: number;
  maxTokens?: number;
}

/**
 * Agent State
 */
export interface AgentState {
  id: string;
  config: AgentConfig;
  memory: IMemory;
  tools: ToolRegistry;
  iteration: number;
  completed: boolean;
  error?: string;
  result?: any;
}

/**
 * Base Agent
 * 
 * Abstract base class for all agents.
 * Implements the core agentic loop with perception, planning, execution, and reflection.
 */
export abstract class BaseAgent {
  protected readonly logger = createChildLogger({ module: 'BaseAgent' });
  protected state: AgentState;

  constructor(
    protected readonly config: AgentConfig,
    protected readonly memory: IMemory,
    protected readonly tools: ToolRegistry,
    protected readonly llm: ILLMAdapter
  ) {
    this.state = {
      id: `agent_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
      config,
      memory,
      tools,
      iteration: 0,
      completed: false,
    };
  }

  /**
   * Run the agent
   */
  async run(task: string): Promise<any> {
    this.logger.info({
      agent: this.config.name,
      task,
    }, 'Agent starting');

    // Store the task in memory
    await this.memory.store({
      content: `Task: ${task}`,
      type: 'observation',
      metadata: { task },
    });

    // Agentic loop
    while (!this.state.completed && this.state.iteration < (this.config.maxIterations || 10)) {
      this.state.iteration++;
      
      this.logger.debug({
        agent: this.config.name,
        iteration: this.state.iteration,
      }, 'Agent iteration');

      try {
        // 1. Perceive - understand current state
        await this.perceive();

        // 2. Plan - decide what to do next
        const plan = await this.plan();

        // 3. Execute - take action
        await this.execute(plan);

        // 4. Reflect - learn from the action
        await this.reflect();

      } catch (error) {
        this.logger.error({
          agent: this.config.name,
          iteration: this.state.iteration,
          error,
        }, 'Agent iteration failed');

        await this.memory.store({
          content: `Error: ${error instanceof Error ? error.message : String(error)}`,
          type: 'reflection',
          metadata: { error: String(error) },
        });

        // Try to recover
        await this.recover(error);
      }
    }

    this.logger.info({
      agent: this.config.name,
      iterations: this.state.iteration,
      completed: this.state.completed,
    }, 'Agent finished');

    return this.state.result;
  }

  /**
   * Perceive - understand current state
   */
  protected async perceive(): Promise<void> {
    // Get context from memory
    const context = await this.memory.getContext();
    
    await this.memory.store({
      content: `Current context: ${context.substring(0, 500)}`,
      type: 'observation',
    });
  }

  /**
   * Plan - decide what to do next
   */
  protected async plan(): Promise<any> {
    // Get tools
    const tools = this.tools.getDefinitions();

    // Build messages
    const messages: LLMMessage[] = [
      {
        role: 'system',
        content: this.config.systemPrompt,
      },
    ];

    // Add recent memories
    const recent = await this.memory.getRecent(10);
    for (const memory of recent) {
      messages.push({
        role: 'assistant',
        content: `${memory.type}: ${memory.content}`,
      });
    }

    // Add prompt for planning
    messages.push({
      role: 'user',
      content: `Based on the current state, what should I do next? Be specific and actionable. Available tools: ${tools.map(t => t.name).join(', ')}`,
    });

    // Get LLM response
    const response = await this.llm.complete(messages, {
      temperature: this.config.temperature || 0.7,
      maxTokens: this.config.maxTokens || 500,
      tools: tools.map(t => ({
        type: 'function' as const,
        function: {
          name: t.name,
          description: t.description,
          parameters: t.parameters,
        },
      })),
    });

    // Store the plan
    await this.memory.store({
      content: `Plan: ${response.content}`,
      type: 'thought',
      metadata: { toolCalls: response.toolCalls },
    });

    return response;
  }

  /**
   * Execute - take action
   */
  protected async execute(plan: any): Promise<void> {
    if (!plan.toolCalls || plan.toolCalls.length === 0) {
      // No tools to call - just continue
      await this.memory.store({
        content: `Proceeding without tools: ${plan.content}`,
        type: 'action',
      });
      return;
    }

    // Execute each tool call
    for (const toolCall of plan.toolCalls) {
      const { name, arguments: args } = toolCall.function;
      const params = JSON.parse(args);

      this.logger.debug({
        tool: name,
        params,
      }, 'Executing tool');

      // Execute the tool
      const result = await this.tools.execute(name, params);

      // Store the result
      await this.memory.store({
        content: `Tool ${name} result: ${JSON.stringify(result.data || result.error)}`,
        type: 'action',
        metadata: {
          tool: name,
          result,
        },
      });

      if (!result.success) {
        throw new Error(`Tool ${name} failed: ${result.error}`);
      }
    }
  }

  /**
   * Reflect - learn from the action
   */
  protected async reflect(): Promise<void> {
    // Get recent actions
    const actions = await this.memory.getRecent(5, ['action']);
    
    if (actions.length === 0) return;

    // Build reflection prompt
    const messages: LLMMessage[] = [
      {
        role: 'system',
        content: `You are reflecting on the recent actions of an AI agent. What went well? What could be improved? What should you do next?`,
      },
      {
        role: 'user',
        content: `Recent actions:\n${actions.map(a => `- ${a.content}`).join('\n')}\n\nReflect on these actions and learn from them.`,
      },
    ];

    // Get reflection
    const response = await this.llm.complete(messages, {
      temperature: 0.3,
      maxTokens: 300,
    });

    // Store reflection
    await this.memory.store({
      content: `Reflection: ${response.content}`,
      type: 'reflection',
    });

    // Check if task is complete
    if (response.content.toLowerCase().includes('task complete') ||
        response.content.toLowerCase().includes('all done')) {
      this.state.completed = true;
      this.state.result = response.content;
    }
  }

  /**
   * Recover from an error
   */
  protected async recover(error: unknown): Promise<void> {
    const errorMessage = error instanceof Error ? error.message : String(error);
    
    this.logger.warn({
      agent: this.config.name,
      error: errorMessage,
    }, 'Attempting recovery');

    // Store error in memory
    await this.memory.store({
      content: `Attempting recovery from: ${errorMessage}`,
      type: 'reflection',
    });

    // Try a different approach
    if (this.state.iteration > 3) {
      this.logger.warn({
        agent: this.config.name,
        iterations: this.state.iteration,
      }, 'Too many errors - marking as failed');
      
      this.state.completed = true;
      this.state.error = errorMessage;
      throw error;
    }
  }

  /**
   * Get agent state
   */
  getState(): AgentState {
    return this.state;
  }

  /**
   * Get memory
   */
  getMemory(): IMemory {
    return this.memory;
  }

  /**
   * Stop the agent
   */
  stop(): void {
    this.state.completed = true;
    this.logger.info({ agent: this.config.name }, 'Agent stopped');
  }
}
```

#### Step 7: Orchestrator Agent

**File:** `packages/gateway/src/infrastructure/adapters/agents/orchestrator-agent.ts`

```typescript
import { BaseAgent } from '../../../core/domain/agents/base-agent.js';
import { ToolRegistry } from '../../../core/domain/tools/tool.interface.js';
import { IMemory } from '../../../core/domain/memory/memory.interface.js';
import { ILLMAdapter } from '../ai/llm/llm.interface.js';

/**
 * Orchestrator Agent
 * 
 * A specialized agent that orchestrates other agents and tools.
 * 
 * This agent can:
 * 1. Break down complex tasks into subtasks
 * 2. Delegate subtasks to specialized agents
 * 3. Coordinate execution across multiple agents
 * 4. Synthesize results into a final response
 */
export class OrchestratorAgent extends BaseAgent {
  private subAgents: BaseAgent[] = [];

  constructor(
    memory: IMemory,
    tools: ToolRegistry,
    llm: ILLMAdapter,
    config?: Partial<BaseAgent['config']>
  ) {
    super(
      {
        name: 'Orchestrator',
        description: 'An agent that orchestrates other agents and tools to complete complex tasks',
        systemPrompt: `You are an orchestrator agent that coordinates other agents and tools to complete tasks.

Your responsibilities:
1. Break down complex tasks into subtasks
2. Delegate subtasks to appropriate agents
3. Coordinate execution
4. Synthesize results

When breaking down tasks, consider:
- What subtasks are needed?
- What order should they be done in?
- What agents/tools are needed for each subtask?
- How will results be combined?

Always verify subtask completion before proceeding.`,
        maxIterations: 20,
        temperature: 0.7,
        maxTokens: 1000,
        ...config,
      },
      memory,
      tools,
      llm
    );
  }

  /**
   * Register a sub-agent
   */
  registerSubAgent(agent: BaseAgent): void {
    this.subAgents.push(agent);
    this.logger.info({
      agent: agent.config.name,
    }, 'Sub-agent registered');
  }

  /**
   * Execute the orchestrator
   */
  protected async execute(plan: any): Promise<void> {
    // Check if we need to delegate
    if (plan.toolCalls && plan.toolCalls.length > 0) {
      // Execute tools directly
      await super.execute(plan);
      return;
    }

    // Parse the plan for sub-tasks
    const subtasks = this.parseSubTasks(plan.content);

    if (subtasks.length === 0) {
      // No subtasks - just continue
      await this.memory.store({
        content: `Continuing without subtasks: ${plan.content}`,
        type: 'action',
      });
      return;
    }

    // Execute subtasks
    const results = [];
    for (const subtask of subtasks) {
      this.logger.debug({ subtask }, 'Executing subtask');
      
      const result = await this.executeSubTask(subtask);
      results.push(result);
    }

    // Store results
    await this.memory.store({
      content: `Subtask results: ${JSON.stringify(results)}`,
      type: 'action',
      metadata: { subtasks: results },
    });
  }

  /**
   * Parse subtasks from plan
   */
  private parseSubTasks(plan: string): string[] {
    // Look for numbered lists or bullet points
    const lines = plan.split('\n');
    const subtasks: string[] = [];

    for (const line of lines) {
      const trimmed = line.trim();
      
      // Check for numbered list or bullet
      if (trimmed.match(/^\d+[\.\)]\s/) || trimmed.match(/^[\-\*]\s/)) {
        // Remove the list marker
        const task = trimmed.replace(/^[\d\.\)\s]+/, '').replace(/^[\-\*\s]+/, '').trim();
        if (task) {
          subtasks.push(task);
        }
      }
    }

    return subtasks;
  }

  /**
   * Execute a subtask
   */
  private async executeSubTask(subtask: string): Promise<any> {
    // Find the best agent for this subtask
    const agent = this.findBestAgent(subtask);

    if (agent) {
      // Delegate to the agent
      return await agent.run(subtask);
    }

    // No suitable agent - use tools directly
    const messages = [
      {
        role: 'system' as const,
        content: `Execute this subtask using available tools: ${this.tools.getDefinitions().map(t => t.name).join(', ')}`,
      },
      {
        role: 'user' as const,
        content: subtask,
      },
    ];

    const response = await this.llm.complete(messages, {
      temperature: 0.5,
      maxTokens: 500,
      tools: this.tools.getDefinitions().map(t => ({
        type: 'function' as const,
        function: {
          name: t.name,
          description: t.description,
          parameters: t.parameters,
        },
      })),
    });

    // Execute any tool calls
    if (response.toolCalls && response.toolCalls.length > 0) {
      const results = [];
      for (const toolCall of response.toolCalls) {
        const { name, arguments: args } = toolCall.function;
        const result = await this.tools.execute(name, JSON.parse(args));
        results.push(result);
      }
      return results;
    }

    return response.content;
  }

  /**
   * Find the best agent for a subtask
   */
  private findBestAgent(subtask: string): BaseAgent | null {
    // Simple keyword matching
    const keywords = {
      'task': ['task', 'todo', 'work item'],
      'user': ['user', 'profile', 'account'],
      'search': ['search', 'find', 'lookup'],
    };

    const lowerSubtask = subtask.toLowerCase();

    for (const agent of this.subAgents) {
      const agentName = agent.config.name.toLowerCase();
      const matchedKeywords = keywords[agentName as keyof typeof keywords] || [];
      
      for (const keyword of matchedKeywords) {
        if (lowerSubtask.includes(keyword)) {
          return agent;
        }
      }
    }

    return null;
  }
}
```

### 4. The Verification

#### Step 1: Test Agent Memory

**File:** `packages/gateway/tests/unit/memory.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { VectorMemory } from '../../src/core/domain/memory/vector-memory.js';
import { OpenAIAdapter } from '../../src/infrastructure/adapters/ai/llm/openai-adapter.js';

describe('Vector Memory', () => {
  let memory: VectorMemory;

  beforeAll(() => {
    const llm = new OpenAIAdapter({ model: 'text-embedding-3-small' });
    memory = new VectorMemory(llm);
  });

  it('should store and retrieve memories', async () => {
    const id = await memory.store({
      content: 'Test memory content',
      type: 'observation',
      metadata: { test: true },
    });

    const retrieved = await memory.get(id);
    expect(retrieved).toBeDefined();
    expect(retrieved?.content).toBe('Test memory content');
    expect(retrieved?.type).toBe('observation');
  });

  it('should search memories', async () => {
    await memory.store({
      content: 'The user wants to create a new task',
      type: 'observation',
    });
    await memory.store({
      content: 'Tasks can be prioritized as low, medium, high, or critical',
      type: 'knowledge',
    });
    await memory.store({
      content: 'Users can only access their own tasks',
      type: 'knowledge',
    });

    const results = await memory.search('task priority');
    expect(results.length).toBeGreaterThan(0);
    expect(results[0].entry.content).toContain('prioritized');
  });

  it('should get recent memories', async () => {
    const entries = await memory.getRecent(2);
    expect(entries.length).toBeLessThanOrEqual(2);
  });

  it('should get context', async () => {
    const context = await memory.getContext();
    expect(context).toBeTruthy();
  });
});
```

#### Step 2: Test Agent Tools

**File:** `packages/gateway/tests/unit/tools.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { ToolRegistry } from '../../src/core/domain/tools/tool.interface.js';
import { TaskTool } from '../../src/core/domain/tools/task-tool.js';
import { InMemoryTaskRepository } from '../../src/infrastructure/adapters/persistence/in-memory/task.repository.js';
import { InMemoryUserRepository } from '../../src/infrastructure/adapters/persistence/in-memory/user.repository.js';
import { TaskDomainService } from '../../src/core/domain/services/task.service.js';

describe('Agent Tools', () => {
  let registry: ToolRegistry;
  let taskService: TaskDomainService;

  beforeAll(() => {
    const taskRepo = new InMemoryTaskRepository();
    const userRepo = new InMemoryUserRepository();
    taskService = new TaskDomainService(taskRepo, userRepo);
    registry = new ToolRegistry();
    registry.register(new TaskTool(taskService));
  });

  it('should get tool definitions', () => {
    const definitions = registry.getDefinitions();
    expect(definitions).toHaveLength(1);
    expect(definitions[0].name).toBe('manage_task');
  });

  it('should validate tool parameters', () => {
    const tool = registry.get('manage_task');
    expect(tool).toBeDefined();

    const valid = tool!.validate({
      action: 'create',
      userId: 'user-123',
      title: 'Test Task',
      description: 'A test task',
    });
    expect(valid).toBe(true);

    const invalid = tool!.validate({
      action: 'create',
      userId: 'user-123',
    });
    expect(invalid).toBe(false);
  });

  it('should execute tool', async () => {
    const result = await registry.execute('manage_task', {
      action: 'create',
      userId: 'user-123',
      title: 'Test Task',
      description: 'A test task',
      priority: 'high',
    });

    expect(result.success).toBe(true);
    expect(result.data.title).toBe('Test Task');
    expect(result.data.priority).toBe('high');
  });
});
```

#### Step 3: Test Full Agent Flow

**File:** `packages/gateway/tests/integration/agent-flow.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { OrchestratorAgent } from '../../src/infrastructure/adapters/agents/orchestrator-agent.js';
import { VectorMemory } from '../../src/core/domain/memory/vector-memory.js';
import { ToolRegistry } from '../../src/core/domain/tools/tool.interface.js';
import { TaskTool } from '../../src/core/domain/tools/task-tool.js';
import { OpenAIAdapter } from '../../src/infrastructure/adapters/ai/llm/openai-adapter.js';
import { InMemoryTaskRepository } from '../../src/infrastructure/adapters/persistence/in-memory/task.repository.js';
import { InMemoryUserRepository } from '../../src/infrastructure/adapters/persistence/in-memory/user.repository.js';
import { TaskDomainService } from '../../src/core/domain/services/task.service.js';

describe('Agent Flow Integration Tests', () => {
  let orchestrator: OrchestratorAgent;
  let memory: VectorMemory;

  beforeAll(() => {
    const llm = new OpenAIAdapter();
    memory = new VectorMemory(llm);

    // Setup tools
    const taskRepo = new InMemoryTaskRepository();
    const userRepo = new InMemoryUserRepository();
    const taskService = new TaskDomainService(taskRepo, userRepo);
    
    const tools = new ToolRegistry();
    tools.register(new TaskTool(taskService));

    // Create orchestrator
    orchestrator = new OrchestratorAgent(memory, tools, llm);
  });

  it('should complete a task from start to finish', async () => {
    const task = 'Create a high-priority task called "Build the AI system" with description "Implement agentic loops"';

    const result = await orchestrator.run(task);

    expect(orchestrator.getState().completed).toBe(true);
    expect(result).toBeDefined();
  }, 30000);

  it('should store memories during execution', async () => {
    const stats = await memory.getStats();
    expect(stats.totalEntries).toBeGreaterThan(0);
    
    const types = stats.types;
    expect(types.observation).toBeDefined();
    expect(types.thought).toBeDefined();
    expect(types.action).toBeDefined();
  });

  it('should use tools effectively', async () => {
    // Check if a task was created
    const taskTool = orchestrator['tools'].get('manage_task');
    expect(taskTool).toBeDefined();
  });
});
```

### 5. Deep Dive: Agent Design Patterns

#### Reflection Pattern

The reflection pattern allows agents to learn from their actions:

```typescript
// Each iteration
1. Act: Perform an action
2. Observe: See the result
3. Reflect: Analyze what worked and what didn't
4. Plan: Adjust strategy based on reflection
```

#### Tool Design Principles

**1. Single Responsibility:**
```typescript
// Good: One tool, one purpose
class CreateTaskTool { /* ... */ }
class UpdateTaskTool { /* ... */ }
class DeleteTaskTool { /* ... */ }

// Bad: One tool does everything
class TaskTool { /* ... */ }
```

**2. Clear Contracts:**
```typescript
interface ToolContract {
  parameters: {
    type: 'object';
    properties: Record<string, any>;
    required: string[];
  };
  returns: {
    success: boolean;
    data?: any;
    error?: string;
  };
}
```

**3. Error Handling:**
```typescript
async execute(params: any): Promise<ToolResult> {
  try {
    // Validate
    // Execute
    // Return success
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

#### Memory Management

**Short-term Memory:**
- Recent actions and observations
- Limited capacity (e.g., last 10 items)
- Used for immediate context

**Long-term Memory:**
- Vector embeddings for semantic search
- Unlimited capacity (with pruning)
- Used for knowledge retrieval

**Working Memory:**
- Current task context
- Intermediate results
- Active plan

### 6. Summary

**What We Built:**
- ✅ LLM adapter for OpenAI integration
- ✅ Tool system with task management
- ✅ Vector memory for semantic search
- ✅ Base agent with full agentic loop
- ✅ Orchestrator agent for coordination
- ✅ Comprehensive test suite

**Key Concepts Learned:**
- Agentic loops (Perceive → Plan → Execute → Reflect)
- Tool use and function calling
- Vector memory and semantic search
- Agent orchestration and coordination
- Reflection and learning patterns
- Memory management strategies

**What's Next:**
In Part 2 of Phase 6, we'll build the "Final Boss" capstone - a production-grade API orchestration layer with request queuing, retries, rate limiting, and full AbortController integration.

**Verification Checklist:**
- [ ] LLM adapter works with OpenAI
- [ ] Tools register and execute correctly
- [ ] Vector memory stores and searches
- [ ] Agent completes tasks successfully
- [ ] Agent uses tools appropriately
- [ ] Memory stores all types of entries
- [ ] Orchestrator coordinates execution
