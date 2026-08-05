# Part 1 — Foundations of Relational Database Design

## Build the Right Foundation Before You Write a Single Query

---

### Introduction to Part 1

Welcome to the first hands‑on phase of your journey. In this part, we will take the business requirements of **ScaleCart** and turn them into a robust, normalized relational database schema. By the end, you will have a production‑ready PostgreSQL database that enforces data integrity, supports efficient queries, and is prepared for the performance optimizations we’ll add later.

We will proceed through the following sections:

1. **Domain‑Driven Data Modeling** – Identify entities, attributes, relationships, and constraints using Entity‑Relationship Diagrams (ERDs).
2. **Translating ERD to Relational Schema** – Convert the conceptual model into tables, columns, and foreign keys.
3. **Normalization That Makes Sense** – Apply 1NF, 2NF, 3NF, and BCNF to eliminate redundancy and anomalies.
4. **Designing Efficient Tables** – Choose appropriate data types, default values, and storage options.
5. **Implementing the Schema in PostgreSQL** – Write and execute the complete DDL (Data Definition Language) script.
6. **Seeding and Verification** – Load sample data and validate the schema with test queries.
7. **When to Denormalize** – Understand the trade‑offs and when experienced engineers intentionally break normalization.

**Target audience:** This part assumes you already know basic SQL syntax (CREATE, INSERT, SELECT). We’ll explain every design decision in depth.

**Estimated time:** 5‑6 hours of active work. You can pause after each section.

Let’s begin.

---

## Section 1.1 – Domain‑Driven Data Modeling

### 1.1.1 The Target

**What are we building?**  
We are creating a complete **Entity‑Relationship Diagram (ERD)** for the ScaleCart e‑commerce platform. The ERD will visually represent all entities, their attributes, the relationships between them, and the business constraints (e.g., a product must have a price, an order must belong to a customer).

### 1.1.2 The Concept – Thinking Like a Domain Expert

**Analogy:** Imagine you are designing a library catalog system. You would first list all the things you need to track: books, authors, publishers, members, loans, etc. For each thing, you list its properties (title, ISBN, name, address, due date). Then you decide how these things are connected (a book is written by an author, a loan is associated with a member and a book). This is exactly what we do with ERDs.

**Terminology (defined inline):**
- **Entity** – A real‑world object or concept that has independent existence (e.g., `Customer`, `Product`, `Order`). In a database, an entity becomes a table.
- **Attribute** – A property or characteristic of an entity (e.g., `name`, `price`, `order_date`). Attributes become columns.
- **Relationship** – An association between two or more entities (e.g., a `Customer` places an `Order`). Relationships become foreign keys or join tables.
- **Cardinality** – The number of instances of one entity that can be associated with another. Common types: one‑to‑one (1:1), one‑to‑many (1:N), many‑to‑many (N:M).
- **Business constraint** – A rule derived from business logic (e.g., an order total must be positive; a product’s stock cannot be negative).

### 1.1.3 Gathering Requirements for ScaleCart

We’ll start with a written description of the business domain. From this, we extract entities and relationships.

**ScaleCart Requirements:**

1. **Products** – Each product has a unique ID, a name, a description (optional), a price (must be >= 0), and a creation timestamp. Products belong to exactly one category, but a category can contain many products.

2. **Categories** – Each category has a unique ID, a name, and an optional parent category (to support hierarchical categorization, e.g., “Electronics” -> “Laptops”).

3. **Suppliers** – Each supplier has a unique ID, name, contact email, phone number, and address. A product can be supplied by multiple suppliers, and a supplier can supply many products. The price from each supplier may differ (this is a “supplier_product” relationship with an extra attribute: `supply_price`).

4. **Customers** – Each customer has a unique ID, email (must be unique), full name, password hash (for authentication), and registration date. They may have multiple addresses (shipping and billing), and we need to distinguish address types.

5. **Addresses** – Each address has a unique ID, street, city, state, postal code, country, and a flag for whether it’s the default shipping address for that customer. Addresses are linked to customers.

6. **Orders** – Each order has a unique ID, a reference to the customer who placed it, the order date, a status (e.g., pending, paid, shipped, delivered), and a total amount. An order can contain multiple line items (order items), each referencing a product and specifying the quantity and the unit price at the time of order.

7. **Order Items** – A line item belongs to one order and one product. It records the quantity purchased and the price per unit (historical snapshot).

8. **Inventory** – We need to track stock levels per product. Each product has a current stock quantity. Also, we might have multiple warehouses, but for simplicity we’ll assume a single warehouse initially. We’ll also track reorder thresholds.

9. **Payments** – For each order, we may have one or more payment records (e.g., partial payments). Payments have a method (credit card, PayPal), amount, status, and timestamp.

10. **Reviews** – Customers can leave reviews for products. Each review has a rating (1‑5), a comment, and a timestamp. A customer can review a product only once.

**Additional business constraints:**
- An order total must equal the sum of its line items’ subtotals (quantity * unit price). This is enforced by application logic, but we’ll design the schema to support it.
- A product’s stock cannot go below zero. We’ll handle this with a check constraint.
- An order status can only be one of a fixed set of values (we’ll use an ENUM).

### 1.1.4 Identifying Entities and Attributes

From the requirements, we list the main entities and their attributes.

