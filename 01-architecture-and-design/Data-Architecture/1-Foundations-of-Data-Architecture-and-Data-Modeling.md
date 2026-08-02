# Part 1: Foundations of Data Architecture and Data Modeling

Welcome to the first technical part of our series! In this module, we'll establish the fundamental principles that underpin every enterprise data platform. We'll explore the evolution of data architecture, distinguish between operational and analytical systems, master data modeling techniques, and implement our first production-ready data models.

## Learning Objectives

By the end of this part, you will be able to:

- Understand the evolution of enterprise data architecture
- Distinguish between operational (OLTP) and analytical (OLAP) systems
- Model data using Entity-Relationship Diagrams (ERD)
- Apply normalization and denormalization techniques
- Implement Master Data Management (MDM) patterns
- Design schemas that support evolution and versioning

---

## 1.1 Understanding Enterprise Data Architecture

### The Concept

Think of enterprise data architecture like the infrastructure of a modern city. Just as a city needs roads (data pipelines), buildings (databases), traffic lights (orchestration), and zoning laws (governance), a data architecture provides the foundation for information to flow, be stored, and be consumed throughout an organization.

**Evolution of Data Architecture:**

```
1970s-1980s: Centralized Mainframe
    └── Single database serving all needs
    └── Monolithic applications

1990s-2000s: Client-Server & Data Warehousing
    └── Operational databases + separate data warehouse
    └── ETL (Extract, Transform, Load) processes

2010s: Big Data & Cloud
    └── Hadoop ecosystem + cloud storage
    └── Data lakes for raw data storage

2020s: Modern Data Stack
    └── Lakehouse architecture (best of both worlds)
    └── Real-time streaming + batch processing
    └── Data mesh & domain-oriented ownership
```

### Operational vs. Analytical Systems

Understanding the distinction between these two types of systems is crucial:

| Aspect | Operational Systems (OLTP) | Analytical Systems (OLAP) |
|--------|---------------------------|---------------------------|
| **Purpose** | Run day-to-day operations | Support business decisions |
| **Users** | Employees, customers | Analysts, executives |
| **Workload** | Many small transactions | Few large, complex queries |
| **Data Model** | Normalized (3NF) | Denormalized (Star/Snowflake) |
| **Latency** | Milliseconds | Seconds to minutes |
| **History** | Current state | Historical trends |
| **Example** | E-commerce checkout | Monthly sales report |

### Data Types and Structures

Modern data platforms handle three primary data types:

1. **Structured Data** - Highly organized with fixed schema
   - Example: Relational databases, CSV files
   - Storage: Tables with rows and columns

2. **Semi-Structured Data** - Some organizational properties but flexible
   - Example: JSON, XML, Avro
   - Storage: Documents with optional fields

3. **Unstructured Data** - No predefined structure
   - Example: Images, videos, text documents
   - Storage: Blobs, objects

---

## 1.2 Data Modeling Fundamentals

### The Concept

Data modeling is like creating architectural blueprints for your data. Just as an architect creates plans showing how a building will be constructed, data modeling defines how data will be structured, stored, and related. A good data model ensures your data is accurate, consistent, and easy to query.

### Entity-Relationship Modeling (ERD)

Let's implement a practical example using PostgreSQL to demonstrate these concepts.

### The Target
Create a complete data model for an e-commerce system with customers, products, orders, and inventory.

### The Concept
We'll build a database schema that:
- Captures all necessary entities and relationships
- Follows normalization principles
- Supports both operational and analytical use cases
- Includes proper constraints and indexes

### The Implementation

**File: `part-01-foundations/docker-compose.yml`**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: dataarch_postgres
    environment:
      POSTGRES_USER: dataarch
      POSTGRES_PASSWORD: dataarch123
      POSTGRES_DB: ecommerce
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dataarch"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: dataarch_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@dataarch.com
      PGADMIN_DEFAULT_PASSWORD: admin123
    ports:
      - "5050:80"
    depends_on:
      - postgres
    volumes:
      - pgadmin_data:/var/lib/pgadmin

volumes:
  postgres_data:
  pgadmin_data:
```

**File: `part-01-foundations/sql/01-schema.sql`**
```sql
-- ============================================
-- E-COMMERCE DATA MODEL
-- Complete schema with normalization and constraints
-- ============================================

-- Enable extensions for additional data types
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. CUSTOMER MANAGEMENT
-- ============================================

-- Customer table - central entity for all customer data
-- Following 3NF normalization: atomic values, no transitive dependencies
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    -- Store encrypted sensitive data
    password_hash BYTEA NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    -- Audit fields
    created_by VARCHAR(100),
    modified_by VARCHAR(100),
    
    -- Constraints
    CONSTRAINT email_valid CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT phone_format CHECK (phone IS NULL OR phone ~ '^\+?[1-9]\d{1,14}$')
);

