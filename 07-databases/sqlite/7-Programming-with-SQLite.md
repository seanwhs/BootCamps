Welcome to Part 7. So far, we have interacted with SQLite exclusively through the command‑line shell. Now we bring SQLite into the real world of application development. This part covers integrating SQLite into Python applications (desktop, scripts, backends), web frameworks (Flask, Django, FastAPI), and mobile platforms (Android, React Native, Flutter). You will learn connection management, prepared statements, row factories, custom functions, thread safety, async patterns, and testing strategies. By the end, you will be able to embed SQLite securely and efficiently in any environment.

**Part 7** is divided into three modules:

- **Module 21:** Python Integration – The `sqlite3` module, context managers, parameterized queries, row factories, user‑defined functions, aggregates, thread safety, and async.
- **Module 22:** Web Development – Flask, Django, FastAPI integration, connection lifecycles, repository patterns, ORM vs raw SQL, and testing.
- **Module 23:** Mobile Development – Android (Room), React Native (expo‑sqlite), Flutter (sqflite, Drift), offline‑first patterns.

Let's dive in.

---

# Part 7: Programming with SQLite

## Module 21: Python Integration

### The Target

Master the built‑in `sqlite3` module in Python. You will write robust, production‑ready code that uses parameterized queries, connection management, transactions, row factories, and custom extensions. You will also build a complete desktop application (a contact manager) that demonstrates all these concepts.

### The Concept

Python's `sqlite3` module is part of the standard library, so you don't need to install anything. It provides a DB‑API 2.0 compliant interface. Think of it as a **bridge** between your Python objects and the SQLite C library. We'll use it to:

- Create and manage connections (context managers ensure proper cleanup).
- Execute parameterized queries to prevent SQL injection.
- Use transactions for atomic operations.
- Convert rows to Python dictionaries or custom objects with row factories.
- Register Python functions and aggregates that can be called from SQL.
- Handle multithreaded access with care.
- Use async with `aiosqlite` for non‑blocking I/O.

### Hands‑on Lab 21.1: Basic Connection and Queries

We'll create a Python script `contacts_manager.py` that manages a contacts database.

```python
# contacts_manager.py
import sqlite3
import os
from contextlib import contextmanager

DB_PATH = "contacts.db"

# Context manager for database connections
@contextmanager
def get_connection():
    conn = sqlite3.connect(DB_PATH)
    try:
        yield conn
    finally:
        conn.close()

# Initialize the database schema
def init_db():
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                phone TEXT,
                created_at TEXT DEFAULT (datetime('now'))
            )
        """)
        conn.commit()

# Insert a new contact
def add_contact(first_name, last_name, email, phone):
    with get_connection() as conn:
        cursor = conn.cursor()
        # Parameterized query prevents SQL injection
        cursor.execute("""
            INSERT INTO contacts (first_name, last_name, email, phone)
            VALUES (?, ?, ?, ?)
        """, (first_name, last_name, email, phone))
        conn.commit()
        return cursor.lastrowid

# Retrieve all contacts as dictionaries (using row_factory)
def get_all_contacts():
    with get_connection() as conn:
        conn.row_factory = sqlite3.Row  # rows behave like dictionaries
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM contacts ORDER BY last_name, first_name")
        return [dict(row) for row in cursor.fetchall()]

# Update a contact
def update_contact(contact_id, first_name, last_name, email, phone):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE contacts
            SET first_name = ?, last_name = ?, email = ?, phone = ?
            WHERE id = ?
        """, (first_name, last_name, email, phone, contact_id))
        conn.commit()
        return cursor.rowcount > 0  # True if updated

# Delete a contact
def delete_contact(contact_id):
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM contacts WHERE id = ?", (contact_id,))
        conn.commit()
        return cursor.rowcount > 0

# Search contacts by name or email
def search_contacts(query):
    with get_connection() as conn:
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        search_term = f"%{query}%"
        cursor.execute("""
            SELECT * FROM contacts
            WHERE first_name LIKE ? OR last_name LIKE ? OR email LIKE ?
            ORDER BY last_name, first_name
        """, (search_term, search_term, search_term))
        return [dict(row) for row in cursor.fetchall()]

if __name__ == "__main__":
    init_db()
    # Add some sample contacts
    add_contact("Alice", "Smith", "alice@example.com", "555-1234")
    add_contact("Bob", "Johnson", "bob@example.com", "555-5678")
    
    # List all contacts
    print("All contacts:")
    for contact in get_all_contacts():
        print(f"{contact['first_name']} {contact['last_name']} - {contact['email']}")
    
    # Search
    print("\nSearch for 'alice':")
    for contact in search_contacts("alice"):
        print(f"{contact['first_name']} {contact['last_name']}")
```

