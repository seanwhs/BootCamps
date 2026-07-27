# Part 3: Relationships & Relational Queries (Joins & Keys)

Our `users` and `products` tables are complete, but they exist in isolation. In this part, we'll connect them using relationships, foreign keys, and joins. Think of this as building the roads between separate buildings—users need to place orders, and orders contain products. We'll build the entire order management system from scratch.

## Phase 3.1: Understanding Database Relationships

### The Target
Understand the three types of relationships in relational databases and map them to e-commerce concepts.

### The Concept
Relationships define how tables connect to each other. Think of them like family relationships:
- **One-to-One**: Each person has one passport (rarely used in e-commerce)
- **One-to-Many**: One customer can have many orders
- **Many-to-Many**: Many products can be in many categories

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create a visual representation of relationships with comments
-- One-to-Many: users -> orders (one user has many orders)
-- One-to-Many: orders -> order_items (one order has many items)
-- Many-to-One: order_items -> products (many order items reference one product)
-- Many-to-Many: products <-> categories (via product_categories junction table)

-- Let's create our relationship structure step by step
```

---

## Phase 3.2: Creating the Orders Table (One-to-Many with Users)

### The Target
Create the `orders` table with a foreign key to `users`.

### The Concept
A foreign key is like a pointer from one table to another. In our `orders` table, `user_id` points to the `id` column in `users`. This creates a one-to-many relationship: one user can have many orders. Foreign keys enforce referential integrity—you can't create an order for a user that doesn't exist.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Drop existing tables if they exist (in correct order to avoid FK errors)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Create the orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign key to users table
    -- This creates a one-to-many relationship: one user -> many orders
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    
    -- Order status: track the order lifecycle
    -- 'pending' -> 'paid' -> 'shipped' -> 'delivered' -> 'cancelled'
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    
    -- Order totals
    subtotal NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    tax NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (tax >= 0),
    shipping_cost NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
    total NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (total >= 0),
    
    -- Shipping information (snapshot of user's address at order time)
    shipping_address_line1 VARCHAR(255) NOT NULL,
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100) NOT NULL,
    shipping_state VARCHAR(50),
    shipping_postal_code VARCHAR(20) NOT NULL,
    shipping_country VARCHAR(100) NOT NULL DEFAULT 'US',
    
    -- Payment information (simplified)
    payment_method VARCHAR(50), -- 'credit_card', 'paypal', 'bank_transfer'
    payment_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded'
    payment_transaction_id VARCHAR(255),
    
    -- Tracking information
    tracking_number VARCHAR(100),
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    
    -- Notes
    notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Order constraints
    CONSTRAINT valid_order_status CHECK (
        status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')
    ),
    CONSTRAINT valid_payment_status CHECK (
        payment_status IN ('pending', 'completed', 'failed', 'refunded')
    )
);

-- Create indexes for common queries
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_orders_created_at_status ON orders(created_at, status);

-- Create the updated_at trigger
DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verify the table
\d orders
```

### The Verification

```bash
# Check the table structure
psql -d ecommerce -c "\d orders"

# Test foreign key constraint - this should fail because user doesn't exist
psql -d ecommerce -c "INSERT INTO orders (user_id) VALUES ('11111111-1111-1111-1111-111111111111');"
# Expected ERROR: insert or update on table "orders" violates foreign key constraint

# Get a valid user ID for testing
psql -d ecommerce -c "SELECT id FROM users LIMIT 1;"
# Copy the ID and use it in the next command
```

---

## Phase 3.3: Creating the Order Items Table (One-to-Many with Orders and Many-to-One with Products)

### The Target
Create the `order_items` table that connects orders to products.

