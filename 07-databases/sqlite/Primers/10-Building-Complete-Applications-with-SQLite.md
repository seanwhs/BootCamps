# Real‑World Projects and Capstone Primer 10: Building Complete Applications with SQLite

You've learned the theory, practiced the skills, and explored advanced features. Now it's time to **build**. This primer walks you through three complete real‑world projects and a comprehensive capstone that ties everything together. Each project grows in complexity, and by the end, you'll have a portfolio of production‑ready SQLite applications.

---

## Project 1: Personal Finance Manager

### Description
A command‑line application to track income and expenses, with categories, budgets, and reports.

### Schema
```sql
-- finance.db
PRAGMA foreign_keys = ON;

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    type TEXT CHECK (type IN ('income', 'expense')) NOT NULL,
    budget REAL DEFAULT 0
);

CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL CHECK (amount != 0),
    date TEXT NOT NULL DEFAULT (date('now')),
    description TEXT,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

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
```

### Key Features
- **Add transactions** with categories.
- **Set budgets** per category.
- **Monthly reports** showing income vs. expenses.
- **Budget alerts** when spending exceeds limits.

### Python Implementation (Core Functions)
```python
import sqlite3
from contextlib import contextmanager

@contextmanager
def get_conn():
    conn = sqlite3.connect('finance.db')
    conn.row_factory = sqlite3.Row
    try:
        yield conn
    finally:
        conn.close()

def add_transaction(amount, category_name, description=None, date=None):
    with get_conn() as conn:
        cat = conn.execute("SELECT category_id FROM categories WHERE name = ?", (category_name,)).fetchone()
        if not cat:
            raise ValueError(f"Category '{category_name}' not found")
        if date is None:
            date = datetime.date.today().isoformat()
        cur = conn.execute(
            "INSERT INTO transactions (amount, date, description, category_id) VALUES (?, ?, ?, ?)",
            (amount, date, description, cat[0])
        )
        conn.commit()
        return cur.lastrowid

def monthly_report(year, month):
    with get_conn() as conn:
        rows = conn.execute("""
            SELECT c.name, c.type, SUM(t.amount) AS total, c.budget
            FROM transactions t
            JOIN categories c ON t.category_id = c.category_id
            WHERE strftime('%Y', t.date) = ? AND strftime('%m', t.date) = ?
            GROUP BY c.category_id
        """, (str(year), f"{month:02d}")).fetchall()
        return [dict(row) for row in rows]
```

### Verification
Run the script, add some transactions, and generate a report. Check that budgets trigger alerts.

---

## Project 2: Point of Sale (POS) System

### Description
A simple POS system with products, customers, sales, and inventory tracking. Demonstrates transactions and stock management.

### Schema
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
    unit_price REAL NOT NULL,
    PRIMARY KEY (sale_id, product_id),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Trigger to reduce stock on sale
CREATE TRIGGER reduce_stock
AFTER INSERT ON sale_items
BEGIN
    UPDATE products SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END;

-- Trigger to prevent sale if insufficient stock
CREATE TRIGGER check_stock
BEFORE INSERT ON sale_items
BEGIN
    SELECT CASE
        WHEN (SELECT stock FROM products WHERE product_id = NEW.product_id) < NEW.quantity
        THEN RAISE(ABORT, 'Insufficient stock')
    END;
END;
```

### Key Features
- **Add products** with stock quantity.
- **Create a sale** with multiple items.
- **Stock reduction** via triggers.
- **Daily sales report** view.

### Python Implementation (Create Sale)
```python
def create_sale(customer_id, items):  # items: [(product_id, quantity), ...]
    with get_conn() as conn:
        conn.execute("BEGIN")
        try:
            total = 0
            for pid, qty in items:
                prod = conn.execute("SELECT price FROM products WHERE product_id = ?", (pid,)).fetchone()
                if not prod:
                    raise ValueError(f"Product {pid} not found")
                total += prod[0] * qty
            cur = conn.execute("INSERT INTO sales (customer_id, total) VALUES (?, ?)", (customer_id, total))
            sale_id = cur.lastrowid
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
```

### Verification
Create a sale, verify stock is reduced, and check the daily sales report view. Try selling more than stock—the trigger should abort.

---

## Project 3: Knowledge Base with Full‑Text Search

### Description
A note‑taking application with tags, attachments (via BLOB), and powerful full‑text search using FTS5.

### Schema
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

CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

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
    content=notes
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

### Key Features
- **Create notes** with title and content.
- **Tag notes** (many‑to‑many).
- **Full‑text search** with ranking and snippets.
- **Automatic FTS sync** via triggers.

### Python Implementation (Search)
```python
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
```

### Verification
Create several notes, add tags, and search for keywords. Check that snippets and ranking work correctly.

---

## Capstone Project: Task Management System

### Description
A full‑featured web application with users, projects, tasks, subtasks, tags, comments, search, audit logging, and JSON metadata—all powered by SQLite with a FastAPI backend.

### Schema
```sql
-- task_manager.db
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- Users
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
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

