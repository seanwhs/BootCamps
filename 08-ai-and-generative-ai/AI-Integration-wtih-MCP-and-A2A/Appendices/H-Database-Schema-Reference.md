# Appendix H: Database Schema Reference

## Overview

This appendix provides comprehensive database schema documentation for all database components built throughout the tutorial series. It includes table definitions, relationships, indexes, and sample data for both SQLite and PostgreSQL implementations.

---

## Part 1: SQLite Database Schema

### Database: `app.db`

**Location:** `./data/app.db` (configurable via `DB_PATH` environment variable)

**Version:** 1.0.0

---

### Table: `users`

Stores user account information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique user identifier |
| `name` | TEXT | NOT NULL | User's full name |
| `email` | TEXT | UNIQUE, NOT NULL | User's email address |
| `age` | INTEGER | | User's age (optional) |
| `created_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| `updated_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_users_email` on `email` (unique)

**Sample Data:**
```sql
INSERT INTO users (name, email, age) VALUES
  ('Alice Johnson', 'alice@example.com', 30),
  ('Bob Smith', 'bob@example.com', 25),
  ('Charlie Brown', 'charlie@example.com', 35),
  ('Diana Ross', 'diana@example.com', 28),
  ('Eve Wilson', 'eve@example.com', 32);
```

---

### Table: `products`

Stores product catalog information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique product identifier |
| `name` | TEXT | NOT NULL | Product name |
| `description` | TEXT | | Product description |
| `price` | REAL | NOT NULL | Product price |
| `category` | TEXT | | Product category |
| `stock` | INTEGER | DEFAULT 0 | Available stock quantity |
| `created_at` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Sample Data:**
```sql
INSERT INTO products (name, description, price, category, stock) VALUES
  ('Laptop Pro', 'High-performance laptop with 16GB RAM', 1299.99, 'Electronics', 50),
  ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'Accessories', 200),
  ('USB-C Hub', '7-in-1 USB-C hub with HDMI', 49.99, 'Accessories', 150),
  ('Monitor 27"', '4K UHD Monitor', 399.99, 'Electronics', 30),
  ('Keyboard', 'Mechanical gaming keyboard', 89.99, 'Accessories', 75);
```

---

### Table: `orders`

Stores customer orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique order identifier |
| `user_id` | INTEGER | NOT NULL, FOREIGN KEY → users(id) | Customer who placed the order |
| `order_date` | DATETIME | DEFAULT CURRENT_TIMESTAMP | Order creation timestamp |
| `total` | REAL | NOT NULL | Order total amount |
| `status` | TEXT | DEFAULT 'pending' | Order status |

**Indexes:**
- `idx_orders_user_id` on `user_id`

**Sample Data:**
```sql
INSERT INTO orders (user_id, total, status) VALUES
  (1, 1329.98, 'completed'),
  (2, 79.98, 'pending'),
  (3, 449.98, 'shipped'),
  (1, 89.99, 'pending'),
  (4, 1299.99, 'completed');
```

---

### Table: `order_items`

Stores individual items within orders.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY, AUTOINCREMENT | Unique item identifier |
| `order_id` | INTEGER | NOT NULL, FOREIGN KEY → orders(id) | Parent order |
| `product_id` | INTEGER | NOT NULL, FOREIGN KEY → products(id) | Product ordered |
| `quantity` | INTEGER | NOT NULL | Quantity ordered |
| `price` | REAL | NOT NULL | Price at time of order |

**Indexes:**
- `idx_order_items_order_id` on `order_id`
- `idx_order_items_product_id` on `product_id`

**Sample Data:**
```sql
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  (1, 1, 1, 1299.99),
  (1, 2, 1, 29.99),
  (2, 2, 2, 29.99),
  (2, 3, 1, 49.99),
  (3, 4, 1, 399.99),
  (3, 2, 1, 29.99),
  (4, 5, 1, 89.99),
  (5, 1, 1, 1299.99);
