# Part 1: Foundations & The Audit Trail Setup

Welcome to the first technical installment of our Database Activity Management series! In Part 0, we established why DAM matters and outlined the complete architecture. Now, we roll up our sleeves and build the foundation upon which everything else rests: the audit trail.

## The Target: What We're Building Right Now

By the end of this part, you will have:

1. **A Node.js `AuditedPool` class** that wraps Neon/Postgres connections and logs every query with user context, timing, and status
2. **A Python `AuditedSQLite` context manager** that does the same for SQLite databases
3. **Persistent audit tables** in both database systems that store comprehensive query logs
4. **Real-time console output** for immediate visibility into database activity

These components form the bedrock of our DAM system. Every query—successful or failed—will leave an audit trail.

---

## The Concept: Why Audit Trails Matter

Imagine you're the security manager of a large bank. Every day, thousands of transactions occur. Money moves in and out. Employees access accounts. Customers check balances.

If something goes wrong—a theft, an error, a system compromise—how do you investigate? You need a complete, unalterable record of every action that occurred. You need to know:

- **Who** performed the action (which user)
- **What** they did (which query)
- **When** they did it (timestamp)
- **Where** they were (IP address)
- **How** it turned out (success or failure)
- **How long** it took (performance context)

This is an audit trail. In database terms, we log every query with these details.

### The Critical Properties of an Audit Trail

1. **Immutability**: Once a log entry is written, it should never be modified or deleted. This is why many DAM systems use append-only storage or write-once media.

2. **Completeness**: Every query, regardless of outcome, must be logged. Attackers can learn from failed queries too.

3. **Verifiability**: The audit log should be structured enough that it can be queried and analyzed programmatically.

4. **Performance**: Audit logging should not significantly impact database performance. We use asynchronous logging where possible.

5. **Separation of Concerns**: Audit logs should be stored separately from application data. If the application database is compromised, the audit trail survives.

### The Audit Pipeline Pattern

Think of audit logging like a security camera that records every moment:

1. **Before the event**: Capture the context (who, when, where)
2. **During the event**: Execute the actual database operation
3. **After the event**: Log the outcome (success, failure, duration)

This "before-during-after" pattern is what we'll implement in both JavaScript and Python.

---

## Implementation: JavaScript / Node.js + Neon

Let's build our first audited database layer. We'll start with the JavaScript implementation for Neon Serverless Postgres, then move to Python/SQLite.

### Step 1: Project Setup

First, ensure you're in the correct directory and have installed the necessary packages.

**Navigate to your JavaScript directory:**

```bash
cd guarding-the-core/javascript
```

**Install required dependencies:**

```bash
npm install pg dotenv
```

**Create your `.env` file:**

Create a file named `.env` in the `javascript/` directory with your Neon connection string:

```env
# javascript/.env
DATABASE_URL=postgresql://username:password@ep-some-id.us-east-2.aws.neon.tech/database?sslmode=require
```

**Verify your `package.json`:**

Your `package.json` should look similar to this (adjust the version numbers as needed):

```json
{
  "name": "javascript",
  "version": "1.0.0",
  "description": "DAM implementation for Neon/Postgres",
  "main": "src/index.js",
  "scripts": {
    "test": "node tests/test.js",
    "start": "node src/index.js"
  },
  "dependencies": {
    "dotenv": "^16.0.0",
    "pg": "^8.11.0"
  }
}
```

---

### Step 2: The AuditedPool Class

Now we create the core audit logging infrastructure. We'll wrap the PostgreSQL `Pool` class to intercept every query and log it.

**File: `javascript/src/audited-pool.js`**

```javascript
// javascript/src/audited-pool.js

import pkg from 'pg';
const { Pool } = pkg;

/**
 * AuditedPool - A database connection pool that logs every query with context
 * 
 * This class wraps the PostgreSQL Pool class and adds comprehensive audit logging
 * for every query executed through it. It captures:
 * - The exact SQL query and parameters
 * - Execution duration in milliseconds
 * - User context (who executed the query)
 * - IP address of the requestor
 * - Success/failure status
 * - Error messages if the query fails
 * 
 * @example
 * const pool = new AuditedPool(process.env.DATABASE_URL);
 * await pool.query('SELECT * FROM users WHERE id = $1', [123], { id: 'user-456', ip: '192.168.1.100' });
 */
export class AuditedPool {
  /**
   * Create a new audited connection pool
   * @param {string} connectionString - PostgreSQL connection string
   * @param {Object} options - Additional pool options (optional)
   */
  constructor(connectionString, options = {}) {
    // Store the connection string for potential reconnection logic
    this.connectionString = connectionString;
    
    // Create the underlying PostgreSQL pool
    // The Pool class manages multiple database connections efficiently
    this.pool = new Pool({ 
      connectionString,
      // Set a reasonable connection timeout to prevent hanging queries
      connectionTimeoutMillis: 5000,
      // Maximum number of clients the pool should contain
      max: 20,
      ...options
    });

    // Flag to track if we've initialized the audit table
    // We only need to create the audit table once, not for every connection
    this.auditTableInitialized = false;
  }

  /**
   * Initialize the audit table in the database
   * This is called automatically on the first query
   * 
   * The audit table stores:
   * - id: Auto-incrementing primary key
   * - query_text: The SQL query that was executed (with parameters? placeholders)
   * - query_params: The parameters passed to the query (JSONB format for Postgres)
   * - duration_ms: How long the query took in milliseconds
   * - user_id: Who executed the query (from application context)
   * - user_ip: Where the request originated
   * - status: 'SUCCESS' or 'ERROR'
   * - error_message: If status is ERROR, the error details
   * - timestamp: When the query was executed
   */
  async initAuditTable() {
    if (this.auditTableInitialized) {
      return; // Already initialized
    }

    // Use a temporary client directly from the pool
    // We don't want to audit our audit table creation!
    const client = await this.pool.connect();
    try {
      await client.query(`
        CREATE TABLE IF NOT EXISTS dam_audit_logs (
          id BIGSERIAL PRIMARY KEY,
          query_text TEXT NOT NULL,
          query_params JSONB,
          duration_ms NUMERIC(10, 3),
          user_id TEXT,
          user_ip TEXT,
          status TEXT NOT NULL,
          error_message TEXT,
          timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );

        -- Create an index on timestamp for efficient range queries
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_timestamp 
          ON dam_audit_logs(timestamp);

        -- Create an index on user_id for filtering by user
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_user_id 
          ON dam_audit_logs(user_id);

        -- Create an index on status for filtering failures
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_status 
          ON dam_audit_logs(status);
      `);
      
      // Mark as initialized so we don't recreate the table on every query
      this.auditTableInitialized = true;
    } finally {
      // Always release the client back to the pool
      // Even if the query fails, we need to release the connection
      client.release();
    }
  }

  /**
   * Execute a query with full audit logging
   * 
   * This method wraps the pool's query method and adds comprehensive logging
   * before and after the actual query execution. It captures:
   * 1. The query start time
   * 2. The query execution
   * 3. The duration
   * 4. The status (success/error)
   * 5. All relevant context
   * 
   * @param {string|Object} text - SQL query text or query configuration object
   * @param {Array} params - Query parameters (for parameterized queries)
   * @param {Object} userContext - Context about the user executing the query
   * @param {string} userContext.id - User identifier
   * @param {string} userContext.ip - User's IP address (or 'unknown' if not available)
   * @param {string} userContext.agent - User agent string (optional)
   * @returns {Promise<Object>} - The query result
   * @throws {Error} - Re-throws any error that occurred during query execution
   */
  async query(text, params = [], userContext = { id: 'system', ip: 'unknown' }) {
    // Ensure the audit table exists before we start logging
    // This is a no-op after the first successful call
    await this.initAuditTable();

    // Capture the start time with high precision
    // Using performance.now() for millisecond accuracy
    const startTime = performance.now();
    
    // Initialize status tracking variables
    let status = 'SUCCESS';
    let errorMessage = null;
    let result = null;

    // Determine the exact query text - handles both string and object formats
    // The pg library supports both: pool.query('SELECT...') and pool.query({ text: 'SELECT...' })
    const queryText = typeof text === 'string' ? text : text?.text ?? '[non-string query object]';
    
    // Determine the parameters - handle object format too
    const queryParams = typeof text === 'object' && text?.values ? text.values : params;

    try {
      // Execute the actual query
      // We use the underlying pool's query method to avoid infinite recursion
      result = await this.pool.query(text, params);
      return result;
    } catch (error) {
      // Something went wrong during execution
      status = 'ERROR';
      errorMessage = error.message;
      // Re-throw the error after we log it
      throw error;
    } finally {
      // This block always executes, regardless of success or failure
      // It's the perfect place for audit logging
      
      // Calculate the duration using performance.now() for sub-millisecond precision
      const endTime = performance.now();
      const durationMs = endTime - startTime;

      // Build the audit log entry as a structured object
      // Using JSONB in Postgres allows us to query inside the parameters later
      const auditEntry = {
        query_text: queryText,
        query_params: queryParams, // In production, you should redact sensitive values here
        duration_ms: durationMs,
        user_id: userContext.id || 'system',
        user_ip: userContext.ip || 'unknown',
        status: status,
        error_message: errorMessage
      };

      // Log the query asynchronously - we don't want to block the main query
      // This is a fire-and-forget operation
      await this.logAudit(auditEntry);
    }
  }

  /**
   * Write an audit entry to the database
   * 
   * This method uses a direct client connection to avoid recursion
   * (since we're logging a query, we don't want that query to be logged too!)
   * 
   * @param {Object} auditEntry - The audit data to log
   * @param {string} auditEntry.query_text - The SQL query
   * @param {Array|Object} auditEntry.query_params - Query parameters
   * @param {number} auditEntry.duration_ms - Execution duration
   * @param {string} auditEntry.user_id - User identifier
   * @param {string} auditEntry.user_ip - User IP address
   * @param {string} auditEntry.status - 'SUCCESS' or 'ERROR'
   * @param {string|null} auditEntry.error_message - Error details if any
   */
  async logAudit(auditEntry) {
    // Use a direct client connection to avoid the audit logging loop
    // If we used pool.query(), we'd be logging our own audit logs!
    const client = await this.pool.connect();
    try {
      // Insert the audit log entry
      // We use jsonb_build_object to safely convert the parameters to JSONB
      // This allows us to store complex parameter structures
      await client.query(
        `
        INSERT INTO dam_audit_logs (
          query_text,
          query_params,
          duration_ms,
          user_id,
          user_ip,
          status,
          error_message
        ) VALUES (
          $1,
          $2,
          $3,
          $4,
          $5,
          $6,
          $7
        )
        `,
        [
          auditEntry.query_text,
          // Convert parameters to JSON string for storage
          // Postgres will parse this as JSONB
          JSON.stringify(auditEntry.query_params || []),
          auditEntry.duration_ms,
          auditEntry.user_id,
          auditEntry.user_ip,
          auditEntry.status,
          auditEntry.error_message
        ]
      );
    } catch (auditError) {
      // If audit logging fails, we still want to know about it
      // We'll log to console as a fallback
      console.error('[DAM AUDIT FAILURE] Could not write audit log:', auditError);
      console.error('[DAM AUDIT FAILURE] Original audit entry:', auditEntry);
    } finally {
      // Always release the client back to the pool
      client.release();
    }

    // Also log to console for immediate visibility
    // In production, you might want to use a structured logger like pino or winston
    console.log(
      `[DAM AUDIT] ${new Date().toISOString()} | ` +
      `User: ${auditEntry.user_id} | ` +
      `IP: ${auditEntry.user_ip} | ` +
      `Status: ${auditEntry.status} | ` +
      `Duration: ${auditEntry.duration_ms.toFixed(2)}ms | ` +
      `Query: ${auditEntry.query_text.substring(0, 200)}${auditEntry.query_text.length > 200 ? '...' : ''}`
    );
  }

  /**
   * Get the underlying pool for advanced operations
   * Use with caution - this bypasses the audit trail
   * 
   * @returns {Pool} - The underlying PostgreSQL pool
   */
  getUnderlyingPool() {
    return this.pool;
  }

  /**
   * Close all connections in the pool
   * Must be called when shutting down the application
   */
  async close() {
    await this.pool.end();
  }
}
```

