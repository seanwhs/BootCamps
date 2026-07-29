# Serverless Postgres with Neon: From Zero to Production

## Primer 5: Security Best Practices for PostgreSQL

### Overview

Security isn't an afterthought—it's a fundamental part of database design. This primer covers everything you need to know to keep your PostgreSQL database secure. Think of it as learning to lock all the doors, install security cameras, and train your staff to spot suspicious activity. In today's world, a database breach can be catastrophic, so let's make sure your data stays safe.

---

### P5.1 The Security Mindset

#### Common Threats

```
Database Threats:
┌─────────────────────────────────────────────────────────────┐
│ 1. SQL Injection          → Malicious queries              │
│ 2. Data Breach            → Unauthorized data access       │
│ 3. Credential Theft       → Stolen passwords               │
│ 4. Insider Threats        → Malicious employees            │
│ 5. MITM Attacks           → Intercepted connections        │
│ 6. DoS Attacks            → Overwhelming the system        │
│ 7. Data Loss              → Accidental or malicious        │
│ 8. Compliance Violations  → GDPR, HIPAA, PCI-DSS          │
└─────────────────────────────────────────────────────────────┘
```

#### Security Principles (CIA Triad)

```
Confidentiality: Only authorized users can see data
Integrity: Data is accurate and hasn't been tampered with
Availability: Data is accessible when needed
```

---

### P5.2 Authentication & Authorization

#### User Management

**Creating and Managing Users:**

```sql
-- Create a user with a strong password
CREATE USER app_user WITH PASSWORD 'very_strong_password_123!';

-- Create a user with connection limits
CREATE USER limited_user WITH PASSWORD 'password' CONNECTION LIMIT 5;

-- Create a read-only user
CREATE USER read_only_user WITH PASSWORD 'readonly123';

-- Grant read-only access
GRANT CONNECT ON DATABASE your_db TO read_only_user;
GRANT USAGE ON SCHEMA public TO read_only_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only_user;

-- Create an admin user (use sparingly)
CREATE USER admin_user WITH PASSWORD 'admin_password' SUPERUSER;

-- Check existing users
SELECT usename, usesuper, usecreatedb, usebypassrls 
FROM pg_user;

-- Remove a user
DROP USER username;
```

#### Principle of Least Privilege

```sql
-- Bad: Giving too many permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;

-- Good: Minimal permissions needed
GRANT SELECT, INSERT, UPDATE ON products TO app_user;
GRANT SELECT, INSERT ON orders TO app_user;
GRANT SELECT, UPDATE ON users TO app_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Create role-based access
CREATE ROLE app_read_only;
CREATE ROLE app_read_write;
CREATE ROLE app_admin;

-- Grant permissions to roles
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read_only;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_read_write;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;

-- Assign users to roles
GRANT app_read_only TO read_only_user;
GRANT app_read_write TO app_user;
GRANT app_admin TO admin_user;

-- Revoke permissions
REVOKE SELECT ON products FROM read_only_user;
```

#### Row-Level Security (RLS)

RLS ensures users only see their own data:

```sql
-- Enable RLS on table
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Create policy: Users see only their orders
CREATE POLICY user_orders_policy ON orders
    FOR ALL
    USING (user_id = current_user_id())
    WITH CHECK (user_id = current_user_id());

-- Create policy: Admins see everything
CREATE POLICY admin_orders_policy ON orders
    FOR ALL
    USING (current_user_role() = 'admin');

-- Example: Get current user ID (in application)
-- This would be set per session
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID;
END;
$$ LANGUAGE plpgsql;

-- Set user ID per request (in application)
-- SELECT set_config('app.current_user_id', user_id, FALSE);

-- Test RLS
-- As user1: Only sees their orders
SELECT * FROM orders;  -- Filtered by user_id

-- As admin: Sees all orders
SELECT * FROM orders;  -- All rows

-- Disable RLS (if needed)
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
```

---

### P5.3 Connection Security

