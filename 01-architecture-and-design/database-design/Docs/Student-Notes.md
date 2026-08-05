# Mastering Modern Database Design — Complete Student Notes

## Comprehensive Lecture Notes for the Entire Series

---

## NOTES OVERVIEW

These student notes are designed to accompany the "Mastering Modern Database Design" series. They contain all key concepts, definitions, diagrams, and examples in a concise format for quick reference.

**How to Use These Notes:**
1. Review before each lecture
2. Follow along during the lecture
3. Annotate with your own examples
4. Use for exam preparation

---

## PART 0: INTRODUCTION

### 0.1 What Is a Database?

**Definition:** A structured collection of data stored electronically.

**Key Concepts:**
- **Data** → Raw facts and figures
- **Information** → Processed data with meaning
- **Database** → Organized collection of related data
- **DBMS** → Software that manages databases

**Why Databases Matter:**
- Data persistence
- Concurrent access
- Security and integrity
- Query capability
- Scalability

### 0.2 Database Types

| Type | Description | Examples |
|------|-------------|----------|
| **Relational** | Tables with rows/columns | PostgreSQL, MySQL, Oracle |
| **Document** | JSON-like documents | MongoDB, Couchbase |
| **Key-Value** | Simple key-value pairs | Redis, DynamoDB |
| **Graph** | Nodes and relationships | Neo4j, Amazon Neptune |
| **Time-Series** | Time-stamped data | TimescaleDB, InfluxDB |
| **Wide-Column** | Sparse columnar data | Cassandra, HBase |

### 0.3 ScaleCart Overview

**What We're Building:** Complete e-commerce platform

**Scale Targets:**
- 100M+ products
- 1000+ concurrent users
- 1000+ transactions/second
- 99.95% uptime

**Technologies:**
- PostgreSQL 15+ (primary)
- Redis 7+ (cache/sessions)
- MongoDB 7+ (document cache)
- Neo4j 5+ (recommendations)
- TimescaleDB (time-series)

---

## PART 1: FOUNDATIONS OF RELATIONAL DATABASE DESIGN

### 1.1 Key Concepts

**Entity:** A real-world object or concept with independent existence.

**Attribute:** A property or characteristic of an entity.

**Relationship:** A connection between two or more entities.

**Cardinality:** The number of entities in a relationship.

| Type | Notation | Example |
|------|----------|---------|
| One-to-One | 1:1 | Person ↔ Passport |
| One-to-Many | 1:N | Customer → Orders |
| Many-to-Many | N:M | Students ↔ Courses |

### 1.2 ER Diagram Notation

```
┌──────────────┐              ┌──────────────┐
│   ENTITY     │1            N│   ENTITY     │
│   (Table)    │──────────────│   (Table)    │
├──────────────┤              ├──────────────┤
│ id (PK)      │              │ id (PK)      │
│ name         │              │ entity_id (FK)│
│ description  │              │ field1       │
└──────────────┘              └──────────────┘
```

**Crow's Foot Notation:**
- ──────── : One (exactly one)
- ────◯─── : Zero or one
- ────<─── : Many (one or more)
- ────◯<── : Zero or many

### 1.3 Normalization

**Purpose:** Reduce data redundancy and prevent anomalies.

| Normal Form | Rule | Example Violation |
|-------------|------|-------------------|
| **1NF** | Atomic values, no repeating groups | Multiple phone numbers in one field |
| **2NF** | 1NF + no partial dependencies | ProductName depends on ProductID only |
| **3NF** | 2NF + no transitive dependencies | City depends on Zip, not CustomerID |
| **BCNF** | 3NF + every determinant is a candidate key | Overlapping candidate keys |

**Normalization Steps:**

1. **Identify all entities and attributes**
2. **Define functional dependencies**
3. **Apply 1NF** → Eliminate repeating groups
4. **Apply 2NF** → Remove partial dependencies
5. **Apply 3NF** → Remove transitive dependencies
6. **Apply BCNF** → Check all determinants

### 1.4 Data Types (PostgreSQL)

| Category | Type | Use Case |
|----------|------|----------|
| Numeric | INTEGER | IDs, counts |
| Numeric | NUMERIC(10,2) | Currency, prices |
| Text | VARCHAR(255) | Short strings |
| Text | TEXT | Long text |
| Date/Time | TIMESTAMPTZ | Dates with timezone |
| Boolean | BOOLEAN | Yes/No flags |
| Special | JSONB | Semi-structured data |
| Special | UUID | Unique identifiers |

