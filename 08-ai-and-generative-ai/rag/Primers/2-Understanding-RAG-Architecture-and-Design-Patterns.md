# Primer 2: Understanding RAG Architecture and Design Patterns

## Overview

This primer provides a comprehensive deep dive into RAG (Retrieval-Augmented Generation) architecture, design patterns, and best practices. While the main tutorial series focuses on implementation, this primer explores the architectural decisions, trade-offs, and patterns that make RAG systems production-ready.

---

## P2.1 What is RAG?

### The Core Concept

**Retrieval-Augmented Generation (RAG)** is an architecture that combines:
1. **Retrieval**: Finding relevant information from an external knowledge base
2. **Generation**: Using an LLM to synthesize an answer from retrieved information

Instead of relying solely on the LLM's parametric memory (what it learned during training), RAG provides relevant context at query time.

### The Simple RAG Pipeline

```
┌─────────────────────────────────────────────────────┐
│                  Simple RAG Pipeline                │
├─────────────────────────────────────────────────────┤
│                                                      │
│   User Query    ──▶  Embed   ──▶  Search          │
│                                                      │
│                         │                           │
│                         ▼                           │
│                  ┌─────────────┐                    │
│                  │   Context   │                    │
│                  │   (Chunks)  │                    │
│                  └─────────────┘                    │
│                         │                           │
│                         ▼                           │
│   Response    ◀──  LLM   ◀──  Prompt + Context    │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Why RAG Matters

| Problem | Without RAG | With RAG |
|---------|-------------|----------|
| Knowledge cutoff | Outdated info | Always current |
| Hallucinations | Frequent | Reduced |
| Private data | Cannot access | Secure access |
| Source attribution | None | Can cite sources |
| Customization | Retraining needed | Just update data |

### Code: Basic RAG Implementation

```typescript
class BasicRAG {
  async answer(question: string): Promise<string> {
    // 1. Embed the question
    const queryEmbedding = await embedder.embedQuery(question);
    
    // 2. Retrieve relevant documents
    const searchResults = await vectorDB.similaritySearch(
      queryEmbedding,
      5 // top-k
    );
    
    // 3. Build context
    const context = searchResults
      .map(r => r.chunk.content)
      .join('\n\n');
    
    // 4. Generate answer
    const prompt = `Context: ${context}\nQuestion: ${question}\nAnswer:`;
    const response = await llm.invoke(prompt);
    
    return response.content;
  }
}
```

---

## P2.2 RAG Architecture Patterns

### Pattern 1: Naive RAG (Basic)

**Architecture:**
```
Query → Embed → Search → Retrieve → Prompt → Generate → Response
```

**Characteristics:**
- Simple implementation
- One retrieval attempt
- No refinement

**When to use:**
- Simple QA
- Prototyping
- Small knowledge bases

### Pattern 2: RAG with Reranking

**Architecture:**
```
Query → Embed → Search → Retrieve → Rerank → Prompt → Generate → Response
```

**Characteristics:**
- Initial retrieval (e.g., 20 results)
- Cross-encoder reranking
- Higher precision

**When to use:**
- Precision-critical applications
- Large result sets
- Domain-specific ranking

```typescript
class RAGWithReranking extends BasicRAG {
  async answer(question: string): Promise<string> {
    // Get more results initially
    const initialResults = await vectorDB.similaritySearch(
      await embedder.embedQuery(question),
      20 // Double the usual
    );
    
    // Rerank with cross-encoder
    const reranked = await reranker.rerank(question, initialResults, 5);
    
    // Continue with normal flow
    const context = reranked.map(r => r.chunk.content).join('\n\n');
    // ... rest of generation
  }
}
```

### Pattern 3: Iterative RAG (Self-Correction)

**Architecture:**
```
Query → Search → Evaluate → [Quality Check]
                                │
                    If Poor ◀───┘
                                │
                    If Good ───▶ Generate → Response
