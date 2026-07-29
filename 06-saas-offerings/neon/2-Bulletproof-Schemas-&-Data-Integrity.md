# Serverless Postgres with Neon: From Zero to Production

## Part 2: Bulletproof Schemas & Data Integrity

### The Target

In this part, we'll:
1. Understand the importance of primary keys (SERIAL vs UUID)
2. Generate and use UUIDs in PostgreSQL
3. Create a robust `users` table with comprehensive constraints
4. Implement email validation using PostgreSQL CHECK constraints
5. Add automatic timestamp management
6. Understand Neon's connection pooling (Direct vs Pooled connections)
7. Write a complete schema migration script

By the end of this part, you'll have a production-quality `users` table with bulletproof data integrity and understand how to manage connections in a serverless environment.

---

### The Concept: Building a Fortress for Your Data

Imagine you're building a secure apartment building. You need:
- **Unique apartment numbers** (primary keys) so no two units are confused
- **Rules about who can enter** (constraints) like "residents must be over 18"
- **A way to identify residents** (UUIDs) that works across the entire city
- **A guest book** (timestamp columns) that records when people come and go

In database terms, these are:
- **Primary Keys**: Uniquely identify each record
- **Constraints**: Enforce business rules automatically
- **UUIDs**: Universally unique identifiers that work across systems
- **Timestamps**: Track when records are created or modified

---

### Implementation Step 1: Understanding Primary Keys - SERIAL vs UUID

#### 1.1 The SERIAL Primary Key

We used `SERIAL` in Part 1. It's simple and efficient:

```sql
-- SERIAL creates an auto-incrementing integer
CREATE TABLE example_serial (
    id SERIAL PRIMARY KEY,  -- 1, 2, 3, 4, ...
    name TEXT
);

INSERT INTO example_serial (name) VALUES ('First'), ('Second');
SELECT * FROM example_serial;
-- id | name
-- 1  | First
-- 2  | Second
```

**Pros of SERIAL**:
- Simple to understand and use
- Efficient for storage (4 bytes)
- Fast for joins and indexing

**Cons of SERIAL**:
- Predictable (bad for security - users can guess other IDs)
- Not portable across databases (if you merge databases, IDs conflict)
- Difficult to use in distributed systems

#### 1.2 The UUID Primary Key

UUID stands for "Universally Unique Identifier"—a 128-bit number that's globally unique:

```sql
-- UUID is a 36-character string (with hyphens)
CREATE TABLE example_uuid (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT
);

INSERT INTO example_uuid (name) VALUES ('First'), ('Second');
SELECT * FROM example_uuid;
-- id                                   | name
-- 550e8400-e29b-41d4-a716-446655440000 | First
-- 6ba7b810-9dad-11d1-80b4-00c04fd430c8 | Second
```

**Pros of UUID**:
- Globally unique (even across different systems)
- Non-sequential (better for security)
- Can be generated client-side

**Cons of UUID**:
- Larger storage (16 bytes vs 4 bytes)
- Slower for indexing due to randomness
- Harder to read and remember

#### 1.3 Which Should You Use?

**Use SERIAL when**:
- You're building a simple internal application
- Data never needs to merge with other databases
- Performance is critical and you're dealing with billions of rows

**Use UUID when**:
- Building public-facing APIs (security matters)
- Working with distributed systems
- You might need to merge data from multiple sources
- You want to generate IDs client-side

**For our e-commerce app, we'll use UUIDs for the users table and keep SERIAL for the products table**—this gives you experience with both approaches.

---

### Implementation Step 2: Enable UUID Extension in Neon

#### 2.1 Enable the Extension

Before we can use UUIDs, we need to enable the `uuid-ossp` extension:

```sql
-- Connect to your database and run:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Verify it's installed
SELECT * FROM pg_extension WHERE extname = 'uuid-ossp';
```

**The Verification**: You should see a row with `uuid-ossp` in the `extname` column.

#### 2.2 Test UUID Generation

