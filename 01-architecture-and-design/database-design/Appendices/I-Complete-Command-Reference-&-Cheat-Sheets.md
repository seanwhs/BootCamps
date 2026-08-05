# APPENDIX I — Complete Command Reference & Cheat Sheets

## Quick Reference for All ScaleCart Operations

---

## I.1 Introduction

This appendix provides a comprehensive command reference for all aspects of the ScaleCart platform. Use it as your daily operations cheat sheet for:

1. **Docker & Docker Compose** – Container management commands
2. **Database Operations** – PostgreSQL, MongoDB, Redis, Neo4j commands
3. **Kubernetes** – kubectl commands for cluster management
4. **AWS CLI** – Cloud operations commands
5. **Development** – Python, Git, and testing commands
6. **Monitoring** – Health checks and troubleshooting commands

---

## I.2 Docker & Docker Compose Commands

### I.2.1 Development Environment

```bash
# ============================================
# BASIC DOCKER COMPOSE COMMANDS
# ============================================

# Start all services in detached mode
docker compose up -d

# Start specific service
docker compose up -d postgres redis

# Stop all services
docker compose down

# Stop and remove volumes (clears data)
docker compose down -v

# View logs for all services
docker compose logs -f

# View logs for specific service
docker compose logs -f api
docker compose logs -f postgres

# Restart a specific service
docker compose restart api

# Execute command in running container
docker compose exec api bash
docker compose exec postgres psql -U scalecart -d scalecart

# Scale a service
docker compose up -d --scale api=3

# Build and start with rebuild
docker compose up -d --build

# Check service status
docker compose ps

# View resource usage
docker compose stats

# ============================================
# DOCKER COMPOSE PROFILES
# ============================================

# Start with monitoring stack
docker compose --profile monitoring up -d

# Start only essential services
docker compose --profile minimal up -d

# Production-like environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# ============================================
# DOCKER IMAGE COMMANDS
# ============================================

# Build production image
docker build --target production -t scalecart/api:latest .

# Build development image
docker build --target development -t scalecart/api:dev .

# Tag image for registry
docker tag scalecart/api:latest ghcr.io/username/scalecart:latest

# Push to registry
docker push ghcr.io/username/scalecart:latest

# List images
docker images

# Remove unused images
docker image prune -a

# ============================================
# DOCKER NETWORK COMMANDS
# ============================================

# List networks
docker network ls

# Inspect network
docker network inspect scalecart_network

# Clean up networks
docker network prune
```

### I.2.2 Docker Compose Quick Commands

```bash
# Makefile shortcuts (if available)
make up          # Start all services
make down        # Stop all services
make logs        # View logs
make shell       # Open API shell
make psql        # Connect to PostgreSQL
make mongo       # Connect to MongoDB
make redis       # Connect to Redis
make neo4j       # Connect to Neo4j
make db-init     # Initialize database
make db-migrate  # Run migrations
make db-seed     # Seed data
make test        # Run tests
make lint        # Run linters
```

---

## I.3 Database Commands

### I.3.1 PostgreSQL

```bash
# ============================================
# POSTGRESQL CONNECTION COMMANDS
# ============================================

# Connect to PostgreSQL
docker compose exec postgres psql -U scalecart -d scalecart

# Connect from host (if port exposed)
psql -h localhost -p 5432 -U scalecart -d scalecart

# Connect with connection string
psql "postgresql://scalecart:scalecart_password@localhost:5432/scalecart"

# ============================================
# POSTGRESQL DATABASE OPERATIONS
# ============================================

# List databases
\l

# List tables
\dt

# Describe table
\d products
\d orders

# Show indexes
\di

# Show running queries
SELECT pid, usename, query, state, query_start 
FROM pg_stat_activity 
WHERE state = 'active' AND pid != pg_backend_pid();

# Kill a query
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid = 1234;

# Show table sizes
SELECT 
    schemaname, 
    tablename, 
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

# Vacuum a table
VACUUM ANALYZE products;

# Vacuum full (locks table)
VACUUM FULL products;

# Show cache hit ratio
SELECT 
    'cache_hit_ratio' AS metric,
    ROUND(100.0 * sum(heap_blks_hit) / GREATEST(sum(heap_blks_hit) + sum(heap_blks_read), 1), 2) AS ratio
FROM pg_statio_user_tables;

# ============================================
# POSTGRESQL BACKUP & RESTORE
# ============================================

# Backup database (custom format)
pg_dump -U scalecart -h localhost -d scalecart -F c -f backup.dump

# Backup database (SQL format)
pg_dump -U scalecart -h localhost -d scalecart > backup.sql

# Backup specific tables
pg_dump -U scalecart -h localhost -d scalecart -t products -t orders > backup_partial.sql

# Restore database
pg_restore -U scalecart -h localhost -d scalecart -c backup.dump

# Restore from SQL
psql -U scalecart -h localhost -d scalecart < backup.sql

# Create a read replica
# In PostgreSQL configuration:
# wal_level = replica
# max_wal_senders = 10
# hot_standby = on
```

