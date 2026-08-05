Welcome to Part 6. You now have a solid foundation in SQLite's core capabilities: schema design, querying, indexing, transactions, and reliability. Now we unlock the advanced features that make SQLite a **multi‑paradigm data platform**. We will integrate JSON for flexible document storage, build a full‑text search engine for millions of documents, extend SQLite with virtual tables and custom extensions, and automate business logic with triggers and views. By the end, you will be able to build hybrid relational‑document databases, search applications, and auditable systems.

**Part 6** is divided into four modules:

- **Module 17:** JSON1 Extension – Storing, querying, and indexing JSON data.
- **Module 18:** Full‑Text Search (FTS5) – Building search engines with ranking and snippets.
- **Module 19:** Virtual Tables & Extensions – CSV virtual tables, custom virtual tables, and loadable extensions.
- **Module 20:** Triggers & Views – Automating logic with triggers, and creating reusable views.

Let's begin.

---

# Part 6: Advanced SQLite Features

## Module 17: JSON1 Extension

### The Target

Learn to store and manipulate JSON documents directly inside SQLite. You will use the JSON1 extension to extract values, modify documents, generate JSON from relational data, and even index JSON fields for performance. This enables hybrid models where you combine structured relational tables with flexible semi‑structured data.

### The Concept

Think of JSON as a **flexible container** that can hold nested objects and arrays—like a digital Swiss Army knife. In modern applications, you often need to store variable‑shape data: user preferences, API responses, product attributes, etc. Instead of using a separate NoSQL database, SQLite lets you store JSON as `TEXT` and query it efficiently using the JSON1 extension.

The JSON1 extension provides functions to:
- Validate JSON (`json_valid`).
- Extract values (`json_extract`, `->`, `->>`).
- Modify JSON (`json_set`, `json_insert`, `json_remove`, `json_replace`).
- Generate JSON from relational data (`json_group_array`, `json_group_object`).
- Index JSON fields using generated columns.

### Enabling JSON1

The JSON1 extension is built into SQLite by default (since version 3.9.0). You don't need to enable anything. Verify:

```sql
SELECT json('{"hello":"world"}');  -- returns the JSON string
```

### Hands‑on Lab 17.1: Storing and Querying JSON

We'll create a `products` table where each product has fixed columns (id, name) and a flexible `attributes` JSON column for extra fields.

```bash
sqlite3 json_demo.db
```

```sql
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    attributes TEXT  -- JSON document
);

-- Insert products with varying attributes
INSERT INTO products (name, attributes) VALUES
    ('Laptop', '{"brand":"Dell", "specs": {"cpu":"i7", "ram":16, "storage":"512GB SSD"}, "in_stock":true}'),
    ('Smartphone', '{"brand":"Apple", "specs": {"cpu":"A15", "storage":"128GB"}, "color":"silver", "in_stock":false}'),
    ('Tablet', '{"brand":"Samsung", "specs": {"cpu":"Exynos", "ram":8}, "in_stock":true, "accessories":["pen","keyboard"]}');
```

Now query JSON fields:

```sql
-- Extract brand from attributes
SELECT name, json_extract(attributes, '$.brand') AS brand FROM products;

-- Use the shorthand -> and ->> (available in SQLite 3.38+)
SELECT name, attributes->>'$.brand' AS brand FROM products;

-- Extract nested spec
SELECT name, attributes->'$.specs.cpu' AS cpu FROM products;

-- Filter by JSON value (in_stock = true)
SELECT name FROM products WHERE attributes->>'$.in_stock' = 'true';

-- Filter by nested value
SELECT name FROM products WHERE attributes->'$.specs.ram' >= 16;
```

### Modifying JSON

Use `json_set` to add or update a field, `json_insert` to add only if not exists, `json_remove` to delete, and `json_replace` to replace existing.

```sql
-- Add a new field 'warranty' to the laptop
UPDATE products 
SET attributes = json_set(attributes, '$.warranty', '2 years')
WHERE product_id = 1;

-- Update the storage spec for the smartphone
UPDATE products 
SET attributes = json_set(attributes, '$.specs.storage', '256GB')
WHERE product_id = 2;

-- Remove the color field from smartphone
UPDATE products 
SET attributes = json_remove(attributes, '$.color')
WHERE product_id = 2;

-- Insert a new attribute only if it doesn't exist (won't overwrite)
UPDATE products 
SET attributes = json_insert(attributes, '$.discount', 0.1)
WHERE product_id = 1;  -- doesn't exist, so it's added
```

