Welcome to Part 3. You now know how to write SQL and build tables. But knowing how to build a table is not the same as knowing what to build. This part is about the **art and science of structuring data** so that it is accurate, efficient, and easy to query. We will cover Entity-Relationship (ER) modeling, normalization theory, and then apply those principles to design schemas for several real-world domains. The capstone of this part is designing a complete relational database from scratch based on complex business requirements.

**Part 3** is divided into two modules:

- **Module 9:** Relational Database Design – ER modeling, normalization, denormalization, keys, and naming conventions.
- **Module 10:** Practical Schema Design – Domain schemas and a capstone project where you design a complete system.

Let's dive in.

---

# Part 3: Database Design

## Module 9: Relational Database Design

### The Target

By the end of this module, you will understand the process of taking a set of business requirements and transforming them into a clean, normalized relational schema. You will be able to identify entities, attributes, relationships, and apply the rules of normalization (1NF, 2NF, 3NF) to eliminate redundancy and avoid update anomalies.

### The Concept

Imagine you are an architect. Before you build a house, you draw blueprints. Database design is the blueprint for your data. A well-designed database ensures:

- **Data Integrity** – no contradictory or missing data.
- **Efficiency** – fast queries and minimal storage.
- **Flexibility** – easy to adapt to changing requirements.

The primary tool for this is **Entity-Relationship (ER) Modeling**. We identify the "things" (entities) in our domain, their "properties" (attributes), and how they "relate" to each other (relationships). Then we use **Normalization** to refine our tables and eliminate redundancy.

### Entities, Attributes, and Relationships

- **Entity** – A real-world object or concept that has a separate existence. Examples: `Customer`, `Order`, `Product`.
- **Attribute** – A property of an entity. Examples: `Customer.first_name`, `Order.order_date`.
- **Relationship** – An association between entities. Examples: A `Customer` *places* an `Order`. A `Product` *belongs to* a `Category`.

**Cardinalities** describe how many instances of one entity relate to another:

- **One-to-One (1:1)** – A `Person` has one `Passport`.
- **One-to-Many (1:N)** – A `Customer` has many `Orders`; an `Order` belongs to one `Customer`.
- **Many-to-Many (M:N)** – A `Book` has many `Authors`; an `Author` writes many `Books`. This requires a junction table.

### Normalization Explained with a Bad Example

Normalization is a process of organizing columns and tables to reduce data redundancy and improve integrity. We typically aim for **Third Normal Form (3NF)** in most applications.

Let's start with a **denormalized** table: `Order_Details` that tries to store everything in one place.

**Denormalized Table:**

| Order_ID | Customer_Name | Customer_Email | Order_Date | Product_ID | Product_Name | Product_Price | Quantity |
|----------|---------------|----------------|------------|------------|--------------|---------------|----------|
| 1001     | Alice         | alice@e.com    | 2025-01-01 | P1         | Laptop       | 1200          | 1        |
| 1001     | Alice         | alice@e.com    | 2025-01-01 | P2         | Mouse        | 25            | 2        |
| 1002     | Bob           | bob@e.com      | 2025-01-02 | P1         | Laptop       | 1200          | 1        |

**Problems (Anomalies):**
- **Update Anomaly** – If Alice's email changes, we must update it in multiple rows. If we miss one, data becomes inconsistent.
- **Insertion Anomaly** – We cannot add a new product unless it is part of an order.
- **Deletion Anomaly** – If we delete the only order for a product, we lose the product data entirely.

We fix this by decomposing the table into smaller, focused tables.

### The Normal Forms

**1NF (First Normal Form):**
- Each cell must contain a single value (atomic).
- Each column must have a unique name.
- The order of rows/columns does not matter.
Our table already satisfies 1NF because each cell has a single value.

