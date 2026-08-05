Welcome to the final part of the series. You have learned everything from SQLite fundamentals to production deployment. Now it's time to put it all together. In this part, we will build multiple real‑world projects that showcase different aspects of SQLite, from simple CRUD to advanced FTS, JSON, and offline‑first sync. We will then culminate in a **capstone project** that integrates all the concepts you've learned: schema design, indexing, transactions, WAL, security, backup, and a full application stack.

---

# Part 9: Real-World Projects & Capstone

This part is divided into two sections:

- **Real‑World Projects** – We will build four complete applications:
  1. **Personal Finance Manager** – Track income and expenses with categories, reports, and budget alerts.
  2. **Point of Sale (POS) System** – Manage products, customers, sales, and inventory.
  3. **Notes & Knowledge Base with Full-Text Search** – Store notes with tags, attachments, and powerful search using FTS5.
  4. **Mobile Expense Tracker** – An offline‑first React Native app that syncs later.

- **Capstone Project** – A comprehensive **Task Management System** that includes:
  - Users, projects, tasks, subtasks, tags, and comments.
  - Full‑text search on task titles and descriptions.
  - JSON metadata for custom fields.
  - Triggers for audit logging and task status transitions.
  - SQLCipher encryption for sensitive data.
  - A REST API built with FastAPI.
  - Backup and maintenance scripts.
  - Comprehensive testing and deployment guide.

Let's dive into the projects.

---

## Project 1: Personal Finance Manager

### The Target

Build a command‑line application to manage personal finances: record transactions (income/expense), categorize them, and generate reports (monthly summary, budget vs actual). The database will use indexes, triggers, and views for reporting.

### The Concept

You have bank accounts, categories (e.g., Food, Rent, Salary), and transactions. Each transaction has an amount, date, description, and category. The application will:
- Add, list, update, and delete transactions.
- Show monthly spending by category.
- Set budgets per category and alert when exceeded.
- Use views for common reports.

### Implementation

We'll use Python with `sqlite3`. Create a database schema:

```sql
-- finance.db
PRAGMA foreign_keys = ON;

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    type TEXT CHECK (type IN ('income', 'expense')) NOT NULL,
    budget REAL CHECK (budget >= 0) DEFAULT 0
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL CHECK (amount != 0),
    date TEXT NOT NULL DEFAULT (date('now')),
    description TEXT,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- Indexes for performance
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_transactions_date ON transactions(date);

-- View for monthly summary
CREATE VIEW monthly_summary AS
SELECT 
    strftime('%Y-%m', date) AS month,
    c.name AS category,
    c.type,
    SUM(amount) AS total
FROM transactions t
JOIN categories c ON t.category_id = c.category_id
GROUP BY month, category_id
ORDER BY month DESC, total DESC;

-- Trigger to check budget: if an expense exceeds budget, log a warning (we'll handle in app)
-- But we can use a trigger to insert into a warnings table (optional)
```

Now the Python code (`finance.py`):

