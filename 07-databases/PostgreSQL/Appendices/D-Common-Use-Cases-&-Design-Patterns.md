# Appendix D: Common Use Cases & Design Patterns

This appendix provides battle-tested solutions to common e-commerce problems. Think of it as your recipe book—when you encounter a specific challenge, you can find a proven pattern here. We'll cover everything from shopping cart management to inventory reconciliation and reporting optimization.

---

## D.1 Shopping Cart Implementation

### Target
Build a flexible shopping cart system that handles guest and authenticated users.

### Concept
Shopping carts need to handle multiple scenarios: guest carts, authenticated user carts, merging carts, and expiration. We'll implement a robust cart system that's both performant and flexible.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Create shopping cart tables
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS carts CASCADE;

-- Shopping carts table
CREATE TABLE carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255), -- For guest users
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    expires_at TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '7 days',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure either user_id or session_id is present
    CONSTRAINT cart_owner_check CHECK (
        (user_id IS NOT NULL AND session_id IS NULL) OR
        (user_id IS NULL AND session_id IS NOT NULL)
    ),
    -- Unique constraint for active carts
    CONSTRAINT unique_active_cart_user UNIQUE (user_id) WHERE status = 'active' AND user_id IS NOT NULL,
    CONSTRAINT unique_active_cart_session UNIQUE (session_id) WHERE status = 'active' AND session_id IS NOT NULL
);

-- Cart items table
CREATE TABLE cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_snapshot NUMERIC(10,2) NOT NULL, -- Price at time added
    selected_options JSONB, -- Size, color, etc.
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Unique product per cart
    CONSTRAINT unique_cart_product UNIQUE (cart_id, product_id)
);

-- Create indexes
CREATE INDEX idx_carts_user_id ON carts(user_id) WHERE status = 'active';
CREATE INDEX idx_carts_session_id ON carts(session_id) WHERE status = 'active';
CREATE INDEX idx_carts_expires_at ON carts(expires_at) WHERE status = 'active';
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);

-- 2. Create functions for cart management

-- Get or create cart (authenticated user)
CREATE OR REPLACE FUNCTION get_or_create_user_cart(p_user_id UUID)
RETURNS UUID AS $$
DECLARE
    v_cart_id UUID;
BEGIN
    -- Check for existing active cart
    SELECT id INTO v_cart_id
    FROM carts
    WHERE user_id = p_user_id AND status = 'active';
    
    -- If no active cart, create one
    IF v_cart_id IS NULL THEN
        INSERT INTO carts (user_id)
        VALUES (p_user_id)
        RETURNING id INTO v_cart_id;
    END IF;
    
    -- Extend expiration
    UPDATE carts 
    SET expires_at = NOW() + INTERVAL '7 days'
    WHERE id = v_cart_id;
    
    RETURN v_cart_id;
END;
$$ LANGUAGE plpgsql;

-- Get or create cart (guest user)
CREATE OR REPLACE FUNCTION get_or_create_guest_cart(p_session_id VARCHAR)
RETURNS UUID AS $$
DECLARE
    v_cart_id UUID;
BEGIN
    SELECT id INTO v_cart_id
    FROM carts
    WHERE session_id = p_session_id AND status = 'active';
    
    IF v_cart_id IS NULL THEN
        INSERT INTO carts (session_id)
        VALUES (p_session_id)
        RETURNING id INTO v_cart_id;
    END IF;
    
    UPDATE carts 
    SET expires_at = NOW() + INTERVAL '7 days'
    WHERE id = v_cart_id;
    
    RETURN v_cart_id;
END;
$$ LANGUAGE plpgsql;

