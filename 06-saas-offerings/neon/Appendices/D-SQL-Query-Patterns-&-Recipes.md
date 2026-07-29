# Serverless Postgres with Neon: From Zero to Production

## Appendix D: SQL Query Patterns & Recipes

### Overview

This appendix provides a comprehensive collection of battle-tested SQL query patterns and recipes for common e-commerce operations. Each pattern includes the problem statement, the complete SQL solution, and practical usage examples. Use this as your go-to reference for implementing specific features in your application.

---

### D.1 User Management Patterns

#### D.1.1 User Registration

```sql
-- Pattern: Create a new user with validation
-- Problem: Register a new user with email, username, and password

-- Complete registration with all validations
WITH new_user AS (
    -- Insert the user with validation
    INSERT INTO users (
        email,
        username,
        password_hash,
        full_name,
        phone,
        role,
        status,
        created_at
    ) VALUES (
        'newuser@example.com',                              -- email
        'newuser',                                          -- username
        crypt('SecurePassword123!', gen_salt('bf')),       -- password hash
        'New User',                                         -- full_name
        '+1-555-1234',                                      -- phone
        'customer',                                         -- role
        'active',                                           -- status
        CURRENT_TIMESTAMP                                   -- created_at
    )
    ON CONFLICT (email) DO UPDATE SET
        -- If email exists, update the record instead
        updated_at = CURRENT_TIMESTAMP,
        last_login = NULL
    RETURNING id, email, username, created_at
)
SELECT * FROM new_user;

-- Verify the new user was created
SELECT 
    u.id,
    u.email,
    u.username,
    u.full_name,
    u.role,
    u.status,
    u.created_at
FROM users u
WHERE u.email = 'newuser@example.com';
```

#### D.1.2 User Authentication

```sql
-- Pattern: Authenticate a user by email and password
-- Problem: Validate user credentials and return user info

-- First, get user by email
WITH user_auth AS (
    SELECT 
        id,
        email,
        username,
        password_hash,
        full_name,
        role,
        status,
        deleted_at
    FROM users
    WHERE email = 'newuser@example.com'
      AND deleted_at IS NULL
)
SELECT 
    id,
    email,
    username,
    full_name,
    role,
    status,
    -- Check if password matches (using crypt function)
    CASE 
        WHEN password_hash = crypt('SecurePassword123!', password_hash) 
        THEN 'authenticated'
        ELSE 'invalid_credentials'
    END AS auth_status,
    -- Return authenticated user info
    jsonb_build_object(
        'user_id', id,
        'email', email,
        'username', username,
        'full_name', full_name,
        'role', role
    ) AS user_info
FROM user_auth;

-- Update last login timestamp after successful auth
UPDATE users 
SET last_login = CURRENT_TIMESTAMP
WHERE email = 'newuser@example.com'
  AND deleted_at IS NULL
  AND password_hash = crypt('SecurePassword123!', password_hash)
RETURNING id, email, last_login;
```

#### D.1.3 User Profile Management

```sql
-- Pattern: Get complete user profile with address information
-- Problem: Retrieve user profile with all associated data

SELECT 
    u.id AS user_id,
    u.email,
    u.username,
    u.full_name,
    u.phone,
    u.role,
    u.status,
    u.created_at AS member_since,
    u.last_login,
    -- Get all addresses as JSON array
    COALESCE(
        jsonb_agg(
            DISTINCT jsonb_build_object(
                'id', a.id,
                'address_line1', a.address_line1,
                'address_line2', a.address_line2,
                'city', a.city,
                'state', a.state,
                'postal_code', a.postal_code,
                'country', a.country,
                'type', a.address_type,
                'is_default', a.is_default
            )
        ) FILTER (WHERE a.id IS NOT NULL),
        '[]'::jsonb
    ) AS addresses,
    -- Get order summary
    COALESCE(
        jsonb_build_object(
            'total_orders', COUNT(DISTINCT o.id),
            'total_spent', SUM(o.total),
            'average_order', AVG(o.total),
            'last_order', MAX(o.order_date)
        ),
        jsonb_build_object(
            'total_orders', 0,
            'total_spent', 0,
            'average_order', NULL,
            'last_order', NULL
        )
    ) AS order_summary
FROM users u
LEFT JOIN addresses a ON u.id = a.user_id AND a.deleted_at IS NULL
LEFT JOIN orders o ON u.id = o.user_id 
    AND o.status NOT IN ('cancelled', 'refunded')
    AND o.deleted_at IS NULL
WHERE u.id = 'user-uuid-here'  -- Replace with actual user ID
GROUP BY u.id;

-- Update user profile
UPDATE users 
SET 
    full_name = 'Updated Name',
    phone = '+1-555-5678',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'user-uuid-here'
  AND deleted_at IS NULL
RETURNING id, email, full_name, phone, updated_at;
```

#### D.1.4 User Deactivation (Soft Delete)

