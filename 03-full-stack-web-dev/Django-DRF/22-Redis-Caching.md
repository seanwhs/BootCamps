# Part 22: Redis Caching

## Accelerating Your Application with Redis

Welcome to **Part 22** of the Django REST Framework & Next.js 16 masterclass. Now that we've optimized our database queries, it's time to add Redis caching to further accelerate our application. We'll implement multiple caching strategies to reduce database load and improve response times.

In this part, we'll:
- Set up Redis with Django
- Implement view caching
- Add API response caching
- Implement low-level caching
- Build cache invalidation strategies
- Create a caching layer for expensive operations

Think of Redis as your application's **express lane**. Just as a supermarket has an express checkout for quick purchases, Redis provides a fast path for frequently accessed data, bypassing the slower database.

---

## The Target

We'll implement a complete caching system:

```
Caching Architecture:
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  Request ──▶ Cache Check ──▶ Hit ──▶ Return Cached Response       │
│                │                                                   │
│                │ Miss                                              │
│                ▼                                                   │
│            Database ──▶ Store in Cache ──▶ Return Response        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

Caching Strategies:
┌─────────────────────────────────────────────────────────────────────┐
│  1. View Caching       - Cache entire API responses                │
│  2. Query Caching      - Cache database query results              │
│  3. Template Caching   - Cache rendered templates                  │
│  4. Session Caching    - Cache user sessions (future)              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Concept

### Why Redis?

Redis is an in-memory data store that provides:
- **Speed**: Sub-millisecond response times
- **Persistence**: Data can be persisted to disk
- **Data structures**: Strings, hashes, lists, sets, sorted sets
- **TTL**: Time-to-live for automatic expiration
- **Atomic operations**: Thread-safe operations

### Caching Strategies

1. **Write-Through**: Write to cache and database simultaneously
2. **Write-Behind**: Write to cache, then asynchronously to database
3. **Cache-Aside**: Check cache first, then database on miss
4. **Time-Based**: Cache expires after a set time
5. **Event-Based**: Cache invalidated on specific events

### What to Cache

| Type | TTL | Example |
|------|-----|---------|
| **Static data** | Long (hours/days) | User roles, project lists |
| **Dynamic data** | Short (minutes) | Task lists, search results |
| **User-specific** | Medium (hours) | User profiles, settings |
| **Aggregated data** | Long (hours) | Stats, counts, reports |

---

## The Implementation

### Step 1: Configure Redis

**backend/config/settings.py** (update Redis settings)

```python
# Redis cache configuration
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/1'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'PARSER_CLASS': 'redis.connection.HiredisParser',
            'CONNECTION_POOL_CLASS': 'redis.BlockingConnectionPool',
            'CONNECTION_POOL_CLASS_KWARGS': {
                'max_connections': 50,
                'timeout': 20,
            },
            'MAX_CONNECTIONS': 1000,
            'PICKLE_VERSION': -1,
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
        },
        'KEY_PREFIX': 'taskflow',
    },
    'session': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/2'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
        'KEY_PREFIX': 'taskflow_session',
    },
    'rate_limit': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': env('REDIS_URL', default='redis://localhost:6379/3'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
        'KEY_PREFIX': 'taskflow_ratelimit',
    },
}

# Cache timeouts (in seconds)
CACHE_TTL = {
    'short': 60,           # 1 minute
    'medium': 300,         # 5 minutes
    'long': 3600,          # 1 hour
    'very_long': 86400,    # 24 hours
}

# Session engine
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'session'
```

### Step 2: Create Cache Utilities

**backend/apps/api/cache.py** (create)

```python
"""
Caching utilities for API responses.
"""

import hashlib
import json
from functools import wraps
from django.core.cache import cache
from django.conf import settings
from rest_framework.response import Response


def cache_response(timeout=settings.CACHE_TTL['medium'], key_prefix='api'):
    """
    Decorator to cache API responses.
    """
    def decorator(view_func):
        @wraps(view_func)
        def wrapped_view(request, *args, **kwargs):
            # Skip caching for non-GET requests
            if request.method != 'GET':
                return view_func(request, *args, **kwargs)
            
            # Generate cache key
            cache_key = generate_cache_key(request, key_prefix)
            
            # Try to get from cache
            cached_response = cache.get(cache_key)
            if cached_response is not None:
                return Response(cached_response, status=200)
            
            # Not in cache - execute view
            response = view_func(request, *args, **kwargs)
            
            # Store in cache
            if response.status_code == 200:
                cache.set(cache_key, response.data, timeout)
            
            return response
        return wrapped_view
    return decorator


