# Primer 14: Understanding Event-Driven Architecture Deep Dive

## A Comprehensive Guide to Building Event-Driven Systems

Welcome to the fourteenth primer! This is a comprehensive deep dive into event-driven architecture (EDA) - a powerful architectural pattern that enables loose coupling, scalability, and real-time responsiveness. Think of this like a well-orchestrated dance where each dancer (service) responds to the music (events) independently, creating a beautiful synchronized performance without needing to watch each other.

### 1. The Big Picture

#### Event-Driven Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EVENT-DRIVEN ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     EVENT PRODUCERS                                 │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   API        │  │   Database   │  │   External   │              │   │
│  │  │   Gateway    │  │   Changes    │  │   Systems    │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     EVENT BUS / BROKER                             │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  • Message Queue (RabbitMQ, SQS)                           │   │   │
│  │  │  • Event Streaming (Kafka, Kinesis)                        │   │   │
│  │  │  • Pub/Sub (SNS, Google Pub/Sub)                           │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     EVENT CONSUMERS                                │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   Email      │  │   Analytics  │  │   Notification │             │   │
│  │  │   Service    │  │   Service    │  │   Service     │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Event Flow: Event → Broker → Consumer → Process → (Optional) New Events   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Event Types & Schemas

#### Domain Events

```typescript
// Base Domain Event
abstract class DomainEvent {
    public readonly id: string;
    public readonly type: string;
    public readonly aggregateId: string;
    public readonly version: number;
    public readonly timestamp: Date;
    public readonly correlationId: string;
    public readonly causationId?: string;

    constructor(
        type: string,
        aggregateId: string,
        version: number = 1,
        correlationId?: string,
        causationId?: string
    ) {
        this.id = randomUUID();
        this.type = type;
        this.aggregateId = aggregateId;
        this.version = version;
        this.timestamp = new Date();
        this.correlationId = correlationId || randomUUID();
        this.causationId = causationId;
    }

    abstract toJSON(): Record<string, any>;
}

// User Domain Events
class UserCreatedEvent extends DomainEvent {
    constructor(
        aggregateId: string,
        public readonly email: string,
        public readonly username: string,
        public readonly firstName: string,
        public readonly lastName: string,
        version: number = 1,
        correlationId?: string,
        causationId?: string
    ) {
        super('UserCreated', aggregateId, version, correlationId, causationId);
    }

    toJSON(): Record<string, any> {
        return {
            id: this.id,
            type: this.type,
            aggregateId: this.aggregateId,
            version: this.version,
            timestamp: this.timestamp.toISOString(),
            correlationId: this.correlationId,
            causationId: this.causationId,
            data: {
                email: this.email,
                username: this.username,
                firstName: this.firstName,
                lastName: this.lastName,
            },
        };
    }
}

class UserEmailChangedEvent extends DomainEvent {
    constructor(
        aggregateId: string,
        public readonly oldEmail: string,
        public readonly newEmail: string,
        version: number = 1,
        correlationId?: string,
        causationId?: string
    ) {
        super('UserEmailChanged', aggregateId, version, correlationId, causationId);
    }

    toJSON(): Record<string, any> {
        return {
            id: this.id,
            type: this.type,
            aggregateId: this.aggregateId,
            version: this.version,
            timestamp: this.timestamp.toISOString(),
            correlationId: this.correlationId,
            causationId: this.causationId,
            data: {
                oldEmail: this.oldEmail,
                newEmail: this.newEmail,
            },
        };
    }
}

// Task Domain Events
class TaskCreatedEvent extends DomainEvent {
    constructor(
        aggregateId: string,
        public readonly title: string,
        public readonly userId: string,
        public readonly priority: string,
        version: number = 1,
        correlationId?: string,
        causationId?: string
    ) {
        super('TaskCreated', aggregateId, version, correlationId, causationId);
    }

    toJSON(): Record<string, any> {
        return {
            id: this.id,
            type: this.type,
            aggregateId: this.aggregateId,
            version: this.version,
            timestamp: this.timestamp.toISOString(),
            correlationId: this.correlationId,
            causationId: this.causationId,
            data: {
                title: this.title,
                userId: this.userId,
                priority: this.priority,
            },
        };
    }
}
```

