# Module 6.1: Dashboard Engineering & BI Semantic Layers
## Part 1: Production Database Setup

### The Target

We're building the foundation of our entire analytics pipeline: a production-grade PostgreSQL database with sample e-commerce data. This database will serve as our source of truth for all subsequent analysis, dashboarding, and machine learning.

### The Concept

Think of this database as the "warehouse" of our business data. Just as a physical warehouse organizes inventory with clear aisles and shelves, our database organizes information with tables, relationships, and constraints. PostgreSQL is our warehouse management system – it handles storage, retrieval, and ensures data integrity.

We're using Docker to run PostgreSQL because it gives us:
- **Consistency:** Exactly the same environment on any machine
- **Isolation:** No conflicts with existing database installations
- **Portability:** Can be moved to production with minimal changes
- **Reproducibility:** Every team member gets the identical setup

---

## Step 1: Project Initialization

### The Target
Create the project directory structure and initialize our development environment.

### The Concept
Before writing any code, we need a well-organized workspace. This is like setting up a workshop before building furniture – you need clear spaces for raw materials, tools, and finished products.

### The Implementation

Open your terminal and run these commands:

```bash
# Create the project root directory
mkdir -p ~/projects/executive-decision-pipeline
cd ~/projects/executive-decision-pipeline

# Create the complete directory structure
mkdir -p data/{raw,processed,external}
mkdir -p src/{database,etl,models,explainability,dashboard}
mkdir -p notebooks tests reports/figures scripts dashboards/{metabase,superset}
mkdir -p .docker

# Create initial Python package files
touch src/__init__.py
touch src/database/__init__.py
touch src/etl/__init__.py
touch src/models/__init__.py
touch src/explainability/__init__.py
touch src/dashboard/__init__.py
touch tests/__init__.py

# Initialize Git repository
git init
echo "# Executive Decision Pipeline" > README.md

# Create .gitignore with standard Python ignores
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
pythonenv*
*.egg-info/
dist/
build/
.eggs/
*.egg

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Data files
*.csv
*.parquet
*.db
*.duckdb
*.sqlite

# Logs
logs/
*.log

# Jupyter
.ipynb_checkpoints/
*.ipynb

# OS
.DS_Store
Thumbs.db

# Docker
.docker/
*.pid

# Test coverage
.coverage
htmlcov/
.pytest_cache/
EOF

# Create initial requirements file
cat > requirements.txt << 'EOF'
# Core data processing
pandas==2.0.3
numpy==1.24.3
sqlalchemy==2.0.19
psycopg2-binary==2.9.7

# Database
duckdb==0.9.0

# Machine Learning
scikit-learn==1.3.0
xgboost==1.7.6

# Explainability
shap==0.42.1
lime==0.2.0.1

# Visualization
plotly==5.17.0
matplotlib==3.7.2
seaborn==0.12.2

# Jupyter
jupyterlab==4.0.3
ipykernel==6.25.1

# Utilities
python-dotenv==1.0.0
pyyaml==6.0.1
click==8.1.7
tqdm==4.66.1

# Testing
pytest==7.4.0
pytest-cov==4.1.0

# Code quality
black==23.7.0
flake8==6.1.0
mypy==1.5.1

# Reporting
quarto==1.3.450
markdown==3.4.4
EOF

# Create a Makefile for common commands
cat > Makefile << 'EOF'
.PHONY: help setup up down test clean

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

setup: ## Install dependencies and setup environment
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && pip install -r requirements.txt
	. venv/bin/activate && pre-commit install

up: ## Start all Docker services
	docker-compose up -d

down: ## Stop all Docker services
	docker-compose down

test: ## Run tests
	. venv/bin/activate && pytest tests/ -v --cov=src

clean: ## Clean temporary files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache/ .coverage htmlcov/
EOF

# Create environment variables template
cat > .env.example << 'EOF'
# PostgreSQL Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=analytics
POSTGRES_USER=analytics_user
POSTGRES_PASSWORD=secure_password_change_me

# DuckDB Configuration
DUCKDB_PATH=data/processed/analytics.duckdb

# Metabase Configuration
METABASE_PORT=3000
METABASE_DB=metabase
METABASE_USER=metabase_user
METABASE_PASSWORD=secure_password_change_me

# Model Configuration
MODEL_PATH=models/churn_model.pkl
RANDOM_SEED=42

# API Configuration (for future use)
API_HOST=0.0.0.0
API_PORT=8000
EOF

# Copy .env.example to .env (but don't commit .env)
cp .env.example .env
echo ".env" >> .gitignore

# Create Docker Compose file
cat > docker-compose.yml << 'EOF'
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
    networks:
      - edp_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-analytics_user}"]
      interval: 10s
      timeout: 5s
      retries: 5

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

volumes:
  postgres_data:

networks:
  edp_network:
    driver: bridge
EOF

# Create PostgreSQL initialization script
cat > scripts/init_postgres.sql << 'EOF'
-- This script runs when the PostgreSQL container first starts
-- It creates extensions and initial setup

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Set default timezone
SET timezone = 'UTC';

-- Create schema for analytics
CREATE SCHEMA IF NOT EXISTS analytics;

-- Grant privileges
GRANT ALL ON SCHEMA analytics TO analytics_user;

-- Create a function to calculate age in years (for future use)
CREATE OR REPLACE FUNCTION analytics.years_between(date1 DATE, date2 DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM age(date2, date1))::INTEGER;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
EOF

# Create initial Python script for database testing
cat > scripts/test_db_connection.py << 'EOF'
#!/usr/bin/env python3
"""Test database connectivity and basic operations."""

import os
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

def test_postgres_connection():
    """Test connection to PostgreSQL and run a simple query."""
    load_dotenv()
    
    # Get connection parameters
    host = os.getenv('POSTGRES_HOST', 'localhost')
    port = os.getenv('POSTGRES_PORT', '5432')
    database = os.getenv('POSTGRES_DB', 'analytics')
    user = os.getenv('POSTGRES_USER', 'analytics_user')
    password = os.getenv('POSTGRES_PASSWORD', 'secure_password_change_me')
    
    # Create connection string
    connection_string = f"postgresql://{user}:{password}@{host}:{port}/{database}"
    print(f"🔗 Connecting to PostgreSQL at {host}:{port}...")
    
    try:
        engine = create_engine(connection_string)
        with engine.connect() as conn:
            # Test connection with simple query
            result = conn.execute(text("SELECT 1 as test, current_timestamp as now"))
            row = result.fetchone()
            print(f"✅ Successfully connected! Test query result: {row.test}")
            print(f"   Current database time: {row.now}")
            
            # Check extensions
            ext_result = conn.execute(text(
                "SELECT extname FROM pg_extension WHERE extname IN ('uuid-ossp', 'pg_trgm')"
            ))
            extensions = [row[0] for row in ext_result]
            print(f"   Extensions installed: {', '.join(extensions)}")
            
            return True
            
    except SQLAlchemyError as e:
        print(f"❌ Failed to connect to PostgreSQL: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    print("=" * 60)
    print("Database Connection Test")
    print("=" * 60)
    
    success = test_postgres_connection()
    sys.exit(0 if success else 1)
EOF

# Make the test script executable
chmod +x scripts/test_db_connection.py
```

