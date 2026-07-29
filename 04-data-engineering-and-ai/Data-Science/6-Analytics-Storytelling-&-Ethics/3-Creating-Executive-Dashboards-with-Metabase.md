# Module 6.1: Dashboard Engineering & BI Semantic Layers
## Part 3: Creating Executive Dashboards with Metabase

### The Target

We're building a comprehensive executive dashboard in Metabase that transforms our semantic layer data into actionable business intelligence. This dashboard will be the primary interface for non-technical stakeholders to monitor business health, identify trends, and make data-driven decisions.

### The Concept

Think of Metabase as a **"GPS for your business data."** Just as a GPS translates complex map data into simple, actionable directions, Metabase translates your database tables into:
- **Visual dashboards** that show business health at a glance
- **Interactive charts** that allow exploration without SQL
- **Automated reports** that deliver insights to stakeholders
- **Self-service analytics** that let users answer their own questions

The key is **designing for the executive audience:**
- **Clarity over complexity:** Every chart should tell one clear story
- **Actionability over volume:** Show metrics that drive decisions
- **Consistency over variety:** Use the same metrics defined in our semantic layer
- **Performance over flexibility:** Pre-aggregate for speed

---

## Step 1: Setting Up Metabase

### The Target
Configure Metabase and connect it to our PostgreSQL database.

### The Concept
Metabase runs in a Docker container (we already set this up in Part 1). Now we'll initialize it, connect it to our analytics database, and configure it for our stakeholders.

### The Implementation

```bash
# 1. First, let's ensure Metabase is running
docker-compose ps metabase

# If it's not running, start it
docker-compose up -d metabase

# 2. Wait for Metabase to be ready (about 30 seconds)
echo "Waiting for Metabase to initialize..."
sleep 30

# 3. Check Metabase health
curl -s http://localhost:3000/api/health | python -m json.tool
```

Now open your browser and go to `http://localhost:3000`. You'll see the Metabase setup wizard:

**Step 1: Create an admin account**
- **First name:** `Executive`
- **Last name:** `Admin`
- **Email:** `executive@decisionpipeline.com`
- **Password:** `SecurePassword123!`

**Step 2: Add your data**
- **Database name:** `Analytics Database`
- **Database type:** `PostgreSQL`
- **Host:** `postgres` (the Docker service name)
- **Port:** `5432`
- **Database name:** `analytics`
- **Username:** `analytics_user`
- **Password:** `secure_password_change_me`
- **Use SSL:** `No`

Click "Save" to connect.

**Step 3: Let Metabase sync data**
Wait for the "Syncing" message to complete (takes 1-2 minutes).

**Step 4: Choose what to do next**
Select "I'll add my data later" - we'll manually create questions and dashboards.

### The Verification

```bash
# 1. Verify Metabase can connect to the database
curl -s -X GET "http://localhost:3000/api/database" \
  -H "Content-Type: application/json" \
  | python -m json.tool

# 2. Check that our tables are visible
curl -s -X GET "http://localhost:3000/api/table" \
  -H "Content-Type: application/json" \
  | python -m json.tool | grep "display_name"

# Expected output: Shows our dbt mart tables (dm_customer_360, dm_product_performance, etc.)
```

---

## Step 2: Creating Metabase Questions

### The Target
Create the foundational questions (SQL queries) that will power our dashboard visualizations.

### The Concept
In Metabase, a "Question" is a saved query - it's the atomic unit of analysis. Think of questions as the "ingredients" in our dashboard recipe. We'll create questions that:
- **Reference our mart models** (the semantic layer)
- **Return only the data needed** for specific visualizations
- **Are optimized for performance** (using aggregates, not raw data)
- **Have clear, business-friendly names** (no technical jargon)

### The Implementation

We'll create questions using Metabase's "Native Query" mode with SQL. In a real deployment, you'd create these through the UI, but I'll provide the SQL for each question.

#### Question 1: Executive Dashboard - Monthly Revenue Trend