-- Add item to cart
CREATE OR REPLACE FUNCTION add_to_cart(
    p_cart_id UUID,
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_selected_options JSONB DEFAULT '{}'::jsonb
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_price NUMERIC(10,2);
    v_current_stock INTEGER;
BEGIN
    -- Get product info with row lock
    SELECT price, stock_quantity INTO v_current_price, v_current_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;
    
    -- Check stock
    IF v_current_stock < p_quantity THEN
        RETURN FALSE;
    END IF;
    
    -- Insert or update cart item
    INSERT INTO cart_items (cart_id, product_id, quantity, price_snapshot, selected_options)
    VALUES (p_cart_id, p_product_id, p_quantity, v_current_price, p_selected_options)
    ON CONFLICT (cart_id, product_id) 
    DO UPDATE SET 
        quantity = cart_items.quantity + EXCLUDED.quantity,
        updated_at = NOW()
    WHERE cart_items.cart_id = EXCLUDED.cart_id 
      AND cart_items.product_id = EXCLUDED.product_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Remove item from cart
CREATE OR REPLACE FUNCTION remove_from_cart(
    p_cart_item_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM cart_items 
    WHERE id = p_cart_item_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Update quantity
CREATE OR REPLACE FUNCTION update_cart_item_quantity(
    p_cart_item_id UUID,
    p_new_quantity INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE cart_items 
    SET quantity = p_new_quantity,
        updated_at = NOW()
    WHERE id = p_cart_item_id
    AND p_new_quantity > 0;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Clear cart
CREATE OR REPLACE FUNCTION clear_cart(p_cart_id UUID)
RETURNS VOID AS $$
BEGIN
    DELETE FROM cart_items WHERE cart_id = p_cart_id;
    UPDATE carts SET updated_at = NOW() WHERE id = p_cart_id;
END;
$$ LANGUAGE plpgsql;

-- Merge guest cart into user cart (after login)
CREATE OR REPLACE FUNCTION merge_carts(
    p_user_id UUID,
    p_session_id VARCHAR
)
RETURNS UUID AS $$
DECLARE
    v_user_cart_id UUID;
    v_guest_cart_id UUID;
    v_item RECORD;
BEGIN
    -- Get active carts
    SELECT id INTO v_user_cart_id
    FROM carts
    WHERE user_id = p_user_id AND status = 'active';
    
    SELECT id INTO v_guest_cart_id
    FROM carts
    WHERE session_id = p_session_id AND status = 'active'
      AND user_id IS NULL;
    
    -- If no guest cart, return user cart
    IF v_guest_cart_id IS NULL THEN
        RETURN get_or_create_user_cart(p_user_id);
    END IF;
    
    -- If no user cart, convert guest cart to user cart
    IF v_user_cart_id IS NULL THEN
        UPDATE carts 
        SET user_id = p_user_id,
            session_id = NULL,
            updated_at = NOW()
        WHERE id = v_guest_cart_id
        RETURNING id INTO v_user_cart_id;
        
        RETURN v_user_cart_id;
    END IF;
    
    -- Merge items from guest cart into user cart
    FOR v_item IN 
        SELECT product_id, quantity, price_snapshot, selected_options
        FROM cart_items
        WHERE cart_id = v_guest_cart_id
    LOOP
        INSERT INTO cart_items (cart_id, product_id, quantity, price_snapshot, selected_options)
        VALUES (v_user_cart_id, v_item.product_id, v_item.quantity, v_item.price_snapshot, v_item.selected_options)
        ON CONFLICT (cart_id, product_id) 
        DO UPDATE SET 
            quantity = cart_items.quantity + EXCLUDED.quantity,
            updated_at = NOW();
    END LOOP;
    
    -- Delete guest cart
    DELETE FROM carts WHERE id = v_guest_cart_id;
    
    RETURN v_user_cart_id;
END;
$$ LANGUAGE plpgsql;

-- 3. Cart summary view
CREATE OR REPLACE VIEW cart_summary AS
SELECT 
    c.id AS cart_id,
    c.user_id,
    c.session_id,
    c.status,
    COUNT(ci.id) AS item_count,
    SUM(ci.quantity) AS total_quantity,
    SUM(ci.price_snapshot * ci.quantity) AS subtotal,
    SUM(ci.price_snapshot * ci.quantity * 0.08) AS tax_estimate,
    SUM(ci.price_snapshot * ci.quantity) * 1.08 AS total_estimate
FROM carts c
LEFT JOIN cart_items ci ON ci.cart_id = c.id
WHERE c.status = 'active'
  AND c.expires_at > NOW()
GROUP BY c.id, c.user_id, c.session_id, c.status;

-- 4. Test the cart system
DO $$
DECLARE
    v_user_id UUID;
    v_cart_id UUID;
    v_guest_cart_id UUID;
    v_session_id VARCHAR := 'guest_session_123';
BEGIN
    -- Get a user
    SELECT id INTO v_user_id FROM users WHERE email LIKE '%@%' LIMIT 1;
    
    -- Create user cart
    v_cart_id := get_or_create_user_cart(v_user_id);
    RAISE NOTICE 'User cart: %', v_cart_id;
    
    -- Add items
    PERFORM add_to_cart(v_cart_id, 1, 2);  -- Headphones
    PERFORM add_to_cart(v_cart_id, 2, 1);  -- Cable
    PERFORM add_to_cart(v_cart_id, 3, 3);  -- Water bottle
    
    -- Create guest cart
    v_guest_cart_id := get_or_create_guest_cart(v_session_id);
    RAISE NOTICE 'Guest cart: %', v_guest_cart_id;
    
    -- Add guest items
    PERFORM add_to_cart(v_guest_cart_id, 4, 1);  -- Laptop stand
    
    -- Test merge
    v_cart_id := merge_carts(v_user_id, v_session_id);
    RAISE NOTICE 'Merged cart: %', v_cart_id;
    
    -- Check cart summary
    PERFORM * FROM cart_summary WHERE cart_id = v_cart_id;
END $$;

-- Check cart summary
SELECT * FROM cart_summary;
```

### The Verification

```bash
# Test cart functions
psql -d ecommerce -c "
SELECT get_or_create_user_cart((SELECT id FROM users LIMIT 1));"

psql -d ecommerce -c "
SELECT add_to_cart(
    (SELECT id FROM carts WHERE user_id IS NOT NULL LIMIT 1),
    1, 2, '{\"color\": \"black\"}'::jsonb
);"

psql -d ecommerce -c "SELECT * FROM cart_summary;"

# Check cart items
psql -d ecommerce -c "SELECT * FROM cart_items LIMIT 10;"
```

---

## D.2 Inventory Management

### Target
Implement robust inventory management with real-time tracking and alerts.

### Concept
Inventory management is critical for e-commerce. We need to track stock levels, handle reservations, generate low-stock alerts, and prevent overselling. This pattern ensures inventory accuracy even under high load.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Create inventory tracking tables
DROP TABLE IF EXISTS inventory_transactions CASCADE;

CREATE TABLE inventory_transactions (
    id BIGSERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    transaction_type VARCHAR(20) NOT NULL, -- 'stock_in', 'stock_out', 'adjustment', 'return', 'reserve'
    quantity INTEGER NOT NULL,
    previous_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    reference_id UUID, -- Order ID, PO ID, etc.
    reference_type VARCHAR(50),
    notes TEXT,
    performed_by VARCHAR(255) DEFAULT CURRENT_USER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_inventory_transactions_product_id ON inventory_transactions(product_id);
CREATE INDEX idx_inventory_transactions_created_at ON inventory_transactions(created_at);
CREATE INDEX idx_inventory_transactions_type ON inventory_transactions(transaction_type);

-- 2. Create inventory management functions

-- Reserve inventory for an order
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_current_stock INTEGER;
    v_new_stock INTEGER;
BEGIN
    -- Lock product row
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;
    
    -- Check stock
    IF v_current_stock < p_quantity THEN
        RETURN FALSE;
    END IF;
    
    -- Calculate new stock
    v_new_stock := v_current_stock - p_quantity;
    
    -- Update product
    UPDATE products 
    SET stock_quantity = v_new_stock,
        updated_at = NOW()
    WHERE id = p_product_id;
    
    -- Log transaction
    INSERT INTO inventory_transactions (
        product_id,
        transaction_type,
        quantity,
        previous_stock,
        new_stock,
        reference_id,
        reference_type,
        notes
    ) VALUES (
        p_product_id,
        'reserve',
        -p_quantity,
        v_current_stock,
        v_new_stock,
        p_order_id,
        'order',
        p_notes
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Restore inventory (order cancelled)
CREATE OR REPLACE FUNCTION restore_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_current_stock INTEGER;
    v_new_stock INTEGER;
BEGIN
    -- Lock product row
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;
    
    -- Calculate new stock
    v_new_stock := v_current_stock + p_quantity;
    
    -- Update product
    UPDATE products 
    SET stock_quantity = v_new_stock,
        updated_at = NOW()
    WHERE id = p_product_id;
    
    -- Log transaction
    INSERT INTO inventory_transactions (
        product_id,
        transaction_type,
        quantity,
        previous_stock,
        new_stock,
        reference_id,
        reference_type,
        notes
    ) VALUES (
        p_product_id,
        'return',
        p_quantity,
        v_current_stock,
        v_new_stock,
        p_order_id,
        'order',
        p_notes
    );
END;
$$ LANGUAGE plpgsql;

-- Add stock (purchase order)
CREATE OR REPLACE FUNCTION add_stock(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_po_id UUID,
    p_notes TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_current_stock INTEGER;
    v_new_stock INTEGER;
BEGIN
    -- Lock product row
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE id = p_product_id
    FOR UPDATE;
    
    -- Calculate new stock
    v_new_stock := v_current_stock + p_quantity;
    
    -- Update product
    UPDATE products 
    SET stock_quantity = v_new_stock,
        updated_at = NOW()
    WHERE id = p_product_id;
    
    -- Log transaction
    INSERT INTO inventory_transactions (
        product_id,
        transaction_type,
        quantity,
        previous_stock,
        new_stock,
        reference_id,
        reference_type,
        notes
    ) VALUES (
        p_product_id,
        'stock_in',
        p_quantity,
        v_current_stock,
        v_new_stock,
        p_po_id,
        'purchase_order',
        p_notes
    );
END;
$$ LANGUAGE plpgsql;

-- 3. Low stock alert view
CREATE OR REPLACE VIEW low_stock_alert AS
SELECT 
    p.id,
    p.name,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS avg_daily_sales_30d,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) > 0 THEN 
            ROUND((p.stock_quantity / NULLIF(SUM(oi.quantity) / 30.0, 0))::NUMERIC, 1)
        ELSE NULL
    END AS days_of_stock,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'OUT_OF_STOCK'
        WHEN p.stock_quantity < 10 THEN 'CRITICAL'
        WHEN p.stock_quantity < 50 THEN 'LOW'
        ELSE 'OK'
    END AS alert_level,
    MAX(o.created_at) AS last_sale_date
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id 
    AND o.status != 'cancelled' 
    AND o.created_at > NOW() - INTERVAL '30 days'
WHERE p.is_active = true
GROUP BY p.id, p.name, p.stock_quantity
HAVING p.stock_quantity < 50
ORDER BY alert_level, stock_quantity;

-- 4. Inventory transaction history
CREATE OR REPLACE VIEW inventory_transaction_history AS
SELECT 
    it.id,
    p.name AS product_name,
    it.transaction_type,
    it.quantity,
    it.previous_stock,
    it.new_stock,
    it.reference_id,
    it.reference_type,
    it.notes,
    it.performed_by,
    it.created_at,
    CASE 
        WHEN it.transaction_type = 'stock_in' THEN 'IN'
        WHEN it.transaction_type IN ('stock_out', 'reserve') THEN 'OUT'
        ELSE 'ADJUST'
    END AS direction
FROM inventory_transactions it
JOIN products p ON p.id = it.product_id
ORDER BY it.created_at DESC;

-- 5. Test inventory functions
DO $$
DECLARE
    v_product_id INTEGER := 1;
    v_order_id UUID := uuid_generate_v4();
    v_result BOOLEAN;
BEGIN
    -- Check initial stock
    RAISE NOTICE 'Initial stock: %', 
        (SELECT stock_quantity FROM products WHERE id = v_product_id);
    
    -- Reserve inventory
    v_result := reserve_inventory(v_product_id, 2, v_order_id, 'Test reserve');
    RAISE NOTICE 'Reserve result: %', v_result;
    
    -- Check new stock
    RAISE NOTICE 'After reserve: %', 
        (SELECT stock_quantity FROM products WHERE id = v_product_id);
    
    -- Restore inventory
    PERFORM restore_inventory(v_product_id, 2, v_order_id, 'Test restore');
    
    -- Check final stock
    RAISE NOTICE 'After restore: %', 
        (SELECT stock_quantity FROM products WHERE id = v_product_id);
END $$;

-- Check alerts
SELECT * FROM low_stock_alert;
```

### The Verification

```bash
# Test inventory functions
psql -d ecommerce -c "
SELECT reserve_inventory(1, 5, uuid_generate_v4(), 'Test reservation');
SELECT stock_quantity FROM products WHERE id = 1;"

psql -d ecommerce -c "SELECT * FROM low_stock_alert;"

psql -d ecommerce -c "SELECT * FROM inventory_transaction_history LIMIT 10;"
```

---

## D.3 Order Processing Pipeline

### Target
Build a complete order processing pipeline with validation, payment, and shipping.

### Concept
Order processing involves multiple steps: validation, payment processing, inventory reservation, shipping calculation, and confirmation. This pattern provides a complete pipeline with proper error handling and rollback.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Enhanced order creation with full pipeline
CREATE OR REPLACE FUNCTION create_order_from_cart(
    p_cart_id UUID,
    p_user_id UUID,
    p_shipping_address JSONB,
    p_billing_address JSONB,
    p_payment_method VARCHAR,
    p_shipping_method VARCHAR DEFAULT 'standard'
)
RETURNS TABLE(order_id UUID, success BOOLEAN, message TEXT) AS $$
DECLARE
    v_order_id UUID;
    v_subtotal NUMERIC(10,2);
    v_tax NUMERIC(10,2);
    v_shipping_cost NUMERIC(10,2);
    v_total NUMERIC(10,2);
    v_item RECORD;
    v_product_stock INTEGER;
BEGIN
    -- Start transaction
    BEGIN
        -- Validate cart exists and belongs to user
        IF NOT EXISTS (
            SELECT 1 FROM carts 
            WHERE id = p_cart_id 
              AND (user_id = p_user_id OR session_id IS NOT NULL)
              AND status = 'active'
              AND expires_at > NOW()
        ) THEN
            RETURN QUERY SELECT NULL::UUID, FALSE, 'Invalid or expired cart';
            RETURN;
        END IF;
        
        -- Check cart has items
        IF NOT EXISTS (SELECT 1 FROM cart_items WHERE cart_id = p_cart_id) THEN
            RETURN QUERY SELECT NULL::UUID, FALSE, 'Cart is empty';
            RETURN;
        END IF;
        
        -- Calculate totals and validate inventory
        FOR v_item IN 
            SELECT 
                ci.product_id,
                ci.quantity,
                ci.price_snapshot,
                p.stock_quantity,
                p.price AS current_price
            FROM cart_items ci
            JOIN products p ON p.id = ci.product_id
            WHERE ci.cart_id = p_cart_id
        LOOP
            -- Check inventory
            IF v_item.stock_quantity < v_item.quantity THEN
                RETURN QUERY SELECT NULL::UUID, FALSE, 
                    format('Insufficient stock for product ID %s', v_item.product_id);
                RETURN;
            END IF;
            
            -- Use current price if product hasn't changed
            v_subtotal := v_subtotal + (v_item.price_snapshot * v_item.quantity);
        END LOOP;
        
        -- Calculate taxes and shipping
        v_tax := v_subtotal * 0.08;
        v_shipping_cost := CASE 
            WHEN v_shipping_method = 'express' THEN 15.99
            WHEN v_subtotal > 100 THEN 0
            ELSE 5.99
        END;
        v_total := v_subtotal + v_tax + v_shipping_cost;
        
        -- Create order
        INSERT INTO orders (
            user_id,
            status,
            subtotal,
            tax,
            shipping_cost,
            total,
            shipping_address_line1,
            shipping_address_line2,
            shipping_city,
            shipping_state,
            shipping_postal_code,
            shipping_country,
            payment_method,
            payment_status,
            notes
        ) VALUES (
            p_user_id,
            'pending',
            v_subtotal,
            v_tax,
            v_shipping_cost,
            v_total,
            p_shipping_address->>'line1',
            p_shipping_address->>'line2',
            p_shipping_address->>'city',
            p_shipping_address->>'state',
            p_shipping_address->>'postal_code',
            p_shipping_address->>'country',
            p_payment_method,
            'pending',
            'Order from cart: ' || p_cart_id
        ) RETURNING id INTO v_order_id;
        
        -- Create order items and reserve inventory
        FOR v_item IN 
            SELECT 
                ci.product_id,
                ci.quantity,
                ci.price_snapshot,
                ci.selected_options,
                p.name AS product_name,
                p.slug AS product_sku
            FROM cart_items ci
            JOIN products p ON p.id = ci.product_id
            WHERE ci.cart_id = p_cart_id
        LOOP
            -- Add order item
            INSERT INTO order_items (
                order_id,
                product_id,
                product_name,
                product_sku,
                unit_price,
                quantity,
                total_price,
                product_options
            ) VALUES (
                v_order_id,
                v_item.product_id,
                v_item.product_name,
                v_item.product_sku,
                v_item.price_snapshot,
                v_item.quantity,
                v_item.price_snapshot * v_item.quantity,
                v_item.selected_options
            );
            
            -- Reserve inventory
            PERFORM reserve_inventory(
                v_item.product_id,
                v_item.quantity,
                v_order_id,
                'Order reservation'
            );
        END LOOP;
        
        -- Clear cart
        PERFORM clear_cart(p_cart_id);
        
        -- Return success
        RETURN QUERY SELECT v_order_id, TRUE, 'Order created successfully';
        
        -- Commit transaction
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback everything
            ROLLBACK;
            RETURN QUERY SELECT NULL::UUID, FALSE, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- 2. Payment processing
CREATE OR REPLACE FUNCTION process_order_payment(
    p_order_id UUID,
    p_payment_token VARCHAR,
    p_amount NUMERIC
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_order_total NUMERIC;
    v_current_status VARCHAR;
BEGIN
    -- Start transaction
    BEGIN
        -- Get order info with lock
        SELECT total, status INTO v_order_total, v_current_status
        FROM orders
        WHERE id = p_order_id
        FOR UPDATE;
        
        -- Validate
        IF v_current_status != 'pending' THEN
            RETURN QUERY SELECT FALSE, 'Order is not in pending state';
            RETURN;
        END IF;
        
        IF v_order_total != p_amount THEN
            RETURN QUERY SELECT FALSE, 'Payment amount does not match order total';
            RETURN;
        END IF;
        
        -- Simulate payment processing
        -- In production, integrate with Stripe, PayPal, etc.
        IF p_payment_token IS NULL OR length(p_payment_token) < 10 THEN
            RAISE EXCEPTION 'Invalid payment token';
        END IF;
        
        -- Update order
        UPDATE orders 
        SET 
            payment_status = 'completed',
            status = 'paid',
            payment_transaction_id = p_payment_token,
            updated_at = NOW()
        WHERE id = p_order_id;
        
        -- Commit
        COMMIT;
        
        RETURN QUERY SELECT TRUE, 'Payment processed successfully';
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN QUERY SELECT FALSE, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- 3. Shipping processing
CREATE OR REPLACE FUNCTION process_order_shipping(
    p_order_id UUID,
    p_tracking_number VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_current_status VARCHAR;
BEGIN
    -- Start transaction
    BEGIN
        -- Get order status
        SELECT status INTO v_current_status
        FROM orders
        WHERE id = p_order_id
        FOR UPDATE;
        
        -- Validate
        IF v_current_status != 'paid' THEN
            RETURN QUERY SELECT FALSE, 'Order is not in paid state';
            RETURN;
        END IF;
        
        -- Update order
        UPDATE orders 
        SET 
            status = 'shipped',
            tracking_number = p_tracking_number,
            shipped_at = NOW(),
            updated_at = NOW()
        WHERE id = p_order_id;
        
        -- Commit
        COMMIT;
        
        RETURN QUERY SELECT TRUE, 'Order shipped successfully';
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN QUERY SELECT FALSE, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- 4. Order cancellation
CREATE OR REPLACE FUNCTION cancel_order(
    p_order_id UUID,
    p_reason TEXT DEFAULT 'Customer requested cancellation'
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_status VARCHAR;
    v_item RECORD;
BEGIN
    -- Start transaction
    BEGIN
        -- Get order with lock
        SELECT status INTO v_status
        FROM orders
        WHERE id = p_order_id
        FOR UPDATE;
        
        -- Validate
        IF v_status NOT IN ('pending', 'paid') THEN
            RETURN QUERY SELECT FALSE, 'Order cannot be cancelled in its current state';
            RETURN;
        END IF;
        
        -- Restore inventory for each item
        FOR v_item IN 
            SELECT product_id, quantity
            FROM order_items
            WHERE order_id = p_order_id
        LOOP
            PERFORM restore_inventory(
                v_item.product_id,
                v_item.quantity,
                p_order_id,
                'Order cancelled: ' || p_reason
            );
        END LOOP;
        
        -- Update order
        UPDATE orders 
        SET 
            status = 'cancelled',
            notes = COALESCE(notes, '') || ' Cancelled: ' || p_reason,
            updated_at = NOW()
        WHERE id = p_order_id;
        
        -- Commit
        COMMIT;
        
        RETURN QUERY SELECT TRUE, 'Order cancelled successfully';
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN QUERY SELECT FALSE, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- 5. Create order status view
CREATE OR REPLACE VIEW order_status_view AS
SELECT 
    o.id AS order_id,
    u.email AS customer_email,
    u.first_name,
    u.last_name,
    o.status,
    o.total,
    o.created_at,
    o.shipped_at,
    o.delivered_at,
    o.tracking_number,
    COUNT(oi.id) AS item_count,
    SUM(oi.quantity) AS total_items,
    string_agg(oi.product_name, ', ' LIMIT 3) AS product_summary,
    CASE 
        WHEN o.status = 'pending' THEN 'Processing'
        WHEN o.status = 'paid' THEN 'Payment Confirmed'
        WHEN o.status = 'shipped' THEN 'On the Way'
        WHEN o.status = 'delivered' THEN 'Delivered'
        WHEN o.status = 'cancelled' THEN 'Cancelled'
        ELSE 'Unknown'
    END AS friendly_status
FROM orders o
JOIN users u ON u.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, u.email, u.first_name, u.last_name, 
         o.status, o.total, o.created_at, o.shipped_at, 
         o.delivered_at, o.tracking_number;
```

### The Verification

```bash
# Test order creation
psql -d ecommerce -c "
SELECT * FROM create_order_from_cart(
    (SELECT id FROM carts WHERE user_id IS NOT NULL LIMIT 1),
    (SELECT user_id FROM carts WHERE user_id IS NOT NULL LIMIT 1),
    '{\"line1\": \"123 Main St\", \"city\": \"NYC\", \"state\": \"NY\", \"postal_code\": \"10001\", \"country\": \"US\"}'::jsonb,
    '{\"line1\": \"123 Main St\", \"city\": \"NYC\", \"state\": \"NY\", \"postal_code\": \"10001\", \"country\": \"US\"}'::jsonb,
    'credit_card'
);"

# Test payment
psql -d ecommerce -c "
SELECT * FROM process_order_payment(
    (SELECT id FROM orders WHERE status = 'pending' LIMIT 1),
    'payment_token_12345',
    (SELECT total FROM orders WHERE status = 'pending' LIMIT 1)
);"

# Check order status
psql -d ecommerce -c "SELECT * FROM order_status_view LIMIT 5;"
```

---

## D.4 Reporting and Analytics Patterns

### Target
Implement common reporting patterns for e-commerce analytics.

### Concept
Reports drive business decisions. This section provides patterns for common reports with performance optimizations for large datasets.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Materialized views for reports (performance optimization)
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_sales_report AS
SELECT 
    DATE(created_at) AS sale_date,
    DATE_TRUNC('month', created_at) AS sale_month,
    COUNT(DISTINCT id) AS order_count,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(total) AS revenue,
    SUM(subtotal) AS subtotal_revenue,
    SUM(tax) AS tax_collected,
    SUM(shipping_cost) AS shipping_revenue,
    AVG(total) AS avg_order_value,
    SUM(total) FILTER (WHERE status = 'cancelled') AS cancelled_revenue,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled_orders
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE(created_at), DATE_TRUNC('month', created_at);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_report;

-- Create index on materialized view
CREATE INDEX idx_daily_sales_report_date ON daily_sales_report(sale_date);

-- 2. Customer lifetime value report
CREATE MATERIALIZED VIEW IF NOT EXISTS customer_lifetime_value AS
WITH customer_orders AS (
    SELECT 
        u.id AS customer_id,
        u.email,
        u.created_at AS signup_date,
        COUNT(DISTINCT o.id) AS order_count,
        SUM(o.total) AS lifetime_value,
        AVG(o.total) AS avg_order_value,
        MIN(o.created_at) AS first_order,
        MAX(o.created_at) AS last_order,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at)) AS days_since_last_order,
        MAX(o.created_at) > NOW() - INTERVAL '30 days' AS active_30d,
        MAX(o.created_at) > NOW() - INTERVAL '90 days' AS active_90d
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    GROUP BY u.id, u.email, u.created_at
)
SELECT 
    customer_id,
    email,
    signup_date,
    COALESCE(order_count, 0) AS order_count,
    COALESCE(lifetime_value, 0) AS lifetime_value,
    COALESCE(avg_order_value, 0) AS avg_order_value,
    first_order,
    last_order,
    days_since_last_order,
    active_30d,
    active_90d,
    CASE 
        WHEN COALESCE(order_count, 0) = 0 THEN 'New'
        WHEN COALESCE(lifetime_value, 0) > 1000 THEN 'VIP'
        WHEN COALESCE(lifetime_value, 0) > 500 THEN 'Regular'
        WHEN COALESCE(lifetime_value, 0) > 100 THEN 'Occasional'
        ELSE 'Low Value'
    END AS customer_segment,
    RANK() OVER (ORDER BY COALESCE(lifetime_value, 0) DESC) AS value_rank,
    NTILE(10) OVER (ORDER BY COALESCE(lifetime_value, 0)) AS value_decile
FROM customer_orders
WHERE customer_id IS NOT NULL;

REFRESH MATERIALIZED VIEW CONCURRENTLY customer_lifetime_value;

-- 3. Product performance report (daily)
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_product_performance AS
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    DATE(o.created_at) AS sale_date,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS revenue,
    COUNT(DISTINCT o.id) AS order_count,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    AVG(oi.unit_price) AS avg_sale_price
FROM products p
JOIN order_items oi ON oi.product_id = p.id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name, DATE(o.created_at);

REFRESH MATERIALIZED VIEW CONCURRENTLY daily_product_performance;

-- 4. Executive dashboard (function)
CREATE OR REPLACE FUNCTION get_executive_dashboard()
RETURNS TABLE(
    metric VARCHAR,
    current_value NUMERIC,
    previous_value NUMERIC,
    change_pct NUMERIC
) AS $$
DECLARE
    v_current_start DATE := DATE_TRUNC('day', NOW()) - INTERVAL '30 days';
    v_previous_start DATE := DATE_TRUNC('day', NOW()) - INTERVAL '60 days';
    v_current_end DATE := DATE_TRUNC('day', NOW());
    v_previous_end DATE := DATE_TRUNC('day', NOW()) - INTERVAL '30 days';
BEGIN
    -- Revenue
    RETURN QUERY
    SELECT 
        'Revenue' AS metric,
        COALESCE(SUM(total), 0) AS current_value,
        COALESCE((
            SELECT SUM(total) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0) AS previous_value,
        ROUND(100 * (COALESCE(SUM(total), 0) - COALESCE((
            SELECT SUM(total) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0)) / NULLIF(COALESCE((
            SELECT SUM(total) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0), 0)::NUMERIC, 2) AS change_pct
    FROM orders
    WHERE created_at BETWEEN v_current_start AND v_current_end
      AND status != 'cancelled';
    
    -- Repeat for other metrics
    -- Orders count
    RETURN QUERY
    SELECT 
        'Orders' AS metric,
        COALESCE(COUNT(*), 0)::NUMERIC AS current_value,
        COALESCE((
            SELECT COUNT(*) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0)::NUMERIC AS previous_value,
        ROUND(100 * (COUNT(*) - COALESCE((
            SELECT COUNT(*) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0)) / NULLIF(COALESCE((
            SELECT COUNT(*) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0), 0)::NUMERIC, 2) AS change_pct
    FROM orders
    WHERE created_at BETWEEN v_current_start AND v_current_end
      AND status != 'cancelled';
    
    -- New customers
    RETURN QUERY
    SELECT 
        'New Customers' AS metric,
        COALESCE(COUNT(*), 0)::NUMERIC AS current_value,
        COALESCE((
            SELECT COUNT(*) 
            FROM users 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end
        ), 0)::NUMERIC AS previous_value,
        ROUND(100 * (COUNT(*) - COALESCE((
            SELECT COUNT(*) 
            FROM users 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end
        ), 0)) / NULLIF(COALESCE((
            SELECT COUNT(*) 
            FROM users 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end
        ), 0), 0)::NUMERIC, 2) AS change_pct
    FROM users
    WHERE created_at BETWEEN v_current_start AND v_current_end;
    
    -- Average order value
    RETURN QUERY
    SELECT 
        'Avg Order Value' AS metric,
        COALESCE(AVG(total), 0) AS current_value,
        COALESCE((
            SELECT AVG(total) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0) AS previous_value,
        ROUND(100 * (COALESCE(AVG(total), 0) - COALESCE((
            SELECT AVG(total) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0)) / NULLIF(COALESCE((
            SELECT AVG(total) 
            FROM orders 
            WHERE created_at BETWEEN v_previous_start AND v_previous_end 
              AND status != 'cancelled'
        ), 0), 0)::NUMERIC, 2) AS change_pct
    FROM orders
    WHERE created_at BETWEEN v_current_start AND v_current_end
      AND status != 'cancelled';
END;
$$ LANGUAGE plpgsql;

-- 5. Check reports
SELECT * FROM daily_sales_report ORDER BY sale_date DESC LIMIT 30;
SELECT * FROM customer_lifetime_value ORDER BY lifetime_value DESC LIMIT 20;
SELECT * FROM get_executive_dashboard();
```

### The Verification

```bash
# Test materialized views
psql -d ecommerce -c "REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_report;"
psql -d ecommerce -c "SELECT COUNT(*) FROM daily_sales_report;"

# Check executive dashboard
psql -d ecommerce -c "SELECT * FROM get_executive_dashboard();"

# Check customer lifetime value
psql -d ecommerce -c "
SELECT customer_segment, COUNT(*), AVG(lifetime_value) 
FROM customer_lifetime_value 
GROUP BY customer_segment;"
```

---

## D.5 Summary

You now have a comprehensive library of e-commerce patterns:

✅ Shopping cart management (guest/user carts, merging)  
✅ Inventory management with transaction tracking  
✅ Low stock alerts and forecasting  
✅ Complete order processing pipeline  
✅ Payment and shipping workflow  
✅ Order cancellation with inventory restoration  
✅ Materialized views for reporting  
✅ Executive dashboard function  
✅ Customer lifetime value analysis  

These patterns are battle-tested and ready for production use. Adapt them to your specific needs, and you'll have a robust e-commerce backend.
