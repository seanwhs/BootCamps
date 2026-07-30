# Primer 1: Understanding Vector Embeddings and Semantic Search

## Overview

This primer provides a deep dive into vector embeddings and semantic search—the foundational technology behind modern RAG systems. Unlike the main tutorial series, which focuses on implementation, this primer explores the *why* and *how* behind the technology.

---

## P1.1 What Are Vector Embeddings?

### The Core Concept

Imagine you have a library with millions of books. To find books about "space exploration," you could:
1. Search for exact words ("space," "exploration") → **Lexical search**
2. Understand the *meaning* and find books about related concepts ("cosmos," "astronauts," "NASA") → **Semantic search**

**Vector embeddings** are how computers understand meaning. They convert text (or images, audio, etc.) into **arrays of numbers** that capture semantic meaning.

### The Analogy: Zip Codes for Meaning

Think of embeddings like a **postal system for ideas**:

- **Similar ideas** get similar "zip codes" (nearby vectors)
- **Different ideas** get very different "zip codes" (distant vectors)
- The "zip code" system has thousands of dimensions (like a 1536-digit postal code)

### Visual Representation

```
"King" → [0.2, 0.8, -0.3, 0.5, ...]  ← Vector (1536 numbers)
"Queen" → [0.1, 0.9, -0.2, 0.6, ...]  ← Similar to "King"
"Apple" → [-0.7, 0.1, 0.9, -0.4, ...] ← Far from "King"
```

### Mathematical Representation

A vector is just an ordered list of numbers:

```
Vector v = [v₁, v₂, v₃, ..., vₙ]
```

Where:
- **n** = dimension (e.g., 1536 for text-embedding-3-small)
- Each **vᵢ** is a real number (float)
- Different dimensions capture different semantic features

---

## P1.2 How Embeddings Are Generated

### The Transformer Architecture

Modern embeddings are created using **transformer neural networks**. The process:

1. **Tokenization**: Break text into tokens (words/subwords)
2. **Contextualization**: Use attention mechanisms to understand context
3. **Pooling**: Convert token representations into a single vector
4. **Normalization**: Scale vectors to unit length

### Example: OpenAI's Embedding Pipeline

```
Input: "What is RAG?"
    ↓
[Tokenization]
    ↓
["What", "is", "R", "AG", "?"]
    ↓
[Transformer Layers]
    ↓
[Attention + Context Understanding]
    ↓
[Pooling Layer]
    ↓
[0.2, 0.8, -0.3, 0.5, ...] ← 1536-dimensional vector
```

### Code Example: Generating Embeddings

```typescript
import { OpenAIEmbeddings } from '@langchain/openai';

const embeddings = new OpenAIEmbeddings({
  model: 'text-embedding-3-small',
});

// Single text
const vector = await embeddings.embedQuery('What is RAG?');
console.log(vector.length); // 1536
console.log(vector.slice(0, 5)); // [0.2, 0.8, -0.3, 0.5, 0.1]

// Multiple texts (batched)
const texts = ['What is RAG?', 'How does vector search work?'];
const vectors = await embeddings.embedDocuments(texts);
console.log(vectors.length); // 2
console.log(vectors[0].length); // 1536
```

---

## P1.3 The Mathematics of Similarity

### Cosine Similarity

The most common way to compare vectors is **cosine similarity**:

```
cosine_similarity(A, B) = (A · B) / (||A|| × ||B||)
```

Where:
- **A · B** = dot product (sum of element-wise products)
- **||A||** = magnitude (Euclidean norm) of vector A

### Why Cosine Similarity?

1. **Scale Invariant**: Only direction matters, not magnitude
2. **Normalized**: Results in range [-1, 1]
3. **Intuitive**: 1 = same direction, 0 = orthogonal, -1 = opposite

### Example Calculation

```typescript
// Simple cosine similarity implementation
function cosineSimilarity(a: number[], b: number[]): number {
  let dotProduct = 0;
  let normA = 0;
  let normB = 0;
  
  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  
  return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
}

// Example
const embeddingA = [0.2, 0.8, -0.3];
const embeddingB = [0.1, 0.9, -0.2];
const similarity = cosineSimilarity(embeddingA, embeddingB);
console.log(similarity); // ~0.98 (very similar)
```

### Distance Metrics Comparison

| Metric | Formula | Range | Use Case |
|--------|---------|-------|----------|
| Cosine | 1 - cos(θ) | [0, 2] | Semantic similarity |
| Euclidean | √(Σ(aᵢ - bᵢ)²) | [0, ∞) | Geometric distance |
| Dot Product | Σ(aᵢ × bᵢ) | (-∞, ∞) | Raw similarity |