### Generating JSON from Relational Data

You can aggregate rows into JSON arrays or objects.

```sql
-- Create a JSON array of all product names
SELECT json_group_array(name) AS all_names FROM products;

-- Create a JSON object mapping product_id to name
SELECT json_group_object(product_id, name) AS id_name_map FROM products;
```

### Indexing JSON Fields

Because JSON fields are stored as text, you can't index them directly. However, you can create **generated columns** that extract a JSON value and then index that column.

```sql
-- Add generated columns for frequently queried fields
ALTER TABLE products ADD COLUMN brand TEXT GENERATED ALWAYS AS (attributes->>'$.brand') STORED;
ALTER TABLE products ADD COLUMN in_stock INTEGER GENERATED ALWAYS AS (CASE WHEN attributes->>'$.in_stock' = 'true' THEN 1 ELSE 0 END) STORED;
ALTER TABLE products ADD COLUMN cpu TEXT GENERATED ALWAYS AS (attributes->'$.specs.cpu') STORED;

-- Now create indexes on these generated columns
CREATE INDEX idx_products_brand ON products(brand);
CREATE INDEX idx_products_in_stock ON products(in_stock);
CREATE INDEX idx_products_cpu ON products(cpu);
```

Now queries filtering on these fields will use the indexes.

```sql
EXPLAIN QUERY PLAN SELECT name FROM products WHERE brand = 'Dell';
-- Should use the index
```

### Validation and Type Coercion

Use `json_valid` to check if a string is valid JSON before inserting.

```sql
-- Insert only if valid
INSERT INTO products (name, attributes) 
SELECT 'Test', '{"valid":true}' WHERE json_valid('{"valid":true}');
```

### Hands‑on Lab 17.2: Building a Document Store

We'll simulate a simple blog post store where each post has a flexible metadata JSON field.

```sql
CREATE TABLE posts (
    post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    metadata TEXT,  -- JSON: tags, author, views, etc.
    created_at TEXT DEFAULT (datetime('now'))
);

-- Insert posts with different metadata shapes
INSERT INTO posts (title, content, metadata) VALUES
    ('First Post', 'Hello world!', '{"author":"Alice","tags":["intro","hello"],"views":10}'),
    ('SQLite Tips', 'Use JSON!', '{"author":"Bob","tags":["sqlite","json"],"views":25,"rating":4.5}'),
    ('Advanced SQL', 'Join, CTE, etc.', '{"author":"Alice","tags":["sql","advanced"],"views":5}');

-- Query: Find posts by Alice with views > 5
SELECT title, metadata->>'$.views' AS views 
FROM posts 
WHERE metadata->>'$.author' = 'Alice' AND CAST(metadata->>'$.views' AS INTEGER) > 5;

-- Add a generated column for author to speed up
ALTER TABLE posts ADD COLUMN author TEXT GENERATED ALWAYS AS (metadata->>'$.author') STORED;
CREATE INDEX idx_posts_author ON posts(author);
```

#### Verification

Run queries and verify that JSON extraction works. Use `EXPLAIN QUERY PLAN` to confirm index usage after adding generated columns.

---

### Reference: JSON1 Functions Summary

| Function | Description |
|----------|-------------|
| `json_valid(str)` | Returns 1 if str is valid JSON, else 0. |
| `json_extract(json, path, ...)` | Extracts value at path. |
| `json_set(json, path, value, ...)` | Adds/updates fields. |
| `json_insert(json, path, value, ...)` | Adds only if field doesn't exist. |
| `json_replace(json, path, value, ...)` | Replaces existing fields. |
| `json_remove(json, path, ...)` | Removes fields. |
| `json_array_length(json)` | Length of a JSON array. |
| `json_each(json)` | Table-valued function to iterate over array. |
| `json_tree(json)` | Table-valued function to iterate over entire structure. |
| `json_group_array(expr)` | Aggregate to build JSON array. |
| `json_group_object(key, value)` | Aggregate to build JSON object. |

---

**[GENERATED: Part 6, Module 17: JSON1 Extension]**

---

## Module 18: Full‑Text Search (FTS5)

### The Target

Implement a full‑text search engine using the FTS5 extension. You will create virtual tables, populate them with documents, and run relevance‑ranked search queries with snippets and highlighting.

### The Concept