```

**Characteristics:**
- Multiple retrieval attempts
- Quality evaluation
- Query refinement

**When to use:**
- Complex queries
- High accuracy requirements
- Exploratory search

```typescript
class IterativeRAG {
  async answer(question: string, maxIterations: number = 3): Promise<string> {
    let query = question;
    let bestResults = null;
    let bestScore = 0;
    
    for (let i = 0; i < maxIterations; i++) {
      // Search with current query
      const results = await this.search(query);
      
      // Evaluate quality
      const score = await this.evaluateResults(results, question);
      
      if (score > bestScore) {
        bestScore = score;
        bestResults = results;
      }
      
      // If good enough, stop
      if (score > 0.7) break;
      
      // Refine query
      query = await this.refineQuery(query, results);
    }
    
    return this.generate(question, bestResults);
  }
}
```

### Pattern 4: Agentic RAG

**Architecture:**
```
Query → Agent Planner → [Tool Decision]
                │
                ├─── Search ───┐
                ├─── Rerank ───┤
                ├─── Web ──────┤─── Evaluate
                ├─── API ──────┤
                └─── Human ────┘
```

**Characteristics:**
- Autonomous tool selection
- Multi-step reasoning
- Human-in-the-loop

**When to use:**
- Complex tasks
- Multi-domain queries
- High-stakes decisions

```typescript
class AgenticRAG {
  async execute(question: string): Promise<string> {
    const agent = new Agent({
      tools: [
        new SearchTool(),
        new RerankTool(),
        new WebSearchTool(),
        new HumanApprovalTool(),
      ],
    });
    
    const result = await agent.invoke(question);
    return result.finalAnswer;
  }
}
```

---

## P2.3 Chunking Strategies

### Why Chunking Matters

Chunking is critical because:
1. **Context Window**: LLMs have token limits
2. **Relevance**: Each chunk should be a coherent unit
3. **Retrieval**: Too large = noisy, too small = disconnected

### Strategy 1: Fixed-Size Chunking

**Characteristics:**
- Fixed number of characters/tokens
- Simple implementation
- May break semantic units

```typescript
function fixedSizeChunk(text: string, size: number = 1000): string[] {
  const chunks: string[] = [];
  for (let i = 0; i < text.length; i += size) {
    chunks.push(text.slice(i, i + size));
  }
  return chunks;
}
```

### Strategy 2: Recursive Chunking

**Characteristics:**
- Uses hierarchy of separators
- Preserves natural boundaries
- More semantically coherent

```typescript
function recursiveChunk(text: string, separators: string[], chunkSize: number): string[] {
  if (text.length <= chunkSize) return [text];
  
  const separator = separators[0];
  const parts = text.split(separator);
  const chunks: string[] = [];
  let currentChunk = '';
  
  for (const part of parts) {
    if (currentChunk.length + part.length > chunkSize) {
      if (currentChunk) chunks.push(currentChunk);
      if (part.length > chunkSize) {
        chunks.push(...recursiveChunk(part, separators.slice(1), chunkSize));
        currentChunk = '';
      } else {
        currentChunk = part;
      }
    } else {
      currentChunk += (currentChunk ? separator : '') + part;
    }
  }
  
  if (currentChunk) chunks.push(currentChunk);
  return chunks;
}
```

### Strategy 3: Semantic Chunking

**Characteristics:**
- Uses NLP to identify semantic units
- Maintains meaning
- More complex implementation

```typescript
function semanticChunk(text: string): string[] {
  // Split by paragraphs
  const paragraphs = text.split('\n\n');
  const chunks: string[] = [];
  let currentChunk = '';
  
  for (const para of paragraphs) {
    // If adding paragraph exceeds chunk size, split by sentences
    if (currentChunk.length + para.length > 1000) {
      if (currentChunk) chunks.push(currentChunk);
      
      // Split paragraph by sentences
      const sentences = para.match(/[^.!?]+[.!?]+/g) || [para];
      currentChunk = '';
      
      for (const sentence of sentences) {
        if (currentChunk.length + sentence.length > 1000) {
          if (currentChunk) chunks.push(currentChunk);
          currentChunk = sentence;
        } else {
          currentChunk += (currentChunk ? ' ' : '') + sentence;
        }
      }
    } else {
      currentChunk += (currentChunk ? '\n\n' : '') + para;
    }
  }
  
  if (currentChunk) chunks.push(currentChunk);
  return chunks;
}
```

### Chunk Size Guidelines

| Use Case | Chunk Size | Overlap | Reason |
|----------|------------|---------|--------|
| General RAG | 500-1000 tokens | 10-20% | Balanced |
| Code Search | 200-500 tokens | 10-20% | Small functions |
| Long-form QA | 1000-2000 tokens | 10-20% | Need full context |
| Legal/Medical | 200-500 tokens | 20-30% | Precision critical |

---

## P2.4 Retrieval Strategies

### Strategy 1: Dense Retrieval

**Characteristics:**
- Uses embeddings
- Captures semantic meaning
- Works cross-lingually

```typescript
class DenseRetriever {
  async retrieve(query: string, topK: number = 5): Promise<Document[]> {
    const embedding = await embedder.embedQuery(query);
    const results = await vectorDB.similaritySearch(embedding, topK);
    return results.map(r => r.chunk);
  }
}
```

### Strategy 2: Lexical Retrieval (BM25)

**Characteristics:**
- Uses term matching
- Fast and deterministic
- Good for exact matches

```typescript
class LexicalRetriever {
  private index: BM25;
  
