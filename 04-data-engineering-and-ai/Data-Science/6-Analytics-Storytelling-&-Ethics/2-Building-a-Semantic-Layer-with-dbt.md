# Module 6.1: Dashboard Engineering & BI Semantic Layers
## Part 2: Building a Semantic Layer with dbt

### The Target

We're building a robust semantic layer using dbt (data build tool) that centralizes our business logic, creates reusable metric definitions, and ensures a single source of truth for all analytics. This will transform our raw database into a curated, business-friendly data model.

### The Concept

Think of a semantic layer as the **"Rosetta Stone"** of your data stack. Just as the Rosetta Stone translated ancient Egyptian hieroglyphs into understandable Greek, a semantic layer translates complex database tables into business-friendly concepts.

**Without a semantic layer:**
- Each analyst writes their own definition of "active customer"
- Dashboard metrics don't match report metrics
- Every query reinvents the wheel
- Business logic is scattered in obscure SQL files

**With a semantic layer:**
- "Active customer" is defined once, used everywhere
- All metrics are consistent across tools
- Business logic is version-controlled and documented
- Analysts work at the business concept level, not table level

dbt (data build tool) is perfect for this because it:
- **Version controls** all your SQL transformations
- **Tests** your data quality automatically
- **Documents** your data model as you build it
- **Manages dependencies** between models
- **Enables modularity** with reusable components (macros)

---

## Step 1: Setting Up dbt

### The Target
Install dbt Core and initialize our dbt project.

### The Concept
dbt works as a command-line tool that compiles your SQL models, runs them against your database, and manages your data transformation pipeline. Think of it as a "compiler" for your business logic—it takes your SQL templates and turns them into executed database operations.

### The Implementation

```bash
# 1. Install dbt with PostgreSQL adapter
source venv/bin/activate  # Ensure we're in our virtual environment
pip install dbt-postgres==1.6.0

# Update requirements.txt
echo "dbt-postgres==1.6.0" >> requirements.txt
echo "dbt-core==1.6.0" >> requirements.txt

# 2. Initialize dbt project in the root directory
dbt init analytics_dbt

# When prompted:
# - Enter 'analytics_dbt' as the project name
# - Enter 'postgres' as the database adapter
# - Press Enter for default settings (we'll configure them)

# 3. Move the dbt project to the correct location
mv analytics_dbt/dbt_project.yml .
mv analytics_dbt/models/ .
mv analytics_dbt/macros/ .
mv analytics_dbt/tests/ .
mv analytics_dbt/seeds/ .
mv analytics_dbt/snapshots/ .
mv analytics_dbt/analyses/ .
rm -rf analytics_dbt/

# 4. Create dbt profile directory
mkdir -p ~/.dbt

# 5. Create dbt profile configuration
cat > ~/.dbt/profiles.yml << 'EOF'
analytics_dbt:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: analytics_user
      password: secure_password_change_me
      dbname: analytics
      schema: analytics_dbt
      threads: 4
      keepalives_idle: 0
      connect_timeout: 10
    prod:
      type: postgres
      host: localhost
      port: 5432
      user: analytics_user
      password: secure_password_change_me
      dbname: analytics
      schema: analytics_dbt
      threads: 8
      keepalives_idle: 0
      connect_timeout: 10
EOF

# 6. Test dbt connection
dbt debug --project-dir .

# Expected output: 
# All checks passed!
# Connection to postgres successful
```

Now let's update the dbt project configuration:

```bash
cat > dbt_project.yml << 'EOF'
# dbt project configuration

name: 'analytics_dbt'
version: '1.0.0'
config-version: 2

# This setting configures which "profile" dbt uses for this project.
profile: 'analytics_dbt'

# These configurations specify where dbt should look for different types of files.
model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

clean-targets:         # directories to be removed by `dbt clean`
  - "target"
  - "dbt_packages"

# Configuring models
# Full documentation: https://docs.getdbt.com/docs/configuring-models
models:
  analytics_dbt:
    # Config indicated by + and applies to all files under models/
    staging:
      +materialized: view
      +schema: staging
      +tags: ['staging']
    intermediate:
      +materialized: view
      +schema: intermediate
      +tags: ['intermediate']
    marts:
      +materialized: table
      +schema: marts
      +tags: ['marts']
    core:
      +materialized: view
      +schema: core
      +tags: ['core']

seeds:
  analytics_dbt:
    +schema: raw
    +quote_columns: false

vars:
  # Business definitions
  active_customer_days: 30
  churn_threshold_days: 90
  high_value_threshold: 1000
EOF
```

---

## Step 2: Creating the Staging Layer

### The Target
Create staging models that clean and prepare raw data for downstream transformations.

### The Concept
Staging models are the foundation of our semantic layer—they're like the "raw ingredients" prep station in a restaurant kitchen. They:
- **Rename columns** to consistent naming conventions
- **Cast data types** correctly
- **Handle nulls** with sensible defaults
- **Remove duplicates** and clean data
- **Add simple derived columns** (like calculating age from birth date)

These models are materialized as **views** because they should always reflect the latest raw data and don't store results.

### The Implementation

Create the staging models directory structure:

```bash
mkdir -p models/staging
mkdir -p models/staging/sources
```

#### Source Configuration

```bash
cat > models/staging/sources/sources.yml << 'EOF'
version: 2

sources:
  - name: analytics
    description: "Source database for e-commerce analytics"
    database: analytics
    schema: analytics
    loader: postgres
    
    tables:
      - name: customers
        description: "All registered customers with their personal information"
        columns:
          - name: customer_id
            description: "Primary key for customers table"
            tests:
              - unique
              - not_null
          - name: email
            description: "Customer email address (unique)"
            tests:
              - unique
              - not_null
          - name: registration_date
            description: "Date when customer registered"
          - name: is_active
            description: "Whether customer account is currently active"
          
      - name: products
        description: "Product catalog with pricing and inventory"
        columns:
          - name: product_id
            description: "Primary key for products table"
            tests:
              - unique
              - not_null
          - name: sku
            description: "Stock keeping unit (unique)"
            tests:
              - unique
              - not_null
          - name: unit_price
            description: "Current selling price per unit"
            tests:
              - not_null
              
      - name: categories
        description: "Product categorization hierarchy"
        
      - name: suppliers
        description: "Vendor information"
        
      - name: orders
        description: "All customer orders with complete transaction details"
        columns:
          - name: order_id
            description: "Primary key for orders table"
            tests:
              - unique
              - not_null
          - name: customer_id
            description: "Foreign key to customers table"
            tests:
              - not_null
              - relationships:
                  to: source('analytics', 'customers')
                  field: customer_id
          - name: order_date
            description: "Date when order was placed"
            tests:
              - not_null
              
      - name: order_items
        description: "Individual line items within orders"
        columns:
          - name: order_item_id
            description: "Primary key for order_items table"
          - name: order_id
            description: "Foreign key to orders table"
            tests:
              - not_null
          - name: product_id
            description: "Foreign key to products table"
            tests:
              - not_null
              
      - name: returns
        description: "Product returns and refunds"
        
      - name: reviews
        description: "Customer product reviews and ratings"
        
      - name: marketing_campaigns
        description: "Marketing and promotional campaigns"
        
      - name: campaign_responses
        description: "Customer responses to marketing campaigns"
EOF
```

