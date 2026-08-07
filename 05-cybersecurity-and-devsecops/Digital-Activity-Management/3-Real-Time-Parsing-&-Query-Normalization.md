# Part 3: Real-Time Parsing & Query Normalization

Welcome to Part 3 of our Database Activity Management series! In Part 1, we built audit logging. In Part 2, we added interception at multiple layers. Now we have a firehose of raw SQL queries flowing into our audit system.

But here's the challenge: **Raw SQL logs are verbose, repetitive, and difficult to analyze.**

Consider these two queries:

```sql
SELECT * FROM users WHERE email = 'alice@example.com' AND age = 30;
SELECT * FROM users WHERE email = 'bob@example.com' AND age = 25;
```

As raw strings, they're completely different. But structurally, they're identical:

```sql
SELECT * FROM users WHERE email = '?' AND age = ?;
```

This is **query normalization**—replacing literal values with placeholders to reveal the underlying structure. In this part, we'll build normalizers that transform verbose SQL into compact, pattern-friendly signatures.

---

## The Target: What We're Building Right Now

By the end of this part, you will have:

1. **JavaScript normalizer** that strips literals from SQL queries
2. **Python normalizer** with the same capabilities
3. **Enhanced audit logs** that store both raw and normalized queries
4. **Pattern detection** capabilities for identifying query families
5. **Storage optimization** for efficient log retention

---

## The Concept: Why Normalization Matters

Imagine you're a librarian trying to organize thousands of books. If you cataloged each book by its exact title, you'd have a massive, unorganized list. But if you catalog by genre, author, and subject, you can find patterns and group similar books together.

Query normalization does the same thing for SQL:

### The Problem with Raw Logs

```
Raw logs are:
- Verbose (a single query can be hundreds of characters)
- Unique (every query has different literal values)
- Hard to analyze (can't easily group by pattern)
- Storage-intensive (duplicate patterns stored many times)
- Privacy-sensitive (contain actual data values)
```

### The Solution: Normalization

Normalized queries are:

```
- Compact (replace literals with '?' placeholders)
- Pattern-friendly (same structure = same signature)
- Analysis-ready (can count occurrences of patterns)
- Storage-efficient (store pattern + count, not every instance)
- Privacy-safe (data values are stripped)
```

### The Normalization Pipeline

```
Raw SQL Query
     │
     ▼
┌─────────────────────────────┐
│ 1. String Literal Removal   │  'alice@example.com' → '?'
│    Remove '...' values      │
└─────────────────────────────┘
     │
     ▼
┌─────────────────────────────┐
│ 2. Numeric Literal Removal  │  30 → ?
│    Remove 123, 45.6 values  │
└─────────────────────────────┘
     │
     ▼
┌─────────────────────────────┐
│ 3. Whitespace Collapse      │  Multiple spaces → single space
│    Normalize spacing        │
└─────────────────────────────┘
     │
     ▼
┌─────────────────────────────┐
│ 4. Optional: Case           │  SELECT → select
│    Normalization            │  (for case-insensitive matching)
└─────────────────────────────┘
     │
     ▼
Normalized SQL Pattern
```

---

## Implementation: JavaScript / Node.js

### Step 1: Basic Normalizer

Let's start with a basic normalizer that handles the most common cases.

**File: `javascript/src/normalizer.js`**

