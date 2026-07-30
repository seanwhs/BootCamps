# Phase 5, Part 2: Stream Processing & Backpressure

## Building Event Processing Pipelines

Welcome to the second part of Phase 5! Now that we have our event store and event bus, we need to process events efficiently. Think of this like setting up a conveyor belt in a factory - events flow through the system, and we need to handle them at the right speed without overwhelming any part of the system.

### 1. The Target

**What we're building:** Stream processing pipeline with backpressure handling:
- Node.js Readable/Writable streams for event processing
- Backpressure handling to prevent system overload
- Event streaming with cursor-based pagination
- Real-time event processing and notifications
- Stream transformation and aggregation
- Performance monitoring for event pipelines

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── event-store/
│   │   │   │   └── postgres/
│   │   │   │       ├── event-store.ts (updated)
│   │   │   │       └── event-stream.ts          # NEW: Event stream
│   │   │   ├── streams/                         # NEW: Stream processing
│   │   │   │   ├── event-processor.ts
│   │   │   │   ├── backpressure-handler.ts
│   │   │   │   ├── stream-aggregator.ts
│   │   │   │   └── stream-monitor.ts
│   │   │   └── projections/
│   │   │       ├── user-projection.ts (updated)
│   │   │       └── task-projection.ts (updated)
│   │   └── di/
│   │       └── container.ts (updated)
│   ├── core/
│   │   └── application/
│   │       └── handlers/
│   │           └── notification-handler.ts      # NEW: Notification handler
│   └── server.ts (updated)
│
├── tests/
│   ├── unit/
│   │   └── stream-processing.test.ts            # NEW: Stream tests
│   └── integration/
│       └── event-stream.test.ts                 # NEW: Event stream tests
│
└── infrastructure/
    └── terraform/
        └── event-stream.tf                      # NEW: Stream infrastructure
```

### 2. The Concept: Stream Processing & Backpressure

**Stream Processing:**
Like water flowing through a pipe system. Events enter at one end, are processed along the way, and come out the other end transformed.

```
┌─────────────────────────────────────────────────────────────┐
│                     STREAM PIPELINE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Source     │───▶│  Transform   │───▶│   Sink       │  │
│  │   (Event     │    │  (Process,   │    │  (Store,     │  │
│  │    Store)    │    │   Filter,    │    │   Notify)    │  │
│  └──────────────┘    │   Aggregate) │    └──────────────┘  │
│                      └──────────────┘                     │
│                            │                               │
│                            ▼                               │
│                      ┌──────────────┐                     │
│                      │  Backpressure │                     │
│                      │  Control      │                     │
│                      └──────────────┘                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Backpressure:**
Like a pressure valve in a pipe system. When the sink can't keep up, the source slows down to prevent flooding.

### 3. The Implementation

#### Step 1: Event Stream Interface

**File:** `packages/gateway/src/infrastructure/adapters/event-store/postgres/event-stream.ts`

