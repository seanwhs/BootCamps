# Primer 18: Understanding Message Queues & Event Streaming

## A Comprehensive Guide to Asynchronous Communication

Welcome to the eighteenth primer! This is a comprehensive deep dive into message queues and event streaming - the backbone of asynchronous communication in distributed systems. Think of this like setting up a sophisticated order processing system in your restaurant chain - orders come in, are queued for preparation, and flow through various stations (services) in a controlled, reliable manner.

### 1. The Big Picture

#### Message Queue & Event Streaming Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MESSAGE QUEUE & STREAMING ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MESSAGE PRODUCERS                                │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   API        │  │   Database   │  │   External   │              │   │
│  │  │   Gateway    │  │   Changes    │  │   Systems    │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MESSAGE BROKER / EVENT STREAM                    │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                    TOPIC / QUEUE                           │   │   │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │   │   │
│  │  │  │ Message │  │ Message │  │ Message │  │ Message │       │   │   │
│  │  │  │    1    │  │    2    │  │    3    │  │    N    │       │   │   │
│  │  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │               PARTITIONS / CONSUMER GROUPS                 │   │   │
│  │  │  Partition 0 ◄── Consumer Group A                          │   │   │
│  │  │  Partition 1 ◄── Consumer Group B                          │   │   │
│  │  │  Partition 2 ◄── Consumer Group C                          │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    MESSAGE CONSUMERS                               │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   Email      │  │   Analytics  │  │   Notification │             │   │
│  │  │   Service    │  │   Service    │  │   Service     │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Message Queue Implementation

#### RabbitMQ Producer/Consumer

