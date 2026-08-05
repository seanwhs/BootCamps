# Advanced Features Primer 9: JSON, Full‑Text Search, and Extensibility

SQLite isn't just a simple relational database. It includes powerful extensions for modern applications: storing and querying JSON, building search engines with full‑text search (FTS5), automating logic with triggers, simplifying queries with views, and even reading CSV files as tables. This primer gives you a practical tour of these advanced capabilities.

---

## 1. JSON Support (JSON1 Extension)

SQLite can store JSON documents in `TEXT` columns and query them efficiently. The JSON1 extension provides functions to extract, modify, and aggregate JSON data.

### Storing JSON
```sql
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT,
    attributes TEXT  -- JSON document
);

INSERT INTO products (name, attributes) VALUES
    ('Laptop', '{"brand":"Dell","specs":{"cpu":"i7","ram":16},"in_stock":true}'),
    ('Phone', '{"brand":"Apple","specs":{"cpu":"A15","storage":"128GB"},"color":"silver"}');
```

### Extracting JSON Values
```sql
-- Extract brand
SELECT name, json_extract(attributes, '$.brand') AS brand FROM products;

-- Extract nested spec
SELECT name, json_extract(attributes, '$.specs.cpu') AS cpu FROM products;

-- Shorthand (SQLite 3.38+)
SELECT name, attributes->>'$.brand' AS brand FROM products;

-- Filter by JSON value
SELECT name FROM products WHERE attributes->>'$.in_stock' = 'true';
```

### Modifying JSON
```sql
-- Add a field
UPDATE products SET attributes = json_set(attributes, '$.warranty', '2 years')
WHERE id = 1;

-- Remove a field
UPDATE products SET attributes = json_remove(attributes, '$.color')
WHERE id = 2;
```

### Generating JSON from Relational Data
```sql
-- Aggregate rows into JSON array
SELECT json_group_array(name) AS all_names FROM products;

-- Build JSON object
SELECT json_group_object(id, name) AS id_name_map FROM products;
```

### Indexing JSON Fields
Create **generated columns** to extract JSON values, then index them.

```sql
ALTER TABLE products ADD COLUMN brand TEXT GENERATED ALWAYS AS (attributes->>'$.brand') STORED;
CREATE INDEX idx_products_brand ON products(brand);
```

Now queries filtering on `brand` use the index.

---

## 2. Full‑Text Search (FTS5)

FTS5 lets you search text fields quickly, with relevance ranking, snippets, and support for Boolean operators, prefixes, and phrases.

### Creating an FTS5 Table
```sql
-- Virtual table for full‑text search
CREATE VIRTUAL TABLE docs_fts USING fts5(title, content);
```

### Inserting Data
```sql
INSERT INTO docs_fts (title, content) VALUES
    ('SQLite Tutorial', 'SQLite is a lightweight, serverless database.'),
    ('Advanced SQLite', 'Learn about JSON, FTS, and virtual tables.'),
    ('Performance Tuning', 'Indexing and query optimization make SQLite fast.');
```

### Querying with `MATCH`
```sql
-- Simple word search
SELECT title FROM docs_fts WHERE docs_fts MATCH 'SQLite';

-- Phrase search
SELECT title FROM docs_fts WHERE docs_fts MATCH '"serverless database"';

-- Prefix search (words starting with 'opti')
SELECT title FROM docs_fts WHERE docs_fts MATCH 'opti*';

-- Boolean AND
SELECT title FROM docs_fts WHERE docs_fts MATCH 'SQLite AND FTS';

-- NEAR (within 5 words)
SELECT title FROM docs_fts WHERE docs_fts MATCH 'SQLite NEAR/5 FTS';
```

### Ranking with `bm25()`
```sql
SELECT title, bm25(docs_fts) AS rank
FROM docs_fts
WHERE docs_fts MATCH 'SQLite'
ORDER BY rank;
```

### Snippets (Highlighting)
```sql
SELECT title, snippet(docs_fts, 1, '<b>', '</b>', '...', 30) AS excerpt
FROM docs_fts
WHERE docs_fts MATCH 'SQLite';
```

### Using an External Content Table
If you already have a table, you can link FTS to it to avoid duplication.

