# Appendix A: PostgreSQL Installation & Configuration Deep Dive

While Part 1 covered the basics of getting PostgreSQL running, this appendix provides comprehensive installation guidance, configuration optimization, and troubleshooting for all major platforms. Consider this your complete reference for setting up PostgreSQL in any environment—from development laptops to production servers.

## A.1 Installation Methods by Platform

### Target
Provide exhaustive installation options for every major operating system and use case.

### Concept
PostgreSQL can be installed through package managers, official installers, or compiled from source. Each method has trade-offs between simplicity, flexibility, and control. We'll cover all approaches so you can choose the right one for your environment.

---

## A.1.1 macOS Installation

### Option 1: Homebrew (Recommended for Development)

```bash
# Update Homebrew
brew update
brew upgrade

# Install PostgreSQL 16 (latest stable)
brew install postgresql@16

# Alternative: Install the latest version
brew install postgresql

# Start the service automatically
brew services start postgresql@16

# Verify installation
postgres --version
# Output: postgres (PostgreSQL) 16.2

# Check if service is running
brew services list | grep postgresql

# Stop the service (when needed)
brew services stop postgresql@16

# Restart the service
brew services restart postgresql@16

# Uninstall (if needed)
brew uninstall postgresql@16
```

### Option 2: Official Installer (GUI)

1. Download from: https://www.postgresql.org/download/macosx/
2. Choose the version matching your macOS (Intel or Apple Silicon)
3. Run the installer package
4. Follow these settings:
   - Installation directory: `/Library/PostgreSQL/16`
   - Data directory: `/Library/PostgreSQL/16/data`
   - Port: `5432`
   - **IMPORTANT**: Set a strong password for the postgres superuser
   - Check "Install PostgreSQL Server"
   - Check "Install pgAdmin" (optional but recommended)

### Option 3: EDB Postgres (Enterprise-grade)

```bash
# Download the EDB installer from https://www.enterprisedb.com/downloads/postgres-postgresql-downloads
# Run the installer and select:
# - PostgreSQL Server
# - Stack Builder (for additional tools)
# - pgAdmin (GUI tool)
```

### Post-Installation Configuration (macOS)

```bash
# Locate the PostgreSQL configuration file
# Homebrew location:
/opt/homebrew/var/postgresql@16/postgresql.conf

# Official installer location:
/Library/PostgreSQL/16/data/postgresql.conf

# Edit configuration for development
# Increase shared_buffers for better performance
shared_buffers = 256MB                    # Default is 128MB
work_mem = 32MB                           # Default is 4MB
maintenance_work_mem = 256MB              # Default is 64MB

# Enable logging for debugging
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'ddl'                     # Log schema changes
log_min_duration_statement = 5000         # Log queries > 5 seconds

# Restart PostgreSQL for changes to take effect
brew services restart postgresql@16
```

---

## A.1.2 Ubuntu/Debian Installation

### Option 1: Official Ubuntu Repository

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Check installed version
psql --version
# Output: psql (PostgreSQL) 14.x (Ubuntu 14.x-0ubuntu0.22.04.1)

# Check service status
sudo systemctl status postgresql

# Start/stop/restart
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql
sudo systemctl reload postgresql

# Enable auto-start on boot
sudo systemctl enable postgresql
```

### Option 2: PostgreSQL Official APT Repository (Latest Version)

```bash
# Add the PostgreSQL official repository
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Add the repository key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update package list
sudo apt update

# Install PostgreSQL 16
sudo apt install -y postgresql-16 postgresql-contrib-16

# Install development tools (optional)
sudo apt install -y postgresql-server-dev-16

# Verify installation
psql --version
# Output: psql (PostgreSQL) 16.2
```

### Option 3: Docker Installation (Containerized)

```bash
# Pull the official PostgreSQL image
docker pull postgres:16

# Run PostgreSQL container
docker run --name postgres-ecommerce \
    -e POSTGRES_PASSWORD=secure_password_123 \
    -e POSTGRES_USER=ecommerce_user \
    -e POSTGRES_DB=ecommerce \
    -p 5432:5432 \
    -v postgres_data:/var/lib/postgresql/data \
    -d postgres:16