```typescript
import { Readable, Writable, Transform, pipeline } from 'stream';
import { DomainEvent } from '../../../../core/domain/events/user-events.js';
import { EventFactory } from '../../../../core/domain/events/user-events.js';
import { postgresConnection } from '../../persistence/postgres/connection.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * Event Stream
 * 
 * Provides a Node.js stream interface for events.
 * 
 * This allows us to:
 * 1. Process events in batches
 * 2. Apply backpressure
 * 3. Transform events
 * 4. Pipe events to multiple destinations
 */
export class EventStream {
  private readonly logger = createChildLogger({ module: 'EventStream' });

  /**
   * Create a readable stream of events
   */
  createReadStream(options?: {
    aggregateId?: string;
    eventTypes?: string[];
    startDate?: Date;
    endDate?: Date;
    batchSize?: number;
    cursor?: string;
  }): Readable {
    const batchSize = options?.batchSize || 100;
    let cursor = options?.cursor || null;
    let ended = false;

    return new Readable({
      objectMode: true,
      highWaterMark: batchSize,
      read: async function () {
        try {
          if (ended) {
            this.push(null);
            return;
          }

          // Query events in batches
          const events = await this.fetchEvents(cursor, batchSize, options);

          if (events.length === 0) {
            ended = true;
            this.push(null);
            return;
          }

          // Update cursor for next batch
          cursor = events[events.length - 1].eventId;

          // Push events to the stream
          for (const event of events) {
            if (!this.push(event)) {
              // Backpressure detected - wait for drain
              // The stream will handle this automatically
              break;
            }
          }
        } catch (error) {
          this.destroy(error instanceof Error ? error : new Error(String(error)));
        }
      },
    });
  }

  /**
   * Fetch events from the database
   */
  private async fetchEvents(
    cursor: string | null,
    limit: number,
    options?: {
      aggregateId?: string;
      eventTypes?: string[];
      startDate?: Date;
      endDate?: Date;
    }
  ): Promise<DomainEvent[]> {
    let query = `
      SELECT * FROM events
      WHERE 1=1
    `;

    const params: any[] = [];
    let paramIndex = 1;

    if (options?.aggregateId) {
      query += ` AND aggregate_id = $${paramIndex}`;
      params.push(options.aggregateId);
      paramIndex++;
    }

    if (options?.eventTypes && options.eventTypes.length > 0) {
      const placeholders = options.eventTypes
        .map((_, i) => `$${paramIndex + i}`)
        .join(', ');
      query += ` AND event_type IN (${placeholders})`;
      params.push(...options.eventTypes);
      paramIndex += options.eventTypes.length;
    }

    if (options?.startDate) {
      query += ` AND occurred_at >= $${paramIndex}`;
      params.push(options.startDate);
      paramIndex++;
    }

    if (options?.endDate) {
      query += ` AND occurred_at <= $${paramIndex}`;
      params.push(options.endDate);
      paramIndex++;
    }

    if (cursor) {
      query += ` AND event_id > $${paramIndex}`;
      params.push(cursor);
      paramIndex++;
    }

    query += ` ORDER BY occurred_at ASC LIMIT $${paramIndex}`;
    params.push(limit);

    try {
      const result = await postgresConnection.query<any>(query, params);
      return result.rows.map(row => EventFactory.createFromData(row));
    } catch (error) {
      this.logger.error({ error, query, params }, 'Failed to fetch events');
      throw error;
    }
  }

  /**
   * Create a writable stream for events
   */
  createWriteStream(): Writable {
    return new Writable({
      objectMode: true,
      highWaterMark: 100,
      write: async (event: DomainEvent, encoding, callback) => {
        try {
          // Insert event into event store
          const query = `
            INSERT INTO events (
              event_id, aggregate_id, aggregate_type,
              event_type, version, occurred_at, data
            ) VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT (event_id) DO NOTHING
          `;

          const data = event.toJSON();
          await postgresConnection.query(query, [
            event.eventId,
            event.aggregateId,
            event.aggregateType,
            event.eventType,
            event.version,
            event.occurredAt,
            data,
          ]);

          callback();
        } catch (error) {
          callback(error instanceof Error ? error : new Error(String(error)));
        }
      },
    });
  }

  /**
   * Create a transform stream for event processing
   */
  createTransformStream(
    transformFn: (event: DomainEvent) => Promise<DomainEvent | DomainEvent[] | null>
  ): Transform {
    return new Transform({
      objectMode: true,
      highWaterMark: 100,
      transform: async (event: DomainEvent, encoding, callback) => {
        try {
          const result = await transformFn(event);
          
          if (Array.isArray(result)) {
            for (const item of result) {
              this.push(item);
            }
          } else if (result !== null) {
            this.push(result);
          }
          
          callback();
        } catch (error) {
          callback(error instanceof Error ? error : new Error(String(error)));
        }
      },
    });
  }
}

/**
 * Event Pipeline Builder
 * 
 * Builds and runs event processing pipelines
 */
export class EventPipelineBuilder {
  private readonly logger = createChildLogger({ module: 'EventPipelineBuilder' });
  private source: Readable | null = null;
  private transforms: Transform[] = [];
  private sinks: Writable[] = [];
  private monitor: any = null;

  /**
   * Set the source of the pipeline
   */
  from(stream: Readable): this {
    this.source = stream;
    return this;
  }

  /**
   * Add a transform step
   */
  through(transform: Transform): this {
    this.transforms.push(transform);
    return this;
  }

  /**
   * Add a sink
   */
  to(sink: Writable): this {
    this.sinks.push(sink);
    return this;
  }

  /**
   * Add monitoring
   */
  withMonitor(monitor: any): this {
    this.monitor = monitor;
    return this;
  }

  /**
   * Run the pipeline
   */
  run(): Promise<void> {
    if (!this.source) {
      throw new Error('Source stream is required');
    }

    return new Promise((resolve, reject) => {
      try {
        // Build the pipeline
        let currentStream: NodeJS.ReadableStream = this.source;

        // Apply transforms
        for (const transform of this.transforms) {
          currentStream = currentStream.pipe(transform);
        }

        // Connect to sinks
        const pipes: NodeJS.WritableStream[] = [];
        for (const sink of this.sinks) {
          const pipe = currentStream.pipe(sink);
          pipes.push(pipe);
        }

        // Handle errors
        this.source.on('error', reject);
        for (const transform of this.transforms) {
          transform.on('error', reject);
        }
        for (const sink of this.sinks) {
          sink.on('error', reject);
        }

        // Handle completion
        let completed = 0;
        const finishHandler = () => {
          completed++;
          if (completed === pipes.length) {
            this.logger.info('Pipeline completed successfully');
            resolve();
          }
        };

        for (const pipe of pipes) {
          pipe.on('finish', finishHandler);
        }

        // Start the pipeline
        this.logger.info('Pipeline started');
      } catch (error) {
        reject(error);
      }
    });
  }
}

// Singleton instance
export const eventStream = new EventStream();
```

#### Step 2: Backpressure Handler

**File:** `packages/gateway/src/infrastructure/adapters/streams/backpressure-handler.ts`

