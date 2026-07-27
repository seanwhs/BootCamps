# Part 4: Aggregations, Grouping, & Subqueries

Your e-commerce database is now fully relational. But data is only valuable when you can analyze it. In this part, we'll transform raw data into business intelligence. Think of aggregations as turning a pile of bricks into a finished building—we'll count, sum, average, and group our way to meaningful insights.

## Phase 4.1: Understanding Aggregate Functions

### The Target
Master the five core aggregate functions: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, and `MAX()`.

### The Concept
Aggregate functions take many values and combine them into a single result. They're like different types of summaries: `COUNT` is a headcount, `SUM` adds everything up, `AVG` finds the typical value, `MIN` finds the smallest, and `MAX` finds the largest.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. COUNT: Count rows in a table
-- Count all users
SELECT COUNT(*) AS total_users FROM users;

-- Count only active users
SELECT COUNT(*) AS active_users FROM users WHERE is_active = true;

-- Count distinct values (unique users who placed orders)
SELECT COUNT(DISTINCT user_id) AS unique_customers FROM orders;

-- Count NULL and non-NULL values
SELECT 
    COUNT(*) AS total_users,
    COUNT(phone) AS users_with_phone,
    COUNT(*) - COUNT(phone) AS users_without_phone
FROM users;

-- 2. SUM: Add up numeric values
-- Total revenue from all orders
SELECT SUM(total) AS total_revenue FROM orders WHERE status != 'cancelled';

-- Total quantity of all items sold
SELECT SUM(quantity) AS total_items_sold FROM order_items;

-- Revenue by order status
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total) AS total_revenue
FROM orders
GROUP BY status
ORDER BY status;

-- 3. AVG: Calculate average values
-- Average order value
SELECT AVG(total) AS avg_order_value FROM orders WHERE status = 'paid';

-- Average product price
SELECT AVG(price) AS avg_product_price FROM products WHERE is_active = true;

-- Average items per order
SELECT AVG(item_count) AS avg_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS order_item_counts;

-- 4. MIN and MAX: Find extremes
-- Most expensive product
SELECT MAX(price) AS max_price FROM products;

-- Cheapest product
SELECT MIN(price) AS min_price FROM products;

-- First and last order dates
SELECT 
    MIN(created_at) AS first_order_date,
    MAX(created_at) AS last_order_date
FROM orders;

-- 5. Combining aggregates in one query
SELECT 
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order_value,
    MIN(total) AS smallest_order,
    MAX(total) AS largest_order,
    SUM(total) / COUNT(*) AS avg_order_value_manual
FROM orders 
WHERE status IN ('paid', 'shipped', 'delivered');
```

### The Verification

```bash
# Run each aggregate query and verify results

# Total revenue
psql -d ecommerce -c "SELECT SUM(total) FROM orders WHERE status != 'cancelled';"

# Average order value
psql -d ecommerce -c "SELECT AVG(total) FROM orders WHERE status = 'paid';"

# Products price range
psql -d ecommerce -c "SELECT MIN(price), MAX(price), AVG(price) FROM products;"

# Verify counts match
psql -d ecommerce -c "
SELECT 
    (SELECT COUNT(*) FROM users) AS users,
    (SELECT COUNT(*) FROM orders) AS orders,
    (SELECT COUNT(*) FROM order_items) AS order_items;"