# Connect to the container
docker exec -it postgres-ecommerce psql -U ecommerce_user -d ecommerce

# Check logs
docker logs postgres-ecommerce

# Stop the container
docker stop postgres-ecommerce

# Start the container again
docker start postgres-ecommerce
```

### Post-Installation Configuration (Ubuntu)

```bash
# Configuration file location
# Ubuntu 22.04:
/etc/postgresql/16/main/postgresql.conf

# Edit configuration
sudo nano /etc/postgresql/16/main/postgresql.conf

# Recommended settings for development
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 16MB
maintenance_work_mem = 256MB
wal_buffers = 16MB
checkpoint_completion_target = 0.9
max_connections = 200

# For production, consider these:
shared_buffers = 4GB              # 25% of total RAM
effective_cache_size = 12GB       # 75% of total RAM
work_mem = 64MB                   # Adjust based on workload
maintenance_work_mem = 1GB

# Client authentication configuration
# /etc/postgresql/16/main/pg_hba.conf
# Add this line for development (trust local connections)
# host    all             all             127.0.0.1/32            trust

# Restart PostgreSQL
sudo systemctl restart postgresql

# Connect as postgres user
sudo -u postgres psql
```

---

## A.1.3 Windows Installation

### Option 1: Official Installer (Recommended)

1. Download from: https://www.postgresql.org/download/windows/
2. Choose the version for your Windows (64-bit)
3. Run the installer as Administrator
4. Installation wizard steps:
   - **Installation Directory**: `C:\Program Files\PostgreSQL\16`
   - **Data Directory**: `C:\Program Files\PostgreSQL\16\data`
   - **Port**: `5432`
   - **Superuser Password**: Set a strong password (remember it!)
   - **Service Account**: Use the default (postgres)
   - **Additional Components**:
     - ✅ PostgreSQL Server
     - ✅ pgAdmin 4 (GUI tool)
     - ✅ Stack Builder (for extensions)
     - ☐ Command Line Tools (optional)

5. Complete the installation

### Option 2: Chocolatey Package Manager

```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install PostgreSQL via Chocolatey
choco install postgresql

# Or install a specific version
choco install postgresql16

# Verify installation
psql --version
```

### Option 3: Windows Subsystem for Linux (WSL2)

```powershell
# In PowerShell (Admin)
# Enable WSL2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Set WSL2 as default
wsl --set-default-version 2

# Install Ubuntu from Microsoft Store
# Then follow Ubuntu installation instructions above

# Access PostgreSQL from Windows
psql -h localhost -U postgres -d ecommerce
```

### Post-Installation Configuration (Windows)

```powershell
# Locate the configuration file
# C:\Program Files\PostgreSQL\16\data\postgresql.conf

# Edit with Notepad or your preferred editor
notepad "C:\Program Files\PostgreSQL\16\data\postgresql.conf"

# Add/modify these settings
shared_buffers = 256MB
work_mem = 16MB
maintenance_work_mem = 256MB

# Restart PostgreSQL service
# Method 1: Services panel
# Win + R, type services.msc, find PostgreSQL, restart

# Method 2: Command line (Admin)
net stop postgresql-x64-16
net start postgresql-x64-16

# Method 3: PowerShell (Admin)
Restart-Service -Name "postgresql-x64-16"
```

---

## A.2 PostgreSQL Configuration Deep Dive

### Target
Understand every important configuration parameter for development and production.

### Concept
PostgreSQL is highly configurable. The right settings can dramatically improve performance, while wrong settings can cause crashes or slow queries. Think of configuration as tuning a race car—you need the right balance for your specific track (workload).

---

## A.2.1 Essential Configuration Parameters

### Memory Settings

```sql
-- Connection to PostgreSQL
\c ecommerce

-- View current settings
SHOW shared_buffers;
SHOW work_mem;
SHOW maintenance_work_mem;
SHOW effective_cache_size;