#### Event Schemas with Zod

```typescript
import { z } from 'zod';

// Event Schema Definition
const EventSchemas = {
    UserCreated: z.object({
        id: z.string().uuid(),
        type: z.literal('UserCreated'),
        aggregateId: z.string().uuid(),
        version: z.number().positive(),
        timestamp: z.string().datetime(),
        correlationId: z.string().uuid(),
        causationId: z.string().uuid().optional(),
        data: z.object({
            email: z.string().email(),
            username: z.string().min(3),
            firstName: z.string(),
            lastName: z.string(),
        }),
    }),

    UserEmailChanged: z.object({
        id: z.string().uuid(),
        type: z.literal('UserEmailChanged'),
        aggregateId: z.string().uuid(),
        version: z.number().positive(),
        timestamp: z.string().datetime(),
        correlationId: z.string().uuid(),
        causationId: z.string().uuid().optional(),
        data: z.object({
            oldEmail: z.string().email(),
            newEmail: z.string().email(),
        }),
    }),

    TaskCreated: z.object({
        id: z.string().uuid(),
        type: z.literal('TaskCreated'),
        aggregateId: z.string().uuid(),
        version: z.number().positive(),
        timestamp: z.string().datetime(),
        correlationId: z.string().uuid(),
        causationId: z.string().uuid().optional(),
        data: z.object({
            title: z.string(),
            userId: z.string().uuid(),
            priority: z.enum(['low', 'medium', 'high', 'critical']),
        }),
    }),
};

type EventType = keyof typeof EventSchemas;

// Event Validator
class EventValidator {
    validate(event: any): { valid: boolean; error?: string } {
        const schema = EventSchemas[event.type as EventType];
        if (!schema) {
            return { valid: false, error: `Unknown event type: ${event.type}` };
        }

        try {
            schema.parse(event);
            return { valid: true };
        } catch (error) {
            if (error instanceof z.ZodError) {
                return { 
                    valid: false, 
                    error: error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ')
                };
            }
            return { valid: false, error: 'Validation failed' };
        }
    }
}
```

### 3. Event Brokers

#### RabbitMQ Implementation