#### Verification

Run the script:

```bash
python3 contacts_manager.py
```

You should see output with the two contacts. The database file `contacts.db` will be created.

---

### Parameterized Queries and SQL Injection Prevention

Always use parameterized queries (with `?` placeholders) rather than string interpolation. For example, **never** do:

```python
cursor.execute(f"SELECT * FROM contacts WHERE email = '{email}'")  # DANGEROUS!
```

If `email` contains `' OR 1=1; --`, your entire table could be exposed. Use `?` and pass a tuple as the second argument.

---

### Row Factories

We used `conn.row_factory = sqlite3.Row` to get rows that can be accessed by column name. You can also create a custom row factory, e.g., to return dataclass instances.

```python
from dataclasses import dataclass

@dataclass
class Contact:
    id: int
    first_name: str
    last_name: str
    email: str
    phone: str
    created_at: str

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

# Then set: conn.row_factory = dict_factory
```

---

### User‑Defined Functions

You can register Python functions that can be called from SQL using `conn.create_function()`. This is powerful for custom calculations, data cleaning, etc.

```python
def add_emojis(text):
    return f"✨ {text} ✨"

def register_functions(conn):
    conn.create_function("add_emojis", 1, add_emojis)

# Usage in SQL:
# SELECT add_emojis(first_name) FROM contacts;
```

### Custom Aggregates

Define your own aggregate functions (like `SUM`, `AVG` but custom) using `conn.create_aggregate()`.

```python
class ConcatAggregate:
    def __init__(self):
        self.values = []
    def step(self, value):
        self.values.append(value)
    def finalize(self):
        return ', '.join(self.values)

conn.create_aggregate("concat", 1, ConcatAggregate)

# Usage: SELECT concat(first_name) FROM contacts; -- returns comma-separated names
```

### Transactions

We used `conn.commit()` explicitly. If you use `conn` as a context manager, it automatically commits or rolls back on exit. But for explicit control, use `BEGIN`/`COMMIT` or rely on autocommit (default is autocommit off; each `execute` starts a transaction). Best practice: use explicit transactions for multiple statements.

### Thread Safety

The `sqlite3` module is **not** thread‑safe when sharing a connection between threads. Use one connection per thread, or use a connection pool. For simple cases, you can use a lock.

```python
import threading
lock = threading.Lock()

def thread_safe_query(sql, params):
    with lock:
        with sqlite3.connect(DB_PATH) as conn:
            return conn.execute(sql, params).fetchall()
```

Alternatively, use `sqlite3.connect(DB_PATH, check_same_thread=False)` to allow sharing, but this is not recommended for production.

### Async SQLite

For asynchronous applications (e.g., FastAPI, asyncio), use `aiosqlite`. It wraps `sqlite3` with async/await support.

```python
import aiosqlite

async def get_contacts_async():
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = sqlite3.Row
        async with db.execute("SELECT * FROM contacts") as cursor:
            return [dict(row) async for row in cursor]
```

### Hands‑on Lab 21.2: Building a Simple Desktop Application

We'll create a full command‑line interface (CLI) for the contact manager.

