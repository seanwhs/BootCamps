# Student Notes: Bridging the Gap — Enterprise RAG, Vector Databases, and Agentic Orchestration

## Overview

These student notes are designed to be your **companion reference** throughout the "Bridging the Gap" series. Unlike the detailed tutorial or the comprehensive manual, these notes are:

- **Concise**: Key concepts only, no fluff
- **Structured**: Organized by topic for quick lookup
- **Actionable**: Commands and code snippets you'll actually use
- **Reference-First**: Find what you need, when you need it

**How to use these notes**:
1. Follow along with the tutorial
2. Annotate with your own observations
3. Use as a quick reference during exercises
4. Review before each session to refresh your memory

---

## Quick Reference Card

### Essential Commands

```bash
# Development
npm run dev                    # Start dev server with hot reload
npm run build                  # Build for production
npm run test                   # Run all tests

# Database
docker-compose up -d postgres  # Start PostgreSQL
npm run setup:db              # Initialize database
npx prisma studio             # Open database UI

# Docker
docker-compose up -d          # Start all services
docker-compose logs -f        # Follow logs
docker-compose down           # Stop all services
```

### Key URLs

| Service | URL |
|---------|-----|
| API Server | http://localhost:3000 |
| Swagger Docs | http://localhost:3000/docs |
| Health Check | http://localhost:3000/health |
| pgAdmin | http://localhost:5050 |
| Prisma Studio | http://localhost:5555 |

### Environment Variables Quick Reference

```env
# Essential
OPENAI_API_KEY=sk-...           # Your OpenAI key
PGVECTOR_HOST=localhost         # Database host
PGVECTOR_DATABASE=rag_db        # Database name

# Performance
TOP_K_RETRIEVAL=5               # Number of results
CHUNK_SIZE=1000                 # Chunk size in characters
CHUNK_OVERLAP=200               # Overlap between chunks

# Features
USE_HYBRID_SEARCH=true          # Enable hybrid search
USE_RERANKING=true              # Enable reranking
ENABLE_HITL=true                # Enable human-in-the-loop
```

---

## Part 1: The Context Deficit — Grounding Models with RAG

### Part 1 Core Concepts

#### What is RAG?
- **R**etrieval **A**ugmented **G**eneration
- Enhances LLMs with external knowledge
- Three stages: Ingestion → Retrieval → Generation
- Analogy: Research assistant with a library card

#### The RAG Pipeline

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  INGESTION  │────▶│  RETRIEVAL  │────▶│ GENERATION  │
│  Load       │     │  Embed      │     │  Prompt     │
│  Chunk      │     │  Search     │     │  LLM        │
│  Embed      │     │  Rank       │     │  Respond    │
│  Store      │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Key Code Patterns

#### 1. Document Loading
```typescript
const doc = await loader.loadFile('./docs/sample.txt');
// Returns: { id, content, metadata }
```

#### 2. Chunking
```typescript
const chunks = await chunker.chunkDocument(doc);
// Returns: DocumentChunk[] with content and metadata
```

#### 3. Embedding
```typescript
const embedding = await embedder.embedText('Hello world');
// Returns: number[] with 1536 dimensions
```

#### 4. Vector Search
```typescript
const results = await vectorDB.similaritySearch(queryEmbedding, 5);
// Returns: SearchResult[] with scores
```

#### 5. Generation
```typescript
const response = await generator.generate(question, context);
// Returns: string answer
```

### Key Files to Know

| File | Purpose | Key Function |
|------|---------|--------------|
| `src/ingestion/loader.ts` | Document loading | `loadFile()`, `loadDirectory()` |
| `src/ingestion/chunker.ts` | Text chunking | `chunkDocument()` |
| `src/ingestion/embedder.ts` | Embedding generation | `embedTexts()`, `embedChunks()` |
| `src/services/vector-db.ts` | Vector database | `storeDocument()`, `similaritySearch()` |
| `src/retrieval/retriever.ts` | Retrieval | `retrieve()` |
| `src/retrieval/generator.ts` | Generation | `generate()` |
| `src/retrieval/pipeline.ts` | Complete pipeline | `query()` |

### Common Pitfalls Part 1

#### ❌ Chunk Size Too Large
- Exceeds context window
- Contains irrelevant information
- **Fix**: Reduce chunk size (500-1000 tokens)

#### ❌ No Metadata
- Can't filter or trace sources
- **Fix**: Always add source, timestamp, document type

