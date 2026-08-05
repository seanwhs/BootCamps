# Appendix C: SQLite Built-in Functions Reference

This appendix provides a complete, quick‑reference guide to SQLite's built‑in scalar functions, aggregate functions, window functions, and key extension functions (JSON1, FTS5). Use it as a cheat sheet when writing queries.

---

## 1. Scalar Functions

Scalar functions operate on a single value (or row) and return a single value.

### String Functions

| Function | Description | Example |
|----------|-------------|---------|
| `length(X)` | Returns the length of string X (in characters). | `length('hello')` → 5 |
| `upper(X)` | Converts string X to uppercase. | `upper('sql')` → 'SQL' |
| `lower(X)` | Converts string X to lowercase. | `lower('SQL')` → 'sql' |
| `trim(X)` | Removes leading and trailing spaces from X. | `trim('  hi  ')` → 'hi' |
| `ltrim(X)` | Removes leading spaces. | `ltrim('  hi')` → 'hi' |
| `rtrim(X)` | Removes trailing spaces. | `rtrim('hi  ')` → 'hi' |
| `substr(X, start, length)` | Returns a substring of X starting at start (1‑based) for length characters. | `substr('abcdef', 2, 3)` → 'bcd' |
| `replace(X, Y, Z)` | Replaces all occurrences of Y in X with Z. | `replace('foo bar', 'bar', 'baz')` → 'foo baz' |
| `instr(X, Y)` | Returns the position (1‑based) of the first occurrence of Y in X, or 0. | `instr('hello world', 'world')` → 7 |
| `like(pattern, X)` | Returns 1 if X matches pattern (case‑insensitive for ASCII), else 0. | `like('h%', 'hello')` → 1 |
| `glob(pattern, X)` | Returns 1 if X matches Unix‑style pattern (case‑sensitive). | `glob('h*', 'hello')` → 1 |
| `printf(format, ...)` | Formats a string using printf‑style placeholders. | `printf('Hello %s', 'world')` → 'Hello world' |
| `quote(X)` | Returns a quoted version of X suitable for SQL literals. | `quote('O\'Reilly')` → `'O''Reilly'` |
| `hex(X)` | Returns the hexadecimal representation of X. | `hex('AB')` → '4142' |
| `randomblob(N)` | Returns a BLOB of N random bytes. | `randomblob(16)` |
| `zeroblob(N)` | Returns a BLOB of N zero bytes. | `zeroblob(100)` |

### Math Functions

| Function | Description | Example |
|----------|-------------|---------|
| `abs(X)` | Absolute value. | `abs(-5)` → 5 |
| `ceil(X)` | Ceiling (smallest integer ≥ X). | `ceil(3.2)` → 4 |
| `floor(X)` | Floor (largest integer ≤ X). | `floor(3.9)` → 3 |
| `round(X, Y)` | Rounds X to Y decimal places (default Y=0). | `round(3.14159, 2)` → 3.14 |
| `min(X, Y, ...)` | Returns the minimum value among arguments. | `min(3, 5, 1)` → 1 |
| `max(X, Y, ...)` | Returns the maximum value among arguments. | `max(3, 5, 1)` → 5 |
| `random()` | Returns a pseudo‑random integer (signed 64‑bit). | `random()` → some int |
| `random()` with seed? No built‑in seed. | |
| `sqrt(X)` | Square root. | `sqrt(16)` → 4.0 |
| `pow(X, Y)` | X raised to power Y. | `pow(2, 3)` → 8.0 |
| `exp(X)` | e^X. | `exp(1)` → 2.718... |
| `ln(X)` | Natural logarithm. | `ln(2.718)` → ~1.0 |
| `log(X)` | Base‑10 logarithm. | `log(100)` → 2.0 |
| `pi()` | Returns π (3.141592653589793). | `pi()` |

### Date/Time Functions

These functions accept a time string, modifiers, and return a formatted string or number.

| Function | Description | Example |
|----------|-------------|---------|
| `date(timestring, ...)` | Returns date as `YYYY‑MM‑DD`. | `date('now')` |
| `time(timestring, ...)` | Returns time as `HH:MM:SS`. | `time('now')` |
| `datetime(timestring, ...)` | Returns datetime as `YYYY‑MM‑DD HH:MM:SS`. | `datetime('now')` |
| `julianday(timestring, ...)` | Returns Julian day number (real). | `julianday('now')` |
| `strftime(format, timestring, ...)` | Returns formatted string using `strftime` format codes. | `strftime('%Y‑%m‑%d', 'now')` |
| `unixepoch(timestring)` | Returns Unix epoch seconds (SQLite 3.38+). | `unixepoch('2025‑01‑01')` |

**Common time strings:** `'now'`, `'2025-01-15'`, `'2025-01-15 14:30:00'`, `'now'`, `'today'`, `'yesterday'`, `'tomorrow'`.

**Modifiers:** `'+N days'`, `'-N months'`, `'start of month'`, `'start of year'`, `'localtime'`, `'utc'`.

### Conversion Functions