### The Concept
An order is a header, and order items are the lines. Each item belongs to exactly one order and references exactly one product. This is a many-to-one relationship from items to orders, and many-to-one from items to products. We snapshot the price at order time so it doesn't change if the product price changes later.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create the order_items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign key to orders (many items belong to one order)
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    
    -- Foreign key to products (many items reference one product)
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Snapshot of product data at order time (price may change later)
    product_name TEXT NOT NULL,      -- Snapshot of product name
    product_sku VARCHAR(255),        -- Snapshot of product SKU
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0),
    
    -- Additional details
    product_options JSONB,           -- Store selected options (size, color, etc.)
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Unique constraint: one product per order (can't add same product twice)
    -- This ensures we don't duplicate items in the same order
    CONSTRAINT unique_order_product UNIQUE (order_id, product_id)
);

-- Create indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);

-- Create the updated_at trigger
DROP TRIGGER IF EXISTS update_order_items_updated_at ON order_items;
CREATE TRIGGER update_order_items_updated_at
    BEFORE UPDATE ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Verify the table
\d order_items
```

### The Verification

```bash
# Check table structure
psql -d ecommerce -c "\d order_items"

# Test foreign key constraints
# This should fail because order doesn't exist
psql -d ecommerce -c "INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, total_price) VALUES ('11111111-1111-1111-1111-111111111111', 1, 'Test', 10.00, 1, 10.00);"

# This should fail because product doesn't exist
psql -d ecommerce -c "INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, total_price) VALUES (gen_random_uuid(), 9999, 'Test', 10.00, 1, 10.00);"
```

---

## Phase 3.4: Building the Category System (Many-to-Many)

### The Target
Create categories and a junction table for many-to-many relationships with products.

### The Concept
A many-to-many relationship requires a "junction table." Think of it like a meeting scheduler: products and categories are like two groups of people, and the junction table is the meeting room where they connect. One product can belong to many categories, and one category can contain many products.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create the categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    
    -- For hierarchical categories (e.g., Electronics > Audio > Headphones)
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);

-- Create the updated_at trigger
DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create the junction table (many-to-many between products and categories)
CREATE TABLE product_categories (
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Primary key is the combination of both foreign keys
    PRIMARY KEY (product_id, category_id)
);

-- Create indexes for faster lookups
CREATE INDEX idx_product_categories_product_id ON product_categories(product_id);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);

-- Insert initial categories
INSERT INTO categories (name, slug, description) VALUES
    ('Electronics', 'electronics', 'Electronic devices and accessories'),
    ('Audio', 'audio', 'Headphones, speakers, and audio equipment'),
    ('Computer Accessories', 'computer-accessories', 'Keyboards, mice, and computer peripherals'),
    ('Home & Kitchen', 'home-kitchen', 'Kitchenware, home goods, and appliances'),
    ('Office Supplies', 'office-supplies', 'Stationery and office equipment'),
    ('Health & Fitness', 'health-fitness', 'Fitness equipment and health products'),
    ('Bags & Luggage', 'bags-luggage', 'Bags, backpacks, and travel gear');

-- Insert subcategories (with parent_id)
INSERT INTO categories (name, slug, description, parent_id) VALUES
    ('Headphones', 'headphones', 'Headphones and earphones', 
        (SELECT id FROM categories WHERE slug = 'audio')),
    ('Speakers', 'speakers', 'Bluetooth and wired speakers',
        (SELECT id FROM categories WHERE slug = 'audio')),
    ('Keyboards', 'keyboards', 'Mechanical and membrane keyboards',
        (SELECT id FROM categories WHERE slug = 'computer-accessories')),
    ('Mice', 'mice', 'Wired and wireless mice',
        (SELECT id FROM categories WHERE slug = 'computer-accessories'));

-- Verify categories
SELECT * FROM categories ORDER BY parent_id NULLS FIRST, name;
```

### The Verification

```bash
# Check categories
psql -d ecommerce -c "SELECT * FROM categories;"

# Check hierarchical structure
psql -d ecommerce -c "
SELECT 
    c1.name AS category,
    c2.name AS subcategory
FROM categories c1
LEFT JOIN categories c2 ON c2.parent_id = c1.id
WHERE c1.parent_id IS NULL
ORDER BY c1.name, c2.name;"

# Check junction table
psql -d ecommerce -c "\d product_categories"
```

