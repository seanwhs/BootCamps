# Part 16: DRF Permissions

## Building a Robust Authorization System

Welcome to **Part 16** of the Django REST Framework & Next.js 16 masterclass. Now that we have authentication in place, it's time to implement authorization. We'll build a comprehensive permission system that controls what users can do based on their roles and ownership of resources.

In this part, we'll:
- Understand DRF's permission system
- Implement custom permission classes
- Build object-level permissions
- Implement role-based access control (RBAC)
- Protect resources based on ownership

Think of permissions as the **security policies** of your application. Just as a company has different access levels (employees, managers, executives), your API needs to enforce who can access what.

---

## The Target

We'll implement a complete permission system:

```
Permission Hierarchy:
┌─────────────────────────────────────────────────────────────┐
│                     Permission Classes                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │   IsAuthenticated│  │  IsAdminUser   │                   │
│  │   (Base)        │  │  (Superuser)   │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Custom Permissions                     │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │  - IsProjectOwner                                  │    │
│  │  - IsTaskAssignee                                  │    │
│  │  - IsCommentAuthor                                 │    │
│  │  - HasProjectAccess                                │    │
│  │  - IsManagerOrHigher                               │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## The Concept

### DRF Permission System

DRF uses a simple but powerful permission system:

```python
class Permission:
    def has_permission(self, request, view):
        # Check at the view level
        return True or False
    
    def has_object_permission(self, request, view, obj):
        # Check at the object level
        return True or False
```

### Permission Checks Flow

```
1. Request arrives at view
   ↓
2. `has_permission` called
   - Checks if user is authenticated
   - Checks role-based permissions
   ↓
3. If `has_permission` returns True
   ↓
4. `has_object_permission` called
   - Checks if user can access specific object
   - Checks ownership
   ↓
5. If both return True → Access granted
```

### Permission Types

| Type | When Checked | Purpose |
|------|--------------|---------|
| **Global** | Every request | Authentication, roles |
| **Object** | For specific objects | Ownership, project membership |
| **Custom** | Both levels | Complex business rules |

---

## The Implementation

### Step 1: Create Custom Permission Classes

**backend/apps/api/permissions.py** (create)

```python
"""
Custom permission classes for the API.
"""

from rest_framework import permissions
from apps.users.models import User


class IsAuthenticated(permissions.IsAuthenticated):
    """
    Standard authentication check.
    """
    pass


class IsAdminUser(permissions.IsAdminUser):
    """
    Allows access only to admin users.
    """
    pass


class IsManagerOrHigher(permissions.BasePermission):
    """
    Allows access only to users with manager role or higher.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        return request.user.role in [User.Roles.ADMIN, User.Roles.MANAGER]


class IsProjectOwner(permissions.BasePermission):
    """
    Allows access only to the user who created the project.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Project instance
        return obj.created_by == request.user


class IsProjectMember(permissions.BasePermission):
    """
    Allows access if user is a member of the project.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Project instance
        # Check if user is the project owner or has tasks in the project
        if obj.created_by == request.user:
            return True
        return obj.tasks.filter(assigned_to=request.user).exists()


class HasProjectAccess(permissions.BasePermission):
    """
    Allows access if user has access to the project.
    Admin users have access to all projects.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Project instance
        return request.user.has_project_access(obj)


class IsTaskAssignee(permissions.BasePermission):
    """
    Allows access only to the user assigned to the task.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Task instance
        return obj.assigned_to == request.user


class IsTaskCreator(permissions.BasePermission):
    """
    Allows access only to the user who created the task.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Task instance
        return obj.created_by == request.user


class HasTaskAccess(permissions.BasePermission):
    """
    Allows access if user has access to the task.
    Admin users have access to all tasks.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Task instance
        return request.user.has_task_access(obj)


class IsCommentAuthor(permissions.BasePermission):
    """
    Allows access only to the user who wrote the comment.
    """
    def has_object_permission(self, request, view, obj):
        # obj is a Comment instance
        return obj.author == request.user


class CanManageUsers(permissions.BasePermission):
    """
    Allows access only to users who can manage other users.
    """
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Admin can manage all users
        if request.user.role == User.Roles.ADMIN:
            return True
        
        # Manager can manage users but not admins
        if request.user.role == User.Roles.MANAGER:
            # For user list, managers can see all users
            if view.action == 'list':
                return True
            # For specific user operations, check the target user
            return True
        
        return False
    
    def has_object_permission(self, request, view, obj):
        # obj is a User instance
        
        # Admin can manage all users
        if request.user.role == User.Roles.ADMIN:
            return True
        
        # Manager can manage non-admin users
        if request.user.role == User.Roles.MANAGER:
            return obj.role != User.Roles.ADMIN
        
        return False


class IsSafeMethod(permissions.BasePermission):
    """
    Allows read-only access (GET, HEAD, OPTIONS) to all users.
    """
    def has_permission(self, request, view):
        return request.method in permissions.SAFE_METHODS


class ReadOnlyOrAuthenticated(permissions.BasePermission):
    """
    Allows read-only access to all users, write access only to authenticated users.
    """
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True
        return request.user and request.user.is_authenticated


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Allows read-only access to all users, write access only to the object owner.
    """
    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed to any request
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions are only allowed to the owner
        # We need to check if obj has a 'created_by' or 'author' field
        if hasattr(obj, 'created_by'):
            return obj.created_by == request.user
        elif hasattr(obj, 'author'):
            return obj.author == request.user
        
        return False