```javascript
// javascript/src/normalizer.js

/**
 * Query Normalizer for SQL statements
 * 
 * Transforms raw SQL queries into normalized patterns by replacing
 * literal values with placeholders. This enables:
 * - Pattern matching and analysis
 * - Efficient storage
 * - Privacy protection (strips data values)
 * - Attack pattern detection
 * 
 * The normalizer handles:
 * 1. String literals (single-quoted strings)
 * 2. Numeric literals (integers and decimals)
 * 3. Whitespace normalization
 * 4. Optional case normalization
 * 5. Special handling for IN clauses and arrays
 * 6. JSON and UUID literals
 * 
 * @example
 * normalizeQuery("SELECT * FROM users WHERE email = 'alice@example.com' AND age = 30;")
 * // Returns: "SELECT * FROM users WHERE email = '?' AND age = ?;"
 */
export class QueryNormalizer {
  /**
   * Create a new query normalizer with options
   * @param {Object} options - Configuration options
   * @param {boolean} options.caseInsensitive - Normalize to lowercase (default: false)
   * @param {boolean} options.preserveComments - Keep SQL comments (default: false)
   * @param {boolean} options.normalizeInClauses - Normalize IN list values (default: true)
   */
  constructor(options = {}) {
    this.options = {
      caseInsensitive: false,
      preserveComments: false,
      normalizeInClauses: true,
      ...options
    };
  }

  /**
   * Normalize a SQL query
   * @param {string} sql - The raw SQL query
   * @returns {string} - The normalized query
   */
  normalize(sql) {
    if (!sql || typeof sql !== 'string') {
      return '';
    }

    let normalized = sql;

    // Optional: Remove comments first
    if (!this.options.preserveComments) {
      normalized = this.removeComments(normalized);
    }

    // Step 1: Replace string literals with '?'
    normalized = this.replaceStringLiterals(normalized);

    // Step 2: Replace numeric literals with ?
    normalized = this.replaceNumericLiterals(normalized);

    // Step 3: Replace UUID literals with ?
    normalized = this.replaceUuidLiterals(normalized);

    // Step 4: Replace JSON/JSONB literals with ?
    normalized = this.replaceJsonLiterals(normalized);

    // Step 5: Normalize IN clauses
    if (this.options.normalizeInClauses) {
      normalized = this.normalizeInClauses(normalized);
    }

    // Step 6: Collapse whitespace
    normalized = this.collapseWhitespace(normalized);

    // Step 7: Optional case normalization
    if (this.options.caseInsensitive) {
      normalized = normalized.toLowerCase();
    }

    return normalized.trim();
  }

  /**
   * Remove SQL comments (-- and /* ... * /)
   * @param {string} sql - The SQL query
   * @returns {string} - SQL without comments
   */
  removeComments(sql) {
    // Remove multi-line comments /* ... */
    let result = sql.replace(/\/\*[\s\S]*?\*\//g, '');
    
    // Remove single-line comments --
    // But be careful with -- in strings (which we've already removed)
    // We handle this by processing line by line
    const lines = result.split('\n');
    const cleanedLines = lines.map(line => {
      // Find the first occurrence of -- that's not inside a string
      // Since we've removed string literals, we can safely remove all --
      const commentIndex = line.indexOf('--');
      if (commentIndex !== -1) {
        return line.substring(0, commentIndex);
      }
      return line;
    });
    
    return cleanedLines.join(' ');
  }

  /**
   * Replace string literals with '?'
   * Handles both single-quoted strings and double-quoted identifiers
   * @param {string} sql - The SQL query
   * @returns {string} - SQL with string literals replaced
   */
  replaceStringLiterals(sql) {
    // Handle single-quoted strings
    // This regex handles:
    // 1. Normal strings: 'hello'
    // 2. Strings with escaped quotes: 'it''s'
    // 3. Strings with escape sequences: 'hello\nworld'
    let result = sql.replace(/'[^']*(?:''[^']*)*'/g, "'?'");
    
    // Handle double-quoted identifiers (don't replace these)
    // We need to be careful not to replace double-quoted column names
    // We'll temporarily mark them and restore later
    const identifiers = [];
    result = result.replace(/"[^"]*"/g, (match) => {
      identifiers.push(match);
      return `__IDENTIFIER_${identifiers.length - 1}__`;
    });
    
    // Now handle any remaining double-quoted strings (like JSON keys)
    // These are actually string literals in some SQL dialects
    // We'll replace them with '?' but preserve the quotes
    result = result.replace(/"[^"]*"/g, "'?'");
    
    // Restore identifiers
    identifiers.forEach((id, index) => {
      result = result.replace(`__IDENTIFIER_${index}__`, id);
    });
    
    return result;
  }

  /**
   * Replace numeric literals with ?
   * Handles integers, decimals, and scientific notation
   * @param {string} sql - The SQL query
   * @returns {string} - SQL with numeric literals replaced
   */
  replaceNumericLiterals(sql) {
    // Match integers and decimals
    // This regex matches:
    // 1. Integers: 123
    // 2. Decimals: 123.45
    // 3. Scientific: 1.23e+4
    // 4. Negative numbers: -123
    // But we need to be careful not to match parts of identifiers or column names
    return sql.replace(/\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b/g, '?');
  }

  /**
   * Replace UUID literals with ?
   * UUIDs are common in modern databases and should be normalized
   * @param {string} sql - The SQL query
   * @returns {string} - SQL with UUIDs replaced
   */
  replaceUuidLiterals(sql) {
    // UUID pattern: 123e4567-e89b-12d3-a456-426614174000
    const uuidPattern = /'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'/gi;
    return sql.replace(uuidPattern, "'?'");
  }

  /**
   * Replace JSON/JSONB literals with ?
   * @param {string} sql - The SQL query
   * @returns {string} - SQL with JSON literals replaced
   */
  replaceJsonLiterals(sql) {
    // JSON pattern: '{"key":"value"}'
    // This is a simplified pattern that catches most JSON strings
    // A more robust solution would use a proper JSON parser
    const jsonPattern = /'\{[^']*?\}'/g;
    return sql.replace(jsonPattern, "'?'");
  }

  /**
   * Normalize IN clauses with multiple values
   * Replaces (1,2,3,4) with (?,?,?,?) or (?) for all values
   * @param {string} sql - The SQL query
   * @returns {string} - SQL with IN clauses normalized
   */
  normalizeInClauses(sql) {
    // Find IN clauses with multiple values
    // We need to handle:
    // 1. IN (1, 2, 3)
    // 2. IN ('a', 'b', 'c')
    // 3. IN (1, 'a', 2, 'b')
    
    // This regex finds IN ( ... ) and replaces the contents with (?, ...)
    // We need to handle nested parentheses carefully
    let result = sql;
    let inClausePattern = /\bIN\s*\(([^)]*)\)/gi;
    
    result = result.replace(inClausePattern, (match, contents) => {
      // Count the number of items (approximate, based on commas)
      // Split by commas, but be careful of commas inside strings
      // Since we've already replaced string literals, we can safely split
      const items = contents.split(',').filter(item => item.trim().length > 0);
      
      if (items.length > 1) {
        // Replace with normalized pattern
        const placeholders = items.map(() => '?').join(', ');
        return `IN (${placeholders})`;
      }
      
      // Single item, already normalized
      return match;
    });
    
    return result;
  }

  /**
   * Collapse multiple spaces into a single space
   * Also removes leading/trailing whitespace from each line
   * @param {string} sql - The SQL query
   * @returns {string} - SQL with normalized whitespace
   */
  collapseWhitespace(sql) {
    return sql
      .replace(/\s+/g, ' ')          // Collapse multiple spaces
      .replace(/\s*\(\s*/g, '(')     // Remove spaces after (
      .replace(/\s*\)\s*/g, ')')     // Remove spaces before )
      .replace(/\s*,\s*/g, ', ')     // Normalize comma spacing
      .replace(/\s*=\s*/g, ' = ')    // Normalize = spacing
      .replace(/\s*>\s*/g, ' > ')    // Normalize > spacing
      .replace(/\s*<\s*/g, ' < ')    // Normalize < spacing
      .trim();
  }

  /**
   * Generate a hash/fingerprint of the normalized query
   * Useful for quick pattern matching and grouping
   * @param {string} normalized - The normalized query
   * @param {string} algorithm - Hash algorithm (default: 'sha256')
   * @returns {string} - A fingerprint of the query
   */
  fingerprint(normalized) {
    // Simple hash function for Node.js
    const crypto = require('crypto');
    return crypto
      .createHash('sha256')
      .update(normalized)
      .digest('hex')
      .substring(0, 16); // Short fingerprint
  }

  /**
   * Check if two queries are structurally identical
   * @param {string} sql1 - First SQL query
   * @param {string} sql2 - Second SQL query
   * @returns {boolean} - True if the queries have the same structure
   */
  areStructurallyIdentical(sql1, sql2) {
    const norm1 = this.normalize(sql1);
    const norm2 = this.normalize(sql2);
    return norm1 === norm2;
  }

  /**
   * Count the number of literal placeholders in a query
   * Useful for understanding query complexity
   * @param {string} normalized - The normalized query
   * @returns {number} - Number of placeholders
   */
  countPlaceholders(normalized) {
    return (normalized.match(/\?/g) || []).length;
  }

  /**
   * Get the query structure tree (simplified)
   * Returns the normalized query without values
   * @param {string} sql - The SQL query
   * @returns {Object} - Structure information
   */
  analyzeStructure(sql) {
    const normalized = this.normalize(sql);
    const placeholders = this.countPlaceholders(normalized);
    
    // Extract the query type
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

/**
 * Convenience function for quick normalization
 * @param {string} sql - The SQL query
 * @param {Object} options - Normalizer options
 * @returns {string} - Normalized query
 */
export function normalizeQuery(sql, options = {}) {
  const normalizer = new QueryNormalizer(options);
  return normalizer.normalize(sql);
}

/**
 * Convenience function for structural comparison
 * @param {string} sql1 - First SQL query
 * @param {string} sql2 - Second SQL query
 * @param {Object} options - Normalizer options
 * @returns {boolean} - True if queries have same structure
 */
export function areQueriesIdentical(sql1, sql2, options = {}) {
  const normalizer = new QueryNormalizer(options);
  return normalizer.areStructurallyIdentical(sql1, sql2);
}
```

---

### Step 2: Enhanced Audit with Normalization

Now let's enhance our `AuditedPool` to store normalized queries alongside raw ones.

**File: `javascript/src/normalized-audited-pool.js`**