  async retrieve(query: string, topK: number = 5): Promise<Document[]> {
    const scores = this.index.score(query);
    return scores
      .map((score, idx) => ({ document: this.documents[idx], score }))
      .sort((a, b) => b.score - a.score)
      .slice(0, topK)
      .map(item => item.document);
  }
}
```

### Strategy 3: Hybrid Retrieval

**Characteristics:**
- Combines multiple methods
- More robust
- Better recall

```typescript
class HybridRetriever {
  async retrieve(query: string, topK: number = 5): Promise<Document[]> {
    // Get results from multiple methods
    const [denseResults, lexicalResults] = await Promise.all([
      this.denseRetriever.retrieve(query, topK * 2),
      this.lexicalRetriever.retrieve(query, topK * 2),
    ]);
    
    // Fuse results
    return this.fuseResults(denseResults, lexicalResults, topK);
  }
  
  private fuseResults(
    dense: Document[],
    lexical: Document[],
    topK: number
  ): Document[] {
    // Reciprocal Rank Fusion (RRF)
    const scores = new Map<string, number>();
    const K = 60;
    
    [...dense, ...lexical].forEach((doc, rank) => {
      const currentScore = scores.get(doc.id) || 0;
      scores.set(doc.id, currentScore + 1 / (K + rank + 1));
    });
    
    return Array.from(scores.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, topK)
      .map(([id]) => this.documents.find(d => d.id === id)!);
  }
}
```

### Strategy 4: Multi-Query Retrieval

**Characteristics:**
- Uses multiple query formulations
- Improves recall
- Handles ambiguous queries

```typescript
class MultiQueryRetriever {
  async retrieve(question: string, topK: number = 5): Promise<Document[]> {
    // Generate multiple queries
    const queries = await this.generateQueries(question);
    
    // Search with each query
    const allResults = await Promise.all(
      queries.map(q => this.baseRetriever.retrieve(q, topK))
    );
    
    // Merge and deduplicate
    return this.mergeResults(allResults, topK);
  }
  