#### SSL/TLS Configuration

Always use encrypted connections:

```javascript
// Good: SSL enabled
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: true,
        ca: process.env.DB_CA_CERT,
        cert: process.env.DB_CERT,
        key: process.env.DB_KEY,
    },
});

// In Neon: SSL is enabled by default
// Connection string includes sslmode=require
// postgresql://username:password@host:port/db?sslmode=require
```

#### Connection String Best Practices

```bash
# Bad: Hardcoded credentials in code
const DATABASE_URL = 'postgresql://admin:password123@localhost:5432/mydb';

# Good: Environment variables
DATABASE_URL=postgresql://username:password@host:port/db?sslmode=require

# Best: Using secrets management
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=require

# In Node.js
const DATABASE_URL = process.env.DATABASE_URL;
```

#### Connection Pool Security

```javascript
// Secure connection pool configuration
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    
    // Connection limits (DoS protection)
    max: 20,
    min: 2,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
    
    // SSL
    ssl: {
        rejectUnauthorized: true,
    },
    
    // Statement timeout
    statement_timeout: 30000,  // 30 seconds
    
    // Idle transaction timeout
    idle_in_transaction_session_timeout: 30000,
    
    // Application name for audit logs
    application_name: 'my-production-app',
});
```

---

### P5.4 SQL Injection Prevention

SQL injection is one of the most common and dangerous vulnerabilities.

#### Parameterized Queries (Always Use These!)

```javascript
// ❌ BAD: SQL Injection vulnerable
const userId = req.params.id;
const result = await pool.query(`SELECT * FROM users WHERE id = ${userId}`);
// Attacker: userId = "1; DROP TABLE users; --"

// ✅ GOOD: Parameterized query
const userId = req.params.id;
const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);

// ✅ GOOD: Multiple parameters
const user = await pool.query(
    'SELECT * FROM users WHERE email = $1 AND status = $2',
    [email, status]
);

// ✅ GOOD: Insert with parameters
await pool.query(
    'INSERT INTO users (email, password_hash, full_name) VALUES ($1, $2, $3)',
    [email, hashedPassword, fullName]
);
```

#### Input Validation

```javascript
// Never trust user input
const email = req.body.email;

// Validate format
const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
if (!emailRegex.test(email)) {
    throw new Error('Invalid email format');
}

// Validate length
if (email.length > 255) {
    throw new Error('Email too long');
}

// Validate against known malicious patterns
const sqlInjectionPatterns = /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|TRUNCATE)\b)/i;
if (sqlInjectionPatterns.test(email)) {
    throw new Error('Suspicious input detected');
}

// Then use in parameterized query
await pool.query('SELECT * FROM users WHERE email = $1', [email]);
```

#### Stored Procedures for Extra Safety

```sql
-- Create a stored procedure for sensitive operations
CREATE OR REPLACE FUNCTION create_user(
    p_email TEXT,
    p_password_hash TEXT,
    p_full_name TEXT
)
RETURNS UUID AS $$
DECLARE
    v_user_id UUID;
BEGIN
    -- Input validation in PL/pgSQL
    IF p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format';
    END IF;
    
    -- Insert user
    INSERT INTO users (email, password_hash, full_name)
    VALUES (p_email, p_password_hash, p_full_name)
    RETURNING id INTO v_user_id;
    
    RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- Use from application
const result = await pool.query('SELECT create_user($1, $2, $3)', [
    email,
    hashedPassword,
    fullName
]);
```

---

### P5.5 Data Encryption

#### Column-Level Encryption

