# Part 3 — Transactions, Concurrency & Data Integrity

## Build Systems That Remain Correct Under Load

---

### Introduction to Part 3

Welcome to the concurrency phase. In Parts 1 and 2, we built a fast, scalable database. Now we need to ensure it stays **correct** when hundreds of users interact simultaneously—placing orders, updating inventory, and modifying their profiles.

Concurrency problems rarely appear during development. They emerge under production traffic when two transactions overlap in unexpected ways. This part focuses on protecting your data integrity under real-world workloads.

We will cover:

1. **ACID Transactions in Practice** – Understanding atomicity, consistency, isolation, and durability.
2. **Concurrency Control** – Preventing dirty reads, non-repeatable reads, and phantom reads.
3. **Locking Strategies** – Optimistic vs. pessimistic locking, deadlock detection and avoidance.
4. **Zero-Downtime Database Changes** – Online schema migrations, rolling deployments, and backward-compatible evolution.

By the end, your ScaleCart application will handle concurrent operations safely, protect against race conditions, and evolve without downtime.

**Estimated time:** 4-6 hours.

---

## Section 3.1 – ACID Transactions in Practice

### 3.1.1 The Target

We'll implement transactional workflows that guarantee data integrity, even when multiple operations must succeed or fail together.

### 3.1.2 The Concept – The Four Pillars

**Analogy:** Imagine transferring money between two bank accounts. You must debit one account and credit the other. If the system crashes after the debit but before the credit, money disappears. ACID prevents this.

**ACID Definitions:**

- **Atomicity** – All operations in a transaction succeed or none do. If any part fails, the entire transaction rolls back.
- **Consistency** – The database remains in a valid state before and after the transaction. All constraints (foreign keys, check constraints, triggers) are enforced.
- **Isolation** – Concurrent transactions don't interfere with each other. Each transaction sees the database as if it were the only one running.
- **Durability** – Once a transaction commits, its changes survive system crashes (written to disk, WAL).

**PostgreSQL Implementation:**
- Every statement runs in a transaction (autocommit can be disabled).
- `BEGIN` starts a transaction block.
- `COMMIT` makes changes permanent.
- `ROLLBACK` undoes all changes in the transaction.

### 3.1.3 Implementing the Order Placement Transaction

This is a critical workflow in ScaleCart: a customer places an order, which must:
1. Create the order record.
2. Add order items.
3. Reduce inventory quantities.
4. Create a payment record.
5. Update customer order count (optional).

**All or nothing:**

```sql
-- Start transaction
BEGIN;

-- 1. Create the order
INSERT INTO orders (customer_id, status, total_amount)
VALUES (42, 'pending', 0.00)
RETURNING id;

-- Assume we got order_id = 1001

-- 2. Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES 
    (1001, 1, 2, 2499.99),
    (1001, 5, 1, 14.99);

-- 3. Reduce inventory (with stock check)
UPDATE inventory 
SET stock_quantity = stock_quantity - 2,
    last_updated = CURRENT_TIMESTAMP
WHERE product_id = 1 
  AND stock_quantity >= 2;

UPDATE inventory 
SET stock_quantity = stock_quantity - 1,
    last_updated = CURRENT_TIMESTAMP
WHERE product_id = 5 
  AND stock_quantity >= 1;

-- 4. Update order total (or compute from items)
UPDATE orders 
SET total_amount = (
    SELECT SUM(quantity * unit_price) 
    FROM order_items 
    WHERE order_id = 1001
)
WHERE id = 1001;

-- 5. Create payment record (simulated)
INSERT INTO payments (order_id, amount, method, status)
VALUES (1001, 5014.97, 'credit_card', 'pending');

-- If all succeeded:
COMMIT;

-- If any step fails (e.g., insufficient stock):
ROLLBACK;
```

### 3.1.4 Python Implementation with Error Handling

**File:** `src/services/order_service.py`

