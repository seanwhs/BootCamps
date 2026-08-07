# DAM Tutorial Series: Complete Lab Book

Welcome to the DAM Tutorial Lab Book! This comprehensive laboratory manual provides structured, hands-on exercises for building and testing your Database Activity Management system. Each lab builds on previous ones, creating a complete, working DAM system by the end.

---

## HOW TO USE THIS LAB BOOK

### Lab Structure

Each lab contains:

1. **Lab Objectives** - What you'll accomplish
2. **Pre-Lab Requirements** - What you need before starting
3. **Estimated Time** - How long the lab should take
4. **Step-by-Step Instructions** - Detailed procedures
5. **Code to Write** - Complete code blocks to implement
6. **Verification Steps** - How to confirm it works
7. **Lab Report** - Questions to answer
8. **Troubleshooting Guide** - Common issues and solutions

### Lab Setup

**Directory Structure:**
```
dam-labs/
├── lab-1-audit/
│   ├── javascript/
│   │   ├── src/
│   │   └── tests/
│   └── python/
│       ├── src/
│       └── tests/
├── lab-2-interception/
├── lab-3-normalization/
├── lab-4-detection/
├── lab-5-response/
└── lab-6-integration/
```

### Lab Completion Checklist

For each lab, check off:
- [ ] All code implemented
- [ ] All verification steps pass
- [ ] Lab report questions answered
- [ ] Troubleshooting notes documented

---

# LAB 1: BUILDING THE AUDIT FOUNDATION

## Lab 1.1: JavaScript AuditedPool

### Objectives
- ✅ Build an `AuditedPool` class for PostgreSQL/Neon
- ✅ Create and initialize audit tables
- ✅ Implement query interception with logging
- ✅ Test the audit system

### Pre-Lab Requirements
- ☐ Node.js v16+ installed
- ☐ Neon account with connection string
- ☐ Code editor (VS Code recommended)

### Estimated Time: 45 minutes

### Step 1: Project Setup

**1.1 Create the lab directory:**
```bash
mkdir -p ~/dam-labs/lab-1-audit/javascript
cd ~/dam-labs/lab-1-audit/javascript
```

**1.2 Initialize the project:**
```bash
npm init -y
npm install pg dotenv
```

**1.3 Create environment file:**

Create `.env`:
```env
DATABASE_URL=postgresql://user:pass@host:port/database?sslmode=require
```

### Step 2: Implement the AuditedPool

**2.1 Create `src/audited-pool.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/audited-pool.js

import pkg from 'pg';
const { Pool } = pkg;

/**
 * AuditedPool - A database connection pool that logs every query with context
 * 
 * This class wraps the PostgreSQL Pool class and adds comprehensive audit logging
 * for every query executed through it.
 */
export class AuditedPool {
  constructor(connectionString, options = {}) {
    this.connectionString = connectionString;
    this.pool = new Pool({ 
      connectionString,
      connectionTimeoutMillis: 5000,
      max: 20,
      ...options
    });
    this.auditTableInitialized = false;
  }

  /**
   * Initialize the audit table in the database
   * Called automatically on the first query
   */
  async initAuditTable() {
    if (this.auditTableInitialized) {
      return;
    }

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
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_timestamp 
          ON dam_audit_logs(timestamp);
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_user_id 
          ON dam_audit_logs(user_id);
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_status 
          ON dam_audit_logs(status);
      `);
      this.auditTableInitialized = true;
    } finally {
      client.release();
    }
  }

  /**
   * Execute a query with full audit logging
   */
  async query(text, params = [], userContext = { id: 'system', ip: 'unknown' }) {
    await this.initAuditTable();

    const startTime = performance.now();
    let status = 'SUCCESS';
    let errorMessage = null;
    let result = null;

    try {
      result = await this.pool.query(text, params);
      return result;
    } catch (error) {
      status = 'ERROR';
      errorMessage = error.message;
      throw error;
    } finally {
      const durationMs = performance.now() - startTime;
      await this.logAudit({
        query_text: text,
        query_params: params,
        duration_ms: durationMs,
        user_id: userContext.id || 'system',
        user_ip: userContext.ip || 'unknown',
        status: status,
        error_message: errorMessage
      });
    }
  }

  /**
   * Write an audit entry to the database
   */
  async logAudit(auditEntry) {
    const client = await this.pool.connect();
    try {
      await client.query(
        `
        INSERT INTO dam_audit_logs (
          query_text, query_params, duration_ms, user_id, user_ip, status, error_message
        ) VALUES ($1, $2, $3, $4, $5, $6, $7)
        `,
        [
          auditEntry.query_text,
          JSON.stringify(auditEntry.query_params || []),
          auditEntry.duration_ms,
          auditEntry.user_id,
          auditEntry.user_ip,
          auditEntry.status,
          auditEntry.error_message
        ]
      );
    } finally {
      client.release();
    }

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
   */
  getUnderlyingPool() {
    return this.pool;
  }

  /**
   * Close all connections in the pool
   */
  async close() {
    await this.pool.end();
  }
}
```
</details>

### Step 3: Create the Test Script

**3.1 Create `tests/test-audited-pool.js`:**

<details>
<summary>Click to expand the test code</summary>

```javascript
// tests/test-audited-pool.js

import 'dotenv/config';
import { AuditedPool } from '../src/audited-pool.js';

async function testAuditedPool() {
  console.log('🧪 Testing AuditedPool...\n');

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    console.error('   Please create a .env file with your Neon connection string.');
    process.exit(1);
  }

  const pool = new AuditedPool(databaseUrl);
  console.log('✅ AuditedPool created successfully');

  try {
    // TEST 1: Successful SELECT
    console.log('\n📝 TEST 1: Successful SELECT query');
    console.log('   Context: User "test-user" from IP "127.0.0.1"');
    
    const result1 = await pool.query(
      'SELECT NOW() as current_time',
      [],
      { id: 'test-user', ip: '127.0.0.1' }
    );
    console.log(`   ✅ Query returned: ${result1.rows[0].current_time}`);

    // TEST 2: Create and query a table
    console.log('\n📝 TEST 2: CREATE and INSERT operations');
    await pool.query(
      'CREATE TABLE IF NOT EXISTS test_users (id SERIAL PRIMARY KEY, name TEXT)',
      [],
      { id: 'system', ip: 'localhost' }
    );
    
    await pool.query(
      'INSERT INTO test_users (name) VALUES ($1)',
      ['Alice'],
      { id: 'alice@example.com', ip: '192.168.1.100' }
    );
    console.log('   ✅ Table created and data inserted');

    // TEST 3: Failing query
    console.log('\n📝 TEST 3: Failing query (should log error)');
    console.log('   Context: User "error-test" from IP "127.0.0.1"');
    
    try {
      await pool.query(
        'SELECT * FROM non_existent_table_12345',
        [],
        { id: 'error-test', ip: '127.0.0.1' }
      );
      console.log('   ⚠️ Query should have failed but didn\'t!');
    } catch (error) {
      console.log(`   ✅ Query failed as expected: ${error.message.substring(0, 80)}...`);
    }

    // TEST 4: Query with parameters
    console.log('\n📝 TEST 4: Query with parameters');
    const result2 = await pool.query(
      'SELECT $1::text as greeting, $2::text as name',
      ['Hello', 'DAM Lab'],
      { id: 'student', ip: '10.0.0.5' }
    );
    console.log(`   ✅ Query executed: ${result2.rows[0].greeting}, ${result2.rows[0].name}`);

    // TEST 5: Verify audit entries
    console.log('\n📝 TEST 5: Verifying audit entries');
    const auditResult = await pool.query(
      'SELECT COUNT(*) as count FROM dam_audit_logs',
      [],
      { id: 'system', ip: 'localhost' }
    );
    console.log(`   ✅ Found ${auditResult.rows[0].count} audit entries`);

    console.log('\n✅ All tests completed successfully!');
    console.log('   Check the console output above for audit log entries.');
    console.log('   The dam_audit_logs table should contain records for all queries.');

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await pool.close();
    console.log('\n🔌 Connection pool closed.');
  }
}

testAuditedPool();
```
</details>

### Step 4: Run the Tests

**4.1 Execute the test script:**
```bash
node tests/test-audited-pool.js
```

**4.2 Expected output:**

```
🧪 Testing AuditedPool...

✅ AuditedPool created successfully

📝 TEST 1: Successful SELECT query
   Context: User "test-user" from IP "127.0.0.1"
[DAM AUDIT] 2024-01-15T10:00:00.000Z | User: test-user | IP: 127.0.0.1 | Status: SUCCESS | Duration: 45.20ms | Query: SELECT NOW() as current_time
   ✅ Query returned: 2024-01-15T10:00:00.000Z

📝 TEST 2: CREATE and INSERT operations
[DAM AUDIT] 2024-01-15T10:00:00.100Z | User: system | IP: localhost | Status: SUCCESS | Duration: 12.30ms | Query: CREATE TABLE IF NOT EXISTS test_users...
[DAM AUDIT] 2024-01-15T10:00:00.120Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 8.40ms | Query: INSERT INTO test_users...
   ✅ Table created and data inserted

📝 TEST 3: Failing query (should log error)
   Context: User "error-test" from IP "127.0.0.1"
[DAM AUDIT] 2024-01-15T10:00:00.140Z | User: error-test | IP: 127.0.0.1 | Status: ERROR | Duration: 3.20ms | Query: SELECT * FROM non_existent_table_12345
   ✅ Query failed as expected: relation "non_existent_table_12345" does not exist...

📝 TEST 4: Query with parameters
[DAM AUDIT] 2024-01-15T10:00:00.160Z | User: student | IP: 10.0.0.5 | Status: SUCCESS | Duration: 6.10ms | Query: SELECT $1::text as greeting, $2::text as name
   ✅ Query executed: Hello, DAM Lab

📝 TEST 5: Verifying audit entries
[DAM AUDIT] 2024-01-15T10:00:00.180Z | User: system | IP: localhost | Status: SUCCESS | Duration: 4.50ms | Query: SELECT COUNT(*) as count FROM dam_audit_logs
   ✅ Found 5 audit entries

✅ All tests completed successfully!
   Check the console output above for audit log entries.
   The dam_audit_logs table should contain records for all queries.

🔌 Connection pool closed.
```

### ✅ Verification Checklist

- [ ] All 5 tests pass without errors
- [ ] Console shows `[DAM AUDIT]` entries for each query
- [ ] Successful queries show status `SUCCESS`
- [ ] Failed query shows status `ERROR`
- [ ] User context is captured correctly
- [ ] Duration is measured and logged

---

## Lab 1.2: Python AuditedSQLite

### Objectives
- ✅ Build an `AuditedSQLite` class for SQLite
- ✅ Implement context manager for transactions
- ✅ Create audit table and logs
- ✅ Test the audit system

### Pre-Lab Requirements
- ☐ Python 3.8+ installed
- ☐ Basic understanding of Python context managers

### Estimated Time: 30 minutes

### Step 1: Create the Lab Directory

**1.1 Create the Python lab directory:**
```bash
mkdir -p ~/dam-labs/lab-1-audit/python
cd ~/dam-labs/lab-1-audit/python
```

### Step 2: Implement the AuditedSQLite

**2.1 Create `audited_sqlite.py`:**

<details>
<summary>Click to expand the complete code</summary>

```python
# audited_sqlite.py

import sqlite3
import time
from contextlib import contextmanager
from datetime import datetime, timezone

