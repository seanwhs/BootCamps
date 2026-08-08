# Part 8: Generic Views, ViewSets & Routers

## Scaling Your API with DRF Abstractions

Welcome to **Part 8** of the Django REST Framework & Next.js 16 masterclass. Now that we have a working API with function-based views, it's time to level up. In this part, we'll replace our repetitive CRUD views with DRF's powerful abstractions: Generic Views, ViewSets, and Routers.

Think of this as upgrading from **hand-crafted tools** to **power tools**. We're replacing repetitive code with elegant, reusable components that handle common patterns automatically while still allowing customization when needed.

---

## The Target

We'll refactor our API views to use:

```
backend/apps/
├── users/
│   ├── views.py          # Convert to ViewSets
│   └── urls.py           # Use DefaultRouter
├── projects/
│   ├── views.py          # Convert to ViewSets with custom actions
│   └── urls.py           # Use DefaultRouter
├── tasks/
│   ├── views.py          # Convert to ViewSets with custom actions
│   └── urls.py           # Use DefaultRouter
└── comments/
    ├── views.py          # Convert to ViewSets
    └── urls.py           # Use DefaultRouter
```

---

## The Concept

### The Evolution of DRF Views

DRF provides multiple levels of abstraction:

```
Function-Based Views (@api_view)
         ↓
Class-Based Views (APIView)
         ↓
Generic Views (ListCreateAPIView, etc.)
         ↓
ViewSets (ModelViewSet)
         ↓
Routers (DefaultRouter)
```

Each level reduces boilerplate code while maintaining flexibility.

### Generic Views

Generic views are pre-built class-based views for common patterns:

| Generic View | HTTP Methods | Description |
|--------------|--------------|-------------|
| `ListAPIView` | GET | List all resources |
| `CreateAPIView` | POST | Create a resource |
| `RetrieveAPIView` | GET | Get a single resource |
| `UpdateAPIView` | PUT/PATCH | Update a resource |
| `DestroyAPIView` | DELETE | Delete a resource |
| `ListCreateAPIView` | GET, POST | List and create |
| `RetrieveUpdateAPIView` | GET, PUT, PATCH | Retrieve and update |
| `RetrieveDestroyAPIView` | GET, DELETE | Retrieve and delete |
| `RetrieveUpdateDestroyAPIView` | GET, PUT, PATCH, DELETE | Full CRUD |

### ViewSets

ViewSets group related views into a single class:

```python
class TaskViewSet(viewsets.ModelViewSet):
    """
    A ViewSet that provides CRUD operations for tasks.
    Automatically handles:
    - GET /tasks/           -> list()
    - POST /tasks/          -> create()
    - GET /tasks/{id}/      -> retrieve()
    - PUT /tasks/{id}/      -> update()
    - PATCH /tasks/{id}/    -> partial_update()
    - DELETE /tasks/{id}/   -> destroy()
    """
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
```

### ViewSet Actions

ViewSets automatically map HTTP methods to actions:

| HTTP Method | URL | Action | Description |
|-------------|-----|--------|-------------|
| GET | `/tasks/` | `list()` | List all tasks |
| POST | `/tasks/` | `create()` | Create a task |
| GET | `/tasks/{id}/` | `retrieve()` | Get a task |
| PUT | `/tasks/{id}/` | `update()` | Full update |
| PATCH | `/tasks/{id}/` | `partial_update()` | Partial update |
| DELETE | `/tasks/{id}/` | `destroy()` | Delete a task |

### Custom Actions

Add custom actions with the `@action` decorator:

```python
from rest_framework.decorators import action

class TaskViewSet(viewsets.ModelViewSet):
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        task = self.get_object()
        task.status = 'done'
        task.save()
        return Response({'status': 'completed'})
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        # Returns /tasks/stats/
        stats = {
            'total': Task.objects.count(),
            'completed': Task.objects.filter(status='done').count()
        }
        return Response(stats)
```

### Routers

Routers automatically generate URL patterns for ViewSets:

```python
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'projects', ProjectViewSet, basename='project')

urlpatterns = router.urls
```

This automatically creates all CRUD URLs:

```
^tasks/$                    [name='task-list']
^tasks/{id}/$               [name='task-detail']
^tasks/{id}/complete/$      [name='task-complete']
^tasks/stats/$              [name='task-stats']
```

