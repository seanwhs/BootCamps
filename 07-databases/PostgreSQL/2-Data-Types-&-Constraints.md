# Part 2: Data Types & Constraints (Building Bulletproof Tables)

Your `products` table works, but it could be more robust. In this part, we'll build the `users` table with PostgreSQL's advanced data types and powerful constraints. Think of constraints as security guards that prevent bad data from entering your database.

## Phase 2.1: Understanding PostgreSQL Data Types

### The Target
Learn about PostgreSQL's rich data type system and choose the right types for our `users` table.

### The Concept
Data types are like container sizes in a kitchen. You wouldn't store soup in a colander or dry pasta in a water jug. Similarly, PostgreSQL provides specific data types for specific kinds of data. We'll explore the key types and understand when to use each.

### The Implementation

Let's start by examining PostgreSQL's data types with real examples:

```sql
-- Connect to the database
\c ecommerce

-- Create a temporary table to explore data types
CREATE TEMP TABLE data_type_demo (
    -- Text types
    text_col TEXT,                    -- Unlimited length text
    varchar_col VARCHAR(50),          -- Limited to 50 characters
    char_col CHAR(10),               -- Fixed length, padded with spaces
    
    -- Numeric types
    integer_col INTEGER,              -- Whole numbers (-2.1B to 2.1B)
    bigint_col BIGINT,               -- Large whole numbers
    decimal_col DECIMAL(10,2),       -- Exact decimal, 10 total digits, 2 decimal places
    numeric_col NUMERIC(10,2),       -- Same as DECIMAL
    real_col REAL,                   -- Approximate, 6 decimal digits precision
    double_col DOUBLE PRECISION,      -- Approximate, 15 decimal digits precision
    
    -- Boolean
    boolean_col BOOLEAN,             -- TRUE, FALSE, NULL
    
    -- Date/Time
    date_col DATE,                   -- Just the date
    time_col TIME,                   -- Just the time
    timestamp_col TIMESTAMP,          -- Date and time, no timezone
    timestamptz_col TIMESTAMPTZ,     -- Date and time with timezone
    interval_col INTERVAL,           -- Time interval
    
    -- UUID (Universally Unique Identifier)
    uuid_col UUID,                   -- 32-character hex identifier
    
    -- JSON
    json_col JSON,                   -- JSON data (stored as text)
    jsonb_col JSONB,                 -- Binary JSON (indexable, faster)
    
    -- Arrays
    text_array TEXT[],               -- Array of text
    int_array INTEGER[]              -- Array of integers
);

-- Insert sample data to see how types work
INSERT INTO data_type_demo (
    text_col, varchar_col, char_col,
    integer_col, bigint_col, decimal_col, numeric_col,
    boolean_col,
    date_col, timestamptz_col,
    jsonb_col,
    text_array
) VALUES (
    'This is unlimited text',
    'Limited to 50 chars',
    'fixed',  -- Will be padded to 10 chars
    42,
    9223372036854775807,  -- Max BIGINT
    123.45,
    123.45,
    TRUE,
    '2024-01-15',
    '2024-01-15 14:30:00+00',
    '{"name": "John", "age": 30, "preferences": {"theme": "dark"}}',
    ARRAY['apple', 'banana', 'orange']
);

-- Query to see how types behave
SELECT 
    text_col,
    varchar_col,
    char_col,  -- Notice the padding!
    integer_col,
    bigint_col,
    decimal_col,
    numeric_col,
    boolean_col,
    date_col,
    timestamptz_col,
    jsonb_col,
    jsonb_col->>'name' AS json_name,
    text_array,
    text_array[1] AS first_array_item
FROM data_type_demo;
```

### The Verification

```bash
# See the table structure
psql -d ecommerce -c "\d data_type_demo"

# Query the data
psql -d ecommerce -c "SELECT * FROM data_type_demo;"

# Test a constraint violation (will fail)
psql -d ecommerce -c "INSERT INTO data_type_demo (varchar_col) VALUES ('This string is way longer than 50 characters and will fail!');"
# Expected: ERROR: value too long for type character varying(50)
```

