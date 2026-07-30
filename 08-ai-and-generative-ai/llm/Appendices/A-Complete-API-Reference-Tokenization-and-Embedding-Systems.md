# Appendix A: Complete API Reference — Tokenization and Embedding Systems

This appendix provides comprehensive API documentation for the tokenization and embedding systems built throughout this series. Use this as a quick reference when working with your LLM system.

---

## A.1 BPETokenizer Class

### Overview
The `BPETokenizer` implements Byte-Pair Encoding (BPE) tokenization, the foundation of modern LLMs. It learns subword units from a training corpus and can encode/decode text efficiently.

```javascript
import { BPETokenizer } from './src/tokenizer/bpe-tokenizer.js';
```

### Constructor
```javascript
new BPETokenizer(config)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.vocabSize` | `number` | 1000 | Target vocabulary size |
| `config.specialTokens` | `string[]` | `['<\|endoftext\|>', '<\|pad\|>']` | Special tokens for control |

### Methods

#### `train(corpus)`
Trains the tokenizer on a text corpus.

```javascript
const tokenizer = new BPETokenizer({ vocabSize: 2000 });
tokenizer.train("The quick brown fox jumps over the lazy dog.");
```

**Parameters:**
- `corpus` (string): Training text

**Returns:** `BPETokenizer` (for chaining)

#### `encode(text)`
Converts text to token IDs.

```javascript
const ids = tokenizer.encode("Hello world");
// Returns: [42, 156, 203, ...]
```

**Parameters:**
- `text` (string): Text to encode

**Returns:** `number[]` - Array of token IDs

**Throws:** Error if tokenizer not trained

#### `decode(tokenIds)`
Converts token IDs back to text.

```javascript
const text = tokenizer.decode([42, 156, 203]);
// Returns: "Hello world"
```

**Parameters:**
- `tokenIds` (number[]): Array of token IDs

**Returns:** `string` - Decoded text

**Throws:** Error if tokenizer not trained

#### `exportConfig()`
Exports tokenizer configuration for persistence.

```javascript
const config = tokenizer.exportConfig();
// Save config to disk
fs.writeFileSync('tokenizer.json', JSON.stringify(config));
```

**Returns:** `Object` - Configuration object

#### `importConfig(config)`
Imports previously exported configuration.

```javascript
const config = JSON.parse(fs.readFileSync('tokenizer.json'));
tokenizer.importConfig(config);
```

**Parameters:**
- `config` (Object): Configuration from `exportConfig()`

#### `saveToFile(filepath)`
Saves tokenizer to disk.

```javascript
tokenizer.saveToFile('./models/tokenizer.json');
```

**Parameters:**
- `filepath` (string): Path to save file

#### `loadFromFile(filepath)`
Loads tokenizer from disk.

```javascript
tokenizer.loadFromFile('./models/tokenizer.json');
```

**Parameters:**
- `filepath` (string): Path to load file

**Returns:** `BPETokenizer` (for chaining)

### Properties

```javascript
tokenizer.vocabulary          // Map: token -> id
tokenizer.inverseVocabulary   // Map: id -> token
tokenizer.mergeRules          // Array: [(left, right), merged]
tokenizer.specialTokens       // Array: special token strings
tokenizer.vocabSize           // Number: current vocabulary size
tokenizer.stats               // Object: training statistics
```

### Example Usage

```javascript
// Full example
const tokenizer = new BPETokenizer({
    vocabSize: 1000,
    specialTokens: ['<|endoftext|>', '<|pad|>', '<|unk|>']
});

// Train
const corpus = "The quick brown fox jumps over the lazy dog.";
tokenizer.train(corpus);

// Encode
const text = "Hello world!";
const ids = tokenizer.encode(text);

// Decode
const decoded = tokenizer.decode(ids);

// Save and load
tokenizer.saveToFile('./tokenizer.json');
const newTokenizer = new BPETokenizer();
newTokenizer.loadFromFile('./tokenizer.json');
```

---

## A.2 Vocabulary Class

### Overview
Manages token-vocabulary mappings with special token support, frequency tracking, and pruning capabilities.

```javascript
import { Vocabulary } from './src/tokenizer/vocabulary.js';
```

