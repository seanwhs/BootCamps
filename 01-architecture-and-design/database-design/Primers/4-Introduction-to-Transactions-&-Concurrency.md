# APPENDIX PRIMER 4 — Introduction to Transactions & Concurrency

## Understanding How Databases Stay Correct Under Pressure

---

## P4.1 Introduction

Welcome to the fourth primer! Now that you understand basic database concepts (Primer 1), relational design (Primer 2), and performance optimization (Primer 3), it's time to tackle one of the most important topics in database systems: **transactions and concurrency**.

This primer will prepare you for Part 3 of the main series.

**By the end of this primer, you will understand:**
- What a transaction is and why it matters
- The ACID properties (Atomicity, Consistency, Isolation, Durability)
- What happens when multiple users access data simultaneously
- The concept of database locks
- Why data can become corrupted without proper controls

**Estimated time:** 30-45 minutes

---

## P4.2 What Is a Transaction?

### P4.2.1 The Analogy: Transferring Money

```
┌─────────────────────────────────────────────────────────────────────┐
│                    TRANSACTION ANALOGY                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Imagine you're transferring $100 from your savings account       │
│   to your checking account:                                       │
│                                                                     │
│   Step 1: Check savings balance (must be >= $100)                │
│   Step 2: Deduct $100 from savings                                │
│   Step 3: Add $100 to checking                                    │
│   Step 4: Record the transaction                                  │
│                                                                     │
│   What if the system crashes after Step 2 but before Step 3?     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ❌ Money disappears from savings                          │ │
│   │  ❌ Money never appears in checking                        │ │
│   │  ❌ You just lost $100!                                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   A TRANSACTION prevents this:                                   │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  ✅ All steps happen together (Atomicity)                 │ │
│   │  ✅ If any step fails, everything is undone (Rollback)    │ │
│   │  ✅ Money is either transferred completely or not at all  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.2.2 What Is a Transaction in Databases?

A **transaction** is a group of database operations that are treated as a single unit of work.

```sql
-- A simple transaction
BEGIN TRANSACTION;

-- All operations in this block are part of one transaction
UPDATE accounts SET balance = balance - 100 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 100 WHERE account_id = 2;
INSERT INTO transactions (from_account, to_account, amount) VALUES (1, 2, 100);

-- If everything succeeded:
COMMIT;  -- Make all changes permanent