```typescript
import { createChildLogger } from '../../../logger.js';

/**
 * Backpressure Handler
 * 
 * Manages backpressure in event processing pipelines.
 * 
 * Backpressure is a mechanism to slow down the producer when
 * the consumer can't keep up. This prevents memory overflow
 * and system crashes.
 */
export class BackpressureHandler {
  private readonly logger = createChildLogger({ module: 'BackpressureHandler' });
  private stats = {
    backpressureEvents: 0,
    lastBackpressure: 0,
    totalPauses: 0,
    totalResumes: 0,
  };

  /**
   * Create a backpressure-aware stream wrapper
   */
  wrap<T>(
    source: AsyncIterable<T>,
    options?: {
      maxBufferSize?: number;
      highWaterMark?: number;
      onBackpressure?: (info: BackpressureInfo) => void;
    }
  ): AsyncIterable<T> {
    const maxBufferSize = options?.maxBufferSize || 1000;
    const highWaterMark = options?.highWaterMark || 100;
    let buffer: T[] = [];
    let paused = false;
    let resumeResolve: (() => void) | null = null;

    const info: BackpressureInfo = {
      bufferSize: 0,
      maxBufferSize,
      isPaused: false,
      highWaterMark,
      backpressureEvents: this.stats.backpressureEvents,
    };

    return {
      [Symbol.asyncIterator]: () => {
        const iterator = source[Symbol.asyncIterator]();

        return {
          next: async (): Promise<IteratorResult<T>> => {
            // Check if we have buffered items
            if (buffer.length > 0) {
              const value = buffer.shift()!;
              info.bufferSize = buffer.length;
              return { value, done: false };
            }

            // If paused, wait for resume
            if (paused) {
              await new Promise<void>((resolve) => {
                resumeResolve = resolve;
              });
              paused = false;
              info.isPaused = false;
              this.stats.totalResumes++;
            }

            // Get next item from source
            const result = await iterator.next();

            if (result.done) {
              return result;
            }

            // Check buffer size
            if (buffer.length < maxBufferSize) {
              buffer.push(result.value);
              info.bufferSize = buffer.length;

              // Check if we're approaching the limit
              if (buffer.length >= highWaterMark) {
                paused = true;
                info.isPaused = true;
                this.stats.totalPauses++;
                this.stats.backpressureEvents++;
                this.stats.lastBackpressure = Date.now();

                this.logger.warn({
                  bufferSize: buffer.length,
                  highWaterMark,
                  maxBufferSize,
                }, 'Backpressure applied - pausing stream');

                if (options?.onBackpressure) {
                  options.onBackpressure(info);
                }
              }

              // Return the buffered value
              return { value: buffer.shift()!, done: false };
            }

            // Buffer is full - apply backpressure
            this.stats.backpressureEvents++;
            this.stats.lastBackpressure = Date.now();
            
            this.logger.warn({
              bufferSize: buffer.length,
              maxBufferSize,
            }, 'Buffer full - dropping item');

            if (options?.onBackpressure) {
              options.onBackpressure({
                ...info,
                bufferSize: buffer.length,
                isPaused: true,
              });
            }

            // Drop the item to prevent memory overflow
            return { value: result.value, done: false };
          },
        };
      },
    };
  }

  /**
   * Get backpressure statistics
   */
  getStats(): BackpressureStats {
    return {
      ...this.stats,
      currentBufferSize: 0, // Would need to track this
      isBackpressured: this.stats.backpressureEvents > 0,
    };
  }

  /**
   * Reset statistics
   */
  reset(): void {
    this.stats = {
      backpressureEvents: 0,
      lastBackpressure: 0,
      totalPauses: 0,
      totalResumes: 0,
    };
  }
}

export interface BackpressureInfo {
  bufferSize: number;
  maxBufferSize: number;
  isPaused: boolean;
  highWaterMark: number;
  backpressureEvents: number;
}

export interface BackpressureStats {
  backpressureEvents: number;
  lastBackpressure: number;
  totalPauses: number;
  totalResumes: number;
  currentBufferSize: number;
  isBackpressured: boolean;
}
```

#### Step 3: Stream Aggregator

**File:** `packages/gateway/src/infrastructure/adapters/streams/stream-aggregator.ts`

