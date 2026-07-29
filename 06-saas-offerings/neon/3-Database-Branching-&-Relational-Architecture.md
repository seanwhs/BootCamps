# Serverless Postgres with Neon: From Zero to Production

## Part 3: Database Branching & Relational Architecture

### The Target

In this part, we'll:
1. Understand and implement Neon's database branching feature
2. Create development and staging branches for safe testing
3. Design a relational database model for e-commerce (orders, order_items, addresses)
4. Implement FOREIGN KEY constraints with proper cascade rules
5. Write complex JOIN queries across multiple tables
6. Practice safe migration workflows using branches

By the end of this part, you'll have a complete relational e-commerce database and know how to use Neon branches for development and testing.

---

### The Concept: Your Database as a Git Repository

Imagine your database is like a book. In traditional setups, editing the book means you have to change the only copy—if you make a mistake, the book is damaged. Neon's branching is like having a photocopier that can instantly create an exact copy of the book in seconds.

You can:
- **Create a branch**: Make a perfect copy of your database in under a second
- **Experiment safely**: Make changes, run tests, and break things without affecting production
- **Merge back**: Apply your changes to the main branch when everything works
- **Delete branches**: Clean up when you're done

This is revolutionary because:
- **Copying a database traditionally takes hours** (or even days for large databases)
- **Neon branches copy instantly** because they use copy-on-write technology
- **No storage duplication**: Branches share the same underlying storage until changes are made

---

### Implementation Step 1: Understanding Neon Branching

#### 1.1 Create Your First Branch

**Option A: Using Neon Console (GUI)**

1. Log into your Neon dashboard
2. Click on your project (`ecommerce-backend`)
3. In the left sidebar, click **"Branches"**
4. Click **"Create Branch"**
5. Name: `dev-branch`
6. Parent: `main` (or whatever your primary branch is)
7. Click **"Create"**

You'll see your branch created in seconds with its own connection string.

**Option B: Using Neon CLI**

```bash
# List existing branches
neonctl branches list --project-id your-project-id

# Create a new branch
neonctl branches create --name dev-branch --project-id your-project-id

# Create a branch with a specific parent
neonctl branches create --name staging-branch --parent main --project-id your-project-id

# Get connection string for the new branch
neonctl branches get-connection-string dev-branch --project-id your-project-id
```

**The Verification**: You should see your new branch listed in the Neon console with status "Active". You'll also see a connection string specific to that branch.

#### 1.2 Connect to Your Branch

```bash
# Use the branch's connection string
psql "postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/dev-branch?sslmode=require"

# Or use the CLI to get the string
neonctl branches get-connection-string dev-branch --project-id your-project-id | pbcopy
```

**The Verification**: You can connect and run `SELECT current_database();` to confirm you're on the branch database.

---

### Implementation Step 2: Design the Relational Model

Now let's build our e-commerce relational model. We'll create:

1. **addresses**: User shipping/billing addresses (One-to-Many with users)
2. **orders**: Order header information (Many-to-One with users)
3. **order_items**: Items within an order (Many-to-One with orders and products)

#### 2.1 The Complete Relational Schema

Create `migrations/002_create_ecommerce_tables.sql`:

```sql
-- migrations/002_create_ecommerce_tables.sql
-- Complete relational schema for e-commerce

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: addresses
-- Stores user shipping and billing addresses
-- ============================================
CREATE TABLE IF NOT EXISTS addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Address fields
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),  -- Apartment, suite, etc.
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'USA',
    
    -- Address type
    address_type VARCHAR(20) NOT NULL DEFAULT 'shipping',
    CONSTRAINT valid_address_type CHECK (address_type IN ('shipping', 'billing', 'both')),
    
    -- Is this the default address?
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Ensure user can't have two default addresses of same type
    CONSTRAINT unique_default_address UNIQUE (user_id, address_type, is_default)
);

-- Create indexes for addresses
CREATE INDEX idx_addresses_user_id ON addresses(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_addresses_postal_code ON addresses(postal_code);
CREATE INDEX idx_addresses_country ON addresses(country);

-- ============================================
-- TABLE: orders
-- Stores order header information
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    shipping_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    billing_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    
    -- Order details
    order_number VARCHAR(20) UNIQUE NOT NULL,
    order_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Status tracking
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    CONSTRAINT valid_order_status CHECK (status IN (
        'pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'
    )),
    
    -- Payment information
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    CONSTRAINT valid_payment_status CHECK (payment_status IN (
        'pending', 'authorized', 'paid', 'failed', 'refunded'
    )),
    
    -- Monetary fields (use NUMERIC for precision)
    subtotal NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    shipping_cost NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    discount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    total NUMERIC(10,2) NOT NULL,
    
    -- Shipping information (denormalized for order history)
    shipping_method VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100),
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    
    -- Customer notes
    customer_notes TEXT,
    admin_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Business rules
    CONSTRAINT positive_total CHECK (total >= 0),
    CONSTRAINT positive_subtotal CHECK (subtotal >= 0),
    CONSTRAINT valid_dates CHECK (
        estimated_delivery_date IS NULL OR 
        estimated_delivery_date >= order_date::DATE
    )
);

-- Create indexes for orders
CREATE INDEX idx_orders_user_id ON orders(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_order_date ON orders(order_date DESC);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- ============================================
-- TABLE: order_items
-- Stores individual items within an order
-- ============================================
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Snapshot of product details at time of order
    product_name VARCHAR(255) NOT NULL,  -- Denormalized from products table
    product_description TEXT,            -- Denormalized from products table
    unit_price NUMERIC(10,2) NOT NULL,   -- Price at time of purchase
    quantity INTEGER NOT NULL,
    
    -- Calculated fields
    line_subtotal NUMERIC(10,2) NOT NULL,  -- unit_price * quantity
    line_tax NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    line_total NUMERIC(10,2) NOT NULL,     -- subtotal + tax
    
    -- Additional product metadata at time of order
    product_attributes JSONB,  -- Store product attributes as they were when ordered
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Business rules
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_unit_price CHECK (unit_price >= 0),
    CONSTRAINT positive_line_total CHECK (line_total >= 0)
);

-- Create indexes for order_items
CREATE INDEX idx_order_items_order_id ON order_items(order_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_created_at ON order_items(created_at DESC);

-- ============================================
-- TRIGGERS: Automatic timestamp updates
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables
CREATE TRIGGER update_addresses_updated_at 
    BEFORE UPDATE ON addresses 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_order_items_updated_at 
    BEFORE UPDATE ON order_items 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS: Simplify common queries
-- ============================================
-- View: Order summary with user and item counts
CREATE VIEW order_summary AS
SELECT 
    o.id,
    o.order_number,
    o.order_date,
    o.status,
    o.total,
    u.email AS customer_email,
    u.full_name AS customer_name,
    COUNT(oi.id) AS item_count,
    SUM(oi.quantity) AS total_items
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id AND oi.deleted_at IS NULL
WHERE o.deleted_at IS NULL
GROUP BY o.id, u.email, u.full_name;

-- View: User order history
CREATE VIEW user_order_history AS
SELECT 
    u.id AS user_id,
    u.email,
    u.full_name,
    o.id AS order_id,
    o.order_number,
    o.order_date,
    o.status,
    o.total,
    COUNT(oi.id) AS items_ordered
FROM users u
JOIN orders o ON u.id = o.user_id AND o.deleted_at IS NULL
LEFT JOIN order_items oi ON o.id = oi.order_id AND oi.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, o.id
ORDER BY o.order_date DESC;

-- View: Product sales report
CREATE VIEW product_sales_report AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.line_total) AS total_revenue,
    AVG(oi.unit_price) AS average_selling_price,
    MIN(oi.unit_price) AS min_price_paid,
    MAX(oi.unit_price) AS max_price_paid
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id AND oi.deleted_at IS NULL
LEFT JOIN orders o ON oi.order_id = o.id AND o.status NOT IN ('cancelled', 'refunded')
WHERE p.deleted_at IS NULL
GROUP BY p.id, p.name
ORDER BY total_revenue DESC;

-- Output confirmation
SELECT 'Relational schema created successfully!' AS status;
SELECT 
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') AS tables_created,
    (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'public') AS views_created;
```

---

### Implementation Step 3: Understanding Foreign Keys

#### 3.1 What Are Foreign Keys?

A foreign key creates a relationship between two tables:

```sql
-- user_id in addresses references users.id
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
```

Think of it like a link between two documents. If you have a customer (users) and their addresses (addresses), the foreign key ensures:
- **Every address belongs to a valid user**
- **You can't create an address for a user that doesn't exist**
- **If you delete a user, their addresses can be automatically deleted**

#### 3.2 CASCADE Rules

We use different cascade rules for different situations:

**ON DELETE CASCADE**:
```sql
-- If a user is deleted, delete all their addresses
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
```
Use this when child data depends on the parent and should be removed with it.