```python
# contacts_cli.py
import sqlite3
import sys
from contacts_manager import get_all_contacts, add_contact, search_contacts, update_contact, delete_contact, init_db

def print_contacts(contacts):
    print(f"{'ID':<4} {'First':<12} {'Last':<12} {'Email':<25} {'Phone':<15}")
    print("-" * 70)
    for c in contacts:
        print(f"{c['id']:<4} {c['first_name']:<12} {c['last_name']:<12} {c['email']:<25} {c['phone']:<15}")

def main():
    init_db()
    while True:
        print("\n=== Contact Manager ===")
        print("1. List all contacts")
        print("2. Add a contact")
        print("3. Search contacts")
        print("4. Update a contact")
        print("5. Delete a contact")
        print("0. Exit")
        choice = input("Choose: ").strip()
        
        if choice == "1":
            contacts = get_all_contacts()
            print_contacts(contacts)
        elif choice == "2":
            first = input("First name: ").strip()
            last = input("Last name: ").strip()
            email = input("Email: ").strip()
            phone = input("Phone: ").strip()
            try:
                add_contact(first, last, email, phone)
                print("Contact added.")
            except sqlite3.IntegrityError as e:
                print(f"Error: {e}")
        elif choice == "3":
            query = input("Search term: ").strip()
            contacts = search_contacts(query)
            if contacts:
                print_contacts(contacts)
            else:
                print("No contacts found.")
        elif choice == "4":
            contacts = get_all_contacts()
            print_contacts(contacts)
            cid = input("Enter ID to update: ").strip()
            if not cid.isdigit():
                print("Invalid ID")
                continue
            cid = int(cid)
            # For simplicity, we require all fields
            first = input("First name: ").strip()
            last = input("Last name: ").strip()
            email = input("Email: ").strip()
            phone = input("Phone: ").strip()
            if update_contact(cid, first, last, email, phone):
                print("Contact updated.")
            else:
                print("No contact with that ID.")
        elif choice == "5":
            cid = input("Enter ID to delete: ").strip()
            if not cid.isdigit():
                print("Invalid ID")
                continue
            if delete_contact(int(cid)):
                print("Contact deleted.")
            else:
                print("No contact with that ID.")
        elif choice == "0":
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
```

#### Verification

Run the CLI and test each function. Ensure that integrity errors (like duplicate email) are caught.

---

**[GENERATED: Part 7, Module 21: Python Integration]**

---

## Module 22: Web Development

### The Target

Integrate SQLite into web applications. We will cover three popular frameworks: Flask (microframework), Django (full‑stack), and FastAPI (async). You will learn connection per request, raw SQL vs ORM, repository patterns, and testing with an in‑memory database.

### The Concept

Web applications need a database connection that is managed per request. For SQLite, we can open a connection at the start of a request and close it at the end. This avoids connection leaks and ensures proper transaction boundaries. We will also explore using ORMs (like SQLAlchemy or Django ORM) for higher‑level abstraction, but we'll also show raw SQL for fine control.

### Flask Integration

We'll build a simple REST API for contacts using Flask.

```python
# app_flask.py
from flask import Flask, request, jsonify
import sqlite3
from contextlib import contextmanager

app = Flask(__name__)
DATABASE = "contacts.db"

# Context manager for connection per request
def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(app, 'db', None)
    if db is not None:
        db.close()

@app.route('/contacts', methods=['GET'])
def list_contacts():
    conn = get_db()
    cur = conn.execute("SELECT * FROM contacts ORDER BY last_name, first_name")
    contacts = [dict(row) for row in cur.fetchall()]
    return jsonify(contacts)

@app.route('/contacts', methods=['POST'])
def add_contact():
    data = request.get_json()
    required = ['first_name', 'last_name', 'email']
    if not all(k in data for k in required):
        return jsonify({'error': 'Missing fields'}), 400
    conn = get_db()
    try:
        cur = conn.execute(
            "INSERT INTO contacts (first_name, last_name, email, phone) VALUES (?, ?, ?, ?)",
            (data['first_name'], data['last_name'], data['email'], data.get('phone', ''))
        )
        conn.commit()
        return jsonify({'id': cur.lastrowid}), 201
    except sqlite3.IntegrityError as e:
        return jsonify({'error': str(e)}), 400

@app.route('/contacts/<int:contact_id>', methods=['GET'])
def get_contact(contact_id):
    conn = get_db()
    row = conn.execute("SELECT * FROM contacts WHERE id = ?", (contact_id,)).fetchone()
    if row is None:
        return jsonify({'error': 'Not found'}), 404
    return jsonify(dict(row))

@app.route('/contacts/<int:contact_id>', methods=['PUT'])
def update_contact(contact_id):
    data = request.get_json()
    conn = get_db()
    # First check if exists
    row = conn.execute("SELECT id FROM contacts WHERE id = ?", (contact_id,)).fetchone()
    if row is None:
        return jsonify({'error': 'Not found'}), 404
    try:
        conn.execute(
            "UPDATE contacts SET first_name=?, last_name=?, email=?, phone=? WHERE id=?",
            (data.get('first_name'), data.get('last_name'), data.get('email'), data.get('phone'), contact_id)
        )
        conn.commit()
        return jsonify({'success': True})
    except sqlite3.IntegrityError as e:
        return jsonify({'error': str(e)}), 400

@app.route('/contacts/<int:contact_id>', methods=['DELETE'])
def delete_contact(contact_id):
    conn = get_db()
    cur = conn.execute("DELETE FROM contacts WHERE id = ?", (contact_id,))
    conn.commit()
    if cur.rowcount == 0:
        return jsonify({'error': 'Not found'}), 404
    return jsonify({'success': True})

if __name__ == '__main__':
    app.run(debug=True)
```

