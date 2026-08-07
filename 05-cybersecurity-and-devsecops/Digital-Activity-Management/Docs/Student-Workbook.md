# DAM Tutorial Series: Complete Student Workbook

**[STARTING: Student Workbook - Complete DAM Tutorial Series]**

Welcome to the DAM Tutorial Student Workbook! This comprehensive workbook is designed to accompany the slide deck and tutorial series. It provides structured exercises, hands-on labs, code templates, verification checkpoints, and self-assessment questions for every part of the series.

---

## HOW TO USE THIS WORKBOOK

### Workbook Structure

Each part of the series has its own section in this workbook containing:

1. **Learning Objectives** - What you'll accomplish
2. **Pre-Lab Setup** - What to prepare before starting
3. **Step-by-Step Exercises** - Hands-on coding activities
4. **Code Templates** - Starter code with placeholders to fill in
5. **Verification Checkpoints** - Tests to confirm your work
6. **Knowledge Checks** - Questions to test understanding
7. **Challenge Exercises** - Extra credit activities
8. **Troubleshooting Guide** - Common issues and solutions

### How to Use This Workbook

1. **Read the tutorial/slides first** - This workbook is for hands-on practice
2. **Follow the exercises in order** - Each builds on the previous
3. **Fill in the code templates** - Complete the missing parts
4. **Run the verification checks** - Confirm your code works
5. **Answer the knowledge checks** - Test your understanding
6. **Try the challenges** - Push yourself further

### Workbook Symbols

| Symbol | Meaning |
|--------|---------|
| 📖 | Reading/Conceptual |
| 💻 | Hands-on Coding |
| ✅ | Verification Checkpoint |
| ❓ | Knowledge Check |
| 🏆 | Challenge Exercise |
| ⚠️ | Common Pitfall/Troubleshooting |
| 📝 | Take Notes |

---

# SECTION 0: INTRODUCTION WORKBOOK

## Part 0: Understanding the DAM Series

### 📖 0.1: Pre-Lab Reading

Before starting the hands-on exercises, ensure you understand:

| Concept | Your Understanding (1-5) |
|---------|-------------------------|
| What is DAM? | ☐ 1 ☐ 2 ☐ 3 ☐ 4 ☐ 5 |
| Why is DAM important? | ☐ 1 ☐ 2 ☐ 3 ☐ 4 ☐ 5 |
| What are the 5 DAM layers? | ☐ 1 ☐ 2 ☐ 3 ☐ 4 ☐ 5 |
| What technologies we'll use | ☐ 1 ☐ 2 ☐ 3 ☐ 4 ☐ 5 |

### 💻 0.2: Environment Setup

**Step 1: Check Node.js Version**
```bash
node --version
# Expected: v16.0.0 or higher
# Your version: _____________
```

**Step 2: Check Python Version**
```bash
python --version
# Expected: Python 3.8.0 or higher
# Your version: _____________
```

**Step 3: Create Project Directories**
```bash
mkdir -p ~/projects/guarding-the-core
cd ~/projects/guarding-the-core
mkdir -p javascript/src javascript/tests
mkdir -p python
```

**Step 4: Sign Up for Neon**
- Go to: https://neon.tech
- Sign up with GitHub or email
- Create a new project
- Save your connection string: ___________________________

### 📝 0.3: Architecture Diagram

**Instructions:** Label the following DAM architecture diagram:

```
                    ┌─────────────────────────────┐
                    │                             │
                    │     1. ___________          │
                    │      (Part 1)              │
                    │                             │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │                             │
                    │     2. ___________          │
                    │      (Part 2)              │
                    │                             │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │                             │
                    │     3. ___________          │
                    │      (Part 3)              │
                    │                             │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │                             │
                    │     4. ___________          │
                    │      (Part 4)              │
                    │                             │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐
                    │                             │
                    │     5. ___________          │
                    │      (Part 5)              │
                    │                             │
                    └─────────────────────────────┘
```

**Word Bank:** Incident Response, Threat Detection, Audit Trail, Normalization, Interception

### ❓ 0.4: Pre-Lab Knowledge Check

1. What does DAM stand for?
   _________________________________________________________________

2. Why is DAM important for database security?
   _________________________________________________________________

3. What are the five layers of the DAM pipeline?
   _________________________________________________________________

4. What two programming languages will we use?
   _________________________________________________________________

5. What two database systems will we work with?
   _________________________________________________________________

### ✅ 0.5: Verification Checklist

Check off each item as you complete it:

- [ ] Node.js is installed and working
- [ ] Python is installed and working
- [ ] Project directories are created
- [ ] Neon account is created
- [ ] Connection string is saved

---

# SECTION 1: PART 1 WORKBOOK

## Part 1: Foundations & The Audit Trail Setup

### 📖 1.1: Learning Objectives

By completing this part, you will be able to:
- [ ] Explain what an audit trail is and why it matters
- [ ] Build an AuditedPool class for PostgreSQL
- [ ] Build an AuditedSQLite class for SQLite
- [ ] Create audit tables with proper indexing
- [ ] Log queries with user context, timing, and status
- [ ] Test and verify audit logging functionality

### 💻 1.2: JavaScript Implementation Exercise

**Exercise 1.2.1: Create the AuditedPool Class**

Create `javascript/src/audited-pool.js` with the following structure. Fill in the missing parts (indicated by `______`):

```javascript
// javascript/src/audited-pool.js

import pkg from 'pg';
const { Pool } = pkg;

export class AuditedPool {
  constructor(connectionString, options = {}) {
    this.connectionString = connectionString;
    this.pool = new Pool({ 
      connectionString,
      connectionTimeoutMillis: ______,
      max: ______,
      ...options
    });
    this.auditTableInitialized = ______;
  }

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
      `);
      this.auditTableInitialized = ______;
    } finally {
      client.release();
    }
  }

  async query(text, params = [], userContext = { id: 'system', ip: 'unknown' }) {
    await this.initAuditTable();
    const startTime = ______;
    let status = 'SUCCESS';
    let errorMessage = null;
    let result = null;

    try {
      result = await this.pool.query(text, params);
      return result;
    } catch (error) {
      status = ______;
      errorMessage = error.message;
      throw error;
    } finally {
      const durationMs = ______ - startTime;
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
      `Status: ${auditEntry.status} | ` +
      `Duration: ${auditEntry.duration_ms.toFixed(2)}ms | ` +
      `Query: ${auditEntry.query_text.substring(0, 200)}...`
    );
  }

  async close() {
    await this.pool.end();
  }
}
```

**Fill in the missing values:**
- `connectionTimeoutMillis`: _______
- `max`: _______
- `auditTableInitialized`: _______
- `startTime`: _______
- `status`: _______
- `durationMs`: _______

### 💻 1.3: JavaScript Test Implementation

**Exercise 1.3.1: Create the Test Script**

Create `javascript/tests/test-audited-pool.js`:

```javascript
// javascript/tests/test-audited-pool.js