```sql
-- Pattern: Soft delete a user account
-- Problem: Deactivate a user without permanently removing data

-- Soft delete user
UPDATE users 
SET 
    deleted_at = CURRENT_TIMESTAMP,
    status = 'inactive',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'user-uuid-here'
  AND deleted_at IS NULL
RETURNING id, email, status, deleted_at;

-- Also soft delete associated addresses
UPDATE addresses 
SET deleted_at = CURRENT_TIMESTAMP
WHERE user_id = 'user-uuid-here'
  AND deleted_at IS NULL;

-- Reactivate user
UPDATE users 
SET 
    deleted_at = NULL,
    status = 'active',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'user-uuid-here'
  AND deleted_at IS NOT NULL
RETURNING id, email, status;
```

---

### D.2 Product Catalog Patterns

#### D.2.1 Product Search with Filters

```sql
-- Pattern: Search products with multiple filters
-- Problem: Implement product search with category, price range, and text search

CREATE OR REPLACE FUNCTION search_products(
    p_search_term TEXT DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL,
    p_brand TEXT DEFAULT NULL,
    p_in_stock BOOLEAN DEFAULT NULL,
    p_sort_by TEXT DEFAULT 'relevance',
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    product_id INTEGER,
    product_name VARCHAR,
    price NUMERIC,
    brand TEXT,
    category TEXT,
    stock_quantity INTEGER,
    relevance_score NUMERIC,
    attributes JSONB,
    variants JSONB
) AS $$
BEGIN
    RETURN QUERY
    WITH filtered_products AS (
        SELECT 
            p.id,
            p.name,
            p.price,
            p.metadata->>'brand' AS brand,
            p.metadata->>'category' AS category,
            p.stock_quantity,
            p.attributes,
            p.variants,
            -- Calculate relevance score based on search
            CASE 
                WHEN p_search_term IS NOT NULL THEN
                    GREATEST(
                        similarity(p.name, p_search_term),
                        similarity(p.description, p_search_term),
                        similarity(p.metadata->>'brand', p_search_term),
                        similarity(p.metadata->>'category', p_search_term)
                    )
                ELSE 0
            END AS score
        FROM products p
        WHERE p.deleted_at IS NULL
          AND (p_category IS NULL OR p.metadata->>'category' = p_category)
          AND (p_min_price IS NULL OR p.price >= p_min_price)
          AND (p_max_price IS NULL OR p.price <= p_max_price)
          AND (p_brand IS NULL OR p.metadata->>'brand' = p_brand)
          AND (p_in_stock IS NULL OR 
               (p_in_stock = true AND p.stock_quantity > 0) OR
               (p_in_stock = false AND p.stock_quantity = 0))
          AND (p_search_term IS NULL OR 
               p.search_vector @@ plainto_tsquery(p_search_term) OR
               similarity(p.name, p_search_term) > 0.3 OR
               similarity(p.description, p_search_term) > 0.3)
    )
    SELECT 
        fp.id,
        fp.name,
        fp.price,
        fp.brand,
        fp.category,
        fp.stock_quantity,
        fp.score AS relevance_score,
        fp.attributes,
        fp.variants
    FROM filtered_products fp
    ORDER BY 
        CASE 
            WHEN p_sort_by = 'relevance' THEN fp.score
            WHEN p_sort_by = 'price_asc' THEN -fp.price
            WHEN p_sort_by = 'price_desc' THEN fp.price
            WHEN p_sort_by = 'name' THEN 0
        END DESC NULLS LAST,
        CASE WHEN p_sort_by = 'name' THEN fp.name END ASC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Usage examples:
-- Search with text
SELECT * FROM search_products(p_search_term => 'wireless headphones');

-- Search with filters
SELECT * FROM search_products(
    p_search_term => 'camera',
    p_category => 'Cameras',
    p_min_price => 100,
    p_max_price => 500,
    p_in_stock => true,
    p_sort_by => 'price_desc'
);

-- Get product details with variants
SELECT 
    p.id,
    p.name,
    p.price,
    p.attributes,
    p.metadata,
    jsonb_agg(
        DISTINCT jsonb_build_object(
            'color', v.value->>'color',
            'price_adjustment', (v.value->>'price_adjustment')::numeric,
            'sku', v.value->>'sku',
            'stock', (v.value->>'stock')::int
        )
    ) AS variants
FROM products p,
     jsonb_array_elements(p.variants) AS v(value)
WHERE p.id = 'product-id-here'
  AND p.deleted_at IS NULL
GROUP BY p.id, p.name, p.price, p.attributes, p.metadata;
```

#### D.2.2 Product Category Hierarchy

