# Part 5: Modern Postgres Power Tools (JSONB & Window Functions)

You've mastered traditional SQL. Now it's time to unlock PostgreSQL's modern superpowers. We'll explore JSONB for flexible, document-like data storage, and window functions for sophisticated analytics without losing detail. Think of JSONB as giving your relational database NoSQL capabilities, and window functions as allowing you to look at data through a moving window.

## Phase 5.1: Understanding JSONB

### The Target
Learn JSONB fundamentals for storing and querying semi-structured data.

### The Concept
JSONB (JSON Binary) stores data as JSON but in a binary format that's faster to query and index. Think of it as having a mini-document database inside your relational database. You can store flexible, unstructured data while still being able to query, filter, and index it efficiently.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Add product metadata JSONB column for flexible product attributes
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Add product variants (different sizes, colors, etc.)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS variants JSONB DEFAULT '[]'::jsonb;

-- Update products with rich metadata
UPDATE products 
SET metadata = jsonb_set(
    COALESCE(metadata, '{}'::jsonb),
    '{brand}',
    CASE 
        WHEN name ILIKE '%headphone%' THEN '"AudioTech"'::jsonb
        WHEN name ILIKE '%cable%' THEN '"CablePro"'::jsonb
        WHEN name ILIKE '%water bottle%' THEN '"EcoVessel"'::jsonb
        WHEN name ILIKE '%laptop stand%' THEN '"ErgoTech"'::jsonb
        WHEN name ILIKE '%keyboard%' THEN '"KeyMaster"'::jsonb
        ELSE '"GenericBrand"'::jsonb
    END
)
WHERE metadata->>'brand' IS NULL;

-- Add more metadata fields
UPDATE products 
SET metadata = metadata || 
    '{"warranty_months": 24, "eco_friendly": false}'::jsonb
WHERE metadata->>'brand' = 'AudioTech';

UPDATE products 
SET metadata = metadata || 
    '{"warranty_months": 12, "eco_friendly": true, "material": "stainless_steel"}'::jsonb
WHERE metadata->>'brand' = 'EcoVessel';

-- Add variants to products
UPDATE products 
SET variants = '[
    {"color": "Black", "sku": "HD-BLK", "stock": 50},
    {"color": "White", "sku": "HD-WHT", "stock": 30}
]'::jsonb
WHERE name ILIKE '%headphone%';

UPDATE products 
SET variants = '[
    {"size": "S", "sku": "WB-S", "stock": 100},
    {"size": "M", "sku": "WB-M", "stock": 150},
    {"size": "L", "sku": "WB-L", "stock": 75}
]'::jsonb
WHERE name ILIKE '%water bottle%';

-- Query JSONB data
SELECT 
    id,
    name,
    price,
    metadata->>'brand' AS brand,
    metadata->>'warranty_months' AS warranty_months,
    metadata->>'eco_friendly' AS eco_friendly,
    variants
FROM products
WHERE metadata ? 'brand'
ORDER BY price;
```

### The Verification

```bash
# Check metadata was added
psql -d ecommerce -c "
SELECT name, metadata 
FROM products 
WHERE metadata != '{}'::jsonb 
LIMIT 5;"

# Check variants
psql -d ecommerce -c "
SELECT name, variants 
FROM products 
WHERE variants != '[]'::jsonb 
LIMIT 5;"

