# Appendix D: Complete API Reference — Production Deployment

This appendix provides comprehensive API documentation for the production deployment system built throughout the series. Use this as a quick reference when serving models, optimizing inference, and building production-ready AI applications.

---

## D.1 Production Server API

### Overview
The production server provides a complete Express.js-based serving layer for your distilled models with production features like caching, rate limiting, and monitoring.

```javascript
import { ProductionServer } from './src/inference/serve.js';
```

### Constructor

```javascript
new ProductionServer(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.port` | `number` | 3000 | Server port |
| `config.modelDir` | `string` | './models/distillation_demo' | Directory containing model files |
| `config.maxTokens` | `number` | 100 | Default max tokens |
| `config.temperature` | `number` | 0.8 | Default temperature |
| `config.topK` | `number` | 40 | Default top-K |
| `config.topP` | `number` | 0.9 | Default top-P |
| `config.repetitionPenalty` | `number` | 1.1 | Default repetition penalty |
| `config.maxConcurrentRequests` | `number` | 10 | Max concurrent requests |

**Methods:**

#### `initialize()`

Loads models and initializes the server.

```javascript
await server.initialize();
```

**Returns:** `Promise<void>`

**Example:**
```javascript
const server = new ProductionServer({
    port: 3000,
    modelDir: './models/distillation_demo'
});

await server.initialize();
console.log('Server initialized!');
```

#### `start()`

Starts the HTTP server.

```javascript
server.start();
```

**Example:**
```javascript
server.start();
// Server running on http://localhost:3000
```

#### `shutdown()`

Gracefully shuts down the server.

```javascript
await server.shutdown();
```

**Example:**
```javascript
process.on('SIGTERM', async () => {
    await server.shutdown();
});
```

### API Endpoints

#### `GET /health`

Health check endpoint.

**Response:**
```javascript
{
    status: "healthy" | "unhealthy",
    timestamp: "2024-01-01T00:00:00.000Z",
    uptime: 123.45,
    memory: {
        rss: 123456789,
        heapTotal: 98765432,
        heapUsed: 76543210
    },
    activeRequests: 5,
    modelStats: {
        parameters: 5000,
        layers: 2,
        heads: 4
    }
}
```

**Example:**
```bash
curl http://localhost:3000/health
```

#### `POST /api/generate`

Generate text from a prompt.

**Request Body:**
```javascript
{
    prompt: string,           // Required
    maxTokens?: number,       // Default: 100
    temperature?: number,     // Default: 0.8
    topK?: number,           // Default: 40
    topP?: number,           // Default: 0.9
    repetitionPenalty?: number // Default: 1.1
}
```

**Response:**
```javascript
{
    success: true,
    prompt: "The quick brown fox",
    generated: " jumps over the lazy dog.",
    tokens: [" jumps", " over", " the", " lazy", " dog."],
    tokenCount: 5,
    elapsedTime: 0.123,
    tokensPerSecond: 40.65,
    cacheHit: false
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "The quick brown fox", "maxTokens": 50, "temperature": 0.7}'
```

#### `POST /api/generate/stream`

Stream generation using Server-Sent Events.

**Request Body:** Same as `/api/generate`

**Response:** Server-Sent Events stream

**Example:**
```javascript
const eventSource = new EventSource('/api/generate/stream');
eventSource.onmessage = (event) => {
    const data = JSON.parse(event.data);
    if (data.done) {
        console.log('Generation complete!');
        eventSource.close();
    } else {
        console.log(data.token);
    }
};
```

```bash
curl -X POST http://localhost:3000/api/generate/stream \
  -H "Content-Type: application/json" \
  -d '{"prompt": "The quick brown fox", "temperature": 0.9}'
```

#### `GET /api/models`

List available models.

**Response:**
```javascript
{
    models: [
        {
            id: "student",
            name: "Distilled Student Model",
            parameters: 5000,
            layers: 2,
            heads: 4,
            vocabSize: 1000,
            loaded: true
        }
    ],
    activeModel: "student"
}
```

**Example:**
```bash
curl http://localhost:3000/api/models
```

#### `GET /api/stats`

Get server and model statistics.

