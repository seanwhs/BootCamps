# Serverless Postgres with Neon: From Zero to Production

## Primer 3: Working with Neon - Serverless PostgreSQL Platform

### Overview

This primer introduces you to Neon, the serverless PostgreSQL platform that powers your e-commerce application. Think of Neon as PostgreSQL that lives in the cloud, automatically scales, and comes with superpowers like instant branching and connection pooling. If you're familiar with traditional PostgreSQL but new to Neon, or if you're new to both, this primer will get you up to speed.

---

### P3.1 What is Neon?

Neon is a fully managed, serverless PostgreSQL platform. But what does that actually mean?

#### Traditional PostgreSQL vs. Neon

**Traditional PostgreSQL Setup:**
1. Install PostgreSQL on your computer or server
2. Configure settings (memory, connections, security)
3. Manage backups manually
4. Handle scaling (add more resources, replication)
5. Apply security patches
6. Monitor performance and disk space

**Neon Setup:**
1. Create an account
2. Click "Create Database"
3. Start using it

That's it. Neon handles everything else.

#### Neon's Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Application                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Neon Control Plane                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Connection  │  │   Branch    │  │    Autoscaling      │ │
│  │   Pooling   │  │ Management  │  │     Engine          │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Storage Layer (S3)                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Pages     │  │   Branches  │  │   Backups (PITR)   │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**Key Components:**

1. **Control Plane**: Manages your database instances
2. **Compute Layer**: Runs PostgreSQL processes (autoscaling)
3. **Storage Layer**: Separates storage from compute (S3-backed)
4. **Connection Pooler**: Manages connections for serverless workloads
5. **Branch Manager**: Creates instant database copies

---

### P3.2 Getting Started with Neon

#### Creating Your Account

**Step 1: Sign Up**
```
1. Go to https://neon.tech
2. Click "Sign Up" or "Start Free"
3. Choose sign-up method:
   - GitHub (recommended)
   - Google
   - Email/Password
4. Verify your email (if using email sign-up)
```

**Step 2: Create Your First Project**
```
1. After signing in, click "Create a Project"
2. Name your project (e.g., "my-app")
3. Choose a region close to your users:
   - US East (aws-us-east-1)
   - US West (aws-us-west-2)
   - EU (aws-eu-central-1)
   - Asia Pacific (aws-ap-southeast-1)
4. Click "Create Project"
5. Wait ~10 seconds for provisioning
```

**Step 3: Get Your Connection String**
```
1. On the project dashboard, click "Connect"
2. Copy the connection string:
   postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require
3. Save this securely
4. Note: The password is shown only once!
```

---

### P3.3 Neon Connection Types

Neon provides two types of connections, and understanding the difference is crucial.

#### Direct Connection

**What it is**: A standard PostgreSQL connection directly to your database.

```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require
```

**Use when**:
- Running migrations
- Running administrative tasks
- Using tools that need direct access
- Long-running connections

#### Pooled Connection

**What it is**: A connection through Neon's connection pooler that manages connections efficiently.

```
postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/database?sslmode=require&pool_mode=transaction
```

**Pooled connection parameters**:
- `pool_mode=transaction` - Each transaction gets a fresh connection
- `pool_mode=session` - Session persists for the whole connection

**Use when**:
- Serverless functions (AWS Lambda, Vercel)
- Short-lived connections
- High connection count scenarios
- API endpoints

#### Connection Modes

```javascript
// Node.js example: Using pooled connection
const { Pool } = require('pg');

// Use pooled connection for serverless
const pool = new Pool({
    connectionString: process.env.DATABASE_POOLED_URL,
    max: 20,  // Max connections in pool
    idleTimeoutMillis: 30000,
});

// Serverless function example
exports.handler = async (event) => {
    const client = await pool.connect();
    try {
        const result = await client.query('SELECT * FROM products');
        return { statusCode: 200, body: JSON.stringify(result.rows) };
    } finally {
        client.release(); // Critical: Always release
    }
};
```

---

### P3.4 Understanding Branches

This is Neon's killer feature—instant database branching.

#### What is a Database Branch?

A branch is an instant copy of your database. Unlike traditional database copies that can take hours, Neon branches are created in seconds.

