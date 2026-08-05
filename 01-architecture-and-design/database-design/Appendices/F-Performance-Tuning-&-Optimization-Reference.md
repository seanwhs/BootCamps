# APPENDIX F — Performance Tuning & Optimization Reference

## Complete Performance Optimization Guide for ScaleCart

---

## F.1 Introduction

This appendix provides a comprehensive reference for performance tuning and optimization across the entire ScaleCart stack. It covers:

1. **Database Performance Tuning** – PostgreSQL, MongoDB, Redis, Neo4j
2. **Query Optimization** – Writing efficient queries
3. **Application Performance** – Code optimization and caching strategies
4. **Infrastructure Tuning** – OS, network, and hardware optimization
5. **Monitoring & Profiling** – Identifying performance bottlenecks
6. **Optimization Checklist** – Quick reference for common issues

---

## F.2 PostgreSQL Performance Tuning

### F.2.1 Configuration Parameters

```ini
# File: postgresql-performance.conf
# Comprehensive PostgreSQL performance configuration

# ============================================
# MEMORY SETTINGS
# ============================================

# Shared memory for database buffers (25-40% of RAM)
shared_buffers = '4GB'                      # For 16GB RAM system
# shared_buffers = '8GB'                    # For 32GB RAM system

# Memory for sort operations (per operation)
work_mem = '64MB'                           # For OLTP workloads
# work_mem = '256MB'                        # For analytical workloads

# Memory for maintenance operations (VACUUM, CREATE INDEX)
maintenance_work_mem = '1GB'                # Increase for large operations

# Estimated memory available for OS cache
effective_cache_size = '12GB'               # 75% of total RAM

# ============================================
# WRITE-AHEAD LOG (WAL) SETTINGS
# ============================================

# WAL buffer size
wal_buffers = '64MB'

# Checkpoint tuning
checkpoint_completion_target = 0.9          # Spread checkpoint I/O
max_wal_size = '20GB'
min_wal_size = '5GB'
checkpoint_timeout = '15min'

# WAL compression (reduces I/O)
wal_compression = on

# ============================================
# QUERY TUNING
# ============================================

# Cost parameters (adjust for storage type)
random_page_cost = 1.1                      # For SSD
# random_page_cost = 4.0                    # For HDD
effective_io_concurrency = 200              # For SSD
# effective_io_concurrency = 2             # For HDD

# Parallel query settings
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
parallel_tuple_cost = 0.1
parallel_setup_cost = 1000.0

# Join optimization
join_collapse_limit = 8
from_collapse_limit = 8

# ============================================
# CONNECTION SETTINGS
# ============================================

max_connections = 200                       # Adjust based on application
superuser_reserved_connections = 3
tcp_keepalives_idle = 60
tcp_keepalives_interval = 10
tcp_keepalives_count = 5

# ============================================
# AUTOVACUUM SETTINGS
# ============================================

autovacuum = on
autovacuum_vacuum_scale_factor = 0.05       # More aggressive vacuum
autovacuum_analyze_scale_factor = 0.02
autovacuum_vacuum_threshold = 1000
autovacuum_analyze_threshold = 500
autovacuum_vacuum_cost_limit = 1000         # Faster vacuum
autovacuum_naptime = '10s'

# ============================================
# LOGGING (Performance Monitoring)
# ============================================

log_min_duration_statement = 1000           # Log queries > 1 second
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 1000

# ============================================
# STATISTICS COLLECTION
# ============================================

# Increase statistics for columns with skewed distributions
# Set per table/column:
ALTER TABLE products ALTER COLUMN category_id SET STATISTICS 1000;
ALTER TABLE orders ALTER COLUMN customer_id SET STATISTICS 1000;

# Update statistics regularly
ANALYZE products;
ANALYZE orders;
ANALYZE customers;

# ============================================
# EXTENSIONS FOR PERFORMANCE
# ============================================

# pg_stat_statements for query monitoring
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 10000

# pg_buffercache for cache hit analysis
# pg_prewarm for warming up buffer cache
```

### F.2.2 Index Optimization Queries