**Response:**
```javascript
{
    server: {
        uptime: 123.45,
        activeRequests: 5,
        maxConcurrentRequests: 10,
        memoryUsage: {
            rss: 123456789,
            heapTotal: 98765432,
            heapUsed: 76543210
        }
    },
    model: {
        parameters: 5000,
        layers: 2,
        heads: 4,
        vocabSize: 1000
    },
    cache: {
        size: 42,
        maxSize: 1000,
        hits: 156,
        misses: 89,
        hitRate: 0.637
    }
}
```

**Example:**
```bash
curl http://localhost:3000/api/stats
```

---

## D.2 KV Cache API

### Overview
The KV cache stores key and value matrices from previous tokens to avoid recomputation, dramatically speeding up autoregressive generation.

```javascript
import { KVCache, KVCacheEntry } from './src/inference/kv-cache.js';
```

### Class: `KVCache`

```javascript
new KVCache(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.maxSize` | `number` | 1000 | Maximum number of cached sequences |
| `config.ttl` | `number` | 3600 | Time-to-live in seconds |
| `config.maxSequenceLength` | `number` | 2048 | Maximum sequence length |

**Methods:**

#### `getKey(prompt, params)`

Generates a cache key from prompt and parameters.

```javascript
const key = cache.getKey("Hello world", { temperature: 0.8 });
// Returns: "Hello world|0.8|40|0.9"
```

**Parameters:**
- `prompt` (string): Input prompt
- `params` (Object): Generation parameters

**Returns:** `string` - Cache key

#### `get(key)`

Retrieves cached KV values.

```javascript
const entry = cache.get(key);
if (entry) {
    console.log(`Cache hit! Sequence length: ${entry.sequenceLength}`);
} else {
    console.log('Cache miss');
}
```

**Parameters:**
- `key` (string): Cache key

**Returns:** `Object | null`
```javascript
{
    keys: number[][][],          // Keys per layer [layers, seq_len, d_k]
    values: number[][][],        // Values per layer [layers, seq_len, d_v]
    sequenceLength: number       // Cached sequence length
}
```

#### `set(key, keys, values, sequenceLength)`

Stores KV values in cache.

```javascript
cache.set(key, kvKeys, kvValues, 10);
```

**Parameters:**
- `key` (string): Cache key
- `keys` (number[][][]]): Key matrices per layer
- `values` (number[][][]]): Value matrices per layer
- `sequenceLength` (number): Current sequence length

#### `invalidate(key)`

Invalidates a specific cache entry.

```javascript
const removed = cache.invalidate('some_key');
// Returns: true if removed
```

**Parameters:**
- `key` (string): Cache key to invalidate

**Returns:** `boolean` - Whether entry was removed

#### `clear()`

Clears the entire cache.

```javascript
cache.clear();
```

#### `cleanup()`

Removes expired entries.

```javascript
cache.cleanup();
```

#### `getStats()`

Gets cache statistics.

```javascript
const stats = cache.getStats();
// Returns: { size: 42, maxSize: 1000, hits: 156, misses: 89, hitRate: 0.637, ... }
```

**Returns:** `Object`
```javascript
{
    size: number,
    maxSize: number,
    hits: number,
    misses: number,
    totalRequests: number,
    hitRate: number,
    evictions: number,
    ttl: number
}
```

### Class: `KVCacheEntry`

```javascript
new KVCacheEntry(layerKeys, layerValues, sequenceLength)
```

Represents a single cache entry.

**Constructor Parameters:**
- `layerKeys` (number[][][]]): Keys for each layer
- `layerValues` (number[][][]]): Values for each layer
- `sequenceLength` (number): Current sequence length

**Methods:**

#### `getSize()`

Estimates memory size of the entry.

```javascript
const size = entry.getSize();
```

**Returns:** `number` - Estimated size in elements

#### `merge(newKeys, newValues)`

Merges new keys/values with cached ones.

```javascript
const merged = entry.merge(newKeys, newValues);
// Returns: new KVCacheEntry with combined values
```

**Parameters:**
- `newKeys` (number[][][]]): New keys to append
- `newValues` (number[][][]]): New values to append

**Returns:** `KVCacheEntry` - New merged entry

---

## D.3 Model Service API

### Overview
The model service orchestrates model loading, inference, and generation with performance optimizations.

```javascript
import { ModelService } from './src/inference/model-service.js';
```

### Constructor

