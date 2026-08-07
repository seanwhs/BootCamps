# DAM Tutorial Series: Complete Student Notes

Welcome to the DAM Tutorial Student Notes! This comprehensive document serves as your **reference guide** for the entire series. Unlike the workbook which contains exercises, these notes are designed for **review, reference, and study**. Use them to:

- Review key concepts after each session
- Prepare for discussions or exams
- Quickly look up definitions and examples
- Refresh your memory before building your own DAM system

---

## HOW TO USE THESE NOTES

### Note Structure

Each section contains:

1. **Key Concepts** - Core ideas you must understand
2. **Important Definitions** - Terminology with explanations
3. **Code Snippets** - Critical code patterns
4. **Diagrams** - Visual representations (described)
5. **Summary Points** - Quick review bullets
6. **Key Takeaways** - What you should remember

### Note Symbols

| Symbol | Meaning |
|--------|---------|
| ⭐ | Critical concept |
| 📌 | Important definition |
| 💻 | Key code pattern |
| 🔍 | Deep dive topic |
| ⚠️ | Common mistake/pitfall |
| 🎯 | Learning objective |
| 📝 | Remember this |

---

# SECTION 0: INTRODUCTION NOTES

## What is DAM?

**Database Activity Management (DAM)** is the practice of monitoring, detecting, and responding to activities happening in your database.

### Key Concepts

⭐ **DAM fills a critical security gap** - Traditional security protects the perimeter; DAM protects what's inside.

⭐ **The Five Pillars of DAM**:
1. **Visibility** - See everything happening
2. **Normalization** - Find patterns in the noise
3. **Detection** - Identify threats in real-time
4. **Prevention** - Stop threats before they execute
5. **Response** - Take automated action

### Why DAM Matters

📌 **The Problem**: Traditional security (firewalls, IAM) stops at the database door.

📌 **The Solution**: DAM watches what happens inside the database.