```sql
-- Pattern: Build product category hierarchy with counts
-- Problem: Display categories with nested subcategories and product counts

-- Create categories table (if not exists)
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT valid_slug CHECK (slug ~ '^[a-z0-9-]+$')
);

-- Insert sample categories
INSERT INTO categories (name, slug, description, parent_id, sort_order) VALUES
    ('Electronics', 'electronics', 'All electronic devices', NULL, 1),
    ('Audio', 'audio', 'Audio equipment and devices', 1, 1),
    ('Cameras', 'cameras', 'Digital cameras and accessories', 1, 2),
    ('Computers', 'computers', 'Laptops, desktops, and peripherals', 1, 3),
    ('Headphones', 'headphones', 'Wired and wireless headphones', 2, 1),
    ('Speakers', 'speakers', 'Bluetooth and home speakers', 2, 2),
    ('DSLR', 'dslr', 'Digital SLR cameras', 3, 1),
    ('Mirrorless', 'mirrorless', 'Mirrorless cameras', 3, 2);

-- Get category tree with product counts
WITH RECURSIVE category_tree AS (
    -- Anchor: root categories
    SELECT 
        id,
        name,
        slug,
        description,
        parent_id,
        sort_order,
        0 AS level,
        ARRAY[id] AS path,
        name AS full_path
    FROM categories
    WHERE parent_id IS NULL
      AND deleted_at IS NULL
    
    UNION ALL
    
    -- Recursive: child categories
    SELECT 
        c.id,
        c.name,
        c.slug,
        c.description,
        c.parent_id,
        c.sort_order,
        ct.level + 1,
        ct.path || c.id,
        ct.full_path || ' > ' || c.name
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
    WHERE c.deleted_at IS NULL
),
category_counts AS (
    SELECT 
        p.metadata->>'category' AS category_name,
        COUNT(*) AS product_count,
        COUNT(CASE WHEN p.stock_quantity > 0 THEN 1 END) AS in_stock_count,
        MIN(p.price) AS min_price,
        MAX(p.price) AS max_price,
        AVG(p.price) AS avg_price
    FROM products p
    WHERE p.deleted_at IS NULL
    GROUP BY p.metadata->>'category'
)
SELECT 
    ct.id,
    ct.name,
    ct.slug,
    ct.description,
    ct.level,
    ct.full_path,
    ct.sort_order,
    COALESCE(cc.product_count, 0) AS product_count,
    COALESCE(cc.in_stock_count, 0) AS in_stock_count,
    cc.min_price,
    cc.max_price,
    cc.avg_price,
    -- Subcategories
    (SELECT jsonb_agg(
        jsonb_build_object(
            'id', sub.id,
            'name', sub.name,
            'slug', sub.slug,
            'level', sub.level
        )
     )
     FROM category_tree sub
     WHERE sub.path[1] = ct.id 
       AND sub.id != ct.id
       AND sub.level <= 2
    ) AS subcategories
FROM category_tree ct
LEFT JOIN category_counts cc ON ct.name = cc.category_name
ORDER BY ct.level, ct.sort_order, ct.name;
```

---

### D.3 Order Management Patterns

#### D.3.1 Complete Checkout Flow

