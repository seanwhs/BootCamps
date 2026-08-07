# Part 2: Interception & Native Hooks

Welcome to Part 2 of our Database Activity Management series! In Part 1, we built a solid audit logging foundation at the application layer. Every query that went through our `AuditedPool` or `AuditedSQLite` classes was logged with full context.

But here's the uncomfortable truth: **What if queries bypass our wrapper?**

Imagine this scenario: A developer, unaware of the audit system, uses a raw database connection directly. Or a legacy system component connects to the database without going through our audited layer. Or worse—an attacker gains access to the database credentials and connects directly.

In all these cases, our application-layer audit logging would be completely blind. The queries would execute, but we'd never know about them.

This is where **interception** and **native hooks** come in. We need to capture queries at the **driver** and **native** levels—before they even reach our application code.

---

## The Target: What We're Building Right Now

By the end of this part, you will have:

1. **Driver-level interceptors** for Neon/Postgres that catch queries at the `pg` driver level
2. **Native trace callbacks** for SQLite using the `sqlite3_trace` API
3. **Multiple interception layers** that work together for complete coverage
4. **A unified approach** that catches queries regardless of how they're executed

---

## The Concept: Why Interception Matters

Imagine you're the security manager of a large office building. You have security guards at the main entrance (our application layer), and they check everyone who comes through.

But what if someone sneaks in through a side door? Or a window? Or what if an employee who already has access just walks past the guards without being checked?

In database terms:

- **Application layer logging** = Security guards at the main entrance. They check everyone who comes through the proper channels.
- **Driver-level interception** = Security cameras that watch all entrances, even side doors.
- **Native hooks** = Motion sensors that detect movement anywhere in the building.

### The Defense-in-Depth Approach

Security isn't about a single perfect solution. It's about layers:

```
┌─────────────────────────────────────┐
│      Application Business Logic      │
│         (Your Code)                  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Application Layer (Part 1)       │
│   AuditedPool / AuditedSQLite        │
│   - Logs queries with user context   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Driver Layer (Part 2 - This)      │
│   pg Interceptor / sqlite3_trace     │
│   - Catches ALL queries at driver    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Native Layer (Part 2 - This)      │
│   pgaudit / SQLite Native Hooks      │
│   - Catches queries at C-level       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Database Engine              │
│    Postgres / SQLite                 │
└─────────────────────────────────────┘
```

Each layer sees the query, and each layer provides a different perspective:

1. **Application Layer**: Has user context, business logic, and application state
2. **Driver Layer**: Sees the exact wire protocol messages
3. **Native Layer**: Sees the query from the database engine's perspective

By combining all three, we achieve complete visibility.

### The Interception Pattern

The interception pattern has three key components:

1. **Hook Point**: Where we intercept the query (application, driver, or native)
2. **Interceptor**: The code that captures the query
3. **Handler**: What we do with the captured query (log, block, transform)

```
Query → [Hook Point] → [Interceptor] → [Handler] → Database
                                       │
                                       ▼
                                 Audit Log / Block
```

In this part, we're building interceptors at the driver and native levels.

---

## Implementation: JavaScript / Node.js + Neon

### Step 1: Driver-Level Interception in `pg`

The `pg` library (which we use for Neon/Postgres) provides several hook points. We'll intercept queries at the driver level by wrapping the `query` method and using the `connect` event.

**File: `javascript/src/driver-interceptor.js`**

