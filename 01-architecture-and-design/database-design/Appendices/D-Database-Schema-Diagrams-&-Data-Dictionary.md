# APPENDIX D — Database Schema Diagrams & Data Dictionary

## Complete Reference for ScaleCart Data Model

---

## D.1 Introduction

This appendix provides a comprehensive reference for the ScaleCart database schema, including:

1. **Entity-Relationship Diagrams (ERD)** – Visual representation of all tables and relationships
2. **Data Dictionary** – Complete description of every table, column, constraint, and index
3. **Relationship Matrix** – All foreign key relationships and their meanings
4. **Sample Queries** – Common query patterns with explanations
5. **Migration History** – Evolution of the schema

---

## D.2 Complete Entity-Relationship Diagram

### D.2.1 Text-Based ERD (Simplified)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SCALECART DATABASE SCHEMA                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐                                                          │
│  │  categories  │                                                          │
│  ├──────────────┤                                                          │
│  │ id (PK)      │◄───────────────────────┐                                 │
│  │ name         │                         │                                 │
│  │ parent_id (FK)├────────────────────────┘                                 │
│  │ description  │                         │                                 │
│  │ created_at   │                         │                                 │
│  └──────┬───────┘                         │                                 │
│         │                                 │                                 │
│         │ 1:N                             │                                 │
│         ▼                                 │                                 │
│  ┌──────────────┐                         │                                 │
│  │   products   │                         │                                 │
│  ├──────────────┤                         │                                 │
│  │ id (PK)      │                         │                                 │
│  │ name         │                         │                                 │
│  │ description  │                         │                                 │
│  │ price        │                         │                                 │
│  │ category_id  │───┐                     │                                 │
│  │ weight_kg    │   │                     │                                 │
│  │ sku          │   │                     │                                 │
│  │ search_vector│   │   ┌─────────────┐   │                                 │
│  │ created_at   │   │   │  suppliers  │   │                                 │
│  │ updated_at   │   │   ├─────────────┤   │                                 │
│  └──────┬───────┘   │   │ id (PK)     │   │                                 │
│         │           │   │ name        │   │                                 │
│         │           │   │ contact_email│  │                                 │
│         │           │   │ phone       │   │                                 │
│         │           │   │ address     │   │                                 │
│         │           │   │ created_at  │   │                                 │
│         │           │   └─────────────┘   │                                 │
│         │           │          │          │                                 │
│         │           │          │          │                                 │
│         │           │   ┌──────┴──────┐   │                                 │
│         │           │   │ supplier_   │   │                                 │
│         │           │   │  products   │   │                                 │
│         │           │   ├─────────────┤   │                                 │
│         │           └───┤ supplier_id │   │                                 │
│         │               │ product_id  │   │                                 │
│         │               │ supply_price│   │                                 │
│         │               │ is_preferred│   │                                 │
│         │               │ created_at  │   │                                 │
│         │               └─────────────┘   │                                 │
│         │                                 │                                 │
│         │ 1:N                             │                                 │
│         ▼                                 │                                 │
│  ┌──────────────┐                         │                                 │
│  │   inventory  │                         │                                 │
│  ├──────────────┤                         │                                 │
│  │ product_id   │───┐                     │                                 │
│  │ stock_qty    │   │                     │                                 │
│  │ reserved_qty │   │                     │                                 │
│  │ reorder_thr  │   │                     │                                 │
│  │ reorder_qty  │   │                     │                                 │
│  │ last_updated │   │                     │                                 │
│  └──────────────┘   │                     │                                 │
│                     │                     │                                 │
│                     │                     │                                 │
│  ┌──────────────┐   │                     │                                 │
│  │  customers   │   │                     │                                 │
│  ├──────────────┤   │                     │                                 │
│  │ id (PK)      │   │                     │                                 │
│  │ email        │   │                     │                                 │
│  │ password_hash│   │                     │                                 │
│  │ full_name    │   │                     │                                 │
│  │ phone        │   │                     │                                 │
│  │ registered_at│   │                     │                                 │
│  │ last_login   │   │                     │                                 │
│  │ is_active    │   │                     │                                 │
│  │ is_verified  │   │                     │                                 │
│  │ version      │   │                     │                                 │
│  │ created_at   │   │                     │                                 │
│  │ updated_at   │   │                     │                                 │
│  └──────┬───────┘   │                     │                                 │
│         │           │                     │                                 │
│         │ 1:N       │                     │                                 │
│         ▼           │                     │                                 │
│  ┌──────────────┐   │                     │                                 │
│  │  addresses   │   │                     │                                 │
│  ├──────────────┤   │                     │                                 │
│  │ id (PK)      │   │                     │                                 │
│  │ customer_id  │───┘                     │                                 │
│  │ address_type │                         │                                 │
│  │ street       │                         │                                 │
│  │ city         │                         │                                 │
│  │ state        │                         │                                 │
│  │ postal_code  │                         │                                 │
│  │ country      │                         │                                 │
│  │ is_default   │                         │                                 │
│  │ created_at   │                         │                                 │
│  │ updated_at   │                         │                                 │
│  └──────────────┘                         │                                 │
│                                            │                                 │
│  ┌──────────────┐                         │                                 │
│  │    orders    │                         │                                 │
│  ├──────────────┤                         │                                 │
│  │ id (PK)      │                         │                                 │
│  │ customer_id  │───┐                     │                                 │
│  │ order_date   │   │                     │                                 │
│  │ status       │   │                     │                                 │
│  │ total_amount │   │                     │                                 │
│  │ shipping_addr│   │                     │                                 │
│  │ billing_addr │   │                     │                                 │
│  │ notes        │   │                     │                                 │
│  │ created_at   │   │                     │                                 │
│  │ updated_at   │   │                     │                                 │
│  └──────┬───────┘   │                     │                                 │
│         │           │                     │                                 │
│         │ 1:N       │                     │                                 │
│         ▼           │                     │                                 │
│  ┌──────────────┐   │                     │                                 │
│  │ order_items  │   │                     │                                 │
│  ├──────────────┤   │                     │                                 │
│  │ order_id     │───┘                     │                                 │
│  │ product_id   │───┐                     │                                 │
│  │ quantity     │   │                     │                                 │
│  │ unit_price   │   │                     │                                 │
│  │ discount_pct │   │                     │                                 │
│  │ created_at   │   │                     │                                 │
│  └──────────────┘   │                     │                                 │
│                     │                     │                                 │
│  ┌──────────────┐   │                     │                                 │
│  │   payments   │   │                     │                                 │
│  ├──────────────┤   │                     │                                 │
│  │ id (PK)      │   │                     │                                 │
│  │ order_id     │───┘                     │                                 │
│  │ amount       │                         │                                 │
│  │ method       │                         │                                 │
│  │ status       │                         │                                 │
│  │ transaction_id│                        │                                 │
│  │ payment_date │                         │                                 │
│  │ metadata     │                         │                                 │
│  │ created_at   │                         │                                 │
│  │ updated_at   │                         │                                 │
│  └──────────────┘                         │                                 │
│                                            │                                 │
│  ┌──────────────┐                         │                                 │
│  │   reviews    │                         │                                 │
│  ├──────────────┤                         │                                 │
│  │ id (PK)      │                         │                                 │
│  │ product_id   │───┐                     │                                 │
│  │ customer_id  │───┘                     │                                 │
│  │ rating       │                         │                                 │
│  │ title        │                         │                                 │
│  │ comment      │                         │                                 │
│  │ is_verified  │                         │                                 │
│  │ helpful_count│                         │                                 │
│  │ review_date  │                         │                                 │
│  │ created_at   │                         │                                 │
│  │ updated_at   │                         │                                 │
│  └──────────────┘                         │                                 │
│                                            │                                 │
│  ┌──────────────┐                         │                                 │
│  │ outbox_msgs  │                         │                                 │
│  ├──────────────┤                         │                                 │
│  │ id (PK)      │                         │                                 │
│  │ message_id   │                         │                                 │
│  │ aggregate_id │                         │                                 │
│  │ aggregate_typ│                         │                                 │
│  │ event_type   │                         │                                 │
│  │ payload      │                         │                                 │
│  │ created_at   │                         │                                 │
│  │ published_at │                         │                                 │
│  │ retry_count  │                         │                                 │
│  │ last_error   │                         │                                 │
│  └──────────────┘                         │                                 │
│                                            │                                 │
│  ┌──────────────┐                         │                                 │
│  │  audit_log   │                         │                                 │
│  ├──────────────┤                         │                                 │
│  │ id (PK)      │                         │                                 │
│  │ table_name   │                         │                                 │
│  │ record_id    │                         │                                 │
│  │ action       │                         │                                 │
│  │ old_data     │                         │                                 │
│  │ new_data     │                         │                                 │
│  │ changed_by   │                         │                                 │
│  │ changed_at   │                         │                                 │
│  │ client_ip    │                         │                                 │
│  │ user_agent   │                         │                                 │
│  └──────────────┘                         │                                 │
│                                            │                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## D.3 Data Dictionary