  private async generateQueries(question: string): Promise<string[]> {
    const prompt = `
      Generate 3 different search queries for: "${question}"
      Make them different but related.
    `;
    const response = await llm.invoke(prompt);
    return JSON.parse(response.content);
  }
}
```

---

## P2.5 Indexing and Storage Patterns

### Pattern 1: Simple Document Storage

**Schema:**
```sql
CREATE TABLE documents (
  id UUID PRIMARY KEY,
  content TEXT,
  embedding VECTOR(1536),
  metadata JSONB
);
```

**When to use:**
- Small deployments
- Simple use cases
- Quick prototyping

### Pattern 2: Document Hierarchical Storage

**Schema:**
```sql
CREATE TABLE sources (
  id UUID PRIMARY KEY,
  name TEXT,
  type TEXT
);

CREATE TABLE documents (
  id UUID PRIMARY KEY,
  source_id UUID REFERENCES sources(id),
  content TEXT,
  embedding VECTOR(1536),
  metadata JSONB,
  parent_id UUID REFERENCES documents(id) -- For hierarchy
);
```

**When to use:**
- Multi-source documents
- Nested structures
- Document versioning

### Pattern 3: Multi-Tenant Storage

**Schema:**
```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY,
  name TEXT,
  config JSONB
);

CREATE TABLE documents (
  id UUID PRIMARY KEY,
  tenant_id UUID REFERENCES tenants(id),
  content TEXT,
  embedding VECTOR(1536),
  metadata JSONB,
  access_level TEXT
);

-- Partition by tenant
CREATE TABLE documents_tenant_1 PARTITION OF documents
  FOR VALUES IN ('tenant-1');
```

**When to use:**
- SaaS applications
- Multiple organizations
- Data isolation requirements

### Indexing Strategy

```sql
-- 1. HNSW index for fast ANN search
CREATE INDEX documents_embedding_idx 
ON documents 
USING hnsw (embedding vector_cosine_ops);

-- 2. GIN index for metadata filtering
CREATE INDEX documents_metadata_idx 
ON documents 
USING gin (metadata);

-- 3. Partial indexes for frequent queries
CREATE INDEX documents_frequent_idx 
ON documents (id, metadata) 
WHERE metadata->>'department' = 'engineering';

-- 4. Covering indexes for commonly accessed fields
CREATE INDEX documents_covering_idx 
ON documents (id) 
INCLUDE (content, metadata);
```

---

## P2.6 Generation Strategies

### Strategy 1: Simple Generation

**Characteristics:**
- Single LLM call
- No validation
- Simple and fast

```typescript
class SimpleGenerator {
  async generate(question: string, context: string): Promise<string> {
    const prompt = `
      Context: ${context}
      Question: ${question}
      Answer:
    `;
    const response = await llm.invoke(prompt);
    return response.content;
  }
}
```

### Strategy 2: Structured Generation

**Characteristics:**
- Validated output format
- Type-safe responses
- Reliable parsing

```typescript
const AnswerSchema = z.object({
  answer: z.string(),
  confidence: z.number().min(0).max(1),
  sources: z.array(z.string()),
});

class StructuredGenerator {
  async generate(question: string, context: string): Promise<z.infer<typeof AnswerSchema>> {
    const parser = StructuredOutputParser.fromZodSchema(AnswerSchema);
    const prompt = await this.createPrompt(question, context, parser.getFormatInstructions());
    const response = await llm.invoke(prompt);
    return parser.parse(response.content);
  }
}
```

### Strategy 3: Iterative Generation

**Characteristics:**
- Multiple LLM calls
- Self-correction
- Higher quality

```typescript
class IterativeGenerator {
  async generate(question: string, context: string): Promise<string> {
    let draft = await this.generateDraft(question, context);
    let iterations = 0;
    
    while (iterations < 3) {
      const feedback = await this.evaluateDraft(draft, question, context);
      if (feedback.quality > 0.8) break;
      draft = await this.improveDraft(draft, feedback, question, context);
      iterations++;
    }
    
    return draft;
  }
}
```

### Strategy 4: Chain-of-Thought Generation

**Characteristics:**
- Step-by-step reasoning
- Explainable
- Better complex reasoning

```typescript
class ChainOfThoughtGenerator {
  async generate(question: string, context: string): Promise<string> {
    const steps = await this.reasonSteps(question, context);
    const answer = await this.synthesize(question, steps);
    return answer;
  }
  