```sql
-- Find missing indexes (queries with many sequential scans)
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    seq_tup_read / seq_scan AS avg_rows_per_scan,
    CASE WHEN seq_scan > 0 THEN seq_tup_read / seq_scan ELSE 0 END AS rows_per_scan
FROM pg_stat_user_tables
WHERE seq_scan > 0
  AND seq_scan > idx_scan * 10
  AND seq_tup_read / seq_scan > 1000
ORDER BY seq_scan DESC;

-- Find unused indexes (wasting resources)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Find duplicate indexes
SELECT 
    pg_class.relname AS table_name,
    pg_index.indisunique,
    pg_index.indisprimary,
    array_to_string(array_agg(pg_attribute.attname), ', ') AS columns
FROM pg_index
JOIN pg_class ON pg_index.indrelid = pg_class.oid
JOIN pg_attribute ON pg_attribute.attrelid = pg_class.oid
    AND pg_attribute.attnum = ANY(pg_index.indkey)
WHERE pg_class.relkind = 'r'
  AND pg_class.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
GROUP BY pg_class.relname, pg_index.indisunique, pg_index.indisprimary, pg_index.indkey
HAVING COUNT(*) > 1;

-- Check index usage ratio
SELECT 
    relname,
    seq_scan,
    idx_scan,
    CASE 
        WHEN seq_scan + idx_scan > 0 THEN 
            ROUND(100.0 * idx_scan / (seq_scan + idx_scan), 2)
        ELSE 0 
    END AS index_usage_pct
FROM pg_stat_user_tables
ORDER BY index_usage_pct ASC;
```

### F.2.3 Query Tuning Best Practices

```sql
-- 1. Use EXPLAIN ANALYZE to understand query plans
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT 
    p.id,
    p.name,
    c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE p.price BETWEEN 100 AND 1000
  AND p.created_at > '2025-01-01'
ORDER BY p.created_at DESC
LIMIT 100;

-- 2. Use CTEs for complex queries (better readability, sometimes performance)
WITH category_stats AS (
    SELECT 
        category_id,
        COUNT(*) AS product_count,
        AVG(price) AS avg_price
    FROM products
    GROUP BY category_id
)
SELECT 
    c.name,
    cs.product_count,
    cs.avg_price
FROM categories c
JOIN category_stats cs ON c.id = cs.category_id
WHERE cs.product_count > 100
ORDER BY cs.avg_price DESC;

-- 3. Use materialized views for expensive aggregations
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    DATE(order_date) AS sale_date,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered')
GROUP BY DATE(order_date)
WITH DATA;

-- Refresh materialized view
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_summary;

-- 4. Use window functions for analytical queries
SELECT 
    id,
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY order_date
    ) AS cumulative_spent,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id 
        ORDER BY order_date DESC
    ) AS order_rank
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered');

-- 5. Use partial indexes for common filters
CREATE INDEX idx_orders_active ON orders(customer_id) 
WHERE status NOT IN ('cancelled', 'refunded');

-- 6. Use expression indexes for computed columns
CREATE INDEX idx_orders_year_month ON orders(EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date));
```

---

## F.3 MongoDB Performance Tuning

### F.3.1 Index Recommendations

```javascript
// File: mongodb-indexes.js

// 1. Index for product queries
db.product_cache.createIndex({ "category_id": 1 });
db.product_cache.createIndex({ "name": "text" });
db.product_cache.createIndex({ "price": 1 });
db.product_cache.createIndex({ "created_at": -1 });

// 2. Composite indexes for common query patterns
db.product_cache.createIndex({ "category_id": 1, "price": -1 });
db.product_cache.createIndex({ "name": "text", "category_id": 1 });

// 3. TTL index for cache expiration
db.product_cache.createIndex(
    { "created_at": 1 },
    { expireAfterSeconds: 3600 }
);

// 4. Sparse indexes for optional fields
db.product_cache.createIndex(
    { "features": 1 },
    { sparse: true }
);

// 5. Unique indexes
db.product_cache.createIndex(
    { "sku": 1 },
    { unique: true }
);
```