```

---

## Phase 4.2: Grouping Data with GROUP BY

### The Target
Use `GROUP BY` to segment data and perform aggregate calculations per group.

### The Concept
`GROUP BY` is like sorting data into buckets, then applying aggregates to each bucket. Think of it as analyzing sales by region, by product category, or by customer type. Each group gets its own summary statistics.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Basic GROUP BY
-- Count orders by status
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total) AS total_value
FROM orders
GROUP BY status
ORDER BY status;

-- 2. GROUP BY with date truncation
-- Orders by month
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS order_count,
    SUM(total) AS monthly_revenue
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- 3. GROUP BY with multiple columns
-- Orders by year and month
SELECT 
    EXTRACT(YEAR FROM created_at) AS year,
    EXTRACT(MONTH FROM created_at) AS month,
    COUNT(*) AS order_count,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value
FROM orders
WHERE status != 'cancelled'
GROUP BY EXTRACT(YEAR FROM created_at), EXTRACT(MONTH FROM created_at)
ORDER BY year DESC, month DESC;

-- 4. GROUP BY with joined tables
-- Sales by product category
SELECT 
    c.name AS category,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS revenue
FROM categories c
JOIN product_categories pc ON pc.category_id = c.id
JOIN products p ON p.id = pc.product_id
JOIN order_items oi ON oi.product_id = p.id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY c.id, c.name
ORDER BY revenue DESC;

-- 5. GROUP BY with customer analysis
-- Customer purchase history
SELECT 
    u.id,
    u.email,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent,
    AVG(o.total) AS avg_order_value,
    MIN(o.created_at) AS first_order,
    MAX(o.created_at) AS last_order
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE o.status != 'cancelled'
GROUP BY u.id, u.email
HAVING COUNT(o.id) > 0
ORDER BY total_spent DESC;

-- 6. GROUP BY with product analysis
-- Most popular products
SELECT 
    p.name AS product,
    COUNT(DISTINCT oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.total_price) AS total_revenue,
    AVG(oi.unit_price) AS avg_price_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
ORDER BY total_revenue DESC
LIMIT 10;

-- 7. GROUP BY with customer segmentation
-- Customer spending tiers
SELECT 
    CASE 
        WHEN total_spent < 100 THEN 'Bronze (< $100)'
        WHEN total_spent < 500 THEN 'Silver ($100 - $500)'
        WHEN total_spent < 1000 THEN 'Gold ($500 - $1000)'
        ELSE 'Platinum (> $1000)'
    END AS customer_tier,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS total_revenue,
    AVG(total_spent) AS avg_spent
FROM (
    SELECT 
        u.id,
        SUM(o.total) AS total_spent
    FROM users u
    JOIN orders o ON o.user_id = u.id
    WHERE o.status != 'cancelled'
    GROUP BY u.id
) AS customer_spending
GROUP BY customer_tier
ORDER BY MIN(total_spent);
```

### The Verification

```bash
# Test group by queries

# Check monthly revenue trends
psql -d ecommerce -c "
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE status != 'cancelled'
GROUP BY month
ORDER BY month DESC;"

# Find top categories
psql -d ecommerce -c "
SELECT 
    c.name,
    SUM(oi.quantity) AS units_sold
FROM categories c
JOIN product_categories pc ON pc.category_id = c.id
JOIN order_items oi ON oi.product_id = pc.product_id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY c.name
ORDER BY units_sold DESC
LIMIT 5;"

# Check customer tiers
psql -d ecommerce -c "
SELECT 
    CASE 
        WHEN total < 100 THEN 'Bronze'
        WHEN total < 500 THEN 'Silver'
        ELSE 'Gold'
    END AS tier,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE status != 'cancelled'
GROUP BY tier;"
```

---

## Phase 4.3: Filtering Groups with HAVING

### The Target
Use `HAVING` to filter groups after aggregation.

### The Concept
`WHERE` filters individual rows; `HAVING` filters groups after `GROUP BY`. Think of `WHERE` as screening applicants before they enter the room, and `HAVING` as deciding which groups in the room qualify. It's essential for answering questions like "Which customers have spent more than $1000?"

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Basic HAVING
-- Find customers with more than 2 orders
SELECT 
    u.email,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE o.status != 'cancelled'
GROUP BY u.id, u.email
HAVING COUNT(o.id) > 2
ORDER BY order_count DESC;

-- 2. HAVING with aggregate conditions
-- Products that have generated more than $100 in revenue
SELECT 
    p.name AS product,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
HAVING SUM(oi.total_price) > 100
ORDER BY revenue DESC;

-- 3. HAVING with multiple conditions
-- Categories with more than 50 units sold and average price > $30
SELECT 
    c.name AS category,
    SUM(oi.quantity) AS units_sold,
    AVG(oi.unit_price) AS avg_price,
    SUM(oi.total_price) AS revenue
FROM categories c
JOIN product_categories pc ON pc.category_id = c.id
JOIN products p ON p.id = pc.product_id
JOIN order_items oi ON oi.product_id = p.id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY c.id, c.name
HAVING 
    SUM(oi.quantity) > 50 
    AND AVG(oi.unit_price) > 30
ORDER BY revenue DESC;

-- 4. HAVING with complex calculations
-- Find months with above-average revenue
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        SUM(total) AS revenue,
        AVG(SUM(total)) OVER () AS overall_avg
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT 
    month,
    revenue,
    overall_avg,
    ROUND((revenue - overall_avg) / overall_avg * 100, 2) AS pct_above_avg
FROM monthly_revenue
WHERE revenue > overall_avg
ORDER BY revenue DESC;

-- 5. HAVING with COUNT DISTINCT
-- Products bought by more than 3 unique customers
SELECT 
    p.name AS product,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    COUNT(oi.id) AS total_orders
FROM products p
JOIN order_items oi ON oi.product_id = p.id
JOIN orders o ON o.id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name
HAVING COUNT(DISTINCT o.user_id) > 3
ORDER BY unique_customers DESC;