class AuditedSQLite:
    """
    A wrapper around SQLite connections that provides comprehensive audit logging.
    
    This class intercepts all database operations and logs them with context,
    duration, and status information.
    
    Example:
        >>> db = AuditedSQLite('myapp.db')
        >>> with db.transaction('SELECT * FROM users', user='alice@example.com') as cursor:
        ...     cursor.execute('SELECT * FROM users WHERE id = ?', (123,))
    """
    
    def __init__(self, db_path: str, create_audit_table: bool = True):
        self.db_path = db_path
        if create_audit_table:
            self._init_audit_table()
    
    def _init_audit_table(self):
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS audit_logs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    query TEXT NOT NULL,
                    duration_ms REAL,
                    user TEXT,
                    status TEXT,
                    error TEXT,
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp)")
            conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user)")
            conn.commit()
    
    @contextmanager
    def transaction(self, query: str, user: str = "system"):
        """
        Context manager for transactional queries with audit logging.
        
        Example:
            >>> with db.transaction('Update user', user='admin') as cur:
            ...     cur.execute("UPDATE users SET name = ? WHERE id = ?", ('Alice', 1))
        """
        start = time.perf_counter()
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        status = "SUCCESS"
        error_msg = None

        try:
            yield cursor
            conn.commit()
        except Exception as e:
            conn.rollback()
            status = "ERROR"
            error_msg = str(e)
            raise
        finally:
            duration = (time.perf_counter() - start) * 1000
            cursor.execute(
                """
                INSERT INTO audit_logs (query, duration_ms, user, status, error)
                VALUES (?, ?, ?, ?, ?)
                """,
                (query, duration, user, status, error_msg)
            )
            conn.commit()
            conn.close()
            print(
                f"[DAM AUDIT] {datetime.now(timezone.utc).isoformat()} | "
                f"User: {user} | Status: {status} | "
                f"Duration: {duration:.2f}ms | Query: {query[:200]}..."
            )
    
    def execute(self, query: str, params: tuple = (), user: str = "system"):
        """
        Execute a query with audit logging.
        
        Args:
            query: SQL query string
            params: Query parameters
            user: User identifier
        
        Returns:
            sqlite3.Cursor: The cursor from the executed query
        """
        with self.transaction(query, user) as cursor:
            return cursor.execute(query, params)
    
    def query(self, query: str, params: tuple = (), user: str = "system"):
        """
        Execute a query and return results as dictionaries.
        
        Returns:
            List[Dict[str, Any]]: List of rows as dictionaries
        """
        with self.transaction(query, user) as cursor:
            cursor.execute(query, params)
            columns = [description[0] for description in cursor.description] if cursor.description else []
            return [dict(zip(columns, row)) for row in cursor.fetchall()]
    
    def query_one(self, query: str, params: tuple = (), user: str = "system"):
        """
        Execute a query and return the first row as a dictionary.
        
        Returns:
            Optional[Dict[str, Any]]: The first row as a dictionary, or None if no rows
        """
        results = self.query(query, params, user)
        return results[0] if results else None
    
    def get_audit_logs(self, limit: int = 100):
        """
        Retrieve recent audit logs.
        
        Args:
            limit: Maximum number of logs to return
        
        Returns:
            List[Dict[str, Any]]: List of audit log entries
        """
        return self.query(
            "SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT ?",
            (limit,),
            user="system"
        )
    
    def close(self):
        """Close the database connection."""
        # Connections are managed by the context manager
        pass
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
```
</details>

### Step 3: Create the Test Script

**3.1 Create `test_audited_sqlite.py`:**

```python
# test_audited_sqlite.py

from audited_sqlite import AuditedSQLite
import sqlite3

def test_audited_sqlite():
    print("🧪 Testing AuditedSQLite...\n")
    
    # Use in-memory database for testing
    db = AuditedSQLite(':memory:')
    print("✅ AuditedSQLite created successfully")
    
    try:
        # TEST 1: Create table and insert data
        print("\n📝 TEST 1: Creating table and inserting data")
        db.execute(
            "CREATE TABLE test_users (id INTEGER PRIMARY KEY, name TEXT)",
            user="admin"
        )
        db.execute(
            "INSERT INTO test_users VALUES (1, 'Alice')",
            user="alice@example.com"
        )
        db.execute(
            "INSERT INTO test_users VALUES (2, 'Bob')",
            user="bob@example.com"
        )
        print("   ✅ Table created and data inserted")
        
        # TEST 2: Query data
        print("\n📝 TEST 2: Querying data")
        results = db.query(
            "SELECT * FROM test_users",
            user="viewer"
        )
        print(f"   ✅ Found {len(results)} users: {results}")
        
        # TEST 3: Query with parameters
        print("\n📝 TEST 3: Query with parameters")
        result = db.query_one(
            "SELECT * FROM test_users WHERE id = ?",
            (1,),
            user="viewer"
        )
        print(f"   ✅ Found user: {result['name'] if result else 'None'}")
        
        # TEST 4: Failing query
        print("\n📝 TEST 4: Failing query (should log error)")
        try:
            db.execute(
                "SELECT * FROM non_existent_table",
                user="error-test"
            )
            print("   ⚠️ Query should have failed but didn't!")
        except sqlite3.Error as e:
            print(f"   ✅ Query failed as expected: {str(e)[:60]}...")
        
        # TEST 5: Get audit logs
        print("\n📝 TEST 5: Retrieving audit logs")
        logs = db.get_audit_logs(limit=10)
        print(f"   ✅ Found {len(logs)} audit entries")
        
        for i, log in enumerate(logs[:3], 1):
            print(f"      {i}. {log['user']} | {log['status']} | {log['query'][:50]}...")
        
        print("\n✅ All tests completed successfully!")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
    finally:
        db.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    test_audited_sqlite()
```

### Step 4: Run the Tests

**4.1 Execute the test script:**
```bash
python test_audited_sqlite.py
```

**4.2 Expected output:**

```
🧪 Testing AuditedSQLite...

✅ AuditedSQLite created successfully

📝 TEST 1: Creating table and inserting data
[DAM AUDIT] 2024-01-15T10:00:00.000Z | User: admin | Status: SUCCESS | Duration: 2.50ms | Query: CREATE TABLE test_users...
[DAM AUDIT] 2024-01-15T10:00:00.010Z | User: alice@example.com | Status: SUCCESS | Duration: 1.20ms | Query: INSERT INTO test_users...
[DAM AUDIT] 2024-01-15T10:00:00.020Z | User: bob@example.com | Status: SUCCESS | Duration: 1.10ms | Query: INSERT INTO test_users...
   ✅ Table created and data inserted

📝 TEST 2: Querying data
[DAM AUDIT] 2024-01-15T10:00:00.030Z | User: viewer | Status: SUCCESS | Duration: 0.80ms | Query: SELECT * FROM test_users
   ✅ Found 2 users: [{'id': 1, 'name': 'Alice'}, {'id': 2, 'name': 'Bob'}]

📝 TEST 3: Query with parameters
[DAM AUDIT] 2024-01-15T10:00:00.040Z | User: viewer | Status: SUCCESS | Duration: 0.60ms | Query: SELECT * FROM test_users WHERE id = ?
   ✅ Found user: Alice

📝 TEST 4: Failing query (should log error)
[DAM AUDIT] 2024-01-15T10:00:00.050Z | User: error-test | Status: ERROR | Duration: 0.50ms | Query: SELECT * FROM non_existent_table
   ✅ Query failed as expected: no such table: non_existent_table...

📝 TEST 5: Retrieving audit logs
[DAM AUDIT] 2024-01-15T10:00:00.060Z | User: system | Status: SUCCESS | Duration: 0.70ms | Query: SELECT * FROM audit_logs...
   ✅ Found 8 audit entries
      1. viewer | SUCCESS | SELECT * FROM test_users...
      2. viewer | SUCCESS | SELECT * FROM test_users WHERE id = ?...
      3. error-test | ERROR | SELECT * FROM non_existent_table...

✅ All tests completed successfully!

🔌 Database connection closed.
```

### ✅ Verification Checklist

- [ ] All 5 tests pass without errors
- [ ] Console shows `[DAM AUDIT]` entries for each query
- [ ] Successful queries show status `SUCCESS`
- [ ] Failed query shows status `ERROR`
- [ ] User context is captured correctly
- [ ] Duration is measured and logged

---

## Lab 1.3: Audit Data Verification

### Objectives
- ✅ Verify audit data in the database
- ✅ Query audit logs for analysis
- ✅ Understand audit log structure

### Estimated Time: 15 minutes

### JavaScript Database Verification

**1.1 Connect to Neon and verify audit data:**

```sql
-- Check audit table structure
\d dam_audit_logs

-- Count total entries
SELECT COUNT(*) as total_entries FROM dam_audit_logs;

-- View recent entries
SELECT 
    id,
    user_id,
    status,
    LEFT(query_text, 60) as query_preview,
    duration_ms,
    timestamp
FROM dam_audit_logs 
ORDER BY timestamp DESC 
LIMIT 10;

-- Group by user
SELECT 
    user_id,
    COUNT(*) as query_count,
    AVG(duration_ms) as avg_duration,
    COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as error_count
FROM dam_audit_logs
GROUP BY user_id
ORDER BY query_count DESC;

-- Find slow queries
SELECT 
    user_id,
    LEFT(query_text, 80) as query,
    duration_ms
FROM dam_audit_logs
WHERE duration_ms > 100
ORDER BY duration_ms DESC
LIMIT 5;
```

### Python Database Verification

**1.2 Verify SQLite audit data:**

```bash
# Open the database
sqlite3 test.db

# Check table structure
.schema audit_logs

# Count entries
SELECT COUNT(*) FROM audit_logs;

# View recent entries
SELECT 
    id,
    user,
    status,
    LEFT(query, 60) as query_preview,
    duration_ms,
    timestamp
FROM audit_logs 
ORDER BY timestamp DESC 
LIMIT 10;

# Group by user
SELECT 
    user,
    COUNT(*) as query_count,
    AVG(duration_ms) as avg_duration,
    COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as error_count
FROM audit_logs
GROUP BY user
ORDER BY query_count DESC;

# Exit
.quit
```

---

## Lab 1.4: Lab Report

### Questions to Answer

**1.4.1** What information does the audit trail capture for each query?

**Your Answer:**
_________________________________________________________________

**1.4.2** Why is it important to log both successful and failed queries?

**Your Answer:**
_________________________________________________________________

**1.4.3** How does the JavaScript implementation differ from the Python implementation?

**Your Answer:**
_________________________________________________________________

**1.4.4** What would happen if audit logging failed? Should the query still execute?

**Your Answer:**
_________________________________________________________________

**1.4.5** How would you extend the audit system to capture more information?

**Your Answer:**
_________________________________________________________________

### Troubleshooting Notes

**Issues encountered:**
_________________________________________________________________

**Solutions:**
_________________________________________________________________

---

# LAB 2: IMPLEMENTING INTERCEPTION

## Lab 2.1: JavaScript Driver Interception

### Objectives
- ✅ Implement driver-level interception for PostgreSQL
- ✅ Catch queries that bypass the application layer
- ✅ Test interception coverage

### Pre-Lab Requirements
- ☐ Lab 1.1 completed
- ☐ Node.js environment set up

### Estimated Time: 40 minutes

### Step 1: Create the DriverInterceptor

**1.1 Create `src/driver-interceptor.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/driver-interceptor.js

import pkg from 'pg';
const { Pool, Client } = pkg;

/**
 * Driver-level interceptor for PostgreSQL (pg library)
 * 
 * This module provides interceptors that catch queries at the driver level,
 * before they're sent to the database. This ensures that even queries
 * executed through raw connections are captured and logged.
 */
export class DriverInterceptor {
  constructor(db, options = {}) {
    this.db = db;
    this.options = {
      logAllQueries: true,
      onQuery: null,
      onError: null,
      ...options
    };
    
    this.originalQuery = db.query.bind(db);
    this.interceptedClients = new WeakSet();
    this.install();
  }

  install() {
    if (this.db.constructor === Pool) {
      this.interceptPool();
    } else if (this.db.constructor === Client) {
      this.interceptClient(this.db);
    } else {
      throw new Error('Unsupported database object. Must be Pool or Client.');
    }
    
    console.log('[DRIVER INTERCEPTOR] Installed successfully');
  }

  interceptPool() {
    const self = this;
    const pool = this.db;

    pool.query = async function(...args) {
      let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text || '[non-string query object]';
      let params = typeof args[0] === 'object' && args[0]?.values ? args[0].values : args[1] || [];

      if (self.options.onQuery) {
        try {
          await self.options.onQuery(queryText, params, 'pool');
        } catch (error) {
          if (self.options.onError) {
            self.options.onError(error, queryText, params);
          }
        }
      }

      if (self.options.logAllQueries) {
        console.log(
          `[DRIVER INTERCEPTOR] Pool query intercepted: ${queryText.substring(0, 100)}${queryText.length > 100 ? '...' : ''}`
        );
      }

      return self.originalQuery(...args);
    };

    const originalConnect = pool.connect.bind(pool);
    pool.connect = async function(...args) {
      const client = await originalConnect(...args);
      if (!self.interceptedClients.has(client)) {
        self.interceptClient(client);
        self.interceptedClients.add(client);
      }
      return client;
    };
  }