```sql
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt sensitive data
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    ssn_encrypted BYTEA NOT NULL,  -- Encrypted SSN
    credit_card_encrypted BYTEA,    -- Encrypted credit card
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Encrypt data on insert
INSERT INTO users (email, password_hash, ssn_encrypted) 
VALUES (
    'user@example.com',
    crypt('password123', gen_salt('bf')),
    pgp_sym_encrypt('123-45-6789', 'encryption_key_here')
);

-- Decrypt data on select
SELECT 
    email,
    pgp_sym_decrypt(ssn_encrypted, 'encryption_key_here') AS ssn
FROM users 
WHERE id = 'user-id-here';

-- For application-level encryption
-- encrypt.js
const crypto = require('crypto');

class Encryptor {
    constructor(key) {
        this.key = crypto.createHash('sha256').update(key).digest();
        this.algorithm = 'aes-256-gcm';
    }
    
    encrypt(text) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        const authTag = cipher.getAuthTag();
        return {
            encrypted,
            iv: iv.toString('hex'),
            authTag: authTag.toString('hex')
        };
    }
    
    decrypt(encrypted, iv, authTag) {
        const decipher = crypto.createDecipheriv(
            this.algorithm,
            this.key,
            Buffer.from(iv, 'hex')
        );
        decipher.setAuthTag(Buffer.from(authTag, 'hex'));
        let decrypted = decipher.update(encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    }
}

// Usage
const encryptor = new Encryptor(process.env.ENCRYPTION_KEY);
const encrypted = encryptor.encrypt('sensitive_data');
const decrypted = encryptor.decrypt(encrypted.encrypted, encrypted.iv, encrypted.authTag);
```

#### Transparent Data Encryption (TDE)

```sql
-- In Neon, data is encrypted at rest automatically
-- For additional security:

-- 1. Encrypt backups
pg_dump -d "$DATABASE_URL" | gpg --encrypt --recipient backup@example.com > backup.sql.gpg

-- 2. Encrypt sensitive columns with application keys
ALTER TABLE users ADD COLUMN email_encrypted BYTEA;

UPDATE users 
SET email_encrypted = pgp_sym_encrypt(email, 'application_key');

ALTER TABLE users DROP COLUMN email;
```

---

### P5.6 Audit Logging

#### Database Audit Trail

```sql
-- Create audit table
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    record_id TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    user_id UUID,
    user_ip TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (
        table_name,
        operation,
        record_id,
        old_data,
        new_data,
        user_id,
        user_ip
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(OLD.id::text, NEW.id::text),
        CASE WHEN TG_OP IN ('DELETE', 'UPDATE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        current_user_id(),
        inet_client_addr()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to sensitive tables
CREATE TRIGGER audit_users
    BEFORE INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_orders
    BEFORE INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();

-- Query audit trail
SELECT 
    table_name,
    operation,
    record_id,
    user_id,
    created_at,
    new_data
FROM audit_log
WHERE table_name = 'users'
  AND operation = 'UPDATE'
ORDER BY created_at DESC
LIMIT 100;
```

#### Application Audit Logging

```javascript
// Express middleware for audit logging
app.use((req, res, next) => {
    const startTime = Date.now();
    
    // Store original end function
    const originalEnd = res.end;
    
    // Override end function
    res.end = function(chunk, encoding) {
        const duration = Date.now() - startTime;
        
        // Log to database
        const logData = {
            method: req.method,
            path: req.path,
            status_code: res.statusCode,
            duration_ms: duration,
            user_id: req.user?.id,
            ip: req.ip,
            user_agent: req.headers['user-agent'],
        };
        
        // Async log (don't block response)
        pool.query(
            'INSERT INTO api_audit_log (method, path, status_code, duration_ms, user_id, ip, user_agent) VALUES ($1, $2, $3, $4, $5, $6, $7)',
            Object.values(logData)
        ).catch(err => console.error('Audit log failed:', err));
        
        // Call original end
        originalEnd.call(this, chunk, encoding);
    };
    
    next();
});

-- Create audit table
CREATE TABLE api_audit_log (
    id BIGSERIAL PRIMARY KEY,
    method VARCHAR(10),
    path TEXT,
    status_code INTEGER,
    duration_ms INTEGER,
    user_id UUID,
    ip INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast queries
CREATE INDEX idx_api_audit_log_user_id ON api_audit_log(user_id);
CREATE INDEX idx_api_audit_log_created_at ON api_audit_log(created_at DESC);
CREATE INDEX idx_api_audit_log_path ON api_audit_log(path);
```