```

---

## Part 2: PostgreSQL Schema

### Database: `postgres`

**Default Schema:** `public`

**Extensions:**
- `pg_stat_statements` — Query performance monitoring
- `uuid-ossp` — UUID generation
- `pgcrypto` — Cryptographic functions

---

### Table: `users`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Unique user identifier |
| `name` | VARCHAR(255) | NOT NULL | User's full name |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User's email address |
| `age` | INTEGER | CHECK (age >= 0 AND age <= 150) | User's age |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_users_email` on `email` (UNIQUE)
- `idx_users_age` on `age`

**Triggers:**
- `update_users_updated_at` — Updates `updated_at` on row update

**Sample Data:**
```sql
INSERT INTO users (name, email, age) VALUES
  ('Alice Johnson', 'alice@example.com', 30),
  ('Bob Smith', 'bob@example.com', 25),
  ('Charlie Brown', 'charlie@example.com', 35),
  ('Diana Ross', 'diana@example.com', 28),
  ('Eve Wilson', 'eve@example.com', 32);
```

---

### Table: `products`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Unique product identifier |
| `sku` | VARCHAR(50) | UNIQUE, NOT NULL | Stock Keeping Unit |
| `name` | VARCHAR(255) | NOT NULL | Product name |
| `description` | TEXT | | Product description |
| `price` | DECIMAL(10,2) | NOT NULL, CHECK (price >= 0) | Product price |
| `category` | VARCHAR(100) | | Product category |
| `stock` | INTEGER | DEFAULT 0, CHECK (stock >= 0) | Available stock quantity |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_products_sku` on `sku` (UNIQUE)
- `idx_products_category` on `category`
- `idx_products_price` on `price`

**Sample Data:**
```sql
INSERT INTO products (sku, name, description, price, category, stock) VALUES
  ('LAP-001', 'Laptop Pro', 'High-performance laptop with 16GB RAM', 1299.99, 'Electronics', 50),
  ('MOU-002', 'Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'Accessories', 200),
  ('HUB-003', 'USB-C Hub', '7-in-1 USB-C hub with HDMI', 49.99, 'Accessories', 150),
  ('MON-004', 'Monitor 27"', '4K UHD Monitor', 399.99, 'Electronics', 30),
  ('KEY-005', 'Keyboard', 'Mechanical gaming keyboard', 89.99, 'Accessories', 75);
```

---

### Table: `orders`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Unique order identifier |
| `order_number` | VARCHAR(20) | UNIQUE, NOT NULL | Human-readable order number |
| `user_id` | INTEGER | NOT NULL, FOREIGN KEY → users(id) | Customer who placed the order |
| `order_date` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Order creation timestamp |
| `total` | DECIMAL(10,2) | NOT NULL, CHECK (total >= 0) | Order total amount |
| `status` | VARCHAR(20) | DEFAULT 'pending' | Order status |
| `shipping_address` | TEXT | | Shipping address |
| `billing_address` | TEXT | | Billing address |
| `payment_method` | VARCHAR(50) | | Payment method |
| `payment_status` | VARCHAR(20) | DEFAULT 'pending' | Payment status |
| `notes` | TEXT | | Order notes |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- `idx_orders_user_id` on `user_id`
- `idx_orders_order_number` on `order_number` (UNIQUE)
- `idx_orders_status` on `status`
- `idx_orders_order_date` on `order_date`

**Enum Types:**
```sql
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');
```

**Sample Data:**
```sql
INSERT INTO orders (order_number, user_id, total, status, shipping_address, payment_method, payment_status) VALUES
  ('ORD-2024-0001', 1, 1329.98, 'delivered', '123 Main St, City, State 12345', 'credit_card', 'paid'),
  ('ORD-2024-0002', 2, 79.98, 'pending', '456 Oak Ave, City, State 12345', 'paypal', 'pending'),
  ('ORD-2024-0003', 3, 449.98, 'shipped', '789 Pine St, City, State 12345', 'credit_card', 'paid'),
  ('ORD-2024-0004', 1, 89.99, 'pending', '123 Main St, City, State 12345', 'credit_card', 'pending'),
  ('ORD-2024-0005', 4, 1299.99, 'delivered', '321 Elm St, City, State 12345', 'paypal', 'paid');
```

---

### Table: `order_items`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Unique item identifier |
| `order_id` | INTEGER | NOT NULL, FOREIGN KEY → orders(id) ON DELETE CASCADE | Parent order |
| `product_id` | INTEGER | NOT NULL, FOREIGN KEY → products(id) | Product ordered |
| `quantity` | INTEGER | NOT NULL, CHECK (quantity > 0) | Quantity ordered |
| `unit_price` | DECIMAL(10,2) | NOT NULL, CHECK (unit_price >= 0) | Price at time of order |
| `total_price` | DECIMAL(10,2) | NOT NULL, CHECK (total_price >= 0) | Quantity × Unit Price |
| `discount` | DECIMAL(10,2) | DEFAULT 0, CHECK (discount >= 0) | Discount applied |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_order_items_order_id` on `order_id`
- `idx_order_items_product_id` on `product_id`

**Sample Data:**
```sql
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
  (1, 1, 1, 1299.99, 1299.99),
  (1, 2, 1, 29.99, 29.99),
  (2, 2, 2, 29.99, 59.98),
  (2, 3, 1, 49.99, 49.99),
  (3, 4, 1, 399.99, 399.99),
  (3, 2, 1, 29.99, 29.99),
  (4, 5, 1, 89.99, 89.99),
  (5, 1, 1, 1299.99, 1299.99);
```

---

### Table: `categories`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Unique category identifier |
| `name` | VARCHAR(100) | UNIQUE, NOT NULL | Category name |
| `slug` | VARCHAR(100) | UNIQUE, NOT NULL | URL-friendly category name |
| `description` | TEXT | | Category description |
| `parent_id` | INTEGER | FOREIGN KEY → categories(id) | Parent category (for hierarchies) |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_categories_slug` on `slug` (UNIQUE)
- `idx_categories_parent_id` on `parent_id`

**Sample Data:**
```sql
INSERT INTO categories (name, slug, description) VALUES
  ('Electronics', 'electronics', 'Electronic devices and accessories'),
  ('Accessories', 'accessories', 'Computer and phone accessories'),
  ('Computers', 'computers', 'Computer hardware'),
  ('Software', 'software', 'Software products');
```

---

### Table: `audit_log`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | SERIAL | PRIMARY KEY | Unique audit entry |
| `user_id` | INTEGER | FOREIGN KEY → users(id) | User who performed action |
| `action` | VARCHAR(50) | NOT NULL | Action performed |
| `table_name` | VARCHAR(50) | | Table affected |
| `record_id` | INTEGER | | Record affected |
| `old_values` | JSONB | | Previous values (before change) |
| `new_values` | JSONB | | New values (after change) |
| `ip_address` | INET | | Client IP address |
| `user_agent` | TEXT | | Client user agent |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |

**Indexes:**
- `idx_audit_log_user_id` on `user_id`
- `idx_audit_log_action` on `action`
- `idx_audit_log_created_at` on `created_at`

---

## Part 3: Database Views

### View: `order_summary`

Provides a summary of order information.

```sql
CREATE VIEW order_summary AS
SELECT 
  o.id,
  o.order_number,
  u.name as customer_name,
  u.email as customer_email,
  o.total,
  o.status,
  o.order_date,
  COUNT(oi.id) as item_count,
  SUM(oi.quantity) as total_items,
  o.shipping_address
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, o.order_number, u.name, u.email, o.total, o.status, o.order_date, o.shipping_address;
```

### View: `product_performance`

Analyzes product sales performance.

```sql
CREATE VIEW product_performance AS
SELECT 
  p.id,
  p.name,
  p.sku,
  p.category,
  COUNT(oi.id) as times_ordered,
  SUM(oi.quantity) as total_sold,
  SUM(oi.total_price) as total_revenue,
  AVG(oi.unit_price) as avg_selling_price,
  MAX(o.order_date) as last_sold_date
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.id, p.name, p.sku, p.category;
```

### View: `customer_lifetime_value`

Calculates customer lifetime value.

```sql
CREATE VIEW customer_lifetime_value AS
SELECT 
  u.id,
  u.name,
  u.email,
  COUNT(DISTINCT o.id) as order_count,
  SUM(o.total) as total_spent,
  AVG(o.total) as avg_order_value,
  MIN(o.order_date) as first_order,
  MAX(o.order_date) as last_order,
  EXTRACT(DAY FROM (MAX(o.order_date) - MIN(o.order_date))) / 365 as customer_lifetime_years
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY u.id, u.name, u.email;
```

---

## Part 4: Stored Procedures

### PostgreSQL

```sql
-- Get order statistics by user
CREATE OR REPLACE FUNCTION get_user_order_stats(p_user_id INTEGER)
RETURNS TABLE(
  total_orders BIGINT,
  total_spent DECIMAL(10,2),
  avg_order_value DECIMAL(10,2),
  last_order_date TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::BIGINT,
    COALESCE(SUM(total), 0),
    COALESCE(AVG(total), 0),
    MAX(order_date)
  FROM orders
  WHERE user_id = p_user_id
    AND status NOT IN ('cancelled', 'refunded');
END;
$$ LANGUAGE plpgsql;

-- Update product stock after order
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET stock = stock - NEW.quantity
  WHERE id = NEW.product_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();
```

---

## Part 5: SQLite Schema Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         SQLite Schema                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────┐       │
│  │                      users                          │       │
│  │  ┌─────────────────────────────────────────────┐   │       │
│  │  │  id         │ INTEGER  │ PRIMARY KEY       │   │       │
│  │  │  name       │ TEXT     │ NOT NULL          │   │       │
│  │  │  email      │ TEXT     │ UNIQUE, NOT NULL  │   │       │
│  │  │  age        │ INTEGER  │                   │   │       │
│  │  │  created_at │ DATETIME │ DEFAULT CURR...   │   │       │
│  │  │  updated_at │ DATETIME │ DEFAULT CURR...   │   │       │
│  │  └─────────────────────────────────────────────┘   │       │
│  └──────────────────────┬──────────────────────────────┘       │
│                         │                                      │
│                         │ 1                                    │
│                         │                                      │
│                         │ many                                 │
│  ┌──────────────────────▼──────────────────────────────┐       │
│  │                      orders                         │       │
│  │  ┌─────────────────────────────────────────────┐   │       │
│  │  │  id         │ INTEGER  │ PRIMARY KEY       │   │       │
│  │  │  user_id    │ INTEGER  │ FOREIGN KEY       │   │       │
│  │  │  order_date │ DATETIME │ DEFAULT CURR...   │   │       │
│  │  │  total      │ REAL     │ NOT NULL          │   │       │
│  │  │  status     │ TEXT     │ DEFAULT 'pending' │   │       │
│  │  └─────────────────────────────────────────────┘   │       │
│  └──────────────────────┬──────────────────────────────┘       │
│                         │                                      │
│                         │ 1                                    │
│                         │                                      │
│                         │ many                                 │
│  ┌──────────────────────▼──────────────────────────────┐       │
│  │                    order_items                      │       │
│  │  ┌─────────────────────────────────────────────┐   │       │
│  │  │  id         │ INTEGER  │ PRIMARY KEY       │   │       │
│  │  │  order_id   │ INTEGER  │ FOREIGN KEY       │   │       │
│  │  │  product_id │ INTEGER  │ FOREIGN KEY       │   │       │
│  │  │  quantity   │ INTEGER  │ NOT NULL          │   │       │
│  │  │  price      │ REAL     │ NOT NULL          │   │       │
│  │  └─────────────────────────────────────────────┘   │       │
│  └──────────────────────┬──────────────────────────────┘       │
│                         │                                      │
│                         │ many                                 │
│                         │                                      │
│                         │ 1                                    │
│  ┌──────────────────────▼──────────────────────────────┐       │
│  │                    products                         │       │
│  │  ┌─────────────────────────────────────────────┐   │       │
│  │  │  id         │ INTEGER  │ PRIMARY KEY       │   │       │
│  │  │  name       │ TEXT     │ NOT NULL          │   │       │
│  │  │  description│ TEXT     │                   │   │       │
│  │  │  price      │ REAL     │ NOT NULL          │   │       │
│  │  │  category   │ TEXT     │                   │   │       │
│  │  │  stock      │ INTEGER  │ DEFAULT 0         │   │       │
│  │  │  created_at │ DATETIME │ DEFAULT CURR...   │   │       │
│  │  └─────────────────────────────────────────────┘   │       │
│  └──────────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Part 6: PostgreSQL Schema Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PostgreSQL Schema                                  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                            users                                     │  │
│  │  ┌──────────────────────────────────────────────────────────────┐   │  │
│  │  │  id              │ SERIAL        │ PRIMARY KEY              │   │  │
│  │  │  name            │ VARCHAR(255)  │ NOT NULL                 │   │  │
│  │  │  email           │ VARCHAR(255)  │ UNIQUE, NOT NULL         │   │  │
│  │  │  age             │ INTEGER       │ CHECK(age >= 0)          │   │  │
│  │  │  created_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  │  updated_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  └──────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────┬────────────────────────────────────────┘  │
│                                │                                           │
│                                │ 1                                         │
│                                │                                           │
│                                │ many                                      │
│  ┌─────────────────────────────▼────────────────────────────────────────┐  │
│  │                            orders                                     │  │
│  │  ┌──────────────────────────────────────────────────────────────┐   │  │
│  │  │  id              │ SERIAL        │ PRIMARY KEY              │   │  │
│  │  │  order_number    │ VARCHAR(20)   │ UNIQUE, NOT NULL         │   │  │
│  │  │  user_id         │ INTEGER       │ FOREIGN KEY              │   │  │
│  │  │  order_date      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  │  total           │ DECIMAL(10,2) │ NOT NULL, CHECK >= 0     │   │  │
│  │  │  status          │ VARCHAR(20)   │ DEFAULT 'pending'        │   │  │
│  │  │  shipping_address│ TEXT          │                           │   │  │
│  │  │  billing_address │ TEXT          │                           │   │  │
│  │  │  payment_method  │ VARCHAR(50)   │                           │   │  │
│  │  │  payment_status  │ VARCHAR(20)   │ DEFAULT 'pending'        │   │  │
│  │  │  notes           │ TEXT          │                           │   │  │
│  │  │  created_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  │  updated_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  └──────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────┬────────────────────────────────────────┘  │
│                                │                                           │
│                                │ 1                                         │
│                                │                                           │
│                                │ many                                      │
│  ┌─────────────────────────────▼────────────────────────────────────────┐  │
│  │                          order_items                                  │  │
│  │  ┌──────────────────────────────────────────────────────────────┐   │  │
│  │  │  id              │ SERIAL        │ PRIMARY KEY              │   │  │
│  │  │  order_id        │ INTEGER       │ FOREIGN KEY              │   │  │
│  │  │  product_id      │ INTEGER       │ FOREIGN KEY              │   │  │
│  │  │  quantity        │ INTEGER       │ NOT NULL, CHECK > 0      │   │  │
│  │  │  unit_price      │ DECIMAL(10,2) │ NOT NULL, CHECK >= 0     │   │  │
│  │  │  total_price     │ DECIMAL(10,2) │ NOT NULL, CHECK >= 0     │   │  │
│  │  │  discount        │ DECIMAL(10,2) │ DEFAULT 0, CHECK >= 0    │   │  │
│  │  │  created_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  └──────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────┬────────────────────────────────────────┘  │
│                                │                                           │
│                                │ many                                      │
│                                │                                           │
│                                │ 1                                         │
│  ┌─────────────────────────────▼────────────────────────────────────────┐  │
│  │                           products                                    │  │
│  │  ┌──────────────────────────────────────────────────────────────┐   │  │
│  │  │  id              │ SERIAL        │ PRIMARY KEY              │   │  │
│  │  │  sku             │ VARCHAR(50)   │ UNIQUE, NOT NULL         │   │  │
│  │  │  name            │ VARCHAR(255)  │ NOT NULL                 │   │  │
│  │  │  description     │ TEXT          │                           │   │  │
│  │  │  price           │ DECIMAL(10,2) │ NOT NULL, CHECK >= 0     │   │  │
│  │  │  category        │ VARCHAR(100)  │                           │   │  │
│  │  │  stock           │ INTEGER       │ DEFAULT 0, CHECK >= 0    │   │  │
│  │  │  created_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  │  updated_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  └──────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                           categories                                 │  │
│  │  ┌──────────────────────────────────────────────────────────────┐   │  │
│  │  │  id              │ SERIAL        │ PRIMARY KEY              │   │  │
│  │  │  name            │ VARCHAR(100)  │ UNIQUE, NOT NULL         │   │  │
│  │  │  slug            │ VARCHAR(100)  │ UNIQUE, NOT NULL         │   │  │
│  │  │  description     │ TEXT          │                           │   │  │
│  │  │  parent_id       │ INTEGER       │ FOREIGN KEY              │   │  │
│  │  │  created_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  └──────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │                           audit_log                                  │  │
│  │  ┌──────────────────────────────────────────────────────────────┐   │  │
│  │  │  id              │ SERIAL        │ PRIMARY KEY              │   │  │
│  │  │  user_id         │ INTEGER       │ FOREIGN KEY              │   │  │
│  │  │  action          │ VARCHAR(50)   │ NOT NULL                 │   │  │
│  │  │  table_name      │ VARCHAR(50)   │                           │   │  │
│  │  │  record_id       │ INTEGER       │                           │   │  │
│  │  │  old_values      │ JSONB         │                           │   │  │
│  │  │  new_values      │ JSONB         │                           │   │  │
│  │  │  ip_address      │ INET          │                           │   │  │
│  │  │  user_agent      │ TEXT          │                           │   │  │
│  │  │  created_at      │ TIMESTAMP     │ DEFAULT CURRENT_TIMESTAMP │   │  │
│  │  └──────────────────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 7: Database Query Examples

### SQLite Query Examples

```sql
-- Get all users with their order count
SELECT 
  u.id,
  u.name,
  u.email,
  COUNT(o.id) as order_count,
  COALESCE(SUM(o.total), 0) as total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email
ORDER BY total_spent DESC;

-- Get top 5 products by sales
SELECT 
  p.id,
  p.name,
  p.category,
  SUM(oi.quantity) as total_sold,
  SUM(oi.quantity * oi.price) as total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.category
ORDER BY total_revenue DESC
LIMIT 5;

-- Get monthly order statistics
SELECT 
  strftime('%Y-%m', order_date) as month,
  COUNT(*) as order_count,
  SUM(total) as total_revenue,
  AVG(total) as avg_order_value
FROM orders
WHERE status != 'cancelled'
GROUP BY month
ORDER BY month DESC;
```

### PostgreSQL Query Examples

```sql
-- Get user lifetime value with percentile ranking
SELECT 
  u.id,
  u.name,
  u.email,
  SUM(o.total) as total_spent,
  COUNT(o.id) as order_count,
  NTILE(4) OVER (ORDER BY SUM(o.total) DESC) as quartile
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY u.id, u.name, u.email
ORDER BY total_spent DESC;

-- Find products that are frequently bought together
SELECT 
  a.product_id as product_a,
  b.product_id as product_b,
  COUNT(*) as times_bought_together
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY times_bought_together DESC
LIMIT 10;

-- Get order fulfillment statistics
SELECT 
  status,
  COUNT(*) as count,
  AVG(EXTRACT(EPOCH FROM (updated_at - order_date))) / 3600 as avg_hours_to_complete
FROM orders
WHERE status IN ('delivered', 'cancelled', 'refunded')
GROUP BY status;
```

---

## Part 8: Database Migration Scripts

### SQLite Migration Template

```sql
-- Migration: create_tables
-- Version: 1.0.0
-- Description: Initial schema creation

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  age INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  price REAL NOT NULL,
  category TEXT,
  stock INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  total REAL NOT NULL,
  status TEXT DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  price REAL NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

COMMIT;
```

### PostgreSQL Migration Template

```sql
-- Migration: create_tables
-- Version: 1.0.0
-- Description: Initial schema creation

BEGIN;

-- Create ENUM types
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

-- Create tables
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  age INTEGER CHECK (age >= 0 AND age <= 150),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  sku VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  category VARCHAR(100),
  stock INTEGER DEFAULT 0 CHECK (stock >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  order_number VARCHAR(20) UNIQUE NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id),
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  status order_status DEFAULT 'pending',
  shipping_address TEXT,
  billing_address TEXT,
  payment_method VARCHAR(50),
  payment_status payment_status DEFAULT 'pending',
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

COMMIT;
```

---

## Part 9: Database Seed Scripts

### SQLite Seed Script

```typescript
// seed-db.ts
import { getConnectionManager } from '../db/connection-manager.js';

async function seedDatabase() {
  const db = getConnectionManager();
  await db.initialize();

  console.log('Seeding database...');

  // Seed users
  await db.executeQuery(`
    INSERT OR IGNORE INTO users (name, email, age) VALUES
      ('Alice Johnson', 'alice@example.com', 30),
      ('Bob Smith', 'bob@example.com', 25),
      ('Charlie Brown', 'charlie@example.com', 35),
      ('Diana Ross', 'diana@example.com', 28),
      ('Eve Wilson', 'eve@example.com', 32)
  `);

  // Seed products
  await db.executeQuery(`
    INSERT OR IGNORE INTO products (name, description, price, category, stock) VALUES
      ('Laptop Pro', 'High-performance laptop with 16GB RAM', 1299.99, 'Electronics', 50),
      ('Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'Accessories', 200),
      ('USB-C Hub', '7-in-1 USB-C hub with HDMI', 49.99, 'Accessories', 150),
      ('Monitor 27"', '4K UHD Monitor', 399.99, 'Electronics', 30),
      ('Keyboard', 'Mechanical gaming keyboard', 89.99, 'Accessories', 75)
  `);

  console.log('Database seeded successfully!');
}

await seedDatabase();
```

---

## Part 10: Database Backup and Restore

### SQLite Backup Script

```bash
#!/bin/bash
# backup-sqlite.sh

DB_PATH=${1:-"./data/app.db"}
BACKUP_DIR=${2:-"./backups"}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP.db"

mkdir -p "$BACKUP_DIR"

# Create backup using SQLite backup API
sqlite3 "$DB_PATH" ".backup '$BACKUP_PATH'"

# Compress backup
gzip "$BACKUP_PATH"

echo "Backup created: $BACKUP_PATH.gz"
```

### PostgreSQL Backup Script

```bash
#!/bin/bash
# backup-postgres.sh

DB_NAME=${POSTGRES_DATABASE:-"postgres"}
DB_USER=${POSTGRES_USER:-"postgres"}
DB_HOST=${POSTGRES_HOST:-"localhost"}
DB_PORT=${POSTGRES_PORT:-"5432"}
BACKUP_DIR=${1:-"./backups"}
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

# Create backup using pg_dump
PGPASSWORD=$POSTGRES_PASSWORD pg_dump \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -F p \
  -f "$BACKUP_PATH"

# Compress backup
gzip "$BACKUP_PATH"

echo "Backup created: $BACKUP_PATH.gz"
```

---

This appendix serves as a complete reference for all database schemas used in the tutorial series. Use it when designing your own database schemas, writing queries, or performing database maintenance.
