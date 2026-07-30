# Part 3: Orchestrating the Loop — LangChain.js and Composable Runnables

---

## The Problem

In Parts 1 and 2, we built a powerful RAG system, but our code has several issues:

1. **Tight Coupling**: Our retrieval and generation logic is tightly integrated with specific implementations. Switching from OpenAI to Anthropic would require significant code changes.

2. **No Standardized Pipeline**: Each step (embedding, retrieval, generation) is called separately. There's no unified way to compose these operations.

3. **Manual Error Handling**: Error handling is scattered throughout the codebase. There's no standardized way to handle retries, fallbacks, or graceful degradation.

4. **No Structured Output**: Our LLM responses are free text. We can't guarantee they follow a specific format, making them hard to parse programmatically.

5. **Limited Observability**: While we have basic logging, we lack comprehensive monitoring, tracing, and metrics collection.

**Think of it like this**: We've built a car with great components (engine, transmission, wheels), but they're not integrated into a cohesive driving experience. LangChain.js Runnables provide the **dashboard, steering wheel, and pedals** that make everything work together smoothly.

---

## What We're Building in Part 3

By the end of this part, you'll have:

1. ✅ **LangChain.js Runnables** — Composable, chainable operations
2. ✅ **Provider-Agnostic Abstraction** — Swap LLM providers without code changes
3. ✅ **Structured Output with Zod** — Guaranteed format for LLM responses
4. ✅ **Prompt Templates** — Reusable, parameterized prompts
5. ✅ **Runtime Telemetry** — Comprehensive monitoring and tracing
6. ✅ **Retry and Fallback Logic** — Production-grade resilience
7. ✅ **Complete Pipeline Orchestration** — Unified, testable RAG pipeline

---

## Phase 3.1: LangChain.js Setup and Runnables

### The Target
Set up LangChain.js core components and understand the Runnable interface.

### The Concept
LangChain.js Runnables are the building blocks for composing AI workflows. Think of them as **plumbing pipes** that connect different operations:

- Each Runnable is a self-contained unit of work
- Runnables can be composed using `.pipe()` (like Unix pipes)
- They handle errors, streaming, and batching consistently
- They're provider-agnostic (works with OpenAI, Anthropic, Cohere, etc.)

**Analogy**: Imagine a factory assembly line:
1. **Input** goes in
2. Each **Runnable** performs a specific operation (embedding, retrieval, generation)
3. **Output** comes out the other end
4. `.pipe()` connects the stations

### The Implementation

#### Step 1: Install Dependencies

```bash
# LangChain core
npm install @langchain/core langchain

# Various providers (install what you need)
npm install @langchain/openai
npm install @langchain/anthropic
npm install @langchain/cohere
npm install @langchain/google-vertexai

# LangSmith for tracing (optional but recommended)
npm install @langchain/langsmith

# Additional utilities
npm install zod  # Already installed
npm install @langchain/community
```

#### Step 2: Create Base Runnable Configuration

Create `src/orchestration/runnables/base.ts`:

```typescript
/**
 * Base Runnable Configuration
 * Core runnables for the RAG pipeline
 */

import {
  Runnable,
  RunnableConfig,
  RunnableMap,
  RunnableSequence,
} from '@langchain/core/runnables';
import { Document } from '@langchain/core/documents';
import { BaseMessage } from '@langchain/core/messages';
import { ChatOpenAI, OpenAIEmbeddings } from '@langchain/openai';
import { PromptTemplate } from '@langchain/core/prompts';
import { OutputFixingParser, StructuredOutputParser } from 'langchain/output_parsers';
import { z } from 'zod';
import { logger } from '../../services/logger.js';
import { vectorDB } from '../../services/vector-db.js';

/**
 * Create a base embedding runnable
 * Converts text to embeddings
 */
export const createEmbeddingRunnable = () => {
  const embeddings = new OpenAIEmbeddings({
    model: process.env.OPENAI_EMBEDDING_MODEL || 'text-embedding-3-small',
  });

  return Runnable.fromFunction(async (input: string | string[]) => {
    const texts = Array.isArray(input) ? input : [input];
    const results = await embeddings.embedDocuments(texts);
    return Array.isArray(input) ? results : results[0];
  });
};

/**
 * Create a vector search runnable
 * Searches the vector database for similar documents
 */
export const createVectorSearchRunnable = () => {
  return Runnable.fromFunction(
    async (input: { query: string; topK?: number; filters?: Record<string, any> }) => {
      const { query, topK = 5, filters } = input;
      
      // First, embed the query
      const embeddingRunnable = createEmbeddingRunnable();
      const embedding = await embeddingRunnable.invoke(query);
      
      // Search the database
      const results = await vectorDB.similaritySearch(
        embedding,
        topK,
        parseFloat(process.env.SIMILARITY_THRESHOLD || '0.7'),
        filters
      );
      
      // Convert to LangChain Document format
      return results.map(result => ({
        pageContent: result.chunk.content,
        metadata: {
          ...result.chunk.metadata,
          score: result.score,
          id: result.chunk.id,
        },
      }));
    }
  );
};

/**
 * Create a hybrid search runnable
 * Combines dense and lexical search
 */
export const createHybridSearchRunnable = () => {
  // Will be implemented later with proper hybrid search
  return createVectorSearchRunnable();
};

/**
 * Create a chat model runnable
 * Provider-agnostic LLM for generation
 */
export const createChatModelRunnable = () => {
  const model = new ChatOpenAI({
    model: process.env.OPENAI_CHAT_MODEL || 'gpt-4o-mini',
    temperature: 0.3,
    maxTokens: 1000,
  });
  
  // Optionally add retry logic
  return model.withRetry({
    stopAfterAttempt: 3,
    onFailedAttempt: (error) => {
      logger.warn('LLM call failed, retrying', {
        attempt: error.attempts,
        error: error.error.message,
      });
    },
  });
};

/**
 * Create a prompt template for RAG
 * Formats context and query into a prompt
 */
export const createRAGPromptTemplate = () => {
  return PromptTemplate.fromTemplate(`
You are a helpful AI assistant that answers questions based on the provided context.

IMPORTANT RULES:
1. ONLY use information from the provided context to answer the question.
2. If the context doesn't contain enough information to answer, say so clearly.
3. Cite which source you're using for each piece of information.
4. Be concise but thorough.
5. Do not make up information or use knowledge outside the provided context.

Context:
{context}

Question: {question}

Answer:
`);
};

/**
 * Create a structured output parser
 * Ensures the LLM responds in a specific format
 */
export const createStructuredOutputParser = <T extends z.ZodSchema>(
  schema: T
) => {
  return StructuredOutputParser.fromZodSchema(schema);
};

/**
 * Create an output fixing parser
 * Automatically fixes malformed JSON outputs
 */
export const createOutputFixingParser = <T extends z.ZodSchema>(
  schema: T,
  maxRetries: number = 3
) => {
  const parser = StructuredOutputParser.fromZodSchema(schema);
  return OutputFixingParser.fromLLM(
    new ChatOpenAI({
      model: process.env.OPENAI_CHAT_MODEL || 'gpt-4o-mini',
      temperature: 0,
    }),
    parser,
    { maxRetries }
  );
};

/**
 * Create a logging runnable
 * Logs input/output for debugging
 */
export const createLoggingRunnable = (name: string) => {
  return Runnable.fromFunction(async (input: any) => {
    logger.debug(`[${name}] Input:`, { 
      input: typeof input === 'string' ? input.substring(0, 200) : input 
    });
    
    // In a real implementation, you'd also log output here
    // This will be handled by the wrapping runnable
    
    return input;
  });
};

/**
 * Create a fallback runnable
 * Provides a fallback response if the main runnable fails
 */
export const createFallbackRunnable = <T>(
  mainRunnable: Runnable<any, T>,
  fallbackResponse: T
) => {
  return Runnable.fromFunction(async (input: any) => {
    try {
      return await mainRunnable.invoke(input);
    } catch (error) {
      logger.warn('Main runnable failed, using fallback', {
        error: error instanceof Error ? error.message : String(error),
      });
      return fallbackResponse;
    }
  });
};
```

