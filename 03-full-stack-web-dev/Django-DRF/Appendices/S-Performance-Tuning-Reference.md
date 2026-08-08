# Appendix S: Performance Tuning Reference

## Complete Performance Tuning Reference

Welcome to **Appendix S** of the Django REST Framework & Next.js 16 masterclass. This appendix provides comprehensive performance tuning references, including recommended settings for various components.

---

## Section 1: Django Performance Tuning

### 1.1 Recommended Settings

```python
# settings.py - Performance settings

# Database connection pooling
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'taskflow_db',
        'USER': 'taskflow_user',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '5432',
        'CONN_MAX_AGE': 600,  # Keep connections alive
        'CONN_HEALTH_CHECKS': True,
        'OPTIONS': {
            'keepalives': 1,
            'keepalives_idle': 30,
            'keepalives_interval': 10,
            'keepalives_count': 5,
        },
    }
}

# Cache settings
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'CONNECTION_POOL_CLASS': 'redis.BlockingConnectionPool',
            'CONNECTION_POOL_CLASS_KWARGS': {
                'max_connections': 50,
                'timeout': 20,
            },
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
        },
        'KEY_PREFIX': 'taskflow',
        'TIMEOUT': 300,
    }
}

# Static files
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# Template caching
TEMPLATES = [{
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'OPTIONS': {
        'loaders': [
            ('django.template.loaders.cached.Loader', [
                'django.template.loaders.filesystem.Loader',
                'django.template.loaders.app_directories.Loader',
            ]),
        ],
    },
}]

# Session caching
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'
```

### 1.2 Gunicorn Configuration

```python
# gunicorn.conf.py

import multiprocessing

# Worker count: 2 * CPU cores + 1
workers = multiprocessing.cpu_count() * 2 + 1

# Worker type
worker_class = 'sync'

# Worker connections
worker_connections = 1000

# Timeout
timeout = 30
graceful_timeout = 30

# Max requests per worker (prevents memory leaks)
max_requests = 1000
max_requests_jitter = 100

# Preload application
preload_app = True

# Logging
accesslog = '/var/log/gunicorn/access.log'
errorlog = '/var/log/gunicorn/error.log'
loglevel = 'info'
```

### 1.3 Query Optimization Patterns

```python
# Use select_related for ForeignKey
tasks = Task.objects.select_related('project', 'assigned_to').all()

# Use prefetch_related for ManyToMany
projects = Project.objects.prefetch_related('tasks', 'members').all()

# Use only() for specific fields
tasks = Task.objects.only('id', 'title', 'status', 'created_at')

# Use defer() for heavy fields
tasks = Task.objects.defer('description', 'long_text')

# Use values() for lightweight data
task_data = Task.objects.values('id', 'title', 'status')

# Use exists() for existence checks
exists = Task.objects.filter(status='done').exists()

# Use count() for counting
count = Task.objects.filter(project=project).count()

# Use bulk operations
Task.objects.bulk_create([
    Task(title='Task 1', project=project),
    Task(title='Task 2', project=project),
])
```

---

## Section 2: PostgreSQL Tuning

### 2.1 Recommended Settings

```ini
# postgresql.conf

# Memory
shared_buffers = 256MB      # 25% of RAM
work_mem = 4MB              # Per operation
maintenance_work_mem = 64MB # Maintenance operations
effective_cache_size = 2GB  # OS cache

# Connections
max_connections = 200
superuser_reserved_connections = 3

# WAL
wal_level = replica
wal_buffers = 16MB
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
max_wal_size = 1GB
min_wal_size = 80MB

# Query planning
random_page_cost = 1.1      # SSD
effective_io_concurrency = 200
cpu_tuple_cost = 0.01
cpu_index_tuple_cost = 0.005

# Logging
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_min_duration_statement = 1000  # Log queries > 1s
log_checkpoints = on
log_connections = off
log_disconnections = off
log_lock_waits = on
log_temp_files = 0
```

### 2.2 Query Analysis Commands

```sql
-- Find slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    (total_time / (SELECT sum(total_time) FROM pg_stat_statements)) * 100 as percentage
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Find frequently run queries
SELECT 
    query,
    calls,
    mean_time,
    total_time
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Check table statistics
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY seq_scan DESC;
```

---

## Section 3: Redis Tuning

### 3.1 Recommended Settings

```ini
# redis.conf

# Memory
maxmemory 1GB
maxmemory-policy allkeys-lru

# Persistence
appendonly yes
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# Performance
tcp-backlog 511
timeout 0
tcp-keepalive 300
loglevel notice
databases 16

# Security
requirepass your_password
rename-command CONFIG ""
rename-command FLUSHALL ""
rename-command FLUSHDB ""

# Limits
maxclients 10000
```

