# APPENDIX J — Troubleshooting & Common Issues Guide

## Complete Problem-Solving Reference for ScaleCart

---

## J.1 Introduction

This appendix provides a comprehensive troubleshooting guide for common issues you might encounter while deploying, running, and maintaining the ScaleCart platform. It covers:

1. **Database Issues** – PostgreSQL, MongoDB, Redis, Neo4j problems
2. **Application Issues** – API errors, performance problems, deployment failures
3. **Infrastructure Issues** – Docker, Kubernetes, cloud provider problems
4. **Integration Issues** – Service-to-service communication failures
5. **Performance Issues** – Slow queries, memory leaks, CPU spikes
6. **Security Issues** – Authentication failures, permission problems

---

## J.2 Database Troubleshooting

### J.2.1 PostgreSQL Issues

#### Issue: Cannot Connect to PostgreSQL

**Symptoms:**
```
psql: could not connect to server: Connection refused
Is the server running on host "localhost" (127.0.0.1) and accepting
TCP/IP connections on port 5432?
```

**Troubleshooting Steps:**

```bash
# 1. Check if PostgreSQL container is running
docker compose ps postgres

# 2. Check container logs
docker compose logs postgres

# 3. Check if port is already in use
sudo netstat -tulpn | grep 5432
# or
lsof -i :5432

# 4. Check Docker network
docker network inspect scalecart_network

# 5. Test connection from host
psql -h localhost -p 5432 -U scalecart -d scalecart

# 6. Restart PostgreSQL
docker compose restart postgres

# 7. Check PostgreSQL configuration
docker compose exec postgres cat /var/lib/postgresql/data/postgresql.conf | grep listen_addresses
```

#### Issue: Database Connection Pool Exhaustion

**Symptoms:**
```
FATAL: remaining connection slots are reserved for non-replication superuser connections
FATAL: sorry, too many clients already
```

**Solutions:**

```sql
-- 1. Check current connections
SELECT count(*) FROM pg_stat_activity;
SELECT pid, usename, application_name, client_addr, state, query 
FROM pg_stat_activity 
WHERE pid != pg_backend_pid();

-- 2. Find idle connections
SELECT pid, usename, application_name, state, query 
FROM pg_stat_activity 
WHERE state = 'idle' AND query != '';

-- 3. Kill idle connections
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE state = 'idle' AND pid != pg_backend_pid();

-- 4. Increase max_connections (requires restart)
ALTER SYSTEM SET max_connections = 300;
-- Then restart PostgreSQL

-- 5. Use PgBouncer connection pool (recommended for production)
# Configure PgBouncer in docker-compose.yml
```

#### Issue: Slow Queries

**Symptoms:**
- API response times > 500ms
- High CPU usage in PostgreSQL
- Queries taking seconds to complete

**Diagnosis:**

```sql
-- 1. Find currently running slow queries
SELECT 
    pid,
    usename,
    now() - query_start AS duration,
    state,
    query
FROM pg_stat_activity
WHERE state = 'active' 
  AND now() - query_start > interval '5 seconds'
  AND pid != pg_backend_pid()
ORDER BY duration DESC;

-- 2. Check pg_stat_statements for historical slow queries
SELECT 
    query,
    calls,
    total_time / 1000 AS total_seconds,
    mean_time / 1000 AS avg_ms,
    rows
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- 3. Check index usage
SELECT 
    schemaname,
    tablename,
    seq_scan,
    idx_scan,
    ROUND(100.0 * idx_scan / GREATEST(seq_scan + idx_scan, 1), 2) AS index_usage_pct
FROM pg_stat_user_tables
WHERE seq_scan + idx_scan > 1000
ORDER BY index_usage_pct ASC;

-- 4. EXPLAIN ANALYZE the problematic query
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT * FROM products WHERE category_id = 5 AND price > 100;
```

**Solutions:**

