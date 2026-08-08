# Part 9: Advanced Querying

## Building a Powerful Search and Filter API

Welcome to **Part 9** of the Django REST Framework & Next.js 16 masterclass. Now that we've refactored our API to use ViewSets and Routers, it's time to add advanced querying capabilities. We'll build a search and filter system that allows clients to find exactly the data they need.

In this part, we'll:
- Implement advanced filtering with django-filter
- Add complex search across multiple fields
- Enable sorting and ordering
- Create date filters
- Build relationship-based filtering
- Expose all of this through our API

Think of this as adding **advanced search capabilities** to our API. Instead of just listing everything, users can now find exactly what they need by filtering, searching, and sorting the data.

---

## The Target

We'll enhance our API with:

```
GET /api/v1/tasks/?status=in_progress                  # Filter by status
GET /api/v1/tasks/?priority=high                       # Filter by priority
GET /api/v1/tasks/?search=api                         # Search in title/description
GET /api/v1/tasks/?ordering=-created_at               # Sort by newest first
GET /api/v1/tasks/?created_after=2026-01-01           # Date filtering
GET /api/v1/tasks/?assigned_to=42                     # Relationship filtering
GET /api/v1/tasks/?project_name__icontains=web        # Filter on related fields
GET /api/v1/tasks/?status=done&priority=high          # Multiple filters
```

---

## The Concept

### What is django-filter?

django-filter is a powerful library that provides an easy way to filter querysets based on user input. It integrates seamlessly with DRF and allows you to build complex filtering systems.

### Filtering Options

```python
from django_filters import rest_framework as filters

class TaskFilter(filters.FilterSet):
    # Exact match
    status = filters.CharFilter(field_name='status')
    
    # Contains (case-insensitive)
    title = filters.CharFilter(field_name='title', lookup_expr='icontains')
    
    # Greater than or equal to
    created_at = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    
    # Relationship filtering
    project_name = filters.CharFilter(field_name='project__name', lookup_expr='icontains')
    
    class Meta:
        model = Task
        fields = ['status', 'priority', 'project', 'assigned_to']
```

### Lookup Expressions

Django provides various lookup expressions:

| Lookup | Description | Example |
|--------|-------------|---------|
| `exact` | Exact match | `title__exact="Task"` |
| `iexact` | Case-insensitive exact | `title__iexact="task"` |
| `contains` | Contains | `title__contains="API"` |
| `icontains` | Case-insensitive contains | `title__icontains="api"` |
| `startswith` | Starts with | `title__startswith="API"` |
| `endswith` | Ends with | `title__endswith="project"` |
| `gt` | Greater than | `created_at__gt="2026-01-01"` |
| `gte` | Greater than or equal | `created_at__gte="2026-01-01"` |
| `lt` | Less than | `created_at__lt="2026-01-01"` |
| `lte` | Less than or equal | `created_at__lte="2026-01-01"` |
| `in` | In a list | `status__in=["todo", "in_progress"]` |
| `isnull` | Is null | `assigned_to__isnull=True` |

---

## The Implementation

### Step 1: Install django-filter

```bash
cd backend
source venv/bin/activate
pip install django-filter

# Add to requirements
echo "django-filter>=24.0.0" >> requirements/base.txt
```

### Step 2: Configure django-filter in Settings

**backend/config/settings.py** (ensure these settings)

```python
# In INSTALLED_APPS
INSTALLED_APPS = [
    # ...
    'django_filters',  # Add this
    # ...
]

# In REST_FRAMEWORK settings
REST_FRAMEWORK = {
    # ...
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    # ...
}

# Additional filter settings
FILTERS_DEFAULT_LOOKUP_EXPR = 'icontains'  # Default lookup for filters
```

### Step 3: Create Task Filter

**backend/apps/tasks/filters.py** (create this file)

