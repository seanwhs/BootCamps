# Primer 4: Understanding CQRS & Event Sourcing

## A Deep Dive into Event-Driven Architecture

Welcome to the fourth primer! This is a comprehensive deep dive into CQRS (Command Query Responsibility Segregation) and Event Sourcing - two powerful patterns that work together to build scalable, auditable, and flexible systems. Think of this like running a restaurant with two separate systems: one for taking orders (commands) and one for reporting sales (queries), with a complete history of every transaction (event sourcing).

### 1. The Big Picture

#### Traditional CRUD vs CQRS + Event Sourcing

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  TRADITIONAL CRUD ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Application Layer                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Same Model for Reads and Writes                                    │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  User { id, name, email, createdAt, updatedAt, ... }       │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Single Database                                                   │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  users table: id, name, email, created_at, updated_at      │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Issues:                                                                    │
│  • Writes and reads use same model (not optimized)                         │
│  • No history of changes                                                   │
│  • Hard to audit                                                           │
│  • Coupled to database schema                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                  CQRS + EVENT SOURCING ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────┐    ┌──────────────────────────────────┐  │
│  │    COMMAND SIDE (Write)      │    │    QUERY SIDE (Read)             │  │
│  │  ┌────────────────────────┐  │    │  ┌────────────────────────────┐  │  │
│  │  │ Commands:              │  │    │  │ Queries:                   │  │  │
│  │  │  • CreateUser          │  │    │  │  • GetUserById             │  │  │
│  │  │  • UpdateUser          │  │    │  │  • GetUserByEmail          │  │  │
│  │  │  • DeleteUser          │  │    │  │  • GetUserTasks            │  │  │
│  │  └────────────────────────┘  │    │  └────────────────────────────┘  │  │
│  │  ┌────────────────────────┐  │    │  ┌────────────────────────────┐  │  │
│  │  │ Domain Logic           │  │    │  │ Read Models:              │  │  │
│  │  │  • Validation          │  │    │  │  • Denormalized tables    │  │  │
│  │  │  • Business Rules      │  │    │  │  • Optimized for reads    │  │  │
│  │  │  • Event Generation    │  │    │  │  • Multiple views         │  │  │
│  │  └────────────────────────┘  │    │  └────────────────────────────┘  │  │
│  └──────────────────────────────┘    └──────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     EVENT STORE                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  Events (Immutable Log of All Changes):                     │   │   │
│  │  │  1. UserCreated { id: 1, name: "John", email: "..." }      │   │   │
│  │  │  2. UserEmailChanged { id: 1, old: "...", new: "..." }     │   │   │
│  │  │  3. UserNameChanged { id: 1, old: "John", new: "John D." } │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Benefits:                                                                  │
│  • Complete audit trail                                                    │
│  • Optimized reads and writes                                              │
│  • Can rebuild state at any point in time                                 │
│  • Event replay for new read models                                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Event Sourcing Deep Dive

Event Sourcing is the practice of storing state changes as a sequence of events.

#### The Event Store

```typescript
// Event Store Schema
interface Event {
    id: string;
    aggregateId: string;
    eventType: string;
    version: number;
    data: any;
    metadata: {
        occurredAt: Date;
        userId?: string;
        correlationId?: string;
    };
}

// Example Event Store Implementation
class EventStore {
    async append(aggregateId: string, events: DomainEvent[]): Promise<void> {
        // Get current version
        const currentVersion = await this.getCurrentVersion(aggregateId);
        
        // Check for concurrency conflicts
        for (const event of events) {
            if (event.version <= currentVersion) {
                throw new ConcurrencyError(
                    `Expected version ${currentVersion + 1}, got ${event.version}`
                );
            }
        }

        // Store events in a transaction
        await this.db.transaction(async (trx) => {
            for (const event of events) {
                await trx('events').insert({
                    id: event.eventId,
                    aggregate_id: event.aggregateId,
                    event_type: event.eventType,
                    version: event.version,
                    data: event.toJSON().data,
                    metadata: JSON.stringify(event.metadata),
                    occurred_at: event.occurredAt,
                });
            }
        });
    }

    async getEvents(aggregateId: string): Promise<DomainEvent[]> {
        const rows = await this.db('events')
            .where('aggregate_id', aggregateId)
            .orderBy('version', 'asc');
        
        return rows.map(row => EventFactory.createFromData(row));
    }

    async getEventsFromVersion(
        aggregateId: string,
        version: number
    ): Promise<DomainEvent[]> {
        const rows = await this.db('events')
            .where('aggregate_id', aggregateId)
            .where('version', '>', version)
            .orderBy('version', 'asc');
        
        return rows.map(row => EventFactory.createFromData(row));
    }
}
```

