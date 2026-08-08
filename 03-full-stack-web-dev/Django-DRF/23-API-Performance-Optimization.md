# Part 23: API Performance Optimization

## Squeezing Every Millisecond Out of Your API

Welcome to **Part 23** of the Django REST Framework & Next.js 16 masterclass. Now that we have Redis caching in place, it's time to optimize every aspect of our API performance. We'll fine-tune serializers, optimize database queries, implement response compression, and establish performance monitoring.

In this part, we'll:
- Optimize serializers for speed
- Implement response compression
- Use Django's `only()` and `defer()` effectively
- Implement pagination optimization
- Add performance monitoring
- Create a performance testing suite

Think of this as **fine-tuning your race car**. We've already upgraded the engine (database), added turbo (Redis), now we're optimizing every component to work together seamlessly for maximum speed.

---

## The Target

We'll optimize multiple layers of the API:

```
Performance Optimization Layers:
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  1. Database Layer                                                  │
│     ├── Optimized queries with select_related/prefetch_related     │
│     ├── Database indexes                                           │
│     └── Query optimization                                         │
│                                                                     │
│  2. Serialization Layer                                             │
│     ├── Lightweight serializers for lists                         │
│     ├── Only necessary fields                                      │
│     └── Optimized related field access                             │
│                                                                     │
│  3. Response Layer                                                  │
│     ├── Response compression (gzip)                                │
│     ├── Pagination optimization                                    │
│     └── Selective field inclusion                                  │
│                                                                     │
│  4. Caching Layer                                                   │
│     ├── Response caching                                           │
│     ├── Query caching                                              │
│     └── Cache invalidation strategies                              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Concept

### Performance Bottlenecks

Common bottlenecks and solutions:

| Bottleneck | Cause | Solution |
|------------|-------|----------|
| **Heavy Serializers** | Too many fields, nested relations | Use list vs detail serializers |
| **Large Responses** | Sending unnecessary data | Use `only()`, fields parameter |
| **Slow Queries** | Missing indexes, N+1 queries | Add indexes, use select_related |
| **Large Payloads** | No compression | Enable gzip compression |
| **Database Load** | Too many queries | Caching, query optimization |

### Optimization Principles

1. **Measure First**: Profile before optimizing
2. **Optimize Hot Paths**: Focus on frequently used endpoints
3. **Cache Aggressively**: Cache at multiple levels
4. **Minimize Payloads**: Send only what's needed
5. **Use Async When Possible**: Background tasks for heavy operations

---

## The Implementation

### Step 1: Install Performance Testing Tools

```bash
cd backend
source venv/bin/activate
pip install django-debug-toolbar django-silk
pip install psutil
echo "django-silk>=5.0.0" >> requirements/development.txt
echo "psutil>=5.9.0" >> requirements/base.txt
```

### Step 2: Configure Silk for Profiling

**backend/config/settings.py** (update)

```python
# Add to INSTALLED_APPS in development
if DEBUG:
    INSTALLED_APPS += [
        'debug_toolbar',
        'silk',  # Performance profiling
    ]
    MIDDLEWARE += [
        'debug_toolbar.middleware.DebugToolbarMiddleware',
        'silk.middleware.SilkyMiddleware',
    ]
    
    # Silk settings
    SILKY_PYTHON_PROFILER = True
    SILKY_AUTHENTICATION = True
    SILKY_AUTHORISATION = True
    SILKY_PERMISSIONS = lambda user: user.is_superuser
    SILKY_ANALYZE_QUERIES = True
    SILKY_MAX_REQUEST_BODY_SIZE = -1  # Unlimited
    SILKY_MAX_RESPONSE_BODY_SIZE = -1  # Unlimited
    SILKY_META = True
```

### Step 3: Optimize Serializers with Field Selection

**backend/apps/tasks/serializers.py** (update)

```python
from rest_framework import serializers
from .models import Task


class TaskListSerializer(serializers.ModelSerializer):
    """
    Ultra-lightweight serializer for task lists.
    Only includes fields needed for listing.
    """
    project_name = serializers.CharField(source='project.name')
    assigned_to_username = serializers.CharField(source='assigned_to.username')
    
    class Meta:
        model = Task
        fields = [
            'id', 
            'title', 
            'status', 
            'priority',
            'project_name',
            'assigned_to_username',
            'due_date',
            'created_at'
        ]