**2NF (Second Normal Form):**
- Must be in 1NF.
- All non-key attributes must be fully functionally dependent on the **entire primary key**.
In our table, the composite primary key is `(Order_ID, Product_ID)`. `Product_Name` and `Product_Price` depend only on `Product_ID` (not the full key), and `Customer_Name` depends only on `Order_ID`. This violates 2NF.

**3NF (Third Normal Form):**
- Must be in 2NF.
- No transitive dependencies (a non-key attribute should not depend on another non-key attribute).
If we had a `Product_Category` that depends on `Product_ID` (which is a non-key if we split), we'd need to move it.

### Hands‑on Lab 9.1: Normalizing a Denormalized Table

#### The Target
Take the `Order_Details` table above and normalize it to 3NF.

#### Implementation

We will create tables in SQLite to represent the normalized structure.

**Step 1: Split into Orders, Customers, Products, and Order_Items.**

```sql
-- Create normalized schema
PRAGMA foreign_keys = ON;

-- 1. Customers table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);

-- 2. Products table
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price REAL NOT NULL CHECK (price >= 0)
);

-- 3. Orders table
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    order_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Order_Items table (junction for the many-to-many between Orders and Products)
CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);
```

**Step 2: Insert the sample data.**

```sql
-- Insert customers
INSERT INTO customers (name, email) VALUES ('Alice', 'alice@e.com'), ('Bob', 'bob@e.com');

-- Insert products
INSERT INTO products (name, price) VALUES ('Laptop', 1200.0), ('Mouse', 25.0);

-- Insert orders
INSERT INTO orders (order_id, customer_id, order_date) VALUES (1001, 1, '2025-01-01');
INSERT INTO orders (order_id, customer_id, order_date) VALUES (1002, 2, '2025-01-02');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1001, 1, 1); -- Laptop
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1001, 2, 2); -- Mouse
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1002, 1, 1); -- Laptop
```

**Step 3: Query the normalized data to reconstruct the original report.**

```sql
SELECT 
    o.order_id,
    c.name AS customer_name,
    c.email AS customer_email,
    o.order_date,
    p.product_id,
    p.name AS product_name,
    p.price AS product_price,
    oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;
```

#### Verification

Run the `SELECT` query. You should see exactly the same data as the denormalized table, but now it is stored in separate, non-redundant tables. If Alice's email changes, we update one row in `customers`. If we add a new product, it can exist without an order. If we delete an order, we only lose the `order_items` (due to `CASCADE`), not the product.

Now, test the integrity:

```sql
-- This should fail: duplicate email
INSERT INTO customers (name, email) VALUES ('Charlie', 'alice@e.com');

-- This should fail: quantity must be > 0
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1001, 1, -1);

-- This should fail: foreign key violation (product 999 doesn't exist)
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1001, 999, 1);
```

All these should raise errors, proving that our constraints protect data integrity.

---

### Denormalization (When and Why)

While normalization is the default best practice, sometimes we deliberately **denormalize** for performance. This means adding redundant data to avoid expensive joins in hot queries. For example, storing `customer_name` directly in the `orders` table so you don't have to join to get it.

**Rule of thumb:** Normalize for data integrity; denormalize for performance only after measuring and when necessary.

### Naming Conventions

Consistency is key. We follow these conventions:

- **Tables** – plural, lowercase, underscores (`customers`, `order_items`).
- **Primary Keys** – `tablename_id` (e.g., `customer_id`).
- **Foreign Keys** – same name as the primary key they reference.
- **Columns** – lowercase, underscores (`order_date`, `first_name`).
- **Avoid reserved words** (like `select`, `table`).

We have used these conventions throughout our examples.

---

**[GENERATED: Part 3, Module 9: Relational Database Design]**

---

## Module 10: Practical Schema Design

### The Target

Apply all the principles from Module 9 to design schemas for real-world domains. We will walk through an E-commerce system, a Hospital Management system, and a Student Information system. The **capstone lab** is to design a complete relational database from scratch based on a detailed business requirement specification.

### The Concept

