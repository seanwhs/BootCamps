# Primer 7: Understanding Node.js Streams & Backpressure

## A Deep Dive into Stream Processing

Welcome to the seventh primer! This is a comprehensive deep dive into Node.js streams and backpressure - one of the most powerful but misunderstood features of Node.js. Think of streams like water flowing through pipes in a plumbing system - you need to control the flow rate to prevent flooding (backpressure) while keeping everything moving efficiently.

### 1. The Big Picture

#### What are Streams?

Streams are a fundamental abstraction in Node.js for handling data that is too large to process all at once. They allow you to process data piece by piece, as it becomes available.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NODE.JS STREAMS CONCEPT                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Data Source (Readable)                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • File on disk                                                    │   │
│  │  • HTTP request                                                    │   │
│  │  • Database cursor                                                 │   │
│  │  • Event stream                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    STREAM PIPELINE                                 │   │
│  │                                                                     │   │
│  │  Readable ──▶ Transform ──▶ Transform ──▶ Writable                 │   │
│  │  (Source)    (Process)    (Process)    (Sink)                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Data Sink (Writable)                                                      │
│  └─────────────────────────────────────────────────────────────────────┘   │
│  • File on disk                                                            │
│  • HTTP response                                                           │
│  • Database insert                                                         │
│  • Console output                                                          │
│                                                                             │
│  BACKPRESSURE: When the sink can't keep up, it signals the source          │
│  to slow down. This prevents memory overflow.                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Stream Types

#### Readable Streams

Readable streams are sources of data. They implement the `Readable` interface.

```typescript
import { Readable } from 'stream';

// Creating a readable stream
class NumberStream extends Readable {
    private current = 0;
    private max: number;

    constructor(max: number) {
        super({
            objectMode: true,  // Work with objects, not just buffers
            highWaterMark: 16,  // Buffer size
        });
        this.max = max;
    }

    _read(size: number): void {
        // Push data until we reach the limit or the buffer is full
        while (this.current < this.max && !this.push(this.current)) {
            this.current++;
        }
        
        // Signal end of stream
        if (this.current >= this.max) {
            this.push(null);
        }
    }
}

// Usage
const stream = new NumberStream(100);
stream.on('data', (chunk) => {
    console.log(chunk);
});
stream.on('end', () => {
    console.log('Stream ended');
});
```

#### Writable Streams

Writable streams are destinations for data. They implement the `Writable` interface.

```typescript
import { Writable } from 'stream';

// Creating a writable stream
class ConsoleWriter extends Writable {
    private count = 0;

    constructor() {
        super({
            objectMode: true,
            highWaterMark: 16,
        });
    }

    _write(chunk: any, encoding: string, callback: (error?: Error | null) => void): void {
        this.count++;
        console.log(`[${this.count}]`, chunk);
        callback();
    }

    // Optional: Called when the stream is finished
    _final(callback: (error?: Error | null) => void): void {
        console.log(`Total items written: ${this.count}`);
        callback();
    }
}
```

#### Transform Streams

Transform streams are both readable and writable. They process data as it passes through.

```typescript
import { Transform } from 'stream';

// Creating a transform stream
class UpperCaseTransform extends Transform {
    constructor() {
        super({
            objectMode: true,
        });
    }

    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        // Transform the data
        if (typeof chunk === 'string') {
            const transformed = chunk.toUpperCase();
            callback(null, transformed);
        } else {
            callback(new Error('Expected string input'));
        }
    }

    // Optional: Called before the stream ends
    _flush(callback: (error?: Error | null) => void): void {
        callback();
    }
}

// Usage
const source = new NumberStream(10);
const transform = new UpperCaseTransform();
const sink = new ConsoleWriter();

source.pipe(transform).pipe(sink);
```

#### Duplex Streams

Duplex streams are both readable and writable (like a socket).