---

## Phase 2.2: Designing the Users Table

### The Target
Design a comprehensive `users` table with appropriate data types and constraints.

### The Concept
A user table is the heart of any application. We need to store user information securely and enforce strict rules about what data is valid. We'll use `UUID` for primary keys instead of `SERIAL` for better distributed system support, and we'll add constraints to enforce data integrity.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- First, let's create the UUID extension (only needed once)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Now create the users table with bulletproof constraints
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    -- UUID primary key: More secure and globally unique than SERIAL
    -- uuid_generate_v4() creates a random UUID
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Email: Unique, must be valid format (we'll check with a constraint)
    email VARCHAR(255) NOT NULL UNIQUE,
    
    -- Password hash: Store only hashed passwords, never plain text!
    password_hash VARCHAR(255) NOT NULL,
    
    -- Name fields
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    
    -- Phone: Optional, but format should be validated
    phone VARCHAR(20),
    
    -- Address fields (optional for e-commerce)
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'US',
    
    -- Account status
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,  -- Email verified?
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Preferences
    preferences JSONB DEFAULT '{"theme": "light", "notifications": true}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    
    -- Add constraints for data validation
    CONSTRAINT email_format_check CHECK (
        email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT phone_format_check CHECK (
        phone IS NULL OR phone ~ '^\+?[0-9\-\(\)\s]{10,20}$'
    ),
    CONSTRAINT valid_country_check CHECK (
        country IN ('US', 'CA', 'UK', 'DE', 'FR', 'JP', 'AU', 'BR', 'IN', 'CN')
    ),
    CONSTRAINT postal_code_check CHECK (
        postal_code IS NULL OR postal_code ~ '^[0-9A-Za-z\-\s]{3,10}$'
    )
);

-- Add indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_last_name ON users(last_name);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Create a partial index (only indexes active users)
CREATE INDEX idx_users_active_created_at ON users(created_at) WHERE is_active = true;

-- Verify the table structure
\d users
```

### The Verification

```bash
# Check that the UUID extension is installed
psql -d ecommerce -c "SELECT * FROM pg_extension WHERE extname = 'uuid-ossp';"

# Verify the table exists with all columns
psql -d ecommerce -c "\d users"

# Check constraints
psql -d ecommerce -c "
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_def
FROM pg_constraint 
WHERE conrelid = 'users'::regclass;"
```

---

## Phase 2.3: Inserting Valid Users

### The Target
Insert valid user data to test our constraints.

### The Concept
Our constraints act as bouncers at a club—they only let valid data through. We'll try inserting valid users and see how the constraints protect us from bad data.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Insert valid users
INSERT INTO users (
    email,
    password_hash,
    first_name,
    last_name,
    phone,
    address_line1,
    city,
    state,
    postal_code,
    country,
    preferences
) VALUES 
(
    'john.doe@example.com',
    -- This is a bcrypt hash of 'password123' - NEVER use real passwords in examples!
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'John',
    'Doe',
    '+1-555-123-4567',
    '123 Main St',
    'New York',
    'NY',
    '10001',
    'US',
    '{"theme": "dark", "notifications": false, "language": "en"}'
),
(
    'jane.smith@example.com',
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Jane',
    'Smith',
    '+44-20-7946-0958',
    '456 Oxford St',
    'London',
    NULL,  -- Some countries don't have states/provinces
    'W1D 1LL',
    'UK',
    '{"theme": "light", "notifications": true, "language": "en-GB"}'
),
(
    'bob.wilson@example.com',
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Bob',
    'Wilson',
    NULL,  -- No phone number
    '789 Sunset Blvd',
    'Los Angeles',
    'CA',
    '90210',
    'US',
    '{"theme": "light", "notifications": true}'
),
(
    'alice.chen@example.com',
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Alice',
    'Chen',
    '+81-3-1234-5678',
    '1-2-3 Shibuya',
    'Tokyo',
    NULL,
    '150-0002',
    'JP',
    '{"theme": "auto", "notifications": false, "language": "ja"}'
),
(
    'admin@example.com',
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Admin',
    'User',
    '+1-555-000-0000',
    '100 Admin Way',
    'San Francisco',
    'CA',
    '94105',
    'US',
    '{"theme": "dark", "notifications": true, "is_admin": true}'
);

-- Verify the inserts
SELECT id, email, first_name, last_name, is_active, is_verified, is_admin 
FROM users;

-- Show the generated UUIDs
SELECT id, email FROM users;
```

### The Verification

```bash
# Count users
psql -d ecommerce -c "SELECT COUNT(*) FROM users;"

# Show all users
psql -d ecommerce -c "SELECT id, email, first_name, last_name, is_admin FROM users;"

# Check default values
psql -d ecommerce -c "SELECT email, is_active, is_verified, created_at FROM users;"
```

---

## Phase 2.4: Testing Constraints

### The Target
Test each constraint to ensure it blocks invalid data.

### The Concept
Our constraints should act like a vaccine—preventing bad data from getting through. We'll deliberately try to insert invalid data to prove our constraints work.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Test 1: Duplicate email (UNIQUE constraint)
-- This should fail
INSERT INTO users (email, password_hash, first_name, last_name) 
VALUES ('john.doe@example.com', 'hash', 'John', 'Doe');
-- Expected ERROR: duplicate key value violates unique constraint "users_email_key"

-- Test 2: Invalid email format (CHECK constraint)
-- This should fail
INSERT INTO users (email, password_hash, first_name, last_name) 
VALUES ('invalid-email', 'hash', 'John', 'Doe');
-- Expected ERROR: new row for relation "users" violates check constraint "email_format_check"

-- Test 3: Invalid phone format (CHECK constraint)
-- This should fail
INSERT INTO users (email, password_hash, first_name, last_name, phone) 
VALUES ('test@example.com', 'hash', 'John', 'Doe', '123');
-- Expected ERROR: new row for relation "users" violates check constraint "phone_format_check"

-- Test 4: Invalid country (CHECK constraint)
-- This should fail
INSERT INTO users (email, password_hash, first_name, last_name, country) 
VALUES ('test@example.com', 'hash', 'John', 'Doe', 'Mars');
-- Expected ERROR: new row for relation "users" violates check constraint "valid_country_check"

-- Test 5: NULL in NOT NULL column
-- This should fail
INSERT INTO users (email, password_hash, first_name) 
VALUES ('test@example.com', 'hash', NULL);
-- Expected ERROR: null value in column "first_name" violates not-null constraint

-- Test 6: Valid insertion with all fields
-- This should succeed
INSERT INTO users (
    email, password_hash, first_name, last_name, 
    phone, address_line1, city, state, postal_code, country
) VALUES (
    'new.user@example.com',
    'hash',
    'New',
    'User',
    '+1-555-999-8888',
    '456 New Street',
    'Boston',
    'MA',
    '02110',
    'US'
);

-- Verify the successful insert
SELECT email, first_name, last_name, country FROM users WHERE email = 'new.user@example.com';
```

### The Verification

```bash
# Check that only valid users were added
psql -d ecommerce -c "SELECT COUNT(*) FROM users;"

# Show all email addresses (should be 6 total)
psql -d ecommerce -c "SELECT email, first_name, last_name FROM users ORDER BY email;"
```

---

## Phase 2.5: Using JSONB for Flexible Data

### The Target
Store and query semi-structured data using PostgreSQL's JSONB type.

### The Concept
JSONB is like having a mini-document database inside your relational database. It allows you to store flexible, unstructured data while still being able to query and index it. Think of it as storing a user's preferences as a dictionary that can change without modifying the table schema.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Update user preferences using JSONB operations
-- Set specific preference values
UPDATE users 
SET preferences = jsonb_set(
    preferences,
    '{theme}',
    '"dark"'
) 
WHERE email = 'jane.smith@example.com';

-- Add a new preference without overwriting others
UPDATE users 
SET preferences = preferences || '{"language": "ja"}'::jsonb
WHERE email = 'alice.chen@example.com';

-- Remove a preference
UPDATE users 
SET preferences = preferences - 'notifications'
WHERE email = 'bob.wilson@example.com';

-- Complex JSONB queries
-- Find users who prefer dark theme
SELECT email, first_name, last_name, preferences
FROM users
WHERE preferences->>'theme' = 'dark';

-- Find users who have the 'notifications' preference set to true
SELECT email, first_name, last_name, preferences
FROM users
WHERE preferences->>'notifications' = 'true';

-- Find users with a specific key present
SELECT email, first_name, last_name, preferences
FROM users
WHERE preferences ? 'language';

-- Extract nested JSON data
SELECT 
    email,
    preferences->>'theme' AS theme,
    preferences->>'notifications' AS notifications,
    preferences->>'language' AS language
FROM users;

-- Update with complex nested JSON
UPDATE users 
SET preferences = jsonb_set(
    preferences,
    '{shipping}',
    '{"preferred_carrier": "UPS", "same_day": true}'::jsonb
)
WHERE email = 'john.doe@example.com';

-- Query nested JSON
SELECT 
    email,
    preferences->'shipping'->>'preferred_carrier' AS carrier,
    preferences->'shipping'->>'same_day' AS same_day
FROM users
WHERE preferences ? 'shipping';

-- Create an index on JSONB fields for better performance
CREATE INDEX idx_users_preferences_theme ON users ((preferences->>'theme'));
CREATE INDEX idx_users_preferences_language ON users ((preferences->>'language'));

-- Demonstrate the index with a query
-- EXPLAIN ANALYZE 
SELECT email, preferences->>'theme' AS theme
FROM users
WHERE preferences->>'theme' = 'dark';
```

### The Verification

```bash
# Show all users with their preferences
psql -d ecommerce -c "
SELECT 
    email,
    preferences
FROM users 
ORDER BY email;"

# Count users by theme preference
psql -d ecommerce -c "
SELECT 
    preferences->>'theme' AS theme,
    COUNT(*) AS count
FROM users 
GROUP BY theme;"

# Show users with shipping preferences
psql -d ecommerce -c "
SELECT 
    email,
    preferences->'shipping'
FROM users 
WHERE preferences ? 'shipping';"
```

---

## Phase 2.6: Audit Columns and Triggers

### The Target
Implement automatic timestamp updates using triggers.

### The Concept
Audit columns (`created_at`, `updated_at`) should update automatically. We'll create a trigger that updates `updated_at` every time a row changes. This is like having a built-in version control system for your data.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create a function that updates the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    -- Set updated_at to current timestamp
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that calls the function before any UPDATE
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Test the trigger
-- Check the current updated_at
SELECT id, email, updated_at FROM users WHERE email = 'john.doe@example.com';

-- Update the user
UPDATE users 
SET first_name = 'Jonathan' 
WHERE email = 'john.doe@example.com';

-- Check that updated_at changed automatically
SELECT id, email, first_name, updated_at FROM users WHERE email = 'john.doe@example.com';

-- Update multiple fields
UPDATE users 
SET 
    last_name = 'Smith-Wilson',
    is_verified = TRUE
WHERE email = 'bob.wilson@example.com';

-- Verify the trigger worked
SELECT email, first_name, last_name, is_verified, updated_at 
FROM users 
WHERE email = 'bob.wilson@example.com';
```

### The Verification

```bash
# Check the trigger exists
psql -d ecommerce -c "
SELECT 
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    tgtype,
    tgfoid::regproc AS function_name
FROM pg_trigger 
WHERE tgrelid = 'users'::regclass;"

# Test the automatic update
psql -d ecommerce -c "
UPDATE users SET first_name = 'Test' WHERE email = 'admin@example.com';
SELECT email, first_name, updated_at, created_at FROM users WHERE email = 'admin@example.com';"
```

---

## Phase 2.7: Implementing Soft Delete

### The Target
Create a "soft delete" pattern using the `is_active` flag.

### The Concept
Instead of permanently deleting users (which loses historical data), we'll "soft delete" them by setting `is_active = false`. This preserves the data while removing the user from active queries. Think of it as moving a file to the trash instead of permanently deleting it.

### The Implementation

```sql
-- Connect to the database
\c ecommerce

-- Create a view for active users (easier than always filtering)
DROP VIEW IF EXISTS active_users;

CREATE VIEW active_users AS
SELECT * FROM users WHERE is_active = true;

-- "Delete" a user (soft delete)
UPDATE users 
SET is_active = false,
    updated_at = NOW()
WHERE email = 'new.user@example.com';

-- Query using the view (only active users)
SELECT email, first_name, last_name, is_active 
FROM active_users 
ORDER BY email;

-- Query all users including inactive
SELECT email, first_name, last_name, is_active 
FROM users 
ORDER BY email;

-- Reactivate a user (undelete)
UPDATE users 
SET is_active = true,
    updated_at = NOW()
WHERE email = 'new.user@example.com';

-- Verify reactivation
SELECT email, first_name, last_name, is_active 
FROM users 
WHERE email = 'new.user@example.com';

-- Create a function to safely delete users
CREATE OR REPLACE FUNCTION soft_delete_user(user_email VARCHAR)
RETURNS TABLE(
    deleted_email VARCHAR,
    deleted_at TIMESTAMPTZ
) AS $$
BEGIN
    -- Update the user
    UPDATE users 
    SET 
        is_active = false,
        updated_at = NOW()
    WHERE email = user_email
    RETURNING email, updated_at INTO deleted_email, deleted_at;
    
    -- Return the result
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Use the function
SELECT * FROM soft_delete_user('bob.wilson@example.com');

-- Verify the user is now inactive
SELECT email, is_active, updated_at FROM users WHERE email = 'bob.wilson@example.com';

-- Create an "undelete" function
CREATE OR REPLACE FUNCTION hard_delete_user(user_email VARCHAR)
RETURNS VOID AS $$
BEGIN
    -- Permanently delete the user
    DELETE FROM users WHERE email = user_email;
END;
$$ LANGUAGE plpgsql;

-- WARNING: This permanently deletes data!
-- Only use when you're absolutely sure
-- SELECT hard_delete_user('bob.wilson@example.com');
```

### The Verification

```bash
# Check the active users view
psd -d ecommerce -c "SELECT COUNT(*) FROM active_users;"
psql -d ecommerce -c "SELECT COUNT(*) FROM users WHERE is_active = true;"

# Compare active vs total
psql -d ecommerce -c "
SELECT 
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE is_active = true) AS active_users,
    COUNT(*) FILTER (WHERE is_active = false) AS inactive_users
