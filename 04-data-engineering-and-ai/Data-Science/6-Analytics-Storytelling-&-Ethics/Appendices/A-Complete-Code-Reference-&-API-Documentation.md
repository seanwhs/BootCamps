# Appendix A: Complete Code Reference & API Documentation

## Why Appendices Matter

Before diving into the code, let me explain why I'm including comprehensive appendices:

**Appendices serve as your "cheat sheet"** - they're the reference material you'll keep coming back to long after you've completed the tutorial. Think of them as the **"manual"** for everything you've built.

### What You'll Find in This Appendix
- Complete, copy-pasteable code for every major component
- Environment configuration templates
- Docker and deployment configurations
- Common troubleshooting solutions
- API reference for key libraries
- Database schema documentation
- Testing templates and examples

### How to Use This Appendix
1. **Quick reference:** Need to remember a SQLAlchemy pattern? Jump to Section 5.2
2. **Troubleshooting:** Getting an error? Check Section 9
3. **Deployment:** Ready to go to production? See Section 8
4. **Extending:** Want to add new features? Check the API patterns in Section 6

---

## 1. Complete dbt Model Code Reference

### 1.1 All Staging Models

#### stg_customers.sql
```sql
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
```

#### stg_products.sql
```sql
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
```

#### stg_orders.sql
```sql
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
```

### 1.2 All Mart Models

#### dm_customer_360.sql (Customer 360 View)
```sql
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
```

#### dm_sales_summary.sql (Sales Performance)
```sql
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
        
        COUNT(CASE WHEN payment_method = 'credit_card' THEN 1 END) AS credit_card_orders,
        COUNT(CASE WHEN payment_method = 'paypal' THEN 1 END) AS paypal_orders,
        COUNT(CASE WHEN payment_method IN ('apple_pay', 'google_pay') THEN 1 END) AS digital_wallet_orders,
        
        COUNT(CASE WHEN status = 'completed' THEN 1 END) AS completed_orders,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) AS pending_orders,
        COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled_orders,
        COUNT(CASE WHEN status = 'shipped' THEN 1 END) AS shipped_orders,
        
        COUNT(CASE WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 1 END) AS weekend_orders,
        COUNT(CASE WHEN EXTRACT(DOW FROM order_date) NOT IN (0, 6) THEN 1 END) AS weekday_orders
        
    FROM orders
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
),

monthly_growth AS (
    SELECT
        *,
        LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
        LAG(total_orders) OVER (ORDER BY sales_month) AS previous_month_orders,
        LAG(unique_customers) OVER (ORDER BY sales_month) AS previous_month_customers,
        
        CASE
            WHEN LAG(total_revenue) OVER (ORDER BY sales_month) > 0
            THEN ROUND(((total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month)) / LAG(total_revenue) OVER (ORDER BY sales_month)) * 100, 2)
            ELSE NULL
        END AS revenue_growth_percent,
        
        CASE
            WHEN LAG(total_orders) OVER (ORDER BY sales_month) > 0
            THEN ROUND(((total_orders - LAG(total_orders) OVER (ORDER BY sales_month)) / LAG(total_orders) OVER (ORDER BY sales_month)) * 100, 2)
            ELSE NULL
        END AS order_growth_percent
        
    FROM monthly_sales
)

SELECT * FROM monthly_growth
```

---

## 2. Complete PostgreSQL Schema

