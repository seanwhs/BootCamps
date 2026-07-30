# Appendix B: Complete API Reference — Transformer Architecture

This appendix provides comprehensive API documentation for the transformer architecture built throughout the series. Use this as a quick reference when working with attention mechanisms, positional encodings, and text generation.

---

## B.1 Attention Mechanism API

### Overview
The attention module implements scaled dot-product attention and multi-head attention, the core components of the Transformer architecture.

```javascript
import { 
    scaledDotProductAttention, 
    MultiHeadAttention 
} from './src/transformer/attention.js';
```

### Function: `scaledDotProductAttention`

```javascript
scaledDotProductAttention(Q, K, V, mask, scale)
```

Computes scaled dot-product attention.

**Parameters:**
- `Q` (number[][]): Query matrix [seq_len, d_k]
- `K` (number[][]): Key matrix [seq_len, d_k]
- `V` (number[][]): Value matrix [seq_len, d_v]
- `mask` (boolean[][]): Optional attention mask [seq_len, seq_len]
- `scale` (number): Optional scaling factor (default: √d_k)

**Returns:** `Object` - Attention output
```javascript
{
    output: number[][],         // Attention output [seq_len, d_v]
    attentionWeights: number[][] // Attention weights [seq_len, seq_len]
}
```

**Example:**
```javascript
const seqLen = 3;
const d_k = 4;
const d_v = 3;

const Q = [[1,0,0,0], [0,1,0,0], [0,0,1,0]];
const K = [[1,0,0,0], [0,1,0,0], [0,0,1,0]];
const V = [[1,0,0], [0,1,0], [0,0,1]];

const { output, attentionWeights } = scaledDotProductAttention(Q, K, V);
console.log(output); // [[0.8, 0.1, 0.1], ...]
```

---

### Class: `MultiHeadAttention`

```javascript
new MultiHeadAttention(config)
```

Implements multi-head attention with parallel attention heads.

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.d_model` | `number` | 512 | Model dimension |
| `config.numHeads` | `number` | 8 | Number of attention heads |
| `config.d_k` | `number` | `d_model / numHeads` | Key/query dimension per head |
| `config.d_v` | `number` | `d_model / numHeads` | Value dimension per head |
| `config.dropout` | `number` | 0.1 | Dropout rate |

**Methods:**

#### `forward(X, mask, KV)`

Forward pass through multi-head attention.

```javascript
const { output, attentionWeights } = mha.forward(X, mask);
```

**Parameters:**
- `X` (number[][]): Input embeddings [seq_len, d_model]
- `mask` (boolean[][]): Optional attention mask
- `KV` (Object): Optional KV cache for inference

**Returns:** `Object`
```javascript
{
    output: number[][],              // Output [seq_len, d_model]
    attentionWeights: number[][][],  // Weights per head [numHeads, seq_len, seq_len]
    Q: number[][],                   // Query projections
    K: number[][],                   // Key projections
    V: number[][]                    // Value projections
}
```

**Example:**
```javascript
const mha = new MultiHeadAttention({
    d_model: 64,
    numHeads: 4
});

const seqLen = 10;
const X = Array.from({ length: seqLen }, () => 
    Array.from({ length: 64 }, () => Math.random() - 0.5)
);

const { output, attentionWeights } = mha.forward(X);

