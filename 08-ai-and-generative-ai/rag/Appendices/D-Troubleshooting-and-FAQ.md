# Appendix D: Troubleshooting and FAQ

## Overview

This appendix provides comprehensive troubleshooting guidance and answers to frequently asked questions about the RAG Agent System. Use this as a reference when encountering issues during development, deployment, or operations.

---

## D.1 Installation and Setup Issues

### Issue: TypeScript Compilation Errors

**Symptom:** `tsc` fails with type errors

**Solutions:**

1. **Update TypeScript and dependencies:**
```bash
npm update typescript @types/node
npm install
```

2. **Check TypeScript configuration:**
```bash
# Validate tsconfig.json
npx tsc --showConfig
```

3. **Clear build cache:**
```bash
npm run clean
rm -rf node_modules/.cache
npm run build
```

4. **Common type errors and fixes:**

```typescript
// Error: Cannot find module 'langchain'
// Fix: Install missing types
npm install -D @types/langchain

// Error: Property 'x' does not exist on type 'y'
// Fix: Ensure proper imports
import { OpenAI } from 'langchain/llms/openai'; // Correct
import { OpenAI } from '@langchain/openai'; // Also correct

// Error: Cannot use import statement outside a module
// Fix: Add "type": "module" to package.json
{
  "type": "module"
}
```

### Issue: Node.js Version Incompatibility

**Symptom:** Errors about ES modules or missing features

**Solution:**

```bash
# Check Node version
node --version  # Should be 20+

# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install and use Node 20
nvm install 20
nvm use 20
```

### Issue: npm Installation Fails

**Symptom:** `npm install` fails with various errors

**Solutions:**

```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and package-lock.json
rm -rf node_modules package-lock.json

# Reinstall with verbose logging
npm install --verbose

# Use specific registry if needed
npm install --registry=https://registry.npmjs.org
```

### Issue: Environment Variables Not Loading

**Symptom:** Process.env variables are undefined

**Solutions:**

```bash
# Ensure .env file exists in root directory
ls -la .env

# Check .env file is not empty
cat .env

# Load environment manually in code
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' }); // Specify path
```

---

## D.2 Database Issues

### Issue: PostgreSQL Connection Failed

**Symptom:** `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Solutions:**

```bash
# Check if PostgreSQL is running
docker ps | grep postgres
# or
systemctl status postgresql

# Start PostgreSQL
docker-compose up -d postgres
# or
systemctl start postgresql

# Check connection details
echo $DATABASE_URL
# Should be: postgresql://user:pass@localhost:5432/rag_db

# Test connection manually
PGPASSWORD=postgres psql -h localhost -U postgres -d rag_db -c "SELECT 1"

# Check logs for errors
docker-compose logs postgres
# or
tail -f /var/log/postgresql/postgresql.log
```

### Issue: pgvector Extension Not Installed

**Symptom:** `ERROR: extension "vector" is not available`

**Solutions:**

```bash
# Connect to PostgreSQL and install extension
docker exec -it rag_postgres psql -U postgres -d rag_db

-- Run in psql
CREATE EXTENSION IF NOT EXISTS vector;
\dx  # List extensions