### 3.2 Redis Monitoring Commands

```bash
# Check memory usage
redis-cli INFO memory

# Check hit rate
redis-cli INFO stats | grep keyspace

# Check connected clients
redis-cli INFO clients

# Check slow queries
redis-cli SLOWLOG GET 10

# Monitor commands
redis-cli MONITOR

# Check memory stats
redis-cli MEMORY STATS
```

---

## Section 4: Nginx Tuning

### 4.1 Recommended Settings

```nginx
# nginx.conf

# Worker processes
worker_processes auto;
worker_rlimit_nofile 65535;

# Events
events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

# HTTP settings
http {
    # Compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml image/svg+xml text/html;

    # Buffers
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    output_buffers 32 32k;
    postpone_output 1460;

    # Timeouts
    client_body_timeout 60;
    client_header_timeout 60;
    keepalive_timeout 65;
    send_timeout 60;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_requests 100;
}
```

### 4.2 Caching Configuration

```nginx
# Cache settings
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m 
                 max_size=1g inactive=24h use_temp_path=off;

location /api/ {
    proxy_cache api_cache;
    proxy_cache_key "$scheme$request_method$host$request_uri";
    proxy_cache_valid 200 302 5m;
    proxy_cache_valid 404 1m;
    proxy_cache_valid 500 502 503 504 0s;
    proxy_cache_use_stale error timeout updating http_500 http_502 http_503;
    proxy_cache_background_update on;
    proxy_cache_lock on;
    proxy_cache_lock_timeout 5s;
    
    proxy_pass http://backend;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

---

## Section 5: Next.js Performance Tuning

### 5.1 next.config.js

```javascript
// next.config.js
module.exports = {
    // Standalone output
    output: 'standalone',
    
    // Compression
    compress: true,
    
    // Image optimization
    images: {
        domains: ['localhost'],
        deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
        imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
        formats: ['image/webp'],
    },
    
    // Experimental features
    experimental: {
        optimizeCss: true,
        scrollRestoration: true,
    },
    
    // Bundle optimization
    modularizeImports: {
        'lucide-react': {
            transform: 'lucide-react/dist/esm/icons/{{member}}',
        },
        '@radix-ui/react-*': {
            transform: '@radix-ui/react-{{member}}',
        },
    },
};
```

### 5.2 Bundle Analysis

```bash
# Run bundle analysis
npm install -D @next/bundle-analyzer

# Add to next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
    enabled: process.env.ANALYZE === 'true',
});
module.exports = withBundleAnalyzer(nextConfig);

# Run analysis
ANALYZE=true npm run build
```

---

## Section 6: Performance Testing Commands

### 6.1 Load Testing with Artillery

```yaml
# artillery.yml
config:
  target: "http://localhost:8000"
  phases:
    - duration: 60
      arrivalRate: 10
  defaults:
    headers:
      Authorization: "Bearer {{ token }}"

scenarios:
  - flow:
    - loop:
      - get:
          url: "/api/v1/tasks/"
      - get:
          url: "/api/v1/projects/"
      - post:
          url: "/api/v1/tasks/"
          json:
            title: "Load test task"
            project: 1
            status: "todo"
      count: 10
```

```bash
# Run artillery test
artillery run artillery.yml
```

### 6.2 Load Testing with wrk

```bash
# Install wrk
# macOS: brew install wrk
# Ubuntu: sudo apt-get install wrk

# Run load test
wrk -t12 -c400 -d30s --header="Authorization: Bearer $TOKEN" \
    http://localhost:8000/api/v1/tasks/
```

---

## Section 7: Performance Optimization Checklist

### Backend
- [ ] Database indexes are added for query patterns
- [ ] Query count minimized (select_related, prefetch_related)
- [ ] Caching implemented (Redis)
- [ ] Serializers optimized (list vs detail)
- [ ] Gunicorn workers tuned
- [ ] Database connection pooling configured
- [ ] Pagination implemented for large datasets
- [ ] Static files compressed and cached
- [ ] Media files optimized

### Frontend
- [ ] Images optimized (Next.js Image component)
- [ ] Code splitting implemented
- [ ] Lazy loading for heavy components
- [ ] Fonts optimized (next/font)
- [ ] Bundle analysis performed
- [ ] Caching strategies implemented
- [ ] Core Web Vitals monitored
- [ ] Minimize client-side JavaScript
- [ ] Use server components when possible

### Infrastructure
- [ ] CDN configured for static assets
- [ ] Gzip/Brotli compression enabled
- [ ] SSL/TLS optimized
- [ ] Load balancing configured
- [ ] Health checks configured
- [ ] Monitoring and alerting set up
- [ ] Auto-scaling configured

---

*This concludes Appendix S. Use these performance tuning references to optimize your application for production.*
