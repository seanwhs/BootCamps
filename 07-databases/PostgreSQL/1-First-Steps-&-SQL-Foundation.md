# Part 1: First Steps & The SQL Foundation

Welcome to your first hands-on session! We're going to install PostgreSQL, create our e-commerce database, and build our first table: `products`. By the end of this part, you'll be writing `SELECT`, `INSERT`, `UPDATE`, and `DELETE` queries like a pro.

## Phase 1.1: Installing PostgreSQL

### The Target
Install PostgreSQL on your operating system and verify it's working correctly.

### The Concept
Think of PostgreSQL as a specialized application that manages your data. Like any application, it needs to be installed properly before you can use it. We'll install it, start the service, and confirm we can connect.

### The Implementation

#### For macOS Users

**Option 1: Using Homebrew (Recommended)**
```bash
# Update Homebrew
brew update

# Install PostgreSQL
brew install postgresql@16

# Start the PostgreSQL service
brew services start postgresql@16

# Verify the installation
postgres --version
# Should output something like: postgres (PostgreSQL) 16.2
```

**Option 2: Using the Official Installer**
1. Download from https://www.postgresql.org/download/macosx/
2. Run the installer and follow the prompts
3. Remember the password you set for the `postgres` user

#### For Ubuntu/Debian Users

```bash
# Update package index
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start the service
sudo systemctl start postgresql

# Enable auto-start on boot
sudo systemctl enable postgresql

# Verify installation
psql --version
# Should output: psql (PostgreSQL) 14.x or higher
```

#### For Windows Users

1. Download the installer from https://www.postgresql.org/download/windows/
2. Run the installer
3. Choose these settings:
   - Installation directory: `C:\Program Files\PostgreSQL\16`
   - Data directory: `C:\Program Files\PostgreSQL\16\data`
   - Port: `5432`
   - **IMPORTANT**: Set and remember the password for the `postgres` superuser
4. Complete the installation
5. Open Command Prompt or PowerShell and run:
```cmd
psql --version
```

### The Verification

After installation, verify PostgreSQL is running:

```bash
# Check if PostgreSQL is listening on port 5432
sudo netstat -anp | grep 5432
# or on Windows:
# netstat -an | findstr 5432

# Check the service status
# macOS with Homebrew:
brew services list | grep postgresql

# Linux:
sudo systemctl status postgresql

# Windows:
# Open Services (services.msc) and look for PostgreSQL
```

**Troubleshooting Tip**: If PostgreSQL isn't running, try these commands:
- macOS: `brew services start postgresql@16`
- Linux: `sudo systemctl start postgresql`
- Windows: Restart the service from Services panel

---

## Phase 1.2: Connecting to PostgreSQL

### The Target
Connect to PostgreSQL using the `psql` command-line client and create our e-commerce database.

### The Concept
`psql` is like a direct phone line to your database. You can send SQL commands and see results immediately. We'll connect as the system administrator (`postgres`), create our database, and then connect to our new database.

### The Implementation

#### Step 1: Connect as the Postgres User

```bash
# Connect to the default postgres database
sudo -u postgres psql
# On macOS with Homebrew:
# psql postgres
# On Windows:
# Run as Administrator: psql -U postgres

# You'll see a prompt like:
# postgres=#
```

#### Step 2: Create Our Database

```sql
-- At the postgres=# prompt, create our e-commerce database
CREATE DATABASE ecommerce;

-- Verify it was created
\l
-- Should show 'ecommerce' in the list of databases
```

#### Step 3: Connect to Our Database

```sql
-- Connect to the ecommerce database
\c ecommerce

-- Your prompt should change to:
-- ecommerce=#
```

#### Step 4: Create a Dedicated User (Optional but Recommended)

```sql
-- Create a user for our application
CREATE USER ecommerce_user WITH PASSWORD 'secure_password_123';

-- Grant all privileges on the ecommerce database to this user
GRANT ALL PRIVILEGES ON DATABASE ecommerce TO ecommerce_user;

-- Exit psql
\q

-- Now connect as our new user
psql -d ecommerce -U ecommerce_user -h localhost
# Enter the password when prompted
```

### The Verification

Run these commands to confirm everything works:

```bash
# Show current connection info
psql -d ecommerce -c "\conninfo"
# Should show: "You are connected to database 'ecommerce'..."

# List all tables (should be empty initially)
psql -d ecommerce -c "\dt"
# Should show: "Did not find any relations."

# Show current user
psql -d ecommerce -c "SELECT current_user;"
# Should show: ecommerce_user
```