### 2.1 Full Database Schema SQL
```sql
-- ====================================================
-- Complete Database Schema: E-commerce Analytics
-- ====================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create schema
CREATE SCHEMA IF NOT EXISTS analytics;

-- ====================================================
-- DIMENSION TABLES
-- ====================================================

-- Customers
CREATE TABLE IF NOT EXISTS analytics.customers (
    customer_id     UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    phone           VARCHAR(20),
    date_of_birth   DATE,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_date TIMESTAMP WITH TIME ZONE,
    is_active       BOOLEAN DEFAULT TRUE,
    is_verified     BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE IF NOT EXISTS analytics.products (
    product_id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku                 VARCHAR(50) NOT NULL UNIQUE,
    name                VARCHAR(200) NOT NULL,
    description         TEXT,
    category_id         UUID,
    supplier_id         UUID,
    unit_price          DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    cost_per_unit       DECIMAL(10, 2) NOT NULL CHECK (cost_per_unit >= 0),
    weight_kg           DECIMAL(8, 3),
    stock_quantity      INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_level       INTEGER DEFAULT 10,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE IF NOT EXISTS analytics.categories (
    category_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(100) NOT NULL UNIQUE,
    description         TEXT,
    parent_category_id  UUID REFERENCES analytics.categories(category_id),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Suppliers
CREATE TABLE IF NOT EXISTS analytics.suppliers (
    supplier_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(200) NOT NULL,
    contact_name        VARCHAR(100),
    contact_email       VARCHAR(255),
    contact_phone       VARCHAR(20),
    address_line1       VARCHAR(200),
    address_line2       VARCHAR(200),
    city                VARCHAR(100),
    state               VARCHAR(50),
    postal_code         VARCHAR(20),
    country             VARCHAR(50),
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================
-- FACT TABLES
-- ====================================================

-- Orders
CREATE TABLE IF NOT EXISTS analytics.orders (
    order_id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id         UUID NOT NULL REFERENCES analytics.customers(customer_id),
    order_date          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status              VARCHAR(50) NOT NULL DEFAULT 'pending',
    shipping_address_line1 VARCHAR(200),
    shipping_address_line2 VARCHAR(200),
    shipping_city       VARCHAR(100),
    shipping_state      VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    shipping_country    VARCHAR(50),
    payment_method      VARCHAR(50),
    payment_status      VARCHAR(50) DEFAULT 'pending',
    subtotal_amount     DECIMAL(10, 2) NOT NULL CHECK (subtotal_amount >= 0),
    tax_amount          DECIMAL(10, 2) DEFAULT 0,
    shipping_amount     DECIMAL(10, 2) DEFAULT 0,
    discount_amount     DECIMAL(10, 2) DEFAULT 0,
    total_amount        DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    notes               TEXT,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Order Items
CREATE TABLE IF NOT EXISTS analytics.order_items (
    order_item_id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id            UUID NOT NULL REFERENCES analytics.orders(order_id) ON DELETE CASCADE,
    product_id          UUID NOT NULL REFERENCES analytics.products(product_id),
    quantity            INTEGER NOT NULL CHECK (quantity > 0),
    unit_price          DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_percent    DECIMAL(5, 2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    total_price         DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(order_id, product_id)
);

-- Returns
CREATE TABLE IF NOT EXISTS analytics.returns (
    return_id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id       UUID NOT NULL REFERENCES analytics.order_items(order_item_id),
    return_reason       VARCHAR(200),
    return_status       VARCHAR(50) DEFAULT 'requested',
    refund_amount       DECIMAL(10, 2) NOT NULL CHECK (refund_amount >= 0),
    refund_date         TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Reviews
CREATE TABLE IF NOT EXISTS analytics.reviews (
    review_id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id          UUID NOT NULL REFERENCES analytics.products(product_id),
    customer_id         UUID NOT NULL REFERENCES analytics.customers(customer_id),
    rating              INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title               VARCHAR(200),
    comment             TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count       INTEGER DEFAULT 0,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, customer_id)
);

-- Marketing Campaigns
CREATE TABLE IF NOT EXISTS analytics.marketing_campaigns (
    campaign_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(200) NOT NULL,
    description         TEXT,
    channel             VARCHAR(50) NOT NULL,
    start_date          TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date            TIMESTAMP WITH TIME ZONE,
    budget              DECIMAL(10, 2) NOT NULL CHECK (budget >= 0),
    cost_per_contact    DECIMAL(10, 2),
    target_audience     JSONB,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Campaign Responses
CREATE TABLE IF NOT EXISTS analytics.campaign_responses (
    response_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id         UUID NOT NULL REFERENCES analytics.marketing_campaigns(campaign_id),
    customer_id         UUID NOT NULL REFERENCES analytics.customers(customer_id),
    response_date       TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    action_taken        VARCHAR(50),
    conversion_value    DECIMAL(10, 2),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(campaign_id, customer_id)
);

-- ====================================================
-- INDEXES
-- ====================================================

CREATE INDEX idx_customers_email ON analytics.customers(email);
CREATE INDEX idx_customers_registration_date ON analytics.customers(registration_date);
CREATE INDEX idx_products_category_id ON analytics.products(category_id);
CREATE INDEX idx_orders_customer_id ON analytics.orders(customer_id);
CREATE INDEX idx_orders_order_date ON analytics.orders(order_date);
CREATE INDEX idx_order_items_order_id ON analytics.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON analytics.order_items(product_id);

-- ====================================================
-- VIEWS
-- ====================================================

CREATE OR REPLACE VIEW analytics.customer_lifetime_value AS
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    COALESCE(MAX(o.order_date), c.registration_date) as last_order_date,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - COALESCE(MAX(o.order_date), c.registration_date))) as days_since_last_order
FROM analytics.customers c
LEFT JOIN analytics.orders o ON c.customer_id = o.customer_id AND o.status NOT IN ('cancelled')
GROUP BY c.customer_id, c.email, c.first_name, c.last_name, c.registration_date;

-- ====================================================
-- TRIGGERS
-- ====================================================

CREATE OR REPLACE FUNCTION analytics.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON analytics.customers
    FOR EACH ROW EXECUTE FUNCTION analytics.update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON analytics.products
    FOR EACH ROW EXECUTE FUNCTION analytics.update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON analytics.orders
    FOR EACH ROW EXECUTE FUNCTION analytics.update_updated_at_column();

-- ====================================================
-- MATERIALIZED VIEWS FOR PERFORMANCE
-- ====================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS analytics_dbt.mv_daily_product_performance AS
SELECT 
    product_id,
    name,
    total_revenue,
    units_sold,
    avg_rating,
    product_health,
    CURRENT_DATE AS snapshot_date
FROM analytics_dbt.dm_product_performance
WITH DATA;

CREATE MATERIALIZED VIEW IF NOT EXISTS analytics_dbt.mv_weekly_kpis AS
SELECT 
    'weekly' AS period,
    SUM(total_revenue) AS total_revenue,
    SUM(total_orders) AS total_orders,
    AVG(avg_order_value) AS avg_order_value,
    CURRENT_DATE AS snapshot_date
FROM analytics_dbt.dm_sales_summary
WHERE sales_month >= CURRENT_DATE - INTERVAL '30 days'
WITH DATA;
```