| Entity | Attributes |
|--------|------------|
| **Category** | `id` (PK), `name`, `parent_category_id` (FK to self) |
| **Product** | `id` (PK), `name`, `description`, `price`, `category_id` (FK), `created_at`, `updated_at` |
| **Supplier** | `id` (PK), `name`, `contact_email`, `phone`, `address` |
| **SupplierProduct** (junction) | `supplier_id` (PK, FK), `product_id` (PK, FK), `supply_price` |
| **Customer** | `id` (PK), `email` (unique), `password_hash`, `full_name`, `registered_at` |
| **Address** | `id` (PK), `customer_id` (FK), `street`, `city`, `state`, `postal_code`, `country`, `is_default_shipping` |
| **Order** | `id` (PK), `customer_id` (FK), `order_date`, `status`, `total_amount` |
| **OrderItem** | `order_id` (PK, FK), `product_id` (PK, FK), `quantity`, `unit_price` |
| **Inventory** | `product_id` (PK, FK), `stock_quantity`, `reorder_threshold` |
| **Payment** | `id` (PK), `order_id` (FK), `amount`, `method`, `status`, `payment_date` |
| **Review** | `id` (PK), `product_id` (FK), `customer_id` (FK), `rating`, `comment`, `review_date` (unique constraint on product_id, customer_id) |

### 1.1.5 Defining Relationships and Cardinalities

Now we draw the connections.

- **Category** to **Product**: one‑to‑many (1:N). A category can have many products; a product belongs to exactly one category.
- **Supplier** to **Product** via **SupplierProduct**: many‑to‑many (N:M) with an extra attribute `supply_price`. Each association represents a supply agreement.
- **Customer** to **Address**: one‑to‑many (1:N). A customer can have many addresses; an address belongs to exactly one customer.
- **Customer** to **Order**: one‑to‑many (1:N). A customer can place many orders; an order is placed by exactly one customer.
- **Order** to **OrderItem**: one‑to‑many (1:N). An order can have many line items; each line item belongs to exactly one order.
- **Product** to **OrderItem**: one‑to‑many (1:N). A product can appear in many order items; an order item references exactly one product (historical snapshot of price).
- **Product** to **Inventory**: one‑to‑one (1:1). Each product has exactly one inventory record (with stock quantity). We keep it separate to allow for future expansion.
- **Order** to **Payment**: one‑to‑many (1:N). An order can have multiple payments (e.g., partial), each payment belongs to exactly one order.
- **Product** to **Review**: one‑to‑many (1:N). A product can have many reviews; a review is for exactly one product.
- **Customer** to **Review**: one‑to‑many (1:N). A customer can write many reviews; a review is written by exactly one customer.
- **Category** self‑reference: one‑to‑many (1:N) for subcategories (parent_category_id).

We also note cardinalities:
- A product must have a category (not null).
- An order must have a customer (not null).
- An order item must have an order and a product.
- Inventory record must exist for each product (we’ll enforce via application logic, or we could create a trigger).

### 1.1.6 Drawing the ERD (Conceptual)

Since we can’t draw images in text, we’ll represent it using a text‑based diagram. But more importantly, we’ll translate it directly into SQL tables in the next section. For now, we solidify the design.

**Text ERD (simplified):**

```
+-------------+          +------------+          +------------+
|  Category   |          |  Supplier  |          |  Customer  |
+-------------+          +------------+          +------------+
| id (PK)     |          | id (PK)    |          | id (PK)    |
| name        |          | name       |          | email      |
| parent_id   |◄─┐       | contact    |          | password   |
+-------------+  │       | phone      |          | full_name  |
       │          │       | address    |          | reg_date   |
       │          │       +------------+          +------------+
       │          │              │                        │
       │          │              │                        │
       ▼          │              ▼                        ▼
+-------------+  │       +-----------------+       +------------+
|  Product    |  │       | SupplierProduct |       |  Address   |
+-------------+  │       +-----------------+       +------------+
| id (PK)     |  │       | supplier_id (PK)|       | id (PK)    |
| name        |  │       | product_id (PK) |       | customer_id|
| description |  │       | supply_price    |       | street     |
| price       |  │       +-----------------+       | city       |
| category_id |──┘       │          │              | state      |
| created_at  |          │          │              | postal     |
| updated_at  |          │          │              | country    |
+-------------+          │          │              | is_default |
       │                  │          │              +------------+
       │                  │          │
       │                  │          │
       ▼                  │          ▼
+-------------+           │       +------------+
|  Inventory  |           │       |  Order     |
+-------------+           │       +------------+
| product_id  |           │       | id (PK)    |
| stock_qty   |           │       | customer_id|
| reorder_th  |           │       | order_date |
+-------------+           │       | status     |
       │                  │       | total      |
       │                  │       +------------+
       │                  │              │
       │                  │              ▼
       │                  │       +-----------------+
       │                  │       |   OrderItem     |
       │                  │       +-----------------+
       │                  │       | order_id (PK)   |
       │                  │       | product_id (PK) |
       │                  │       | quantity        |
       │                  │       | unit_price      |
       │                  │       +-----------------+
       │                  │              │
       │                  │              │
       │                  ▼              ▼
       │           +------------+  +------------+
       │           |  Payment   |  |  Review    |
       │           +------------+  +------------+
       │           | id (PK)    |  | id (PK)    |
       │           | order_id   |  | product_id |
       │           | amount     |  | customer_id|
       │           | method     |  | rating     |
       │           | status     |  | comment    |
       │           | date       |  | review_date|
       │           +------------+  +------------+
       │
       ▼
(Note: Review also linked to Customer, not shown)
```

### 1.1.7 Business Constraints Checklist

We capture all constraints that must be enforced at the database level:

- **Primary keys** – all entities have a unique ID.
- **Foreign keys** – to enforce relationships.
- **NOT NULL** – e.g., product name, price, category_id, order customer_id, etc.
- **UNIQUE** – customer email, and (product_id, customer_id) on Review to prevent duplicate reviews.
- **CHECK** – price >= 0, stock_quantity >= 0, rating between 1 and 5, order status in an enum.
- **Default values** – `created_at` defaults to `CURRENT_TIMESTAMP`, `updated_at` defaults and updates on change.
- **Cascading actions** – we need to decide what happens when a parent is deleted: for example, if a category is deleted, what happens to its products? We might set `ON DELETE RESTRICT` (prevent deletion if products exist) or `ON DELETE SET NULL` (if we allow products without category). We’ll choose `RESTRICT` for most relationships to protect integrity.

### 1.1.8 Verification – ERD Review

At this stage, we have a complete conceptual model. To verify, we’ll run through a few scenarios:

1. **Can we track a product’s supplier?** Yes, via SupplierProduct.
2. **Can we get all orders for a customer?** Yes, via customer_id in Order.
3. **Can we get all items in an order?** Yes, via OrderItem.
4. **Can we enforce that a customer can only review a product once?** Yes, with a unique constraint on (product_id, customer_id).
5. **Can we handle hierarchical categories?** Yes, with parent_category_id self‑FK.

**We are confident the ERD covers all requirements.**

---

## Section 1.2 – Translating ERD to Relational Schema

### 1.2.1 The Target

Now we convert the ERD into a **relational schema** – a set of table definitions with columns, data types, primary keys, foreign keys, and constraints. This is the blueprint for our SQL DDL.

### 1.2.2 The Concept – From Picture to Tables

An ERD is like a blueprint for a house. The relational schema is the actual construction plan: each entity becomes a table, each attribute becomes a column, relationships become foreign keys or junction tables. We decide exact data types (e.g., VARCHAR(255), INTEGER, DECIMAL) and additional constraints.

**Terminology:**
- **DDL (Data Definition Language)** – SQL commands like `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`.
- **Junction table** – a table used to implement many‑to‑many relationships (e.g., `SupplierProduct`). It contains foreign keys to both participating tables and may have additional attributes.

### 1.2.3 Mapping Each Entity to a Table

We’ll go through each entity and define its columns.

#### Table: `categories`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| name | VARCHAR(100) | NOT NULL, UNIQUE |
| parent_category_id | INTEGER | FOREIGN KEY REFERENCES categories(id) ON DELETE RESTRICT |

#### Table: `products`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| name | VARCHAR(255) | NOT NULL |
| description | TEXT | |
| price | DECIMAL(10,2) | NOT NULL, CHECK (price >= 0) |
| category_id | INTEGER | NOT NULL, FOREIGN KEY REFERENCES categories(id) ON DELETE RESTRICT |
| created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| updated_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

#### Table: `suppliers`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| name | VARCHAR(200) | NOT NULL |
| contact_email | VARCHAR(100) | NOT NULL, UNIQUE |
| phone | VARCHAR(20) | |
| address | TEXT | |

#### Table: `supplier_products` (junction)

| Column | Type | Constraints |
|--------|------|-------------|
| supplier_id | INTEGER | PRIMARY KEY, FOREIGN KEY REFERENCES suppliers(id) ON DELETE CASCADE |
| product_id | INTEGER | PRIMARY KEY, FOREIGN KEY REFERENCES products(id) ON DELETE CASCADE |
| supply_price | DECIMAL(10,2) | NOT NULL, CHECK (supply_price >= 0) |

#### Table: `customers`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| email | VARCHAR(255) | NOT NULL, UNIQUE |
| password_hash | VARCHAR(255) | NOT NULL |
| full_name | VARCHAR(100) | NOT NULL |
| registered_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

#### Table: `addresses`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| customer_id | INTEGER | NOT NULL, FOREIGN KEY REFERENCES customers(id) ON DELETE CASCADE |
| street | VARCHAR(200) | NOT NULL |
| city | VARCHAR(100) | NOT NULL |
| state | VARCHAR(50) | |
| postal_code | VARCHAR(20) | |
| country | VARCHAR(50) | NOT NULL |
| is_default_shipping | BOOLEAN | DEFAULT FALSE |

#### Table: `orders`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| customer_id | INTEGER | NOT NULL, FOREIGN KEY REFERENCES customers(id) ON DELETE RESTRICT |
| order_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| status | VARCHAR(20) | NOT NULL, CHECK (status IN ('pending','paid','shipped','delivered','cancelled')) |
| total_amount | DECIMAL(10,2) | NOT NULL, CHECK (total_amount >= 0) |

#### Table: `order_items`

| Column | Type | Constraints |
|--------|------|-------------|
| order_id | INTEGER | PRIMARY KEY, FOREIGN KEY REFERENCES orders(id) ON DELETE CASCADE |
| product_id | INTEGER | PRIMARY KEY, FOREIGN KEY REFERENCES products(id) ON DELETE RESTRICT |
| quantity | INTEGER | NOT NULL, CHECK (quantity > 0) |
| unit_price | DECIMAL(10,2) | NOT NULL, CHECK (unit_price >= 0) |

#### Table: `inventory`

| Column | Type | Constraints |
|--------|------|-------------|
| product_id | INTEGER | PRIMARY KEY, FOREIGN KEY REFERENCES products(id) ON DELETE CASCADE |
| stock_quantity | INTEGER | NOT NULL, DEFAULT 0, CHECK (stock_quantity >= 0) |
| reorder_threshold | INTEGER | NOT NULL, DEFAULT 10, CHECK (reorder_threshold >= 0) |
| last_updated | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

