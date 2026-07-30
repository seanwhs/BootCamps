# Primer 5: Understanding AI Agents & LLM Integration

## A Deep Dive into Building Intelligent Systems

Welcome to the fifth primer! This is a comprehensive deep dive into AI agents and LLM (Large Language Model) integration. Think of this like building a team of incredibly smart assistants who can understand complex tasks, use tools to accomplish them, learn from their experiences, and work together to solve problems.

### 1. The Big Picture

#### What is an AI Agent?

An AI agent is a system that uses an LLM to perceive its environment, make decisions, take actions, and learn from the results. It's like having a digital employee who can understand natural language, think through problems, use tools, and improve over time.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AI AGENT ARCHITECTURE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         AGENT CORE                                 │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    LLM (Brain)                              │   │   │
│  │  │  • Understands natural language                            │   │   │
│  │  │  • Reasons about problems                                  │   │   │
│  │  │  • Makes plans and decisions                               │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    MEMORY                                  │   │   │
│  │  │  • Short-term: Current context                             │   │   │
│  │  │  • Long-term: Past experiences                             │   │   │
│  │  │  • Vector embeddings for semantic search                   │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    TOOLS                                   │   │   │
│  │  │  • APIs and integrations                                   │   │   │
│  │  │  • Functions and operations                                │   │   │
│  │  │  • External services                                       │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    AGENTIC LOOP                                     │   │
│  │                                                                     │   │
│  │  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐  │   │
│  │  │  PERCEIVE    │───▶│    PLAN      │───▶│     EXECUTE          │  │   │
│  │  │  (Observe    │    │   (Think)    │    │    (Act)             │  │   │
│  │  │   state,     │    │  Break down  │    │  Use tools,          │  │   │
│  │  │   user input)│    │  into steps) │    │  perform actions)    │  │   │
│  │  └──────────────┘    └──────────────┘    └──────────────────────┘  │   │
│  │         │                                      │                   │   │
│  │         │                                      ▼                   │   │
│  │         │              ┌──────────────────────────────────────┐   │   │
│  │         └─────────────▶│        REFLECT                      │   │   │
│  │                        │   (Learn from results)              │   │   │
│  │                        └──────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. LLM Integration

#### Core LLM Concepts

**1. Tokens:**
The basic units of text that LLMs process. A token can be a word, part of a word, or a character.

```typescript
// Token counting example
function countTokens(text: string): number {
    // In production, use tiktoken or similar library
    // This is a simplified approximation
    return text.split(/[\s,.;!?]+/).length;
}

// Example usage
const prompt = "Create a new task called 'Build the API'";
const tokens = countTokens(prompt);
console.log(`Prompt uses ~${tokens} tokens`);
// Output: Prompt uses ~9 tokens
```

**2. Temperature:**
Controls the randomness of the output. Higher = more creative, lower = more deterministic.

```typescript
interface LLMConfig {
    temperature: number; // 0 to 1
    maxTokens: number;
    topP: number;
    frequencyPenalty: number;
    presencePenalty: number;
}

const configs = {
    creative: {
        temperature: 0.9,
        maxTokens: 1000,
        topP: 0.95,
        frequencyPenalty: 0.5,
        presencePenalty: 0.5,
    },
    deterministic: {
        temperature: 0.1,
        maxTokens: 500,
        topP: 0.9,
        frequencyPenalty: 0,
        presencePenalty: 0,
    },
    balanced: {
        temperature: 0.5,
        maxTokens: 750,
        topP: 0.92,
        frequencyPenalty: 0.3,
        presencePenalty: 0.3,
    },
};
```

#### LLM Adapter Pattern