# Check JSONB operators work
psql -d ecommerce -c "
SELECT COUNT(*) 
FROM products 
WHERE metadata ? 'brand';"
```

---

## Phase 5.2: Advanced JSONB Querying

### The Target
Master JSONB operators and functions for sophisticated JSON queries.

### The Concept
PostgreSQL provides rich operators for JSONB. Think of them as specialized tools for digging into JSON documents: `->` gets a JSON object, `->>` gets text, `?` checks if a key exists, `@>` checks if one JSON contains another. These make JSONB almost as queryable as regular columns.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. JSONB Operators
-- Get specific fields
SELECT 
    name,
    metadata->'brand' AS brand_json,
    metadata->>'brand' AS brand_text,
    metadata->>'warranty_months' AS warranty,
    metadata->>'eco_friendly' AS eco_friendly
FROM products
WHERE metadata->>'brand' IS NOT NULL
LIMIT 10;

-- 2. JSONB Existence Operators
-- Find products with specific keys
SELECT name, metadata
FROM products
WHERE metadata ? 'brand'
  AND metadata ? 'warranty_months'
  AND metadata ? 'eco_friendly';

-- Find products with eco-friendly tag
SELECT name, metadata->>'brand' AS brand
FROM products
WHERE metadata @> '{"eco_friendly": true}'::jsonb;

-- 3. JSONB Containment
-- Find products with specific metadata
SELECT name, metadata
FROM products
WHERE metadata @> '{"brand": "AudioTech"}'::jsonb;

-- Find products with warranty > 12 months
SELECT name, metadata->>'brand' AS brand, metadata->>'warranty_months' AS warranty
FROM products
WHERE (metadata->>'warranty_months')::int > 12;

-- 4. Querying JSON Arrays
-- Products with variants
SELECT 
    name,
    jsonb_array_length(variants) AS variant_count,
    variants->0 AS first_variant
FROM products
WHERE jsonb_array_length(variants) > 0;

-- Products with specific variant attribute
SELECT 
    name,
    variants
FROM products
WHERE variants @> '[{"color": "Black"}]'::jsonb;

-- 5. JSONB Array Operations
-- Expand variants into rows
SELECT 
    p.name,
    variant.value AS variant_detail
FROM products p,
LATERAL jsonb_array_elements(p.variants) AS variant(value)
WHERE jsonb_array_length(p.variants) > 0;

-- Get specific variant fields
SELECT 
    p.name,
    variant.value->>'color' AS color,
    variant.value->>'sku' AS sku,
    (variant.value->>'stock')::int AS stock
FROM products p,
LATERAL jsonb_array_elements(p.variants) AS variant(value)
WHERE jsonb_array_length(p.variants) > 0
  AND variant.value ? 'color';

-- 6. JSONB with aggregations
-- Count products by brand
SELECT 
    metadata->>'brand' AS brand,
    COUNT(*) AS product_count,
    AVG((metadata->>'warranty_months')::int) AS avg_warranty,
    SUM(CASE WHEN (metadata->>'eco_friendly')::boolean THEN 1 ELSE 0 END) AS eco_friendly_count
FROM products
WHERE metadata ? 'brand'
GROUP BY metadata->>'brand'
ORDER BY product_count DESC;

-- 7. Nested JSONB operations
-- Update nested JSON
UPDATE products 
SET metadata = jsonb_set(
    metadata,
    '{shipping}',
    '{"weight": 1.5, "dimensions": {"length": 10, "width": 5, "height": 3}}'::jsonb
)
WHERE metadata->>'brand' = 'AudioTech';

-- Query nested fields
SELECT 
    name,
    metadata->'shipping'->>'weight' AS weight,
    metadata->'shipping'->'dimensions'->>'length' AS length
FROM products
WHERE metadata ? 'shipping';

-- 8. Creating indexes on JSONB
-- Create GIN index for fast JSONB queries
CREATE INDEX IF NOT EXISTS idx_products_metadata_gin 
ON products USING gin(metadata);

-- Create expression index on specific JSONB fields
CREATE INDEX IF NOT EXISTS idx_products_metadata_brand 
ON products ((metadata->>'brand'));

CREATE INDEX IF NOT EXISTS idx_products_metadata_eco 
ON products ((metadata->>'eco_friendly')) 
WHERE (metadata->>'eco_friendly')::boolean = true;

-- Demonstrate index usage
EXPLAIN ANALYZE
SELECT name, metadata
FROM products
WHERE metadata @> '{"eco_friendly": true}'::jsonb;
```

### The Verification

```bash
# Test JSONB queries
psql -d ecommerce -c "
SELECT name, metadata->>'brand' AS brand
FROM products
WHERE metadata ? 'brand'
LIMIT 5;"

# Test array expansion
psql -d ecommerce -c "
SELECT 
    p.name,
    jsonb_array_length(p.variants) AS variants
FROM products p
WHERE jsonb_array_length(p.variants) > 0;"

# Check indexes exist
psql -d ecommerce -c "\di idx_products_metadata*"
```

---

## Phase 5.3: Window Functions Fundamentals

### The Target
Understand window functions and their basic usage.

### The Concept
Window functions perform calculations across a set of rows related to the current row, but unlike GROUP BY, they don't collapse rows. Think of them as looking through a window that moves row by row, allowing you to see surrounding data without losing individual row details.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. ROW_NUMBER: Assign sequential numbers
-- Number each order by creation date
SELECT 
    id,
    user_id,
    total,
    created_at,
    ROW_NUMBER() OVER (ORDER BY created_at) AS order_sequence
FROM orders
WHERE status != 'cancelled'
LIMIT 20;

-- Number orders by user (partition by user)
SELECT 
    id,
    user_id,
    total,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS customer_order_number
FROM orders
WHERE status != 'cancelled'
ORDER BY user_id, created_at;

-- 2. RANK and DENSE_RANK
-- Rank products by revenue
WITH product_revenue AS (
    SELECT 
        p.id,
        p.name,
        SUM(oi.total_price) AS revenue
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    GROUP BY p.id, p.name
)
SELECT 
    name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS row_number
FROM product_revenue
WHERE revenue > 0
ORDER BY rank
LIMIT 10;

-- 3. LAG and LEAD: Access previous/next rows
-- Compare each order with previous order (for the same user)
SELECT 
    id,
    user_id,
    total,
    created_at,
    LAG(total, 1) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_order_value,
    total - LAG(total, 1) OVER (PARTITION BY user_id ORDER BY created_at) AS difference,
    LEAD(total, 1) OVER (PARTITION BY user_id ORDER BY created_at) AS next_order_value
FROM orders
WHERE status != 'cancelled'
ORDER BY user_id, created_at;

-- Calculate days between orders
SELECT 
    id,
    user_id,
    created_at,
    LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_order_date,
    EXTRACT(DAY FROM created_at - LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at)) AS days_between_orders
FROM orders
WHERE status != 'cancelled'
ORDER BY user_id, created_at;