```sql
-- 1. Create missing indexes
CREATE INDEX CONCURRENTLY idx_products_category_price ON products(category_id, price);

-- 2. Update statistics
ANALYZE products;

-- 3. Increase work_mem for the session
SET work_mem = '256MB';

-- 4. Rewrite query to be more efficient
-- Instead of:
SELECT * FROM products p JOIN categories c ON p.category_id = c.id WHERE c.name = 'Electronics';
-- Use:
SELECT * FROM products WHERE category_id = (SELECT id FROM categories WHERE name = 'Electronics');
```

#### Issue: Database Corruption

**Symptoms:**
```
ERROR: could not read block 1234 in file "base/12345/12345": read only 0 of 8192 bytes
PANIC: could not open file "pg_xlog/0000000100000000000000XX": No such file or directory
```

**Recovery Steps:**

```bash
# 1. Stop PostgreSQL
docker compose stop postgres

# 2. Check PostgreSQL logs
docker compose logs postgres | grep -i error

# 3. Try to start in single-user mode
docker compose run --rm postgres postgres --single -D /var/lib/postgresql/data

# 4. Use pg_resetwal (dangerous - may lose data)
docker compose run --rm postgres pg_resetwal -f /var/lib/postgresql/data

# 5. Restore from backup
pg_restore -U scalecart -d scalecart -c /backups/latest.dump

# 6. If corruption is limited to one table, dump and restore that table
pg_dump -U scalecart -d scalecart -t products > products.sql
# Then drop and recreate the table, then restore
```

#### Issue: Disk Space Full

**Symptoms:**
```
ERROR: could not extend file "base/12345/12345": No space left on device
```

**Solutions:**

```bash
# 1. Check disk usage
df -h

# 2. Find large files
du -sh /var/lib/postgresql/data/* | sort -h

# 3. Remove old WAL files (if archive is enabled)
# First, check if WAL can be removed
SELECT pg_switch_wal();
SELECT pg_current_wal_lsn();

# 4. Vacuum full (may free space but locks tables)
docker compose exec postgres psql -U scalecart -d scalecart -c "VACUUM FULL;"

# 5. Drop unused indexes
# Find unused indexes first, then drop

# 6. Archive old data or move to another tablespace

# 7. Increase disk space
# In cloud: resize volume
# In Docker: increase volume size in docker-compose.yml
```

---

### J.2.2 Redis Issues

#### Issue: Redis Connection Refused

**Symptoms:**
```
redis.exceptions.ConnectionError: Error 111 connecting to localhost:6379. Connection refused.
```

**Troubleshooting:**

```bash
# 1. Check if Redis is running
docker compose ps redis

# 2. Check Redis logs
docker compose logs redis

# 3. Check Redis configuration
docker compose exec redis redis-cli -a scalecart_password INFO

# 4. Test connection
docker compose exec redis redis-cli -a scalecart_password PING

# 5. Check password
docker compose exec redis redis-cli -a scalecart_password CONFIG GET requirepass

# 6. Restart Redis
docker compose restart redis
```

#### Issue: Redis Memory Full

**Symptoms:**
```
OOM command not allowed when used memory > 'maxmemory'
Error: OOM (Out of Memory) in Redis
```

**Solutions:**

```bash
# 1. Check memory usage
docker compose exec redis redis-cli -a scalecart_password INFO memory

# 2. Check memory policies
docker compose exec redis redis-cli -a scalecart_password CONFIG GET maxmemory-policy

# 3. Clear specific keys
docker compose exec redis redis-cli -a scalecart_password KEYS "session:*" | xargs redis-cli DEL

# 4. Increase maxmemory
docker compose exec redis redis-cli -a scalecart_password CONFIG SET maxmemory 2gb

# 5. Change eviction policy
docker compose exec redis redis-cli -a scalecart_password CONFIG SET maxmemory-policy allkeys-lru

# 6. Monitor memory in real-time
docker compose exec redis redis-cli -a scalecart_password --stat
```

#### Issue: Redis Slow Operations

**Symptoms:**
- Operations taking > 1ms
- Redis CPU usage high

**Diagnosis:**