```typescript
// LLM Adapter Interface
interface ILLMAdapter {
    complete(messages: Message[], options?: LLMOptions): Promise<LLMResponse>;
    stream(messages: Message[], options?: LLMOptions): AsyncIterable<LLMResponse>;
    embed(text: string): Promise<number[]>;
}

// OpenAI Implementation
class OpenAIAdapter implements ILLMAdapter {
    private client: OpenAI;
    private model: string;

    constructor(config: { apiKey: string; model?: string }) {
        this.client = new OpenAI({ apiKey: config.apiKey });
        this.model = config.model || 'gpt-4-turbo-preview';
    }

    async complete(messages: Message[], options?: LLMOptions): Promise<LLMResponse> {
        const response = await this.client.chat.completions.create({
            model: this.model,
            messages: messages.map(m => ({
                role: m.role,
                content: m.content,
                ...(m.toolCalls && { tool_calls: m.toolCalls }),
            })),
            temperature: options?.temperature || 0.7,
            max_tokens: options?.maxTokens || 1000,
            tools: options?.tools,
            tool_choice: options?.toolChoice as any,
        });

        return {
            id: response.id,
            content: response.choices[0].message.content || '',
            toolCalls: response.choices[0].message.tool_calls || [],
            usage: {
                promptTokens: response.usage?.prompt_tokens || 0,
                completionTokens: response.usage?.completion_tokens || 0,
                totalTokens: response.usage?.total_tokens || 0,
            },
        };
    }

    async *stream(messages: Message[], options?: LLMOptions): AsyncIterable<LLMResponse> {
        const stream = await this.client.chat.completions.create({
            model: this.model,
            messages: messages.map(m => ({ role: m.role, content: m.content })),
            temperature: options?.temperature || 0.7,
            max_tokens: options?.maxTokens || 1000,
            stream: true,
        });

        for await (const chunk of stream) {
            yield {
                id: chunk.id,
                content: chunk.choices[0]?.delta?.content || '',
                toolCalls: [],
                usage: { promptTokens: 0, completionTokens: 0, totalTokens: 0 },
            };
        }
    }

    async embed(text: string): Promise<number[]> {
        const response = await this.client.embeddings.create({
            model: 'text-embedding-3-small',
            input: text,
        });
        return response.data[0].embedding;
    }
}
```

### 3. Agent Memory Systems

#### Vector Memory

Vector memory stores embeddings of text for semantic search.

```typescript
class VectorMemory implements IMemory {
    private memories: Map<string, MemoryEntry> = new Map();
    private llm: ILLMAdapter;

    constructor(llm: ILLMAdapter) {
        this.llm = llm;
    }

    async store(content: string, metadata: Record<string, any> = {}): Promise<string> {
        const id = randomUUID();
        const embedding = await this.llm.embed(content);
        
        this.memories.set(id, {
            id,
            content,
            embedding,
            metadata,
            timestamp: new Date(),
        });

        return id;
    }

    async search(query: string, limit: number = 10): Promise<MemoryEntry[]> {
        const queryEmbedding = await this.llm.embed(query);
        const results: Array<{ entry: MemoryEntry; similarity: number }> = [];

        for (const entry of this.memories.values()) {
            if (!entry.embedding) continue;
            const similarity = this.cosineSimilarity(queryEmbedding, entry.embedding);
            results.push({ entry, similarity });
        }

        results.sort((a, b) => b.similarity - a.similarity);
        return results.slice(0, limit).map(r => r.entry);
    }

    private cosineSimilarity(a: number[], b: number[]): number {
        let dotProduct = 0;
        let normA = 0;
        let normB = 0;

        for (let i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        if (normA === 0 || normB === 0) return 0;
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }

    async getRecent(limit: number = 10): Promise<MemoryEntry[]> {
        return Array.from(this.memories.values())
            .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
            .slice(0, limit);
    }

    async getContext(maxTokens: number = 2000): Promise<string> {
        const recent = await this.getRecent(20);
        const context = recent
            .map(m => `[${m.timestamp.toISOString()}] ${m.content}`)
            .join('\n');
        // Truncate to approximate token limit
        return context.slice(0, maxTokens * 2); // Rough approximation
    }
}
```

#### Context Management

