# Primer 1: Linear Algebra Fundamentals for LLMs

This primer provides a comprehensive introduction to the linear algebra concepts you need to understand LLMs. If you've ever felt intimidated by the math behind AI, this guide will break it down using intuitive explanations and practical JavaScript examples.

---

## P1.1 Why Linear Algebra Matters for LLMs

### The Core Insight

**Every LLM is fundamentally a series of matrix multiplications.**

When you send a prompt to an LLM, the following happens:

```
Text → Tokens → Embeddings (Vectors) → Matrix Operations → Predictions
```

Everything from token embeddings to attention mechanisms to feed-forward networks is built on linear algebra operations.

### What You'll Learn

| Concept | Why It Matters | Where Used |
|---------|---------------|------------|
| **Vectors** | Represent words, tokens, and concepts | Embeddings, attention |
| **Matrices** | Store weights, process batches | Neural networks, attention |
| **Dot Product** | Measure similarity | Attention scores, cosine similarity |
| **Matrix Multiplication** | Transform data | Linear layers, attention |
| **Softmax** | Convert scores to probabilities | Output layer, attention weights |
| **Transpose** | Change data orientation | Attention computation |

---

## P1.2 Vectors: The Building Blocks

### What Is a Vector?

**Think of a vector as a list of numbers that represents something in space.**