**Save this connection string** for future use:
```
postgresql://ecommerce_user:secure_password_123@localhost:5432/ecommerce
```

---

## Phase 1.3: Creating Our First Table

### The Target
Create the `products` table with appropriate columns and data types.

### The Concept
A table is like a spreadsheet with specific columns. Each column has a type (like `TEXT`, `INTEGER`, `NUMERIC`) that enforces what kind of data can go in it. We'll create a `products` table to store our product catalog.

### The Implementation

Connect to your database and run:

```sql
-- Switch to the ecommerce database if not already connected
\c ecommerce

-- Drop the table if it exists (for clean re-runs)
DROP TABLE IF EXISTS products CASCADE;

-- Create the products table
CREATE TABLE products (
    -- SERIAL auto-increments: like a page number that increases automatically
    -- This is our primary key - uniquely identifies each product
    id SERIAL PRIMARY KEY,
    
    -- TEXT is like VARCHAR but without length limits
    -- Good for product names that might be long
    name TEXT NOT NULL,
    
    -- VARCHAR(255) limits to 255 characters
    -- Good for slugs - URL-friendly versions of names
    slug VARCHAR(255) UNIQUE NOT NULL,
    
    -- TEXT for long descriptions
    description TEXT,
    
    -- NUMERIC(10,2) means 10 total digits, 2 after decimal
    -- Perfect for prices - no floating-point errors
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    
    -- INTEGER for whole numbers
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    
    -- BOOLEAN for true/false values
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- TIMESTAMP WITH TIME ZONE automatically handles timezones
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add an index on slug for faster lookups
CREATE INDEX idx_products_slug ON products(slug);

-- Add an index on is_active for filtering active products
CREATE INDEX idx_products_is_active ON products(is_active);

-- Verify the table structure
\d products
```

### The Verification

```bash
# Check that the table exists
psql -d ecommerce -c "\dt"

# Check the table structure
psql -d ecommerce -c "\d products"

# Check that indexes were created
psql -d ecommerce -c "\di"
```

**Expected Output**:
```
                                     Table "public.products"
     Column     |           Type           | Collation | Nullable |           Default            
----------------+--------------------------+-----------+----------+------------------------------
 id             | integer                  |           | not null | nextval('products_id_seq'::regclass)
 name           | text                     |           | not null | 
 slug           | character varying(255)   |           | not null | 
 description    | text                     |           |          | 
 price          | numeric(10,2)            |           | not null | 
 stock_quantity | integer                  |           | not null | 0
 is_active      | boolean                  |           | not null | true
 created_at     | timestamp with time zone |           | not null | now()
 updated_at     | timestamp with time zone |           | not null | now()
Indexes:
    "products_pkey" PRIMARY KEY, btree (id)
    "products_slug_key" UNIQUE CONSTRAINT, btree (slug)
    "idx_products_is_active" btree (is_active)
    "idx_products_slug" btree (slug)
Check constraints:
    "products_price_check" CHECK (price >= 0)
    "products_stock_quantity_check" CHECK (stock_quantity >= 0)
```

---

## Phase 1.4: CRUD - INSERT (Adding Products)

### The Target
Insert product data into our `products` table using `INSERT` statements.

### The Concept
`INSERT` is like adding a new row to a spreadsheet. We specify the column names and the values we want to put in each column. PostgreSQL handles the `id` auto-increment and `created_at` timestamps automatically.

### The Implementation

