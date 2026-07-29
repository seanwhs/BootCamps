# Serverless Postgres with Neon: From Zero to Production
## Comprehensive Slide Deck Outline

---

## PART 0: INTRODUCTION & SETTING THE STAGE

### Section 0.1: Welcome & Course Overview
**Slides: 1-5**

**Slide 1: Title Slide**
- Course Title: Serverless Postgres with Neon: From Zero to Production
- Subtitle: Building a Production-Ready E-Commerce Backend
- Duration: [X] hours / [X] sessions
- Instructor introduction

**Slide 2: What This Course Covers**
- Modern PostgreSQL without infrastructure headaches 
- Neon's serverless PostgreSQL platform features:
  - Scale-to-zero compute 
  - Instant database branching 
  - Connection pooling built-in 
  - Point-in-time restore 
- Building a complete e-commerce backend
- SQL fundamentals + cutting-edge serverless workflows

**Slide 3: What You'll Build**
- Complete e-commerce backend architecture
- Product catalog with flexible attributes
- User authentication and management
- Order processing with inventory
- Real-time sales analytics
- CI/CD with database branches 

**Slide 4: Target Audience**
- Developers with basic programming experience
- New to databases or SQL (or need a refresher)
- Interested in modern serverless workflows
- Want to build production-grade applications

**Slide 5: Prerequisites & Setup**
- Neon account (free tier) 
- PostgreSQL client (psql recommended)
- Development environment (terminal, code editor)
- Node.js (for API examples)
- Git for version control

---

### Section 0.2: Architecture Overview
**Slides: 6-10**

**Slide 6: The Problem with Traditional PostgreSQL**
- Installing and configuring locally
- Connection string management across environments
- Scaling concerns
- Database copy/backup challenges
- Cost of idle infrastructure 

**Slide 7: The Neon Solution**
- Serverless PostgreSQL platform 
- Compute-Storage separation 
- Key differentiators:
  - Scale-to-zero (no paying for idle) 
  - Instant branching (Git-like workflows) 
  - Built-in connection pooling 
  - Free tier: 0.5GB storage, 100 compute hours 

**Slide 8: Ultimate Architecture Diagram**
```
┌─────────────────────────────────────┐
│      Frontend Application           │
│  (React, Next.js, or any client)    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         API Layer (Your Code)       │
│  - Express.js / Fastify             │
│  - Business Logic & Validation       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│        Neon PostgreSQL              │
│  ┌───────────────────────────────┐ │
│  │        Main Branch            │ │
│  │  ┌──────────┐ ┌──────────┐  │ │
│  │  │ products │ │  users   │  │ │
│  │  │ orders   │ │ address  │  │ │
│  │  └──────────┘ └──────────┘  │ │
│  └───────────────────────────────┘ │
│              │                      │
│              ▼                      │
│  ┌───────────────────────────────┐ │
│  │   Development Branch           │ │
│  │  (Instant copy for testing)   │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Slide 9: Course Roadmap**
| Part | Topic | Focus |
|------|-------|-------|
| 1 | Setup & Cloud SQL Fundamentals | CRUD, Basic Queries |
| 2 | Bulletproof Schemas & Data Integrity | Constraints, UUIDs, Pooling |
| 3 | Database Branching & Relational Architecture | Foreign Keys, Joins, Branches |
| 4 | Analytical Power | Aggregations, Window Functions |
| 5 | JSONB & Extensions | Semi-structured data, Search |
| 6 | Performance, Transactions & CI/CD | Optimization, Deployment |

**Slide 10: Learning Outcomes**
- ✅ Provision production-ready PostgreSQL in seconds
- ✅ Design normalized schemas with constraints
- ✅ Write complex SQL queries (joins, aggregations)
- ✅ Implement ACID transactions
- ✅ Use JSONB for flexible document storage
- ✅ Optimize queries with proper indexing
- ✅ Leverage Neon database branching for CI/CD
- ✅ Apply skills to any PostgreSQL project

---

## PART 1: INSTANT SETUP & CLOUD SQL FUNDAMENTALS

### Section 1.1: Getting Started with Neon
**Slides: 11-15**

**Slide 11: Part 1 Overview**
**Target**: Spin up Neon database, connect, create products table, perform CRUD
**Concepts**: Databases as digital filing cabinets, serverless architecture
**Hands-On**: Provision database, build products table, seed data, CRUD queries

**Slide 12: Neon Account Setup**
- Navigate to neon.tech 
- Sign up with GitHub (recommended) or email
- Create project: "ecommerce-backend"
- Choose region closest to users 
- Wait ~10 seconds for provisioning 

**Slide 13: Project & Database Structure**
- Project = top-level container 
- production = root default branch 
- Each project holds: branches, databases, roles
- Create one project per repository 

**Slide 14: Connection Strings Explained**
```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require

Breakdown:
- postgresql:// - Protocol
- username:password - Your credentials
- ep-xyz.us-east-1.aws.neon.tech - Host endpoint
- /database - Database name (neondb)
- ?sslmode=require - SSL required (always!) 
```

**Slide 15: Neon CLI Installation**
```bash
# Install CLI
npm install -g neonctl

# Authenticate
neonctl auth

# Verify
neonctl --version

# List projects
neonctl projects list
```

---

### Section 1.2: Connecting to Your Database
**Slides: 16-20**

**Slide 16: psql Installation**
```bash
# macOS
brew install postgresql@16

# Ubuntu/Debian
sudo apt update
sudo apt install postgresql-client

# Windows: Download from PostgreSQL Downloads
```

**Slide 17: Connect with psql**
```bash
psql "postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require"
```
**Expected Output**:
```
psql (16.1)
SSL connection (protocol: TLSv1.3)
Type "help" for help.
neondb=>
```

**Slide 18: Test Connection**
```sql
SELECT version();
-- Should show PostgreSQL 16.x
```

**Slide 19: Understanding Data Types**
| Type | Use Case | Example |
|------|----------|---------|
| SERIAL | Auto-incrementing IDs | 1, 2, 3... |
| VARCHAR(255) | Short text | Names, emails |
| TEXT | Unlimited text | Descriptions |
| NUMERIC(10,2) | Money/Exact decimals | 99.99 |
| INTEGER | Whole numbers | Stock quantity |
| TIMESTAMPTZ | Date+time+timezone | created_at |

**Slide 20: psql Quick Reference**
```sql
\c database_name  -- Connect to database
\l              -- List databases
\dt             -- List tables
\d table_name   -- Describe table
\q              -- Quit psql
```

---

### Section 1.3: Creating the Products Table
**Slides: 21-25**

**Slide 21: Table Creation Pattern**
```sql
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```

**Slide 22: Understanding Each Column**
- **SERIAL PRIMARY KEY**: Auto-incrementing unique ID 
- **VARCHAR(255) NOT NULL**: Required text, max 255 chars
- **TEXT**: Unlimited text (good for descriptions)
- **NUMERIC(10,2)**: Exact decimal, 10 digits total, 2 after decimal
- **INTEGER NOT NULL DEFAULT 0**: Whole number, defaults to 0
- **TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP**: Auto-set on creation

**Slide 23: Verify Table Structure**
```sql
\d products
```
**Output**: Shows all columns with data types and constraints

**Slide 24: E-Commerce Table Design Pattern** 
- Each entity gets its own table
- Unique identifiers (primary keys)
- Foreign keys for relationships
- Proper data types for each field
- NOT NULL for required fields
- DEFAULT values for common cases

**Slide 25: Key Design Principles** 
| Principle | Example |
|-----------|---------|
| Each user has unique ID | cust_id SERIAL PRIMARY KEY |
| Product has unique ID | item_id SERIAL PRIMARY KEY |
| Required fields = NOT NULL | item_name VARCHAR(100) NOT NULL |
| Foreign keys link tables | cust_id INTEGER REFERENCES users(cust_id) |

---

### Section 1.4: CRUD Operations
**Slides: 26-35**

**Slide 26: CREATE (INSERT)**
```sql
-- Single row
INSERT INTO products (name, description, price, stock_quantity)
VALUES ('Wireless Headphones', 'Premium noise-cancelling', 99.99, 150);