```sql
-- Pattern: Complete checkout with inventory reservation
-- Problem: Process an order with multiple items, reserve inventory, and handle payment

CREATE OR REPLACE FUNCTION process_checkout(
    p_user_id UUID,
    p_shipping_address_id UUID,
    p_billing_address_id UUID,
    p_payment_method VARCHAR,
    p_shipping_method VARCHAR,
    p_items JSONB,  -- Array of {product_id, quantity}
    p_coupon_code VARCHAR DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE(
    order_id UUID,
    order_number VARCHAR,
    status VARCHAR,
    total NUMERIC,
    message TEXT
) AS $$
DECLARE
    v_order_id UUID;
    v_order_number VARCHAR;
    v_subtotal NUMERIC := 0;
    v_tax NUMERIC := 0;
    v_shipping_cost NUMERIC := 5.99;
    v_discount NUMERIC := 0;
    v_total NUMERIC;
    v_item JSONB;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_unit_price NUMERIC;
    v_line_subtotal NUMERIC;
    v_available_stock INTEGER;
    v_order_date TIMESTAMP := CURRENT_TIMESTAMP;
BEGIN
    -- Start transaction
    BEGIN
        -- Generate order number
        v_order_number := 'ORD-' || TO_CHAR(v_order_date, 'YYYYMMDD') || 
                         '-' || LPAD(nextval('orders_order_number_seq')::TEXT, 6, '0');
        
        -- Validate items and calculate totals
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            -- Get product details with stock check
            SELECT 
                p.price,
                p.stock_quantity,
                p.attributes->>'reserved' AS reserved
            INTO 
                v_unit_price,
                v_available_stock,
                v_reserved
            FROM products p
            WHERE p.id = v_product_id
              AND p.deleted_at IS NULL
            FOR UPDATE;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Product % not found', v_product_id;
            END IF;
            
            -- Check stock availability
            IF (v_available_stock - COALESCE(v_reserved::INTEGER, 0)) < v_quantity THEN
                RAISE EXCEPTION 'Insufficient stock for product %. Available: %, Requested: %',
                    v_product_id, 
                    (v_available_stock - COALESCE(v_reserved::INTEGER, 0)),
                    v_quantity;
            END IF;
            
            -- Reserve inventory
            UPDATE products 
            SET 
                attributes = jsonb_set(
                    attributes, 
                    '{reserved}', 
                    (COALESCE(attributes->>'reserved', '0')::int + v_quantity)::text::jsonb
                )
            WHERE id = v_product_id;
            
            -- Calculate line totals
            v_line_subtotal := v_unit_price * v_quantity;
            v_subtotal := v_subtotal + v_line_subtotal;
        END LOOP;
        
        -- Apply discount if coupon provided
        IF p_coupon_code IS NOT NULL THEN
            SELECT 
                discount_percentage,
                discount_amount
            INTO 
                v_discount_percent,
                v_discount_amount
            FROM coupons
            WHERE code = p_coupon_code
              AND valid_until >= CURRENT_DATE
              AND active = true;
            
            IF FOUND THEN
                IF v_discount_percent IS NOT NULL THEN
                    v_discount := v_subtotal * (v_discount_percent / 100.0);
                ELSE
                    v_discount := v_discount_amount;
                END IF;
            END IF;
        END IF;
        
        -- Calculate tax (8%)
        v_tax := (v_subtotal - v_discount) * 0.08;
        
        -- Calculate shipping (free for orders over $100)
        IF v_subtotal - v_discount > 100 THEN
            v_shipping_cost := 0;
        END IF;
        
        -- Calculate total
        v_total := v_subtotal - v_discount + v_tax + v_shipping_cost;
        
        -- Create the order
        INSERT INTO orders (
            user_id,
            shipping_address_id,
            billing_address_id,
            order_number,
            order_date,
            subtotal,
            tax,
            shipping_cost,
            discount,
            total,
            payment_method,
            payment_status,
            status,
            shipping_method,
            customer_notes,
            created_at
        ) VALUES (
            p_user_id,
            p_shipping_address_id,
            p_billing_address_id,
            v_order_number,
            v_order_date,
            v_subtotal,
            v_tax,
            v_shipping_cost,
            COALESCE(v_discount, 0),
            v_total,
            p_payment_method,
            'pending',
            'pending',
            p_shipping_method,
            p_notes,
            v_order_date
        )
        RETURNING id INTO v_order_id;
        
        -- Insert order items and update inventory
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            v_product_id := (v_item->>'product_id')::INTEGER;
            v_quantity := (v_item->>'quantity')::INTEGER;
            
            -- Get product details for order item
            SELECT price INTO v_unit_price
            FROM products
            WHERE id = v_product_id;
            
            -- Insert order item
            INSERT INTO order_items (
                order_id,
                product_id,
                product_name,
                product_description,
                unit_price,
                quantity,
                line_subtotal,
                line_tax,
                line_total,
                product_attributes,
                created_at
            )
            SELECT 
                v_order_id,
                p.id,
                p.name,
                p.description,
                v_unit_price,
                v_quantity,
                v_unit_price * v_quantity,
                v_unit_price * v_quantity * 0.08,
                v_unit_price * v_quantity * 1.08,
                p.attributes,
                v_order_date
            FROM products p
            WHERE p.id = v_product_id;
            
            -- Deduct from actual inventory
            UPDATE products 
            SET 
                stock_quantity = stock_quantity - v_quantity,
                attributes = jsonb_set(
                    attributes, 
                    '{reserved}', 
                    (COALESCE(attributes->>'reserved', '0')::int - v_quantity)::text::jsonb
                ),
                updated_at = v_order_date
            WHERE id = v_product_id;
        END LOOP;
        
        -- Commit transaction
        COMMIT;
        
        -- Return success
        RETURN QUERY
        SELECT 
            v_order_id,
            v_order_number,
            'pending' AS status,
            v_total,
            'Order placed successfully' AS message;
            
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback on error
            ROLLBACK;
            RETURN QUERY
            SELECT 
                NULL::UUID,
                NULL::VARCHAR,
                'failed' AS status,
                NULL::NUMERIC,
                SQLERRM AS message;
    END;
END;
$$ LANGUAGE plpgsql;

-- Usage example:
SELECT * FROM process_checkout(
    'user-uuid-here',
    'shipping-address-uuid-here',
    'billing-address-uuid-here',
    'credit_card',
    'UPS Ground',
    '[{"product_id": 1, "quantity": 2}, {"product_id": 3, "quantity": 1}]'::jsonb,
    'SAVE10'
);
```

#### D.3.2 Order Tracking & Status Updates

```sql
-- Pattern: Track order status and provide timeline
-- Problem: Show order status history with timestamps

CREATE TABLE IF NOT EXISTS order_status_history (
    id SERIAL PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX idx_order_status_history_created_at ON order_status_history(created_at);

-- Function to update order status with history
CREATE OR REPLACE FUNCTION update_order_status(
    p_order_id UUID,
    p_new_status VARCHAR,
    p_note TEXT DEFAULT NULL,
    p_updated_by UUID DEFAULT NULL
)
RETURNS TABLE(
    order_id UUID,
    old_status VARCHAR,
    new_status VARCHAR,
    updated_at TIMESTAMP
) AS $$
DECLARE
    v_old_status VARCHAR;
BEGIN
    -- Get current status
    SELECT status INTO v_old_status
    FROM orders
    WHERE id = p_order_id
      AND deleted_at IS NULL;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;
    
    -- Update order status
    UPDATE orders 
    SET 
        status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_order_id
    RETURNING id, status INTO p_order_id, v_new_status;
    
    -- Log status change
    INSERT INTO order_status_history (
        order_id,
        status,
        note,
        created_at,
        updated_by
    ) VALUES (
        p_order_id,
        p_new_status,
        COALESCE(p_note, 'Status changed from ' || v_old_status || ' to ' || p_new_status),
        CURRENT_TIMESTAMP,
        p_updated_by
    );
    
    -- Return status update info
    RETURN QUERY
    SELECT 
        p_order_id,
        v_old_status,
        p_new_status,
        CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- Get order status timeline
SELECT 
    o.order_number,
    o.total,
    o.status AS current_status,
    jsonb_agg(
        jsonb_build_object(
            'status', h.status,
            'note', h.note,
            'timestamp', h.created_at,
            'updated_by', u.full_name
        )
        ORDER BY h.created_at DESC
    ) AS status_history,
    -- Calculate time in each status
    jsonb_agg(
        jsonb_build_object(
            'status', h.status,
            'duration', EXTRACT(EPOCH FROM (LEAD(h.created_at) OVER (ORDER BY h.created_at) - h.created_at))::INTEGER
        )
        ORDER BY h.created_at
    ) AS status_durations
FROM orders o
LEFT JOIN order_status_history h ON o.id = h.order_id
LEFT JOIN users u ON h.updated_by = u.id
WHERE o.id = 'order-uuid-here'
GROUP BY o.id, o.order_number, o.total, o.status;
```