| Security Layer | What It Protects | What It Misses |
|----------------|------------------|----------------|
| Firewall | Network perimeter | Internal threats |
| Authentication | Who can access | What they do |
| Authorization (IAM) | What resources | When/how/why |
| WAF | Web application | Direct database access |
| **DAM** | **Database operations** | **(Everything else - it's specialized)** |

### The DAM Pipeline

```
Query → Interception → Normalization → Detection → Response → Audit
  │          │              │             │           │          │
  │          ▼              ▼             ▼           ▼          ▼
  │     Capture      Strip      Pattern    Block/    Incident
  │     All          Literals   Match      Allow     Vault
  │     Queries                 Heuristics  Notify    Audit
  │                              Frequency            Table
```

### The Five Parts

| Part | Focus | Key Output |
|------|-------|-----------|
| **Part 1** | Audit Foundation | `AuditedPool`, `AuditedSQLite` |
| **Part 2** | Interception | `DriverInterceptor`, `NativeInterceptor` |
| **Part 3** | Normalization | `QueryNormalizer` |
| **Part 4** | Detection | `ThreatDetector` |
| **Part 5** | Response | `IncidentResponder` |

### Key Takeaways

📝 DAM is essential because:
- SQL injection is the #1 web attack
- Insider threats represent 34% of breaches
- Average breach detection time is 277 days
- Traditional security doesn't watch the database

📝 Our DAM system is:
- Built with open source (Neon, Node.js, Python, SQLite)
- Production-ready with full error handling
- Extensible with custom rules and integrations

---

# SECTION 1: PART 1 NOTES

## Audit Trail Foundation

### Key Concepts

⭐ **An audit trail** is a complete, chronological record of database activities.

⭐ **The "Before-During-After" Pattern**:
1. **Before**: Capture context (who, when, where)
2. **During**: Execute the query
3. **After**: Log the result (success/failure, duration)

### Critical Properties of Audit Trails

📌 **Immutability** - Cannot be modified or deleted (prevents tampering)
📌 **Completeness** - Every query, success AND failure (no blind spots)
📌 **Verifiability** - Structured, queryable data (easy to investigate)
📌 **Performance** - Minimal impact on database (doesn't slow applications)
📌 **Separation** - Stored separately from data (survives database breach)

### JavaScript: AuditedPool

**Key Methods:**

```javascript
// Constructor - wraps PostgreSQL pool
new AuditedPool(connectionString, options)

// Execute query with audit logging
async query(text, params = [], userContext = { id, ip })

// Log audit entry (uses direct connection to avoid recursion)
async logAudit(auditEntry)

// Close the pool
async close()
```

**Audit Table Schema:**
```sql
CREATE TABLE dam_audit_logs (
  id BIGSERIAL PRIMARY KEY,
  query_text TEXT NOT NULL,
  query_params JSONB,
  duration_ms NUMERIC(10, 3),
  user_id TEXT,
  user_ip TEXT,
  status TEXT NOT NULL,      -- 'SUCCESS' or 'ERROR'
  error_message TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

**Why use a direct connection for logging?**
⚠️ To avoid recursion - logging the audit write would create infinite loops.

### Python: AuditedSQLite

**Key Methods:**

```python
# Constructor
AuditedSQLite(db_path)

# Transaction context manager
@contextmanager
def transaction(query, user="system"):
    # Before: Start timer
    # During: Yield cursor for user queries
    # After: Log result (success or failure)

# Convenience methods
def execute(query, params, user):  # Execute and commit
def query(query, params, user):    # Execute and return results as dicts
def query_one(query, params, user): # Execute and return first result
```

**Why use a context manager?**
⭐ Ensures proper commit/rollback handling and always logs the result.

### Verification Commands

**JavaScript:**
```bash
node tests/test-audited-pool.js
```

**Python:**
```bash
python test_audited_sqlite.py
```

### Key Takeaways

📝 Every query is logged with:
- Who (user_id)
- What (query_text)
- When (timestamp)
- Where (user_ip)
- How (duration_ms)
- Outcome (status, error_message)

📝 Both implementations achieve the same goal:
- JavaScript: Connection pool pattern
- Python: Context manager pattern

📝 Audit tables should be indexed for performance:
- timestamp (for time-based queries)
- user_id (for user-based queries)
- status (for filtering errors)

---

# SECTION 2: PART 2 NOTES

## Interception & Native Hooks

### Key Concepts

⭐ **Why interception is necessary**: Application-layer auditing misses queries that bypass the application.

⭐ **Three Interception Layers**:
1. **Application Layer** (Part 1) - Queries through audited wrappers
2. **Driver Layer** (Part 2 - JS) - Queries at the pg library level
3. **Native Layer** (Part 2 - Python) - Queries at the database engine level

### The Interception Analogy

| Layer | Analogy | What It Catches |
|-------|---------|-----------------|
| Application | Security guards at main entrance | Proper entrances |
| Driver | Security cameras on all doors | All entrances (including side doors) |
| Native | Motion sensors everywhere | Any movement anywhere |

### JavaScript: DriverInterceptor

**Key Methods:**

```javascript
// Intercept pg Pool or Client
new DriverInterceptor(db, options)

// Intercept pool-level queries
interceptPool()  // Wraps pool.query()

// Intercept client-level queries
interceptClient(client)  // Wraps client.query()

// Uninstall and restore original
uninstall()
```

**What gets intercepted:**
- All queries through the pool
- All queries through individual clients
- All queries through raw connections
- All queries through the underlying driver

### Python: NativeInterceptor

**Key Methods:**

```javascript
// Intercept SQLite connection
new NativeInterceptor(connection)

// Set callback for intercepted queries
set_callback(callback)

// Uninstall interceptor
uninstall()
```

**How it works:**
⭐ SQLite's `set_trace_callback` registers a C-level callback that fires for every statement.

### Combined Approach: EnhancedAuditedPool

```javascript
export class EnhancedAuditedPool extends AuditedPool {
  installDriverInterceptor() {
    // Add driver-layer interception
    this.driverInterceptor = new DriverInterceptor(
      underlyingPool,
      { onQuery: (query, params, source) => {
          // Log via audit system
          this.logAudit({ ... });
        }
      }
    );
  }
}
```

### Key Takeaways

📝 **Defense in depth** means multiple interception layers:
- Application layer catches normal queries
- Driver layer catches raw connections
- Native layer catches everything else

📝 **JavaScript** intercepts at the driver level:
- Wraps `query()` methods
- Works with Pool and Client
- Catches queries before wire protocol

📝 **Python** intercepts at the native level:
- Uses `sqlite3_trace`
- C-level callback
- Catches ALL statements

📝 **Verification**: Test raw connections to ensure they're intercepted.

---

# SECTION 3: PART 3 NOTES

## Query Normalization

### Key Concepts

⭐ **Query Normalization** transforms verbose SQL into compact patterns by replacing literal values with placeholders.

⭐ **Why Normalization Matters**:
1. **Compact Storage** - Store patterns once, not every variation
2. **Pattern Matching** - Group identical query structures
3. **Privacy Protection** - Data values are stripped
4. **Attack Detection** - Recognize malicious patterns

### The Normalization Pipeline

```
Raw SQL
  │
  ▼
1. Remove Comments
  │
  ▼
2. String Literal Replacement  'hello' → '?'
  │
  ▼
3. Numeric Literal Replacement  123 → ?
  │
  ▼
4. UUID Replacement  uuid → '?'
  │
  ▼
5. JSON Replacement  {...} → '?'
  │
  ▼
6. IN Clause Normalization  (1,2,3) → (?, ?, ?)
  │
  ▼
7. Whitespace Collapse
  │
  ▼
8. Case Normalization (Optional)
  │
  ▼
Normalized Pattern
```

### JavaScript: QueryNormalizer

**Key Methods:**

```javascript
// Normalize a SQL query
normalize(sql)

// Replace string literals with '?'
replaceStringLiterals(sql)

// Replace numeric literals with ?
replaceNumericLiterals(sql)

// Normalize IN clauses
normalizeInClauses(sql)

// Collapse whitespace
collapseWhitespace(sql)

// Generate query fingerprint (SHA-256 hash)
fingerprint(normalized)

// Count placeholders
countPlaceholders(normalized)

// Check structural identity
areStructurallyIdentical(sql1, sql2)

// Analyze query structure
analyzeStructure(sql)
```

**String Literal Pattern:**
```regex
'[^']*(?:''[^']*)*'
```
📌 Handles normal strings AND escaped quotes (it''s)

**Numeric Literal Pattern:**
```regex
\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b
```
📌 Handles integers, decimals, and scientific notation

### Python: QueryNormalizer

**Key Methods:**

```python
# Normalize a SQL query
normalize(sql)

# Replace string literals with '?'
_replace_string_literals(sql)

# Replace numeric literals with ?
_replace_numeric_literals(sql)

# Normalize IN clauses
_normalize_in_clauses(sql)

# Collapse whitespace
_collapse_whitespace(sql)

# Generate fingerprint (SHA-256 hash)
fingerprint(normalized)

# Count placeholders
count_placeholders(normalized)

# Check structural identity
are_structurally_identical(sql1, sql2)

# Analyze query structure
analyze_structure(sql)
```

### Enhanced Audit with Normalization

**Extended Audit Table:**
```sql
ALTER TABLE dam_audit_logs 
ADD COLUMN normalized_query TEXT,
ADD COLUMN query_fingerprint VARCHAR(32),
ADD COLUMN placeholder_count INTEGER;
```

**Pattern Analysis:**
```sql
SELECT 
  query_fingerprint,
  normalized_query,
  COUNT(*) as occurrence_count,
  AVG(duration_ms) as avg_duration_ms
FROM dam_audit_logs
WHERE normalized_query IS NOT NULL
GROUP BY query_fingerprint, normalized_query
ORDER BY occurrence_count DESC;
```

### Key Takeaways

📝 **Normalization transforms**:
- `SELECT * FROM users WHERE email = 'alice@example.com'`
- → `SELECT * FROM users WHERE email = '?'`

📝 **Fingerprints** identify identical patterns:
- Same structure → Same fingerprint
- Fast pattern matching and grouping

📝 **Privacy** is protected because:
- Actual data values are removed
- PII/PHI is not stored in logs
- Only structural patterns remain

📝 **Storage is efficient** because:
- Patterns are stored once
- Variations are grouped
- Compression is more effective

---

# SECTION 4: PART 4 NOTES

## Threat Detection

### Key Concepts

⭐ **Threat Detection** analyzes normalized queries to identify malicious patterns in real-time.

⭐ **Two Detection Approaches**:

| Approach | How It Works | Pros | Cons |
|----------|--------------|------|------|
| **Pattern Matching** | Matches known attack signatures | Fast, reliable, low false positives | Can't detect new attacks |
| **Heuristics** | Looks for suspicious behavior | Can detect new attacks, flexible | May have false positives |

### Threat Types

| Threat Type | Examples | Detection Method |
|-------------|----------|------------------|
| **SQL Injection** | OR 1=1, UNION SELECT, -- | Pattern matching |
| **DDL Operations** | DROP TABLE, TRUNCATE | Pattern matching |
| **Privilege Escalation** | GRANT, REVOKE | Pattern matching |
| **Data Exfiltration** | SELECT *, sensitive tables | Heuristics |
| **Brute Force** | High query frequency | Frequency analysis |
| **Time-Based Injection** | SLEEP(), DELAY | Heuristics |

### JavaScript: ThreatDetector

**Constants:**
```javascript
ThreatLevel: LOW, MEDIUM, HIGH, CRITICAL
ThreatCategory: SQL_INJECTION, DDL_OPERATION, PRIVILEGE_ESCALATION,
                DATA_EXFILTRATION, BRUTE_FORCE, SUSPICIOUS_PATTERN
RuleType: BLOCK, WARN, LOG, SCORE
```

**Key Methods:**

```javascript
// Analyze query for threats
analyze(query, context)

// Add a custom rule
addRule(rule)

// Check whitelist
isWhitelisted(query)

// Determine action based on detection
determineAction(detection)

// Run heuristic analysis
runHeuristics(query, normalized, context)

// Analyze query frequency
analyzeFrequency(query, context)
```

**Default Rules (Partial List):**

| Rule ID | Name | Severity | Pattern |
|---------|------|----------|---------|
| `sqli_tautology` | Tautology SQL Injection | HIGH | `OR 1=1` |
| `sqli_union` | Union SQL Injection | CRITICAL | `UNION SELECT` |
| `sqli_stacked` | Stacked Query Injection | CRITICAL | `; DROP TABLE` |
| `sqli_comment` | Comment Injection | HIGH | `--` |
| `ddl_drop_table` | DROP TABLE Attempt | CRITICAL | `DROP TABLE` |
| `ddl_truncate` | TRUNCATE Attempt | CRITICAL | `TRUNCATE` |
| `priv_grant` | GRANT Privilege Attempt | CRITICAL | `GRANT` |

### Threat Scoring

**Severity Scores:**
```
LOW      = 1
MEDIUM   = 5
HIGH     = 10
CRITICAL = 25
```

**Threat Level Calculation:**
```
Score ≥ 25  → CRITICAL
Score ≥ 10  → HIGH
Score ≥ 5   → MEDIUM
Score ≥ 1   → LOW
Score = 0   → LOW
```

**Action Determination:**
```
if (whitelisted) → ALLOW
if (no threats)  → ALLOW
if (any BLOCK rule matched) → BLOCK
if (score ≥ 15) → BLOCK
if (any WARN rule matched) → WARN
else → LOG
```

### Python: ThreatDetector

**Enums:**
```python
ThreatLevel: LOW, MEDIUM, HIGH, CRITICAL
ThreatCategory: SQL_INJECTION, DDL_OPERATION, PRIVILEGE_ESCALATION,
                DATA_EXFILTRATION, BRUTE_FORCE, SUSPICIOUS_PATTERN
RuleType: BLOCK, WARN, LOG, SCORE
```

**Classes:**
```python
# Threat rule definition
ThreatRule(rule_id, name, category, severity, rule_type, pattern, description)

# Threat detector
ThreatDetector(options)
```

### Secure Pool Integration

**JavaScript:**
```javascript
class SecureAuditedPool extends NormalizedAuditedPool {
  async query(text, params, userContext) {
    const detection = this.detector.analyze(text, userContext);
    if (detector.determineAction(detection) === 'BLOCK') {
      throw new Error(`[SECURITY] Query blocked: ${text}`);
    }
    return super.query(text, params, userContext);
  }
}
```

**Python:**
```python
class SecureAuditedSQLite(NormalizedAuditedSQLite):
    def execute(self, sql, params, user_context):
        detection = self.detector.analyze(sql, user_context)
        if self.detector.determine_action(detection) == 'BLOCK':
            raise sqlite3.Error(f"[SECURITY] Query blocked: {sql}")
        return super().execute(sql, params, user_context)
```

### Key Takeaways

📝 **Pattern matching** detects known attacks quickly:
- Uses regex patterns
- Fast and reliable
- Low false positives

📝 **Heuristics** detect suspicious behavior:
- Sensitive table access
- Time-based injection attempts
- Large IN clauses (brute force)

📝 **Frequency analysis** detects brute force:
- >100 queries/minute = suspicious
- Tracking per user + IP
- Triggers high severity alert

📝 **Threat scoring** prioritizes responses:
- Multiple findings combine
- Higher score = more severe
- Determines action (BLOCK, WARN, LOG)

📝 **Rules are extensible** - Add your own:
- Custom patterns
- Custom severity
- Custom actions

---

# SECTION 5: PART 5 NOTES

## Incident Response

### Key Concepts

⭐ **Incident Response** turns detection into automated action.

⭐ **The Incident Response Lifecycle**:
1. **Detection** - Threat is identified
2. **Containment** - Stop the threat from spreading
3. **Eradication** - Remove the threat
4. **Recovery** - Restore normal operations
5. **Investigation** - Learn from the incident

### Response Actions

| Action | Description | When Used |
|--------|-------------|-----------|
| **BLOCK_QUERY** | Prevent query execution | All threats |
| **TERMINATE_CONNECTION** | Close database connection | HIGH/CRITICAL |
| **REVOKE_CREDENTIALS** | Revoke user credentials | CRITICAL |
| **NOTIFY_SECURITY** | Alert security team | MEDIUM+ |
| **CIRCUIT_BREAKER** | Trip circuit breaker | HIGH+ repeated |
| **ISOLATE_USER** | Isolate user from system | CRITICAL |
| **ROLLBACK_TRANSACTION** | Rollback current transaction | CRITICAL |
| **LOG_INCIDENT** | Record in incident vault | Always |

### Circuit Breaker Pattern

```
CLOSED (Normal)
  │ Queries flow normally
  ▼
Multiple threats detected
  │
  ▼
OPEN (Triggered)
  │ All queries blocked
  │ "Fail fast"
  │ Expires after 5 minutes
  │
  ▼
HALF-OPEN (Testing)
  │ One query allowed through
  │ If successful → CLOSED
  │ If failed → OPEN
```

**Why Circuit Breaker Matters:**
- Prevents cascading failures
- Protects database from overload
- Gives security team time to respond
- Automatically recovers after cooldown

### JavaScript: IncidentResponder

**Key Methods:**

```javascript
// Handle an incident
async handleIncident(incident)

// Generate response plan based on severity
generateResponsePlan(incident)

// Execute response plan
async executeResponsePlan(plan, incident)

// Record incident to immutable vault
async recordIncident(incidentId, timestamp, incident, results)

// Check circuit breaker status
isCircuitBreakerActive()

// Query incident vault
async queryVault(filters)
```

**Incident Vault Format (JSONL):**
```json
{"incidentId":"INC-A1B2C3","timestamp":"2024-01-15T10:00:00.000Z","severity":"HIGH",...}
{"incidentId":"INC-D4E5F6","timestamp":"2024-01-15T10:00:01.000Z","severity":"CRITICAL",...}
```

### Python: IncidentResponder

**Key Methods:**

```python
# Handle an incident
handle_incident(incident)

# Generate response plan
_generate_response_plan(incident)

# Execute response plan
_execute_response_plan(plan, incident)

# Record incident to vault
_record_incident(incident, response_results)

# Check circuit breaker
is_circuit_breaker_active()

# Query vault
query_vault(filters, limit)
```

### Complete System Integration

**JavaScript:**
```javascript
class CompleteDAMSystem {
  async initialize() {
    this.auditPool = new SecureAuditedPool(connectionString);
    this.incidentResponder = new IncidentResponder(options);
  }
  
  async query(query, params, userContext) {
    // Check circuit breaker
    if (this.incidentResponder.isCircuitBreakerActive()) {
      throw new Error('Circuit breaker is active');
    }
    
    // Execute through secure pool
    try {
      return await this.auditPool.query(query, params, userContext);
    } catch (error) {
      // Trigger incident response on security errors
      if (error.message.includes('[SECURITY]')) {
        await this.incidentResponder.handleIncident({
          query, params, userContext,
          threatLevel: IncidentSeverity.HIGH,
          findings: error.findings || []
        });
      }
      throw error;
    }
  }
}
```

**Python:**
```python
class CompleteDAMSystem:
    def __enter__(self):
        self.initialize()
        return self
    
    def execute(self, sql, params, user_context):
        # Check circuit breaker
        if self.incident_responder.is_circuit_breaker_active():
            raise Exception('Circuit breaker is active')
        
        try:
            return self.secure_db.execute(sql, params, user_context)
        except sqlite3.Error as e:
            if 'SECURITY' in str(e):
                self.incident_responder.handle_incident({
                    'query': sql,
                    'params': params,
                    'threat_level': IncidentSeverity.HIGH.value,
                    'user_context': user_context,
                    'findings': getattr(e, 'findings', [])
                })
            raise
```

### Key Takeaways

📝 **The incident response lifecycle**:
1. Detection identifies the threat
2. Containment stops it (block, terminate)
3. Eradication removes it (revoke, isolate)
4. Recovery restores normal operations
5. Investigation provides learning

📝 **The circuit breaker**:
- Prevents cascading failures
- Blocks ALL queries after multiple threats
- Automatically recovers after 5 minutes
- "Fail fast" approach

📝 **The incident vault**:
- Append-only (immutable)
- Cannot be modified or deleted
- Provides tamper-proof evidence
- Supports investigations and compliance

📝 **Complete system integration**:
- All five parts work together
- Single entry point
- Automatic threat detection and response
- Production-ready and extensible

---

# COMPLETE SYSTEM SUMMARY

## The Five Parts in One Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         APPLICATION LAYER                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐ │
│  │                      Complete DAM System                            │ │
│  └──────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                           SECURITY COMPONENTS                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │  Audit Log  │  │Interception │  │Normalization│  │  Threat         │ │
│  │  (Part 1)   │  │  (Part 2)   │  │  (Part 3)   │  │  Detection      │ │
│  │             │  │             │  │             │  │  (Part 4)       │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                        INCIDENT RESPONSE                                  │
│                         (Part 5)                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────────┐   │
│  │  Containment│  │ Eradication │  │        Recovery                │   │
│  │  (Block)    │  │ (Revoke)    │  │    (Cleanup)                   │   │
│  └─────────────┘  └─────────────┘  └─────────────────────────────────┘   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────────┐   │
│  │Investigation│  │ Prevention  │  │      Circuit Breaker            │   │
│  │  (Vault)    │  │  (Update)   │  │   (Fail Fast)                   │   │
│  └─────────────┘  └─────────────┘  └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                         DATABASE LAYER                                    │
│  ┌─────────────────┐              ┌─────────────────────────────────────┐ │
│  │    PostgreSQL   │              │              SQLite                 │ │
│  │    (Neon)       │              │                                     │ │
│  └─────────────────┘              └─────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Key Code Patterns

### JavaScript Core Classes

| Class | Purpose | Key Method |
|-------|---------|------------|
| `AuditedPool` | Audit logging | `query()` |
| `DriverInterceptor` | Driver interception | `install()` |
| `QueryNormalizer` | Query normalization | `normalize()` |
| `ThreatDetector` | Threat detection | `analyze()` |
| `IncidentResponder` | Incident response | `handleIncident()` |
| `CompleteDAMSystem` | Full integration | `query()` |

### Python Core Classes

| Class | Purpose | Key Method |
|-------|---------|------------|
| `AuditedSQLite` | Audit logging | `transaction()` |
| `NativeInterceptor` | Native interception | `set_callback()` |
| `QueryNormalizer` | Query normalization | `normalize()` |
| `ThreatDetector` | Threat detection | `analyze()` |
| `IncidentResponder` | Incident response | `handle_incident()` |
| `CompleteDAMSystem` | Full integration | `execute()` |

## Core Database Tables

### PostgreSQL Audit Table
```sql
dam_audit_logs (
  id, query_text, normalized_query, query_fingerprint,
  placeholder_count, query_params, duration_ms,
  user_id, user_ip, status, error_message, timestamp
)
```

### SQLite Audit Table
```sql
audit_logs (
  id, query_text, normalized_query, query_fingerprint,
  placeholder_count, query_params, duration_ms,
  user_id, user_ip, status, error_message, timestamp
)
```

### Incident Vault (JSONL)
```
incident_vault.jsonl (append-only)
```

---

## Quick Reference Cards

### Part 1: Audit Logging
```
Purpose: Log every query with context
Key Pattern: Before-During-After
JavaScript: AuditedPool
Python: AuditedSQLite
Storage: dam_audit_logs / audit_logs
```

### Part 2: Interception
```
Purpose: Catch queries that bypass application
JavaScript: DriverInterceptor (driver layer)
Python: NativeInterceptor (native layer)
Key Principle: Defense in depth
```

### Part 3: Normalization
```
Purpose: Strip literals to reveal patterns
Key Pattern: 'hello' → '?', 123 → ?
Output: Normalized query + fingerprint
Benefits: Storage, analysis, privacy
```

### Part 4: Detection
```
Purpose: Identify threats in real-time
Methods: Pattern matching + Heuristics + Frequency
Output: Threat score + level
Actions: BLOCK, WARN, LOG
```

### Part 5: Response
```
Purpose: Automate threat response
Key Pattern: Circuit breaker
Storage: Incident vault (append-only)
Actions: Block, Terminate, Notify, Isolate
```

---

## Common Commands

### JavaScript
```bash
# Install dependencies
npm install pg dotenv

# Run tests
node tests/test-*.js

# Start application
node src/index.js
```

### Python
```bash
# Run tests
python test_*.py

# Start application
python main.py

# Check SQLite database
sqlite3 database.db ".tables"
```

---

These notes are designed to be your **companion reference** throughout the DAM tutorial series. Keep them handy for:
- Quick review before each session
- Looking up definitions and examples
- Preparing for hands-on exercises
- Building your own DAM system

**Good luck with your DAM journey!** 🎯