console.log(output.length);          // 10
console.log(output[0].length);       // 64
console.log(attentionWeights.length); // 4 (heads)
```

#### `getNumParams()`

Gets number of parameters.

```javascript
const params = mha.getNumParams();
// Returns: 4 * d_model * d_model (Q, K, V, O projections)
```

**Returns:** `number` - Parameter count

---

## B.2 Positional Encoding API

### Overview
Adds position information to token embeddings using sinusoidal functions.

```javascript
import {
    generatePositionalEncodings,
    LearnedPositionalEmbeddings,
    addPositionalEncodings,
    getPositionEncoding,
    positionalSimilarity,
    visualizePositionalEncodings
} from './src/transformer/positional.js';
```

### Function: `generatePositionalEncodings`

```javascript
generatePositionalEncodings(seqLen, d_model, maxLen)
```

Generates sinusoidal positional encodings.

**Parameters:**
- `seqLen` (number): Sequence length
- `d_model` (number): Model dimension
- `maxLen` (number): Maximum sequence length (default: 10000)

**Returns:** `number[][]` - Positional encodings [seqLen, d_model]

**Example:**
```javascript
const encodings = generatePositionalEncodings(10, 64);
console.log(encodings.length);    // 10
console.log(encodings[0].length); // 64
```

### Class: `LearnedPositionalEmbeddings`

```javascript
new LearnedPositionalEmbeddings(config)
```

Learned positional embeddings (trainable).

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.maxLen` | `number` | 10000 | Maximum sequence length |
| `config.d_model` | `number` | 512 | Model dimension |

**Methods:**

#### `forward(seqLen)`

Gets positional embeddings for a sequence.

```javascript
const embeddings = posEmbeddings.forward(10);
// Returns: [10, d_model] array
```

**Parameters:**
- `seqLen` (number): Sequence length

**Returns:** `number[][]` - Positional embeddings

#### `update(gradients, learningRate)`

Updates embeddings during training.

```javascript
const gradients = [[0.01, -0.02, ...], ...];
posEmbeddings.update(gradients, 0.001);
```

**Parameters:**
- `gradients` (number[][]]): Gradients for each position
- `learningRate` (number): Learning rate (default: 0.001)

### Function: `addPositionalEncodings`

```javascript
addPositionalEncodings(embeddings, positionalEncodings)
```

Adds positional encodings to token embeddings.

**Parameters:**
- `embeddings` (number[][]): Token embeddings [seqLen, d_model]
- `positionalEncodings` (number[][]): Positional encodings [seqLen, d_model]

**Returns:** `number[][]` - Combined embeddings

**Example:**
```javascript
const tokenEmb = [[1,0,0], [0,1,0], [0,0,1]];
const posEmb = generatePositionalEncodings(3, 3);
const combined = addPositionalEncodings(tokenEmb, posEmb);
```

### Utility Functions

#### `getPositionEncoding(pos, dim, d_model, maxLen)`

Gets encoding for a specific position and dimension.

```javascript
const value = getPositionEncoding(5, 3, 64);
// Returns: number
```

#### `positionalSimilarity(pos1, pos2, d_model, maxLen)`

Computes similarity between two positional encodings.

```javascript
const sim = positionalSimilarity(0, 10, 64);
// Returns: 0.34
```

#### `visualizePositionalEncodings(seqLen, d_model, maxLen)`

Visualizes positional encodings.

```javascript
const viz = visualizePositionalEncodings(10, 64);
console.log(viz.sample);
// Shows sampled dimension values
```

---

## B.3 Transformer Block API

### Overview
Complete transformer block combining attention, feed-forward, and normalization.

```javascript
import { 
    TransformerBlock,
    FeedForward,
    LayerNorm
} from './src/transformer/transformer.js';
```

### Class: `TransformerBlock`

```javascript
new TransformerBlock(config)
```

Single transformer block with self-attention and feed-forward.

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.d_model` | `number` | 512 | Model dimension |
| `config.numHeads` | `number` | 8 | Number of attention heads |
| `config.d_ff` | `number` | `4 * d_model` | Feed-forward hidden dimension |
| `config.dropout` | `number` | 0.1 | Dropout rate |

**Methods:**

#### `forward(X, mask)`

Forward pass through transformer block.

```javascript
const { output, attentionWeights } = block.forward(X, mask);
```

**Parameters:**
- `X` (number[][]): Input embeddings [seq_len, d_model]
- `mask` (boolean[][]): Optional attention mask

**Returns:** `Object`
```javascript
{
    output: number[][],              // Output [seq_len, d_model]
    attentionWeights: number[][][]   // Attention weights per head
}
```

**Example:**
```javascript
const block = new TransformerBlock({
    d_model: 64,
    numHeads: 4,
    d_ff: 256
});