---

## The Implementation

### Step 1: Update Settings for DRF

**backend/config/settings.py** (ensure these settings are present)

```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        # We'll add JWT in Phase 3
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Will change in Phase 3
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',  # For testing
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
    ],
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_VERSIONING_CLASS': 'rest_framework.versioning.URLPathVersioning',
    'DEFAULT_VERSION': 'v1',
    'ALLOWED_VERSIONS': ['v1'],
    'VERSION_PARAM': 'version',
}
```

### Step 2: Create User ViewSet

**backend/apps/users/views.py** (replace with ViewSet)

```python
"""
API views for User management using ViewSets.
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import User
from .serializers import (
    UserSerializer,
    UserCreateSerializer,
    UserUpdateSerializer,
    UserProfileSerializer,
)


class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet for User CRUD operations.
    
    Provides:
    - list: GET /users/
    - create: POST /users/
    - retrieve: GET /users/{id}/
    - update: PUT /users/{id}/
    - partial_update: PATCH /users/{id}/
    - destroy: DELETE /users/{id}/
    - profile: GET /users/profile/
    """
    
    queryset = User.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    def get_serializer_class(self):
        """
        Return different serializers based on the action.
        """
        if self.action == 'create':
            return UserCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return UserUpdateSerializer
        elif self.action == 'profile':
            return UserProfileSerializer
        return UserSerializer
    
    def get_queryset(self):
        """
        Optionally filter by role.
        """
        queryset = super().get_queryset()
        role = self.request.query_params.get('role')
        if role:
            queryset = queryset.filter(role=role)
        return queryset
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """
        Get the current user's profile.
        Custom action at /users/profile/
        """
        # For now, return the first user
        # Will be updated with authentication in Phase 3
        user = self.queryset.first()
        if user:
            serializer = self.get_serializer(user)
            return Response(serializer.data)
        return Response(
            {'detail': 'No user found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    @action(detail=True, methods=['post'])
    def set_role(self, request, pk=None):
        """
        Set a user's role.
        Custom action at /users/{id}/set_role/
        """
        user = self.get_object()
        role = request.data.get('role')
        
        if not role:
            return Response(
                {'detail': 'Role is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if role not in dict(User.Roles.choices):
            return Response(
                {'detail': 'Invalid role.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user.role = role
        user.save()
        
        serializer = self.get_serializer(user)
        return Response(serializer.data)
```

**backend/apps/users/urls.py** (replace with router)

```python
"""
URL configuration for the users app using ViewSets and Router.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include

from . import views

# Create a router and register our ViewSet
router = DefaultRouter()
router.register(r'', views.UserViewSet, basename='user')

# The router will automatically generate these URLs:
# ^$                        [name='user-list']
# ^{pk}/$                   [name='user-detail']
# ^profile/$                [name='user-profile']
# ^{pk}/set_role/$          [name='user-set-role']

urlpatterns = [
    path('', include(router.urls)),
]
```

### Step 3: Create Project ViewSet

**backend/apps/projects/views.py** (replace with ViewSet)

```python
"""
API views for Project management using ViewSets.
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Project
from .serializers import ProjectSerializer, ProjectCreateSerializer
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer
from apps.tasks.models import Task


class ProjectViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Project CRUD operations.
    
    Provides:
    - list: GET /projects/
    - create: POST /projects/
    - retrieve: GET /projects/{id}/
    - update: PUT /projects/{id}/
    - partial_update: PATCH /projects/{id}/
    - destroy: DELETE /projects/{id}/
    - tasks: GET /projects/{id}/tasks/
    - add_task: POST /projects/{id}/add_task/
    """
    
    queryset = Project.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
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
        # For now, get the first user
        # Will be updated with authentication in Phase 3
        from apps.users.models import User
        user = User.objects.first()
        serializer.save(created_by=user)
    
    @action(detail=True, methods=['get'])
    def tasks(self, request, pk=None):
        """
        Get all tasks for a project.
        Custom action at /projects/{id}/tasks/
        """
        project = self.get_object()
        tasks = project.tasks.all()
        
        # Apply filters from query params
        status_filter = request.query_params.get('status')
        if status_filter:
            tasks = tasks.filter(status=status_filter)
        
        priority_filter = request.query_params.get('priority')
        if priority_filter:
            tasks = tasks.filter(priority=priority_filter)
        
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def add_task(self, request, pk=None):
        """
        Add a task to a project.
        Custom action at /projects/{id}/add_task/
        """
        project = self.get_object()
        
        # Add project to the data
        data = request.data.copy()
        data['project'] = project.id
        
        serializer = TaskCreateSerializer(data=data)
        if serializer.is_valid():
            # Set created_by to current user
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
        Custom action at /projects/{id}/stats/
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
            }
        }
        return Response(stats)
```

