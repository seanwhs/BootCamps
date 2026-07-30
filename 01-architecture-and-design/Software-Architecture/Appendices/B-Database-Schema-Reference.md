# Appendix B: Database Schema Reference

## Complete PostgreSQL Schema Documentation

This appendix provides a comprehensive reference for the database schema used in the Orchestrator system. Think of this as the blueprint for your data architecture - showing how all the pieces fit together.

### 1. Schema Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATABASE SCHEMA DIAGRAM                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                         users                                       │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ email │ username │ first_name │ last_name │ ...   │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                               │ 1                                         │
│                               │                                           │
│                               │ N                                         │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                         tasks                                      │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ user_id (FK) │ title │ description │ status │ ...  │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                         events                                      │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ event_id │ aggregate_id │ event_type │ data │ ...  │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                    user_read_model                                 │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ email │ username │ first_name │ is_active │ ...   │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                    task_read_model                                  │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ user_id │ title │ status │ priority │ due_date │  │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                    user_login_history                               │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ user_id (FK) │ ip_address │ login_at │ ...        │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                    migrations                                      │    │
│  │  ┌──────────────────────────────────────────────────────────────┐  │    │
│  │  │ id (PK) │ name │ executed_at │                              │  │    │
│  │  └──────────────────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Core Tables

#### Users Table

Stores user account information.

**File:** `001_initial_schema.sql`

```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Comments for documentation
COMMENT ON TABLE users IS 'User accounts for the Orchestrator system';
COMMENT ON COLUMN users.id IS 'Unique identifier for the user';
COMMENT ON COLUMN users.email IS 'User email address (unique)';
COMMENT ON COLUMN users.username IS 'Unique username for display';
COMMENT ON COLUMN users.password_hash IS 'Bcrypt hash of the password';
COMMENT ON COLUMN users.is_active IS 'Whether the user account is active';
COMMENT ON COLUMN users.last_login_at IS 'Timestamp of the last successful login';
```

#### Tasks Table

Stores task information.

```sql
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes for common queries
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_created_at ON tasks(created_at DESC);
CREATE INDEX idx_tasks_completed_at ON tasks(completed_at);

-- Composite indexes for performance
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);
CREATE INDEX idx_tasks_user_priority ON tasks(user_id, priority);

-- GIN index for JSONB metadata queries
CREATE INDEX idx_tasks_metadata ON tasks USING GIN(metadata);

COMMENT ON TABLE tasks IS 'Tasks created by users in the Orchestrator system';
COMMENT ON COLUMN tasks.status IS 'Current status: pending, in_progress, completed, failed, cancelled';
COMMENT ON COLUMN tasks.priority IS 'Priority level: low, medium, high, critical';
COMMENT ON COLUMN tasks.metadata IS 'Flexible JSON metadata for task extensions';
```

### 3. Event Sourcing Tables

#### Events Table

Stores all domain events for event sourcing.

```sql
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

-- Indexes for event queries
CREATE INDEX idx_events_aggregate_id_version ON events(aggregate_id, version);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_occurred_at ON events(occurred_at DESC);
CREATE INDEX idx_events_aggregate_type ON events(aggregate_type);
CREATE INDEX idx_events_data ON events USING GIN(data);

-- Comments
COMMENT ON TABLE events IS 'Event sourcing event log';
COMMENT ON COLUMN events.event_id IS 'Unique event ID (idempotency key)';
COMMENT ON COLUMN events.aggregate_id IS 'Aggregate ID (entity ID)';
COMMENT ON COLUMN events.aggregate_type IS 'Type of aggregate (User, Task, etc.)';
COMMENT ON COLUMN events.event_type IS 'Type of event (UserCreated, TaskCompleted, etc.)';
COMMENT ON COLUMN events.version IS 'Aggregate version after this event';
COMMENT ON COLUMN events.data IS 'Event data as JSON';
```

#### Snapshots Table

Optional table for aggregate snapshots (performance optimization).

```sql
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
```

### 4. Read Model Tables

#### User Read Model

Denormalized view of user data for fast queries.

```sql
CREATE TABLE IF NOT EXISTS user_read_model (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_user_read_model_email ON user_read_model(email);
CREATE INDEX idx_user_read_model_username ON user_read_model(username);
CREATE INDEX idx_user_read_model_is_active ON user_read_model(is_active);
```

#### Task Read Model

Denormalized view of task data for fast queries.

```sql
CREATE TABLE IF NOT EXISTS task_read_model (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    user_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    priority VARCHAR(20) NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT,
    cancellation_reason TEXT,
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX idx_task_read_model_user_id ON task_read_model(user_id);
CREATE INDEX idx_task_read_model_status ON task_read_model(status);
CREATE INDEX idx_task_read_model_priority ON task_read_model(priority);
CREATE INDEX idx_task_read_model_due_date ON task_read_model(due_date);
CREATE INDEX idx_task_read_model_created_at ON task_read_model(created_at DESC);
```

#### User Login History

Audit trail of user logins.

```sql
CREATE TABLE IF NOT EXISTS user_login_history (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_login_history_user_id ON user_login_history(user_id);
CREATE INDEX idx_user_login_history_login_at ON user_login_history(login_at DESC);
```

### 5. Migration Management

#### Migrations Table

Tracks which migrations have been applied.

