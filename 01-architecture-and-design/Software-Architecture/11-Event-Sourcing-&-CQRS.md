# Phase 5, Part 1: Event Sourcing & CQRS

## Building Event-Driven Systems

Welcome to Phase 5! We're moving from traditional CRUD to event-driven architecture. Think of this like moving from taking a photo of a process to recording a video - instead of just storing the current state, we store every change that led to it. This gives us complete history, auditability, and the ability to replay events to rebuild state at any point in time.

### 1. The Target

**What we're building:** Event-sourced architecture with CQRS:
- Event store for recording all state changes
- Event sourcing pattern implementation
- CQRS (Command Query Responsibility Segregation) with read/write separation
- Node.js stream processing for events
- Event replay and projection building
- Read model materialization

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   │   ├── domain/
│   │   │   ├── events/                      # NEW: Domain events
│   │   │   │   ├── user-events.ts
│   │   │   │   ├── task-events.ts
│   │   │   │   └── event-bus.ts
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   └── application/
│   │       ├── commands/
│   │       ├── queries/
│   │       └── handlers/
│   │
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── event-store/                # NEW: Event store
│   │   │   │   ├── postgres/
│   │   │   │   │   ├── event-store.ts
│   │   │   │   │   └── migrations/
│   │   │   │   │       └── 003_event_store.sql
│   │   │   │   └── in-memory/
│   │   │   │       └── event-store.ts
│   │   │   ├── projections/                 # NEW: Projections
│   │   │   │   ├── user-projection.ts
│   │   │   │   └── task-projection.ts
│   │   │   └── read-models/                 # NEW: Read models
│   │   │       ├── user-read-model.ts
│   │   │       └── task-read-model.ts
│   │   └── di/
│   │       └── container.ts (updated)
│   └── server.ts
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│       └── event-sourcing.test.ts          # NEW: Event sourcing tests
│
└── infrastructure/
    └── terraform/
        └── event-store.tf                  # NEW: Event store infrastructure
```

### 2. The Concept: Event Sourcing & CQRS

**Event Sourcing:**
Instead of storing just the current state of an entity, we store every event that changed it. Like keeping a diary of everything that happened.

```
Traditional CRUD:
User { id: 1, name: "John", email: "john@example.com" }
Update → User { id: 1, name: "John Doe", email: "john@example.com" }
→ Last state only

Event Sourcing:
Event 1: UserCreated { id: 1, name: "John", email: "john@example.com" }
Event 2: UserNameChanged { id: 1, newName: "John Doe" }
→ Full history preserved
```

**CQRS (Command Query Responsibility Segregation):**
Separate models for writes and reads. Like having different teams for ordering (commands) and reporting (queries).

```
┌─────────────────────────────────────────────────────────────┐
│                         CQRS                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐          ┌─────────────────────────┐  │
│  │   Command Side  │          │    Query Side           │  │
│  │   (Write)       │          │    (Read)               │  │
│  ├─────────────────┤          ├─────────────────────────┤  │
│  │ • Validate      │          │ • Optimized for reads   │  │
│  │ • Business      │          │ • Denormalized          │  │
│  │   logic         │          │ • Multiple projections  │  │
│  │ • Event         │          │ • Fast queries          │  │
│  │   generation    │          │                         │  │
│  └─────────────────┘          └─────────────────────────┘  │
│         │                              ▲                    │
│         ▼                              │                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Event Store                           │   │
│  │  (Source of truth - immutable event log)           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. The Implementation

#### Step 1: Domain Events

**File:** `packages/gateway/src/core/domain/events/user-events.ts`

```typescript
import { randomUUID } from 'crypto';

/**
 * Base Domain Event
 * 
 * All domain events extend this base class.
 * Events are immutable and represent facts that happened in the system.
 */
export abstract class DomainEvent {
  public readonly eventId: string;
  public readonly eventType: string;
  public readonly aggregateId: string;
  public readonly aggregateType: string;
  public readonly occurredAt: Date;
  public readonly version: number;

  constructor(
    eventType: string,
    aggregateId: string,
    aggregateType: string,
    version: number,
    eventId?: string
  ) {
    this.eventId = eventId || randomUUID();
    this.eventType = eventType;
    this.aggregateId = aggregateId;
    this.aggregateType = aggregateType;
    this.occurredAt = new Date();
    this.version = version;
  }

  /**
   * Convert event to plain object for serialization
   */
  abstract toJSON(): Record<string, any>;
}

/**
 * User Events
 */
export class UserCreatedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly email: string,
    public readonly username: string,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly passwordHash: string,
    version: number = 1
  ) {
    super('UserCreated', aggregateId, 'User', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        email: this.email,
        username: this.username,
        firstName: this.firstName,
        lastName: this.lastName,
        passwordHash: this.passwordHash,
      },
    };
  }
}

export class UserProfileUpdatedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly firstName: string,
    public readonly lastName: string,
    version: number
  ) {
    super('UserProfileUpdated', aggregateId, 'User', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        firstName: this.firstName,
        lastName: this.lastName,
      },
    };
  }
}

export class UserEmailChangedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly oldEmail: string,
    public readonly newEmail: string,
    version: number
  ) {
    super('UserEmailChanged', aggregateId, 'User', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        oldEmail: this.oldEmail,
        newEmail: this.newEmail,
      },
    };
  }
}

export class UserDeactivatedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly reason?: string,
    version: number = 1
  ) {
    super('UserDeactivated', aggregateId, 'User', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        reason: this.reason,
      },
    };
  }
}

export class UserReactivatedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    version: number = 1
  ) {
    super('UserReactivated', aggregateId, 'User', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {},
    };
  }
}

export class UserLoggedInEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly ipAddress?: string,
    public readonly userAgent?: string,
    version: number = 1
  ) {
    super('UserLoggedIn', aggregateId, 'User', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        ipAddress: this.ipAddress,
        userAgent: this.userAgent,
      },
    };
  }
}

/**
 * Event Factory
 * 
 * Creates domain events from stored event data
 */
export class EventFactory {
  static createFromData(data: any): DomainEvent {
    const { eventType, aggregateId, aggregateType, version, occurredAt, data: eventData } = data;

    switch (eventType) {
      case 'UserCreated':
        return new UserCreatedEvent(
          aggregateId,
          eventData.email,
          eventData.username,
          eventData.firstName,
          eventData.lastName,
          eventData.passwordHash,
          version
        );
      case 'UserProfileUpdated':
        return new UserProfileUpdatedEvent(
          aggregateId,
          eventData.firstName,
          eventData.lastName,
          version
        );
      case 'UserEmailChanged':
        return new UserEmailChangedEvent(
          aggregateId,
          eventData.oldEmail,
          eventData.newEmail,
          version
        );
      case 'UserDeactivated':
        return new UserDeactivatedEvent(
          aggregateId,
          eventData.reason,
          version
        );
      case 'UserReactivated':
        return new UserReactivatedEvent(
          aggregateId,
          version
        );
      case 'UserLoggedIn':
        return new UserLoggedInEvent(
          aggregateId,
          eventData.ipAddress,
          eventData.userAgent,
          version
        );
      default:
        throw new Error(`Unknown event type: ${eventType}`);
    }
  }
}
```