```bash
# 1. Check slow log
docker compose exec redis redis-cli -a scalecart_password SLOWLOG GET 10

# 2. Check command stats
docker compose exec redis redis-cli -a scalecart_password INFO commandstats

# 3. Check client connections
docker compose exec redis redis-cli -a scalecart_password INFO clients

# 4. Check latency
docker compose exec redis redis-cli -a scalecart_password --latency

# 5. Monitor commands
docker compose exec redis redis-cli -a scalecart_password MONITOR
```

**Solutions:**

```bash
# 1. Adjust slow log threshold
docker compose exec redis redis-cli -a scalecart_password CONFIG SET slowlog-log-slower-than 10000

# 2. Use pipelining for batch operations in application

# 3. Consider Redis Cluster for horizontal scaling

# 4. Use appropriate data structures (hashes instead of multiple keys)
```

---

### J.2.3 MongoDB Issues

#### Issue: MongoDB Connection Timeout

**Symptoms:**
```
pymongo.errors.ServerSelectionTimeoutError: connection closed
```

**Troubleshooting:**

```bash
# 1. Check if MongoDB is running
docker compose ps mongodb

# 2. Check MongoDB logs
docker compose logs mongodb

# 3. Check MongoDB status
docker compose exec mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin --eval "db.serverStatus()"

# 4. Test connection
docker compose exec mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin --eval "db.runCommand({ping:1})"

# 5. Check MongoDB configuration
docker compose exec mongodb cat /etc/mongod.conf
```

#### Issue: MongoDB Performance

**Symptoms:**
- Slow queries
- High CPU usage
- Connection pool exhaustion

**Diagnosis:**

```javascript
// 1. Check current operations
db.currentOp()

// 2. Check slow queries (if profiling enabled)
db.system.profile.find().sort({ts: -1}).limit(10)

// 3. Check index usage
db.products.aggregate([
    { $indexStats: {} }
])

// 4. Check collection statistics
db.products.stats()
db.orders.stats()
```

**Solutions:**

```javascript
// 1. Create missing indexes
db.products.createIndex({ "category_id": 1, "price": -1 })
db.orders.createIndex({ "customer_id": 1, "order_date": -1 })

// 2. Use compound indexes
db.order_items.createIndex({ "order_id": 1, "product_id": 1 })

// 3. Use covered queries (project only indexed fields)
db.products.find(
    { category_id: 5 },
    { name: 1, price: 1, _id: 0 }
)

// 4. Increase connection pool in application
// MongoClient options: maxPoolSize=100, minPoolSize=10
```

---

## J.3 Application Troubleshooting

### J.3.1 API Issues

#### Issue: API Not Responding

**Symptoms:**
```
curl: (7) Failed to connect to localhost port 8000: Connection refused
```

**Troubleshooting:**

```bash
# 1. Check if API container is running
docker compose ps api

# 2. Check API logs
docker compose logs api

# 3. Check if API is listening on correct port
docker compose exec api netstat -tulpn | grep 8000

# 4. Test from within container
docker compose exec api curl http://localhost:8000/health

# 5. Check if port is mapped correctly
docker compose port api 8000

# 6. Restart API
docker compose restart api
```

#### Issue: API Returns 500 Errors

**Symptoms:**
```
Internal Server Error (500)
```

**Troubleshooting:**

```bash
# 1. Check API logs for stack traces
docker compose logs api | grep -A 10 "ERROR"

# 2. Check for unhandled exceptions
docker compose logs api | grep "Traceback"

# 3. Enable debug mode temporarily (only for debugging)
docker compose exec api bash -c "export DEBUG=true && python src/api/app.py"

# 4. Check database connectivity
docker compose exec api python -c "from src.utils.db import get_db; next(get_db()).execute('SELECT 1')"

# 5. Check for missing environment variables
docker compose exec api env | grep -E "DATABASE|REDIS|MONGO"

# 6. Check disk space
docker compose exec api df -h
```

#### Issue: Slow API Responses

**Diagnosis:**