When you have large text documents (blog posts, emails, logs), ordinary `LIKE '%word%'` searches are slow and limited. **Full‑text search** indexes the words (tokens) in your documents, allowing you to search for phrases, word variants, and even use Boolean operators. SQLite's FTS5 is a powerful, battle‑tested search engine that can index millions of documents.

FTS5 works by creating a **virtual table** that looks like a regular table but is backed by a special inverted index. You insert your documents into this virtual table, and then you can query it using the `MATCH` operator. FTS5 supports:
- Prefix searches (`'search*'`)
- Phrase searches (`'"exact phrase"'`)
- NEAR searches (`'word1 NEAR word2'`)
- Relevance ranking with BM25 (and custom ranking)
- Snippets (highlighted excerpts)
- Custom tokenizers (for non‑English languages, custom stop words)

### Enabling FTS5

FTS5 is built into SQLite (since 3.9.0). No separate loading needed. Verify:

```sql
SELECT fts5_version();  -- if available, returns version
```

### Hands‑on Lab 18.1: Building a Document Search Engine

We'll create an FTS5 table for blog posts.

```bash
sqlite3 fts_demo.db
```

```sql
-- Create an external content table for your actual data (optional)
CREATE TABLE docs (
    doc_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    author TEXT,
    published DATE
);

-- Insert sample documents
INSERT INTO docs (title, body, author) VALUES
    ('Getting Started with SQLite', 'SQLite is a lightweight database. It is serverless and self-contained.', 'Alice'),
    ('Advanced SQLite', 'Learn about JSON, FTS, and virtual tables. SQLite is powerful!', 'Bob'),
    ('SQLite Performance', 'Indexing, WAL, and query optimization make SQLite fast.', 'Carol'),
    ('Full-Text Search in SQLite', 'FTS5 enables powerful text search. Use MATCH queries.', 'Alice'),
    ('Python and SQLite', 'Integrate SQLite with Python using sqlite3 module.', 'Bob');

-- Now create an FTS5 virtual table that mirrors the docs table
CREATE VIRTUAL TABLE docs_fts USING fts5(
    title,
    body,
    author,
    content=docs  -- link to the external content table
);

-- Populate the FTS table from the docs table
INSERT INTO docs_fts(rowid, title, body, author)
SELECT doc_id, title, body, author FROM docs;
```

Now we can search:

```sql
-- Basic search: find documents containing 'SQLite'
SELECT rowid, title, body, author 
FROM docs_fts 
WHERE docs_fts MATCH 'SQLite';

-- Phrase search: exact phrase 'full-text search'
SELECT rowid, title 
FROM docs_fts 
WHERE docs_fts MATCH '"full-text search"';

-- Prefix search: words starting with 'optim'
SELECT rowid, title 
FROM docs_fts 
WHERE docs_fts MATCH 'optim*';

-- Boolean operators: SQLite AND Python
SELECT rowid, title 
FROM docs_fts 
WHERE docs_fts MATCH 'SQLite AND Python';

-- NEAR operator: 'SQLite' within 5 words of 'serverless'
SELECT rowid, title 
FROM docs_fts 
WHERE docs_fts MATCH 'SQLite NEAR/5 serverless';
```

### Ranking Results

FTS5 provides the `bm25()` function for ranking. Higher scores mean more relevant.

```sql
-- Rank results by relevance
SELECT rowid, title, bm25(docs_fts) AS rank
FROM docs_fts 
WHERE docs_fts MATCH 'SQLite'
ORDER BY rank;
```

### Snippets and Highlighting

`snippet()` returns a formatted excerpt with the matched words highlighted.

```sql
SELECT title, snippet(docs_fts, 1, '<b>', '</b>', '...', 30) AS excerpt
FROM docs_fts 
WHERE docs_fts MATCH 'SQLite';
```

Parameters: column index (1 = title, 2 = body, etc.), open tag, close tag, separator, max tokens.

### Using an External Content Table

If your data is already in a separate table, you can use the `content` option to avoid duplication. We already did that. FTS5 will only store the index, not the full text. This saves space.

To keep the FTS table in sync with the content table, you can use triggers (covered in Module 20).

### Custom Tokenizers

FTS5 supports custom tokenizers (e.g., for Unicode, non‑English, or custom stop words). You can specify a tokenizer when creating the table:

```sql
CREATE VIRTUAL TABLE docs_fts USING fts5(
    title,
    body,
    author,
    tokenize = 'porter unicode61'
);
```

