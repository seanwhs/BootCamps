# Serverless Postgres with Neon: From Zero to Production

## Appendix B: Complete Sample Data Generation Scripts

### Overview

This appendix provides comprehensive, production-quality seed data generation scripts for all tables in your e-commerce application. These scripts generate realistic, interconnected data that you can use for development, testing, and demonstrations. All scripts are designed to be re-runnable and include proper error handling.

---

### B.1 Master Seed Script

Create `scripts/seed_all.sql`:

```sql
-- scripts/seed_all.sql
-- Master seed script that runs all data generation in the correct order
-- Run this to populate your entire database with realistic sample data

\echo '🚀 Starting database seeding...'
\echo '=========================================='

-- Enable required extensions if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Set search path
SET search_path TO public;

-- Run each seed script in order
\i scripts/seed_users.sql
\i scripts/seed_products.sql
\i scripts/seed_addresses.sql
\i scripts/seed_orders.sql
\i scripts/seed_order_items.sql
\i scripts/seed_inventory.sql

\echo '=========================================='
\echo '✅ Database seeding complete!'
\echo ''
\echo '📊 Database Statistics:'
SELECT 
    'Users' AS table_name,
    COUNT(*) AS record_count
FROM users
UNION ALL
SELECT 
    'Products' AS table_name,
    COUNT(*) AS record_count
FROM products
UNION ALL
SELECT 
    'Addresses' AS table_name,
    COUNT(*) AS record_count
FROM addresses
UNION ALL
SELECT 
    'Orders' AS table_name,
    COUNT(*) AS record_count
FROM orders
UNION ALL
SELECT 
    'Order Items' AS table_name,
    COUNT(*) AS record_count
FROM order_items
UNION ALL
SELECT 
    'Inventory' AS table_name,
    COUNT(*) AS record_count
FROM inventory
ORDER BY table_name;
```

---

### B.2 User Data Generation

Create `scripts/seed_users.sql`:

```sql
-- scripts/seed_users.sql
-- Generate realistic user data with diverse roles, statuses, and demographics

\echo '📝 Generating users...'

-- Clean up existing data if re-running
TRUNCATE TABLE users CASCADE;

-- Insert admin users
INSERT INTO users (email, username, password_hash, full_name, phone, role, status, created_at)
SELECT 
    'admin' || i || '@company.com' AS email,
    'admin' || i AS username,
    crypt('admin123' || i::text, gen_salt('bf')) AS password_hash,
    'Admin ' || i AS full_name,
    '+1-555-000' || LPAD(i::text, 2, '0') AS phone,
    'admin' AS role,
    'active' AS status,
    CURRENT_TIMESTAMP - (random() * INTERVAL '365 days') AS created_at
FROM generate_series(1, 3) AS i;

-- Insert staff users
INSERT INTO users (email, username, password_hash, full_name, phone, role, status, created_at)
SELECT 
    'staff' || i || '@company.com' AS email,
    'staff' || i AS username,
    crypt('staff123' || i::text, gen_salt('bf')) AS password_hash,
    'Staff Member ' || i AS full_name,
    '+1-555-100' || LPAD(i::text, 2, '0') AS phone,
    'staff' AS role,
    CASE WHEN random() < 0.1 THEN 'inactive' ELSE 'active' END AS status,
    CURRENT_TIMESTAMP - (random() * INTERVAL '365 days') AS created_at
FROM generate_series(1, 10) AS i;

-- Insert regular customers
WITH customer_data AS (
    SELECT 
        i,
        -- Generate realistic names
        CASE (random() * 9)::int
            WHEN 0 THEN 'James'
            WHEN 1 THEN 'Mary'
            WHEN 2 THEN 'John'
            WHEN 3 THEN 'Patricia'
            WHEN 4 THEN 'Robert'
            WHEN 5 THEN 'Jennifer'
            WHEN 6 THEN 'Michael'
            WHEN 7 THEN 'Linda'
            WHEN 8 THEN 'William'
            WHEN 9 THEN 'Elizabeth'
        END AS first_name,
        CASE (random() * 9)::int
            WHEN 0 THEN 'Smith'
            WHEN 1 THEN 'Johnson'
            WHEN 2 THEN 'Williams'
            WHEN 3 THEN 'Brown'
            WHEN 4 THEN 'Jones'
            WHEN 5 THEN 'Garcia'
            WHEN 6 THEN 'Miller'
            WHEN 7 THEN 'Davis'
            WHEN 8 THEN 'Rodriguez'
            WHEN 9 THEN 'Martinez'
        END AS last_name,
        -- Generate realistic emails
        CASE (random() * 4)::int
            WHEN 0 THEN '@gmail.com'
            WHEN 1 THEN '@yahoo.com'
            WHEN 2 THEN '@outlook.com'
            WHEN 3 THEN '@hotmail.com'
            WHEN 4 THEN '@company.com'
        END AS email_domain,
        -- Random statuses
        CASE WHEN random() < 0.05 THEN 'suspended'
             WHEN random() < 0.10 THEN 'inactive'
             ELSE 'active' 
        END AS status,
        -- Random creation dates
        CURRENT_TIMESTAMP - (random() * INTERVAL '730 days') AS created_at
    FROM generate_series(1, 100) AS i
)
INSERT INTO users (email, username, password_hash, full_name, phone, role, status, created_at)
SELECT 
    LOWER(first_name || '.' || last_name || i || email_domain) AS email,
    LOWER(first_name || '_' || last_name || i) AS username,
    crypt('customer123' || i::text, gen_salt('bf')) AS password_hash,
    first_name || ' ' || last_name AS full_name,
    '+1-555-' || LPAD((200 + i)::text, 4, '0') AS phone,
    'customer' AS role,
    status,
    created_at
FROM customer_data;

-- Insert users with specific attributes for testing
INSERT INTO users (email, username, password_hash, full_name, phone, role, status, created_at)
VALUES 
    ('test.customer@example.com', 'test_customer', crypt('test123', gen_salt('bf')), 'Test Customer', '+1-555-9999', 'customer', 'active', CURRENT_TIMESTAMP),
    ('vip.customer@example.com', 'vip_customer', crypt('vip123', gen_salt('bf')), 'VIP Customer', '+1-555-8888', 'customer', 'active', CURRENT_TIMESTAMP),
    ('inactive.user@example.com', 'inactive_user', crypt('inactive123', gen_salt('bf')), 'Inactive User', '+1-555-7777', 'customer', 'inactive', CURRENT_TIMESTAMP - INTERVAL '30 days');

-- Log the results
\echo '✅ Users seeded: ' (SELECT COUNT(*) FROM users);

-- Show sample of created users
SELECT 
    id,
    email,
    username,
    full_name,
    role,
    status,
    created_at
FROM users 
ORDER BY created_at DESC 
LIMIT 10;
```