```python
"""
Custom filters for the Task model.
"""

from django_filters import rest_framework as filters
from django_filters import FilterSet, CharFilter, DateTimeFilter, NumberFilter, BooleanFilter
from django.db.models import Q

from .models import Task


class TaskFilter(FilterSet):
    """
    Advanced filter set for Task model.
    Supports filtering by:
    - Exact fields (status, priority, project, assigned_to)
    - Text search (title, description)
    - Date ranges (created_at, due_date)
    - Relationships (project_name, assigned_to_username)
    - Boolean fields (is_overdue)
    - Custom methods (has_comments)
    """
    
    # Exact filters
    status = filters.ChoiceFilter(choices=Task.Status.choices)
    priority = filters.ChoiceFilter(choices=Task.Priority.choices)
    project = filters.NumberFilter(field_name='project__id')
    assigned_to = filters.NumberFilter(field_name='assigned_to__id')
    created_by = filters.NumberFilter(field_name='created_by__id')
    
    # Text search filters (case-insensitive contains)
    title = filters.CharFilter(field_name='title', lookup_expr='icontains')
    description = filters.CharFilter(field_name='description', lookup_expr='icontains')
    
    # Combined search (searches both title and description)
    search = filters.CharFilter(method='filter_search', label='Search')
    
    # Date filters
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    due_after = filters.DateTimeFilter(field_name='due_date', lookup_expr='gte')
    due_before = filters.DateTimeFilter(field_name='due_date', lookup_expr='lte')
    
    # Date exact match
    created_at = filters.DateTimeFilter(field_name='created_at')
    due_date = filters.DateTimeFilter(field_name='due_date')
    
    # Relationship filters (filter on related model fields)
    project_name = filters.CharFilter(field_name='project__name', lookup_expr='icontains')
    project_created_by = filters.NumberFilter(field_name='project__created_by__id')
    
    assigned_to_username = filters.CharFilter(
        field_name='assigned_to__username',
        lookup_expr='icontains'
    )
    created_by_username = filters.CharFilter(
        field_name='created_by__username',
        lookup_expr='icontains'
    )
    
    # Boolean filters
    is_overdue = filters.BooleanFilter(method='filter_is_overdue', label='Is Overdue')
    has_comments = filters.BooleanFilter(method='filter_has_comments', label='Has Comments')
    
    # Status count filter (at least N comments)
    comment_count_min = filters.NumberFilter(method='filter_comment_count_min', label='Min Comments')
    comment_count_max = filters.NumberFilter(method='filter_comment_count_max', label='Max Comments')
    
    class Meta:
        model = Task
        fields = [
            'status', 'priority', 'project', 'assigned_to', 'created_by',
            'title', 'description', 'search',
            'created_after', 'created_before', 'due_after', 'due_before',
            'created_at', 'due_date',
            'project_name', 'project_created_by',
            'assigned_to_username', 'created_by_username',
            'is_overdue', 'has_comments',
            'comment_count_min', 'comment_count_max',
        ]
    
    def filter_search(self, queryset, name, value):
        """
        Custom search that looks in title and description.
        """
        if value:
            return queryset.filter(
                Q(title__icontains=value) |
                Q(description__icontains=value)
            )
        return queryset
    
    def filter_is_overdue(self, queryset, name, value):
        """
        Filter tasks that are overdue (due date in past and not done).
        """
        from django.utils import timezone
        now = timezone.now()
        if value:
            return queryset.filter(
                due_date__lt=now,
                status__in=['todo', 'in_progress', 'review']
            )
        else:
            return queryset.exclude(
                due_date__lt=now,
                status__in=['todo', 'in_progress', 'review']
            )
    
    def filter_has_comments(self, queryset, name, value):
        """
        Filter tasks that have comments.
        """
        if value:
            return queryset.filter(comments__isnull=False).distinct()
        else:
            return queryset.filter(comments__isnull=True)
    
    def filter_comment_count_min(self, queryset, name, value):
        """
        Filter tasks with at least N comments.
        """
        from django.db.models import Count
        return queryset.annotate(
            comment_count=Count('comments')
        ).filter(comment_count__gte=value)
    
    def filter_comment_count_max(self, queryset, name, value):
        """
        Filter tasks with at most N comments.
        """
        from django.db.models import Count
        return queryset.annotate(
            comment_count=Count('comments')
        ).filter(comment_count__lte=value)
```