### Constructor
```javascript
new Vocabulary(config)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.maxSize` | `number` | 50000 | Maximum vocabulary size |
| `config.specialTokens` | `string[]` | `['<\|endoftext\|>', '<\|pad\|>', '<\|unk\|>']` | Special tokens |

### Methods

#### `addToken(token)`
Adds a token to the vocabulary.

```javascript
const id = vocab.addToken('hello');
// Returns: number (token ID)
```

**Parameters:**
- `token` (string): Token to add

**Returns:** `number` - Token ID

**Throws:** Error if vocabulary is full

#### `addTokens(tokens)`
Adds multiple tokens at once.

```javascript
const ids = vocab.addTokens(['hello', 'world', '!']);
// Returns: [42, 43, 44]
```

**Parameters:**
- `tokens` (string[]): Array of tokens

**Returns:** `number[]` - Token IDs

#### `getTokenId(token)`
Gets token ID, returns unknown token ID if not found.

```javascript
const id = vocab.getTokenId('hello');
// Returns: 42
```

**Parameters:**
- `token` (string): Token to look up

**Returns:** `number` - Token ID

**Throws:** Error if token not found and no unknown token

#### `getToken(id)`
Gets token from ID.

```javascript
const token = vocab.getToken(42);
// Returns: 'hello'
```

**Parameters:**
- `id` (number): Token ID

**Returns:** `string` - Token

**Throws:** Error if ID not found

#### `updateFrequency(token, count)`
Updates frequency of a token.

```javascript
vocab.updateFrequency('hello', 5);
```

**Parameters:**
- `token` (string): Token to update
- `count` (number): Frequency increment (default: 1)

#### `getMostFrequent(n)`
Gets most frequent tokens.

```javascript
const topTokens = vocab.getMostFrequent(10);
// Returns: [{ token: 'the', frequency: 1000 }, ...]
```

**Parameters:**
- `n` (number): Number of tokens to return (default: 10)

**Returns:** `Array<{token: string, frequency: number}>`

#### `prune(targetSize)`
Prunes least frequent tokens.

```javascript
vocab.prune(1000); // Keep only 1000 most frequent tokens
```

**Parameters:**
- `targetSize` (number): Target vocabulary size

#### `getStats()`
Gets vocabulary statistics.

```javascript
const stats = vocab.getStats();
// Returns: { size: 1000, maxSize: 50000, specialTokens: 5, uniqueTokens: 995 }
```

**Returns:** `Object` - Statistics

#### `export()`
Exports vocabulary for persistence.

```javascript
const data = vocab.export();
fs.writeFileSync('vocab.json', JSON.stringify(data));
```

**Returns:** `Object` - Export data

#### `import(data)`
Imports previously exported vocabulary.

```javascript
const data = JSON.parse(fs.readFileSync('vocab.json'));
vocab.import(data);
```

**Parameters:**
- `data` (Object): Export data from `export()`

### Properties

```javascript
vocab.tokenToId      // Map: token -> id
vocab.idToToken      // Map: id -> token
vocab.frequencies    // Map: token -> frequency
vocab.specialTokens  // Array: special token strings
vocab.maxSize        // Number: maximum size
```

---

## A.3 EmbeddingSystem Class

### Overview
Converts token IDs to dense vector representations with caching for performance.

```javascript
import { EmbeddingSystem } from './src/tokenizer/embeddings.js';
```

### Constructor
```javascript
new EmbeddingSystem(config)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.vocabSize` | `number` | 1000 | Vocabulary size |
| `config.embeddingDim` | `number` | 64 | Embedding dimension |
| `config.cacheSize` | `number` | 1000 | Cache size for embeddings |

### Methods

#### `getEmbedding(tokenId)`
Gets embedding vector for a token ID.

```javascript
const embedding = embeddings.getEmbedding(42);
// Returns: [0.23, -0.45, 0.12, ...]
```

**Parameters:**
- `tokenId` (number): Token ID

**Returns:** `number[]` - Embedding vector

#### `getEmbeddings(tokenIds)`
Gets embeddings for multiple token IDs.

```javascript
const embeddingsArray = embeddings.getEmbeddings([42, 156, 203]);
// Returns: [[0.23, -0.45], [0.12, 0.89], [0.67, -0.33]]
```

**Parameters:**
- `tokenIds` (number[]): Array of token IDs

**Returns:** `number[][]` - Array of embedding vectors