-- 6. HAVING with date filters
-- Customers who ordered in the last 30 days and have spent > $200
SELECT 
    u.email,
    COUNT(o.id) AS recent_orders,
    SUM(o.total) AS recent_spent
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE 
    o.status != 'cancelled'
    AND o.created_at > NOW() - INTERVAL '30 days'
GROUP BY u.id, u.email
HAVING 
    COUNT(o.id) >= 1 
    AND SUM(o.total) > 200
ORDER BY recent_spent DESC;
```

### The Verification

```bash
# Test HAVING queries

# Customers with multiple orders
psql -d ecommerce -c "
SELECT u.email, COUNT(o.id) 
FROM users u
JOIN orders o ON o.user_id = u.id
GROUP BY u.email
HAVING COUNT(o.id) > 1;"

# Products with revenue > $100
psql -d ecommerce -c "
SELECT p.name, SUM(oi.total_price) AS revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.name
HAVING SUM(oi.total_price) > 100;"

# Check monthly performance
psql -d ecommerce -c "
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    SUM(total) AS revenue
FROM orders
WHERE status != 'cancelled'
GROUP BY month
HAVING SUM(total) > AVG(SUM(total)) OVER ();
```

---

## Phase 4.4: Mastering Subqueries

### The Target
Use subqueries for complex filtering and derived tables.

### The Concept
Subqueries are queries within queries—like a tool inside a toolbox. They allow you to filter based on aggregated values or create derived tables for more complex analysis. Think of them as asking a question to help answer a bigger question.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Subquery in WHERE (Scalar subquery)
-- Find products priced above average
SELECT 
    id, name, price, stock_quantity
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- Find users who have never placed an order
SELECT 
    id, email, first_name, last_name
FROM users
WHERE id NOT IN (
    SELECT DISTINCT user_id FROM orders
)
AND is_active = true;

-- 2. Subquery with IN
-- Find orders from users who signed up in the last 3 months
SELECT 
    id, total, created_at, user_id
FROM orders
WHERE user_id IN (
    SELECT id 
    FROM users 
    WHERE created_at > NOW() - INTERVAL '3 months'
)
ORDER BY created_at DESC;

-- 3. Subquery in SELECT (Scalar subquery)
-- Get each order with the average order value
SELECT 
    id,
    user_id,
    total,
    (SELECT AVG(total) FROM orders) AS overall_avg,
    total - (SELECT AVG(total) FROM orders) AS diff_from_avg
FROM orders
WHERE status != 'cancelled'
ORDER BY diff_from_avg DESC;

-- 4. Correlated Subquery
-- Products that have never been ordered
SELECT 
    id, name, price
FROM products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM order_items oi 
    WHERE oi.product_id = p.id
)
AND is_active = true;

-- Users with their order count (correlated subquery)
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) AS order_count,
    (SELECT COALESCE(SUM(total), 0) FROM orders o WHERE o.user_id = u.id AND o.status != 'cancelled') AS total_spent
FROM users u
WHERE u.is_active = true
ORDER BY total_spent DESC;

-- 5. Subquery in FROM (Derived Table)
-- Find the top 3 products in each category
WITH ranked_products AS (
    SELECT 
        p.id,
        p.name,
        c.name AS category,
        SUM(oi.quantity) AS total_sold,
        ROW_NUMBER() OVER (PARTITION BY c.id ORDER BY SUM(oi.quantity) DESC) AS rank
    FROM products p
    JOIN product_categories pc ON pc.product_id = p.id
    JOIN categories c ON c.id = pc.category_id
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    GROUP BY p.id, p.name, c.id, c.name
)
SELECT 
    category,
    name AS product,
    total_sold,
    rank
FROM ranked_products
WHERE rank <= 3
ORDER BY category, rank;

-- 6. Subquery with ANY/ALL
-- Products more expensive than at least one product in the 'Audio' category
SELECT 
    id, name, price
FROM products
WHERE price > ANY (
    SELECT p.price
    FROM products p
    JOIN product_categories pc ON pc.product_id = p.id
    JOIN categories c ON c.id = pc.category_id
    WHERE c.slug = 'audio'
)
AND is_active = true
ORDER BY price;

-- 7. Complex subquery for analysis
-- Customer lifetime value vs. their first order size
SELECT 
    u.email,
    first_order.first_order_value,
    customer_lifetime.total_spent,
    customer_lifetime.total_spent / NULLIF(first_order.first_order_value, 0) AS lifetime_multiplier
FROM users u
JOIN (
    -- First order value
    SELECT 
        o.user_id,
        MIN(o.created_at) AS first_order_date,
        SUM(o.total) AS first_order_value
    FROM orders o
    WHERE o.status != 'cancelled'
    GROUP BY o.user_id
) first_order ON first_order.user_id = u.id
JOIN (
    -- Lifetime value
    SELECT 
        o.user_id,
        SUM(o.total) AS total_spent
    FROM orders o
    WHERE o.status != 'cancelled'
    GROUP BY o.user_id
) customer_lifetime ON customer_lifetime.user_id = u.id
WHERE customer_lifetime.total_spent > 0
ORDER BY lifetime_multiplier DESC;
```