---

## 3. Complete Environment Configuration

### 3.1 .env File Template
```bash
# ====================================================
# PostgreSQL Configuration
# ====================================================
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=analytics
POSTGRES_USER=analytics_user
POSTGRES_PASSWORD=secure_password_change_me

# ====================================================
# DuckDB Configuration
# ====================================================
DUCKDB_PATH=data/processed/analytics.duckdb

# ====================================================
# Metabase Configuration
# ====================================================
METABASE_PORT=3000
METABASE_DB=metabase
METABASE_USER=metabase_user
METABASE_PASSWORD=secure_password_change_me

# Email Configuration (for reports)
MB_EMAIL_SMTP_HOST=smtp.gmail.com
MB_EMAIL_SMTP_PORT=587
MB_EMAIL_SMTP_USERNAME=your_email@gmail.com
MB_EMAIL_SMTP_PASSWORD=your_app_password
MB_EMAIL_FROM=executive-reports@decisionpipeline.com
MB_EMAIL_SMTP_SECURITY=tls

# ====================================================
# Model Configuration
# ====================================================
MODEL_PATH=models/churn_model.pkl
RANDOM_SEED=42

# ====================================================
# API Configuration (for future use)
# ====================================================
API_HOST=0.0.0.0
API_PORT=8000
API_SECRET_KEY=your_secret_key_here_change_in_production

# ====================================================
# Logging
# ====================================================
LOG_LEVEL=INFO
LOG_FILE=logs/app.log

# ====================================================
# Feature Flags
# ====================================================
ENABLE_FAIRNESS_MITIGATION=true
ENABLE_SHAP_EXPLAINABILITY=true
ENABLE_PRIVACY_ANONYMIZATION=false
```

### 3.2 docker-compose.yml Complete
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    container_name: edp_postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-analytics}
      POSTGRES_USER: ${POSTGRES_USER:-analytics_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-secure_password_change_me}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init_postgres.sql:/docker-entrypoint-initdb.d/init.sql
      - ./scripts/create_schema.sql:/docker-entrypoint-initdb.d/02_create_schema.sql
    networks:
      - edp_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-analytics_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  metabase:
    image: metabase/metabase:v0.47.0
    container_name: edp_metabase
    ports:
      - "3000:3000"
    environment:
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: metabase
      MB_DB_PORT: 5432
      MB_DB_USER: ${POSTGRES_USER:-analytics_user}
      MB_DB_PASS: ${POSTGRES_PASSWORD:-secure_password_change_me}
      MB_DB_HOST: postgres
      MB_JETTY_HOST: 0.0.0.0
      MB_SITE_URL: http://localhost:3000
      # Email settings
      MB_EMAIL_SMTP_HOST: ${MB_EMAIL_SMTP_HOST:-}
      MB_EMAIL_SMTP_PORT: ${MB_EMAIL_SMTP_PORT:-587}
      MB_EMAIL_SMTP_USERNAME: ${MB_EMAIL_SMTP_USERNAME:-}
      MB_EMAIL_SMTP_PASSWORD: ${MB_EMAIL_SMTP_PASSWORD:-}
      MB_EMAIL_FROM: ${MB_EMAIL_FROM:-}
      MB_EMAIL_SMTP_SECURITY: ${MB_EMAIL_SMTP_SECURITY:-tls}
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - edp_network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 5
    restart: unless-stopped

  jupyter:
    image: jupyter/datascience-notebook:latest
    container_name: edp_jupyter
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/home/jovyan/work/notebooks
      - ./data:/home/jovyan/work/data
      - ./src:/home/jovyan/work/src
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_DB=${POSTGRES_DB:-analytics}
      - POSTGRES_USER=${POSTGRES_USER:-analytics_user}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-secure_password_change_me}
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - edp_network
    restart: unless-stopped

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: edp_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@company.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin123}
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - edp_network
    restart: unless-stopped

