# DAM Tutorial Series: Comprehensive Quiz & Test Bank

Welcome to the DAM Tutorial Quiz & Test Bank! This comprehensive assessment resource is designed for instructors, self-learners, and certification programs. It includes:

- **Multiple Choice Questions** - Test factual knowledge
- **True/False Questions** - Verify understanding of concepts
- **Fill-in-the-Blank** - Assess recall of key terms
- **Short Answer Questions** - Evaluate comprehension
- **Scenario-Based Questions** - Test application of knowledge
- **Hands-On Practical Assessments** - Validate coding skills
- **Answer Keys** - Complete with explanations

---

## HOW TO USE THIS TEST BANK

### For Instructors

| Assessment Type | Recommended Use | Time |
|-----------------|-----------------|------|
| **Pre-Assessment** | Before series starts | 15 min |
| **Module Quizzes** | After each part | 10-15 min |
| **Mid-Term Exam** | After Part 3 | 45-60 min |
| **Final Exam** | After Part 5 | 90-120 min |
| **Practical Lab** | Throughout series | Variable |

### For Self-Learners

| Assessment Type | Recommended Use | Time |
|-----------------|-----------------|------|
| **Self-Check** | After each module | 5-10 min |
| **Knowledge Review** | Before moving on | 15 min |
| **Final Assessment** | After completing series | 60 min |

### Scoring Guide

| Score Range | Rating | Action |
|-------------|--------|--------|
| 90-100% | Excellent | Move to next part |
| 75-89% | Good | Review weak areas |
| 60-74% | Satisfactory | Re-study the material |
| Below 60% | Needs Improvement | Retake the module |

---

# SECTION 1: PART 1 ASSESSMENT

## Multiple Choice Questions

**1.1.1** What does DAM stand for?
- A) Database Access Management
- B) Database Activity Monitoring
- C) Database Activity Management
- D) Data Access Management

**Answer:** C) Database Activity Management

**1.1.2** Which of the following is NOT one of the five pillars of DAM?
- A) Visibility
- B) Normalization
- C) Encryption
- D) Detection

**Answer:** C) Encryption

**1.1.3** What is the "Before-During-After" pattern in audit logging?
- A) A database backup strategy
- B) A logging pattern that captures context, executes, then logs results
- C) A deployment pattern for microservices
- D) A security scanning methodology

**Answer:** B) A logging pattern that captures context, executes, then logs results

**1.1.4** Why does the JavaScript `AuditedPool` use a separate connection for audit logging?
- A) For better performance
- B) To avoid infinite recursion
- C) To support multiple databases
- D) To improve security

**Answer:** B) To avoid infinite recursion

**1.1.5** What information does a complete audit trail capture?
- A) Only successful queries
- B) Who, what, when, where, and how
- C) Only error messages
- D) Only query execution time

**Answer:** B) Who, what, when, where, and how

**1.1.6** In the Python `AuditedSQLite`, what does the `@contextmanager` decorator provide?
- A) Automatic database connection pooling
- B) Transaction management with automatic commit/rollback
- C) Query optimization
- D) Encryption

**Answer:** B) Transaction management with automatic commit/rollback

**1.1.7** Which of the following is NOT a critical property of audit trails?
- A) Immutability
- B) Completeness
- C) Compression
- D) Verifiability

**Answer:** C) Compression

**1.1.8** What is the primary purpose of the `userContext` parameter in the `query()` method?
- A) To encrypt the query
- B) To log who executed the query
- C) To optimize query performance
- D) To validate input

**Answer:** B) To log who executed the query

---

## True/False Questions

**1.2.1** Audit trails should only log successful queries, not failures.

**Answer:** FALSE - Complete audit trails log both successes AND failures.

**1.2.2** The incident vault should be append-only to prevent tampering.

**Answer:** TRUE - Append-only storage ensures immutability.

**1.2.3** Database Activity Management (DAM) replaces traditional firewalls.

**Answer:** FALSE - DAM complements traditional security; it doesn't replace it.

**1.2.4** The average time to detect a data breach is approximately 277 days.

**Answer:** TRUE - According to IBM Cost of Data Breach report.

**1.2.5** SQL injection attacks represent less than 10% of all web application attacks.

**Answer:** FALSE - SQL injection is the #1 web application attack vector.

---

## Fill-in-the-Blank

**1.3.1** The __________ property of audit trails ensures that once a record is written, it can never be modified or deleted.

**Answer:** immutability

**1.3.2** In the JavaScript `AuditedPool`, the __________ method is called automatically on the first query to create the audit table.

**Answer:** `initAuditTable()`

**1.3.3** The __________ property of audit trails means every query is logged, regardless of the outcome.

**Answer:** completeness

**1.3.4** In Python, the __________ context manager is used to handle database transactions with automatic commit and rollback.

**Answer:** `transaction`

**1.3.5** The __________ is the database column that stores whether a query succeeded or failed.

**Answer:** `status`

---

## Short Answer Questions

**1.4.1** Explain why audit trails are essential for security and compliance. Provide at least three reasons.

**Answer:**
1. **Security Investigation**: Audit trails provide the evidence needed to investigate security incidents and identify root causes.
2. **Compliance**: Regulations like GDPR, HIPAA, and PCI DSS require detailed logging of database access.
3. **Insider Threat Detection**: Audit trails can identify suspicious behavior from legitimate users.
4. **Deterrence**: The knowledge that actions are logged discourages malicious behavior.
5. **Forensic Analysis**: Provides a timeline of events during security incidents.
6. **Data Governance**: Enables organizations to track data access and usage.

**1.4.2** Describe the "Before-During-After" pattern used in audit logging. Explain each phase and its purpose.

**Answer:**
- **Before**: Capture the context - who is executing the query (user ID), when (timestamp), and where (IP address). This provides the necessary metadata for later analysis.
- **During**: Execute the actual database query. This phase is identical to normal query execution - we don't modify the query behavior.
- **After**: Log the result regardless of outcome. Record the duration, success/failure status, and any error messages. This creates the complete audit trail.

**1.4.3** Compare and contrast the JavaScript `AuditedPool` and Python `AuditedSQLite` implementations. What are the key differences in approach?

**Answer:**
| Aspect | JavaScript/Postgres | Python/SQLite |
|--------|-------------------|---------------|
| Connection Model | Connection Pool | Direct/Thread-Local |
| Transaction Handling | Manual (BEGIN/COMMIT) | Context Manager |
| Parameter Storage | JSONB | JSON text |
| Error Handling | Try/Catch/Finally | Try/Except/Finally |
| Database Type | Cloud (Neon) | Local File |
| Concurrency | Async/Promises | Thread-Local |

Both achieve the same goal but use language-appropriate idioms and database-specific features.

---

## Scenario-Based Questions

**1.5.1** A developer runs the following query through your `AuditedPool`:
```sql
SELECT * FROM users WHERE email = 'alice@example.com'
```
The query executes successfully and returns results.

**Question:** What entries appear in the audit log, and what information do they contain?

**Answer:** The audit log contains:
- `query_text`: "SELECT * FROM users WHERE email = 'alice@example.com'"
- `query_params`: [] (no parameters)
- `duration_ms`: Execution time (e.g., 12.34)
- `user_id`: The provided user ID (e.g., 'alice@example.com')
- `user_ip`: The provided IP address
- `status`: "SUCCESS"
- `error_message`: NULL
- `timestamp`: The execution timestamp