#### D.3.3 Order Analytics

```sql
-- Pattern: Generate order analytics dashboards
-- Problem: Create comprehensive order reports

-- Daily sales summary
CREATE OR REPLACE VIEW daily_sales_analytics AS
SELECT 
    DATE(o.order_date) AS sale_date,
    COUNT(DISTINCT o.id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(o.total) AS total_revenue,
    AVG(o.total) AS average_order_value,
    SUM(oi.quantity) AS total_items_sold,
    SUM(oi.line_total) AS total_item_revenue,
    AVG(oi.quantity) AS average_items_per_order,
    -- Revenue by payment method
    jsonb_agg(
        DISTINCT jsonb_build_object(
            'payment_method', o.payment_method,
            'count', COUNT(*) FILTER (WHERE o.payment_method = o.payment_method),
            'revenue', SUM(o.total) FILTER (WHERE o.payment_method = o.payment_method)
        )
    ) AS payment_breakdown,
    -- Status distribution
    jsonb_agg(
        DISTINCT jsonb_build_object(
            'status', o.status,
            'count', COUNT(*) FILTER (WHERE o.status = o.status),
            'revenue', SUM(o.total) FILTER (WHERE o.status = o.status)
        )
    ) AS status_breakdown,
    COUNT(CASE WHEN o.status = 'cancelled' THEN 1 END) AS cancelled_orders,
    SUM(CASE WHEN o.status = 'cancelled' THEN o.total ELSE 0 END) AS cancelled_revenue,
    COUNT(CASE WHEN o.status = 'refunded' THEN 1 END) AS refunded_orders,
    SUM(CASE WHEN o.status = 'refunded' THEN o.total ELSE 0 END) AS refunded_revenue
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
WHERE o.deleted_at IS NULL
  AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(o.order_date)
ORDER BY sale_date DESC;

-- Sales by hour of day
SELECT 
    EXTRACT(HOUR FROM order_date) AS hour_of_day,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value,
    RANK() OVER (ORDER BY SUM(total) DESC) AS revenue_rank
FROM orders
WHERE deleted_at IS NULL
  AND status NOT IN ('cancelled', 'refunded')
  AND order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY EXTRACT(HOUR FROM order_date)
ORDER BY hour_of_day;

-- Customer purchase patterns
SELECT 
    u.id,
    u.full_name,
    u.email,
    COUNT(DISTINCT o.id) AS order_count,
    SUM(o.total) AS lifetime_value,
    AVG(o.total) AS avg_order_value,
    MIN(o.order_date) AS first_purchase,
    MAX(o.order_date) AS last_purchase,
    EXTRACT(DAY FROM (MAX(o.order_date) - MIN(o.order_date))) AS days_active,
    -- Calculate customer health score
    CASE 
        WHEN COUNT(DISTINCT o.id) >= 10 AND SUM(o.total) >= 1000 THEN 'VIP'
        WHEN COUNT(DISTINCT o.id) >= 5 AND SUM(o.total) >= 500 THEN 'Loyal'
        WHEN COUNT(DISTINCT o.id) >= 2 AND SUM(o.total) >= 100 THEN 'Regular'
        WHEN COUNT(DISTINCT o.id) >= 1 THEN 'New'
        ELSE 'Inactive'
    END AS customer_segment,
    -- Purchase frequency
    EXTRACT(DAY FROM (
        MAX(o.order_date) - MIN(o.order_date)
    )) / NULLIF(COUNT(DISTINCT o.id) - 1, 0) AS avg_days_between_orders,
    -- Last order recency
    CASE 
        WHEN MAX(o.order_date) >= CURRENT_DATE - INTERVAL '7 days' THEN 'Active'
        WHEN MAX(o.order_date) >= CURRENT_DATE - INTERVAL '30 days' THEN 'Recent'
        WHEN MAX(o.order_date) >= CURRENT_DATE - INTERVAL '90 days' THEN 'Lapsed'
        ELSE 'Churned'
    END AS recency_status
FROM users u
LEFT JOIN orders o ON u.id = o.user_id 
    AND o.status NOT IN ('cancelled', 'refunded')
    AND o.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.full_name, u.email
HAVING COUNT(DISTINCT o.id) > 0
ORDER BY lifetime_value DESC;
```

---

### D.4 Inventory Management Patterns

#### D.4.1 Real-time Inventory Tracking

