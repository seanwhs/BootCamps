# Serverless Postgres with Neon: From Zero to Production

## Part 1: Instant Setup & Cloud SQL Fundamentals

### The Target

In this first technical part, we'll:
1. Create a Neon account and provision our first serverless PostgreSQL database
2. Set up the Neon CLI tool for command-line management
3. Connect to our database using both `psql` and connection strings
4. Create our first table: `products`
5. Populate it with sample data
6. Write basic CRUD (Create, Read, Update, Delete) queries
7. Learn filtering and sorting with `WHERE`, `LIKE`, `ORDER BY`, and `LIMIT`

By the end of this part, you'll have a working Neon database with a `products` table containing real data that you can query and manipulate.

---

### The Concept: Databases as Digital Filing Cabinets

Think of a database as a massive, highly organized digital filing cabinet. Instead of paper folders, we have **tables** (like `products`). Each table has **columns** (like `name`, `price`, `description`) that define what information we store. Each individual item is a **row** (like a specific product: "Wireless Headphones, $99.99").

PostgreSQL is the "filing cabinet brand"—it's a specific type of database that's been battle-tested for decades. Neon is like having that filing cabinet stored in a cloud warehouse that's always accessible, automatically backed up, and scales to hold millions of files without you ever needing to buy more cabinets.

In this part, we'll learn the basic operations you perform on this digital filing cabinet:
- **CREATE**: Add new records (like filing a new document)
- **READ**: Retrieve records (like looking up a file)
- **UPDATE**: Modify records (like correcting information on a form)
- **DELETE**: Remove records (like shredding outdated documents)

---

### Implementation Step 1: Neon Account Setup

#### 1.1 Create Your Neon Account