### 1.5 Constraints

| Constraint | Purpose | Syntax |
|------------|---------|--------|
| PRIMARY KEY | Unique identifier for each row | `id SERIAL PRIMARY KEY` |
| FOREIGN KEY | References another table | `customer_id INTEGER REFERENCES customers(id)` |
| NOT NULL | Field cannot be empty | `name VARCHAR(255) NOT NULL` |
| UNIQUE | All values must be different | `email VARCHAR(255) UNIQUE` |
| CHECK | Validate data | `CHECK (price >= 0)` |
| DEFAULT | Default value | `created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP` |

### 1.6 ON DELETE Actions

| Action | Behavior |
|--------|----------|
| **RESTRICT** | Prevent deletion if child rows exist |
| **CASCADE** | Delete child rows automatically |
| **SET NULL** | Set foreign key to NULL |
| **SET DEFAULT** | Set foreign key to default value |
| **NO ACTION** | Similar to RESTRICT |

### 1.7 ScaleCart Core Tables

**Categories (Self-Referencing)**
```
- id (PK)
- name (UNIQUE)
- parent_category_id (FK to categories.id)
- description
- created_at
- updated_at
```

**Products (Core Catalog)**
```
- id (PK)
- name (NOT NULL)
- description
- price (CHECK >= 0)
- category_id (FK to categories.id)
- sku (UNIQUE)
- weight_kg
- search_vector (GENERATED)
- created_at
- updated_at
```

**Customers**
```
- id (PK)
- email (UNIQUE, NOT NULL)
- password_hash (NOT NULL)
- full_name (NOT NULL)
- phone
- registered_at
- last_login
- is_active
- is_verified
- version (optimistic locking)
- created_at
- updated_at
```

**Orders**
```
- id (PK)
- customer_id (FK to customers.id)
- order_date
- status (CHECK: pending, paid, shipped, delivered, cancelled)
- total_amount (CHECK >= 0)
- shipping_address_id (FK to addresses.id)
- billing_address_id (FK to addresses.id)
- notes
- created_at
- updated_at
```

**Order Items**
```
- order_id (FK to orders.id) [PK]
- product_id (FK to products.id) [PK]
- quantity (CHECK > 0)
- unit_price (CHECK >= 0)
- discount_percent (CHECK 0-100)
- created_at
```

---

## PART 2: SQL PERFORMANCE & OPTIMIZATION

### 2.1 Query Execution

**Execution Pipeline:**
```
Parser → Rewriter → Planner → Executor
```

**Scan Types:**

| Type | Description | When Used |
|------|-------------|-----------|
| **Sequential Scan** | Reads every row | Small tables, low selectivity |
| **Index Scan** | Uses index to find rows | High selectivity, indexed columns |
| **Bitmap Scan** | Combines multiple indexes | Multiple conditions |
| **Index Only Scan** | Reads from index only | Covering indexes |

**Join Types:**

| Type | Description | Best For |
|------|-------------|----------|
| **Nested Loop** | For each outer row, scan inner | Small outer table |
| **Hash Join** | Build hash table of one table | Larger tables, equality conditions |
| **Merge Join** | Sort and merge | Sorted inputs |

### 2.2 EXPLAIN ANALYZE

**Reading EXPLAIN Output:**
```
Seq Scan on orders  (cost=0.00..25000.00 rows=1000 width=100)
  (actual time=0.123..123.456 rows=150 loops=1)
  Filter: (customer_id = 42)
  Rows Removed by Filter: 1999850
  Planning Time: 0.234 ms
  Execution Time: 123.789 ms
```

**Key Components:**
- **Cost:** Estimated resource usage
- **Rows:** Estimated rows returned
- **Actual time:** Real execution time
- **loops:** Number of executions
- **Filter:** WHERE condition
- **Rows Removed:** Non-matching rows

### 2.3 Index Types