```typescript
import { DomainEvent } from '../../../core/domain/events/user-events.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Stream Aggregator
 * 
 * Aggregates events by time windows or counts.
 * 
 * This is useful for:
 * 1. Batch processing
 * 2. Rate limiting
 * 3. Periodic reporting
 * 4. Reducing database load
 */
export class StreamAggregator {
  private readonly logger = createChildLogger({ module: 'StreamAggregator' });
  private buffer: DomainEvent[] = [];
  private timer: NodeJS.Timeout | null = null;

  /**
   * Aggregate events by time window
   */
  aggregateByTime<T>(
    events: AsyncIterable<DomainEvent>,
    windowMs: number,
    processBatch: (batch: DomainEvent[]) => Promise<T[]>
  ): AsyncIterable<T> {
    let buffer: DomainEvent[] = [];
    let lastFlush = Date.now();

    const flush = async (): Promise<T[]> => {
      if (buffer.length === 0) return [];
      
      const batch = buffer;
      buffer = [];
      lastFlush = Date.now();
      
      this.logger.debug({ batchSize: batch.length }, 'Flushing time window');
      return processBatch(batch);
    };

    return {
      [Symbol.asyncIterator]: () => {
        const iterator = events[Symbol.asyncIterator]();

        return {
          next: async (): Promise<IteratorResult<T>> => {
            const result = await iterator.next();

            if (result.done) {
              // Flush remaining buffer
              const results = await flush();
              for (const item of results) {
                return { value: item, done: false };
              }
              return { value: undefined as any, done: true };
            }

            buffer.push(result.value);

            // Check if window expired
            const now = Date.now();
            if (now - lastFlush >= windowMs) {
              const results = await flush();
              if (results.length > 0) {
                return { value: results[0], done: false };
              }
            }

            // Get next item
            return this.next();
          },
        };
      },
    };
  }

  /**
   * Aggregate events by count
   */
  aggregateByCount<T>(
    events: AsyncIterable<DomainEvent>,
    batchSize: number,
    processBatch: (batch: DomainEvent[]) => Promise<T[]>
  ): AsyncIterable<T> {
    let buffer: DomainEvent[] = [];

    const flush = async (force: boolean = false): Promise<T[]> => {
      if (buffer.length === 0) return [];
      
      const batch = buffer.slice(0, force ? buffer.length : batchSize);
      if (batch.length === 0) return [];
      
      buffer = buffer.slice(batch.length);
      
      this.logger.debug({ batchSize: batch.length }, 'Flushing count batch');
      return processBatch(batch);
    };

    return {
      [Symbol.asyncIterator]: () => {
        const iterator = events[Symbol.asyncIterator]();

        return {
          next: async (): Promise<IteratorResult<T>> => {
            const result = await iterator.next();

            if (result.done) {
              // Flush remaining buffer
              const results = await flush(true);
              for (const item of results) {
                return { value: item, done: false };
              }
              return { value: undefined as any, done: true };
            }

            buffer.push(result.value);

            // Check if we've reached batch size
            if (buffer.length >= batchSize) {
              const results = await flush();
              if (results.length > 0) {
                return { value: results[0], done: false };
              }
            }

            // Get next item
            return this.next();
          },
        };
      },
    };
  }

  /**
   * Aggregate events by both time and count
   */
  aggregateByBoth<T>(
    events: AsyncIterable<DomainEvent>,
    windowMs: number,
    batchSize: number,
    processBatch: (batch: DomainEvent[]) => Promise<T[]>
  ): AsyncIterable<T> {
    let buffer: DomainEvent[] = [];
    let lastFlush = Date.now();

    const flush = async (force: boolean = false): Promise<T[]> => {
      if (buffer.length === 0) return [];
      
      const batch = force ? buffer : buffer.slice(0, batchSize);
      if (batch.length === 0) return [];
      
      buffer = buffer.slice(batch.length);
      lastFlush = Date.now();
      
      this.logger.debug({
        batchSize: batch.length,
        remaining: buffer.length,
        forced: force,
      }, 'Flushing batch');
      
      return processBatch(batch);
    };

    return {
      [Symbol.asyncIterator]: () => {
        const iterator = events[Symbol.asyncIterator]();

        return {
          next: async (): Promise<IteratorResult<T>> => {
            const result = await iterator.next();

            if (result.done) {
              // Flush remaining buffer
              const results = await flush(true);
              for (const item of results) {
                return { value: item, done: false };
              }
              return { value: undefined as any, done: true };
            }

            buffer.push(result.value);

            // Check conditions
            const now = Date.now();
            const timeExpired = now - lastFlush >= windowMs;
            const countReached = buffer.length >= batchSize;

            if (timeExpired || countReached) {
              const results = await flush(timeExpired);
              if (results.length > 0) {
                return { value: results[0], done: false };
              }
            }

            // Get next item
            return this.next();
          },
        };
      },
    };
  }
}

/**
 * Stream Aggregator Factory
 */
export class StreamAggregatorFactory {
  static create(): StreamAggregator {
    return new StreamAggregator();
  }

  /**
   * Create a time-based aggregator
   */
  static time<T>(
    events: AsyncIterable<DomainEvent>,
    windowMs: number,
    processBatch: (batch: DomainEvent[]) => Promise<T[]>
  ): AsyncIterable<T> {
    const aggregator = new StreamAggregator();
    return aggregator.aggregateByTime(events, windowMs, processBatch);
  }

  /**
   * Create a count-based aggregator
   */
  static count<T>(
    events: AsyncIterable<DomainEvent>,
    batchSize: number,
    processBatch: (batch: DomainEvent[]) => Promise<T[]>
  ): AsyncIterable<T> {
    const aggregator = new StreamAggregator();
    return aggregator.aggregateByCount(events, batchSize, processBatch);
  }

  /**
   * Create a combined aggregator
   */
  static both<T>(
    events: AsyncIterable<DomainEvent>,
    windowMs: number,
    batchSize: number,
    processBatch: (batch: DomainEvent[]) => Promise<T[]>
  ): AsyncIterable<T> {
    const aggregator = new StreamAggregator();
    return aggregator.aggregateByBoth(events, windowMs, batchSize, processBatch);
  }
}
```

#### Step 4: Stream Monitor

**File:** `packages/gateway/src/infrastructure/adapters/streams/stream-monitor.ts`

