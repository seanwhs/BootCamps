# Part 4: Building API Views

## Creating Your First REST Endpoints

Welcome to **Part 4** of the Django REST Framework & Next.js 16 masterclass. Now that we have our models and serializers, it's time to build the actual API endpoints that will serve data to our frontend.

In this part, we'll:
- Understand the different ways to build API views in DRF
- Create CRUD endpoints for all our resources
- Implement proper HTTP methods and status codes
- Add URL routing for our endpoints
- Test our API with curl and Postman

Think of API views as the **controllers** of our application. They receive HTTP requests, process them using our serializers and models, and return HTTP responses. The views are where we define *what happens* when someone hits a specific endpoint.

---

## The Target

We'll create complete API endpoints for all our resources:

```
GET    /api/v1/users/                 # List users
POST   /api/v1/users/                 # Create user
GET    /api/v1/users/{id}/            # Get user details
PUT    /api/v1/users/{id}/            # Update user
PATCH  /api/v1/users/{id}/            # Partial update user
DELETE /api/v1/users/{id}/            # Delete user

GET    /api/v1/projects/              # List projects
POST   /api/v1/projects/              # Create project
GET    /api/v1/projects/{id}/         # Get project details
PUT    /api/v1/projects/{id}/         # Update project
PATCH  /api/v1/projects/{id}/         # Partial update project
DELETE /api/v1/projects/{id}/         # Delete project

GET    /api/v1/tasks/                 # List tasks
POST   /api/v1/tasks/                 # Create task
GET    /api/v1/tasks/{id}/            # Get task details
PUT    /api/v1/tasks/{id}/            # Update task
PATCH  /api/v1/tasks/{id}/            # Partial update task
DELETE /api/v1/tasks/{id}/            # Delete task

GET    /api/v1/comments/              # List comments
POST   /api/v1/comments/              # Create comment
GET    /api/v1/comments/{id}/         # Get comment details
PUT    /api/v1/comments/{id}/         # Update comment
PATCH  /api/v1/comments/{id}/         # Partial update comment
DELETE /api/v1/comments/{id}/         # Delete comment
```

We'll also create nested endpoints:
```
GET    /api/v1/projects/{id}/tasks/   # Get tasks for a project
POST   /api/v1/projects/{id}/tasks/   # Create task in a project
GET    /api/v1/tasks/{id}/comments/   # Get comments for a task
POST   /api/v1/tasks/{id}/comments/   # Create comment on a task
```

---

## The Concept

### What Are API Views?

API views are Python functions or classes that handle HTTP requests and return HTTP responses. They're the **entry point** for every API request.

### Types of Views in DRF

DRF provides several ways to build views, each with different levels of abstraction:

1. **Function-Based Views (`@api_view`)** : Simple decorator-based views
2. **Class-Based Views (`APIView`)** : More structure with methods for each HTTP verb
3. **Generic Views**: Pre-built views for common patterns
4. **ViewSets**: Group related views together

### View Responsibility