```sql
-- Connect to the ecommerce database
\c ecommerce

-- Insert a single product
INSERT INTO products (
    name, 
    slug, 
    description, 
    price, 
    stock_quantity, 
    is_active
) VALUES (
    'Wireless Bluetooth Headphones',
    'wireless-bluetooth-headphones',
    'High-quality wireless headphones with noise cancellation and 20-hour battery life.',
    79.99,
    100,
    true
);

-- Insert multiple products in one statement
INSERT INTO products (name, slug, description, price, stock_quantity, is_active) VALUES
    ('USB-C Charging Cable', 'usb-c-charging-cable', 'Durable 2-meter USB-C to USB-C charging cable.', 12.99, 500, true),
    ('Stainless Steel Water Bottle', 'stainless-steel-water-bottle', 'Vacuum insulated, 32oz, keeps drinks cold for 24 hours.', 24.95, 200, true),
    ('Laptop Stand', 'laptop-stand', 'Adjustable aluminum laptop stand, ergonomic design.', 39.99, 150, true),
    ('Wireless Mouse', 'wireless-mouse', 'Ergonomic wireless mouse with USB receiver.', 29.99, 75, true),
    ('Mechanical Keyboard', 'mechanical-keyboard', 'RGB mechanical keyboard with blue switches.', 89.99, 0, false),
    ('Webcam 1080p', 'webcam-1080p', 'Full HD 1080p webcam with built-in microphone.', 49.99, 30, true),
    ('Microfiber Cleaning Cloth', 'microfiber-cleaning-cloth', 'Pack of 3, lint-free microfiber cloths.', 8.99, 1000, true),
    ('External Hard Drive 1TB', 'external-hard-drive-1tb', 'Portable 1TB external hard drive, USB 3.0.', 59.99, 45, true);

-- Insert a product with default values (stock_quantity defaults to 0)
INSERT INTO products (name, slug, description, price) VALUES (
    'Premium Laptop Bag',
    'premium-laptop-bag',
    'Water-resistant laptop bag with padded compartment.',
    34.99
);

-- Verify the inserts
SELECT COUNT(*) FROM products;
-- Should return 10

-- View all products
SELECT * FROM products;
```

### The Verification

```bash
# Count the number of products
psql -d ecommerce -c "SELECT COUNT(*) FROM products;"

# View all products with specific columns
psql -d ecommerce -c "SELECT id, name, price, stock_quantity, is_active FROM products;"

# View a nicely formatted version
psql -d ecommerce -x -c "SELECT * FROM products LIMIT 3;"
```

**Troubleshooting**: If you get a duplicate key error on `slug`, you've already inserted that product. Use `DELETE FROM products;` to clear the table and try again, or skip the duplicate entry.

---

## Phase 1.5: CRUD - SELECT (Querying Products)

### The Target
Query products using `SELECT` with various filtering and sorting options.

### The Concept
`SELECT` is your primary tool for retrieving data. Think of it as asking your database questions. We'll use `WHERE` to filter, `ORDER BY` to sort, and various operators to find exactly what we need.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Basic SELECT: Get all products
SELECT * FROM products;

-- Select specific columns (better practice)
SELECT id, name, price, stock_quantity FROM products;

-- WHERE clause: Filter products
-- Get active products only
SELECT * FROM products WHERE is_active = true;

-- Get products with stock greater than 0
SELECT * FROM products WHERE stock_quantity > 0;

-- Get products with price between $20 and $50 (BETWEEN)
SELECT * FROM products WHERE price BETWEEN 20.00 AND 50.00;

-- Get products with price > $50 (comparison)
SELECT * FROM products WHERE price > 50.00;

-- String matching with LIKE (case-sensitive pattern matching)
-- Get products with 'wireless' in the name
SELECT * FROM products WHERE name LIKE '%Wireless%';

-- Get products starting with 'L'
SELECT * FROM products WHERE name LIKE 'L%';

-- Case-insensitive pattern matching with ILIKE
SELECT * FROM products WHERE name ILIKE '%usb%';

-- IN operator: Multiple possible values
SELECT * FROM products WHERE price IN (12.99, 24.95, 89.99);

-- OR operator
SELECT * FROM products 
WHERE stock_quantity = 0 
   OR price > 50.00;

-- AND operator
SELECT * FROM products 
WHERE is_active = true 
  AND stock_quantity > 0 
  AND price BETWEEN 20.00 AND 60.00;

-- ORDER BY: Sorting results
-- Sort by price (lowest to highest)
SELECT * FROM products ORDER BY price ASC;

-- Sort by price (highest to lowest)
SELECT * FROM products ORDER BY price DESC;

-- Sort by multiple columns
SELECT * FROM products 
ORDER BY is_active DESC, price ASC;

-- LIMIT: Get only the first N rows
-- Get the 3 most expensive products
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 3;

-- OFFSET: Skip N rows (for pagination)
-- Get products 4-6 in price order
SELECT * FROM products 
ORDER BY price 
LIMIT 3 OFFSET 3;

-- Combining everything
-- Get active products, in stock, sorted by price, limit to 5
SELECT id, name, price, stock_quantity 
FROM products 
WHERE is_active = true 
  AND stock_quantity > 0 
ORDER BY price DESC 
LIMIT 5;

-- NULL checking
-- Get products with no description (NULL)
SELECT * FROM products WHERE description IS NULL;

-- Get products with a description (NOT NULL)
SELECT * FROM products WHERE description IS NOT NULL;

-- DISTINCT: Get unique values
SELECT DISTINCT is_active FROM products;