```typescript
class ContextManager {
    private maxTokens: number = 4000;
    private tokenCounter: (text: string) => number;

    constructor(maxTokens: number = 4000) {
        this.maxTokens = maxTokens;
        this.tokenCounter = (text: string) => text.length / 4; // Rough approximation
    }

    async buildContext(messages: Message[], memories: MemoryEntry[]): Promise<string> {
        let context = '';
        let tokens = 0;

        // Add system prompt
        const systemPrompt = `You are an AI assistant. Help the user accomplish their task.`;
        context += systemPrompt + '\n';
        tokens += this.tokenCounter(systemPrompt);

        // Add recent memories
        for (const memory of memories.slice(0, 10)) {
            const memoryStr = `[${memory.timestamp.toISOString()}] ${memory.content}`;
            const memoryTokens = this.tokenCounter(memoryStr);
            
            if (tokens + memoryTokens > this.maxTokens) break;
            
            context += memoryStr + '\n';
            tokens += memoryTokens;
        }

        // Add conversation history
        for (const message of messages.slice(-5)) {
            const msgStr = `${message.role}: ${message.content}`;
            const msgTokens = this.tokenCounter(msgStr);
            
            if (tokens + msgTokens > this.maxTokens) break;
            
            context += msgStr + '\n';
            tokens += msgTokens;
        }

        return context;
    }

    truncateContext(context: string): string {
        const words = context.split(' ');
        const maxWords = this.maxTokens * 0.75; // Leave room for response
        if (words.length > maxWords) {
            return words.slice(0, maxWords).join(' ') + '...';
        }
        return context;
    }
}
```

### 4. Tool Use and Function Calling

#### Tool Definition

```typescript
interface Tool {
    name: string;
    description: string;
    parameters: {
        type: 'object';
        properties: Record<string, {
            type: string;
            description: string;
            enum?: string[];
        }>;
        required: string[];
    };
    execute: (params: Record<string, any>) => Promise<any>;
}

// Example Tools
class TaskTool implements Tool {
    name = 'create_task';
    description = 'Create a new task in the system';
    parameters = {
        type: 'object' as const,
        properties: {
            title: {
                type: 'string',
                description: 'The title of the task',
            },
            description: {
                type: 'string',
                description: 'Detailed description of the task',
            },
            priority: {
                type: 'string',
                enum: ['low', 'medium', 'high', 'critical'],
                description: 'Priority level of the task',
            },
            dueDate: {
                type: 'string',
                description: 'Due date in ISO format',
            },
        },
        required: ['title', 'description'],
    };

    constructor(private readonly taskService: TaskService) {}

    async execute(params: Record<string, any>): Promise<any> {
        return await this.taskService.createTask({
            title: params.title,
            description: params.description,
            priority: params.priority || 'medium',
            dueDate: params.dueDate ? new Date(params.dueDate) : undefined,
        });
    }
}

class UserTool implements Tool {
    name = 'get_user';
    description = 'Get user information by email or ID';
    parameters = {
        type: 'object' as const,
        properties: {
            identifier: {
                type: 'string',
                description: 'User email or ID',
            },
        },
        required: ['identifier'],
    };

    constructor(private readonly userService: UserService) {}

    async execute(params: Record<string, any>): Promise<any> {
        const { identifier } = params;
        if (identifier.includes('@')) {
            return await this.userService.findByEmail(identifier);
        } else {
            return await this.userService.findById(identifier);
        }
    }
}
```

#### Tool Registry

```typescript
class ToolRegistry {
    private tools: Map<string, Tool> = new Map();

    register(tool: Tool): void {
        this.tools.set(tool.name, tool);
    }

    getTool(name: string): Tool | undefined {
        return this.tools.get(name);
    }

    getDefinitions(): ToolDefinition[] {
        return Array.from(this.tools.values()).map(tool => ({
            name: tool.name,
            description: tool.description,
            parameters: tool.parameters,
        }));
    }

    async executeToolCall(toolCall: ToolCall): Promise<any> {
        const tool = this.getTool(toolCall.function.name);
        if (!tool) {
            throw new Error(`Tool ${toolCall.function.name} not found`);
        }

        try {
            const params = JSON.parse(toolCall.function.arguments);
            return await tool.execute(params);
        } catch (error) {
            return {
                error: error instanceof Error ? error.message : String(error),
            };
        }
    }
}
```

### 5. Building an Agent

#### Base Agent Class

