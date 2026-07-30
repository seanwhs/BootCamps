# Trainer Guide: Bridging the Gap — Enterprise RAG, Vector Databases, and Agentic Orchestration

---

## Overview

This Trainer Guide is designed to help you deliver the "Bridging the Gap" series effectively. It provides:

- **Teaching strategies**: How to present each module
- **Timing guidelines**: How long each section should take
- **Common pitfalls**: What students typically struggle with
- **Discussion questions**: To engage students
- **Demo scripts**: Step-by-step live demonstrations
- **Assessment**: How to evaluate student progress

---

## Trainer Preparation Checklist

### Before the Course Begins

#### Technical Setup

- [ ] **Development Environment**:
  - Install Node.js (v20+)
  - Install Docker and Docker Compose
  - Install VS Code with recommended extensions:
    - TypeScript/JavaScript
    - ESLint
    - Prettier
    - Thunder Client (API testing)

- [ ] **Cloud Services**:
  - [ ] OpenAI API key (with credits)
  - [ ] (Optional) LangSmith account for monitoring
  - [ ] (Optional) Anthropic API key for provider switching demo

- [ ] **Starter Repository**:
  - [ ] Create GitHub repository with initial skeleton
  - [ ] Ensure all starter code works
  - [ ] Test on a clean machine

- [ ] **Course Materials**:
  - [ ] Slide deck prepared
  - [ ] Student manual printed/digital
  - [ ] Student notes ready
  - [ ] References document ready
  - [ ] Code samples tested

#### Environment Verification

Run this verification script before the course:

```bash
#!/bin/bash
# verify-setup.sh

echo "Verifying development environment..."

# Check Node.js
node --version || echo "❌ Node.js not found"

# Check Docker
docker --version || echo "❌ Docker not found"
docker-compose --version || echo "❌ Docker Compose not found"

# Check OpenAI key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY not set"
else
    echo "✅ OPENAI_API_KEY set"
fi

# Check PostgreSQL
docker ps | grep postgres || echo "❌ PostgreSQL not running"

# Test project
npm install || echo "❌ npm install failed"
npm run build || echo "❌ Build failed"

echo "Verification complete!"
```

---

## Course Overview

### Total Duration

| Component | Duration |
|-----------|----------|
| Part 0: Introduction | 1 hour |
| Part 1: RAG Foundation | 4 hours |
| Part 2: Advanced Retrieval | 4 hours |
| Part 3: Orchestration | 4 hours |
| Part 4: Agents | 4 hours |
| Capstone Project | 6 hours |
| Primers (optional) | 2 hours each |
| **Total** | **~27+ hours** |

### Suggested Schedule

**Option A: 5-Day Intensive (Full-time)**
| Day | Sessions |
|-----|----------|
| Day 1 | Part 0 + Part 1 |
| Day 2 | Part 1 (continued) + Part 2 |
| Day 3 | Part 2 (continued) + Part 3 |
| Day 4 | Part 3 (continued) + Part 4 |
| Day 5 | Capstone Project |

**Option B: 10-Week Evening Course (3 hours/week)**
| Week | Topic |
|------|-------|
| Week 1 | Introduction + Setup |
| Week 2 | Part 1: Document Ingestion |
| Week 3 | Part 1: Embeddings + Vector DB |
| Week 4 | Part 1: Complete RAG |
| Week 5 | Part 2: Hybrid Search |
| Week 6 | Part 2: Reranking + Governance |
| Week 7 | Part 3: LangChain.js Runnables |
| Week 8 | Part 3: Telemetry + Orchestration |
| Week 9 | Part 4: LangGraph.js Agents |
| Week 10 | Capstone Project |

---

## Part 0: Introduction

### Key Learning Objectives
- Understand the problem RAG solves
- See the complete system architecture
- Understand the learning journey
- Set up the development environment

### Teaching Strategy

#### Hook (10 min)
- **Start with a demo**: Show a simple LLM hallucinating vs. RAG providing accurate answers
- **Ask the class**: "What's the difference between these two responses?"

#### The Problem (15 min)
- **Interactive discussion**: "What happens when you ask an LLM about current events?"
- **Real-world examples**: Customer support, legal research, technical documentation