```python
# File: src/services/order_service.py
"""
Order placement service with transactional integrity.
"""

import psycopg2
from psycopg2 import sql, extras
from typing import List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class OrderService:
    def __init__(self, db_connection):
        self.conn = db_connection

    def place_order(self, customer_id: int, items: List[Dict[str, Any]]) -> int:
        """
        Place an order atomically.
        items: [{'product_id': 1, 'quantity': 2}, ...]
        Returns order_id on success, raises exception on failure.
        """
        # Use a transaction context manager
        with self.conn:
            with self.conn.cursor() as cur:
                try:
                    # Step 1: Create order (pending status)
                    cur.execute(
                        "INSERT INTO orders (customer_id, status, total_amount) "
                        "VALUES (%s, 'pending', 0.00) RETURNING id",
                        (customer_id,)
                    )
                    order_id = cur.fetchone()[0]
                    logger.info(f"Created order {order_id} for customer {customer_id}")

                    # Step 2: Insert items and check inventory
                    total = 0.0
                    for item in items:
                        product_id = item['product_id']
                        quantity = item['quantity']

                        # Get current price from products table
                        cur.execute(
                            "SELECT price FROM products WHERE id = %s",
                            (product_id,)
                        )
                        result = cur.fetchone()
                        if not result:
                            raise ValueError(f"Product {product_id} not found")
                        unit_price = float(result[0])

                        # Insert order item
                        cur.execute(
                            "INSERT INTO order_items (order_id, product_id, quantity, unit_price) "
                            "VALUES (%s, %s, %s, %s)",
                            (order_id, product_id, quantity, unit_price)
                        )

                        # Reduce inventory with check
                        cur.execute(
                            "UPDATE inventory "
                            "SET stock_quantity = stock_quantity - %s, "
                            "    last_updated = CURRENT_TIMESTAMP "
                            "WHERE product_id = %s "
                            "  AND stock_quantity >= %s "
                            "RETURNING stock_quantity",
                            (quantity, product_id, quantity)
                        )
                        new_stock = cur.fetchone()
                        if not new_stock:
                            raise ValueError(
                                f"Insufficient stock for product {product_id}. "
                                f"Requested {quantity}."
                            )

                        total += quantity * unit_price
                        logger.debug(f"Reserved {quantity} of product {product_id}")

                    # Step 3: Update order total
                    cur.execute(
                        "UPDATE orders SET total_amount = %s WHERE id = %s",
                        (round(total, 2), order_id)
                    )

                    # Step 4: Create payment record (simulated)
                    cur.execute(
                        "INSERT INTO payments (order_id, amount, method, status) "
                        "VALUES (%s, %s, 'credit_card', 'pending')",
                        (order_id, round(total, 2))
                    )

                    # Step 5: Commit (auto-committed when exiting 'with self.conn:')
                    logger.info(f"Order {order_id} placed successfully for ${total:.2f}")
                    return order_id

                except Exception as e:
                    # Rollback happens automatically when 'with self.conn:' exits
                    logger.error(f"Order placement failed: {e}")
                    raise

    def get_order_with_items(self, order_id: int) -> Dict[str, Any]:
        """Retrieve order and its items (read-only, no transaction needed)."""
        with self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            # Get order
            cur.execute(
                "SELECT id, customer_id, order_date, status, total_amount "
                "FROM orders WHERE id = %s",
                (order_id,)
            )
            order = cur.fetchone()
            if not order:
                raise ValueError(f"Order {order_id} not found")

            # Get items
            cur.execute(
                "SELECT product_id, quantity, unit_price, "
                "       (quantity * unit_price) as subtotal "
                "FROM order_items WHERE order_id = %s",
                (order_id,)
            )
            order['items'] = cur.fetchall()

            return order
```

### 3.1.5 Testing the Transaction

**File:** `src/scripts/test_order.py`