**ON DELETE RESTRICT**:
```sql
-- Prevent deleting a user who has orders
user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT
```
Use this when you need to preserve historical data.

**ON DELETE SET NULL**:
```sql
-- Set foreign key to NULL when parent is deleted
user_id UUID REFERENCES users(id) ON DELETE SET NULL
```
Use this when you want to keep the child record but remove the relationship.

#### 3.3 Testing Foreign Key Constraints

```sql
-- This will fail if the user doesn't exist
INSERT INTO addresses (user_id, address_line1, city, state, postal_code) 
VALUES ('non-existent-uuid', '123 Main St', 'Boston', 'MA', '02101');
-- ERROR: insert or update on table "addresses" violates foreign key constraint

-- This will fail if user has orders (RESTRICT)
DELETE FROM users WHERE id = 'user-with-orders-uuid';
-- ERROR: update or delete on table "users" violates foreign key constraint

-- This will cascade delete addresses if user has no orders
DELETE FROM users WHERE id = 'user-without-orders-uuid';
-- SUCCESS: User and all their addresses are deleted
```

---

### Implementation Step 4: Insert Sample Relational Data

#### 4.1 Create a Seed Script

Create `migrations/002_seed_relational_data.sql`:

```sql
-- migrations/002_seed_relational_data.sql
-- Seed data for relational tables

-- We'll need real user UUIDs from the users table
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    user3_id UUID;
    addr1_id UUID;
    addr2_id UUID;
    addr3_id UUID;
    order1_id UUID;
    order2_id UUID;
    order3_id UUID;
BEGIN
    -- Get user IDs (assuming these users exist from part 2)
    -- If they don't exist, we create them first
    SELECT id INTO user1_id FROM users WHERE email = 'alice.admin@company.com' LIMIT 1;
    IF user1_id IS NULL THEN
        INSERT INTO users (email, username, password_hash, full_name, role) 
        VALUES ('alice.admin@company.com', 'alice_admin', 'hash_placeholder', 'Alice Johnson', 'admin')
        RETURNING id INTO user1_id;
    END IF;

    SELECT id INTO user2_id FROM users WHERE email = 'bob.staff@company.com' LIMIT 1;
    IF user2_id IS NULL THEN
        INSERT INTO users (email, username, password_hash, full_name, role) 
        VALUES ('bob.staff@company.com', 'bob_staff', 'hash_placeholder', 'Bob Smith', 'staff')
        RETURNING id INTO user2_id;
    END IF;

    SELECT id INTO user3_id FROM users WHERE email = 'carol.customer@example.com' LIMIT 1;
    IF user3_id IS NULL THEN
        INSERT INTO users (email, username, password_hash, full_name, role) 
        VALUES ('carol.customer@example.com', 'carol_customer', 'hash_placeholder', 'Carol Williams', 'customer')
        RETURNING id INTO user3_id;
    END IF;

    -- Insert addresses for users
    INSERT INTO addresses (user_id, address_line1, city, state, postal_code, address_type, is_default) 
    VALUES 
        (user1_id, '123 Admin Way', 'Boston', 'MA', '02101', 'shipping', TRUE),
        (user1_id, '123 Admin Way', 'Boston', 'MA', '02101', 'billing', TRUE),
        (user2_id, '456 Staff Ave', 'New York', 'NY', '10001', 'shipping', TRUE),
        (user2_id, '456 Staff Ave', 'New York', 'NY', '10001', 'billing', TRUE),
        (user3_id, '789 Customer Rd', 'Los Angeles', 'CA', '90001', 'shipping', TRUE),
        (user3_id, '789 Customer Rd', 'Los Angeles', 'CA', '90001', 'billing', FALSE);

    -- Get address IDs for orders
    SELECT id INTO addr1_id FROM addresses WHERE user_id = user1_id AND address_type = 'shipping' LIMIT 1;
    SELECT id INTO addr2_id FROM addresses WHERE user_id = user2_id AND address_type = 'shipping' LIMIT 1;
    SELECT id INTO addr3_id FROM addresses WHERE user_id = user3_id AND address_type = 'shipping' LIMIT 1;

    -- Insert orders
    INSERT INTO orders (
        user_id, shipping_address_id, billing_address_id, order_number,
        subtotal, tax, shipping_cost, discount, total,
        payment_method, payment_status, status,
        shipping_method, estimated_delivery_date
    ) VALUES 
        (
            user1_id, addr1_id, addr1_id, 'ORD-2024-0001',
            349.99, 27.99, 0.00, 10.00, 367.98,
            'credit_card', 'paid', 'delivered',
            'UPS Ground', CURRENT_DATE + INTERVAL '5 days'
        ),
        (
            user2_id, addr2_id, addr2_id, 'ORD-2024-0002',
            249.99, 20.00, 5.99, 0.00, 275.98,
            'paypal', 'paid', 'shipped',
            'FedEx 2-Day', CURRENT_DATE + INTERVAL '3 days'
        ),
        (
            user3_id, addr3_id, addr3_id, 'ORD-2024-0003',
            489.99, 39.20, 0.00, 25.00, 504.19,
            'credit_card', 'pending', 'processing',
            'USPS Priority', CURRENT_DATE + INTERVAL '7 days'
        )
    RETURNING id INTO order1_id, order2_id, order3_id;

    -- Get product IDs (from part 1)
    -- Insert order items based on actual product IDs
    INSERT INTO order_items (
        order_id, product_id, product_name, product_description, 
        unit_price, quantity, line_subtotal, line_tax, line_total
    ) 
    SELECT 
        order1_id, 
        p.id,
        p.name,
        p.description,
        p.price,
        1,
        p.price,
        p.price * 0.08,
        p.price * 1.08
    FROM products p 
    WHERE p.name = 'Premium Wireless Headphones' 
    LIMIT 1;

    INSERT INTO order_items (
        order_id, product_id, product_name, product_description, 
        unit_price, quantity, line_subtotal, line_tax, line_total
    ) 
    SELECT 
        order1_id, 
        p.id,
        p.name,
        p.description,
        p.price,
        1,
        p.price,
        p.price * 0.08,
        p.price * 1.08
    FROM products p 
    WHERE p.name = 'Smart Health Tracker' 
    LIMIT 1;

    INSERT INTO order_items (
        order_id, product_id, product_name, product_description, 
        unit_price, quantity, line_subtotal, line_tax, line_total
    ) 
    SELECT 
        order2_id, 
        p.id,
        p.name,
        p.description,
        p.price,
        1,
        p.price,
        p.price * 0.08,
        p.price * 1.08
    FROM products p 
    WHERE p.name = 'Mechanical Gaming Keyboard Pro' 
    LIMIT 1;

    INSERT INTO order_items (
        order_id, product_id, product_name, product_description, 
        unit_price, quantity, line_subtotal, line_tax, line_total
    ) 
    SELECT 
        order3_id, 
        p.id,
        p.name,
        p.description,
        p.price,
        1,
        p.price,
        p.price * 0.08,
        p.price * 1.08
    FROM products p 
    WHERE p.name IN ('4K Action Camera Pro', 'Ultra-HD Webcam', 'Portable External SSD')
    LIMIT 3;

    -- Output summary
    RAISE NOTICE 'Seeded data successfully!';
    RAISE NOTICE 'Users: %, Addresses: %, Orders: %, Order Items: %',
        (SELECT COUNT(*) FROM users),
        (SELECT COUNT(*) FROM addresses),
        (SELECT COUNT(*) FROM orders),
        (SELECT COUNT(*) FROM order_items);
END $$;
```

