# Appendix A: Complete API Reference & Deep Dives

Welcome to the first appendix of our Database Activity Management series! This comprehensive reference document serves as your go-to resource for understanding every component, class, method, and pattern used throughout the series.

Unlike the main tutorial, which follows a linear progression, this appendix is structured as a reference manual. Use it to look up specific APIs, understand configuration options, and dive deeper into complex topics.

---

## A.1: Complete Class Hierarchy

### JavaScript Class Structure

```
CompleteDAMSystem (Part 5)
├── SecureAuditedPool (Part 4)
│   └── NormalizedAuditedPool (Part 3)
│       └── AuditedPool (Part 1)
│           └── Pool (pg)
├── ThreatDetector (Part 4)
│   └── QueryNormalizer (Part 3)
└── IncidentResponder (Part 5)
    └── (Incident Vault - JSONL)
```

### Python Class Structure

```
CompleteDAMSystem (Part 5)
├── SecureAuditedSQLite (Part 4)
│   └── NormalizedAuditedSQLite (Part 3)
│       └── AuditedSQLite (Part 1)
│           └── sqlite3.Connection
├── ThreatDetector (Part 4)
│   └── QueryNormalizer (Part 3)
└── IncidentResponder (Part 5)
    └── (Incident Vault - JSONL)
```

---

## A.2: JavaScript API Reference

### A.2.1: AuditedPool (Part 1)

**File:** `src/audited-pool.js`

#### Constructor

```javascript
new AuditedPool(connectionString, options)
```

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `connectionString` | `string` | PostgreSQL connection string (Neon format) |
| `options` | `object` | Optional pool configuration |
| `options.connectionTimeoutMillis` | `number` | Connection timeout in ms (default: 5000) |
| `options.max` | `number` | Maximum pool size (default: 20) |

**Example:**
```javascript
const pool = new AuditedPool(process.env.DATABASE_URL, {
    max: 10,
    connectionTimeoutMillis: 3000
});
```

#### Methods

##### `query(text, params, userContext)`

Execute a query with full audit logging.

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `string \| object` | SQL query or query configuration object |
| `params` | `array` | Query parameters (default: `[]`) |
| `userContext` | `object` | User context object |
| `userContext.id` | `string` | User identifier (default: `'system'`) |
| `userContext.ip` | `string` | User IP address (default: `'unknown'`) |

**Returns:** `Promise<object>` - Query result

**Example:**
```javascript
const result = await pool.query(
    'SELECT * FROM users WHERE id = $1',
    [123],
    { id: 'user-456', ip: '192.168.1.100' }
);
```

##### `initAuditTable()`

Initialize the audit table in the database. Called automatically on first query.

**Returns:** `Promise<void>`

##### `logAudit(auditEntry)`

Write an audit entry to the database.

| Parameter | Type | Description |
|-----------|------|-------------|
| `auditEntry` | `object` | Audit data |
| `auditEntry.query_text` | `string` | The SQL query |
| `auditEntry.query_params` | `array` | Query parameters |
| `auditEntry.duration_ms` | `number` | Execution duration in ms |
| `auditEntry.user_id` | `string` | User identifier |
| `auditEntry.user_ip` | `string` | User IP address |
| `auditEntry.status` | `string` | 'SUCCESS' or 'ERROR' |
| `auditEntry.error_message` | `string \| null` | Error details if any |

**Returns:** `Promise<void>`

##### `getUnderlyingPool()`

Get the underlying pg Pool for advanced operations.

**Returns:** `Pool` - The PostgreSQL connection pool

##### `close()`

Close all connections in the pool.

**Returns:** `Promise<void>`

---

### A.2.2: DriverInterceptor (Part 2)

**File:** `src/driver-interceptor.js`

#### Constructor

```javascript
new DriverInterceptor(db, options)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `db` | `Pool \| Client` | pg connection pool or client |
| `options` | `object` | Configuration |
| `options.onQuery` | `function` | Callback for intercepted queries |
| `options.onError` | `function` | Callback for interception errors |
| `options.logAllQueries` | `boolean` | Log all queries to console (default: true) |

**Example:**
```javascript
const interceptor = new DriverInterceptor(pool, {
    onQuery: (query, params, source) => {
        console.log(`Query from ${source}: ${query}`);
    },
    onError: (error, query, params) => {
        console.error('Interception error:', error);
    }
});
```

#### Methods

##### `install()`

Install the driver-level interceptor. Called automatically in constructor.

**Returns:** `void`

##### `uninstall()`

Uninstall the interceptor and restore the original query method.

**Returns:** `void`

##### `getOriginalQuery()`

Get the original query method (bypasses interception).

**Returns:** `Function` - Original query method

---

### A.2.3: QueryNormalizer (Part 3)

**File:** `src/normalizer.js`

#### Constructor

```javascript
new QueryNormalizer(options)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `object` | Configuration |
| `options.caseInsensitive` | `boolean` | Normalize to lowercase (default: false) |
| `options.preserveComments` | `boolean` | Keep SQL comments (default: false) |
| `options.normalizeInClauses` | `boolean` | Normalize IN list values (default: true) |