#### Architecture Overview (15 min)
- **Use the analogy**: "Think of RAG like a research assistant with a library card"
- **Draw the pipeline**: Ingestion → Retrieval → Generation

#### Setup (20 min)
- **Live coding**: Walk through the setup step by step
- **Check student progress**: Everyone should have a working environment

### Common Student Questions

**Q: "Why not just fine-tune the model?"**
A: Fine-tuning is expensive, requires expertise, and doesn't handle dynamic data. RAG is cheaper, easier, and works with changing data.

**Q: "Do I need to learn Python?"**
A: No! This series uses TypeScript/Node.js throughout.

**Q: "What if I don't have an OpenAI API key?"**
A: You can use open-source models with Transformers.js for local development.

### Demo Script

```bash
# 1. Show project structure
tree rag-agent-system

# 2. Show environment variables
cat .env.example

# 3. Start services
docker-compose up -d postgres

# 4. Show health check
curl http://localhost:3000/health

# 5. Show interactive mode (preview)
npm start -- --interactive
```

---

## Part 1: The Context Deficit — Grounding Models with RAG

### Key Learning Objectives
- Build a document loader for multiple file types
- Implement recursive text chunking
- Generate embeddings with OpenAI
- Set up pgvector database
- Perform similarity search
- Build a complete RAG pipeline

### Teaching Strategy

#### Part 1.1: Document Loading (45 min)

**Before you teach**:
- Prepare sample documents (.txt, .md, .pdf)
- Test loading on your machine

**Presentation (15 min)**:
- Show the DocumentLoader class
- Explain file type handling
- Demonstrate error handling

**Live Coding (20 min)**:
```typescript
// Build loader.ts from scratch
const doc = await loader.loadFile('./docs/sample.txt');
console.log(doc);
```

**Exercise (10 min)**:
- Add support for a new file type (e.g., CSV)
- **Solution**: See Student Manual Appendix E

#### Part 1.2: Chunking (45 min)

**Before you teach**:
- Prepare a long document for chunking demo
- Show different chunk sizes visually

**Presentation (10 min)**:
- Why chunking matters (visual comparison)
- Different chunking strategies

**Live Coding (20 min)**:
```typescript
// Build chunker.ts
const chunks = await chunker.chunkDocument(doc);
console.log(`Created ${chunks.length} chunks`);
```

**Exercise (15 min)**:
- Try different chunk sizes and observe results
- **Key insight**: Find the "goldilocks" chunk size

#### Part 1.3: Embeddings (45 min)

**Before you teach**:
- Have OpenAI API key ready
- Understand embedding dimensions

**Presentation (15 min)**:
- What embeddings are (visual analogy)
- How OpenAI generates embeddings
- Cost considerations

**Live Coding (20 min)**:
```typescript
// Build embedder.ts
const embedding = await embedder.embedText('Hello world');
console.log(`Embedding length: ${embedding.length}`);
```

**Exercise (10 min)**:
- Embed multiple texts and compare similarity

#### Part 1.4: Vector Database (45 min)

**Before you teach**:
- PostgreSQL + pgvector ready
- Understand vector indexes

**Presentation (10 min)**:
- Why use a vector database?
- How pgvector works
- Index types (HNSW, IVFFlat)

**Live Coding (20 min)**:
```typescript
// Build vector-db.ts
const results = await vectorDB.similaritySearch(queryEmbedding, 5);
console.log(results);
```

**Exercise (15 min)**:
- Try different similarity thresholds

#### Part 1.5: Complete Pipeline (45 min)

**Before you teach**:
- All previous components working
- Sample documents ready

**Presentation (10 min)**:
- How all components fit together

**Live Coding (20 min)**:
```typescript
// Build pipeline.ts
const response = await pipeline.query('What is RAG?');
console.log(response.answer);
```

**Exercise (15 min)**:
- Try different queries
- Debug retrieval issues

### Common Student Pitfalls

| Pitfall | Solution |
|---------|----------|
| Chunk size too large | Start with 1000 characters |
| Missing OpenAI key | Check .env file |
| PostgreSQL not running | `docker-compose up -d postgres` |
| Empty search results | Lower similarity threshold |
| Slow queries | Check indexes, reduce topK |