---

## Phase 3.5: Creating Complete Orders with Sample Data

### The Target
Create complete orders with multiple items and assign products to categories.

### The Concept
Now we'll tie everything together by creating real orders. We'll insert an order, add items to it, and assign categories to products. This simulates a customer placing an order in our e-commerce system.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Get some user and product IDs for our data
-- Let's create variables (in psql, we'll use subqueries)

-- 1. First, assign categories to products
-- Electronics products
INSERT INTO product_categories (product_id, category_id)
SELECT 
    p.id,
    c.id
FROM products p
CROSS JOIN categories c
WHERE 
    -- Match products to categories
    (p.name ILIKE '%headphone%' OR p.name ILIKE '%earbud%' OR p.name ILIKE '%speaker%') 
    AND c.slug IN ('audio', 'electronics')
UNION
SELECT 
    p.id,
    c.id
FROM products p
CROSS JOIN categories c
WHERE 
    -- More product-category mappings
    (p.name ILIKE '%keyboard%' OR p.name ILIKE '%mouse%' OR p.name ILIKE '%stand%') 
    AND c.slug IN ('computer-accessories', 'electronics')
UNION
SELECT 
    p.id,
    c.id
FROM products p
CROSS JOIN categories c
WHERE 
    p.name ILIKE '%water bottle%' 
    AND c.slug IN ('home-kitchen', 'health-fitness');

-- 2. Create an order for a specific user
-- Get a user ID (let's use the first user in our system)
WITH selected_user AS (
    SELECT id FROM users LIMIT 1
),
new_order AS (
    INSERT INTO orders (
        user_id,
        status,
        shipping_address_line1,
        shipping_city,
        shipping_state,
        shipping_postal_code,
        shipping_country,
        payment_method,
        payment_status
    ) 
    SELECT 
        id,
        'pending',
        '123 Main St',
        'New York',
        'NY',
        '10001',
        'US',
        'credit_card',
        'pending'
    FROM selected_user
    RETURNING id
)
-- Get the order ID
SELECT id FROM new_order;

-- 3. Add items to the order
-- Use the order ID from above (replace with actual UUID)
-- Let's create a complete order with multiple items
DO $$
DECLARE
    order_id UUID;
    product_record RECORD;
BEGIN
    -- Get the most recent pending order
    SELECT id INTO order_id 
    FROM orders 
    WHERE status = 'pending' 
    ORDER BY created_at DESC 
    LIMIT 1;
    
    -- Add first item: Wireless Headphones
    INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        product_sku,
        unit_price,
        quantity,
        total_price,
        product_options
    )
    SELECT 
        order_id,
        id,
        name,
        slug,
        price,
        1,
        price,
        '{"color": "black", "warranty": "2 years"}'::jsonb
    FROM products 
    WHERE slug = 'wireless-bluetooth-headphones'
    LIMIT 1;
    
    -- Add second item: USB Cable
    INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        product_sku,
        unit_price,
        quantity,
        total_price
    )
    SELECT 
        order_id,
        id,
        name,
        slug,
        price,
        2,
        price * 2
    FROM products 
    WHERE slug = 'usb-c-charging-cable'
    LIMIT 1;
    
    -- Add third item: Laptop Stand
    INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        product_sku,
        unit_price,
        quantity,
        total_price,
        product_options
    )
    SELECT 
        order_id,
        id,
        name,
        slug,
        price,
        1,
        price,
        '{"color": "silver", "adjustable": true}'::jsonb
    FROM products 
    WHERE slug = 'laptop-stand'
    LIMIT 1;
    
    -- Update the order totals
    UPDATE orders 
    SET 
        subtotal = (
            SELECT SUM(total_price) FROM order_items WHERE order_id = orders.id
        ),
        tax = subtotal * 0.08, -- 8% tax
        shipping_cost = CASE 
            WHEN subtotal > 50 THEN 0 
            ELSE 5.99 
        END,
        total = subtotal + tax + shipping_cost,
        status = 'paid',
        payment_status = 'completed'
    WHERE id = order_id;
    
    RAISE NOTICE 'Created order with ID: %', order_id;