#### ❌ Embedding Generation Fails
- OpenAI API key missing
- Rate limits exceeded
- **Fix**: Check .env, add retry logic, reduce batch size

### Quick Commands Part 1

```bash
# Run interactive mode
npm start -- --interactive

# Ingest documents
npm start -- --ingest=./docs

# Query the system
npm start -- --query="What is RAG?"
```

---

## Part 2: Advanced Retrieval & Defense

### Part 2 Core Concepts

#### Why Hybrid Search?
- **Semantic (Dense)**: Good for meaning, bad for exact terms
- **Lexical (BM25)**: Good for exact terms, bad for meaning
- **Hybrid**: Best of both worlds

#### The Hybrid Pipeline

```
                    ┌─────────────────┐
                    │  User Query     │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
    ┌─────────────────┐           ┌─────────────────┐
    │  Dense Search   │           │  Lexical Search │
    │  (Embeddings)   │           │  (BM25)         │
    └────────┬────────┘           └────────┬────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                   ┌─────────────────┐
                   │  RRF Fusion     │
                   │  (Combine Ranks)│
                   └────────┬────────┘
                             │
                             ▼
                   ┌─────────────────┐
                   │  Reranking      │
                   │  (Cross-Encoder)│
                   └────────┬────────┘
                             │
                             ▼
                   ┌─────────────────┐
                   │  Governance     │
                   │  (Filters)      │
                   └─────────────────┘
```

### Key Code Patterns

#### 1. BM25 Implementation
```typescript
const results = await lexicalSearch.search('FDA approval');
// Returns: SearchResult[] with lexical scores
```

#### 2. RRF Fusion
```typescript
const fused = fusion.fuse([denseResults, lexicalResults]);
// Returns: Combined results ranked by RRF
```

#### 3. Reranking
```typescript
const reranked = await reranker.rerank(query, results);
// Returns: Results re-ranked by cross-encoder
```

#### 4. Governance
```typescript
const filtered = governance.applyGovernance(results, userContext);
// Returns: Results filtered by access control
```

### Key Files to Know

| File | Purpose | Key Function |
|------|---------|--------------|
| `src/retrieval/lexical.ts` | BM25 search | `search()`, `refreshIndex()` |
| `src/retrieval/fusion.ts` | RRF fusion | `fuse()`, `fuseWeighted()` |
| `src/retrieval/reranker.ts` | Cross-encoder | `rerank()`, `loadModel()` |
| `src/retrieval/governance.ts` | Access control | `buildFilters()`, `applyGovernance()` |
| `src/retrieval/retriever.ts` | Hybrid retrieval | `retrieve()` (updated) |

### BM25 Parameters

```typescript
// Standard BM25 parameters
const bm25 = new BM25(docs, {
  k1: 1.2,   // Term frequency saturation
  b: 0.75,   // Document length normalization
});
```

### RRF Parameters

```typescript
const K = 60;  // Standard RRF constant
// Higher K = less influence of low-ranked documents
```

### Cross-Encoder Models

| Model | Size | Speed | Accuracy |
|-------|------|-------|----------|
| ms-marco-MiniLM-L-6-v2 | 80MB | Fast | Good |
| ms-marco-MiniLM-L-12-v2 | 120MB | Medium | Better |
| ms-marco-mpnet-base-v2 | 400MB | Slow | Best |

### Common Pitfalls Part 2

#### ❌ BM25 Index Stale
- New documents not searchable lexically
- **Fix**: Auto-refresh index every 5 minutes

#### ❌ RRF Weights Unbalanced
- One method dominates results
- **Fix**: Use equal weights or tune based on data

#### ❌ Reranking Too Slow
- Cross-encoder adds latency
- **Fix**: Only rerank top results (10-20)

### Quick Commands Part 2

```bash
# Test hybrid search
npx ts-node test-hybrid.ts

# Force BM25 index refresh
curl -X POST http://localhost:3000/api/v1/admin/index/reload

# Compare search methods
npx ts-node test-hybrid.ts --compare
```

---

## Part 3: Orchestrating the Loop — LangChain.js

### Part 3 Core Concepts

#### What is a Runnable?
- Standard interface for all operations
- `invoke()`, `stream()`, `batch()`, `pipe()`
- Composable like Unix pipes

