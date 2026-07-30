# Primer 3: Understanding LLM Agents and State Machines

## Overview

This primer provides a comprehensive deep dive into LLM agents, state machines, and the architectural patterns that make autonomous AI systems possible. While the main tutorial series focuses on implementation with LangGraph.js, this primer explores the theoretical foundations, design patterns, and decision frameworks for building agentic systems.

---

## P3.1 What Are LLM Agents?

### The Core Concept

An **LLM Agent** is an autonomous system that uses a language model to:
1. **Plan** actions based on goals
2. **Execute** actions using tools
3. **Observe** results from actions
4. **Reflect** on outcomes
5. **Iterate** until goals are achieved

Think of an agent as a **goal-oriented problem solver** that can use tools, make decisions, and adapt to changing circumstances.

### Agent vs. Pipeline

| Aspect | Pipeline | Agent |
|--------|----------|-------|
| **Control Flow** | Fixed, linear | Dynamic, branching |
| **Decision Making** | Pre-determined | Autonomous |
| **Tool Use** | Integrated | Selected on-the-fly |
| **Adaptability** | Low | High |
| **Predictability** | High | Lower |
| **Complexity** | Simple | Complex |

### The Agent Cycle

```
┌─────────────────────────────────────────────────────────┐
│                    Agent Cycle                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────┐                                          │
│   │  Goal    │                                          │
│   │  Input   │                                          │
│   └────┬─────┘                                          │
│        │                                                 │
│        ▼                                                 │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐       │
│   │  Plan    │────▶│  Act     │────▶│ Observe  │       │
│   │  (Think) │     │  (Tool)  │     │ (Result) │       │
│   └──────────┘     └──────────┘     └──────────┘       │
│        │                                   │             │
│        │                                   │             │
│        └───────────────┬───────────────────┘             │
│                        │                                 │
│                        ▼                                 │
│                   ┌──────────┐                          │
│                   │ Reflect  │                          │
│                   │ (Learn)  │                          │
│                   └──────────┘                          │
│                        │                                 │
│                        ▼                                 │
│                   ┌──────────┐                          │
│                   │ Complete │                          │
│                   └──────────┘                          │
└─────────────────────────────────────────────────────────┘
```

### Code: Simple Agent Implementation

```typescript
interface AgentState {
  goal: string;
  plan: string[];
  actions: Action[];
  observations: Observation[];
  completed: boolean;
  iteration: number;
  maxIterations: number;
}

class SimpleAgent {
  async run(goal: string): Promise<string> {
    const state: AgentState = {
      goal,
      plan: [],
      actions: [],
      observations: [],
      completed: false,
      iteration: 0,
      maxIterations: 5,
    };
    
    while (!state.completed && state.iteration < state.maxIterations) {
      // Plan
      state.plan = await this.plan(state);
      
      // Act
      for (const action of state.plan) {
        const result = await this.execute(action);
        state.observations.push(result);
      }
      
      // Reflect
      state.completed = await this.reflect(state);
      state.iteration++;
    }
    
    return await this.summarize(state);
  }
}
```

---

## P3.2 Agent Architectures

### Architecture 1: ReAct Agent

**ReAct** = **Re**asoning + **Act**ing

**Concept**: Interleave reasoning and action steps.

```
Thought: I need to search for RAG information
Action: Search("What is RAG?")
Observation: RAG is Retrieval-Augmented Generation...
Thought: I have enough information to answer
Action: Respond("RAG is...")
```

**Characteristics**:
- Step-by-step reasoning
- Transparent decision making
- Good for complex tasks

```typescript
class ReActAgent {
  async process(question: string): Promise<string> {
    let thought = `I need to answer: ${question}`;
    let observations: string[] = [];
    let maxSteps = 5;
    let step = 0;
    
    while (step < maxSteps) {
      // Generate next thought/action
      const response = await this.llm.invoke({
        messages: [
          new SystemMessage(this.systemPrompt),
          new HumanMessage(`
            Previous thoughts: ${thought}
            Observations: ${observations.join('\n')}
            
            What should I do next?
            Thought: ...
            Action: ...
          `),
        ],
      });
      
      // Parse thought and action
      const { thought: newThought, action } = this.parse(response);
      thought = newThought;
      
      // Execute action if needed
      if (action.type !== 'respond') {
        const result = await this.executeAction(action);
        observations.push(`${action.type}: ${result}`);
        step++;
      } else {
        return action.content;
      }
    }
    
    return "I couldn't find a complete answer.";
  }
}
```