# Or use the initialization script
npm run setup:db
```

### Issue: Connection Pool Exhausted

**Symptom:** `Error: Client connection limit exceeded`

**Solutions:**

```typescript
// Increase pool size in src/services/vector-db.ts
const dbConfig = {
  // ...
  max: parseInt(process.env.PGVECTOR_POOL_SIZE || '20'), // Increase from 10 to 20
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

// Or via environment variable
PGVECTOR_POOL_SIZE=20

// Properly release connections
const client = await pool.connect();
try {
  // ... do work
} finally {
  client.release(); // Ensure release
}
```

### Issue: Slow Queries

**Symptom:** Database queries taking too long

**Solutions:**

```sql
-- Check query performance
EXPLAIN ANALYZE SELECT * FROM documents WHERE embedding <=> query_vector < 1;

-- Create appropriate indexes
CREATE INDEX documents_embedding_idx ON documents USING hnsw (embedding vector_cosine_ops);

-- Enable query logging in postgresql.conf
log_min_duration_statement = 500  -- Log queries > 500ms

-- Analyze table statistics
ANALYZE documents;

-- Vacuum to reclaim space
VACUUM ANALYZE documents;
```

---

## D.3 Vector Search Issues

### Issue: No Results Found

**Symptom:** Search returns empty results even with documents in database

**Solutions:**

```typescript
// Check if documents have embeddings
const result = await vectorDB.query(
  'SELECT id, embedding IS NOT NULL as has_embedding FROM documents LIMIT 10'
);
console.log(result.rows);

// Reduce similarity threshold
const results = await vectorDB.similaritySearch(
  queryEmbedding,
  5,
  0.3  // Lower threshold from 0.7
);

// Check document count
const stats = await vectorDB.getStats();
console.log(`Total documents: ${stats.total_documents}`);

// Ensure documents were properly embedded
console.log(chunks[0].embedding?.length); // Should be 1536
```

### Issue: Embedding Generation Fails

**Symptom:** `Error: OpenAI embedding generation failed`

**Solutions:**

```bash
# Check OpenAI API key
echo $OPENAI_API_KEY

# Verify API key works
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"

# Check rate limits
# Reduce batch size
EMBEDDING_BATCH_SIZE=50

# Add retry logic
const embeddings = await this.embeddings.embedDocuments(batch, {
  maxRetries: 3,
  timeout: 30000,
});

# Check token limits
# Ensure each chunk is under 8192 tokens
const tokenCount = chunker.estimateTokens(chunk.content);
if (tokenCount > 8000) {
  // Split chunk further
}
```

### Issue: BM25 Index Not Available

**Symptom:** Lexical search returns empty results

**Solutions:**

```bash
# Force BM25 index refresh
curl -X POST http://localhost:3000/api/v1/admin/index/reload

# Or programmatically
await lexicalSearch.refreshIndex();

# Check if documents are in the index
const status = await lexicalSearch.isReady();
console.log('BM25 ready:', status);

# Check document count
const docCount = await vectorDB.getStats();
console.log('Document count:', docCount.total_documents);
```

---

## D.4 LangChain and LangGraph Issues

### Issue: Runnable Pipeline Fails

**Symptom:** `Error: Cannot read property 'pipe' of undefined`

**Solutions:**

```typescript
// Ensure proper imports
import { RunnableSequence } from '@langchain/core/runnables';
import { PromptTemplate } from '@langchain/core/prompts';

// Check runnable composition
const pipeline = RunnableSequence.from([
  // All steps must return valid values
  (input) => ({ query: input }),
  (input) => ({ ...input, processed: true }),
]);

// Add error handling
const safePipeline = pipeline.withFallbacks({
  fallbacks: [fallbackRunnable],
});
```

### Issue: Agent State Validation Fails

**Symptom:** `Error: State validation failed`

**Solutions:**

```typescript
// Validate state before operations
import { AgentStateSchema } from './agent/state.js';

try {
  AgentStateSchema.parse(state);
} catch (error) {
  console.error('Invalid state:', error.errors);
  // Fix state
}

// Ensure all required fields exist
const defaultState = {
  query: '',
  originalQuery: '',
  searchResults: [],
  searchAttempts: [],
  evidence: [],
  evidenceQuality: 0,
  iteration: 0,
  maxIterations: 5,
  status: 'initialized',
  needsApproval: false,
  approved: false,
};

const cleanState = { ...defaultState, ...state };
```

### Issue: Graph Execution Hangs

**Symptom:** Agent workflow never completes

**Solutions:**

```typescript
// Set timeout for graph execution
const result = await agent.execute(query, {
  maxIterations: 3, // Reduce from 5
  timeout: 30000,
});

// Add timeout to individual nodes
import { withTimeout } from './agent/parallel.js';

const nodeWithTimeout = withTimeout(nodeFunction, 10000);

// Check for infinite loops
function shouldContinue(state) {
  if (state.iteration > state.maxIterations) {
    return 'generate'; // Force generation
  }
  // ... normal logic
}

// Add breakpoint debugging
const stream = await agent.stream(query);
for await (const event of stream) {
  console.log('Event:', event);
  if (event.status === 'failed') break;
}
```

---

## D.5 Performance Issues

### Issue: High Latency

**Symptom:** API responses take > 1 second

**Solutions:**

```typescript
// Enable caching
import { Cache } from '@langchain/core/caches';
const cache = new InMemoryCache();
const model = new ChatOpenAI({
  cache,
  // ...
});

// Reduce topK
const result = await orchestrator.query({
  query,
  topK: 3, // Reduce from 5
});

// Disable reranking for faster responses
const result = await orchestrator.query({
  query,
  useReranking: false,
});

// Enable streaming for user feedback
const stream = await orchestrator.queryStreaming(query, {
  onToken: (token) => {
    // Show token immediately
  },
});
```

### Issue: High Memory Usage

**Symptom:** Process memory > 4GB

**Solutions:**

```typescript
// Reduce batch sizes
const EMBEDDING_BATCH_SIZE = 50; // Reduce from 100
const RERANKING_BATCH_SIZE = 4; // Reduce from 8

// Unload models when not in use
await reranker.unloadModel();

// Use streaming for large responses
const response = await generator.generateStreaming(query, (token) => {
  // Process token
});

// Implement memory limits
if (process.memoryUsage().heapUsed > 1024 * 1024 * 1024 * 2) {
  // Trigger garbage collection
  if (global.gc) {
    global.gc();
  }
}

// Check for memory leaks
// Use --inspect and Chrome DevTools
node --inspect --expose-gc dist/app.js
```

### Issue: Queue Backlog

**Symptom:** Jobs accumulating in Redis

**Solutions:**

```bash
# Check queue depth
redis-cli llen bull:rag-queue:waiting

# Increase workers
docker-compose up -d --scale worker=5

# Monitor worker performance
docker-compose logs worker

# Clear stalled jobs
redis-cli lrem bull:rag-queue:stalled 0

# Implement job timeout
const worker = new Worker('rag-queue', processor, {
  lockDuration: 30000,
  stalledInterval: 30000,
  maxStalledCount: 3,
});
```

---

## D.6 API and WebSocket Issues

### Issue: API Returns 404

**Symptom:** Endpoint not found

**Solutions:**

```bash
# Check routes are registered
curl http://localhost:3000/docs

# Verify route prefix
# Routes are under /api/v1
curl http://localhost:3000/api/v1/queries

# Check server logs
docker-compose logs api
```

### Issue: WebSocket Connection Fails

**Symptom:** `Error: WebSocket connection failed`

**Solutions:**

```javascript
// Ensure WebSocket route is registered
// ws://localhost:3000/ws

// Check WebSocket URL
const ws = new WebSocket('ws://localhost:3000/ws');

// Add connection timeout
const connectionTimeout = setTimeout(() => {
  ws.close();
  console.error('Connection timeout');
}, 5000);

// Handle connection errors
ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

// Send authentication
ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'jwt-token',
  }));
};
```

### Issue: Rate Limiting Too Aggressive

**Symptom:** `429 Too Many Requests`

**Solutions:**

```bash
# Increase rate limit
RATE_LIMIT_MAX=200