```javascript
new ModelService(config)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.pipeline` | `TextProcessingPipeline` | Required | Tokenization pipeline |
| `config.model` | `StudentModel` | Required | Student model for inference |
| `config.kvCache` | `KVCache` | `new KVCache()` | KV cache instance |
| `config.generationDefaults` | `Object` | `{maxTokens:100, temperature:0.8, topK:40, topP:0.9, repetitionPenalty:1.1}` | Default generation parameters |

**Methods:**

#### `generate(prompt, params)`

Generates text with caching.

```javascript
const result = await service.generate("The quick brown fox", {
    maxTokens: 50,
    temperature: 0.8
});
```

**Parameters:**
- `prompt` (string): Input prompt
- `params` (Object): Generation parameters (optional)

**Returns:** `Promise<Object>`
```javascript
{
    prompt: string,
    generated: string,
    tokens: string[],
    tokenCount: number,
    elapsedTime: number,
    tokensPerSecond: number,
    cacheHit: boolean
}
```

**Example:**
```javascript
const service = new ModelService({
    pipeline: pipeline,
    model: student,
    kvCache: cache
});

const result = await service.generate("The meaning of life is");
console.log(`Generated: ${result.generated}`);
console.log(`Speed: ${result.tokensPerSecond.toFixed(2)} tokens/sec`);
console.log(`Cache hit: ${result.cacheHit}`);
```

#### `generateStream(prompt, params, callback)`

Generates text with streaming.

```javascript
await service.generateStream(
    "The quick brown fox",
    { maxTokens: 50 },
    (data) => {
        if (data.isComplete) {
            console.log('Complete!');
        } else {
            process.stdout.write(data.token);
        }
    }
);
```

**Parameters:**
- `prompt` (string): Input prompt
- `params` (Object): Generation parameters (optional)
- `callback` (Function): Called for each token

**Callback Data:**
```javascript
{
    token: string,          // Current token text
    tokenId: number,        // Current token ID
    step: number,           // Generation step
    fullText: string,       // Complete generated text so far
    isComplete: boolean     // Whether generation is done
}
```

#### `getStats()`

Gets service statistics.

```javascript
const stats = service.getStats();
// Returns: { model: {...}, cache: {...}, generations: {...}, cachePerformance: {...} }
```

**Returns:** `Object`
```javascript
{
    model: Object,           // Model statistics
    cache: Object,           // Cache statistics
    generations: {
        total: number,
        totalTokens: number,
        avgTokensPerSecond: number,
        totalTime: number
    },
    cachePerformance: {
        hits: number,
        misses: number,
        hitRate: number
    }
}
```

---

## D.4 Middleware API

### Overview
Middleware functions for logging, performance monitoring, error handling, and security.

```javascript
import {
    logger,
    performanceMiddleware,
    errorHandler,
    validateRequest,
    RateLimiter,
    securityHeaders
} from './src/inference/middleware.js';
```

### Function: `logger`

Request logger middleware.

```javascript
app.use(logger);
// Logs: [2024-01-01T00:00:00.000Z] GET /api/generate - 200 - 123.45ms
```

### Function: `performanceMiddleware`

Performance monitoring middleware.

```javascript
app.use(performanceMiddleware);
// Adds X-Response-Time header
```

### Function: `errorHandler`

Error handler middleware.

```javascript
app.use(errorHandler);
// Returns: { error: { message: "...", status: 500, timestamp: "...", path: "..." } }
```

### Function: `validateRequest`

Request validation middleware.

```javascript
const schema = {
    prompt: { required: true, type: 'string' },
    maxTokens: { type: 'number', min: 1, max: 2048 },
    temperature: { type: 'number', min: 0, max: 2 }
};

app.post('/api/generate', validateRequest(schema), handler);
```

**Parameters:**
- `schema` (Object): Validation schema

**Schema Rules:**
- `required` (boolean): Field is required
- `type` (string): 'string', 'number', 'boolean'
- `min` (number): Minimum value (for numbers)
- `max` (number): Maximum value (for numbers)

### Class: `RateLimiter`

```javascript
new RateLimiter(config)
```