  private async reasonSteps(
    question: string,
    context: string
  ): Promise<string[]> {
    const prompt = `
      Context: ${context}
      Question: ${question}
      
      Break down the reasoning into steps:
      Step 1: ...
      Step 2: ...
    `;
    const response = await llm.invoke(prompt);
    return this.parseSteps(response.content);
  }
}
```

---

## P2.7 Evaluation Patterns

### Pattern 1: Retrieval Evaluation

```typescript
class RetrievalEvaluator {
  // Mean Reciprocal Rank
  computeMRR(results: Array<Array<boolean>>): number {
    let sum = 0;
    for (const queryResults of results) {
      for (let i = 0; i < queryResults.length; i++) {
        if (queryResults[i]) {
          sum += 1 / (i + 1);
          break;
        }
      }
    }
    return sum / results.length;
  }
  
  // Precision@k
  computePrecisionAtK(results: Array<Array<boolean>>, k: number): number {
    let total = 0;
    for (const queryResults of results) {
      const relevant = queryResults.slice(0, k).filter(r => r).length;
      total += relevant / k;
    }
    return total / results.length;
  }
  
  // Recall@k
  computeRecallAtK(results: Array<Array<boolean>>, k: number): number {
    let total = 0;
    for (const queryResults of results) {
      const relevant = queryResults.filter(r => r).length;
      const relevantInK = queryResults.slice(0, k).filter(r => r).length;
      total += relevantInK / (relevant || 1);
    }
    return total / results.length;
  }
}
```

### Pattern 2: Generation Evaluation

```typescript
class GenerationEvaluator {
  // Faithfulness: Does the answer stay true to the context?
  async evaluateFaithfulness(answer: string, context: string): Promise<number> {
    const prompt = `
      Context: ${context}
      Answer: ${answer}
      
      Rate faithfulness from 0-1 (1 = completely faithful):
    `;
    const response = await llm.invoke(prompt);
    return parseFloat(response.content);
  }
  
  // Completeness: Does the answer fully answer the question?
  async evaluateCompleteness(question: string, answer: string): Promise<number> {
    const prompt = `
      Question: ${question}
      Answer: ${answer}
      
      Rate completeness from 0-1 (1 = completely answers):
    `;
    const response = await llm.invoke(prompt);
    return parseFloat(response.content);
  }
  
  // Coherence: Is the answer well-structured and logical?
  async evaluateCoherence(answer: string): Promise<number> {
    const prompt = `
      Answer: ${answer}
      
      Rate coherence from 0-1 (1 = perfectly coherent):
    `;
    const response = await llm.invoke(prompt);
    return parseFloat(response.content);
  }
}
```

### Pattern 3: End-to-End Evaluation

```typescript
class EndToEndEvaluator {
  async evaluate(
    testCases: Array<{ question: string; expected: string; context: string[] }>
  ): Promise<{
    retrievalMetrics: any;
    generationMetrics: any;
    overallScore: number;
  }> {
    const results = [];
    
    for (const testCase of testCases) {
      // Run RAG pipeline
      const result = await ragPipeline.query(testCase.question);
      
      // Evaluate retrieval
      const retrievalQuality = this.evaluateRetrieval(
        result.sources,
        testCase.context
      );
      
      // Evaluate generation
      const generationQuality = await this.evaluateGeneration(
        result.answer,
        testCase.expected,
        testCase.context
      );
      
      results.push({
        retrieval: retrievalQuality,
        generation: generationQuality,
      });
    }
    
    return this.aggregateResults(results);
  }
}
```

---

## P2.8 Production Patterns

### Pattern 1: Caching

```typescript
class CachePattern {
  private cache = new Map<string, any>();
  