#### Runnable Pipeline Example
```typescript
const pipeline = RunnableSequence.from([
  embedRunnable,   // Text → embedding
  searchRunnable,  // Embedding → results
  formatRunnable,  // Results → context
  generateRunnable // Context → answer
]);
```

### Key Code Patterns

#### 1. Creating Runnables
```typescript
const embeddingRunnable = Runnable.fromFunction(
  async (text: string) => await embedder.embedText(text)
);
```

#### 2. Composing with `.pipe()`
```typescript
const pipeline = embeddingRunnable
  .pipe(searchRunnable)
  .pipe(generateRunnable);
```

#### 3. Prompt Templates
```typescript
const template = PromptTemplate.fromTemplate(`
  Context: {context}
  Question: {question}
  Answer:
`);
```

#### 4. Structured Output
```typescript
const schema = z.object({
  answer: z.string(),
  confidence: z.number(),
});
const parser = StructuredOutputParser.fromZodSchema(schema);
```

### Key Files to Know

| File | Purpose | Key Function |
|------|---------|--------------|
| `src/orchestration/runnables/base.ts` | Base runnables | `createEmbeddingRunnable()` |
| `src/orchestration/runnables/rag-pipeline.ts` | Pipeline | `createRAGPipeline()` |
| `src/orchestration/prompts.ts` | Prompt templates | `buildPrompt()` |
| `src/orchestration/schemas.ts` | Zod schemas | `RAGResponseSchema` |
| `src/orchestration/telemetry.ts` | Monitoring | `startTrace()`, `recordMetric()` |
| `src/orchestration/orchestrator.ts` | Orchestration | `query()` |

### Telemetry Patterns

#### 1. Tracing
```typescript
const traceId = telemetry.startTrace('Query');
const spanId = telemetry.startSpan(traceId, 'search');
// ... do work ...
telemetry.endSpan(traceId, spanId);
telemetry.endTrace(traceId);
```

#### 2. Metrics
```typescript
telemetry.recordMetric('query.duration', durationMs, 'ms');
telemetry.recordMetric('query.results', resultCount, 'count');
```

#### 3. Events
```typescript
telemetry.recordEvent('query.complete', {
  answerLength: answer.length,
  confidence: confidence,
});
```

### Provider Switching

```typescript
// Switch from OpenAI to Anthropic
import { ChatAnthropic } from '@langchain/anthropic';

const model = new ChatAnthropic({
  model: 'claude-3-sonnet-20240229',
  temperature: 0.3,
});
```

### Common Pitfalls Part 3

#### ❌ Runnable Type Errors
- Incompatible input/output types
- **Fix**: Use generics or type assertions

#### ❌ Missing Telemetry
- Hard to debug issues
- **Fix**: Add telemetry to all critical operations

#### ❌ No Fallbacks
- Single point of failure
- **Fix**: Use `.withFallbacks()` for retries

---

## Part 4: From Pipelines to Agents — LangGraph.js

### Part 4 Core Concepts

#### Agent vs. Pipeline
| Aspect | Pipeline | Agent |
|--------|----------|-------|
| Flow | Linear | Cyclic |
| Decisions | Fixed | Dynamic |
| Adaptation | None | Self-correction |
| Human Input | No | Yes (HITL) |

#### Agent Cycle
```
Plan → Act → Observe → Reflect → (Repeat or Complete)
```

### Key Code Patterns

#### 1. State Definition
```typescript
const AgentState = Annotation.Root({
  query: Annotation<string>(),
  iteration: Annotation<number>(),
  status: Annotation<'searching' | 'evaluating' | 'generating'>(),
});
```

#### 2. Graph Construction
```typescript
const workflow = new StateGraph(AgentState)
  .addNode('search', searchNode)
  .addNode('evaluate', evaluateNode)
  .addNode('generate', generateNode)
  .addConditionalEdges('evaluate', shouldContinue)
  .addEdge('generate', END);
```

#### 3. Node Implementation
```typescript
async function searchNode(state: AgentState): Promise<Partial<AgentState>> {
  const results = await retriever.retrieve(state.query);
  return { searchResults: results, status: 'searching' };
}
```

#### 4. Conditional Routing
```typescript
function shouldContinue(state: AgentState): string {
  if (state.evidenceQuality > 0.7) return 'generate';
  if (state.iteration >= state.maxIterations) return 'generate';
  return 'search';
}
```

### Key Files to Know