-- 4. FIRST_VALUE and LAST_VALUE
-- First and last order for each customer
SELECT 
    id,
    user_id,
    total,
    created_at,
    FIRST_VALUE(total) OVER (PARTITION BY user_id ORDER BY created_at) AS first_order_value,
    LAST_VALUE(total) OVER (PARTITION BY user_id ORDER BY created_at RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order_value
FROM orders
WHERE status != 'cancelled'
ORDER BY user_id, created_at;

-- 5. Moving averages with window frames
-- 3-order moving average (for each user)
SELECT 
    id,
    user_id,
    total,
    created_at,
    ROUND(AVG(total) OVER (
        PARTITION BY user_id 
        ORDER BY created_at 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )::NUMERIC, 2) AS moving_avg_3,
    ROUND(AVG(total) OVER (
        PARTITION BY user_id 
        ORDER BY created_at 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )::NUMERIC, 2) AS cumulative_avg
FROM orders
WHERE status != 'cancelled'
ORDER BY user_id, created_at;
```

### The Verification

```bash
# Test ROW_NUMBER
psql -d ecommerce -c "
SELECT 
    id, user_id, total,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_num
FROM orders
WHERE status != 'cancelled'
LIMIT 20;"

# Test RANK
psql -d ecommerce -c "
WITH revenue AS (
    SELECT p.name, SUM(oi.total_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.id
    GROUP BY p.name
)
SELECT name, revenue,
    RANK() OVER (ORDER BY revenue DESC) AS rank
FROM revenue
WHERE revenue > 0
LIMIT 5;"

# Test LAG
psql -d ecommerce -c "
SELECT 
    id, user_id, total,
    LAG(total) OVER (PARTITION BY user_id ORDER BY created_at) AS prev_total
FROM orders
WHERE status != 'cancelled'
LIMIT 10;"
```

---

## Phase 5.4: Advanced Window Functions

### The Target
Use advanced window function patterns for complex analytics.

### The Concept
Window functions become powerful when combined. We can calculate running totals, percentage of totals, and sophisticated rankings. Think of these as your advanced analytics toolkit for understanding trends and distributions.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Running totals (cumulative sums)
-- Running total of orders over time
SELECT 
    DATE_TRUNC('day', created_at) AS day,
    COUNT(*) AS daily_orders,
    SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('day', created_at) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day;

-- 2. Percentage of total
-- Each order's percentage of total revenue
SELECT 
    id,
    user_id,
    total,
    created_at,
    total / SUM(total) OVER () * 100 AS pct_of_total,
    total / SUM(total) OVER (PARTITION BY user_id) * 100 AS pct_of_customer_total
FROM orders
WHERE status != 'cancelled'
ORDER BY pct_of_total DESC
LIMIT 20;

-- 3. Customer purchase progression
-- Track customer spending growth
WITH customer_orders AS (
    SELECT 
        user_id,
        created_at,
        total,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_number
    FROM orders
    WHERE status != 'cancelled'
)
SELECT 
    user_id,
    order_number,
    total,
    total - LAG(total) OVER (PARTITION BY user_id ORDER BY order_number) AS order_change,
    ROUND((total - LAG(total) OVER (PARTITION BY user_id ORDER BY order_number)) / NULLIF(LAG(total) OVER (PARTITION BY user_id ORDER BY order_number), 0) * 100, 2) AS pct_change
FROM customer_orders
WHERE order_number > 1
ORDER BY user_id, order_number;

-- 4. Product performance with rankings
WITH product_metrics AS (
    SELECT 
        p.id,
        p.name,
        COALESCE(SUM(oi.quantity), 0) AS total_units,
        COALESCE(SUM(oi.total_price), 0) AS revenue,
        COALESCE(COUNT(DISTINCT oi.order_id), 0) AS order_count
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    GROUP BY p.id, p.name
)
SELECT 
    name,
    revenue,
    total_units,
    order_count,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_units DESC) AS units_rank,
    RANK() OVER (ORDER BY order_count DESC) AS popularity_rank,
    total_units / NULLIF(order_count, 0) AS avg_units_per_order
FROM product_metrics
WHERE revenue > 0 OR total_units > 0
ORDER BY revenue_rank
LIMIT 15;

-- 5. Cohort analysis with window functions
-- Customer retention cohorts (by month of first order)
WITH first_orders AS (
    SELECT 
        user_id,
        MIN(created_at) AS first_order_date,
        DATE_TRUNC('month', MIN(created_at)) AS cohort_month
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY user_id
),
order_details AS (
    SELECT 
        o.user_id,
        o.created_at,
        DATE_TRUNC('month', o.created_at) AS order_month,
        EXTRACT(MONTH FROM o.created_at) AS month_number,
        EXTRACT(YEAR FROM o.created_at) AS year_number
    FROM orders o
    JOIN first_orders fo ON fo.user_id = o.user_id
    WHERE o.status != 'cancelled'
)
SELECT 
    cohort_month,
    order_month,
    COUNT(DISTINCT user_id) AS retained_customers,
    COUNT(DISTINCT user_id) - LAG(COUNT(DISTINCT user_id)) OVER (PARTITION BY cohort_month ORDER BY order_month) AS retention_change,
    ROUND((COUNT(DISTINCT user_id) / NULLIF(FIRST_VALUE(COUNT(DISTINCT user_id)) OVER (PARTITION BY cohort_month ORDER BY order_month), 0) * 100)::NUMERIC, 2) AS retention_rate_pct
FROM order_details
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;

-- 6. NTILE: Percentile grouping
-- Divide customers into 4 quartiles by spending
WITH customer_spending AS (
    SELECT 
        u.id,
        u.email,
        SUM(o.total) AS total_spent
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    GROUP BY u.id, u.email
)
SELECT 
    email,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent) AS spending_quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_spent) = 1 THEN 'Low Spend'
        WHEN NTILE(4) OVER (ORDER BY total_spent) = 2 THEN 'Medium-Low Spend'
        WHEN NTILE(4) OVER (ORDER BY total_spent) = 3 THEN 'Medium-High Spend'
        ELSE 'High Spend'
    END AS spending_category
FROM customer_spending
ORDER BY spending_quartile, total_spent DESC;

-- 7. Cumulative distribution
-- What percentage of products are cheaper than each price point?
SELECT 
    name,
    price,
    ROUND(CUME_DIST() OVER (ORDER BY price)::NUMERIC * 100, 2) AS pct_products_cheaper_or_equal,
    ROUND(PERCENT_RANK() OVER (ORDER BY price)::NUMERIC * 100, 2) AS pct_strictly_cheaper
FROM products
WHERE is_active = true
ORDER BY price;
```

### The Verification

```bash
# Test running totals
psql -d ecommerce -c "
SELECT 
    DATE_TRUNC('day', created_at) AS day,
    COUNT(*) AS orders,
    SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('day', created_at)) AS running_total
FROM orders
WHERE status != 'cancelled'
GROUP BY day
ORDER BY day DESC
LIMIT 10;"

# Test NTILE
psql -d ecommerce -c "
WITH customer_spending AS (
    SELECT u.id, SUM(o.total) AS spent
    FROM users u
    JOIN orders o ON o.user_id = u.id
    WHERE o.status != 'cancelled'
    GROUP BY u.id
)
SELECT 
    NTILE(4) OVER (ORDER BY spent) AS quartile,
    COUNT(*) AS customers,
    MIN(spent) AS min_spent,
    MAX(spent) AS max_spent
FROM customer_spending
GROUP BY quartile
ORDER BY quartile;"

# Test cumulative distribution
psql -d ecommerce -c "
SELECT 
    price,
    ROUND(CUME_DIST() OVER (ORDER BY price)::NUMERIC * 100, 2) AS percentile
FROM products
WHERE is_active = true
ORDER BY price
LIMIT 10;"
```

---

## Phase 5.5: JSONB + Window Functions Combined

### The Target
Combine JSONB and window functions for powerful analytics.

### The Concept
The real power comes when combining JSONB's flexibility with window functions' analytical capabilities. We can extract data from JSONB and perform window calculations on it, enabling complex analyses that would be difficult in traditional SQL.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Analyze product variants with window functions
WITH variant_analysis AS (
    SELECT 
        p.name AS product_name,
        variant.value->>'color' AS color,
        variant.value->>'sku' AS sku,
        (variant.value->>'stock')::int AS variant_stock,
        ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY (variant.value->>'stock')::int DESC) AS stock_rank
    FROM products p,
    LATERAL jsonb_array_elements(p.variants) AS variant(value)
    WHERE jsonb_array_length(p.variants) > 0
)
SELECT 
    product_name,
    color,
    sku,
    variant_stock,
    stock_rank,
    CASE 
        WHEN stock_rank = 1 THEN 'Best Stocked'
        WHEN stock_rank = jsonb_array_length((SELECT variants FROM products WHERE name = product_name)) THEN 'Lowest Stock'
        ELSE 'Middle Stock'
    END AS stock_status
FROM variant_analysis
ORDER BY product_name, stock_rank;

-- 2. JSONB metadata with product performance
WITH product_performance AS (
    SELECT 
        p.id,
        p.name,
        p.price,
        p.metadata->>'brand' AS brand,
        (p.metadata->>'warranty_months')::int AS warranty_months,
        (p.metadata->>'eco_friendly')::boolean AS eco_friendly,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(SUM(oi.total_price), 0) AS revenue
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    GROUP BY p.id, p.name, p.price, p.metadata
)
SELECT 
    name,
    brand,
    price,
    warranty_months,
    eco_friendly,
    revenue,
    RANK() OVER (PARTITION BY brand ORDER BY revenue DESC) AS revenue_rank_in_brand,
    RANK() OVER (ORDER BY revenue DESC) AS overall_rank,
    ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY brand)::NUMERIC, 2) AS pct_of_brand_revenue,
    ROUND(100 * revenue / SUM(revenue) OVER ()::NUMERIC, 2) AS pct_of_total_revenue
