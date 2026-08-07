# Appendix B: SQLAlchemy 2.x Deep Dive & Optimization Guide

Welcome to Appendix B! This comprehensive reference section provides an expert-level exploration of SQLAlchemy 2.x, the powerful ORM powering TaskFlow's database layer. While the main tutorial covered practical usage, this appendix dives deep into SQLAlchemy's architecture, advanced patterns, and optimization techniques that will make you a true SQLAlchemy expert.

---

## Table of Contents

1. [SQLAlchemy Architecture Overview](#1-sqlalchemy-architecture-overview)
2. [The Session and Identity Map](#2-the-session-and-identity-map)
3. [Relationship Loading Strategies](#3-relationship-loading-strategies)
4. [Advanced Querying Techniques](#4-advanced-querying-techniques)
5. [Performance Optimization](#5-performance-optimization)
6. [Transactions and Concurrency](#6-transactions-and-concurrency)
7. [Alembic Migrations Deep Dive](#7-alembic-migrations-deep-dive)
8. [Common Pitfalls and Solutions](#8-common-pitfalls-and-solutions)

---

## 1. SQLAlchemy Architecture Overview

### The Two-Phase Architecture

SQLAlchemy is built on a two-layer architecture that separates the **Core** (database communication) from the **ORM** (object-relational mapping).

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Application                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  SQLAlchemy ORM                             │
│  - Declarative Models                                       │
│  - Session Management                                       │
│  - Identity Map                                             │
│  - Relationship Handling                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                  SQLAlchemy Core                            │
│  - SQL Expression Language                                  │
│  - Connection Pooling                                       │
│  - Dialect System                                           │
│  - Result Set Processing                                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│              Database Driver (psycopg2/aiosqlite)           │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                    Database (PostgreSQL/MySQL/SQLite)       │
└─────────────────────────────────────────────────────────────┘
```

### The SQLAlchemy Core Components

```python
from sqlalchemy import create_engine, MetaData, Table, Column, Integer, String
from sqlalchemy.sql import select

# 1. Engine - The database connection factory
engine = create_engine('postgresql://user:pass@localhost/db')

# 2. Connection - An individual database connection
connection = engine.connect()

# 3. MetaData - Registry of table definitions
metadata = MetaData()

# 4. Table - A database table definition
users = Table('users', metadata,
    Column('id', Integer, primary_key=True),
    Column('name', String(50)),
)

# 5. SQL Expression - A SQL query represented in Python
query = select(users).where(users.c.id == 1)

# 6. Result - The query result set
result = connection.execute(query)

# ORM equivalent using declarative models
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = 'users'
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
```

### How SQLAlchemy Translates Python to SQL

```python
# Python code
query = select(User).where(User.name == "John")

# Internal representation (SQLAlchemy expression tree)
# SELECT users.id, users.name, users.email 
# FROM users 
# WHERE users.name = :name_1

# Compiled SQL
compiled = query.compile(compile_kwargs={"literal_binds": True})
print(compiled)  # SELECT users.id, users.name, users.email 
                 # FROM users 
                 # WHERE users.name = 'John'

# The compilation process:
# 1. Python expression → SQLAlchemy expression
# 2. SQLAlchemy expression → Dialect-specific SQL
# 3. Dialect-specific SQL → Database driver execution
```

---

## 2. The Session and Identity Map

### The Session Lifecycle

The Session is the central object for all ORM operations. It's like a transactional workspace where changes are tracked before being flushed to the database.

```python
from sqlalchemy.orm import Session

# Session creation
session = Session(engine)

# Session states during a request
def request_lifecycle():
    # 1. BEGIN: Session created at start of request
    session = Session(engine)
    
    # 2. ACTIVE: Queries and operations
    user = session.query(User).first()
    user.name = "Updated Name"
    
    # 3. PENDING: Changes are tracked but not committed
    # 4. FLUSH: Session.flush() sends SQL to database
    session.flush()  # Optional, happens automatically on commit
    
    # 5. COMMIT/ROLLBACK: End of transaction
    session.commit()  # Commits all changes
    # OR
    session.rollback()  # Rolls back all changes
    
    # 6. CLOSED: Session is closed
    session.close()
```

### The Identity Map Pattern

The Identity Map ensures that each database row is represented by at most one Python object in memory within a single session.

```python
def identity_map_demo(session):
    # First query: creates a User object
    user1 = session.query(User).filter_by(id=1).first()
    print(f"User1 ID: {id(user1)}")  # e.g., 12345
    
    # Second query: returns the SAME object
    user2 = session.query(User).filter_by(id=1).first()
    print(f"User2 ID: {id(user2)}")  # 12345 (same object!)
    
    # Modifying user1 affects user2
    user1.name = "New Name"
    print(user2.name)  # "New Name"
    
    # Why this matters:
    # - Reduces memory usage
    # - Ensures consistency within a transaction
    # - Enables automatic change tracking
    
    # The identity map key: (class, primary_key)
    key = (User, (1,))
    assert session.identity_map.get(key) is user1
```

### Session States (New, Persistent, Detached)

```python
def session_states():
    # 1. TRANSIENT: New object, not in session
    user = User(name="John")  # Transient
    
    # 2. PENDING: Added to session
    session.add(user)  # Pending
    
    # 3. FLUSHED: SQL sent to database
    session.flush()  # Still Pending until commit
    
    # 4. PERSISTENT: Committed, in session
    session.commit()  # Persistent
    
    # 5. DETACHED: Removed from session
    session.expunge(user)  # Detached
    
    # Or expired/closed session
    session.close()  # All objects become detached

# Detached objects can be re-attached
def reattach_detached(session, user):
    # Object is detached
    assert user not in session
    
    # Option 1: Merge (adds or updates)
    merged_user = session.merge(user)
    session.commit()
    
    # Option 2: Add (if we know it's new)
    session.add(user)
    
    # Option 3: Query then update
    existing = session.query(User).get(user.id)
    if existing:
        existing.name = user.name
```

### Session Best Practices

```python
# ✅ Good: Context manager for automatic cleanup
with Session(engine) as session:
    user = session.query(User).first()
    user.name = "Updated"
    session.commit()
# Session automatically closed

# ✅ Good: Request-scoped session
@app.before_request
def create_session():
    g.db = Session(engine)

@app.teardown_request
def close_session(exception):
    session = g.pop('db', None)
    if session:
        session.close()

# ✅ Good: Explicit transaction boundaries
def update_user(user_id, data):
    session = Session(engine)
    try:
        user = session.query(User).get(user_id)
        for key, value in data.items():
            setattr(user, key, value)
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()
```

---

## 3. Relationship Loading Strategies

### Understanding the N+1 Query Problem

```python
# ❌ N+1 Query Problem (SELECT N+1)
def n_plus_one_problem(session):
    # 1 query: Select all tasks
    tasks = session.query(Task).all()  # SELECT * FROM tasks
    
    # N queries: For each task, fetch the user
    for task in tasks:
        print(task.user.name)  # SELECT * FROM users WHERE id = ?
    # Total: 1 + N queries!

# ✅ Solution 1: Eager Loading with joinedload
def eager_loading(session):
    tasks = session.query(Task).options(
        joinedload(Task.user)
    ).all()  # LEFT OUTER JOIN users
    
    for task in tasks:
        print(task.user.name)  # No additional queries!

# ✅ Solution 2: Eager Loading with selectinload
def selectin_loading(session):
    tasks = session.query(Task).options(
        selectinload(Task.user)
    ).all()  # SELECT tasks, then SELECT users WHERE id IN (...)
    
    for task in tasks:
        print(task.user.name)  # No additional queries!
```

### Loading Strategy Comparison

| Strategy | Use Case | Pros | Cons |
|----------|----------|------|------|
| **Lazy (`lazy='select'`)** | Default, when you might not need the relationship | No unnecessary data | N+1 queries if accessed in loop |
| **Eager (`lazy='joined'`)** | When you always need the relationship | Single query | Can return lots of data |
| **Eager (`lazy='selectin'`)** | Collections or when joined would be large | Efficient, avoids cartesian product | Two queries instead of one |
| **Eager (`lazy='subquery'`)** | Alternative to selectin for older databases | Works with more databases | Slower with large datasets |
| **Dynamic (`lazy='dynamic'`)** | For large collections you need to filter | Clean API for filtering | Not a real relationship, extra queries |

### Configuring Loading Strategies in Models

```python
from sqlalchemy.orm import relationship, joinedload, selectinload, lazyload

class User(Base):
    __tablename__ = 'users'
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    
    # Different loading strategies for different relationships
    tasks: Mapped[List['Task']] = relationship(
        back_populates='user',
        lazy='selectin',  # Load tasks with selectinload by default
        cascade='all, delete-orphan'
    )
    
    # For a relationship you rarely need
    audit_logs: Mapped[List['AuditLog']] = relationship(
        back_populates='user',
        lazy='noload'  # Never load automatically
    )

class Task(Base):
    __tablename__ = 'tasks'
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str]
    user_id: Mapped[int] = mapped_column(ForeignKey('users.id'))
    
    user: Mapped['User'] = relationship(
        back_populates='tasks',
        lazy='joined'  # Always load user with joinedload
    )

# Per-query override
def override_loading(session):
    # Override default lazy='joined' to lazy='selectin'
    tasks = session.query(Task).options(
        selectinload(Task.user)
    ).all()
    
    # Override default lazy='selectin' to lazy='joined'
    users = session.query(User).options(
        joinedload(User.tasks)
    ).all()
    
    # Override to lazy load (back to default)
    users = session.query(User).options(
        lazyload(User.tasks)
    ).all()
```

### Handling Deep Relationships

```python
# Deep relationship loading
def deep_loading(session):
    # Load Task -> User -> Teams
    tasks = session.query(Task).options(
        joinedload(Task.user).joinedload(User.teams)
    ).all()
    
    # More complex: different strategies at different levels
    tasks = session.query(Task).options(
        selectinload(Task.user),  # Users via selectinload
        joinedload(Task.category),  # Categories via joinedload
        selectinload(Task.tags)  # Tags via selectinload
    ).all()
    
    # For deeply nested collections (many-to-many)
    users = session.query(User).options(
        selectinload(User.tasks).selectinload(Task.tags)
    ).all()
```

---

## 4. Advanced Querying Techniques

### Composite Queries with Joins

```python
# Complex joins with SQLAlchemy
def advanced_joins(session):
    # Inner join with conditions
    query = session.query(Task).join(
        User, Task.user_id == User.id
    ).filter(User.is_active == True)
    
    # Multiple joins
    query = session.query(Task).join(
        User, Task.user_id == User.id
    ).join(
        Category, Task.category_id == Category.id
    ).filter(
        Category.name == "Work"
    )
    
    # Left outer join (fetch users even if no tasks)
    users = session.query(User).outerjoin(
        Task, User.id == Task.user_id
    ).all()
    
    # Multiple join types in one query
    from sqlalchemy.orm import aliased
    
    # Alias for self-join or multiple joins to same table
    manager = aliased(User)
    tasks = session.query(Task).join(
        User, Task.user_id == User.id
    ).join(
        manager, User.manager_id == manager.id
    ).filter(
        manager.is_admin == True
    ).all()
```

### Subqueries and CTEs

```python
from sqlalchemy.sql import func, and_, or_
from sqlalchemy.orm import subqueryload

def subqueries_demo(session):
    # Subquery in SELECT
    subq = session.query(
        Task.user_id,
        func.count(Task.id).label('task_count')
    ).group_by(Task.user_id).subquery()
    
    users = session.query(
        User,
        subq.c.task_count
    ).outerjoin(
        subq, User.id == subq.c.user_id
    ).all()
    
    # Subquery in WHERE (exists)
    subq = session.query(Task).filter(
        Task.user_id == User.id
    ).exists()
    
    users_with_tasks = session.query(User).filter(subq).all()
    
    # CTE (Common Table Expression)
    from sqlalchemy.orm import aliased
    
    cte = session.query(
        Task.id,
        Task.title,
        Task.parent_id
    ).filter(Task.parent_id.is_(None)).cte(recursive=True)
    
    # Recursive CTE for hierarchical data
    cte_alias = aliased(cte)
    cte = cte.union_all(
        session.query(
            Task.id,
            Task.title,
            Task.parent_id
        ).join(
            cte_alias, Task.parent_id == cte_alias.c.id
        )
    )
    
    hierarchical = session.query(cte).all()
```

### Window Functions for Analytics

```python
def window_functions(session):
    from sqlalchemy.sql import func
    
    # Rank tasks by due date
    query = session.query(
        Task.title,
        Task.due_date,
        func.rank().over(
            order_by=Task.due_date
        ).label('rank')
    ).order_by(Task.due_date)
    
    # Partition by status, rank within each status
    query = session.query(
        Task.title,
        Task.status,
        Task.due_date,
        func.dense_rank().over(
            partition_by=Task.status,
            order_by=Task.due_date
        ).label('rank_in_status')
    )
    
    # Lag/Lead for comparing with previous/next rows
    query = session.query(
        Task.title,
        Task.due_date,
        func.lag(Task.due_date, 1).over(
            order_by=Task.due_date
        ).label('prev_due_date'),
        func.lead(Task.due_date, 1).over(
            order_by=Task.due_date
        ).label('next_due_date')
    )
```

### Full-Text Search

```python
def full_text_search(session):
    # PostgreSQL Full-Text Search
    from sqlalchemy.sql import func
    
    # Simple search
    results = session.query(Task).filter(
        func.to_tsvector('english', Task.title + ' ' + Task.description).match('search terms')
    ).all()
    
    # With relevance ranking
    query = session.query(
        Task,
        func.ts_rank(
            func.to_tsvector('english', Task.title + ' ' + Task.description),
            func.to_tsquery('search & terms')
        ).label('rank')
    ).filter(
        func.to_tsvector('english', Task.title + ' ' + Task.description).op('@@')(
            func.to_tsquery('search & terms')
        )
    ).order_by('rank DESC')
    
    # Web search (handles prefixes, phrases)
    query = session.query(Task).filter(
        func.to_tsvector('english', Task.title).op('@@')(
            func.plainto_tsquery('english', 'search terms')
        )
    )
    
    # With highlighting
    query = session.query(
        Task,
        func.ts_headline(
            'english',
            Task.title,
            func.to_tsquery('search & terms'),
            'StartSel=<mark>, StopSel=</mark>'
        ).label('highlighted')
    ).filter(
        func.to_tsvector('english', Task.title).op('@@')(
            func.to_tsquery('search & terms')
        )
    )
```

### Aggregation and Grouping

```python
def aggregation_demo(session):
    from sqlalchemy.sql import func
    
    # Simple aggregation
    task_count = session.query(func.count(Task.id)).scalar()
    
    # Group by with multiple aggregations
    stats = session.query(
        Task.status,
        func.count(Task.id).label('count'),
        func.avg(Task.priority).label('avg_priority'),
        func.max(Task.due_date).label('latest_due'),
        func.min(Task.created_at).label('earliest_created')
    ).group_by(Task.status).all()
    
    # Having clause
    results = session.query(
        User.id,
        func.count(Task.id).label('task_count')
    ).join(Task).group_by(User.id).having(
        func.count(Task.id) > 10
    ).all()
    
    # ROLLUP and CUBE for subtotals
    results = session.query(
        Task.status,
        Task.priority,
        func.count(Task.id)
    ).group_by(
        func.rollup(Task.status, Task.priority)
    ).all()
    
    # String aggregation
    result = session.query(
        Task.status,
        func.string_agg(Task.title, ', ').label('titles')
    ).group_by(Task.status).first()
```

---

## 5. Performance Optimization

### Query Optimization Techniques

```python
def query_optimization(session):
    # 1. Use only the columns you need
    # ❌ Bad
    users = session.query(User).all()  # All columns
    
    # ✅ Good
    users = session.query(User.id, User.name).all()  # Only needed columns
    
    # 2. Use LIMIT and OFFSET for pagination
    users = session.query(User).limit(20).offset(40).all()
    
    # 3. Use INDEX for common filters
    # In model:
    # name: Mapped[str] = mapped_column(String(50), index=True)
    # email: Mapped[str] = mapped_column(String(120), index=True, unique=True)
    
    # 4. Use EXISTS instead of COUNT for existence checks
    # ❌ Bad
    has_tasks = session.query(Task).filter(Task.user_id == user_id).count() > 0
    
    # ✅ Good
    has_tasks = session.query(
        session.query(Task).filter(Task.user_id == user_id).exists()
    ).scalar()
    
    # 5. Use subqueries instead of JOIN when possible
    # ❌ Bad
    users = session.query(User).join(Task).all()  # May return duplicates
    
    # ✅ Good
    users = session.query(User).filter(
        User.id.in_(session.query(Task.user_id).distinct())
    ).all()
```

### Query Profiling

```python
import time
from sqlalchemy import event

def profile_queries(session):
    # Enable query logging
    from app import db
    db.engine.echo = True
    
    # Custom query profiler
    @event.listens_for(db.engine, "before_cursor_execute")
    def before_cursor_execute(conn, cursor, statement, parameters, context, executemany):
        conn.info['query_start_time'] = time.time()
    
    @event.listens_for(db.engine, "after_cursor_execute")
    def after_cursor_execute(conn, cursor, statement, parameters, context, executemany):
        total = time.time() - conn.info['query_start_time']
        if total > 0.1:  # Log slow queries (>100ms)
            app.logger.warning(f"Slow query ({total:.2f}s): {statement}")
    
    # Using explain() to analyze query plans
    def analyze_query(query):
        # For PostgreSQL
        explain = session.execute(
            f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {query.statement}"
        ).scalar()
        return explain
    
    # Example usage
    query = session.query(Task).filter(Task.status == 'pending')
    plan = analyze_query(query)
    print(plan)
```

### Connection Pool Optimization

```python
# Engine configuration for optimal performance
engine = create_engine(
    'postgresql://user:pass@localhost/db',
    
    # Connection pool settings
    pool_size=20,              # Number of connections to keep open
    max_overflow=40,           # Extra connections when pool is full
    pool_recycle=3600,         # Recycle connections after 1 hour
    pool_pre_ping=True,        # Check connection before using
    pool_timeout=30,           # Timeout for getting a connection
    
    # Execution settings
    echo=False,                # Don't log all queries
    echo_pool=False,          # Don't log pool events
    
    # Performance settings
    isolation_level="READ COMMITTED",  # Default isolation level
    max_identifier_length=63,          # PostgreSQL identifier limit
    
    # Driver-specific settings
    connect_args={
        'keepalives': 1,
        'keepalives_idle': 60,
        'keepalives_interval': 10,
        'keepalives_count': 5,
        'connect_timeout': 10,
    }
)

# Monitoring connection pool
from sqlalchemy import event

@event.listens_for(engine, "checkout")
def receive_checkout(dbapi_conn, connection_record, connection_proxy):
    print(f"Connection checked out. Pool size: {engine.pool.size()}")

@event.listens_for(engine, "checkin")
def receive_checkin(dbapi_conn, connection_record):
    print(f"Connection checked in. Pool size: {engine.pool.size()}")
```

### Bulk Operations

```python
def bulk_operations(session):
    # Bulk inserts (faster than individual adds)
    users = [
        User(name=f"User {i}") for i in range(1000)
    ]
    session.bulk_save_objects(users)
    
    # Bulk insert with dicts (even faster)
    users = [
        {"name": f"User {i}"} for i in range(1000)
    ]
    session.bulk_insert_mappings(User, users)
    
    # Bulk update
    session.bulk_update_mappings(User, [
        {"id": 1, "name": "Updated Name"},
        {"id": 2, "name": "Updated Name 2"},
    ])
    
    # Bulk delete (avoid N deletions)
    session.query(Task).filter(Task.status == 'archived').delete()
    
    # Raw SQL for maximum performance
    session.execute(
        "UPDATE users SET name = 'Updated' WHERE id IN (1, 2, 3)"
    )
```

---

## 6. Transactions and Concurrency

### Transaction Isolation Levels

```python
# SQLAlchemy isolation level configuration
def isolation_levels():
    # Read Uncommitted (dirty reads allowed)
    engine = create_engine(
        'postgresql://user:pass@localhost/db',
        isolation_level="READ UNCOMMITTED"
    )
    
    # Read Committed (default for PostgreSQL)
    engine = create_engine(
        'postgresql://user:pass@localhost/db',
        isolation_level="READ COMMITTED"
    )
    
    # Repeatable Read (PostgreSQL default for SERIALIZABLE)
    engine = create_engine(
        'postgresql://user:pass@localhost/db',
        isolation_level="REPEATABLE READ"
    )
    
    # Serializable (strongest, most restrictive)
    engine = create_engine(
        'postgresql://user:pass@localhost/db',
        isolation_level="SERIALIZABLE"
    )

# Per-transaction isolation level
def transaction_with_isolation(session):
    # Set isolation for this transaction only
    session.connection().execution_options(
        isolation_level="SERIALIZABLE"
    )
    
    # Execute operations
    user = session.query(User).with_for_update().first()
    user.balance -= 100
    session.commit()
```

### Optimistic vs Pessimistic Locking

```python
def locking_strategies(session):
    # Pessimistic Locking (database-level lock)
    # Use with_for_update() to lock rows
    user = session.query(User).with_for_update().first()
    # Row is locked until transaction ends
    user.balance -= 50
    session.commit()  # Lock released
    
    # Skip locked (for queue processing)
    task = session.query(Task).filter(
        Task.status == 'pending'
    ).with_for_update(
        skip_locked=True
    ).first()
    # Skips rows that are already locked
    
    # Optimistic Locking (application-level)
    class User(Base):
        __tablename__ = 'users'
        id: Mapped[int] = mapped_column(primary_key=True)
        name: Mapped[str]
        balance: Mapped[int]
        version: Mapped[int] = mapped_column(default=1)
    
    # Update with version check
    def update_user(user):
        session.query(User).filter(
            User.id == user.id,
            User.version == user.version
        ).update({
            'balance': user.balance + 100,
            'version': User.version + 1
        })
        if session.query(User).get(user.id).version != user.version + 1:
            raise Exception("Concurrent update detected")
```

### Savepoints for Nested Transactions

```python
def savepoint_demo(session):
    try:
        # Start a transaction
        session.begin_nested()  # Create a savepoint
        
        # Operation 1
        user = User(name="John")
        session.add(user)
        
        # Nested savepoint
        session.begin_nested()
        try:
            # Operation 2
            task = Task(title="Complex Task")
            session.add(task)
            
            # Something goes wrong
            if task.title == "Complex Task":
                raise Exception("Task too complex")
            
            session.commit()  # Commit nested savepoint
        except Exception:
            session.rollback()  # Rollback to inner savepoint
        
        # Still have user, but no task
        session.commit()  # Commit outer transaction
        
    except Exception:
        session.rollback()  # Rollback everything
```

---

## 7. Alembic Migrations Deep Dive

### Migration File Structure

```python
# Alembic migration file structure
"""
migrations/versions/abc123_initial_migration.py
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# Revision identifiers
revision = 'abc123'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    # Create tables
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('username', sa.String(length=50), nullable=False),
        sa.Column('email', sa.String(length=120), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email'),
        sa.UniqueConstraint('username')
    )
    
    # Add indexes
    op.create_index('ix_users_email', 'users', ['email'])
    op.create_index('ix_users_username', 'users', ['username'])
    
    # Add enums
    status_enum = postgresql.ENUM('pending', 'in_progress', 'completed', name='taskstatus')
    status_enum.create(op.get_bind())

def downgrade():
    # Reverse operations
    status_enum = postgresql.ENUM('pending', 'in_progress', 'completed', name='taskstatus')
    status_enum.drop(op.get_bind())
    
    op.drop_index('ix_users_username', table_name='users')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_table('users')
```

### Advanced Alembic Operations

```python
# Advanced migration operations
def advanced_operations():
    # Batch mode (for SQLite or large tables)
    with op.batch_alter_table('users') as batch_op:
        batch_op.add_column(sa.Column('bio', sa.Text()))
        batch_op.alter_column('username', type_=sa.String(100))
        batch_op.drop_column('old_column')
    
    # Data migration with Python
    def upgrade():
        # Add new column
        op.add_column('tasks', sa.Column('priority', sa.String(50)))
        
        # Create a connection for data migration
        connection = op.get_bind()
        connection.execute(
            "UPDATE tasks SET priority = 'medium' WHERE priority IS NULL"
        )
        
        # Make column non-nullable after data is set
        op.alter_column('tasks', 'priority', nullable=False)
    
    # Rename table
    op.rename_table('old_table', 'new_table')
    
    # Move column
    op.alter_column('users', 'full_name', new_column_name='name')
    
    # Add foreign key with constraint name
    op.create_foreign_key(
        'fk_tasks_user_id',
        'tasks',
        'users',
        ['user_id'],
        ['id'],
        ondelete='CASCADE'
    )
    
    # Create and populate a new table from existing data
    def upgrade():
        # Create the new table
        op.create_table(
            'user_profiles',
            sa.Column('id', sa.Integer(), nullable=False),
            sa.Column('user_id', sa.Integer(), nullable=False),
            sa.Column('bio', sa.Text()),
            sa.PrimaryKeyConstraint('id'),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'])
        )
        
        # Populate from existing data
        connection = op.get_bind()
        connection.execute("""
            INSERT INTO user_profiles (user_id, bio)
            SELECT id, bio FROM users WHERE bio IS NOT NULL
        """)
```

### Safe Migrations for Production

```python
# Safe migration patterns

# 1. Add column with default value
def upgrade():
    # Add nullable first
    op.add_column('tasks', sa.Column('status', sa.String(50)))
    
    # Set default for existing rows
    op.execute("UPDATE tasks SET status = 'pending' WHERE status IS NULL")
    
    # Then make non-nullable
    op.alter_column('tasks', 'status', nullable=False, server_default='pending')

# 2. Add column with default but avoid locking large tables
def upgrade():
    # For PostgreSQL, use NOT VALID to avoid table lock
    op.execute("ALTER TABLE tasks ADD COLUMN priority VARCHAR(50) DEFAULT 'medium' NOT VALID")
    
    # Validate constraint later (in a separate migration)
    op.execute("ALTER TABLE tasks VALIDATE CONSTRAINT tasks_priority_check")

# 3. Split large migration into steps
# migration 1: Add column (nullable)
# migration 2: Populate data (can be run during low traffic)
# migration 3: Make column non-nullable

# 4. Use try/except for idempotent migrations
def upgrade():
    try:
        op.add_column('users', sa.Column('new_column', sa.String(50)))
    except Exception:
        pass  # Column already exists
```

---

## 8. Common Pitfalls and Solutions

### Pitfall 1: The N+1 Query Problem

```python
# ❌ Problem
def get_tasks_with_users(session):
    tasks = session.query(Task).all()
    for task in tasks:
        print(task.user.name)  # N+1 queries!
    return tasks

# ✅ Solution 1: Eager loading
def get_tasks_with_users(session):
    tasks = session.query(Task).options(
        joinedload(Task.user)
    ).all()
    for task in tasks:
        print(task.user.name)  # No additional query
    return tasks

# ✅ Solution 2: Query with join
def get_tasks_with_users(session):
    tasks = session.query(Task).join(Task.user).add_entity(User).all()
    # tasks are (Task, User) tuples
    return tasks
```

### Pitfall 2: Session Expiration

```python
# ❌ Problem: AttributeError after session expires
def bad_pattern(session):
    user = session.query(User).first()
    session.commit()  # Session closed/expired
    print(user.name)  # May raise AttributeError

# ✅ Solution 1: Keep session open
def good_pattern(session):
    user = session.query(User).first()
    print(user.name)
    session.commit()  # Commit after access

# ✅ Solution 2: Refresh or expire
def refresh_pattern(session):
    user = session.query(User).first()
    session.commit()
    session.refresh(user)  # Refresh object state
    print(user.name)
```

### Pitfall 3: Detached Instance Errors

```python
# ❌ Problem: Detached instance
def detached_problem(session):
    user = session.query(User).first()
    session.expunge(user)  # Detach user
    user.name = "New Name"
    session.add(user)  # Error: Can't add detached instance

# ✅ Solution 1: Merge
def merge_solution(session, user):
    merged_user = session.merge(user)
    merged_user.name = "New Name"
    session.commit()

# ✅ Solution 2: Re-query
def requery_solution(session, user):
    db_user = session.query(User).get(user.id)
    db_user.name = "New Name"
    session.commit()
```

### Pitfall 4: Transaction Management

```python
# ❌ Problem: Mixing auto-commit and manual transactions
def bad_transaction(session):
    session.autoflush = False  # Danger!
    user = User(name="John")
    session.add(user)
    # If something fails here, user is still in session
    
    # Commit happens automatically on next query
    session.query(User).first()  # Auto-commits!

# ✅ Solution: Explicit transaction boundaries
def good_transaction(session):
    try:
        user = User(name="John")
        session.add(user)
        # Explicit commit
        session.commit()
    except Exception:
        session.rollback()
        raise
```

### Pitfall 5: Relationship Assignment

```python
# ❌ Problem: Assigning to collection incorrectly
def bad_assignment(session, user):
    # This creates a new list and breaks relationship tracking
    user.tasks = []  # Bad!
    session.commit()

# ✅ Solution: Use the collection API
def good_assignment(session, user, new_task):
    user.tasks.append(new_task)  # Good
    # or
    user.tasks.extend([task1, task2])  # Good
    # or
    user.tasks.clear()  # Good for removing all
```

---

## Summary

This appendix has covered the deep internals of SQLAlchemy 2.x:

1. **Architecture**: The two-layer system (Core + ORM)
2. **Session & Identity Map**: How SQLAlchemy tracks objects
3. **Relationship Loading**: Strategies to avoid N+1 queries
4. **Advanced Querying**: Joins, subqueries, window functions
5. **Performance Optimization**: Query profiling, connection pooling, bulk operations
6. **Transactions & Concurrency**: Isolation levels, locking strategies
7. **Alembic Migrations**: Advanced migration patterns
8. **Common Pitfalls**: Solutions to frequent problems

Understanding these internals will help you build efficient, scalable database layers and debug complex ORM issues in production.