---

### P5.7 Backup Security

#### Encrypted Backups

```bash
#!/bin/bash
# Secure backup script

# Load encryption key from environment
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# Create encrypted backup
pg_dump -d "$DATABASE_URL" --format=custom | \
gpg --symmetric --cipher-algo AES256 --batch --passphrase "$ENCRYPTION_KEY" > \
backup_$(date +%Y%m%d).dump.gpg

# Upload to secure storage (AWS S3 with encryption)
aws s3 cp backup_$(date +%Y%m%d).dump.gpg \
s3://my-secure-bucket/backups/ \
--sse AES256

# Restore from encrypted backup
gpg --decrypt --batch --passphrase "$ENCRYPTION_KEY" backup.dump.gpg | \
pg_restore -d "$DATABASE_URL"
```

---

### P5.8 Security Checklist

#### Deployment Checklist

**Authentication:**
- [ ] All users have strong passwords
- [ ] Minimum privilege principle applied
- [ ] RLS policies implemented for sensitive data
- [ ] Application users are non-superuser
- [ ] Default accounts removed/disabled

**Connection Security:**
- [ ] SSL/TLS enforced for all connections
- [ ] Connection strings stored securely
- [ ] Connection limits configured
- [ ] Statement timeouts set

**Data Protection:**
- [ ] Sensitive data encrypted at rest
- [ ] Sensitive data encrypted in transit
- [ ] PII columns encrypted
- [ ] Backups encrypted

**Monitoring:**
- [ ] Audit logging enabled
- [ ] Suspicious activity alerts configured
- [ ] Login failures monitored
- [ ] Unauthorized access attempts logged

**Application:**
- [ ] Parameterized queries used everywhere
- [ ] Input validation in place
- [ ] SQL injection prevention tested
- [ ] No hardcoded credentials

**Compliance:**
- [ ] GDPR compliance (if applicable)
- [ ] PCI-DSS compliance (if handling cards)
- [ ] HIPAA compliance (if healthcare data)
- [ ] Data retention policies defined
- [ ] Data deletion procedures in place

#### Regular Security Audits

```sql
-- Daily security checks
SELECT 
    'Suspicious Login Attempts' AS check_name,
    COUNT(*) AS count
FROM audit_log 
WHERE table_name = 'users' 
  AND operation = 'SELECT'
  AND created_at > CURRENT_DATE - INTERVAL '1 hour'
  AND user_ip NOT IN ('127.0.0.1', '10.0.0.0/8');

-- Weekly: Check for unauthorized access
SELECT 
    usename,
    usesuper,
    usecreatedb
FROM pg_user 
WHERE usesuper = true 
   OR usecreatedb = true;

-- Weekly: Review unused accounts
SELECT 
    usename,
    usesuper,
    usecreatedb
FROM pg_user u
LEFT JOIN pg_stat_activity a ON u.usename = a.usename
WHERE a.usename IS NULL
  AND u.usename NOT IN ('postgres', 'admin');

-- Monthly: Review failed login attempts
SELECT 
    user_ip,
    COUNT(*) AS failed_attempts
FROM audit_log
WHERE operation = 'CONNECT'
  AND user_ip != 'localhost'
  AND created_at > CURRENT_DATE - INTERVAL '30 days'
GROUP BY user_ip
HAVING COUNT(*) > 100
ORDER BY failed_attempts DESC;
```

---

### P5.9 Common Vulnerabilities & Solutions

#### Vulnerability 1: SQL Injection

```javascript
// ❌ Vulnerable
const query = `SELECT * FROM users WHERE email = '${email}'`;
await pool.query(query);

// ✅ Safe
await pool.query('SELECT * FROM users WHERE email = $1', [email]);
```

#### Vulnerability 2: Weak Passwords