| Index Type | Use Case | Example |
|------------|----------|---------|
| **B-Tree** | Equality, range queries | `CREATE INDEX ON table(column)` |
| **GIN** | Full-text, arrays, JSONB | `CREATE INDEX ON table USING GIN(vector)` |
| **GiST** | Geospatial, nearest neighbor | `CREATE INDEX ON table USING GiST(geom)` |
| **BRIN** | Very large ordered tables | `CREATE INDEX ON table USING BRIN(date)` |
| **Partial** | Subset of rows | `CREATE INDEX ON table(column) WHERE condition` |
| **Composite** | Multiple columns | `CREATE INDEX ON table(col1, col2)` |
| **Covering** | Include extra columns | `CREATE INDEX ON table(col) INCLUDE (col2)` |

### 2.4 Index Best Practices

**When to Index:**
- Columns used in WHERE
- Columns used in JOIN
- Columns used in ORDER BY
- High selectivity columns
- Large tables (>10k rows)

**When NOT to Index:**
- Very small tables (<1k rows)
- Low selectivity columns
- Rarely used columns
- High write tables (INSERT/UPDATE/DELETE)

**Index Creation:**
```sql
-- Basic index
CREATE INDEX idx_name ON table(column);

-- Concurrent (no locking)
CREATE INDEX CONCURRENTLY idx_name ON table(column);

-- Composite index
CREATE INDEX idx_name ON table(col1, col2);

-- Partial index
CREATE INDEX idx_name ON table(column) WHERE condition;

-- Covering index
CREATE INDEX idx_name ON table(col1) INCLUDE (col2, col3);
```

### 2.5 Query Optimization Tips

**Best Practices:**
1. Use `SELECT` only needed columns
2. Use `LIMIT` for large result sets
3. Use `EXISTS` instead of `COUNT` for existence
4. Use `JOIN` instead of correlated subqueries
5. Use `WITH` (CTE) for complex queries
6. Use appropriate indexes
7. Avoid leading wildcards in `LIKE`
8. Use `UNION` instead of `OR` for different columns
9. Update statistics regularly (`ANALYZE`)

### 2.6 Partitioning

**Definition:** Splitting a table into smaller pieces.

**Types:**
- **Range:** By date or numeric range
- **List:** By discrete values
- **Hash:** Even distribution

**Benefits:**
- Faster queries (partition pruning)
- Easier data lifecycle management
- Parallel scans
- Better maintenance (VACUUM)

**Example:**
```sql
-- Create partitioned table
CREATE TABLE orders_partitioned (
    id SERIAL,
    order_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20),
    PRIMARY KEY (id, order_date)
) PARTITION BY RANGE (order_date);

-- Create partitions
CREATE TABLE orders_2024 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
```

### 2.7 Sharding

**Definition:** Distributing data across multiple servers.

**Strategies:**
- **Range sharding:** By key range
- **Hash sharding:** Consistent hashing
- **Directory sharding:** Lookup table

**Challenges:**
- Cross-shard queries
- Rebalancing
- Hot spots

---

## PART 3: TRANSACTIONS & CONCURRENCY

### 3.1 ACID Properties

| Property | Definition | Implementation |
|----------|------------|----------------|
| **Atomicity** | All or nothing | Transaction log, COMMIT/ROLLBACK |
| **Consistency** | Valid state | Constraints, triggers |
| **Isolation** | No interference | Locks, isolation levels |
| **Durability** | Survives crashes | WAL (Write-Ahead Log) |

### 3.2 Isolation Levels

| Level | Dirty Reads | Non-Repeatable | Phantom |
|-------|-------------|----------------|---------|
| **READ UNCOMMITTED** | ✅ | ✅ | ✅ |
| **READ COMMITTED** | ❌ | ✅ | ✅ |
| **REPEATABLE READ** | ❌ | ❌ | ❌ (PostgreSQL) |
| **SERIALIZABLE** | ❌ | ❌ | ❌ |

**PostgreSQL Default:** READ COMMITTED

### 3.3 Concurrency Anomalies

**Dirty Read:** Reading uncommitted data from another transaction.

**Non-Repeatable Read:** Reading the same row twice with different results.

**Phantom Read:** New rows appearing in a query result.

### 3.4 Locking

**Lock Types:**
| Lock | Allows | Blocks |
|------|--------|--------|
| **Shared (SHARE)** | Reads | Writes |
| **Exclusive (FOR UPDATE)** | Nothing | Reads and writes |

**Pessimistic Locking:**
```sql
BEGIN;
SELECT * FROM inventory WHERE product_id = 1 FOR UPDATE;
-- Other transactions cannot read or write this row
UPDATE inventory SET stock_quantity = stock_quantity - 2 WHERE product_id = 1;
COMMIT;
```

