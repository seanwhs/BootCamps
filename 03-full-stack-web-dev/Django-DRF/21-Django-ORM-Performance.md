# Part 21: Django ORM Performance

## Optimizing Database Queries for Speed

Welcome to **Part 21** of the Django REST Framework & Next.js 16 masterclass. This is the beginning of Phase 4, where we'll optimize our application for production. In this part, we'll focus on Django ORM performance, identifying and fixing slow queries, and ensuring our database can handle real-world loads.

In this part, we'll:
- Understand QuerySets and lazy evaluation
- Identify and fix the N+1 query problem
- Use select_related and prefetch_related
- Add database indexes
- Optimize serialization
- Implement query profiling

Think of this as **tuning your database engine**. Just as a car needs regular maintenance to run smoothly, your database queries need optimization to perform well under load.

---

## The Target

We'll optimize our ORM queries:

```
Performance Optimization Goals:
┌─────────────────────────────────────────────────────────────────────┐
│  Before                     After                                 │
│  ─────────────────────────────────────────────────────────────      │
│  1 API request             1 API request                          │
│       ↓                        ↓                                  │
│  50 database queries       2 database queries                     │
│       ↓                        ↓                                  │
│  800ms response            80ms response                          │
│       ↓                        ↓                                  │
│  Slow user experience      Fast user experience                   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Concept

### The N+1 Query Problem

The N+1 query problem occurs when you make one query to fetch a list of items, then N additional queries to fetch related data for each item:

```python
# Problem: N+1 queries
tasks = Task.objects.all()  # 1 query
for task in tasks:
    print(task.project.name)  # N queries (one per task)
```

**Solution**: Use `select_related` or `prefetch_related`

```python
# Solution: 1 query (join)
tasks = Task.objects.select_related('project').all()
for task in tasks:
    print(task.project.name)  # No additional query
```

### QuerySet Evaluation

QuerySets are lazy - they don't hit the database until evaluated:

```python
# No database query yet
tasks = Task.objects.all()

# Still no query
tasks = tasks.filter(status='todo')

# Database query executes here
print(len(tasks))  # Queries database
print(tasks[0])    # Uses cached results
```

### When to Use What

| Method | Use Case | Example |
|--------|----------|---------|
| `select_related` | ForeignKey, OneToOne | `select_related('project', 'assigned_to')` |
| `prefetch_related` | ManyToMany, reverse FK | `prefetch_related('comments', 'tags')` |
| `only` | Fetch specific fields | `only('title', 'status')` |
| `defer` | Exclude large fields | `defer('description')` |
| `values` | Get dictionary of data | `values('id', 'title')` |
| `values_list` | Get tuple of data | `values_list('id', flat=True)` |

---

## The Implementation

### Step 1: Install Debug Toolbar for Profiling

```bash
cd backend
source venv/bin/activate
pip install django-debug-toolbar
echo "django-debug-toolbar>=4.3.0" >> requirements/development.txt
```

**backend/config/settings.py** (update for debug toolbar)

```python
# Add to INSTALLED_APPS only in development
if DEBUG:
    INSTALLED_APPS += ['debug_toolbar']

# Add to MIDDLEWARE only in development
if DEBUG:
    MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']

# Debug toolbar settings
INTERNAL_IPS = [
    '127.0.0.1',
    'localhost',
]

# Debug toolbar panels
DEBUG_TOOLBAR_PANELS = [
    'debug_toolbar.panels.versions.VersionsPanel',
    'debug_toolbar.panels.timer.TimerPanel',
    'debug_toolbar.panels.settings.SettingsPanel',
    'debug_toolbar.panels.headers.HeadersPanel',
    'debug_toolbar.panels.request.RequestPanel',
    'debug_toolbar.panels.sql.SQLPanel',
    'debug_toolbar.panels.staticfiles.StaticFilesPanel',
    'debug_toolbar.panels.templates.TemplatesPanel',
    'debug_toolbar.panels.cache.CachePanel',
    'debug_toolbar.panels.signals.SignalsPanel',
    'debug_toolbar.panels.logging.LoggingPanel',
    'debug_toolbar.panels.redirects.RedirectsPanel',
    'debug_toolbar.panels.profiling.ProfilingPanel',
]
```

### Step 2: Optimize Task Queries with select_related and prefetch_related

**backend/apps/tasks/views.py** (update get_queryset)

```python
from django.db import models