### D.3.1 Table: categories

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| name | VARCHAR(100) | NO | - | Category name, unique |
| parent_category_id | INTEGER | YES | NULL | Self-reference for hierarchy |
| description | TEXT | YES | NULL | Category description |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (name)
- INDEX idx_categories_parent_category_id (parent_category_id)

**Constraints:**
- FOREIGN KEY (parent_category_id) REFERENCES categories(id) ON DELETE RESTRICT

**Comments:**
- Supports hierarchical categories (e.g., Electronics → Laptops → Gaming Laptops)

---

### D.3.2 Table: products

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| name | VARCHAR(255) | NO | - | Product name |
| description | TEXT | YES | NULL | Product description |
| price | NUMERIC(10,2) | NO | - | Current price (must be >= 0) |
| category_id | INTEGER | NO | - | Foreign key to categories |
| weight_kg | NUMERIC(5,2) | YES | 0.0 | Product weight in kg |
| sku | VARCHAR(50) | YES | NULL | Stock Keeping Unit, unique |
| search_vector | TSVECTOR | GENERATED | - | Full-text search vector |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (sku)
- INDEX idx_products_category_id (category_id)
- INDEX idx_products_search_vector (search_vector) USING GIN
- INDEX idx_products_name_lower (LOWER(name))
- INDEX idx_products_name_trgm (name) USING GIN (gin_trgm_ops)
- INDEX idx_products_covering (category_id) INCLUDE (name, price)