### I.3.2 PostgreSQL Performance Commands

```sql
-- ============================================
-- POSTGRESQL PERFORMANCE MONITORING
-- ============================================

-- Show slow queries
SELECT 
    query, 
    calls, 
    total_time / 1000 AS total_seconds,
    mean_time / 1000 AS avg_ms,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Show most frequent queries
SELECT 
    query, 
    calls,
    mean_time / 1000 AS avg_ms
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- Show table access statistics
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    ROUND(100.0 * idx_scan / GREATEST(seq_scan + idx_scan, 1), 2) AS index_usage_pct
FROM pg_stat_user_tables
ORDER BY seq_scan DESC
LIMIT 20;

-- Show index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan ASC
LIMIT 20;

-- Show locks
SELECT 
    l.locktype,
    l.relation::regclass AS table_name,
    l.mode,
    l.granted,
    a.pid,
    a.usename,
    a.query
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON l.pid = a.pid
WHERE NOT l.granted OR l.pid != pg_backend_pid();

-- Show replication lag
SELECT 
    client_addr,
    state,
    sync_state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS lag_bytes
FROM pg_stat_replication;
```

### I.3.3 MongoDB

```bash
# ============================================
# MONGODB CONNECTION COMMANDS
# ============================================

# Connect to MongoDB
docker compose exec mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin scalecart

# Connect from host
mongosh "mongodb://scalecart:scalecart_password@localhost:27017/scalecart"

# ============================================
# MONGODB DATABASE OPERATIONS
# ============================================

# List databases
show dbs

# Use database
use scalecart

# List collections
show collections

# Find documents
db.products.find().pretty()
db.products.find({ category_id: 5 }).limit(10)

# Count documents
db.products.countDocuments()

# Create index
db.products.createIndex({ "name": 1 })
db.products.createIndex({ "category_id": 1, "price": -1 })

# Show indexes
db.products.getIndexes()

# Drop index
db.products.dropIndex("name_1")

# Aggregation pipeline
db.products.aggregate([
    { $match: { price: { $gt: 100 } } },
    { $group: { _id: "$category_id", avg_price: { $avg: "$price" } } },
    { $sort: { avg_price: -1 } }
])

# ============================================
# MONGODB BACKUP & RESTORE
# ============================================

# Backup database
mongodump --uri="mongodb://scalecart:scalecart_password@localhost:27017/scalecart" --out=/backups/mongodb

# Backup specific collection
mongodump --uri="mongodb://scalecart:scalecart_password@localhost:27017/scalecart" --collection=products --out=/backups/mongodb

# Restore database
mongorestore --uri="mongodb://scalecart:scalecart_password@localhost:27017/scalecart" /backups/mongodb

# Restore specific collection
mongorestore --uri="mongodb://scalecart:scalecart_password@localhost:27017/scalecart" --collection=products /backups/mongodb/products.bson
```

### I.3.4 Redis