#### Table: `payments`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| order_id | INTEGER | NOT NULL, FOREIGN KEY REFERENCES orders(id) ON DELETE RESTRICT |
| amount | DECIMAL(10,2) | NOT NULL, CHECK (amount > 0) |
| method | VARCHAR(20) | NOT NULL, CHECK (method IN ('credit_card','paypal','bank_transfer')) |
| status | VARCHAR(20) | NOT NULL, CHECK (status IN ('pending','completed','failed')) |
| payment_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |

#### Table: `reviews`

| Column | Type | Constraints |
|--------|------|-------------|
| id | SERIAL | PRIMARY KEY |
| product_id | INTEGER | NOT NULL, FOREIGN KEY REFERENCES products(id) ON DELETE CASCADE |
| customer_id | INTEGER | NOT NULL, FOREIGN KEY REFERENCES customers(id) ON DELETE CASCADE |
| rating | INTEGER | NOT NULL, CHECK (rating BETWEEN 1 AND 5) |
| comment | TEXT | |
| review_date | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP |
| UNIQUE (product_id, customer_id) | | ensures one review per customer per product |

### 1.2.4 Choosing Data Types Wisely

- **SERIAL** – auto‑incrementing integer, suitable for surrogate primary keys.
- **DECIMAL(10,2)** – exact numeric for currency, 10 digits total, 2 after decimal. Good for prices up to $99,999,999.99.
- **VARCHAR** – variable‑length string with max length. We set reasonable limits (e.g., name 255, email 255).
- **TEXT** – unlimited length for descriptions and comments.
- **TIMESTAMP** – stores date and time with time zone (we’ll use `TIMESTAMPTZ` in PostgreSQL for better practice).
- **BOOLEAN** – true/false for flags.

**Why not use FLOAT for money?** Floating point can introduce rounding errors. Use DECIMAL or NUMERIC.

### 1.2.5 Foreign Key Constraints and Actions

We choose `ON DELETE` actions carefully:

- **RESTRICT** – prevents deletion of a parent if child rows exist. This maintains integrity (e.g., don’t delete a category that has products).
- **CASCADE** – automatically deletes child rows when parent is deleted. Useful for dependent data (e.g., deleting an order should delete its order_items).
- **SET NULL** – not used here except maybe if we allowed products without categories; we don’t, so we keep RESTRICT.

**Decisions:**
- `categories` → `products`: RESTRICT (cannot delete category if products exist).
- `customers` → `orders`: RESTRICT (cannot delete customer with orders unless we cascade? We choose RESTRICT to preserve history).
- `orders` → `order_items`: CASCADE (order items are meaningless without an order).
- `products` → `order_items`: RESTRICT (prevent deleting a product that has been ordered).
- `products` → `inventory`: CASCADE (inventory is dependent on product).
- `products` → `reviews`: CASCADE (reviews are dependent).
- `customers` → `reviews`: CASCADE.
- `supplier_products` uses CASCADE on both sides, because it’s a pure relationship.

### 1.2.6 Verification – Schema Completeness

We’ll double‑check that every relationship is represented:

- Category‑Product: FK `category_id` in `products`.
- Supplier‑Product: junction `supplier_products`.
- Customer‑Address: FK `customer_id` in `addresses`.
- Customer‑Order: FK `customer_id` in `orders`.
- Order‑OrderItem: FK `order_id` in `order_items`.
- Product‑OrderItem: FK `product_id` in `order_items`.
- Product‑Inventory: FK `product_id` in `inventory` (1:1 via primary key).
- Order‑Payment: FK `order_id` in `payments`.
- Product‑Review: FK `product_id` in `reviews`.
- Customer‑Review: FK `customer_id` in `reviews`.
- Category self‑reference: FK `parent_category_id` in `categories` to itself.

Everything is covered.

---

## Section 1.3 – Normalization That Makes Sense

### 1.3.1 The Target

We will now apply the **normalization rules** to our schema to eliminate redundancy, avoid update anomalies, and ensure data integrity. We’ll walk through First (1NF), Second (2NF), Third (3NF), and Boyce‑Codd (BCNF) normal forms, verifying that our design meets them.

### 1.3.2 The Concept – Why Normalize?

**Analogy:** Imagine you have a spreadsheet where you store customer orders. You list customer name and address with every order. If a customer moves, you have to update every row for that customer – that’s an **update anomaly**. If you delete the last order of a customer, you lose their address – that’s a **deletion anomaly**. Normalization organizes data into separate tables to avoid these problems.

**Normal Forms** are progressive rules:
- **1NF**: Eliminate repeating groups; each column holds atomic values, and each row is unique.
- **2NF**: Must be in 1NF and all non‑key attributes must be fully functionally dependent on the entire primary key (applies to tables with composite keys).
- **3NF**: Must be in 2NF and no transitive dependencies (non‑key attribute depends on another non‑key attribute).
- **BCNF**: A stronger version of 3NF where every determinant is a candidate key.

### 1.3.3 Checking 1NF

Our tables already satisfy 1NF:
- All columns contain atomic values (no arrays or nested structures).
- Each row is uniquely identified by a primary key (SERIAL or composite key).
- No repeating groups (e.g., we don’t have multiple phone numbers in one column; we split into separate rows if needed).

### 1.3.4 Checking 2NF

