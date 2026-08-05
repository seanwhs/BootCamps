# PRIMER 3 — Introduction to SQL Performance & Indexing

## Understanding How to Make Your Database Fast

---

## P3.1 Introduction

Welcome to the third and final primer! Now that you understand basic database concepts (Primer 1) and relational database design (Primer 2), we'll explore what makes databases fast or slow. This is the foundation for the performance optimization you'll learn in Part 2 of the main series.

**By the end of this primer, you will understand:**
- Why some queries are fast and others are slow
- What indexes are and how they work
- The trade-offs of indexing
- How to think about query performance
- Basic query optimization techniques

---

## P3.2 Why Are Some Queries Slow?

### P3.2.1 The Analogy: Finding a Book in a Library

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LIBRARY ANALOGY                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   SCENARIO: Find all books by "Jane Austen"                       │
│                                                                     │
│   WITHOUT INDEX (Reading every book):                             │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │  Bookshelf 1: Check every book → No match                  │ │
│   │  Bookshelf 2: Check every book → No match                  │ │
│   │  Bookshelf 3: Check every book → No match                  │ │
│   │  Bookshelf 4: Check every book → FOUND: Pride & Prejudice │ │
│   │  Bookshelf 5: Check every book → No match                  │ │
│   │  Bookshelf 6: Check every book → FOUND: Sense & Sensibility│ │
│   │  Bookshelf 7: Check every book → No match                  │ │
│   │                                                             │ │
│   │  Result: Had to check 10,000 books to find 2!              │ │
│   │  Time: ~30 minutes                                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   WITH INDEX (Using a catalog):                                   │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                                                             │ │
│   │  Catalog: Look up "Austen, Jane"                           │ │
│   │  Catalog says: Books are on shelf 4, row 3, and shelf 6   │ │
│   │  Go directly to those books                                 │ │
│   │                                                             │ │
│   │  Result: Found both books immediately!                      │ │
│   │  Time: ~2 minutes                                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   DATABASE EQUIVALENT:                                            │
│   • Without Index → Sequential Scan (checks every row)           │
│   • With Index → Index Scan (goes directly to matching rows)    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P3.2.2 Sequential Scan vs. Index Scan

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCAN TYPES                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   SEQUENTIAL SCAN (Full Table Scan):                              │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SELECT * FROM customers WHERE last_name = 'Smith';        │ │
│   │                                                             │ │
│   │  Database reads EVERY row in the customers table            │ │
│   │  Checks each row's last_name column                         │ │
│   │  Returns rows where last_name = 'Smith'                    │ │
│   │                                                             │ │
│   │  Cost: O(N) where N = number of rows                       │ │
│   │  For 1 million rows: reads 1 million rows                  │ │
│   │  Takes ~2-5 seconds                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   INDEX SCAN:                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SELECT * FROM customers WHERE last_name = 'Smith';        │ │
│   │                                                             │ │
│   │  Database:                                                  │ │
│   │  1. Looks up 'Smith' in the index                         │ │
│   │  2. Index points to the exact rows                         │ │
│   │  3. Reads only those rows                                  │ │
│   │                                                             │ │
│   │  Cost: O(log N) + rows returned                            │ │
│   │  For 1 million rows: ~20 index lookups                     │ │
│   │  Takes ~1-2 milliseconds                                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P3.2.3 What Makes a Query Slow?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SLOW QUERY CAUSES                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. NO INDEX ON FILTERED COLUMN                                  │
│      SELECT * FROM orders WHERE customer_id = 42;                │
│      → If customer_id has no index, full scan required          │
│                                                                     │
│   2. JOINING WITHOUT INDEXES                                      │
│      SELECT * FROM orders JOIN customers ON orders.customer_id = │
│      customers.id;                                               │
│      → Both sides need indexes for efficient join               │
│                                                                     │
│   3. USING FUNCTIONS ON INDEXED COLUMNS                          │
│      SELECT * FROM customers WHERE LOWER(email) = 'john@test.com';│
│      → The LOWER() function prevents index usage                │
│                                                                     │
│   4. LIKE WITH LEADING WILDCARD                                  │
│      SELECT * FROM products WHERE name LIKE '%laptop%';          │
│      → '%' at start means index can't be used                   │
│                                                                     │
│   5. LARGE RESULT SETS                                            │
│      SELECT * FROM orders WHERE order_date > '2025-01-01';       │
│      → Even with index, returning 100K rows is slow             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.3 What Is an Index?