class TaskDetailSerializer(serializers.ModelSerializer):
    """
    Full serializer for task details.
    Includes all fields but optimized with select_related.
    """
    project_name = serializers.CharField(source='project.name')
    assigned_to_username = serializers.CharField(source='assigned_to.username')
    created_by_username = serializers.CharField(source='created_by.username')
    status_display = serializers.CharField(source='get_status_display')
    priority_display = serializers.CharField(source='get_priority_display')
    is_overdue = serializers.BooleanField()
    comment_count = serializers.IntegerField()
    
    class Meta:
        model = Task
        fields = [
            'id', 'title', 'description', 'status', 'status_display',
            'priority', 'priority_display', 'due_date', 'is_overdue',
            'project', 'project_name', 'assigned_to', 'assigned_to_username',
            'created_by', 'created_by_username', 'comment_count',
            'created_at', 'updated_at'
        ]
        # Use read_only_fields for fields that shouldn't be writable
        read_only_fields = ['created_at', 'updated_at', 'is_overdue', 'comment_count']


def get_task_serializer_for_action(action, request=None):
    """
    Factory function to get the appropriate serializer.
    """
    # Custom field selection based on request
    if action == 'list':
        return TaskListSerializer
    elif action == 'retrieve':
        return TaskDetailSerializer
    
    # For other actions (create, update, etc.), use the appropriate serializer
    return TaskCreateSerializer if action == 'create' else TaskUpdateSerializer
```

### Step 4: Optimize ViewSets with Dynamic Field Selection

**backend/apps/tasks/views.py** (update with optimization)

```python
class TaskViewSet(viewsets.ModelViewSet):
    # ... other code ...
    
    def get_serializer_class(self):
        """
        Use optimized serializers based on action.
        """
        if self.action == 'list':
            from .serializers import TaskListSerializer
            return TaskListSerializer
        elif self.action == 'retrieve':
            from .serializers import TaskDetailSerializer
            return TaskDetailSerializer
        elif self.action == 'create':
            from .serializers import TaskCreateSerializer
            return TaskCreateSerializer
        elif self.action in ['update', 'partial_update']:
            if self.action == 'partial_update' and 'status' in self.request.data:
                from .serializers import TaskStatusUpdateSerializer
                return TaskStatusUpdateSerializer
            from .serializers import TaskUpdateSerializer
            return TaskUpdateSerializer
        elif self.action == 'status':
            from .serializers import TaskStatusUpdateSerializer
            return TaskStatusUpdateSerializer
        return TaskSerializer
    
    def get_queryset(self):
        """
        Use only() to select only necessary fields.
        """
        user = self.request.user
        
        # For list actions, select only needed fields
        if self.action == 'list':
            return Task.objects.select_related(
                'project', 'assigned_to'
            ).only(
                'id', 'title', 'status', 'priority', 
                'due_date', 'created_at',
                'project__name', 'project__id',
                'assigned_to__username', 'assigned_to__id'
            ).filter(
                models.Q(created_by=user) |
                models.Q(assigned_to=user) |
                models.Q(project__created_by=user)
            ).distinct()
        
        # For detail actions, select all fields
        return Task.objects.select_related(
            'project', 'assigned_to', 'created_by',
            'project__created_by'
        ).prefetch_related(
            'comments'
        ).all()
```

### Step 5: Implement Response Compression

**backend/config/settings.py** (add compression middleware)

```python
# Add to MIDDLEWARE (near the top)
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.middleware.gzip.GZipMiddleware',  # Add for compression
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'apps.api.middleware.PerformanceMiddleware',
]

# Compression settings
GZIP_CONTENT_TYPES = [
    'application/json',
    'application/javascript',
    'text/css',
    'text/html',
    'text/plain',
]
```

### Step 6: Create Performance Middleware

**backend/apps/api/middleware.py** (add performance monitoring)

```python
import time
import logging
from django.utils.deprecation import MiddlewareMixin
from django.db import connection
import psutil

logger = logging.getLogger('api')


