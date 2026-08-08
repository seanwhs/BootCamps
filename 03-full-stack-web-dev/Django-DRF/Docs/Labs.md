# Django REST Framework & Next.js 16: Lab Book

## Hands-On Laboratory Exercises for the Masterclass

---

# Lab 1: Setting Up Your Development Environment

## Objective
Set up a complete development environment for the Django REST Framework and Next.js project.

## Prerequisites
- Python 3.12+ installed
- Node.js 20+ installed
- PostgreSQL 15+ installed
- Redis 7+ installed
- Docker and Docker Compose installed
- VS Code or preferred IDE

## Step 1: Create Project Directory

```bash
mkdir django-nextjs-masterclass
cd django-nextjs-masterclass
```

## Step 2: Set Up Backend

```bash
mkdir backend
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

Create `requirements/base.txt`:

```txt
Django>=6.0,<6.1
psycopg2-binary>=2.9.0
django-environ>=0.11.0
python-dotenv>=1.0.0
djangorestframework>=3.15.0
django-cors-headers>=4.3.0
```

Install dependencies:

```bash
pip install -r requirements/base.txt
```

## Step 3: Create Django Project

```bash
django-admin startproject config .
```

## Step 4: Create .env File

```bash
# backend/.env
SECRET_KEY=django-insecure-dev-key-12345
DEBUG=True
DATABASE_URL=postgresql://taskflow_user:taskflow_pass@localhost:5432/taskflow_db
```

## Step 5: Create PostgreSQL Database

```bash
# Using PostgreSQL CLI
createdb -U postgres taskflow_db
createuser -U postgres taskflow_user
psql -U postgres -c "ALTER USER taskflow_user WITH PASSWORD 'taskflow_pass';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE taskflow_db TO taskflow_user;"
```

## Step 6: Set Up Frontend

```bash
cd ..
npx create-next-app@latest frontend --typescript --tailwind --eslint --app --use-npm
```

## Step 7: Verify Setup

### Verify Backend
```bash
cd backend
python manage.py runserver
# Should start on http://localhost:8000
```

### Verify Frontend
```bash
cd frontend
npm run dev
# Should start on http://localhost:3000
```

## ✅ Checkpoint: Lab 1 Complete
- [ ] Project directory created
- [ ] Backend virtual environment created
- [ ] Django project initialized
- [ ] PostgreSQL database created
- [ ] Next.js frontend created
- [ ] Both servers can start

---

# Lab 2: Building Django Models and Migrations

## Objective
Create Django models for the TaskFlow application and run migrations.

## Step 1: Create Custom User Model

Create the users app and model:

```bash
cd backend
python manage.py startapp users apps/users
```

**backend/apps/users/models.py:**

```python
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    class Roles(models.TextChoices):
        ADMIN = 'admin', 'Administrator'
        MANAGER = 'manager', 'Manager'
        MEMBER = 'member', 'Member'
        VIEWER = 'viewer', 'Viewer'
    
    email = models.EmailField(unique=True)
    bio = models.TextField(blank=True, null=True)
    role = models.CharField(max_length=20, choices=Roles.choices, default=Roles.MEMBER)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']
    
    def __str__(self):
        return self.email
```

## Step 2: Create Project Model

```bash
python manage.py startapp projects apps/projects
```

**backend/apps/projects/models.py:**

```python
from django.db import models
from django.conf import settings

class Project(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='projects'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return self.name
```

## Step 3: Create Task Model

```bash
python manage.py startapp tasks apps/tasks
```

**backend/apps/tasks/models.py:**

```python
from django.db import models
from django.conf import settings

class Task(models.Model):
    class Status(models.TextChoices):
        TODO = 'todo', 'To Do'
        IN_PROGRESS = 'in_progress', 'In Progress'
        REVIEW = 'review', 'In Review'
        DONE = 'done', 'Done'
    
    class Priority(models.TextChoices):
        LOW = 'low', 'Low'
        MEDIUM = 'medium', 'Medium'
        HIGH = 'high', 'High'
        URGENT = 'urgent', 'Urgent'
    
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.TODO)
    priority = models.CharField(max_length=20, choices=Priority.choices, default=Priority.MEDIUM)
    due_date = models.DateTimeField(blank=True, null=True)
    project = models.ForeignKey(
        'projects.Project',
        on_delete=models.CASCADE,
        related_name='tasks'
    )
    assigned_to = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_tasks'
    )
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='created_tasks'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.title} ({self.project.name})"
```

## Step 4: Create Comment Model

```bash
python manage.py startapp comments apps/comments
```

**backend/apps/comments/models.py:**

```python
from django.db import models
from django.conf import settings

