# Primer C: What a Database Index Actually Does

Indexes are one of the most important tools for making databases fast, yet they are often treated as magic. This primer gives you a concrete mental model so you can reason about when they help, when they hurt, and why they appear in almost every system-design discussion about storage.

### 1. The Core Problem: Finding Data Without Scanning Everything

Imagine a phone book that is just a giant unordered pile of pages. To find “Alice Smith” you would have to look at every page. That is a **full table scan**.

A database without an index works the same way. On a table with millions of rows, looking up a single user by email can become painfully slow.

An **index** is an extra data structure that lets the database jump directly to the relevant rows instead of scanning everything.

### 2. The Most Common Mental Model: A Sorted Book Index

Think of the index at the back of a technical book:

- It is sorted.
- It maps a keyword to page numbers.
- You look up the keyword once, then go straight to the right pages.

A database index works almost identically:

- It stores the values of one or more columns in a sorted (or otherwise searchable) structure.
- Alongside each value it stores a pointer to the actual row in the main table.
- The database uses the index to find the pointer(s), then fetches only the needed rows.

The most common structure is a **B-tree** (or B+ tree). You do not need to memorize the internals, but you should know the practical consequences:

- Lookups, range scans, and ordered retrieval are fast (logarithmic time).
- Inserts, updates, and deletes become a bit more expensive because the index must also be updated.

### 3. Primary Key vs Secondary Indexes

- **Primary key index**  
  Every table almost always has one. It uniquely identifies each row and is often used as the main way the data is physically organized.

- **Secondary indexes**  
  Extra indexes you create on other columns (email, status, created_at, etc.) to speed up queries that filter or sort on those columns.

Each additional index speeds up some reads but slows down writes and consumes extra storage.

### 4. What Indexes Are Good At (and What They Are Not)

**Good for:**
- Exact match lookups (`WHERE email = '…'`)
- Range queries (`WHERE created_at > '2025-01-01'`)
- Ordering (`ORDER BY created_at DESC`)
- Some joins and foreign-key checks

**Not magic for:**
- Queries that return a huge fraction of the table (the database may correctly decide a full scan is cheaper)
- Functions applied to the column (`WHERE LOWER(email) = '…'` usually cannot use a normal index)
- Leading-wildcard searches (`WHERE title LIKE '%report'`)

### 5. The Cost Side – Why You Don’t Index Everything

Every write (INSERT, UPDATE, DELETE) must update every index that includes the changed columns. More indexes = more work on every write + more disk and memory usage.

Practical rule of thumb:

> Index the columns that appear frequently in `WHERE`, `JOIN`, and `ORDER BY` clauses of your important queries. Measure before adding more.

### 6. Composite Indexes (Multi-Column)

You can create an index on several columns together: `(workspace_id, status, created_at)`.

Order matters. This index is excellent for queries that filter on `workspace_id`, or `workspace_id + status`, or all three. It is far less useful for queries that only filter on `created_at`.

A useful analogy: a phone book sorted by Last Name → First Name helps you find “Smith, Alice” quickly, but does not help you find every “Alice” regardless of last name.

### 7. Covering Indexes (Bonus Concept)

If an index already contains all the columns a query needs, the database can answer the query from the index alone without touching the main table. This is called a **covering index** and can be very fast.

### 8. How This Appears in System Design

When we later discuss:

- Why a query suddenly became slow after data growth → often a missing or ineffective index
- Why write throughput dropped after adding a feature → often too many new indexes
- How to shard or partition data → the partition key is frequently also the leading column of important indexes
- Caching strategies → we cache expensive queries that even a good index cannot make cheap enough

…you will use the mental model from this primer.

### 9. What You Should Be Able to Do After This Primer

- Explain what an index does in plain language (avoiding “it makes the database faster”).
- Describe the trade-off between read speed and write cost.
- Look at a simple query and suggest which column(s) would benefit from an index.
- Recognize why `WHERE lower(email) = …` or leading-wildcard `LIKE` queries often bypass indexes.
- Understand why composite index column order matters.

This primer prepares you for the storage and query discussions in Part 3 and for the performance work in later parts.

**[END OF PRIMER C]**
