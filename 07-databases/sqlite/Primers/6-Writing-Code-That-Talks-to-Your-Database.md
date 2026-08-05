# Programming with SQLite Primer 6: Writing Code That Talks to Your Database

You've learned SQL, designed your schema, and tuned performance. Now it's time to bring your database to life by connecting it to a real application. This primer covers the essentials of using SQLite from code—regardless of your programming language—with concrete examples in Python (the most common language for SQLite tutorials) and notes for other ecosystems.

---

## 1. The Big Picture: How Applications Talk to SQLite

SQLite is an **in‑process library**. Your application links against the SQLite C library (or its bindings) and makes direct function calls. There's **no network, no server, no authentication**—just a file on disk and an API.

This means:
- **Extremely low latency** (no network round‑trips).
- **Simple deployment** (just include the library).
- **No separate process to manage** (no connection pool or database server).

Your job is to:
1. **Open** a connection to the database file.
2. **Prepare** SQL statements (with placeholders for user data).
3. **Bind** parameters (to prevent SQL injection).
4. **Execute** the statement.
5. **Fetch** results (if any).
6. **Close** the connection (or use a context manager).

---

## 2. Essential Concepts

### Connection
A connection is a handle to the database file. It holds the state (e.g., PRAGMA settings, transactions, prepared statements) for a single session.

### Cursor
A cursor is a pointer that executes SQL statements and fetches rows. In many APIs, you create a cursor from a connection.

### Prepared Statement (Parameterized Query)
A SQL statement with placeholders (`?` or named parameters). You **prepare** it once, then **bind** values to the placeholders for each execution. This is **essential for security** and performance.

### Commit / Rollback
You control transactions from code: `BEGIN`, `COMMIT`, `ROLLBACK` (or the API equivalents).

### Error Handling
Always catch exceptions. SQLite errors include `IntegrityError` (unique, foreign key), `OperationalError` (busy, disk full), `DatabaseError` (general corruption), etc.

---

## 3. Python Example: A Contact Manager

Python's standard library includes the `sqlite3` module. Here's a minimal but complete example:

```python
import sqlite3

# 1. Open a connection (creates the file if it doesn't exist)
conn = sqlite3.connect('contacts.db')
cursor = conn.cursor()

# 2. Create a table
cursor.execute('''
    CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT
    )
''')

# 3. Insert a contact (using placeholders)
cursor.execute(
    'INSERT INTO contacts (name, email, phone) VALUES (?, ?, ?)',
    ('Alice', 'alice@example.com', '555-1234')
)

# 4. Commit the changes (important!)
conn.commit()

# 5. Query and fetch results
cursor.execute('SELECT * FROM contacts')
rows = cursor.fetchall()  # returns list of tuples
for row in rows:
    print(f"{row[1]} ({row[2]})")

# 6. Use a context manager (auto‑commits, auto‑closes)
with sqlite3.connect('contacts.db') as conn:
    cursor = conn.execute('SELECT * FROM contacts')
    for row in cursor:
        print(row)

# 7. Close the connection (if not using context manager)
conn.close()
```

---

## 4. Parameterized Queries (SQL Injection Prevention)

**Never** build SQL strings using string concatenation or f‑strings.

```python
# DANGEROUS (SQL injection vulnerability)
name = "'; DROP TABLE contacts; --"
cursor.execute(f"SELECT * FROM contacts WHERE name = '{name}'")
```

**Always** use placeholders:

```python
# Safe
name = "'; DROP TABLE contacts; --"
cursor.execute('SELECT * FROM contacts WHERE name = ?', (name,))
# This will search for that exact string (no injection)
```

Named placeholders (easier for many parameters):
```python
cursor.execute(
    'INSERT INTO contacts (name, email, phone) VALUES (:name, :email, :phone)',
    {'name': 'Bob', 'email': 'bob@example.com', 'phone': '555-5678'}
)
```

---

## 5. Transaction Management in Code

By default, `sqlite3` starts a transaction on the first SQL statement and doesn't commit until you call `commit()`. If you use the connection as a context manager, it **commits** on exit if no exception, or **rolls back** on exception.

```python
with sqlite3.connect('contacts.db') as conn:
    # This block is a transaction
    conn.execute('UPDATE contacts SET phone = ? WHERE id = ?', ('555-9999', 1))
    # If an exception occurs here, the transaction is rolled back
# On normal exit, it commits
```

For explicit control:
```python
conn = sqlite3.connect('contacts.db')
try:
    conn.execute('BEGIN')
    # ... do work ...
    conn.commit()
except Exception:
    conn.rollback()
    raise
finally:
    conn.close()
```

---

## 6. Row Factories (Access Columns by Name)

By default, rows are tuples. Use `row_factory` to get dictionaries or custom objects.

```python
conn = sqlite3.connect('contacts.db')
conn.row_factory = sqlite3.Row  # rows can be accessed by name

cursor = conn.execute('SELECT name, email FROM contacts')
for row in cursor:
    print(row['name'], row['email'])
```