### Step 4: Create Project Filter

**backend/apps/projects/filters.py** (create this file)

```python
"""
Custom filters for the Project model.
"""

from django_filters import rest_framework as filters
from django_filters import FilterSet, CharFilter, NumberFilter, BooleanFilter
from django.db.models import Q

from .models import Project


class ProjectFilter(FilterSet):
    """
    Advanced filter set for Project model.
    """
    
    # Text search
    name = filters.CharFilter(field_name='name', lookup_expr='icontains')
    description = filters.CharFilter(field_name='description', lookup_expr='icontains')
    search = filters.CharFilter(method='filter_search', label='Search')
    
    # User filters
    created_by = filters.NumberFilter(field_name='created_by__id')
    created_by_username = filters.CharFilter(
        field_name='created_by__username',
        lookup_expr='icontains'
    )
    
    # Date filters
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    
    # Task count filters
    task_count_min = filters.NumberFilter(method='filter_task_count_min', label='Min Tasks')
    task_count_max = filters.NumberFilter(method='filter_task_count_max', label='Max Tasks')
    
    # Boolean filters
    has_tasks = filters.BooleanFilter(method='filter_has_tasks', label='Has Tasks')
    has_completed_tasks = filters.BooleanFilter(
        method='filter_has_completed_tasks',
        label='Has Completed Tasks'
    )
    
    class Meta:
        model = Project
        fields = [
            'name', 'description', 'search',
            'created_by', 'created_by_username',
            'created_after', 'created_before',
            'task_count_min', 'task_count_max',
            'has_tasks', 'has_completed_tasks',
        ]
    
    def filter_search(self, queryset, name, value):
        """
        Custom search that looks in name and description.
        """
        if value:
            return queryset.filter(
                Q(name__icontains=value) |
                Q(description__icontains=value)
            )
        return queryset
    
    def filter_task_count_min(self, queryset, name, value):
        """
        Filter projects with at least N tasks.
        """
        from django.db.models import Count
        return queryset.annotate(
            task_count=Count('tasks')
        ).filter(task_count__gte=value)
    
    def filter_task_count_max(self, queryset, name, value):
        """
        Filter projects with at most N tasks.
        """
        from django.db.models import Count
        return queryset.annotate(
            task_count=Count('tasks')
        ).filter(task_count__lte=value)
    
    def filter_has_tasks(self, queryset, name, value):
        """
        Filter projects that have tasks.
        """
        from django.db.models import Count
        if value:
            return queryset.annotate(
                task_count=Count('tasks')
            ).filter(task_count__gt=0)
        else:
            return queryset.annotate(
                task_count=Count('tasks')
            ).filter(task_count=0)
    
    def filter_has_completed_tasks(self, queryset, name, value):
        """
        Filter projects that have completed tasks.
        """
        from apps.tasks.models import Task
        if value:
            return queryset.filter(
                tasks__status=Task.Status.DONE
            ).distinct()
        else:
            return queryset.exclude(
                tasks__status=Task.Status.DONE
            ).distinct()
```

### Step 5: Create Comment Filter

**backend/apps/comments/filters.py** (create this file)