```python
# File: src/scripts/test_order.py
import psycopg2
from src.services.order_service import OrderService

def main():
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        user="scalecart",
        password="scalecart_password",
        dbname="scalecart"
    )
    # Disable autocommit so we control transactions
    conn.autocommit = False

    service = OrderService(conn)

    # Test 1: Successful order
    try:
        items = [
            {'product_id': 1, 'quantity': 2},
            {'product_id': 5, 'quantity': 1}
        ]
        order_id = service.place_order(42, items)
        print(f"✅ Order {order_id} created successfully")

        # Verify
        order = service.get_order_with_items(order_id)
        print(f"Order total: ${order['total_amount']}")
        for item in order['items']:
            print(f"  Product {item['product_id']}: {item['quantity']} @ ${item['unit_price']}")

    except Exception as e:
        print(f"❌ Order failed: {e}")

    # Test 2: Insufficient stock (should roll back)
    try:
        items = [{'product_id': 1, 'quantity': 999999}]
        service.place_order(42, items)
        print("❌ This shouldn't succeed")
    except Exception as e:
        print(f"✅ Order correctly failed: {e}")

    conn.close()

if __name__ == "__main__":
    main()
```

**Run the test:**

```bash
python src/scripts/test_order.py
```

---

## Section 3.2 – Concurrency Control

### 3.2.1 The Target

We'll understand isolation levels and how to prevent concurrency anomalies like dirty reads, non-repeatable reads, and phantom reads.

### 3.2.2 The Concept – Isolation Levels

**Analogy:** Imagine two people updating the same Excel spreadsheet simultaneously. Without coordination, one person's changes can be overwritten or based on stale data. Isolation levels control how much interference is allowed.

**PostgreSQL Isolation Levels:**

| Level | Dirty Read | Non-Repeatable Read | Phantom Read | Description |
|-------|------------|---------------------|--------------|-------------|
| READ UNCOMMITTED | ✅ Possible | ✅ Possible | ✅ Possible | Can see uncommitted changes (not allowed in PostgreSQL) |
| READ COMMITTED | ❌ Not possible | ✅ Possible | ✅ Possible | Sees only committed changes; default in PostgreSQL |
| REPEATABLE READ | ❌ Not possible | ❌ Not possible | ✅ Possible | Sees a snapshot from transaction start |
| SERIALIZABLE | ❌ Not possible | ❌ Not possible | ❌ Not possible | Strongest; mimics sequential execution |

**Anomalies Explained:**
- **Dirty Read** – Reading uncommitted data from another transaction (can be rolled back).
- **Non-Repeatable Read** – Reading the same row twice and getting different values because another transaction updated it.
- **Phantom Read** – A query returns different rows on second execution because another transaction inserted/deleted rows.

### 3.2.3 Demo: Non-Repeatable Read

**Session 1:**

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT stock_quantity FROM inventory WHERE product_id = 1;
-- Returns: 50

-- Session 2 updates stock (in another terminal)
-- Update to 45

SELECT stock_quantity FROM inventory WHERE product_id = 1;
-- Returns: 45 (different value!)
```

**Fix:** Use `REPEATABLE READ`.

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT stock_quantity FROM inventory WHERE product_id = 1;
-- Returns: 50

-- Session 2 updates to 45 (but Session 1 still sees 50)

SELECT stock_quantity FROM inventory WHERE product_id = 1;
-- Returns: 50 (same as before)
COMMIT;
```

### 3.2.4 Demo: Phantom Read

**Session 1 (REPEATABLE READ):**

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT COUNT(*) FROM orders WHERE status = 'pending';
-- Returns: 5

-- Session 2 inserts a new pending order