def generate_cache_key(request, prefix='api'):
    """
    Generate a unique cache key for the request.
    """
    # Get request path
    path = request.path
    
    # Get query parameters
    query_params = sorted(request.GET.items())
    
    # Get authentication info (user ID if authenticated)
    user_id = request.user.id if request.user.is_authenticated else 'anonymous'
    
    # Create a unique key
    key_data = {
        'path': path,
        'params': query_params,
        'user': user_id,
    }
    
    key_string = json.dumps(key_data, sort_keys=True)
    key_hash = hashlib.md5(key_string.encode()).hexdigest()
    
    return f"{prefix}:{key_hash}"


def invalidate_cache_prefix(prefix):
    """
    Invalidate all cache keys with a given prefix.
    """
    # Note: This is a simple implementation
    # In production, you might want to use a more sophisticated approach
    # or use Redis pattern matching
    cache.delete_pattern(f"{prefix}:*")


def get_cached_stats():
    """
    Get cached statistics or compute and cache them.
    """
    from apps.tasks.models import Task
    from apps.projects.models import Project
    from django.utils import timezone
    
    cache_key = 'stats:global'
    stats = cache.get(cache_key)
    
    if stats is None:
        # Compute stats
        now = timezone.now()
        tasks = Task.objects.all()
        
        stats = {
            'total_tasks': tasks.count(),
            'total_projects': Project.objects.count(),
            'todo': tasks.filter(status='todo').count(),
            'in_progress': tasks.filter(status='in_progress').count(),
            'review': tasks.filter(status='review').count(),
            'done': tasks.filter(status='done').count(),
            'overdue': tasks.filter(
                due_date__lt=now,
                status__in=['todo', 'in_progress', 'review']
            ).count(),
        }
        
        # Cache for 5 minutes
        cache.set(cache_key, stats, settings.CACHE_TTL['medium'])
    
    return stats


def invalidate_stats_cache():
    """
    Invalidate cached statistics.
    """
    cache.delete('stats:global')
```

### Step 3: Implement View Caching

**backend/apps/tasks/views.py** (add caching)

```python
from apps.api.cache import cache_response

class TaskViewSet(viewsets.ModelViewSet):
    # ... other code ...
    
    @action(detail=False, methods=['get'])
    @cache_response(timeout=300, key_prefix='tasks_stats')
    def stats(self, request):
        """
        Get task statistics with caching.
        """
        filtered_queryset = self.filter_queryset(self.get_queryset())
        
        from django.utils import timezone
        now = timezone.now()
        
        stats = {
            'total': filtered_queryset.count(),
            'todo': filtered_queryset.filter(status='todo').count(),
            'in_progress': filtered_queryset.filter(status='in_progress').count(),
            'review': filtered_queryset.filter(status='review').count(),
            'done': filtered_queryset.filter(status='done').count(),
            'overdue': filtered_queryset.filter(
                due_date__lt=now,
                status__in=['todo', 'in_progress', 'review']
            ).count(),
            'by_priority': {
                'low': filtered_queryset.filter(priority='low').count(),
                'medium': filtered_queryset.filter(priority='medium').count(),
                'high': filtered_queryset.filter(priority='high').count(),
                'urgent': filtered_queryset.filter(priority='urgent').count(),
            }
        }
        
        return Response(stats)
```

### Step 4: Add Low-Level Caching for Common Queries

**backend/apps/tasks/models.py** (add cached properties)

```python
from django.core.cache import cache
from django.conf import settings

class Task(models.Model):
    # ... fields ...
    
    def get_cached_comment_count(self):
        """
        Get comment count with caching.
        """
        cache_key = f'task_comments_count:{self.id}'
        count = cache.get(cache_key)
        
        if count is None:
            count = self.comments.count()
            cache.set(cache_key, count, settings.CACHE_TTL['long'])
        
        return count
    
    def invalidate_comment_count_cache(self):
        """
        Invalidate the cached comment count.
        """
        cache_key = f'task_comments_count:{self.id}'
        cache.delete(cache_key)
```

**backend/apps/comments/models.py** (invalidate cache on save/delete)

```python
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver

class Comment(models.Model):
    # ... fields ...
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Invalidate task comment count cache
        self.task.invalidate_comment_count_cache()
    
    def delete(self, *args, **kwargs):
        task = self.task
        super().delete(*args, **kwargs)
        # Invalidate task comment count cache
        task.invalidate_comment_count_cache()
```

### Step 5: Create Cache Management Commands

**backend/apps/api/management/commands/clear_cache.py** (create)

```python
"""
Django management command to clear cache.
"""

from django.core.management.base import BaseCommand
from django.core.cache import cache


class Command(BaseCommand):
    help = 'Clear all cached data'

    def add_arguments(self, parser):
        parser.add_argument(
            '--prefix',
            type=str,
            help='Clear only cache keys with this prefix',
        )

    def handle(self, *args, **options):
        prefix = options.get('prefix')
        
        if prefix:
            self.stdout.write(f'Clearing cache with prefix: {prefix}')
            # This is a simple implementation
            # In production, use Redis pattern matching
            cache.delete_pattern(f"{prefix}:*")
        else:
            self.stdout.write('Clearing entire cache')
            cache.clear()
        
        self.stdout.write(
            self.style.SUCCESS('Cache cleared successfully')
        )