```sql
-- Generate a random UUID
SELECT uuid_generate_v4();

-- Generate multiple UUIDs
SELECT 
    uuid_generate_v4() as uuid1,
    uuid_generate_v4() as uuid2,
    uuid_generate_v4() as uuid3;
```

**The Verification**: You should see three different UUID strings. Notice how they're 36 characters with hyphens.

---

### Implementation Step 3: Create the Users Table

Now let's build our robust `users` table with comprehensive constraints.

#### 3.1 The Complete Schema

```sql
-- Create the users table with comprehensive constraints
CREATE TABLE IF NOT EXISTS users (
    -- UUID primary key with automatic generation
    -- We use gen_random_uuid() which is available in PostgreSQL 13+
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Email: Unique, not null, with validation
    -- The CHECK constraint enforces email format (more on this later)
    email VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    
    -- Username: Unique, not null, 3-50 characters
    -- Must start with a letter and only contain letters, numbers, and underscores
    username VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT valid_username CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$'),
    
    -- Password hash: Never store plain text passwords!
    -- We'll use bcrypt in the application, but the database stores the hash
    password_hash TEXT NOT NULL,
    
    -- Full name: Not null, 1-100 characters
    full_name VARCHAR(100) NOT NULL,
    
    -- Optional fields with sensible defaults
    phone VARCHAR(20),  -- No constraint, we'll validate in application
    
    -- Status: Enum-like behavior with CHECK constraint
    -- 'active' = normal user, 'inactive' = deactivated, 'suspended' = temporary ban
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'suspended')),
    
    -- Role: For permission management
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    CONSTRAINT valid_role CHECK (role IN ('customer', 'staff', 'admin')),
    
    -- Timestamps with automatic management
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Soft delete: Instead of actually deleting, we mark as deleted
    -- This preserves data for audits and allows restoration
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for faster queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- Output confirmation
SELECT 'Users table created successfully!' AS status;
```

**The Verification**: You should see the table creation message. Run `\d users` to see the structure.

---

### Implementation Step 4: Understanding Constraints

#### 4.1 NOT NULL Constraint

Prevents NULL (empty) values:

```sql
-- This will fail because email is NOT NULL
INSERT INTO users (email) VALUES (NULL);  -- ERROR: null value violates not-null constraint
```

**Why It Matters**: Business-critical fields should always have values. A user without an email can't log in or receive notifications.

#### 4.2 UNIQUE Constraint

Ensures no duplicate values:

```sql
-- This will fail if the email already exists
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('john@example.com', 'john_doe', 'hash', 'John Doe');

-- Second attempt with same email fails
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('john@example.com', 'john_doe2', 'hash', 'John Doe');  -- ERROR: duplicate key value
```

**Why It Matters**: Prevents multiple accounts with the same email or username.

#### 4.3 CHECK Constraint

Validates data with custom rules:

```sql
-- Email validation with regular expression
-- This ensures emails follow the format: name@domain.tld
CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')

-- Username validation: starts with letter, then letters/numbers/underscore, 3-50 chars
CONSTRAINT valid_username CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$')

-- Status validation: only allowed values
CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'suspended'))
```

**Testing the CHECK constraints**:

```sql
-- Invalid email (missing @)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('invalidemail.com', 'test_user', 'hash', 'Test User');  -- ERROR

-- Invalid username (starts with number)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('test@example.com', '1test_user', 'hash', 'Test User');  -- ERROR

-- Valid insertion (should work)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('test@example.com', 'test_user', 'hash', 'Test User');  -- SUCCESS
```

---

### Implementation Step 5: Insert Sample Users

#### 5.1 Insert Various Users