### F.3.2 Query Optimization

```javascript
// Use projection to limit returned fields
db.product_cache.find(
    { category_id: 5 },
    { name: 1, price: 1, _id: 0 }
);

// Use limit for pagination
db.product_cache.find({}).skip(100).limit(20);

// Use aggregation pipeline for complex queries
db.product_cache.aggregate([
    { $match: { category_id: 5 } },
    { $group: {
        _id: "$category_id",
        avg_price: { $avg: "$price" },
        count: { $sum: 1 }
    }},
    { $sort: { avg_price: -1 } }
]);

// Use explain to analyze queries
db.product_cache.find({ category_id: 5 }).explain("executionStats");
```

### F.3.3 Configuration

```yaml
# mongod.conf for performance
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
  logRotate: reopen

storage:
  dbPath: /data/db
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 8                    # 50-60% of RAM
      journalCompressor: snappy
    collectionConfig:
      blockCompressor: snappy
    indexConfig:
      prefixCompression: true

net:
  port: 27017
  maxIncomingConnections: 1000
  serviceExecutor: adaptive

operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100

# Connection pool settings in application
# maxPoolSize: 100
# minPoolSize: 10
# maxIdleTimeMS: 300000
# waitQueueTimeoutMS: 5000
```

---

## F.4 Redis Performance Tuning

### F.4.1 Redis Configuration

```conf
# redis-performance.conf

# Memory management
maxmemory 512mb
maxmemory-policy allkeys-lru
maxmemory-samples 5

# Persistence (balance performance vs durability)
save 900 1
save 300 10
save 60 10000

# Append-only file (AOF) settings
appendonly yes
appendfsync everysec
no-appendfsync-on-rewrite yes
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# Performance tuning
tcp-backlog 511
timeout 0
tcp-keepalive 300

# Lazy freeing (non-blocking)
lazyfree-lazy-eviction yes
lazyfree-lazy-expire yes
lazyfree-lazy-server-del yes
replica-lazy-flush yes

# Slow log
slowlog-log-slower-than 10000
slowlog-max-len 128

# Disable certain commands for security
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""
```

### F.4.2 Redis Optimization Patterns

```python
# File: src/utils/redis_optimizations.py
import redis
import json
from typing import Any, Optional
from functools import lru_cache

class OptimizedRedis:
    def __init__(self, connection_pool):
        self.redis = redis.Redis(connection_pool=connection_pool)
    
    # 1. Use pipelines for batch operations
    def batch_get(self, keys: list) -> dict:
        """Efficiently get multiple keys using pipeline."""
        pipeline = self.redis.pipeline()
        for key in keys:
            pipeline.get(key)
        results = pipeline.execute()
        return {key: value for key, value in zip(keys, results)}
    
    # 2. Use Redis Hash for structured data
    def store_product(self, product_id: int, data: dict):
        """Store product as hash for efficient field access."""
        key = f"product:{product_id}"
        self.redis.hset(key, mapping=data)
        self.redis.expire(key, 3600)  # 1 hour TTL
    
    def get_product_field(self, product_id: int, field: str) -> Optional[str]:
        """Get specific field without fetching entire hash."""
        return self.redis.hget(f"product:{product_id}", field)
    
    # 3. Use Redis Sets for relationships
    def add_to_category(self, category_id: int, product_id: int):
        """Maintain product-category relationship in set."""
        self.redis.sadd(f"category:{category_id}:products", product_id)
    
    def get_category_products(self, category_id: int) -> list:
        """Get products in category efficiently."""
        return list(self.redis.smembers(f"category:{category_id}:products"))
    
    # 4. Use Redis Sorted Sets for rankings
    def update_product_rank(self, product_id: int, score: float):
        """Update product ranking score."""
        self.redis.zadd("product_ranking", {product_id: score})
    
    def get_top_products(self, limit: int = 10) -> list:
        """Get top products by score."""
        return self.redis.zrevrange("product_ranking", 0, limit - 1, withscores=True)
    
    # 5. Use Lua scripts for atomic operations
    def atomic_increment_with_ttl(self, key: str, max_value: int, ttl: int) -> int:
        """Atomic operation with Redis Lua script."""
        lua_script = """
        local current = redis.call('GET', KEYS[1])
        if not current then
            redis.call('SET', KEYS[1], 1, 'EX', ARGV[2])
            return 1
        end
        current = tonumber(current)
        if current >= tonumber(ARGV[1]) then
            return -1
        end
        local new_value = current + 1
        redis.call('SET', KEYS[1], new_value, 'EX', ARGV[2])
        return new_value
        """
        return self.redis.eval(lua_script, 1, key, max_value, ttl)
    
    # 6. Cache with cache-aside pattern
    @lru_cache(maxsize=1024)
    def cached_expensive_operation(self, arg: str) -> Any:
        """Cache expensive operations in Python LRU."""
        return self._expensive_operation(arg)
    
    def _expensive_operation(self, arg: str) -> Any:
        """Simulate expensive operation."""
        # Would be expensive computation or database query
        pass
```