class PerformanceMiddleware(MiddlewareMixin):
    """
    Middleware to monitor and log API performance metrics.
    """
    
    def process_request(self, request):
        # Skip for admin and static paths
        if request.path.startswith('/admin/') or request.path.startswith('/static/'):
            return
        
        # Start timing
        request.start_time = time.time()
        request.start_memory = psutil.Process().memory_info().rss / 1024 / 1024  # MB
    
    def process_response(self, request, response):
        if not hasattr(request, 'start_time'):
            return response
        
        # Calculate metrics
        duration = time.time() - request.start_time
        
        # Memory usage
        current_memory = psutil.Process().memory_info().rss / 1024 / 1024
        memory_delta = current_memory - request.start_memory
        
        # Query count
        query_count = len(connection.queries)
        
        # Response size
        response_size = len(response.content) if hasattr(response, 'content') else 0
        
        # Log if slow
        if duration > 0.5:
            logger.warning(
                f"Slow request: {request.path} took {duration:.3f}s, "
                f"{query_count} queries, {response_size/1024:.1f}KB, "
                f"memory: {memory_delta:.1f}MB"
            )
        
        # Add performance headers (for debugging)
        if getattr(settings, 'DEBUG', False):
            response['X-Performance-Duration'] = f"{duration:.3f}s"
            response['X-Performance-Query-Count'] = str(query_count)
            response['X-Performance-Response-Size'] = f"{response_size/1024:.1f}KB"
        
        return response
```

### Step 7: Add Database Connection Pooling

**backend/config/settings.py** (update database settings)

```python
# Database settings with connection pooling
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': env('DB_NAME', default='taskflow_db'),
        'USER': env('DB_USER', default='taskflow_user'),
        'PASSWORD': env('DB_PASSWORD', default=''),
        'HOST': env('DB_HOST', default='localhost'),
        'PORT': env('DB_PORT', default='5432'),
        'CONN_MAX_AGE': 600,  # 10 minutes - keep connections alive
        'CONN_HEALTH_CHECKS': True,  # Check connection health before using
        'OPTIONS': {
            'keepalives': 1,
            'keepalives_idle': 30,
            'keepalives_interval': 10,
            'keepalives_count': 5,
            'connect_timeout': 5,
        },
        'POOL_OPTIONS': {
            'max_connections': 50,
            'min_connections': 5,
        },
    }
}

# For connection pooling, you might want to use:
# pip install django-db-connection-pool
# Then use 'ENGINE': 'django_db_connection_pool.backends.postgresql'
```

### Step 8: Optimize Pagination

**backend/apps/api/pagination.py** (update)

```python
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response


class OptimizedPageNumberPagination(PageNumberPagination):
    """
    Pagination class optimized for performance.
    """
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100
    
    # Cache page numbers to reduce counts
    _cached_count = None
    
    def paginate_queryset(self, queryset, request, view=None):
        # Use count optimization for large datasets
        if queryset.count() > 10000:
            # Use approximate count for large datasets
            self._cached_count = queryset.only('id').count()
        else:
            self._cached_count = None
        
        return super().paginate_queryset(queryset, request, view)
    
    def get_paginated_response(self, data):
        # Use cached count if available
        count = self._cached_count if self._cached_count is not None else self.page.paginator.count
        
        return Response({
            'links': {
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            },
            'count': count,
            'page_size': self.get_page_size(self.request),
            'current_page': self.page.number,
            'total_pages': (count + self.page_size - 1) // self.page_size,
            'results': data,
        })
```

### Step 9: Create Performance Test Suite

**backend/tests/test_performance.py** (create)

```python
"""
Performance tests for the API.
"""

import time
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model
from django.core.cache import cache

User = get_user_model()