#### Rebuilding State from Events

```typescript
class AggregateRoot {
    private events: DomainEvent[] = [];
    private currentVersion: number = 0;

    // Apply an event to the aggregate
    protected applyEvent(event: DomainEvent): void {
        // This is where business logic updates state
        switch (event.eventType) {
            case 'UserCreated':
                this.handleUserCreated(event);
                break;
            case 'UserEmailChanged':
                this.handleUserEmailChanged(event);
                break;
            case 'UserNameChanged':
                this.handleUserNameChanged(event);
                break;
        }
        this.currentVersion = event.version;
        this.events.push(event);
    }

    // Rebuild state from events
    static rebuild(events: DomainEvent[]): AggregateRoot {
        const aggregate = new this();
        for (const event of events) {
            aggregate.applyEvent(event);
        }
        return aggregate;
    }

    // Get pending events (for persistence)
    getUncommittedEvents(): DomainEvent[] {
        return this.events;
    }

    // Mark events as committed
    markEventsCommitted(): void {
        this.events = [];
    }
}

// Example User Aggregate
class UserAggregate extends AggregateRoot {
    private email: string = '';
    private name: string = '';
    private isActive: boolean = true;

    private handleUserCreated(event: UserCreatedEvent): void {
        this.email = event.data.email;
        this.name = event.data.name;
        this.isActive = true;
    }

    private handleUserEmailChanged(event: UserEmailChangedEvent): void {
        this.email = event.data.newEmail;
    }

    private handleUserNameChanged(event: UserNameChangedEvent): void {
        this.name = event.data.newName;
    }

    // Business method
    changeEmail(newEmail: string): void {
        if (newEmail === this.email) {
            throw new Error('New email must be different');
        }
        if (!this.isActive) {
            throw new Error('Cannot change email of inactive user');
        }
        
        const event = new UserEmailChangedEvent(
            this.id,
            this.email,
            newEmail,
            this.currentVersion + 1
        );
        this.applyEvent(event);
    }

    // Command method
    deactivate(): void {
        if (!this.isActive) {
            throw new Error('User already inactive');
        }
        
        const event = new UserDeactivatedEvent(
            this.id,
            this.currentVersion + 1
        );
        this.applyEvent(event);
    }
}
```

### 3. CQRS Deep Dive

CQRS separates the read and write models of your application.

#### Command Side (Write Model)