# Different limits for different endpoints
# In src/api/server.ts
await fastify.register(rateLimit, {
  max: 100,
  timeWindow: '1 minute',
  skip: (request) => {
    // Skip rate limiting for admin IPs
    return request.ip === '127.0.0.1';
  },
});

# Implement retry with backoff
const response = await fetchWithRetry(url, {
  maxRetries: 3,
  initialDelay: 1000,
});
```

---

## D.7 Security Issues

### Issue: CORS Errors

**Symptom:** `Access-Control-Allow-Origin` errors in browser

**Solutions:**

```typescript
// In src/api/server.ts
await fastify.register(cors, {
  origin: ['https://app.example.com', 'http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
});
```

### Issue: JWT Authentication Fails

**Symptom:** `401 Unauthorized`

**Solutions:**

```typescript
// Check token format
// Should be: Bearer <token>
const authHeader = request.headers.authorization;
if (!authHeader?.startsWith('Bearer ')) {
  throw new Error('Invalid authorization header');
}

// Verify token
const token = authHeader.slice(7);
try {
  const decoded = jwt.verify(token, process.env.JWT_SECRET);
  // Token is valid
} catch (error) {
  // Token is invalid
  throw new Error('Invalid token');
}

// Check token expiration
// Ensure JWT_EXPIRY is set correctly
JWT_EXPIRY=7d
```

### Issue: Sensitive Data Exposure

**Symptom:** Logs contain sensitive information

**Solutions:**

```typescript
// Sanitize logs
const sanitize = (data) => {
  const sensitive = ['password', 'token', 'api_key', 'secret'];
  if (typeof data === 'object' && data !== null) {
    const sanitized = { ...data };
    for (const key of sensitive) {
      if (sanitized[key]) {
        sanitized[key] = '[REDACTED]';
      }
    }
    return sanitized;
  }
  return data;
};

// Use sanitized logger
logger.info('Request', sanitize(request));

// Never log sensitive environment variables
console.log(process.env.OPENAI_API_KEY); // BAD!
```

---

## D.8 Common Error Messages

### Error: "Connection timeout"

**Solution:**
```typescript
// Increase connection timeout
const dbConfig = {
  connectionTimeoutMillis: 10000, // 10 seconds
};

// Add retry logic
const connectWithRetry = async (maxRetries = 3) => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await vectorDB.healthCheck();
      return;
    } catch (error) {
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
  throw new Error('Failed to connect after retries');
};
```

### Error: "OpenAI API rate limit exceeded"

**Solution:**
```typescript
// Implement exponential backoff
const backoff = async (attempt: number) => {
  const delay = Math.min(1000 * Math.pow(2, attempt), 30000);
  await new Promise(resolve => setTimeout(resolve, delay));
};