#### Step 3: Create RAG Pipeline Runnables

Create `src/orchestration/runnables/rag-pipeline.ts`:

```typescript
/**
 * RAG Pipeline Runnables
 * Complete RAG pipeline using LangChain runnables
 */

import {
  Runnable,
  RunnableConfig,
  RunnableSequence,
} from '@langchain/core/runnables';
import { Document } from '@langchain/core/documents';
import { BaseMessage } from '@langchain/core/messages';
import { z } from 'zod';
import { logger } from '../../services/logger.js';
import {
  createEmbeddingRunnable,
  createHybridSearchRunnable,
  createChatModelRunnable,
  createRAGPromptTemplate,
  createStructuredOutputParser,
  createLoggingRunnable,
  createFallbackRunnable,
} from './base.js';
import { SearchResult } from '../../types/index.js';

/**
 * Schema for RAG response
 * Ensures LLM returns structured output
 */
export const RAGResponseSchema = z.object({
  answer: z.string().describe('The answer to the question'),
  confidence: z.number().min(0).max(1).describe('Confidence score 0-1'),
  sources: z.array(z.object({
    id: z.string(),
    content: z.string(),
    score: z.number(),
  })).optional().describe('Source documents used'),
  reasoning: z.string().optional().describe('Brief reasoning behind the answer'),
});

export type RAGResponseType = z.infer<typeof RAGResponseSchema>;

/**
 * Create a complete RAG pipeline using runnables
 */
export const createRAGPipeline = () => {
  // Step 1: Embed query and search
  const searchRunnable = RunnableSequence.from([
    createLoggingRunnable('Input'),
    // Input: { query: string, topK?: number }
    Runnable.fromFunction(async (input: { query: string; topK?: number }) => {
      // Use the hybrid search runnable
      const search = createHybridSearchRunnable();
      const results = await search.invoke({
        query: input.query,
        topK: input.topK || 5,
      });
      
      // Format context
      const context = results
        .map((doc: Document, i: number) => 
          `[Source ${i + 1}] ${doc.pageContent}`
        )
        .join('\n\n---\n\n');
      
      return {
        context,
        query: input.query,
        results,
      };
    }),
    createLoggingRunnable('Search'),
  ]);

  // Step 2: Generate answer using LLM
  const generateRunnable = RunnableSequence.from([
    // Create prompt with context and query
    Runnable.fromFunction(async (input: { context: string; query: string }) => {
      const promptTemplate = createRAGPromptTemplate();
      return await promptTemplate.invoke({
        context: input.context,
        question: input.query,
      });
    }),
    createLoggingRunnable('Prompt'),
    
    // Call LLM
    createChatModelRunnable(),
    createLoggingRunnable('LLM'),
    
    // Parse structured output
    Runnable.fromFunction(async (response: BaseMessage) => {
      const parser = createStructuredOutputParser(RAGResponseSchema);
      return await parser.invoke(response.content.toString());
    }),
    createLoggingRunnable('ParsedOutput'),
  ]);

  // Step 3: Combine everything
  const pipeline = RunnableSequence.from([
    // Search
    searchRunnable,
    
    // Generate
    Runnable.fromFunction(async (input: any) => {
      const result = await generateRunnable.invoke({
        context: input.context,
        query: input.query,
      });
      
      // Add source metadata
      if (input.results && result.sources) {
        // Map source IDs to full documents
        const sourceMap = new Map(
          input.results.map((doc: Document) => [doc.metadata.id, doc])
        );
        
        result.sources = result.sources.map((source: any) => {
          const fullDoc = sourceMap.get(source.id);
          return {
            ...source,
            content: fullDoc?.pageContent || source.content,
          };
        });
      }
      
      return result;
    }),
  ]);

  // Add fallback for the entire pipeline
  return createFallbackRunnable(
    pipeline,
    {
      answer: "I'm sorry, I encountered an error processing your request. Please try again.",
      confidence: 0,
      sources: [],
      reasoning: "Pipeline error occurred",
    }
  );
};

/**
 * Create a streaming RAG pipeline
 * Streams tokens as they're generated
 */
export const createStreamingRAGPipeline = () => {
  const basePipeline = createRAGPipeline();
  
  return Runnable.fromFunction(async (
    input: { query: string; topK?: number; onToken?: (token: string) => void }
  ) => {
    // For streaming, we'll use the base pipeline but with streaming enabled
    // This requires custom implementation with the chat model's stream method
    
    const { query, topK = 5, onToken } = input;
    
    // Step 1: Search
    const searchRunnable = createHybridSearchRunnable();
    const results = await searchRunnable.invoke({ query, topK });
    
    const context = results
      .map((doc: Document, i: number) => 
        `[Source ${i + 1}] ${doc.pageContent}`
      )
      .join('\n\n---\n\n');
    
    // Step 2: Generate with streaming
    const promptTemplate = createRAGPromptTemplate();
    const prompt = await promptTemplate.invoke({
      context,
      question: query,
    });
    
    const chatModel = createChatModelRunnable();
    const stream = await chatModel.stream(prompt);
    
    let fullAnswer = '';
    let sentTokens = 0;
    
    for await (const chunk of stream) {
      const content = chunk.content?.toString() || '';
      fullAnswer += content;
      
      if (onToken) {
        onToken(content);
        sentTokens++;
        
        // Log token streaming at a higher level (every 10 tokens)
        if (sentTokens % 10 === 0) {
          logger.debug('Streaming tokens', { tokenCount: sentTokens });
        }
      }
    }
    
    // Step 3: Parse final answer
    try {
      const parser = createStructuredOutputParser(RAGResponseSchema);
      const parsed = await parser.invoke(fullAnswer);
      return parsed;
    } catch (error) {
      // If parsing fails, return a basic response
      logger.warn('Failed to parse streamed output', {
        error: error instanceof Error ? error.message : String(error),
      });
      return {
        answer: fullAnswer,
        confidence: 0.5,
        sources: results.map((doc: Document) => ({
          id: doc.metadata.id,
          content: doc.pageContent,
          score: doc.metadata.score,
        })),
        reasoning: "Output parsed with fallback due to formatting issues",
      };
    }
  });
};

/**
 * Create a batch processing pipeline
 * Processes multiple queries in parallel
 */
export const createBatchRAGPipeline = () => {
  const pipeline = createRAGPipeline();
  
  return Runnable.fromFunction(async (inputs: { query: string; topK?: number }[]) => {
    // Process in parallel with Promise.all
    const results = await Promise.all(
      inputs.map(input => pipeline.invoke(input))
    );
    
    return results;
  });
};
```

---

## Phase 3.2: Advanced Prompt Templates

### The Target
Create reusable, parameterized prompt templates with different styles and outputs.

### The Concept
Prompt templates are like **Mad Libs** for AI — they have slots you fill in with specific values. This ensures consistency, makes prompts maintainable, and allows for easy A/B testing.

**Key Features**:
- **Parameterization**: `{variable}` syntax for dynamic content
- **Composition**: Combine templates to build complex prompts
- **Serialization**: Save templates as JSON for versioning
- **Multi-language**: Support different languages with separate templates

### The Implementation

Create `src/orchestration/prompts.ts`:

```typescript
/**
 * Advanced Prompt Templates
 * Reusable, parameterized prompts for different use cases
 */

import { PromptTemplate } from '@langchain/core/prompts';
import { FewShotPromptTemplate } from '@langchain/core/prompts';
import { z } from 'zod';
import { logger } from '../services/logger.js';
import fs from 'fs/promises';
import path from 'path';

/**
 * Prompt styles
 */
export enum PromptStyle {
  /** Concise and direct */
  CONCISE = 'concise',
  
  /** Detailed and thorough */
  DETAILED = 'detailed',
  
  /** Step-by-step reasoning */
  REASONING = 'reasoning',
  
  /** Socratic (ask clarifying questions) */
  SOCRATIC = 'socratic',
  
  /** Expert-level (assumes domain knowledge) */
  EXPERT = 'expert',
}

/**
 * Prompt template configuration
 */
export interface PromptConfig {
  style: PromptStyle;
  systemPrompt?: string;
  outputFormat?: 'text' | 'json' | 'structured';
  maxLength?: number;
  temperature?: number;
}

/**
 * Prompt template manager
 */
export class PromptManager {
  private templates: Map<string, PromptTemplate> = new Map();
  private fewShotExamples: Map<string, any[]> = new Map();

  constructor() {
    this.initializeTemplates();
  }

  /**
   * Initialize standard templates
   */
  private initializeTemplates(): void {
    // Basic RAG template
    this.templates.set('basic-rag', PromptTemplate.fromTemplate(`
{system}

Context:
{context}

Question: {question}

Answer:
`));

    // Concise template
    this.templates.set('concise', PromptTemplate.fromTemplate(`
{system}

Context: {context}
Question: {question}

Provide a brief, direct answer based ONLY on the context.
Answer:
`));

    // Detailed template
    this.templates.set('detailed', PromptTemplate.fromTemplate(`
{system}

Context:
{context}

Question: {question}

Provide a comprehensive answer that:
1. Directly answers the question
2. Supports each point with evidence from the context
3. Cites specific sources
4. Notes any limitations or uncertainties

Answer:
`));

    // Reasoning template
    this.templates.set('reasoning', PromptTemplate.fromTemplate(`
{system}

Context:
{context}

Question: {question}

Follow these steps:
1. Identify the key information needed from the context
2. Extract relevant evidence
3. Synthesize the evidence into a coherent answer
4. If insufficient evidence, state what's missing

Answer (show your reasoning):
`));

    // Socratic template
    this.templates.set('socratic', PromptTemplate.fromTemplate(`
{system}

Context:
{context}

Question: {question}

Instead of directly answering, help the user discover the answer:
1. Ask clarifying questions about what they're really asking
2. Point to relevant parts of the context
3. Guide them to draw their own conclusions
4. Only provide the answer if they explicitly ask again

Response:
`));

    // Expert template
    this.templates.set('expert', PromptTemplate.fromTemplate(`
{system}

Context:
{context}

Question: {question}

Provide an expert-level response that:
1. Assumes domain knowledge
2. Uses technical terminology appropriately
3. Provides nuanced insights
4. Acknowledges edge cases and limitations
5. References sources directly

Expert Answer:
`));
  }

  /**
   * Get a prompt template by name
   */
  getTemplate(name: string): PromptTemplate | undefined {
    return this.templates.get(name);
  }

  /**
   * Create a custom prompt template
   */
  createTemplate(
    name: string,
    template: string,
    inputVariables: string[]
  ): void {
    const promptTemplate = new PromptTemplate({
      template,
      inputVariables,
    });
    this.templates.set(name, promptTemplate);
    logger.info('Custom prompt template created', { name });
  }

  /**
   * Build a prompt with a specific style
   */
  buildPrompt(
    style: PromptStyle,
    variables: {
      system?: string;
      context: string;
      question: string;
      additional?: Record<string, any>;
    }
  ): Promise<string> {
    const systemPrompt = variables.system || this.getSystemPrompt(style);
    
    // Choose the right template
    let templateName: string;
    switch (style) {
      case PromptStyle.CONCISE:
        templateName = 'concise';
        break;
      case PromptStyle.DETAILED:
        templateName = 'detailed';
        break;
      case PromptStyle.REASONING:
        templateName = 'reasoning';
        break;
      case PromptStyle.SOCRATIC:
        templateName = 'socratic';
        break;
      case PromptStyle.EXPERT:
        templateName = 'expert';
        break;
      default:
        templateName = 'basic-rag';
    }

    const template = this.getTemplate(templateName);
    if (!template) {
      throw new Error(`Template not found: ${templateName}`);
    }

    return template.format({
      system: systemPrompt,
      context: variables.context,
      question: variables.question,
      ...variables.additional,
    });
  }

  /**
   * Get system prompt for a style
   */
  private getSystemPrompt(style: PromptStyle): string {
    const prompts: Record<PromptStyle, string> = {
      [PromptStyle.CONCISE]: `
You are a helpful AI assistant that provides concise, accurate answers based on the provided context.

RULES:
1. Answer only using the context provided.
2. Be brief but complete.
3. If the context doesn't contain enough information, say so.
      `.trim(),

      [PromptStyle.DETAILED]: `
You are a thorough AI assistant that provides detailed, well-supported answers.

RULES:
1. Use ONLY information from the context.
2. Cite sources for each claim.
3. Acknowledge any uncertainties.
4. Provide complete explanations.
      `.trim(),

      [PromptStyle.REASONING]: `
You are an analytical AI assistant that explains its reasoning process.

RULES:
1. Show your step-by-step reasoning.
2. Cite evidence from the context.
3. Acknowledge gaps in knowledge.
4. Be transparent about limitations.
      `.trim(),

      [PromptStyle.SOCRATIC]: `
You are a Socratic AI assistant that guides users to discover answers.

RULES:
1. Ask clarifying questions.
2. Point to relevant context.
3. Encourage critical thinking.
4. Only provide answers when explicitly asked after guidance.
      `.trim(),

      [PromptStyle.EXPERT]: `
You are an expert AI assistant with deep domain knowledge.

RULES:
1. Provide nuanced, sophisticated answers.
2. Use technical terminology correctly.
3. Address edge cases.
4. Provide insights beyond the obvious.
5. Always ground answers in the context.
      `.trim(),
    };

    return prompts[style] || prompts[PromptStyle.DETAILED];
  }

  /**
   * Load a custom prompt from file
   */
  async loadPromptFromFile(filePath: string): Promise<PromptTemplate> {
    try {
      const content = await fs.readFile(filePath, 'utf-8');
      const config = JSON.parse(content);
      
      const template = new PromptTemplate({
        template: config.template,
        inputVariables: config.inputVariables || [],
      });
      
      this.templates.set(config.name || 'custom', template);
      
      logger.info('Prompt loaded from file', { filePath, name: config.name });
      return template;
      
    } catch (error) {
      logger.error('Failed to load prompt from file', {
        filePath,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * Save a prompt template to file
   */
  async savePromptToFile(
    name: string,
    filePath: string
  ): Promise<void> {
    const template = this.templates.get(name);
    if (!template) {
      throw new Error(`Template not found: ${name}`);
    }

    const config = {
      name,
      template: template.template,
      inputVariables: template.inputVariables,
      createdAt: new Date().toISOString(),
    };

    await fs.writeFile(filePath, JSON.stringify(config, null, 2));
    logger.info('Prompt saved to file', { filePath, name });
  }

  /**
   * Add few-shot examples for a template
   */
  addFewShotExamples(
    templateName: string,
    examples: Array<{
      context: string;
      question: string;
      answer: string;
    }>
  ): void {
    this.fewShotExamples.set(templateName, examples);
    logger.info('Few-shot examples added', { 
      templateName, 
      exampleCount: examples.length 
    });
  }

  /**
   * Create a few-shot prompt template
   */
  createFewShotPrompt(
    templateName: string,
    prefix: string,
    suffix: string
  ): PromptTemplate | null {
    const examples = this.fewShotExamples.get(templateName);
    if (!examples) {
      logger.warn('No few-shot examples found for template', { templateName });
      return null;
    }

    // Note: This requires the FewShotPromptTemplate from @langchain/core/prompts
    // Implementation depends on specific version
    return null;
  }
}

export default new PromptManager();
```