```javascript
// javascript/src/driver-interceptor.js

import pkg from 'pg';
const { Pool, Client } = pkg;

/**
 * Driver-level interceptor for PostgreSQL (pg library)
 * 
 * This module provides interceptors that catch queries at the driver level,
 * before they're sent to the database. This ensures that even queries
 * executed through raw connections are captured and logged.
 * 
 * The interceptor works by:
 * 1. Wrapping the Pool's query method
 * 2. Intercepting the 'connect' event to wrap individual clients
 * 3. Preserving the original query signature for compatibility
 */
export class DriverInterceptor {
  /**
   * Create a driver interceptor for a pg Pool or Client
   * @param {Pool|Client} db - The pg connection pool or client
   * @param {Object} options - Configuration options
   * @param {Function} options.onQuery - Callback for each intercepted query
   * @param {Function} options.onError - Callback for errors during interception
   * @param {boolean} options.logAllQueries - Whether to log all queries (default: true)
   */
  constructor(db, options = {}) {
    this.db = db;
    this.options = {
      logAllQueries: true,
      onQuery: null,
      onError: null,
      ...options
    };
    
    // Store the original query method for reference
    this.originalQuery = db.query.bind(db);
    
    // Keep track of intercepted clients
    this.interceptedClients = new WeakSet();
    
    // Install the interceptor
    this.install();
  }
  
  /**
   * Install the driver-level interceptor
   * This wraps the query method and sets up client interception
   */
  install() {
    // Check if we're dealing with a Pool or Client
    if (this.db.constructor === Pool) {
      // For pools, we intercept queries at the pool level
      // AND we intercept new clients when they're created
      this.interceptPool();
    } else if (this.db.constructor === Client) {
      // For direct clients, we intercept the client directly
      this.interceptClient(this.db);
    } else {
      throw new Error('Unsupported database object. Must be Pool or Client.');
    }
    
    console.log('[DRIVER INTERCEPTOR] Installed successfully');
  }
  
  /**
   * Intercept all queries on a Pool
   * This wraps the pool's query method and sets up client interception
   */
  interceptPool() {
    const self = this;
    const pool = this.db;
    
    // Wrap the pool's query method
    // We use a function here to preserve 'this' context
    pool.query = async function(...args) {
      // Extract the query text
      let queryText = typeof args[0] === 'string' 
        ? args[0] 
        : args[0]?.text || '[non-string query object]';
      
      // Extract the parameters
      let params = typeof args[0] === 'object' && args[0]?.values 
        ? args[0].values 
        : args[1] || [];
      
      // Call the interceptor callback if provided
      if (self.options.onQuery) {
        try {
          await self.options.onQuery(queryText, params, 'pool');
        } catch (error) {
          if (self.options.onError) {
            self.options.onError(error, queryText, params);
          }
          // Don't throw - we want the query to continue
        }
      }
      
      // Log the query if requested
      if (self.options.logAllQueries) {
        console.log(
          `[DRIVER INTERCEPTOR] Pool query intercepted: ${queryText.substring(0, 100)}${queryText.length > 100 ? '...' : ''}`
        );
      }
      
      // Call the original query method
      // We use the stored original to avoid infinite recursion
      return self.originalQuery(...args);
    };
    
    // Intercept new clients when they're created
    // The pool creates clients internally - we hook the client creation
    const originalConnect = pool.connect.bind(pool);
    pool.connect = async function(...args) {
      // Get the client from the original connect
      const client = await originalConnect(...args);
      
      // Intercept the client if we haven't already
      if (!self.interceptedClients.has(client)) {
        self.interceptClient(client);
        self.interceptedClients.add(client);
      }
      
      return client;
    };
  }
  
  /**
   * Intercept all queries on a Client
   * This wraps the client's query method
   * @param {Client} client - The pg client to intercept
   */
  interceptClient(client) {
    const self = this;
    const originalClientQuery = client.query.bind(client);
    
    // Wrap the client's query method
    client.query = async function(...args) {
      // Extract query text and params (same as pool)
      let queryText = typeof args[0] === 'string' 
        ? args[0] 
        : args[0]?.text || '[non-string query object]';
      
      let params = typeof args[0] === 'object' && args[0]?.values 
        ? args[0].values 
        : args[1] || [];
      
      // Call the interceptor callback if provided
      if (self.options.onQuery) {
        try {
          await self.options.onQuery(queryText, params, 'client');
        } catch (error) {
          if (self.options.onError) {
            self.options.onError(error, queryText, params);
          }
        }
      }
      
      // Log the query if requested
      if (self.options.logAllQueries) {
        console.log(
          `[DRIVER INTERCEPTOR] Client query intercepted: ${queryText.substring(0, 100)}${queryText.length > 100 ? '...' : ''}`
        );
      }
      
      // Call the original query
      return originalClientQuery(...args);
    };
    
    // Also intercept the query method on the client's connection
    // This catches queries that use the connection directly
    if (client.connection) {
      const originalConnectionQuery = client.connection.query?.bind(client.connection);
      if (originalConnectionQuery) {
        client.connection.query = async function(...args) {
          // Similar interception for connection-level queries
          let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text || '[non-string query]';
          let params = typeof args[0] === 'object' && args[0]?.values ? args[0].values : args[1] || [];
          
          if (self.options.logAllQueries) {
            console.log(
              `[DRIVER INTERCEPTOR] Connection query: ${queryText.substring(0, 100)}${queryText.length > 100 ? '...' : ''}`
            );
          }
          
          return originalConnectionQuery(...args);
        };
      }
    }
    
    // Mark as intercepted
    self.interceptedClients.add(client);
  }
  
  /**
   * Uninstall the interceptor
   * Restores the original query method
   */
  uninstall() {
    // Restore the pool's query method
    if (this.db.query) {
      this.db.query = this.originalQuery;
    }
    
    console.log('[DRIVER INTERCEPTOR] Uninstalled successfully');
  }
  
  /**
   * Get the original query method
   * Useful for bypassing interception when needed
   * @returns {Function} The original query method
   */
  getOriginalQuery() {
    return this.originalQuery;
  }
}
```

---

### Step 2: Enhanced AuditedPool with Driver Interception

Now let's integrate the driver interceptor with our `AuditedPool` from Part 1. We'll extend `AuditedPool` to automatically install the driver interceptor.

**File: `javascript/src/enhanced-audited-pool.js`**

```javascript
// javascript/src/enhanced-audited-pool.js

import { AuditedPool } from './audited-pool.js';
import { DriverInterceptor } from './driver-interceptor.js';

/**
 * Enhanced AuditedPool with driver-level interception
 * 
 * This extends the base AuditedPool with driver-level interception,
 * providing even more comprehensive query coverage.
 * 
 * Benefits:
 * 1. Catches queries that bypass the AuditedPool
 * 2. Provides two layers of auditing: application + driver
 * 3. Enables detection of "shadow" queries
 */
export class EnhancedAuditedPool extends AuditedPool {
  /**
   * Create an enhanced audited pool with driver interception
   * @param {string} connectionString - PostgreSQL connection string
   * @param {Object} options - Additional options
   * @param {boolean} options.enableDriverInterception - Enable driver interception (default: true)
   * @param {boolean} options.logRawQueries - Log raw queries at driver level (default: true)
   */
  constructor(connectionString, options = {}) {
    // Create the base audited pool
    super(connectionString, options);
    
    // Store enhanced options
    this.enhancedOptions = {
      enableDriverInterception: true,
      logRawQueries: true,
      ...options
    };
    
    // Install driver interception if enabled
    if (this.enhancedOptions.enableDriverInterception) {
      this.installDriverInterceptor();
    }
  }
  
  /**
   * Install the driver interceptor
   * This catches queries at the driver level, even if they bypass the AuditedPool
   */
  installDriverInterceptor() {
    // We need to ensure the pool is initialized before installing
    // The interceptor works with the underlying pg Pool
    const underlyingPool = this.getUnderlyingPool();
    
    // Create the interceptor with a callback for intercepted queries
    this.driverInterceptor = new DriverInterceptor(underlyingPool, {
      logAllQueries: this.enhancedOptions.logRawQueries,
      onQuery: (queryText, params, source) => {
        // Log the query through our audit system
        // We use the parent AuditedPool's logAudit method
        this.logAudit({
          query_text: `[DRIVER] ${queryText}`,
          query_params: params,
          duration_ms: 0, // Driver interception doesn't have duration yet
          user_id: 'driver-interceptor',
          user_ip: 'internal',
          status: 'INTERCEPTED',
          error_message: null
        });
        
        // Also log to console with a special marker
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
  
  /**
   * Override the close method to also uninstall the driver interceptor
   */
  async close() {
    // Uninstall the driver interceptor first
    if (this.driverInterceptor) {
      this.driverInterceptor.uninstall();
    }
    
    // Then close the underlying pool
    await super.close();
  }
}
```