| File | Purpose | Key Function |
|------|---------|--------------|
| `src/agent/state.ts` | State definitions | `AgentState`, `createInitialState()` |
| `src/agent/graph.ts` | Agent graph | `createAgentGraph()` |
| `src/agent/nodes/search.ts` | Search node | `searchNode()` |
| `src/agent/nodes/evaluate.ts` | Evaluate node | `evaluateNode()` |
| `src/agent/nodes/generate.ts` | Generate node | `generateNode()` |
| `src/agent/nodes/reflect.ts` | Reflect node | `reflectNode()` |
| `src/agent/nodes/human-approval.ts` | HITL node | `humanApprovalNode()` |
| `src/agent/persistence.ts` | Checkpoints | `saveCheckpoint()`, `resumeFromCheckpoint()` |
| `src/agent/parallel.ts` | Concurrency | `parallelWithTimeout()`, `withTimeout()` |

### Node Types

| Node | Purpose | Input | Output |
|------|---------|-------|--------|
| Search | Retrieve documents | Query | Search results |
| Evaluate | Assess relevance | Results | Evidence, quality score |
| Generate | Create answer | Evidence | Draft answer |
| Reflect | Review quality | Draft answer | Feedback, improved query |
| Human Approval | Get human input | Approval request | Approved/rejected |

### Checkpoint Persistence

```typescript
// Save checkpoint
const checkpoint = await checkpointManager.saveCheckpoint(state, {
  node: 'evaluate',
  iteration: state.iteration,
});

// Resume from checkpoint
const resumed = await checkpointManager.resumeFromCheckpoint(checkpoint.id);
```

### Parallel Execution

```typescript
// Search multiple sources in parallel
const results = await parallelWithTimeout([
  { name: 'vector', fn: () => vectorSearch(query) },
  { name: 'lexical', fn: () => lexicalSearch(query) },
  { name: 'web', fn: () => webSearch(query) },
], 30000); // 30 second timeout
```

### Common Pitfalls Part 4

#### ❌ Infinite Loops
- Agent never completes
- **Fix**: Set maxIterations, add timeout

#### ❌ State Mutation Issues
- Unexpected state changes
- **Fix**: Use immutable state updates

#### ❌ HITL Timeout
- Human never responds
- **Fix**: Set reasonable timeout, auto-continue with warning

### Quick Commands Part 4

```bash
# Run agent
npm start -- --agent --query="What is RAG?"

# Interactive agent mode
npm start -- --agent --interactive

# Resume from checkpoint
npm start -- --resume=checkpoint-id

# Test agent
npx ts-node test-agent.ts
```

---

## Capstone Project

### Capstone Core Concepts

#### Production Architecture

```
┌─────────────────────────────────────────────────────┐
│              Production System                      │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────┐    ┌──────────────┐             │
│  │  API Server  │    │  Workers     │             │
│  │  (Fastify)   │    │  (BullMQ)    │             │
│  └──────────────┘    └──────────────┘             │
│        │                    │                       │
│        └────────┬───────────┘                       │
│                 │                                   │
│         ┌───────┴────────┐                         │
│         │                │                         │
│         ▼                ▼                         │
│  ┌──────────────┐  ┌──────────────┐                │
│  │  PostgreSQL  │  │    Redis     │                │
│  │  (pgvector)  │  │  (Queues)    │                │
│  └──────────────┘  └──────────────┘                │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### Key Files to Know

| File | Purpose |
|------|---------|
| `src/api/server.ts` | Fastify server setup |
| `src/api/routes/queries.ts` | Query API endpoints |
| `src/api/routes/ingestion.ts` | Ingestion API endpoints |
| `src/api/routes/checkpoints.ts` | Checkpoint API endpoints |
| `src/api/routes/admin.ts` | Admin API endpoints |
| `src/workers/ingestion-worker.ts` | Ingestion worker |
| `src/queues/ingestion-queue.ts` | Ingestion queue |
| `src/websocket/manager.ts` | WebSocket manager |
| `prisma/schema.prisma` | Database schema |
| `docker/Dockerfile` | Docker build |
| `docker-compose.yml` | Service orchestration |

### API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/v1/queries` | Execute query |
| GET | `/api/v1/queries/stream` | Stream query |
| GET | `/api/v1/queries/history` | Query history |
| POST | `/api/v1/ingestion` | Ingest documents |
| GET | `/api/v1/ingestion/:jobId` | Job status |
| GET | `/api/v1/checkpoints` | List checkpoints |
| POST | `/api/v1/checkpoints/:id/resume` | Resume from checkpoint |
| GET | `/api/v1/admin/status` | System status |
| GET | `/health` | Health check |
| GET | `/metrics` | Metrics |
| GET | `/docs` | Swagger docs |