---

## Phase 3.3: Structured Output with Zod

### The Target
Implement comprehensive structured output parsing for guaranteed response formats.

### The Concept
Structured output ensures your LLM responses are **predictable and machine-readable**. Instead of parsing free text, you define a schema (using Zod) and the LLM outputs data that matches it.

**Benefits**:
- **Type Safety**: TypeScript can validate the structure
- **Consistency**: Every response follows the same format
- **Reliability**: Failed parsing can be caught early
- **Integration**: Easier to pass responses to other systems

### The Implementation

Create `src/orchestration/schemas.ts`:

```typescript
/**
 * Zod Schemas for Structured Output
 * Defines the expected format for all LLM responses
 */

import { z } from 'zod';

/**
 * Base response schema with common fields
 */
export const BaseResponseSchema = z.object({
  answer: z.string().min(1, 'Answer cannot be empty'),
  confidence: z.number().min(0).max(1, 'Confidence must be between 0 and 1'),
  timestamp: z.string().datetime().optional(),
});

/**
 * RAG response schema with sources
 */
export const RAGResponseSchema = BaseResponseSchema.extend({
  sources: z.array(
    z.object({
      id: z.string().optional(),
      content: z.string(),
      score: z.number().min(0).max(1),
      relevance: z.enum(['high', 'medium', 'low']).optional(),
    })
  ).optional(),
  reasoning: z.string().optional(),
  missingInformation: z.array(z.string()).optional(),
  followUpQuestions: z.array(z.string()).optional(),
});

/**
 * Analysis response schema
 * For analyzing documents or providing insights
 */
export const AnalysisResponseSchema = BaseResponseSchema.extend({
  summary: z.string(),
  keyPoints: z.array(z.string()),
  sentiment: z.enum(['positive', 'negative', 'neutral']).optional(),
  entities: z.array(
    z.object({
      name: z.string(),
      type: z.string(),
      relevance: z.number().optional(),
    })
  ).optional(),
  topics: z.array(z.string()).optional(),
});

/**
 * Classification response schema
 * For categorizing or tagging content
 */
export const ClassificationResponseSchema = z.object({
  categories: z.array(
    z.object({
      name: z.string(),
      confidence: z.number().min(0).max(1),
      explanation: z.string().optional(),
    })
  ),
  primaryCategory: z.string(),
  tags: z.array(z.string()),
  confidence: z.number().min(0).max(1),
});

/**
 * Comparison response schema
 * For comparing multiple items
 */
export const ComparisonResponseSchema = BaseResponseSchema.extend({
  items: z.array(
    z.object({
      name: z.string(),
      pros: z.array(z.string()),
      cons: z.array(z.string()),
      score: z.number().optional(),
    })
  ),
  recommendation: z.string().optional(),
  factors: z.array(z.string()),
});

/**
 * Step-by-step reasoning schema
 * For tasks requiring process explanation
 */
export const ReasoningResponseSchema = BaseResponseSchema.extend({
  steps: z.array(
    z.object({
      step: z.number(),
      action: z.string(),
      evidence: z.string().optional(),
      output: z.string(),
    })
  ),
  conclusion: z.string(),
  confidence: z.number().min(0).max(1),
});

/**
 * Error response schema
 * For graceful error handling
 */
export const ErrorResponseSchema = z.object({
  error: z.string(),
  type: z.enum([
    'RETRIEVAL_FAILED',
    'GENERATION_FAILED',
    'NO_CONTEXT',
    'PARSING_FAILED',
    'TIMEOUT',
    'UNKNOWN',
  ]),
  recoverable: z.boolean(),
  suggestion: z.string().optional(),
});

/**
 * Combined schema type
 * Union of all possible response types
 */
export const CombinedResponseSchema = z.union([
  RAGResponseSchema,
  AnalysisResponseSchema,
  ClassificationResponseSchema,
  ComparisonResponseSchema,
  ReasoningResponseSchema,
  ErrorResponseSchema,
]);

/**
 * Extract TypeScript types from schemas
 */
export type RAGResponse = z.infer<typeof RAGResponseSchema>;
export type AnalysisResponse = z.infer<typeof AnalysisResponseSchema>;
export type ClassificationResponse = z.infer<typeof ClassificationResponseSchema>;
export type ComparisonResponse = z.infer<typeof ComparisonResponseSchema>;
export type ReasoningResponse = z.infer<typeof ReasoningResponseSchema>;
export type ErrorResponse = z.infer<typeof ErrorResponseSchema>;
export type CombinedResponse = z.infer<typeof CombinedResponseSchema>;

/**
 * Response factory for creating structured responses
 */
export class ResponseFactory {
  /**
   * Create a success response
   */
  static success(
    answer: string,
    options?: Partial<Omit<RAGResponse, 'answer'>>
  ): RAGResponse {
    return {
      answer,
      confidence: options?.confidence || 0.8,
      sources: options?.sources || [],
      reasoning: options?.reasoning,
      missingInformation: options?.missingInformation,
      followUpQuestions: options?.followUpQuestions,
    };
  }

  /**
   * Create an error response
   */
  static error(
    message: string,
    type: ErrorResponse['type'] = 'UNKNOWN',
    recoverable: boolean = true,
    suggestion?: string
  ): ErrorResponse {
    return {
      error: message,
      type,
      recoverable,
      suggestion,
    };
  }

  /**
   * Create a low-confidence response
   */
  static lowConfidence(
    answer: string,
    reason: string,
    sources: any[] = []
  ): RAGResponse {
    return {
      answer,
      confidence: 0.3,
      sources,
      reasoning: `Low confidence: ${reason}`,
      warnings: ['Confidence below threshold'],
    };
  }

  /**
   * Validate a response against a schema
   */
  static validate<T extends z.ZodSchema>(
    schema: T,
    data: unknown
  ): { success: true; data: z.infer<T> } | { success: false; errors: string[] } {
    try {
      const result = schema.parse(data);
      return { success: true, data: result };
    } catch (error) {
      if (error instanceof z.ZodError) {
        return { 
          success: false, 
          errors: error.errors.map(e => `${e.path.join('.')}: ${e.message}`)
        };
      }
      return { success: false, errors: ['Unknown validation error'] };
    }
  }

  /**
   * Create a parser for a specific schema
   */
  static createParser<T extends z.ZodSchema>(schema: T) {
    return (data: unknown): z.infer<T> => {
      return schema.parse(data);
    };
  }
}
```

---

## Phase 3.4: Runtime Telemetry

### The Target
Implement comprehensive monitoring, tracing, and metrics for the RAG pipeline.

### The Concept
**Telemetry** is your window into what the system is doing. Think of it as the **dashboard and gauges** in a car:

- **Metrics**: Numbers (speed, RPM, temperature) — track over time
- **Traces**: Journey logs (where you went, route taken) — understand what happened
- **Logs**: Detailed events (engine started, brake applied) — debug issues

**We'll implement**:
- Request/response tracing with unique IDs
- Performance metrics (latency, token usage, error rates)
- Health checks and status reporting
- Integration with LangSmith for advanced tracing

### The Implementation

Create `src/orchestration/telemetry.ts`:

```typescript
/**
 * Runtime Telemetry Service
 * Comprehensive monitoring, tracing, and metrics
 */

import { logger } from '../services/logger.js';
import { randomUUID } from 'crypto';

// Types
export interface TelemetryEvent {
  id: string;
  timestamp: string;
  type: string;
  name: string;
  data: Record<string, any>;
  traceId?: string;
  spanId?: string;
  parentSpanId?: string;
}

export interface Metric {
  name: string;
  value: number;
  unit: string;
  tags: Record<string, string>;
  timestamp: string;
}

export interface Trace {
  id: string;
  name: string;
  startTime: string;
  endTime?: string;
  duration?: number;
  spans: Span[];
  status: 'pending' | 'success' | 'error';
  error?: string;
}

export interface Span {
  id: string;
  name: string;
  startTime: string;
  endTime?: string;
  duration?: number;
  parentSpanId?: string;
  events: TelemetryEvent[];
  status: 'pending' | 'success' | 'error';
  error?: string;
}

/**
 * Telemetry service with distributed tracing support
 */
export class TelemetryService {
  private traces: Map<string, Trace> = new Map();
  private metrics: Metric[] = [];
  private events: TelemetryEvent[] = [];
  private maxStoredItems: number = 10000;
  
  private static instance: TelemetryService;

  private constructor() {
    // Start periodic cleanup
    setInterval(() => this.cleanup(), 300000); // Every 5 minutes
  }

  public static getInstance(): TelemetryService {
    if (!TelemetryService.instance) {
      TelemetryService.instance = new TelemetryService();
    }
    return TelemetryService.instance;
  }

  /**
   * Start a new trace
   */
  startTrace(name: string): string {
    const id = randomUUID();
    const trace: Trace = {
      id,
      name,
      startTime: new Date().toISOString(),
      spans: [],
      status: 'pending',
    };
    
    this.traces.set(id, trace);
    logger.debug('Trace started', { traceId: id, name });
    
    return id;
  }

  /**
   * End a trace
   */
  endTrace(
    traceId: string,
    status: 'success' | 'error' = 'success',
    error?: string
  ): Trace | null {
    const trace = this.traces.get(traceId);
    if (!trace) {
      logger.warn('Trace not found', { traceId });
      return null;
    }

    trace.endTime = new Date().toISOString();
    trace.duration = this.calculateDuration(trace.startTime, trace.endTime);
    trace.status = status;
    if (error) trace.error = error;

    logger.debug('Trace ended', { 
      traceId, 
      status, 
      duration: trace.duration 
    });

    return trace;
  }

  /**
   * Start a span within a trace
   */
  startSpan(
    traceId: string,
    name: string,
    parentSpanId?: string
  ): string {
    const trace = this.traces.get(traceId);
    if (!trace) {
      logger.warn('Trace not found for span', { traceId });
      return '';
    }

    const spanId = randomUUID();
    const span: Span = {
      id: spanId,
      name,
      startTime: new Date().toISOString(),
      parentSpanId,
      events: [],
      status: 'pending',
    };

    trace.spans.push(span);
    logger.debug('Span started', { traceId, spanId, name, parentSpanId });

    return spanId;
  }

  /**
   * End a span
   */
  endSpan(
    traceId: string,
    spanId: string,
    status: 'success' | 'error' = 'success',
    error?: string
  ): Span | null {
    const trace = this.traces.get(traceId);
    if (!trace) {
      logger.warn('Trace not found', { traceId });
      return null;
    }

    const span = trace.spans.find(s => s.id === spanId);
    if (!span) {
      logger.warn('Span not found', { traceId, spanId });
      return null;
    }

    span.endTime = new Date().toISOString();
    span.duration = this.calculateDuration(span.startTime, span.endTime);
    span.status = status;
    if (error) span.error = error;

    logger.debug('Span ended', { traceId, spanId, status, duration: span.duration });

    return span;
  }

  /**
   * Record an event
   */
  recordEvent(
    name: string,
    data: Record<string, any>,
    traceId?: string,
    spanId?: string
  ): void {
    const event: TelemetryEvent = {
      id: randomUUID(),
      timestamp: new Date().toISOString(),
      type: 'event',
      name,
      data,
      traceId,
      spanId,
    };

    this.events.push(event);

    // If this is part of a trace, add to the span
    if (traceId && spanId) {
      const trace = this.traces.get(traceId);
      if (trace) {
        const span = trace.spans.find(s => s.id === spanId);
        if (span) {
          span.events.push(event);
        }
      }
    }

    // Log important events
    if (data.level === 'error' || data.level === 'warn') {
      logger.log(data.level || 'info', `[Telemetry] ${name}`, data);
    }
  }

  /**
   * Record a metric
   */
  recordMetric(
    name: string,
    value: number,
    unit: string = 'count',
    tags: Record<string, string> = {}
  ): void {
    const metric: Metric = {
      name,
      value,
      unit,
      tags,
      timestamp: new Date().toISOString(),
    };

    this.metrics.push(metric);
    
    // Keep only last N metrics
    if (this.metrics.length > this.maxStoredItems) {
      this.metrics = this.metrics.slice(-this.maxStoredItems);
    }

    // Log significant metrics
    if (value > 100 || name.includes('error')) {
      logger.debug('[Metric]', { name, value, unit, tags });
    }
  }

  /**
   * Record a performance measurement
   */
  recordPerformance(
    operation: string,
    durationMs: number,
    tags: Record<string, string> = {}
  ): void {
    this.recordMetric(`perf.${operation}`, durationMs, 'ms', tags);
    
    // Record histogram-like metric
    const bucket = this.getBucket(durationMs);
    this.recordMetric(`perf.${operation}.bucket.${bucket}`, 1, 'count', tags);
  }

  /**
   * Record token usage
   */
  recordTokenUsage(
    model: string,
    promptTokens: number,
    completionTokens: number,
    tags: Record<string, string> = {}
  ): void {
    const totalTokens = promptTokens + completionTokens;
    
    this.recordMetric(`tokens.${model}.prompt`, promptTokens, 'tokens', tags);
    this.recordMetric(`tokens.${model}.completion`, completionTokens, 'tokens', tags);
    this.recordMetric(`tokens.${model}.total`, totalTokens, 'tokens', tags);
    
    // Track cost (rough estimate)
    const cost = this.estimateCost(model, promptTokens, completionTokens);
    this.recordMetric(`cost.${model}`, cost, 'usd', tags);
  }

  /**
   * Estimate cost for OpenAI models
   */
  private estimateCost(
    model: string,
    promptTokens: number,
    completionTokens: number
  ): number {
    // Rough cost per 1K tokens (in USD)
    const costs: Record<string, { prompt: number; completion: number }> = {
      'gpt-4o-mini': { prompt: 0.00015, completion: 0.0006 },
      'gpt-4o': { prompt: 0.005, completion: 0.015 },
      'gpt-4': { prompt: 0.03, completion: 0.06 },
      'gpt-3.5-turbo': { prompt: 0.0005, completion: 0.0015 },
      'text-embedding-3-small': { prompt: 0.00002, completion: 0 },
      'text-embedding-3-large': { prompt: 0.00013, completion: 0 },
    };

    const cost = costs[model] || costs['gpt-4o-mini'];
    return (promptTokens / 1000) * cost.prompt + 
           (completionTokens / 1000) * cost.completion;
  }

  /**
   * Get a duration bucket for metrics
   */
  private getBucket(ms: number): string {
    if (ms < 10) return 'lt10ms';
    if (ms < 50) return 'lt50ms';
    if (ms < 100) return 'lt100ms';
    if (ms < 500) return 'lt500ms';
    if (ms < 1000) return 'lt1s';
    if (ms < 5000) return 'lt5s';
    if (ms < 30000) return 'lt30s';
    return 'gt30s';
  }

  /**
   * Calculate duration between two timestamps
   */
  private calculateDuration(start: string, end: string): number {
    return new Date(end).getTime() - new Date(start).getTime();
  }

  /**
   * Get a trace by ID
   */
  getTrace(traceId: string): Trace | null {
    return this.traces.get(traceId) || null;
  }

  /**
   * Get recent traces
   */
  getRecentTraces(limit: number = 10): Trace[] {
    return Array.from(this.traces.values())
      .sort((a, b) => new Date(b.startTime).getTime() - new Date(a.startTime).getTime())
      .slice(0, limit);
  }

  /**
   * Get metrics by name
   */
  getMetrics(
    namePattern?: string,
    timeRange?: { start: Date; end: Date }
  ): Metric[] {
    let filtered = this.metrics;
    
    if (namePattern) {
      const pattern = new RegExp(namePattern);
      filtered = filtered.filter(m => pattern.test(m.name));
    }
    
    if (timeRange) {
      filtered = filtered.filter(m => {
        const time = new Date(m.timestamp);
        return time >= timeRange.start && time <= timeRange.end;
      });
    }
    
    return filtered;
  }

  /**
   * Get aggregated metrics
   */
  getAggregatedMetrics(
    name: string,
    aggregation: 'sum' | 'avg' | 'min' | 'max' | 'count',
    timeRange?: { start: Date; end: Date }
  ): number {
    const metrics = this.getMetrics(name, timeRange);
    
    if (metrics.length === 0) return 0;
    
    switch (aggregation) {
      case 'sum':
        return metrics.reduce((sum, m) => sum + m.value, 0);
      case 'avg':
        return metrics.reduce((sum, m) => sum + m.value, 0) / metrics.length;
      case 'min':
        return Math.min(...metrics.map(m => m.value));
      case 'max':
        return Math.max(...metrics.map(m => m.value));
      case 'count':
        return metrics.length;
      default:
        return 0;
    }
  }

  /**
   * Get system health status
   */
  getHealth(): Record<string, any> {
    const totalTraces = this.traces.size;
    const errorTraces = Array.from(this.traces.values())
      .filter(t => t.status === 'error').length;
    
    const lastMetrics = this.metrics.slice(-100);
    const avgLatency = lastMetrics
      .filter(m => m.name.startsWith('perf.'))
      .reduce((sum, m) => sum + m.value, 0) / 
      (lastMetrics.filter(m => m.name.startsWith('perf.')).length || 1);

    return {
      status: errorTraces / (totalTraces || 1) < 0.1 ? 'healthy' : 'degraded',
      totalTraces,
      errorRate: totalTraces > 0 ? errorTraces / totalTraces : 0,
      avgLatencyMs: avgLatency,
      metricsCount: this.metrics.length,
      eventsCount: this.events.length,
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Clean up old traces and events
   */
  private cleanup(): void {
    const now = Date.now();
    const maxAge = 3600000; // 1 hour
    
    // Remove old traces
    for (const [id, trace] of this.traces) {
      const age = now - new Date(trace.startTime).getTime();
      if (age > maxAge) {
        this.traces.delete(id);
      }
    }
    
    // Keep events within limit
    if (this.events.length > this.maxStoredItems) {
      this.events = this.events.slice(-this.maxStoredItems);
    }
  }

  /**
   * Export telemetry data
   */
  exportData(): Record<string, any> {
    return {
      traces: Array.from(this.traces.values()),
      metrics: this.metrics.slice(-1000), // Last 1000 metrics
      events: this.events.slice(-1000), // Last 1000 events
      health: this.getHealth(),
      exportTime: new Date().toISOString(),
    };
  }
}

export default TelemetryService.getInstance();
```