**Optimistic Locking:**
```sql
-- Add version column
ALTER TABLE products ADD COLUMN version INTEGER DEFAULT 1;

-- Update with version check
UPDATE products 
SET price = 99.99, version = version + 1 
WHERE id = 1 AND version = 1;
-- If 0 rows updated, conflict occurred
```

### 3.5 Deadlocks

**Definition:** Two transactions waiting for each other.

**Prevention:**
1. Lock in consistent order
2. Keep transactions short
3. Use appropriate isolation levels
4. Retry on deadlock

### 3.6 Zero-Downtime Migrations

**Key Principles:**
1. Backward compatibility
2. Multi-phase migrations
3. Rollback capability

**Migration Patterns:**

| Pattern | Approach |
|---------|----------|
| **Add column** | Add with DEFAULT, then make NOT NULL |
| **Rename column** | Add new, backfill, update code, drop old |
| **Change type** | Add new column, convert, switch, drop old |
| **Drop column** | Remove code usage first |
| **Add index** | Use CONCURRENTLY |

**Expand and Contract:**
1. Expand: Add new columns
2. Migrate: Update data
3. Contract: Remove old columns

---

## PART 4: MODERN DATA ARCHITECTURES

### 4.1 NoSQL Categories

| Category | Description | Examples | Use Cases |
|----------|-------------|----------|-----------|
| **Document** | JSON-like documents | MongoDB, Couchbase | Flexible schemas |
| **Key-Value** | Simple key-value pairs | Redis, DynamoDB | Caching, sessions |
| **Wide-Column** | Sparse tables | Cassandra, HBase | Time-series, IoT |
| **Graph** | Nodes and relationships | Neo4j, Neptune | Social graphs, recommendations |
| **Time-Series** | Time-stamped data | TimescaleDB, InfluxDB | Metrics, monitoring |
| **Search** | Full-text search | Elasticsearch, Solr | Logs, search |

### 4.2 When to Use NoSQL

| Use Case | Best Choice |
|----------|-------------|
| Flexible schema | Document (MongoDB) |
| High write throughput | Wide-Column (Cassandra) |
| Complex relationships | Graph (Neo4j) |
| Caching | Key-Value (Redis) |
| Full-text search | Search (Elasticsearch) |
| Time-series data | Time-Series (TimescaleDB) |
| Strong consistency | SQL (PostgreSQL) |
| ACID transactions | SQL (PostgreSQL) |

### 4.3 CAP Theorem

**Definition:** In distributed systems, you can only have two of three:

```
                     ┌──────────┐
                    │CONSISTENCY│
                    └────┬─────┘
                         │
              ┌──────────┼──────────┐
              │          │          │
              │          │          │
         ┌────▼────┐     │    ┌─────▼────┐
         │   CP    │     │    │   AP     │
         └────┬────┘     │    └─────┬────┘
              │          │          │
              └──────────┼──────────┘
                         │
                    ┌────▼─────┐
                    │AVAILABILITY│
                    └──────────┘
```

**Systems by Type:**
- **CA:** Single-node PostgreSQL (no partition tolerance)
- **CP:** PostgreSQL cluster, MongoDB (majority writes)
- **AP:** Redis, Cassandra, DynamoDB

### 4.4 Distributed Patterns

**Transactional Outbox:**
```
Business Operation → Write to outbox (same transaction)
                    → Publisher reads outbox
                    → Publishes events
```

**Saga Pattern:**
```
Distributed Transaction → Sequence of local transactions
                        → Compensating actions on failure
```

**Event-Driven Architecture:**
```
Events as first-class citizens → Loose coupling
                               → Asynchronous processing
                               → Scalability
```

### 4.5 Polyglot Persistence

**Definition:** Using multiple database technologies for different workloads.

**ScaleCart Example:**
| Workload | Database | Why |
|----------|----------|-----|
| Core data | PostgreSQL | ACID, complex queries |
| Caching | Redis | Speed, TTL |
| Product catalog | MongoDB | Flexible schema |
| Recommendations | Neo4j | Relationship traversal |
| Analytics | TimescaleDB | Time-series aggregates |

---

## QUICK REFERENCE CARDS

### SQL Reference

