# Serverless Postgres with Neon: From Zero to Production

## Primer 2: Database Design & Normalization

### Overview

Before you build your e-commerce application, you need to understand how to design your database properly. This primer covers the art and science of database design—how to organize your data to avoid redundancy, maintain integrity, and ensure performance. Think of this as learning how to architect a building before you start construction.

---

### P2.1 Why Database Design Matters

Imagine building a house without a blueprint. You might end up with rooms that don't connect properly, doors that open into walls, and a structure that's inefficient and hard to maintain. The same applies to databases.

**Poor database design leads to:**
- **Data Redundancy**: Storing the same information in multiple places
- **Data Inconsistency**: Different versions of the same data
- **Update Anomalies**: Difficulty updating data without breaking things
- **Insertion Anomalies**: Can't add data without adding unrelated data
- **Deletion Anomalies**: Deleting data accidentally removes other data
- **Performance Issues**: Slow queries due to poor structure

**Good database design results in:**
- **Efficient Storage**: No unnecessary duplication
- **Data Integrity**: Accurate, consistent data
- **Flexibility**: Easy to add new features
- **Performance**: Fast queries with proper indexing
- **Maintainability**: Easy to understand and modify

---

### P2.2 The Relational Model

#### Entities and Attributes

Think of your database as a collection of real-world objects:

```
Entity: A real-world object or concept (like a "Customer" or "Order")
Attribute: A characteristic of an entity (like a Customer's "Name" or "Email")
Relationship: How entities relate to each other (like "A Customer places Orders")
```

**Example: E-commerce Entities**

```
Customer
├── id
├── name
├── email
├── phone
└── address

Order
├── id
├── date
├── status
├── total
└── customer_id (references Customer)

Product
├── id
├── name
├── description
├── price
└── stock_quantity

OrderItem
├── id
├── order_id (references Order)
├── product_id (references Product)
├── quantity
└── price
```

#### Primary Keys

Every table should have a primary key—a column (or set of columns) that uniquely identifies each row.

```sql
-- Natural Key: Uses existing data
CREATE TABLE products (
    sku VARCHAR(20) PRIMARY KEY,  -- Product SKU is unique
    name TEXT,
    price NUMERIC
);

-- Surrogate Key: Artificial identifier (recommended)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing number
    sku VARCHAR(20) UNIQUE,  -- Natural key as alternate
    name TEXT,
    price NUMERIC
);

-- UUID Primary Key (for distributed systems)
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    price NUMERIC
);
```

**Choosing Primary Keys:**

| Type | Pros | Cons | Best For |
|------|------|------|----------|
| SERIAL | Simple, efficient, small | Not globally unique | Internal apps |
| UUID | Globally unique, secure | Larger, slower | Distributed systems |
| Natural Key | No extra column | Can change | Stable codes (US states, countries) |
| Composite | No extra columns | Complex, hard to join | Junction tables |

---

### P2.3 Normalization

Normalization is the process of organizing data to reduce redundancy and improve integrity. Think of it as "database hygiene."

#### First Normal Form (1NF)

**Rule**: Eliminate repeating groups; each cell must contain a single value.

**Before (NOT 1NF)**:
```sql
-- A product with multiple colors in one field (violates 1NF)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    colors VARCHAR(255)  -- "Red, Blue, Green" (repeating group)
);
```

**After (1NF)**:
```sql
-- Separate table for colors (proper 1NF)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE product_colors (
    product_id INTEGER REFERENCES products(id),
    color VARCHAR(50),
    PRIMARY KEY (product_id, color)
);
```

#### Second Normal Form (2NF)

**Rule**: Must be in 1NF AND all non-key columns depend on the entire primary key.

**Before (NOT 2NF)**:
```sql
-- Order details with product and customer info
CREATE TABLE order_details (
    order_id INTEGER,
    product_id INTEGER,
    customer_name TEXT,  -- Depends on order_id, not product_id
    product_name TEXT,   -- Depends on product_id, not order_id
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
```