const seqLen = 10;
const X = Array.from({ length: seqLen }, () => 
    Array.from({ length: 64 }, () => Math.random() - 0.5)
);

const { output, attentionWeights } = block.forward(X);
```

#### `getNumParams()`

Gets number of parameters.

```javascript
const params = block.getNumParams();
// Returns: attention params + feed-forward params
```

### Class: `FeedForward`

```javascript
new FeedForward(config)
```

Feed-forward network with ReLU activation.

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.d_model` | `number` | 512 | Model dimension |
| `config.d_ff` | `number` | `4 * d_model` | Hidden dimension |
| `config.dropout` | `number` | 0.1 | Dropout rate |

**Methods:**

#### `forward(X)`

Forward pass through feed-forward network.

```javascript
const output = ff.forward(X);
// Returns: [seq_len, d_model]
```

**Parameters:**
- `X` (number[][]): Input [seq_len, d_model]

**Returns:** `number[][]` - Output [seq_len, d_model]

### Class: `LayerNorm`

```javascript
new LayerNorm(d_model, eps)
```

Layer normalization.

**Parameters:**
- `d_model` (number): Model dimension
- `eps` (number): Small constant for stability (default: 1e-6)

**Methods:**

#### `forward(X)`

Normalizes across feature dimension.

```javascript
const normalized = layerNorm.forward(X);
// Returns: [seq_len, d_model] normalized
```

**Parameters:**
- `X` (number[][]): Input [seq_len, d_model]

**Returns:** `number[][]` - Normalized output

---

## B.4 Complete Transformer API

### Overview
Complete decoder-only transformer model for text generation.

```javascript
import { Transformer } from './src/transformer/transformer.js';
```

### Constructor

```javascript
new Transformer(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.vocabSize` | `number` | 1000 | Vocabulary size |
| `config.d_model` | `number` | 64 | Model dimension |
| `config.numHeads` | `number` | 4 | Number of attention heads |
| `config.numLayers` | `number` | 3 | Number of transformer blocks |
| `config.d_ff` | `number` | `4 * d_model` | Feed-forward dimension |
| `config.maxLen` | `number` | 512 | Maximum sequence length |
| `config.dropout` | `number` | 0.1 | Dropout rate |

**Methods:**

#### `forward(tokenIds, mask, useCache)`

Forward pass through transformer.

```javascript
const { logits, attentionWeights } = transformer.forward(tokenIds);
```

**Parameters:**
- `tokenIds` (number[]): Input token IDs
- `mask` (boolean[][]): Optional attention mask
- `useCache` (boolean): Use KV cache (default: false)

**Returns:** `Object`
```javascript
{
    logits: number[][],              // [seq_len, vocabSize]
    attentionWeights: number[][][],  // Per layer, per head
    hiddenStates: number[][]         // Final hidden states
}
```

**Example:**
```javascript
const transformer = new Transformer({
    vocabSize: 1000,
    d_model: 64,
    numHeads: 4,
    numLayers: 3
});

const tokenIds = [1, 2, 3, 4, 5];
const { logits, attentionWeights } = transformer.forward(tokenIds);
console.log(logits.length);          // 5 (seq_len)
console.log(logits[0].length);       // 1000 (vocabSize)
```

#### `generate(inputIds, config)`

Generates text autoregressively.

```javascript
const outputIds = transformer.generate(inputIds, {
    maxTokens: 100,
    temperature: 0.8,
    topK: 40,
    topP: 0.9
});
```

**Parameters:**
- `inputIds` (number[]): Starting token IDs
- `config.maxTokens` (number): Maximum tokens to generate (default: 100)
- `config.temperature` (number): Sampling temperature (default: 1.0)
- `config.topK` (number): Top-K sampling (default: 0)
- `config.topP` (number): Top-P sampling (default: 0.0)

**Returns:** `number[]` - Generated token IDs