-- Explanation of each setting
/*
shared_buffers: 
  - Memory used for caching data
  - Default: 128MB
  - Recommended: 25% of total RAM for dedicated database servers
  - Too high: Can cause system instability
  - Too low: More disk I/O, slower queries

work_mem:
  - Memory for sorting, hash joins, and aggregations
  - Default: 4MB
  - Recommended: 16-64MB for development, 64-256MB for production
  - Can be set per session or per query

maintenance_work_mem:
  - Memory for VACUUM, CREATE INDEX, and maintenance
  - Default: 64MB
  - Recommended: 1-10GB for production with large tables
  - Can be set higher than work_mem

effective_cache_size:
  - Estimate of OS cache size (not allocated)
  - Default: 4GB
  - Recommended: 75% of total RAM
  - Helps the query planner decide when to use indexes
*/

-- Set settings for the current session
SET work_mem = '64MB';
SET maintenance_work_mem = '512MB';

-- View current session settings
SELECT name, setting, unit 
FROM pg_settings 
WHERE name IN ('work_mem', 'maintenance_work_mem');

-- Set settings in postgresql.conf for persistence
-- Edit the file and add:
/*
shared_buffers = 4GB
work_mem = 64MB
maintenance_work_mem = 1GB
effective_cache_size = 12GB
*/
```

### Connection Settings

```sql
-- Check connection settings
SHOW max_connections;
SHOW superuser_reserved_connections;

/*
max_connections:
  - Maximum number of concurrent client connections
  - Default: 100
  - Recommended: 200-500 for production web applications
  - Each connection uses ~2-10MB of RAM

superuser_reserved_connections:
  - Connections reserved for superusers (usually 3)
  - Prevents admin lockout when max_connections is reached
*/

-- Connection pooling in applications
-- Use PgBouncer or connection pools in your application
-- Recommended: application-level connection pooling

-- Example application connection string with pooling
-- postgresql://user:password@host:5432/database?pool_size=20&max_pool_size=50

-- Recommended production settings
/*
max_connections = 300
superuser_reserved_connections = 5
tcp_keepalives_idle = 60
tcp_keepalives_interval = 10
tcp_keepalives_count = 6
*/
```

### Write-Ahead Log (WAL) Settings

```sql
-- Check WAL settings
SHOW wal_buffers;
SHOW wal_sync_method;
SHOW full_page_writes;
SHOW checkpoint_timeout;
SHOW max_wal_size;
SHOW min_wal_size;

/*
wal_buffers:
  - Memory for WAL (transaction log)
  - Default: 16MB
  - Recommended: 16-64MB for busy databases

checkpoint_timeout:
  - How often to write dirty buffers to disk
  - Default: 5 minutes
  - Recommended: 15-30 minutes for better performance

max_wal_size:
  - Maximum size of WAL files
  - Default: 1GB
  - Recommended: 4-64GB (larger for busy databases)
  - Larger = fewer checkpoints = better performance
*/

-- Recommended production settings
/*
wal_buffers = 16MB
checkpoint_timeout = 15min
max_wal_size = 10GB
min_wal_size = 2GB
checkpoint_completion_target = 0.9
*/
```

### Query Planning Settings

```sql
-- Check planner settings
SHOW random_page_cost;
SHOW effective_cache_size;
SHOW seq_page_cost;
SHOW enable_hashjoin;
SHOW enable_mergejoin;

/*
random_page_cost:
  - Cost of random I/O (disk seeks)
  - Default: 4.0
  - For SSDs: 1.1-1.5
  - For HDDs: 4.0
  - Lower values favor index scans

seq_page_cost:
  - Cost of sequential I/O
  - Default: 1.0
  - Usually fine at default

effective_cache_size:
  - Estimate of OS cache
  - Default: 4GB
  - Recommended: 75% of RAM
*/

-- Recommended settings for SSD
/*
random_page_cost = 1.1
effective_cache_size = 12GB  # 75% of 16GB RAM
*/

-- For development (force index scans for testing)
SET enable_seqscan = off;
-- But remember to turn it back on!
SET enable_seqscan = on;
```

### Logging Settings

```sql
-- Check logging settings
SHOW log_destination;
SHOW logging_collector;
SHOW log_directory;
SHOW log_filename;
SHOW log_statement;
SHOW log_min_duration_statement;