```sql
-- Question: Monthly Revenue Trend
-- Description: Shows revenue trends over time with growth percentages
-- Type: Line chart

SELECT 
    sales_month,
    total_orders,
    total_revenue,
    avg_order_value,
    revenue_growth_percent,
    completion_rate
FROM analytics_dbt.dm_sales_summary
WHERE sales_month >= CURRENT_DATE - INTERVAL '12 months'
ORDER BY sales_month;
```

#### Question 2: Executive Dashboard - Top Products by Revenue

```sql
-- Question: Top Products by Revenue
-- Description: Shows products generating the most revenue
-- Type: Bar chart

SELECT 
    name AS product_name,
    category_name,
    total_revenue,
    units_sold,
    avg_rating,
    product_health
FROM analytics_dbt.dm_product_performance
WHERE is_active = true
ORDER BY total_revenue DESC
LIMIT 20;
```

#### Question 3: Executive Dashboard - Customer Health Distribution

```sql
-- Question: Customer Health Distribution
-- Description: Shows distribution of customer health scores
-- Type: Histogram

SELECT 
    customer_tier,
    churn_risk,
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_health_score), 2) AS avg_health_score,
    ROUND(AVG(projected_lifetime_value), 2) AS avg_clv
FROM analytics_dbt.dm_customer_360
GROUP BY customer_tier, churn_risk
ORDER BY customer_tier, churn_risk;
```

#### Question 4: Executive Dashboard - Campaign ROI

```sql
-- Question: Campaign ROI
-- Description: Shows performance of marketing campaigns
-- Type: Scatter plot or table

SELECT 
    name AS campaign_name,
    channel,
    campaign_status,
    budget,
    total_responses,
    total_conversion_value,
    roi_ratio,
    cost_per_acquisition,
    open_rate,
    conversion_rate
FROM analytics_dbt.dm_campaign_performance
WHERE campaign_status IN ('active', 'completed')
ORDER BY roi_ratio DESC;
```

#### Question 5: Executive Dashboard - Sales by Payment Method

```sql
-- Question: Sales by Payment Method
-- Description: Shows payment method preferences
-- Type: Pie chart

SELECT 
    sales_month,
    credit_card_orders,
    paypal_orders,
    digital_wallet_orders,
    -- Calculate percentages
    ROUND((credit_card_orders * 100.0 / total_orders), 2) AS credit_card_percent,
    ROUND((paypal_orders * 100.0 / total_orders), 2) AS paypal_percent,
    ROUND((digital_wallet_orders * 100.0 / total_orders), 2) AS wallet_percent
FROM analytics_dbt.dm_sales_summary
WHERE sales_month = (
    SELECT MAX(sales_month) 
    FROM analytics_dbt.dm_sales_summary
);
```

#### Question 6: Executive Dashboard - Product Inventory Health

```sql
-- Question: Product Inventory Health
-- Description: Shows inventory status across products
-- Type: Donut chart

SELECT 
    stock_status,
    COUNT(*) AS product_count,
    ROUND(SUM(current_stock_value), 2) AS total_stock_value,
    ROUND(AVG(inventory_turnover_ratio), 2) AS avg_turnover
FROM analytics_dbt.dm_product_performance
GROUP BY stock_status;
```

#### Question 7: Executive Dashboard - Customer Acquisition vs Churn