### Architecture 2: Plan-and-Execute Agent

**Concept**: Create a complete plan first, then execute it.

```
Plan:
1. Search for RAG definition
2. Search for RAG benefits
3. Search for RAG examples
4. Synthesize answer

Execute:
[Step 1] → "RAG is Retrieval-Augmented Generation..."
[Step 2] → "Benefits include reducing hallucinations..."
[Step 3] → "Examples: customer support, legal research..."
[Step 4] → "RAG is a technique that combines retrieval with generation..."
```

**Characteristics**:
- Structured approach
- More predictable
- Better for multi-step tasks

```typescript
class PlanExecuteAgent {
  async process(goal: string): Promise<string> {
    // 1. Create plan
    const plan = await this.createPlan(goal);
    
    // 2. Execute plan
    const results: string[] = [];
    for (const step of plan) {
      const result = await this.executeStep(step);
      results.push(result);
    }
    
    // 3. Synthesize results
    return await this.synthesize(goal, results);
  }
  
  private async createPlan(goal: string): Promise<string[]> {
    const response = await this.llm.invoke({
      messages: [
        new SystemMessage(`Create a step-by-step plan to accomplish the goal.`),
        new HumanMessage(`Goal: ${goal}\nPlan:`),
      ],
    });
    return this.parsePlan(response.content);
  }
}
```

### Architecture 3: Hierarchical Agent

**Concept**: Agents with managers and workers.

```
                    ┌─────────────────┐
                    │   Manager       │
                    │   Agent         │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
       ┌──────────┐  ┌──────────┐  ┌──────────┐
       │ Search   │  │  Code    │  │  Data    │
       │ Worker   │  │  Worker  │  │  Worker  │
       └──────────┘  └──────────┘  └──────────┘
```

**Characteristics**:
- Decomposition of complex tasks
- Specialization
- Parallel execution

```typescript
class HierarchicalAgent {
  private manager: ManagerAgent;
  private workers: Map<string, WorkerAgent>;
  
  async process(goal: string): Promise<string> {
    // Manager decomposes goal
    const subtasks = await this.manager.decompose(goal);
    
    // Distribute to workers
    const results = await Promise.all(
      subtasks.map(subtask => {
        const worker = this.workers.get(subtask.type);
        return worker.execute(subtask);
      })
    );
    
    // Manager synthesizes results
    return await this.manager.synthesize(goal, results);
  }
}
```

### Architecture 4: Reflection Agent

**Concept**: Agents that critique and improve their own work.

```
Draft → Critic → Feedback → Revision → Final
```

**Characteristics**:
- Self-improvement
- Higher quality outputs
- Multiple iterations

```typescript
class ReflectionAgent {
  async process(goal: string): Promise<string> {
    // Initial draft
    let draft = await this.generateDraft(goal);
    let iterations = 0;
    const maxIterations = 3;
    
    while (iterations < maxIterations) {
      // Criticize
      const critique = await this.criticize(draft);
      
      if (critique.quality > 0.8) {
        break; // Good enough
      }
      
      // Revise
      draft = await this.revise(draft, critique.feedback);
      iterations++;
    }
    
    return draft;
  }
}
```

---

## P3.3 State Machines and State Management

### What is a State Machine?

A **state machine** is a mathematical model that:
1. Has a set of **states**
2. Has **transitions** between states
3. Responds to **events** that trigger transitions
4. Maintains **state** throughout execution

### Why Use State Machines for Agents?

1. **Predictability**: Clear states and transitions
2. **Traceability**: Easy to debug and monitor
3. **Resilience**: Can recover from failures
4. **Human-in-the-loop**: Clear pause and resume points
5. **Persistence**: Easy to save and restore

### Types of State Machines

#### 1. Finite State Machine (FSM)

```
States: IDLE → SEARCHING → EVALUATING → GENERATING → COMPLETE
Transitions: Based on conditions and events
```

