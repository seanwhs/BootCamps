# Part 14: Authentication Architecture

## Building a Secure Foundation

Welcome to **Part 14** of the Django REST Framework & Next.js 16 masterclass. This is the beginning of Phase 3, where we'll add authentication and authorization to our application. In this part, we'll understand the architecture of authentication systems and set up JWT (JSON Web Token) authentication with Django REST Framework.

In this part, we'll:
- Understand authentication vs authorization
- Learn about JWT architecture
- Install and configure SimpleJWT
- Create authentication endpoints
- Test the authentication flow

Think of authentication as the **security checkpoint** for your application. Just as a building has security guards checking IDs at the entrance, your API needs to verify who is making requests before allowing access to protected resources.

---

## The Target

We'll set up a complete authentication system:

```
Authentication Flow:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Login     │───▶│   JWT       │───▶│   Access    │───▶│   Protected │
│  Request    │    │ Generation  │    │   Token     │    │   Resource  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │
                          ▼
                    ┌─────────────┐
                    │   Refresh   │
                    │   Token     │
                    └─────────────┘

API Endpoints:
POST /api/v1/token/                 # Obtain JWT token pair
POST /api/v1/token/refresh/         # Refresh access token
POST /api/v1/token/verify/          # Verify token validity
POST /api/v1/users/register/        # User registration
```

---

## The Concept

### Authentication vs Authorization

**Authentication** = Who you are
- Verifying identity
- "Are you who you say you are?"
- Login, passwords, biometrics, etc.

**Authorization** = What you can do
- Verifying permissions
- "Are you allowed to do this?"
- Roles, permissions, ownership, etc.

### JWT Architecture

JWT (JSON Web Token) is a compact, URL-safe token format:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

A JWT consists of three parts:
1. **Header**: Algorithm and token type
2. **Payload**: Claims (user data, expiration, etc.)
3. **Signature**: Verifies the token hasn't been tampered with

### Token Types

**Access Token**:
- Short-lived (5-15 minutes)
- Contains user claims
- Used for API authorization

**Refresh Token**:
- Long-lived (days/weeks)
- Used to get new access tokens
- Can be revoked (blacklisted)

### The Token Lifecycle

```
1. User logs in
   ↓
2. Server validates credentials
   ↓
3. Server generates access + refresh tokens
   ↓
4. Client stores tokens securely
   ↓
5. Client sends access token with API requests
   ↓
6. Server validates token before processing
   ↓
7. Token expires → Client uses refresh token
   ↓
8. Server issues new access token
```

---

## The Implementation

### Step 1: Install Required Packages

```bash
cd backend
source venv/bin/activate

# Install SimpleJWT
pip install djangorestframework-simplejwt

# Install CORS headers (if not already installed)
pip install django-cors-headers

# Add to requirements
echo "djangorestframework-simplejwt>=5.3.0" >> requirements/base.txt
echo "django-cors-headers>=4.3.0" >> requirements/base.txt
```

### Step 2: Update Settings

**backend/config/settings.py** (update)

```python
# In INSTALLED_APPS
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third-party apps
    'rest_framework',
    'corsheaders',
    'django_filters',
    'django_redis',
    
    # Local apps
    'apps.users',
    'apps.projects',
    'apps.tasks',
    'apps.comments',
]

# In MIDDLEWARE
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',  # CORS middleware should be high
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# CORS settings
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # Next.js development
    "http://127.0.0.1:3000",
]

CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]

# Django REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',  # Default: require authentication
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
    ],
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_PAGINATION_CLASS': 'apps.api.pagination.CustomPageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_VERSIONING_CLASS': 'rest_framework.versioning.URLPathVersioning',
    'DEFAULT_VERSION': 'v1',
    'ALLOWED_VERSIONS': ['v1'],
    'VERSION_PARAM': 'version',
}

# JWT Settings
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'VERIFYING_KEY': None,
    'AUDIENCE': None,
    'ISSUER': None,
    'JWK_URL': None,
    'LEEWAY': 0,
    
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'USER_AUTHENTICATION_RULE': 'rest_framework_simplejwt.authentication.default_user_authentication_rule',
    
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
    'TOKEN_USER_CLASS': 'rest_framework_simplejwt.models.TokenUser',
    
    'JTI_CLAIM': 'jti',
    
    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': timedelta(minutes=5),
    'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),
}
```

### Step 3: Create Authentication URLs

**backend/apps/api/urls.py** (update)

```python
"""
API v1 URL configuration using ViewSets and Routers.
"""

from rest_framework.routers import DefaultRouter
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

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

# Authentication URLs
auth_urls = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
]

urlpatterns = [
    # Include authentication URLs
    path('', include(auth_urls)),
    # Include router URLs
    path('', include(router.urls)),
]
```

### Step 4: Create User Registration View

**backend/apps/users/views.py** (update)

```python
"""
API views for User management using ViewSets.
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
    - set_role: POST /users/{id}/set_role/
    - register: POST /users/register/
    """
    
    queryset = User.objects.all()
    
    def get_permissions(self):
        """
        Allow registration without authentication.
        Require authentication for other actions.
        """
        if self.action == 'register':
            return [AllowAny()]
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
        
        user.role = role
        user.save()
        
        serializer = self.get_serializer(user)
        return Response(serializer.data)
```

### Step 5: Update Permissions on Other ViewSets

**backend/apps/projects/views.py** (update permissions)

