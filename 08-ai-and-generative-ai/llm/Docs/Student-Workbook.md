# Student Workbook: Beneath the Surface — Demystifying LLMs, Transformers, and Distillation

## A Hands-On Developer Workbook

---

# INTRODUCTION TO THE WORKBOOK

## Welcome!

This workbook is designed to accompany the "Beneath the Surface" tutorial series. It contains:

- **📝 Exercises** - Hands-on coding challenges for each module
- **✏️ Fill-in-the-Blank** - Key concepts to complete
- **❓ Quiz Questions** - Test your understanding
- **📊 Cheat Sheets** - Quick reference for key concepts
- **📋 Lab Activities** - Guided coding sessions
- **📈 Progress Tracking** - Check your understanding

## How to Use This Workbook

1. **Before Each Module**: Read the section and complete the pre-quiz
2. **During Each Module**: Complete the exercises and labs
3. **After Each Module**: Take the post-quiz and review cheat sheets
4. **Track Your Progress**: Use the progress tracker at the end

---

# MODULE 0: INTRODUCTION

## Pre-Module Self-Assessment

**Rate your current understanding (1-5):**

___ I understand what an LLM is and how it works
___ I understand the difference between APIs and self-hosted models
___ I can explain what tokenization is
___ I understand why transformers are important
___ I can write basic JavaScript/Node.js code

**Goals for this module:**
1. _________________________________
2. _________________________________
3. _________________________________

## Key Vocabulary

**Fill in the definitions:**

1. **LLM**: _____________________________________________
2. **Tokenization**: ________________________________________
3. **Embedding**: __________________________________________
4. **Transformer**: _______________________________________
5. **Distillation**: _______________________________________

## Module 0 Exercises

### Exercise 0.1: Project Setup

**Complete these steps:**

```bash
# 1. Create project directory
mkdir llm-from-scratch && cd llm-from-scratch

# 2. Initialize npm
npm init -y

# 3. Create directory structure
mkdir -p src/{tokenizer,transformer,distillation,inference,utils}
mkdir -p models data tests

# 4. Verify structure
ls -la
```

**Expected output:**
```
llm-from-scratch/
├── src/
│   ├── tokenizer/
│   ├── transformer/
│   ├── distillation/
│   ├── inference/
│   └── utils/
├── models/
├── data/
├── tests/
└── package.json
```

**Check your understanding:**
- Why do we need this structure? ________________________________
- What will go in each directory? ________________________________

### Exercise 0.2: Environment Configuration

**Create your .env file:**

```bash
# .env
MODEL_CACHE_DIR="./models/cache"
PORT=3000
LOG_LEVEL=info
DEBUG_MODE=true
```

**Questions:**
1. Why shouldn't we commit .env to Git? __________________________

2. What environment variable would you change for production? ______

### Exercise 0.3: Mental Model Reflection

**Answer these questions in 2-3 sentences:**

1. What is an LLM in your own words?
____________________________________________________________
____________________________________________________________

2. What do you hope to build with this knowledge?
____________________________________________________________
____________________________________________________________

3. What's the most confusing concept about LLMs for you?
____________________________________________________________
____________________________________________________________

---

## Module 0 Quiz

1. **True or False**: LLMs are "thinking brains" that understand meaning like humans.

2. **What is the primary purpose of tokenization?**
   a) To make text colorful
   b) To convert text to numbers
   c) To delete unnecessary words
   d) To encrypt the text

3. **Which of these is NOT part of the series architecture?**
   a) Tokenization
   b) Transformer
   c) Quantum computing
   d) Distillation

4. **What is the main difference between using an API and self-hosting?**
   ____________________________________________________________

5. **Name three prerequisites for this series.**
   - __________________
   - __________________
   - __________________

**Answer Key (cover before checking):**
1. False (LLMs are prediction engines)
2. b
3. c
4. API is easier but more expensive; self-hosting requires more setup but is cheaper at scale
5. JavaScript, Node.js, basic math (high school level)

---

# MODULE 1: ANATOMY OF AN LLM — TEXT TO PREDICTIONS

## Learning Objectives Checklist

- [ ] I understand why text needs to be converted to numbers
- [ ] I can explain BPE tokenization
- [ ] I know what embeddings are and why they matter
- [ ] I can implement a tokenizer from scratch
- [ ] I understand semantic similarity
- [ ] I can visualize embeddings

## Key Vocabulary

**Define these terms:**

1. **Byte-Pair Encoding (BPE)**: ________________________________
____________________________________________________________

2. **Vocabulary**: _____________________________________________
____________________________________________________________

3. **Embedding Vector**: _______________________________________
____________________________________________________________

4. **Cosine Similarity**: _______________________________________
____________________________________________________________

5. **Semantic Space**: _________________________________________
____________________________________________________________

6. **Special Tokens**: _________________________________________
____________________________________________________________

7. **Pre-training**: ___________________________________________
____________________________________________________________

## Module 1 Exercises

### Exercise 1.1: Implementing BPE Tokenizer

**Fill in the missing code:**

```javascript
// 📁 src/tokenizer/bpe-tokenizer.js

export class BPETokenizer {
    constructor(config = {}) {
        this.vocabSize = config.vocabSize || 1000;
        this.specialTokens = config.specialTokens || ['<|endoftext|>', '<|pad|>'];
        this.vocabulary = new _____();  // What type?
        this.inverseVocabulary = new _____();  // What type?
        this.mergeRules = [];
        this.initialTokens = new Set();
    }

    train(corpus) {
        console.log(`[Tokenizer] Training on corpus of ${corpus.length} characters...`);
        
        // Step 1: Initialize vocabulary
        this._initializeVocabulary(corpus);
        console.log(`[Tokenizer] Initial vocabulary: ${this.vocabulary.size} tokens`);
        
        // Step 2: Perform BPE merges
        while (this.vocabulary.size < this.vocabSize) {
            const bestPair = this._findMostFrequentPair(corpus);
            if (!bestPair) break;
            this._performMerge(bestPair, corpus);
            this.stats.mergesPerformed++;
        }
        
        console.log(`[Tokenizer] Training complete! Vocabulary size: ${this.vocabulary.size}`);
        return this;
    }

    _initializeVocabulary(corpus) {
        // HINT: Start with characters from corpus
        const chars = new Set(________);  // What goes here?
        
        // Add special tokens first
        let nextId = 0;
        for (const specialToken of this.specialTokens) {
            this.vocabulary.set(________, nextId);
            this.inverseVocabulary.set(________, specialToken);
            nextId++;
        }
        
        // Add all characters
        for (const char of chars) {
            if (this.vocabulary.has(char)) continue;
            this.vocabulary.set(________, nextId);
            this.inverseVocabulary.set(________, char);
            nextId++;
        }
    }

    encode(text) {
        if (this.vocabulary.size === 0) {
            throw new Error('Tokenizer must be trained before encoding');
        }
        
        const tokens = this._applyBPETokenization(text);
        const tokenIds = tokens.map(token => {
            const id = this.vocabulary.get(________);
            if (id === undefined) {
                // Fallback to first character
                const fallbackId = this.vocabulary.get(token[0]);
                if (fallbackId === undefined) {
                    throw new Error(`Unknown token: "${token}"`);
                }
                return fallbackId;
            }
            return id;
        });
        
        return tokenIds;
    }

    decode(tokenIds) {
        const tokens = tokenIds.map(id => {
            const token = this.inverseVocabulary.get(________);
            if (token === undefined) {
                throw new Error(`Unknown token ID: ${id}`);
            }
            return token;
        });
        return tokens.join('');
    }
}
```

**Question:** What data types are used for vocabulary and inverse vocabulary? Why? ____________________________________________________________

### Exercise 1.2: Vocabulary Management

**Implement the missing methods:**