```bash
# ============================================
# REDIS CONNECTION COMMANDS
# ============================================

# Connect to Redis CLI
docker compose exec redis redis-cli -a scalecart_password

# Connect from host
redis-cli -h localhost -p 6379 -a scalecart_password

# ============================================
# REDIS COMMANDS
# ============================================

# Get all keys
KEYS *

# Get key by pattern
KEYS session:*

# Get value
GET session:abc123

# Set value with TTL
SETEX product:1 3600 '{"name":"MacBook"}'

# Check key exists
EXISTS product:1

# Delete key
DEL product:1

# Get TTL
TTL product:1

# Hash operations
HSET user:42 name "John" email "john@example.com"
HGET user:42 name
HGETALL user:42

# Set operations
SADD category:5 products 1 2 3
SMEMBERS category:5:products
SISMEMBER category:5:products 1

# Sorted set operations
ZADD ranking 100.0 product:1 95.0 product:2
ZREVRANGE ranking 0 10 WITHSCORES

# List operations
LPUSH cart:user:42 product:1
LRANGE cart:user:42 0 -1

# Server info
INFO
INFO memory
INFO stats
INFO clients

# Monitor real-time commands
MONITOR

# ============================================
# REDIS BACKUP & RESTORE
# ============================================

# Save RDB snapshot (blocking)
SAVE

# Save RDB snapshot (non-blocking)
BGSAVE

# Backup RDB file
# RDB is located at /data/dump.rdb in container
docker compose exec redis cp /data/dump.rdb /backups/redis.rdb

# Restore RDB
# Stop Redis, copy dump.rdb, restart Redis

# Backup with CLI
redis-cli -a scalecart_password --rdb /backups/redis_dump.rdb

# AOF backup
# AOF file is at /data/appendonly.aof
```

### I.3.5 Neo4j

```bash
# ============================================
# NEO4J CONNECTION COMMANDS
# ============================================

# Connect to Cypher shell
docker compose exec neo4j cypher-shell -u neo4j -p scalecart_neo4j_password

# Connect from browser
# Open http://localhost:7474

# ============================================
# CYPHER QUERY EXAMPLES
# ============================================

# Show all nodes
MATCH (n) RETURN n LIMIT 25

# Show all relationships
MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 25

# Create node
CREATE (p:Product {id: 1, name: "MacBook", price: 2499.99})

# Create relationship
MATCH (c:Customer {id: 42})
MATCH (p:Product {id: 1})
CREATE (c)-[:BOUGHT {order_id: 1001}]->(p)

# Find product recommendations
MATCH (c:Customer {id: 42})-[:BOUGHT]->(p:Product)<-[:BOUGHT]-(other:Customer)-[:BOUGHT]->(rec:Product)
WHERE NOT (c)-[:BOUGHT]->(rec)
RETURN rec.name, COUNT(*) AS frequency
ORDER BY frequency DESC
LIMIT 10

# Find shortest path
MATCH (c:Customer {id: 42}), (p:Product {id: 5})
MATCH path = shortestPath((c)-[:BOUGHT*1..5]-(p))
RETURN path

# Delete all data
MATCH (n) DETACH DELETE n

# Show database info
CALL dbms.info()
CALL db.labels()
CALL db.relationshipTypes()

# ============================================
# NEO4J BACKUP & RESTORE
# ============================================

# Backup (enterprise only)
neo4j-admin backup --from=bolt://localhost:7687 --backup-dir=/backups/neo4j

# Restore
neo4j-admin restore --from=/backups/neo4j/backup.db

# Export database (community)
neo4j-admin dump --database=neo4j --to=/backups/neo4j.dump

# Load database
neo4j-admin load --from=/backups/neo4j.dump --database=neo4j --force
```

---

## I.4 Kubernetes Commands

### I.4.1 kubectl Basics