**Constraints:**
- CHECK (price >= 0)
- FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT

**Generated Columns:**
- `search_vector`: setweight(to_tsvector('english', coalesce(name, '')), 'A') || setweight(to_tsvector('english', coalesce(description, '')), 'B')

**Triggers:**
- trigger_products_updated_at: Updates updated_at on row update

---

### D.3.3 Table: suppliers

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| name | VARCHAR(200) | NO | - | Supplier name |
| contact_email | VARCHAR(100) | NO | - | Contact email, unique |
| phone | VARCHAR(20) | YES | NULL | Phone number |
| address | TEXT | YES | NULL | Physical address |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (contact_email)

---

### D.3.4 Table: supplier_products

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| supplier_id | INTEGER | NO | - | Foreign key to suppliers |
| product_id | INTEGER | NO | - | Foreign key to products |
| supply_price | NUMERIC(10,2) | NO | - | Price from this supplier |
| is_preferred | BOOLEAN | YES | FALSE | Preferred supplier flag |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |

**Indexes:**
- PRIMARY KEY (supplier_id, product_id)
- INDEX idx_supplier_products_supplier_id (supplier_id)
- INDEX idx_supplier_products_product_id (product_id)

**Constraints:**
- CHECK (supply_price >= 0)
- FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE
- FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE

---