**Example:**
```javascript
const inputIds = tokenizer.encode("The quick brown");
const outputIds = transformer.generate(inputIds, {
    maxTokens: 50,
    temperature: 0.7,
    topK: 10
});
const generatedText = tokenizer.decode(outputIds);
```

#### `getNumParams()`

Gets total number of parameters.

```javascript
const params = transformer.getNumParams();
// Returns: number
```

#### `saveToFile(filepath)`

Saves model to disk.

```javascript
transformer.saveToFile('./models/transformer.json');
```

**Parameters:**
- `filepath` (string): Path to save file

#### `loadFromFile(filepath)`

Loads model from disk.

```javascript
transformer.loadFromFile('./models/transformer.json');
```

**Parameters:**
- `filepath` (string): Path to load file

**Returns:** `Transformer` (for chaining)

---

## B.5 Text Generation API

### Overview
High-level text generation system combining tokenization and transformer.

```javascript
import { TextGenerator } from './src/transformer/generation.js';
```

### Constructor

```javascript
new TextGenerator(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.pipeline` | `TextProcessingPipeline` | null | Tokenization pipeline |
| `config.transformer` | `Transformer` | null | Transformer model |
| `config.maxTokens` | `number` | 100 | Default max tokens |
| `config.temperature` | `number` | 1.0 | Default temperature |
| `config.topK` | `number` | 0 | Default top-K |
| `config.topP` | `number` | 0.0 | Default top-P |
| `config.stopTokens` | `string[]` | `['<\|endoftext\|>', '<\|eos\|>']` | Stop tokens |

**Methods:**

#### `generate(prompt, config)`

Generates text from a prompt.

```javascript
const result = generator.generate("The future of AI is", {
    maxTokens: 50,
    temperature: 0.8
});
```

**Parameters:**
- `prompt` (string): Input prompt
- `config` (Object): Override generation settings

**Returns:** `Object`
```javascript
{
    prompt: string,              // Original prompt
    generated: string,           // Generated text only
    fullText: string,            // Prompt + generated
    tokenIds: number[],          // Full token sequence
    tokens: string[],            // Full token strings
    promptTokens: number,        // Prompt length
    totalTokens: number,         // Total tokens
    generationTime: number,      // Time in seconds
    tokensPerSecond: number      // Generation speed
}
```

**Example:**
```javascript
const generator = new TextGenerator({
    pipeline: pipeline,
    transformer: transformer
});

const result = generator.generate(
    "The quick brown fox",
    { maxTokens: 30, temperature: 0.7 }
);

console.log(`Generated: ${result.generated}`);
console.log(`Speed: ${result.tokensPerSecond.toFixed(2)} tokens/sec`);
```

#### `generateStreaming(prompt, callback, config)`

Streams generation token by token.

```javascript
await generator.generateStreaming(
    "The quick brown fox",
    (data) => {
        if (data.isComplete) {
            console.log('Complete!');
        } else {
            process.stdout.write(data.token);
        }
    },
    { maxTokens: 30 }
);
```

**Parameters:**
- `prompt` (string): Input prompt
- `callback` (Function): Called for each token
- `config` (Object): Override generation settings

**Callback Data:**
```javascript
{
    token: string,          // Current token text
    tokenId: number,        // Current token ID
    step: number,           // Generation step
    isComplete: boolean,    // Whether generation is done
    fullGenerated: string   // Complete generated text (only on completion)
}
```

#### `getStats()`

Gets generator statistics.

```javascript
const stats = generator.getStats();
// Returns: { pipelineTrained: true, transformerInitialized: true, defaultConfig: {...} }
```

---

## B.6 Common Usage Patterns

### Complete Generation Pipeline