#### `computeSimilarity(tokenId1, tokenId2)`
Computes cosine similarity between two tokens.

```javascript
const similarity = embeddings.computeSimilarity(42, 156);
// Returns: 0.87
```

**Parameters:**
- `tokenId1` (number): First token ID
- `tokenId2` (number): Second token ID

**Returns:** `number` - Similarity score (-1 to 1)

#### `findNearestNeighbors(tokenId, n)`
Finds nearest neighbors in embedding space.

```javascript
const neighbors = embeddings.findNearestNeighbors(42, 5);
// Returns: [{ tokenId: 156, similarity: 0.87 }, ...]
```

**Parameters:**
- `tokenId` (number): Query token ID
- `n` (number): Number of neighbors (default: 5)

**Returns:** `Array<{tokenId: number, similarity: number}>`

#### `updateEmbedding(tokenId, newEmbedding)`
Updates embedding for a specific token.

```javascript
embeddings.updateEmbedding(42, [0.5, -0.3, 0.1, ...]);
```

**Parameters:**
- `tokenId` (number): Token ID to update
- `newEmbedding` (number[]): New embedding vector

#### `getEmbeddingMatrix()`
Gets embedding matrix as typed array.

```javascript
const matrix = embeddings.getEmbeddingMatrix();
// Returns: Float32Array(vocabSize * embeddingDim)
```

**Returns:** `Float32Array` - Flattened embedding matrix

#### `getStats()`
Gets embedding statistics.

```javascript
const stats = embeddings.getStats();
// Returns: { vocabSize: 1000, embeddingDim: 64, minValue: -2.3, maxValue: 2.1, ... }
```

**Returns:** `Object` - Statistics

### Properties

```javascript
embeddings.embeddings  // Array: [vocabSize][embeddingDim]
embeddings.vocabSize   // Number: vocabulary size
embeddings.embeddingDim // Number: embedding dimension
embeddings.cache       // Map: tokenId -> embedding
```

---

## A.4 TextProcessingPipeline Class

### Overview
Complete text processing pipeline connecting tokenization, vocabulary, and embeddings.

```javascript
import { TextProcessingPipeline } from './src/tokenizer/pipeline.js';
```

### Constructor
```javascript
new TextProcessingPipeline(config)
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.vocabSize` | `number` | 1000 | Vocabulary size |
| `config.embeddingDim` | `number` | 64 | Embedding dimension |
| `config.specialTokens` | `string[]` | `['<\|endoftext\|>', '<\|pad\|>', '<\|unk\|>']` | Special tokens |

### Methods

#### `train(corpus)`
Trains the entire pipeline on a corpus.

```javascript
const pipeline = new TextProcessingPipeline();
pipeline.train("The quick brown fox jumps over the lazy dog.");
```

**Parameters:**
- `corpus` (string): Training text

**Returns:** `TextProcessingPipeline` (for chaining)

#### `processText(text)`
Processes text through the complete pipeline.

```javascript
const result = pipeline.processText("Hello world");
// Returns: {
//   original: "Hello world",
//   normalized: "Hello world",
//   tokenIds: [42, 156],
//   tokens: ["Hello", "world"],
//   embeddings: [[0.23, -0.45], [0.12, 0.89]]
// }
```

**Parameters:**
- `text` (string): Input text

**Returns:** `Object` - Processing result

**Throws:** Error if pipeline not trained

#### `processBatch(texts)`
Processes multiple texts.

```javascript
const results = pipeline.processBatch(["Hello", "World"]);
```

**Parameters:**
- `texts` (string[]): Array of input texts

**Returns:** `Object[]` - Array of processing results

#### `decode(tokenIds)`
Decodes token IDs back to text.

```javascript
const text = pipeline.decode([42, 156]);
// Returns: "Hello world"
```

**Parameters:**
- `tokenIds` (number[]): Array of token IDs

**Returns:** `string` - Decoded text

#### `findSimilar(text, n)`
Finds tokens similar to the first token in text.

```javascript
const similar = pipeline.findSimilar("Hello", 5);
// Returns: [{ token: 'Hi', similarity: 0.87 }, ...]
```

**Parameters:**
- `text` (string): Input text
- `n` (number): Number of similar tokens (default: 5)