#### Verification

Run `python app_flask.py` and use `curl` to test:

```bash
# List contacts
curl http://localhost:5000/contacts

# Add a contact
curl -X POST -H "Content-Type: application/json" -d '{"first_name":"Carol","last_name":"Williams","email":"carol@example.com","phone":"555-9999"}' http://localhost:5000/contacts

# Get one
curl http://localhost:5000/contacts/1
```

### Django Integration

Django uses SQLite as the default database. You set it in `settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
```

Then define models, run migrations, and use the ORM. Here is a minimal `models.py`:

```python
from django.db import models

class Contact(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
```

Django manages connections automatically per request. Use `Contact.objects.all()` etc.

### FastAPI Integration

FastAPI works well with `aiosqlite` for async endpoints.

```python
# app_fastapi.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import aiosqlite
from typing import List, Optional

app = FastAPI()
DATABASE = "contacts.db"

class ContactIn(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone: Optional[str] = None

class ContactOut(ContactIn):
    id: int
    created_at: str

@app.on_event("startup")
async def startup():
    async with aiosqlite.connect(DATABASE) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                email TEXT UNIQUE NOT NULL,
                phone TEXT,
                created_at TEXT DEFAULT (datetime('now'))
            )
        """)
        await db.commit()

@app.get("/contacts", response_model=List[ContactOut])
async def list_contacts():
    async with aiosqlite.connect(DATABASE) as db:
        db.row_factory = sqlite3.Row
        cursor = await db.execute("SELECT * FROM contacts ORDER BY last_name, first_name")
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]

@app.post("/contacts", response_model=ContactOut, status_code=201)
async def add_contact(contact: ContactIn):
    async with aiosqlite.connect(DATABASE) as db:
        try:
            cursor = await db.execute(
                "INSERT INTO contacts (first_name, last_name, email, phone) VALUES (?, ?, ?, ?)",
                (contact.first_name, contact.last_name, contact.email, contact.phone)
            )
            await db.commit()
            # Retrieve the inserted row
            row = await db.execute("SELECT * FROM contacts WHERE id = ?", (cursor.lastrowid,))
            return dict(await row.fetchone())
        except sqlite3.IntegrityError as e:
            raise HTTPException(status_code=400, detail=str(e))
```

### Repository Pattern

To decouple business logic from database details, use a repository class. For example:

```python
class ContactRepository:
    def __init__(self, db_connection):
        self.conn = db_connection
    
    def get_all(self):
        return self.conn.execute("SELECT * FROM contacts").fetchall()
    
    def add(self, contact_data):
        # ...
```

This makes testing easier (you can mock the repository).

### Testing with In‑Memory Databases

For unit tests, use `:memory:` to create a temporary database.

```python
import sqlite3
import pytest

@pytest.fixture
def db_conn():
    conn = sqlite3.connect(':memory:')
    conn.execute("CREATE TABLE contacts (...)")
    yield conn
    conn.close()

def test_add_contact(db_conn):
    # test using the in-memory db
```

### Verification

- Run the Flask/FastAPI app and test endpoints.
- Ensure that connections are closed after each request.
- Test error handling (duplicate email, missing fields).

---

**[GENERATED: Part 7, Module 22: Web Development]**

---

## Module 23: Mobile Development

### The Target

Learn how to use SQLite in mobile applications: Android (with Room), React Native (with expo‑sqlite), and Flutter (with sqflite and Drift). We'll focus on offline‑first architecture, data synchronization, and conflict resolution.

### The Concept

Mobile apps often need local data to work offline. SQLite is the standard choice on both Android and iOS (via the SQLite C library). We'll cover three major frameworks:

- **Android**: Use the Room persistence library for type‑safe SQL access.
- **React Native**: Use `expo‑sqlite` for a simple SQLite API, or `react‑native‑quick‑sqlite` for performance.
- **Flutter**: Use `sqflite` plugin, or the more advanced `Drift` (formerly Moor) for reactive queries.

We'll also discuss offline‑first patterns: local cache, sync with remote server, conflict resolution strategies (last‑write‑wins, version vectors, etc.).

### Android with Room