FROM users;"

# Test the soft delete function
psql -d ecommerce -c "SELECT * FROM soft_delete_user('jane.smith@example.com');"
```

---

## Phase 2.8: Complete Users Setup Script

### The Target
Create a complete, reusable setup script for the users table.

### The Concept
Professional database development requires reproducible setup scripts. We'll create a complete script that creates the users table, all constraints, indexes, triggers, and views.

### The Implementation

Create a file called `02_users_setup.sql`:

```sql
-- 02_users_setup.sql
-- Complete setup script for the users table

\c ecommerce

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop everything (clean slate)
DROP VIEW IF EXISTS active_users CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS soft_delete_user(VARCHAR) CASCADE;

-- Create the users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'US',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    preferences JSONB DEFAULT '{"theme": "light", "notifications": true}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ,
    
    CONSTRAINT email_format_check CHECK (
        email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    ),
    CONSTRAINT phone_format_check CHECK (
        phone IS NULL OR phone ~ '^\+?[0-9\-\(\)\s]{10,20}$'
    ),
    CONSTRAINT valid_country_check CHECK (
        country IN ('US', 'CA', 'UK', 'DE', 'FR', 'JP', 'AU', 'BR', 'IN', 'CN')
    ),
    CONSTRAINT postal_code_check CHECK (
        postal_code IS NULL OR postal_code ~ '^[0-9A-Za-z\-\s]{3,10}$'
    )
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_last_name ON users(last_name);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_active_created_at ON users(created_at) WHERE is_active = true;
CREATE INDEX idx_users_preferences_theme ON users ((preferences->>'theme'));

