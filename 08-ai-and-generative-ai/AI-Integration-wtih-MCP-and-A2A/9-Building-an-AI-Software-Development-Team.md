# Part 9: Advanced Multi-Agent Architectures — Building an AI Software Development Team

## The Target

In this part, we're building an **advanced multi-agent system** that functions as a complete AI software development team. We'll implement:

- **Hierarchical Agent Architecture** — Coordinator-Supervisor pattern
- **Planner-Worker Execution** — Planning phase, execution phase, review phase
- **Event-Driven Workflows** — Reactive agent behavior
- **Shared Memory** — Cross-agent context sharing
- **Human-in-the-Loop** — User intervention and approval
- **Distributed Reasoning** — Agents collaborating on complex problems

This represents the pinnacle of our multi-agent journey — a system where agents work together like a well-oiled software development team.

## The Concept

### The Software Development Team Analogy

Think of a software development team:

- **Product Manager** (Coordinator) — Defines what to build
- **Tech Lead** (Supervisor) — Designs the architecture
- **Developers** (Worker Agents) — Write the code
- **QA Engineers** (Reviewer Agents) — Test and validate
- **DevOps** (DevOps Agent) — Deploy and monitor

Our AI team mirrors this structure, with each agent having a specific role and responsibilities.

### Advanced Architecture Patterns

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     AI Software Development Team                       │
│                                                                        │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │                      Coordinator Agent                         │   │
│  │  - Receives project requirements                              │   │
│  │  - Creates high-level plan                                    │   │
│  │  - Monitors overall progress                                  │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                              │                                         │
│                              ▼                                         │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │                       Supervisor Agent                         │   │
│  │  - Breaks down into tasks                                     │   │
│  │  - Assigns to workers                                         │   │
│  │  - Reviews and merges work                                    │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                              │                                         │
│                              ▼                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │ Research │  │  Coding  │  │  Review  │  │  DevOps  │           │
│  │  Agent   │  │  Agent   │  │  Agent   │  │  Agent   │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│       │             │             │             │                    │
│       └─────────────┴─────────────┴─────────────┘                    │
│                              │                                         │
│                              ▼                                         │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │                      Shared Memory & Context                   │   │
│  │  - Project context                                            │   │
│  │  - Code artifacts                                             │   │
│  │  - Test results                                               │   │
│  │  - Deployment status                                          │   │
│  └────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### The Development Workflow

1. **Planning Phase** — Coordinator defines the project
2. **Design Phase** — Supervisor creates architecture
3. **Implementation Phase** — Worker agents write code
4. **Review Phase** — Reviewer agents validate
5. **Integration Phase** — DevOps agents deploy
6. **Monitoring Phase** — Continuous observation

## The Implementation

### Step 1: Project Setup

```bash
cd ai-integration-javascript/multi-agent
mkdir -p advanced-architecture
cd advanced-architecture
npm init -y
```

Install dependencies:

```bash
npm install @modelcontextprotocol/sdk openai zod dotenv pino pino-pretty
npm install -D typescript @types/node tsx vitest @vitest/coverage-v8 @typescript-eslint/eslint-plugin @typescript-eslint/parser eslint prettier
```

**File:** `ai-integration-javascript/multi-agent/advanced-architecture/tsconfig.json`

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

### Step 2: Create Shared Memory System

**File:** `ai-integration-javascript/multi-agent/advanced-architecture/src/shared-memory.ts`