Additionally, a console log entry appears: `[DAM AUDIT] ... User: alice@example.com | Status: SUCCESS | Duration: 12.34ms`

**1.5.2** An attacker attempts to exploit a vulnerability by sending this query:
```sql
SELECT * FROM users WHERE email = '' OR 1=1 --'
```

**Question:** How does the `AuditedPool` handle this, and what is recorded in the audit log?

**Answer:** The query is executed (if not blocked by other mechanisms) and the audit system logs:
- The full query text
- The failure (or success, if the query executes)
- User context from the attacker (if provided)
- Status: "ERROR" (if the query fails) or "SUCCESS" (if it executes)
- If it's a SQL injection attempt that the application doesn't catch, the audit trail would capture the suspicious query for later investigation.

**Note:** In a complete DAM system (Part 4), this query would be blocked before execution.

---

## Answer Key Summary - Part 1

| Question | Answer | Explanation |
|----------|--------|-------------|
| 1.1.1 | C | DAM = Database Activity Management |
| 1.1.2 | C | Encryption is data security, not DAM |
| 1.1.3 | B | Before-During-After is the logging pattern |
| 1.1.4 | B | Prevents infinite recursion |
| 1.1.5 | B | Complete audit trails capture who, what, when, where, how |
| 1.1.6 | B | Context manager handles transactions |
| 1.1.7 | C | Compression is not a critical property |
| 1.1.8 | B | Captures user identity for audit |
| 1.2.1 | FALSE | Must log both successes and failures |
| 1.2.2 | TRUE | Append-only ensures immutability |
| 1.2.3 | FALSE | DAM complements, doesn't replace |
| 1.2.4 | TRUE | IBM Cost of Data Breach report |
| 1.2.5 | FALSE | SQL injection is #1 attack vector |

---

# SECTION 2: PART 2 ASSESSMENT

## Multiple Choice Questions

**2.1.1** Why is application-layer auditing insufficient on its own?
- A) It's too slow
- B) It misses queries that bypass the application
- C) It's not secure
- D) It requires too much storage

**Answer:** B) It misses queries that bypass the application

**2.1.2** Which of the following is NOT one of the three interception layers in our DAM system?
- A) Application Layer
- B) Driver Layer
- C) Network Layer
- D) Native Layer

**Answer:** C) Network Layer

**2.1.3** In JavaScript, which class is used for driver-level interception?
- A) `DriverInterceptor`
- B) `AuditedPool`
- C) `QueryNormalizer`
- D) `ThreatDetector`

**Answer:** A) `DriverInterceptor`

**2.1.4** How does the JavaScript `DriverInterceptor` handle new clients created by the pool?
- A) It ignores them
- B) It intercepts them in the `connect` method
- C) It checks them periodically
- D) It fails if new clients are created

**Answer:** B) It intercepts them in the `connect` method

**2.1.5** What SQLite API does Python use for native-level interception?
- A) `sqlite3_exec`
- B) `sqlite3_prepare`
- C) `sqlite3_trace`
- D) `sqlite3_intercept`

**Answer:** C) `sqlite3_trace`

**2.1.6** What is the purpose of the WeakSet in the JavaScript driver interceptor?
- A) To prevent memory leaks
- B) To improve performance
- C) To secure queries
- D) To cache results

**Answer:** A) To prevent memory leaks

**2.1.7** In the interception analogy, what does the "Native Layer" correspond to?
- A) Security guards at the front door
- B) Security cameras on all entrances
- C) Motion sensors detecting any movement
- D) The police force

**Answer:** C) Motion sensors detecting any movement

**2.1.8** Which interception layer is the LOWEST level available in our system?
- A) Application Layer
- B) Driver Layer
- C) Native Layer
- D) Network Layer

**Answer:** C) Native Layer

---

## True/False Questions

**2.2.1** The JavaScript `DriverInterceptor` can only intercept queries through the application layer.

**Answer:** FALSE - It intercepts at the driver level, catching raw connections too.

**2.2.2** SQLite's `set_trace_callback` is a C-level callback that fires for every SQL statement executed.

**Answer:** TRUE - It operates at the native C level.

**2.2.3** The `EnhancedAuditedPool` combines application-layer and driver-layer interception.

**Answer:** TRUE - It extends `AuditedPool` with driver interception.

**2.2.4** Native-level interception is only available in the JavaScript implementation.

**Answer:** FALSE - Native interception is implemented in Python using `sqlite3_trace`.

**2.2.5** In defense-in-depth, more security layers always means more protection.

**Answer:** TRUE - Multiple layers provide redundancy and catch different types of threats.

---

## Fill-in-the-Blank

**2.3.1** The JavaScript `DriverInterceptor` stores the original query method in __________ to restore it later.

**Answer:** `this.originalQuery`

**2.3.2** SQLite's __________ method registers a callback function that fires for every executed SQL statement.

**Answer:** `set_trace_callback`

**2.3.3** The __________ pattern uses multiple, overlapping layers of protection.

**Answer:** defense-in-depth

**2.3.4** In the JavaScript driver interceptor, individual clients are tracked using a __________ to allow garbage collection.

**Answer:** `WeakSet`

**2.3.5** The __________ class combines application-layer auditing with native-level interception for SQLite.

**Answer:** `AuditedNativeSQLite`

---

## Short Answer Questions

**2.4.1** Explain the three interception layers in our DAM system and describe what each layer catches.

**Answer:**
1. **Application Layer (Part 1)**: Catches queries through audited wrappers (`AuditedPool`, `AuditedSQLite`). These queries have full user context and business logic awareness.
2. **Driver Layer (Part 2 - JavaScript)**: Catches queries at the `pg` driver level. This catches queries through raw connections, direct clients, and even queries that bypass the application layer.
3. **Native Layer (Part 2 - Python)**: Catches queries at the SQLite C-level using `sqlite3_trace`. This is the lowest-level interception possible, catching every query regardless of how it's executed.

**2.4.2** Describe how the JavaScript `DriverInterceptor` works, including how it intercepts both pool and client-level queries.

**Answer:**
The `DriverInterceptor` works by wrapping the `query` methods at both the pool and client levels:

1. **Pool-Level Interception**: Wraps the pool's `query()` method. Every query through the pool is intercepted. Also intercepts `pool.connect()` to wrap new clients as they're created.
2. **Client-Level Interception**: Wraps each client's `query()` method. This catches queries through individual clients.
3. **Tracking**: Uses a `WeakSet` to track intercepted clients, allowing garbage collection.

The interceptor preserves the original query method, calls the callback (if provided), logs the query, and then executes the original query.

**2.4.3** Compare and contrast driver-level interception (JavaScript) with native-level interception (Python).

**Answer:**
| Aspect | JavaScript (Driver) | Python (Native) |
|--------|-------------------|-----------------|
| Level | Driver/Library level | Database engine (C) level |
| Technology | pg library method wrapping | sqlite3_trace callback |
| Language | JavaScript | C (via Python callback) |
| Coverage | All pg connections | All SQLite connections |
| Performance | Minimal overhead | Minimal overhead |
| Implementation | Method wrapping | Native callback |
| Bypass Risk | Medium (could use different driver) | Low (would require recompiling SQLite) |