```javascript
// 📁 src/tokenizer/vocabulary.js

export class Vocabulary {
    constructor(config = {}) {
        this.maxSize = config.maxSize || 50000;
        this.specialTokens = config.specialTokens || ['<|endoftext|>', '<|pad|>', '<|unk|>'];
        this.tokenToId = new Map();
        this.idToToken = new Map();
        this.frequencies = new Map();
        this._initializeSpecialTokens();
    }

    _initializeSpecialTokens() {
        // HINT: Add special tokens to both maps
        for (let i = 0; i < this.specialTokens.length; i++) {
            const token = this.specialTokens[i];
            this.tokenToId.set(________, i);
            this.idToToken.set(________, token);
            this.frequencies.set(token, 0);
        }
    }

    addToken(token) {
        if (this.tokenToId.has(token)) {
            return this.tokenToId.get(________);
        }
        
        if (this.tokenToId.size >= this.maxSize) {
            throw new Error(`Vocabulary is full (max size: ${this.maxSize})`);
        }
        
        const id = this.tokenToId.size;
        this.tokenToId.set(________, id);
        this.idToToken.set(________, token);
        this.frequencies.set(token, 0);
        return id;
    }

    getTokenId(token) {
        if (this.tokenToId.has(________)) {
            return this.tokenToId.get(________);
        }
        
        const unknownToken = '<|unk|>';
        if (this.tokenToId.has(unknownToken)) {
            return this.tokenToId.get(unknownToken);
        }
        
        throw new Error(`Token "${token}" not found in vocabulary`);
    }

    prune(targetSize) {
        // HINT: Remove least frequent tokens
        // Keep special tokens
        const sortedTokens = Array.from(this.frequencies.entries())
            .sort((a, b) => a[1] - b[1]);
        
        let removed = 0;
        for (const [token, freq] of sortedTokens) {
            if (this.specialTokens.includes(token)) continue;
            // Remove token
            const id = this.tokenToId.get(token);
            this.tokenToId.delete(________);
            this.idToToken.delete(________);
            this.frequencies.delete(________);
            removed++;
            if (removed >= this.tokenToId.size - targetSize) break;
        }
    }
}
```

**Questions:**
1. Why do we need special tokens? _______________________________
____________________________________________________________

2. What happens if we try to add a token when the vocabulary is full? ______
____________________________________________________________

3. How does pruning help manage vocabulary size? _________________
____________________________________________________________

### Exercise 1.3: Embedding System

**Complete the implementation:**

```javascript
// 📁 src/tokenizer/embeddings.js

import { randomNormal } from '../utils/math-utils.js';

export class EmbeddingSystem {
    constructor(config = {}) {
        this.vocabSize = config.vocabSize || 1000;
        this.embeddingDim = config.embeddingDim || 64;
        this.embeddings = null;
        this.initializer = config.initializer || this._defaultInitializer.bind(this);
        this.initialize();
        this.cache = new Map();
        this.cacheSize = config.cacheSize || 1000;
    }

    _defaultInitializer() {
        // HINT: Xavier/Glorot initialization
        const scale = Math.sqrt(________ / this.embeddingDim);  // What factor?
        const mean = 0;
        const std = scale;
        
        const embeddings = [];
        for (let i = 0; i < this.vocabSize; i++) {
            const vector = [];
            for (let j = 0; j < this.embeddingDim; j++) {
                // Box-Muller transform for normal distribution
                let u1 = Math.random();
                let u2 = Math.random();
                while (u1 === 0) u1 = Math.random();
                while (u2 === 0) u2 = Math.random();
                const z = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
                vector.push(mean + std * z);
            }
            embeddings.push(vector);
        }
        return embeddings;
    }

    getEmbedding(tokenId) {
        // HINT: Check cache first
        if (this.cache.has(________)) {
            return this.cache.get(________);
        }
        
        if (tokenId < 0 || tokenId >= this.vocabSize) {
            throw new Error(`Token ID ${tokenId} out of range`);
        }
        
        const embedding = [...this.embeddings[________]];
        this.cache.set(________, embedding);
        
        // HINT: Manage cache size
        if (this.cache.size > this.cacheSize) {
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        
        return embedding;
    }

    computeSimilarity(tokenId1, tokenId2) {
        const emb1 = this.getEmbedding(________);
        const emb2 = this.getEmbedding(________);
        return this._cosineSimilarity(emb1, emb2);
    }

    _cosineSimilarity(vec1, vec2) {
        // HINT: Compute dot product and norms
        let dotProduct = 0;
        let norm1 = 0;
        let norm2 = 0;
        
        for (let i = 0; i < vec1.length; i++) {
            dotProduct += vec1[i] * vec2[i];
            norm1 += vec1[i] * vec1[i];
            norm2 += vec2[i] * vec2[i];
        }
        
        norm1 = Math.sqrt(norm1);
        norm2 = Math.sqrt(norm2);
        
        if (norm1 === 0 || norm2 === 0) return 0;
        return ________ / (________ * ________);
    }

    findNearestNeighbors(tokenId, n = 5) {
        const queryEmbedding = this.getEmbedding(________);
        const similarities = [];
        
        for (let i = 0; i < this.vocabSize; i++) {
            if (i === tokenId) continue;
            const similarity = this._cosineSimilarity(________, this.embeddings[i]);
            similarities.push({ tokenId: i, similarity });
        }
        
        similarities.sort((a, b) => b.similarity - a.similarity);
        return similarities.slice(0, n);
    }
}
```

**Questions:**
1. Why do we use a cache for embeddings? ________________________
____________________________________________________________

2. What is the purpose of the scaling factor in initialization? ______
____________________________________________________________

3. Why is cosine similarity used instead of Euclidean distance? _____
____________________________________________________________

### Exercise 1.4: Tokenization Pipeline

**Create the complete pipeline:**

```javascript
// 📁 src/tokenizer/pipeline.js

import { BPETokenizer } from './bpe-tokenizer.js';
import { Vocabulary } from './vocabulary.js';
import { EmbeddingSystem } from './embeddings.js';
import { normalizeText } from './token-utils.js';

export class TextProcessingPipeline {
    constructor(config = {}) {
        this.config = {
            vocabSize: config.vocabSize || 1000,
            embeddingDim: config.embeddingDim || 64,
            specialTokens: config.specialTokens || ['<|endoftext|>', '<|pad|>', '<|unk|>']
        };
        
        // HINT: Initialize all components
        this.tokenizer = new BPETokenizer({
            vocabSize: this.config.vocabSize,
            specialTokens: this.config.specialTokens
        });
        
        this.vocabulary = new Vocabulary({
            maxSize: this.config.vocabSize,
            specialTokens: this.config.specialTokens
        });
        
        this.embeddings = new EmbeddingSystem({
            vocabSize: this.config.vocabSize,
            embeddingDim: this.config.embeddingDim
        });
        
        this.isTrained = false;
        this.stats = {
            totalProcessed: 0,
            totalTokens: 0
        };
    }

    train(corpus) {
        console.log('[Pipeline] Starting training...');
        
        // Step 1: Train tokenizer
        console.log('[Pipeline] Step 1: Training tokenizer...');
        this.tokenizer.________(corpus);  // What method?
        
        // Step 2: Build vocabulary
        console.log('[Pipeline] Step 2: Building vocabulary...');
        this._buildVocabularyFromTokenizer();
        
        // Step 3: Initialize embeddings
        console.log('[Pipeline] Step 3: Initializing embeddings...');
        this.embeddings.________();  // What method?
        
        this.isTrained = true;
        console.log('[Pipeline] Training complete!');
        return this;
    }

    processText(text) {
        if (!this.isTrained) {
            throw new Error('Pipeline must be trained first');
        }
        
        const normalized = normalizeText(________);  // What goes here?
        const tokenIds = this.tokenizer.________(normalized);  // What method?
        const embeddings = this.embeddings.________(tokenIds);  // What method?
        
        this.stats.totalProcessed++;
        this.stats.totalTokens += tokenIds.length;
        
        return {
            original: text,
            normalized: normalized,
            tokenIds: tokenIds,
            tokens: tokenIds.map(id => this.vocabulary.getToken(________)),
            embeddings: embeddings
        };
    }

    findSimilar(text, n = 5) {
        const processed = this.processText(________);
        if (processed.tokenIds.length === 0) return [];
        
        const queryTokenId = processed.tokenIds[0];
        const neighbors = this.embeddings.findNearestNeighbors(________, n);
        
        return neighbors.map(({ tokenId, similarity }) => ({
            token: this.vocabulary.getToken(________),
            similarity: similarity,
            tokenId: tokenId
        }));
    }
}
```

### Lab 1.1: Building Your First Tokenizer

**Step-by-Step Lab:**

1. **Create the tokenizer file:**
```bash
touch src/tokenizer/bpe-tokenizer.js
```