```sql
-- Insert sample users with different roles and statuses
INSERT INTO users (email, username, password_hash, full_name, phone, role, status) VALUES
    ('alice.admin@company.com', 'alice_admin', 'hash_placeholder', 'Alice Johnson', '+1-555-0101', 'admin', 'active'),
    ('bob.staff@company.com', 'bob_staff', 'hash_placeholder', 'Bob Smith', '+1-555-0102', 'staff', 'active'),
    ('carol.customer@example.com', 'carol_customer', 'hash_placeholder', 'Carol Williams', '+1-555-0103', 'customer', 'active'),
    ('david.customer@example.com', 'david_customer', 'hash_placeholder', 'David Brown', '+1-555-0104', 'customer', 'inactive'),
    ('eve.customer@example.com', 'eve_customer', 'hash_placeholder', 'Eve Davis', '+1-555-0105', 'customer', 'suspended');

-- Verify insertion
SELECT id, email, username, full_name, role, status, created_at 
FROM users 
ORDER BY created_at;
```

**The Verification**: You should see 5 users with different roles and statuses.

#### 5.2 Test Data Integrity

Let's test that our constraints work:

```sql
-- Test 1: Duplicate email (should fail)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('alice.admin@company.com', 'new_user', 'hash', 'New User');

-- Test 2: Duplicate username (should fail)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('new@example.com', 'alice_admin', 'hash', 'New User');

-- Test 3: Invalid email format (should fail)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('notanemail', 'new_user', 'hash', 'New User');

-- Test 4: Invalid username (should fail)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('valid@example.com', 'ab', 'hash', 'New User');  -- Too short

-- Test 5: Valid insertion (should succeed)
INSERT INTO users (email, username, password_hash, full_name) 
VALUES ('valid@example.com', 'valid_user', 'hash_placeholder', 'Valid User');
```

**The Verification**: Tests 1-4 should fail with constraint violation errors. Test 5 should succeed.

---

### Implementation Step 6: Automatic Timestamps

#### 6.1 How Automatic Timestamps Work

Our table has `created_at` and `updated_at` fields:

```sql
-- created_at: Set once when record is created
created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP

-- updated_at: Set on creation and updated on modification
updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
```

The `DEFAULT CURRENT_TIMESTAMP` sets the value automatically. However, `updated_at` won't auto-update on changes—we need a trigger for that.

#### 6.2 Create the Update Trigger

```sql
-- Create a function that updates the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a trigger that calls the function on UPDATE
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

**The Verification**: 

```sql
-- Test the trigger
UPDATE users SET full_name = 'Alice Johnson (Updated)' WHERE email = 'alice.admin@company.com';

-- Check if updated_at changed
SELECT email, full_name, created_at, updated_at 
FROM users 
WHERE email = 'alice.admin@company.com';
```

You should see that `updated_at` is now later than `created_at`.

**Why This Matters**: Timestamps are crucial for:
- Auditing: When was this record created or changed?
- Debugging: When did this issue start happening?
- Reporting: How many users signed up this month?
- Caching: Has this data changed since we last fetched it?

---

### Implementation Step 7: Soft Delete Pattern

#### 7.1 What is Soft Delete?

Instead of actually deleting a record (which permanently removes data), we mark it as deleted with a timestamp:

```sql
-- Mark a user as deleted
UPDATE users 
SET deleted_at = CURRENT_TIMESTAMP 
WHERE email = 'david.customer@example.com';

-- Query active users (not deleted)
SELECT email, username, full_name 
FROM users 
WHERE deleted_at IS NULL;

-- Query deleted users
SELECT email, username, full_name, deleted_at 
FROM users 
WHERE deleted_at IS NOT NULL;
```

**Benefits of Soft Delete**:
- Data isn't permanently lost
- Can restore deleted records
- Maintains referential integrity
- Useful for audits and compliance

**Drawbacks**:
- Requires filtering in all queries
- Storage grows over time

#### 7.2 Create a View for Active Users

Views simplify querying by creating a virtual table:

```sql
-- Create a view that only shows active (not soft-deleted) users
CREATE VIEW active_users AS
SELECT 
    id, email, username, full_name, phone, 
    role, status, created_at, updated_at
FROM users
WHERE deleted_at IS NULL;

-- Query the view (simpler than filtering every time)
SELECT * FROM active_users;