// Batch requests
const batches = chunkArray(texts, 50);
for (const batch of batches) {
  const embeddings = await embedBatch(batch);
  await backoff(batchIndex);
}

// Use queue for embedding requests
const embeddingQueue = new PQueue({ concurrency: 3 });
const results = await Promise.all(
  texts.map(text => embeddingQueue.add(() => embedText(text)))
);
```

### Error: "Invalid chunk size"

**Solution:**
```typescript
// Validate chunk size
const CHUNK_SIZE = parseInt(process.env.CHUNK_SIZE || '1000');
const CHUNK_OVERLAP = parseInt(process.env.CHUNK_OVERLAP || '200');

if (CHUNK_SIZE <= CHUNK_OVERLAP) {
  throw new Error('Chunk size must be greater than overlap');
}

// Ensure minimum chunk size
const MIN_CHUNK_SIZE = 100;
if (chunk.length < MIN_CHUNK_SIZE && chunk.length > 0) {
  // Merge with previous chunk or discard
}
```

### Error: "No documents found"

**Solution:**
```typescript
// Check database
const stats = await vectorDB.getStats();
console.log('Documents:', stats.total_documents);

// Ingest sample documents
await app.ingestDocuments('./docs');

// Check search without threshold
const results = await vectorDB.similaritySearch(
  embedding,
  10,
  0 // No threshold
);
console.log('Results:', results.length);
```

---

## D.9 Frequently Asked Questions (FAQ)

### General Questions

**Q: What is the difference between RAG and fine-tuning?**

**A:** RAG retrieves relevant information at query time, while fine-tuning modifies the model weights. RAG is better for:
- Frequently changing data
- Large knowledge bases
- Source attribution requirements
- Private/custom data

**Q: When should I use the agent vs. the standard pipeline?**

**A:** Use the agent when:
- You need iterative improvement
- The query requires multiple steps
- Evidence quality is uncertain
- Human feedback is needed

Use the standard pipeline when:
- Speed is critical
- Queries are straightforward
- You have high-confidence data

**Q: How do I update the knowledge base?**

**A:** Simply ingest new documents:
```bash
curl -X POST /api/v1/ingestion \
  -H "Content-Type: application/json" \
  -d '{"path": "./new-docs"}'
```

The system will automatically chunk, embed, and store new documents.

### Architecture Questions

**Q: Can I use a different vector database?**

**A:** Yes. The system supports:
- pgvector (current)
- Pinecone (optional)
- Chroma (optional)
- Weaviate (with adapter)
- Qdrant (with adapter)

**Q: Can I use a different LLM provider?**

**A:** Yes. LangChain.js supports:
- OpenAI
- Anthropic Claude
- Cohere
- Google Vertex AI
- Hugging Face
- Custom providers

**Q: How does the system handle large documents?**

**A:** Documents are:
1. Loaded in streaming mode
2. Chunked into manageable pieces
3. Embedded in batches
4. Stored efficiently with indexes

**Q: Is the system fault-tolerant?**

**A:** Yes. The system includes:
- Checkpoint persistence
- Retry logic
- Graceful degradation
- Queue persistence
- Database backups

### Performance Questions

**Q: How many documents can the system handle?**

**A:** The system can handle:
- Millions of documents with pgvector
- Scalable with proper indexing
- Performance depends on:
  - Embedding dimension
  - Search type (dense vs. hybrid)
  - Hardware resources

**Q: How can I improve query performance?**

**A:** Recommendations:
1. Use caching (Redis)
2. Reduce topK for simple queries
3. Disable reranking for speed
4. Use batch processing
5. Implement result caching
6. Use appropriate indexes

**Q: What's the impact of reranking on performance?**

**A:** Cross-encoder reranking:
- Adds 100-500ms per query
- Improves accuracy by 10-20%
- Uses additional compute resources
- Recommended for critical queries

### Cost Questions

**Q: How much does it cost to run?**

**A:** Costs depend on:
- OpenAI API usage (tokens)
- Infrastructure (AWS/cloud)
- Database size
- Query volume

**Q: How can I reduce OpenAI costs?**

**A:** Strategies:
1. Use smaller models (gpt-4o-mini)
2. Implement caching
3. Reduce token usage
4. Use batch processing
5. Monitor token usage
6. Use embedding models efficiently

**Q: Can I use open-source models?**

**A:** Yes, you can use:
- Hugging Face models
- Ollama (local models)
- Mistral API
- Llama (with appropriate configuration)

### Development Questions

**Q: How do I add a new document type?**

**A:** Extend the DocumentLoader class:
```typescript
// src/ingestion/loader.ts
class DocumentLoader {
  // Add new method
  private async loadDOCX(filePath: string): Promise<string> {
    // Implementation for .docx files
  }
  