-- Multiple rows
INSERT INTO products (name, price, stock_quantity) VALUES
    ('4K Camera', 249.99, 45),
    ('Smart Watch', 199.00, 78),
    ('Docking Station', 149.50, 23);
```
**Key**: Specify columns → values match order

**Slide 27: READ (SELECT) - Basic**
```sql
-- All columns, all rows
SELECT * FROM products;

-- Specific columns
SELECT id, name, price FROM products;

-- With filter
SELECT * FROM products WHERE price > 100;

-- With ordering
SELECT * FROM products ORDER BY price DESC;

-- With limit
SELECT * FROM products LIMIT 5;
```

**Slide 28: READ (SELECT) - Advanced**
```sql
-- Range query
SELECT * FROM products WHERE price BETWEEN 100 AND 200;

-- Pattern matching
SELECT * FROM products WHERE name ILIKE '%wireless%';

-- Multiple conditions
SELECT * FROM products 
WHERE price > 50 AND stock_quantity > 0;

-- Pagination
SELECT * FROM products LIMIT 10 OFFSET 20;
```

**Slide 29: UPDATE**
```sql
-- Update single column
UPDATE products 
SET price = 39.99 
WHERE name = 'Wireless Mouse';

-- Update multiple columns
UPDATE products 
SET price = 54.99, stock_quantity = 25 
WHERE name = 'Keyboard';

-- Calculate new value
UPDATE products 
SET price = price * 1.10 
WHERE price < 50;
```
**⚠️ WARNING**: Always use WHERE or you update ALL rows!

**Slide 30: DELETE**
```sql
-- Delete specific row
DELETE FROM products WHERE id = 5;

-- Delete with conditions
DELETE FROM products WHERE stock_quantity = 0;

-- Safe: Check before delete
SELECT * FROM products WHERE id = 5;
DELETE FROM products WHERE id = 5;
```
**⚠️ WARNING**: Always use WHERE or you delete ALL data!

**Slide 31: CRUD Summary Table**
| Operation | SQL Command | Key Rule |
|-----------|-------------|----------|
| Create | INSERT INTO ... VALUES | Match columns/values |
| Read | SELECT ... FROM ... WHERE | Filter with WHERE |
| Update | UPDATE ... SET ... WHERE | ALWAYS use WHERE |
| Delete | DELETE FROM ... WHERE | ALWAYS use WHERE |

---

### Section 1.5: Filtering & Sorting
**Slides: 32-38**

**Slide 32: WHERE Clause Operators**
```sql
=   -- Equal
!=  -- Not equal
>   -- Greater than
<   -- Less than
>=  -- Greater than or equal
<=  -- Less than or equal
IN  -- In a list
BETWEEN -- Range
LIKE -- Pattern (case-sensitive)
ILIKE -- Pattern (case-insensitive)
IS NULL -- Check for NULL
IS NOT NULL -- Check for non-NULL
```

**Slide 33: Pattern Matching**
```sql
-- Starts with 'K'
SELECT * FROM products WHERE name LIKE 'K%';

-- Ends with 'er'
SELECT * FROM products WHERE name LIKE '%er';

-- Contains 'om'
SELECT * FROM products WHERE name LIKE '%om%';

-- Case-insensitive
SELECT * FROM products WHERE name ILIKE '%keyboard%';
```
**Pattern Symbols**: `%` = any characters, `_` = exactly one character

**Slide 34: ORDER BY**
```sql
-- Ascending (default)
SELECT * FROM products ORDER BY price;

-- Descending
SELECT * FROM products ORDER BY price DESC;

-- Multiple columns
SELECT * FROM products ORDER BY price DESC, name ASC;

-- With NULL handling
SELECT * FROM products ORDER BY stock_quantity ASC NULLS LAST;
```

**Slide 35: LIMIT & Pagination**
```sql
-- First 5 products
SELECT * FROM products LIMIT 5;

-- Most expensive 3
SELECT * FROM products ORDER BY price DESC LIMIT 3;

-- Page 2 (rows 11-20)
SELECT * FROM products ORDER BY id LIMIT 10 OFFSET 10;
```

**Slide 36: Combined Example**
```sql
-- Expensive products with low stock
SELECT id, name, price, stock_quantity
FROM products
WHERE price > 100
  AND stock_quantity < 50
ORDER BY price DESC
LIMIT 5;
```
**Use case**: Inventory alert for expensive items running low

**Slide 37: Verification Commands**
```sql
-- Count products
SELECT COUNT(*) FROM products;

-- See sample data
SELECT * FROM products LIMIT 5;

-- Check for duplicates
SELECT name, COUNT(*) FROM products GROUP BY name HAVING COUNT(*) > 1;
```

**Slide 38: Exercise - Build a Catalog Query**
```sql
-- Requirements: In-stock only, cheapest first, show 5 per page
SELECT 
    id, name, price,
    CASE 
        WHEN LENGTH(description) > 100 
        THEN LEFT(description, 97) || '...' 
        ELSE description 
    END AS short_description,
    stock_quantity