END $$;

-- Create a second order for testing
DO $$
DECLARE
    user_id UUID;
    order_id UUID;
BEGIN
    -- Get a different user
    SELECT id INTO user_id 
    FROM users 
    WHERE email != 'admin@example.com' 
    LIMIT 1;
    
    -- Create order
    INSERT INTO orders (
        user_id,
        status,
        shipping_address_line1,
        shipping_city,
        shipping_state,
        shipping_postal_code,
        shipping_country,
        payment_method,
        payment_status
    ) VALUES (
        user_id,
        'pending',
        '456 Oak Avenue',
        'Los Angeles',
        'CA',
        '90001',
        'US',
        'paypal',
        'pending'
    )
    RETURNING id INTO order_id;
    
    -- Add a single item
    INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        product_sku,
        unit_price,
        quantity,
        total_price
    )
    SELECT 
        order_id,
        id,
        name,
        slug,
        price,
        1,
        price
    FROM products 
    WHERE slug = 'wireless-mouse'
    LIMIT 1;
    
    -- Update totals
    UPDATE orders 
    SET 
        subtotal = (SELECT SUM(total_price) FROM order_items WHERE order_id = orders.id),
        tax = subtotal * 0.08,
        shipping_cost = CASE 
            WHEN subtotal > 50 THEN 0 
            ELSE 5.99 
        END,
        total = subtotal + tax + shipping_cost
    WHERE id = order_id;
END $$;

-- Verify the data
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
```

### The Verification

```bash
# Check orders
psql -d ecommerce -c "SELECT id, user_id, status, subtotal, tax, total FROM orders;"

# Check order items
psql -d ecommerce -c "SELECT order_id, product_name, quantity, unit_price, total_price FROM order_items;"

# Check product categories
psql -d ecommerce -c "
SELECT 
    p.name AS product,
    c.name AS category