```sql
-- Question: Customer Acquisition vs Churn
-- Description: Shows customer movement over time
-- Type: Bar chart

WITH monthly_activity AS (
    SELECT 
        DATE_TRUNC('month', registration_date) AS month,
        COUNT(*) AS new_customers
    FROM analytics_dbt.stg_customers
    GROUP BY DATE_TRUNC('month', registration_date)
),

monthly_churn AS (
    SELECT 
        DATE_TRUNC('month', last_order_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers,
        LAG(COUNT(DISTINCT customer_id)) OVER (ORDER BY DATE_TRUNC('month', last_order_date)) AS previous_month_active
    FROM analytics_dbt.dm_customer_360
    WHERE last_order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', last_order_date)
)

SELECT 
    COALESCE(a.month, c.month) AS month,
    COALESCE(a.new_customers, 0) AS new_customers,
    GREATEST(0, COALESCE(c.previous_month_active, 0) - COALESCE(c.active_customers, 0)) AS churned_customers,
    COALESCE(c.active_customers, 0) AS active_customers
FROM monthly_activity a
FULL OUTER JOIN monthly_churn c ON a.month = c.month
WHERE a.month >= CURRENT_DATE - INTERVAL '12 months'
ORDER BY month;
```

#### Question 8: Executive Dashboard - Key Performance Indicators (KPIs)

```sql
-- Question: KPIs
-- Description: Single-value metrics for the dashboard header
-- Type: Scalar

WITH current_month AS (
    SELECT 
        MAX(sales_month) AS latest_month
    FROM analytics_dbt.dm_sales_summary
),

latest_metrics AS (
    SELECT 
        s.total_revenue,
        s.total_orders,
        s.unique_customers AS monthly_active_customers,
        s.avg_order_value,
        s.completion_rate
    FROM analytics_dbt.dm_sales_summary s
    WHERE s.sales_month = (SELECT latest_month FROM current_month)
),

customer_metrics AS (
    SELECT 
        COUNT(*) AS total_customers,
        ROUND(AVG(customer_health_score), 2) AS avg_health_score,
        ROUND(AVG(projected_lifetime_value), 2) AS avg_clv
    FROM analytics_dbt.dm_customer_360
),

product_metrics AS (
    SELECT 
        COUNT(*) AS total_products,
        ROUND(AVG(avg_rating), 2) AS avg_product_rating
    FROM analytics_dbt.dm_product_performance
    WHERE is_active = true
)

SELECT 
    lm.total_revenue,
    lm.total_orders,
    lm.monthly_active_customers,
    lm.avg_order_value,
    lm.completion_rate,
    cm.total_customers,
    cm.avg_health_score,
    cm.avg_clv,
    pm.total_products,
    pm.avg_product_rating
FROM latest_metrics lm
CROSS JOIN customer_metrics cm
CROSS JOIN product_metrics pm;
```

### The Verification

```bash
# 1. Test each question query directly in PostgreSQL
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT sales_month, total_revenue, revenue_growth_percent 
FROM analytics_dbt.dm_sales_summary 
ORDER BY sales_month DESC 
LIMIT 6;"

# Expected output: Shows monthly revenue with growth rates

# 2. Verify the KPIs query works
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT total_revenue, total_orders, avg_order_value 
FROM analytics_dbt.dm_sales_summary 
ORDER BY sales_month DESC 
LIMIT 1;"
```

---

## Step 3: Building the Dashboard in Metabase UI

### The Target
Create the actual dashboard layout in Metabase with proper visualizations.

### The Concept
Since we're building this through the UI, I'll provide step-by-step instructions for creating each visualization. Think of this as interior design for data - we want a dashboard that's:
- **Intuitive:** Users know where to look first
- **Hierarchical:** KPIs at top, trends in middle, details at bottom
- **Consistent:** Same colors, fonts, and formatting throughout
- **Actionable:** Each visualization should raise questions or suggest actions

### The Implementation

#### Step 3.1: Login and Create Dashboard

```
1. Open http://localhost:3000
2. Login with your credentials:
   - Email: executive@decisionpipeline.com
   - Password: SecurePassword123!
3. Click the "+" button in the top right
4. Select "New Dashboard"
5. Name it: "Executive Decision Pack Dashboard"
6. Description: "Real-time business health monitoring for strategic decisions"
7. Click "Create"
8. Note the Dashboard ID in the URL (e.g., http://localhost:3000/dashboard/1)
```

#### Step 3.2: Create Individual Questions

**For each question, follow these steps:**