```sql
CREATE TABLE IF NOT EXISTS migrations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    executed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

#### Migration Files

**001_initial_schema.sql**
- Creates users, tasks, and migrations tables
- Sets up indexes and comments
- Configures updated_at triggers

**002_add_indexes.sql**
- Adds performance indexes
- Creates partial indexes for active users
- Sets up covering indexes

**003_event_store.sql**
- Creates events and snapshots tables
- Adds event notification triggers
- Sets up event store indexes

### 6. Database Functions & Triggers

#### Update Timestamp Trigger

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Apply to tasks table
CREATE TRIGGER update_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

#### Event Notification Trigger

```sql
CREATE OR REPLACE FUNCTION notify_event_insert()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('event_inserted', row_to_json(NEW)::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER event_insert_trigger
AFTER INSERT ON events
FOR EACH ROW
EXECUTE FUNCTION notify_event_insert();
```

### 7. Common Queries

#### Get User with Tasks

```sql
SELECT 
    u.id,
    u.email,
    u.username,
    u.first_name,
    u.last_name,
    u.is_active,
    u.last_login_at,
    json_agg(
        json_build_object(
            'id', t.id,
            'title', t.title,
            'status', t.status,
            'priority', t.priority,
            'due_date', t.due_date
        )
    ) as tasks
FROM users u
LEFT JOIN tasks t ON u.id = t.user_id
WHERE u.id = 'user-id'
GROUP BY u.id;
```

#### Get Event History

```sql
SELECT 
    event_id,
    aggregate_id,
    event_type,
    version,
    occurred_at,
    data->>'title' as title
FROM events
WHERE aggregate_id = 'aggregate-id'
ORDER BY version ASC;
```

#### Get Recent Events

```sql
SELECT 
    event_type,
    COUNT(*) as count,
    MAX(occurred_at) as last_occurred
FROM events
WHERE occurred_at > NOW() - INTERVAL '1 hour'
GROUP BY event_type
ORDER BY count DESC;
```

#### Rebuild User Read Model

```sql
-- Truncate read model
TRUNCATE TABLE user_read_model CASCADE;

-- Insert from events
INSERT INTO user_read_model (
    id, email, username, first_name, last_name,
    password_hash, is_active, last_login_at,
    created_at, updated_at
)
SELECT 
    aggregate_id,
    data->>'email' as email,
    data->>'username' as username,
    data->>'firstName' as first_name,
    data->>'lastName' as last_name,
    data->>'passwordHash' as password_hash,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM events e2 
            WHERE e2.aggregate_id = e1.aggregate_id 
            AND e2.event_type = 'UserDeactivated'
            AND e2.version > e1.version
        ) THEN false
        ELSE true
    END as is_active,
    (
        SELECT data->>'lastLoginAt'::timestamp 
        FROM events e3 
        WHERE e3.aggregate_id = e1.aggregate_id 
        AND e3.event_type = 'UserLoggedIn'
        ORDER BY e3.version DESC 
        LIMIT 1
    ) as last_login_at,
    MIN(occurred_at) as created_at,
    MAX(occurred_at) as updated_at
FROM events e1
WHERE aggregate_type = 'User'
GROUP BY aggregate_id;
```

### 8. Performance Optimization Tips

#### Query Optimization

1. **Use Indexes Effectively:**
```sql
-- For JSON queries
CREATE INDEX idx_events_data_user_email ON events((data->>'email'));

-- For partial indexes
CREATE INDEX idx_users_active_email ON users(email) WHERE is_active = true;

-- For covering indexes
CREATE INDEX idx_tasks_covering ON tasks(user_id, status) INCLUDE (title, created_at);
```

2. **Use EXPLAIN ANALYZE:**
```sql
EXPLAIN ANALYZE
SELECT * FROM events 
WHERE aggregate_id = 'user-id' 
ORDER BY version DESC;
```

3. **Batch Operations:**
```sql
-- Use bulk inserts
INSERT INTO events (event_id, aggregate_id, ...) VALUES
    ($1, $2, ...),
    ($3, $4, ...),
    ...
ON CONFLICT (event_id) DO NOTHING;
```

#### Connection Pooling

```typescript
// Recommended pool settings
const poolConfig = {
    max: 20,              // Maximum connections
    idleTimeoutMillis: 30000,  // Close idle connections after 30s
    connectionTimeoutMillis: 2000,  // Timeout for getting connection
    statement_timeout: 30000,  // Max query execution time
};
```

### 9. Backup & Recovery

#### Backup Commands

```bash
# Full backup
pg_dump -U postgres orchestrator > backup.sql

# Schema-only backup
pg_dump -U postgres --schema-only orchestrator > schema.sql

# Data-only backup
pg_dump -U postgres --data-only orchestrator > data.sql

# Compressed backup
pg_dump -U postgres orchestrator | gzip > backup.sql.gz
```

#### Restore Commands

```bash
# Restore full backup
psql -U postgres orchestrator < backup.sql

# Restore compressed backup
gunzip -c backup.sql.gz | psql -U postgres orchestrator
```

### 10. Migration Management Best Practices

1. **Always Include Rollback Scripts:**
```sql
-- Migration: 004_add_user_preferences.sql

-- UP
ALTER TABLE users ADD COLUMN preferences JSONB DEFAULT '{}'::jsonb;

-- DOWN
ALTER TABLE users DROP COLUMN preferences;
```

2. **Use Idempotent Migrations:**
```sql
-- Safe to run multiple times
CREATE TABLE IF NOT EXISTS users (
    -- schema definition
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
```

3. **Test Migrations Locally First:**
```bash
# Run migrations in test environment
NODE_ENV=test npm run admin:db-migrate

# Verify schema
psql -U postgres -d orchestrator_test -c "\dt"
```

---

This database schema reference provides a complete picture of your data architecture. Use it as a guide when querying the database, extending the schema, or debugging data-related issues.
