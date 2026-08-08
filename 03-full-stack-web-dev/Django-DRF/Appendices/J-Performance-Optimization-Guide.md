# Appendix J: Performance Optimization Guide

## Complete Performance Tuning Reference

Welcome to **Appendix J** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for performance optimization techniques across the entire stack.

---

## Section 1: Django Performance Optimization

### 1.1 Database Query Optimization

**Select Related & Prefetch Related**

```python
# ❌ Bad: N+1 queries
tasks = Task.objects.all()
for task in tasks:
    print(task.project.name)  # Extra query per task

# ✅ Good: Single query with join
tasks = Task.objects.select_related('project').all()
for task in tasks:
    print(task.project.name)  # No extra query

# ✅ Best: Select only needed fields
tasks = Task.objects.select_related('project').only(
    'id', 'title', 'project__name'
).all()

# Complex relationships
tasks = Task.objects.select_related(
    'project', 'assigned_to', 'created_by'
).prefetch_related(
    'comments', 'tags'
).all()
```

**Only & Defer**

```python
# Only load specific fields
tasks = Task.objects.only('id', 'title', 'status')

# Defer large fields
tasks = Task.objects.defer('description', 'long_text_field')

# Performance comparison
# 1. Normal: SELECT * FROM tasks_task (loads all fields)
# 2. Only:   SELECT id, title, status FROM tasks_task (loads only needed)
# 3. Defer:  SELECT all EXCEPT description FROM tasks_task
```

**Query Optimization Patterns**

```python
# Counting efficiently
# ❌ Bad: Count after loading
tasks = Task.objects.all()
count = len(tasks)  # Loads all data

# ✅ Good: Use count()
count = Task.objects.count()  # SELECT COUNT(*)

# Existence check
# ❌ Bad: Loads all data
if Task.objects.filter(status='done').exists():  # Recommended
    pass

# ✅ Good: Use exists()
if Task.objects.filter(status='done').exists():
    pass

# Aggregations
from django.db.models import Count, Sum, Avg

# Bad: Python loops
total = 0
for task in tasks:
    total += task.priority

# Good: Database aggregation
total = Task.objects.aggregate(Sum('priority'))['priority__sum']
```

### 1.2 Database Indexes

**Add Indexes to Models**

```python
class Task(models.Model):
    title = models.CharField(max_length=255)
    status = models.CharField(max_length=20)
    priority = models.CharField(max_length=20)
    due_date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)
    assigned_to = models.ForeignKey(User, on_delete=models.SET_NULL)

    class Meta:
        indexes = [
            # Single column indexes
            models.Index(fields=['status']),
            models.Index(fields=['priority']),
            
            # Composite indexes (for combined filters)
            models.Index(fields=['status', 'priority']),
            
            # Ordered indexes
            models.Index(fields=['-created_at']),
            
            # Functional indexes
            models.Index(fields=['due_date'], 
                       condition=Q(status='todo')),
            
            # Partial index
            models.Index(fields=['assigned_to'], 
                       condition=Q(status__in=['todo', 'in_progress'])),
        ]
```

**Query Analysis**

```python
# Get query count
from django.db import connection

def get_query_count():
    return len(connection.queries)

# Profile a block
import time
from django.db import connection

def profile_queries(func):
    def wrapper(*args, **kwargs):
        connection.queries_log.clear()
        start = time.time()
        result = func(*args, **kwargs)
        duration = time.time() - start
        queries = len(connection.queries)
        print(f"Queries: {queries}, Duration: {duration:.3f}s")
        return result
    return wrapper

@profile_queries
def get_complex_data():
    return Task.objects.select_related('project').all()
```

### 1.3 Caching with Django

**View Caching**

```python
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers

@cache_page(60 * 5)  # Cache for 5 minutes
def task_list(request):
    tasks = Task.objects.all()
    return render(request, 'tasks/list.html', {'tasks': tasks})

@vary_on_headers('Cookie')  # Vary cache by cookie
@cache_page(300)
def user_profile(request):
    # ...
    pass
```

**Template Fragment Caching**

```django
{% load cache %}

{% cache 300 task_list user.id %}
    {% for task in tasks %}
        <div class="task">{{ task.title }}</div>
    {% endfor %}
{% endcache %}
```

**Low-Level Caching**

```python
from django.core.cache import cache

def get_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    profile = cache.get(cache_key)
    
    if profile is None:
        profile = UserProfile.objects.get(user_id=user_id)
        cache.set(cache_key, profile, 3600)  # Cache for 1 hour
    
    return profile

def invalidate_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    cache.delete(cache_key)
```

### 1.4 Serializer Optimization