```bash
# ============================================
# KUBECTL BASIC COMMANDS
# ============================================

# Get cluster info
kubectl cluster-info

# Get nodes
kubectl get nodes

# Get pods in namespace
kubectl get pods -n scalecart

# Get all resources in namespace
kubectl get all -n scalecart

# Describe pod
kubectl describe pod scalecart-api-7d8f9b6c4-abc12 -n scalecart

# View pod logs
kubectl logs scalecart-api-7d8f9b6c4-abc12 -n scalecart

# Follow pod logs
kubectl logs -f scalecart-api-7d8f9b6c4-abc12 -n scalecart

# Exec into pod
kubectl exec -it scalecart-api-7d8f9b6c4-abc12 -n scalecart -- /bin/bash

# Port forward
kubectl port-forward pod/scalecart-api-7d8f9b6c4-abc12 8000:8000 -n scalecart

# ============================================
# KUBECTL DEPLOYMENT COMMANDS
# ============================================

# Create deployment
kubectl create deployment scalecart-api --image=scalecart/api:latest -n scalecart

# Apply manifest
kubectl apply -f k8s/deployment.yaml -n scalecart

# Delete deployment
kubectl delete deployment scalecart-api -n scalecart

# Rollout status
kubectl rollout status deployment/scalecart-api -n scalecart

# Rollout history
kubectl rollout history deployment/scalecart-api -n scalecart

# Rollback deployment
kubectl rollout undo deployment/scalecart-api -n scalecart

# Scale deployment
kubectl scale deployment scalecart-api --replicas=5 -n scalecart

# Edit deployment
kubectl edit deployment scalecart-api -n scalecart

# ============================================
# KUBECTL SERVICE COMMANDS
# ============================================

# List services
kubectl get svc -n scalecart

# Describe service
kubectl describe svc scalecart-api -n scalecart

# Expose deployment
kubectl expose deployment scalecart-api --port=8000 --target-port=8000 -n scalecart

# ============================================
# KUBECTL INGRESS COMMANDS
# ============================================

# List ingresses
kubectl get ingress -n scalecart

# Describe ingress
kubectl describe ingress scalecart-ingress -n scalecart

# ============================================
# KUBECTL CONFIGMAP & SECRETS
# ============================================

# Get configmaps
kubectl get configmap -n scalecart

# Describe configmap
kubectl describe configmap scalecart-config -n scalecart

# Create configmap from file
kubectl create configmap scalecart-config --from-file=app.conf -n scalecart

# Create secret
kubectl create secret generic scalecart-secrets --from-literal=password=secret -n scalecart

# Get secrets
kubectl get secrets -n scalecart

# Decode secret
kubectl get secret scalecart-secrets -o jsonpath='{.data.password}' | base64 -d

# ============================================
# KUBECTL TROUBLESHOOTING
# ============================================

# Check events
kubectl get events -n scalecart --sort-by='.lastTimestamp'

# Check node status
kubectl describe nodes

# Check pod status and reasons
kubectl get pods -n scalecart --output=wide

# Check resource usage (requires metrics-server)
kubectl top pods -n scalecart
kubectl top nodes

# Check if service is accessible
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl -v http://scalecart-api:8000/health

# ============================================
# KUBECTL CONTEXT & NAMESPACE
# ============================================

# Get current context
kubectl config current-context

# Set namespace
kubectl config set-context --current --namespace=scalecart

# Create namespace
kubectl create namespace scalecart

# Delete namespace
kubectl delete namespace scalecart
```

### I.4.2 Helm Commands

```bash
# ============================================
# HELM COMMANDS
# ============================================

# Add a repository
helm repo add scalecart https://charts.scalecart.com

# Update repositories
helm repo update

# Search for charts
helm search repo scalecart

# Install chart
helm install scalecart scalecart/scalecart -n scalecart --create-namespace

# Install with values
helm install scalecart scalecart/scalecart -n scalecart -f values.yaml

# Upgrade release
helm upgrade scalecart scalecart/scalecart -n scalecart -f values.yaml

# Rollback release
helm rollback scalecart 1 -n scalecart

# List releases
helm list -n scalecart

# Get release history
helm history scalecart -n scalecart

# Uninstall release
helm uninstall scalecart -n scalecart

# Package chart
helm package ./chart

# Lint chart
helm lint ./chart

# Template chart (render manifests)
helm template scalecart ./chart -n scalecart
```

---

## I.5 AWS CLI Commands

### I.5.1 ECS Commands