```typescript
import amqp, { Connection, Channel } from 'amqplib';

class RabbitMQEventBroker {
    private connection: Connection | null = null;
    private channel: Channel | null = null;
    private readonly logger: Logger;

    constructor(private readonly url: string) {
        this.logger = createLogger({ service: 'rabbitmq' });
    }

    async connect(): Promise<void> {
        try {
            this.connection = await amqp.connect(this.url);
            this.channel = await this.connection.createChannel();
            
            // Setup exchanges
            await this.setupExchanges();

            this.logger.info('RabbitMQ connected');
        } catch (error) {
            this.logger.error({ error }, 'Failed to connect to RabbitMQ');
            throw error;
        }
    }

    private async setupExchanges(): Promise<void> {
        if (!this.channel) return;

        // Topic exchange for routing
        await this.channel.assertExchange('orchestrator.events', 'topic', {
            durable: true,
        });

        // Dead letter exchange
        await this.channel.assertExchange('orchestrator.events.dead', 'topic', {
            durable: true,
        });
    }

    async publish(
        event: DomainEvent,
        options?: {
            routingKey?: string;
            headers?: Record<string, string>;
            expiration?: number;
        }
    ): Promise<void> {
        if (!this.channel) {
            throw new Error('RabbitMQ not connected');
        }

        const routingKey = options?.routingKey || event.type;
        const payload = JSON.stringify(event.toJSON());

        try {
            this.channel.publish(
                'orchestrator.events',
                routingKey,
                Buffer.from(payload),
                {
                    persistent: true,
                    headers: {
                        'x-event-type': event.type,
                        'x-correlation-id': event.correlationId,
                        ...options?.headers,
                    },
                    expiration: options?.expiration?.toString(),
                    timestamp: Math.floor(event.timestamp.getTime() / 1000),
                }
            );

            this.logger.debug({
                eventType: event.type,
                eventId: event.id,
                routingKey,
            }, 'Event published');
        } catch (error) {
            this.logger.error({ error, event }, 'Failed to publish event');
            throw error;
        }
    }

    async consume(
        eventTypes: string[],
        handler: (event: DomainEvent) => Promise<void>,
        options?: {
            queueName?: string;
            prefetch?: number;
            deadLetter?: boolean;
        }
    ): Promise<void> {
        if (!this.channel) {
            throw new Error('RabbitMQ not connected');
        }

        const queueName = options?.queueName || `orchestrator.events.${randomUUID()}`;
        const prefetch = options?.prefetch || 10;

        // Setup queue
        await this.channel.assertQueue(queueName, {
            durable: true,
            deadLetterExchange: options?.deadLetter ? 'orchestrator.events.dead' : undefined,
        });

        // Bind to event types
        for (const eventType of eventTypes) {
            await this.channel.bindQueue(
                queueName,
                'orchestrator.events',
                eventType
            );
        }

        // Set prefetch
        await this.channel.prefetch(prefetch);

        // Consume messages
        await this.channel.consume(queueName, async (msg) => {
            if (!msg) return;

            try {
                const content = JSON.parse(msg.content.toString());
                const event = this.createEvent(content);

                // Validate event
                const validator = new EventValidator();
                const validation = validator.validate(content);
                if (!validation.valid) {
                    this.logger.warn({
                        eventId: event.id,
                        error: validation.error,
                    }, 'Invalid event');
                    this.channel!.ack(msg);
                    return;
                }

                // Process event
                await handler(event);
                this.channel!.ack(msg);

                this.logger.debug({
                    eventType: event.type,
                    eventId: event.id,
                }, 'Event processed successfully');
            } catch (error) {
                this.logger.error({
                    error,
                    eventId: msg.properties.headers?.['x-message-id'],
                }, 'Failed to process event');

                // Reject and requeue or dead letter
                this.channel!.nack(msg, false, options?.deadLetter !== false);
            }
        });

        this.logger.info({
            queue: queueName,
            eventTypes,
        }, 'Consumer started');
    }

    private createEvent(data: any): DomainEvent {
        // Factory method to create event from data
        switch (data.type) {
            case 'UserCreated':
                return new UserCreatedEvent(
                    data.aggregateId,
                    data.data.email,
                    data.data.username,
                    data.data.firstName,
                    data.data.lastName,
                    data.version,
                    data.correlationId,
                    data.causationId
                );
            case 'UserEmailChanged':
                return new UserEmailChangedEvent(
                    data.aggregateId,
                    data.data.oldEmail,
                    data.data.newEmail,
                    data.version,
                    data.correlationId,
                    data.causationId
                );
            case 'TaskCreated':
                return new TaskCreatedEvent(
                    data.aggregateId,
                    data.data.title,
                    data.data.userId,
                    data.data.priority,
                    data.version,
                    data.correlationId,
                    data.causationId
                );
            default:
                throw new Error(`Unknown event type: ${data.type}`);
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
            this.logger.info('RabbitMQ disconnected');
        } catch (error) {
            this.logger.error({ error }, 'Error disconnecting from RabbitMQ');
        }
    }
}
```

#### Kafka Implementation