```typescript
import { createModuleLogger } from './logger.js';

const logger = createModuleLogger('shared-memory');

/**
 * Shared memory entry with versioning
 */
export interface MemoryEntry {
  id: string;
  key: string;
  value: any;
  type: 'context' | 'artifact' | 'decision' | 'result' | 'state';
  version: number;
  createdBy: string; // Agent ID
  createdAt: Date;
  updatedAt: Date;
  metadata?: Record<string, any>;
}

/**
 * Shared memory query
 */
export interface MemoryQuery {
  key?: string;
  type?: MemoryEntry['type'];
  createdBy?: string;
  minVersion?: number;
  limit?: number;
}

/**
 * Shared memory system
 * Enables cross-agent context sharing with versioning
 */
export class SharedMemory {
  private entries: Map<string, MemoryEntry[]> = new Map(); // key -> entries (versioned)
  private logger = createModuleLogger('shared-memory');

  constructor() {
    this.logger.info('Shared memory initialized');
  }

  /**
   * Set a value in shared memory
   */
  set(
    key: string,
    value: any,
    type: MemoryEntry['type'],
    createdBy: string,
    metadata?: Record<string, any>
  ): MemoryEntry {
    const existing = this.entries.get(key) || [];
    const version = existing.length > 0 ? existing[existing.length - 1].version + 1 : 1;

    const entry: MemoryEntry = {
      id: `mem-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`,
      key,
      value,
      type,
      version,
      createdBy,
      createdAt: new Date(),
      updatedAt: new Date(),
      metadata
    };

    // Add new version
    existing.push(entry);
    this.entries.set(key, existing);

    this.logger.debug('Memory set', {
      key,
      type,
      version,
      createdBy,
      valueType: typeof value
    });

    return entry;
  }

  /**
   * Get the latest version of a value
   */
  get(key: string): MemoryEntry | undefined {
    const existing = this.entries.get(key);
    if (!existing || existing.length === 0) {
      return undefined;
    }
    return existing[existing.length - 1];
  }

  /**
   * Get a specific version of a value
   */
  getVersion(key: string, version: number): MemoryEntry | undefined {
    const existing = this.entries.get(key);
    if (!existing) {
      return undefined;
    }
    return existing.find(e => e.version === version);
  }

  /**
   * Get all versions of a value
   */
  getAllVersions(key: string): MemoryEntry[] {
    return this.entries.get(key) || [];
  }

  /**
   * Query memory entries
   */
  query(query: MemoryQuery): MemoryEntry[] {
    let results: MemoryEntry[] = [];

    // Collect all entries
    for (const [key, entries] of this.entries) {
      if (query.key && key !== query.key) {
        continue;
      }
      results = results.concat(entries);
    }

    // Filter by type
    if (query.type) {
      results = results.filter(e => e.type === query.type);
    }

    // Filter by creator
    if (query.createdBy) {
      results = results.filter(e => e.createdBy === query.createdBy);
    }

    // Filter by version
    if (query.minVersion) {
      results = results.filter(e => e.version >= query.minVersion!);
    }

    // Sort by createdAt (newest first)
    results.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    // Apply limit
    if (query.limit) {
      results = results.slice(0, query.limit);
    }

    return results;
  }

  /**
   * Search memory by key pattern
   */
  search(pattern: string): MemoryEntry[] {
    const results: MemoryEntry[] = [];
    const regex = new RegExp(pattern, 'i');

    for (const [key, entries] of this.entries) {
      if (regex.test(key)) {
        // Get the latest version for this key
        const latest = entries[entries.length - 1];
        results.push(latest);
      }
    }

    return results;
  }

  /**
   * Get memory snapshot for context building
   */
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

  /**
   * Clear all memory
   */
  clear(): void {
    this.entries.clear();
    this.logger.info('Shared memory cleared');
  }

  /**
   * Get memory statistics
   */
  getStats(): {
    totalEntries: number;
    totalKeys: number;
    types: Record<MemoryEntry['type'], number>;
  } {
    const types: Record<MemoryEntry['type'], number> = {
      context: 0,
      artifact: 0,
      decision: 0,
      result: 0,
      state: 0
    };

    let totalEntries = 0;
    const keys = new Set<string>();

    for (const [key, entries] of this.entries) {
      keys.add(key);
      for (const entry of entries) {
        totalEntries++;
        types[entry.type] = (types[entry.type] || 0) + 1;
      }
    }

    return {
      totalEntries,
      totalKeys: keys.size,
      types
    };
  }
}

/**
 * Shared memory singleton
 */
export const sharedMemory = new SharedMemory();
```

### Step 3: Create the Supervisor Agent

**File:** `ai-integration-javascript/multi-agent/advanced-architecture/src/agents/supervisor-agent.ts`

```typescript
import { BaseAgent } from '../../../a2a-protocol/a2a-library/dist/base-agent.js';
import { AgentRole, AgentCapability } from '../../../a2a-protocol/a2a-library/dist/types.js';
import { AgentRegistry } from '../../../a2a-protocol/a2a-library/dist/registry.js';
import { MessageRouter } from '../../../a2a-protocol/a2a-library/dist/router.js';
import { sharedMemory } from '../shared-memory.js';
import OpenAI from 'openai';

/**
 * Supervisor Agent
 * Breaks down projects, assigns tasks, and reviews work
 */
export class SupervisorAgent extends BaseAgent {
  private openai: OpenAI;
  private activeProjects: Map<string, any> = new Map();

  constructor(
    registry: AgentRegistry,
    router: MessageRouter,
    openai: OpenAI
  ) {
    const identity = {
      id: `supervisor-${Date.now()}`,
      name: 'Supervisor Agent',
      role: 'coordinator' as AgentRole,
      description: 'Breaks down projects, assigns tasks, reviews work, and ensures quality',
      address: 'supervisor-agent',
      status: 'offline' as any
    };

    const capabilities: AgentCapability[] = [
      {
        name: 'Project Planning',
        description: 'Break down projects into tasks and assign to appropriate agents',
        tools: ['create_project', 'assign_task', 'review_work'],
        resources: ['project://*'],
        expertise: ['planning', 'architecture', 'delegation']
      },
      {
        name: 'Code Review',
        description: 'Review code quality and provide feedback',
        tools: ['review_code', 'suggest_improvements'],
        resources: ['artifact://code', 'artifact://tests'],
        expertise: ['code_review', 'quality_assurance']
      },
      {
        name: 'Workflow Management',
        description: 'Manage project workflow and ensure timely delivery',
        tools: ['update_status', 'schedule_tasks'],
        resources: ['workflow://*'],
        expertise: ['workflow', 'project_management']
      }
    ];

    super(identity, capabilities, registry, router);
    this.openai = openai;
    this.logger.info('Supervisor Agent created');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing supervisor delegation', { task });

    try {
      if (task.action === 'create_project') {
        return await this.createProject(task);
      } else if (task.action === 'assign_task') {
        return await this.assignTask(task);
      } else if (task.action === 'review_work') {
        return await this.reviewWork(task);
      } else {
        throw new Error(`Unknown action: ${task.action}`);
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Supervisor delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Create a project plan
   */
  private async createProject(task: any): Promise<any> {
    const { name, description, requirements, priority } = task;

    this.logger.info('Creating project', { name, description });

    // Store in shared memory
    const projectEntry = sharedMemory.set(
      `project:${name}`,
      {
        name,
        description,
        requirements,
        priority: priority || 'medium',
        status: 'planning',
        createdAt: new Date().toISOString(),
        tasks: []
      },
      'context',
      this.identity.id,
      { type: 'project' }
    );

    // Generate task breakdown using LLM
    const breakdown = await this.generateTaskBreakdown(name, description, requirements);

    // Store tasks in shared memory
    const tasks = breakdown.tasks || [];
    for (const task of tasks) {
      sharedMemory.set(
        `task:${task.id}`,
        {
          ...task,
          projectName: name,
          status: 'pending'
        },
        'context',
        this.identity.id,
        { project: name }
      );
    }

    // Update project with tasks
    const project = projectEntry.value;
    project.tasks = tasks;
    project.status = 'active';

    sharedMemory.set(
      `project:${name}`,
      project,
      'context',
      this.identity.id,
      { type: 'project' }
    );

    this.activeProjects.set(name, project);

    return {
      projectName: name,
      tasks: tasks.map((t: any) => ({ id: t.id, name: t.name, assignedTo: t.assignedRole })),
      summary: breakdown.summary || `Project "${name}" created with ${tasks.length} tasks`
    };
  }

  /**
   * Generate task breakdown using LLM
   */
  private async generateTaskBreakdown(
    name: string,
    description: string,
    requirements: string
  ): Promise<any> {
    this.logger.debug('Generating task breakdown', { name });

    const prompt = `You are a technical project manager. Break down the following project into specific tasks.