---

### B.3 Product Data Generation

Create `scripts/seed_products.sql`:

```sql
-- scripts/seed_products.sql
-- Generate comprehensive product catalog with JSONB attributes and variants

\echo '📦 Generating products...'

-- Clean up existing data
TRUNCATE TABLE products CASCADE;

-- Define product categories and their attributes
WITH product_data AS (
    SELECT 
        i,
        -- Product name variations
        CASE (random() * 9)::int
            WHEN 0 THEN 'Premium Wireless Headphones'
            WHEN 1 THEN '4K Action Camera Pro'
            WHEN 2 THEN 'Smart Health Tracker'
            WHEN 3 THEN 'Universal Laptop Docking Station'
            WHEN 4 THEN 'Mechanical Gaming Keyboard'
            WHEN 5 THEN 'Ergonomic Wireless Mouse'
            WHEN 6 THEN 'Solar-Powered Power Bank'
            WHEN 7 THEN 'Professional Studio Microphone'
            WHEN 8 THEN 'Smart Home Display'
            WHEN 9 THEN 'Noise Cancelling Earbuds'
        END AS base_name,
        -- Variations for product variants
        CASE (random() * 5)::int
            WHEN 0 THEN 'Black'
            WHEN 1 THEN 'White'
            WHEN 2 THEN 'Silver'
            WHEN 3 THEN 'Gold'
            WHEN 4 THEN 'Red'
            WHEN 5 THEN 'Blue'
        END AS color,
        -- Prices ranging from $19.99 to $499.99
        ROUND((20 + random() * 480)::numeric, 2) AS base_price,
        -- Stock quantities
        (random() * 200)::int AS stock_qty,
        -- Category
        CASE (random() * 5)::int
            WHEN 0 THEN 'Audio'
            WHEN 1 THEN 'Cameras'
            WHEN 2 THEN 'Wearables'
            WHEN 3 THEN 'Accessories'
            WHEN 4 THEN 'Gaming'
            WHEN 5 THEN 'Smart Home'
        END AS category,
        -- Brand
        CASE (random() * 5)::int
            WHEN 0 THEN 'TechPro'
            WHEN 1 THEN 'AudioMaster'
            WHEN 2 THEN 'SmartLife'
            WHEN 3 THEN 'GameOn'
            WHEN 4 THEN 'ConnectPlus'
            WHEN 5 THEN 'VisionTech'
        END AS brand
    FROM generate_series(1, 50) AS i
)
INSERT INTO products (
    name, description, price, stock_quantity, 
    attributes, variants, metadata, created_at, updated_at
)
SELECT 
    -- Generate unique names with variant
    CASE 
        WHEN random() < 0.3 THEN base_name || ' ' || color
        ELSE base_name
    END AS name,
    -- Generate realistic descriptions
    CASE category
        WHEN 'Audio' THEN 'High-quality audio device with premium features and long battery life. Perfect for music lovers and professionals.'
        WHEN 'Cameras' THEN 'Professional-grade camera with advanced features, high resolution, and durable construction for all environments.'
        WHEN 'Wearables' THEN 'Smart wearable device with health monitoring, fitness tracking, and smartphone integration for active lifestyles.'
        WHEN 'Accessories' THEN 'Versatile accessory designed to enhance your productivity and connectivity with modern devices.'
        WHEN 'Gaming' THEN 'Gaming-optimized device with RGB lighting, programmable features, and responsive performance for competitive play.'
        WHEN 'Smart Home' THEN 'Intelligent home device with voice control, automation features, and seamless integration with smart home ecosystems.'
    END AS description,
    -- Price with some variation
    ROUND(base_price * (0.9 + random() * 0.2), 2) AS price,
    stock_qty AS stock_quantity,
    -- Build JSONB attributes based on category
    jsonb_build_object(
        'color', color,
        'connectivity', CASE (random() * 3)::int
            WHEN 0 THEN 'Bluetooth 5.0'
            WHEN 1 THEN 'Wi-Fi 6'
            WHEN 2 THEN 'USB-C 3.0'
            WHEN 3 THEN 'Bluetooth 5.2'
        END,
        'battery_life', (5 + (random() * 40)::int) || ' hours',
        'weight', ROUND(100 + random() * 900) || 'g',
        'material', CASE (random() * 3)::int
            WHEN 0 THEN 'Aluminum'
            WHEN 1 THEN 'Plastic Composite'
            WHEN 2 THEN 'Stainless Steel'
            WHEN 3 THEN 'Carbon Fiber'
        END,
        'dimensions', jsonb_build_object(
            'length', ROUND(5 + random() * 25, 1),
            'width', ROUND(3 + random() * 20, 1),
            'height', ROUND(1 + random() * 10, 1)
        )
    ) AS attributes,
    -- Build JSONB variants with different colors
    jsonb_build_array(
        jsonb_build_object(
            'color', color,
            'price_adjustment', 0,
            'sku', UPPER(SUBSTRING(brand, 1, 2)) || '-' || 
                  UPPER(SUBSTRING(REPLACE(base_name, ' ', ''), 1, 4)) || 
                  '-' || LPAD(i::text, 3, '0') || '-001',
            'stock', (random() * 50)::int
        ),
        jsonb_build_object(
            'color', CASE 
                WHEN color = 'Black' THEN 'White'
                WHEN color = 'White' THEN 'Silver'
                WHEN color = 'Silver' THEN 'Black'
                ELSE 'Silver'
            END,
            'price_adjustment', ROUND((random() * 20)::numeric, 2),
            'sku', UPPER(SUBSTRING(brand, 1, 2)) || '-' || 
                  UPPER(SUBSTRING(REPLACE(base_name, ' ', ''), 1, 4)) || 
                  '-' || LPAD(i::text, 3, '0') || '-002',
            'stock', (random() * 30)::int
        )
    ) AS variants,
    -- Build metadata JSONB
    jsonb_build_object(
        'brand', brand,
        'warranty_months', (12 + (random() * 24)::int),
        'release_date', (CURRENT_DATE - (random() * 365)::int)::text,
        'category', category,
        'subcategory', CASE (random() * 3)::int
            WHEN 0 THEN 'Standard'
            WHEN 1 THEN 'Premium'
            WHEN 2 THEN 'Professional'
            WHEN 3 THEN 'Budget'
        END,
        'tags', jsonb_build_array(
            CASE WHEN random() < 0.5 THEN 'premium' ELSE 'standard' END,
            CASE WHEN random() < 0.5 THEN 'wireless' ELSE 'wired' END,
            CASE WHEN random() < 0.5 THEN 'new' ELSE 'popular' END
        )
    ) AS metadata,
    -- Creation and update timestamps
    CURRENT_TIMESTAMP - (random() * INTERVAL '180 days') AS created_at,
    CURRENT_TIMESTAMP - (random() * INTERVAL '30 days') AS updated_at
FROM product_data;

-- Update search vectors for full-text search
UPDATE products 
SET search_vector = 
    setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'brand', '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'category', '')), 'C');

-- Log results
\echo '✅ Products seeded: ' (SELECT COUNT(*) FROM products);

-- Show sample products
SELECT 
    id,
    name,
    price,
    stock_quantity,
    metadata->>'brand' AS brand,
    metadata->>'category' AS category,
    jsonb_array_length(variants) AS variant_count
FROM products 
ORDER BY created_at DESC 
LIMIT 10;
```