### D.3.5 Table: customers

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| email | VARCHAR(255) | NO | - | Email address, unique |
| password_hash | VARCHAR(255) | NO | - | Bcrypt/Argon2 hashed password |
| full_name | VARCHAR(100) | NO | - | Customer's full name |
| phone | VARCHAR(20) | YES | NULL | Phone number |
| registered_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Registration timestamp |
| last_login | TIMESTAMPTZ | YES | NULL | Last login timestamp |
| is_active | BOOLEAN | YES | TRUE | Account active flag |
| is_verified | BOOLEAN | YES | FALSE | Email verified flag |
| version | INTEGER | YES | 1 | Optimistic locking version |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (email)
- INDEX idx_customers_active_email (email) WHERE is_active = true
- INDEX idx_customers_email_lower (LOWER(email))

---

### D.3.6 Table: addresses

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| customer_id | INTEGER | NO | - | Foreign key to customers |
| address_type | VARCHAR(20) | NO | 'shipping' | shipping/billing/both |
| street | VARCHAR(200) | NO | - | Street address |
| city | VARCHAR(100) | NO | - | City |
| state | VARCHAR(50) | YES | NULL | State/Province |
| postal_code | VARCHAR(20) | YES | NULL | Postal/ZIP code |
| country | VARCHAR(50) | NO | - | Country |
| is_default | BOOLEAN | YES | FALSE | Default address flag |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_addresses_customer_id (customer_id)

**Constraints:**
- CHECK (address_type IN ('shipping', 'billing', 'both'))
- FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE

---

### D.3.7 Table: orders

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| customer_id | INTEGER | NO | - | Foreign key to customers |
| order_date | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Order date/time |
| status | VARCHAR(20) | NO | - | Order status |
| total_amount | NUMERIC(12,2) | NO | - | Total order amount |
| shipping_address_id | INTEGER | YES | NULL | Foreign key to addresses |
| billing_address_id | INTEGER | YES | NULL | Foreign key to addresses |
| notes | TEXT | YES | NULL | Order notes |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_orders_customer_id (customer_id)
- INDEX idx_orders_order_date (order_date DESC)
- INDEX idx_orders_customer_status (customer_id, status)
- INDEX idx_orders_shipping_address_id (shipping_address_id)
- INDEX idx_orders_billing_address_id (billing_address_id)
- INDEX idx_orders_pending (order_date) WHERE status = 'pending'

**Constraints:**
- CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded'))
- CHECK (total_amount >= 0)
- FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
- FOREIGN KEY (shipping_address_id) REFERENCES addresses(id) ON DELETE SET NULL
- FOREIGN KEY (billing_address_id) REFERENCES addresses(id) ON DELETE SET NULL

---

### D.3.8 Table: order_items

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| order_id | INTEGER | NO | - | Foreign key to orders |
| product_id | INTEGER | NO | - | Foreign key to products |
| quantity | INTEGER | NO | - | Quantity ordered |
| unit_price | NUMERIC(10,2) | NO | - | Price at order time |
| discount_percent | NUMERIC(5,2) | YES | 0.0 | Applied discount |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |

**Indexes:**
- PRIMARY KEY (order_id, product_id)
- INDEX idx_order_items_order_id (order_id)
- INDEX idx_order_items_product_id (product_id)
- INDEX idx_order_items_order_id_product_id (order_id, product_id)

**Constraints:**
- CHECK (quantity > 0)
- CHECK (unit_price >= 0)
- CHECK (discount_percent >= 0 AND discount_percent <= 100)
- FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
- FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT

---

### D.3.9 Table: inventory

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| product_id | INTEGER | NO | - | Foreign key to products (PK) |
| stock_quantity | INTEGER | NO | 0 | Current stock level |
| reserved_quantity | INTEGER | NO | 0 | Reserved for pending orders |
| reorder_threshold | INTEGER | NO | 10 | Minimum stock before reorder |
| reorder_quantity | INTEGER | YES | 100 | Quantity to order when reordering |
| last_restocked_at | TIMESTAMPTZ | YES | NULL | Last restock timestamp |
| last_updated | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (product_id)
- INDEX idx_inventory_low_stock (product_id) WHERE stock_quantity < reorder_threshold