**Example:**
```javascript
const normalizer = new QueryNormalizer({
    caseInsensitive: true,
    normalizeInClauses: true
});
```

#### Methods

##### `normalize(sql)`

Normalize a SQL query.

| Parameter | Type | Description |
|-----------|------|-------------|
| `sql` | `string` | Raw SQL query |

**Returns:** `string` - Normalized query

**Example:**
```javascript
const normalized = normalizer.normalize(
    "SELECT * FROM users WHERE email = 'alice@example.com'"
);
// Returns: "SELECT * FROM users WHERE email = '?'"
```

##### `removeComments(sql)`

Remove SQL comments.

**Returns:** `string` - SQL without comments

##### `replaceStringLiterals(sql)`

Replace string literals with `'?'`.

**Returns:** `string` - SQL with literals replaced

##### `replaceNumericLiterals(sql)`

Replace numeric literals with `?`.

**Returns:** `string` - SQL with numerics replaced

##### `replaceUuidLiterals(sql)`

Replace UUID literals with `'?'`.

**Returns:** `string` - SQL with UUIDs replaced

##### `replaceJsonLiterals(sql)`

Replace JSON literals with `'?'`.

**Returns:** `string` - SQL with JSON replaced

##### `normalizeInClauses(sql)`

Normalize IN clauses with multiple values.

**Returns:** `string` - SQL with normalized IN clauses

##### `collapseWhitespace(sql)`

Collapse multiple spaces into a single space.

**Returns:** `string` - SQL with normalized whitespace

##### `fingerprint(normalized)`

Generate a hash/fingerprint of the normalized query.

| Parameter | Type | Description |
|-----------|------|-------------|
| `normalized` | `string` | Normalized query |

**Returns:** `string` - SHA-256 fingerprint (16 chars)

##### `areStructurallyIdentical(sql1, sql2)`

Check if two queries are structurally identical.

| Parameter | Type | Description |
|-----------|------|-------------|
| `sql1` | `string` | First SQL query |
| `sql2` | `string` | Second SQL query |

**Returns:** `boolean` - True if queries have same structure

##### `countPlaceholders(normalized)`

Count the number of literal placeholders.

| Parameter | Type | Description |
|-----------|------|-------------|
| `normalized` | `string` | Normalized query |

**Returns:** `number` - Number of placeholders

##### `analyzeStructure(sql)`

Get the query structure tree.

| Parameter | Type | Description |
|-----------|------|-------------|
| `sql` | `string` | SQL query |

**Returns:** `object` - Structure information
```javascript
{
    original: 'SELECT * FROM users WHERE id = 1',
    normalized: 'SELECT * FROM users WHERE id = ?',
    fingerprint: 'a1b2c3d4e5f67890',
    placeholders: 1,
    queryType: 'SELECT',
    length: 35
}
```

---

### A.2.4: ThreatDetector (Part 4)

**File:** `src/threat-detector.js`

#### Constants

##### `ThreatLevel`

```javascript
{
    LOW: 'LOW',
    MEDIUM: 'MEDIUM',
    HIGH: 'HIGH',
    CRITICAL: 'CRITICAL'
}
```

##### `ThreatCategory`

```javascript
{
    SQL_INJECTION: 'SQL_INJECTION',
    DDL_OPERATION: 'DDL_OPERATION',
    PRIVILEGE_ESCALATION: 'PRIVILEGE_ESCALATION',
    DATA_EXFILTRATION: 'DATA_EXFILTRATION',
    BRUTE_FORCE: 'BRUTE_FORCE',
    SUSPICIOUS_PATTERN: 'SUSPICIOUS_PATTERN'
}
```

##### `RuleType`

```javascript
{
    BLOCK: 'BLOCK',
    WARN: 'WARN',
    LOG: 'LOG',
    SCORE: 'SCORE'
}
```

#### Constructor