import 'dotenv/config';
import { AuditedPool } from '../src/audited-pool.js';

async function testAuditedPool() {
  console.log('🧪 Testing AuditedPool...\n');

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    process.exit(1);
  }

  const pool = new AuditedPool(databaseUrl);
  console.log('✅ AuditedPool created successfully');

  try {
    // TEST 1: Successful SELECT
    console.log('\n📝 TEST 1: Successful SELECT query');
    const result = await pool.query(
      'SELECT NOW() as current_time',
      [],
      { id: 'test-user', ip: '127.0.0.1' }
    );
    console.log(`   ✅ Query returned: ${result.rows[0].current_time}`);

    // TEST 2: Failing query
    console.log('\n📝 TEST 2: Failing query (should log error)');
    try {
      await pool.query(
        'SELECT * FROM non_existent_table',
        [],
        { id: 'error-test', ip: '127.0.0.1' }
      );
    } catch (error) {
      console.log(`   ✅ Query failed as expected: ${error.message}`);
    }

    // TEST 3: Query with user context
    console.log('\n📝 TEST 3: Query with user context');
    const result2 = await pool.query(
      'SELECT $1::text as greeting',
      ['Hello, DAM!'],
      { id: 'alice@example.com', ip: '192.168.1.100' }
    );
    console.log(`   ✅ Query executed: ${result2.rows[0].greeting}`);

    console.log('\n✅ All tests completed successfully!');
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await pool.close();
    console.log('\n🔌 Connection pool closed.');
  }
}

testAuditedPool();
```

### 💻 1.4: Python Implementation Exercise

**Exercise 1.4.1: Create the AuditedSQLite Class**

Create `python/audited_sqlite.py`:

```python
# python/audited_sqlite.py

import sqlite3
import time
from contextlib import contextmanager
from datetime import datetime

class AuditedSQLite:
    def __init__(self, db_path: str):
        self.db_path = db_path
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
            conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp)")
            conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_logs(user)")
            conn.commit()

    @contextmanager
    def transaction(self, query: str, user: str = "system"):
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
                f"[DAM AUDIT] {datetime.utcnow().isoformat()} | "
                f"User: {user} | Status: {status} | "
                f"Duration: {duration:.2f}ms | Query: {query[:200]}..."
            )

    def execute(self, query: str, params: tuple = (), user: str = "system"):
        with self.transaction(query, user) as cursor:
            return cursor.execute(query, params)

    def query(self, query: str, params: tuple = (), user: str = "system"):
        with self.transaction(query, user) as cursor:
            cursor.execute(query, params)
            columns = [description[0] for description in cursor.description]
            return [dict(zip(columns, row)) for row in cursor.fetchall()]

    def query_one(self, query: str, params: tuple = (), user: str = "system"):
        results = self.query(query, params, user)
        return results[0] if results else None

    def close(self):
        # Connection is managed by context managers
        pass

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
```

### 💻 1.5: Python Test Implementation

**Exercise 1.5.1: Create the Python Test Script**

Create `python/test_audited_sqlite.py`:

```python
# python/test_audited_sqlite.py

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
            user="alice"
        )
        print("   ✅ Table created and data inserted")
        
        # TEST 2: Query data
        print("\n📝 TEST 2: Querying data")
        results = db.query(
            "SELECT * FROM test_users",
            user="alice"
        )
        print(f"   ✅ Found {len(results)} users: {results}")
        
        # TEST 3: Failing query
        print("\n📝 TEST 3: Failing query (should log error)")
        try:
            db.execute(
                "SELECT * FROM non_existent_table",
                user="test"
            )
        except sqlite3.Error as e:
            print(f"   ✅ Query failed as expected: {e}")
        
        print("\n✅ All tests completed successfully!")
    except Exception as e:
        print(f"❌ Test failed: {e}")
    finally:
        db.close()
        print("\n🔌 Database connection closed.")

if __name__ == "__main__":
    test_audited_sqlite()
```

### ✅ 1.6: Verification Checkpoints

**Checkpoint 1: JavaScript Test**

Run the JavaScript tests:
```bash
cd javascript
node tests/test-audited-pool.js
```

**Expected Output:** 
- All three tests pass
- Audit entries appear in console
- No errors

**Did it work?** ☐ Yes ☐ No

If not, what error did you see?
_________________________________________________________________

**Checkpoint 2: Python Test**

Run the Python tests:
```bash
cd python
python test_audited_sqlite.py
```

**Expected Output:**
- All three tests pass
- Audit entries appear in console
- No errors

**Did it work?** ☐ Yes ☐ No

If not, what error did you see?
_________________________________________________________________

**Checkpoint 3: Database Verification (JavaScript)**

Connect to Neon and check the audit table:
```sql
SELECT user_id, status, LEFT(query_text, 40) as query, duration_ms
FROM dam_audit_logs
ORDER BY timestamp DESC
LIMIT 5;
```

**Expected:** 3-5 rows with different user_id values

**Did it work?** ☐ Yes ☐ No

**Checkpoint 4: Database Verification (Python)**

Check the SQLite audit table:
```bash
sqlite3 :memory: "SELECT user, status, LEFT(query, 40) as query, duration_ms FROM audit_logs ORDER BY timestamp DESC LIMIT 5;"
```

**Expected:** 3-5 rows with different user values

**Did it work?** ☐ Yes ☐ No

### ❓ 1.7: Knowledge Checks

1. What is an audit trail and why is it important?
   _________________________________________________________________

2. What does the "before-during-after" pattern mean?
   _________________________________________________________________

3. Why do we use a separate connection for audit logging in the JavaScript implementation?
   _________________________________________________________________

4. What is the purpose of the Python context manager in the AuditedSQLite class?
   _________________________________________________________________

5. What information does our audit system capture for each query?
   _________________________________________________________________

### 🏆 1.8: Challenge Exercises

**Challenge 1: Add User Agent Logging**

Enhance the audit system to log the User-Agent header:

1. Modify the `userContext` to include `agent`
2. Add a `user_agent` column to the audit table
3. Update the INSERT statement to include it
4. Modify the console output to show the agent

**Challenge 2: Add Parameter Redaction**

Implement parameter redaction for sensitive fields:

1. Create a `redactParams` function
2. Replace values like 'password', 'ssn', 'credit_card' with '[REDACTED]'
3. Apply redaction before logging

**Challenge 3: Audit Table Partitioning**

Implement date-based partitioning for the audit table:

1. Create a partition for the current month
2. Automatically create partitions for future months
3. Implement partition cleanup for old data

### ⚠️ 1.9: Troubleshooting Guide

| Problem | Possible Solution |
|---------|-------------------|
| `DATABASE_URL not set` | Create .env file with DATABASE_URL |
| `relation "dam_audit_logs" does not exist` | Check table creation and permissions |
| `Could not connect to database` | Verify Neon connection string |
| `Permission denied` | Check file permissions for SQLite |
| `Module not found` | Run `npm install` |
| `Python module not found` | Check Python path and installation |

### 📝 1.10: Part 1 Reflection

**What I learned:**
_________________________________________________________________

**What was challenging:**
_________________________________________________________________

**What I want to learn more about:**
_________________________________________________________________

---

# SECTION 2: PART 2 WORKBOOK

## Part 2: Interception & Native Hooks

### 📖 2.1: Learning Objectives

By completing this part, you will be able to:
- [ ] Explain why application-layer auditing isn't enough
- [ ] Implement driver-level interception for PostgreSQL
- [ ] Implement native-level interception for SQLite
- [ ] Combine multiple interception layers
- [ ] Test interception coverage

### 💻 2.2: JavaScript Driver Interceptor

**Exercise 2.2.1: Create the DriverInterceptor**

Create `javascript/src/driver-interceptor.js` and fill in the missing parts:

```javascript
// javascript/src/driver-interceptor.js