Project: ${name}
Description: ${description}
Requirements: ${requirements}

For each task, specify:
- Task ID (unique)
- Task name
- Description
- Assigned role (researcher, coder, reviewer, devops)
- Dependencies (task IDs this depends on)
- Estimated effort (hours)

Also provide:
- Overall project summary
- Estimated total effort
- Critical path

Return as JSON.`;

    try {
      const response = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: 'You are a technical project manager.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 2000,
        temperature: 0.3
      });

      const content = response.choices[0].message.content || '{}';
      
      try {
        return JSON.parse(content);
      } catch {
        // Fallback to simple breakdown
        return {
          tasks: [
            {
              id: 'task-1',
              name: 'Research Requirements',
              description: 'Research and analyze project requirements',
              assignedRole: 'researcher',
              dependencies: [],
              estimatedEffort: 2
            },
            {
              id: 'task-2',
              name: 'Design Architecture',
              description: 'Design system architecture',
              assignedRole: 'coder',
              dependencies: ['task-1'],
              estimatedEffort: 4
            },
            {
              id: 'task-3',
              name: 'Implement Code',
              description: 'Write implementation code',
              assignedRole: 'coder',
              dependencies: ['task-2'],
              estimatedEffort: 8
            },
            {
              id: 'task-4',
              name: 'Review Code',
              description: 'Review and validate implementation',
              assignedRole: 'reviewer',
              dependencies: ['task-3'],
              estimatedEffort: 2
            },
            {
              id: 'task-5',
              name: 'Deploy Application',
              description: 'Deploy to production',
              assignedRole: 'devops',
              dependencies: ['task-4'],
              estimatedEffort: 2
            }
          ],
          summary: 'Standard software development workflow',
          totalEffort: 18
        };
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Task breakdown generation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Assign a task to an agent
   */
  private async assignTask(task: any): Promise<any> {
    const { taskId, projectName } = task;

    this.logger.info('Assigning task', { taskId, projectName });

    // Get task from shared memory
    const taskEntry = sharedMemory.get(`task:${taskId}`);
    if (!taskEntry) {
      throw new Error(`Task ${taskId} not found`);
    }

    const taskData = taskEntry.value;
    
    // Find best agent for the task
    const targetAgent = this.registry.findBestAgentForTask(
      taskData.assignedRole,
      undefined,
      taskData.name
    );

    if (!targetAgent) {
      throw new Error(`No suitable agent found for task: ${taskId}`);
    }

    // Update task status
    taskData.status = 'assigned';
    taskData.assignedTo = targetAgent.agent.id;
    taskData.assignedAt = new Date().toISOString();

    sharedMemory.set(
      `task:${taskId}`,
      taskData,
      'context',
      this.identity.id,
      { assignedTo: targetAgent.agent.id }
    );

    // Send delegation request
    await this.delegate(
      targetAgent.agent.role,
      {
        taskId,
        projectName,
        description: taskData.description,
        parameters: {
          requirements: taskData.requirements || '',
          context: sharedMemory.getContext(['project:' + projectName])
        },
        priority: task.priority || 'medium'
      },
      'high'
    );

    return {
      taskId,
      assignedTo: targetAgent.agent.id,
      agentName: targetAgent.agent.name,
      status: 'assigned'
    };
  }

  /**
   * Review work from an agent
   */
  private async reviewWork(task: any): Promise<any> {
    const { taskId, result, projectName } = task;

    this.logger.info('Reviewing work', { taskId, projectName });

    // Get task from shared memory
    const taskEntry = sharedMemory.get(`task:${taskId}`);
    if (!taskEntry) {
      throw new Error(`Task ${taskId} not found`);
    }

    const taskData = taskEntry.value;

    // Perform code review if it's code
    if (result.code) {
      const reviewResult = await this.reviewCode(result.code, taskData.name);
      result.review = reviewResult;
    }

    // Store result in shared memory
    sharedMemory.set(
      `result:${taskId}`,
      {
        taskId,
        projectName,
        result,
        reviewedBy: this.identity.id,
        reviewedAt: new Date().toISOString(),
        approved: true
      },
      'result',
      this.identity.id,
      { taskId, projectName }
    );

    // Update task status
    taskData.status = 'completed';
    taskData.completedAt = new Date().toISOString();

    sharedMemory.set(
      `task:${taskId}`,
      taskData,
      'context',
      this.identity.id,
      { status: 'completed' }
    );

    return {
      taskId,
      approved: true,
      feedback: result.review?.feedback || 'Work approved',
      summary: `Task ${taskId} reviewed and approved`
    };
  }

  /**
   * Review code quality
   */
  private async reviewCode(code: string, context: string): Promise<any> {
    this.logger.debug('Reviewing code', { context });

    const prompt = `You are a senior software engineer. Review the following code:

Context: ${context}

Code:
\`\`\`
${code}
\`\`\`

Provide a review including:
1. Code quality score (1-10)
2. Major issues (if any)
3. Minor issues (if any)
4. Suggestions for improvement
5. Security concerns
6. Performance considerations

Return as JSON.`;

    try {
      const response = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: 'You are a senior software engineer.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 1500,
        temperature: 0.3
      });

      const content = response.choices[0].message.content || '{}';
      
      try {
        return JSON.parse(content);
      } catch {
        return {
          qualityScore: 7,
          majorIssues: [],
          minorIssues: [],
          suggestions: ['Code looks reasonable, consider adding more tests'],
          securityConcerns: [],
          performanceConsiderations: []
        };
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Code review failed', { error: errorMsg });
      return {
        qualityScore: 7,
        feedback: 'Code review completed but could not generate detailed analysis.'
      };
    }
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Handle project requests
    this.router.onMessage('request', this.handleProjectRequest.bind(this));
  }

  /**
   * Handle project request messages
   */
  private async handleProjectRequest(message: any, reply: any): Promise<void> {
    this.logger.debug('Project request received', {
      from: message.from,
      subject: message.subject
    });

    const body = message.body;

    if (body.action === 'get_project' && body.projectName) {
      const project = sharedMemory.get(`project:${body.projectName}`);
      
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Project Status',
        body: { project: project?.value, success: true },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    } else if (body.action === 'list_projects') {
      const projects = sharedMemory.search('project:');
      
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Project List',
        body: { 
          projects: projects.map((p: any) => p.value),
          count: projects.length,
          success: true 
        },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
    }
  }
}
```

### Step 4: Create Worker Agents

**File:** `ai-integration-javascript/multi-agent/advanced-architecture/src/agents/coding-agent.ts`

```typescript
import { BaseAgent } from '../../../a2a-protocol/a2a-library/dist/base-agent.js';
import { AgentRole, AgentCapability } from '../../../a2a-protocol/a2a-library/dist/types.js';
import { AgentRegistry } from '../../../a2a-protocol/a2a-library/dist/registry.js';
import { MessageRouter } from '../../../a2a-protocol/a2a-library/dist/router.js';
import { sharedMemory } from '../shared-memory.js';
import OpenAI from 'openai';

/**
 * Coding Agent
 * Writes code based on requirements and specifications
 */
export class CodingAgent extends BaseAgent {
  private openai: OpenAI;

  constructor(
    registry: AgentRegistry,
    router: MessageRouter,
    openai: OpenAI
  ) {
    const identity = {
      id: `coder-${Date.now()}`,
      name: 'Coding Agent',
      role: 'coder' as AgentRole,
      description: 'Writes high-quality code based on requirements and specifications',
      address: 'coding-agent',
      status: 'offline' as any
    };

    const capabilities: AgentCapability[] = [
      {
        name: 'Code Generation',
        description: 'Generate code from requirements and specifications',
        tools: ['write_code', 'refactor_code', 'fix_bugs'],
        resources: ['artifact://code'],
        expertise: ['programming', 'software_development', 'code_generation']
      },
      {
        name: 'Testing',
        description: 'Write and run tests for code',
        tools: ['write_tests', 'run_tests'],
        resources: ['artifact://tests'],
        expertise: ['testing', 'quality_assurance']
      },
      {
        name: 'Documentation',
        description: 'Write documentation for code',
        tools: ['write_documentation'],
        resources: ['artifact://docs'],
        expertise: ['documentation', 'technical_writing']
      }
    ];

    super(identity, capabilities, registry, router);
    this.openai = openai;
    this.logger.info('Coding Agent created');
  }

  /**
   * Process a delegation task
   */
  protected async processDelegation(task: any): Promise<any> {
    this.logger.info('Processing coding delegation', { task });

    try {
      const { taskId, projectName, description, parameters } = task;

      // Get context from shared memory
      const project = sharedMemory.get(`project:${projectName}`);
      const projectContext = project?.value || {};

      // Generate code based on description
      const code = await this.generateCode(
        description,
        projectContext,
        parameters
      );

      // Write tests if needed
      const tests = await this.generateTests(code, description);

      // Store artifacts in shared memory
      sharedMemory.set(
        `artifact:code:${taskId}`,
        { code, language: 'javascript', framework: 'node.js' },
        'artifact',
        this.identity.id,
        { taskId, projectName }
      );

      if (tests) {
        sharedMemory.set(
          `artifact:tests:${taskId}`,
          { tests, framework: 'jest' },
          'artifact',
          this.identity.id,
          { taskId, projectName }
        );
      }

      // Notify supervisor
      await this.sendMessage(
        process.env.SUPERVISOR_AGENT_ID || 'supervisor',
        'notification',
        'Code Complete',
        {
          taskId,
          projectName,
          code,
          tests,
          summary: `Generated ${code.split('\n').length} lines of code`
        },
        'high',
        false
      );

      return {
        taskId,
        projectName,
        code,
        tests,
        summary: `Coding completed for task ${taskId}`
      };

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Coding delegation failed', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Generate code based on description
   */
  private async generateCode(
    description: string,
    context: any,
    parameters: any
  ): Promise<string> {
    this.logger.debug('Generating code', { description: description.substring(0, 50) });

    const prompt = `You are a senior software engineer. Write code based on the following requirements.

Description: ${description}

Context: ${JSON.stringify(context, null, 2)}

Parameters: ${JSON.stringify(parameters, null, 2)}

Write clean, well-structured, production-ready code with:
1. Proper error handling
2. Clear comments
3. Good naming conventions
4. Security considerations

Return only the code, no explanations.`;

    try {
      const response = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: 'You are a senior software engineer.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 2000,
        temperature: 0.3
      });

      return response.choices[0].message.content || '// Code generation failed';
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Code generation failed', { error: errorMsg });
      return `// Error generating code: ${errorMsg}\n// Please check the requirements and try again.`;
    }
  }