---

## Scenario-Based Questions

**2.5.1** A developer connects to the database using a raw PostgreSQL connection (not through the `AuditedPool`):

```javascript
const { Pool } = require('pg');
const pool = new Pool({ connectionString: DATABASE_URL });
const result = await pool.query('SELECT * FROM users');
```

**Question:** Will this query be intercepted by the DAM system? Why or why not?

**Answer:** Yes, this query WILL be intercepted by the driver-level interceptor if the `EnhancedAuditedPool` is used. The `DriverInterceptor` wraps the pool's `query()` method, so even though the developer didn't use the `AuditedPool` directly, the driver interceptor still catches the query. This demonstrates why interception is necessary—it catches queries that bypass the application-layer audit.

**2.5.2** In a Python application using SQLite, a developer bypasses the `AuditedSQLite` class:

```python
import sqlite3
conn = sqlite3.connect('database.db')
conn.execute('DROP TABLE users')
```

**Question:** Will the DAM system catch this query? Explain the layers that would or would not catch it.

**Answer:** Yes, if native interception is enabled. The `NativeInterceptor` uses SQLite's `set_trace_callback` at the C level, which catches ALL SQL statements regardless of how they're executed. Even though the developer bypassed the `AuditedSQLite` class, the native interceptor still captures the `DROP TABLE` query and logs it.

---

## Answer Key Summary - Part 2

| Question | Answer | Explanation |
|----------|--------|-------------|
| 2.1.1 | B | Application layer misses bypasses |
| 2.1.2 | C | Network layer is not one of our interception layers |
| 2.1.3 | A | `DriverInterceptor` handles driver-level interception |
| 2.1.4 | B | Intercepts in `connect` method |
| 2.1.5 | C | `sqlite3_trace` is the native API |
| 2.1.6 | A | WeakSet prevents memory leaks |
| 2.1.7 | C | Motion sensors = native layer |
| 2.1.8 | C | Native layer is the lowest level |
| 2.2.1 | FALSE | Catches at driver level |
| 2.2.2 | TRUE | C-level callback |
| 2.2.3 | TRUE | Combines both layers |
| 2.2.4 | FALSE | Available in Python implementation |
| 2.2.5 | TRUE | More layers = more protection |

---

# SECTION 3: PART 3 ASSESSMENT

## Multiple Choice Questions

**3.1.1** What is query normalization?
- A) Encrypting SQL queries
- B) Stripping literal values to reveal structural patterns
- C) Converting SQL to NoSQL
- D) Optimizing query performance

**Answer:** B) Stripping literal values to reveal structural patterns

**3.1.2** Which of the following is NOT a benefit of query normalization?
- A) Compact storage
- B) Pattern matching
- C) Faster query execution
- D) Privacy protection

**Answer:** C) Faster query execution

**3.1.3** What does the normalization pattern `'hello' → '?'` accomplish?
- A) It encrypts the string
- B) It removes the string literal and replaces it with a placeholder
- C) It converts the string to uppercase
- D) It validates the string format

**Answer:** B) It removes the string literal and replaces it with a placeholder

**3.1.4** What is a query fingerprint used for?
- A) Encryption
- B) Fast pattern matching and grouping
- C) Query optimization
- D) Authentication

**Answer:** B) Fast pattern matching and grouping

**3.1.5** Which of the following is NOT handled by the `QueryNormalizer`?
- A) String literals
- B) Numeric literals
- C) Query comments
- D) Query execution plans

**Answer:** D) Query execution plans

**3.1.6** How does the normalizer handle IN clauses?
- A) It removes them entirely
- B) It normalizes values to a consistent number of placeholders
- C) It converts them to JOINs
- D) It ignores them

**Answer:** B) It normalizes values to a consistent number of placeholders

**3.1.7** What algorithm is used for generating query fingerprints?
- A) MD5
- B) SHA-256
- C) DES
- D) RSA

**Answer:** B) SHA-256

**3.1.8** Why is whitespace collapsed during normalization?
- A) To improve security
- B) To create consistent patterns for matching
- C) To reduce query size
- D) To prevent SQL injection

**Answer:** B) To create consistent patterns for matching

---

## True/False Questions

**3.2.1** Query normalization makes it easier to group identical query structures.

**Answer:** TRUE - Normalization reveals structural patterns.

**3.2.2** The normalizer replaces UUID literals with numeric placeholders.

**Answer:** FALSE - UUID literals are replaced with `'?'`, not numeric placeholders.

**3.2.3** Query normalization removes all data values from logs, protecting privacy.

**Answer:** TRUE - Literal values are replaced with placeholders.

**3.2.4** A query fingerprint is a short hash of the normalized query that identifies its structure.

**Answer:** TRUE - Fingerprints are used for fast pattern matching.

**3.2.5** The normalizer preserves SQL comments by default.

**Answer:** FALSE - Comments are removed by default.

---

## Fill-in-the-Blank

**3.3.1** After normalization, `SELECT * FROM users WHERE id = 123` becomes __________.

**Answer:** `SELECT * FROM users WHERE id = ?`

**3.3.2** The __________ method in `QueryNormalizer` generates a short hash of the normalized query.

**Answer:** `fingerprint()`

**3.3.3** The normalizer replaces __________ literals with `?` to handle both integers and decimals.

**Answer:** numeric

**3.3.4** The __________ property of normalization replaces multiple spaces with a single space.

**Answer:** whitespace collapse

**3.3.5** The normalizer's __________ method checks if two queries have the same structure.

**Answer:** `areStructurallyIdentical()` (JavaScript) or `are_structurally_identical()` (Python)

---

## Short Answer Questions

**3.4.1** Explain the concept of query normalization and describe why it's important for DAM systems.

**Answer:**
Query normalization is the process of transforming raw SQL queries into compact, structural patterns by replacing literal values with placeholders.

**Why it's important:**

1. **Compact Storage**: Instead of storing every variation, store the pattern once. `SELECT * FROM users WHERE email = 'alice@example.com'` and `SELECT * FROM users WHERE email = 'bob@example.com'` both normalize to `SELECT * FROM users WHERE email = '?'`.

2. **Pattern Matching**: Normalized queries reveal structural patterns, making it easy to group identical query types and detect variations.

3. **Privacy Protection**: Actual data values are removed from logs, protecting PII and sensitive information.

4. **Attack Detection**: Malicious patterns (e.g., `OR 1=1`) are revealed regardless of the specific values used.

**3.4.2** Describe the normalization pipeline, listing each step in order.

**Answer:**
1. **Remove Comments**: Strip SQL comments (`--` and `/* */`)
2. **String Literal Replacement**: Replace `'value'` with `'?'`
3. **Numeric Literal Replacement**: Replace `123` with `?`
4. **UUID Literal Replacement**: Replace UUIDs with `'?'`
5. **JSON Literal Replacement**: Replace JSON objects with `'?'`
6. **IN Clause Normalization**: Normalize `IN (1,2,3)` to `IN (?, ?, ?)`
7. **Whitespace Collapse**: Replace multiple spaces with a single space
8. **Case Normalization (Optional)**: Convert to lowercase for case-insensitive matching

**3.4.3** How does the normalizer handle string literals, and what edge cases does it handle?

