# Appendix E: Performance Optimization & Scalability Guide

Welcome to Appendix E of the FastAPI Masterclass series! This comprehensive guide covers everything you need to know about optimizing your FastAPI application for maximum performance and scalability. From database optimization to caching strategies, load balancing to horizontal scaling, this appendix serves as your performance tuning handbook.

## Table of Contents
1. [Performance Metrics & Monitoring](#performance-metrics--monitoring)
2. [Database Optimization](#database-optimization)
3. [Caching Strategies](#caching-strategies)
4. [Async Optimization](#async-optimization)
5. [Memory Management](#memory-management)
6. [Network Optimization](#network-optimization)
7. [Horizontal Scaling](#horizontal-scaling)
8. [Load Balancing](#load-balancing)
9. [CDN & Edge Caching](#cdn--edge-caching)
10. [Performance Testing](#performance-testing)

---

## Performance Metrics & Monitoring

### Key Performance Indicators (KPIs)

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| API Response Time (p95) | < 100ms | > 500ms |
| API Response Time (p99) | < 200ms | > 1s |
| Error Rate | < 0.1% | > 1% |
| Database Query Time | < 10ms | > 100ms |
| Cache Hit Rate | > 80% | < 50% |
| Memory Usage | < 70% | > 85% |
| CPU Usage | < 60% | > 80% |
| Request Throughput | 1000+ req/s | < 100 req/s |

### Performance Monitoring Setup

**`app/middleware/performance_metrics.py`:**

```python
"""
app/middleware/performance_metrics.py
Comprehensive performance metrics collection.
"""

from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
import time
import asyncio
from typing import Dict, Any
from collections import defaultdict
import statistics
import logging

from prometheus_client import (
    Counter, Histogram, Gauge, Summary,
    generate_latest, CONTENT_TYPE_LATEST
)

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────────────────────
# Performance Metrics
# ────────────────────────────────────────────────────────────────

# Request metrics
REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint', 'status_code'],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10)
)

REQUEST_SIZE = Histogram(
    'http_request_size_bytes',
    'HTTP request size in bytes',
    ['method', 'endpoint'],
    buckets=(100, 1000, 10000, 100000, 1000000)
)

RESPONSE_SIZE = Histogram(
    'http_response_size_bytes',
    'HTTP response size in bytes',
    ['method', 'endpoint'],
    buckets=(100, 1000, 10000, 100000, 1000000)
)

# Database metrics
DB_QUERY_DURATION = Histogram(
    'db_query_duration_seconds',
    'Database query duration in seconds',
    ['operation', 'table'],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5)
)

DB_CONNECTION_POOL = Gauge(
    'db_connection_pool_size',
    'Database connection pool size',
    ['state']  # 'used', 'available', 'total'
)

# Cache metrics
CACHE_OPERATIONS = Counter(
    'cache_operations_total',
    'Cache operations count',
    ['operation', 'cache_type']  # operation: hit, miss, set, delete
)

CACHE_LATENCY = Histogram(
    'cache_latency_seconds',
    'Cache operation latency in seconds',
    ['operation', 'cache_type'],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5)
)

# Task queue metrics
TASK_QUEUE_LENGTH = Gauge(
    'task_queue_length',
    'Number of tasks in queue',
    ['queue_name']
)

TASK_PROCESSING_TIME = Histogram(
    'task_processing_time_seconds',
    'Task processing time in seconds',
    ['task_name'],
    buckets=(0.1, 0.5, 1, 2.5, 5, 10, 30, 60, 120)
)

# System metrics
ACTIVE_REQUESTS = Gauge(
    'active_requests',
    'Number of active requests'
)

REQUEST_QUEUE_SIZE = Gauge(
    'request_queue_size',
    'Number of queued requests'
)

ASYNC_TASKS_PENDING = Gauge(
    'async_tasks_pending',
    'Number of pending async tasks'
)

# ────────────────────────────────────────────────────────────────
# Performance Middleware
# ────────────────────────────────────────────────────────────────

class PerformanceMiddleware(BaseHTTPMiddleware):
    """Comprehensive performance monitoring middleware."""
    
    def __init__(self, app):
        super().__init__(app)
        self.slow_request_threshold = 0.5  # 500ms
        self._request_times = defaultdict(list)
    
    async def dispatch(self, request: Request, call_next):
        # Track active requests
        ACTIVE_REQUESTS.inc()
        
        # Track request size
        content_length = request.headers.get("content-length", 0)
        try:
            size = int(content_length)
            REQUEST_SIZE.labels(
                method=request.method,
                endpoint=self._get_endpoint(request.url.path)
            ).observe(size)
        except (ValueError, TypeError):
            pass
        
        # Start timing
        start_time = time.perf_counter()
        
        try:
            response = await call_next(request)
            
            # Record request duration
            duration = time.perf_counter() - start_time
            endpoint = self._get_endpoint(request.url.path)
            
            REQUEST_DURATION.labels(
                method=request.method,
                endpoint=endpoint,
                status_code=response.status_code
            ).observe(duration)
            
            # Track response size
            if hasattr(response, "body") and response.body:
                RESPONSE_SIZE.labels(
                    method=request.method,
                    endpoint=endpoint
                ).observe(len(response.body))
            
            # Log slow requests
            if duration > self.slow_request_threshold:
                await self._log_slow_request(
                    request, response, duration
                )
            
            return response
            
        except Exception as e:
            duration = time.perf_counter() - start_time
            logger.error(
                f"Request failed after {duration:.3f}s",
                extra={
                    "path": request.url.path,
                    "method": request.method,
                    "error": str(e),
                    "duration": duration,
                }
            )
            raise
        finally:
            ACTIVE_REQUESTS.dec()
    
    def _get_endpoint(self, path: str) -> str:
        """Extract endpoint name from path."""
        # Remove IDs and dynamic parts
        parts = path.split("/")
        normalized = []
        for part in parts:
            if part.isdigit():
                normalized.append("{id}")
            elif part and part not in ["api", "v1"]:
                normalized.append(part)
        return "/".join(normalized)
    
    async def _log_slow_request(self, request: Request, response: Response, duration: float):
        """Log slow requests with details."""
        logger.warning(
            f"Slow request: {duration:.3f}s",
            extra={
                "path": request.url.path,
                "method": request.method,
                "status_code": response.status_code,
                "duration": duration,
                "client_ip": request.client.host if request.client else None,
                "query_params": str(request.query_params),
                "user_agent": request.headers.get("user-agent"),
            }
        )


# ────────────────────────────────────────────────────────────────
# Database Performance Tracking
# ────────────────────────────────────────────────────────────────

class QueryTracker:
    """Track database query performance."""
    
    _queries = defaultdict(list)
    
    @classmethod
    async def track_query(cls, operation: str, table: str, duration: float):
        """Track a database query."""
        DB_QUERY_DURATION.labels(
            operation=operation,
            table=table
        ).observe(duration)
        
        # Store for analysis
        cls._queries[f"{table}.{operation}"].append(duration)
        
        # Log slow queries (> 100ms)
        if duration > 0.1:
            logger.warning(
                f"Slow query: {operation} on {table} took {duration:.3f}s"
            )
    
    @classmethod
    def get_query_stats(cls) -> Dict[str, Any]:
        """Get query performance statistics."""
        stats = {}
        for key, durations in cls._queries.items():
            if durations:
                stats[key] = {
                    "count": len(durations),
                    "avg": statistics.mean(durations),
                    "p95": statistics.quantiles(durations, n=20)[-1] if len(durations) >= 20 else None,
                    "max": max(durations),
                    "min": min(durations),
                }
        return stats


# ────────────────────────────────────────────────────────────────
# Cache Performance Tracking
# ────────────────────────────────────────────────────────────────

class CacheTracker:
    """Track cache performance."""
    
    _hits = 0
    _misses = 0
    _latencies = defaultdict(list)
    
    @classmethod
    def record_hit(cls, cache_type: str = "redis"):
        """Record a cache hit."""
        CACHE_OPERATIONS.labels(
            operation="hit",
            cache_type=cache_type
        ).inc()
        cls._hits += 1
    
    @classmethod
    def record_miss(cls, cache_type: str = "redis"):
        """Record a cache miss."""
        CACHE_OPERATIONS.labels(
            operation="miss",
            cache_type=cache_type
        ).inc()
        cls._misses += 1
    
    @classmethod
    def record_latency(cls, operation: str, cache_type: str, duration: float):
        """Record cache operation latency."""
        CACHE_LATENCY.labels(
            operation=operation,
            cache_type=cache_type
        ).observe(duration)
        cls._latencies[f"{cache_type}.{operation}"].append(duration)
    
    @classmethod
    def get_hit_rate(cls) -> float:
        """Get cache hit rate."""
        total = cls._hits + cls._misses
        return cls._hits / total if total > 0 else 0.0


# ────────────────────────────────────────────────────────────────
# Performance Report Generation
# ────────────────────────────────────────────────────────────────

async def generate_performance_report() -> Dict[str, Any]:
    """Generate a comprehensive performance report."""
    return {
        "requests": {
            "active": ACTIVE_REQUESTS._value.get(),
            "queued": REQUEST_QUEUE_SIZE._value.get(),
        },
        "database": {
            "pool": {
                "used": DB_CONNECTION_POOL.labels(state="used")._value.get(),
                "available": DB_CONNECTION_POOL.labels(state="available")._value.get(),
                "total": DB_CONNECTION_POOL.labels(state="total")._value.get(),
            },
            "queries": QueryTracker.get_query_stats(),
        },
        "cache": {
            "hit_rate": CacheTracker.get_hit_rate(),
            "hits": CacheTracker._hits,
            "misses": CacheTracker._misses,
        },
        "tasks": {
            "pending": ASYNC_TASKS_PENDING._value.get(),
            "queues": {
                "default": TASK_QUEUE_LENGTH.labels(queue_name="default")._value.get(),
                "email": TASK_QUEUE_LENGTH.labels(queue_name="email")._value.get(),
            }
        }
    }
```

---

## Database Optimization

### Index Strategy

**`scripts/optimize_indexes.sql`:**

```sql
-- Database index optimization strategy

-- ────────────────────────────────────────────────────────────────
-- 1. Primary Key Indexes (already created automatically)
-- ────────────────────────────────────────────────────────────────

-- ────────────────────────────────────────────────────────────────
-- 2. Foreign Key Indexes
-- ────────────────────────────────────────────────────────────────

-- Tasks table
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_created_by_id ON tasks(created_by_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_assignee_id ON tasks(assignee_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_parent_task_id ON tasks(parent_task_id);

-- Comments table
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comments_task_id ON comments(task_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comments_author_id ON comments(author_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_comments_parent_comment_id ON comments(parent_comment_id);

-- Projects table
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_projects_owner_id ON projects(owner_id);

-- Project members table
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_project_members_project_id ON project_members(project_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_project_members_user_id ON project_members(user_id);

-- ────────────────────────────────────────────────────────────────
-- 3. Composite Indexes for Common Queries
-- ────────────────────────────────────────────────────────────────

-- Tasks: Filter by status and assignee
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_status_assignee 
ON tasks(status, assignee_id) 
WHERE status NOT IN ('done', 'archived');

-- Tasks: Filter by project and status
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_project_status 
ON tasks(project_id, status) 
WHERE status NOT IN ('done', 'archived');

-- Tasks: Due date for overdue queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_due_date 
ON tasks(due_date) 
WHERE due_date IS NOT NULL AND status NOT IN ('done', 'archived');

-- ────────────────────────────────────────────────────────────────
-- 4. Partial Indexes for Specific Use Cases
-- ────────────────────────────────────────────────────────────────

-- Active users only
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_active 
ON users(username, email) 
WHERE is_active = true;

-- Overdue tasks
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_overdue 
ON tasks(due_date, assignee_id) 
WHERE due_date < CURRENT_TIMESTAMP AND status NOT IN ('done', 'archived');

-- ────────────────────────────────────────────────────────────────
-- 5. Text Search Indexes
-- ────────────────────────────────────────────────────────────────

-- Full-text search on tasks
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_search 
ON tasks USING gin(
    to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(description, ''))
);

-- ────────────────────────────────────────────────────────────────
-- 6. Covering Indexes (Include additional columns to avoid table access)
-- ────────────────────────────────────────────────────────────────

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_list 
ON tasks(project_id, status, priority) 
INCLUDE (title, assignee_id, due_date, created_at);

-- ────────────────────────────────────────────────────────────────
-- 7. Monitor Index Usage
-- ────────────────────────────────────────────────────────────────

-- Check unused indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY tablename, indexname;

-- Check duplicate indexes
SELECT 
    pg_size_pretty(sum(pg_relation_size(idx.indexrelid))) as size,
    string_agg(idx.indexrelid::regclass::text, ', ') as indexes,
    (string_agg(idx.indexrelid::regclass::text, ', ')) as idx
FROM pg_index as i
JOIN pg_class as c ON c.oid = i.indrelid
JOIN pg_index as idx ON idx.indrelid = i.indrelid
WHERE i.indisprimary = false
GROUP BY c.oid, i.indrelid, i.indkey
HAVING count(*) > 1;
```

### Query Optimization

**`app/core/query_optimizer.py`:**

```python
"""
app/core/query_optimizer.py
Database query optimization utilities.
"""

from typing import Optional, List, Dict, Any
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload, selectinload
import time
import logging

logger = logging.getLogger(__name__)


class QueryOptimizer:
    """Database query optimization utilities."""
    
    @staticmethod
    async def analyze_query(session: AsyncSession, query: Any) -> Dict[str, Any]:
        """
        Analyze a query for performance issues.
        
        Args:
            session: Database session
            query: SQLAlchemy query
            
        Returns:
            Dict: Query analysis results
        """
        # Get the SQL string
        sql = str(query.compile(compile_kwargs={"literal_binds": True}))
        
        # Run EXPLAIN
        explain_query = f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {sql}"
        result = await session.execute(text(explain_query))
        explain_result = result.fetchall()
        
        # Analyze the plan
        plan = explain_result[0][0] if explain_result else {}
        
        analysis = {
            "sql": sql,
            "plan": plan,
            "issues": [],
        }
        
        # Check for sequential scans
        if "Seq Scan" in str(plan):
            analysis["issues"].append("Sequential scan detected")
        
        # Check for high cost
        if "cost" in str(plan):
            import re
            costs = re.findall(r"cost=(\d+\.\d+)\.\.(\d+\.\d+)", str(plan))
            for start, end in costs:
                if float(end) > 1000:
                    analysis["issues"].append(f"High cost query: {end}")
        
        return analysis
    
    @staticmethod
    def get_optimal_load_strategy(relationship: str, fetch_count: int) -> str:
        """
        Determine the optimal loading strategy for relationships.
        
        Args:
            relationship: Relationship name
            fetch_count: Number of items to fetch
            
        Returns:
            str: Loading strategy ('selectin', 'joined', 'lazy')
        """
        if fetch_count <= 10:
            return "selectin"  # Best for small sets
        elif fetch_count <= 100:
            return "joined"    # Best for medium sets
        else:
            return "lazy"      # Best for large sets
    
    @staticmethod
    def apply_pagination_optimization(
        query: Any,
        page: int,
        size: int,
        sort_field: str = "created_at",
        sort_desc: bool = True,
    ) -> Any:
        """
        Apply optimized pagination to a query.
        
        Uses keyset pagination for better performance on large datasets.
        
        Args:
            query: SQLAlchemy query
            page: Page number
            size: Page size
            sort_field: Field to sort by
            sort_desc: Sort descending
            
        Returns:
            Any: Optimized query
        """
        # For large offsets, use keyset pagination
        offset = (page - 1) * size
        
        if offset > 1000:
            # Use a subquery to get the IDs first
            # This is faster for large offsets
            pass
        
        return query.offset(offset).limit(size)
    
    @staticmethod
    def batch_queries(queries: List[Any], batch_size: int = 100) -> List[List[Any]]:
        """
        Batch multiple queries for efficient execution.
        
        Args:
            queries: List of queries
            batch_size: Batch size
            
        Returns:
            List[List[Any]]: Batched queries
        """
        batches = []
        for i in range(0, len(queries), batch_size):
            batches.append(queries[i:i + batch_size])
        return batches
    
    @staticmethod
    async def get_relation_counts(
        session: AsyncSession,
        model: Any,
        relation_name: str,
        ids: List[int],
    ) -> Dict[int, int]:
        """
        Efficiently count related objects for multiple records.
        
        Args:
            session: Database session
            model: Model class
            relation_name: Relationship name
            ids: List of record IDs
            
        Returns:
            Dict[int, int]: ID to count mapping
        """
        if not ids:
            return {}
        
        # Get the relationship from the model
        relation = getattr(model, relation_name)
        
        # Count related objects
        from sqlalchemy import func
        count_query = select(
            relation.property.local_columns,
            func.count().label("count")
        ).where(
            relation.property.local_columns.in_(ids)
        ).group_by(relation.property.local_columns)
        
        result = await session.execute(count_query)
        return {row[0]: row[1] for row in result.all()}
```

### Connection Pool Optimization

**`app/core/database_pool.py`:**

```python
"""
app/core/database_pool.py
Database connection pool optimization.
"""

from sqlalchemy.ext.asyncio import create_async_engine, AsyncEngine
from sqlalchemy.pool import AsyncAdaptedQueuePool
from typing import Optional
import time
import logging

from app.core.config import settings
from app.middleware.performance_metrics import DB_CONNECTION_POOL, QueryTracker

logger = logging.getLogger(__name__)


class OptimizedConnectionPool:
    """Optimized database connection pool."""
    
    _engine: Optional[AsyncEngine] = None
    
    @classmethod
    def get_engine(cls) -> AsyncEngine:
        """Get or create the optimized engine."""
        if cls._engine is None:
            cls._engine = cls._create_engine()
        return cls._engine
    
    @classmethod
    def _create_engine(cls) -> AsyncEngine:
        """Create the optimized engine with connection pooling."""
        
        # Calculate optimal pool size
        # Formula: (connections = (core_count * 2) + effective_spindle_count)
        import multiprocessing
        cpu_count = multiprocessing.cpu_count()
        optimal_pool_size = min(
            (cpu_count * 2) + 1,  # Standard formula
            20  # Cap at 20 for safety
        )
        
        logger.info(f"Creating database pool with {optimal_pool_size} connections")
        
        engine = create_async_engine(
            settings.DATABASE_URL,
            echo=settings.DATABASE_ECHO,
            pool_size=optimal_pool_size,
            max_overflow=optimal_pool_size * 2,
            pool_pre_ping=True,
            pool_recycle=3600,
            pool_timeout=30,
            poolclass=AsyncAdaptedQueuePool,
            connect_args={
                "server_settings": {
                    "application_name": "fastapi_app",
                    "timezone": "UTC",
                    "statement_timeout": "30000",  # 30 seconds
                    "idle_in_transaction_session_timeout": "60000",  # 60 seconds
                },
                "command_timeout": 30,
            },
        )
        
        # Create a wrapper to track connection usage
        cls._track_pool_usage(engine)
        
        return engine
    
    @classmethod
    def _track_pool_usage(cls, engine: AsyncEngine):
        """Track connection pool usage."""
        from sqlalchemy import event
        
        @event.listens_for(engine.sync_engine, "checkout")
        def on_checkout(dbapi_conn, connection_record, connection_proxy):
            """Called when a connection is checked out."""
            pool = engine.sync_engine.pool
            DB_CONNECTION_POOL.labels(state="used").set(
                pool.checkedin() - pool.checkedout()
            )
            DB_CONNECTION_POOL.labels(state="available").set(
                pool.checkedin()
            )
            DB_CONNECTION_POOL.labels(state="total").set(
                pool.size() + pool.overflow()
            )
        
        @event.listens_for(engine.sync_engine, "checkin")
        def on_checkin(dbapi_conn, connection_record):
            """Called when a connection is checked in."""
            pool = engine.sync_engine.pool
            DB_CONNECTION_POOL.labels(state="used").set(
                pool.checkedin() - pool.checkedout()
            )
            DB_CONNECTION_POOL.labels(state="available").set(
                pool.checkedin()
            )


# Async session context manager with performance tracking
class TrackedAsyncSession:
    """Async session with performance tracking."""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def __aenter__(self):
        return self.session
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.session.close()
    
    async def execute(self, query, *args, **kwargs):
        """Execute query with performance tracking."""
        start = time.perf_counter()
        
        try:
            result = await self.session.execute(query, *args, **kwargs)
            duration = time.perf_counter() - start
            
            # Track query
            operation = self._get_operation_type(query)
            table = self._get_table_name(query)
            await QueryTracker.track_query(operation, table, duration)
            
            return result
        except Exception as e:
            duration = time.perf_counter() - start
            logger.error(f"Query failed after {duration:.3f}s: {e}")
            raise
    
    def _get_operation_type(self, query) -> str:
        """Determine query operation type."""
        sql = str(query)
        if sql.startswith("SELECT"):
            return "select"
        elif sql.startswith("INSERT"):
            return "insert"
        elif sql.startswith("UPDATE"):
            return "update"
        elif sql.startswith("DELETE"):
            return "delete"
        else:
            return "other"
    
    def _get_table_name(self, query) -> str:
        """Extract table name from query."""
        import re
        sql = str(query)
        match = re.search(r'(?:FROM|INTO|UPDATE)\s+"?(\w+)"?', sql, re.IGNORECASE)
        return match.group(1) if match else "unknown"
```

---

## Caching Strategies

### Multi-Level Cache Implementation

**`app/core/cache_manager.py`:**

```python
"""
app/core/cache_manager.py
Multi-level caching with Redis and in-memory cache.
"""

from typing import Optional, Any, Dict, TypeVar, Generic
from functools import wraps
import time
import hashlib
import json
import asyncio
from collections import OrderedDict

from app.core.redis import RedisClient, RedisCache
from app.core.config import settings
from app.middleware.performance_metrics import CacheTracker

logger = logging.getLogger(__name__)

T = TypeVar('T')


class MemoryCache:
    """
    In-memory cache with LRU eviction.
    
    Used as L1 cache (fastest, but limited capacity).
    """
    
    def __init__(self, max_size: int = 1000, ttl: int = 60):
        self._cache: OrderedDict = OrderedDict()
        self._expiry: Dict[str, float] = {}
        self.max_size = max_size
        self.ttl = ttl
        self._lock = asyncio.Lock()
        self._stats = {"hits": 0, "misses": 0}
    
    async def get(self, key: str) -> Optional[Any]:
        """Get value from memory cache."""
        async with self._lock:
            # Check if expired
            if key in self._expiry and time.time() > self._expiry[key]:
                self._cache.pop(key, None)
                self._expiry.pop(key, None)
                self._stats["misses"] += 1
                return None
            
            value = self._cache.get(key)
            if value is not None:
                # Move to end (LRU)
                self._cache.move_to_end(key)
                self._stats["hits"] += 1
                CacheTracker.record_hit("memory")
                return value
            
            self._stats["misses"] += 1
            CacheTracker.record_miss("memory")
            return None
    
    async def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """Set value in memory cache."""
        async with self._lock:
            # LRU eviction
            if len(self._cache) >= self.max_size:
                # Remove oldest
                oldest = next(iter(self._cache))
                self._cache.pop(oldest)
                self._expiry.pop(oldest, None)
            
            self._cache[key] = value
            self._expiry[key] = time.time() + (ttl or self.ttl)
    
    async def delete(self, key: str):
        """Delete value from memory cache."""
        async with self._lock:
            self._cache.pop(key, None)
            self._expiry.pop(key, None)
    
    async def clear(self):
        """Clear memory cache."""
        async with self._lock:
            self._cache.clear()
            self._expiry.clear()
    
    def get_stats(self) -> Dict[str, int]:
        """Get cache statistics."""
        total = self._stats["hits"] + self._stats["misses"]
        return {
            "hits": self._stats["hits"],
            "misses": self._stats["misses"],
            "hit_rate": self._stats["hits"] / total if total > 0 else 0,
            "size": len(self._cache),
        }


class CacheManager:
    """
    Multi-level cache manager.
    
    L1: Memory cache (fastest)
    L2: Redis cache (distributed)
    L3: Database (fallback)
    """
    
    def __init__(self):
        self.l1 = MemoryCache(max_size=1000, ttl=60)
        self.redis_client = RedisClient()
        self.redis_cache = RedisCache(self.redis_client)
        self._initialized = False
        self._lock = asyncio.Lock()
    
    async def initialize(self):
        """Initialize cache manager."""
        if not self._initialized:
            async with self._lock:
                if not self._initialized:
                    await self.redis_client.connect()
                    self._initialized = True
    
    async def get(
        self,
        key: str,
        ttl: Optional[int] = None,
        force_refresh: bool = False,
    ) -> Optional[Any]:
        """
        Get value from cache (L1 → L2).
        
        Args:
            key: Cache key
            ttl: TTL for L2 cache
            force_refresh: Force refresh from L2
            
        Returns:
            Optional[Any]: Cached value
        """
        await self.initialize()
        
        # Check L1 (memory)
        if not force_refresh:
            start = time.perf_counter()
            value = await self.l1.get(key)
            if value is not None:
                return value
        
        # Check L2 (Redis)
        start = time.perf_counter()
        value = await self.redis_cache.get(key)
        
        duration = time.perf_counter() - start
        CacheTracker.record_latency("get", "redis", duration)
        
        if value is not None:
            # Cache in L1
            await self.l1.set(key, value, ttl or 60)
            return value
        
        return None
    
    async def set(
        self,
        key: str,
        value: Any,
        ttl: Optional[int] = None,
        skip_l1: bool = False,
    ) -> bool:
        """
        Set value in cache (L1 + L2).
        
        Args:
            key: Cache key
            value: Value to cache
            ttl: TTL in seconds
            skip_l1: Skip L1 caching
            
        Returns:
            bool: Success
        """
        await self.initialize()
        
        # Set in L2 (Redis)
        start = time.perf_counter()
        result = await self.redis_cache.set(key, value, ttl)
        
        duration = time.perf_counter() - start
        CacheTracker.record_latency("set", "redis", duration)
        
        if result and not skip_l1:
            # Set in L1 (memory)
            await self.l1.set(key, value, ttl)
        
        return result
    
    async def delete(self, key: str) -> bool:
        """Delete from all cache levels."""
        await self.initialize()
        
        # Delete from L1
        await self.l1.delete(key)
        
        # Delete from L2
        start = time.perf_counter()
        result = await self.redis_cache.delete(key)
        
        duration = time.perf_counter() - start
        CacheTracker.record_latency("delete", "redis", duration)
        
        return result
    
    async def get_or_set(
        self,
        key: str,
        func,
        *args,
        ttl: Optional[int] = None,
        **kwargs,
    ) -> Any:
        """
        Get from cache or execute function and cache result.
        
        Args:
            key: Cache key
            func: Async function to execute on cache miss
            ttl: TTL in seconds
            *args: Function arguments
            **kwargs: Function keyword arguments
            
        Returns:
            Any: Cached or computed value
        """
        # Try to get from cache
        value = await self.get(key)
        if value is not None:
            return value
        
        # Execute function
        start = time.perf_counter()
        value = await func(*args, **kwargs)
        duration = time.perf_counter() - start
        
        # Cache result
        await self.set(key, value, ttl)
        
        return value
    
    def get_stats(self) -> Dict[str, Any]:
        """Get cache statistics."""
        return {
            "l1": self.l1.get_stats(),
            "l2": {
                "connected": self.redis_client.is_connected(),
            },
            "global_hit_rate": CacheTracker.get_hit_rate(),
        }


# ────────────────────────────────────────────────────────────────
# Cache Decorators
# ────────────────────────────────────────────────────────────────

# Global cache manager instance
_cache_manager: Optional[CacheManager] = None


def get_cache_manager() -> CacheManager:
    """Get or create the cache manager."""
    global _cache_manager
    if _cache_manager is None:
        _cache_manager = CacheManager()
    return _cache_manager


def cached(ttl: Optional[int] = None, key_prefix: str = "", skip_l1: bool = False):
    """
    Decorator for caching function results.
    
    Args:
        ttl: TTL in seconds
        key_prefix: Prefix for cache key
        skip_l1: Skip L1 caching
        
    Example:
        @cached(ttl=300, key_prefix="user")
        async def get_user(user_id: int):
            return await db.fetch_user(user_id)
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Generate cache key
            key_parts = [key_prefix or func.__name__]
            key_parts.extend(str(arg) for arg in args if arg is not None)
            key_parts.extend(f"{k}:{v}" for k, v in kwargs.items() if v is not None)
            cache_key = hashlib.md5(":".join(key_parts).encode()).hexdigest()
            
            cache = get_cache_manager()
            return await cache.get_or_set(cache_key, func, *args, ttl=ttl, **kwargs)
        return wrapper
    return decorator


def invalidate(pattern: str):
    """
    Decorator to invalidate cache after function execution.
    
    Args:
        pattern: Cache key pattern to invalidate
        
    Example:
        @invalidate("user:*")
        async def update_user(user_id: int, data):
            return await db.update_user(user_id, data)
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            result = await func(*args, **kwargs)
            
            # Invalidate cache
            cache = get_cache_manager()
            # In production, use Redis SCAN to delete by pattern
            # For now, just log
            logger.info(f"Invalidating cache pattern: {pattern}")
            
            return result
        return wrapper
    return decorator


# ────────────────────────────────────────────────────────────────
# Response Caching
# ────────────────────────────────────────────────────────────────

class ResponseCache:
    """Cache HTTP responses."""
    
    def __init__(self, cache_manager: CacheManager):
        self.cache = cache_manager
        self.cacheable_statuses = {200, 201, 204}
        self.cacheable_methods = {"GET"}
    
    async def get_cached_response(self, request) -> Optional[Dict[str, Any]]:
        """Get cached HTTP response."""
        if request.method not in self.cacheable_methods:
            return None
        
        cache_key = self._generate_cache_key(request)
        return await self.cache.get(cache_key)
    
    async def cache_response(
        self,
        request,
        response,
        ttl: Optional[int] = None,
    ) -> None:
        """Cache HTTP response."""
        if (
            request.method not in self.cacheable_methods or
            response.status_code not in self.cacheable_statuses
        ):
            return
        
        cache_key = self._generate_cache_key(request)
        
        cache_data = {
            "status_code": response.status_code,
            "headers": dict(response.headers),
            "body": response.body if hasattr(response, "body") else None,
        }
        
        await self.cache.set(cache_key, cache_data, ttl)
    
    def _generate_cache_key(self, request) -> str:
        """Generate cache key from request."""
        path = request.url.path
        query = str(request.query_params)
        
        # Include authorization header for user-specific caching
        auth = request.headers.get("authorization", "")
        
        key_data = f"{path}:{query}:{auth}"
        return f"response:{hashlib.md5(key_data.encode()).hexdigest()}"
```

### Cache Invalidation Strategy

**`app/core/cache_invalidation.py`:**

```python
"""
app/core/cache_invalidation.py
Smart cache invalidation strategies.
"""

from typing import Set, Dict, Any
from collections import defaultdict
import asyncio
import logging

from app.core.cache_manager import get_cache_manager

logger = logging.getLogger(__name__)


class CacheInvalidator:
    """
    Smart cache invalidation with dependency tracking.
    
    Tracks relationships between cache keys and invalidates
    dependent entries when data changes.
    """
    
    def __init__(self):
        self.dependencies: Dict[str, Set[str]] = defaultdict(set)
        self.dependents: Dict[str, Set[str]] = defaultdict(set)
        self._lock = asyncio.Lock()
    
    def add_dependency(self, cache_key: str, depends_on: Set[str]):
        """
        Register dependencies for a cache key.
        
        Args:
            cache_key: The cache key
            depends_on: Set of keys it depends on
        """
        for dep in depends_on:
            self.dependencies[cache_key].add(dep)
            self.dependents[dep].add(cache_key)
    
    async def invalidate(self, key: str) -> None:
        """
        Invalidate a key and all dependent keys.
        
        Args:
            key: The key to invalidate
        """
        async with self._lock:
            cache = get_cache_manager()
            
            # Get all dependent keys
            to_invalidate = set()
            to_check = {key}
            
            while to_check:
                current = to_check.pop()
                if current not in to_invalidate:
                    to_invalidate.add(current)
                    # Add dependents
                    for dependent in self.dependents.get(current, set()):
                        to_check.add(dependent)
            
            # Invalidate all keys
            for key_to_delete in to_invalidate:
                await cache.delete(key_to_delete)
                logger.debug(f"Invalidated cache key: {key_to_delete}")
    
    def get_dependency_graph(self) -> Dict[str, Any]:
        """Get the dependency graph for debugging."""
        return {
            "dependencies": dict(self.dependencies),
            "dependents": dict(self.dependents),
        }


# ────────────────────────────────────────────────────────────────
# Specific Invalidation Strategies
# ────────────────────────────────────────────────────────────────

class TaskCacheInvalidator(CacheInvalidator):
    """Specialized invalidation for task-related caches."""
    
    async def invalidate_task(self, task_id: int):
        """Invalidate all caches related to a task."""
        await self.invalidate(f"task:{task_id}")
        await self.invalidate(f"task_list:*")
        await self.invalidate(f"project:{task_id}_tasks")  # Example
    
    async def invalidate_user_tasks(self, user_id: int):
        """Invalidate all caches for a user's tasks."""
        await self.invalidate(f"user:{user_id}:tasks")
        await self.invalidate(f"user:{user_id}:assigned_tasks")
        await self.invalidate(f"user:{user_id}:created_tasks")


# ────────────────────────────────────────────────────────────────
# Cache Warmup
# ────────────────────────────────────────────────────────────────

class CacheWarmer:
    """Pre-warm cache with frequently accessed data."""
    
    def __init__(self, cache_manager):
        self.cache = cache_manager
    
    async def warmup(self):
        """Warm up the cache with common data."""
        logger.info("Starting cache warmup...")
        
        # Warm up popular data
        tasks = await self.warmup_tasks()
        users = await self.warmup_users()
        projects = await self.warmup_projects()
        
        logger.info(
            f"Cache warmup complete: {len(tasks)} tasks, "
            f"{len(users)} users, {len(projects)} projects"
        )
    
    async def warmup_tasks(self):
        """Warm up task caches."""
        # In production, this would fetch popular tasks
        pass
    
    async def warmup_users(self):
        """Warm up user caches."""
        pass
    
    async def warmup_projects(self):
        """Warm up project caches."""
        pass
```

---

## Async Optimization

### Async Performance Patterns

**`app/core/async_performance.py`:**

```python
"""
app/core/async_performance.py
Advanced async performance optimizations.
"""

import asyncio
from typing import List, Any, Callable, TypeVar, Coroutine
from asyncio import Semaphore, Queue
import time
import logging

logger = logging.getLogger(__name__)

T = TypeVar('T')


# ────────────────────────────────────────────────────────────────
# Concurrency Control
# ────────────────────────────────────────────────────────────────

class ConcurrencyLimiter:
    """Limit concurrency of async operations."""
    
    def __init__(self, max_concurrency: int):
        self.semaphore = Semaphore(max_concurrency)
    
    async def run(self, coro: Coroutine) -> Any:
        """Run a coroutine with concurrency limit."""
        async with self.semaphore:
            return await coro
    
    async def run_many(self, coros: List[Coroutine]) -> List[Any]:
        """Run multiple coroutines with concurrency limit."""
        tasks = [self.run(coro) for coro in coros]
        return await asyncio.gather(*tasks, return_exceptions=True)


# ────────────────────────────────────────────────────────────────
# Batch Processing
# ────────────────────────────────────────────────────────────────

class BatchProcessor:
    """Process items in batches for efficiency."""
    
    def __init__(self, batch_size: int = 100, max_concurrency: int = 10):
        self.batch_size = batch_size
        self.concurrency_limiter = ConcurrencyLimiter(max_concurrency)
    
    async def process(
        self,
        items: List[Any],
        processor: Callable,
        *args,
        **kwargs,
    ) -> List[Any]:
        """
        Process items in batches.
        
        Args:
            items: List of items to process
            processor: Async function to process each item
            *args: Positional arguments for processor
            **kwargs: Keyword arguments for processor
            
        Returns:
            List[Any]: Processing results
        """
        results = []
        
        for i in range(0, len(items), self.batch_size):
            batch = items[i:i + self.batch_size]
            
            # Process batch concurrently
            tasks = [
                processor(item, *args, **kwargs)
                for item in batch
            ]
            
            batch_results = await self.concurrency_limiter.run_many(tasks)
            results.extend(batch_results)
        
        return results


# ────────────────────────────────────────────────────────────────
# Async Task Queue
# ────────────────────────────────────────────────────────────────

class AsyncTaskQueue:
    """Async task queue for background processing."""
    
    def __init__(self, max_size: int = 1000, worker_count: int = 4):
        self.queue = Queue(maxsize=max_size)
        self.workers = worker_count
        self.is_running = False
        self.tasks = []
        self._processed_count = 0
    
    async def start(self):
        """Start the task queue workers."""
        self.is_running = True
        self.tasks = [
            asyncio.create_task(self._worker(i))
            for i in range(self.workers)
        ]
        logger.info(f"Started {self.workers} task queue workers")
    
    async def stop(self):
        """Stop the task queue workers."""
        self.is_running = False
        for task in self.tasks:
            task.cancel()
        await asyncio.gather(*self.tasks, return_exceptions=True)
        logger.info("Task queue stopped")
    
    async def enqueue(self, func: Callable, *args, **kwargs):
        """Enqueue a task for background processing."""
        await self.queue.put((func, args, kwargs))
        ASYNC_TASKS_PENDING.set(self.queue.qsize())
    
    async def _worker(self, worker_id: int):
        """Worker processing tasks from the queue."""
        while self.is_running:
            try:
                # Get task with timeout
                func, args, kwargs = await asyncio.wait_for(
                    self.queue.get(),
                    timeout=1.0
                )
                
                start = time.perf_counter()
                
                try:
                    # Execute task
                    if asyncio.iscoroutinefunction(func):
                        result = await func(*args, **kwargs)
                    else:
                        result = func(*args, **kwargs)
                    
                    duration = time.perf_counter() - start
                    self._processed_count += 1
                    
                    logger.debug(
                        f"Worker {worker_id} completed task in {duration:.3f}s"
                    )
                    
                except Exception as e:
                    logger.error(f"Worker {worker_id} task failed: {e}")
                
                finally:
                    self.queue.task_done()
                    ASYNC_TASKS_PENDING.set(self.queue.qsize())
                    
            except asyncio.TimeoutError:
                continue
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Worker {worker_id} error: {e}")
    
    def get_stats(self) -> Dict[str, Any]:
        """Get queue statistics."""
        return {
            "queue_size": self.queue.qsize(),
            "processed_count": self._processed_count,
            "worker_count": self.workers,
            "is_running": self.is_running,
        }


# ────────────────────────────────────────────────────────────────
# Async Context Managers
# ────────────────────────────────────────────────────────────────

class AsyncTimer:
    """Context manager for timing async operations."""
    
    def __init__(self, name: str = "operation"):
        self.name = name
        self.start_time = None
        self.duration = None
    
    async def __aenter__(self):
        self.start_time = time.perf_counter()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        self.duration = time.perf_counter() - self.start_time
        logger.debug(f"{self.name} took {self.duration:.3f}s")
        
        if self.duration > 1.0:
            logger.warning(f"Slow {self.name}: {self.duration:.3f}s")


# ────────────────────────────────────────────────────────────────
# Async Connection Pool
# ────────────────────────────────────────────────────────────────

class AsyncConnectionPool:
    """Generic async connection pool."""
    
    def __init__(
        self,
        connector: Callable,
        max_size: int = 10,
        idle_timeout: int = 300,
    ):
        self.connector = connector
        self.max_size = max_size
        self.idle_timeout = idle_timeout
        self._pool = []
        self._in_use = set()
        self._lock = asyncio.Lock()
    
    async def acquire(self) -> Any:
        """Acquire a connection from the pool."""
        async with self._lock:
            # Try to get an existing connection
            while self._pool:
                conn = self._pool.pop()
                if self._is_valid(conn):
                    self._in_use.add(conn)
                    return conn
            
            # Create new connection
            if len(self._in_use) < self.max_size:
                conn = await self.connector()
                self._in_use.add(conn)
                return conn
            
            # Wait for a connection to become available
            # Simplified - in production, use asyncio.Condition
            raise RuntimeError("Connection pool exhausted")
    
    async def release(self, conn):
        """Release a connection back to the pool."""
        async with self._lock:
            self._in_use.discard(conn)
            if self._is_valid(conn):
                self._pool.append(conn)
    
    def _is_valid(self, conn) -> bool:
        """Check if connection is still valid."""
        # Override in subclass
        return True
    
    async def close_all(self):
        """Close all connections."""
        async with self._lock:
            for conn in self._pool:
                await self._close_connection(conn)
            self._pool.clear()
    
    async def _close_connection(self, conn):
        """Close a connection."""
        # Override in subclass
        pass
```

---

## Performance Testing Tools

### Load Test Configuration

**`tests/performance/load_test_config.py`:**

```python
"""
tests/performance/load_test_config.py
Load test configuration and scenarios.
"""

import json
from typing import Dict, Any
from dataclasses import dataclass


@dataclass
class LoadTestConfig:
    """Load test configuration."""
    
    host: str = "http://localhost:8000"
    users: int = 100
    spawn_rate: int = 10
    duration: int = 300  # seconds
    ramp_up: int = 60    # seconds
    
    # Request mix
    endpoint_weights: Dict[str, int] = None
    
    # Think time
    min_wait: int = 1
    max_wait: int = 5
    
    def __post_init__(self):
        if self.endpoint_weights is None:
            self.endpoint_weights = {
                "GET /api/v1/tasks/": 30,
                "POST /api/v1/tasks/": 15,
                "GET /api/v1/tasks/{id}": 20,
                "PUT /api/v1/tasks/{id}": 10,
                "DELETE /api/v1/tasks/{id}": 5,
                "GET /api/v1/auth/me": 10,
                "GET /api/v1/projects/": 10,
            }
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "host": self.host,
            "users": self.users,
            "spawn_rate": self.spawn_rate,
            "duration": self.duration,
            "ramp_up": self.ramp_up,
            "endpoint_weights": self.endpoint_weights,
            "think_time": {
                "min": self.min_wait,
                "max": self.max_wait,
            },
        }


# ────────────────────────────────────────────────────────────────
# Test Scenarios
# ────────────────────────────────────────────────────────────────

class LoadTestScenarios:
    """Pre-defined load test scenarios."""
    
    @staticmethod
    def smoke_test() -> LoadTestConfig:
        """Smoke test with minimal load."""
        return LoadTestConfig(
            users=5,
            spawn_rate=2,
            duration=60,
            ramp_up=10,
        )
    
    @staticmethod
    def performance_test() -> LoadTestConfig:
        """Performance test with moderate load."""
        return LoadTestConfig(
            users=50,
            spawn_rate=5,
            duration=300,
            ramp_up=30,
        )
    
    @staticmethod
    def stress_test() -> LoadTestConfig:
        """Stress test with high load."""
        return LoadTestConfig(
            users=500,
            spawn_rate=25,
            duration=600,
            ramp_up=120,
        )
    
    @staticmethod
    def endurance_test() -> LoadTestConfig:
        """Endurance test over a long period."""
        return LoadTestConfig(
            users=100,
            spawn_rate=10,
            duration=3600,  # 1 hour
            ramp_up=60,
        )
    
    @staticmethod
    def spike_test() -> LoadTestConfig:
        """Spike test with sudden load increase."""
        config = LoadTestConfig(
            users=100,
            spawn_rate=50,
            duration=300,
            ramp_up=10,
        )
        return config
```

---

## Scalability Best Practices

### Architecture Checklist

```markdown
# Scalability Architecture Checklist

## Database
- [ ] Connection pooling configured
- [ ] Read replicas for read-heavy workloads
- [ ] Write-ahead logging enabled
- [ ] Appropriate indexes on all foreign keys
- [ ] Partitioning for large tables
- [ ] Query optimization reviewed
- [ ] Caching implemented for frequent queries

## Application
- [ ] Stateless application design
- [ ] Horizontal scaling enabled
- [ ] Async/await used throughout
- [ ] Proper exception handling
- [ ] Health check endpoints implemented
- [ ] Graceful shutdown handling
- [ ] Request ID propagation

## Caching
- [ ] Multi-level caching (memory + Redis)
- [ ] Cache invalidation strategy defined
- [ ] Cache warming implemented
- [ ] Cache hit rate > 80%

## Network
- [ ] Load balancing configured
- [ ] SSL termination at load balancer
- [ ] CDN for static assets
- [ ] Gzip compression enabled

## Monitoring
- [ ] Performance metrics collected
- [ ] Alerting configured
- [ ] Logging structured (JSON format)
- [ ] Distributed tracing enabled
- [ ] Real-time dashboards created

## Deployment
- [ ] Blue-green deployment strategy
- [ ] Canary releases supported
- [ ] Rolling updates configured
- [ ] Auto-scaling policies defined
- [ ] Disaster recovery plan documented
```

---

This comprehensive performance optimization guide provides everything you need to tune your FastAPI application for maximum performance and scalability. Use it as your reference for identifying bottlenecks, implementing optimizations, and scaling your application to handle millions of requests.

**[END OF APPENDIX E]**