  /**
   * Generate tests for code
   */
  private async generateTests(code: string, description: string): Promise<string | null> {
    this.logger.debug('Generating tests');

    const prompt = `You are a QA engineer. Write unit tests for the following code.

Code:
\`\`\`
${code}
\`\`\`

Description: ${description}

Write comprehensive tests covering:
1. Happy path
2. Edge cases
3. Error handling
4. Boundary conditions

Return only the test code, no explanations.`;

    try {
      const response = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: 'You are a QA engineer.' },
          { role: 'user', content: prompt }
        ],
        max_tokens: 1500,
        temperature: 0.3
      });

      return response.choices[0].message.content || null;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error('Test generation failed', { error: errorMsg });
      return null;
    }
  }

  /**
   * Setup message handlers
   */
  protected setupHandlers(): void {
    super.setupHandlers();

    // Handle coding requests
    this.router.onMessage('query', this.handleCodingQuery.bind(this));
  }

  /**
   * Handle coding query messages
   */
  private async handleCodingQuery(message: any, reply: any): Promise<void> {
    this.logger.debug('Coding query received', {
      from: message.from,
      query: message.body.query
    });

    const query = message.body.query;

    if (!query) {
      await reply({
        id: `msg-${Date.now()}`,
        type: 'response',
        from: this.identity.id,
        to: message.from,
        subject: 'Coding Query Error',
        body: { error: 'Query required' },
        priority: 'medium',
        createdAt: new Date(),
        requiresResponse: false,
        responseTo: message.id
      });
      return;
    }

    // Generate code
    const code = await this.generateCode(query, {}, {});
    
    await reply({
      id: `msg-${Date.now()}`,
      type: 'response',
      from: this.identity.id,
      to: message.from,
      subject: 'Code Generated',
      body: { code, query, success: true },
      priority: 'medium',
      createdAt: new Date(),
      requiresResponse: false,
      responseTo: message.id
    });
  }
}
```

### Step 5: Create the Advanced Multi-Agent System

**File:** `ai-integration-javascript/multi-agent/advanced-architecture/src/advanced-system.ts`

```typescript
import dotenv from 'dotenv';
dotenv.config();

import OpenAI from 'openai';
import { AgentRegistry } from '../../../a2a-protocol/a2a-library/dist/registry.js';
import { MessageRouter } from '../../../a2a-protocol/a2a-library/dist/router.js';
import { SupervisorAgent } from './agents/supervisor-agent.js';
import { CodingAgent } from './agents/coding-agent.js';
import { createLogger } from './logger.js';
import { sharedMemory } from './shared-memory.js';
import { MCPClient } from '../../../mcp-protocol/clients/mcp-client-lib/dist/index.js';

const logger = createLogger();

/**
 * Advanced Multi-Agent System
 * Software development team with hierarchical architecture
 */
export class AdvancedMultiAgentSystem {
  private registry: AgentRegistry;
  private router: MessageRouter;
  private supervisor: SupervisorAgent;
  private agents: Map<string, any> = new Map();
  private mcpClient: MCPClient;
  private openai: OpenAI;
  private isRunning: boolean = false;