-- Create the updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create active users view
CREATE VIEW active_users AS
SELECT * FROM users WHERE is_active = true;

-- Create soft delete function
CREATE OR REPLACE FUNCTION soft_delete_user(user_email VARCHAR)
RETURNS TABLE(
    deleted_email VARCHAR,
    deleted_at TIMESTAMPTZ
) AS $$
BEGIN
    UPDATE users 
    SET is_active = false, updated_at = NOW()
    WHERE email = user_email
    RETURNING email, updated_at INTO deleted_email, deleted_at;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Insert initial users
INSERT INTO users (
    email, password_hash, first_name, last_name,
    phone, address_line1, city, state, postal_code, country,
    is_admin, preferences
) VALUES 
(
    'admin@example.com',
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Admin',
    'User',
    '+1-555-000-0000',
    '100 Admin Way',
    'San Francisco',
    'CA',
    '94105',
    'US',
    true,
    '{"theme": "dark", "notifications": true}'
),
(
    'demo.user@example.com',
    '$2a$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    'Demo',
    'User',
    '+1-555-123-4567',
    '123 Demo St',
    'New York',
    'NY',
    '10001',
    'US',
    false,
    '{"theme": "light", "notifications": true}'
);

-- Report
SELECT 'Users Setup Complete!' AS status;
SELECT COUNT(*) AS total_users FROM users;
SELECT COUNT(*) AS active_users_count FROM active_users;
```

Run the script:

```bash
# Execute the setup script
psql -d ecommerce -U ecommerce_user -f 02_users_setup.sql

