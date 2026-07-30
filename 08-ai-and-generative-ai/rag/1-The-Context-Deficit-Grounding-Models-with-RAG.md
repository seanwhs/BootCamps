# Part 1: The Context Deficit — Grounding Models with RAG

## The Problem

Your LLM has a knowledge cutoff. It doesn't know about your company's latest product features, internal documentation, or proprietary data. When users ask questions about these topics, the model either:

1. **Hallucinates** — Makes up plausible but incorrect information
2. **Refuses** — Says "I don't have information about that"
3. **Gives outdated answers** — References old information

The solution is **RAG (Retrieval-Augmented Generation)**: instead of relying solely on the model's parametric memory (what it learned during training), we provide relevant context from an external knowledge base at query time.

---

## The Concept

Think of RAG like a **research assistant with a library card**:

- **Without RAG**: You ask the assistant a question. They answer from memory. If they never learned it, they guess.
- **With RAG**: The assistant goes to the library, finds the most relevant books, reads the relevant sections, and then gives you an answer based on those sources.

The key insight is that we're *augmenting* the model's generation with *retrieved* context.

### The RAG Pipeline in Three Steps:

```
1. INGESTION
   ┌─────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
   │ Document│────▶│ Chunking │────▶│Embeddings│────▶│   Store  │
   │ Loading │     │          │     │          │     │   in DB  │
   └─────────┘     └──────────┘     └──────────┘     └──────────┘

2. RETRIEVAL
   ┌─────────┐     ┌──────────┐     ┌──────────┐
   │ Query   │────▶│ Embed    │────▶│ Similarity│
   │         │     │ Query    │     │  Search   │
   └─────────┘     └──────────┘     └──────────┘

3. GENERATION
   ┌─────────┐     ┌──────────┐     ┌──────────┐
   │ Context │────▶│ Prompt   │────▶│   LLM    │
   │ + Query │     │ Assembly │     │ Response │
   └─────────┘     └──────────┘     └──────────┘
```

---

## What We're Building in Part 1

By the end of this part, you'll have:

1. ✅ A **document ingestion pipeline** that reads files and chunks them
2. ✅ An **embedding service** that converts text to vectors
3. ✅ A **vector database** (PostgreSQL with pgvector) for storage
4. ✅ A **retrieval pipeline** that finds relevant documents
5. ✅ A **generation pipeline** that answers questions with context
6. ✅ A **complete end-to-end RAG system** you can query

---

## Phase 1.1: Project Setup & Dependencies

### The Target
Set up the TypeScript project structure with all necessary dependencies for our RAG system.

### The Concept
Before we can build anything, we need a solid foundation. This is like setting up your workshop before building furniture — you need the right tools, organized workspace, and safety equipment (error handling and type safety).

### The Implementation

#### Step 1: Initialize Project Structure

```bash
# Create the project directory (if not already done)
mkdir -p rag-agent-system
cd rag-agent-system

# Initialize npm
npm init -y

# Create source directory structure
mkdir -p src/ingestion src/retrieval src/services src/types
mkdir -p docs tests scripts
```

#### Step 2: Install Production Dependencies

```bash
# Core dependencies
npm install langchain @langchain/core @langchain/openai
npm install dotenv winston
npm install zod

# Vector database dependencies
npm install pg @types/pg  # PostgreSQL client
npm install @pinecone-database/pinecone  # Optional: Pinecone
npm install chromadb  # Optional: Chroma

# Utility dependencies
npm install uuid @types/uuid
npm install js-tiktoken  # For token counting
npm install pdf-parse  # For PDF reading
```

#### Step 3: Install Development Dependencies

```bash
# TypeScript
npm install -D typescript @types/node ts-node
npm install -D nodemon  # Auto-restart on changes

# Testing
npm install -D jest @types/jest ts-jest
npm install -D @types/uuid

# Linting and formatting
npm install -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
npm install -D prettier
```

#### Step 4: Configure TypeScript

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    /* Language and Environment */
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    
    /* Type Checking */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    
    /* Modules */
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    
    /* Output */
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    /* Interop */
    "resolveJsonModule": true,
    "isolatedModules": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

#### Step 5: Configure Environment Variables

Create `.env.example` in the root:

```env
# ============================================
# OpenAI Configuration
# ============================================
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_EMBEDDING_MODEL=text-embedding-3-small
OPENAI_CHAT_MODEL=gpt-4o-mini
OPENAI_API_BASE=https://api.openai.com/v1

# ============================================
# Vector Database Configuration
# ============================================
# Choose ONE of the following vector databases

# Option 1: PostgreSQL with pgvector (recommended for local dev)
VECTOR_DB_TYPE=pgvector
PGVECTOR_HOST=localhost
PGVECTOR_PORT=5432
PGVECTOR_DATABASE=rag_db
PGVECTOR_USER=postgres
PGVECTOR_PASSWORD=postgres
PGVECTOR_POOL_SIZE=10

# Option 2: Pinecone (managed service)
# VECTOR_DB_TYPE=pinecone
# PINECONE_API_KEY=your_pinecone_api_key
# PINECONE_INDEX=rag-index
# PINECONE_ENVIRONMENT=us-west1-gcp

# Option 3: Chroma (open-source)
# VECTOR_DB_TYPE=chroma
# CHROMA_URL=http://localhost:8000
# CHROMA_COLLECTION_NAME=rag_documents

# ============================================
# Application Configuration
# ============================================
# Chunking settings
CHUNK_SIZE=1000
CHUNK_OVERLAP=200
MIN_CHUNK_SIZE=100

# Retrieval settings
TOP_K_RETRIEVAL=5
SIMILARITY_THRESHOLD=0.7

# Logging
LOG_LEVEL=info
LOG_FORMAT=pretty  # or json

# ============================================
# Optional: LangSmith (for monitoring)
# ============================================
# LANGCHAIN_TRACING_V2=true
# LANGCHAIN_API_KEY=your_langsmith_key
# LANGCHAIN_PROJECT=rag-agent-series
```

#### Step 6: Create `.gitignore`

```
# Node
node_modules/
dist/
.env
*.log
*.lock
package-lock.json
yarn.lock

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Database
*.db
*.sqlite
*.sqlite3
pgdata/

# Test outputs
coverage/
.nyc_output/

# Logs
logs/
*.log
```

#### Step 7: Update `package.json` Scripts

```json
{
  "name": "rag-agent-system",
  "version": "1.0.0",
  "description": "Production-grade RAG and agentic workflow system",
  "main": "dist/app.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/app.js",
    "dev": "nodemon --exec ts-node src/app.ts",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write 'src/**/*.ts'",
    "clean": "rm -rf dist",
    "setup:db": "node scripts/setup-database.js"
  },
  "keywords": [
    "rag",
    "langchain",
    "langgraph",
    "ai",
    "vector-database"
  ],
  "author": "",
  "license": "MIT"
}
```

#### Step 8: Create Base Configuration Files

Create `src/types/index.ts` for shared types:

```typescript
/**
 * Core type definitions used throughout the RAG system
 */

/**
 * Represents a document chunk with its embedding and metadata
 */
export interface DocumentChunk {
  /** Unique identifier for this chunk */
  id: string;
  
  /** The actual text content of the chunk */
  content: string;
  
  /** Vector embedding of the content (dense vector representation) */
  embedding?: number[];
  
  /** Metadata about the source document */
  metadata: {
    /** Original filename or source identifier */
    source: string;
    /** Chunk index within the original document (0-based) */
    chunkIndex: number;
    /** Total number of chunks in the source document */
    totalChunks: number;
    /** Optional: page number for PDFs */
    pageNumber?: number;
    /** Optional: section heading */
    section?: string;
    /** Timestamp of ingestion */
    ingestedAt: string;
    /** Optional: custom tags for filtering */
    tags?: string[];
    /** Optional: document type */
    documentType?: string;
  };
  
  /** Token count for this chunk (for context window management) */
  tokenCount?: number;
}

/**
 * Represents a search query and its results
 */
export interface SearchResult {
  /** The matched document chunk */
  chunk: DocumentChunk;
  
  /** Similarity score (0-1, higher is more similar) */
  score: number;
  
  /** Optional: rank from different retrieval methods */
  ranks?: {
    dense?: number;   // Rank from dense vector search
    lexical?: number; // Rank from BM25 search
    fused?: number;   // Combined rank after fusion
  };
}

/**
 * Configuration for the RAG pipeline
 */
export interface RAGConfig {
  /** Number of documents to retrieve */
  topK: number;
  
  /** Minimum similarity threshold (0-1) */
  similarityThreshold: number;
  
  /** Whether to rerank results */
  useReranking: boolean;
  
  /** Whether to use hybrid search */
  useHybridSearch: boolean;
}

/**
 * Complete RAG response with sources
 */
export interface RAGResponse {
  /** The generated answer */
  answer: string;
  
  /** Source chunks used to generate the answer */
  sources: SearchResult[];
  
  /** Confidence score (0-1) based on source relevance */
  confidence: number;
  
  /** Any warnings (e.g., low confidence, missing sources) */
  warnings: string[];
}
```

Create `src/services/logger.ts`:

```typescript
/**
 * Logger service with structured logging and different log levels
 */

import winston from 'winston';
import path from 'path';

// Determine log level from environment
const LOG_LEVEL = process.env.LOG_LEVEL || 'info';
const LOG_FORMAT = process.env.LOG_FORMAT || 'pretty';

// Configure log format based on environment
const format = LOG_FORMAT === 'json'
  ? winston.format.json()
  : winston.format.combine(
      winston.format.colorize(),
      winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
      winston.format.printf(({ timestamp, level, message, ...meta }) => {
        const metaStr = Object.keys(meta).length
          ? ` ${JSON.stringify(meta)}`
          : '';
        return `${timestamp} [${level}]: ${message}${metaStr}`;
      })
    );

// Create the logger instance
export const logger = winston.createLogger({
  level: LOG_LEVEL,
  format,
  transports: [
    // Console output
    new winston.transports.Console(),
    
    // File output for errors
    new winston.transports.File({
      filename: path.join('logs', 'error.log'),
      level: 'error',
      format: winston.format.json(),
    }),
    
    // File output for all logs
    new winston.transports.File({
      filename: path.join('logs', 'combined.log'),
      format: winston.format.json(),
    }),
  ],
});

// Add child logger support for contextual logging
export const createChildLogger = (context: string) => {
  return logger.child({ context });
};

// Export a default logger instance
export default logger;
```