```python
# finance.py
import sqlite3
import datetime
from contextlib import contextmanager

DB_PATH = "finance.db"

@contextmanager
def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    with get_conn() as conn:
        conn.executescript("""
            PRAGMA foreign_keys = ON;
            CREATE TABLE IF NOT EXISTS categories (
                category_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT UNIQUE NOT NULL,
                type TEXT CHECK (type IN ('income', 'expense')) NOT NULL,
                budget REAL DEFAULT 0
            );
            CREATE TABLE IF NOT EXISTS transactions (
                transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
                amount REAL NOT NULL CHECK (amount != 0),
                date TEXT NOT NULL DEFAULT (date('now')),
                description TEXT,
                category_id INTEGER NOT NULL,
                FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
            );
            CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);
            CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
            CREATE VIEW IF NOT EXISTS monthly_summary AS
            SELECT 
                strftime('%Y-%m', date) AS month,
                c.name AS category,
                c.type,
                SUM(amount) AS total
            FROM transactions t
            JOIN categories c ON t.category_id = c.category_id
            GROUP BY month, category_id
            ORDER BY month DESC, total DESC;
        """)
        conn.commit()

def add_category(name, type, budget=0):
    with get_conn() as conn:
        cur = conn.execute(
            "INSERT INTO categories (name, type, budget) VALUES (?, ?, ?)",
            (name, type, budget)
        )
        conn.commit()
        return cur.lastrowid

def add_transaction(amount, category_name, description=None, date=None):
    with get_conn() as conn:
        # Get category_id by name
        cat = conn.execute("SELECT category_id FROM categories WHERE name = ?", (category_name,)).fetchone()
        if not cat:
            raise ValueError(f"Category '{category_name}' does not exist")
        if date is None:
            date = datetime.date.today().isoformat()
        cur = conn.execute(
            "INSERT INTO transactions (amount, date, description, category_id) VALUES (?, ?, ?, ?)",
            (amount, date, description, cat[0])
        )
        conn.commit()
        return cur.lastrowid

def list_transactions(limit=20):
    with get_conn() as conn:
        rows = conn.execute("""
            SELECT t.transaction_id, t.amount, t.date, t.description, c.name AS category, c.type
            FROM transactions t
            JOIN categories c ON t.category_id = c.category_id
            ORDER BY t.date DESC, t.transaction_id DESC
            LIMIT ?
        """, (limit,)).fetchall()
        return [dict(row) for row in rows]

def monthly_report(year, month):
    with get_conn() as conn:
        rows = conn.execute("""
            SELECT 
                c.name AS category,
                c.type,
                SUM(t.amount) AS total,
                c.budget
            FROM transactions t
            JOIN categories c ON t.category_id = c.category_id
            WHERE strftime('%Y', t.date) = ? AND strftime('%m', t.date) = ?
            GROUP BY c.category_id
            ORDER BY c.type, total DESC
        """, (str(year), f"{month:02d}")).fetchall()
        return [dict(row) for row in rows]

def budget_alerts(month, year):
    # Get expenses that exceeded budget
    with get_conn() as conn:
        rows = conn.execute("""
            SELECT 
                c.name,
                SUM(t.amount) AS total,
                c.budget,
                (SUM(t.amount) - c.budget) AS over_by
            FROM transactions t
            JOIN categories c ON t.category_id = c.category_id
            WHERE c.type = 'expense'
              AND strftime('%Y', t.date) = ? AND strftime('%m', t.date) = ?
            GROUP BY c.category_id
            HAVING total > c.budget AND c.budget > 0
        """, (str(year), f"{month:02d}")).fetchall()
        return [dict(row) for row in rows]

def main():
    init_db()
    # Add some sample categories
    for cat, typ, bud in [('Salary', 'income', 0), ('Food', 'expense', 500), ('Rent', 'expense', 1000), ('Entertainment', 'expense', 200)]:
        try:
            add_category(cat, typ, bud)
        except sqlite3.IntegrityError:
            pass  # already exists

    # Sample transactions
    add_transaction(2000, 'Salary', 'January salary', '2025-01-31')
    add_transaction(-150, 'Food', 'Groceries', '2025-01-05')
    add_transaction(-1000, 'Rent', 'January rent', '2025-01-01')
    add_transaction(-50, 'Entertainment', 'Movie', '2025-01-10')

    print("Recent transactions:")
    for t in list_transactions(5):
        print(f"{t['date']} {t['category']:12} {t['amount']:8.2f} {t['description']}")

    print("\nMonthly report for Jan 2025:")
    for r in monthly_report(2025, 1):
        print(f"{r['category']:15} {r['type']:6} {r['total']:8.2f} (budget: {r['budget']:8.2f})")

    alerts = budget_alerts(1, 2025)
    if alerts:
        print("\nBudget alerts:")
        for a in alerts:
            print(f"  {a['name']} over by {a['over_by']:.2f}")
    else:
        print("\nAll within budget!")

if __name__ == "__main__":
    main()
```

#### Verification

Run `python finance.py`. You should see transactions, a report, and possibly a budget alert if you set budgets low. The database file `finance.db` will be created.

---

## Project 2: Point of Sale (POS) System

### The Target

Build a simple POS system with products, customers, sales, and inventory. Track sales, update stock, and generate daily sales reports. This project demonstrates transactions and concurrency (multiple users) and uses WAL mode.

### The Concept

A POS system manages products (SKU, name, price, stock), customers (name, email, phone), and sales (header and line items). Each sale reduces stock. We'll use a transaction to ensure stock is updated atomically. We'll also implement a trigger to prevent negative stock.

### Implementation

Schema:

```sql
-- pos.db
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    sku TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    price REAL NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT
);

CREATE TABLE sales (
    sale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    sale_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    total REAL NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE sale_items (
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price REAL NOT NULL,  -- snapshot
    PRIMARY KEY (sale_id, product_id),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Trigger to reduce stock on sale item insert
CREATE TRIGGER reduce_stock
AFTER INSERT ON sale_items
BEGIN
    UPDATE products SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
    -- Check constraint will prevent negative stock
END;

-- Trigger to prevent sale if product out of stock (before insert)
CREATE TRIGGER check_stock
BEFORE INSERT ON sale_items
BEGIN
    SELECT CASE
        WHEN (SELECT stock FROM products WHERE product_id = NEW.product_id) < NEW.quantity
        THEN RAISE(ABORT, 'Insufficient stock')
    END;
END;

-- View for daily sales report
CREATE VIEW daily_sales AS
SELECT date(sale_date) AS day, COUNT(*) AS num_sales, SUM(total) AS total_revenue
FROM sales
GROUP BY day;
```

Python code (`pos.py`):

```python
# pos.py
import sqlite3
from contextlib import contextmanager

DB_PATH = "pos.db"

@contextmanager
def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    # Set PRAGMA for production
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    with get_conn() as conn:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS products (
                product_id INTEGER PRIMARY KEY AUTOINCREMENT,
                sku TEXT UNIQUE NOT NULL,
                name TEXT NOT NULL,
                price REAL NOT NULL CHECK (price >= 0),
                stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0)
            );
            CREATE TABLE IF NOT EXISTS customers (
                customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT UNIQUE,
                phone TEXT
            );
            CREATE TABLE IF NOT EXISTS sales (
                sale_id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER,
                sale_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
                total REAL NOT NULL,
                FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
            );
            CREATE TABLE IF NOT EXISTS sale_items (
                sale_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                quantity INTEGER NOT NULL CHECK (quantity > 0),
                unit_price REAL NOT NULL,
                PRIMARY KEY (sale_id, product_id),
                FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
                FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
            );
            CREATE TRIGGER IF NOT EXISTS reduce_stock
            AFTER INSERT ON sale_items
            BEGIN
                UPDATE products SET stock = stock - NEW.quantity
                WHERE product_id = NEW.product_id;
            END;
            CREATE TRIGGER IF NOT EXISTS check_stock
            BEFORE INSERT ON sale_items
            BEGIN
                SELECT CASE
                    WHEN (SELECT stock FROM products WHERE product_id = NEW.product_id) < NEW.quantity
                    THEN RAISE(ABORT, 'Insufficient stock')
                END;
            END;
            CREATE VIEW IF NOT EXISTS daily_sales AS
            SELECT date(sale_date) AS day, COUNT(*) AS num_sales, SUM(total) AS total_revenue
            FROM sales
            GROUP BY day;
        """)
        conn.commit()

def add_product(sku, name, price, stock=0):
    with get_conn() as conn:
        cur = conn.execute(
            "INSERT INTO products (sku, name, price, stock) VALUES (?, ?, ?, ?)",
            (sku, name, price, stock)
        )
        conn.commit()
        return cur.lastrowid

def add_customer(name, email=None, phone=None):
    with get_conn() as conn:
        cur = conn.execute(
            "INSERT INTO customers (name, email, phone) VALUES (?, ?, ?)",
            (name, email, phone)
        )
        conn.commit()
        return cur.lastrowid

def create_sale(customer_id, items):  # items: list of (product_id, quantity)
    with get_conn() as conn:
        # Begin transaction
        conn.execute("BEGIN")
        try:
            # Compute total
            total = 0
            for pid, qty in items:
                # Get product price (use current price)
                prod = conn.execute("SELECT price FROM products WHERE product_id = ?", (pid,)).fetchone()
                if not prod:
                    raise ValueError(f"Product {pid} not found")
                total += prod[0] * qty
            # Insert sale
            cur = conn.execute(
                "INSERT INTO sales (customer_id, total) VALUES (?, ?)",
                (customer_id, total)
            )
            sale_id = cur.lastrowid
            # Insert sale items
            for pid, qty in items:
                price = conn.execute("SELECT price FROM products WHERE product_id = ?", (pid,)).fetchone()[0]
                conn.execute(
                    "INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)",
                    (sale_id, pid, qty, price)
                )
            conn.commit()
            return sale_id
        except Exception as e:
            conn.rollback()
            raise e

def daily_report():
    with get_conn() as conn:
        rows = conn.execute("SELECT * FROM daily_sales ORDER BY day DESC").fetchall()
        return [dict(row) for row in rows]

def main():
    init_db()
    # Add sample products
    add_product("P001", "Laptop", 999.99, 10)
    add_product("P002", "Mouse", 25.00, 50)
    add_product("P003", "Keyboard", 45.00, 20)
    # Add customer
    cust_id = add_customer("Alice", "alice@pos.com", "555-1234")
    # Make a sale: laptop and mouse
    sale_id = create_sale(cust_id, [(1, 1), (2, 2)])
    print(f"Sale {sale_id} created.")
    # Check stock
    with get_conn() as conn:
        for row in conn.execute("SELECT name, stock FROM products").fetchall():
            print(f"{row['name']}: {row['stock']}")
    # Daily report
    print("Daily sales report:")
    for r in daily_report():
        print(f"{r['day']}: {r['num_sales']} sales, ${r['total_revenue']:.2f}")

if __name__ == "__main__":
    main()
```