---

### Implementation Step 5: Complex JOIN Queries

#### 5.1 INNER JOIN

Returns only rows that have matching records in both tables:

```sql
-- Get complete order details with user info and items
SELECT 
    o.order_number,
    u.full_name AS customer,
    u.email,
    o.total,
    o.status,
    o.order_date,
    oi.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM orders o
INNER JOIN users u ON o.user_id = u.id
INNER JOIN order_items oi ON o.id = oi.order_id
WHERE o.deleted_at IS NULL
ORDER BY o.order_date DESC, oi.created_at;
```

**The Verification**: You should see all orders with their customer details and each item within the order.

#### 5.2 LEFT JOIN

Returns all rows from the left table, even if there are no matches in the right table:

```sql
-- Show all users and their orders (including users with no orders)
SELECT 
    u.full_name,
    u.email,
    o.order_number,
    o.total,
    o.status
FROM users u
LEFT JOIN orders o ON u.id = o.user_id AND o.deleted_at IS NULL
WHERE u.deleted_at IS NULL
ORDER BY u.full_name;

-- Show all products and whether they've been ordered
SELECT 
    p.name AS product,
    oi.order_id IS NOT NULL AS has_been_ordered,
    COUNT(oi.id) AS times_ordered
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE p.deleted_at IS NULL
GROUP BY p.name, oi.order_id IS NOT NULL
ORDER BY p.name;
```