Designing a schema is like writing a story about your data. You start with the requirements, identify the key actors (entities), define their attributes, and describe how they interact. We will practice this by building schemas for different industries, paying close attention to the unique challenges of each domain.

### Domain 1: E-Commerce System

**Requirements:**
- A customer can have many orders.
- An order can have many products (line items).
- Products belong to categories.
- Products have a name, price, and stock quantity.
- Orders have a status (pending, shipped, delivered) and a date.
- Payment information is stored per order (amount, method, date).

**Schema Design (ER Diagram in text):**

We will reuse the `customers`, `orders`, `order_items`, and `products` tables from Module 9, but we will add `categories` and `payments`.

```sql
-- Categories table
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- Products table (extended with category and stock)
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INTEGER,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Orders (extended with status)
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    order_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items (same as before, but we add unit_price to snapshot the price at order time)
CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price REAL NOT NULL CHECK (unit_price >= 0),  -- snapshot price
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments table
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    amount REAL NOT NULL CHECK (amount >= 0),
    method TEXT NOT NULL CHECK (method IN ('credit_card', 'paypal', 'cash')),
    payment_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
```

**Insert Sample Data and Test:**

```sql
-- Categories
INSERT INTO categories (name, description) VALUES 
    ('Electronics', 'Gadgets and devices'),
    ('Books', 'Printed and digital books');

-- Products
INSERT INTO products (name, price, stock_quantity, category_id) VALUES
    ('Smartphone', 599.99, 50, 1),
    ('Tablet', 399.99, 30, 1),
    ('SQLite Guide', 29.99, 100, 2);

-- Customers (we already have Alice and Bob)
-- Orders
INSERT INTO orders (customer_id, order_date, status) VALUES (1, '2025-02-01', 'shipped');
INSERT INTO orders (customer_id, order_date, status) VALUES (2, '2025-02-02', 'pending');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 599.99),
    (1, 3, 2, 29.99);  -- Alice ordered a phone and two books

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (2, 2, 1, 399.99);  -- Bob ordered a tablet

-- Payments
INSERT INTO payments (order_id, amount, method) VALUES (1, 659.97, 'credit_card');
INSERT INTO payments (order_id, amount, method) VALUES (2, 399.99, 'paypal');
```

**Complex Query Example: Find total revenue per product.**

```sql
SELECT p.name, SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC;
```

---

### Domain 2: Hospital Management System

**Requirements:**
- Patients are admitted with an admission date.
- Patients have a primary doctor (a staff member).
- Staff include doctors and nurses.
- Each patient can have multiple treatments (e.g., X-ray, surgery).
- Treatments have a name, description, and cost.

**Schema Design:**

```sql
-- Staff
CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('doctor', 'nurse', 'admin')),
    specialization TEXT  -- only for doctors
);

-- Patients
CREATE TABLE patients (
    patient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    date_of_birth TEXT NOT NULL,
    admission_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    primary_doctor_id INTEGER,
    FOREIGN KEY (primary_doctor_id) REFERENCES staff(staff_id)
);

-- Treatments
CREATE TABLE treatments (
    treatment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    cost REAL NOT NULL CHECK (cost >= 0)
);

-- Patient Treatments (junction)
CREATE TABLE patient_treatments (
    patient_id INTEGER NOT NULL,
    treatment_id INTEGER NOT NULL,
    performed_by INTEGER NOT NULL,  -- staff who performed it
    performed_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    notes TEXT,
    PRIMARY KEY (patient_id, treatment_id, performed_date), -- composite key
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id) ON DELETE CASCADE,
    FOREIGN KEY (performed_by) REFERENCES staff(staff_id)
);
```

**Verification Query:** List all patients with their primary doctor.

```sql
SELECT p.first_name || ' ' || p.last_name AS patient,
       s.first_name || ' ' || s.last_name AS doctor
FROM patients p
LEFT JOIN staff s ON p.primary_doctor_id = s.staff_id;
```

---