```typescript
// Commands - Represent user intention
interface Command {
    commandId: string;
    type: string;
    timestamp: Date;
    data: any;
}

class CreateUserCommand implements Command {
    commandId: string;
    type: 'CreateUser' = 'CreateUser';
    timestamp: Date;

    constructor(
        public readonly data: {
            email: string;
            name: string;
        }
    ) {
        this.commandId = randomUUID();
        this.timestamp = new Date();
    }
}

// Command Handler - Processes commands and produces events
class UserCommandHandler {
    constructor(
        private readonly eventStore: EventStore,
        private readonly commandValidator: CommandValidator
    ) {}

    async handleCreateUser(command: CreateUserCommand): Promise<void> {
        // 1. Validate command
        await this.commandValidator.validate(command);
        
        // 2. Check business rules
        const existingEvents = await this.eventStore.getEventsByEmail(
            command.data.email
        );
        if (existingEvents.length > 0) {
            throw new Error('User already exists');
        }

        // 3. Create events
        const event = new UserCreatedEvent(
            randomUUID(),
            command.data.email,
            command.data.name,
            1
        );

        // 4. Store events
        await this.eventStore.append(event.aggregateId, [event]);

        // 5. Publish events (for projections)
        await this.eventBus.publish(event);
    }
}

// Command Bus - Routes commands to handlers
class CommandBus {
    private handlers: Map<string, any> = new Map();

    register(commandType: string, handler: any): void {
        this.handlers.set(commandType, handler);
    }

    async dispatch(command: Command): Promise<void> {
        const handler = this.handlers.get(command.type);
        if (!handler) {
            throw new Error(`No handler for command: ${command.type}`);
        }
        return handler.handle(command);
    }
}
```

#### Query Side (Read Model)

```typescript
// Queries - Represent read operations
interface Query<T> {
    queryId: string;
    type: string;
    data: any;
}

class GetUserQuery implements Query<User> {
    queryId: string;
    type: 'GetUser' = 'GetUser';

    constructor(public readonly data: { userId: string }) {
        this.queryId = randomUUID();
    }
}

// Query Handler - Fetches data from read models
class UserQueryHandler {
    constructor(
        private readonly userReadModel: UserReadModel,
        private readonly userProjection: UserProjection
    ) {}

    async handleGetUser(query: GetUserQuery): Promise<User | null> {
        // Read from optimized read model
        return await this.userReadModel.findById(query.data.userId);
    }

    async handleGetUserByEmail(query: GetUserByEmailQuery): Promise<User | null> {
        return await this.userReadModel.findByEmail(query.data.email);
    }

    async handleGetActiveUsers(query: GetActiveUsersQuery): Promise<User[]> {
        return await this.userReadModel.findActiveUsers();
    }
}

// Read Models - Denormalized views optimized for queries
class UserReadModel {
    async findById(id: string): Promise<UserDTO | null> {
        const row = await this.db('user_read_model')
            .where('id', id)
            .first();
        return row ? this.mapToDTO(row) : null;
    }

    async findByEmail(email: string): Promise<UserDTO | null> {
        const row = await this.db('user_read_model')
            .where('email', email)
            .first();
        return row ? this.mapToDTO(row) : null;
    }

    async findActiveUsers(): Promise<UserDTO[]> {
        const rows = await this.db('user_read_model')
            .where('is_active', true)
            .orderBy('created_at', 'desc');
        return rows.map(row => this.mapToDTO(row));
    }

    private mapToDTO(row: any): UserDTO {
        return {
            id: row.id,
            email: row.email,
            name: row.name,
            isActive: row.is_active,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
        };
    }
}
```

### 4. Projections

Projections build read models from events.

```typescript
class UserProjection {
    async processEvent(event: DomainEvent): Promise<void> {
        switch (event.eventType) {
            case 'UserCreated':
                await this.handleUserCreated(event);
                break;
            case 'UserEmailChanged':
                await this.handleUserEmailChanged(event);
                break;
            case 'UserNameChanged':
                await this.handleUserNameChanged(event);
                break;
            case 'UserDeactivated':
                await this.handleUserDeactivated(event);
                break;
        }
    }

    private async handleUserCreated(event: UserCreatedEvent): Promise<void> {
        await this.db('user_read_model').insert({
            id: event.aggregateId,
            email: event.data.email,
            name: event.data.name,
            is_active: true,
            created_at: event.occurredAt,
            updated_at: event.occurredAt,
        });
    }

    private async handleUserEmailChanged(event: UserEmailChangedEvent): Promise<void> {
        await this.db('user_read_model')
            .where('id', event.aggregateId)
            .update({
                email: event.data.newEmail,
                updated_at: event.occurredAt,
            });
    }

    private async handleUserDeactivated(event: UserDeactivatedEvent): Promise<void> {
        await this.db('user_read_model')
            .where('id', event.aggregateId)
            .update({
                is_active: false,
                updated_at: event.occurredAt,
            });
    }

    // Rebuild from scratch
    async rebuild(): Promise<void> {
        // Clear read model
        await this.db('user_read_model').truncate();

        // Get all events
        const events = await this.eventStore.getEventsByType('User');
        
        // Process events in order
        for (const event of events) {
            await this.processEvent(event);
        }
    }
}
```