#### Verification

Run `python pos.py`. It should create a sale and reduce stock accordingly. Try to sell more than stock; the trigger should abort with an error.

---

## Project 3: Notes & Knowledge Base with Full-Text Search

### The Target

Build a note‑taking application with tags, attachments, and powerful full‑text search using FTS5. The app will support hierarchical tags (categories) and searching across note titles and content.

### The Concept

Notes have a title, content, creation date, and tags (many‑to‑many). We'll use FTS5 for fast search. Tags can have parent tags for organization (optional). We'll implement triggers to keep the FTS table in sync with the main notes table.

### Implementation

Schema:

```sql
-- notes.db
PRAGMA foreign_keys = ON;

CREATE TABLE notes (
    note_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    updated_at TEXT DEFAULT (datetime('now', 'localtime'))
);

-- Tags
CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    parent_tag_id INTEGER,
    FOREIGN KEY (parent_tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Junction
CREATE TABLE note_tags (
    note_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (note_id, tag_id),
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- FTS5 virtual table
CREATE VIRTUAL TABLE notes_fts USING fts5(
    title,
    content,
    content=notes   -- external content
);

-- Triggers to sync FTS
CREATE TRIGGER notes_ai AFTER INSERT ON notes
BEGIN
    INSERT INTO notes_fts(rowid, title, content) VALUES (NEW.note_id, NEW.title, NEW.content);
END;

CREATE TRIGGER notes_au AFTER UPDATE ON notes
BEGIN
    UPDATE notes_fts SET title = NEW.title, content = NEW.content WHERE rowid = NEW.note_id;
END;

CREATE TRIGGER notes_ad AFTER DELETE ON notes
BEGIN
    DELETE FROM notes_fts WHERE rowid = OLD.note_id;
END;
```

Python code (`notes.py`):

```python
# notes.py
import sqlite3
from contextlib import contextmanager

DB_PATH = "notes.db"

@contextmanager
def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    with get_conn() as conn:
        conn.executescript("""
            PRAGMA foreign_keys = ON;
            CREATE TABLE IF NOT EXISTS notes (
                note_id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                content TEXT,
                created_at TEXT DEFAULT (datetime('now', 'localtime')),
                updated_at TEXT DEFAULT (datetime('now', 'localtime'))
            );
            CREATE TABLE IF NOT EXISTS tags (
                tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT UNIQUE NOT NULL,
                parent_tag_id INTEGER,
                FOREIGN KEY (parent_tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
            );
            CREATE TABLE IF NOT EXISTS note_tags (
                note_id INTEGER NOT NULL,
                tag_id INTEGER NOT NULL,
                PRIMARY KEY (note_id, tag_id),
                FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
                FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
            );
            CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
                title,
                content,
                content=notes
            );
            CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes
            BEGIN
                INSERT INTO notes_fts(rowid, title, content) VALUES (NEW.note_id, NEW.title, NEW.content);
            END;
            CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes
            BEGIN
                UPDATE notes_fts SET title = NEW.title, content = NEW.content WHERE rowid = NEW.note_id;
            END;
            CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes
            BEGIN
                DELETE FROM notes_fts WHERE rowid = OLD.note_id;
            END;
        """)
        conn.commit()

def create_note(title, content, tags=None):
    with get_conn() as conn:
        cur = conn.execute(
            "INSERT INTO notes (title, content) VALUES (?, ?)",
            (title, content)
        )
        note_id = cur.lastrowid
        if tags:
            for tag_name in tags:
                # Get or create tag
                tag = conn.execute("SELECT tag_id FROM tags WHERE name = ?", (tag_name,)).fetchone()
                if not tag:
                    cur = conn.execute("INSERT INTO tags (name) VALUES (?)", (tag_name,))
                    tag_id = cur.lastrowid
                else:
                    tag_id = tag[0]
                conn.execute(
                    "INSERT INTO note_tags (note_id, tag_id) VALUES (?, ?)",
                    (note_id, tag_id)
                )
        conn.commit()
        return note_id

def search_notes(query):
    with get_conn() as conn:
        rows = conn.execute("""
            SELECT n.note_id, n.title, n.content, n.created_at,
                   snippet(notes_fts, 1, '<b>', '</b>', '...', 20) AS snippet
            FROM notes n
            JOIN notes_fts ON n.note_id = notes_fts.rowid
            WHERE notes_fts MATCH ?
            ORDER BY bm25(notes_fts)
        """, (query,)).fetchall()
        return [dict(row) for row in rows]

def list_notes(limit=20):
    with get_conn() as conn:
        rows = conn.execute("""
            SELECT note_id, title, created_at
            FROM notes
            ORDER BY created_at DESC
            LIMIT ?
        """, (limit,)).fetchall()
        return [dict(row) for row in rows]

def add_tag_to_note(note_id, tag_name):
    with get_conn() as conn:
        tag = conn.execute("SELECT tag_id FROM tags WHERE name = ?", (tag_name,)).fetchone()
        if not tag:
            cur = conn.execute("INSERT INTO tags (name) VALUES (?)", (tag_name,))
            tag_id = cur.lastrowid
        else:
            tag_id = tag[0]
        conn.execute(
            "INSERT OR IGNORE INTO note_tags (note_id, tag_id) VALUES (?, ?)",
            (note_id, tag_id)
        )
        conn.commit()

def main():
    init_db()
    # Create some notes
    create_note("Getting Started with SQLite", "SQLite is great for embedded databases.", ["sqlite", "tutorial"])
    create_note("Advanced FTS", "Use FTS5 for full-text search with ranking.", ["sqlite", "fts", "search"])
    create_note("Notes App", "Build a notes app with tags and search.", ["project", "python"])

    print("All notes:")
    for note in list_notes(5):
        print(f"{note['note_id']}: {note['title']} ({note['created_at']})")

    print("\nSearch for 'sqlite':")
    for res in search_notes("sqlite"):
        print(f"{res['title']}: {res['snippet']}")

if __name__ == "__main__":
    main()
```