**How it works:**
```
Main Branch:    [Prod Data]
                     │
                     ▼
Create Branch:  ┌─────────────────────┐
                │  Copy-on-Write      │
                │  ┌───────────────┐  │
                │  │ Shared Blocks │  │
                │  └───────────────┘  │
                │  ┌───────────────┐  │
                │  │ New Changes   │  │ ← Only new data is stored
                │  └───────────────┘  │
                └─────────────────────┘
```

#### Branch Use Cases

**1. Development Branch**
```bash
# Create a development branch
neonctl branches create --name dev --parent main --project-id your-project-id

# Connect to dev branch
psql "$(neonctl branches get-connection-string dev --project-id your-project-id)"

# Make changes safely
-- Add new tables, test queries, experiment
CREATE TABLE test_table (...);

# Merge back to main when ready
neonctl branches merge dev --target main --project-id your-project-id
```

**2. Feature Branches**
```bash
# For each feature
neonctl branches create --name feature-payments --parent main --project-id your-project-id

# Work on feature
# Test thoroughly
# Merge when ready
neonctl branches merge feature-payments --target main --project-id your-project-id
```

**3. Preview Deployments**
```yaml
# GitHub Actions example
- name: Create Preview Database
  run: |
    PR_NUMBER=${{ github.event.pull_request.number }}
    neonctl branches create \
      --name preview-$PR_NUMBER \
      --parent main \
      --project-id $PROJECT_ID
    
    PREVIEW_URL=$(neonctl branches get-connection-string preview-$PR_NUMBER)
    echo "DATABASE_URL=$PREVIEW_URL" >> $GITHUB_ENV
```

**4. Disaster Recovery**
```bash
# Before major changes
neonctl branches create --name pre-deployment-backup --parent main --project-id your-project-id

# Make changes
# If something goes wrong:
neonctl branches create --name recovery --parent pre-deployment-backup --project-id your-project-id
```

#### Branch Management Commands

```bash
# List branches
neonctl branches list --project-id your-project-id

# Create a branch
neonctl branches create --name new-branch --parent main --project-id your-project-id

# Get branch info
neonctl branches info new-branch --project-id your-project-id

# Get connection string
neonctl branches get-connection-string new-branch --project-id your-project-id

# Merge branch
neonctl branches merge new-branch --target main --project-id your-project-id

# Delete branch
neonctl branches delete new-branch --project-id your-project-id

# Create branch from timestamp (Point-in-Time Recovery)
neonctl branches create \
  --name pitr-recovery \
  --parent main \
  --timestamp "2024-01-01T00:00:00Z" \
  --project-id your-project-id
```

---

### P3.5 Autoscaling

Neon automatically scales compute resources based on demand.

#### How Autoscaling Works

```
Usage Pattern:
    High:  ┌────────────┐
    │     │  │              │
    │  │  │  │  │           │
    ──────────────────────────
    Auto-scale: 0.25 → 1 → 2 → 4 compute units
    
    Idle:    ────────────────
    Auto-scale: Scales down to 0.25 compute units
```

#### Compute Units

| Size | vCPU | Memory | Use Case |
|------|------|--------|----------|
| 0.25 | 0.25 | 1 GB | Development, low traffic |
| 0.5 | 0.5 | 2 GB | Small production apps |
| 1 | 1 | 4 GB | Medium production apps |
| 2 | 2 | 8 GB | High traffic production |
| 3 | 3 | 12 GB | Heavy production workload |
| 4 | 4 | 16 GB | Enterprise workload |

#### Configuring Autoscaling

```bash
# In Neon Console
# Settings → Compute → Autoscaling

# Or via CLI
neonctl projects set-compute \
  --project-id your-project-id \
  --min-size 0.5 \
  --max-size 4
```

#### Autoscaling Best Practices

```yaml
# Recommended scaling configurations
workloads:
  development:
    min_size: 0.25
    max_size: 0.5
    # Never scale to production size
    
  staging:
    min_size: 0.5
    max_size: 1
    # Test scaling behavior
    
  production_startup:
    min_size: 0.5
    max_size: 2
    # Scale gradually
    
  production_growth:
    min_size: 1
    max_size: 4
    # For growing applications
    
  production_high:
    min_size: 2
    max_size: 8
    # For high-traffic apps
```

---

### P3.6 Connection Pooling

Neon's connection pooler is crucial for serverless workloads.

#### Why Connection Pooling Matters