-- Aliases: Rename columns in results
SELECT 
    name AS "Product Name",
    price AS "Price ($)",
    stock_quantity AS "Stock Count"
FROM products;
```

### The Verification

```bash
# Count active products
psql -d ecommerce -c "SELECT COUNT(*) FROM products WHERE is_active = true;"

# Show the 5 most expensive products
psql -d ecommerce -c "SELECT name, price FROM products ORDER BY price DESC LIMIT 5;"

# Show products with no stock
psql -d ecommerce -c "SELECT name, stock_quantity FROM products WHERE stock_quantity = 0;"

# All these queries should return results without errors
```

---

## Phase 1.6: CRUD - UPDATE (Modifying Products)

### The Target
Update existing product data using `UPDATE` statements.

### The Concept
`UPDATE` is like editing cells in a spreadsheet. You specify which rows to update using a `WHERE` clause, and you provide new values for the columns you want to change. Always use `WHERE` to avoid updating every row!

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- WARNING: Always use WHERE with UPDATE!
-- This would update ALL rows (DON'T RUN):
-- UPDATE products SET price = 0;

-- Update a specific product by ID
UPDATE products 
SET price = 84.99, 
    updated_at = NOW()
WHERE id = 1;

-- Update using a unique identifier (slug)
UPDATE products 
SET stock_quantity = 250,
    updated_at = NOW()
WHERE slug = 'usb-c-charging-cable';

-- Update multiple columns at once
UPDATE products 
SET description = 'Premium vacuum insulated stainless steel water bottle, 32oz, keeps drinks cold for 24 hours.',
    price = 26.95,
    updated_at = NOW()
WHERE slug = 'stainless-steel-water-bottle';

-- Bulk update: Increase all prices by 10%
-- WARNING: Be careful with arithmetic!
UPDATE products 
SET price = price * 1.10,
    updated_at = NOW()
WHERE is_active = true AND stock_quantity > 0;

-- Conditional update with CASE
-- Apply different price adjustments based on current price
UPDATE products 
SET price = CASE 
                WHEN price < 20 THEN price * 1.15  -- 15% increase for cheap items
                WHEN price < 50 THEN price * 1.10  -- 10% increase for mid-range
                ELSE price * 1.05                  -- 5% increase for expensive items
            END,
    updated_at = NOW()
WHERE is_active = true;

-- Update with subquery
-- Set the updated_at timestamp
UPDATE products 
SET updated_at = NOW()
WHERE created_at IS NOT NULL;

-- Restore a product to active status
UPDATE products 
SET is_active = true,
    updated_at = NOW()
WHERE id = 6;  -- The mechanical keyboard

-- Verify the updates
SELECT id, name, price, stock_quantity, is_active, updated_at 
FROM products 
WHERE id IN (1, 2, 3, 6);
```

### The Verification

```bash
# Check that specific product was updated
psql -d ecommerce -c "SELECT id, name, price FROM products WHERE id = 1;"

# Check the bulk price update
psql -d ecommerce -c "SELECT name, price FROM products ORDER BY price;"

# Verify the keyboard was reactivated
psql -d ecommerce -c "SELECT id, name, is_active FROM products WHERE id = 6;"
```

---

## Phase 1.7: CRUD - DELETE (Removing Products)

### The Target
Delete products using `DELETE` statements.

### The Concept
`DELETE` removes entire rows from your table. It's like tearing a page out of a notebook. Always use a `WHERE` clause unless you want to delete every row! In production, we often use a "soft delete" (setting `is_active = false`) instead of actual deletion.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- WARNING: DELETE without WHERE removes ALL rows!
-- DELETE FROM products;  -- DON'T RUN THIS!

-- Delete a specific product by ID
DELETE FROM products WHERE id = 9;  -- Premium Laptop Bag (id may vary)

-- Delete using a unique identifier
DELETE FROM products WHERE slug = 'microfiber-cleaning-cloth';

-- Delete products that are inactive and have no stock
DELETE FROM products 
WHERE is_active = false AND stock_quantity = 0;

-- Delete products with very low stock and inactive status
DELETE FROM products 
WHERE stock_quantity = 0 
  AND is_active = false 
  AND id NOT IN (1, 2, 3, 4, 5);  -- Keep some products

-- Verify the deletions
SELECT COUNT(*) FROM products;
-- Check what remains
SELECT id, name, is_active, stock_quantity FROM products ORDER BY id;