-- Address table - normalized (customers can have multiple addresses)
CREATE TABLE customer_addresses (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('billing', 'shipping', 'both')),
    street_address1 VARCHAR(255) NOT NULL,
    street_address2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key with cascade delete for clean customer removal
    CONSTRAINT fk_customer_address 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE CASCADE
);

-- Create index for frequent lookups
CREATE INDEX idx_customer_addresses_customer_id ON customer_addresses(customer_id);

-- ============================================
-- 2. PRODUCT MANAGEMENT
-- ============================================

-- Product categories - hierarchical structure
CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_category_id UUID,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    slug VARCHAR(120) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Self-referencing foreign key for hierarchy
    CONSTRAINT fk_category_parent 
        FOREIGN KEY (parent_category_id) 
        REFERENCES categories(category_id)
);

-- Products table - core product information
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    weight_grams INTEGER,
    dimensions VARCHAR(100), -- e.g., "30x20x10"
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    modified_by VARCHAR(100),
    
    -- Foreign key with RESTRICT to prevent orphaned categories
    CONSTRAINT fk_product_category 
        FOREIGN KEY (category_id) 
        REFERENCES categories(category_id)
        ON DELETE RESTRICT
);

-- Product attributes - flexible key-value storage for varying product types
CREATE TABLE product_attributes (
    attribute_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value TEXT,
    attribute_type VARCHAR(50) CHECK (attribute_type IN ('text', 'number', 'boolean', 'date')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_product_attribute 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE CASCADE,
    -- Each product can have each attribute only once
    UNIQUE(product_id, attribute_name)
);

-- Product images - one-to-many relationship
CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_product_image 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE CASCADE
);

-- Create indexes for product queries
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name ON products(name);

-- ============================================
-- 3. INVENTORY MANAGEMENT
-- ============================================

-- Warehouses table
CREATE TABLE warehouses (
    warehouse_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_name VARCHAR(100) NOT NULL,
    address_street VARCHAR(255) NOT NULL,
    address_city VARCHAR(100) NOT NULL,
    address_state VARCHAR(50),
    address_postal VARCHAR(20) NOT NULL,
    address_country VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Inventory - tracks stock levels per product per warehouse
CREATE TABLE inventory (
    inventory_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL,
    warehouse_id UUID NOT NULL,
    quantity_on_hand INTEGER DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_reserved INTEGER DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_available INTEGER GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    reorder_level INTEGER DEFAULT 0 CHECK (reorder_level >= 0),
    reorder_quantity INTEGER DEFAULT 0 CHECK (reorder_quantity >= 0),
    last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(100),
    
    CONSTRAINT fk_inventory_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_warehouse 
        FOREIGN KEY (warehouse_id) 
        REFERENCES warehouses(warehouse_id) 
        ON DELETE RESTRICT,
    -- Each product can only have one inventory record per warehouse
    UNIQUE(product_id, warehouse_id)
);

-- Create index for inventory lookups
CREATE INDEX idx_inventory_product_id ON inventory(product_id);
CREATE INDEX idx_inventory_warehouse_id ON inventory(warehouse_id);

-- ============================================
-- 4. ORDER MANAGEMENT
-- ============================================

-- Orders table - main order header
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL CHECK (status IN (
        'pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded'
    )),
    -- Billing and shipping references
    billing_address_id UUID NOT NULL,
    shipping_address_id UUID NOT NULL,
    -- Payment information (denormalized for historical accuracy)
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),
    -- Order totals (denormalized to maintain historical snapshot)
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10, 2) NOT NULL CHECK (tax_amount >= 0),
    shipping_amount DECIMAL(10, 2) NOT NULL CHECK (shipping_amount >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0 CHECK (discount_amount >= 0),
    total_amount DECIMAL(10, 2) GENERATED ALWAYS AS (
        subtotal + tax_amount + shipping_amount - discount_amount
    ) STORED,
    -- Shipping tracking
    tracking_number VARCHAR(100),
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    -- Metadata
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_order_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_billing_address 
        FOREIGN KEY (billing_address_id) 
        REFERENCES customer_addresses(address_id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_shipping_address 
        FOREIGN KEY (shipping_address_id) 
        REFERENCES customer_addresses(address_id) 
        ON DELETE RESTRICT
);

-- Order items - line items for each order (denormalized product snapshot)
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    -- Denormalized fields to preserve historical accuracy
    product_sku VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit_price_at_time DECIMAL(10, 2) NOT NULL CHECK (unit_price_at_time >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    discount_percent DECIMAL(5, 2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    line_total DECIMAL(10, 2) GENERATED ALWAYS AS (
        unit_price_at_time * quantity * (1 - discount_percent/100)
    ) STORED,
    
    CONSTRAINT fk_order_item_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT
);

-- Order status history - track state changes
CREATE TABLE order_status_history (
    status_history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),
    
    CONSTRAINT fk_status_history_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE
);

-- Create indexes for order queries
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- ============================================
-- 5. REVIEW AND RATING SYSTEM
-- ============================================

CREATE TABLE product_reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    order_id UUID NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_votes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT fk_review_product 
        FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_review_customer 
        FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_review_order 
        FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE,
    -- One review per product per customer per order
    UNIQUE(product_id, customer_id, order_id)
);