```
1. Click the "+" button in the top right
2. Select "New Question"
3. Click "Native Query" at the bottom
4. Paste the SQL from the question above
5. Click "Preview" to see the data
6. If the data looks correct, click "Save"
7. Name the question (use the names I provided above)
8. Click "Save"
9. Close the question
```

**Create all 8 questions** using this process:
1. Executive Dashboard - Monthly Revenue Trend
2. Executive Dashboard - Top Products by Revenue
3. Executive Dashboard - Customer Health Distribution
4. Executive Dashboard - Campaign ROI
5. Executive Dashboard - Sales by Payment Method
6. Executive Dashboard - Product Inventory Health
7. Executive Dashboard - Customer Acquisition vs Churn
8. Executive Dashboard - Key Performance Indicators (KPIs)

#### Step 3.3: Add Questions to Dashboard

```
1. Navigate to your dashboard
2. Click "Edit dashboard" (pencil icon at top right)
3. Click "Add Card" or the "+" in the bottom left
4. Select "Question"
5. Choose one of the questions you created
6. Click "Add"
7. The card will appear on the dashboard
8. Drag to position it where you want
```

#### Step 3.4: Dashboard Layout Configuration

Here's the recommended layout for an executive dashboard:

```
┌─────────────────────────────────────────────────────────────────────┐
│ KPI ROW (6 cards, all same height)                                │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐     │
│ │ Total       │ │ Revenue    │ │ Avg Order  │ │ Customer   │     │
│ │ Revenue     │ │ Growth     │ │ Value      │ │ Health     │     │
│ │ $1.2M      │ │ ▲ 12.5%   │ │ $85.40    │ │ Score 78.2 │     │
│ └────────────┘ └────────────┘ └────────────┘ └────────────┘     │
│ ┌────────────┐ ┌────────────┐                                     │
│ │ Active      │ │ Completion │                                     │
│ │ Customers   │ │ Rate      │                                     │
│ │ 4,258      │ │ 94.7%     │                                     │
│ └────────────┘ └────────────┘                                     │
├─────────────────────────────────────────────────────────────────────┤
│ TREND ROW (2 charts, double height)                               │
│ ┌────────────────────────┐ ┌────────────────────────┐            │
│ │ Monthly Revenue Trend   │ │ Customer Acquisition    │            │
│ │ (Line Chart)            │ │ vs Churn (Bar Chart)   │            │
│ │                         │ │                         │            │
│ │                         │ │                         │            │
│ └────────────────────────┘ └────────────────────────┘            │
├─────────────────────────────────────────────────────────────────────┤
│ DETAIL ROW (4 charts, single height)                              │
│ ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐     │
│ │ Top        │ │ Customer   │ │ Payment    │ │ Product    │     │
│ │ Products   │ │ Health     │ │ Methods    │ │ Inventory  │     │
│ │ (Table)    │ │ Dist.      │ │ (Pie)      │ │ (Donut)    │     │
│ │            │ │ (Histogram)│ │            │ │            │     │
│ └────────────┘ └────────────┘ └────────────┘ └────────────┘     │
├─────────────────────────────────────────────────────────────────────┤
│ BOTTOM ROW (Campaign Performance, full width)                    │
│ ┌─────────────────────────────────────────────────────────────────┐ │
│ │ Campaign ROI Dashboard (Table with conditional formatting)     │ │
│ │ Campaign │ Channel │ Budget │ ROI │ Cost/Acquisition │ Status │ │
│ │ Summer   │ Email   │ $15K  │ 3.2 │ $42.50           │ Active │ │
│ │ Holiday  │ Social  │ $25K  │ 2.8 │ $38.20           │ Done   │ │
│ └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

#### Step 3.5: Configure Each Chart's Visual Settings

**Monthly Revenue Trend (Line Chart):**
```
1. Click the card to open it
2. Click the "Visualization" icon (bar chart icon)
3. Select "Line"
4. Configure:
   - X-axis: sales_month
   - Y-axis: total_revenue
   - Series options:
     - Color: Blue (#4C9F70)
     - Line style: Solid
     - Show data points: Yes
5. Add a second series:
   - Add series: Select "Executive Dashboard - Monthly Revenue Trend"
   - Field: revenue_growth_percent
   - Use right Y-axis
   - Color: Orange
6. Click "Done"
7. Click "Update"
```

**Top Products Table:**
```
1. Open the card
2. Click "Visualization" icon
3. Select "Table"
4. Configure columns:
   - Product Name: width 20%
   - Category: width 15%
   - Revenue: width 15%, format as currency
   - Units Sold: width 12%
   - Rating: width 10%, show stars
   - Health: width 10%
5. Add conditional formatting:
   - If health = "star": green background
   - If health = "needs_improvement": red background
6. Click "Done"
7. Click "Update"
```

**Customer Health Distribution (Bar Chart):**
```
1. Open the card
2. Click "Visualization" icon
3. Select "Bar"
4. Configure:
   - X-axis: customer_tier
   - Y-axis: customer_count
   - Group by: churn_risk
5. Click "Done"
6. Click "Update"
```

**Campaign ROI (Table with formatting):**
```
1. Open the card
2. Click "Visualization" icon
3. Select "Table"
4. Configure columns:
   - Campaign Name: width 20%
   - Channel: width 10%
   - Budget: width 12%, currency
   - ROI: width 12%, 2 decimals
   - Cost/Acquisition: width 12%, currency
   - Status: width 10%
5. Add conditional formatting for ROI:
   - If ROI > 2: green text
   - If ROI 1-2: yellow text
   - If ROI < 1: red text
6. Click "Done"
7. Click "Update"
```

### The Verification

```bash
# 1. Check that the dashboard is accessible via API
curl -s -X GET "http://localhost:3000/api/dashboard" \
  -H "Content-Type: application/json" \
  | python -m json.tool

# 2. Test each question's performance (should be < 2 seconds)
# In Metabase UI, each card shows the query time
```

---

## Step 4: Creating Automated Executive Reports

### The Target
Set up automated email reports that deliver key metrics to executives on a schedule.

### The Concept
Not all stakeholders have time to check dashboards. Automated reports are like a **"morning briefing"** that delivers the most important information without requiring any action. This ensures:
- **Consistent communication:** Reports arrive like clockwork
- **Wide distribution:** Can send to non-technical stakeholders
- **Action prompts:** Include highlights and recommendations

### The Implementation

#### Step 4.1: Configure Email Settings

```bash
# 1. Set up email in Metabase via environment variables
# Add to docker-compose.yml or create a new .env.metabase file

# Add these to your .env file
cat >> .env << 'EOF'
# Metabase Email Configuration
MB_EMAIL_SMTP_HOST=smtp.gmail.com
MB_EMAIL_SMTP_PORT=587
MB_EMAIL_SMTP_USERNAME=your_email@gmail.com
MB_EMAIL_SMTP_PASSWORD=your_app_password
MB_EMAIL_FROM=executive-reports@decisionpipeline.com
MB_EMAIL_SMTP_SECURITY=tls
EOF
```

```bash
# 2. Restart Metabase with email configuration
docker-compose restart metabase
```

#### Step 4.2: Create Report SQL

```bash
# Create the weekly executive summary SQL
cat > scripts/executive_weekly_report.sql << 'EOF'
-- Weekly Executive Summary Report
-- Send every Monday at 9:00 AM

WITH weekly_metrics AS (
    SELECT 
        DATE_TRUNC('week', order_date) AS week_start,
        SUM(total_amount) AS weekly_revenue,
        COUNT(DISTINCT order_id) AS weekly_orders,
        COUNT(DISTINCT customer_id) AS weekly_customers,
        AVG(total_amount) AS avg_order_value
    FROM analytics_dbt.stg_orders
    WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'
    GROUP BY DATE_TRUNC('week', order_date)
),

top_performers AS (
    SELECT 
        name AS product_name,
        total_revenue,
        units_sold
    FROM analytics_dbt.dm_product_performance
    ORDER BY total_revenue DESC
    LIMIT 5
),

customer_insights AS (
    SELECT 
        customer_tier,
        COUNT(*) AS customer_count,
        ROUND(AVG(customer_health_score), 2) AS avg_health
    FROM analytics_dbt.dm_customer_360
    GROUP BY customer_tier
),

campaign_performance AS (
    SELECT 
        name,
        roi_ratio,
        conversion_rate
    FROM analytics_dbt.dm_campaign_performance
    WHERE campaign_status = 'active'
)

SELECT 
    'Weekly Executive Summary' AS report_title,
    CURRENT_DATE AS report_date,
    (SELECT weekly_revenue FROM weekly_metrics) AS last_week_revenue,
    (SELECT weekly_orders FROM weekly_metrics) AS last_week_orders,
    (SELECT weekly_customers FROM weekly_metrics) AS last_week_customers,
    (SELECT avg_order_value FROM weekly_metrics) AS avg_order_value,
    (SELECT json_agg(top_performers) FROM top_performers) AS top_products,
    (SELECT json_agg(customer_insights) FROM customer_insights) AS customer_segments,
    (SELECT json_agg(campaign_performance) FROM campaign_performance) AS active_campaigns;
EOF
```

#### Step 4.3: Create Dashboards for Reports

In Metabase UI:

```
1. Click the "Create" button (+)
2. Select "Pulse" or "Dashboard Subscription" depending on your version
3. Name: "Weekly Executive Summary"
4. Set schedule: Every Monday at 9:00 AM
5. Add the following cards to the email:
   - Executive Dashboard - Monthly Revenue Trend (last 4 weeks)
   - Executive Dashboard - Top Products by Revenue (top 10)
   - Executive Dashboard - Key Performance Indicators (KPIs)
6. Add the following text to the email:
   "Good morning! Here's your weekly business health update.
   
   Key Highlights:
   - Revenue: ${revenue} (${growth}% vs last week)
   - Top performer: ${top_product}
   - Action needed: ${action_item}
   
   Log in to the full dashboard for deeper analysis."
7. Add recipients: executive@company.com, leadership@company.com
8. Click "Save"
```

### The Verification

```bash
# 1. Test the weekly report query
docker-compose exec postgres psql -U analytics_user -d analytics -f scripts/executive_weekly_report.sql

# 2. Verify email configuration
docker-compose logs metabase | grep -i email
```

---

## Step 5: Performance Optimization for Dashboards

### The Target
Optimize dashboard performance for executive users.

### The Concept
Executives have **zero patience for slow dashboards**. We need to ensure:
- **Dashboard loads in < 3 seconds**
- **Complex queries are pre-aggregated**
- **Caching is enabled and configured**
- **Large tables use pagination**

### The Implementation

#### Step 5.1: Enable Metabase Caching

```bash
# Add caching configuration to Metabase via API or UI

# In Metabase UI:
1. Click the gear icon (Admin)
2. Click "Settings"
3. Click "Caching"
4. Enable caching: "On"
5. Set cache duration: "24 hours" for weekly data
6. For real-time data: "1 hour"
7. Click "Save"
```

#### Step 5.2: Create Materialized Views in PostgreSQL

```bash
# Create materialized views for slow queries
docker-compose exec postgres psql -U analytics_user -d analytics << 'EOF'
-- Create materialized view for product performance (refreshes daily)
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

-- Create materialized view for customer segments (refreshes weekly)
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics_dbt.mv_customer_segments AS
SELECT 
    customer_tier,
    churn_risk,
    COUNT(*) AS customer_count,
    ROUND(AVG(customer_health_score), 2) AS avg_health_score,
    ROUND(AVG(projected_lifetime_value), 2) AS avg_clv,
    CURRENT_DATE AS snapshot_date
FROM analytics_dbt.dm_customer_360
GROUP BY customer_tier, churn_risk
WITH DATA;

-- Create materialized view for weekly KPIs (refreshes daily)
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

-- Create refresh function
CREATE OR REPLACE FUNCTION analytics_dbt.refresh_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW analytics_dbt.mv_daily_product_performance;
    REFRESH MATERIALIZED VIEW analytics_dbt.mv_customer_segments;
    REFRESH MATERIALIZED VIEW analytics_dbt.mv_weekly_kpis;
END;
$$ LANGUAGE plpgsql;
EOF
```

#### Step 5.3: Set Up Automatic View Refresh

```bash
# Create a cron job to refresh materialized views
# We'll use the PostgreSQL pg_cron extension

docker-compose exec postgres psql -U analytics_user -d analytics << 'EOF'
-- Install pg_cron extension (if not already installed)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule refresh at 3:00 AM daily
SELECT cron.schedule(
    'refresh-analytics-views',
    '0 3 * * *',
    'SELECT analytics_dbt.refresh_materialized_views()'
);
EOF
```

#### Step 5.4: Create Indexes for Performance

```bash
# Create additional indexes for query performance
docker-compose exec postgres psql -U analytics_user -d analytics << 'EOF'
-- Indexes for sales summary queries
CREATE INDEX IF NOT EXISTS idx_sales_month ON analytics_dbt.dm_sales_summary(sales_month DESC);
CREATE INDEX IF NOT EXISTS idx_sales_revenue ON analytics_dbt.dm_sales_summary(total_revenue);

-- Indexes for customer queries
CREATE INDEX IF NOT EXISTS idx_customer_tier ON analytics_dbt.dm_customer_360(customer_tier);
CREATE INDEX IF NOT EXISTS idx_customer_health ON analytics_dbt.dm_customer_360(customer_health_score);
CREATE INDEX IF NOT EXISTS idx_customer_churn ON analytics_dbt.dm_customer_360(churn_risk);

-- Indexes for product queries
CREATE INDEX IF NOT EXISTS idx_product_revenue ON analytics_dbt.dm_product_performance(total_revenue DESC);
CREATE INDEX IF NOT EXISTS idx_product_health ON analytics_dbt.dm_product_performance(product_health);

-- Analyze tables for query planner
ANALYZE analytics_dbt.dm_sales_summary;
ANALYZE analytics_dbt.dm_customer_360;
ANALYZE analytics_dbt.dm_product_performance;
ANALYZE analytics_dbt.dm_campaign_performance;
EOF
```

### The Verification

```bash
# 1. Test query performance before optimization
EXPLAIN ANALYZE SELECT * FROM analytics_dbt.dm_sales_summary WHERE sales_month >= CURRENT_DATE - INTERVAL '12 months';

# 2. Test materialized view performance
SELECT * FROM analytics_dbt.mv_weekly_kpis;

# 3. Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'analytics_dbt'
ORDER BY idx_scan DESC;
```

---

## Step 6: User Management and Permissions

### The Target
Set up user roles and permissions for your dashboard.

### The Concept
Different stakeholders need different levels of access:
- **Executives:** View all dashboards, no editing
- **Analysts:** Create and edit questions, no dashboard admin
- **Data Engineers:** Full admin access

### The Implementation

#### Step 6.1: Create User Groups

In Metabase Admin Panel:

```
1. Click the gear icon (Admin)
2. Click "People"
3. Click "Groups"
4. Create groups:
   a. "Executives" - Read-only access
   b. "Analysts" - Can create questions
   c. "Data Team" - Full access
```

#### Step 6.2: Set Data Permissions

```
1. In Admin panel, click "Permissions"
2. Select "Data" tab
3. For the "Analytics Database":
   - Executives: "View data - query builder and native"
   - Analysts: "View data - query builder and native"
   - Data Team: "View data - query builder and native"
```

#### Step 6.3: Set Dashboard Permissions

```
1. In Admin panel, click "Permissions"
2. Select "Dashboards" tab
3. Find "Executive Decision Pack Dashboard":
   - Executives: "View"
   - Analysts: "View" and "Edit"
   - Data Team: "View" and "Edit"
```

#### Step 6.4: Create Sample Users

```bash
# Create user accounts via API (or use UI)
curl -X POST "http://localhost:3000/api/user" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Sarah",
    "last_name": "Johnson",
    "email": "sarah.johnson@company.com",
    "password": "SecurePassword123!",
    "group_ids": [1]  # Executives group
  }'