```bash
# 1. Check API response times with curl
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8000/api/v1/products

# 2. Use Python profiling
docker compose exec api python -m cProfile -o profile.stats src/api/app.py

# 3. Check database query performance (see PostgreSQL section)

# 4. Check Redis cache hit rate
docker compose exec redis redis-cli -a scalecart_password INFO stats | grep keyspace

# 5. Check application memory usage
docker compose exec api ps aux | grep python

# 6. Check CPU usage
docker compose exec api top -b -n 1 | head -20
```

**Solutions:**

```python
# 1. Add caching
@cache.cached(timeout=300)
def get_products():
    # Your code here

# 2. Use connection pooling
# Already implemented in src/utils/connection_pool.py

# 3. Use async for I/O operations
async def get_product_with_reviews(product_id):
    product = await get_product(product_id)
    reviews = await get_reviews(product_id)
    return {**product, "reviews": reviews}

# 4. Use pagination
def get_products(page=1, limit=20):
    offset = (page - 1) * limit
    return Product.query.offset(offset).limit(limit).all()

# 5. Use batch operations
def bulk_update_inventory(items):
    with session.bulk_save_objects(items):
        pass
```

### J.3.2 Migration Issues

#### Issue: Alembic Migration Fails

**Symptoms:**
```
alembic.util.exc.CommandError: Can't locate revision identified by 'abc123'
```

**Troubleshooting:**

```bash
# 1. Check current migration version
alembic current

# 2. Check migration history
alembic history

# 3. Check if migration file exists
ls src/migrations/versions/

# 4. Try to stamp to a specific version
alembic stamp <revision-id>

# 5. Skip migration that's failing
# Edit the migration file and comment out the problematic section

# 6. Force migration (dangerous - may cause inconsistency)
alembic stamp head
```

#### Issue: Migration Takes Too Long

**Symptoms:**
- Migration running for hours
- Database locked

**Solutions:**

```sql
-- 1. Add CONCURRENTLY to index creation
CREATE INDEX CONCURRENTLY idx_products_name ON products(name);

-- 2. Batch large updates
DO $$
DECLARE
    batch_size INT := 1000;
    total_rows INT;
BEGIN
    SELECT COUNT(*) INTO total_rows FROM orders;
    FOR i IN 0..total_rows STEP batch_size LOOP
        UPDATE orders 
        SET status = 'processed' 
        WHERE id IN (
            SELECT id FROM orders 
            LIMIT batch_size 
            OFFSET i
        );
        COMMIT;
    END LOOP;
END $$;

-- 3. Use --no-lock for pg_dump
pg_dump --no-lock -U scalecart -d scalecart > backup.sql
```

### J.3.3 Dependency Issues

#### Issue: Missing Python Package

**Symptoms:**
```
ModuleNotFoundError: No module named 'some_package'
```

**Solutions:**

```bash
# 1. Install missing package
pip install some_package

# 2. Update requirements.txt
pip freeze > requirements.txt

# 3. Install from requirements with specific version
pip install -r requirements.txt

# 4. Check if package is installed in container
docker compose exec api pip list | grep some_package

# 5. Rebuild container with updated dependencies
docker compose build --no-cache api
```

#### Issue: Version Conflicts

**Symptoms:**
```
ERROR: Cannot install because these package versions have conflicting dependencies
```

**Solutions:**

```bash
# 1. Check dependency tree
pip freeze | grep some-package
pipdeptree | grep some-package

# 2. Try to resolve conflicts manually
# Edit requirements.txt and pin specific versions

# 3. Use constraints file
pip install -c constraints.txt -r requirements.txt

# 4. Use poetry for better dependency management
poetry add some-package@version

# 5. Create a fresh virtual environment
rm -rf venv
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## J.4 Infrastructure Troubleshooting

### J.4.1 Docker Issues

#### Issue: Docker Daemon Not Running

**Symptoms:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

**Solutions:**

```bash
# 1. Start Docker daemon
# On Linux:
sudo systemctl start docker

# On Mac:
open /Applications/Docker.app

# On Windows:
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# 2. Check Docker status
sudo systemctl status docker

# 3. Check permissions
sudo usermod -aG docker $USER