### Assessment

**Checkpoint Questions**:
1. What are the three stages of the RAG pipeline?
2. Why is chunking important?
3. How do embeddings capture meaning?
4. What is cosine similarity?
5. How does the generator use context?

**Exercise Solutions**:
See Student Manual Appendix E.

---

## Part 2: Advanced Retrieval & Defense

### Key Learning Objectives
- Implement BM25 lexical search
- Perform RRF fusion
- Add cross-encoder reranking
- Implement metadata governance
- Combine everything into hybrid retrieval

### Teaching Strategy

#### Part 2.1: BM25 Lexical Search (45 min)

**Before you teach**:
- Understand BM25 formula
- Have sample documents with keywords

**Presentation (15 min)**:
- What is BM25? (formula explained)
- Why lexical search matters
- BM25 vs. TF-IDF

**Live Coding (20 min)**:
```typescript
// Build lexical.ts
const results = await lexicalSearch.search('FDA approval');
console.log(results);
```

**Exercise (10 min)**:
- Try different queries
- Compare with dense search

#### Part 2.2: RRF Fusion (45 min)

**Before you teach**:
- Understand RRF math
- Prepare results from both search methods

**Presentation (15 min)**:
- Why combine rankings?
- How RRF works (formula)
- Standard constant (k=60)

**Live Coding (20 min)**:
```typescript
// Build fusion.ts
const fused = fusion.fuse([denseResults, lexicalResults]);
console.log(fused);
```

**Exercise (10 min)**:
- Try different weights
- Observe effect on ranking

#### Part 2.3: Cross-Encoder Reranking (45 min)

**Before you teach**:
- Understand cross-encoder vs. bi-encoder
- Have model loaded

**Presentation (15 min)**:
- Bi-encoder vs. Cross-encoder
- Why reranking improves results
- Model selection

**Live Coding (20 min)**:
```typescript
// Build reranker.ts
const reranked = await reranker.rerank(query, results);
console.log(reranked);
```

**Exercise (10 min)**:
- Compare accuracy with/without reranking

#### Part 2.4: Metadata Governance (45 min)

**Before you teach**:
- Understand access control concepts

**Presentation (15 min)**:
- Why governance matters
- Access level patterns
- Metadata filtering

**Live Coding (20 min)**:
```typescript
// Build governance.ts
const filtered = governance.applyGovernance(results, userContext);
console.log(filtered);
```

**Exercise (10 min)**:
- Implement role-based filtering

#### Part 2.5: Complete Hybrid Retriever (45 min)

**Before you teach**:
- All components working

**Presentation (10 min)**:
- How all components integrate

**Live Coding (20 min)**:
```typescript
// Update retriever.ts
const results = await retriever.retrieve(query, {
  useHybrid: true,
  useReranking: true,
});
```

**Exercise (15 min)**:
- Test all combinations
- Performance comparison

### Common Student Pitfalls

| Pitfall | Solution |
|---------|----------|
| BM25 index stale | Auto-refresh every 5 min |
| RRF weights unbalanced | Start with equal weights |
| Reranking too slow | Only rerank top 10-20 |
| Governance too strict | Start with broad filters |
| Duplicate results | Deduplicate before fusion |

### Assessment

**Checkpoint Questions**:
1. What are the limitations of semantic search?
2. How does BM25 work?
3. What is RRF and why use it?
4. How does cross-encoder reranking work?
5. What is metadata governance?

---

## Part 3: Orchestrating the Loop — LangChain.js

### Key Learning Objectives
- Understand LangChain.js runnables
- Build composable pipelines
- Use prompt templates
- Implement structured output
- Add telemetry
- Create complete orchestrator

### Teaching Strategy

#### Part 3.1: Runnables (45 min)

**Before you teach**:
- Understand Runnable interface
- Have LangChain.js installed

**Presentation (15 min)**:
- What are Runnables?
- The Runnable interface
- `.pipe()` composition

**Live Coding (20 min)**:
```typescript
// Build base.ts
const embeddingRunnable = createEmbeddingRunnable();
const embedding = await embeddingRunnable.invoke('Hello');
```