2. **Implement the BPETokenizer class** using the code from Exercise 1.1

3. **Test your tokenizer:**
```javascript
// src/test-tokenizer.js
import { BPETokenizer } from './tokenizer/bpe-tokenizer.js';

const tokenizer = new BPETokenizer({ vocabSize: 50 });
const corpus = "The quick brown fox jumps over the lazy dog.";
tokenizer.train(corpus);

const text = "The quick brown";
const ids = tokenizer.encode(text);
const decoded = tokenizer.decode(ids);

console.log("Original:", text);
console.log("IDs:", ids);
console.log("Decoded:", decoded);
```

4. **Run the test:**
```bash
node src/test-tokenizer.js
```

**Expected output:**
```
Original: The quick brown
IDs: [42, 156, 203]
Decoded: The quick brown
```

### Lab 1.2: Exploring Embedding Space

**Step-by-Step Lab:**

1. **Create the embedding visualizer:**
```javascript
// src/explore-embeddings.js
import { TextProcessingPipeline } from './tokenizer/pipeline.js';

const pipeline = new TextProcessingPipeline({
    vocabSize: 100,
    embeddingDim: 16
});

const corpus = `
cat dog bird fish animal pet
car truck bus vehicle transport
apple orange fruit banana
`;

pipeline.train(corpus);

const words = ['cat', 'dog', 'car', 'apple'];
for (const word of words) {
    const similar = pipeline.findSimilar(word, 3);
    console.log(`\nWords similar to "${word}":`);
    for (const { token, similarity } of similar) {
        console.log(`  ${token}: ${similarity.toFixed(3)}`);
    }
}
```

2. **Run the exploration:**
```bash
node src/explore-embeddings.js
```

3. **Questions to answer:**
   - Which words are most similar to "cat"? _____________________
   - Which words are most similar to "car"? _____________________
   - Why are "cat" and "dog" more similar than "cat" and "car"? ____________________________________________________________

### Lab 1.3: Semantic Search Engine

**Implement a simple semantic search:**

```javascript
// src/semantic-search.js
import { TextProcessingPipeline } from './tokenizer/pipeline.js';

class SemanticSearch {
    constructor(corpus) {
        this.pipeline = new TextProcessingPipeline({
            vocabSize: 500,
            embeddingDim: 32
        });
        this.pipeline.train(corpus);
        this.documents = [];
        this.docEmbeddings = [];
    }

    addDocument(text) {
        // HINT: Process the text and store the embedding
        const processed = this.pipeline.processText(________);
        const embedding = processed.embeddings[0]; // Use first token's embedding
        
        this.documents.push(________);
        this.docEmbeddings.push(________);
    }

    search(query, n = 3) {
        // HINT: Find most similar documents
        const processed = this.pipeline.processText(________);
        const queryEmbedding = processed.embeddings[0];
        
        const similarities = this.docEmbeddings.map((emb, i) => ({
            index: i,
            similarity: this._cosineSimilarity(queryEmbedding, emb)
        }));
        
        similarities.sort((a, b) => b.similarity - a.similarity);
        return similarities.slice(0, n).map(({ index, similarity }) => ({
            document: this.documents[index],
            similarity: similarity
        }));
    }

    _cosineSimilarity(a, b) {
        // HINT: Implement cosine similarity
        let dot = 0, normA = 0, normB = 0;
        for (let i = 0; i < a.length; i++) {
            dot += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }
        return dot / (Math.sqrt(normA) * Math.sqrt(normB));
    }
}

// Test the search
const corpus = `
The cat sat on the mat.
The dog played in the garden.
Cars drive on the road.
Apples grow on trees.
`;

const search = new SemanticSearch(corpus);
search.addDocument("The cat is sleeping.");
search.addDocument("The dog is running.");
search.addDocument("The car is fast.");
search.addDocument("The apple is red.");

const results = search.search("animal", 2);
console.log("\nSearch results for 'animal':");
for (const result of results) {
    console.log(`  ${result.document} (similarity: ${result.similarity.toFixed(3)})`);
}
```

## Module 1 Quiz

**1. What is the main advantage of BPE over word-level tokenization?**
   a) It's faster
   b) It handles unknown words better
   c) It uses less memory
   d) All of the above

**2. What is the purpose of special tokens like [PAD]?**
   ____________________________________________________________

**3. True or False: Embeddings capture semantic meaning because similar words have similar vectors.**

**4. What does cosine similarity measure?**
   a) The distance between two vectors
   b) The angle between two vectors
   c) The difference between two vectors
   d) The product of two vectors

**5. Why do we use high-dimensional embeddings instead of 2D or 3D?**
   ____________________________________________________________

**6. What is the relationship between tokenization and embeddings?**
   ____________________________________________________________

**7. Write the formula for cosine similarity:**
   ____________________________________________________________

**8. What happens to a word that isn't in the vocabulary during encoding?**
   ____________________________________________________________

**Answer Key:**
1. d
2. They control model behavior (padding, start/end, unknown tokens)
3. True
4. b
5. Higher dimensions can capture more nuance and relationships
6. Tokenization converts text to IDs; embeddings convert IDs to vectors
7. cos(θ) = (A·B) / (||A||·||B||)
8. It's either replaced with [UNK] token or split into subword units

## Module 1 Cheat Sheet

```
┌─────────────────────────────────────────────────────────────┐
│  TEXT PROCESSING PIPELINE                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Text → Tokenization → IDs → Embeddings → Vectors           │
│                                                              │
│  BPE Tokenizer:                                             │
│  • Starts with characters                                   │
│  • Merges most frequent pairs                               │
│  • Creates subword vocabulary                              │
│                                                              │
│  Embeddings:                                                │
│  • Dense vectors (64-1024 dims)                             │
│  • Semantic meaning encoded                                │
│  • Similar words cluster together                          │
│                                                              │
│  Cosine Similarity:                                         │
│  • Measures angle between vectors                          │
│  • Range: -1 to 1                                         │
│  • 1 = identical, 0 = unrelated, -1 = opposite             │
│                                                              │
│  Special Tokens:                                            │
│  [BOS] Beginning of sequence                               │
│  [EOS] End of sequence                                    │
│  [PAD] Padding                                            │
│  [UNK] Unknown                                            │
└─────────────────────────────────────────────────────────────┘
```

---

# MODULE 2: THE TRANSFORMER REVOLUTION

## Learning Objectives Checklist

- [ ] I understand why RNNs struggled with long sequences
- [ ] I can explain the attention mechanism
- [ ] I know what Q, K, and V represent
- [ ] I can implement multi-head attention
- [ ] I understand positional encodings
- [ ] I can generate text with a transformer

## Key Vocabulary

**Define these terms:**

1. **Self-Attention**: _________________________________________
____________________________________________________________

2. **Multi-Head Attention**: ___________________________________
____________________________________________________________

3. **Q, K, V (Query, Key, Value)**: ___________________________
____________________________________________________________

4. **Positional Encoding**: ___________________________________
____________________________________________________________

5. **Causal Mask**: ___________________________________________
____________________________________________________________

6. **Autoregressive Generation**: _____________________________
____________________________________________________________

7. **Temperature Sampling**: __________________________________
____________________________________________________________

## Module 2 Exercises

### Exercise 2.1: Attention Implementation

**Complete the attention function:**