**Answer:**
The normalizer handles string literals by:
1. Replacing single-quoted strings with `'?'`
2. Handling escaped quotes (e.g., `'O''Brien'` becomes `'?'`)
3. Protecting double-quoted identifiers (e.g., `"column_name"` is preserved)

The regex pattern `'[^']*(?:''[^']*)*'` handles:
- Normal strings: `'hello'`
- Strings with escaped quotes: `'it''s'`
- Strings with escape sequences: `'hello\nworld'`

---

## Scenario-Based Questions

**3.5.1** You have these two queries:
```sql
SELECT * FROM users WHERE email = 'alice@example.com' AND age = 30;
SELECT * FROM users WHERE email = 'bob@example.com' AND age = 25;
```

**Question:** What do these queries become after normalization, and why is this useful?

**Answer:**
After normalization, both become: `SELECT * FROM users WHERE email = '?' AND age = ?`

**Why it's useful:**
- **Storage Efficiency**: Store one pattern instead of two variations
- **Pattern Analysis**: Both queries are recognized as the same structural type
- **Grouping**: Can group both queries together for analysis
- **Privacy**: Actual email addresses and ages are not stored
- **Detection**: If an attack pattern matches this structure, it's detected regardless of the specific values

**3.5.2** A security analyst is reviewing query logs and sees these normalized queries:
```
SELECT * FROM users WHERE email = '?' AND password = '?' AND role = '?'
SELECT * FROM users WHERE email = '?' AND role = '?' AND password = '?'
```

**Question:** What can you conclude from these patterns, and what's the difference between them?

**Answer:**
These queries are structurally similar but have a subtle difference in order. The first checks email, then password, then role. The second checks email, then role, then password.

**Conclusion:**
- Both are SELECT queries on the `users` table
- Both use three parameters
- The order of parameters differs

**Potential Concerns:**
- If these are authentication queries, the order of password vs role matters for security
- The different order might indicate different code paths or potential vulnerabilities
- The analyst should investigate why there are two different orders for the same query pattern

---

## Answer Key Summary - Part 3

| Question | Answer | Explanation |
|----------|--------|-------------|
| 3.1.1 | B | Normalization strips literal values |
| 3.1.2 | C | Normalization doesn't speed up execution |
| 3.1.3 | B | Replaces literal with placeholder |
| 3.1.4 | B | Fingerprints enable fast pattern matching |
| 3.1.5 | D | Execution plans are not normalized |
| 3.1.6 | B | Normalizes to consistent placeholders |
| 3.1.7 | B | SHA-256 is used for fingerprints |
| 3.1.8 | B | Creates consistent patterns for matching |
| 3.2.1 | TRUE | Normalization reveals structural patterns |
| 3.2.2 | FALSE | UUIDs become `'?'` |
| 3.2.3 | TRUE | Literal values are removed |
| 3.2.4 | TRUE | Fingerprints identify structure |
| 3.2.5 | FALSE | Comments are removed by default |

---

# SECTION 4: PART 4 ASSESSMENT

## Multiple Choice Questions

**4.1.1** What are the two main approaches to threat detection?
- A) Encryption and decryption
- B) Pattern matching and heuristics
- C) Logging and monitoring
- D) Prevention and response

**Answer:** B) Pattern matching and heuristics

**4.1.2** Which of the following is an example of pattern matching detection?
- A) Detecting access to a table named "passwords"
- B) Detecting `OR 1=1` in a query
- C) Detecting high query frequency
- D) Detecting unusual query times

**Answer:** B) Detecting `OR 1=1` in a query

**4.1.3** What is the threat score for a HIGH severity threat?
- A) 1
- B) 5
- C) 10
- D) 25

**Answer:** C) 10

**4.1.4** What threat level is assigned when the threat score is 25 or higher?
- A) LOW
- B) MEDIUM
- C) HIGH
- D) CRITICAL

**Answer:** D) CRITICAL

**4.1.5** Which of the following is NOT detected by the default rules?
- A) Tautology SQL injection
- B) UNION SELECT injection
- C) NoSQL injection
- D) DROP TABLE operations

**Answer:** C) NoSQL injection

**4.1.6** What does frequency analysis detect?
- A) SQL injection attacks
- B) DDL operations
- C) Brute force attacks
- D) Privilege escalation

**Answer:** C) Brute force attacks

**4.1.7** What is the purpose of the whitelist in the threat detector?
- A) To block all queries
- B) To prevent false positives
- C) To encrypt queries
- D) To optimize performance

**Answer:** B) To prevent false positives

**4.1.8** What action does the `determineAction()` method return when a BLOCK rule is triggered?
- A) ALLOW
- B) WARN
- C) BLOCK
- D) LOG

**Answer:** C) BLOCK

---

## True/False Questions

**4.2.1** Pattern matching can detect attacks that have never been seen before.

**Answer:** FALSE - Pattern matching only detects known attack signatures.

**4.2.2** Heuristic analysis can detect suspicious behavior even if it doesn't match a known pattern.

**Answer:** TRUE - Heuristics look for suspicious behaviors, not just known patterns.

**4.2.3** A threat score of 15 or higher triggers an automatic BLOCK action.

**Answer:** TRUE - Score ≥ 15 triggers BLOCK.

**4.2.4** The `sqli_tautology` rule detects UNION SELECT injection attempts.

**Answer:** FALSE - `sqli_tautology` detects `OR 1=1` patterns. `sqli_union` detects UNION SELECT.

**4.2.5** Time-based injection attacks are detected through heuristic analysis.

**Answer:** TRUE - Heuristics detect `SLEEP()`, `DELAY`, and `WAITFOR` functions.

---

## Fill-in-the-Blank

**4.3.1** The `sqli_union` rule detects __________ attacks.

**Answer:** UNION SELECT injection

**4.3.2** __________ analysis tracks the number of queries per user per time period.

**Answer:** Frequency

**4.3.3** The threat detector's __________ property prevents false positives by exempting safe queries.

**Answer:** whitelist

**4.3.4** The __________ method in the threat detector calculates the total threat score.

**Answer:** `getSeverityScore()` (JavaScript) or `get_severity_score()` (Python)

**4.3.5** The __________ rule detects `DROP TABLE` operations.

**Answer:** `ddl_drop_table`

---

## Short Answer Questions

**4.4.1** Explain the difference between pattern matching and heuristic detection in threat detection.

**Answer:**

| Aspect | Pattern Matching | Heuristic Detection |
|--------|------------------|---------------------|
| **How it works** | Matches known attack signatures (regex patterns) | Looks for suspicious behaviors |
| **Speed** | Fast (simple pattern matching) | Slower (more complex analysis) |
| **False Positives** | Low | Higher (potential false alarms) |
| **False Negatives** | Higher (misses new attacks) | Lower (can detect new attacks) |
| **Examples** | `OR 1=1`, `UNION SELECT` | Sensitive table access, time-based injection |
| **Pros** | Reliable, simple, low false positives | Flexible, detects new attack vectors |
| **Cons** | Can't detect unknown attacks | May have false positives |

**4.4.2** Describe the threat scoring system and how it determines the action to take.

**Answer:**
**Threat Scoring System:**
1. Each threat finding contributes a score based on severity:
   - LOW = 1 point
   - MEDIUM = 5 points
   - HIGH = 10 points
   - CRITICAL = 25 points