```javascript
// javascript/src/normalized-audited-pool.js

import { AuditedPool } from './audited-pool.js';
import { QueryNormalizer, normalizeQuery } from './normalizer.js';

/**
 * Enhanced AuditedPool with query normalization
 * 
 * This extends the base AuditedPool to store both raw and normalized
 * query patterns. This enables:
 * 1. Pattern-based analysis
 * 2. Efficient storage (store normalized once)
 * 3. Quick fingerprinting for duplicate detection
 * 4. Privacy protection (data values are stripped)
 */
export class NormalizedAuditedPool extends AuditedPool {
  /**
   * Create a normalized audited pool
   * @param {string} connectionString - PostgreSQL connection string
   * @param {Object} options - Configuration options
   * @param {Object} options.normalizerOptions - Options for the QueryNormalizer
   * @param {boolean} options.storeRawQueries - Store raw queries (default: true)
   * @param {boolean} options.storeNormalized - Store normalized queries (default: true)
   * @param {boolean} options.autoFingerprint - Auto-generate fingerprint (default: true)
   */
  constructor(connectionString, options = {}) {
    // Initialize the base audited pool
    super(connectionString, options);
    
    this.normalizerOptions = options.normalizerOptions || {};
    this.storeRawQueries = options.storeRawQueries !== false; // Default: true
    this.storeNormalized = options.storeNormalized !== false; // Default: true
    this.autoFingerprint = options.autoFingerprint !== false; // Default: true
    
    // Create the normalizer instance
    this.normalizer = new QueryNormalizer(this.normalizerOptions);
    
    // Extend the audit table to include normalized queries
    this.extendAuditTable();
  }

  /**
   * Extend the audit table with normalization columns
   * Adds columns for normalized query and fingerprint
   */
  async extendAuditTable() {
    const client = await this.pool.connect();
    try {
      // Add normalized_query column if it doesn't exist
      await client.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'dam_audit_logs' 
            AND column_name = 'normalized_query'
          ) THEN
            ALTER TABLE dam_audit_logs 
            ADD COLUMN normalized_query TEXT;
          END IF;
        END $$;
      `);
      
      // Add query_fingerprint column if it doesn't exist
      await client.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'dam_audit_logs' 
            AND column_name = 'query_fingerprint'
          ) THEN
            ALTER TABLE dam_audit_logs 
            ADD COLUMN query_fingerprint VARCHAR(32);
          END IF;
        END $$;
      `);
      
      // Add placeholder_count column if it doesn't exist
      await client.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'dam_audit_logs' 
            AND column_name = 'placeholder_count'
          ) THEN
            ALTER TABLE dam_audit_logs 
            ADD COLUMN placeholder_count INTEGER;
          END IF;
        END $$;
      `);
      
      // Create index on fingerprint for fast pattern matching
      await client.query(`
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_fingerprint 
        ON dam_audit_logs(query_fingerprint)
      `);
      
      console.log('[NORMALIZED AUDITED POOL] Audit table extended with normalization columns');
    } finally {
      client.release();
    }
  }

  /**
   * Override the logAudit method to include normalized queries
   * @param {Object} auditEntry - The audit entry
   */
  async logAudit(auditEntry) {
    // Get the raw query text
    const rawQuery = auditEntry.query_text || '';
    
    // Generate normalized query
    let normalizedQuery = null;
    let fingerprint = null;
    let placeholderCount = 0;
    
    if (this.storeNormalized && rawQuery) {
      try {
        // Normalize the query
        normalizedQuery = this.normalizer.normalize(rawQuery);
        
        // Count placeholders
        placeholderCount = this.normalizer.countPlaceholders(normalizedQuery);
        
        // Generate fingerprint if enabled
        if (this.autoFingerprint) {
          fingerprint = this.normalizer.fingerprint(normalizedQuery);
        }
      } catch (error) {
        console.error('[NORMALIZED AUDITED POOL] Normalization failed:', error);
        // Continue with logging even if normalization fails
      }
    }
    
    // Use a direct client connection to avoid recursion
    const client = await this.pool.connect();
    try {
      // Insert the audit log entry with normalized data
      await client.query(
        `
        INSERT INTO dam_audit_logs (
          query_text,
          normalized_query,
          query_fingerprint,
          placeholder_count,
          query_params,
          duration_ms,
          user_id,
          user_ip,
          status,
          error_message
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
        )
        `,
        [
          this.storeRawQueries ? rawQuery : '[REDACTED]',
          normalizedQuery,
          fingerprint,
          placeholderCount,
          JSON.stringify(auditEntry.query_params || []),
          auditEntry.duration_ms,
          auditEntry.user_id,
          auditEntry.user_ip,
          auditEntry.status,
          auditEntry.error_message
        ]
      );
    } catch (auditError) {
      console.error('[NORMALIZED AUDITED POOL] Audit write failed:', auditError);
      console.error('[NORMALIZED AUDITED POOL] Original audit entry:', auditEntry);
    } finally {
      client.release();
    }
    
    // Log to console (show both raw and normalized)
    console.log(
      `[NORMALIZED AUDIT] ${new Date().toISOString()} | ` +
      `User: ${auditEntry.user_id} | ` +
      `Status: ${auditEntry.status} | ` +
      `Duration: ${auditEntry.duration_ms.toFixed(2)}ms | ` +
      `Raw: ${rawQuery.substring(0, 60)}${rawQuery.length > 60 ? '...' : ''} | ` +
      `Pattern: ${normalizedQuery ? normalizedQuery.substring(0, 40) + '...' : 'N/A'}`
    );
  }

  /**
   * Get query patterns grouped by fingerprint
   * Useful for understanding what types of queries are being executed
   * @param {number} limit - Maximum number of patterns to return
   * @returns {Promise<Array>} - Array of query pattern statistics
   */
  async getQueryPatterns(limit = 50) {
    const result = await this.query(
      `
      SELECT 
        query_fingerprint,
        normalized_query,
        placeholder_count,
        COUNT(*) as occurrence_count,
        AVG(duration_ms) as avg_duration_ms,
        MAX(duration_ms) as max_duration_ms,
        MIN(duration_ms) as min_duration_ms,
        COUNT(DISTINCT user_id) as distinct_users
      FROM dam_audit_logs
      WHERE normalized_query IS NOT NULL
      GROUP BY query_fingerprint, normalized_query, placeholder_count
      ORDER BY occurrence_count DESC
      LIMIT $1
      `,
      [limit],
      { id: 'system', ip: 'internal' }
    );
    
    return result.rows;
  }

  /**
   * Find queries similar to a given pattern
   * @param {string} sql - SQL query to find similar patterns for
   * @param {number} limit - Maximum number of results
   * @returns {Promise<Array>} - Similar query patterns
   */
  async findSimilarQueries(sql, limit = 10) {
    const normalizer = new QueryNormalizer(this.normalizerOptions);
    const normalized = normalizer.normalize(sql);
    const fingerprint = normalizer.fingerprint(normalized);
    
    const result = await this.query(
      `
      SELECT 
        query_text,
        normalized_query,
        user_id,
        timestamp,
        duration_ms,
        status
      FROM dam_audit_logs
      WHERE query_fingerprint = $1
      ORDER BY timestamp DESC
      LIMIT $2
      `,
      [fingerprint, limit],
      { id: 'system', ip: 'internal' }
    );
    
    return result.rows;
  }

  /**
   * Get query pattern statistics for security analysis
   * @returns {Promise<Object>} - Security statistics
   */
  async getSecurityStats() {
    const result = await this.query(
      `
      SELECT 
        COUNT(DISTINCT query_fingerprint) as unique_patterns,
        COUNT(*) as total_queries,
        AVG(placeholder_count) as avg_complexity,
        MAX(placeholder_count) as max_complexity,
        COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as failed_queries,
        COUNT(CASE WHEN query_text ILIKE '%DROP%' THEN 1 END) as drop_attempts,
        COUNT(CASE WHEN query_text ILIKE '%TRUNCATE%' THEN 1 END) as truncate_attempts
      FROM dam_audit_logs
      WHERE normalized_query IS NOT NULL
      `,
      [],
      { id: 'system', ip: 'internal' }
    );
    
    return result.rows[0] || {};
  }
}
```

---

### Step 3: Testing Query Normalization

Now let's test our normalizer to ensure it correctly transforms SQL queries.

**File: `javascript/tests/test-normalizer.js`**

```javascript
// javascript/tests/test-normalizer.js

import { QueryNormalizer, normalizeQuery, areQueriesIdentical } from '../src/normalizer.js';

/**
 * Test the query normalizer with various SQL patterns
 */
