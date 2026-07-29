# Serverless Postgres with Neon: From Zero to Production

## Part 4: Analytical Power: Aggregations & Window Functions

### The Target

In this part, we'll:
1. Master aggregate functions: `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`
2. Group and segment data with `GROUP BY`
3. Filter grouped data with `HAVING`
4. Learn advanced window functions: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LEAD()`, `LAG()`
5. Use `PARTITION BY` for grouped window operations
6. Write conditional logic with `CASE WHEN`
7. Build comprehensive business intelligence reports

By the end of this part, you'll be able to generate real-time sales analytics, customer insights, and inventory reports directly from your Neon database.

---

### The Concept: Your Data as a Story

Imagine you're a store manager looking at a pile of sales receipts. Aggregations are like asking:
- "How many items did we sell today?" (COUNT)
- "What's our total revenue?" (SUM)
- "What's the average purchase amount?" (AVG)
- "What's the most expensive item sold?" (MAX)

Window functions are like looking at each receipt while also seeing the running total, ranking, or comparison to previous sales. They let you see individual records AND their context within the larger dataset.

Think of it this way:
- **Aggregates**: Summarize the whole story into a single number
- **Window functions**: Show each page of the story while keeping the context of the entire book

---

### Implementation Step 1: Basic Aggregations

#### 1.1 COUNT - Counting Records

```sql
-- Count all products
SELECT COUNT(*) AS total_products FROM products;

-- Count products with stock (excluding zero or null)
SELECT COUNT(stock_quantity) AS products_with_stock 
FROM products 
WHERE stock_quantity > 0;

-- Count distinct values
SELECT 
    COUNT(DISTINCT role) AS distinct_roles,
    COUNT(DISTINCT status) AS distinct_statuses
FROM users;

-- Count orders by status
SELECT 
    status,
    COUNT(*) AS order_count
FROM orders
WHERE deleted_at IS NULL
GROUP BY status
ORDER BY order_count DESC;
```

**The Verification**: You should see actual counts for your data. The distinct roles should be 3 (admin, staff, customer).

#### 1.2 SUM - Adding Values

```sql
-- Total revenue from all orders
SELECT 
    SUM(total) AS total_revenue,
    SUM(tax) AS total_tax_collected,
    SUM(shipping_cost) AS total_shipping_revenue
FROM orders
WHERE status NOT IN ('cancelled', 'refunded');

-- Revenue by payment method
SELECT 
    payment_method,
    COUNT(*) AS order_count,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order_value
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Sum of quantities sold per product
SELECT 
    p.name,
    SUM(oi.quantity) AS total_sold
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 10;
```

#### 1.3 AVG, MIN, MAX - Statistical Analysis

```sql
-- Overall order statistics
SELECT 
    COUNT(*) AS total_orders,
    MIN(total) AS min_order_value,
    MAX(total) AS max_order_value,
    AVG(total) AS avg_order_value,
    SUM(total) AS total_revenue,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median_order_value
FROM orders
WHERE status NOT IN ('cancelled', 'refunded');

-- Price analysis by product category (if we had categories)
-- For now, we'll just analyze all products
SELECT 
    MIN(price) AS cheapest,
    MAX(price) AS most_expensive,
    AVG(price) AS average_price,
    STDDEV(price) AS price_standard_deviation,
    VARIANCE(price) AS price_variance
FROM products;

-- Customer order behavior
SELECT 
    u.full_name,
    COUNT(o.id) AS order_count,
    MIN(o.total) AS min_order,
    MAX(o.total) AS max_order,
    AVG(o.total) AS avg_order,
    SUM(o.total) AS lifetime_value
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
HAVING COUNT(o.id) > 0
ORDER BY lifetime_value DESC;
```

---

### Implementation Step 2: Grouping Data with GROUP BY

#### 2.1 Simple GROUP BY

```sql
-- Orders by status (count and revenue)
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total) AS revenue,
    AVG(total) AS average_order,
    MIN(total) AS min_order,
    MAX(total) AS max_order
FROM orders
WHERE deleted_at IS NULL
GROUP BY status
ORDER BY revenue DESC NULLS LAST;

-- Sales by month
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    COUNT(DISTINCT user_id) AS unique_customers
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