```javascript
new ThreatDetector(options)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `object` | Configuration |
| `options.enablePatternMatching` | `boolean` | Enable pattern matching (default: true) |
| `options.enableHeuristics` | `boolean` | Enable heuristic analysis (default: true) |
| `options.enableThreatScoring` | `boolean` | Enable threat scoring (default: true) |
| `options.logAllDetections` | `boolean` | Log all detections (default: true) |

#### Methods

##### `addRule(rule)`

Add a security rule.

| Parameter | Type | Description |
|-----------|------|-------------|
| `rule` | `object` | Rule configuration |
| `rule.id` | `string` | Unique rule identifier |
| `rule.name` | `string` | Human-readable name |
| `rule.category` | `string` | Threat category |
| `rule.severity` | `string` | Threat severity |
| `rule.type` | `string` | Rule type (BLOCK, WARN, LOG, SCORE) |
| `rule.pattern` | `RegExp` | Regex pattern to match |
| `rule.description` | `string` | Rule description |

**Example:**
```javascript
detector.addRule({
    id: 'custom_rule',
    name: 'Custom Detection',
    category: ThreatCategory.SQL_INJECTION,
    severity: ThreatLevel.HIGH,
    type: RuleType.BLOCK,
    pattern: /CUSTOM_PATTERN/i,
    description: 'Custom detection rule'
});
```

##### `analyze(query, context)`

Analyze a query for threats.

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | `string` | SQL query to analyze |
| `context` | `object` | User context |
| `context.userId` | `string` | User identifier |
| `context.ip` | `string` | User IP address |

**Returns:** `object` - Detection results
```javascript
{
    threatDetected: true,
    score: 25,
    level: 'CRITICAL',
    findings: [
        {
            rule: { id: 'sqli_union', name: 'Union SQL Injection', ... },
            matched: true,
            score: 25,
            normalized: 'SELECT * FROM users WHERE id = ? UNION SELECT * FROM admins'
        }
    ],
    normalized: 'SELECT * FROM users WHERE id = ? UNION SELECT * FROM admins',
    whitelisted: false
}
```

##### `isWhitelisted(query)`

Check if a query is whitelisted.

**Returns:** `boolean` - True if whitelisted

##### `determineAction(detection)`

Determine action based on detection results.

| Parameter | Type | Description |
|-----------|------|-------------|
| `detection` | `object` | Detection result from `analyze()` |

**Returns:** `string` - Action to take ('BLOCK', 'WARN', 'LOG', 'ALLOW')

##### `getSeverityScore(severity)`

Get numeric score for a severity level.

| Parameter | Type | Description |
|-----------|------|-------------|
| `severity` | `string` | Threat severity |

**Returns:** `number` - Numeric score (1, 5, 10, 25)

##### `getThreatLevel(score)`

Get threat level based on score.

| Parameter | Type | Description |
|-----------|------|-------------|
| `score` | `number` | Total threat score |

**Returns:** `string` - Threat level (LOW, MEDIUM, HIGH, CRITICAL)

---

### A.2.5: IncidentResponder (Part 5)

**File:** `src/incident-responder.js`

#### Constants

##### `IncidentSeverity`

```javascript
{
    LOW: 'LOW',
    MEDIUM: 'MEDIUM',
    HIGH: 'HIGH',
    CRITICAL: 'CRITICAL'
}
```

##### `ResponseAction`

```javascript
{
    BLOCK_QUERY: 'BLOCK_QUERY',
    TERMINATE_CONNECTION: 'TERMINATE_CONNECTION',
    REVOKE_CREDENTIALS: 'REVOKE_CREDENTIALS',
    NOTIFY_SECURITY: 'NOTIFY_SECURITY',
    CIRCUIT_BREAKER: 'CIRCUIT_BREAKER',
    ISOLATE_USER: 'ISOLATE_USER',
    ROLLBACK_TRANSACTION: 'ROLLBACK_TRANSACTION',
    LOG_INCIDENT: 'LOG_INCIDENT'
}
```

#### Constructor

```javascript
new IncidentResponder(options)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `object` | Configuration |
| `options.vaultPath` | `string` | Path to incident vault file (default: './incident_vault.jsonl') |
| `options.notifySecurity` | `boolean` | Enable security notifications (default: true) |
| `options.useCircuitBreaker` | `boolean` | Enable circuit breaker (default: true) |
| `options.terminateConnections` | `boolean` | Terminate connections on incidents (default: true) |
| `options.revokeCredentials` | `boolean` | Revoke credentials on critical incidents (default: false) |
| `options.maxIncidentsMemory` | `number` | Max incidents in memory (default: 100) |
| `options.cooldownPeriod` | `number` | Cooldown period in ms (default: 60000) |

#### Methods

##### `handleIncident(incident)`

Handle an incident.

| Parameter | Type | Description |
|-----------|------|-------------|
| `incident` | `object` | Incident details |
| `incident.query` | `string` | SQL query that triggered the incident |
| `incident.params` | `array` | Query parameters |
| `incident.threatLevel` | `string` | Threat severity level |
| `incident.userContext` | `object` | User context (id, ip, etc.) |
| `incident.findings` | `array` | Detection findings |
| `incident.detection` | `object` | Full detection result |
| `incident.dbConnection` | `object` | Database connection (for termination) |