  constructor() {
    // Initialize OpenAI
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY || ''
    });

    // Initialize registry and router
    this.registry = new AgentRegistry();
    this.router = new MessageRouter(this.registry);

    // Initialize MCP client
    this.mcpClient = this.initializeMCPClient();

    // Initialize agents
    this.initAgents();

    logger.info('Advanced Multi-Agent System initialized');
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

    // Supervisor Agent
    const supervisor = new SupervisorAgent(this.registry, this.router, this.openai);
    this.agents.set('supervisor', supervisor);
    this.supervisor = supervisor;

    // Coding Agent
    const coder = new CodingAgent(this.registry, this.router, this.openai);
    this.agents.set('coder', coder);

    // Add more agents as needed:
    // - Research Agent
    // - Reviewer Agent
    // - DevOps Agent

    logger.info('Agents initialized', {
      agents: Array.from(this.agents.keys())
    });
  }

  /**
   * Start the system
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      logger.warn('System already running');
      return;
    }

    logger.info('Starting Advanced Multi-Agent System');

    try {
      // Connect to MCP servers
      await this.mcpClient.connectAll();
      logger.info('Connected to MCP servers');

      // Load registry
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

      this.isRunning = true;

      logger.info('Advanced Multi-Agent System started successfully');
      console.error('🚀 Advanced AI Development Team is running!');
      console.error(`Agents: ${Array.from(this.agents.keys()).join(', ')}`);
      console.error('Supervisor is ready to create projects.');

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
    if (!this.isRunning) {
      logger.warn('System already stopped');
      return;
    }

    logger.info('Stopping Advanced Multi-Agent System');

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

      await this.mcpClient.disconnectAll();
      this.isRunning = false;

      logger.info('Advanced Multi-Agent System stopped successfully');

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      logger.error('Failed to stop system', { error: errorMsg });
      throw error;
    }
  }

  /**
   * Create a new software project
   */
  async createProject(name: string, description: string, requirements: string): Promise<any> {
    if (!this.isRunning) {
      throw new Error('System is not running');
    }

    logger.info('Creating project', { name });

    // Delegate to supervisor
    const result = await this.supervisor.processDelegation({
      action: 'create_project',
      name,
      description,
      requirements,
      priority: 'high'
    });

    return result;
  }

  /**
   * Get system status
   */
  getStatus(): any {
    const agents = Array.from(this.agents.entries()).map(([name, agent]) => ({
      name,
      running: agent.isActive(),
      status: agent.getIdentity().status
    }));

    return {
      running: this.isRunning,
      agents,
      registry: this.registry.getStats(),
      memory: sharedMemory.getStats()
    };
  }

  /**
   * Get project status
   */
  getProject(projectName: string): any {
    const project = sharedMemory.get(`project:${projectName}`);
    return project?.value || null;
  }

  /**
   * List all projects
   */
  listProjects(): any[] {
    const projects = sharedMemory.search('project:');
    return projects.map((p: any) => p.value);
  }

  /**
   * Get all tasks
   */
  getTasks(projectName?: string): any[] {
    const tasks = sharedMemory.search('task:');
    const allTasks = tasks.map((t: any) => t.value);
    
    if (projectName) {
      return allTasks.filter(t => t.projectName === projectName);
    }
    
    return allTasks;
  }

  /**
   * Get all artifacts
   */
  getArtifacts(projectName?: string): any[] {
    const artifacts = sharedMemory.search('artifact:');
    const allArtifacts = artifacts.map((a: any) => ({ ...a.value, key: a.key }));
    
    if (projectName) {
      return allArtifacts.filter(a => a.projectName === projectName);
    }
    
    return allArtifacts;
  }
}

/**
 * Main entry point
 */
const main = async (): Promise<void> => {
  logger.info('Starting Advanced Multi-Agent System entry point');

  const system = new AdvancedMultiAgentSystem();

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

  process.on('uncaughtException', (error) => {
    logger.fatal('Uncaught exception', { error: error.message, stack: error.stack });
    process.exit(1);
  });

  process.on('unhandledRejection', (reason) => {
    logger.fatal('Unhandled rejection', { reason });
    process.exit(1);
  });

  await system.start();

  // Keep alive
  console.error('Press Ctrl+C to stop');

  // Expose system for CLI usage
  (global as any).system = system;
};

if (import.meta.url === `file://${process.argv[1]}`) {
  void main();
}

export { AdvancedMultiAgentSystem };
```

### Step 6: Create CLI Interface

**File:** `ai-integration-javascript/multi-agent/advanced-architecture/src/cli.ts`

```typescript
#!/usr/bin/env node

import dotenv from 'dotenv';
dotenv.config();

import { AdvancedMultiAgentSystem } from './advanced-system.js';
import { createLogger } from './logger.js';
import readline from 'readline';

const logger = createLogger();

/**
 * CLI Interface for the Advanced Multi-Agent System
 */
class AdvancedSystemCLI {
  private system: AdvancedMultiAgentSystem | null = null;
  private rl: readline.Interface;