class Comment(models.Model):
    content = models.TextField()
    task = models.ForeignKey(
        'tasks.Task',
        on_delete=models.CASCADE,
        related_name='comments'
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='comments'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['created_at']
    
    def __str__(self):
        return f"Comment by {self.author.email} on {self.task.title}"
```

## Step 5: Update Settings and Register Apps

**backend/config/settings.py:**

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'apps.users',
    'apps.projects',
    'apps.tasks',
    'apps.comments',
]

AUTH_USER_MODEL = 'users.User'

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

CORS_ALLOW_ALL_ORIGINS = True

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
}
```

## Step 6: Run Migrations

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
# Follow prompts to create admin user
```

## ✅ Checkpoint: Lab 2 Complete
- [ ] Custom User model created
- [ ] Project model created
- [ ] Task model created
- [ ] Comment model created
- [ ] All apps registered in settings
- [ ] Migrations created and applied
- [ ] Superuser created

---

# Lab 3: Creating DRF Serializers

## Objective
Create serializers for all models with validation.

## Step 1: Create User Serializers

**backend/apps/users/serializers.py:**

```python
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    full_name = serializers.SerializerMethodField()
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'full_name',
                  'bio', 'role', 'role_display', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_full_name(self, obj):
        return obj.get_full_name()

class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['email', 'username', 'first_name', 'last_name', 'password', 
                  'confirm_password', 'bio', 'role']
    
    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError({"confirm_password": "Passwords do not match"})
        return data
    
    def create(self, validated_data):
        validated_data.pop('confirm_password')
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user
```

## Step 2: Create Project Serializers

**backend/apps/projects/serializers.py:**

```python
from rest_framework import serializers
from .models import Project

class ProjectSerializer(serializers.ModelSerializer):
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)
    
    class Meta:
        model = Project
        fields = ['id', 'name', 'description', 'created_by', 'created_by_username',
                  'created_at', 'updated_at']
        read_only_fields = ['id', 'created_by', 'created_at', 'updated_at']
    
    def validate_name(self, value):
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Project name must be at least 3 characters")
        return value.strip()
```

## Step 3: Create Task Serializers

**backend/apps/tasks/serializers.py:**

```python
from rest_framework import serializers
from django.utils import timezone
from .models import Task

class TaskListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views"""
    project_name = serializers.CharField(source='project.name', read_only=True)
    assigned_to_username = serializers.CharField(source='assigned_to.username', read_only=True)
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'priority', 'project_name', 
                  'assigned_to_username', 'due_date', 'created_at']

class TaskDetailSerializer(serializers.ModelSerializer):
    """Full serializer for detail views"""
    project_name = serializers.CharField(source='project.name', read_only=True)
    assigned_to_username = serializers.CharField(source='assigned_to.username', read_only=True)
    created_by_username = serializers.CharField(source='created_by.username', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)
    
    class Meta:
        model = Task
        fields = '__all__'

class TaskCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['title', 'description', 'status', 'priority', 'due_date', 
                  'project', 'assigned_to']
    
    def validate_title(self, value):
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Task title must be at least 3 characters")
        return value.strip()
    
    def validate(self, data):
        if data.get('due_date') and data['due_date'] < timezone.now():
            raise serializers.ValidationError({"due_date": "Due date must be in the future"})
        return data
```

## Step 4: Create Comment Serializer

**backend/apps/comments/serializers.py:**

```python
from rest_framework import serializers
from .models import Comment

class CommentSerializer(serializers.ModelSerializer):
    author_username = serializers.CharField(source='author.username', read_only=True)
    
    class Meta:
        model = Comment
        fields = ['id', 'content', 'task', 'author', 'author_username', 'created_at', 'updated_at']
        read_only_fields = ['id', 'author', 'created_at', 'updated_at']
    
    def validate_content(self, value):
        if len(value.strip()) < 2:
            raise serializers.ValidationError("Comment must be at least 2 characters")
        return value.strip()
```

## ✅ Checkpoint: Lab 3 Complete
- [ ] User serializers created
- [ ] Project serializers created
- [ ] Task serializers created (list and detail)
- [ ] Comment serializers created
- [ ] Validation implemented on all serializers

---

# Lab 4: Building API Views

## Objective
Create CRUD API views for all resources.

## Step 1: Create User Views

**backend/apps/users/views.py:**

```python
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import User
from .serializers import UserSerializer, UserCreateSerializer

@api_view(['GET', 'POST'])
def user_list(request):
    if request.method == 'GET':
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = UserCreateSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def user_detail(request, pk):
    try:
        user = User.objects.get(pk=pk)
    except User.DoesNotExist:
        return Response({'detail': 'User not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = UserSerializer(user)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = UserSerializer(user, data=request.data, partial=(request.method == 'PATCH'))
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

## Step 2: Create Project Views

**backend/apps/projects/views.py:**

```python
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Project
from .serializers import ProjectSerializer
from apps.tasks.serializers import TaskSerializer
from apps.tasks.models import Task

@api_view(['GET', 'POST'])
def project_list(request):
    if request.method == 'GET':
        projects = Project.objects.all()
        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = ProjectSerializer(data=request.data)
        if serializer.is_valid():
            project = serializer.save(created_by=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def project_detail(request, pk):
    try:
        project = Project.objects.get(pk=pk)
    except Project.DoesNotExist:
        return Response({'detail': 'Project not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = ProjectSerializer(project)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = ProjectSerializer(project, data=request.data, partial=(request.method == 'PATCH'))
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        project.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def project_tasks(request, project_pk):
    try:
        project = Project.objects.get(pk=project_pk)
    except Project.DoesNotExist:
        return Response({'detail': 'Project not found'}, status=status.HTTP_404_NOT_FOUND)
    
    tasks = project.tasks.all()
    serializer = TaskSerializer(tasks, many=True)
    return Response(serializer.data)
```

## Step 3: Create Task Views

**backend/apps/tasks/views.py:**

```python
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Task
from .serializers import TaskListSerializer, TaskDetailSerializer, TaskCreateSerializer

@api_view(['GET', 'POST'])
def task_list(request):
    if request.method == 'GET':
        tasks = Task.objects.all()
        serializer = TaskListSerializer(tasks, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = TaskCreateSerializer(data=request.data)
        if serializer.is_valid():
            task = serializer.save(created_by=request.user)
            return Response(TaskDetailSerializer(task).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def task_detail(request, pk):
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response({'detail': 'Task not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = TaskDetailSerializer(task)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = TaskDetailSerializer(task, data=request.data, partial=(request.method == 'PATCH'))
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        task.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def task_comments(request, task_pk):
    try:
        task = Task.objects.get(pk=task_pk)
    except Task.DoesNotExist:
        return Response({'detail': 'Task not found'}, status=status.HTTP_404_NOT_FOUND)
    
    comments = task.comments.all()
    from apps.comments.serializers import CommentSerializer
    serializer = CommentSerializer(comments, many=True)
    return Response(serializer.data)
```

## Step 4: Create Comment Views

**backend/apps/comments/views.py:**

```python
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Comment
from .serializers import CommentSerializer

@api_view(['GET', 'POST'])
def comment_list(request):
    if request.method == 'GET':
        comments = Comment.objects.all()
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = CommentSerializer(data=request.data)
        if serializer.is_valid():
            comment = serializer.save(author=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def comment_detail(request, pk):
    try:
        comment = Comment.objects.get(pk=pk)
    except Comment.DoesNotExist:
        return Response({'detail': 'Comment not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = CommentSerializer(comment)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = CommentSerializer(comment, data=request.data, partial=(request.method == 'PATCH'))
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        comment.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

## Step 5: Create URL Configuration

**backend/apps/api/urls.py:**

```python
from django.urls import path, include

urlpatterns = [
    path('users/', include('apps.users.urls')),
    path('projects/', include('apps.projects.urls')),
    path('tasks/', include('apps.tasks.urls')),
    path('comments/', include('apps.comments.urls')),
]
```

**backend/apps/users/urls.py:**

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.user_list, name='user-list'),
    path('<int:pk>/', views.user_detail, name='user-detail'),
]
```

**backend/apps/projects/urls.py:**

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.project_list, name='project-list'),
    path('<int:pk>/', views.project_detail, name='project-detail'),
    path('<int:project_pk>/tasks/', views.project_tasks, name='project-tasks'),
]
```

**backend/apps/tasks/urls.py:**

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.task_list, name='task-list'),
    path('<int:pk>/', views.task_detail, name='task-detail'),
    path('<int:task_pk>/comments/', views.task_comments, name='task-comments'),
]
```

**backend/apps/comments/urls.py:**

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.comment_list, name='comment-list'),
    path('<int:pk>/', views.comment_detail, name='comment-detail'),
]
```

**backend/config/urls.py:**

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('apps.api.urls')),
]
```

## ✅ Checkpoint: Lab 4 Complete
- [ ] User views created
- [ ] Project views created
- [ ] Task views created
- [ ] Comment views created
- [ ] All URL patterns configured
- [ ] API is accessible at /api/v1/

---

# Lab 5: Testing the API

## Objective
Test all API endpoints using curl and verify they work correctly.

## Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

## Step 2: Test User Endpoints

```bash
# Create a user (requires POST)
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

# List users
curl -X GET http://localhost:8000/api/v1/users/

# Get user detail
curl -X GET http://localhost:8000/api/v1/users/1/
```

## Step 3: Test Project Endpoints

```bash
# Create a project
curl -X POST http://localhost:8000/api/v1/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Project",
    "description": "This is a test project"
  }'

# List projects
curl -X GET http://localhost:8000/api/v1/projects/
```

## Step 4: Test Task Endpoints

```bash
# Create a task
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "This is a test task",
    "project": 1,
    "status": "todo",
    "priority": "high"
  }'

# List tasks
curl -X GET http://localhost:8000/api/v1/tasks/

# Get tasks for a project
curl -X GET http://localhost:8000/api/v1/projects/1/tasks/
```

## Step 5: Test Comment Endpoints

```bash
# Create a comment
curl -X POST http://localhost:8000/api/v1/comments/ \
  -H "Content-Type: application/json" \
  -d '{
    "content": "This is a test comment",
    "task": 1
  }'

# List comments
curl -X GET http://localhost:8000/api/v1/comments/

# Get comments for a task
curl -X GET http://localhost:8000/api/v1/tasks/1/comments/
```

## ✅ Checkpoint: Lab 5 Complete
- [ ] User endpoints tested and working
- [ ] Project endpoints tested and working
- [ ] Task endpoints tested and working
- [ ] Comment endpoints tested and working
- [ ] All endpoints return expected responses

---

# Lab 6: Building Next.js API Client

## Objective
Create an API client in Next.js to communicate with the Django backend.

## Step 1: Create API Client

**frontend/lib/api/client.ts:**

```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';

export interface ApiResponse<T = any> {
    data?: T;
    error?: any;
    status: number;
}

export async function apiRequest<T = any>(
    endpoint: string,
    options: RequestInit = {}
): Promise<ApiResponse<T>> {
    const url = `${API_URL}${endpoint}`;
    const headers: HeadersInit = {
        'Content-Type': 'application/json',
        ...options.headers,
    };
    
    try {
        const response = await fetch(url, { ...options, headers });
        const data = await response.json();
        
        if (!response.ok) {
            return { error: data, status: response.status };
        }
        
        return { data, status: response.status };
    } catch (error) {
        return { error, status: 0 };
    }
}

export function get<T = any>(endpoint: string): Promise<ApiResponse<T>> {
    return apiRequest<T>(endpoint, { method: 'GET' });
}

export function post<T = any>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return apiRequest<T>(endpoint, {
        method: 'POST',
        body: data ? JSON.stringify(data) : undefined,
    });
}

export function put<T = any>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return apiRequest<T>(endpoint, {
        method: 'PUT',
        body: data ? JSON.stringify(data) : undefined,
    });
}

export function patch<T = any>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return apiRequest<T>(endpoint, {
        method: 'PATCH',
        body: data ? JSON.stringify(data) : undefined,
    });
}

export function del<T = any>(endpoint: string): Promise<ApiResponse<T>> {
    return apiRequest<T>(endpoint, { method: 'DELETE' });
}
```

## Step 2: Create API Endpoints

**frontend/lib/api/endpoints.ts:**

```typescript
export const ENDPOINTS = {
    users: {
        list: '/users/',
        detail: (id: number) => `/users/${id}/`,
    },
    projects: {
        list: '/projects/',
        detail: (id: number) => `/projects/${id}/`,
        tasks: (id: number) => `/projects/${id}/tasks/`,
    },
    tasks: {
        list: '/tasks/',
        detail: (id: number) => `/tasks/${id}/`,
        comments: (id: number) => `/tasks/${id}/comments/`,
    },
    comments: {
        list: '/comments/',
        detail: (id: number) => `/comments/${id}/`,
    },
};
```

## Step 3: Create Type Definitions

**frontend/types/index.ts:**

```typescript
export interface User {
    id: number;
    email: string;
    username: string;
    first_name: string;
    last_name: string;
    full_name: string;
    bio: string | null;
    role: 'admin' | 'manager' | 'member' | 'viewer';
    created_at: string;
    updated_at: string;
}

export interface Project {
    id: number;
    name: string;
    description: string | null;
    created_by: number;
    created_by_username: string;
    created_at: string;
    updated_at: string;
}

export interface Task {
    id: number;
    title: string;
    description: string | null;
    status: 'todo' | 'in_progress' | 'review' | 'done';
    priority: 'low' | 'medium' | 'high' | 'urgent';
    due_date: string | null;
    project: number;
    project_name: string;
    assigned_to: number | null;
    assigned_to_username: string | null;
    created_by: number;
    created_by_username: string;
    created_at: string;
    updated_at: string;
}

export interface Comment {
    id: number;
    content: string;
    task: number;
    author: number;
    author_username: string;
    created_at: string;
    updated_at: string;
}
```

## ✅ Checkpoint: Lab 6 Complete
- [ ] API client created
- [ ] Endpoints defined
- [ ] Type definitions created
- [ ] Client is ready for use in components

---

# Lab 7: Building React Components

## Objective
Create React components to display and manage data.

## Step 1: Create Task List Component

**frontend/app/(dashboard)/tasks/components/TaskList.tsx:**

```tsx
'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';

interface TaskListProps {
    initialTasks?: Task[];
}

export function TaskList({ initialTasks }: TaskListProps) {
    const [tasks, setTasks] = useState<Task[]>(initialTasks || []);
    const [loading, setLoading] = useState(!initialTasks);
    const [error, setError] = useState<string | null>(null);
    
    useEffect(() => {
        if (!initialTasks) {
            const fetchTasks = async () => {
                try {
                    const response = await get<Task[]>(ENDPOINTS.tasks.list);
                    if (response.data) {
                        setTasks(response.data);
                    } else {
                        setError('Failed to load tasks');
                    }
                } catch (err) {
                    setError('An error occurred');
                } finally {
                    setLoading(false);
                }
            };
            fetchTasks();
        }
    }, [initialTasks]);
    
    if (loading) {
        return <div className="text-center py-8">Loading tasks...</div>;
    }
    
    if (error) {
        return <div className="text-center py-8 text-red-600">{error}</div>;
    }
    
    if (tasks.length === 0) {
        return <div className="text-center py-8 text-gray-500">No tasks found</div>;
    }
    
    return (
        <div className="space-y-4">
            {tasks.map((task) => (
                <Link
                    key={task.id}
                    href={`/tasks/${task.id}`}
                    className="block bg-white p-4 rounded-lg shadow hover:shadow-md transition-shadow"
                >
                    <div className="flex items-center justify-between">
                        <div>
                            <h3 className="font-semibold">{task.title}</h3>
                            <p className="text-sm text-gray-600">{task.project_name}</p>
                        </div>
                        <span className={`px-2 py-1 text-sm rounded ${
                            task.status === 'done' ? 'bg-green-100 text-green-800' :
                            task.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                            'bg-gray-100 text-gray-800'
                        }`}>
                            {task.status}
                        </span>
                    </div>
                </Link>
            ))}
        </div>
    );
}
```

## Step 2: Create Task Form Component

**frontend/app/(dashboard)/tasks/components/TaskForm.tsx:**

```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { post } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';

interface TaskFormProps {
    projectId?: number;
}

export function TaskForm({ projectId }: TaskFormProps) {
    const router = useRouter();
    const [loading, setLoading] = useState(false);
    const [errors, setErrors] = useState<Record<string, string[]>>({});
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        status: 'todo',
        priority: 'medium',
        due_date: '',
        project: projectId || '',
        assigned_to: '',
    });
    
    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };
    
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setErrors({});
        
        const response = await post(ENDPOINTS.tasks.list, formData);
        
        if (response.error) {
            setErrors(response.error);
            setLoading(false);
            return;
        }
        
        if (projectId) {
            router.push(`/projects/${projectId}`);
        } else {
            router.push('/tasks');
        }
        router.refresh();
    };
    
    return (
        <form onSubmit={handleSubmit} className="space-y-4 max-w-2xl">
            <div>
                <label htmlFor="title" className="block text-sm font-medium text-gray-700">
                    Title *
                </label>
                <input
                    type="text"
                    id="title"
                    name="title"
                    value={formData.title}
                    onChange={handleChange}
                    required
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                />
                {errors.title && (
                    <p className="text-red-600 text-sm mt-1">{errors.title.join(', ')}</p>
                )}
            </div>
            
            <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700">
                    Description
                </label>
                <textarea
                    id="description"
                    name="description"
                    value={formData.description}
                    onChange={handleChange}
                    rows={4}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                />
            </div>
            
            <div className="grid grid-cols-2 gap-4">
                <div>
                    <label htmlFor="status" className="block text-sm font-medium text-gray-700">
                        Status
                    </label>
                    <select
                        id="status"
                        name="status"
                        value={formData.status}
                        onChange={handleChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    >
                        <option value="todo">To Do</option>
                        <option value="in_progress">In Progress</option>
                        <option value="review">In Review</option>
                        <option value="done">Done</option>
                    </select>
                </div>
                
                <div>
                    <label htmlFor="priority" className="block text-sm font-medium text-gray-700">
                        Priority
                    </label>
                    <select
                        id="priority"
                        name="priority"
                        value={formData.priority}
                        onChange={handleChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    >
                        <option value="low">Low</option>
                        <option value="medium">Medium</option>
                        <option value="high">High</option>
                        <option value="urgent">Urgent</option>
                    </select>
                </div>
            </div>
            
            <div className="grid grid-cols-2 gap-4">
                <div>
                    <label htmlFor="due_date" className="block text-sm font-medium text-gray-700">
                        Due Date
                    </label>
                    <input
                        type="datetime-local"
                        id="due_date"
                        name="due_date"
                        value={formData.due_date}
                        onChange={handleChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    />
                </div>
                
                <div>
                    <label htmlFor="project" className="block text-sm font-medium text-gray-700">
                        Project *
                    </label>
                    <input
                        type="number"
                        id="project"
                        name="project"
                        value={formData.project}
                        onChange={handleChange}
                        required
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    />
                </div>
            </div>
            
            <div>
                <button
                    type="submit"
                    disabled={loading}
                    className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:opacity-50"
                >
                    {loading ? 'Creating...' : 'Create Task'}
                </button>
            </div>
        </form>
    );
}
```

## Step 3: Create Tasks Page

**frontend/app/(dashboard)/tasks/page.tsx:**

```tsx
import { TaskList } from './components/TaskList';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';

export default async function TasksPage() {
    const response = await get<Task[]>(ENDPOINTS.tasks.list);
    const tasks = response.data || [];
    
    return (
        <div>
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-2xl font-bold">Tasks</h1>
                <a href="/tasks/create" className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
                    New Task
                </a>
            </div>
            <TaskList initialTasks={tasks} />
        </div>
    );
}
```

## ✅ Checkpoint: Lab 7 Complete
- [ ] TaskList component created
- [ ] TaskForm component created
- [ ] Tasks page created
- [ ] Components are functional and display data

---

# Lab 8: Creating a Dashboard

## Objective
Build a dashboard page with statistics and quick actions.

## Step 1: Create Stats Hook

**frontend/hooks/useStats.ts:**

```tsx
'use client';

import { useState, useEffect } from 'react';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';

interface Stats {
    total_tasks: number;
    todo: number;
    in_progress: number;
    review: number;
    done: number;
    overdue: number;
    by_priority: {
        low: number;
        medium: number;
        high: number;
        urgent: number;
    };
}

export function useStats() {
    const [stats, setStats] = useState<Stats | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    
    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await get<Stats>(ENDPOINTS.tasks.stats);
                if (response.data) {
                    setStats(response.data);
                } else {
                    setError('Failed to load stats');
                }
            } catch (err) {
                setError('An error occurred');
            } finally {
                setLoading(false);
            }
        };
        fetchStats();
    }, []);
    
    return { stats, loading, error };
}
```

## Step 2: Create Dashboard Page

**frontend/app/(dashboard)/dashboard/page.tsx:**

```tsx
'use client';

import Link from 'next/link';
import { useStats } from '@/hooks/useStats';

export default function DashboardPage() {
    const { stats, loading, error } = useStats();
    
    if (loading) {
        return <div className="text-center py-8">Loading dashboard...</div>;
    }
    
    if (error || !stats) {
        return <div className="text-center py-8 text-red-600">{error || 'Failed to load stats'}</div>;
    }
    
    return (
        <div className="space-y-6">
            <h1 className="text-2xl font-bold">Dashboard</h1>
            
            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="bg-white p-6 rounded-lg shadow">
                    <h3 className="text-sm font-medium text-gray-500">Total Tasks</h3>
                    <p className="text-2xl font-bold">{stats.total_tasks}</p>
                </div>
                <div className="bg-white p-6 rounded-lg shadow">
                    <h3 className="text-sm font-medium text-gray-500">To Do</h3>
                    <p className="text-2xl font-bold text-yellow-600">{stats.todo}</p>
                </div>
                <div className="bg-white p-6 rounded-lg shadow">
                    <h3 className="text-sm font-medium text-gray-500">In Progress</h3>
                    <p className="text-2xl font-bold text-blue-600">{stats.in_progress}</p>
                </div>
                <div className="bg-white p-6 rounded-lg shadow">
                    <h3 className="text-sm font-medium text-gray-500">Done</h3>
                    <p className="text-2xl font-bold text-green-600">{stats.done}</p>
                </div>
            </div>
            
            {/* Priority Breakdown */}
            <div className="bg-white p-6 rounded-lg shadow">
                <h3 className="text-lg font-medium mb-4">Priority Breakdown</h3>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                        <span className="text-sm text-gray-500">Low</span>
                        <p className="text-xl font-bold">{stats.by_priority.low}</p>
                    </div>
                    <div>
                        <span className="text-sm text-gray-500">Medium</span>
                        <p className="text-xl font-bold">{stats.by_priority.medium}</p>
                    </div>
                    <div>
                        <span className="text-sm text-gray-500">High</span>
                        <p className="text-xl font-bold text-orange-600">{stats.by_priority.high}</p>
                    </div>
                    <div>
                        <span className="text-sm text-gray-500">Urgent</span>
                        <p className="text-xl font-bold text-red-600">{stats.by_priority.urgent}</p>
                    </div>
                </div>
            </div>
            
            {/* Quick Actions */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Link
                    href="/tasks/create"
                    className="bg-blue-600 text-white p-4 rounded-lg text-center hover:bg-blue-700"
                >
                    <span className="text-lg font-medium">Create Task</span>
                </Link>
                <Link
                    href="/projects/create"
                    className="bg-green-600 text-white p-4 rounded-lg text-center hover:bg-green-700"
                >
                    <span className="text-lg font-medium">Create Project</span>
                </Link>
                <Link
                    href="/tasks"
                    className="bg-purple-600 text-white p-4 rounded-lg text-center hover:bg-purple-700"
                >
                    <span className="text-lg font-medium">View All Tasks</span>
                </Link>
            </div>
        </div>
    );
}
```

## ✅ Checkpoint: Lab 8 Complete
- [ ] Stats hook created
- [ ] Dashboard page created
- [ ] Statistics displayed
- [ ] Quick actions functional

---

# Lab 9: Authentication Setup

## Objective
Implement JWT authentication for the application.

## Step 1: Install SimpleJWT

```bash
cd backend
source venv/bin/activate
pip install djangorestframework-simplejwt
```

**backend/config/settings.py:**

```python
from datetime import timedelta

INSTALLED_APPS += ['rest_framework_simplejwt']

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}
```

## Step 2: Create Authentication URLs

**backend/apps/api/urls.py:**

```python
from django.urls import path, include
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

urlpatterns = [
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('', include('apps.users.urls')),
    # ... other includes
]
```

## Step 3: Update User Views

**backend/apps/users/views.py:**

```python
from rest_framework.permissions import AllowAny, IsAuthenticated

class UserViewSet(viewsets.ModelViewSet):
    def get_permissions(self):
        if self.action == 'register':
            return [AllowAny()]
        return [IsAuthenticated()]
```

## Step 4: Create Frontend Auth Token Management

**frontend/lib/auth/token.ts:**

```typescript
let accessToken: string | null = null;
let refreshToken: string | null = null;

export function setTokens(access: string, refresh: string) {
    accessToken = access;
    refreshToken = refresh;
    localStorage.setItem('access_token', access);
    localStorage.setItem('refresh_token', refresh);
}

export function getAccessToken(): string | null {
    if (accessToken) return accessToken;
    return localStorage.getItem('access_token');
}

export function getRefreshToken(): string | null {
    if (refreshToken) return refreshToken;
    return localStorage.getItem('refresh_token');
}

export function clearTokens() {
    accessToken = null;
    refreshToken = null;
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
}

export function isAuthenticated(): boolean {
    return !!getAccessToken();
}
```

## Step 5: Update API Client

**frontend/lib/api/client.ts:**

```typescript
import { getAccessToken, getRefreshToken, setTokens, clearTokens } from '@/lib/auth/token';

export async function apiRequest<T = any>(
    endpoint: string,
    options: RequestInit = {}
): Promise<ApiResponse<T>> {
    const url = `${API_URL}${endpoint}`;
    const token = getAccessToken();
    
    const headers: HeadersInit = {
        'Content-Type': 'application/json',
        ...(token && { 'Authorization': `Bearer ${token}` }),
        ...options.headers,
    };
    
    try {
        let response = await fetch(url, { ...options, headers });
        
        // Handle token refresh
        if (response.status === 401) {
            const refresh = getRefreshToken();
            if (refresh) {
                const refreshResponse = await fetch(`${API_URL}/token/refresh/`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ refresh }),
                });
                
                if (refreshResponse.ok) {
                    const data = await refreshResponse.json();
                    setTokens(data.access, refresh);
                    headers['Authorization'] = `Bearer ${data.access}`;
                    response = await fetch(url, { ...options, headers });
                } else {
                    clearTokens();
                    window.location.href = '/login';
                    return { status: 401, error: 'Session expired' };
                }
            }
        }
        
        const data = await response.json();
        if (!response.ok) {
            return { error: data, status: response.status };
        }
        return { data, status: response.status };
    } catch (error) {
        return { error, status: 0 };
    }
}
```

## ✅ Checkpoint: Lab 9 Complete
- [ ] SimpleJWT installed and configured
- [ ] Authentication endpoints created
- [ ] Token management created
- [ ] API client updated with auth handling

---

# Lab 10: Testing the Complete Application

## Objective
Test the complete application flow with authentication.

## Step 1: Create a Test User

```bash
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
```

## Step 2: Obtain Token

```bash
curl -X POST http://localhost:8000/api/v1/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }'
```

Save the access token from the response.

## Step 3: Test Authenticated Endpoints

```bash
# List tasks with authentication
curl -X GET http://localhost:8000/api/v1/tasks/ \
  -H "Authorization: Bearer <access_token>"

# Create a project
curl -X POST http://localhost:8000/api/v1/projects/ \
  -H "Authorization: Bearer <access_token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Project", "description": "Test description"}'

# Create a task
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

## Step 4: Frontend Testing

```bash
# Start the frontend
cd frontend
npm run dev

# Access http://localhost:3000
# Navigate to /login to see the login form
# Navigate to /register to create a new user
# After login, access /dashboard
```

## ✅ Checkpoint: Lab 10 Complete
- [ ] Test user registered
- [ ] Token obtained
- [ ] Authenticated endpoints working
- [ ] Frontend authentication working

---

# Lab 11: Performance Optimization

## Objective
Optimize database queries and implement caching.

## Step 1: Optimize Task List Query

**backend/apps/tasks/views.py:**

```python
class TaskViewSet(viewsets.ModelViewSet):
    def get_queryset(self):
        # Use select_related to reduce queries
        return Task.objects.select_related(
            'project', 'assigned_to', 'created_by'
        ).all()
```

## Step 2: Add Database Indexes

**backend/apps/tasks/models.py:**

```python
class Task(models.Model):
    # ... fields ...
    
    class Meta:
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['project', 'status']),
            models.Index(fields=['assigned_to', 'status']),
            models.Index(fields=['due_date']),
            models.Index(fields=['-created_at']),
        ]
```

## Step 3: Create Migration

```bash
python manage.py makemigrations
python manage.py migrate
```

## Step 4: Implement Redis Caching

```bash
pip install django-redis
```

**backend/config/settings.py:**

```python
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
        'KEY_PREFIX': 'taskflow',
    }
}
```

**backend/apps/tasks/views.py:**

```python
from django.core.cache import cache

@action(detail=False, methods=['get'])
def stats(self, request):
    cache_key = 'task_stats'
    stats = cache.get(cache_key)
    
    if stats is None:
        queryset = self.get_queryset()
        stats = {
            'total': queryset.count(),
            'todo': queryset.filter(status='todo').count(),
            'in_progress': queryset.filter(status='in_progress').count(),
            'done': queryset.filter(status='done').count(),
        }
        cache.set(cache_key, stats, 300)  # Cache for 5 minutes
    
    return Response(stats)
```

## ✅ Checkpoint: Lab 11 Complete
- [ ] Query optimization with select_related
- [ ] Database indexes added
- [ ] Redis caching implemented
- [ ] Stats endpoint cached

---

# Lab 12: Docker Deployment

## Objective
Containerize the application with Docker.

## Step 1: Create Dockerfile for Backend

**backend/Dockerfile:**

```dockerfile
FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements/base.txt requirements/base.txt
RUN pip install -r requirements/base.txt

COPY . .

RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "config.wsgi"]
```

## Step 2: Create Dockerfile for Frontend

**frontend/Dockerfile:**

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nodejs

EXPOSE 3000

CMD ["node", "server.js"]
```

## Step 3: Create docker-compose.yml

**docker-compose.yml:**

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: taskflow_db
      POSTGRES_USER: taskflow_user
      POSTGRES_PASSWORD: taskflow_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  backend:
    build: ./backend
    environment:
      - DATABASE_URL=postgresql://taskflow_user:taskflow_pass@db:5432/taskflow_db
      - REDIS_URL=redis://redis:6379/1
      - DJANGO_ENV=production
      - DEBUG=False
      - SECRET_KEY=your-secret-key
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
    volumes:
      - ./backend:/app

  frontend:
    build: ./frontend
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000/api/v1
    ports:
      - "3000:3000"
    depends_on:
      - backend
    volumes:
      - ./frontend:/app

volumes:
  postgres_data:
  redis_data:
```

## ✅ Checkpoint: Lab 12 Complete
- [ ] Backend Dockerfile created
- [ ] Frontend Dockerfile created
- [ ] docker-compose.yml created
- [ ] Application runs in containers

---

# Lab 13: Testing Docker Deployment

## Objective
Test the Docker deployment and verify all services work together.

## Step 1: Build and Start Containers

```bash
docker-compose build
docker-compose up -d
```

## Step 2: Verify Containers

```bash
docker-compose ps
```

## Step 3: Test Backend

```bash
curl http://localhost:8000/health/
```

## Step 4: Test Frontend

```bash
curl http://localhost:3000
```

## Step 5: Check Logs

```bash
docker-compose logs -f
```

## ✅ Checkpoint: Lab 13 Complete
- [ ] All containers running
- [ ] Backend accessible
- [ ] Frontend accessible
- [ ] Logs are showing activity

---

# Lab 14: CI/CD Pipeline

## Objective
Set up a CI/CD pipeline with GitHub Actions.

## Step 1: Create GitHub Actions Workflow

**.github/workflows/ci.yml:**

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      - name: Install dependencies
        run: |
          cd backend
          python -m pip install --upgrade pip
          pip install -r requirements/development.txt
      - name: Run tests
        run: |
          cd backend
          pytest --cov=apps

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - name: Install dependencies
        run: |
          cd frontend
          npm ci
      - name: Run tests
        run: |
          cd frontend
          npm run test

  build-images:
    needs: [test-backend, test-frontend]
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - name: Build backend image
        run: |
          cd backend
          docker build -t taskflow-backend .
      - name: Build frontend image
        run: |
          cd frontend
          docker build -t taskflow-frontend .
```

## ✅ Checkpoint: Lab 14 Complete
- [ ] CI workflow created
- [ ] Tests run on pull requests
- [ ] Docker images built on push to main
- [ ] Workflow passes

---

# Lab 15: Production Deployment

## Objective
Deploy the application to a production environment.

## Step 1: Create Production Docker Compose

**docker-compose.prod.yml:**

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

  backend:
    build: ./backend
    image: ${DOCKER_REGISTRY}/taskflow-backend:${IMAGE_TAG}
    environment:
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - REDIS_URL=redis://redis:6379/1
      - DJANGO_ENV=production
      - DEBUG=False
      - SECRET_KEY=${SECRET_KEY}
    restart: unless-stopped
    depends_on:
      - db
      - redis

  frontend:
    build: ./frontend
    image: ${DOCKER_REGISTRY}/taskflow-frontend:${IMAGE_TAG}
    environment:
      - NEXT_PUBLIC_API_URL=${API_URL}
    restart: unless-stopped
    depends_on:
      - backend

volumes:
  postgres_data:
  redis_data:
```

## Step 2: Create Environment File

**.env.production:**

```bash
DB_NAME=taskflow_db
DB_USER=taskflow_user
DB_PASSWORD=secure_password
SECRET_KEY=your_secret_key
API_URL=https://api.taskflow.com/api/v1
DOCKER_REGISTRY=ghcr.io/yourusername
IMAGE_TAG=latest
```

## Step 3: Deploy to Production

```bash
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

## Step 4: Verify Production Deployment

```bash
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs
```

## ✅ Checkpoint: Lab 15 Complete
- [ ] Production docker-compose created
- [ ] Environment variables configured
- [ ] Application deployed
- [ ] Production deployment verified

---

## Final Checklist

### Backend
- [ ] Models, Views, Serializers complete
- [ ] Authentication working
- [ ] API endpoints tested
- [ ] Performance optimized
- [ ] Tests passing

### Frontend
- [ ] Components built
- [ ] API client configured
- [ ] Authentication integrated
- [ ] Dashboard functional
- [ ] Tests passing

### Infrastructure
- [ ] Docker containers working
- [ ] CI/CD pipeline configured
- [ ] Production deployment ready
- [ ] Monitoring set up

---

*This concludes the Lab Book for the Django REST Framework & Next.js 16 masterclass.*