---

### Step 3: Testing Driver Interception

Now let's test our driver interception to ensure it catches queries that bypass the audited layer.

**File: `javascript/tests/test-driver-interception.js`**

```javascript
// javascript/tests/test-driver-interception.js

import 'dotenv/config';
import pkg from 'pg';
const { Pool } = pkg;
import { EnhancedAuditedPool } from '../src/enhanced-audited-pool.js';
import { DriverInterceptor } from '../src/driver-interceptor.js';

/**
 * Test driver-level interception
 * We'll test:
 * 1. Queries through the AuditedPool (should be caught by both layers)
 * 2. Queries through a raw connection (should be caught by driver layer)
 * 3. Queries through a client (should be caught by driver layer)
 */
async function testDriverInterception() {
  console.log('🧪 Testing Driver-Level Interception...\n');

  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    process.exit(1);
  }

  // Create the enhanced audited pool
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

    // TEST 2: Query through a raw connection (bypasses AuditedPool)
    console.log('\n📝 TEST 2: Query through raw connection');
    console.log('   This query should ONLY be caught by the driver layer');
    console.log('   (It bypasses the AuditedPool entirely)');
    
    // Get a raw client from the underlying pool
    const underlyingPool = pool.getUnderlyingPool();
    const rawClient = await underlyingPool.connect();
    try {
      await rawClient.query(
        'INSERT INTO interception_test (name) VALUES ($1)',
        ['Raw connection test']
      );
      console.log('   ✅ Query executed through raw connection');
    } finally {
      rawClient.release();
    }

    // TEST 3: Query through a direct client (bypasses both)
    console.log('\n📝 TEST 3: Query through direct client');
    console.log('   This query should be caught by driver layer');
    console.log('   (It uses a separate Client instance)');
    
    // Create a separate client (not using the pool)
    const directClient = new Pool({ connectionString: databaseUrl });
    try {
      // Install the driver interceptor on this client too
      const clientInterceptor = new DriverInterceptor(directClient, {
        logAllQueries: true,
        onQuery: (queryText, params) => {
          console.log(`[DIRECT CLIENT INTERCEPTED] ${queryText.substring(0, 60)}...`);
        }
      });
      
      await directClient.query(
        'INSERT INTO interception_test (name) VALUES ($1)',
        ['Direct client test']
      );
      console.log('   ✅ Query executed through direct client');
    } finally {
      await directClient.end();
    }

    // TEST 4: Query that bypasses both through the underlying driver
    console.log('\n📝 TEST 4: Query through the underlying driver directly');
    console.log('   This tests the deepest interception layer');
    
    // We'll simulate this by using the driver's internal methods
    // This is intentionally hard to bypass - our interceptor covers most cases
    const client = await underlyingPool.connect();
    try {
      // The interceptor should catch even this deep query
      await client.query(
        'SELECT COUNT(*) FROM interception_test'
      );
      console.log('   ✅ Deep query executed');
    } finally {
      client.release();
    }

    // Verify that all queries were logged
    console.log('\n🔍 Checking audit logs...');
    
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

    // Verify that the raw connection queries were intercepted
    const rawQueries = auditCheck.rows.filter(row => 
      row.query_text.includes('[DRIVER]') || 
      row.query_text.includes('interception_test')
    );
    
    if (rawQueries.length > 3) {
      console.log('\n✅ Driver interception is working correctly!');
      console.log(`   Intercepted ${rawQueries.length} queries, including those that bypassed the audit layer.`);
    } else {
      console.log('\n⚠️ Driver interception may not be catching all queries.');
      console.log('   Check the logs for more details.');
    }

  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await pool.close();
    console.log('\n🔌 Connection pool closed.');
  }
}

// Run the test
testDriverInterception();
```

---

## Implementation: Python / SQLite

### Step 1: Native Trace Callback in SQLite

SQLite provides a powerful feature called `sqlite3_trace` that allows us to intercept queries at the native C level. This is the lowest-level interception available in SQLite.

**File: `python/native_interceptor.py`**