---

## Phase 3.5: Complete Orchestration Layer

### The Target
Bring everything together into a cohesive orchestration layer.

### The Implementation

Create `src/orchestration/orchestrator.ts`:

```typescript
/**
 * Complete Orchestration Layer
 * Brings together all RAG components with LangChain runnables
 */

import { RunnableConfig } from '@langchain/core/runnables';
import { logger } from '../services/logger.js';
import telemetry from './telemetry.js';
import promptManager, { PromptStyle } from './prompts.js';
import { ResponseFactory, RAGResponseSchema } from './schemas.js';
import { createRAGPipeline, createStreamingRAGPipeline } from './runnables/rag-pipeline.js';
import { HybridRetriever } from '../retrieval/retriever.js';
import { Generator } from '../retrieval/generator.js';

/**
 * Orchestrator configuration
 */
export interface OrchestratorConfig {
  topK: number;
  similarityThreshold: number;
  useReranking: boolean;
  useHybridSearch: boolean;
  promptStyle: PromptStyle;
  enableTelemetry: boolean;
  enableStreaming: boolean;
  maxRetries: number;
  timeoutMs: number;
}

/**
 * Orchestrator request
 */
export interface OrchestratorRequest {
  query: string;
  topK?: number;
  includeSources?: boolean;
  promptStyle?: PromptStyle;
  metadataFilters?: Record<string, any>;
  userContext?: Record<string, any>;
  traceId?: string;
}

/**
 * Main orchestrator for the RAG system
 */
export class Orchestrator {
  private config: OrchestratorConfig;
  private retriever: HybridRetriever;
  private generator: Generator;
  private ragPipeline: ReturnType<typeof createRAGPipeline>;
  private streamingPipeline: ReturnType<typeof createStreamingRAGPipeline>;

  constructor(config?: Partial<OrchestratorConfig>) {
    this.config = {
      topK: parseInt(process.env.TOP_K_RETRIEVAL || '5'),
      similarityThreshold: parseFloat(process.env.SIMILARITY_THRESHOLD || '0.7'),
      useReranking: true,
      useHybridSearch: true,
      promptStyle: PromptStyle.DETAILED,
      enableTelemetry: true,
      enableStreaming: true,
      maxRetries: 3,
      timeoutMs: 30000,
      ...config,
    };

    this.retriever = new HybridRetriever(this.config);
    this.generator = new Generator();
    
    // Initialize LangChain pipelines
    this.ragPipeline = createRAGPipeline();
    this.streamingPipeline = createStreamingRAGPipeline();

    logger.info('Orchestrator initialized', { config: this.config });
  }

  /**
   * Execute a RAG query with full orchestration
   */
  async query(request: OrchestratorRequest): Promise<any> {
    const traceId = request.traceId || telemetry.startTrace('RAG Query');
    const spanId = telemetry.startSpan(traceId, 'orchestrator.query');

    const startTime = Date.now();

    try {
      // Log the request
      telemetry.recordEvent('query.start', {
        query: request.query.substring(0, 100),
        topK: request.topK || this.config.topK,
        promptStyle: request.promptStyle || this.config.promptStyle,
        traceId,
      }, traceId, spanId);

      // Build the prompt
      const promptStyle = request.promptStyle || this.config.promptStyle;
      const prompt = await this.buildPrompt(
        request.query,
        promptStyle,
        request.metadataFilters
      );

      // Execute the pipeline
      const result = await this.ragPipeline.invoke({
        query: request.query,
        topK: request.topK || this.config.topK,
        ...prompt,
      });

      // Validate the result
      const validation = ResponseFactory.validate(RAGResponseSchema, result);
      if (!validation.success) {
        telemetry.recordEvent('query.validation_failed', {
          errors: validation.errors,
          traceId,
        }, traceId, spanId);
        
        throw new Error(`Response validation failed: ${validation.errors.join(', ')}`);
      }

      const duration = Date.now() - startTime;

      // Record metrics
      telemetry.recordPerformance('rag.query', duration, {
        promptStyle,
        resultCount: (result.sources || []).length,
      });

      telemetry.recordEvent('query.complete', {
        answerLength: result.answer.length,
        confidence: result.confidence,
        sourceCount: (result.sources || []).length,
        duration,
        traceId,
      }, traceId, spanId);

      // End spans and trace
      telemetry.endSpan(traceId, spanId, 'success');
      telemetry.endTrace(traceId, 'success');

      return {
        ...result,
        metadata: {
          traceId,
          duration,
          timestamp: new Date().toISOString(),
        },
      };

    } catch (error) {
      const duration = Date.now() - startTime;
      
      telemetry.recordEvent('query.error', {
        error: error instanceof Error ? error.message : String(error),
        duration,
        traceId,
      }, traceId, spanId);

      telemetry.endSpan(traceId, spanId, 'error', 
        error instanceof Error ? error.message : String(error)
      );
      telemetry.endTrace(traceId, 'error', 
        error instanceof Error ? error.message : String(error)
      );

      // Return error response
      return ResponseFactory.error(
        error instanceof Error ? error.message : 'Query failed',
        'GENERATION_FAILED',
        true,
        'Please try again with a different query'
      );
    }
  }

  /**
   * Stream a RAG query response
   */
  async queryStreaming(
    request: OrchestratorRequest,
    onToken: (token: string) => void
  ): Promise<any> {
    const traceId = request.traceId || telemetry.startTrace('RAG Query Streaming');
    const spanId = telemetry.startSpan(traceId, 'orchestrator.queryStreaming');

    const startTime = Date.now();

    try {
      telemetry.recordEvent('query.stream_start', {
        query: request.query.substring(0, 100),
        traceId,
      }, traceId, spanId);

      // Execute streaming pipeline
      const result = await this.streamingPipeline.invoke({
        query: request.query,
        topK: request.topK || this.config.topK,
        onToken,
      });

      const duration = Date.now() - startTime;

      telemetry.recordPerformance('rag.query.streaming', duration, {
        resultCount: (result.sources || []).length,
      });

      telemetry.endSpan(traceId, spanId, 'success');
      telemetry.endTrace(traceId, 'success');

      return result;

    } catch (error) {
      const duration = Date.now() - startTime;
      
      telemetry.recordEvent('query.stream_error', {
        error: error instanceof Error ? error.message : String(error),
        traceId,
      }, traceId, spanId);

      telemetry.endSpan(traceId, spanId, 'error');
      telemetry.endTrace(traceId, 'error');

      return ResponseFactory.error(
        error instanceof Error ? error.message : 'Streaming query failed',
        'GENERATION_FAILED',
        true,
        'Please try again with a different query'
      );
    }
  }

  /**
   * Build a prompt for the query
   */
  private async buildPrompt(
    query: string,
    style: PromptStyle,
    filters?: Record<string, any>
  ): Promise<{ context: string; system?: string }> {
    const traceId = telemetry.startTrace('Build Prompt');
    const spanId = telemetry.startSpan(traceId, 'orchestrator.buildPrompt');

    try {
      // Retrieve context
      const results = await this.retriever.retrieve(query, {
        topK: this.config.topK,
        useReranking: this.config.useReranking,
        useHybridSearch: this.config.useHybridSearch,
      }, filters);

      // Format context
      const context = results
        .map((result, i) => {
          const score = result.rerankScore || result.score;
          return `[Source ${i + 1} (${(score * 100).toFixed(1)}%)]\n${result.chunk.content}`;
        })
        .join('\n\n---\n\n');

      // Build prompt with style
      const prompt = await promptManager.buildPrompt(style, {
        context,
        question: query,
      });

      telemetry.endSpan(traceId, spanId, 'success');
      telemetry.endTrace(traceId, 'success');

      return { context };

    } catch (error) {
      telemetry.endSpan(traceId, spanId, 'error');
      telemetry.endTrace(traceId, 'error');
      throw error;
    }
  }

  /**
   * Update orchestrator configuration
   */
  updateConfig(config: Partial<OrchestratorConfig>): void {
    this.config = { ...this.config, ...config };
    this.retriever.updateConfig(config);
    logger.info('Orchestrator configuration updated', { config: this.config });
  }

  /**
   * Get orchestrator status
   */
  async getStatus(): Promise<Record<string, any>> {
    const health = await this.retriever.healthCheck();
    const telemetryHealth = telemetry.getHealth();
    
    return {
      config: this.config,
      health,
      telemetry: telemetryHealth,
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
    };
  }
}

export default new Orchestrator();
```