```typescript
class FiniteStateMachine {
  private state: 'idle' | 'searching' | 'evaluating' | 'generating' | 'complete';
  private context: any = {};
  
  async transition(event: string, data: any) {
    switch (this.state) {
      case 'idle':
        if (event === 'start') {
          this.state = 'searching';
          this.context.query = data;
        }
        break;
        
      case 'searching':
        if (event === 'results') {
          this.context.results = data;
          this.state = 'evaluating';
        } else if (event === 'error') {
          this.state = 'idle';
          this.context.error = data;
        }
        break;
        
      case 'evaluating':
        if (event === 'quality_good') {
          this.state = 'generating';
        } else if (event === 'quality_poor') {
          this.state = 'searching';
          this.context.refinements = (this.context.refinements || 0) + 1;
        }
        break;
        
      case 'generating':
        if (event === 'complete') {
          this.context.answer = data;
          this.state = 'complete';
        }
        break;
    }
  }
}
```

#### 2. Hierarchical State Machine

```
┌─────────────────────────────────────────────┐
│                Agent State Machine           │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │       Processing State              │  │
│  │  ┌────────────┐  ┌────────────┐    │  │
│  │  │  Search    │  │  Evaluate  │    │  │
│  │  └────────────┘  └────────────┘    │  │
│  │  ┌────────────┐  ┌────────────┐    │  │
│  │  │  Generate  │  │  Reflect   │    │  │
│  │  └────────────┘  └────────────┘    │  │
│  └──────────────────────────────────────┘  │
│                    │                        │
│                    ▼                        │
│  ┌──────────────────────────────────────┐  │
│  │         Error State                  │  │
│  └──────────────────────────────────────┘  │
│                    │                        │
│                    ▼                        │
│  ┌──────────────────────────────────────┐  │
│  │         Complete State               │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

#### 3. State Machine with Persistence

```typescript
class PersistentStateMachine {
  private currentState: any;
  private storage: CheckpointStorage;
  
  async transition(event: string, data: any) {
    // Save state before transition
    await this.checkpoint();
    
    // Execute transition
    const result = await this.executeTransition(event, data);
    
    // Save state after transition
    await this.checkpoint();
    
    return result;
  }
  
  async checkpoint(): Promise<void> {
    const checkpoint = {
      state: this.currentState,
      context: this.context,
      timestamp: new Date().toISOString(),
      history: this.history,
    };
    
    await this.storage.save(checkpoint);
  }
  
  async resume(checkpointId: string): Promise<void> {
    const checkpoint = await this.storage.load(checkpointId);
    this.currentState = checkpoint.state;
    this.context = checkpoint.context;
    this.history = checkpoint.history;
  }
}
```

---

## P3.4 Tool Design and Integration

### Tool Pattern

**Tool** = A function that an agent can call to perform an action.

```typescript
interface Tool {
  name: string;
  description: string;
  parameters: z.ZodSchema;
  execute: (params: any) => Promise<any>;
}

class SearchTool implements Tool {
  name = 'search';
  description = 'Search for information on a topic';
  parameters = z.object({
    query: z.string().describe('The search query'),
  });
  
  async execute(params: { query: string }) {
    return await searchEngine.search(params.query);
  }
}

class CalculatorTool implements Tool {
  name = 'calculator';
  description = 'Perform mathematical calculations';
  parameters = z.object({
    expression: z.string().describe('Mathematical expression'),
  });
  
  async execute(params: { expression: string }) {
    return eval(params.expression);
  }
}
```

### Tool Selection Strategies

#### Strategy 1: LLM-based Selection

```typescript
class LLMToolSelector {
  async selectTool(goal: string, tools: Tool[]): Promise<Tool> {
    const prompt = `
      Goal: ${goal}
      Available tools: ${tools.map(t => `${t.name}: ${t.description}`).join('\n')}
      
      Which tool should I use?
    `;
    
    const response = await llm.invoke(prompt);
    const toolName = this.parseToolName(response.content);
    return tools.find(t => t.name === toolName)!;
  }
}
```

#### Strategy 2: Rule-based Selection

```typescript
class RuleBasedToolSelector {
  selectTool(goal: string, tools: Tool[]): Tool[] {
    const selected: Tool[] = [];
    
    for (const tool of tools) {
      // Simple keyword matching
      if (this.matchKeywords(goal, tool)) {
        selected.push(tool);
      }
    }
    
    return selected;
  }
  