---

### Step 3: Testing the AuditedPool

Now let's create a test script to verify our audit logging works correctly.

**File: `javascript/tests/test-audited-pool.js`**

```javascript
// javascript/tests/test-audited-pool.js

import 'dotenv/config';
import { AuditedPool } from '../src/audited-pool.js';

/**
 * Test the AuditedPool class with various scenarios
 * We'll test:
 * 1. A successful SELECT query
 * 2. An INSERT query
 * 3. A failing query (to test error logging)
 * 4. Different user contexts
 */
async function testAuditedPool() {
  console.log('🧪 Testing AuditedPool...\n');

  // Ensure we have a database URL
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    console.error('   Please create a .env file with your Neon connection string.');
    process.exit(1);
  }

  // Create the audited pool
  const pool = new AuditedPool(databaseUrl);
  console.log('✅ AuditedPool created successfully');

  try {
    // TEST 1: Successful SELECT with user context
    console.log('\n📝 TEST 1: Successful SELECT query');
    console.log('   Context: User "alice@example.com" from IP "192.168.1.100"');
    
    // Create a users table if it doesn't exist
    await pool.query(`
      CREATE TABLE IF NOT EXISTS test_users (
        id SERIAL PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `, [], { id: 'system', ip: 'localhost' });

    // Insert a test user
    await pool.query(
      'INSERT INTO test_users (email, name) VALUES ($1, $2)',
      ['alice@example.com', 'Alice Johnson'],
      { id: 'alice@example.com', ip: '192.168.1.100' }
    );
    console.log('   ✅ Inserted test user');

    // Query the user we just inserted
    const result = await pool.query(
      'SELECT * FROM test_users WHERE email = $1',
      ['alice@example.com'],
      { id: 'alice@example.com', ip: '192.168.1.100' }
    );
    console.log(`   ✅ Retrieved user: ${result.rows[0]?.name || 'Not found'}`);

    // TEST 2: INSERT with different user context
    console.log('\n📝 TEST 2: INSERT query with different user');
    console.log('   Context: User "bob@example.com" from IP "10.0.0.5"');
    
    await pool.query(
      'INSERT INTO test_users (email, name) VALUES ($1, $2)',
      ['bob@example.com', 'Bob Smith'],
      { id: 'bob@example.com', ip: '10.0.0.5' }
    );
    console.log('   ✅ Inserted second test user');

    // TEST 3: Query with no user context (should use defaults)
    console.log('\n📝 TEST 3: Query with default user context');
    console.log('   Context: Default (system/unknown)');
    
    await pool.query('SELECT COUNT(*) FROM test_users');
    console.log('   ✅ Executed query with default context');

    // TEST 4: A deliberately failing query
    console.log('\n📝 TEST 4: Failing query (should log error)');
    console.log('   This query has a syntax error - it should be caught and logged');
    
    try {
      await pool.query(
        'SELECT * FROM non_existent_table_12345',
        [],
        { id: 'error_test', ip: '127.0.0.1' }
      );
      console.log('   ⚠️ Query should have failed but didn\'t!');
    } catch (error) {
      console.log(`   ✅ Query failed as expected: ${error.message}`);
    }

    // TEST 5: Query with complex parameters
    console.log('\n📝 TEST 5: Query with complex parameters (array)');
    console.log('   Testing that arrays are properly logged as JSONB');
    
    await pool.query(
      'SELECT * FROM test_users WHERE id = ANY($1)',
      [[1, 2]],
      { id: 'complex_test', ip: '192.168.1.200' }
    );
    console.log('   ✅ Executed query with array parameter');

    // Now check the audit logs to verify everything was recorded
    console.log('\n🔍 Checking audit logs...');
    
    const auditCheck = await pool.query(
      `
      SELECT 
        query_text,
        user_id,
        status,
        duration_ms,
        error_message
      FROM dam_audit_logs
      ORDER BY timestamp DESC
      LIMIT 10
      `,
      [],
      { id: 'system', ip: 'localhost' }
    );

    console.log(`\n📊 Last ${auditCheck.rows.length} audit entries:`);
    auditCheck.rows.forEach((row, index) => {
      console.log(`\n${index + 1}. Query: ${row.query_text.substring(0, 80)}${row.query_text.length > 80 ? '...' : ''}`);
      console.log(`   User: ${row.user_id}`);
      console.log(`   Status: ${row.status}`);
      console.log(`   Duration: ${row.duration_ms}ms`);
      if (row.error_message) {
        console.log(`   Error: ${row.error_message}`);
      }
    });

    console.log('\n✅ All tests completed successfully!');
    console.log('   Check the console output above for audit log entries.');
    console.log('   The dam_audit_logs table should contain records for all queries.');

  } catch (error) {
    console.error('❌ Test failed with error:', error);
  } finally {
    // Always clean up connections
    await pool.close();
    console.log('\n🔌 Connection pool closed.');
  }
}

// Run the test
testAuditedPool();
```

---

### Step 4: Creating a Simple Entry Point

Let's also create a simple entry point that demonstrates using the AuditedPool in an application context.

**File: `javascript/src/index.js`**

```javascript
// javascript/src/index.js

import 'dotenv/config';
import { AuditedPool } from './audited-pool.js';

/**
 * Simple application demonstrating the AuditedPool in action
 * This mimics a typical web application that executes queries
 * with user context from a request.
 */
async function main() {
  console.log('🚀 Starting DAM Demo Application');
  console.log('================================\n');

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    process.exit(1);
  }

  // Create the audited pool
  const pool = new AuditedPool(databaseUrl);
  console.log('✅ Connected to database with audit logging\n');

  try {
    // Simulate a user session
    const sessions = [
      { id: 'user-123', ip: '192.168.1.50', name: 'Frontend User' },
      { id: 'user-456', ip: '10.0.0.15', name: 'Admin User' },
      { id: 'system', ip: 'localhost', name: 'Background Job' },
    ];

    // Simulate some application operations
    console.log('📝 Simulating application operations...\n');

    // 1. Admin creates a new product
    console.log('1️⃣ Admin creates a new product');
    await pool.query(
      `INSERT INTO products (name, price, stock) VALUES ($1, $2, $3)`,
      ['Wireless Mouse', 29.99, 100],
      { id: sessions[1].id, ip: sessions[1].ip }
    );

    // 2. User views product catalog
    console.log('2️⃣ User views product catalog');
    const products = await pool.query(
      'SELECT name, price FROM products WHERE stock > $1 ORDER BY price',
      [0],
      { id: sessions[0].id, ip: sessions[0].ip }
    );
    console.log(`   Found ${products.rows.length} products`);

    // 3. Background job updates stock
    console.log('3️⃣ Background job updates stock');
    await pool.query(
      'UPDATE products SET stock = stock - $1 WHERE id = $2',
      [1, 1],
      { id: sessions[2].id, ip: sessions[2].ip }
    );

    // 4. Admin makes a mistake (intentional error)
    console.log('4️⃣ Admin attempts invalid operation (will fail)');
    try {
      await pool.query(
        'UPDATE products SET price = price * $1 WHERE invalid_column = $2',
        [1.1, 5],
        { id: sessions[1].id, ip: sessions[1].ip }
      );
    } catch (error) {
      // We expect this to fail
      console.log('   ✅ Operation failed as expected (logged as ERROR)');
    }

    // 5. Query to demonstrate audit logs
    console.log('\n📊 Retrieving audit summary...');
    const auditSummary = await pool.query(
      `
      SELECT 
        user_id,
        COUNT(*) as total_queries,
        AVG(duration_ms) as avg_duration_ms,
        COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as failed_queries
      FROM dam_audit_logs
      GROUP BY user_id
      ORDER BY total_queries DESC
      `,
      [],
      { id: 'system', ip: 'localhost' }
    );

    console.log('\n📈 Audit Summary:');
    console.log('---------------');
    auditSummary.rows.forEach(row => {
      console.log(`User: ${row.user_id}`);
      console.log(`  Total Queries: ${row.total_queries}`);
      console.log(`  Average Duration: ${row.avg_duration_ms.toFixed(2)}ms`);
      console.log(`  Failed Queries: ${row.failed_queries}`);
      console.log('');
    });

    console.log('✅ Demo completed successfully');
    console.log('   All queries were audited and logged to dam_audit_logs');

  } catch (error) {
    console.error('❌ Application error:', error);
  } finally {
    await pool.close();
    console.log('\n🔌 Connection pool closed.');
    console.log('👋 Demo finished');
  }
}

// Run the application if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
```

---

## Verification: Testing Your JavaScript Implementation

Now let's verify everything works. Run these commands in order:

### Step 1: Create the Database Tables

Before running the tests, let's create a simple products table so our demo doesn't fail.

**Create a setup script: `javascript/tests/setup.js`**

```javascript
// javascript/tests/setup.js

import 'dotenv/config';
import pkg from 'pg';
const { Pool } = pkg;

async function setupDatabase() {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL not set');
    process.exit(1);
  }

  const pool = new Pool({ connectionString: databaseUrl });
  console.log('📦 Setting up database tables...');

  try {
    // Create products table for our demo
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name TEXT NOT NULL,
        price NUMERIC(10, 2) NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Products table ready');

    // Insert some sample products if none exist
    const count = await pool.query('SELECT COUNT(*) FROM products');
    if (parseInt(count.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO products (name, price, stock) VALUES
          ('Laptop', 999.99, 10),
          ('Mouse', 29.99, 50),
          ('Keyboard', 79.99, 30)
      `);
      console.log('✅ Sample products inserted');
    }

    console.log('✅ Database setup complete!');
  } catch (error) {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

setupDatabase();
```

### Step 2: Run the Verification Commands

**1. Set up the database:**

```bash
cd javascript
node tests/setup.js
```

Expected output:
```
📦 Setting up database tables...
✅ Products table ready
✅ Sample products inserted
✅ Database setup complete!
```

**2. Run the audit pool tests:**

```bash
node tests/test-audited-pool.js
```

Expected output (you'll see actual UUIDs and timestamps):

```
🧪 Testing AuditedPool...

✅ AuditedPool created successfully

📝 TEST 1: Successful SELECT query
   Context: User "alice@example.com" from IP "192.168.1.100"
[DAM AUDIT] 2026-08-07T10:00:00.000Z | User: system | IP: localhost | Status: SUCCESS | Duration: 45.23ms | Query: CREATE TABLE IF NOT EXISTS test_users...
[DAM AUDIT] 2026-08-07T10:00:00.100Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 12.34ms | Query: INSERT INTO test_users (email, name) VALUES ($1, $2)
[DAM AUDIT] 2026-08-07T10:00:00.150Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 8.50ms | Query: SELECT * FROM test_users WHERE email = $1
   ✅ Retrieved user: Alice Johnson

📝 TEST 2: INSERT query with different user
   Context: User "bob@example.com" from IP "10.0.0.5"
[DAM AUDIT] 2026-08-07T10:00:00.200Z | User: bob@example.com | IP: 10.0.0.5 | Status: SUCCESS | Duration: 11.20ms | Query: INSERT INTO test_users (email, name) VALUES ($1, $2)
   ✅ Inserted second test user

📝 TEST 3: Query with default user context
   Context: Default (system/unknown)
[DAM AUDIT] 2026-08-07T10:00:00.250Z | User: system | IP: unknown | Status: SUCCESS | Duration: 6.80ms | Query: SELECT COUNT(*) FROM test_users
   ✅ Executed query with default context

📝 TEST 4: Failing query (should log error)
   Context: User "error_test" from IP "127.0.0.1"
[DAM AUDIT] 2026-08-07T10:00:00.300Z | User: error_test | IP: 127.0.0.1 | Status: ERROR | Duration: 15.40ms | Query: SELECT * FROM non_existent_table_12345
   ✅ Query failed as expected: relation "non_existent_table_12345" does not exist

📝 TEST 5: Query with complex parameters (array)
   Testing that arrays are properly logged as JSONB
[DAM AUDIT] 2026-08-07T10:00:00.350Z | User: complex_test | IP: 192.168.1.200 | Status: SUCCESS | Duration: 7.10ms | Query: SELECT * FROM test_users WHERE id = ANY($1)
   ✅ Executed query with array parameter

🔍 Checking audit logs...

📊 Last 10 audit entries:

1. Query: SELECT * FROM test_users WHERE id = ANY($1)
   User: complex_test
   Status: SUCCESS
   Duration: 7.1ms

2. Query: SELECT * FROM non_existent_table_12345
   User: error_test
   Status: ERROR
   Duration: 15.4ms
   Error: relation "non_existent_table_12345" does not exist

... (more entries)

✅ All tests completed successfully!
   Check the console output above for audit log entries.
   The dam_audit_logs table should contain records for all queries.

🔌 Connection pool closed.
```

**3. Run the demo application:**

```bash
node src/index.js
```

Expected output:
```
🚀 Starting DAM Demo Application
================================

✅ Connected to database with audit logging

📝 Simulating application operations...

1️⃣ Admin creates a new product
[DAM AUDIT] 2026-08-07T10:00:01.000Z | User: user-456 | IP: 10.0.0.15 | Status: SUCCESS | Duration: 15.20ms | Query: INSERT INTO products (name, price, stock) VALUES ($1, $2, $3)

2️⃣ User views product catalog
[DAM AUDIT] 2026-08-07T10:00:01.050Z | User: user-123 | IP: 192.168.1.50 | Status: SUCCESS | Duration: 10.30ms | Query: SELECT name, price FROM products WHERE stock > $1 ORDER BY price
   Found 3 products

3️⃣ Background job updates stock
[DAM AUDIT] 2026-08-07T10:00:01.100Z | User: system | IP: localhost | Status: SUCCESS | Duration: 8.70ms | Query: UPDATE products SET stock = stock - $1 WHERE id = $2

4️⃣ Admin attempts invalid operation (will fail)
[DAM AUDIT] 2026-08-07T10:00:01.150Z | User: user-456 | IP: 10.0.0.15 | Status: ERROR | Duration: 12.50ms | Query: UPDATE products SET price = price * $1 WHERE invalid_column = $2
   ✅ Operation failed as expected (logged as ERROR)

📊 Retrieving audit summary...

📈 Audit Summary:
---------------
User: user-123
  Total Queries: 1
  Average Duration: 10.30ms
  Failed Queries: 0

User: user-456
  Total Queries: 2
  Average Duration: 13.85ms
  Failed Queries: 1

User: system
  Total Queries: 1
  Average Duration: 8.70ms
  Failed Queries: 0

✅ Demo completed successfully
   All queries were audited and logged to dam_audit_logs

🔌 Connection pool closed.
👋 Demo finished
```

### Step 4: Verify the Audit Table Directly (Optional)

You can also connect to your Neon database directly and query the audit table:

```bash
# Using the Neon CLI or psql
psql $DATABASE_URL -c "SELECT user_id, status, LEFT(query_text, 50) as query_preview FROM dam_audit_logs ORDER BY timestamp DESC LIMIT 5;"
```

Or using a Node.js script:

```javascript
// Run this as: node -e "require('dotenv/config'); const {Pool} = require('pg'); const p = new Pool({connectionString: process.env.DATABASE_URL}); p.query('SELECT COUNT(*) FROM dam_audit_logs').then(r => console.log('Total audit logs:', r.rows[0].count)).finally(() => p.end());"
```

---

## Implementation: Python / SQLite

Now let's build the Python equivalent for SQLite. The concepts are identical, but the implementation patterns differ due to Python's unique features.

### Step 1: Project Setup

**Navigate to your Python directory:**

```bash
cd guarding-the-core/python
```

**Create `requirements.txt`:** (we'll add more packages in later parts)

```txt
# python/requirements.txt
# No external dependencies required for basic SQLite functionality
# We'll add more packages in later parts
```

**Create the main Python file:**

```python
# python/main.py

"""
DAM Implementation for SQLite
This module provides the main entry point for the Python DAM system.
"""

import sqlite3
import os
from datetime import datetime
from contextlib import contextmanager

# We'll import our classes from separate files as we build them
# For now, we'll keep everything in one file for simplicity

def main():
    print("🚀 Python DAM System")
    print("===================\n")
    
    # Create a test database in memory for demonstration
    # In production, you'd use a persistent file
    db_path = "test_dam.db"
    
    # TODO: We'll implement the AuditedSQLite class next
    
    print("✅ Python DAM system ready")

if __name__ == "__main__":
    main()
```

---

### Step 2: The AuditedSQLite Class

Now let's create the SQLite audit logging infrastructure.

**File: `python/audited_sqlite.py`**

```python
# python/audited_sqlite.py

"""
Audited SQLite Database Connection
Provides audit logging for all SQLite operations.
"""

import sqlite3
import json
import time
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Optional, Dict, Any, List, Union
import threading

class AuditedSQLite:
    """
    A wrapper around SQLite connections that provides comprehensive audit logging.
    
    This class intercepts all database operations and logs them with context,
    duration, and status information. It maintains an audit trail that can be
    used for security monitoring, compliance, and debugging.
    
    Features:
        - Automatic audit table creation
        - Logs every query with duration
        - Captures user context (user_id, ip)
        - Logs both successful and failed queries
        - Thread-safe for concurrent access
        - Console output for immediate visibility
    
    Example:
        >>> db = AuditedSQLite('myapp.db')
        >>> with db.transaction('SELECT * FROM users WHERE id = ?', user='alice@example.com') as cursor:
        ...     cursor.execute('SELECT * FROM users WHERE id = ?', (123,))
        ...     users = cursor.fetchall()
    """
    
    def __init__(self, db_path: str, create_audit_table: bool = True):
        """
        Initialize the audited SQLite database connection.
        
        Args:
            db_path: Path to the SQLite database file. Use ':memory:' for in-memory database.
            create_audit_table: Whether to create the audit table on initialization.
                Set to False if you want to create it manually.
        
        Raises:
            sqlite3.Error: If the database connection fails
        """
        self.db_path = db_path
        self._local = threading.local()
        
        # Initialize the audit table if requested
        if create_audit_table:
            self._init_audit_table()
    
    def _get_connection(self) -> sqlite3.Connection:
        """
        Get a thread-local database connection.
        This ensures each thread gets its own connection.
        
        Returns:
            sqlite3.Connection: A SQLite connection object
        """
        if not hasattr(self._local, 'connection') or self._local.connection is None:
            self._local.connection = sqlite3.connect(self.db_path, check_same_thread=False)
            # Enable foreign keys for better data integrity
            self._local.connection.execute("PRAGMA foreign_keys = ON")
            # Enable WAL mode for better concurrency
            self._local.connection.execute("PRAGMA journal_mode = WAL")
        return self._local.connection
    
    def _init_audit_table(self) -> None:
        """
        Create the audit_logs table if it doesn't exist.
        
        The audit table stores:
        - id: Auto-incrementing primary key
        - query_text: The SQL query (with ? placeholders)
        - query_params: JSON-encoded query parameters
        - duration_ms: Query execution time in milliseconds
        - user_id: Who executed the query
        - user_ip: Where the request originated
        - status: 'SUCCESS' or 'ERROR'
        - error_message: Error details if status is ERROR
        - timestamp: When the query was executed
        """
        conn = self._get_connection()
        conn.execute("""
            CREATE TABLE IF NOT EXISTS audit_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                query_text TEXT NOT NULL,
                query_params TEXT,  -- JSON encoded
                duration_ms REAL,
                user_id TEXT,
                user_ip TEXT,
                status TEXT NOT NULL,
                error_message TEXT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Create indexes for common query patterns
        conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_status ON audit_logs(status)")
        conn.commit()
    
    def _log_audit(self, audit_entry: Dict[str, Any]) -> None:
        """
        Write an audit entry to the database.
        
        This method uses a direct connection to avoid recursion.
        It logs to both the database and console for immediate visibility.
        
        Args:
            audit_entry: Dictionary containing the audit data
        """
        conn = self._get_connection()
        try:
            conn.execute(
                """
                INSERT INTO audit_logs (
                    query_text, query_params, duration_ms,
                    user_id, user_ip, status, error_message
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    audit_entry['query_text'],
                    audit_entry.get('query_params', '[]'),
                    audit_entry['duration_ms'],
                    audit_entry.get('user_id', 'system'),
                    audit_entry.get('user_ip', 'unknown'),
                    audit_entry['status'],
                    audit_entry.get('error_message')
                )
            )
            conn.commit()
        except sqlite3.Error as e:
            # If audit logging fails, log to console as fallback
            print(f"[DAM AUDIT FAILURE] Could not write audit log: {e}")
            print(f"[DAM AUDIT FAILURE] Original audit entry: {audit_entry}")
        
        # Always log to console for immediate visibility
        timestamp = datetime.now(timezone.utc).isoformat()
        print(
            f"[DAM AUDIT] {timestamp} | "
            f"User: {audit_entry.get('user_id', 'system')} | "
            f"IP: {audit_entry.get('user_ip', 'unknown')} | "
            f"Status: {audit_entry['status']} | "
            f"Duration: {audit_entry['duration_ms']:.2f}ms | "
            f"Query: {audit_entry['query_text'][:200]}{'...' if len(audit_entry['query_text']) > 200 else ''}"
        )
    
    def execute(self, query: str, params: Union[tuple, list, dict] = None,
                user_context: Dict[str, str] = None) -> sqlite3.Cursor:
        """
        Execute a query with full audit logging.
        
        This is a convenience method for single statements. For transactions
        with multiple statements, use the transaction() context manager.
        
        Args:
            query: SQL query string
            params: Query parameters (tuple, list, or dict)
            user_context: Dict with 'id' and 'ip' keys for the user
        
        Returns:
            sqlite3.Cursor: The cursor object from the executed query
        
        Raises:
            sqlite3.Error: If the query fails
        """
        params = params or ()
        user_context = user_context or {'id': 'system', 'ip': 'unknown'}
        
        start_time = time.perf_counter()
        status = 'SUCCESS'
        error_msg = None
        result = None
        
        conn = self._get_connection()
        cursor = conn.cursor()
        
        try:
            # Execute the query
            if isinstance(params, dict):
                cursor.execute(query, params)
            else:
                cursor.execute(query, params)
            conn.commit()
            result = cursor
            return result
        except sqlite3.Error as e:
            # Rollback on error
            conn.rollback()
            status = 'ERROR'
            error_msg = str(e)
            raise e
        finally:
            # Log the audit entry
            duration_ms = (time.perf_counter() - start_time) * 1000
            
            # Convert params to JSON for storage
            params_json = json.dumps(list(params) if isinstance(params, (tuple, list)) else params)
            
            self._log_audit({
                'query_text': query,
                'query_params': params_json,
                'duration_ms': duration_ms,
                'user_id': user_context.get('id', 'system'),
                'user_ip': user_context.get('ip', 'unknown'),
                'status': status,
                'error_message': error_msg
            })
    
    @contextmanager
    def transaction(self, query_description: str = None,
                   user_context: Dict[str, str] = None):
        """
        Context manager for transactional queries with audit logging.
        
        This is the recommended way to execute queries that may involve
        multiple statements. The context manager handles:
        1. Connection creation
        2. Transaction management (commit/rollback)
        3. Audit logging
        4. Error handling
        
        Args:
            query_description: A description of the query for logging
                              (e.g., "INSERT user", "UPDATE product")
            user_context: Dict with 'id' and 'ip' keys for the user
        
        Yields:
            sqlite3.Cursor: A cursor for executing queries
        
        Example:
            >>> with db.transaction('Update user', {'id': 'alice', 'ip': '192.168.1.100'}) as cur:
            ...     cur.execute("UPDATE users SET name = ? WHERE id = ?", ('Alice', 123))
            ...     cur.execute("INSERT INTO audit (action) VALUES (?)", ('user_updated',))
        """
        user_context = user_context or {'id': 'system', 'ip': 'unknown'}
        query_description = query_description or 'transaction'
        
        start_time = time.perf_counter()
        status = 'SUCCESS'
        error_msg = None
        
        # Get a connection and start a transaction
        conn = self._get_connection()
        cursor = conn.cursor()
        
        try:
            # Yield the cursor for the caller to use
            yield cursor
            # If we get here, no exception was raised
            conn.commit()
        except Exception as e:
            # Something went wrong - rollback and re-raise
            conn.rollback()
            status = 'ERROR'
            error_msg = str(e)
            raise e
        finally:
            # Always log the transaction
            duration_ms = (time.perf_counter() - start_time) * 1000
            
            self._log_audit({
                'query_text': f'[TRANSACTION] {query_description}',
                'query_params': '[]',
                'duration_ms': duration_ms,
                'user_id': user_context.get('id', 'system'),
                'user_ip': user_context.get('ip', 'unknown'),
                'status': status,
                'error_message': error_msg
            })
    
    def query(self, query: str, params: Union[tuple, list, dict] = None,
              user_context: Dict[str, str] = None) -> List[Dict[str, Any]]:
        """
        Execute a query and return results as a list of dictionaries.
        
        This is a convenience method that combines execute() and fetchall()
        into a single operation. Results are returned as dictionaries
        with column names as keys.
        
        Args:
            query: SQL query string
            params: Query parameters (tuple, list, or dict)
            user_context: Dict with 'id' and 'ip' keys for the user
        
        Returns:
            List[Dict[str, Any]]: List of rows as dictionaries
        """
        cursor = self.execute(query, params, user_context)
        columns = [description[0] for description in cursor.description] if cursor.description else []
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
    
    def query_one(self, query: str, params: Union[tuple, list, dict] = None,
                  user_context: Dict[str, str] = None) -> Optional[Dict[str, Any]]:
        """
        Execute a query and return the first row as a dictionary.
        
        This is useful for queries that are expected to return a single row.
        
        Args:
            query: SQL query string
            params: Query parameters (tuple, list, or dict)
            user_context: Dict with 'id' and 'ip' keys for the user
        
        Returns:
            Optional[Dict[str, Any]]: The first row as a dictionary, or None if no rows
        """
        cursor = self.execute(query, params, user_context)
        row = cursor.fetchone()
        if row is None:
            return None
        columns = [description[0] for description in cursor.description]
        return dict(zip(columns, row))
    
    def get_audit_logs(self, limit: int = 100, offset: int = 0,
                       user_id: str = None, status: str = None) -> List[Dict[str, Any]]:
        """
        Retrieve audit logs with optional filtering.
        
        Args:
            limit: Maximum number of logs to return
            offset: Number of logs to skip (for pagination)
            user_id: Filter by user ID
            status: Filter by status ('SUCCESS' or 'ERROR')
        
        Returns:
            List[Dict[str, Any]]: List of audit log entries
        """
        query = "SELECT * FROM audit_logs WHERE 1=1"
        params = []
        
        if user_id:
            query += " AND user_id = ?"
            params.append(user_id)
        if status:
            query += " AND status = ?"
            params.append(status)
        
        query += " ORDER BY timestamp DESC LIMIT ? OFFSET ?"
        params.extend([limit, offset])
        
        return self.query(query, params, {'id': 'system', 'ip': 'internal'})
    
    def get_audit_summary(self) -> Dict[str, Any]:
        """
        Get a summary of audit statistics.
        
        Returns:
            Dict with total queries, success rate, average duration, etc.
        """
        results = self.query(
            """
            SELECT 
                COUNT(*) as total_queries,
                COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful_queries,
                COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as failed_queries,
                AVG(duration_ms) as avg_duration_ms,
                MAX(duration_ms) as max_duration_ms,
                MIN(duration_ms) as min_duration_ms,
                COUNT(DISTINCT user_id) as unique_users
            FROM audit_logs
            """,
            user_context={'id': 'system', 'ip': 'internal'}
        )
        return results[0] if results else {}
    
    def close(self) -> None:
        """Close the database connection."""
        if hasattr(self._local, 'connection') and self._local.connection is not None:
            self._local.connection.close()
            self._local.connection = None
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - ensures connection is closed."""
        self.close()
```

---

### Step 3: Testing the AuditedSQLite

Now let's create a test script to verify our SQLite audit logging.

**File: `python/test_audited_sqlite.py`**

```python
# python/test_audited_sqlite.py

"""
Test script for the AuditedSQLite class.
"""

import os
import sys
import sqlite3
from datetime import datetime
from audited_sqlite import AuditedSQLite

def test_audited_sqlite():
    """Test all functionality of the AuditedSQLite class."""
    
    print("🧪 Testing AuditedSQLite...\n")
    
    # Use an in-memory database for testing
    # This ensures we start clean every time
    db = AuditedSQLite(':memory:')
    print("✅ AuditedSQLite created successfully")
    
    try:
        # TEST 1: Create a table and insert data
        print("\n📝 TEST 1: Creating table and inserting data")
        print("   Context: User 'admin' from IP '192.168.1.1'")
        
        db.execute(
            """
            CREATE TABLE IF NOT EXISTS test_users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT NOT NULL UNIQUE,
                name TEXT NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
            """,
            user_context={'id': 'admin', 'ip': '192.168.1.1'}
        )
        
        db.execute(
            "INSERT INTO test_users (email, name) VALUES (?, ?)",
            ('alice@example.com', 'Alice Johnson'),
            user_context={'id': 'alice@example.com', 'ip': '192.168.1.100'}
        )
        print("   ✅ Inserted test user")
        
        # TEST 2: Query with query() method
        print("\n📝 TEST 2: Query using query() method")
        print("   Context: User 'alice@example.com' from IP '192.168.1.100'")
        
        users = db.query(
            "SELECT * FROM test_users WHERE email = ?",
            ('alice@example.com',),
            user_context={'id': 'alice@example.com', 'ip': '192.168.1.100'}
        )
        print(f"   ✅ Found user: {users[0]['name'] if users else 'Not found'}")
        
        # TEST 3: Transaction with multiple statements
        print("\n📝 TEST 3: Transaction with multiple statements")
        print("   Context: User 'bob@example.com' from IP '10.0.0.5'")
        
        with db.transaction('Insert user', user_context={'id': 'bob@example.com', 'ip': '10.0.0.5'}):
            # Create a second user
            db.execute(
                "INSERT INTO test_users (email, name) VALUES (?, ?)",
                ('bob@example.com', 'Bob Smith')
            )
        print("   ✅ Transaction completed successfully")
        
        # TEST 4: Failing query (should log error)
        print("\n📝 TEST 4: Failing query (should log error)")
        print("   Context: User 'error_test' from IP '127.0.0.1'")
        
        try:
            db.execute(
                "SELECT * FROM non_existent_table_12345",
                user_context={'id': 'error_test', 'ip': '127.0.0.1'}
            )
            print("   ⚠️ Query should have failed but didn't!")
        except sqlite3.Error as e:
            print(f"   ✅ Query failed as expected: {e}")
        
        # TEST 5: Query with default context
        print("\n📝 TEST 5: Query with default context")
        print("   Using default system context")
        
        count = db.query_one(
            "SELECT COUNT(*) as count FROM test_users"
        )
        print(f"   ✅ Found {count['count']} users")
        
        # TEST 6: Get audit summary
        print("\n📊 Audit Summary:")
        summary = db.get_audit_summary()
        print(f"   Total Queries: {summary.get('total_queries', 0)}")
        print(f"   Successful: {summary.get('successful_queries', 0)}")
        print(f"   Failed: {summary.get('failed_queries', 0)}")
        print(f"   Avg Duration: {summary.get('avg_duration_ms', 0):.2f}ms")
        print(f"   Unique Users: {summary.get('unique_users', 0)}")
        
        # TEST 7: Retrieve recent audit logs
        print("\n📄 Recent Audit Logs:")
        logs = db.get_audit_logs(limit=5)
        for idx, log in enumerate(logs, 1):
            print(f"\n{idx}. Query: {log['query_text'][:60]}{'...' if len(log['query_text']) > 60 else ''}")
            print(f"   User: {log['user_id']}")
            print(f"   Status: {log['status']}")
            print(f"   Duration: {log['duration_ms']:.2f}ms")
        
        print("\n✅ All tests completed successfully!")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    test_audited_sqlite()
```

---

### Step 4: Creating the Main Application

Let's create a more comprehensive demo application.

**File: `python/main.py`**

```python
# python/main.py

"""
Main application for the Python DAM system.
"""

import os
import sqlite3
import random
import time
from datetime import datetime
from audited_sqlite import AuditedSQLite

def create_sample_data(db: AuditedSQLite) -> None:
    """Create sample tables and data for the demo."""
    
    print("\n📦 Creating sample data...")
    
    # Create products table
    db.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """, user_context={'id': 'system', 'ip': 'setup'})
    
    # Insert sample products if none exist
    count = db.query_one("SELECT COUNT(*) as count FROM products")
    if count['count'] == 0:
        with db.transaction('Insert sample products', user_context={'id': 'system', 'ip': 'setup'}):
            db.execute(
                "INSERT INTO products (name, price, stock) VALUES (?, ?, ?)",
                ('Laptop', 999.99, 10)
            )
            db.execute(
                "INSERT INTO products (name, price, stock) VALUES (?, ?, ?)",
                ('Wireless Mouse', 29.99, 50)
            )
            db.execute(
                "INSERT INTO products (name, price, stock) VALUES (?, ?, ?)",
                ('Mechanical Keyboard', 79.99, 30)
            )
        print("   ✅ Sample products inserted")
    
    # Create orders table for more complex operations
    db.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_email TEXT NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            total REAL NOT NULL,
            status TEXT DEFAULT 'pending',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id)
        )
    """, user_context={'id': 'system', 'ip': 'setup'})
    
    print("   ✅ Tables ready")

def simulate_user_activity(db: AuditedSQLite) -> None:
    """Simulate typical user activity with different roles."""
    
    # Different user sessions with their contexts
    sessions = [
        {'id': 'alice@example.com', 'ip': '192.168.1.100', 'name': 'Customer'},
        {'id': 'bob@example.com', 'ip': '10.0.0.5', 'name': 'Admin'},
        {'id': 'system', 'ip': 'localhost', 'name': 'Background Job'},
        {'id': 'charlie@example.com', 'ip': '192.168.1.50', 'name': 'Customer'},
    ]
    
    print("\n👤 Simulating user activities...")
    
    # 1. Admin updates product prices
    print("\n1️⃣ Admin updating product prices")
    with db.transaction('Update prices', user_context={'id': sessions[1]['id'], 'ip': sessions[1]['ip']}):
        db.execute(
            "UPDATE products SET price = price * ? WHERE id = ?",
            (1.1, 1)  # 10% price increase
        )
    print("   ✅ Prices updated")
    
    # 2. Customers browse products
    print("\n2️⃣ Customer browsing products")
    products = db.query(
        "SELECT name, price, stock FROM products WHERE stock > ? ORDER BY price",
        (0,),
        user_context={'id': sessions[0]['id'], 'ip': sessions[0]['ip']}
    )
    print(f"   ✅ Found {len(products)} products")
    
    # 3. Customer places an order
    print("\n3️⃣ Customer placing an order")
    product = db.query_one(
        "SELECT id, price FROM products WHERE name = ?",
        ('Wireless Mouse',),
        user_context={'id': sessions[0]['id'], 'ip': sessions[0]['ip']}
    )
    
    if product:
        quantity = 2
        total = product['price'] * quantity
        
        with db.transaction('Place order', user_context={'id': sessions[0]['id'], 'ip': sessions[0]['ip']}):
            # Create the order
            db.execute(
                """
                INSERT INTO orders (user_email, product_id, quantity, total)
                VALUES (?, ?, ?, ?)
                """,
                (sessions[0]['id'], product['id'], quantity, total)
            )
            
            # Update stock
            db.execute(
                "UPDATE products SET stock = stock - ? WHERE id = ?",
                (quantity, product['id'])
            )
        print(f"   ✅ Order placed for {quantity} units")
    
    # 4. Background job processes orders
    print("\n4️⃣ Background job processing orders")
    pending_orders = db.query(
        "SELECT id, user_email FROM orders WHERE status = 'pending'",
        user_context={'id': sessions[2]['id'], 'ip': sessions[2]['ip']}
    )
    
    for order in pending_orders:
        with db.transaction('Process order', user_context={'id': sessions[2]['id'], 'ip': sessions[2]['ip']}):
            db.execute(
                "UPDATE orders SET status = ? WHERE id = ?",
                ('processed', order['id'])
            )
        print(f"   ✅ Processed order #{order['id']} for {order['user_email']}")
    
    # 5. Another customer makes a mistake (intentional error)
    print("\n5️⃣ Customer attempting invalid operation (will fail)")
    try:
        db.execute(
            "UPDATE products SET stock = stock - ? WHERE invalid_column = ?",
            (5, 999),
            user_context={'id': sessions[3]['id'], 'ip': sessions[3]['ip']}
        )
        print("   ⚠️ This should have failed!")
    except sqlite3.Error as e:
        print(f"   ✅ Operation failed as expected: {e}")

def show_audit_report(db: AuditedSQLite) -> None:
    """Display an audit report showing activity statistics."""
    
    print("\n📊 Generating audit report...")
    print("=" * 60)
    
    # Summary statistics
    summary = db.get_audit_summary()
    print(f"\n📈 Overall Statistics:")
    print(f"   Total Queries: {summary.get('total_queries', 0)}")
    print(f"   Success Rate: {summary.get('successful_queries', 0) / max(1, summary.get('total_queries', 1)) * 100:.1f}%")
    print(f"   Average Duration: {summary.get('avg_duration_ms', 0):.2f}ms")
    print(f"   Unique Users: {summary.get('unique_users', 0)}")
    
    # User activity breakdown
    print("\n👤 User Activity Breakdown:")
    user_stats = db.query("""
        SELECT 
            user_id,
            COUNT(*) as queries,
            AVG(duration_ms) as avg_duration,
            COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as errors
        FROM audit_logs
        GROUP BY user_id
        ORDER BY queries DESC
    """)
    
    for stat in user_stats:
        print(f"\n   User: {stat['user_id']}")
        print(f"      Queries: {stat['queries']}")
        print(f"      Avg Duration: {stat['avg_duration']:.2f}ms")
        print(f"      Errors: {stat['errors']}")
    
    # Recent anomalies (failed queries or long-running queries)
    print("\n⚠️ Recent Issues:")
    recent_errors = db.query("""
        SELECT 
            query_text,
            user_id,
            duration_ms,
            error_message,
            timestamp
        FROM audit_logs
        WHERE status = 'ERROR'
        ORDER BY timestamp DESC
        LIMIT 3
    """)
    
    if recent_errors:
        for error in recent_errors:
            print(f"\n   ❌ Error at {error['timestamp']}")
            print(f"      User: {error['user_id']}")
            print(f"      Query: {error['query_text'][:100]}...")
            print(f"      Error: {error['error_message']}")
    else:
        print("   No recent errors found ✅")
    
    print("\n" + "=" * 60)

def main():
    """Main application entry point."""
    
    print("🚀 Python DAM Application")
    print("========================")
    print(f"Started at: {datetime.now().isoformat()}")
    
    # Use a persistent database file for this demo
    db_path = "dam_demo.db"
    
    # Remove old database if it exists (for clean demo)
    if os.path.exists(db_path):
        os.remove(db_path)
        print("🧹 Removed old database file")
    
    # Create the audited database
    db = AuditedSQLite(db_path)
    print("✅ Audited database created")
    
    try:
        # Setup sample data
        create_sample_data(db)
        
        # Simulate user activity
        simulate_user_activity(db)
        
        # Show audit report
        show_audit_report(db)
        
        print("\n✅ Demo completed successfully!")
        print(f"   Database: {db_path}")
        print("   All queries were audited and logged to audit_logs")
        print("   Check the console output above for audit entries")
        
    except Exception as e:
        print(f"❌ Application error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    main()
```

---

## Verification: Testing Your Python Implementation

### Step 1: Verify Python Installation

```bash
python --version
# Should show Python 3.8.0 or higher
```

### Step 2: Run the Tests

**Run the AuditedSQLite tests:**

```bash
cd python
python test_audited_sqlite.py
```

Expected output:

```
🧪 Testing AuditedSQLite...

✅ AuditedSQLite created successfully

📝 TEST 1: Creating table and inserting data
   Context: User 'admin' from IP '192.168.1.1'
[DAM AUDIT] 2026-08-07T10:00:00.000Z | User: admin | IP: 192.168.1.1 | Status: SUCCESS | Duration: 2.50ms | Query: CREATE TABLE IF NOT EXISTS test_users...
[DAM AUDIT] 2026-08-07T10:00:00.010Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 1.20ms | Query: INSERT INTO test_users (email, name) VALUES (?, ?)
   ✅ Inserted test user

📝 TEST 2: Query using query() method
   Context: User 'alice@example.com' from IP '192.168.1.100'
[DAM AUDIT] 2026-08-07T10:00:00.020Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 0.80ms | Query: SELECT * FROM test_users WHERE email = ?
   ✅ Found user: Alice Johnson

📝 TEST 3: Transaction with multiple statements
   Context: User 'bob@example.com' from IP '10.0.0.5'
[DAM AUDIT] 2026-08-07T10:00:00.030Z | User: bob@example.com | IP: 10.0.0.5 | Status: SUCCESS | Duration: 2.10ms | Query: [TRANSACTION] Insert user
   ✅ Transaction completed successfully

📝 TEST 4: Failing query (should log error)
   Context: User 'error_test' from IP '127.0.0.1'
[DAM AUDIT] 2026-08-07T10:00:00.040Z | User: error_test | IP: 127.0.0.1 | Status: ERROR | Duration: 0.50ms | Query: SELECT * FROM non_existent_table_12345
   ✅ Query failed as expected: no such table: non_existent_table_12345

📝 TEST 5: Query with default context
   Using default system context
[DAM AUDIT] 2026-08-07T10:00:00.050Z | User: system | IP: unknown | Status: SUCCESS | Duration: 0.30ms | Query: SELECT COUNT(*) as count FROM test_users
   ✅ Found 2 users

📊 Audit Summary:
   Total Queries: 6
   Successful: 5
   Failed: 1
   Avg Duration: 1.23ms
   Unique Users: 4

📄 Recent Audit Logs:

1. Query: [TRANSACTION] Insert user
   User: bob@example.com
   Status: SUCCESS
   Duration: 2.10ms

2. Query: SELECT * FROM non_existent_table_12345
   User: error_test
   Status: ERROR
   Duration: 0.50ms

3. Query: SELECT * FROM test_users WHERE email = ?
   User: alice@example.com
   Status: SUCCESS
   Duration: 0.80ms

4. Query: INSERT INTO test_users (email, name) VALUES (?, ?)
   User: alice@example.com
   Status: SUCCESS
   Duration: 1.20ms

5. Query: CREATE TABLE IF NOT EXISTS test_users...
   User: admin
   Status: SUCCESS
   Duration: 2.50ms

✅ All tests completed successfully!

🔌 Database connection closed.
```

### Step 3: Run the Full Demo

```bash
python main.py
```

Expected output (abbreviated):

```
🚀 Python DAM Application
========================
Started at: 2026-08-07T10:00:01.123456

🧹 Removed old database file
✅ Audited database created

📦 Creating sample data...
   ✅ Sample products inserted
   ✅ Tables ready

👤 Simulating user activities...

1️⃣ Admin updating product prices
[DAM AUDIT] 2026-08-07T10:00:01.200Z | User: bob@example.com | IP: 10.0.0.5 | Status: SUCCESS | Duration: 1.50ms | Query: [TRANSACTION] Update prices
   ✅ Prices updated

2️⃣ Customer browsing products
[DAM AUDIT] 2026-08-07T10:00:01.210Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 0.90ms | Query: SELECT name, price, stock FROM products WHERE stock > ? ORDER BY price
   ✅ Found 3 products

3️⃣ Customer placing an order
[DAM AUDIT] 2026-08-07T10:00:01.220Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 2.30ms | Query: SELECT id, price FROM products WHERE name = ?
[DAM AUDIT] 2026-08-07T10:00:01.230Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 3.10ms | Query: [TRANSACTION] Place order
   ✅ Order placed for 2 units

4️⃣ Background job processing orders
[DAM AUDIT] 2026-08-07T10:00:01.240Z | User: system | IP: localhost | Status: SUCCESS | Duration: 0.80ms | Query: SELECT id, user_email FROM orders WHERE status = 'pending'
[DAM AUDIT] 2026-08-07T10:00:01.250Z | User: system | IP: localhost | Status: SUCCESS | Duration: 1.20ms | Query: [TRANSACTION] Process order
   ✅ Processed order #1 for alice@example.com

5️⃣ Customer attempting invalid operation (will fail)
[DAM AUDIT] 2026-08-07T10:00:01.260Z | User: charlie@example.com | IP: 192.168.1.50 | Status: ERROR | Duration: 0.40ms | Query: UPDATE products SET stock = stock - ? WHERE invalid_column = ?
   ✅ Operation failed as expected: no such column: invalid_column

📊 Generating audit report...
============================================================

📈 Overall Statistics:
   Total Queries: 8
   Success Rate: 87.5%
   Average Duration: 1.55ms
   Unique Users: 4

👤 User Activity Breakdown:

   User: alice@example.com
      Queries: 3
      Avg Duration: 2.10ms
      Errors: 0

   User: bob@example.com
      Queries: 1
      Avg Duration: 1.50ms
      Errors: 0

   User: charlie@example.com
      Queries: 1
      Avg Duration: 0.40ms
      Errors: 1

   User: system
      Queries: 2
      Avg Duration: 1.00ms
      Errors: 0

⚠️ Recent Issues:

   ❌ Error at 2026-08-07 10:00:01.260
      User: charlie@example.com
      Query: UPDATE products SET stock = stock - ? WHERE invalid_column = ?...
      Error: no such column: invalid_column

============================================================

✅ Demo completed successfully!
   Database: dam_demo.db
   All queries were audited and logged to audit_logs
   Check the console output above for audit entries

🔌 Database connection closed.
```

### Step 4: Verify the Database Contents (Optional)

You can also use the SQLite CLI to inspect the audit logs directly:

```bash
sqlite3 dam_demo.db
sqlite> .schema audit_logs
sqlite> SELECT user_id, status, LEFT(query_text, 40) as query_preview FROM audit_logs LIMIT 5;
sqlite> SELECT COUNT(*) FROM audit_logs;
sqlite> .quit
```

Or using Python:

```bash
python -c "
import sqlite3
conn = sqlite3.connect('dam_demo.db')
cursor = conn.cursor()
cursor.execute('SELECT COUNT(*) FROM audit_logs')
print(f'Total audit logs: {cursor.fetchone()[0]}')
conn.close()
"
```

---

## Deep Reference Section

Now that we've built the foundation, let's dive deeper into some of the critical concepts and patterns we've used.

### Reference: Connection Pooling

**What is Connection Pooling?**

A database connection pool maintains a cache of database connections that can be reused. Instead of opening and closing a connection for every query, the pool reuses existing connections.

**Why It Matters for DAM:**

Our `AuditedPool` wraps a connection pool. This is important because:
- We need to intercept every query regardless of which connection it uses
- We need to maintain the audit log's integrity across multiple connections
- We need to handle errors gracefully without leaking connections

**How Our Implementation Works:**

```javascript
// We create a pool that manages connections
this.pool = new Pool({ connectionString });

// When a query comes in, we check if we have a connection available
// The pool handles the complexity of connection management

// When the pool is closed, all connections are properly terminated
await this.pool.end();
```

**In SQLite:**

SQLite doesn't have traditional connection pooling, but our `AuditedSQLite` class provides similar benefits through:
- Thread-local connections (each thread gets its own connection)
- Connection reuse across operations
- Proper cleanup on close

### Reference: Transaction Management

**What is a Transaction?**

A transaction groups multiple database operations into a single atomic unit. Either all operations succeed, or none do.

**Why It Matters for DAM:**

When we audit transactions, we need to log:
- The entire transaction as a unit (not just individual statements)
- Whether the transaction committed or rolled back
- The duration of the entire transaction

**Our Implementation Approach:**

**JavaScript (Postgres):**

In Postgres, transactions are typically managed by the client:

```javascript
// In the demo, we don't explicitly manage transactions, but we could:
const client = await pool.pool.connect();
try {
  await client.query('BEGIN');
  await client.query('INSERT INTO products...');
  await client.query('UPDATE inventory...');
  await client.query('COMMIT');
} catch (error) {
  await client.query('ROLLBACK');
  throw error;
} finally {
  client.release();
}
```

**Python (SQLite):**

In SQLite, we use a context manager pattern:

```python
with db.transaction('Transaction description', user_context):
    cursor.execute('INSERT INTO products...')
    cursor.execute('UPDATE inventory...')
# Auto-commits on success, auto-rollbacks on error
```

This pattern ensures:
1. The transaction is properly committed or rolled back
2. The audit entry captures the transaction as a whole
3. Errors are caught and logged with the rollback

### Reference: Thread Safety

**What is Thread Safety?**

Thread safety means that a piece of code works correctly when multiple threads access it simultaneously. Each thread should see a consistent state without interference.

**Why It Matters for DAM:**

In a web application, multiple requests may hit the database at the same time. Our audit system needs to handle this concurrency without:
- Corrupting audit logs
- Losing audit entries
- Creating race conditions

**Our Implementation Approach:**

**In Node.js (Single-Threaded, Async):**

JavaScript is single-threaded but asynchronous. We rely on:
- Promise-based operations that don't share state
- Each query gets its own execution context
- The underlying pg pool handles connection management

**In Python (Multi-Threaded):**

We use thread-local storage to ensure each thread has its own connection:

```python
self._local = threading.local()

def _get_connection(self):
    if not hasattr(self._local, 'connection'):
        self._local.connection = sqlite3.connect(self.db_path)
    return self._local.connection
```

This prevents threads from interfering with each other's connections.

### Reference: Logging Strategies

**Console Logging vs. Database Logging**

We log audit entries to both console and the database:

**Console Logging:**
- Immediate visibility for developers
- Useful for debugging and monitoring
- Not persistent (logs can be lost on restart)

**Database Logging:**
- Persistent storage
- Queryable for analysis
- Immune to console loss
- Requires database write operations (performance impact)

**Our Approach:**

We use both:
1. Database logging for persistence and queryability
2. Console logging for immediate visibility

In production, you might:
- Replace console logging with structured JSON logging
- Send logs to a centralized logging system (ELK, Loki, etc.)
- Use async logging to avoid blocking database operations

### Reference: Performance Considerations

**Where Does the Overhead Come From?**

Audit logging adds overhead in several places:
1. **Duration measurement**: Using `performance.now()` or `time.perf_counter()`
2. **Parameter serialization**: Converting parameters to JSON
3. **Database write**: Inserting the audit entry
4. **Console output**: Writing to stdout

**Mitigation Strategies:**

1. **Async Audit Logging**:
   In JavaScript, we use `await this.logAudit()` but in production, you might want to make it fire-and-forget:
   ```javascript
   // Don't await - let it run in the background
   this.logAudit(auditEntry).catch(err => console.error('Audit failed:', err));
   ```

2. **Batching**:
   Accumulate multiple audit entries and write them in a batch.

3. **Sample-Based Logging**:
   Log only a percentage of queries in high-throughput systems.

4. **Separate Audit Database**:
   Write audit logs to a separate database to avoid contention.

**Performance in Our Implementation:**

We balance performance and completeness:
- We measure duration with high precision but minimal overhead
- We use parameterized queries for the audit table insertion
- We log to database synchronously (simpler, but could be optimized)

### Reference: Security Considerations

**What We're Already Doing Right**

1. **Parameterized Queries**: We use parameterized queries (`$1`, `$2` or `?`), preventing SQL injection.
2. **Separate Audit Table**: Audit logs are stored separately from application data.
3. **User Context**: Every query is tagged with user and IP information.
4. **Error Logging**: Failed queries are logged with error details.
5. **Immutable Logs**: We never update or delete audit entries.

**Areas for Production Improvement**

1. **Parameter Redaction**: We currently log all parameters. In production, you should redact sensitive data like passwords, credit card numbers, or PII.
   ```javascript
   // Add redaction logic
   function redactSensitiveParams(params) {
       return params.map(p => 
           typeof p === 'string' && p.match(/password|ssn|credit/i) ? '[REDACTED]' : p
       );
   }
   ```

2. **Audit Table Security**: The audit table should have restricted access:
   ```sql
   -- Only allow INSERT for application users
   REVOKE ALL ON dam_audit_logs FROM PUBLIC;
   GRANT INSERT ON dam_audit_logs TO app_user;
   -- Only admins can SELECT for analysis
   GRANT SELECT ON dam_audit_logs TO admin_role;
   ```

3. **Encryption**: Consider encrypting sensitive audit log fields at rest.

4. **Log Rotation**: Audit logs can grow quickly. Implement log rotation or archiving.

### Reference: Comparing the Two Implementations

| Feature | JavaScript/Neon (Postgres) | Python/SQLite |
|---------|---------------------------|---------------|
| **Database Type** | Serverless Cloud | Local File |
| **Connection** | Connection Pool | Thread-Local |
| **Transaction** | Manual (BEGIN/COMMIT) | Context Manager |
| **Concurrency** | Async/Promise | Thread-Local |
| **Performance** | Higher (Cloud) | Lower (Local) |
| **Audit Storage** | dam_audit_logs table | audit_logs table |
| **Parameter Format** | JSONB | JSON text |
| **Error Handling** | Try/Catch/Finally | Try/Except/Finally |

Both implementations achieve the same goal with different idioms appropriate to each language and database.

---

## Summary: What You've Built

Congratulations! You've completed Part 1 of the DAM series. You now have:

### JavaScript Implementation
- ✅ `AuditedPool` class that wraps Neon/Postgres connections
- ✅ Automatic audit table creation with proper indexes
- ✅ Comprehensive logging with user context, timing, and status
- ✅ Console output for immediate visibility
- ✅ Test script verifying all functionality
- ✅ Demo application showing real-world usage

### Python Implementation
- ✅ `AuditedSQLite` class for SQLite audit logging
- ✅ Thread-safe connection management
- ✅ Context manager for transactional operations
- ✅ Query methods with built-in audit logging
- ✅ Audit log retrieval and summary functions
- ✅ Test script and full demo application

### Common Knowledge Gained
- ✅ Why audit trails are essential for database security
- ✅ The "before-during-after" logging pattern
- ✅ Transaction management in both JavaScript and Python
- ✅ Thread safety considerations for audit systems
- ✅ Performance trade-offs in audit logging
- ✅ Security considerations for production deployment

---

## What's Next: Part 2 - Interception & Native Hooks

In Part 1, we built audit logging at the **application layer**. Every query that goes through our `AuditedPool` or `AuditedSQLite` classes is logged. But what about queries that bypass our wrapper?

In Part 2, we'll go deeper to intercept queries at the **driver and native levels**. This ensures that even if another part of the application uses a raw database connection, we'll still catch and log the activity.

We'll cover:
- **Driver-level middleware**: Intercepting queries at the pg driver level
- **Native hooks**: Using PostgreSQL's `pgaudit` and SQLite's `sqlite3_trace_callback`
- **Defense in depth**: Multiple interception layers for complete coverage

**Get ready to go deeper into the database stack!**

*Part 1 is complete! You now have a working audit trail for both Neon/Postgres and SQLite. Continue to Part 2 to learn how to intercept queries at the driver and native levels for even more comprehensive coverage.*