```typescript
import { Kafka, Producer, Consumer, Partitioners } from 'kafkajs';

class KafkaEventBroker {
    private kafka: Kafka;
    private producer: Producer | null = null;
    private consumer: Consumer | null = null;
    private readonly logger: Logger;

    constructor(
        clientId: string,
        brokers: string[],
        private readonly groupId: string
    ) {
        this.kafka = new Kafka({
            clientId,
            brokers,
        });
        this.logger = createLogger({ service: 'kafka' });
    }

    async connectProducer(): Promise<void> {
        this.producer = this.kafka.producer({
            createPartitioner: Partitioners.DefaultPartitioner,
        });
        await this.producer.connect();
        this.logger.info('Kafka producer connected');
    }

    async connectConsumer(): Promise<void> {
        this.consumer = this.kafka.consumer({ groupId: this.groupId });
        await this.consumer.connect();
        this.logger.info('Kafka consumer connected');
    }

    async publish(
        topic: string,
        event: DomainEvent,
        options?: {
            key?: string;
            partition?: number;
            headers?: Record<string, string>;
        }
    ): Promise<void> {
        if (!this.producer) {
            throw new Error('Kafka producer not connected');
        }

        const payload = JSON.stringify(event.toJSON());

        try {
            await this.producer.send({
                topic,
                messages: [
                    {
                        key: options?.key || event.aggregateId,
                        value: payload,
                        partition: options?.partition,
                        headers: {
                            'event-type': event.type,
                            'correlation-id': event.correlationId,
                            'event-id': event.id,
                            ...options?.headers,
                        },
                        timestamp: event.timestamp.getTime().toString(),
                    },
                ],
            });

            this.logger.debug({
                topic,
                eventType: event.type,
                eventId: event.id,
            }, 'Event published to Kafka');
        } catch (error) {
            this.logger.error({ error, event }, 'Failed to publish event');
            throw error;
        }
    }

    async consume(
        topics: string[],
        handler: (event: DomainEvent) => Promise<void>,
        options?: {
            fromBeginning?: boolean;
            maxMessages?: number;
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
            partitionsConsumedConcurrently: options?.maxMessages || 1,
            eachMessage: async ({ message, topic, partition }) => {
                try {
                    if (!message.value) {
                        this.logger.warn({ topic, partition }, 'Empty message received');
                        return;
                    }

                    const content = JSON.parse(message.value.toString());
                    const event = this.createEvent(content);

                    // Process event
                    await handler(event);

                    this.logger.debug({
                        topic,
                        partition,
                        eventType: event.type,
                        eventId: event.id,
                        offset: message.offset,
                    }, 'Event processed successfully');
                } catch (error) {
                    this.logger.error({
                        error,
                        topic,
                        partition,
                        offset: message.offset,
                    }, 'Failed to process event');
                    
                    // In Kafka, we can't nack individual messages
                    // Error handling would need to be implemented differently
                    // e.g., send to DLQ or log for manual processing
                }
            },
        });

        this.logger.info({
            topics,
        }, 'Kafka consumer started');
    }

    private createEvent(data: any): DomainEvent {
        // Same factory method as RabbitMQ
        // ... (implementation omitted for brevity)
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
```

### 4. Event Processing Patterns

#### Event Sourcing with Stream Processing

```typescript
class EventProcessor {
    private eventStore: EventStore;
    private logger: Logger;

    constructor(eventStore: EventStore) {
        this.eventStore = eventStore;
        this.logger = createLogger({ service: 'event-processor' });
    }

    async processEventStream(
        aggregateId: string,
        startVersion: number = 0
    ): Promise<void> {
        const events = await this.eventStore.getEventsFromVersion(
            aggregateId,
            startVersion
        );

        for (const event of events) {
            try {
                // Process event
                await this.handleEvent(event);
                
                // Update projection
                await this.updateProjection(event);
                
                // Publish to downstream
                await this.publishProcessedEvent(event);
            } catch (error) {
                this.logger.error({
                    error,
                    eventId: event.id,
                    aggregateId,
                }, 'Failed to process event');
                throw error;
            }
        }
    }

    private async handleEvent(event: DomainEvent): Promise<void> {
        // Business logic for each event type
        switch (event.type) {
            case 'UserCreated':
                await this.handleUserCreated(event as UserCreatedEvent);
                break;
            case 'UserEmailChanged':
                await this.handleUserEmailChanged(event as UserEmailChangedEvent);
                break;
            // ... other event types
        }
    }

    private async updateProjection(event: DomainEvent): Promise<void> {
        // Update read model
        // Implementation depends on the projection
    }

    private async publishProcessedEvent(event: DomainEvent): Promise<void> {
        // Publish to event bus for other services
    }
}
```

#### Event Aggregation