**Exercise (10 min)**:
- Create a custom runnable

#### Part 3.2: Pipeline Composition (45 min)

**Before you teach**:
- Understand pipeline patterns

**Presentation (15 min)**:
- Sequential composition
- Branching
- Error handling

**Live Coding (20 min)**:
```typescript
// Build rag-pipeline.ts
const pipeline = createRAGPipeline();
const result = await pipeline.invoke({ query: 'What is RAG?' });
```

**Exercise (10 min)**:
- Add a custom step to the pipeline

#### Part 3.3: Prompt Templates (45 min)

**Before you teach**:
- Understand prompt engineering

**Presentation (15 min)**:
- Why prompt templates?
- Different prompt styles
- Template inheritance

**Live Coding (20 min)**:
```typescript
// Build prompts.ts
const prompt = await promptManager.buildPrompt(
  PromptStyle.DETAILED,
  { context, question }
);
```

**Exercise (10 min)**:
- Create a custom prompt style

#### Part 3.4: Structured Output (45 min)

**Before you teach**:
- Understand Zod schemas

**Presentation (15 min)**:
- Why structured output?
- Zod validation
- Output parsers

**Live Coding (20 min)**:
```typescript
// Build schemas.ts
const schema = RAGResponseSchema;
const parser = StructuredOutputParser.fromZodSchema(schema);
const parsed = await parser.parse(response);
```

**Exercise (10 min)**:
- Create a custom schema

#### Part 3.5: Telemetry (45 min)

**Before you teach**:
- Understand monitoring concepts

**Presentation (15 min)**:
- Why telemetry?
- Traces, metrics, events
- Distributed tracing

**Live Coding (20 min)**:
```typescript
// Build telemetry.ts
const traceId = telemetry.startTrace('Query');
// ... do work ...
telemetry.endTrace(traceId);
```

**Exercise (10 min)**:
- Add telemetry to a component

#### Part 3.6: Orchestrator (45 min)

**Before you teach**:
- All components ready

**Presentation (10 min)**:
- How orchestrator integrates everything

**Live Coding (20 min)**:
```typescript
// Build orchestrator.ts
const response = await orchestrator.query({
  query: 'What is RAG?'
});
```

**Exercise (15 min)**:
- Test orchestrator with different configurations

### Common Student Pitfalls

| Pitfall | Solution |
|---------|----------|
| Runnable type errors | Use proper type annotations |
| Missing telemetry | Add to all critical paths |
| No fallbacks | Use `.withFallbacks()` |
| Provider switching issues | Use provider-agnostic runnables |
| Memory leaks | Unload models when done |

### Assessment

**Checkpoint Questions**:
1. What is the Runnable interface?
2. How does `.pipe()` work?
3. Why use prompt templates?
4. What is structured output?
5. Why use telemetry?

---

## Part 4: From Pipelines to Agents — LangGraph.js

### Key Learning Objectives
- Understand LangGraph.js state machines
- Build agent graphs
- Implement nodes
- Add self-correction
- Use checkpoint persistence
- Implement HITL

### Teaching Strategy

#### Part 4.1: State Machines (45 min)

**Before you teach**:
- Understand state machine concepts
- Have LangGraph.js installed

**Presentation (15 min)**:
- What are state machines?
- States, nodes, edges
- Conditional edges

**Live Coding (20 min)**:
```typescript
// Build state.ts
const state = createInitialState('What is RAG?');
console.log(state.status);
```

**Exercise (10 min)**:
- Define a custom state

#### Part 4.2: Agent Graph (45 min)

**Before you teach**:
- Understand graph patterns

**Presentation (15 min)**:
- Node design patterns
- Edge types
- Graph compilation

**Live Coding (20 min)**:
```typescript
// Build graph.ts
const graph = createAgentGraph();
const result = await graph.invoke(state);
```

**Exercise (10 min)**:
- Add a new node to the graph

#### Part 4.3: Nodes Implementation (90 min)

**Before you teach**:
- Understand each node's purpose

**Presentation (20 min)**:
- Search node: Strategy selection
- Evaluate node: Quality scoring
- Generate node: Draft creation
- Reflect node: Self-correction
- HITL node: Human approval