-- If anything failed:
ROLLBACK;  -- Undo all changes
```

---

## P4.3 The ACID Properties

ACID is an acronym that defines the four properties of reliable database transactions.

### P4.3.1 Atomicity — "All or Nothing"

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ATOMICITY                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Atomicity means: A transaction is treated as a single,          │
│   indivisible unit.                                               │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │   BEGIN;                                                   │ │
│   │   UPDATE accounts SET balance = 0 WHERE id = 1;           │ │
│   │   UPDATE accounts SET balance = 1000 WHERE id = 2;        │ │
│   │   COMMIT; -- Everything is saved                          │ │
│   │                                                             │ │
│   │   OR                                                       │ │
│   │                                                             │ │
│   │   BEGIN;                                                   │ │
│   │   UPDATE accounts SET balance = 0 WHERE id = 1;           │ │
│   │   UPDATE accounts SET balance = 1000 WHERE id = 2;        │ │
│   │   ROLLBACK; -- Nothing is saved (both updates undone)     │ │
│   │                                                             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Real-world example:                                            │
│   • Placing an order: Create order + Reduce inventory           │
│   • If inventory update fails, order is not created             │
│   • If order creation fails, inventory is not reduced           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.3.2 Consistency — "Keep Data Valid"

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONSISTENCY                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Consistency means: A transaction brings the database from       │
│   one valid state to another valid state.                        │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Valid state means:                                        │ │
│   │  • All constraints are satisfied (foreign keys, check,     │ │
│   │    unique, not null)                                        │ │
│   │  • Business rules are enforced                             │ │
│   │  • Referential integrity is maintained                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Example:                                                       │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Rule: Order total must equal sum of item prices           │ │
│   │                                                             │ │
│   │  Before transaction: Order has valid total                 │ │
│   │  During transaction: Order has zero total (temporarily)    │ │
│   │  After transaction: Order has correct total                │ │
│   │                                                             │ │
│   │  The database is only "consistent" at the start and end    │ │
│   │  of the transaction. The intermediate state is not         │ │
│   │  visible to other transactions.                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.3.3 Isolation — "Transactions Don't Interfere"

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ISOLATION                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Isolation means: Transactions execute as if they were the       │
│   only one running. They don't interfere with each other.        │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Without Isolation:                                        │ │
│   │  Transaction A is running. Transaction B starts.           │ │
│   │  Transaction B reads data that Transaction A is changing.  │ │
│   │  Transaction A rolls back.                                 │ │
│   │  Transaction B just read data that never existed! ❌       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  With Isolation:                                           │ │
│   │  Transaction A is running. Transaction B starts.           │ │
│   │  Transaction B cannot see changes from Transaction A       │ │
│   │  until Transaction A commits.                              │ │
│   │  ✅ Clean, consistent data for both transactions           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.3.4 Durability — "Survives Crashes"

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DURABILITY                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Durability means: Once a transaction commits, its changes       │
│   survive even if the system crashes immediately after.          │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  How it works:                                             │ │
│   │                                                             │ │
│   │  1. Transaction commits                                    │ │
│   │  2. Changes written to Write-Ahead Log (WAL)              │ │
│   │  3. WAL written to disk                                   │ │
│   │  4. Acknowledgment sent to client                          │ │
│   │  5. Data written to main storage (later)                  │ │
│   │                                                             │ │
│   │  If the system crashes after step 4 but before step 5:     │ │
│   │  • On restart, database reads the WAL                     │ │
│   │  • Replays the committed transaction                       │ │
│   │  • Data is restored!                                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Real-world example:                                            │
│   • Customer places an order ✅                                 │
│   • Confirmation email sent ✅                                  │
│   • Database crashes 💥                                         │
│   • When restarted, the order is still there ✅                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P4.4 Concurrency Problems

When multiple users access the database simultaneously, several problems can occur.

### P4.4.1 The Three Concurrency Anomalies

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONCURRENCY ANOMALIES                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. DIRTY READ                                                   │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Transaction A updates a row (but doesn't commit)          │ │
│   │  Transaction B reads that row (sees the uncommitted change) │ │
│   │  Transaction A rolls back (undoes the change)              │ │
│   │  Transaction B just read data that never existed! ❌       │ │
│   │                                                             │ │
│   │  Example: John transfers $100 to Mary. Jane looks at       │ │
│   │  Mary's balance before the transfer completes.             │ │
│   │  Jane sees $100 that hasn't actually been transferred.     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   2. NON-REPEATABLE READ                                          │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Transaction A reads a row                                 │ │
│   │  Transaction B updates that row and commits                │ │
│   │  Transaction A reads the same row again                    │ │
│   │  Transaction A sees different values! ❌                   │ │
│   │                                                             │ │
│   │  Example: Jane looks at John's balance ($100).             │ │
│   │  John transfers $50 to Mary and commits.                   │ │
│   │  Jane looks at John's balance again ($50).                 │ │
│   │  Jane got different answers to the same question.          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   3. PHANTOM READ                                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Transaction A queries for a set of rows                   │ │
│   │  Transaction B inserts a new row that matches the query    │ │
│   │  Transaction A re-runs the query                           │ │
│   │  Transaction A sees new rows that weren't there before! ❌ │ │
│   │                                                             │ │
│   │  Example: Jane looks at all pending orders (5 orders).     │ │
│   │  John places a new order and commits.                      │ │
│   │  Jane looks at pending orders again (6 orders).            │ │
│   │  Jane saw "phantom" orders appear.                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.4.2 Why Concurrency Matters in E-Commerce

```
┌─────────────────────────────────────────────────────────────────────┐
│                    E-COMMERCE CONCURRENCY SCENARIOS               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   SCENARIO 1: The Last Item in Stock                             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Product: MacBook Pro (1 left in stock)                    │ │
│   │                                                             │ │
│   │  Customer A: Adds to cart, starts checkout                 │ │
│   │  Customer B: Adds to cart, starts checkout                 │ │
│   │                                                             │ │
│   │  Without proper locking:                                   │ │
│   │  • Both customers see 1 in stock                          │ │
│   │  • Both place orders                                       │ │
│   │  • Inventory goes to -1 ❌                                 │ │
│   │  • One customer gets cancelled later ❌                    │ │
│   │                                                             │ │
│   │  With proper locking:                                      │ │
│   │  • First customer gets the laptop ✅                       │ │
│   │  • Second customer gets "Out of Stock" message ✅          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   SCENARIO 2: Payment Processing                                  │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Customer: Order placed, payment in progress              │ │
│   │                                                             │ │
│   │  Without transactions:                                      │ │
│   │  • Order created                                            │ │
│   │  • Payment processing fails                                 │ │
│   │  • Order remains in system (unpaid) ❌                     │ │
│   │                                                             │ │
│   │  With transactions:                                         │ │
│   │  • Order and payment are atomic                            │ │
│   │  • If payment fails, order is rolled back ✅               │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P4.5 Database Locks

### P4.5.1 What Is a Lock?