Or use `dict` factory:
```python
def dict_factory(cursor, row):
    return {col[0]: row[i] for i, col in enumerate(cursor.description)}

conn.row_factory = dict_factory
```

---

## 7. Error Handling

Catch specific exceptions:

```python
try:
    cursor.execute('INSERT INTO contacts (name, email) VALUES (?, ?)', ('Alice', 'alice@example.com'))
    conn.commit()
except sqlite3.IntegrityError:
    print('Duplicate email or constraint violation')
except sqlite3.OperationalError as e:
    if 'database is locked' in str(e):
        print('Database busy, retry later')
    else:
        print(f'Operational error: {e}')
except sqlite3.DatabaseError as e:
    print(f'Database error: {e}')
```

---

## 8. Handling `SQLITE_BUSY` in Code

Set a busy timeout:

```python
conn = sqlite3.connect('contacts.db')
conn.execute('PRAGMA busy_timeout = 5000')  # wait 5 seconds
```

Or use a custom busy handler:
```python
import time

def busy_handler(attempts):
    print(f'Database busy, retrying... (attempt {attempts})')
    time.sleep(0.1)
    return True  # continue retrying

conn.set_busy_handler(busy_handler)
```

---

## 9. Working with BLOBs and JSON

### BLOBs (Binary Data)
```python
with open('photo.jpg', 'rb') as f:
    photo_data = f.read()
cursor.execute('INSERT INTO photos (name, data) VALUES (?, ?)', ('profile', photo_data))
```

### JSON (using SQLite's JSON1 extension)
```python
import json
cursor.execute(
    'INSERT INTO products (name, attributes) VALUES (?, ?)',
    ('Laptop', json.dumps({'brand': 'Dell', 'ram': 16}))
)
```

---

## 10. Performance Tips for Applications

- **Use transactions** for batch operations (e.g., 10,000 inserts in one `BEGIN`/`COMMIT`).
- **Reuse prepared statements** if executing the same query many times.
- **Fetch only what you need**: use `LIMIT` and select only required columns.
- **Use `row_factory`** to avoid tuple index confusion.
- **Close connections** when done (or use context managers).
- **Enable WAL mode** for better concurrency.

---

## 11. Quick Reference: Python `sqlite3` Cheat Sheet

| Task | Code |
|------|------|
| Open connection | `conn = sqlite3.connect('file.db')` |
| Create in‑memory | `conn = sqlite3.connect(':memory:')` |
| Execute one statement | `cursor.execute('SQL', params)` |
| Execute many (batch) | `cursor.executemany('SQL', list_of_params)` |
| Fetch all rows | `rows = cursor.fetchall()` |
| Fetch one row | `row = cursor.fetchone()` |
| Commit | `conn.commit()` |
| Rollback | `conn.rollback()` |
| Close | `conn.close()` |
| Set row factory | `conn.row_factory = sqlite3.Row` |
| Enable WAL | `conn.execute('PRAGMA journal_mode = WAL')` |

---

## 12. Integrating with Other Languages

### Node.js (with `better-sqlite3`)
```javascript
const Database = require('better-sqlite3');
const db = new Database('contacts.db');

const stmt = db.prepare('SELECT * FROM contacts WHERE name = ?');
const rows = stmt.all('Alice');
```

### Java (JDBC)
```java
import java.sql.*;
Connection conn = DriverManager.getConnection("jdbc:sqlite:contacts.db");
PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM contacts WHERE name = ?");
pstmt.setString(1, "Alice");
ResultSet rs = pstmt.executeQuery();
```

### C# (.NET with `Microsoft.Data.Sqlite`)
```csharp
using Microsoft.Data.Sqlite;
using var connection = new SqliteConnection("Data Source=contacts.db");
connection.Open();
var command = connection.CreateCommand();
command.CommandText = "SELECT * FROM contacts WHERE name = @name";
command.Parameters.AddWithValue("@name", "Alice");
```

---

## 13. Common Pitfalls and How to Avoid Them

| Pitfall | Solution |
|---------|----------|
| **SQL injection** | Always use parameterized queries. |
| **Forgetting to commit** | Use context managers or explicit `commit()`. |
| **Leaking connections** | Use `with` or `try/finally` to close. |
| **Holding transactions too long** | Keep transactions short; commit early. |
| **Not handling `SQLITE_BUSY`** | Set `busy_timeout` and retry. |
| **Using `SELECT *` in production** | List only needed columns. |
| **String concatenation for SQL** | Use placeholders and parameter binding. |

---

## Next Steps

- Learn about **connection pooling** (not needed for SQLite, but useful for web apps).
- Explore **async SQLite** (e.g., `aiosqlite` in Python).
- Dive into **ORM integration** (SQLAlchemy, Django, etc.).
- Build a full application with SQLite (check the **Master SQLite** series).

---

**Programming with SQLite is straightforward.** The key is to respect its simplicity: treat the database file as a shared resource, use parameterized queries, and manage transactions explicitly. Now go connect your code to the data!

Happy coding!