```sql
-- ❌ Bad: Weak password
CREATE USER app_user WITH PASSWORD 'password123';

-- ✅ Good: Strong password
CREATE USER app_user WITH PASSWORD 'X9kL#mNp&2$vQw';

-- ✅ Enforce password policies
ALTER USER app_user PASSWORD 'X9kL#mNp&2$vQw' VALID UNTIL '2024-12-31';
```

#### Vulnerability 3: Exposed Credentials

```bash
# ❌ Bad: Credentials in code
const DB_PASSWORD = 'password123';

# ✅ Good: Environment variables
const DB_PASSWORD = process.env.DB_PASSWORD;

# ❌ Bad: Credentials in logs
console.log('Connecting to:', DATABASE_URL);

# ✅ Good: Redact sensitive info
console.log('Connecting to database...');
```

#### Vulnerability 4: Missing Encryption

```sql
-- ❌ Bad: Sensitive data in plaintext
CREATE TABLE users (
    ssn TEXT,
    credit_card TEXT
);

-- ✅ Good: Encrypted data
CREATE TABLE users (
    ssn_encrypted BYTEA,
    credit_card_encrypted BYTEA
);
```

#### Vulnerability 5: Excessive Privileges

```sql
-- ❌ Bad: All privileges
GRANT ALL PRIVILEGES ON DATABASE mydb TO app_user;

-- ✅ Good: Minimal privileges
GRANT CONNECT ON DATABASE mydb TO app_user;
GRANT SELECT, INSERT, UPDATE ON products TO app_user;
GRANT SELECT ON orders TO app_user;
```

#### Vulnerability 6: Missing Audit Trails

```sql
-- ❌ Bad: No audit logging
UPDATE users SET email = 'new@email.com' WHERE id = 123;

-- ✅ Good: Audit logging (with trigger)
-- Audit trigger automatically logs all changes
```

---

### P5.10 Incident Response Plan

#### If a Breach is Suspected:

```sql
-- 1. Isolate the database (create a secure copy for investigation)
neonctl branches create --name incident-investigation --parent main;

-- 2. Export relevant logs
COPY (
    SELECT * FROM audit_log 
    WHERE created_at > '2024-01-01' 
    ORDER BY created_at DESC
) TO '/tmp/audit_log.csv' CSV HEADER;

-- 3. Check for unauthorized access
SELECT 
    usename,
    application_name,
    client_addr,
    state,
    query,
    query_start
FROM pg_stat_activity
WHERE state = 'active'
  AND client_addr NOT IN ('127.0.0.1', '::1', '10.0.0.0/8');

-- 4. Force disconnect suspicious connections
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE client_addr = 'suspicious-ip';

-- 5. Change credentials immediately
ALTER USER app_user PASSWORD 'NewStrongPassword!@#';

-- 6. Review all recent changes
SELECT * FROM audit_log 
WHERE operation IN ('INSERT', 'UPDATE', 'DELETE')
  AND table_name IN ('users', 'orders', 'payments')
  AND created_at > CURRENT_DATE - INTERVAL '7 days'
ORDER BY created_at DESC;

-- 7. Rotate encryption keys
-- Update encryption keys for all sensitive data
```

#### Communication Plan:

```
1. Internal team notification
2. Incident assessment
3. Data impact analysis
4. Legal/compliance notification
5. Customer communication (if needed)
6. System restoration
7. Post-mortem and improvements
```

---

### Summary

You now understand database security essentials:

- **Authentication**: Strong passwords, user roles
- **Authorization**: Minimum privileges, RLS
- **Connection Security**: SSL/TLS, connection limits
- **SQL Injection**: Parameterized queries, validation
- **Encryption**: Data at rest, data in transit
- **Audit Logging**: Track all changes
- **Backups**: Encrypted, secure storage
- **Monitoring**: Suspicious activity detection
- **Incident Response**: Plan for breaches

**Remember**: Security is not a one-time task—it's an ongoing process of monitoring, updating, and improving.