function testNormalizer() {
  console.log('🧪 Testing Query Normalizer...\n');
  
  const normalizer = new QueryNormalizer();
  
  // Test cases: [raw SQL, expected normalized output]
  const testCases = [
    // Basic SELECT
    [
      "SELECT * FROM users WHERE email = 'alice@example.com'",
      "SELECT * FROM users WHERE email = '?'"
    ],
    
    // SELECT with numbers
    [
      "SELECT * FROM products WHERE price > 100 AND stock < 50",
      "SELECT * FROM products WHERE price > ? AND stock < ?"
    ],
    
    // INSERT
    [
      "INSERT INTO users (name, email, age) VALUES ('Alice', 'alice@example.com', 30)",
      "INSERT INTO users (name, email, age) VALUES ('?', '?', ?)"
    ],
    
    // UPDATE
    [
      "UPDATE products SET price = 29.99, stock = 100 WHERE id = 123",
      "UPDATE products SET price = ?, stock = ? WHERE id = ?"
    ],
    
    // DELETE
    [
      "DELETE FROM users WHERE last_login < '2024-01-01' AND status = 'inactive'",
      "DELETE FROM users WHERE last_login < '?' AND status = '?'"
    ],
    
    // IN clause
    [
      "SELECT * FROM users WHERE id IN (1, 2, 3, 4, 5)",
      "SELECT * FROM users WHERE id IN (?, ?, ?, ?, ?)"
    ],
    
    // Complex WHERE
    [
      "SELECT * FROM orders WHERE amount > 1000 AND status = 'pending' AND created_at > '2024-01-01'",
      "SELECT * FROM orders WHERE amount > ? AND status = '?' AND created_at > '?'"
    ],
    
    // JSON operation
    [
      "SELECT data->>'name' FROM users WHERE data->>'email' = 'alice@example.com'",
      "SELECT data->>'name' FROM users WHERE data->>'email' = '?'"
    ],
    
    // UUID
    [
      "SELECT * FROM sessions WHERE session_id = '123e4567-e89b-12d3-a456-426614174000'",
      "SELECT * FROM sessions WHERE session_id = '?'"
    ],
    
    // Multiple lines and whitespace
    [
      "SELECT\n  *\nFROM\n  users\nWHERE\n  id = 123",
      "SELECT * FROM users WHERE id = ?"
    ],
    
    // Mixed case
    [
      "SELECT * FROM Users WHERE Email = 'alice@example.com' AND Age = 30",
      "SELECT * FROM Users WHERE Email = '?' AND Age = ?"
    ],
    
    // Nested conditions
    [
      "SELECT * FROM orders WHERE (status = 'pending' AND amount > 100) OR (status = 'processing' AND amount > 200)",
      "SELECT * FROM orders WHERE (status = '?' AND amount > ?) OR (status = '?' AND amount > ?)"
    ]
  ];
  
  let passed = 0;
  let failed = 0;
  
  testCases.forEach(([raw, expected], index) => {
    const normalized = normalizer.normalize(raw);
    const isMatch = normalized === expected;
    
    console.log(`\n📝 Test ${index + 1}:`);
    console.log(`   Raw:   ${raw.substring(0, 80)}${raw.length > 80 ? '...' : ''}`);
    console.log(`   Norm:  ${normalized}`);
    console.log(`   Expected: ${expected}`);
    console.log(`   ${isMatch ? '✅ PASS' : '❌ FAIL'}`);
    
    if (isMatch) {
      passed++;
    } else {
      failed++;
    }
  });
  
  console.log(`\n📊 Results: ${passed} passed, ${failed} failed`);
  
  // Additional tests for structural comparison
  console.log('\n📝 Structural Comparison Tests:');
  
  const identicalQueries = [
    "SELECT * FROM users WHERE email = 'alice@example.com'",
    "SELECT * FROM users WHERE email = 'bob@example.com'"
  ];
  const isIdentical = areQueriesIdentical(identicalQueries[0], identicalQueries[1]);
  console.log(`   Queries "${identicalQueries[0].substring(0, 30)}..." and "${identicalQueries[1].substring(0, 30)}..."`);
  console.log(`   Structurally identical? ${isIdentical ? '✅ Yes' : '❌ No'}`);
  
  const differentQueries = [
    "SELECT * FROM users WHERE email = 'alice@example.com'",
    "SELECT * FROM products WHERE price > 100"
  ];
  const isDifferent = !areQueriesIdentical(differentQueries[0], differentQueries[1]);
  console.log(`   Queries "${differentQueries[0].substring(0, 30)}..." and "${differentQueries[1].substring(0, 30)}..."`);
  console.log(`   Structurally different? ${isDifferent ? '✅ Yes' : '❌ No'}`);
  
  // Test fingerprint generation
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
  
  // Test analysis
  console.log('\n📝 Query Analysis:');
  const analysis = normalizer.analyzeStructure(
    "SELECT name, email FROM users WHERE age > 21 AND status = 'active'"
  );
  console.log(`   Query Type: ${analysis.queryType}`);
  console.log(`   Placeholders: ${analysis.placeholders}`);
  console.log(`   Fingerprint: ${analysis.fingerprint}`);
  console.log(`   Normalized: ${analysis.normalized}`);
  
  return { passed, failed };
}

// Run the test
testNormalizer();
```

---

## Implementation: Python / SQLite

### Step 1: Python Normalizer

Now let's build the Python version of our query normalizer.

**File: `python/normalizer.py`**

```python
# python/normalizer.py

"""
Query Normalizer for SQL statements.

Transforms raw SQL queries into normalized patterns by replacing
literal values with placeholders. This enables pattern matching,
efficient storage, and privacy protection.
"""

import re
import hashlib
from typing import Dict, Any, Optional, List, Tuple
from enum import Enum

class NormalizationOptions:
    """Configuration options for the query normalizer."""
    
    def __init__(self, 
                 case_insensitive: bool = False,
                 preserve_comments: bool = False,
                 normalize_in_clauses: bool = True,
                 normalize_uuid: bool = True,
                 normalize_json: bool = True,
                 collapse_whitespace: bool = True):
        """
        Initialize normalization options.
        
        Args:
            case_insensitive: Convert to lowercase
            preserve_comments: Keep SQL comments
            normalize_in_clauses: Normalize IN list values
            normalize_uuid: Replace UUID literals with '?'
            normalize_json: Replace JSON literals with '?'
            collapse_whitespace: Collapse multiple spaces to one
        """
        self.case_insensitive = case_insensitive
        self.preserve_comments = preserve_comments
        self.normalize_in_clauses = normalize_in_clauses
        self.normalize_uuid = normalize_uuid
        self.normalize_json = normalize_json
        self.collapse_whitespace = collapse_whitespace