The `porter` stemmer reduces words to roots (e.g., "running" -> "run"). `unicode61` supports Unicode characters.

### Hands‑on Lab 18.2: Searching a Large Dataset

We'll generate 100,000 sample documents and test performance.

```sql
-- Create a large docs table
CREATE TABLE large_docs (id INTEGER PRIMARY KEY, content TEXT);
INSERT INTO large_docs (content)
SELECT 'Document ' || value || ' contains the word SQLite ' || (value % 10) || ' times.'
FROM generate_series(1, 100000);

-- Create FTS table
CREATE VIRTUAL TABLE large_fts USING fts5(content);
INSERT INTO large_fts(rowid, content) SELECT id, content FROM large_docs;

-- Now search
.timer on
SELECT rowid, content FROM large_fts WHERE large_fts MATCH 'SQLite' LIMIT 10;
```

Observe the speed—should be sub‑100ms. Compare with `LIKE '%SQLite%'` on the original table (should be much slower).

### Verification

- Ensure FTS5 tables return expected results.
- Use `EXPLAIN QUERY PLAN` on a `MATCH` query—it should use the virtual table index.
- Test ranking and snippets.

---

### Reference: FTS5 Query Syntax

| Query | Example | Matches |
|-------|---------|---------|
| Single word | `sqlite` | Documents containing "sqlite" |
| Phrase | `"full text"` | Documents containing the exact phrase |
| Prefix | `optim*` | Words starting with "optim" |
| AND | `sqlite AND json` | Both terms |
| OR | `sqlite OR postgresql` | Either term |
| NOT | `sqlite NOT embedded` | Contains "sqlite" but not "embedded" |
| NEAR | `sqlite NEAR/3 serverless` | "sqlite" within 3 words of "serverless" |
| Column filter | `title:SQLite` | "SQLite" in the title column |

---

**[GENERATED: Part 6, Module 18: Full‑Text Search (FTS5)]**

---

## Module 19: Virtual Tables & Extensions

### The Target

Learn about SQLite's extensibility model: virtual tables that present external data as tables, and loadable extensions that add new functionality. We will use the built‑in CSV virtual table, create a custom virtual table (in C), and understand the extension loading mechanism.

### The Concept

Virtual tables are like **adapters** that make external data (e.g., CSV files, logs, JSON APIs) appear as regular SQLite tables. You can `SELECT`, `INSERT`, `UPDATE`, `DELETE` on them (if the adapter supports it). This is incredibly powerful for ETL, data integration, and prototyping.

Loadable extensions are shared libraries (`.so`, `.dll`, `.dylib`) that can add new functions, collations, virtual tables, and more. SQLite provides a few extensions out‑of‑the‑box (like `json1`, `fts5`, `spellfix1`, `series`, `csv`).

### Built‑in Virtual Tables

**1. The `generate_series` table** (available in SQLite 3.40+ as a built‑in table, or as the `series` extension). We've used this extensively.

**2. The `csv` virtual table** – Read CSV files directly as tables.

To use the `csv` virtual table, you need to load the CSV extension (if not built‑in). For most SQLite builds, it's available.

```sql
-- Load the CSV extension (if needed)
.load /path/to/csv
-- In some builds, it's built-in; try without .load first

-- Create a virtual table over a CSV file
CREATE VIRTUAL TABLE temp.csv_data USING csv(filename='data.csv');
SELECT * FROM csv_data LIMIT 10;
```

**3. The `spellfix1` extension** – For spelling correction and suggestions.

```sql
.load /path/to/spellfix
CREATE VIRTUAL TABLE words USING spellfix1(word);
INSERT INTO words(word) VALUES ('sqlite'), ('python'), ('database');
SELECT word, distance FROM words WHERE word MATCH 'sqlit' ORDER BY distance;
```

### Hands‑on Lab 19.1: Using the CSV Virtual Table

Create a CSV file `employees.csv` with content:

```
id,name,department,salary
1,Alice,Engineering,75000
2,Bob,Marketing,65000
3,Carol,Sales,68000
```

Then, in SQLite, load and query it:

```sql
-- If CSV extension is built-in, skip .load
-- For demonstration, we'll use the CLI's import command as alternative if .load fails

-- Method 1: Virtual table (if extension loaded)
-- .load /usr/lib/sqlite3/pcre.so  (might not be needed)

-- Method 2: Use the CLI's .import command (easiest)
-- But for a virtual table, we need the extension.

-- If you have the extension, do:
CREATE VIRTUAL TABLE employees_csv USING csv(filename='employees.csv');
SELECT * FROM employees_csv WHERE department = 'Engineering';
```