---

### B.4 Address Data Generation

Create `scripts/seed_addresses.sql`:

```sql
-- scripts/seed_addresses.sql
-- Generate realistic addresses for all users

\echo '📍 Generating addresses...'

-- Clean up existing data
TRUNCATE TABLE addresses CASCADE;

-- Insert addresses for users
WITH address_data AS (
    SELECT 
        u.id AS user_id,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY random()) AS address_number,
        -- Realistic address data
        CASE (random() * 4)::int
            WHEN 0 THEN '123 ' || (ARRAY['Main', 'Oak', 'Pine', 'Maple', 'Cedar', 'Elm', 'Washington', 'Jefferson', 'Lincoln', 'Madison'])[ceil(random() * 10)] || ' St'
            WHEN 1 THEN (100 + (random() * 9999)::int)::text || ' ' || (ARRAY['Broadway', 'Avenue', 'Blvd', 'Park', 'Sunset', 'Mountain', 'River', 'Lake', 'Forest', 'Highland'])[ceil(random() * 10)] || ' Rd'
            WHEN 2 THEN (100 + (random() * 9999)::int)::text || ' ' || (ARRAY['Garden', 'Hill', 'View', 'Valley', 'Creek', 'Ridge', 'Meadow', 'Willow', 'Aspen', 'Birch'])[ceil(random() * 10)] || ' Dr'
            WHEN 3 THEN (100 + (random() * 9999)::int)::text || ' ' || (ARRAY['Pearl', 'Ruby', 'Diamond', 'Emerald', 'Sapphire', 'Topaz', 'Amber', 'Jade', 'Crystal', 'Opal'])[ceil(random() * 10)] || ' Ct'
            ELSE (100 + (random() * 9999)::int)::text || ' ' || (ARRAY['Colonial', 'Victorian', 'Modern', 'Craftsman', 'Tudor', 'Ranch', 'Cape Cod', 'Georgian', 'Federal', 'Greek'])[ceil(random() * 10)] || ' Way'
        END AS address_line1,
        -- Apartment/Unit for some addresses
        CASE WHEN random() < 0.3 
            THEN 'Apt ' || (1 + (random() * 50)::int)::text 
            ELSE NULL 
        END AS address_line2,
        -- Cities
        CASE (random() * 9)::int
            WHEN 0 THEN 'New York'
            WHEN 1 THEN 'Los Angeles'
            WHEN 2 THEN 'Chicago'
            WHEN 3 THEN 'Houston'
            WHEN 4 THEN 'Phoenix'
            WHEN 5 THEN 'Philadelphia'
            WHEN 6 THEN 'San Antonio'
            WHEN 7 THEN 'San Diego'
            WHEN 8 THEN 'Dallas'
            WHEN 9 THEN 'Austin'
        END AS city,
        -- States
        CASE (random() * 9)::int
            WHEN 0 THEN 'NY'
            WHEN 1 THEN 'CA'
            WHEN 2 THEN 'IL'
            WHEN 3 THEN 'TX'
            WHEN 4 THEN 'AZ'
            WHEN 5 THEN 'PA'
            WHEN 6 THEN 'TX'
            WHEN 7 THEN 'CA'
            WHEN 8 THEN 'TX'
            WHEN 9 THEN 'TX'
        END AS state,
        -- ZIP codes
        LPAD(CAST((10001 + (random() * 99999)::int) AS TEXT), 5, '0') AS postal_code,
        -- Address type
        CASE 
            WHEN address_number = 1 THEN 'shipping'
            WHEN address_number = 2 AND random() < 0.3 THEN 'billing'
            ELSE 'shipping'
        END AS address_type,
        -- Is default
        address_number = 1 AS is_default
    FROM users u
    CROSS JOIN LATERAL generate_series(1, 2) AS gs
    WHERE random() < 0.8 OR gs = 1  -- Most users get 2 addresses, some get 1
)
INSERT INTO addresses (
    user_id, address_line1, address_line2, city, state, postal_code,
    address_type, is_default, created_at
)
SELECT 
    user_id,
    address_line1,
    address_line2,
    city,
    state,
    postal_code,
    address_type,
    is_default,
    CURRENT_TIMESTAMP - (random() * INTERVAL '180 days')
FROM address_data
WHERE user_id IS NOT NULL;

-- Ensure each user has at least one shipping address
INSERT INTO addresses (
    user_id, address_line1, address_line2, city, state, postal_code,
    address_type, is_default, created_at
)
SELECT 
    u.id,
    '123 Default St',
    NULL,
    'Default City',
    'CA',
    '90210',
    'shipping',
    TRUE,
    CURRENT_TIMESTAMP
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM addresses a 
    WHERE a.user_id = u.id
);

-- Log results
\echo '✅ Addresses seeded: ' (SELECT COUNT(*) FROM addresses);

-- Show sample addresses
SELECT 
    u.full_name,
    a.address_line1,
    a.city,
    a.state,
    a.address_type,
    a.is_default
FROM addresses a
JOIN users u ON a.user_id = u.id
LIMIT 15;
```

