# Part 7: Building an Autonomous Research Assistant

## The Target

In this part, we're building an **Autonomous Research Assistant** — an AI agent that can independently:

- **Plan** complex research tasks by breaking them down into steps
- **Execute** research using the Knowledge Server and other MCP tools
- **Reason** about findings and draw conclusions
- **Reflect** on results and adjust the research approach
- **Remember** context across research sessions
- **Collaborate** with users through natural language

This agent represents the transition from tool-using AI to truly autonomous AI agents that can work independently on complex tasks.

## The Concept

### From Tool to Agent

Think of the difference between a tool and an agent:

- **Tool** (Parts 1-6): "What do you want me to do?" — Reactive
- **Agent** (This Part): "Here's what I think needs to be done" — Proactive

An autonomous agent has:

1. **Goals** — What it's trying to achieve
2. **Planning** — How to achieve the goals
3. **Execution** — Carrying out the plan
4. **Monitoring** — Checking if it's working
5. **Adaptation** — Changing the plan if needed

### The Agent Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Autonomous Research Assistant                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                      Agent Core                             │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │  │
│  │  │ Planner  │  │Executor  │  │ Reflector│  │ Memory   │ │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                   MCP Client Layer                          │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │  │
│  │  │Knowledge │  │Database  │  │  GitHub  │  │   REST   │ │  │
│  │  │ Server   │  │ Servers  │  │ Adapter  │  │ Adapter  │ │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘ │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                    │
│                              ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              External Systems (MCP Servers)                 │  │
│  │  Knowledge  │PostgreSQL│  SQLite  │ GitHub  │  REST API  │  │
│  │  Server     │          │         │         │             │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### The Agent Loop

The agent follows a continuous cycle:

1. **Plan** → Break down the goal into steps
2. **Execute** → Perform each step using MCP tools
3. **Observe** → Collect and analyze results
4. **Reflect** → Evaluate progress and adjust
5. **Repeat** → Continue until the goal is achieved

## The Implementation

### Step 1: Project Setup

```bash
cd ai-integration-javascript/ai-agents
mkdir -p research-assistant
cd research-assistant
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk openai zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/ai-agents/research-assistant/tsconfig.json`

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

**File:** `ai-integration-javascript/ai-agents/research-assistant/.env.example`

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_MAX_TOKENS=4096

# MCP Client Configuration
MCP_CLIENT_NAME=research-assistant
MCP_KNOWLEDGE_SERVER_PATH=../../mcp-protocol/servers/knowledge-server/dist/index.js
MCP_DATABASE_SERVER_PATH=../../mcp-protocol/servers/database-server/dist/index.js

# Agent Configuration
AGENT_MAX_ITERATIONS=20
AGENT_MAX_TOOL_CALLS=50
AGENT_MEMORY_SIZE=100
AGENT_LOG_LEVEL=info

# Logging
LOG_LEVEL=info
```

### Step 2: Create the Logger

**File:** `ai-integration-javascript/ai-agents/research-assistant/src/logger.ts`

```typescript
import pino from 'pino';
import { randomUUID } from 'crypto';
import path from 'path';
import fs from 'fs';

interface LoggerConfig {
  level: string;
  prettyPrint: boolean;
  baseLogDir: string;
}

const getEnvironmentConfig = (): { level: string; prettyPrint: boolean } => {
  const env = process.env.NODE_ENV || 'development';
  switch (env) {
    case 'production':
    case 'staging':
      return { level: 'info', prettyPrint: false };
    case 'development':
    default:
      return { level: 'debug', prettyPrint: true };
  }
};

const ensureLogDirectory = (logDir: string): void => {
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true });
  }
};

const config: LoggerConfig = {
  level: process.env.LOG_LEVEL || getEnvironmentConfig().level,
  prettyPrint: getEnvironmentConfig().prettyPrint,
  baseLogDir: path.join(process.cwd(), 'logs')
};

ensureLogDirectory(config.baseLogDir);

export const createLogger = (context?: Record<string, unknown>) => {
  const requestId = randomUUID();
  const baseBindings = {
    requestId,
    service: 'research-assistant',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    ...context
  };

  const transports = pino.transport({
    targets: [
      {
        target: 'pino-pretty',
        level: config.level,
        options: {
          colorize: config.prettyPrint,
          translateTime: 'SYS:standard',
          ignore: 'pid,hostname',
          singleLine: !config.prettyPrint,
          hideObject: false
        }
      },
      ...(process.env.NODE_ENV === 'production' ? [{
        target: 'pino/file',
        level: 'info',
        options: {
          destination: path.join(config.baseLogDir, 'research-assistant.log'),
          mkdir: true
        }
      }] : [])
    ]
  });

  const rootLogger = pino(
    {
      level: config.level,
      base: {
        pid: process.pid,
        hostname: require('os').hostname()
      }
    },
    transports
  );

  return rootLogger.child(baseBindings);
};

export const logger = createLogger();
export const createModuleLogger = (moduleName: string) => {
  return logger.child({ module: moduleName });
};
```

### Step 3: Create the Memory System

**File:** `ai-integration-javascript/ai-agents/research-assistant/src/memory.ts`

```typescript
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('memory');

/**
 * Memory entry with timestamp and importance
 */