### Domain 3: Student Information System

**Requirements:**
- Students enroll in courses.
- Courses have a code, name, and credits.
- Students have a name, email, and enrollment date.
- Each course is taught by a professor (staff).
- Grades are recorded for each enrollment.

**Schema Design:**

```sql
-- Professors (subset of staff)
CREATE TABLE professors (
    professor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);

-- Students
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    enrollment_date TEXT DEFAULT (datetime('now', 'localtime'))
);

-- Courses
CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,  -- e.g., 'CS101'
    name TEXT NOT NULL,
    credits INTEGER NOT NULL CHECK (credits > 0),
    professor_id INTEGER NOT NULL,
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id)
);

-- Enrollments (junction with grade)
CREATE TABLE enrollments (
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    enrollment_date TEXT DEFAULT (datetime('now', 'localtime')),
    grade TEXT CHECK (grade IN ('A', 'B', 'C', 'D', 'F', 'INC', 'W')), -- allow NULL
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);
```

**Verification Query:** Get the average number of credits per student.

```sql
SELECT s.first_name || ' ' || s.last_name AS student,
       COUNT(e.course_id) AS course_count,
       SUM(c.credits) AS total_credits
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id
GROUP BY s.student_id;
```

---

### Capstone Lab: Design a Complete Database from Scratch

#### The Target
You are given the following business requirements for a **Library Management System**. Design the entire schema from scratch, including all tables, constraints, and indexes. Then implement it in SQLite and populate it with sample data.

**Business Requirements:**

1. The library has a collection of books. Each book has a title, ISBN (unique), publication year, edition, and a category (e.g., Fiction, Non-Fiction, Science).
2. The library has multiple branches. Each branch has a name, address, and phone number.
3. Each book copy belongs to a specific branch. Copies are identified by a copy number (unique within the branch) and have a status (available, loaned, damaged, lost).
4. Members can borrow books. Each member has a name, email (unique), phone, and membership date.
5. When a member borrows a copy, we record the loan date and the expected return date (e.g., 14 days later). When the copy is returned, we record the actual return date.
6. If a member returns a book late, a fine is calculated at $0.50 per day overdue.
7. The library wants to be able to generate reports: books currently loaned, overdue books, most popular books, etc.
8. Security: Enforce that a member cannot borrow more than 5 books at the same time.
9. Business rule: A book copy cannot be loaned if its status is not 'available'.

#### Step 1: Identify Entities, Attributes, Relationships

- **Entity 1: `books`** (title, isbn unique, publication_year, edition, category_id)
- **Entity 2: `categories`** (name, description)
- **Entity 3: `branches`** (name, address, phone)
- **Entity 4: `copies`** (book_id, branch_id, copy_number (unique per branch), status)
- **Entity 5: `members`** (name, email unique, phone, membership_date)
- **Entity 6: `loans`** (copy_id, member_id, loan_date, expected_return_date, actual_return_date, fine)

**Relationships:**
- A `book` belongs to one `category` (1:N).
- A `copy` belongs to one `book` and one `branch`.
- A `loan` involves one `copy` and one `member`.

#### Step 2: Write the SQL Schema

We will implement this with all constraints, including a trigger to enforce the max 5 books rule and a trigger to automatically set expected_return_date to 14 days later.

