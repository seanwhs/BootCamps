# Student Workbook: Bridging the Gap — Enterprise RAG, Vector Databases, and Agentic Orchestration

## Overview

This student manual is designed to accompany the "Bridging the Gap" tutorial series. It provides:

- **Pre-class preparation**: What to do before each session
- **In-class activities**: Hands-on exercises and checkpoints
- **Post-class assignments**: Homework to reinforce learning
- **Reference materials**: Quick access to key concepts and commands
- **Troubleshooting guides**: Common issues and solutions
- **Self-assessment**: Check your understanding

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Part 1: The Context Deficit — Grounding Models with RAG](#part-1)
3. [Part 2: Advanced Retrieval & Defense](#part-2)
4. [Part 3: Orchestrating the Loop — LangChain.js](#part-3)
5. [Part 4: From Pipelines to Agents — LangGraph.js](#part-4)
6. [Capstone Project](#capstone)
7. [Appendices](#appendices)
8. [Glossary](#glossary)

---

## Getting Started

### Before You Begin

**System Requirements:**

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| CPU | 4 cores | 8+ cores |
| RAM | 8 GB | 16+ GB |
| Storage | 10 GB free | 50+ GB free |
| OS | Linux/macOS/Windows | Linux/macOS |
| Node.js | v20.0.0+ | Latest LTS |
| Docker | v20.10+ | Latest |
| Browser | Modern | Chrome/Firefox |

**Software to Install:**

```bash
# 1. Node.js (v20+)
node --version  # Should show v20.x.x or higher

# 2. Docker
docker --version
docker-compose --version

# 3. Git (optional but recommended)
git --version

# 4. A good code editor (VS Code recommended)
code --version
```

**Required Accounts:**

- [ ] OpenAI API key (https://platform.openai.com/api-keys)
- [ ] GitHub account (for code sharing)
- [ ] Optional: LangSmith account for monitoring

**Knowledge Checklist:**

Before starting, ensure you are comfortable with:

- [ ] JavaScript/TypeScript basics
- [ ] Async/await and Promises
- [ ] Basic terminal/command line usage
- [ ] REST API concepts
- [ ] JSON data format
- [ ] Environment variables

---

## Part 1: The Context Deficit

### Part 1 Overview

**Objective**: Build a complete RAG system from scratch.

**Duration**: 3-4 hours (including exercises)

**Key Skills**:
- Document loading and chunking
- Embedding generation
- Vector database operations
- Similarity search
- Basic RAG pipeline

---

### Pre-Class Preparation

**1. Set Up Your Project**

```bash
# Create project directory
mkdir rag-agent-system
cd rag-agent-system

# Initialize npm
npm init -y

# Install required dependencies
npm install typescript @types/node ts-node --save-dev
npm install dotenv pg @types/pg uuid @types/uuid langchain @langchain/openai @langchain/core winston zod

# Initialize TypeScript
npx tsc --init
```

**2. Create Your .env File**

```bash
# Create .env from template
cp .env.example .env
# Edit .env with your OpenAI API key
```

**3. Set Up Docker for PostgreSQL**

```bash
# Start PostgreSQL with pgvector
docker-compose up -d postgres

# Verify it's running
docker ps | grep postgres
```

**4. Create Directory Structure**

```bash
mkdir -p src/ingestion src/retrieval src/services src/types
mkdir -p docs scripts
touch src/app.ts
```

---

### In-Class Activities

#### Activity 1.1: Document Loader

**Goal**: Build a document loader that reads various file types.

**Step 1**: Create `src/ingestion/loader.ts`

**Step 2**: Implement loading for .txt, .md, and .pdf files

**Step 3**: Test with sample documents

**Checkpoint**:
```bash
npx ts-node -e "
import loader from './src/ingestion/loader';
const doc = await loader.loadFile('./docs/sample.txt');
console.log('Loaded:', doc.id, doc.content.length);
"
```

✅ Expected output: "Loaded: sample.txt 1234"

**Common Pitfalls**:
- PDF parsing requires additional dependencies
- File paths must be absolute or relative to project root
- Large files may cause memory issues

---

#### Activity 1.2: Text Chunker

**Goal**: Implement recursive text chunking.

**Step 1**: Create `src/ingestion/chunker.ts`

**Step 2**: Implement recursive chunking with separators

**Step 3**: Test with different chunk sizes

**Checkpoint**:
```typescript
const chunks = await chunker.chunkDocument(doc);
console.log(`Created ${chunks.length} chunks`);
```

✅ Expected output: "Created 5 chunks" (or appropriate number)

**Troubleshooting**:
- Ensure chunk size > overlap
- Minimum chunk size prevents tiny chunks
- Check that separators are properly ordered

---

#### Activity 1.3: Embedding Service

**Goal**: Generate embeddings using OpenAI.

**Step 1**: Create `src/ingestion/embedder.ts`

**Step 2**: Implement batch embedding

**Step 3**: Handle rate limits and errors

**Checkpoint**:
```typescript
const embedding = await embedder.embedText('Hello world');
console.log('Embedding length:', embedding.length);
```

✅ Expected output: "Embedding length: 1536"

**Troubleshooting**:
- Verify OpenAI API key is set
- Check network connectivity
- Ensure text is not empty

---

#### Activity 1.4: Vector Database

**Goal**: Set up and use pgvector.

**Step 1**: Create `src/services/vector-db.ts`

**Step 2**: Implement store and search functions

**Step 3**: Test with sample data

**Checkpoint**:
```bash
npx ts-node -e "
import vectorDB from './src/services/vector-db';
const health = await vectorDB.healthCheck();
console.log('DB health:', health);
"
```

✅ Expected output: "DB health: true"

---

#### Activity 1.5: Complete RAG Pipeline

**Goal**: Build the complete RAG pipeline.

**Step 1**: Create `src/retrieval/retriever.ts`

**Step 2**: Create `src/retrieval/generator.ts`

**Step 3**: Create `src/retrieval/pipeline.ts`

**Step 4**: Create `src/app.ts` with interactive mode

**Checkpoint**:
```bash
npm start -- --ingest=./docs
npm start -- --query="What is RAG?"
```

✅ Expected output: A coherent answer about RAG

---

### Post-Class Assignments

#### Homework 1.1: Add CSV Support

Modify the document loader to support CSV files. Convert CSV to markdown tables for better LLM understanding.

```typescript
// Hint: Add to loader.ts
case 'csv':
  content = await this.loadCSV(filePath);
  break;
```

#### Homework 1.2: Custom Chunking Strategy

Implement a semantic chunking strategy that splits on paragraph boundaries and sentences.

#### Homework 1.3: Metadata Enrichment

Add metadata to chunks including:
- Document title
- Section headers
- Page numbers (for PDFs)
- Timestamps

---

### Self-Assessment

**Check your understanding:**

1. What is RAG and why is it needed?
2. Explain the three stages of the RAG pipeline.
3. What is the purpose of chunking?
4. How do embeddings capture meaning?
5. What is cosine similarity?
6. How do you store and retrieve vectors?
7. What is a similarity threshold?
8. How does the generator use retrieved context?

**Answers at end of manual.**

---

## Part 2: Advanced Retrieval & Defense

### Part 2 Overview

**Objective**: Improve retrieval quality with hybrid search, reranking, and governance.

**Duration**: 3-4 hours

**Key Skills**:
- BM25 lexical search
- Reciprocal Rank Fusion
- Cross-encoder reranking
- Metadata governance
- Performance optimization

---

### Pre-Class Preparation

**1. Install Additional Dependencies**

```bash
npm install bm25js @xenova/transformers
npm install -D @types/bm25js
```

**2. Understand the Limitations**

Review your Part 1 RAG system. Note cases where:
- Semantic search missed exact matches
- Retrieved documents were not relevant
- Users accessed documents they shouldn't see

---

### In-Class Activities

#### Activity 2.1: BM25 Implementation

**Goal**: Implement lexical search with BM25.

**Step 1**: Create `src/retrieval/lexical.ts`

**Step 2**: Implement BM25 index management

**Step 3**: Test with keyword queries

**Checkpoint**:
```typescript
const results = await lexicalSearch.search('FDA approval');
console.log(`Found ${results.length} lexical matches`);
```

✅ Expected output: "Found 3 lexical matches"

---

#### Activity 2.2: RRF Fusion

**Goal**: Combine dense and lexical search results.

**Step 1**: Create `src/retrieval/fusion.ts`

**Step 2**: Implement RRF algorithm

**Step 3**: Test with sample results

**Checkpoint**:
```typescript
const fused = fusion.fuse([denseResults, lexicalResults]);
console.log(`Fused ${fused.length} results`);
```

✅ Expected output: "Fused 5 results"

---

#### Activity 2.3: Cross-Encoder Reranking

**Goal**: Implement cross-encoder reranking.

**Step 1**: Create `src/retrieval/reranker.ts`

**Step 2**: Load and use cross-encoder model

**Step 3**: Integrate with retrieval pipeline

**Checkpoint**:
```typescript
const reranked = await reranker.rerank(query, results);
console.log('Reranked scores:', reranked.map(r => r.rerankScore));
```

---

#### Activity 2.4: Metadata Governance

**Goal**: Implement access control.

**Step 1**: Create `src/retrieval/governance.ts`

**Step 2**: Implement role-based filtering

**Step 3**: Integrate with retrieval

**Checkpoint**:
```typescript
const filtered = governance.applyGovernance(results, userContext);
console.log(`Filtered to ${filtered.length} results`);
```

---

#### Activity 2.5: Complete Hybrid Retriever

**Goal**: Combine all components.

**Step 1**: Update `src/retrieval/retriever.ts`

**Step 2**: Add configuration options

**Step 3**: Test all combinations

**Checkpoint**:
```bash
# Test different configurations
npm start -- --query="RAG benefits" --hybrid
npm start -- --query="RAG benefits" --rerank
```

---

### Post-Class Assignments

#### Homework 2.1: Custom RRF Weights

Experiment with different weights for dense and lexical results. Which combination works best for your documents?

#### Homework 2.2: Performance Comparison

Create a benchmark that compares:
1. Dense only
2. Lexical only
3. Hybrid
4. Hybrid + Reranking

Measure speed and accuracy.

#### Homework 2.3: Access Control Implementation

Add a simple role-based access control with:
- public: sees only public documents
- internal: sees public + internal
- admin: sees all

---

### Self-Assessment

**Check your understanding:**

1. What are the limitations of pure semantic search?
2. How does BM25 work?
3. What is Reciprocal Rank Fusion?
4. Why is reranking needed?
5. How do cross-encoders differ from bi-encoders?
6. What is metadata governance?
7. How do you combine multiple search methods?
8. What are the trade-offs between speed and accuracy?

---

## Part 3: Orchestrating the Loop — LangChain.js

### Part 3 Overview

**Objective**: Professionalize the RAG system with LangChain.js.

**Duration**: 3-4 hours

**Key Skills**:
- LangChain.js runnables
- Provider abstraction
- Prompt templates
- Structured output
- Telemetry and monitoring

---

### Pre-Class Preparation

**1. Install LangChain.js**

```bash
npm install @langchain/core langchain @langchain/openai @langchain/anthropic
npm install @langchain/langsmith
```

**2. Understand Runnables**

Runnables provide a standard interface for all operations:
- `invoke()`: Single input → single output
- `stream()`: Single input → stream of outputs
- `batch()`: Multiple inputs → multiple outputs
- `pipe()`: Chain runnables together

---

### In-Class Activities

#### Activity 3.1: Base Runnables

**Goal**: Create reusable runnables.

**Step 1**: Create `src/orchestration/runnables/base.ts`

**Step 2**: Implement embedding runnable

**Step 3**: Implement search runnable

**Step 4**: Implement chat model runnable

**Checkpoint**:
```typescript
const embeddingRunnable = createEmbeddingRunnable();
const embedding = await embeddingRunnable.invoke('Hello world');
console.log('Embedding length:', embedding.length);
```

✅ Expected output: "Embedding length: 1536"

---

#### Activity 3.2: Pipeline Composition

**Goal**: Build a complete pipeline with `.pipe()`.

**Step 1**: Create `src/orchestration/runnables/rag-pipeline.ts`

**Step 2**: Compose search and generation

**Step 3**: Add logging and error handling

**Checkpoint**:
```typescript
const pipeline = createRAGPipeline();
const result = await pipeline.invoke({ query: 'What is RAG?' });
console.log('Answer:', result.answer);
```

---

#### Activity 3.3: Prompt Templates

**Goal**: Create reusable prompts.

**Step 1**: Create `src/orchestration/prompts.ts`

**Step 2**: Implement multiple templates

**Step 3**: Add template selection

**Checkpoint**:
```typescript
const prompt = await promptManager.buildPrompt(
  PromptStyle.DETAILED,
  { context, question }
);
console.log('Prompt length:', prompt.length);
```

---

#### Activity 3.4: Structured Output

**Goal**: Validate and parse LLM responses.

**Step 1**: Create `src/orchestration/schemas.ts`

**Step 2**: Implement Zod schemas

**Step 3**: Add output parsing

**Checkpoint**:
```typescript
const schema = RAGResponseSchema;
const parser = StructuredOutputParser.fromZodSchema(schema);
const parsed = await parser.parse(response);
console.log('Confidence:', parsed.confidence);
```

---

#### Activity 3.5: Telemetry Service

**Goal**: Implement comprehensive monitoring.

**Step 1**: Create `src/orchestration/telemetry.ts`

**Step 2**: Add tracing and metrics

**Step 3**: Integrate with pipeline

**Checkpoint**:
```typescript
const result = await orchestrator.query({
  query: 'What is RAG?',
  traceId: 'test-123',
});
console.log('Trace:', result.metadata.traceId);
```

---

### Post-Class Assignments

#### Homework 3.1: Custom Runnable

Create a custom runnable that:
1. Takes search results
2. Filters by relevance threshold
3. Returns only high-quality results

#### Homework 3.2: Provider Switching

Configure your system to use Anthropic's Claude instead of OpenAI. What changes are needed?

#### Homework 3.3: Telemetry Dashboard

Create a simple dashboard that displays:
- Query volume
- Response latency
- Error rates

---

### Self-Assessment

**Check your understanding:**

1. What is the Runnable interface?
2. How does `.pipe()` work?
3. Why are prompt templates useful?
4. What is structured output?
5. Why use Zod for validation?
6. What is telemetry?
7. How do you trace a request?
8. What metrics should you track?

---

## Part 4: From Pipelines to Agents — LangGraph.js

### Part 4 Overview

**Objective**: Build autonomous agents with LangGraph.js.

**Duration**: 3-4 hours

**Key Skills**:
- State machines
- Agent graphs
- Self-correction
- Checkpoint persistence
- Human-in-the-loop

---

### Pre-Class Preparation

**1. Install LangGraph.js**

```bash
npm install @langchain/langgraph
```

**2. Understand State Machines**

Key concepts:
- **State**: Data that persists throughout the workflow
- **Node**: Operations that modify state
- **Edge**: Transitions between nodes
- **Conditional Edge**: Branch based on state

---

### In-Class Activities

#### Activity 4.1: Agent State

**Goal**: Define typed agent state.

**Step 1**: Create `src/agent/state.ts`

**Step 2**: Define state annotations

**Step 3**: Add validation

**Checkpoint**:
```typescript
const state = createInitialState('What is RAG?');
console.log('State:', state.status);
```

✅ Expected output: "State: initialized"

---

#### Activity 4.2: Agent Graph

**Goal**: Build the complete agent graph.

**Step 1**: Create `src/agent/graph.ts`

**Step 2**: Define all nodes

**Step 3**: Add conditional edges

**Checkpoint**:
```typescript
const graph = createAgentGraph();
const result = await graph.invoke(initialState);
console.log('Result:', result.status);
```

---

#### Activity 4.3: Search Node

**Goal**: Implement the search node.

**Step 1**: Create `src/agent/nodes/search.ts`

**Step 2**: Add strategy selection

**Step 3**: Record attempts

**Checkpoint**:
```typescript
const newState = await searchNode(state);
console.log('Attempts:', newState.totalSearchAttempts);
```

---

#### Activity 4.4: Evaluate Node

**Goal**: Implement evidence evaluation.

**Step 1**: Create `src/agent/nodes/evaluate.ts`

**Step 2**: Add quality scoring

**Step 3**: Extract evidence

**Checkpoint**:
```typescript
const newState = await evaluateNode(state);
console.log('Quality:', newState.evidenceQuality);
```

---

#### Activity 4.5: Generate Node

**Goal**: Implement generation.

**Step 1**: Create `src/agent/nodes/generate.ts`

**Step 2**: Build context from evidence

**Step 3: Generate draft answer

**Checkpoint**:
```typescript
const newState = await generateNode(state);
console.log('Draft:', newState.draftAnswer);
```

---

#### Activity 4.6: Reflect Node

**Goal**: Implement self-correction.

**Step 1**: Create `src/agent/nodes/reflect.ts`

**Step 2**: Add quality assessment

**Step 3**: Improve query if needed

**Checkpoint**:
```typescript
const newState = await reflectNode(state);
console.log('Satisfactory:', newState.status === 'completed');
```

---

#### Activity 4.7: Human Approval Node

**Goal**: Implement human-in-the-loop.

**Step 1**: Create `src/agent/nodes/human-approval.ts`

**Step 2**: Add approval request

**Step 3**: Wait for response

**Checkpoint**:
```typescript
const newState = await humanApprovalNode(state);
console.log('Approved:', newState.approved);
```

---

#### Activity 4.8: Checkpoint Persistence

**Goal**: Make agents resumable.

**Step 1**: Create `src/agent/persistence.ts`

**Step 2**: Implement save/load

**Step 3**: Test resumption

**Checkpoint**:
```typescript
const checkpoint = await checkpointManager.saveCheckpoint(state);
const resumed = await checkpointManager.resumeFromCheckpoint(checkpoint.id);
console.log('Resumed state:', resumed.status);
```

---

### Post-Class Assignments

#### Homework 4.1: Custom Node

Create a new node that:
1. Takes the query
2. Checks a cache for similar questions
3. Returns cached answer if found

#### Homework 4.2: Agent Configuration

Add configurable parameters:
- Max iterations
- Evidence threshold
- Number of search results

#### Homework 4.3: Multi-Agent System

Create two agents:
1. Researcher: Finds and summarizes information
2. Validator: Checks the research for accuracy

---

### Self-Assessment

**Check your understanding:**

1. What is a state machine?
2. How does LangGraph.js work?
3. What are nodes and edges?
4. How does self-correction work?
5. Why is checkpointing useful?
6. What is human-in-the-loop?
7. How do you implement parallel execution?
8. What are conditional edges?

---

## Capstone Project

### Capstone Overview

**Objective**: Build a complete production system.

**Duration**: 4-6 hours

**Key Skills**:
- REST API development
- Async processing
- WebSocket support
- Docker deployment
- Monitoring

---

### Project Structure

```
rag-agent-system/
├── src/
│   ├── api/
│   │   ├── server.ts
│   │   ├── routes/
│   │   │   ├── queries.ts
│   │   │   ├── ingestion.ts
│   │   │   ├── checkpoints.ts
│   │   │   └── admin.ts
│   │   └── middleware/
│   │       ├── auth.ts
│   │       └── logging.ts
│   ├── workers/
│   │   ├── ingestion-worker.ts
│   │   └── hitl-worker.ts
│   ├── queues/
│   │   ├── ingestion-queue.ts
│   │   └── hitl-queue.ts
│   └── websocket/
│       ├── manager.ts
│       └── handlers.ts
├── prisma/
│   └── schema.prisma
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
└── .env.example
```

---

### In-Class Activities

#### Activity C.1: REST API

**Goal**: Build the Fastify API.

**Step 1**: Create `src/api/server.ts`

**Step 2**: Implement all routes

**Step 3**: Add Swagger documentation

**Checkpoint**:
```bash
curl http://localhost:3000/health
```

✅ Expected output: `{"status":"healthy"}`

---

#### Activity C.2: Async Processing

**Goal**: Implement BullMQ queues.

**Step 1**: Create `src/queues/ingestion-queue.ts`

**Step 2**: Create `src/workers/ingestion-worker.ts`

**Step 3**: Test job processing

**Checkpoint**:
```typescript
await ingestionQueue.add('ingest', { path: './docs' });
console.log('Job added');
```

---

#### Activity C.3: WebSocket Support

**Goal**: Add real-time updates.

**Step 1**: Create `src/websocket/manager.ts`

**Step 2**: Add subscription handling

**Step 3**: Test WebSocket connection

**Checkpoint**:
```javascript
const ws = new WebSocket('ws://localhost:3000/ws');
ws.onmessage = (event) => console.log(event.data);
```

---

#### Activity C.4: Docker Deployment

**Goal**: Containerize the application.

**Step 1**: Create `docker/Dockerfile`

**Step 2**: Create `docker-compose.yml`

**Step 3**: Test deployment

**Checkpoint**:
```bash
docker-compose up -d
docker-compose ps
```

---

### Post-Class Assignments

#### Homework C.1: Authentication

Add JWT authentication to the API.

#### Homework C.2: Rate Limiting

Implement rate limiting for API endpoints.

#### Homework C.3: Monitoring Dashboard

Create a Grafana dashboard for system metrics.

---

### Self-Assessment

**Check your understanding:**

1. Why use Fastify for the API?
2. What is BullMQ used for?
3. Why are WebSockets needed?
4. What are the benefits of Docker?
5. How do you scale the system?
6. What metrics should you monitor?
7. How do you handle errors in production?
8. What is the deployment process?

---

## Appendices

### Appendix A: Quick Reference

#### Common Commands

```bash
# Development
npm run dev                    # Start dev server
npm run build                  # Build for production
npm run test                   # Run tests

# Database
docker-compose up -d postgres  # Start database
npm run prisma:studio          # Open database UI
npm run prisma:migrate         # Run migrations

# Docker
docker-compose up -d           # Start all services
docker-compose logs -f         # View logs
docker-compose down            # Stop all services
```

#### Directory Structure Quick Reference

```
rag-agent-system/
├── src/
│   ├── agent/         # LangGraph.js agent
│   ├── api/           # Fastify API
│   ├── ingestion/     # Document ingestion
│   ├── retrieval/     # Retrieval components
│   ├── orchestration/ # LangChain.js orchestration
│   ├── services/      # Core services
│   ├── workers/       # BullMQ workers
│   └── types/         # TypeScript types
├── docker/            # Docker configuration
├── prisma/            # Database schema
└── scripts/           # Utility scripts
```

---

### Appendix B: Troubleshooting Guide

#### Common Errors and Solutions

**1. Database Connection Failed**

```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solution**:
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Start PostgreSQL
docker-compose up -d postgres

# Wait for it to be ready
sleep 5
```

**2. OpenAI API Key Missing**

```
Error: OpenAI API key not found
```

**Solution**:
```bash
# Check .env file
cat .env | grep OPENAI_API_KEY

# Or set it directly
export OPENAI_API_KEY=your_key_here
```

**3. TypeScript Compilation Errors**

```
error TS2307: Cannot find module 'some-module'
```

**Solution**:
```bash
# Install missing dependencies
npm install some-module

# Or update TypeScript
npm update typescript @types/node
```

**4. Port Already in Use**

```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution**:
```bash
# Find process using port
lsof -i :3000

# Kill it
kill -9 <PID>

# Or use a different port
PORT=3001 npm start
```

**5. Out of Memory**

```
FATAL ERROR: Reached heap limit
```

**Solution**:
```bash
# Increase memory limit
export NODE_OPTIONS="--max-old-space-size=4096"

# Or reduce batch sizes
EMBEDDING_BATCH_SIZE=50
RERANKING_BATCH_SIZE=4
```

---

### Appendix C: Performance Tuning

#### Optimizing Query Speed

**1. Reduce topK for simple queries**
```typescript
const results = await orchestrator.query({
  query: question,
  topK: 3, // Instead of 5
});
```

**2. Disable reranking for speed**
```typescript
const results = await orchestrator.query({
  query: question,
  useReranking: false,
});
```

**3. Enable caching**
```typescript
const cache = new InMemoryCache();
const model = new ChatOpenAI({ cache });
```

**4. Batch embeddings**
```typescript
const embeddings = await embedder.embedTexts(texts, {
  batchSize: 50,
});
```

#### Optimizing Memory Usage

**1. Reduce batch sizes**
```typescript
const BATCH_SIZE = 50; // Instead of 100
```

**2. Unload models when not in use**
```typescript
await reranker.unloadModel();
```

**3. Use streaming for large responses**
```typescript
const stream = await generator.generateStreaming(query, onToken);
```

**4. Implement pagination for results**
```typescript
const results = await vectorDB.similaritySearch(embedding, {
  limit: 10,
  offset: 0,
});
```

---

### Appendix D: Deployment Checklist

#### Pre-Deployment

- [ ] All tests passing
- [ ] Build successful
- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] Secrets stored securely
- [ ] SSL certificates installed
- [ ] DNS configured
- [ ] Monitoring set up

#### Deployment

- [ ] Create deployment directory
- [ ] Copy built files
- [ ] Install production dependencies
- [ ] Set up environment
- [ ] Run database migrations
- [ ] Start services
- [ ] Verify health check

#### Post-Deployment

- [ ] Health check passing
- [ ] Can execute test query
- [ ] Monitoring dashboard accessible
- [ ] Logs being collected
- [ ] Alerts configured
- [ ] Backup schedule configured

---

### Appendix E: Exercise Solutions

#### Part 1 Exercise Solutions

**Exercise 1.1: Add CSV Support**

```typescript
// src/ingestion/loader.ts
private async loadCSV(filePath: string): Promise<string> {
  const content = await fs.readFile(filePath, 'utf-8');
  const lines = content.split('\n').filter(line => line.trim());
  
  if (lines.length === 0) return '';
  
  // Parse headers
  const headers = lines[0].split(',').map(h => h.trim());
  
  // Convert to markdown table
  const rows = lines.slice(1).map(line => 
    line.split(',').map(c => c.trim())
  );
  
  const table = [
    '| ' + headers.join(' | ') + ' |',
    '| ' + headers.map(() => '---').join(' | ') + ' |',
    ...rows.map(row => '| ' + row.join(' | ') + ' |'),
  ];
  
  return table.join('\n');
}
```

**Exercise 1.2: Semantic Chunking**

```typescript
// src/ingestion/chunker.ts
private chunkSemantic(text: string): string[] {
  const paragraphs = text.split('\n\n');
  const chunks: string[] = [];
  let current = '';
  
  for (const para of paragraphs) {
    if (current.length + para.length > this.chunkSize) {
      if (current) chunks.push(current.trim());
      
      // Split paragraph by sentences
      const sentences = para.match(/[^.!?]+[.!?]+/g) || [para];
      current = '';
      
      for (const sentence of sentences) {
        if (current.length + sentence.length > this.chunkSize) {
          if (current) chunks.push(current.trim());
          current = sentence;
        } else {
          current += (current ? ' ' : '') + sentence;
        }
      }
    } else {
      current += (current ? '\n\n' : '') + para;
    }
  }
  
  if (current) chunks.push(current.trim());
  return chunks;
}
```

#### Part 2 Exercise Solutions

**Exercise 2.1: Custom RRF Weights**

```typescript
// src/retrieval/fusion.ts
fuseWeighted(
  denseResults: SearchResult[],
  lexicalResults: SearchResult[],
  weightDense: number = 0.5,
  weightLexical: number = 0.5
): SearchResult[] {
  // Normalize weights
  const total = weightDense + weightLexical;
  const wDense = weightDense / total;
  const wLexical = weightLexical / total;
  
  // Calculate weighted RRF scores
  const scores = new Map<string, number>();
  const K = 60;
  
  denseResults.forEach((r, i) => {
    const score = wDense * (1 / (K + i + 1));
    scores.set(r.chunk.id, (scores.get(r.chunk.id) || 0) + score);
  });
  
  lexicalResults.forEach((r, i) => {
    const score = wLexical * (1 / (K + i + 1));
    scores.set(r.chunk.id, (scores.get(r.chunk.id) || 0) + score);
  });
  
  // Sort and return
  return Array.from(scores.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, this.topK)
    .map(([id]) => this.getDocument(id));
}
```

---

### Appendix F: Self-Assessment Answers

#### Part 1 Answers

1. **What is RAG?** RAG (Retrieval-Augmented Generation) is a technique that enhances LLMs by providing relevant context from external knowledge sources at query time.

2. **Three stages:** 
   - Ingestion: Load, chunk, embed, and store documents
   - Retrieval: Embed query, search for relevant documents
   - Generation: Combine context and query, generate response

3. **Purpose of chunking:** To break documents into manageable pieces that fit within context windows while preserving meaning.

4. **Embeddings capture meaning** by converting text to vectors where similar concepts have similar vectors.

5. **Cosine similarity** measures the angle between vectors, with 1 being identical direction and 0 being orthogonal.

6. **Store and retrieve vectors** using vector databases like pgvector with similarity search operations.

7. **Similarity threshold** filters out results below a certain relevance score.

8. **Generator uses context** by formatting retrieved chunks into a prompt and asking the LLM to answer based only on that context.

---

## Glossary

### A
**Agent**: An autonomous system that uses an LLM to plan, execute actions, observe results, and iterate toward a goal.

**ANN (Approximate Nearest Neighbor)** : Algorithm for fast similarity search in high-dimensional spaces.

### B
**BM25**: A ranking function for lexical search based on term frequency and document length.

**BullMQ**: Redis-based job queue for handling background tasks.

### C
**Chunking**: Breaking documents into smaller pieces for embedding and retrieval.

**Cosine Similarity**: Measure of similarity between two vectors based on the cosine of the angle between them.

**Cross-Encoder**: A model that processes query and document together for accurate relevance scoring.

### D
**Dense Retrieval**: Search using vector embeddings and similarity metrics.

**Document Loader**: Component that reads documents from various sources (files, URLs, etc.).

### E
**Embedding**: A vector representation of text that captures semantic meaning.

**Evaluation Node**: Agent node that assesses the quality of search results.

### F
**Fastify**: High-performance web framework for Node.js.

**Fusion**: Combining results from multiple search methods (e.g., RRF).

### G
**Generation**: The process of producing an answer using an LLM with context.

**Governance**: Access control and metadata filtering for document retrieval.

### H
**HITL (Human-in-the-Loop)** : Pattern where humans provide input or approval in automated workflows.

**HNSW (Hierarchical Navigable Small World)** : Algorithm for fast approximate nearest neighbor search.

**Hybrid Search**: Combining dense (semantic) and lexical (keyword) search.

### I
**Ingestion**: The process of loading, chunking, embedding, and storing documents.

### L
**LangChain.js**: Framework for building LLM applications with composable components.

**LangGraph.js**: Extension for building stateful, cyclic agent workflows.

**Lexical Search**: Search using keyword matching (e.g., BM25).

### M
**Metadata Governance**: Filtering documents based on metadata for access control.

**Multi-Query Retrieval**: Generating and searching with multiple query formulations.

### N
**Node**: Individual operation in a LangGraph.js workflow.

### P
**pgvector**: PostgreSQL extension for vector similarity search.

**Pipeline**: Linear sequence of operations (as opposed to graph-based agents).

**Prompt Template**: Reusable, parameterized prompt format.

### R
**RAG (Retrieval-Augmented Generation)** : Technique that enhances LLMs with external context.

**Reflection**: Agent process of reviewing and improving its own work.

**Reranking**: Using a cross-encoder to refine search results.

**Retrieval**: Finding relevant documents for a query.

**RRF (Reciprocal Rank Fusion)** : Method for combining rankings from multiple search methods.

**Runnable**: LangChain.js interface for composable operations.

### S
**Semantic Search**: Search based on meaning (using embeddings).

**State Machine**: Model with defined states and transitions between them.

**Structured Output**: Validated, type-safe LLM responses using Zod schemas.

### T
**Telemetry**: Monitoring and tracing of system behavior.

**Tool**: Function that an agent can call to perform actions.

### V
**Vector Database**: Database optimized for storing and searching vectors.

### W
**WebSocket**: Protocol for real-time bidirectional communication.

### Z
**Zod**: Schema validation library for TypeScript.

---

## Final Notes### Congratulations!

You've completed the "Bridging the Gap" student manual. You now have:

1. A complete production-ready RAG system
2. Understanding of advanced retrieval techniques
3. Experience with LangChain.js orchestration
4. Skills in building LangGraph.js agents
5. Knowledge of production deployment

### Next Steps

- Deploy your system to production
- Add custom document sources
- Implement additional agent tools
- Optimize for your specific use case
- Contribute to the community

### Support

- **GitHub Issues**: Report bugs and request features
- **Discord**: Join the LangChain community
- **Stack Overflow**: Ask questions with #langchainjs

---

**Happy Building! 🚀**