**After (2NF)**:
```sql
-- Separate tables for each entity
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER
);

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE order_items (
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    PRIMARY KEY (order_id, product_id)
);
```

#### Third Normal Form (3NF)

**Rule**: Must be in 2NF AND non-key columns depend only on the primary key (not on other non-key columns).

**Before (NOT 3NF)**:
```sql
-- Product with category info that depends on product
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    category_name TEXT,
    category_description TEXT,  -- Depends on category_name, not product id
    price NUMERIC
);
```

**After (3NF)**:
```sql
-- Separate category table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE,
    description TEXT
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT,
    category_id INTEGER REFERENCES categories(id),
    price NUMERIC
);
```

#### Boyce-Codd Normal Form (BCNF)

**Rule**: A stricter version of 3NF where every determinant is a candidate key.

**Example**:
```sql
-- A table where course determines instructor, and instructor determines office
-- Course -> Instructor
-- Instructor -> Office
-- Candidate Key: (Course)

CREATE TABLE course_instructors (
    course_id INTEGER,
    instructor_id INTEGER,
    instructor_office VARCHAR(50),
    PRIMARY KEY (course_id)
);

-- BCNF: Split into two tables
CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    instructor_id INTEGER
);

CREATE TABLE instructors (
    id INTEGER PRIMARY KEY,
    office VARCHAR(50)
);
```

#### Normalization Summary

| Normal Form | Rule | When to Stop |
|-------------|------|--------------|
| 1NF | No repeating groups | Always |
| 2NF | No partial dependencies | Always |
| 3NF | No transitive dependencies | Usually |
| BCNF | All determinants are keys | For complex business rules |
| 4NF | No multi-valued dependencies | For advanced use cases |
| 5NF | No join dependencies | Rarely needed |

---

### P2.4 Relationships

#### One-to-One (1:1)

One record in Table A relates to exactly one record in Table B.

```sql
-- User and Profile (1:1)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE
);

CREATE TABLE user_profiles (
    user_id INTEGER PRIMARY KEY REFERENCES users(id),
    full_name TEXT,
    bio TEXT,
    avatar_url TEXT
);

-- Or combine into one table if always needed together
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    full_name TEXT,
    bio TEXT,
    avatar_url TEXT
);
```

#### One-to-Many (1:M)

One record in Table A relates to many records in Table B.

```sql
-- One user has many orders (1:M)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total NUMERIC
);

-- Query: Get all orders for a user
SELECT 
    u.name,
    o.id,
    o.total
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE u.id = 1;
```

#### Many-to-Many (M:N)

Many records in Table A relate to many records in Table B.

```sql
-- Many products in many orders (M:N)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id)
);

-- Junction table (resolves M:N)
CREATE TABLE order_items (
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    price NUMERIC,
    PRIMARY KEY (order_id, product_id)
);

-- Query: Get all products in an order
SELECT 
    o.id AS order_id,
    p.name AS product_name,
    oi.quantity,
    oi.price
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.id = 1;
```

---

### P2.5 Denormalization

While normalization is generally good, sometimes we denormalize for performance:

```sql
-- Normalized (3NF)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    price NUMERIC
);

-- Denormalized (adding calculated fields)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP,
    total_items INTEGER,      -- Denormalized: count of items
    subtotal NUMERIC,          -- Denormalized: sum of item prices
    tax NUMERIC,              -- Denormalized: calculated tax
    total NUMERIC             -- Denormalized: final total
);
```

**When to Denormalize:**
- Frequently queried calculated values
- Read-heavy applications
- Data that rarely changes
- Reports and analytics

**When NOT to Denormalize:**
- Data that changes frequently
- Write-heavy applications
- Data where consistency is critical

---

### P2.6 Practical Database Design Example

Let's design a complete e-commerce database from scratch:

#### Step 1: Identify Entities