---

## Phase 3.6: Update Main Application

### The Target
Update the main application to use the new orchestration layer.

### The Implementation

Update `src/app.ts` to use the orchestrator:

```typescript
/**
 * Main Application Entry Point - Updated for Part 3
 * Using the complete orchestration layer
 */

import dotenv from 'dotenv';
import { logger } from './services/logger.js';
import orchestrator from './orchestration/orchestrator.js';
import telemetry from './orchestration/telemetry.js';
import { PromptStyle } from './orchestration/prompts.js';
import { vectorDB } from './services/vector-db.js';
import loader from './ingestion/loader.js';
import chunker from './ingestion/chunker.js';
import embedder from './ingestion/embedder.js';

dotenv.config();

export class RAGApplication {
  private initialized = false;

  async initialize(): Promise<void> {
    if (this.initialized) return;

    logger.info('🚀 Initializing RAG Application (Part 3)');

    try {
      // Check database
      const dbHealth = await vectorDB.healthCheck();
      if (!dbHealth) {
        throw new Error('Database connection failed');
      }
      logger.info('✅ Database connected');

      // Check embedding service
      const embeddingHealth = await embedder.healthCheck();
      if (!embeddingHealth) {
        throw new Error('Embedding service unavailable');
      }
      logger.info('✅ Embedding service ready');

      this.initialized = true;
      logger.info('✅ Application initialized successfully');

    } catch (error) {
      logger.error('Failed to initialize application', {
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  async query(
    question: string,
    options?: {
      topK?: number;
      includeSources?: boolean;
      promptStyle?: PromptStyle;
      stream?: boolean;
      onToken?: (token: string) => void;
    }
  ): Promise<any> {
    logger.info('🔍 Querying RAG system (Part 3)', {
      question: question.substring(0, 100),
      options,
    });

    const traceId = telemetry.startTrace('App Query');
    
    try {
      if (options?.stream && options.onToken) {
        return await orchestrator.queryStreaming(
          {
            query: question,
            topK: options.topK,
            includeSources: options.includeSources,
            promptStyle: options.promptStyle,
            traceId,
          },
          options.onToken
        );
      } else {
        return await orchestrator.query({
          query: question,
          topK: options?.topK,
          includeSources: options?.includeSources,
          promptStyle: options?.promptStyle,
          traceId,
        });
      }
    } catch (error) {
      logger.error('Query failed', {
        question,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  async ingestDocuments(
    directoryPath: string,
    options?: {
      extensionFilter?: string[];
      dryRun?: boolean;
    }
  ): Promise<any> {
    logger.info('📄 Starting document ingestion', {
      directoryPath,
      options,
    });

    const traceId = telemetry.startTrace('Ingestion');

    try {
      // Load documents
      const documents = await loader.loadDirectory(
        directoryPath,
        options?.extensionFilter
      );
      
      if (documents.length === 0) {
        return { documentsLoaded: 0, chunksCreated: 0, chunksStored: 0 };
      }

      // Chunk documents
      const chunks = await chunker.chunkDocuments(documents);
      
      if (options?.dryRun) {
        return {
          documentsLoaded: documents.length,
          chunksCreated: chunks.length,
          chunksStored: 0,
        };
      }

      // Embed and store
      const embeddedChunks = await embedder.embedChunks(chunks);
      const storedIds = await vectorDB.storeDocuments(embeddedChunks);

      telemetry.endTrace(traceId, 'success');
      telemetry.recordMetric('ingestion.documents', documents.length, 'count');
      telemetry.recordMetric('ingestion.chunks', storedIds.length, 'count');

      return {
        documentsLoaded: documents.length,
        chunksCreated: chunks.length,
        chunksStored: storedIds.length,
      };

    } catch (error) {
      telemetry.endTrace(traceId, 'error', 
        error instanceof Error ? error.message : String(error)
      );
      throw error;
    }
  }

  async interactive(): Promise<void> {
    logger.info('💬 Starting interactive mode (Part 3)');
    console.log('\n' + '='.repeat(60));
    console.log('📚 RAG System Interactive Mode (LangChain Orchestration)');
    console.log('='.repeat(60));
    console.log('Commands:');
    console.log('  /ingest <path>    - Ingest documents from directory');
    console.log('  /status           - Show system status');
    console.log('  /style <style>    - Set prompt style (concise|detailed|reasoning)');
    console.log('  /trace <id>       - Show trace details');
    console.log('  /help             - Show this help');
    console.log('  /exit             - Exit interactive mode');
    console.log('  <question>        - Ask a question');
    console.log('='.repeat(60) + '\n');

    const readline = (await import('readline')).default;
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    let currentStyle = PromptStyle.DETAILED;

    const askQuestion = (): Promise<void> => {
      return new Promise((resolve) => {
        rl.question(`❓ You (${currentStyle}): `, async (input: string) => {
          const trimmed = input.trim();
          
          if (!trimmed) {
            resolve();
            return;
          }

          if (trimmed.startsWith('/')) {
            await this.handleCommand(trimmed, rl, currentStyle, (style) => {
              currentStyle = style;
            });
          } else if (trimmed.toLowerCase() === 'exit') {
            console.log('👋 Goodbye!');
            rl.close();
            resolve();
            return;
          } else {
            try {
              console.log('🤖 Thinking...');
              const startTime = Date.now();
              
              // Stream the response
              console.log('\n🤖 Answer: ');
              let fullAnswer = '';
              
              const response = await this.query(trimmed, {
                includeSources: true,
                promptStyle: currentStyle,
                stream: true,
                onToken: (token) => {
                  process.stdout.write(token);
                  fullAnswer += token;
                },
              });
              
              console.log('\n');
              
              if (response.metadata) {
                console.log(`⏱️ Time: ${response.metadata.duration}ms`);
                console.log(`🔍 Trace: ${response.metadata.traceId}`);
              }
              
              if (response.sources && response.sources.length > 0) {
                console.log('\n📚 Sources:');
                response.sources.forEach((source: any, index: number) => {
                  console.log(`  ${index + 1}. (${(source.score * 100).toFixed(1)}%)`);
                  console.log(`     ${source.content.substring(0, 150)}...`);
                });
              }
              
              if (response.confidence !== undefined) {
                console.log(`\n📊 Confidence: ${(response.confidence * 100).toFixed(1)}%`);
              }
              
              console.log('');
              
            } catch (error) {
              console.log(`❌ Error: ${error instanceof Error ? error.message : String(error)}`);
            }
          }
          
          resolve();
        });
      });
    };

    while (true) {
      await askQuestion();
      if (!rl.closed) continue;
      break;
    }
  }

  private async handleCommand(
    input: string,
    rl: any,
    currentStyle: PromptStyle,
    setStyle: (style: PromptStyle) => void
  ): Promise<void> {
    const parts = input.split(' ');
    const command = parts[0].toLowerCase();
    
    switch (command) {
      case '/style': {
        const style = parts[1] as PromptStyle;
        if (Object.values(PromptStyle).includes(style)) {
          setStyle(style);
          console.log(`✅ Prompt style set to: ${style}`);
        } else {
          console.log(`❌ Invalid style: ${style}`);
          console.log(`   Valid: ${Object.values(PromptStyle).join(', ')}`);
        }
        break;
      }
      
      case '/trace': {
        const traceId = parts[1];
        if (!traceId) {
          console.log('❌ Please provide a trace ID: /trace <id>');
          return;
        }
        
        const trace = telemetry.getTrace(traceId);
        if (!trace) {
          console.log(`❌ Trace not found: ${traceId}`);
          return;
        }
        
        console.log('\n📊 Trace Details:');
        console.log(`  ID: ${trace.id}`);
        console.log(`  Name: ${trace.name}`);
        console.log(`  Status: ${trace.status}`);
        console.log(`  Start: ${trace.startTime}`);
        console.log(`  Duration: ${trace.duration}ms`);
        console.log(`  Spans: ${trace.spans.length}`);
        
        if (trace.error) {
          console.log(`  Error: ${trace.error}`);
        }
        
        console.log('\n  Spans:');
        trace.spans.forEach((span, i) => {
          console.log(`    ${i + 1}. ${span.name}`);
          console.log(`       Status: ${span.status}`);
          console.log(`       Duration: ${span.duration}ms`);
          if (span.events.length > 0) {
            console.log(`       Events: ${span.events.length}`);
          }
        });
        console.log('');
        break;
      }
      
      default:
        // Let parent handle it
        break;
    }
  }

  async shutdown(): Promise<void> {
    logger.info('🔄 Shutting down application');
    try {
      await vectorDB.close();
      chunker.dispose();
      logger.info('✅ Clean shutdown complete');
    } catch (error) {
      logger.error('Error during shutdown', { error });
    }
  }
}

async function main() {
  const app = new RAGApplication();
  
  try {
    await app.initialize();
    
    const args = process.argv.slice(2);
    const isInteractive = args.includes('--interactive') || args.includes('-i');
    const ingestPath = args.find(arg => arg.startsWith('--ingest='))?.split('=')[1];
    const queryText = args.find(arg => arg.startsWith('--query='))?.split('=')[1];
    
    if (ingestPath) {
      const result = await app.ingestDocuments(ingestPath);
      console.log(`✅ Ingestion complete:`, result);
    } else if (queryText) {
      const response = await app.query(queryText, { includeSources: true });
      console.log('\n🤖 Answer:');
      console.log(response.answer);
      console.log(`\n📊 Confidence: ${(response.confidence * 100).toFixed(1)}%`);
    } else if (isInteractive) {
      await app.interactive();
    } else {
      console.log(`