export interface MemoryEntry {
  id: string;
  content: string;
  type: 'observation' | 'conclusion' | 'plan' | 'reflection' | 'result';
  timestamp: Date;
  importance: number; // 0-10
  metadata?: Record<string, any>;
}

/**
 * Semantic memory for the agent
 * Stores and retrieves information with importance weighting
 */
export class SemanticMemory {
  private shortTerm: MemoryEntry[] = [];
  private longTerm: MemoryEntry[] = [];
  private maxShortTerm: number = 10;
  private maxLongTerm: number = 1000;
  private logger = createModuleLogger('semantic-memory');

  constructor(maxShortTerm?: number, maxLongTerm?: number) {
    this.maxShortTerm = maxShortTerm || parseInt(process.env.AGENT_MEMORY_SIZE || '10');
    this.maxLongTerm = maxLongTerm || parseInt(process.env.AGENT_MEMORY_LONG_TERM || '1000');
    this.logger.info('Semantic memory initialized', {
      maxShortTerm: this.maxShortTerm,
      maxLongTerm: this.maxLongTerm
    });
  }

  /**
   * Add a memory entry
   */
  add(content: string, type: MemoryEntry['type'], importance: number = 5, metadata?: Record<string, any>): MemoryEntry {
    const entry: MemoryEntry = {
      id: `mem-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      content,
      type,
      timestamp: new Date(),
      importance: Math.min(10, Math.max(1, importance)),
      metadata
    };

    // Add to short-term memory
    this.shortTerm.unshift(entry);
    if (this.shortTerm.length > this.maxShortTerm) {
      const moved = this.shortTerm.pop()!;
      // Only move to long-term if important enough
      if (moved.importance >= 4) {
        this.longTerm.unshift(moved);
        this.logger.debug('Moved memory to long-term', {
          content: moved.content.substring(0, 50),
          importance: moved.importance
        });
      }
    }

    // Trim long-term memory
    if (this.longTerm.length > this.maxLongTerm) {
      this.longTerm = this.longTerm.slice(0, this.maxLongTerm);
    }

    this.logger.debug('Memory added', { type, content: content.substring(0, 50), importance });
    return entry;
  }

  /**
   * Get recent memories (short-term)
   */
  getRecent(count: number = 5): MemoryEntry[] {
    return this.shortTerm.slice(0, count);
  }

  /**
   * Search memory by content
   */
  search(query: string, limit: number = 10): MemoryEntry[] {
    const results = [...this.shortTerm, ...this.longTerm]
      .filter(entry => entry.content.toLowerCase().includes(query.toLowerCase()))
      .sort((a, b) => b.importance - a.importance)
      .slice(0, limit);

    this.logger.debug('Memory search completed', { query, results: results.length });
    return results;
  }

  /**
   * Get memories by type
   */
  getByType(type: MemoryEntry['type'], limit: number = 10): MemoryEntry[] {
    const results = [...this.shortTerm, ...this.longTerm]
      .filter(entry => entry.type === type)
      .sort((a, b) => b.importance - a.importance)
      .slice(0, limit);

    return results;
  }

  /**
   * Get all memories
   */
  getAll(): MemoryEntry[] {
    return [...this.shortTerm, ...this.longTerm];
  }

  /**
   * Get memory context as text for LLM prompts
   */
  getContext(limit: number = 10): string {
    const entries = this.shortTerm.slice(0, limit);
    if (entries.length === 0) {
      return 'No recent memories.';
    }

    return entries.map(entry => 
      `[${entry.type}] ${entry.content} (${entry.timestamp.toISOString()})`
    ).join('\n');
  }

  /**
   * Clear short-term memory
   */
  clearShortTerm(): void {
    this.shortTerm = [];
    this.logger.debug('Short-term memory cleared');
  }

  /**
   * Clear all memory
   */
  clearAll(): void {
    this.shortTerm = [];
    this.longTerm = [];
    this.logger.debug('All memory cleared');
  }

  /**
   * Get memory statistics
   */
  getStats(): {
    shortTermCount: number;
    longTermCount: number;
    totalCount: number;
    types: Record<MemoryEntry['type'], number>;
  } {
    const all = this.getAll();
    const types: Record<MemoryEntry['type'], number> = {
      observation: 0,
      conclusion: 0,
      plan: 0,
      reflection: 0,
      result: 0
    };

    for (const entry of all) {
      types[entry.type] = (types[entry.type] || 0) + 1;
    }

    return {
      shortTermCount: this.shortTerm.length,
      longTermCount: this.longTerm.length,
      totalCount: all.length,
      types
    };
  }
}
```

### Step 4: Create the Planner Module

**File:** `ai-integration-javascript/ai-agents/research-assistant/src/planner.ts`

```typescript
import { createModuleLogger } from './logger.js';
import { SemanticMemory } from './memory.js';

const logger = createModuleLogger('planner');

/**
 * Plan step with action and dependencies
 */
export interface PlanStep {
  id: string;
  description: string;
  action: string; // Tool name to call
  parameters: Record<string, any>;
  dependencies: string[]; // IDs of steps that must complete first
  status: 'pending' | 'in_progress' | 'completed' | 'failed' | 'skipped';
  result?: any;
  error?: string;
}

/**
 * Research plan with goals and steps
 */
export interface ResearchPlan {
  id: string;
  goal: string;
  steps: PlanStep[];
  status: 'planning' | 'executing' | 'completed' | 'failed' | 'paused';
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Planner module for creating research plans
 */
export class Planner {
  private memory: SemanticMemory;
  private logger = createModuleLogger('planner');

  constructor(memory: SemanticMemory) {
    this.memory = memory;
    this.logger.info('Planner initialized');
  }

  /**
   * Create a research plan based on a goal
   */
  createPlan(goal: string): ResearchPlan {
    this.logger.info('Creating research plan', { goal });

    // Store goal in memory
    this.memory.add(`Goal: ${goal}`, 'plan', 8);

    // Create plan structure
    const plan: ResearchPlan = {
      id: `plan-${Date.now()}`,
      goal,
      steps: [],
      status: 'planning',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    // Generate steps based on goal analysis
    const steps = this.generateSteps(goal);
    plan.steps = steps;

    // Store the plan in memory
    this.memory.add(
      `Research plan created with ${steps.length} steps: ${steps.map(s => s.description).join(', ')}`,
      'plan',
      7
    );

    this.logger.info('Research plan created', {
      planId: plan.id,
      stepCount: steps.length
    });

    return plan;
  }

  /**
   * Generate plan steps based on goal
   */
  private generateSteps(goal: string): PlanStep[] {
    const steps: PlanStep[] = [];

    // Determine research type based on goal
    const goalLower = goal.toLowerCase();
    const isDataQuery = goalLower.includes('data') || goalLower.includes('query') || goalLower.includes('database');
    const isCodeQuery = goalLower.includes('code') || goalLower.includes('github') || goalLower.includes('repository');
    const isDocumentQuery = goalLower.includes('document') || goalLower.includes('readme') || goalLower.includes('docs');

    // Step 1: Understand the request
    steps.push({
      id: `step-${Date.now()}-1`,
      description: 'Understand the research request and identify key requirements',
      action: 'reflect',
      parameters: { focus: 'requirements' },
      dependencies: [],
      status: 'pending'
    });

    // Step 2: Determine data sources
    steps.push({
      id: `step-${Date.now()}-2`,
      description: 'Determine which data sources are needed for the research',
      action: 'search_knowledge',
      parameters: { 
        query: `Data sources for: ${goal}`,
        sources: ['knowledge']
      },
      dependencies: ['step-1'],
      status: 'pending'
    });

    // Step 3: Query data sources
    if (isDataQuery) {
      steps.push({
        id: `step-${Date.now()}-3`,
        description: 'Query database for relevant data',
        action: 'execute_query',
        parameters: { 
          sql: `SELECT * FROM ... WHERE ...`,
          params: [],
          limit: 100
        },
        dependencies: ['step-2'],
        status: 'pending'
      });
    }

    if (isCodeQuery) {
      steps.push({
        id: `step-${Date.now()}-3`,
        description: 'Search GitHub repository for code',
        action: 'search_code',
        parameters: { 
          query: goal,
          limit: 20
        },
        dependencies: ['step-2'],
        status: 'pending'
      });
    }

    if (isDocumentQuery) {
      steps.push({
        id: `step-${Date.now()}-3`,
        description: 'Search documentation',
        action: 'search_docs',
        parameters: { 
          query: goal,
          limit: 10
        },
        dependencies: ['step-2'],
        status: 'pending'
      });
    }

    // Step 4: Analyze and synthesize results
    steps.push({
      id: `step-${Date.now()}-4`,
      description: 'Analyze and synthesize research findings',
      action: 'analyze_results',
      parameters: { 
        context: goal,
        format: 'summary'
      },
      dependencies: steps.filter(s => s.id.startsWith('step-3')).map(s => s.id),
      status: 'pending'
    });

    // Step 5: Draw conclusions
    steps.push({
      id: `step-${Date.now()}-5`,
      description: 'Draw conclusions and provide recommendations',
      action: 'reflect',
      parameters: { focus: 'conclusions' },
      dependencies: ['step-4'],
      status: 'pending'
    });

    return steps;
  }

  /**
   * Get the next pending step
   */
  getNextStep(plan: ResearchPlan): PlanStep | null {
    // Get all pending steps that have their dependencies met
    const pending = plan.steps.filter(step => 
      step.status === 'pending' &&
      step.dependencies.every(depId => {
        const dep = plan.steps.find(s => s.id === depId);
        return dep && dep.status === 'completed';
      })
    );

    if (pending.length === 0) {
      return null;
    }

    // Return the first available step
    return pending[0];
  }

  /**
   * Update step status
   */
  updateStep(plan: ResearchPlan, stepId: string, status: PlanStep['status'], result?: any, error?: string): void {
    const step = plan.steps.find(s => s.id === stepId);
    if (!step) {
      throw new Error(`Step ${stepId} not found in plan`);
    }

    step.status = status;
    if (result !== undefined) {
      step.result = result;
    }
    if (error !== undefined) {
      step.error = error;
    }

    plan.updatedAt = new Date();

    this.logger.debug('Step updated', {
      planId: plan.id,
      stepId,
      status,
      hasResult: result !== undefined,
      hasError: error !== undefined
    });

    // Store step completion in memory
    if (status === 'completed') {
      this.memory.add(
        `Completed step: ${step.description}`,
        'result',
        6,
        { stepId, result: result ? 'success' : 'no result' }
      );
    }

    if (status === 'failed') {
      this.memory.add(
        `Failed step: ${step.description}`,
        'reflection',
        7,
        { stepId, error }
      );
    }

    // Update overall plan status
    this.updatePlanStatus(plan);
  }

  /**
   * Update the overall plan status based on step statuses
   */
  private updatePlanStatus(plan: ResearchPlan): void {
    const statuses = plan.steps.map(s => s.status);
    
    if (statuses.every(s => s === 'completed' || s === 'skipped')) {
      plan.status = 'completed';
      this.memory.add(`Research plan completed: ${plan.goal}`, 'conclusion', 9);
    } else if (statuses.some(s => s === 'failed')) {
      plan.status = 'failed';
      this.memory.add(`Research plan failed: ${plan.goal}`, 'reflection', 8);
    } else if (statuses.some(s => s === 'pending' || s === 'in_progress')) {
      plan.status = 'executing';
    }

    plan.updatedAt = new Date();
  }

  /**
   * Get plan summary
   */
  getPlanSummary(plan: ResearchPlan): string {
    const total = plan.steps.length;
    const completed = plan.steps.filter(s => s.status === 'completed').length;
    const failed = plan.steps.filter(s => s.status === 'failed').length;
    const pending = plan.steps.filter(s => s.status === 'pending').length;

    let summary = `Plan: ${plan.goal}\n`;
    summary += `Status: ${plan.status}\n`;
    summary += `Progress: ${completed}/${total} steps completed`;
    if (failed > 0) {
      summary += `, ${failed} failed`;
    }
    if (pending > 0) {
      summary += `, ${pending} pending`;
    }
    summary += '\n\nSteps:\n';

    for (const step of plan.steps) {
      const statusIcon = step.status === 'completed' ? '✅' :
                        step.status === 'failed' ? '❌' :
                        step.status === 'in_progress' ? '🔄' :
                        '⏳';
      summary += `${statusIcon} ${step.description}`;
      if (step.status === 'failed' && step.error) {
        summary += ` (${step.error})`;
      }
      summary += '\n';
    }

    return summary;
  }
}
```

### Step 5: Create the Agent Core

**File:** `ai-integration-javascript/ai-agents/research-assistant/src/agent.ts`

```typescript
import OpenAI from 'openai';
import { createModuleLogger } from './logger.js';
import { SemanticMemory, MemoryEntry } from './memory.js';
import { Planner, ResearchPlan, PlanStep } from './planner.js';
import { MCPClient } from '../../../mcp-protocol/clients/mcp-client-lib/dist/index.js';
import { MCPServerConfig } from '../../../mcp-protocol/clients/mcp-client-lib/dist/types.js';

const logger = createModuleLogger('agent');

/**
 * Agent configuration
 */
export interface AgentConfig {
  openaiApiKey: string;
  model: string;
  maxIterations: number;
  maxToolCalls: number;
  maxTokens: number;
}

/**
 * Tool call result
 */
export interface ToolCallResult {
  success: boolean;
  content: any;
  error?: string;
}

/**
 * Autonomous Research Assistant Agent
 */
export class ResearchAssistant {
  private openai: OpenAI;
  private memory: SemanticMemory;
  private planner: Planner;
  private mcpClient: MCPClient;
  private config: AgentConfig;
  private currentPlan?: ResearchPlan;
  private iteration: number = 0;
  private toolCalls: number = 0;
  private logger = createModuleLogger('research-assistant');
  private isRunning: boolean = false;

  constructor(config?: Partial<AgentConfig>) {
    // Load configuration
    this.config = {
      openaiApiKey: config?.openaiApiKey || process.env.OPENAI_API_KEY || '',
      model: config?.model || process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
      maxIterations: config?.maxIterations || parseInt(process.env.AGENT_MAX_ITERATIONS || '20'),
      maxToolCalls: config?.maxToolCalls || parseInt(process.env.AGENT_MAX_TOOL_CALLS || '50'),
      maxTokens: config?.maxTokens || parseInt(process.env.OPENAI_MAX_TOKENS || '4096')
    };

    if (!this.config.openaiApiKey) {
      throw new Error('OpenAI API key is required');
    }

    // Initialize OpenAI
    this.openai = new OpenAI({
      apiKey: this.config.openaiApiKey
    });

    // Initialize memory
    this.memory = new SemanticMemory();

    // Initialize planner
    this.planner = new Planner(this.memory);

    // Initialize MCP client
    this.mcpClient = this.initializeMCPClient();

    this.logger.info('Research Assistant initialized', {
      model: this.config.model,
      maxIterations: this.config.maxIterations
    });
  }

  /**
   * Initialize MCP client with knowledge server
   */
  private initializeMCPClient(): MCPClient {
    const knowledgeServerPath = process.env.MCP_KNOWLEDGE_SERVER_PATH || 
      '../../mcp-protocol/servers/knowledge-server/dist/index.js';

    const serverConfig: MCPServerConfig = {
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

    const client = new (require('../../../mcp-protocol/clients/mcp-client-lib/dist/index.js').MCPClient)({
      servers: [serverConfig],
      defaultTimeout: 30000,
      debug: process.env.DEBUG === 'true'
    });

    this.logger.info('MCP Client initialized with knowledge server');
    return client;
  }

  /**
   * Run the research assistant on a goal
   */
  async run(goal: string): Promise<{
    plan: ResearchPlan;
    results: any[];
    summary: string;
  }> {
    if (this.isRunning) {
      throw new Error('Agent is already running');
    }

    this.isRunning = true;
    this.iteration = 0;
    this.toolCalls = 0;

    this.logger.info('Starting research assistant', { goal });

    try {
      // Connect to MCP servers
      await this.mcpClient.connectAll();
      this.logger.info('Connected to MCP servers');

      // Create research plan
      this.currentPlan = this.planner.createPlan(goal);
      this.logger.info('Research plan created', {
        planId: this.currentPlan.id,
        steps: this.currentPlan.steps.length
      });

      // Store goal in memory
      this.memory.add(`Research goal: ${goal}`, 'plan', 9);

      // Execute the plan
      const results = await this.executePlan();

      // Generate summary
      const summary = await this.generateSummary();

      this.logger.info('Research completed', {
        planId: this.currentPlan.id,
        status: this.currentPlan.status,
        results: results.length
      });

      return {
        plan: this.currentPlan,
        results,
        summary
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Research failed', { error: errorMsg });
      throw error;
    } finally {
      this.isRunning = false;
      await this.mcpClient.disconnectAll();
    }
  }

  /**
   * Execute the research plan
   */
  private async executePlan(): Promise<any[]> {
    const results: any[] = [];

    while (this.iteration < this.config.maxIterations) {
      this.iteration++;
      this.logger.debug('Plan iteration', { iteration: this.iteration });

      // Get the next step
      if (!this.currentPlan) {
        throw new Error('No plan available');
      }

      const nextStep = this.planner.getNextStep(this.currentPlan);
      if (!nextStep) {
        // No more steps
        this.logger.info('All plan steps completed');
        break;
      }

      this.logger.debug('Executing step', {
        stepId: nextStep.id,
        description: nextStep.description,
        action: nextStep.action
      });

      // Mark step as in progress
      this.planner.updateStep(this.currentPlan, nextStep.id, 'in_progress');

      try {
        // Execute the step based on action type
        let result: any;

        switch (nextStep.action) {
          case 'reflect':
            result = await this.reflect(nextStep.parameters);
            break;
          case 'search_knowledge':
            result = await this.searchKnowledge(nextStep.parameters);
            break;
          case 'execute_query':
            result = await this.executeQuery(nextStep.parameters);
            break;
          case 'search_code':
            result = await this.searchCode(nextStep.parameters);
            break;
          case 'search_docs':
            result = await this.searchDocs(nextStep.parameters);
            break;
          case 'analyze_results':
            result = await this.analyzeResults(nextStep.parameters);
            break;
          default:
            // Generic tool call using MCP client
            result = await this.callTool(nextStep.action, nextStep.parameters);
        }

        // Store result
        results.push({
          stepId: nextStep.id,
          description: nextStep.description,
          result
        });

        // Mark step as completed
        this.planner.updateStep(this.currentPlan, nextStep.id, 'completed', result);

        // Store in memory
        this.memory.add(
          `Step completed: ${nextStep.description}`,
          'result',
          6,
          { stepId: nextStep.id }
        );

      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : 'Unknown error';
        this.logger.error('Step execution failed', {
          stepId: nextStep.id,
          error: errorMsg
        });

        // Mark step as failed
        this.planner.updateStep(this.currentPlan, nextStep.id, 'failed', undefined, errorMsg);

        // Store failure in memory
        this.memory.add(
          `Step failed: ${nextStep.description} - ${errorMsg}`,
          'reflection',
          8,
          { stepId: nextStep.id, error: errorMsg }
        );

        // If critical step failed, break
        if (nextStep.dependencies.length === 0) {
          this.logger.warn('Critical step failed, stopping plan');
          break;
        }
      }

      // Check if we've exceeded tool call limits
      if (this.toolCalls > this.config.maxToolCalls) {
        this.logger.warn('Max tool calls exceeded', { toolCalls: this.toolCalls });
        break;
      }
    }

    return results;
  }

  /**
   * Call an MCP tool
   */
  private async callTool(toolName: string, params: Record<string, any>): Promise<any> {
    this.toolCalls++;
    this.logger.debug('Calling MCP tool', { toolName, params });

    try {
      const result = await this.mcpClient.callTool('knowledge-server', toolName, params);
      return result;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Tool call failed', { toolName, error: errorMsg });
      throw error;
    }
  }

  /**
   * Reflection action
   */
  private async reflect(params: { focus: string }): Promise<any> {
    this.logger.debug('Reflecting', { focus: params.focus });

    const memoryContext = this.memory.getContext(10);
    const planSummary = this.currentPlan ? this.planner.getPlanSummary(this.currentPlan) : 'No plan';

    const prompt = `You are reflecting on the research progress.

Focus: ${params.focus}

Recent Memory Context:
${memoryContext}

Current Plan:
${planSummary}

Based on this, provide:
1. Key observations
2. What's working well
3. What needs adjustment
4. Next steps to focus on

Format your response as a JSON object with these fields.`;

    const response = await this.openai.chat.completions.create({
      model: this.config.model,
      messages: [
        { role: 'system', content: 'You are a reflective research assistant analyzing progress.' },
        { role: 'user', content: prompt }
      ],
      max_tokens: this.config.maxTokens,
      temperature: 0.7
    });

    const reflection = response.choices[0].message.content || '';

    // Store reflection in memory
    this.memory.add(
      `Reflection: ${reflection.substring(0, 100)}...`,
      'reflection',
      7,
      { focus: params.focus }
    );

    try {
      return JSON.parse(reflection);
    } catch {
      return { reflection, error: 'Failed to parse JSON' };
    }
  }

  /**
   * Search knowledge
   */
  private async searchKnowledge(params: { query: string; sources?: string[]; limit?: number }): Promise<any> {
    this.logger.debug('Searching knowledge', { query: params.query });

    const result = await this.callTool('search_knowledge', {
      query: params.query,
      sources: params.sources || [],
      limit: params.limit || 20
    });

    // Store search results in memory
    this.memory.add(
      `Searched knowledge for: ${params.query}`,
      'observation',
      5,
      { query: params.query, resultCount: result.content?.length || 0 }
    );

    return result;
  }

  /**
   * Execute database query
   */
  private async executeQuery(params: { sql: string; params?: any[]; limit?: number }): Promise<any> {
    this.logger.debug('Executing database query', { sql: params.sql });

    const result = await this.callTool('execute_query', {
      sql: params.sql,
      params: params.params || [],
      limit: params.limit || 100
    });

    // Store query result in memory
    this.memory.add(
      `Executed query: ${params.sql.substring(0, 50)}...`,
      'observation',
      5,
      { sql: params.sql, rowCount: result.rowCount || 0 }
    );

    return result;
  }

  /**
   * Search code
   */
  private async searchCode(params: { query: string; limit?: number }): Promise<any> {
    this.logger.debug('Searching code', { query: params.query });

    // This would use the GitHub adapter through the knowledge server
    const result = await this.callTool('search_knowledge', {
      query: `code: ${params.query}`,
      sources: ['github'],
      limit: params.limit || 20
    });

    this.memory.add(
      `Searched code for: ${params.query}`,
      'observation',
      5,
      { query: params.query, resultCount: result.content?.length || 0 }
    );

    return result;
  }

  /**
   * Search documentation
   */
  private async searchDocs(params: { query: string; limit?: number }): Promise<any> {
    this.logger.debug('Searching documentation', { query: params.query });

    // This would use documentation adapters through the knowledge server
    const result = await this.callTool('search_knowledge', {
      query: `doc: ${params.query}`,
      sources: ['sqlite', 'postgres'],
      limit: params.limit || 10
    });

    this.memory.add(
      `Searched docs for: ${params.query}`,
      'observation',
      5,
      { query: params.query, resultCount: result.content?.length || 0 }
    );

    return result;
  }

  /**
   * Analyze results
   */
  private async analyzeResults(params: { context: string; format: string }): Promise<any> {
    this.logger.debug('Analyzing results', { context: params.context });

    const memoryContext = this.memory.getContext(15);
    const planSummary = this.currentPlan ? this.planner.getPlanSummary(this.currentPlan) : 'No plan';

    const prompt = `You are analyzing research results.

Context: ${params.context}
Format: ${params.format}

Plan Summary:
${planSummary}

Recent Results and Observations:
${memoryContext}

Please provide a comprehensive analysis:
1. Key findings and insights
2. Patterns and themes
3. Gaps in the research
4. Recommendations for further investigation

Format: ${params.format}`;

    const response = await this.openai.chat.completions.create({
      model: this.config.model,
      messages: [
        { role: 'system', content: 'You are an expert research analyst.' },
        { role: 'user', content: prompt }
      ],
      max_tokens: this.config.maxTokens,
      temperature: 0.5
    });

    const analysis = response.choices[0].message.content || '';

    // Store analysis in memory
    this.memory.add(
      `Analysis: ${analysis.substring(0, 100)}...`,
      'conclusion',
      8,
      { format: params.format }
    );

    return { analysis, format: params.format };
  }

  /**
   * Generate final summary
   */
  private async generateSummary(): Promise<string> {
    this.logger.debug('Generating final summary');

    const memoryContext = this.memory.getContext(20);
    const planSummary = this.currentPlan ? this.planner.getPlanSummary(this.currentPlan) : 'No plan';
    const stats = this.memory.getStats();

    const prompt = `You are generating a final research summary.

Plan Summary:
${planSummary}

Research Memory:
${memoryContext}

Statistics:
- Total observations: ${stats.types.observation}
- Conclusions drawn: ${stats.types.conclusion}
- Reflections: ${stats.types.reflection}
- Results: ${stats.types.result}

Please provide a comprehensive research summary including:
1. Executive summary
2. Key findings
3. Detailed analysis
4. Limitations and gaps
5. Recommendations
6. Next steps

Format your response as a well-structured research report.`;

    const response = await this.openai.chat.completions.create({
      model: this.config.model,
      messages: [
        { role: 'system', content: 'You are a research director writing a comprehensive report.' },
        { role: 'user', content: prompt }
      ],
      max_tokens: this.config.maxTokens,
      temperature: 0.3
    });

    const summary = response.choices[0].message.content || '';

    // Store final summary in memory
    this.memory.add(
      'Final research summary generated',
      'conclusion',
      10,
      { summaryLength: summary.length }
    );

    return summary;
  }

  /**
   * Get agent status
   */
  getStatus(): {
    isRunning: boolean;
    iteration: number;
    toolCalls: number;
    memoryStats: ReturnType<SemanticMemory['getStats']>;
    plan?: {
      id: string;
      status: ResearchPlan['status'];
      stepCount: number;
      completedSteps: number;
    };
  } {
    return {
      isRunning: this.isRunning,
      iteration: this.iteration,
      toolCalls: this.toolCalls,
      memoryStats: this.memory.getStats(),
      plan: this.currentPlan ? {
        id: this.currentPlan.id,
        status: this.currentPlan.status,
        stepCount: this.currentPlan.steps.length,
        completedSteps: this.currentPlan.steps.filter(s => s.status === 'completed').length
      } : undefined
    };
  }

  /**
   * Get memory context
   */
  getMemoryContext(limit: number = 10): string {
    return this.memory.getContext(limit);
  }

  /**
   * Shutdown the agent
   */
  async shutdown(): Promise<void> {
    this.logger.info('Shutting down research assistant');
    await this.mcpClient.disconnectAll();
    this.isRunning = false;
    this.logger.info('Research assistant shut down');
  }
}
```

### Step 6: Create the CLI Interface

**File:** `ai-integration-javascript/ai-agents/research-assistant/src/index.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { ResearchAssistant } from './agent.js';
import { createLogger } from './logger.js';
import readline from 'readline';

const logger = createLogger();

/**
 * CLI Interface for the Research Assistant
 */
class ResearchAssistantCLI {
  private assistant?: ResearchAssistant;
  private rl: readline.Interface;

  constructor() {
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: true
    });

    this.rl.on('close', () => {
      console.log('\n👋 Goodbye!');
      process.exit(0);
    });
  }

  /**
   * Start the CLI
   */
  async start(): Promise<void> {
    console.clear();
    console.log('🔬 Autonomous Research Assistant');
    console.log('================================');
    console.log();
    console.log('Welcome! I can help you research complex topics.');
    console.log('I will autonomously plan, execute, and analyze research.');
    console.log();
    console.log('Type your research goal or "quit" to exit.');
    console.log();

    try {
      // Initialize the assistant
      this.assistant = new ResearchAssistant();
      console.log('✅ Research Assistant initialized\n');

      this.promptUser();

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ Failed to initialize: ${errorMsg}`);
      process.exit(1);
    }
  }

  /**
   * Prompt the user for input
   */
  private promptUser(): void {
    this.rl.question('\n🔍 Research goal: ', async (input) => {
      const trimmed = input.trim();
      
      if (!trimmed) {
        this.promptUser();
        return;
      }

      if (trimmed.toLowerCase() === 'quit' || trimmed.toLowerCase() === 'exit') {
        this.rl.close();
        return;
      }

      if (trimmed.toLowerCase() === 'status') {
        this.showStatus();
        this.promptUser();
        return;
      }

      if (trimmed.toLowerCase() === 'memory') {
        this.showMemory();
        this.promptUser();
        return;
      }

      if (trimmed.toLowerCase() === 'help') {
        this.showHelp();
        this.promptUser();
        return;
      }

      // Execute research
      await this.executeResearch(trimmed);
      this.promptUser();
    });
  }

  /**
   * Execute research on a goal
   */
  private async executeResearch(goal: string): Promise<void> {
    if (!this.assistant) {
      console.error('❌ Assistant not initialized');
      return;
    }

    console.log('\n🔬 Starting research...');
    console.log(`📋 Goal: ${goal}`);
    console.log('⏳ This may take a few moments...\n');

    try {
      const result = await this.assistant.run(goal);
      
      console.log('\n📊 Research Complete!');
      console.log('====================\n');
      
      console.log('📋 Plan Summary:');
      console.log(this.assistant.getStatus().plan ? 
        `   Status: ${result.plan.status}` :
        '   No plan available'
      );
      console.log(`   Steps: ${result.results.length} completed\n`);

      console.log('📝 Research Summary:');
      console.log('-------------------');
      console.log(result.summary);
      console.log();

      // Show status
      const status = this.assistant.getStatus();
      console.log('📊 Statistics:');
      console.log(`   Iterations: ${status.iteration}`);
      console.log(`   Tool calls: ${status.toolCalls}`);
      console.log(`   Memory entries: ${status.memoryStats.totalCount}`);
      console.log();

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ Research failed: ${errorMsg}`);
    }
  }

  /**
   * Show agent status
   */
  private showStatus(): void {
    if (!this.assistant) {
      console.log('❌ Assistant not initialized');
      return;
    }

    const status = this.assistant.getStatus();
    console.log('\n📊 Agent Status');
    console.log('===============');
    console.log(`   Running: ${status.isRunning}`);
    console.log(`   Iterations: ${status.iteration}`);
    console.log(`   Tool calls: ${status.toolCalls}`);
    console.log(`   Memory: ${status.memoryStats.totalCount} entries`);
    console.log(`   Short-term: ${status.memoryStats.shortTermCount}`);
    console.log(`   Long-term: ${status.memoryStats.longTermCount}`);
    
    if (status.plan) {
      console.log(`   Plan: ${status.plan.id}`);
      console.log(`   Plan status: ${status.plan.status}`);
      console.log(`   Steps: ${status.plan.completedSteps}/${status.plan.stepCount}`);
    }
    console.log();
  }

  /**
   * Show memory context
   */
  private showMemory(): void {
    if (!this.assistant) {
      console.log('❌ Assistant not initialized');
      return;
    }

    const context = this.assistant.getMemoryContext(15);
    console.log('\n🧠 Memory Context');
    console.log('================');
    console.log(context);
    console.log();
  }

  /**
   * Show help
   */
  private showHelp(): void {
    console.log('\n📚 Help');
    console.log('=======');
    console.log('Commands:');
    console.log('  <research goal>   - Start research on a topic');
    console.log('  status            - Show agent status');
    console.log('  memory            - Show memory context');
    console.log('  help              - Show this help');
    console.log('  quit/exit         - Exit the application');
    console.log();
    console.log('Examples:');
    console.log('  🔍 Research goal: Analyze user data to find trends');
    console.log('  🔍 Research goal: Find best practices for database optimization');
    console.log('  🔍 Research goal: Research GitHub repository activity');
    console.log();
  }

  /**
   * Shutdown the CLI
   */
  async shutdown(): Promise<void> {
    if (this.assistant) {
      await this.assistant.shutdown();
    }
    this.rl.close();
  }
}

/**
 * Main entry point
 */
const main = async (): Promise<void> => {
  logger.info('Starting Research Assistant CLI');

  const cli = new ResearchAssistantCLI();

  // Handle shutdown signals
  process.on('SIGINT', async () => {
    console.log('\n\n⏹️ Shutting down...');
    await cli.shutdown();
    process.exit(0);
  });

  process.on('SIGTERM', async () => {
    await cli.shutdown();
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

  await cli.start();
};

if (import.meta.url === `file://${process.argv[1]}`) {
  void main();
}

export { ResearchAssistant };
```

### Step 7: Create Package.json

**File:** `ai-integration-javascript/ai-agents/research-assistant/package.json`

```json
{
  "name": "research-assistant",
  "version": "1.0.0",
  "description": "Autonomous Research Assistant using MCP and AI",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "start": "node dist/index.js",
    "start:dev": "tsx src/index.ts",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0",
    "openai": "^4.20.1",
    "zod": "^3.22.4",
    "dotenv": "^16.3.1",
    "pino": "^8.17.2",
    "pino-pretty": "^10.3.1"
  },
  "devDependencies": {
    "@types/node": "^20.10.5",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "eslint": "^8.55.0",
    "prettier": "^3.1.1",
    "tsx": "^4.6.0",
    "typescript": "^5.3.3",
    "vitest": "^1.0.4",
    "@vitest/coverage-v8": "^1.0.4"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## The Verification

### Step 1: Build the Research Assistant

```bash
cd ai-integration-javascript/ai-agents/research-assistant
npm install
npm run build
```

### Step 2: Ensure Required Services are Running

```bash
# Start PostgreSQL
docker run --name postgres-mcp -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine

# Create SQLite data directory
mkdir -p ../../mcp-protocol/servers/knowledge-server/data
```

### Step 3: Set Up Environment Variables

Create `.env` file:

```bash
cat > .env << EOF
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4-turbo-preview
LOG_LEVEL=info
EOF
```

### Step 4: Build the Knowledge Server

```bash
cd ../../mcp-protocol/servers/knowledge-server
npm install
npm run build
```

### Step 5: Start the Research Assistant

```bash
cd ../../../ai-agents/research-assistant
npm start
```

### Step 6: Run Research Tasks

Example interactions:

```
🔬 Autonomous Research Assistant
================================

Welcome! I can help you research complex topics.
I will autonomously plan, execute, and analyze research.

🔍 Research goal: Analyze the user table in the database and find demographics

🔬 Starting research...
📋 Goal: Analyze the user table in the database and find demographics
⏳ This may take a few moments...

📊 Research Complete!
====================

📋 Plan Summary:
   Status: completed
   Steps: 5 completed

📝 Research Summary:
-------------------
Executive Summary
The analysis of the user table reveals a diverse user demographic...

...
```

## What You've Built

You've built an **Autonomous Research Assistant** with:

### Core Components
1. **Semantic Memory** — Short and long-term memory with importance weighting
2. **Planner** — Creates and manages research plans with dependencies
3. **Agent Core** — Orchestrates planning, execution, and reflection
4. **MCP Integration** — Connects to the Knowledge Server and other MCP services

### Agent Capabilities
1. **Planning** — Breaks down research goals into executable steps
2. **Execution** — Calls MCP tools to gather information
3. **Reflection** — Analyzes progress and adjusts approach
4. **Memory** — Maintains context across research sessions
5. **Reasoning** — Uses LLM for analysis and synthesis
6. **Adaptation** — Handles failures and adjusts plans

### CLI Interface
1. **Interactive** — Natural language goal input
2. **Status Monitoring** — Real-time progress tracking
3. **Memory Inspection** — View what the agent remembers
4. **Results Display** — Comprehensive research summaries

## Key Takeaways

1. **Autonomy is a Spectrum** — From simple tools to autonomous agents
2. **Planning is Essential** — Good plans lead to good results
3. **Memory Provides Context** — Agents need to remember what they've learned
4. **Reflection Drives Improvement** — Analyzing progress leads to better outcomes
5. **MCP Enables Autonomy** — Standardized tools allow agents to do real work
6. **Iterative Execution** — Break complex tasks into manageable steps

## What's Next?

In **Part 8**, we'll expand from a single agent to **multi-agent collaboration** using Agent-to-Agent (A2A) protocols. We'll build specialized agents that work together on complex tasks, communicating and delegating work to each other.