FROM products p
JOIN product_categories pc ON pc.product_id = p.id
JOIN categories c ON c.id = pc.category_id
ORDER BY product, category;"
```

---

## Phase 3.6: Mastering JOIN Operations

### The Target
Learn and practice all types of JOINs to combine data from multiple tables.

### The Concept
JOINs are how we combine data from multiple tables in a single query. Think of them as different ways to merge two lists:
- **INNER JOIN**: Only matching rows (like intersection)
- **LEFT JOIN**: All rows from left table, plus matches (like left-dominant merge)
- **RIGHT JOIN**: All rows from right table, plus matches (like right-dominant merge)
- **FULL JOIN**: All rows from both tables (like union)

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. INNER JOIN: Get orders with user information
-- Only shows orders that have a matching user
SELECT 
    o.id AS order_id,
    u.email AS user_email,
    u.first_name,
    u.last_name,
    o.status,
    o.total AS order_total,
    o.created_at
FROM orders o
INNER JOIN users u ON u.id = o.user_id
ORDER BY o.created_at DESC;

-- 2. LEFT JOIN: All users, even those without orders
-- Shows all users, order info is NULL if no orders
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    o.id AS order_id,
    o.status,
    o.total
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.is_active = true
ORDER BY u.email, o.created_at;

-- 3. Complex JOIN with multiple tables
-- Get complete order details including items and products
SELECT 
    o.id AS order_id,
    u.email AS customer_email,
    o.status,
    o.total,
    o.created_at,
    oi.product_name,
    oi.quantity,
    oi.unit_price,
    oi.total_price AS item_total,
    p.stock_quantity AS current_stock
FROM orders o
INNER JOIN users u ON u.id = o.user_id
INNER JOIN order_items oi ON oi.order_id = o.id
INNER JOIN products p ON p.id = oi.product_id
WHERE o.status != 'cancelled'
ORDER BY o.created_at DESC, oi.created_at;

-- 4. JOIN with aggregation (we'll cover this more in Part 4)
-- Get order summary with item count
SELECT 
    o.id AS order_id,
    u.email,
    COUNT(oi.id) AS item_count,
    SUM(oi.quantity) AS total_quantity,
    o.total
FROM orders o
INNER JOIN users u ON u.id = o.user_id
INNER JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, u.email, o.total
HAVING COUNT(oi.id) > 0
ORDER BY item_count DESC;

-- 5. Self JOIN: Product categories with parent-child relationships
-- Get categories with their parent names
SELECT 
    c1.name AS category,
    c2.name AS parent_category,
    c1.slug
FROM categories c1
LEFT JOIN categories c2 ON c2.id = c1.parent_id
WHERE c1.is_active = true
ORDER BY parent_category NULLS FIRST, category;

-- 6. Multi-table JOIN with JSONB
-- Get product details with category and JSONB options
SELECT 
    p.name AS product_name,
    p.price,
    array_agg(c.name) AS categories,
    p.slug,
    p.stock_quantity
FROM products p
LEFT JOIN product_categories pc ON pc.product_id = p.id
LEFT JOIN categories c ON c.id = pc.category_id
WHERE p.is_active = true
GROUP BY p.id, p.name, p.price, p.slug, p.stock_quantity
HAVING array_agg(c.name) IS NOT NULL
ORDER BY p.name;

-- 7. LEFT JOIN with condition (finding users with no orders)
SELECT 
    u.email,
    u.first_name,
    u.last_name,
    COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.email, u.first_name, u.last_name
HAVING COUNT(o.id) = 0
ORDER BY u.email;
```

### The Verification

```bash
# Test each join query

# 1. INNER JOIN - should show all orders with user info
psql -d ecommerce -c "
SELECT o.id, u.email, o.total 
FROM orders o 
INNER JOIN users u ON u.id = o.user_id 
LIMIT 5;"

# 2. LEFT JOIN - should show all users including those without orders
psql -d ecommerce -c "
SELECT u.email, COUNT(o.id) AS order_count
FROM users u 
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.email
ORDER BY order_count DESC;"

# 3. Complex JOIN - full order details
psql -d ecommerce -c "
SELECT o.id, u.email, oi.product_name, oi.quantity
FROM orders o
INNER JOIN users u ON u.id = o.user_id
INNER JOIN order_items oi ON oi.order_id = o.id
LIMIT 10;"
```

---

## Phase 3.7: Cascading Actions (DELETE CASCADE)

### The Target
Understand and implement cascade actions for maintaining referential integrity.

### The Concept
Cascade actions define what happens when a parent record is deleted. With `ON DELETE CASCADE`, deleting a user also deletes their orders (and order items). This is like dominoes—one action triggers a chain reaction. With `ON DELETE RESTRICT`, the delete is blocked if child records exist.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create a test user with orders
DO $$
DECLARE
    test_user_id UUID;
    test_order_id UUID;
BEGIN
    -- Insert test user
    INSERT INTO users (
        email, password_hash, first_name, last_name
    ) VALUES (
        'test.cascade@example.com',
        'hash',
        'Cascade',
        'Test'
    )
    RETURNING id INTO test_user_id;
    
    -- Insert test order
    INSERT INTO orders (
        user_id,
        status,
        shipping_address_line1,
        shipping_city,
        shipping_postal_code,
        shipping_country
    ) VALUES (
        test_user_id,
        'pending',
        '123 Test St',
        'Test City',
        '12345',
        'US'
    )
    RETURNING id INTO test_order_id;
    
    -- Insert test order item
    INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        unit_price,
        quantity,
        total_price
    ) VALUES (
        test_order_id,
        (SELECT id FROM products LIMIT 1),
        'Test Product',
        10.00,
        1,
        10.00
    );
    
    RAISE NOTICE 'Created test user with order: %', test_user_id;