  interceptClient(client) {
    const self = this;
    const originalClientQuery = client.query.bind(client);

    client.query = async function(...args) {
      let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text || '[non-string query object]';
      let params = typeof args[0] === 'object' && args[0]?.values ? args[0].values : args[1] || [];

      if (self.options.onQuery) {
        try {
          await self.options.onQuery(queryText, params, 'client');
        } catch (error) {
          if (self.options.onError) {
            self.options.onError(error, queryText, params);
          }
        }
      }

      if (self.options.logAllQueries) {
        console.log(
          `[DRIVER INTERCEPTOR] Client query intercepted: ${queryText.substring(0, 100)}${queryText.length > 100 ? '...' : ''}`
        );
      }

      return originalClientQuery(...args);
    };

    self.interceptedClients.add(client);
  }

  uninstall() {
    if (this.db.query) {
      this.db.query = this.originalQuery;
    }
    console.log('[DRIVER INTERCEPTOR] Uninstalled successfully');
  }

  getOriginalQuery() {
    return this.originalQuery;
  }
}
```
</details>

### Step 2: Create EnhancedAuditedPool

**2.1 Create `src/enhanced-audited-pool.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/enhanced-audited-pool.js

import { AuditedPool } from './audited-pool.js';
import { DriverInterceptor } from './driver-interceptor.js';

/**
 * Enhanced AuditedPool with driver-level interception
 * 
 * This extends the base AuditedPool with driver-level interception,
 * providing even more comprehensive query coverage.
 */
export class EnhancedAuditedPool extends AuditedPool {
  constructor(connectionString, options = {}) {
    super(connectionString, options);
    
    this.enhancedOptions = {
      enableDriverInterception: true,
      logRawQueries: true,
      ...options
    };
    
    if (this.enhancedOptions.enableDriverInterception) {
      this.installDriverInterceptor();
    }
  }

  installDriverInterceptor() {
    const underlyingPool = this.getUnderlyingPool();
    
    this.driverInterceptor = new DriverInterceptor(underlyingPool, {
      logAllQueries: this.enhancedOptions.logRawQueries,
      onQuery: (queryText, params, source) => {
        this.logAudit({
          query_text: `[DRIVER] ${queryText}`,
          query_params: params,
          duration_ms: 0,
          user_id: 'driver-interceptor',
          user_ip: 'internal',
          status: 'INTERCEPTED',
          error_message: null
        });
        
        console.log(`[DRIVER-INTERCEPTED] Query from ${source}: ${queryText.substring(0, 80)}...`);
      },
      onError: (error, queryText, params) => {
        console.error('[DRIVER INTERCEPTOR ERROR]', error.message);
        console.error('  Query:', queryText);
        console.error('  Params:', params);
      }
    });
    
    console.log('[ENHANCED AUDITED POOL] Driver interceptor installed');
  }

  async close() {
    if (this.driverInterceptor) {
      this.driverInterceptor.uninstall();
    }
    await super.close();
  }
}
```
</details>

### Step 3: Test the Interceptor

**3.1 Create `tests/test-driver-interception.js`:**

<details>
<summary>Click to expand the test code</summary>

```javascript
// tests/test-driver-interception.js

import 'dotenv/config';
import { EnhancedAuditedPool } from '../src/enhanced-audited-pool.js';
import { DriverInterceptor } from '../src/driver-interceptor.js';

async function testDriverInterception() {
  console.log('🧪 Testing Driver-Level Interception...\n');

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    process.exit(1);
  }

  const pool = new EnhancedAuditedPool(databaseUrl);
  console.log('✅ EnhancedAuditedPool created');
  console.log('   - Application-layer audit: Active');
  console.log('   - Driver-layer interception: Active\n');

  try {
    // TEST 1: Query through the audited pool
    console.log('📝 TEST 1: Query through AuditedPool');
    console.log('   This query should be caught by BOTH application and driver layers');
    
    await pool.query(
      'CREATE TABLE IF NOT EXISTS interception_test (id SERIAL PRIMARY KEY, name TEXT)',
      [],
      { id: 'test-user', ip: '127.0.0.1' }
    );
    console.log('   ✅ Query executed through AuditedPool');

    // TEST 2: Query through a raw connection
    console.log('\n📝 TEST 2: Query through raw connection');
    console.log('   This query should ONLY be caught by the driver layer');
    console.log('   (It bypasses the AuditedPool entirely)');
    
    const underlyingPool = pool.getUnderlyingPool();
    const rawClient = await underlyingPool.connect();
    try {
      await rawClient.query('INSERT INTO interception_test (name) VALUES ($1)', ['Raw connection test']);
      console.log('   ✅ Query executed through raw connection');
    } finally {
      rawClient.release();
    }

    // TEST 3: Query through a direct client
    console.log('\n📝 TEST 3: Query through direct client');
    console.log('   This query should be caught by driver layer');
    
    const directClient = new Pool({ connectionString: databaseUrl });
    try {
      const clientInterceptor = new DriverInterceptor(directClient, {
        logAllQueries: true
      });
      
      await directClient.query('INSERT INTO interception_test (name) VALUES ($1)', ['Direct client test']);
      console.log('   ✅ Query executed through direct client');
    } finally {
      await directClient.end();
    }

    // TEST 4: Verify interception
    console.log('\n📝 TEST 4: Verifying interception coverage');
    
    const auditCheck = await pool.query(
      `
      SELECT 
        query_text,
        user_id,
        status
      FROM dam_audit_logs
      WHERE query_text LIKE '%interception_test%'
      OR query_text LIKE '%[DRIVER]%'
      ORDER BY timestamp DESC
      `,
      [],
      { id: 'system', ip: 'localhost' }
    );

    console.log(`\n📊 Found ${auditCheck.rows.length} audit entries related to interception tests:`);
    auditCheck.rows.forEach((row, index) => {
      console.log(`\n${index + 1}. ${row.query_text.substring(0, 80)}...`);
      console.log(`   User: ${row.user_id}`);
      console.log(`   Status: ${row.status}`);
    });

    console.log('\n✅ All tests completed successfully!');
    console.log('   Check the console output above for driver interception entries.');
    console.log('   The driver layer should have captured all queries, including raw connections.');

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await pool.close();
    console.log('\n🔌 Connection pool closed.');
  }
}

testDriverInterception();
```
</details>

### Step 4: Run the Tests

**4.1 Execute the test script:**
```bash
node tests/test-driver-interception.js
```

### ✅ Verification Checklist

- [ ] Queries through AuditedPool are caught by both layers
- [ ] Raw connection queries are caught by driver layer
- [ ] Direct client queries are caught by driver layer
- [ ] All queries appear in audit logs
- [ ] No queries bypass interception

---

## Lab 2.2: Python Native Interception

### Objectives
- ✅ Implement native-level interception for SQLite
- ✅ Use `sqlite3_trace` for C-level interception
- ✅ Catch queries that bypass the application layer

### Pre-Lab Requirements
- ☐ Lab 1.2 completed
- ☐ Python 3.8+ installed

### Estimated Time: 30 minutes

### Step 1: Create the NativeInterceptor

**1.1 Create `native_interceptor.py`:**

<details>
<summary>Click to expand the complete code</summary>

```python
# native_interceptor.py

import sqlite3
from typing import Callable, Optional

class NativeInterceptor:
    """
    Native-level interceptor for SQLite connections.
    
    Uses the sqlite3_trace API to intercept all SQL statements at the
    C-level before they're executed. This provides the lowest-level
    interception possible in SQLite.
    
    Example:
        >>> conn = sqlite3.connect('database.db')
        >>> interceptor = NativeInterceptor(conn)
        >>> interceptor.set_callback(lambda sql: print(f'Query: {sql}'))
        >>> conn.execute('SELECT * FROM users')
        Query: SELECT * FROM users
    """
    
    def __init__(self, connection: sqlite3.Connection):
        self.connection = connection
        self._callback = None
        self._original_trace = None
        self._installed = False
    
    def set_callback(self, callback: Callable[[str], None]) -> None:
        self._callback = callback
        self._install()
    
    def _install(self) -> None:
        if self._installed:
            return
        
        def trace_callback(sql: str) -> None:
            if self._callback:
                try:
                    self._callback(sql)
                except Exception as e:
                    print(f"[NATIVE INTERCEPTOR ERROR] Callback failed: {e}")
        
        self.connection.set_trace_callback(trace_callback)
        self._installed = True
        print("[NATIVE INTERCEPTOR] Installed successfully")
    
    def uninstall(self) -> None:
        if self._installed:
            self.connection.set_trace_callback(self._original_trace)
            self._installed = False
            print("[NATIVE INTERCEPTOR] Uninstalled successfully")
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.uninstall()
```
</details>

### Step 2: Create AuditedNativeSQLite

**2.1 Create `audited_native_sqlite.py`:**

```python
# audited_native_sqlite.py

import sqlite3
from datetime import datetime, timezone
from native_interceptor import NativeInterceptor

class AuditedNativeSQLite:
    """
    An extended SQLite connection with both application and native interception.
    
    This class combines:
    1. Application-layer audit
    2. Native-level interception
    
    Providing comprehensive coverage for all SQL operations.
    """
    
    def __init__(self, db_path: str):
        self.db_path = db_path
        self.connection = sqlite3.connect(db_path, check_same_thread=False)
        self.connection.execute("PRAGMA foreign_keys = ON")
        self.interceptor = None
        
        # Create native audit table
        self.connection.execute("""
            CREATE TABLE IF NOT EXISTS native_audit_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                sql_statement TEXT NOT NULL,
                captured_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                source TEXT DEFAULT 'native'
            )
        """)
        self.connection.commit()
    
    def _native_audit_callback(self, sql: str) -> None:
        """Callback for native interception - logs queries to the audit table."""
        self.connection.execute(
            "INSERT INTO native_audit_logs (sql_statement, source) VALUES (?, ?)",
            (sql, 'native_interceptor')
        )
        self.connection.commit()
        
        timestamp = datetime.now(timezone.utc).isoformat()
        print(
            f"[NATIVE AUDIT] {timestamp} | Query: {sql[:100]}{'...' if len(sql) > 100 else ''}"
        )
    
    def enable_native_interception(self) -> None:
        self.interceptor = NativeInterceptor(self.connection)
        self.interceptor.set_callback(self._native_audit_callback)
        print("[AUDITED NATIVE SQLITE] Native interception enabled")
    
    def disable_native_interception(self) -> None:
        if self.interceptor:
            self.interceptor.uninstall()
            self.interceptor = None
            print("[AUDITED NATIVE SQLITE] Native interception disabled")
    
    def execute(self, sql: str, params: tuple = ()) -> sqlite3.Cursor:
        """Execute a SQL statement with application-layer audit."""
        print(f"[APP AUDIT] Executing: {sql[:100]}{'...' if len(sql) > 100 else ''}")
        cursor = self.connection.execute(sql, params)
        self.connection.commit()
        return cursor
    
    def get_native_audit_logs(self, limit: int = 100):
        cursor = self.connection.execute(
            "SELECT sql_statement, captured_at, source FROM native_audit_logs ORDER BY captured_at DESC LIMIT ?",
            (limit,)
        )
        return cursor.fetchall()
    
    def close(self) -> None:
        if self.interceptor:
            self.interceptor.uninstall()
        if self.connection:
            self.connection.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
```

### Step 3: Test Native Interception

**3.1 Create `test_native_interception.py`:**

```python
# test_native_interception.py

import sqlite3
from native_interceptor import NativeInterceptor
from audited_native_sqlite import AuditedNativeSQLite