**Returns:** `Array<{token: string, similarity: number, tokenId: number}>`

#### `getStats()`
Gets pipeline statistics.

```javascript
const stats = pipeline.getStats();
// Returns: { isTrained: true, vocabSize: 1000, embeddingDim: 64, totalProcessed: 100 }
```

**Returns:** `Object` - Statistics

#### `saveToDirectory(directory)`
Saves entire pipeline to disk.

```javascript
pipeline.saveToDirectory('./models/pipeline/');
```

**Parameters:**
- `directory` (string): Directory to save to

#### `loadFromDirectory(directory)`
Loads pipeline from disk.

```javascript
pipeline.loadFromDirectory('./models/pipeline/');
```

**Parameters:**
- `directory` (string): Directory to load from

**Returns:** `TextProcessingPipeline` (for chaining)

---

## A.5 EmbeddingVisualizer Class

### Overview
Visualizes embedding space with projection and similarity analysis.

```javascript
import { EmbeddingVisualizer } from './src/tokenizer/visualizer.js';
```

### Constructor
```javascript
new EmbeddingVisualizer(embeddingSystem, vocabulary)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `embeddingSystem` | `EmbeddingSystem` | Embedding system to visualize |
| `vocabulary` | `Vocabulary` | Vocabulary for token lookup |

### Methods

#### `projectTo2D()`
Projects embeddings to 2D for visualization.

```javascript
const projection = visualizer.projectTo2D();
// Returns: [{ x: 0.5, y: -0.3 }, ...]
```

**Returns:** `Array<{x: number, y: number}>`

#### `findNearest(token, n)`
Finds nearest tokens.

```javascript
const neighbors = visualizer.findNearest('hello', 5);
// Returns: [{ token: 'hi', similarity: 0.87 }, ...]
```

**Parameters:**
- `token` (string|number): Token or token ID
- `n` (number): Number of neighbors (default: 5)

**Returns:** `Array<{token: string, similarity: number, tokenId: number}>`

#### `compareTokens(token1, token2)`
Compares two tokens semantically.

```javascript
const result = visualizer.compareTokens('cat', 'dog');
// Returns: { token1: 'cat', token2: 'dog', similarity: 0.82, distance: 0.18 }
```

**Parameters:**
- `token1` (string|number): First token
- `token2` (string|number): Second token

**Returns:** `Object` - Comparison result

#### `analogy(tokenA, tokenB, tokenC)`
Performs analogy task: "B - A + C = ?"

```javascript
const result = visualizer.analogy('king', 'man', 'woman');
// Returns: { analogy: 'man - king + woman = ?', result: 'queen', similarity: 0.85 }
```

**Parameters:**
- `tokenA` (string|number): First token
- `tokenB` (string|number): Second token
- `tokenC` (string|number): Third token

**Returns:** `Object` - Analogy result

#### `generateAsciiPlot(width, height)`
Generates ASCII plot of embedding space.

```javascript
const plot = visualizer.generateAsciiPlot(60, 20);
console.log(plot);
```

**Parameters:**
- `width` (number): Plot width (default: 60)
- `height` (number): Plot height (default: 20)

**Returns:** `string` - ASCII plot

#### `exportForPlotting()`
Exports data for external plotting libraries.

```javascript
const data = visualizer.exportForPlotting();
// Returns: { points: [{ x, y, token, id }], metadata: { ... } }
```

**Returns:** `Object` - Plotting data

---

## A.6 Token Utility Functions

### Overview
Helper functions for token manipulation and preprocessing.

```javascript
import { 
    normalizeText,
    splitIntoSentences,
    splitIntoWords,
    countTokenFrequencies,
    findCommonSubwords,
    truncateTokens,
    padTokens,
    tokensToString
} from './src/tokenizer/token-utils.js';
```

### Function Reference

#### `normalizeText(text)`
Normalizes text by removing extra whitespace and control characters.

```javascript
const normalized = normalizeText("  Hello   world!  ");
// Returns: "Hello world!"
```

**Parameters:**
- `text` (string): Input text

**Returns:** `string` - Normalized text

#### `splitIntoSentences(text)`
Splits text into sentences (simple implementation).

```javascript
const sentences = splitIntoSentences("Hello world. How are you?");
// Returns: ["Hello world", "How are you"]
```

**Parameters:**
- `text` (string): Input text

**Returns:** `string[]` - Array of sentences

#### `splitIntoWords(text)`
Splits text into words.

```javascript
const words = splitIntoWords("Hello, world!");
// Returns: ["Hello", "world"]
```

**Parameters:**
- `text` (string): Input text

**Returns:** `string[]` - Array of words

#### `countTokenFrequencies(tokens)`
Counts token frequencies.

```javascript
const freqs = countTokenFrequencies(['hello', 'world', 'hello']);
// Returns: Map { 'hello' => 2, 'world' => 1 }
```

**Parameters:**
- `tokens` (string[]): Array of tokens

**Returns:** `Map<string, number>` - Frequency map

#### `findCommonSubwords(corpus, minOccurrences)`
Finds common subword patterns.

```javascript
const subwords = findCommonSubwords("the quick brown fox", 2);
// Returns: [{ subword: 'the', count: 1 }, ...]
```

**Parameters:**
- `corpus` (string): Input corpus
- `minOccurrences` (number): Minimum occurrences (default: 2)

**Returns:** `Array<{subword: string, count: number}>`

#### `truncateTokens(tokens, maxLength)`
Truncates token sequence with context preservation.

```javascript
const truncated = truncateTokens([1,2,3,4,5], 3);
// Returns: [1,2, '|truncated|', 5]
```

**Parameters:**
- `tokens` (any[]): Array of tokens
- `maxLength` (number): Maximum length

**Returns:** `any[]` - Truncated tokens

#### `padTokens(tokens, targetLength, padToken)`
Pads token sequence to fixed length.

```javascript
const padded = padTokens([1,2], 5, 0);
// Returns: [1,2,0,0,0]
```

**Parameters:**
- `tokens` (any[]): Array of tokens
- `targetLength` (number): Target length
- `padToken` (any): Padding token (default: '<|pad|>')

**Returns:** `any[]` - Padded tokens

---

## A.7 Common Usage Patterns

### Complete Training Pipeline

```javascript
import { TextProcessingPipeline } from './src/tokenizer/pipeline.js';
import { EmbeddingVisualizer } from './src/tokenizer/visualizer.js';