```sql
-- Pattern: Track inventory with real-time availability
-- Problem: Get current inventory status with projected availability

CREATE OR REPLACE VIEW inventory_status AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    p.price,
    p.stock_quantity,
    -- Reserved quantity from attributes
    COALESCE((p.attributes->>'reserved')::INTEGER, 0) AS reserved_quantity,
    -- Available (can be sold)
    GREATEST(p.stock_quantity - COALESCE((p.attributes->>'reserved')::INTEGER, 0), 0) AS available_quantity,
    -- Total reserved (including orders in progress)
    (SELECT COALESCE(SUM(oi.quantity), 0)
     FROM order_items oi
     JOIN orders o ON oi.order_id = o.id
     WHERE oi.product_id = p.id
       AND o.status IN ('pending', 'processing')
       AND o.deleted_at IS NULL
       AND oi.deleted_at IS NULL) AS reserved_in_orders,
    -- Reorder point
    CASE 
        WHEN p.stock_quantity < 10 THEN 'CRITICAL'
        WHEN p.stock_quantity < 25 THEN 'LOW'
        WHEN p.stock_quantity < 50 THEN 'MEDIUM'
        ELSE 'OK'
    END AS stock_status,
    -- Days until out of stock (based on average daily sales)
    CASE 
        WHEN p.stock_quantity > 0 AND daily_sales.avg_daily > 0 THEN
            (p.stock_quantity / daily_sales.avg_daily)::INTEGER
        ELSE NULL
    END AS days_until_out_of_stock,
    -- Reorder recommendation
    CASE 
        WHEN p.stock_quantity < 10 THEN 'URGENT: Reorder now'
        WHEN p.stock_quantity < 25 THEN 'Order soon'
        WHEN p.stock_quantity < 50 THEN 'Monitor stock'
        ELSE 'Stock OK'
    END AS reorder_recommendation
FROM products p
LEFT JOIN (
    SELECT 
        product_id,
        AVG(quantity) AS avg_daily
    FROM (
        SELECT 
            oi.product_id,
            DATE(o.order_date) AS sale_date,
            SUM(oi.quantity) AS quantity
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.id
        WHERE o.status NOT IN ('cancelled', 'refunded')
          AND o.deleted_at IS NULL
          AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY oi.product_id, DATE(o.order_date)
    ) daily_sales
    GROUP BY product_id
) daily_sales ON p.id = daily_sales.product_id
WHERE p.deleted_at IS NULL;

-- Get inventory alerts
SELECT 
    product_id,
    product_name,
    stock_quantity,
    available_quantity,
    stock_status,
    reorder_recommendation,
    days_until_out_of_stock
FROM inventory_status
WHERE stock_status IN ('CRITICAL', 'LOW')
   OR available_quantity < 10
ORDER BY available_quantity ASC;

-- Update inventory after order fulfillment
CREATE OR REPLACE FUNCTION fulfill_order(
    p_order_id UUID
)
RETURNS TABLE(
    order_id UUID,
    status VARCHAR,
    items_fulfilled INTEGER
) AS $$
DECLARE
    v_item RECORD;
    v_fulfilled_count INTEGER := 0;
BEGIN
    -- Start transaction
    BEGIN
        -- Check order status
        IF NOT EXISTS (
            SELECT 1 FROM orders 
            WHERE id = p_order_id 
              AND status = 'processing'
              AND deleted_at IS NULL
        ) THEN
            RAISE EXCEPTION 'Order % is not in processing state', p_order_id;
        END IF;
        
        -- Process each item
        FOR v_item IN 
            SELECT 
                product_id,
                quantity
            FROM order_items
            WHERE order_id = p_order_id
              AND deleted_at IS NULL
        LOOP
            -- Update inventory
            UPDATE products
            SET 
                stock_quantity = stock_quantity - v_item.quantity,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = v_item.product_id
              AND stock_quantity >= v_item.quantity;
            
            -- Check if update was successful
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Insufficient stock for product %', v_item.product_id;
            END IF;
            
            v_fulfilled_count := v_fulfilled_count + 1;
        END LOOP;
        
        -- Update order status
        UPDATE orders
        SET 
            status = 'shipped',
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_order_id;
        
        -- Commit transaction
        COMMIT;
        
        -- Return success
        RETURN QUERY
        SELECT 
            p_order_id,
            'shipped' AS status,
            v_fulfilled_count;
            
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;
```

---

### D.5 Reporting & Analytics Patterns

#### D.5.1 Executive Dashboard