**backend/apps/projects/urls.py** (replace with router)

```python
"""
URL configuration for the projects app using ViewSets and Router.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include

from . import views

# Create a router and register our ViewSet
router = DefaultRouter()
router.register(r'', views.ProjectViewSet, basename='project')

# The router will automatically generate these URLs:
# ^$                        [name='project-list']
# ^{pk}/$                   [name='project-detail']
# ^{pk}/tasks/$             [name='project-tasks']
# ^{pk}/add_task/$          [name='project-add-task']
# ^{pk}/stats/$             [name='project-stats']

urlpatterns = [
    path('', include(router.urls)),
]
```

### Step 4: Create Task ViewSet

**backend/apps/tasks/views.py** (replace with ViewSet)

```python
"""
API views for Task management using ViewSets.
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


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Task CRUD operations.
    
    Provides:
    - list: GET /tasks/
    - create: POST /tasks/
    - retrieve: GET /tasks/{id}/
    - update: PUT /tasks/{id}/
    - partial_update: PATCH /tasks/{id}/
    - destroy: DELETE /tasks/{id}/
    - status: PATCH /tasks/{id}/status/
    - comments: GET /tasks/{id}/comments/
    """
    
    queryset = Task.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    # Add filtering, searching, and ordering
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'priority', 'project', 'assigned_to', 'created_by']
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'due_date', 'priority', 'status']
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
        Custom action at /tasks/{id}/status/
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
        Custom action at /tasks/{id}/comments/
        """
        task = self.get_object()
        comments = task.comments.all()
        from apps.comments.serializers import CommentSerializer
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """
        Get task statistics.
        Custom action at /tasks/stats/
        """
        tasks = self.get_queryset()
        
        stats = {
            'total': tasks.count(),
            'todo': tasks.filter(status='todo').count(),
            'in_progress': tasks.filter(status='in_progress').count(),
            'review': tasks.filter(status='review').count(),
            'done': tasks.filter(status='done').count(),
            'overdue': tasks.filter(due_date__lt='now', status__in=['todo', 'in_progress', 'review']).count(),
            'by_priority': {
                'low': tasks.filter(priority='low').count(),
                'medium': tasks.filter(priority='medium').count(),
                'high': tasks.filter(priority='high').count(),
                'urgent': tasks.filter(priority='urgent').count(),
            }
        }
        return Response(stats)
```

**backend/apps/tasks/urls.py** (replace with router)

```python
"""
URL configuration for the tasks app using ViewSets and Router.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include

from . import views

# Create a router and register our ViewSet
router = DefaultRouter()
router.register(r'', views.TaskViewSet, basename='task')

# The router will automatically generate these URLs:
# ^$                        [name='task-list']
# ^{pk}/$                   [name='task-detail']
# ^{pk}/status/$            [name='task-status']
# ^{pk}/comments/$          [name='task-comments']
# ^stats/$                  [name='task-stats']

urlpatterns = [
    path('', include(router.urls)),
]
```

### Step 5: Create Comment ViewSet

**backend/apps/comments/views.py** (replace with ViewSet)

```python
"""
API views for Comment management using ViewSets.
"""

from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Comment
from .serializers import CommentSerializer, CommentCreateSerializer, CommentUpdateSerializer


class CommentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Comment CRUD operations.
    
    Provides:
    - list: GET /comments/
    - create: POST /comments/
    - retrieve: GET /comments/{id}/
    - update: PUT /comments/{id}/
    - partial_update: PATCH /comments/{id}/
    - destroy: DELETE /comments/{id}/
    """
    
    queryset = Comment.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    # Add filtering
    filter_backends = [filters.OrderingFilter]
    ordering_fields = ['created_at']
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
    
    def get_queryset(self):
        """
        Optionally filter by task.
        """
        queryset = super().get_queryset()
        task_id = self.request.query_params.get('task')
        if task_id:
            queryset = queryset.filter(task_id=task_id)
        return queryset
    
    @action(detail=False, methods=['get'])
    def by_task(self, request):
        """
        Get comments by task ID.
        Custom action at /comments/by_task/?task_id=1
        """
        task_id = request.query_params.get('task_id')
        if not task_id:
            return Response(
                {'detail': 'task_id parameter is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        comments = self.get_queryset().filter(task_id=task_id)
        serializer = self.get_serializer(comments, many=True)
        return Response(serializer.data)
```