```javascript
// 📁 src/transformer/attention.js

import { dotProduct, softmax, matrixMultiply, transpose } from '../utils/math-utils.js';

export function scaledDotProductAttention(Q, K, V, mask = null, scale = null) {
    // Q: [seq_len, d_k]
    // K: [seq_len, d_k]
    // V: [seq_len, d_v]
    
    const d_k = Q[0].length;
    const scaleFactor = scale || Math.sqrt(________);  // What goes here?
    
    // Step 1: Compute Q * K^T (attention scores)
    const K_T = transpose(________);  // What goes here?
    const scores = matrixMultiply(________, K_T);
    
    // Step 2: Scale the scores
    const scaledScores = scores.map(row => 
        row.map(val => val / scaleFactor)
    );
    
    // Step 3: Apply mask (if provided)
    let maskedScores = scaledScores;
    if (mask) {
        maskedScores = scaledScores.map((row, i) =>
            row.map((val, j) => mask[i][j] ? val : -1e9)
        );
    }
    
    // Step 4: Apply softmax
    const attentionWeights = maskedScores.map(row => softmax(________));
    
    // Step 5: Multiply by V
    const output = matrixMultiply(attentionWeights, ________);
    
    return {
        output: output,
        attentionWeights: attentionWeights
    };
}

export class MultiHeadAttention {
    constructor(config = {}) {
        this.d_model = config.d_model || 512;
        this.numHeads = config.numHeads || 8;
        this.d_k = config.d_k || this.d_model / this.numHeads;
        this.d_v = config.d_v || this.d_model / this.numHeads;
        this.dropout = config.dropout || 0.1;
        
        if (this.d_model % this.numHeads !== 0) {
            throw new Error(`d_model (${this.d_model}) must be divisible by numHeads (${this.numHeads})`);
        }
        
        // Initialize weight matrices
        this.W_Q = this._initializeWeights(this.d_model, this.d_k * this.numHeads);
        this.W_K = this._initializeWeights(________, ________);
        this.W_V = this._initializeWeights(________, ________);
        this.W_O = this._initializeWeights(this.d_v * this.numHeads, this.d_model);
    }

    forward(X, mask = null) {
        const seqLen = X.length;
        
        // Step 1: Linear projections
        const Q = matrixMultiply(________, this.W_Q);
        const K = matrixMultiply(________, this.W_K);
        const V = matrixMultiply(________, this.W_V);
        
        // Step 2: Split into heads
        const Q_heads = this._splitHeads(________);
        const K_heads = this._splitHeads(________);
        const V_heads = this._splitHeads(________);
        
        // Step 3: Apply attention for each head
        const headOutputs = [];
        const headWeights = [];
        
        for (let h = 0; h < this.numHeads; h++) {
            const { output, attentionWeights } = scaledDotProductAttention(
                Q_heads[h], K_heads[h], V_heads[h], mask
            );
            headOutputs.push(________);
            headWeights.push(________);
        }
        
        // Step 4: Concatenate heads
        const concatenated = this._concatenateHeads(________);
        
        // Step 5: Final projection
        const output = matrixMultiply(concatenated, this.W_O);
        
        return {
            output: output,
            attentionWeights: headWeights
        };
    }
}
```

**Questions:**
1. Why do we scale the attention scores by √d_k? _________________
____________________________________________________________

2. What is the purpose of the mask parameter? ___________________
____________________________________________________________

3. Why do we need multiple attention heads? _____________________
____________________________________________________________

### Exercise 2.2: Positional Encodings

**Complete the implementation:**

```javascript
// 📁 src/transformer/positional.js

export function generatePositionalEncodings(seqLen, d_model, maxLen = 10000) {
    const positions = [];
    
    for (let pos = 0; pos < seqLen; pos++) {
        const encoding = [];
        for (let i = 0; i < d_model; i++) {
            const angle = pos / Math.pow(maxLen, (2 * i) / d_model);
            if (i % 2 === 0) {
                encoding.push(Math.sin(________));  // What goes here?
            } else {
                encoding.push(Math.cos(________));  // What goes here?
            }
        }
        positions.push(encoding);
    }
    
    return positions;
}

export function addPositionalEncodings(embeddings, positionalEncodings) {
    if (embeddings.length !== positionalEncodings.length) {
        throw new Error(`Embeddings length (${embeddings.length}) must match positional encodings length (${positionalEncodings.length})`);
    }
    
    const result = [];
    for (let i = 0; i < embeddings.length; i++) {
        const combined = [];
        for (let j = 0; j < embeddings[i].length; j++) {
            combined.push(embeddings[i][j] + positionalEncodings[i][j]);
        }
        result.push(combined);
    }
    return result;
}

export class LearnedPositionalEmbeddings {
    constructor(config = {}) {
        this.maxLen = config.maxLen || 10000;
        this.d_model = config.d_model || 512;
        this.embeddings = this._initializeEmbeddings();
    }

    _initializeEmbeddings() {
        const embeddings = [];
        const scale = 0.02;
        
        for (let pos = 0; pos < this.maxLen; pos++) {
            const embedding = [];
            for (let i = 0; i < this.d_model; i++) {
                embedding.push((Math.random() * 2 - 1) * scale);
            }
            embeddings.push(embedding);
        }
        return embeddings;
    }

    forward(seqLen) {
        if (seqLen > this.maxLen) {
            throw new Error(`Sequence length ${seqLen} exceeds max length ${this.maxLen}`);
        }
        return this.embeddings.slice(0, seqLen);
    }
}
```

**Questions:**
1. What is the difference between sinusoidal and learned positional encodings? ____________________________________________________________

2. Why do we need positional encodings in transformers? _________
____________________________________________________________

3. What happens if we don't use positional encodings? ___________
____________________________________________________________

### Exercise 2.3: Complete Transformer

**Fill in the missing parts:**

```javascript
// 📁 src/transformer/transformer.js

import { MultiHeadAttention } from './attention.js';
import { generatePositionalEncodings, addPositionalEncodings } from './positional.js';
import { matrixAdd } from '../utils/math-utils.js';

export class FeedForward {
    constructor(config = {}) {
        this.d_model = config.d_model || 512;
        this.d_ff = config.d_ff || 4 * this.d_model;
        this.dropout = config.dropout || 0.1;
        
        this.W1 = this._initializeWeights(this.d_model, this.d_ff);
        this.b1 = new Array(this.d_ff).fill(0);
        this.W2 = this._initializeWeights(this.d_ff, this.d_model);
        this.b2 = new Array(this.d_model).fill(0);
    }

    forward(X) {
        // HINT: Two linear layers with ReLU
        // Layer 1: X @ W1 + b1 -> ReLU
        const hidden = X.map(row => {
            const h = [];
            for (let j = 0; j < this.d_ff; j++) {
                let sum = this.b1[j];
                for (let i = 0; i < this.d_model; i++) {
                    sum += row[i] * this.W1[i][j];
                }
                h.push(Math.max(0, sum));  // ReLU activation
            }
            return h;
        });
        
        // Layer 2: hidden @ W2 + b2
        const output = hidden.map(row => {
            const out = [];
            for (let j = 0; j < this.d_model; j++) {
                let sum = this.b2[j];
                for (let i = 0; i < this.d_ff; i++) {
                    sum += row[i] * this.W2[i][j];
                }
                out.push(sum);
            }
            return out;
        });
        
        return output;
    }
}

export class TransformerBlock {
    constructor(config = {}) {
        this.d_model = config.d_model || 512;
        this.numHeads = config.numHeads || 8;
        this.d_ff = config.d_ff || 4 * this.d_model;
        this.dropout = config.dropout || 0.1;
        
        this.attention = new MultiHeadAttention({
            d_model: this.d_model,
            numHeads: this.numHeads,
            dropout: this.dropout
        });
        
        this.feedForward = new FeedForward({
            d_model: this.d_model,
            d_ff: this.d_ff,
            dropout: this.dropout
        });
        
        this.norm1 = new LayerNorm(this.d_model);
        this.norm2 = new LayerNorm(this.d_model);
    }

    forward(X, mask = null) {
        // HINT: Attention + residual + norm
        const attentionOutput = this.attention.forward(________, mask);
        const attended = matrixAdd(________, attentionOutput.output);
        const normalized1 = this.norm1.forward(attended);
        
        // HINT: Feed-forward + residual + norm
        const ffOutput = this.feedForward.forward(________);
        const ffAdded = matrixAdd(normalized1, ffOutput);
        const normalized2 = this.norm2.forward(ffAdded);
        
        return {
            output: normalized2,
            attentionWeights: attentionOutput.attentionWeights
        };
    }
}

export class LayerNorm {
    constructor(d_model, eps = 1e-6) {
        this.d_model = d_model;
        this.eps = eps;
        this.gamma = new Array(d_model).fill(1);
        this.beta = new Array(d_model).fill(0);
    }

    forward(X) {
        return X.map(row => {
            // HINT: Compute mean and variance
            const mean = row.reduce((a, b) => a + b, 0) / row.length;
            const variance = row.reduce((a, b) => a + (b - mean) ** 2, 0) / row.length;
            
            // HINT: Normalize, scale, and shift
            const normalized = row.map(x => 
                (x - mean) / Math.sqrt(variance + this.eps)
            );
            return normalized.map((x, i) => 
                this.gamma[i] * x + this.beta[i]
            );
        });
    }
}
```