def test_native_interception():
    print("🧪 Testing Native-Level Interception...\n")
    
    # Create a test database in memory
    conn = sqlite3.connect(':memory:')
    conn.execute("CREATE TABLE test (id INTEGER, name TEXT)")
    conn.commit()
    
    intercepted_queries = []
    
    def interceptor_callback(sql: str) -> None:
        intercepted_queries.append(sql)
        print(f"[INTERCEPTED] {sql[:100]}{'...' if len(sql) > 100 else ''}")
    
    print("📝 Installing native interceptor...")
    interceptor = NativeInterceptor(conn)
    interceptor.set_callback(interceptor_callback)
    
    try:
        # TEST 1: Direct query
        print("\n📝 TEST 1: Direct query through connection")
        conn.execute("INSERT INTO test VALUES (1, 'Alice')")
        conn.commit()
        print("   ✅ Direct query executed")
        
        # TEST 2: Parameterized query
        print("\n📝 TEST 2: Query with parameters")
        conn.execute("INSERT INTO test VALUES (?, ?)", (2, 'Bob'))
        conn.commit()
        print("   ✅ Parameterized query executed")
        
        # TEST 3: SELECT query
        print("\n📝 TEST 3: SELECT query")
        cursor = conn.execute("SELECT * FROM test WHERE id = ?", (1,))
        results = cursor.fetchall()
        print(f"   ✅ SELECT query returned {len(results)} rows")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
    finally:
        interceptor.uninstall()
        conn.close()
    
    print(f"\n📊 Intercepted {len(intercepted_queries)} queries:")
    for idx, query in enumerate(intercepted_queries, 1):
        print(f"{idx}. {query[:80]}{'...' if len(query) > 80 else ''}")
    
    print("\n✅ All tests completed!")

def test_audited_native_sqlite():
    print("\n" + "="*60)
    print("🧪 Testing AuditedNativeSQLite")
    print("="*60 + "\n")
    
    with AuditedNativeSQLite(':memory:') as db:
        db.enable_native_interception()
        
        db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
        db.execute("INSERT INTO users (name) VALUES (?)", ('Alice',))
        db.execute("INSERT INTO users (name) VALUES (?)", ('Bob',))
        
        cursor = db.connection.execute("SELECT * FROM users")
        rows = cursor.fetchall()
        print(f"Found {len(rows)} users")
        
        logs = db.get_native_audit_logs(10)
        print(f"\nNative audit logs: {len(logs)} entries")
        
        for log in logs[:5]:
            print(f"  - {log[0][:60]}...")
        
        print("\n✅ AuditedNativeSQLite test completed")

if __name__ == "__main__":
    test_native_interception()
    test_audited_native_sqlite()
```

### Step 4: Run the Tests

**4.1 Execute the test scripts:**
```bash
python test_native_interception.py
```

### ✅ Verification Checklist

- [ ] Native interceptor installed successfully
- [ ] All queries intercepted at C-level
- [ ] Application-layer audit works with native interception
- [ ] Native audit logs are created
- [ ] Queries that bypass application are caught

---

# LAB 3: IMPLEMENTING NORMALIZATION

## Lab 3.1: JavaScript QueryNormalizer

### Objectives
- ✅ Implement query normalization for PostgreSQL
- ✅ Create fingerprint generation
- ✅ Test normalization patterns

### Pre-Lab Requirements
- ☐ Lab 1.1 completed
- ☐ Node.js environment set up

### Estimated Time: 35 minutes

### Step 1: Create the QueryNormalizer

**1.1 Create `src/normalizer.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/normalizer.js

export class QueryNormalizer {
  constructor(options = {}) {
    this.options = {
      caseInsensitive: false,
      preserveComments: false,
      normalizeInClauses: true,
      ...options
    };
  }

  normalize(sql) {
    if (!sql || typeof sql !== 'string') {
      return '';
    }

    let normalized = sql;

    if (!this.options.preserveComments) {
      normalized = this.removeComments(normalized);
    }

    normalized = this.replaceStringLiterals(normalized);
    normalized = this.replaceNumericLiterals(normalized);
    normalized = this.replaceUuidLiterals(normalized);
    normalized = this.replaceJsonLiterals(normalized);

    if (this.options.normalizeInClauses) {
      normalized = this.normalizeInClauses(normalized);
    }

    normalized = this.collapseWhitespace(normalized);

    if (this.options.caseInsensitive) {
      normalized = normalized.toLowerCase();
    }

    return normalized.trim();
  }

  removeComments(sql) {
    let result = sql.replace(/\/\*[\s\S]*?\*\//g, '');
    const lines = result.split('\n');
    const cleanedLines = lines.map(line => {
      const commentIndex = line.indexOf('--');
      if (commentIndex !== -1) {
        return line.substring(0, commentIndex);
      }
      return line;
    });
    return cleanedLines.join(' ');
  }

  replaceStringLiterals(sql) {
    let result = sql.replace(/'[^']*(?:''[^']*)*'/g, "'?'");
    
    const identifiers = [];
    result = result.replace(/"[^"]*"/g, (match) => {
      identifiers.push(match);
      return `__IDENTIFIER_${identifiers.length - 1}__`;
    });
    
    result = result.replace(/"[^"]*"/g, "'?'");
    
    identifiers.forEach((id, index) => {
      result = result.replace(`__IDENTIFIER_${index}__`, id);
    });
    
    return result;
  }

  replaceNumericLiterals(sql) {
    return sql.replace(/\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b/g, '?');
  }

  replaceUuidLiterals(sql) {
    const uuidPattern = /'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'/gi;
    return sql.replace(uuidPattern, "'?'");
  }

  replaceJsonLiterals(sql) {
    const jsonPattern = /'\{[^']*?\}'/g;
    return sql.replace(jsonPattern, "'?'");
  }

  normalizeInClauses(sql) {
    let result = sql;
    const inClausePattern = /\bIN\s*\(([^)]*)\)/gi;
    
    result = result.replace(inClausePattern, (match, contents) => {
      const items = contents.split(',').filter(item => item.trim().length > 0);
      if (items.length > 1) {
        const placeholders = items.map(() => '?').join(', ');
        return `IN (${placeholders})`;
      }
      return match;
    });
    
    return result;
  }

  collapseWhitespace(sql) {
    return sql
      .replace(/\s+/g, ' ')
      .replace(/\s*\(\s*/g, '(')
      .replace(/\s*\)\s*/g, ')')
      .replace(/\s*,\s*/g, ', ')
      .replace(/\s*=\s*/g, ' = ')
      .replace(/\s*>\s*/g, ' > ')
      .replace(/\s*<\s*/g, ' < ')
      .trim();
  }

  fingerprint(normalized) {
    const crypto = require('crypto');
    return crypto
      .createHash('sha256')
      .update(normalized)
      .digest('hex')
      .substring(0, 16);
  }

  countPlaceholders(normalized) {
    return (normalized.match(/\?/g) || []).length;
  }

  areStructurallyIdentical(sql1, sql2) {
    const norm1 = this.normalize(sql1);
    const norm2 = this.normalize(sql2);
    return norm1 === norm2;
  }

  analyzeStructure(sql) {
    const normalized = this.normalize(sql);
    const placeholders = this.countPlaceholders(normalized);
    const queryTypeMatch = normalized.match(/^\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|TRUNCATE|GRANT|REVOKE)/i);
    const queryType = queryTypeMatch ? queryTypeMatch[1].toUpperCase() : 'UNKNOWN';
    
    return {
      original: sql,
      normalized: normalized,
      fingerprint: this.fingerprint(normalized),
      placeholders: placeholders,
      queryType: queryType,
      length: normalized.length
    };
  }
}
```
</details>

### Step 2: Test the Normalizer

**2.1 Create `tests/test-normalizer.js`:**

<details>
<summary>Click to expand the test code</summary>

```javascript
// tests/test-normalizer.js

import { QueryNormalizer, normalizeQuery, areQueriesIdentical } from '../src/normalizer.js';

function testNormalizer() {
  console.log('🧪 Testing Query Normalizer...\n');
  
  const normalizer = new QueryNormalizer();
  
  const testCases = [
    ["SELECT * FROM users WHERE email = 'alice@example.com'",
     "SELECT * FROM users WHERE email = '?'"],
    ["SELECT * FROM products WHERE price > 100 AND stock < 50",
     "SELECT * FROM products WHERE price > ? AND stock < ?"],
    ["INSERT INTO users (name, email, age) VALUES ('Alice', 'alice@example.com', 30)",
     "INSERT INTO users (name, email, age) VALUES ('?', '?', ?)"],
    ["UPDATE products SET price = 29.99, stock = 100 WHERE id = 123",
     "UPDATE products SET price = ?, stock = ? WHERE id = ?"],
    ["DELETE FROM users WHERE last_login < '2024-01-01' AND status = 'inactive'",
     "DELETE FROM users WHERE last_login < '?' AND status = '?'"],
    ["SELECT * FROM users WHERE id IN (1, 2, 3, 4, 5)",
     "SELECT * FROM users WHERE id IN (?, ?, ?, ?, ?)"],
    ["SELECT\n  *\nFROM\n  users\nWHERE\n  id = 123",
     "SELECT * FROM users WHERE id = ?"]
  ];
  
  let passed = 0;
  testCases.forEach(([raw, expected], index) => {
    const normalized = normalizer.normalize(raw);
    const isMatch = normalized === expected;
    
    console.log(`\n📝 Test ${index + 1}:`);
    console.log(`   Raw:   ${raw.substring(0, 60)}${raw.length > 60 ? '...' : ''}`);
    console.log(`   Norm:  ${normalized}`);
    console.log(`   Expected: ${expected}`);
    console.log(`   ${isMatch ? '✅ PASS' : '❌ FAIL'}`);
    
    if (isMatch) passed++;
  });
  
  console.log(`\n📊 Results: ${passed} passed, ${testCases.length - passed} failed`);
  
  // Structural comparison tests
  console.log('\n📝 Structural Comparison Tests:');
  
  const identicalQueries = [
    "SELECT * FROM users WHERE email = 'alice@example.com'",
    "SELECT * FROM users WHERE email = 'bob@example.com'"
  ];
  const isIdentical = normalizer.areStructurallyIdentical(identicalQueries[0], identicalQueries[1]);
  console.log(`   Queries structurally identical? ${isIdentical ? '✅ Yes' : '❌ No'}`);
  
  const differentQueries = [
    "SELECT * FROM users WHERE email = 'alice@example.com'",
    "SELECT * FROM products WHERE price > 100"
  ];
  const isDifferent = !normalizer.areStructurallyIdentical(differentQueries[0], differentQueries[1]);
  console.log(`   Queries structurally different? ${isDifferent ? '✅ Yes' : '❌ No'}`);
  
  // Fingerprint tests
  console.log('\n📝 Fingerprint Generation:');
  const sql1 = "SELECT * FROM users WHERE id = 1";
  const sql2 = "SELECT * FROM users WHERE id = 2";
  const norm1 = normalizer.normalize(sql1);
  const norm2 = normalizer.normalize(sql2);
  const fp1 = normalizer.fingerprint(norm1);
  const fp2 = normalizer.fingerprint(norm2);
  
  console.log(`   Query 1: ${sql1}`);
  console.log(`   Query 2: ${sql2}`);
  console.log(`   Fingerprint 1: ${fp1}`);
  console.log(`   Fingerprint 2: ${fp2}`);
  console.log(`   Fingerprints match? ${fp1 === fp2 ? '✅ Yes' : '❌ No'}`);
  
  // Analysis
  console.log('\n📝 Query Analysis:');
  const analysis = normalizer.analyzeStructure(
    "SELECT name, email FROM users WHERE age > 21 AND status = 'active'"
  );
  console.log(`   Query Type: ${analysis.queryType}`);
  console.log(`   Placeholders: ${analysis.placeholders}`);
  console.log(`   Fingerprint: ${analysis.fingerprint}`);
  console.log(`   Normalized: ${analysis.normalized}`);
  
  return { passed, failed: testCases.length - passed };
}