# 4. Restart Docker
sudo systemctl restart docker
```

#### Issue: Port Conflict

**Symptoms:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:5432: bind: address already in use
```

**Solutions:**

```bash
# 1. Find process using the port
sudo lsof -i :5432
# or
sudo netstat -tulpn | grep 5432

# 2. Kill the process
sudo kill -9 <PID>

# 3. Change port mapping in docker-compose.yml
ports:
  - "5433:5432"

# 4. Use a different port in .env
POSTGRES_PORT=5433

# 5. Stop conflicting service
docker stop <container-name>
```

#### Issue: Docker Out of Memory

**Symptoms:**
```
docker: Error response from daemon: cannot allocate memory
```

**Solutions:**

```bash
# 1. Check memory usage
docker system df -v

# 2. Clean up unused resources
docker system prune -a -f

# 3. Increase Docker memory limit
# Docker Desktop: Settings > Resources > Memory

# 4. Set memory limits in docker-compose.yml
services:
  api:
    deploy:
      resources:
        limits:
          memory: 2G

# 5. Use memory swaps
docker compose up --memory-swap=4G
```

### J.4.2 Kubernetes Issues

#### Issue: Pod CrashLoopBackOff

**Symptoms:**
```
NAME                            READY   STATUS             RESTARTS   AGE
scalecart-api-7d8f9b6c4-abc12   0/1     CrashLoopBackOff   5          10m
```

**Troubleshooting:**

```bash
# 1. Check pod logs
kubectl logs scalecart-api-7d8f9b6c4-abc12 -n scalecart

# 2. Check pod describe for events
kubectl describe pod scalecart-api-7d8f9b6c4-abc12 -n scalecart

# 3. Check previous logs (if container restarted)
kubectl logs scalecart-api-7d8f9b6c4-abc12 --previous -n scalecart

# 4. Check if image exists and is accessible
kubectl get deployment scalecart-api -o yaml -n scalecart

# 5. Check resource limits
kubectl describe pod scalecart-api-7d8f9b6c4-abc12 -n scalecart | grep -A 5 Limits

# 6. Check configmaps and secrets
kubectl get configmap scalecart-config -o yaml -n scalecart
kubectl get secret scalecart-secrets -n scalecart

# 7. Check readiness probe
kubectl describe pod scalecart-api-7d8f9b6c4-abc12 -n scalecart | grep -A 10 Readiness
```

**Common Causes and Solutions:**

```yaml
# 1. Missing environment variables
# Add missing variables to deployment

# 2. Database not ready
# Add initContainer to wait for database
initContainers:
- name: wait-for-db
  image: busybox
  command: ['sh', '-c', 'until nc -z postgres 5432; do echo waiting; sleep 2; done;']

# 3. Insufficient resources
# Increase resource limits
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"

# 4. Incorrect image tag
# Use correct image tag in deployment
image: scalecart/api:v1.0.0

# 5. Failed health checks
# Adjust health check parameters
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  initialDelaySeconds: 60
  periodSeconds: 30
```

#### Issue: Service Not Accessible

**Symptoms:**
```
curl: (7) Failed to connect to api.scalecart.com port 80: Connection refused
```

**Troubleshooting:**

```bash
# 1. Check service exists
kubectl get svc -n scalecart

# 2. Check endpoints
kubectl get endpoints scalecart-api -n scalecart

# 3. Check ingress
kubectl get ingress -n scalecart

# 4. Check network policies
kubectl get networkpolicies -n scalecart

# 5. Port forward to test
kubectl port-forward svc/scalecart-api 8000:8000 -n scalecart

# 6. Test from inside cluster
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl -v http://scalecart-api:8000/health -n scalecart
```

---

## J.5 Security Troubleshooting

### J.5.1 Authentication Issues

#### Issue: Invalid Token

**Symptoms:**
```
{"detail": "Could not validate credentials"}
```

**Troubleshooting:**