import pkg from 'pg';
const { Pool, Client } = pkg;

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

    // Wrap the pool's query method
    pool.query = async function(...args) {
      let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text;
      let params = typeof args[0] === 'object' ? args[0]?.values : args[1];

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
          `[DRIVER INTERCEPTOR] Pool query: ${queryText.substring(0, 100)}...`
        );
      }

      return self.originalQuery(...args);
    };

    // Intercept new clients
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
      let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text;
      let params = typeof args[0] === 'object' ? args[0]?.values : args[1];

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
          `[DRIVER INTERCEPTOR] Client query: ${queryText.substring(0, 100)}...`
        );
      }

      return originalClientQuery(...args);
    };

    self.interceptedClients.add(client);
  }

  uninstall() {
    this.db.query = this.originalQuery;
    console.log('[DRIVER INTERCEPTOR] Uninstalled successfully');
  }
}
```

**Exercise 2.2.2: Create EnhancedAuditedPool**

Create `javascript/src/enhanced-audited-pool.js`:

```javascript
// javascript/src/enhanced-audited-pool.js

import { AuditedPool } from './audited-pool.js';
import { DriverInterceptor } from './driver-interceptor.js';

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
      }
    });
  }

  async close() {
    if (this.driverInterceptor) {
      this.driverInterceptor.uninstall();
    }
    await super.close();
  }
}
```

### 💻 2.3: Python Native Interceptor

**Exercise 2.3.1: Create NativeInterceptor**

Create `python/native_interceptor.py`:

```python
# python/native_interceptor.py

import sqlite3
import threading
from typing import Callable, Optional

class NativeInterceptor:
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

**Exercise 2.3.2: Create AuditedNativeSQLite**

Create `python/audited_native_sqlite.py`:

```python
# python/audited_native_sqlite.py

import sqlite3
from datetime import datetime, timezone
from native_interceptor import NativeInterceptor

class AuditedNativeSQLite:
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
                captured_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        """)
        self.connection.commit()

    def _native_audit_callback(self, sql: str) -> None:
        self.connection.execute(
            "INSERT INTO native_audit_logs (sql_statement) VALUES (?)",
            (sql,)
        )
        self.connection.commit()
        print(
            f"[NATIVE AUDIT] {datetime.now(timezone.utc).isoformat()} | "
            f"Query: {sql[:100]}{'...' if len(sql) > 100 else ''}"
        )

    def enable_native_interception(self) -> None:
        self.interceptor = NativeInterceptor(self.connection)
        self.interceptor.set_callback(self._native_audit_callback)

    def disable_native_interception(self) -> None:
        if self.interceptor:
            self.interceptor.uninstall()
            self.interceptor = None

    def execute(self, sql: str, params: tuple = ()) -> sqlite3.Cursor:
        print(f"[APP AUDIT] Executing: {sql[:100]}{'...' if len(sql) > 100 else ''}")
        cursor = self.connection.execute(sql, params)
        self.connection.commit()
        return cursor

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

### 💻 2.4: Interception Tests

**Exercise 2.4.1: JavaScript Interception Test**

Create `javascript/tests/test-driver-interception.js`:

```javascript
// javascript/tests/test-driver-interception.js

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
  console.log('✅ EnhancedAuditedPool created\n');

  try {
    // TEST 1: Query through AuditedPool
    console.log('📝 TEST 1: Query through AuditedPool');
    await pool.query(
      'SELECT NOW()',
      [],
      { id: 'test-user', ip: '127.0.0.1' }
    );
    console.log('   ✅ Query executed through AuditedPool');

    // TEST 2: Query through raw connection
    console.log('\n📝 TEST 2: Query through raw connection');
    const underlyingPool = pool.getUnderlyingPool();
    const rawClient = await underlyingPool.connect();
    try {
      await rawClient.query('SELECT NOW()');
      console.log('   ✅ Query executed through raw connection');
    } finally {
      rawClient.release();
    }

    console.log('\n✅ All tests completed!');
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await pool.close();
  }
}

testDriverInterception();
```

**Exercise 2.4.2: Python Interception Test**

Create `python/test_native_interception.py`:

```python
# python/test_native_interception.py

import sqlite3
from native_interceptor import NativeInterceptor

def test_native_interception():
    print("🧪 Testing Native-Level Interception...\n")
    
    conn = sqlite3.connect(':memory:')
    conn.execute("CREATE TABLE test (id INTEGER)")
    conn.commit()
    
    intercepted = []
    
    def callback(sql: str) -> None:
        intercepted.append(sql)
        print(f"[INTERCEPTED] {sql[:80]}...")
    
    interceptor = NativeInterceptor(conn)
    interceptor.set_callback(callback)
    
    try:
        print("📝 Executing queries...")
        conn.execute("INSERT INTO test VALUES (1)")
        conn.execute("INSERT INTO test VALUES (2)")
        conn.execute("SELECT * FROM test")
        conn.commit()
        print(f"   ✅ {len(intercepted)} queries executed")
    finally:
        interceptor.uninstall()
        conn.close()
    
    print(f"\n✅ Intercepted {len(intercepted)} queries")
    for i, q in enumerate(intercepted, 1):
        print(f"   {i}. {q[:80]}...")

if __name__ == "__main__":
    test_native_interception()