class PerformanceTestCase(TestCase):
    """
    Test case for performance monitoring.
    """
    
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='testpass123'
        )
        self.client.force_authenticate(user=self.user)
        
        # Clear cache before each test
        cache.clear()
    
    def test_task_list_performance(self):
        """
        Test that task list responds within acceptable time.
        """
        url = reverse('task-list')
        
        # First request (cold cache)
        start = time.time()
        response = self.client.get(url)
        first_duration = time.time() - start
        
        # Second request (warm cache)
        start = time.time()
        response = self.client.get(url)
        second_duration = time.time() - start
        
        # Assertions
        self.assertLess(first_duration, 1.0, "First request too slow")
        self.assertLess(second_duration, 0.5, "Cached request too slow")
    
    def test_task_detail_performance(self):
        """
        Test that task detail responds quickly.
        """
        # Create a task
        from apps.projects.models import Project
        project = Project.objects.create(
            name='Test Project',
            created_by=self.user
        )
        from apps.tasks.models import Task
        task = Task.objects.create(
            title='Test Task',
            project=project,
            created_by=self.user
        )
        
        url = reverse('task-detail', kwargs={'pk': task.id})
        
        start = time.time()
        response = self.client.get(url)
        duration = time.time() - start
        
        self.assertLess(duration, 0.2, "Task detail too slow")
    
    def test_query_count(self):
        """
        Test that the query count is within acceptable limits.
        """
        from django.db import connection
        from apps.tasks.models import Task
        from apps.projects.models import Project
        
        # Create test data
        project = Project.objects.create(
            name='Test Project',
            created_by=self.user
        )
        Task.objects.create(
            title='Test Task 1',
            project=project,
            created_by=self.user
        )
        Task.objects.create(
            title='Test Task 2',
            project=project,
            created_by=self.user
        )
        
        # Reset query count
        connection.queries_log.clear()
        
        # Fetch tasks with optimized queryset
        tasks = Task.objects.select_related('project').all()
        list(tasks)  # Evaluate queryset
        
        query_count = len(connection.queries)
        self.assertLess(query_count, 5, f"Too many queries: {query_count}")
```

### Step 10: Create Performance Dashboard

**backend/apps/api/views.py** (add performance dashboard)

```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response
from django.core.cache import cache
import psutil
import time
from django.db import connection


@api_view(['GET'])
@permission_classes([IsAdminUser])
def performance_dashboard(request):
    """
    Get comprehensive performance metrics.
    """
    # System metrics
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    # Database metrics
    db_connections = connection.connection.cursor().execute(
        "SELECT count(*) FROM pg_stat_activity;"
    ).fetchone()[0] if connection.connection else 0
    
    # Cache metrics
    cache_stats = {}
    try:
        redis_client = cache.client.get_client()
        info = redis_client.info()
        cache_stats = {
            'hits': info.get('keyspace_hits', 0),
            'misses': info.get('keyspace_misses', 0),
            'hit_rate': info.get('keyspace_hits', 0) / max(1, info.get('keyspace_misses', 0) + 1),
            'used_memory': info.get('used_memory_human', '0'),
        }
    except:
        pass
    
    return Response({
        'system': {
            'cpu_percent': cpu_percent,
            'memory_percent': memory.percent,
            'memory_used': memory.used / 1024 / 1024 / 1024,  # GB
            'memory_total': memory.total / 1024 / 1024 / 1024,  # GB
            'disk_percent': disk.percent,
            'disk_free': disk.free / 1024 / 1024 / 1024,  # GB
        },
        'database': {
            'connections': db_connections,
            'query_count': len(connection.queries),
        },
        'cache': cache_stats,
        'timestamp': time.time(),
    })
```

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Test Serializer Performance

```bash
# Test list endpoint with lightweight serializer
time curl -X GET "http://localhost:8000/api/v1/tasks/?page_size=100" \
  -H "Authorization: Bearer $TOKEN"

# Should be faster than before
```

### Step 3: Test Compression

```bash
# Check response size with and without compression
curl -X GET "http://localhost:8000/api/v1/tasks/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept-Encoding: gzip" \
  -v

# Look for Content-Encoding: gzip header
```

### Step 4: Test Performance Dashboard

```bash
# Get performance metrics
curl -X GET "http://localhost:8000/api/v1/performance/" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### Step 5: Run Performance Tests

```bash
python manage.py test tests.test_performance
```

---

## Key Takeaways

1. **Lightweight serializers** for list views improve performance.

2. **Response compression** reduces bandwidth usage.

3. **Query optimization** with `only()` and `defer()` reduces data transfer.

4. **Connection pooling** reduces database connection overhead.

5. **Performance middleware** helps identify slow requests.

6. **Performance testing** ensures optimizations are effective.

7. **Monitoring** helps maintain performance in production.

---

## What's Next

In **Part 24**, we'll implement automated backend testing:

- Django TestCase
- DRF APITestCase
- Factory Boy
- Coverage reports

---

**End of Part 23**

*Next: Part 24 - Automated Backend Testing*