```typescript
abstract class BaseAgent {
    protected memory: IMemory;
    protected tools: ToolRegistry;
    protected llm: ILLMAdapter;
    protected config: AgentConfig;
    protected state: AgentState;

    constructor(config: AgentConfig, deps: {
        memory: IMemory;
        tools: ToolRegistry;
        llm: ILLMAdapter;
    }) {
        this.config = config;
        this.memory = deps.memory;
        this.tools = deps.tools;
        this.llm = deps.llm;
        this.state = {
            id: randomUUID(),
            iteration: 0,
            completed: false,
            history: [],
        };
    }

    async run(task: string): Promise<any> {
        // Store initial task
        await this.memory.store(`Task: ${task}`);

        while (!this.state.completed && this.state.iteration < 10) {
            this.state.iteration++;
            
            // 1. Perceive - get context
            const context = await this.perceive();

            // 2. Plan - decide next action
            const plan = await this.plan(context);

            // 3. Execute - take action
            await this.execute(plan);

            // 4. Reflect - learn from results
            await this.reflect();
        }

        return this.state.result;
    }

    protected async perceive(): Promise<string> {
        // Get recent memories and context
        const context = await this.memory.getContext();
        await this.memory.store(`Current context: ${context.slice(0, 500)}`);
        return context;
    }

    protected async plan(context: string): Promise<LLMResponse> {
        const tools = this.tools.getDefinitions();
        const messages: LLMMessage[] = [
            {
                role: 'system',
                content: this.config.systemPrompt,
            },
            {
                role: 'user',
                content: `Context: ${context}\n\nWhat should I do next?`,
            },
        ];

        return await this.llm.complete(messages, {
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
    }

    protected async execute(plan: LLMResponse): Promise<void> {
        if (plan.toolCalls && plan.toolCalls.length > 0) {
            for (const toolCall of plan.toolCalls) {
                const result = await this.tools.executeToolCall(toolCall);
                await this.memory.store(
                    `Tool ${toolCall.function.name} result: ${JSON.stringify(result)}`,
                    { tool: toolCall.function.name }
                );
            }
        } else {
            await this.memory.store(`Plan: ${plan.content}`);
        }
    }

    protected async reflect(): Promise<void> {
        const recent = await this.memory.getRecent(5);
        const reflections = await this.llm.complete([
            {
                role: 'system',
                content: 'Reflect on the recent actions. What went well? What could be improved?',
            },
            {
                role: 'user',
                content: `Recent actions:\n${recent.map(r => `- ${r.content}`).join('\n')}`,
            },
        ]);

        await this.memory.store(`Reflection: ${reflections.content}`);

        if (reflections.content.toLowerCase().includes('complete')) {
            this.state.completed = true;
            this.state.result = reflections.content;
        }
    }

    abstract getSystemPrompt(): string;
}
```

#### Specialized Agent: Task Manager Agent

```typescript
class TaskManagerAgent extends BaseAgent {
    constructor(deps: {
        memory: IMemory;
        tools: ToolRegistry;
        llm: ILLMAdapter;
    }) {
        super({
            name: 'TaskManager',
            systemPrompt: `You are a task management agent. You help users create, update, and track tasks.

            Your responsibilities:
            1. Understand what the user wants to accomplish
            2. Create tasks with appropriate details
            3. Update task status as work progresses
            4. Provide updates on task status

            When creating tasks, ensure you have:
            - Clear title
            - Good description
            - Appropriate priority
            - Reasonable due date

            When a task is created, follow up to ensure it gets completed.`,
            temperature: 0.7,
            maxTokens: 1000,
        }, deps);
    }

    getSystemPrompt(): string {
        return this.config.systemPrompt;
    }

    // Custom method for task creation
    async createTaskFromDescription(description: string): Promise<Task> {
        // Use LLM to extract task details
        const response = await this.llm.complete([
            {
                role: 'system',
                content: 'Extract task details from the description. Return as JSON.',
            },
            {
                role: 'user',
                content: description,
            },
        ]);

        const taskData = JSON.parse(response.content);
        const tool = this.tools.getTool('create_task');
        
        if (!tool) {
            throw new Error('Create task tool not available');
        }

        return await tool.execute(taskData);
    }
}
```

#### Orchestrator Agent