**Returns:** `Promise<object>` - Response result

##### `generateResponsePlan(incident)`

Generate a response plan based on incident severity.

**Returns:** `array` - List of response actions

##### `executeResponsePlan(plan, incident)`

Execute the response plan.

**Returns:** `Promise<object>` - Response results

##### `isCircuitBreakerActive()`

Check if the circuit breaker is active.

**Returns:** `boolean` - True if circuit breaker is active

##### `queryVault(filters)`

Query the incident vault.

| Parameter | Type | Description |
|-----------|------|-------------|
| `filters` | `object` | Filter criteria |
| `filters.severity` | `string` | Filter by severity |
| `filters.userId` | `string` | Filter by user ID |
| `filters.startDate` | `Date` | Start date for range |
| `filters.endDate` | `Date` | End date for range |
| `filters.limit` | `number` | Maximum results (default: 100) |

**Returns:** `Promise<array>` - Incident records

##### `generateReport(incidentId)`

Generate an incident report.

| Parameter | Type | Description |
|-----------|------|-------------|
| `incidentId` | `string` | Incident ID |

**Returns:** `Promise<object>` - Incident report

##### `getStats()`

Get incident statistics.

**Returns:** `object` - Statistics

---

### A.2.6: CompleteDAMSystem (Part 5)

**File:** `src/complete-dam-system.js`

#### Constructor

```javascript
new CompleteDAMSystem(options)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `object` | Configuration |
| `options.connectionString` | `string` | PostgreSQL connection string |
| `options.threatDetectorOptions` | `object` | Threat detector options |
| `options.incidentResponderOptions` | `object` | Incident responder options |
| `options.securePoolOptions` | `object` | Secure pool options |
| `options.enableAudit` | `boolean` | Enable audit (default: true) |
| `options.enableThreatDetection` | `boolean` | Enable threat detection (default: true) |
| `options.enableIncidentResponse` | `boolean` | Enable incident response (default: true) |
| `options.enableConsoleLogging` | `boolean` | Enable console logging (default: true) |

#### Methods

##### `initialize()`

Initialize the DAM system.

**Returns:** `Promise<void>`

##### `query(query, params, userContext)`

Execute a query through the DAM system.

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | `string` | SQL query |
| `params` | `array` | Query parameters |
| `userContext` | `object` | User context |

**Returns:** `Promise<object>` - Query result

##### `getStatus()`

Get system status.

**Returns:** `object` - System status

##### `getAuditSummary()`

Get audit summary.

**Returns:** `Promise<object>` - Audit summary

##### `getThreatPatterns(level, limit)`

Get threat patterns.

| Parameter | Type | Description |
|-----------|------|-------------|
| `level` | `string` | Threat level filter |
| `limit` | `number` | Maximum results (default: 50) |

**Returns:** `Promise<array>` - Threat patterns

##### `getIncidentHistory(filters)`

Get incident history.

| Parameter | Type | Description |
|-----------|------|-------------|
| `filters` | `object` | Filter criteria |

**Returns:** `Promise<array>` - Incident history

##### `shutdown()`

Shutdown the DAM system.

**Returns:** `Promise<void>`

---

## A.3: Python API Reference

### A.3.1: AuditedSQLite (Part 1)

**File:** `audited_sqlite.py`

#### Constructor

```python
AuditedSQLite(db_path, create_audit_table=True)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `db_path` | `str` | Path to SQLite database |
| `create_audit_table` | `bool` | Create audit table on init (default: True) |

**Example:**
```python
db = AuditedSQLite('myapp.db')
```

#### Methods

##### `execute(query, params, user_context)`

Execute a query with audit logging.

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | `str` | SQL query |
| `params` | `tuple \| list \| dict` | Query parameters |
| `user_context` | `dict` | User context with 'id' and 'ip' keys |

**Returns:** `sqlite3.Cursor` - Query cursor

##### `query(query, params, user_context)`

Execute a query and return results as dictionaries.

**Returns:** `list[dict]` - Rows as dictionaries

##### `query_one(query, params, user_context)`

Execute a query and return the first row.

**Returns:** `dict \| None` - First row or None

##### `transaction(query_description, user_context)`

Context manager for transactional queries.

**Yields:** `sqlite3.Cursor` - Cursor for the transaction

**Example:**
```python
with db.transaction('Update user', {'id': 'admin', 'ip': '127.0.0.1'}) as cur:
    cur.execute('UPDATE users SET name = ? WHERE id = ?', ('Alice', 1))
```

##### `get_audit_logs(limit, offset, user_id, status)`

Retrieve audit logs with optional filtering.

