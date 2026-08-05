# Appendix B: SQLite Data Types, Storage Classes, and Type Affinity

This appendix provides a comprehensive reference for SQLite's unique typing system. Understanding these concepts is crucial for designing efficient schemas and avoiding surprises when storing or querying data.

## 1. Storage Classes

SQLite stores values using one of five **storage classes** (also called "datatypes" at the storage level). These are the actual formats used on disk.

| Storage Class | Description | Storage Size |
|---------------|-------------|--------------|
| **NULL** | A missing or unknown value. | 0 bytes (only a flag in the record header). |
| **INTEGER** | A signed integer value. Stored in 1, 2, 3, 4, 6, or 8 bytes depending on the magnitude. | Variable (1‑8 bytes). |
| **REAL** | A floating‑point value (IEEE 754 64‑bit). | 8 bytes. |
| **TEXT** | A string of text, stored using UTF‑8, UTF‑16BE, or UTF‑16LE encoding. | Variable (length of string + overhead). |
| **BLOB** | A binary large object—raw bytes, stored exactly as provided. | Variable (length of data + overhead). |

**Important:** The storage class is determined by the value itself, not by the column declaration. For example, you can store an integer in a column declared as `TEXT`—it will be stored as `TEXT` (the string representation) or as `INTEGER` depending on the value and affinity (see below).

## 2. Type Affinity

When you declare a column with a type (e.g., `INTEGER`, `TEXT`, `VARCHAR(255)`), SQLite assigns a **type affinity** to that column. Affinity is a recommendation that influences how values are *converted* when inserted, but it does **not** enforce the type.

### Affinity Determination Rules

SQLite examines the declared type and assigns an affinity based on these rules (in order):

| Rule | Declared Type Contains... | Resulting Affinity |
|------|---------------------------|---------------------|
| 1 | `INT` | **INTEGER** |
| 2 | `CHAR`, `CLOB`, or `TEXT` | **TEXT** |
| 3 | `BLOB` | **BLOB** |
| 4 | `REAL`, `FLOA`, or `DOUB` | **REAL** |
| 5 | (none of the above) | **NUMERIC** |

**Examples:**

| Declared Type | Affinity | Reason |
|---------------|----------|--------|
| `INTEGER` | INTEGER | Contains "INT" |
| `VARCHAR(255)` | TEXT | Contains "CHAR" |
| `TEXT` | TEXT | Contains "TEXT" |
| `REAL` | REAL | Contains "REAL" |
| `DOUBLE PRECISION` | REAL | Contains "DOUB" |
| `NUMERIC` | NUMERIC | No match, default |
| `BOOLEAN` | NUMERIC | No match, default |
| `BLOB` | BLOB | Contains "BLOB" |
| `STRING` | NUMERIC | No match (does not contain "CHAR" or "TEXT") |

### Affinity Behavior on Insert/Update

When a value is inserted into a column, SQLite attempts to convert the value to the column's affinity before storing.

- **INTEGER affinity**: Converts to `INTEGER` if possible; otherwise tries `REAL`; otherwise stores as `TEXT` or `BLOB`.
- **REAL affinity**: Converts to `REAL` if possible; otherwise stores as `TEXT` or `BLOB`.
- **TEXT affinity**: Converts to `TEXT` (all values are stored as strings, except `BLOB` which stays as `BLOB`).
- **BLOB affinity**: No conversion; values are stored exactly as provided (except `NULL`).
- **NUMERIC affinity**: Attempts to convert to `INTEGER`, then `REAL`; otherwise stores as `TEXT` or `BLOB`.

**Example:**
```sql
CREATE TABLE demo (
    a_int INTEGER,
    a_text TEXT,
    a_blob BLOB,
    a_numeric NUMERIC
);

INSERT INTO demo VALUES ('123', 456, 'hello', '78.9');
-- a_int stores 123 as INTEGER
-- a_text stores '456' as TEXT
-- a_blob stores 'hello' as BLOB
-- a_numeric stores 78.9 as REAL (since numeric affinity prefers numbers)
```

## 3. Determining the Storage Class of a Value

Use the `typeof()` SQL function to check the storage class of a value.

```sql
SELECT typeof('hello');   -- 'text'
SELECT typeof(123);       -- 'integer'
SELECT typeof(123.45);    -- 'real'
SELECT typeof(NULL);      -- 'null'
SELECT typeof(x'0102');   -- 'blob'
```

## 4. Type Affinity in Practice: Comparisons and Sorting

SQLite's flexible typing also affects comparisons and sorting. The rules are complex but can be summarized:

- When comparing two values, SQLite uses the **storage class** of the values to determine the comparison rules.
- If one side is `TEXT` and the other is `INTEGER`, SQLite generally treats the `TEXT` as a number if it looks like one (using `NUMERIC` affinity).
- If both are `TEXT`, lexicographic comparison is used.
- For `BLOB`, byte‑by‑byte comparison is used.