SELECT COUNT(*) FROM orders WHERE status = 'pending';
-- Returns: 5 (still 5, no phantom!)
```

Actually, in PostgreSQL's `REPEATABLE READ`, phantom reads are also prevented (it's stronger than the SQL standard). For true serializable, use `SERIALIZABLE`.

### 3.2.5 Choosing the Right Level

| Workload | Recommended Level | Why |
|----------|-------------------|-----|
| Reports, analytics | REPEATABLE READ | Consistent snapshot for long-running queries |
| OLTP (e-commerce) | READ COMMITTED | Good balance; handle conflicts in application |
| Financial transactions | SERIALIZABLE | Highest integrity, but lower concurrency |

**ScaleCart Decision:** Use `READ COMMITTED` for most operations, and `SERIALIZABLE` only for critical financial operations (e.g., transferring loyalty points).

---

## Section 3.3 – Locking Strategies

### 3.3.1 The Target

We'll implement optimistic and pessimistic locking to prevent update conflicts, and learn to detect and avoid deadlocks.

### 3.3.2 The Concept – Two Approaches

**Analogy:** 
- **Pessimistic locking** – "Hold the door" – lock the resource so others can't use it until you're done.
- **Optimistic locking** – "Don't hold the door, but check if someone slipped in" – proceed without locks, but verify no one changed the data before committing.

### 3.3.3 Pessimistic Locking (Explicit Row Locks)

**Use Case:** Updating inventory during checkout. We want to lock the row so no one else can change it.

```sql
BEGIN;

-- Select for update (locks the row)
SELECT stock_quantity FROM inventory 
WHERE product_id = 1 
FOR UPDATE;

-- Check stock, perform update
UPDATE inventory 
SET stock_quantity = stock_quantity - 2 
WHERE product_id = 1;

COMMIT;  -- Lock released
```

**In Python:**

```python
def reserve_inventory(self, product_id, quantity):
    with self.conn:
        with self.conn.cursor() as cur:
            # Lock the row
            cur.execute(
                "SELECT stock_quantity FROM inventory "
                "WHERE product_id = %s FOR UPDATE",
                (product_id,)
            )
            current_stock = cur.fetchone()[0]
            
            if current_stock < quantity:
                raise ValueError(f"Insufficient stock. Have {current_stock}, need {quantity}")
            
            cur.execute(
                "UPDATE inventory SET stock_quantity = stock_quantity - %s "
                "WHERE product_id = %s",
                (quantity, product_id)
            )
```

**Lock Modes:**
- `FOR UPDATE` – Row-level lock (exclusive).
- `FOR SHARE` – Shared lock (others can read, not write).
- `FOR NO KEY UPDATE` – Less strict (for when not updating key).
- `FOR KEY SHARE` – Only lock key columns.

**Skip Locked (for queue processing):**

```sql
SELECT * FROM orders 
WHERE status = 'pending' 
ORDER BY order_date 
LIMIT 10 
FOR UPDATE SKIP LOCKED;
```

### 3.3.4 Optimistic Locking (Version Number)

**Use Case:** Updating customer profile; conflicts are rare.

**Schema change:**

```sql
ALTER TABLE customers ADD COLUMN version INTEGER DEFAULT 1;
```

**Implementation:**

```python
def update_customer_email(self, customer_id, new_email):
    with self.conn:
        with self.conn.cursor() as cur:
            # Read current version
            cur.execute(
                "SELECT version FROM customers WHERE id = %s",
                (customer_id,)
            )
            current_version = cur.fetchone()[0]
            
            # Update only if version hasn't changed
            cur.execute(
                "UPDATE customers SET email = %s, version = version + 1 "
                "WHERE id = %s AND version = %s",
                (new_email, customer_id, current_version)
            )
            rows_updated = cur.rowcount
            
            if rows_updated == 0:
                raise ValueError("Customer was modified by another transaction. Retry.")