FROM product_performance
WHERE revenue > 0
ORDER BY brand, revenue DESC;

-- 3. Analyze product metadata attributes distribution
SELECT 
    metadata->>'brand' AS brand,
    COUNT(*) AS product_count,
    AVG((metadata->>'warranty_months')::int) AS avg_warranty,
    SUM(CASE WHEN (metadata->>'eco_friendly')::boolean THEN 1 ELSE 0 END) AS eco_friendly_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS popularity_rank,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER ()::NUMERIC, 2) AS market_share_pct
FROM products
WHERE metadata ? 'brand'
GROUP BY metadata->>'brand'
ORDER BY product_count DESC;

-- 4. Product metadata and order patterns
WITH order_analysis AS (
    SELECT 
        p.id AS product_id,
        p.name,
        p.metadata->>'brand' AS brand,
        (p.metadata->>'warranty_months')::int AS warranty_months,
        COUNT(DISTINCT o.id) AS order_count,
        SUM(oi.quantity) AS total_units,
        SUM(oi.total_price) AS revenue,
        AVG(oi.unit_price) AS avg_sale_price,
        MIN(o.created_at) AS first_sale,
        MAX(o.created_at) AS last_sale
    FROM products p
    JOIN order_items oi ON oi.product_id = p.id
    JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    WHERE p.metadata ? 'brand'
    GROUP BY p.id, p.name, p.metadata
),
ranked_products AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY brand ORDER BY revenue DESC) AS brand_rank,
        RANK() OVER (ORDER BY revenue DESC) AS overall_rank,
        ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY brand)::NUMERIC, 2) AS brand_contribution_pct,
        ROUND(100 * revenue / SUM(revenue) OVER ()::NUMERIC, 2) AS total_contribution_pct
    FROM order_analysis
)
SELECT 
    brand,
    name AS product,
    revenue,
    total_units,
    order_count,
    brand_rank,
    brand_contribution_pct,
    overall_rank,
    CASE 
        WHEN overall_rank <= 3 THEN 'Top Product'
        WHEN overall_rank <= 10 THEN 'High Performer'
        ELSE 'Standard'
    END AS performance_tier