#### Customer Staging Model

```bash
cat > models/staging/stg_customers.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'customers') }}
),

renamed AS (
    SELECT
        -- Primary key
        customer_id,
        
        -- Personal information
        email,
        first_name,
        last_name,
        phone,
        date_of_birth,
        
        -- Calculate age from date of birth
        CASE 
            WHEN date_of_birth IS NOT NULL 
            THEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth))
            ELSE NULL
        END AS age,
        
        -- Account information
        registration_date,
        last_login_date,
        
        -- Status flags
        is_active,
        is_verified,
        
        -- Derived: days since registration
        EXTRACT(DAY FROM (CURRENT_DATE - registration_date::DATE)) AS days_since_registration,
        
        -- Derived: customer lifecycle stage
        CASE
            WHEN EXTRACT(DAY FROM (CURRENT_DATE - registration_date::DATE)) <= 30 THEN 'new'
            WHEN EXTRACT(DAY FROM (CURRENT_DATE - registration_date::DATE)) <= 90 THEN 'active'
            WHEN EXTRACT(DAY FROM (CURRENT_DATE - registration_date::DATE)) <= 365 THEN 'regular'
            ELSE 'loyal'
        END AS lifecycle_stage,
        
        -- Metadata
        created_at,
        updated_at
        
    FROM source
)

SELECT * FROM renamed
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
EOF
```

#### Product Staging Model

```bash
cat > models/staging/stg_products.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'products') }}
),

renamed AS (
    SELECT
        -- Primary key
        product_id,
        
        -- Product identification
        sku,
        name,
        description,
        
        -- Category and supplier
        category_id,
        supplier_id,
        
        -- Pricing
        unit_price,
        cost_per_unit,
        
        -- Calculate profit margin
        CASE
            WHEN unit_price > 0 THEN ROUND(((unit_price - cost_per_unit) / unit_price) * 100, 2)
            ELSE NULL
        END AS profit_margin_percent,
        
        -- Inventory
        weight_kg,
        stock_quantity,
        reorder_level,
        
        -- Stock status
        CASE
            WHEN stock_quantity <= 0 THEN 'out_of_stock'
            WHEN stock_quantity <= reorder_level THEN 'low_stock'
            WHEN stock_quantity <= reorder_level * 3 THEN 'medium_stock'
            ELSE 'high_stock'
        END AS stock_status,
        
        -- Active status
        is_active,
        
        -- Metadata
        created_at,
        updated_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

#### Category Staging Model

```bash
cat > models/staging/stg_categories.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'categories') }}
),

-- Recursive CTE to build category hierarchy
category_hierarchy AS (
    -- Anchor: top-level categories (no parent)
    SELECT
        category_id,
        name,
        parent_category_id,
        name AS full_path,
        0 AS level
    FROM source
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- Recursive: child categories
    SELECT
        c.category_id,
        c.name,
        c.parent_category_id,
        ch.full_path || ' > ' || c.name AS full_path,
        ch.level + 1 AS level
    FROM source c
    INNER JOIN category_hierarchy ch ON c.parent_category_id = ch.category_id
),

renamed AS (
    SELECT
        -- Primary key
        category_id,
        
        -- Category information
        name,
        description,
        parent_category_id,
        
        -- Hierarchy details
        full_path,
        level,
        
        -- Is this a top-level category?
        parent_category_id IS NULL AS is_top_level,
        
        -- Metadata
        created_at
        
    FROM category_hierarchy
)

SELECT * FROM renamed
EOF
```

#### Order Staging Model

```bash
cat > models/staging/stg_orders.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'orders') }}
),

renamed AS (
    SELECT
        -- Primary key
        order_id,
        
        -- Foreign keys
        customer_id,
        
        -- Order details
        order_date,
        status,
        
        -- Shipping
        shipping_address_line1,
        shipping_address_line2,
        shipping_city,
        shipping_state,
        shipping_postal_code,
        shipping_country,
        
        -- Payment
        payment_method,
        payment_status,
        
        -- Amounts
        subtotal_amount,
        tax_amount,
        shipping_amount,
        discount_amount,
        total_amount,
        
        -- Derived: tax rate
        CASE
            WHEN subtotal_amount - discount_amount > 0 
            THEN ROUND((tax_amount / (subtotal_amount - discount_amount)) * 100, 2)
            ELSE 0
        END AS effective_tax_rate,
        
        -- Derived: discount rate
        CASE
            WHEN subtotal_amount > 0 
            THEN ROUND((discount_amount / subtotal_amount) * 100, 2)
            ELSE 0
        END AS discount_rate,
        
        -- Derived: order day of week
        EXTRACT(DOW FROM order_date) AS day_of_week,
        
        -- Derived: order month
        DATE_TRUNC('month', order_date) AS order_month,
        
        -- Derived: order quarter
        DATE_TRUNC('quarter', order_date) AS order_quarter,
        
        -- Derived: order year
        EXTRACT(YEAR FROM order_date) AS order_year,
        
        -- Derived: is weekend order?
        EXTRACT(DOW FROM order_date) IN (0, 6) AS is_weekend,
        
        -- Metadata
        notes,
        created_at,
        updated_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

#### Order Items Staging Model

```bash
cat > models/staging/stg_order_items.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'order_items') }}
),

renamed AS (
    SELECT
        -- Primary key
        order_item_id,
        
        -- Foreign keys
        order_id,
        product_id,
        
        -- Item details
        quantity,
        unit_price,
        discount_percent,
        total_price,
        
        -- Derived: discount amount per item
        ROUND(unit_price * quantity * (discount_percent / 100), 2) AS discount_amount,
        
        -- Derived: net price per item (after discount)
        ROUND(unit_price * (1 - discount_percent / 100), 2) AS net_unit_price,
        
        -- Derived: line item total before discount
        ROUND(unit_price * quantity, 2) AS subtotal_amount,
        
        -- Derived: was this item discounted?
        discount_percent > 0 AS is_discounted,
        
        -- Metadata
        created_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

#### Returns Staging Model

```bash
cat > models/staging/stg_returns.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'returns') }}
),