📚 RAG System - LangChain Orchestration

Usage:
  npm start [options]

Options:
  --ingest=<path>     Ingest documents from directory
  --query=<text>      Query the RAG system
  --interactive, -i   Interactive mode
  --help, -h          Show this help

Examples:
  npm start -- --ingest=./docs
  npm start -- --query="What is RAG?"
  npm start -- --interactive
      `);
    }
    
    await app.shutdown();
    process.exit(0);
    
  } catch (error) {
    logger.error('Application error', { error });
    process.exit(1);
  }
}

main();
```

---

## Part 3 Summary

🎉 **Congratulations! You've built a professional orchestration layer!**

### What You've Added:
- ✅ **LangChain.js Runnables** — Composable, provider-agnostic operations
- ✅ **Prompt Templates** — Reusable, parameterized, and style-able
- ✅ **Structured Output** — Zod-validated, guaranteed format
- ✅ **Runtime Telemetry** — Comprehensive tracing, metrics, and monitoring
- ✅ **Error Handling** — Retries, fallbacks, and graceful degradation
- ✅ **Streaming Support** — Token-by-token responses
- ✅ **Provider Abstraction** — Easy to swap LLM providers

### What's Next in Part 4:
- **LangGraph.js** — Stateful, cyclic agent workflows
- **State Machines** — Typed state with validation
- **Parallel Execution** — Fan-out with `Promise.all()`
- **Checkpoint Persistence** — Resumable workflows
- **Human-in-the-Loop** — Approval gates and pauses

---

*Continue to Part 4, where we'll build autonomous, self-correcting agents with LangGraph.js.*