2NF only applies to tables with composite primary keys. Which tables have composite keys?
- `supplier_products` – primary key = (supplier_id, product_id). It also has `supply_price`. The supply_price depends on both supplier and product (i.e., the whole key), so it’s fully functional dependent.
- `order_items` – primary key = (order_id, product_id). It has `quantity` and `unit_price`. Both depend on the combination of order and product (the price is the historical snapshot at order time), not on only one part. So full dependency holds.

No other table has composite PK. Therefore, our design is in 2NF.

### 1.3.5 Checking 3NF

We must eliminate transitive dependencies – where a non‑key column depends on another non‑key column.

Let’s examine each table:
- `categories`: parent_category_id is a FK to the same table, but it’s not a transitive dependency (it’s a self‑reference). No non‑key column depends on another non‑key.
- `products`: category_id is a FK to categories; that’s a direct dependency on the primary key, not transitive.
- `suppliers`: all columns depend on the PK id.
- `supplier_products`: supply_price depends on the composite PK.
- `customers`: all columns depend on id.
- `addresses`: customer_id is FK, depends on id; no transitive.
- `orders`: customer_id is FK, depends on id; total_amount is derived from order items but we store it; it depends directly on order id (we compute it from items), so it’s not a transitive dependency because it’s a derived attribute but still functionally dependent on the order PK.
- `order_items`: quantity and unit_price depend on the composite PK.
- `inventory`: stock_quantity and reorder_threshold depend on product_id.
- `payments`: all depend on id.
- `reviews`: rating, comment depend on id; product_id and customer_id are FKs.

**Potential issue:** In `orders`, we have `total_amount`. It is calculated from order items. Is that a transitive dependency? It depends on the order PK, not on another non‑key column. So it’s fine. We store it for performance (denormalization, but that’s allowed if we manage it consistently). At this stage, it’s not violating 3NF because it’s directly dependent on the PK.

Thus, our schema is in 3NF.

### 1.3.6 Checking BCNF

BCNF states that for every non‑trivial functional dependency, the left‑hand side must be a superkey (i.e., a candidate key or a superset thereof). In practice, if we are in 3NF and there are no overlapping candidate keys, we are usually in BCNF. Our tables have simple candidate keys (single‑column serial IDs) except for junction tables, where the composite key is the only candidate key. No functional dependency exists where a non‑candidate key determines another column. For example, in `reviews`, we have a unique constraint on (product_id, customer_id) – that’s a candidate key as well, but we have a separate `id` as primary key. The functional dependencies are: `id` -> all, and `(product_id, customer_id)` -> all. Both left‑hand sides are candidate keys. So BCNF holds.

We are confidently normalized.

### 1.3.7 When We Might Consider Denormalization

We’ll discuss this in Section 1.7, but for now we have a fully normalized design that will serve as a solid foundation.

---

## Section 1.4 – Designing Efficient Tables

### 1.4.1 The Target

We will refine our table definitions by selecting the most appropriate **data types**, adding **default values**, **constraints**, and **indexes** (though indexes will be covered in Part 2, we’ll add a few critical ones now). We’ll also consider **storage** and **naming conventions**.

### 1.4.2 The Concept – Optimizing for Storage and Integrity

Choosing the right data type can save disk space and improve performance. For example, using `INTEGER` instead of `BIGINT` when values won’t exceed 2 billion. Using `VARCHAR(255)` instead of `TEXT` if the length is bounded. Using `TIMESTAMPTZ` (timestamp with time zone) is recommended for global applications.

**Constraints** protect data integrity: `NOT NULL`, `CHECK`, `UNIQUE`. They also help the query planner.

**Default values** reduce application code (e.g., automatic timestamps).

**Indexes** speed up lookups but add overhead on writes; we’ll create them for foreign keys and frequently queried columns.

### 1.4.3 Refining Data Types (PostgreSQL‑specific)

We’ll use PostgreSQL, so we can leverage its rich type system.

- **Primary keys**: Use `SERIAL` for auto‑incrementing integers. Alternatively, `IDENTITY` columns (PostgreSQL 10+) but we’ll stick with SERIAL for compatibility.
- **Timestamps**: Use `TIMESTAMPTZ` (alias `TIMESTAMP WITH TIME ZONE`). We’ll set default to `CURRENT_TIMESTAMP`.
- **Fixed‑precision numbers**: Use `NUMERIC(10,2)` (equivalent to DECIMAL).
- **Text**: Use `VARCHAR` with a limit where known; otherwise `TEXT`.
- **Boolean**: Use `BOOLEAN`.

**Examples**:
- `price` -> `NUMERIC(10,2) NOT NULL CHECK (price >= 0)`
- `status` -> `VARCHAR(20) NOT NULL CHECK (status IN (...))`

### 1.4.4 Adding Indexes for Foreign Keys

PostgreSQL does not automatically create indexes on foreign key columns, but it’s often beneficial for join performance. We’ll create indexes on all foreign key columns:

- `products.category_id`
- `addresses.customer_id`
- `orders.customer_id`
- `order_items.order_id`
- `order_items.product_id`
- `payments.order_id`
- `reviews.product_id`
- `reviews.customer_id`
- `supplier_products.supplier_id` and `product_id` (composite PK already acts as index)
- `categories.parent_category_id`

We’ll also create indexes on columns used in WHERE clauses often, like `products.name` (for search) and `orders.order_date` (for date range queries), but we’ll defer advanced indexing to Part 2.

### 1.4.5 Naming Conventions

Consistency is key. We’ll use snake_case for table and column names. Table names are plural (e.g., `products`, `customers`). Primary key columns are `id`. Foreign keys are named after the referenced table + `_id`. Junction tables combine both names (e.g., `supplier_products`).