### 5. Event Versioning

As systems evolve, events may change structure.

```typescript
// Version 1: Simple event
class UserCreatedEventV1 {
    constructor(
        public readonly id: string,
        public readonly email: string,
        public readonly name: string
    ) {}
}

// Version 2: Added fields
class UserCreatedEventV2 {
    constructor(
        public readonly id: string,
        public readonly email: string,
        public readonly firstName: string,
        public readonly lastName: string,
        public readonly timezone: string
    ) {}
}

// Event Upcaster - Converts old events to new format
class UserCreatedEventUpcaster {
    upcast(event: any): any {
        // Version 1: Single name field
        if (!event.data.firstName && !event.data.lastName && event.data.name) {
            const [firstName, ...lastNameParts] = event.data.name.split(' ');
            return {
                ...event,
                version: 2,
                data: {
                    ...event.data,
                    firstName,
                    lastName: lastNameParts.join(' ') || '',
                    timezone: 'UTC', // Default value
                },
            };
        }
        return event;
    }
}
```

### 6. Common Patterns

#### Event Sourcing with Snapshotting

```typescript
class SnapshotManager {
    async getAggregate(id: string): Promise<AggregateRoot> {
        // Try to get snapshot
        const snapshot = await this.getSnapshot(id);
        
        if (snapshot) {
            // Get events after snapshot
            const events = await this.eventStore.getEventsFromVersion(
                id,
                snapshot.version
            );
            
            // Rebuild from snapshot
            const aggregate = this.rebuildFromSnapshot(snapshot);
            for (const event of events) {
                aggregate.applyEvent(event);
            }
            return aggregate;
        }

        // No snapshot - rebuild from all events
        const events = await this.eventStore.getEvents(id);
        return AggregateRoot.rebuild(events);
    }

    async takeSnapshot(aggregate: AggregateRoot): Promise<void> {
        const state = aggregate.getState();
        const version = aggregate.getVersion();
        
        await this.db('snapshots').insert({
            aggregate_id: aggregate.id,
            version: version,
            data: JSON.stringify(state),
            created_at: new Date(),
        });
    }
}
```

#### Eventual Consistency with Projections

```typescript
class EventualConsistencyManager {
    async processEvents(): Promise<void> {
        // Get unprocessed events
        const events = await this.eventStore.getUnprocessedEvents();
        
        // Process in batches
        const batchSize = 100;
        for (let i = 0; i < events.length; i += batchSize) {
            const batch = events.slice(i, i + batchSize);
            
            // Process events
            for (const event of batch) {
                await this.processEvent(event);
            }
            
            // Mark as processed
            await this.eventStore.markProcessed(batch.map(e => e.id));
            
            // Small delay to prevent overwhelming
            await new Promise(resolve => setTimeout(resolve, 100));
        }
    }
}
```

### 7. Benefits and Trade-offs

#### Benefits

1. **Audit Trail:** Complete history of changes
2. **Time Travel:** Can rebuild state at any point
3. **Event Replay:** Create new read models from events
4. **Scalability:** Separate read/write optimization
5. **Flexibility:** Easy to add new read models
6. **Temporal Queries:** Query state at any point in time

#### Trade-offs

1. **Complexity:** More moving parts
2. **Storage:** Event store grows indefinitely (use snapshots)
3. **Eventual Consistency:** Read models may lag
4. **Learning Curve:** Developers need to understand patterns
5. **Migration:** Event schema changes need upcasting