**backend/apps/comments/urls.py** (replace with router)

```python
"""
URL configuration for the comments app using ViewSets and Router.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include

from . import views

# Create a router and register our ViewSet
router = DefaultRouter()
router.register(r'', views.CommentViewSet, basename='comment')

# The router will automatically generate these URLs:
# ^$                        [name='comment-list']
# ^{pk}/$                   [name='comment-detail']
# ^by_task/$                [name='comment-by-task']

urlpatterns = [
    path('', include(router.urls)),
]
```

### Step 6: Update the API URLs

**backend/apps/api/urls.py** (update)

```python
"""
API v1 URL configuration using ViewSets and Routers.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include

# Import all ViewSets
from apps.users.views import UserViewSet
from apps.projects.views import ProjectViewSet
from apps.tasks.views import TaskViewSet
from apps.comments.views import CommentViewSet

# Create a root router
router = DefaultRouter()

# Register all ViewSets
router.register(r'users', UserViewSet, basename='user')
router.register(r'projects', ProjectViewSet, basename='project')
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'comments', CommentViewSet, basename='comment')

# The router will automatically generate all URLs:
# ^users/$                                [name='user-list']
# ^users/{pk}/$                           [name='user-detail']
# ^users/profile/$                        [name='user-profile']
# ^users/{pk}/set_role/$                  [name='user-set-role']
# ^projects/$                             [name='project-list']
# ^projects/{pk}/$                        [name='project-detail']
# ^projects/{pk}/tasks/$                  [name='project-tasks']
# ^projects/{pk}/add_task/$               [name='project-add-task']
# ^projects/{pk}/stats/$                  [name='project-stats']
# ^tasks/$                                [name='task-list']
# ^tasks/{pk}/$                           [name='task-detail']
# ^tasks/{pk}/status/$                    [name='task-status']
# ^tasks/{pk}/comments/$                  [name='task-comments']
# ^tasks/stats/$                          [name='task-stats']
# ^comments/$                             [name='comment-list']
# ^comments/{pk}/$                        [name='comment-detail']
# ^comments/by_task/$                     [name='comment-by-task']

urlpatterns = router.urls
```

### Step 7: Update Admin URLs (Optional)

**backend/config/urls.py** (verify)

```python
"""
URL configuration for the backend project.
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('apps.api.urls')),
    # Add browsable API root
    path('api-auth/', include('rest_framework.urls')),
]
```

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Explore the Browsable API

Open your browser and go to: http://localhost:8000/api/v1/

You should see the browsable API root with all endpoints:
- Users
- Projects
- Tasks
- Comments

### Step 3: Test All Endpoints

#### Users

```bash
# List users
curl -X GET http://localhost:8000/api/v1/users/

# Create user
curl -X POST http://localhost:8000/api/v1/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "first_name": "Test",
    "last_name": "User",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!"
  }'

# Get user profile
curl -X GET http://localhost:8000/api/v1/users/profile/

# Set user role
curl -X POST http://localhost:8000/api/v1/users/1/set_role/ \
  -H "Content-Type: application/json" \
  -d '{"role": "admin"}'
```

#### Projects

```bash
# List projects
curl -X GET http://localhost:8000/api/v1/projects/

# Create project
curl -X POST http://localhost:8000/api/v1/projects/ \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Project", "description": "Test description"}'

# Get project tasks
curl -X GET http://localhost:8000/api/v1/projects/1/tasks/

# Get project stats
curl -X GET http://localhost:8000/api/v1/projects/1/stats/

# Add task to project
curl -X POST http://localhost:8000/api/v1/projects/1/add_task/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "priority": "high"
  }'
```

#### Tasks