**Constraints:**
- CHECK (stock_quantity >= 0)
- CHECK (reserved_quantity >= 0)
- CHECK (reorder_threshold >= 0)
- FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE

---

### D.3.10 Table: payments

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| order_id | INTEGER | NO | - | Foreign key to orders |
| amount | NUMERIC(12,2) | NO | - | Payment amount |
| method | VARCHAR(30) | NO | - | Payment method |
| status | VARCHAR(20) | NO | - | Payment status |
| transaction_id | VARCHAR(100) | YES | NULL | External transaction ID |
| payment_date | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Payment date |
| metadata | JSONB | YES | NULL | Additional payment data |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_payments_order_id (order_id)
- INDEX idx_payments_transaction_id (transaction_id)

**Constraints:**
- CHECK (amount > 0)
- CHECK (method IN ('credit_card', 'paypal', 'bank_transfer', 'apple_pay', 'google_pay'))
- CHECK (status IN ('pending', 'completed', 'failed', 'refunded'))
- FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE RESTRICT

---

### D.3.11 Table: reviews

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| product_id | INTEGER | NO | - | Foreign key to products |
| customer_id | INTEGER | NO | - | Foreign key to customers |
| rating | INTEGER | NO | - | Rating (1-5) |
| title | VARCHAR(200) | YES | NULL | Review title |
| comment | TEXT | YES | NULL | Review text |
| is_verified_purchase | BOOLEAN | YES | FALSE | Verified purchase flag |
| helpful_count | INTEGER | YES | 0 | Number of helpful votes |
| review_date | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Review date |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Last update timestamp |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (product_id, customer_id)
- INDEX idx_reviews_product_id (product_id)
- INDEX idx_reviews_customer_id (customer_id)
- INDEX idx_reviews_product_rating (product_id, rating DESC)

**Constraints:**
- CHECK (rating BETWEEN 1 AND 5)
- FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
- FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE

---

### D.3.12 Table: outbox_messages

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| message_id | UUID | NO | uuid_generate_v4() | Unique message identifier |
| aggregate_id | VARCHAR(100) | NO | - | Domain aggregate ID |
| aggregate_type | VARCHAR(50) | NO | - | Type of aggregate |
| event_type | VARCHAR(100) | NO | - | Type of event |
| payload | JSONB | NO | - | Event payload |
| created_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Message creation time |
| published_at | TIMESTAMPTZ | YES | NULL | Publication timestamp |
| retry_count | INTEGER | YES | 0 | Number of retry attempts |
| last_error | TEXT | YES | NULL | Last error message |

**Indexes:**
- PRIMARY KEY (id)
- UNIQUE (message_id)
- INDEX idx_outbox_messages_published (published_at NULLS FIRST) WHERE published_at IS NULL

---

### D.3.13 Table: audit_log

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary key |
| table_name | VARCHAR(100) | NO | - | Table that was modified |
| record_id | INTEGER | NO | - | ID of modified record |
| action | VARCHAR(20) | NO | - | INSERT/UPDATE/DELETE |
| old_data | JSONB | YES | NULL | Previous state |
| new_data | JSONB | YES | NULL | New state |
| changed_by | INTEGER | YES | NULL | Customer ID who made change |
| changed_at | TIMESTAMPTZ | NO | CURRENT_TIMESTAMP | Change timestamp |
| client_ip | INET | YES | NULL | Client IP address |
| user_agent | TEXT | YES | NULL | User agent string |

**Indexes:**
- PRIMARY KEY (id)
- INDEX idx_audit_log_table_record (table_name, record_id)
- INDEX idx_audit_log_changed_at (changed_at DESC)
- INDEX idx_audit_log_changed_by (changed_by)