```sql
CREATE TABLE docs (id INTEGER PRIMARY KEY, title TEXT, content TEXT);
INSERT INTO docs VALUES (1, 'SQLite', 'Lightweight database');

CREATE VIRTUAL TABLE docs_fts USING fts5(title, content, content=docs);
INSERT INTO docs_fts(rowid, title, content) SELECT id, title, content FROM docs;
```

**Tip:** Keep FTS in sync using triggers (covered below).

---

## 3. Triggers (Automated Actions)

Triggers automatically run SQL in response to `INSERT`, `UPDATE`, or `DELETE`. They're great for:
- Audit logging
- Data validation (beyond constraints)
- Keeping summary tables or FTS tables in sync
- Soft deletes

### Basic Trigger Syntax
```sql
CREATE TRIGGER trigger_name
[BEFORE|AFTER|INSTEAD OF] [INSERT|UPDATE|DELETE] ON table_name
[WHEN condition]
BEGIN
    -- SQL statements here
END;
```

### Example: Audit Logging
```sql
-- Audit log table
CREATE TABLE audit_log (
    id INTEGER PRIMARY KEY,
    table_name TEXT,
    action TEXT,
    row_id INTEGER,
    old_values TEXT,
    new_values TEXT,
    changed_at TEXT DEFAULT (datetime('now'))
);

-- Trigger for INSERT
CREATE TRIGGER products_audit_insert
AFTER INSERT ON products
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, new_values)
    VALUES ('products', 'INSERT', NEW.id, json_object('name', NEW.name, 'price', NEW.price));
END;

-- Trigger for UPDATE
CREATE TRIGGER products_audit_update
AFTER UPDATE ON products
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_values, new_values)
    VALUES ('products', 'UPDATE', OLD.id,
            json_object('name', OLD.name, 'price', OLD.price),
            json_object('name', NEW.name, 'price', NEW.price));
END;
```

### Example: Soft Delete
Instead of deleting rows, mark them as deleted.

```sql
ALTER TABLE products ADD COLUMN deleted INTEGER DEFAULT 0;

CREATE VIEW active_products AS
SELECT * FROM products WHERE deleted = 0;

CREATE TRIGGER products_soft_delete
INSTEAD OF DELETE ON products
BEGIN
    UPDATE products SET deleted = 1 WHERE id = OLD.id;
END;

-- Now DELETE FROM products sets deleted=1
```

### Example: Keeping FTS in Sync
```sql
CREATE TRIGGER docs_fts_insert
AFTER INSERT ON docs
BEGIN
    INSERT INTO docs_fts(rowid, title, content) VALUES (NEW.id, NEW.title, NEW.content);
END;
```

---

## 4. Views (Virtual Tables)

Views are saved queries that you can treat like tables. They simplify complex queries and can be used for security (expose only certain columns).

### Creating a View
```sql
CREATE VIEW product_summary AS
SELECT 
    p.id,
    p.name,
    p.price,
    c.name AS category,
    (SELECT COUNT(*) FROM orders WHERE product_id = p.id) AS order_count
FROM products p
JOIN categories c ON p.category_id = c.id;
```

### Using a View
```sql
SELECT * FROM product_summary WHERE order_count > 10;
```

### Updatable Views with `INSTEAD OF` Triggers
```sql
CREATE VIEW active_products AS
SELECT * FROM products WHERE deleted = 0;

CREATE TRIGGER active_products_insert
INSTEAD OF INSERT ON active_products
BEGIN
    INSERT INTO products (name, price, deleted) VALUES (NEW.name, NEW.price, 0);
END;

-- Now INSERT INTO active_products works
```

### Materialized Views (Emulation)
SQLite doesn't have built‑in materialized views, but you can create a regular table and refresh it with a trigger or scheduled job.

---

## 5. Virtual Tables (CSV, etc.)

Virtual tables make external data (CSV files, JSON, etc.) appear as SQL tables.

### CSV Virtual Table
```sql
-- Load CSV extension (if not built‑in)
.load /path/to/csv

-- Create virtual table over a CSV file
CREATE VIRTUAL TABLE temp.csv_data USING csv(filename='data.csv');

-- Query like a normal table
SELECT * FROM csv_data LIMIT 10;
```