  constructor() {
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: true
    });
  }

  /**
   * Start the CLI
   */
  async start(): Promise<void> {
    console.clear();
    console.log('🚀 Advanced AI Development Team');
    console.log('================================');
    console.log();
    console.log('This system creates an AI software development team that');
    console.log('can plan, build, test, and deploy software projects.');
    console.log();
    console.log('Commands:');
    console.log('  create-project <name>     - Create a new software project');
    console.log('  list-projects             - List all projects');
    console.log('  project <name>            - Show project details');
    console.log('  tasks [project-name]      - List tasks');
    console.log('  artifacts [project-name]  - List artifacts');
    console.log('  status                    - Show system status');
    console.log('  help                      - Show this help');
    console.log('  quit/exit                 - Exit the application');
    console.log();

    try {
      // Initialize the system
      this.system = new AdvancedMultiAgentSystem();
      await this.system.start();
      
      console.log('✅ System initialized and ready\n');
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
    this.rl.question('\n> ', async (input) => {
      const trimmed = input.trim();
      
      if (!trimmed) {
        this.promptUser();
        return;
      }

      await this.processCommand(trimmed);
      this.promptUser();
    });
  }

  /**
   * Process a command
   */
  private async processCommand(input: string): Promise<void> {
    const parts = input.split(' ');
    const command = parts[0].toLowerCase();
    const args = parts.slice(1);

    if (!this.system) {
      console.error('❌ System not initialized');
      return;
    }

    switch (command) {
      case 'create-project':
        await this.createProject(args);
        break;

      case 'list-projects':
        await this.listProjects();
        break;

      case 'project':
        await this.showProject(args[0]);
        break;

      case 'tasks':
        await this.listTasks(args[0]);
        break;

      case 'artifacts':
        await this.listArtifacts(args[0]);
        break;

      case 'status':
        await this.showStatus();
        break;

      case 'help':
        this.showHelp();
        break;

      case 'quit':
      case 'exit':
        this.rl.close();
        break;

      default:
        console.log(`❌ Unknown command: ${command}. Type 'help' for available commands.`);
    }
  }

  /**
   * Create a project
   */
  private async createProject(args: string[]): Promise<void> {
    if (args.length === 0) {
      console.log('❌ Usage: create-project <name> [description] [requirements]');
      return;
    }

    const name = args[0];
    const description = args[1] || `Project ${name}`;
    const requirements = args.slice(2).join(' ') || 'Standard software development project';

    console.log(`📋 Creating project: ${name}...`);
    console.log(`   Description: ${description}`);
    console.log(`   Requirements: ${requirements}`);
    console.log('⏳ This may take a few moments...\n');

    try {
      const result = await this.system!.createProject(name, description, requirements);
      
      console.log('✅ Project created successfully!');
      console.log(`📊 Project: ${result.projectName}`);
      console.log(`📝 Summary: ${result.summary}`);
      console.log(`📋 Tasks: ${result.tasks?.length || 0} tasks created`);
      
      if (result.tasks && result.tasks.length > 0) {
        console.log('\nTasks:');
        for (const task of result.tasks) {
          console.log(`   - ${task.name} (${task.assignedTo || 'unassigned'})`);
        }
      }
      console.log();

    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Unknown error';
      console.error(`❌ Failed to create project: ${errorMsg}`);
    }
  }

  /**
   * List all projects
   */
  private async listProjects(): Promise<void> {
    const projects = this.system!.listProjects();
    
    if (projects.length === 0) {
      console.log('📋 No projects found.');
      return;
    }

    console.log(`📋 Projects (${projects.length}):`);
    for (const project of projects) {
      const tasks = this.system!.getTasks(project.name);
      const completed = tasks.filter((t: any) => t.status === 'completed').length;
      console.log(`   - ${project.name}: ${project.status} (${completed}/${tasks.length} tasks)`);
    }
    console.log();
  }

  /**
   * Show project details
   */
  private async showProject(name?: string): Promise<void> {
    if (!name) {
      console.log('❌ Usage: project <project-name>');
      return;
    }

    const project = this.system!.getProject(name);
    
    if (!project) {
      console.log(`❌ Project '${name}' not found.`);
      return;
    }

    console.log(`📊 Project: ${project.name}`);
    console.log(`   Status: ${project.status}`);
    console.log(`   Description: ${project.description}`);
    console.log(`   Created: ${project.createdAt}`);
    console.log(`   Priority: ${project.priority || 'medium'}`);
    
    const tasks = this.system!.getTasks(name);
    console.log(`   Tasks: ${tasks.length}`);
    
    if (tasks.length > 0) {
      console.log('\nTasks:');
      for (const task of tasks) {
        const statusIcon = task.status === 'completed' ? '✅' :
                          task.status === 'in_progress' ? '🔄' :
                          task.status === 'assigned' ? '📌' : '⏳';
        console.log(`   ${statusIcon} ${task.name} (${task.status})`);
        if (task.assignedTo) {
          console.log(`      Assigned to: ${task.assignedTo}`);
        }
      }
    }
    console.log();
  }

  /**
   * List tasks
   */
  private async listTasks(projectName?: string): Promise<void> {
    const tasks = this.system!.getTasks(projectName);
    
    if (tasks.length === 0) {
      console.log(`📋 No tasks found${projectName ? ` for project '${projectName}'` : ''}.`);
      return;
    }

    console.log(`📋 Tasks (${tasks.length}):`);
    for (const task of tasks) {
      const statusIcon = task.status === 'completed' ? '✅' :
                        task.status === 'in_progress' ? '🔄' :
                        task.status === 'assigned' ? '📌' : '⏳';
      console.log(`   ${statusIcon} ${task.name} (${task.status})`);
      if (task.projectName) {
        console.log(`      Project: ${task.projectName}`);
      }
      if (task.assignedTo) {
        console.log(`      Assigned to: ${task.assignedTo}`);
      }
    }
    console.log();
  }

  /**
   * List artifacts
   */
  private async listArtifacts(projectName?: string): Promise<void> {
    const artifacts = this.system!.getArtifacts(projectName);
    
    if (artifacts.length === 0) {
      console.log(`📋 No artifacts found${projectName ? ` for project '${projectName}'` : ''}.`);
      return;
    }

    console.log(`📋 Artifacts (${artifacts.length}):`);
    for (const artifact of artifacts) {
      const type = artifact.key?.includes('code') ? '💻' :
                  artifact.key?.includes('tests') ? '🧪' :
                  artifact.key?.includes('docs') ? '📝' : '📦';
      console.log(`   ${type} ${artifact.key || 'unnamed'}`);
      if (artifact.projectName) {
        console.log(`      Project: ${artifact.projectName}`);
      }
      if (artifact.language) {
        console.log(`      Language: ${artifact.language}`);
      }
    }
    console.log();
  }

  /**
   * Show system status
   */
  private async showStatus(): Promise<void> {
    const status = this.system!.getStatus();
    
    console.log('📊 System Status');
    console.log('===============');
    console.log(`   Running: ${status.running}`);
    console.log(`   Agents: ${status.agents?.length || 0}`);
    
    if (status.agents) {
      for (const agent of status.agents) {
        const statusIcon = agent.running ? '✅' : '❌';
        console.log(`      ${statusIcon} ${agent.name} (${agent.status})`);
      }
    }
    
    console.log('\n   Registry:');
    console.log(`      Total agents: ${status.registry?.totalAgents || 0}`);
    console.log(`      Online: ${status.registry?.onlineAgents || 0}`);
    console.log(`      Offline: ${status.registry?.offlineAgents || 0}`);
    
    console.log('\n   Memory:');
    console.log(`      Total entries: ${status.memory?.totalEntries || 0}`);
    console.log(`      Total keys: ${status.memory?.totalKeys || 0}`);
    
    if (status.memory?.types) {
      console.log('      Types:');
      for (const [type, count] of Object.entries(status.memory.types)) {
        console.log(`         ${type}: ${count}`);
      }
    }
    
    console.log();
  }

  /**
   * Show help
   */
  private showHelp(): void {
    console.log('\n📚 Available Commands:');
    console.log('=====================');
    console.log('  create-project <name> [description] [requirements]  - Create a new project');
    console.log('  list-projects                                       - List all projects');
    console.log('  project <name>                                     - Show project details');
    console.log('  tasks [project-name]                              - List tasks');
    console.log('  artifacts [project-name]                          - List artifacts');
    console.log('  status                                            - Show system status');
    console.log('  help                                              - Show this help');
    console.log('  quit/exit                                         - Exit the application');
    console.log();
    console.log('Examples:');
    console.log('  create-project "My App" "Build a web app" "React, Node.js, PostgreSQL"');
    console.log('  project "My App"');
    console.log('  tasks "My App"');
    console.log();
  }

  /**
   * Shutdown the CLI
   */
  async shutdown(): Promise<void> {
    if (this.system) {
      await this.system.stop();
    }
    this.rl.close();
  }
}