curl -X POST "http://localhost:3000/api/user" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Mike",
    "last_name": "Chen",
    "email": "mike.chen@company.com",
    "password": "SecurePassword123!",
    "group_ids": [2]  # Analysts group
  }'
```

### The Verification

```bash
# 1. Check user list
curl -X GET "http://localhost:3000/api/user" \
  -H "Content-Type: application/json" \
  | python -m json.tool

# 2. Verify permissions by logging in as different users
# Sarah Johnson (Executive): Should see dashboard, no edit
# Mike Chen (Analyst): Should see and edit dashboard
```

---

## Dashboard User Guide

Create a quick reference guide for your executive users:

### Executive Dashboard Quick Guide

#### Getting Started
1. **Access:** Go to `http://localhost:3000` and login
2. **Main View:** Click "Executive Decision Pack Dashboard"

#### Key Metrics Explained
| Metric | Definition | Why It Matters |
|--------|------------|----------------|
| **Total Revenue** | Gross revenue from all orders | Business health indicator |
| **Revenue Growth** | % change from previous month | Trend direction |
| **Avg Order Value** | Revenue ÷ Number of orders | Customer spending behavior |
| **Customer Health Score** | Composite score (0-100) | Customer satisfaction & loyalty |

#### Taking Action
- **Revenue dropping?** Check "Top Products" for declines
- **Health score low?** Review "Customer Health Distribution"  
- **Campaigns underperforming?** Check "Campaign ROI" for adjustments

