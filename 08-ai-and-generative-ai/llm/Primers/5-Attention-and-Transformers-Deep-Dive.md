# Primer 5: Advanced Topics — Attention and Transformers Deep Dive

This primer provides a comprehensive deep dive into the attention mechanism and transformer architecture, the cornerstones of modern LLMs. If you've ever wondered how attention really works, why transformers are so powerful, or what the "dark knowledge" in distillation means, this guide will explain it all with intuitive analogies and practical JavaScript examples.

---

## P5.1 Why Attention is Revolutionary

### The Core Insight

**Attention changed everything because it solved the "long-range dependency" problem.**

Before attention, models struggled with long sequences:
- **RNNs**: Information fades over time
- **LSTMs**: Better, but still limited to ~100 tokens
- **Attention**: Can connect any two tokens directly, regardless of distance

```
Without Attention:
"John, who lived in New York and worked as a software engineer, [100 words later] ... eventually moved to Boston."
→ The model forgets John is the subject

With Attention:
"John ... eventually moved to Boston."
→ The model directly connects "John" to "moved"
→ No information loss over distance
```

### What You'll Learn

| Concept | Why It Matters | Where Used |
|---------|---------------|------------|
| **Attention Scores** | Which tokens are related | Self-attention, cross-attention |
| **Multi-Head Attention** | Different relationship types | Every transformer layer |
| **Causal Attention** | Autoregressive generation | Decoder-only transformers |
| **Cross-Attention** | Sequence-to-sequence | Translation, summarization |
| **Flash Attention** | Efficient implementation | Production deployments |
| **KV Cache** | Fast inference | Generation, serving |
| **Paged Attention** | Long contexts | vLLM, production serving |

---

## P5.2 Attention Mechanism Deep Dive

### The Target
We'll implement attention from first principles and visualize how it works.

### The Concept

**Think of attention like a team of information seekers and providers.**

- **Queries**: "What information am I looking for?"
- **Keys**: "What information do I have?"
- **Values**: "What is the actual content?"
- **Attention**: "How much should I focus on each piece of information?"

```
Attention Process:
1. Query looks at all Keys
2. Computes similarity scores
3. Softmax converts to weights
4. Weights multiply Values
5. Result is weighted sum

Result: Focus on relevant information, ignore irrelevant
```

### The Implementation