```sql
-- SELECT
SELECT column1, column2 FROM table WHERE condition ORDER BY column LIMIT 10;

-- INSERT
INSERT INTO table (col1, col2) VALUES (val1, val2);

-- UPDATE
UPDATE table SET col1 = val1 WHERE condition;

-- DELETE
DELETE FROM table WHERE condition;

-- CREATE TABLE
CREATE TABLE table_name (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- CREATE INDEX
CREATE INDEX idx_name ON table(column);
CREATE INDEX CONCURRENTLY idx_name ON table(column);

-- EXPLAIN
EXPLAIN ANALYZE SELECT * FROM table WHERE condition;

-- TRANSACTION
BEGIN;
-- operations
COMMIT; -- or ROLLBACK;
```

### Index Creation Cheat Sheet

```sql
-- Single column
CREATE INDEX idx_name ON table(column);

-- Composite
CREATE INDEX idx_name ON table(col1, col2);

-- Unique
CREATE UNIQUE INDEX idx_name ON table(column);

-- Partial
CREATE INDEX idx_name ON table(column) WHERE condition;

-- Covering
CREATE INDEX idx_name ON table(col1) INCLUDE (col2, col3);

-- GIN (full-text)
CREATE INDEX idx_name ON table USING GIN(search_vector);

-- GiST (geospatial)
CREATE INDEX idx_name ON table USING GiST(geom);

-- BRIN (time-series)
CREATE INDEX idx_name ON table USING BRIN(timestamp);
```

### Performance Tuning Checklist

```
□ Run EXPLAIN ANALYZE on slow queries
□ Create indexes for WHERE, JOIN, ORDER BY
□ Use composite indexes for multiple columns
□ Use partial indexes for filtered data
□ Use covering indexes for frequent queries
□ Avoid leading wildcards in LIKE
□ Use LIMIT for large result sets
□ Update statistics (ANALYZE)
□ Vacuum regularly (VACUUM)
□ Consider partitioning for large tables
□ Monitor index usage
□ Drop unused indexes
□ Use connection pooling
□ Implement caching
```

### ACID Quick Reference

```
A = Atomicity     → All or nothing
C = Consistency   → Valid state
I = Isolation     → No interference
D = Durability    → Survives crashes
```

### Isolation Levels Quick Reference

```
READ UNCOMMITTED → Dirty reads allowed (NOT recommended)
READ COMMITTED   → No dirty reads (PostgreSQL default)
REPEATABLE READ  → Consistent snapshot
SERIALIZABLE     → Strongest consistency
```

### Lock Types Quick Reference

```
SHARE (FOR SHARE)       → Allows reads, blocks writes
EXCLUSIVE (FOR UPDATE)  → Blocks reads and writes
```

### NoSQL Decision Matrix

```
┌─────────────────────────────────────────────────────────────────┐
│                   NOSQL DECISION MATRIX                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  NEED                    →     CHOOSE                          │
│  ─────                         ──────                          │
│  Flexible schema               Document (MongoDB)             │
│  High write throughput         Wide-Column (Cassandra)        │
│  Complex relationships         Graph (Neo4j)                  │
│  Fast lookups                  Key-Value (Redis)              │
│  Full-text search              Search (Elasticsearch)          │
│  Time-series data              Time-Series (TimescaleDB)       │
│  ACID transactions             SQL (PostgreSQL)               │
│  Strong consistency            SQL (PostgreSQL)               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### ScaleCart Entity Summary

| Entity | Primary Key | Foreign Keys | Key Relationships |
|--------|-------------|--------------|-------------------|
| Category | id | parent_category_id | Self-reference (subcategories) |
| Product | id | category_id | Category(1) → Product(N) |
| Supplier | id | - | Supplier(N) ↔ Product(N) |
| Customer | id | - | Customer(1) → Order(N) |
| Address | id | customer_id | Customer(1) → Address(N) |
| Order | id | customer_id, address_ids | Customer(1) → Order(N) |
| Order Item | (order_id, product_id) | order_id, product_id | Order(1) → OrderItem(N) |
| Inventory | product_id | product_id | Product(1) ↔ Inventory(1) |
| Payment | id | order_id | Order(1) → Payment(N) |
| Review | id | product_id, customer_id | Product(1) → Review(N) |

---

## NOTES SPACE

Use this space for additional notes, diagrams, and examples:

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

**[END OF STUDENT NOTES]**

*These notes cover all key concepts from the Mastering Modern Database Design series. Use them as a reference during lectures and for exam preparation.*