  async query(question: string): Promise<string> {
    // Check cache
    const cacheKey = this.createCacheKey(question);
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }
    
    // Execute query
    const result = await this.executeQuery(question);
    
    // Store in cache
    this.cache.set(cacheKey, result);
    return result;
  }
  
  private createCacheKey(question: string): string {
    return crypto.createHash('sha256')
      .update(question.toLowerCase().trim())
      .digest('hex');
  }
}
```

### Pattern 2: Graceful Degradation

```typescript
class GracefulDegradation {
  async query(question: string): Promise<string> {
    try {
      // Try full RAG pipeline
      return await this.fullPipeline(question);
    } catch (error) {
      // Fallback to simple retrieval
      try {
        return await this.fallbackRetrieval(question);
      } catch (error) {
        // Ultimate fallback
        return "I couldn't process your request. Please try again.";
      }
    }
  }
}
```

### Pattern 3: Circuit Breaker

```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailureTime = Date.now();
  private threshold = 5;
  private timeout = 60000;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  
  async execute(fn: () => Promise<any>): Promise<any> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailureTime > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }
    
    try {
      const result = await fn();
      
      if (this.state === 'half-open') {
        this.state = 'closed';
        this.failures = 0;
      }
      
      return result;
      
    } catch (error) {
      this.failures++;
      this.lastFailureTime = Date.now();
      
      if (this.failures >= this.threshold) {
        this.state = 'open';
      }
      
      throw error;
    }
  }
}
```

---

## P2.9 Common Anti-Patterns

### Anti-Pattern 1: Over-Chunking

**Problem**: Creating chunks that are too small.

**Consequences**:
- Loss of context
- Noisy retrieval
- Incoherent responses

**Solution**:
- Minimum chunk size (e.g., 100 tokens)
- Semantic chunking
- Context preservation

### Anti-Pattern 2: Under-Chunking

**Problem**: Creating chunks that are too large.

**Consequences**:
- Exceeds context window
- Irrelevant information included
- Slow retrieval

**Solution**:
- Maximum chunk size (e.g., 1000 tokens)
- Recursive chunking
- Overlap for continuity

### Anti-Pattern 3: No Evaluation

**Problem**: Not measuring system performance.

**Consequences**:
- Unknown quality
- Degradation over time
- Hard to improve

**Solution**:
- Regular evaluation
- A/B testing
- Metrics dashboard

### Anti-Pattern 4: Ignoring Metadata

**Problem**: Storing only embeddings and content.

**Consequences**:
- No filtering
- Poor governance
- Hard to debug

**Solution**:
- Rich metadata
- Access controls
- Source tracking

---

## P2.10 Best Practices Checklist

### Data Preparation
- [ ] Clean and normalize text
- [ ] Remove duplicates
- [ ] Preserve structure (headings, lists)
- [ ] Add rich metadata
- [ ] Version documents

### Chunking
- [ ] Use semantic boundaries
- [ ] Include overlap
- [ ] Minimum and maximum sizes
- [ ] Preserve context
- [ ] Test different strategies

### Retrieval
- [ ] Hybrid approach
- [ ] Reranking for precision
- [ ] Metadata filtering
- [ ] Multi-query expansion
- [ ] Cache frequent queries

### Generation
- [ ] Structured output
- [ ] Chain-of-thought for complex queries
- [ ] Iterative improvement
- [ ] Source attribution
- [ ] Confidence scoring

### Evaluation
- [ ] Retrieval metrics (MRR, recall@k)
- [ ] Generation metrics (faithfulness, completeness)
- [ ] End-to-end testing
- [ ] A/B testing
- [ ] Monitoring dashboard

### Production
- [ ] Caching
- [ ] Graceful degradation
- [ ] Circuit breakers
- [ ] Monitoring and alerts
- [ ] Regular backups

---

## P2.11 Real-World Use Cases

### Customer Support

```typescript
class SupportRAG extends BasicRAG {
  async answer(question: string): Promise<string> {
    // Add customer context
    const customer = await getCustomerContext(question);
    
    // Filter by customer segment
    const results = await this.search(question, {
      filters: {
        customerSegment: customer.segment,
        productType: customer.productType,
      },
    });
    
    // Generate with support-specific prompt
    const prompt = `
      You are a support agent for ${customer.productType}.
      
      Context: ${results}
      Customer Question: ${question}
      Customer Info: ${JSON.stringify(customer)}
      
      Provide a helpful, empathetic response:
    `;
    
    return await llm.invoke(prompt);
  }
}
```

### Legal Document Review

```typescript
class LegalRAG extends BasicRAG {
  async answer(question: string): Promise<string> {
    // Add legal-specific filters
    const results = await this.search(question, {
      filters: {
        jurisdiction: 'US',
        court: 'Supreme Court',
        year: { $gte: 2010 },
      },
    });
    
    // Generate with legal-specific prompt
    const prompt = `
      You are a legal assistant. Provide citations.
      
      Context: ${results}
      Legal Question: ${question}
      
      Provide a legally sound answer with citations:
    `;
    
    return await llm.invoke(prompt);
  }
}
```

### Technical Documentation

```typescript
class TechDocRAG extends BasicRAG {
  async answer(question: string): Promise<string> {
    // Filter by technology
    const results = await this.search(question, {
      filters: {
        techStack: ['TypeScript', 'Node.js'],
        version: 'v2.0.0',
      },
    });
    
    // Generate with code examples
    const prompt = `
      You are a technical writer. Include code examples.
      
      Context: ${results}
      Technical Question: ${question}
      
      Provide a detailed answer with code examples:
    `;
    
    return await llm.invoke(prompt);
  }
}
```

---

## P2.12 Quick Reference

### RAG Pipeline Components

```typescript
// Complete RAG pipeline interface
interface RAGPipeline {
  // Pre-processing
  loadDocuments(): Promise<void>;
  chunkDocuments(): Promise<Chunk[]>;
  embedChunks(): Promise<EmbeddedChunk[]>;
  indexChunks(): Promise<void>;
  