### 1.4.6 Final Table Definitions (DDL Ready)

We’ll now write the final `CREATE TABLE` statements with all constraints and indexes.

---

## Section 1.5 – Implementing the Schema in PostgreSQL

### 1.5.1 The Target

We will write a complete SQL script that creates the ScaleCart database schema in PostgreSQL. We’ll execute it using `psql` or a Python script. We’ll also create a database and user.

### 1.5.2 The Concept – Running DDL

We’ll use Docker Compose to start a PostgreSQL container, then run the script. We’ll provide both manual commands and an automated setup.

### 1.5.3 Implementation – Database Setup

First, create a directory for the project and a docker-compose.yml.

**File:** `docker-compose.yml` (we already have a basic one, let’s refine it with volume for persistence and a healthcheck).

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    container_name: scalecart_postgres
    environment:
      POSTGRES_USER: scalecart
      POSTGRES_PASSWORD: scalecart_password
      POSTGRES_DB: scalecart
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d   # optional: run scripts on startup
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U scalecart"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

**File:** `.env` (optional, but we can set environment variables)

```
POSTGRES_USER=scalecart
POSTGRES_PASSWORD=scalecart_password
POSTGRES_DB=scalecart
```

Now, we’ll create the SQL script.

**File:** `init-scripts/01-schema.sql` – but we can also run it manually after container starts. Let’s do manual for learning.

### 1.5.4 Complete SQL DDL

We’ll write a single file `schema.sql` that contains all `CREATE TABLE` statements, constraints, and indexes.

**File:** `schema.sql`

```sql
-- =====================================================================
-- ScaleCart Database Schema
-- PostgreSQL 15+
-- Part 1: Foundations
-- =====================================================================

-- Enable extension for UUID (if needed) but we use SERIAL.
-- Create tables in order to respect foreign key dependencies.

-- 1. Categories (self-referencing)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INTEGER REFERENCES categories(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Suppliers
CREATE TABLE suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Products
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Supplier-Product junction
CREATE TABLE supplier_products (
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    supply_price NUMERIC(10,2) NOT NULL CHECK (supply_price >= 0),
    PRIMARY KEY (supplier_id, product_id)
);

-- 5. Customers
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    registered_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Addresses
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    street VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) NOT NULL,
    is_default_shipping BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Orders
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending','paid','shipped','delivered','cancelled')),
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

-- 8. Order Items
CREATE TABLE order_items (
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

-- 9. Inventory
CREATE TABLE inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_threshold INTEGER NOT NULL DEFAULT 10 CHECK (reorder_threshold >= 0),
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 10. Payments
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    method VARCHAR(20) NOT NULL CHECK (method IN ('credit_card','paypal','bank_transfer')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending','completed','failed')),
    payment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 11. Reviews
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, customer_id)
);

-- =====================================================================
-- Indexes for Foreign Keys and Common Queries
-- =====================================================================

-- Foreign key indexes
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_addresses_customer_id ON addresses(customer_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_categories_parent_category_id ON categories(parent_category_id);

-- Additional indexes for performance (we'll refine in Part 2)
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);  -- for text search, requires pg_trgm extension
-- We'll add more later

-- =====================================================================
-- Triggers for updated_at (optional, but we'll add a function and trigger)
-- =====================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Similarly for other tables with updated_at, but we only have updated_at on products for now.

-- =====================================================================
-- Comments (documentation)
-- =====================================================================

COMMENT ON TABLE categories IS 'Product categories with hierarchical self-reference';
COMMENT ON TABLE products IS 'Core product catalog';
COMMENT ON TABLE supplier_products IS 'Many-to-many between suppliers and products with supply price';
COMMENT ON TABLE customers IS 'Registered users';
COMMENT ON TABLE addresses IS 'Customer shipping/billing addresses';
COMMENT ON TABLE orders IS 'Customer orders';
COMMENT ON TABLE order_items IS 'Line items within an order (historical snapshot of price)';
COMMENT ON TABLE inventory IS 'Current stock levels and reorder settings';
COMMENT ON TABLE payments IS 'Payment records for orders';
COMMENT ON TABLE reviews IS 'Product reviews from customers';
```

### 1.5.5 Execution Instructions

We’ll provide two ways: using `psql` directly and using a Python script.

**Option A: Using psql inside the container**

```bash
# Start the container
docker compose up -d postgres

# Copy the schema.sql into the container
docker cp schema.sql scalecart_postgres:/schema.sql

# Execute it
docker exec -it scalecart_postgres psql -U scalecart -d scalecart -f /schema.sql
```

**Option B: Using a Python script with psycopg2** (better for later parts when we have Python code).

Create a Python script `src/scripts/create_schema.py`:

```python
# File: src/scripts/create_schema.py
import os
import psycopg2
from psycopg2 import sql

def main():
    # Read connection parameters from environment or hardcode for now
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        user="scalecart",
        password="scalecart_password",
        dbname="scalecart"
    )
    conn.autocommit = True
    cur = conn.cursor()

    # Read the schema.sql file (assume it's in the project root)
    schema_path = os.path.join(os.path.dirname(__file__), '../../schema.sql')
    with open(schema_path, 'r') as f:
        sql_script = f.read()

    # Execute the script
    cur.execute(sql_script)
    print("Schema created successfully.")

    cur.close()
    conn.close()

if __name__ == "__main__":
    main()
```

But we need to install psycopg2-binary: `pip install psycopg2-binary`. We’ll do that later.

For simplicity, we’ll use `psql` for now.