```javascript
// 📁 src/primers/attention/attention-deep-dive.js
/**
 * Attention Mechanism Deep Dive
 * 
 * Comprehensive implementation of attention with visualization
 * and analysis tools.
 */

import { dotProduct, softmax } from '../math/vectors.js';
import { matrixMultiply, transpose } from '../math/matrices.js';

/**
 * Compute attention scores between queries and keys
 * @param {number[][]} Q - Query matrix [seqLen, d_k]
 * @param {number[][]} K - Key matrix [seqLen, d_k]
 * @param {number} scale - Scaling factor (default: √d_k)
 * @returns {number[][]} Attention scores [seqLen, seqLen]
 */
export function computeAttentionScores(Q, K, scale = null) {
    const d_k = Q[0].length;
    const scaleFactor = scale || Math.sqrt(d_k);
    
    // Q × K^T
    const K_T = transpose(K);
    const scores = matrixMultiply(Q, K_T);
    
    // Scale
    return scores.map(row => row.map(v => v / scaleFactor));
}

/**
 * Apply softmax to attention scores
 */
export function applyAttentionSoftmax(scores, mask = null) {
    let maskedScores = scores;
    if (mask) {
        maskedScores = scores.map((row, i) =>
            row.map((v, j) => mask[i][j] ? v : -1e9)
        );
    }
    return maskedScores.map(row => softmax(row));
}

/**
 * Complete attention computation with visualization
 */
export function computeAttention(Q, K, V, mask = null) {
    // 1. Compute scores
    const scores = computeAttentionScores(Q, K);
    
    // 2. Apply softmax
    const weights = applyAttentionSoftmax(scores, mask);
    
    // 3. Multiply by V
    const output = matrixMultiply(weights, V);
    
    return {
        scores: scores,
        weights: weights,
        output: output,
        stats: {
            scoreStats: getStats(scores),
            weightStats: getStats(weights),
            outputStats: getStats(output)
        }
    };
}

/**
 * Get statistics for a matrix
 */
function getStats(matrix) {
    const flat = matrix.flat();
    const sum = flat.reduce((a, b) => a + b, 0);
    const mean = sum / flat.length;
    const variance = flat.reduce((a, b) => a + (b - mean) ** 2, 0) / flat.length;
    const std = Math.sqrt(variance);
    
    return {
        mean: mean,
        std: std,
        min: Math.min(...flat),
        max: Math.max(...flat),
        sum: sum
    };
}

/**
 * Visualize attention weights
 * @param {number[][]} weights - Attention weights [seqLen, seqLen]
 * @param {string[]} labels - Token labels for axes
 * @returns {string} ASCII visualization
 */
export function visualizeAttention(weights, labels = null) {
    const n = weights.length;
    const maxVal = Math.max(...weights.flat());
    
    // Create ASCII heatmap
    const rows = [];
    for (let i = 0; i < n; i++) {
        let row = '';
        for (let j = 0; j < n; j++) {
            const intensity = Math.round((weights[i][j] / maxVal) * 9);
            const char = [' ', '░', '▒', '▓', '█', '█', '█', '▓', '▒', '░'][intensity] || ' ';
            row += char;
        }
        const label = labels && labels[i] ? labels[i].padStart(8).slice(0, 8) : String(i).padStart(4);
        rows.push(`${label} │${row}│`);
    }
    
    // Add header
    let header = '       ';
    for (let i = 0; i < n; i++) {
        const label = labels && labels[i] ? labels[i][0] : String(i);
        header += label;
    }
    
    return ['┌' + '─'.repeat(n + 2) + '┐', ...rows, '└' + '─'.repeat(n + 2) + '┘'];
}

/**
 * Analyze attention patterns
 */
export function analyzeAttention(weights) {
    const n = weights.length;
    const analysis = {
        sparsity: 0,
        entropy: [],
        maxWeight: 0,
        maxPosition: [0, 0]
    };
    
    for (let i = 0; i < n; i++) {
        // Entropy for each row
        let entropy = 0;
        for (const w of weights[i]) {
            if (w > 0) entropy -= w * Math.log(w);
        }
        analysis.entropy.push(entropy);
        
        // Find max
        for (let j = 0; j < n; j++) {
            if (weights[i][j] > analysis.maxWeight) {
                analysis.maxWeight = weights[i][j];
                analysis.maxPosition = [i, j];
            }
        }
    }
    
    // Sparsity: fraction of weights that are very small
    const threshold = 0.01;
    let smallCount = 0;
    for (const row of weights) {
        for (const w of row) {
            if (w < threshold) smallCount++;
        }
    }
    analysis.sparsity = smallCount / (n * n);
    
    analysis.avgEntropy = analysis.entropy.reduce((a, b) => a + b, 0) / n;
    
    return analysis;
}

// Example usage
function runAttentionDemo() {
    console.log('='.repeat(60));
    console.log('🔍 Attention Mechanism Deep Dive');
    console.log('='.repeat(60));

    // 1. Simple attention example
    console.log('\n📊 1. Basic Attention Computation');
    console.log('─'.repeat(40));

    const seqLen = 4;
    const d_k = 3;
    
    // Create sample Q, K, V
    const Q = [
        [1, 0, 0],  // Query 1
        [0, 1, 0],  // Query 2
        [0, 0, 1],  // Query 3
        [1, 1, 0]   // Query 4
    ];
    
    const K = [
        [1, 0, 0],  // Key 1
        [0, 1, 0],  // Key 2
        [0, 0, 1],  // Key 3
        [0, 1, 1]   // Key 4
    ];
    
    const V = [
        [1, 0],     // Value 1
        [0, 1],     // Value 2
        [1, 1],     // Value 3
        [0, 0]      // Value 4
    ];
    
    console.log('  Query matrix Q (4×3):');
    for (const row of Q) console.log(`    [${row.join(', ')}]`);
    
    console.log('\n  Key matrix K (4×3):');
    for (const row of K) console.log(`    [${row.join(', ')}]`);
    
    console.log('\n  Value matrix V (4×2):');
    for (const row of V) console.log(`    [${row.join(', ')}]`);
    
    // Compute attention
    const result = computeAttention(Q, K, V);
    
    console.log('\n  Attention Scores (Q × K^T / √d_k):');
    for (const row of result.scores) {
        console.log(`    [${row.map(v => v.toFixed(2)).join(', ')}]`);
    }
    
    console.log('\n  Attention Weights (softmax):');
    for (const row of result.weights) {
        console.log(`    [${row.map(v => v.toFixed(2)).join(', ')}]`);
    }
    
    console.log('\n  Output:');
    for (const row of result.output) {
        console.log(`    [${row.map(v => v.toFixed(2)).join(', ')}]`);
    }
    
    // 2. Visualize attention
    console.log('\n🎨 2. Attention Visualization');
    console.log('─'.repeat(40));
    
    const labels = ['Q1', 'Q2', 'Q3', 'Q4'];
    const viz = visualizeAttention(result.weights, labels);
    console.log('  Attention Heatmap (darker = higher attention):');
    for (const line of viz) {
        console.log(`  ${line}`);
    }
    
    // 3. Analyze attention patterns
    console.log('\n📈 3. Attention Analysis');
    console.log('─'.repeat(40));
    
    const analysis = analyzeAttention(result.weights);
    console.log(`  Sparsity: ${(analysis.sparsity * 100).toFixed(1)}%`);
    console.log(`  Avg Entropy: ${analysis.avgEntropy.toFixed(3)}`);
    console.log(`  Max Weight: ${analysis.maxWeight.toFixed(3)} at position (${analysis.maxPosition.join(', ')})`);
    console.log(`  Row Entropies: [${analysis.entropy.map(e => e.toFixed(3)).join(', ')}]`);
    
    // 4. Causal attention
    console.log('\n🚫 4. Causal Attention (Masked)');
    console.log('─'.repeat(40));
    console.log('  Causal attention: each token can only attend to itself and previous tokens');
    
    const causalMask = [];
    for (let i = 0; i < seqLen; i++) {
        const row = [];
        for (let j = 0; j < seqLen; j++) {
            row.push(j <= i);
        }
        causalMask.push(row);
    }
    
    console.log('  Mask (true = can attend):');
    for (const row of causalMask) {
        console.log(`    [${row.map(v => v ? '✓' : '✗').join(' ')}]`);
    }
    
    const causalResult = computeAttention(Q, K, V, causalMask);
    console.log('\n  Causal Attention Weights:');
    for (const row of causalResult.weights) {
        console.log(`    [${row.map(v => v.toFixed(2)).join(', ')}]`);
    }
    
    console.log('\n' + '='.repeat(60));
}

runAttentionDemo();
```