```bash
# List tasks with filters
curl -X GET http://localhost:8000/api/v1/tasks/?status=todo
curl -X GET http://localhost:8000/api/v1/tasks/?search=api
curl -X GET http://localhost:8000/api/v1/tasks/?ordering=-priority

# Create task
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "Test description",
    "project": 1,
    "status": "todo",
    "priority": "high"
  }'

# Update task status
curl -X PATCH http://localhost:8000/api/v1/tasks/1/status/ \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'

# Get task comments
curl -X GET http://localhost:8000/api/v1/tasks/1/comments/

# Get task stats
curl -X GET http://localhost:8000/api/v1/tasks/stats/
```

#### Comments

```bash
# List comments
curl -X GET http://localhost:8000/api/v1/comments/

# Create comment
curl -X POST http://localhost:8000/api/v1/comments/ \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Test comment",
    "task": 1
  }'

# Get comments by task
curl -X GET http://localhost:8000/api/v1/comments/by_task/?task_id=1
```

### Step 4: Compare with Previous Implementation

Notice how much less code we have:
- **Before:** 5 files with ~300 lines of view code
- **After:** 5 files with ~200 lines of view code

And we gained:
- Filtering
- Searching
- Ordering
- Automatic URL generation
- Consistent API patterns
- Built-in documentation (browsable API)

### Step 5: Update Frontend API Endpoints

The frontend API client should work with the new URLs since they follow the same patterns. However, note the new URLs:

| Old URL | New URL |
|---------|---------|
| `/projects/1/tasks/` | `/projects/1/tasks/` (same) |
| `/tasks/1/status/` | `/tasks/1/status/` (same) |
| `/tasks/1/comments/` | `/tasks/1/comments/` (same) |
| `/tasks/stats/` | `/tasks/stats/` (new) |
| `/projects/1/stats/` | `/projects/1/stats/` (new) |

The frontend API endpoints file should be updated to include the new stats endpoints:

**frontend/lib/api/endpoints.ts** (update)

```typescript
export const ENDPOINTS = {
  users: {
    list: '/users/',
    detail: (id: number) => `/users/${id}/`,
    profile: '/users/profile/',
    setRole: (id: number) => `/users/${id}/set_role/`,
  },
  projects: {
    list: '/projects/',
    detail: (id: number) => `/projects/${id}/`,
    tasks: (id: number) => `/projects/${id}/tasks/`,
    addTask: (id: number) => `/projects/${id}/add_task/`,
    stats: (id: number) => `/projects/${id}/stats/`,
  },
  tasks: {
    list: '/tasks/',
    detail: (id: number) => `/tasks/${id}/`,
    status: (id: number) => `/tasks/${id}/status/`,
    comments: (id: number) => `/tasks/${id}/comments/`,
    stats: '/tasks/stats/',
  },
  comments: {
    list: '/comments/',
    detail: (id: number) => `/comments/${id}/`,
    byTask: '/comments/by_task/',
  },
};
```

---

## Key Takeaways

1. **Generic Views and ViewSets** dramatically reduce boilerplate code.

2. **Routers** automatically generate URL patterns, ensuring consistency.

3. **Custom actions** with `@action` allow you to add non-CRUD operations.

4. **Filtering, searching, and ordering** are built-in with DRF's filter backends.

5. **The browsable API** is a powerful tool for testing and documentation.

6. **ViewSets** make it easy to maintain a consistent API interface.

7. **Different serializers** can be used for different actions (create, update, list).

8. **The abstraction levels** (APIView → Generic Views → ViewSets) let you choose the right tool for the job.

---

## When to Use What

| Pattern | Best For | Example |
|---------|----------|---------|
| `@api_view` | Simple endpoints, one-off actions | Health check, stats endpoint |
| `APIView` | Custom logic, non-standard operations | Complex calculations, integrations |
| `Generic Views` | Standard CRUD with custom behavior | Projects with custom permissions |
| `ViewSets` | Full CRUD with consistent interface | Most resources (users, tasks, comments) |
| `ModelViewSet` | Complete CRUD with minimal code | Simple resources with no customization |

---

## Next Steps

With our API now using ViewSets and Routers, we've significantly improved our codebase. In **Part 9**, we'll add advanced querying capabilities:

- Advanced filtering with django-filter
- Complex search queries
- Sorting and ordering
- Date filters
- Relationship filtering

---

**End of Part 8**

*Next: Part 9 - Advanced Querying*