**Live Coding (40 min)**:
```typescript
// Build each node
// search.ts, evaluate.ts, generate.ts, reflect.ts, human-approval.ts
```

**Exercise (30 min)**:
- Enhance a node with custom logic

#### Part 4.4: Checkpoints (45 min)

**Before you teach**:
- Understand persistence patterns

**Presentation (15 min)**:
- Why checkpointing?
- Save/restore patterns
- Resume workflows

**Live Coding (20 min)**:
```typescript
// Build persistence.ts
const checkpoint = await checkpointManager.saveCheckpoint(state);
const resumed = await checkpointManager.resumeFromCheckpoint(checkpoint.id);
```

**Exercise (10 min)**:
- Test resumption

#### Part 4.5: Parallel Execution (45 min)

**Before you teach**:
- Understand concurrency patterns

**Presentation (15 min)**:
- Fan-out patterns
- Timeouts
- Cancellation

**Live Coding (20 min)**:
```typescript
// Build parallel.ts
const results = await parallelWithTimeout(tasks, 30000);
```

**Exercise (10 min)**:
- Implement parallel search

### Common Student Pitfalls

| Pitfall | Solution |
|---------|----------|
| Infinite loops | Set maxIterations |
| State mutation bugs | Use immutable updates |
| HITL timeout | Set reasonable timeout |
| Checkpoint corruption | Validate state before save |
| Parallel execution race conditions | Use Promise.allSettled |

### Assessment

**Checkpoint Questions**:
1. What is a state machine?
2. How does LangGraph.js work?
3. What is self-correction?
4. Why use checkpoints?
5. What is HITL?

---

## Capstone Project

### Key Learning Objectives
- Build REST API
- Implement async processing
- Add WebSocket support
- Containerize with Docker
- Configure monitoring

### Teaching Strategy

#### Part C.1: REST API (90 min)

**Before you teach**:
- Understand Fastify
- Have route definitions ready

**Presentation (20 min)**:
- API design patterns
- Route definitions
- Validation
- Error handling

**Live Coding (40 min)**:
```typescript
// Build server.ts, routes/
const server = createServer();
await server.listen({ port: 3000 });
```

**Exercise (30 min)**:
- Add a new endpoint

#### Part C.2: Async Processing (60 min)

**Before you teach**:
- Understand BullMQ
- Have Redis running

**Presentation (15 min)**:
- Queue patterns
- Worker design
- Job monitoring

**Live Coding (25 min)**:
```typescript
// Build queues/, workers/
const job = await ingestionQueue.add('ingest', { path });
```

**Exercise (20 min)**:
- Implement a new worker

#### Part C.3: WebSocket (45 min)

**Before you teach**:
- Understand WebSocket protocol

**Presentation (10 min)**:
- Real-time updates
- Connection management
- Event broadcasting

**Live Coding (20 min)**:
```typescript
// Build websocket/
wsManager.broadcast('progress', { status: 'processing' });
```

**Exercise (15 min)**:
- Implement progress updates

#### Part C.4: Docker (60 min)

**Before you teach**:
- Understand Docker
- Have Docker installed

**Presentation (15 min)**:
- Dockerfile patterns
- Multi-stage builds
- Docker Compose

**Live Coding (25 min)**:
```dockerfile
# Build Dockerfile, docker-compose.yml
docker-compose up -d
```

**Exercise (20 min)**:
- Scale services

### Common Student Pitfalls

| Pitfall | Solution |
|---------|----------|
| Connection pool exhaustion | Increase pool size |
| Queue backlog | Scale workers |
| Memory issues | Reduce batch sizes |
| Port conflicts | Use different ports |
| Volume permissions | Check user/group |

### Assessment

**Checkpoint Questions**:
1. Why use Fastify?
2. What is BullMQ used for?
3. Why WebSockets?
4. What are Docker benefits?
5. How to scale the system?

---

## Trainer Tips

### Engagement Strategies