---

## P5.3 Multi-Head Attention Deep Dive

### The Target
We'll implement multi-head attention and understand why multiple heads are necessary.

### The Concept

**Each attention head learns a different type of relationship.**

- **Head 1**: Syntactic patterns (subject-verb)
- **Head 2**: Semantic relationships (word meaning)
- **Head 3**: Positional relationships (nearby words)
- **Head 4**: Long-range dependencies (distant connections)

```
Multi-Head Attention:
Input → [Head 1] → Pattern 1
      → [Head 2] → Pattern 2
      → [Head 3] → Pattern 3
      → [Head 4] → Pattern 4
      → Concatenate → Output

Together, heads capture a rich understanding of the input.
```

### The Implementation

```javascript
// 📁 src/primers/attention/multi-head.js
/**
 * Multi-Head Attention Deep Dive
 * 
 * Implementation and analysis of multi-head attention.
 */

import { matrixMultiply, transpose } from '../math/matrices.js';
import { computeAttention, analyzeAttention } from './attention-deep-dive.js';

/**
 * Multi-Head Attention Implementation
 */
export class MultiHeadAttention {
    /**
     * Create multi-head attention
     * @param {Object} config
     * @param {number} config.d_model - Model dimension
     * @param {number} config.numHeads - Number of heads
     * @param {number} config.d_k - Key dimension per head
     * @param {number} config.d_v - Value dimension per head
     */
    constructor(config) {
        this.d_model = config.d_model || 64;
        this.numHeads = config.numHeads || 4;
        this.d_k = config.d_k || this.d_model / this.numHeads;
        this.d_v = config.d_v || this.d_model / this.numHeads;
        
        if (this.d_model % this.numHeads !== 0) {
            throw new Error(`d_model (${this.d_model}) must be divisible by numHeads (${this.numHeads})`);
        }
    }

    /**
     * Split projections into heads
     */
    _splitHeads(projection) {
        const seqLen = projection.length;
        const heads = [];
        for (let h = 0; h < this.numHeads; h++) {
            const head = [];
            for (let i = 0; i < seqLen; i++) {
                const start = h * this.d_k;
                const end = start + this.d_k;
                head.push(projection[i].slice(start, end));
            }
            heads.push(head);
        }
        return heads;
    }

    /**
     * Concatenate heads
     */
    _concatenateHeads(headOutputs) {
        const seqLen = headOutputs[0].length;
        const d_v = headOutputs[0][0].length;
        const result = [];
        for (let i = 0; i < seqLen; i++) {
            const row = [];
            for (let h = 0; h < this.numHeads; h++) {
                row.push(...headOutputs[h][i]);
            }
            result.push(row);
        }
        return result;
    }

    /**
     * Forward pass
     */
    forward(X, mask = null) {
        const seqLen = X.length;
        
        // For simplicity, we'll use fixed random projections
        // In practice, these would be learned
        const d_model = this.d_model;
        const d_k = this.d_k;
        
        // Generate random projections (simplified)
        const W_Q = Array.from({ length: d_model }, () =>
            Array.from({ length: d_k * this.numHeads }, () => Math.random() - 0.5)
        );
        const W_K = Array.from({ length: d_model }, () =>
            Array.from({ length: d_k * this.numHeads }, () => Math.random() - 0.5)
        );
        const W_V = Array.from({ length: d_model }, () =>
            Array.from({ length: this.d_v * this.numHeads }, () => Math.random() - 0.5)
        );
        
        // Project Q, K, V
        const Q = matrixMultiply(X, W_Q);
        const K = matrixMultiply(X, W_K);
        const V = matrixMultiply(X, W_V);
        
        // Split into heads
        const Q_heads = this._splitHeads(Q);
        const K_heads = this._splitHeads(K);
        const V_heads = this._splitHeads(V);
        
        // Process each head
        const headOutputs = [];
        const headWeights = [];
        const headAnalyses = [];
        
        for (let h = 0; h < this.numHeads; h++) {
            const result = computeAttention(Q_heads[h], K_heads[h], V_heads[h], mask);
            headOutputs.push(result.output);
            headWeights.push(result.weights);
            headAnalyses.push(analyzeAttention(result.weights));
        }
        
        // Concatenate heads
        const concatenated = this._concatenateHeads(headOutputs);
        
        // Output projection (simplified)
        const W_O = Array.from({ length: this.numHeads * this.d_v }, () =>
            Array.from({ length: d_model }, () => Math.random() - 0.5)
        );
        const output = matrixMultiply(concatenated, W_O);
        
        return {
            output: output,
            headWeights: headWeights,
            headAnalyses: headAnalyses,
            numHeads: this.numHeads
        };
    }

    /**
     * Analyze head behavior
     */
    analyzeHeads(headAnalyses) {
        const results = [];
        for (let h = 0; h < headAnalyses.length; h++) {
            const analysis = headAnalyses[h];
            results.push({
                head: h,
                sparsity: analysis.sparsity,
                entropy: analysis.avgEntropy,
                maxWeight: analysis.maxWeight,
                focus: analysis.sparsity < 0.5 ? 'distributed' : 'focused'
            });
        }
        return results;
    }
}

/**
 * Visualize multi-head attention patterns
 */
export function visualizeMultiHead(headWeights, labels = null) {
    const numHeads = headWeights.length;
    console.log(`\n  Multi-Head Attention: ${numHeads} heads`);
    console.log('  ─'.repeat(40));
    
    for (let h = 0; h < numHeads; h++) {
        console.log(`\n  Head ${h + 1}:`);
        const viz = visualizeAttention(headWeights[h], labels);
        for (const line of viz) {
            console.log(`    ${line}`);
        }
    }
}

// Example usage
function runMultiHeadDemo() {
    console.log('='.repeat(60));
    console.log('🧠 Multi-Head Attention Deep Dive');
    console.log('='.repeat(60));

    // 1. Create multi-head attention
    console.log('\n📊 1. Multi-Head Attention Setup');
    console.log('─'.repeat(40));

    const mha = new MultiHeadAttention({
        d_model: 8,
        numHeads: 4
    });
    
    console.log(`  d_model: ${mha.d_model}`);
    console.log(`  numHeads: ${mha.numHeads}`);
    console.log(`  d_k: ${mha.d_k}`);
    console.log(`  d_v: ${mha.d_v}`);

    // 2. Forward pass
    console.log('\n🔄 2. Forward Pass');
    console.log('─'.repeat(40));

    const seqLen = 4;
    const X = Array.from({ length: seqLen }, () =>
        Array.from({ length: mha.d_model }, () => Math.random() - 0.5)
    );
    
    console.log('  Input shape:', `${X.length} × ${X[0].length}`);
    
    const result = mha.forward(X);
    console.log('  Output shape:', `${result.output.length} × ${result.output[0].length}`);
    console.log(`  Number of heads: ${result.numHeads}`);

    // 3. Analyze heads
    console.log('\n📈 3. Head Analysis');
    console.log('─'.repeat(40));

    const headAnalysis = mha.analyzeHeads(result.headAnalyses);
    for (const info of headAnalysis) {
        console.log(`\n  Head ${info.head + 1}:`);
        console.log(`    Sparsity: ${(info.sparsity * 100).toFixed(1)}%`);
        console.log(`    Entropy: ${info.entropy.toFixed(3)}`);
        console.log(`    Focus: ${info.focus}`);
        console.log(`    Max attention: ${info.maxWeight.toFixed(3)}`);
    }

    // 4. Visualize head attention
    console.log('\n🎨 4. Attention Patterns by Head');
    console.log('─'.repeat(40));

    const labels = ['T1', 'T2', 'T3', 'T4'];
    visualizeMultiHead(result.headWeights, labels);

    console.log('\n' + '='.repeat(60));
}

runMultiHeadDemo();
```