```typescript
import { Duplex } from 'stream';

// Creating a duplex stream
class EchoStream extends Duplex {
    private buffer: any[] = [];

    constructor() {
        super({
            objectMode: true,
        });
    }

    _read(size: number): void {
        // Push data from buffer
        while (this.buffer.length > 0 && this.push(this.buffer.shift())) {
            // Continue while we can push
        }
    }

    _write(chunk: any, encoding: string, callback: (error?: Error | null) => void): void {
        // Echo back the data
        this.buffer.push(chunk);
        // If we can push immediately, do it
        if (this.push(chunk)) {
            callback();
        } else {
            // Otherwise wait for drain
            this.once('drain', callback);
        }
    }

    _final(callback: (error?: Error | null) => void): void {
        // Push any remaining data
        while (this.buffer.length > 0 && this.push(this.buffer.shift())) {
            // Continue
        }
        this.push(null);
        callback();
    }
}
```

### 3. Backpressure

Backpressure is the mechanism that slows down the producer when the consumer can't keep up.

#### Understanding Backpressure

```typescript
import { Readable, Writable, pipeline } from 'stream';

// Fast producer
class FastProducer extends Readable {
    private count = 0;

    constructor() {
        super({ objectMode: true });
    }

    _read(size: number): void {
        // Simulate producing data as fast as possible
        for (let i = 0; i < 100; i++) {
            this.count++;
            // push returns false when the buffer is full (backpressure)
            if (!this.push(this.count)) {
                // Stop pushing, wait for drain
                console.log('Backpressure applied!');
                return;
            }
        }
        // Continue after drain
        this.once('drain', () => {
            this._read(size);
        });
    }
}

// Slow consumer
class SlowConsumer extends Writable {
    constructor() {
        super({ objectMode: true, highWaterMark: 1 }); // Small buffer
    }

    _write(chunk: any, encoding: string, callback: (error?: Error | null) => void): void {
        // Simulate slow processing
        setTimeout(() => {
            console.log('Processed:', chunk);
            callback();
        }, 100);
    }
}

// Backpressure in action
const producer = new FastProducer();
const consumer = new SlowConsumer();

pipeline(
    producer,
    consumer,
    (err) => {
        if (err) {
            console.error('Pipeline failed:', err);
        } else {
            console.log('Pipeline completed');
        }
    }
);
```

#### Manual Backpressure Control

```typescript
class BackpressureAwareProcessor {
    private buffer: any[] = [];
    private paused = false;
    private maxBufferSize = 1000;

    // Process data from a readable stream
    async processStream(readable: Readable, processor: (data: any) => Promise<void>): Promise<void> {
        return new Promise((resolve, reject) => {
            readable.on('data', async (chunk) => {
                // Apply backpressure
                if (this.buffer.length > this.maxBufferSize) {
                    this.paused = true;
                    readable.pause();
                    console.log('Paused due to backpressure');
                }

                // Process the chunk
                try {
                    await processor(chunk);
                    this.buffer.push(chunk);
                } catch (error) {
                    readable.destroy(error);
                    reject(error);
                    return;
                }

                // Resume if we've processed enough
                if (this.paused && this.buffer.length < this.maxBufferSize * 0.5) {
                    this.paused = false;
                    readable.resume();
                    console.log('Resumed after backpressure');
                }
            });

            readable.on('error', reject);
            readable.on('end', resolve);
        });
    }
}
```

### 4. Stream Composition

#### Piping Streams

Piping connects streams together, automatically handling backpressure.

```typescript
import { pipeline } from 'stream';
import { promisify } from 'util';

const pipelineAsync = promisify(pipeline);

// Piping with error handling
async function processFile() {
    const readStream = fs.createReadStream('input.txt');
    const writeStream = fs.createWriteStream('output.txt');
    const transform = new UpperCaseTransform();

    try {
        await pipelineAsync(
            readStream,
            transform,
            writeStream
        );
        console.log('Pipeline completed successfully');
    } catch (error) {
        console.error('Pipeline failed:', error);
    }
}
```

#### Multiple Consumers

```typescript
// Tee stream - split data to multiple destinations
class TeeStream extends Transform {
    private destinations: Writable[] = [];

    constructor(destinations: Writable[]) {
        super({ objectMode: true });
        this.destinations = destinations;
    }

    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        // Send to all destinations
        const results = this.destinations.map(dest => 
            dest.write(chunk)  // Returns false if backpressure
        );

        // Check if any destination is applying backpressure
        if (results.some(r => r === false)) {
            // Wait for all destinations to drain
            Promise.all(
                this.destinations.map(dest => 
                    new Promise(resolve => dest.once('drain', resolve))
                )
            ).then(() => callback(null, chunk));
        } else {
            callback(null, chunk);
        }
    }
}

// Usage
const source = new NumberStream(100);
const dest1 = new ConsoleWriter();
const dest2 = new ConsoleWriter();
const tee = new TeeStream([dest1, dest2]);

source.pipe(tee);
```