  // Query
  query(question: string): Promise<RAGResponse>;
  
  // Post-processing
  evaluate(): Promise<EvaluationResults>;
  monitor(): Promise<Metrics>;
}
```

### Common Configurations

```typescript
const configs = {
  fast: {
    chunkSize: 500,
    topK: 3,
    useReranking: false,
    useHybrid: false,
  },
  balanced: {
    chunkSize: 1000,
    topK: 5,
    useReranking: true,
    useHybrid: true,
  },
  accurate: {
    chunkSize: 1500,
    topK: 10,
    useReranking: true,
    useHybrid: true,
    maxIterations: 3,
  },
};
```

### Useful Constants

```typescript
const RAG_CONSTANTS = {
  // Chunking
  MIN_CHUNK_SIZE: 100,      // tokens
  MAX_CHUNK_SIZE: 2000,     // tokens
  DEFAULT_CHUNK_SIZE: 1000, // tokens
  CHUNK_OVERLAP: 0.2,       // 20%
  
  // Retrieval
  DEFAULT_TOP_K: 5,
  MAX_TOP_K: 20,
  SIMILARITY_THRESHOLD: 0.7,
  
  // Performance
  BATCH_SIZE: 100,
  EMBEDDING_TIMEOUT: 30000, // 30 seconds
  SEARCH_TIMEOUT: 10000,    // 10 seconds
};
```

---

**[PRIMER 2 — COMPLETE]**

*Continue to Primer 3: Understanding LLM Agents and State Machines.*