**Returns:** `list[dict]` - Audit log entries

##### `get_audit_summary()`

Get audit statistics.

**Returns:** `dict` - Audit summary

##### `close()`

Close the database connection.

---

### A.3.2: QueryNormalizer (Part 3)

**File:** `normalizer.py`

#### Class: NormalizationOptions

```python
NormalizationOptions(
    case_insensitive=False,
    preserve_comments=False,
    normalize_in_clauses=True,
    normalize_uuid=True,
    normalize_json=True,
    collapse_whitespace=True
)
```

#### Class: QueryNormalizer

```python
QueryNormalizer(options=None)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `NormalizationOptions` | Normalization options |

#### Methods

##### `normalize(sql)`

Normalize a SQL query.

| Parameter | Type | Description |
|-----------|------|-------------|
| `sql` | `str` | Raw SQL query |

**Returns:** `str` - Normalized query

##### `fingerprint(normalized)`

Generate a fingerprint of the normalized query.

| Parameter | Type | Description |
|-----------|------|-------------|
| `normalized` | `str` | Normalized query |

**Returns:** `str` - SHA-256 fingerprint (16 chars)

##### `are_structurally_identical(sql1, sql2)`

Check if two queries are structurally identical.

**Returns:** `bool` - True if queries have same structure

##### `count_placeholders(normalized)`

Count the number of literal placeholders.

**Returns:** `int` - Number of placeholders

##### `analyze_structure(sql)`

Analyze the structure of a query.

**Returns:** `dict` - Structure information

---

### A.3.3: ThreatDetector (Part 4)

**File:** `threat_detector.py`

#### Enums

##### `ThreatLevel`

```python
class ThreatLevel(Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"
```

##### `ThreatCategory`

```python
class ThreatCategory(Enum):
    SQL_INJECTION = "SQL_INJECTION"
    DDL_OPERATION = "DDL_OPERATION"
    PRIVILEGE_ESCALATION = "PRIVILEGE_ESCALATION"
    DATA_EXFILTRATION = "DATA_EXFILTRATION"
    BRUTE_FORCE = "BRUTE_FORCE"
    SUSPICIOUS_PATTERN = "SUSPICIOUS_PATTERN"
```

##### `RuleType`

```python
class RuleType(Enum):
    BLOCK = "BLOCK"
    WARN = "WARN"
    LOG = "LOG"
    SCORE = "SCORE"
```

#### Class: ThreatRule

```python
ThreatRule(rule_id, name, category, severity, rule_type, pattern=None, description="")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `rule_id` | `str` | Unique rule identifier |
| `name` | `str` | Human-readable name |
| `category` | `ThreatCategory` | Threat category |
| `severity` | `ThreatLevel` | Threat severity |
| `rule_type` | `RuleType` | Rule type |
| `pattern` | `str` | Regex pattern (optional) |
| `description` | `str` | Rule description |

#### Class: ThreatDetector

```python
ThreatDetector(options=None)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `dict` | Configuration options |

#### Methods

##### `add_rule(rule)`

Add a threat rule.

| Parameter | Type | Description |
|-----------|------|-------------|
| `rule` | `ThreatRule` | The threat rule to add |

##### `analyze(query, context)`

Analyze a query for threats.

| Parameter | Type | Description |
|-----------|------|-------------|
| `query` | `str` | SQL query |
| `context` | `dict` | User context |

**Returns:** `dict` - Detection results

##### `is_whitelisted(query)`

Check if a query is whitelisted.

**Returns:** `bool` - True if whitelisted

##### `determine_action(detection)`

Determine action based on detection results.

**Returns:** `str` - Action to take ('BLOCK', 'WARN', 'LOG', 'ALLOW')

##### `get_severity_score(severity)`

Get numeric score for a severity level.

**Returns:** `int` - Numeric score (1, 5, 10, 25)

##### `get_threat_level(score)`

Get threat level based on score.

**Returns:** `ThreatLevel` - Threat level

---

### A.3.4: IncidentResponder (Part 5)

**File:** `incident_responder.py`

#### Class: Incident

```python
@dataclass
class Incident:
    query: str
    params: Any
    threat_level: str
    user_context: Dict[str, str]
    findings: List[Dict[str, Any]]
    detection: Dict[str, Any]
    timestamp: str = None
    incident_id: str = None
```

#### Class: IncidentResponder

```python
IncidentResponder(options=None)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `dict` | Configuration options |
| `options.vault_path` | `str` | Path to incident vault |
| `options.notify_security` | `bool` | Enable security notifications |
| `options.use_circuit_breaker` | `bool` | Enable circuit breaker |
| `options.terminate_connections` | `bool` | Terminate connections |
| `options.revoke_credentials` | `bool` | Revoke credentials |
| `options.max_incidents_memory` | `int` | Max incidents in memory |
| `options.cooldown_period` | `int` | Cooldown period in ms |

#### Methods

##### `handle_incident(incident)`

Handle an incident.

| Parameter | Type | Description |
|-----------|------|-------------|
| `incident` | `dict` | Incident details |

**Returns:** `dict` - Response result

##### `is_circuit_breaker_active()`

Check if the circuit breaker is active.

**Returns:** `bool` - True if active

##### `query_vault(filters, limit)`

Query the incident vault.

**Returns:** `list[dict]` - Incident records

##### `generate_report(incident_id)`

Generate an incident report.

**Returns:** `dict` - Incident report

##### `get_stats()`

Get incident statistics.

**Returns:** `dict` - Statistics

---

### A.3.5: CompleteDAMSystem (Part 5)

**File:** `complete_dam_system.py`

#### Constructor

```python
CompleteDAMSystem(options=None)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | `dict` | Configuration options |
| `options.db_path` | `str` | SQLite database path |
| `options.secure_audit_options` | `dict` | Secure audit options |
| `options.incident_responder_options` | `dict` | Incident responder options |
| `options.enable_audit` | `bool` | Enable audit (default: True) |
| `options.enable_threat_detection` | `bool` | Enable threat detection (default: True) |
| `options.enable_incident_response` | `bool` | Enable incident response (default: True) |
| `options.enable_console_logging` | `bool` | Enable console logging (default: True) |

#### Methods

##### `initialize()`

Initialize the DAM system.

##### `execute(sql, params, user_context)`

Execute a query through the DAM system.

**Returns:** `sqlite3.Cursor` - Query cursor

##### `query(sql, params, user_context)`

Execute a query and return results as dictionaries.

**Returns:** `list[dict]` - Rows as dictionaries

##### `get_status()`

Get system status.

**Returns:** `dict` - System status

##### `get_audit_summary()`

Get audit summary.

**Returns:** `dict` - Audit summary

##### `get_threat_patterns(level, limit)`

Get threat patterns.

**Returns:** `list[dict]` - Threat patterns

##### `get_incident_history(filters, limit)`

Get incident history.

**Returns:** `list[dict]` - Incident history

##### `shutdown()`

Shutdown the DAM system.

---

## A.4: Database Schema Reference

### PostgreSQL Audit Table Schema

```sql
CREATE TABLE dam_audit_logs (
    -- Primary key
    id BIGSERIAL PRIMARY KEY,
    
    -- Query information
    query_text TEXT NOT NULL,
    normalized_query TEXT,
    query_fingerprint VARCHAR(32),
    placeholder_count INTEGER,
    query_params JSONB,
    
    -- Timing
    duration_ms NUMERIC(10, 3),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- User context
    user_id TEXT,
    user_ip TEXT,
    
    -- Status
    status TEXT NOT NULL,
    error_message TEXT,
    
    -- Security
    threat_score INTEGER DEFAULT 0,
    threat_level VARCHAR(20),
    action_taken VARCHAR(20),
    
    -- Indexes for performance
    CONSTRAINT idx_audit_timestamp UNIQUE (id, timestamp)
);

-- Indexes
CREATE INDEX idx_dam_audit_logs_timestamp ON dam_audit_logs(timestamp);
CREATE INDEX idx_dam_audit_logs_user_id ON dam_audit_logs(user_id);
CREATE INDEX idx_dam_audit_logs_status ON dam_audit_logs(status);
CREATE INDEX idx_dam_audit_logs_fingerprint ON dam_audit_logs(query_fingerprint);
CREATE INDEX idx_dam_audit_logs_threat_level ON dam_audit_logs(threat_level);
```

### SQLite Audit Table Schema

```sql
CREATE TABLE audit_logs (
    -- Primary key
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Query information
    query_text TEXT NOT NULL,
    normalized_query TEXT,
    query_fingerprint VARCHAR(32),
    placeholder_count INTEGER,
    query_params TEXT,  -- JSON encoded
    
    -- Timing
    duration_ms REAL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    -- User context
    user_id TEXT,
    user_ip TEXT,
    
    -- Status
    status TEXT NOT NULL,
    error_message TEXT,
    
    -- Security
    threat_score INTEGER DEFAULT 0,
    threat_level VARCHAR(20),
    action_taken VARCHAR(20)
);

-- Indexes
CREATE INDEX idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_status ON audit_logs(status);
CREATE INDEX idx_audit_logs_fingerprint ON audit_logs(query_fingerprint);
CREATE INDEX idx_audit_logs_threat_level ON audit_logs(threat_level);
```

---

## A.5: Configuration Reference

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | Required |
| `DAM_VAULT_PATH` | Path to incident vault | `./incident_vault.jsonl` |
| `DAM_ENABLE_AUDIT` | Enable audit logging | `true` |
| `DAM_ENABLE_DETECTION` | Enable threat detection | `true` |
| `DAM_ENABLE_RESPONSE` | Enable incident response | `true` |
| `DAM_ENABLE_CONSOLE` | Enable console logging | `true` |
| `DAM_NOTIFY_SECURITY` | Enable security notifications | `true` |
| `DAM_CIRCUIT_BREAKER` | Enable circuit breaker | `true` |
| `DAM_TERMINATE_CONNECTIONS` | Terminate connections | `true` |
| `DAM_REVOKE_CREDENTIALS` | Revoke credentials | `false` |
| `DAM_COOLDOWN_PERIOD` | Cooldown period (ms) | `60000` |

### Configuration File Example

**JSON:**

```json
{
    "dam": {
        "enableAudit": true,
        "enableThreatDetection": true,
        "enableIncidentResponse": true,
        "enableConsoleLogging": true,
        "threatDetector": {
            "enablePatternMatching": true,
            "enableHeuristics": true,
            "enableThreatScoring": true,
            "logAllDetections": true
        },
        "incidentResponder": {
            "vaultPath": "./incident_vault.jsonl",
            "notifySecurity": true,
            "useCircuitBreaker": true,
            "terminateConnections": true,
            "revokeCredentials": false,
            "maxIncidentsMemory": 100,
            "cooldownPeriod": 60000
        }
    }
}
```

---

## A.6: Error Codes Reference

| Code | Description | Action |
|------|-------------|--------|
| `DAM-001` | Audit table initialization failed | Check database permissions |
| `DAM-002` | Audit log write failed | Check database connectivity |
| `DAM-003` | Query normalization failed | Check query syntax |
| `DAM-004` | Threat detection failed | Check threat detector configuration |
| `DAM-005` | Incident response failed | Check incident responder configuration |
| `DAM-006` | Circuit breaker active | Wait for cooldown period |
| `DAM-007` | Query blocked by security rules | Review query and rules |
| `DAM-008` | Connection termination failed | Check connection status |
| `DAM-009` | Credential revocation failed | Check auth system integration |
| `DAM-010` | Vault write failed | Check file permissions and disk space |
| `DAM-011` | Vault read failed | Check file permissions |
| `DAM-012` | System not initialized | Call `initialize()` first |
| `DAM-013` | System shutting down | Wait for shutdown to complete |

---

## A.7: Performance Metrics

### Audit Logging Overhead

| Operation | Overhead | Notes |
|-----------|----------|-------|
| Simple SELECT | 2-5ms | With audit logging |
| Complex SELECT | 5-15ms | With audit logging |
| INSERT/UPDATE | 3-8ms | With audit logging |
| Transaction | 5-20ms | With audit logging |
| Normalization | 0.5-2ms | Per query |
| Threat Detection | 1-5ms | Per query (with rules) |
| Incident Response | 10-50ms | Per incident |

### Scaling Recommendations

| Query Volume | Recommendations |
|--------------|-----------------|
| < 1000/min | Standard configuration |
| 1000-10000/min | Enable async logging, use connection pooling |
| 10000-100000/min | Use sampling, batch writes, separate audit database |
| > 100000/min | Consider log sampling, distributed architecture |

---

## A.8: Security Best Practices

### 1. Encryption

**At Rest:**
- Encrypt the incident vault file
- Use disk-level encryption
- Consider database encryption

**In Transit:**
- Use TLS/SSL for database connections
- Encrypt notifications
- Use secure channels for alerts

### 2. Access Control

**Least Privilege:**
- DAM system should have minimal database permissions
- Separate audit database user
- Read-only access for analysis tools

**Audit Log Access:**
- Restrict who can view audit logs
- Log access to audit logs
- Implement role-based access control

### 3. Integrity

**Tamper Prevention:**
- Use append-only vault
- Implement cryptographic signatures
- Regular integrity checks
- Offline backups

**Detection:**
- Monitor for tampering attempts
- Alert on modification attempts
- Log all access attempts

### 4. Compliance

**GDPR Requirements:**
- Redact PII from logs
- Support data deletion requests
- Maintain audit trail of log access
- Implement data retention policies

**HIPAA Requirements:**
- Encrypt PHI in logs
- Maintain strict access controls
- Log all PHI access
- Implement business associate agreements

---

## A.9: Troubleshooting Guide

### Common Issues and Solutions

#### 1. Audit Table Not Created

**Symptom:** `relation "dam_audit_logs" does not exist`

**Solution:**
```sql
-- Manual creation
CREATE TABLE dam_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    query_text TEXT NOT NULL,
    -- ... other columns
);
```

#### 2. Connection Pool Exhaustion

**Symptom:** `Cannot acquire connection from pool`

**Solution:**
```javascript
// Increase pool size
const pool = new AuditedPool(connectionString, {
    max: 50,  // Increase from default 20
    connectionTimeoutMillis: 10000
});
```

#### 3. Circuit Breaker Triggers Too Easily

**Symptom:** Queries being blocked by circuit breaker

**Solution:**
```javascript
// Adjust circuit breaker sensitivity
const responder = new IncidentResponder({
    cooldownPeriod: 120000,  // Increase to 2 minutes
    maxIncidentsMemory: 200   // Increase history size
});
```

#### 4. False Positive Threat Detections

**Symptom:** Legitimate queries being blocked

**Solution:**
```javascript
// Add whitelist entry
detector.whitelist.push({
    pattern: /LEGITIMATE_PATTERN/i,
    description: 'Legitimate query pattern'
});