2. Total score = sum of all finding scores
3. Threat level is determined by total score:
   - Score ≥ 25 → CRITICAL
   - Score ≥ 10 → HIGH
   - Score ≥ 5 → MEDIUM
   - Score ≥ 1 → LOW
   - Score = 0 → No threat

**Action Determination:**
1. If whitelisted → ALLOW
2. If no threats → ALLOW
3. If any BLOCK rule matched → BLOCK
4. If score ≥ 15 → BLOCK
5. If any WARN rule matched → WARN
6. Otherwise → LOG

**4.4.3** What are the default detection rules, and what does each one detect?

**Answer:**
| Rule ID | Name | Detects |
|---------|------|---------|
| `sqli_tautology` | Tautology SQL Injection | `OR 1=1` pattern |
| `sqli_union` | Union SQL Injection | `UNION SELECT` pattern |
| `sqli_stacked` | Stacked Query Injection | `; DROP TABLE` pattern |
| `sqli_comment` | Comment Injection | `--` comments |
| `ddl_drop_table` | DROP TABLE Attempt | `DROP TABLE` operation |
| `ddl_truncate` | TRUNCATE Attempt | `TRUNCATE` operation |
| `ddl_alter` | ALTER TABLE Attempt | `ALTER TABLE` operation |
| `priv_grant` | GRANT Privilege Attempt | `GRANT` operation |
| `exfil_select_star` | SELECT * with No Filter | `SELECT * FROM table` |
| `heuristic_sensitive_table` | Sensitive Table Access | Access to sensitive tables |
| `heuristic_time_based` | Time-Based Injection | `SLEEP()`, `DELAY` |
| `heuristic_brute_force` | Brute Force Detection | >100 queries/minute |

---

## Scenario-Based Questions

**4.5.1** A user executes this query:
```sql
SELECT * FROM users WHERE email = 'alice@example.com' UNION SELECT * FROM admins
```

**Question:** How does the threat detector handle this query? Include:
- Which rules match
- The threat score and level
- The action taken

**Answer:**
1. **Rules Matched**:
   - `sqli_union` (Union SQL Injection) - CRITICAL severity
   - `heuristic_sensitive_table` (Sensitive Table Access for "admins") - HIGH severity

2. **Threat Score Calculation**:
   - `sqli_union`: 25 points (CRITICAL)
   - `heuristic_sensitive_table`: 10 points (HIGH)
   - Total: 35 points

3. **Threat Level**: CRITICAL (score ≥ 25)

4. **Action Taken**: BLOCK
   - `sqli_union` is a BLOCK rule
   - Score is ≥ 15
   - The query is blocked before execution

**4.5.2** A user executes 150 queries in one minute, all SELECT queries on the `users` table.

**Question:** How does the threat detector handle this? What is detected and what action is taken?

**Answer:**
1. **Detection**:
   - Pattern matching: No individual query matches a threat pattern
   - Heuristic: Accessing `users` table is sensitive (HIGH severity for each query)
   - Frequency analysis: 150 queries/minute triggers the brute force heuristic

2. **Threat Score**:
   - Each sensitive table access: 10 points
   - Brute force detection: 10 points
   - Total: 10 points (overall, not per query)
   - Threat Level: HIGH

3. **Action**:
   - The `heuristic_brute_force` rule is WARN type
   - The `heuristic_sensitive_table` rule is WARN type
   - No BLOCK rule matched
   - Score ≥ 15? No (score = 10)
   - Action: WARN (notify but allow)

---

## Answer Key Summary - Part 4

| Question | Answer | Explanation |
|----------|--------|-------------|
| 4.1.1 | B | Pattern matching + heuristics |
| 4.1.2 | B | `OR 1=1` is a known pattern |
| 4.1.3 | C | HIGH = 10 points |
| 4.1.4 | D | Score ≥ 25 = CRITICAL |
| 4.1.5 | C | NoSQL injection is not detected |
| 4.1.6 | C | Frequency analysis detects brute force |
| 4.1.7 | B | Whitelist prevents false positives |
| 4.1.8 | C | BLOCK rule → BLOCK action |
| 4.2.1 | FALSE | Pattern matching is for known attacks |
| 4.2.2 | TRUE | Heuristics detect suspicious behavior |
| 4.2.3 | TRUE | Score ≥ 15 triggers BLOCK |
| 4.2.4 | FALSE | `sqli_tautology` detects `OR 1=1` |
| 4.2.5 | TRUE | Heuristics detect time-based injection |

---

# SECTION 5: PART 5 ASSESSMENT

## Multiple Choice Questions

**5.1.1** What is the first phase of the incident response lifecycle?
- A) Recovery
- B) Detection
- C) Eradication
- D) Investigation

**Answer:** B) Detection

**5.1.2** Which response action is taken for ALL incidents?
- A) BLOCK_QUERY
- B) TERMINATE_CONNECTION
- C) NOTIFY_SECURITY
- D) LOG_INCIDENT

**Answer:** D) LOG_INCIDENT

**5.1.3** What is the purpose of the circuit breaker pattern?
- A) To improve database performance
- B) To prevent cascading failures
- C) To encrypt data
- D) To speed up queries

**Answer:** B) To prevent cascading failures

**5.1.4** How long does the circuit breaker remain active before expiring?
- A) 1 minute
- B) 5 minutes
- C) 30 minutes
- D) 1 hour

**Answer:** B) 5 minutes

**5.1.5** Which of the following is NOT a response action available in the system?
- A) ISOLATE_USER
- B) REVOKE_CREDENTIALS
- C) ENCRYPT_DATA
- D) CIRCUIT_BREAKER

**Answer:** C) ENCRYPT_DATA

**5.1.6** What format is used for the incident vault?
- A) JSONL (JSON Lines)
- B) CSV
- C) XML
- D) Binary

**Answer:** A) JSONL (JSON Lines)

**5.1.7** Why is the incident vault append-only?
- A) For better performance
- B) To ensure immutability
- C) To save storage
- D) To simplify queries

**Answer:** B) To ensure immutability

**5.1.8** What happens when a HIGH severity incident is detected?
- A) Only LOG_INCIDENT
- B) LOG_INCIDENT + BLOCK_QUERY
- C) LOG_INCIDENT + BLOCK_QUERY + NOTIFY_SECURITY
- D) All actions including ISOLATE_USER

**Answer:** C) LOG_INCIDENT + BLOCK_QUERY + NOTIFY_SECURITY

---

## True/False Questions

**5.2.1** The incident response lifecycle ends with eradication.

**Answer:** FALSE - The lifecycle ends with investigation and prevention.

**5.2.2** CRITICAL incidents trigger the ISOLATE_USER action.

**Answer:** TRUE - CRITICAL severity triggers user isolation.

**5.2.3** The circuit breaker blocks all queries when activated.

**Answer:** TRUE - Circuit breaker blocks ALL queries.

**5.2.4** The incident vault can be modified if needed.

**Answer:** FALSE - The vault is append-only and immutable.

**5.2.5** The `CompleteDAMSystem` integrates all five parts of the DAM pipeline.

**Answer:** TRUE - It combines audit, interception, normalization, detection, and response.

---

## Fill-in-the-Blank

**5.3.1** The __________ pattern prevents cascading failures by blocking all queries after multiple threats.

**Answer:** circuit breaker