```typescript
import { Readable, Writable, Transform } from 'stream';
import { createChildLogger } from '../../../logger.js';

/**
 * Stream Monitor
 * 
 * Monitors stream performance and health.
 * 
 * Tracks:
 * 1. Throughput (events per second)
 * 2. Latency (time to process)
 * 3. Error rate
 * 4. Buffer size
 * 5. Backpressure events
 */
export class StreamMonitor {
  private readonly logger = createChildLogger({ module: 'StreamMonitor' });
  private metrics = {
    totalEvents: 0,
    processedEvents: 0,
    failedEvents: 0,
    throughput: 0,
    avgLatency: 0,
    maxLatency: 0,
    minLatency: Infinity,
    bufferSize: 0,
    backpressureEvents: 0,
    startTime: Date.now(),
    lastMetric: Date.now(),
    eventLatencies: [] as number[],
  };

  private interval: NodeJS.Timeout | null = null;

  /**
   * Start monitoring a stream
   */
  monitor(stream: Readable | Writable | Transform, name: string): void {
    this.logger.info({ stream: name }, 'Starting stream monitoring');

    // Start metrics collection
    this.interval = setInterval(() => {
      this.reportMetrics(name);
    }, 10000);

    // Monitor events
    stream.on('data', (chunk) => {
      this.metrics.totalEvents++;
      const now = Date.now();
      this.metrics.lastMetric = now;
    });

    stream.on('error', (error) => {
      this.metrics.failedEvents++;
      this.logger.error({ stream: name, error }, 'Stream error');
    });

    stream.on('finish', () => {
      this.logger.info({ stream: name }, 'Stream finished');
      this.reportMetrics(name);
    });

    stream.on('drain', () => {
      this.logger.debug({ stream: name }, 'Stream drained');
    });

    stream.on('pipe', () => {
      this.logger.debug({ stream: name }, 'Stream piped');
    });

    stream.on('unpipe', () => {
      this.logger.debug({ stream: name }, 'Stream unpiped');
    });
  }

  /**
   * Record a processed event
   */
  recordEvent(latency: number): void {
    this.metrics.processedEvents++;
    this.metrics.eventLatencies.push(latency);
    
    // Keep only last 1000 latencies
    if (this.metrics.eventLatencies.length > 1000) {
      this.metrics.eventLatencies.shift();
    }

    // Update metrics
    this.metrics.avgLatency = this.metrics.eventLatencies.reduce((a, b) => a + b, 0) / 
                              this.metrics.eventLatencies.length;
    this.metrics.maxLatency = Math.max(this.metrics.maxLatency, latency);
    this.metrics.minLatency = Math.min(this.metrics.minLatency, latency);
  }

  /**
   * Record backpressure event
   */
  recordBackpressure(): void {
    this.metrics.backpressureEvents++;
  }

  /**
   * Report metrics
   */
  private reportMetrics(name: string): void {
    const now = Date.now();
    const duration = (now - this.metrics.startTime) / 1000;
    const throughput = this.metrics.totalEvents / duration;

    this.logger.info({
      stream: name,
      totalEvents: this.metrics.totalEvents,
      processedEvents: this.metrics.processedEvents,
      failedEvents: this.metrics.failedEvents,
      throughput: Math.round(throughput * 100) / 100,
      avgLatency: Math.round(this.metrics.avgLatency * 100) / 100,
      maxLatency: Math.round(this.metrics.maxLatency * 100) / 100,
      minLatency: this.metrics.minLatency === Infinity ? 0 : Math.round(this.metrics.minLatency * 100) / 100,
      backpressureEvents: this.metrics.backpressureEvents,
      uptime: Math.round(duration),
    }, 'Stream metrics');
  }

  /**
   * Get current metrics
   */
  getMetrics(): StreamMetrics {
    const now = Date.now();
    const duration = (now - this.metrics.startTime) / 1000;
    
    return {
      totalEvents: this.metrics.totalEvents,
      processedEvents: this.metrics.processedEvents,
      failedEvents: this.metrics.failedEvents,
      successRate: this.metrics.totalEvents > 0 
        ? (this.metrics.processedEvents / this.metrics.totalEvents) * 100 
        : 0,
      throughput: this.metrics.totalEvents / duration,
      avgLatency: this.metrics.avgLatency,
      maxLatency: this.metrics.maxLatency,
      minLatency: this.metrics.minLatency === Infinity ? 0 : this.metrics.minLatency,
      backpressureEvents: this.metrics.backpressureEvents,
      uptime: duration,
      bufferSize: this.metrics.bufferSize,
    };
  }

  /**
   * Stop monitoring
   */
  stop(): void {
    if (this.interval) {
      clearInterval(this.interval);
      this.interval = null;
    }
    this.logger.info('Stream monitoring stopped');
  }
}

export interface StreamMetrics {
  totalEvents: number;
  processedEvents: number;
  failedEvents: number;
  successRate: number;
  throughput: number;
  avgLatency: number;
  maxLatency: number;
  minLatency: number;
  backpressureEvents: number;
  uptime: number;
  bufferSize: number;
}
```

#### Step 5: Event Processor with Streams

**File:** `packages/gateway/src/infrastructure/adapters/streams/event-processor.ts`