```

**backend/apps/api/management/commands/warm_cache.py** (create)

```python
"""
Django management command to warm the cache.
"""

from django.core.management.base import BaseCommand
from django.core.cache import cache
from apps.tasks.models import Task
from apps.projects.models import Project
from apps.api.cache import get_cached_stats


class Command(BaseCommand):
    help = 'Warm the cache with common data'

    def handle(self, *args, **options):
        self.stdout.write('Warming cache...')
        
        # Warm statistics cache
        self.stdout.write('  Warming statistics cache...')
        get_cached_stats()
        
        # Warm common project list cache
        self.stdout.write('  Warming project list cache...')
        projects = Project.objects.select_related('created_by').all()[:50]
        cache.set('warm:projects', projects, 3600)
        
        # Warm common task list cache
        self.stdout.write('  Warming task list cache...')
        tasks = Task.objects.select_related('project', 'assigned_to').all()[:50]
        cache.set('warm:tasks', tasks, 3600)
        
        self.stdout.write(
            self.style.SUCCESS('Cache warmed successfully')
        )
```

### Step 6: Create a Cache Stats Endpoint

**backend/apps/api/views.py** (add cache stats view)

```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response
from django.core.cache import cache
import redis


@api_view(['GET'])
@permission_classes([IsAdminUser])
def cache_stats(request):
    """
    Get cache statistics for admin monitoring.
    """
    try:
        # Get Redis info
        redis_client = cache.client.get_client()
        info = redis_client.info()
        
        stats = {
            'connected_clients': info.get('connected_clients', 0),
            'used_memory': info.get('used_memory_human', '0'),
            'total_commands_processed': info.get('total_commands_processed', 0),
            'keyspace_hits': info.get('keyspace_hits', 0),
            'keyspace_misses': info.get('keyspace_misses', 0),
            'hit_rate': info.get('keyspace_hits', 0) / max(1, info.get('keyspace_misses', 0) + 1),
            'uptime': info.get('uptime_in_seconds', 0) / 3600,  # hours
        }
        
        return Response(stats)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=500
        )


@api_view(['POST'])
@permission_classes([IsAdminUser])
def clear_cache(request):
    """
    Clear the entire cache.
    """
    try:
        cache.clear()
        return Response({'status': 'Cache cleared successfully'})
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=500
        )
```

### Step 7: Update URLs for Cache Management

**backend/config/urls.py** (add cache management URLs)

```python
from django.urls import path
from apps.api.views import cache_stats, clear_cache

urlpatterns = [
    # ... other URLs ...
    path('api/v1/cache/stats/', cache_stats, name='cache-stats'),
    path('api/v1/cache/clear/', clear_cache, name='cache-clear'),
]
```

### Step 8: Update Docker Compose for Redis

**docker-compose.yml** (ensure Redis is included)

```yaml
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: taskflow-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    restart: unless-stopped

volumes:
  redis_data:
```

---

## The Verification

### Step 1: Start Redis

```bash
# If using Docker
docker-compose up -d redis

# Or start Redis locally
redis-server
```

### Step 2: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 3: Test Caching

```bash
# First request - should be slow (database query)
time curl -X GET "http://localhost:8000/api/v1/tasks/stats/" \
  -H "Authorization: Bearer $TOKEN"

# Second request - should be fast (cached)
time curl -X GET "http://localhost:8000/api/v1/tasks/stats/" \
  -H "Authorization: Bearer $TOKEN"

# Compare response times
```

### Step 4: Test Cache Invalidation

```bash
# Create a new task (should invalidate stats cache)
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Task",
    "project": 1,
    "status": "todo"
  }'

# Stats should be updated
curl -X GET "http://localhost:8000/api/v1/tasks/stats/" \
  -H "Authorization: Bearer $TOKEN"
```

### Step 5: Check Cache Stats

```bash
# Get cache statistics (admin only)
curl -X GET "http://localhost:8000/api/v1/cache/stats/" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## Key Takeaways

1. **Redis** provides fast, in-memory caching for Django applications.

2. **View caching** reduces database load for frequently accessed endpoints.

3. **Low-level caching** stores expensive query results.

4. **Cache invalidation** is critical for data consistency.

5. **Different TTLs** for different data types optimize performance.

6. **Cache warming** pre-populates the cache for common queries.

7. **Cache statistics** help monitor cache effectiveness.

---

## What's Next

In **Part 23**, we'll implement API performance optimization:

- Query optimization review
- Serialization optimization
- Response compression
- Caching best practices

---

**End of Part 22**

*Next: Part 23 - API Performance*