  private matchKeywords(goal: string, tool: Tool): boolean {
    const keywords = {
      search: ['find', 'search', 'lookup', 'retrieve'],
      calculate: ['calculate', 'compute', 'sum', 'math'],
      code: ['code', 'program', 'function', 'implement'],
    };
    
    const toolKeywords = keywords[tool.name] || [];
    return toolKeywords.some(kw => goal.toLowerCase().includes(kw));
  }
}
```

### Tool Composition

```typescript
class ToolComposition {
  async compose(tools: Tool[], goal: string): Promise<any> {
    // Create a sequence of tool calls
    const plan = await this.createPlan(tools, goal);
    
    let result = null;
    for (const step of plan) {
      const tool = tools.find(t => t.name === step.tool);
      if (!tool) continue;
      
      // Pass previous result as parameter
      const params = {
        ...step.params,
        previousResult: result,
      };
      
      result = await tool.execute(params);
    }
    
    return result;
  }
}
```

---

## P3.5 Human-in-the-Loop (HITL)

### Why HITL?

1. **Quality**: Human oversight for critical decisions
2. **Trust**: Build confidence in the system
3. **Safety**: Prevent harmful actions
4. **Learning**: Gather human feedback for improvement

### HITL Patterns

#### Pattern 1: Approval Gate

```typescript
class ApprovalGate {
  async approve(action: Action): Promise<boolean> {
    // Send approval request
    const request = {
      id: uuid(),
      action: action.description,
      context: action.context,
      timestamp: new Date(),
    };
    
    await this.notifyApprover(request);
    
    // Wait for response (with timeout)
    const response = await this.waitForApproval(request.id, 300000); // 5 minutes
    
    return response.approved;
  }
}

// Usage in agent
async function executeWithApproval(action: Action) {
  const gate = new ApprovalGate();
  
  if (action.requiresApproval) {
    const approved = await gate.approve(action);
    if (!approved) {
      throw new Error('Action rejected by human');
    }
  }
  
  return await action.execute();
}
```

#### Pattern 2: Human Feedback Loop

```typescript
class HumanFeedbackLoop {
  async process(goal: string): Promise<string> {
    let draft = await this.generateDraft(goal);
    let iterations = 0;
    
    while (iterations < 3) {
      // Get human feedback
      const feedback = await this.requestFeedback(draft);
      
      if (feedback.approved) {
        return draft;
      }
      
      // Incorporate feedback
      draft = await this.incorporateFeedback(draft, feedback);
      iterations++;
    }
    
    return draft;
  }
}
```

#### Pattern 3: Escalation

```typescript
class EscalationHandler {
  async handle(task: Task): Promise<any> {
    try {
      // Try automated solution
      return await this.automatedSolve(task);
    } catch (error) {
      // Escalate to human
      return await this.escalateToHuman(task, error);
    }
  }
  
  private async escalateToHuman(task: Task, error: Error): Promise<any> {
    const escalation = {
      task: task,
      error: error.message,
      context: task.context,
      priority: this.calculatePriority(task),
    };
    
    await this.notifyHuman(escalation);
    return await this.waitForHumanResponse(escalation);
  }
}
```

---

## P3.6 Memory and Context Management

### Types of Memory

#### 1. Short-term Memory (Working Memory)

```typescript
class ShortTermMemory {
  private history: Message[] = [];
  private maxLength: number = 20;
  
  add(message: Message): void {
    this.history.push(message);
    if (this.history.length > this.maxLength) {
      this.history.shift();
    }
  }
  
  getContext(): Message[] {
    return this.history;
  }
}
```

#### 2. Long-term Memory (Episodic)

```typescript
class LongTermMemory {
  private storage: VectorDB;
  
  async remember(event: any): Promise<void> {
    // Store with embedding
    const embedding = await embedder.embedQuery(JSON.stringify(event));
    await this.storage.save({
      event,
      embedding,
      timestamp: new Date(),
    });
  }
  