- A 2D vector: `[3, 4]` (like coordinates on a map)
- A 3D vector: `[1, 2, 3]` (like position in 3D space)
- A 512D vector: `[0.23, -0.45, 0.12, ...]` (like a word's "meaning" in embedding space)

In LLMs, every word/token is represented as a high-dimensional vector.

### Vector Operations in JavaScript

```javascript
// 📁 src/primers/math/vectors.js
/**
 * Vector Operations
 * 
 * Fundamental vector operations used throughout LLMs.
 * Each operation is implemented with clear comments
 * and includes error checking.
 */

/**
 * Create a vector of given length with random values
 */
export function randomVector(length, min = -1, max = 1) {
    const vector = [];
    for (let i = 0; i < length; i++) {
        vector.push(min + Math.random() * (max - min));
    }
    return vector;
}

/**
 * Create a zero vector
 */
export function zeroVector(length) {
    return new Array(length).fill(0);
}

/**
 * Vector addition: element-wise addition
 * Used for: Combining embeddings with positional encodings
 * Example: [1,2] + [3,4] = [4,6]
 */
export function vectorAdd(a, b) {
    if (a.length !== b.length) {
        throw new Error(`Vector lengths must match: ${a.length} vs ${b.length}`);
    }
    const result = [];
    for (let i = 0; i < a.length; i++) {
        result.push(a[i] + b[i]);
    }
    return result;
}

/**
 * Vector subtraction: element-wise subtraction
 * Used for: Analogy tasks (king - man + woman)
 * Example: [3,4] - [1,2] = [2,2]
 */
export function vectorSubtract(a, b) {
    if (a.length !== b.length) {
        throw new Error(`Vector lengths must match: ${a.length} vs ${b.length}`);
    }
    const result = [];
    for (let i = 0; i < a.length; i++) {
        result.push(a[i] - b[i]);
    }
    return result;
}

/**
 * Scalar multiplication: multiply a vector by a number
 * Used for: Scaling embeddings, applying temperature
 * Example: [1,2] * 3 = [3,6]
 */
export function scalarMultiply(vector, scalar) {
    return vector.map(v => v * scalar);
}

/**
 * Element-wise multiplication (Hadamard product)
 * Used for: Gating mechanisms, attention scaling
 * Example: [1,2] * [3,4] = [3,8]
 */
export function elementwiseMultiply(a, b) {
    if (a.length !== b.length) {
        throw new Error(`Vector lengths must match: ${a.length} vs ${b.length}`);
    }
    return a.map((v, i) => v * b[i]);
}

/**
 * Dot product: sum of element-wise products
 * Used for: Measuring similarity between embeddings, attention scores
 * Example: [1,2] · [3,4] = 1*3 + 2*4 = 11
 */
export function dotProduct(a, b) {
    if (a.length !== b.length) {
        throw new Error(`Vector lengths must match: ${a.length} vs ${b.length}`);
    }
    let result = 0;
    for (let i = 0; i < a.length; i++) {
        result += a[i] * b[i];
    }
    return result;
}

/**
 * L2 norm (Euclidean norm): √(sum of squares)
 * Used for: Normalizing vectors, computing distances
 * Example: ||[3,4]|| = √(9+16) = 5
 */
export function l2Norm(vector) {
    let sumSquares = 0;
    for (const v of vector) {
        sumSquares += v * v;
    }
    return Math.sqrt(sumSquares);
}

/**
 * Normalize a vector to unit length (L2 norm = 1)
 * Used for: Making embeddings comparable, cosine similarity
 * Example: [3,4] normalized = [0.6, 0.8]
 */
export function normalize(vector) {
    const norm = l2Norm(vector);
    if (norm === 0) {
        throw new Error('Cannot normalize a zero vector');
    }
    return vector.map(v => v / norm);
}

/**
 * Cosine similarity: measures the angle between two vectors
 * Used for: Finding semantically similar words, nearest neighbors
 * Formula: cos(θ) = (A·B) / (||A|| * ||B||)
 * Range: -1 (opposite) to 1 (same direction)
 */
export function cosineSimilarity(a, b) {
    const dot = dotProduct(a, b);
    const normA = l2Norm(a);
    const normB = l2Norm(b);
    
    if (normA === 0 || normB === 0) {
        return 0;
    }
    
    return dot / (normA * normB);
}

/**
 * Euclidean distance: straight-line distance between vectors
 * Used for: Clustering, nearest neighbor search
 * Formula: d = √(∑(a_i - b_i)²)
 */
export function euclideanDistance(a, b) {
    if (a.length !== b.length) {
        throw new Error(`Vector lengths must match: ${a.length} vs ${b.length}`);
    }
    let sumSquares = 0;
    for (let i = 0; i < a.length; i++) {
        const diff = a[i] - b[i];
        sumSquares += diff * diff;
    }
    return Math.sqrt(sumSquares);
}

/**
 * Mean vector: average of multiple vectors
 * Used for: Centering embeddings, computing centroids
 */
export function meanVector(vectors) {
    if (vectors.length === 0) {
        throw new Error('Cannot compute mean of empty vector set');
    }
    const dim = vectors[0].length;
    const sum = zeroVector(dim);
    for (const vector of vectors) {
        if (vector.length !== dim) {
            throw new Error('All vectors must have same dimension');
        }
        for (let i = 0; i < dim; i++) {
            sum[i] += vector[i];
        }
    }
    return sum.map(v => v / vectors.length);
}

/**
 * Principal Component Analysis (simplified)
 * Projects vectors to 2D for visualization
 */
export function projectTo2D(vectors) {
    const dim = vectors[0].length;
    // Random projection for simplicity
    // In practice, you'd use proper PCA or t-SNE
    const projectionMatrix = [];
    for (let i = 0; i < dim; i++) {
        projectionMatrix.push([
            Math.random() * 2 - 1,
            Math.random() * 2 - 1
        ]);
    }
    
    return vectors.map(vector => {
        let x = 0, y = 0;
        for (let i = 0; i < vector.length; i++) {
            x += vector[i] * projectionMatrix[i][0];
            y += vector[i] * projectionMatrix[i][1];
        }
        return { x, y };
    });
}
```

### Visualizing Vector Operations

```javascript
// 📁 src/primers/math/vector-demo.js
/**
 * Vector Operations Demo
 * 
 * Demonstrates vector operations with real examples
 * from LLM applications.
 */

import {
    randomVector,
    vectorAdd,
    vectorSubtract,
    dotProduct,
    cosineSimilarity,
    normalize,
    projectTo2D
} from './vectors.js';

function runVectorDemo() {
    console.log('='.repeat(60));
    console.log('📐 Vector Operations Demo');
    console.log('='.repeat(60));
    
    // 1. Create word embeddings
    console.log('\n📚 1. Word Embeddings');
    console.log('─'.repeat(40));
    
    // Simulate 3D embeddings for words
    const wordEmbeddings = {
        'king': [0.8, 0.6, 0.2],
        'queen': [0.7, 0.5, 0.3],
        'man': [0.6, 0.8, 0.1],
        'woman': [0.5, 0.7, 0.2],
        'apple': [0.1, 0.2, 0.9],
        'orange': [0.2, 0.1, 0.8]
    };
    
    console.log('Word embeddings (3D):');
    for (const [word, embedding] of Object.entries(wordEmbeddings)) {
        console.log(`  ${word}: [${embedding.map(v => v.toFixed(2)).join(', ')}]`);
    }
    
    // 2. Compute similarities
    console.log('\n🔍 2. Semantic Similarities');
    console.log('─'.repeat(40));
    
    const pairs = [
        ['king', 'queen'],
        ['king', 'man'],
        ['queen', 'woman'],
        ['apple', 'orange'],
        ['apple', 'king']
    ];
    
    for (const [word1, word2] of pairs) {
        const emb1 = wordEmbeddings[word1];
        const emb2 = wordEmbeddings[word2];
        const sim = cosineSimilarity(emb1, emb2);
        console.log(`  "${word1}" vs "${word2}": ${sim.toFixed(3)}`);
    }
    
    // 3. Word analogies
    console.log('\n🧠 3. Word Analogies');
    console.log('─'.repeat(40));
    console.log('  Using: king - man + woman = ?');
    
    const king = wordEmbeddings['king'];
    const man = wordEmbeddings['man'];
    const woman = wordEmbeddings['woman'];
    const result = vectorAdd(vectorSubtract(king, man), woman);
    console.log(`  Resulting vector: [${result.map(v => v.toFixed(2)).join(', ')}]`);
    
    // Find closest word
    let closestWord = '';
    let closestDistance = Infinity;
    for (const [word, embedding] of Object.entries(wordEmbeddings)) {
        if (word === 'king' || word === 'man' || word === 'woman') continue;
        const dist = euclideanDistance(result, embedding);
        if (dist < closestDistance) {
            closestDistance = dist;
            closestWord = word;
        }
    }
    console.log(`  Closest word: "${closestWord}" (distance: ${closestDistance.toFixed(3)})`);
    
    // 4. Embedding space visualization
    console.log('\n🎨 4. Embedding Space Projection');
    console.log('─'.repeat(40));
    
    const embeddings = Object.values(wordEmbeddings);
    const words = Object.keys(wordEmbeddings);
    const projected = projectTo2D(embeddings);
    
    console.log('  2D Projection of embedding space:');
    for (let i = 0; i < words.length; i++) {
        const p = projected[i];
        console.log(`  ${words[i]}: (${p.x.toFixed(3)}, ${p.y.toFixed(3)})`);
    }
    
    // 5. Practical example: Semantic search
    console.log('\n🔎 5. Semantic Search Example');
    console.log('─'.repeat(40));
    
    const query = 'royal female';
    const queryVector = vectorAdd(
        wordEmbeddings['king'],
        wordEmbeddings['woman']
    );
    
    console.log(`  Query: "${query}"`);
    console.log(`  Query embedding: [${queryVector.map(v => v.toFixed(2)).join(', ')}]`);
    
    // Find most similar words
    const results = [];
    for (const [word, embedding] of Object.entries(wordEmbeddings)) {
        const sim = cosineSimilarity(queryVector, embedding);
        results.push({ word, similarity: sim });
    }
    results.sort((a, b) => b.similarity - a.similarity);
    
    console.log('  Top matches:');
    for (const result of results.slice(0, 3)) {
        console.log(`    ${result.word}: ${result.similarity.toFixed(3)}`);
    }
    
    console.log('\n' + '='.repeat(60));
}

// Run the demo
runVectorDemo();
```

---

## P1.3 Matrices: Tables of Numbers

### What Is a Matrix?

**Think of a matrix as a spreadsheet of numbers with rows and columns.**

```
A = [1  2  3]    (1×3 matrix, row vector)
    [4  5  6]    (2×3 matrix)
    [7  8  9]    (3×3 matrix, square)
```

In LLMs, matrices represent:
- **Weight matrices**: The learned parameters
- **Embedding matrices**: Lookup tables for token embeddings
- **Attention matrices**: Q, K, V projections
- **Batch processing**: Multiple sequences at once

### Matrix Operations in JavaScript

```javascript
// 📁 src/primers/math/matrices.js
/**
 * Matrix Operations
 * 
 * Fundamental matrix operations used throughout LLMs.
 * Matrices are represented as 2D arrays: matrix[row][column]
 */

/**
 * Create a matrix with random values
 */
export function randomMatrix(rows, cols, min = -1, max = 1) {
    const matrix = [];
    for (let i = 0; i < rows; i++) {
        const row = [];
        for (let j = 0; j < cols; j++) {
            row.push(min + Math.random() * (max - min));
        }
        matrix.push(row);
    }
    return matrix;
}

/**
 * Create a zero matrix
 */
export function zeroMatrix(rows, cols) {
    return Array.from({ length: rows }, () => new Array(cols).fill(0));
}

/**
 * Create an identity matrix (1s on diagonal, 0s elsewhere)
 * Used for: Initialization, residual connections
 */
export function identityMatrix(size) {
    const matrix = zeroMatrix(size, size);
    for (let i = 0; i < size; i++) {
        matrix[i][i] = 1;
    }
    return matrix;
}

/**
 * Matrix addition: element-wise addition
 * Used for: Residual connections, combining outputs
 * Example: A + B where both are same dimensions
 */
export function matrixAdd(a, b) {
    if (a.length !== b.length || a[0].length !== b[0].length) {
        throw new Error('Matrices must have same dimensions');
    }
    const rows = a.length;
    const cols = a[0].length;
    const result = zeroMatrix(rows, cols);
    for (let i = 0; i < rows; i++) {
        for (let j = 0; j < cols; j++) {
            result[i][j] = a[i][j] + b[i][j];
        }
    }
    return result;
}

/**
 * Scalar multiplication: multiply matrix by a number
 * Used for: Scaling weights, temperature scaling
 */
export function matrixScalarMultiply(matrix, scalar) {
    return matrix.map(row => row.map(v => v * scalar));
}

/**
 * Matrix multiplication: A(rows×cols) * B(cols×p) = C(rows×p)
 * Used for: ALL linear transformations in neural networks!
 * This is the MOST IMPORTANT operation in LLMs
 */
export function matrixMultiply(a, b) {
    const rows = a.length;
    const cols = a[0].length;
    const p = b[0].length;
    
    if (cols !== b.length) {
        throw new Error(`Matrix dimensions incompatible: A(${rows}×${cols}) × B(${b.length}×${p})`);
    }
    
    const result = zeroMatrix(rows, p);
    for (let i = 0; i < rows; i++) {
        for (let j = 0; j < p; j++) {
            let sum = 0;
            for (let k = 0; k < cols; k++) {
                sum += a[i][k] * b[k][j];
            }
            result[i][j] = sum;
        }
    }
    return result;
}

/**
 * Matrix transpose: flip rows and columns
 * Used for: Computing attention scores (Q × K^T)
 * Example: A (2×3) → A^T (3×2)
 */
export function transpose(matrix) {
    const rows = matrix.length;
    const cols = matrix[0].length;
    const result = zeroMatrix(cols, rows);
    for (let i = 0; i < rows; i++) {
        for (let j = 0; j < cols; j++) {
            result[j][i] = matrix[i][j];
        }
    }
    return result;
}

/**
 * Vector-matrix multiplication: vector(1×n) × matrix(n×m) = vector(1×m)
 * Used for: Forward pass through neural networks
 */
export function vectorMatrixMultiply(vector, matrix) {
    if (vector.length !== matrix.length) {
        throw new Error(`Vector length (${vector.length}) must match matrix rows (${matrix.length})`);
    }
    const cols = matrix[0].length;
    const result = [];
    for (let j = 0; j < cols; j++) {
        let sum = 0;
        for (let i = 0; i < vector.length; i++) {
            sum += vector[i] * matrix[i][j];
        }
        result.push(sum);
    }
    return result;
}

/**
 * Matrix norm (Frobenius norm): √(sum of squares)
 * Used for: Regularization, measuring weight magnitude
 */
export function frobeniusNorm(matrix) {
    let sumSquares = 0;
    for (const row of matrix) {
        for (const val of row) {
            sumSquares += val * val;
        }
    }
    return Math.sqrt(sumSquares);
}

/**
 * Softmax: converts logits to probabilities
 * Used for: Output layer, attention weights
 * Formula: p_i = exp(z_i) / ∑ exp(z_j)
 */
export function softmax(vector) {
    const maxVal = Math.max(...vector);
    const expVector = vector.map(v => Math.exp(v - maxVal));
    const sumExp = expVector.reduce((a, b) => a + b, 0);
    return expVector.map(v => v / sumExp);
}

/**
 * Softmax on matrix rows
 */
export function matrixSoftmax(matrix) {
    return matrix.map(row => softmax(row));
}

/**
 * Apply function element-wise to matrix
 */
export function elementwiseApply(matrix, fn) {
    return matrix.map(row => row.map(fn));
}
```

### Visualizing Matrix Operations

```javascript
// 📁 src/primers/math/matrix-demo.js
/**
 * Matrix Operations Demo
 * 
 * Demonstrates matrix operations with real examples
 * from LLM applications.
 */

import {
    randomMatrix,
    zeroMatrix,
    matrixAdd,
    matrixMultiply,
    transpose,
    softmax,
    matrixSoftmax
} from './matrices.js';

function runMatrixDemo() {
    console.log('='.repeat(60));
    console.log('📊 Matrix Operations Demo');
    console.log('='.repeat(60));
    
    // 1. The embedding matrix
    console.log('\n📚 1. Embedding Matrix');
    console.log('─'.repeat(40));
    
    const vocabSize = 5;
    const embeddingDim = 4;
    const embeddingMatrix = randomMatrix(vocabSize, embeddingDim, -0.1, 0.1);
    
    console.log(`Vocabulary size: ${vocabSize}`);
    console.log(`Embedding dimension: ${embeddingDim}`);
    console.log('Embedding Matrix (tokens × embeddings):');
    for (let i = 0; i < vocabSize; i++) {
        console.log(`  Token ${i}: [${embeddingMatrix[i].map(v => v.toFixed(3)).join(', ')}]`);
    }
    
    // 2. Attention computation
    console.log('\n🔍 2. Attention Score Computation');
    console.log('─'.repeat(40));
    console.log('  Formula: Attention(Q,K) = softmax(Q × K^T / √d_k)');
    
    const seqLen = 3;
    const d_k = 4;
    
    // Q (queries) and K (keys) from the embedding matrix
    const Q = randomMatrix(seqLen, d_k, -0.5, 0.5);
    const K = randomMatrix(seqLen, d_k, -0.5, 0.5);
    const K_T = transpose(K);
    
    console.log(`  Q (${seqLen}×${d_k}) and K (${seqLen}×${d_k})`);
    console.log(`  Q × K^T = (${seqLen}×${seqLen}) attention scores`);
    
    // Compute attention scores
    const scores = matrixMultiply(Q, K_T);
    const scaledScores = matrixScalarMultiply(scores, 1 / Math.sqrt(d_k));
    const attentionWeights = matrixSoftmax(scaledScores);
    
    console.log('  Attention weights (row = query, col = key):');
    for (let i = 0; i < seqLen; i++) {
        console.log(`  Query ${i}: [${attentionWeights[i].map(v => v.toFixed(3)).join(', ')}]`);
    }
    
    // 3. Linear layer transformation
    console.log('\n🧠 3. Linear Layer (Matrix Multiplication)');
    console.log('─'.repeat(40));
    console.log('  Formula: Output = X × W + b');
    
    const inputDim = 4;
    const outputDim = 3;
    const W = randomMatrix(inputDim, outputDim, -0.1, 0.1);
    const b = randomMatrix(1, outputDim, -0.1, 0.1);
    
    console.log(`  Input dimension: ${inputDim}`);
    console.log(`  Output dimension: ${outputDim}`);
    console.log(`  Weight matrix: ${inputDim}×${outputDim}`);
    
    const input = randomMatrix(1, inputDim, -0.5, 0.5);
    const output = matrixMultiply(input, W);
    const outputWithBias = output.map((row, i) => 
        row.map((v, j) => v + b[0][j])
    );
    
    console.log(`  Input: [${input[0].map(v => v.toFixed(3)).join(', ')}]`);
    console.log(`  Output: [${outputWithBias[0].map(v => v.toFixed(3)).join(', ')}]`);
    
    // 4. Multi-head attention dimensions
    console.log('\n🔄 4. Multi-Head Attention Dimensions');
    console.log('─'.repeat(40));
    
    const d_model = 64;
    const numHeads = 8;
    const d_k_head = d_model / numHeads;
    const d_v_head = d_model / numHeads;
    
    console.log(`  Model dimension: ${d_model}`);
    console.log(`  Number of heads: ${numHeads}`);
    console.log(`  d_k per head: ${d_k_head}`);
    console.log(`  d_v per head: ${d_v_head}`);
    
    console.log('\n  Head weights (each head has Q, K, V projections):');
    for (let h = 0; h < numHeads; h++) {
        console.log(`  Head ${h}:`);
        console.log(`    W_Q: ${d_model}×${d_k_head} = ${d_model * d_k_head} params`);
        console.log(`    W_K: ${d_model}×${d_k_head} = ${d_model * d_k_head} params`);
        console.log(`    W_V: ${d_model}×${d_v_head} = ${d_model * d_v_head} params`);
    }
    console.log(`  Output projection: ${d_model}×${d_model} = ${d_model * d_model} params`);
    
    // 5. Practical: Layer Norm
    console.log('\n📊 5. Layer Normalization');
    console.log('─'.repeat(40));
    console.log('  Formula: LN(x) = γ * (x - μ) / √(σ² + ε) + β');
    
    const sampleInput = [0.5, -0.2, 1.3, -0.8, 0.1];
    const mean = sampleInput.reduce((a, b) => a + b, 0) / sampleInput.length;
    const variance = sampleInput.reduce((a, b) => a + (b - mean) ** 2, 0) / sampleInput.length;
    const eps = 1e-6;
    const normalized = sampleInput.map(v => (v - mean) / Math.sqrt(variance + eps));
    
    console.log(`  Input: [${sampleInput.map(v => v.toFixed(2)).join(', ')}]`);
    console.log(`  Mean: ${mean.toFixed(3)}, Variance: ${variance.toFixed(3)}`);
    console.log(`  Normalized: [${normalized.map(v => v.toFixed(3)).join(', ')}]`);
    
    console.log('\n' + '='.repeat(60));
}

// Run the demo
runMatrixDemo();
```

---

## P1.4 The Three Most Important Operations

### 1. Matrix Multiplication (The Workhorse)

```
Input: X ∈ ℝ^(batch×seq×d_model)
Weights: W ∈ ℝ^(d_model×d_ff)
Output: X × W ∈ ℝ^(batch×seq×d_ff)
```

In LLMs, matrix multiplication is used for:
- **Token embeddings**: Vocab × d_model
- **Linear layers**: d_model × d_ff
- **Attention**: Q × K^T, Attention × V
- **Positional encoding**: Position × d_model

**Visual Example:**

```
A (2×3) × B (3×4) = C (2×4)

A = [1 2 3]    B = [1 2 3 4]    C = [30 36 42 48]
    [4 5 6]        [5 6 7 8]        [66 81 96 111]
                   [9 0 1 2]

C[0,0] = 1*1 + 2*5 + 3*9 = 1 + 10 + 27 = 30
C[0,1] = 1*2 + 2*6 + 3*0 = 2 + 12 + 0 = 36
...
```

### 2. Transpose (The Orientation Changer)

```
A (2×3) → A^T (3×2)

A = [1 2 3]    A^T = [1 4]
    [4 5 6]         [2 5]
                    [3 6]
```

In LLMs, transpose is used for:
- **Attention**: Q × K^T
- **Backpropagation**: Gradients flow backwards

### 3. Softmax (The Probability Maker)

```
Input: [2.0, 1.0, 0.5]
Output: [0.545, 0.200, 0.122, ...]

Formula: softmax(x_i) = exp(x_i) / ∑ exp(x_j)
```

In LLMs, softmax is used for:
- **Output probabilities**: Next token prediction
- **Attention weights**: Focus on relevant tokens

---

## P1.5 Practical Example: The Embedding Lookup

```javascript
// 📁 src/primers/math/embedding-lookup.js
/**
 * Embedding Lookup Example
 * 
 * Demonstrates how token IDs become embeddings
 * using matrix operations.
 */

import { randomMatrix, zeroMatrix } from './matrices.js';

function runEmbeddingLookup() {
    console.log('='.repeat(60));
    console.log('🔤 Embedding Lookup Demo');
    console.log('='.repeat(60));
    
    // 1. Create embedding matrix
    const vocabSize = 10;
    const embeddingDim = 4;
    const embeddingMatrix = randomMatrix(vocabSize, embeddingDim, -0.1, 0.1);
    
    console.log('\n📚 1. Embedding Matrix');
    console.log(`  Vocabulary size: ${vocabSize}`);
    console.log(`  Embedding dimension: ${embeddingDim}`);
    console.log('  Shape: [tokens × embeddings]');
    
    for (let i = 0; i < vocabSize; i++) {
        console.log(`  Token ${i}: [${embeddingMatrix[i].map(v => v.toFixed(3)).join(', ')}]`);
    }
    
    // 2. Token IDs (from tokenizer)
    const tokenIds = [2, 5, 7, 2];
    console.log(`\n📝 Token IDs: ${tokenIds.join(', ')}`);
    
    // 3. Look up embeddings
    const embeddings = tokenIds.map(id => embeddingMatrix[id]);
    console.log('\n🎯 3. Embeddings Lookup');
    for (let i = 0; i < tokenIds.length; i++) {
        console.log(`  Token ${tokenIds[i]}: [${embeddings[i].map(v => v.toFixed(3)).join(', ')}]`);
    }
    
    // 4. Batch embedding matrix
    console.log('\n📦 4. Batch Embedding Matrix');
    console.log('  Shape: [batch_size × seq_len × embedding_dim]');
    console.log(`  This is what the transformer receives as input!`);
    
    const batchSize = 2;
    const seqLen = 4;
    const batchEmbeddings = [];
    
    for (let b = 0; b < batchSize; b++) {
        const batch = [];
        for (let s = 0; s < seqLen; s++) {
            const tokenId = Math.floor(Math.random() * vocabSize);
            batch.push(embeddingMatrix[tokenId]);
        }
        batchEmbeddings.push(batch);
    }
    
    console.log(`\n  Batch 1: ${batchEmbeddings[0].length} tokens`);
    console.log(`  Batch 2: ${batchEmbeddings[1].length} tokens`);
    console.log(`  Each embedding: ${embeddingDim} dimensions`);
    
    // 5. Relationship to word2vec
    console.log('\n🔗 5. Connection to Word2vec');
    console.log('  In Word2Vec, the embedding matrix is learned!');
    console.log('  Token → Embedding → Semantic Understanding');
    console.log('  "king" and "queen" have similar embeddings');
    console.log('  "apple" and "orange" have similar embeddings');
    console.log('  "king" - "man" + "woman" ≈ "queen"');
    
    console.log('\n' + '='.repeat(60));
}

runEmbeddingLookup();
```

---

## P1.6 Practice Exercises

### Exercise 1: Semantic Search
**Task**: Implement a function that finds the most semantically similar word to a query.

```javascript
function semanticSearch(queryEmbedding, embeddingMatrix, vocabulary) {
    // Calculate cosine similarity between query and all words
    // Return top 5 most similar words
    
    // HINT: Use cosineSimilarity function
    // HINT: Sort by similarity descending
}
```

### Exercise 2: Attention Computation
**Task**: Compute attention weights for a simple sequence.

```javascript
function computeAttention(Q, K, V) {
    // 1. Compute Q × K^T
    // 2. Scale by √d_k
    // 3. Apply softmax
    // 4. Multiply by V
    // Return attention output and weights
    
    // HINT: Use matrixMultiply, transpose, matrixScalarMultiply, softmax
}
```

### Exercise 3: Word Analogy
**Task**: Find the word that completes the analogy.

```javascript
function findAnalogy(wordA, wordB, wordC, embeddings, vocabulary) {
    // Compute: embeddingB - embeddingA + embeddingC
    // Find closest word in vocabulary
    // Return the word and its similarity
    
    // HINT: Use vectorSubtract, vectorAdd, cosineSimilarity
}
```

---

## P1.7 Quick Reference Card

```javascript
// QUICK REFERENCE - LINEAR ALGEBRA

// VECTORS
const v1 = [1, 2, 3];
const v2 = [4, 5, 6];

// Vector addition
const sum = [v1[0]+v2[0], v1[1]+v2[1], v1[2]+v2[2]];

// Dot product
const dot = v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];

// Norm (length)
const norm = Math.sqrt(v1[0]**2 + v1[1]**2 + v1[2]**2);

// Cosine similarity
const cosSim = dot / (norm1 * norm2);

// MATRICES
const A = [[1, 2, 3], [4, 5, 6]];
const B = [[7, 8], [9, 10], [11, 12]];

// Matrix multiplication: A(2×3) × B(3×2) = C(2×2)
const C = [
    [1*7+2*9+3*11, 1*8+2*10+3*12],
    [4*7+5*9+6*11, 4*8+5*10+6*12]
];

// Transpose
const A_T = [[1, 4], [2, 5], [3, 6]];

// Softmax
function softmax(z) {
    const max = Math.max(...z);
    const exp = z.map(v => Math.exp(v - max));
    const sum = exp.reduce((a, b) => a + b, 0);
    return exp.map(v => v / sum);
}
```

---

**[END OF PRIMER 1]**