```bash
# 1. Check token expiration
# Decode JWT token to check expiration
jwt decode <token>

# 2. Check JWT secret
# Ensure SECRET_KEY in environment matches
docker compose exec api echo $SECRET_KEY

# 3. Check token format
# Should be: Bearer <token>

# 4. Check token algorithm
# Should match ALGORITHM in code (HS256)

# 5. Check token audience (if using)
# Ensure audience matches in token and validation
```

#### Issue: Rate Limiting Hit

**Symptoms:**
```
{"detail": "Rate limit exceeded"}
```

**Solutions:**

```bash
# 1. Check rate limit headers
# X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset

# 2. Wait for reset period (typically 60 seconds)

# 3. Increase rate limit for trusted users
# In code, skip rate limiting for certain IPs or user IDs

# 4. Adjust rate limit configuration
# In .env or config: RATE_LIMIT_PER_MINUTE=100

# 5. Check if Redis is working (rate limiting uses Redis)
docker compose exec redis redis-cli -a scalecart_password ping
```

---

## J.6 Common Error Codes

### J.6.1 HTTP Status Codes

| Code | Meaning | Common Causes | Solution |
|------|---------|---------------|----------|
| 400 | Bad Request | Invalid input data, malformed JSON | Validate input, check request format |
| 401 | Unauthorized | Missing/invalid token, expired token | Ensure valid token, check expiration |
| 403 | Forbidden | Insufficient permissions | Check user role/permissions |
| 404 | Not Found | Resource doesn't exist | Verify ID, resource exists |
| 409 | Conflict | Duplicate record, constraint violation | Check uniqueness, handle conflicts |
| 422 | Unprocessable Entity | Validation error, business rule violation | Fix input data, check business rules |
| 429 | Too Many Requests | Rate limit exceeded | Wait, increase limit, use backoff |
| 500 | Internal Server Error | Server error, database error | Check logs, fix application error |
| 503 | Service Unavailable | Database down, dependency failure | Check dependencies, retry |

### J.6.2 Database Error Codes

| Code | Meaning | Common Causes | Solution |
|------|---------|---------------|----------|
| 23503 | Foreign Key Violation | Referenced record doesn't exist | Check parent record exists |
| 23505 | Unique Violation | Duplicate key | Check uniqueness, handle duplicates |
| 23514 | Check Violation | Constraint failed | Fix data to satisfy constraint |
| 42P01 | Undefined Table | Table doesn't exist | Run migrations, check schema |
| 42703 | Undefined Column | Column doesn't exist | Check column name, run migrations |
| 08006 | Connection Failure | Database down, network issue | Check DB connectivity |
| 57014 | Query Canceled | Timeout, user cancellation | Increase timeout, optimize query |
| 55P03 | Lock Not Available | Lock timeout | Retry, check for deadlocks |

---

## J.7 Quick Diagnostic Commands

### J.7.1 One-Line Diagnostics

```bash
# Check all services status
docker compose ps && echo "---" && docker compose exec postgres pg_isready && echo "---" && docker compose exec redis redis-cli -a scalecart_password ping

# Check API health and response time
curl -w "Status: %{http_code} | Time: %{time_total}s\n" -o /dev/null -s http://localhost:8000/health

# Check database connections
docker compose exec postgres psql -U scalecart -d scalecart -c "SELECT count(*) FROM pg_stat_activity;"

# Check Redis memory usage
docker compose exec redis redis-cli -a scalecart_password INFO memory | grep used_memory_human

# Check disk space
df -h | grep -E "Filesystem|/var/lib/docker|/dev/sd"

# Check CPU and memory
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPct}}\t{{.MemUsage}}"

# Check for slow queries
docker compose exec postgres psql -U scalecart -d scalecart -c "SELECT query, mean_time FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 5;"
```

### J.7.2 Diagnostic Script