**File:** `packages/gateway/src/core/domain/events/task-events.ts`

```typescript
import { DomainEvent } from './user-events.js';
import { TaskStatus, TaskPriority } from '../entities/task.entity.js';

export class TaskCreatedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly title: string,
    public readonly description: string,
    public readonly userId: string,
    public readonly priority: TaskPriority,
    public readonly dueDate?: Date,
    version: number = 1
  ) {
    super('TaskCreated', aggregateId, 'Task', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        title: this.title,
        description: this.description,
        userId: this.userId,
        priority: this.priority,
        dueDate: this.dueDate?.toISOString(),
      },
    };
  }
}

export class TaskStartedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    version: number
  ) {
    super('TaskStarted', aggregateId, 'Task', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {},
    };
  }
}

export class TaskCompletedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly completedAt: Date,
    version: number
  ) {
    super('TaskCompleted', aggregateId, 'Task', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        completedAt: this.completedAt.toISOString(),
      },
    };
  }
}

export class TaskFailedEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly reason?: string,
    version: number = 1
  ) {
    super('TaskFailed', aggregateId, 'Task', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        reason: this.reason,
      },
    };
  }
}

export class TaskCancelledEvent extends DomainEvent {
  constructor(
    public readonly aggregateId: string,
    public readonly reason?: string,
    version: number = 1
  ) {
    super('TaskCancelled', aggregateId, 'Task', version);
  }

  toJSON(): Record<string, any> {
    return {
      eventId: this.eventId,
      eventType: this.eventType,
      aggregateId: this.aggregateId,
      aggregateType: this.aggregateType,
      occurredAt: this.occurredAt.toISOString(),
      version: this.version,
      data: {
        reason: this.reason,
      },
    };
  }
}
```

#### Step 2: Event Store Interface

**File:** `packages/gateway/src/core/domain/repositories/event-store.port.ts`

```typescript
import { DomainEvent } from '../events/user-events.js';

/**
 * Event Store Port
 * 
 * Interface for storing and retrieving domain events.
 * This is the backbone of event sourcing.
 */
export interface IEventStore {
  /**
   * Append events to the event store
   */
  appendEvents(aggregateId: string, events: DomainEvent[]): Promise<void>;

  /**
   * Get all events for an aggregate
   */
  getEvents(aggregateId: string): Promise<DomainEvent[]>;

  /**
   * Get events for an aggregate starting from a version
   */
  getEventsFromVersion(aggregateId: string, version: number): Promise<DomainEvent[]>;

  /**
   * Get all events of a specific type
   */
  getEventsByType(eventType: string, limit?: number): Promise<DomainEvent[]>;

  /**
   * Get events for a time range
   */
  getEventsByTimeRange(startDate: Date, endDate: Date): Promise<DomainEvent[]>;

  /**
   * Subscribe to events
   */
  subscribe(subscriber: (event: DomainEvent) => Promise<void>): void;

  /**
   * Get latest event for an aggregate
   */
  getLatestEvent(aggregateId: string): Promise<DomainEvent | null>;

  /**
   * Check if an event already exists (idempotency)
   */
  eventExists(eventId: string): Promise<boolean>;
}

export const EVENT_STORE = Symbol('EVENT_STORE');
```

#### Step 3: Postgres Event Store

**File:** `packages/gateway/src/infrastructure/adapters/event-store/postgres/event-store.ts`