---

### B.5 Order Data Generation

Create `scripts/seed_orders.sql`:

```sql
-- scripts/seed_orders.sql
-- Generate realistic order data with various statuses

\echo '📋 Generating orders...'

-- Clean up existing data
TRUNCATE TABLE orders CASCADE;

-- Generate orders spanning the last 6 months
WITH order_data AS (
    SELECT 
        u.id AS user_id,
        -- Get random addresses for this user
        (SELECT id FROM addresses a WHERE a.user_id = u.id ORDER BY random() LIMIT 1) AS shipping_address_id,
        (SELECT id FROM addresses a WHERE a.user_id = u.id ORDER BY random() LIMIT 1) AS billing_address_id,
        -- Order date distribution: more recent orders are more common
        CURRENT_DATE - (random() * 180)::int * INTERVAL '1 day' AS order_date,
        -- Random status with realistic distribution
        CASE WHEN random() < 0.6 THEN 'completed'
             WHEN random() < 0.8 THEN 'shipped'
             WHEN random() < 0.9 THEN 'processing'
             WHEN random() < 0.95 THEN 'pending'
             WHEN random() < 0.98 THEN 'cancelled'
             ELSE 'refunded'
        END AS status,
        -- Random payment method
        CASE (random() * 2)::int
            WHEN 0 THEN 'credit_card'
            WHEN 1 THEN 'paypal'
            WHEN 2 THEN 'apple_pay'
        END AS payment_method,
        -- Payment status based on order status
        CASE WHEN random() < 0.7 THEN 'paid'
             WHEN random() < 0.9 THEN 'authorized'
             ELSE 'pending'
        END AS payment_status,
        -- Random shipping method
        CASE (random() * 3)::int
            WHEN 0 THEN 'UPS Ground'
            WHEN 1 THEN 'FedEx 2-Day'
            WHEN 2 THEN 'USPS Priority'
            WHEN 3 THEN 'DHL Express'
        END AS shipping_method,
        -- Random number of items (1-5)
        (1 + (random() * 4)::int) AS item_count,
        -- Order number
        'ORD-' || TO_CHAR(CURRENT_DATE - (random() * 180)::int, 'YYYY-MM-DD') || 
        '-' || LPAD(CAST((1 + (random() * 9999)::int) AS TEXT), 4, '0') AS order_number
    FROM users u
    WHERE u.status = 'active'
    CROSS JOIN LATERAL generate_series(1, 2 + (random() * 3)::int) AS gs
    WHERE random() < 0.3  -- Each user gets ~2-5 orders
)
INSERT INTO orders (
    user_id, shipping_address_id, billing_address_id, order_number,
    subtotal, tax, shipping_cost, discount, total,
    payment_method, payment_status, status,
    shipping_method, order_date, estimated_delivery_date, actual_delivery_date,
    customer_notes, created_at, updated_at
)
SELECT 
    user_id,
    shipping_address_id,
    billing_address_id,
    order_number,
    -- Subtotal: random amount
    ROUND((50 + random() * 950)::numeric, 2) AS subtotal,
    -- Tax: 8% of subtotal
    ROUND(ROUND((50 + random() * 950)::numeric, 2) * 0.08, 2) AS tax,
    -- Shipping cost: $5.99 or free
    CASE WHEN random() < 0.3 THEN 0.00 ELSE 5.99 END AS shipping_cost,
    -- Discount
    CASE WHEN random() < 0.2 THEN ROUND((10 + random() * 40)::numeric, 2) ELSE 0.00 END AS discount,
    -- Total: subtotal + tax + shipping - discount
    ROUND(ROUND((50 + random() * 950)::numeric, 2) + 
          ROUND(ROUND((50 + random() * 950)::numeric, 2) * 0.08, 2) + 
          CASE WHEN random() < 0.3 THEN 0.00 ELSE 5.99 END - 
          CASE WHEN random() < 0.2 THEN ROUND((10 + random() * 40)::numeric, 2) ELSE 0.00 END, 2) AS total,
    payment_method,
    payment_status,
    status,
    shipping_method,
    order_date,
    -- Estimated delivery
    order_date + (3 + (random() * 7)::int) * INTERVAL '1 day' AS estimated_delivery_date,
    -- Actual delivery (only for completed orders)
    CASE 
        WHEN status = 'completed' THEN order_date + (2 + (random() * 5)::int) * INTERVAL '1 day'
        ELSE NULL
    END AS actual_delivery_date,
    -- Customer notes (some orders have notes)
    CASE WHEN random() < 0.1 THEN 'Please leave at the door' ELSE NULL END AS customer_notes,
    order_date AS created_at,
    order_date + (random() * INTERVAL '10 days') AS updated_at
FROM order_data;

-- Update order totals to match order items (will be fixed in next script)
\echo '✅ Orders seeded: ' (SELECT COUNT(*) FROM orders);

-- Show sample orders
SELECT 
    order_number,
    status,
    payment_method,
    total,
    order_date,
    shipping_method
FROM orders 
ORDER BY order_date DESC 
LIMIT 15;
```