```python
"""
Custom filters for the Comment model.
"""

from django_filters import rest_framework as filters
from django_filters import FilterSet, CharFilter, NumberFilter, DateTimeFilter
from django.db.models import Q

from .models import Comment


class CommentFilter(FilterSet):
    """
    Advanced filter set for Comment model.
    """
    
    # Exact filters
    task = filters.NumberFilter(field_name='task__id')
    author = filters.NumberFilter(field_name='author__id')
    
    # Text search
    content = filters.CharFilter(field_name='content', lookup_expr='icontains')
    search = filters.CharFilter(method='filter_search', label='Search')
    
    # Date filters
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    
    # Relationship filters
    task_title = filters.CharFilter(field_name='task__title', lookup_expr='icontains')
    author_username = filters.CharFilter(
        field_name='author__username',
        lookup_expr='icontains'
    )
    author_email = filters.CharFilter(
        field_name='author__email',
        lookup_expr='icontains'
    )
    
    class Meta:
        model = Comment
        fields = [
            'task', 'author',
            'content', 'search',
            'created_after', 'created_before',
            'task_title', 'author_username', 'author_email',
        ]
    
    def filter_search(self, queryset, name, value):
        """
        Custom search that looks in content and task title.
        """
        if value:
            return queryset.filter(
                Q(content__icontains=value) |
                Q(task__title__icontains=value)
            )
        return queryset
```

### Step 6: Update ViewSets with Filters

**backend/apps/tasks/views.py** (update)

```python
"""
API views for Task management using ViewSets with advanced filtering.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Task
from .serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskUpdateSerializer,
    TaskStatusUpdateSerializer,
)
from .filters import TaskFilter


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Task CRUD operations with advanced filtering.
    
    Provides:
    - list: GET /tasks/ (with filtering, search, ordering)
    - create: POST /tasks/
    - retrieve: GET /tasks/{id}/
    - update: PUT /tasks/{id}/
    - partial_update: PATCH /tasks/{id}/
    - destroy: DELETE /tasks/{id}/
    - status: PATCH /tasks/{id}/status/
    - comments: GET /tasks/{id}/comments/
    - stats: GET /tasks/stats/
    """
    
    queryset = Task.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    # Filter backends
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    # Use our custom filter class
    filterset_class = TaskFilter
    
    # Search fields
    search_fields = ['title', 'description']
    
    # Ordering fields
    ordering_fields = [
        'created_at', 'updated_at', 'due_date',
        'priority', 'status', 'title'
    ]
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        """
        Return different serializers based on the action.
        """
        if self.action == 'create':
            return TaskCreateSerializer
        elif self.action in ['update', 'partial_update']:
            if self.action == 'partial_update' and 'status' in self.request.data:
                return TaskStatusUpdateSerializer
            return TaskUpdateSerializer
        elif self.action == 'status':
            return TaskStatusUpdateSerializer
        return TaskSerializer
    
    def perform_create(self, serializer):
        """
        Set the created_by field when creating a task.
        """
        from apps.users.models import User
        user = User.objects.first()  # Will be updated with auth
        serializer.save(created_by=user)
    
    @action(detail=True, methods=['patch'])
    def status(self, request, pk=None):
        """
        Update only the status of a task.
        """
        task = self.get_object()
        serializer = TaskStatusUpdateSerializer(task, data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_serializer = TaskSerializer(task)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    @action(detail=True, methods=['get'])
    def comments(self, request, pk=None):
        """
        Get all comments for a task.
        """
        task = self.get_object()
        comments = task.comments.all()
        
        # Apply comment filters
        from apps.comments.filters import CommentFilter
        from django_filters import rest_framework as drf_filters
        
        # Apply filters using the CommentFilter
        filter_set = CommentFilter(
            request.query_params,
            queryset=comments,
            request=request
        )
        if filter_set.is_valid():
            comments = filter_set.qs
        
        from apps.comments.serializers import CommentSerializer
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """
        Get task statistics.
        """
        # Apply filters to get accurate stats
        filtered_queryset = self.filter_queryset(self.get_queryset())
        
        stats = {
            'total': filtered_queryset.count(),
            'todo': filtered_queryset.filter(status='todo').count(),
            'in_progress': filtered_queryset.filter(status='in_progress').count(),
            'review': filtered_queryset.filter(status='review').count(),
            'done': filtered_queryset.filter(status='done').count(),
            'by_priority': {
                'low': filtered_queryset.filter(priority='low').count(),
                'medium': filtered_queryset.filter(priority='medium').count(),
                'high': filtered_queryset.filter(priority='high').count(),
                'urgent': filtered_queryset.filter(priority='urgent').count(),
            }
        }
        
        # Add overdue count if not filtered out
        from django.utils import timezone
        now = timezone.now()
        stats['overdue'] = filtered_queryset.filter(
            due_date__lt=now,
            status__in=['todo', 'in_progress', 'review']
        ).count()
        
        return Response(stats)
```