Every API view should:
1. **Receive** the HTTP request
2. **Authenticate** the user (we'll add this in Phase 3)
3. **Authorize** the user (we'll add this in Phase 3)
4. **Validate** input data using serializers
5. **Perform** the business logic (create, read, update, delete)
6. **Return** a response with proper status codes

### The Request-Response Cycle

```
Client Request
     ↓
URL Router (maps URL to view)
     ↓
View receives request
     ↓
View authenticates/authorizes
     ↓
View validates input (serializer)
     ↓
View performs business logic
     ↓
View serializes output
     ↓
View returns HTTP response
     ↓
Client receives response
```

---

## The Implementation

### Step 1: Set Up the API Versioning Structure

First, let's set up our URL structure with versioning.

**backend/config/urls.py**
```python
"""
URL configuration for the backend project.
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('apps.api.urls')),  # We'll create this
]
```

**backend/apps/api/urls.py** (create this file)
```python
"""
API v1 URL configuration.
This file routes all API requests to the appropriate app views.
"""

from django.urls import path, include

urlpatterns = [
    path('users/', include('apps.users.urls')),
    path('projects/', include('apps.projects.urls')),
    path('tasks/', include('apps.tasks.urls')),
    path('comments/', include('apps.comments.urls')),
]
```

### Step 2: Create User Views

**backend/apps/users/views.py**
```python
"""
API views for User management.
"""

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import User
from .serializers import (
    UserSerializer,
    UserCreateSerializer,
    UserUpdateSerializer,
    UserProfileSerializer,
)


@api_view(['GET', 'POST'])
def user_list(request):
    """
    List all users or create a new user.
    GET: Returns a list of all users
    POST: Creates a new user
    """
    if request.method == 'GET':
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = UserCreateSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            # Return the created user data
            response_serializer = UserSerializer(user)
            return Response(
                response_serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def user_detail(request, pk):
    """
    Retrieve, update or delete a user.
    GET: Returns the user details
    PUT: Updates the user (full update)
    PATCH: Partially updates the user
    DELETE: Deletes the user
    """
    try:
        user = User.objects.get(pk=pk)
    except User.DoesNotExist:
        return Response(
            {'detail': 'User not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        serializer = UserSerializer(user)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        # Full update
        serializer = UserUpdateSerializer(user, data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_serializer = UserSerializer(user)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'PATCH':
        # Partial update
        serializer = UserUpdateSerializer(
            user,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            response_serializer = UserSerializer(user)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'DELETE':
        user.delete()
        return Response(
            {'detail': 'User deleted successfully.'},
            status=status.HTTP_204_NO_CONTENT
        )


@api_view(['GET'])
def current_user_profile(request):
    """
    Get the current user's profile.
    This will be used after authentication is implemented.
    """
    # For now, just return the first user
    # We'll update this when we add authentication
    user = User.objects.first()
    if user:
        serializer = UserProfileSerializer(user)
        return Response(serializer.data)
    return Response(
        {'detail': 'No user found.'},
        status=status.HTTP_404_NOT_FOUND
    )
```

**backend/apps/users/urls.py** (create this file)
```python
"""
URL configuration for the users app.
"""

from django.urls import path

from . import views

urlpatterns = [
    # User list and create
    path('', views.user_list, name='user-list'),
    
    # User detail, update, delete
    path('<int:pk>/', views.user_detail, name='user-detail'),
    
    # Current user profile
    path('profile/', views.current_user_profile, name='user-profile'),
]
```

### Step 3: Create Project Views

**backend/apps/projects/views.py**
```python
"""
API views for Project management.
"""

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Project
from .serializers import ProjectSerializer, ProjectCreateSerializer
from apps.tasks.serializers import TaskSerializer
from apps.tasks.models import Task


@api_view(['GET', 'POST'])
def project_list(request):
    """
    List all projects or create a new project.
    GET: Returns a list of all projects
    POST: Creates a new project
    """
    if request.method == 'GET':
        projects = Project.objects.all()
        serializer = ProjectSerializer(projects, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = ProjectCreateSerializer(data=request.data)
        if serializer.is_valid():
            # Set the created_by to the current user
            # For now, get the first user (we'll add auth later)
            from apps.users.models import User
            user = User.objects.first()
            if not user:
                return Response(
                    {'detail': 'No user exists to create project.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            project = serializer.save(created_by=user)
            response_serializer = ProjectSerializer(project)
            return Response(
                response_serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def project_detail(request, pk):
    """
    Retrieve, update or delete a project.
    GET: Returns the project details
    PUT: Updates the project (full update)
    PATCH: Partially updates the project
    DELETE: Deletes the project
    """
    try:
        project = Project.objects.get(pk=pk)
    except Project.DoesNotExist:
        return Response(
            {'detail': 'Project not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        serializer = ProjectSerializer(project)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = ProjectCreateSerializer(project, data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_serializer = ProjectSerializer(project)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'PATCH':
        serializer = ProjectCreateSerializer(
            project,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            response_serializer = ProjectSerializer(project)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'DELETE':
        project.delete()
        return Response(
            {'detail': 'Project deleted successfully.'},
            status=status.HTTP_204_NO_CONTENT
        )


@api_view(['GET', 'POST'])
def project_tasks(request, project_pk):
    """
    List all tasks for a project or create a new task in the project.
    GET: Returns all tasks for the project
    POST: Creates a new task in the project
    """
    try:
        project = Project.objects.get(pk=project_pk)
    except Project.DoesNotExist:
        return Response(
            {'detail': 'Project not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        tasks = project.tasks.all()
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        # Create a task in this project
        from apps.tasks.serializers import TaskCreateSerializer
        
        # Add the project to the request data
        data = request.data.copy()
        data['project'] = project_pk
        
        serializer = TaskCreateSerializer(data=data)
        if serializer.is_valid():
            # Set created_by to current user
            from apps.users.models import User
            user = User.objects.first()
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
```

**backend/apps/projects/urls.py** (create this file)
```python
"""
URL configuration for the projects app.
"""

from django.urls import path

from . import views

urlpatterns = [
    # Project list and create
    path('', views.project_list, name='project-list'),
    
    # Project detail, update, delete
    path('<int:pk>/', views.project_detail, name='project-detail'),
    
    # Project tasks
    path('<int:project_pk>/tasks/', views.project_tasks, name='project-tasks'),
]
```

### Step 4: Create Task Views

**backend/apps/tasks/views.py**
```python
"""
API views for Task management.
"""

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Task
from .serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskUpdateSerializer,
    TaskStatusUpdateSerializer,
)


@api_view(['GET', 'POST'])
def task_list(request):
    """
    List all tasks or create a new task.
    GET: Returns a list of all tasks
    POST: Creates a new task
    """
    if request.method == 'GET':
        tasks = Task.objects.all()
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = TaskCreateSerializer(data=request.data)
        if serializer.is_valid():
            # Set created_by to current user
            from apps.users.models import User
            user = User.objects.first()
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


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def task_detail(request, pk):
    """
    Retrieve, update or delete a task.
    GET: Returns the task details
    PUT: Updates the task (full update)
    PATCH: Partially updates the task
    DELETE: Deletes the task
    """
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response(
            {'detail': 'Task not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        serializer = TaskSerializer(task)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = TaskUpdateSerializer(task, data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_serializer = TaskSerializer(task)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'PATCH':
        # Check if we're only updating status
        if set(request.data.keys()) == {'status'}:
            serializer = TaskStatusUpdateSerializer(
                task,
                data=request.data,
                partial=True
            )
        else:
            serializer = TaskUpdateSerializer(
                task,
                data=request.data,
                partial=True
            )
        
        if serializer.is_valid():
            serializer.save()
            response_serializer = TaskSerializer(task)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'DELETE':
        task.delete()
        return Response(
            {'detail': 'Task deleted successfully.'},
            status=status.HTTP_204_NO_CONTENT
        )


@api_view(['GET'])
def task_comments(request, task_pk):
    """
    List all comments for a task.
    GET: Returns all comments for the task
    """
    try:
        task = Task.objects.get(pk=task_pk)
    except Task.DoesNotExist:
        return Response(
            {'detail': 'Task not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    comments = task.comments.all()
    from apps.comments.serializers import CommentSerializer
    serializer = CommentSerializer(comments, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def task_update_status(request, pk):
    """
    Update only the status of a task.
    This is a convenience endpoint for quick status changes.
    """
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response(
            {'detail': 'Task not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    serializer = TaskStatusUpdateSerializer(task, data=request.data)
    if serializer.is_valid():
        serializer.save()
        response_serializer = TaskSerializer(task)
        return Response(response_serializer.data)
    return Response(
        serializer.errors,
        status=status.HTTP_400_BAD_REQUEST
    )
```

**backend/apps/tasks/urls.py** (create this file)
```python
"""
URL configuration for the tasks app.
"""

from django.urls import path

from . import views

urlpatterns = [
    # Task list and create
    path('', views.task_list, name='task-list'),
    
    # Task detail, update, delete
    path('<int:pk>/', views.task_detail, name='task-detail'),
    
    # Update task status
    path('<int:pk>/status/', views.task_update_status, name='task-update-status'),
    
    # Task comments
    path('<int:task_pk>/comments/', views.task_comments, name='task-comments'),
]
```

### Step 5: Create Comment Views

**backend/apps/comments/views.py**
```python
"""
API views for Comment management.
"""

from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import Comment
from .serializers import CommentSerializer, CommentCreateSerializer


@api_view(['GET', 'POST'])
def comment_list(request):
    """
    List all comments or create a new comment.
    GET: Returns a list of all comments
    POST: Creates a new comment
    """
    if request.method == 'GET':
        comments = Comment.objects.all()
        serializer = CommentSerializer(comments, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = CommentCreateSerializer(data=request.data)
        if serializer.is_valid():
            # Set author to current user
            from apps.users.models import User
            user = User.objects.first()
            if not user:
                return Response(
                    {'detail': 'No user exists to create comment.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            comment = serializer.save(author=user)
            response_serializer = CommentSerializer(comment)
            return Response(
                response_serializer.data,
                status=status.HTTP_201_CREATED
            )
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def comment_detail(request, pk):
    """
    Retrieve, update or delete a comment.
    GET: Returns the comment details
    PUT: Updates the comment (full update)
    PATCH: Partially updates the comment
    DELETE: Deletes the comment
    """
    try:
        comment = Comment.objects.get(pk=pk)
    except Comment.DoesNotExist:
        return Response(
            {'detail': 'Comment not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    if request.method == 'GET':
        serializer = CommentSerializer(comment)
        return Response(serializer.data)
    
    elif request.method == 'PUT':
        serializer = CommentCreateSerializer(comment, data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_serializer = CommentSerializer(comment)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'PATCH':
        from .serializers import CommentUpdateSerializer
        serializer = CommentUpdateSerializer(
            comment,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            response_serializer = CommentSerializer(comment)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    elif request.method == 'DELETE':
        comment.delete()
        return Response(
            {'detail': 'Comment deleted successfully.'},
            status=status.HTTP_204_NO_CONTENT
        )


@api_view(['GET'])
def comment_by_task(request, task_pk):
    """
    Get all comments for a specific task.
    """
    try:
        from apps.tasks.models import Task
        task = Task.objects.get(pk=task_pk)
    except Task.DoesNotExist:
        return Response(
            {'detail': 'Task not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    comments = task.comments.all()
    serializer = CommentSerializer(comments, many=True)
    return Response(serializer.data)
```

**backend/apps/comments/urls.py** (create this file)
```python
"""
URL configuration for the comments app.
"""

from django.urls import path

from . import views

urlpatterns = [
    # Comment list and create
    path('', views.comment_list, name='comment-list'),
    
    # Comment detail, update, delete
    path('<int:pk>/', views.comment_detail, name='comment-detail'),
    
    # Comments by task
    path('by-task/<int:task_pk>/', views.comment_by_task, name='comment-by-task'),
]
```

### Step 6: Fix Any Import Issues

We need to make sure all our imports are correct. Create the `apps/api` module:

**backend/apps/api/__init__.py** (create this file)
```python
"""
API v1 package.
"""
```

**backend/apps/api/urls.py** (already created, verify contents)
```python
"""
API v1 URL configuration.
"""

from django.urls import path, include

urlpatterns = [
    path('users/', include('apps.users.urls')),
    path('projects/', include('apps.projects.urls')),
    path('tasks/', include('apps.tasks.urls')),
    path('comments/', include('apps.comments.urls')),
]
```

---

## The Verification

### Step 1: Test the API with curl

Start the server:

```bash
python manage.py runserver
```

In another terminal, test each endpoint:

#### Test Users

```bash
# List all users
curl -X GET http://localhost:8000/api/v1/users/

# Create a new user
curl -X POST http://localhost:8000/api/v1/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "username": "newuser",
    "first_name": "New",
    "last_name": "User",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!"
  }'

# Get a specific user
curl -X GET http://localhost:8000/api/v1/users/1/

# Update a user
curl -X PATCH http://localhost:8000/api/v1/users/1/ \
  -H "Content-Type: application/json" \
  -d '{"bio": "This is my updated bio"}'

# Delete a user (be careful!)
curl -X DELETE http://localhost:8000/api/v1/users/1/
```

#### Test Projects

```bash
# List all projects
curl -X GET http://localhost:8000/api/v1/projects/

# Create a project
curl -X POST http://localhost:8000/api/v1/projects/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Project",
    "description": "This is a new project"
  }'

# Get a specific project
curl -X GET http://localhost:8000/api/v1/projects/1/

# Get tasks for a project
curl -X GET http://localhost:8000/api/v1/projects/1/tasks/

# Create a task in a project
curl -X POST http://localhost:8000/api/v1/projects/1/tasks/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Task in Project",
    "description": "Task description",
    "status": "todo",
    "priority": "high"
  }'
```

#### Test Tasks

```bash
# List all tasks
curl -X GET http://localhost:8000/api/v1/tasks/

# Create a task
curl -X POST http://localhost:8000/api/v1/tasks/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Standalone Task",
    "description": "Task without project",
    "project": 1,
    "status": "todo",
    "priority": "medium"
  }'

# Get a specific task
curl -X GET http://localhost:8000/api/v1/tasks/1/

# Update task status
curl -X PATCH http://localhost:8000/api/v1/tasks/1/status/ \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'

# Update task (full update)
curl -X PUT http://localhost:8000/api/v1/tasks/1/ \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Task Title",
    "description": "Updated description",
    "status": "review",
    "priority": "urgent",
    "project": 1
  }'
```

#### Test Comments

```bash
# List all comments
curl -X GET http://localhost:8000/api/v1/comments/

# Create a comment
curl -X POST http://localhost:8000/api/v1/comments/ \
  -H "Content-Type: application/json" \
  -d '{
    "content": "This is a test comment",
    "task": 1
  }'

# Get a specific comment
curl -X GET http://localhost:8000/api/v1/comments/1/

# Get comments for a task
curl -X GET http://localhost:8000/api/v1/comments/by-task/1/
```

### Step 2: Create a Comprehensive Test Script

**backend/test_api.py**
```python
"""
Comprehensive API test script using the Django test client.
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.test import Client
from django.contrib.auth import get_user_model
import json

User = get_user_model()


def test_api_endpoints():
    """Test all API endpoints."""
    client = Client()
    
    # Create a user for testing
    user = User.objects.create_user(
        email='test@example.com',
        username='testuser',
        password='TestPass123!',
        first_name='Test',
        last_name='User'
    )
    
    print("=" * 50)
    print("TESTING API ENDPOINTS")
    print("=" * 50)
    
    # Test user endpoints
    print("\n--- Testing User Endpoints ---")
    
    # GET /api/v1/users/
    response = client.get('/api/v1/users/')
    print(f"GET /api/v1/users/: {response.status_code}")
    assert response.status_code == 200
    
    # POST /api/v1/users/
    data = {
        'email': 'newtest@example.com',
        'username': 'newtest',
        'first_name': 'New',
        'last_name': 'Test',
        'password': 'SecurePass123!',
        'confirm_password': 'SecurePass123!',
    }
    response = client.post(
        '/api/v1/users/',
        data=json.dumps(data),
        content_type='application/json'
    )
    print(f"POST /api/v1/users/: {response.status_code}")
    assert response.status_code == 201
    
    # Test project endpoints
    print("\n--- Testing Project Endpoints ---")
    
    # POST /api/v1/projects/
    data = {
        'name': 'Test Project',
        'description': 'Project for API testing',
    }
    response = client.post(
        '/api/v1/projects/',
        data=json.dumps(data),
        content_type='application/json'
    )
    print(f"POST /api/v1/projects/: {response.status_code}")
    assert response.status_code == 201
    
    # GET /api/v1/projects/
    response = client.get('/api/v1/projects/')
    print(f"GET /api/v1/projects/: {response.status_code}")
    assert response.status_code == 200
    
    # Test task endpoints
    print("\n--- Testing Task Endpoints ---")
    
    # POST /api/v1/tasks/
    data = {
        'title': 'Test Task',
        'description': 'Task for API testing',
        'project': 1,
        'status': 'todo',
        'priority': 'high',
    }
    response = client.post(
        '/api/v1/tasks/',
        data=json.dumps(data),
        content_type='application/json'
    )
    print(f"POST /api/v1/tasks/: {response.status_code}")
    assert response.status_code == 201
    
    # GET /api/v1/tasks/
    response = client.get('/api/v1/tasks/')
    print(f"GET /api/v1/tasks/: {response.status_code}")
    assert response.status_code == 200
    
    # GET /api/v1/projects/1/tasks/
    response = client.get('/api/v1/projects/1/tasks/')
    print(f"GET /api/v1/projects/1/tasks/: {response.status_code}")
    assert response.status_code == 200
    
    # Test comment endpoints
    print("\n--- Testing Comment Endpoints ---")
    
    # POST /api/v1/comments/
    data = {
        'content': 'Test comment',
        'task': 1,
    }
    response = client.post(
        '/api/v1/comments/',
        data=json.dumps(data),
        content_type='application/json'
    )
    print(f"POST /api/v1/comments/: {response.status_code}")
    assert response.status_code == 201
    
    # GET /api/v1/comments/
    response = client.get('/api/v1/comments/')
    print(f"GET /api/v1/comments/: {response.status_code}")
    assert response.status_code == 200
    
    # GET /api/v1/tasks/1/comments/
    response = client.get('/api/v1/tasks/1/comments/')
    print(f"GET /api/v1/tasks/1/comments/: {response.status_code}")
    assert response.status_code == 200
    
    # Test error handling
    print("\n--- Testing Error Handling ---")
    
    # GET /api/v1/users/999/ (non-existent user)
    response = client.get('/api/v1/users/999/')
    print(f"GET /api/v1/users/999/: {response.status_code}")
    assert response.status_code == 404
    
    # POST /api/v1/projects/ with invalid data
    data = {'name': ''}  # Empty name should fail
    response = client.post(
        '/api/v1/projects/',
        data=json.dumps(data),
        content_type='application/json'
    )
    print(f"POST /api/v1/projects/ (invalid): {response.status_code}")
    assert response.status_code == 400
    
    # PUT /api/v1/tasks/1/ with invalid data
    data = {'status': 'invalid_status'}  # Invalid status
    response = client.put(
        '/api/v1/tasks/1/',
        data=json.dumps(data),
        content_type='application/json'
    )
    print(f"PUT /api/v1/tasks/1/ (invalid): {response.status_code}")
    assert response.status_code == 400
    
    print("\n" + "=" * 50)
    print("✅ ALL API TESTS COMPLETED SUCCESSFULLY")
    print("=" * 50)


if __name__ == '__main__':
    test_api_endpoints()
```

Run the test script:

```bash
python test_api.py
```

### Step 3: View the API in Browser

Open your browser and navigate to:

- http://localhost:8000/api/v1/users/ - List of users (JSON)
- http://localhost:8000/api/v1/projects/ - List of projects (JSON)
- http://localhost:8000/api/v1/tasks/ - List of tasks (JSON)
- http://localhost:8000/api/v1/comments/ - List of comments (JSON)

---

## Key Takeaways

1. **API views handle HTTP requests and return HTTP responses.** They're the controllers of our application.

2. **Function-based views with `@api_view`** are simple and readable for CRUD operations.

3. **Each resource should have a consistent set of endpoints:**
   - List and create at the collection URL
   - Detail, update, and delete at the item URL

4. **Proper status codes are essential:**
   - 200 OK for successful GET, PUT, PATCH
   - 201 Created for successful POST
   - 204 No Content for successful DELETE
   - 400 Bad Request for validation errors
   - 404 Not Found for non-existent resources

5. **Nested endpoints** handle relationships (e.g., `/projects/1/tasks/`).

6. **Error handling** should be consistent and informative.

7. **The views and serializers work together:** views handle the request/response cycle, serializers handle data validation and transformation.

---

## Common View Patterns

### Pattern 1: List and Create

```python
@api_view(['GET', 'POST'])
def resource_list(request):
    if request.method == 'GET':
        resources = Resource.objects.all()
        serializer = ResourceSerializer(resources, many=True)
        return Response(serializer.data)
    
    if request.method == 'POST':
        serializer = ResourceCreateSerializer(data=request.data)
        if serializer.is_valid():
            resource = serializer.save()
            response_serializer = ResourceSerializer(resource)
            return Response(response_serializer.data, status=201)
        return Response(serializer.errors, status=400)
```

### Pattern 2: Detail, Update, Delete

```python
@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def resource_detail(request, pk):
    try:
        resource = Resource.objects.get(pk=pk)
    except Resource.DoesNotExist:
        return Response({'detail': 'Not found.'}, status=404)
    
    if request.method == 'GET':
        serializer = ResourceSerializer(resource)
        return Response(serializer.data)
    
    # ... update and delete
```

### Pattern 3: Nested Operations

```python
@api_view(['GET', 'POST'])
def parent_children(request, parent_pk):
    parent = Parent.objects.get(pk=parent_pk)
    
    if request.method == 'GET':
        children = parent.children.all()
        serializer = ChildSerializer(children, many=True)
        return Response(serializer.data)
    
    if request.method == 'POST':
        data = request.data.copy()
        data['parent'] = parent_pk
        serializer = ChildCreateSerializer(data=data)
        # ... validation and creation
```

---

## What's Next

In **Part 5**, we'll build our Next.js 16 frontend. You'll learn:

- Setting up Next.js 16 with the App Router
- Understanding Server Components and Client Components
- Creating layouts and pages
- Building the UI with React 19
- Setting up Tailwind CSS for styling

We'll create a modern, responsive frontend that will consume the API we've just built.

---

**End of Part 4**

*Next: Part 5 - Next.js 16 Foundations*