```python
# Use different serializers for list vs detail

class TaskListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views"""
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'priority', 'created_at']

class TaskDetailSerializer(serializers.ModelSerializer):
    """Full serializer for detail views"""
    project = ProjectSerializer(read_only=True)
    comments = CommentSerializer(many=True, read_only=True)
    
    class Meta:
        model = Task
        fields = '__all__'

# Use in view
class TaskViewSet(viewsets.ModelViewSet):
    def get_serializer_class(self):
        if self.action == 'list':
            return TaskListSerializer
        return TaskDetailSerializer
```

---

## Section 2: Next.js Performance Optimization

### 2.1 Server Components

```tsx
// ✅ Good: Server Component for data fetching
export default async function TaskList() {
    const tasks = await getTasks();  // Server-side fetch
    return <div>{/* Render tasks */}</div>;
}

// ❌ Bad: Client Component with useEffect for initial data
'use client';
export default function TaskList() {
    const [tasks, setTasks] = useState([]);
    useEffect(() => {
        fetch('/api/tasks').then(res => res.json()).then(setTasks);
    }, []);
    return <div>{/* Render tasks */}</div>;
}
```

### 2.2 Image Optimization

```tsx
import Image from 'next/image';

// ✅ Good: Next.js Image component
<Image
    src="/profile.jpg"
    alt="Profile"
    width={200}
    height={200}
    priority  // For above-the-fold
    sizes="(max-width: 768px) 100vw, 50vw"
/>

// ❌ Bad: Regular img tag
<img src="/profile.jpg" alt="Profile" />
```

### 2.3 Dynamic Imports

```tsx
// ✅ Good: Dynamic import for heavy components
import dynamic from 'next/dynamic';

const HeavyChart = dynamic(
    () => import('@/components/HeavyChart'),
    {
        loading: () => <p>Loading chart...</p>,
        ssr: false,  // Client-side only
    }
);

// Lazy load on interaction
const LazyComponent = dynamic(() => import('@/components/HeavyComponent'), {
    ssr: false,
    loading: () => <Skeleton />,
});
```

### 2.4 Code Splitting

```javascript
// next.config.js
module.exports = {
    // Bundle analyzer
    webpack: (config, { isServer }) => {
        if (!isServer) {
            config.plugins.push(
                new BundleAnalyzerPlugin({
                    analyzerMode: 'static',
                    reportFilename: './bundle-report.html',
                })
            );
        }
        return config;
    },
    
    // Module chunking
    modularizeImports: {
        'lodash': {
            transform: 'lodash/{{member}}',
        },
        'date-fns': {
            transform: 'date-fns/{{member}}',
        },
    },
};
```

### 2.5 Caching Strategies

```tsx
// Time-based revalidation
export default async function Page() {
    const data = await fetch('https://api.example.com/data', {
        next: { revalidate: 60 },  // Revalidate every 60 seconds
    });
    return <Component data={data} />;
}

// On-demand revalidation
export async function POST(request) {
    const data = await request.json();
    await updateDatabase(data);
    
    revalidatePath('/dashboard');
    revalidateTag('tasks');
    
    return NextResponse.json({ success: true });
}
```

### 2.6 Font Optimization

```tsx
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google';

// Next.js automatically optimizes fonts
const inter = Inter({
    subsets: ['latin'],
    display: 'swap',
    preload: true,
});

export default function RootLayout({ children }) {
    return (
        <html lang="en" className={inter.className}>
            <body>{children}</body>
        </html>
    );
}
```

---

## Section 3: PostgreSQL Performance

### 3.1 Query Optimization

```sql
-- Use EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT t.*, p.name 
FROM tasks_task t
JOIN projects_project p ON t.project_id = p.id
WHERE t.status = 'todo' 
AND t.created_at > NOW() - INTERVAL '7 days'
ORDER BY t.created_at DESC;

-- Look for:
-- * Sequential scans
-- * Index scans
-- * Sort operations
-- * Hash joins

-- Add indexes for WHERE clauses
CREATE INDEX CONCURRENTLY idx_task_status ON tasks_task (status);
CREATE INDEX CONCURRENTLY idx_task_created ON tasks_task (created_at DESC);

-- Add indexes for JOIN conditions
CREATE INDEX CONCURRENTLY idx_task_project ON tasks_task (project_id);

-- Add partial index for common query
CREATE INDEX CONCURRENTLY idx_task_active 
    ON tasks_task (created_at) 
    WHERE status = 'todo' OR status = 'in_progress';
```

### 3.2 Connection Pooling

```python
# settings.py
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
            'connect_timeout': 5,
        },
    }
}
```

### 3.3 Vacuum & Analyze

```sql
-- Check table statistics
SELECT 
    schemaname,
    tablename,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
WHERE tablename = 'tasks_task';

-- Run vacuum (manual)
VACUUM ANALYZE tasks_task;

-- For production, use vacuumdb tool
# vacuumdb -U postgres -d taskflow_db -t tasks_task
```

---

## Section 4: Redis Optimization

### 4.1 Memory Optimization