renamed AS (
    SELECT
        -- Primary key
        return_id,
        
        -- Foreign keys
        order_item_id,
        
        -- Return details
        return_reason,
        return_status,
        refund_amount,
        refund_date,
        
        -- Derived: days to refund
        EXTRACT(DAY FROM (refund_date - created_at)) AS days_to_refund,
        
        -- Derived: was refund processed?
        refund_date IS NOT NULL AS is_refunded,
        
        -- Metadata
        created_at,
        updated_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

#### Reviews Staging Model

```bash
cat > models/staging/stg_reviews.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'reviews') }}
),

renamed AS (
    SELECT
        -- Primary key
        review_id,
        
        -- Foreign keys
        product_id,
        customer_id,
        
        -- Review details
        rating,
        title,
        comment,
        is_verified_purchase,
        helpful_count,
        
        -- Derived: review sentiment based on rating
        CASE
            WHEN rating >= 4 THEN 'positive'
            WHEN rating = 3 THEN 'neutral'
            ELSE 'negative'
        END AS sentiment,
        
        -- Derived: is helpful review?
        helpful_count > 0 AS is_helpful,
        
        -- Metadata
        created_at,
        updated_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

#### Marketing Staging Models

```bash
cat > models/staging/stg_marketing_campaigns.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'marketing_campaigns') }}
),