```typescript
import amqp, { Connection, Channel } from 'amqplib';

class RabbitMQProducer {
    private connection: Connection | null = null;
    private channel: Channel | null = null;
    private logger: Logger;

    constructor(private readonly url: string) {
        this.logger = createLogger({ service: 'rabbitmq-producer' });
    }

    async connect(): Promise<void> {
        try {
            this.connection = await amqp.connect(this.url);
            this.channel = await this.connection.createChannel();
            
            // Setup exchanges and queues
            await this.setupInfrastructure();

            this.logger.info('RabbitMQ producer connected');
        } catch (error) {
            this.logger.error({ error }, 'Failed to connect to RabbitMQ');
            throw error;
        }
    }

    private async setupInfrastructure(): Promise<void> {
        if (!this.channel) return;

        // Declare exchanges
        await this.channel.assertExchange('orchestrator.events', 'topic', {
            durable: true,
        });

        await this.channel.assertExchange('orchestrator.commands', 'direct', {
            durable: true,
        });

        await this.channel.assertExchange('orchestrator.notifications', 'fanout', {
            durable: true,
        });
    }

    async publish(
        exchange: string,
        routingKey: string,
        message: any,
        options?: {
            persistent?: boolean;
            expiration?: number;
            headers?: Record<string, string>;
        }
    ): Promise<void> {
        if (!this.channel) {
            throw new Error('RabbitMQ producer not connected');
        }

        const payload = Buffer.from(JSON.stringify(message));

        try {
            this.channel.publish(
                exchange,
                routingKey,
                payload,
                {
                    persistent: options?.persistent ?? true,
                    expiration: options?.expiration?.toString(),
                    headers: {
                        'x-message-type': message.type,
                        'x-correlation-id': message.correlationId,
                        ...options?.headers,
                    },
                    timestamp: Math.floor(Date.now() / 1000),
                }
            );

            this.logger.debug({
                exchange,
                routingKey,
                messageType: message.type,
            }, 'Message published');
        } catch (error) {
            this.logger.error({ error, exchange, routingKey }, 'Failed to publish message');
            throw error;
        }
    }

    async disconnect(): Promise<void> {
        try {
            if (this.channel) {
                await this.channel.close();
            }
            if (this.connection) {
                await this.connection.close();
            }
            this.logger.info('RabbitMQ producer disconnected');
        } catch (error) {
            this.logger.error({ error }, 'Error disconnecting from RabbitMQ');
        }
    }
}

class RabbitMQConsumer {
    private connection: Connection | null = null;
    private channel: Channel | null = null;
    private logger: Logger;
    private consumerTag: string | null = null;

    constructor(
        private readonly url: string,
        private readonly queueName: string
    ) {
        this.logger = createLogger({ service: 'rabbitmq-consumer' });
    }

    async connect(): Promise<void> {
        try {
            this.connection = await amqp.connect(this.url);
            this.channel = await this.connection.createChannel();
            
            // Setup queue
            await this.setupInfrastructure();

            this.logger.info('RabbitMQ consumer connected');
        } catch (error) {
            this.logger.error({ error }, 'Failed to connect to RabbitMQ');
            throw error;
        }
    }

    private async setupInfrastructure(): Promise<void> {
        if (!this.channel) return;

        // Declare queue
        await this.channel.assertQueue(this.queueName, {
            durable: true,
            deadLetterExchange: 'orchestrator.dlq',
        });

        // Bind to exchanges
        await this.channel.bindQueue(
            this.queueName,
            'orchestrator.events',
            '#' // All events
        );

        await this.channel.bindQueue(
            this.queueName,
            'orchestrator.commands',
            'task.*' // Task commands
        );

        // Set prefetch
        await this.channel.prefetch(10);
    }

    async consume(
        handler: (message: any) => Promise<void>,
        options?: {
            ackMode?: 'auto' | 'manual';
            retryOnFailure?: boolean;
            maxRetries?: number;
        }
    ): Promise<void> {
        if (!this.channel) {
            throw new Error('RabbitMQ consumer not connected');
        }

        const { consumerTag } = await this.channel.consume(
            this.queueName,
            async (msg) => {
                if (!msg) return;

                try {
                    const content = JSON.parse(msg.content.toString());
                    const retryCount = this.getRetryCount(msg);

                    // Process message
                    await handler(content);

                    // Acknowledge
                    if (options?.ackMode === 'manual') {
                        // Manual ack handled by consumer
                    } else {
                        this.channel!.ack(msg);
                    }

                    this.logger.debug({
                        messageId: msg.properties.messageId,
                        retryCount,
                    }, 'Message processed successfully');

                } catch (error) {
                    const retryCount = this.getRetryCount(msg) + 1;
                    this.logger.error({
                        error,
                        messageId: msg.properties.messageId,
                        retryCount,
                        maxRetries: options?.maxRetries,
                    }, 'Failed to process message');

                    if (options?.retryOnFailure && 
                        retryCount <= (options?.maxRetries || 3)) {
                        // Reject and requeue with retry count
                        this.channel!.nack(msg, false, true);
                    } else {
                        // Reject and send to DLQ
                        this.channel!.nack(msg, false, false);
                    }
                }
            },
            { noAck: options?.ackMode === 'auto' }
        );

        this.consumerTag = consumerTag;
        this.logger.info('Consumer started', { consumerTag });
    }

    private getRetryCount(msg: amqp.Message): number {
        const headers = msg.properties.headers || {};
        return parseInt(headers['x-retry-count'] || '0', 10);
    }

    async stop(): Promise<void> {
        if (this.channel && this.consumerTag) {
            await this.channel.cancel(this.consumerTag);
            this.logger.info('Consumer stopped');
        }
    }

    async disconnect(): Promise<void> {
        await this.stop();
        try {
            if (this.channel) {
                await this.channel.close();
            }
            if (this.connection) {
                await this.connection.close();
            }
            this.logger.info('RabbitMQ consumer disconnected');
        } catch (error) {
            this.logger.error({ error }, 'Error disconnecting from RabbitMQ');
        }
    }
}
```

### 3. Event Streaming with Kafka