-- Sales by day of week
SELECT 
    EXTRACT(DOW FROM order_date) AS day_of_week,
    CASE EXTRACT(DOW FROM order_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY EXTRACT(DOW FROM order_date)
ORDER BY day_of_week;
```

#### 2.2 GROUP BY with Multiple Columns

```sql
-- Revenue by payment method and status
SELECT 
    payment_method,
    status,
    COUNT(*) AS count,
    SUM(total) AS revenue,
    AVG(total) AS avg_value
FROM orders
WHERE deleted_at IS NULL
GROUP BY payment_method, status
ORDER BY payment_method, status;

-- Sales by month and payment method
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    payment_method,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY DATE_TRUNC('month', order_date), payment_method
ORDER BY month DESC, revenue DESC;
```

---

### Implementation Step 3: Filtering Groups with HAVING

HAVING is like WHERE but for groups (it filters after GROUP BY).

#### 3.1 Basic HAVING Examples

```sql
-- Customers with more than 2 orders
SELECT 
    u.full_name,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
HAVING COUNT(o.id) > 2
ORDER BY total_spent DESC;

-- Products that have generated more than $500 in revenue
SELECT 
    p.name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS revenue
FROM products p
INNER JOIN order_items oi ON p.id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY p.id, p.name
HAVING SUM(oi.line_total) > 500
ORDER BY revenue DESC;

-- Months with more than 5 orders
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY DATE_TRUNC('month', order_date)
HAVING COUNT(*) > 5
ORDER BY month DESC;
```

#### 3.2 Complex HAVING Conditions

```sql
-- Payment methods that process at least 3 orders with average > $100
SELECT 
    payment_method,
    COUNT(*) AS order_count,
    AVG(total) AS avg_value,
    SUM(total) AS total_revenue,
    MIN(total) AS min_order,
    MAX(total) AS max_order
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY payment_method
HAVING COUNT(*) >= 3 
   AND AVG(total) > 100
ORDER BY total_revenue DESC;

-- Customers with high average order value and at least 2 orders
SELECT 
    u.id,
    u.full_name,
    COUNT(o.id) AS order_count,
    AVG(o.total) AS avg_order_value,
    SUM(o.total) AS total_spent,
    MAX(o.total) AS largest_order
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
HAVING COUNT(o.id) >= 2 
   AND AVG(o.total) > 100
ORDER BY avg_order_value DESC;
```

---

### Implementation Step 4: Window Functions Fundamentals

Window functions perform calculations across a set of rows related to the current row, without collapsing them into a single result.

#### 4.1 ROW_NUMBER - Sequential Numbering

```sql
-- Number orders chronologically by customer
SELECT 
    u.full_name,
    o.order_number,
    o.total,
    o.order_date,
    ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.order_date) AS order_sequence
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
ORDER BY u.full_name, o.order_date;

-- Find the most recent order for each customer
WITH ordered_orders AS (
    SELECT 
        u.id AS user_id,
        u.full_name,
        o.id AS order_id,
        o.order_number,
        o.total,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.order_date DESC) AS rn
    FROM users u
    INNER JOIN orders o ON u.id = o.user_id
    WHERE o.status NOT IN ('cancelled', 'refunded')
      AND o.deleted_at IS NULL
)
SELECT 
    full_name,
    order_number,
    total,
    order_date
FROM ordered_orders
WHERE rn = 1
ORDER BY order_date DESC;
```

#### 4.2 RANK and DENSE_RANK - Competition Rankings

```sql
-- Rank customers by total spending (with ties)
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total) DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY SUM(o.total) DESC) AS dense_rank,
    ROW_NUMBER() OVER (ORDER BY SUM(o.total) DESC) AS row_number
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
HAVING SUM(o.total) > 0
ORDER BY total_spent DESC;

-- Rank products by units sold within each price range
SELECT 
    p.name,
    p.price,
    SUM(oi.quantity) AS units_sold,
    NTILE(4) OVER (ORDER BY p.price) AS price_quartile,
    RANK() OVER (PARTITION BY NTILE(4) OVER (ORDER BY p.price) ORDER BY SUM(oi.quantity) DESC) AS rank_in_quartile
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id 
    AND o.status NOT IN ('cancelled', 'refunded')
    AND o.deleted_at IS NULL