**Without Pooling (Direct Connections):**
```
Request 1 → New Connection ──┐
Request 2 → New Connection ──┼── Database (May hit connection limit)
Request 3 → New Connection ──┘
```

**With Pooling:**
```
Request 1 ──┐
Request 2 ──┼── Connection Pool ──┐
Request 3 ──┘                      │── Database (Few connections)
Request 4 ──┐                      │
Request 5 ──┼── Connection Pool ──┘
Request 6 ──┘
```

#### Pooling Modes

**Transaction Mode** (Default, recommended):
```javascript
// Each transaction gets a fresh connection
const pool = new Pool({
    connectionString: 'postgresql://...?pool_mode=transaction',
    max: 10,
});

// Query runs in its own transaction
await pool.query('BEGIN');
await pool.query('UPDATE products SET stock = stock - 1 WHERE id = 1');
await pool.query('COMMIT');
```

**Session Mode**:
```javascript
// Connection persists across multiple transactions
const pool = new Pool({
    connectionString: 'postgresql://...?pool_mode=session',
    max: 10,
});

// Same connection used for multiple queries
const client = await pool.connect();
try {
    await client.query('SELECT * FROM products');
    await client.query('SELECT * FROM orders');
} finally {
    client.release();
}
```

#### Connection Pool Configuration

```javascript
// Production-ready pool configuration
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    
    // Pool size
    max: 20,  // Maximum connections
    min: 2,   // Minimum connections
    idleTimeoutMillis: 30000,
    
    // Timeouts
    connectionTimeoutMillis: 2000,
    statement_timeout: 60000,
    idle_in_transaction_session_timeout: 30000,
    
    // Keep alive
    keepAlive: true,
    keepAliveInitialDelayMillis: 10000,
    
    // SSL (Always on for production)
    ssl: {
        rejectUnauthorized: true,
        ca: process.env.DB_CA_CERT,
    },
    
    // Application name for monitoring
    application_name: 'my-production-app',
});
```

---

### P3.7 Monitoring and Observability

Neon provides built-in monitoring through the console and CLI.

#### Key Metrics to Monitor

```sql
-- Database health check
SELECT 
    (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT count(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
    pg_database_size(current_database()) / 1024 / 1024 AS database_size_mb,
    (SELECT 
        round((sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100), 2)
     FROM pg_statio_user_tables) AS cache_hit_ratio;

-- Query performance
SELECT 
    queryid,
    query,
    calls,
    mean_exec_time,
    total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Active queries
SELECT 
    pid,
    usename,
    query,
    state,
    now() - query_start AS duration
FROM pg_stat_activity
WHERE state = 'active'
ORDER BY duration DESC;
```

#### Using Neon Console

**Key Dashboard Sections:**
1. **Compute**: CPU, memory, disk usage
2. **Connections**: Active connections, connection history
3. **Branches**: Branch status, size, activity
4. **Queries**: Query performance, slow queries
5. **Storage**: Disk usage, growth trends

#### Setting Up Alerts

```bash
# Via Neon CLI
neonctl alerts create \
  --type connection-usage \
  --threshold 80 \
  --webhook-url https://your-webhook.com/alert \
  --project-id your-project-id

# Types of alerts:
# - connection-usage
# - compute-usage
# - storage-usage
# - query-performance
```

---

### P3.8 Data Import and Export

#### Importing Data

```bash
# From a SQL dump file
psql "$DATABASE_URL" -f backup.sql

# From a custom format dump
pg_restore -d "$DATABASE_URL" backup.dump

# Import CSV data
COPY products FROM '/path/to/products.csv' DELIMITER ',' CSV HEADER;

# Import CSV from URL
curl -s https://example.com/products.csv | psql "$DATABASE_URL" -c "
    COPY products (name, price, stock_quantity) 
    FROM STDIN 
    DELIMITER ',' 
    CSV HEADER;
"
```

#### Exporting Data

```bash
# Export full database
pg_dump "$DATABASE_URL" > backup.sql

# Export schema only
pg_dump "$DATABASE_URL" --schema-only > schema.sql

# Export data only
pg_dump "$DATABASE_URL" --data-only > data.sql

# Export to CSV
psql "$DATABASE_URL" -c "\COPY (SELECT * FROM products) TO 'products.csv' CSV HEADER"

# Export to JSON
psql "$DATABASE_URL" -c "SELECT json_agg(row_to_json(products)) FROM products;" > products.json
```