### The Verification

```bash
# Test subquery examples

# Products above average price
psql -d ecommerce -c "
SELECT name, price 
FROM products 
WHERE price > (SELECT AVG(price) FROM products);"

# Users with no orders
psql -d ecommerce -c "
SELECT email 
FROM users 
WHERE id NOT IN (SELECT DISTINCT user_id FROM orders);"

# Monthly revenue with running total
psql -d ecommerce -c "
WITH monthly AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        SUM(total) AS revenue
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY month
)
SELECT 
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;"
```

---

## Phase 4.5: Conditional Logic with CASE WHEN

### The Target
Use `CASE WHEN` to implement conditional logic in SQL.

### The Concept
`CASE WHEN` is SQL's if-then-else statement. It allows you to create new values based on conditions—like categorizing orders by size, creating flags, or handling NULL values. Think of it as a decision tree within your query.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Simple CASE for categorization
-- Categorize products by price
SELECT 
    name,
    price,
    CASE 
        WHEN price < 20 THEN 'Budget'
        WHEN price < 50 THEN 'Economy'
        WHEN price < 100 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_tier
FROM products
WHERE is_active = true
ORDER BY price;

-- 2. CASE for status mapping
-- Order status with user-friendly labels
SELECT 
    id,
    user_id,
    total,
    created_at,
    CASE status
        WHEN 'pending' THEN 'Awaiting Payment'
        WHEN 'paid' THEN 'Payment Confirmed'
        WHEN 'shipped' THEN 'On the Way'
        WHEN 'delivered' THEN 'Delivered'
        WHEN 'cancelled' THEN 'Cancelled'
        ELSE 'Unknown Status'
    END AS status_label
FROM orders
ORDER BY created_at DESC
LIMIT 20;

-- 3. CASE in aggregations
-- Sales report with categorized orders
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN status != 'cancelled' THEN total ELSE 0 END) AS revenue,
    SUM(CASE WHEN total < 50 THEN 1 ELSE 0 END) AS small_orders,
    SUM(CASE WHEN total BETWEEN 50 AND 200 THEN 1 ELSE 0 END) AS medium_orders,
    SUM(CASE WHEN total > 200 THEN 1 ELSE 0 END) AS large_orders
FROM orders
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- 4. CASE for handling NULL values
-- Products with stock status
SELECT 
    name,
    stock_quantity,
    CASE 
        WHEN stock_quantity IS NULL THEN 'Unknown Stock'
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity < 10 THEN 'Low Stock'
        WHEN stock_quantity < 50 THEN 'In Stock'
        ELSE 'Well Stocked'
    END AS stock_status,
    CASE 
        WHEN is_active THEN 'Active'
        ELSE 'Inactive'
    END AS product_status
FROM products
ORDER BY stock_quantity NULLS LAST;

-- 5. CASE for customer segmentation
-- Customer segments based on purchasing behavior
WITH customer_metrics AS (
    SELECT 
        u.id,
        u.email,
        COUNT(o.id) AS order_count,
        COALESCE(SUM(o.total), 0) AS total_spent,
        MAX(o.created_at) AS last_order_date
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    GROUP BY u.id, u.email
)
SELECT 
    email,
    order_count,
    total_spent,
    CASE 
        WHEN order_count = 0 THEN 'Inactive'
        WHEN order_count = 1 AND total_spent < 100 THEN 'New Shopper'
        WHEN order_count = 1 AND total_spent >= 100 THEN 'First-Time Big Spender'
        WHEN order_count BETWEEN 2 AND 5 AND total_spent < 500 THEN 'Regular Shopper'
        WHEN order_count BETWEEN 2 AND 5 AND total_spent >= 500 THEN 'Loyal Customer'
        WHEN order_count > 5 AND total_spent < 1000 THEN 'Frequent Shopper'
        WHEN order_count > 5 AND total_spent >= 1000 THEN 'VIP Customer'
        ELSE 'High-Value Customer'
    END AS customer_segment,
    CASE 
        WHEN last_order_date > NOW() - INTERVAL '30 days' THEN 'Active'
        WHEN last_order_date > NOW() - INTERVAL '90 days' THEN 'Recent'
        ELSE 'Inactive'
    END AS activity_status
FROM customer_metrics
ORDER BY total_spent DESC;