```

### ✅ 2.5: Verification Checkpoints

**Checkpoint 1: JavaScript Interception**

Run the interception test:
```bash
cd javascript
node tests/test-driver-interception.js
```

**Expected:** Both the AuditedPool and raw connection queries are intercepted

**Did it work?** ☐ Yes ☐ No

**Checkpoint 2: Python Interception**

Run the interception test:
```bash
cd python
python test_native_interception.py
```

**Expected:** All queries are intercepted at the native level

**Did it work?** ☐ Yes ☐ No

### ❓ 2.6: Knowledge Checks

1. Why is application-layer auditing insufficient on its own?
   _________________________________________________________________

2. What is the difference between driver-level and native-level interception?
   _________________________________________________________________

3. What is the WeakSet used for in the JavaScript driver interceptor?
   _________________________________________________________________

4. How does the SQLite native trace callback work?
   _________________________________________________________________

5. What are the three interception layers we've implemented?
   _________________________________________________________________

### 🏆 2.7: Challenge Exercises

**Challenge 1: Add PostgreSQL pgaudit**

Enable PostgreSQL's built-in pgaudit extension for native-level Postgres interception:

1. Enable pgaudit in your Neon database
2. Configure pgaudit to log all queries
3. Create a mechanism to read pgaudit logs

**Challenge 2: Intercept Connection Parameters**

Enhance the driver interceptor to capture connection parameters:

1. Log database names and usernames
2. Track connection timing
3. Detect unusual connection patterns

**Challenge 3: Multi-Threaded Interception**

Implement thread-safe interception for Python SQLite:

1. Use thread-local storage
2. Handle multiple connections safely
3. Test with concurrent queries

---

# SECTION 3: PART 3 WORKBOOK

## Part 3: Real-Time Parsing & Query Normalization

### 📖 3.1: Learning Objectives

By completing this part, you will be able to:
- [ ] Explain why query normalization is important
- [ ] Implement string and numeric literal replacement
- [ ] Normalize IN clauses and whitespace
- [ ] Generate query fingerprints
- [ ] Store normalized queries in audit tables

### 💻 3.2: JavaScript QueryNormalizer

**Exercise 3.2.1: Create the QueryNormalizer**

Create `javascript/src/normalizer.js` and fill in the missing parts:

```javascript
// javascript/src/normalizer.js

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
    // Replace single-quoted strings with '?'
    let result = sql.replace(/'[^']*(?:''[^']*)*'/g, "'?'");
    
    // Protect double-quoted identifiers
    const identifiers = [];
    result = result.replace(/"[^"]*"/g, (match) => {
      identifiers.push(match);
      return `__IDENTIFIER_${identifiers.length - 1}__`;
    });
    
    // Restore identifiers
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
    const queryTypeMatch = normalized.match(/^\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|TRUNCATE)/i);
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

### 💻 3.3: Python QueryNormalizer

**Exercise 3.3.1: Create Python QueryNormalizer**

Create `python/normalizer.py`:

```python
# python/normalizer.py

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
            r'^\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER|TRUNCATE)',
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

### 💻 3.4: Normalization Tests

**Exercise 3.4.1: JavaScript Normalizer Test**

Create `javascript/tests/test-normalizer.js`:

```javascript
// javascript/tests/test-normalizer.js

import { QueryNormalizer } from '../src/normalizer.js';

function testNormalizer() {
  console.log('🧪 Testing Query Normalizer...\n');
  
  const normalizer = new QueryNormalizer();
  const testCases = [
    ["SELECT * FROM users WHERE email = 'alice@example.com'", 
     "SELECT * FROM users WHERE email = '?'"],
    ["SELECT * FROM products WHERE price > 100 AND stock < 50",
     "SELECT * FROM products WHERE price > ? AND stock < ?"],
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
    console.log(`   Raw:   ${raw.substring(0, 60)}...`);
    console.log(`   Norm:  ${normalized}`);
    console.log(`   ${isMatch ? '✅ PASS' : '❌ FAIL'}`);
    if (isMatch) passed++;
  });
  
  console.log(`\n📊 Results: ${passed}/${testCases.length} passed`);
}

testNormalizer();
```

**Exercise 3.4.2: Python Normalizer Test**

Create `python/test_normalizer.py`:

```python
# python/test_normalizer.py

from normalizer import QueryNormalizer, NormalizationOptions