FROM ranked_products
ORDER BY brand, brand_rank;

-- 5. Customer preference analysis from JSONB preferences
WITH customer_preferences AS (
    SELECT 
        id,
        email,
        preferences->>'theme' AS theme,
        preferences->>'notifications' AS notifications,
        preferences->>'language' AS language,
        preferences->'shipping'->>'preferred_carrier' AS preferred_carrier
    FROM users
    WHERE preferences ? 'theme'
),
customer_spending AS (
    SELECT 
        u.id AS user_id,
        SUM(o.total) AS total_spent,
        COUNT(o.id) AS order_count
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    GROUP BY u.id
)
SELECT 
    cp.theme,
    cp.notifications,
    cp.language,
    COUNT(DISTINCT cp.id) AS user_count,
    AVG(cs.total_spent) AS avg_spent,
    SUM(cs.total_spent) AS total_spent,
    RANK() OVER (ORDER BY SUM(cs.total_spent) DESC) AS spending_rank,
    ROUND(100 * SUM(cs.total_spent) / SUM(SUM(cs.total_spent)) OVER ()::NUMERIC, 2) AS share_of_spend
FROM customer_preferences cp
JOIN customer_spending cs ON cs.user_id = cp.id
GROUP BY cp.theme, cp.notifications, cp.language
HAVING COUNT(DISTINCT cp.id) > 0
ORDER BY total_spent DESC;
```

### The Verification

```bash
# Test combined JSONB + window functions
psql -d ecommerce -c "
WITH variant_analysis AS (
    SELECT 
        p.name,
        variant.value->>'color' AS color,
        ROW_NUMBER() OVER (PARTITION BY p.id ORDER BY variant.value->>'stock') AS stock_rank
    FROM products p,
    LATERAL jsonb_array_elements(p.variants) AS variant(value)
    WHERE jsonb_array_length(p.variants) > 0
)
SELECT name, color, stock_rank
FROM variant_analysis
WHERE stock_rank <= 2
ORDER BY name, stock_rank;"

# Test brand performance analysis
psql -d ecommerce -c "
WITH brand_metrics AS (
    SELECT 
        metadata->>'brand' AS brand,
        COUNT(*) AS product_count,
        SUM(price) AS total_value
    FROM products
    WHERE metadata ? 'brand'
    GROUP BY metadata->>'brand'
)
SELECT 
    brand,
    product_count,
    total_value,
    RANK() OVER (ORDER BY total_value DESC) AS rank