```typescript
import { Kafka, Producer, Consumer, Partitioners, logLevel } from 'kafkajs';

class KafkaEventStream {
    private kafka: Kafka;
    private producer: Producer | null = null;
    private consumer: Consumer | null = null;
    private logger: Logger;

    constructor(
        clientId: string,
        brokers: string[],
        private readonly groupId: string
    ) {
        this.kafka = new Kafka({
            clientId,
            brokers,
            logLevel: logLevel.INFO,
            retry: {
                initialRetryTime: 300,
                retries: 10,
            },
        });
        this.logger = createLogger({ service: 'kafka-stream' });
    }

    async connectProducer(): Promise<void> {
        this.producer = this.kafka.producer({
            createPartitioner: Partitioners.DefaultPartitioner,
            allowAutoTopicCreation: true,
            idempotent: true,
        });
        await this.producer.connect();
        this.logger.info('Kafka producer connected');
    }

    async connectConsumer(): Promise<void> {
        this.consumer = this.kafka.consumer({
            groupId: this.groupId,
            maxWaitTimeInMs: 100,
            heartbeatInterval: 3000,
            sessionTimeout: 30000,
            retry: {
                maxRetryTime: 30000,
                initialRetryTime: 300,
                retries: 10,
            },
        });
        await this.consumer.connect();
        this.logger.info('Kafka consumer connected');
    }

    async produce(
        topic: string,
        messages: Array<{
            key?: string;
            value: any;
            partition?: number;
            headers?: Record<string, string>;
        }>
    ): Promise<void> {
        if (!this.producer) {
            throw new Error('Kafka producer not connected');
        }

        const records = messages.map(msg => ({
            key: msg.key,
            value: JSON.stringify(msg.value),
            partition: msg.partition,
            headers: {
                'message-type': msg.value.type || 'unknown',
                'correlation-id': msg.value.correlationId || '',
                ...msg.headers,
            },
            timestamp: Date.now().toString(),
        }));

        try {
            await this.producer.send({
                topic,
                messages: records,
                acks: -1, // Wait for all replicas
                timeout: 30000,
            });

            this.logger.debug({
                topic,
                count: records.length,
            }, 'Messages produced to Kafka');
        } catch (error) {
            this.logger.error({ error, topic }, 'Failed to produce messages');
            throw error;
        }
    }

    async consume(
        topics: string[],
        handler: (message: any, context: ConsumerContext) => Promise<void>,
        options?: {
            fromBeginning?: boolean;
            maxMessages?: number;
            partitionsConsumedConcurrently?: number;
        }
    ): Promise<void> {
        if (!this.consumer) {
            throw new Error('Kafka consumer not connected');
        }

        await this.consumer.subscribe({
            topics,
            fromBeginning: options?.fromBeginning || false,
        });

        await this.consumer.run({
            partitionsConsumedConcurrently: options?.partitionsConsumedConcurrently || 1,
            eachMessage: async ({ topic, partition, message, heartbeat }) => {
                try {
                    if (!message.value) {
                        this.logger.warn({ topic, partition }, 'Empty message received');
                        return;
                    }

                    const value = JSON.parse(message.value.toString());

                    // Process message
                    await handler(value, {
                        topic,
                        partition,
                        offset: parseInt(message.offset, 10),
                        key: message.key?.toString(),
                        timestamp: new Date(parseInt(message.timestamp || '0')),
                        heartbeat,
                    });

                    this.logger.debug({
                        topic,
                        partition,
                        offset: message.offset,
                        messageType: value.type,
                    }, 'Message processed successfully');

                } catch (error) {
                    this.logger.error({
                        error,
                        topic,
                        partition,
                        offset: message.offset,
                    }, 'Failed to process message');
                    
                    // In Kafka, we can't nack individual messages
                    // Error handling needs to be implemented differently
                    // e.g., send to a dead letter topic
                    // We'll log and continue
                }
            },
            eachBatch: options?.maxMessages ? {
                maxBatchSize: options.maxMessages,
                autoResolve: true,
            } : undefined,
        });

        this.logger.info({
            topics,
            groupId: this.groupId,
        }, 'Kafka consumer started');
    }

    async pause(): Promise<void> {
        if (this.consumer) {
            await this.consumer.pause();
            this.logger.info('Kafka consumer paused');
        }
    }

    async resume(): Promise<void> {
        if (this.consumer) {
            await this.consumer.resume();
            this.logger.info('Kafka consumer resumed');
        }
    }

    async commitOffsets(): Promise<void> {
        if (this.consumer) {
            await this.consumer.commitOffsets([]);
        }
    }

    async disconnect(): Promise<void> {
        try {
            if (this.producer) {
                await this.producer.disconnect();
            }
            if (this.consumer) {
                await this.consumer.disconnect();
            }
            this.logger.info('Kafka disconnected');
        } catch (error) {
            this.logger.error({ error }, 'Error disconnecting from Kafka');
        }
    }
}

interface ConsumerContext {
    topic: string;
    partition: number;
    offset: number;
    key?: string;
    timestamp: Date;
    heartbeat: () => Promise<void>;
}
```