-- 6. CASE in ORDER BY
-- Custom sorting (prioritize high-value active customers)
SELECT 
    id, email, first_name, last_name, created_at
FROM users
ORDER BY 
    CASE 
        WHEN is_active = false THEN 1
        ELSE 0
    END,
    CASE 
        WHEN email LIKE '%admin%' THEN 0
        ELSE 1
    END,
    created_at DESC;

-- 7. Nested CASE for complex logic
-- Product recommendations based on categories and price
SELECT 
    p.name,
    p.price,
    array_agg(c.name) AS categories,
    CASE 
        WHEN p.price > 100 AND 'electronics' = ANY(array_agg(c.slug)) THEN 'Premium Electronics'
        WHEN p.price > 50 AND 'electronics' = ANY(array_agg(c.slug)) THEN 'Mid-Range Electronics'
        WHEN p.price <= 50 AND 'electronics' = ANY(array_agg(c.slug)) THEN 'Budget Electronics'
        WHEN p.price > 50 AND 'home-kitchen' = ANY(array_agg(c.slug)) THEN 'Premium Home Goods'
        WHEN p.price <= 50 AND 'home-kitchen' = ANY(array_agg(c.slug)) THEN 'Budget Home Goods'
        ELSE 'General Merchandise'
    END AS product_category_tier
FROM products p
LEFT JOIN product_categories pc ON pc.product_id = p.id
LEFT JOIN categories c ON c.id = pc.category_id
WHERE p.is_active = true
GROUP BY p.id, p.name, p.price
HAVING array_agg(c.name) IS NOT NULL
ORDER BY p.price DESC;
```

### The Verification

```bash
# Test CASE queries

# Price tier distribution
psql -d ecommerce -c "
SELECT 
    CASE 
        WHEN price < 20 THEN 'Budget'
        WHEN price < 50 THEN 'Economy'
        ELSE 'Premium'
    END AS tier,
    COUNT(*) AS count,
    AVG(price) AS avg_price
FROM products
GROUP BY tier;"

# Order status summary
psql -d ecommerce -c "
SELECT 
    status,
    COUNT(*) AS count,
    SUM(total) AS total_revenue
FROM orders
GROUP BY status;"

# Customer segmentation
psql -d ecommerce -c "
WITH customer_metrics AS (
    SELECT 
        u.id,
        COUNT(o.id) AS order_count,
        COALESCE(SUM(o.total), 0) AS total_spent
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    GROUP BY u.id
)
SELECT 
    CASE 
        WHEN order_count = 0 THEN 'No Orders'
        WHEN order_count < 3 THEN 'Few Orders'
        ELSE 'Many Orders'
    END AS segment,
    COUNT(*) AS customers,
    SUM(total_spent) AS total_revenue