```

### 3.3.5 Deadlocks – Detection and Avoidance

**Deadlock:** Two transactions waiting for each other's locks.

**Example:**

```
Transaction A: UPDATE inventory SET ... WHERE product_id = 1; (locks row 1)
Transaction B: UPDATE inventory SET ... WHERE product_id = 2; (locks row 2)
Transaction A: UPDATE inventory SET ... WHERE product_id = 2; (waits for B)
Transaction B: UPDATE inventory SET ... WHERE product_id = 1; (waits for A)
--> DEADLOCK
```

**PostgreSQL detects and kills one transaction:**

```
ERROR: deadlock detected
DETAIL: Process 1234 waits for ShareLock on transaction 5678; blocked by process 5678.
HINT: See server log for query details.
```

**Best Practices to Avoid Deadlocks:**
1. **Lock in consistent order** – Always lock tables in the same order (e.g., by product_id ascending).
2. **Keep transactions short** – Reduce the window for conflicts.
3. **Retry on deadlock** – Catch the error and retry the transaction.

**Retry logic in Python:**

```python
import time
from psycopg2 import errors

def place_order_with_retry(self, customer_id, items, max_retries=3):
    for attempt in range(max_retries):
        try:
            return self.place_order(customer_id, items)
        except errors.SerializationFailure as e:
            if attempt == max_retries - 1:
                raise
            wait = 2 ** attempt  # Exponential backoff
            logger.warning(f"Deadlock detected, retrying in {wait}s...")
            time.sleep(wait)
    raise RuntimeError("Max retries exceeded")
```

### 3.3.6 Verification – Locking Tests

**Test pessimistic locking:**
1. Open two database sessions.
2. In Session 1, `BEGIN; SELECT FOR UPDATE;`
3. In Session 2, try to update the same row (should block).
4. Commit Session 1; Session 2 should proceed.

**Test deadlock detection:**
1. Session 1: Update row 1, then row 2.
2. Session 2: Update row 2, then row 1.
3. Observe which transaction gets killed.

---

## Section 3.4 – Zero-Downtime Database Changes

### 3.4.1 The Target

We'll implement schema migrations that don't cause downtime, using online migration techniques and backward-compatible changes.

### 3.4.2 The Concept – Evolving Without Disruption

**Analogy:** Changing a tire while the car is moving. You need to be careful, use specialized tools, and never remove all support at once.

**Principles:**
1. **Backward-compatible changes** – Don't break existing queries.
2. **Multi-phase migrations** – Add, then migrate, then remove.
3. **Use transactions carefully** – Some migrations can't be rolled back easily.
4. **Test on staging first.**

### 3.4.3 Safe Migration Patterns

**Pattern 1: Adding a column with default**

```sql
-- SAFE: Adding with DEFAULT in one transaction
ALTER TABLE products ADD COLUMN weight_kg NUMERIC(5,2) DEFAULT 0.0 NOT NULL;
-- This locks the table briefly, but is fine for small tables.

-- For large tables, use:
ALTER TABLE products ADD COLUMN weight_kg NUMERIC(5,2);
-- Then backfill in batches, then set NOT NULL
```

**Pattern 2: Renaming a column**

```sql
-- Step 1: Add new column
ALTER TABLE customers ADD COLUMN first_name VARCHAR(50);

-- Step 2: Backfill data (in batches)
UPDATE customers SET first_name = split_part(full_name, ' ', 1);

-- Step 3: Deploy code that uses both old and new columns
-- Step 4: Drop old column (after verifying no code uses it)
ALTER TABLE customers DROP COLUMN full_name;
```

**Pattern 3: Changing data type**

```sql
-- Step 1: Add new column with new type
ALTER TABLE orders ADD COLUMN total_amount_new NUMERIC(12,2);

-- Step 2: Backfill with conversion
UPDATE orders SET total_amount_new = total_amount::NUMERIC(12,2);