```bash
# Check memory usage
redis-cli INFO memory

# Set memory limits
CONFIG SET maxmemory 1GB
CONFIG SET maxmemory-policy allkeys-lru  # LRU eviction

# Find big keys
redis-cli --bigkeys

# Analyze key memory
redis-cli MEMORY USAGE key_name
```

### 4.2 Pipeline Commands

```python
# Python Redis pipeline
import redis
r = redis.Redis()

# ❌ Bad: Separate commands
r.set('key1', 'value1')
r.set('key2', 'value2')
r.incr('counter')

# ✅ Good: Pipeline (single network round-trip)
pipe = r.pipeline()
pipe.set('key1', 'value1')
pipe.set('key2', 'value2')
pipe.incr('counter')
pipe.execute()
```

### 4.3 Cache Invalidation

```python
# Cache invalidation patterns

# 1. Time-based
cache.set('data', data, timeout=300)  # 5 minutes

# 2. Event-based
def update_task(task_id):
    # Update database
    Task.objects.filter(id=task_id).update(status='done')
    # Invalidate cache
    cache.delete(f'task:{task_id}')
    cache.delete('task_list')  # Invalidate list cache

# 3. Version-based
version = 1
cache.set(f'data:v{version}', data)
version += 1  # On update
```

---

## Section 5: Frontend Performance

### 5.1 Bundle Optimization

```javascript
// package.json - Analyze bundle
{
    "scripts": {
        "analyze": "ANALYZE=true npm run build",
    }
}

// next.config.js - Bundle analysis
const withBundleAnalyzer = require('@next/bundle-analyzer')({
    enabled: process.env.ANALYZE === 'true',
});
module.exports = withBundleAnalyzer({});
```

### 5.2 Lazy Loading

```tsx
// React lazy loading
import React, { lazy, Suspense } from 'react';

const HeavyComponent = lazy(() => import('./HeavyComponent'));

function MyComponent() {
    return (
        <Suspense fallback={<div>Loading...</div>}>
            <HeavyComponent />
        </Suspense>
    );
}

// Next.js dynamic imports
import dynamic from 'next/dynamic';

const DynamicComponent = dynamic(
    () => import('../components/HeavyComponent'),
    { ssr: false }
);
```

### 5.3 Performance Monitoring

```tsx
// Add performance monitoring
export function PerformanceMonitor() {
    useEffect(() => {
        // Core Web Vitals
        if ('web-vitals' in window) {
            import('web-vitals').then(({ onCLS, onFID, onLCP }) => {
                onCLS(console.log);
                onFID(console.log);
                onLCP(console.log);
            });
        }
    }, []);
}

// Use Performance API
const start = performance.now();
// ... operation ...
const duration = performance.now() - start;
console.log(`Operation took ${duration}ms`);
```

---

## Section 6: Load Testing

### 6.1 Using Locust

```python
# locustfile.py
from locust import HttpUser, task, between

class TaskUser(HttpUser):
    wait_time = between(1, 5)
    
    @task
    def list_tasks(self):
        self.client.get('/api/v1/tasks/')
    
    @task(2)
    def view_task(self):
        self.client.get('/api/v1/tasks/1/')
    
    @task
    def create_task(self):
        self.client.post('/api/v1/tasks/', json={
            'title': 'Load test task',
            'project': 1,
            'status': 'todo'
        })
```

### 6.2 Using k6

```javascript
// k6-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    stages: [
        { duration: '30s', target: 20 },   // Ramp up
        { duration: '1m', target: 20 },    // Stay at 20
        { duration: '30s', target: 0 },    // Ramp down
    ],
};

export default function() {
    const res = http.get('http://localhost:8000/api/v1/tasks/');
    check(res, {
        'status is 200': (r) => r.status === 200,
        'response time < 200ms': (r) => r.timings.duration < 200,
    });
    sleep(1);
}
```

---

## Performance Checklist

### Backend
- [ ] Database indexes added for query patterns
- [ ] Query count minimized (use select_related, prefetch_related)
- [ ] Caching implemented (Redis)
- [ ] Serializers optimized (list vs detail)
- [ ] Gunicorn workers tuned
- [ ] Database connection pooling configured
- [ ] Pagination implemented for large datasets

### Frontend
- [ ] Images optimized (Next.js Image component)
- [ ] Code splitting implemented
- [ ] Lazy loading for heavy components
- [ ] Fonts optimized (next/font)
- [ ] Bundle analysis performed
- [ ] Caching strategies implemented
- [ ] Core Web Vitals monitored

### Infrastructure
- [ ] CDN configured for static assets
- [ ] Gzip/Brotli compression enabled
- [ ] SSL/TLS optimized
- [ ] Load balancing configured
- [ ] Health checks configured
- [ ] Monitoring and alerting set up

---

*This concludes Appendix J. Use this performance reference to optimize your applications.*