```typescript
import { PoolClient } from 'pg';
import { DomainEvent } from '../../../../core/domain/events/user-events.js';
import { EventFactory } from '../../../../core/domain/events/user-events.js';
import { IEventStore } from '../../../../core/domain/repositories/event-store.port.js';
import { postgresConnection } from '../../persistence/postgres/connection.js';
import { createChildLogger } from '../../../../logger.js';

/**
 * PostgreSQL Event Store
 * 
 * Implements the Event Store port using PostgreSQL.
 * 
 * Key features:
 * 1. Append-only event storage
 * 2. Version tracking for concurrency control
 * 3. Event subscription for projections
 * 4. Snapshot support (optional)
 */
export class PostgresEventStore implements IEventStore {
  private readonly logger = createChildLogger({ module: 'PostgresEventStore' });
  private subscribers: Array<(event: DomainEvent) => Promise<void>> = [];

  constructor() {
    // Ensure the event table exists
    this.ensureTable();
  }

  /**
   * Ensure the event store table exists
   */
  private async ensureTable(): Promise<void> {
    // The migration script will create the table
    // This is just a safety check
    try {
      await postgresConnection.query(`
        CREATE TABLE IF NOT EXISTS events (
          id BIGSERIAL PRIMARY KEY,
          event_id UUID NOT NULL UNIQUE,
          aggregate_id UUID NOT NULL,
          aggregate_type VARCHAR(50) NOT NULL,
          event_type VARCHAR(50) NOT NULL,
          version INTEGER NOT NULL,
          occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
          data JSONB NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
        )
      `);

      await postgresConnection.query(`
        CREATE INDEX IF NOT EXISTS idx_events_aggregate_id 
        ON events(aggregate_id, version)
      `);

      await postgresConnection.query(`
        CREATE INDEX IF NOT EXISTS idx_events_event_type 
        ON events(event_type)
      `);

      await postgresConnection.query(`
        CREATE INDEX IF NOT EXISTS idx_events_occurred_at 
        ON events(occurred_at)
      `);
    } catch (error) {
      this.logger.warn({ error }, 'Event store table may already exist');
    }
  }

  /**
   * Append events to the store
   */
  async appendEvents(aggregateId: string, events: DomainEvent[]): Promise<void> {
    if (events.length === 0) return;

    this.logger.debug({ aggregateId, count: events.length }, 'Appending events');

    // Sort events by version
    const sortedEvents = [...events].sort((a, b) => a.version - b.version);

    // Check if aggregate already exists and get current version
    const currentVersion = await this.getCurrentVersion(aggregateId);
    const firstEvent = sortedEvents[0];

    if (firstEvent.version <= currentVersion) {
      throw new Error(
        `Concurrency conflict: Expected version ${currentVersion + 1}, got ${firstEvent.version}`
      );
    }

    // Check for duplicate event IDs
    for (const event of sortedEvents) {
      const exists = await this.eventExists(event.eventId);
      if (exists) {
        throw new Error(`Duplicate event: ${event.eventId}`);
      }
    }

    // Insert events in a transaction
    await postgresConnection.transaction(async (client) => {
      for (const event of sortedEvents) {
        await this.insertEvent(client, event);
      }
    });

    this.logger.info({ aggregateId, count: events.length }, 'Events appended');

    // Notify subscribers
    for (const event of sortedEvents) {
      await this.notifySubscribers(event);
    }
  }

  /**
   * Insert a single event
   */
  private async insertEvent(client: PoolClient, event: DomainEvent): Promise<void> {
    const query = `
      INSERT INTO events (
        event_id, aggregate_id, aggregate_type,
        event_type, version, occurred_at, data
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    `;

    const data = event.toJSON();
    const params = [
      event.eventId,
      event.aggregateId,
      event.aggregateType,
      event.eventType,
      event.version,
      event.occurredAt,
      data,
    ];

    await client.query(query, params);
  }

  /**
   * Get current version of an aggregate
   */
  private async getCurrentVersion(aggregateId: string): Promise<number> {
    const query = `
      SELECT COALESCE(MAX(version), 0) as version
      FROM events
      WHERE aggregate_id = $1
    `;

    const result = await postgresConnection.query<{ version: number }>(query, [aggregateId]);
    return result.rows[0]?.version || 0;
  }

  /**
   * Get all events for an aggregate
   */
  async getEvents(aggregateId: string): Promise<DomainEvent[]> {
    const query = `
      SELECT * FROM events
      WHERE aggregate_id = $1
      ORDER BY version ASC
    `;

    const result = await postgresConnection.query<any>(query, [aggregateId]);
    return result.rows.map(row => this.deserializeEvent(row));
  }

  /**
   * Get events from a specific version
   */
  async getEventsFromVersion(aggregateId: string, version: number): Promise<DomainEvent[]> {
    const query = `
      SELECT * FROM events
      WHERE aggregate_id = $1 AND version > $2
      ORDER BY version ASC
    `;

    const result = await postgresConnection.query<any>(query, [aggregateId, version]);
    return result.rows.map(row => this.deserializeEvent(row));
  }

  /**
   * Get events by type
   */
  async getEventsByType(eventType: string, limit: number = 1000): Promise<DomainEvent[]> {
    const query = `
      SELECT * FROM events
      WHERE event_type = $1
      ORDER BY occurred_at DESC
      LIMIT $2
    `;

    const result = await postgresConnection.query<any>(query, [eventType, limit]);
    return result.rows.map(row => this.deserializeEvent(row));
  }

  /**
   * Get events by time range
   */
  async getEventsByTimeRange(startDate: Date, endDate: Date): Promise<DomainEvent[]> {
    const query = `
      SELECT * FROM events
      WHERE occurred_at BETWEEN $1 AND $2
      ORDER BY occurred_at ASC
    `;

    const result = await postgresConnection.query<any>(query, [startDate, endDate]);
    return result.rows.map(row => this.deserializeEvent(row));
  }

  /**
   * Get latest event for an aggregate
   */
  async getLatestEvent(aggregateId: string): Promise<DomainEvent | null> {
    const query = `
      SELECT * FROM events
      WHERE aggregate_id = $1
      ORDER BY version DESC
      LIMIT 1
    `;

    const result = await postgresConnection.query<any>(query, [aggregateId]);
    if (result.rows.length === 0) return null;
    return this.deserializeEvent(result.rows[0]);
  }

  /**
   * Check if event exists
   */
  async eventExists(eventId: string): Promise<boolean> {
    const query = 'SELECT 1 FROM events WHERE event_id = $1 LIMIT 1';
    const result = await postgresConnection.query(query, [eventId]);
    return result.rows.length > 0;
  }

  /**
   * Subscribe to events
   */
  subscribe(subscriber: (event: DomainEvent) => Promise<void>): void {
    this.subscribers.push(subscriber);
    this.logger.debug({ totalSubscribers: this.subscribers.length }, 'Subscriber added');
  }

  /**
   * Notify subscribers of new events
   */
  private async notifySubscribers(event: DomainEvent): Promise<void> {
    const results = await Promise.allSettled(
      this.subscribers.map(subscriber => subscriber(event))
    );

    const failures = results.filter(r => r.status === 'rejected');
    if (failures.length > 0) {
      this.logger.warn({
        failures: failures.length,
        eventId: event.eventId,
      }, 'Some subscribers failed to process event');
    }
  }

  /**
   * Deserialize event from database row
   */
  private deserializeEvent(row: any): DomainEvent {
    // The data column contains the full event data
    const eventData = row.data;
    
    // If the data doesn't have eventId, use the column
    if (!eventData.eventId) {
      eventData.eventId = row.event_id;
    }
    
    return EventFactory.createFromData({
      eventType: row.event_type,
      aggregateId: row.aggregate_id,
      aggregateType: row.aggregate_type,
      version: row.version,
      occurredAt: row.occurred_at,
      data: eventData,
    });
  }

  /**
   * Get event store statistics
   */
  async getStats(): Promise<{
    totalEvents: number;
    aggregates: number;
    eventTypes: Record<string, number>;
  }> {
    const totalQuery = 'SELECT COUNT(*) as count FROM events';
    const totalResult = await postgresConnection.query<{ count: string }>(totalQuery);

    const aggregateQuery = 'SELECT COUNT(DISTINCT aggregate_id) as count FROM events';
    const aggregateResult = await postgresConnection.query<{ count: string }>(aggregateQuery);

    const typesQuery = `
      SELECT event_type, COUNT(*) as count
      FROM events
      GROUP BY event_type
    `;
    const typesResult = await postgresConnection.query<{ event_type: string; count: string }>(typesQuery);

    const eventTypes: Record<string, number> = {};
    for (const row of typesResult.rows) {
      eventTypes[row.event_type] = parseInt(row.count, 10);
    }

    return {
      totalEvents: parseInt(totalResult.rows[0]?.count || '0', 10),
      aggregates: parseInt(aggregateResult.rows[0]?.count || '0', 10),
      eventTypes,
    };
  }
}
```

#### Step 4: Event Store Migration

**File:** `packages/gateway/src/infrastructure/adapters/event-store/postgres/migrations/003_event_store.sql`

```sql
-- 003_event_store.sql
-- Event Store Schema

-- Events table - append-only event log
CREATE TABLE IF NOT EXISTS events (
    id BIGSERIAL PRIMARY KEY,
    event_id UUID NOT NULL UNIQUE,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    version INTEGER NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_events_aggregate_id_version 
ON events(aggregate_id, version);

CREATE INDEX IF NOT EXISTS idx_events_event_type 
ON events(event_type);

CREATE INDEX IF NOT EXISTS idx_events_occurred_at 
ON events(occurred_at DESC);

CREATE INDEX IF NOT EXISTS idx_events_aggregate_type 
ON events(aggregate_type);

-- GIN index for JSONB queries (if needed)
CREATE INDEX IF NOT EXISTS idx_events_data 
ON events USING GIN(data);

-- Comments
COMMENT ON TABLE events IS 'Event sourcing event log';
COMMENT ON COLUMN events.event_id IS 'Unique event ID (idempotency key)';
COMMENT ON COLUMN events.aggregate_id IS 'Aggregate ID (entity ID)';
COMMENT ON COLUMN events.aggregate_type IS 'Type of aggregate (User, Task, etc.)';
COMMENT ON COLUMN events.event_type IS 'Type of event (UserCreated, TaskCompleted, etc.)';
COMMENT ON COLUMN events.version IS 'Aggregate version after this event';
COMMENT ON COLUMN events.data IS 'Event data as JSON';

-- Function for event notifications (for event bus)
CREATE OR REPLACE FUNCTION notify_event_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('event_inserted', row_to_json(NEW)::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for event notifications
CREATE TRIGGER event_insert_trigger
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION notify_event_insert();

-- Snapshot table (optional - for performance)
CREATE TABLE IF NOT EXISTS snapshots (
    aggregate_id UUID PRIMARY KEY,
    aggregate_type VARCHAR(50) NOT NULL,
    version INTEGER NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE snapshots IS 'Snapshots for fast aggregate loading';
COMMENT ON COLUMN snapshots.aggregate_id IS 'Aggregate ID';
COMMENT ON COLUMN snapshots.version IS 'Version at snapshot time';
COMMENT ON COLUMN snapshots.data IS 'Aggregate state snapshot';

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_snapshots_updated_at
BEFORE UPDATE ON snapshots
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

#### Step 5: Projections

**File:** `packages/gateway/src/infrastructure/adapters/projections/user-projection.ts`

```typescript
import { DomainEvent } from '../../../core/domain/events/user-events.js';
import { postgresConnection } from '../../persistence/postgres/connection.js';
import { createChildLogger } from '../../../logger.js';

/**
 * User Projection
 * 
 * Builds and maintains a read model for users.
 * 
 * A projection listens to events and builds denormalized views
 * optimized for querying.
 */
export class UserProjection {
  private readonly logger = createChildLogger({ module: 'UserProjection' });
  private isRunning = false;

  /**
   * Handle events and update the read model
   */
  async handleEvent(event: DomainEvent): Promise<void> {
    this.logger.debug({
      eventType: event.eventType,
      aggregateId: event.aggregateId,
    }, 'Processing user event');

    try {
      switch (event.eventType) {
        case 'UserCreated':
          await this.handleUserCreated(event);
          break;
        case 'UserProfileUpdated':
          await this.handleUserProfileUpdated(event);
          break;
        case 'UserEmailChanged':
          await this.handleUserEmailChanged(event);
          break;
        case 'UserDeactivated':
          await this.handleUserDeactivated(event);
          break;
        case 'UserReactivated':
          await this.handleUserReactivated(event);
          break;
        case 'UserLoggedIn':
          await this.handleUserLoggedIn(event);
          break;
        default:
          // Ignore other events
          break;
      }
    } catch (error) {
      this.logger.error({
        error,
        eventType: event.eventType,
        aggregateId: event.aggregateId,
      }, 'Failed to process event for projection');
      throw error;
    }
  }

  /**
   * Handle UserCreated event
   */
  private async handleUserCreated(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      INSERT INTO user_read_model (
        id, email, username, first_name, last_name,
        password_hash, is_active, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        username = EXCLUDED.username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        password_hash = EXCLUDED.password_hash,
        is_active = EXCLUDED.is_active,
        updated_at = EXCLUDED.updated_at
    `;

    await postgresConnection.query(query, [
      event.aggregateId,
      data.email,
      data.username,
      data.firstName,
      data.lastName,
      data.passwordHash,
      true,
      event.occurredAt,
      event.occurredAt,
    ]);

    this.logger.debug({ userId: event.aggregateId }, 'User read model created');
  }

  /**
   * Handle UserProfileUpdated event
   */
  private async handleUserProfileUpdated(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      UPDATE user_read_model
      SET first_name = $1, last_name = $2, updated_at = $3
      WHERE id = $4
    `;

    await postgresConnection.query(query, [
      data.firstName,
      data.lastName,
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ userId: event.aggregateId }, 'User read model updated');
  }

  /**
   * Handle UserEmailChanged event
   */
  private async handleUserEmailChanged(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      UPDATE user_read_model
      SET email = $1, updated_at = $2
      WHERE id = $3
    `;

    await postgresConnection.query(query, [
      data.newEmail,
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ userId: event.aggregateId }, 'User email updated in read model');
  }

  /**
   * Handle UserDeactivated event
   */
  private async handleUserDeactivated(event: DomainEvent): Promise<void> {
    const query = `
      UPDATE user_read_model
      SET is_active = false, updated_at = $1
      WHERE id = $2
    `;

    await postgresConnection.query(query, [
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ userId: event.aggregateId }, 'User deactivated in read model');
  }

  /**
   * Handle UserReactivated event
   */
  private async handleUserReactivated(event: DomainEvent): Promise<void> {
    const query = `
      UPDATE user_read_model
      SET is_active = true, updated_at = $1
      WHERE id = $2
    `;

    await postgresConnection.query(query, [
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ userId: event.aggregateId }, 'User reactivated in read model');
  }

  /**
   * Handle UserLoggedIn event
   */
  private async handleUserLoggedIn(event: DomainEvent): Promise<void> {
    // Update last login timestamp
    const query = `
      UPDATE user_read_model
      SET last_login_at = $1, updated_at = $2
      WHERE id = $3
    `;

    await postgresConnection.query(query, [
      event.occurredAt,
      event.occurredAt,
      event.aggregateId,
    ]);

    // Optionally log login history
    const data = event.toJSON().data;
    const historyQuery = `
      INSERT INTO user_login_history (
        user_id, ip_address, user_agent, login_at
      ) VALUES ($1, $2, $3, $4)
    `;

    await postgresConnection.query(historyQuery, [
      event.aggregateId,
      data.ipAddress,
      data.userAgent,
      event.occurredAt,
    ]);

    this.logger.debug({ userId: event.aggregateId }, 'User login recorded');
  }

  /**
   * Rebuild the read model from events
   */
  async rebuild(): Promise<void> {
    this.logger.info('Rebuilding user read model from events');

    // Start fresh
    await postgresConnection.query('TRUNCATE TABLE user_read_model CASCADE');
    await postgresConnection.query('TRUNCATE TABLE user_login_history CASCADE');

    // Get all user events
    const query = `
      SELECT * FROM events
      WHERE aggregate_type = 'User'
      ORDER BY aggregate_id, version ASC
    `;

    const result = await postgresConnection.query<any>(query);
    const events = result.rows;

    this.logger.info({ totalEvents: events.length }, 'Found user events');

    // Process events in order
    let processed = 0;
    for (const row of events) {
      const event = EventFactory.createFromData(row);
      await this.handleEvent(event);
      processed++;
    }

    this.logger.info({ processed }, 'User read model rebuild complete');
  }
}
```

**File:** `packages/gateway/src/infrastructure/adapters/projections/task-projection.ts`

```typescript
import { DomainEvent } from '../../../core/domain/events/user-events.js';
import { postgresConnection } from '../../persistence/postgres/connection.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Task Projection
 * 
 * Builds and maintains a read model for tasks.
 */
export class TaskProjection {
  private readonly logger = createChildLogger({ module: 'TaskProjection' });

  async handleEvent(event: DomainEvent): Promise<void> {
    this.logger.debug({
      eventType: event.eventType,
      aggregateId: event.aggregateId,
    }, 'Processing task event');

    try {
      switch (event.eventType) {
        case 'TaskCreated':
          await this.handleTaskCreated(event);
          break;
        case 'TaskStarted':
          await this.handleTaskStarted(event);
          break;
        case 'TaskCompleted':
          await this.handleTaskCompleted(event);
          break;
        case 'TaskFailed':
          await this.handleTaskFailed(event);
          break;
        case 'TaskCancelled':
          await this.handleTaskCancelled(event);
          break;
        default:
          break;
      }
    } catch (error) {
      this.logger.error({
        error,
        eventType: event.eventType,
        aggregateId: event.aggregateId,
      }, 'Failed to process task event');
      throw error;
    }
  }

  private async handleTaskCreated(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      INSERT INTO task_read_model (
        id, title, description, user_id, status,
        priority, due_date, created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      ON CONFLICT (id) DO UPDATE SET
        title = EXCLUDED.title,
        description = EXCLUDED.description,
        status = EXCLUDED.status,
        priority = EXCLUDED.priority,
        due_date = EXCLUDED.due_date,
        updated_at = EXCLUDED.updated_at
    `;

    await postgresConnection.query(query, [
      event.aggregateId,
      data.title,
      data.description,
      data.userId,
      'pending',
      data.priority,
      data.dueDate || null,
      event.occurredAt,
      event.occurredAt,
    ]);

    this.logger.debug({ taskId: event.aggregateId }, 'Task read model created');
  }

  private async handleTaskStarted(event: DomainEvent): Promise<void> {
    const query = `
      UPDATE task_read_model
      SET status = 'in_progress', updated_at = $1
      WHERE id = $2
    `;

    await postgresConnection.query(query, [event.occurredAt, event.aggregateId]);
    this.logger.debug({ taskId: event.aggregateId }, 'Task started in read model');
  }

  private async handleTaskCompleted(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      UPDATE task_read_model
      SET status = 'completed', 
          completed_at = $1,
          updated_at = $2
      WHERE id = $3
    `;

    await postgresConnection.query(query, [
      new Date(data.completedAt),
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ taskId: event.aggregateId }, 'Task completed in read model');
  }

  private async handleTaskFailed(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      UPDATE task_read_model
      SET status = 'failed',
          failure_reason = $1,
          updated_at = $2
      WHERE id = $3
    `;

    await postgresConnection.query(query, [
      data.reason || null,
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ taskId: event.aggregateId }, 'Task failed in read model');
  }

  private async handleTaskCancelled(event: DomainEvent): Promise<void> {
    const data = event.toJSON().data;
    const query = `
      UPDATE task_read_model
      SET status = 'cancelled',
          cancellation_reason = $1,
          updated_at = $2
      WHERE id = $3
    `;

    await postgresConnection.query(query, [
      data.reason || null,
      event.occurredAt,
      event.aggregateId,
    ]);

    this.logger.debug({ taskId: event.aggregateId }, 'Task cancelled in read model');
  }

  async rebuild(): Promise<void> {
    this.logger.info('Rebuilding task read model from events');

    await postgresConnection.query('TRUNCATE TABLE task_read_model CASCADE');

    const query = `
      SELECT * FROM events
      WHERE aggregate_type = 'Task'
      ORDER BY aggregate_id, version ASC
    `;

    const result = await postgresConnection.query<any>(query);
    const events = result.rows;

    this.logger.info({ totalEvents: events.length }, 'Found task events');

    let processed = 0;
    for (const row of events) {
      const event = EventFactory.createFromData(row);
      await this.handleEvent(event);
      processed++;
    }

    this.logger.info({ processed }, 'Task read model rebuild complete');
  }
}
```

#### Step 6: Event Bus

**File:** `packages/gateway/src/core/domain/events/event-bus.ts`

```typescript
import { DomainEvent } from './user-events.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Event Handler
 */
export type EventHandler = (event: DomainEvent) => Promise<void>;

/**
 * Event Bus
 * 
 * Distributes events to registered handlers.
 * 
 * This is the heart of event-driven architecture.
 * It allows different parts of the system to react to events
 * without being tightly coupled.
 */
export class EventBus {
  private static instance: EventBus;
  private handlers: Map<string, EventHandler[]> = new Map();
  private wildcardHandlers: EventHandler[] = [];
  private readonly logger = createChildLogger({ module: 'EventBus' });
  private eventStore: any = null; // Will be set later

  private constructor() {}

  static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus();
    }
    return EventBus.instance;
  }

  /**
   * Set the event store (for persistence)
   */
  setEventStore(eventStore: any): void {
    this.eventStore = eventStore;
  }

  /**
   * Register a handler for specific event types
   */
  on(eventType: string, handler: EventHandler): void {
    if (!this.handlers.has(eventType)) {
      this.handlers.set(eventType, []);
    }
    this.handlers.get(eventType)!.push(handler);
    this.logger.debug({ eventType }, 'Handler registered');
  }

  /**
   * Register a handler for all events
   */
  onAny(handler: EventHandler): void {
    this.wildcardHandlers.push(handler);
    this.logger.debug('Wildcard handler registered');
  }

  /**
   * Publish an event
   */
  async publish(event: DomainEvent): Promise<void> {
    this.logger.debug({
      eventType: event.eventType,
      aggregateId: event.aggregateId,
      version: event.version,
    }, 'Publishing event');

    // 1. Persist to event store if available
    if (this.eventStore) {
      try {
        // The event store will handle version checking
        await this.eventStore.appendEvents(event.aggregateId, [event]);
      } catch (error) {
        this.logger.error({
          error,
          eventType: event.eventType,
          aggregateId: event.aggregateId,
        }, 'Failed to persist event to store');
        throw error;
      }
    }

    // 2. Notify specific handlers
    const specificHandlers = this.handlers.get(event.eventType) || [];
    for (const handler of specificHandlers) {
      try {
        await handler(event);
      } catch (error) {
        this.logger.error({
          error,
          eventType: event.eventType,
          handler: handler.name,
        }, 'Handler failed');
        // Don't throw - let other handlers continue
      }
    }

    // 3. Notify wildcard handlers
    for (const handler of this.wildcardHandlers) {
      try {
        await handler(event);
      } catch (error) {
        this.logger.error({
          error,
          eventType: event.eventType,
          handler: handler.name,
        }, 'Wildcard handler failed');
      }
    }

    this.logger.debug({
      eventType: event.eventType,
      handlers: specificHandlers.length + this.wildcardHandlers.length,
    }, 'Event published');
  }

  /**
   * Publish multiple events
   */
  async publishAll(events: DomainEvent[]): Promise<void> {
    for (const event of events) {
      await this.publish(event);
    }
  }

  /**
   * Remove all handlers (for testing)
   */
  clear(): void {
    this.handlers.clear();
    this.wildcardHandlers = [];
    this.logger.debug('All handlers cleared');
  }

  /**
   * Get statistics
   */
  getStats(): {
    eventTypes: number;
    totalHandlers: number;
    handlers: Record<string, number>;
  } {
    const handlers: Record<string, number> = {};
    for (const [eventType, handlerList] of this.handlers) {
      handlers[eventType] = handlerList.length;
    }
    return {
      eventTypes: this.handlers.size,
      totalHandlers: this.wildcardHandlers.length + Array.from(this.handlers.values())
        .reduce((sum, list) => sum + list.length, 0),
      handlers,
    };
  }
}
```

### 4. The Verification

#### Step 1: Run Event Store Migration

```bash
cd packages/gateway
npm run admin:db-migrate
```

Expected output:
```
[INFO] Running migration: 003_event_store.sql
[INFO] ✅ Migration completed: 003_event_store.sql
```

#### Step 2: Test Event Sourcing

**File:** `packages/gateway/tests/integration/event-sourcing.test.ts`

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { PostgresEventStore } from '../../src/infrastructure/adapters/event-store/postgres/event-store.js';
import { UserCreatedEvent, UserProfileUpdatedEvent } from '../../src/core/domain/events/user-events.js';
import { EventBus } from '../../src/core/domain/events/event-bus.js';
import { UserProjection } from '../../src/infrastructure/adapters/projections/user-projection.js';

describe('Event Sourcing Integration Tests', () => {
  let eventStore: PostgresEventStore;
  let eventBus: EventBus;
  let userProjection: UserProjection;

  beforeAll(async () => {
    eventStore = new PostgresEventStore();
    eventBus = EventBus.getInstance();
    eventBus.setEventStore(eventStore);
    userProjection = new UserProjection();

    // Register projection as handler
    eventBus.on('UserCreated', userProjection.handleEvent.bind(userProjection));
    eventBus.on('UserProfileUpdated', userProjection.handleEvent.bind(userProjection));
  });

  afterAll(async () => {
    // Clean up test data
    await eventStore.connection?.query('DELETE FROM events WHERE aggregate_id LIKE $1', ['test-%']);
  });

  it('should store and retrieve events', async () => {
    const userId = `test-${Date.now()}`;
    
    // Create events
    const created = new UserCreatedEvent(
      userId,
      'test@example.com',
      'testuser',
      'Test',
      'User',
      'hashed_password'
    );

    const updated = new UserProfileUpdatedEvent(
      userId,
      'Updated',
      'Name',
      2
    );

    // Publish events
    await eventBus.publish(created);
    await eventBus.publish(updated);

    // Retrieve events
    const events = await eventStore.getEvents(userId);

    expect(events).toHaveLength(2);
    expect(events[0].eventType).toBe('UserCreated');
    expect(events[1].eventType).toBe('UserProfileUpdated');
    expect(events[0].version).toBe(1);
    expect(events[1].version).toBe(2);
  });

  it('should handle concurrency conflicts', async () => {
    const userId = `test-conflict-${Date.now()}`;
    
    const created = new UserCreatedEvent(
      userId,
      'conflict@example.com',
      'conflictuser',
      'Conflict',
      'User',
      'hashed_password'
    );

    await eventBus.publish(created);

    // Try to create another event with wrong version
    const duplicate = new UserProfileUpdatedEvent(
      userId,
      'Duplicate',
      'User',
      1 // Should be 2
    );

    await expect(eventBus.publish(duplicate)).rejects.toThrow('Concurrency conflict');
  });

  it('should rebuild projection from events', async () => {
    const userId = `test-rebuild-${Date.now()}`;
    
    // Create events
    const created = new UserCreatedEvent(
      userId,
      'rebuild@example.com',
      'rebuilduser',
      'Rebuild',
      'Test',
      'hashed_password'
    );

    await eventBus.publish(created);

    // Rebuild projection
    await userProjection.rebuild();

    // Query the read model
    const result = await eventStore.connection?.query(
      'SELECT * FROM user_read_model WHERE id = $1',
      [userId]
    );

    expect(result?.rows[0]).toBeDefined();
    expect(result?.rows[0].email).toBe('rebuild@example.com');
    expect(result?.rows[0].first_name).toBe('Rebuild');
  });
});
```