#### Verification

Run `python notes.py`. The search should return notes containing "sqlite". Verify the snippets. Ensure the FTS table is automatically updated when you insert/update/delete notes.

---

## Project 4: Mobile Expense Tracker (React Native)

We'll provide a high‑level implementation for a React Native app using `expo-sqlite`. Since this is a tutorial, we'll focus on the database layer and the offline‑first pattern.

### The Target

Build an expense tracking mobile app that works offline. It stores expenses locally and syncs with a remote server when online. The app uses SQLite for local storage.

### Implementation (Database Layer)

We'll create a database schema similar to the Finance Manager, but with additional columns for sync status and a `last_modified` timestamp.

```sql
-- mobile_expenses.db
CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    description TEXT,
    category TEXT,
    date TEXT NOT NULL,
    -- sync fields
    sync_status TEXT DEFAULT 'pending',  -- 'pending', 'synced'
    last_modified TEXT DEFAULT (datetime('now')),
    remote_id INTEGER  -- id from server
);
CREATE INDEX idx_sync_status ON expenses(sync_status);
```

In the React Native code (using `expo-sqlite`), we have functions:

```javascript
import * as SQLite from 'expo-sqlite';

const db = SQLite.openDatabase('expenses.db');

// Initialize
const initDB = () => {
  db.transaction(tx => {
    tx.executeSql(
      `CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        description TEXT,
        category TEXT,
        date TEXT,
        sync_status TEXT DEFAULT 'pending',
        last_modified TEXT DEFAULT (datetime('now')),
        remote_id INTEGER
      )`
    );
    tx.executeSql('CREATE INDEX IF NOT EXISTS idx_sync_status ON expenses(sync_status)');
  });
};

// Add expense locally
const addExpense = (amount, description, category, date) => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        `INSERT INTO expenses (amount, description, category, date, sync_status) VALUES (?, ?, ?, ?, 'pending')`,
        [amount, description, category, date],
        (_, results) => resolve(results.insertId),
        (_, error) => reject(error)
      );
    });
  });
};

// Get expenses, optionally filter by date
const getExpenses = () => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        `SELECT * FROM expenses ORDER BY date DESC`,
        [],
        (_, results) => {
          const rows = [];
          for (let i = 0; i < results.rows.length; i++) {
            rows.push(results.rows.item(i));
          }
          resolve(rows);
        },
        (_, error) => reject(error)
      );
    });
  });
};

// Sync: fetch pending expenses and send to server; on success update sync_status
const syncExpenses = async (apiUrl) => {
  const pending = await getPendingExpenses();
  for (let exp of pending) {
    try {
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(exp)
      });
      if (response.ok) {
        const result = await response.json();
        // Update local record with remote_id and sync_status
        await updateSyncStatus(exp.id, result.remote_id);
      }
    } catch (e) {
      console.error('Sync failed for expense', exp.id);
    }
  }
};

const getPendingExpenses = () => {
  return new Promise((resolve, reject) => {
    db.transaction(tx => {
      tx.executeSql(
        `SELECT * FROM expenses WHERE sync_status = 'pending'`,
        [],
        (_, results) => {
          const rows = [];
          for (let i = 0; i < results.rows.length; i++) {
            rows.push(results.rows.item(i));
          }
          resolve(rows);
        }
      );
    });
  });
};

const updateSyncStatus = (id, remoteId) => {
  db.transaction(tx => {
    tx.executeSql(
      `UPDATE expenses SET sync_status = 'synced', remote_id = ? WHERE id = ?`,
      [remoteId, id]
    );
  });
};
```