**Constraints:**
- CHECK (action IN ('INSERT', 'UPDATE', 'DELETE'))
- FOREIGN KEY (changed_by) REFERENCES customers(id) ON DELETE SET NULL

---

## D.4 Relationship Matrix

| From Table | To Table | Type | Description |
|------------|----------|------|-------------|
| products | categories | 1:N | Each product belongs to one category |
| products | inventory | 1:1 | Each product has one inventory record |
| products | supplier_products | 1:N | Product can have multiple suppliers |
| products | order_items | 1:N | Product can appear in multiple orders |
| products | reviews | 1:N | Product can have many reviews |
| suppliers | supplier_products | 1:N | Supplier can supply many products |
| customers | addresses | 1:N | Customer can have many addresses |
| customers | orders | 1:N | Customer can have many orders |
| customers | reviews | 1:N | Customer can write many reviews |
| orders | order_items | 1:N | Order has many line items |
| orders | payments | 1:N | Order can have multiple payments |
| orders | addresses | N:1 | Order has shipping/billing addresses |
| categories | categories | 1:N | Self-reference for hierarchy |

---

## D.5 Sample Queries

### D.5.1 Product Catalog Queries

```sql
-- Get products with category name and stock
SELECT 
    p.id,
    p.name,
    p.price,
    c.name AS category,
    COALESCE(i.stock_quantity, 0) AS stock,
    ROUND(AVG(r.rating), 1) AS avg_rating
FROM products p
JOIN categories c ON p.category_id = c.id
LEFT JOIN inventory i ON p.id = i.product_id
LEFT JOIN reviews r ON p.id = r.product_id
WHERE p.category_id = 5  -- Laptops
  AND p.price BETWEEN 1000 AND 2000
GROUP BY p.id, p.name, p.price, c.name, i.stock_quantity
HAVING AVG(r.rating) >= 4.0
ORDER BY p.price ASC
LIMIT 20;

-- Full-text search
SELECT 
    id,
    name,
    description,
    price,
    ts_rank(search_vector, to_tsquery('english', 'laptop & high-performance')) AS relevance
FROM products
WHERE search_vector @@ to_tsquery('english', 'laptop & high-performance')
ORDER BY relevance DESC
LIMIT 10;
```

### D.5.2 Order Analytics

```sql
-- Daily revenue for last 30 days
SELECT 
    DATE(o.order_date) AS day,
    COUNT(DISTINCT o.id) AS orders,
    SUM(o.total_amount) AS revenue,
    AVG(o.total_amount) AS average_order_value,
    SUM(oi.quantity) AS items_sold
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
  AND o.order_date > CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(o.order_date)
ORDER BY day DESC;

-- Top 10 products by revenue
SELECT 
    p.id,
    p.name,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    COUNT(DISTINCT o.id) AS order_count
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status IN ('paid', 'shipped', 'delivered')
  AND o.order_date > CURRENT_DATE - INTERVAL '90 days'
GROUP BY p.id, p.name
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer lifetime value
SELECT 
    c.id,
    c.full_name,
    c.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS lifetime_value,
    AVG(o.total_amount) AS average_order,
    MAX(o.order_date) AS last_order_date,
    EXTRACT(DAY FROM (CURRENT_DATE - MAX(o.order_date))) AS days_since_last_order
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE o.status IN ('paid', 'shipped', 'delivered')
GROUP BY c.id, c.full_name, c.email
HAVING COUNT(o.id) > 0
ORDER BY lifetime_value DESC
LIMIT 20;
```

### D.5.3 Inventory Management

```sql
-- Products with low stock
SELECT 
    p.id,
    p.name,
    p.sku,
    i.stock_quantity,
    i.reorder_threshold,
    i.reorder_quantity,
    i.stock_quantity - i.reorder_threshold AS deficit
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE i.stock_quantity < i.reorder_threshold
  AND p.is_active = true
ORDER BY deficit ASC;

-- Inventory valuation
SELECT 
    SUM(i.stock_quantity * p.price) AS total_inventory_value,
    COUNT(p.id) AS total_products,
    AVG(i.stock_quantity) AS average_stock
FROM inventory i
JOIN products p ON i.product_id = p.id;
```