### 1.5.6 Verification

After executing the schema, we verify:

```bash
# Connect to the database
docker exec -it scalecart_postgres psql -U scalecart -d scalecart

# List all tables
\dt

# Expected output:
#                List of relations
#  Schema |      Name       | Type  |  Owner
# --------+-----------------+-------+----------
#  public | addresses       | table | scalecart
#  public | categories      | table | scalecart
#  public | customers       | table | scalecart
#  public | inventory       | table | scalecart
#  public | order_items     | table | scalecart
#  public | orders          | table | scalecart
#  public | payments        | table | scalecart
#  public | products        | table | scalecart
#  public | reviews         | table | scalecart
#  public | supplier_products| table | scalecart
#  public | suppliers       | table | scalecart
# (11 rows)

# Check constraints and indexes
\d products
# Should show indexes, check constraints, etc.

# Exit
\q
```

**All tables created successfully.**

---

## Section 1.6 – Seeding and Verification

### 1.6.1 The Target

We’ll populate the database with sample data to verify that the schema works correctly and that relationships are enforced. We’ll also run some basic queries to confirm data integrity.

### 1.6.2 The Concept – Populating with Test Data

We’ll generate INSERT statements for a small set of records covering all tables. We’ll include edge cases (e.g., hierarchical categories, multiple addresses, orders with multiple items). We’ll also test that constraints (unique, foreign key, check) are working.

### 1.6.3 Implementation – Sample Data Script

**File:** `seed_data.sql`

```sql
-- =====================================================================
-- Seed data for ScaleCart
-- =====================================================================

-- Insert categories (hierarchical)
INSERT INTO categories (name, parent_category_id) VALUES
    ('Electronics', NULL),
    ('Books', NULL),
    ('Clothing', NULL),
    ('Laptops', 1),
    ('Smartphones', 1),
    ('Fiction', 2),
    ('Non-Fiction', 2),
    ('Men''s Clothing', 3),
    ('Women''s Clothing', 3);

-- Insert suppliers
INSERT INTO suppliers (name, contact_email, phone, address) VALUES
    ('TechSupply Co.', 'info@techsupply.com', '+1-555-1234', '123 Tech St, Silicon Valley, CA'),
    ('BookWorld Distributors', 'orders@bookworld.com', '+1-555-5678', '456 Reader Ave, NY, NY'),
    ('FashionHub Inc.', 'contact@fashionhub.com', '+1-555-9012', '789 Style Blvd, LA, CA');

-- Insert products (some with descriptions)
INSERT INTO products (name, description, price, category_id) VALUES
    ('MacBook Pro 16', 'High-performance laptop with M2 Pro chip', 2499.99, 4),
    ('Dell XPS 13', 'Compact ultrabook with OLED display', 1899.99, 4),
    ('iPhone 15 Pro', 'Latest smartphone with titanium body', 1099.99, 5),
    ('Samsung Galaxy S24', 'Android flagship with AI features', 999.99, 5),
    ('The Great Gatsby', 'Classic novel by F. Scott Fitzgerald', 14.99, 6),
    ('Sapiens: A Brief History', 'Non-fiction bestseller', 19.99, 7),
    ('Levi''s 501 Jeans', 'Classic denim jeans', 69.99, 8),
    ('Nike Air Max', 'Running shoes', 129.99, 9);

-- Link suppliers to products (supply prices)
INSERT INTO supplier_products (supplier_id, product_id, supply_price) VALUES
    (1, 1, 2000.00),
    (1, 2, 1500.00),
    (1, 3, 900.00),
    (1, 4, 800.00),
    (2, 5, 10.00),
    (2, 6, 15.00),
    (3, 7, 45.00),
    (3, 8, 90.00);

-- Insert customers
INSERT INTO customers (email, password_hash, full_name) VALUES
    ('alice@example.com', 'hashed_password_1', 'Alice Johnson'),
    ('bob@example.com', 'hashed_password_2', 'Bob Smith'),
    ('carol@example.com', 'hashed_password_3', 'Carol Davis');

-- Insert addresses
INSERT INTO addresses (customer_id, street, city, state, postal_code, country, is_default_shipping) VALUES
    (1, '123 Maple St', 'Springfield', 'IL', '62701', 'USA', TRUE),
    (1, '456 Oak Ave', 'Springfield', 'IL', '62702', 'USA', FALSE),
    (2, '789 Pine Rd', 'Metropolis', 'NY', '10001', 'USA', TRUE),
    (3, '1010 Elm St', 'Gotham', 'NJ', '07001', 'USA', TRUE);

-- Insert orders
INSERT INTO orders (customer_id, status, total_amount) VALUES
    (1, 'paid', 2614.98),   -- MacBook + Gatsby
    (2, 'shipped', 999.99), -- Samsung Galaxy
    (3, 'pending', 199.98); -- Levi's + Nike

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 2499.99),
    (1, 5, 1, 14.99),
    (2, 4, 1, 999.99),
    (3, 7, 1, 69.99),
    (3, 8, 1, 129.99);

-- Insert inventory records
INSERT INTO inventory (product_id, stock_quantity, reorder_threshold) VALUES
    (1, 50, 10),
    (2, 30, 5),
    (3, 100, 20),
    (4, 75, 15),
    (5, 200, 50),
    (6, 150, 40),
    (7, 80, 20),
    (8, 60, 15);

-- Insert payments
INSERT INTO payments (order_id, amount, method, status) VALUES
    (1, 2614.98, 'credit_card', 'completed'),
    (2, 999.99, 'paypal', 'completed'),
    (3, 199.98, 'credit_card', 'pending');

-- Insert reviews
INSERT INTO reviews (product_id, customer_id, rating, comment) VALUES
    (1, 1, 5, 'Amazing laptop!'),
    (4, 2, 4, 'Good phone but battery life could be better.'),
    (7, 3, 3, 'Decent jeans, but fit is off.');
```