```javascript
import { TextProcessingPipeline } from './src/tokenizer/pipeline.js';
import { Transformer } from './src/transformer/transformer.js';
import { TextGenerator } from './src/transformer/generation.js';

// 1. Create pipeline
const pipeline = new TextProcessingPipeline({
    vocabSize: 2000,
    embeddingDim: 64
});
pipeline.train("Your training corpus...");

// 2. Create transformer
const transformer = new Transformer({
    vocabSize: pipeline.getStats().vocabSize,
    d_model: 64,
    numHeads: 4,
    numLayers: 3
});

// 3. Create generator
const generator = new TextGenerator({
    pipeline: pipeline,
    transformer: transformer,
    maxTokens: 100,
    temperature: 0.8
});

// 4. Generate
const result = generator.generate("The meaning of life is");
console.log(result.generated);
```

### Streaming Generation

```javascript
// Simple streaming to console
await generator.generateStreaming(
    "Once upon a time",
    (data) => {
        if (data.isComplete) {
            console.log(`\n\nComplete: ${data.fullGenerated}`);
        } else {
            process.stdout.write(data.token);
        }
    },
    { maxTokens: 50, temperature: 0.9 }
);

// Streaming with progress tracking
let tokenCount = 0;
await generator.generateStreaming(
    "The future of AI",
    (data) => {
        tokenCount++;
        console.log(`Token ${tokenCount}: ${data.token}`);
        if (data.isComplete) {
            console.log(`Total tokens: ${tokenCount}`);
        }
    }
);
```

### Batch Generation

```javascript
const prompts = [
    "The quick brown fox",
    "Once upon a time",
    "In the beginning"
];

const results = prompts.map(prompt => 
    generator.generate(prompt, { maxTokens: 20 })
);

for (const result of results) {
    console.log(`Prompt: ${result.prompt}`);
    console.log(`Generated: ${result.generated}`);
    console.log(`Speed: ${result.tokensPerSecond.toFixed(2)} tokens/sec`);
    console.log('---');
}
```

### Parameter Tuning

```javascript
// Different generation styles
const creativeResult = generator.generate("Tell me a story", {
    maxTokens: 100,
    temperature: 1.2,
    topK: 60,
    topP: 0.95
});

const factualResult = generator.generate("What is the capital of France?", {
    maxTokens: 50,
    temperature: 0.3,
    topK: 10,
    topP: 0.8
});

const balancedResult = generator.generate("Explain AI", {
    maxTokens: 80,
    temperature: 0.7,
    topK: 40,
    topP: 0.9
});
```

### Save and Load Models

```javascript
// Save complete setup
pipeline.saveToDirectory('./models/pipeline/');
transformer.saveToFile('./models/transformer.json');

// Load complete setup
const loadedPipeline = new TextProcessingPipeline();
loadedPipeline.loadFromDirectory('./models/pipeline/');

const loadedTransformer = new Transformer();
loadedTransformer.loadFromFile('./models/transformer.json');

const loadedGenerator = new TextGenerator({
    pipeline: loadedPipeline,
    transformer: loadedTransformer
});

// Verify
const result = loadedGenerator.generate("Test prompt");
console.log(result.generated);
```

---

## B.7 Performance Optimization

### KV Cache Integration

```javascript
// Enable KV caching for faster generation
const transformer = new Transformer({
    // ... config
});

// First forward pass caches keys/values
const { logits, kv } = transformer.forward(tokenIds, null, null);

// Subsequent passes use the cache
const { logits: nextLogits } = transformer.forward(
    [newTokenId],
    null,
    kv  // Pass cached KV
);
```

### Batch Processing

```javascript
// Process multiple prompts in parallel
const prompts = ['Prompt 1', 'Prompt 2', 'Prompt 3'];
const results = [];

for (const prompt of prompts) {
    const result = generator.generate(prompt, { maxTokens: 50 });
    results.push(result);
}
```

### Memory Management

```javascript
// Clear cache periodically
transformer.kvCache?.clear();

// Monitor memory usage
const memoryUsage = process.memoryUsage();
console.log(`Heap used: ${(memoryUsage.heapUsed / 1024 / 1024).toFixed(2)} MB`);

// Use smaller models for memory-constrained environments
const smallTransformer = new Transformer({
    d_model: 32,
    numHeads: 2,
    numLayers: 2
});
```