```typescript
class EventAggregator {
    private events: DomainEvent[] = [];
    private windowMs: number;
    private maxSize: number;

    constructor(windowMs: number = 5000, maxSize: number = 1000) {
        this.windowMs = windowMs;
        this.maxSize = maxSize;
        this.startAggregation();
    }

    private startAggregation(): void {
        setInterval(() => {
            if (this.events.length > 0) {
                this.aggregateAndFlush();
            }
        }, this.windowMs);
    }

    addEvent(event: DomainEvent): void {
        this.events.push(event);
        if (this.events.length >= this.maxSize) {
            this.aggregateAndFlush();
        }
    }

    private async aggregateAndFlush(): Promise<void> {
        const events = [...this.events];
        this.events = [];

        try {
            // Aggregate events by type
            const grouped = this.groupEvents(events);
            
            // Process each group
            for (const [type, group] of grouped) {
                await this.processGroup(type, group);
            }
        } catch (error) {
            console.error('Failed to process aggregated events:', error);
            // Re-queue events?
        }
    }

    private groupEvents(events: DomainEvent[]): Map<string, DomainEvent[]> {
        const groups = new Map<string, DomainEvent[]>();
        for (const event of events) {
            if (!groups.has(event.type)) {
                groups.set(event.type, []);
            }
            groups.get(event.type)!.push(event);
        }
        return groups;
    }

    private async processGroup(type: string, events: DomainEvent[]): Promise<void> {
        // Process aggregated events
        console.log(`Processing ${events.length} events of type ${type}`);
        // Implementation depends on business logic
    }
}
```

### 5. Eventual Consistency

#### Saga Pattern Implementation

```typescript
class SagaOrchestrator {
    private steps: SagaStep[] = [];
    private logger: Logger;

    constructor() {
        this.logger = createLogger({ service: 'saga' });
    }

    addStep(step: SagaStep): void {
        this.steps.push(step);
    }

    async execute(context: SagaContext): Promise<SagaResult> {
        const executedSteps: string[] = [];
        
        try {
            for (const step of this.steps) {
                this.logger.info({
                    step: step.name,
                    context,
                }, 'Executing saga step');

                await step.execute(context);
                executedSteps.push(step.name);
            }

            return {
                success: true,
                context,
            };
        } catch (error) {
            this.logger.error({
                error,
                executedSteps,
            }, 'Saga failed, starting compensation');

            // Compensate in reverse order
            for (const step of this.steps) {
                if (executedSteps.includes(step.name)) {
                    await step.compensate(context);
                }
            }

            return {
                success: false,
                error: error instanceof Error ? error.message : String(error),
            };
        }
    }
}

interface SagaStep {
    name: string;
    execute: (context: SagaContext) => Promise<void>;
    compensate: (context: SagaContext) => Promise<void>;
}

interface SagaContext {
    [key: string]: any;
}

interface SagaResult {
    success: boolean;
    context?: SagaContext;
    error?: string;
}
```

### 6. Key Takeaways

1. **Events are Immutable Facts:**
   - Events represent something that happened
   - Never change or delete events
   - Add new events for corrections

2. **Event-Driven Architecture Benefits:**
   - Loose coupling between services
   - Scalability through asynchronous processing
   - Resilience through event replay
   - Flexibility to add new consumers

3. **Event Design Best Practices:**
   - Use past tense names (UserCreated, TaskCompleted)
   - Include correlation IDs for tracing
   - Version events for evolution
   - Keep events small and focused

4. **Broker Selection:**
   - RabbitMQ: Low latency, complex routing
   - Kafka: High throughput, event streaming
   - SQS: Simple, AWS integrated
   - NATS: Lightweight, high performance

5. **Error Handling:**
   - Implement DLQ (Dead Letter Queue)
   - Retry with exponential backoff
   - Monitor event processing lag
   - Have manual intervention process

6. **Eventual Consistency:**
   - Accept that read models may lag
   - Use sagas for distributed transactions
   - Provide status updates to users
   - Design for compensation

---

This primer provides a comprehensive understanding of event-driven architecture. EDA enables building highly scalable, resilient, and flexible systems that can evolve over time.