| Function | Description | Example |
|----------|-------------|---------|
| `cast(expr AS type)` | Converts expression to the specified type (INTEGER, REAL, TEXT, BLOB). | `cast('123' AS INTEGER)` → 123 |
| `typeof(expr)` | Returns the storage class of the expression. | `typeof(123)` → 'integer' |
| `hex(X)` | Returns hexadecimal representation (also string). | `hex(255)` → 'FF' |
| `unicode(char)` | Returns the Unicode code point of the first character. | `unicode('A')` → 65 |
| `char(X1, X2, ...)` | Returns a string composed of characters with the given code points. | `char(65, 66)` → 'AB' |

### Aggregate Functions (used with GROUP BY)

| Function | Description |
|----------|-------------|
| `count(*)` | Number of rows in the group. |
| `count(expr)` | Number of non‑NULL values of expr. |
| `sum(expr)` | Sum of expr (returns NULL if no rows). |
| `total(expr)` | Sum of expr (returns 0.0 if no rows). |
| `avg(expr)` | Average of expr (returns NULL if no rows). |
| `min(expr)` | Minimum non‑NULL value. |
| `max(expr)` | Maximum non‑NULL value. |
| `group_concat(expr, sep)` | Concatenates expr values using sep (default ','). |

### JSON1 Functions (if extension loaded)

| Function | Description |
|----------|-------------|
| `json_valid(X)` | Returns 1 if X is valid JSON, else 0. |
| `json_extract(json, path, ...)` | Extracts value(s) at the given JSON path(s). |
| `json_set(json, path, value, ...)` | Adds or updates fields. |
| `json_insert(json, path, value, ...)` | Adds fields only if they don't exist. |
| `json_replace(json, path, value, ...)` | Replaces existing fields. |
| `json_remove(json, path, ...)` | Removes fields. |
| `json_array_length(json)` | Returns length of a JSON array. |
| `json_each(json)` | Table‑valued function to iterate over array elements. |
| `json_tree(json)` | Table‑valued function to iterate over entire structure. |
| `json_group_array(expr)` | Aggregate to build a JSON array. |
| `json_group_object(key, value)` | Aggregate to build a JSON object. |

### FTS5 Functions (for full‑text search)

| Function | Description |
|----------|-------------|
| `match()` | Operator used in `WHERE` clause (e.g., `WHERE col MATCH 'query'`). |
| `bm25(fts_table)` | Returns a relevance score (lower is better) for ranking. |
| `snippet(fts_table, col_index, open_tag, close_tag, separator, max_tokens)` | Returns an excerpt with highlighted matches. |

---

## 2. Aggregate Functions

Used with `GROUP BY`. See table above. They can also be used as window functions with `OVER`.

### Example with GROUP BY:
```sql
SELECT category, COUNT(*) AS count, AVG(price) AS avg_price
FROM products
GROUP BY category;
```

---

## 3. Window Functions

Window functions perform calculations across a set of rows related to the current row, without collapsing the result set. They are used with the `OVER` clause.

### Common Window Functions

| Function | Description | Example |
|----------|-------------|---------|
| `row_number()` | Sequential integer starting at 1 per partition. | `ROW_NUMBER() OVER (ORDER BY id)` |
| `rank()` | Rank with gaps. | `RANK() OVER (ORDER BY score DESC)` |
| `dense_rank()` | Rank without gaps. | `DENSE_RANK() OVER (ORDER BY score DESC)` |
| `lag(expr, offset, default)` | Accesses previous row's value. | `LAG(salary, 1, 0) OVER (ORDER BY date)` |
| `lead(expr, offset, default)` | Accesses next row's value. | `LEAD(salary, 1, 0) OVER (ORDER BY date)` |
| `first_value(expr)` | Value of first row in window frame. | `FIRST_VALUE(salary) OVER (PARTITION BY dept ORDER BY date)` |
| `last_value(expr)` | Value of last row in window frame. | `LAST_VALUE(salary) OVER (...)` |
| `sum(expr) OVER(...)` | Running total. | `SUM(amount) OVER (ORDER BY date)` |
| `avg(expr) OVER(...)` | Moving average. | `AVG(amount) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` |

### Window Frame Specification

- `ROWS BETWEEN start AND end` – physical row offsets.
- `RANGE BETWEEN start AND end` – logical value range.
- Common: `UNBOUNDED PRECEDING`, `CURRENT ROW`, `UNBOUNDED FOLLOWING`, `N PRECEDING`, `N FOLLOWING`.

---

## 4. Other Useful Functions

| Function | Description |
|----------|-------------|
| `changes()` | Returns the number of rows affected by the last INSERT, UPDATE, or DELETE. |
| `total_changes()` | Returns the total number of rows changed since the connection was opened. |
| `last_insert_rowid()` | Returns the ROWID of the last inserted row. |
| `sqlite_version()` | Returns the SQLite version string. |
| `sqlite_source_id()` | Returns the source code identifier. |
| `zeroblob(N)` | Returns a BLOB of N zero bytes. |
| `iif(cond, true_value, false_value)` | Short‑form `CASE`. |

---

## 5. Using Functions in Queries

**Example:**
```sql
SELECT
    id,
    upper(name) AS name_upper,
    round(price * 1.2, 2) AS price_with_tax,
    date(created_at) AS created_date,
    row_number() OVER (ORDER BY price) AS rank_by_price
FROM products
WHERE price > 100;
```

---

This appendix covers the majority of SQLite's built‑in functions. For a complete and up‑to‑date list, always refer to the official SQLite documentation at [sqlite.org/lang_corefunc.html](https://www.sqlite.org/lang_corefunc.html).