Run the tests:
```bash
npm test -- tests/integration/event-sourcing.test.ts
```

#### Step 3: Test Event Bus

Create a test script:

**File:** `packages/gateway/tests/manual/event-bus.test.ts`

```typescript
import { EventBus } from '../../src/core/domain/events/event-bus.js';
import { UserCreatedEvent, UserProfileUpdatedEvent } from '../../src/core/domain/events/user-events.js';

async function testEventBus() {
  const eventBus = EventBus.getInstance();

  // Register handlers
  eventBus.on('UserCreated', async (event) => {
    console.log(`User created: ${event.aggregateId}`);
  });

  eventBus.on('UserProfileUpdated', async (event) => {
    const data = event.toJSON().data;
    console.log(`User profile updated: ${event.aggregateId} → ${data.firstName} ${data.lastName}`);
  });

  // Register wildcard handler
  eventBus.onAny(async (event) => {
    console.log(`Any event: ${event.eventType} for ${event.aggregateId}`);
  });

  // Publish events
  const userId = `test-${Date.now()}`;
  
  const created = new UserCreatedEvent(
    userId,
    'test@example.com',
    'testuser',
    'Test',
    'User',
    'hash'
  );

  const updated = new UserProfileUpdatedEvent(
    userId,
    'Updated',
    'Name',
    2
  );

  await eventBus.publish(created);
  await eventBus.publish(updated);

  // Get stats
  const stats = eventBus.getStats();
  console.log('Event Bus Stats:', stats);
}

testEventBus().catch(console.error);
```