### `generate_series` (Built‑in Virtual Table)
```sql
SELECT value FROM generate_series(1, 10);
```

### Custom Virtual Tables
You can write your own in C or Python (advanced; not covered here).

---

## 6. Putting It All Together: A Hybrid Example

Build a blog application with:
- Relational tables for `authors` and `posts`.
- JSON for flexible `post_metadata` (tags, views, custom fields).
- FTS5 for searching post content.
- Triggers to keep FTS in sync.
- Views for common reports.

```sql
-- 1. Relational tables
CREATE TABLE authors (id INTEGER PRIMARY KEY, name TEXT);

CREATE TABLE posts (
    id INTEGER PRIMARY KEY,
    author_id INTEGER REFERENCES authors(id),
    title TEXT,
    content TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    metadata TEXT  -- JSON: tags, views, rating
);

-- 2. JSON index on tags (extract first tag)
ALTER TABLE posts ADD COLUMN first_tag TEXT GENERATED ALWAYS AS (json_extract(metadata, '$.tags[0]')) STORED;
CREATE INDEX idx_posts_first_tag ON posts(first_tag);

-- 3. FTS table
CREATE VIRTUAL TABLE posts_fts USING fts5(title, content, content=posts);

-- 4. Triggers to sync FTS
CREATE TRIGGER posts_ai AFTER INSERT ON posts
BEGIN
    INSERT INTO posts_fts(rowid, title, content) VALUES (NEW.id, NEW.title, NEW.content);
END;

CREATE TRIGGER posts_au AFTER UPDATE ON posts
BEGIN
    UPDATE posts_fts SET title = NEW.title, content = NEW.content WHERE rowid = NEW.id;
END;

CREATE TRIGGER posts_ad AFTER DELETE ON posts
BEGIN
    DELETE FROM posts_fts WHERE rowid = OLD.id;
END;

-- 5. View for popular posts
CREATE VIEW popular_posts AS
SELECT p.id, p.title, a.name AS author, json_extract(p.metadata, '$.views') AS views
FROM posts p
JOIN authors a ON p.author_id = a.id
ORDER BY views DESC;
```

Now you can:
- Insert posts with JSON metadata.
- Search posts using `MATCH` queries.
- Get popular posts from the view.
- Audit changes with triggers (if you add an audit log).

---

## 7. Quick Reference

| Feature | Key Syntax |
|---------|------------|
| JSON extraction | `json_extract(json, '$.path')` or `json->>'$.path'` |
| JSON modification | `json_set(json, '$.path', value)` |
| FTS5 table creation | `CREATE VIRTUAL TABLE name USING fts5(col1, col2, content=table)` |
| FTS5 query | `WHERE table MATCH 'search terms'` |
| Ranking | `bm25(table)` in ORDER BY |
| Snippet | `snippet(table, col, '<b>', '</b>', '...', 30)` |
| Trigger | `CREATE TRIGGER name BEFORE/AFTER INSERT/UPDATE/DELETE ON table` |
| View | `CREATE VIEW name AS SELECT ...` |
| Virtual table | `CREATE VIRTUAL TABLE name USING module(args)` |

---

## 8. Best Practices

- **Use JSON for flexible, variable‑shape data** (e.g., user‑defined fields, API responses).
- **Index JSON fields** using generated columns for performance.
- **Use FTS5** for searching large text corpora; it's faster and more powerful than `LIKE`.
- **Keep triggers simple**; complex triggers can hurt performance.
- **Use views** to encapsulate complex joins; they make application code cleaner.
- **Test virtual tables** (like CSV) with small files first; they're great for ETL.

---

## Next Steps

- Dive deeper into **JSON1** and **FTS5** in the main series.
- Learn about **spatial extensions** (Spatialite) if you need GIS.
- Explore **custom extensions** and **loadable modules**.
- Build real projects with these advanced features.

---

**SQLite is more than a simple database. It's a Swiss Army knife for data.** With JSON, FTS, triggers, and views, you can build sophisticated applications without leaving the comfort of SQLite. Now go extend your toolkit!