// 1. Create pipeline
const pipeline = new TextProcessingPipeline({
    vocabSize: 2000,
    embeddingDim: 128
});

// 2. Train
pipeline.train("Your training corpus here...");

// 3. Process text
const result = pipeline.processText("Hello world");
console.log(result.tokenIds);
console.log(result.embeddings);

// 4. Explore embeddings
const visualizer = new EmbeddingVisualizer(
    pipeline.embeddings,
    pipeline.vocabulary
);

console.log(visualizer.findNearest('hello'));
console.log(visualizer.generateAsciiPlot());
```

### Save and Load Pipeline

```javascript
// Save
pipeline.saveToDirectory('./models/my_pipeline/');

// Load
const loadedPipeline = new TextProcessingPipeline();
loadedPipeline.loadFromDirectory('./models/my_pipeline/');

// Verify
const result = loadedPipeline.processText("Test text");
console.log(result);
```

### Batch Processing

```javascript
const texts = [
    "First sentence.",
    "Second sentence.",
    "Third sentence."
];

const results = pipeline.processBatch(texts);
for (const result of results) {
    console.log(`Tokens: ${result.tokens.join(' ')}`);
    console.log(`Embeddings shape: ${result.embeddings.length} x ${result.embeddings[0].length}`);
}
```

### Embedding Space Analysis

```javascript
// Find similar words
const similar = pipeline.findSimilar("cat", 10);
console.log("Words similar to 'cat':");
for (const { token, similarity } of similar) {
    console.log(`  ${token}: ${similarity.toFixed(3)}`);
}

// Compare words
const comparison = visualizer.compareTokens("cat", "dog");
console.log(`Cat vs Dog similarity: ${comparison.similarity.toFixed(3)}`);

// Word analogy
const analogy = visualizer.analogy("king", "man", "woman");
console.log(analogy.analogy);
console.log(`Result: ${analogy.result} (similarity: ${analogy.similarity.toFixed(3)})`);
```

### Performance Optimization

```javascript
// Use typed arrays for memory efficiency
const matrix = pipeline.embeddings.getEmbeddingMatrix();
console.log(`Matrix size: ${matrix.length} floats`);