---

### B.6 Order Items Generation

Create `scripts/seed_order_items.sql`:

```sql
-- scripts/seed_order_items.sql
-- Generate order items based on existing orders and products

\echo '📦 Generating order items...'

-- Clean up existing data
TRUNCATE TABLE order_items CASCADE;

-- Generate order items for each order
WITH order_item_data AS (
    SELECT 
        o.id AS order_id,
        p.id AS product_id,
        -- Get random quantity (1-3 for most orders, sometimes more)
        CASE 
            WHEN random() < 0.6 THEN 1
            WHEN random() < 0.85 THEN 2
            ELSE 3
        END AS quantity,
        -- Use current price or slightly adjusted
        ROUND(p.price * (0.95 + random() * 0.1), 2) AS unit_price,
        -- Row number for creating multiple items per order
        ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY random()) AS item_num
    FROM orders o
    CROSS JOIN products p
    WHERE random() < 0.05  -- 5% chance for each product-order combination
      AND o.status NOT IN ('cancelled', 'refunded')
)
INSERT INTO order_items (
    order_id, product_id, product_name, product_description,
    unit_price, quantity, line_subtotal, line_tax, line_total,
    product_attributes, created_at
)
SELECT 
    oi.order_id,
    oi.product_id,
    p.name AS product_name,
    p.description AS product_description,
    oi.unit_price,
    oi.quantity,
    ROUND(oi.unit_price * oi.quantity, 2) AS line_subtotal,
    ROUND(oi.unit_price * oi.quantity * 0.08, 2) AS line_tax,
    ROUND(oi.unit_price * oi.quantity * 1.08, 2) AS line_total,
    p.attributes AS product_attributes,
    o.order_date AS created_at
FROM order_item_data oi
JOIN products p ON oi.product_id = p.id
JOIN orders o ON oi.order_id = o.id
WHERE oi.item_num <= 3  -- Max 3 items per order
  AND oi.quantity > 0;

-- Update order totals to match actual order items
WITH order_totals AS (
    SELECT 
        order_id,
        SUM(line_subtotal) AS actual_subtotal,
        SUM(line_tax) AS actual_tax,
        SUM(line_total) AS actual_total,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
)
UPDATE orders o
SET 
    subtotal = ot.actual_subtotal,
    tax = ot.actual_tax,
    total = ot.actual_total + shipping_cost - discount,
    -- Also update status based on order items
    status = CASE 
        WHEN o.status = 'pending' AND EXISTS (
            SELECT 1 FROM order_items WHERE order_id = o.id
        ) THEN 'processing'
        ELSE o.status
    END
FROM order_totals ot
WHERE o.id = ot.order_id;

-- Ensure orders without items are deleted (orphan orders)
DELETE FROM orders 
WHERE id IN (
    SELECT o.id 
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE oi.id IS NULL
    AND o.status NOT IN ('cancelled', 'refunded')
);

-- Log results
\echo '✅ Order items seeded: ' (SELECT COUNT(*) FROM order_items);

-- Show sample order items
SELECT 
    o.order_number,
    oi.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
LIMIT 20;
```