### 1.6.4 Executing the Seed

Run the seed script similarly:

```bash
docker cp seed_data.sql scalecart_postgres:/seed_data.sql
docker exec -it scalecart_postgres psql -U scalecart -d scalecart -f /seed_data.sql
```

### 1.6.5 Verification Queries

Now we test the data and integrity.

**Test 1: Count records**

```sql
SELECT 'categories' as table_name, COUNT(*) FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews;
```

Expected counts: categories=9, products=8, suppliers=3, customers=3, orders=3, order_items=5, inventory=8, payments=3, reviews=3.

**Test 2: Join to verify relationships**

```sql
-- Get all orders with customer name
SELECT o.id, c.full_name, o.order_date, o.status, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.id;

-- Get order items with product names and order info
SELECT o.id as order_id, p.name as product, oi.quantity, oi.unit_price
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id;

-- Get products with their categories
SELECT p.name, c.name as category
FROM products p
JOIN categories c ON p.category_id = c.id;

-- Get average rating per product
SELECT p.name, AVG(r.rating) as avg_rating
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id;
```

**Test 3: Constraint validation**

Try inserting an invalid order status:

```sql
-- This should fail
INSERT INTO orders (customer_id, status, total_amount) VALUES (1, 'invalid_status', 10.00);
-- Expected error: check constraint violation
```

Try inserting a product with negative price:

```sql
-- Should fail
INSERT INTO products (name, price, category_id) VALUES ('Invalid', -5.00, 1);
-- Expected: CHECK constraint violation
```

Try inserting a duplicate email:

```sql
-- Should fail
INSERT INTO customers (email, password_hash, full_name) VALUES ('alice@example.com', 'hash', 'Alice Again');
-- Expected: unique constraint violation
```

If all these pass, our schema is correctly enforcing data integrity.

---

## Section 1.7 – When and Why to Denormalize (Expert Insight)

### 1.7.1 The Target

We discuss scenarios where experienced engineers intentionally denormalize – i.e., store redundant data or combine tables – to improve read performance, simplify queries, or support specific use cases. We’ll also discuss the trade‑offs.

### 1.7.2 The Concept – Performance vs. Integrity

Normalization minimizes redundancy and ensures consistency, but it often requires more joins, which can slow down queries. In high‑read, low‑write scenarios, denormalization can reduce query complexity and improve speed. However, it introduces update anomalies that must be managed carefully (e.g., through application logic or database triggers).

**Common denormalization techniques:**
- Storing computed aggregates (e.g., order total in the orders table – we already do this).
- Adding redundant columns to avoid joins (e.g., storing category name in product table, but that’s usually not recommended if category name changes often).
- Creating summary tables for reporting (e.g., daily sales rollups).
- Using materialized views.

### 1.7.3 When to Consider in ScaleCart

- **Order total:** We store `total_amount` to avoid summing order items every time we display an order. This is a classic denormalization. We must ensure it’s updated when order items change (using triggers or application logic). We already have it, and we can rely on application code to keep it consistent.
- **Product rating:** We might store an `avg_rating` in the products table to avoid recalculating from reviews. That’s another candidate.
- **Category path:** For hierarchical categories, we might store a path string (e.g., "Electronics/Laptops") for easier querying, but that’s complex to maintain.
- **Inventory stock with product info:** We keep inventory separate, but we could join often. For high‑traffic product listings, we might consider caching or materialized views.

**We will revisit denormalization in Part 2 when we discuss performance tuning.** For now, our normalized design is correct and maintainable.

---

## Section 1.8 – Summary and Exercises

### 1.8.1 What We Accomplished

In this part, we:
- Extracted business requirements and built an ERD.
- Translated the ERD into a relational schema.
- Applied normalization (1NF, 2NF, 3NF, BCNF) and verified our design.
- Designed efficient tables with appropriate data types, constraints, and indexes.
- Implemented the schema in PostgreSQL and verified it with sample data.
- Discussed denormalization as a future optimization.

You now have a production‑ready database foundation for ScaleCart that can handle millions of records with integrity.

### 1.8.2 Exercises (Optional but Recommended)

1. **Add a new table** for `warehouses` and link inventory to warehouses (one product can have stock in multiple warehouses). Update the ERD and schema accordingly. Write the DDL and test.

2. **Implement a trigger** that automatically updates `orders.total_amount` when an order item is inserted, updated, or deleted. Write the PL/pgSQL function and trigger.

3. **Write a query** that finds the top 5 best‑selling products (by quantity) in the last 30 days. Use the existing seed data (you may add more orders).

4. **Add a check constraint** to ensure that an order cannot have a status of 'shipped' without having at least one payment with status 'completed'. (This may be better in application logic, but try a database trigger.)

5. **Explore the `pg_stat_statements`** extension to start monitoring query performance. We’ll cover this in Part 2.

### 1.8.3 Next Steps

In **Part 2 – SQL Performance & Advanced Database Optimization**, we will:
- Dive into the query optimizer and execution plans.
- Implement advanced indexing strategies (B‑Tree, GiST, GIN, BRIN, full‑text).
- Learn to balance read/write performance.
- Scale to 100 million records using partitioning and sharding.

**We are ready for Part 2.**