def test_normalizer():
    print("🧪 Testing Query Normalizer...\n")
    
    normalizer = QueryNormalizer()
    
    test_cases = [
        ("SELECT * FROM users WHERE email = 'alice@example.com'",
         "SELECT * FROM users WHERE email = '?'"),
        ("SELECT * FROM products WHERE price > 100 AND stock < 50",
         "SELECT * FROM products WHERE price > ? AND stock < ?"),
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
        print(f"   Raw:   {raw[:60]}...")
        print(f"   Norm:  {normalized}")
        print(f"   {'✅ PASS' if is_match else '❌ FAIL'}")
        if is_match:
            passed += 1
    
    print(f"\n📊 Results: {passed}/{len(test_cases)} passed")

if __name__ == "__main__":
    test_normalizer()
```

### ✅ 3.5: Verification Checkpoints

**Checkpoint 1: JavaScript Normalization**

Run the normalizer test:
```bash
cd javascript
node tests/test-normalizer.js
```

**Expected:** All test cases pass

**Did it work?** ☐ Yes ☐ No

**Checkpoint 2: Python Normalization**

Run the normalizer test:
```bash
cd python
python test_normalizer.py
```

**Expected:** All test cases pass

**Did it work?** ☐ Yes ☐ No

### ❓ 3.6: Knowledge Checks

1. What is query normalization and why is it important?
   _________________________________________________________________

2. What types of literals does our normalizer replace?
   _________________________________________________________________

3. What is a query fingerprint and how is it used?
   _________________________________________________________________

4. Why do we normalize IN clauses differently?
   _________________________________________________________________

5. How does normalization protect privacy?
   _________________________________________________________________

### 🏆 3.7: Challenge Exercises

**Challenge 1: SQL Formatting Preserver**

Modify the normalizer to preserve specific formatting:

1. Add an option to preserve comments
2. Add an option to preserve case
3. Add an option to preserve line breaks

**Challenge 2: Advanced IN Clause Normalization**

Handle nested IN clauses:

1. Detect nested IN clauses
2. Normalize each level independently
3. Preserve the structure

**Challenge 3: Parameter Position Tracking**

Track the positions of replaced parameters:

1. Create a mapping of parameter positions
2. Maintain the mapping in the normalized string
3. Use for parameter analysis

---

# SECTION 4: PART 4 WORKBOOK

## Part 4: Behavioral Rules & SQL Injection Detection

### 📖 4.1: Learning Objectives

By completing this part, you will be able to:
- [ ] Explain the difference between pattern matching and heuristics
- [ ] Build a threat detection engine with rules
- [ ] Implement SQL injection detection
- [ ] Implement DDL operation blocking
- [ ] Create threat scoring and level assignment

### 💻 4.2: JavaScript ThreatDetector

**Exercise 4.2.1: Create the ThreatDetector**

Create `javascript/src/threat-detector.js`:

```javascript
// javascript/src/threat-detector.js

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
      'credit_cards', 'payment', 'banking', 'financial',
      'customers', 'employees', 'patients', 'medical'
    ];
    
    this.whitelist = [];
    this.loadDefaultWhitelist();
    
    this.detectionHistory = new Map();
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
      description: 'Detects ALTER TABLE operations'
    });

    // Privilege Escalation Rules
    this.addRule({
      id: 'priv_grant',
      name: 'GRANT Privilege Attempt',
      category: ThreatCategory.PRIVILEGE_ESCALATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /GRANT\s+/i,
      description: 'Detects GRANT operations'
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
      return { threatDetected: false, whitelisted: true };
    }

    const findings = [];
    let totalScore = 0;
    
    if (this.options.enablePatternMatching) {
      for (const rule of this.rules) {
        if (!rule.pattern) continue;
        if (rule.pattern.test(query)) {
          const severityScore = this.getSeverityScore(rule.severity);
          totalScore += severityScore;
          findings.push({ rule, matched: true, score: severityScore });
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
        score: this.getSeverityScore(ThreatLevel.HIGH)
      });
    }
    
    if (/sleep|delay|waitfor/i.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_time_based',
          name: 'Time-Based Injection',
          category: ThreatCategory.SQL_INJECTION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'Time-based injection attempt'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH)
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
    
    if (history.length > 100) {
      findings.push({
        rule: {
          id: 'heuristic_brute_force',
          name: 'Brute Force Detection',
          category: ThreatCategory.BRUTE_FORCE,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: `${history.length} queries in last minute`
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH)
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

  determineAction(detection) {
    if (detection.whitelisted) return 'ALLOW';
    if (!detection.threatDetected) return 'ALLOW';
    
    for (const finding of detection.findings) {
      if (finding.rule.type === RuleType.BLOCK) {
        return 'BLOCK';
      }
    }
    
    if (detection.score >= 15) return 'BLOCK';
    
    for (const finding of detection.findings) {
      if (finding.rule.type === RuleType.WARN) {
        return 'WARN';
      }
    }
    
    return 'LOG';
  }
}
```

### 💻 4.3: Threat Detection Tests

**Exercise 4.3.1: JavaScript Threat Detection Test**

Create `javascript/tests/test-threat-detector.js`:

```javascript
// javascript/tests/test-threat-detector.js

import { ThreatDetector } from '../src/threat-detector.js';

function testThreatDetector() {
  console.log('🧪 Testing Threat Detector...\n');
  
  const detector = new ThreatDetector();
  const testCases = [
    { query: "SELECT * FROM users WHERE id = 1", shouldDetect: false, desc: "Normal query" },
    { query: "SELECT * FROM users WHERE email = '' OR 1=1 --'", shouldDetect: true, desc: "SQL Injection (tautology)" },
    { query: "SELECT * FROM users UNION SELECT * FROM admins", shouldDetect: true, desc: "SQL Injection (UNION)" },
    { query: "SELECT * FROM users; DROP TABLE users", shouldDetect: true, desc: "Stacked Query" },
    { query: "DROP TABLE users", shouldDetect: true, desc: "DROP TABLE" },
    { query: "TRUNCATE TABLE users", shouldDetect: true, desc: "TRUNCATE" },
    { query: "SELECT * FROM passwords", shouldDetect: true, desc: "Sensitive table" },
    { query: "SELECT SLEEP(5) FROM users", shouldDetect: true, desc: "Time-based injection" }
  ];
  
  let passed = 0;
  testCases.forEach((tc, idx) => {
    const result = detector.analyze(tc.query, { userId: 'test', ip: '127.0.0.1' });
    const passedTest = result.threatDetected === tc.shouldDetect;
    
    console.log(`\n📝 Test ${idx + 1}: ${tc.desc}`);
    console.log(`   Detected: ${result.threatDetected ? '✅ Yes' : '❌ No'}`);
    console.log(`   Expected: ${tc.shouldDetect ? '✅ Yes' : '❌ No'}`);
    console.log(`   Score: ${result.score}`);
    console.log(`   Level: ${result.level}`);
    console.log(`   ${passedTest ? '✅ PASS' : '❌ FAIL'}`);
    if (passedTest) passed++;
  });
  
  console.log(`\n📊 Results: ${passed}/${testCases.length} passed`);
}

testThreatDetector();
```

### 💻 4.4: Python ThreatDetector

**Exercise 4.4.1: Create Python ThreatDetector**

Create `python/threat_detector.py`:

```python
# python/threat_detector.py

import re
from enum import Enum
from typing import Dict, Any, Optional, List
from collections import defaultdict
from normalizer import QueryNormalizer, NormalizationOptions

class ThreatLevel(Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"

class ThreatCategory(Enum):
    SQL_INJECTION = "SQL_INJECTION"
    DDL_OPERATION = "DDL_OPERATION"
    PRIVILEGE_ESCALATION = "PRIVILEGE_ESCALATION"
    DATA_EXFILTRATION = "DATA_EXFILTRATION"
    BRUTE_FORCE = "BRUTE_FORCE"
    SUSPICIOUS_PATTERN = "SUSPICIOUS_PATTERN"

class RuleType(Enum):
    BLOCK = "BLOCK"
    WARN = "WARN"
    LOG = "LOG"
    SCORE = "SCORE"

class ThreatRule:
    def __init__(self, rule_id: str, name: str, category: ThreatCategory,
                 severity: ThreatLevel, rule_type: RuleType,
                 pattern: Optional[str] = None,
                 description: str = ""):
        self.id = rule_id
        self.name = name
        self.category = category
        self.severity = severity
        self.type = rule_type
        self.pattern = re.compile(pattern, re.IGNORECASE) if pattern else None
        self.description = description

class ThreatDetector:
    def __init__(self, options: Optional[Dict[str, Any]] = None):
        self.options = {
            'enable_pattern_matching': True,
            'enable_heuristics': True,
            'enable_threat_scoring': True,
            'log_all_detections': True,
            ** (options or {})
        }
        
        self.normalizer = QueryNormalizer(
            NormalizationOptions(case_insensitive=True)
        )
        self.rules: List[ThreatRule] = []
        self._load_default_rules()
        
        self.sensitive_tables = {
            'users', 'passwords', 'credentials', 'secrets',
            'customers', 'employees', 'patients', 'medical',
            'credit_cards', 'payment', 'banking', 'financial'
        }
        
        self.whitelist: List[re.Pattern] = []
        self._load_default_whitelist()
        
        self.detection_history = defaultdict(list)

    def _load_default_rules(self):
        # SQL Injection Rules
        self.add_rule(ThreatRule(
            rule_id='sqli_tautology',
            name='Tautology SQL Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.HIGH,
            rule_type=RuleType.BLOCK,
            pattern=r"OR\s+['\"]?1['\"]?\s*=\s*['\"]?1",
            description='Detects tautology attempts (OR 1=1)'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='sqli_union',
            name='Union SQL Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"UNION\s+SELECT",
            description='Detects UNION SELECT injection attempts'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='sqli_stacked',
            name='Stacked Query Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r";\s*(DROP|DELETE|UPDATE|INSERT|TRUNCATE|CREATE|ALTER)",
            description='Detects stacked query injection attempts'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='ddl_drop_table',
            name='DROP TABLE Attempt',
            category=ThreatCategory.DDL_OPERATION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"DROP\s+TABLE",
            description='Detects DROP TABLE operations'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='ddl_truncate',
            name='TRUNCATE Attempt',
            category=ThreatCategory.DDL_OPERATION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"TRUNCATE\s+TABLE",
            description='Detects TRUNCATE TABLE operations'
        ))

    def _load_default_whitelist(self):
        safe_patterns = [
            r"^SET\s+",
            r"^SHOW\s+",
            r"^DESCRIBE\s+",
            r"^EXPLAIN\s+"
        ]
        for pattern in safe_patterns:
            self.whitelist.append(re.compile(pattern, re.IGNORECASE))

    def add_rule(self, rule: ThreatRule) -> None:
        self.rules.append(rule)

    def is_whitelisted(self, query: str) -> bool:
        for pattern in self.whitelist:
            if pattern.search(query):
                return True
        return False

    def get_severity_score(self, severity: ThreatLevel) -> int:
        scores = {
            ThreatLevel.LOW: 1,
            ThreatLevel.MEDIUM: 5,
            ThreatLevel.HIGH: 10,
            ThreatLevel.CRITICAL: 25
        }
        return scores.get(severity, 0)

    def get_threat_level(self, score: int) -> ThreatLevel:
        if score >= 25:
            return ThreatLevel.CRITICAL
        if score >= 10:
            return ThreatLevel.HIGH
        if score >= 5:
            return ThreatLevel.MEDIUM
        if score >= 1:
            return ThreatLevel.LOW
        return ThreatLevel.LOW

    def analyze(self, query: str, context: Dict[str, str] = None) -> Dict[str, Any]:
        context = context or {}
        normalized = self.normalizer.normalize(query)
        
        if self.is_whitelisted(query):
            return {'threat_detected': False, 'whitelisted': True}
        
        findings = []
        total_score = 0
        
        if self.options['enable_pattern_matching']:
            for rule in self.rules:
                if not rule.pattern:
                    continue
                if rule.pattern.search(query):
                    severity_score = self.get_severity_score(rule.severity)
                    total_score += severity_score
                    findings.append({
                        'rule': rule,
                        'matched': True,
                        'score': severity_score
                    })
        
        if self.options['enable_heuristics']:
            heuristic_findings = self._run_heuristics(query, normalized, context)
            findings.extend(heuristic_findings)
            total_score += sum(f['score'] for f in heuristic_findings)
        
        if self.options['enable_threat_scoring']:
            freq_findings = self._analyze_frequency(query, context)
            findings.extend(freq_findings)
            total_score += sum(f['score'] for f in freq_findings)
        
        level = self.get_threat_level(total_score)
        
        return {
            'threat_detected': bool(findings),
            'score': total_score,
            'level': level,
            'findings': findings,
            'normalized': normalized,
            'whitelisted': False
        }

    def _run_heuristics(self, query: str, normalized: str,
                       context: Dict[str, str]) -> List[Dict[str, Any]]:
        findings = []
        
        sensitive_pattern = re.compile('|'.join(self.sensitive_tables), re.IGNORECASE)
        if sensitive_pattern.search(query):
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_sensitive_table',
                    name='Sensitive Table Access',
                    category=ThreatCategory.DATA_EXFILTRATION,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description='Access to sensitive table detected'
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH)
            })
        
        if re.search(r"sleep|delay|waitfor", query, re.IGNORECASE):
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_time_based',
                    name='Time-Based Injection',
                    category=ThreatCategory.SQL_INJECTION,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description='Time-based injection attempt'
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH)
            })
        
        return findings

    def _analyze_frequency(self, query: str,
                          context: Dict[str, str]) -> List[Dict[str, Any]]:
        findings = []
        key = f"{context.get('user_id', 'unknown')}:{context.get('ip', 'unknown')}"
        now = datetime.now()
        
        self.detection_history[key].append(now)
        
        one_minute_ago = now - timedelta(minutes=1)
        self.detection_history[key] = [
            t for t in self.detection_history[key]
            if t > one_minute_ago
        ]
        
        if len(self.detection_history[key]) > 100:
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_brute_force',
                    name='Brute Force Detection',
                    category=ThreatCategory.BRUTE_FORCE,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description=f"{len(self.detection_history[key])} queries in last minute"
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH)
            })
        
        return findings

    def determine_action(self, detection: Dict[str, Any]) -> str:
        if detection.get('whitelisted', False):
            return 'ALLOW'
        
        if not detection.get('threat_detected', False):
            return 'ALLOW'
        
        for finding in detection['findings']:
            if finding['rule'].type == RuleType.BLOCK:
                return 'BLOCK'
        
        if detection.get('score', 0) >= 15:
            return 'BLOCK'
        
        for finding in detection['findings']:
            if finding['rule'].type == RuleType.WARN:
                return 'WARN'
        
        return 'LOG'