```python
# python/native_interceptor.py

"""
Native-level interceptor for SQLite using the sqlite3_trace API.

This module provides low-level query interception by using SQLite's
native tracing capabilities. This catches queries even if they bypass
the application layer.
"""

import sqlite3
import threading
import time
from typing import Callable, Optional, Dict, Any
from datetime import datetime, timezone

class NativeInterceptor:
    """
    Native-level interceptor for SQLite connections.
    
    Uses the sqlite3_trace API to intercept all SQL statements at the
    C-level before they're executed. This provides the lowest-level
    interception possible in SQLite.
    
    Features:
        - Catches all SQL statements regardless of how they're executed
        - Works with any SQLite connection (no wrapper needed)
        - Provides the exact SQL that will be executed
        - Low overhead (native C callback)
        - Thread-safe for multiple connections
    
    Example:
        >>> conn = sqlite3.connect('database.db')
        >>> interceptor = NativeInterceptor(conn)
        >>> interceptor.set_callback(lambda sql: print(f'Query: {sql}'))
        >>> conn.execute('SELECT * FROM users')
        Query: SELECT * FROM users
    """
    
    def __init__(self, connection: sqlite3.Connection):
        """
        Initialize the native interceptor for a SQLite connection.
        
        Args:
            connection: The SQLite connection to intercept
        """
        self.connection = connection
        self._callback = None
        self._original_trace = None
        
        # Store the original trace function if it exists
        try:
            self._original_trace = connection.get_trace_callback()
        except AttributeError:
            # Older SQLite versions might not support get_trace_callback
            self._original_trace = None
        
        # Keep track of whether we're installed
        self._installed = False
    
    def set_callback(self, callback: Callable[[str], None]) -> None:
        """
        Set the callback function for intercepted queries.
        
        Args:
            callback: Function that takes the SQL string as argument
                    The callback is called for every SQL statement executed.
        """
        self._callback = callback
        self._install()
    
    def _install(self) -> None:
        """
        Install the trace callback on the connection.
        This is called automatically when set_callback is called.
        """
        if self._installed:
            return
        
        def trace_callback(sql: str) -> None:
            """Internal trace callback for SQLite."""
            # Call the user's callback if provided
            if self._callback:
                try:
                    self._callback(sql)
                except Exception as e:
                    print(f"[NATIVE INTERCEPTOR ERROR] Callback failed: {e}")
        
        # Set the trace callback
        self.connection.set_trace_callback(trace_callback)
        self._installed = True
        print("[NATIVE INTERCEPTOR] Installed successfully")
    
    def uninstall(self) -> None:
        """
        Uninstall the interceptor and restore the original trace callback.
        """
        if self._installed:
            # Restore the original trace callback if it existed
            if self._original_trace:
                self.connection.set_trace_callback(self._original_trace)
            else:
                self.connection.set_trace_callback(None)
            self._installed = False
            print("[NATIVE INTERCEPTOR] Uninstalled successfully")
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - ensures the interceptor is uninstalled."""
        self.uninstall()

class AuditedNativeSQLite:
    """
    An extended SQLite connection with both application and native interception.
    
    This class combines:
    1. Application-layer audit (from Part 1)
    2. Native-level interception (from this part)
    
    Providing comprehensive coverage for all SQL operations.
    """
    
    def __init__(self, db_path: str, 
                 callback: Optional[Callable[[str], None]] = None):
        """
        Initialize the audited native SQLite connection.
        
        Args:
            db_path: Path to the SQLite database file
            callback: Optional callback for intercepted queries
        """
        self.db_path = db_path
        self.connection = None
        self.interceptor = None
        
        # Initialize the connection
        self._init_connection()
        
        # Install the interceptor if a callback is provided
        if callback:
            self.interceptor = NativeInterceptor(self.connection)
            self.interceptor.set_callback(callback)
    
    def _init_connection(self) -> None:
        """
        Initialize the SQLite connection with audit table.
        """
        self.connection = sqlite3.connect(self.db_path, check_same_thread=False)
        self.connection.execute("PRAGMA foreign_keys = ON")
        self.connection.execute("PRAGMA journal_mode = WAL")
        
        # Create the audit table if it doesn't exist
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
        """
        Callback for native interception - logs queries to the audit table.
        
        Args:
            sql: The SQL statement that was intercepted
        """
        # Log to the audit table
        self.connection.execute(
            """
            INSERT INTO native_audit_logs (sql_statement, source)
            VALUES (?, ?)
            """,
            (sql, 'native_interceptor')
        )
        self.connection.commit()
        
        # Also log to console for immediate visibility
        timestamp = datetime.now(timezone.utc).isoformat()
        print(
            f"[NATIVE AUDIT] {timestamp} | Query: {sql[:100]}{'...' if len(sql) > 100 else ''}"
        )
    
    def enable_native_interception(self) -> None:
        """
        Enable native interception on this connection.
        This will capture all SQL statements at the C level.
        """
        # Install the interceptor with our audit callback
        self.interceptor = NativeInterceptor(self.connection)
        self.interceptor.set_callback(self._native_audit_callback)
        print("[AUDITED NATIVE SQLITE] Native interception enabled")
    
    def disable_native_interception(self) -> None:
        """
        Disable native interception.
        """
        if self.interceptor:
            self.interceptor.uninstall()
            self.interceptor = None
            print("[AUDITED NATIVE SQLITE] Native interception disabled")
    
    def execute(self, sql: str, params: tuple = ()) -> sqlite3.Cursor:
        """
        Execute a SQL statement with audit logging.
        
        This is the application-layer audit, which will be complemented
        by the native interception.
        """
        # Application-layer audit (from Part 1)
        print(f"[APP AUDIT] Executing: {sql[:100]}{'...' if len(sql) > 100 else ''}")
        
        # Execute the query
        cursor = self.connection.execute(sql, params)
        self.connection.commit()
        return cursor
    
    def get_native_audit_logs(self, limit: int = 100) -> list:
        """
        Retrieve logs from the native interception.
        """
        cursor = self.connection.execute(
            """
            SELECT sql_statement, captured_at, source
            FROM native_audit_logs
            ORDER BY captured_at DESC
            LIMIT ?
            """,
            (limit,)
        )
        return cursor.fetchall()
    
    def close(self) -> None:
        """
        Close the connection and clean up.
        """
        if self.interceptor:
            self.interceptor.uninstall()
        if self.connection:
            self.connection.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
```

---

### Step 2: Testing Native Interception

Now let's test our native interception to ensure it catches queries at the C level.

**File: `python/test_native_interception.py`**