FROM customer_metrics
GROUP BY segment;"
```

---

## Phase 4.6: Building Sales Reports

### The Target
Create comprehensive sales reports combining all the concepts we've learned.

### The Concept
Now we'll synthesize everything into real business reports. These are the kinds of queries that power dashboards and help businesses make decisions. We'll build reports for revenue, customer analysis, product performance, and inventory.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- 1. Executive Dashboard - Key Metrics
SELECT 
    (SELECT COUNT(*) FROM users WHERE is_active = true) AS active_customers,
    (SELECT COUNT(*) FROM orders WHERE status != 'cancelled') AS total_orders,
    (SELECT COALESCE(SUM(total), 0) FROM orders WHERE status != 'cancelled') AS total_revenue,
    (SELECT AVG(total) FROM orders WHERE status != 'cancelled') AS avg_order_value,
    (SELECT COUNT(*) FROM products WHERE is_active = true) AS active_products,
    (SELECT SUM(stock_quantity) FROM products WHERE is_active = true) AS total_inventory;

-- 2. Monthly Revenue Report with Trends
WITH monthly_data AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        COUNT(*) AS orders,
        SUM(total) AS revenue,
        SUM(CASE WHEN status = 'cancelled' THEN total ELSE 0 END) AS cancelled_revenue,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_orders
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT 
    month,
    orders,
    revenue,
    cancelled_orders,
    cancelled_revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS revenue_change,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100)::NUMERIC, 2) AS revenue_growth_pct,
    ROUND((revenue / NULLIF(SUM(revenue) OVER (ORDER BY month), 0) * 100)::NUMERIC, 2) AS revenue_percentage_of_total
FROM monthly_data
ORDER BY month DESC;

-- 3. Top Customers Report
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent,
    AVG(o.total) AS avg_order_value,
    MIN(o.created_at) AS first_order,
    MAX(o.created_at) AS last_order,
    EXTRACT(DAY FROM NOW() - MAX(o.created_at)) AS days_since_last_order,
    SUM(oi.quantity) AS total_items_purchased,
    COUNT(DISTINCT oi.product_id) AS unique_products_purchased
FROM users u
JOIN orders o ON o.user_id = u.id
JOIN order_items oi ON oi.order_id = o.id
WHERE o.status != 'cancelled'
GROUP BY u.id, u.email, u.first_name, u.last_name
HAVING COUNT(o.id) > 0
ORDER BY total_spent DESC
LIMIT 10;

-- 4. Product Performance Report
WITH product_sales AS (
    SELECT 
        p.id,
        p.name,
        p.price AS current_price,
        COUNT(DISTINCT oi.order_id) AS times_ordered,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.total_price) AS revenue,
        AVG(oi.unit_price) AS avg_sale_price,
        COUNT(DISTINCT o.user_id) AS unique_customers,
        MAX(o.created_at) AS last_sold_date
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
    WHERE p.is_active = true
    GROUP BY p.id, p.name, p.price
)
SELECT 
    name,
    current_price,
    COALESCE(units_sold, 0) AS units_sold,
    COALESCE(revenue, 0) AS revenue,
    COALESCE(times_ordered, 0) AS times_ordered,
    COALESCE(unique_customers, 0) AS unique_customers,
    CASE 
        WHEN COALESCE(times_ordered, 0) > 0 THEN 
            ROUND((COALESCE(revenue, 0) / times_ordered)::NUMERIC, 2)
        ELSE 0
    END AS revenue_per_order,
    CASE 
        WHEN COALESCE(revenue, 0) > 0 AND current_price > 0 THEN
            ROUND(((COALESCE(revenue, 0) / current_price) - 1) * 100, 2)
        ELSE 0
    END AS price_premium_pct,
    CASE 
        WHEN last_sold_date IS NULL THEN 'Never Sold'
        WHEN last_sold_date > NOW() - INTERVAL '7 days' THEN 'Selling Now'
        WHEN last_sold_date > NOW() - INTERVAL '30 days' THEN 'Recent'
        ELSE 'Inactive'
    END AS sales_status
FROM product_sales
ORDER BY revenue DESC NULLS LAST;

-- 5. Inventory Health Report
SELECT 
    p.name,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'No Sales'
        WHEN p.stock_quantity < 10 THEN 'Critical Stock'
        WHEN p.stock_quantity < 50 THEN 'Low Stock'
        WHEN p.stock_quantity > 500 THEN 'Overstocked'
        ELSE 'Healthy Stock'
    END AS inventory_status,
    CASE 
        WHEN COALESCE(SUM(oi.quantity), 0) > 0 AND p.stock_quantity > 0 THEN
            ROUND((p.stock_quantity / COALESCE(SUM(oi.quantity), 1))::NUMERIC, 2)
        ELSE NULL
    END AS months_of_inventory,
    COALESCE(MAX(o.created_at), NULL) AS last_sale_date
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
WHERE p.is_active = true
GROUP BY p.id, p.name, p.stock_quantity
ORDER BY p.stock_quantity ASC;

-- 6. Category Performance Report
SELECT 
    c.name AS category,
    COUNT(DISTINCT p.id) AS product_count,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS revenue,
    ROUND(AVG(oi.unit_price)::NUMERIC, 2) AS avg_sale_price,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(oi.total_price) / NULLIF(COUNT(DISTINCT o.user_id), 0) AS revenue_per_customer,
    ROUND((SUM(oi.total_price) / NULLIF((SELECT SUM(total) FROM orders WHERE status != 'cancelled'), 0) * 100)::NUMERIC, 2) AS pct_of_total_revenue
FROM categories c
JOIN product_categories pc ON pc.category_id = c.id
JOIN products p ON p.id = pc.product_id
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
GROUP BY c.id, c.name
HAVING COUNT(DISTINCT oi.order_id) > 0
ORDER BY revenue DESC;

-- 7. Customer Retention Analysis
WITH customer_orders AS (
    SELECT 
        user_id,
        created_at,
        total,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_number
    FROM orders
    WHERE status != 'cancelled'
),
first_orders AS (
    SELECT 
        user_id,
        created_at AS first_order_date,
        total AS first_order_value
    FROM customer_orders
    WHERE order_number = 1
),
repeat_orders AS (
    SELECT 
        user_id,
        COUNT(*) AS repeat_count,
        SUM(total) AS repeat_revenue
    FROM customer_orders
    WHERE order_number > 1
    GROUP BY user_id
)
SELECT 
    COUNT(DISTINCT fo.user_id) AS total_customers,
    COUNT(DISTINCT ro.user_id) AS repeat_customers,
    ROUND((COUNT(DISTINCT ro.user_id) / COUNT(DISTINCT fo.user_id) * 100)::NUMERIC, 2) AS repeat_rate,
    SUM(fo.first_order_value) AS first_order_revenue,
    COALESCE(SUM(ro.repeat_revenue), 0) AS repeat_revenue,
    COALESCE(SUM(ro.repeat_revenue) / NULLIF(SUM(fo.first_order_value), 0) * 100, 0) AS repeat_revenue_pct
FROM first_orders fo
LEFT JOIN repeat_orders ro ON ro.user_id = fo.user_id;
```