```
1. User          - People who use the system
2. Product       - Items for sale
3. Category      - Product classifications
4. Order         - Customer purchases
5. OrderItem     - Products in an order
6. Address       - Shipping/billing locations
7. Review        - Customer product reviews
8. Cart          - Temporary shopping carts
9. CartItem      - Products in a cart
10. Payment      - Payment transactions
```

#### Step 2: Define Attributes

```sql
-- User
User
├── id (PK)
├── email (unique)
├── password_hash
├── first_name
├── last_name
├── phone
├── status (active/inactive/suspended)
├── created_at
├── updated_at
└── last_login

-- Product
Product
├── id (PK)
├── name
├── description
├── price
├── stock_quantity
├── category_id (FK)
├── attributes (JSONB)
├── created_at
├── updated_at
└── deleted_at

-- Category
Category
├── id (PK)
├── name
├── slug
├── description
├── parent_id (self-reference FK)
└── sort_order
```

#### Step 3: Define Relationships

```
- User has many Orders (1:M)
- User has many Addresses (1:M)
- User has many Reviews (1:M)
- User has one Cart (1:1)
- Product belongs to one Category (M:1)
- Product has many Reviews (1:M)
- Product has many OrderItems (1:M)
- Product has many CartItems (1:M)
- Order belongs to one User (M:1)
- Order has many OrderItems (1:M)
- Order belongs to one Shipping Address (M:1)
- Order belongs to one Billing Address (M:1)
- Order has one Payment (1:1)
- OrderItem belongs to one Order (M:1)
- OrderItem belongs to one Product (M:1)
- Cart belongs to one User (1:1)
- CartItem belongs to one Cart (M:1)
- CartItem belongs to one Product (M:1)
- Payment belongs to one Order (M:1)
```

#### Step 4: Create the Schema

```sql
-- Complete e-commerce database schema

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'suspended'))
);

-- Addresses table
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) DEFAULT 'USA',
    address_type VARCHAR(20) DEFAULT 'shipping',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT valid_address_type CHECK (address_type IN ('shipping', 'billing'))
);

-- Categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    category_id INTEGER REFERENCES categories(id),
    attributes JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    search_vector TSVECTOR,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT positive_price CHECK (price >= 0),
    CONSTRAINT non_negative_stock CHECK (stock_quantity >= 0)
);

-- Reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL,
    title VARCHAR(255),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT valid_rating CHECK (rating BETWEEN 1 AND 5)
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    shipping_address_id UUID NOT NULL REFERENCES addresses(id),
    billing_address_id UUID NOT NULL REFERENCES addresses(id),
    subtotal NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL DEFAULT 0,
    shipping_cost NUMERIC(10,2) NOT NULL DEFAULT 0,
    discount NUMERIC(10,2) NOT NULL DEFAULT 0,
    total NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending',
    shipping_method VARCHAR(50),
    tracking_number VARCHAR(100),
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    customer_notes TEXT,
    admin_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT valid_order_status CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    CONSTRAINT valid_payment_status CHECK (payment_status IN ('pending', 'authorized', 'paid', 'failed', 'refunded')),
    CONSTRAINT positive_total CHECK (total >= 0)
);

-- Order Items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    line_subtotal NUMERIC(10,2) NOT NULL,
    line_tax NUMERIC(10,2) NOT NULL DEFAULT 0,
    line_total NUMERIC(10,2) NOT NULL,
    product_attributes JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_unit_price CHECK (unit_price >= 0)
);

-- Carts table
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expired_at TIMESTAMPTZ
);

-- Cart Items table
CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT positive_quantity CHECK (quantity > 0)
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL,
    method VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    transaction_id VARCHAR(255),
    gateway_response JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT valid_payment_status CHECK (status IN ('pending', 'success', 'failed', 'refunded'))
);
```

#### Step 5: Add Indexes