CREATE INDEX idx_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON product_reviews(customer_id);
CREATE INDEX idx_reviews_rating ON product_reviews(rating);

-- ============================================
-- 6. AUDIT AND MASTER DATA MANAGEMENT
-- ============================================

-- Master Data Management - Reference data tables

-- Payment method reference data
CREATE TABLE payment_methods (
    payment_method_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    method_code VARCHAR(50) UNIQUE NOT NULL,
    method_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Shipping carriers reference data
CREATE TABLE shipping_carriers (
    carrier_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    carrier_code VARCHAR(50) UNIQUE NOT NULL,
    carrier_name VARCHAR(100) NOT NULL,
    tracking_url_template VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Currency reference data
CREATE TABLE currencies (
    currency_code CHAR(3) PRIMARY KEY,
    currency_name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10),
    decimal_places INTEGER DEFAULT 2,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 7. TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================

-- Trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_customers_updated_at 
    BEFORE UPDATE ON customers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at 
    BEFORE UPDATE ON products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 8. INITIAL REFERENCE DATA
-- ============================================

-- Insert currency data
INSERT INTO currencies (currency_code, currency_name, symbol) VALUES
    ('USD', 'US Dollar', '$'),
    ('EUR', 'Euro', '€'),
    ('GBP', 'British Pound', '£'),
    ('JPY', 'Japanese Yen', '¥'),
    ('CAD', 'Canadian Dollar', 'C$');

-- Insert payment methods
INSERT INTO payment_methods (method_code, method_name, description) VALUES
    ('CREDIT_CARD', 'Credit Card', 'Visa, MasterCard, Amex'),
    ('PAYPAL', 'PayPal', 'PayPal online payment'),
    ('BANK_TRANSFER', 'Bank Transfer', 'Direct bank transfer'),
    ('CRYPTO', 'Cryptocurrency', 'Bitcoin, Ethereum');

-- Insert shipping carriers
INSERT INTO shipping_carriers (carrier_code, carrier_name, tracking_url_template) VALUES
    ('UPS', 'UPS', 'https://www.ups.com/track?tracknum={tracking}'),
    ('FEDEX', 'FedEx', 'https://www.fedex.com/fedextrack?trknbr={tracking}'),
    ('USPS', 'USPS', 'https://tools.usps.com/go/TrackConfirmAction?tRef={tracking}'),
    ('DHL', 'DHL Express', 'https://www.dhl.com/en/express/tracking.html?AWB={tracking}');
```

**File: `part-01-foundations/sql/02-sample-data.sql`**
```sql
-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert categories
INSERT INTO categories (category_id, category_name, description, slug) VALUES
    (gen_random_uuid(), 'Electronics', 'Electronic devices and accessories', 'electronics'),
    (gen_random_uuid(), 'Clothing', 'Apparel and fashion items', 'clothing'),
    (gen_random_uuid(), 'Books', 'Books and publications', 'books'),
    (gen_random_uuid(), 'Home & Garden', 'Home improvement and garden supplies', 'home-garden');

-- Insert subcategories
INSERT INTO categories (category_id, parent_category_id, category_name, description, slug) VALUES
    (gen_random_uuid(), (SELECT category_id FROM categories WHERE slug = 'electronics'), 'Laptops', 'Portable computers', 'laptops'),
    (gen_random_uuid(), (SELECT category_id FROM categories WHERE slug = 'electronics'), 'Smartphones', 'Mobile phones', 'smartphones'),
    (gen_random_uuid(), (SELECT category_id FROM categories WHERE slug = 'clothing'), 'Men''s Clothing', 'Clothing for men', 'mens-clothing'),
    (gen_random_uuid(), (SELECT category_id FROM categories WHERE slug = 'clothing'), 'Women''s Clothing', 'Clothing for women', 'womens-clothing');

-- Insert products
INSERT INTO products (sku, name, description, category_id, unit_price, cost, weight_grams) VALUES
    ('LAPTOP-001', 'Dell XPS 15', 'High-performance laptop with 4K display', 
        (SELECT category_id FROM categories WHERE slug = 'laptops'), 1899.99, 1500.00, 2000),
    ('LAPTOP-002', 'MacBook Pro 14', 'Apple MacBook Pro with M2 chip',
        (SELECT category_id FROM categories WHERE slug = 'laptops'), 1999.99, 1600.00, 1600),
    ('PHONE-001', 'iPhone 15 Pro', 'Apple iPhone 15 Pro with titanium frame',
        (SELECT category_id FROM categories WHERE slug = 'smartphones'), 1099.99, 800.00, 187),
    ('PHONE-002', 'Samsung Galaxy S24', 'Samsung Galaxy with AI features',
        (SELECT category_id FROM categories WHERE slug = 'smartphones'), 999.99, 750.00, 167);

-- Insert sample customers
INSERT INTO customers (email, first_name, last_name, phone, password_hash) VALUES
    ('john.doe@example.com', 'John', 'Doe', '+1234567890', crypt('password123', gen_salt('bf'))),
    ('jane.smith@example.com', 'Jane', 'Smith', '+1987654321', crypt('password123', gen_salt('bf'))),
    ('bob.wilson@example.com', 'Bob', 'Wilson', '+1122334455', crypt('password123', gen_salt('bf')));

-- Insert addresses
INSERT INTO customer_addresses (customer_id, address_type, street_address1, city, state, postal_code, country, is_default) VALUES
    ((SELECT customer_id FROM customers WHERE email = 'john.doe@example.com'), 'both', '123 Main St', 'New York', 'NY', '10001', 'USA', TRUE),
    ((SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), 'billing', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA', TRUE),
    ((SELECT customer_id FROM customers WHERE email = 'jane.smith@example.com'), 'shipping', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 'USA', FALSE);

-- Insert warehouses
INSERT INTO warehouses (warehouse_name, address_street, address_city, address_state, address_postal, address_country) VALUES
    ('NYC Warehouse', '123 Storage Blvd', 'New York', 'NY', '10002', 'USA'),
    ('LA Warehouse', '456 Distribution Way', 'Los Angeles', 'CA', '90002', 'USA');

-- Insert inventory
INSERT INTO inventory (product_id, warehouse_id, quantity_on_hand, reorder_level, reorder_quantity) VALUES
    ((SELECT product_id FROM products WHERE sku = 'LAPTOP-001'), 
        (SELECT warehouse_id FROM warehouses WHERE warehouse_name = 'NYC Warehouse'), 10, 3, 10),
    ((SELECT product_id FROM products WHERE sku = 'LAPTOP-002'), 
        (SELECT warehouse_id FROM warehouses WHERE warehouse_name = 'LA Warehouse'), 5, 2, 5),
    ((SELECT product_id FROM products WHERE sku = 'PHONE-001'), 
        (SELECT warehouse_id FROM warehouses WHERE warehouse_name = 'NYC Warehouse'), 25, 10, 20),
    ((SELECT product_id FROM products WHERE sku = 'PHONE-002'), 
        (SELECT warehouse_id FROM warehouses WHERE warehouse_name = 'LA Warehouse'), 15, 5, 15);
```

**File: `part-01-foundations/sql/03-analytical-views.sql`**
```sql
-- ============================================
-- ANALYTICAL VIEWS FOR BUSINESS INTELLIGENCE
-- ============================================

-- View: Customer order summary with lifetime value
CREATE OR REPLACE VIEW customer_analytics AS
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) as order_count,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    MIN(o.order_date) as first_order_date,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - MAX(o.order_date))) as days_since_last_order,
    -- Customer segment based on total spending
    CASE 
        WHEN COALESCE(SUM(o.total_amount), 0) > 5000 THEN 'High Value'
        WHEN COALESCE(SUM(o.total_amount), 0) > 1000 THEN 'Medium Value'
        WHEN COALESCE(SUM(o.total_amount), 0) > 0 THEN 'Low Value'
        ELSE 'New'
    END as customer_segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
    AND o.status IN ('delivered', 'shipped')  -- Only completed orders