---

## P5.4 Cross-Attention and Encoder-Decoder

### The Target
We'll implement cross-attention and understand the encoder-decoder architecture.

### The Concept

**Cross-attention connects two different sequences.**

- **Encoder**: Processes the source sequence (e.g., French)
- **Decoder**: Generates the target sequence (e.g., English)
- **Cross-Attention**: Allows decoder to attend to encoder

```
Translation Example:
French: "Le chat est sur le tapis"
         ↓ Encoder
[Encoded representations]
         ↓ Cross-Attention (decoder attends to encoder)
English: "The cat is on the mat"
```

### The Implementation

```javascript
// 📁 src/primers/attention/cross-attention.js
/**
 * Cross-Attention and Encoder-Decoder
 * 
 * Implementation of cross-attention and encoder-decoder architecture.
 */

import { computeAttention, visualizeAttention } from './attention-deep-dive.js';

/**
 * Cross-Attention: Decoder attends to Encoder
 * Q: From decoder, K/V: From encoder
 */
export function crossAttention(decoderQ, encoderK, encoderV, mask = null) {
    // Q comes from decoder, K/V come from encoder
    return computeAttention(decoderQ, encoderK, encoderV, mask);
}

/**
 * Simple Encoder-Decoder with Cross-Attention
 */
export class EncoderDecoder {
    /**
     * Create encoder-decoder
     * @param {Object} config
     * @param {number} config.d_model - Model dimension
     * @param {number} config.numHeads - Number of attention heads
     * @param {number} config.numLayers - Number of layers
     */
    constructor(config) {
        this.d_model = config.d_model || 64;
        this.numHeads = config.numHeads || 4;
        this.numLayers = config.numLayers || 2;
        
        // Simplified: use fixed random weights
        this.encoderWeights = this._initWeights();
        this.decoderWeights = this._initWeights();
        this.crossWeights = this._initWeights();
    }

    _initWeights() {
        return Array.from({ length: this.numLayers }, () => ({
            W_Q: Array.from({ length: this.d_model }, () =>
                Array.from({ length: this.d_model }, () => Math.random() - 0.5)
            ),
            W_K: Array.from({ length: this.d_model }, () =>
                Array.from({ length: this.d_model }, () => Math.random() - 0.5)
            ),
            W_V: Array.from({ length: this.d_model }, () =>
                Array.from({ length: this.d_model }, () => Math.random() - 0.5)
            )
        }));
    }

    /**
     * Simple linear projection
     */
    _project(X, W) {
        const output = [];
        for (const row of X) {
            const outRow = [];
            for (let j = 0; j < W[0].length; j++) {
                let sum = 0;
                for (let i = 0; i < row.length; i++) {
                    sum += row[i] * W[i][j];
                }
                outRow.push(sum);
            }
            output.push(outRow);
        }
        return output;
    }

    /**
     * Encoder forward pass
     */
    encode(input) {
        let current = input;
        const layerOutputs = [];
        
        for (let layer = 0; layer < this.numLayers; layer++) {
            const weights = this.encoderWeights[layer];
            
            // Self-attention
            const Q = this._project(current, weights.W_Q);
            const K = this._project(current, weights.W_K);
            const V = this._project(current, weights.W_V);
            
            const attention = computeAttention(Q, K, V);
            current = attention.output;
            layerOutputs.push(current);
        }
        
        return {
            output: current,
            layerOutputs: layerOutputs
        };
    }

    /**
     * Decoder forward pass with cross-attention
     */
    decode(decoderInput, encoderOutput) {
        let current = decoderInput;
        const crossAttentionOutputs = [];
        
        for (let layer = 0; layer < this.numLayers; layer++) {
            const weights = this.decoderWeights[layer];
            
            // Self-attention (decoder)
            const Q_self = this._project(current, weights.W_Q);
            const K_self = this._project(current, weights.W_K);
            const V_self = this._project(current, weights.W_V);
            
            const selfAttention = computeAttention(Q_self, K_self, V_self);
            const selfOutput = selfAttention.output;
            
            // Cross-attention (decoder attends to encoder)
            const Q_cross = this._project(selfOutput, this.crossWeights[layer].W_Q);
            const K_cross = this._project(encoderOutput, this.crossWeights[layer].W_K);
            const V_cross = this._project(encoderOutput, this.crossWeights[layer].W_V);
            
            const crossAttention = computeAttention(Q_cross, K_cross, V_cross);
            current = crossAttention.output;
            crossAttentionOutputs.push({
                selfAttention: selfAttention,
                crossAttention: crossAttention
            });
        }
        
        return {
            output: current,
            crossAttentionOutputs: crossAttentionOutputs
        };
    }
}

// Example usage
function runCrossAttentionDemo() {
    console.log('='.repeat(60));
    console.log('🔀 Cross-Attention and Encoder-Decoder Demo');
    console.log('='.repeat(60));

    // 1. Basic cross-attention
    console.log('\n📊 1. Cross-Attention');
    console.log('─'.repeat(40));

    const seqLenEncoder = 3;
    const seqLenDecoder = 2;
    const d_k = 4;
    const d_v = 4;

    // Encoder representations
    const encoderQ = Array.from({ length: seqLenEncoder }, () =>
        Array.from({ length: d_k }, () => Math.random() - 0.5)
    );
    const encoderK = Array.from({ length: seqLenEncoder }, () =>
        Array.from({ length: d_k }, () => Math.random() - 0.5)
    );
    const encoderV = Array.from({ length: seqLenEncoder }, () =>
        Array.from({ length: d_v }, () => Math.random() - 0.5)
    );

    // Decoder queries
    const decoderQ = Array.from({ length: seqLenDecoder }, () =>
        Array.from({ length: d_k }, () => Math.random() - 0.5)
    );

    console.log(`  Encoder: ${seqLenEncoder} tokens, ${d_k} dim`);
    console.log(`  Decoder: ${seqLenDecoder} tokens, ${d_k} dim`);

    const crossResult = crossAttention(decoderQ, encoderK, encoderV);
    console.log('\n  Cross-Attention Output:');
    for (const row of crossResult.output) {
        console.log(`    [${row.map(v => v.toFixed(2)).join(', ')}]`);
    }

    // 2. Encoder-Decoder demo
    console.log('\n📊 2. Encoder-Decoder Example');
    console.log('─'.repeat(40));
    console.log('  Simulating: French → English translation');

    const encdec = new EncoderDecoder({
        d_model: 8,
        numHeads: 2,
        numLayers: 2
    });

    // Simulate French sentence embeddings (3 tokens)
    const frenchInput = Array.from({ length: 3 }, () =>
        Array.from({ length: 8 }, () => Math.random() - 0.5)
    );

    // Simulate English sentence embeddings (4 tokens)
    const englishInput = Array.from({ length: 4 }, () =>
        Array.from({ length: 8 }, () => Math.random() - 0.5)
    );

    console.log(`  French tokens: ${frenchInput.length}`);
    console.log(`  English tokens: ${englishInput.length}`);

    // Encode French
    const encoded = encdec.encode(frenchInput);
    console.log('\n  Encoded French:');
    console.log(`    Output shape: ${encoded.output.length} × ${encoded.output[0].length}`);
    console.log(`    Layers: ${encoded.layerOutputs.length}`);

    // Decode to English with cross-attention
    const decoded = encdec.decode(englishInput, encoded.output);
    console.log('\n  Decoded English:');
    console.log(`    Output shape: ${decoded.output.length} × ${decoded.output[0].length}`);
    console.log(`    Cross-attention layers: ${decoded.crossAttentionOutputs.length}`);

    // 3. Show cross-attention patterns
    console.log('\n🎨 3. Cross-Attention Visualization');
    console.log('─'.repeat(40));

    // Use the first layer's cross-attention
    const crossWeights = decoded.crossAttentionOutputs[0].crossAttention.weights;
    const encoderLabels = ['F1', 'F2', 'F3'];
    const decoderLabels = ['E1', 'E2', 'E3', 'E4'];
    
    console.log('  Cross-attention: Decoder → Encoder');
    console.log('  (French → English attention weights)');
    console.log('  ═══');
    
    const viz = visualizeAttention(crossWeights, decoderLabels);
    for (const line of viz) {
        console.log(`    ${line}`);
    }

    console.log('\n' + '='.repeat(60));
}

runCrossAttentionDemo();
```