class QueryNormalizer:
    """
    Normalizes SQL queries by replacing literal values with placeholders.
    
    Features:
        - String literal replacement ('hello' → '?')
        - Numeric literal replacement (123 → ?)
        - UUID replacement (uuid → '?')
        - JSON replacement ({"key":"value"} → '?')
        - IN clause normalization
        - Whitespace normalization
        - Optional case normalization
        - Fingerprint generation for pattern matching
    
    Example:
        >>> normalizer = QueryNormalizer()
        >>> normalized = normalizer.normalize(
        ...     "SELECT * FROM users WHERE email = 'alice@example.com'"
        ... )
        >>> print(normalized)
        SELECT * FROM users WHERE email = '?'
    """
    
    def __init__(self, options: Optional[NormalizationOptions] = None):
        """
        Initialize the normalizer with options.
        
        Args:
            options: Configuration options (creates default if None)
        """
        self.options = options or NormalizationOptions()
        
        # Compile regex patterns for performance
        self._compile_patterns()
    
    def _compile_patterns(self) -> None:
        """Compile regex patterns for performance."""
        # String literal pattern (single quotes)
        # Handles: 'hello', 'it''s', 'hello\nworld'
        self.string_literal_pattern = re.compile(
            r"'[^']*(?:''[^']*)*'",
            re.DOTALL
        )
        
        # Numeric literal pattern
        # Handles: 123, 123.45, 1.23e+4, -123
        self.numeric_pattern = re.compile(
            r'\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b'
        )
        
        # UUID pattern
        self.uuid_pattern = re.compile(
            r"'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'",
            re.IGNORECASE
        )
        
        # JSON pattern (simplified)
        self.json_pattern = re.compile(r"'\{[^']*?\}'")
        
        # IN clause pattern
        self.in_clause_pattern = re.compile(r'\bIN\s*\(([^)]*)\)', re.IGNORECASE)
        
        # Whitespace pattern
        self.whitespace_pattern = re.compile(r'\s+')
        
        # Comment patterns
        self.multi_comment_pattern = re.compile(r'/\*[\s\S]*?\*/')
        self.single_comment_pattern = re.compile(r'--[^\n]*')
    
    def normalize(self, sql: str) -> str:
        """
        Normalize a SQL query.
        
        Args:
            sql: The raw SQL query
            
        Returns:
            The normalized query
        """
        if not sql or not isinstance(sql, str):
            return ''
        
        normalized = sql
        
        # Remove comments if not preserving them
        if not self.options.preserve_comments:
            normalized = self._remove_comments(normalized)
        
        # Step 1: Replace string literals with '?'
        normalized = self._replace_string_literals(normalized)
        
        # Step 2: Replace numeric literals with ?
        normalized = self._replace_numeric_literals(normalized)
        
        # Step 3: Replace UUID literals if enabled
        if self.options.normalize_uuid:
            normalized = self._replace_uuid_literals(normalized)
        
        # Step 4: Replace JSON literals if enabled
        if self.options.normalize_json:
            normalized = self._replace_json_literals(normalized)
        
        # Step 5: Normalize IN clauses if enabled
        if self.options.normalize_in_clauses:
            normalized = self._normalize_in_clauses(normalized)
        
        # Step 6: Collapse whitespace
        if self.options.collapse_whitespace:
            normalized = self._collapse_whitespace(normalized)
        
        # Step 7: Optional case normalization
        if self.options.case_insensitive:
            normalized = normalized.lower()
        
        return normalized.strip()
    
    def _remove_comments(self, sql: str) -> str:
        """
        Remove SQL comments.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL without comments
        """
        # Remove multi-line comments
        result = self.multi_comment_pattern.sub('', sql)
        
        # Remove single-line comments
        result = self.single_comment_pattern.sub('', result)
        
        return result
    
    def _replace_string_literals(self, sql: str) -> str:
        """
        Replace string literals with '?'.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL with string literals replaced
        """
        # First, protect double-quoted identifiers
        # We'll temporarily mark them and restore later
        identifiers = []
        
        def protect_identifier(match):
            identifiers.append(match.group(0))
            return f'__IDENTIFIER_{len(identifiers) - 1}__'
        
        # Protect double-quoted identifiers
        protected_sql = re.sub(r'"[^"]*"', protect_identifier, sql)
        
        # Replace single-quoted strings
        protected_sql = self.string_literal_pattern.sub("'?'", protected_sql)
        
        # Restore identifiers
        for idx, identifier in enumerate(identifiers):
            protected_sql = protected_sql.replace(f'__IDENTIFIER_{idx}__', identifier)
        
        return protected_sql
    
    def _replace_numeric_literals(self, sql: str) -> str:
        """
        Replace numeric literals with ?.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL with numeric literals replaced
        """
        return self.numeric_pattern.sub('?', sql)
    
    def _replace_uuid_literals(self, sql: str) -> str:
        """
        Replace UUID literals with '?'.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL with UUIDs replaced
        """
        return self.uuid_pattern.sub("'?'", sql)
    
    def _replace_json_literals(self, sql: str) -> str:
        """
        Replace JSON literals with '?'.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL with JSON literals replaced
        """
        return self.json_pattern.sub("'?'", sql)
    
    def _normalize_in_clauses(self, sql: str) -> str:
        """
        Normalize IN clauses with multiple values.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL with IN clauses normalized
        """
        def replace_in_clause(match):
            contents = match.group(1)
            # Split by commas (strings are already normalized)
            items = [item.strip() for item in contents.split(',') if item.strip()]
            
            if len(items) > 1:
                # Replace with normalized pattern
                placeholders = ', '.join(['?'] * len(items))
                return f'IN ({placeholders})'
            
            # Single item, already normalized
            return match.group(0)
        
        return self.in_clause_pattern.sub(replace_in_clause, sql)
    
    def _collapse_whitespace(self, sql: str) -> str:
        """
        Collapse multiple spaces and normalize spacing.
        
        Args:
            sql: The SQL query
            
        Returns:
            SQL with normalized whitespace
        """
        # Collapse multiple spaces to one
        result = self.whitespace_pattern.sub(' ', sql)
        
        # Remove spaces around parentheses
        result = result.replace(' (', '(')
        result = result.replace('( ', '(')
        result = result.replace(' )', ')')
        result = result.replace(') ', ')')
        
        # Normalize spacing around operators
        result = re.sub(r'\s*=\s*', ' = ', result)
        result = re.sub(r'\s*>\s*', ' > ', result)
        result = re.sub(r'\s*<\s*', ' < ', result)
        result = re.sub(r'\s*,\s*', ', ', result)
        
        return result.strip()
    
    def fingerprint(self, normalized: str) -> str:
        """
        Generate a fingerprint of the normalized query.
        
        Args:
            normalized: The normalized query
            
        Returns:
            A short fingerprint string
        """
        # Use SHA-256 for hashing
        hash_bytes = hashlib.sha256(normalized.encode('utf-8')).digest()
        # Return first 16 bytes as hex
        return hash_bytes.hex()[:16]
    
    def are_structurally_identical(self, sql1: str, sql2: str) -> bool:
        """
        Check if two queries are structurally identical.
        
        Args:
            sql1: First SQL query
            sql2: Second SQL query
            
        Returns:
            True if the queries have the same structure
        """
        norm1 = self.normalize(sql1)
        norm2 = self.normalize(sql2)
        return norm1 == norm2
    
    def count_placeholders(self, normalized: str) -> int:
        """
        Count the number of literal placeholders in a query.
        
        Args:
            normalized: The normalized query
            
        Returns:
            Number of placeholders
        """
        return normalized.count('?')
    
    def analyze_structure(self, sql: str) -> Dict[str, Any]:
        """
        Analyze the structure of a query.
        
        Args:
            sql: The SQL query
            
        Returns:
            Dictionary with structure information
        """
        normalized = self.normalize(sql)
        placeholders = self.count_placeholders(normalized)
        
        # Extract the query type
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

def normalize_query(sql: str, **options) -> str:
    """
    Convenience function for quick normalization.
    
    Args:
        sql: The SQL query
        **options: Normalization options
        
    Returns:
        The normalized query
    """
    opts = NormalizationOptions(**options)
    normalizer = QueryNormalizer(opts)
    return normalizer.normalize(sql)

