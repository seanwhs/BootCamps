# Appendix D: Production Performance Tuning & Scaling Guide

Welcome to Appendix D! This comprehensive reference provides expert-level guidance on optimizing Flask applications for production, scaling strategies, and performance tuning. While the main tutorial covered deployment, this appendix dives deep into making your application fast, scalable, and resilient under real-world traffic.

---

## Table of Contents

1. [Performance Measurement & Profiling](#1-performance-measurement--profiling)
2. [Application-Level Optimization](#2-application-level-optimization)
3. [Database Performance Tuning](#3-database-performance-tuning)
4. [Caching Strategies](#4-caching-strategies)
5. [API Performance Optimization](#5-api-performance-optimization)
6. [Scaling Strategies](#6-scaling-strategies)
7. [Load Testing & Capacity Planning](#7-load-testing--capacity-planning)
8. [Monitoring & Alerting](#8-monitoring--alerting)
9. [Disaster Recovery & High Availability](#9-disaster-recovery--high-availability)

---

## 1. Performance Measurement & Profiling

### Application Profiling

```python
import cProfile
import pstats
import io
import time
from functools import wraps
from flask import request, current_app

def profile_endpoint(f):
    """
    Decorator to profile individual endpoints.
    
    Usage:
        @app.route('/slow-endpoint')
        @profile_endpoint
        def slow_endpoint():
            return "Slow response"
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        if not current_app.config.get('DEBUG', False):
            return f(*args, **kwargs)
        
        profiler = cProfile.Profile()
        profiler.enable()
        
        start_time = time.time()
        result = f(*args, **kwargs)
        duration = time.time() - start_time
        
        profiler.disable()
        
        # Log if endpoint is slow
        if duration > 1.0:
            # Save profile data
            s = io.StringIO()
            ps = pstats.Stats(profiler, stream=s).sort_stats('cumtime')
            ps.print_stats(20)
            
            # Log the profile
            current_app.logger.warning(
                f"Slow endpoint: {request.path} took {duration:.2f}s\n{s.getvalue()}"
            )
        
        return result
    return decorated

# Request timing middleware
class RequestTimingMiddleware:
    """Middleware to time all requests."""
    
    def __init__(self, app):
        self.app = app
    
    def __call__(self, environ, start_response):
        start_time = time.time()
        
        def timing_start_response(status, headers, exc_info=None):
            # Calculate response time
            duration = time.time() - start_time
            
            # Add timing header
            headers.append(('X-Response-Time', f'{duration:.3f}s'))
            
            # Log slow requests
            if duration > 1.0:
                path = environ.get('PATH_INFO', 'unknown')
                method = environ.get('REQUEST_METHOD', 'GET')
                current_app.logger.warning(f"Slow request: {method} {path} took {duration:.2f}s")
            
            return start_response(status, headers, exc_info)
        
        return self.app(environ, timing_start_response)

# Apply middleware
app.wsgi_app = RequestTimingMiddleware(app.wsgi_app)
```

### Performance Metrics Collection

```python
import psutil
import os
import threading
import time
from collections import deque
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class PerformanceMetric:
    """Performance metric data point."""
    timestamp: float
    cpu_percent: float
    memory_mb: float
    request_count: int
    average_response_time: float
    error_count: int

class PerformanceCollector:
    """
    Collect and store performance metrics.
    """
    
    def __init__(self, app, max_history=1000):
        self.app = app
        self.metrics = deque(maxlen=max_history)
        self.request_counts = {}
        self.error_counts = {}
        self.response_times = {}
        self.collecting = False
        self._thread = None
    
    def start(self):
        """Start collecting metrics."""
        if self.collecting:
            return
        
        self.collecting = True
        self._thread = threading.Thread(target=self._collect_loop, daemon=True)
        self._thread.start()
        self.app.logger.info("Performance collection started")
    
    def stop(self):
        """Stop collecting metrics."""
        self.collecting = False
        if self._thread:
            self._thread.join(timeout=5)
        self.app.logger.info("Performance collection stopped")
    
    def _collect_loop(self):
        """Main collection loop."""
        while self.collecting:
            try:
                # Collect system metrics
                cpu = psutil.cpu_percent(interval=1)
                memory = psutil.Process(os.getpid()).memory_info().rss / (1024 * 1024)
                
                # Aggregate request metrics
                total_requests = sum(self.request_counts.values())
                total_errors = sum(self.error_counts.values())
                
                # Calculate average response time
                if self.response_times:
                    avg_response = sum(self.response_times.values()) / len(self.response_times)
                else:
                    avg_response = 0
                
                # Store metric
                metric = PerformanceMetric(
                    timestamp=time.time(),
                    cpu_percent=cpu,
                    memory_mb=memory,
                    request_count=total_requests,
                    average_response_time=avg_response,
                    error_count=total_errors
                )
                self.metrics.append(metric)
                
                # Reset counters
                self.request_counts = {}
                self.error_counts = {}
                self.response_times = {}
                
                # Sleep for 10 seconds
                time.sleep(10)
                
            except Exception as e:
                self.app.logger.error(f"Error collecting metrics: {e}")
    
    def record_request(self, endpoint, duration, error=False):
        """Record a request metric."""
        if endpoint not in self.request_counts:
            self.request_counts[endpoint] = 0
            self.response_times[endpoint] = 0
        
        self.request_counts[endpoint] += 1
        self.response_times[endpoint] += duration
        
        if error:
            if endpoint not in self.error_counts:
                self.error_counts[endpoint] = 0
            self.error_counts[endpoint] += 1
    
    def get_metrics(self):
        """Get collected metrics."""
        return list(self.metrics)

# Integrate with Flask
collector = PerformanceCollector(app)

@app.before_request
def before_request_metrics():
    """Start tracking request timing."""
    g.start_time = time.time()

@app.after_request
def after_request_metrics(response):
    """Record request metrics."""
    duration = time.time() - g.start_time
    endpoint = request.endpoint or 'unknown'
    error = response.status_code >= 400
    collector.record_request(endpoint, duration, error)
    return response

# Metrics endpoint
@app.route('/metrics/performance')
@admin_required
def performance_metrics():
    """Get performance metrics."""
    metrics = collector.get_metrics()
    return jsonify({
        'metrics': [m.__dict__ for m in metrics],
        'current': {
            'cpu': psutil.cpu_percent(),
            'memory': psutil.Process(os.getpid()).memory_info().rss / (1024 * 1024),
            'connections': len(psutil.net_connections()),
        }
    })
```

---

## 2. Application-Level Optimization

### Code Optimization Patterns

```python
# ❌ BAD: Inefficient database queries in loop
def bad_task_export(user_id):
    tasks = Task.query.filter_by(user_id=user_id).all()
    result = []
    for task in tasks:
        # N+1 query problem
        user = User.query.get(task.user_id)
        result.append({
            'task': task.title,
            'user': user.username
        })
    return result

# ✅ GOOD: Eager loading
def good_task_export(user_id):
    tasks = Task.query.options(
        joinedload(Task.user)
    ).filter_by(user_id=user_id).all()
    
    return [{
        'task': task.title,
        'user': task.user.username
    } for task in tasks]

# ❌ BAD: Doing work that could be cached
def expensive_computation(data):
    # Complex calculation
    result = []
    for item in data:
        processed = heavy_process(item)
        result.append(processed)
    return result

# ✅ GOOD: Caching results
from functools import lru_cache

@lru_cache(maxsize=1000)
def cached_computation(data_hash):
    # Hash input for cache key
    # Complex calculation
    return heavy_process(data_hash)

# ❌ BAD: Over-broad logging
@app.route('/api/users')
def get_users():
    app.logger.debug("Received request for users")  # Too verbose
    # ... process ...

# ✅ GOOD: Appropriate logging levels
@app.route('/api/users')
def get_users():
    # Only log at DEBUG level
    app.logger.debug("Fetching users list")
    # ...
    app.logger.info(f"Returned {len(users)} users")
```

### Connection Pool Optimization

```python
from sqlalchemy.pool import QueuePool
from sqlalchemy import create_engine

# Optimized engine configuration
engine = create_engine(
    'postgresql://user:pass@localhost/db',
    poolclass=QueuePool,
    pool_size=20,              # Number of connections to maintain
    max_overflow=40,           # Extra connections when pool is full
    pool_recycle=3600,         # Recycle after 1 hour
    pool_pre_ping=True,        # Check connection before using
    pool_timeout=30,           # Timeout waiting for connection
    
    # Query optimization
    echo=False,                # Don't log queries
    query_cache_size=500,      # Cache prepared statements
    isolation_level='READ COMMITTED',
    
    # Connection parameters
    connect_args={
        'keepalives': 1,
        'keepalives_idle': 60,
        'keepalives_interval': 10,
        'keepalives_count': 5,
        'connect_timeout': 10,
        'sslmode': 'require',
    }
)

# Monitor connection pool
@event.listens_for(engine, "checkout")
def on_checkout(dbapi_conn, connection_record, connection_proxy):
    current_app.logger.debug(
        f"Connection checkout: pool size={engine.pool.size()}, "
        f"checkedout={engine.pool.checkedout()}"
    )

@event.listens_for(engine, "checkin")
def on_checkin(dbapi_conn, connection_record):
    current_app.logger.debug(
        f"Connection checkin: pool size={engine.pool.size()}, "
        f"checkedout={engine.pool.checkedout()}"
    )
```

### Template Optimization

```python
# ❌ BAD: Complex logic in templates
def bad_template_example():
    return render_template('bad.html', items=items)

# bad.html:
# {% for item in items %}
#     {% set processed = process_item(item) %}
#     {% if processed.is_valid %}
#         <div class="{{ 'active' if processed.active else 'inactive' }}">
#             {{ processed.name | upper | truncate(20) }}
#         </div>
#     {% endif %}
# {% endfor %}

# ✅ GOOD: Pre-process in view
def good_template_example():
    processed_items = []
    for item in items:
        processed = process_item(item)
        if processed.is_valid:
            processed_items.append({
                'class': 'active' if processed.active else 'inactive',
                'name': processed.name.upper()[:20]
            })
    return render_template('good.html', items=processed_items)

# good.html:
# {% for item in items %}
#     <div class="{{ item.class }}">
#         {{ item.name }}
#     </div>
# {% endfor %}

# Template fragment caching
from flask_caching import Cache
cache = Cache(app, config={'CACHE_TYPE': 'filesystem'})

@app.route('/dashboard')
def dashboard():
    # Cache expensive template fragment
    return render_template('dashboard.html')

# In template:
# {% cache 300, 'user_widget', user.id %}
#     <div class="user-widget">
#         <!-- Expensive user data rendering -->
#     </div>
# {% endcache %}
```

---

## 3. Database Performance Tuning

### Query Optimization

```python
from sqlalchemy import text, func, Index
from sqlalchemy.dialects.postgresql import GIN

# 1. Index Strategy
class Task(Base):
    __tablename__ = 'tasks'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    status = Column(String(20))
    priority = Column(String(20))
    due_date = Column(DateTime)
    created_at = Column(DateTime)
    
    # Composite index for common queries
    __table_args__ = (
        Index('idx_tasks_user_status', 'user_id', 'status'),
        Index('idx_tasks_due_date', 'due_date'),
        Index('idx_tasks_created_at', 'created_at'),
        # GIN index for full-text search
        Index('idx_tasks_search', func.to_tsvector('english', title), postgresql_using='gin'),
    )

# 2. Query Optimization
def optimized_task_query(user_id, status=None, priority=None):
    query = Task.query.filter_by(user_id=user_id)
    
    # Use indexes
    if status:
        query = query.filter_by(status=status)  # Uses composite index
    
    if priority:
        query = query.filter_by(priority=priority)  # Uses composite index
    
    # Use LIMIT for pagination
    query = query.limit(20).offset(0)
    
    # Use column selection
    query = query.with_entities(
        Task.id,
        Task.title,
        Task.status,
        Task.due_date
    )
    
    return query.all()

# 3. Bulk Operations
def bulk_task_update(user_id, updates):
    # ❌ BAD: Individual updates
    for task_id, status in updates.items():
        task = Task.query.get(task_id)
        if task.user_id == user_id:
            task.status = status
    
    # ✅ GOOD: Bulk update
    from sqlalchemy import update
    stmt = update(Task).where(
        Task.id.in_(updates.keys()),
        Task.user_id == user_id
    ).values(status=updates.values())
    
    db.session.execute(stmt)
    db.session.commit()

# 4. Use EXPLAIN to analyze queries
def analyze_query(query):
    """Get query execution plan."""
    sql = str(query.compile(compile_kwargs={"literal_binds": True}))
    result = db.session.execute(
        f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {sql}"
    ).scalar()
    return result
```

### Connection Pool Tuning

```python
# Connection pool configuration based on traffic patterns

def get_pool_config(traffic_level):
    """Get optimal pool configuration based on traffic."""
    if traffic_level == 'high':
        return {
            'pool_size': 30,
            'max_overflow': 60,
            'pool_recycle': 600,  # 10 minutes
            'pool_timeout': 10,
        }
    elif traffic_level == 'medium':
        return {
            'pool_size': 15,
            'max_overflow': 30,
            'pool_recycle': 3600,  # 1 hour
            'pool_timeout': 20,
        }
    else:  # low
        return {
            'pool_size': 5,
            'max_overflow': 10,
            'pool_recycle': 7200,  # 2 hours
            'pool_timeout': 30,
        }

# Connection pool monitoring
def get_pool_stats():
    """Get connection pool statistics."""
    pool = db.engine.pool
    return {
        'size': pool.size(),
        'checkedout': pool.checkedout(),
        'overflow': pool.overflow(),
        'available': pool.size() - pool.checkedout(),
    }

# Health check with pool status
@app.route('/health/db')
def db_health():
    """Database health check with pool stats."""
    try:
        # Test connection
        db.session.execute(text("SELECT 1"))
        
        return jsonify({
            'status': 'healthy',
            'pool_stats': get_pool_stats()
        })
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e)
        }), 503
```

### Read Replicas

```python
# Configure read replicas
SQLALCHEMY_BINDS = {
    'master': 'postgresql://user:pass@master-db:5432/taskflow',
    'replica1': 'postgresql://user:pass@replica1:5432/taskflow',
    'replica2': 'postgresql://user:pass@replica2:5432/taskflow',
}

class RoutingSession:
    """Session that routes reads to replicas."""
    
    def __init__(self, master_session, replica_sessions):
        self.master = master_session
        self.replicas = replica_sessions
        self._current_replica_index = 0
    
    def get_read_session(self):
        """Get a session for read operations (round-robin)."""
        replica = self.replicas[self._current_replica_index]
        self._current_replica_index = (self._current_replica_index + 1) % len(self.replicas)
        return replica
    
    def get_write_session(self):
        """Get session for write operations (always master)."""
        return self.master

# Read/Write split in application
def get_tasks(user_id):
    """Read operation - uses replica."""
    session = routing.get_read_session()
    return session.query(Task).filter_by(user_id=user_id).all()

def create_task(data):
    """Write operation - uses master."""
    session = routing.get_write_session()
    task = Task(**data)
    session.add(task)
    session.commit()
    return task
```

---

## 4. Caching Strategies

### Multi-level Caching

```python
from flask_caching import Cache
import redis
from functools import wraps

# Configure cache
cache = Cache(app, config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://localhost:6379/2',
    'CACHE_DEFAULT_TIMEOUT': 300,
    'CACHE_KEY_PREFIX': 'taskflow:'
})

# 1. View Caching
@app.route('/api/expensive-data')
@cache.cached(timeout=300, query_string=True)
def expensive_data():
    # This endpoint is cached for 5 minutes
    # Different query strings = different cache keys
    return jsonify(compute_expensive_data())

# 2. Function Caching
@cache.memoize(timeout=600)
def get_user_stats(user_id):
    """Cache individual user stats."""
    # Expensive computation
    return compute_user_stats(user_id)

# 3. Template Caching
# In template:
# {% cache 300, 'user_widget', user.id %}
#     <div class="user-widget">
#         {{ user.name }}
#         {{ user.stats }}
#     </div>
# {% endcache %}

# 4. Custom Cache Strategy
class CustomCache:
    """Custom caching with fallback and invalidation."""
    
    def __init__(self, cache):
        self.cache = cache
    
    def get_or_compute(self, key, compute_func, timeout=300):
        """Get from cache or compute if missing."""
        value = self.cache.get(key)
        if value is not None:
            return value
        
        value = compute_func()
        self.cache.set(key, value, timeout=timeout)
        return value
    
    def invalidate_pattern(self, pattern):
        """Invalidate all keys matching a pattern."""
        # For Redis, use SCAN to find matching keys
        redis_client = self.cache._client
        for key in redis_client.scan_iter(f"*{pattern}*"):
            redis_client.delete(key)
    
    def invalidate_user_cache(self, user_id):
        """Invalidate all cache for a user."""
        self.invalidate_pattern(f"*user:{user_id}*")
        self.invalidate_pattern(f"*:user_{user_id}_*")

# Usage
cache_manager = CustomCache(cache)

@app.route('/api/user/<int:user_id>/stats')
def user_stats(user_id):
    def compute_stats():
        return compute_user_stats(user_id)
    
    return jsonify(cache_manager.get_or_compute(
        f"user_stats:{user_id}",
        compute_stats,
        timeout=600
    ))
```

### Cache Invalidation Strategies

```python
# 1. Time-based invalidation (TTL)
@cache.cached(timeout=300)
def get_data():
    return expensive_computation()

# 2. Event-based invalidation
def invalidate_related_caches(event):
    """Invalidate cache based on events."""
    if event.type == 'task_created':
        cache.delete(f"user_tasks:{event.user_id}")
        cache.delete(f"task_stats:{event.user_id}")
    elif event.type == 'task_updated':
        cache.delete(f"task:{event.task_id}")
        cache.delete(f"user_tasks:{event.user_id}")
    elif event.type == 'user_updated':
        cache.delete_pattern(f"user:*:{event.user_id}:*")

# 3. Cache-Aside Pattern
def get_user_with_cache(user_id):
    """Cache-Aside caching pattern."""
    cache_key = f"user:{user_id}"
    
    # Check cache
    user_data = cache.get(cache_key)
    if user_data is not None:
        return user_data
    
    # Cache miss - get from database
    user = User.query.get(user_id)
    if not user:
        return None
    
    # Store in cache
    user_data = user.to_dict()
    cache.set(cache_key, user_data, timeout=600)
    
    return user_data

# 4. Write-Through Pattern
def update_user_with_cache(user_id, data):
    """Write-Through caching pattern."""
    # Update database
    user = User.query.get(user_id)
    for key, value in data.items():
        setattr(user, key, value)
    db.session.commit()
    
    # Update cache
    cache_key = f"user:{user_id}"
    cache.set(cache_key, user.to_dict(), timeout=600)
    
    return user

# 5. Cache Stampede Prevention
def get_data_with_mutex(key, compute_func, timeout=300):
    """Prevent cache stampede with distributed mutex."""
    # Try to get from cache
    value = cache.get(key)
    if value is not None:
        return value
    
    # Try to acquire mutex
    mutex_key = f"{key}_mutex"
    if cache.add(mutex_key, "locked", timeout=10):
        try:
            # Compute new value
            value = compute_func()
            cache.set(key, value, timeout=timeout)
            return value
        finally:
            cache.delete(mutex_key)
    else:
        # Another process is computing, wait and retry
        time.sleep(0.1)
        return get_data_with_mutex(key, compute_func, timeout)
```

---

## 5. API Performance Optimization

### API Response Compression

```python
from flask import Response
import gzip
from io import BytesIO

def compress_response(response):
    """Compress response with gzip."""
    if 'Content-Encoding' in response.headers:
        return response
    
    # Only compress large responses
    if len(response.data) < 1024:
        return response
    
    # Check if client accepts gzip
    if 'gzip' not in request.headers.get('Accept-Encoding', ''):
        return response
    
    # Compress response
    gzip_buffer = BytesIO()
    with gzip.GzipFile(mode='w', fileobj=gzip_buffer) as gzip_file:
        gzip_file.write(response.data)
    
    response.data = gzip_buffer.getvalue()
    response.headers['Content-Encoding'] = 'gzip'
    response.headers['Content-Length'] = len(response.data)
    
    return response

# Apply compression
@app.after_request
def compress(response):
    return compress_response(response)

# API pagination for large datasets
def paginate_query(query, page, per_page):
    """Paginate query results with metadata."""
    # Get total count
    total = query.count()
    
    # Calculate pagination
    per_page = min(per_page, 100)  # Max per page
    offset = (page - 1) * per_page
    
    # Get items
    items = query.limit(per_page).offset(offset).all()
    
    # Return with metadata
    return {
        'items': items,
        'pagination': {
            'page': page,
            'per_page': per_page,
            'total': total,
            'pages': (total + per_page - 1) // per_page,
            'has_next': page * per_page < total,
            'has_prev': page > 1,
        }
    }

# API response optimization
def optimized_api_response(data, status=200):
    """Optimize API responses with compression and caching."""
    response = jsonify(data)
    response.status_code = status
    
    # Add cache headers for GET requests
    if request.method == 'GET':
        response.headers['Cache-Control'] = 'public, max-age=60'
        response.headers['Vary'] = 'Accept-Encoding'
    
    # Add rate limit headers
    response.headers['X-RateLimit-Limit'] = '100'
    response.headers['X-RateLimit-Remaining'] = '95'
    
    return response
```

### API Response Optimization

```python
# 1. Field selection
class TaskSchema(Schema):
    class Meta:
        # Only include fields that are actually needed
        fields = ('id', 'title', 'status', 'due_date')
        
    # Or use exclude to omit certain fields
    # exclude = ('user_id', 'created_at')

# 2. Partial response (GraphQL style)
@app.route('/api/tasks')
def get_tasks():
    # Support field selection
    fields = request.args.get('fields', '').split(',')
    
    tasks = Task.query.all()
    
    if fields and fields[0]:
        # Only return requested fields
        result = []
        for task in tasks:
            result.append({
                field: getattr(task, field)
                for field in fields
                if hasattr(task, field)
            })
        return jsonify(result)
    else:
        # Return all fields
        return jsonify([task.to_dict() for task in tasks])

# 3. Batch operations
@app.route('/api/tasks/batch', methods=['POST'])
def batch_tasks():
    """Process multiple operations in one request."""
    operations = request.get_json()
    
    results = []
    for op in operations:
        try:
            if op['method'] == 'GET':
                task = Task.query.get(op['id'])
                results.append({'status': 'success', 'data': task.to_dict()})
            elif op['method'] == 'UPDATE':
                task = Task.query.get(op['id'])
                for key, value in op['data'].items():
                    setattr(task, key, value)
                db.session.commit()
                results.append({'status': 'success'})
            elif op['method'] == 'DELETE':
                task = Task.query.get(op['id'])
                db.session.delete(task)
                db.session.commit()
                results.append({'status': 'success'})
        except Exception as e:
            results.append({'status': 'error', 'error': str(e)})
    
    return jsonify(results)

# 4. ETag support
from hashlib import md5

@app.route('/api/tasks/<int:task_id>')
def get_task_with_etag(task_id):
    task = Task.query.get(task_id)
    if not task:
        abort(404)
    
    # Generate ETag from data
    data = task.to_dict()
    etag = md5(json.dumps(data, sort_keys=True).encode()).hexdigest()
    
    # Check if client has matching ETag
    if request.headers.get('If-None-Match') == etag:
        return '', 304
    
    response = jsonify(data)
    response.headers['ETag'] = etag
    return response
```

---

## 6. Scaling Strategies

### Horizontal Scaling Configuration

```python
# Gunicorn configuration for horizontal scaling
gunicorn_config = {
    'workers': 4,                    # Number of worker processes
    'worker_class': 'gevent',        # Async worker class
    'worker_connections': 1000,      # Max connections per worker
    'threads': 2,                    # Threads per worker
    'preload_app': True,            # Preload application
    'timeout': 30,                   # Worker timeout
    'keepalive': 5,                  # Keep-alive timeout
    'max_requests': 1000,           # Restart workers after N requests
    'max_requests_jitter': 100,     # Add jitter to prevent thundering herd
    'graceful_timeout': 30,         # Graceful worker shutdown
    'limit_request_line': 0,        # No limit
    'limit_request_fields': 100,    # Max request fields
    'limit_request_field_size': 8190,  # Max field size
}

# Load balancer configuration (HAProxy example)
haproxy_config = """
global
    maxconn 50000
    log /dev/log local0
    user haproxy
    group haproxy

defaults
    log global
    mode http
    option httplog
    option dontlognull
    retries 3
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http-in
    bind *:80
    bind *:443 ssl crt /etc/ssl/haproxy/
    redirect scheme https if !{ ssl_fc }
    default_backend taskflow_backend

backend taskflow_backend
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    server web1 10.0.0.10:8000 check
    server web2 10.0.0.11:8000 check
    server web3 10.0.0.12:8000 check
"""
```

### Database Scaling Patterns

```python
# 1. Sharding Strategy
class ShardManager:
    """Database sharding based on user_id."""
    
    SHARDS = {
        0: 'shard0:5432/taskflow',
        1: 'shard1:5432/taskflow',
        2: 'shard2:5432/taskflow',
    }
    
    @staticmethod
    def get_shard(user_id):
        """Get shard ID for a user."""
        return user_id % len(ShardManager.SHARDS)
    
    @staticmethod
    def get_connection(user_id):
        """Get database connection for user's shard."""
        shard_id = ShardManager.get_shard(user_id)
        db_url = ShardManager.SHARDS[shard_id]
        return create_engine(f'postgresql://user:pass@{db_url}')

    @staticmethod
    def get_user_task(user_id, task_id):
        """Get a task from the correct shard."""
        engine = ShardManager.get_connection(user_id)
        with engine.connect() as conn:
            result = conn.execute(
                "SELECT * FROM tasks WHERE id = :task_id AND user_id = :user_id",
                {'task_id': task_id, 'user_id': user_id}
            )
            return result.fetchone()

# 2. Partitioning (PostgreSQL)
create_partition_sql = """
-- Partition tasks table by month
CREATE TABLE tasks (
    id SERIAL,
    title TEXT,
    user_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Create monthly partitions
CREATE TABLE tasks_2024_01 PARTITION OF tasks
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE tasks_2024_02 PARTITION OF tasks
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Create partition for current month automatically
CREATE OR REPLACE FUNCTION create_monthly_partition()
RETURNS TRIGGER AS $$
BEGIN
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS tasks_%s PARTITION OF tasks
         FOR VALUES FROM (''%s'') TO (''%s'')',
        to_char(NEW.created_at, 'YYYY_MM'),
        date_trunc('month', NEW.created_at),
        date_trunc('month', NEW.created_at + interval '1 month')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
"""
```

### Microservices Pattern

```python
# Service discovery and communication
class ServiceRegistry:
    """Simple service registry for microservices."""
    
    SERVICES = {}
    
    @classmethod
    def register(cls, name, url):
        """Register a service."""
        cls.SERVICES[name] = url
    
    @classmethod
    def get_url(cls, name):
        """Get service URL."""
        return cls.SERVICES.get(name)
    
    @classmethod
    def call_service(cls, name, endpoint, method='GET', data=None):
        """Call a microservice."""
        base_url = cls.get_url(name)
        if not base_url:
            return None
        
        url = f"{base_url}/{endpoint.lstrip('/')}"
        
        try:
            if method == 'GET':
                response = requests.get(url, timeout=5)
            elif method == 'POST':
                response = requests.post(url, json=data, timeout=5)
            elif method == 'PUT':
                response = requests.put(url, json=data, timeout=5)
            elif method == 'DELETE':
                response = requests.delete(url, timeout=5)
            
            return response.json() if response.status_code == 200 else None
            
        except requests.RequestException as e:
            current_app.logger.error(f"Service call failed: {e}")
            return None

# Circuit breaker pattern
class CircuitBreaker:
    """Circuit breaker for service calls."""
    
    def __init__(self, name, failure_threshold=5, timeout=60):
        self.name = name
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.failures = 0
        self.last_failure_time = None
        self.open = False
    
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if self.open:
                # Circuit is open, check if timeout has elapsed
                if self.last_failure_time and (time.time() - self.last_failure_time) > self.timeout:
                    self.open = False
                    self.failures = 0
                else:
                    # Circuit is still open
                    return None
            
            try:
                result = func(*args, **kwargs)
                # Success - reset failures
                self.failures = 0
                return result
            except Exception as e:
                # Failure
                self.failures += 1
                self.last_failure_time = time.time()
                
                if self.failures >= self.failure_threshold:
                    self.open = True
                    current_app.logger.warning(f"Circuit breaker opened for {self.name}")
                
                raise e
        
        return wrapper

# Usage
@CircuitBreaker('tasks_service', failure_threshold=3, timeout=30)
def call_tasks_service(endpoint, data=None):
    return ServiceRegistry.call_service('tasks', endpoint, data=data)
```

---

## 7. Load Testing & Capacity Planning

### Load Testing with Locust

```python
# locustfile.py
from locust import HttpUser, task, between

class TaskflowUser(HttpUser):
    """Simulated user for load testing."""
    
    wait_time = between(0.5, 2)
    token = None
    
    def on_start(self):
        """Login and get token."""
        response = self.client.post("/api/auth/login", json={
            "email": "test@example.com",
            "password": "password123"
        })
        if response.status_code == 200:
            self.token = response.json()["access_token"]
    
    @task(3)
    def view_tasks(self):
        """View tasks page."""
        if self.token:
            self.client.get("/api/tasks", headers={
                "Authorization": f"Bearer {self.token}"
            })
    
    @task(2)
    def view_task_detail(self):
        """View single task."""
        if self.token:
            self.client.get("/api/tasks/1", headers={
                "Authorization": f"Bearer {self.token}"
            })
    
    @task(1)
    def create_task(self):
        """Create a new task."""
        if self.token:
            self.client.post("/api/tasks", headers={
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json"
            }, json={
                "title": "Load test task",
                "priority": "high"
            })

# Run:
# locust -f locustfile.py --host=http://localhost:8000
# Then open http://localhost:8089 to start test
```

### Capacity Planning

```python
# Capacity planning calculations
def capacity_planning():
    """
    Calculate infrastructure needs based on expected load.
    """
    # Assumptions
    expected_daily_users = 10000
    requests_per_user = 100
    peak_factor = 3  # Peak traffic is 3x average
    request_size_kb = 50
    
    # Calculate requests per second
    daily_requests = expected_daily_users * requests_per_user
    avg_rps = daily_requests / 86400  # 86400 seconds in a day
    peak_rps = avg_rps * peak_factor
    
    # Calculate bandwidth
    daily_bandwidth_mb = daily_requests * request_size_kb / 1024
    peak_bandwidth_mbps = (peak_rps * request_size_kb * 8) / 1000
    
    # Database calculations
    db_connections = peak_rps / 10  # Assume each connection handles 10 requests/sec
    db_connections = max(db_connections, 20)  # Minimum
    
    # Memory requirements
    memory_per_request_mb = 10
    memory_required_mb = peak_rps * memory_per_request_mb
    
    # Results
    return {
        'peak_rps': peak_rps,
        'avg_rps': avg_rps,
        'daily_bandwidth_mb': daily_bandwidth_mb,
        'peak_bandwidth_mbps': peak_bandwidth_mbps,
        'db_connections': db_connections,
        'memory_required_mb': memory_required_mb,
        'gunicorn_workers': int(peak_rps / 20),  # Each worker handles ~20 req/s
        'cache_size_mb': int(peak_rps * 5),  # Cache 5 seconds of traffic
    }
```

---

## 8. Monitoring & Alerting

### Application Performance Monitoring (APM)

```python
import newrelic.agent
from datadog import statsd

# New Relic instrumentation
@app.before_request
def start_newrelic_transaction():
    if hasattr(g, 'newrelic_transaction'):
        return
    g.newrelic_transaction = newrelic.agent.current_transaction()

@app.after_request
def end_newrelic_transaction(response):
    if hasattr(g, 'newrelic_transaction'):
        newrelic.agent.end_transaction()
    return response

# DataDog StatsD integration
class DataDogMetrics:
    """Custom DataDog metrics."""
    
    @staticmethod
    def record_request(endpoint, duration, status_code):
        """Record request metrics."""
        tags = ['endpoint:' + endpoint, 'status:' + str(status_code)]
        statsd.increment('flask.request.count', tags=tags)
        statsd.histogram('flask.request.duration', duration, tags=tags)
        
        if status_code >= 500:
            statsd.increment('flask.request.errors', tags=tags)
    
    @staticmethod
    def record_db_query(duration, query_type):
        """Record database query metrics."""
        tags = ['type:' + query_type]
        statsd.histogram('flask.db.query.duration', duration, tags=tags)
    
    @staticmethod
    def record_cache_hit(hit):
        """Record cache metrics."""
        statsd.increment('flask.cache.hit' if hit else 'flask.cache.miss')

# Custom health metrics endpoint
@app.route('/health/metrics')
def health_metrics():
    """Get detailed health metrics."""
    import psutil
    import threading
    
    metrics = {
        'cpu': psutil.cpu_percent(interval=0.5),
        'memory': {
            'total': psutil.virtual_memory().total,
            'available': psutil.virtual_memory().available,
            'percent': psutil.virtual_memory().percent,
        },
        'disk': {
            'total': psutil.disk_usage('/').total,
            'used': psutil.disk_usage('/').used,
            'free': psutil.disk_usage('/').free,
            'percent': psutil.disk_usage('/').percent,
        },
        'process': {
            'threads': threading.active_count(),
            'memory': psutil.Process(os.getpid()).memory_info().rss,
            'connections': len(psutil.net_connections()),
        },
        'database': get_database_metrics(),
        'redis': get_redis_metrics(),
        'request_stats': {
            'total': request_counter.total,
            'errors': request_counter.errors,
            'avg_response': request_counter.get_avg_response(),
        }
    }
    
    # Set status based on metrics
    status = 'healthy'
    if metrics['cpu'] > 80 or metrics['memory']['percent'] > 85:
        status = 'degraded'
    if metrics['database'].get('status') != 'healthy':
        status = 'unhealthy'
    
    return jsonify({
        'status': status,
        'metrics': metrics
    }), 200 if status != 'unhealthy' else 503
```

### Alert Configuration

```python
# Alert rules configuration
alert_rules = {
    'high_cpu': {
        'condition': lambda: psutil.cpu_percent() > 80,
        'severity': 'warning',
        'message': 'CPU usage is above 80%',
        'action': lambda: notify_admin('High CPU usage detected')
    },
    'high_memory': {
        'condition': lambda: psutil.virtual_memory().percent > 85,
        'severity': 'warning',
        'message': 'Memory usage is above 85%',
        'action': lambda: notify_admin('High memory usage detected')
    },
    'database_error': {
        'condition': lambda: get_database_status() != 'healthy',
        'severity': 'critical',
        'message': 'Database is not healthy',
        'action': lambda: notify_admin('Database error detected')
    },
    'high_error_rate': {
        'condition': lambda: get_error_rate() > 0.05,
        'severity': 'critical',
        'message': 'Error rate is above 5%',
        'action': lambda: notify_admin('High error rate detected')
    },
    'high_response_time': {
        'condition': lambda: get_avg_response_time() > 2.0,
        'severity': 'warning',
        'message': 'Response time is above 2 seconds',
        'action': lambda: notify_admin('High response time detected')
    }
}

def check_alerts():
    """Check all alert rules."""
    for name, rule in alert_rules.items():
        try:
            if rule['condition']():
                current_app.logger.warning(f"Alert: {name} - {rule['message']}")
                if rule.get('action'):
                    rule['action']()
        except Exception as e:
            current_app.logger.error(f"Alert check failed for {name}: {e}")

# Scheduled alert checking
import schedule

def schedule_alert_checks():
    """Schedule periodic alert checks."""
    schedule.every(1).minutes.do(check_alerts)
    
    while True:
        schedule.run_pending()
        time.sleep(10)
```

---

## 9. Disaster Recovery & High Availability

### Backup and Recovery Strategy

```python
import subprocess
from datetime import datetime
import boto3
from pathlib import Path

class BackupManager:
    """Automated backup and recovery management."""
    
    def __init__(self):
        self.backup_dir = Path('/var/backups/taskflow')
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        self.s3_client = boto3.client('s3')
        self.bucket_name = 'taskflow-backups'
    
    def create_full_backup(self):
        """Create a full backup of all data."""
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        backup_file = self.backup_dir / f"full_backup_{timestamp}.tar.gz"
        
        # Backup database
        db_backup = self.backup_dir / f"db_backup_{timestamp}.sql.gz"
        subprocess.run([
            'pg_dump',
            '-h', 'localhost',
            '-U', 'taskflow',
            '-d', 'taskflow',
            '-Fc',  # Custom format
            '-f', str(db_backup)
        ], check=True)
        
        # Backup uploads
        uploads_backup = self.backup_dir / f"uploads_{timestamp}.tar.gz"
        subprocess.run([
            'tar', '-czf', str(uploads_backup),
            '-C', '/var/www/taskflow', 'uploads'
        ], check=True)
        
        # Backup configuration
        config_backup = self.backup_dir / f"config_{timestamp}.tar.gz"
        subprocess.run([
            'tar', '-czf', str(config_backup),
            '-C', '/etc', 'taskflow'
        ], check=True)
        
        # Combine all backups
        combined_backup = self.backup_dir / f"full_backup_{timestamp}.tar.gz"
        subprocess.run([
            'tar', '-czf', str(combined_backup),
            '-C', str(self.backup_dir),
            f"db_backup_{timestamp}.sql.gz",
            f"uploads_{timestamp}.tar.gz",
            f"config_{timestamp}.tar.gz"
        ], check=True)
        
        # Upload to S3
        self.upload_to_s3(combined_backup)
        
        # Clean old backups
        self.clean_old_backups()
        
        return combined_backup
    
    def restore_from_backup(self, backup_file):
        """Restore from a backup file."""
        if not backup_file.exists():
            raise FileNotFoundError(f"Backup file not found: {backup_file}")
        
        # Extract backup
        subprocess.run([
            'tar', '-xzf', str(backup_file),
            '-C', str(self.backup_dir)
        ], check=True)
        
        # Extract timestamp from filename
        timestamp = backup_file.stem.replace('full_backup_', '')
        
        # Restore database
        db_backup = self.backup_dir / f"db_backup_{timestamp}.sql.gz"
        subprocess.run([
            'pg_restore',
            '-h', 'localhost',
            '-U', 'taskflow',
            '-d', 'taskflow',
            str(db_backup)
        ], check=True)
        
        # Restore uploads
        uploads_backup = self.backup_dir / f"uploads_{timestamp}.tar.gz"
        subprocess.run([
            'tar', '-xzf', str(uploads_backup),
            '-C', '/var/www/taskflow'
        ], check=True)
        
        # Restore configuration
        config_backup = self.backup_dir / f"config_{timestamp}.tar.gz"
        subprocess.run([
            'tar', '-xzf', str(config_backup),
            '-C', '/etc'
        ], check=True)
        
        # Restart services
        subprocess.run(['systemctl', 'restart', 'taskflow'], check=True)
    
    def upload_to_s3(self, file_path):
        """Upload backup to S3."""
        try:
            self.s3_client.upload_file(
                str(file_path),
                self.bucket_name,
                f"backups/{file_path.name}"
            )
        except Exception as e:
            current_app.logger.error(f"Failed to upload to S3: {e}")
    
    def clean_old_backups(self):
        """Remove backups older than 30 days."""
        cutoff = time.time() - 30 * 86400
        
        for file_path in self.backup_dir.glob("*.tar.gz"):
            if file_path.stat().st_mtime < cutoff:
                file_path.unlink()
                current_app.logger.info(f"Deleted old backup: {file_path}")
```

### High Availability Configuration

```python
# HA configuration for Nginx
ha_nginx_config = """
upstream taskflow_backend {
    # Load balancing
    least_conn;
    
    # Active servers
    server web1:8000 max_fails=3 fail_timeout=30s;
    server web2:8000 max_fails=3 fail_timeout=30s;
    server web3:8000 max_fails=3 fail_timeout=30s;
    
    # Backup servers
    server backup1:8000 backup;
    server backup2:8000 backup;
}

# Health check endpoint
location /health {
    access_log off;
    proxy_pass http://taskflow_backend;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Health check timeout
    proxy_connect_timeout 5s;
    proxy_timeout 5s;
    proxy_read_timeout 5s;
}
"""

# Database high availability with replication
db_ha_config = """
# Primary database
primary:
  host: db-primary
  port: 5432

# Replica databases
replicas:
  - host: db-replica1
    port: 5432
  - host: db-replica2
    port: 5432

# Automatic failover
failover:
  enabled: true
  timeout: 60
  max_retries: 3
  promotion: auto
"""

# Failover script
def handle_database_failover():
    """
    Handle automatic database failover.
    """
    # Check primary health
    if not is_database_healthy('primary'):
        current_app.logger.critical("Primary database is down, initiating failover")
        
        # Promote replica to primary
        promote_replica_to_primary()
        
        # Update application config
        update_database_config('new_primary')
        
        # Notify team
        notify_admin("Database failover initiated")
        
        # Restart affected services
        restart_affected_services()
        
        return True
    
    return False

# Health check with failover
def health_check_with_failover():
    """
    Periodic health check with automatic failover.
    """
    while True:
        try:
            # Check database health
            db_healthy = check_database_health()
            if not db_healthy:
                handle_database_failover()
            
            # Check Redis health
            redis_healthy = check_redis_health()
            if not redis_healthy:
                handle_redis_failover()
            
            # Check application health
            app_healthy = check_application_health()
            if not app_healthy:
                restart_application()
            
            time.sleep(30)
            
        except Exception as e:
            current_app.logger.error(f"Health check failed: {e}")
            time.sleep(60)
```

---

## Summary

This appendix has covered comprehensive production performance tuning and scaling:

1. **Performance Measurement**: Profiling, metrics collection, monitoring
2. **Application Optimization**: Code improvements, connection pooling, template optimization
3. **Database Tuning**: Query optimization, indexing, connection pooling, read replicas
4. **Caching**: Multi-level caching, invalidation strategies, stampede prevention
5. **API Optimization**: Compression, pagination, field selection, batch operations
6. **Scaling Strategies**: Horizontal scaling, sharding, partitioning, microservices
7. **Load Testing**: Capacity planning, performance testing, bottleneck identification
8. **Monitoring**: APM integration, alerting, metrics collection
9. **Disaster Recovery**: Backup strategy, restore procedures, high availability

**Performance Optimization Checklist**:
- [ ] Use Gunicorn with appropriate worker count
- [ ] Enable compression (gzip) for responses
- [ ] Implement caching for expensive operations
- [ ] Optimize database queries with indexes and eager loading
- [ ] Use connection pooling with proper configuration
- [ ] Implement read/write splitting for database
- [ ] Add CDN for static assets
- [ ] Use async views for I/O-bound operations
- [ ] Implement request rate limiting
- [ ] Set up monitoring and alerting
- [ ] Create automated backup strategy
- [ ] Test with load testing tools