-- Verify deleted user isn't shown
SELECT COUNT(*) FROM active_users;  -- Should be 4 (David is soft-deleted)
```

**The Verification**: The count should be 4 since David was soft-deleted.

---

### Implementation Step 8: Neon Connection Pooling

#### 8.1 Understanding Direct vs Pooled Connections

Neon offers two connection modes:

**Direct Connection** (Standard):
```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Pooled Connection** (Recommended for serverless):
```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction
```

#### 8.2 Why Pooling Matters

In serverless environments (AWS Lambda, Vercel, Cloudflare Workers):
- **Each request gets a new connection**
- Opening/closing connections is slow
- You can hit connection limits

**Pooled connections**:
- Reuse connections between requests
- Much faster for short-lived connections
- Can handle thousands of concurrent users

#### 8.3 Connection Pooling Modes

Neon supports these pooling modes:

1. **Session Mode**: 
   - A single connection is used for the entire session
   - Good for long-running applications (APIs, web apps)
   
2. **Transaction Mode** (Default):
   - Connection is used only for one transaction
   - Released immediately after transaction commits/rolls back
   - Perfect for serverless functions

#### 8.4 Getting Your Pooled Connection String

1. In your Neon dashboard, click on your project
2. Go to "Connection Details"
3. Toggle "Pooled Connection" 
4. Copy the connection string with `pool_mode=transaction`

Your pooled string will look like:
```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction
```

#### 8.5 Best Practice: Use Pooled Connections

```javascript
// Example Node.js configuration for Neon
const { Pool } = require('pg');

// Use the pooled connection string
const pool = new Pool({
    connectionString: process.env.DATABASE_POOLED_URL,
    max: 20, // Maximum connections in pool
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Connect using the pool
pool.connect((err, client, release) => {
    if (err) {
        console.error('Error connecting to database', err);
        return;
    }
    // Use the client
    client.query('SELECT * FROM products', (err, result) => {
        release(); // Release back to pool
    });
});
```

---

### Implementation Step 9: Complete Schema Migration Script

#### 9.1 Create a Migration File

Create `migrations/001_create_users_table.sql`:

```sql
-- migrations/001_create_users_table.sql
-- Complete migration script for users table

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing table if it exists (careful in production!)
DROP TABLE IF EXISTS users CASCADE;

-- Create users table with all constraints
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    username VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT valid_username CHECK (username ~ '^[A-Za-z][A-Za-z0-9_]{2,49}$'),
    password_hash TEXT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    CONSTRAINT valid_status CHECK (status IN ('active', 'inactive', 'suspended')),
    role VARCHAR(20) NOT NULL DEFAULT 'customer',
    CONSTRAINT valid_role CHECK (role IN ('customer', 'staff', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- Create function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for automatic updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create view for active users
CREATE VIEW active_users AS
SELECT 
    id, email, username, full_name, phone, 
    role, status, created_at, updated_at
FROM users
WHERE deleted_at IS NULL;

-- Insert initial seed data
INSERT INTO users (email, username, password_hash, full_name, phone, role, status) VALUES
    ('admin@company.com', 'admin', 'hash_placeholder', 'System Administrator', '+1-555-0000', 'admin', 'active'),
    ('staff@company.com', 'staff', 'hash_placeholder', 'Staff Member', '+1-555-0001', 'staff', 'active'),
    ('demo@example.com', 'demo_user', 'hash_placeholder', 'Demo User', '+1-555-0002', 'customer', 'active');

-- Verify the migration
SELECT 
    'Migration completed successfully!' as status,
    (SELECT COUNT(*) FROM users) as user_count,
    (SELECT COUNT(*) FROM active_users) as active_user_count;

-- Show sample data
SELECT id, email, username, full_name, role, status 
FROM users 
LIMIT 5;
```

#### 9.2 Run the Migration

```bash
# From your terminal
psql "postgresql://your-username:your-password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction" -f migrations/001_create_users_table.sql
```

#### 9.3 Create a Rollback Script

Create `migrations/001_rollback_users_table.sql`:

```sql
-- migrations/001_rollback_users_table.sql
-- Rollback users table migration

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP VIEW IF EXISTS active_users;
DROP TABLE IF EXISTS users;
DROP EXTENSION IF EXISTS "uuid-ossp";

SELECT 'Rollback completed successfully!' as status;
```