### Lab 2.1: Building a Tiny Transformer

**Step-by-Step Lab:**

1. **Create a tiny transformer:**
```javascript
// src/tiny-transformer.js
import { Transformer } from './transformer/transformer.js';

// Create a tiny transformer for demonstration
const tinyTransformer = new Transformer({
    vocabSize: 100,
    d_model: 16,
    numHeads: 2,
    numLayers: 2,
    d_ff: 32,
    maxLen: 20
});

console.log("Tiny Transformer created!");
console.log(`Parameters: ${tinyTransformer.getNumParams()}`);
```

2. **Test the forward pass:**
```javascript
// src/test-forward.js
import { Transformer } from './transformer/transformer.js';

const transformer = new Transformer({
    vocabSize: 100,
    d_model: 16,
    numHeads: 2,
    numLayers: 2
});

const tokenIds = [1, 2, 3, 4, 5];
const { logits, attentionWeights } = transformer.forward(tokenIds);

console.log("Input tokens:", tokenIds);
console.log("Logits shape:", logits.length, "x", logits[0].length);
console.log("Attention layers:", attentionWeights.length);
```

3. **Generate text:**
```javascript
// src/generate-demo.js
import { Transformer } from './transformer/transformer.js';
import { TextProcessingPipeline } from '../tokenizer/pipeline.js';

// Create pipeline
const pipeline = new TextProcessingPipeline({
    vocabSize: 100,
    embeddingDim: 16
});
pipeline.train("The quick brown fox jumps over the lazy dog.");

// Create transformer
const transformer = new Transformer({
    vocabSize: pipeline.getStats().vocabSize,
    d_model: 16,
    numHeads: 2,
    numLayers: 2
});

// Generate
const inputIds = pipeline.processText("The").tokenIds;
const outputIds = transformer.generate(inputIds, {
    maxTokens: 10,
    temperature: 0.8
});

const outputText = pipeline.decode(outputIds);
console.log("Generated:", outputText);
```

### Lab 2.2: Attention Visualization

**Create an attention visualizer:**

```javascript
// src/visualize-attention.js
import { Transformer } from './transformer/transformer.js';

function visualizeAttention(weights, tokens) {
    console.log("\nAttention Heatmap:");
    console.log("  " + tokens.join("  "));
    
    for (let i = 0; i < weights.length; i++) {
        const row = weights[i];
        const rowStr = tokens[i] + " ";
        for (let j = 0; j < row.length; j++) {
            const intensity = Math.round(row[j] * 8);
            const char = [" ", "░", "▒", "▓", "█"][intensity] || " ";
            rowStr += char + "  ";
        }
        console.log(rowStr);
    }
}

// Test with sample tokens
const tokens = ["The", "cat", "sat", "on", "the", "mat"];
const weights = [
    [0.8, 0.1, 0.05, 0.02, 0.02, 0.01],
    [0.05, 0.7, 0.2, 0.02, 0.02, 0.01],
    [0.02, 0.05, 0.7, 0.2, 0.02, 0.01],
    [0.01, 0.02, 0.05, 0.8, 0.1, 0.02],
    [0.01, 0.02, 0.02, 0.05, 0.8, 0.1],
    [0.01, 0.01, 0.02, 0.02, 0.05, 0.89]
];

visualizeAttention(weights, tokens);
```

## Module 2 Quiz

**1. What problem does the attention mechanism solve?**
   a) It makes models faster
   b) It enables long-range dependencies
   c) It reduces memory usage
   d) All of the above

**2. In attention, what do Q, K, and V represent?**
   Q: ________________________________________________________
   K: ________________________________________________________
   V: ________________________________________________________

**3. Why do we need multiple attention heads?**
   ____________________________________________________________

**4. True or False: Transformers process all tokens simultaneously.**

**5. What is the purpose of positional encodings?**
   ____________________________________________________________

**6. What does the causal mask do?**
   a) It speeds up computation
   b) It prevents looking at future tokens
   c) It reduces memory usage
   d) It improves accuracy

**7. Write the attention formula:**
   ____________________________________________________________

**8. What is the difference between greedy and temperature sampling?**
   ____________________________________________________________

**Answer Key:**
1. d
2. Q = Query (what I'm looking for), K = Key (what information is available), V = Value (what's the content)
3. Different heads capture different relationship patterns
4. True
5. To preserve order information since attention is order-agnostic
6. b
7. Attention(Q,K,V) = softmax(Q·K^T/√d_k)·V
8. Greedy always picks the most likely token; temperature sampling adds randomness

## Module 2 Cheat Sheet

```
┌─────────────────────────────────────────────────────────────┐
│  TRANSFORMER ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Attention:                                                 │
│  • Q (Query): What am I looking for?                       │
│  • K (Key): What information is available?                 │
│  • V (Value): What's the actual content?                   │
│  • Scores = Q × K^T / √d_k                                │
│  • Weights = softmax(scores)                              │
│  • Output = weights × V                                   │
│                                                              │
│  Multi-Head:                                                │
│  • Multiple parallel attention heads                        │
│  • Each head learns different patterns                     │
│  • Concatenate and project                                 │
│                                                              │
│  Positional Encoding:                                       │
│  • Sinusoidal: sin/cos functions                           │
│  • Learned: trainable embeddings                           │
│  • Added to token embeddings                               │
│                                                              │
│  Transformer Block:                                         │
│  • Multi-Head Attention → Add + Norm                       │
│  • Feed-Forward → Add + Norm                              │
│                                                              │
│  Generation:                                                │
│  • Autoregressive: token by token                          │
│  • Temperature: controls randomness                        │
│  • Top-K: only keep K most likely                          │
│  • Top-P: keep cumulative probability P                   │
└─────────────────────────────────────────────────────────────┘
```

---

# MODULE 3: KNOWLEDGE DISTILLATION

## Learning Objectives Checklist

- [ ] I understand why model compression is important
- [ ] I can explain the teacher-student paradigm
- [ ] I know what soft targets are
- [ ] I understand temperature scaling
- [ ] I can implement distillation loss
- [ ] I can compare teacher vs student performance

## Key Vocabulary

**Define these terms:**

1. **Knowledge Distillation**: __________________________________
____________________________________________________________

2. **Teacher Model**: __________________________________________
____________________________________________________________

3. **Student Model**: __________________________________________
____________________________________________________________

4. **Soft Targets**: ___________________________________________
____________________________________________________________

5. **Dark Knowledge**: ________________________________________
____________________________________________________________

6. **Temperature Scaling**: ___________________________________
____________________________________________________________

7. **KL Divergence**: _________________________________________
____________________________________________________________

## Module 3 Exercises

### Exercise 3.1: Teacher Model

**Complete the teacher implementation:**

```javascript
// 📁 src/distillation/teacher.js

import { Transformer } from '../transformer/transformer.js';
import { softmax } from '../utils/math-utils.js';

export class TeacherModel {
    constructor(config = {}) {
        this.transformer = config.transformer || null;
        this.pipeline = config.pipeline || null;
        this.modelPath = config.modelPath || null;
        this.isLoaded = false;
        
        this.config = {
            temperature: config.temperature || 1.0,
            maxSequenceLength: config.maxSequenceLength || 512
        };
    }

    async initialize() {
        if (this.modelPath) {
            if (this.transformer) {
                this.transformer.loadFromFile(________);
            } else {
                this.transformer = new Transformer();
                this.transformer.loadFromFile(________);
            }
            this.isLoaded = true;
        } else if (this.transformer) {
            this.isLoaded = true;
        } else {
            // Create default teacher (larger model)
            const vocabSize = this.pipeline ? this.pipeline.getStats().vocabSize : 100;
            this.transformer = new Transformer({
                vocabSize: vocabSize,
                d_model: 128,        // Larger than student
                numHeads: 8,         // More heads
                numLayers: 6,        // Deeper
                d_ff: 512,           // Wider
                maxLen: 512,
                dropout: 0.1
            });
            this.isLoaded = true;
        }
        
        console.log(`[Teacher] Initialized with ${this.transformer.getNumParams().toLocaleString()} parameters`);
        return this;
    }

    getSoftTargets(tokenIds, temperature = 1.0) {
        if (!this.isLoaded) {
            throw new Error('Teacher model not loaded');
        }
        
        const { logits } = this.transformer.forward(________);
        
        // HINT: Apply temperature scaling
        const scaledLogits = logits.map(row => 
            row.map(l => l / ________)
        );
        
        const probabilities = scaledLogits.map(row => softmax(________));
        
        return {
            logits: logits,
            scaledLogits: scaledLogits,
            probabilities: probabilities,
            temperature: temperature
        };
    }

    predict(text, temperature = 1.0) {
        if (!this.pipeline) {
            throw new Error('Pipeline required for text processing');
        }
        
        const processed = this.pipeline.processText(________);
        const { probabilities } = this.getSoftTargets(processed.tokenIds, temperature);
        
        const lastProbs = probabilities[probabilities.length - 1];
        const predictedId = this._argmax(________);
        const predictedToken = this.pipeline.vocabulary.getToken(predictedId);
        
        return {
            tokenIds: processed.tokenIds,
            probabilities: probabilities,
            predictedId: predictedId,
            predictedToken: predictedToken,
            confidence: Math.max(...lastProbs)
        };
    }

    getDistillationTargets(tokenIds, temperature = 2.0) {
        const { probabilities, logits } = this.getSoftTargets(________, ________);
        
        return {
            probabilities: probabilities,
            logits: logits,
            temperature: temperature,
            shape: {
                sequenceLength: probabilities.length,
                vocabSize: probabilities[0] ? probabilities[0].length : 0
            }
        };
    }
}
```