FROM products
WHERE stock_quantity > 0
ORDER BY price ASC
LIMIT 5 OFFSET 0;
```

---

## PART 2: BULLETPROOF SCHEMAS & DATA INTEGRITY

### Section 2.1: Primary Keys - SERIAL vs UUID
**Slides: 39-45**

**Slide 39: Part 2 Overview**
**Target**: Build robust users table with constraints and UUIDs
**Concepts**: Data integrity, primary key selection, connection pooling
**Hands-On**: UUID-enabled users table with validation, constraints, pooling

**Slide 40: SERIAL Primary Keys**
```sql
CREATE TABLE example_serial (
    id SERIAL PRIMARY KEY,  -- 1, 2, 3, 4...
    name TEXT
);
```
**Pros**: Simple, efficient (4 bytes), fast joins
**Cons**: Predictable (security risk), not portable across databases

**Slide 41: UUID Primary Keys**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE example_uuid (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT
);
-- 550e8400-e29b-41d4-a716-446655440000
```
**Pros**: Globally unique, non-sequential (security)
**Cons**: Larger (16 bytes), slower indexing

**Slide 42: Which to Choose?**
| Use SERIAL When | Use UUID When |
|-----------------|---------------|
| Simple internal apps | Public-facing APIs |
| No database merging | Distributed systems |
| Performance critical | Security matters |
| Billions of rows | Client-side ID generation |

**Slide 43: Enable UUID in Neon**
```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Test generation
SELECT uuid_generate_v4();
-- Returns: 550e8400-e29b-41d4-a716-446655440000
```

**Slide 44: Complete Users Table Schema**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);
```

**Slide 45: Constraints Explained**
- **UNIQUE NOT NULL**: Email and username must be unique and present
- **NOT NULL DEFAULT 'active'**: Status has default if not provided
- **CHECK constraints** (next slide): Validate formats
- **FOREIGN KEY constraints**: Reference other tables
- **TIMESTAMPTZ**: Store timezone-aware timestamps

---

### Section 2.2: Data Integrity Constraints
**Slides: 46-52**

**Slide 46: Types of Constraints**
| Constraint | Purpose | Example |
|------------|---------|---------|
| NOT NULL | Value required | email VARCHAR NOT NULL |
| UNIQUE | No duplicates | email UNIQUE |
| PRIMARY KEY | Unique identifier | id SERIAL PRIMARY KEY |
| FOREIGN KEY | Reference another table | user_id REFERENCES users(id) |
| CHECK | Custom validation | price CHECK (price >= 0) |
| DEFAULT | Fallback value | status DEFAULT 'active' |

**Slide 47: Email Validation with CHECK**
```sql
CONSTRAINT valid_email 
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```
**Pattern Breakdown**:
- `^` - Start of string
- `[A-Za-z0-9._%+-]+` - Local part
- `@` - Literal @ symbol
- `[A-Za-z0-9.-]+` - Domain name
- `\.` - Literal dot
- `[A-Za-z]{2,}` - Top-level domain (at least 2 chars)
- `$` - End of string

**Slide 48: Username Validation**
```sql
CONSTRAINT valid_username 
CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$')
```
**Rules**:
- First character must be a letter
- Followed by 2-49 letters, numbers, or underscores
- Total length: 3-50 characters

**Slide 49: Enum-like Status Validation**
```sql
CONSTRAINT valid_status 
CHECK (status IN ('active', 'inactive', 'suspended'))

CONSTRAINT valid_role 
CHECK (role IN ('customer', 'staff', 'admin'))
```
**Benefits**: 
- Database enforces valid values
- No invalid statuses/roles can be inserted
- Clear to developers what values are valid

**Slide 50: Testing Constraints**
```sql
-- This should FAIL
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('invalidemail.com', '1test', 'hash', 'Test');
-- ERROR: invalid email format
-- ERROR: username must start with letter

-- This should SUCCEED
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('test@example.com', 'test_user', 'hash', 'Test User');
```

**Slide 51: Automatic Timestamps**
```sql
-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to call function
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

**Slide 52: Soft Delete Pattern**
```sql
-- Mark as deleted (not actually delete)
UPDATE users 
SET deleted_at = CURRENT_TIMESTAMP 
WHERE email = 'user@example.com';

-- Query active users (deleted_at IS NULL)
SELECT * FROM users WHERE deleted_at IS NULL;

-- View for active users
CREATE VIEW active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;
```
**Benefits**: Data not permanently lost, can restore, audit trail

---

### Section 2.3: Connection Pooling in Neon
**Slides: 53-57**

**Slide 53: Direct vs Pooled Connections**
```
Direct (Standard):
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require

Pooled (Recommended for Serverless):
postgresql://username:password@ep-xyz-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction
```

**Slide 54: Why Pooling Matters**
- **Problem**: Serverless functions create a new connection per request
- **Opening connections is slow** (TCP handshake, authentication)
- **Connection limits**: Can exhaust max_connections

**Pooled Connections**:
- Reuse connections between requests
- Much faster for short-lived connections
- Can handle thousands of concurrent users 

**Slide 55: Pooling Modes**
| Mode | Description | Best For |
|------|-------------|----------|
| Session | Connection for entire session | Long-running apps |
| Transaction | Connection for one transaction | Serverless functions |

**Slide 56: Using Pooled Connection in Node.js**
```javascript
const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_POOLED_URL,
    max: 20, // Max connections in pool
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Use the pool
const client = await pool.connect();
try {
    const result = await client.query('SELECT * FROM products');
    // Process result
} finally {
    client.release(); // Return to pool
}
```

**Slide 57: Migration Script**
```sql
-- migrations/001_create_users_table.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    -- ... more columns and constraints
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
```

---

## PART 3: DATABASE BRANCHING & RELATIONAL ARCHITECTURE

### Section 3.1: Neon Database Branching
**Slides: 58-64**

**Slide 58: Part 3 Overview**
**Target**: Create dev/staging branches, build relational models, write JOINs
**Concepts**: Neon branching as Git for databases, foreign keys, relationships
**Hands-On**: Create branch, orders/order_items with FKs, complex JOIN queries

**Slide 59: What is Database Branching?** 
- Instant copy of your database (copy-on-write)
- Branches share underlying storage 
- Changes only stored when you modify data
- Traditional copying: hours/days for large databases
- Neon: seconds regardless of size 

**Slide 60: Branching Analogy** 
```
Git:  Your code repository
Neon: Your database

git branch feature-x  →  neonctl branches create --name feature-x
git reset --hard main →  neonctl branches reset feature-x --target main
git merge feature-x   →  neonctl branches merge feature-x --target main
```

**Slide 61: Creating a Branch**
```bash
# In Neon Console: Branches → Create Branch → Name: dev-branch

# Or using CLI
neonctl branches create --name dev-branch --project-id your-project-id

# Create from specific parent
neonctl branches create --name staging-branch --parent main --project-id your-project-id

# Create with TTL (auto-delete after 4 hours) 
neonctl branches create --name test-123 --ttl 4h --parent main --project-id your-project-id
```

**Slide 62: Connect to Branch**
```bash
# Get connection string
neonctl branches get-connection-string dev-branch --project-id your-project-id

# Connect
psql "postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/dev-branch?sslmode=require"
```