```typescript
class OrchestratorAgent extends BaseAgent {
    private subAgents: Map<string, BaseAgent> = new Map();

    constructor(deps: {
        memory: IMemory;
        tools: ToolRegistry;
        llm: ILLMAdapter;
    }) {
        super({
            name: 'Orchestrator',
            systemPrompt: `You are an orchestrator agent that coordinates other agents and tools.

            Your responsibilities:
            1. Break down complex tasks into subtasks
            2. Delegate subtasks to appropriate agents
            3. Monitor progress and coordinate execution
            4. Synthesize results

            When breaking down tasks, consider:
            - What subtasks are needed?
            - What order should they be done in?
            - Which agent is best for each subtask?
            - How will results be combined?`,
            temperature: 0.7,
            maxTokens: 1000,
        }, deps);
    }

    registerAgent(name: string, agent: BaseAgent): void {
        this.subAgents.set(name, agent);
    }

    getSystemPrompt(): string {
        return this.config.systemPrompt;
    }

    protected async plan(context: string): Promise<LLMResponse> {
        // Check if we need to delegate
        const messages: LLMMessage[] = [
            {
                role: 'system',
                content: this.config.systemPrompt,
            },
            {
                role: 'user',
                content: `Context: ${context}\n\nAvailable agents: ${Array.from(this.subAgents.keys()).join(', ')}\n\nWhat should I do next?`,
            },
        ];

        return await this.llm.complete(messages, {
            temperature: this.config.temperature,
            maxTokens: this.config.maxTokens,
        });
    }

    protected async execute(plan: LLMResponse): Promise<void> {
        // Check if plan involves delegation
        const subtasks = this.extractSubtasks(plan.content);
        
        if (subtasks.length === 0) {
            await super.execute(plan);
            return;
        }

        // Execute subtasks in parallel or sequence
        const results = [];
        for (const subtask of subtasks) {
            const agent = this.selectAgent(subtask);
            if (agent) {
                const result = await agent.run(subtask);
                results.push(result);
            } else {
                // Use tools directly
                const result = await this.executeWithTools(subtask);
                results.push(result);
            }
        }

        // Store results
        await this.memory.store(`Subtask results: ${JSON.stringify(results)}`);
    }

    private extractSubtasks(plan: string): string[] {
        // Look for numbered lists or bullet points
        const lines = plan.split('\n');
        const subtasks: string[] = [];

        for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed.match(/^\d+[\.\)]\s/) || trimmed.match(/^[\-\*]\s/)) {
                const task = trimmed.replace(/^[\d\.\)\s]+/, '')
                                   .replace(/^[\-\*\s]+/, '')
                                   .trim();
                if (task) {
                    subtasks.push(task);
                }
            }
        }

        return subtasks;
    }

    private selectAgent(subtask: string): BaseAgent | null {
        // Simple keyword matching
        const keywords: Record<string, string[]> = {
            'task': ['task', 'todo', 'work item'],
            'user': ['user', 'profile', 'account'],
            'search': ['search', 'find', 'lookup'],
        };

        const lowerSubtask = subtask.toLowerCase();
        for (const [agentName, agentKeywords] of Object.entries(keywords)) {
            if (agentKeywords.some(keyword => lowerSubtask.includes(keyword))) {
                return this.subAgents.get(agentName) || null;
            }
        }

        return null;
    }

    private async executeWithTools(subtask: string): Promise<any> {
        const tools = this.tools.getDefinitions();
        const response = await this.llm.complete([
            {
                role: 'system',
                content: `Execute this subtask using available tools: ${tools.map(t => t.name).join(', ')}`,
            },
            {
                role: 'user',
                content: subtask,
            },
        ]);

        if (response.toolCalls && response.toolCalls.length > 0) {
            const results = [];
            for (const toolCall of response.toolCalls) {
                const result = await this.tools.executeToolCall(toolCall);
                results.push(result);
            }
            return results;
        }

        return response.content;
    }
}
```

### 6. Advanced Patterns

#### Chain of Thought Reasoning

```typescript
class ChainOfThoughtAgent extends BaseAgent {
    protected async plan(context: string): Promise<LLMResponse> {
        const messages: LLMMessage[] = [
            {
                role: 'system',
                content: `You are a reasoning agent. Solve problems step by step.

                Think through each step carefully before acting.
                Show your reasoning process.
                Make sure each step builds on the previous one.`,
            },
            {
                role: 'user',
                content: `Context: ${context}\n\nLet's think through this step by step.`,
            },
        ];

        // Get reasoning steps
        const response = await this.llm.complete(messages, {
            temperature: 0.3,
            maxTokens: 500,
        });

        // Extract steps
        const steps = this.extractSteps(response.content);
        await this.memory.store(`Reasoning steps: ${JSON.stringify(steps)}`);

        return response;
    }

    private extractSteps(response: string): string[] {
        const steps: string[] = [];
        const lines = response.split('\n');
        let inSteps = false;

        for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed.toLowerCase().includes('step')) {
                inSteps = true;
            }
            if (inSteps && trimmed.match(/^\d+[\.\)]\s/)) {
                steps.push(trimmed.replace(/^\d+[\.\)]\s+/, ''));
            }
        }

        return steps;
    }
}
```

#### ReAct Pattern (Reasoning + Acting)

```typescript
class ReActAgent extends BaseAgent {
    private thinkActionLoop: boolean = true;