/*
log_statement:
  - 'none': Log nothing
  - 'ddl': Log schema changes
  - 'mod': Log DDL and data changes
  - 'all': Log everything (not recommended for production)
  
log_min_duration_statement:
  - Log queries that take longer than this (milliseconds)
  - 0 = log all queries
  - 5000 = log queries > 5 seconds
  - -1 = disable
*/

-- Create a logging function
CREATE OR REPLACE FUNCTION log_query_performance()
RETURNS TRIGGER AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_duration INTERVAL;
BEGIN
    -- Logging setup for debugging slow queries
    RAISE NOTICE 'Query: %', current_query();
    RAISE NOTICE 'Duration: %', clock_timestamp() - v_start_time;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recommended logging settings
/*
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 5000  # Log queries > 5 seconds
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 0
*/
```

---

## A.2.2 Creating a Custom Configuration File

### Target
Create a tailored configuration for our e-commerce application.

### Implementation

Create a file called `custom_postgresql.conf`:

```bash
# custom_postgresql.conf
# Tailored configuration for the e-commerce database

# ============================================================
# CONNECTION SETTINGS
# ============================================================
listen_addresses = 'localhost'          # Listen on localhost only
port = 5432                             # Default PostgreSQL port
max_connections = 200                   # Enough for development
superuser_reserved_connections = 3      # Reserved for admin

# ============================================================
# MEMORY SETTINGS
# ============================================================
shared_buffers = 512MB                  # 25% of 2GB RAM
work_mem = 32MB                         # For sorting and joins
maintenance_work_mem = 512MB            # For VACUUM and indexing
effective_cache_size = 1.5GB            # 75% of 2GB RAM

# ============================================================
# WAL SETTINGS
# ============================================================
wal_buffers = 16MB
checkpoint_timeout = 15min
max_wal_size = 4GB
min_wal_size = 1GB
checkpoint_completion_target = 0.9

# ============================================================
# QUERY PLANNER
# ============================================================
random_page_cost = 1.1                  # For SSDs
seq_page_cost = 1.0
effective_cache_size = 1.5GB

# ============================================================
# LOGGING
# ============================================================
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 5000       # Log slow queries
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on

# ============================================================
# AUTOVACUUM
# ============================================================
autovacuum = on
autovacuum_max_workers = 3
autovacuum_naptime = 1min
autovacuum_vacuum_threshold = 50
autovacuum_analyze_threshold = 50
autovacuum_vacuum_scale_factor = 0.2
autovacuum_analyze_scale_factor = 0.1

# ============================================================
# CLIENT SETTINGS
# ============================================================
default_transaction_isolation = 'read committed'
timezone = 'UTC'
datestyle = 'iso, mdy'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
```

Apply the configuration:

```bash
# Copy the configuration to the PostgreSQL directory
# macOS (Homebrew)
cp custom_postgresql.conf /opt/homebrew/var/postgresql@16/postgresql.conf

# Ubuntu
sudo cp custom_postgresql.conf /etc/postgresql/16/main/postgresql.conf

# Windows
# Copy to C:\Program Files\PostgreSQL\16\data\postgresql.conf

# Restart PostgreSQL
# macOS
brew services restart postgresql@16

# Ubuntu
sudo systemctl restart postgresql

# Windows (Admin)
net stop postgresql-x64-16
net start postgresql-x64-16

# Verify settings
psql -d ecommerce -c "SHOW ALL;"
```

---

## A.3 Troubleshooting Common Issues

### Target
Diagnose and fix common PostgreSQL problems.

### Concept
Even with perfect setup, things can go wrong. This section provides a troubleshooting guide for the most common issues you'll encounter.

---

## A.3.1 Connection Issues

### Problem: "FATAL: role 'username' does not exist"

```bash
# Create the missing user
psql -U postgres -c "CREATE USER username WITH PASSWORD 'password';"

# Or connect with the correct user
psql -U postgres -d ecommerce