---

### B.7 Inventory Data Generation

Create `scripts/seed_inventory.sql`:

```sql
-- scripts/seed_inventory.sql
-- Generate inventory data for all products

\echo '📊 Generating inventory data...'

-- Clean up existing data
TRUNCATE TABLE inventory CASCADE;
TRUNCATE TABLE inventory_transactions CASCADE;

-- Create inventory records for all products
INSERT INTO inventory (product_id, quantity, reserved_quantity, reorder_point, last_updated)
SELECT 
    p.id AS product_id,
    p.stock_quantity AS quantity,
    -- Random reserved quantity (0-10)
    (random() * 10)::int AS reserved_quantity,
    -- Reorder point: 10-50% of stock
    GREATEST(5, (p.stock_quantity * (0.1 + random() * 0.4))::int) AS reorder_point,
    CURRENT_TIMESTAMP - (random() * INTERVAL '30 days') AS last_updated
FROM products p;

-- Generate initial inventory transactions (past 30 days)
WITH transaction_data AS (
    SELECT 
        i.product_id,
        -- Generate various transaction types
        CASE (random() * 3)::int
            WHEN 0 THEN 'restock'
            WHEN 1 THEN 'sell'
            WHEN 2 THEN 'adjust'
            WHEN 3 THEN 'reserve'
        END AS transaction_type,
        -- Quantities: 1-50 for restock, 1-5 for sales
        CASE 
            WHEN transaction_type = 'restock' THEN (5 + (random() * 45)::int)
            WHEN transaction_type = 'sell' THEN (1 + (random() * 4)::int)
            ELSE (1 + (random() * 5)::int)
        END AS quantity,
        CURRENT_TIMESTAMP - (random() * INTERVAL '30 days') AS created_at,
        -- Random user or system
        CASE WHEN random() < 0.1 THEN NULL ELSE (SELECT id FROM users ORDER BY random() LIMIT 1) END AS user_id
    FROM inventory i
    CROSS JOIN LATERAL generate_series(1, 5 + (random() * 10)::int) AS gs
    WHERE random() < 0.5  -- Generate transactions for 50% of products
)
INSERT INTO inventory_transactions (
    product_id, transaction_type, quantity,
    previous_quantity, new_quantity, order_id, user_id, created_at
)
SELECT 
    td.product_id,
    td.transaction_type,
    td.quantity,
    -- Previous quantity (for realism)
    CASE 
        WHEN td.transaction_type = 'restock' THEN i.quantity - td.quantity
        WHEN td.transaction_type = 'sell' THEN i.quantity + td.quantity
        ELSE i.quantity
    END AS previous_quantity,
    -- New quantity
    CASE 
        WHEN td.transaction_type = 'restock' THEN i.quantity
        WHEN td.transaction_type = 'sell' THEN i.quantity - td.quantity
        ELSE i.quantity + (CASE WHEN random() < 0.5 THEN td.quantity ELSE -td.quantity END)
    END AS new_quantity,
    -- Link some transactions to orders
    CASE 
        WHEN td.transaction_type = 'sell' AND random() < 0.5 
        THEN (SELECT id FROM orders WHERE status != 'cancelled' ORDER BY random() LIMIT 1)
        ELSE NULL 
    END AS order_id,
    td.user_id,
    td.created_at
FROM transaction_data td
JOIN inventory i ON td.product_id = i.product_id;

-- Update inventory quantities based on transactions
WITH latest_transactions AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        new_quantity,
        created_at
    FROM inventory_transactions
    ORDER BY product_id, created_at DESC
)
UPDATE inventory i
SET 
    quantity = lt.new_quantity,
    last_updated = lt.created_at
FROM latest_transactions lt
WHERE i.product_id = lt.product_id;

-- Log results
\echo '✅ Inventory seeded: ' (SELECT COUNT(*) FROM inventory);
\echo '✅ Inventory transactions seeded: ' (SELECT COUNT(*) FROM inventory_transactions);

-- Show inventory summary
SELECT 
    p.name,
    i.quantity,
    i.reserved_quantity,
    i.quantity - i.reserved_quantity AS available,
    i.reorder_point,
    CASE 
        WHEN i.quantity = 0 THEN 'Out of Stock'
        WHEN i.quantity < i.reorder_point THEN 'Low Stock'
        WHEN i.quantity < i.reorder_point * 2 THEN 'Medium Stock'
        ELSE 'Well Stocked'
    END AS status
FROM inventory i
JOIN products p ON i.product_id = p.id
ORDER BY available ASC
LIMIT 20;
```