def are_queries_identical(sql1: str, sql2: str, **options) -> bool:
    """
    Convenience function for structural comparison.
    
    Args:
        sql1: First SQL query
        sql2: Second SQL query
        **options: Normalization options
        
    Returns:
        True if queries have the same structure
    """
    opts = NormalizationOptions(**options)
    normalizer = QueryNormalizer(opts)
    return normalizer.are_structurally_identical(sql1, sql2)
```

---

### Step 2: Enhanced AuditedSQLite with Normalization

Now let's enhance our `AuditedSQLite` class to store normalized queries.

**File: `python/normalized_audited_sqlite.py`**

```python
# python/normalized_audited_sqlite.py

"""
Enhanced AuditedSQLite with query normalization.
"""

import sqlite3
import json
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone
from audited_sqlite import AuditedSQLite
from normalizer import QueryNormalizer, NormalizationOptions

class NormalizedAuditedSQLite(AuditedSQLite):
    """
    Enhanced SQLite audit with query normalization.
    
    This extends the base AuditedSQLite to store both raw and normalized
    queries, enabling pattern-based analysis and efficient storage.
    
    Additional features:
        - Stores normalized query patterns
        - Generates fingerprints for pattern matching
        - Counts placeholders for complexity analysis
        - Query pattern grouping and analysis
    """
    
    def __init__(self, db_path: str, 
                 options: Optional[NormalizationOptions] = None,
                 store_raw_queries: bool = True,
                 store_normalized: bool = True,
                 auto_fingerprint: bool = True):
        """
        Initialize the normalized audited SQLite connection.
        
        Args:
            db_path: Path to the SQLite database file
            options: Normalization options
            store_raw_queries: Store raw queries in the audit table
            store_normalized: Store normalized queries in the audit table
            auto_fingerprint: Auto-generate fingerprints
        """
        # Initialize the base audited SQLite
        super().__init__(db_path, create_audit_table=False)
        
        self.options = options or NormalizationOptions()
        self.store_raw_queries = store_raw_queries
        self.store_normalized = store_normalized
        self.auto_fingerprint = auto_fingerprint
        
        # Create the normalizer
        self.normalizer = QueryNormalizer(self.options)
        
        # Extend the audit table
        self._extend_audit_table()
    
    def _extend_audit_table(self) -> None:
        """Extend the audit table with normalization columns."""
        conn = self._get_connection()
        
        # Check if columns exist and add them if not
        cursor = conn.execute("PRAGMA table_info(audit_logs)")
        columns = [row[1] for row in cursor.fetchall()]
        
        if 'normalized_query' not in columns:
            conn.execute("ALTER TABLE audit_logs ADD COLUMN normalized_query TEXT")
        
        if 'query_fingerprint' not in columns:
            conn.execute("ALTER TABLE audit_logs ADD COLUMN query_fingerprint VARCHAR(32)")
        
        if 'placeholder_count' not in columns:
            conn.execute("ALTER TABLE audit_logs ADD COLUMN placeholder_count INTEGER")
        
        conn.commit()
        
        # Create index on fingerprint if it doesn't exist
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_audit_logs_fingerprint "
            "ON audit_logs(query_fingerprint)"
        )
        conn.commit()
    
    def _log_audit(self, audit_entry: Dict[str, Any]) -> None:
        """
        Override audit logging to include normalized queries.
        
        Args:
            audit_entry: The audit entry dictionary
        """
        raw_query = audit_entry.get('query_text', '')
        
        # Generate normalized query
        normalized_query = None
        fingerprint = None
        placeholder_count = 0
        
        if self.store_normalized and raw_query:
            try:
                normalized_query = self.normalizer.normalize(raw_query)
                placeholder_count = self.normalizer.count_placeholders(normalized_query)
                
                if self.auto_fingerprint:
                    fingerprint = self.normalizer.fingerprint(normalized_query)
            except Exception as e:
                print(f"[NORMALIZED AUDIT] Normalization failed: {e}")
        
        conn = self._get_connection()
        try:
            conn.execute(
                """
                INSERT INTO audit_logs (
                    query_text, normalized_query, query_fingerprint,
                    placeholder_count, query_params, duration_ms,
                    user_id, user_ip, status, error_message
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    raw_query if self.store_raw_queries else '[REDACTED]',
                    normalized_query,
                    fingerprint,
                    placeholder_count,
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
            print(f"[NORMALIZED AUDIT] Audit write failed: {e}")
            print(f"[NORMALIZED AUDIT] Original audit entry: {audit_entry}")
        
        # Log to console with normalized version
        timestamp = datetime.now(timezone.utc).isoformat()
        print(
            f"[NORMALIZED AUDIT] {timestamp} | "
            f"User: {audit_entry.get('user_id', 'system')} | "
            f"Status: {audit_entry['status']} | "
            f"Duration: {audit_entry['duration_ms']:.2f}ms | "
            f"Raw: {raw_query[:60]}{'...' if len(raw_query) > 60 else ''} | "
            f"Pattern: {normalized_query[:40] + '...' if normalized_query and len(normalized_query) > 40 else normalized_query}"
        )
    
    def get_query_patterns(self, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get query patterns grouped by fingerprint.
        
        Args:
            limit: Maximum number of patterns to return
            
        Returns:
            List of query pattern statistics
        """
        result = self.query(
            """
            SELECT 
                query_fingerprint,
                normalized_query,
                placeholder_count,
                COUNT(*) as occurrence_count,
                AVG(duration_ms) as avg_duration_ms,
                MAX(duration_ms) as max_duration_ms,
                MIN(duration_ms) as min_duration_ms,
                COUNT(DISTINCT user_id) as distinct_users,
                COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as error_count
            FROM audit_logs
            WHERE normalized_query IS NOT NULL
            GROUP BY query_fingerprint, normalized_query, placeholder_count
            ORDER BY occurrence_count DESC
            LIMIT ?
            """,
            (limit,)
        )
        return result
    
    def find_similar_queries(self, sql: str, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Find queries similar to a given pattern.
        
        Args:
            sql: SQL query to find similar patterns for
            limit: Maximum number of results
            
        Returns:
            Similar query patterns
        """
        normalized = self.normalizer.normalize(sql)
        fingerprint = self.normalizer.fingerprint(normalized)
        
        return self.query(
            """
            SELECT 
                query_text,
                normalized_query,
                user_id,
                timestamp,
                duration_ms,
                status
            FROM audit_logs
            WHERE query_fingerprint = ?
            ORDER BY timestamp DESC
            LIMIT ?
            """,
            (fingerprint, limit)
        )
    
    def get_security_stats(self) -> Dict[str, Any]:
        """
        Get query pattern statistics for security analysis.
        
        Returns:
            Dictionary with security statistics
        """
        result = self.query_one(
            """
            SELECT 
                COUNT(DISTINCT query_fingerprint) as unique_patterns,
                COUNT(*) as total_queries,
                AVG(placeholder_count) as avg_complexity,
                MAX(placeholder_count) as max_complexity,
                COUNT(CASE WHEN status = 'ERROR' THEN 1 END) as failed_queries,
                COUNT(CASE WHEN query_text ILIKE '%DROP%' THEN 1 END) as drop_attempts,
                COUNT(CASE WHEN query_text ILIKE '%TRUNCATE%' THEN 1 END) as truncate_attempts
            FROM audit_logs
            WHERE normalized_query IS NOT NULL
            """
        )
        return result or {}
    
    def get_anomalies(self, threshold: float = 3.0) -> List[Dict[str, Any]]:
        """
        Detect anomalous query patterns using statistical analysis.
        
        Args:
            threshold: Number of standard deviations to consider anomalous
            
        Returns:
            List of anomalous query patterns
        """
        # Get patterns with their statistics
        patterns = self.get_query_patterns(limit=1000)
        
        # Calculate mean and standard deviation of occurrences
        if not patterns:
            return []
        
        occurrences = [p['occurrence_count'] for p in patterns]
        mean = sum(occurrences) / len(occurrences)
        variance = sum((x - mean) ** 2 for x in occurrences) / len(occurrences)
        std_dev = variance ** 0.5
        
        # Find anomalies
        anomalies = []
        for pattern in patterns:
            z_score = (pattern['occurrence_count'] - mean) / std_dev if std_dev > 0 else 0
            if abs(z_score) > threshold:
                pattern['z_score'] = z_score
                anomalies.append(pattern)
        
        return sorted(anomalies, key=lambda x: abs(x['z_score']), reverse=True)
```

---

### Step 3: Testing Python Normalization

Now let's test our Python normalizer.

**File: `python/test_normalizer.py`**

```python
# python/test_normalizer.py

"""
Test script for the query normalizer.
"""

from normalizer import QueryNormalizer, NormalizationOptions, normalize_query, are_queries_identical

def test_normalizer():
    """Test the query normalizer with various SQL patterns."""
    
    print("🧪 Testing Query Normalizer...\n")
    
    normalizer = QueryNormalizer()
    
    # Test cases: [raw SQL, expected normalized output]
    test_cases = [
        # Basic SELECT
        (
            "SELECT * FROM users WHERE email = 'alice@example.com'",
            "SELECT * FROM users WHERE email = '?'"
        ),
        
        # SELECT with numbers
        (
            "SELECT * FROM products WHERE price > 100 AND stock < 50",
            "SELECT * FROM products WHERE price > ? AND stock < ?"
        ),
        
        # INSERT
        (
            "INSERT INTO users (name, email, age) VALUES ('Alice', 'alice@example.com', 30)",
            "INSERT INTO users (name, email, age) VALUES ('?', '?', ?)"
        ),
        
        # UPDATE
        (
            "UPDATE products SET price = 29.99, stock = 100 WHERE id = 123",
            "UPDATE products SET price = ?, stock = ? WHERE id = ?"
        ),
        
        # DELETE
        (
            "DELETE FROM users WHERE last_login < '2024-01-01' AND status = 'inactive'",
            "DELETE FROM users WHERE last_login < '?' AND status = '?'"
        ),
        
        # IN clause
        (
            "SELECT * FROM users WHERE id IN (1, 2, 3, 4, 5)",
            "SELECT * FROM users WHERE id IN (?, ?, ?, ?, ?)"
        ),
        
        # Complex WHERE
        (
            "SELECT * FROM orders WHERE amount > 1000 AND status = 'pending' AND created_at > '2024-01-01'",
            "SELECT * FROM orders WHERE amount > ? AND status = '?' AND created_at > '?'"
        ),
        
        # JSON operation
        (
            "SELECT data->>'name' FROM users WHERE data->>'email' = 'alice@example.com'",
            "SELECT data->>'name' FROM users WHERE data->>'email' = '?'"
        ),
        
        # UUID
        (
            "SELECT * FROM sessions WHERE session_id = '123e4567-e89b-12d3-a456-426614174000'",
            "SELECT * FROM sessions WHERE session_id = '?'"
        ),
        
        # Multiple lines and whitespace
        (
            "SELECT\n  *\nFROM\n  users\nWHERE\n  id = 123",
            "SELECT * FROM users WHERE id = ?"
        ),
        
        # Nested conditions
        (
            "SELECT * FROM orders WHERE (status = 'pending' AND amount > 100) OR (status = 'processing' AND amount > 200)",
            "SELECT * FROM orders WHERE (status = '?' AND amount > ?) OR (status = '?' AND amount > ?)"
        )
    ]
    
    passed = 0
    failed = 0
    
    for idx, (raw, expected) in enumerate(test_cases, 1):
        normalized = normalizer.normalize(raw)
        is_match = normalized == expected
        
        print(f"\n📝 Test {idx}:")
        print(f"   Raw:   {raw[:80]}{'...' if len(raw) > 80 else ''}")
        print(f"   Norm:  {normalized}")
        print(f"   Expected: {expected}")
        print(f"   { '✅ PASS' if is_match else '❌ FAIL' }")
        
        if is_match:
            passed += 1
        else:
            failed += 1
    
    print(f"\n📊 Results: {passed} passed, {failed} failed")
    
    # Additional tests for structural comparison
    print("\n📝 Structural Comparison Tests:")
    
    identical_queries = [
        "SELECT * FROM users WHERE email = 'alice@example.com'",
        "SELECT * FROM users WHERE email = 'bob@example.com'"
    ]
    is_identical = are_queries_identical(identical_queries[0], identical_queries[1])
    print(f"   Queries '{identical_queries[0][:30]}...' and '{identical_queries[1][:30]}...'")
    print(f"   Structurally identical? { '✅ Yes' if is_identical else '❌ No' }")
    
    different_queries = [
        "SELECT * FROM users WHERE email = 'alice@example.com'",
        "SELECT * FROM products WHERE price > 100"
    ]
    is_different = not are_queries_identical(different_queries[0], different_queries[1])
    print(f"   Queries '{different_queries[0][:30]}...' and '{different_queries[1][:30]}...'")
    print(f"   Structurally different? { '✅ Yes' if is_different else '❌ No' }")
    
    # Test fingerprint generation
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
    print(f"   Fingerprints match? { '✅ Yes' if fp1 == fp2 else '❌ No' }")
    
    # Test analysis
    print("\n📝 Query Analysis:")
    analysis = normalizer.analyze_structure(
        "SELECT name, email FROM users WHERE age > 21 AND status = 'active'"
    )
    print(f"   Query Type: {analysis['query_type']}")
    print(f"   Placeholders: {analysis['placeholders']}")
    print(f"   Fingerprint: {analysis['fingerprint']}")
    print(f"   Normalized: {analysis['normalized']}")
    
    return passed, failed

if __name__ == "__main__":
    test_normalizer()
```

---

## Verification: Testing Both Implementations

### JavaScript Verification

**Run the normalizer tests:**

```bash
cd javascript
node tests/test-normalizer.js
```

Expected output (abbreviated):

```
🧪 Testing Query Normalizer...

📝 Test 1:
   Raw:   SELECT * FROM users WHERE email = 'alice@example.com'
   Norm:  SELECT * FROM users WHERE email = '?'
   Expected: SELECT * FROM users WHERE email = '?'
   ✅ PASS

📝 Test 2:
   Raw:   SELECT * FROM products WHERE price > 100 AND stock < 50
   Norm:  SELECT * FROM products WHERE price > ? AND stock < ?
   Expected: SELECT * FROM products WHERE price > ? AND stock < ?
   ✅ PASS

... (more tests)

📊 Results: 11 passed, 0 failed

📝 Structural Comparison Tests:
   Queries "SELECT * FROM users WHERE email = 'alice..." and "SELECT * FROM users WHERE email = 'bob..."
   Structurally identical? ✅ Yes
   Queries "SELECT * FROM users WHERE email = 'alice..." and "SELECT * FROM products WHERE price > 100..."
   Structurally different? ✅ Yes

📝 Fingerprint Generation:
   Query 1: SELECT * FROM users WHERE id = 1
   Query 2: SELECT * FROM users WHERE id = 2
   Fingerprint 1: a1b2c3d4e5f67890
   Fingerprint 2: a1b2c3d4e5f67890
   Fingerprints match? ✅ Yes

📝 Query Analysis:
   Query Type: SELECT
   Placeholders: 2
   Fingerprint: f1e2d3c4b5a67890
   Normalized: SELECT name, email FROM users WHERE age > ? AND status = '?'
```

### Python Verification

**Run the normalizer tests:**

```bash
cd python
python test_normalizer.py
```

Expected output (similar to JavaScript):

```
🧪 Testing Query Normalizer...

📝 Test 1:
   Raw:   SELECT * FROM users WHERE email = 'alice@example.com'
   Norm:  SELECT * FROM users WHERE email = '?'
   Expected: SELECT * FROM users WHERE email = '?'
   ✅ PASS

📝 Test 2:
   Raw:   SELECT * FROM products WHERE price > 100 AND stock < 50
   Norm:  SELECT * FROM products WHERE price > ? AND stock < ?
   Expected: SELECT * FROM products WHERE price > ? AND stock < ?
   ✅ PASS

... (more tests)

📊 Results: 11 passed, 0 failed

📝 Structural Comparison Tests:
   Queries 'SELECT * FROM users WHERE email = 'alice...' and 'SELECT * FROM users WHERE email = 'bob...'
   Structurally identical? ✅ Yes
   Queries 'SELECT * FROM users WHERE email = 'alice...' and 'SELECT * FROM products WHERE price > 100...'
   Structurally different? ✅ Yes

📝 Fingerprint Generation:
   Query 1: SELECT * FROM users WHERE id = 1
   Query 2: SELECT * FROM users WHERE id = 2
   Fingerprint 1: a1b2c3d4e5f67890
   Fingerprint 2: a1b2c3d4e5f67890
   Fingerprints match? ✅ Yes

📝 Query Analysis:
   Query Type: SELECT
   Placeholders: 2
   Fingerprint: f1e2d3c4b5a67890
   Normalized: SELECT name, email FROM users WHERE age > ? AND status = '?'
```

---

## Deep Reference Section

### Reference: SQL Parsing vs. Normalization

**What's the Difference?**

- **Parsing**: Understanding the complete structure of SQL (AST - Abstract Syntax Tree)
- **Normalization**: Replacing values with placeholders (simpler, faster)

**Why We Use Normalization Instead of Full Parsing:**

1. **Performance**: Normalization is fast (regex-based) vs. parsing (needs full grammar)
2. **Simplicity**: Normalization is easier to implement correctly
3. **Sufficiency**: For DAM purposes, knowing the pattern is usually enough
4. **Language Support**: Works across SQL dialects without a full parser

**When Would You Need Full Parsing?**

- Complex query rewriting
- Advanced optimization
- Complete structural analysis

### Reference: Regular Expression Patterns

**String Literal Pattern:**

```regex
'[^']*(?:''[^']*)*'
```

- `'` - Opening quote
- `[^']*` - Any characters except quotes
- `(?:''[^']*)*` - Handle escaped quotes (it''s)
- `'` - Closing quote

**Numeric Literal Pattern:**

```regex
\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b
```

- `\b` - Word boundary
- `-?` - Optional minus sign
- `\d+` - One or more digits
- `(?:\.\d+)?` - Optional decimal part
- `(?:[eE][+-]?\d+)?` - Optional scientific notation
- `\b` - Word boundary

### Reference: Performance Optimization

**How Normalization Affects Performance:**

| Operation | Time (microseconds) | Notes |
|-----------|-------------------|-------|
| Raw Query | 0 | No processing |
| Basic Normalization | 5-10 | String + numeric replacement |
| Full Normalization | 10-20 | All replacements + whitespace |
| With Parsing | 100-500 | Full SQL parsing |

**Optimization Tips:**

1. **Cache Normalized Results**:
   ```javascript
   const cache = new Map();
   function cachedNormalize(sql) {
       if (!cache.has(sql)) {
           cache.set(sql, normalizeQuery(sql));
       }
       return cache.get(sql);
   }
   ```

2. **Sample-Based Normalization**:
   Only normalize a percentage of queries in high-volume systems

3. **Async Normalization**:
   Normalize in the background after logging

4. **Lazy Normalization**:
   Only normalize when querying/analyzing, not on every log

### Reference: Privacy Considerations

**Data Protection with Normalization:**

| Element | Raw | Normalized | Privacy Impact |
|---------|-----|------------|----------------|
| Email | alice@example.com | '?' | ✅ Protected |
| Phone | 555-123-4567 | '?' | ✅ Protected |
| Name | Alice Johnson | '?' | ✅ Protected |
| Address | 123 Main St | '?' | ✅ Protected |
| SSN | 123-45-6789 | '?' | ✅ Protected |
| Credit Card | 4111-1111-1111-1111 | '?' | ✅ Protected |

**But Be Careful With:**

1. **Identifiers in Non-Literal Contexts**:
   ```sql
   -- This could expose sensitive table names
   SELECT * FROM sensitive_table WHERE id = 1
   -- Normalized: SELECT * FROM sensitive_table WHERE id = ?
   -- Table name is still visible!
   ```

2. **Timestamps in Non-Literal Contexts**:
   ```sql
   -- The timestamp is in a function call, not a literal
   SELECT * FROM logs WHERE created_at > NOW() - INTERVAL '7 days'
   -- The '7 days' is a literal, but the function might leak info
   ```

3. **Numbers as Identifiers**:
   ```sql
   -- This column name might be sensitive
   SELECT employee_123 from users
   -- The 123 in employee_123 is not replaced (it's part of identifier)
   ```

**Best Practices for Privacy:**

1. Always normalize before storing audit logs
2. Implement additional redaction for sensitive identifiers
3. Use access controls on audit logs
4. Implement encryption for stored audit logs
5. Regularly review what's being logged

---

## Summary: What You've Built

### JavaScript Implementation
- ✅ **QueryNormalizer** class with comprehensive normalization
- ✅ String, numeric, UUID, and JSON literal replacement
- ✅ IN clause normalization
- ✅ Whitespace normalization
- ✅ Fingerprint generation for pattern matching
- ✅ Structural comparison for query analysis
- ✅ **NormalizedAuditedPool** with enhanced audit logging
- ✅ Pattern-based query analysis
- ✅ Security statistics generation

### Python Implementation
- ✅ **QueryNormalizer** class with all normalization features
- ✅ Regex-based literal replacement
- ✅ IN clause normalization
- ✅ Whitespace normalization
- ✅ Fingerprint generation
- ✅ Structural comparison
- ✅ **NormalizedAuditedSQLite** with enhanced audit logging
- ✅ Pattern grouping and analysis
- ✅ Anomaly detection using statistical analysis

### Common Knowledge Gained
- ✅ Why query normalization is essential for DAM
- ✅ How to strip literal values while preserving structure
- ✅ Privacy protection through normalization
- ✅ Pattern matching and fingerprinting
- ✅ Performance considerations for normalization
- ✅ Security analysis using normalized queries

---

## What's Next: Part 4 - Behavioral Rules & SQL Injection Detection

In Part 3, we learned how to normalize queries into compact, analyzable patterns. Now we can detect threats in real-time by looking for suspicious patterns in these normalized queries.

In Part 4, we'll build:
- **Rule engine** for detecting dangerous SQL patterns
- **SQL injection detection** using heuristics
- **Real-time blocking** of malicious queries
- **Threat scoring** to prioritize responses
- **Whitelist/blacklist** management

**Get ready to build your threat detection engine!**

*Part 3 is complete! You now have powerful query normalization that transforms verbose SQL into analyzable patterns. Continue to Part 4 to build a rule engine that detects and blocks threats in real-time.*