---

## F.5 Application Performance Optimization

### F.5.1 Python Code Optimization

```python
# File: src/utils/performance_optimizations.py
import asyncio
import concurrent.futures
from functools import lru_cache, wraps
import time
from typing import Any, Callable

class PerformanceOptimizer:
    """Performance optimization utilities."""
    
    @staticmethod
    def timer(func: Callable) -> Callable:
        """Decorator to time function execution."""
        @wraps(func)
        def wrapper(*args, **kwargs):
            start = time.perf_counter()
            result = func(*args, **kwargs)
            end = time.perf_counter()
            duration = end - start
            print(f"{func.__name__} took {duration:.4f}s")
            return result
        return wrapper
    
    @staticmethod
    def cache(maxsize: int = 128):
        """Decorator for LRU caching."""
        def decorator(func):
            @lru_cache(maxsize=maxsize)
            def wrapper(*args, **kwargs):
                return func(*args, **kwargs)
            return wrapper
        return decorator
    
    @staticmethod
    def retry(max_attempts: int = 3, delay: float = 1.0, backoff: float = 2.0):
        """Decorator for retry logic with exponential backoff."""
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                current_delay = delay
                for attempt in range(max_attempts):
                    try:
                        return func(*args, **kwargs)
                    except Exception as e:
                        if attempt == max_attempts - 1:
                            raise
                        time.sleep(current_delay)
                        current_delay *= backoff
            return wrapper
        return decorator
    
    @staticmethod
    def async_batch(limit: int = 100):
        """Decorator to batch async operations."""
        def decorator(func):
            @wraps(func)
            async def wrapper(items, *args, **kwargs):
                results = []
                for i in range(0, len(items), limit):
                    batch = items[i:i + limit]
                    batch_results = await asyncio.gather(
                        *[func(item, *args, **kwargs) for item in batch]
                    )
                    results.extend(batch_results)
                return results
            return wrapper
        return decorator

# Usage examples
@PerformanceOptimizer.timer
def expensive_operation():
    """Simulate expensive operation."""
    time.sleep(1)
    return "Done"

@PerformanceOptimizer.cache(maxsize=100)
def cached_query(product_id: int):
    """Cached database query."""
    # This would be a database query
    return {"id": product_id, "data": f"Product {product_id}"}

@PerformanceOptimizer.retry(max_attempts=3, delay=0.5)
def flaky_api_call():
    """Retry flaky API calls."""
    import requests
    response = requests.get("https://api.example.com/data")
    response.raise_for_status()
    return response.json()

# Async batch processing
@PerformanceOptimizer.async_batch(limit=50)
async def process_item(item_id: int):
    """Process item in batch."""
    await asyncio.sleep(0.1)
    return f"Processed {item_id}"
```

### F.5.2 Database Connection Pooling