---

## P5.5 Flash Attention and KV Cache

### The Target
We'll understand efficient attention implementations for production.

### The Concept

**Flash Attention: Making attention faster and more memory-efficient.**

Traditional attention has O(n²) memory complexity. Flash Attention reduces this by:
1. **Tiling**: Process the sequence in blocks
2. **Recomputation**: Don't store the full attention matrix
3. **IO-aware**: Optimize for GPU memory hierarchy

**KV Cache: Reusing computations during generation.**

```
Without KV Cache:
Step 1: Process [token1] → Store nothing
Step 2: Process [token1, token2] → Recompute token1
Step 3: Process [token1, token2, token3] → Recompute token1, token2
→ O(n²) complexity

With KV Cache:
Step 1: Process [token1] → Store K,V for token1
Step 2: Process [token1, token2] → Reuse K,V for token1, only compute token2
Step 3: Process [token1, token2, token3] → Reuse K,V for token1,2, only compute token3
→ O(n) complexity
```

### The Implementation

```javascript
// 📁 src/primers/attention/flash-kv.js
/**
 * Efficient Attention: Flash Attention and KV Cache
 * 
 * Implementation of memory-efficient attention and KV caching.
 */

/**
 * Flash Attention (simplified)
 * Demonstrates the tiling concept
 */
export function flashAttention(Q, K, V, blockSize = 2) {
    const seqLen = Q.length;
    const d_k = Q[0].length;
    const d_v = V[0].length;
    
    // Simulate block processing
    const output = Array.from({ length: seqLen }, () => new Array(d_v).fill(0));
    
    for (let i = 0; i < seqLen; i += blockSize) {
        const qBlock = Q.slice(i, i + blockSize);
        
        // Process keys in blocks
        for (let j = 0; j < seqLen; j += blockSize) {
            const kBlock = K.slice(j, j + blockSize);
            const vBlock = V.slice(j, j + blockSize);
            
            // Compute attention for this block pair
            // In real Flash Attention, this is done incrementally
            // without storing the full attention matrix
            const scores = qBlock.map(q => 
                kBlock.map(k => dotProduct(q, k) / Math.sqrt(d_k))
            );
            
            // Apply softmax and accumulate
            // In practice, this is done in a numerically stable way
            for (let a = 0; a < qBlock.length; a++) {
                const row = scores[a];
                const weights = softmax(row);
                for (let b = 0; b < vBlock.length; b++) {
                    for (let c = 0; c < d_v; c++) {
                        output[i + a][c] += weights[b] * vBlock[b][c];
                    }
                }
            }
        }
    }
    
    return {
        output: output,
        blockSize: blockSize,
        memorySaved: `O(n²) → O(${blockSize} * n)`
    };
}

function dotProduct(a, b) {
    return a.reduce((sum, v, i) => sum + v * b[i], 0);
}

function softmax(arr) {
    const maxVal = Math.max(...arr);
    const expArr = arr.map(v => Math.exp(v - maxVal));
    const sumExp = expArr.reduce((a, b) => a + b, 0);
    return expArr.map(v => v / sumExp);
}

/**
 * KV Cache Implementation
 */
export class KVCache {
    constructor(maxSize = 1000) {
        this.cache = new Map();
        this.maxSize = maxSize;
        this.hits = 0;
        this.misses = 0;
    }

    /**
     * Get cache key
     */
    getKey(prompt, params = {}) {
        return JSON.stringify({ prompt, ...params });
    }

    /**
     * Get from cache
     */
    get(key) {
        if (this.cache.has(key)) {
            this.hits++;
            return this.cache.get(key);
        }
        this.misses++;
        return null;
    }

    /**
     * Set in cache
     */
    set(key, value) {
        if (this.cache.size >= this.maxSize) {
            // Evict oldest (first key)
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        this.cache.set(key, value);
    }

    /**
     * Get cache statistics
     */
    getStats() {
        const total = this.hits + this.misses;
        return {
            size: this.cache.size,
            maxSize: this.maxSize,
            hits: this.hits,
            misses: this.misses,
            hitRate: total > 0 ? this.hits / total : 0
        };
    }

    /**
     * Clear cache
     */
    clear() {
        this.cache.clear();
        this.hits = 0;
        this.misses = 0;
    }
}

/**
 * Simulate generation with KV cache
 */
export function simulateGenerationWithCache(model, prompt, maxTokens = 10) {
    const cache = new KVCache();
    let tokens = prompt;
    const generated = [];
    
    console.log(`\n  Generating with KV Cache:`);
    console.log(`  Prompt: "${prompt}"`);
    
    for (let step = 0; step < maxTokens; step++) {
        const key = cache.getKey(tokens);
        let cached = cache.get(key);
        
        if (cached) {
            console.log(`  Step ${step + 1}: Cache hit! Using cached K,V`);
            // Use cached K,V (simplified)
            const nextToken = `token_${step}`;
            generated.push(nextToken);
            tokens += ` ${nextToken}`;
        } else {
            console.log(`  Step ${step + 1}: Cache miss, computing K,V`);
            // Compute K,V (simplified)
            const kv = { keys: [], values: [] };
            cache.set(key, kv);
            
            // Generate next token (simplified)
            const nextToken = `token_${step}`;
            generated.push(nextToken);
            tokens += ` ${nextToken}`;
        }
    }
    
    return {
        generated: generated,
        cacheStats: cache.getStats(),
        fullText: tokens
    };
}

// Example usage
function runEfficientAttentionDemo() {
    console.log('='.repeat(60));
    console.log('⚡ Efficient Attention: Flash Attention & KV Cache');
    console.log('='.repeat(60));

    // 1. Flash Attention
    console.log('\n📊 1. Flash Attention (Tiling Concept)');
    console.log('─'.repeat(40));

    const seqLen = 8;
    const d_k = 4;
    const d_v = 3;

    const Q = Array.from({ length: seqLen }, () =>
        Array.from({ length: d_k }, () => Math.random() - 0.5)
    );
    const K = Array.from({ length: seqLen }, () =>
        Array.from({ length: d_k }, () => Math.random() - 0.5)
    );
    const V = Array.from({ length: seqLen }, () =>
        Array.from({ length: d_v }, () => Math.random() - 0.5)
    );

    console.log(`  Sequence length: ${seqLen}`);
    console.log(`  Q,K dimension: ${d_k}`);
    console.log(`  V dimension: ${d_v}`);

    const result = flashAttention(Q, K, V, 2);
    console.log(`\n  Output shape: ${result.output.length} × ${result.output[0].length}`);
    console.log(`  Block size: ${result.blockSize}`);
    console.log(`  Memory savings: ${result.memorySaved}`);

    // 2. KV Cache
    console.log('\n📊 2. KV Cache for Fast Generation');
    console.log('─'.repeat(40));

    const generationResult = simulateGenerationWithCache(
        {}, // dummy model
        "The quick brown",
        8
    );

    console.log(`\n  Generated: ${generationResult.generated.join(' ')}`);
    console.log(`  Full text: "${generationResult.fullText}"`);
    console.log(`\n  Cache Statistics:`);
    console.log(`    Size: ${generationResult.cacheStats.size}`);
    console.log(`    Hits: ${generationResult.cacheStats.hits}`);
    console.log(`    Misses: ${generationResult.cacheStats.misses}`);
    console.log(`    Hit Rate: ${(generationResult.cacheStats.hitRate * 100).toFixed(1)}%`);

    // 3. Performance comparison
    console.log('\n📊 3. Performance Comparison');
    console.log('─'.repeat(40));

    console.log('  Without KV Cache:');
    console.log(`    Complexity: O(n²) where n = sequence length`);
    console.log(`    Example: n=1000 → 1,000,000 operations per step`);
    
    console.log('\n  With KV Cache:');
    console.log(`    Complexity: O(n) where n = sequence length`);
    console.log(`    Example: n=1000 → 1,000 operations per step`);
    console.log(`    Speedup: ${1000}x for long sequences`);

    console.log('\n' + '='.repeat(60));
}

runEfficientAttentionDemo();
```