#### Getting Help
- Questions? Contact the Analytics Team: analytics@company.com
- Request new metrics via the #analytics Slack channel

---

## Summary of What You've Built

You've successfully created a complete executive dashboard ecosystem:

1. **8 foundational questions** powering the dashboard
2. **Comprehensive dashboard layout** with KPIs, trends, and details
3. **Automated executive reports** delivered via email
4. **Performance optimizations** with materialized views and caching
5. **User management and permissions** for different roles
6. **Documentation** for executive users

### The Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         EXECUTIVE DECISION                        │
│                     PACK DASHBOARD (Metabase)                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  KPI Cards │ Line Charts │ Bar Charts │ Tables │ Donuts    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                              ▲                                     │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   Metabase      │                           │
│                     │   Query Layer   │                           │
│                     └────────┬────────┘                           │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   PostgreSQL    │                           │
│                     │   Materialized  │                           │
│                     │   Views         │                           │
│                     └────────┬────────┘                           │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   dbt Models    │                           │
│                     │   (Mart Layer)  │                           │
│                     └────────┬────────┘                           │
│                              │                                     │
│                     ┌────────┴────────┐                           │
│                     │   Raw Data      │                           │
│                     │   (Schema)      │                           │
│                     └─────────────────┘                           │
└─────────────────────────────────────────────────────────────────────┘
```

## What's Next

**[GENERATED: Module 6.1, Part 3 - Dashboard Creation with Metabase]**

You've completed the BI and dashboard engineering module! You have:
- A production-ready semantic layer (dbt models)
- An interactive executive dashboard (Metabase)
- Automated reporting and performance optimization

Now you're ready to move on to **Module 6.2: Analytics Storytelling & Executive Communication** where you'll learn to:
- Frame complex analytical findings for executive audiences
- Structure compelling presentations using the SCR framework
- Translate statistical concepts into business outcomes
- Design executive summary presentations that drive decisions