```python
# File: src/utils/connection_pool.py
import psycopg2
from psycopg2 import pool
import redis
from pymongo import MongoClient
from neo4j import GraphDatabase
import os

class ConnectionPoolManager:
    """Centralized connection pool management."""
    
    _postgres_pool = None
    _redis_pool = None
    _mongo_client = None
    _neo4j_driver = None
    
    @classmethod
    def get_postgres_pool(cls):
        """Get or create PostgreSQL connection pool."""
        if cls._postgres_pool is None:
            cls._postgres_pool = psycopg2.pool.SimpleConnectionPool(
                minconn=5,
                maxconn=20,
                host=os.getenv("POSTGRES_HOST", "localhost"),
                port=os.getenv("POSTGRES_PORT", 5432),
                user=os.getenv("POSTGRES_USER", "scalecart"),
                password=os.getenv("POSTGRES_PASSWORD", "scalecart_password"),
                dbname=os.getenv("POSTGRES_DB", "scalecart"),
                keepalives=1,
                keepalives_idle=60,
                keepalives_interval=10,
                keepalives_count=5
            )
        return cls._postgres_pool
    
    @classmethod
    def get_redis_pool(cls):
        """Get or create Redis connection pool."""
        if cls._redis_pool is None:
            cls._redis_pool = redis.ConnectionPool(
                host=os.getenv("REDIS_HOST", "localhost"),
                port=int(os.getenv("REDIS_PORT", 6379)),
                password=os.getenv("REDIS_PASSWORD", "scalecart_password"),
                decode_responses=True,
                max_connections=50,
                socket_timeout=5,
                socket_connect_timeout=5,
                retry_on_timeout=True
            )
        return cls._redis_pool
    
    @classmethod
    def get_mongo_client(cls):
        """Get or create MongoDB client."""
        if cls._mongo_client is None:
            cls._mongo_client = MongoClient(
                os.getenv("MONGO_URI", "mongodb://localhost:27017"),
                maxPoolSize=50,
                minPoolSize=10,
                maxIdleTimeMS=300000,
                waitQueueTimeoutMS=5000,
                socketTimeoutMS=10000,
                connectTimeoutMS=5000,
                serverSelectionTimeoutMS=5000
            )
        return cls._mongo_client
    
    @classmethod
    def get_neo4j_driver(cls):
        """Get or create Neo4j driver."""
        if cls._neo4j_driver is None:
            cls._neo4j_driver = GraphDatabase.driver(
                os.getenv("NEO4J_URI", "bolt://localhost:7687"),
                auth=(
                    os.getenv("NEO4J_USER", "neo4j"),
                    os.getenv("NEO4J_PASSWORD", "scalecart_neo4j_password")
                ),
                max_connection_pool_size=50,
                connection_acquisition_timeout=10,
                max_transaction_retry_time=30
            )
        return cls._neo4j_driver
    
    @classmethod
    def close_all(cls):
        """Close all connection pools."""
        if cls._postgres_pool:
            cls._postgres_pool.closeall()
        if cls._redis_pool:
            cls._redis_pool.disconnect()
        if cls._mongo_client:
            cls._mongo_client.close()
        if cls._neo4j_driver:
            cls._neo4j_driver.close()
```

---

## F.6 Infrastructure Performance Tuning

### F.6.1 Linux OS Tuning

```bash
#!/bin/bash
# File: scripts/tune_os.sh
# Linux performance tuning for ScaleCart

# ============================================
# FILESYSTEM TUNING
# ============================================

# Mount options for database volumes
# Add to /etc/fstab:
# /dev/sdb /data ext4 defaults,noatime,nodiratime,data=ordered,commit=60 0 0

# Filesystem cache settings
echo "vm.dirty_ratio = 40" >> /etc/sysctl.conf
echo "vm.dirty_background_ratio = 10" >> /etc/sysctl.conf
echo "vm.dirty_expire_centisecs = 6000" >> /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf

# ============================================
# NETWORK TUNING
# ============================================

# TCP settings
echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 5000" >> /etc/sysctl.conf
echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf
echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 87380 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 16777216" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf
echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 10000 65535" >> /etc/sysctl.conf

# ============================================
# PROCESS LIMITS
# ============================================

# Increase file descriptor limits
echo "fs.file-max = 1000000" >> /etc/sysctl.conf

# Update /etc/security/limits.conf:
# * soft nofile 100000
# * hard nofile 100000
# * soft nproc 100000
# * hard nproc 100000

# ============================================
# SWAP TUNING
# ============================================

# Set swappiness (reduce swap usage)
echo "vm.swappiness = 10" >> /etc/sysctl.conf

# ============================================
# DISK I/O SCHEDULER
# ============================================

# For SSDs (for each device):
# echo noop > /sys/block/sda/queue/scheduler
# echo 256 > /sys/block/sda/queue/nr_requests

# For HDDs:
# echo deadline > /sys/block/sda/queue/scheduler

# ============================================
# APPLY SETTINGS
# ============================================

sysctl -p

echo "OS tuning applied successfully"
```