END $$;

-- Verify the test data
SELECT u.email, o.id, o.status 
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE u.email = 'test.cascade@example.com';

-- Now delete the user - this should cascade to orders and order_items
DELETE FROM users WHERE email = 'test.cascade@example.com';

-- Verify cascade deletion worked
-- This should return no rows
SELECT u.email, o.id, o.status 
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE u.email = 'test.cascade@example.com';

-- The order and order items should also be gone
SELECT COUNT(*) FROM orders WHERE user_id IN (
    SELECT id FROM users WHERE email = 'test.cascade@example.com'
);

-- Show cascade behavior with order_items
-- Create another test user with order
DO $$
DECLARE
    test_user_id UUID;
    test_order_id UUID;
BEGIN
    INSERT INTO users (email, password_hash, first_name, last_name) 
    VALUES ('test.cascade2@example.com', 'hash', 'Cascade2', 'Test')
    RETURNING id INTO test_user_id;
    
    INSERT INTO orders (user_id, status, shipping_address_line1, shipping_city, shipping_postal_code, shipping_country)
    VALUES (test_user_id, 'pending', '456 Test Ave', 'Testville', '67890', 'US')
    RETURNING id INTO test_order_id;
    
    INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, total_price)
    VALUES (test_order_id, (SELECT id FROM products LIMIT 1), 'Test Product 2', 15.00, 2, 30.00);
    
    RAISE NOTICE 'Created test data with order items';
END $$;

-- Delete the user and all associated data cascades
DELETE FROM users WHERE email = 'test.cascade2@example.com';

-- Verify nothing remains
SELECT COUNT(*) FROM users WHERE email LIKE 'test.cascade%';
SELECT COUNT(*) FROM orders WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'test.cascade%');
```

### The Verification

```bash
# Verify cascade deletion
psql -d ecommerce -c "SELECT * FROM users WHERE email LIKE 'test.cascade%';"
psql -d ecommerce -c "SELECT * FROM orders WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'test.cascade%');"

# Should return 0 rows for both queries
```

---

## Phase 3.8: Complete Orders Setup Script

### The Target
Create a complete setup script for the entire orders system.

### The Concept
We now have all the pieces: users, products, categories, orders, and order items. We'll create a comprehensive setup script that builds everything and includes sample data.

### The Implementation

Create a file called `03_orders_setup.sql`:

```sql
-- 03_orders_setup.sql
-- Complete setup script for orders, order_items, categories, and relationships

\c ecommerce

-- Ensure UUID extension is available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop everything in correct order (cascade takes care of dependencies)
DROP VIEW IF EXISTS active_users CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Create categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);

-- Insert main categories
INSERT INTO categories (name, slug, description) VALUES
    ('Electronics', 'electronics', 'Electronic devices and accessories'),
    ('Audio', 'audio', 'Headphones, speakers, and audio equipment'),
    ('Computer Accessories', 'computer-accessories', 'Keyboards, mice, and computer peripherals'),
    ('Home & Kitchen', 'home-kitchen', 'Kitchenware, home goods, and appliances'),
    ('Office Supplies', 'office-supplies', 'Stationery and office equipment'),
    ('Health & Fitness', 'health-fitness', 'Fitness equipment and health products'),
    ('Bags & Luggage', 'bags-luggage', 'Bags, backpacks, and travel gear');

-- Insert subcategories
INSERT INTO categories (name, slug, description, parent_id) VALUES
    ('Headphones', 'headphones', 'Headphones and earphones', 
        (SELECT id FROM categories WHERE slug = 'audio')),
    ('Speakers', 'speakers', 'Bluetooth and wired speakers',
        (SELECT id FROM categories WHERE slug = 'audio')),
    ('Keyboards', 'keyboards', 'Mechanical and membrane keyboards',
        (SELECT id FROM categories WHERE slug = 'computer-accessories')),
    ('Mice', 'mice', 'Wired and wireless mice',
        (SELECT id FROM categories WHERE slug = 'computer-accessories'));