**5.3.2** The incident vault stores data in __________ format.

**Answer:** JSONL (JSON Lines)

**5.3.3** The __________ response action terminates the user's database connection.

**Answer:** TERMINATE_CONNECTION

**5.3.4** The __________ method in `IncidentResponder` generates the response plan based on severity.

**Answer:** `generateResponsePlan()` (JavaScript) or `_generate_response_plan()` (Python)

**5.3.5** The __________ class integrates all five parts of the DAM system.

**Answer:** `CompleteDAMSystem`

---

## Short Answer Questions

**5.4.1** Explain the incident response lifecycle and describe each phase.

**Answer:**
1. **Detection**: The threat is identified by the detection engine. This is the trigger for all subsequent phases.

2. **Containment**: The threat is stopped from spreading. Actions include blocking the query, terminating the connection, and activating the circuit breaker.

3. **Eradication**: The threat is removed. Actions include revoking credentials, isolating the user, and rolling back transactions.

4. **Recovery**: Normal operations are restored. This includes reconnecting legitimate users and restoring any affected data.

5. **Investigation/Prevention**: The incident is analyzed to learn from it. Recommendations are generated, rules are updated, and the system is improved to prevent future incidents.

**5.4.2** Describe the circuit breaker pattern and explain why it's important for database security.

**Answer:**
The circuit breaker pattern prevents cascading failures by blocking all queries when a threshold is exceeded.

**States:**
1. **CLOSED**: Normal operation - queries flow freely
2. **OPEN**: Triggered - all queries are blocked
3. **HALF-OPEN**: Testing - one query allowed through to test recovery

**Why it's important:**
1. **Prevents cascading failures**: Stops a single attack from overwhelming the system
2. **Protects the database**: Prevents resource exhaustion
3. **"Fail fast"**: Provides immediate feedback that something is wrong
4. **Automatic recovery**: Self-resets after 5 minutes
5. **Security**: Blocks further attacks while the system recovers

**5.4.3** Describe the `CompleteDAMSystem` class and how it integrates all five parts.

**Answer:**
The `CompleteDAMSystem` is the main entry point that integrates all five DAM components:

1. **Audit (Part 1)**: Through `SecureAuditedPool` (which extends `AuditedPool`)
2. **Interception (Part 2)**: Through `SecureAuditedPool` (which includes interception)
3. **Normalization (Part 3)**: Through `SecureAuditedPool` (which extends `NormalizedAuditedPool`)
4. **Detection (Part 4)**: Through `SecureAuditedPool`'s `ThreatDetector`
5. **Response (Part 5)**: Through `IncidentResponder`

**Integration points:**
- The `query()` method executes through the secure pool
- Threat detection is automatic for every query
- Circuit breaker checks happen before execution
- Security errors trigger incident response

---

## Scenario-Based Questions

**5.5.1** A critical incident is detected with a score of 30. List all response actions that will be taken.

**Answer:**
For a CRITICAL incident (score ≥ 25), the following actions are taken:

1. **LOG_INCIDENT** - Always taken for all incidents
2. **BLOCK_QUERY** - Always taken for all incidents
3. **NOTIFY_SECURITY** - Taken for MEDIUM+ incidents
4. **TERMINATE_CONNECTION** - Taken for HIGH+ incidents (and CRITICAL)
5. **REVOKE_CREDENTIALS** - Taken for CRITICAL incidents
6. **CIRCUIT_BREAKER** - Taken for HIGH+ repeated incidents
7. **ISOLATE_USER** - Taken for CRITICAL incidents

**5.5.2** A user triggers multiple HIGH severity incidents within a short period. What happens, and why?

**Answer:**
1. **First incident**: Query is blocked, connection is terminated, security team is notified, and the incident is logged.

2. **Second incident**: Same actions, but now the circuit breaker is triggered because multiple HIGH incidents occurred.

3. **Circuit breaker activates**: All queries from ALL users are blocked (not just the attacker). This prevents cascading failures and protects the database from being overwhelmed.

4. **Cooldown**: The circuit breaker remains active for 5 minutes, then automatically resets.

**Why this happens**: The circuit breaker pattern is designed to prevent cascading failures. If there are multiple attacks in a short period, it's better to stop ALL queries than to risk database overload or further compromise.

---

## Answer Key Summary - Part 5

| Question | Answer | Explanation |
|----------|--------|-------------|
| 5.1.1 | B | Detection is first in the lifecycle |
| 5.1.2 | D | LOG_INCIDENT is always taken |
| 5.1.3 | B | Circuit breaker prevents cascading failures |
| 5.1.4 | B | 5 minutes is the default cooldown |
| 5.1.5 | C | ENCRYPT_DATA is not a response action |
| 5.1.6 | A | Incident vault uses JSONL format |
| 5.1.7 | B | Append-only ensures immutability |
| 5.1.8 | C | HIGH triggers LOG + BLOCK + NOTIFY |
| 5.2.1 | FALSE | Lifecycle ends with investigation |
| 5.2.2 | TRUE | ISOLATE_USER for CRITICAL |
| 5.2.3 | TRUE | Circuit breaker blocks all queries |
| 5.2.4 | FALSE | Vault is immutable |
| 5.2.5 | TRUE | CompleteDAMSystem integrates all parts |

---

# SECTION 6: COMPREHENSIVE FINAL EXAM

## Part A: Multiple Choice (30 questions - 1 point each)

**6.1.1** What is the primary purpose of DAM?
- A) To improve query performance
- B) To monitor and protect database activities
- C) To replace database encryption
- D) To speed up database backups

**Answer:** B

**6.1.2** Which of the following is NOT a pillar of DAM?
- A) Visibility
- B) Normalization
- C) Virtualization
- D) Detection

**Answer:** C

**6.1.3** The "Before-During-After" pattern in audit logging captures:
- A) Backup, restore, verify
- B) Context, execution, result
- C) Plan, code, test
- D) Read, write, delete

**Answer:** B

**6.1.4** Why does the JavaScript AuditedPool use a separate connection for logging?
- A) To improve performance
- B) To avoid infinite recursion
- C) To support multiple databases
- D) To encrypt the logs

**Answer:** B

**6.1.5** What is the average time to detect a data breach?
- A) 30 days
- B) 277 days
- C) 365 days
- D) 7 days

**Answer:** B

**6.1.6** What is SQL injection?
- A) A method to optimize queries
- B) A technique to inject malicious SQL into a query
- C) A way to compress SQL statements
- D) A database backup method

**Answer:** B

**6.1.7** Which of the following is a SQL injection pattern?
- A) `SELECT * FROM users`
- B) `OR 1=1`
- C) `CREATE TABLE users`
- D) `DROP DATABASE`

**Answer:** B

**6.1.8** In the JavaScript driver interceptor, what is a WeakSet used for?
- A) Caching queries
- B) Tracking intercepted clients without memory leaks
- C) Storing configuration
- D) Managing connections

**Answer:** B

**6.1.9** What SQLite API is used for native-level interception?
- A) `sqlite3_exec`
- B) `sqlite3_prepare`
- C) `sqlite3_trace`
- D) `sqlite3_intercept`

**Answer:** C

**6.1.10** What is the purpose of query normalization?
- A) To encrypt SQL queries
- B) To strip literal values and reveal patterns
- C) To convert SQL to NoSQL
- D) To optimize query performance