**Example:**
```sql
SELECT '123' < 45;  -- This returns 0? Actually, '123' is converted to 123 for comparison, so 123 < 45 is false (0).
SELECT 'abc' < 45;  -- 'abc' cannot be converted to a number, so the comparison uses TEXT affinity? Actually, if conversion fails, it may be treated as TEXT and compared lexicographically? The rule is: if the TEXT value is a well-formed integer/real literal, it is converted; otherwise, it is compared as TEXT. This can be tricky.
```

**Best practice:** Avoid relying on implicit conversion across different types. Use `CAST` or explicit conversion functions when necessary.

## 5. Boolean Handling

SQLite does **not** have a native Boolean type. Booleans are typically stored as integers:

- `0` for false
- `1` for true

You can use `CHECK` constraints to enforce this.

```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY,
    name TEXT,
    is_done INTEGER CHECK (is_done IN (0,1))
);
```

When retrieving, you can interpret the integer as a boolean in your application code.

## 6. Date and Time Handling

SQLite does **not** have a native date/time type. Instead, you can store dates/times as:

- **TEXT**: ISO8601 strings (`'2025-01-15 14:30:00'`)
- **INTEGER**: Unix epoch seconds (`1705312200`)
- **REAL**: Julian day numbers (`2460710.5`)

SQLite provides a set of date/time functions to manipulate these formats.

### Common Date Functions

| Function | Description |
|----------|-------------|
| `date(timestring, modifiers...)` | Returns the date as `YYYY-MM-DD`. |
| `time(timestring, modifiers...)` | Returns the time as `HH:MM:SS`. |
| `datetime(timestring, modifiers...)` | Returns the date and time as `YYYY-MM-DD HH:MM:SS`. |
| `julianday(timestring, modifiers...)` | Returns the Julian day number (a real number). |
| `strftime(format, timestring, modifiers...)` | Returns a formatted string using the same format codes as the C `strftime` function. |
| `unixepoch(timestring)` | Returns the Unix epoch seconds (SQLite 3.38+). |

**Useful modifiers:**
- `'localtime'` – convert from UTC to local time.
- `'utc'` – convert to UTC.
- `'+N days'`, `'-N months'`, `'start of month'`, etc.

**Examples:**
```sql
SELECT date('now');                     -- today's date
SELECT datetime('now', 'localtime');    -- current local datetime
SELECT datetime('2025-01-15 14:30:00', '+1 day'); -- add one day
SELECT strftime('%Y-%m-%d %H:%M', 'now');  -- custom format
```

**Best practice:** Store dates as ISO8601 `TEXT` because they are human‑readable, sortable, and compatible with the date functions. Use `DATETIME('now', 'localtime')` as a default value for `created_at` columns.

## 7. Type Affinity and `ROWID`

Every table in SQLite has a `ROWID` (unless `WITHOUT ROWID` is specified). The `ROWID` is a 64‑bit signed integer. If you declare an `INTEGER PRIMARY KEY` column, that column becomes an alias for `ROWID`. This is the only case where affinity affects primary key behavior.

- `INTEGER PRIMARY KEY` columns must store integers; they will attempt to convert values to integers.
- If you use `INTEGER PRIMARY KEY AUTOINCREMENT`, SQLite adds a separate `sqlite_sequence` table to track the next ID.

**Example:**
```sql
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);
INSERT INTO users (name) VALUES ('Alice');  -- id will be auto-incremented
SELECT rowid, id FROM users;  -- both same
```

## 8. Summary Table: Affinity vs. Storage Class

| Affinity | Preferred Storage | Conversion Behavior |
|----------|-------------------|---------------------|
| INTEGER | INTEGER (or REAL/TEXT if conversion fails) | Converts to integer if possible; otherwise real; otherwise text. |
| REAL | REAL (or INTEGER/TEXT if conversion fails) | Converts to real if possible; otherwise integer; otherwise text. |
| TEXT | TEXT | All non‑BLOB values are stored as TEXT. BLOB remains BLOB. |
| BLOB | BLOB | No conversion; stored as‑is (except NULL). |
| NUMERIC | INTEGER or REAL (or TEXT if conversion fails) | Tries integer, then real; otherwise text. |

## 9. Practical Recommendations

- **Be explicit:** Use appropriate affinities for your columns, but don't rely on them for enforcement.
- **Use `CHECK` constraints** to enforce actual data types if needed (e.g., `CHECK (typeof(column) = 'integer')`).
- **Use `CAST`** to force conversions when you need predictable behavior.
- **Prefer `TEXT` for dates** and use the built‑in date functions.
- **Use `BOOLEAN` as a 0/1 integer** with a `CHECK` constraint.

---

This appendix gives you the complete picture of SQLite's flexible typing. Refer back to it whenever you encounter unexpected storage or comparison behavior in your applications.