Rate limiting middleware.

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config.maxRequests` | `number` | 100 | Maximum requests per window |
| `config.windowMs` | `number` | 60000 | Time window in milliseconds |

**Methods:**

#### `isAllowed(clientId)`

Checks if request is allowed.

```javascript
const allowed = limiter.isAllowed('client-123');
// Returns: boolean
```

**Parameters:**
- `clientId` (string): Client identifier (e.g., IP)

**Returns:** `boolean` - Whether request is allowed

#### `getInfo(clientId)`

Gets rate limit info for client.

```javascript
const info = limiter.getInfo('client-123');
// Returns: { remaining: 95, resetTime: 1704067200000 }
```

**Returns:** `Object`
```javascript
{
    remaining: number,
    resetTime: number
}
```

#### `cleanup()`

Removes expired clients.

```javascript
limiter.cleanup();
```

### Function: `securityHeaders`

Security headers middleware.

```javascript
app.use(securityHeaders);
// Sets: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, etc.
```

---

## D.5 Generation Parameters API

### Overview
Configuration objects for controlling text generation.

```javascript
import { GenerationParams } from './src/inference/generation-params.js';
```

### Class: `GenerationParams`

```javascript
new GenerationParams(params)
```

**Constructor Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `params.maxTokens` | `number` | 100 | Maximum tokens to generate |
| `params.temperature` | `number` | 0.8 | Sampling temperature (0-2) |
| `params.topK` | `number` | 40 | Top-K sampling parameter |
| `params.topP` | `number` | 0.9 | Top-P (nucleus) sampling |
| `params.repetitionPenalty` | `number` | 1.1 | Penalty for repeated tokens |
| `params.stopTokens` | `string[]` | `['<\|endoftext\|>', '<\|eos\|>']` | Tokens that stop generation |
| `params.seed` | `number` | null | Random seed for reproducibility |

**Methods:**

#### `describe()`

Gets a description of the parameters.

```javascript
const params = new GenerationParams({ maxTokens: 50, temperature: 0.3 });
console.log(params.describe());
// "Short generation, Deterministic (low temperature), Focused sampling"
```

**Returns:** `string` - Human-readable description

#### `toJSON()`

Converts to JSON.

```javascript
const json = params.toJSON();
// Returns: { maxTokens: 50, temperature: 0.3, topK: 40, ... }
```

**Returns:** `Object` - JSON representation

#### `fromJSON(json)`

Creates from JSON (static method).

```javascript
const params = GenerationParams.fromJSON('{"maxTokens": 50, "temperature": 0.3}');
```

**Parameters:**
- `json` (string|Object): JSON string or object

**Returns:** `GenerationParams` - New instance

### Static Method: `getPresets()`

Gets preset configurations.

```javascript
const presets = GenerationParams.getPresets();
// Returns: { creative, balanced, deterministic, factual, story }
```

**Available Presets:**

| Preset | maxTokens | temperature | topK | topP | repetitionPenalty |
|--------|-----------|-------------|------|------|-------------------|
| `creative` | 150 | 1.2 | 60 | 0.95 | 1.1 |
| `balanced` | 100 | 0.8 | 40 | 0.9 | 1.1 |
| `deterministic` | 100 | 0.1 | 1 | 1.0 | 1.0 |
| `factual` | 80 | 0.3 | 10 | 0.8 | 1.2 |
| `story` | 200 | 0.9 | 50 | 0.92 | 1.05 |

**Example:**
```javascript
const params = GenerationParams.getPresets().creative;
console.log(params.describe());
// "Long generation, Creative (high temperature), Diverse sampling, Liberal nucleus sampling"
```

---

## D.6 Common Usage Patterns

### Complete Server Setup

```javascript
import { ProductionServer } from './src/inference/serve.js';
import dotenv from 'dotenv';

dotenv.config();

const server = new ProductionServer({
    port: process.env.PORT || 3000,
    modelDir: process.env.MODEL_DIR || './models/distillation_demo',
    maxTokens: parseInt(process.env.MAX_TOKENS) || 100,
    temperature: parseFloat(process.env.TEMPERATURE) || 0.8,
    topK: parseInt(process.env.TOP_K) || 40,
    topP: parseFloat(process.env.TOP_P) || 0.9,
    maxConcurrentRequests: parseInt(process.env.MAX_CONCURRENT) || 10
});

// Initialize and start
(async () => {
    try {
        await server.initialize();
        server.start();
        console.log('🚀 Server is running!');
    } catch (error) {
        console.error('Failed to start server:', error);
        process.exit(1);
    }
})();

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('Received SIGTERM, shutting down...');
    await server.shutdown();
    process.exit(0);
});
```

### Custom Cache Configuration

```javascript
import { KVCache } from './src/inference/kv-cache.js';
import { ModelService } from './src/inference/model-service.js';