#### Verification

In a React Native app, you would call these functions. The sync function can be triggered when the network is available (using `NetInfo`). The offline‑first pattern ensures the app remains usable without internet.

---

## Capstone Project: Task Management System

Now we bring everything together in a comprehensive application. We'll build a **Task Management System** with a FastAPI backend, using SQLite with all advanced features.

### Requirements

- **Users**: Register, login (JWT authentication).
- **Projects**: Each project has a name, description, and owner.
- **Tasks**: Each task belongs to a project, has a title, description, status (TODO, IN_PROGRESS, DONE), priority (LOW, MEDIUM, HIGH), due date, and assignee (user).
- **Subtasks**: Tasks can have subtasks (hierarchical).
- **Tags**: Flexible tagging (many‑to‑many).
- **Comments**: Users can comment on tasks.
- **Search**: Full‑text search on task title and description (FTS5).
- **Audit Log**: Track changes to tasks (status, assignment, etc.) using triggers.
- **JSON metadata**: Each task can have extra custom fields stored as JSON.
- **Encryption**: User passwords are hashed; sensitive fields (e.g., personal notes) can be encrypted with SQLCipher (optional).
- **Backup**: Automated backup script.
- **Indexes**: Proper indexes on foreign keys, status, due_date.
- **WAL mode**: Enabled.
- **Reporting**: Views for project progress, task distribution, etc.

### Schema Design

```sql
-- task_manager.db
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- Users
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,  -- bcrypt hashed
    email TEXT UNIQUE NOT NULL,
    created_at TEXT DEFAULT (datetime('now'))
);

-- Projects
CREATE TABLE projects (
    project_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    owner_id INTEGER NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Tags
CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

-- Tasks
CREATE TABLE tasks (
    task_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'TODO' CHECK (status IN ('TODO', 'IN_PROGRESS', 'DONE')),
    priority TEXT DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
    due_date TEXT,
    assignee_id INTEGER,
    parent_task_id INTEGER,  -- for subtasks
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    metadata TEXT,  -- JSON for custom fields
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (assignee_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (parent_task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);

-- Task-Tag junction
CREATE TABLE task_tags (
    task_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (task_id, tag_id),
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Comments
CREATE TABLE comments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Audit Log (trigger-based)
CREATE TABLE audit_log (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT,
    action TEXT,
    row_id INTEGER,
    old_values TEXT,  -- JSON
    new_values TEXT,
    user_id INTEGER,
    changed_at TEXT DEFAULT (datetime('now'))
);

-- FTS5 for tasks (external content)
CREATE VIRTUAL TABLE tasks_fts USING fts5(
    title,
    description,
    content=tasks
);

-- Indexes
CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_assignee ON tasks(assignee_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_comments_task ON comments(task_id);
CREATE INDEX idx_task_tags_task ON task_tags(task_id);

-- Triggers for audit logging (simplified)
CREATE TRIGGER tasks_audit_update AFTER UPDATE ON tasks
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_values, new_values)
    VALUES ('tasks', 'UPDATE', OLD.task_id,
            json_object('title', OLD.title, 'status', OLD.status, 'assignee_id', OLD.assignee_id),
            json_object('title', NEW.title, 'status', NEW.status, 'assignee_id', NEW.assignee_id));
END;

-- Triggers for FTS sync
CREATE TRIGGER tasks_ai AFTER INSERT ON tasks
BEGIN
    INSERT INTO tasks_fts(rowid, title, description) VALUES (NEW.task_id, NEW.title, NEW.description);
END;

CREATE TRIGGER tasks_au AFTER UPDATE ON tasks
BEGIN
    UPDATE tasks_fts SET title = NEW.title, description = NEW.description WHERE rowid = NEW.task_id;
END;

CREATE TRIGGER tasks_ad AFTER DELETE ON tasks
BEGIN
    DELETE FROM tasks_fts WHERE rowid = OLD.task_id;
END;

-- Views for reporting
CREATE VIEW task_summary AS
SELECT 
    p.name AS project,
    t.status,
    COUNT(*) AS task_count
FROM tasks t
JOIN projects p ON t.project_id = p.project_id
GROUP BY p.project_id, t.status;

CREATE VIEW user_task_load AS
SELECT 
    u.username,
    COUNT(t.task_id) AS active_tasks
FROM users u
LEFT JOIN tasks t ON u.user_id = t.assignee_id AND t.status != 'DONE'
GROUP BY u.user_id;
```