### 5. Advanced Stream Patterns

#### Throughput Monitoring

```typescript
class ThroughputMonitor extends Transform {
    private bytesRead = 0;
    private startTime = Date.now();
    private interval: NodeJS.Timeout;

    constructor(private reportInterval: number = 1000) {
        super();
        this.interval = setInterval(() => this.report(), reportInterval);
    }

    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        this.bytesRead += chunk.length;
        callback(null, chunk);
    }

    _flush(callback: (error?: Error | null) => void): void {
        clearInterval(this.interval);
        this.report();
        callback();
    }

    private report(): void {
        const duration = (Date.now() - this.startTime) / 1000;
        const mbPerSecond = (this.bytesRead / (1024 * 1024)) / duration;
        console.log(`Throughput: ${mbPerSecond.toFixed(2)} MB/s`);
    }
}
```

#### Stream Combining

```typescript
class StreamCombiner extends Transform {
    private buffers: Map<string, any[]> = new Map();
    private timers: Map<string, NodeJS.Timeout> = new Map();

    constructor(private windowMs: number = 1000) {
        super({ objectMode: true });
    }

    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        const key = this.getKey(chunk);
        
        // Group by key
        if (!this.buffers.has(key)) {
            this.buffers.set(key, []);
        }
        this.buffers.get(key)!.push(chunk);

        // Schedule flush
        if (!this.timers.has(key)) {
            this.timers.set(key, setTimeout(() => {
                this.flush(key);
            }, this.windowMs));
        }

        callback();
    }

    private getKey(chunk: any): string {
        // Group by userId or similar
        return chunk.userId || 'default';
    }

    private flush(key: string): void {
        const batch = this.buffers.get(key) || [];
        this.buffers.delete(key);
        this.timers.delete(key);

        if (batch.length > 0) {
            // Push the combined result
            this.push({
                key,
                count: batch.length,
                data: batch,
            });
        }
    }

    _flush(callback: (error?: Error | null) => void): void {
        // Flush all remaining buffers
        for (const key of this.buffers.keys()) {
            this.flush(key);
        }
        callback();
    }
}
```

### 6. Backpressure Strategies

#### Buffer-Based Strategy

```typescript
class BufferedStream {
    private buffer: any[] = [];
    private maxSize: number;
    private overflowStrategy: 'drop' | 'error' | 'wait' = 'wait';

    constructor(maxSize: number, overflowStrategy: 'drop' | 'error' | 'wait' = 'wait') {
        this.maxSize = maxSize;
        this.overflowStrategy = overflowStrategy;
    }

    write(data: any): boolean {
        // Check if buffer is full
        if (this.buffer.length >= this.maxSize) {
            switch (this.overflowStrategy) {
                case 'drop':
                    return false; // Drop the data
                case 'error':
                    throw new Error('Buffer full');
                case 'wait':
                    // Wait for space - handled by backpressure
                    return false;
            }
        }

        this.buffer.push(data);
        return true;
    }

    read(): any | undefined {
        return this.buffer.shift();
    }

    size(): number {
        return this.buffer.length;
    }

    isEmpty(): boolean {
        return this.buffer.length === 0;
    }

    isFull(): boolean {
        return this.buffer.length >= this.maxSize;
    }
}
```

#### Throttling Strategy

