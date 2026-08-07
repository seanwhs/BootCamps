# DAM Tutorial Series: Comprehensive Slide Deck Outline

This comprehensive slide deck outline is designed to teach the entire Database Activity Management tutorial series in a structured, presentation-ready format. Each slide includes key points, visual suggestions, speaker notes, and estimated timing. The outline is organized to flow naturally from foundational concepts to advanced implementation.

---

## DECK OVERVIEW

**Title:** Guarding the Core: A Practitioner's Guide to Database Activity Management (DAM)

**Target Audience:** Developers, Security Engineers, DevOps Professionals, Technical Leads

**Total Slides:** ~200+
**Estimated Duration:** 4-6 hours (full workshop) or 6-8 sessions (modular)

**Format:** Slide-by-slide outline with:
- Slide number and title
- Key content points
- Visual/Diagram suggestions
- Speaker notes
- Estimated timing
- Interactive elements

---

# SECTION 0: INTRODUCTION & FOUNDATIONS

## Module 0.1: Opening & Context (15 minutes)

### SLIDE 0.1: Title Slide
**Title:** Guarding the Core: A Practitioner's Guide to Database Activity Management

**Visual:**
- Database icon with security shield overlay
- "Complete DAM Tutorial Series" subtitle
- Company logo (if applicable)
- Presenter name and title

**Speaker Notes:** 
"Welcome to 'Guarding the Core.' Over the next [X hours/sessions], we'll build a complete production-ready Database Activity Management system from scratch. This isn't a theoretical security talk—we're going to write real code, build real systems, and create a working DAM solution you can actually deploy."

**Timing:** 1 minute

---

### SLIDE 0.2: The Problem Statement
**Title:** The Database Blind Spot

**Visual:**
- Split screen showing:
  - Left: Traditional security stack (firewall, WAF, IAM)
  - Right: Database (unprotected)
  - "Blind Spot" highlighted in red

**Content:**
- Traditional security protects the perimeter
- Once inside, the database is often unprotected
- Internal threats: 34% of all breaches
- SQL injection: #1 web application attack
- Average breach detection time: 277 days

**Speaker Notes:**
"Think of a medieval castle. The walls are high, the guards are vigilant. But once someone is inside—whether a trusted knight or an enemy spy—they can walk straight to the treasure room. Traditional security protects the 'castle walls.' But the 'treasure room'—your database—often has no security. DAM is the treasure room security."

**Timing:** 3 minutes

**Interactive Element:** 
"Raise your hand if your organization has ever experienced a database-related security incident."

---

### SLIDE 0.3: What Is This Series?
**Title:** A Complete DAM Journey

**Visual:**
- Roadmap/mountain path showing 5 parts + appendices
- Each part as a checkpoint

**Content:**
- **Part 1**: Foundations & Audit Trail Setup
- **Part 2**: Interception & Native Hooks
- **Part 3**: Real-Time Parsing & Query Normalization
- **Part 4**: Behavioral Rules & SQL Injection Detection
- **Part 5**: Automated Remediation & Incident Response
- **Appendices**: API Reference, Deployment Guide, Primers

**Speaker Notes:**
"We're going on a journey. We'll start with the absolute basics—audit logging—and progressively build up to a complete, production-ready DAM system. By the end, you'll have working code in both JavaScript and Python that you can adapt to your own applications."

**Timing:** 2 minutes

---

### SLIDE 0.4: What You'll Build
**Title:** The Complete Architecture

**Visual:**
- Layered architecture diagram:
  - Application Layer
  - Security Components Layer (Audit → Interception → Normalization → Detection → Response)
  - Database Layer
  - Storage Layer

**Content:**
- **5 integrated layers** working together
- **2 languages**: JavaScript (Postgres) + Python (SQLite)
- **Open source tools**: Neon, Node.js, Python, SQLite
- **Production-ready code**: Full error handling, security, performance

**Speaker Notes:**
"Here's what we're building. It's a complete security pipeline. Every query is intercepted, normalized, analyzed for threats, and either blocked or allowed. Everything is logged in an immutable audit trail. And when a threat is detected, the system responds automatically—blocking queries, terminating connections, and alerting security teams."

**Timing:** 2 minutes

---

### SLIDE 0.5: Target Audience & Prerequisites
**Title:** Who This Is For

**Visual:**
- Three audience categories with checkmarks:
  - Developers (✓)
  - Security Engineers (✓)
  - DevOps/Infrastructure (✓)

**Content:**

**Primary Audience:**
- Junior to Mid-Level Developers
- DevOps Engineers
- Security Engineers
- Full-Stack Developers
- Technical Leads

**Prerequisites:**
- Basic programming (JavaScript/Python)
- Basic SQL knowledge
- Node.js and Python installed

**Not Required:**
- Security expertise
- Enterprise infrastructure
- Commercial licenses

**Speaker Notes:**
"This series is designed for developers who want to understand security monitoring from the ground up. You don't need to be a security expert. You just need basic programming knowledge and a willingness to learn. Everything else—the security concepts, the architecture patterns, the code—we'll build together."

**Timing:** 2 minutes

---

### SLIDE 0.6: Our Technology Stack
**Title:** Open Source Tools

**Visual:**
- Logos/names with brief descriptions:
  - Neon Serverless Postgres (cloud database)
  - SQLite (local database)
  - Node.js / JavaScript
  - Python
  - Prometheus/Grafana (monitoring)
  - JSONL (audit storage)

**Content:**
- **Everything is free and open source**
- No commercial licenses needed
- Works on Windows, macOS, Linux
- Can be adapted to other databases/languages

**Speaker Notes:**
"We're using only free, open-source software. No expensive commercial DAM solutions, no vendor lock-in. Just you, your editor, and the code. And the patterns we learn can be adapted to any programming language or database."

**Timing:** 2 minutes

---

### SLIDE 0.7: Series Structure & Flow
**Title:** How We'll Progress

**Visual:**
- Timeline showing each part in sequence
- Arrows showing dependencies

**Content:**

| Part | Focus | Code |
|------|-------|------|
| **Part 1** | Audit Foundation | AuditedPool, AuditedSQLite |
| **Part 2** | Interception | DriverInterceptor, NativeTrace |
| **Part 3** | Normalization | QueryNormalizer |
| **Part 4** | Detection | ThreatDetector |
| **Part 5** | Response | IncidentResponder |

**Speaker Notes:**
"Each part builds on the previous one. We start with the foundation—audit logging—and add layers of sophistication: interception, normalization, detection, and finally, automated response. Each part is complete with code you can run and test."

**Timing:** 2 minutes

---

### SLIDE 0.8: Environment Setup
**Title:** Getting Ready to Code

**Visual:**
- Terminal commands screenshot
- Directory structure diagram

**Content:**

**Required:**
- Node.js v16+
- Python 3.8+
- VS Code (or preferred editor)

**Setup Commands:**
```bash
mkdir guarding-the-core
cd guarding-the-core
mkdir -p javascript/src javascript/tests
mkdir python
```

**Neon Account (free tier):**
- Sign up at neon.tech
- Create a database
- Get connection string

**Speaker Notes:**
"Before we start writing code, let's get our environment set up. You'll need Node.js and Python installed, and a Neon account for the cloud database parts. Everything is free."

**Timing:** 3 minutes

**Interactive Element:** 
"Take 2 minutes to check your environment. Node --version? Python --version? If you're ready, give me a thumbs up."

---

### SLIDE 0.9: Live Demo
**Title:** What Success Looks Like

**Visual:**
- Terminal/console output showing:
  - Audited query logs
  - Threat detection alerts
  - Incident response actions

**Content:**

**Demo (Live or Video):**
1. Start the DAM system
2. Execute a normal query → Success
3. Execute a malicious query → Blocked
4. Show audit logs
5. Show incident vault

**Speaker Notes:**
"Here's what we're building toward. This is the system in action. A normal query executes and is logged. A malicious query—in this case, SQL injection—is detected, blocked, and the incident is recorded. Everything is logged for analysis."

**Timing:** 3 minutes

---

### SLIDE 0.10: The DAM Pipeline (Visual)
**Title:** The Security Pipeline

**Visual:**
- Flowchart showing:
  1. Query → 2. Interception → 3. Normalization → 4. Detection → 5. Response → 6. Audit

**Content:**

```
Query → Interception → Normalization → Detection → Response → Audit
  │          │              │             │           │          │
  │          ▼              ▼             ▼           ▼          ▼
  │     Application    "SELECT *    Pattern   Block/    Incident
  │     Driver         FROM users   Matching  Allow     Vault
  │     Native         WHERE '?'"   Heuristic Notify    Audit
  │                                  Frequency          Table
```

**Speaker Notes:**
"This is the DAM pipeline in action. A query enters the system, is intercepted at multiple layers, normalized to reveal its true pattern, analyzed for threats, and either allowed or blocked. Everything is audited for later analysis."

**Timing:** 2 minutes

---

### SLIDE 0.11: Key Terms
**Title:** DAM Vocabulary

**Visual:**
- Terms with brief definitions
- Icons for each concept

**Content:**

| Term | Definition | Analogy |
|------|------------|---------|
| **DAM** | Database Activity Management | Security cameras for database |
| **Audit Trail** | Complete record of activities | Bank transaction log |
| **Interception** | Capturing queries | Security checkpoint |
| **Normalization** | Stripping literals to find patterns | Recognizing behavior, not details |
| **Heuristics** | Pattern-based detection | Security guard's intuition |
| **Remediation** | Automated response | Automatic security door |

**Speaker Notes:**
"Let's quickly review some key terms. We'll use these throughout the series. If you're not familiar with any of these, don't worry—we'll cover each one in detail as we build the corresponding components."

**Timing:** 2 minutes

---

### SLIDE 0.12: Prerequisites Check
**Title:** Are You Ready?

**Visual:**
- Checklist with all prerequisites

**Content:**

**✅ You should have:**
- Node.js installed
- Python installed
- Neon account (free tier)
- Code editor ready
- Terminal/command line access

**✅ You should know:**
- Basic JavaScript or Python
- What a SELECT query does
- How to run a script

**❌ You don't need:**
- Security certifications
- Enterprise infrastructure
- Commercial licenses
- Prior DAM experience

**Speaker Notes:**
"Before we dive in, let's make sure you're ready. If you have Node.js and Python installed, you're 90% of the way there. The rest we'll cover as we go."

**Timing:** 1 minute

---

### SLIDE 0.13: Series Overview
**Title:** Part 1 Preview

**Visual:**
- Part 1 icon/thumbnail
- Brief description

**Content:**

**Part 1: Foundations & The Audit Trail Setup**
- Build the `AuditedPool` (JavaScript)
- Build the `AuditedSQLite` (Python)
- Create audit tables
- Log queries with context
- Test the audit system

**Key Takeaway:** Every query is logged with who, what, when, and where.

**Speaker Notes:**
"In Part 1, we'll build the foundation of our DAM system: audit logging. We'll create classes that wrap database connections and log every query with user context, timing, and status. This is the bedrock upon which everything else rests."

**Timing:** 1 minute

---

### SLIDE 0.14: Module Overview
**Title:** How Each Module Works

**Visual:**
- Four-part structure diagram

**Content:**

**Each module has:**

1. **The Target** → What we're building
2. **The Concept** → Why it matters (with analogies)
3. **The Implementation** → Complete, copy-pasteable code
4. **The Verification** → How to test it works

**Then deep references:**
- API documentation
- Deep dives
- Performance considerations

**Speaker Notes:**
"Every part follows the same structure. We'll start with a clear target—what we're building. Then we'll explain the concept using real-world analogies. Then we'll write the code—complete, working code you can copy and paste. Finally, we'll verify it works before moving on."

**Timing:** 1 minute

---

### SLIDE 0.15: Q&A (End of Introduction)
**Title:** Questions?

**Visual:**
- Open question mark graphic
- Your contact information

**Content:**
- What questions do you have about the series?
- What specific database security challenges are you facing?
- Any concerns about prerequisites?

**Speaker Notes:**
"Before we move on to the code, I want to make sure you have a solid foundation. What questions do you have? What aspects of database security are you most concerned about?"

**Timing:** 5 minutes

---

# SECTION 1: PART 1 - FOUNDATIONS & AUDIT TRAIL

## Module 1.1: Why Audit Trails (10 minutes)

### SLIDE 1.1: Part 1 - Foundations & Audit Trail Setup
**Title:** Building the Foundation

**Visual:**
- Part 1 opening graphic
- "Part 1 of 5" badge

**Content:**
- **Goal:** Build a reliable, immutable audit-logging foundation
- **Databases:** Neon (Postgres) + SQLite
- **Languages:** JavaScript + Python
- **Output:** Complete audit logging system

**Speaker Notes:**
"Welcome to Part 1! We're going to build the foundation of our DAM system: the audit trail. Think of this as installing security cameras in your database—every operation is recorded."

**Timing:** 1 minute

---

### SLIDE 1.2: Why Audit Trails Matter
**Title:** The Security Camera Analogy

**Visual:**
- Bank vault with security cameras
- Transaction log shown on screen

**Content:**

**What is an Audit Trail?**
- Complete, chronological record of database activities
- Who did what, when, where, and how
- Successes AND failures

**Why It Matters:**
- Investigate security incidents
- Meet compliance requirements
- Detect insider threats
- Debug application issues
- Understand data usage

**Speaker Notes:**
"Imagine you're the security manager of a bank. Every transaction is recorded—who performed it, what they did, when they did it, and whether it succeeded or failed. If something goes wrong, you have a complete record to investigate. That's exactly what we're building for your database."

**Timing:** 3 minutes

---

### SLIDE 1.3: The Critical Properties of Audit Trails
**Title:** What Makes a Good Audit Trail?

**Visual:**
- Five pillars diagram:
  - Immutability
  - Completeness
  - Verifiability
  - Performance
  - Separation of Concerns

**Content:**