### pgvector Implementation

```sql
-- Cosine distance (1 - cosine similarity)
SELECT 
  id,
  content,
  1 - (embedding <=> query_embedding) AS similarity
FROM documents
ORDER BY embedding <=> query_embedding
LIMIT 5;

-- Euclidean distance
SELECT 
  id,
  content,
  embedding <-> query_embedding AS distance
FROM documents
ORDER BY embedding <-> query_embedding
LIMIT 5;
```

---

## P1.4 Semantic vs. Lexical Search

### Lexical Search (BM25)

**How it works:**
- Matches exact words
- Uses term frequency and inverse document frequency
- Fast and deterministic

**Example:**
```
Query: "chocolate chip cookie"
Matches: Contains "chocolate" OR "chip" OR "cookie"
```

```typescript
// BM25 scoring
const bm25 = new BM25(documents);
const scores = bm25.score('chocolate chip cookie');
// Returns scores based on term frequency
```

### Semantic Search (Dense Vectors)

**How it works:**
- Matches meaning
- Uses embeddings and vector similarity
- Understands synonyms and context

**Example:**
```
Query: "chocolate chip cookie"
Matches: Related concepts like "baking," "dessert," "recipe"
```

```typescript
// Semantic search
const queryEmbedding = await embedder.embedQuery('chocolate chip cookie');
const results = await vectorDB.similaritySearch(queryEmbedding);
// Returns documents about baking and desserts
```

### Comparison Table

| Aspect | Lexical (BM25) | Semantic (Dense) |
|--------|----------------|------------------|
| **Speed** | Fast | Slower (needs embedding) |
| **Accuracy** | High for exact matches | High for meaning |
| **Synonyms** | ❌ Limited | ✅ Good |
| **Out-of-vocabulary** | ❌ Fails | ✅ Can generalize |
| **Multilingual** | ❌ Per-language | ✅ Cross-lingual |
| **Explainability** | ✅ Transparent | ❌ Black box |

---

## P1.5 Embedding Models Comparison

### OpenAI Models

| Model | Dimension | Cost ($/1K tokens) | Use Case |
|-------|-----------|-------------------|----------|
| text-embedding-3-small | 1536 | $0.00002 | General purpose |
| text-embedding-3-large | 3072 | $0.00013 | High precision |
| text-embedding-ada-002 | 1536 | $0.00010 | Legacy (deprecated) |

### Open-Source Models

| Model | Dimension | Size | Best For |
|-------|-----------|------|----------|
| all-MiniLM-L6-v2 | 384 | 80MB | Fast, lightweight |
| all-mpnet-base-v2 | 768 | 420MB | Good accuracy |
| BAAI/bge-large-en | 1024 | 1.3GB | Best open-source |
| Cohere-embed-english-v3 | 1024 | - | Good balance |

### Choosing an Embedding Model

```typescript
// Configuration by use case
const embeddingConfigs = {
  fast: {
    model: 'text-embedding-3-small',
    dimension: 1536,
    batchSize: 200,
  },
  accurate: {
    model: 'text-embedding-3-large',
    dimension: 3072,
    batchSize: 50,
  },
  local: {
    // Using transformers.js for local embeddings
    model: 'all-MiniLM-L6-v2',
    dimension: 384,
    batchSize: 100,
  },
};
```

---

## P1.6 Semantic Search in Practice

### The Complete Pipeline

```
1. User Query
   ↓
2. Embed Query
   ↓
3. Vector Search
   ↓
4. Retrieve Documents
   ↓
5. Return Results
```

### Code Example: Building a Semantic Search

```typescript
class SemanticSearch {
  constructor(private embedder: OpenAIEmbeddings) {}

  async search(query: string, topK: number = 5) {
    // Step 1: Embed the query
    const queryEmbedding = await this.embedder.embedQuery(query);
    
    // Step 2: Search the vector database
    const results = await vectorDB.similaritySearch(
      queryEmbedding,
      topK
    );
    
    // Step 3: Return results with scores
    return results.map((result, index) => ({
      content: result.chunk.content,
      score: result.score,
      rank: index + 1,
      source: result.chunk.metadata.source,
    }));
  }
}

// Usage
const search = new SemanticSearch(embedder);
const results = await search.search('What is vector search?');
console.log(results);
```

### Optimizing Search Performance