# Verify the setup
psql -d ecommerce -c "SELECT COUNT(*) FROM users;"
psql -d ecommerce -c "SELECT email, is_admin, is_active FROM users;"
psql -d ecommerce -c "\dv"  -- Show views
psql -d ecommerce -c "\df"  -- Show functions
```

### The Verification

```bash
# Verify everything is working
psql -d ecommerce -c "SELECT COUNT(*) FROM users;"
psql -d ecommerce -c "SELECT COUNT(*) FROM active_users;"
psql -d ecommerce -c "SELECT * FROM soft_delete_user('demo.user@example.com');"
psql -d ecommerce -c "SELECT email, is_active FROM users WHERE email = 'demo.user@example.com';"
```

---

## Summary: What You've Accomplished

Congratulations! You've built a bulletproof users table with:

✅ UUID primary keys for global uniqueness  
✅ Email format validation with regular expressions  
✅ Phone number format validation  
✅ Country enumeration with a whitelist  
✅ JSONB preferences with querying and indexing  
✅ Automatic updated_at timestamps  
✅ Soft delete pattern using is_active flag  
✅ Comprehensive views and helper functions  
✅ Complete, reusable setup script  

## What's Next

In **Part 3**, we'll connect our users and products tables with relationships. You'll learn about foreign keys, joins, and building the orders system that ties everything together.

**Before Part 3**, practice these skills:
1. Add 5 new users with different preferences
2. Query users by country and theme preference
3. Soft delete a user and then reactivate them
4. Create a new view for admin users only
5. Add a new JSONB preference and query users who have it