### F.6.2 Docker Tuning

```yaml
# File: docker-compose.prod.yml with resource limits
services:
  postgres:
    image: postgres:15
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
    ulimits:
      nofile:
        soft: 100000
        hard: 100000
    sysctls:
      - net.core.somaxconn=1024
      - net.ipv4.tcp_tw_reuse=1

  redis:
    image: redis:7-alpine
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G

  mongodb:
    image: mongo:7.0
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G

  api:
    image: scalecart/api:latest
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

---

## F.7 Monitoring & Profiling

### F.7.1 Performance Monitoring Queries

```sql
-- PostgreSQL: Active queries with duration
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    wait_event_type,
    wait_event,
    query_start,
    NOW() - query_start AS duration,
    query
FROM pg_stat_activity
WHERE state = 'active'
  AND pid != pg_backend_pid()
ORDER BY duration DESC;

-- PostgreSQL: Cache hit ratio
SELECT 
    'cache_hit_ratio' AS metric,
    ROUND(100.0 * sum(heap_blks_hit) / 
          GREATEST(sum(heap_blks_hit) + sum(heap_blks_read), 1), 2) AS ratio
FROM pg_statio_user_tables;

-- PostgreSQL: Table access statistics
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    ROUND(100.0 * idx_scan / GREATEST(seq_scan + idx_scan, 1), 2) AS idx_usage_pct
FROM pg_stat_user_tables
WHERE seq_scan + idx_scan > 1000
ORDER BY seq_scan DESC
LIMIT 20;

-- PostgreSQL: Long-running transactions
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    NOW() - query_start AS duration,
    query
FROM pg_stat_activity
WHERE state IN ('idle in transaction', 'active')
  AND query_start < NOW() - INTERVAL '5 minutes'
ORDER BY duration DESC;

-- PostgreSQL: Locks
SELECT 
    l.locktype,
    l.relation::regclass AS table_name,
    l.mode,
    l.granted,
    l.transactionid,
    a.pid,
    a.usename,
    a.query_start,
    a.state,
    a.query
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON l.pid = a.pid
WHERE NOT l.granted
   OR l.pid != pg_backend_pid()
ORDER BY l.granted, a.query_start;
```

### F.7.2 Application Profiling

```python
# File: src/utils/profiler.py
import cProfile
import pstats
import io
import functools
import time
from contextlib import contextmanager
from typing import Callable, Any

class Profiler:
    """Application profiling utilities."""
    
    @staticmethod
    @contextmanager
    def profile(output_file: str = None):
        """Context manager for profiling code blocks."""
        pr = cProfile.Profile()
        pr.enable()
        try:
            yield
        finally:
            pr.disable()
            s = io.StringIO()
            ps = pstats.Stats(pr, stream=s).sort_stats('cumtime')
            ps.print_stats()
            
            if output_file:
                with open(output_file, 'w') as f:
                    ps.stream = f
                    ps.print_stats()
            else:
                print(s.getvalue())
    
    @staticmethod
    def profile_function(func: Callable) -> Callable:
        """Decorator to profile individual functions."""
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            pr = cProfile.Profile()
            pr.enable()
            try:
                result = func(*args, **kwargs)
            finally:
                pr.disable()
                s = io.StringIO()
                ps = pstats.Stats(pr, stream=s).sort_stats('cumtime')
                ps.print_stats()
                print(f"\nProfile for {func.__name__}:")
                print(s.getvalue())
            return result
        return wrapper
    
    @staticmethod
    @contextmanager
    def measure_time(name: str = None):
        """Context manager to measure execution time."""
        start = time.perf_counter()
        try:
            yield
        finally:
            end = time.perf_counter()
            duration = end - start
            label = name or "Operation"
            print(f"{label} took {duration:.4f} seconds")
    
    @staticmethod
    def timed(func: Callable) -> Callable:
        """Decorator to measure function execution time."""
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            start = time.perf_counter()
            result = func(*args, **kwargs)
            end = time.perf_counter()
            print(f"{func.__name__} took {end - start:.4f}s")
            return result
        return wrapper