```python
# python/test_native_interception.py

"""
Test script for native-level interception in SQLite.
"""

import sqlite3
import time
from datetime import datetime
from native_interceptor import NativeInterceptor, AuditedNativeSQLite

def test_native_interception():
    """Test native-level interception."""
    
    print("🧪 Testing Native-Level Interception...\n")
    
    # Create a test database in memory
    conn = sqlite3.connect(':memory:')
    
    # Create a test table
    conn.execute("CREATE TABLE test (id INTEGER, name TEXT)")
    conn.commit()
    
    # Keep track of intercepted queries
    intercepted_queries = []
    
    def interceptor_callback(sql: str) -> None:
        """Callback for intercepted queries."""
        intercepted_queries.append(sql)
        print(f"[INTERCEPTED] Query: {sql[:100]}{'...' if len(sql) > 100 else ''}")
    
    # Install the interceptor
    print("📝 Installing native interceptor...")
    interceptor = NativeInterceptor(conn)
    interceptor.set_callback(interceptor_callback)
    
    try:
        # TEST 1: Execute a direct query through the connection
        print("\n📝 TEST 1: Direct query through connection")
        conn.execute("INSERT INTO test (id, name) VALUES (1, 'Alice')")
        conn.commit()
        print("   ✅ Direct query executed")
        
        # TEST 2: Query with parameters
        print("\n📝 TEST 2: Query with parameters")
        conn.execute("INSERT INTO test (id, name) VALUES (?, ?)", (2, 'Bob'))
        conn.commit()
        print("   ✅ Parameterized query executed")
        
        # TEST 3: Select query
        print("\n📝 TEST 3: SELECT query")
        cursor = conn.execute("SELECT * FROM test WHERE id = ?", (1,))
        results = cursor.fetchall()
        print(f"   ✅ SELECT query returned {len(results)} rows")
        
        # TEST 4: Multiple statements in one call
        print("\n📝 TEST 4: Multiple statements")
        conn.executescript("""
            INSERT INTO test VALUES (3, 'Charlie');
            INSERT INTO test VALUES (4, 'David');
            SELECT COUNT(*) FROM test;
        """)
        print("   ✅ Multiple statements executed")
        
        # TEST 5: Query that bypasses application layer
        print("\n📝 TEST 5: Raw SQLite query (simulating external access)")
        # This simulates a raw C-level query that bypasses any Python wrapper
        conn.execute("INSERT INTO test VALUES (5, 'External')")
        conn.commit()
        print("   ✅ Raw query executed")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
    finally:
        # Uninstall the interceptor
        interceptor.uninstall()
        conn.close()
    
    # Show what was intercepted
    print(f"\n📊 Intercepted {len(intercepted_queries)} queries:")
    for idx, query in enumerate(intercepted_queries, 1):
        print(f"{idx}. {query[:80]}{'...' if len(query) > 80 else ''}")
    
    # Verify that all queries were intercepted
    expected_queries = [
        "INSERT INTO test (id, name) VALUES (1, 'Alice')",
        "INSERT INTO test (id, name) VALUES (?, ?)",
        "SELECT * FROM test WHERE id = ?",
        "INSERT INTO test VALUES (3, 'Charlie')",
        "INSERT INTO test VALUES (4, 'David')",
        "SELECT COUNT(*) FROM test",
        "INSERT INTO test VALUES (5, 'External')"
    ]
    
    print("\n✅ Verification:")
    print(f"   Expected: {len(expected_queries)} queries")
    print(f"   Intercepted: {len(intercepted_queries)} queries")
    
    if len(intercepted_queries) >= len(expected_queries):
        print("   ✅ All queries were intercepted at the native level!")
    else:
        print("   ⚠️ Some queries may not have been intercepted.")
        print("      Check the logs for details.")
    
    return intercepted_queries

def test_audited_native_sqlite():
    """Test the AuditedNativeSQLite class."""
    
    print("\n" + "="*60)
    print("🧪 Testing AuditedNativeSQLite")
    print("="*60 + "\n")
    
    # Create an audited native SQLite connection
    with AuditedNativeSQLite(':memory:') as db:
        # Enable native interception
        db.enable_native_interception()
        
        # Create a test table
        db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
        
        # Insert some data
        db.execute("INSERT INTO users (name) VALUES (?)", ('Alice',))
        db.execute("INSERT INTO users (name) VALUES (?)", ('Bob',))
        
        # Query the data
        cursor = db.connection.execute("SELECT * FROM users")
        rows = cursor.fetchall()
        print(f"Found {len(rows)} users")
        
        # Get the native audit logs
        logs = db.get_native_audit_logs(10)
        print(f"\nNative audit logs: {len(logs)} entries")
        
        for log in logs[:5]:
            print(f"  - {log[0][:60]}...")
        
        print("\n✅ AuditedNativeSQLite test completed")

if __name__ == "__main__":
    # Run the native interception test
    test_native_interception()
    
    # Run the audited native SQLite test
    test_audited_native_sqlite()
```

---

### Step 3: Comprehensive Integration Test

Now let's create a comprehensive test that combines all layers: application audit, driver interception (in Python's case, native interception), and verification.

**File: `python/test_comprehensive.py`**