### D.5.4 Customer Analytics

```sql
-- Customer acquisition over time
SELECT 
    DATE(registered_at) AS acquisition_date,
    COUNT(*) AS new_customers,
    SUM(CASE WHEN is_verified THEN 1 ELSE 0 END) AS verified_customers
FROM customers
WHERE registered_at > CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE(registered_at)
ORDER BY acquisition_date DESC;

-- Customer retention (repeat purchase rate)
WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status IN ('paid', 'shipped', 'delivered')
    GROUP BY customer_id
)
SELECT 
    COUNT(DISTINCT fp.customer_id) AS total_customers,
    COUNT(DISTINCT o.customer_id) AS repeat_customers,
    ROUND(100.0 * COUNT(DISTINCT o.customer_id) / COUNT(DISTINCT fp.customer_id), 2) AS retention_rate
FROM first_purchase fp
LEFT JOIN orders o ON fp.customer_id = o.customer_id
    AND o.order_date > fp.first_order_date
    AND o.status IN ('paid', 'shipped', 'delivered');
```

### D.5.5 Performance Monitoring

```sql
-- Slow queries (using pg_stat_statements)
SELECT 
    query,
    calls,
    total_time / 1000 AS total_seconds,
    mean_time / 1000 AS avg_ms,
    rows,
    100.0 * shared_blks_hit / (shared_blks_hit + shared_blks_read) AS cache_hit_pct
FROM pg_stat_statements
WHERE calls > 100
ORDER BY total_time DESC
LIMIT 10;

-- Table sizes and bloat
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - 
                   pg_relation_size(schemaname||'.'||tablename)) AS index_size,
    n_live_tup AS live_rows,
    n_dead_tup AS dead_rows,
    ROUND(n_dead_tup * 100.0 / (n_live_tup + 1), 2) AS dead_pct
FROM pg_stat_user_tables
WHERE n_live_tup > 10000
ORDER BY dead_pct DESC;
```

---

## D.6 Migration History

| Migration | Version | Description | Date | Rollback Strategy |
|-----------|---------|-------------|------|-------------------|
| Initial Schema | 001 | Create all tables | 2026-01-01 | Drop all tables |
| Product Indexes | 002 | Add performance indexes | 2026-01-02 | Drop indexes |
| Order Partitioning | 003 | Partition orders by date | 2026-01-05 | Merge partitions |
| Add Weight to Products | 004 | Add weight_kg column | 2026-01-07 | Drop column |
| Customer Version | 005 | Add optimistic locking | 2026-01-08 | Drop version column |
| Outbox Messages | 006 | Create outbox table | 2026-01-10 | Drop table |
| Audit Log | 007 | Create audit log table | 2026-01-12 | Drop table |
| Product SKU | 008 | Add SKU and index | 2026-01-15 | Drop SKU column |
| Inventory Reserved | 009 | Add reserved_quantity | 2026-01-18 | Drop column |
| Full-Text Search | 010 | Add search_vector | 2026-01-20 | Drop column |

---

## D.7 Schema Validation Queries

```sql
-- Validate foreign key integrity
SELECT 
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name;

-- Validate all indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Check table sizes
SELECT 
    table_schema,
    table_name,
    pg_size_pretty(pg_total_relation_size(table_schema || '.' || table_name)) AS total_size,
    pg_size_pretty(pg_relation_size(table_schema || '.' || table_name)) AS table_size,
    pg_size_pretty(pg_total_relation_size(table_schema || '.' || table_name) - 
                   pg_relation_size(table_schema || '.' || table_name)) AS index_size
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY pg_total_relation_size(table_schema || '.' || table_name) DESC;
```

---

**[END OF APPENDIX D]**

*This data dictionary provides complete reference documentation for the ScaleCart database schema. Use it as your authoritative source for all database design questions.*