GROUP BY p.id, p.name, p.price
ORDER BY p.price, units_sold DESC;
```

#### 4.3 LAG and LEAD - Looking Forward and Backward

```sql
-- Month-over-month revenue comparison
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total) AS revenue
    FROM orders
    WHERE status NOT IN ('cancelled', 'refunded')
      AND deleted_at IS NULL
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) AS previous_month_revenue,
    LEAD(revenue, 1) OVER (ORDER BY month) AS next_month_revenue,
    revenue - LAG(revenue, 1) OVER (ORDER BY month) AS month_over_month_change,
    CASE 
        WHEN LAG(revenue, 1) OVER (ORDER BY month) IS NOT NULL 
        THEN ((revenue - LAG(revenue, 1) OVER (ORDER BY month)) / LAG(revenue, 1) OVER (ORDER BY month)) * 100
        ELSE NULL 
    END AS growth_percentage
FROM monthly_revenue
ORDER BY month DESC;

-- Compare each order to customer's previous order
SELECT 
    u.full_name,
    o.order_number,
    o.total,
    o.order_date,
    LAG(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date) AS previous_order_value,
    LAG(o.order_date) OVER (PARTITION BY u.id ORDER BY o.order_date) AS previous_order_date,
    o.total - LAG(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date) AS order_value_change,
    o.order_date - LAG(o.order_date) OVER (PARTITION BY u.id ORDER BY o.order_date) AS days_since_last_order
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
ORDER BY u.full_name, o.order_date;
```

---

### Implementation Step 5: Advanced Window Functions

#### 5.1 Running Totals and Moving Averages

```sql
-- Running total of orders (cumulative revenue)
SELECT 
    order_date,
    order_number,
    total,
    SUM(total) OVER (ORDER BY order_date) AS running_total,
    AVG(total) OVER (ORDER BY order_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg_5_orders
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
ORDER BY order_date;

-- Customer lifetime value with running total per customer
SELECT 
    u.full_name,
    o.order_date,
    o.order_number,
    o.total,
    SUM(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date) AS customer_lifetime_value,
    AVG(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date) AS customer_running_avg
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
ORDER BY u.full_name, o.order_date;
```

#### 5.2 Percentiles and Distribution

```sql
-- Percentile analysis of orders
SELECT 
    total,
    NTILE(100) OVER (ORDER BY total) AS percentile_rank,
    CUME_DIST() OVER (ORDER BY total) AS cumulative_distribution,
    PERCENT_RANK() OVER (ORDER BY total) AS percent_rank
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
ORDER BY total
LIMIT 10;

-- Customer spending percentiles
WITH customer_spending AS (
    SELECT 
        u.id,
        u.full_name,
        SUM(o.total) AS total_spent
    FROM users u
    INNER JOIN orders o ON u.id = o.user_id
    WHERE o.status NOT IN ('cancelled', 'refunded')
      AND o.deleted_at IS NULL
    GROUP BY u.id, u.full_name
)
SELECT 
    full_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent) AS quartile,
    NTILE(10) OVER (ORDER BY total_spent) AS decile,
    CUME_DIST() OVER (ORDER BY total_spent) AS percentile