-- Create orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    subtotal NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    tax NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (tax >= 0),
    shipping_cost NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
    total NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (total >= 0),
    shipping_address_line1 VARCHAR(255) NOT NULL,
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100) NOT NULL,
    shipping_state VARCHAR(50),
    shipping_postal_code VARCHAR(20) NOT NULL,
    shipping_country VARCHAR(100) NOT NULL DEFAULT 'US',
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending',
    payment_transaction_id VARCHAR(255),
    tracking_number VARCHAR(100),
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT valid_order_status CHECK (
        status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')
    ),
    CONSTRAINT valid_payment_status CHECK (
        payment_status IN ('pending', 'completed', 'failed', 'refunded')
    )
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Create order_items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name TEXT NOT NULL,
    product_sku VARCHAR(255),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0),
    product_options JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_order_product UNIQUE (order_id, product_id)
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Create product_categories junction table
CREATE TABLE product_categories (
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (product_id, category_id)
);

CREATE INDEX idx_product_categories_product_id ON product_categories(product_id);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);

-- Add updated_at triggers
DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_order_items_updated_at ON order_items;
CREATE TRIGGER update_order_items_updated_at
    BEFORE UPDATE ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Assign categories to products (more comprehensive)
INSERT INTO product_categories (product_id, category_id)
SELECT p.id, c.id
FROM products p
CROSS JOIN categories c
WHERE 
    (p.name ILIKE '%headphone%' AND c.slug = 'headphones')
    OR (p.name ILIKE '%speaker%' AND c.slug = 'speakers')
    OR (p.name ILIKE '%keyboard%' AND c.slug = 'keyboards')
    OR (p.name ILIKE '%mouse%' AND c.slug = 'mice')
    OR (p.name ILIKE '%laptop stand%' AND c.slug = 'computer-accessories')
    OR (p.name ILIKE '%water bottle%' AND c.slug = 'home-kitchen')
    OR (p.name ILIKE '%charging cable%' AND c.slug = 'electronics');

-- Create sample orders
DO $$
DECLARE
    user_record RECORD;
    order_id UUID;
    product_record RECORD;