class TaskViewSet(viewsets.ModelViewSet):
    # ... other code ...
    
    def get_queryset(self):
        """
        Optimize queries with select_related and prefetch_related.
        """
        user = self.request.user
        
        # Base queryset with optimized joins
        queryset = Task.objects.select_related(
            'project',           # ForeignKey to Project
            'assigned_to',       # ForeignKey to User
            'created_by',        # ForeignKey to User
            'project__created_by',  # Nested ForeignKey
        ).prefetch_related(
            'comments',          # Reverse ForeignKey
            'comments__author',  # Nested ForeignKey
        )
        
        # Apply user filtering
        if user.is_admin:
            return queryset.all()
        
        return queryset.filter(
            models.Q(created_by=user) |
            models.Q(assigned_to=user) |
            models.Q(project__created_by=user)
        ).distinct()
```

### Step 3: Optimize Project Queries

**backend/apps/projects/views.py** (update get_queryset)

```python
from django.db import models

class ProjectViewSet(viewsets.ModelViewSet):
    # ... other code ...
    
    def get_queryset(self):
        """
        Optimize project queries with select_related.
        """
        user = self.request.user
        
        queryset = Project.objects.select_related(
            'created_by',  # ForeignKey to User
        ).prefetch_related(
            'tasks',       # Reverse ForeignKey to Task
            'tasks__assigned_to',  # Nested ForeignKey
        )
        
        if user.is_admin:
            return queryset.all()
        
        return queryset.filter(
            models.Q(created_by=user) |
            models.Q(tasks__assigned_to=user)
        ).distinct()
```

### Step 4: Add Database Indexes to Models

**backend/apps/tasks/models.py** (update with indexes)

```python
class Task(models.Model):
    # ... fields ...
    
    class Meta:
        db_table = 'tasks'
        verbose_name = _('task')
        verbose_name_plural = _('tasks')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['project', 'status']),
            models.Index(fields=['assigned_to', 'status']),
            models.Index(fields=['due_date']),
            models.Index(fields=['priority']),
            models.Index(fields=['created_at']),  # For sorting
            models.Index(fields=['status', 'created_at']),  # Common filter + sort
            models.Index(fields=['project', 'status', 'priority']),  # Composite
            models.Index(fields=['assigned_to', 'status', 'created_at']),
        ]
        # Remove unique_together if it's not needed or causing issues
        # unique_together = [['project', 'title']]  # Uncomment if needed
```

**backend/apps/projects/models.py** (update with indexes)

```python
class Project(models.Model):
    # ... fields ...
    
    class Meta:
        db_table = 'projects'
        verbose_name = _('project')
        verbose_name_plural = _('projects')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['created_by', 'created_at']),
            models.Index(fields=['name']),
            models.Index(fields=['created_at']),
        ]
```

**backend/apps/comments/models.py** (update with indexes)

```python
class Comment(models.Model):
    # ... fields ...
    
    class Meta:
        db_table = 'comments'
        verbose_name = _('comment')
        verbose_name_plural = _('comments')
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['task', 'created_at']),
            models.Index(fields=['author', 'created_at']),
            models.Index(fields=['created_at']),
        ]
```

**backend/apps/users/models.py** (update with indexes)

```python
class User(AbstractUser):
    # ... fields ...
    
    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email']),  # Used for authentication
            models.Index(fields=['role']),
            models.Index(fields=['created_at']),
        ]
```

### Step 5: Create Migrations for Indexes

```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

### Step 6: Optimize Serializer Performance

**backend/apps/tasks/serializers.py** (update)

```python
class TaskListSerializer(serializers.ModelSerializer):
    """
    Lightweight serializer for task lists (uses fewer fields).
    """
    project_name = serializers.CharField(source='project.name')
    assigned_to_username = serializers.CharField(source='assigned_to.username')
    status_display = serializers.CharField(source='get_status_display')
    priority_display = serializers.CharField(source='get_priority_display')
    
    class Meta:
        model = Task
        fields = [
            'id', 'title', 'status', 'status_display',
            'priority', 'priority_display', 'project_name',
            'assigned_to_username', 'due_date', 'created_at'
        ]


class TaskDetailSerializer(serializers.ModelSerializer):
    """
    Detailed serializer for individual task views.
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
```

**backend/apps/tasks/views.py** (use optimized serializers)

```python
class TaskViewSet(viewsets.ModelViewSet):
    # ... other code ...
    
    def get_serializer_class(self):
        """
        Use different serializers for different actions.
        List view uses lightweight serializer for performance.
        """
        if self.action == 'list':
            from .serializers import TaskListSerializer
            return TaskListSerializer
        elif self.action == 'retrieve':
            from .serializers import TaskDetailSerializer
            return TaskDetailSerializer
        elif self.action == 'create':
            return TaskCreateSerializer
        elif self.action in ['update', 'partial_update']:
            if self.action == 'partial_update' and 'status' in self.request.data:
                return TaskStatusUpdateSerializer
            return TaskUpdateSerializer
        elif self.action == 'status':
            return TaskStatusUpdateSerializer
        return TaskSerializer
```