**backend/apps/projects/views.py** (update)

```python
"""
API views for Project management using ViewSets with advanced filtering.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Project
from .serializers import ProjectSerializer, ProjectCreateSerializer
from .filters import ProjectFilter
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer
from apps.tasks.filters import TaskFilter
from apps.tasks.models import Task


class ProjectViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Project CRUD operations with advanced filtering.
    
    Provides:
    - list: GET /projects/ (with filtering, search, ordering)
    - create: POST /projects/
    - retrieve: GET /projects/{id}/
    - update: PUT /projects/{id}/
    - partial_update: PATCH /projects/{id}/
    - destroy: DELETE /projects/{id}/
    - tasks: GET /projects/{id}/tasks/ (with filtering)
    - add_task: POST /projects/{id}/add_task/
    - stats: GET /projects/{id}/stats/
    """
    
    queryset = Project.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    # Filter backends
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    # Use our custom filter class
    filterset_class = ProjectFilter
    
    # Search fields
    search_fields = ['name', 'description']
    
    # Ordering fields
    ordering_fields = ['created_at', 'name', 'task_count']
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        """
        Return different serializers based on the action.
        """
        if self.action == 'create':
            return ProjectCreateSerializer
        return ProjectSerializer
    
    def perform_create(self, serializer):
        """
        Set the created_by field when creating a project.
        """
        from apps.users.models import User
        user = User.objects.first()  # Will be updated with auth
        serializer.save(created_by=user)
    
    @action(detail=True, methods=['get'])
    def tasks(self, request, pk=None):
        """
        Get all tasks for a project with filtering.
        """
        project = self.get_object()
        tasks = project.tasks.all()
        
        # Apply task filters
        filter_set = TaskFilter(
            request.query_params,
            queryset=tasks,
            request=request
        )
        if filter_set.is_valid():
            tasks = filter_set.qs
        
        # Apply ordering
        ordering = request.query_params.get('ordering', '-created_at')
        if ordering in TaskFilter.Meta.model._meta.ordering_fields:
            tasks = tasks.order_by(ordering)
        
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def add_task(self, request, pk=None):
        """
        Add a task to a project.
        """
        project = self.get_object()
        
        # Add project to the data
        data = request.data.copy()
        data['project'] = project.id
        
        serializer = TaskCreateSerializer(data=data)
        if serializer.is_valid():
            from apps.users.models import User
            user = User.objects.first()  # Will be updated with auth
            if not user:
                return Response(
                    {'detail': 'No user exists to create task.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            task = serializer.save(created_by=user)
            response_serializer = TaskSerializer(task)
            return Response(
                response_serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        """
        Get statistics for a project.
        """
        project = self.get_object()
        tasks = project.tasks.all()
        
        stats = {
            'total_tasks': tasks.count(),
            'completed': tasks.filter(status='done').count(),
            'in_progress': tasks.filter(status='in_progress').count(),
            'todo': tasks.filter(status='todo').count(),
            'review': tasks.filter(status='review').count(),
            'by_priority': {
                'low': tasks.filter(priority='low').count(),
                'medium': tasks.filter(priority='medium').count(),
                'high': tasks.filter(priority='high').count(),
                'urgent': tasks.filter(priority='urgent').count(),
            },
            'completion_rate': 0
        }
        
        if stats['total_tasks'] > 0:
            stats['completion_rate'] = round(
                (stats['completed'] / stats['total_tasks']) * 100,
                1
            )
        
        return Response(stats)
```