**The Verification**: Run the migration and check the output. You should see the status message with user counts.

---

### Implementation Step 10: Querying the Users Table

#### 10.1 Basic Queries

```sql
-- Get all active users with their roles
SELECT email, username, full_name, role, status 
FROM active_users 
ORDER BY created_at DESC;

-- Get users by role
SELECT email, username, full_name 
FROM users 
WHERE role = 'customer' AND deleted_at IS NULL;

-- Get users by status
SELECT email, username, full_name, status 
FROM users 
WHERE status = 'active' AND deleted_at IS NULL;

-- Search users by email or username
SELECT id, email, username, full_name 
FROM users 
WHERE (email ILIKE '%john%' OR username ILIKE '%john%')
  AND deleted_at IS NULL;
```

#### 10.2 Advanced Queries

```sql
-- Count users by role
SELECT role, COUNT(*) as count
FROM users
WHERE deleted_at IS NULL
GROUP BY role
ORDER BY count DESC;

-- Users created in the last 7 days
SELECT email, username, created_at
FROM users
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
  AND deleted_at IS NULL;

-- Users who haven't logged in (if we had login tracking)
-- This is a placeholder for when we add login tracking
SELECT email, username, created_at
FROM users
WHERE deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM user_sessions 
      WHERE user_sessions.user_id = users.id
  );
```

---

### Verification Checklist

Before moving to Part 3, confirm you can:

- [ ] Generate UUIDs using PostgreSQL functions
- [ ] Create a table with comprehensive constraints (NOT NULL, UNIQUE, CHECK)
- [ ] Insert data that passes validation rules
- [ ] See constraint violations when inserting invalid data
- [ ] Use automatic timestamps (created_at, updated_at)
- [ ] Implement soft delete pattern
- [ ] Create and use a view for active users
- [ ] Understand the difference between direct and pooled connections
- [ ] Run a complete migration script

---

### Deep Dive: Regular Expressions in PostgreSQL

We used regex for validation in our CHECK constraints. Let's break down the patterns:

#### Email Validation Pattern
```
^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$
```

- `^` - Start of string
- `[A-Za-z0-9._%+-]+` - One or more valid characters for local part
- `@` - Literal @ symbol
- `[A-Za-z0-9.-]+` - One or more valid characters for domain
- `\.` - Literal dot (escaped)
- `[A-Za-z]{2,}` - Two or more letters (TLD)
- `$` - End of string

#### Username Validation Pattern
```
^[A-Za-z][A-Za-z0-9_]{2,49}$
```

- `^` - Start of string
- `[A-Za-z]` - First character must be a letter
- `[A-Za-z0-9_]{2,49}` - 2-49 characters, letters/numbers/underscore
- `$` - End of string

#### PostgreSQL Regex Functions
```sql
-- Test if a string matches a pattern
SELECT 'test@example.com' ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AS is_valid;

-- Extract matching substring
SELECT substring('email: test@example.com' FROM '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');

-- Replace text using regex
SELECT regexp_replace('My email is test@example.com', 'test@example.com', 'new@example.com');
```

---

### Common Pitfalls to Avoid

1. **Not validating email format**: Use CHECK constraints or application validation
2. **Storing plain text passwords**: NEVER! Always hash with bcrypt, Argon2, or PBKDF2
3. **Forgetting to filter deleted users**: Always check `deleted_at IS NULL` in queries
4. **Using SERIAL for user-facing IDs**: Use UUIDs for security
5. **Not using connection pooling in serverless**: Can cause connection exhaustion
6. **Not indexing frequently queried columns**: Email, username, and status should always be indexed

---

### What's Next?

Excellent progress! You've built a rock-solid users table with data integrity constraints. In Part 3, we'll:

- Explore Neon's database branching feature
- Create dev and staging branches
- Build relational models (orders, order_items)
- Learn about foreign keys and joins
- Write complex multi-table queries

The branching feature is where Neon really shines—you'll create instant copies of your database for safe development and testing!