### Step 7: Create Query Profiling Utility

**backend/apps/api/utils.py** (create)

```python
"""
Utility functions for performance profiling.
"""

import time
import logging
from functools import wraps
from django.db import connection
from django.conf import settings

logger = logging.getLogger('api')


def profile_queries(view_func):
    """
    Decorator to profile database queries.
    """
    @wraps(view_func)
    def wrapped_view(request, *args, **kwargs):
        if not settings.DEBUG:
            return view_func(request, *args, **kwargs)
        
        # Reset query count
        connection.queries_log.clear()
        
        # Execute view
        start_time = time.time()
        response = view_func(request, *args, **kwargs)
        duration = time.time() - start_time
        
        # Log query count and duration
        query_count = len(connection.queries)
        
        logger.info(
            f"View: {view_func.__name__}, "
            f"Queries: {query_count}, "
            f"Duration: {duration:.3f}s"
        )
        
        if query_count > 20:
            logger.warning(
                f"High query count: {query_count} queries in {view_func.__name__}"
            )
        
        return response
    return wrapped_view


def profile_method(method):
    """
    Decorator to profile individual methods.
    """
    @wraps(method)
    def wrapped_method(self, *args, **kwargs):
        start_time = time.time()
        result = method(self, *args, **kwargs)
        duration = time.time() - start_time
        
        if duration > 0.5:
            logger.warning(
                f"Slow method: {method.__name__} took {duration:.3f}s"
            )
        
        return result
    return wrapped_method
```

### Step 8: Add Query Count Middleware

**backend/apps/api/middleware.py** (add query count monitoring)

```python
import logging
from django.db import connection
from django.conf import settings

logger = logging.getLogger('api')


class QueryCountMiddleware:
    """
    Middleware to log database query count per request.
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        if not settings.DEBUG:
            return self.get_response(request)
        
        # Reset query count
        connection.queries_log.clear()
        
        response = self.get_response(request)
        
        # Log query count
        query_count = len(connection.queries)
        if query_count > 20:
            logger.warning(
                f"Request {request.path}: {query_count} queries"
            )
        
        return response
```

### Step 9: Update Settings for Logging

**backend/config/settings.py** (update logging)

```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': 'logs/api.log',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console', 'file'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'DEBUG' if DEBUG else 'INFO',
            'propagate': False,
        },
        'api': {
            'handlers': ['console', 'file'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}
```

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Test with Debug Toolbar

1. Open the application in your browser
2. Navigate to a page that makes API calls
3. Open the Debug Toolbar (right side of the page)
4. Check the SQL panel:
   - ✅ Should show query count
   - ✅ Should show query time
   - ✅ Should identify duplicate queries

### Step 3: Profile Task List Query

```bash
# Test the task list endpoint with profiling
curl -X GET "http://localhost:8000/api/v1/tasks/" \
  -H "Authorization: Bearer $TOKEN"

# Check the SQL panel to see query count
# Should be 1-2 queries instead of N+1
```

### Step 4: Test with Many Items

```python
# In Django shell, create many tasks
python manage.py shell

from apps.tasks.models import Task
from apps.projects.models import Project

project = Project.objects.first()
for i in range(100):
    Task.objects.create(
        title=f"Test Task {i}",
        project=project,
        created_by=project.created_by,
        assigned_to=project.created_by
    )

# Test the list endpoint
# With optimized queries, should still be fast
```

### Step 5: Check Index Usage

```bash
# In PostgreSQL, you can check index usage
psql -d taskflow_db -c "SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch FROM pg_stat_user_indexes ORDER BY idx_scan DESC;"
```

---

## Key Takeaways

1. **select_related** and **prefetch_related** prevent the N+1 query problem.

2. **Database indexes** dramatically improve query performance.

3. **Different serializers** for list and detail views reduce overhead.

4. **Lazy evaluation** means QuerySets only hit the database when needed.

5. **Debug Toolbar** is invaluable for identifying slow queries.

6. **Query profiling** helps monitor performance in development.

7. **Composite indexes** improve performance for common filter combinations.

---

## What's Next

In **Part 22**, we'll implement Redis caching:

- Setting up Redis
- Django cache framework
- View caching
- API response caching
- Cache invalidation

---

**End of Part 21**

*Next: Part 22 - Redis Caching*