### Exercise 3.2: Student Model

**Complete the student implementation:**

```javascript
// 📁 src/distillation/student.js

import { Transformer } from '../transformer/transformer.js';
import { softmax, klDivergence } from '../utils/math-utils.js';

export class StudentModel {
    constructor(config = {}) {
        this.config = {
            vocabSize: config.vocabSize || 100,
            d_model: config.d_model || 32,      // Smaller than teacher
            numHeads: config.numHeads || 4,
            numLayers: config.numLayers || 2,
            d_ff: config.d_ff || 128,
            maxLen: config.maxLen || 256,
            dropout: config.dropout || 0.1
        };
        
        this.transformer = new Transformer(this.config);
        
        this.trainingState = {
            epoch: 0,
            step: 0,
            lossHistory: [],
            bestLoss: Infinity
        };
    }

    forward(tokenIds, mask = null) {
        return this.transformer.forward(________, mask);
    }

    computeDistillationLoss(studentLogits, teacherProbabilities, temperature = 2.0) {
        // HINT: Apply temperature to student logits
        const studentProbs = studentLogits.map(row => {
            const scaled = row.map(l => l / ________);
            return softmax(scaled);
        });
        
        let totalKL = 0;
        let count = 0;
        
        for (let i = 0; i < studentProbs.length; i++) {
            if (i >= teacherProbabilities.length) break;
            const kl = klDivergence(teacherProbabilities[i], studentProbs[i]);
            totalKL += kl;
            count++;
        }
        
        return count > 0 ? totalKL / count : 0;
    }

    computeSupervisedLoss(studentLogits, targetIds) {
        let totalLoss = 0;
        let count = 0;
        
        for (let i = 0; i < studentLogits.length - 1; i++) {
            const targetId = targetIds[i + 1];
            const probs = softmax(studentLogits[i]);
            const loss = -Math.log(probs[targetId] + 1e-8);
            totalLoss += loss;
            count++;
        }
        
        return count > 0 ? totalLoss / count : 0;
    }

    trainStep(tokenIds, teacherProbabilities, config = {}) {
        const temperature = config.temperature || 2.0;
        const alpha = config.alpha || 0.7;
        const learningRate = config.learningRate || 0.001;
        
        const { logits } = this.forward(________);
        
        const distLoss = this.computeDistillationLoss(________, teacherProbabilities, temperature);
        const supLoss = this.computeSupervisedLoss(________, tokenIds);
        
        const totalLoss = alpha * distLoss + (1 - alpha) * supLoss;
        
        this.trainingState.step++;
        this.trainingState.lossHistory.push({
            step: this.trainingState.step,
            totalLoss: totalLoss,
            distillationLoss: distLoss,
            supervisedLoss: supLoss
        });
        
        return {
            totalLoss: totalLoss,
            distillationLoss: distLoss,
            supervisedLoss: supLoss,
            learningRate: learningRate
        };
    }
}
```

### Lab 3.1: Distillation Training

**Complete the distillation trainer:**

```javascript
// src/distill-demo.js
import { TextProcessingPipeline } from './tokenizer/pipeline.js';
import { TeacherModel } from './distillation/teacher.js';
import { StudentModel } from './distillation/student.js';
import { Transformer } from './transformer/transformer.js';

async function runDistillation() {
    // 1. Create pipeline
    const pipeline = new TextProcessingPipeline({
        vocabSize: 100,
        embeddingDim: 16
    });
    
    const corpus = `
        The quick brown fox jumps over the lazy dog.
        A fast cat runs through the garden.
        The sun sets over the mountains.
        Birds fly high in the sky.
    `;
    
    pipeline.train(corpus);
    console.log("Pipeline trained!");
    
    // 2. Create teacher (large model)
    console.log("\nCreating teacher model...");
    const teacher = new TeacherModel({
        pipeline: pipeline,
        transformer: new Transformer({
            vocabSize: pipeline.getStats().vocabSize,
            d_model: 32,    // Larger
            numHeads: 4,
            numLayers: 3,
            d_ff: 128
        })
    });
    await teacher.initialize();
    console.log(`Teacher parameters: ${teacher.getStats().parameters}`);
    
    // 3. Create student (small model)
    console.log("\nCreating student model...");
    const student = new StudentModel({
        vocabSize: pipeline.getStats().vocabSize,
        d_model: 8,      // Smaller
        numHeads: 2,
        numLayers: 1,
        d_ff: 32
    });
    console.log(`Student parameters: ${student.getStats().parameters}`);
    
    // 4. Train with distillation
    console.log("\nTraining with distillation...");
    const texts = corpus.split('\n').filter(t => t.trim());
    
    // Simplified training loop
    for (let epoch = 0; epoch < 3; epoch++) {
        let totalLoss = 0;
        for (const text of texts) {
            const processed = pipeline.processText(text);
            const tokenIds = processed.tokenIds;
            
            // Get teacher targets
            const teacherTargets = teacher.getSoftTargets(tokenIds, 2.0);
            
            // Train student
            const result = student.trainStep(
                tokenIds,
                teacherTargets.probabilities,
                { temperature: 2.0, alpha: 0.7 }
            );
            totalLoss += result.totalLoss;
        }
        console.log(`Epoch ${epoch + 1}: Loss = ${(totalLoss / texts.length).toFixed(4)}`);
    }
    
    // 5. Compare models
    console.log("\nComparing models...");
    const testText = "The quick brown";
    const processed = pipeline.processText(testText);
    
    // Teacher prediction
    const teacherPred = teacher.predict(testText);
    console.log(`Teacher predicts: "${teacherPred.predictedToken}"`);
    
    // Student prediction
    const studentPred = student.predict(processed.tokenIds);
    const lastStudentProbs = studentPred.probabilities[studentPred.probabilities.length - 1];
    const studentPredId = studentPred.predictions[studentPred.predictions.length - 1].id;
    const studentToken = pipeline.vocabulary.getToken(studentPredId);
    console.log(`Student predicts: "${studentToken}"`);
}

runDistillation();
```

## Module 3 Quiz

**1. What is the main goal of knowledge distillation?**
   a) To make models faster
   b) To compress models while preserving quality
   c) To reduce training time
   d) All of the above

**2. What are "soft targets"?**
   ____________________________________________________________

**3. True or False: The student model only learns from the teacher's predictions.**

**4. What is "dark knowledge" in distillation?**
   ____________________________________________________________

**5. Why do we use temperature scaling in distillation?**
   a) To speed up training
   b) To reveal hidden patterns in the teacher's predictions
   c) To reduce memory usage
   d) To improve accuracy

**6. What is the distillation loss formula?**
   ____________________________________________________________

**7. How does distillation differ from quantization?**
   ____________________________________________________________

**8. What is the typical compression ratio from distillation?**
   a) 1.5x
   b) 3-10x
   c) 100x
   d) 1000x