  async recall(query: string): Promise<any[]> {
    const embedding = await embedder.embedQuery(query);
    const results = await this.storage.similaritySearch(embedding, 10);
    return results.map(r => r.event);
  }
}
```

#### 3. Semantic Memory (Knowledge)

```typescript
class SemanticMemory {
  private knowledge: Map<string, any> = new Map();
  
  async learn(fact: string, value: any): Promise<void> {
    // Store fact
    this.knowledge.set(fact, value);
    
    // Also store in vector DB for retrieval
    const embedding = await embedder.embedQuery(fact);
    await this.vectorStore.save({
      fact,
      value,
      embedding,
    });
  }
  
  async recall(fact: string): Promise<any> {
    // Check exact match
    if (this.knowledge.has(fact)) {
      return this.knowledge.get(fact);
    }
    
    // Check semantic match
    const embedding = await embedder.embedQuery(fact);
    const results = await this.vectorStore.similaritySearch(embedding, 1);
    return results[0]?.value;
  }
}
```

### Memory Management Patterns

#### Sliding Window

```typescript
class SlidingWindowMemory {
  private window: Message[] = [];
  private windowSize: number = 10;
  
  add(message: Message): void {
    this.window.push(message);
    if (this.window.length > this.windowSize) {
      // Remove oldest, but maybe summarize first
      const removed = this.window.shift();
      this.summarize(removed);
    }
  }
}
```

#### Summarization

```typescript
class SummarizationMemory {
  private memory: Message[] = [];
  private summary: string = '';
  
  async add(message: Message): Promise<void> {
    this.memory.push(message);
    
    // Periodically summarize
    if (this.memory.length > 20) {
      this.summary = await this.createSummary();
      // Keep only recent messages
      this.memory = this.memory.slice(-5);
    }
  }
  
  async createSummary(): Promise<string> {
    const context = this.memory.map(m => m.content).join('\n');
    const response = await llm.invoke(
      `Summarize this conversation:\n${context}`
    );
    return response.content;
  }
}
```

---

## P3.7 Error Handling and Recovery

### Error Handling Patterns

#### Pattern 1: Retry with Backoff

```typescript
class RetryWithBackoff {
  async execute<T>(
    fn: () => Promise<T>,
    maxRetries: number = 3,
    baseDelay: number = 1000
  ): Promise<T> {
    let lastError: Error;
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await fn();
      } catch (error) {
        lastError = error;
        
        if (attempt === maxRetries) break;
        
        const delay = baseDelay * Math.pow(2, attempt);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    throw lastError!;
  }
}
```

#### Pattern 2: Fallback Chain

```typescript
class FallbackChain {
  async execute<T>(
    primary: () => Promise<T>,
    fallbacks: Array<() => Promise<T>>
  ): Promise<T> {
    try {
      return await primary();
    } catch (error) {
      for (const fallback of fallbacks) {
        try {
          return await fallback();
        } catch (fallbackError) {
          // Continue to next fallback
        }
      }
      throw new Error('All fallbacks failed');
    }
  }
}
```

#### Pattern 3: Graceful Degradation

```typescript
class GracefulDegradation {
  async execute(goal: string): Promise<string> {
    try {
      // Full agent execution
      return await this.fullAgent(goal);
    } catch (error) {
      // Simplify: remove reranking
      try {
        return await this.simpleRAG(goal);
      } catch (error) {
        // Ultra-simple: keyword search
        try {
          return await this.keywordSearch(goal);
        } catch (error) {
          // Ultimate fallback
          return "I couldn't process your request. Please try again.";
        }
      }
    }
  }
}
```

---

## P3.8 Performance Optimization

### Optimization Patterns

#### Pattern 1: Parallel Execution

```typescript
class ParallelExecutor {
  async execute(tasks: Array<() => Promise<any>>): Promise<any[]> {
    return await Promise.all(tasks.map(task => task()));
  }
}