    protected async plan(context: string): Promise<LLMResponse> {
        const messages: LLMMessage[] = [
            {
                role: 'system',
                content: `You are a ReAct agent. For each step:

                Thought: Consider what to do next
                Action: Choose a tool to use
                Observation: See the result

                Continue until the task is complete.`,
            },
            {
                role: 'user',
                content: `Context: ${context}\n\nWhat's your next thought and action?`,
            },
        ];

        return await this.llm.complete(messages, {
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
    }

    protected async reflect(): Promise<void> {
        const recent = await this.memory.getRecent(3);
        const reflection = await this.llm.complete([
            {
                role: 'system',
                content: 'Reflect on your recent actions. What did you learn?',
            },
            {
                role: 'user',
                content: `Recent actions:\n${recent.map(r => `- ${r.content}`).join('\n')}`,
            },
        ]);

        await this.memory.store(`Reflection: ${reflection.content}`);

        // Check if task is complete
        if (reflection.content.toLowerCase().includes('task complete')) {
            this.state.completed = true;
            this.state.result = reflection.content;
        }
    }
}
```

### 7. Best Practices

#### Prompt Engineering

```typescript
class PromptBuilder {
    static buildSystemPrompt(role: string, context: string): string {
        return `
You are a ${role} assistant.

Context:
${context}

Guidelines:
- Be helpful and concise
- Ask for clarification when needed
- Break down complex tasks
- Use tools when appropriate
- Provide clear reasoning

Output Format:
- Use clear structure
- Show your reasoning
- Provide actionable steps
        `.trim();
    }

    static buildFewShotExamples(examples: Array<{
        input: string;
        output: string;
    }>): string {
        const formatted = examples.map(e => 
            `Input: ${e.input}\nOutput: ${e.output}`
        ).join('\n\n');
        
        return `Here are some examples of how to respond:\n\n${formatted}`;
    }
}
```

#### Error Handling

```typescript
class SafeAgent {
    protected async executeSafely(fn: () => Promise<any>): Promise<any> {
        try {
            return await fn();
        } catch (error) {
            // Log error
            await this.memory.store(
                `Error: ${error instanceof Error ? error.message : String(error)}`,
                { type: 'error' }
            );
            
            // Try to recover
            if (this.state.iteration < 3) {
                await this.memory.store('Attempting recovery...');
                // Try alternative approach
                return await this.retryWithAlternative(error);
            }
            
            throw error;
        }
    }

    private async retryWithAlternative(error: unknown): Promise<any> {
        const alternativePlan = await this.llm.complete([
            {
                role: 'system',
                content: `Previous attempt failed with error: ${error}\n\nSuggest an alternative approach.`,
            },
        ]);

        return await this.execute(alternativePlan);
    }
}
```

### 8. Key Takeaways

1. **AI Agents are Systems, Not Just APIs:**
   - Combine LLM with memory, tools, and reasoning
   - The whole is greater than the sum of parts

2. **Memory is Crucial:**
   - Short-term: Current context
   - Long-term: Past experiences
   - Vector embeddings for semantic search

3. **Tools Extend Capabilities:**
   - Agents can interact with the world
   - Well-defined tool interfaces are key
   - Tools should be focused and atomic

4. **Agentic Loop:**
   - Perceive → Plan → Execute → Reflect
   - Continuous learning and improvement
   - Iterative problem-solving

5. **Prompt Engineering Matters:**
   - Clear system prompts
   - Few-shot examples
   - Structured output formats

6. **Error Handling is Essential:**
   - Agents will make mistakes
   - Build in recovery mechanisms
   - Learn from failures

---

This primer provides a comprehensive understanding of AI agents and LLM integration. These concepts are essential for building intelligent systems that can understand, reason, and act autonomously.