```python
"""
API views for Project management using ViewSets.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny

from .models import Project
from .serializers import ProjectSerializer, ProjectCreateSerializer
from .filters import ProjectFilter
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer
from apps.tasks.filters import TaskFilter
from apps.tasks.models import Task


class ProjectViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Project CRUD operations.
    """
    
    queryset = Project.objects.all()
    permission_classes = [IsAuthenticated]
    
    # Filter backends
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    filterset_class = ProjectFilter
    search_fields = ['name', 'description']
    ordering_fields = ['created_at', 'name', 'task_count']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """
        Filter projects to only show projects the user has access to.
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

### Step 6: Update Task ViewSet Permissions

**backend/apps/tasks/views.py** (update permissions)

```python
"""
API views for Task management using ViewSets.
"""

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


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Task CRUD operations.
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
    
    def get_queryset(self):
        """
        Filter tasks to only show tasks the user has access to.
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

### Step 7: Update Comment ViewSet Permissions

**backend/apps/comments/views.py** (update permissions)

```python
"""
API views for Comment management using ViewSets.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Comment
from .serializers import CommentSerializer, CommentCreateSerializer, CommentUpdateSerializer
from .filters import CommentFilter


class CommentViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Comment CRUD operations.
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
    
    def get_queryset(self):
        """
        Filter comments to only show comments on tasks the user has access to.
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

### Step 8: Update User Model with Authentication Helpers

**backend/apps/users/models.py** (update)

```python
"""
Custom User model extending Django's AbstractUser.
"""

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext_lazy as _

from .managers import UserManager


class User(AbstractUser):
    """
    Custom User model with additional fields.
    """
    
    class Roles(models.TextChoices):
        ADMIN = 'admin', _('Administrator')
        MANAGER = 'manager', _('Manager')
        MEMBER = 'member', _('Member')
        VIEWER = 'viewer', _('Viewer')

    email = models.EmailField(_('email address'), unique=True)
    bio = models.TextField(_('bio'), blank=True, null=True)
    role = models.CharField(
        _('role'),
        max_length=20,
        choices=Roles.choices,
        default=Roles.MEMBER,
    )
    created_at = models.DateTimeField(_('created at'), auto_now_add=True)
    updated_at = models.DateTimeField(_('updated at'), auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-created_at']

    def __str__(self):
        return self.email

    def get_full_name(self):
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.email

    @property
    def is_admin(self):
        return self.role == self.Roles.ADMIN or self.is_superuser

    @property
    def is_manager(self):
        return self.role in [self.Roles.ADMIN, self.Roles.MANAGER]

    def has_project_access(self, project):
        """
        Check if user has access to a project.
        """
        if self.is_admin:
            return True
        if project.created_by == self:
            return True
        if project.tasks.filter(assigned_to=self).exists():
            return True
        return False
    
    def has_task_access(self, task):
        """
        Check if user has access to a task.
        """
        if self.is_admin:
            return True
        if task.created_by == self:
            return True
        if task.assigned_to == self:
            return True
        if task.project.created_by == self:
            return True
        return False
```

---

## The Verification

### Step 1: Run Migrations

```bash
cd backend
source venv/bin/activate
python manage.py makemigrations
python manage.py migrate
```

### Step 2: Create a Test User

```bash
python manage.py createsuperuser
# Email: admin@example.com
# Username: admin
# Password: admin123
```

### Step 3: Test Authentication Endpoints

```bash
# Get JWT token
curl -X POST http://localhost:8000/api/v1/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'

# You should receive:
# {
#   "refresh": "eyJhbGciOiJIUzI1NiIs...",
#   "access": "eyJhbGciOiJIUzI1NiIs..."
# }

# Test protected endpoint without token (should fail)
curl -X GET http://localhost:8000/api/v1/projects/

# Test protected endpoint with token
curl -X GET http://localhost:8000/api/v1/projects/ \
  -H "Authorization: Bearer <access_token>"

# Refresh token
curl -X POST http://localhost:8000/api/v1/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{"refresh": "<refresh_token>"}'

# Register new user
curl -X POST http://localhost:8000/api/v1/users/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "first_name": "Test",
    "last_name": "User",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!"
  }'

# Get user profile (requires authentication)
curl -X GET http://localhost:8000/api/v1/users/profile/ \
  -H "Authorization: Bearer <access_token>"
```

### Step 4: Test Protected Endpoints

```bash
# Create a project (requires authentication)
curl -X POST http://localhost:8000/api/v1/projects/ \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Project", "description": "Test description"}'

# Create a task (requires authentication)
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "Test description",
    "project": 1,
    "status": "todo",
    "priority": "high"
  }'
```

---

## Key Takeaways

1. **JWT Authentication** provides stateless authentication suitable for REST APIs.

2. **Access tokens** are short-lived and used for API authorization.

3. **Refresh tokens** are long-lived and used to obtain new access tokens.

4. **SimpleJWT** handles the JWT implementation in Django.

5. **Authentication vs Authorization**: Authentication verifies identity, authorization verifies permissions.

6. **Token rotation** improves security by issuing new refresh tokens.

7. **Default permissions** should be restrictive, with `AllowAny` only where necessary.

---

## What's Next

In **Part 15**, we'll implement JWT authentication in the frontend:

- Login and registration UI
- Token storage and management
- Authenticated API requests
- Route protection
- Automatic token refresh

---

**End of Part 14**

*Next: Part 15 - JWT with SimpleJWT*