```

### ✅ 4.5: Verification Checkpoints

**Checkpoint 1: JavaScript Threat Detection**

Run the threat detection test:
```bash
cd javascript
node tests/test-threat-detector.js
```

**Expected:** All threat detection tests pass

**Did it work?** ☐ Yes ☐ No

**Checkpoint 2: Python Threat Detection**

Create and run `python/test_threat_detector.py` (similar to JavaScript version)

**Expected:** All threat detection tests pass

**Did it work?** ☐ Yes ☐ No

### ❓ 4.6: Knowledge Checks

1. What is the difference between pattern matching and heuristic detection?
   _________________________________________________________________

2. What is a tautology attack and how does our system detect it?
   _________________________________________________________________

3. What is the purpose of the threat score?
   _________________________________________________________________

4. How does frequency analysis detect brute force attacks?
   _________________________________________________________________

5. What is the role of the whitelist in threat detection?
   _________________________________________________________________

### 🏆 4.7: Challenge Exercises

**Challenge 1: Add Custom Rules**

Add custom rules for your environment:

1. Create a rule for your organization's specific threats
2. Add a rule to block dangerous stored procedures
3. Implement a rule for schema change detection

**Challenge 2: Machine Learning Integration**

Implement a simple anomaly detection model:

1. Train a model on normal query patterns
2. Detect deviations from normal
3. Score based on the deviation

---

# SECTION 5: PART 5 WORKBOOK

## Part 5: Automated Remediation & Incident Response Orchestration

### 📖 5.1: Learning Objectives

By completing this part, you will be able to:
- [ ] Explain the incident response lifecycle
- [ ] Build an incident response orchestrator
- [ ] Implement circuit breaker pattern
- [ ] Create an immutable incident vault
- [ ] Integrate all DAM components

### 💻 5.2: JavaScript IncidentResponder

**Exercise 5.2.1: Create the IncidentResponder**

Create `javascript/src/incident-responder.js`:

```javascript
// javascript/src/incident-responder.js

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
      }
    } catch (error) {
      console.error('[INCIDENT RESPONDER] Failed to initialize vault:', error);
    }
  }

  async handleIncident(incident) {
    const timestamp = new Date().toISOString();
    const incidentId = this.generateIncidentId();
    
    console.log(`\n[INCIDENT RESPONDER] Handling incident ${incidentId}`);
    
    const validationResult = await this.validateIncident(incident);
    if (!validationResult.shouldRespond) {
      return { incidentId, handled: false, reason: validationResult.reason };
    }
    
    const responsePlan = this.generateResponsePlan(incident);
    const responseResults = await this.executeResponsePlan(responsePlan, incident);
    const vaultEntry = await this.recordIncident(incidentId, timestamp, incident, responseResults);
    this.updateStats(incident, responseResults);
    await this.postResponseActions(incident, responseResults, vaultEntry);
    
    return { incidentId, handled: true, responseResults, vaultEntry };
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
        return { success: true, message: 'Query blocked', timestamp: new Date().toISOString() };
      
      case ResponseAction.TERMINATE_CONNECTION:
        if (incident.dbConnection) {
          try {
            await incident.dbConnection.end();
            return { success: true, message: 'Connection terminated', timestamp: new Date().toISOString() };
          } catch (error) {
            return { success: false, error: error.message };
          }
        }
        return { success: false, error: 'No connection to terminate' };
      
      case ResponseAction.NOTIFY_SECURITY:
        if (this.options.notifySecurity) {
          await this.notifySecurityTeam(incident);
        }
        this.stats.notificationsSent++;
        return { success: true, message: 'Security team notified', timestamp: new Date().toISOString() };
      
      case ResponseAction.CIRCUIT_BREAKER:
        this.activateCircuitBreaker(incident);
        return { success: true, message: 'Circuit breaker activated', timestamp: new Date().toISOString() };
      
      case ResponseAction.ISOLATE_USER:
        console.log(`[ACTION] Isolating user: ${incident.userContext?.id}`);
        return { success: true, message: `User ${incident.userContext?.id} isolated` };
      
      case ResponseAction.LOG_INCIDENT:
        return { success: true, message: 'Incident logged' };
      
      default:
        return { success: false, error: `Unknown action: ${action}` };
    }
  }

  activateCircuitBreaker(incident) {
    this.circuitBreakerActive = true;
    this.circuitBreakerExpiry = Date.now() + 5 * 60 * 1000;
    console.log(`[CIRCUIT BREAKER] Activated for ${incident.userContext?.id}`);
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
  }

  async postResponseActions(incident, responseResults, vaultEntry) {
    if (incident.threatLevel === IncidentSeverity.CRITICAL) {
      console.log('[POST-RESPONSE] Updating security rules based on incident...');
    }
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

  async validateIncident(incident) {
    if (!incident.query) {
      return { shouldRespond: false, reason: 'No query provided' };
    }
    return { shouldRespond: true, reason: 'Valid incident' };
  }

  getStats() {
    return { ...this.stats };
  }
}
```

### 💻 5.3: Complete DAM Integration

**Exercise 5.3.1: Create Complete DAM System**

Create `javascript/src/complete-dam-system.js`:

```javascript
// javascript/src/complete-dam-system.js

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
    this.incidentResponder = null;
    this.isInitialized = false;
  }

  async initialize() {
    if (this.isInitialized) return;
    
    console.log('[DAM SYSTEM] Initializing...');
    
    this.auditPool = new SecureAuditedPool(
      this.options.connectionString,
      this.options.securePoolOptions
    );
    
    this.incidentResponder = new IncidentResponder(
      this.options.incidentResponderOptions
    );
    
    this.isInitialized = true;
    console.log('[DAM SYSTEM] Initialized successfully');
  }

  async query(query, params = [], userContext = {}) {
    if (!this.isInitialized) {
      throw new Error('[DAM SYSTEM] System not initialized');
    }
    
    if (this.incidentResponder.isCircuitBreakerActive()) {
      throw new Error('[DAM SYSTEM] Circuit breaker is active');
    }
    
    try {
      return await this.auditPool.query(query, params, userContext);
    } catch (error) {
      if (error.message.includes('[SECURITY]')) {
        if (this.options.enableIncidentResponse) {
          await this.incidentResponder.handleIncident({
            query: query,
            params: params,
            userContext: userContext,
            threatLevel: IncidentSeverity.HIGH,
            findings: error.findings || [],
            dbConnection: this.auditPool.pool
          });
        }
      }
      throw error;
    }
  }

  getStatus() {
    return {
      initialized: this.isInitialized,
      stats: {
        audit: this.auditPool ? 'Active' : 'Inactive',
        threatDetection: this.auditPool ? 'Active' : 'Inactive',
        incidentResponse: this.incidentResponder ? 'Active' : 'Inactive',
        circuitBreaker: this.incidentResponder?.isCircuitBreakerActive() || false
      },
      incidentStats: this.incidentResponder?.getStats() || {}
    };
  }

  async shutdown() {
    if (this.auditPool) {
      await this.auditPool.close();
    }
    this.isInitialized = false;
    console.log('[DAM SYSTEM] Shutdown complete');
  }
}