### Database Schema

```prisma
model Document {
  id          String   @id @default(cuid())
  content     String   @db.Text
  embedding   Unsupported("vector(1536)")?
  metadata    Json
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}

model User {
  id          String   @id @default(cuid())
  email       String   @unique
  role        String   @default("user")
  createdAt   DateTime @default(now())
}

model Query {
  id          String   @id @default(cuid())
  userId      String?  @map("user_id")
  query       String   @db.Text
  answer      String?  @db.Text
  confidence  Float?
  status      String   @default("pending")
  createdAt   DateTime @default(now())
}
```

### Docker Commands

```bash
# Build and start
docker-compose up -d

# Scale workers
docker-compose up -d --scale worker=3

# View logs
docker-compose logs -f api

# Stop
docker-compose down

# Clean volumes
docker-compose down -v
```

### Common Pitfalls Capstone

#### ❌ Database Connection Pool
- Too many connections
- **Fix**: Increase pool size, properly release connections

#### ❌ Queue Backlog
- Workers can't keep up
- **Fix**: Scale workers, reduce batch sizes

#### ❌ Memory Issues
- OOM kills container
- **Fix**: Increase memory limit, reduce batch sizes

---

## Quick Troubleshooting

### Connection Issues

```bash
# Check database
docker ps | grep postgres
PGPASSWORD=postgres psql -h localhost -U postgres -d rag_db -c "SELECT 1"

# Check Redis
redis-cli ping

# Check API
curl http://localhost:3000/health
```

### Performance Issues

```bash
# Check memory
node --print process.memoryUsage()

# Check queue depth
redis-cli llen bull:rag-queue:waiting

# Check database connections
docker exec rag_postgres psql -U postgres -c "SELECT * FROM pg_stat_activity WHERE datname='rag_db'"
```

### Debugging

```bash
# Enable debug logging
LOG_LEVEL=debug npm run dev

# Get trace details
curl http://localhost:3000/api/v1/traces/:traceId

# Check system status
curl http://localhost:3000/api/v1/admin/status
```

---

## Cheat Sheets

### Search Types Comparison

| Feature | Dense | Lexical | Hybrid + Rerank |
|---------|-------|---------|-----------------|
| Speed | Fast | Fast | Slow |
| Exact Matches | Poor | Excellent | Good |
| Synonyms | Excellent | Poor | Good |
| Accuracy | Good | Moderate | Best |
| Explainability | Low | High | Medium |

### Embedding Models

| Model | Dimensions | Speed | Use Case |
|-------|------------|-------|----------|
| text-embedding-3-small | 1536 | Fast | General |
| text-embedding-3-large | 3072 | Medium | High precision |
| all-MiniLM-L6-v2 | 384 | Very Fast | Local/dev |

### Chunking Strategies

| Strategy | Best For | Trade-offs |
|----------|----------|------------|
| Fixed Size | Simple documents | May break meaning |
| Recursive | General use | Good balance |
| Semantic | Complex text | Slower, more accurate |
| Marker-based | Structured docs | Preserves sections |

### Agent Types

| Type | Best For | Complexity |
|------|----------|------------|
| ReAct | General tasks | Medium |
| Plan-Execute | Multi-step tasks | High |
| Hierarchical | Complex domains | Very High |
| Reflection | Quality-critical | Medium |

---

## Final Checklist

### Before Each Session

- [ ] Docker running
- [ ] PostgreSQL started
- [ ] Environment variables set
- [ ] Code editor ready
- [ ] Terminal open

### After Each Session

- [ ] Save your work
- [ ] Test everything works
- [ ] Note what you learned
- [ ] Identify questions
- [ ] Review next session prep

### For Production

- [ ] Environment variables secured
- [ ] Database backed up
- [ ] Monitoring configured
- [ ] Alerts set up
- [ ] Deployment plan ready
- [ ] Rollback plan ready
- [ ] Documentation updated
- [ ] Team notified

---

## Space for Your Notes

```
─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────

─────────────────────────────────────────────────────────
```

---

**[END OF STUDENT NOTES]**

**Keep these notes handy throughout the series!**