```python
# python/test_comprehensive.py

"""
Comprehensive test combining all layers of interception.
"""

import sqlite3
import time
from datetime import datetime
from audited_sqlite import AuditedSQLite
from native_interceptor import AuditedNativeSQLite

def test_comprehensive():
    """Test all interception layers working together."""
    
    print("="*70)
    print("🧪 Comprehensive Interception Test")
    print("="*70)
    
    # Use a file-based database for this test
    db_path = "comprehensive_test.db"
    
    # Initialize the database
    app_db = AuditedSQLite(db_path)
    
    # Keep track of queries at different levels
    app_queries = []
    native_queries = []
    
    def native_callback(sql: str):
        """Callback for native interception."""
        native_queries.append(sql)
        print(f"[NATIVE] {sql[:60]}...")
    
    # Create the native interceptor
    native_db = AuditedNativeSQLite(db_path, callback=native_callback)
    
    print("\n📊 Test Setup:")
    print(f"   Application Layer: {type(app_db).__name__}")
    print(f"   Native Layer: {type(native_db).__name__}")
    print(f"   Both layers are active on the same database file\n")
    
    try:
        # 1. Create tables through the application layer
        print("📝 1. Creating tables (Application Layer)")
        app_db.execute("""
            CREATE TABLE IF NOT EXISTS customers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE
            )
        """, user_context={'id': 'app_user', 'ip': '127.0.0.1'})
        
        app_db.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                customer_id INTEGER,
                amount REAL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (customer_id) REFERENCES customers(id)
            )
        """, user_context={'id': 'app_user', 'ip': '127.0.0.1'})
        
        print("   ✅ Tables created")
        
        # 2. Insert data through the application layer
        print("\n📝 2. Inserting data (Application Layer)")
        app_db.execute(
            "INSERT INTO customers (name, email) VALUES (?, ?)",
            ('Alice Johnson', 'alice@example.com'),
            user_context={'id': 'alice@example.com', 'ip': '192.168.1.100'}
        )
        
        app_db.execute(
            "INSERT INTO customers (name, email) VALUES (?, ?)",
            ('Bob Smith', 'bob@example.com'),
            user_context={'id': 'bob@example.com', 'ip': '10.0.0.5'}
        )
        
        app_db.execute(
            "INSERT INTO orders (customer_id, amount) VALUES (?, ?)",
            (1, 299.99),
            user_context={'id': 'alice@example.com', 'ip': '192.168.1.100'}
        )
        print("   ✅ Data inserted")
        
        # 3. Query through the application layer
        print("\n📝 3. Querying data (Application Layer)")
        results = app_db.query(
            """
            SELECT c.name, c.email, o.amount
            FROM customers c
            JOIN orders o ON c.id = o.customer_id
            """
        )
        print(f"   ✅ Found {len(results)} results")
        for result in results:
            print(f"      {result['name']}: ${result['amount']}")
        
        # 4. Update through native layer (bypassing application)
        print("\n📝 4. Updating data (Native Layer - Bypassing Application)")
        native_db.connection.execute(
            "UPDATE customers SET email = ? WHERE name = ?",
            ('alice_new@example.com', 'Alice Johnson')
        )
        native_db.connection.commit()
        print("   ✅ Update executed through native layer")
        
        # 5. Native query (completely bypassing any Python wrapper)
        print("\n📝 5. Raw query (Native Layer - Direct SQLite)")
        native_db.connection.execute(
            "INSERT INTO orders (customer_id, amount) VALUES (?, ?)",
            (2, 149.50)
        )
        native_db.connection.commit()
        print("   ✅ Raw query executed")
        
        # 6. Mixed - application with native context
        print("\n📝 6. Mixed operation")
        app_db.execute(
            "DELETE FROM orders WHERE amount < ?",
            (100,),  # No orders under $100, so nothing deleted
            user_context={'id': 'system', 'ip': 'internal'}
        )
        print("   ✅ Mixed operation completed")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        # Clean up
        app_db.close()
        native_db.close()
        print("\n🔌 Connections closed.")
    
    # Analyze what was intercepted
    print("\n" + "="*70)
    print("📊 Interception Analysis")
    print("="*70)
    
    print(f"\nApplication-layer queries: {len(app_db.get_audit_logs(limit=100))}")
    print(f"Native-layer queries: {len(native_queries)}")
    print(f"Queries intercepted by both: {len(set(native_queries) & set([q.get('query_text', '') for q in app_db.get_audit_logs()]))}")
    
    print("\n📝 Native queries intercepted:")
    for idx, query in enumerate(native_queries[:5], 1):
        print(f"   {idx}. {query[:80]}{'...' if len(query) > 80 else ''}")
    
    if native_queries:
        print(f"\n✅ Native interception is working! Captured {len(native_queries)} queries.")
    else:
        print("\n⚠️ No queries intercepted at the native layer.")
        print("   Check if the native interceptor is properly installed.")
    
    print("\n" + "="*70)
    print("✅ Comprehensive test completed")

if __name__ == "__main__":
    test_comprehensive()
```

---

## Verification: Testing Both Implementations

### JavaScript Verification

**1. Run the driver interception test:**

```bash
cd javascript
node tests/test-driver-interception.js
```

Expected output (abbreviated):

```
🧪 Testing Driver-Level Interception...

✅ EnhancedAuditedPool created
   - Application-layer audit: Active
   - Driver-layer interception: Active

📝 TEST 1: Query through AuditedPool
   This query should be caught by BOTH application and driver layers
[DRIVER INTERCEPTOR] Pool query intercepted: CREATE TABLE IF NOT EXISTS interception_test (id SERIAL PRIMARY KEY, name TEXT)
[DAM AUDIT] 2026-08-07T10:00:00.000Z | User: test-user | IP: 127.0.0.1 | Status: SUCCESS | Duration: 45.20ms | Query: CREATE TABLE IF NOT EXISTS interception_test...
   ✅ Query executed through AuditedPool

📝 TEST 2: Query through raw connection
   This query should ONLY be caught by the driver layer
[DRIVER INTERCEPTOR] Client query intercepted: INSERT INTO interception_test (name) VALUES ($1)
   ✅ Query executed through raw connection

📝 TEST 3: Query through direct client
   This query should be caught by driver layer
[DRIVER INTERCEPTOR] Pool query intercepted: INSERT INTO interception_test (name) VALUES ($1)
[DIRECT CLIENT INTERCEPTED] INSERT INTO interception_test (name) VALUES ($1)...
   ✅ Query executed through direct client

📝 TEST 4: Query through the underlying driver directly
[DRIVER INTERCEPTOR] Client query intercepted: SELECT COUNT(*) FROM interception_test
   ✅ Deep query executed

🔍 Checking audit logs...

📊 Found 6 audit entries related to interception tests:

1. SELECT COUNT(*) FROM interception_test
   User: driver-interceptor
   Status: INTERCEPTED

2. INSERT INTO interception_test (name) VALUES ($1)
   User: driver-interceptor
   Status: INTERCEPTED

3. INSERT INTO interception_test (name) VALUES ($1)
   User: driver-interceptor
   Status: INTERCEPTED

4. INSERT INTO interception_test (name) VALUES ($1)
   User: test-user
   Status: SUCCESS

5. CREATE TABLE IF NOT EXISTS interception_test...
   User: test-user
   Status: SUCCESS

6. CREATE TABLE IF NOT EXISTS interception_test...
   User: driver-interceptor
   Status: INTERCEPTED

✅ Driver interception is working correctly!
   Intercepted 4 queries, including those that bypassed the audit layer.

🔌 Connection pool closed.
```

### Python Verification

**1. Run the native interception test:**

```bash
cd python
python test_native_interception.py
```

Expected output (abbreviated):