export function createDAMSystem(options = {}) {
  return new CompleteDAMSystem(options);
}
```

### ✅ 5.4: Verification Checkpoints

**Checkpoint 1: Complete System Test**

Create and run `tests/test-complete-system.js`:

```javascript
// tests/test-complete-system.js
import { createDAMSystem } from '../src/complete-dam-system.js';

async function testCompleteSystem() {
  console.log('🧪 Testing Complete DAM System...\n');
  
  const system = createDAMSystem({
    incidentResponderOptions: {
      vaultPath: './test_incident_vault.jsonl',
      notifySecurity: true,
      cooldownPeriod: 5000
    }
  });
  
  await system.initialize();
  
  try {
    // Test 1: Normal query
    console.log('📝 Test 1: Normal query');
    await system.query('SELECT NOW()', [], { id: 'test-user', ip: '127.0.0.1' });
    console.log('  ✅ Query executed');
    
    // Test 2: SQL Injection (should be blocked)
    console.log('\n📝 Test 2: SQL Injection (should be blocked)');
    try {
      await system.query("SELECT * FROM users WHERE email = '' OR 1=1 --'", [], 
        { id: 'attacker', ip: '192.168.1.200' });
    } catch (error) {
      console.log(`  ✅ Query blocked: ${error.message.substring(0, 80)}...`);
    }
    
    // Get status
    console.log('\n📊 System Status:');
    console.log(JSON.stringify(system.getStatus(), null, 2));
    
  } finally {
    await system.shutdown();
  }
}