FROM customer_spending
ORDER BY total_spent DESC;
```

#### 5.3 First and Last Values

```sql
-- First and last order for each customer
SELECT DISTINCT
    u.full_name,
    FIRST_VALUE(o.order_number) OVER (PARTITION BY u.id ORDER BY o.order_date) AS first_order,
    FIRST_VALUE(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date) AS first_order_value,
    FIRST_VALUE(o.order_date) OVER (PARTITION BY u.id ORDER BY o.order_date) AS first_order_date,
    LAST_VALUE(o.order_number) OVER (PARTITION BY u.id ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order,
    LAST_VALUE(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order_value,
    LAST_VALUE(o.order_date) OVER (PARTITION BY u.id ORDER BY o.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order_date
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
ORDER BY u.full_name;
```

---

### Implementation Step 6: CASE WHEN - Conditional Logic

#### 6.1 Simple CASE Statements

```sql
-- Categorize orders by value
SELECT 
    order_number,
    total,
    CASE 
        WHEN total < 100 THEN 'Small'
        WHEN total >= 100 AND total < 500 THEN 'Medium'
        WHEN total >= 500 AND total < 1000 THEN 'Large'
        WHEN total >= 1000 THEN 'XL'
    END AS order_size_category
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
ORDER BY total DESC;

-- Customer segmentation by total spend
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent,
    CASE 
        WHEN SUM(o.total) < 100 THEN 'Bronze'
        WHEN SUM(o.total) >= 100 AND SUM(o.total) < 500 THEN 'Silver'
        WHEN SUM(o.total) >= 500 AND SUM(o.total) < 1000 THEN 'Gold'
        WHEN SUM(o.total) >= 1000 THEN 'Platinum'
    END AS customer_tier
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

#### 6.2 Complex CASE Logic

```sql
-- Sales performance report with multiple conditions
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS total_orders,
    SUM(total) AS revenue,
    CASE 
        WHEN SUM(total) > 10000 THEN 'Excellent'
        WHEN SUM(total) > 5000 THEN 'Good'
        WHEN SUM(total) > 1000 THEN 'Average'
        ELSE 'Below Target'
    END AS performance_rating,
    CASE 
        WHEN COUNT(*) > 100 THEN 'High Volume'
        WHEN COUNT(*) > 50 THEN 'Medium Volume'
        ELSE 'Low Volume'
    END AS volume_category
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

-- Product performance analysis
SELECT 
    p.name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS revenue,
    CASE 
        WHEN SUM(oi.quantity) IS NULL OR SUM(oi.quantity) = 0 THEN 'Never Sold'
        WHEN SUM(oi.quantity) < 10 THEN 'Low Volume'
        WHEN SUM(oi.quantity) >= 10 AND SUM(oi.quantity) < 50 THEN 'Medium Volume'
        WHEN SUM(oi.quantity) >= 50 THEN 'High Volume'
    END AS sales_volume,
    CASE 
        WHEN SUM(oi.line_total) IS NULL OR SUM(oi.line_total) = 0 THEN 'No Revenue'
        WHEN SUM(oi.line_total) < 500 THEN 'Low Revenue'
        WHEN SUM(oi.line_total) >= 500 AND SUM(oi.line_total) < 2000 THEN 'Medium Revenue'
        WHEN SUM(oi.line_total) >= 2000 THEN 'High Revenue'
    END AS revenue_category
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id 
    AND o.status NOT IN ('cancelled', 'refunded')
    AND o.deleted_at IS NULL
GROUP BY p.id, p.name
ORDER BY revenue DESC NULLS LAST;
```

---

### Implementation Step 7: Building Comprehensive Reports

#### 7.1 Executive Dashboard Report

```sql
-- Executive summary dashboard
WITH current_metrics AS (
    SELECT 
        COUNT(*) AS total_orders,
        SUM(total) AS total_revenue,
        AVG(total) AS avg_order_value,
        COUNT(DISTINCT user_id) AS unique_customers
    FROM orders
    WHERE status NOT IN ('cancelled', 'refunded')
      AND deleted_at IS NULL
      AND order_date >= DATE_TRUNC('month', CURRENT_DATE)
),
previous_metrics AS (
    SELECT 
        COUNT(*) AS total_orders,
        SUM(total) AS total_revenue,
        AVG(total) AS avg_order_value,
        COUNT(DISTINCT user_id) AS unique_customers
    FROM orders
    WHERE status NOT IN ('cancelled', 'refunded')
      AND deleted_at IS NULL
      AND order_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
      AND order_date < DATE_TRUNC('month', CURRENT_DATE)
)
SELECT 
    'Monthly Report' AS report_type,
    c.total_orders AS current_orders,
    p.total_orders AS previous_orders,
    CASE 
        WHEN p.total_orders > 0 
        THEN ((c.total_orders - p.total_orders)::FLOAT / p.total_orders) * 100
        ELSE NULL 
    END AS order_growth_pct,
    c.total_revenue AS current_revenue,
    p.total_revenue AS previous_revenue,
    CASE 
        WHEN p.total_revenue > 0 
        THEN ((c.total_revenue - p.total_revenue)::FLOAT / p.total_revenue) * 100
        ELSE NULL 
    END AS revenue_growth_pct,
    c.avg_order_value AS current_avg_order,
    p.avg_order_value AS previous_avg_order,
    c.unique_customers AS current_customers,
    p.unique_customers AS previous_customers
FROM current_metrics c
CROSS JOIN previous_metrics p;
```

#### 7.2 Customer Analytics Report

```sql
-- Comprehensive customer analytics
WITH customer_metrics AS (
    SELECT 
        u.id,
        u.full_name,
        u.email,
        u.created_at AS signup_date,
        COUNT(DISTINCT o.id) AS order_count,
        COUNT(DISTINCT oi.id) AS item_count,
        SUM(o.total) AS total_spent,
        AVG(o.total) AS avg_order_value,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date,
        EXTRACT(DAY FROM (MAX(o.order_date) - MIN(o.order_date))) AS days_between_first_last,
        -- Customer tier based on total spend
        CASE 
            WHEN SUM(o.total) >= 1000 THEN 'Platinum'
            WHEN SUM(o.total) >= 500 THEN 'Gold'
            WHEN SUM(o.total) >= 100 THEN 'Silver'
            WHEN SUM(o.total) > 0 THEN 'Bronze'
            ELSE 'Prospect'
        END AS customer_tier
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id 
        AND o.status NOT IN ('cancelled', 'refunded')
        AND o.deleted_at IS NULL
    LEFT JOIN order_items oi ON o.id = oi.order_id AND oi.deleted_at IS NULL
    WHERE u.deleted_at IS NULL
    GROUP BY u.id, u.full_name, u.email, u.created_at
)
SELECT 
    customer_tier,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS total_revenue,
    AVG(total_spent) AS avg_lifetime_value,
    AVG(order_count) AS avg_order_count,
    AVG(avg_order_value) AS avg_order_value,
    SUM(order_count) AS total_orders,
    SUM(item_count) AS total_items_sold
FROM customer_metrics
GROUP BY customer_tier
ORDER BY 
    CASE customer_tier
        WHEN 'Platinum' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Bronze' THEN 4
        WHEN 'Prospect' THEN 5
    END;
```

#### 7.3 Inventory Performance Report

```sql
-- Product inventory and sales performance
SELECT 
    p.id,
    p.name,
    p.price,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    COALESCE(SUM(oi.line_total), 0) AS total_revenue,
    COALESCE(COUNT(DISTINCT oi.order_id), 0) AS times_ordered,
    -- Days since last order (if any)
    CASE 
        WHEN MAX(o.order_date) IS NOT NULL 
        THEN EXTRACT(DAY FROM (CURRENT_DATE - MAX(o.order_date)))
        ELSE NULL
    END AS days_since_last_sale,
    -- Inventory health
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity < 10 THEN 'Low Stock'
        WHEN p.stock_quantity < 50 THEN 'Medium Stock'
        ELSE 'Well Stocked'
    END AS inventory_status,
    -- Sales velocity (units per day since first order)
    CASE 
        WHEN MIN(o.order_date) IS NOT NULL 
        THEN ROUND(
            (COALESCE(SUM(oi.quantity), 0)::NUMERIC / 
            GREATEST(EXTRACT(DAY FROM (CURRENT_DATE - MIN(o.order_date))), 1))
        , 2)
        ELSE 0
    END AS sales_velocity_per_day
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.id 
    AND o.status NOT IN ('cancelled', 'refunded')
    AND o.deleted_at IS NULL
WHERE p.deleted_at IS NULL
GROUP BY p.id, p.name, p.price, p.stock_quantity
ORDER BY sales_velocity_per_day DESC, total_revenue DESC;
```

---

### Implementation Step 8: Performance Optimization with Indexing

#### 8.1 Analyze Query Performance

```sql
-- Analyze a slow query with EXPLAIN
EXPLAIN ANALYZE
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

#### 8.2 Create Performance Indexes

```sql
-- Composite indexes for common query patterns
CREATE INDEX idx_orders_user_status_date ON orders(user_id, status, order_date DESC);
CREATE INDEX idx_orders_status_date ON orders(status, order_date DESC);
CREATE INDEX idx_order_items_order_product ON order_items(order_id, product_id);
CREATE INDEX idx_order_items_product_quantity ON order_items(product_id, quantity);

-- Partial indexes for specific queries
CREATE INDEX idx_orders_active ON orders(order_date) 
WHERE status NOT IN ('cancelled', 'refunded') 
  AND deleted_at IS NULL;

-- Covering index for specific columns (PostgreSQL 11+)
CREATE INDEX idx_orders_covering ON orders(user_id, order_date) 
INCLUDE (total, status);

-- Analyze to refresh statistics
ANALYZE orders;
ANALYZE order_items;
ANALYZE users;
ANALYZE products;
```

---

### Implementation Step 9: Real-Time Analytics Views

#### 9.1 Create Materialized Views

Materialized views store results physically for faster access:

```sql
-- Daily sales summary (refreshed daily)
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE(order_date) AS sale_date,
    COUNT(*) AS order_count,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value,
    COUNT(DISTINCT user_id) AS unique_customers,
    COUNT(DISTINCT payment_method) AS payment_methods_used
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
  AND deleted_at IS NULL
GROUP BY DATE(order_date)
ORDER BY DATE(order_date);

-- Refresh the materialized view
REFRESH MATERIALIZED VIEW daily_sales_summary;

-- Query the materialized view (much faster than querying base tables)
SELECT * FROM daily_sales_summary 
WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY sale_date DESC;

-- Create unique index on materialized view
CREATE UNIQUE INDEX idx_daily_sales_summary_date 
ON daily_sales_summary(sale_date);

-- Customer product preferences (refresh weekly)
CREATE MATERIALIZED VIEW customer_product_preferences AS
SELECT 
    u.id AS user_id,
    u.full_name,
    p.id AS product_id,
    p.name AS product_name,
    COUNT(oi.id) AS purchase_count,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.line_total) AS total_spent,
    RANK() OVER (PARTITION BY u.id ORDER BY SUM(oi.line_total) DESC) AS product_rank
FROM users u
INNER JOIN orders o ON u.id = o.user_id
INNER JOIN order_items oi ON o.id = oi.order_id
INNER JOIN products p ON oi.product_id = p.id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
  AND oi.deleted_at IS NULL
  AND p.deleted_at IS NULL
GROUP BY u.id, u.full_name, p.id, p.name;

-- Automatic refresh using cron (requires pg_cron extension)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- SELECT cron.schedule('0 2 * * *', 'REFRESH MATERIALIZED VIEW daily_sales_summary');
```

---

### Verification Checklist

Before moving to Part 5, confirm you can:

- [ ] Use COUNT, SUM, AVG, MIN, MAX in queries
- [ ] Group data with GROUP BY on single and multiple columns
- [ ] Filter grouped data with HAVING
- [ ] Use ROW_NUMBER, RANK, DENSE_RANK
- [ ] Use LAG and LEAD for time-series analysis
- [ ] Calculate running totals and moving averages
- [ ] Implement CASE WHEN for conditional logic
- [ ] Build comprehensive business reports
- [ ] Create and use materialized views
- [ ] Analyze query performance with EXPLAIN

---

### Deep Dive: Window Function Mechanics

**ORDER BY vs PARTITION BY in Window Functions**:

```sql
-- ROW_NUMBER with ORDER BY (global ordering)
SELECT 
    name,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS global_rank
FROM products;

-- ROW_NUMBER with PARTITION BY AND ORDER BY (grouped ordering)
SELECT 
    category,  -- if we had this column
    name,
    price,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category
FROM products;
```

**Frame Specifications**:

```sql
-- Different frame types
SELECT 
    order_date,
    total,
    -- Default frame: RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    SUM(total) OVER (ORDER BY order_date) AS running_total_default,
    -- ROWS frame (more predictable with duplicate values)
    SUM(total) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_rows,
    -- Sliding window: last 5 rows
    AVG(total) OVER (ORDER BY order_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg_5,
    -- Sliding window: current row and next 2
    AVG(total) OVER (ORDER BY order_date ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) AS forward_avg_3
FROM orders;
```

---

### Common Pitfalls to Avoid

1. **Using aggregates without GROUP BY**: Mixing aggregated and non-aggregated columns requires GROUP BY
2. **Forgetting HAVING vs WHERE**: WHERE filters before grouping, HAVING filters after
3. **Window function performance**: Window functions can be expensive on large datasets
4. **NULL handling**: Aggregates ignore NULLs (except COUNT(*))
5. **Incorrect frame specification**: Default frame may not be what you expect
6. **Not analyzing queries**: Always use EXPLAIN ANALYZE for complex analytics
7. **Materialized view staleness**: Remember to refresh materialized views

---

### What's Next?

Incredible progress! You've unlocked the analytical power of PostgreSQL. In Part 5, we'll:

- Store and query semi-structured data with JSONB
- Use PostgreSQL extensions (pg_trgm for fuzzy search)
- Index JSON keys for performance
- Build a flexible product catalog with custom attributes
- Implement fast product search

You're becoming a true PostgreSQL power user!