// Large cache for production
const cache = new KVCache({
    maxSize: 10000,      // 10x larger
    ttl: 86400,          // 24 hours
    maxSequenceLength: 4096
});

// Small cache for development
const devCache = new KVCache({
    maxSize: 100,
    ttl: 60,             // 1 minute
    maxSequenceLength: 256
});

// Use in service
const service = new ModelService({
    pipeline: pipeline,
    model: student,
    kvCache: cache
});
```

### Custom Rate Limiting

```javascript
import { RateLimiter } from './src/inference/middleware.js';

// Per-user rate limiting middleware
const userLimiter = new RateLimiter({
    maxRequests: 60,
    windowMs: 60000     // 60 requests per minute
});

app.use('/api/generate', (req, res, next) => {
    const clientId = req.headers['x-api-key'] || req.ip;
    
    if (!userLimiter.isAllowed(clientId)) {
        return res.status(429).json({
            error: 'Rate limit exceeded',
            retryAfter: Math.ceil(userLimiter.getInfo(clientId).resetTime / 1000)
        });
    }
    
    next();
});
```

### Monitoring and Metrics

```javascript
import { performance } from 'perf_hooks';

class MetricsCollector {
    constructor() {
        this.metrics = {
            requests: 0,
            tokens: 0,
            errors: 0,
            avgLatency: 0,
            p95Latency: 0
        };
        this.latencies = [];
    }

    recordRequest(duration, tokens, error = false) {
        this.metrics.requests++;
        this.metrics.tokens += tokens;
        if (error) this.metrics.errors++;
        
        this.latencies.push(duration);
        if (this.latencies.length > 1000) {
            this.latencies.shift();
        }
        
        // Update averages
        this.metrics.avgLatency = this.latencies.reduce((a, b) => a + b, 0) / this.latencies.length;
        
        // Calculate p95
        const sorted = [...this.latencies].sort((a, b) => a - b);
        const idx = Math.floor(sorted.length * 0.95);
        this.metrics.p95Latency = sorted[idx] || 0;
    }

    getStats() {
        return {
            ...this.metrics,
            activeRequests: this.metrics.requests - this.metrics.errors
        };
    }
}

// Usage
const metrics = new MetricsCollector();

app.use((req, res, next) => {
    const start = performance.now();
    const originalEnd = res.end;
    
    res.end = function(...args) {
        const duration = performance.now() - start;
        const tokenCount = res.locals.tokenCount || 0;
        metrics.recordRequest(duration, tokenCount, res.statusCode >= 400);
        originalEnd.apply(this, args);
    };
    
    next();
});
```

### Health Check with Dependencies

```javascript
// Enhanced health check
app.get('/health', async (req, res) => {
    const checks = {
        server: server.isReady ? 'up' : 'down',
        model: server.modelService ? 'loaded' : 'unloaded',
        cache: server.modelService?.kvCache ? 'available' : 'unavailable'
    };
    
    const overall = Object.values(checks).every(v => 
        v === 'up' || v === 'loaded' || v === 'available'
    );
    
    res.status(overall ? 200 : 503).json({
        status: overall ? 'healthy' : 'unhealthy',
        timestamp: new Date().toISOString(),
        checks: checks,
        uptime: process.uptime()
    });
});
```

---

## D.7 Performance Optimization

### KV Cache Tuning

```javascript
// Adjust cache size based on memory
function getOptimalCacheSize(memoryLimitMB = 1024) {
    // Estimate memory per entry (roughly)
    const bytesPerEntry = 1024 * 1024; // 1MB per entry
    const maxEntries = Math.floor((memoryLimitMB * 1024 * 1024) / bytesPerEntry);
    return Math.min(maxEntries, 10000);
}

const cache = new KVCache({
    maxSize: getOptimalCacheSize(2048), // 2GB limit
    ttl: 3600
});
```

### Batch Processing

```javascript
// Process multiple prompts efficiently
async function batchGenerate(service, prompts, params) {
    const results = [];
    const batchSize = 4; // Adjust based on memory
    
    for (let i = 0; i < prompts.length; i += batchSize) {
        const batch = prompts.slice(i, i + batchSize);
        const batchResults = await Promise.all(
            batch.map(prompt => service.generate(prompt, params))
        );
        results.push(...batchResults);
    }
    
    return results;
}