### FastAPI Implementation

We'll provide the core endpoints. Full code would be extensive; we'll show the database layer and key endpoints.

**Project structure:**

```
task_manager/
├── app/
│   ├── main.py
│   ├── database.py
│   ├── models.py (Pydantic)
│   ├── crud.py
│   ├── auth.py
│   └── schemas.py
├── backups/
└── maintenance.py
```

**database.py** (connection, PRAGMA, context manager):

```python
# database.py
import sqlite3
from contextlib import contextmanager
import os

DB_PATH = os.environ.get("DB_PATH", "task_manager.db")

@contextmanager
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA foreign_keys = ON")
    conn.execute("PRAGMA busy_timeout = 5000")
    try:
        yield conn
    finally:
        conn.close()

def init_db():
    with get_db() as conn:
        conn.executescript(open("schema.sql").read())  # schema as above
```

**crud.py** (CRUD operations with parameterized queries, error handling):

```python
# crud.py
import sqlite3
from app.database import get_db
from app.schemas import TaskCreate, TaskUpdate
import json

def create_task(task: TaskCreate, assignee_id=None):
    with get_db() as conn:
        cur = conn.execute(
            """INSERT INTO tasks (project_id, title, description, status, priority, due_date, assignee_id, parent_task_id, metadata)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (task.project_id, task.title, task.description, task.status, task.priority,
             task.due_date, assignee_id, task.parent_task_id, json.dumps(task.metadata) if task.metadata else None)
        )
        conn.commit()
        return cur.lastrowid

def get_task(task_id):
    with get_db() as conn:
        row = conn.execute("SELECT * FROM tasks WHERE task_id = ?", (task_id,)).fetchone()
        return dict(row) if row else None

def update_task(task_id, task_update: TaskUpdate):
    with get_db() as conn:
        # Build dynamic update
        fields = []
        values = []
        for key, value in task_update.dict(exclude_unset=True).items():
            if key == 'metadata' and value is not None:
                value = json.dumps(value)
            fields.append(f"{key} = ?")
            values.append(value)
        if not fields:
            return False
        values.append(task_id)
        sql = f"UPDATE tasks SET {', '.join(fields)}, updated_at = datetime('now') WHERE task_id = ?"
        cur = conn.execute(sql, values)
        conn.commit()
        return cur.rowcount > 0

def search_tasks(query):
    with get_db() as conn:
        rows = conn.execute("""
            SELECT t.*, snippet(tasks_fts, 1, '<b>', '</b>', '...', 30) AS snippet
            FROM tasks t
            JOIN tasks_fts ON t.task_id = tasks_fts.rowid
            WHERE tasks_fts MATCH ?
            ORDER BY bm25(tasks_fts)
        """, (query,)).fetchall()
        return [dict(row) for row in rows]

def add_comment(task_id, user_id, content):
    with get_db() as conn:
        cur = conn.execute(
            "INSERT INTO comments (task_id, user_id, content) VALUES (?, ?, ?)",
            (task_id, user_id, content)
        )
        conn.commit()
        return cur.lastrowid

def get_task_comments(task_id):
    with get_db() as conn:
        rows = conn.execute("""
            SELECT c.*, u.username
            FROM comments c
            JOIN users u ON c.user_id = u.user_id
            WHERE c.task_id = ?
            ORDER BY c.created_at
        """, (task_id,)).fetchall()
        return [dict(row) for row in rows]
```

**Auth** (JWT with `python-jose`):