A **lock** is a mechanism that prevents multiple transactions from accessing the same data simultaneously in incompatible ways.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LOCK TYPES                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   SHARED LOCK (Read Lock)                                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Multiple transactions can read the same data              │ │
│   │  No transaction can modify the data                        │ │
│   │  Used for: SELECT queries                                   │ │
│   │  Example: Many customers can view product details          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   EXCLUSIVE LOCK (Write Lock)                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Only one transaction can access the data                  │ │
│   │  No other transaction can read or write                    │ │
│   │  Used for: INSERT, UPDATE, DELETE                          │ │
│   │  Example: Updating inventory for a product                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   LOCK COMPATIBILITY:                                             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                   Shared    Exclusive                      │ │
│   │   Shared        ✅ Allowed  ❌ Blocked                    │ │
│   │   Exclusive     ❌ Blocked  ❌ Blocked                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.5.2 Explicit Locking in SQL

```sql
-- ============================================
-- PESSIMISTIC LOCKING
-- ============================================

-- 1. FOR UPDATE (Exclusive Lock)
BEGIN;
SELECT * FROM inventory WHERE product_id = 1 FOR UPDATE;
-- You now have an exclusive lock on this row
-- Other transactions cannot read or write this row
UPDATE inventory SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
COMMIT;  -- Lock is released

-- 2. FOR SHARE (Shared Lock)
BEGIN;
SELECT * FROM products WHERE id = 1 FOR SHARE;
-- You have a shared lock on this row
-- Other transactions can read, but cannot write
COMMIT;  -- Lock is released

-- 3. FOR UPDATE SKIP LOCKED
-- Skip rows that are already locked
BEGIN;
SELECT * FROM orders 
WHERE status = 'pending' 
LIMIT 10 
FOR UPDATE SKIP LOCKED;
-- This is great for queue processing
COMMIT;
```

---

## P4.6 What Is a Deadlock?

### P4.6.1 The Deadlock Concept

A **deadlock** occurs when two transactions are waiting for each other to release locks.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEADLOCK EXAMPLE                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Transaction A:                                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  BEGIN;                                                    │ │
│   │  UPDATE product SET price = 100 WHERE id = 1; -- Locks row 1 │ │
│   │  -- Then tries to update row 2...                         │ │
│   │  UPDATE product SET price = 200 WHERE id = 2; -- Waits for B │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Transaction B:                                                 │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  BEGIN;                                                    │ │
│   │  UPDATE product SET price = 300 WHERE id = 2; -- Locks row 2 │ │
│   │  -- Then tries to update row 1...                         │ │
│   │  UPDATE product SET price = 400 WHERE id = 1; -- Waits for A │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Result:                                                        │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Transaction A is waiting for Transaction B                │ │
│   │  Transaction B is waiting for Transaction A                │ │
│   │  Neither can proceed! 💥                                   │ │
│   │                                                             │ │
│   │  Database detects this and aborts one transaction.         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.6.2 How to Avoid Deadlocks

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEADLOCK AVOIDANCE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. LOCK IN CONSISTENT ORDER                                    │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Always lock resources in the same order                   │ │
│   │  Example: Always update product 1 before product 2         │ │
│   │  Instead of: Sometimes update product 2 then product 1    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   2. KEEP TRANSACTIONS SHORT                                      │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Do as little work as possible in a transaction            │ │
│   │  Don't wait for user input while holding locks             │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   3. USE OPTIMISTIC LOCKING FOR READ-HEAVY WORKLOADS             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Use version numbers instead of locks                      │ │
│   │  Check if data changed before committing                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   4. RETRY ON DEADLOCK                                            │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Catch deadlock errors and retry the transaction            │ │
│   │  Most deadlocks are resolved on retry                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P4.7 Optimistic vs. Pessimistic Locking

### P4.7.1 Comparison

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LOCKING STRATEGIES COMPARISON                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   PESSIMISTIC LOCKING                                             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Strategy: Lock data before using it                       │ │
│   │  Assumption: Conflicts are likely                         │ │
│   │  Implementation: SELECT ... FOR UPDATE                     │ │
│   │  Best for: High-conflict scenarios (inventory)            │ │
│   │  Performance: Higher overhead, but no retries              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   OPTIMISTIC LOCKING                                              │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Strategy: Don't lock, check before commit                 │ │
│   │  Assumption: Conflicts are rare                           │ │
│   │  Implementation: Version numbers or timestamps             │ │
│   │  Best for: Low-conflict scenarios (customer profiles)     │ │
│   │  Performance: Lower overhead, but retries on conflict      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P4.7.2 Optimistic Locking Example

```sql
-- ============================================
-- OPTIMISTIC LOCKING WITH VERSION NUMBER
-- ============================================

-- Add version column to table
ALTER TABLE customers ADD COLUMN version INTEGER DEFAULT 1;

-- Update with version check
UPDATE customers 
SET 
    email = 'new@email.com',
    version = version + 1
WHERE 
    id = 42 
    AND version = 1;  -- Only works if version hasn't changed

-- If no rows updated, someone else modified the data
-- Retry the transaction
```