testNormalizer();
```
</details>

### Step 3: Run the Tests

**3.1 Execute the test script:**
```bash
node tests/test-normalizer.js
```

### ✅ Verification Checklist

- [ ] All test cases pass
- [ ] String literals are replaced with `'?'`
- [ ] Numeric literals are replaced with `?`
- [ ] IN clauses are normalized
- [ ] Whitespace is collapsed
- [ ] Fingerprints are generated
- [ ] Structural comparison works

---

## Lab 3.2: Python QueryNormalizer

### Objectives
- ✅ Implement query normalization for SQLite
- ✅ Create fingerprint generation
- ✅ Test normalization patterns

### Pre-Lab Requirements
- ☐ Lab 1.2 completed
- ☐ Python 3.8+ installed

### Estimated Time: 30 minutes

### Step 1: Create the QueryNormalizer

**1.1 Create `normalizer.py`:**

<details>
<summary>Click to expand the complete code</summary>

```python
# normalizer.py

import re
import hashlib
from typing import Dict, Any, Optional

class NormalizationOptions:
    def __init__(self, 
                 case_insensitive: bool = False,
                 preserve_comments: bool = False,
                 normalize_in_clauses: bool = True,
                 normalize_uuid: bool = True,
                 normalize_json: bool = True,
                 collapse_whitespace: bool = True):
        self.case_insensitive = case_insensitive
        self.preserve_comments = preserve_comments
        self.normalize_in_clauses = normalize_in_clauses
        self.normalize_uuid = normalize_uuid
        self.normalize_json = normalize_json
        self.collapse_whitespace = collapse_whitespace

class QueryNormalizer:
    def __init__(self, options: Optional[NormalizationOptions] = None):
        self.options = options or NormalizationOptions()
        self._compile_patterns()
    
    def _compile_patterns(self):
        self.string_literal_pattern = re.compile(
            r"'[^']*(?:''[^']*)*'",
            re.DOTALL
        )
        self.numeric_pattern = re.compile(
            r'\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b'
        )
        self.uuid_pattern = re.compile(
            r"'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'",
            re.IGNORECASE
        )
        self.json_pattern = re.compile(r"'\{[^']*?\}'")
        self.in_clause_pattern = re.compile(r'\bIN\s*\(([^)]*)\)', re.IGNORECASE)
        self.whitespace_pattern = re.compile(r'\s+')
        self.multi_comment_pattern = re.compile(r'/\*[\s\S]*?\*/')
        self.single_comment_pattern = re.compile(r'--[^\n]*')
    
    def normalize(self, sql: str) -> str:
        if not sql or not isinstance(sql, str):
            return ''
        
        normalized = sql
        
        if not self.options.preserve_comments:
            normalized = self._remove_comments(normalized)
        
        normalized = self._replace_string_literals(normalized)
        normalized = self._replace_numeric_literals(normalized)
        
        if self.options.normalize_uuid:
            normalized = self._replace_uuid_literals(normalized)
        
        if self.options.normalize_json:
            normalized = self._replace_json_literals(normalized)
        
        if self.options.normalize_in_clauses:
            normalized = self._normalize_in_clauses(normalized)
        
        if self.options.collapse_whitespace:
            normalized = self._collapse_whitespace(normalized)
        
        if self.options.case_insensitive:
            normalized = normalized.lower()
        
        return normalized.strip()
    
    def _remove_comments(self, sql: str) -> str:
        result = self.multi_comment_pattern.sub('', sql)
        result = self.single_comment_pattern.sub('', result)
        return result
    
    def _replace_string_literals(self, sql: str) -> str:
        identifiers = []
        def protect_identifier(match):
            identifiers.append(match.group(0))
            return f'__IDENTIFIER_{len(identifiers) - 1}__'
        
        protected_sql = re.sub(r'"[^"]*"', protect_identifier, sql)
        protected_sql = self.string_literal_pattern.sub("'?'", protected_sql)
        
        for idx, identifier in enumerate(identifiers):
            protected_sql = protected_sql.replace(f'__IDENTIFIER_{idx}__', identifier)
        
        return protected_sql
    
    def _replace_numeric_literals(self, sql: str) -> str:
        return self.numeric_pattern.sub('?', sql)
    
    def _replace_uuid_literals(self, sql: str) -> str:
        return self.uuid_pattern.sub("'?'", sql)
    
    def _replace_json_literals(self, sql: str) -> str:
        return self.json_pattern.sub("'?'", sql)
    
    def _normalize_in_clauses(self, sql: str) -> str:
        def replace_in_clause(match):
            contents = match.group(1)
            items = [item.strip() for item in contents.split(',') if item.strip()]
            if len(items) > 1:
                placeholders = ', '.join(['?'] * len(items))
                return f'IN ({placeholders})'
            return match.group(0)
        
        return self.in_clause_pattern.sub(replace_in_clause, sql)
    
    def _collapse_whitespace(self, sql: str) -> str:
        result = self.whitespace_pattern.sub(' ', sql)
        result = result.replace(' (', '(')
        result = result.replace('( ', '(')
        result = result.replace(' )', ')')
        result = result.replace(') ', ')')
        result = re.sub(r'\s*=\s*', ' = ', result)
        result = re.sub(r'\s*,\s*', ', ', result)
        return result.strip()
    
    def fingerprint(self, normalized: str) -> str:
        hash_bytes = hashlib.sha256(normalized.encode('utf-8')).digest()
        return hash_bytes.hex()[:16]
    
    def count_placeholders(self, normalized: str) -> int:
        return normalized.count('?')
    
    def are_structurally_identical(self, sql1: str, sql2: str) -> bool:
        norm1 = self.normalize(sql1)
        norm2 = self.normalize(sql2)
        return norm1 == norm2
    
    def analyze_structure(self, sql: str) -> Dict[str, Any]:
        normalized = self.normalize(sql)
        placeholders = self.count_placeholders(normalized)
        query_type_match = re.match(
            r'^\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|TRUNCATE|GRANT|REVOKE)',
            normalized,
            re.IGNORECASE
        )
        query_type = query_type_match.group(1).upper() if query_type_match else 'UNKNOWN'
        
        return {
            'original': sql,
            'normalized': normalized,
            'fingerprint': self.fingerprint(normalized),
            'placeholders': placeholders,
            'query_type': query_type,
            'length': len(normalized)
        }
```
</details>

### Step 2: Test the Normalizer

**2.1 Create `test_normalizer.py`:**

```python
# test_normalizer.py

from normalizer import QueryNormalizer, NormalizationOptions

def test_normalizer():
    print("🧪 Testing Query Normalizer...\n")
    
    normalizer = QueryNormalizer()
    
    test_cases = [
        ("SELECT * FROM users WHERE email = 'alice@example.com'",
         "SELECT * FROM users WHERE email = '?'"),
        ("SELECT * FROM products WHERE price > 100 AND stock < 50",
         "SELECT * FROM products WHERE price > ? AND stock < ?"),
        ("INSERT INTO users (name, email, age) VALUES ('Alice', 'alice@example.com', 30)",
         "INSERT INTO users (name, email, age) VALUES ('?', '?', ?)"),
        ("UPDATE products SET price = 29.99, stock = 100 WHERE id = 123",
         "UPDATE products SET price = ?, stock = ? WHERE id = ?"),
        ("DELETE FROM users WHERE last_login < '2024-01-01' AND status = 'inactive'",
         "DELETE FROM users WHERE last_login < '?' AND status = '?'"),
        ("SELECT * FROM users WHERE id IN (1, 2, 3, 4, 5)",
         "SELECT * FROM users WHERE id IN (?, ?, ?, ?, ?)"),
        ("SELECT\n  *\nFROM\n  users\nWHERE\n  id = 123",
         "SELECT * FROM users WHERE id = ?")
    ]
    
    passed = 0
    for idx, (raw, expected) in enumerate(test_cases, 1):
        normalized = normalizer.normalize(raw)
        is_match = normalized == expected
        
        print(f"\n📝 Test {idx}:")
        print(f"   Raw:   {raw[:60]}{'...' if len(raw) > 60 else ''}")
        print(f"   Norm:  {normalized}")
        print(f"   Expected: {expected}")
        print(f"   {'✅ PASS' if is_match else '❌ FAIL'}")
        
        if is_match:
            passed += 1
    
    print(f"\n📊 Results: {passed} passed, {len(test_cases) - passed} failed")
    
    # Structural comparison tests
    print("\n📝 Structural Comparison Tests:")
    
    identical_queries = [
        "SELECT * FROM users WHERE email = 'alice@example.com'",
        "SELECT * FROM users WHERE email = 'bob@example.com'"
    ]
    is_identical = normalizer.are_structurally_identical(identical_queries[0], identical_queries[1])
    print(f"   Queries structurally identical? {'✅ Yes' if is_identical else '❌ No'}")
    
    different_queries = [
        "SELECT * FROM users WHERE email = 'alice@example.com'",
        "SELECT * FROM products WHERE price > 100"
    ]
    is_different = not normalizer.are_structurally_identical(different_queries[0], different_queries[1])
    print(f"   Queries structurally different? {'✅ Yes' if is_different else '❌ No'}")
    
    # Fingerprint tests
    print("\n📝 Fingerprint Generation:")
    sql1 = "SELECT * FROM users WHERE id = 1"
    sql2 = "SELECT * FROM users WHERE id = 2"
    norm1 = normalizer.normalize(sql1)
    norm2 = normalizer.normalize(sql2)
    fp1 = normalizer.fingerprint(norm1)
    fp2 = normalizer.fingerprint(norm2)
    
    print(f"   Query 1: {sql1}")
    print(f"   Query 2: {sql2}")
    print(f"   Fingerprint 1: {fp1}")
    print(f"   Fingerprint 2: {fp2}")
    print(f"   Fingerprints match? {'✅ Yes' if fp1 == fp2 else '❌ No'}")
    
    # Analysis
    print("\n📝 Query Analysis:")
    analysis = normalizer.analyze_structure(
        "SELECT name, email FROM users WHERE age > 21 AND status = 'active'"
    )
    print(f"   Query Type: {analysis['query_type']}")
    print(f"   Placeholders: {analysis['placeholders']}")
    print(f"   Fingerprint: {analysis['fingerprint']}")
    print(f"   Normalized: {analysis['normalized']}")

if __name__ == "__main__":
    test_normalizer()
```

### Step 3: Run the Tests

**3.1 Execute the test script:**
```bash
python test_normalizer.py
```

### ✅ Verification Checklist

- [ ] All test cases pass
- [ ] String literals are replaced with `'?'`
- [ ] Numeric literals are replaced with `?`
- [ ] IN clauses are normalized
- [ ] Whitespace is collapsed
- [ ] Fingerprints are generated
- [ ] Structural comparison works

---

# LAB 4: IMPLEMENTING THREAT DETECTION

## Lab 4.1: JavaScript ThreatDetector

### Objectives
- ✅ Implement threat detection engine
- ✅ Create default security rules
- ✅ Test SQL injection detection

### Pre-Lab Requirements
- ☐ Labs 1.1 and 3.1 completed
- ☐ Node.js environment set up

### Estimated Time: 40 minutes

### Step 1: Create the ThreatDetector

**1.1 Create `src/threat-detector.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/threat-detector.js

import { QueryNormalizer } from './normalizer.js';

export const ThreatLevel = {
  LOW: 'LOW',
  MEDIUM: 'MEDIUM',
  HIGH: 'HIGH',
  CRITICAL: 'CRITICAL'
};

export const ThreatCategory = {
  SQL_INJECTION: 'SQL_INJECTION',
  DDL_OPERATION: 'DDL_OPERATION',
  PRIVILEGE_ESCALATION: 'PRIVILEGE_ESCALATION',
  DATA_EXFILTRATION: 'DATA_EXFILTRATION',
  BRUTE_FORCE: 'BRUTE_FORCE',
  SUSPICIOUS_PATTERN: 'SUSPICIOUS_PATTERN'
};

export const RuleType = {
  BLOCK: 'BLOCK',
  WARN: 'WARN',
  LOG: 'LOG',
  SCORE: 'SCORE'
};