### 4. Message Patterns

#### Work Queue Pattern

```typescript
class WorkQueue {
    private queue: RabbitMQConsumer;
    private producer: RabbitMQProducer;
    private workers: number = 0;
    private maxWorkers: number = 10;
    private logger: Logger;

    constructor(
        queue: RabbitMQConsumer,
        producer: RabbitMQProducer,
        maxWorkers: number = 10
    ) {
        this.queue = queue;
        this.producer = producer;
        this.maxWorkers = maxWorkers;
        this.logger = createLogger({ service: 'work-queue' });
    }

    async start(): Promise<void> {
        await this.queue.consume(
            async (message) => {
                this.workers++;
                
                try {
                    await this.processWork(message);
                    
                    // Send completion message
                    await this.producer.publish(
                        'orchestrator.events',
                        'task.completed',
                        {
                            type: 'task.completed',
                            correlationId: message.correlationId,
                            data: {
                                taskId: message.data.taskId,
                                completedAt: new Date().toISOString(),
                            },
                        }
                    );
                } catch (error) {
                    this.logger.error({ error, message }, 'Work processing failed');
                    
                    // Send failure message
                    await this.producer.publish(
                        'orchestrator.events',
                        'task.failed',
                        {
                            type: 'task.failed',
                            correlationId: message.correlationId,
                            data: {
                                taskId: message.data.taskId,
                                error: error instanceof Error ? error.message : String(error),
                            },
                        }
                    );
                    
                    throw error;
                } finally {
                    this.workers--;
                }
            },
            {
                ackMode: 'manual',
                retryOnFailure: true,
                maxRetries: 3,
            }
        );
        
        this.logger.info('Work queue started');
    }

    private async processWork(message: any): Promise<void> {
        // Simulate work
        await new Promise(resolve => setTimeout(resolve, 1000));
        this.logger.info({
            taskId: message.data.taskId,
            workers: this.workers,
        }, 'Processing work');
    }

    getStats(): {
        workers: number;
        maxWorkers: number;
        utilization: number;
    } {
        return {
            workers: this.workers,
            maxWorkers: this.maxWorkers,
            utilization: this.workers / this.maxWorkers,
        };
    }
}
```

#### Pub/Sub Pattern