**Answer:** B

**6.1.11** After normalization, what does `SELECT * FROM users WHERE id = 123` become?
- A) `SELECT * FROM users WHERE id = '123'`
- B) `SELECT * FROM users WHERE id = ?`
- C) `SELECT * FROM users WHERE id = 123`
- D) `SELECT * FROM users WHERE id = ???`

**Answer:** B

**6.1.12** What is a query fingerprint used for?
- A) Encryption
- B) Fast pattern matching
- C) Query optimization
- D) Authentication

**Answer:** B

**6.1.13** What hash algorithm is used for query fingerprints?
- A) MD5
- B) SHA-256
- C) DES
- D) RSA

**Answer:** B

**6.1.14** What are the two main approaches to threat detection?
- A) Encryption and decryption
- B) Pattern matching and heuristics
- C) Logging and monitoring
- D) Prevention and response

**Answer:** B

**6.1.15** What is the threat score for a HIGH severity threat?
- A) 1
- B) 5
- C) 10
- D) 25

**Answer:** C

**6.1.16** What threat level is assigned when the threat score is 25 or higher?
- A) LOW
- B) MEDIUM
- C) HIGH
- D) CRITICAL

**Answer:** D

**6.1.17** What does frequency analysis detect?
- A) SQL injection
- B) DDL operations
- C) Brute force attacks
- D) Privilege escalation

**Answer:** C

**6.1.18** What is the first phase of the incident response lifecycle?
- A) Recovery
- B) Detection
- C) Eradication
- D) Investigation

**Answer:** B

**6.1.19** Which response action is taken for ALL incidents?
- A) BLOCK_QUERY
- B) TERMINATE_CONNECTION
- C) NOTIFY_SECURITY
- D) LOG_INCIDENT

**Answer:** D

**6.1.20** What is the purpose of the circuit breaker pattern?
- A) To improve performance
- B) To prevent cascading failures
- C) To encrypt data
- D) To speed up queries

**Answer:** B

**6.1.21** How long does the circuit breaker remain active before expiring?
- A) 1 minute
- B) 5 minutes
- C) 30 minutes
- D) 1 hour

**Answer:** B

**6.1.22** What format is used for the incident vault?
- A) JSONL
- B) CSV
- C) XML
- D) Binary

**Answer:** A

**6.1.23** Why is the incident vault append-only?
- A) For performance
- B) To ensure immutability
- C) To save storage
- D) To simplify queries

**Answer:** B

**6.1.24** Which interception layer is the LOWEST level available in our system?
- A) Application Layer
- B) Driver Layer
- C) Native Layer
- D) Network Layer

**Answer:** C

**6.1.25** What is the `sqli_tautology` rule used for?
- A) Detecting UNION SELECT injection
- B) Detecting `OR 1=1` injection
- C) Detecting DROP TABLE operations
- D) Detecting GRANT operations

**Answer:** B

**6.1.26** What is the `ddl_drop_table` rule used for?
- A) Detecting SELECT queries
- B) Detecting DROP TABLE operations
- C) Detecting INSERT operations
- D) Detecting UPDATE operations

**Answer:** B

**6.1.27** What is the `heuristic_sensitive_table` rule used for?
- A) Detecting performance issues
- B) Detecting access to sensitive tables
- C) Detecting connection problems
- D) Detecting backup failures

**Answer:** B

**6.1.28** What does `CompleteDAMSystem` integrate?
- A) Only audit logging
- B) Only threat detection
- C) Only incident response
- D) All five parts of the DAM pipeline

**Answer:** D

**6.1.29** What is the `heuristic_brute_force` rule based on?
- A) Query text analysis
- B) Frequency analysis
- C) Pattern matching
- D) Encryption detection

**Answer:** B

**6.1.30** What is the main benefit of defense-in-depth?
- A) Reducing costs
- B) Multiple layers of protection
- C) Simpler implementation
- D) Faster performance

**Answer:** B

---

## Part B: True/False (10 questions - 1 point each)

**6.2.1** DAM replaces traditional security measures like firewalls.

**Answer:** FALSE - DAM complements, doesn't replace

**6.2.2** Native-level interception catches queries that bypass the application.

**Answer:** TRUE

**6.2.3** Query normalization removes all data values from logs, protecting privacy.

**Answer:** TRUE

**6.2.4** Pattern matching can detect new, unknown attacks.

**Answer:** FALSE - Pattern matching detects known attacks

**6.2.5** Heuristic analysis can detect suspicious behavior even if it doesn't match a known pattern.

**Answer:** TRUE

**6.2.6** The circuit breaker blocks all queries when activated.

**Answer:** TRUE

**6.2.7** The incident vault can be modified after creation.

**Answer:** FALSE - The vault is append-only and immutable

**6.2.8** CRITICAL incidents trigger the ISOLATE_USER action.

**Answer:** TRUE

**6.2.9** The `CompleteDAMSystem` only works with PostgreSQL.

**Answer:** FALSE - Works with PostgreSQL and SQLite

**6.2.10** Frequency analysis is used to detect brute force attacks.

**Answer:** TRUE

---

## Part C: Fill-in-the-Blank (10 questions - 2 points each)

**6.3.1** DAM stands for __________.

**Answer:** Database Activity Management

**6.3.2** The __________ property of audit trails ensures that once a record is written, it can never be modified or deleted.

**Answer:** immutability

**6.3.3** The __________ pattern uses multiple, overlapping layers of protection.

**Answer:** defense-in-depth

**6.3.4** In the JavaScript driver interceptor, individual clients are tracked using a __________ to allow garbage collection.

**Answer:** WeakSet

**6.3.5** SQLite's __________ method registers a callback function that fires for every executed SQL statement.

**Answer:** set_trace_callback

**6.3.6** After normalization, `SELECT * FROM users WHERE id = 123` becomes __________.

**Answer:** `SELECT * FROM users WHERE id = ?`

**6.3.7** The __________ rule detects `OR 1=1` injection attempts.

**Answer:** sqli_tautology

**6.3.8** The __________ rule detects `DROP TABLE` operations.

**Answer:** ddl_drop_table

**6.3.9** The __________ pattern prevents cascading failures by blocking all queries after multiple threats.

**Answer:** circuit breaker

**6.3.10** The __________ class integrates all five parts of the DAM system.

**Answer:** CompleteDAMSystem

---

## Part D: Short Answer (4 questions - 5 points each)

**6.4.1** Explain the five pillars of DAM and how they work together.

**Answer:**
1. **Visibility**: Observes all database operations in real-time. This is the foundation—you can't protect what you can't see.

2. **Normalization**: Transforms verbose SQL into compact patterns by stripping literal values. This enables efficient storage and pattern matching.

3. **Detection**: Analyzes normalized queries to identify threats using pattern matching and heuristics. This is where threats are identified.

4. **Prevention**: Blocks dangerous operations before they execute. This stops threats from causing damage.

5. **Response**: Takes automated action when threats are detected. This includes blocking, notifying, and isolating.

**How they work together**: Visibility provides the raw data, normalization organizes it, detection identifies threats, prevention stops them, and response ensures quick action. Together, they form a complete security pipeline.

**6.4.2** Describe the three interception layers in our DAM system and explain why multiple layers are necessary.

**Answer:**