// Or adjust rule severity
const rule = detector.rules.find(r => r.id === 'problematic_rule');
rule.type = RuleType.WARN;  // Change from BLOCK to WARN
```

#### 5. Vault File Corruption

**Symptom:** `Unexpected token in JSON`

**Solution:**
```bash
# Recover from backup
cp incident_vault.jsonl.backup incident_vault.jsonl

# Or manually repair the file
grep -v "bad_line" incident_vault.jsonl > incident_vault.jsonl.tmp
mv incident_vault.jsonl.tmp incident_vault.jsonl
```

---

## A.10: Advanced Usage Patterns

### Pattern 1: Custom Alert Handlers

**JavaScript:**
```javascript
const responder = new IncidentResponder({
    notifySecurity: true
});

// Override notification method
responder.notifySecurityTeam = async (incident) => {
    // Custom notification logic
    await slackClient.send({
        channel: '#security',
        text: `🚨 Incident: ${incident.incidentId}`,
        attachments: [{
            color: 'danger',
            fields: [
                { title: 'User', value: incident.userContext.id },
                { title: 'Query', value: incident.query.substring(0, 200) }
            ]
        }]
    });
};
```

**Python:**
```python
class CustomResponder(IncidentResponder):
    def _notify_security_team(self, incident):
        # Custom notification logic
        requests.post('https://slack.com/api/chat.postMessage', json={
            'channel': '#security',
            'text': f'🚨 Incident: {incident.incident_id}',
            'attachments': [{
                'color': 'danger',
                'fields': [
                    {'title': 'User', 'value': incident.user_context.get('id')},
                    {'title': 'Query', 'value': incident.query[:200]}
                ]
            }]
        })