```typescript
class PubSubManager {
    private producer: RabbitMQProducer;
    private consumers: Map<string, RabbitMQConsumer> = new Map();
    private subscriptions: Map<string, Set<string>> = new Map();
    private logger: Logger;

    constructor(producer: RabbitMQProducer) {
        this.producer = producer;
        this.logger = createLogger({ service: 'pubsub' });
    }

    async publish(
        topic: string,
        event: any
    ): Promise<void> {
        const subscribers = this.subscriptions.get(topic) || new Set();
        
        this.logger.debug({
            topic,
            subscribers: subscribers.size,
            eventType: event.type,
        }, 'Publishing event');

        // Publish to exchange
        await this.producer.publish(
            'orchestrator.events',
            topic,
            {
                ...event,
                publishedAt: new Date().toISOString(),
            }
        );
    }

    async subscribe(
        topic: string,
        subscriberId: string,
        handler: (event: any) => Promise<void>
    ): Promise<void> {
        // Add to subscriptions
        if (!this.subscriptions.has(topic)) {
            this.subscriptions.set(topic, new Set());
            // Create queue for topic
            await this.setupConsumer(topic);
        }
        
        this.subscriptions.get(topic)!.add(subscriberId);

        // Create consumer for this subscriber
        const queueName = `subscriber.${subscriberId}.${topic}`;
        const consumer = new RabbitMQConsumer(
            process.env.RABBITMQ_URL!,
            queueName
        );

        await consumer.connect();
        await consumer.consume(handler, {
            ackMode: 'auto',
            retryOnFailure: true,
            maxRetries: 3,
        });

        this.consumers.set(`${subscriberId}:${topic}`, consumer);

        this.logger.info({
            topic,
            subscriberId,
        }, 'Subscribed to topic');
    }

    private async setupConsumer(topic: string): Promise<void> {
        // Setup queue binding for topic
        const queueName = `topic.${topic}`;
        const consumer = new RabbitMQConsumer(
            process.env.RABBITMQ_URL!,
            queueName
        );
        
        await consumer.connect();
        // Bind to topic exchange
        // Implementation depends on broker
    }

    async unsubscribe(
        topic: string,
        subscriberId: string
    ): Promise<void> {
        const key = `${subscriberId}:${topic}`;
        const consumer = this.consumers.get(key);
        
        if (consumer) {
            await consumer.stop();
            await consumer.disconnect();
            this.consumers.delete(key);
        }

        const subscribers = this.subscriptions.get(topic);
        if (subscribers) {
            subscribers.delete(subscriberId);
            if (subscribers.size === 0) {
                this.subscriptions.delete(topic);
            }
        }

        this.logger.info({
            topic,
            subscriberId,
        }, 'Unsubscribed from topic');
    }

    async cleanup(): Promise<void> {
        for (const consumer of this.consumers.values()) {
            await consumer.stop();
            await consumer.disconnect();
        }
        this.consumers.clear();
        this.subscriptions.clear();
    }
}
```

### 5. Dead Letter Queue

```typescript
class DeadLetterQueue {
    private consumer: RabbitMQConsumer;
    private producer: RabbitMQProducer;
    private logger: Logger;

    constructor(
        consumer: RabbitMQConsumer,
        producer: RabbitMQProducer
    ) {
        this.consumer = consumer;
        this.producer = producer;
        this.logger = createLogger({ service: 'dead-letter-queue' });
    }

    async processDeadLetters(): Promise<void> {
        await this.consumer.consume(
            async (message) => {
                this.logger.warn({
                    messageId: message.id,
                    originalQueue: message.headers['x-original-queue'],
                    error: message.headers['x-error'],
                    timestamp: message.headers['x-failed-at'],
                }, 'Processing dead letter');

                // Store in database for manual inspection
                await this.storeDeadLetter(message);

                // Optionally retry after manual review
                // await this.retryMessage(message);
            },
            {
                ackMode: 'manual',
                retryOnFailure: false,
            }
        );

        this.logger.info('Dead letter queue processor started');
    }

    private async storeDeadLetter(message: any): Promise<void> {
        // Store in database
        // Implementation omitted for brevity
    }

    private async retryMessage(message: any): Promise<void> {
        await this.producer.publish(
            message.headers['x-original-exchange'],
            message.headers['x-original-routing-key'],
            message,
            {
                headers: {
                    'x-retry-count': (parseInt(message.headers['x-retry-count'] || '0') + 1),
                },
            }
        );
    }
}
```

### 6. Key Takeaways

1. **Message Queue vs Event Stream:**
   - Queues: Point-to-point, ordered, competing consumers
   - Streams: Multiple consumers, replay, order preserved
   - Choose based on use case

2. **Delivery Semantics:**
   - At-most-once: Fast, potential data loss
   - At-least-once: Reliable, potential duplicates
   - Exactly-once: Ideal but complex

3. **Message Patterns:**
   - Work Queue: Distribute work among workers
   - Pub/Sub: Broadcast to multiple consumers
   - Request-Reply: Synchronous over async

4. **Error Handling:**
   - Dead Letter Queue for failed messages
   - Retry with exponential backoff
   - Manual intervention for complex issues

5. **Performance Considerations:**
   - Batch processing
   - Prefetch limits
   - Partitioning
   - Compression

6. **Monitoring:**
   - Queue depth
   - Consumer lag
   - Processing time
   - Error rate

---

This primer provides a comprehensive understanding of message queues and event streaming. These technologies are essential for building scalable, decoupled, and resilient distributed systems.