### Step 7: Update Comment ViewSet with Filters

**backend/apps/comments/views.py** (update)

```python
"""
API views for Comment management using ViewSets with advanced filtering.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Comment
from .serializers import CommentSerializer, CommentCreateSerializer, CommentUpdateSerializer
from .filters import CommentFilter


class CommentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Comment CRUD operations with advanced filtering.
    
    Provides:
    - list: GET /comments/ (with filtering, search, ordering)
    - create: POST /comments/
    - retrieve: GET /comments/{id}/
    - update: PUT /comments/{id}/
    - partial_update: PATCH /comments/{id}/
    - destroy: DELETE /comments/{id}/
    - by_task: GET /comments/by_task/?task_id=1
    """
    
    queryset = Comment.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    # Filter backends
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    # Use our custom filter class
    filterset_class = CommentFilter
    
    # Search fields
    search_fields = ['content', 'task__title']
    
    # Ordering fields
    ordering_fields = ['created_at', 'author__username']
    ordering = ['created_at']
    
    def get_serializer_class(self):
        """
        Return different serializers based on the action.
        """
        if self.action == 'create':
            return CommentCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return CommentUpdateSerializer
        return CommentSerializer
    
    def perform_create(self, serializer):
        """
        Set the author field when creating a comment.
        """
        from apps.users.models import User
        user = User.objects.first()  # Will be updated with auth
        serializer.save(author=user)
    
    @action(detail=False, methods=['get'])
    def by_task(self, request):
        """
        Get comments by task ID.
        """
        task_id = request.query_params.get('task_id')
        if not task_id:
            return Response(
                {'detail': 'task_id parameter is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        comments = self.get_queryset().filter(task_id=task_id)
        
        # Apply additional filters
        filter_set = CommentFilter(
            request.query_params,
            queryset=comments,
            request=request
        )
        if filter_set.is_valid():
            comments = filter_set.qs
        
        serializer = self.get_serializer(comments, many=True)
        return Response(serializer.data)
```

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Test Advanced Queries

#### Basic Filtering

```bash
# Filter by status
curl -X GET "http://localhost:8000/api/v1/tasks/?status=in_progress"

# Filter by priority
curl -X GET "http://localhost:8000/api/v1/tasks/?priority=high"

# Multiple filters
curl -X GET "http://localhost:8000/api/v1/tasks/?status=done&priority=high"

# Filter by project
curl -X GET "http://localhost:8000/api/v1/tasks/?project=1"
```

#### Search

```bash
# Search in title and description
curl -X GET "http://localhost:8000/api/v1/tasks/?search=api"

# Search with custom filter
curl -X GET "http://localhost:8000/api/v1/tasks/?title=build"

# Search in description
curl -X GET "http://localhost:8000/api/v1/tasks/?description=rest"
```

#### Ordering

```bash
# Order by newest first
curl -X GET "http://localhost:8000/api/v1/tasks/?ordering=-created_at"

# Order by priority (high to low)
curl -X GET "http://localhost:8000/api/v1/tasks/?ordering=-priority"

# Order by status
curl -X GET "http://localhost:8000/api/v1/tasks/?ordering=status"

# Combined ordering
curl -X GET "http://localhost:8000/api/v1/tasks/?ordering=-priority,created_at"
```

#### Date Filtering

```bash
# Tasks created after a date
curl -X GET "http://localhost:8000/api/v1/tasks/?created_after=2026-01-15T00:00:00Z"

# Tasks created before a date
curl -X GET "http://localhost:8000/api/v1/tasks/?created_before=2026-01-31T23:59:59Z"

# Tasks with due date in the future
curl -X GET "http://localhost:8000/api/v1/tasks/?due_after=2026-02-01T00:00:00Z"

# Tasks due this month
curl -X GET "http://localhost:8000/api/v1/tasks/?due_after=2026-02-01T00:00:00Z&due_before=2026-03-01T00:00:00Z"
```

#### Relationship Filtering