```sql
-- Critical indexes for performance

-- User indexes
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;

-- Product indexes
CREATE INDEX idx_products_name ON products(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_category ON products(category_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_price ON products(price) WHERE deleted_at IS NULL;
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);

-- Order indexes
CREATE INDEX idx_orders_user ON orders(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_status ON orders(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_date ON orders(created_at DESC) WHERE deleted_at IS NULL;

-- Order item indexes
CREATE INDEX idx_order_items_order ON order_items(order_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_order_items_product ON order_items(product_id) WHERE deleted_at IS NULL;

-- Review indexes
CREATE INDEX idx_reviews_product ON reviews(product_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_reviews_user ON reviews(user_id) WHERE deleted_at IS NULL;

-- Address indexes
CREATE INDEX idx_addresses_user ON addresses(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_addresses_default ON addresses(user_id, is_default) WHERE deleted_at IS NULL;
```

---

### P2.7 Database Design Anti-Patterns

#### Anti-Pattern 1: EAV (Entity-Attribute-Value)

**Bad**:
```sql
CREATE TABLE product_attributes (
    product_id INTEGER,
    attribute_name VARCHAR(50),
    attribute_value TEXT
);
-- Querying is complex and slow
```

**Good**:
```sql
ALTER TABLE products ADD COLUMN attributes JSONB;
-- Fast and flexible
```

#### Anti-Pattern 2: One Table for Everything

**Bad**:
```sql
CREATE TABLE everything (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50),
    field1 TEXT,
    field2 TEXT,
    field3 TEXT
);
```

**Good**:
```sql
-- Separate tables for each entity
CREATE TABLE users (...);
CREATE TABLE products (...);
CREATE TABLE orders (...);
```

#### Anti-Pattern 3: Using VARCHAR for Everything

**Bad**:
```sql
CREATE TABLE orders (
    id VARCHAR(255) PRIMARY KEY,
    total VARCHAR(255)  -- Should be NUMERIC
);
```

**Good**:
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    total NUMERIC(10,2)
);
```

#### Anti-Pattern 4: Missing Foreign Keys

**Bad**:
```sql
CREATE TABLE orders (
    user_id INTEGER  -- No foreign key constraint
);
```

**Good**:
```sql
CREATE TABLE orders (
    user_id INTEGER REFERENCES users(id)
);
```

---

### P2.8 Design Checklist

Before finalizing your database design, check:

**Data Integrity**
- [ ] Every table has a primary key
- [ ] Foreign keys reference valid tables
- [ ] NOT NULL constraints on required fields
- [ ] UNIQUE constraints on unique data
- [ ] CHECK constraints on business rules
- [ ] Default values for common fields

**Normalization**
- [ ] No repeating groups (1NF)
- [ ] No partial dependencies (2NF)
- [ ] No transitive dependencies (3NF)
- [ ] Consider BCNF for complex rules

**Performance**
- [ ] Indexes on foreign keys
- [ ] Indexes on frequently queried columns
- [ ] Indexes on ORDER BY columns
- [ ] Consider partition for large tables
- [ ] Consider materialized views for reports

**Flexibility**
- [ ] Use UUID for distributed systems
- [ ] Use JSONB for flexible data
- [ ] Use soft delete (deleted_at)
- [ ] Include timestamps (created_at, updated_at)

**Security**
- [ ] Row-level security policies considered
- [ ] Column-level encryption for sensitive data
- [ ] Audit trail for critical tables

---

### Summary

You now understand:

- **Why design matters**: Prevents data issues and improves performance
- **The relational model**: Entities, attributes, and relationships
- **Normalization**: 1NF, 2NF, 3NF, BCNF
- **Relationships**: 1:1, 1:M, M:N
- **Denormalization**: When and why to break normalization rules
- **Practical design**: Complete e-commerce schema
- **Anti-patterns**: What to avoid
- **Design checklist**: Ensure your design is production-ready

With these fundamentals, you're ready to understand and extend the database design used in the main series!