```sql
-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- 1. Categories
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- 2. Books
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    isbn TEXT UNIQUE NOT NULL,
    publication_year INTEGER CHECK (publication_year > 0),
    edition TEXT,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 3. Branches
CREATE TABLE branches (
    branch_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT
);

-- 4. Copies
CREATE TABLE copies (
    copy_id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    branch_id INTEGER NOT NULL,
    copy_number INTEGER NOT NULL,  -- unique per branch
    status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'loaned', 'damaged', 'lost')),
    UNIQUE (branch_id, copy_number),  -- copy_number is unique within a branch
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE CASCADE
);

-- 5. Members
CREATE TABLE members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    membership_date TEXT DEFAULT (datetime('now', 'localtime'))
);

-- 6. Loans
CREATE TABLE loans (
    loan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    copy_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    loan_date TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    expected_return_date TEXT NOT NULL DEFAULT (datetime('now', '+14 days')),
    actual_return_date TEXT,
    fine REAL DEFAULT 0 CHECK (fine >= 0),
    FOREIGN KEY (copy_id) REFERENCES copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_copy ON loans(copy_id);
CREATE INDEX idx_loans_returned ON loans(actual_return_date) WHERE actual_return_date IS NULL;
CREATE INDEX idx_copies_book ON copies(book_id);
CREATE INDEX idx_copies_branch ON copies(branch_id);

-- 7. Trigger to enforce: a member cannot borrow more than 5 books at a time
CREATE TRIGGER limit_borrows
BEFORE INSERT ON loans
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(*) FROM loans 
            WHERE member_id = NEW.member_id AND actual_return_date IS NULL
        ) >= 5
        THEN RAISE(ABORT, 'Member already has 5 books loaned')
    END;
END;

-- 8. Trigger to automatically update copy status when a loan is inserted
CREATE TRIGGER update_copy_status_on_loan
AFTER INSERT ON loans
BEGIN
    UPDATE copies SET status = 'loaned' WHERE copy_id = NEW.copy_id;
END;

-- 9. Trigger to update copy status and calculate fine when a book is returned
CREATE TRIGGER update_return
AFTER UPDATE OF actual_return_date ON loans
WHEN NEW.actual_return_date IS NOT NULL
BEGIN
    -- Update copy status back to available
    UPDATE copies SET status = 'available' WHERE copy_id = NEW.copy_id;
    
    -- Calculate fine if overdue
    UPDATE loans 
    SET fine = ROUND(
        (julianday(NEW.actual_return_date) - julianday(NEW.expected_return_date)) * 0.50,
        2
    )
    WHERE loan_id = NEW.loan_id 
    AND NEW.actual_return_date > NEW.expected_return_date;
END;
```

#### Step 3: Populate Sample Data

```sql
-- Categories
INSERT INTO categories (name, description) VALUES 
    ('Fiction', 'Imaginative prose novels'),
    ('Science', 'Scientific and technical books'),
    ('History', 'Historical narratives');

-- Books
INSERT INTO books (title, isbn, publication_year, edition, category_id) VALUES
    ('Dune', '978-0-441-17271-9', 1965, '1st', 1),
    ('A Brief History of Time', '978-0-553-38016-3', 1988, 'Updated', 2),
    ('Sapiens', '978-0-06-231609-7', 2014, '1st', 3);

-- Branches
INSERT INTO branches (name, address, phone) VALUES
    ('Central Library', '123 Main St', '555-1234'),
    ('East Branch', '456 Oak Ave', '555-5678');

-- Copies (2 copies of Dune at Central, 1 at East, etc.)
INSERT INTO copies (book_id, branch_id, copy_number, status) VALUES
    (1, 1, 1, 'available'),
    (1, 1, 2, 'available'),
    (1, 2, 1, 'available'),
    (2, 1, 1, 'available'),
    (3, 1, 1, 'available');

-- Members
INSERT INTO members (first_name, last_name, email, phone) VALUES
    ('Alice', 'Smith', 'alice@lib.com', '555-0001'),
    ('Bob', 'Johnson', 'bob@lib.com', '555-0002');

-- Test a loan (Alice borrows copy 1 of Dune)
INSERT INTO loans (copy_id, member_id, loan_date) VALUES (1, 1, datetime('now'));

-- Verify copy status changed
SELECT copy_id, status FROM copies WHERE copy_id = 1;  -- should be 'loaned'

-- Try to borrow 6 books (we only have 5 copies, but we'll force it later; the trigger will prevent)
-- For now, let's simulate returning the book
UPDATE loans SET actual_return_date = datetime('now', '+15 days') WHERE loan_id = 1;

-- Check the fine (should be 0.50 * 1 day = 0.50)
SELECT loan_id, fine FROM loans WHERE loan_id = 1;
```