# List all users
psql -U postgres -c "\du"
```

### Problem: "FATAL: database 'database_name' does not exist"

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE database_name;"

# List all databases
psql -U postgres -c "\l"

# Connect to the default database
psql -U postgres -d postgres
```

### Problem: "could not connect to server: Connection refused"

```bash
# Check if PostgreSQL is running
# macOS
brew services list | grep postgresql

# Ubuntu
sudo systemctl status postgresql

# Windows
# Check Services panel or run:
sc query postgresql-x64-16

# Start PostgreSQL
# macOS
brew services start postgresql@16

# Ubuntu
sudo systemctl start postgresql

# Windows
net start postgresql-x64-16

# Check if port is being used
sudo netstat -anp | grep 5432
# On Windows:
netstat -an | findstr 5432

# Check the log for errors
tail -f /opt/homebrew/var/log/postgresql.log  # macOS
sudo tail -f /var/log/postgresql/postgresql-16-main.log  # Ubuntu
```

### Problem: "FATAL: password authentication failed"

```bash
# Reset the password
psql -U postgres -c "ALTER USER username WITH PASSWORD 'new_password';"

# Or allow trust authentication for development
# Edit pg_hba.conf and add:
# host    all    all    127.0.0.1/32    trust

# Then restart PostgreSQL
```

---

## A.3.2 Performance Issues

### Problem: Queries are slow

```sql
-- Use EXPLAIN ANALYZE to find bottlenecks
EXPLAIN (ANALYZE, BUFFERS, VERBOSE) 
SELECT * FROM orders WHERE user_id = 'some-uuid';

-- Check for missing indexes
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan
FROM pg_stat_user_tables
WHERE seq_scan > 100
ORDER BY seq_scan DESC;

-- Check for unused indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY tablename;

-- Run VACUUM ANALYZE to update statistics
VACUUM ANALYZE;

-- Check current queries
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

### Problem: High CPU Usage

```sql
-- Identify CPU-heavy queries
SELECT 
    query,
    total_time,
    calls,
    total_time / calls AS avg_time_ms
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Kill runaway queries
SELECT pg_cancel_backend(pid)
FROM pg_stat_activity
WHERE query LIKE '%long_running_query%';

-- Or kill the connection (more aggressive)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE pid = <pid_to_kill>;
```

### Problem: Memory Issues

```sql
-- Check memory usage
SELECT 
    pid,
    usename,
    query,
    (SELECT SUM(amount) FROM pg_stat_activity) AS total_memory
FROM pg_stat_activity;

-- Check for memory-related errors
SELECT * FROM pg_stat_activity 
WHERE query LIKE '%out of memory%';

-- Reduce work_mem for problematic queries
SET work_mem = '4MB';
-- Run the query
SET work_mem = '64MB';  -- Reset

-- Check system memory
-- On Linux:
-- free -h
-- On macOS:
-- vm_stat
-- On Windows:
-- wmic OS get TotalVisibleMemorySize
```

---

## A.3.3 Data Corruption Issues

### Problem: "ERROR: could not open file ..."

```bash
# Check disk space
df -h

# Check for corrupted indexes
psql -d ecommerce -c "REINDEX DATABASE ecommerce;"

# Or reindex specific tables
psql -d ecommerce -c "REINDEX TABLE users;"

# Repair data (if necessary)
# Restore from backup
pg_restore -d ecommerce -v backup.dump

# Or use pg_dump to create a backup and restore
pg_dump -d ecommerce > backup.sql
psql -d ecommerce < backup.sql
```

### Problem: "ERROR: could not extend file: No space left on device"

```bash
# Check disk space
df -h

# Remove old log files
# Check log directory
ls -la /var/log/postgresql/

# Remove old logs
sudo rm /var/log/postgresql/postgresql-*.log.old

# Or rotate logs
sudo logrotate -f /etc/logrotate.d/postgresql

# Clean up dead tuples
VACUUM FULL;

