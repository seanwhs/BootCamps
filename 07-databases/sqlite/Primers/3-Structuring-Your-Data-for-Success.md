# Database Design Primer 3: Structuring Your Data for Success

Good database design is like good architecture: it makes everything easier. A well‑designed database:

- **Eliminates redundancy** (the same data stored in multiple places).
- **Ensures integrity** (no contradictory or missing data).
- **Is easy to query** (fast and simple SQL).
- **Adapts to change** (adding new features doesn't break everything).

This primer covers the essential concepts—**entities**, **attributes**, **relationships**, **keys**, **normalization**, and **common schema patterns**—so you can design robust, production‑ready databases.

---

## 1. Entities, Attributes, and Relationships

### Entity
An entity is a real‑world object or concept that we store data about. Think of it as a noun: **Customer**, **Order**, **Product**, **Employee**.

### Attribute
An attribute is a property of an entity: **Customer.name**, **Order.date**, **Product.price**.

### Relationship
A relationship describes how entities interact: a **Customer** *places* an **Order**; a **Product** *belongs to* a **Category**.

### Cardinalities (How Many?)
- **One‑to‑One (1:1)**: A Person has one Passport; a Passport belongs to one Person.
- **One‑to‑Many (1:N)**: A Customer has many Orders; an Order belongs to one Customer.
- **Many‑to‑Many (M:N)**: A Book has many Authors; an Author writes many Books. This requires a **junction table**.

---

## 2. Keys

### Primary Key (PK)
Uniquely identifies each row. Usually an integer (`AUTOINCREMENT`) or a natural unique value (like an ISBN).

```sql
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,   -- surrogate key
    isbn TEXT PRIMARY KEY            -- natural key, less common
);
```

### Foreign Key (FK)
A column in one table that references the primary key of another table. It establishes the relationship.

```sql
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    author_id INTEGER,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);
```

### Composite Key
A primary key made of two or more columns.

```sql
CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    PRIMARY KEY (book_id, author_id)
);
```

---

## 3. Normalization (The 3NF Rule)

Normalization is a process that organizes tables to reduce redundancy. We aim for **Third Normal Form (3NF)** in most applications.

### First Normal Form (1NF)
- Each cell must contain a single value (no arrays or lists).
- Each column has a unique name.
- The order of rows and columns doesn't matter.

**Violation (bad):** An `orders` table storing multiple products in one cell.
```
order_id | products
1        | "Laptop, Mouse, Keyboard"
```
**Fixed:** Create separate rows or a junction table.

---

### Second Normal Form (2NF)
- Must be in 1NF.
- Every non‑key column must depend on the **entire** primary key (no partial dependencies).

**Violation (bad):** A table with composite key `(order_id, product_id)` storing `product_name` (which depends only on `product_id`, not the full key).
```
order_id | product_id | product_name | quantity
1        | 101        | Laptop       | 1
2        | 101        | Laptop       | 2
```
**Fixed:** Move `product_name` to a separate `products` table.

---

### Third Normal Form (3NF)
- Must be in 2NF.
- No transitive dependencies: non‑key columns must depend **only** on the primary key, not on other non‑key columns.

**Violation (bad):** An `orders` table storing `customer_city` which depends on `customer_id` (a non‑key column).
```
order_id | customer_id | customer_city | order_date
1        | 101         | New York      | 2025-01-01
```
**Fixed:** Store `customer_city` in the `customers` table and join when needed.

---

## 4. Designing Relationships

### One‑to‑Many (1:N)
Place the foreign key in the "many" side.

```sql
-- One Customer has many Orders
CREATE TABLE customers (customer_id INTEGER PRIMARY KEY);
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER REFERENCES customers);
```

---

### Many‑to‑Many (M:N)
Create a **junction table** with composite primary key of both foreign keys.

```sql
-- Books and Authors
CREATE TABLE books (book_id INTEGER PRIMARY KEY);
CREATE TABLE authors (author_id INTEGER PRIMARY KEY);
CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books,
    FOREIGN KEY (author_id) REFERENCES authors
);
```

---

### One‑to‑One (1:1)
Place the foreign key in one of the tables with a `UNIQUE` constraint.

```sql
CREATE TABLE users (user_id INTEGER PRIMARY KEY);
CREATE TABLE profiles (
    profile_id INTEGER PRIMARY KEY,
    user_id INTEGER UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users
);
```

---

## 5. Common Schema Patterns (with SQLite Examples)

### E‑Commerce
```sql
-- Users, Products, Categories, Orders, Order_Items
CREATE TABLE categories (category_id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE products (product_id INTEGER PRIMARY KEY, name TEXT, price REAL, category_id INTEGER);
CREATE TABLE users (user_id INTEGER PRIMARY KEY, name TEXT, email TEXT);
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, user_id INTEGER, order_date TEXT);
CREATE TABLE order_items (
    order_id INTEGER, product_id INTEGER, quantity INTEGER, price REAL,
    PRIMARY KEY (order_id, product_id)
);
```

### Social Media
```sql
CREATE TABLE users (user_id INTEGER PRIMARY KEY, username TEXT);
CREATE TABLE posts (post_id INTEGER PRIMARY KEY, user_id INTEGER, content TEXT, created_at TEXT);
CREATE TABLE likes (user_id INTEGER, post_id INTEGER, PRIMARY KEY (user_id, post_id));
```

### Task Management
```sql
CREATE TABLE projects (project_id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE tasks (task_id INTEGER PRIMARY KEY, project_id INTEGER, title TEXT, status TEXT, assigned_to INTEGER);
-- status could be 'todo', 'in_progress', 'done'
```

### Blog
```sql
CREATE TABLE authors (author_id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE posts (post_id INTEGER PRIMARY KEY, author_id INTEGER, title TEXT, content TEXT, published_at TEXT);
CREATE TABLE tags (tag_id INTEGER PRIMARY KEY, name TEXT UNIQUE);
CREATE TABLE post_tags (post_id INTEGER, tag_id INTEGER, PRIMARY KEY (post_id, tag_id));
```

---

## 6. Naming Conventions

Consistency makes your database easier to understand. Here's a common convention:

- **Tables**: plural, lowercase, underscores (`users`, `order_items`).
- **Primary Keys**: `id` or `table_name_id` (e.g., `user_id`).
- **Foreign Keys**: same name as the referenced primary key (e.g., `customer_id`).
- **Columns**: lowercase, underscores (`created_at`, `first_name`).

**Example:**
```sql
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

---

## 7. When to Denormalize

Normalization is the default best practice, but sometimes we deliberately add redundancy for **performance**. This is called **denormalization**.

**Example:** If you query order totals very frequently, you might store `order_total` directly in the `orders` table rather than calculating it from `order_items` every time. You must keep it updated (e.g., via triggers).

**Rule of thumb:** Normalize for integrity; denormalize only after measuring and when necessary.

---

## 8. Practical Design Checklist

- [ ] Identify all **entities** (nouns) from requirements.
- [ ] Define **attributes** for each entity.
- [ ] Determine **relationships** (1:1, 1:N, M:N).
- [ ] Choose **primary keys** (surrogate integer keys recommended).
- [ ] Add **foreign keys** for relationships.
- [ ] Apply **normalization** (aim for 3NF).
- [ ] Create **indexes** on foreign keys and frequently‑queried columns.
- [ ] Use **constraints** (NOT NULL, UNIQUE, CHECK, DEFAULT) to enforce integrity.
- [ ] Write **ER diagrams** (even on paper) to visualise.

---

## 9. Example: Designing a Library System from Scratch

**Requirements:**
- Library has **books** (title, ISBN, year, category).
- **Authors** write books (many‑to‑many).
- **Members** borrow books; each loan has a date and due date.
- **Branches**: each book copy belongs to a branch.

**Step 1 – Entities:** Book, Author, Member, Branch, Loan, Category.

**Step 2 – Attributes:**
- **Book**: book_id, title, isbn, year, category_id
- **Author**: author_id, name
- **Member**: member_id, name, email
- **Branch**: branch_id, name, address
- **Loan**: loan_id, copy_id (which book copy?), member_id, loan_date, due_date, return_date
- **Category**: category_id, name

**Step 3 – Relationships:**
- Book belongs to one Category (1:N).
- Book has many Authors, Author writes many Books (M:N) → junction `book_authors`.
- Each Book has many Copies (1:N).
- Each Copy belongs to one Branch (1:N).
- Each Loan is for one Copy (1:N) and one Member (1:N).

**Step 4 – Schema (SQLite):**
```sql
CREATE TABLE categories (category_id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE books (book_id INTEGER PRIMARY KEY, title TEXT, isbn TEXT UNIQUE, year INTEGER, category_id INTEGER);
CREATE TABLE authors (author_id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE book_authors (book_id INTEGER, author_id INTEGER, PRIMARY KEY (book_id, author_id));
CREATE TABLE branches (branch_id INTEGER PRIMARY KEY, name TEXT, address TEXT);
CREATE TABLE copies (copy_id INTEGER PRIMARY KEY, book_id INTEGER, branch_id INTEGER, status TEXT);
CREATE TABLE members (member_id INTEGER PRIMARY KEY, name TEXT, email TEXT UNIQUE);
CREATE TABLE loans (loan_id INTEGER PRIMARY KEY, copy_id INTEGER, member_id INTEGER, loan_date TEXT, due_date TEXT, return_date TEXT);
```

**Step 5 – Add constraints, indexes, and foreign keys** to complete the design.

---

## 10. Summary

| Concept | Key Takeaway |
|---------|--------------|
| **Entity** | A real‑world "thing" (e.g., Customer). |
| **Attribute** | A property of an entity (e.g., name). |
| **Relationship** | How entities connect (e.g., Customer places Order). |
| **Primary Key** | Uniquely identifies a row. |
| **Foreign Key** | Links to a primary key in another table. |
| **Normalization** | Reduces redundancy and anomalies. Aim for 3NF. |
| **Denormalization** | Adds redundancy for performance. Use sparingly. |
| **Junction Table** | Handles many‑to‑many relationships. |

---

## Next Steps

- Practice designing schemas for different domains (e‑commerce, hospital, school).
- Use **DB Browser for SQLite** or any GUI tool to visualise your schema.
- Apply indexing strategies (covered in the **Master SQLite** series).
- Learn about **transactions** to keep your data consistent.
- Build a real project to solidify your skills.

---

This primer gives you the foundational knowledge to design clean, maintainable databases. In the **Master SQLite** series, you'll see these principles applied in full‑scale projects.

Happy designing!