1. **Start with Why**: Always explain why a concept matters before teaching it
2. **Live Coding**: Write code in front of students (mistakes and all!)
3. **Pair Programming**: Have students work in pairs
4. **Regular Checkpoints**: Stop every 15-20 minutes to verify understanding
5. **Debug Together**: Share common errors and solve them as a group

### Handling Questions

| Question Type | Strategy |
|---------------|----------|
| "Why not X?" | Compare and contrast, acknowledge trade-offs |
| "I got an error" | Debug together, share solution |
| "What about production?" | Cover in Capstone, share best practices |
| "How does this compare?" | Use analogies, show examples |

### Pace Management

**Too Fast?**
- [ ] More exercises
- [ ] Additional demos
- [ ] Pair programming
- [ ] Written reflection

**Too Slow?**
- [ ] Skip optional sections
- [ ] More code-along
- [ ] Advanced exercises
- [ ] Preview next parts

### Classroom Setup

**Physical Setup**:
- Projector for slides and demos
- Good internet connection
- Power outlets for everyone
- Whiteboard for diagrams

**Digital Setup**:
- Shared repository
- Communication channel (Slack/Discord)
- Code sharing tool (CodePen/Codesandbox)
- Screen sharing ready

---

## Assessment Rubric

### Part 1: RAG Foundation

| Criteria | Excellent | Proficient | Developing | Needs Work |
|----------|-----------|------------|------------|------------|
| Document Loading | Handles 3+ formats | Handles 2 formats | Handles 1 format | Cannot load |
| Chunking | Multiple strategies | One strategy | Chunks too small/large | No chunking |
| Embeddings | Batched, error handled | Works | Slow | Fails |
| Vector Search | Indexed, fast | Works | Slow | Fails |
| Pipeline | Complete, robust | Works | Partial | Broken |

### Part 2: Advanced Retrieval

| Criteria | Excellent | Proficient | Developing | Needs Work |
|----------|-----------|------------|------------|------------|
| BM25 | Auto-refresh | Manual refresh | Setup issue | Not working |
| RRF | Weighted | Standard | Partial | Not working |
| Reranking | Fast, accurate | Works | Slow | Not working |
| Governance | Multi-role | Single role | Setup issue | Not working |

### Part 3: Orchestration

| Criteria | Excellent | Proficient | Developing | Needs Work |
|----------|-----------|------------|------------|------------|
| Runnables | Custom, composed | Standard | Setup issue | Not working |
| Pipelines | Complex | Simple | Broken | Not built |
| Prompt Templates | Multi-style | Single | Setup issue | Not working |
| Structured Output | Custom schema | Standard | Partial | Not working |
| Telemetry | Complete | Basic | Partial | Not working |

### Part 4: Agents

| Criteria | Excellent | Proficient | Developing | Needs Work |
|----------|-----------|------------|------------|------------|
| State Machine | Complex | Simple | Setup issue | Not working |
| Graph | All nodes | 3+ nodes | 1-2 nodes | Broken |
| Self-Correction | Works well | Basic | Setup issue | Not working |
| Checkpoints | Reliable | Works | Partial | Not working |
| HITL | Full workflow | Basic | Setup issue | Not working |

### Capstone Project

| Criteria | Excellent | Proficient | Developing | Needs Work |
|----------|-----------|------------|------------|------------|
| API | Full CRUD | Basic | Partial | Not built |
| Async | Complete | Basic | Setup issue | Not working |
| WebSocket | Real-time | Basic | Setup issue | Not working |
| Docker | Production-ready | Works | Broken | Not built |
| Monitoring | Complete | Basic | Partial | Not working |

---

## Sample Schedule (Day-by-Day)

### Day 1: Introduction + Part 1

| Time | Activity | Duration |
|------|----------|----------|
| 9:00-9:30 | Welcome + Overview | 30 min |
| 9:30-10:00 | Part 0: Introduction | 30 min |
| 10:00-10:15 | Break | 15 min |
| 10:15-11:00 | Part 1.1: Document Loading | 45 min |
| 11:00-11:45 | Part 1.2: Chunking | 45 min |
| 11:45-12:30 | Lunch | 45 min |
| 12:30-13:15 | Part 1.3: Embeddings | 45 min |
| 13:15-14:00 | Part 1.4: Vector DB | 45 min |
| 14:00-14:15 | Break | 15 min |
| 14:15-15:00 | Part 1.5: Complete Pipeline | 45 min |
| 15:00-15:30 | Review + Q&A | 30 min |