```typescript
import { pipeline } from 'stream';
import { DomainEvent } from '../../../core/domain/events/user-events.js';
import { EventStream, eventStream } from '../event-store/postgres/event-stream.js';
import { EventBus } from '../../../core/domain/events/event-bus.js';
import { StreamAggregatorFactory } from './stream-aggregator.js';
import { BackpressureHandler } from './backpressure-handler.js';
import { StreamMonitor } from './stream-monitor.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Event Processor
 * 
 * Processes events through a streaming pipeline.
 * 
 * This is the main event processing engine that:
 * 1. Reads events from the event store
 * 2. Processes them through transforms
 * 3. Publishes them to the event bus
 * 4. Handles backpressure
 */
export class EventProcessor {
  private readonly logger = createChildLogger({ module: 'EventProcessor' });
  private backpressureHandler = new BackpressureHandler();
  private monitor = new StreamMonitor();
  private isRunning = false;

  constructor(
    private readonly eventBus: EventBus,
    private readonly batchSize: number = 100,
    private readonly windowMs: number = 5000
  ) {}

  /**
   * Start processing events
   */
  async start(options?: {
    aggregateId?: string;
    eventTypes?: string[];
    startDate?: Date;
    endDate?: Date;
    cursor?: string;
  }): Promise<void> {
    if (this.isRunning) {
      this.logger.warn('Event processor already running');
      return;
    }

    this.isRunning = true;
    this.logger.info('Starting event processor');

    try {
      // Create event stream
      const source = eventStream.createReadStream({
        aggregateId: options?.aggregateId,
        eventTypes: options?.eventTypes,
        startDate: options?.startDate,
        endDate: options?.endDate,
        cursor: options?.cursor,
        batchSize: this.batchSize,
      });

      // Apply backpressure control
      const backpressuredSource = this.backpressureHandler.wrap(
        this.streamToAsyncIterable(source),
        {
          maxBufferSize: 1000,
          highWaterMark: 100,
          onBackpressure: (info) => {
            this.logger.warn({ info }, 'Backpressure detected');
            this.monitor.recordBackpressure();
          },
        }
      );

      // Monitor the stream
      this.monitor.monitor(source, 'event-processor');

      // Process events
      await this.processEvents(backpressuredSource);

    } catch (error) {
      this.logger.error({ error }, 'Event processor failed');
      throw error;
    } finally {
      this.isRunning = false;
      this.monitor.stop();
    }
  }

  /**
   * Process events from an async iterable
   */
  private async processEvents(events: AsyncIterable<DomainEvent>): Promise<void> {
    let processed = 0;
    let batch: DomainEvent[] = [];

    for await (const event of events) {
      batch.push(event);
      processed++;

      // Process in batches
      if (batch.length >= this.batchSize) {
        await this.processBatch(batch);
        batch = [];
      }
    }

    // Process remaining events
    if (batch.length > 0) {
      await this.processBatch(batch);
    }

    this.logger.info({
      totalProcessed: processed,
    }, 'Event processing complete');
  }

  /**
   * Process a batch of events
   */
  private async processBatch(events: DomainEvent[]): Promise<void> {
    const startTime = Date.now();

    try {
      // Transform events (if needed)
      const transformedEvents = await this.transformEvents(events);

      // Publish to event bus
      for (const event of transformedEvents) {
        await this.eventBus.publish(event);
      }

      // Record latency
      const latency = Date.now() - startTime;
      this.monitor.recordEvent(latency);

      this.logger.debug({
        batchSize: events.length,
        latency,
        avgLatency: latency / events.length,
      }, 'Batch processed');

    } catch (error) {
      this.logger.error({
        error,
        batchSize: events.length,
      }, 'Batch processing failed');
      throw error;
    }
  }

  /**
   * Transform events (optional)
   */
  private async transformEvents(events: DomainEvent[]): Promise<DomainEvent[]> {
    // Example transformations:
    // 1. Filter out events
    // 2. Enrich events with additional data
    // 3. Aggregate events
    
    // For now, return as-is
    return events;
  }

  /**
   * Convert a Node.js stream to an async iterable
   */
  private async *streamToAsyncIterable<T>(stream: NodeJS.ReadableStream): AsyncIterable<T> {
    for await (const chunk of stream) {
      yield chunk as T;
    }
  }

  /**
   * Stop processing
   */
  stop(): void {
    this.isRunning = false;
    this.logger.info('Event processor stopped');
  }

  /**
   * Get processor status
   */
  getStatus(): {
    isRunning: boolean;
    metrics: any;
    backpressure: any;
  } {
    return {
      isRunning: this.isRunning,
      metrics: this.monitor.getMetrics(),
      backpressure: this.backpressureHandler.getStats(),
    };
  }
}
```

#### Step 6: Notification Handler

**File:** `packages/gateway/src/core/application/handlers/notification-handler.ts`