---

## P4.8 Why This Matters for ScaleCart

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART TRANSACTION USE CASES                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   PLACING AN ORDER (Critical Transaction)                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. Check inventory                                         │ │
│   │  2. Reserve items                                           │ │
│   │  3. Create order                                            │ │
│   │  4. Add order items                                         │ │
│   │  5. Process payment                                         │ │
│   │  6. Update customer stats                                   │ │
│   │  7. Send confirmation                                       │ │
│   │                                                             │ │
│   │  If any step fails: ALL steps rolled back!                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   CANCELLING AN ORDER (Compensating Transaction)                  │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. Update order status to cancelled                       │ │
│   │  2. Restore inventory                                      │ │
│   │  3. Process refund                                         │ │
│   │  4. Update customer stats                                  │ │
│   │                                                             │ │
│   │  This is a separate transaction that "undoes" the order    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   INVENTORY UPDATE (High-Concurrency Scenario)                    │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Multiple orders for the same product simultaneously      │ │
│   │                                                             │ │
│   │  Without proper locks: ❌ Negative inventory               │ │
│   │  With pessimistic locks: ✅ Correct inventory              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P4.9 Glossary of New Terms

| Term | Definition |
|------|------------|
| **Transaction** | A group of database operations treated as a single unit |
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **Atomicity** | All operations in a transaction succeed or fail together |
| **Consistency** | Transactions maintain valid database state |
| **Isolation** | Transactions don't interfere with each other |
| **Durability** | Committed changes survive system crashes |
| **COMMIT** | Make transaction changes permanent |
| **ROLLBACK** | Undo all changes in a transaction |
| **Dirty Read** | Reading uncommitted data from another transaction |
| **Non-Repeatable Read** | Reading different values for the same data in one transaction |
| **Phantom Read** | New rows appearing in a query result during a transaction |
| **Lock** | Mechanism to prevent concurrent access conflicts |
| **Shared Lock** | Allows multiple reads, no writes |
| **Exclusive Lock** | Only one transaction can access |
| **Deadlock** | Two transactions waiting for each other |
| **Optimistic Locking** | Check for conflicts before committing |
| **Pessimistic Locking** | Lock data before using it |

---

## P4.10 Summary

### P4.10.1 Key Takeaways

1. **Transactions ensure data integrity** – They group operations that must all succeed or fail together.

2. **ACID is the foundation** – Atomicity, Consistency, Isolation, Durability are the four properties that make transactions reliable.

3. **Concurrency problems are real** – Dirty reads, non-repeatable reads, and phantom reads can corrupt data.

4. **Locks prevent conflicts** – Shared locks for reads, exclusive locks for writes.

5. **Deadlocks happen** – Two transactions waiting for each other. Avoid by locking in consistent order.

6. **Choose the right strategy** – Pessimistic for high-conflict, optimistic for low-conflict scenarios.

### P4.10.2 What's Next?

You've completed all four primers! You're now ready for the main series:

**Part 1: Foundations of Relational Database Design**
- Complete database modeling
- Full normalization
- Building the ScaleCart schema

**Part 2: SQL Performance & Advanced Database Optimization**
- Understanding execution plans
- Advanced indexing strategies
- Query optimization
- Scaling to millions of records

**Part 3: Transactions, Concurrency & Data Integrity**
- ACID transactions in practice
- Locking strategies
- Zero-downtime migrations

**Part 4: Modern Data Architectures Beyond SQL**
- NoSQL databases
- Graph databases
- Distributed systems
- Polyglot persistence

---

## P4.11 Quick Quiz

Test your understanding:

1. **What does the "A" in ACID stand for?**
   - A) Availability
   - B) Atomicity
   - C) Authorization
   - D) Accuracy

2. **What happens when you ROLLBACK a transaction?**
   - A) All changes are saved
   - B) All changes are undone
   - C) The transaction pauses
   - D) The database restarts

3. **What is a dirty read?**
   - A) Reading data from a dirty table
   - B) Reading uncommitted data from another transaction
   - C) Reading data that has been deleted
   - D) Reading data from the wrong database

4. **Which lock prevents other transactions from reading or writing?**
   - A) Shared Lock
   - B) Read Lock
   - C) Exclusive Lock
   - D) Temporary Lock

5. **What is a deadlock?**
   - A) Two transactions waiting for each other
   - B) A transaction that never completes
   - C) A database that has crashed
   - D) A lock that cannot be released

**Answers:** 1-B, 2-B, 3-B, 4-C, 5-A

---

**[END OF PRIMER 4]**

*You have now completed all four primers! You're ready to begin the main series. Congratulations!*