# Or in extreme cases:
# Stop PostgreSQL, delete pg_xlog files (WAL), restart
# WARNING: This can cause data loss if not done carefully!
```

---

## A.4 PostgreSQL Extensions

### Target
Install and configure essential PostgreSQL extensions.

### Concept
Extensions add powerful capabilities to PostgreSQL. We've already used `uuid-ossp` and `pg_trgm`. This section covers other useful extensions and how to install them.

---

## A.4.1 Essential Extensions for Our E-Commerce Application

### Install Extensions

```sql
-- Connect to the database
\c ecommerce

-- List available extensions
SELECT * FROM pg_available_extensions ORDER BY name;

-- Install extensions we've used
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";     -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";      -- Text search with trigrams

-- Additional useful extensions
-- 1. pg_stat_statements: Query performance monitoring
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- 2. citext: Case-insensitive text
CREATE EXTENSION IF NOT EXISTS citext;

-- 3. hstore: Key-value pairs (older alternative to JSONB)
CREATE EXTENSION IF NOT EXISTS hstore;

-- 4. btree_gist: Support for exclusion constraints
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 5. postgis: Spatial data (for location-based features)
-- CREATE EXTENSION IF NOT EXISTS postgis;

-- Verify installed extensions
SELECT * FROM pg_extension;
```

### Configure pg_stat_statements for Performance Monitoring

```sql
-- Check if pg_stat_statements is loaded
SHOW shared_preload_libraries;

-- Add to postgresql.conf:
-- shared_preload_libraries = 'pg_stat_statements'

-- Configure pg_stat_statements
ALTER SYSTEM SET pg_stat_statements.max = 10000;
ALTER SYSTEM SET pg_stat_statements.track = 'top';
ALTER SYSTEM SET pg_stat_statements.track_utility = true;

-- Restart PostgreSQL after changing shared_preload_libraries

-- Query performance statistics
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time,
    rows,
    100.0 * shared_blks_hit / NULLIF(shared_blks_hit + shared_blks_read, 0) AS cache_hit_ratio
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 20;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

### Using citext for Case-Insensitive Text

```sql
-- Create a table with citext columns
CREATE TABLE test_citext (
    id SERIAL PRIMARY KEY,
    email CITEXT NOT NULL UNIQUE,
    username CITEXT
);

-- Insert data (case doesn't matter)
INSERT INTO test_citext (email, username) VALUES 
    ('USER@EXAMPLE.COM', 'JohnDoe'),
    ('another@example.com', 'johndoe');  -- This will fail because username is UNIQUE CITEXT

-- Query case-insensitively
SELECT * FROM test_citext WHERE email = 'user@example.com';
-- Returns the row regardless of case
```

---

## A.5 Database Backup and Recovery

### Target
Master backup and recovery strategies for PostgreSQL.

### Concept
Regular backups are your safety net. Think of them as time machines for your data—if something goes wrong, you can go back to a known good state. We'll cover different backup strategies and recovery procedures.

---

## A.5.1 Backup Methods

### Method 1: pg_dump (Logical Backup)

```bash
# Backup entire database
pg_dump -d ecommerce -U ecommerce_user -h localhost > ecommerce_backup_$(date +%Y%m%d).sql

# Backup in custom format (compressed)
pg_dump -d ecommerce -U ecommerce_user -h localhost -Fc > ecommerce_backup_$(date +%Y%m%d).dump

# Backup only schema (no data)
pg_dump -d ecommerce -U ecommerce_user -h localhost --schema-only > ecommerce_schema.sql

# Backup only data (no schema)
pg_dump -d ecommerce -U ecommerce_user -h localhost --data-only > ecommerce_data.sql

# Backup specific tables
pg_dump -d ecommerce -U ecommerce_user -h localhost -t users -t orders > users_orders_backup.sql

# Backup with compression
pg_dump -d ecommerce -U ecommerce_user -h localhost | gzip > ecommerce_backup_$(date +%Y%m%d).sql.gz

# Backup excluding large tables
pg_dump -d ecommerce -U ecommerce_user -h localhost --exclude-table=order_items > ecommerce_no_items.sql
```

### Method 2: pg_dumpall (Backup All Databases)