-- Return deleted data (useful for logging)
DELETE FROM products 
WHERE id = 8 
RETURNING *;
```

### The Verification

```bash
# Count remaining products
psql -d ecommerce -c "SELECT COUNT(*) FROM products;"

# Show all remaining products
psql -d ecommerce -c "SELECT id, name, is_active, stock_quantity FROM products ORDER BY id;"

# Check that deleted products are gone
psql -d ecommerce -c "SELECT * FROM products WHERE slug = 'microfiber-cleaning-cloth';"
# Should return 0 rows
```

---

## Phase 1.8: Building a Search Query

### The Target
Build a complex search query that combines multiple filters and sorting.

### The Concept
In an e-commerce application, users need to search and filter products. We'll build a query that mimics a real product search page: filtering by price range, availability, and name search, with sorting options.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- First, make sure we have a good mix of test data
-- Insert some additional varied products
INSERT INTO products (name, slug, description, price, stock_quantity, is_active) VALUES
    ('Smart Watch Pro', 'smart-watch-pro', 'Premium smart watch with health tracking', 299.99, 20, true),
    ('Smart Watch Lite', 'smart-watch-lite', 'Budget smart watch with basic features', 149.99, 50, true),
    ('Bluetooth Speaker X3', 'bluetooth-speaker-x3', 'Portable waterproof speaker', 79.99, 35, true),
    ('Bluetooth Speaker Mini', 'bluetooth-speaker-mini', 'Ultra-compact speaker', 39.99, 60, true),
    ('Wireless Earbuds', 'wireless-earbuds', 'True wireless earbuds with charging case', 89.99, 0, false),
    ('Gaming Headset', 'gaming-headset', 'RGB gaming headset with surround sound', 59.99, 15, true);

-- Build a search query for "bluetooth" products under $100 that are in stock
SELECT 
    id,
    name,
    description,
    price,
    stock_quantity,
    is_active
FROM products
WHERE 
    -- Full-text search in name and description (for "bluetooth")
    (name ILIKE '%bluetooth%' OR description ILIKE '%bluetooth%')
    -- Price filter
    AND price <= 100.00
    -- Stock filter
    AND stock_quantity > 0
    -- Active filter
    AND is_active = true
-- Sort by price ascending
ORDER BY price ASC;

-- Search for products between $50-$100, sorted by newest first
SELECT 
    id,
    name,
    price,
    stock_quantity,
    created_at
FROM products
WHERE 
    price BETWEEN 50.00 AND 100.00
    AND is_active = true
ORDER BY created_at DESC;

-- Advanced search: Combine multiple filters dynamically
-- This simulates a search with: query="wireless", price range=$20-$80, in stock, sort by price
SELECT 
    id,
    name,
    price,
    stock_quantity,
    CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN stock_quantity < 10 THEN 'Low Stock'
        WHEN stock_quantity < 50 THEN 'In Stock'
        ELSE 'Plentiful Stock'
    END AS stock_status,
    is_active
FROM products
WHERE 
    (name ILIKE '%wireless%' OR description ILIKE '%wireless%')
    AND price BETWEEN 20.00 AND 80.00
    AND stock_quantity > 0
    AND is_active = true
ORDER BY 
    price ASC,
    stock_quantity DESC;

-- Count results by price range
SELECT 
    CASE 
        WHEN price < 20 THEN 'Budget (<$20)'
        WHEN price < 50 THEN 'Economy ($20-$50)'
        WHEN price < 100 THEN 'Mid-Range ($50-$100)'
        WHEN price < 200 THEN 'Premium ($100-$200)'
        ELSE 'Luxury (>$200)'
    END AS price_tier,
    COUNT(*) AS product_count,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price)::NUMERIC(10,2) AS avg_price
FROM products
WHERE is_active = true
GROUP BY price_tier
ORDER BY MIN(price);
```

### The Verification

```bash
# Test the search query - replace "bluetooth" with your search term
psql -d ecommerce -c "
SELECT id, name, price, stock_quantity 
FROM products 
WHERE name ILIKE '%bluetooth%' 
AND is_active = true 
ORDER BY price;"

# Check price tier distribution
psql -d ecommerce -c "
SELECT 
    CASE 
        WHEN price < 20 THEN 'Budget'
        WHEN price < 50 THEN 'Economy'
        ELSE 'Premium'
    END AS tier,
    COUNT(*),
    AVG(price)::NUMERIC(10,2) AS avg_price
FROM products
WHERE is_active = true
GROUP BY tier;"
```

---

## Phase 1.9: Exporting Your Data

### The Target
Export your product data to CSV for backup or analysis.