```sql
-- Pattern: Generate executive dashboard metrics
-- Problem: Create comprehensive business metrics for leadership

CREATE OR REPLACE VIEW executive_dashboard AS
WITH current_period AS (
    SELECT 
        DATE_TRUNC('month', CURRENT_DATE) AS period_start,
        DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day' AS period_end
),
previous_period AS (
    SELECT 
        DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month') AS period_start,
        DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 day' AS period_end
),
current_metrics AS (
    SELECT
        COUNT(DISTINCT o.id) AS orders,
        COUNT(DISTINCT o.user_id) AS customers,
        SUM(o.total) AS revenue,
        AVG(o.total) AS avg_order_value,
        SUM(oi.quantity) AS items_sold,
        COUNT(DISTINCT CASE WHEN o.status = 'new' THEN o.id END) AS new_orders
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.order_date BETWEEN (SELECT period_start FROM current_period)
        AND (SELECT period_end FROM current_period)
        AND o.status NOT IN ('cancelled', 'refunded')
),
previous_metrics AS (
    SELECT
        COUNT(DISTINCT o.id) AS orders,
        COUNT(DISTINCT o.user_id) AS customers,
        SUM(o.total) AS revenue,
        AVG(o.total) AS avg_order_value,
        SUM(oi.quantity) AS items_sold,
        COUNT(DISTINCT CASE WHEN o.status = 'new' THEN o.id END) AS new_orders
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.order_date BETWEEN (SELECT period_start FROM previous_period)
        AND (SELECT period_end FROM previous_period)
        AND o.status NOT IN ('cancelled', 'refunded')
),
top_products AS (
    SELECT 
        p.name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.line_total) AS revenue,
        RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
    FROM products p
    JOIN order_items oi ON p.id = oi.product_id
    JOIN orders o ON oi.order_id = o.id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
      AND o.status NOT IN ('cancelled', 'refunded')
    GROUP BY p.id, p.name
    LIMIT 5
)
SELECT 
    -- Current period metrics
    (SELECT revenue FROM current_metrics) AS current_revenue,
    (SELECT orders FROM current_metrics) AS current_orders,
    (SELECT customers FROM current_metrics) AS current_customers,
    (SELECT avg_order_value FROM current_metrics) AS current_avg_order,
    (SELECT items_sold FROM current_metrics) AS current_items_sold,
    (SELECT new_orders FROM current_metrics) AS current_new_orders,
    
    -- Previous period metrics (for comparison)
    (SELECT revenue FROM previous_metrics) AS previous_revenue,
    (SELECT orders FROM previous_metrics) AS previous_orders,
    (SELECT customers FROM previous_metrics) AS previous_customers,
    
    -- Growth percentages
    ROUND(
        ((SELECT revenue FROM current_metrics) - 
         (SELECT revenue FROM previous_metrics)) / 
        NULLIF((SELECT revenue FROM previous_metrics), 0) * 100,
        2
    ) AS revenue_growth_percent,
    
    ROUND(
        ((SELECT orders FROM current_metrics) - 
         (SELECT orders FROM previous_metrics)) / 
        NULLIF((SELECT orders FROM previous_metrics), 0) * 100,
        2
    ) AS order_growth_percent,
    
    -- Top products
    (SELECT jsonb_agg(
        jsonb_build_object(
            'name', name,
            'units_sold', units_sold,
            'revenue', revenue,
            'rank', revenue_rank
        )
    ) FROM top_products) AS top_products,
    
    -- Daily average
    ROUND((SELECT revenue FROM current_metrics) / 30, 2) AS daily_average_revenue,
    
    -- Conversion rate (if we had visitors data)
    -- This would be joined with analytics data
    
    -- Timestamp
    CURRENT_TIMESTAMP AS generated_at;
```

#### D.5.2 Customer Retention Analysis

```sql
-- Pattern: Analyze customer retention and churn
-- Problem: Understand customer lifecycle and retention rates

WITH customer_orders AS (
    SELECT 
        u.id AS user_id,
        u.full_name,
        u.email,
        u.created_at AS signup_date,
        o.id AS order_id,
        o.order_date,
        o.total,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.order_date) AS order_sequence,
        LAG(o.order_date) OVER (PARTITION BY u.id ORDER BY o.order_date) AS previous_order_date
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id 
        AND o.status NOT IN ('cancelled', 'refunded')
        AND o.deleted_at IS NULL
    WHERE u.deleted_at IS NULL
),
cohorts AS (
    SELECT 
        user_id,
        full_name,
        email,
        DATE_TRUNC('month', signup_date) AS signup_cohort,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total) AS lifetime_value,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        AVG(total) AS avg_order_value,
        -- Days between orders
        AVG(
            EXTRACT(EPOCH FROM (order_date - previous_order_date)) / 86400
        ) FILTER (WHERE previous_order_date IS NOT NULL) AS avg_days_between_orders
    FROM customer_orders
    GROUP BY user_id, full_name, email, signup_date
),
retention_metrics AS (
    SELECT 
        signup_cohort,
        COUNT(*) AS total_customers,
        SUM(CASE WHEN total_orders >= 1 THEN 1 ELSE 0 END) AS active_customers,
        SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
        SUM(CASE WHEN total_orders >= 5 THEN 1 ELSE 0 END) AS loyal_customers,
        AVG(lifetime_value) AS avg_lifetime_value,
        AVG(total_orders) AS avg_orders_per_customer,
        -- Retention rates
        ROUND(
            (SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END)::FLOAT / 
             NULLIF(SUM(CASE WHEN total_orders >= 1 THEN 1 ELSE 0 END), 0)) * 100,
            2
        ) AS repeat_rate,
        -- Churn prediction (no order in last 90 days)
        SUM(CASE 
            WHEN total_orders >= 1 
             AND last_order_date < CURRENT_DATE - INTERVAL '90 days' 
            THEN 1 ELSE 0 
        END) AS churned_customers,
        ROUND(
            (SUM(CASE 
                WHEN total_orders >= 1 
                 AND last_order_date < CURRENT_DATE - INTERVAL '90 days' 
                THEN 1 ELSE 0 
            END)::FLOAT / 
            NULLIF(SUM(CASE WHEN total_orders >= 1 THEN 1 ELSE 0 END), 0)) * 100,
            2
        ) AS churn_rate
    FROM cohorts
    GROUP BY signup_cohort
    ORDER BY signup_cohort DESC
)
SELECT 
    signup_cohort,
    total_customers,
    active_customers,
    repeat_customers,
    loyal_customers,
    avg_lifetime_value,
    avg_orders_per_customer,
    repeat_rate || '%' AS repeat_rate_percent,
    churned_customers,
    churn_rate || '%' AS churn_rate_percent,
    -- Health score
    CASE 
        WHEN repeat_rate >= 40 AND churn_rate < 20 THEN 'Excellent'
        WHEN repeat_rate >= 25 AND churn_rate < 30 THEN 'Good'
        WHEN repeat_rate >= 15 AND churn_rate < 40 THEN 'Fair'
        ELSE 'Needs Improvement'
    END AS cohort_health
FROM retention_metrics;
```