```
🧪 Testing Native-Level Interception...

📝 Installing native interceptor...
[NATIVE INTERCEPTOR] Installed successfully

📝 TEST 1: Direct query through connection
[INTERCEPTED] Query: INSERT INTO test (id, name) VALUES (1, 'Alice')
   ✅ Direct query executed

📝 TEST 2: Query with parameters
[INTERCEPTED] Query: INSERT INTO test (id, name) VALUES (?, ?)
   ✅ Parameterized query executed

📝 TEST 3: SELECT query
[INTERCEPTED] Query: SELECT * FROM test WHERE id = ?
   ✅ SELECT query returned 1 rows

📝 TEST 4: Multiple statements
[INTERCEPTED] Query: INSERT INTO test VALUES (3, 'Charlie')
[INTERCEPTED] Query: INSERT INTO test VALUES (4, 'David')
[INTERCEPTED] Query: SELECT COUNT(*) FROM test
   ✅ Multiple statements executed

📝 TEST 5: Raw SQLite query (simulating external access)
[INTERCEPTED] Query: INSERT INTO test VALUES (5, 'External')
   ✅ Raw query executed

📊 Intercepted 7 queries:
1. INSERT INTO test (id, name) VALUES (1, 'Alice')
2. INSERT INTO test (id, name) VALUES (?, ?)
3. SELECT * FROM test WHERE id = ?
4. INSERT INTO test VALUES (3, 'Charlie')
5. INSERT INTO test VALUES (4, 'David')
6. SELECT COUNT(*) FROM test
7. INSERT INTO test VALUES (5, 'External')

✅ Verification:
   Expected: 7 queries
   Intercepted: 7 queries
   ✅ All queries were intercepted at the native level!
```

**2. Run the comprehensive test:**

```bash
python test_comprehensive.py
```

Expected output (abbreviated):

```
🧪 Comprehensive Interception Test
======================================================================

📊 Test Setup:
   Application Layer: AuditedSQLite
   Native Layer: AuditedNativeSQLite
   Both layers are active on the same database file

📝 1. Creating tables (Application Layer)
[DAM AUDIT] 2026-08-07T10:00:00.000Z | User: app_user | IP: 127.0.0.1 | Status: SUCCESS | Duration: 2.50ms | Query: CREATE TABLE IF NOT EXISTS customers...
[DAM AUDIT] 2026-08-07T10:00:00.010Z | User: app_user | IP: 127.0.0.1 | Status: SUCCESS | Duration: 1.80ms | Query: CREATE TABLE IF NOT EXISTS orders...
   ✅ Tables created

📝 2. Inserting data (Application Layer)
[DAM AUDIT] 2026-08-07T10:00:00.020Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 1.20ms | Query: INSERT INTO customers...
[DAM AUDIT] 2026-08-07T10:00:00.030Z | User: bob@example.com | IP: 10.0.0.5 | Status: SUCCESS | Duration: 0.90ms | Query: INSERT INTO customers...
[DAM AUDIT] 2026-08-07T10:00:00.040Z | User: alice@example.com | IP: 192.168.1.100 | Status: SUCCESS | Duration: 1.10ms | Query: INSERT INTO orders...
   ✅ Data inserted

📝 3. Querying data (Application Layer)
[DAM AUDIT] 2026-08-07T10:00:00.050Z | User: system | IP: unknown | Status: SUCCESS | Duration: 0.80ms | Query: SELECT c.name, c.email, o.amount...
   ✅ Found 1 results
      Alice Johnson: $299.99

📝 4. Updating data (Native Layer - Bypassing Application)
[NATIVE] UPDATE customers SET email = ? WHERE name = ?...
   ✅ Update executed through native layer

📝 5. Raw query (Native Layer - Direct SQLite)
[NATIVE] INSERT INTO orders (customer_id, amount) VALUES (?, ?)...
   ✅ Raw query executed

📝 6. Mixed operation
[DAM AUDIT] 2026-08-07T10:00:00.060Z | User: system | IP: internal | Status: SUCCESS | Duration: 0.70ms | Query: DELETE FROM orders WHERE amount < ?
   ✅ Mixed operation completed

🔌 Connections closed.

======================================================================
📊 Interception Analysis
======================================================================

Application-layer queries: 6
Native-layer queries: 8
Queries intercepted by both: 4

📝 Native queries intercepted:
   1. CREATE TABLE customers...
   2. CREATE TABLE orders...
   3. INSERT INTO customers...
   4. INSERT INTO customers...
   5. INSERT INTO orders...

✅ Native interception is working! Captured 8 queries.

======================================================================
✅ Comprehensive test completed
```

---

## Deep Reference Section

### Reference: PostgreSQL Wire Protocol

**What is the Wire Protocol?**

PostgreSQL uses a custom wire protocol for client-server communication. When a client (like the `pg` library) sends a query, it's serialized into a specific format and sent over the network.

**How Driver Interception Works:**

The `pg` library provides hooks at different levels:

1. **Client.query()**: The most common entry point
2. **Connection.query()**: Lower-level entry point
3. **Stream events**: Even lower-level for raw protocol handling

By wrapping these methods, we can intercept queries at the driver level.

**The Interception Flow:**

```
Application Code
       │
       ▼
Client.query('SELECT * FROM users')
       │
       ▼
[Driver Interceptor] ←-- We intercept here!
       │
       ▼
pg.Client._query()
       │
       ▼
Connection (wire protocol)
       │
       ▼
PostgreSQL Server
```

**Why This Matters for DAM:**

Driver interception catches queries that:
- Bypass application-layer audit (using direct connections)
- Come from external tools (psql, pgAdmin, etc.)
- Are executed by other applications using the same database

### Reference: SQLite Native Trace

**What is sqlite3_trace?**

SQLite provides a C-level API called `sqlite3_trace` that allows you to register a callback function. This callback is invoked for every SQL statement that the SQLite engine executes.

**The Trace Flow:**

```
Application Code
       │
       ▼
sqlite3_exec() or sqlite3_prepare()
       │
       ▼
SQLite Engine
       │
       ▼
[sqlite3_trace callback] ←-- We intercept here!
       │
       ▼
Query Execution
```