---

## B.8 Error Handling Reference

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `d_model must be divisible by numHeads` | Invalid configuration | Ensure `d_model % numHeads === 0` |
| `Sequence length exceeds max length` | Input too long | Truncate input or increase `maxLen` |
| `Unknown token in generation` | Invalid token ID | Ensure vocabulary includes all tokens |
| `Model not initialized` | Using before loading | Call `loadFromFile()` or create model |
| `KV cache mismatch` | Wrong cache dimensions | Ensure KV cache matches model configuration |

### Defensive Generation

```javascript
function safeGenerate(generator, prompt, config = {}) {
    try {
        // Validate inputs
        if (!prompt || typeof prompt !== 'string') {
            throw new Error('Invalid prompt');
        }
        
        // Set safe defaults
        const safeConfig = {
            maxTokens: Math.min(config.maxTokens || 100, 200),
            temperature: Math.max(0.1, Math.min(config.temperature || 0.8, 2.0)),
            ...config
        };
        
        return generator.generate(prompt, safeConfig);
    } catch (error) {
        console.error('Generation failed:', error.message);
        return {
            error: error.message,
            generated: '',
            tokens: []
        };
    }
}

// Usage
const result = safeGenerate(generator, "Hello world", {
    maxTokens: 50,
    temperature: 1.5
});

if (result.error) {
    console.error('Failed:', result.error);
} else {
    console.log(result.generated);
}
```

---

## B.9 Advanced Configuration

### Custom Attention Mask

```javascript
// Causal mask for autoregressive generation
function createCausalMask(seqLen) {
    const mask = [];
    for (let i = 0; i < seqLen; i++) {
        const row = [];
        for (let j = 0; j < seqLen; j++) {
            row.push(j <= i); // Can attend to self and previous tokens
        }
        mask.push(row);
    }
    return mask;
}

// Apply mask
const mask = createCausalMask(10);
const { output } = block.forward(X, mask);
```

### Custom Initialization

```javascript
// Xavier initialization for weights
function xavierInit(rows, cols) {
    const scale = Math.sqrt(2.0 / (rows + cols));
    return Array.from({ length: rows }, () =>
        Array.from({ length: cols }, () => 
            (Math.random() - 0.5) * 2 * scale
        )
    );
}

// Use in transformer
const transformer = new Transformer({
    // ... config
});
transformer.tokenEmbeddings = xavierInit(vocabSize, d_model);
```

---

## B.10 API Quick Reference Card

```javascript
// QUICK REFERENCE - TRANSFORMER API

// Attention
const { output, attentionWeights } = scaledDotProductAttention(Q, K, V);
const mha = new MultiHeadAttention({ d_model: 64, numHeads: 4 });
const { output } = mha.forward(X);

// Positional Encodings
const posEnc = generatePositionalEncodings(10, 64);
const combined = addPositionalEncodings(embeddings, posEnc);

// Transformer Block
const block = new TransformerBlock({ d_model: 64, numHeads: 4 });
const { output } = block.forward(X);

// Complete Transformer
const transformer = new Transformer({
    vocabSize: 1000,
    d_model: 64,
    numHeads: 4,
    numLayers: 3
});

// Forward pass
const { logits } = transformer.forward(tokenIds);

// Generate
const outputIds = transformer.generate(inputIds, {
    maxTokens: 100,
    temperature: 0.8,
    topK: 40,
    topP: 0.9
});

// Text Generator
const generator = new TextGenerator({
    pipeline: pipeline,
    transformer: transformer
});

// Generate
const result = generator.generate("Prompt", { maxTokens: 50 });

// Stream
await generator.generateStreaming("Prompt", callback);

// Save/Load
transformer.saveToFile('./model.json');
transformer.loadFromFile('./model.json');

// Utilities
const mask = createCausalMask(10);
const normalized = layerNorm.forward(X);
const ffOutput = feedForward.forward(X);
```

---

**[END OF APPENDIX B]**