volumes:
  postgres_data:
  pgadmin_data:

networks:
  edp_network:
    driver: bridge
```

---

## 4. Complete Makefile

```makefile
.PHONY: help setup up down test clean lint format docs deploy

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  %-20s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

# ====================================================
# Environment Setup
# ====================================================

setup: ## Install dependencies and setup environment
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements.txt
	@echo "✅ Environment setup complete"
	@echo "Run 'source venv/bin/activate' to activate the virtual environment"

update: ## Update dependencies
	. venv/bin/activate && pip install -r requirements.txt --upgrade

# ====================================================
# Docker Services
# ====================================================

up: ## Start all Docker services
	docker-compose up -d
	@echo "⏳ Waiting for services to be ready..."
	sleep 10
	docker-compose ps

down: ## Stop all Docker services
	docker-compose down

restart: down up ## Restart all Docker services

logs: ## View Docker logs
	docker-compose logs -f

ps: ## Show Docker service status
	docker-compose ps

# ====================================================
# Database
# ====================================================

db-create: ## Create database schema
	docker-compose exec -T postgres psql -U analytics_user -d analytics < scripts/create_schema.sql
	@echo "✅ Schema created"

db-seed: ## Generate sample data
	python scripts/generate_sample_data.py
	@echo "✅ Sample data generated"

db-reset: down db-create db-seed up ## Reset database (CAUTION: deletes data)

db-connect: ## Connect to database
	docker-compose exec postgres psql -U analytics_user -d analytics

# ====================================================
# dbt
# ====================================================

dbt-debug: ## Debug dbt connection
	dbt debug --project-dir .

dbt-run: ## Run all dbt models
	dbt run --project-dir .

dbt-test: ## Run dbt tests
	dbt test --project-dir .

dbt-docs: ## Generate dbt documentation
	dbt docs generate --project-dir .
	dbt docs serve --project-dir . --port 8080

dbt-refresh: ## Refresh all dbt models
	dbt run --project-dir . --full-refresh

# ====================================================
# Model Training
# ====================================================

train: ## Train churn prediction model
	python src/explainability/churn_model.py

explain: ## Generate SHAP explanations
	python src/explainability/shap_explainer.py

fairness: ## Run fairness analysis
	python src/explainability/fairness_analysis.py

# ====================================================
# Testing
# ====================================================

test: ## Run all tests
	. venv/bin/activate && pytest tests/ -v --cov=src --cov-report=html

test-unit: ## Run unit tests only
	. venv/bin/activate && pytest tests/unit/ -v

test-integration: ## Run integration tests
	. venv/bin/activate && pytest tests/integration/ -v

test-all: test dbt-test ## Run all tests (includes dbt)

# ====================================================
# Code Quality
# ====================================================

format: ## Format code with black
	. venv/bin/activate && black src/ tests/ scripts/

lint: ## Lint code with flake8
	. venv/bin/activate && flake8 src/ tests/ scripts/

type-check: ## Type check with mypy
	. venv/bin/activate && mypy src/

pre-commit: ## Run all pre-commit checks
	. venv/bin/activate && pre-commit run --all-files

# ====================================================
# Documentation
# ====================================================

docs: ## Generate all documentation
	make dbt-docs
	make docs-sphinx

docs-sphinx: ## Generate Sphinx documentation
	. venv/bin/activate && cd docs && make html

# ====================================================
# Capstone
# ====================================================

capstone: ## Generate Executive Decision Pack
	python capstone/scripts/generate_capstone.py

capstone-check: ## Verify capstone integration
	python capstone/scripts/check_integration.py

# ====================================================
# Cleanup
# ====================================================

clean: ## Clean temporary files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name ".coverage" -delete
	rm -rf .pytest_cache/ .coverage htmlcov/
	rm -rf dist/ build/ *.egg-info/
	rm -rf target/ dbt_packages/
	@echo "✅ Cleaned temporary files"