Room is a wrapper over SQLite that provides compile‑time verification of SQL queries.

**Add dependencies** (in `build.gradle`):

```groovy
dependencies {
    implementation "androidx.room:room-runtime:2.6.0"
    annotationProcessor "androidx.room:room-compiler:2.6.0"
}
```

**Define Entity**:

```java
@Entity(tableName = "contacts")
public class Contact {
    @PrimaryKey(autoGenerate = true)
    public int id;
    @ColumnInfo(name = "first_name")
    public String firstName;
    @ColumnInfo(name = "last_name")
    public String lastName;
    public String email;
    public String phone;
}
```

**Define DAO (Data Access Object)**:

```java
@Dao
public interface ContactDao {
    @Query("SELECT * FROM contacts ORDER BY last_name, first_name")
    List<Contact> getAll();

    @Insert
    long insert(Contact contact);

    @Update
    void update(Contact contact);

    @Delete
    void delete(Contact contact);
}
```

**Define Database**:

```java
@Database(entities = {Contact.class}, version = 1)
public abstract class AppDatabase extends RoomDatabase {
    public abstract ContactDao contactDao();
}
```

**Use in an Activity**:

```java
AppDatabase db = Room.databaseBuilder(getApplicationContext(),
        AppDatabase.class, "contacts.db").build();
ContactDao dao = db.contactDao();
List<Contact> contacts = dao.getAll();
```

**Migrations**: Room supports migration via `addMigrations()`.

**Performance**: Use `@Index` annotations for frequently queried columns.

### React Native with expo‑sqlite

For Expo projects, use `expo-sqlite`.

**Install**:

```bash
expo install expo-sqlite
```

**Usage**:

```javascript
import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabase('contacts.db');

// Create table
db.transaction(tx => {
  tx.executeSql(
    'CREATE TABLE IF NOT EXISTS contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, first_name TEXT, last_name TEXT, email TEXT UNIQUE, phone TEXT)'
  );
});

// Insert
const addContact = (firstName, lastName, email, phone) => {
  db.transaction(tx => {
    tx.executeSql(
      'INSERT INTO contacts (first_name, last_name, email, phone) VALUES (?, ?, ?, ?)',
      [firstName, lastName, email, phone],
      (tx, results) => console.log('Inserted', results.insertId)
    );
  });
};

// Query
const getContacts = () => {
  db.transaction(tx => {
    tx.executeSql(
      'SELECT * FROM contacts',
      [],
      (tx, results) => {
        const len = results.rows.length;
        for (let i = 0; i < len; i++) {
          console.log(results.rows.item(i));
        }
      }
    );
  });
};
```

For performance, consider `react-native-quick-sqlite` which runs in a separate thread.

### Flutter with sqflite

**Add dependency** in `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.3.0
  path_provider: ^2.1.0
```

**Usage**:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, first_name TEXT, last_name TEXT, email TEXT UNIQUE, phone TEXT)'
        );
      },
    );
  }

  Future<int> insertContact(Map<String, dynamic> contact) async {
    Database db = await database;
    return await db.insert('contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    Database db = await database;
    return await db.query('contacts', orderBy: 'last_name, first_name');
  }
}
```

**Drift** (formerly Moor) is a more advanced reactive ORM that generates type‑safe code and supports stream queries.

### Offline‑First Architecture

Key principles:

1. **Local cache**: Store all data locally; the UI reads from the local database.
2. **Sync**: Periodically (or on network change) synchronize with a remote server.
3. **Conflict resolution**: When both local and remote changes conflict, decide a strategy: last‑write‑wins, merge, or manual resolution.
4. **Versioning**: Use a sync token or version vector to track changes.

Example: Use a `sync_status` column (pending, synced) and a `last_modified` timestamp. When a record is updated locally, set sync_status = 'pending'. A background sync job uploads pending changes and marks them synced.

### Verification

- Build a simple mobile app that performs CRUD operations.
- Test offline mode by disabling network and ensuring the app still works.
- Implement a simple sync with a mock server.

You have now integrated SQLite into Python applications, web backends, and mobile platforms. You understand connection management, parameterized queries, custom functions, async patterns, and offline‑first design. These skills allow you to build complete, production‑ready applications that leverage SQLite's power.

In **Part 8: Security & Production Deployment**, we will focus on securing your database (encryption, SQL injection prevention, file permissions), implementing backup and maintenance routines, and deploying SQLite in production environments with monitoring and logging.