```bash
# ============================================
# AWS ECS COMMANDS
# ============================================

# List clusters
aws ecs list-clusters

# Describe cluster
aws ecs describe-clusters --clusters scalecart-production

# List services
aws ecs list-services --cluster scalecart-production

# Describe service
aws ecs describe-services --cluster scalecart-production --services scalecart-api

# Update service
aws ecs update-service \
  --cluster scalecart-production \
  --service scalecart-api \
  --task-definition scalecart-api:v10 \
  --force-new-deployment

# Scale service
aws ecs update-service \
  --cluster scalecart-production \
  --service scalecart-api \
  --desired-count 5

# List tasks
aws ecs list-tasks --cluster scalecart-production

# Describe tasks
aws ecs describe-tasks --cluster scalecart-production --tasks arn:aws:ecs:...

# Stop task
aws ecs stop-task --cluster scalecart-production --task arn:aws:ecs:...

# Run task (one-off)
aws ecs run-task \
  --cluster scalecart-production \
  --task-definition scalecart-api \
  --overrides '{"containerOverrides":[{"name":"api","command":["python","manage.py","migrate"]}]}'

# ============================================
# AWS ECR COMMANDS
# ============================================

# List repositories
aws ecr describe-repositories

# Create repository
aws ecr create-repository --repository-name scalecart-api

# Get login password
aws ecr get-login-password --region us-east-1

# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# List images
aws ecr list-images --repository-name scalecart-api

# Delete image
aws ecr batch-delete-image \
  --repository-name scalecart-api \
  --image-ids imageTag=old-tag
```

### I.5.2 RDS Commands

```bash
# ============================================
# AWS RDS COMMANDS
# ============================================

# List databases
aws rds describe-db-instances

# Create snapshot
aws rds create-db-snapshot \
  --db-instance-identifier scalecart-prod \
  --db-snapshot-identifier scalecart-prod-snapshot-$(date +%Y%m%d)

# List snapshots
aws rds describe-db-snapshots --db-instance-identifier scalecart-prod

# Restore snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier scalecart-prod-restored \
  --db-snapshot-identifier scalecart-prod-snapshot-20260101

# Start database
aws rds start-db-instance --db-instance-identifier scalecart-prod

# Stop database
aws rds stop-db-instance --db-instance-identifier scalecart-prod

# Modify database
aws rds modify-db-instance \
  --db-instance-identifier scalecart-prod \
  --instance-class db.r5.large \
  --apply-immediately
```

### I.5.3 S3 Commands

```bash
# ============================================
# AWS S3 COMMANDS
# ============================================

# List buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://scalecart-backups/

# Sync to bucket
aws s3 sync ./backups/ s3://scalecart-backups/prod/$(date +%Y%m%d)/

# Download from bucket
aws s3 cp s3://scalecart-backups/prod/20260101/backup.dump ./backup.dump

# Delete old backups (older than 30 days)
aws s3 ls s3://scalecart-backups/ | \
  awk '{print $2}' | \
  while read folder; do
    if [[ $(date -d "$folder" +%s 2>/dev/null) -lt $(date -d "30 days ago" +%s) ]]; then
      aws s3 rm s3://scalecart-backups/$folder --recursive
    fi
  done

# Generate presigned URL
aws s3 presign s3://scalecart-backups/backup.dump --expires-in 3600
```

---

## I.6 Development Commands

### I.6.1 Python & pip

```bash
# ============================================
# PYTHON ENVIRONMENT
# ============================================

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

# Deactivate
deactivate

# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .

# Show installed packages
pip list

# Check outdated packages
pip list --outdated

# Update a package
pip install --upgrade package-name

# Freeze dependencies
pip freeze > requirements.txt

# ============================================
# PYTHON DEVELOPMENT TOOLS
# ============================================

# Run black formatter
black src/ tests/

# Run isort (import sorting)
isort src/ tests/

# Run flake8 linter
flake8 src/ tests/

# Run mypy type checker
mypy src/

# Run pytest
pytest -v

# Run pytest with coverage
pytest --cov=src --cov-report=html

# Run specific test
pytest tests/test_services.py -v
pytest tests/test_services.py::TestOrderService::test_place_order -v

# Run with debug
pytest --pdb -v
```

### I.6.2 Alembic Migrations

```bash
# ============================================
# ALEMBIC MIGRATION COMMANDS
# ============================================

# Create new migration
alembic revision --autogenerate -m "description"

# Create empty migration
alembic revision -m "description"

# Apply migrations (upgrade)
alembic upgrade head

# Upgrade to specific version
alembic upgrade <revision-id>

# Upgrade by +1
alembic upgrade +1

# Rollback migrations (downgrade)
alembic downgrade -1

# Rollback to specific version
alembic downgrade <revision-id>

# Show current version
alembic current

# Show migration history
alembic history

# Show migration graph
alembic graph

# Set to a specific version (dangerous)
alembic stamp <revision-id>

# Reset to base
alembic stamp base
```

### I.6.3 Git Commands