**Slide 63: Branch Management Commands**
```bash
# List all branches
neonctl branches list --project-id your-project-id

# Get branch info
neonctl branches info dev-branch --project-id your-project-id

# Reset to parent (like git reset --hard) 
neonctl branches reset dev-branch --parent main --project-id your-project-id

# Merge changes 
neonctl branches merge dev-branch --target main --project-id your-project-id

# Delete branch
neonctl branches delete dev-branch --project-id your-project-id
```

**Slide 64: Branch Workflows** 
```
Production (main)
    │
    ├── development (long-lived)
    │       │
    │       ├── feature-payments (temporary)
    │       └── feature-auth (temporary)
    │
    └── staging (pre-production)
            │
            └── preview-pr-123 (auto-deleted)
```

---

### Section 3.2: Relational Models - One-to-Many
**Slides: 65-70**

**Slide 65: Relationship Types**
- **One-to-One (1:1)**: One user → one profile
- **One-to-Many (1:M)**: One user → many orders
- **Many-to-Many (M:N)**: Many products → many orders

**Slide 66: One-to-Many Pattern** 
```sql
-- Users table (one)
CREATE TABLE users (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL
);

-- Orders table (many)
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total NUMERIC(10,2)
);
```
**Relationship**: One user can have many orders
**Foreign Key**: user_id references users(id)

**Slide 67: Addresses Table (One-to-Many with Users)**
```sql
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_line1 VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    address_type VARCHAR(20) DEFAULT 'shipping',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);
```

**Slide 68: Orders Table (One-to-Many with Users)**
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    shipping_address_id UUID NOT NULL REFERENCES addresses(id) ON DELETE RESTRICT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    total NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT valid_status CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
```
**ON DELETE RESTRICT**: Prevents deleting user who has orders

**Slide 69: Cascade Rules Explained**
| Rule | Behavior | Use When |
|------|----------|----------|
| CASCADE | Delete child records | Addresses should be deleted with user |
| RESTRICT | Prevent deletion | Orders should remain even if user deleted |
| SET NULL | Set FK to NULL | Keep record but remove relationship |

**Slide 70: Creating Relationships in Practice**
```sql
-- Self-referencing (categories with subcategories)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE
);
```

---

### Section 3.3: Relational Models - Many-to-Many
**Slides: 71-75**

**Slide 71: Many-to-Many Pattern**
```sql
-- Junction table (resolves M:N)
CREATE TABLE order_items (
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```
**Key**: Junction table has composite primary key
**Purpose**: Connects orders and products

**Slide 72: Complete Relational Schema**
```
users ──┬── addresses (1:M)
        ├── orders (1:M)
        │       └── order_items (1:M)
        │               └── products (M:N)
        └── reviews (1:M)

products ──┬── order_items (1:M)
           ├── reviews (1:M)
           └── categories (M:1)
```

**Slide 73: Order Items with Denormalization**
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    -- Snapshot of product details (denormalized)
    product_name VARCHAR(255) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    line_subtotal NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
```
**Denormalization**: Store product_name and unit_price even if product changes later

**Slide 74: Creating the Order Items Table**
```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    line_subtotal NUMERIC(10,2) NOT NULL,
    line_total NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_quantity CHECK (quantity > 0),
    CONSTRAINT positive_price CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```

**Slide 75: Data Integrity in Relationships**
```sql
-- Get order with user and items
SELECT 
    o.order_number,
    u.full_name AS customer,
    oi.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
WHERE o.id = 'order-uuid-here';
```
**Key**: JOIN connects tables for complete picture

---

### Section 3.4: JOIN Queries
**Slides: 76-82**

**Slide 76: INNER JOIN**
```sql
-- Returns only matching records
SELECT 
    o.order_number,
    u.full_name AS customer,
    o.total
FROM orders o
INNER JOIN users u ON o.user_id = u.id;
```
**Use**: Orders that have users (should be all valid orders)

**Slide 77: LEFT JOIN**
```sql
-- Returns all users, even those without orders
SELECT 
    u.full_name,
    o.order_number,
    o.total
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
```
**Use**: Find users who haven't placed orders

**Slide 78: RIGHT JOIN**
```sql
-- Returns all orders, even those without users
SELECT 
    u.full_name,
    o.order_number
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;
```
**Use**: Find orphaned orders (invalid data)

**Slide 79: Multiple Joins**
```sql
-- Complete order details with user, addresses, and items
SELECT 
    o.order_number,
    u.full_name AS customer,
    sa.address_line1 AS shipping_address,
    ba.address_line1 AS billing_address,
    oi.product_name,
    oi.quantity,
    oi.line_total
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN addresses sa ON o.shipping_address_id = sa.id
JOIN addresses ba ON o.billing_address_id = ba.id
JOIN order_items oi ON o.id = oi.order_id;
```

**Slide 80: Self Join**
```sql
-- Categories with parent names
SELECT 
    c1.name AS category,
    c2.name AS parent_category
FROM categories c1
LEFT JOIN categories c2 ON c1.parent_id = c2.id;
```

**Slide 81: JOIN Visual Comparison**
| JOIN Type | Result |
|-----------|--------|
| INNER JOIN | Only rows that match in both tables |
| LEFT JOIN | All rows from left + matches from right |
| RIGHT JOIN | All rows from right + matches from left |
| FULL JOIN | All rows from both tables |

**Slide 82: Exercise - Customer Order Summary**
```sql
-- Get order count and total spent per customer
SELECT 
    u.id,
    u.full_name,
    COUNT(o.id) AS order_count,
    SUM(o.total) AS total_spent,
    AVG(o.total) AS avg_order_value,
    MIN(o.total) AS smallest_order,
    MAX(o.total) AS largest_order
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
  AND o.deleted_at IS NULL
GROUP BY u.id, u.full_name
HAVING COUNT(o.id) > 0
ORDER BY total_spent DESC;
```

---

## PART 4: ANALYTICAL POWER - AGGREGATIONS & WINDOW FUNCTIONS

### Section 4.1: Aggregate Functions
**Slides: 83-89**

**Slide 83: Part 4 Overview**
**Target**: Generate real-time sales reports and analytics
**Concepts**: Aggregations, grouping, window functions
**Hands-On**: Sales reporting, customer analytics, inventory metrics

**Slide 84: Basic Aggregate Functions**
```sql
-- COUNT: Number of rows
SELECT COUNT(*) FROM orders;

-- SUM: Add values
SELECT SUM(total) AS total_revenue FROM orders;

-- AVG: Average
SELECT AVG(total) AS avg_order_value FROM orders;

-- MIN/MAX: Minimum/Maximum
SELECT MIN(total), MAX(total) FROM orders;
```

**Slide 85: Aggregates with Conditions**
```sql
-- Count by status
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total) AS revenue
FROM orders
GROUP BY status;

-- Distinct counts
SELECT 
    COUNT(DISTINCT user_id) AS unique_customers,
    COUNT(DISTINCT payment_method) AS payment_methods_used
FROM orders;
```

**Slide 86: GROUP BY Pattern**
```sql
-- Monthly revenue
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(*) AS orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order_value
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;
```

**Slide 87: HAVING - Filtering Groups**
```sql
-- Customers with more than 3 orders
SELECT 
    user_id,
    COUNT(*) AS order_count,
    SUM(total) AS total_spent
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 3
ORDER BY total_spent DESC;
```
**Key**: WHERE filters rows, HAVING filters groups

**Slide 88: GROUP BY with Multiple Columns**
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
```

**Slide 89: Combined Analytics Report**
```sql
-- Daily sales summary
SELECT 
    DATE(order_date) AS sale_date,
    COUNT(*) AS total_orders,
    SUM(total) AS revenue,
    AVG(total) AS avg_order,
    COUNT(DISTINCT user_id) AS unique_customers,
    SUM(oi.quantity) AS items_sold
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY DATE(order_date)
ORDER BY sale_date DESC
LIMIT 30;
```

---

### Section 4.2: Window Functions
**Slides: 90-96**

**Slide 90: What are Window Functions?**
- Calculations across rows related to current row
- Unlike GROUP BY, rows are NOT collapsed
- Each row retains its identity
- Think: "Show me each order AND its running total"

**Slide 91: ROW_NUMBER**
```sql
-- Number orders per customer
SELECT 
    u.full_name,
    o.order_number,
    o.total,
    ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY o.order_date) AS order_sequence