### The Verification

Run these commands to verify your setup:

```bash
# 1. Check directory structure
tree -L 2 -I 'venv|__pycache__|*.pyc'

# Expected output: Shows the directory tree we created

# 2. Check Python environment
python3 --version
# Expected: Python 3.9 or higher

# 3. Verify Docker installation
docker --version
docker-compose --version
# Expected: Docker version and Docker Compose version

# 4. Create Python virtual environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. Verify installations
python -c "import pandas, numpy, sqlalchemy, psycopg2; print('✅ All packages installed')"
```

---

## Step 2: Docker Container Orchestration

### The Target
Start our PostgreSQL database and Metabase services using Docker Compose.

### The Concept
Docker Compose is like a conductor for an orchestra – it coordinates multiple services (our PostgreSQL database and Metabase BI tool) to work together harmoniously. Each service runs in its own container (like a musician's soundproof booth), but they can communicate through a shared network.

### The Implementation

Our `docker-compose.yml` file defines two services:

1. **PostgreSQL:** Our primary database with persistent storage
2. **Metabase:** Our BI tool that will connect to PostgreSQL

Let's start the services:

```bash
# Start both services in detached mode (running in background)
docker-compose up -d

# Check status of containers
docker-compose ps

# Watch the logs (optional, press Ctrl+C to exit logs view)
docker-compose logs -f

# Wait for PostgreSQL to be healthy (about 10-15 seconds)
# You should see: "postgres | database system is ready to accept connections"
```

### The Verification

Let's verify both services are running correctly:

```bash
# 1. Check PostgreSQL is accepting connections
docker-compose exec postgres pg_isready -U analytics_user

# Expected output: 
# /var/run/postgresql:5432 - accepting connections

# 2. Test database connection with our Python script
python scripts/test_db_connection.py

# Expected output:
# ============================================================
# Database Connection Test
# ============================================================
# 🔗 Connecting to PostgreSQL at localhost:5432...
# ✅ Successfully connected! Test query result: 1
#    Current database time: 2024-... (date and time)
#    Extensions installed: uuid-ossp, pg_trgm

# 3. Check Metabase is running
curl -s http://localhost:3000/api/health | python -m json.tool

# Expected output:
# {
#     "status": "ok"
# }

# 4. Open Metabase in your browser
# Go to http://localhost:3000
# You should see the Metabase setup wizard
# (Don't complete setup yet - we'll do it later)
```

---

## Step 3: Database Schema Design

### The Target
Create our business schema with properly normalized tables for an e-commerce platform.

### The Concept
A database schema is like a blueprint for a building. We need to design our tables, their columns, and their relationships before we start filling them with data. Our schema follows **Third Normal Form (3NF)** – a design pattern that minimizes data redundancy and prevents inconsistencies.

Think of it this way:
- **Customers** are people who shop with us
- **Orders** are individual purchases made by customers
- **Order Items** are the individual products in each order
- **Products** are the items we sell
- **Categories** group similar products
- **Returns** track when customers send products back
- **Reviews** capture customer feedback
- **Marketing Campaigns** track our promotional efforts
- **Campaign Responses** show which customers engaged

### The Implementation

Create the schema creation script:

```bash
# Create the schema creation script
cat > scripts/create_schema.sql << 'EOF'
-- ====================================================
-- Schema: E-commerce Analytics Database
-- Description: Core business tables for analytics
-- ====================================================

-- Switch to the analytics schema
SET search_path TO analytics;

-- ====================================================
-- DIMENSION TABLES (Things we describe)
-- ====================================================

-- 1. Customers table
CREATE TABLE IF NOT EXISTS customers (
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

-- 2. Products table
CREATE TABLE IF NOT EXISTS products (
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

-- 3. Categories table
CREATE TABLE IF NOT EXISTS categories (
    category_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(100) NOT NULL UNIQUE,
    description         TEXT,
    parent_category_id  UUID REFERENCES categories(category_id),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Suppliers table
CREATE TABLE IF NOT EXISTS suppliers (
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
-- FACT TABLES (Events and transactions)
-- ====================================================

-- 5. Orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id         UUID NOT NULL REFERENCES customers(customer_id),
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

-- 6. Order Items table (line items within orders)
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id            UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id          UUID NOT NULL REFERENCES products(product_id),
    quantity            INTEGER NOT NULL CHECK (quantity > 0),
    unit_price          DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    discount_percent    DECIMAL(5, 2) DEFAULT 0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    total_price         DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(order_id, product_id)
);

-- 7. Returns table
CREATE TABLE IF NOT EXISTS returns (
    return_id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id       UUID NOT NULL REFERENCES order_items(order_item_id),
    return_reason       VARCHAR(200),
    return_status       VARCHAR(50) DEFAULT 'requested',
    refund_amount       DECIMAL(10, 2) NOT NULL CHECK (refund_amount >= 0),
    refund_date         TIMESTAMP WITH TIME ZONE,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Reviews table
CREATE TABLE IF NOT EXISTS reviews (
    review_id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id          UUID NOT NULL REFERENCES products(product_id),
    customer_id         UUID NOT NULL REFERENCES customers(customer_id),
    rating              INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title               VARCHAR(200),
    comment             TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count       INTEGER DEFAULT 0,
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, customer_id)
);

-- 9. Marketing Campaigns table
CREATE TABLE IF NOT EXISTS marketing_campaigns (
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

-- 10. Campaign Responses table
CREATE TABLE IF NOT EXISTS campaign_responses (
    response_id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id         UUID NOT NULL REFERENCES marketing_campaigns(campaign_id),
    customer_id         UUID NOT NULL REFERENCES customers(customer_id),
    response_date       TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    action_taken        VARCHAR(50),  -- 'opened', 'clicked', 'purchased', 'unsubscribed'
    conversion_value    DECIMAL(10, 2),
    created_at          TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(campaign_id, customer_id)
);

-- ====================================================
-- CREATE INDEXES (For performance)
-- ====================================================

-- Customers indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_registration_date ON customers(registration_date);
CREATE INDEX idx_customers_last_login ON customers(last_login_date);

-- Products indexes
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_supplier_id ON products(supplier_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_is_active ON products(is_active);

-- Orders indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- Order Items indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Returns indexes
CREATE INDEX idx_returns_order_item_id ON returns(order_item_id);
CREATE INDEX idx_returns_status ON returns(return_status);

-- Reviews indexes
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Campaign Responses indexes
CREATE INDEX idx_campaign_responses_campaign_id ON campaign_responses(campaign_id);
CREATE INDEX idx_campaign_responses_customer_id ON campaign_responses(customer_id);

-- ====================================================
-- VIEWS (Common business logic)
-- ====================================================

-- Customer lifetime value view
CREATE OR REPLACE VIEW customer_lifetime_value AS
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
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status NOT IN ('cancelled')
GROUP BY c.customer_id, c.email, c.first_name, c.last_name, c.registration_date;

-- Product performance view
CREATE OR REPLACE VIEW product_performance AS
SELECT 
    p.product_id,
    p.sku,
    p.name,
    p.category_id,
    COALESCE(SUM(oi.quantity), 0) as total_units_sold,
    COALESCE(COUNT(DISTINCT oi.order_id), 0) as total_orders,
    COALESCE(SUM(oi.total_price), 0) as total_revenue,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COALESCE(COUNT(r.review_id), 0) as total_reviews
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status NOT IN ('cancelled')
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.sku, p.name, p.category_id;

-- Monthly sales summary view
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT 
    DATE_TRUNC('month', order_date) as month,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    SUM(tax_amount) as total_tax,
    SUM(shipping_amount) as total_shipping,
    SUM(discount_amount) as total_discounts
FROM orders
WHERE status NOT IN ('cancelled')
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

-- ====================================================
-- TRIGGER: Auto-update updated_at columns
-- ====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_returns_updated_at BEFORE UPDATE ON returns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ====================================================
-- COMMENTS (Documentation in the database)
-- ====================================================

COMMENT ON DATABASE analytics IS 'E-commerce analytics database for the Executive Decision Pipeline project';

COMMENT ON TABLE customers IS 'All registered customers with their personal information';
COMMENT ON TABLE orders IS 'All customer orders with complete transaction details';
COMMENT ON TABLE order_items IS 'Individual line items within orders';
COMMENT ON TABLE products IS 'Product catalog with pricing and inventory';
COMMENT ON TABLE categories IS 'Product categorization hierarchy';
COMMENT ON TABLE suppliers IS 'Vendor information';
COMMENT ON TABLE returns IS 'Product returns and refunds';
COMMENT ON TABLE reviews IS 'Customer product reviews and ratings';
COMMENT ON TABLE marketing_campaigns IS 'Marketing and promotional campaigns';
COMMENT ON TABLE campaign_responses IS 'Customer responses to marketing campaigns';

EOF
```

Now apply this schema to our database:

```bash
# Apply the schema to PostgreSQL
docker-compose exec -T postgres psql -U analytics_user -d analytics < scripts/create_schema.sql

# Verify schema creation
docker-compose exec postgres psql -U analytics_user -d analytics -c "\dt analytics.*"

# Expected output: Shows all 10 tables we created
```

---

## Step 4: Generate Sample Data

### The Target
Populate our database with realistic e-commerce sample data for analysis.

### The Concept
We need realistic data to work with. Instead of random noise, we'll generate data that mimics real business patterns:
- Customer demographics with realistic distributions
- Purchase behavior with seasonality
- Product categories with proper hierarchies
- Marketing campaign responses with realistic conversion rates

We'll create a Python script that generates this data using a combination of:
- **Faker library** for realistic personal information
- **Statistical distributions** for natural data patterns
- **Business rules** for realistic relationships

### The Implementation

First, install the Faker library for generating realistic data:

```bash
# Install Faker for data generation
pip install faker

# Update requirements.txt
echo "faker==19.6.1" >> requirements.txt
```

Now create the data generation script:

```bash
cat > scripts/generate_sample_data.py << 'EOF'
#!/usr/bin/env python3
"""
Generate realistic sample data for the e-commerce analytics database.
Uses Faker to create realistic personal information and business data.
"""

import os
import sys
import random
import uuid
from datetime import datetime, timedelta
from pathlib import Path
from decimal import Decimal

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

import pandas as pd
import numpy as np
from faker import Faker
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Faker
fake = Faker(['en_US'])
Faker.seed(42)  # For reproducible results
np.random.seed(42)
random.seed(42)

# Set random seed for consistent results
np.random.seed(42)

# Configuration
NUM_CUSTOMERS = 5000
NUM_PRODUCTS = 200
NUM_CATEGORIES = 20
NUM_SUPPLIERS = 15
NUM_ORDERS = 15000
MAX_ITEMS_PER_ORDER = 10
NUM_MARKETING_CAMPAIGNS = 10

# Date range for data
START_DATE = datetime(2022, 1, 1)
END_DATE = datetime(2024, 6, 30)

# Product categories with realistic names
CATEGORIES = [
    "Electronics", "Computers", "Phones", "Accessories", 
    "Clothing", "Men's Fashion", "Women's Fashion", "Kids' Fashion",
    "Home & Garden", "Furniture", "Kitchen", "Decor",
    "Sports", "Fitness", "Outdoors", "Team Sports",
    "Books", "Fiction", "Non-Fiction", "Educational"
]

# Product names by category
PRODUCT_NAMES = {
    "Electronics": ["Smart TV", "Soundbar", "Headphones", "Speakers", "Smart Home Hub"],
    "Computers": ["Laptop", "Desktop", "Monitor", "Keyboard", "Mouse", "External Drive"],
    "Phones": ["Smartphone", "Phone Case", "Screen Protector", "Charger", "Power Bank"],
    "Accessories": ["Watch", "Belt", "Wallet", "Backpack", "Sunglasses"],
    "Clothing": ["T-Shirt", "Jeans", "Sweater", "Jacket", "Socks", "Underwear"],
    "Men's Fashion": ["Dress Shirt", "Suit", "Tie", "Belt", "Dress Shoes"],
    "Women's Fashion": ["Dress", "Blouse", "Skirt", "Handbag", "Heels"],
    "Kids' Fashion": ["Toddler T-Shirt", "Kids Jeans", "Kids Shoes", "Toy"],
    "Home & Garden": ["Lamp", "Rug", "Plant", "Table", "Chair"],
    "Furniture": ["Sofa", "Bed", "Dining Table", "Bookshelf", "Desk"],
    "Kitchen": ["Knife Set", "Cookware", "Bakeware", "Coffee Maker", "Blender"],
    "Decor": ["Wall Art", "Vase", "Candle", "Mirror", "Clock"],
    "Sports": ["Basketball", "Soccer Ball", "Tennis Racket", "Yoga Mat"],
    "Fitness": ["Dumbbells", "Resistance Bands", "Jump Rope", "Gym Bag"],
    "Outdoors": ["Tent", "Sleeping Bag", "Hiking Boots", "Water Bottle"],
    "Team Sports": ["Jersey", "Shorts", "Socks", "Sports Bag"],
    "Books": ["Novel", "Non-Fiction", "Cookbook", "Self-Help", "Biography"],
    "Fiction": ["Science Fiction", "Mystery", "Romance", "Fantasy", "Thriller"],
    "Non-Fiction": ["History", "Science", "Philosophy", "Business", "Psychology"],
    "Educational": ["Textbook", "Workbook", "Study Guide", "Reference Book"]
}

# Supplier names
SUPPLIER_NAMES = [
    "GlobalTech Distributors", "Prime Products Inc", "Quality Wholesale",
    "International Supplies", "Mega Distribution", "Direct Logistics",
    "Premium Goods Co", "Reliable Suppliers", "First Choice Wholesale",
    "Best Price Distributors", "Elite Products", "Universal Supplies",
    "Specialty Distributors", "Top Shelf Wholesale", "Golden Gate Logistics"
]

# Payment methods
PAYMENT_METHODS = ['credit_card', 'debit_card', 'paypal', 'apple_pay', 'google_pay', 'bank_transfer']

# Order statuses (weighted by probability)
ORDER_STATUSES = ['completed', 'completed', 'completed', 'completed', 'pending', 'shipped', 'cancelled']

# Payment statuses
PAYMENT_STATUSES = ['paid', 'paid', 'paid', 'pending', 'failed', 'refunded']

# Return reasons
RETURN_REASONS = [
    'defective', 'wrong_size', 'not_as_described', 'changed_mind',
    'arrived_late', 'no_longer_needed', 'better_price_elsewhere'
]

# Marketing channels
MARKETING_CHANNELS = ['email', 'social_media', 'ppc', 'seo', 'referral', 'affiliate']


def get_db_engine():
    """Create SQLAlchemy engine for PostgreSQL connection."""
    host = os.getenv('POSTGRES_HOST', 'localhost')
    port = os.getenv('POSTGRES_PORT', '5432')
    database = os.getenv('POSTGRES_DB', 'analytics')
    user = os.getenv('POSTGRES_USER', 'analytics_user')
    password = os.getenv('POSTGRES_PASSWORD', 'secure_password_change_me')
    
    connection_string = f"postgresql://{user}:{password}@{host}:{port}/{database}"
    return create_engine(connection_string)


def generate_customers(n):
    """Generate n realistic customers."""
    customers = []
    for _ in range(n):
        # 80% of customers register with an email
        use_email = random.random() < 0.8
        email_domain = fake.free_email_domain()
        first_name = fake.first_name()
        last_name = fake.last_name()
        
        if use_email:
            email = f"{first_name.lower()}.{last_name.lower()}@{email_domain}"
        else:
            email = f"user{random.randint(1000, 9999)}@{fake.free_email_domain()}"
        
        # Some customers don't provide full profile info
        has_phone = random.random() < 0.7
        has_birth_date = random.random() < 0.6
        
        customer = {
            'customer_id': uuid.uuid4(),
            'email': email,
            'first_name': first_name,
            'last_name': last_name,
            'phone': fake.phone_number() if has_phone else None,
            'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=85) if has_birth_date else None,
            'registration_date': fake.date_time_between(start_date=START_DATE, end_date=END_DATE),
            'last_login_date': None,  # Will set later based on order activity
            'is_active': random.random() < 0.85,  # 85% active
            'is_verified': random.random() < 0.7,  # 70% verified
        }
        customers.append(customer)
    
    return pd.DataFrame(customers)


def generate_categories():
    """Generate product category hierarchy."""
    categories = []
    
    # First level: Main categories
    main_categories = CATEGORIES[:10]  # First 10 as main categories
    
    for i, name in enumerate(main_categories):
        cat_id = uuid.uuid4()
        categories.append({
            'category_id': cat_id,
            'name': name,
            'description': fake.paragraph(nb_sentences=1),
            'parent_category_id': None,
            'created_at': fake.date_time_between(start_date=START_DATE, end_date=END_DATE)
        })
    
    # Second level: Sub-categories
    sub_categories = CATEGORIES[10:]  # Last 10 as sub-categories
    for i, name in enumerate(sub_categories):
        parent = random.choice(categories[:5])  # Assign to one of first 5 main categories
        cat_id = uuid.uuid4()
        categories.append({
            'category_id': cat_id,
            'name': name,
            'description': fake.paragraph(nb_sentences=1),
            'parent_category_id': parent['category_id'],
            'created_at': fake.date_time_between(start_date=START_DATE, end_date=END_DATE)
        })
    
    return pd.DataFrame(categories)


def generate_suppliers(n):
    """Generate n suppliers."""
    suppliers = []
    for name in SUPPLIER_NAMES[:n]:
        suppliers.append({
            'supplier_id': uuid.uuid4(),
            'name': name,
            'contact_name': fake.name(),
            'contact_email': fake.company_email(),
            'contact_phone': fake.phone_number(),
            'address_line1': fake.street_address(),
            'address_line2': fake.secondary_address() if random.random() < 0.3 else None,
            'city': fake.city(),
            'state': fake.state_abbr(),
            'postal_code': fake.zipcode(),
            'country': 'USA',
            'is_active': random.random() < 0.9,
            'created_at': fake.date_time_between(start_date=START_DATE, end_date=END_DATE)
        })
    
    return pd.DataFrame(suppliers)


def generate_products(n, categories_df, suppliers_df):
    """Generate n products."""
    products = []
    category_list = categories_df['category_id'].tolist()
    supplier_list = suppliers_df['supplier_id'].tolist()
    
    for _ in range(n):
        # Pick a category and get matching product names
        category_id = random.choice(category_list)
        category_name = categories_df[categories_df['category_id'] == category_id]['name'].iloc[0]
        
        # Get product name possibilities for this category
        possible_names = PRODUCT_NAMES.get(category_name, ["Generic Product"])
        product_name = random.choice(possible_names)
        
        # Add variation
        if random.random() < 0.7:
            product_name = f"{product_name} {random.choice(['Pro', 'Lite', 'Plus', 'Elite', 'Premium'])}"
        
        # Calculate price with some variation
        base_price = random.uniform(10, 500)
        unit_price = round(base_price * random.uniform(0.8, 1.2), 2)
        cost_per_unit = round(unit_price * random.uniform(0.4, 0.7), 2)
        
        products.append({
            'product_id': uuid.uuid4(),
            'sku': f"SKU-{fake.unique.bothify('???-#####', letters='ABCDEFGHIJKLMNOPQRSTUVWXYZ')}",
            'name': product_name,
            'description': fake.paragraph(nb_sentences=3),
            'category_id': category_id,
            'supplier_id': random.choice(supplier_list),
            'unit_price': unit_price,
            'cost_per_unit': cost_per_unit,
            'weight_kg': round(random.uniform(0.1, 10), 3),
            'stock_quantity': random.randint(0, 500),
            'reorder_level': random.randint(5, 50),
            'is_active': random.random() < 0.85,
            'created_at': fake.date_time_between(start_date=START_DATE, end_date=END_DATE)
        })
    
    return pd.DataFrame(products)


def generate_orders(n, customers_df, products_df):
    """Generate n orders with their order items."""
    customer_ids = customers_df['customer_id'].tolist()
    product_ids = products_df['product_id'].tolist()
    product_prices = dict(zip(products_df['product_id'], products_df['unit_price']))
    
    orders = []
    order_items = []
    
    for _ in range(n):
        # Pick a random customer
        customer_id = random.choice(customer_ids)
        
        # Generate order date (biased toward recent dates)
        days_offset = random.expovariate(0.01)  # Exponential distribution
        order_date = END_DATE - timedelta(days=min(days_offset, 365*3))
        order_date = max(order_date, START_DATE)
        
        # Number of items in this order
        num_items = random.randint(1, MAX_ITEMS_PER_ORDER)
        
        # Pick products for this order
        order_product_ids = random.sample(product_ids, min(num_items, len(product_ids)))
        
        # Calculate order totals
        subtotal = 0
        order_items_list = []
        
        for product_id in order_product_ids:
            quantity = random.randint(1, 5)
            unit_price = product_prices[product_id]
            discount_percent = random.choice([0, 0, 0, 0, 0.05, 0.10, 0.15])  # Some items discounted
            total_price = round(unit_price * quantity * (1 - discount_percent), 2)
            subtotal += total_price
            
            order_items_list.append({
                'order_item_id': uuid.uuid4(),
                'order_id': None,  # Will assign after order creation
                'product_id': product_id,
                'quantity': quantity,
                'unit_price': unit_price,
                'discount_percent': discount_percent,
                'total_price': total_price,
                'created_at': order_date
            })
        
        # Apply some discounts at order level
        order_discount = 0
        if random.random() < 0.1:
            order_discount = round(subtotal * random.uniform(0.05, 0.15), 2)
        
        tax = round((subtotal - order_discount) * 0.08, 2)  # 8% sales tax
        shipping = round(random.choice([0, 5.99, 9.99, 19.99]), 2)
        
        total = round(subtotal - order_discount + tax + shipping, 2)
        
        # Determine order status
        status = random.choice(ORDER_STATUSES)
        payment_status = random.choice(PAYMENT_STATUSES)
        
        order = {
            'order_id': uuid.uuid4(),
            'customer_id': customer_id,
            'order_date': order_date,
            'status': status,
            'shipping_address_line1': fake.street_address(),
            'shipping_address_line2': fake.secondary_address() if random.random() < 0.2 else None,
            'shipping_city': fake.city(),
            'shipping_state': fake.state_abbr(),
            'shipping_postal_code': fake.zipcode(),
            'shipping_country': 'USA',
            'payment_method': random.choice(PAYMENT_METHODS),
            'payment_status': payment_status,
            'subtotal_amount': subtotal,
            'tax_amount': tax,
            'shipping_amount': shipping,
            'discount_amount': order_discount,
            'total_amount': total,
            'notes': fake.sentence() if random.random() < 0.1 else None,
            'created_at': order_date,
            'updated_at': order_date
        }
        
        # Update order items with order_id
        for item in order_items_list:
            item['order_id'] = order['order_id']
        
        orders.append(order)
        order_items.extend(order_items_list)
    
    return pd.DataFrame(orders), pd.DataFrame(order_items)


def generate_returns(order_items_df, max_returns=0.05):
    """Generate returns for a portion of order items."""
    num_returns = int(len(order_items_df) * max_returns)
    if num_returns == 0:
        return pd.DataFrame()
    
    selected_items = order_items_df.sample(n=min(num_returns, len(order_items_df)))
    
    returns = []
    for _, item in selected_items.iterrows():
        refund_amount = round(item['total_price'] * random.uniform(0.8, 1.0), 2)
        
        returns.append({
            'return_id': uuid.uuid4(),
            'order_item_id': item['order_item_id'],
            'return_reason': random.choice(RETURN_REASONS),
            'return_status': random.choice(['requested', 'approved', 'completed', 'rejected']),
            'refund_amount': refund_amount,
            'refund_date': item['created_at'] + timedelta(days=random.randint(1, 30)),
            'created_at': item['created_at'],
            'updated_at': item['created_at'] + timedelta(days=random.randint(1, 10))
        })
    
    return pd.DataFrame(returns)


def generate_reviews(orders_df, order_items_df, customers_df, products_df):
    """Generate product reviews based on order history."""
    # Only completed orders can have reviews
    completed_orders = orders_df[orders_df['status'] == 'completed']
    
    # 15% of completed orders have reviews
    potential_reviews = order_items_df[order_items_df['order_id'].isin(completed_orders['order_id'])]
    num_reviews = int(len(potential_reviews) * 0.15)
    
    if num_reviews == 0:
        return pd.DataFrame()
    
    selected_items = potential_reviews.sample(n=min(num_reviews, len(potential_reviews)))
    
    reviews = []
    for _, item in selected_items.iterrows():
        # Get order to find customer
        order = orders_df[orders_df['order_id'] == item['order_id']].iloc[0]
        customer_id = order['customer_id']
        
        # Rating distribution (biased toward positive)
        rating = random.choices(
            [1, 2, 3, 4, 5],
            weights=[0.05, 0.08, 0.12, 0.30, 0.45],
            k=1
        )[0]
        
        reviews.append({
            'review_id': uuid.uuid4(),
            'product_id': item['product_id'],
            'customer_id': customer_id,
            'rating': rating,
            'title': fake.sentence(nb_words=5) if random.random() < 0.7 else None,
            'comment': fake.paragraph(nb_sentences=3) if random.random() < 0.6 else None,
            'is_verified_purchase': True,  # They actually bought it
            'helpful_count': random.randint(0, 50),
            'created_at': order['order_date'] + timedelta(days=random.randint(3, 60)),
            'updated_at': order['order_date'] + timedelta(days=random.randint(3, 60))
        })
    
    return pd.DataFrame(reviews)


def generate_marketing_campaigns(n):
    """Generate n marketing campaigns."""
    campaigns = []
    
    for _ in range(n):
        start_date = fake.date_time_between(start_date=START_DATE, end_date=END_DATE - timedelta(days=30))
        duration_days = random.randint(14, 60)
        end_date = start_date + timedelta(days=duration_days)
        
        campaigns.append({
            'campaign_id': uuid.uuid4(),
            'name': f"{random.choice(['Spring', 'Summer', 'Fall', 'Winter', 'Holiday'])} "
                    f"{random.choice(['Sale', 'Promotion', 'Event', 'Launch', 'Special'])} "
                    f"{fake.year()}",
            'description': fake.paragraph(nb_sentences=2),
            'channel': random.choice(MARKETING_CHANNELS),
            'start_date': start_date,
            'end_date': end_date,
            'budget': round(random.uniform(1000, 50000), 2),
            'cost_per_contact': round(random.uniform(0.5, 5.0), 2),
            'target_audience': {'age_range': f"{random.randint(18, 35)}-{random.randint(45, 70)}"},
            'created_at': start_date - timedelta(days=random.randint(1, 30))
        })
    
    return pd.DataFrame(campaigns)


def generate_campaign_responses(campaigns_df, customers_df):
    """Generate responses to marketing campaigns."""
    responses = []
    
    for _, campaign in campaigns_df.iterrows():
        # Random subset of customers who saw campaign
        num_responses = random.randint(int(len(customers_df) * 0.01), int(len(customers_df) * 0.05))
        responding_customers = customers_df.sample(n=min(num_responses, len(customers_df)))
        
        for _, customer in responding_customers.iterrows():
            # Response actions with probability weights
            actions = ['opened', 'clicked', 'purchased', 'unsubscribed']
            weights = [0.4, 0.25, 0.2, 0.15]
            
            action = random.choices(actions, weights=weights, k=1)[0]
            
            # Response within campaign window
            response_date = fake.date_time_between(
                start_date=campaign['start_date'],
                end_date=campaign['end_date'] or END_DATE
            )
            
            conversion_value = None
            if action == 'purchased':
                conversion_value = round(random.uniform(20, 200), 2)
            
            responses.append({
                'response_id': uuid.uuid4(),
                'campaign_id': campaign['campaign_id'],
                'customer_id': customer['customer_id'],
                'response_date': response_date,
                'action_taken': action,
                'conversion_value': conversion_value,
                'created_at': response_date
            })
    
    return pd.DataFrame(responses)


def update_customer_last_login(customers_df, orders_df):
    """Set last login date based on order history."""
    # Customers who placed orders get their last login as their most recent order date
    customer_last_orders = orders_df.groupby('customer_id')['order_date'].max()
    
    for customer_id in customers_df.index:
        if customer_id in customer_last_orders.index:
            customers_df.at[customer_id, 'last_login_date'] = customer_last_orders[customer_id]
        else:
            # Some customers who registered but never ordered may have logged in
            if random.random() < 0.3:
                days_after_reg = random.randint(1, 365)
                customers_df.at[customer_id, 'last_login_date'] = customers_df.at[customer_id, 'registration_date'] + timedelta(days=days_after_reg)
    
    return customers_df


def load_data_to_postgres(df, table_name, if_exists='append'):
    """Load a DataFrame to PostgreSQL."""
    engine = get_db_engine()
    
    with engine.connect() as conn:
        # Clear table first if replacing
        if if_exists == 'replace':
            conn.execute(text(f"TRUNCATE TABLE analytics.{table_name} CASCADE"))
            conn.commit()
    
    # Use schema='analytics' to specify the schema
    df.to_sql(table_name, engine, schema='analytics', if_exists=if_exists, index=False, method='multi')
    print(f"✅ Loaded {len(df)} rows to {table_name}")


def main():
    """Generate and load all sample data."""
    print("=" * 60)
    print("Generating Sample Data for E-commerce Analytics")
    print("=" * 60)
    
    # 1. Generate categories
    print("\n📦 Generating categories...")
    categories_df = generate_categories()
    load_data_to_postgres(categories_df, 'categories', if_exists='replace')
    
    # 2. Generate suppliers
    print("\n📦 Generating suppliers...")
    suppliers_df = generate_suppliers(NUM_SUPPLIERS)
    load_data_to_postgres(suppliers_df, 'suppliers', if_exists='replace')
    
    # 3. Generate customers
    print("\n👤 Generating customers...")
    customers_df = generate_customers(NUM_CUSTOMERS)
    load_data_to_postgres(customers_df, 'customers', if_exists='replace')
    
    # 4. Generate products
    print("\n📦 Generating products...")
    products_df = generate_products(NUM_PRODUCTS, categories_df, suppliers_df)
    load_data_to_postgres(products_df, 'products', if_exists='replace')
    
    # 5. Generate orders and order items
    print("\n🛒 Generating orders...")
    orders_df, order_items_df = generate_orders(NUM_ORDERS, customers_df, products_df)
    load_data_to_postgres(orders_df, 'orders', if_exists='replace')
    load_data_to_postgres(order_items_df, 'order_items', if_exists='replace')
    
    # 6. Generate returns
    print("\n🔄 Generating returns...")
    returns_df = generate_returns(order_items_df, max_returns=0.05)
    if not returns_df.empty:
        load_data_to_postgres(returns_df, 'returns', if_exists='replace')
    else:
        print("   No returns generated")
    
    # 7. Generate reviews
    print("\n⭐ Generating reviews...")
    reviews_df = generate_reviews(orders_df, order_items_df, customers_df, products_df)
    if not reviews_df.empty:
        load_data_to_postgres(reviews_df, 'reviews', if_exists='replace')
    else:
        print("   No reviews generated")
    
    # 8. Update customer last login
    print("\n👤 Updating customer last login...")
    customers_df = update_customer_last_login(customers_df, orders_df)
    # Reload customers with updated last login
    load_data_to_postgres(customers_df, 'customers', if_exists='replace')
    
    # 9. Generate marketing campaigns
    print("\n📊 Generating marketing campaigns...")
    campaigns_df = generate_marketing_campaigns(NUM_MARKETING_CAMPAIGNS)
    load_data_to_postgres(campaigns_df, 'marketing_campaigns', if_exists='replace')
    
    # 10. Generate campaign responses
    print("\n📊 Generating campaign responses...")
    responses_df = generate_campaign_responses(campaigns_df, customers_df)
    load_data_to_postgres(responses_df, 'campaign_responses', if_exists='replace')
    
    print("\n" + "=" * 60)
    print("✅ Data generation complete!")
    print("=" * 60)
    
    # Print summary statistics
    print("\n📊 Data Summary:")
    print(f"   Customers: {len(customers_df)}")
    print(f"   Products: {len(products_df)}")
    print(f"   Categories: {len(categories_df)}")
    print(f"   Suppliers: {len(suppliers_df)}")
    print(f"   Orders: {len(orders_df)}")
    print(f"   Order Items: {len(order_items_df)}")
    print(f"   Returns: {len(returns_df)}")
    print(f"   Reviews: {len(reviews_df)}")
    print(f"   Campaigns: {len(campaigns_df)}")
    print(f"   Campaign Responses: {len(responses_df)}")


if __name__ == "__main__":
    main()
EOF
```

Make the script executable and run it:

```bash
# Make executable
chmod +x scripts/generate_sample_data.py

# Run the data generation
python scripts/generate_sample_data.py
```

This will take about 30-60 seconds to generate all the data.

### The Verification

Let's verify our data is correctly loaded:

```bash
# 1. Count records in each table
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    'customers' as table_name, COUNT(*) as count FROM analytics.customers
UNION ALL
SELECT 'products', COUNT(*) FROM analytics.products
UNION ALL
SELECT 'categories', COUNT(*) FROM analytics.categories
UNION ALL
SELECT 'orders', COUNT(*) FROM analytics.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM analytics.order_items
UNION ALL
SELECT 'returns', COUNT(*) FROM analytics.returns
UNION ALL
SELECT 'reviews', COUNT(*) FROM analytics.reviews
UNION ALL
SELECT 'marketing_campaigns', COUNT(*) FROM analytics.marketing_campaigns
UNION ALL
SELECT 'campaign_responses', COUNT(*) FROM analytics.campaign_responses
ORDER BY table_name;"

# 2. Sample a customer record
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT customer_id, email, first_name, last_name, registration_date 
FROM analytics.customers 
LIMIT 3;"

# 3. Check orders by status
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT status, COUNT(*) as count 
FROM analytics.orders 
GROUP BY status 
ORDER BY count DESC;"

# 4. Test the views we created
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT * FROM analytics.customer_lifetime_value LIMIT 5;"

docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT * FROM analytics.monthly_sales_summary LIMIT 5;"

# 5. Check total revenue
docker-compose exec postgres psql -U analytics_user -d analytics -c "
SELECT 
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    COUNT(*) as total_orders
FROM analytics.orders 
WHERE status NOT IN ('cancelled');"
```

---

## Step 5: Create Database Utility Module

### The Target
Create a Python module that provides clean, reusable database connections for all future work.

### The Concept
Instead of rewriting connection code in every script, we create a utility module that handles:
- Connection pooling for efficiency
- Retry logic for reliability
- Context managers for safe resource cleanup
- Environment-based configuration for security

This is like having a reliable API for your database – one interface that works the same way everywhere.

### The Implementation

```bash
cat > src/database/postgres.py << 'EOF'
"""
PostgreSQL database utilities with connection pooling and context management.
Provides a clean interface for database operations across the application.
"""

import os
import logging
from contextlib import contextmanager
from typing import Generator, Optional, Dict, Any
from urllib.parse import quote_plus

from sqlalchemy import create_engine, text, MetaData
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError, OperationalError
from sqlalchemy.pool import QueuePool
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()


class DatabaseConfig:
    """Configuration for PostgreSQL database connection."""
    
    def __init__(self, **kwargs):
        # Load from environment with defaults
        self.host = kwargs.get('host', os.getenv('POSTGRES_HOST', 'localhost'))
        self.port = kwargs.get('port', int(os.getenv('POSTGRES_PORT', '5432')))
        self.database = kwargs.get('database', os.getenv('POSTGRES_DB', 'analytics'))
        self.user = kwargs.get('user', os.getenv('POSTGRES_USER', 'analytics_user'))
        self.password = kwargs.get('password', os.getenv('POSTGRES_PASSWORD'))
        
        # Connection pool settings
        self.pool_size = kwargs.get('pool_size', 5)
        self.max_overflow = kwargs.get('max_overflow', 10)
        self.pool_timeout = kwargs.get('pool_timeout', 30)
        self.pool_recycle = kwargs.get('pool_recycle', 3600)
        
        # Other settings
        self.echo = kwargs.get('echo', False)
        self.auto_commit = kwargs.get('auto_commit', False)
    
    def get_connection_string(self) -> str:
        """Generate PostgreSQL connection string with proper escaping."""
        # Quote password if it contains special characters
        password = quote_plus(self.password) if self.password else ''
        return f"postgresql://{self.user}:{password}@{self.host}:{self.port}/{self.database}"
    
    def get_engine(self) -> Engine:
        """Create SQLAlchemy engine with connection pooling."""
        connection_string = self.get_connection_string()
        
        engine = create_engine(
            connection_string,
            poolclass=QueuePool,
            pool_size=self.pool_size,
            max_overflow=self.max_overflow,
            pool_timeout=self.pool_timeout,
            pool_recycle=self.pool_recycle,
            echo=self.echo,
            connect_args={
                'connect_timeout': 10,
                'application_name': 'edp_analytics',
            }
        )
        return engine


class PostgresClient:
    """
    PostgreSQL client with connection management and query utilities.
    Use as a context manager for automatic cleanup.
    """
    
    def __init__(self, config: Optional[DatabaseConfig] = None):
        """
        Initialize the PostgreSQL client.
        
        Args:
            config: Database configuration. If None, uses environment variables.
        """
        self.config = config or DatabaseConfig()
        self.engine = self.config.get_engine()
        self.metadata = MetaData()
        
        # Track connection state
        self._connection = None
        self._transaction = None
        
        logger.info(f"PostgresClient initialized for database: {self.config.database}")
    
    @contextmanager
    def connect(self) -> Generator:
        """
        Context manager for database connections.
        Ensures connections are properly closed after use.
        
        Usage:
            with client.connect() as conn:
                result = conn.execute(text("SELECT * FROM users"))
        
        Yields:
            SQLAlchemy connection object
        """
        connection = None
        try:
            connection = self.engine.connect()
            logger.debug("Database connection established")
            yield connection
        except OperationalError as e:
            logger.error(f"Database connection failed: {e}")
            raise
        except SQLAlchemyError as e:
            logger.error(f"Database error: {e}")
            raise
        finally:
            if connection:
                connection.close()
                logger.debug("Database connection closed")
    
    @contextmanager
    def transaction(self) -> Generator:
        """
        Context manager for database transactions.
        Automatically commits on success or rolls back on error.
        
        Usage:
            with client.transaction() as conn:
                conn.execute(text("INSERT INTO users (name) VALUES ('Alice')"))
                # Auto-commits if no exception
        """
        connection = None
        try:
            connection = self.engine.connect()
            trans = connection.begin()
            logger.debug("Transaction started")
            yield connection
            trans.commit()
            logger.debug("Transaction committed")
        except Exception as e:
            if connection:
                trans.rollback()
                logger.warning(f"Transaction rolled back due to: {e}")
            raise
        finally:
            if connection:
                connection.close()
                logger.debug("Connection closed")
    
    def execute_query(self, sql: str, params: Optional[Dict[str, Any]] = None) -> list:
        """
        Execute a query and return all results as a list of dictionaries.
        
        Args:
            sql: SQL query string
            params: Query parameters for prepared statements
            
        Returns:
            List of dictionaries representing rows
        """
        with self.connect() as conn:
            try:
                result = conn.execute(text(sql), params or {})
                # Convert to list of dicts
                columns = result.keys()
                rows = [dict(zip(columns, row)) for row in result]
                logger.debug(f"Query returned {len(rows)} rows")
                return rows
            except SQLAlchemyError as e:
                logger.error(f"Query execution failed: {sql[:100]}... Error: {e}")
                raise
    
    def execute_many(self, sql: str, params_list: list) -> int:
        """
        Execute a parameterized query multiple times with different parameters.
        
        Args:
            sql: SQL query string with placeholders
            params_list: List of parameter dictionaries
            
        Returns:
            Number of rows affected
        """
        if not params_list:
            return 0
        
        with self.connect() as conn:
            try:
                result = conn.execute(text(sql), params_list)
                affected = result.rowcount
                logger.debug(f"Executed {len(params_list)} operations, {affected} rows affected")
                return affected
            except SQLAlchemyError as e:
                logger.error(f"Batch execution failed: {e}")
                raise
    
    def get_table_info(self, table_name: str, schema: str = 'analytics') -> Dict[str, Any]:
        """
        Get metadata about a specific table.
        
        Args:
            table_name: Name of the table
            schema: Database schema (default: 'analytics')
            
        Returns:
            Dictionary with table metadata
        """
        with self.connect() as conn:
            # Get column information
            query = """
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default
                FROM information_schema.columns
                WHERE table_schema = :schema
                AND table_name = :table_name
                ORDER BY ordinal_position
            """
            columns = conn.execute(
                text(query),
                {'schema': schema, 'table_name': table_name}
            ).fetchall()
            
            # Get primary key information
            pk_query = """
                SELECT
                    kcu.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kcu
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                WHERE tc.constraint_type = 'PRIMARY KEY'
                    AND tc.table_schema = :schema
                    AND tc.table_name = :table_name
            """
            pk_columns = conn.execute(
                text(pk_query),
                {'schema': schema, 'table_name': table_name}
            ).fetchall()
            
            return {
                'name': table_name,
                'schema': schema,
                'columns': [dict(col._mapping) for col in columns],
                'primary_key': [col[0] for col in pk_columns]
            }
    
    def table_exists(self, table_name: str, schema: str = 'analytics') -> bool:
        """Check if a table exists in the database."""
        query = """
            SELECT EXISTS (
                SELECT 1 FROM information_schema.tables
                WHERE table_schema = :schema
                AND table_name = :table_name
            )
        """
        result = self.execute_query(query, {'schema': schema, 'table_name': table_name})
        return result[0]['exists'] if result else False
    
    def get_table_count(self, table_name: str, schema: str = 'analytics') -> int:
        """Get the row count for a table."""
        result = self.execute_query(
            f"SELECT COUNT(*) as count FROM {schema}.{table_name}"
        )
        return result[0]['count'] if result else 0
    
    def close(self):
        """Close the database connection pool."""
        self.engine.dispose()
        logger.info("Database connection pool disposed")


# Singleton instance
_default_client = None


def get_client() -> PostgresClient:
    """
    Get a singleton database client instance.
    Use this in your application code.
    """
    global _default_client
    if _default_client is None:
        _default_client = PostgresClient()
    return _default_client


# Example usage and testing
if __name__ == "__main__":
    print("=" * 60)
    print("Testing PostgreSQL Client")
    print("=" * 60)
    
    client = get_client()
    
    try:
        # Test connection
        result = client.execute_query("SELECT 1 as test, current_timestamp as now")
        print(f"✅ Connection test: {result}")
        
        # Get table list
        tables = client.execute_query("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'analytics'
            ORDER BY table_name
        """)
        print(f"\n📋 Tables in analytics schema:")
        for table in tables:
            print(f"   - {table['table_name']}")
        
        # Get customer count
        count = client.get_table_count('customers')
        print(f"\n👤 Customers: {count}")
        
        # Test transaction
        print("\n🔄 Testing transaction...")
        with client.transaction() as conn:
            # This is just a test, we won't actually modify data
            result = conn.execute(text("SELECT COUNT(*) as count FROM analytics.customers"))
            print(f"   Transaction connection works: {result.fetchone()[0]} customers found")
        
        print("\n✅ All tests passed!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        raise
    finally:
        client.close()
EOF
```

Test the database utility:

```bash
# Run the client test
python src/database/postgres.py

# Expected output: Shows connection test results and table list
```

---

## Step 6: Verify Everything Works Together

### The Target
Run a comprehensive verification that all components are working correctly.

### The Implementation

```bash
cat > scripts/verify_setup.py << 'EOF'
#!/usr/bin/env python3
"""Verify the complete database setup is working correctly."""

import sys
from pathlib import Path

project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from src.database.postgres import get_client


def verify_installation():
    """Run comprehensive verification of the database setup."""
    print("=" * 60)
    print("Verifying Executive Decision Pipeline Setup")
    print("=" * 60)
    
    client = get_client()
    
    try:
        # 1. Test connection
        print("\n1️⃣ Testing database connection...")
        result = client.execute_query("SELECT version() as version")
        print(f"   ✅ Connected to PostgreSQL: {result[0]['version'][:50]}...")
        
        # 2. Check schema
        print("\n2️⃣ Checking schema...")
        tables = client.execute_query("""
            SELECT table_name, 
                   (SELECT COUNT(*) FROM information_schema.columns 
                    WHERE table_schema = 'analytics' 
                    AND table_name = t.table_name) as columns
            FROM information_schema.tables t
            WHERE table_schema = 'analytics'
            ORDER BY table_name
        """)
        print(f"   ✅ Found {len(tables)} tables:")
        for table in tables:
            print(f"      - {table['table_name']} ({table['columns']} columns)")
        
        # 3. Check data population
        print("\n3️⃣ Checking data population...")
        for table in tables:
            count = client.get_table_count(table['table_name'])
            status = "✅" if count > 0 else "⚠️"
            print(f"      {status} {table['table_name']}: {count} rows")
        
        # 4. Check views
        print("\n4️⃣ Checking views...")
        views = client.execute_query("""
            SELECT viewname
            FROM pg_views
            WHERE schemaname = 'analytics'
            ORDER BY viewname
        """)
        print(f"   ✅ Found {len(views)} views:")
        for view in views:
            print(f"      - {view['viewname']}")
        
        # 5. Test business logic
        print("\n5️⃣ Testing business logic...")
        
        # Check customer lifetime value view
        clv = client.execute_query("""
            SELECT COUNT(*) as total, SUM(total_spent) as total_spent
            FROM analytics.customer_lifetime_value
        """)
        print(f"   ✅ Customer LTV calculated: {clv[0]['total']} customers, ${clv[0]['total_spent']:,.2f} total value")
        
        # Check monthly sales
        monthly = client.execute_query("""
            SELECT COUNT(*) as months, SUM(total_revenue) as total_revenue
            FROM analytics.monthly_sales_summary
        """)
        print(f"   ✅ Monthly sales summarized: {monthly[0]['months']} months, ${monthly[0]['total_revenue']:,.2f} revenue")
        
        # 6. Check trigger
        print("\n6️⃣ Checking triggers...")
        triggers = client.execute_query("""
            SELECT trigger_name, event_manipulation
            FROM information_schema.triggers
            WHERE trigger_schema = 'analytics'
            ORDER BY trigger_name
        """)
        print(f"   ✅ Found {len(triggers)} triggers:")
        for trigger in triggers:
            print(f"      - {trigger['trigger_name']} (on {trigger['event_manipulation']})")
        
        print("\n" + "=" * 60)
        print("✅ ALL VERIFICATIONS PASSED!")
        print("=" * 60)
        print("\n🎉 Your Executive Decision Pipeline database is ready!")
        print("   You're now ready for Module 6.1, Part 2: Semantic Layer with dbt")
        
        return True
        
    except Exception as e:
        print(f"\n❌ Verification failed: {e}")
        return False
    finally:
        client.close()


if __name__ == "__main__":
    success = verify_installation()
    sys.exit(0 if success else 1)
EOF
```

Run the verification:

```bash
python scripts/verify_setup.py
```

---

## Summary of What You've Built

You've successfully:

1. **Created a production-grade project structure** with proper organization
2. **Set up Docker containers** for PostgreSQL and Metabase
3. **Designed a normalized e-commerce schema** with 10 tables
4. **Generated realistic sample data** with 5,000+ customers and 15,000+ orders
5. **Created views** for common business logic (customer LTV, monthly sales)
6. **Built a Python database utility** with connection pooling and context managers
7. **Verified everything works** with comprehensive tests

## What's Next

**[GENERATED: Module 6.1, Part 1 - Database Setup]**

You've laid the foundation. Now we'll build our **semantic layer** using dbt (data build tool), which will:
- Centralize our business logic
- Create reusable metric definitions
- Version control our transformations
- Enable self-service analytics