---

## P5.6 Practice Exercises

### Exercise 1: Attention Visualization
**Task**: Create a visualization that shows attention patterns for different input types.

```javascript
function visualizeAttentionPatterns() {
    // 1. Create different input sequences
    // 2. Compute attention for each
    // 3. Visualize patterns
    // 4. Compare patterns
    
    // HINT: Use visualizeAttention function
    // HINT: Try different Q, K, V patterns
}
```

### Exercise 2: Multi-Head Analysis
**Task**: Analyze what different attention heads learn.

```javascript
function analyzeHeads() {
    // 1. Create multi-head attention
    // 2. Process different inputs
    // 3. Analyze each head's pattern
    // 4. Identify head specializations
    
    // HINT: Use MultiHeadAttention class
    // HINT: Use analyzeAttention function
}
```

### Exercise 3: KV Cache Implementation
**Task**: Implement a complete KV cache for transformer generation.

```javascript
function implementKVCache() {
    // 1. Create KV cache class
    // 2. Integrate with transformer
    // 3. Test generation speed
    // 4. Measure performance improvement
    
    // HINT: Use KVCache class as starting point
    // HINT: Compare generation with and without cache
}
```

### Exercise 4: Cross-Attention for Translation
**Task**: Build a simple translation system using cross-attention.