FROM users u
JOIN orders o ON u.id = o.user_id
ORDER BY u.full_name, o.order_date;
```
**Output**: Each customer's orders numbered 1, 2, 3...

**Slide 92: RANK and DENSE_RANK**
```sql
-- Rank customers by spending
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total) DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY SUM(o.total) DESC) AS dense_rank
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```
**Difference**: RANK has gaps, DENSE_RANK doesn't

**Slide 93: LAG and LEAD**
```sql
-- Month-over-month comparison
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) AS previous_month,
    revenue - LAG(revenue, 1) OVER (ORDER BY month) AS change,
    ((revenue - LAG(revenue, 1) OVER (ORDER BY month)) / LAG(revenue, 1) OVER (ORDER BY month)) * 100 AS growth_pct
FROM monthly_revenue
ORDER BY month DESC;
```

**Slide 94: Running Totals**
```sql
-- Cumulative revenue over time
SELECT 
    order_date,
    total,
    SUM(total) OVER (ORDER BY order_date) AS running_total,
    AVG(total) OVER (ORDER BY order_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg_5
FROM orders
WHERE status NOT IN ('cancelled', 'refunded')
ORDER BY order_date;
```

**Slide 95: PARTITION BY in Window Functions**
```sql
-- Customer lifetime value with running total
SELECT 
    u.full_name,
    o.order_date,
    o.total,
    SUM(o.total) OVER (PARTITION BY u.id ORDER BY o.order_date) AS customer_lifetime_value,
    RANK() OVER (PARTITION BY u.id ORDER BY o.total DESC) AS order_size_rank
FROM users u
JOIN orders o ON u.id = o.user_id
ORDER BY u.full_name, o.order_date;
```

**Slide 96: Window Functions Summary**
| Function | Purpose | Use Case |
|----------|---------|----------|
| ROW_NUMBER | Sequential numbering | Number orders per customer |
| RANK/DENSE_RANK | Competition ranking | Top customers/products |
| LAG/LEAD | Previous/next values | Month-over-month comparison |
| SUM/AVG with OVER | Running totals | Cumulative revenue |
| NTILE | Percentile buckets | Customer segmentation |

---

### Section 4.3: CASE WHEN & Analytics
**Slides: 97-100**

**Slide 97: CASE WHEN - Conditional Logic**
```sql
-- Categorize orders by size
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
ORDER BY total DESC;
```

**Slide 98: Customer Segmentation with CASE**
```sql
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
JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

**Slide 99: Executive Dashboard View** 
```sql
CREATE VIEW executive_dashboard AS
SELECT 
    COUNT(DISTINCT o.id) AS total_orders,
    SUM(o.total) AS total_revenue,
    AVG(o.total) AS avg_order_value,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    ROUND(
        (COUNT(CASE WHEN o.status = 'completed' THEN 1 END)::FLOAT / 
         COUNT(*)::FLOAT) * 100, 2
    ) AS completion_rate,
    CURRENT_TIMESTAMP AS generated_at
FROM orders o
WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days';
```

**Slide 100: Product Performance Report**
```sql
SELECT 
    p.name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS revenue,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    CASE 
        WHEN SUM(oi.quantity) < 10 THEN 'Low Volume'
        WHEN SUM(oi.quantity) < 50 THEN 'Medium Volume'
        ELSE 'High Volume'
    END AS sales_volume,
    RANK() OVER (ORDER BY SUM(oi.line_total) DESC) AS revenue_rank
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY p.id, p.name
ORDER BY revenue DESC
LIMIT 10;
```

---

## PART 5: SEMI-STRUCTURED DATA WITH JSONB & EXTENSIONS

### Section 5.1: JSONB Fundamentals
**Slides: 101-107**

**Slide 101: Part 5 Overview**
**Target**: Add flexible product attributes and fuzzy search
**Concepts**: JSONB storage, PostgreSQL extensions, hybrid search
**Hands-On**: Product attributes JSONB, variants, full-text search, fuzzy search

**Slide 102: What is JSONB?**
- Binary JSON storage (validated and compressed)
- Perfect for flexible, semi-structured data
- Queryable like regular columns
- Indexable with GIN indexes
- Think: "Sticky notes attached to each record"

**Slide 103: When to Use JSONB vs Relational**
| Use JSONB When | Use Relational When |
|----------------|---------------------|
| Data varies per row | All rows have same fields |
| Schema evolves frequently | Schema is stable |
| Nested/complex structures | Simple flat data |
| Data rarely needs to be joined | Data needs to be joined often |
| Unknown fields upfront | All fields known upfront |

**Slide 104: Adding JSONB Columns**
```sql
ALTER TABLE products 
ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb,
ADD COLUMN variants JSONB DEFAULT '[]'::jsonb,
ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
```

**Slide 105: Inserting JSONB Data**
```sql
UPDATE products 
SET 
    attributes = jsonb_build_object(
        'color', 'Black',
        'connectivity', 'Bluetooth 5.3',
        'battery_life', '40 hours',
        'noise_cancellation', 'Active'
    ),
    variants = jsonb_build_array(
        jsonb_build_object(
            'color', 'Black',
            'price_adjustment', 0,
            'sku', 'HP-BLK-001',
            'stock', 50
        ),
        jsonb_build_object(
            'color', 'Silver',
            'price_adjustment', 10.00,
            'sku', 'HP-SLV-001',
            'stock', 25
        )
    ),
    metadata = jsonb_build_object(
        'brand', 'AudioPro',
        'warranty_months', 24,
        'category', 'Audio',
        'tags', array['premium', 'wireless']
    )
WHERE name = 'Premium Wireless Headphones';
```

**Slide 106: JSONB Query Operators**
| Operator | Description | Example |
|----------|-------------|---------|
| `->` | Get field (JSON) | attributes->'color' |
| `->>` | Get field (text) | attributes->>'color' |
| `#>` | Get nested (JSON) | attributes#>>'{ports,hdmi}' |
| `@>` | Contains | attributes @> '{"color":"Black"}' |
| `?` | Key exists | attributes ? 'color' |
| `?|` | Any key exists | attributes ?\| array['color','size'] |

**Slide 107: Querying JSONB Data**
```sql
-- Get specific attributes
SELECT 
    name,
    attributes->>'color' AS color,
    attributes->>'battery_life' AS battery
FROM products
WHERE attributes @> '{"noise_cancellation": "Active"}'::jsonb;

-- Query nested in variants
SELECT 
    name,
    variants
FROM products
WHERE variants @> '[{"color": "Silver"}]'::jsonb;
```

---

### Section 5.2: JSONB Indexing
**Slides: 108-111**

**Slide 108: GIN Index for JSONB**
```sql
-- Create GIN index (fast JSONB queries)
CREATE INDEX idx_products_attributes_gin ON products USING gin(attributes);
CREATE INDEX idx_products_metadata_gin ON products USING gin(metadata);
```
**Benefit**: Speeds up containment queries (`@>`)

**Slide 109: Path-Specific Indexes**
```sql
-- Index on specific JSON paths
CREATE INDEX idx_products_brand ON products ((metadata->>'brand'));
CREATE INDEX idx_products_category ON products ((metadata->>'category'));

-- Partial index for specific category
CREATE INDEX idx_products_audio_attributes ON products USING gin(attributes)
WHERE metadata->>'category' = 'Audio';
```

**Slide 110: Index Performance**
```sql
-- Check if index is used
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE metadata->>'brand' = 'AudioPro';
-- Should show "Index Scan" or "Bitmap Index Scan" 

-- Without index: Seq Scan on products (slow)
-- With index: Index Scan on idx_products_brand (fast)
```

**Slide 111: Index Tuning - Column Order** 
```sql
-- B-Tree index column order matters
-- Query: WHERE a = 42 AND b = 42
-- Best: CREATE INDEX ON example(a, b)  -- both columns in order
-- Also good: CREATE INDEX ON example(a) AND CREATE INDEX ON example(b)
-- Bad: CREATE INDEX ON example(b, a)  -- wrong order
```
**Rule**: Put most selective column first in composite indexes 

---

### Section 5.3: PostgreSQL Extensions in Neon
**Slides: 112-116**

**Slide 112: Available Extensions**
```sql
-- List all available extensions
SELECT * FROM pg_available_extensions ORDER BY name;

-- Key extensions for e-commerce:
-- uuid-ossp: UUID generation
-- pg_trgm: Fuzzy text search
-- btree_gin: Combined B-tree + GIN indexes
-- pgcrypto: Encryption functions
```

**Slide 113: Enable pg_trgm for Fuzzy Search**
```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create trigram indexes
CREATE INDEX idx_products_name_trgm ON products USING gin(name gin_trgm_ops);
CREATE INDEX idx_products_description_trgm ON products USING gin(description gin_trgm_ops);
```

**Slide 114: Fuzzy Search with Trigram**
```sql
-- Similarity scores
SELECT 
    name,
    similarity(name, 'wireless headphone') AS similarity_score
FROM products
ORDER BY similarity_score DESC;

-- Threshold search
SELECT * FROM products
WHERE similarity(name, 'wireless headphone') > 0.3
ORDER BY similarity(name, 'wireless headphone') DESC;

-- Word similarity (better for multi-word)
SELECT * FROM products
WHERE word_similarity('wirelss headphone', description) > 0.3;
```

**Slide 115: Full-Text Search Setup**
```sql
-- Add search vector column
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Update search vector
UPDATE products 
SET search_vector = 
    setweight(to_tsvector('english', COALESCE(name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(metadata->>'brand', '')), 'C');

-- Create index
CREATE INDEX idx_products_search_vector ON products USING gin(search_vector);

-- Full-text search
SELECT 
    name,
    ts_rank_cd(search_vector, plainto_tsquery('wireless headphones')) AS rank
FROM products
WHERE search_vector @@ plainto_tsquery('wireless headphones')
ORDER BY rank DESC;
```

**Slide 116: Hybrid Search Function**
```sql
CREATE OR REPLACE FUNCTION hybrid_product_search(search_term TEXT)
RETURNS TABLE(
    product_name VARCHAR,
    price NUMERIC,
    relevance_score FLOAT,
    match_type TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH full_text AS (
        SELECT name, price,
            ts_rank_cd(search_vector, plainto_tsquery(search_term)) AS score
        FROM products
        WHERE search_vector @@ plainto_tsquery(search_term)
    ),
    fuzzy_matches AS (
        SELECT name, price,
            similarity(name, search_term) AS score
        FROM products
        WHERE similarity(name, search_term) > 0.3
    )
    SELECT name, price, score, 'Full-Text' FROM full_text
    UNION ALL
    SELECT name, price, score, 'Fuzzy' FROM fuzzy_matches
    WHERE NOT EXISTS (SELECT 1 FROM full_text ft WHERE ft.name = fuzzy_matches.name)
    ORDER BY relevance_score DESC;
END;
$$ LANGUAGE plpgsql;
```

---

## PART 6: PERFORMANCE, TRANSACTIONS & SERVERLESS WORKFLOWS

### Section 6.1: Query Optimization
**Slides: 117-125**

**Slide 117: Part 6 Overview**
**Target**: Optimize queries, implement transactions, set up CI/CD
**Concepts**: EXPLAIN ANALYZE, indexing strategies, ACID, Neon branching workflows
**Hands-On**: Query optimization, inventory reservation, GitHub Actions with Neon

**Slide 118: EXPLAIN ANALYZE** 
```sql
EXPLAIN ANALYZE
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status NOT IN ('cancelled', 'refunded')
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

**Slide 119: Reading EXPLAIN Output** 
```
Seq Scan on orders (cost=0.00..245.00 rows=1000 width=100)
  Filter: (status NOT IN ('cancelled','refunded'))
  Rows Removed by Filter: 9000

Problem: Sequential scan on large table
Solution: Add index on status column
```
**Key indicators**:
- "Seq Scan" on large table → Missing index 
- "Rows Removed by Filter" high → Poor selectivity 
- "Nested Loop" on huge tables → Inefficient join

**Slide 120: Rows Removed by Filter** 
```sql
-- Problem: Index used but many rows filtered
CREATE INDEX example_a_idx ON example (a);

EXPLAIN ANALYZE SELECT id FROM example WHERE a = 42 AND b = 42;
-- Rows Removed by Filter: 1016
-- Only 1 row returned from 1017 scanned

-- Solution: Composite index
CREATE INDEX example_a_b_idx ON example (a, b);
-- Query now: Index Scan (fast, no filter)
```

**Slide 121: Index Types Reference** 
| Type | Best For | Example |
|------|----------|---------|
| B-Tree (default) | Equality, range | WHERE price > 100 |
| GIN | JSONB, arrays, full-text | WHERE attributes @> '{"color":"Black"}' |
| BRIN | Very large ordered tables | WHERE created_at > '2024-01-01' |
| Partial | Frequent subset | WHERE deleted_at IS NULL |
| Covering | Index-only scans | INCLUDE (total, status) |

**Slide 122: Creating Performance Indexes**
```sql
-- B-Tree: Range queries
CREATE INDEX idx_orders_date ON orders(order_date DESC);

-- Composite: Multiple conditions 
CREATE INDEX idx_orders_user_status_date ON orders(user_id, status, order_date);

-- Partial: Specific use case
CREATE INDEX idx_orders_active ON orders(order_date) 
WHERE status NOT IN ('cancelled', 'refunded');

-- Covering: Index-only scans
CREATE INDEX idx_orders_covering ON orders(user_id, order_date) 
INCLUDE (total, status);
```

**Slide 123: Keep Index Set Lean** 
```
Every extra index costs you:
- Writes: INSERT/UPDATE loops through all indexes 
- Reads: Planner examines all indexes (O(N) to O(N²)) 
- Memory: Unused indexes still consume cache
- Vacuum: Processes all indexes twice 
- WAL: More indexes = more replication pressure 
```
**Rule**: Drop unused indexes 

**Slide 124: Finding Unused Indexes** 
```sql
SELECT 
    schemaname,
    relname AS table_name,
    indexrelname AS index_name,
    idx_scan AS scans,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND schemaname = 'public'
  AND indexrelname NOT LIKE 'idx_%_gin'
ORDER BY pg_relation_size(indexrelid) DESC;
```

**Slide 125: VACUUM and ANALYZE** 
```sql
-- Update statistics (improves query plans)
ANALYZE orders;

-- Reclaim storage
VACUUM orders;

-- Combined
VACUUM ANALYZE orders;

-- Full vacuum (locks table)
VACUUM FULL orders;

-- Rebuild indexes
REINDEX INDEX idx_orders_date;
```
**When**: After bulk changes, when performance degrades 

---

### Section 6.2: ACID Transactions
**Slides: 126-132**

**Slide 126: ACID Properties**
- **Atomicity**: All or nothing
- **Consistency**: Data remains valid
- **Isolation**: Transactions don't interfere
- **Durability**: Committed data survives failures

**Slide 127: Transaction Commands**
```sql
BEGIN;                    -- Start transaction
SAVEPOINT savepoint_name; -- Create savepoint
ROLLBACK TO SAVEPOINT savepoint_name; -- Partial rollback
COMMIT;                   -- Save changes
ROLLBACK;                 -- Discard all changes
```

**Slide 128: Checkout Transaction**
```sql
BEGIN;

-- Create order
INSERT INTO orders (user_id, shipping_address_id, total, status)
VALUES (user_uuid, address_uuid, 99.99, 'pending')
RETURNING id INTO order_id;

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (order_id, 1, 2, 49.99);

-- Update inventory
UPDATE products 
SET stock_quantity = stock_quantity - 2
WHERE id = 1 AND stock_quantity >= 2;

-- If everything worked
COMMIT;

-- If something went wrong
ROLLBACK;
```

**Slide 129: Row-Level Locking** 
```sql
BEGIN;
-- Lock rows to prevent concurrent modifications
SELECT * FROM inventory 
WHERE product_id = 1 
FOR UPDATE;

-- Check availability
IF available >= requested THEN
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + requested
    WHERE product_id = 1;
    COMMIT;
ELSE
    ROLLBACK;
    RAISE EXCEPTION 'Insufficient stock';
END IF;
```
**FOR UPDATE**: Prevents other transactions from modifying locked rows

**Slide 130: Inventory Reservation Function**
```sql
CREATE OR REPLACE FUNCTION reserve_inventory(
    p_product_id INTEGER,
    p_quantity INTEGER,
    p_order_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_available INTEGER;
BEGIN
    -- Lock the inventory row
    SELECT stock_quantity INTO v_available
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    IF v_available < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock';
    END IF;
    
    UPDATE inventory 
    SET reserved_quantity = reserved_quantity + p_quantity
    WHERE product_id = p_product_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

**Slide 131: Complete Checkout with Transaction** 
```sql
CREATE OR REPLACE FUNCTION checkout_order(
    p_user_id UUID,
    p_items JSONB
)
RETURNS UUID AS $$
DECLARE
    v_order_id UUID;
BEGIN
    BEGIN
        -- All operations in one transaction
        INSERT INTO orders (...) RETURNING id INTO v_order_id;
        
        -- For each item
        FOR item IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            PERFORM reserve_inventory(
                item->>'product_id'::int,
                item->>'quantity'::int,
                v_order_id
            );
            
            INSERT INTO order_items (...) VALUES (...);
        END LOOP;
        
        COMMIT;
        RETURN v_order_id;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;
```

**Slide 132: Transaction Best Practices**
- Keep transactions SHORT 
- Avoid user interaction inside transactions
- Use appropriate isolation levels
- Always handle errors with ROLLBACK
- Test concurrent scenarios

---

### Section 6.3: CI/CD with Neon Branches
**Slides: 133-140**

**Slide 133: Preview Deployments with Branches** 
```
Git Workflow:          Neon Workflow:
┌─────────────────┐   ┌─────────────────────────────────┐
│ feature/payments │   │ neonctl branches create         │
│   ↓              │   │   --name preview-123             │
│ Pull Request     │   │   --parent main                  │
│   ↓              │   │                                 │
│ Deploy Preview   │   │ Run migrations on preview branch│
│   ↓              │   │ Run tests                       │
│ Merge to main    │   │ Merge branch to main            │
└─────────────────┘   └─────────────────────────────────┘
```

**Slide 134: GitHub Actions with Neon** 
```yaml
name: Database CI/CD
on: pull_request

jobs:
  test-database:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Neon CLI
        run: npm install -g neonctl
      
      - name: Create Preview Branch
        run: |
          BRANCH_NAME="preview-${{ github.event.pull_request.number }}"
          neonctl branches create \
            --name $BRANCH_NAME \
            --parent main \
            --project-id ${{ secrets.PROJECT_ID }}
          echo "BRANCH_NAME=$BRANCH_NAME" >> $GITHUB_ENV
```

**Slide 135: Running Migrations on Branch** 
```yaml
      - name: Run Migrations on Preview
        run: |
          CONN_STRING=$(neonctl branches get-connection-string $BRANCH_NAME)
          psql "$CONN_STRING" -f migrations/001_create_users_table.sql
          psql "$CONN_STRING" -f migrations/002_create_ecommerce_tables.sql
      
      - name: Run Tests
        run: |
          export DATABASE_URL=$(neonctl branches get-connection-string $BRANCH_NAME)
          npm test
```

**Slide 136: Merging to Production** 
```yaml
      - name: Merge to Production
        if: github.event.pull_request.merged == true
        run: |
          # Merge the preview branch to main
          neonctl branches merge $BRANCH_NAME \
            --target main \
            --project-id ${{ secrets.PROJECT_ID }}
          
          # Clean up
          neonctl branches delete $BRANCH_NAME \
            --project-id ${{ secrets.PROJECT_ID }}
```

**Slide 137: Migration Specialist Agent** 
```
1. Create test branch with 4-hour TTL
2. Run migrations on test branch
3. Validate changes thoroughly
4. Delete test branch
5. Create migration files and open PR
6. User or CI/CD applies to main
```
**CRITICAL**: NEVER run migrations directly on main 

**Slide 138: Schema Diff** 
- GitHub-style comparison tool 
- Visualize differences between branches
- Green = Additions, Red = Removals
- Available in Neon Console → Branches → Schema Diff
- Perfect for code review of database changes

**Slide 139: Branch Reset Workflow** 
```bash
# Reset development branch to production state
neonctl branches reset development --target main --project-id your-project-id

# When to reset:
# ✅ After feature completed and merged
# ✅ To abandon experimental changes
# ✅ In CI/CD automation
```
**Like**: `git reset --hard origin/main` for databases

**Slide 140: Complete CI/CD Pipeline**
```
1. Developer opens PR
2. Neon creates preview branch
3. Migrations run on preview branch
4. Automated tests run
5. Schema Diff available for review
6. PR approved and merged
7. Preview branch merged to main
8. Preview branch deleted
9. Production deployed
```

---

### Section 6.4: Production Monitoring
**Slides: 141-146**

**Slide 141: Key Metrics to Monitor** 
```sql
-- Daily health check
SELECT 
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
    (SELECT pg_database_size(current_database()) / 1024 / 1024) AS database_size_mb,
    (SELECT 
        ROUND((sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100), 2)
     FROM pg_statio_user_tables) AS cache_hit_ratio;
```

**Slide 142: Query Performance Monitoring** 
```sql
-- Top slow queries
SELECT 
    queryid,
    query,
    calls,
    mean_exec_time,
    total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Active queries
SELECT 
    pid,
    usename,
    query,
    state,
    NOW() - query_start AS duration
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY duration DESC;
```

**Slide 143: Alerting Conditions** 
```yaml
Alerts to Configure:
- Active connections > 80% of max
- Cache hit ratio < 95%
- Slow queries > 5 seconds
- Long-running transactions > 5 minutes
- Database size > 80% capacity
- Table bloat > 30%
```

**Slide 144: Health Check View**
```sql
CREATE VIEW database_health_check AS
SELECT 
    CURRENT_TIMESTAMP AS checked_at,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
    (SELECT COUNT(*) FROM orders WHERE status = 'pending' AND order_date < CURRENT_DATE - INTERVAL '1 hour') AS stuck_orders,
    (SELECT COUNT(*) FROM products WHERE stock_quantity < 10) AS low_stock_items,
    pg_size_pretty(pg_database_size(current_database())) AS database_size;
```

**Slide 145: Slow Query Logging** 
```sql
CREATE TABLE slow_query_log (
    id BIGSERIAL PRIMARY KEY,
    pid INTEGER,
    username TEXT,
    query_text TEXT,
    duration_seconds INTEGER,
    logged_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Log queries > 5 seconds
-- Schedule with cron: * * * * * SELECT log_slow_queries();
```

**Slide 146: Performance Triage Checklist** 
```
1. Check EXPLAIN ANALYZE for the slow query 
2. Look for sequential scans on large tables
3. Check pg_stat_user_indexes for unused indexes 
4. Check autovacuum status on large tables
5. Review connection pooling configuration 
6. Check for long-running transactions (blocking locks) 
7. Review logs (log_min_duration_statement) 
8. Check for application N+1 query patterns 
```

---

## APPENDICES OVERVIEW
**Slide 147: Appendix A - SQL Reference & Cheat Sheet**
- All SQL commands covered
- Data types reference
- DDL/DML/DCL commands
- Quick lookup tables

**Slide 148: Appendix B - Sample Data Generation**
- Complete seed scripts
- Realistic e-commerce data
- Reusable seed functions
- Data validation queries

**Slide 149: Appendix C - Deployment & Operations**
- Production deployment checklist
- Monitoring configuration
- Backup and recovery procedures
- Kubernetes/container deployment

**Slide 150: Appendix D - SQL Query Patterns & Recipes**
- User management patterns
- Product catalog patterns
- Order management patterns
- Reporting and analytics patterns

---

## PRIMERS OVERVIEW
**Slide 151: Primer 1 - PostgreSQL Fundamentals**
- Database concepts
- Data types
- CRUD operations
- Basic queries

**Slide 152: Primer 2 - Database Design & Normalization**
- Normalization (1NF, 2NF, 3NF) 
- Relationship types
- Schema design principles
- Anti-patterns

**Slide 153: Primer 3 - Working with Neon**
- Neon architecture
- Connection types
- Branching features 
- CLI and console tour

**Slide 154: Primer 4 - SQL Optimization & Performance**
- EXPLAIN ANALYZE 
- Index types 
- Query optimization 
- Monitoring

**Slide 155: Primer 5 - Security Best Practices**
- Authentication & authorization
- SQL injection prevention
- Connection security
- Audit logging

---

## CONCLUSION
**Slide 156: Course Recap**
- ✅ Serverless PostgreSQL with Neon
- ✅ Complete e-commerce backend
- ✅ SQL fundamentals to production
- ✅ Database branching workflows
- ✅ Performance optimization
- ✅ CI/CD integration

**Slide 157: What's Next?**
- Build your frontend (React, Next.js)
- Add authentication (Neon Auth) 
- Implement caching (Redis)
- Add payments (Stripe)
- Deploy with confidence!

**Slide 158: Resources**
- Neon Documentation: neon.tech/docs
- Course GitHub Repository
- Community: Discord, GitHub Discussions
- Further Learning: Blog, Webinars

---

**[END OF SLIDE DECK OUTLINE]**