renamed AS (
    SELECT
        -- Primary key
        campaign_id,
        
        -- Campaign details
        name,
        description,
        channel,
        start_date,
        end_date,
        budget,
        cost_per_contact,
        target_audience,
        
        -- Derived: campaign duration in days
        EXTRACT(DAY FROM (end_date - start_date)) AS campaign_duration_days,
        
        -- Derived: is campaign active?
        CURRENT_DATE BETWEEN start_date AND COALESCE(end_date, CURRENT_DATE) AS is_active,
        
        -- Derived: campaign status
        CASE
            WHEN CURRENT_DATE < start_date THEN 'scheduled'
            WHEN CURRENT_DATE BETWEEN start_date AND COALESCE(end_date, CURRENT_DATE) THEN 'active'
            ELSE 'completed'
        END AS campaign_status,
        
        -- Metadata
        created_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

```bash
cat > models/staging/stg_campaign_responses.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['staging']
    )
}}

WITH source AS (
    SELECT * FROM {{ source('analytics', 'campaign_responses') }}
),

renamed AS (
    SELECT
        -- Primary key
        response_id,
        
        -- Foreign keys
        campaign_id,
        customer_id,
        
        -- Response details
        response_date,
        action_taken,
        conversion_value,
        
        -- Derived: did customer convert?
        action_taken = 'purchased' AS did_convert,
        
        -- Derived: conversion value (0 if no conversion)
        COALESCE(conversion_value, 0) AS conversion_value_coalesced,
        
        -- Metadata
        created_at
        
    FROM source
)

SELECT * FROM renamed
EOF
```

### The Verification

```bash
# 1. Check that all staging models are recognized
dbt list --project-dir . --resource-type model

# Expected output: Shows all staging models (stg_customers, stg_products, etc.)

# 2. Run staging models
dbt run --project-dir . --models staging

# 3. Check the staging schema
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics_dbt.*"

# 4. Verify staging data
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 'stg_customers' as model, COUNT(*) as count FROM analytics_dbt.stg_customers
UNION ALL
SELECT 'stg_products', COUNT(*) FROM analytics_dbt.stg_products
UNION ALL
SELECT 'stg_orders', COUNT(*) FROM analytics_dbt.stg_orders
ORDER BY model;"
```

---

## Step 3: Creating Intermediate Models

### The Target
Create intermediate models that combine data from multiple staging models to answer specific business questions.

### The Concept
Intermediate models are like a "prep cook" in our kitchen analogy. They take cleaned raw ingredients from staging and start combining them in meaningful ways. These models:
- **Join** related data from multiple staging models
- **Perform aggregations** at the right grain
- **Calculate derived metrics** that are needed by multiple marts
- **Handle complex business logic** that needs to be reused

### The Implementation

Create the intermediate directory and models:

```bash
mkdir -p models/intermediate
```

#### Customer Orders Summary

```bash
cat > models/intermediate/int_customer_orders_summary.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS total_spent,
        AVG(total_amount) AS avg_order_value,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        MAX(order_date) - MIN(order_date) AS customer_lifetime_days,
        COUNT(DISTINCT CASE WHEN status = 'completed' THEN order_id END) AS completed_orders,
        COUNT(DISTINCT CASE WHEN status = 'cancelled' THEN order_id END) AS cancelled_orders,
        SUM(CASE WHEN status != 'cancelled' THEN total_amount ELSE 0 END) AS net_spent
    FROM orders
    GROUP BY customer_id
),

final AS (
    SELECT
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        c.registration_date,
        c.age,
        c.is_active,
        c.lifecycle_stage,
        
        -- Order summary
        COALESCE(co.total_orders, 0) AS total_orders,
        COALESCE(co.total_spent, 0) AS total_spent,
        COALESCE(co.avg_order_value, 0) AS avg_order_value,
        COALESCE(co.net_spent, 0) AS net_spent,
        co.first_order_date,
        co.last_order_date,
        co.customer_lifetime_days,
        
        -- Customer value tier
        CASE
            WHEN COALESCE(co.net_spent, 0) >= 5000 THEN 'platinum'
            WHEN COALESCE(co.net_spent, 0) >= 2000 THEN 'gold'
            WHEN COALESCE(co.net_spent, 0) >= 500 THEN 'silver'
            WHEN COALESCE(co.net_spent, 0) > 0 THEN 'bronze'
            ELSE 'prospect'
        END AS customer_tier,
        
        -- Churn risk indicators
        c.days_since_registration,
        EXTRACT(DAY FROM (CURRENT_DATE - COALESCE(co.last_order_date, c.registration_date))) AS days_since_last_activity,
        CASE
            WHEN COALESCE(co.last_order_date, c.registration_date) < CURRENT_DATE - INTERVAL '90 days' THEN 'high'
            WHEN COALESCE(co.last_order_date, c.registration_date) < CURRENT_DATE - INTERVAL '45 days' THEN 'medium'
            ELSE 'low'
        END AS churn_risk,
        
        -- Customer lifetime value (simple projection)
        ROUND(
            COALESCE(co.net_spent, 0) * 
            CASE
                WHEN c.days_since_registration > 0 THEN 365.0 / c.days_since_registration
                ELSE 1
            END * 3,
            2
        ) AS projected_lifetime_value
        
    FROM customers c
    LEFT JOIN customer_orders co ON c.customer_id = co.customer_id
)

SELECT * FROM final
EOF
```

#### Product Performance Summary

```bash
cat > models/intermediate/int_product_performance.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

categories AS (
    SELECT * FROM {{ ref('stg_categories') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

orders AS (
    SELECT order_id, status FROM {{ ref('stg_orders') }}
),

reviews AS (
    SELECT * FROM {{ ref('stg_reviews') }}
),

-- Product sales summary
product_sales AS (
    SELECT
        oi.product_id,
        COUNT(DISTINCT oi.order_id) AS order_count,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.total_price) AS total_revenue,
        AVG(oi.quantity) AS avg_quantity_per_order,
        AVG(oi.unit_price) AS avg_selling_price,
        SUM(oi.discount_amount) AS total_discount_given
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled')
    GROUP BY oi.product_id
),

-- Product review summary
product_reviews AS (
    SELECT
        product_id,
        AVG(rating) AS avg_rating,
        COUNT(*) AS review_count,
        COUNT(CASE WHEN sentiment = 'positive' THEN 1 END) AS positive_reviews,
        COUNT(CASE WHEN sentiment = 'negative' THEN 1 END) AS negative_reviews,
        SUM(helpful_count) AS total_helpful_votes
    FROM reviews
    GROUP BY product_id
),

final AS (
    SELECT
        p.product_id,
        p.sku,
        p.name,
        p.description,
        p.category_id,
        c.name AS category_name,
        c.full_path AS category_full_path,
        p.supplier_id,
        p.unit_price,
        p.cost_per_unit,
        p.profit_margin_percent,
        p.stock_quantity,
        p.stock_status,
        p.is_active,
        
        -- Sales performance
        COALESCE(ps.order_count, 0) AS order_count,
        COALESCE(ps.units_sold, 0) AS units_sold,
        COALESCE(ps.total_revenue, 0) AS total_revenue,
        COALESCE(ps.avg_quantity_per_order, 0) AS avg_quantity_per_order,
        COALESCE(ps.avg_selling_price, p.unit_price) AS avg_selling_price,
        COALESCE(ps.total_discount_given, 0) AS total_discount_given,
        
        -- Revenue ranking
        RANK() OVER (ORDER BY COALESCE(ps.total_revenue, 0) DESC) AS revenue_rank,
        
        -- Review performance
        COALESCE(pr.avg_rating, 0) AS avg_rating,
        COALESCE(pr.review_count, 0) AS review_count,
        COALESCE(pr.positive_reviews, 0) AS positive_reviews,
        COALESCE(pr.negative_reviews, 0) AS negative_reviews,
        COALESCE(pr.total_helpful_votes, 0) AS total_helpful_votes,
        
        -- Rating as percentage of 5 stars
        ROUND(COALESCE(pr.avg_rating, 0) * 20, 2) AS rating_percent,
        
        -- Product health score
        CASE
            WHEN COALESCE(pr.avg_rating, 0) >= 4.0 AND COALESCE(ps.units_sold, 0) > 100 THEN 'star'
            WHEN COALESCE(pr.avg_rating, 0) < 3.0 AND COALESCE(ps.units_sold, 0) > 50 THEN 'needs_improvement'
            WHEN COALESCE(ps.units_sold, 0) <= 10 THEN 'low_performer'
            ELSE 'steady'
        END AS product_health,
        
        -- Inventory turnover (rough estimate)
        CASE
            WHEN p.stock_quantity > 0 AND COALESCE(ps.units_sold, 0) > 0 
            THEN ROUND(COALESCE(ps.units_sold, 0) * 1.0 / p.stock_quantity, 2)
            ELSE 0
        END AS inventory_turnover_ratio
        
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.category_id
    LEFT JOIN product_sales ps ON p.product_id = ps.product_id
    LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
)

SELECT * FROM final
EOF
```

#### Order Fulfillment Summary

```bash
cat > models/intermediate/int_order_fulfillment_summary.sql << 'EOF'
{{
    config(
        materialized='view',
        tags=['intermediate']
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

returns AS (
    SELECT * FROM {{ ref('stg_returns') }}
),

-- Order item details with return flags
order_items_with_returns AS (
    SELECT
        oi.order_item_id,
        oi.order_id,
        oi.product_id,
        oi.quantity,
        oi.total_price,
        oi.is_discounted,
        r.return_id,
        r.return_status,
        r.refund_amount,
        r.return_reason,
        CASE WHEN r.return_id IS NOT NULL THEN 1 ELSE 0 END AS is_returned,
        CASE WHEN r.return_status = 'completed' THEN 1 ELSE 0 END AS is_return_completed
    FROM order_items oi
    LEFT JOIN returns r ON oi.order_item_id = r.order_item_id
),

-- Aggregate by order
order_fulfillment AS (
    SELECT
        order_id,
        COUNT(DISTINCT order_item_id) AS total_items,
        SUM(total_price) AS item_total,
        SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS returned_items,
        SUM(CASE WHEN is_return_completed = 1 THEN 1 ELSE 0 END) AS completed_returns,
        SUM(CASE WHEN is_discounted = 1 THEN 1 ELSE 0 END) AS discounted_items,
        
        -- Return rate per order
        CASE 
            WHEN COUNT(DISTINCT order_item_id) > 0 
            THEN CAST(SUM(CASE WHEN is_returned = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT order_item_id)
            ELSE 0
        END AS order_return_rate
    FROM order_items_with_returns
    GROUP BY order_id
),

final AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        o.payment_status,
        o.total_amount,
        
        -- Fulfillment metrics
        of.total_items,
        of.item_total,
        of.returned_items,
        of.completed_returns,
        of.discounted_items,
        of.order_return_rate,
        
        -- Fulfillment status
        CASE
            WHEN of.returned_items = 0 AND o.status IN ('completed', 'shipped') THEN 'fully_fulfilled'
            WHEN of.returned_items > 0 AND of.returned_items = of.total_items THEN 'fully_returned'
            WHEN of.returned_items > 0 AND of.returned_items < of.total_items THEN 'partially_returned'
            WHEN o.status = 'cancelled' THEN 'cancelled'
            WHEN o.status = 'pending' THEN 'pending'
            ELSE 'other'
        END AS fulfillment_status,
        
        -- Discount impact
        CASE
            WHEN o.subtotal_amount > 0 
            THEN ROUND((o.discount_amount / o.subtotal_amount) * 100, 2)
            ELSE 0
        END AS order_discount_rate
        
    FROM orders o
    LEFT JOIN order_fulfillment of ON o.order_id = of.order_id
)

SELECT * FROM final
EOF
```

### The Verification

```bash
# 1. Run intermediate models
dbt run --project-dir . --models intermediate

# 2. Verify the intermediate tables
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics_dbt.intermediate"

# 3. Check data quality for customer summary
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    customer_tier,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent), 2) as avg_spent,
    ROUND(AVG(avg_order_value), 2) as avg_order_value
FROM analytics_dbt.int_customer_orders_summary
GROUP BY customer_tier
ORDER BY customer_tier;"

# 4. Check product performance metrics
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    product_health,
    COUNT(*) as product_count,
    ROUND(AVG(avg_rating), 2) as avg_rating,
    ROUND(AVG(units_sold), 0) as avg_units_sold
FROM analytics_dbt.int_product_performance
GROUP BY product_health
ORDER BY product_health;"
```

---

## Step 4: Creating Mart Models

### The Target
Create mart models that are optimized for specific business domains and ready for dashboard consumption.

### The Concept
Mart models are the "finished dishes" in our kitchen analogy—they're polished, optimized, and ready to serve. These models:
- **Aggregate data** to the appropriate grain for specific business domains
- **Create business-friendly field names** (no more technical column names)
- **Pre-calculate common metrics** for performance
- **Combine data from multiple intermediate models** into coherent views
- **Optimize for query performance** for dashboard usage

### The Implementation

Create the mart directory structure:

```bash
mkdir -p models/marts/{customer,product,sales,marketing}
```

#### Customer Mart

```bash
cat > models/marts/customer/dm_customer_360.sql << 'EOF'
{{
    config(
        materialized='table',
        schema='marts',
        tags=['marts', 'customer'],
        partition_by={
            "field": "registration_date",
            "data_type": "timestamp",
            "granularity": "month"
        }
    )
}}

WITH customer_summary AS (
    SELECT * FROM {{ ref('int_customer_orders_summary') }}
),

order_fulfillment AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders,
        AVG(order_return_rate) AS avg_return_rate,
        SUM(CASE WHEN fulfillment_status = 'fully_returned' THEN 1 ELSE 0 END) AS fully_returned_orders
    FROM {{ ref('int_order_fulfillment_summary') }}
    GROUP BY customer_id
),

customer_reviews AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_reviews,
        AVG(rating) AS avg_review_rating,
        COUNT(CASE WHEN sentiment = 'positive' THEN 1 END) AS positive_reviews
    FROM {{ ref('stg_reviews') }}
    GROUP BY customer_id
),

marketing_engagement AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_campaign_responses,
        COUNT(CASE WHEN did_convert THEN 1 END) AS campaign_conversions,
        SUM(conversion_value_coalesced) AS campaign_revenue
    FROM {{ ref('stg_campaign_responses') }}
    GROUP BY customer_id
),

final AS (
    SELECT
        -- Customer identification
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        c.age,
        c.is_active,
        c.is_verified,
        
        -- Registration info
        c.registration_date,
        c.days_since_registration,
        c.lifecycle_stage,
        
        -- Purchase behavior
        c.total_orders,
        c.total_spent,
        c.avg_order_value,
        c.net_spent,
        c.first_order_date,
        c.last_order_date,
        
        -- Customer value metrics
        c.customer_tier,
        c.projected_lifetime_value,
        c.churn_risk,
        
        -- Return behavior
        COALESCE(of.avg_return_rate, 0) AS avg_return_rate,
        COALESCE(of.fully_returned_orders, 0) AS fully_returned_orders,
        
        -- Review behavior
        COALESCE(cr.total_reviews, 0) AS total_reviews,
        COALESCE(cr.avg_review_rating, 0) AS avg_review_rating,
        COALESCE(cr.positive_reviews, 0) AS positive_reviews,
        
        -- Marketing engagement
        COALESCE(me.total_campaign_responses, 0) AS total_campaign_responses,
        COALESCE(me.campaign_conversions, 0) AS campaign_conversions,
        COALESCE(me.campaign_revenue, 0) AS campaign_revenue,
        
        -- Customer health score (composite metric)
        ROUND(
            (CASE WHEN c.is_active THEN 20 ELSE 0 END) +
            (CASE WHEN c.total_orders >= 5 THEN 20 ELSE c.total_orders * 4 END) +
            (CASE WHEN c.avg_order_value >= 100 THEN 20 ELSE c.avg_order_value / 5 END) +
            (CASE WHEN c.churn_risk = 'low' THEN 20 WHEN c.churn_risk = 'medium' THEN 10 ELSE 0 END) +
            (CASE WHEN COALESCE(cr.avg_review_rating, 0) >= 4 THEN 20 ELSE 0 END),
            2
        ) AS customer_health_score,
        
        -- Last updated timestamp
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM customer_summary c
    LEFT JOIN order_fulfillment of ON c.customer_id = of.customer_id
    LEFT JOIN customer_reviews cr ON c.customer_id = cr.customer_id
    LEFT JOIN marketing_engagement me ON c.customer_id = me.customer_id
)

SELECT * FROM final
EOF
```

#### Product Mart

```bash
cat > models/marts/product/dm_product_performance.sql << 'EOF'
{{
    config(
        materialized='table',
        schema='marts',
        tags=['marts', 'product']
    )
}}

WITH product_performance AS (
    SELECT * FROM {{ ref('int_product_performance') }}
),

-- Monthly product performance
monthly_product_sales AS (
    SELECT
        oi.product_id,
        DATE_TRUNC('month', o.order_date) AS sales_month,
        SUM(oi.total_price) AS monthly_revenue,
        SUM(oi.quantity) AS monthly_units_sold
    FROM {{ ref('stg_order_items') }} oi
    INNER JOIN {{ ref('stg_orders') }} o ON oi.order_id = o.order_id
    WHERE o.status NOT IN ('cancelled')
    GROUP BY oi.product_id, DATE_TRUNC('month', o.order_date)
),

monthly_ranked AS (
    SELECT
        product_id,
        sales_month,
        monthly_revenue,
        monthly_units_sold,
        RANK() OVER (PARTITION BY sales_month ORDER BY monthly_revenue DESC) AS monthly_revenue_rank
    FROM monthly_product_sales
),

latest_monthly_performance AS (
    SELECT DISTINCT ON (product_id)
        product_id,
        sales_month AS latest_sales_month,
        monthly_revenue AS latest_monthly_revenue,
        monthly_units_sold AS latest_monthly_units_sold,
        monthly_revenue_rank AS latest_monthly_revenue_rank
    FROM monthly_ranked
    ORDER BY product_id, sales_month DESC
),

final AS (
    SELECT
        -- Product identification
        p.product_id,
        p.sku,
        p.name,
        p.description,
        p.category_id,
        p.category_name,
        p.category_full_path,
        
        -- Pricing and costs
        p.unit_price,
        p.cost_per_unit,
        p.profit_margin_percent,
        
        -- Inventory
        p.stock_quantity,
        p.stock_status,
        p.reorder_level,
        p.inventory_turnover_ratio,
        
        -- Lifetime sales
        p.order_count,
        p.units_sold,
        p.total_revenue,
        p.avg_quantity_per_order,
        p.avg_selling_price,
        p.total_discount_given,
        p.revenue_rank,
        
        -- Monthly performance
        lp.latest_sales_month,
        lp.latest_monthly_revenue,
        lp.latest_monthly_units_sold,
        lp.latest_monthly_revenue_rank,
        
        -- Review metrics
        p.avg_rating,
        p.review_count,
        p.positive_reviews,
        p.negative_reviews,
        p.total_helpful_votes,
        p.rating_percent,
        
        -- Product health
        p.product_health,
        p.is_active,
        
        -- Current stock value
        ROUND(p.stock_quantity * p.unit_price, 2) AS current_stock_value,
        
        -- Gross profit
        ROUND(p.units_sold * (p.unit_price - p.cost_per_unit), 2) AS gross_profit,
        
        -- Return on investment (simple)
        CASE 
            WHEN p.cost_per_unit > 0 AND p.units_sold > 0
            THEN ROUND(((p.unit_price - p.cost_per_unit) / p.cost_per_unit) * 100, 2)
            ELSE 0
        END AS roi_percent,
        
        -- Last updated timestamp
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM product_performance p
    LEFT JOIN latest_monthly_performance lp ON p.product_id = lp.product_id
)

SELECT * FROM final
EOF
```

#### Sales Mart

```bash
cat > models/marts/sales/dm_sales_summary.sql << 'EOF'
{{
    config(
        materialized='table',
        schema='marts',
        tags=['marts', 'sales'],
        partition_by={
            "field": "sales_month",
            "data_type": "timestamp",
            "granularity": "month"
        }
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

-- Aggregate by month
monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_id) AS unique_customers,
        SUM(total_amount) AS total_revenue,
        AVG(total_amount) AS avg_order_value,
        SUM(subtotal_amount) AS subtotal_revenue,
        SUM(tax_amount) AS total_tax,
        SUM(shipping_amount) AS total_shipping,
        SUM(discount_amount) AS total_discounts,
        
        -- Payment method breakdown
        COUNT(CASE WHEN payment_method = 'credit_card' THEN 1 END) AS credit_card_orders,
        COUNT(CASE WHEN payment_method = 'paypal' THEN 1 END) AS paypal_orders,
        COUNT(CASE WHEN payment_method IN ('apple_pay', 'google_pay') THEN 1 END) AS digital_wallet_orders,
        
        -- Status breakdown
        COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_orders,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending_orders,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_orders,
        COUNT(CASE WHEN status = 'shipped' THEN 1 END) AS shipped_orders,
        
        -- Weekday vs weekend
        COUNT(CASE WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 1 END) AS weekend_orders,
        COUNT(CASE WHEN EXTRACT(DOW FROM order_date) NOT IN (0, 6) THEN 1 END) AS weekday_orders
        
    FROM orders
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
),

-- Add growth calculations
monthly_growth AS (
    SELECT
        *,
        LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
        LAG(total_orders) OVER (ORDER BY sales_month) AS previous_month_orders,
        LAG(unique_customers) OVER (ORDER BY sales_month) AS previous_month_customers,
        
        -- Revenue growth rate
        CASE
            WHEN LAG(total_revenue) OVER (ORDER BY sales_month) > 0
            THEN ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month)) / LAG(total_revenue) OVER (ORDER BY sales_month)) * 100, 2)
            ELSE NULL
        END AS revenue_growth_percent,
        
        -- Order growth rate
        CASE
            WHEN LAG(total_orders) OVER (ORDER BY sales_month) > 0
            THEN ROUND(((total_orders - LAG(total_orders) OVER (ORDER BY sales_month)) / LAG(total_orders) OVER (ORDER BY sales_month)) * 100, 2)
            ELSE NULL
        END AS order_growth_percent
        
    FROM monthly_sales
),

final AS (
    SELECT
        sales_month,
        total_orders,
        unique_customers,
        total_revenue,
        avg_order_value,
        subtotal_revenue,
        total_tax,
        total_shipping,
        total_discounts,
        credit_card_orders,
        paypal_orders,
        digital_wallet_orders,
        completed_orders,
        pending_orders,
        cancelled_orders,
        shipped_orders,
        weekend_orders,
        weekday_orders,
        
        -- Calculate percentages
        ROUND((completed_orders * 100.0 / NULLIF(total_orders, 0)), 2) AS completion_rate,
        ROUND((weekend_orders * 100.0 / NULLIF(total_orders, 0)), 2) AS weekend_order_percent,
        
        -- Growth metrics
        previous_month_revenue,
        previous_month_orders,
        revenue_growth_percent,
        order_growth_percent,
        
        -- Last updated timestamp
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM monthly_growth
)

SELECT * FROM final
EOF
```

#### Marketing Mart

```bash
cat > models/marts/marketing/dm_campaign_performance.sql << 'EOF'
{{
    config(
        materialized='table',
        schema='marts',
        tags=['marts', 'marketing']
    )
}}

WITH campaigns AS (
    SELECT * FROM {{ ref('stg_marketing_campaigns') }}
),

responses AS (
    SELECT * FROM {{ ref('stg_campaign_responses') }}
),

-- Campaign response summary
campaign_response_summary AS (
    SELECT
        campaign_id,
        COUNT(DISTINCT response_id) AS total_responses,
        COUNT(DISTINCT customer_id) AS unique_customers_reached,
        COUNT(CASE WHEN action_taken = 'opened' THEN 1 END) AS opens,
        COUNT(CASE WHEN action_taken = 'clicked' THEN 1 END) AS clicks,
        COUNT(CASE WHEN action_taken = 'purchased' THEN 1 END) AS purchases,
        COUNT(CASE WHEN action_taken = 'unsubscribed' THEN 1 END) AS unsubscribes,
        SUM(conversion_value_coalesced) AS total_conversion_value,
        AVG(conversion_value_coalesced) AS avg_conversion_value
    FROM responses
    GROUP BY campaign_id
),

-- Customer acquisition from campaigns
acquisition AS (
    SELECT
        campaign_id,
        customer_id,
        MIN(response_date) AS first_response_date,
        COUNT(*) AS total_interactions
    FROM responses
    GROUP BY campaign_id, customer_id
),

campaign_acquisition AS (
    SELECT
        campaign_id,
        COUNT(DISTINCT customer_id) AS total_customers_acquired
    FROM acquisition
    WHERE total_interactions >= 2  -- At least 2 interactions to consider acquired
    GROUP BY campaign_id
),

final AS (
    SELECT
        c.campaign_id,
        c.name,
        c.description,
        c.channel,
        c.start_date,
        c.end_date,
        c.campaign_duration_days,
        c.campaign_status,
        c.budget,
        c.cost_per_contact,
        
        -- Response metrics
        COALESCE(cr.total_responses, 0) AS total_responses,
        COALESCE(cr.unique_customers_reached, 0) AS unique_customers_reached,
        COALESCE(cr.opens, 0) AS opens,
        COALESCE(cr.clicks, 0) AS clicks,
        COALESCE(cr.purchases, 0) AS purchases,
        COALESCE(cr.unsubscribes, 0) AS unsubscribes,
        COALESCE(cr.total_conversion_value, 0) AS total_conversion_value,
        COALESCE(cr.avg_conversion_value, 0) AS avg_conversion_value,
        
        -- Acquisition metrics
        COALESCE(ca.total_customers_acquired, 0) AS total_customers_acquired,
        
        -- Performance rates
        CASE 
            WHEN cr.unique_customers_reached > 0 
            THEN ROUND((cr.opens * 100.0 / cr.unique_customers_reached), 2)
            ELSE 0
        END AS open_rate,
        
        CASE 
            WHEN cr.opens > 0 
            THEN ROUND((cr.clicks * 100.0 / cr.opens), 2)
            ELSE 0
        END AS click_through_rate,
        
        CASE 
            WHEN cr.clicks > 0 
            THEN ROUND((cr.purchases * 100.0 / cr.clicks), 2)
            ELSE 0
        END AS conversion_rate,
        
        CASE 
            WHEN cr.unique_customers_reached > 0 
            THEN ROUND((cr.unsubscribes * 100.0 / cr.unique_customers_reached), 2)
            ELSE 0
        END AS unsubscribe_rate,
        
        -- ROI metrics
        CASE 
            WHEN c.budget > 0 
            THEN ROUND((cr.total_conversion_value / c.budget), 2)
            ELSE 0
        END AS roi_ratio,
        
        -- Cost per acquisition
        CASE 
            WHEN ca.total_customers_acquired > 0 
            THEN ROUND(c.budget / ca.total_customers_acquired, 2)
            ELSE c.budget
        END AS cost_per_acquisition,
        
        -- Last updated timestamp
        CURRENT_TIMESTAMP AS dbt_loaded_at
        
    FROM campaigns c
    LEFT JOIN campaign_response_summary cr ON c.campaign_id = cr.campaign_id
    LEFT JOIN campaign_acquisition ca ON c.campaign_id = ca.campaign_id
)

SELECT * FROM final
EOF
```

### The Verification

```bash
# 1. Run all mart models
dbt run --project-dir . --models marts

# 2. Verify mart tables were created
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics_dbt.marts"

# 3. Check customer mart data
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    customer_tier,
    COUNT(*) as customer_count,
    ROUND(AVG(customer_health_score), 2) as avg_health_score,
    ROUND(AVG(projected_lifetime_value), 2) as avg_clv
FROM analytics_dbt.dm_customer_360
GROUP BY customer_tier
ORDER BY customer_tier;"

# 4. Check product mart
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    product_health,
    COUNT(*) as product_count,
    ROUND(AVG(avg_rating), 2) as avg_rating,
    ROUND(AVG(inventory_turnover_ratio), 2) as avg_turnover
FROM analytics_dbt.dm_product_performance
GROUP BY product_health
ORDER BY product_health;"

# 5. Check sales summary
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    sales_month,
    total_orders,
    unique_customers,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    revenue_growth_percent
FROM analytics_dbt.dm_sales_summary
ORDER BY sales_month DESC
LIMIT 6;"
```

---

## Step 5: Testing Data Quality

### The Target
Create tests to ensure our data quality is maintained as our semantic layer evolves.

### The Concept
Tests are like quality control checks in manufacturing—they catch problems before they reach the customer. dbt provides:
- **Generic tests:** Built-in tests like `unique`, `not_null`, `accepted_values`
- **Custom tests:** Business-specific logic you define in SQL
- **Automated execution:** Tests run with `dbt test` command

### The Implementation

```bash
mkdir -p tests/generic
mkdir -p tests/custom
```

#### Define Tests in the Schema

```bash
cat > models/marts/schema.yml << 'EOF'
version: 2

models:
  - name: dm_customer_360
    description: "360-degree view of customers for analytics and segmentation"
    columns:
      - name: customer_id
        description: "Primary key for customers"
        tests:
          - unique
          - not_null
      - name: email
        description: "Customer email address"
        tests:
          - not_null
      - name: customer_tier
        description: "Customer value tier"
        tests:
          - accepted_values:
              values: ['platinum', 'gold', 'silver', 'bronze', 'prospect']
      - name: churn_risk
        description: "Customer churn risk assessment"
        tests:
          - accepted_values:
              values: ['low', 'medium', 'high']
      - name: customer_health_score
        description: "Composite health score (0-100)"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: projected_lifetime_value
        description: "Projected lifetime value"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0

  - name: dm_product_performance
    description: "Product performance and health metrics"
    columns:
      - name: product_id
        description: "Primary key for products"
        tests:
          - unique
          - not_null
      - name: sku
        description: "Product SKU"
        tests:
          - unique
          - not_null
      - name: product_health
        description: "Product health classification"
        tests:
          - accepted_values:
              values: ['star', 'steady', 'needs_improvement', 'low_performer']
      - name: units_sold
        description: "Total units sold"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
      - name: total_revenue
        description: "Total revenue from product"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0

  - name: dm_sales_summary
    description: "Monthly sales summary and growth metrics"
    columns:
      - name: sales_month
        description: "Month of sales data"
        tests:
          - unique
          - not_null
      - name: total_revenue
        description: "Total monthly revenue"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
      - name: completion_rate
        description: "Order completion rate as percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100

  - name: dm_campaign_performance
    description: "Marketing campaign performance metrics"
    columns:
      - name: campaign_id
        description: "Primary key for campaigns"
        tests:
          - unique
          - not_null
      - name: open_rate
        description: "Email open rate as percentage"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
      - name: roi_ratio
        description: "Return on investment ratio"
        tests:
          - dbt_utils.accepted_range:
              min_value: 0
EOF
```

#### Custom Tests

```bash
cat > tests/custom/test_no_empty_marts.sql << 'EOF'
-- Test that our mart tables have data

{% set mart_models = [
    'dm_customer_360',
    'dm_product_performance',
    'dm_sales_summary',
    'dm_campaign_performance'
] %}

{% for model in mart_models %}
    SELECT 
        '{{ model }}' as model_name,
        COUNT(*) as row_count
    FROM {{ ref(model) }}
    HAVING COUNT(*) = 0
    {% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
EOF
```

```bash
cat > tests/custom/test_customer_tier_consistency.sql << 'EOF'
-- Test that customer tier is consistent with spending
-- Gold tier customers should have spent at least $500

WITH inconsistent_customers AS (
    SELECT 
        customer_id,
        customer_tier,
        total_spent
    FROM {{ ref('dm_customer_360') }}
    WHERE 
        (customer_tier = 'gold' AND total_spent < 2000)
        OR (customer_tier = 'silver' AND total_spent < 500)
        OR (customer_tier = 'bronze' AND total_spent < 0)
)

SELECT 
    customer_id,
    customer_tier,
    total_spent,
    'Inconsistent customer tier' as failure_reason
FROM inconsistent_customers
EOF
```

### The Verification

```bash
# 1. Install dbt utility package for additional tests
cat > packages.yml << 'EOF'
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
EOF

# 2. Install the package
dbt deps --project-dir .

# 3. Run all tests
dbt test --project-dir .

# Expected output: All tests should pass (green)

# 4. View test results
# Test results are stored in target/run_results.json
```

---

## Step 6: Documenting the Semantic Layer

### The Target
Generate comprehensive documentation for our semantic layer.

### The Concept
Documentation is the user manual for your data model. dbt auto-generates documentation from your SQL files and YAML configurations, creating a living knowledge base that evolves with your code.

### The Implementation

```bash
# 1. Generate documentation
dbt docs generate --project-dir .

# 2. Serve documentation as a web server
dbt docs serve --project-dir . --port 8080

# Output: "Serving documentation at http://localhost:8080"
# Open in browser to view the documentation

# 3. View the catalog
# The catalog.json file contains all your metadata
cat target/catalog.json | python -m json.tool | head -100
```

---

## Summary of What You've Built

You've successfully created a complete semantic layer with:

1. **Staging models** that clean and prepare raw data
2. **Intermediate models** that combine data for complex business logic
3. **Mart models** that are optimized for specific business domains
4. **Data quality tests** that ensure accuracy and consistency
5. **Auto-generated documentation** for your entire data model

### Semantic Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        MART LAYER                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │ dm_customer_360│  │dm_product_     │  │ dm_sales_     │   │
│  │ (Customer 360) │  │performance    │  │ summary       │   │
│  └────────┬───────┘  └──────┬─────────┘  └──────┬─────────┘   │
│           │                 │                    │             │
│           └─────────────────┼────────────────────┘             │
│                             │                                  │
│                    INTERMEDIATE LAYER                          │
│  ┌──────────────────────────┴──────────────────────────────┐   │
│  │ int_customer_orders_summary                             │   │
│  │ int_product_performance                                 │   │
│  │ int_order_fulfillment_summary                           │   │
│  └──────────────────────────────────────────────────────────┘   │
│                             │                                  │
│                      STAGING LAYER                             │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ stg_customers │ stg_products │ stg_orders │ stg_returns │   │
│  │ stg_categories│ stg_suppliers│ stg_reviews│ stg_campaigns│   │
│  └──────────────────────────────────────────────────────────┘   │
│                             │                                  │
│                     SOURCE LAYER                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ PostgreSQL Schema: analytics                            │   │
│  │ (Raw data from e-commerce database)                     │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## What's Next

Now that we have our semantic layer in place, we'll connect it to our BI tool (Metabase) and create:
- Interactive dashboards
- Executive-facing visualizations
- Self-service analytics capabilities