```python
# auth.py
from jose import JWTError, jwt
from datetime import datetime, timedelta
import bcrypt

SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def verify_password(password, hashed):
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_token(token):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        return None
```

**main.py** (FastAPI app with endpoints):

We'll include endpoints for:

- `/auth/register`, `/auth/login`
- `/projects` (CRUD)
- `/tasks` (CRUD, search, comments)
- `/reports/task_summary`, `/reports/user_load`
- `/health`

Full code would be long; we'll outline. Key endpoints:

```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from app import crud, auth, schemas, database

app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = auth.decode_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")
    return payload.get("sub")  # username

@app.post("/auth/register")
def register(user: schemas.UserCreate):
    # Insert user into DB with hashed password
    ...

@app.post("/auth/login")
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Verify username/password, return token
    ...

@app.get("/tasks")
def list_tasks(project_id: int = None, status: str = None, current_user: str = Depends(get_current_user)):
    # Use current_user for permissions if needed
    with database.get_db() as conn:
        query = "SELECT * FROM tasks"
        params = []
        if project_id:
            query += " WHERE project_id = ?"
            params.append(project_id)
        if status:
            query += " AND status = ?" if project_id else " WHERE status = ?"
            params.append(status)
        rows = conn.execute(query, params).fetchall()
        return [dict(row) for row in rows]

@app.post("/tasks")
def create_task(task: schemas.TaskCreate, current_user: str = Depends(get_current_user)):
    # Get user_id from username
    with database.get_db() as conn:
        user = conn.execute("SELECT user_id FROM users WHERE username = ?", (current_user,)).fetchone()
        if not user:
            raise HTTPException(404, "User not found")
        task_id = crud.create_task(task, assignee_id=user[0])  # or from request
        return {"id": task_id}

@app.get("/tasks/search")
def search(q: str, current_user: str = Depends(get_current_user)):
    return crud.search_tasks(q)

@app.get("/tasks/{task_id}/comments")
def get_comments(task_id: int, current_user: str = Depends(get_current_user)):
    return crud.get_task_comments(task_id)

@app.post("/tasks/{task_id}/comments")
def add_comment(task_id: int, comment: schemas.CommentCreate, current_user: str = Depends(get_current_user)):
    # get user_id
    ...
    crud.add_comment(task_id, user_id, comment.content)
    return {"status": "ok"}

@app.get("/reports/task_summary")
def task_summary(current_user: str = Depends(get_current_user)):
    with database.get_db() as conn:
        rows = conn.execute("SELECT * FROM task_summary").fetchall()
        return [dict(row) for row in rows]
```

**Maintenance script** (backup, integrity, vacuum) similar to Module 25 but extended.

### Deployment

We'll create a `Dockerfile` to run the FastAPI app with SQLite:

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
ENV DB_PATH=/data/task_manager.db
RUN mkdir -p /data
VOLUME /data
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

And a `docker-compose.yml` for persistent volume and backup cron.

### Verification

- Run `python -m app.main` (with a proper entry point) and test endpoints with `curl` or Postman.
- Use the search endpoint to confirm FTS works.
- Check audit log after updates.
- Verify WAL mode is active: `PRAGMA journal_mode`.
- Run integrity check and backups.

### Capstone Summary

This project integrates:
- Complex schema with relationships, constraints, indexes.
- FTS5 for search.
- JSON for flexible metadata.
- Triggers for audit and FTS sync.
- Security with JWT and password hashing.
- Production settings (WAL, busy_timeout, etc.).
- Backup and maintenance.
- Containerization.

You now have a complete blueprint to build and deploy a production‑grade SQLite application.

## End of Part 9 and Series

Congratulations! You have completed the entire series. You have gone from absolute beginner to a confident SQLite practitioner capable of designing, optimizing, securing, and deploying production‑grade database systems. You have built multiple real‑world applications and a comprehensive capstone project.

Throughout this journey, you have:
- Understood SQLite's internal architecture and storage.
- Mastered SQL programming, joins, aggregations, and window functions.
- Designed efficient, normalized schemas.
- Optimized performance with indexes and query planning.
- Managed transactions and concurrency with WAL.
- Leveraged advanced features: JSON, FTS5, virtual tables, triggers, views.
- Integrated SQLite into Python, web, and mobile applications.
- Secured databases with encryption and parameterized queries.
- Implemented robust backup, maintenance, and deployment strategies.

You are now ready to embed SQLite in any project with confidence. Keep exploring, keep building, and remember: the best way to master a tool is to use it in your own creations.