BEGIN
    -- For each user, create 1-2 sample orders
    FOR user_record IN 
        SELECT id, first_name, last_name 
        FROM users 
        WHERE is_active = true 
        AND email NOT LIKE 'test%' 
        AND email != 'admin@example.com'
        LIMIT 3
    LOOP
        -- First order
        INSERT INTO orders (
            user_id,
            status,
            shipping_address_line1,
            shipping_city,
            shipping_state,
            shipping_postal_code,
            shipping_country,
            payment_method,
            payment_status
        ) VALUES (
            user_record.id,
            'paid',
            '123 Main St',
            'Sample City',
            'CA',
            '90210',
            'US',
            'credit_card',
            'completed'
        ) RETURNING id INTO order_id;
        
        -- Add 2-3 items
        FOR product_record IN 
            SELECT id, name, slug, price 
            FROM products 
            WHERE is_active = true
            ORDER BY random()
            LIMIT 2 + floor(random() * 2)::int
        LOOP
            INSERT INTO order_items (
                order_id,
                product_id,
                product_name,
                product_sku,
                unit_price,
                quantity,
                total_price
            ) VALUES (
                order_id,
                product_record.id,
                product_record.name,
                product_record.slug,
                product_record.price,
                1 + floor(random() * 3)::int,
                product_record.price * (1 + floor(random() * 3)::int)
            );
        END LOOP;
        
        -- Update order totals
        UPDATE orders 
        SET 
            subtotal = (
                SELECT SUM(total_price) 
                FROM order_items 
                WHERE order_id = orders.id
            ),
            tax = subtotal * 0.08,
            shipping_cost = CASE 
                WHEN subtotal > 50 THEN 0 
                ELSE 5.99 
            END,
            total = subtotal + tax + shipping_cost
        WHERE id = order_id;
    END LOOP;
    
    -- Add one pending order
    INSERT INTO orders (
        user_id,
        status,
        shipping_address_line1,
        shipping_city,
        shipping_state,
        shipping_postal_code,
        shipping_country,
        payment_method,
        payment_status
    ) VALUES (
        (SELECT id FROM users WHERE email = 'demo.user@example.com'),
        'pending',
        '456 Oak St',
        'Los Angeles',
        'CA',
        '90001',
        'US',
        'paypal',
        'pending'
    ) RETURNING id INTO order_id;
    
    INSERT INTO order_items (
        order_id,
        product_id,
        product_name,
        product_sku,
        unit_price,
        quantity,
        total_price
    )
    SELECT 
        order_id,
        id,
        name,
        slug,
        price,
        1,
        price
    FROM products 
    WHERE slug = 'wireless-mouse'
    LIMIT 1;
    
    UPDATE orders 
    SET 
        subtotal = (SELECT SUM(total_price) FROM order_items WHERE order_id = orders.id),
        tax = subtotal * 0.08,
        shipping_cost = CASE 
            WHEN subtotal > 50 THEN 0 
            ELSE 5.99 
        END,
        total = subtotal + tax + shipping_cost
    WHERE id = order_id;
END $$;

-- Report
SELECT 'Orders Setup Complete!' AS status;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_order_items FROM order_items;
SELECT COUNT(*) AS total_categories FROM categories;
SELECT COUNT(*) AS product_category_assignments FROM product_categories;
```

Run the script:

```bash
# Execute the complete setup
psql -d ecommerce -U ecommerce_user -f 03_orders_setup.sql

# Verify everything
psql -d ecommerce -c "SELECT COUNT(*) FROM orders;"
psql -d ecommerce -c "SELECT COUNT(*) FROM order_items;"
psql -d ecommerce -c "SELECT COUNT(*) FROM categories;"
psql -d ecommerce -c "SELECT COUNT(*) FROM product_categories;"
```

### The Verification

```bash
# Run a comprehensive verification
psql -d ecommerce -c "
SELECT 
    'Total Users' AS metric, COUNT(*) AS value FROM users
UNION ALL
SELECT 'Total Products', COUNT(*) FROM products
UNION ALL
SELECT 'Total Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Total Order Items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Total Categories', COUNT(*) FROM categories
UNION ALL
SELECT 'Total Product Categories', COUNT(*) FROM product_categories;"

# Check sample data
psql -d ecommerce -c "
SELECT 
    u.email,
    COUNT(o.id) AS order_count,
    SUM(oi.quantity) AS total_items
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY u.email
HAVING COUNT(o.id) > 0
ORDER BY order_count DESC;"
```

---

## Summary: What You've Accomplished

You've built a complete relational e-commerce system with:

✅ Foreign keys connecting users, orders, and products  
✅ One-to-many relationships (users to orders, orders to order items)  
✅ Many-to-many relationships (products to categories via junction table)  
✅ All four JOIN types (INNER, LEFT, RIGHT, FULL)  
✅ Cascade deletion behaviors  
✅ Complete order creation with multiple items and automatic totals  
✅ Hierarchical categories with self-joins  
✅ Comprehensive setup script for easy deployment  

## What's Next

In **Part 4**, we'll dive into data analysis with aggregations, grouping, and subqueries. You'll learn to generate sales reports, find top customers, and analyze revenue trends.

**Before Part 4**, practice these skills:
1. Create an order with 5 different items
2. Query all orders for a specific user
3. Find products that have never been ordered
4. List all categories with their product count
5. Write a query showing order totals and user information