If the extension is not available, you can still use `.import`:

```sql
-- In CLI:
-- .mode csv
-- .import employees.csv employees
-- That creates a regular table, not virtual.
```

### Creating a Custom Virtual Table (Conceptual)

Writing a custom virtual table in C is beyond the scope of this course, but we can outline the steps:

1. Define the `sqlite3_module` structure with callbacks for `xCreate`, `xConnect`, `xBestIndex`, `xFilter`, `xNext`, `xEof`, `xColumn`, `xRowid`, etc.
2. Register the module with `sqlite3_create_module`.
3. Implement the logic to fetch data from your external source.

Many open‑source extensions exist for PostgreSQL, JSON, REST APIs, etc. You can also write in other languages using bindings (e.g., Python's `sqlite3` allows creating virtual tables using Python callbacks via `sqlite3_create_module`—see Part 7).

### Loadable Extensions

To load an extension, you use the `.load` command in the CLI, or `sqlite3_load_extension` in C.

**Example: Loading a spatial extension** (like `spatialite`).

```sql
.load libspatialite
-- Then use spatial functions
```

**Extension Security:** Extensions can execute arbitrary code, so they are disabled by default. Enable them with `PRAGMA load_extension = 1;` (or the `-enable-load-extension` flag).

### Hands‑on Lab 19.2: Loading a Simple Extension (if available)

We'll try loading the `regexp` extension (if compiled). If not, we'll simulate.

```sql
-- Try to load regexp (common extension)
SELECT load_extension('regexp');  -- may fail if not built

-- If loaded, you can use regexp()
SELECT 'abc' REGEXP '^a';
```

Most production builds include JSON1 and FTS5 without loading.

### Verification

- If you have a CSV file, test the CSV virtual table.
- Check `PRAGMA load_extension` and try loading a known extension.
- Note that extensions must be compiled for your platform.

---

**[GENERATED: Part 6, Module 19: Virtual Tables & Extensions]**

---

## Module 20: Triggers & Views

### The Target

Automate database logic with triggers (`BEFORE`, `AFTER`, `INSTEAD OF`) and create reusable, updatable views. Implement audit logging, soft‑delete patterns, and materialized view emulation.

### The Concept

**Triggers** are stored procedures that automatically execute in response to `INSERT`, `UPDATE`, or `DELETE` events. They are like **event‑driven hooks** for your database—perfect for:
- Audit logging (track who changed what and when).
- Data validation (enforce business rules that can't be expressed with constraints).
- Syncing (keep summary tables or FTS tables up to date).
- Soft deletes (mark records as deleted instead of physically removing them).

**Views** are saved queries that you can query like a table. They simplify complex queries and provide a layer of abstraction. `INSTEAD OF` triggers can make views updatable.

### Triggers Syntax

```sql
CREATE TRIGGER trigger_name 
[BEFORE|AFTER|INSTEAD OF] [INSERT|UPDATE|DELETE] ON table_name
[WHEN condition]
BEGIN
    -- SQL statements
END;
```

Inside a trigger, you can access `OLD` (the old row for `UPDATE`/`DELETE`) and `NEW` (the new row for `INSERT`/`UPDATE`).

### Hands‑on Lab 20.1: Audit Logging

We'll create an audit table that logs every change to a `products` table.

```sql
-- Create the main table
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price REAL NOT NULL CHECK (price >= 0),
    stock INTEGER DEFAULT 0
);

-- Create the audit log table
CREATE TABLE audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT,
    action TEXT,  -- INSERT, UPDATE, DELETE
    row_id INTEGER,
    old_values TEXT,  -- JSON representation
    new_values TEXT,
    changed_by TEXT,
    changed_at TEXT DEFAULT (datetime('now'))
);

-- Trigger for INSERT
CREATE TRIGGER products_after_insert
AFTER INSERT ON products
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, new_values, changed_by)
    VALUES ('products', 'INSERT', NEW.product_id, 
            json_object('name', NEW.name, 'price', NEW.price, 'stock', NEW.stock),
            'system');
END;

-- Trigger for UPDATE
CREATE TRIGGER products_after_update
AFTER UPDATE ON products
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_values, new_values, changed_by)
    VALUES ('products', 'UPDATE', OLD.product_id,
            json_object('name', OLD.name, 'price', OLD.price, 'stock', OLD.stock),
            json_object('name', NEW.name, 'price', NEW.price, 'stock', NEW.stock),
            'system');
END;

-- Trigger for DELETE
CREATE TRIGGER products_after_delete
AFTER DELETE ON products
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_values, changed_by)
    VALUES ('products', 'DELETE', OLD.product_id,
            json_object('name', OLD.name, 'price', OLD.price, 'stock', OLD.stock),
            'system');
END;
```

Now test:

```sql
INSERT INTO products (name, price, stock) VALUES ('Laptop', 999.99, 10);
UPDATE products SET price = 899.99 WHERE product_id = 1;
DELETE FROM products WHERE product_id = 1;

-- Check audit log
SELECT * FROM audit_log;
```

### Hands‑on Lab 20.2: Soft Delete Pattern

Instead of physically deleting rows, we mark them as deleted.

```sql
-- Add a deleted flag column
ALTER TABLE products ADD COLUMN deleted INTEGER DEFAULT 0;

-- Create a view that excludes deleted rows
CREATE VIEW active_products AS
SELECT * FROM products WHERE deleted = 0;

-- Instead of DELETE, we do UPDATE
CREATE TRIGGER products_soft_delete
INSTEAD OF DELETE ON products
BEGIN
    UPDATE products SET deleted = 1 WHERE product_id = OLD.product_id;
END;

-- Now we can DELETE from the view (or the table) and it will soft delete
DELETE FROM products WHERE product_id = 1;  -- uses the trigger
```

For security, you might also use a view to prevent direct access to the underlying table.

### Hands‑on Lab 20.3: Updating FTS Tables with Triggers

In Module 18, we had an FTS table `docs_fts` that mirrored `docs`. We need to keep it in sync.

```sql
-- Trigger to insert into FTS when a new doc is added
CREATE TRIGGER docs_after_insert
AFTER INSERT ON docs
BEGIN
    INSERT INTO docs_fts(rowid, title, body, author)
    VALUES (NEW.doc_id, NEW.title, NEW.body, NEW.author);
END;

-- Trigger for update
CREATE TRIGGER docs_after_update
AFTER UPDATE ON docs
BEGIN
    UPDATE docs_fts 
    SET title = NEW.title, body = NEW.body, author = NEW.author 
    WHERE rowid = NEW.doc_id;
END;

-- Trigger for delete
CREATE TRIGGER docs_after_delete
AFTER DELETE ON docs
BEGIN
    DELETE FROM docs_fts WHERE rowid = OLD.doc_id;
END;
```

Now any changes to `docs` automatically update the FTS index.

### Views for Simplified Queries

Create a view that joins related tables.

```sql
-- Using library.db from Part 2
CREATE VIEW book_loan_details AS
SELECT 
    b.title,
    a.first_name || ' ' || a.last_name AS author,
    br.first_name || ' ' || br.last_name AS borrower,
    l.loan_date,
    l.return_date
FROM loans l
JOIN books b ON l.book_id = b.book_id
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN borrowers br ON l.borrower_id = br.borrower_id;

-- Now query it easily
SELECT * FROM book_loan_details WHERE return_date IS NULL;
```

### Materialized Views (Emulation)

SQLite does not have native materialized views, but you can emulate them with a regular table and triggers to refresh it.

1. Create a summary table `sales_summary` that aggregates sales by month.
2. Use triggers on the source `sales` table to update the summary.

This is more advanced; we'll cover it in the capstone project.

### Verification

- Test the audit triggers by performing DML and checking the audit log.
- Test soft delete by deleting and then querying the view.
- Verify that FTS sync triggers work by inserting a doc and searching for it.

---

### Reference: Trigger and View Best Practices

- Keep triggers simple and fast; they run inside transactions.
- Avoid recursive triggers (unless you really need them).
- Use `INSTEAD OF` triggers on views for custom behavior.
- Views can be used for security (expose only certain columns).
- Materialized views can dramatically speed up complex aggregations.

You have now unlocked the advanced capabilities of SQLite. You can store and query JSON documents, build full‑text search engines, extend SQLite with virtual tables, and automate business logic with triggers and views. These features allow you to build sophisticated applications that go beyond traditional relational databases.

In **Part 7: Programming with SQLite**, we will leave the CLI behind and integrate SQLite into real applications. You will learn to use Python's `sqlite3` module, build web backends with Flask and FastAPI, and develop offline‑first mobile apps with React Native and Flutter.