GROUP BY c.customer_id, c.email, c.first_name, c.last_name;

-- View: Product performance analytics
CREATE OR REPLACE VIEW product_analytics AS
SELECT 
    p.product_id,
    p.sku,
    p.name,
    c.category_name,
    COUNT(DISTINCT oi.order_id) as order_count,
    SUM(oi.quantity) as total_quantity_sold,
    COALESCE(SUM(oi.line_total), 0) as total_revenue,
    AVG(oi.unit_price_at_time) as avg_selling_price,
    -- Current inventory status
    COALESCE(SUM(inv.quantity_on_hand), 0) as total_inventory_on_hand,
    -- Review metrics
    COALESCE(AVG(pr.rating), 0) as avg_rating,
    COUNT(DISTINCT pr.review_id) as review_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.status IN ('delivered', 'shipped')
LEFT JOIN inventory inv ON p.product_id = inv.product_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
    AND pr.is_approved = TRUE
GROUP BY p.product_id, p.sku, p.name, c.category_name;

-- View: Sales trends by month
CREATE OR REPLACE VIEW monthly_sales_trend AS
SELECT 
    DATE_TRUNC('month', o.order_date) as month,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_units_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('delivered', 'shipped')
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month DESC;

-- View: Inventory aging and turnover
CREATE OR REPLACE VIEW inventory_analytics AS
SELECT 
    p.product_id,
    p.sku,
    p.name,
    w.warehouse_name,
    inv.quantity_on_hand,
    inv.quantity_reserved,
    inv.quantity_available,
    inv.reorder_level,
    -- Turnover calculation (if we had sales history)
    CASE 
        WHEN inv.quantity_on_hand > 0 AND inv.quantity_on_hand - inv.reorder_level < 0 
        THEN 'Reorder Required'
        WHEN inv.quantity_on_hand > 0 THEN 'In Stock'
        ELSE 'Out of Stock'
    END as stock_status