```bash
# Backup all databases (including global objects)
pg_dumpall -U postgres -h localhost > all_databases_backup_$(date +%Y%m%d).sql

# Backup only roles and tablespace definitions
pg_dumpall -U postgres -h localhost --roles-only --tablespaces-only > global_objects.sql

# Backup all databases with compression
pg_dumpall -U postgres -h localhost | gzip > all_databases_$(date +%Y%m%d).sql.gz
```

### Method 3: File System Backup (Physical Backup)

```bash
# Create a base backup using pg_basebackup
pg_basebackup -D /backup/pg_backup_$(date +%Y%m%d) -F tar -P -U postgres -h localhost

# Or with streaming replication
pg_basebackup -D /backup/pg_backup_$(date +%Y%m%d) -F tar -P -U postgres -h localhost -X stream

# Include WAL files
pg_basebackup -D /backup/pg_backup_$(date +%Y%m%d) -F tar -P -U postgres -h localhost -X fetch

# Compress the backup
tar -czf /backup/pg_backup_$(date +%Y%m%d).tar.gz /backup/pg_backup_$(date +%Y%m%d)
```

### Method 4: Continuous Archiving (Point-in-Time Recovery)

```bash
# Configure archive in postgresql.conf
wal_level = archive
archive_mode = on
archive_command = 'cp %p /archive/%f'

# Create base backup
pg_basebackup -D /backup/base_backup -F tar -P -U postgres -h localhost

# WAL files will be archived automatically
# Restore to any point in time using the base backup + WAL files
```

## A.5.2 Recovery Procedures

### Restore from SQL Backup

```bash
# Restore SQL backup
psql -d ecommerce -U ecommerce_user -h localhost < ecommerce_backup_20240101.sql

# Restore from compressed SQL backup
gunzip -c ecommerce_backup_20240101.sql.gz | psql -d ecommerce -U ecommerce_user -h localhost

# Restore only schema
psql -d ecommerce -U ecommerce_user -h localhost < ecommerce_schema.sql

# Restore only data
psql -d ecommerce -U ecommerce_user -h localhost < ecommerce_data.sql
```

### Restore from Custom Format

```bash
# Restore custom format backup
pg_restore -d ecommerce -U ecommerce_user -h localhost ecommerce_backup_20240101.dump

# Restore with verbose output
pg_restore -d ecommerce -U ecommerce_user -h localhost -v ecommerce_backup_20240101.dump

# Restore only specific tables
pg_restore -d ecommerce -U ecommerce_user -h localhost -t users ecommerce_backup_20240101.dump

# Restore and run custom SQL
pg_restore -d ecommerce -U ecommerce_user -h localhost -f restore_commands.sql ecommerce_backup_20240101.dump
```

### Restore from File System Backup

```bash
# Stop PostgreSQL
sudo systemctl stop postgresql

# Restore data directory
rm -rf /var/lib/postgresql/16/main/*
tar -xzf /backup/pg_backup_20240101.tar.gz -C /var/lib/postgresql/16/main/

# Fix permissions
chown -R postgres:postgres /var/lib/postgresql/16/main/

# Start PostgreSQL
sudo systemctl start postgresql
```

### Point-in-Time Recovery

```bash
# Prepare recovery configuration
cp /usr/share/postgresql/16/recovery.conf.sample /var/lib/postgresql/16/main/recovery.conf

# Edit recovery.conf:
# restore_command = 'cp /archive/%f %p'
# recovery_target_time = '2024-01-01 12:00:00'
# recovery_target_inclusive = true

# Create recovery signal file
touch /var/lib/postgresql/16/main/recovery.signal

# Start PostgreSQL
sudo systemctl start postgresql

# It will recover to the specified point in time
# Then promote to normal operation
```

---

## A.6 Summary

You now have a comprehensive reference for PostgreSQL installation, configuration, and troubleshooting:

✅ Installation guides for all platforms (macOS, Ubuntu, Windows)  
✅ Docker container setup  
✅ Configuration optimization for development and production  
✅ Essential extensions for e-commerce applications  
✅ Comprehensive troubleshooting guide  
✅ Multiple backup strategies and recovery procedures  

This appendix serves as your permanent reference for setting up and maintaining PostgreSQL in any environment.