**The Verification**: You should see all users, including those with no orders, and all products with order counts.

#### 5.3 Multiple Joins

```sql
-- Complex query: Full order details with addresses
SELECT 
    o.order_number,
    o.order_date,
    o.status,
    o.total,
    u.full_name AS customer_name,
    u.email AS customer_email,
    sa.address_line1 AS shipping_address,
    sa.city AS shipping_city,
    sa.state AS shipping_state,
    ba.address_line1 AS billing_address,
    ba.city AS billing_city,
    ba.state AS billing_state,
    (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) AS item_count
FROM orders o
INNER JOIN users u ON o.user_id = u.id
INNER JOIN addresses sa ON o.shipping_address_id = sa.id
INNER JOIN addresses ba ON o.billing_address_id = ba.id
WHERE o.deleted_at IS NULL
ORDER BY o.order_date DESC;
```

#### 5.4 Aggregations with Joins

```sql
-- Customer lifetime value
SELECT 
    u.id,
    u.full_name,
    u.email,
    COUNT(DISTINCT o.id) AS total_orders,
    SUM(o.total) AS total_spent,
    AVG(o.total) AS average_order_value,
    MIN(o.total) AS smallest_order,
    MAX(o.total) AS largest_order
FROM users u
LEFT JOIN orders o ON u.id = o.user_id 
    AND o.deleted_at IS NULL 
    AND o.status NOT IN ('cancelled', 'refunded')
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.full_name, u.email
HAVING COUNT(DISTINCT o.id) > 0
ORDER BY total_spent DESC;
```

---

### Implementation Step 6: Using Database Branches for Development

#### 6.1 Working with Branches Workflow

**Development Workflow**:

1. Create a dev branch from main:
```bash
neonctl branches create --name dev-branch --parent main --project-id your-project-id
```

2. Connect to dev branch and make changes:
```bash
psql "postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/dev-branch?sslmode=require"
```

3. Create and test new tables:
```sql
-- In dev branch
CREATE TABLE IF NOT EXISTS wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

4. Test thoroughly in dev branch

5. When ready, merge to main:
```bash
neonctl branches merge dev-branch --target main --project-id your-project-id
```

#### 6.2 Preview Environments with Branches

Create a branch for each pull request:

```bash
# In CI/CD pipeline (like GitHub Actions)
BRANCH_NAME="pr-${PR_NUMBER}"
neonctl branches create --name "$BRANCH_NAME" --parent main --project-id $PROJECT_ID

# Run tests on this branch
psql "$(neonctl branches get-connection-string $BRANCH_NAME)" -f test_data.sql
npm test

# Clean up
neonctl branches delete "$BRANCH_NAME" --project-id $PROJECT_ID
```

---

### Implementation Step 7: Safe Migration Scripts

#### 7.1 Migration with Rolling Back

Create `migrations/003_add_wishlists.sql`:

```sql
-- migrations/003_add_wishlists.sql
-- Add wishlists feature

-- Check if we're on the correct branch (optional safety)
DO $$
BEGIN
    IF current_database() = 'production' THEN
        RAISE EXCEPTION 'Cannot run this migration on production database! Use a branch first.';
    END IF;
END $$;

-- Create table
CREATE TABLE IF NOT EXISTS wishlists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure a user can't add same product twice
    CONSTRAINT unique_user_product UNIQUE (user_id, product_id)
);

-- Create indexes
CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);
CREATE INDEX idx_wishlists_product_id ON wishlists(product_id);

-- Create trigger for updated_at
CREATE TRIGGER update_wishlists_updated_at 
    BEFORE UPDATE ON wishlists 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

SELECT 'Wishlists table created successfully!' AS status;
```

Create `migrations/003_rollback_wishlists.sql`:

```sql
-- migrations/003_rollback_wishlists.sql
-- Rollback wishlists migration

DROP TRIGGER IF EXISTS update_wishlists_updated_at ON wishlists;
DROP TABLE IF EXISTS wishlists;

SELECT 'Wishlists table rolled back successfully!' AS status;
```

#### 7.2 Testing Migrations with Branches

```bash
# 1. Create a test branch
neonctl branches create --name test-migration --parent main --project-id your-project-id

# 2. Run migration on test branch
psql "$(neonctl branches get-connection-string test-migration)" -f migrations/003_add_wishlists.sql

# 3. Test the migration
psql "$(neonctl branches get-connection-string test-migration)" -c "INSERT INTO wishlists (user_id, product_id) SELECT id, 1 FROM users LIMIT 1;"