### The Verification

1. **Check TypeScript compilation**:
```bash
npx tsc --noEmit
```
This should run without errors (we haven't written any application code yet).

2. **Test the logger**:
Create a temporary test file:
```typescript
// test-logger.ts
import logger from './src/services/logger';

logger.info('Logger is working!');
logger.error('This is an error message');
logger.warn('This is a warning');
```

Run it:
```bash
npx ts-node test-logger.ts
```

You should see colored, formatted log output.

3. **Verify environment variables**:
Create `.env` from `.env.example` and ensure your OpenAI key is set:
```bash
cp .env.example .env
# Edit .env with your actual API key
```

4. **Test import resolution**:
```bash
npx ts-node -e "import './src/types/index'; console.log('Types loaded successfully');"
```

---

## Phase 1.2: Vector Database Setup

### The Target
Set up PostgreSQL with pgvector extension as our vector database.

### The Concept
A vector database is specialized for storing and querying high-dimensional vectors (arrays of numbers). Think of it as a specialized index — like the Dewey Decimal System in a library, but for mathematical vectors instead of book subjects.

**Why PostgreSQL with pgvector?**
- Familiar SQL interface
- ACID compliance (transactions, consistency)
- Built-in backup and replication
- No new infrastructure to learn
- Free and open-source

### The Implementation

#### Step 1: Docker Compose for Local PostgreSQL

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    container_name: rag_postgres
    environment:
      POSTGRES_USER: ${PGVECTOR_USER:-postgres}
      POSTGRES_PASSWORD: ${PGVECTOR_PASSWORD:-postgres}
      POSTGRES_DB: ${PGVECTOR_DATABASE:-rag_db}
    ports:
      - "${PGVECTOR_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - rag_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${PGVECTOR_USER:-postgres} -d ${PGVECTOR_DATABASE:-rag_db}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Optional: pgAdmin for database management
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: rag_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    networks:
      - rag_network
    depends_on:
      - postgres
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  rag_network:
    driver: bridge
```

#### Step 2: Database Initialization Script

Create `scripts/init-db.sql`:

```sql
-- Enable the vector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create the documents table
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    embedding VECTOR(1536),  -- 1536 dimensions for text-embedding-3-small
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an HNSW index for fast similarity search
-- HNSW (Hierarchical Navigable Small World) is an approximate nearest neighbor algorithm
-- It provides fast search at the cost of some accuracy
CREATE INDEX IF NOT EXISTS documents_embedding_idx 
ON documents 
USING hnsw (embedding vector_cosine_ops);

-- Create GIN index for JSONB metadata filtering
CREATE INDEX IF NOT EXISTS documents_metadata_idx 
ON documents 
USING gin (metadata);

-- Create a function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to update updated_at
CREATE TRIGGER update_documents_updated_at
BEFORE UPDATE ON documents
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create a function for cosine similarity search
-- This returns documents sorted by similarity to the query embedding
CREATE OR REPLACE FUNCTION search_documents(
    query_embedding VECTOR(1536),
    match_threshold FLOAT,
    match_count INT
)
RETURNS TABLE(
    id UUID,
    content TEXT,
    metadata JSONB,
    similarity FLOAT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        documents.id,
        documents.content,
        documents.metadata,
        1 - (documents.embedding <=> query_embedding) AS similarity,
        documents.created_at
    FROM documents
    WHERE 1 - (documents.embedding <=> query_embedding) > match_threshold
    ORDER BY documents.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- Create a function for metadata-filtered search
CREATE OR REPLACE FUNCTION search_documents_with_metadata(
    query_embedding VECTOR(1536),
    match_threshold FLOAT,
    match_count INT,
    metadata_filters JSONB
)
RETURNS TABLE(
    id UUID,
    content TEXT,
    metadata JSONB,
    similarity FLOAT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        documents.id,
        documents.content,
        documents.metadata,
        1 - (documents.embedding <=> query_embedding) AS similarity,
        documents.created_at
    FROM documents
    WHERE 
        1 - (documents.embedding <=> query_embedding) > match_threshold
        AND documents.metadata @> metadata_filters
    ORDER BY documents.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- Create a view for document statistics
CREATE OR REPLACE VIEW document_stats AS
SELECT 
    COUNT(*) as total_documents,
    AVG(LENGTH(content)) as avg_content_length,
    MIN(created_at) as oldest_document,
    MAX(created_at) as newest_document
FROM documents;

-- Grant permissions (adjust as needed)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
```

#### Step 3: Database Client Service

Create `src/services/vector-db.ts`:

```typescript
/**
 * Vector Database Service using PostgreSQL with pgvector
 * Handles connection pooling, CRUD operations, and similarity search
 */

import { Pool, PoolClient, QueryResult } from 'pg';
import { v4 as uuidv4 } from 'uuid';
import { logger } from './logger.js';
import { DocumentChunk, SearchResult } from '../types/index.js';

// Database configuration from environment
const dbConfig = {
  host: process.env.PGVECTOR_HOST || 'localhost',
  port: parseInt(process.env.PGVECTOR_PORT || '5432'),
  database: process.env.PGVECTOR_DATABASE || 'rag_db',
  user: process.env.PGVECTOR_USER || 'postgres',
  password: process.env.PGVECTOR_PASSWORD || 'postgres',
  max: parseInt(process.env.PGVECTOR_POOL_SIZE || '10'),
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
};

// Create connection pool
class VectorDatabase {
  private pool: Pool;
  private static instance: VectorDatabase;

  private constructor() {
    this.pool = new Pool(dbConfig);
    
    // Set up event listeners
    this.pool.on('connect', () => {
      logger.debug('New database connection established');
    });
    
    this.pool.on('error', (err) => {
      logger.error('Unexpected database pool error', { error: err });
    });
    
    this.pool.on('acquire', () => {
      logger.debug('Client acquired from pool');
    });
    
    this.pool.on('remove', () => {
      logger.debug('Client removed from pool');
    });
  }

  /**
   * Singleton pattern to ensure single connection pool
   */
  public static getInstance(): VectorDatabase {
    if (!VectorDatabase.instance) {
      VectorDatabase.instance = new VectorDatabase();
    }
    return VectorDatabase.instance;
  }

  /**
   * Get a client from the pool with automatic release
   */
  private async getClient(): Promise<PoolClient> {
    const client = await this.pool.connect();
    // Wrap client to ensure it's always released
    const originalRelease = client.release.bind(client);
    client.release = () => {
      originalRelease();
      logger.debug('Client released back to pool');
    };
    return client;
  }

  /**
   * Store a document chunk with its embedding
   */
  async storeDocument(
    chunk: DocumentChunk
  ): Promise<string> {
    if (!chunk.embedding) {
      throw new Error('Document chunk must have an embedding');
    }

    const id = chunk.id || uuidv4();
    
    const query = `
      INSERT INTO documents (id, content, embedding, metadata)
      VALUES ($1, $2, $3, $4)
      RETURNING id
    `;

    const values = [
      id,
      chunk.content,
      `[${chunk.embedding.join(',')}]`, // Convert array to PostgreSQL vector format
      chunk.metadata,
    ];

    try {
      const client = await this.getClient();
      const result = await client.query(query, values);
      client.release();
      
      logger.info('Document stored successfully', { id, source: chunk.metadata.source });
      return result.rows[0].id;
    } catch (error) {
      logger.error('Failed to store document', { 
        id, 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    }
  }

  /**
   * Store multiple document chunks in a batch transaction
   */
  async storeDocuments(
    chunks: DocumentChunk[]
  ): Promise<string[]> {
    const client = await this.getClient();
    const ids: string[] = [];

    try {
      await client.query('BEGIN');
      
      for (const chunk of chunks) {
        const id = await this.storeDocumentWithClient(chunk, client);
        ids.push(id);
      }
      
      await client.query('COMMIT');
      logger.info(`Batch of ${chunks.length} documents stored successfully`);
      
    } catch (error) {
      await client.query('ROLLBACK');
      logger.error('Batch store failed, rolled back transaction', { 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    } finally {
      client.release();
    }

    return ids;
  }

  /**
   * Internal method: store document with existing client
   */
  private async storeDocumentWithClient(
    chunk: DocumentChunk,
    client: PoolClient
  ): Promise<string> {
    if (!chunk.embedding) {
      throw new Error('Document chunk must have an embedding');
    }

    const id = chunk.id || uuidv4();
    
    const query = `
      INSERT INTO documents (id, content, embedding, metadata)
      VALUES ($1, $2, $3, $4)
      RETURNING id
    `;

    const values = [
      id,
      chunk.content,
      `[${chunk.embedding.join(',')}]`,
      chunk.metadata,
    ];

    const result = await client.query(query, values);
    return result.rows[0].id;
  }

  /**
   * Perform similarity search using cosine distance
   * Returns documents sorted by relevance (highest first)
   */
  async similaritySearch(
    queryEmbedding: number[],
    topK: number = parseInt(process.env.TOP_K_RETRIEVAL || '5'),
    threshold: number = parseFloat(process.env.SIMILARITY_THRESHOLD || '0.7'),
    metadataFilters?: Record<string, any>
  ): Promise<SearchResult[]> {
    const client = await this.getClient();

    try {
      let query: string;
      let values: any[];

      if (metadataFilters && Object.keys(metadataFilters).length > 0) {
        // Use metadata-filtered search
        query = `
          SELECT 
            id,
            content,
            metadata,
            1 - (embedding <=> $1) AS similarity,
            created_at
          FROM documents
          WHERE 1 - (embedding <=> $1) > $2
            AND metadata @> $3
          ORDER BY embedding <=> $1
          LIMIT $4
        `;
        values = [
          `[${queryEmbedding.join(',')}]`,
          threshold,
          metadataFilters,
          topK,
        ];
      } else {
        // Use basic similarity search
        query = `
          SELECT 
            id,
            content,
            metadata,
            1 - (embedding <=> $1) AS similarity,
            created_at
          FROM documents
          WHERE 1 - (embedding <=> $1) > $2
          ORDER BY embedding <=> $1
          LIMIT $3
        `;
        values = [
          `[${queryEmbedding.join(',')}]`,
          threshold,
          topK,
        ];
      }

      const result = await client.query(query, values);
      client.release();

      // Map database rows to SearchResult objects
      const searchResults: SearchResult[] = result.rows.map((row) => ({
        chunk: {
          id: row.id,
          content: row.content,
          embedding: undefined, // Don't return embeddings to save memory
          metadata: row.metadata,
          tokenCount: this.estimateTokens(row.content),
        },
        score: row.similarity,
        ranks: {
          dense: 0, // Will be filled by fusion logic later
        },
      }));

      // Assign dense ranks based on order
      searchResults.forEach((result, index) => {
        if (result.ranks) {
          result.ranks.dense = index + 1;
        }
      });

      logger.debug('Similarity search completed', {
        queryEmbeddingLength: queryEmbedding.length,
        topK,
        resultsCount: searchResults.length,
        threshold,
      });

      return searchResults;

    } catch (error) {
      client.release();
      logger.error('Similarity search failed', { 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    }
  }

  /**
   * Delete a document by ID
   */
  async deleteDocument(id: string): Promise<boolean> {
    const client = await this.getClient();
    
    try {
      const query = 'DELETE FROM documents WHERE id = $1 RETURNING id';
      const result = await client.query(query, [id]);
      client.release();
      
      const deleted = result.rows.length > 0;
      if (deleted) {
        logger.info('Document deleted', { id });
      } else {
        logger.warn('Document not found for deletion', { id });
      }
      
      return deleted;
    } catch (error) {
      client.release();
      logger.error('Failed to delete document', { 
        id, 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    }
  }

  /**
   * Get document statistics
   */
  async getStats(): Promise<Record<string, any>> {
    const client = await this.getClient();
    
    try {
      const query = 'SELECT * FROM document_stats';
      const result = await client.query(query);
      client.release();
      
      return result.rows[0] || {};
    } catch (error) {
      client.release();
      logger.error('Failed to get database stats', { 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    }
  }

  /**
   * Estimate token count for a string
   * Simple approximation: ~4 characters per token
   */
  private estimateTokens(text: string): number {
    // Rough approximation: 1 token ≈ 4 characters
    return Math.ceil(text.length / 4);
  }

  /**
   * Check database health
   */
  async healthCheck(): Promise<boolean> {
    try {
      const client = await this.getClient();
      await client.query('SELECT 1');
      client.release();
      return true;
    } catch (error) {
      logger.error('Database health check failed', { 
        error: error instanceof Error ? error.message : String(error) 
      });
      return false;
    }
  }

  /**
   * Close the connection pool
   */
  async close(): Promise<void> {
    await this.pool.end();
    logger.info('Database connection pool closed');
  }
}

// Export singleton instance
export const vectorDB = VectorDatabase.getInstance();
export default vectorDB;
```

#### Step 4: Database Setup Script

Create `scripts/setup-database.js`:

```javascript
/**
 * Database setup script for local development
 * This creates the database and runs migrations
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
import dotenv from 'dotenv';
dotenv.config({ path: path.join(__dirname, '../.env') });

const config = {
  host: process.env.PGVECTOR_HOST || 'localhost',
  port: process.env.PGVECTOR_PORT || '5432',
  database: process.env.PGVECTOR_DATABASE || 'rag_db',
  user: process.env.PGVECTOR_USER || 'postgres',
  password: process.env.PGVECTOR_PASSWORD || 'postgres',
};

async function setupDatabase() {
  console.log('🚀 Setting up vector database...');
  console.log(`📊 Database: ${config.database} on ${config.host}:${config.port}`);

  try {
    // Check if Docker is running
    console.log('🐳 Checking Docker status...');
    await execAsync('docker ps');
    
    // Start Docker containers
    console.log('📦 Starting PostgreSQL with pgvector...');
    await execAsync('docker-compose up -d postgres');
    
    // Wait for database to be ready
    console.log('⏳ Waiting for database to be ready...');
    let retries = 30;
    while (retries > 0) {
      try {
        await execAsync(
          `docker exec rag_postgres pg_isready -U ${config.user} -d ${config.database}`
        );
        break;
      } catch (error) {
        retries--;
        if (retries === 0) {
          throw new Error('Database did not become ready in time');
        }
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
    
    console.log('✅ Database is ready!');
    console.log('📝 Running initialization script...');
    
    // Run the initialization script
    const initSql = fs.readFileSync(
      path.join(__dirname, 'init-db.sql'),
      'utf-8'
    );
    
    // Write SQL to a temporary file and run it
    const tempSqlPath = path.join(__dirname, 'temp-init.sql');
    fs.writeFileSync(tempSqlPath, initSql);
    
    await execAsync(
      `docker exec -i rag_postgres psql -U ${config.user} -d ${config.database} < ${tempSqlPath}`
    );
    
    fs.unlinkSync(tempSqlPath);
    
    console.log('✅ Database initialized successfully!');
    console.log('📊 Database stats:');
    
    // Get stats
    const statsResult = await execAsync(
      `docker exec rag_postgres psql -U ${config.user} -d ${config.database} -c "SELECT * FROM document_stats;"`
    );
    console.log(statsResult.stdout);
    
  } catch (error) {
    console.error('❌ Failed to set up database:', error);
    process.exit(1);
  }
}

// Run setup
setupDatabase();
```

### The Verification

1. **Start PostgreSQL**:
```bash
docker-compose up -d postgres
```

2. **Run database setup**:
```bash
npm run setup:db
# or
node scripts/setup-database.js
```

3. **Verify database is running**:
```bash
docker ps | grep rag_postgres
```

4. **Test connection**:
Create `test-db.ts`:
```typescript
import vectorDB from './src/services/vector-db';

async function testConnection() {
  const health = await vectorDB.healthCheck();
  console.log(`Database health: ${health ? '✅ OK' : '❌ Failed'}`);
  
  const stats = await vectorDB.getStats();
  console.log('Database stats:', stats);
  
  // Close connection
  await vectorDB.close();
}

testConnection().catch(console.error);
```

Run it:
```bash
npx ts-node test-db.ts
```

Expected output:
```
Database health: ✅ OK
Database stats: {
  total_documents: '0',
  avg_content_length: null,
  oldest_document: null,
  newest_document: null
}
```

---

## Phase 1.3: Document Ingestion Pipeline

### The Target
Build a pipeline that loads documents, chunks them intelligently, and prepares them for embedding.

### The Concept
Documents are too large to feed directly into an LLM (due to context window limits). We need to break them into smaller pieces called "chunks." The challenge is finding the right balance:

- **Too small**: Lose context, poor retrieval
- **Too large**: Exceed context window, slower processing
- **Just right**: Captures semantic units while fitting in memory

Think of chunking like cutting a loaf of bread — you want slices that are thick enough to be meaningful but thin enough to be manageable.

### The Implementation

#### Step 1: Document Loader

Create `src/ingestion/loader.ts`:

```typescript
/**
 * Document Loader Service
 * Handles loading documents from various sources (files, URLs, etc.)
 */

import fs from 'fs/promises';
import path from 'path';
import { Readable } from 'stream';
import { logger } from '../services/logger.js';

// Import PDF parser (lazy loaded for performance)
let pdfParse: any = null;

/**
 * Represents a loaded document before chunking
 */
export interface LoadedDocument {
  /** Unique identifier (filename or path) */
  id: string;
  
  /** Full text content of the document */
  content: string;
  
  /** Source information */
  source: string;
  
  /** Document metadata */
  metadata: {
    /** File name or URL */
    fileName: string;
    /** File type extension */
    fileType: string;
    /** File size in bytes */
    fileSize: number;
    /** When the document was loaded */
    loadedAt: string;
    /** Additional metadata from the file system */
    [key: string]: any;
  };
  
  /** Optional: pages for PDFs */
  pages?: string[];
}

/**
 * Document Loader class with support for multiple file types
 */
export class DocumentLoader {
  private supportedTypes: Set<string> = new Set([
    'txt',
    'md',
    'json',
    'pdf',
    'csv',
    'html',
  ]);

  /**
   * Load a single file from the filesystem
   */
  async loadFile(filePath: string): Promise<LoadedDocument> {
    logger.info('Loading document', { filePath });
    
    try {
      const stats = await fs.stat(filePath);
      const extension = path.extname(filePath).toLowerCase().slice(1);
      const fileName = path.basename(filePath);
      
      if (!this.supportedTypes.has(extension)) {
        throw new Error(
          `Unsupported file type: ${extension}. Supported types: ${Array.from(this.supportedTypes).join(', ')}`
        );
      }
      
      let content: string;
      
      // Handle different file types
      switch (extension) {
        case 'pdf':
          content = await this.loadPDF(filePath);
          break;
        case 'json':
          content = await this.loadJSON(filePath);
          break;
        case 'csv':
          content = await this.loadCSV(filePath);
          break;
        case 'html':
          content = await this.loadHTML(filePath);
          break;
        default:
          // Text files: txt, md, etc.
          content = await fs.readFile(filePath, 'utf-8');
          break;
      }
      
      return {
        id: fileName,
        content,
        source: filePath,
        metadata: {
          fileName,
          fileType: extension,
          fileSize: stats.size,
          loadedAt: new Date().toISOString(),
        },
      };
      
    } catch (error) {
      logger.error('Failed to load document', { 
        filePath, 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    }
  }

  /**
   * Load multiple files from a directory
   */
  async loadDirectory(
    directoryPath: string,
    extensionFilter?: string[]
  ): Promise<LoadedDocument[]> {
    logger.info('Loading documents from directory', { 
      directoryPath, 
      extensionFilter 
    });
    
    try {
      const files = await fs.readdir(directoryPath);
      const documents: LoadedDocument[] = [];
      
      for (const file of files) {
        const fullPath = path.join(directoryPath, file);
        const stats = await fs.stat(fullPath);
        
        if (stats.isDirectory()) {
          // Recursively load subdirectories
          const subDocs = await this.loadDirectory(fullPath, extensionFilter);
          documents.push(...subDocs);
          continue;
        }
        
        const extension = path.extname(file).toLowerCase().slice(1);
        
        // Apply extension filter if provided
        if (extensionFilter && !extensionFilter.includes(extension)) {
          continue;
        }
        
        try {
          const doc = await this.loadFile(fullPath);
          documents.push(doc);
        } catch (error) {
          logger.warn('Skipping file due to load error', { 
            file, 
            error: error instanceof Error ? error.message : String(error) 
          });
        }
      }
      
      logger.info('Directory loading complete', { 
        directoryPath, 
        documentCount: documents.length 
      });
      
      return documents;
      
    } catch (error) {
      logger.error('Failed to load directory', { 
        directoryPath, 
        error: error instanceof Error ? error.message : String(error) 
      });
      throw error;
    }
  }

  /**
   * Load a PDF file using pdf-parse
   */
  private async loadPDF(filePath: string): Promise<string> {
    try {
      // Lazy load pdf-parse
      if (!pdfParse) {
        const module = await import('pdf-parse');
        pdfParse = module.default;
      }
      
      const dataBuffer = await fs.readFile(filePath);
      const data = await pdfParse(dataBuffer);
      
      return data.text;
      
    } catch (error) {
      throw new Error(`PDF parsing failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * Load a JSON file and convert to text
   */
  private async loadJSON(filePath: string): Promise<string> {
    const content = await fs.readFile(filePath, 'utf-8');
    const data = JSON.parse(content);
    
    // Convert JSON to readable text
    if (Array.isArray(data)) {
      // If it's an array, join objects with newlines
      return data.map(item => JSON.stringify(item, null, 2)).join('\n\n');
    } else {
      return JSON.stringify(data, null, 2);
    }
  }

  /**
   * Load a CSV file
   */
  private async loadCSV(filePath: string): Promise<string> {
    const content = await fs.readFile(filePath, 'utf-8');
    // Simple CSV to text conversion (keeps it human-readable)
    const lines = content.split('\n');
    
    // Try to parse headers
    const headers = lines[0]?.split(',').map(h => h.trim()) || [];
    
    // Convert to markdown table format
    if (headers.length > 0) {
      const rows = lines.slice(1).filter(line => line.trim());
      const table = [
        '| ' + headers.join(' | ') + ' |',
        '| ' + headers.map(() => '---').join(' | ') + ' |',
        ...rows.map(row => {
          const cells = row.split(',').map(c => c.trim());
          return '| ' + cells.join(' | ') + ' |';
        }),
      ];
      return table.join('\n');
    }
    
    return content;
  }

  /**
   * Load an HTML file and extract text
   * (Simple implementation - for production, use a proper HTML parser)
   */
  private async loadHTML(filePath: string): Promise<string> {
    const content = await fs.readFile(filePath, 'utf-8');
    
    // Remove HTML tags (basic implementation)
    const text = content
      .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, ' ')
      .replace(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi, ' ')
      .replace(/<[^>]+>/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    
    return text;
  }
}

export default new DocumentLoader();
```

#### Step 2: Text Chunker

Create `src/ingestion/chunker.ts`:

```typescript
/**
 * Text Chunking Service
 * Splits documents into semantic chunks for embedding and retrieval
 */

import { logger } from '../services/logger.js';
import { LoadedDocument } from './loader.js';
import { DocumentChunk } from '../types/index.js';
import { encoding_for_model, Tiktoken } from 'js-tiktoken';

// Configuration from environment
const CHUNK_SIZE = parseInt(process.env.CHUNK_SIZE || '1000');
const CHUNK_OVERLAP = parseInt(process.env.CHUNK_OVERLAP || '200');
const MIN_CHUNK_SIZE = parseInt(process.env.MIN_CHUNK_SIZE || '100');

/**
 * Chunking strategies
 */
export enum ChunkingStrategy {
  /** Split by fixed number of characters */
  FIXED_SIZE = 'fixed',
  
  /** Split by paragraphs and then sentences */
  SEMANTIC = 'semantic',
  
  /** Split recursively to maintain natural boundaries */
  RECURSIVE = 'recursive',
  
  /** Split by semantic markers (headers, bullet points, etc.) */
  MARKER_BASED = 'markers',
}

/**
 * Chunker configuration
 */
export interface ChunkerConfig {
  /** Target chunk size in characters */
  chunkSize: number;
  
  /** Overlap between chunks in characters */
  chunkOverlap: number;
  
  /** Minimum chunk size to keep (smaller chunks are discarded) */
  minChunkSize: number;
  
  /** Chunking strategy to use */
  strategy: ChunkingStrategy;
  
  /** Separator for recursive chunking */
  separators?: string[];
  
  /** Whether to preserve natural language boundaries */
  preserveBoundaries: boolean;
}

export class TextChunker {
  private config: ChunkerConfig;
  private tokenizer: Tiktoken | null = null;

  constructor(config?: Partial<ChunkerConfig>) {
    this.config = {
      chunkSize: config?.chunkSize || CHUNK_SIZE,
      chunkOverlap: config?.chunkOverlap || CHUNK_OVERLAP,
      minChunkSize: config?.minChunkSize || MIN_CHUNK_SIZE,
      strategy: config?.strategy || ChunkingStrategy.RECURSIVE,
      separators: config?.separators || ['\n\n', '\n', '. ', ' ', ''],
      preserveBoundaries: config?.preserveBoundaries || true,
    };
    
    // Initialize tokenizer for counting
    this.initTokenizer();
  }

  /**
   * Initialize the tokenizer
   */
  private async initTokenizer() {
    try {
      // Use cl100k_base encoding (used by OpenAI embeddings)
      this.tokenizer = encoding_for_model('gpt-4');
    } catch (error) {
      logger.warn('Failed to initialize tokenizer, falling back to character counting', {
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  /**
   * Chunk a single document
   */
  async chunkDocument(
    document: LoadedDocument,
    strategy?: ChunkingStrategy
  ): Promise<DocumentChunk[]> {
    const strategyToUse = strategy || this.config.strategy;
    
    logger.debug('Chunking document', {
      documentId: document.id,
      strategy: strategyToUse,
      contentLength: document.content.length,
    });
    
    let chunks: string[];
    
    // Apply the chosen strategy
    switch (strategyToUse) {
      case ChunkingStrategy.FIXED_SIZE:
        chunks = this.chunkFixedSize(document.content);
        break;
      
      case ChunkingStrategy.SEMANTIC:
        chunks = this.chunkSemantic(document.content);
        break;
      
      case ChunkingStrategy.MARKER_BASED:
        chunks = this.chunkByMarkers(document.content);
        break;
      
      case ChunkingStrategy.RECURSIVE:
      default:
        chunks = this.chunkRecursive(document.content);
        break;
    }
    
    // Filter out chunks that are too small
    chunks = chunks.filter(chunk => chunk.trim().length >= this.config.minChunkSize);
    
    // Create DocumentChunk objects with metadata
    const documentChunks: DocumentChunk[] = chunks.map((content, index) => {
      const tokenCount = this.tokenizer 
        ? this.tokenizer.encode(content).length 
        : Math.ceil(content.length / 4);
      
      return {
        id: `${document.id}_chunk_${index}`,
        content,
        metadata: {
          source: document.source,
          chunkIndex: index,
          totalChunks: chunks.length,
          ingestedAt: new Date().toISOString(),
          ...document.metadata,
        },
        tokenCount,
      };
    });
    
    logger.info('Document chunking complete', {
      documentId: document.id,
      chunkCount: documentChunks.length,
      avgChunkSize: documentChunks.reduce((acc, c) => acc + c.content.length, 0) / documentChunks.length,
    });
    
    return documentChunks;
  }

  /**
   * Chunk multiple documents
   */
  async chunkDocuments(
    documents: LoadedDocument[]
  ): Promise<DocumentChunk[]> {
    logger.info('Chunking multiple documents', { documentCount: documents.length });
    
    const allChunks: DocumentChunk[] = [];
    
    for (const doc of documents) {
      try {
        const chunks = await this.chunkDocument(doc);
        allChunks.push(...chunks);
      } catch (error) {
        logger.error('Failed to chunk document', {
          documentId: doc.id,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }
    
    logger.info('Batch chunking complete', { 
      totalChunks: allChunks.length,
      documentsProcessed: documents.length,
    });
    
    return allChunks;
  }

  /**
   * Fixed-size chunking with overlap
   */
  private chunkFixedSize(text: string): string[] {
    const chunks: string[] = [];
    const size = this.config.chunkSize;
    const overlap = this.config.chunkOverlap;
    
    if (text.length <= size) {
      return [text];
    }
    
    let start = 0;
    while (start < text.length) {
      const end = Math.min(start + size, text.length);
      chunks.push(text.substring(start, end));
      start += size - overlap;
    }
    
    return chunks;
  }

  /**
   * Semantic chunking by paragraphs and sentences
   */
  private chunkSemantic(text: string): string[] {
    // Split by paragraphs first
    const paragraphs = text.split('\n\n').filter(p => p.trim().length > 0);
    const chunks: string[] = [];
    let currentChunk = '';
    
    for (const paragraph of paragraphs) {
      // If adding this paragraph would exceed the chunk size,
      // try to split it by sentences
      if (currentChunk.length + paragraph.length > this.config.chunkSize) {
        if (currentChunk) {
          chunks.push(currentChunk.trim());
        }
        
        // Split paragraph by sentences
        const sentences = paragraph.match(/[^.!?]+[.!?]+/g) || [paragraph];
        currentChunk = '';
        
        for (const sentence of sentences) {
          if (currentChunk.length + sentence.length > this.config.chunkSize) {
            if (currentChunk) {
              chunks.push(currentChunk.trim());
            }
            currentChunk = sentence;
          } else {
            currentChunk += (currentChunk ? ' ' : '') + sentence;
          }
        }
      } else {
        currentChunk += (currentChunk ? '\n\n' : '') + paragraph;
      }
    }
    
    if (currentChunk) {
      chunks.push(currentChunk.trim());
    }
    
    return chunks;
  }

  /**
   * Recursive chunking that tries to maintain natural boundaries
   */
  private chunkRecursive(text: string): string[] {
    const separators = this.config.separators || ['\n\n', '\n', '. ', ' ', ''];
    return this.recursiveSplit(text, separators, 0);
  }

  /**
   * Helper for recursive splitting
   */
  private recursiveSplit(text: string, separators: string[], depth: number): string[] {
    if (text.length <= this.config.chunkSize) {
      return text.trim() ? [text.trim()] : [];
    }
    
    // If we've tried all separators, split by character
    if (depth >= separators.length) {
      const chunks: string[] = [];
      const size = this.config.chunkSize;
      let start = 0;
      
      while (start < text.length) {
        const end = Math.min(start + size, text.length);
        chunks.push(text.substring(start, end));
        start += size - this.config.chunkOverlap;
      }
      
      return chunks;
    }
    
    const separator = separators[depth];
    const parts = text.split(separator);
    const chunks: string[] = [];
    let currentChunk = '';
    
    for (const part of parts) {
      const testChunk = currentChunk 
        ? currentChunk + separator + part 
        : part;
      
      if (testChunk.length > this.config.chunkSize) {
        // Current chunk is too big, try splitting with next separator
        if (currentChunk) {
          chunks.push(currentChunk);
          currentChunk = '';
        }
        
        // If this part alone is too big, split it recursively
        if (part.length > this.config.chunkSize) {
          const subChunks = this.recursiveSplit(
            part, 
            separators, 
            depth + 1
          );
          chunks.push(...subChunks);
        } else {
          currentChunk = part;
        }
      } else {
        currentChunk = testChunk;
      }
    }
    
    if (currentChunk) {
      chunks.push(currentChunk);
    }
    
    return chunks;
  }

  /**
   * Chunk by semantic markers (headers, bullet points, etc.)
   */
  private chunkByMarkers(text: string): string[] {
    // Try to identify common section markers
    const markerPattern = /^#{1,6}\s+|^[*-]\s+|^\d+\.\s+|^[A-Z][a-z]+:/gm;
    const lines = text.split('\n');
    const chunks: string[] = [];
    let currentChunk = '';
    let currentMarker = '';
    
    for (const line of lines) {
      const match = line.match(markerPattern);
      
      if (match) {
        // New section found
        if (currentChunk && currentChunk.length >= this.config.minChunkSize) {
          chunks.push(currentChunk.trim());
        }
        currentChunk = line;
        currentMarker = match[0];
      } else {
        if (currentChunk) {
          const testChunk = currentChunk + '\n' + line;
          if (testChunk.length > this.config.chunkSize && currentChunk.length >= this.config.minChunkSize) {
            chunks.push(currentChunk.trim());
            currentChunk = line;
          } else {
            currentChunk = testChunk;
          }
        } else {
          currentChunk = line;
        }
      }
    }
    
    if (currentChunk && currentChunk.length >= this.config.minChunkSize) {
      chunks.push(currentChunk.trim());
    }
    
    // If we got no chunks (maybe no markers found), fall back to recursive
    if (chunks.length === 0) {
      return this.chunkRecursive(text);
    }
    
    return chunks;
  }

  /**
   * Estimate the number of tokens in a chunk
   */
  estimateTokens(text: string): number {
    if (this.tokenizer) {
      return this.tokenizer.encode(text).length;
    }
    return Math.ceil(text.length / 4);
  }

  /**
   * Dispose of the tokenizer
   */
  dispose(): void {
    if (this.tokenizer) {
      this.tokenizer.free();
      this.tokenizer = null;
    }
  }
}

export default new TextChunker();
```

#### Step 3: Embedding Service

Create `src/ingestion/embedder.ts`:

```typescript
/**
 * Embedding Service
 * Converts text chunks to vector embeddings using OpenAI's embedding models
 */

import { OpenAIEmbeddings } from '@langchain/openai';
import { logger } from '../services/logger.js';
import { DocumentChunk } from '../types/index.js';

// Configuration
const EMBEDDING_MODEL = process.env.OPENAI_EMBEDDING_MODEL || 'text-embedding-3-small';
const EMBEDDING_BATCH_SIZE = 100; // Number of texts to embed in one batch

/**
 * Embedding service with batch processing and error handling
 */
export class EmbeddingService {
  private embeddings: OpenAIEmbeddings;
  private batchSize: number;

  constructor(batchSize: number = EMBEDDING_BATCH_SIZE) {
    this.batchSize = batchSize;
    
    // Initialize the OpenAI embeddings model
    this.embeddings = new OpenAIEmbeddings({
      model: EMBEDDING_MODEL,
      // OpenAI will use the OPENAI_API_KEY from environment
      // Configured via process.env by default
    });
    
    logger.info('Embedding service initialized', {
      model: EMBEDDING_MODEL,
      batchSize: this.batchSize,
    });
  }

  /**
   * Generate embeddings for multiple texts with batching
   */
  async embedTexts(texts: string[]): Promise<number[][]> {
    if (texts.length === 0) {
      return [];
    }

    // Filter out empty texts
    const validTexts = texts.filter(text => text.trim().length > 0);
    if (validTexts.length === 0) {
      logger.warn('No valid texts to embed');
      return [];
    }

    logger.info('Starting embedding generation', {
      textCount: validTexts.length,
      model: EMBEDDING_MODEL,
    });

    try {
      // Process in batches to avoid rate limits
      const allEmbeddings: number[][] = [];
      
      for (let i = 0; i < validTexts.length; i += this.batchSize) {
        const batch = validTexts.slice(i, i + this.batchSize);
        
        logger.debug('Processing embedding batch', {
          batchSize: batch.length,
          batchStart: i,
          batchEnd: i + batch.length,
        });
        
        const batchEmbeddings = await this.embeddings.embedDocuments(batch);
        allEmbeddings.push(...batchEmbeddings);
        
        // Add a small delay between batches to avoid rate limits
        if (i + this.batchSize < validTexts.length) {
          await new Promise(resolve => setTimeout(resolve, 100));
        }
      }

      logger.info('Embedding generation complete', {
        totalEmbeddings: allEmbeddings.length,
        vectorDimension: allEmbeddings[0]?.length || 0,
      });

      return allEmbeddings;

    } catch (error) {
      logger.error('Failed to generate embeddings', {
        error: error instanceof Error ? error.message : String(error),
        textCount: validTexts.length,
      });
      throw error;
    }
  }

  /**
   * Embed a single text
   */
  async embedText(text: string): Promise<number[]> {
    const results = await this.embedTexts([text]);
    return results[0] || [];
  }

  /**
   * Embed multiple document chunks
   */
  async embedChunks(chunks: DocumentChunk[]): Promise<DocumentChunk[]> {
    if (chunks.length === 0) {
      return [];
    }

    logger.info('Embedding document chunks', { chunkCount: chunks.length });

    // Extract content from chunks
    const contents = chunks.map(chunk => chunk.content);
    
    try {
      // Generate embeddings
      const embeddings = await this.embedTexts(contents);
      
      // Assign embeddings back to chunks
      const embeddedChunks = chunks.map((chunk, index) => ({
        ...chunk,
        embedding: embeddings[index] || undefined,
      }));

      // Filter out chunks that failed to embed
      const validChunks = embeddedChunks.filter(chunk => chunk.embedding);
      
      const failedCount = chunks.length - validChunks.length;
      if (failedCount > 0) {
        logger.warn('Some chunks failed to embed', { 
          failedCount, 
          totalChunks: chunks.length 
        });
      }

      logger.info('Chunk embedding complete', {
        totalChunks: chunks.length,
        successfullyEmbedded: validChunks.length,
        embeddingDimension: validChunks[0]?.embedding?.length || 0,
      });

      return validChunks;

    } catch (error) {
      logger.error('Failed to embed chunks', {
        error: error instanceof Error ? error.message : String(error),
        chunkCount: chunks.length,
      });
      throw error;
    }
  }

  /**
   * Get embedding dimension for the current model
   */
  getEmbeddingDimension(): number {
    // text-embedding-3-small: 1536 dimensions
    // text-embedding-3-large: 3072 dimensions
    switch (EMBEDDING_MODEL) {
      case 'text-embedding-3-small':
        return 1536;
      case 'text-embedding-3-large':
        return 3072;
      default:
        return 1536; // Default to 1536
    }
  }

  /**
   * Check if the embedding service is available
   */
  async healthCheck(): Promise<boolean> {
    try {
      // Try to embed a simple text
      await this.embedText('Health check test');
      return true;
    } catch (error) {
      logger.error('Embedding service health check failed', {
        error: error instanceof Error ? error.message : String(error),
      });
      return false;
    }
  }
}

export default new EmbeddingService();
```

### The Verification

1. **Create a sample document**:

Create `docs/sample.txt`:
```
# Introduction to RAG Systems

Retrieval-Augmented Generation (RAG) is a technique that enhances large language models by providing them with relevant information from external knowledge sources.

## How RAG Works

RAG operates in three main stages:
1. Document Ingestion: Documents are loaded, chunked, and stored in a vector database.
2. Query Processing: User queries are embedded and used to search for relevant documents.
3. Response Generation: Retrieved documents are combined with the query to generate an answer.

## Benefits of RAG

- Reduces hallucinations by grounding responses in actual data
- Enables access to private or up-to-date information
- Allows attribution of sources for transparency
- Easier to update knowledge by updating the document store
```

2. **Create a test script**:

Create `test-ingestion.ts`:

```typescript
import loader from './src/ingestion/loader';
import chunker from './src/ingestion/chunker';
import embedder from './src/ingestion/embedder';
import vectorDB from './src/services/vector-db';

async function testIngestion() {
  console.log('🧪 Testing document ingestion pipeline...\n');
  
  // Step 1: Load document
  console.log('📄 Loading document...');
  const doc = await loader.loadFile('./docs/sample.txt');
  console.log(`   ✅ Loaded: ${doc.id} (${doc.content.length} characters)`);
  
  // Step 2: Chunk document
  console.log('✂️ Chunking document...');
  const chunks = await chunker.chunkDocument(doc);
  console.log(`   ✅ Created ${chunks.length} chunks`);
  console.log(`   📊 Avg chunk size: ${Math.round(chunks.reduce((acc, c) => acc + c.content.length, 0) / chunks.length)} chars`);
  
  // Step 3: Generate embeddings
  console.log('🧠 Generating embeddings...');
  const embeddedChunks = await embedder.embedChunks(chunks);
  console.log(`   ✅ Embedded ${embeddedChunks.length} chunks`);
  console.log(`   📊 Embedding dimension: ${embeddedChunks[0]?.embedding?.length || 0}`);
  
  // Step 4: Store in vector database
  console.log('💾 Storing in vector database...');
  const ids = await vectorDB.storeDocuments(embeddedChunks);
  console.log(`   ✅ Stored ${ids.length} chunks`);
  
  // Step 5: Verify storage
  console.log('🔍 Verifying storage...');
  const stats = await vectorDB.getStats();
  console.log('   📊 Database stats:', stats);
  
  // Clean up
  await vectorDB.close();
  console.log('\n✅ Ingestion test complete!');
}

testIngestion().catch(console.error);
```

3. **Run the test**:

```bash
# Make sure PostgreSQL is running
docker-compose up -d postgres

# Run the test
npx ts-node test-ingestion.ts
```

Expected output:
```
🧪 Testing document ingestion pipeline...

📄 Loading document...
   ✅ Loaded: sample.txt (XXX characters)
✂️ Chunking document...
   ✅ Created 3 chunks
   📊 Avg chunk size: ~400 chars
🧠 Generating embeddings...
   ✅ Embedded 3 chunks
   📊 Embedding dimension: 1536
💾 Storing in vector database...
   ✅ Stored 3 chunks
🔍 Verifying storage...
   📊 Database stats: { total_documents: '3', ... }

✅ Ingestion test complete!
```

---

## Phase 1.4: Retrieval and Generation Pipeline

### The Target
Build the retrieval and generation pipeline that answers questions using the stored documents.

### The Concept

**Retrieval**: When a user asks a question, we:
1. Convert the question to an embedding
2. Search the vector database for similar chunks
3. Return the most relevant chunks

**Generation**: With the retrieved chunks as context, we:
1. Construct a prompt that includes the context and question
2. Send it to the LLM
3. Return the generated answer with source attribution

This is like a **research assistant** who:
1. Takes your question
2. Finds relevant books in the library (retrieval)
3. Reads them and synthesizes an answer (generation)

### The Implementation

#### Step 1: Retrieval Pipeline

Create `src/retrieval/retriever.ts`:

```typescript
/**
 * Retrieval Pipeline
 * Handles query embedding, similarity search, and result ranking
 */

import { logger } from '../services/logger.js';
import embedder from '../ingestion/embedder.js';
import vectorDB from '../services/vector-db.js';
import { SearchResult, RAGConfig } from '../types/index.js';

// Default configuration
const DEFAULT_CONFIG: RAGConfig = {
  topK: parseInt(process.env.TOP_K_RETRIEVAL || '5'),
  similarityThreshold: parseFloat(process.env.SIMILARITY_THRESHOLD || '0.7'),
  useReranking: false,
  useHybridSearch: false,
};

export class Retriever {
  private config: RAGConfig;

  constructor(config?: Partial<RAGConfig>) {
    this.config = {
      ...DEFAULT_CONFIG,
      ...config,
    };
  }

  /**
   * Retrieve relevant documents for a query
   */
  async retrieve(
    query: string,
    config?: Partial<RAGConfig>
  ): Promise<SearchResult[]> {
    const effectiveConfig = {
      ...this.config,
      ...config,
    };

    logger.info('Starting retrieval', {
      queryLength: query.length,
      topK: effectiveConfig.topK,
      threshold: effectiveConfig.similarityThreshold,
    });

    try {
      // Step 1: Embed the query
      logger.debug('Generating query embedding');
      const queryEmbedding = await embedder.embedText(query);
      
      if (!queryEmbedding || queryEmbedding.length === 0) {
        throw new Error('Failed to generate query embedding');
      }

      // Step 2: Perform similarity search
      logger.debug('Performing similarity search');
      const results = await vectorDB.similaritySearch(
        queryEmbedding,
        effectiveConfig.topK,
        effectiveConfig.similarityThreshold
      );

      // Step 3: Apply optional reranking
      if (effectiveConfig.useReranking) {
        logger.debug('Applying reranking (not implemented in Part 1)');
        // Will be implemented in Part 2
      }

      // Step 4: Apply hybrid search
      if (effectiveConfig.useHybridSearch) {
        logger.debug('Applying hybrid search (not implemented in Part 1)');
        // Will be implemented in Part 2
      }

      // Log results
      logger.info('Retrieval complete', {
        resultCount: results.length,
        topScore: results.length > 0 ? results[0].score : 0,
        avgScore: results.length > 0 
          ? results.reduce((acc, r) => acc + r.score, 0) / results.length 
          : 0,
      });

      return results;

    } catch (error) {
      logger.error('Retrieval failed', {
        query,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * Retrieve with metadata filtering
   */
  async retrieveWithFilter(
    query: string,
    metadataFilters: Record<string, any>,
    config?: Partial<RAGConfig>
  ): Promise<SearchResult[]> {
    const effectiveConfig = {
      ...this.config,
      ...config,
    };

    logger.info('Starting filtered retrieval', {
      queryLength: query.length,
      filters: Object.keys(metadataFilters),
    });

    try {
      // Embed the query
      const queryEmbedding = await embedder.embedText(query);
      
      if (!queryEmbedding || queryEmbedding.length === 0) {
        throw new Error('Failed to generate query embedding');
      }

      // Perform filtered similarity search
      const results = await vectorDB.similaritySearch(
        queryEmbedding,
        effectiveConfig.topK,
        effectiveConfig.similarityThreshold,
        metadataFilters
      );

      logger.info('Filtered retrieval complete', {
        resultCount: results.length,
        filters: metadataFilters,
      });

      return results;

    } catch (error) {
      logger.error('Filtered retrieval failed', {
        query,
        filters: metadataFilters,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * Get just the context text from search results
   */
  async getContext(
    query: string,
    config?: Partial<RAGConfig>
  ): Promise<string> {
    const results = await this.retrieve(query, config);
    
    // Format results as context
    const contextChunks = results.map((result, index) => {
      const chunk = result.chunk;
      return `[Source ${index + 1}] ${chunk.content}`;
    });

    return contextChunks.join('\n\n---\n\n');
  }

  /**
   * Update configuration
   */
  updateConfig(config: Partial<RAGConfig>): void {
    this.config = {
      ...this.config,
      ...config,
    };
    logger.info('Retriever configuration updated', { config: this.config });
  }

  /**
   * Get current configuration
   */
  getConfig(): RAGConfig {
    return { ...this.config };
  }
}

export default new Retriever();
```

#### Step 2: Generation Pipeline

Create `src/retrieval/generator.ts`:

```typescript
/**
 * Generation Pipeline
 * Uses retrieved context to generate answers with source attribution
 */

import { ChatOpenAI } from '@langchain/openai';
import { HumanMessage, SystemMessage } from '@langchain/core/messages';
import { logger } from '../services/logger.js';
import retriever from './retriever.js';
import { SearchResult, RAGResponse } from '../types/index.js';

// Configuration
const CHAT_MODEL = process.env.OPENAI_CHAT_MODEL || 'gpt-4o-mini';
const TEMPERATURE = 0.3; // Lower = more deterministic, higher = more creative

export class Generator {
  private llm: ChatOpenAI;

  constructor() {
    this.llm = new ChatOpenAI({
      model: CHAT_MODEL,
      temperature: TEMPERATURE,
      maxTokens: 1000,
    });
    
    logger.info('Generator initialized', {
      model: CHAT_MODEL,
      temperature: TEMPERATURE,
    });
  }

  /**
   * Generate an answer using retrieved context
   */
  async generate(
    query: string,
    config?: {
      topK?: number;
      includeSources?: boolean;
      systemPrompt?: string;
    }
  ): Promise<RAGResponse> {
    const topK = config?.topK || 5;
    const includeSources = config?.includeSources !== false;

    logger.info('Starting generation', {
      queryLength: query.length,
      topK,
      includeSources,
    });

    try {
      // Step 1: Retrieve relevant documents
      logger.debug('Retrieving context');
      const searchResults = await retriever.retrieve(query, { topK });
      
      if (searchResults.length === 0) {
        logger.warn('No relevant documents found for query');
        return {
          answer: "I couldn't find any relevant information to answer your question. Please try rephrasing your query or ensure documents have been ingested.",
          sources: [],
          confidence: 0,
          warnings: ['No relevant documents found'],
        };
      }

      // Step 2: Build context from retrieved documents
      const contextText = this.formatContext(searchResults);
      
      // Step 3: Calculate confidence based on scores
      const confidence = this.calculateConfidence(searchResults);
      
      // Step 4: Generate answer using LLM
      logger.debug('Generating answer with LLM');
      const answer = await this.generateAnswer(query, contextText, config?.systemPrompt);

      // Step 5: Build response
      const response: RAGResponse = {
        answer,
        sources: includeSources ? searchResults : [],
        confidence,
        warnings: this.getWarnings(searchResults, confidence),
      };

      logger.info('Generation complete', {
        answerLength: answer.length,
        confidence,
        warningCount: response.warnings.length,
      });

      return response;

    } catch (error) {
      logger.error('Generation failed', {
        query,
        error: error instanceof Error ? error.message : String(error),
      });
      
      // Return a graceful fallback
      return {
        answer: "I encountered an error while generating your answer. Please try again later.",
        sources: [],
        confidence: 0,
        warnings: ['Generation error occurred'],
      };
    }
  }

  /**
   * Format search results as context for the LLM
   */
  private formatContext(results: SearchResult[]): string {
    const MAX_CONTEXT_LENGTH = 8000; // Token limit for context
    
    let context = '';
    let tokenCount = 0;
    
    for (let i = 0; i < results.length; i++) {
      const result = results[i];
      const chunk = result.chunk;
      const sourceText = `Source ${i + 1} (Relevance: ${(result.score * 100).toFixed(1)}%):\n${chunk.content}\n`;
      
      // Estimate token count (roughly 4 chars per token)
      const estimatedTokens = Math.ceil(sourceText.length / 4);
      
      if (tokenCount + estimatedTokens > MAX_CONTEXT_LENGTH) {
        logger.debug('Context length limit reached', {
          sourcesIncluded: i,
          tokenCount,
        });
        break;
      }
      
      context += (context ? '\n---\n' : '') + sourceText;
      tokenCount += estimatedTokens;
    }
    
    return context;
  }

  /**
   * Calculate confidence based on search result scores
   */
  private calculateConfidence(results: SearchResult[]): number {
    if (results.length === 0) return 0;
    
    // Weighted average of scores, with top results weighted more
    const weights = results.map((_, i) => Math.exp(-i * 0.5));
    const totalWeight = weights.reduce((a, b) => a + b, 0);
    
    const weightedScore = results.reduce(
      (acc, result, i) => acc + result.score * weights[i],
      0
    ) / totalWeight;
    
    // Normalize to 0-1
    return Math.min(Math.max(weightedScore, 0), 1);
  }

  /**
   * Generate warnings based on results and confidence
   */
  private getWarnings(results: SearchResult[], confidence: number): string[] {
    const warnings: string[] = [];
    
    if (results.length === 0) {
      warnings.push('No relevant documents found');
    }
    
    if (confidence < 0.5) {
      warnings.push('Low confidence - retrieved documents may not be highly relevant');
    }
    
    if (results.length < 3) {
      warnings.push('Limited sources available for response');
    }
    
    // Check for duplicate or very similar sources
    const contents = results.map(r => r.chunk.content.substring(0, 100));
    const uniqueContents = new Set(contents);
    if (uniqueContents.size < contents.length) {
      warnings.push('Multiple retrieved chunks appear similar - consider checking for duplicates');
    }
    
    return warnings;
  }

  /**
   * Generate answer using the LLM
   */
  private async generateAnswer(
    query: string,
    context: string,
    customSystemPrompt?: string
  ): Promise<string> {
    const systemPrompt = customSystemPrompt || `
You are a helpful AI assistant that answers questions based on the provided context.

IMPORTANT RULES:
1. ONLY use information from the provided context to answer the question.
2. If the context doesn't contain enough information to answer, say so clearly.
3. Cite which source (Source 1, Source 2, etc.) you're using for each piece of information.
4. If multiple sources provide different information, acknowledge this.
5. Be concise but thorough.
6. Do not make up information or use knowledge outside the provided context.
`;

    const messages = [
      new SystemMessage(systemPrompt),
      new HumanMessage(
        `Context:\n${context}\n\nQuestion: ${query}\n\nAnswer based ONLY on the context provided above.`
      ),
    ];

    try {
      const response = await this.llm.invoke(messages);
      
      if (!response.content) {
        throw new Error('LLM returned empty response');
      }
      
      return response.content.toString();
      
    } catch (error) {
      logger.error('LLM generation failed', {
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * Generate answer with streaming support
   */
  async generateStreaming(
    query: string,
    onToken: (token: string) => void,
    config?: {
      topK?: number;
      includeSources?: boolean;
      systemPrompt?: string;
    }
  ): Promise<RAGResponse> {
    // First, get the retrieval results
    const topK = config?.topK || 5;
    const searchResults = await retriever.retrieve(query, { topK });
    
    if (searchResults.length === 0) {
      // No results, fall back to non-streaming
      return this.generate(query, config);
    }

    // Format context
    const contextText = this.formatContext(searchResults);
    const confidence = this.calculateConfidence(searchResults);
    
    // Build the prompt
    const systemPrompt = config?.systemPrompt || `
You are a helpful AI assistant that answers questions based on the provided context.

IMPORTANT RULES:
1. ONLY use information from the provided context to answer the question.
2. If the context doesn't contain enough information to answer, say so clearly.
3. Cite which source you're using for each piece of information.
4. Be concise but thorough.
`;

    const messages = [
      new SystemMessage(systemPrompt),
      new HumanMessage(
        `Context:\n${contextText}\n\nQuestion: ${query}\n\nAnswer based ONLY on the context provided above.`
      ),
    ];

    // Stream the response
    const stream = await this.llm.stream(messages);
    let fullAnswer = '';
    
    for await (const chunk of stream) {
      const content = chunk.content?.toString() || '';
      fullAnswer += content;
      onToken(content);
    }

    // Build final response
    const response: RAGResponse = {
      answer: fullAnswer,
      sources: config?.includeSources !== false ? searchResults : [],
      confidence,
      warnings: this.getWarnings(searchResults, confidence),
    };

    return response;
  }
}

export default new Generator();
```

#### Step 3: Complete RAG Pipeline

Create `src/retrieval/pipeline.ts`:

```typescript
/**
 * Complete RAG Pipeline
 * Orchestrates the entire retrieval and generation process
 */

import { logger } from '../services/logger.js';
import retriever from './retriever.js';
import generator from './generator.js';
import { SearchResult, RAGResponse, RAGConfig } from '../types/index.js';

export class RAGPipeline {
  private config: RAGConfig;

  constructor(config?: Partial<RAGConfig>) {
    this.config = {
      topK: parseInt(process.env.TOP_K_RETRIEVAL || '5'),
      similarityThreshold: parseFloat(process.env.SIMILARITY_THRESHOLD || '0.7'),
      useReranking: false,
      useHybridSearch: false,
      ...config,
    };
    
    // Update retriever config
    retriever.updateConfig(this.config);
  }

  /**
   * Execute the full RAG pipeline
   */
  async query(
    question: string,
    options?: {
      topK?: number;
      includeSources?: boolean;
      systemPrompt?: string;
    }
  ): Promise<RAGResponse> {
    logger.info('RAG pipeline executing', {
      questionLength: question.length,
      options,
    });

    try {
      const response = await generator.generate(question, options);
      
      logger.info('RAG pipeline complete', {
        confidence: response.confidence,
        sourcesCount: response.sources.length,
        warningCount: response.warnings.length,
      });
      
      return response;
      
    } catch (error) {
      logger.error('RAG pipeline failed', {
        question,
        error: error instanceof Error ? error.message : String(error),
      });
      
      // Return graceful fallback
      return {
        answer: "I encountered an error processing your request. Please try again.",
        sources: [],
        confidence: 0,
        warnings: ['Pipeline error occurred'],
      };
    }
  }

  /**
   * Query with streaming response
   */
  async queryStreaming(
    question: string,
    onToken: (token: string) => void,
    options?: {
      topK?: number;
      includeSources?: boolean;
      systemPrompt?: string;
    }
  ): Promise<RAGResponse> {
    logger.info('RAG pipeline streaming', {
      questionLength: question.length,
    });

    try {
      return await generator.generateStreaming(question, onToken, options);
      
    } catch (error) {
      logger.error('RAG pipeline streaming failed', {
        question,
        error: error instanceof Error ? error.message : String(error),
      });
      
      return {
        answer: "I encountered an error processing your request. Please try again.",
        sources: [],
        confidence: 0,
        warnings: ['Pipeline error occurred'],
      };
    }
  }

  /**
   * Just retrieve documents without generation
   */
  async retrieveOnly(
    question: string,
    topK?: number
  ): Promise<SearchResult[]> {
    return retriever.retrieve(question, { topK });
  }

  /**
   * Update pipeline configuration
   */
  updateConfig(config: Partial<RAGConfig>): void {
    this.config = {
      ...this.config,
      ...config,
    };
    retriever.updateConfig(this.config);
    logger.info('RAG pipeline configuration updated', { config: this.config });
  }

  /**
   * Get pipeline status
   */
  async getStatus(): Promise<Record<string, any>> {
    return {
      config: this.config,
      dbStats: await import('../services/vector-db.js').then(m => m.vectorDB.getStats()),
    };
  }
}

export default new RAGPipeline();
```

---

## Phase 1.5: Main Application Entry

### The Target
Create the main application entry point that ties everything together.

### The Implementation

Create `src/app.ts`:

```typescript
/**
 * Main Application Entry Point
 * Demonstrates the complete RAG system in action
 */

import dotenv from 'dotenv';
import { logger } from './services/logger.js';
import loader from './ingestion/loader.js';
import chunker from './ingestion/chunker.js';
import embedder from './ingestion/embedder.js';
import vectorDB from './services/vector-db.js';
import ragPipeline from './retrieval/pipeline.js';

// Load environment variables
dotenv.config();

/**
 * Main application class
 */
class RAGApplication {
  private initialized = false;

  /**
   * Initialize the application
   */
  async initialize(): Promise<void> {
    if (this.initialized) {
      return;
    }

    logger.info('🚀 Initializing RAG Application');

    try {
      // Check database connection
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

  /**
   * Ingest documents from a directory
   */
  async ingestDocuments(
    directoryPath: string,
    options?: {
      extensionFilter?: string[];
      chunkingStrategy?: string;
      dryRun?: boolean;
    }
  ): Promise<{
    documentsLoaded: number;
    chunksCreated: number;
    chunksStored: number;
  }> {
    logger.info('📄 Starting document ingestion', {
      directoryPath,
      options,
    });

    try {
      // Load documents
      const documents = await loader.loadDirectory(
        directoryPath,
        options?.extensionFilter
      );
      
      if (documents.length === 0) {
        logger.warn('No documents found to ingest');
        return { documentsLoaded: 0, chunksCreated: 0, chunksStored: 0 };
      }

      // Chunk documents
      const chunks = await chunker.chunkDocuments(documents);
      
      if (chunks.length === 0) {
        logger.warn('No chunks created from documents');
        return { documentsLoaded: documents.length, chunksCreated: 0, chunksStored: 0 };
      }

      // Dry run - don't actually store
      if (options?.dryRun) {
        logger.info('Dry run complete (no storage)', {
          documentsLoaded: documents.length,
          chunksCreated: chunks.length,
        });
        return {
          documentsLoaded: documents.length,
          chunksCreated: chunks.length,
          chunksStored: 0,
        };
      }

      // Embed chunks
      const embeddedChunks = await embedder.embedChunks(chunks);
      
      if (embeddedChunks.length === 0) {
        logger.warn('No chunks successfully embedded');
        return {
          documentsLoaded: documents.length,
          chunksCreated: chunks.length,
          chunksStored: 0,
        };
      }

      // Store in vector database
      const storedIds = await vectorDB.storeDocuments(embeddedChunks);

      logger.info('✅ Ingestion complete', {
        documentsLoaded: documents.length,
        chunksCreated: chunks.length,
        chunksStored: storedIds.length,
      });

      return {
        documentsLoaded: documents.length,
        chunksCreated: chunks.length,
        chunksStored: storedIds.length,
      };

    } catch (error) {
      logger.error('Ingestion failed', {
        directoryPath,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * Query the RAG system
   */
  async query(
    question: string,
    options?: {
      topK?: number;
      includeSources?: boolean;
      systemPrompt?: string;
      stream?: boolean;
    }
  ): Promise<any> {
    logger.info('🔍 Querying RAG system', {
      question: question.substring(0, 100),
      options,
    });

    try {
      // Check if we have documents in the database
      const stats = await vectorDB.getStats();
      if (parseInt(stats.total_documents || '0') === 0) {
        return {
          answer: 'No documents have been ingested yet. Please ingest some documents first.',
          sources: [],
          confidence: 0,
          warnings: ['No documents available'],
        };
      }

      // Execute query
      const response = await ragPipeline.query(question, options);

      logger.info('✅ Query complete', {
        confidence: response.confidence,
        sourcesCount: response.sources.length,
        warnings: response.warnings.length,
      });

      return response;

    } catch (error) {
      logger.error('Query failed', {
        question,
        error: error instanceof Error ? error.message : String(error),
      });
      throw error;
    }
  }

  /**
   * Interactive query mode (REPL)
   */
  async interactive(): Promise<void> {
    logger.info('💬 Starting interactive mode');
    console.log('\n' + '='.repeat(60));
    console.log('📚 RAG System Interactive Mode');
    console.log('='.repeat(60));
    console.log('Commands:');
    console.log('  /ingest <path>    - Ingest documents from directory');
    console.log('  /status           - Show system status');
    console.log('  /help             - Show this help');
    console.log('  /exit             - Exit interactive mode');
    console.log('  <question>        - Ask a question');
    console.log('='.repeat(60) + '\n');

    // Use readline for interactive input
    const readline = (await import('readline')).default;
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const askQuestion = (): Promise<void> => {
      return new Promise((resolve) => {
        rl.question('❓ You: ', async (input: string) => {
          const trimmed = input.trim();
          
          if (!trimmed) {
            resolve();
            return;
          }

          // Handle commands
          if (trimmed.startsWith('/')) {
            await this.handleCommand(trimmed, rl);
          } else if (trimmed.toLowerCase() === 'exit' || trimmed.toLowerCase() === 'quit') {
            console.log('👋 Goodbye!');
            rl.close();
            resolve();
            return;
          } else {
            // Regular question
            try {
              console.log('🤖 Thinking...');
              const response = await this.query(trimmed, { includeSources: true });
              
              console.log('\n🤖 Answer:');
              console.log(response.answer);
              
              if (response.sources.length > 0) {
                console.log('\n📚 Sources:');
                response.sources.forEach((source: any, index: number) => {
                  console.log(`  ${index + 1}. (Confidence: ${(source.score * 100).toFixed(1)}%)`);
                  console.log(`     ${source.chunk.content.substring(0, 200)}...`);
                });
              }
              
              if (response.warnings.length > 0) {
                console.log('\n⚠️ Warnings:');
                response.warnings.forEach((warning: string) => {
                  console.log(`  - ${warning}`);
                });
              }
              
              console.log(`\n📊 Confidence: ${(response.confidence * 100).toFixed(1)}%\n`);
              
            } catch (error) {
              console.log(`❌ Error: ${error instanceof Error ? error.message : String(error)}`);
            }
          }
          
          resolve();
        });
      });
    };

    // Main interaction loop
    while (true) {
      await askQuestion();
      // Check if readline is still open
      if (!rl.closed) {
        continue;
      }
      break;
    }
  }

  /**
   * Handle interactive commands
   */
  private async handleCommand(input: string, rl: any): Promise<void> {
    const parts = input.split(' ');
    const command = parts[0].toLowerCase();
    
    switch (command) {
      case '/ingest': {
        const path = parts[1];
        if (!path) {
          console.log('❌ Please provide a directory path: /ingest <path>');
          return;
        }
        console.log(`📄 Ingesting documents from ${path}...`);
        try {
          const result = await this.ingestDocuments(path);
          console.log(`✅ Ingested ${result.documentsLoaded} documents, ${result.chunksStored} chunks`);
        } catch (error) {
          console.log(`❌ Ingestion failed: ${error instanceof Error ? error.message : String(error)}`);
        }
        break;
      }
      
      case '/status': {
        try {
          const status = await ragPipeline.getStatus();
          console.log('\n📊 System Status:');
          console.log(`  Total documents: ${status.dbStats.total_documents || 0}`);
          console.log(`  Config:`, status.config);
        } catch (error) {
          console.log(`❌ Status check failed: ${error instanceof Error ? error.message : String(error)}`);
        }
        break;
      }
      
      case '/help': {
        console.log('\n📚 Commands:');
        console.log('  /ingest <path>    - Ingest documents from directory');
        console.log('  /status           - Show system status');
        console.log('  /help             - Show this help');
        console.log('  /exit             - Exit interactive mode');
        console.log('  <question>        - Ask a question');
        console.log('');
        break;
      }
      
      default:
        console.log(`❌ Unknown command: ${command}. Type /help for available commands.`);
    }
  }

  /**
   * Clean up resources
   */
  async shutdown(): Promise<void> {
    logger.info('🔄 Shutting down application');
    
    try {
      await vectorDB.close();
      chunker.dispose();
      logger.info('✅ Clean shutdown complete');
    } catch (error) {
      logger.error('Error during shutdown', {
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }
}

/**
 * Main entry point
 */
async function main() {
  const app = new RAGApplication();
  
  try {
    // Parse command line arguments
    const args = process.argv.slice(2);
    const isInteractive = args.includes('--interactive') || args.includes('-i');
    const ingestPath = args.find(arg => arg.startsWith('--ingest='))?.split('=')[1];
    const queryText = args.find(arg => arg.startsWith('--query='))?.split('=')[1];
    
    // Initialize
    await app.initialize();
    
    // Handle different modes
    if (ingestPath) {
      // Ingest mode
      const result = await app.ingestDocuments(ingestPath);
      console.log(`✅ Ingestion complete: ${result.documentsLoaded} documents, ${result.chunksStored} chunks`);
      
    } else if (queryText) {
      // Query mode
      const response = await app.query(queryText, { includeSources: true });
      console.log('\n🤖 Answer:');
      console.log(response.answer);
      console.log(`\n📊 Confidence: ${(response.confidence * 100).toFixed(1)}%`);
      
    } else if (isInteractive) {
      // Interactive mode
      await app.interactive();
      
    } else {
      // Default: show help
      console.log(`
📚 RAG System - Command Line Interface

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
    
    // Clean shutdown
    await app.shutdown();
    process.exit(0);
    
  } catch (error) {
    logger.error('Application error', {
      error: error instanceof Error ? error.message : String(error),
    });
    await app.shutdown();
    process.exit(1);
  }
}

// Run main
main();
```

### The Verification

1. **Build and run the application**:

```bash
# Build TypeScript
npm run build

# Start in interactive mode
npm start -- --interactive
```

2. **Ingest a document**:

In the interactive mode, run:
```
/ingest ./docs
```

3. **Test a query**:

Ask a question about the document:
```
What is RAG and how does it work?
```

Expected output:
```
🤖 Answer:
Based on the provided context, RAG (Retrieval-Augmented Generation) is a technique that enhances large language models by providing them with relevant information from external knowledge sources. It operates in three main stages: Document Ingestion (where documents are loaded, chunked, and stored), Query Processing (where user queries are embedded and used to search for relevant documents), and Response Generation (where retrieved documents are combined with the query to generate an answer). The benefits of RAG include reducing hallucinations, enabling access to private or up-to-date information, allowing attribution of sources, and making it easier to update knowledge by updating the document store.

📊 Confidence: 85.3%
```

4. **Non-interactive mode**:

```bash
# Ingest
npm start -- --ingest=./docs

# Query
npm start -- --query="What are the benefits of RAG?"
```

5. **Check status**:

In interactive mode:
```
/status
```

---

## Part 1 Summary

🎉 **Congratulations! You've built a complete RAG system!**

### What You've Accomplished:
- ✅ Set up a production-grade TypeScript project
- ✅ Deployed PostgreSQL with pgvector for vector storage
- ✅ Built a document ingestion pipeline (loader → chunker → embedder → store)
- ✅ Created a retrieval pipeline (query → embed → search → rank)
- ✅ Built a generation pipeline (context → prompt → LLM → answer)
- ✅ Created an interactive CLI for querying and ingestion
- ✅ Implemented proper error handling, logging, and type safety

### System Architecture:
```
┌─────────────────────────────────────────────────────────────┐
│                    Your RAG System                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   Loader     │───▶│   Chunker    │───▶│  Embedder    │ │
│  │  (Files,     │    │  (Semantic   │    │  (OpenAI     │ │
│  │   Directory) │    │   Chunking)  │    │   Models)    │ │
│  └──────────────┘    └──────────────┘    └──────────────┘ │
│         │                    │                    │         │
│         ▼                    ▼                    ▼         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   Vector DB  │    │  Retriever   │    │  Generator   │ │
│  │  (pgvector)  │◀───│  (Similarity │◀───│  (LLM with   │ │
│  │              │    │   Search)    │    │   Context)   │ │
│  └──────────────┘    └──────────────┘    └──────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### What We'll Improve in Part 2:
- 🚀 Hybrid search (BM25 + dense vectors)
- 🚀 Reciprocal Rank Fusion (RRF)
- 🚀 Cross-encoder reranking
- 🚀 Metadata filtering and access control

### Next Steps:
1. Experiment with different chunking strategies
2. Ingest your own documents
3. Try different questions and observe the responses
4. Note areas where retrieval could be improved (this is what we'll fix in Part 2)

---

*Continue to Part 2, where we'll dramatically improve retrieval quality with hybrid search and reranking.*