// Example: Search multiple sources in parallel
async function parallelSearch(query: string) {
  const tasks = [
    () => vectorSearch(query),
    () => lexicalSearch(query),
    () => webSearch(query),
  ];
  
  const results = await new ParallelExecutor().execute(tasks);
  return mergeResults(results);
}
```

#### Pattern 2: Batching

```typescript
class Batcher {
  async process<T, R>(
    items: T[],
    processor: (batch: T[]) => Promise<R[]>,
    batchSize: number = 10
  ): Promise<R[]> {
    const results: R[] = [];
    
    for (let i = 0; i < items.length; i += batchSize) {
      const batch = items.slice(i, i + batchSize);
      const batchResults = await processor(batch);
      results.push(...batchResults);
    }
    
    return results;
  }
}
```

#### Pattern 3: Caching

```typescript
class CacheManager {
  private cache = new Map<string, any>();
  private ttl = 3600000; // 1 hour
  
  get(key: string): any | null {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() - item.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }
  
  set(key: string, value: any): void {
    this.cache.set(key, {
      value,
      timestamp: Date.now(),
    });
  }
}
```

---

## P3.9 Evaluation and Monitoring

### Agent Metrics

```typescript
class AgentMetrics {
  private metrics: {
    successRate: number;
    averageSteps: number;
    averageTime: number;
    toolUsage: Map<string, number>;
    errorRate: number;
  };
  
  record(execution: AgentExecution): void {
    // Update metrics
    this.metrics.successRate = this.calculateSuccessRate(execution);
    this.metrics.averageSteps = this.calculateAverageSteps(execution);
    this.metrics.averageTime = this.calculateAverageTime(execution);
    this.metrics.toolUsage = this.updateToolUsage(execution);
    this.metrics.errorRate = this.calculateErrorRate(execution);
  }
}
```

### Agent Logging

```typescript
class AgentLogger {
  logStep(step: {
    timestamp: Date;
    thought: string;
    action: string;
    observation: string;
    state: any;
  }): void {
    console.log({
      level: 'info',
      message: 'Agent step',
      step,
    });
  }
  
  logError(error: Error, context: any): void {
    console.log({
      level: 'error',
      message: 'Agent error',
      error: {
        message: error.message,
        stack: error.stack,
      },
      context,
    });
  }
}
```

---

## P3.10 Best Practices Checklist

### Agent Design
- [ ] Clear goal definition
- [ ] Appropriate tool selection
- [ ] Proper error handling
- [ ] Graceful degradation
- [ ] Human oversight mechanisms

### State Management
- [ ] Clear state definitions
- [ ] Valid state transitions
- [ ] Persistence support
- [ ] Debuggability
- [ ] Recovery from failures

### Tool Design
- [ ] Clear descriptions
- [ ] Type-safe parameters
- [ ] Error handling
- [ ] Timeout support
- [ ] Rate limiting

### Memory
- [ ] Appropriate memory type
- [ ] Memory limits
- [ ] Summarization strategy
- [ ] Retrieval strategy
- [ ] Context management

### Evaluation
- [ ] Success rate tracking
- [ ] Step count monitoring
- [ ] Time tracking
- [ ] Tool usage analysis
- [ ] Error rate monitoring

---

## P3.11 Quick Reference

### Agent Types

```typescript
const AgentTypes = {
  REACT: 'ReAct',           // Reasoning + Acting
  PLAN_EXECUTE: 'PlanExecute', // Plan first, then execute
  HIERARCHICAL: 'Hierarchical', // Manager + Workers
  REFLECTION: 'Reflection', // Self-critique
  MULTI_AGENT: 'MultiAgent', // Multiple agents collaborating
};
```

### Common Tools

```typescript
const CommonTools = {
  SEARCH: 'search',
  CALCULATE: 'calculate',
  CODE: 'code',
  WEB: 'web',
  DATABASE: 'database',
  FILE: 'file',
  EMAIL: 'email',
  HUMAN: 'human',
};
```

### State Patterns

```typescript
const StatePatterns = {
  IDLE: 'idle',
  PLANNING: 'planning',
  EXECUTING: 'executing',
  EVALUATING: 'evaluating',
  REFLECTING: 'reflecting',
  COMPLETED: 'completed',
  ERROR: 'error',
  PAUSED: 'paused',
};
```

---

**[PRIMER 3 — COMPLETE]**