1. Navigate to [neon.tech](https://neon.tech) in your browser
2. Click **"Sign Up"** in the top-right corner
3. Choose your preferred sign-up method:
   - GitHub (recommended for easy integration later)
   - Google
   - Email/password
4. Complete the verification process (you'll receive a confirmation email)

**Why This Matters**: Your Neon account is your gateway to serverless PostgreSQL. The free tier includes:
- 10 GB of storage
- 20 hours of compute time per month (more than enough for this series)
- Unlimited branches
- 5 active projects

#### 1.2 Create Your First Project

Once logged in:

1. Click **"Create a Project"** or **"New Project"**
2. Enter a project name: `ecommerce-backend`
3. Choose a region closest to you (this affects latency)
   - For US: choose `us-east-1` or `us-west-2`
   - For Europe: `eu-central-1`
   - For Asia: `ap-southeast-1`
4. Leave all other settings as default
5. Click **"Create Project"**

The provisioning process takes about 10-15 seconds. You'll see a success screen with your database connection details.

> **📝 IMPORTANT**: Save these connection details securely. The password will only be shown once!

#### 1.3 Save Your Connection String

You'll see a connection string that looks like this:

```bash
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require
```

Save this in a secure location. We'll break down what each part means:

- `postgresql://` - The protocol (PostgreSQL)
- `username:password` - Your authentication credentials
- `ep-xyz.us-east-1.aws.neon.tech` - The host endpoint
- `/database` - The database name (usually `neondb`)
- `?sslmode=require` - SSL requirement (always use this in production)

**The Verification**: At this point, you should see your Neon dashboard with your new project showing "Available" status. You've successfully provisioned your first serverless database!

---

### Implementation Step 2: Install Neon CLI (Optional but Recommended)

The Neon CLI lets you manage your database from the command line—perfect for automation and scripting.

#### 2.1 Install via npm (Node.js required)

```bash
npm install -g neonctl
```

#### 2.2 Authenticate the CLI

```bash
neonctl auth
```

This will open a browser window asking you to authorize the CLI. Once authorized, you'll see confirmation in your terminal.

#### 2.3 Verify Installation

```bash
neonctl --version
```

Should output something like: `1.21.0` or higher.

**The Verification**: The command runs without errors, and you can see your project by running:

```bash
neonctl projects list
```

You should see your `ecommerce-backend` project listed.

---

### Implementation Step 3: Connect to Your Database

You have two main ways to connect: using `psql` (the standard PostgreSQL command-line tool) or using a GUI client. We'll use `psql` since it's universally available and great for learning.

#### 3.1 Install psql (if not already installed)

**macOS**:
```bash
brew install postgresql@16
```

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install postgresql-client
```

**Windows**: Download from [PostgreSQL Downloads](https://www.postgresql.org/download/windows/)

#### 3.2 Connect Using psql

Open your terminal and run:

```bash
psql "postgresql://your-username:your-password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require"
```

Replace `your-username`, `your-password`, and the host with your actual connection details.

**Expected Output**:
```
psql (16.1)
SSL connection (protocol: TLSv1.3, cipher: ...)
Type "help" for help.

neondb=>
```

You're now connected to your Neon PostgreSQL instance! The prompt `neondb=>` indicates you're in the `neondb` database.

#### 3.3 Test Your Connection

Run this simple query to confirm everything works:

```sql
SELECT version();
```

You should see output showing your PostgreSQL version (likely 16.x).

#### 3.4 Exit psql

```sql
\q
```

**The Verification**: You were able to connect, run `SELECT version();`, and see the PostgreSQL version. Your connection is working!

---

### Implementation Step 4: Create the Products Table

Now we'll create our first table. We'll design a `products` table that an e-commerce store would use to track inventory.

#### 4.1 Connect to Your Database

Let's reconnect and stay connected for the rest of this part:

```bash
psql "postgresql://your-username:your-password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require"
```

#### 4.2 Create the Table

Run this SQL statement in your `psql` session:

```sql
-- Create the products table with appropriate data types and constraints
CREATE TABLE IF NOT EXISTS products (
    -- SERIAL: Auto-incrementing integer primary key
    -- Think of this as an automatic ID number assigned to each product
    id SERIAL PRIMARY KEY,
    
    -- VARCHAR(255): Variable-length string with max 255 characters
    -- This is the product's display name
    name VARCHAR(255) NOT NULL,
    
    -- TEXT: Unlimited-length string (good for product descriptions)
    description TEXT,
    
    -- NUMERIC(10,2): Exact decimal number with 10 total digits, 2 after decimal
    -- Perfect for prices to avoid floating-point rounding errors
    price NUMERIC(10,2) NOT NULL,
    
    -- INTEGER: Whole number for tracking quantity in stock
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    
    -- TIMESTAMP: Date and time with timezone
    -- Automatically set to current time when row is created
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- TIMESTAMP: Date and time with timezone
    -- Automatically updated when row is modified
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Output confirmation
SELECT 'Products table created successfully!' AS status;
```

**Understanding Each Data Type**:

- **SERIAL**: Auto-incrementing integer. Every new product gets the next number (1, 2, 3...)
- **VARCHAR(255)**: Short text up to 255 characters. Good for names, titles, emails
- **TEXT**: Unlimited text. Good for long descriptions, blog posts, comments
- **NUMERIC(10,2)**: Exact decimal with 10 total digits, 2 after decimal. Perfect for money
- **INTEGER**: Whole numbers. Good for counts, quantities, ages
- **TIMESTAMP WITH TIME ZONE**: Date + time + timezone. Good for "when did this happen"

**The Verification**: You should see:

```
CREATE TABLE
     status     
----------------
 Products table created successfully!
(1 row)
```

#### 4.3 Verify Table Structure

Run this to see the table schema:

```sql
\d products
```

You should see the table structure with all columns and their data types.

---

### Implementation Step 5: Insert Sample Products

Let's add some realistic e-commerce products to our table.

#### 5.1 Insert Multiple Products

```sql
-- Insert a batch of products into the products table
INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Wireless Bluetooth Headphones', 
     'Premium noise-cancelling headphones with 30-hour battery life and comfort-fit ear cushions', 
     99.99, 150),
    
    ('4K Action Camera', 
     'Waterproof action camera with 4K video recording, image stabilization, and dual-screen display', 
     249.99, 45),
    
    ('Smart Fitness Watch', 
     'GPS-enabled fitness tracker with heart rate monitor, sleep tracking, and smartphone notifications', 
     199.00, 78),
    
    ('USB-C Laptop Docking Station', 
     'Dual 4K monitor docking station with 100W power delivery, Ethernet, and USB-A ports', 
     149.50, 23),
    
    ('Mechanical Gaming Keyboard', 
     'RGB backlit mechanical keyboard with Cherry MX switches, programmable keys, and wrist rest', 
     129.99, 62),
    
    ('Wireless Charging Mouse', 
     'Ergonomic wireless mouse with customizable buttons, 1000Hz polling rate, and Qi charging', 
     79.95, 94),
    
    ('Portable Solar Power Bank', 
     '25,000mAh solar power bank with dual USB-C ports, fast charging, and LED flashlight', 
     89.99, 37),
    
    ('Studio Microphone Kit', 
     'Professional condenser microphone with shock mount, pop filter, and adjustable boom arm', 
     159.00, 18),
    
    ('Smart Home Display', 
     '7-inch smart display with voice control, video calling, and home automation hub', 
     229.99, 55),
    
    ('Noise Cancelling Earbuds', 
     'True wireless earbuds with active noise cancellation, 6-hour battery, and wireless charging case', 
     149.99, 120);
```

**The Verification**: You should see:

```
INSERT 0 10
```

This means 10 rows were inserted successfully.

#### 5.2 Check Our Data

Let's quickly view what we inserted:

```sql
SELECT id, name, price, stock_quantity FROM products;
```

You should see all 10 products listed with their IDs, names, prices, and stock quantities.

---

### Implementation Step 6: Basic CRUD Operations

Now we'll learn the four fundamental database operations: Create, Read, Update, Delete.

#### 6.1 CREATE: Insert a Single Product

```sql
-- Insert a single product
INSERT INTO products (name, description, price, stock_quantity) 
VALUES (
    'Bluetooth Speaker with Light Show', 
    'Portable Bluetooth speaker with RGB light show, 20W output, and waterproof design', 
    59.99, 87
);

-- Verify the insertion by finding the new product
SELECT * FROM products WHERE name LIKE '%Light Show%';
```

**The Verification**: You should see the new product with ID 11.

#### 6.2 READ: Retrieve Products

Let's practice retrieving data in various ways.

**Read all products with specific columns**:
```sql
-- Select only the columns we care about, limit to 5 rows
SELECT name, price, stock_quantity 
FROM products 
LIMIT 5;
```

**Read a single product by ID**:
```sql
-- Retrieve a specific product using its primary key
SELECT * FROM products WHERE id = 1;
```

**Read products with price filtering**:
```sql
-- Products between $100 and $200
SELECT name, price 
FROM products 
WHERE price BETWEEN 100 AND 200;
```

**Read with text pattern matching**:
```sql
-- Products that contain 'wireless' in name or description
SELECT id, name, price 
FROM products 
WHERE name ILIKE '%wireless%' 
   OR description ILIKE '%wireless%';
```

> **Note**: `ILIKE` is case-insensitive. `LIKE` is case-sensitive.

**The Verification**: Each query should return the expected products. You should see:
- First query: First 5 products
- Second query: Your first product (Headphones)
- Third query: Products in the $100-200 range
- Fourth query: All wireless-related products

#### 6.3 UPDATE: Modify Product Data

Let's update some products:

```sql
-- Increase the price of the fitness watch by 10%
UPDATE products 
SET price = price * 1.10, 
    updated_at = CURRENT_TIMESTAMP
WHERE name = 'Smart Fitness Watch';

-- Reduce stock for popular items (simulating sales)
UPDATE products 
SET stock_quantity = stock_quantity - 10
WHERE name IN ('Wireless Bluetooth Headphones', 'Noise Cancelling Earbuds');

-- Verify the updates
SELECT id, name, price, stock_quantity, updated_at 
FROM products 
WHERE id IN (3, 1, 10)
ORDER BY id;
```

**Why We Use `WHERE`**: Without `WHERE`, an UPDATE affects ALL rows. Always include a WHERE clause unless you mean to update everything (which is rarely what you want).

**The Verification**: You should see:
- Fitness watch price increased from $199.00 to $218.90
- Headphones stock reduced from 150 to 140
- Earbuds stock reduced from 120 to 110

#### 6.4 DELETE: Remove Products

```sql
-- Delete a single product by ID
DELETE FROM products 
WHERE id = 11;  -- The speaker with light show

-- Verify it's gone
SELECT * FROM products WHERE id = 11;

-- Count remaining products
SELECT COUNT(*) AS total_products FROM products;
```

**The Verification**: The count should be 10 (the original 10 products remain).

#### 6.5 Safe Deletion with Validation

Always double-check before deletion in production:

```sql
-- Best practice: Check what you're about to delete
SELECT * FROM products WHERE id = 11;  -- Should return empty

-- If it returns something, and you're sure, then delete
DELETE FROM products WHERE id = 11;
```

---

### Implementation Step 7: Advanced Filtering and Sorting

Now let's learn more sophisticated data retrieval.

#### 7.1 Filtering with WHERE

```sql
-- Products with stock less than 50 (low inventory alert)
SELECT id, name, stock_quantity 
FROM products 
WHERE stock_quantity < 50 
ORDER BY stock_quantity ASC;

-- Products priced above $150
SELECT name, price 
FROM products 
WHERE price > 150 
ORDER BY price DESC;

-- Products with specific stock ranges
SELECT name, stock_quantity 
FROM products 
WHERE stock_quantity BETWEEN 50 AND 100;

-- Products where description is not empty
SELECT id, name 
FROM products 
WHERE description IS NOT NULL;
```

**The Verification**: 
- Low inventory: Docking Station (23), Microphone Kit (18), Solar Power Bank (37)
- Above $150: Action Camera ($249.99), Smart Display ($229.99), Fitness Watch ($218.90)
- Stock 50-100: Gaming Keyboard (62), Earbuds (110, wait that's >100), Solar Power Bank (37)

#### 7.2 Pattern Matching with LIKE and ILIKE

```sql
-- Products starting with 'S' (case-sensitive)
SELECT name FROM products WHERE name LIKE 'S%';

-- Products containing 'pro' (case-insensitive) in description
SELECT id, name FROM products WHERE description ILIKE '%pro%';

-- Products ending with 's' (case-sensitive)
SELECT name FROM products WHERE name LIKE '%s';
```

**The Verification**: The patterns should return the expected products.

#### 7.3 Sorting with ORDER BY

```sql
-- Sort by price: cheapest first
SELECT name, price FROM products ORDER BY price ASC;

-- Sort by price: most expensive first
SELECT name, price FROM products ORDER BY price DESC;

-- Multiple sorting criteria: price first, then name
SELECT name, price, stock_quantity 
FROM products 
ORDER BY price DESC, name ASC;

-- Sort by stock level with NULLs last
SELECT id, name, stock_quantity 
FROM products 
ORDER BY stock_quantity ASC NULLS LAST;
```

#### 7.4 Limiting Results with LIMIT

```sql
-- Get the 3 cheapest products
SELECT name, price FROM products ORDER BY price ASC LIMIT 3;

-- Get the 3 most expensive products
SELECT name, price FROM products ORDER BY price DESC LIMIT 3;

-- Pagination: get products 4-6 (skip first 3, take next 3)
SELECT id, name, price 
FROM products 
ORDER BY id 
LIMIT 3 OFFSET 3;
```

**Why Pagination Matters**: When you have thousands of products, you never want to return all of them at once. Pagination allows you to fetch them in manageable chunks.

#### 7.5 Combined Example

```sql
-- Complex query: Find expensive products with low stock
SELECT id, name, price, stock_quantity
FROM products
WHERE price > 100           -- Only expensive products
  AND stock_quantity < 50   -- That are low on stock
ORDER BY price DESC         -- Show most expensive first
LIMIT 5;                    -- Show top 5
```

**The Verification**: This should return the Action Camera ($249.99, 45 stock) and the Microphone Kit ($159.00, 18 stock).

---

### Implementation Step 8: Dynamic Seed Data

Let's create a reusable script to populate our database with realistic data. This is useful for testing and development.

#### 8.1 Create a Seed File

Create a new file called `seed.sql` in your project directory:

```sql
-- seed.sql
-- This script populates the products table with realistic e-commerce data

-- First, clear existing data (careful in production!)
TRUNCATE TABLE products RESTART IDENTITY CASCADE;

-- Insert fresh sample products
INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Premium Wireless Headphones', 
     'Studio-quality sound with active noise cancellation, 40-hour battery life, and memory foam ear cushions', 
     149.99, 84),
    
    ('4K Action Camera Pro', 
     'Professional-grade action camera with 4K 60fps recording, HyperSmooth stabilization, and waterproof to 33ft', 
     349.99, 32),
    
    ('Smart Health Tracker', 
     'Advanced health monitoring with ECG, blood oxygen, sleep staging, and 7-day battery life', 
     249.00, 56),
    
    ('Universal Laptop Docking Station', 
     '8-in-1 docking station with dual 4K HDMI, 100W power delivery, USB-C, 3x USB-A, and Gigabit Ethernet', 
     169.50, 19),
    
    ('Mechanical Gaming Keyboard Pro', 
     'Wireless mechanical keyboard with hot-swappable switches, PBT keycaps, and 2000mAh battery', 
     159.99, 48),
    
    ('Ergonomic Wireless Mouse', 
     'Sculpted ergonomic mouse with programmable buttons, 16000 DPI sensor, and Qi wireless charging', 
     89.95, 107),
    
    ('Solar-Powered Power Bank', 
     '30000mAh solar power bank with 3 USB-C ports, wireless charging, and built-in flashlight', 
     99.99, 41),
    
    ('Professional Studio Microphone', 
     'Cardioid condenser microphone with shock mount, pop filter, adjustable stand, and XLR/USB connectivity', 
     199.00, 14),
    
    ('Smart Home Hub Display', 
     '10-inch smart display with home automation, video calls, photo frame, and voice assistant', 
     279.99, 63),
    
    ('Premium Noise Cancelling Earbuds', 
     'True wireless earbuds with adaptive ANC, transparency mode, 8-hour battery, and wireless charging', 
     179.99, 98),
    
    ('Ultra-HD Webcam', 
     '4K webcam with AI autofocus, HDR, dual microphones, and privacy cover for professional streaming', 
     129.99, 72),
    
    ('Portable External SSD', 
     '2TB portable SSD with 2000MB/s read/write speeds, USB 3.2 Gen 2, and rugged design', 
     219.99, 28),
    
    ('Smartphone Gimbal Stabilizer', 
     '3-axis smartphone gimbal with AI tracking, gesture control, and 15-hour battery life', 
     139.99, 53),
    
    ('Bluetooth 5.3 Transmitter', 
     'Dual-stream Bluetooth audio transmitter for TV, gaming, and headphones with low-latency codec support', 
     49.99, 133),
    
    ('RGB LED Strip Kit', 
     'Magnetic RGB LED strip with app control, music sync, and 16 million colors for ambient lighting', 
     39.99, 210);

-- Verify the insertion
SELECT COUNT(*) AS total_products FROM products;

-- Show sample of inserted data
SELECT id, name, price, stock_quantity 
FROM products 
ORDER BY id 
LIMIT 5;
```

#### 8.2 Run the Seed Script

Execute the seed file from your terminal:

```bash
psql "postgresql://your-username:your-password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require" -f seed.sql
```

**The Verification**: You should see:
```
TRUNCATE TABLE
INSERT 0 15
 total_products 
----------------
             15
(1 row)

 id |              name               | price  | stock_quantity 
----+---------------------------------+--------+----------------
  1 | Premium Wireless Headphones     | 149.99 |             84
  2 | 4K Action Camera Pro            | 349.99 |             32
  3 | Smart Health Tracker            | 249.00 |             56
  4 | Universal Laptop Docking Station | 169.50 |             19
  5 | Mechanical Gaming Keyboard Pro  | 159.99 |             48
(5 rows)
```

---

### Implementation Step 9: Practical Exercise - Building a Product Catalog Query

Let's combine everything we've learned into a practical example.

#### 9.1 The Product Catalog Query

Your e-commerce store needs to display products with the following requirements:
- Show only products in stock (stock_quantity > 0)
- Sort by price (most affordable first)
- Only show product name, price, and a shortened description
- Pagination: Show 5 products per page

```sql
-- Catalog query for page 1 (products 1-5)
SELECT 
    id,
    name,
    price,
    -- Truncate description to 100 characters with ellipsis
    CASE 
        WHEN LENGTH(description) > 100 
        THEN LEFT(description, 97) || '...' 
        ELSE description 
    END AS short_description,
    stock_quantity
FROM products
WHERE stock_quantity > 0      -- Only in-stock items
ORDER BY price ASC            -- Show cheapest first
LIMIT 5 OFFSET 0;             -- Page 1
```

#### 9.2 Multiple Sorting Options

Customers might want to sort by different criteria:

```sql
-- Sort by price: most expensive first
SELECT id, name, price, stock_quantity
FROM products
WHERE stock_quantity > 0
ORDER BY price DESC
LIMIT 5;

-- Sort by name alphabetically
SELECT id, name, price, stock_quantity
FROM products
WHERE stock_quantity > 0
ORDER BY name ASC
LIMIT 5;

-- Sort by stock quantity (most stock first)
SELECT id, name, price, stock_quantity
FROM products
WHERE stock_quantity > 0
ORDER BY stock_quantity DESC
LIMIT 5;
```

#### 9.3 Search with Multiple Filters

Implement a product search with multiple filters:

```sql
-- Search products with filters
SELECT id, name, price, stock_quantity
FROM products
WHERE stock_quantity > 0
  AND price BETWEEN 50 AND 200
  AND (name ILIKE '%wireless%' OR description ILIKE '%wireless%')
ORDER BY price ASC;
```

**The Verification**: This query should return products like wireless headphones, earbuds, and the wireless mouse.

---

### Deep Dive: Data Types

Let's explore PostgreSQL data types in more detail:

#### Character Types
- **VARCHAR(n)**: Variable length, max n characters. Good for names, emails.
- **CHAR(n)**: Fixed length, padded with spaces. Rarely used.
- **TEXT**: Unlimited length. Good for content, descriptions.

#### Numeric Types
- **SMALLINT**: -32768 to 32767. Good for ages, small counts.
- **INTEGER**: -2.1B to 2.1B. Good for most counts.
- **BIGINT**: -9.2e18 to 9.2e18. For very large numbers.
- **NUMERIC(p,s)**: Exact decimal with p total digits, s after decimal. Perfect for money.
- **REAL**: Approximate float (4 bytes). Good for scientific calculations.
- **DOUBLE PRECISION**: Approximate float (8 bytes). More precision than REAL.

#### Date/Time Types
- **DATE**: Just the date (no time).
- **TIME**: Just the time (no date).
- **TIMESTAMP**: Date and time (no timezone).
- **TIMESTAMPTZ**: Date and time WITH timezone. Always use this for application data.
- **INTERVAL**: Duration between timestamps.

#### Boolean Type
- **BOOLEAN**: true/false. Good for flags, toggles, statuses.

#### Choosing the Right Type
- **Use NUMERIC for money**: Avoid floating-point rounding errors.
- **Use TIMESTAMPTZ for timestamps**: Store timezone-aware times.
- **Use TEXT for descriptions**: No arbitrary length limits.
- **Use VARCHAR for constrained fields**: When you need to limit length.

---

### Verification Checklist

Before moving to Part 2, confirm you can:

- [ ] Connect to your Neon database using `psql`
- [ ] View all tables in your database (`\dt`)
- [ ] Describe the products table (`\d products`)
- [ ] Insert new products
- [ ] Select products with various filters
- [ ] Update product data
- [ ] Delete products
- [ ] Sort and paginate results
- [ ] Use LIKE/ILIKE for pattern matching

### Common Pitfalls to Avoid

1. **Forgetting the WHERE clause**: Running `DELETE FROM products` without WHERE deletes ALL rows!
2. **Case sensitivity with LIKE**: Remember to use ILIKE for case-insensitive searches.
3. **Not handling NULLs**: Be careful with `NULL` in comparisons. `WHERE column = NULL` doesn't work—use `IS NULL` or `IS NOT NULL`.
4. **Incorrect data types**: Don't try to put text in a numeric field.
5. **Not using transactions for multiple operations**: We'll cover this in Part 6.

---

### What's Next?

Congratulations! You've successfully provisioned your first Neon database, created a products table, and mastered basic CRUD operations. In Part 2, we'll:

- Learn about bulletproof primary keys (UUID vs SERIAL)
- Implement data integrity constraints
- Create a users table with validation
- Understand Neon's connection pooling

Take a moment to celebrate—you've built the foundation of your e-commerce backend!