# 4. If tests pass, merge to main
neonctl branches merge test-migration --target main --project-id your-project-id

# 5. Clean up test branch
neonctl branches delete test-migration --project-id your-project-id
```

---

### Implementation Step 8: Complex Relational Queries Exercise

#### 8.1 E-commerce Analytics

```sql
-- Monthly revenue report with growth
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total) AS revenue,
        COUNT(*) AS orders_count,
        COUNT(DISTINCT user_id) AS unique_customers
    FROM orders
    WHERE status NOT IN ('cancelled', 'refunded')
      AND deleted_at IS NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    revenue,
    orders_count,
    unique_customers,
    revenue / orders_count AS avg_order_value,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    CASE 
        WHEN LAG(revenue) OVER (ORDER BY month) IS NOT NULL 
        THEN ((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month)) * 100
        ELSE NULL 
    END AS growth_percentage
FROM monthly_revenue
ORDER BY month DESC;

-- Top 5 products by revenue
SELECT 
    p.name,
    p.price,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS total_revenue,
    COUNT(DISTINCT o.user_id) AS unique_customers
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
  AND p.deleted_at IS NULL
GROUP BY p.id, p.name, p.price
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer retention analysis
WITH customer_orders AS (
    SELECT 
        user_id,
        COUNT(*) AS order_count,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        AVG(total) AS avg_order_value
    FROM orders
    WHERE status NOT IN ('cancelled', 'refunded')
      AND deleted_at IS NULL
    GROUP BY user_id
)
SELECT 
    CASE 
        WHEN order_count = 1 THEN 'New'
        WHEN order_count BETWEEN 2 AND 5 THEN 'Regular'
        WHEN order_count > 5 THEN 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customers,
    AVG(order_count) AS avg_orders,
    AVG(avg_order_value) AS avg_order_value
FROM customer_orders
GROUP BY customer_segment
ORDER BY customers DESC;
```

---

### Verification Checklist

Before moving to Part 4, confirm you can:

- [ ] Create a Neon branch using both console and CLI
- [ ] Connect to a branch using its specific connection string
- [ ] Create tables with FOREIGN KEY constraints
- [ ] Understand CASCADE rules (CASCADE, RESTRICT, SET NULL)
- [ ] Insert data into related tables
- [ ] Write INNER JOIN queries across multiple tables
- [ ] Write LEFT JOIN queries to find missing relationships
- [ ] Use aggregations with joins for reporting
- [ ] Create and test a migration on a branch
- [ ] Merge a branch back to main

---

### Deep Dive: PostgreSQL Transaction Isolation

When dealing with multiple tables and foreign keys, understanding transactions is crucial:

```sql
-- Transactions ensure all-or-nothing execution
BEGIN;

-- Create an order and its items in a single transaction
INSERT INTO orders (user_id, shipping_address_id, billing_address_id, order_number, total)
VALUES (user_id, addr_id, addr_id, 'ORD-2024-0004', 99.99);

-- Get the order ID
SELECT currval('orders_id_seq') INTO order_id;

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
VALUES (order_id, product_id, 1, 99.99, 99.99);

-- Update product inventory (if we had an inventory table)
-- UPDATE inventory SET quantity = quantity - 1 WHERE product_id = product_id;

-- If everything worked, commit
COMMIT;

-- If something went wrong, roll back
-- ROLLBACK;
```

**Isolation Levels**:

```sql
-- Set transaction isolation level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- Default, prevents dirty reads
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ; -- Prevents non-repeatable reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;    -- Prevents all concurrency issues
```

---

### Common Pitfalls to Avoid

1. **Forgetting ON DELETE rules**: Always specify what happens when parent records are deleted
2. **Not indexing foreign keys**: Foreign key columns should be indexed for JOIN performance
3. **Ignoring branch-specific connection strings**: Each branch has its own connection string
4. **Merging without testing**: Always test migrations on a branch before merging to main
5. **Circular references**: Avoid foreign keys that create cycles (A references B, B references A)
6. **Deep nested joins**: More than 5-6 joins can hurt performance

---

### What's Next?

Fantastic work! You've built a complete relational e-commerce database and mastered Neon's branching feature. In Part 4, we'll:

- Use aggregate functions (COUNT, SUM, AVG, MIN, MAX)
- Group data with GROUP BY and filter with HAVING
- Learn advanced analytics with Window Functions
- Write conditional logic with CASE WHEN
- Generate real-time business reports

You're building the analytical power of your e-commerce backend!