---

### P3.9 Common Neon CLI Commands

```bash
# Project Management
neonctl projects list
neonctl projects create --name new-project
neonctl projects info --id project-id

# Branch Management
neonctl branches list --project-id project-id
neonctl branches create --name dev --parent main --project-id project-id
neonctl branches get-connection-string dev --project-id project-id
neonctl branches merge dev --target main --project-id project-id
neonctl branches delete dev --project-id project-id

# Database Management
neonctl databases list --project-id project-id
neonctl databases create --name new-db --project-id project-id

# Role Management
neonctl roles list --project-id project-id
neonctl roles create --name new-user --project-id project-id

# Autoscaling
neonctl projects set-compute \
  --project-id project-id \
  --min-size 0.5 \
  --max-size 4

# Alerts
neonctl alerts list --project-id project-id
neonctl alerts create \
  --type connection-usage \
  --threshold 80 \
  --webhook-url webhook-url \
  --project-id project-id

# Authentication
neonctl auth
```

---

### P3.10 Neon vs. Other PostgreSQL Services

| Feature | Neon | RDS | Cloud SQL | Heroku Postgres |
|---------|------|-----|-----------|-----------------|
| Serverless | ✅ | ❌ | ❌ | ❌ |
| Instant Branching | ✅ | ❌ | ❌ | ❌ |
| Autoscaling | ✅ | ✅ | ✅ | ❌ |
| Connection Pooling | ✅ | ❌ | ❌ | ❌ |
| PITR | ✅ | ✅ | ✅ | ✅ |
| Free Tier | ✅ | ❌ | ❌ | ❌ |
| Ease of Setup | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Advanced Features | ✅ | ✅ | ✅ | ✅ |
| Cost | Pay-per-use | Pay-per-use | Pay-per-use | Fixed plans |

---

### P3.11 Getting Help

#### Official Resources

- **Documentation**: https://neon.tech/docs
- **GitHub**: https://github.com/neondatabase/neon
- **Discord Community**: https://discord.gg/neon
- **Blog**: https://neon.tech/blog
- **YouTube**: https://youtube.com/@neon_tech

#### Common Issues and Solutions

**Issue: Connection Timeout**
```javascript
// Solution: Increase connection timeout
const pool = new Pool({
    connectionTimeoutMillis: 10000,  // 10 seconds
});
```

**Issue: Too Many Connections**
```javascript
// Solution: Use pooled connection
const pool = new Pool({
    connectionString: process.env.DATABASE_POOLED_URL,
    max: 10,  // Limit pool size
});
```

**Issue: Query Timeout**
```javascript
// Solution: Set statement timeout
const client = await pool.connect();
await client.query('SET statement_timeout = "30s"');
```

**Issue: Migration Fails**
```bash
# Solution: Use branch for testing
neonctl branches create --name test-migration --parent main
# Test migration on branch
# Then merge to main
```

---

### P3.12 Neon Best Practices Checklist

**Setup**
- [ ] Use pooled connection for serverless
- [ ] Configure connection pool size
- [ ] Set appropriate timeouts
- [ ] Enable SSL for all connections

**Development**
- [ ] Use branches for testing
- [ ] Create feature branches
- [ ] Test migrations on branches first
- [ ] Clean up old branches

**Deployment**
- [ ] Use preview deployments
- [ ] Run migration tests
- [ ] Create backup before deployment
- [ ] Monitor after deployment

**Operations**
- [ ] Set up monitoring
- [ ] Configure alerts
- [ ] Regular backup verification
- [ ] Review query performance

**Security**
- [ ] Use environment variables for credentials
- [ ] Rotate passwords regularly
- [ ] Use least-privilege access
- [ ] Enable row-level security

---

### Summary

You now understand the core concepts of Neon:

- **Serverless PostgreSQL**: No infrastructure management
- **Instant Branching**: Create database copies in seconds
- **Connection Pooling**: Handle serverless workloads
- **Autoscaling**: Automatically scale compute resources
- **Monitoring**: Track performance and usage
- **CLI Tools**: Manage everything from the command line

This primer has equipped you with the knowledge to effectively use Neon as your PostgreSQL platform. You're now ready to apply these concepts in the main tutorial series!