### P3.3.1 The Concept

An **index** is a data structure that helps the database find data quickly, just like a book's index helps you find topics.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INDEX CONCEPT                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   A database index is like a phone book:                          │
│                                                                     │
│   Phone Book (Index):                                            │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Name           │   Page  │   Phone                        │ │
│   │  Anderson, John │   12    │   555-0101                    │ │
│   │  Brown, Sarah   │   45    │   555-0202                    │ │
│   │  Davis, Robert  │   78    │   555-0303                    │ │
│   │  Garcia, Maria  │   102   │   555-0404                    │ │
│   │  Jones, William │   156   │   555-0505                    │ │
│   │  Smith, Jennifer│   203   │   555-0606                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Without a phone book (index):                                   │
│   • You'd have to check every page to find someone               │
│                                                                     │
│   With a phone book (index):                                      │
│   • Go directly to the right page                                 │
│   • Find the name quickly                                         │
│   • Get the phone number                                          │
│                                                                     │
│   Database index works the same way:                              │
│   • Column values are sorted                                      │
│   • Database can find values quickly                            │
│   • Then retrieves the full row                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P3.3.2 Index Structure (B-Tree)

Most database indexes use a structure called a **B-Tree** (Balanced Tree).

```
┌─────────────────────────────────────────────────────────────────────┐
│                    B-TREE INDEX STRUCTURE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Index on customers (last_name, first_name):                     │
│                                                                     │
│                        ┌────────────┐                             │
│                        │    "M"     │                             │
│                        │  (Root)    │                             │
│                        └─────┬──────┘                             │
│                              │                                     │
│              ┌───────────────┼───────────────┐                    │
│              │               │               │                    │
│              ▼               ▼               ▼                    │
│         ┌────────┐     ┌────────┐     ┌────────┐                 │
│         │ "A-F"  │     │ "G-L"  │     │ "M-Z"  │                 │
│         └───┬────┘     └───┬────┘     └───┬────┘                 │
│             │              │              │                       │
│     ┌───────┼──────┐       │      ┌───────┼──────┐               │
│     ▼       ▼       ▼       │      ▼       ▼       ▼              │
│   ┌───┐   ┌───┐   ┌───┐    │   ┌───┐   ┌───┐   ┌───┐          │
│   │A-C│   │D-F│   │G-I│    │   │J-L│   │M-O│   │P-R│          │
│   └───┘   └───┘   └───┘    │   └───┘   └───┘   └───┘          │
│             │               │                                     │
│             ▼               ▼                                     │
│         ┌────────┐     ┌────────┐                               │
│         │  "M"   │     │  "S"   │                               │
│         │(Leaves)│     │(Leaves)│                               │
│         └────────┘     └────────┘                               │
│                                                                     │
│   How to find "Smith":                                            │
│   1. Start at root "M"                                           │
│   2. "S" > "M" → go right                                       │
│   3. Found "S" in the right branch                              │
│   4. Follow to leaf for "S"                                    │
│   5. Find "Smith"                                                │
│                                                                     │
│   Number of steps: ~4-5 even for millions of rows!               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.4 Types of Indexes

### P3.4.1 Basic Index Types

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INDEX TYPES                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. SINGLE-COLUMN INDEX                                          │
│      CREATE INDEX idx_customers_email ON customers(email);       │
│      → Index on one column                                       │
│      → Good for: WHERE email = 'john@test.com'                  │
│                                                                     │
│   2. COMPOSITE INDEX                                              │
│      CREATE INDEX idx_orders_customer_status ON orders(          │
│        customer_id, status);                                     │
│      → Index on multiple columns                                  │
│      → Good for: WHERE customer_id = 42 AND status = 'pending'  │
│      → Also works for: WHERE customer_id = 42 (uses first col)  │
│                                                                     │
│   3. UNIQUE INDEX                                                 │
│      CREATE UNIQUE INDEX idx_customers_email ON customers(email);│
│      → Prevents duplicate values in the column                   │
│      → Good for: email, username, SKU                           │
│                                                                     │
│   4. PARTIAL INDEX                                                │
│      CREATE INDEX idx_orders_pending ON orders(order_date)       │
│      WHERE status = 'pending';                                   │
│      → Indexes only a subset of rows                             │
│      → Good for: queries that always filter on a condition      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P3.4.2 Advanced Index Types (Brief Overview)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ADVANCED INDEX TYPES                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   FULL-TEXT INDEX (GIN):                                          │
│   • For searching text in documents                               │
│   • Example: Search product descriptions                          │
│   • Supports: 'laptop' AND 'high-performance'                    │
│                                                                     │
│   GIST INDEX:                                                     │
│   • For geometric data and nearest-neighbor                       │
│   • Example: Find stores within 10km                             │
│                                                                     │
│   BRIN INDEX:                                                     │
│   • For very large tables with natural order                     │
│   • Example: Time-series data by date                            │
│   • Much smaller than B-Tree                                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.5 The Index Trade-Off

### P3.5.1 Indexes Are Not Free

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INDEX TRADE-OFFS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   BENEFITS:                                                       │
│   ✅ Faster SELECT queries                                      │
│   ✅ Faster JOIN operations                                       │
│   ✅ Faster ORDER BY                                              │
│   ✅ Faster GROUP BY                                              │
│   ✅ Enforces uniqueness (unique indexes)                        │
│                                                                     │
│   COSTS:                                                         │
│   ❌ Slower INSERT (must update index)                           │
│   ❌ Slower UPDATE (if indexed column changes)                   │
│   ❌ Slower DELETE (must remove from index)                      │
│   ❌ Uses storage space                                           │
│   ❌ More work for the database                                   │
│                                                                     │
│   ANALOGY:                                                        │
│   Having a book index makes finding topics easy                  │
│   But maintaining the index takes extra work                     │
│   You can't index everything in a book (too many pages)          │
│   You can't index everything in a database (too much overhead)  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P3.5.2 When to Add an Index

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INDEX DECISION GUIDE                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ✅ ADD INDEX WHEN:                                              │
│   • Column is frequently used in WHERE clauses                    │
│   • Column is used in JOIN conditions                             │
│   • Column is used in ORDER BY                                    │
│   • Column has high selectivity (many unique values)              │
│   • Table is large (>10,000 rows)                                │
│   • Queries are slow due to full table scans                      │
│                                                                     │
│   ❌ SKIP INDEX WHEN:                                             │
│   • Column is rarely used in queries                              │
│   • Table is very small (<1,000 rows)                            │
│   • Column has low selectivity (few unique values)                │
│   • Table is heavily written (many INSERT/UPDATE/DELETE)         │
│   • You already have a similar index                             │
│                                                                     │
│   EXAMPLE:                                                        │
│   customers table:                                               │
│   • email → ✅ Index (highly selective, used in login)           │
│   • last_name → ✅ Index (used in search)                       │
│   • created_at → ✅ Index (used for date ranges)                 │
│   • is_active → ❌ Index (low selectivity, only 2 values)        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.6 EXPLAIN ANALYZE

### P3.6.1 What Is EXPLAIN ANALYZE?

`EXPLAIN ANALYZE` is a command that shows you exactly how the database executes your query.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    EXPLAIN ANALYZE EXAMPLE                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   QUERY:                                                          │
│   EXPLAIN ANALYZE                                                 │
│   SELECT * FROM orders WHERE customer_id = 42;                   │
│                                                                     │
│   WITHOUT INDEX:                                                  │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Seq Scan on orders  (cost=0.00..20000.00 rows=50 width=48)│ │
│   │  Actual time: 0.123..123.456 rows=150 loops=1             │ │
│   │  Filter: (customer_id = 42)                                 │ │
│   │  Rows Removed by Filter: 1999850                           │ │
│   │  Planning Time: 0.234 ms                                    │ │
│   │  Execution Time: 123.789 ms                                │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Reading this:                                                   │
│   • "Seq Scan" → Full table scan                                 │
│   • "cost=0.00..20000.00" → Estimated cost                      │
│   • "rows=50" → Estimated rows returned                         │
│   • "Actual time: 123.456" → Actual execution time              │
│   • "rows=150" → Actual rows returned                           │
│   • "Rows Removed by Filter: 1999850" → Rows that didn't match │
│                                                                     │
│   WITH INDEX:                                                    │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Index Scan using idx_orders_customer_id on orders         │ │
│   │  (cost=0.50..100.00 rows=50 width=48)                     │ │
│   │  Actual time: 0.023..0.045 rows=150 loops=1               │ │
│   │  Index Cond: (customer_id = 42)                            │ │
│   │  Planning Time: 0.156 ms                                   │ │
│   │  Execution Time: 0.289 ms                                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   Reading this:                                                   │
│   • "Index Scan" → Used the index                                │
│   • Much lower cost and execution time                          │
│   • No "Rows Removed by Filter" (index found exact rows)       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.7 Basic Query Optimization

### P3.7.1 Optimizing Common Patterns

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUERY OPTIMIZATION TIPS                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. SELECT ONLY NEEDED COLUMNS                                   │
│      ❌ SELECT * FROM products;                                  │
│      ✅ SELECT id, name, price FROM products;                    │
│                                                                     │
│   2. USE INDEXED COLUMNS IN WHERE                                │
│      ❌ WHERE LOWER(email) = 'john@test.com'                    │
│      ✅ WHERE email = 'john@test.com'                           │
│      (Index on email, not on LOWER(email))                      │
│                                                                     │
│   3. AVOID WILDCARDS AT START                                    │
│      ❌ WHERE name LIKE '%laptop%'                              │
│      ✅ WHERE name LIKE 'laptop%'                               │
│      (Can't use index with leading wildcard)                    │
│                                                                     │
│   4. USE LIMIT FOR LARGE RESULTS                                │
│      ❌ SELECT * FROM orders;                                   │
│      ✅ SELECT * FROM orders LIMIT 100;                         │
│                                                                     │
│   5. USE EXISTS INSTEAD OF COUNT FOR EXISTENCE                 │
│      ❌ SELECT COUNT(*) FROM orders WHERE customer_id = 42;     │
│      ✅ SELECT EXISTS (SELECT 1 FROM orders WHERE customer_id = 42);│
│                                                                     │
│   6. BE MINDFUL OF JOINS                                         │
│      ❌ SELECT * FROM orders o JOIN customers c ON o.customer_id =│
│         c.id JOIN addresses a ON c.address_id = a.id;          │
│      → Multiple joins can be slow                               │
│      ✅ Only join tables you need                                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P3.7.2 Real-World Example

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OPTIMIZATION EXAMPLE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   BUSINESS NEED: Find all orders from customer #42 with status    │
│   'shipped' and get the product names.                            │
│                                                                     │
│   SLOW QUERY:                                                     │
│   SELECT o.*, p.name                                              │
│   FROM orders o                                                   │
│   JOIN order_items oi ON o.id = oi.order_id                     │
│   JOIN products p ON oi.product_id = p.id                       │
│   WHERE o.customer_id = 42                                       │
│     AND o.status = 'shipped';                                    │
│                                                                     │
│   OPTIMIZED QUERY:                                                │
│   SELECT o.id, o.order_date, o.total_amount, p.name              │
│   FROM orders o                                                   │
│   JOIN order_items oi ON o.id = oi.order_id                     │
│   JOIN products p ON oi.product_id = p.id                       │
│   WHERE o.customer_id = 42                                       │
│     AND o.status = 'shipped'                                     │
│   LIMIT 100;                                                     │
│                                                                     │
│   REQUIRED INDEXES:                                               │
│   1. CREATE INDEX idx_orders_customer_status                     │
│      ON orders(customer_id, status);                            │
│      → For the WHERE clause                                      │
│                                                                     │
│   2. CREATE INDEX idx_order_items_order_id                       │
│      ON order_items(order_id);                                  │
│      → For the JOIN                                              │
│                                                                     │
│   3. CREATE INDEX idx_order_items_product_id                     │
│      ON order_items(product_id);                                │
│      → For the JOIN                                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.8 Practice Exercise

### P3.8.1 Identify the Problem

**Scenario:** You have a `products` table with 1 million rows. The following query is very slow:

```sql
SELECT * FROM products WHERE name LIKE '%laptop%' AND price < 500;
```

**Questions:**

1. Why is this query slow?
2. What could we do to improve it?
3. What are the trade-offs?

**Answers:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    EXERCISE ANSWERS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. WHY IS IT SLOW?                                              │
│      • LIKE '%laptop%' with leading wildcard can't use index    │
│      • Must scan all 1 million rows                              │
│      • Checks each name for 'laptop'                             │
│      • Also checks each price                                    │
│                                                                     │
│   2. HOW TO IMPROVE?                                              │
│      • Add full-text search index (GIN)                         │
│      • CREATE INDEX idx_products_search ON products             │
│        USING GIN (to_tsvector('english', name));               │
│      • Use full-text search:                                     │
│        SELECT * FROM products WHERE                             │
│        to_tsvector('english', name) @@ to_tsquery('laptop')     │
│        AND price < 500;                                         │
│                                                                     │
│      • Alternative: Only search exact matches or prefixes        │
│        name LIKE 'laptop%' (can use regular index)              │
│                                                                     │
│   3. TRADE-OFFS:                                                  │
│      • GIN index takes more space                                │
│      • GIN index is slower to update                             │
│      • Full-text search is more powerful                         │
│      • But maybe not needed if exact matches work                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P3.9 Glossary of New Terms

| Term | Definition |
|------|------------|
| **Sequential Scan** | Reading every row of a table (full table scan) |
| **Index Scan** | Using an index to find rows quickly |
| **B-Tree** | Balanced tree data structure used by most indexes |
| **Composite Index** | Index on multiple columns |
| **Partial Index** | Index on a subset of rows |
| **Cardinality** | Number of distinct values in a column |
| **Selectivity** | How unique values are in a column |
| **EXPLAIN ANALYZE** | Command to show query execution plan |
| **Cost** | Estimated resource usage for a query |
| **Query Optimization** | Improving query performance |

---

## P3.10 Summary

### P3.10.1 Key Takeaways

1. **Indexes make queries faster** by allowing the database to find data quickly, just like a book's index.

2. **Sequential scan vs. Index scan:**
   - Sequential scan: Reads every row (slow for large tables)
   - Index scan: Goes directly to matching rows (fast)

3. **Types of indexes:**
   - Single-column, composite, unique, partial
   - Advanced: GIN (full-text), GiST (geometric), BRIN (time-series)

4. **Indexes have trade-offs:**
   - ✅ Faster reads
   - ❌ Slower writes
   - ❌ Takes storage space

5. **Use EXPLAIN ANALYZE** to see how your query is executed.

6. **Optimize queries by:**
   - Selecting only needed columns
   - Using indexed columns in WHERE
   - Avoiding leading wildcards
   - Using LIMIT

### P3.10.2 What's Next?

Now you're ready for the main series!

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
- ACID transactions
- Locking strategies
- Zero-downtime migrations

**Part 4: Modern Data Architectures Beyond SQL**
- NoSQL databases
- Graph databases
- Distributed systems
- Polyglot persistence

---

## P3.11 Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────┐
│                    QUICK REFERENCE                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   CREATE INDEX                                                     │
│   CREATE INDEX idx_name ON table(column);                        │
│                                                                     │
│   CREATE UNIQUE INDEX                                              │
│   CREATE UNIQUE INDEX idx_email ON customers(email);              │
│                                                                     │
│   CREATE COMPOSITE INDEX                                           │
│   CREATE INDEX idx_orders_customer ON orders(customer_id, status);│
│                                                                     │
│   CREATE PARTIAL INDEX                                             │
│   CREATE INDEX idx_orders_active ON orders(order_date)            │
│   WHERE status != 'cancelled';                                   │
│                                                                     │
│   DROP INDEX                                                       │
│   DROP INDEX idx_name;                                            │
│                                                                     │
│   EXPLAIN ANALYZE                                                  │
│   EXPLAIN ANALYZE SELECT * FROM table WHERE column = value;       │
│                                                                     │
│   INDEX USAGE GUIDELINE:                                          │
│   • High selectivity → ✅ Index                                 │
│   • Low selectivity → ❌ No index                               │
│   • Frequently queried → ✅ Index                                │
│   • Rarely queried → ❌ No index                                │
│   • Heavy writes → ❌ Be careful                                 │
│   • Light writes → ✅ Index                                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

**[END OF PRIMER 3]**

*This completes the three primers! You are now ready to begin the main series. You have the foundation you need to master modern database design.*