```

### Pattern 2: Audit Log Export

**JavaScript:**
```javascript
async function exportAuditLogs(startDate, endDate) {
    const logs = await pool.query(
        `SELECT * FROM dam_audit_logs 
         WHERE timestamp BETWEEN $1 AND $2`,
        [startDate, endDate],
        { id: 'system', ip: 'internal' }
    );
    
    // Export to CSV
    const csv = logs.rows.map(row => 
        `${row.timestamp},${row.user_id},${row.query_text}`
    ).join('\n');
    
    fs.writeFileSync(`audit-${Date.now()}.csv`, csv);
}
```

**Python:**
```python
def export_audit_logs(start_date, end_date):
    logs = db.query(
        'SELECT * FROM audit_logs WHERE timestamp BETWEEN ? AND ?',
        (start_date, end_date)
    )
    
    # Export to CSV
    import csv
    with open(f'audit-{int(time.time())}.csv', 'w') as f:
        writer = csv.DictWriter(f, fieldnames=logs[0].keys())
        writer.writeheader()
        writer.writerows(logs)
```

### Pattern 3: Real-time Dashboard

**JavaScript/Express:**
```javascript
app.get('/api/dashboard/stats', async (req, res) => {
    const stats = await dam.getAuditSummary();
    const threats = await dam.getThreatPatterns(null, 10);
    const incidents = await dam.getIncidentHistory({ limit: 10 });
    
    res.json({
        stats,
        topThreats: threats,
        recentIncidents: incidents,
        systemStatus: dam.getStatus()
    });
});
```

**Python/Flask:**
```python
@app.route('/api/dashboard/stats')
def dashboard_stats():
    return jsonify({
        'stats': dam.get_audit_summary(),
        'threats': dam.get_threat_patterns(limit=10),
        'incidents': dam.get_incident_history(limit=10),
        'status': dam.get_status()
    })
```

---

This completes Appendix A. You now have a comprehensive reference for all APIs, schemas, and patterns used throughout the DAM series. Use this guide alongside the tutorial to understand, customize, and extend your Database Activity Management system.