```typescript
import { DomainEvent } from '../../domain/events/user-events.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Notification Handler
 * 
 * Handles sending notifications for events.
 * 
 * This is an example of a reactive component that responds
 * to domain events by sending notifications.
 */
export class NotificationHandler {
  private readonly logger = createChildLogger({ module: 'NotificationHandler' });

  /**
   * Handle user events and send notifications
   */
  async handleUserEvents(event: DomainEvent): Promise<void> {
    this.logger.debug({
      eventType: event.eventType,
      aggregateId: event.aggregateId,
    }, 'Processing user event for notifications');

    switch (event.eventType) {
      case 'UserCreated':
        await this.sendWelcomeEmail(event);
        break;
      case 'UserLoggedIn':
        await this.sendLoginNotification(event);
        break;
      case 'UserProfileUpdated':
        await this.sendProfileUpdateNotification(event);
        break;
      case 'UserDeactivated':
        await this.sendAccountDeactivatedNotification(event);
        break;
    }
  }

  /**
   * Handle task events and send notifications
   */
  async handleTaskEvents(event: DomainEvent): Promise<void> {
    this.logger.debug({
      eventType: event.eventType,
      aggregateId: event.aggregateId,
    }, 'Processing task event for notifications');

    switch (event.eventType) {
      case 'TaskCreated':
        await this.sendTaskCreatedNotification(event);
        break;
      case 'TaskCompleted':
        await this.sendTaskCompletedNotification(event);
        break;
      case 'TaskFailed':
        await this.sendTaskFailedNotification(event);
        break;
      case 'TaskCancelled':
        await this.sendTaskCancelledNotification(event);
        break;
    }
  }

  /**
   * Send welcome email
   */
  private async sendWelcomeEmail(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    this.logger.info({
      userId: event.aggregateId,
      email: data.email,
      username: data.username,
    }, 'Sending welcome email');

    // In production, integrate with email service
    // await emailService.sendWelcomeEmail(data.email, data.username);
  }

  /**
   * Send login notification
   */
  private async sendLoginNotification(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    this.logger.info({
      userId: event.aggregateId,
      ip: data.ipAddress,
    }, 'Sending login notification');

    // In production, send push notification or email
  }

  /**
   * Send profile update notification
   */
  private async sendProfileUpdateNotification(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    this.logger.info({
      userId: event.aggregateId,
    }, 'Sending profile update notification');
  }

  /**
   * Send account deactivated notification
   */
  private async sendAccountDeactivatedNotification(event: DomainEvent): Promise<void> {
    this.logger.info({
      userId: event.aggregateId,
    }, 'Sending account deactivated notification');
  }

  /**
   * Send task created notification
   */
  private async sendTaskCreatedNotification(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    this.logger.info({
      taskId: event.aggregateId,
      title: data.title,
      userId: data.userId,
    }, 'Sending task created notification');
  }

  /**
   * Send task completed notification
   */
  private async sendTaskCompletedNotification(event: DomainEvent): Promise<void> {
    this.logger.info({
      taskId: event.aggregateId,
    }, 'Sending task completed notification');
  }

  /**
   * Send task failed notification
   */
  private async sendTaskFailedNotification(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    this.logger.info({
      taskId: event.aggregateId,
      reason: data.reason,
    }, 'Sending task failed notification');
  }

  /**
   * Send task cancelled notification
   */
  private async sendTaskCancelledNotification(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    this.logger.info({
      taskId: event.aggregateId,
      reason: data.reason,
    }, 'Sending task cancelled notification');
  }
}
```

### 4. The Verification

#### Step 1: Test Event Stream

**File:** `packages/gateway/tests/integration/event-stream.test.ts`

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { eventStream } from '../../src/infrastructure/adapters/event-store/postgres/event-stream.js';
import { EventBus } from '../../src/core/domain/events/event-bus.js';
import { UserCreatedEvent } from '../../src/core/domain/events/user-events.js';
import { EventProcessor } from '../../src/infrastructure/adapters/streams/event-processor.js';

describe('Event Stream Integration Tests', () => {
  let eventBus: EventBus;

  beforeAll(async () => {
    eventBus = EventBus.getInstance();
    
    // Create some test events
    for (let i = 0; i < 10; i++) {
      const event = new UserCreatedEvent(
        `test-${i}`,
        `test${i}@example.com`,
        `testuser${i}`,
        'Test',
        `User${i}`,
        'hash'
      );
      await eventBus.publish(event);
    }
  });

  afterAll(async () => {
    // Clean up test data
    await postgresConnection.query(
      "DELETE FROM events WHERE aggregate_id LIKE 'test-%'"
    );
  });

  it('should stream events in batches', async () => {
    const stream = eventStream.createReadStream({
      eventTypes: ['UserCreated'],
      batchSize: 5,
    });

    const events: any[] = [];
    
    await new Promise((resolve, reject) => {
      stream.on('data', (event) => {
        events.push(event);
      });
      stream.on('end', resolve);
      stream.on('error', reject);
    });

    expect(events.length).toBeGreaterThan(0);
    expect(events[0].eventType).toBe('UserCreated');
  });

  it('should process events through processor', async () => {
    const processor = new EventProcessor(eventBus, 5);
    
    let processed = 0;
    
    // Override transform to count events
    processor.transformEvents = async (events) => {
      processed += events.length;
      return events;
    };

    await processor.start({
      eventTypes: ['UserCreated'],
    });

    expect(processed).toBeGreaterThan(0);
  });
});
```

#### Step 2: Test Backpressure

**File:** `packages/gateway/tests/unit/backpressure.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { BackpressureHandler } from '../../src/infrastructure/adapters/streams/backpressure-handler.js';

describe('Backpressure Handler', () => {
  it('should handle backpressure', async () => {
    const handler = new BackpressureHandler();
    let backpressureEvents = 0;

    // Create a slow consumer
    const slowConsumer = async function* () {
      for (let i = 0; i < 100; i++) {
        yield i;
        // Simulate slow processing
        await new Promise(resolve => setTimeout(resolve, 10));
      }
    };

    const wrapped = handler.wrap(slowConsumer(), {
      maxBufferSize: 10,
      highWaterMark: 5,
      onBackpressure: () => {
        backpressureEvents++;
      },
    });

    let count = 0;
    for await (const item of wrapped) {
      count++;
      // Process slowly
      await new Promise(resolve => setTimeout(resolve, 5));
    }

    expect(count).toBe(100);
    expect(backpressureEvents).toBeGreaterThan(0);
    expect(handler.getStats().backpressureEvents).toBeGreaterThan(0);
  });
});
```

#### Step 3: Test Stream Aggregation

**File:** `packages/gateway/tests/unit/stream-aggregator.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { StreamAggregatorFactory } from '../../src/infrastructure/adapters/streams/stream-aggregator.js';