  // Update loadFile method
  switch (extension) {
    case 'docx':
      content = await this.loadDOCX(filePath);
      break;
  }
}
```

**Q: How do I add a new prompt style?**

**A:** Extend the PromptManager:
```typescript
// src/orchestration/prompts.ts
export enum PromptStyle {
  // ... existing styles
  CREATIVE = 'creative',
}

// Add template
this.templates.set('creative', PromptTemplate.fromTemplate(`
{system}

Context: {context}
Question: {question}

Be creative and engaging while staying factual:
`));
```

**Q: How do I add custom validation?**

**A:** Extend the validation schemas:
```typescript
// src/orchestration/schemas.ts
export const CustomResponseSchema = BaseResponseSchema.extend({
  // Add custom fields
  category: z.string(),
  priority: z.enum(['high', 'medium', 'low']),
});
```

---

## D.10 Debugging Tools

### Debugging with Logging

```typescript
// Enable debug logging
LOG_LEVEL=debug

// Add contextual logging
const context = { requestId: '123', userId: '456' };
logger.debug('Processing query', context);

// Use trace for detailed debugging
logger.trace('Chunk details', { 
  chunkId: chunk.id,
  length: chunk.content.length,
  embeddingDim: chunk.embedding?.length,
});
```

### Debugging with Tracing

```typescript
// Add trace for specific operations
const traceId = telemetry.startTrace('Debug Operation');
const spanId = telemetry.startSpan(traceId, 'operation.step');

try {
  // ... operation
  telemetry.recordEvent('operation.detail', {
    step: 'processing',
    data: someData,
  }, traceId, spanId);
} finally {
  telemetry.endSpan(traceId, spanId, 'success');
  telemetry.endTrace(traceId, 'success');
}

// Get trace details
const trace = telemetry.getTrace(traceId);
console.log(JSON.stringify(trace, null, 2));
```

### Debugging Database Queries

```sql
-- Enable query logging
SET log_min_duration_statement = 0;

-- Check active connections
SELECT * FROM pg_stat_activity WHERE datname = 'rag_db';

-- Analyze query performance
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM documents WHERE embedding <=> '[0.1, 0.2, ...]' < 1;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE tablename = 'documents';
```

### Debugging Memory Issues

```typescript
// Monitor memory usage
setInterval(() => {
  const mem = process.memoryUsage();
  console.log({
    heapTotal: Math.round(mem.heapTotal / 1024 / 1024) + 'MB',
    heapUsed: Math.round(mem.heapUsed / 1024 / 1024) + 'MB',
    external: Math.round(mem.external / 1024 / 1024) + 'MB',
  });
}, 30000);

// Use Node.js inspector
node --inspect --expose-gc dist/app.js

// Force garbage collection (with --expose-gc)
global.gc();
```

### Debugging Network Issues

```bash
# Check if service is listening
netstat -tulpn | grep 3000

# Test API endpoint
curl -v http://localhost:3000/health

# Check DNS resolution
nslookup localhost

# Trace network route
traceroute api.example.com

# Check firewall rules
iptables -L -n
```

---

## D.11 Support Resources

### Documentation
- **API Documentation**: `http://localhost:3000/docs`
- **LangChain Docs**: `https://js.langchain.com/docs`
- **LangGraph Docs**: `https://langchain-ai.github.io/langgraphjs/`
- **pgvector Docs**: `https://github.com/pgvector/pgvector`

### Community
- **GitHub Issues**: Project repository issues
- **Stack Overflow**: Tag with `langchainjs`, `rag`
- **Discord**: LangChain community server
- **Slack**: RAG/LLM communities

### Monitoring
- **Logs**: `logs/` directory
- **Metrics**: `/metrics` endpoint
- **Health**: `/health` endpoint
- **Traces**: Telemetry service

### Contact
- **Email**: support@example.com
- **Slack**: #rag-support channel
- **PagerDuty**: On-call rotation

---

**[APPENDIX D — COMPLETE]**