-- Step 3: Add triggers to keep columns in sync
-- Step 4: Switch code to use new column
-- Step 5: Drop old column
```

### 3.4.4 Using Alembic for Migrations

**File:** `alembic.ini` (configured for ScaleCart)

```ini
[alembic]
script_location = src/migrations
prepend_sys_path = .
version_path_separator = os
sqlalchemy.url = postgresql://scalecart:scalecart_password@localhost/scalecart
```

**File:** `src/migrations/env.py`

```python
# File: src/migrations/env.py
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
from src.utils.db import Base  # We'll define models later

config = context.config
fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline():
    context.configure(url=config.get_main_option("sqlalchemy.url"))
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

**Migration Example:** `src/migrations/versions/001_add_weight_to_products.py`

```python
# File: src/migrations/versions/001_add_weight_to_products.py
from alembic import op
import sqlalchemy as sa

# Revision identifiers
revision = '001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    # Add column with DEFAULT (safe for small tables)
    op.add_column('products', sa.Column('weight_kg', sa.Numeric(5, 2), nullable=False, server_default='0.0'))

def downgrade():
    op.drop_column('products', 'weight_kg')
```

### 3.4.5 Online Schema Change Tools

For large tables, use tools that minimize locking:

**pg_repack:** Reorganizes tables without locks.

```bash
# Install pg_repack
apt-get install postgresql-15-repack

# Rebuild table without locking
pg_repack -d scalecart -U scalecart -t products
```

**gh-ost (GitHub's online migration tool for MySQL):**
- Creates a shadow table, copies data incrementally, then swaps.

**In PostgreSQL, use:** 
- `CREATE INDEX CONCURRENTLY` – Builds index without blocking writes.
- `ALTER TABLE ... SET ...` – Many ALTER operations are safe.

**Example: Adding index without downtime:**

```sql
-- This doesn't lock the table for writes
CREATE INDEX CONCURRENTLY idx_products_name ON products(name);
```

### 3.4.6 Rolling Deployments

**Strategy:**
1. **Phase 1:** Deploy code that works with both old and new schema (backward compatible).
2. **Phase 2:** Run migration (add columns, create indexes).
3. **Phase 3:** Deploy code that uses the new schema.
4. **Phase 4:** Remove old columns (after verifying no code uses them).

**Monitoring during migration:**
- Watch for `row_exclusive_locks`.
- Monitor `pg_stat_activity` for long-running queries.
- Set statement timeout to avoid cascading issues.

### 3.4.7 Verification – Migration Test

1. Create a migration that adds a new column.
2. Deploy code that uses the column with a default fallback.
3. Run the migration in a test environment.
4. Verify no downtime by running concurrent read/write workloads.

---

## Section 3.5 – Summary and Exercises

### 3.5.1 What We Accomplished

- Implemented ACID transactions for order placement with rollback on failure.
- Understood isolation levels and prevented concurrency anomalies.
- Used pessimistic and optimistic locking strategies.
- Detected and avoided deadlocks.
- Designed zero-downtime migrations with multi-phase strategies.

Your ScaleCart database can now handle concurrent operations safely and evolve without downtime.

### 3.5.2 Exercises

1. **Implement a transaction** that transfers loyalty points between customers. Ensure atomicity and use appropriate isolation level.

2. **Simulate a deadlock** by running two concurrent transactions that update the same two rows in opposite orders. Implement retry logic.

3. **Create a migration** that adds a `last_login` column to `customers` with a default of `CURRENT_TIMESTAMP`.

4. **Implement an optimistic lock** for updating product prices. Include version checking and retry on conflict.

5. **Design a zero-downtime plan** to split the `full_name` column into `first_name` and `last_name`. Write the migration steps and code changes.

### 3.5.3 Next Steps

In **Part 4 – Modern Data Architectures Beyond SQL**, we will:
- Explore NoSQL databases (MongoDB for documents, Redis for caching).
- Implement Graph databases (Neo4j for social networks and recommendations).
- Work with emerging technologies (time-series, vector databases).
- Build distributed systems (eventual consistency, Saga pattern, Transactional Outbox).
- Design a polyglot persistence architecture for ScaleCart.