**Answer Key:**
1. d
2. Probability distributions from the teacher (vs one-hot labels)
3. False (it also learns from hard labels via supervised loss)
4. The relationships between classes revealed in soft targets
5. b
6. L = α·D_KL(P_teacher_T||P_student_T) + (1-α)·CE(y_true, P_student)
7. Distillation trains a smaller model; quantization reduces precision of weights
8. b

## Module 3 Cheat Sheet

```
┌─────────────────────────────────────────────────────────────┐
│  KNOWLEDGE DISTILLATION                                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Teacher-Student:                                           │
│  • Teacher: Large, slow, accurate                          │
│  • Student: Small, fast, learning                          │
│  • Student mimics teacher's behavior                       │
│                                                              │
│  Soft Targets:                                              │
│  • Probability distributions (vs one-hot)                  │
│  • Carry "dark knowledge"                                 │
│  • Reveal class relationships                             │
│                                                              │
│  Temperature:                                               │
│  • T=1: Standard softmax                                  │
│  • T>1: Softer distribution                               │
│  • T<1: Sharper distribution                              │
│  • Higher T reveals more dark knowledge                   │
│                                                              │
│  Combined Loss:                                             │
│  L = α·D_KL(P_T||P_S) + (1-α)·CE(y_true, P_S)           │
│  • α: Distillation weight (0.7-0.9)                       │
│  • D_KL: KL divergence                                    │
│  • CE: Cross-entropy                                      │
│                                                              │
│  Compression Methods Comparison:                           │
│  • Distillation: 3-10x compression                        │
│  • Quantization: 2-8x compression                         │
│  • Pruning: 1.5-3x compression                            │
│  • Combined: 6-30x compression                            │
└─────────────────────────────────────────────────────────────┘
```

---

# MODULE 4: PRODUCTION DEPLOYMENT

## Learning Objectives Checklist

- [ ] I understand production architecture
- [ ] I can implement KV caching
- [ ] I know how to configure generation parameters
- [ ] I can build an Express API
- [ ] I understand monitoring and scaling
- [ ] I can deploy a model in production

## Key Vocabulary

**Define these terms:**

1. **KV Cache**: ______________________________________________
____________________________________________________________

2. **Autoregressive Generation**: _____________________________
____________________________________________________________

3. **Temperature**: ___________________________________________
____________________________________________________________

4. **Top-K Sampling**: ________________________________________
____________________________________________________________

5. **Top-P Sampling**: ________________________________________
____________________________________________________________

6. **Latency**: _______________________________________________
____________________________________________________________

7. **Throughput**: ____________________________________________
____________________________________________________________

## Module 4 Exercises

### Exercise 4.1: KV Cache Implementation

**Complete the KV cache:**

```javascript
// 📁 src/inference/kv-cache.js

export class KVCache {
    constructor(config = {}) {
        this.maxSize = config.maxSize || 1000;
        this.ttl = config.ttl || 3600;
        this.maxSequenceLength = config.maxSequenceLength || 2048;
        this.cache = new Map();
        this.lru = [];
        this.stats = {
            hits: 0,
            misses: 0,
            totalRequests: 0,
            cacheSize: 0,
            evictions: 0
        };
    }

    getKey(prompt, params = {}) {
        // HINT: Create a unique key from prompt and parameters
        const keyParts = [
            ________,
            params.temperature || 0.8,
            params.topK || 40,
            params.topP || 0.9
        ];
        return keyParts.join('|');
    }

    get(key) {
        this.stats.totalRequests++;
        
        const entry = this.cache.get(________);
        if (!entry) {
            this.stats.misses++;
            return null;
        }
        
        // HINT: Check TTL
        if (Date.now() - entry.timestamp > this.ttl * 1000) {
            this.cache.delete(________);
            this._updateLRU(key, false);
            this.stats.misses++;
            return null;
        }
        
        this._updateLRU(key, true);
        this.stats.hits++;
        
        return {
            keys: entry.keys,
            values: entry.values,
            sequenceLength: entry.sequenceLength
        };
    }

    set(key, keys, values, sequenceLength) {
        // HINT: Check if we need to evict
        if (this.cache.size >= this.maxSize) {
            this._evictLRU();
        }
        
        this.cache.set(key, {
            keys: keys,
            values: values,
            sequenceLength: sequenceLength,
            timestamp: Date.now()
        });
        
        this._updateLRU(key, true);
        this.stats.cacheSize = this.cache.size;
    }

    _evictLRU() {
        if (this.lru.length === 0) return;
        const oldestKey = this.lru.shift();
        this.cache.delete(________);
        this.stats.evictions++;
        this.stats.cacheSize = this.cache.size;
    }

    getStats() {
        const hitRate = this.stats.totalRequests > 0
            ? this.stats.hits / this.stats.totalRequests
            : 0;
        
        return {
            size: this.cache.size,
            maxSize: this.maxSize,
            hits: this.stats.hits,
            misses: this.stats.misses,
            totalRequests: this.stats.totalRequests,
            hitRate: hitRate,
            evictions: this.stats.evictions,
            ttl: this.ttl
        };
    }
}
```

### Exercise 4.2: Generation Parameters

**Complete the generation parameters:**

```javascript
// 📁 src/inference/generation-params.js

export class GenerationParams {
    constructor(params = {}) {
        this.maxTokens = params.maxTokens || 100;
        this.temperature = params.temperature || 0.8;
        this.topK = params.topK || 40;
        this.topP = params.topP || 0.9;
        this.repetitionPenalty = params.repetitionPenalty || 1.1;
        this.stopTokens = params.stopTokens || ['<|endoftext|>', '<|eos|>'];
        this.seed = params.seed || null;
        
        this._validate();
    }

    _validate() {
        if (this.maxTokens < 1 || this.maxTokens > 2048) {
            throw new Error('maxTokens must be between 1 and 2048');
        }
        // HINT: Add validation for other parameters
        if (this.temperature < 0 || this.temperature > 2) {
            throw new Error('temperature must be between 0 and 2');
        }
        if (this.topK < 0 || this.topK > 100) {
            throw new Error('topK must be between 0 and 100');
        }
        if (this.topP < 0 || this.topP > 1) {
            throw new Error('topP must be between 0 and 1');
        }
        if (this.repetitionPenalty < 1 || this.repetitionPenalty > 2) {
            throw new Error('repetitionPenalty must be between 1 and 2');
        }
    }

    describe() {
        const descriptions = [];
        
        if (this.maxTokens < 50) {
            descriptions.push('Short generation');
        } else if (this.maxTokens > 200) {
            descriptions.push('Long generation');
        }
        
        if (this.temperature < 0.5) {
            descriptions.push('Deterministic (low temperature)');
        } else if (this.temperature > 1.2) {
            descriptions.push('Creative (high temperature)');
        } else {
            descriptions.push('Balanced');
        }
        
        return descriptions.join(', ');
    }

    static getPresets() {
        return {
            creative: new GenerationParams({
                maxTokens: 150,
                temperature: 1.2,
                topK: 60,
                topP: 0.95,
                repetitionPenalty: 1.1
            }),
            balanced: new GenerationParams({
                maxTokens: 100,
                temperature: 0.8,
                topK: 40,
                topP: 0.9,
                repetitionPenalty: 1.1
            }),
            factual: new GenerationParams({
                maxTokens: 80,
                temperature: 0.3,
                topK: 10,
                topP: 0.8,
                repetitionPenalty: 1.2
            })
        };
    }
}
```

### Lab 4.1: Building the Production Server

**Complete the server implementation:**