/**
 * Main entry point
 */
const main = async (): Promise<void> => {
  logger.info('Starting Advanced System CLI');

  const cli = new AdvancedSystemCLI();

  process.on('SIGINT', async () => {
    console.log('\n\n⏹️ Shutting down...');
    await cli.shutdown();
    process.exit(0);
  });

  process.on('SIGTERM', async () => {
    await cli.shutdown();
    process.exit(0);
  });

  await cli.start();
};

if (import.meta.url === `file://${process.argv[1]}`) {
  void main();
}
```

## The Verification

### Step 1: Build the System

```bash
cd ai-integration-javascript/multi-agent/advanced-architecture
npm install
npm run build
```

### Step 2: Start the System

```bash
npm run start:cli
```

### Step 3: Create a Project

At the CLI prompt:

```
> create-project "Data Analysis Dashboard" "Build a dashboard for analyzing user data" "PostgreSQL, React, Chart.js"

📋 Creating project: Data Analysis Dashboard...
⏳ This may take a few moments...

✅ Project created successfully!
📊 Project: Data Analysis Dashboard
📝 Summary: Standard software development workflow
📋 Tasks: 5 tasks created

Tasks:
   - Research Requirements (unassigned)
   - Design Architecture (unassigned)
   - Implement Code (unassigned)
   - Review Code (unassigned)
   - Deploy Application (unassigned)
```

### Step 4: Check Status

```
> status

📊 System Status
===============
   Running: true
   Agents: 2
      ✅ supervisor (online)
      ✅ coder (online)

   Registry:
      Total agents: 2
      Online: 2
      Offline: 0

   Memory:
      Total entries: 12
      Total keys: 6
      Types:
         context: 8
         artifact: 2
         result: 2
```

### Step 5: List Projects

```
> list-projects

📋 Projects (1):
   - Data Analysis Dashboard: active (0/5 tasks)
```

## What You've Built

You've built an advanced multi-agent system that functions as a complete AI software development team:

### Core Components
1. **Coordinator Agent** — Orchestrates the overall workflow
2. **Supervisor Agent** — Breaks down projects and assigns tasks
3. **Coding Agent** — Generates code from requirements
4. **Shared Memory** — Cross-agent context sharing
5. **Event-Driven Workflow** — Reactive task execution

### Architectural Patterns
1. **Hierarchical** — Coordinator → Supervisor → Workers
2. **Planner-Worker** — Supervisor plans, Workers execute
3. **Shared Memory** — All agents access common context
4. **Event-Driven** — Agents react to events and messages
5. **Human-in-the-Loop** — CLI interface for user interaction

### Capabilities
1. **Project Planning** — Break down requirements into tasks
2. **Task Delegation** — Assign tasks to appropriate agents
3. **Code Generation** — Write production-ready code
4. **Artifact Management** — Store and retrieve artifacts
5. **Progress Tracking** — Monitor project and task status

## Key Takeaways

1. **Hierarchy Works** — Coordinators and supervisors scale well
2. **Shared Memory is Essential** — Agents need context
3. **Event-Driven is Natural** — Agents react to messages
4. **Planning is Critical** — Good plans lead to good execution
5. **Human-in-the-Loop** — Users provide guidance and oversight
6. **Artifacts Drive Progress** — Code, tests, and docs are valuable outputs

## What's Next?

In **Part 10**, we'll focus on **Production Engineering** — deploying, securing, monitoring, and scaling our AI systems in production environments.

This concludes the comprehensive 9-part tutorial series on mastering AI integration with MCP and A2A using JavaScript. You've progressed from building your first MCP server through creating autonomous agents to orchestrating entire AI development teams.

**Summary of What You've Built:**

| Part | Topic | Key Achievement |
|------|-------|-----------------|
| 0 | Introduction | Understanding the journey ahead |
| 1 | First MCP Server | Complete MCP server with tools, resources, prompts |
| 2 | Advanced MCP Features | HTTP client, caching, authentication |
| 3 | Production MCP Client | Reusable client library |
| 4 | SQLite Integration | Enterprise database access |
| 5 | PostgreSQL Integration | Production database with query optimization |
| 6 | Knowledge Server | Unified access to multiple data sources |
| 7 | Autonomous Agent | Self-directed research assistant |
| 8 | A2A Collaboration | Multi-agent team with communication |
| 9 | Advanced Multi-Agent | AI software development team |

You now have the knowledge and code to build production-ready AI systems that integrate with enterprise systems, operate autonomously, and collaborate across agent teams.