FROM brand_metrics
ORDER BY rank;"
```

---

## Phase 5.6: Customer Ranking System

### The Target
Build a comprehensive customer ranking system using window functions.

### The Concept
We'll create a complete customer ranking system that scores and ranks customers based on multiple criteria. This is the kind of system e-commerce platforms use for loyalty programs, targeted marketing, and VIP identification.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create a customer ranking view
DROP VIEW IF EXISTS customer_ranking;

CREATE VIEW customer_ranking AS
WITH customer_metrics AS (
    SELECT 
        u.id,
        u.email,
        u.first_name,
        u.last_name,
        u.created_at AS signup_date,
        u.preferences->>'theme' AS theme_preference,
        COUNT(DISTINCT o.id) AS order_count,
        COALESCE(SUM(o.total), 0) AS total_spent,
        COALESCE(AVG(o.total), 0) AS avg_order_value,
        MAX(o.created_at) AS last_order_date,
        COALESCE(SUM(oi.quantity), 0) AS total_items,
        COALESCE(COUNT(DISTINCT oi.product_id), 0) AS unique_products,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at)) AS days_since_last_order
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    LEFT JOIN order_items oi ON oi.order_id = o.id
    WHERE u.is_active = true
    GROUP BY u.id, u.email, u.first_name, u.last_name, u.created_at, u.preferences
)
SELECT 
    id,
    email,
    first_name,
    last_name,
    signup_date,
    order_count,
    total_spent,
    avg_order_value,
    last_order_date,
    days_since_last_order,
    total_items,
    unique_products,
    -- Ranking calculations
    RANK() OVER (ORDER BY total_spent DESC) AS spend_rank,
    RANK() OVER (ORDER BY order_count DESC) AS frequency_rank,
    RANK() OVER (ORDER BY total_items DESC) AS volume_rank,
    -- Percentiles
    PERCENT_RANK() OVER (ORDER BY total_spent DESC) AS spend_percentile,
    -- Recency scoring (lower = better)
    CASE 
        WHEN days_since_last_order IS NULL THEN 1.0
        ELSE 1.0 - (days_since_last_order / 365.0)
    END AS recency_score,
    -- Composite scores
    (total_spent / NULLIF(MAX(total_spent) OVER (), 0)) * 40 +
    (order_count / NULLIF(MAX(order_count) OVER (), 0)) * 30 +
    (total_items / NULLIF(MAX(total_items) OVER (), 0)) * 20 +
    (CASE 
        WHEN days_since_last_order IS NULL THEN 0
        ELSE 1.0 - (days_since_last_order / 365.0)
     END) * 10 AS composite_score,
    -- Customer tier
    CASE 
        WHEN order_count = 0 THEN 'Inactive'
        WHEN total_spent >= 1000 THEN 'Platinum'
        WHEN total_spent >= 500 THEN 'Gold'
        WHEN total_spent >= 100 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM customer_metrics
WHERE id IS NOT NULL;

-- Query the customer ranking view
SELECT 
    email,
    customer_tier,
    total_spent,
    order_count,
    composite_score,
    spend_rank,
    frequency_rank
FROM customer_ranking
ORDER BY composite_score DESC
LIMIT 10;

-- Create a loyalty points system
CREATE OR REPLACE FUNCTION calculate_loyalty_points(
    p_user_id UUID,
    p_order_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    v_order_total NUMERIC;
    v_points INTEGER;
    v_user_tier TEXT;
BEGIN
    -- Get order total
    SELECT total INTO v_order_total 
    FROM orders 
    WHERE id = p_order_id AND user_id = p_user_id;
    
    -- Get user tier
    SELECT customer_tier INTO v_user_tier
    FROM customer_ranking
    WHERE id = p_user_id;
    
    -- Calculate points based on tier
    v_points := FLOOR(v_order_total)::INTEGER * 10; -- Base: 10 points per dollar
    
    -- Bonus multipliers
    CASE v_user_tier
        WHEN 'Platinum' THEN v_points := v_points * 2;
        WHEN 'Gold' THEN v_points := v_points * 1.5;
        WHEN 'Silver' THEN v_points := v_points * 1.25;
        ELSE v_points := v_points * 1;
    END CASE;
    
    RETURN v_points;
END;
$$ LANGUAGE plpgsql;

-- Test the loyalty points function
SELECT 
    o.id AS order_id,
    u.email,
    o.total,
    calculate_loyalty_points(u.id, o.id) AS points_earned
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.status != 'cancelled'
LIMIT 10;

-- Create loyalty points summary
WITH customer_points AS (
    SELECT 
        u.id,
        u.email,
        u.first_name,
        u.last_name,
        SUM(calculate_loyalty_points(u.id, o.id)) AS total_points,
        COUNT(o.id) AS orders_with_points
    FROM users u
    JOIN orders o ON o.user_id = u.id
    WHERE o.status != 'cancelled'
    GROUP BY u.id, u.email, u.first_name, u.last_name
)
SELECT 
    email,
    total_points,
    orders_with_points,
    RANK() OVER (ORDER BY total_points DESC) AS points_rank,
    CASE 
        WHEN total_points >= 10000 THEN 'Elite'
        WHEN total_points >= 5000 THEN 'Premium'
        WHEN total_points >= 1000 THEN 'Standard'
        ELSE 'Newcomer'
    END AS loyalty_tier
FROM customer_points
WHERE total_points > 0
ORDER BY total_points DESC
LIMIT 20;
```

### The Verification

```bash
# Check the customer ranking view
psql -d ecommerce -c "SELECT COUNT(*) FROM customer_ranking;"

# View top customers by composite score
psql -d ecommerce -c "
SELECT email, customer_tier, total_spent, order_count, ROUND(composite_score::NUMERIC, 2) AS score
FROM customer_ranking
ORDER BY composite_score DESC
LIMIT 10;"

# Test loyalty points function
psql -d ecommerce -c "
SELECT 
    calculate_loyalty_points(
        (SELECT id FROM users LIMIT 1),
        (SELECT id FROM orders LIMIT 1)
    ) AS points;"

# Check loyalty tiers
psql -d ecommerce -c "
SELECT 
    customer_tier,
    COUNT(*) AS customers,
    AVG(total_spent) AS avg_spent
FROM customer_ranking
GROUP BY customer_tier
ORDER BY customer_tier;"
```

---

## Phase 5.7: Complete Modern Features Script

### The Target
Create a comprehensive script showcasing all modern PostgreSQL features.

### The Concept
We'll compile everything into a single, reusable script that demonstrates all the modern PostgreSQL features we've learned: JSONB operations, window functions, and complex analytics.

### The Implementation

Create a file called `05_modern_features.sql`:

```sql
-- 05_modern_features.sql
-- Comprehensive demonstration of JSONB and Window Functions

\c ecommerce

-- ============================================================
-- SECTION 1: JSONB Setup and Operations
-- ============================================================
SELECT '=== JSONB SETUP ===' AS section;

-- Ensure columns exist
ALTER TABLE products ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS variants JSONB DEFAULT '[]'::jsonb;

-- Update with sample metadata
UPDATE products 
SET metadata = COALESCE(metadata, '{}'::jsonb) || 
    jsonb_build_object(
        'brand', CASE 
            WHEN name ILIKE '%headphone%' THEN 'AudioTech'
            WHEN name ILIKE '%cable%' THEN 'CablePro'
            WHEN name ILIKE '%water%' THEN 'EcoVessel'
            WHEN name ILIKE '%laptop stand%' THEN 'ErgoTech'
            ELSE 'GenericBrand'
        END,
        'last_updated', NOW()::TEXT
    )
WHERE NOT (metadata ? 'brand');

-- Add variants to some products
UPDATE products 
SET variants = 
    CASE 
        WHEN name ILIKE '%headphone%' THEN 
            '[{"color": "Black", "stock": 50}, {"color": "White", "stock": 30}]'::jsonb
        WHEN name ILIKE '%water%' THEN
            '[{"size": "S", "stock": 100}, {"size": "M", "stock": 150}, {"size": "L", "stock": 75}]'::jsonb
        ELSE variants
    END
WHERE jsonb_array_length(variants) = 0 
  AND (name ILIKE '%headphone%' OR name ILIKE '%water%');

-- ============================================================
-- SECTION 2: JSONB Queries
-- ============================================================
SELECT '=== JSONB QUERIES ===' AS section;

-- Get product metadata summary
SELECT 
    'Product Metadata Summary' AS report,
    COUNT(*) FILTER (WHERE metadata ? 'brand') AS has_brand,
    COUNT(*) FILTER (WHERE jsonb_array_length(variants) > 0) AS has_variants,
    COUNT(DISTINCT metadata->>'brand') AS unique_brands
FROM products;

-- Products by brand with variant counts
SELECT 
    metadata->>'brand' AS brand,
    COUNT(*) AS product_count,
    SUM(jsonb_array_length(variants)) AS total_variants,
    AVG((metadata->>'last_updated')::timestamptz) AS avg_last_updated
FROM products
WHERE metadata ? 'brand'
GROUP BY metadata->>'brand'
ORDER BY product_count DESC;

-- ============================================================
-- SECTION 3: Window Functions - Basic
-- ============================================================
SELECT '=== WINDOW FUNCTIONS - BASIC ===' AS section;

-- Order sequence and running totals
SELECT 
    'Running Totals' AS analysis,
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS orders,
    SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', created_at)) AS running_total_orders,
    SUM(SUM(total)) OVER (ORDER BY DATE_TRUNC('month', created_at)) AS running_total_revenue
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month;

-- ============================================================
-- SECTION 4: Window Functions - Advanced
-- ============================================================
SELECT '=== WINDOW FUNCTIONS - ADVANCED ===' AS section;

-- Customer purchase patterns
WITH customer_patterns AS (
    SELECT 
        u.id AS user_id,
        u.email,
        o.id AS order_id,
        o.total,
        o.created_at,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.created_at) AS order_num,
        LAG(o.total) OVER (PARTITION BY u.id ORDER BY o.created_at) AS prev_order_total,
        LEAD(o.total) OVER (PARTITION BY u.id ORDER BY o.created_at) AS next_order_total
    FROM users u
    JOIN orders o ON o.user_id = u.id
    WHERE o.status != 'cancelled'
)
SELECT 
    user_id,
    email,
    order_num,
    total AS current_order,
    prev_order_total,
    next_order_total,
    CASE 
        WHEN prev_order_total IS NULL THEN 'First Order'
        WHEN total > prev_order_total * 1.5 THEN 'Big Spender Increase'
        WHEN total < prev_order_total * 0.5 THEN 'Significant Decrease'
        ELSE 'Normal'
    END AS order_pattern
FROM customer_patterns
WHERE order_num <= 3
ORDER BY user_id, order_num;

-- ============================================================
-- SECTION 5: JSONB + Window Functions Combined
-- ============================================================
SELECT '=== JSONB + WINDOW FUNCTIONS COMBINED ===' AS section;

-- Product performance with brand rankings
WITH product_metrics AS (
    SELECT 
        p.id,
        p.name,
        p.metadata->>'brand' AS brand,
        COALESCE(SUM(oi.quantity), 0) AS units_sold,
        COALESCE(SUM(oi.total_price), 0) AS revenue,
        COALESCE(COUNT(DISTINCT oi.order_id), 0) AS order_count
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    WHERE p.metadata ? 'brand'
    GROUP BY p.id, p.name, p.metadata
)
SELECT 
    brand,
    name AS product,
    units_sold,
    revenue,
    RANK() OVER (PARTITION BY brand ORDER BY revenue DESC) AS brand_rank,
    ROUND(100 * revenue / SUM(revenue) OVER (PARTITION BY brand)::NUMERIC, 2) AS brand_contribution_pct,
    RANK() OVER (ORDER BY revenue DESC) AS overall_rank
FROM product_metrics
WHERE revenue > 0
ORDER BY brand, brand_rank
LIMIT 20;

-- ============================================================
-- SECTION 6: Customer Ranking Summary
-- ============================================================
SELECT '=== CUSTOMER RANKING SUMMARY ===' AS section;

-- Create or replace customer ranking view
DROP VIEW IF EXISTS customer_ranking_summary;

CREATE VIEW customer_ranking_summary AS
WITH metrics AS (
    SELECT 
        u.id,
        u.email,
        COUNT(DISTINCT o.id) AS order_count,
        COALESCE(SUM(o.total), 0) AS total_spent,
        COALESCE(AVG(o.total), 0) AS avg_order,
        MAX(o.created_at) AS last_order,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at)) AS days_since_last
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    WHERE u.is_active = true
    GROUP BY u.id, u.email
)
SELECT 
    id,
    email,
    order_count,
    total_spent,
    avg_order,
    days_since_last,
    RANK() OVER (ORDER BY total_spent DESC) AS spend_rank,
    RANK() OVER (ORDER BY order_count DESC) AS frequency_rank,
    ROUND(100 * (total_spent / SUM(total_spent) OVER ())::NUMERIC, 2) AS pct_of_total_spend,
    CASE 
        WHEN total_spent >= 1000 THEN 'Platinum'
        WHEN total_spent >= 500 THEN 'Gold'
        WHEN total_spent >= 100 THEN 'Silver'
        WHEN order_count > 0 THEN 'Bronze'
        ELSE 'Prospect'
    END AS tier
FROM metrics
WHERE id IS NOT NULL;

-- Query the summary
SELECT 
    tier,
    COUNT(*) AS customers,
    SUM(total_spent) AS total_revenue,
    AVG(total_spent) AS avg_spent,
    AVG(order_count) AS avg_orders
FROM customer_ranking_summary
GROUP BY tier
ORDER BY MIN(total_spent) DESC;

-- ============================================================
-- SECTION 7: Complex Analytics Dashboard
-- ============================================================
SELECT '=== COMPLEX ANALYTICS DASHBOARD ===' AS section;

-- Monthly cohort retention
WITH monthly_cohorts AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', MIN(created_at)) AS cohort_month
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY user_id
),
order_months AS (
    SELECT 
        o.user_id,
        mc.cohort_month,
        DATE_TRUNC('month', o.created_at) AS order_month,
        EXTRACT(MONTH FROM o.created_at) AS month_number,
        EXTRACT(YEAR FROM o.created_at) AS year_number,
        EXTRACT(MONTH FROM o.created_at - mc.cohort_month) AS month_offset
    FROM orders o
    JOIN monthly_cohorts mc ON mc.user_id = o.user_id
    WHERE o.status != 'cancelled'
)
SELECT 
    cohort_month,
    month_offset,
    COUNT(DISTINCT user_id) AS retained_customers,
    ROUND(100 * COUNT(DISTINCT user_id) / MAX(COUNT(DISTINCT user_id)) OVER (PARTITION BY cohort_month)::NUMERIC, 2) AS retention_rate
FROM order_months
GROUP BY cohort_month, month_offset
HAVING month_offset >= 0
ORDER BY cohort_month, month_offset;

-- ============================================================
-- SECTION 8: Report Complete
-- ============================================================
SELECT '=== MODERN FEATURES REPORT COMPLETE ===' AS section;
SELECT NOW() AS report_generated_at;
SELECT 'JSONB + Window Functions Demo Ready!' AS status;
```