### The Verification

```bash
# Generate the executive dashboard
psql -d ecommerce -c "
SELECT 
    (SELECT COUNT(*) FROM users WHERE is_active = true) AS active_customers,
    (SELECT COUNT(*) FROM orders WHERE status != 'cancelled') AS total_orders,
    (SELECT COALESCE(SUM(total), 0) FROM orders WHERE status != 'cancelled') AS total_revenue;"

# View top customers
psql -d ecommerce -c "
SELECT u.email, COUNT(o.id) AS orders, SUM(o.total) AS spent
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE o.status != 'cancelled'
GROUP BY u.email
ORDER BY spent DESC
LIMIT 5;"

# Check inventory health
psql -d ecommerce -c "
SELECT 
    name,
    stock_quantity,
    CASE 
        WHEN stock_quantity < 10 THEN 'CRITICAL'
        WHEN stock_quantity < 50 THEN 'LOW'
        ELSE 'OK'
    END AS status
FROM products
WHERE is_active = true
ORDER BY stock_quantity
LIMIT 10;"
```

---

## Phase 4.7: Complete Analysis Script

### The Target
Create a comprehensive analysis script that generates all reports.

### The Concept
We'll compile all our report queries into a single script file. This makes it easy to generate fresh reports as new data comes in. Think of it as your business intelligence toolkit.

### The Implementation

Create a file called `04_analysis_reports.sql`:

```sql
-- 04_analysis_reports.sql
-- Complete business intelligence and analytics queries

\c ecommerce

-- ============================================================
-- SECTION 1: Executive Dashboard
-- ============================================================
SELECT '=== EXECUTIVE DASHBOARD ===' AS section;

SELECT 
    'Active Customers' AS metric,
    COUNT(*) AS value
FROM users WHERE is_active = true
UNION ALL
SELECT 
    'Total Orders',
    COUNT(*) 
FROM orders WHERE status != 'cancelled'
UNION ALL
SELECT 
    'Total Revenue',
    COALESCE(SUM(total), 0)::TEXT
FROM orders WHERE status != 'cancelled'
UNION ALL
SELECT 
    'Average Order Value',
    COALESCE(AVG(total), 0)::TEXT
FROM orders WHERE status != 'cancelled'
UNION ALL
SELECT 
    'Active Products',
    COUNT(*)::TEXT
FROM products WHERE is_active = true
UNION ALL
SELECT 
    'Total Inventory',
    COALESCE(SUM(stock_quantity), 0)::TEXT
FROM products WHERE is_active = true;

-- ============================================================
-- SECTION 2: Monthly Revenue Report
-- ============================================================
SELECT '=== MONTHLY REVENUE REPORT ===' AS section;

WITH monthly_data AS (
    SELECT 
        DATE_TRUNC('month', created_at) AS month,
        COUNT(*) AS orders,
        SUM(total) AS revenue,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_orders
    FROM orders
    GROUP BY DATE_TRUNC('month', created_at)
)
SELECT 
    month::DATE,
    orders,
    ROUND(revenue::NUMERIC, 2) AS revenue,
    cancelled_orders,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month))::NUMERIC, 2) AS revenue_change,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100)::NUMERIC, 2) AS growth_pct
FROM monthly_data
ORDER BY month DESC;

-- ============================================================
-- SECTION 3: Top Products by Revenue
-- ============================================================
SELECT '=== TOP PRODUCTS BY REVENUE ===' AS section;

SELECT 
    p.name AS product,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.total_price), 0) AS revenue,
    p.stock_quantity
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
WHERE p.is_active = true
GROUP BY p.id, p.name, p.stock_quantity
HAVING COALESCE(SUM(oi.total_price), 0) > 0
ORDER BY revenue DESC
LIMIT 10;

-- ============================================================
-- SECTION 4: Customer Segmentation
-- ============================================================
SELECT '=== CUSTOMER SEGMENTATION ===' AS section;

WITH customer_metrics AS (
    SELECT 
        u.id,
        u.email,
        COUNT(o.id) AS order_count,
        COALESCE(SUM(o.total), 0) AS total_spent,
        MAX(o.created_at) AS last_order_date
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id AND o.status != 'cancelled'
    GROUP BY u.id, u.email
)
SELECT 
    CASE 
        WHEN order_count = 0 THEN 'No Orders'
        WHEN order_count = 1 AND total_spent < 100 THEN 'New Shopper'
        WHEN order_count = 1 AND total_spent >= 100 THEN 'Big First Order'
        WHEN order_count BETWEEN 2 AND 5 AND total_spent < 500 THEN 'Regular'
        WHEN order_count BETWEEN 2 AND 5 AND total_spent >= 500 THEN 'Loyal'
        WHEN order_count > 5 AND total_spent < 1000 THEN 'Frequent'
        ELSE 'VIP'
    END AS segment,
    COUNT(*) AS customers,
    SUM(total_spent) AS total_revenue,
    AVG(total_spent) AS avg_spent
FROM customer_metrics
GROUP BY segment
ORDER BY total_revenue DESC;

-- ============================================================
-- SECTION 5: Category Performance
-- ============================================================
SELECT '=== CATEGORY PERFORMANCE ===' AS section;

SELECT 
    c.name AS category,
    COUNT(DISTINCT p.id) AS products,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.total_price), 0) AS revenue,
    ROUND((COALESCE(SUM(oi.total_price), 0) / NULLIF((SELECT SUM(total) FROM orders WHERE status != 'cancelled'), 0) * 100)::NUMERIC, 2) AS revenue_share_pct
FROM categories c
JOIN product_categories pc ON pc.category_id = c.id
JOIN products p ON p.id = pc.product_id
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
GROUP BY c.id, c.name
HAVING COALESCE(SUM(oi.total_price), 0) > 0
ORDER BY revenue DESC;

-- ============================================================
-- SECTION 6: Inventory Alert Report
-- ============================================================
SELECT '=== INVENTORY ALERT REPORT ===' AS section;

SELECT 
    name AS product,
    stock_quantity,
    CASE 
        WHEN stock_quantity = 0 THEN 'OUT OF STOCK'
        WHEN stock_quantity < 10 THEN 'CRITICAL'
        WHEN stock_quantity < 50 THEN 'LOW'
        ELSE 'OK'
    END AS alert_level,
    COALESCE(SUM(oi.quantity), 0) AS total_sold
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id AND o.status != 'cancelled'
WHERE p.is_active = true
GROUP BY p.id, p.name, p.stock_quantity
HAVING p.stock_quantity < 50 OR COALESCE(SUM(oi.quantity), 0) = 0
ORDER BY p.stock_quantity;

-- ============================================================
-- SECTION 7: Report Summary
-- ============================================================
SELECT '=== REPORT GENERATED SUCCESSFULLY ===' AS status;
SELECT NOW() AS report_generated_at;
```

Run the script:

```bash
# Generate all reports
psql -d ecommerce -U ecommerce_user -f 04_analysis_reports.sql

# Or output to a file
psql -d ecommerce -U ecommerce_user -f 04_analysis_reports.sql > reports_$(date +%Y%m%d).txt

# View the summary
psql -d ecommerce -U ecommerce_user -f 04_analysis_reports.sql | tail -10
```

### The Verification

```bash
# Check that the report script runs without errors
psql -d ecommerce -c "\i 04_analysis_reports.sql"

# Verify report data exists
psql -d ecommerce -c "SELECT COUNT(*) FROM orders WHERE status != 'cancelled';"
psql -d ecommerce -c "SELECT COUNT(*) FROM users WHERE is_active = true;"
```

---

## Summary: What You've Accomplished

You've transformed your e-commerce database into a powerful analytics engine:

✅ Mastered all five aggregate functions (COUNT, SUM, AVG, MIN, MAX)  
✅ Grouped data with GROUP BY for segmentation  
✅ Filtered groups with HAVING for precise analysis  
✅ Used subqueries for complex filtering and derived tables  
✅ Implemented CASE WHEN for conditional logic  
✅ Built comprehensive sales reports and dashboards  
✅ Created reusable analysis scripts  

## What's Next

In **Part 5**, we'll explore modern PostgreSQL features: JSONB for flexible data storage and window functions for advanced analytics like running totals and rankings.

**Before Part 5**, practice these skills:
1. Calculate the average revenue per customer
2. Find the most popular product by units sold
3. Create a report showing monthly revenue growth
4. Segment products by price tier with CASE
5. Write a query to find the top 5 customers by order count

*Ready for Part 5? We'll unlock PostgreSQL's modern features: JSONB for flexible data storage and window functions for sophisticated analytics. You'll learn to store semi-structured data and calculate running totals, rankings, and moving averages without losing detail.*