-- Tasks (with JSON metadata)
CREATE TABLE tasks (
    task_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'TODO' CHECK (status IN ('TODO', 'IN_PROGRESS', 'DONE')),
    priority TEXT DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
    due_date TEXT,
    assignee_id INTEGER,
    parent_task_id INTEGER,
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

-- Audit Log
CREATE TABLE audit_log (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT,
    action TEXT,
    row_id INTEGER,
    old_values TEXT,
    new_values TEXT,
    user_id INTEGER,
    changed_at TEXT DEFAULT (datetime('now'))
);

-- FTS5 for tasks
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

-- Audit triggers (simplified)
CREATE TRIGGER tasks_audit_update AFTER UPDATE ON tasks
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_values, new_values)
    VALUES ('tasks', 'UPDATE', OLD.task_id,
            json_object('title', OLD.title, 'status', OLD.status),
            json_object('title', NEW.title, 'status', NEW.status));
END;

-- FTS sync triggers
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
SELECT p.name AS project, t.status, COUNT(*) AS task_count
FROM tasks t
JOIN projects p ON t.project_id = p.project_id
GROUP BY p.project_id, t.status;
```

### FastAPI Backend (Key Endpoints)

```python
from fastapi import FastAPI, Depends, HTTPException
import sqlite3
from pydantic import BaseModel
import os
import bcrypt
import jwt

app = FastAPI()

# Database context manager
def get_db():
    conn = sqlite3.connect('task_manager.db')
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA foreign_keys = ON")
    return conn

# User registration
@app.post("/auth/register")
def register(username: str, password: str, email: str):
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    with get_db() as conn:
        try:
            conn.execute(
                "INSERT INTO users (username, password_hash, email) VALUES (?, ?, ?)",
                (username, hashed.decode('utf-8'), email)
            )
            conn.commit()
            return {"status": "ok"}
        except sqlite3.IntegrityError:
            raise HTTPException(400, "Username or email already exists")

# Task CRUD
@app.post("/tasks")
def create_task(project_id: int, title: str, description: str, assignee_id: int = None):
    with get_db() as conn:
        cur = conn.execute(
            "INSERT INTO tasks (project_id, title, description, assignee_id) VALUES (?, ?, ?, ?)",
            (project_id, title, description, assignee_id)
        )
        conn.commit()
        return {"id": cur.lastrowid}

@app.get("/tasks/search")
def search_tasks(q: str):
    with get_db() as conn:
        rows = conn.execute("""
            SELECT t.*, snippet(tasks_fts, 1, '<b>', '</b>', '...', 30) AS snippet
            FROM tasks t
            JOIN tasks_fts ON t.task_id = tasks_fts.rowid
            WHERE tasks_fts MATCH ?
            ORDER BY bm25(tasks_fts)
        """, (q,)).fetchall()
        return [dict(row) for row in rows]
```

### Deployment (Docker)

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
ENV DB_PATH=/data/task_manager.db
RUN mkdir -p /data
VOLUME /data
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Production Checklist for Capstone

- [ ] **WAL mode enabled**
- [ ] **Synchronous = NORMAL**
- [ ] **Busy timeout = 5000**
- [ ] **Foreign keys enabled**
- [ ] **All foreign keys indexed**
- [ ] **FTS5 synced via triggers**
- [ ] **Audit logging active**
- [ ] **JSON metadata stored**
- [ ] **Parameterized queries (SQL injection safe)**
- [ ] **Password hashing (bcrypt)**
- [ ] **JWT authentication (optional)**
- [ ] **Backup automation**
- [ ] **Integrity checks scheduled**
- [ ] **Containerised with persistent volume**

---

## Summary: What You've Built

| Project | Features Demonstrated |
|---------|----------------------|
| **Finance Manager** | CRUD, aggregations, views, indexes, budget alerts |
| **POS System** | Transactions, triggers, stock management, foreign keys |
| **Knowledge Base** | FTS5, snippets, tagging, triggers for sync |
| **Task Management (Capstone)** | All of the above + users, JSON, audit logging, REST API, deployment |

---

## Next Steps

- **Extend the projects** – Add new features, create mobile versions.
- **Write tests** – Use `:memory:` databases for fast unit tests.
- **Performance tune** – Measure query times and optimise.
- **Share your work** – Open‑source your projects.

---

**You now have a complete portfolio of SQLite‑powered applications.** From simple finance trackers to full‑scale task management systems, you've applied every concept in the series. These projects are ready to be deployed, extended, and used as the foundation for your own ideas.

**Go build something great!**