Run the script:

```bash
# Execute the modern features demo
psql -d ecommerce -U ecommerce_user -f 05_modern_features.sql

# Generate a report file
psql -d ecommerce -U ecommerce_user -f 05_modern_features.sql > modern_features_report_$(date +%Y%m%d).txt

# Check the customer ranking
psql -d ecommerce -c "SELECT * FROM customer_ranking_summary LIMIT 10;"
```

### The Verification

```bash
# Verify all components
psql -d ecommerce -c "SELECT COUNT(*) FROM products WHERE metadata ? 'brand';"
psql -d ecommerce -c "SELECT COUNT(*) FROM products WHERE jsonb_array_length(variants) > 0;"
psql -d ecommerce -c "SELECT COUNT(*) FROM customer_ranking_summary;"

# Check the dashboard
psql -d ecommerce -c "
SELECT tier, COUNT(*) AS count 
FROM customer_ranking_summary 
GROUP BY tier 
ORDER BY tier;"
```

---

## Summary: What You've Accomplished

You've unlocked PostgreSQL's modern superpowers:

✅ Stored and queried flexible JSONB data  
✅ Created and queried JSON arrays with variants  
✅ Used JSONB operators and functions (->, ->>, @>, ?, jsonb_array_elements)  
✅ Implemented JSONB indexes for performance  
✅ Mastered window functions: ROW_NUMBER, RANK, DENSE_RANK  
✅ Calculated running totals and moving averages  
✅ Performed LAG/LEAD comparisons  
✅ Created customer ranking systems with composite scores  
✅ Built loyalty point calculation functions  
✅ Combined JSONB and window functions for advanced analytics  
✅ Created comprehensive, reusable analysis scripts  

## What's Next

In **Part 6**, we'll focus on production readiness: performance optimization, indexing strategies, and transactions. You'll learn to use `EXPLAIN ANALYZE`, choose the right indexes, and ensure your database operations are atomic and safe.

**Before Part 6**, practice these skills:
1. Add JSONB metadata to all products with at least 3 fields
2. Create a window function query showing 3-month moving average of daily orders
3. Build a ranking of products by revenue within each brand
4. Create a customer loyalty tier summary
5. Write a query using NTILE to segment customers into deciles

*Ready for Part 6? We'll make your database production-ready with performance optimization, strategic indexing, and bulletproof transactions. You'll learn to diagnose slow queries, speed them up, and ensure data integrity during complex operations.*