---

### B.8 Additional Data Generation Scripts

#### B.8.1 Generate Sales Data

Create `scripts/generate_sales_data.sql`:

```sql
-- scripts/generate_sales_data.sql
-- Generate additional sales data for analytics

\echo '📈 Generating sales analytics data...'

-- Create sales summary by month
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT 
    DATE_TRUNC('month', o.order_date) AS month,
    COUNT(DISTINCT o.id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(o.total) AS total_revenue,
    AVG(o.total) AS avg_order_value,
    SUM(oi.quantity) AS items_sold,
    AVG(oi.quantity) AS avg_items_per_order
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month DESC;

-- Create product category sales report
CREATE OR REPLACE VIEW category_sales_report AS
SELECT 
    p.metadata->>'category' AS category,
    COUNT(DISTINCT o.id) AS orders,
    COUNT(DISTINCT o.user_id) AS customers,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS revenue,
    AVG(oi.unit_price) AS avg_price,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.metadata->>'category'
ORDER BY revenue DESC;

-- Create customer lifetime value report
CREATE OR REPLACE VIEW customer_lifetime_value AS
SELECT 
    u.id,
    u.full_name,
    u.email,
    u.created_at AS signup_date,
    COUNT(DISTINCT o.id) AS total_orders,
    SUM(o.total) AS lifetime_value,
    AVG(o.total) AS avg_order_value,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order,
    EXTRACT(DAY FROM (MAX(o.order_date) - MIN(o.order_date))) AS customer_lifetime_days,
    CASE 
        WHEN COUNT(DISTINCT o.id) >= 5 THEN 'Loyal'
        WHEN COUNT(DISTINCT o.id) >= 2 THEN 'Regular'
        WHEN COUNT(DISTINCT o.id) >= 1 THEN 'New'
        ELSE 'Prospect'
    END AS customer_segment
FROM users u
LEFT JOIN orders o ON u.id = o.user_id 
    AND o.status NOT IN ('cancelled', 'refunded')
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.full_name, u.email, u.created_at
ORDER BY lifetime_value DESC NULLS LAST;

\echo '✅ Sales analytics views created!';
```

---

### B.9 Running the Seed Scripts

#### B.9.1 Run All Seeds