```bash
#!/bin/bash
# File: scripts/diagnose.sh
# Complete diagnostic script

echo "==================================="
echo "ScaleCart Diagnostic Report"
echo "==================================="
echo "Time: $(date)"
echo ""

echo "1. Docker Services"
echo "------------------"
docker compose ps

echo ""
echo "2. Container Health"
echo "------------------"
for service in postgres redis mongodb neo4j api; do
    echo -n "$service: "
    docker compose exec -T $service health-check 2>/dev/null || echo "unhealthy"
done

echo ""
echo "3. Database Connections"
echo "----------------------"
docker compose exec -T postgres psql -U scalecart -d scalecart -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';" 2>/dev/null || echo "Database not accessible"

echo ""
echo "4. Redis Status"
echo "--------------"
docker compose exec -T redis redis-cli -a scalecart_password INFO stats 2>/dev/null | grep -E "total_connections_received|total_commands_processed" || echo "Redis not accessible"

echo ""
echo "5. Disk Usage"
echo "------------"
df -h | grep -E "Filesystem|/var/lib/docker|/dev/sd"

echo ""
echo "6. Memory Usage"
echo "--------------"
free -h

echo ""
echo "7. API Health"
echo "------------"
curl -s -o /dev/null -w "Status: %{http_code}\nResponse: %{time_total}s\n" http://localhost:8000/health

echo ""
echo "8. Recent Errors"
echo "---------------"
docker compose logs --tail=50 2>/dev/null | grep -i "error\|exception\|failed" | tail -10

echo ""
echo "==================================="
echo "Diagnostic complete"
```

---

## J.8 Escalation Path

### J.8.1 When to Escalate

| Issue Type | Severity | Action |
|------------|----------|--------|
| Production down | P0 | Immediate escalation to on-call engineer |
| Degraded performance | P1 | Escalate to engineering lead |
| Minor bugs | P2 | Create ticket, fix in next sprint |
| Feature requests | P3 | Add to backlog, prioritize as needed |

### J.8.2 Emergency Contact List

```yaml
# File: docs/emergency-contacts.yaml
emergency_contacts:
  primary:
    name: "John Doe"
    role: "Engineering Lead"
    phone: "+1-555-123-4567"
    email: "john.doe@scalecart.com"
    pagerduty: "john.doe@pd.scalecart.com"

  backup:
    name: "Jane Smith"
    role: "Senior Engineer"
    phone: "+1-555-987-6543"
    email: "jane.smith@scalecart.com"
    pagerduty: "jane.smith@pd.scalecart.com"

  database:
    name: "Bob Johnson"
    role: "Database Administrator"
    phone: "+1-555-456-7890"
    email: "bob.johnson@scalecart.com"

  infrastructure:
    name: "Alice Williams"
    role: "DevOps Engineer"
    phone: "+1-555-789-0123"
    email: "alice.williams@scalecart.com"
```

---

## J.9 Maintenance Windows

### J.9.1 Scheduled Maintenance

```yaml
# File: docs/maintenance-windows.yaml
maintenance:
  regular:
    day: "Sunday"
    time: "02:00 - 04:00 UTC"
    duration: "2 hours"
    impact: "Read-only mode"
    
  database_backup:
    day: "Daily"
    time: "01:00 UTC"
    duration: "30 minutes"
    impact: "Minimal (hot backup)"
    
  deployment:
    day: "Tuesday & Thursday"
    time: "10:00 - 14:00 UTC"
    duration: "4 hours"
    impact: "Zero-downtime (blue-green)"
```

### J.9.2 Maintenance Commands

```bash
# Enter maintenance mode (read-only)
docker compose exec postgres psql -U scalecart -d scalecart -c "ALTER SYSTEM SET default_transaction_read_only = on; SELECT pg_reload_conf();"

# Exit maintenance mode
docker compose exec postgres psql -U scalecart -d scalecart -c "ALTER SYSTEM SET default_transaction_read_only = off; SELECT pg_reload_conf();"

# Enable maintenance page
# Add maintenance.html to static files and redirect all traffic

# Perform rolling restart
kubectl rollout restart deployment/scalecart-api -n scalecart

# Drain a node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Uncordon node
kubectl uncordon <node-name>
```

---

**[END OF APPENDIX J]**

*This comprehensive troubleshooting guide provides solutions for the most common issues you'll encounter. Use it as your first line of defense when problems arise. Remember: always check logs first, then system status, then escalate as needed.*