FROM inventory inv
JOIN products p ON inv.product_id = p.product_id
JOIN warehouses w ON inv.warehouse_id = w.warehouse_id;
```

**File: `part-01-foundations/sql/04-master-data-management.sql`**
```sql
-- ============================================
-- MASTER DATA MANAGEMENT (MDM) PATTERNS
-- ============================================

-- ============================================
-- 1. GOLDEN RECORD - Customer Master
-- ============================================

-- Customer master table (golden record)
-- Consolidates data from multiple sources
CREATE TABLE customer_master (
    master_customer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    global_customer_id VARCHAR(100) UNIQUE NOT NULL,
    -- Primary identity attributes
    primary_email VARCHAR(255) NOT NULL,
    primary_phone VARCHAR(20),
    legal_name VARCHAR(255) NOT NULL,
    -- Additional attributes
    date_of_birth DATE,
    tax_id VARCHAR(50),
    -- Trust and quality metrics
    data_quality_score DECIMAL(5, 2) DEFAULT 0 CHECK (data_quality_score >= 0 AND data_quality_score <= 100),
    record_confidence DECIMAL(5, 2) DEFAULT 0 CHECK (record_confidence >= 0 AND record_confidence <= 100),
    -- Source system tracking
    source_system VARCHAR(100) NOT NULL,
    source_record_id VARCHAR(255),
    -- Status
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'merged', 'inactive', 'pending')),
    -- Hierarchy and relationships
    parent_master_customer_id UUID REFERENCES customer_master(master_customer_id),
    -- Audit
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_synced_at TIMESTAMP WITH TIME ZONE
);