Run the test:
```bash
npx tsx tests/manual/event-bus.test.ts
```

Expected output:
```
User created: test-1234567890
Any event: UserCreated for test-1234567890
User profile updated: test-1234567890 → Updated Name
Any event: UserProfileUpdated for test-1234567890
Event Bus Stats: { eventTypes: 2, totalHandlers: 3, handlers: { UserCreated: 1, UserProfileUpdated: 1 } }
```

### 5. Deep Dive: Event Sourcing Patterns

#### Event Versioning

Events are immutable, but the system evolves:

```typescript
// Version 1: Simple event
class UserCreatedEventV1 {
  userId, name, email
}

// Version 2: Added fields
class UserCreatedEventV2 extends DomainEvent {
  userId, firstName, lastName, email
}
```

**Strategy:**
1. Always include a version number
2. Use version mapping for old events
3. Handle missing fields gracefully

#### Snapshotting

For aggregates with many events:

```typescript
// Take snapshots every N events
async function getAggregate(id: string): Promise<User> {
  const snapshot = await getSnapshot(id);
  const events = await eventStore.getEventsFromVersion(id, snapshot.version);
  
  let user = User.fromSnapshot(snapshot.data);
  for (const event of events) {
    user.apply(event);
  }
  return user;
}
```

#### Idempotency