// Usage
const prompts = [
    "Tell me a story about",
    "Explain quantum physics",
    "Write a poem about"
];

const results = await batchGenerate(service, prompts, {
    maxTokens: 50,
    temperature: 0.8
});
```

### Memory Monitoring

```javascript
function monitorMemory() {
    const usage = process.memoryUsage();
    const MB = 1024 * 1024;
    
    return {
        rss: usage.rss / MB,
        heapTotal: usage.heapTotal / MB,
        heapUsed: usage.heapUsed / MB,
        external: usage.external / MB
    };
}

// Log memory periodically
setInterval(() => {
    const mem = monitorMemory();
    console.log(`Memory: ${mem.heapUsed.toFixed(2)}MB used, ${mem.heapTotal.toFixed(2)}MB total`);
    
    if (mem.heapUsed > mem.heapTotal * 0.8) {
        console.warn('⚠️ High memory usage, consider clearing cache');
        service.kvCache?.cleanup();
    }
}, 30000);
```

---

## D.8 Error Handling Reference

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Server not initialized` | `start()` called before `initialize()` | Call `initialize()` first |
| `Model not loaded` | Missing model files | Ensure model directory exists |
| `Rate limit exceeded` | Too many requests | Increase limit or use backoff |
| `Invalid prompt` | Empty or invalid prompt | Validate prompt before sending |
| `Memory exhausted` | Too many concurrent requests | Reduce concurrent limit or cache size |
| `KV cache full` | Cache size exceeded | Increase maxSize or use LRU |

### Defensive API Handler

```javascript
app.post('/api/generate', async (req, res) => {
    try {
        // 1. Validate input
        const { prompt, ...params } = req.body;
        if (!prompt || typeof prompt !== 'string' || prompt.trim().length === 0) {
            return res.status(400).json({
                error: 'Invalid prompt: must be a non-empty string'
            });
        }
        
        // 2. Sanitize params
        const safeParams = {
            maxTokens: Math.min(params.maxTokens || 100, 500),
            temperature: Math.max(0.1, Math.min(params.temperature || 0.8, 2.0)),
            topK: Math.min(params.topK || 40, 100),
            topP: Math.max(0.1, Math.min(params.topP || 0.9, 1.0)),
            repetitionPenalty: Math.max(1.0, Math.min(params.repetitionPenalty || 1.1, 2.0))
        };
        
        // 3. Check server readiness
        if (!server.isReady) {
            return res.status(503).json({
                error: 'Server is not ready'
            });
        }
        
        // 4. Generate
        const result = await service.generate(prompt, safeParams);
        
        // 5. Store token count for metrics
        res.locals.tokenCount = result.tokenCount;
        
        // 6. Return response
        res.json({
            success: true,
            ...result
        });
        
    } catch (error) {
        console.error('Generation error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Internal server error'
        });
    }
});
```

---

## D.9 API Quick Reference Card

```javascript
// QUICK REFERENCE - PRODUCTION API

// Server
const server = new ProductionServer({ port: 3000, modelDir: './models' });
await server.initialize();
server.start();

// Endpoints
GET  /health
POST /api/generate
POST /api/generate/stream
GET  /api/models
GET  /api/stats

// KV Cache
const cache = new KVCache({ maxSize: 1000, ttl: 3600 });
cache.set(key, keys, values, seqLen);
const entry = cache.get(key);
cache.cleanup();

// Model Service
const service = new ModelService({ pipeline, model, kvCache: cache });
const result = await service.generate(prompt, params);
await service.generateStream(prompt, params, callback);

// Middleware
app.use(logger);
app.use(performanceMiddleware);
app.use(errorHandler);
app.use(validateRequest(schema));
app.use(securityHeaders);

// Rate Limiter
const limiter = new RateLimiter({ maxRequests: 100, windowMs: 60000 });
const allowed = limiter.isAllowed(clientId);

// Generation Params
const params = new GenerationParams({ maxTokens: 50, temperature: 0.8 });
const presets = GenerationParams.getPresets();
const description = params.describe();

// Utilities
const memory = process.memoryUsage();
const stats = service.getStats();
cache.cleanup();
await server.shutdown();
```

---

**[END OF APPENDIX D]**