```typescript
// 1. Use approximate nearest neighbor (ANN) indexes
CREATE INDEX documents_embedding_idx 
ON documents 
USING hnsw (embedding vector_cosine_ops);

// 2. Batch queries
const queries = ['query1', 'query2', 'query3'];
const embeddings = await Promise.all(
  queries.map(q => embedder.embedQuery(q))
);

// 3. Cache frequent queries
const cache = new Map();
function cachedSearch(query: string) {
  if (cache.has(query)) {
    return cache.get(query);
  }
  const results = semanticSearch.search(query);
  cache.set(query, results);
  return results;
}

// 4. Use metadata filtering
const results = await vectorDB.similaritySearch(
  queryEmbedding,
  topK,
  threshold,
  { department: 'engineering' } // Only search engineering docs
);
```

---

## P1.7 Common Pitfalls and Solutions

### Pitfall: The "Curse of Dimensionality"

**Problem**: As dimensions increase, vectors become sparse and distances become less meaningful.

**Solution**: Use appropriate dimensionality and normalize vectors.

```typescript
// Normalize vectors to unit length
function normalize(vector: number[]): number[] {
  const magnitude = Math.sqrt(vector.reduce((sum, v) => sum + v * v, 0));
  return vector.map(v => v / magnitude);
}

// Use cosine similarity (which uses normalized vectors internally)
const similarity = cosineSimilarity(normalizedA, normalizedB);
```

### Pitfall: Embedding Drift

**Problem**: Embeddings change over time as models are updated.

**Solution**: Version your embeddings.

```typescript
// Store embedding version
const chunk = {
  id: 'doc-123',
  content: '...',
  embedding: vector,
  metadata: {
    ...metadata,
    embeddingModel: 'text-embedding-3-small',
    embeddingVersion: '2024-01-01',
  },
};

// Re-embed when models change
async function reembedDocuments() {
  const docs = await getDocumentsWithOldEmbeddings();
  for (const doc of docs) {
    const newEmbedding = await embedder.embedText(doc.content);
    await updateDocumentEmbedding(doc.id, newEmbedding);
  }
}
```

### Pitfall: Poor Semantic Alignment

**Problem**: Query embeddings don't match document embeddings well.

**Solution**: Use query expansion.

```typescript
// Expand query with synonyms
async function expandQuery(query: string): Promise<string[]> {
  const response = await llm.invoke(
    `Generate 3 alternative ways to ask: "${query}"`
  );
  return [query, ...JSON.parse(response.content)];
}

// Search with multiple queries
async function robustSearch(query: string) {
  const expandedQueries = await expandQuery(query);
  const allResults = await Promise.all(
    expandedQueries.map(q => semanticSearch.search(q))
  );
  // Merge and deduplicate results
  return mergeResults(allResults);
}
```

---

## P1.8 Advanced Topics

### Multi-Query Retrieval

```typescript
// Generate multiple search queries from one user question
async function generateQueries(question: string): Promise<string[]> {
  const prompt = `
    Generate 3 different search queries for: "${question}"
    Make them different but related.
  `;
  const response = await llm.invoke(prompt);
  return JSON.parse(response.content);
}

// Search with multiple queries and fuse results
async function multiQuerySearch(question: string) {
  const queries = await generateQueries(question);
  const results = await Promise.all(
    queries.map(q => semanticSearch.search(q))
  );
  return fuseResults(results); // Using RRF
}
```

### Hybrid Search Implementation

```typescript
// Combine lexical and semantic search
async function hybridSearch(query: string) {
  // Semantic search
  const denseResults = await semanticSearch.search(query);
  
  // Lexical search
  const lexicalResults = await lexicalSearch.search(query);
  
  // Fuse results
  const fused = fusion.fuse(
    [denseResults, lexicalResults],
    ['dense', 'lexical']
  );
  
  return fused;
}
```

### Embedding Caching

```typescript
import { createHash } from 'crypto';

class EmbeddingCache {
  private cache = new Map<string, number[]>();
  
  async get(text: string): Promise<number[] | null> {
    const key = createHash('sha256').update(text).digest('hex');
    return this.cache.get(key) || null;
  }
  
  async set(text: string, embedding: number[]): Promise<void> {
    const key = createHash('sha256').update(text).digest('hex');
    this.cache.set(key, embedding);
  }
  
  async getOrEmbed(text: string, embedder: OpenAIEmbeddings): Promise<number[]> {
    const cached = await this.get(text);
    if (cached) return cached;
    
    const embedding = await embedder.embedQuery(text);
    await this.set(text, embedding);
    return embedding;
  }
}
```

---

## P1.9 Measuring and Evaluating Search Quality

### Evaluation Metrics