export class ThreatDetector {
  constructor(options = {}) {
    this.options = {
      enablePatternMatching: true,
      enableHeuristics: true,
      enableThreatScoring: true,
      logAllDetections: true,
      ...options
    };
    
    this.normalizer = new QueryNormalizer({
      caseInsensitive: true,
      preserveComments: false,
      normalizeInClauses: true
    });
    
    this.rules = [];
    this.loadDefaultRules();
    
    this.sensitiveTables = [
      'users', 'passwords', 'credentials', 'secrets',
      'customers', 'employees', 'patients', 'medical',
      'credit_cards', 'payment', 'banking', 'financial',
      'admin', 'administrator', 'root', 'system'
    ];
    
    this.whitelist = [];
    this.loadDefaultWhitelist();
    
    this.detectionHistory = new Map();
    this.historyMaxSize = 1000;
  }

  loadDefaultRules() {
    // SQL Injection Rules
    this.addRule({
      id: 'sqli_tautology',
      name: 'Tautology SQL Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.HIGH,
      type: RuleType.BLOCK,
      pattern: /OR\s+['"]?1['"]?\s*=\s*['"]?1/i,
      description: 'Detects tautology attempts (OR 1=1)'
    });
    
    this.addRule({
      id: 'sqli_union',
      name: 'Union SQL Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /UNION\s+SELECT/i,
      description: 'Detects UNION SELECT injection attempts'
    });
    
    this.addRule({
      id: 'sqli_stacked',
      name: 'Stacked Query Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /;\s*(DROP|DELETE|UPDATE|INSERT|TRUNCATE|CREATE|ALTER)/i,
      description: 'Detects stacked query injection attempts'
    });
    
    this.addRule({
      id: 'sqli_comment',
      name: 'Comment Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.HIGH,
      type: RuleType.BLOCK,
      pattern: /--/,
      description: 'Detects SQL comment injection'
    });

    // DDL Operation Rules
    this.addRule({
      id: 'ddl_drop_table',
      name: 'DROP TABLE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /DROP\s+TABLE/i,
      description: 'Detects DROP TABLE operations'
    });
    
    this.addRule({
      id: 'ddl_drop_database',
      name: 'DROP DATABASE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /DROP\s+DATABASE/i,
      description: 'Detects DROP DATABASE operations'
    });
    
    this.addRule({
      id: 'ddl_truncate',
      name: 'TRUNCATE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /TRUNCATE\s+TABLE/i,
      description: 'Detects TRUNCATE TABLE operations'
    });
    
    this.addRule({
      id: 'ddl_alter',
      name: 'ALTER TABLE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.HIGH,
      type: RuleType.WARN,
      pattern: /ALTER\s+TABLE/i,
      description: 'Detects ALTER TABLE operations (can be dangerous)'
    });

    // Privilege Escalation Rules
    this.addRule({
      id: 'priv_grant',
      name: 'GRANT Privilege Attempt',
      category: ThreatCategory.PRIVILEGE_ESCALATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /GRANT\s+/i,
      description: 'Detects GRANT operations (potential privilege escalation)'
    });

    // Data Exfiltration Rules
    this.addRule({
      id: 'exfil_select_star',
      name: 'SELECT * with No Filter',
      category: ThreatCategory.DATA_EXFILTRATION,
      severity: ThreatLevel.MEDIUM,
      type: RuleType.WARN,
      pattern: /SELECT\s+\*\s+FROM\s+\w+\s*(?:;|$)/i,
      description: 'Detects SELECT * without WHERE clause'
    });

    // Heuristic Rules
    this.addRule({
      id: 'heuristic_multi_statement',
      name: 'Multiple Statements in One Query',
      category: ThreatCategory.SUSPICIOUS_PATTERN,
      severity: ThreatLevel.MEDIUM,
      type: RuleType.WARN,
      pattern: /;/,
      description: 'Detects multiple statements in a single query'
    });
    
    this.addRule({
      id: 'heuristic_encoded',
      name: 'Encoded Payload',
      category: ThreatCategory.SUSPICIOUS_PATTERN,
      severity: ThreatLevel.HIGH,
      type: RuleType.WARN,
      pattern: /%(?:2[0-9A-F]|3[0-9A-F]|4[0-9A-F]|5[0-9A-F]|6[0-9A-F]|7[0-9A-F]|8[0-9A-F]|9[0-9A-F])/i,
      description: 'Detects URL-encoded characters (possible obfuscation)'
    });
  }

  loadDefaultWhitelist() {
    this.whitelist.push({ pattern: /^SET\s+/i, description: 'SET statements' });
    this.whitelist.push({ pattern: /^SHOW\s+/i, description: 'SHOW statements' });
    this.whitelist.push({ pattern: /^DESCRIBE\s+/i, description: 'DESCRIBE statements' });
    this.whitelist.push({ pattern: /^EXPLAIN\s+/i, description: 'EXPLAIN statements' });
  }

  addRule(rule) {
    if (!rule.id || !rule.pattern) {
      throw new Error('Rule must have id and pattern');
    }
    this.rules.push(rule);
  }

  isWhitelisted(query) {
    for (const entry of this.whitelist) {
      if (entry.pattern.test(query)) {
        return true;
      }
    }
    return false;
  }

  analyze(query, context = {}) {
    const normalized = this.normalizer.normalize(query);
    
    if (this.isWhitelisted(query)) {
      return {
        threatDetected: false,
        score: 0,
        level: ThreatLevel.LOW,
        findings: [],
        normalized: normalized,
        whitelisted: true
      };
    }

    const findings = [];
    let totalScore = 0;
    
    if (this.options.enablePatternMatching) {
      for (const rule of this.rules) {
        if (!rule.pattern) continue;
        
        const matched = rule.pattern.test(query) || rule.pattern.test(normalized);
        if (matched) {
          const severityScore = this.getSeverityScore(rule.severity);
          totalScore += severityScore;
          findings.push({
            rule: rule,
            matched: true,
            score: severityScore,
            normalized: normalized
          });
        }
      }
    }
    
    if (this.options.enableHeuristics) {
      const heuristicFindings = this.runHeuristics(query, normalized, context);
      findings.push(...heuristicFindings);
      totalScore += heuristicFindings.reduce((sum, f) => sum + f.score, 0);
    }
    
    if (this.options.enableThreatScoring) {
      const freqFindings = this.analyzeFrequency(query, context);
      findings.push(...freqFindings);
      totalScore += freqFindings.reduce((sum, f) => sum + f.score, 0);
    }
    
    const level = this.getThreatLevel(totalScore);
    
    if (this.options.logAllDetections && findings.length > 0) {
      this.logDetection(query, findings, totalScore, level, context);
    }
    
    return {
      threatDetected: findings.length > 0,
      score: totalScore,
      level: level,
      findings: findings,
      normalized: normalized,
      whitelisted: false
    };
  }

  runHeuristics(query, normalized, context) {
    const findings = [];
    
    const sensitivePattern = new RegExp(this.sensitiveTables.join('|'), 'i');
    if (sensitivePattern.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_sensitive_table',
          name: 'Sensitive Table Access',
          category: ThreatCategory.DATA_EXFILTRATION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'Access to sensitive table detected'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: normalized
      });
    }
    
    const inClauseMatches = query.match(/IN\s*\([^)]*\)/gi);
    if (inClauseMatches) {
      for (const match of inClauseMatches) {
        const values = match.match(/'[^']*'|\d+/g);
        if (values && values.length > 100) {
          findings.push({
            rule: {
              id: 'heuristic_large_in',
              name: 'Large IN Clause',
              category: ThreatCategory.BRUTE_FORCE,
              severity: ThreatLevel.MEDIUM,
              type: RuleType.WARN,
              description: `IN clause with ${values.length} values (potential brute force)`
            },
            matched: true,
            score: this.getSeverityScore(ThreatLevel.MEDIUM),
            normalized: normalized
          });
        }
      }
    }
    
    if (/sleep|delay|waitfor/i.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_time_based',
          name: 'Time-Based Injection',
          category: ThreatCategory.SQL_INJECTION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'Time-based injection attempt (SLEEP/DELAY)'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: normalized
      });
    }
    
    if (/benchmark/i.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_benchmark',
          name: 'Benchmark Injection',
          category: ThreatCategory.SQL_INJECTION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'BENCHMARK function (blind injection)'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: normalized
      });
    }
    
    return findings;
  }

  analyzeFrequency(query, context) {
    const findings = [];
    const key = `${context.userId || 'unknown'}:${context.ip || 'unknown'}`;
    const now = Date.now();
    
    if (!this.detectionHistory.has(key)) {
      this.detectionHistory.set(key, []);
    }
    
    const history = this.detectionHistory.get(key);
    history.push(now);
    
    const oneMinuteAgo = now - 60000;
    while (history.length > 0 && history[0] < oneMinuteAgo) {
      history.shift();
    }
    
    if (history.length > this.historyMaxSize) {
      this.detectionHistory.set(key, history.slice(-this.historyMaxSize));
    }
    
    if (history.length > 100) {
      findings.push({
        rule: {
          id: 'heuristic_brute_force',
          name: 'Brute Force Detection',
          category: ThreatCategory.BRUTE_FORCE,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: `${history.length} queries in last minute (possible brute force)`
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: this.normalizer.normalize(query)
      });
    }
    
    return findings;
  }

  getSeverityScore(severity) {
    const scores = {
      [ThreatLevel.LOW]: 1,
      [ThreatLevel.MEDIUM]: 5,
      [ThreatLevel.HIGH]: 10,
      [ThreatLevel.CRITICAL]: 25
    };
    return scores[severity] || 0;
  }

  getThreatLevel(score) {
    if (score >= 25) return ThreatLevel.CRITICAL;
    if (score >= 10) return ThreatLevel.HIGH;
    if (score >= 5) return ThreatLevel.MEDIUM;
    if (score >= 1) return ThreatLevel.LOW;
    return ThreatLevel.LOW;
  }

  logDetection(query, findings, score, level, context) {
    console.log(`\n[SECURITY ALERT] Threat Detected!`);
    console.log(`  Score: ${score}`);
    console.log(`  Level: ${level}`);
    console.log(`  User: ${context.userId || 'unknown'}`);
    console.log(`  IP: ${context.ip || 'unknown'}`);
    console.log(`  Query: ${query.substring(0, 100)}${query.length > 100 ? '...' : ''}`);
    console.log(`  Findings: ${findings.length}`);
    
    for (const finding of findings) {
      console.log(`    - ${finding.rule.name} (${finding.rule.severity})`);
    }
    console.log('');
  }

  determineAction(detection) {
    if (detection.whitelisted) {
      return 'ALLOW';
    }
    
    if (!detection.threatDetected) {
      return 'ALLOW';
    }
    
    for (const finding of detection.findings) {
      if (finding.rule.type === RuleType.BLOCK) {
        return 'BLOCK';
      }
    }
    
    if (detection.score >= 15) {
      return 'BLOCK';
    }
    
    for (const finding of detection.findings) {
      if (finding.rule.type === RuleType.WARN) {
        return 'WARN';
      }
    }
    
    return 'LOG';
  }
}
```
</details>

### Step 2: Test the Threat Detector

**2.1 Create `tests/test-threat-detector.js`:**

```javascript
// tests/test-threat-detector.js

import { ThreatDetector, ThreatLevel } from '../src/threat-detector.js';