**1. Application Layer (Part 1)**: Queries through audited wrappers (`AuditedPool`, `AuditedSQLite`). These queries have full user context.

**2. Driver Layer (Part 2 - JavaScript)**: Queries at the `pg` driver level. Catches queries through raw connections and direct clients.

**3. Native Layer (Part 2 - Python)**: Queries at the SQLite C-level using `sqlite3_trace`. This is the lowest-level interception possible.

**Why multiple layers are necessary**:
- Each layer catches different types of queries
- A single layer can be bypassed
- Defense-in-depth ensures complete coverage
- Redundancy provides reliability

**6.4.3** Explain how the threat detection system works, including pattern matching, heuristics, frequency analysis, and threat scoring.

**Answer:**
**Pattern Matching**: Uses regex patterns to detect known attack signatures (`OR 1=1`, `UNION SELECT`, `DROP TABLE`). Fast and reliable but can't detect new attacks.

**Heuristics**: Looks for suspicious behaviors (sensitive table access, time-based injection). Can detect new attacks but may have false positives.

**Frequency Analysis**: Tracks query volume per user (>100/minute triggers alert). Detects brute force and scraping attempts.

**Threat Scoring**: Each finding contributes a score (LOW=1, MEDIUM=5, HIGH=10, CRITICAL=25). Total score determines threat level. Actions are based on score and rule types.

**6.4.4** Explain the incident response lifecycle and the circuit breaker pattern. How do they work together?

**Answer:**
**Incident Response Lifecycle**:
1. **Detection**: Threat is identified
2. **Containment**: Threat is stopped (block, terminate)
3. **Eradication**: Threat is removed (revoke, isolate)
4. **Recovery**: Normal operations restored
5. **Investigation**: Incident is analyzed to prevent recurrence

**Circuit Breaker Pattern**: Blocks ALL queries after multiple threats are detected. States: CLOSED (normal), OPEN (blocked), HALF-OPEN (testing).

**How they work together**:
- Circuit breaker is part of the containment phase
- Multiple detections trigger the circuit breaker
- Circuit breaker prevents cascading failures
- Both are automated for fast response
- Provides time for investigation and recovery

---

## Part E: Scenario-Based Questions (2 questions - 10 points each)

**6.5.1** A security team notices unusual query patterns in their audit logs. They see these normalized queries:

```
SELECT * FROM users WHERE email = '?' AND password = '?' --'
SELECT * FROM users WHERE email = '?' OR 1=1 --'
SELECT * FROM users WHERE email = '' OR 1=1 --' AND password = '?'
```

**Questions:**

a) What type of attack is being attempted?

b) How does the threat detection system identify and handle these queries?

c) What response actions are taken?

d) What would a complete DAM system provide for investigation?

**Answer:**

a) **Attack Type**: SQL Injection attacks, specifically:
- Query 1: Comment injection (`--'`) bypassing authentication
- Query 2: Tautology (`OR 1=1`) bypassing authentication
- Query 3: Combined tautology + comment injection

b) **How the system identifies them**:
- `sqli_tautology` rule detects `OR 1=1` pattern
- `sqli_comment` rule detects `--` pattern
- The queries are analyzed in real-time before execution
- Each rule contributes to the threat score

c) **Response Actions**:
- **BLOCK_QUERY**: Queries are blocked before execution
- **LOG_INCIDENT**: Incidents are recorded
- **NOTIFY_SECURITY**: Security team is alerted (HIGH severity)
- **TERMINATE_CONNECTION**: Connection is terminated (HIGH+ severity)
- **CIRCUIT_BREAKER**: If repeated attacks, circuit breaker triggers

d) **Complete DAM System Investigation**:
- Audit logs show who executed the queries (user_id, ip)
- Normalized queries show the attack patterns
- Incident vault provides immutable evidence
- Time stamps show attack timeline
- Response actions are recorded
- Recommendations are generated for prevention

**6.5.2** A company deploys the DAM system in production. After one week, they receive alerts about a user making 250 queries per minute to the `customers` table.

**Questions:**

a) What detection mechanism identifies this behavior?

b) What are the possible explanations (benign and malicious)?

c) What actions should the system take?

d) How can the incident be investigated?

**Answer:**

a) **Detection Mechanism**:
- **Frequency Analysis**: >100 queries/minute triggers alert
- **Heuristic Detection**: Accessing `customers` table (sensitive)
- Combined detection provides confidence

b) **Possible Explanations**:

**Benign**:
- Legitimate bulk data processing
- Report generation
- Scheduled job performing analysis
- Application bug generating too many queries

**Malicious**:
- Data exfiltration (stealing customer data)
- Brute force attack on customer IDs
- Scraping customer information
- Compromised account

c) **System Actions**:
1. **WARN**: Notification sent to security team
2. **LOG_INCIDENT**: Incident recorded in vault
3. **BLOCK_QUERY**: If score exceeds threshold, queries are blocked
4. **TERMINATE_CONNECTION**: If repeated, connection is terminated
5. **CIRCUIT_BREAKER**: If other users affected, circuit breaker triggers

d) **Investigation Steps**:
1. **Audit Logs**: Review who, when, what data was accessed
2. **Normalized Queries**: Look for patterns in the queries
3. **Incident Vault**: Check for similar incidents
4. **User Context**: Identify the user, IP address, and source
5. **Business Context**: Determine if this is legitimate activity
6. **Recommendations**: Generate prevention measures
7. **Reporting**: Create incident report for documentation

---

# ANSWER KEY: COMPREHENSIVE FINAL EXAM

## Part A: Multiple Choice

| Q | Answer | Q | Answer | Q | Answer |
|---|--------|---|--------|---|--------|
| 1 | B | 11 | B | 21 | B |
| 2 | C | 12 | B | 22 | A |
| 3 | B | 13 | B | 23 | B |
| 4 | B | 14 | B | 24 | C |
| 5 | B | 15 | C | 25 | B |
| 6 | B | 16 | D | 26 | B |
| 7 | B | 17 | C | 27 | B |
| 8 | B | 18 | B | 28 | D |
| 9 | C | 19 | D | 29 | B |
| 10 | B | 20 | B | 30 | B |

## Part B: True/False

| Q | Answer | Q | Answer |
|---|--------|---|--------|
| 1 | FALSE | 6 | TRUE |
| 2 | TRUE | 7 | FALSE |
| 3 | TRUE | 8 | TRUE |
| 4 | FALSE | 9 | FALSE |
| 5 | TRUE | 10 | TRUE |

## Part C: Fill-in-the-Blank

| Q | Answer |
|---|--------|
| 1 | Database Activity Management |
| 2 | immutability |
| 3 | defense-in-depth |
| 4 | WeakSet |
| 5 | set_trace_callback |
| 6 | `SELECT * FROM users WHERE id = ?` |
| 7 | sqli_tautology |
| 8 | ddl_drop_table |
| 9 | circuit breaker |
| 10 | CompleteDAMSystem |

## Scoring Guide

| Score | Rating |
|-------|--------|
| 90-100% | Excellent |
| 75-89% | Good |
| 60-74% | Satisfactory |
| Below 60% | Needs Improvement |

---

This comprehensive quiz and test bank provides complete assessment coverage for the entire DAM tutorial series. Use it to evaluate understanding, identify areas for review, and ensure mastery of all concepts before deployment.