testCompleteSystem();
```

**Expected:** Complete system tests pass, threats are blocked

**Did it work?** ☐ Yes ☐ No

### ❓ 5.5: Knowledge Checks

1. What is the incident response lifecycle?
   _________________________________________________________________

2. What is the circuit breaker pattern and why is it important?
   _________________________________________________________________

3. Why is the incident vault append-only and immutable?
   _________________________________________________________________

4. What are the five response actions available in our system?
   _________________________________________________________________

5. How do all five parts work together as a complete system?
   _________________________________________________________________

### 🏆 5.6: Challenge Exercises

**Challenge 1: Add Custom Response Action**

Implement a new response action:

1. Add a new action type
2. Implement the action handler
3. Add it to the response plan generation
4. Test the new action

**Challenge 2: Slack Integration**

Replace console notifications with Slack:

1. Set up a Slack webhook
2. Create notification templates
3. Implement the Slack client
4. Test the integration

**Challenge 3: Distributed Vault**

Implement a distributed incident vault:

1. Use a distributed database
2. Implement cross-instance synchronization
3. Ensure consistency
4. Test with multiple instances

---

# SECTION 6: FINAL PROJECT

## 🏆 Final Project: Complete DAM System

### Project Overview

Build a complete Database Activity Management system that integrates all five parts and adds a REST API for monitoring.

### Requirements

**1. Core Components**
- [ ] Audit logging (Part 1)
- [ ] Multi-layer interception (Part 2)
- [ ] Query normalization (Part 3)
- [ ] Threat detection (Part 4)
- [ ] Incident response (Part 5)

**2. REST API**
- [ ] GET /status - System health
- [ ] GET /audit - Recent audit logs
- [ ] GET /threats - Recent threats
- [ ] GET /incidents - Incident history
- [ ] POST /rules - Add custom rule

**3. Documentation**
- [ ] API documentation
- [ ] Deployment guide
- [ ] Customization guide

### Implementation Outline

**JavaScript/Express API:**
```javascript
// api.js
import express from 'express';
import { createDAMSystem } from './complete-dam-system.js';

const app = express();
const system = createDAMSystem();

app.get('/status', (req, res) => {
  res.json(system.getStatus());
});

app.get('/audit', async (req, res) => {
  // Get recent audit logs
});

app.get('/threats', async (req, res) => {
  // Get recent threats
});

app.get('/incidents', async (req, res) => {
  // Get incident history
});

app.listen(3000);
```

### Verification

**Run the complete system:**
```bash
node api.js
```

**Test with curl:**
```bash
curl http://localhost:3000/status
curl http://localhost:3000/audit
curl http://localhost:3000/threats
curl http://localhost:3000/incidents
```

### Reflection Questions

1. How did the system integrate the five parts?
   _________________________________________________________________

2. What was the most challenging part of building the system?
   _________________________________________________________________

3. How would you deploy this to production?
   _________________________________________________________________

4. What customizations would you make for your organization?
   _________________________________________________________________

5. How does this system compare to commercial DAM solutions?
   _________________________________________________________________

---

## APPENDIX: ANSWER KEY

### Part 1 Knowledge Check Answers

1. An audit trail is a complete, chronological record of database activities. It's important for security investigations, compliance, and detecting insider threats.

2. The "before-during-after" pattern means: Before execution (capture context), during execution (run the query), after execution (log the result).

3. A separate connection avoids recursion (logging the audit log write itself).

4. The context manager ensures proper commit/rollback handling and always logs the result.

5. Query text, parameters, duration, user ID, IP address, status, error message, timestamp.

### Part 2 Knowledge Check Answers

1. Application-layer auditing misses queries that bypass the application (raw connections, admin tools).

2. Driver-level intercepts at the library level; native-level intercepts at the database engine level.

3. WeakSet prevents memory leaks by allowing garbage collection of intercepted clients.

4. SQLite's set_trace_callback registers a C-level callback that fires for every statement.

5. Application layer, driver layer, native layer.

### Part 3 Knowledge Check Answers

1. Query normalization strips literal values to reveal structural patterns for analysis and storage.

2. String literals, numeric literals, UUIDs, JSON literals.

3. A fingerprint is a hash of the normalized query used for fast pattern matching.

4. IN clauses with multiple values are normalized to a consistent number of placeholders.

5. By removing actual data values from logs, preventing PII/PHI exposure.

### Part 4 Knowledge Check Answers

1. Pattern matching looks for known attack signatures; heuristics look for suspicious behaviors.

2. A tautology attack uses OR 1=1 to make a condition always true; our system detects the pattern OR 1=1.

3. The threat score quantifies the severity of a detected threat to prioritize responses.

4. Frequency analysis tracks query volume per user; >100 queries/minute triggers an alert.

5. The whitelist prevents false positives by exempting safe query patterns.

### Part 5 Knowledge Check Answers

1. Detection → Containment → Eradication → Recovery → Investigation.

2. Circuit breaker stops all queries after multiple threats to prevent cascading failures.

3. Append-only prevents tampering, providing immutable evidence for investigations.

4. BLOCK_QUERY, TERMINATE_CONNECTION, NOTIFY_SECURITY, CIRCUIT_BREAKER, ISOLATE_USER.

5. Audit logging captures everything, interception catches all queries, normalization enables analysis, detection identifies threats, response takes action.

---

**[END OF STUDENT WORKBOOK]**

---

Congratulations on completing the DAM Tutorial Student Workbook! You now have a complete set of exercises, code templates, and verification checkpoints for every part of the series. Use this workbook alongside the tutorial and slide deck to build your Database Activity Management system.