#### Step 4: Verification Queries

**1. List all books currently loaned (with member and due date).**

```sql
SELECT b.title, m.first_name || ' ' || m.last_name AS member, l.expected_return_date
FROM loans l
JOIN copies c ON l.copy_id = c.copy_id
JOIN books b ON c.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.actual_return_date IS NULL;
```

**2. List overdue books (today is after expected_return_date).**

```sql
SELECT b.title, m.email, l.expected_return_date, 
       JULIANDAY('now') - JULIANDAY(l.expected_return_date) AS days_overdue
FROM loans l
JOIN copies c ON l.copy_id = c.copy_id
JOIN books b ON c.book_id = b.book_id
JOIN members m ON l.member_id = m.member_id
WHERE l.actual_return_date IS NULL
  AND l.expected_return_date < datetime('now');
```

**3. Most popular books (count of loans per book).**

```sql
SELECT b.title, COUNT(l.loan_id) AS loan_count
FROM books b
JOIN copies c ON b.book_id = c.book_id
LEFT JOIN loans l ON c.copy_id = l.copy_id
GROUP BY b.book_id
ORDER BY loan_count DESC;
```

**4. Test the constraint: Add a second loan for Alice (she already has one). She can have up to 5. Let's add 4 more to hit the limit.**

```sql
-- We'll add loans for copies 2, 3, 4, 5 (assuming copy_id 2 is Dune copy 2, etc.)
INSERT INTO loans (copy_id, member_id) VALUES (2, 1); -- loan 2
INSERT INTO loans (copy_id, member_id) VALUES (3, 1); -- loan 3
INSERT INTO loans (copy_id, member_id) VALUES (4, 1); -- loan 4
INSERT INTO loans (copy_id, member_id) VALUES (5, 1); -- loan 5

-- Now try a 6th loan (should fail)
INSERT INTO loans (copy_id, member_id) VALUES (3, 1); -- But copy 3 is already loaned; we need an available copy. Let's add a new copy first.
INSERT INTO copies (book_id, branch_id, copy_number, status) VALUES (1, 1, 6, 'available');
-- Now try to borrow it with Alice (should abort due to trigger)
INSERT INTO loans (copy_id, member_id) VALUES (6, 1);
```

You should see an error: `Member already has 5 books loaned`.

**5. Test the fine calculation: Return a book late.**

```sql
-- Borrow a book for Bob
INSERT INTO loans (copy_id, member_id, loan_date) VALUES (2, 2, datetime('now', '-20 days'));
-- Update return date to today (which is 20 days later, expected was 14 days)
UPDATE loans SET actual_return_date = datetime('now') WHERE loan_id = 6; -- assuming loan_id 6 is the new one
SELECT loan_id, fine FROM loans WHERE loan_id = 6; -- should be 0.50 * 6 = 3.00 (or close)
```

---

### Verification of Capstone

Run all the SQL commands above in order. Confirm:

1. All tables are created without errors.
2. Triggers are created.
3. Insertion of sample data works.
4. The borrow limit trigger prevents borrowing more than 5.
5. Returning a book updates the copy status and calculates the correct fine.

This capstone demonstrates a complete, production-ready design with advanced features (triggers, constraints, indexes) that you can extend to any domain.

## End of Part 3

You have completed Part 3. You now possess the architectural mindset needed to transform messy requirements into clean, robust schemas. You understand normalization, ER modeling, and have practical experience designing systems for e-commerce, healthcare, education, and library management. You also built a fully functional library system with triggers and business rules.

In **Part 4: Indexing & Query Optimization**, we will shift our focus from *structure* to *speed*. You will learn how to use indexes to turn slow queries into lightning-fast ones, and how to use the query planner to understand and tune performance.