// Cache embeddings for frequently used tokens
const ids = [42, 156, 203];
const embeddings = pipeline.embeddings.getEmbeddings(ids);
console.log(`Cached ${embeddings.length} embeddings`);

// Get statistics
const stats = pipeline.getStats();
console.log(`Average tokens per text: ${stats.averageTokensPerText}`);
```

---

## A.8 Error Handling Reference

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Tokenizer must be trained before encoding` | `encode()` called before `train()` | Call `tokenizer.train(corpus)` first |
| `Token ID out of range` | Invalid token ID | Check vocabulary size and token IDs |
| `Vocabulary is full` | Exceeded maxSize | Increase `maxSize` or prune vocabulary |
| `Unknown token` | Token not in vocabulary | Add token or use unknown token |
| `Embedding dimension mismatch` | Wrong embedding length | Ensure correct `embeddingDim` |
| `Pipeline not trained` | `processText()` before training | Call `pipeline.train()` first |

### Defensive Programming

```javascript
function safeProcessText(pipeline, text) {
    try {
        if (!pipeline.isTrained) {
            throw new Error('Pipeline not trained');
        }
        return pipeline.processText(text);
    } catch (error) {
        console.error('Processing failed:', error.message);
        return null;
    }
}

// Usage
const result = safeProcessText(pipeline, "Hello world");
if (result) {
    console.log('Success:', result.tokenIds);
} else {
    console.log('Failed to process text');
}
```

---

## A.9 Performance Tips

### Memory Optimization
```javascript
// Use smaller embedding dimensions
const pipeline = new TextProcessingPipeline({
    embeddingDim: 32  // Instead of 128
});

// Prune vocabulary
pipeline.vocabulary.prune(1000);

// Clear cache periodically
pipeline.embeddings.cache.clear();
```

### Speed Optimization
```javascript
// Process in batches
const batchSize = 32;
for (let i = 0; i < texts.length; i += batchSize) {
    const batch = texts.slice(i, i + batchSize);
    const results = pipeline.processBatch(batch);
    // Process results
}

// Cache embeddings
const embeddingsCache = new Map();
function getCachedEmbedding(pipeline, token) {
    if (!embeddingsCache.has(token)) {
        const processed = pipeline.processText(token);
        embeddingsCache.set(token, processed.embeddings);
    }
    return embeddingsCache.get(token);
}
```

### Debugging
```javascript
// Enable debug logging
process.env.DEBUG = 'true';

// Log tokenization
const result = pipeline.processText("Hello world");
console.log('Tokens:', result.tokens);
console.log('IDs:', result.tokenIds);
console.log('Embeddings shape:', result.embeddings.length, 'x', result.embeddings[0].length);

// Visualize embeddings
const visualizer = new EmbeddingVisualizer(
    pipeline.embeddings,
    pipeline.vocabulary
);
console.log(visualizer.generateAsciiPlot());
```

---

## A.10 API Quick Reference Card

```javascript
// QUICK REFERENCE - TOKENIZATION API

// Initialize
const tokenizer = new BPETokenizer({ vocabSize: 1000 });
tokenizer.train(corpus);

// Encode/Decode
const ids = tokenizer.encode(text);
const text = tokenizer.decode(ids);

// Vocabulary
const vocab = new Vocabulary({ maxSize: 50000 });
const id = vocab.addToken('hello');
const token = vocab.getToken(42);

// Embeddings
const embeddings = new EmbeddingSystem({ vocabSize: 1000, embeddingDim: 64 });
const emb = embeddings.getEmbedding(42);
const sim = embeddings.computeSimilarity(42, 156);

// Pipeline
const pipeline = new TextProcessingPipeline();
pipeline.train(corpus);
const result = pipeline.processText('Hello world');

// Visualizer
const visualizer = new EmbeddingVisualizer(embeddings, vocab);
const neighbors = visualizer.findNearest('hello');
const plot = visualizer.generateAsciiPlot();

// Save/Load
pipeline.saveToDirectory('./models/');
pipeline.loadFromDirectory('./models/');

// Utils
const normalized = normalizeText('  Hello   world!  ');
const sentences = splitIntoSentences('Hello world. How are you?');
const padded = padTokens([1,2], 5);
```

---

**[END OF APPENDIX A]**