### 8. Real-World Example: Order Processing

```typescript
// Complete example of CQRS + Event Sourcing for orders

// 1. Events
class OrderCreatedEvent extends DomainEvent {
    constructor(
        aggregateId: string,
        public readonly customerId: string,
        public readonly items: OrderItem[],
        public readonly total: number
    ) {
        super('OrderCreated', aggregateId, 'Order', 1);
    }
}

class OrderStatusChangedEvent extends DomainEvent {
    constructor(
        aggregateId: string,
        public readonly oldStatus: OrderStatus,
        public readonly newStatus: OrderStatus,
        version: number
    ) {
        super('OrderStatusChanged', aggregateId, 'Order', version);
    }
}

// 2. Command
class CreateOrderCommand {
    constructor(
        public readonly customerId: string,
        public readonly items: { productId: string; quantity: number }[]
    ) {}
}

// 3. Command Handler
class OrderCommandHandler {
    async handleCreateOrder(command: CreateOrderCommand): Promise<void> {
        // Validate
        const customer = await this.customerService.getById(command.customerId);
        if (!customer) {
            throw new Error('Customer not found');
        }

        // Create events
        const orderId = randomUUID();
        const items = await this.getItemsDetails(command.items);
        const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

        const events = [
            new OrderCreatedEvent(orderId, command.customerId, items, total),
        ];

        // Store events
        await this.eventStore.append(orderId, events);

        // Publish events
        for (const event of events) {
            await this.eventBus.publish(event);
        }
    }
}

// 4. Read Model
class OrderReadModel {
    async getOrderDetails(orderId: string): Promise<OrderDetails> {
        return await this.db('order_read_model')
            .join('order_items', 'order_read_model.id', 'order_items.order_id')
            .where('order_read_model.id', orderId)
            .first();
    }

    async getCustomerOrders(customerId: string): Promise<OrderSummary[]> {
        return await this.db('order_read_model')
            .where('customer_id', customerId)
            .orderBy('created_at', 'desc');
    }
}

// 5. Projection
class OrderProjection {
    async processEvent(event: DomainEvent): Promise<void> {
        switch (event.eventType) {
            case 'OrderCreated':
                await this.handleOrderCreated(event);
                break;
            case 'OrderStatusChanged':
                await this.handleOrderStatusChanged(event);
                break;
        }
    }

    private async handleOrderCreated(event: OrderCreatedEvent): Promise<void> {
        await this.db('order_read_model').insert({
            id: event.aggregateId,
            customer_id: event.data.customerId,
            total: event.data.total,
            status: 'PENDING',
            created_at: event.occurredAt,
            updated_at: event.occurredAt,
        });

        for (const item of event.data.items) {
            await this.db('order_items').insert({
                order_id: event.aggregateId,
                product_id: item.productId,
                quantity: item.quantity,
                price: item.price,
            });
        }
    }
}
```

### 9. Key Takeaways

1. **CQRS Separates Reads and Writes:**
   - Commands: Write operations, business logic
   - Queries: Read operations, optimized for performance

2. **Event Sourcing Stores Changes as Events:**
   - Complete audit trail
   - Ability to replay events
   - Build projections for different views

3. **Eventual Consistency is Acceptable:**
   - Read models may lag behind write model
   - Good for non-critical data
   - Critical data can use synchronous updates

4. **Version Events:**
   - Events are immutable - never change them
   - Use upcasters for version evolution
   - Store version number with events

5. **Use Snapshots for Performance:**
   - Take snapshots periodically
   - Rebuild from snapshot + events
   - Reduces event replay time

6. **Event Store is Source of Truth:**
   - Everything else can be rebuilt from events
   - Read models are disposable
   - Only the event store needs to be backed up

---

This primer provides a comprehensive understanding of CQRS and Event Sourcing. These patterns, when used together, create highly scalable, auditable, and flexible systems that can evolve over time.