### Day 2: Part 2

| Time | Activity | Duration |
|------|----------|----------|
| 9:00-9:15 | Recap Day 1 | 15 min |
| 9:15-10:00 | Part 2.1: BM25 | 45 min |
| 10:00-10:45 | Part 2.2: RRF | 45 min |
| 10:45-11:00 | Break | 15 min |
| 11:00-11:45 | Part 2.3: Reranking | 45 min |
| 11:45-12:30 | Part 2.4: Governance | 45 min |
| 12:30-13:15 | Lunch | 45 min |
| 13:15-14:00 | Part 2.5: Hybrid Retriever | 45 min |
| 14:00-14:45 | Exercise | 45 min |
| 14:45-15:00 | Break | 15 min |
| 15:00-15:30 | Review + Q&A | 30 min |

### Day 3: Part 3

| Time | Activity | Duration |
|------|----------|----------|
| 9:00-9:15 | Recap Day 2 | 15 min |
| 9:15-10:00 | Part 3.1: Runnables | 45 min |
| 10:00-10:45 | Part 3.2: Pipelines | 45 min |
| 10:45-11:00 | Break | 15 min |
| 11:00-11:45 | Part 3.3: Prompt Templates | 45 min |
| 11:45-12:30 | Part 3.4: Structured Output | 45 min |
| 12:30-13:15 | Lunch | 45 min |
| 13:15-14:00 | Part 3.5: Telemetry | 45 min |
| 14:00-14:45 | Part 3.6: Orchestrator | 45 min |
| 14:45-15:00 | Break | 15 min |
| 15:00-15:30 | Review + Q&A | 30 min |

### Day 4: Part 4

| Time | Activity | Duration |
|------|----------|----------|
| 9:00-9:15 | Recap Day 3 | 15 min |
| 9:15-10:00 | Part 4.1: State Machines | 45 min |
| 10:00-10:45 | Part 4.2: Agent Graph | 45 min |
| 10:45-11:00 | Break | 15 min |
| 11:00-11:45 | Part 4.3: Nodes | 45 min |
| 11:45-12:30 | Part 4.4: Checkpoints | 45 min |
| 12:30-13:15 | Lunch | 45 min |
| 13:15-14:00 | Part 4.5: Parallel Execution | 45 min |
| 14:00-14:45 | Exercise | 45 min |
| 14:45-15:00 | Break | 15 min |
| 15:00-15:30 | Review + Q&A | 30 min |

### Day 5: Capstone

| Time | Activity | Duration |
|------|----------|----------|
| 9:00-9:15 | Recap Day 4 | 15 min |
| 9:15-10:45 | Part C.1: REST API | 90 min |
| 10:45-11:00 | Break | 15 min |
| 11:00-12:00 | Part C.2: Async Processing | 60 min |
| 12:00-12:45 | Lunch | 45 min |
| 12:45-13:30 | Part C.3: WebSocket | 45 min |
| 13:30-14:30 | Part C.4: Docker | 60 min |
| 14:30-14:45 | Break | 15 min |
| 14:45-15:30 | Final Review + Q&A | 45 min |

---

## Additional Resources for Trainers

### Recommended Reading
1. **LangChain.js Documentation**: Official docs for reference
2. **LangGraph.js Documentation**: State machine concepts
3. **pgvector Documentation**: Vector operations
4. **OpenAI Cookbook**: Embedding examples

### Sample Code
- **Starter Repo**: Link to GitHub repository with starter code
- **Solution Repo**: Link to GitHub repository with complete solutions

### Training Aids
- **Slide Deck**: Complete slide deck for all parts
- **Student Manual**: Printable PDF
- **Student Notes**: Quick reference cards
- **References Document**: External resources

### Assessment Tools
- **Quizzes**: Multiple choice for each part
- **Code Reviews**: Checklist for each exercise
- **Final Project**: Rubric for capstone

---

**[END OF TRAINER GUIDE]**

**Happy teaching! 🎓**