| Property | Description | Why It Matters |
|----------|-------------|----------------|
| **Immutability** | Cannot be modified or deleted | Prevents tampering |
| **Completeness** | Every query, success or failure | No blind spots |
| **Verifiability** | Structured, queryable data | Easy to investigate |
| **Performance** | Minimal impact on database | Doesn't slow applications |
| **Separation** | Stored separately from data | Survives database breach |

**Speaker Notes:**
"A good audit trail isn't just any log. It's immutable—once written, it can't be changed. It's complete—every query is logged. It's verifiable—you can query it for analysis. It performs well—it doesn't slow your database. And it's separated from your application data."

**Timing:** 3 minutes

---

### SLIDE 1.4: The Audit Pipeline Pattern
**Title:** Before → During → After

**Visual:**
- Timeline showing three phases:
  1. Before: Capture context
  2. During: Execute query
  3. After: Log result

**Content:**

```
┌─────────────────────────────────────────────────────────────┐
│                    THE AUDIT PIPELINE                       │
│                                                             │
│  Before    →   During    →   After                         │
│  ┌─────┐       ┌─────┐      ┌─────┐                      │
│  │ Who  │       │     │      │Status│                     │
│  │ When │       │Query│      │Error │                     │
│  │ Where│       │     │      │Durat.│                     │
│  └─────┘       └─────┘      └─────┘                      │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"Every audit follows a pattern. Before the query executes, we capture context—who, when, where. During the query, we execute it exactly as normal. After the query, we log the outcome—success or failure, duration, any errors. This 'before-during-after' pattern is what we'll implement."

**Timing:** 2 minutes

---

### SLIDE 1.5: Compliance Requirements
**Title:** Why Compliance Demands Audit Trails

**Visual:**
- Regulatory logos:
  - GDPR
  - HIPAA
  - PCI DSS
  - SOC 2
  - SOX

**Content:**

| Regulation | What It Requires |
|------------|------------------|
| **GDPR** | Log all access to personal data |
| **HIPAA** | Track PHI access and modifications |
| **PCI DSS** | Monitor all cardholder data access |
| **SOC 2** | Comprehensive security monitoring |
| **SOX** | Audit financial data operations |

**Common Requirements:**
- User identification
- Timestamps
- Complete access logs
- Tamper-proof storage
- Retention policies

**Speaker Notes:**
"Audit trails aren't just a good idea—they're often legally required. GDPR, HIPAA, PCI DSS, and other regulations all require detailed logging of database access. Our DAM system will meet and exceed these requirements."

**Timing:** 2 minutes

---

## Module 1.2: JavaScript Implementation (30 minutes)

### SLIDE 1.6: JavaScript Setup
**Title:** Project Setup for Node.js

**Visual:**
- Terminal commands screenshot
- Directory structure

**Content:**

```bash
cd guarding-the-core/javascript
npm init -y
npm install pg dotenv
```

**File:** `.env`
```
DATABASE_URL=postgresql://user:pass@neon-host/db?sslmode=require
```

**Directory Structure:**
```
javascript/
├── .env
├── package.json
├── src/
│   └── audited-pool.js
└── tests/
    └── test-audited-pool.js
```

**Speaker Notes:**
"Let's set up our JavaScript environment. We'll use the `pg` package for PostgreSQL connectivity and `dotenv` for configuration. Make sure you have your Neon connection string ready."

**Timing:** 3 minutes

**Live Demo:** Create the directory and files together.

---

### SLIDE 1.7: AuditedPool - Constructor
**Title:** Building the AuditedPool Class

**Visual:**
- Code block with constructor
- Key parts highlighted

**Content:**

```javascript
import pkg from 'pg';
const { Pool } = pkg;

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
}
```

**Explanation:**
- Wraps PostgreSQL's Pool class
- Stores connection string for reconnection
- Configures connection timeout and max connections
- Tracks whether audit table is created

**Speaker Notes:**
"The `AuditedPool` class wraps PostgreSQL's connection pool. It doesn't replace it—it adds audit logging around every query. We'll intercept every query, log it, and then pass it to the original pool."

**Timing:** 3 minutes

---

### SLIDE 1.8: AuditedPool - Audit Table
**Title:** Creating the Audit Table

**Visual:**
- SQL schema diagram
- Code block with CREATE TABLE

**Content:**

```sql
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