describe('Stream Aggregator', () => {
  it('should aggregate by count', async () => {
    const events = (async function* () {
      for (let i = 0; i < 10; i++) {
        yield { id: i };
      }
    })();

    const aggregated = StreamAggregatorFactory.count(
      events,
      3,
      async (batch) => {
        return [{ sum: batch.reduce((a, b) => a + b.id, 0) }];
      }
    );

    const results: any[] = [];
    for await (const item of aggregated) {
      results.push(item);
    }

    // 10 items / batch size 3 = 4 batches (3, 3, 3, 1)
    expect(results.length).toBe(3); // One per batch
    expect(results[0].sum).toBe(0 + 1 + 2); // 3
    expect(results[1].sum).toBe(3 + 4 + 5); // 12
    expect(results[2].sum).toBe(6 + 7 + 8); // 21
  });

  it('should aggregate by time', async () => {
    const events = (async function* () {
      for (let i = 0; i < 10; i++) {
        yield { id: i };
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    })();

    const aggregated = StreamAggregatorFactory.time(
      events,
      200, // 200ms window
      async (batch) => {
        return [{ count: batch.length }];
      }
    );

    const results: any[] = [];
    for await (const item of aggregated) {
      results.push(item);
    }

    expect(results.length).toBeGreaterThan(1);
    expect(results[0].count).toBeGreaterThan(0);
  });
});
```

#### Step 4: Run Performance Tests

Create a manual test for performance:

**File:** `packages/gateway/tests/manual/stream-performance.test.ts`

```typescript
import { EventBus } from '../../src/core/domain/events/event-bus.js';
import { EventProcessor } from '../../src/infrastructure/adapters/streams/event-processor.js';
import { UserCreatedEvent } from '../../src/core/domain/events/user-events.js';

async function testStreamPerformance() {
  console.log('Testing stream performance...');
  
  const eventBus = EventBus.getInstance();
  const processor = new EventProcessor(eventBus, 100);

  // Create test events
  const eventCount = 1000;
  console.log(`Creating ${eventCount} test events...`);
  
  for (let i = 0; i < eventCount; i++) {
    const event = new UserCreatedEvent(
      `perf-${i}`,
      `perf${i}@example.com`,
      `perfuser${i}`,
      'Perf',
      `User${i}`,
      'hash'
    );
    // Store events directly (not through bus)
    await eventStore.appendEvents(event.aggregateId, [event]);
  }

  // Process events
  console.log('Processing events...');
  const start = Date.now();

  // Count processed events
  let processed = 0;
  processor.transformEvents = async (events) => {
    processed += events.length;
    return events;
  };

  await processor.start({
    eventTypes: ['UserCreated'],
  });

  const duration = Date.now() - start;
  const throughput = processed / (duration / 1000);

  console.log(`✅ Processed ${processed} events in ${duration}ms`);
  console.log(`✅ Throughput: ${throughput.toFixed(2)} events/second`);
  console.log(`✅ Status:`, processor.getStatus());
}

testStreamPerformance().catch(console.error);
```

### 5. Deep Dive: Stream Processing Patterns

#### Backpressure Strategies

**1. Buffer-Based:**
Buffer items until consumer is ready
```typescript
// Pros: Simple
// Cons: Memory usage
```

**2. Throttling:**
Limit the rate of production
```typescript
// Pros: Controlled
// Cons: Potential data loss
```

**3. Drop:**
Drop items when buffer is full
```typescript
// Pros: Memory safe
// Cons: Data loss
```

**4. Notify:**
Notify producer to slow down
```typescript
// Pros: Cooperative
// Cons: Complex
```

#### Stream Processing Patterns

**1. Fan-Out:**
One source, multiple consumers
```
Source → [Transform] → Sink 1
                     → Sink 2
                     → Sink 3
```

**2. Fan-In:**
Multiple sources, one sink
```
Source 1 → [Transform] → Sink
Source 2 → [Transform] ↗
Source 3 → [Transform] ↗
```

**3. Pipeline:**
Sequential processing steps
```
Source → Transform → Transform → Sink
```

**4. Split-Apply-Combine:**
Split, process, combine results
```
Source → Split → Process → Combine → Sink
```

### 6. Summary

**What We Built:**
- ✅ Event stream interface for Node.js streams
- ✅ Backpressure handling for event processing
- ✅ Stream aggregator for batching events
- ✅ Stream monitor for performance tracking
- ✅ Event processor with batch processing
- ✅ Notification handler for event reactions
- ✅ Comprehensive test suite

**Key Concepts Learned:**
- Node.js streams for event processing
- Backpressure and its importance
- Batch processing strategies
- Stream aggregation patterns
- Performance monitoring
- Event-driven notification handling

**What's Next:**
In Phase 6, we'll build AI systems with agentic loops, integrate LLM tool use, and create the "Final Boss" capstone - a production-grade API orchestration layer.

**Verification Checklist:**
- [ ] Event stream reads events correctly
- [ ] Backpressure handles slow consumers
- [ ] Stream aggregation works by count/time
- [ ] Event processor processes batches
- [ ] Performance metrics are tracked
- [ ] Notifications are sent for events
- [ ] Tests pass for stream components