```javascript
function buildTranslator() {
    // 1. Create encoder-decoder with cross-attention
    // 2. Encode source language
    // 3. Decode with cross-attention
    // 4. Generate translation
    
    // HINT: Use EncoderDecoder class
    // HINT: Use crossAttention function
}
```

---

## P5.7 Quick Reference Card

```javascript
// QUICK REFERENCE - ATTENTION AND TRANSFORMERS

// ATTENTION SCORES
scores = Q × K^T / √d_k

// ATTENTION WEIGHTS
weights = softmax(scores)

// ATTENTION OUTPUT
output = weights × V

// MULTI-HEAD
MultiHead(Q,K,V) = Concat(head_1,...,head_h) × W_O
head_i = Attention(Q × W_Q_i, K × W_K_i, V × W_V_i)

// CROSS-ATTENTION
Q: from decoder (target)
K,V: from encoder (source)

// CAUSAL ATTENTION
mask_{ij} = 1 if j ≤ i else 0
// Token can only attend to itself and previous tokens

// POSITIONAL ENCODING
PE(pos,2i) = sin(pos / 10000^(2i/d_model))
PE(pos,2i+1) = cos(pos / 10000^(2i/d_model))

// KV CACHE
Store: K_1..K_t, V_1..V_t
Reuse: For generation, only compute new K,V

// FLASH ATTENTION
Tiling: Process blocks
Recompute: Don't store full attention matrix
IO-aware: Optimize memory hierarchy

// COMPLEXITY
Standard Attention: O(n²) memory, O(n²) time
Flash Attention: O(n) memory, O(n²) time (faster)
KV Cache Generation: O(n) time (vs O(n²))

// KEY PATTERNS
Attention heads specialize in different patterns:
- Head 1: Syntactic (subject-verb)
- Head 2: Semantic (word meaning)
- Head 3: Positional (nearby words)
- Head 4: Long-range (distant connections)
```

---

**[END OF PRIMER 5]**