-- Indexes for performance
CREATE INDEX idx_dam_audit_logs_timestamp ON dam_audit_logs(timestamp);
CREATE INDEX idx_dam_audit_logs_user_id ON dam_audit_logs(user_id);
CREATE INDEX idx_dam_audit_logs_status ON dam_audit_logs(status);
```

**Speaker Notes:**
"The audit table stores everything we need: the query text, parameters, duration, user context, status, and error messages. We add indexes on frequently queried columns—timestamp, user_id, and status—for performance."

**Timing:** 3 minutes

**Live Demo:** Run the SQL in a database client.

---

### SLIDE 1.9: AuditedPool - Query Method
**Title:** The Query Method (The Heart of Audit)

**Visual:**
- Code block with detailed comments
- Flow diagram showing before-during-after

**Content:**

```javascript
async query(text, params = [], userContext = { id: 'system', ip: 'unknown' }) {
  // 1. Ensure audit table exists
  await this.initAuditTable();

  // 2. Capture start time
  const startTime = performance.now();
  
  let status = 'SUCCESS';
  let errorMessage = null;
  let result = null;

  try {
    // 3. Execute the query
    result = await this.pool.query(text, params);
    return result;
  } catch (error) {
    // 4. Capture failure
    status = 'ERROR';
    errorMessage = error.message;
    throw error;
  } finally {
    // 5. Always log the result
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
```

**Speaker Notes:**
"The `query` method is the core of our audit system. It executes the query and logs the result—whether success or failure. The `finally` block is key: it runs regardless of whether the query succeeded or failed."

**Timing:** 5 minutes

---

### SLIDE 1.10: AuditedPool - Logging
**Title:** Writing Audit Entries

**Visual:**
- Code block showing logAudit
- Explanation of why we use a direct connection

**Content:**

```javascript
async logAudit(auditEntry) {
  // Use a direct client to avoid recursion
  const client = await this.pool.connect();
  try {
    await client.query(
      `INSERT INTO dam_audit_logs 
       (query_text, query_params, duration_ms, user_id, user_ip, status, error_message)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
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
  
  // Also log to console
  console.log(
    `[DAM AUDIT] ${new Date().toISOString()} | ` +
    `User: ${auditEntry.user_id} | ` +
    `Status: ${auditEntry.status} | ` +
    `Duration: ${auditEntry.duration_ms.toFixed(2)}ms | ` +
    `Query: ${auditEntry.query_text.substring(0, 200)}...`
  );
}
```

**Speaker Notes:**
"Notice that we use a direct client connection, not `pool.query()`. Why? Because if we used `pool.query()`, we'd be auditing our own audit logs—creating an infinite loop! The direct client avoids this. We also log to console for immediate visibility."

**Timing:** 4 minutes

---

### SLIDE 1.11: AuditedPool - Testing
**Title:** Testing the AuditedPool

**Visual:**
- Terminal output showing successful tests
- Code for test script

**Content:**

```javascript
// tests/test-audited-pool.js
const pool = new AuditedPool(process.env.DATABASE_URL);

// Test 1: Normal query
await pool.query('SELECT NOW()', [], { id: 'test-user', ip: '127.0.0.1' });

// Test 2: Failing query (should log error)
try {
  await pool.query('SELECT * FROM non_existent_table', [], { id: 'test-user', ip: '127.0.0.1' });
} catch (error) {
  // Expected
}

// Test 3: Query with user context
await pool.query('SELECT $1::text as greeting', ['Hello, DAM!'], { 
  id: 'alice@example.com', 
  ip: '192.168.1.100' 
});
```

**Expected Console Output:**
```
[DAM AUDIT] 2024-01-15T10:00:00.000Z | User: test-user | Status: SUCCESS | Duration: 12.34ms | Query: SELECT NOW()
[DAM AUDIT] 2024-01-15T10:00:00.100Z | User: test-user | Status: ERROR | Duration: 3.45ms | Query: SELECT * FROM non_existent_table
[DAM AUDIT] 2024-01-15T10:00:00.200Z | User: alice@example.com | Status: SUCCESS | Duration: 8.90ms | Query: SELECT $1::text as greeting
```

**Speaker Notes:**
"Let's test our audit system. We'll run normal queries, failing queries, and queries with different user contexts. Each one should be logged with the correct information."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the output.

---

### SLIDE 1.12: JavaScript Verification
**Title:** Verify Your JavaScript Implementation

**Visual:**
- Terminal commands to run
- Expected output

**Content:**

**Run the tests:**
```bash
node tests/test-audited-pool.js
```

**Check the database:**
```sql
SELECT user_id, status, LEFT(query_text, 50) as query, duration_ms
FROM dam_audit_logs
ORDER BY timestamp DESC
LIMIT 10;
```

**Expected:**
- All queries are logged
- User context is captured
- Errors include error messages
- Timestamps are correct

**Speaker Notes:**
"Take a few minutes to run the tests and verify your implementation. Check the console output and the database table. Make sure all queries are being logged correctly."

**Timing:** 5 minutes

**Interactive Element:** 
"Take 3 minutes to run the tests. If you see green, give me a thumbs up."

---

## Module 1.3: Python Implementation (30 minutes)

### SLIDE 1.13: Python Setup
**Title:** Project Setup for Python

**Visual:**
- Directory structure
- Python file contents

**Content:**

**Directory Structure:**
```
python/
├── audited_sqlite.py
├── test_audited_sqlite.py
└── main.py
```

**Initial Python Code:**
```python
# audited_sqlite.py
import sqlite3
import time
from contextlib import contextmanager
from datetime import datetime

class AuditedSQLite:
    def __init__(self, db_path: str):
        self.db_path = db_path
        self._init_audit_table()
```

**Speaker Notes:**
"Now let's build the Python version for SQLite. The concepts are identical—we're just using Python's idioms and SQLite's features."

**Timing:** 3 minutes

---

### SLIDE 1.14: SQLite Audit Table
**Title:** SQLite Audit Table

**Visual:**
- SQLite schema diagram
- Code block

**Content:**

```python
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
        
        # Create indexes
        conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_logs(timestamp)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_logs(user)")
        conn.commit()
```

**Speaker Notes:**
"The SQLite table is simpler than Postgres—no JSONB, but the structure is similar. We store the query, duration, user, status, error, and timestamp. The indexes help with query performance."

**Timing:** 3 minutes

---

### SLIDE 1.15: Python Transaction Context Manager
**Title:** Transaction Context Manager

**Visual:**
- Code with @contextmanager decorator
- Flow diagram

**Content:**

```python
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
        print(f"[DAM AUDIT] {datetime.utcnow().isoformat()} | User: {user} | Status: {status} | Duration: {duration:.2f}ms | Query: {query}")
```

**Speaker Notes:**
"Python's context manager pattern is perfect for audit logging. The `@contextmanager` decorator lets us wrap any code block. Before the block, we start timing. During the block, the user executes queries. After the block, we log the result—whether it succeeded or failed."

**Timing:** 5 minutes

---

### SLIDE 1.16: Python Helper Methods
**Title:** Convenience Methods

**Visual:**
- Code for query(), query_one(), close()

**Content:**

```python
def query(self, query: str, params: tuple = (), user: str = "system"):
    """Execute a query and return all results as dictionaries."""
    with self.transaction(query, user) as cursor:
        cursor.execute(query, params)
        columns = [description[0] for description in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]

def query_one(self, query: str, params: tuple = (), user: str = "system"):
    """Execute a query and return the first result."""
    results = self.query(query, params, user)
    return results[0] if results else None

def close(self):
    """Close the database connection."""
    if hasattr(self, '_local') and hasattr(self._local, 'connection'):
        self._local.connection.close()
```

**Speaker Notes:**
"These convenience methods make it easy to use the audited database. `query()` returns results as dictionaries, `query_one()` returns just the first result, and `close()` closes the connection cleanly."

**Timing:** 3 minutes

---

### SLIDE 1.17: Python Testing
**Title:** Testing the AuditedSQLite

**Visual:**
- Terminal output with test results
- Python test script

**Content:**

```python
# test_audited_sqlite.py
db = AuditedSQLite(':memory:')  # In-memory for testing

# Test 1: Create table
db.execute("CREATE TABLE test (id INTEGER, name TEXT)", user="admin")

# Test 2: Insert data
db.execute("INSERT INTO test VALUES (1, 'Alice')", user="alice")

# Test 3: Query data
results = db.query("SELECT * FROM test", user="alice")
print(results)  # [{'id': 1, 'name': 'Alice'}]

# Test 4: Failing query
try:
    db.execute("SELECT * FROM non_existent", user="test")
except sqlite3.Error as e:
    print(f"Expected error: {e}")
```

**Expected Output:**
```
[DAM AUDIT] 2024-01-15T10:00:00.000Z | User: admin | Status: SUCCESS | Duration: 2.50ms | Query: CREATE TABLE test...
[DAM AUDIT] 2024-01-15T10:00:00.010Z | User: alice | Status: SUCCESS | Duration: 1.20ms | Query: INSERT INTO test...
[DAM AUDIT] 2024-01-15T10:00:00.020Z | User: alice | Status: SUCCESS | Duration: 0.80ms | Query: SELECT * FROM test
[{'id': 1, 'name': 'Alice'}]
[DAM AUDIT] 2024-01-15T10:00:00.030Z | User: test | Status: ERROR | Duration: 0.50ms | Query: SELECT * FROM non_existent
Expected error: no such table: non_existent
```

**Speaker Notes:**
"Let's test our Python implementation. We'll use an in-memory database for testing. Each query should produce an audit entry."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the output.

---

### SLIDE 1.18: Python Verification
**Title:** Verify Your Python Implementation

**Visual:**
- Commands to run
- Expected output

**Content:**

**Run the tests:**
```bash
python test_audited_sqlite.py
```

**Check the database:**
```bash
sqlite3 test.db
sqlite> SELECT user, status, LEFT(query, 50) as query, duration_ms
        FROM audit_logs ORDER BY timestamp DESC LIMIT 10;
```

**Expected:**
- All queries are logged
- User context is captured
- Errors include error messages
- Timestamps are correct

**Speaker Notes:**
"Take a few minutes to run the Python tests and verify your implementation. Check both the console output and the database table."

**Timing:** 5 minutes

---

### SLIDE 1.19: JavaScript vs Python Comparison
**Title:** Side-by-Side Comparison

**Visual:**
- Split screen showing both implementations

**Content:**

| Aspect | JavaScript (Neon) | Python (SQLite) |
|--------|------------------|-----------------|
| **Language** | Node.js | Python 3 |
| **Database** | Neon (Postgres) | SQLite |
| **Connection** | Connection Pool | Direct/Thread-Local |
| **Transaction** | Manual (BEGIN/COMMIT) | Context Manager |
| **Parameters** | JSONB storage | JSON text |
| **Error Handling** | Try/Catch/Finally | Try/Except/Finally |

**Speaker Notes:**
"Both implementations achieve the same goal but use language-appropriate patterns. JavaScript uses promises and pools; Python uses context managers and thread-local storage. Choose the one that fits your stack."

**Timing:** 2 minutes

---

### SLIDE 1.20: Part 1 Summary
**Title:** What You've Built

**Visual:**
- Checklist of completed items
- Architecture diagram highlighting Part 1

**Content:**

**✅ JavaScript:**
- AuditedPool class for Neon/Postgres
- Automatic audit table creation with indexes
- Comprehensive logging with user context
- Console output for immediate visibility
- Test script verifying all functionality

**✅ Python:**
- AuditedSQLite class for SQLite
- Thread-safe connection management
- Context manager for transactions
- Convenience methods (query, query_one)
- Complete test suite

**Speaker Notes:**
"Congratulations! You've built the foundation of your DAM system. Every query is now logged with complete context. This is the bedrock upon which all other layers will be built."

**Timing:** 2 minutes

---

### SLIDE 1.21: Part 1 Verification Exercise
**Title:** Verify Your Audit System

**Visual:**
- Step-by-step verification checklist

**Content:**

1. **Run the tests**: All tests should pass
2. **Check the database**: Audit table has entries
3. **Test user context**: Queries are tagged with user IDs
4. **Test error logging**: Failed queries are logged
5. **Test performance**: Duration is recorded
6. **Check console output**: Real-time logging works

**If anything fails:**
- Check database connection
- Verify table creation
- Check user context format
- Review error handling

**Speaker Notes:**
"Take 5 minutes to verify your entire audit system. Run the tests, check the database, and make sure everything is working. This is the foundation—it needs to be solid."

**Timing:** 5 minutes

**Interactive Element:** 
"Run the verification commands. If everything passes, give me a thumbs up. If something fails, what error are you seeing?"

---

### SLIDE 1.22: Q&A (End of Part 1)
**Title:** Questions?

**Visual:**
- Open question mark
- Recap of key concepts

**Content:**

**Key Concepts:**
- Audit trails are essential for security and compliance
- The "before-during-after" logging pattern
- Connection pooling and thread safety
- Separate storage for audit logs
- Real-time vs. persistent logging

**Common Questions:**
- Why use a separate connection for audit logging?
- How does this handle high volume?
- Can I add custom fields to audit logs?
- What about redacting sensitive data?

**Speaker Notes:**
"What questions do you have about audit logging? What aspects of the implementation were unclear? Let's make sure everyone is comfortable before we move on."

**Timing:** 5 minutes

---

# SECTION 2: PART 2 - INTERCEPTION & NATIVE HOOKS

## Module 2.1: Why Interception (10 minutes)

### SLIDE 2.1: Part 2 - Interception & Native Hooks
**Title:** Catching Queries at Every Level

**Visual:**
- Part 2 opening graphic
- "Part 2 of 5" badge

**Content:**
- **Goal:** Capture queries at driver and native levels
- **Key Question:** What if queries bypass our audit wrapper?
- **Solution:** Multiple interception layers
- **Output:** Complete query visibility

**Speaker Notes:**
"Welcome to Part 2! In Part 1, we built audit logging at the application layer. But what if queries bypass our wrapper? What if a developer uses a raw connection, or an attacker gains direct database access? Part 2 solves this with multiple interception layers."

**Timing:** 1 minute

---

### SLIDE 2.2: The Interception Problem
**Title:** The Gap in Application-Level Auditing

**Visual:**
- Flowchart showing:
  - Application → AuditedPool ✅ (logged)
  - Application → Raw Connection ❌ (not logged)

**Content:**

**What We Covered in Part 1:**
- All queries through `AuditedPool` are logged
- User context is captured
- Query details are recorded

**What We Missed:**
- Queries through raw database connections
- Queries from other applications
- Queries from administrative tools (psql, pgAdmin)
- Queries from compromised credentials

**The Question:** How do we catch these?

**Speaker Notes:**
"Our Part 1 solution is great for queries that go through our wrapper. But what about queries that don't? A developer might use a raw connection, or an attacker might connect directly to the database. We need to catch these too."

**Timing:** 3 minutes

---

### SLIDE 2.3: Defense-in-Depth with Interception
**Title:** The Interception Layers

**Visual:**
- Three-layer diagram:
  1. Application Layer (Part 1)
  2. Driver Layer (Part 2 - JavaScript)
  3. Native Layer (Part 2 - Python)

**Content:**

```
┌─────────────────────────────────────┐
│  Application Layer (Part 1)         │ ← Queries through AuditedPool
│  - User context                     │
│  - Business-aware                   │
└─────────────────────────────────────┘
              │
┌─────────────▼───────────────────────┐
│  Driver Layer (Part 2 - JS)         │ ← Queries through raw connections
│  - Catches "shadow" queries         │
│  - Driver-level visibility          │
└─────────────────────────────────────┘
              │
┌─────────────▼───────────────────────┐
│  Native Layer (Part 2 - Python)     │ ← Queries from any source
│  - Lowest-level capture             │
│  - Native C callback                │
└─────────────────────────────────────┘
```

**Speaker Notes:**
"Defense-in-depth means multiple layers of protection. Part 1 gave us the application layer. Part 2 adds two more layers: driver-level and native-level interception. Together, they catch every query—no matter how it reaches the database."

**Timing:** 3 minutes

---

### SLIDE 2.4: The Interception Analogy
**Title:** Security Cameras + Motion Sensors

**Visual:**
- Office building with:
  - Security guards at main entrance (application layer)
  - Cameras on all doors (driver layer)
  - Motion sensors everywhere (native layer)

**Content:**

| Layer | Analogy | What It Catches |
|-------|---------|-----------------|
| **Application** | Security guards | Proper entrances |
| **Driver** | Security cameras | All entrances (including side doors) |
| **Native** | Motion sensors | Any movement anywhere |

**Speaker Notes:**
"Application-layer logging is like security guards at the main entrance. They check everyone who comes through the front door. But what about side doors? Security cameras (driver layer) watch all entrances. Motion sensors (native layer) detect any movement anywhere in the building."

**Timing:** 2 minutes

---

### SLIDE 2.5: PostgreSQL Wire Protocol
**Title:** How PostgreSQL Communication Works

**Visual:**
- Protocol stack diagram:
  - Application
  - pg Library
  - Wire Protocol
  - PostgreSQL Server

**Content:**

```
Application → pg Library → Wire Protocol → PostgreSQL Server
     │             │             │               │
     │             │             │               │
  Business      Driver      Network        Database
  Logic         Layer       Layer          Engine
```

**What We Intercept:**
- **Application**: Queries through AuditedPool
- **Driver**: Queries at the pg library level
- **Native**: Queries at the PostgreSQL server level

**Speaker Notes:**
"The `pg` library communicates with PostgreSQL using a custom wire protocol. We can intercept queries at multiple points in this stack. Driver-level interception is at the `pg` library level—before the query is even sent to the database."

**Timing:** 3 minutes

---

## Module 2.2: JavaScript Driver Interception (25 minutes)

### SLIDE 2.6: pg Driver Interceptor
**Title:** Building the DriverInterceptor

**Visual:**
- Code block with DriverInterceptor class
- Key parts highlighted

**Content:**

```javascript
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
    this.install();
  }

  install() {
    if (this.db.constructor === Pool) {
      this.interceptPool();
    } else if (this.db.constructor === Client) {
      this.interceptClient(this.db);
    }
  }
}
```

**Speaker Notes:**
"The `DriverInterceptor` class wraps a `pg` Pool or Client. It stores the original query method and then installs interceptors. This is like placing security cameras at every entrance."

**Timing:** 3 minutes

---

### SLIDE 2.7: Intercepting the Pool
**Title:** Pool-Level Interception

**Visual:**
- Code block showing pool interceptor
- Flow diagram

**Content:**

```javascript
interceptPool() {
  const self = this;
  const pool = this.db;

  // Wrap the pool's query method
  pool.query = async function(...args) {
    let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text;
    let params = typeof args[0] === 'object' ? args[0]?.values : args[1];

    // Call interceptor callback
    if (self.options.onQuery) {
      await self.options.onQuery(queryText, params, 'pool');
    }

    // Log the query
    console.log(`[DRIVER INTERCEPTOR] Pool query: ${queryText}`);

    // Call original query
    return self.originalQuery(...args);
  };

  // Intercept new clients
  const originalConnect = pool.connect.bind(pool);
  pool.connect = async function(...args) {
    const client = await originalConnect(...args);
    self.interceptClient(client);
    return client;
  };
}
```

**Speaker Notes:**
"The pool-level interceptor wraps the pool's query method. Every query through the pool is intercepted. We also intercept new clients as they're created, ensuring no query escapes our monitoring."

**Timing:** 5 minutes

---

### SLIDE 2.8: Client-Level Interception
**Title:** Intercepting Individual Clients

**Visual:**
- Code block showing client interceptor
- Explanation of WeakSet for tracking

**Content:**

```javascript
interceptClient(client) {
  const self = this;
  const originalClientQuery = client.query.bind(client);

  // Track intercepted clients
  this.interceptedClients.add(client);

  client.query = async function(...args) {
    let queryText = typeof args[0] === 'string' ? args[0] : args[0]?.text;
    let params = typeof args[0] === 'object' ? args[0]?.values : args[1];

    if (self.options.onQuery) {
      await self.options.onQuery(queryText, params, 'client');
    }

    console.log(`[DRIVER INTERCEPTOR] Client query: ${queryText}`);
    return originalClientQuery(...args);
  };
}
```

**Speaker Notes:**
"Individual clients also need interception. We track intercepted clients using a `WeakSet` to avoid memory leaks. Every client's query method is wrapped just like the pool's."

**Timing:** 4 minutes

---

### SLIDE 2.9: Enhanced AuditedPool
**Title:** Combining Application + Driver Interception

**Visual:**
- Code block showing EnhancedAuditedPool
- Diagram of combined layers

**Content:**

```javascript
export class EnhancedAuditedPool extends AuditedPool {
  constructor(connectionString, options = {}) {
    super(connectionString, options);
    
    if (this.enhancedOptions.enableDriverInterception) {
      this.installDriverInterceptor();
    }
  }

  installDriverInterceptor() {
    const underlyingPool = this.getUnderlyingPool();
    this.driverInterceptor = new DriverInterceptor(underlyingPool, {
      onQuery: (queryText, params, source) => {
        // Log through the audit system
        this.logAudit({
          query_text: `[DRIVER] ${queryText}`,
          query_params: params,
          duration_ms: 0,
          user_id: 'driver-interceptor',
          user_ip: 'internal',
          status: 'INTERCEPTED'
        });
      }
    });
  }
}
```

**Speaker Notes:**
"The `EnhancedAuditedPool` extends `AuditedPool` and adds driver-level interception. Queries are now caught at two layers: application (with user context) and driver (catching everything, even raw connections)."

**Timing:** 5 minutes

---

### SLIDE 2.10: Testing Driver Interception
**Title:** Verifying Driver Interception

**Visual:**
- Test scenarios table
- Expected output

**Content:**

**Test Scenarios:**

| Test | Query Method | Intercepted? |
|------|--------------|--------------|
| 1 | Through AuditedPool | ✅ Yes (both layers) |
| 2 | Through raw connection | ✅ Yes (driver only) |
| 3 | Through direct client | ✅ Yes (driver only) |
| 4 | Deep driver call | ✅ Yes (driver only) |

**Running the Tests:**
```bash
node tests/test-driver-interception.js
```

**Speaker Notes:**
"We test all scenarios—queries through the audited pool, raw connections, direct clients, and deep driver calls. The driver interceptor should catch all of them, even those that bypass the application layer."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

## Module 2.3: Python Native Interception (25 minutes)

### SLIDE 2.11: SQLite Native Trace
**Title:** SQLite's sqlite3_trace API

**Visual:**
- Code block with trace callback
- Explanation of C-level interception

**Content:**

```python
import sqlite3

def audit_trace_callback(statement: str):
    # statement contains the fully expanded SQL
    print(f"[FOSS INTERCEPTOR] Native statement: {statement}")

conn = sqlite3.connect(":memory:")
conn.set_trace_callback(audit_trace_callback)

# Now every query will trigger the callback
conn.execute("CREATE TABLE users (id INTEGER, name TEXT)")
conn.execute("INSERT INTO users VALUES (1, 'Alice')")
conn.execute("SELECT * FROM users WHERE id = ?", (1,))
```

**Output:**
```
[FOSS INTERCEPTOR] Native statement: CREATE TABLE users (id INTEGER, name TEXT)
[FOSS INTERCEPTOR] Native statement: INSERT INTO users VALUES (1, 'Alice')
[FOSS INTERCEPTOR] Native statement: SELECT * FROM users WHERE id = 1
```

**Speaker Notes:**
"SQLite provides a native trace callback at the C level. This is the lowest-level interception possible—it catches EVERY statement before it executes, regardless of how it was sent."

**Timing:** 3 minutes

---

### SLIDE 2.12: NativeInterceptor Class
**Title:** Building the NativeInterceptor

**Visual:**
- Complete NativeInterceptor code
- Key parts highlighted

**Content:**

```python
class NativeInterceptor:
    def __init__(self, connection: sqlite3.Connection):
        self.connection = connection
        self._callback = None
        self._original_trace = None
        self._installed = False

    def set_callback(self, callback: Callable[[str], None]):
        self._callback = callback
        self._install()

    def _install(self):
        if self._installed:
            return

        def trace_callback(sql: str):
            if self._callback:
                try:
                    self._callback(sql)
                except Exception as e:
                    print(f"[NATIVE INTERCEPTOR ERROR] Callback failed: {e}")

        self.connection.set_trace_callback(trace_callback)
        self._installed = True

    def uninstall(self):
        if self._installed:
            self.connection.set_trace_callback(self._original_trace)
            self._installed = False
```

**Speaker Notes:**
"The `NativeInterceptor` class wraps SQLite's native tracing. It stores the original trace callback, installs our wrapper, and provides an `uninstall` method for cleanup."

**Timing:** 5 minutes

---

### SLIDE 2.13: AuditedNativeSQLite
**Title:** Combining Application + Native Interception

**Visual:**
- Code block showing AuditedNativeSQLite
- Diagram of combined layers

**Content:**

```python
class AuditedNativeSQLite:
    def __init__(self, db_path: str):
        self.connection = sqlite3.connect(db_path)
        self.interceptor = None

    def enable_native_interception(self):
        self.interceptor = NativeInterceptor(self.connection)
        self.interceptor.set_callback(self._native_audit_callback)

    def _native_audit_callback(self, sql: str):
        # Log to audit table
        self.connection.execute(
            "INSERT INTO native_audit_logs (sql_statement) VALUES (?)",
            (sql,)
        )
        self.connection.commit()
        print(f"[NATIVE AUDIT] {sql}")

    def execute(self, sql: str, params: tuple = ()):
        # Application-layer audit
        print(f"[APP AUDIT] Executing: {sql}")
        cursor = self.connection.execute(sql, params)
        self.connection.commit()
        return cursor
```

**Speaker Notes:**
"The `AuditedNativeSQLite` class combines both layers. Application-layer audit provides context, and native-layer interception provides complete coverage. Together, they catch all queries."

**Timing:** 5 minutes

---

### SLIDE 2.14: Testing Native Interception
**Title:** Verifying Native Interception

**Visual:**
- Test scenarios table
- Expected output

**Content:**

**Test Scenarios:**

| Test | Query Method | Intercepted? |
|------|--------------|--------------|
| 1 | Through AuditedNativeSQLite | ✅ Yes (both layers) |
| 2 | Direct connection.execute() | ✅ Yes (native only) |
| 3 | Raw C-level query | ✅ Yes (native only) |
| 4 | Multiple statements | ✅ Yes (native only) |

**Running the Tests:**
```bash
python test_native_interception.py
```

**Speaker Notes:**
"We test all scenarios—queries through the audited wrapper, direct connections, and even raw C-level queries. The native interceptor should catch all of them."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

### SLIDE 2.15: Python Verification
**Title:** Verify Your Python Implementation

**Visual:**
- Commands to run
- Expected output

**Content:**

**Run the tests:**
```bash
python test_native_interception.py
python test_audited_native_sqlite.py
```

**Expected Output:**
- All queries are intercepted at native level
- Both application and native logs exist
- Even queries that bypass the application layer are caught

**Check the logs:**
```sql
SELECT sql_statement, captured_at FROM native_audit_logs ORDER BY captured_at DESC LIMIT 10;
```

**Speaker Notes:**
"Take a few minutes to verify your native interception. Check that both layers are working and that even raw queries are being caught."

**Timing:** 5 minutes

---

### SLIDE 2.16: JavaScript vs Python Interception Comparison
**Title:** Side-by-Side Comparison

**Visual:**
- Split screen showing both implementations

**Content:**

| Aspect | JavaScript (Neon) | Python (SQLite) |
|--------|------------------|-----------------|
| **Driver/Native** | Driver-level (pg) | Native-level (sqlite3_trace) |
| **Interception Point** | Before wire protocol | At C-level |
| **Coverage** | All pg connections | All SQLite connections |
| **Performance** | Minimal overhead | Minimal overhead |
| **Implementation** | Method wrapping | Native callback |

**Speaker Notes:**
"Both implementations provide comprehensive interception, but they work differently. JavaScript intercepts at the driver level before the wire protocol. Python intercepts at the native C level. Both achieve the same goal: complete visibility."

**Timing:** 2 minutes

---

### SLIDE 2.17: Part 2 Summary
**Title:** What You've Built

**Visual:**
- Checklist of completed items
- Architecture diagram highlighting Part 2

**Content:**

**✅ JavaScript:**
- DriverInterceptor class for pg Pool and Client
- EnhancedAuditedPool combining both layers
- Multiple interception points
- Test suite verifying interception

**✅ Python:**
- NativeInterceptor using sqlite3_trace
- AuditedNativeSQLite combining layers
- C-level interception (lowest possible)
- Comprehensive test coverage

**Speaker Notes:**
"Congratulations! You now have multiple interception layers providing comprehensive coverage. Every query is captured—no matter how it reaches the database."

**Timing:** 2 minutes

---

### SLIDE 2.18: Part 2 Verification Exercise
**Title:** Verify Your Interception System

**Visual:**
- Step-by-step verification checklist

**Content:**

1. **Run JavaScript tests**: All tests should pass
2. **Run Python tests**: All tests should pass
3. **Test raw connections**: Queries through raw connections are caught
4. **Test native layer**: C-level queries are caught
5. **Check audit logs**: Both application and interception logs exist
6. **Test bypass attempts**: No query escapes capture

**If anything fails:**
- Check interceptor installation
- Verify callback registration
- Check for recursion issues
- Review error handling

**Speaker Notes:**
"Take 5 minutes to verify your entire interception system. Test raw connections, native queries, and make sure no query escapes capture."

**Timing:** 5 minutes

---

### SLIDE 2.19: Q&A (End of Part 2)
**Title:** Questions?

**Visual:**
- Open question mark
- Recap of key concepts

**Content:**

**Key Concepts:**
- Multiple interception layers for defense-in-depth
- Driver-level interception in PostgreSQL
- Native-level interception in SQLite
- Combining layers for complete coverage
- Preventing interception bypass

**Common Questions:**
- How does this affect performance?
- Can I intercept at both driver and native layers in the same system?
- What about other database systems?
- How do I prevent interception bypass?

**Speaker Notes:**
"What questions do you have about interception? What aspects of the implementation were unclear? Let's make sure everyone is comfortable before we move on."

**Timing:** 5 minutes

---

# SECTION 3: PART 3 - QUERY NORMALIZATION

## Module 3.1: Why Normalization (10 minutes)

### SLIDE 3.1: Part 3 - Real-Time Parsing & Normalization
**Title:** Making Logs Useful

**Visual:**
- Part 3 opening graphic
- "Part 3 of 5" badge

**Content:**
- **Goal:** Transform verbose SQL into compact patterns
- **Problem:** Raw logs are verbose, unique, and hard to analyze
- **Solution:** Query normalization
- **Output:** Pattern-friendly, analyzable audit logs

**Speaker Notes:**
"Welcome to Part 3! We've built audit logging and interception. But raw SQL logs are verbose and difficult to analyze. In this part, we'll transform them into compact, pattern-friendly signatures using query normalization."

**Timing:** 1 minute

---

### SLIDE 3.2: The Normalization Problem
**Title:** Raw Logs Are a Mess

**Visual:**
- Two queries side-by-side showing different values

**Content:**

**Raw Logs:**
```
1. SELECT * FROM users WHERE email = 'alice@example.com' AND age = 30;
2. SELECT * FROM users WHERE email = 'bob@example.com' AND age = 25;
```

**The Problem:**
- These are structurally identical but look completely different
- Storage is inefficient (redundant patterns)
- Analysis is difficult (can't group by pattern)
- Privacy concerns (data values in logs)

**The Solution:**
```
1. SELECT * FROM users WHERE email = '?' AND age = ?;
2. SELECT * FROM users WHERE email = '?' AND age = ?;
```

**Speaker Notes:**
"These two queries are functionally identical—they just have different values. But as raw strings, they're completely different. This makes storage inefficient, analysis difficult, and privacy a concern. Normalization solves all three."

**Timing:** 3 minutes

---

### SLIDE 3.3: What is Query Normalization?
**Title:** Stripping Literals, Revealing Patterns

**Visual:**
- Pipeline showing transformation:

```
Raw: SELECT * FROM users WHERE email = 'alice@example.com' AND age = 30;
     │
     ▼
Step 1: Remove string literals → 'alice@example.com' → '?'
Step 2: Remove numeric literals → 30 → ?
Step 3: Collapse whitespace
     │
     ▼
Normalized: SELECT * FROM users WHERE email = '?' AND age = ?;
```

**What It Does:**
1. Replaces string literals with `'?'`
2. Replaces numeric literals with `?`
3. Removes comments
4. Collapses whitespace
5. Optional: Lowercase everything

**Speaker Notes:**
"Normalization is a series of transformations. We replace literal values—strings, numbers, UUIDs—with placeholders. This reveals the underlying pattern while removing the specific values."

**Timing:** 3 minutes

---

### SLIDE 3.4: Why Normalization Matters
**Title:** The Benefits of Normalization

**Visual:**
- Four benefit icons:
  1. Compact Storage
  2. Pattern Matching
  3. Privacy Protection
  4. Attack Detection

**Content:**

| Benefit | Description | Impact |
|---------|-------------|--------|
| **Compact Storage** | Store patterns once, not every variation | 10-100x storage savings |
| **Pattern Matching** | Group identical query structures | Easy to analyze and detect |
| **Privacy Protection** | Data values are stripped | PII/PHI not stored in logs |
| **Attack Detection** | Recognize malicious patterns | SQL injection detection |
| **Performance Analysis** | Group by query type | Identify slow patterns |
| **Anomaly Detection** | Unusual patterns stand out | Detect new attack vectors |

**Speaker Notes:**
"Normalization has many benefits. It saves storage space, enables pattern matching, protects privacy, and helps detect attacks. A simple transformation with powerful results."

**Timing:** 3 minutes

---

### SLIDE 3.5: The Normalization Pipeline
**Title:** Step-by-Step Transformation

**Visual:**
- Flowchart showing each step:

```
Raw SQL
  │
  ▼
1. Remove Comments
  │
  ▼
2. String Literal Replacement ('hello' → '?')
  │
  ▼
3. Numeric Literal Replacement (123 → ?)
  │
  ▼
4. UUID Literal Replacement (uuid → '?')
  │
  ▼
5. JSON Literal Replacement ({...} → '?')
  │
  ▼
6. IN Clause Normalization (1,2,3 → ?, ?, ?)
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

**Speaker Notes:**
"The normalization pipeline is a series of transformations. Each step removes a specific type of literal or normalizes a specific pattern. The result is a compact, analyzable pattern."

**Timing:** 2 minutes

---

## Module 3.2: JavaScript Normalizer (25 minutes)

### SLIDE 3.6: QueryNormalizer Class
**Title:** Building the QueryNormalizer

**Visual:**
- Code block with class structure
- Key methods highlighted

**Content:**

```javascript
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
}
```

**Speaker Notes:**
"The `QueryNormalizer` class applies a series of transformations to SQL queries. Each transformation is a method that handles a specific type of literal or pattern."

**Timing:** 3 minutes

---

### SLIDE 3.7: String Literal Replacement
**Title:** Replacing 'String Values'

**Visual:**
- Code block showing replaceStringLiterals
- Examples with before/after

**Content:**

```javascript
replaceStringLiterals(sql) {
  // Handle single-quoted strings
  // Pattern: 'hello' → '?'
  // Pattern: 'it''s' → '?' (escaped quotes)
  let result = sql.replace(/'[^']*(?:''[^']*)*'/g, "'?'");
  
  // Handle double-quoted identifiers (don't replace)
  // We temporarily mark them and restore later
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
```

**Examples:**
```javascript
normalize("SELECT * FROM users WHERE email = 'alice@example.com'");
// → "SELECT * FROM users WHERE email = '?'"

normalize("SELECT * FROM users WHERE name = 'O''Brien'");
// → "SELECT * FROM users WHERE name = '?'"
```

**Speaker Notes:**
"String literals are replaced with `'?'`. This includes normal strings, strings with escaped quotes, and even strings with escape sequences. We're careful not to replace double-quoted identifiers."

**Timing:** 4 minutes

---

### SLIDE 3.8: Numeric Literal Replacement
**Title:** Replacing Numbers

**Visual:**
- Code block showing replaceNumericLiterals
- Examples with before/after

**Content:**

```javascript
replaceNumericLiterals(sql) {
  // Match: 123, 123.45, 1.23e+4, -123
  return sql.replace(/\b-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b/g, '?');
}
```

**Examples:**
```javascript
normalize("SELECT * FROM products WHERE price > 100 AND stock < 50");
// → "SELECT * FROM products WHERE price > ? AND stock < ?"

normalize("SELECT * FROM users WHERE id = -123");
// → "SELECT * FROM users WHERE id = ?"

normalize("SELECT * FROM sales WHERE amount = 1.23e+4");
// → "SELECT * FROM sales WHERE amount = ?"
```

**Speaker Notes:**
"Numeric literals—integers, decimals, and scientific notation—are replaced with `?`. This catches all variations of numbers while preserving the structure."

**Timing:** 3 minutes

---

### SLIDE 3.9: IN Clause Normalization
**Title:** Normalizing IN Clauses

**Visual:**
- Code block showing normalizeInClauses
- Examples with before/after

**Content:**

```javascript
normalizeInClauses(sql) {
  // Find IN (1, 2, 3) and normalize to IN (?, ?, ?)
  return sql.replace(/\bIN\s*\(([^)]*)\)/gi, (match, contents) => {
    const items = contents.split(',').filter(item => item.trim().length > 0);
    if (items.length > 1) {
      const placeholders = items.map(() => '?').join(', ');
      return `IN (${placeholders})`;
    }
    return match;
  });
}
```

**Examples:**
```javascript
normalize("SELECT * FROM users WHERE id IN (1, 2, 3, 4, 5)");
// → "SELECT * FROM users WHERE id IN (?, ?, ?, ?, ?)"

normalize("SELECT * FROM users WHERE id IN (1)");
// → "SELECT * FROM users WHERE id IN (1)"  // Not normalized for single item
```

**Speaker Notes:**
"IN clauses with multiple values are normalized to a consistent number of placeholders. This makes the pattern consistent regardless of how many values are in the list."

**Timing:** 3 minutes

---

### SLIDE 3.10: Whitespace Normalization
**Title:** Cleaning Up Formatting

**Visual:**
- Code block showing collapseWhitespace
- Examples with before/after

**Content:**

```javascript
collapseWhitespace(sql) {
  return sql
    .replace(/\s+/g, ' ')          // Multiple spaces → single space
    .replace(/\s*\(\s*/g, '(')     // Remove spaces around (
    .replace(/\s*\)\s*/g, ')')     // Remove spaces around )
    .replace(/\s*,\s*/g, ', ')     // Normalize comma spacing
    .replace(/\s*=\s*/g, ' = ')    // Normalize = spacing
    .trim();
}
```

**Examples:**
```javascript
normalize("SELECT\n  *\nFROM\n  users\nWHERE\n  id = 123");
// → "SELECT * FROM users WHERE id = ?"

normalize("SELECT * FROM users WHERE id=123 AND name='Alice'");
// → "SELECT * FROM users WHERE id = ? AND name = '?'"
```

**Speaker Notes:**
"Whitespace normalization collapses multiple spaces, removes unnecessary whitespace around parentheses and operators, and creates a consistent format. This makes pattern matching reliable."

**Timing:** 3 minutes

---

### SLIDE 3.11: Fingerprinting
**Title:** Generating Query Fingerprints

**Visual:**
- Code block showing fingerprint method
- Explanation of SHA-256

**Content:**

```javascript
fingerprint(normalized) {
  const crypto = require('crypto');
  return crypto
    .createHash('sha256')
    .update(normalized)
    .digest('hex')
    .substring(0, 16);
}
```

**Examples:**
```javascript
const normalized1 = "SELECT * FROM users WHERE email = '?' AND age = ?";
const normalized2 = "SELECT * FROM users WHERE email = '?' AND age = ?";
const fp1 = normalizer.fingerprint(normalized1);  // "a1b2c3d4e5f67890"
const fp2 = normalizer.fingerprint(normalized2);  // "a1b2c3d4e5f67890"
// They match! Same structure → Same fingerprint
```

**Use Cases:**
- Group identical query patterns
- Detect structural changes
- Quick pattern matching
- Efficient storage and lookup

**Speaker Notes:**
"Fingerprinting creates a short hash of the normalized query. Identical query structures produce identical fingerprints. This makes it easy to group queries by pattern for analysis."

**Timing:** 3 minutes

---

### SLIDE 3.12: Testing JavaScript Normalizer
**Title:** Verifying Normalization

**Visual:**
- Test cases table
- Expected output

**Content:**

**Test Cases:**

| Input | Expected Output |
|-------|-----------------|
| `SELECT * FROM users WHERE id = 1` | `SELECT * FROM users WHERE id = ?` |
| `SELECT * FROM users WHERE email = 'alice@example.com'` | `SELECT * FROM users WHERE email = '?'` |
| `SELECT * FROM users WHERE id IN (1, 2, 3)` | `SELECT * FROM users WHERE id IN (?, ?, ?)` |
| `SELECT\n*FROM\nusers\nWHERE id=1` | `SELECT * FROM users WHERE id = ?` |

**Run the Tests:**
```bash
node tests/test-normalizer.js
```

**Speaker Notes:**
"Let's test our normalizer with various SQL patterns. Each test verifies that the transformation produces the expected output."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

## Module 3.3: Python Normalizer (25 minutes)

### SLIDE 3.13: Python Normalizer Class
**Title:** Building the Python Normalizer

**Visual:**
- Code block with class structure
- Key methods highlighted

**Content:**

```python
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
        self.in_clause_pattern = re.compile(
            r'\bIN\s*\(([^)]*)\)', 
            re.IGNORECASE
        )
        self.whitespace_pattern = re.compile(r'\s+')
```

**Speaker Notes:**
"The Python normalizer follows the same design as the JavaScript version. We compile regex patterns for performance, then apply transformations in sequence."

**Timing:** 3 minutes

---

### SLIDE 3.14: Python Normalization Methods
**Title:** Python Normalization Transformations

**Visual:**
- Code block showing key methods
- Examples

**Content:**

```python
def _replace_string_literals(self, sql: str) -> str:
    # Protect double-quoted identifiers
    identifiers = []
    def protect_identifier(match):
        identifiers.append(match.group(0))
        return f'__IDENTIFIER_{len(identifiers) - 1}__'
    
    protected_sql = re.sub(r'"[^"]*"', protect_identifier, sql)
    protected_sql = self.string_literal_pattern.sub("'?'", protected_sql)
    
    # Restore identifiers
    for idx, identifier in enumerate(identifiers):
        protected_sql = protected_sql.replace(f'__IDENTIFIER_{idx}__', identifier)
    
    return protected_sql

def _replace_numeric_literals(self, sql: str) -> str:
    return self.numeric_pattern.sub('?', sql)

def _collapse_whitespace(self, sql: str) -> str:
    result = self.whitespace_pattern.sub(' ', sql)
    result = result.replace(' (', '(')
    result = result.replace('( ', '(')
    result = result.replace(' )', ')')
    result = result.replace(') ', ')')
    result = re.sub(r'\s*=\s*', ' = ', result)
    return result.strip()
```

**Speaker Notes:**
"The Python methods are similar to JavaScript, using Python's regex syntax. Each method handles a specific transformation step."

**Timing:** 5 minutes

---

### SLIDE 3.15: Python Testing
**Title:** Testing Python Normalizer

**Visual:**
- Test cases table
- Expected output

**Content:**

**Test Cases:**

| Input | Expected Output |
|-------|-----------------|
| `SELECT * FROM users WHERE id = 1` | `SELECT * FROM users WHERE id = ?` |
| `SELECT * FROM users WHERE email = 'alice@example.com'` | `SELECT * FROM users WHERE email = '?'` |
| `SELECT * FROM users WHERE id IN (1, 2, 3)` | `SELECT * FROM users WHERE id IN (?, ?, ?)` |

**Run the Tests:**
```bash
python test_normalizer.py
```

**Expected Output:**
```
🧪 Testing Query Normalizer...

📝 Test 1:
   Raw:   SELECT * FROM users WHERE id = 1
   Norm:  SELECT * FROM users WHERE id = ?
   ✅ PASS
```

**Speaker Notes:**
"Let's test our Python normalizer with various SQL patterns. Each test verifies the transformation produces the expected output."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

### SLIDE 3.16: Enhanced Audit with Normalization
**Title:** Storing Normalized Queries

**Visual:**
- Extended audit table schema
- Code block showing normalized audit

**Content:**

**Extended Audit Table:**
```sql
ALTER TABLE dam_audit_logs 
ADD COLUMN normalized_query TEXT,
ADD COLUMN query_fingerprint VARCHAR(32),
ADD COLUMN placeholder_count INTEGER;
```

**JavaScript Integration:**
```javascript
// In logAudit()
const normalizedQuery = this.normalizer.normalize(rawQuery);
const fingerprint = this.normalizer.fingerprint(normalizedQuery);
const placeholderCount = this.normalizer.countPlaceholders(normalizedQuery);

await client.query(
  `INSERT INTO dam_audit_logs 
   (query_text, normalized_query, query_fingerprint, placeholder_count, ...)
   VALUES ($1, $2, $3, $4, ...)`,
  [rawQuery, normalizedQuery, fingerprint, placeholderCount, ...]
);
```

**Speaker Notes:**
"Now we extend our audit table to store normalized queries, fingerprints, and placeholder counts. This enables pattern analysis and efficient storage."

**Timing:** 5 minutes

---

### SLIDE 3.17: Pattern Analysis
**Title:** Analyzing Query Patterns

**Visual:**
- Query patterns table
- Code block showing analysis

**Content:**

**Query Pattern Analysis:**
```javascript
async getQueryPatterns(limit = 50) {
  const result = await this.query(`
    SELECT 
      query_fingerprint,
      normalized_query,
      placeholder_count,
      COUNT(*) as occurrence_count,
      AVG(duration_ms) as avg_duration_ms,
      COUNT(DISTINCT user_id) as distinct_users
    FROM dam_audit_logs
    WHERE normalized_query IS NOT NULL
    GROUP BY query_fingerprint, normalized_query, placeholder_count
    ORDER BY occurrence_count DESC
    LIMIT $1
  `, [limit], { id: 'system', ip: 'internal' });
  return result.rows;
}
```

**Example Output:**
```
Fingerprint: a1b2c3d4 | Pattern: SELECT * FROM users WHERE id = ? | Count: 1,234
Fingerprint: e5f6g7h8 | Pattern: INSERT INTO logs (msg) VALUES (?) | Count: 45,678
Fingerprint: i9j0k1l2 | Pattern: UPDATE products SET stock = ? | Count: 890
```

**Speaker Notes:**
"With normalized queries stored, we can analyze patterns. This shows us which query structures are most common, how long they take, and which users are executing them."

**Timing:** 3 minutes

---

### SLIDE 3.18: Part 3 Summary
**Title:** What You've Built

**Visual:**
- Checklist of completed items
- Architecture diagram highlighting Part 3

**Content:**

**✅ JavaScript:**
- QueryNormalizer class with comprehensive transformations
- String, numeric, UUID, and JSON literal replacement
- IN clause normalization
- Fingerprint generation for pattern matching
- Structural comparison for analysis

**✅ Python:**
- QueryNormalizer class with all features
- Regex-based literal replacement
- Pattern grouping and analysis
- Enhanced audit with normalized storage

**Speaker Notes:**
"Congratulations! You now have powerful query normalization that transforms verbose SQL into analyzable patterns. This enables efficient storage, pattern matching, and attack detection."

**Timing:** 2 minutes

---

### SLIDE 3.19: Part 3 Verification Exercise
**Title:** Verify Your Normalization System

**Visual:**
- Step-by-step verification checklist

**Content:**

1. **Run JavaScript tests**: All tests should pass
2. **Run Python tests**: All tests should pass
3. **Test string literals**: 'hello' → '?' 
4. **Test numeric literals**: 123 → ?
5. **Test IN clauses**: (1,2,3) → (?, ?, ?)
6. **Test fingerprints**: Same structure = same fingerprint
7. **Check audit table**: Normalized queries stored

**If anything fails:**
- Check regex patterns
- Verify string literal handling
- Test edge cases (escaped quotes, scientific notation)
- Review whitespace normalization

**Speaker Notes:**
"Take 5 minutes to verify your normalization system. Test all transformation types and check that normalized queries are stored in the audit table."

**Timing:** 5 minutes

---

### SLIDE 3.20: Q&A (End of Part 3)
**Title:** Questions?

**Visual:**
- Open question mark
- Recap of key concepts

**Content:**

**Key Concepts:**
- Query normalization transforms verbose SQL into patterns
- Replaces literal values with placeholders
- Enables efficient storage and pattern matching
- Protects privacy by stripping data values
- Fingerprints enable fast pattern grouping

**Common Questions:**
- What about non-standard SQL syntax?
- How does this handle comments?
- Can I customize the normalization rules?
- What about performance overhead?

**Speaker Notes:**
"What questions do you have about normalization? What aspects of the implementation were unclear? Let's make sure everyone is comfortable before we move on."

**Timing:** 5 minutes

---

# SECTION 4: PART 4 - THREAT DETECTION

## Module 4.1: Why Threat Detection (10 minutes)

### SLIDE 4.1: Part 4 - Behavioral Rules & SQL Injection Detection
**Title:** Active Defense

**Visual:**
- Part 4 opening graphic
- "Part 4 of 5" badge

**Content:**
- **Goal:** Build a rule engine that blocks threats in real-time
- **Problem:** Detecting threats requires analyzing patterns
- **Solution:** Pattern matching + heuristic analysis
- **Output:** Real-time threat detection and blocking

**Speaker Notes:**
"Welcome to Part 4! We've built audit logging, interception, and normalization. Now we're going to actively defend against threats. Our detection engine will analyze every query and block malicious patterns in real-time."

**Timing:** 1 minute

---

### SLIDE 4.2: The Security Checkpoint Analogy
**Title:** Like Airport Security

**Visual:**
- Airport security checkpoint with:
  - X-ray machine (normalization)
  - Security guard (pattern matching)
  - Behavioral profiler (heuristics)

**Content:**

```
┌─────────────────────────────────────────────────────────────┐
│  Airport Security Checkpoint                               │
│                                                             │
│  Passenger (Query) → X-Ray (Normalization) →               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Security Guard (Pattern Matching)                  │   │
│  │ - Looks for known threats (weapons, explosives)   │   │
│  │ - Matches signatures of dangerous items           │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Behavioral Profiler (Heuristics)                   │   │
│  │ - Looks for suspicious behavior                    │   │
│  │ - Flags anomalies and unusual patterns            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Action: Allow or Block                                    │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"Think of our threat detection engine like airport security. Every passenger (query) goes through the X-ray machine (normalization). Then security guards (pattern matching) look for known threats. Behavioral profilers (heuristics) flag suspicious behavior. Together, they decide whether to allow or block."

**Timing:** 3 minutes

---

### SLIDE 4.3: Types of Threats We Detect
**Title:** What We're Looking For

**Visual:**
- Three categories with examples:
  1. SQL Injection
  2. Dangerous DDL
  3. Suspicious Patterns

**Content:**

| Threat Type | Examples | Detection Method |
|-------------|----------|------------------|
| **SQL Injection** | OR 1=1, UNION SELECT, --, ; DROP TABLE | Pattern matching |
| **Dangerous DDL** | DROP TABLE, TRUNCATE, ALTER | Pattern matching |
| **Privilege Escalation** | GRANT, REVOKE | Pattern matching |
| **Data Exfiltration** | Large SELECTs, sensitive tables | Heuristics |
| **Brute Force** | High query frequency | Frequency analysis |
| **Sensitive Access** | Passwords, PII tables | Heuristics |

**Speaker Notes:**
"Our detection engine looks for four types of threats. SQL injection is the most common. Dangerous DDL can destroy data. Suspicious patterns like brute force or sensitive table access indicate potential breaches."

**Timing:** 3 minutes

---

### SLIDE 4.4: Pattern Matching vs. Heuristics
**Title:** Two Approaches to Detection

**Visual:**
- Split screen comparing both methods

**Content:**

```
┌─────────────────────────────────────────────────────────────┐
│  PATTERN MATCHING                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Looks for known attack signatures                │   │
│  │ • Fast, reliable, low false positives              │   │
│  │ • Can't detect unknown attacks                    │   │
│  │ • Example: OR 1=1 → SQL injection                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  HEURISTICS                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ • Looks for suspicious behavior                    │   │
│  │ • Flexible, can detect new threats                 │   │
│  │ • May have false positives                         │   │
│  │ • Example: Accessing "passwords" table            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"We use both pattern matching and heuristics. Pattern matching is fast and reliable for known attacks. Heuristics catch new attacks and suspicious behavior that pattern matching would miss."

**Timing:** 3 minutes

---

### SLIDE 4.5: The Detection Pipeline
**Title:** From Query to Action

**Visual:**
- Flowchart showing the complete detection pipeline

**Content:**

```
Query
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. Normalization (Part 3)                                  │
│    - Reveals the structural pattern                        │
└─────────────────────────────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Pattern Matching                                        │
│    - Check against known attack signatures                │
│    - Each match adds to threat score                      │
└─────────────────────────────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Heuristic Analysis                                     │
│    - Check for suspicious behavior                        │
│    - Sensitive tables, large IN clauses, etc.            │
└─────────────────────────────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Frequency Analysis                                     │
│    - Check query volume per user                          │
│    - Detect brute force attempts                          │
└─────────────────────────────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Threat Scoring                                         │
│    - Calculate total threat score                         │
│    - Determine threat level (LOW → CRITICAL)             │
└─────────────────────────────────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Action Determination                                   │
│    - Based on score and rule types                        │
│    - BLOCK, WARN, LOG, or ALLOW                          │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"The detection pipeline has six steps. Normalization reveals the pattern. Pattern matching and heuristics identify threats. Frequency analysis detects volume-based attacks. Threat scoring quantifies the risk. Action determination decides what to do."

**Timing:** 2 minutes

---

## Module 4.2: JavaScript Threat Detector (30 minutes)

### SLIDE 4.6: ThreatDetector Class
**Title:** Building the ThreatDetector

**Visual:**
- Code block with class structure
- Key components highlighted

**Content:**

```javascript
export class ThreatDetector {
  constructor(options = {}) {
    this.options = {
      enablePatternMatching: true,
      enableHeuristics: true,
      enableThreatScoring: true,
      logAllDetections: true,
      ...options
    };
    
    // Initialize normalizer
    this.normalizer = new QueryNormalizer({
      caseInsensitive: true,
      preserveComments: false,
      normalizeInClauses: true
    });
    
    // Threat rules
    this.rules = [];
    this.loadDefaultRules();
    
    // Sensitive tables
    this.sensitiveTables = [
      'users', 'passwords', 'credentials', 'secrets',
      'credit_cards', 'payment', 'banking', 'financial'
    ];
    
    // Whitelist for safe queries
    this.whitelist = [];
    this.loadDefaultWhitelist();
  }
}
```

**Speaker Notes:**
"The `ThreatDetector` class has several components: a normalizer, a set of rules, a list of sensitive tables, and a whitelist. Each contributes to the detection process."

**Timing:** 3 minutes

---

### SLIDE 4.7: Default Security Rules
**Title:** The Threat Rules

**Visual:**
- Table of rules with severity and action
- Code block showing rule definition

**Content:**

```javascript
loadDefaultRules() {
  // SQL Injection
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
  
  // DDL Operations
  this.addRule({
    id: 'ddl_drop_table',
    name: 'DROP TABLE Attempt',
    category: ThreatCategory.DDL_OPERATION,
    severity: ThreatLevel.CRITICAL,
    type: RuleType.BLOCK,
    pattern: /DROP\s+TABLE/i,
    description: 'Detects DROP TABLE operations'
  });
}
```

**Speaker Notes:**
"We define rules for each threat pattern. Each rule has a unique ID, a name, a category, a severity level, an action type, and a regex pattern. The engine checks every query against these rules."

**Timing:** 5 minutes

---

### SLIDE 4.8: The analyze() Method
**Title:** The Heart of Detection

**Visual:**
- Code block showing analyze method
- Flow diagram

**Content:**

```javascript
analyze(query, context = {}) {
  // 1. Normalize query
  const normalized = this.normalizer.normalize(query);
  
  // 2. Check whitelist
  if (this.isWhitelisted(query)) {
    return { threatDetected: false, whitelisted: true };
  }
  
  const findings = [];
  let totalScore = 0;
  
  // 3. Pattern matching
  if (this.options.enablePatternMatching) {
    for (const rule of this.rules) {
      if (rule.pattern && rule.pattern.test(query)) {
        const severityScore = this.getSeverityScore(rule.severity);
        totalScore += severityScore;
        findings.push({ rule, matched: true, score: severityScore });
      }
    }
  }
  
  // 4. Heuristics
  if (this.options.enableHeuristics) {
    const heuristicFindings = this.runHeuristics(query, normalized, context);
    findings.push(...heuristicFindings);
    totalScore += heuristicFindings.reduce((sum, f) => sum + f.score, 0);
  }
  
  // 5. Frequency analysis
  if (this.options.enableThreatScoring) {
    const freqFindings = this.analyzeFrequency(query, context);
    findings.push(...freqFindings);
    totalScore += freqFindings.reduce((sum, f) => sum + f.score, 0);
  }
  
  // 6. Determine threat level
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
```

**Speaker Notes:**
"The `analyze` method is the core of the detector. It normalizes the query, checks the whitelist, runs pattern matching and heuristics, analyzes frequency, calculates a threat score, and determines the threat level."

**Timing:** 7 minutes

---

### SLIDE 4.9: Heuristic Analysis
**Title:** Detecting Suspicious Behavior

**Visual:**
- Code block showing runHeuristics
- Examples of heuristic findings

**Content:**

```javascript
runHeuristics(query, normalized, context) {
  const findings = [];
  
  // Check for sensitive table access
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
  
  // Check for large IN clause (potential brute force)
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
            description: `IN clause with ${values.length} values`
          },
          matched: true,
          score: this.getSeverityScore(ThreatLevel.MEDIUM)
        });
      }
    }
  }
  
  // Check for time-based injection
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
```

**Speaker Notes:**
"Heuristic analysis looks for suspicious behavior that might not match a specific attack pattern. Accessing sensitive tables, using large IN clauses, or using time-based injection functions are all suspicious."

**Timing:** 5 minutes

---

### SLIDE 4.10: Frequency Analysis
**Title:** Detecting Brute Force

**Visual:**
- Code block showing analyzeFrequency
- Explanation of history tracking

**Content:**

```javascript
analyzeFrequency(query, context) {
  const findings = [];
  const key = `${context.userId || 'unknown'}:${context.ip || 'unknown'}`;
  const now = Date.now();
  
  if (!this.detectionHistory.has(key)) {
    this.detectionHistory.set(key, []);
  }
  
  const history = this.detectionHistory.get(key);
  history.push(now);
  
  // Clean old entries (older than 1 minute)
  const oneMinuteAgo = now - 60000;
  while (history.length > 0 && history[0] < oneMinuteAgo) {
    history.shift();
  }
  
  // Check for brute force (>100 queries in 1 minute)
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
```

**Speaker Notes:**
"Frequency analysis tracks the number of queries per user per time period. If a user makes more than 100 queries in a minute, it's likely a brute force attempt. This catches attacks that would otherwise be missed."

**Timing:** 4 minutes

---

### SLIDE 4.11: Threat Scoring
**Title:** Quantifying the Risk

**Visual:**
- Table showing severity scores
- Code block showing score calculation

**Content:**

**Severity Scores:**

| Severity | Score |
|----------|-------|
| LOW | 1 |
| MEDIUM | 5 |
| HIGH | 10 |
| CRITICAL | 25 |

**Threat Level Calculation:**

```javascript
getSeverityScore(severity) {
  const scores = {
    LOW: 1,
    MEDIUM: 5,
    HIGH: 10,
    CRITICAL: 25
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
```

**Example:**
- Tautology: +10
- Comment injection: +10
- Sensitive table access: +5
- Total: 25 → CRITICAL

**Speaker Notes:**
"Each finding contributes to a total threat score. The score determines the threat level: LOW (1), MEDIUM (5), HIGH (10), or CRITICAL (25). This helps prioritize responses."

**Timing:** 3 minutes

---

### SLIDE 4.12: Integration with AuditedPool
**Title:** Secure Audited Pool

**Visual:**
- Code block showing SecureAuditedPool
- Integration diagram

**Content:**

```javascript
export class SecureAuditedPool extends NormalizedAuditedPool {
  constructor(connectionString, options = {}) {
    super(connectionString, options);
    this.detector = new ThreatDetector(options.threatDetectorOptions);
    this.blockAction = options.blockAction || 'THROW';
  }

  async query(text, params = [], userContext = {}) {
    const detection = this.detector.analyze(text, userContext);
    const action = this.detector.determineAction(detection);
    
    if (action === 'BLOCK') {
      const error = new Error(`[SECURITY] Query blocked: ${text}`);
      error.detection = detection;
      error.findings = detection.findings;
      throw error;
    }
    
    // Execute query normally
    return super.query(text, params, userContext);
  }
}
```

**Speaker Notes:**
"The `SecureAuditedPool` extends `NormalizedAuditedPool` and adds threat detection. Every query is analyzed before execution. If a threat is detected, the query is blocked and an error is thrown."

**Timing:** 4 minutes

---

### SLIDE 4.13: Testing Threat Detection
**Title:** Verifying Detection

**Visual:**
- Test cases table
- Expected output

**Content:**

**Test Cases:**

| Query | Should Detect? | Why |
|-------|----------------|-----|
| `SELECT * FROM users WHERE id = 1` | ❌ | Normal query |
| `SELECT * FROM users WHERE email = '' OR 1=1 --'` | ✅ | SQL injection |
| `SELECT * FROM users UNION SELECT * FROM admins` | ✅ | Union injection |
| `DROP TABLE users` | ✅ | DDL operation |
| `SELECT * FROM passwords` | ✅ | Sensitive table |
| `SELECT SLEEP(5) FROM users` | ✅ | Time-based injection |

**Run the Tests:**
```bash
node tests/test-threat-detector.js
```

**Speaker Notes:**
"Let's test our threat detector with various SQL patterns. Normal queries should pass, while malicious queries should be blocked."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

## Module 4.3: Python Threat Detector (25 minutes)

### SLIDE 4.14: Python ThreatDetector
**Title:** Building the Python Threat Detector

**Visual:**
- Code block with class structure
- Key components highlighted

**Content:**

```python
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
            'customers', 'employees', 'credit_cards', 'payment'
        }
        
        self.whitelist: List[re.Pattern] = []
        self._load_default_whitelist()
```

**Speaker Notes:**
"The Python threat detector follows the same design as the JavaScript version. It includes a normalizer, rules, sensitive tables, and a whitelist."

**Timing:** 3 minutes

---

### SLIDE 4.15: Python Threat Rules
**Title:** Defining Rules in Python

**Visual:**
- Code block showing ThreatRule class
- Rule definitions

**Content:**

```python
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

# Rule definitions
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
```

**Speaker Notes:**
"Python rules are defined as `ThreatRule` objects. Each rule has a unique ID, a name, a category, a severity, a type, and a regex pattern. The detector checks every query against these rules."

**Timing:** 5 minutes

---

### SLIDE 4.16: Python Integration
**Title:** Secure Audited SQLite

**Visual:**
- Code block showing SecureAuditedSQLite
- Integration diagram

**Content:**

```python
class SecureAuditedSQLite(NormalizedAuditedSQLite):
    def __init__(self, db_path: str, options: Optional[Dict[str, Any]] = None):
        super().__init__(db_path)
        self.detector = ThreatDetector(options or {})
        self.block_action = options.get('block_action', 'THROW') if options else 'THROW'

    def execute(self, sql: str, params: tuple = (),
                user_context: Dict[str, str] = None):
        user_context = user_context or {}
        
        # Analyze query
        detection = self.detector.analyze(sql, user_context)
        action = self.detector.determine_action(detection)
        
        if action == 'BLOCK':
            error_msg = f"[SECURITY] Query blocked: {sql}"
            raise sqlite3.Error(error_msg)
        
        # Execute query
        return super().execute(sql, params, user_context)
```

**Speaker Notes:**
"The `SecureAuditedSQLite` class extends `NormalizedAuditedSQLite` and adds threat detection. Every query is analyzed before execution. If a threat is detected, the query is blocked."

**Timing:** 4 minutes

---

### SLIDE 4.17: Testing Python Detection
**Title:** Verifying Python Detection

**Visual:**
- Test cases table
- Expected output

**Content:**

**Run the Tests:**
```bash
python test_threat_detector.py
```

**Expected Output:**
```
🧪 Testing Threat Detector...

📝 Test 1: Normal SELECT query
   Query: SELECT * FROM users WHERE id = 1
   Detected: ❌ No
   ✅ PASS

📝 Test 2: SQL Injection (tautology)
   Query: SELECT * FROM users WHERE email = '' OR 1=1 --'
   Detected: ✅ Yes
   Score: 20
   Level: HIGH
   Findings: 2
     - Tautology SQL Injection (HIGH)
     - Comment Injection (HIGH)
   ✅ PASS
```

**Speaker Notes:**
"Let's test our Python threat detector. Normal queries should pass, while malicious queries should be blocked."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

### SLIDE 4.18: Part 4 Summary
**Title:** What You've Built

**Visual:**
- Checklist of completed items
- Architecture diagram highlighting Part 4

**Content:**

**✅ JavaScript:**
- ThreatDetector with pattern matching and heuristics
- 15+ default rules for common attack patterns
- SQL injection detection (tautologies, union, stacked)
- DDL operation blocking (DROP, TRUNCATE, ALTER)
- Privilege escalation detection (GRANT, REVOKE)
- Threat scoring and level assignment
- SecureAuditedPool integration

**✅ Python:**
- ThreatDetector with all detection features
- ThreatRule class for rule management
- Comprehensive default rule set
- Heuristic analysis for suspicious patterns
- SecureAuditedSQLite integration

**Speaker Notes:**
"Congratulations! You now have a threat detection engine that identifies malicious queries in real-time. Every query is analyzed, scored, and either allowed or blocked."

**Timing:** 2 minutes

---

### SLIDE 4.19: Part 4 Verification Exercise
**Title:** Verify Your Detection System

**Visual:**
- Step-by-step verification checklist

**Content:**

1. **Run JavaScript tests**: All tests should pass
2. **Run Python tests**: All tests should pass
3. **Test SQL injection**: Should be detected and blocked
4. **Test DDL operations**: Should be detected and blocked
5. **Test sensitive tables**: Should be detected
6. **Test frequency analysis**: Brute force should be detected
7. **Check threat scoring**: Scores should be calculated correctly

**If anything fails:**
- Check rule definitions
- Verify regex patterns
- Test heuristic detection
- Review threat scoring logic

**Speaker Notes:**
"Take 5 minutes to verify your detection system. Test all threat types and verify that blocking works correctly."

**Timing:** 5 minutes

---

### SLIDE 4.20: Q&A (End of Part 4)
**Title:** Questions?

**Visual:**
- Open question mark
- Recap of key concepts

**Content:**

**Key Concepts:**
- Pattern matching detects known attacks
- Heuristics detect suspicious behavior
- Frequency analysis detects brute force
- Threat scoring prioritizes responses
- Secure pools integrate detection with audit

**Common Questions:**
- How do I add custom rules?
- What about false positives?
- How does this handle encrypted queries?
- Can I adjust the severity thresholds?

**Speaker Notes:**
"What questions do you have about threat detection? What aspects of the implementation were unclear? Let's make sure everyone is comfortable before we move on."

**Timing:** 5 minutes

---

# SECTION 5: PART 5 - INCIDENT RESPONSE

## Module 5.1: Why Incident Response (10 minutes)

### SLIDE 5.1: Part 5 - Automated Remediation & Incident Response Orchestration
**Title:** Taking Action

**Visual:**
- Part 5 opening graphic
- "Part 5 of 5" badge

**Content:**
- **Goal:** Turn detection into automated action
- **Problem:** Detection without response is just noise
- **Solution:** Automated incident response
- **Output:** Complete DAM system with self-defense

**Speaker Notes:**
"Welcome to Part 5! We've built detection, but detection without response is just noise. Now we'll build automated remediation and incident response that takes action when threats are detected."

**Timing:** 1 minute

---

### SLIDE 5.2: The Incident Response Lifecycle
**Title:** From Detection to Recovery

**Visual:**
- Five-phase lifecycle diagram:
  1. Detection → 2. Containment → 3. Eradication → 4. Recovery → 5. Investigation

**Content:**

```
┌─────────────────────────────────────────────────────────────┐
│                INCIDENT RESPONSE LIFECYCLE                  │
│                                                             │
│  1. DETECTION                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Threat detected by our system                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  2. CONTAINMENT                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Block query, terminate connection, isolate user    │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  3. ERADICATION                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Revoke credentials, rollback transactions           │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  4. RECOVERY                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Restore data, reconnect legitimate users           │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  5. INVESTIGATION                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Analyze incident vault, identify root cause        │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"Incident response is a lifecycle. Detection triggers containment. Containment leads to eradication. Eradication enables recovery. Recovery supports investigation. Each phase depends on the previous one."

**Timing:** 3 minutes

---

### SLIDE 5.3: The Orchestration Pattern
**Title:** Coordinating the Response

**Visual:**
- Pipeline diagram showing orchestration steps

**Content:**

```
Threat Event
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. Pre-Response Validation                                 │
│    - Verify threat is real                                │
│    - Check severity                                      │
│    - Gather context                                      │
└─────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Immediate Response                                     │
│    - Block query                                          │
│    - Terminate connection                                 │
│    - Circuit breaker activation                           │
└─────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Incident Recording                                     │
│    - Write to immutable vault                             │
│    - Create incident report                               │
│    - Generate alerts                                      │
└─────────────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Post-Response Actions                                  │
│    - Notify security team                                 │
│    - Update security rules                                │
│    - Initiate recovery                                    │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"The orchestrator coordinates the entire response. It validates the threat, executes immediate actions, records everything, and performs post-response actions. Every step is automated."

**Timing:** 3 minutes

---

### SLIDE 5.4: Response Actions
**Title:** What We Can Do

**Visual:**
- Table of actions with descriptions

**Content:**

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

**Speaker Notes:**
"We have a range of response actions, from simple blocking to full user isolation. The orchestrator chooses which actions to take based on the threat severity."

**Timing:** 3 minutes

---

### SLIDE 5.5: The Circuit Breaker Pattern
**Title:** Preventing Cascading Failures

**Visual:**
- Circuit breaker state diagram:
  - CLOSED → OPEN → HALF-OPEN

**Content:**

```
┌─────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER                          │
│                                                             │
│  CLOSED (Normal)                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Queries flow normally                              │   │
│  │ Circuit breaker is not active                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼ (Multiple threats)                │
│  OPEN (Triggered)                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ All queries are blocked                            │   │
│  │ "Fail fast" to prevent cascading failures          │   │
│  │ Expires after 5 minutes                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼ (After cooldown)                  │
│  HALF-OPEN (Testing)                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ One query is allowed through                       │   │
│  │ If successful → CLOSED                             │   │
│  │ If failed → OPEN                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"The circuit breaker prevents cascading failures. If multiple threats are detected, the circuit breaker opens, blocking ALL queries. This 'fail fast' approach prevents system overload and further damage."

**Timing:** 3 minutes

---

## Module 5.2: JavaScript Incident Response (30 minutes)

### SLIDE 5.6: IncidentResponder Class
**Title:** Building the Incident Responder

**Visual:**
- Code block with class structure
- Key components highlighted

**Content:**

```javascript
export class IncidentResponder {
  constructor(options = {}) {
    this.options = {
      vaultPath: './incident_vault.jsonl',
      notifySecurity: true,
      useCircuitBreaker: true,
      terminateConnections: true,
      revokeCredentials: false,
      cooldownPeriod: 60000,
      maxIncidentsMemory: 100,
      ...options
    };
    
    // Incident tracking
    this.incidentHistory = new Map();
    this.circuitBreakerActive = false;
    this.circuitBreakerExpiry = null;
    
    // Statistics
    this.stats = {
      totalIncidents: 0,
      criticalIncidents: 0,
      blockedQueries: 0,
      terminatedConnections: 0,
      notificationsSent: 0
    };
    
    this.initVault();
  }
}
```

**Speaker Notes:**
"The `IncidentResponder` class manages the entire incident response process. It tracks incident history, manages the circuit breaker, maintains statistics, and writes to the incident vault."

**Timing:** 3 minutes

---

### SLIDE 5.7: The handleIncident() Method
**Title:** The Orchestration Hub

**Visual:**
- Code block showing handleIncident
- Flow diagram

**Content:**

```javascript
async handleIncident(incident) {
  const timestamp = new Date().toISOString();
  const incidentId = this.generateIncidentId();
  
  console.log(`[INCIDENT RESPONDER] Handling incident ${incidentId}`);
  
  // 1. Pre-response validation
  const validationResult = await this.validateIncident(incident);
  if (!validationResult.shouldRespond) {
    return { incidentId, handled: false, reason: validationResult.reason };
  }
  
  // 2. Generate response plan
  const responsePlan = this.generateResponsePlan(incident);
  
  // 3. Execute response plan
  const responseResults = await this.executeResponsePlan(responsePlan, incident);
  
  // 4. Record incident
  const vaultEntry = await this.recordIncident(
    incidentId, timestamp, incident, responseResults
  );
  
  // 5. Update statistics
  this.updateStats(incident, responseResults);
  
  // 6. Post-response actions
  await this.postResponseActions(incident, responseResults, vaultEntry);
  
  return { incidentId, handled: true, responseResults, vaultEntry };
}
```

**Speaker Notes:**
"The `handleIncident` method orchestrates the entire response. It validates the threat, generates a response plan, executes it, records everything, updates statistics, and performs post-response actions."

**Timing:** 5 minutes

---

### SLIDE 5.8: Response Plan Generation
**Title:** The Response Plan

**Visual:**
- Code block showing generateResponsePlan
- Table of severity-based actions

**Content:**

```javascript
generateResponsePlan(incident) {
  const plan = [];
  const severity = incident.threatLevel || IncidentSeverity.LOW;
  
  // Always log incidents
  plan.push(ResponseAction.LOG_INCIDENT);
  
  // Block queries for all incidents
  plan.push(ResponseAction.BLOCK_QUERY);
  this.stats.blockedQueries++;
  
  // Severity-based actions
  if (severity === IncidentSeverity.MEDIUM ||
      severity === IncidentSeverity.HIGH ||
      severity === IncidentSeverity.CRITICAL) {
    plan.push(ResponseAction.NOTIFY_SECURITY);
  }
  
  if (severity === IncidentSeverity.HIGH) {
    if (this.options.terminateConnections) {
      plan.push(ResponseAction.TERMINATE_CONNECTION);
    }
    if (this.options.useCircuitBreaker) {
      plan.push(ResponseAction.CIRCUIT_BREAKER);
    }
  }
  
  if (severity === IncidentSeverity.CRITICAL) {
    if (this.options.terminateConnections) {
      plan.push(ResponseAction.TERMINATE_CONNECTION);
    }
    if (this.options.revokeCredentials) {
      plan.push(ResponseAction.REVOKE_CREDENTIALS);
    }
    if (this.options.useCircuitBreaker) {
      plan.push(ResponseAction.CIRCUIT_BREAKER);
    }
    plan.push(ResponseAction.ISOLATE_USER);
  }
  
  return plan;
}
```

**Speaker Notes:**
"The response plan is generated based on threat severity. LOW threats only log. MEDIUM threats also notify. HIGH threats terminate connections. CRITICAL threats revoke credentials and isolate users."

**Timing:** 5 minutes

---

### SLIDE 5.9: The Incident Vault
**Title:** Immutable Incident Storage

**Visual:**
- Code block showing recordIncident
- Vault format example

**Content:**

```javascript
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
  
  // Write to vault (append-only)
  await fs.appendFile(
    this.options.vaultPath,
    JSON.stringify(vaultEntry) + '\n'
  );
  
  return vaultEntry;
}
```

**Vault Entry Format (JSONL):**
```jsonl
{"incidentId":"INC-A1B2C3-D4E5","timestamp":"2024-01-15T10:00:00.000Z","severity":"HIGH",...}
{"incidentId":"INC-F6G7H8-I9J0","timestamp":"2024-01-15T10:00:01.000Z","severity":"CRITICAL",...}
```

**Speaker Notes:**
"The incident vault is append-only and immutable. Once written, entries can never be modified or deleted. This provides a tamper-proof record for investigations and compliance."

**Timing:** 4 minutes

---

### SLIDE 5.10: Complete DAM Integration
**Title:** Putting It All Together

**Visual:**
- Complete system diagram
- Code block showing CompleteDAMSystem

**Content:**

```javascript
export class CompleteDAMSystem {
  constructor(options = {}) {
    this.options = {
      connectionString: process.env.DATABASE_URL,
      enableAudit: true,
      enableThreatDetection: true,
      enableIncidentResponse: true,
      ...options
    };
  }

  async initialize() {
    this.auditPool = new SecureAuditedPool(
      this.options.connectionString,
      this.options.securePoolOptions
    );
    
    this.incidentResponder = new IncidentResponder(
      this.options.incidentResponderOptions
    );
  }

  async query(query, params = [], userContext = {}) {
    // Check circuit breaker
    if (this.incidentResponder.isCircuitBreakerActive()) {
      throw new Error('Circuit breaker is active');
    }
    
    try {
      return await this.auditPool.query(query, params, userContext);
    } catch (error) {
      if (error.message.includes('[SECURITY]')) {
        // Trigger incident response
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

**Speaker Notes:**
"The `CompleteDAMSystem` integrates all components: audit logging, interception, normalization, threat detection, and incident response. It's a single, coherent system that protects your database at every level."

**Timing:** 5 minutes

---

### SLIDE 5.11: Testing Incident Response
**Title:** Verifying Response

**Visual:**
- Test scenarios table
- Expected output

**Content:**

**Test Scenarios:**

| Test | Query | Expected Action |
|------|-------|-----------------|
| 1 | Normal query | Allowed, logged |
| 2 | SQL injection | Blocked, incident recorded |
| 3 | DROP TABLE | Blocked, connection terminated |
| 4 | Multiple threats | Circuit breaker activates |

**Run the Tests:**
```bash
node tests/test-complete-system.js
```

**Speaker Notes:**
"Let's test the complete system. Normal queries should execute normally. Malicious queries should be blocked. Repeated threats should trigger the circuit breaker."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

## Module 5.3: Python Incident Response (25 minutes)

### SLIDE 5.12: Python IncidentResponder
**Title:** Building the Python Incident Responder

**Visual:**
- Code block with class structure
- Key components highlighted

**Content:**

```python
class IncidentResponder:
    def __init__(self, options: Optional[Dict[str, Any]] = None):
        self.options = {
            'vault_path': options.get('vault_path', './incident_vault.jsonl'),
            'notify_security': options.get('notify_security', True),
            'use_circuit_breaker': options.get('use_circuit_breaker', True),
            'terminate_connections': options.get('terminate_connections', True),
            'revoke_credentials': options.get('revoke_credentials', False),
            'cooldown_period': options.get('cooldown_period', 60000),
            ** (options or {})
        }
        
        self.incident_history = defaultdict(lambda: {'count': 0, 'timestamp': 0})
        self.circuit_breaker_active = False
        self.circuit_breaker_expiry = None
        
        self.stats = {
            'total_incidents': 0,
            'critical_incidents': 0,
            'blocked_queries': 0,
            'terminated_connections': 0,
            'notifications_sent': 0
        }
        
        self._init_vault()
```

**Speaker Notes:**
"The Python incident responder follows the same design as the JavaScript version. It tracks incident history, manages the circuit breaker, maintains statistics, and writes to the incident vault."

**Timing:** 3 minutes

---

### SLIDE 5.13: Python Complete System
**Title:** Python Complete DAM System

**Visual:**
- Code block showing CompleteDAMSystem
- Context manager support

**Content:**

```python
class CompleteDAMSystem:
    def __init__(self, options: Optional[Dict[str, Any]] = None):
        self.options = {
            'db_path': options.get('db_path', 'dam_database.db'),
            'enable_audit': options.get('enable_audit', True),
            'enable_threat_detection': options.get('enable_threat_detection', True),
            'enable_incident_response': options.get('enable_incident_response', True),
            ** (options or {})
        }
    
    def initialize(self):
        self.secure_db = SecureAuditedSQLite(
            self.options['db_path'],
            options=self.options.get('secure_audit_options')
        )
        self.incident_responder = IncidentResponder(
            self.options.get('incident_responder_options')
        )
    
    def execute(self, sql: str, params: tuple = (),
                user_context: Optional[Dict[str, str]] = None):
        user_context = user_context or {}
        
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
    
    def __enter__(self):
        self.initialize()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.shutdown()
```

**Speaker Notes:**
"The Python complete system supports context managers for automatic initialization and shutdown. This makes it easy to use in `with` blocks."

**Timing:** 5 minutes

---

### SLIDE 5.14: Testing Python Complete System
**Title:** Verifying Python Complete System

**Visual:**
- Test scenarios table
- Expected output

**Content:**

**Run the Tests:**
```bash
python test_complete_system.py
```

**Expected Output:**
```
🧪 Testing Complete DAM System...

📝 Test 1: Normal query
  ✅ Query executed successfully

📝 Test 2: SQL Injection (should be blocked)
  ✅ Query blocked

📝 Test 3: DROP TABLE attempt (should be blocked)
  ✅ Query blocked

📝 Test 4: Sensitive table access (warning)
  ✅ Query blocked

📊 System Status:
  ...
```

**Speaker Notes:**
"Let's test the Python complete system. Normal queries should execute normally. Malicious queries should be blocked. The circuit breaker should activate on repeated threats."

**Timing:** 5 minutes

**Live Demo:** Run the tests and show the results.

---

### SLIDE 5.15: Part 5 Summary
**Title:** What You've Built

**Visual:**
- Checklist of completed items
- Complete architecture diagram

**Content:**

**✅ JavaScript:**
- IncidentResponder with multi-stage response
- CompleteDAMSystem integrating all components
- Circuit breaker pattern
- Incident vault (append-only JSONL)
- Security team notifications
- Response action orchestration
- Comprehensive test suite

**✅ Python:**
- IncidentResponder with all response capabilities
- CompleteDAMSystem with full integration
- Circuit breaker pattern
- Incident vault (append-only JSONL)
- Security team notifications
- Context manager support

**Speaker Notes:**
"Congratulations! You've built a complete Database Activity Management system from scratch. Every component is production-ready and fully integrated."

**Timing:** 2 minutes

---

### SLIDE 5.16: The Complete Architecture
**Title:** The Big Picture

**Visual:**
- Full architecture diagram with all components

**Content:**

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
                                    │
┌───────────────────────────────────▼───────────────────────────────────────┐
│                         STORAGE LAYER                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │   Audit Logs  │  Incident Vault  │  Security Rules  │  Reports     │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"This is the complete architecture. Five integrated layers work together to protect your database. Every query is audited, intercepted, normalized, detected, and responded to automatically."

**Timing:** 3 minutes

---

## SECTION 6: CONCLUSION & NEXT STEPS

### SLIDE 6.1: What You've Accomplished
**Title:** The Complete DAM System

**Visual:**
- Checklist of all components
- Success badge

**Content:**

**You've built:**
- ✅ Complete audit logging (Part 1)
- ✅ Multi-layer interception (Part 2)
- ✅ Query normalization (Part 3)
- ✅ Threat detection engine (Part 4)
- ✅ Incident response system (Part 5)

**In two languages:**
- ✅ JavaScript/Node.js + PostgreSQL
- ✅ Python + SQLite

**With:**
- ✅ 15+ detection rules
- ✅ Circuit breaker pattern
- ✅ Immutable incident vault
- ✅ Security team notifications
- ✅ Complete test coverage

**Speaker Notes:**
"Look at what you've built! A complete, production-ready Database Activity Management system. This is a significant achievement."

**Timing:** 2 minutes

---

### SLIDE 6.2: The DAM Pipeline in Action
**Title:** End-to-End Flow

**Visual:**
- Animated pipeline showing a query flowing through

**Content:**

```
Query → [Audit] → [Interception] → [Normalization] → [Detection] → [Response] → Database
  │          │           │               │              │           │
  │          ▼           ▼               ▼              ▼           ▼
  │      Logged     Captured        Patterned      Analyzed     Blocked/
  │                  All queries    "SELECT *      OR 1=1 →     Allowed
  │                                     WHERE '?'"   BLOCK
  │
  └───────────────────────────▼─────────────────────────────────────┘
                        Incident Vault (Immutable)
```

**Speaker Notes:**
"Here's the complete pipeline in action. A query flows through every layer. At each stage, something happens: logging, interception, normalization, detection, and response. Everything is recorded in the incident vault."

**Timing:** 3 minutes

---

### SLIDE 6.3: Production Readiness Checklist
**Title:** Deploying to Production

**Visual:**
- Checklist with checkboxes

**Content:**

**Pre-Deployment:**
- [ ] Database migrations prepared
- [ ] Environment variables configured
- [ ] Network security in place
- [ ] Backup strategy defined
- [ ] Monitoring configured

**Post-Deployment:**
- [ ] Health checks passing
- [ ] Audit logs writing successfully
- [ ] Threat detection working
- [ ] Incident response active
- [ ] Notifications received

**Maintenance:**
- [ ] Regular backups
- [ ] Log rotation
- [ ] Rule updates
- [ ] Incident reviews

**Speaker Notes:**
"Before deploying to production, go through this checklist. Make sure your environment is secure, your logs are writing, and your notifications are working."

**Timing:** 3 minutes

---

### SLIDE 6.4: Customization Guide
**Title:** Making It Your Own

**Visual:**
- List of customization options

**Content:**

**Add Custom Rules:**
```javascript
detector.addRule({
  id: 'custom_rule',
  name: 'Custom Detection',
  pattern: /custom_pattern/i,
  severity: 'HIGH',
  type: 'BLOCK'
});
```

**Add Sensitive Tables:**
```javascript
detector.sensitiveTables.push('api_keys', 'secrets');
```

**Adjust Thresholds:**
```javascript
const responder = new IncidentResponder({
  cooldownPeriod: 120000,  // 2 minutes
  maxIncidentsMemory: 200
});
```

**Customize Notifications:**
```javascript
responder.notifySecurityTeam = async (incident) => {
  // Your custom notification logic
  await slack.send({ text: `Incident: ${incident.id}` });
};
```

**Speaker Notes:**
"The system is designed to be extensible. Add custom rules for your specific threats. Adjust thresholds for your environment. Customize notifications for your team."

**Timing:** 3 minutes

---

### SLIDE 6.5: Scaling Considerations
**Title:** Growing Your DAM System

**Visual:**
- Scale pyramid

**Content:**

**Small Scale (<1000 req/min):**
- Standard configuration
- Single database

**Medium Scale (1000-10000 req/min):**
- Async logging
- Connection pooling
- Separate audit database

**Large Scale (>10000 req/min):**
- Sampling
- Batch processing
- Distributed architecture
- Kafka/streaming

**Speaker Notes:**
"As your application grows, your DAM system can grow with it. Start simple and add optimizations as needed."

**Timing:** 2 minutes

---

### SLIDE 6.6: Monitoring Your DAM System
**Title:** Keeping Watch

**Visual:**
- List of key metrics

**Content:**

**Key Metrics to Monitor:**
- Query volume (total, by user)
- Threat detection rate
- Incident response time
- Audit log size
- Circuit breaker status
- System health

**Alert on:**
- High threat rate
- Circuit breaker activation
- Audit log failures
- High response time
- Vault growth

**Speaker Notes:**
"Your DAM system needs monitoring too. Track key metrics and set up alerts for anomalies."

**Timing:** 2 minutes

---

### SLIDE 6.7: Continuous Improvement
**Title:** The Security Journey

**Visual:**
- PDCA cycle (Plan-Do-Check-Act)

**Content:**

```
┌─────────────────────────────────────────────────────────────┐
│                  CONTINUOUS IMPROVEMENT                     │
│                                                             │
│  1. PLAN                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Identify security gaps                            │   │
│  │ Plan improvements                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  2. DO                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Implement changes                                 │   │
│  │ Deploy updates                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  3. CHECK                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Review incident logs                              │   │
│  │ Analyze performance                               │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  4. ACT                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Adjust rules                                      │   │
│  │ Update thresholds                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Speaker Notes:**
"Security is a continuous journey, not a destination. Regularly review your DAM system, learn from incidents, and improve."

**Timing:** 3 minutes

---

### SLIDE 6.8: Future Extensions
**Title:** What's Next?

**Visual:**
- List of potential extensions

**Content:**

**Immediate Extensions:**
- Advanced analytics (ML-based detection)
- Integration with observability stacks
- Additional databases (MySQL, MongoDB)
- Enhanced response actions

**Long-Term:**
- Distributed audit logging
- Predictive threat detection
- Automated rule generation
- Zero-trust architecture

**Speaker Notes:**
"Your DAM system is extensible. Add more databases, integrate with your observability stack, and implement ML-based detection."

**Timing:** 2 minutes

---

### SLIDE 6.9: Resources
**Title:** Where to Learn More

**Visual:**
- List of resources with links

**Content:**

**Documentation:**
- OWASP SQL Injection Prevention
- PostgreSQL Security
- SQLite Security

**Community:**
- Open Source DAM Projects
- Security Forums
- Developer Communities

**Tools:**
- Prometheus/Grafana (Monitoring)
- Elastic Stack (Logs)
- Wireshark (Network Analysis)

**Speaker Notes:**
"The DAM journey doesn't end here. Explore these resources to deepen your knowledge."

**Timing:** 2 minutes

---

### SLIDE 6.10: Thank You & Q&A
**Title:** Thank You!

**Visual:**
- Thank you graphic
- Contact information

**Content:**

**You've completed the DAM Tutorial Series!**

**What you've learned:**
- Building a complete DAM system
- Audit logging, interception, normalization
- Threat detection and incident response
- Production deployment and scaling

**Your next steps:**
- Deploy to production
- Customize for your needs
- Share with your team
- Keep learning!

**Questions?**

**Speaker Notes:**
"Thank you for completing the DAM tutorial series! You now have a complete Database Activity Management system and the knowledge to deploy, customize, and maintain it. Good luck, and stay secure!"

**Timing:** 5 minutes

---

# APPENDICES 

## Appendix A: API Reference

### SLIDE A.1: JavaScript API Quick Reference
**Title:** JavaScript API Summary

**Content:**
- AuditedPool
- DriverInterceptor
- QueryNormalizer
- ThreatDetector
- IncidentResponder
- CompleteDAMSystem

### SLIDE A.2: Python API Quick Reference
**Title:** Python API Summary

**Content:**
- AuditedSQLite
- NativeInterceptor
- QueryNormalizer
- ThreatDetector
- IncidentResponder
- CompleteDAMSystem

### SLIDE A.3: Common Error Codes
**Title:** Troubleshooting

**Content:**
- Dependencies and versions
- Common configuration issues
- Database connectivity problems
- Performance troubleshooting

---

## Appendix B: Deployment Guide

### SLIDE B.1: Deployment Options
**Title:** Where to Deploy

**Content:**
- Containerized (Docker)
- Kubernetes
- Cloud platforms
- On-premise

### SLIDE B.2: Environment Variables
**Title:** Configuration

**Content:**
- All environment variables
- Required vs. optional
- Default values
- Security considerations

### SLIDE B.3: Performance Tuning
**Title:** Making It Fast

**Content:**
- Connection pool settings
- Async logging
- Batch processing
- Sampling strategies

---

## HANDOUTS & EXERCISES

### Exercise 1: Set Up Your DAM System
- Install dependencies
- Configure database
- Run tests
- Verify audit logging

### Exercise 2: Customize Detection Rules
- Add a custom rule
- Test the rule
- Deploy the change
- Monitor results

### Exercise 3: Test Incident Response
- Trigger a threat
- Verify response
- Check incident vault
- Review notifications

### Exercise 4: Production Deployment
- Configure environment
- Deploy to staging
- Run validation
- Deploy to production

---

**[END OF SLIDE DECK OUTLINE]**

---

This comprehensive slide deck outline covers every aspect of the DAM tutorial series with over 200 slides across 6 sections, 5 technical parts, and 2 appendices. Each slide includes content, visuals, speaker notes, and timing recommendations. The outline is structured to be modular—you can use individual sections for focused workshops or the entire deck for a comprehensive training program.
