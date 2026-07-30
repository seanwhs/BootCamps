# References and Resources

This document compiles the essential references, official documentation, and supplementary resources referenced throughout the "Bridging the Gap" series. Use this as your permanent reference guide for continued learning and production deployment.

---

## Official Framework Documentation

### LangChain.js
- **Official Website**: https://js.langchain.com
- **Core Concepts**: https://js.langchain.com/docs/concepts
- **API Reference**: https://api.js.langchain.com
- **GitHub Repository**: https://github.com/langchain-ai/langchainjs

### LangGraph.js
- **Official Website**: https://langchain-ai.github.io/langgraphjs/
- **Core Concepts**: https://langchain-ai.github.io/langgraphjs/concepts/
- **API Reference**: https://langchain-ai.github.io/langgraphjs/reference/
- **GitHub Repository**: https://github.com/langchain-ai/langgraph

### Vercel AI SDK
- **Official Website**: https://sdk.vercel.ai
- **Documentation**: https://sdk.vercel.ai/docs
- **GitHub Repository**: https://github.com/vercel/ai

---

## Vector Database Documentation

### pgvector
- **Official Repository**: https://github.com/pgvector/pgvector
- **Documentation**: https://github.com/pgvector/pgvector#readme
- **Installation Guide**: https://github.com/pgvector/pgvector#installation
- **Usage Examples**: https://github.com/pgvector/pgvector#usage

### Other Vector Databases
- **Pinecone**: https://www.pinecone.io/docs/
- **Chroma**: https://docs.trychroma.com/
- **Weaviate**: https://weaviate.io/developers/weaviate
- **Qdrant**: https://qdrant.tech/documentation/

---

## LLM Provider Documentation

### OpenAI
- **API Documentation**: https://platform.openai.com/docs/api-reference
- **Embeddings Guide**: https://platform.openai.com/docs/guides/embeddings
- **Models Overview**: https://platform.openai.com/docs/models
- **Rate Limits**: https://platform.openai.com/docs/guides/rate-limits

### Azure OpenAI
- **Documentation**: https://learn.microsoft.com/en-us/azure/ai-services/openai/
- **LangChain.js Integration**: Azure official samples provide production-ready implementation patterns for TypeScript/LangChain.js applications 

### Anthropic Claude
- **API Documentation**: https://docs.anthropic.com/claude/reference
- **LangChain Integration**: https://js.langchain.com/docs/integrations/chat/anthropic

---

## Key Technical Resources

### Enterprise RAG and Agentic AI Architecture

Enterprise RAG architectures require specialized considerations for data diversity, security, scalability, and real-time insights—moving beyond simple vector search to agentic orchestration . The Model Context Protocol (MCP) extends pure RAG by enabling action-oriented intents and tool integration .

### Hybrid Search Implementation Patterns

Production hybrid search typically combines:
- **Vector similarity**: Semantic matching via pgvector with cosine distance 
- **Full-text search**: PostgreSQL tsvector with normalized scoring 
- **Fuzzy matching**: Trigram similarity via pg_trgm for typo-tolerant search 
- **Reciprocal Rank Fusion (RRF)**: Weighted combination with configurable vector/FTS weights (e.g., 0.7/0.3) 

### Vector Database Design Checklist

**Pre-Implementation Planning** :
- Choose vector algorithm: HNSW (recommended for production) or IVFFlat (for memory-constrained environments) 
- Select embedding model and match dimension (e.g., OpenAI: 1536, Voyage AI: 1024) 
- Plan metadata schema and indexes
- Set HNSW parameters: m=16, ef_construction=64 for good defaults 
- Define RRF constant: k=60 (standard value) 

**Embedding Model Selection** :
| Model | Dimensions | Best For |
|-------|------------|----------|
| text-embedding-3-small | 1536 | General purpose, cost-efficient |
| text-embedding-3-large | 3072 | High accuracy tasks |
| nomic-embed-text | 768 | Open source, self-hosted |
| bge-large-en-v1.5 | 1024 | Local inference |

**Chunking Strategies** :
| Strategy | Chunk Size | Best For |
|----------|------------|----------|
| Fixed-size | 512 tokens | General purpose |
| Recursive | 1000 chars | Prose, documentation |
| Semantic | Variable | High coherence requirement |
| Document structure | By heading/section | Markdown, HTML |
| Parent-Child | 300/1500 tokens | Best retrieval + context |

---

## Learning Resources

### Video Courses
1. **LangChain Official Tutorials**: https://js.langchain.com/docs/tutorials/
2. **LangGraph Tutorials**: https://langchain-ai.github.io/langgraphjs/tutorials/
3. **Community RAG Tutorials**: LangChain's curated list of third-party tutorials covering LangChain v0.1+, LangGraph, and real-world implementations 

### Recommended Learning Path 

**Phase 1: Foundations (6-8 hours)**
- Complete official chat models and prompt templates tutorials
- Build simple chat interface with streaming and session memory

**Phase 2: RAG (10-12 hours)**
- Complete official RAG and vector store integration tutorials
- Build indexing pipeline for PDFs, markdown, and web pages
- Add citations and confidence metrics to responses