---

### D.6 Performance Optimization Patterns

#### D.6.1 Query Optimization Patterns

```sql
-- Pattern: Optimize slow queries with proper indexing
-- Problem: Identify and fix common performance bottlenecks

-- 1. Function to suggest missing indexes
CREATE OR REPLACE FUNCTION suggest_missing_indexes()
RETURNS TABLE(
    table_name TEXT,
    column_name TEXT,
    suggestion TEXT,
    impact TEXT
) AS $$
BEGIN
    -- Check tables with sequential scans on large tables
    RETURN QUERY
    SELECT 
        t.relname::TEXT AS table_name,
        a.attname::TEXT AS column_name,
        'CREATE INDEX CONCURRENTLY idx_' || t.relname || '_' || a.attname || 
        ' ON ' || t.relname || '(' || a.attname || ');' AS suggestion,
        CASE 
            WHEN t.relpages > 1000 THEN 'HIGH'
            WHEN t.relpages > 500 THEN 'MEDIUM'
            ELSE 'LOW'
        END AS impact
    FROM pg_class t
    JOIN pg_namespace n ON t.relnamespace = n.oid
    JOIN pg_attribute a ON a.attrelid = t.oid
    LEFT JOIN pg_index i ON i.indrelid = t.oid AND a.attnum = ANY(i.indkey)
    LEFT JOIN pg_stat_user_tables s ON s.relid = t.oid
    WHERE n.nspname = 'public'
      AND t.relkind = 'r'
      AND a.attnum > 0
      AND NOT a.attisdropped
      AND i.indexrelid IS NULL
      AND t.relpages > 100  -- Tables with > 100 pages
      AND s.seq_scan > 1000  -- Frequent sequential scans
      AND a.attname IN (
          'user_id', 'product_id', 'order_id', 'status', 
          'created_at', 'updated_at', 'email', 'username'
      );
END;
$$ LANGUAGE plpgsql;

-- Run index suggestions
SELECT * FROM suggest_missing_indexes();

-- 2. Analyze and optimize specific queries
CREATE OR REPLACE FUNCTION analyze_query_performance(
    p_query TEXT
)
RETURNS TABLE(
    analysis_type TEXT,
    recommendation TEXT,
    estimated_improvement TEXT
) AS $$
DECLARE
    v_plan jsonb;
    v_timing record;
    v_index_suggestion TEXT;
BEGIN
    -- Get execution plan
    EXECUTE 'EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ' || p_query
    INTO v_plan;
    
    -- Analyze plan
    IF v_plan::TEXT LIKE '%Seq Scan%' THEN
        RETURN QUERY SELECT 
            'Sequential Scan Found'::TEXT,
            'Consider adding appropriate indexes or using WHERE clause on indexed columns'::TEXT,
            'Potential 10x-100x improvement'::TEXT;
    END IF;
    
    IF v_plan::TEXT LIKE '%Nested Loop%' AND v_plan::TEXT LIKE '%rows=0%' THEN
        RETURN QUERY SELECT 
            'Inefficient Nested Loop'::TEXT,
            'Consider rewriting query with EXISTS or IN instead of correlated subquery'::TEXT,
            'Potential 2x-10x improvement'::TEXT;
    END IF;
    
    IF v_plan::TEXT LIKE '%Sort%' AND v_plan::TEXT LIKE '%rows=1000%' THEN
        RETURN QUERY SELECT 
            'Large Sort Operation'::TEXT,
            'Consider adding index on ORDER BY column or using LIMIT'::TEXT,
            'Potential 3x-5x improvement'::TEXT;
    END IF;
    
    -- If no issues found
    RETURN QUERY SELECT 
        'No Issues Found'::TEXT,
        'Query appears to be optimized'::TEXT,
        'N/A'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Example usage
SELECT * FROM analyze_query_performance(
    'SELECT * FROM orders JOIN users ON orders.user_id = users.id WHERE orders.status = ''pending'''
);
```

---

This appendix provides a comprehensive collection of SQL query patterns and recipes for common e-commerce operations. Use these patterns as building blocks for your application, adapting them to your specific needs and data models.