```bash
# ============================================
# GIT BASIC COMMANDS
# ============================================

# Clone repository
git clone https://github.com/username/scalecart.git

# Check status
git status

# Add files
git add .
git add src/models/product.py

# Commit
git commit -m "feat: add product model"

# Commit with detailed message
git commit -m "feat: add product model

- Add Product model with fields
- Add Category relationship
- Add inventory tracking"

# Push
git push origin main

# Pull latest
git pull origin main

# ============================================
# GIT BRANCHING
# ============================================

# Create branch
git checkout -b feature/add-product-api

# Switch branch
git checkout main

# List branches
git branch -a

# Delete branch
git branch -d feature/add-product-api

# Merge branch
git checkout main
git merge feature/add-product-api

# ============================================
# GIT STASHING
# ============================================

# Stash changes
git stash

# Stash with message
git stash push -m "WIP: product API"

# List stashes
git stash list

# Apply stash
git stash pop

# Apply stash without removing
git stash apply

# ============================================
# GIT LOGGING
# ============================================

# View commit history
git log --oneline

# View commit graph
git log --graph --oneline --all

# Show commit
git show <commit-hash>

# Search commits
git log --grep="product" --oneline

# ============================================
# GIT RESET
# ============================================

# Unstage files
git reset HEAD <file>

# Uncommit (keep changes)
git reset --soft HEAD~1

# Uncommit (discard changes)
git reset --hard HEAD~1

# Reset to specific commit
git reset --hard <commit-hash>
```

---

## I.7 Monitoring & Troubleshooting

### I.7.1 Health Checks

```bash
# ============================================
# HEALTH CHECK COMMANDS
# ============================================

# Basic health check
curl http://localhost:8000/health

# Readiness check
curl http://localhost:8000/health/ready

# Full health check (all services)
curl http://localhost:8000/health/full

# With jq for pretty output
curl -s http://localhost:8000/health/full | jq '.'

# Check with timeout
curl -f --max-time 5 http://localhost:8000/health || echo "Service unhealthy"

# ============================================
# SYSTEM DIAGNOSTICS
# ============================================

# Check all service status
docker compose ps

# Check resource usage
docker compose stats --no-stream

# Check disk usage
df -h

# Check memory usage
free -h

# Check CPU
top -n 1

# Check network
netstat -tulpn

# Check open file descriptors
lsof -i -P -n | grep LISTEN

# Check process
ps aux | grep python
ps aux | grep postgres
```

### I.7.2 Log Analysis

```bash
# ============================================
# LOG VIEWING COMMANDS
# ============================================

# View all logs
docker compose logs

# View logs with timestamps
docker compose logs --timestamps

# View last 100 lines
docker compose logs --tail=100

# View logs since time
docker compose logs --since=1h

# Follow logs with grep
docker compose logs -f | grep ERROR

# View specific service logs
docker compose logs api
docker compose logs postgres

# View logs in JSON format
docker compose logs --no-color | jq '.'

# ============================================
# LOG ROTATION AND CLEANUP
# ============================================

# Show log sizes
docker compose logs --tail=0 2>/dev/null | wc -c

# Clean up container logs
docker system prune -f

# Clean up all unused resources
docker system prune -a -f
```

### I.7.3 Performance Troubleshooting

```bash
# ============================================
# SLOW QUERY DETECTION
# ============================================

# Find slow queries from pg_stat_statements
psql -U scalecart -d scalecart -c "
SELECT 
    query, 
    calls, 
    total_time / 1000 AS total_seconds,
    mean_time / 1000 AS avg_ms
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
"

# Find long running queries
psql -U scalecart -d scalecart -c "
SELECT 
    pid,
    usename,
    NOW() - query_start AS duration,
    state,
    query
FROM pg_stat_activity
WHERE state = 'active' 
  AND NOW() - query_start > INTERVAL '5 seconds'
  AND pid != pg_backend_pid();
"

# Check table bloat
psql -U scalecart -d scalecart -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    n_dead_tup,
    n_live_tup,
    ROUND(n_dead_tup * 100.0 / GREATEST(n_live_tup, 1), 2) AS dead_pct
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY dead_pct DESC;
"

# Check cache hit ratio
psql -U scalecart -d scalecart -c "
SELECT 
    'cache_hit_ratio' AS metric,
    ROUND(100.0 * sum(heap_blks_hit) / GREATEST(sum(heap_blks_hit) + sum(heap_blks_read), 1), 2) AS ratio
FROM pg_statio_user_tables;
"
```