```typescript
class ThrottledStream extends Transform {
    private lastProcessed: number = 0;
    private queue: any[] = [];
    private isProcessing = false;

    constructor(private maxOpsPerSecond: number) {
        super({ objectMode: true });
    }

    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        this.queue.push({ chunk, callback });
        this.processQueue();
    }

    private async processQueue(): Promise<void> {
        if (this.isProcessing || this.queue.length === 0) {
            return;
        }

        this.isProcessing = true;

        while (this.queue.length > 0) {
            // Check rate limit
            const now = Date.now();
            const elapsed = now - this.lastProcessed;
            const minInterval = 1000 / this.maxOpsPerSecond;

            if (elapsed < minInterval) {
                // Wait for the remaining time
                await this.sleep(minInterval - elapsed);
            }

            // Process the next item
            const item = this.queue.shift();
            if (item) {
                this.lastProcessed = Date.now();
                item.callback(null, item.chunk);
            }
        }

        this.isProcessing = false;
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### 7. Error Handling in Streams

#### Robust Error Handling

```typescript
class SafeStream {
    static async pipeWithRetry(
        source: Readable,
        sink: Writable,
        retries: number = 3
    ): Promise<void> {
        let attempt = 0;

        while (attempt < retries) {
            attempt++;
            try {
                await this.pipeWithTimeout(source, sink, 30000);
                return;
            } catch (error) {
                console.error(`Attempt ${attempt} failed:`, error);
                
                // Recreate streams if needed
                if (attempt < retries) {
                    // Exponential backoff
                    await this.sleep(1000 * Math.pow(2, attempt - 1));
                    
                    // Reset streams
                    source.destroy();
                    sink.destroy();
                    
                    // Recreate
                    source = this.recreateReadable(source);
                    sink = this.recreateWritable(sink);
                }
            }
        }
        
        throw new Error(`All ${retries} attempts failed`);
    }

    private static async pipeWithTimeout(
        source: Readable,
        sink: Writable,
        timeout: number
    ): Promise<void> {
        return new Promise((resolve, reject) => {
            const timeoutId = setTimeout(() => {
                reject(new Error('Pipeline timeout'));
            }, timeout);

            pipeline(
                source,
                sink,
                (err) => {
                    clearTimeout(timeoutId);
                    if (err) {
                        reject(err);
                    } else {
                        resolve();
                    }
                }
            );
        });
    }

    private static recreateReadable(source: Readable): Readable {
        // Logic to recreate the readable stream
        return source;
    }

    private static recreateWritable(sink: Writable): Writable {
        // Logic to recreate the writable stream
        return sink;
    }

    private static sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### 8. Performance Optimization

#### Stream Performance Tips

```typescript
// ❌ BAD: Processing one item at a time
class SlowProcessor extends Transform {
    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        // Process each item individually
        const result = this.process(chunk);
        callback(null, result);
    }
}

// ✅ GOOD: Batch processing
class FastProcessor extends Transform {
    private buffer: any[] = [];
    private batchSize = 100;

    _transform(chunk: any, encoding: string, callback: (error?: Error | null, data?: any) => void): void {
        this.buffer.push(chunk);
        
        if (this.buffer.length >= this.batchSize) {
            // Process in batch
            const results = this.processBatch(this.buffer);
            this.buffer = [];
            
            // Push all results
            for (const result of results) {
                this.push(result);
            }
        }
        
        callback();
    }

    _flush(callback: (error?: Error | null) => void): void {
        // Process remaining buffer
        if (this.buffer.length > 0) {
            const results = this.processBatch(this.buffer);
            for (const result of results) {
                this.push(result);
            }
        }
        callback();
    }

    private processBatch(items: any[]): any[] {
        // Process all items efficiently
        return items.map(item => this.process(item));
    }

    private process(item: any): any {
        // Individual processing logic
        return item;
    }
}
```

### 9. Key Takeaways

1. **Streams are for Large Data:**
   - Process data incrementally
   - Reduce memory usage
   - Handle infinite data sources

2. **Backpressure is Automatic:**
   - Streams handle backpressure internally
   - Piping handles backpressure automatically
   - Manual control for complex scenarios

3. **Choose the Right Stream:**
   - Readable: Data sources
   - Writable: Data destinations
   - Transform: Data processing
   - Duplex: Two-way communication

4. **Error Handling is Critical:**
   - Always handle stream errors
   - Use pipeline for better error handling
   - Implement retry logic for robustness

5. **Performance Matters:**
   - Batch processing for efficiency
   - Optimize highWaterMark settings
   - Monitor throughput

6. **Pipeline is the Way:**
   - Use pipeline for composition
   - Automatic backpressure handling
   - Better error propagation

---

This primer provides a comprehensive understanding of Node.js streams and backpressure. These concepts are essential for building efficient, memory-safe applications that handle large volumes of data.