**Phase 3: Tools and Agents (8-10 hours)**
- Learn function calling and structured output patterns
- Add 2-3 tools (search, internal API, calculator)
- Convert to agent pattern for multi-step reasoning

**Phase 4: LangGraph for Reliability (6-8 hours)**
- Model workflows as graphs
- Add retries, timeouts, and safety guards
- Deploy with evaluation and logging

**Phase 5: Productionization (Ongoing)**
- Choose deployment path (Docker + FastAPI, Vercel/Next.js)
- Implement usage analytics and cost dashboards

### Enterprise AI Learning Perspectives

**Closing the Skill Gap**: Traditional RAG systems excel at declarative knowledge ("what are the specs"), but struggle with procedural knowledge ("how to troubleshoot"). One practical approach is to store Standard Operating Procedures (SOPs) as structured documents and instruct the system to treat them as executable workflows rather than reference material .

**Frontend AI Development**: The Mastra framework provides TypeScript primitives for building AI agents on the frontend, including agents, tools, workflows, and RAG—addressing the gap between Python backend frameworks and JavaScript/TypeScript frontend stacks .

---

## GitHub Repositories and Sample Code

### Enterprise RAG Examples

**Azure TypeScript LangChainJS Sample** 
- Production-ready TypeScript/LangChain.js implementation with LangGraph
- Azure OpenAI + Azure AI Search integration
- HR document query system (employee benefits, company policies)
- Docker support and Azure Developer CLI deployment
- Repository: https://github.com/Azure-Samples/azure-typescript-langchainjs

**Agentic Enterprise Knowledge Assistant** 
- Full enterprise RAG pipeline with secure web crawling
- Multi-agent orchestration (LangChain, CrewAI, LCEL)
- FAISS/Chroma vector storage with semantic caching
- Repository: https://github.com/darshit-pithadia/Enterprise-Knowlede-Assistant

**Embabel RAG PgVector** 
- Spring Boot auto-configuration for pgvector
- Hybrid search with configurable weights
- Multi-tenant filtering support
- Repository: https://github.com/embabel/embabel-rag-pgvector

### Implementation Checklists and Patterns

**PGVector Hybrid Search Implementation Checklist** 
- Pre-implementation planning (index strategy, embedding selection, schema design)
- Implementation steps (schema, vector search, keyword search, RRF)
- Metadata boosting strategies (section title 1.5x, path 1.15x, code blocks 1.2x)

**Vector Database Design Guide** 
- Requirements discovery and infrastructure decisions
- Embedding model comparison (including Matryoshka embeddings for dimension reduction)
- HNSW vs IVFFlat index comparison
- Parent-child chunking for optimal retrieval

---

## Production References

### Deployment Patterns

**T4 Stack (Next.js 16 + Vercel AI SDK + Local RAG)** 
- Full-stack TypeScript AI stack with end-to-end type safety
- Async request APIs for streaming AI responses
- Unified provider interface for multiple LLM models
- `generateObject` for structured, typed output with Zod schemas

**Docker Configuration**
- Multi-stage builds for production (see Capstone Project)
- Environment-specific configurations
- Health checks and graceful shutdown

### Monitoring and Observability
- **OpenTelemetry**: https://opentelemetry.io/docs/languages/js/
- **Prometheus**: https://prometheus.io/docs/introduction/overview/
- **Grafana**: https://grafana.com/docs/grafana/latest/
- **LangSmith**: https://docs.smith.langchain.com/

---

## Community and Support

### Discussion Forums
- **LangChain Discord**: https://discord.gg/langchain
- **Reddit r/LangChain**: https://www.reddit.com/r/LangChain/
- **Stack Overflow**: Tag with `langchainjs`, `rag`, `pgvector`
- **GitHub Discussions**: Project repository discussions

### Podcasts
- **Software Engineering Daily**: "Building AI Agents on the Frontend" with Mastra co-founders 

---

## Quick Reference Card

### Essential Commands
```bash
# Development
npm run dev                    # Start dev server
npm run build                  # Build for production
npm run test                   # Run tests

# Database
docker-compose up -d postgres  # Start PostgreSQL
npm run prisma:studio          # Open database UI
npm run prisma:migrate         # Run migrations

# Docker
docker-compose up -d           # Start all services
docker-compose logs -f         # Follow logs
docker-compose down            # Stop all services
```

### Key Environment Variables
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

### Common Endpoints
| Endpoint | Purpose |
|----------|---------|
| `http://localhost:3000/api/v1/queries` | Execute query |
| `http://localhost:3000/docs` | Swagger documentation |
| `http://localhost:3000/health` | Health check |
| `http://localhost:3000/metrics` | Prometheus metrics |

---

## Suggested Citation

When referencing this work, please cite the original series:

> *"Bridging the Gap: Enterprise RAG, Vector Databases, and Agentic Orchestration"* — A production-focused tutorial series for JavaScript/TypeScript ecosystem, LangChain.js, and LangGraph.js.

---

**[END OF REFERENCES AND RESOURCES]**

**Keep this document handy for continued learning and reference!**