```javascript
// src/production-server.js
import express from 'express';
import cors from 'cors';
import { TextProcessingPipeline } from './tokenizer/pipeline.js';
import { StudentModel } from './distillation/student.js';
import { KVCache } from './inference/kv-cache.js';
import { GenerationParams } from './inference/generation-params.js';

class ProductionServer {
    constructor(config = {}) {
        this.port = config.port || 3000;
        this.modelDir = config.modelDir || './models/distillation_demo';
        this.app = express();
        this.modelService = null;
        this.isReady = false;
        
        this._initializeApp();
    }

    _initializeApp() {
        this.app.use(express.json());
        this.app.use(cors());
        
        // HINT: Add middleware
        this.app.use((req, res, next) => {
            console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
            next();
        });
        
        // Health check
        this.app.get('/health', (req, res) => {
            res.json({
                status: this.isReady ? 'healthy' : 'unhealthy',
                timestamp: new Date().toISOString()
            });
        });
        
        // Generate endpoint
        this.app.post('/api/generate', this._handleGenerate.bind(this));
        
        // Stats endpoint
        this.app.get('/api/stats', this._handleStats.bind(this));
    }

    async initialize() {
        console.log('[Server] Initializing...');
        
        // HINT: Load pipeline and model
        const pipeline = new TextProcessingPipeline();
        pipeline.loadFromDirectory(`${this.modelDir}/pipeline`);
        
        const student = new StudentModel({
            vocabSize: pipeline.getStats().vocabSize,
            d_model: 32,
            numHeads: 4,
            numLayers: 2
        });
        student.loadFromFile(`${this.modelDir}/student.json`);
        
        const cache = new KVCache({
            maxSize: 1000,
            ttl: 3600
        });
        
        this.modelService = {
            pipeline: pipeline,
            model: student,
            cache: cache
        };
        
        this.isReady = true;
        console.log('[Server] Ready!');
    }

    async _handleGenerate(req, res) {
        if (!this.isReady) {
            return res.status(503).json({ error: 'Server not ready' });
        }
        
        try {
            const { prompt, ...params } = req.body;
            if (!prompt || typeof prompt !== 'string') {
                return res.status(400).json({ error: 'Invalid prompt' });
            }
            
            // HINT: Generate text
            const processed = this.modelService.pipeline.processText(prompt);
            const genParams = new GenerationParams(params);
            
            // Simplified generation
            const inputIds = processed.tokenIds;
            const outputIds = this.modelService.model.transformer.generate(
                inputIds,
                {
                    maxTokens: genParams.maxTokens,
                    temperature: genParams.temperature,
                    topK: genParams.topK,
                    topP: genParams.topP
                }
            );
            
            const tokens = outputIds.map(id => 
                this.modelService.pipeline.vocabulary.getToken(id)
            );
            const generated = tokens.join('');
            
            res.json({
                success: true,
                prompt: prompt,
                generated: generated,
                tokens: tokens,
                tokenCount: outputIds.length
            });
            
        } catch (error) {
            console.error('Generation error:', error);
            res.status(500).json({ error: error.message });
        }
    }

    _handleStats(req, res) {
        const cacheStats = this.modelService?.cache?.getStats() || {};
        res.json({
            server: {
                uptime: process.uptime(),
                memory: process.memoryUsage()
            },
            cache: cacheStats
        });
    }

    start() {
        if (!this.isReady) {
            throw new Error('Server not initialized');
        }
        this.app.listen(this.port, () => {
            console.log(`🚀 Server running on port ${this.port}`);
        });
    }
}

// Start the server
const server = new ProductionServer({
    port: 3000,
    modelDir: './models/distillation_demo'
});

await server.initialize();
server.start();
```

### Lab 4.2: Testing the Production System

**Test your production server:**

```javascript
// test-api.js
async function testAPI() {
    console.log("Testing Production API...");
    
    // 1. Health check
    console.log("\n1. Health Check:");
    const health = await fetch('http://localhost:3000/health');
    console.log("Status:", await health.json());
    
    // 2. Generate text
    console.log("\n2. Generate Text:");
    const response = await fetch('http://localhost:3000/api/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            prompt: 'The quick brown fox',
            maxTokens: 20,
            temperature: 0.8
        })
    });
    const result = await response.json();
    console.log("Generated:", result.generated);
    console.log("Tokens:", result.tokenCount);
    
    // 3. Get stats
    console.log("\n3. Server Stats:");
    const stats = await fetch('http://localhost:3000/api/stats');
    console.log(await stats.json());
}

testAPI();
```

## Module 4 Quiz

**1. What is the purpose of KV caching?**
   a) To store model weights
   b) To avoid recomputing past tokens
   c) To reduce model size
   d) To improve accuracy

**2. True or False: The KV cache stores both keys and values from previous tokens.**

**3. What does the temperature parameter control?**
   a) Model size
   b) Randomness in generation
   c) Training speed
   d) Memory usage

**4. What's the difference between Top-K and Top-P sampling?**
   ____________________________________________________________

**5. Why do we need rate limiting in production?**
   ____________________________________________________________

**6. What metrics should you monitor in production?**
   ____________________________________________________________

**7. Write a sample API request for text generation:**
   ____________________________________________________________

**8. What happens when the KV cache is full?**
   ____________________________________________________________

**Answer Key:**
1. b
2. True
3. b
4. Top-K keeps K most likely tokens; Top-P keeps cumulative probability P
5. To prevent abuse and ensure fair usage
6. Latency, tokens per second, memory usage, cache hit rate
7. POST /api/generate { "prompt": "The future of AI", "maxTokens": 50 }
8. The oldest entry is evicted (LRU)

## Module 4 Cheat Sheet

```
┌─────────────────────────────────────────────────────────────┐
│  PRODUCTION DEPLOYMENT                                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  KV Cache:                                                  │
│  • Stores K and V matrices from previous tokens             │
│  • Avoids recomputation                                   │
│  • O(n²) → O(n) speedup                                   │
│  • LRU eviction when full                                 │
│                                                              │
│  Generation Parameters:                                     │
│  • maxTokens: Maximum length                               │
│  • temperature: Randomness (0-2)                          │
│  • topK: Only keep K most likely                          │
│  • topP: Keep cumulative probability P                    │
│  • repetitionPenalty: Penalize repeats                    │
│                                                              │
│  Production Endpoints:                                      │
│  GET  /health              → Status check                  │
│  POST /api/generate        → Text generation               │
│  POST /api/generate/stream → Stream generation             │
│  GET  /api/models          → List models                   │
│  GET  /api/stats           → Server statistics             │
│                                                              │
│  Monitoring:                                                │
│  • Latency (p50, p90, p99)                                │
│  • Tokens per second                                      │
│  • Memory usage                                           │
│  • Cache hit rate                                         │
│  • Queue depth                                            │
│                                                              │
│  Deployment Checklist:                                      │
│  • Security: Auth, rate limiting, validation              │
│  • Performance: KV cache, compression                     │
│  • Reliability: Error handling, graceful shutdown        │
│  • Operations: Logging, metrics, alerts                  │
└─────────────────────────────────────────────────────────────┘
```

---

# FINAL REVIEW

## Comprehensive Self-Assessment

**Rate your understanding (1-5):**

___ 1. I understand tokenization and BPE
___ 2. I understand embeddings and semantic space
___ 3. I understand the attention mechanism
___ 4. I understand multi-head attention
___ 5. I understand positional encodings
___ 6. I understand the transformer architecture
___ 7. I understand knowledge distillation
___ 8. I understand soft targets and dark knowledge
___ 9. I understand production deployment
___ 10. I understand KV caching and optimization

**What was the most challenging concept?**
____________________________________________________________
____________________________________________________________

**What was the most rewarding part?**
____________________________________________________________
____________________________________________________________

## Project Ideas

**Choose one to build:**

1. **Chatbot API**: Build a conversational AI with your distilled model
2. **Text Summarizer**: Summarize long documents using your transformer
3. **Code Assistant**: Generate code snippets from natural language
4. **RAG System**: Add retrieval to your generation pipeline
5. **Content Generator**: Create blog posts, stories, or poems

## Final Project: End-to-End System

**Build a complete system that:**
1. Accepts text input via API
2. Tokenizes using your BPE tokenizer
3. Generates using your transformer
4. Uses KV caching for speed
5. Returns the result with metadata
6. Monitors performance
7. Handles errors gracefully

**Project Checklist:**
- [ ] Tokenizer implementation
- [ ] Transformer implementation
- [ ] Distilled model
- [ ] Production server
- [ ] KV caching
- [ ] Monitoring
- [ ] Error handling
- [ ] Documentation

## Certificate of Completion

**Student Name:** _________________

**Date Completed:** _________________

**Modules Completed:**
- [ ] Module 0: Introduction
- [ ] Module 1: Anatomy of an LLM
- [ ] Module 2: Transformer Revolution
- [ ] Module 3: Knowledge Distillation
- [ ] Module 4: Production Deployment

**Final Grade:** _________________

**Instructor Comments:**
____________________________________________________________
____________________________________________________________
____________________________________________________________

---

**[END OF STUDENT WORKBOOK]**