function testThreatDetector() {
  console.log('🧪 Testing Threat Detector...\n');
  
  const detector = new ThreatDetector();
  
  const testCases = [
    { query: "SELECT * FROM users WHERE id = 1", shouldDetect: false, desc: "Normal query" },
    { query: "SELECT * FROM users WHERE email = '' OR 1=1 --'", shouldDetect: true, desc: "SQL Injection (tautology)" },
    { query: "SELECT * FROM users WHERE id = 1 UNION SELECT * FROM admins", shouldDetect: true, desc: "SQL Injection (UNION)" },
    { query: "SELECT * FROM users; DROP TABLE users", shouldDetect: true, desc: "Stacked Query" },
    { query: "DROP TABLE users", shouldDetect: true, desc: "DROP TABLE" },
    { query: "TRUNCATE TABLE users", shouldDetect: true, desc: "TRUNCATE" },
    { query: "ALTER TABLE users ADD COLUMN age INT", shouldDetect: true, desc: "ALTER TABLE" },
    { query: "GRANT SELECT ON users TO public", shouldDetect: true, desc: "GRANT privilege" },
    { query: "SELECT * FROM passwords", shouldDetect: true, desc: "Sensitive table access" },
    { query: "SELECT SLEEP(10) FROM users", shouldDetect: true, desc: "Time-based injection" },
    { query: "SET timezone = 'UTC'", shouldDetect: false, desc: "Whitelisted query" }
  ];
  
  let passed = 0;
  testCases.forEach((tc, idx) => {
    const result = detector.analyze(tc.query, { userId: 'test', ip: '127.0.0.1' });
    const passedTest = result.threatDetected === tc.shouldDetect;
    
    console.log(`\n📝 Test ${idx + 1}: ${tc.desc}`);
    console.log(`   Query: ${tc.query.substring(0, 60)}${tc.query.length > 60 ? '...' : ''}`);
    console.log(`   Detected: ${result.threatDetected ? '✅ Yes' : '❌ No'}`);
    console.log(`   Expected: ${tc.shouldDetect ? '✅ Yes' : '❌ No'}`);
    console.log(`   Score: ${result.score}`);
    console.log(`   Level: ${result.level}`);
    console.log(`   Action: ${detector.determineAction(result)}`);
    
    if (result.findings.length > 0) {
      console.log(`   Findings: ${result.findings.length}`);
      for (const finding of result.findings) {
        console.log(`     - ${finding.rule.name} (${finding.rule.severity})`);
      }
    }
    
    console.log(`   ${passedTest ? '✅ PASS' : '❌ FAIL'}`);
    if (passedTest) passed++;
  });
  
  console.log(`\n📊 Results: ${passed}/${testCases.length} passed`);
}

testThreatDetector();
```

### Step 3: Run the Tests

**3.1 Execute the test script:**
```bash
node tests/test-threat-detector.js
```

### ✅ Verification Checklist

- [ ] Normal queries are not blocked
- [ ] SQL injection queries are detected
- [ ] DDL operations are detected
- [ ] Sensitive table access is detected
- [ ] Threat scoring works correctly
- [ ] Whitelisted queries pass through

---

# LAB 5: IMPLEMENTING INCIDENT RESPONSE

## Lab 5.1: JavaScript IncidentResponder

### Objectives
- ✅ Implement incident response orchestrator
- ✅ Create incident vault
- ✅ Implement circuit breaker pattern
- ✅ Test response actions

### Pre-Lab Requirements
- ☐ Labs 1.1, 3.1, and 4.1 completed
- ☐ Node.js environment set up

### Estimated Time: 45 minutes

### Step 1: Create the IncidentResponder

**1.1 Create `src/incident-responder.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/incident-responder.js

import fs from 'fs/promises';
import path from 'path';

export const IncidentSeverity = {
  LOW: 'LOW',
  MEDIUM: 'MEDIUM',
  HIGH: 'HIGH',
  CRITICAL: 'CRITICAL'
};

export const ResponseAction = {
  BLOCK_QUERY: 'BLOCK_QUERY',
  TERMINATE_CONNECTION: 'TERMINATE_CONNECTION',
  REVOKE_CREDENTIALS: 'REVOKE_CREDENTIALS',
  NOTIFY_SECURITY: 'NOTIFY_SECURITY',
  CIRCUIT_BREAKER: 'CIRCUIT_BREAKER',
  ISOLATE_USER: 'ISOLATE_USER',
  ROLLBACK_TRANSACTION: 'ROLLBACK_TRANSACTION',
  LOG_INCIDENT: 'LOG_INCIDENT'
};

export class IncidentResponder {
  constructor(options = {}) {
    this.options = {
      vaultPath: options.vaultPath || './incident_vault.jsonl',
      notifySecurity: options.notifySecurity !== false,
      useCircuitBreaker: options.useCircuitBreaker !== false,
      terminateConnections: options.terminateConnections !== false,
      revokeCredentials: options.revokeCredentials || false,
      cooldownPeriod: options.cooldownPeriod || 60000,
      maxIncidentsMemory: options.maxIncidentsMemory || 100,
      ...options
    };
    
    this.incidentHistory = new Map();
    this.circuitBreakerActive = false;
    this.circuitBreakerExpiry = null;
    
    this.stats = {
      totalIncidents: 0,
      criticalIncidents: 0,
      blockedQueries: 0,
      terminatedConnections: 0,
      notificationsSent: 0
    };
    
    this.initVault();
  }

  async initVault() {
    try {
      const vaultDir = path.dirname(this.options.vaultPath);
      await fs.mkdir(vaultDir, { recursive: true });
      try {
        await fs.access(this.options.vaultPath);
      } catch {
        await fs.writeFile(this.options.vaultPath, '');
        console.log(`[INCIDENT RESPONDER] Vault created at ${this.options.vaultPath}`);
      }
    } catch (error) {
      console.error('[INCIDENT RESPONDER] Failed to initialize vault:', error);
    }
  }

  async handleIncident(incident) {
    const timestamp = new Date().toISOString();
    const incidentId = this.generateIncidentId();
    
    console.log(`\n[INCIDENT RESPONDER] Handling incident ${incidentId}`);
    console.log(`  Threat Level: ${incident.threatLevel}`);
    console.log(`  User: ${incident.userContext?.id || 'unknown'}`);
    console.log(`  Query: ${incident.query?.substring(0, 100)}...`);
    
    const validationResult = await this.validateIncident(incident);
    if (!validationResult.shouldRespond) {
      console.log(`  Incident ${incidentId} ignored: ${validationResult.reason}`);
      return {
        incidentId,
        handled: false,
        reason: validationResult.reason
      };
    }
    
    const responsePlan = this.generateResponsePlan(incident);
    const responseResults = await this.executeResponsePlan(responsePlan, incident);
    const vaultEntry = await this.recordIncident(incidentId, timestamp, incident, responseResults);
    this.updateStats(incident, responseResults);
    await this.postResponseActions(incident, responseResults, vaultEntry);
    
    console.log(`[INCIDENT RESPONDER] Incident ${incidentId} handled successfully`);
    
    return {
      incidentId,
      handled: true,
      responseResults,
      vaultEntry
    };
  }

  async validateIncident(incident) {
    if (!incident.query) {
      return { shouldRespond: false, reason: 'No query provided' };
    }
    
    const userKey = `${incident.userContext?.id || 'unknown'}:${incident.userContext?.ip || 'unknown'}`;
    const lastIncident = this.incidentHistory.get(userKey);
    
    if (lastIncident) {
      const timeSince = Date.now() - lastIncident.timestamp;
      if (timeSince < this.options.cooldownPeriod) {
        lastIncident.count = (lastIncident.count || 1) + 1;
        if (lastIncident.count > 3) {
          console.log(`  [WARNING] Repeated incidents from ${userKey}: ${lastIncident.count}`);
        }
        return { 
          shouldRespond: true, 
          reason: 'Repeated incident from same user (escalating)' 
        };
      }
    }
    
    this.incidentHistory.set(userKey, {
      timestamp: Date.now(),
      count: 1,
      incident: incident
    });
    
    if (this.incidentHistory.size > this.options.maxIncidentsMemory) {
      const oldestKey = this.incidentHistory.keys().next().value;
      this.incidentHistory.delete(oldestKey);
    }
    
    return { shouldRespond: true, reason: 'Valid incident' };
  }

  generateResponsePlan(incident) {
    const plan = [];
    const severity = incident.threatLevel || IncidentSeverity.LOW;
    
    plan.push(ResponseAction.LOG_INCIDENT);
    plan.push(ResponseAction.BLOCK_QUERY);
    this.stats.blockedQueries++;
    
    if (severity === IncidentSeverity.MEDIUM ||
        severity === IncidentSeverity.HIGH ||
        severity === IncidentSeverity.CRITICAL) {
      plan.push(ResponseAction.NOTIFY_SECURITY);
      this.stats.notificationsSent++;
    }
    
    if (severity === IncidentSeverity.HIGH) {
      if (this.options.terminateConnections) {
        plan.push(ResponseAction.TERMINATE_CONNECTION);
        this.stats.terminatedConnections++;
      }
      if (this.options.useCircuitBreaker) {
        plan.push(ResponseAction.CIRCUIT_BREAKER);
      }
    }
    
    if (severity === IncidentSeverity.CRITICAL) {
      if (this.options.terminateConnections) {
        plan.push(ResponseAction.TERMINATE_CONNECTION);
        this.stats.terminatedConnections++;
      }
      if (this.options.revokeCredentials) {
        plan.push(ResponseAction.REVOKE_CREDENTIALS);
      }
      if (this.options.useCircuitBreaker) {
        plan.push(ResponseAction.CIRCUIT_BREAKER);
      }
      plan.push(ResponseAction.ISOLATE_USER);
      this.stats.criticalIncidents++;
    }
    
    return plan;
  }

  async executeResponsePlan(plan, incident) {
    const results = {};
    for (const action of plan) {
      try {
        results[action] = await this.executeAction(action, incident);
      } catch (error) {
        results[action] = { success: false, error: error.message };
      }
    }
    return results;
  }