```typescript
// Mean Reciprocal Rank (MRR)
function mrr(results: Array<{ relevance: boolean }>): number {
  for (let i = 0; i < results.length; i++) {
    if (results[i].relevance) {
      return 1 / (i + 1);
    }
  }
  return 0;
}

// Precision@k
function precisionAtK(results: Array<{ relevance: boolean }>, k: number): number {
  const relevant = results.slice(0, k).filter(r => r.relevance).length;
  return relevant / k;
}

// Recall@k
function recallAtK(results: Array<{ relevance: boolean }>, k: number): number {
  const totalRelevant = results.filter(r => r.relevance).length;
  const relevantInK = results.slice(0, k).filter(r => r.relevance).length;
  return totalRelevant > 0 ? relevantInK / totalRelevant : 0;
}

// Normalized Discounted Cumulative Gain (NDCG)
function ndcg(results: Array<{ relevance: number }>, k: number): number {
  // Implementation of NDCG metric
  // ... see full implementation in reference
}
```

### A/B Testing Different Models

```typescript
class EmbeddingModelTest {
  private models: Map<string, OpenAIEmbeddings>;
  
  async test(query: string, testQueries: string[]) {
    const results = {};
    
    for (const [name, model] of this.models) {
      const embedder = new SemanticSearch(model);
      const testResults = [];
      
      for (const testQuery of testQueries) {
        const result = await embedder.search(testQuery);
        testResults.push({
          query: testQuery,
          topResult: result[0]?.content,
          score: result[0]?.score,
        });
      }
      
      results[name] = testResults;
    }
    
    return results;
  }
}
```

---

## P1.10 Real-World Applications

### Document Search

```typescript
class DocumentSearch {
  async findRelevantDocuments(topic: string): Promise<Document[]> {
    const embedding = await embedder.embedQuery(topic);
    const results = await vectorDB.similaritySearch(embedding, 10);
    return results.map(r => r.chunk);
  }
}
```

### Similar Document Detection

```typescript
async function findSimilarDocuments(document: string): Promise<string[]> {
  const embedding = await embedder.embedQuery(document);
  const results = await vectorDB.similaritySearch(embedding, 5);
  return results.map(r => r.chunk.content);
}
```

### Recommendation Systems

```typescript
class RecommendationSystem {
  async getRecommendations(userQuery: string): Promise<any[]> {
    // Find similar content
    const embedding = await embedder.embedQuery(userQuery);
    const similar = await vectorDB.similaritySearch(embedding, 10);
    
    // Extract topics/categories
    const topics = await extractTopics(similar);
    
    // Recommend related content
    return this.getRelatedContent(topics);
  }
}
```

---

## P1.11 Resources and Further Reading

### Academic Papers

1. **Word2Vec**: Mikolov et al. (2013) - "Efficient Estimation of Word Representations in Vector Space"
2. **BERT**: Devlin et al. (2018) - "BERT: Pre-training of Deep Bidirectional Transformers"
3. **Dense Passage Retrieval**: Karpukhin et al. (2020) - "Dense Passage Retrieval for Open-Domain Question Answering"
4. **SBERT**: Reimers & Gurevych (2019) - "Sentence-BERT: Sentence Embeddings using Siamese BERT-Networks"

### Online Resources

- **OpenAI Embeddings Guide**: https://platform.openai.com/docs/guides/embeddings
- **Hugging Face Sentence Transformers**: https://www.sbert.net/
- **Cohere Embeddings**: https://docs.cohere.com/docs/embeddings
- **RAG Best Practices**: https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-rag.html

### Code Examples

- **pgvector Examples**: https://github.com/pgvector/pgvector
- **LangChain Embeddings**: https://js.langchain.com/docs/modules/data_connection/text_embedding/
- **OpenAI Cookbook**: https://cookbook.openai.com/

---

## P1.12 Quick Reference

### Common Embedding Functions

```typescript
// Generate embedding
const embedding = await embedder.embedQuery(text);

// Compare embeddings
const similarity = cosineSimilarity(embedding1, embedding2);

// Search vectors
const results = await vectorDB.similaritySearch(embedding, topK);

// Batch embed
const embeddings = await embedder.embedDocuments(texts);

// Normalize embedding
const normalized = normalize(embedding);
```

### Useful Constants

```typescript
// OpenAI embedding dimensions
const OPENAI_SMALL_DIM = 1536;  // text-embedding-3-small
const OPENAI_LARGE_DIM = 3072;  // text-embedding-3-large

// Common similarity thresholds
const HIGH_SIMILARITY = 0.8;
const MEDIUM_SIMILARITY = 0.6;
const LOW_SIMILARITY = 0.4;

// Batch sizes
const EMBEDDING_BATCH_SIZE = 100;
const SEARCH_BATCH_SIZE = 10;
```

---

**[PRIMER 1 — COMPLETE]**

*Continue to Primer 2: Understanding RAG Architecture and Design Patterns.*