# Usage examples
@Profiler.profile_function
def process_orders():
    """Process orders with profiling."""
    time.sleep(0.5)
    return "Done"

def main():
    # Profile a code block
    with Profiler.profile():
        for i in range(100):
            pass
    
    # Measure time of a block
    with Profiler.measure_time("Database query"):
        time.sleep(0.2)
    
    # Timed function
    @Profiler.timed
    def expensive_function():
        time.sleep(0.3)
    expensive_function()
```

---

## F.8 Optimization Checklist

### F.8.1 Pre-Deployment Checklist

```markdown
# Performance Optimization Pre-Deployment Checklist

## Database
- [ ] PostgreSQL configuration optimized (shared_buffers, work_mem, etc.)
- [ ] All foreign key columns have indexes
- [ ] Composite indexes created for common query patterns
- [ ] Partial indexes used for filtered queries
- [ ] GIN/GiST indexes used for full-text and JSONB queries
- [ ] Statistics updated with ANALYZE
- [ ] Connection pool configured (PgBouncer)
- [ ] Read replicas configured for analytics

## Application
- [ ] Connection pooling implemented for all databases
- [ ] Caching strategy defined (Redis for sessions, MongoDB for products)
- [ ] Database queries optimized (N+1 query patterns eliminated)
- [ ] Pagination implemented for all list endpoints
- [ ] Asynchronous processing for non-critical tasks
- [ ] Graceful degradation implemented

## Infrastructure
- [ ] Load balancer configured with health checks
- [ ] Auto-scaling rules defined
- [ ] Monitoring and alerting configured
- [ ] CDN configured for static assets
- [ ] Compression enabled (gzip/brotli)
- [ ] SSL/TLS configured with modern protocols

## Testing
- [ ] Load tests performed with expected traffic (1000 concurrent users)
- [ ] Stress tests performed (200% of expected traffic)
- [ ] Database query performance validated with EXPLAIN ANALYZE
- [ ] Cache hit ratio > 80%
- [ ] Response time < 100ms (p95)

## Monitoring
- [ ] Prometheus metrics exposed
- [ ] Grafana dashboards created
- [ ] Alert rules defined for critical metrics
- [ ] Slow query logging enabled
- [ ] Error tracking configured (Sentry)
- [ ] APM tool configured (New Relic, DataDog)
```

### F.8.2 Common Performance Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Full table scans** | High seq_scan in pg_stat_user_tables | Add appropriate indexes |
| **Missing foreign key indexes** | Slow joins | Create indexes on FK columns |
| **High dead tuple count** | Poor VACUUM performance | Tune autovacuum settings |
| **Connection pool exhaustion** | "too many clients" errors | Increase max_connections, use PgBouncer |
| **Cache misses** | Slow response times | Increase cache TTL, warm cache |
| **Slow queries** | High query duration | Use EXPLAIN ANALYZE, optimize |
| **I/O bottlenecks** | High disk wait time | Use SSDs, tune I/O scheduler |
| **CPU saturation** | High CPU usage | Scale horizontally, optimize code |
| **Memory pressure** | OOM errors | Increase memory, tune cache settings |
| **Network latency** | High response times | Use local networks, CDN |

---

**[END OF APPENDIX F]**

*This comprehensive performance tuning reference provides everything needed to optimize the ScaleCart platform for production workloads. Use it as a continuous reference for maintaining peak performance.*