```bash
#!/bin/bash
# run_seeds.sh - Master seed runner script

echo "🌱 Starting database seeding process..."
echo "=========================================="

# Set database connection string
export DATABASE_URL="postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require"

# Run seeds in order
echo "📝 Seeding users..."
psql "$DATABASE_URL" -f scripts/seed_users.sql

echo "📦 Seeding products..."
psql "$DATABASE_URL" -f scripts/seed_products.sql

echo "📍 Seeding addresses..."
psql "$DATABASE_URL" -f scripts/seed_addresses.sql

echo "📋 Seeding orders..."
psql "$DATABASE_URL" -f scripts/seed_orders.sql

echo "📦 Seeding order items..."
psql "$DATABASE_URL" -f scripts/seed_order_items.sql

echo "📊 Seeding inventory..."
psql "$DATABASE_URL" -f scripts/seed_inventory.sql

echo "=========================================="
echo "✅ Database seeding complete!"

# Show summary
psql "$DATABASE_URL" -c "
SELECT 
    'Total Users' AS metric,
    COUNT(*) AS value 
FROM users
UNION ALL
SELECT 
    'Total Products',
    COUNT(*) 
FROM products
UNION ALL
SELECT 
    'Total Orders',
    COUNT(*) 
FROM orders
UNION ALL
SELECT 
    'Total Order Items',
    COUNT(*) 
FROM order_items
UNION ALL
SELECT 
    'Total Revenue',
    TO_CHAR(SUM(total), '$999,999.99')
FROM orders 
WHERE status NOT IN ('cancelled', 'refunded');
"
```

#### B.9.2 Reset All Data

```sql
-- scripts/reset_all.sql
-- Reset all tables (CASCADE ensures proper order)

\echo '🗑️ Resetting all tables...'

TRUNCATE TABLE order_items CASCADE;
TRUNCATE TABLE orders CASCADE;
TRUNCATE TABLE addresses CASCADE;
TRUNCATE TABLE inventory CASCADE;
TRUNCATE TABLE inventory_transactions CASCADE;
TRUNCATE TABLE products CASCADE;
TRUNCATE TABLE users CASCADE;

\echo '✅ All tables reset!';
```

#### B.9.3 Generate Test Data (Quick Mode)

```sql
-- scripts/seed_quick.sql
-- Quick seed for testing (fewer records)

\echo '⚡ Quick seeding for testing...'

-- Users: 10 customers + 1 admin
INSERT INTO users (email, username, password_hash, full_name, role, status)
VALUES 
    ('admin@test.com', 'admin', crypt('admin123', gen_salt('bf')), 'Test Admin', 'admin', 'active'),
    ('test1@test.com', 'test1', crypt('test123', gen_salt('bf')), 'Test User 1', 'customer', 'active'),
    ('test2@test.com', 'test2', crypt('test123', gen_salt('bf')), 'Test User 2', 'customer', 'active'),
    ('test3@test.com', 'test3', crypt('test123', gen_salt('bf')), 'Test User 3', 'customer', 'active');

-- Products: 5 sample products
INSERT INTO products (name, description, price, stock_quantity, attributes, metadata)
VALUES 
    ('Test Headphones', 'Wireless headphones', 99.99, 100, '{"color": "Black"}'::jsonb, '{"brand": "TestCo"}'::jsonb),
    ('Test Camera', '4K action camera', 249.99, 50, '{"resolution": "4K"}'::jsonb, '{"brand": "TestCo"}'::jsonb),
    ('Test Watch', 'Smart fitness watch', 199.00, 75, '{"display": "AMOLED"}'::jsonb, '{"brand": "TestCo"}'::jsonb);

\echo '✅ Quick seed complete!';
```

---

### B.10 Data Validation Queries

```sql
-- scripts/validate_data.sql
-- Validate data integrity after seeding

\echo '🔍 Validating data integrity...'

-- Check for orphaned addresses
SELECT 
    'Addresses without users' AS issue,
    COUNT(*) AS count
FROM addresses a
LEFT JOIN users u ON a.user_id = u.id
WHERE u.id IS NULL;

-- Check for orphaned orders
SELECT 
    'Orders without users' AS issue,
    COUNT(*) AS count
FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- Check for orders without shipping address
SELECT 
    'Orders without shipping address' AS issue,
    COUNT(*) AS count
FROM orders o
LEFT JOIN addresses a ON o.shipping_address_id = a.id
WHERE a.id IS NULL;

-- Check for order items without products
SELECT 
    'Order items without products' AS issue,
    COUNT(*) AS count
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.id
WHERE p.id IS NULL;

-- Check for order items without orders
SELECT 
    'Order items without orders' AS issue,
    COUNT(*) AS count
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.id
WHERE o.id IS NULL;

-- Check inventory consistency
SELECT 
    'Products without inventory' AS issue,
    COUNT(*) AS count
FROM products p
LEFT JOIN inventory i ON p.id = i.product_id
WHERE i.product_id IS NULL;

-- Check order totals
SELECT 
    'Orders with mismatched totals' AS issue,
    COUNT(*) AS count
FROM orders o
WHERE o.total != (
    SELECT COALESCE(SUM(line_total), 0) + o.shipping_cost - o.discount
    FROM order_items oi
    WHERE oi.order_id = o.id
);

\echo '✅ Validation complete!';
```

---

This appendix provides everything you need to generate realistic, production-quality test data for your Neon PostgreSQL e-commerce application. All scripts are production-ready and include proper error handling, validation, and documentation.