```bash
# Tasks in projects with a specific name
curl -X GET "http://localhost:8000/api/v1/tasks/?project_name=masterclass"

# Tasks assigned to a specific user
curl -X GET "http://localhost:8000/api/v1/tasks/?assigned_to_username=admin"

# Tasks created by a specific user
curl -X GET "http://localhost:8000/api/v1/tasks/?created_by_username=admin"
```

#### Boolean Filters

```bash
# Overdue tasks
curl -X GET "http://localhost:8000/api/v1/tasks/?is_overdue=True"

# Tasks with comments
curl -X GET "http://localhost:8000/api/v1/tasks/?has_comments=True"

# Tasks without comments
curl -X GET "http://localhost:8000/api/v1/tasks/?has_comments=False"
```

#### Count Filters

```bash
# Tasks with at least 2 comments
curl -X GET "http://localhost:8000/api/v1/tasks/?comment_count_min=2"

# Tasks with at most 5 comments
curl -X GET "http://localhost:8000/api/v1/tasks/?comment_count_max=5"

# Tasks with 1-5 comments
curl -X GET "http://localhost:8000/api/v1/tasks/?comment_count_min=1&comment_count_max=5"
```

#### Project Filters

```bash
# Projects with at least 3 tasks
curl -X GET "http://localhost:8000/api/v1/projects/?task_count_min=3"

# Projects with tasks
curl -X GET "http://localhost:8000/api/v1/projects/?has_tasks=True"

# Projects with completed tasks
curl -X GET "http://localhost:8000/api/v1/projects/?has_completed_tasks=True"

# Search projects
curl -X GET "http://localhost:8000/api/v1/projects/?search=api"
```

#### Combined Queries

```bash
# Complex query: high priority tasks in progress that are overdue
curl -X GET "http://localhost:8000/api/v1/tasks/?priority=urgent&status=in_progress&is_overdue=True"

# Complex query: tasks in a specific project, assigned to a user, with comments
curl -X GET "http://localhost:8000/api/v1/tasks/?project=1&assigned_to_username=admin&has_comments=True"

# Complex query: projects with tasks, created after a date, ordered by name
curl -X GET "http://localhost:8000/api/v1/projects/?has_tasks=True&created_after=2026-01-01T00:00:00Z&ordering=name"
```

### Step 3: Test in Browser

Open your browser and navigate to the browsable API:

- http://localhost:8000/api/v1/tasks/
- http://localhost:8000/api/v1/projects/
- http://localhost:8000/api/v1/comments/

You should see filter widgets in the browsable API UI.

### Step 4: Test Stats Endpoint with Filters

```bash
# Stats for all tasks
curl -X GET "http://localhost:8000/api/v1/tasks/stats/"

# Stats for filtered tasks
curl -X GET "http://localhost:8000/api/v1/tasks/stats/?priority=high"
curl -X GET "http://localhost:8000/api/v1/tasks/stats/?status=in_progress"
```

---

## Key Takeaways

1. **django-filter** provides a powerful, declarative way to add filtering to your API.

2. **Filter sets** can include custom methods for complex filtering logic.

3. **Lookup expressions** (`icontains`, `gte`, `lte`) provide flexible filtering options.

4. **Relationship filtering** allows filtering on related model fields.

5. **Search** can be implemented with custom filter methods or DRF's SearchFilter.

6. **Ordering** is built-in with DRF's OrderingFilter.

7. **Boolean filters** are useful for yes/no conditions (is_overdue, has_comments).

8. **Count filters** allow filtering based on related object counts.

9. **Filtering affects statistics** - stats endpoints should respect filters.

10. **The browsable API** automatically generates filter widgets.

---

## What's Next

In **Part 10**, we'll add pagination to our API. You'll learn:

- Different pagination strategies (page-based, limit-offset, cursor)
- Custom pagination classes
- Pagination metadata
- Frontend pagination controls
- Infinite scrolling patterns

---

**End of Part 9**

*Next: Part 10 - Pagination*