```

### Step 2: Update User ViewSet with Permissions

**backend/apps/users/views.py** (update)

```python
"""
API views for User management using ViewSets with permissions.
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User
from .serializers import (
    UserSerializer,
    UserCreateSerializer,
    UserUpdateSerializer,
    UserProfileSerializer,
)
from apps.api.permissions import (
    CanManageUsers,
    IsAdminUser,
    IsManagerOrHigher,
)


class UserViewSet(viewsets.ModelViewSet):
    """
    ViewSet for User CRUD operations with permissions.
    
    Provides:
    - list: GET /users/ (requires authentication)
    - create: POST /users/ (requires authentication)
    - retrieve: GET /users/{id}/ (requires authentication)
    - update: PUT /users/{id}/ (requires manage permission)
    - partial_update: PATCH /users/{id}/ (requires manage permission)
    - destroy: DELETE /users/{id}/ (requires manage permission)
    - profile: GET /users/profile/ (requires authentication)
    - set_role: POST /users/{id}/set_role/ (requires manage permission)
    - register: POST /users/register/ (public)
    """
    
    queryset = User.objects.all()
    
    def get_permissions(self):
        """
        Set permissions for each action.
        """
        if self.action == 'register':
            return [AllowAny()]
        elif self.action in ['list', 'profile']:
            return [IsAuthenticated()]
        elif self.action in ['update', 'partial_update', 'destroy', 'set_role']:
            return [IsAuthenticated(), CanManageUsers()]
        return [IsAuthenticated()]
    
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
        elif self.action == 'register':
            return UserCreateSerializer
        return UserSerializer
    
    def get_queryset(self):
        """
        Filter users based on user role.
        """
        user = self.request.user
        queryset = super().get_queryset()
        
        # Admin sees all users
        if user.role == User.Roles.ADMIN:
            return queryset
        
        # Manager sees all users except admins
        if user.role == User.Roles.MANAGER:
            return queryset.exclude(role=User.Roles.ADMIN)
        
        # Regular users only see themselves
        return queryset.filter(id=user.id)
    
    def perform_create(self, serializer):
        """
        Set the created_by field when creating a user.
        """
        user = serializer.save()
        return user
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def register(self, request):
        """
        Register a new user.
        """
        serializer = UserCreateSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            
            # Generate tokens
            refresh = RefreshToken.for_user(user)
            
            return Response({
                'user': UserSerializer(user).data,
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    @action(detail=False, methods=['get'])
    def profile(self, request):
        """
        Get the current user's profile.
        """
        user = request.user
        serializer = UserProfileSerializer(user)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def set_role(self, request, pk=None):
        """
        Set a user's role.
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
        
        # Check if user can set this role
        current_user = request.user
        if current_user.role == User.Roles.MANAGER and role == User.Roles.ADMIN:
            return Response(
                {'detail': 'Managers cannot set admin role.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        user.role = role
        user.save()
        
        serializer = self.get_serializer(user)
        return Response(serializer.data)
```

### Step 3: Update Project ViewSet with Permissions

**backend/apps/projects/views.py** (update with permissions)

```python
"""
API views for Project management using ViewSets with permissions.
"""

from django.db import models
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Project
from .serializers import ProjectSerializer, ProjectCreateSerializer
from .filters import ProjectFilter
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer
from apps.tasks.filters import TaskFilter
from apps.tasks.models import Task
from apps.api.permissions import (
    HasProjectAccess,
    IsProjectOwner,
    IsProjectMember,
    IsManagerOrHigher,
)


class ProjectViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Project CRUD operations with permissions.
    
    Provides:
    - list: GET /projects/
    - create: POST /projects/
    - retrieve: GET /projects/{id}/
    - update: PUT /projects/{id}/ (requires project access)
    - partial_update: PATCH /projects/{id}/ (requires project access)
    - destroy: DELETE /projects/{id}/ (requires project owner)
    - tasks: GET /projects/{id}/tasks/
    - add_task: POST /projects/{id}/add_task/ (requires project access)
    - stats: GET /projects/{id}/stats/
    """
    
    queryset = Project.objects.all()
    permission_classes = [IsAuthenticated]
    
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    filterset_class = ProjectFilter
    search_fields = ['name', 'description']
    ordering_fields = ['created_at', 'name', 'task_count']
    ordering = ['-created_at']
    
    def get_permissions(self):
        """
        Set permissions for each action.
        """
        if self.action == 'create':
            return [IsAuthenticated()]
        elif self.action in ['update', 'partial_update', 'add_task']:
            return [IsAuthenticated(), HasProjectAccess()]
        elif self.action == 'destroy':
            return [IsAuthenticated(), IsProjectOwner()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        """
        Filter projects based on user access.
        """
        user = self.request.user
        if user.is_admin:
            return Project.objects.all()
        # Users can see projects they created or have tasks in
        return Project.objects.filter(
            models.Q(created_by=user) | 
            models.Q(tasks__assigned_to=user)
        ).distinct()
    
    def get_serializer_class(self):
        if self.action == 'create':
            return ProjectCreateSerializer
        return ProjectSerializer
    
    def perform_create(self, serializer):
        """
        Set the created_by field to the current user.
        """
        serializer.save(created_by=self.request.user)
    
    @action(detail=True, methods=['get'])
    def tasks(self, request, pk=None):
        """
        Get all tasks for a project.
        """
        project = self.get_object()
        
        # Check permission
        if not request.user.has_project_access(project):
            return Response(
                {'detail': 'You do not have access to this project.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
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
        
        # Check permission (already checked by permission class)
        if not request.user.has_project_access(project):
            return Response(
                {'detail': 'You do not have access to this project.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Add project to the data
        data = request.data.copy()
        data['project'] = project.id
        
        serializer = TaskCreateSerializer(data=data)
        if serializer.is_valid():
            task = serializer.save(created_by=request.user)
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
        
        # Check permission
        if not request.user.has_project_access(project):
            return Response(
                {'detail': 'You do not have access to this project.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
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

### Step 4: Update Task ViewSet with Permissions

**backend/apps/tasks/views.py** (update with permissions)

```python
"""
API views for Task management using ViewSets with permissions.
"""

from django.db import models
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Task
from .serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskUpdateSerializer,
    TaskStatusUpdateSerializer,
)
from .filters import TaskFilter
from apps.api.permissions import (
    HasTaskAccess,
    IsTaskAssignee,
    IsTaskCreator,
)


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Task CRUD operations with permissions.
    
    Provides:
    - list: GET /tasks/
    - create: POST /tasks/
    - retrieve: GET /tasks/{id}/
    - update: PUT /tasks/{id}/ (requires task access)
    - partial_update: PATCH /tasks/{id}/ (requires task access)
    - destroy: DELETE /tasks/{id}/ (requires task creator)
    - status: PATCH /tasks/{id}/status/ (requires task access)
    - comments: GET /tasks/{id}/comments/ (requires task access)
    - stats: GET /tasks/stats/
    """
    
    queryset = Task.objects.all()
    permission_classes = [IsAuthenticated]
    
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    filterset_class = TaskFilter
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'updated_at', 'due_date', 'priority', 'status', 'title']
    ordering = ['-created_at']
    
    def get_permissions(self):
        """
        Set permissions for each action.
        """
        if self.action == 'create':
            return [IsAuthenticated()]
        elif self.action in ['retrieve', 'update', 'partial_update', 'status', 'comments']:
            return [IsAuthenticated(), HasTaskAccess()]
        elif self.action == 'destroy':
            return [IsAuthenticated(), IsTaskCreator()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        """
        Filter tasks based on user access.
        """
        user = self.request.user
        if user.is_admin:
            return Task.objects.all()
        # Users can see tasks they created, are assigned to, or are in projects they created
        return Task.objects.filter(
            models.Q(created_by=user) |
            models.Q(assigned_to=user) |
            models.Q(project__created_by=user)
        ).distinct()
    
    def get_serializer_class(self):
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
        Set the created_by field to the current user.
        """
        serializer.save(created_by=self.request.user)
    
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
        
        from apps.comments.filters import CommentFilter
        filter_set = CommentFilter(
            request.query_params,
            queryset=comments,
            request=request
        )
        if filter_set.is_valid():
            comments = filter_set.qs
        
        from rest_framework.pagination import PageNumberPagination
        paginator = PageNumberPagination()
        paginator.page_size = 10
        
        page = paginator.paginate_queryset(comments, request)
        
        from apps.comments.serializers import CommentSerializer
        serializer = CommentSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """
        Get task statistics.
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

### Step 5: Update Comment ViewSet with Permissions

**backend/apps/comments/views.py** (update with permissions)

```python
"""
API views for Comment management using ViewSets with permissions.
"""

from django.db import models
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Comment
from .serializers import CommentSerializer, CommentCreateSerializer, CommentUpdateSerializer
from .filters import CommentFilter
from apps.api.permissions import IsCommentAuthor


class CommentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Comment CRUD operations with permissions.
    
    Provides:
    - list: GET /comments/
    - create: POST /comments/
    - retrieve: GET /comments/{id}/
    - update: PUT /comments/{id}/ (requires comment author)
    - partial_update: PATCH /comments/{id}/ (requires comment author)
    - destroy: DELETE /comments/{id}/ (requires comment author)
    - by_task: GET /comments/by_task/?task_id=1
    """
    
    queryset = Comment.objects.all()
    permission_classes = [IsAuthenticated]
    
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    filterset_class = CommentFilter
    search_fields = ['content', 'task__title']
    ordering_fields = ['created_at', 'author__username']
    ordering = ['created_at']
    
    def get_permissions(self):
        """
        Set permissions for each action.
        """
        if self.action == 'create':
            return [IsAuthenticated()]
        elif self.action in ['update', 'partial_update', 'destroy']:
            return [IsAuthenticated(), IsCommentAuthor()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        """
        Filter comments based on user access.
        """
        user = self.request.user
        if user.is_admin:
            return Comment.objects.all()
        # Users can see comments on tasks they have access to
        return Comment.objects.filter(
            models.Q(task__created_by=user) |
            models.Q(task__assigned_to=user) |
            models.Q(task__project__created_by=user) |
            models.Q(author=user)
        ).distinct()
    
    def get_serializer_class(self):
        if self.action == 'create':
            return CommentCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return CommentUpdateSerializer
        return CommentSerializer
    
    def perform_create(self, serializer):
        """
        Set the author field to the current user.
        """
        serializer.save(author=self.request.user)
    
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

### Step 2: Test Permission Classes

```bash
# Get access token
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/token/ \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "admin123"}' \
  | jq -r '.access')

# Test user list (requires authentication)
curl -X GET http://localhost:8000/api/v1/users/ \
  -H "Authorization: Bearer $TOKEN"

# Test project creation (requires authentication)
curl -X POST http://localhost:8000/api/v1/projects/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Project"}'

# Test access to a project you don't own (should be denied)
# Get a project created by another user
curl -X GET http://localhost:8000/api/v1/projects/2/ \
  -H "Authorization: Bearer $TOKEN"

# Try to delete a project you don't own (should be denied)
curl -X DELETE http://localhost:8000/api/v1/projects/2/ \
  -H "Authorization: Bearer $TOKEN"

# Try to set a user's role (requires manage permission)
curl -X POST http://localhost:8000/api/v1/users/2/set_role/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "manager"}'
```

### Step 3: Test Object-Level Permissions

```bash
# Create a task as a user
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "My Task", "project": 1, "status": "todo", "priority": "medium"}'

# Try to update another user's task (should be denied)
curl -X PATCH http://localhost:8000/api/v1/tasks/2/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'

# Create a comment as a user
curl -X POST http://localhost:8000/api/v1/comments/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Test comment", "task": 1}'

# Try to update another user's comment (should be denied)
curl -X PATCH http://localhost:8000/api/v1/comments/2/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Updated comment"}'
```

---

## Key Takeaways

1. **Permission classes** enforce authorization at the view and object levels.

2. **`has_permission`** checks are done at the view level.

3. **`has_object_permission`** checks are done at the object level.

4. **Custom permissions** can implement complex business rules.

5. **Role-based access** can be implemented through permission classes.

6. **Ownership-based access** ensures users can only modify their own resources.

7. **Object-level filtering** in `get_queryset()` provides efficient filtering.

---

## What's Next

In **Part 17**, we'll implement role-based access control (RBAC):

- User roles and their capabilities
- Group-based permissions
- Role-based UI rendering

---

**End of Part 16**

*Next: Part 17 - Role-Based Access Control*