clean-all: down clean ## Clean everything (including Docker volumes)
	docker-compose down -v
	rm -rf venv/
	rm -rf data/processed/*
	rm -rf models/*.pkl
	rm -rf logs/
	@echo "✅ Cleaned everything"

# ====================================================
# Deployment
# ====================================================

deploy: ## Deploy to production (requires proper configuration)
	@echo "🚀 Deploying to production..."
	@echo "⚠️  This requires proper environment configuration"
	@echo "Setting production environment..."
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

deploy-check: ## Check deployment readiness
	@echo "🔍 Checking deployment readiness..."
	python scripts/verify_setup.py
	python capstone/scripts/check_integration.py
	@echo "✅ Deployment readiness check complete"

# ====================================================
# Development
# ====================================================

dev: ## Start development environment
	make up
	make db-create
	make db-seed
	make dbt-run
	make train
	make capstone
	@echo "✅ Development environment ready"
	@echo "   🌐 Metabase: http://localhost:3000"
	@echo "   📓 Jupyter: http://localhost:8888"
	@echo "   📊 Dashboard: http://localhost:3000/dashboard/1"

shell: ## Open Python shell with project context
	. venv/bin/activate && python -c "import sys; sys.path.append('.'); import src; from src.database.postgres import get_client; print('✅ Interactive Python shell ready'); print('   Client: get_client()')"

# ====================================================
# Monitoring
# ====================================================

monitor: ## Run monitoring dashboard
	python scripts/monitor.py

health: ## Check service health
	@echo "🔍 Checking services..."
	curl -s http://localhost:3000/api/health | python -m json.tool || echo "⚠️ Metabase not running"
	docker-compose exec postgres pg_isready -U analytics_user || echo "⚠️ PostgreSQL not ready"
	@echo "✅ Health check complete"

# ====================================================
# Security
# ====================================================

security: ## Run security checks
	. venv/bin/activate && safety check -r requirements.txt
	. venv/bin/activate && bandit -r src/
	@echo "✅ Security check complete"
```

---

## 5. Common Troubleshooting Guide

### 5.1 Database Connection Issues

**Problem:** `"psycopg2.OperationalError: could not connect to server"`

**Solutions:**
```bash
# 1. Check if PostgreSQL is running
docker-compose ps postgres

# 2. Check logs for errors
docker-compose logs postgres

# 3. Restart PostgreSQL
docker-compose restart postgres

# 4. Verify connection parameters
docker-compose exec postgres psql -U analytics_user -d analytics -c "SELECT 1"
```

### 5.2 dbt Connection Issues

**Problem:** `"Runtime Error: Could not find profile"`

**Solutions:**
```bash
# 1. Verify profile exists
cat ~/.dbt/profiles.yml

# 2. Test dbt connection
dbt debug --project-dir .

# 3. Check dbt_project.yml has correct profile name
grep "profile:" dbt_project.yml
```

### 5.3 Metabase Issues

**Problem:** `"Metabase won't start"`

**Solutions:**
```bash
# 1. Check logs
docker-compose logs metabase

# 2. Verify database is ready
docker-compose exec postgres pg_isready

# 3. Reset Metabase
docker-compose restart metabase

# 4. Check if port is in use
lsof -i :3000
```

### 5.4 Memory Issues

**Problem:** `"MemoryError"` or `"Out of memory"`

**Solutions:**
```bash
# 1. Limit Docker memory
# Add to docker-compose.yml:
# services:
#   postgres:
#     mem_limit: 2g

# 2. Reduce sample size in data generation
# Edit scripts/generate_sample_data.py:
# NUM_CUSTOMERS = 1000  # Reduce from 5000
# NUM_ORDERS = 3000     # Reduce from 15000

# 3. Use smaller SHAP sample
# Edit src/explainability/shap_explainer.py:
# shap_values = explainer.calculate_shap_values(sample_size=50)  # Reduce from 200
```

### 5.5 Permission Issues

**Problem:** `"Permission denied"`

**Solutions:**
```bash
# 1. Fix file permissions
chmod -R 755 scripts/ src/ capstone/

# 2. Fix Docker volume permissions
docker-compose down
docker volume rm $(docker volume ls -q | grep edp)
docker-compose up -d

# 3. Fix virtual environment permissions
chmod -R u+w venv/
```

### 5.6 Quick Reference: Common Commands

| Problem | Command |
|---------|---------|
| Service won't start | `docker-compose logs --tail=50` |
| Can't connect to DB | `docker-compose exec postgres pg_isready` |
| dbt models failing | `dbt run --debug --project-dir .` |
| Tests failing | `pytest -v --tb=short` |
| Need to reset everything | `make clean-all && make dev` |
| View database contents | `docker-compose exec postgres psql -U analytics_user -d analytics` |

---

## 6. API Reference: Key Libraries

### 6.1 SQLAlchemy Common Patterns

```python
# ====================================================
# Connection Patterns
# ====================================================

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Basic connection
engine = create_engine('postgresql://user:pass@localhost:5432/db')
with engine.connect() as conn:
    result = conn.execute(text("SELECT * FROM table"))
    rows = result.fetchall()

# Connection with context manager
class DatabaseManager:
    def __enter__(self):
        self.conn = engine.connect()
        return self.conn
    
    def __exit__(self, *args):
        self.conn.close()

# Transaction management
with engine.begin() as conn:
    conn.execute(text("INSERT INTO users (name) VALUES ('Alice')"))
    # Auto-commits on success, rolls back on exception

# ====================================================
# Query Patterns
# ====================================================

# Parameterized queries
result = conn.execute(
    text("SELECT * FROM users WHERE age > :min_age"),
    {"min_age": 18}
)

# Batch operations
conn.execute(
    text("INSERT INTO users (name) VALUES (:name)"),
    [{"name": "Alice"}, {"name": "Bob"}]
)

# ====================================================
# Connection Pooling
# ====================================================

from sqlalchemy.pool import QueuePool

engine = create_engine(
    'postgresql://user:pass@localhost:5432/db',
    poolclass=QueuePool,
    pool_size=5,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=3600
)
```

### 6.2 Pandas Common Patterns

```python
# ====================================================
# Reading Data
# ====================================================

import pandas as pd

# From SQL
df = pd.read_sql("SELECT * FROM table", engine)

# From CSV
df = pd.read_csv('data.csv')

# From JSON
df = pd.read_json('data.json')

# ====================================================
# Data Cleaning
# ====================================================

# Handle missing values
df.fillna(df.mean(), inplace=True)
df.dropna(subset=['important_column'], inplace=True)

# Convert data types
df['date'] = pd.to_datetime(df['date'])
df['numeric'] = pd.to_numeric(df['numeric'], errors='coerce')

# Rename columns
df.rename(columns={'old_name': 'new_name'}, inplace=True)

# ====================================================
# Data Manipulation
# ====================================================

# Filtering
filtered = df[df['column'] > 100]
filtered = df[(df['column1'] > 0) & (df['column2'] == 'active')]

# Grouping
grouped = df.groupby('category').agg({
    'revenue': 'sum',
    'quantity': 'mean',
    'id': 'count'
}).reset_index()

# Merging
merged = pd.merge(df1, df2, on='key', how='left')

# ====================================================
# Exporting
# ====================================================

# To CSV
df.to_csv('output.csv', index=False)

# To SQL
df.to_sql('table', engine, if_exists='replace', index=False)
```

### 6.3 scikit-learn Common Patterns

```python
# ====================================================
# Train/Test Split
# ====================================================

from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# ====================================================
# Preprocessing
# ====================================================

from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline

# Numerical preprocessing
numeric_transformer = Pipeline(steps=[
    ('scaler', StandardScaler())
])

# Categorical preprocessing
categorical_transformer = Pipeline(steps=[
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

# Combined preprocessor
preprocessor = ColumnTransformer(
    transformers=[
        ('num', numeric_transformer, numeric_features),
        ('cat', categorical_transformer, categorical_features)
    ]
)

# ====================================================
# Model Training
# ====================================================

from sklearn.ensemble import RandomForestClassifier
from xgboost import XGBClassifier

# Random Forest
rf = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    random_state=42
)
rf.fit(X_train, y_train)

# XGBoost
xgb = XGBClassifier(
    n_estimators=100,
    max_depth=5,
    learning_rate=0.1,
    random_state=42
)
xgb.fit(X_train, y_train)

# Full pipeline
pipeline = Pipeline(steps=[
    ('preprocessor', preprocessor),
    ('classifier', classifier)
])
pipeline.fit(X_train, y_train)

# ====================================================
# Evaluation
# ====================================================

from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score

y_pred = pipeline.predict(X_test)
y_pred_proba = pipeline.predict_proba(X_test)[:, 1]

metrics = {
    'accuracy': accuracy_score(y_test, y_pred),
    'precision': precision_score(y_test, y_pred),
    'recall': recall_score(y_test, y_pred),
    'f1': f1_score(y_test, y_pred),
    'roc_auc': roc_auc_score(y_test, y_pred_proba)
}
```

### 6.4 SHAP Common Patterns

```python
# ====================================================
# Basic SHAP Usage
# ====================================================

import shap
import numpy as np

# For tree-based models (XGBoost, RandomForest)
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X_test)

# For any model (slower but more general)
def predict_fn(X):
    return model.predict_proba(X)

explainer = shap.KernelExplainer(predict_fn, X_background)
shap_values = explainer.shap_values(X_test, nsamples=100)

# ====================================================
# Visualization
# ====================================================

# Summary plot (feature importance)
shap.summary_plot(shap_values, X_test, feature_names=feature_names)

# Bar plot (mean |SHAP|)
shap.summary_plot(shap_values, X_test, plot_type="bar")

# Waterfall plot (single prediction)
shap.waterfall_plot(
    shap.Explanation(
        values=shap_values[0],
        base_values=explainer.expected_value,
        data=X_test.iloc[0],
        feature_names=feature_names
    )
)

# Force plot (alternative to waterfall)
shap.force_plot(explainer.expected_value, shap_values[0], X_test.iloc[0])
```

---

## 7. Complete Testing Templates

### 7.1 Database Test Template

```python
# tests/test_database.py
import pytest
from src.database.postgres import get_client

class TestDatabase:
    """Test database connectivity and operations."""
    
    @pytest.fixture
    def client(self):
        return get_client()
    
    def test_connection(self, client):
        """Test database connection."""
        result = client.execute_query("SELECT 1 as test")
        assert result[0]['test'] == 1
    
    def test_table_exists(self, client):
        """Test if required tables exist."""
        tables = ['customers', 'orders', 'products', 'order_items']
        for table in tables:
            assert client.table_exists(table)
    
    def test_data_count(self, client):
        """Test data is populated."""
        count = client.get_table_count('customers')
        assert count > 0, "Customers table is empty"
    
    def test_foreign_keys(self, client):
        """Test foreign key integrity."""
        result = client.execute_query("""
            SELECT COUNT(*) as orphaned
            FROM analytics.orders o
            LEFT JOIN analytics.customers c ON o.customer_id = c.customer_id
            WHERE c.customer_id IS NULL
        """)
        assert result[0]['orphaned'] == 0
```

### 7.2 Model Test Template

```python
# tests/test_model.py
import pytest
import pandas as pd
import numpy as np
from src.explainability.churn_model import ChurnPredictor

class TestChurnModel:
    """Test churn prediction model."""
    
    @pytest.fixture
    def predictor(self):
        return ChurnPredictor()
    
    @pytest.fixture
    def sample_data(self):
        """Generate sample data for testing."""
        return pd.DataFrame({
            'age': [25, 35, 45],
            'total_orders': [5, 10, 3],
            'total_spent': [500, 1000, 200],
            'customer_health_score': [80, 90, 60],
            'customer_tier': ['silver', 'gold', 'bronze'],
            'is_verified': [True, True, False]
        })
    
    def test_data_loading(self, predictor):
        """Test data loading."""
        df = predictor.load_data()
        assert len(df) > 0
        assert 'churn' in df.columns
    
    def test_feature_preparation(self, predictor, sample_data):
        """Test feature preparation."""
        X, y, metadata = predictor.prepare_features(sample_data)
        assert len(X) == len(y)
        assert len(X.columns) > 0
        assert 'feature_names' in metadata
    
    def test_model_training(self, predictor, sample_data):
        """Test model training."""
        X, y, _ = predictor.prepare_features(sample_data)
        metrics = predictor.train(X, y)
        
        assert 'accuracy' in metrics
        assert metrics['accuracy'] > 0
        assert metrics['roc_auc'] > 0
    
    def test_prediction(self, predictor, sample_data):
        """Test model predictions."""
        X, y, _ = predictor.prepare_features(sample_data)
        predictor.train(X, y)
        
        predictions = predictor.predict(X)
        assert len(predictions) == len(X)
        assert set(predictions) <= {0, 1}
```

---

## 8. Deployment Checklist

### 8.1 Pre-Deployment Checklist
```markdown
# Production Deployment Checklist

## Environment Configuration
- [ ] .env file created with production credentials
- [ ] Secret keys rotated from default values
- [ ] Database passwords updated
- [ ] SSL/TLS configured for database connections
- [ ] Email settings configured for reports
- [ ] Log level set to WARNING or ERROR

## Database
- [ ] Database backups configured
- [ ] Connection pooling optimized for production
- [ ] Indexes verified for all queries
- [ ] Materialized views refresh schedule configured
- [ ] Read replicas set up if needed

## Models
- [ ] Model trained on production data
- [ ] Model performance validated on test set
- [ ] Fairness metrics verified
- [ ] Explainability reports generated
- [ ] Model versioning implemented

## Dashboard
- [ ] Metabase configuration verified
- [ ] Dashboard permissions configured
- [ ] Scheduled reports set up
- [ ] Caching enabled
- [ ] Performance tested (load time < 3 seconds)

## Security
- [ ] Network security groups configured
- [ ] API authentication enabled
- [ ] Data encryption at rest enabled
- [ ] Audit logging enabled
- [ ] GDPR/CCPA compliance verified

## Monitoring
- [ ] Health checks configured
- [ ] Alerts set up for critical failures
- [ ] Performance monitoring enabled
- [ ] Usage analytics configured
- [ ] Error tracking implemented

## Disaster Recovery
- [ ] Backup schedule configured
- [ ] Restoration procedure tested
- [ ] Failover plan documented
- [ ] RTO/RPO defined
- [ ] Contact information for emergency team
```

### 8.2 Production Configuration Override

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  postgres:
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - prod_postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G

  metabase:
    environment:
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: metabase
      MB_DB_PORT: 5432
      MB_DB_USER: ${POSTGRES_USER}
      MB_DB_PASS: ${POSTGRES_PASSWORD}
      MB_DB_HOST: postgres
      MB_JETTY_HOST: 0.0.0.0
      MB_SITE_URL: https://your-domain.com
      MB_EMAIL_SMTP_HOST: ${MB_EMAIL_SMTP_HOST}
      MB_EMAIL_SMTP_PORT: ${MB_EMAIL_SMTP_PORT}
      MB_EMAIL_SMTP_USERNAME: ${MB_EMAIL_SMTP_USERNAME}
      MB_EMAIL_SMTP_PASSWORD: ${MB_EMAIL_SMTP_PASSWORD}
      MB_EMAIL_FROM: ${MB_EMAIL_FROM}
      MB_EMAIL_SMTP_SECURITY: ${MB_EMAIL_SMTP_SECURITY}
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G

volumes:
  prod_postgres_data:
```

---

## 9. Quick Reference Cards

### 9.1 dbt Commands Quick Reference

| Command | Description |
|---------|-------------|
| `dbt run` | Run all models |
| `dbt run --models tag:staging` | Run staging models only |
| `dbt run --models +dm_customer_360` | Run model and dependencies |
| `dbt test` | Run all tests |
| `dbt test --select tag:core` | Run core tests only |
| `dbt docs generate` | Generate documentation |
| `dbt docs serve` | Serve documentation locally |
| `dbt compile` | Compile SQL without running |
| `dbt debug` | Debug connection |
| `dbt deps` | Install packages |

### 9.2 Docker Commands Quick Reference

| Command | Description |
|---------|-------------|
| `docker-compose up -d` | Start services in background |
| `docker-compose down` | Stop all services |
| `docker-compose ps` | List running services |
| `docker-compose logs -f` | Follow logs |
| `docker-compose exec postgres bash` | Open shell in container |
| `docker-compose restart metabase` | Restart specific service |
| `docker-compose build` | Rebuild images |

### 9.3 PostgreSQL Quick Reference

| Command | Description |
|---------|-------------|
| `\l` | List databases |
| `\dt` | List tables |
| `\d table_name` | Describe table |
| `\df` | List functions |
| `\dv` | List views |
| `\du` | List users |
| `\timing` | Toggle query timing |
| `\q` | Quit psql |

### 9.4 Python Package Version Reference

```bash
# Core data processing
pandas==2.0.3
numpy==1.24.3

# Database
sqlalchemy==2.0.19
psycopg2-binary==2.9.7
duckdb==0.9.0

# Machine Learning
scikit-learn==1.3.0
xgboost==1.7.6

# Explainability
shap==0.42.1
lime==0.2.0.1
fairlearn==0.10.0

# BI & Visualization
metabase==0.47.0
plotly==5.17.0
matplotlib==3.7.2

# Development
jupyterlab==4.0.3
pytest==7.4.0
black==23.7.0
flake8==6.1.0
mypy==1.5.1

# Utilities
python-dotenv==1.0.0
pyyaml==6.0.1
click==8.1.7
```

---

## 10. Appendix Summary

### What This Appendix Covers

| Section | Content | Use Case |
|---------|---------|----------|
| 1 | Complete dbt models | Reference for all SQL transformations |
| 2 | PostgreSQL schema | Database design reference |
| 3 | Environment configs | Production deployment setup |
| 4 | Complete Makefile | Automation commands |
| 5 | Troubleshooting guide | Fix common issues |
| 6 | API reference | Code patterns for key libraries |
| 7 | Test templates | Write your own tests |
| 8 | Deployment checklist | Production readiness |
| 9 | Quick reference cards | Fast command lookup |
| 10 | This summary | Navigation guide |

---

**[END OF APPENDIX A]**