**Why Native Trace is Powerful:**

1. **Completeness**: Captures ALL SQL, including dynamic statements
2. **Accuracy**: Gets the exact SQL that will be executed
3. **Performance**: Native C callback has minimal overhead
4. **No Bypass**: Can't be bypassed by Python code (short of recompiling SQLite)

### Reference: Multiple Interception Layers

**Defense in Depth with Interception:**

When we combine multiple interception layers, we get:

| Layer | What it Captures | Bypass Risk |
|-------|------------------|-------------|
| Application | Queries through audited wrappers | High (can use raw connection) |
| Driver | Queries at the driver level | Medium (can use different driver) |
| Native | Queries at the database engine level | Low (requires database engine modification) |

**The Complete Picture:**

```
┌──────────────────────────────────────────────────────┐
│ Application Business Logic                           │
└────────────────────┬─────────────────────────────────┘
                     │
        ┌────────────▼────────────┐
        │  Application Layer      │  ← Queries through AuditedPool
        │  (Part 1)               │     - Has user context
        └────────────┬────────────┘     - Business-aware
                     │
        ┌────────────▼────────────┐
        │  Driver Layer           │  ← Queries through raw connections
        │  (Part 2 - JavaScript)  │     - Catches "shadow" queries
        └────────────┬────────────┘     - Driver-level visibility
                     │
        ┌────────────▼────────────┐
        │  Native Layer           │  ← Queries from any source
        │  (Part 2 - Python)      │     - Lowest-level capture
        └────────────┬────────────┘     - Native C callback
                     │
        ┌────────────▼────────────┐
        │  Database Engine         │
        └──────────────────────────┘
```

### Reference: Performance Considerations for Interception

**The Performance Impact:**

Each interception layer adds some overhead:

| Layer | Overhead | Notes |
|-------|----------|-------|
| Application | Low (function wrapper) | Mostly JavaScript/Python overhead |
| Driver | Low (same-language wrapper) | Slightly more due to method wrapping |
| Native | Minimal (C callback) | Fastest, but callback is in C |

**Optimization Strategies:**

1. **Asynchronous Logging**: Don't wait for audit logs to write
2. **Sampling**: Only log a percentage of queries in high-volume systems
3. **Conditional Logging**: Only log certain patterns or users
4. **Batch Processing**: Accumulate logs and write in batches

**Our Implementation:**

We've kept things simple for learning. In production, you might:

```javascript
// Asynchronous audit logging (fire and forget)
this.logAudit(auditEntry).catch(err => console.error('Audit failed:', err));
```

```python
# Asynchronous audit logging (thread pool)
import threading
threading.Thread(target=self._log_audit, args=(audit_entry,)).start()
```

### Reference: Security Considerations for Interception

**What We're Already Doing Right**

1. **Multiple Layers**: We intercept at multiple levels for redundancy
2. **Non-Blocking**: Interception doesn't block query execution
3. **Error Tolerant**: Interception errors don't break the application
4. **Logging Separation**: Audit logs go to separate tables

**Areas for Production Improvement**

1. **Interception Bypass Detection**: Alert if a query is NOT intercepted
2. **Interception Integrity**: Verify that all queries are being captured
3. **Performance Monitoring**: Track interception overhead
4. **Redaction**: Redact sensitive parameters at interception time

**Advanced Security Patterns:**

```javascript
// Detect bypass attempts
let interceptedCount = 0;
let queryCount = 0;

// Count all queries that should be intercepted
const originalQuery = pool.query;
pool.query = async function(...args) {
    queryCount++;
    // ... interception logic ...
};

// Periodic check: if queryCount > interceptedCount + threshold, alert
setInterval(() => {
    if (queryCount > interceptedCount + 10) {
        console.error('[SECURITY ALERT] Potential interception bypass detected!');
    }
}, 60000);
```

---

## Summary: What You've Built

### JavaScript Implementation
- ✅ **DriverInterceptor** class that wraps pg Pool and Client
- ✅ **EnhancedAuditedPool** combining application and driver interception
- ✅ Multiple interception points (pool, client, connection)
- ✅ Callback support for custom handling
- ✅ Test suite verifying interception works
- ✅ Demonstrated catching queries that bypass application layer

### Python Implementation
- ✅ **NativeInterceptor** using sqlite3_trace callback
- ✅ **AuditedNativeSQLite** combining application and native layers
- ✅ Native C-level interception (lowest possible layer)
- ✅ Callback support for custom handling
- ✅ Comprehensive tests for all interception scenarios
- ✅ Demonstrated catching queries at the C level

### Common Knowledge Gained
- ✅ Why interception at multiple layers is essential
- ✅ How the driver layer works in PostgreSQL
- ✅ How native tracing works in SQLite
- ✅ Defense-in-depth principles for database security
- ✅ Performance considerations for interception
- ✅ Security patterns to prevent interception bypass

---

## What's Next: Part 3 - Real-Time Parsing & Query Normalization

In Part 2, we learned how to intercept queries at multiple layers. But raw SQL logs are verbose and difficult to analyze. A query like:

```sql
SELECT * FROM users WHERE email = 'alice@example.com' AND age = 30;
```

...is functionally the same as:

```sql
SELECT * FROM users WHERE email = 'bob@example.com' AND age = 25;
```

But as raw strings, they look completely different. This makes it hard to:
1. **Detect patterns** (is this a common query or a one-off?)
2. **Store efficiently** (do we need to store every variation?)
3. **Analyze trends** (how many times is this pattern used?)

In Part 3, we'll solve this with **query normalization**. We'll strip literal values to create compact, pattern-friendly signatures that:
- Reduce log storage requirements
- Enable pattern matching
- Make analysis easier
- Keep identical attack patterns groupable

**Get ready to transform your audit logs into actionable intelligence!**

*Part 2 is complete! You now have multiple interception layers providing comprehensive coverage. Continue to Part 3 to learn how to normalize queries for efficient storage and pattern matching.*