---

## I.8 Quick Reference Cards

### I.8.1 Database Connection Strings

```bash
# PostgreSQL
postgresql://scalecart:scalecart_password@localhost:5432/scalecart

# MongoDB
mongodb://scalecart:scalecart_password@localhost:27017/scalecart

# Redis
redis://:scalecart_password@localhost:6379/0

# Neo4j
bolt://neo4j:scalecart_neo4j_password@localhost:7687

# TimescaleDB
postgresql://scalecart:scalecart_password@localhost:5433/scalecart_metrics
```

### I.8.2 Service Ports

| Service | Port | URL |
|---------|------|-----|
| API | 8000 | http://localhost:8000 |
| API Docs | 8000 | http://localhost:8000/docs |
| PostgreSQL | 5432 | postgresql://localhost:5432 |
| MongoDB | 27017 | mongodb://localhost:27017 |
| Redis | 6379 | redis://localhost:6379 |
| Neo4j HTTP | 7474 | http://localhost:7474 |
| Neo4j Bolt | 7687 | bolt://localhost:7687 |
| TimescaleDB | 5433 | postgresql://localhost:5433 |
| Prometheus | 9090 | http://localhost:9090 |
| Grafana | 3000 | http://localhost:3000 |
| PgBouncer | 6432 | postgresql://localhost:6432 |

### I.8.3 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| PostgreSQL | scalecart | scalecart_password |
| MongoDB | scalecart | scalecart_password |
| Redis | - | scalecart_password |
| Neo4j | neo4j | scalecart_neo4j_password |
| TimescaleDB | scalecart | scalecart_password |
| Grafana | admin | admin |

### I.8.4 Useful Environment Variables

```bash
# Database connections
DATABASE_URL=postgresql://scalecart:scalecart_password@postgres:5432/scalecart
REDIS_URL=redis://:scalecart_password@redis:6379/0
MONGODB_URI=mongodb://scalecart:scalecart_password@mongodb:27017/scalecart
NEO4J_URI=bolt://neo4j:7687
TIMESCALE_URL=postgresql://scalecart:scalecart_password@timescaledb:5432/scalecart_metrics

# Application
APP_ENV=development
DEBUG=true
SECRET_KEY=your-secret-key
LOG_LEVEL=INFO

# Performance
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=40
PRODUCT_CACHE_TTL=3600
SESSION_TTL=86400
```

---

## I.9 Scripts Reference

### I.9.1 Quick Status Script

```bash
#!/bin/bash
# File: scripts/status.sh
# Quick status check for all services

echo "=================================="
echo "ScaleCart System Status"
echo "=================================="
echo ""

# Check Docker services
echo "🐳 Docker Services:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Check API health
echo "🌐 API Health:"
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health
echo ""

# Check database connections
echo "💾 Database Status:"
docker compose exec -T postgres pg_isready -U scalecart 2>/dev/null || echo "Not ready"
echo ""

# Check Redis
echo "📦 Redis Status:"
docker compose exec -T redis redis-cli -a scalecart_password ping 2>/dev/null || echo "Not ready"
echo ""

echo "=================================="
echo "Disk Usage:"
df -h / | awk 'NR==2 {print "Used: " $3 " / " $2 " (" $5 ")"}'
echo ""
echo "Memory Usage:"
free -h | awk 'NR==2 {print "Used: " $3 " / " $2 " (" $3/$2*100 "%" ")"}'
echo ""

echo "=================================="
echo "Container Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPct}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""
```

### I.9.2 Health Check Loop

```bash
#!/bin/bash
# File: scripts/health-loop.sh
# Continuously check health

while true; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
    if [ "$STATUS" != "200" ]; then
        echo "⚠️  Health check failed with status: $STATUS"
    else
        echo "✅ Health check passed"
    fi
    sleep 10
done
```

---

**[END OF APPENDIX I]**

*This comprehensive command reference provides everything needed for day-to-day operations of the ScaleCart platform. Bookmark this page for quick access to all essential commands.*