  async executeAction(action, incident) {
    switch (action) {
      case ResponseAction.BLOCK_QUERY:
        return { 
          success: true, 
          message: 'Query blocked',
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.TERMINATE_CONNECTION:
        if (incident.dbConnection) {
          try {
            await incident.dbConnection.end();
            return { 
              success: true, 
              message: 'Connection terminated',
              timestamp: new Date().toISOString()
            };
          } catch (error) {
            return { 
              success: false, 
              error: error.message,
              timestamp: new Date().toISOString()
            };
          }
        }
        return { 
          success: false, 
          error: 'No connection to terminate',
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.REVOKE_CREDENTIALS:
        console.log(`[ACTION] Revoking credentials for user: ${incident.userContext?.id}`);
        return { 
          success: true, 
          message: `Credentials revoked for ${incident.userContext?.id}`,
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.NOTIFY_SECURITY:
        if (this.options.notifySecurity) {
          await this.notifySecurityTeam(incident);
        }
        this.stats.notificationsSent++;
        return { 
          success: true, 
          message: 'Security team notified',
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.CIRCUIT_BREAKER:
        this.activateCircuitBreaker(incident);
        return { 
          success: true, 
          message: 'Circuit breaker activated',
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.ISOLATE_USER:
        console.log(`[ACTION] Isolating user: ${incident.userContext?.id}`);
        return { 
          success: true, 
          message: `User ${incident.userContext?.id} isolated`,
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.ROLLBACK_TRANSACTION:
        console.log('[ACTION] Rolling back transaction');
        return { 
          success: true, 
          message: 'Transaction rollback initiated',
          timestamp: new Date().toISOString()
        };
      
      case ResponseAction.LOG_INCIDENT:
        return { 
          success: true, 
          message: 'Incident logged',
          timestamp: new Date().toISOString()
        };
      
      default:
        return { 
          success: false, 
          error: `Unknown action: ${action}`,
          timestamp: new Date().toISOString()
        };
    }
  }

  activateCircuitBreaker(incident) {
    this.circuitBreakerActive = true;
    this.circuitBreakerExpiry = Date.now() + 5 * 60 * 1000;
    console.log(`[CIRCUIT BREAKER] Activated for ${incident.userContext?.id}`);
    console.log(`  Expires at: ${new Date(this.circuitBreakerExpiry).toISOString()}`);
  }

  isCircuitBreakerActive() {
    if (this.circuitBreakerActive) {
      if (Date.now() > this.circuitBreakerExpiry) {
        this.circuitBreakerActive = false;
        this.circuitBreakerExpiry = null;
        console.log('[CIRCUIT BREAKER] Expired and reset');
        return false;
      }
      return true;
    }
    return false;
  }

  async recordIncident(incidentId, timestamp, incident, responseResults) {
    const vaultEntry = {
      incidentId,
      timestamp,
      severity: incident.threatLevel || IncidentSeverity.LOW,
      userContext: incident.userContext || {},
      query: incident.query,
      params: incident.params || [],
      findings: incident.findings || [],
      responseResults: responseResults,
      circuitBreakerActive: this.circuitBreakerActive,
      stats: { ...this.stats }
    };
    
    await fs.appendFile(
      this.options.vaultPath,
      JSON.stringify(vaultEntry) + '\n'
    );
    
    return vaultEntry;
  }

  async notifySecurityTeam(incident) {
    this.stats.notificationsSent++;
    console.log(`
[SECURITY ALERT] Critical Incident Detected!
============================================
Time: ${new Date().toISOString()}
Severity: ${incident.threatLevel || 'UNKNOWN'}
User: ${incident.userContext?.id || 'unknown'}
IP: ${incident.userContext?.ip || 'unknown'}
Query: ${incident.query?.substring(0, 200)}...
Findings: ${incident.findings?.length || 0} threats detected
============================================
    `);
    await new Promise(resolve => setTimeout(resolve, 100));
  }

  async postResponseActions(incident, responseResults, vaultEntry) {
    if (incident.threatLevel === IncidentSeverity.CRITICAL) {
      console.log('[POST-RESPONSE] Updating security rules based on incident...');
    }
    console.log(`[POST-RESPONSE] Incident ${vaultEntry.incidentId} response completed`);
  }

  updateStats(incident, responseResults) {
    this.stats.totalIncidents++;
    if (incident.threatLevel === IncidentSeverity.CRITICAL) {
      this.stats.criticalIncidents++;
    }
  }

  generateIncidentId() {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 7);
    return `INC-${timestamp}-${random}`.toUpperCase();
  }

  getStats() {
    return { ...this.stats };
  }

  async queryVault(filters = {}) {
    const limit = filters.limit || 100;
    const incidents = [];
    
    try {
      const data = await fs.readFile(this.options.vaultPath, 'utf-8');
      const lines = data.split('\n').filter(line => line.trim());
      
      for (let i = lines.length - 1; i >= 0 && incidents.length < limit; i--) {
        const entry = JSON.parse(lines[i]);
        
        if (filters.severity && entry.severity !== filters.severity) continue;
        if (filters.userId && entry.userContext?.id !== filters.userId) continue;
        
        incidents.push(entry);
      }
      return incidents;
    } catch (error) {
      console.error('[INCIDENT RESPONDER] Failed to query vault:', error);
      return [];
    }
  }
}
```
</details>

### Step 2: Create Complete DAM System

**2.1 Create `src/complete-dam-system.js`:**

<details>
<summary>Click to expand the complete code</summary>

```javascript
// src/complete-dam-system.js

import 'dotenv/config';
import { SecureAuditedPool } from './secure-audited-pool.js';
import { IncidentResponder, IncidentSeverity } from './incident-responder.js';

export class CompleteDAMSystem {
  constructor(options = {}) {
    this.options = {
      connectionString: options.connectionString || process.env.DATABASE_URL,
      threatDetectorOptions: options.threatDetectorOptions || {},
      incidentResponderOptions: options.incidentResponderOptions || {},
      securePoolOptions: options.securePoolOptions || {},
      enableAudit: options.enableAudit !== false,
      enableThreatDetection: options.enableThreatDetection !== false,
      enableIncidentResponse: options.enableIncidentResponse !== false,
      ...options
    };
    
    this.auditPool = null;
    this.threatDetector = null;
    this.incidentResponder = null;
    this.isInitialized = false;
    this.isShuttingDown = false;
  }

  async initialize() {
    if (this.isInitialized) {
      console.log('[DAM SYSTEM] Already initialized');
      return;
    }
    
    console.log('[DAM SYSTEM] Initializing...');
    
    try {
      this.auditPool = new SecureAuditedPool(
        this.options.connectionString,
        this.options.securePoolOptions
      );
      
      this.threatDetector = this.auditPool.detector;
      
      this.incidentResponder = new IncidentResponder(
        this.options.incidentResponderOptions
      );
      
      this.isInitialized = true;
      console.log('[DAM SYSTEM] Initialized successfully');
      console.log(`  Audit: ${this.options.enableAudit ? 'Enabled' : 'Disabled'}`);
      console.log(`  Threat Detection: ${this.options.enableThreatDetection ? 'Enabled' : 'Disabled'}`);
      console.log(`  Incident Response: ${this.options.enableIncidentResponse ? 'Enabled' : 'Disabled'}`);
      
    } catch (error) {
      console.error('[DAM SYSTEM] Initialization failed:', error);
      throw error;
    }
  }

  async query(query, params = [], userContext = {}) {
    if (!this.isInitialized) {
      throw new Error('[DAM SYSTEM] System not initialized');
    }
    
    if (this.isShuttingDown) {
      throw new Error('[DAM SYSTEM] System is shutting down');
    }
    
    if (this.options.enableIncidentResponse && 
        this.incidentResponder.isCircuitBreakerActive()) {
      throw new Error('[DAM SYSTEM] Circuit breaker is active - queries are blocked');
    }
    
    try {
      const result = await this.auditPool.query(query, params, userContext);
      return result;
    } catch (error) {
      if (error.message.includes('[SECURITY]')) {
        if (this.options.enableIncidentResponse) {
          const incident = {
            query: query,
            params: params,
            userContext: userContext,
            threatLevel: IncidentSeverity.HIGH,
            findings: error.findings || [],
            detection: error.detection || null,
            dbConnection: this.auditPool.pool
          };
          await this.incidentResponder.handleIncident(incident);
        }
      }
      throw error;
    }
  }

  getStatus() {
    return {
      initialized: this.isInitialized,
      shuttingDown: this.isShuttingDown,
      stats: {
        audit: this.auditPool ? 'Active' : 'Inactive',
        threatDetection: this.threatDetector ? 'Active' : 'Inactive',
        incidentResponse: this.incidentResponder ? 'Active' : 'Inactive',
        circuitBreaker: this.incidentResponder?.isCircuitBreakerActive() || false
      },
      incidentStats: this.incidentResponder?.getStats() || {}
    };
  }

  async getAuditSummary() {
    if (!this.auditPool) {
      throw new Error('[DAM SYSTEM] Audit pool not initialized');
    }
    return await this.auditPool.getSecurityStats();
  }

  async getThreatPatterns(level = null, limit = 50) {
    if (!this.auditPool) {
      throw new Error('[DAM SYSTEM] Audit pool not initialized');
    }
    return await this.auditPool.getThreatPatterns(level, limit);
  }

  async getIncidentHistory(filters = {}) {
    if (!this.incidentResponder) {
      throw new Error('[DAM SYSTEM] Incident responder not initialized');
    }
    return await this.incidentResponder.queryVault(filters);
  }

  async shutdown() {
    if (this.isShuttingDown) return;
    
    this.isShuttingDown = true;
    console.log('[DAM SYSTEM] Shutting down...');
    
    try {
      if (this.auditPool) {
        await this.auditPool.close();
        console.log('[DAM SYSTEM] Audit pool closed');
      }
      this.isInitialized = false;
      console.log('[DAM SYSTEM] Shutdown complete');
    } catch (error) {
      console.error('[DAM SYSTEM] Shutdown error:', error);
      throw error;
    }
  }
}
```
</details>

### Step 3: Test the Complete System

**3.1 Create `tests/test-complete-system.js`:**

```javascript
// tests/test-complete-system.js

import 'dotenv/config';
import { createDAMSystem } from '../src/complete-dam-system.js';

async function testCompleteSystem() {
  console.log('🧪 Testing Complete DAM System...\n');
  
  const system = createDAMSystem({
    incidentResponderOptions: {
      vaultPath: './test_incident_vault.jsonl',
      notifySecurity: true,
      terminateConnections: true,
      revokeCredentials: false,
      cooldownPeriod: 5000
    }
  });
  
  try {
    await system.initialize();
    console.log('✅ System initialized\n');
    
    // Test 1: Normal query
    console.log('📝 Test 1: Normal query');
    try {
      const result = await system.query(
        'SELECT NOW() as current_time',
        [],
        { id: 'test-user', ip: '127.0.0.1' }
      );
      console.log(`  ✅ Query executed: ${result.rows[0].current_time}`);
    } catch (error) {
      console.log(`  ❌ Query failed: ${error.message}`);
    }
    
    // Test 2: SQL Injection
    console.log('\n📝 Test 2: SQL Injection (should be blocked)');
    try {
      await system.query(
        "SELECT * FROM users WHERE email = '' OR 1=1 --'",
        [],
        { id: 'attacker', ip: '192.168.1.200' }
      );
      console.log('  ⚠️ Query should have been blocked!');
    } catch (error) {
      console.log(`  ✅ Query blocked: ${error.message.substring(0, 80)}...`);
    }
    
    // Test 3: DROP TABLE
    console.log('\n📝 Test 3: DROP TABLE (should be blocked)');
    try {
      await system.query(
        'DROP TABLE users',
        [],
        { id: 'malicious-user', ip: '10.0.0.5' }
      );
      console.log('  ⚠️ Query should have been blocked!');
    } catch (error) {
      console.log(`  ✅ Query blocked: ${error.message.substring(0, 80)}...`);
    }
    
    // Test 4: Sensitive table access
    console.log('\n📝 Test 4: Sensitive table access');
    try {
      await system.query(
        'SELECT * FROM passwords',
        [],
        { id: 'curious-user', ip: '192.168.1.50' }
      );
      console.log('  ⚠️ Query should have been blocked!');
    } catch (error) {
      console.log(`  ✅ Query blocked: ${error.message.substring(0, 80)}...`);
    }
    
    console.log('\n📊 System Status:');
    console.log(JSON.stringify(system.getStatus(), null, 2));
    
    console.log('\n✅ All tests completed!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await system.shutdown();
    console.log('\n🔌 System shutdown complete');
  }
}

testCompleteSystem();
```

### Step 4: Run the Tests

**4.1 Execute the test script:**
```bash
node tests/test-complete-system.js
```

### ✅ Verification Checklist

- [ ] System initializes successfully
- [ ] Normal queries execute and are logged
- [ ] SQL injection queries are blocked
- [ ] DDL operations are blocked
- [ ] Incident vault receives entries
- [ ] Circuit breaker activates on repeated threats

---

# LAB 6: COMPLETE SYSTEM INTEGRATION

## Lab 6.1: Full System Test

### Objectives
- ✅ Test all components together
- ✅ Verify end-to-end flow
- ✅ Generate incident report

### Estimated Time: 30 minutes

### Step 1: Run the Complete Test Suite

**1.1 Execute all tests:**

```bash
# JavaScript tests
cd ~/dam-labs/lab-1-audit/javascript
node tests/test-audited-pool.js

cd ~/dam-labs/lab-2-interception/javascript
node tests/test-driver-interception.js

cd ~/dam-labs/lab-3-normalization/javascript
node tests/test-normalizer.js

cd ~/dam-labs/lab-4-detection/javascript
node tests/test-threat-detector.js

cd ~/dam-labs/lab-5-response/javascript
node tests/test-complete-system.js
```

**1.2 Verify the incident vault:**

```bash
cat test_incident_vault.jsonl | jq '.'
```

**Expected output:** JSON entries showing incident details

### Step 2: Verify Audit Data

**2.1 Check PostgreSQL audit logs:**

```sql
SELECT 
    user_id,
    status,
    COUNT(*) as count,
    AVG(duration_ms) as avg_duration
FROM dam_audit_logs
GROUP BY user_id, status
ORDER BY count DESC;
```

### Step 3: Lab Report

**3.1 Answer these questions:**

1. What was the most challenging part of building the DAM system?
   _________________________________________________________________

2. How would you deploy this system to production?
   _________________________________________________________________

3. What customizations would you make for your environment?
   _________________________________________________________________

4. What additional features would you add?
   _________________________________________________________________

---

**[END OF LAB BOOK]**

---

## LAB COMPLETION CERTIFICATE

I, _____________________________, have completed all labs in the DAM Tutorial Series.

**Date:** _________________

**Labs Completed:**
- [ ] Lab 1.1: JavaScript AuditedPool
- [ ] Lab 1.2: Python AuditedSQLite
- [ ] Lab 1.3: Audit Data Verification
- [ ] Lab 2.1: JavaScript Driver Interception
- [ ] Lab 2.2: Python Native Interception
- [ ] Lab 3.1: JavaScript QueryNormalizer
- [ ] Lab 3.2: Python QueryNormalizer
- [ ] Lab 4.1: JavaScript ThreatDetector
- [ ] Lab 5.1: JavaScript IncidentResponder
- [ ] Lab 6.1: Full System Test

**Total Time Spent:** __________ hours