Prevent duplicate event processing:

```typescript
// Store processed event IDs
class EventProcessor {
  async process(event: DomainEvent): Promise<void> {
    if (await this.isProcessed(event.eventId)) {
      return; // Already processed
    }
    
    await this.processEvent(event);
    await this.markProcessed(event.eventId);
  }
}
```

### 6. Summary

**What We Built:**
- ✅ Domain events for user and task
- ✅ Event store with PostgreSQL
- ✅ Event bus for decoupled communication
- ✅ Projections for read models
- ✅ Event sourcing with versioning
- ✅ Concurrency control
- ✅ Event replay for rebuilding projections

**Key Concepts Learned:**
- Event sourcing and its benefits
- CQRS with read/write separation
- Domain events and event modeling
- Event store implementation
- Projections for denormalized reads
- Event bus for decoupling
- Versioning and idempotency

**What's Next:**
In Part 2 of Phase 5, we'll implement stream processing, backpressure handling, and build a complete event-driven pipeline with real-time notifications.

**Verification Checklist:**
- [ ] Event store successfully stores events
- [ ] Event bus publishes events to handlers
- [ ] Projections update read models correctly
- [ ] Event replay rebuilds projections
- [ ] Concurrency conflicts are handled
- [ ] Event versioning works
- [ ] Read models can be queried efficiently