### The Concept
Sometimes you need to share data or move it to another system. PostgreSQL can export query results directly to files. We'll export our products to CSV format.

### The Implementation

```bash
# Export all products to CSV
psql -d ecommerce -U ecommerce_user -c "\COPY products TO 'products_export.csv' WITH CSV HEADER;"

# Export only active products with price > 50
psql -d ecommerce -U ecommerce_user -c "\COPY (SELECT * FROM products WHERE is_active = true AND price > 50) TO 'active_expensive_products.csv' WITH CSV HEADER;"

# Export specific columns
psql -d ecommerce -U ecommerce_user -c "\COPY (SELECT id, name, price, stock_quantity FROM products ORDER BY price DESC) TO 'products_prices.csv' WITH CSV HEADER;"

# Import products back from CSV (useful for restoring data)
-- First, make sure the CSV file exists with correct structure
-- psql -d ecommerce -c "\COPY products (name, slug, description, price, stock_quantity, is_active) FROM 'products_import.csv' WITH CSV HEADER;"
```

### The Verification

```bash
# Check that the CSV file was created
ls -la *.csv
# On Windows: dir *.csv

# View the first few lines of the CSV
head -5 products_export.csv
# On Windows: type products_export.csv | findstr /n ".*" | findstr "^[1-5]"

# Count lines in CSV (header + data rows)
wc -l products_export.csv
```

---

## Phase 1.10: Setting Up a Development Workflow

### The Target
Create a reusable SQL script file for your product operations.

### The Concept
Instead of typing SQL commands interactively, you can save them in `.sql` files and run them later. This is how professional developers manage database schemas—it's reproducible and version-controllable.

### The Implementation

Create a file called `01_products_setup.sql`:

```sql
-- 01_products_setup.sql
-- Complete setup script for the products table

-- Drop everything and start fresh
DROP TABLE IF EXISTS products CASCADE;

-- Create the table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_products_slug ON products(slug);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_price ON products(price);

-- Insert initial sample data
INSERT INTO products (name, slug, description, price, stock_quantity, is_active) VALUES
    ('Wireless Bluetooth Headphones', 'wireless-bluetooth-headphones', 'High-quality wireless headphones with noise cancellation.', 79.99, 100, true),
    ('USB-C Charging Cable', 'usb-c-charging-cable', 'Durable 2-meter USB-C to USB-C charging cable.', 12.99, 500, true),
    ('Stainless Steel Water Bottle', 'stainless-steel-water-bottle', 'Vacuum insulated, 32oz water bottle.', 24.95, 200, true),
    ('Laptop Stand', 'laptop-stand', 'Adjustable aluminum laptop stand.', 39.99, 150, true),
    ('Wireless Mouse', 'wireless-mouse', 'Ergonomic wireless mouse.', 29.99, 75, true);

-- Example query to verify data
SELECT 'Products Setup Complete!' AS status;
SELECT COUNT(*) AS total_products FROM products;
```

Run the script:

```bash
# Execute the SQL script
psql -d ecommerce -U ecommerce_user -f 01_products_setup.sql

# Or with a single line
cat 01_products_setup.sql | psql -d ecommerce -U ecommerce_user

# On Windows, use type instead of cat
type 01_products_setup.sql | psql -d ecommerce -U ecommerce_user
```

### The Verification

```bash
# Verify the script ran successfully
psql -d ecommerce -c "SELECT COUNT(*) FROM products;"
psql -d ecommerce -c "\d products"
psql -d ecommerce -c "SELECT name, price FROM products ORDER BY price;"
```

---

## Summary: What You've Accomplished

Congratulations! You've completed Part 1 and built a solid foundation with PostgreSQL. Here's what you can now do:

✅ Install PostgreSQL on any platform  
✅ Connect to PostgreSQL using `psql`  
✅ Create databases and tables  
✅ Insert, query, update, and delete data  
✅ Filter results with `WHERE`, `LIKE`, `IN`, and `BETWEEN`  
✅ Sort results with `ORDER BY`  
✅ Export data to CSV  
✅ Create reusable SQL scripts  

## Next Steps

In **Part 2**, we'll dive deeper into data types and constraints. We'll build the `users` table with email validation, check constraints, and explore PostgreSQL-specific data types like `UUID`, `TIMESTAMPTZ`, and more.

**Before Part 2**, practice these skills:
1. Insert 5 new products of your choice
2. Query products priced between $15 and $30
3. Update the price of one product
4. Delete a product you inserted
5. Export your product list to CSV