-- Customer aliases - alternate identifiers
CREATE TABLE customer_aliases (
    alias_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    master_customer_id UUID NOT NULL,
    alias_type VARCHAR(50) CHECK (alias_type IN ('email', 'phone', 'username', 'external_id')),
    alias_value VARCHAR(255) NOT NULL,
    source_system VARCHAR(100),
    confidence_score DECIMAL(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_alias_master_customer 
        FOREIGN KEY (master_customer_id) 
        REFERENCES customer_master(master_customer_id)
        ON DELETE CASCADE,
    UNIQUE(alias_type, alias_value)
);

-- ============================================
-- 2. REFERENCE DATA MANAGEMENT
-- ============================================

-- Reference data catalog
CREATE TABLE reference_data_catalog (
    ref_catalog_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    domain VARCHAR(100) NOT NULL,
    code VARCHAR(100) NOT NULL,
    value VARCHAR(255) NOT NULL,
    description TEXT,
    display_order INTEGER,
    parent_code VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    effective_start_date DATE,
    effective_end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Audit fields
    created_by VARCHAR(100),
    modified_by VARCHAR(100),
    
    UNIQUE(domain, code)
);

-- Insert reference data examples
INSERT INTO reference_data_catalog (domain, code, value, description, display_order) VALUES
    ('ORDER_STATUS', 'PENDING', 'Pending', 'Order received but not processed', 1),
    ('ORDER_STATUS', 'PROCESSING', 'Processing', 'Order is being processed', 2),
    ('ORDER_STATUS', 'SHIPPED', 'Shipped', 'Order has been shipped', 3),
    ('ORDER_STATUS', 'DELIVERED', 'Delivered', 'Order delivered to customer', 4),
    ('ORDER_STATUS', 'CANCELLED', 'Cancelled', 'Order was cancelled', 5),
    ('ORDER_STATUS', 'REFUNDED', 'Refunded', 'Order was refunded', 6),
    ('PRODUCT_TYPE', 'PHYSICAL', 'Physical Product', 'Tangible product requiring shipping', 1),
    ('PRODUCT_TYPE', 'DIGITAL', 'Digital Product', 'Downloadable or digital product', 2),
    ('PRODUCT_TYPE', 'SERVICE', 'Service', 'Service-based offering', 3);

-- ============================================
-- 3. DATA QUALITY RULES
-- ============================================

-- Data quality rule definitions
CREATE TABLE data_quality_rules (
    rule_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_name VARCHAR(255) NOT NULL UNIQUE,
    rule_type VARCHAR(50) CHECK (rule_type IN ('completeness', 'validity', 'consistency', 'uniqueness', 'timeliness')),
    table_name VARCHAR(100) NOT NULL,
    column_name VARCHAR(100),
    rule_expression TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'warning' CHECK (severity IN ('info', 'warning', 'error', 'critical')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100)
);

-- Example quality rules
INSERT INTO data_quality_rules (rule_name, rule_type, table_name, column_name, rule_expression, severity) VALUES
    ('Customer email complete', 'completeness', 'customers', 'email', 'email IS NOT NULL AND email != ''', 'error'),
    ('Customer phone valid', 'validity', 'customers', 'phone', 'phone IS NULL OR phone ~ ''^\+?[1-9]\d{1,14}$''', 'warning'),
    ('Product price positive', 'validity', 'products', 'unit_price', 'unit_price >= 0', 'error'),
    ('Order total matches sum', 'consistency', 'orders', 'total_amount', 'total_amount = subtotal + tax_amount + shipping_amount - discount_amount', 'error');

-- Data quality results tracking
CREATE TABLE data_quality_results (
    result_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rule_id UUID NOT NULL,
    check_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_records INTEGER,
    records_passed INTEGER,
    records_failed INTEGER,
    success_percentage DECIMAL(5, 2),
    execution_time_ms INTEGER,
    error_details JSONB,
    
    CONSTRAINT fk_quality_rule 
        FOREIGN KEY (rule_id) 
        REFERENCES data_quality_rules(rule_id)
);

-- ============================================
-- 4. SCHEMA EVOLUTION AND VERSIONING
-- ============================================

-- Schema version tracking
CREATE TABLE schema_versions (
    version_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    version_number INTEGER UNIQUE NOT NULL,
    version_name VARCHAR(255),
    description TEXT,
    migration_script TEXT,
    applied_by VARCHAR(100),
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    rollback_script TEXT,
    is_current BOOLEAN DEFAULT FALSE
);

-- Data contract registry
CREATE TABLE data_contracts (
    contract_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_name VARCHAR(255) NOT NULL UNIQUE,
    version VARCHAR(50) NOT NULL,
    service_provider VARCHAR(255) NOT NULL,
    service_consumer VARCHAR(255) NOT NULL,
    schema_definition JSONB NOT NULL,
    compatibility_mode VARCHAR(50) DEFAULT 'forward' CHECK (compatibility_mode IN ('forward', 'backward', 'full', 'none')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('draft', 'active', 'deprecated', 'archived'))
);
```

**File: `part-01-foundations/scripts/verify_setup.py`**
```python
#!/usr/bin/env python3
"""
Verification script for Part 1 setup.
Tests database connection and validates the schema.
"""

import os
import sys
import json
import psycopg2
from psycopg2 import sql, extras
from datetime import datetime
from typing import Dict, Any, List, Tuple

# Configuration from environment
DB_CONFIG = {
    'dbname': os.getenv('POSTGRES_DB', 'ecommerce'),
    'user': os.getenv('POSTGRES_USER', 'dataarch'),
    'password': os.getenv('POSTGRES_PASSWORD', 'dataarch123'),
    'host': os.getenv('POSTGRES_HOST', 'localhost'),
    'port': os.getenv('POSTGRES_PORT', '5432')
}

class DatabaseVerifier:
    """Verify database schema and data quality"""
    
    def __init__(self, config: Dict[str, str]):
        self.config = config
        self.connection = None
        self.cursor = None
        self.results = {
            'passed': True,
            'checks': [],
            'errors': [],
            'warnings': []
        }
    
    def connect(self) -> bool:
        """Establish database connection"""
        try:
            self.connection = psycopg2.connect(**self.config)
            self.cursor = self.connection.cursor(cursor_factory=extras.RealDictCursor)
            print("✅ Database connection successful")
            return True
        except Exception as e:
            print(f"❌ Database connection failed: {e}")
            self.results['passed'] = False
            return False
    
    def check_tables_exist(self) -> bool:
        """Verify all required tables exist"""
        required_tables = [
            'customers', 'customer_addresses', 'categories', 'products',
            'product_attributes', 'product_images', 'warehouses', 'inventory',
            'orders', 'order_items', 'order_status_history', 'product_reviews',
            'payment_methods', 'shipping_carriers', 'currencies'
        ]
        
        print("\n📋 Checking required tables...")
        
        query = """
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """
        self.cursor.execute(query)
        existing_tables = [row['table_name'] for row in self.cursor.fetchall()]
        
        missing = [t for t in required_tables if t not in existing_tables]
        
        if missing:
            print(f"❌ Missing tables: {', '.join(missing)}")
            self.results['errors'].append(f"Missing tables: {', '.join(missing)}")
            self.results['passed'] = False
            return False
        else:
            print(f"✅ All {len(required_tables)} required tables exist")
            return True
    
    def check_foreign_keys(self) -> bool:
        """Verify foreign key constraints"""
        print("\n🔗 Checking foreign key constraints...")
        
        # Get all foreign keys for our tables
        query = """
            SELECT
                tc.table_name,
                kcu.column_name,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
                ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage ccu
                ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
                AND tc.table_schema = 'public'
        """
        self.cursor.execute(query)
        fks = self.cursor.fetchall()
        
        if len(fks) > 0:
            print(f"✅ Found {len(fks)} foreign key constraints")
            for fk in fks[:5]:  # Show first 5 as example
                print(f"   - {fk['table_name']}.{fk['column_name']} -> {fk['foreign_table_name']}.{fk['foreign_column_name']}")
            return True
        else:
            print("⚠️ No foreign keys found (should have several)")
            self.results['warnings'].append("No foreign keys detected")
            return True  # Not fatal
    
    def check_views(self) -> bool:
        """Verify analytical views exist"""
        print("\n📊 Checking analytical views...")
        
        expected_views = ['customer_analytics', 'product_analytics', 'monthly_sales_trend', 'inventory_analytics']
        
        query = """
            SELECT table_name 
            FROM information_schema.views 
            WHERE table_schema = 'public'
        """
        self.cursor.execute(query)
        existing_views = [row['table_name'] for row in self.cursor.fetchall()]
        
        missing = [v for v in expected_views if v not in existing_views]
        
        if missing:
            print(f"⚠️ Missing views: {', '.join(missing)}")
            self.results['warnings'].append(f"Missing views: {', '.join(missing)}")
            return True  # Views are optional for core schema
        else:
            print(f"✅ All {len(expected_views)} analytical views exist")
            return True
    
    def check_sample_data(self) -> bool:
        """Verify sample data was inserted"""
        print("\n📦 Checking sample data...")
        
        checks = [
            ('customers', 3, "at least 3 customers"),
            ('categories', 6, "at least 6 categories"),
            ('products', 4, "at least 4 products"),
            ('warehouses', 2, "at least 2 warehouses"),
            ('inventory', 4, "at least 4 inventory records")
        ]
        
        all_passed = True
        for table, min_count, description in checks:
            query = sql.SQL("SELECT COUNT(*) as count FROM {}").format(sql.Identifier(table))
            self.cursor.execute(query)
            count = self.cursor.fetchone()['count']
            
            if count >= min_count:
                print(f"   ✅ {table}: {count} rows ({description})")
            else:
                print(f"   ⚠️ {table}: {count} rows (expected {description})")
                self.results['warnings'].append(f"Low data count in {table}: {count}")
                all_passed = False
        
        return all_passed
    
    def test_analytical_queries(self) -> bool:
        """Test the analytical views with sample queries"""
        print("\n🔍 Testing analytical queries...")
        
        try:
            # Test customer analytics view
            self.cursor.execute("SELECT * FROM customer_analytics LIMIT 1")
            result = self.cursor.fetchone()
            if result:
                print(f"   ✅ Customer analytics: found data")
                print(f"      Example: {result['email']} - {result['customer_segment']}")
            else:
                print("   ⚠️ Customer analytics: no data (expected with sample data)")
            
            # Test product analytics view
            self.cursor.execute("SELECT * FROM product_analytics LIMIT 1")
            result = self.cursor.fetchone()
            if result:
                print(f"   ✅ Product analytics: found data")
                print(f"      Example: {result['sku']} - ${result['avg_selling_price']}")
            else:
                print("   ⚠️ Product analytics: no data (expected with sample data)")
            
            return True
        except Exception as e:
            print(f"   ❌ Analytical query failed: {e}")
            self.results['errors'].append(f"Analytical query test failed: {str(e)[:100]}")
            self.results['passed'] = False
            return False
    
    def verify_reference_data(self) -> bool:
        """Verify reference data was inserted correctly"""
        print("\n📚 Checking reference data...")
        
        # Check reference data catalog
        self.cursor.execute("SELECT COUNT(*) as count FROM reference_data_catalog")
        count = self.cursor.fetchone()['count']
        
        if count > 0:
            print(f"   ✅ Reference data catalog: {count} records")
            
            # Check specific domains
            self.cursor.execute("""
                SELECT domain, COUNT(*) as count 
                FROM reference_data_catalog 
                GROUP BY domain
            """)
            domains = self.cursor.fetchall()
            for domain in domains:
                print(f"      - {domain['domain']}: {domain['count']} records")
            return True
        else:
            print("   ⚠️ No reference data found")
            self.results['warnings'].append("Reference data catalog empty")
            return True
    
    def verify_data_quality(self) -> bool:
        """Check data quality rules and results"""
        print("\n📈 Checking data quality framework...")
        
        # Check rules exist
        self.cursor.execute("SELECT COUNT(*) as count FROM data_quality_rules")
        rule_count = self.cursor.fetchone()['count']
        
        if rule_count > 0:
            print(f"   ✅ Data quality rules: {rule_count} defined")
            
            # Show rule types distribution
            self.cursor.execute("""
                SELECT rule_type, COUNT(*) as count 
                FROM data_quality_rules 
                GROUP BY rule_type
            """)
            rule_types = self.cursor.fetchall()
            for rt in rule_types:
                print(f"      - {rt['rule_type']}: {rt['count']} rules")
        else:
            print("   ⚠️ No data quality rules defined")
        
        return True
    
    def print_results(self):
        """Print verification summary"""
        print("\n" + "="*60)
        print("VERIFICATION SUMMARY")
        print("="*60)
        
        if self.results['passed']:
            print("✅ OVERALL STATUS: PASSED")
        else:
            print("❌ OVERALL STATUS: FAILED")
        
        if self.results['errors']:
            print(f"\n❌ Errors ({len(self.results['errors'])}):")
            for error in self.results['errors']:
                print(f"   - {error}")
        
        if self.results['warnings']:
            print(f"\n⚠️ Warnings ({len(self.results['warnings'])}):")
            for warning in self.results['warnings'][:5]:
                print(f"   - {warning}")
            if len(self.results['warnings']) > 5:
                print(f"   ... and {len(self.results['warnings']) - 5} more")
        
        print("\n" + "="*60)
        
        if self.results['passed']:
            print("🎉 Part 1 setup is ready! You can proceed to the next section.")
        else:
            print("⚠️ Some checks failed. Please review the errors and try again.")
    
    def run_all_checks(self) -> bool:
        """Run all verification checks"""
        if not self.connect():
            return False
        
        try:
            self.check_tables_exist()
            self.check_foreign_keys()
            self.check_views()
            self.check_sample_data()
            self.test_analytical_queries()
            self.verify_reference_data()
            self.verify_data_quality()
        except Exception as e:
            print(f"\n❌ Unexpected error during verification: {e}")
            import traceback
            traceback.print_exc()
            self.results['passed'] = False
        finally:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
        
        self.print_results()
        return self.results['passed']

def main():
    """Main entry point"""
    print("="*60)
    print("PART 1: FOUNDATIONS VERIFICATION")
    print("="*60)
    print(f"Database: {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}")
    print()
    
    verifier = DatabaseVerifier(DB_CONFIG)
    success = verifier.run_all_checks()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

**File: `part-01-foundations/requirements.txt`**
```txt
psycopg2-binary==2.9.9
python-dotenv==1.0.0
```

**File: `part-01-foundations/.env.example`**
```bash
# Database Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=ecommerce
POSTGRES_USER=dataarch
POSTGRES_PASSWORD=dataarch123

# Application Configuration
LOG_LEVEL=INFO
ENVIRONMENT=development
```

### The Verification

Now let's verify our setup is working correctly:

```bash
# Navigate to the part directory
cd part-01-foundations

# Start the database containers
docker-compose up -d

# Wait for the database to be ready (about 30 seconds)
docker-compose logs postgres --tail 10

# Verify the schema was created correctly
docker-compose exec postgres psql -U dataarch -d ecommerce -c "\dt"

# You should see a list of tables including:
# - customers
# - products  
# - orders
# - categories
# - warehouses

# Run the verification script
pip install -r requirements.txt
python scripts/verify_setup.py

# You should see output like:
# ✅ Database connection successful
# ✅ All required tables exist
# ✅ Found 15+ foreign key constraints
# ✅ All analytical views exist
# ✅ Sample data inserted successfully
# ✅ OVERALL STATUS: PASSED

# Test a query manually
docker-compose exec postgres psql -U dataarch -d ecommerce -c "
SELECT 
    c.email, 
    COUNT(o.order_id) as order_count,
    COALESCE(SUM(o.total_amount), 0) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.email;
"
```

**Expected Output:**
```
     email      | order_count | total_spent 
----------------+-------------+-------------
 john.doe@...   |           0 |        0.00
 jane.smith@... |           0 |        0.00
 bob.wilson@... |           0 |        0.00
(3 rows)
```

## Key Concepts Explained

### Normalization vs. Denormalization

**Normalization** is like organizing a library by using a card catalog system:
- Books (products) are stored separately from borrower records (customers)
- Each piece of information is stored in exactly one place
- Reduces data duplication but may require joins for queries

**Denormalization** is like keeping a personal copy of each book's location:
- Data is duplicated for faster access
- Trade-off: storage space vs. query performance
- Common in analytics systems (OLAP)

### Master Data Management (MDM)

Think of MDM like a global address book for an organization:
- Single source of truth for critical business entities (customers, products, locations)
- Consolidates data from multiple systems
- Provides a "golden record" for each entity
- Ensures consistency across the enterprise

### Schema Evolution

Your data model will change over time. The schema versioning table we created allows you to:
- Track what changed and when
- Roll back if needed
- Maintain compatibility between versions
- Manage migrations systematically

---

## Part 1 Recap

You have successfully:

✅ Built a complete e-commerce data model with 15+ tables  
✅ Implemented entity-relationship modeling with proper constraints  
✅ Applied normalization principles (3NF)  
✅ Created analytical views for business intelligence  
✅ Established master data management patterns  
✅ Implemented data quality rules and reference data management  
✅ Set up schema versioning and data contracts  
✅ Verified the entire setup with automated tests  
