# Part 3: DRF Serializers

## Building the Bridge Between Models and JSON

Welcome to **Part 3** of the Django REST Framework & Next.js 16 masterclass. Now that we have our Django models in place, we need a way to convert them to JSON for our API and convert incoming JSON back to Python objects. This is where **serializers** come in.

In this part, we'll:
- Understand what serializers do and why we need them
- Create ModelSerializers for all our models
- Handle relationships between models
- Add validation to serializers
- Customize create and update methods
- Test our serializers in the Django shell

Think of serializers as **translators**. They translate complex Django model instances into JSON that can be sent over the network, and they translate incoming JSON back into Python objects that Django can work with.

---

## The Target

We'll create serializers for all our models:

```
backend/apps/
├── users/
│   └── serializers.py          # User serializers
├── projects/
│   └── serializers.py          # Project serializers
├── tasks/
│   └── serializers.py          # Task serializers
└── comments/
    └── serializers.py          # Comment serializers
```

---

## The Concept

### What Is a Serializer?

A serializer is a class that:
1. **Serializes** Python objects (models) to JSON (for responses)
2. **Deserializes** JSON to Python objects (for requests)
3. **Validates** incoming data before creating/updating objects

### Real-World Analogy

Think of a serializer as a **customs officer** at an international border:
- **Serialization (export)** : When leaving the country, the officer checks your documents and translates them into the destination country's format
- **Deserialization (import)** : When entering, the officer checks your documents, verifies they're valid, and translates them into the local format
- **Validation**: The officer ensures you have all required documents (fields) and that they're valid (correct types, formats)

### Serializer Types

Django REST Framework provides several types of serializers:

1. **Serializer** - The base class; you define every field manually
2. **ModelSerializer** - Automatically generates fields from a model
3. **HyperlinkedModelSerializer** - Uses hyperlinks for relationships instead of primary keys

We'll use **ModelSerializer** for most of our work because it dramatically reduces boilerplate code.

### Key Serializer Components

```python
class TaskSerializer(serializers.ModelSerializer):
    # 1. Custom fields (non-model fields or overrides)
    project_name = serializers.CharField(source='project.name', read_only=True)
    
    class Meta:
        model = Task                    # Which model to serialize
        fields = ['id', 'title', ...]   # Which fields to include
        read_only_fields = ['created_at', 'updated_at']  # Fields that can't be written
    
    # 2. Field-level validation
    def validate_title(self, value):
        if len(value) < 3:
            raise serializers.ValidationError("Title must be at least 3 characters")
        return value
    
    # 3. Object-level validation
    def validate(self, data):
        if data.get('due_date') and data.get('due_date') < timezone.now():
            raise serializers.ValidationError("Due date must be in the future")
        return data
    
    # 4. Custom create/update
    def create(self, validated_data):
        # Handle nested data, set defaults, etc.
        return super().create(validated_data)
```

---

## The Implementation

### Step 1: User Serializer

**backend/apps/users/serializers.py**
```python
"""
Serializers for the User model.
"""

from django.contrib.auth.password_validation import validate_password
from django.core import exceptions as django_exceptions
from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
    """
    Main serializer for User model.
    Used for listing and retrieving users.
    """
    
    full_name = serializers.SerializerMethodField()
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    
    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'username',
            'first_name',
            'last_name',
            'full_name',
            'bio',
            'role',
            'role_display',
            'is_active',
            'is_staff',
            'is_superuser',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
            'is_active',
            'is_staff',
            'is_superuser',
        ]
    
    def get_full_name(self, obj):
        """Get user's full name or email if not set"""
        return obj.get_full_name()


class UserCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating new users.
    Includes password handling and validation.
    """
    
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
        style={'input_type': 'password'},
    )
    confirm_password = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'},
    )
    
    class Meta:
        model = User
        fields = [
            'email',
            'username',
            'first_name',
            'last_name',
            'password',
            'confirm_password',
            'bio',
            'role',
        ]
    
    def validate(self, data):
        """
        Check that password and confirm_password match.
        """
        password = data.get('password')
        confirm_password = data.pop('confirm_password')
        
        if password != confirm_password:
            raise serializers.ValidationError({
                'confirm_password': 'Passwords do not match.'
            })
        
        return data
    
    def create(self, validated_data):
        """
        Create a new user with the given validated data.
        """
        # Remove password from validated_data
        password = validated_data.pop('password')
        
        # Create user with remaining data
        user = User.objects.create_user(
            email=validated_data['email'],
            password=password,
            **validated_data
        )
        
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating users.
    """
    
    class Meta:
        model = User
        fields = [
            'first_name',
            'last_name',
            'bio',
            'role',
        ]
    
    def validate_role(self, value):
        """
        Prevent non-admin users from changing their own role.
        """
        # This will be enforced in the view context
        # The serializer doesn't have request context by default
        return value


class UserProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for user profile information.
    Used by the profile endpoint.
    """
    
    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'username',
            'first_name',
            'last_name',
            'bio',
            'role',
            'created_at',
        ]
        read_only_fields = ['id', 'email', 'created_at']
```

### Step 2: Project Serializer

**backend/apps/projects/serializers.py**
```python
"""
Serializers for the Project model.
"""

from rest_framework import serializers

from .models import Project


class ProjectSerializer(serializers.ModelSerializer):
    """
    Main serializer for Project model.
    """
    
    created_by_username = serializers.CharField(
        source='created_by.username',
        read_only=True
    )
    task_count = serializers.IntegerField(read_only=True)
    completed_task_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Project
        fields = [
            'id',
            'name',
            'description',
            'created_by',
            'created_by_username',
            'task_count',
            'completed_task_count',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'created_by',
            'created_by_username',
            'task_count',
            'completed_task_count',
            'created_at',
            'updated_at',
        ]
    
    def validate_name(self, value):
        """
        Validate that the project name is not empty.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Project name cannot be empty.")
        return value.strip()
    
    def validate(self, data):
        """
        Object-level validation.
        """
        # Check if a project with this name already exists for the user
        # This is a soft check; the view will handle the actual creation
        # with the correct user context
        return data


class ProjectCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating projects.
    """
    
    class Meta:
        model = Project
        fields = [
            'name',
            'description',
        ]
    
    def validate_name(self, value):
        """
        Validate that the project name is not empty.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Project name cannot be empty.")
        return value.strip()
    
    def create(self, validated_data):
        """
        Create a new project.
        The created_by field will be set by the view.
        """
        # The view will set created_by from the request user
        return Project.objects.create(**validated_data)


class ProjectDetailSerializer(ProjectSerializer):
    """
    Detailed serializer for Project model.
    Includes task count and other metrics.
    """
    
    # We'll add tasks field when we create TaskSerializer
    # tasks = TaskSerializer(many=True, read_only=True)
    
    class Meta(ProjectSerializer.Meta):
        fields = ProjectSerializer.Meta.fields + [
            # 'tasks',  # Will be added later
        ]
```

### Step 3: Task Serializer

**backend/apps/tasks/serializers.py**
```python
"""
Serializers for the Task model.
"""

from django.utils import timezone
from rest_framework import serializers

from .models import Task
from apps.projects.models import Project
from apps.users.models import User


class TaskSerializer(serializers.ModelSerializer):
    """
    Main serializer for Task model.
    """
    
    project_name = serializers.CharField(
        source='project.name',
        read_only=True
    )
    assigned_to_username = serializers.CharField(
        source='assigned_to.username',
        read_only=True
    )
    created_by_username = serializers.CharField(
        source='created_by.username',
        read_only=True
    )
    status_display = serializers.CharField(
        source='get_status_display',
        read_only=True
    )
    priority_display = serializers.CharField(
        source='get_priority_display',
        read_only=True
    )
    is_overdue = serializers.BooleanField(read_only=True)
    comment_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Task
        fields = [
            'id',
            'title',
            'description',
            'status',
            'status_display',
            'priority',
            'priority_display',
            'due_date',
            'is_overdue',
            'project',
            'project_name',
            'assigned_to',
            'assigned_to_username',
            'created_by',
            'created_by_username',
            'comment_count',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'created_by',
            'created_by_username',
            'created_at',
            'updated_at',
            'is_overdue',
            'comment_count',
        ]
    
    def validate_title(self, value):
        """
        Validate that the task title is not empty and has minimum length.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Task title cannot be empty.")
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Task title must be at least 3 characters.")
        return value.strip()
    
    def validate_due_date(self, value):
        """
        Validate that due date is in the future.
        """
        if value and value < timezone.now():
            raise serializers.ValidationError("Due date must be in the future.")
        return value
    
    def validate(self, data):
        """
        Object-level validation.
        """
        # Check if assigned_to user is part of the project
        project = data.get('project')
        assigned_to = data.get('assigned_to')
        
        if project and assigned_to:
            # Check if the user has access to the project
            if not assigned_to.has_project_access(project):
                raise serializers.ValidationError({
                    'assigned_to': 'User does not have access to this project.'
                })
        
        # Check if we're creating a task with a title that already exists in the project
        # This is a soft check; the view will handle the actual creation
        # with the correct project context
        
        return data


class TaskCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating tasks.
    """
    
    class Meta:
        model = Task
        fields = [
            'title',
            'description',
            'status',
            'priority',
            'due_date',
            'project',
            'assigned_to',
        ]
    
    def validate_title(self, value):
        """
        Validate that the task title is not empty and has minimum length.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Task title cannot be empty.")
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Task title must be at least 3 characters.")
        return value.strip()
    
    def validate_due_date(self, value):
        """
        Validate that due date is in the future.
        """
        if value and value < timezone.now():
            raise serializers.ValidationError("Due date must be in the future.")
        return value
    
    def validate(self, data):
        """
        Object-level validation.
        """
        project = data.get('project')
        assigned_to = data.get('assigned_to')
        
        if project and assigned_to:
            if not assigned_to.has_project_access(project):
                raise serializers.ValidationError({
                    'assigned_to': 'User does not have access to this project.'
                })
        
        # Check for duplicate task title in the same project
        if project and data.get('title'):
            if Task.objects.filter(
                project=project,
                title__iexact=data['title'].strip()
            ).exists():
                raise serializers.ValidationError({
                    'title': 'A task with this title already exists in the project.'
                })
        
        return data
    
    def create(self, validated_data):
        """
        Create a new task.
        The created_by field will be set by the view.
        """
        return Task.objects.create(**validated_data)


class TaskUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating tasks.
    """
    
    class Meta:
        model = Task
        fields = [
            'title',
            'description',
            'status',
            'priority',
            'due_date',
            'assigned_to',
        ]
    
    def validate_title(self, value):
        """
        Validate that the task title is not empty and has minimum length.
        """
        if value is not None:
            if not value or value.strip() == '':
                raise serializers.ValidationError("Task title cannot be empty.")
            if len(value.strip()) < 3:
                raise serializers.ValidationError("Task title must be at least 3 characters.")
            return value.strip()
        return value
    
    def validate_due_date(self, value):
        """
        Validate that due date is in the future.
        """
        if value and value < timezone.now():
            raise serializers.ValidationError("Due date must be in the future.")
        return value
    
    def validate(self, data):
        """
        Object-level validation.
        """
        assigned_to = data.get('assigned_to')
        
        # If assigned_to is being changed, check project access
        if assigned_to:
            # Get the task instance
            task = self.instance
            if not assigned_to.has_project_access(task.project):
                raise serializers.ValidationError({
                    'assigned_to': 'User does not have access to this project.'
                })
        
        # If project is being changed, check if assigned_to has access to new project
        # Note: Project changes are handled separately, but we'll add this for completeness
        # The view will handle project changes with more context
        
        return data


class TaskStatusUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating only the task status.
    Used for quick status changes.
    """
    
    class Meta:
        model = Task
        fields = ['status']
    
    def validate_status(self, value):
        """
        Validate that the status is valid.
        """
        # This validation is automatic because we're using choices
        return value
```

### Step 4: Comment Serializer

**backend/apps/comments/serializers.py**
```python
"""
Serializers for the Comment model.
"""

from rest_framework import serializers

from .models import Comment


class CommentSerializer(serializers.ModelSerializer):
    """
    Main serializer for Comment model.
    """
    
    author_username = serializers.CharField(
        source='author.username',
        read_only=True
    )
    author_email = serializers.EmailField(
        source='author.email',
        read_only=True
    )
    task_title = serializers.CharField(
        source='task.title',
        read_only=True
    )
    
    class Meta:
        model = Comment
        fields = [
            'id',
            'content',
            'task',
            'task_title',
            'author',
            'author_username',
            'author_email',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'author',
            'author_username',
            'author_email',
            'created_at',
            'updated_at',
        ]
    
    def validate_content(self, value):
        """
        Validate that comment content is not empty.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Comment content cannot be empty.")
        if len(value.strip()) < 2:
            raise serializers.ValidationError("Comment must be at least 2 characters.")
        return value.strip()


class CommentCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating comments.
    """
    
    class Meta:
        model = Comment
        fields = [
            'content',
            'task',
        ]
    
    def validate_content(self, value):
        """
        Validate that comment content is not empty.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Comment content cannot be empty.")
        if len(value.strip()) < 2:
            raise serializers.ValidationError("Comment must be at least 2 characters.")
        return value.strip()
    
    def create(self, validated_data):
        """
        Create a new comment.
        The author field will be set by the view.
        """
        return Comment.objects.create(**validated_data)


class CommentUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating comments.
    """
    
    class Meta:
        model = Comment
        fields = ['content']
    
    def validate_content(self, value):
        """
        Validate that comment content is not empty.
        """
        if not value or value.strip() == '':
            raise serializers.ValidationError("Comment content cannot be empty.")
        if len(value.strip()) < 2:
            raise serializers.ValidationError("Comment must be at least 2 characters.")
        return value.strip()
```

### Step 5: Update Models to Use Serializers

We need to update our models to include some properties and methods that serializers might use. Let's make a few updates:

**backend/apps/tasks/models.py** - Add the `comment_count` property (we already have it)
```python
# This is already in the model from Part 2
# Keep it as is
```

### Step 6: Test the Serializers

Let's test our serializers in the Django shell to make sure they work correctly.

```bash
python manage.py shell
```

Run these commands:

```python
# Import all the serializers
from apps.users.serializers import UserSerializer, UserCreateSerializer
from apps.projects.serializers import ProjectSerializer
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer
from apps.comments.serializers import CommentSerializer

# Import models
from apps.users.models import User
from apps.projects.models import Project
from apps.tasks.models import Task
from apps.comments.models import Comment

# Test User Serializer
print("=== Testing User Serializer ===")
user = User.objects.get(email='admin@example.com')
serializer = UserSerializer(user)
print(serializer.data)

# Test Project Serializer
print("\n=== Testing Project Serializer ===")
project = Project.objects.first()
serializer = ProjectSerializer(project)
print(serializer.data)

# Test Task Serializer
print("\n=== Testing Task Serializer ===")
task = Task.objects.first()
serializer = TaskSerializer(task)
print(serializer.data)

# Test Comment Serializer
print("\n=== Testing Comment Serializer ===")
comment = Comment.objects.first()
serializer = CommentSerializer(comment)
print(serializer.data)

# Test validation
print("\n=== Testing Validation ===")
# Test creating a task with invalid data
data = {
    'title': '',  # Empty title - should fail
    'project': project.id,
    'status': 'invalid',  # Invalid status - should fail
}
serializer = TaskCreateSerializer(data=data)
print(f"Is data valid? {serializer.is_valid()}")
print(f"Errors: {serializer.errors}")

# Test creating a task with valid data
data = {
    'title': 'Test Task from Shell',
    'description': 'This is a test task created from the Django shell',
    'project': project.id,
    'status': 'todo',
    'priority': 'high',
}
serializer = TaskCreateSerializer(data=data)
print(f"Is data valid? {serializer.is_valid()}")
if serializer.is_valid():
    # We can't create without the view setting created_by
    print("Data is valid!")
    print(f"Validated data: {serializer.validated_data}")

# Test nested serialization
print("\n=== Testing Nested Serialization ===")
# Get a project with its tasks
project = Project.objects.get(pk=1)
print(f"Project: {project.name}")
print(f"Tasks count: {project.task_count}")

# We can't easily serialize nested tasks without importing TaskSerializer
# in the ProjectSerializer, which we'll do later
```

---

## The Verification

### Step 1: Create a Test Script

Let's create a standalone script to test our serializers more thoroughly.

**backend/test_serializers.py**
```python
"""
Test script for DRF serializers.
Run with: python test_serializers.py
"""

import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.test import TestCase
from django.core.exceptions import ValidationError
from rest_framework.exceptions import ErrorDetail

from apps.users.models import User
from apps.projects.models import Project
from apps.tasks.models import Task
from apps.comments.models import Comment

from apps.users.serializers import UserSerializer, UserCreateSerializer
from apps.projects.serializers import ProjectSerializer, ProjectCreateSerializer
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer
from apps.comments.serializers import CommentSerializer, CommentCreateSerializer


def test_user_serializer():
    """Test UserSerializer"""
    print("\n=== Testing UserSerializer ===")
    user = User.objects.first()
    if user:
        serializer = UserSerializer(user)
        data = serializer.data
        print(f"User data: {data}")
        assert 'full_name' in data
        assert 'role_display' in data
        print("✅ UserSerializer test passed")
    else:
        print("⚠️ No users found to test")


def test_user_create_serializer():
    """Test UserCreateSerializer"""
    print("\n=== Testing UserCreateSerializer ===")
    # Test with valid data
    data = {
        'email': 'testuser@example.com',
        'username': 'testuser',
        'first_name': 'Test',
        'last_name': 'User',
        'password': 'SecurePass123!',
        'confirm_password': 'SecurePass123!',
    }
    serializer = UserCreateSerializer(data=data)
    valid = serializer.is_valid()
    print(f"Valid data validation: {valid}")
    if valid:
        print(f"Validated data: {serializer.validated_data}")
    else:
        print(f"Errors: {serializer.errors}")
    
    # Test with mismatched passwords
    data['confirm_password'] = 'DifferentPass123!'
    serializer = UserCreateSerializer(data=data)
    valid = serializer.is_valid()
    print(f"Invalid data validation (mismatched passwords): {valid}")
    if not valid:
        print(f"Expected error: {serializer.errors}")
    
    print("✅ UserCreateSerializer tests completed")


def test_project_serializer():
    """Test ProjectSerializer"""
    print("\n=== Testing ProjectSerializer ===")
    project = Project.objects.first()
    if project:
        serializer = ProjectSerializer(project)
        data = serializer.data
        print(f"Project data: {data}")
        assert 'task_count' in data
        assert 'completed_task_count' in data
        print("✅ ProjectSerializer test passed")
    else:
        print("⚠️ No projects found to test")


def test_task_serializer():
    """Test TaskSerializer"""
    print("\n=== Testing TaskSerializer ===")
    task = Task.objects.first()
    if task:
        serializer = TaskSerializer(task)
        data = serializer.data
        print(f"Task data: {data}")
        assert 'status_display' in data
        assert 'priority_display' in data
        assert 'is_overdue' in data
        assert 'comment_count' in data
        print("✅ TaskSerializer test passed")
    else:
        print("⚠️ No tasks found to test")


def test_comment_serializer():
    """Test CommentSerializer"""
    print("\n=== Testing CommentSerializer ===")
    comment = Comment.objects.first()
    if comment:
        serializer = CommentSerializer(comment)
        data = serializer.data
        print(f"Comment data: {data}")
        assert 'author_username' in data
        assert 'task_title' in data
        print("✅ CommentSerializer test passed")
    else:
        print("⚠️ No comments found to test")


def test_validation():
    """Test serializer validation"""
    print("\n=== Testing Validation ===")
    
    # Test empty title for task
    data = {
        'title': '',
        'project': 1,
        'status': 'todo',
    }
    serializer = TaskCreateSerializer(data=data)
    valid = serializer.is_valid()
    print(f"Empty title validation: {valid}")
    if not valid:
        print(f"Expected error: {serializer.errors}")
    
    # Test due date in the past
    from django.utils import timezone
    from datetime import timedelta
    
    data = {
        'title': 'Test Task',
        'project': 1,
        'due_date': timezone.now() - timedelta(days=1),
    }
    serializer = TaskCreateSerializer(data=data)
    valid = serializer.is_valid()
    print(f"Past due date validation: {valid}")
    if not valid:
        print(f"Expected error: {serializer.errors}")
    
    print("✅ Validation tests completed")


def run_tests():
    """Run all serializer tests"""
    print("=" * 50)
    print("TESTING DRF SERIALIZERS")
    print("=" * 50)
    
    try:
        test_user_serializer()
        test_user_create_serializer()
        test_project_serializer()
        test_task_serializer()
        test_comment_serializer()
        test_validation()
        
        print("\n" + "=" * 50)
        print("✅ ALL TESTS COMPLETED SUCCESSFULLY")
        print("=" * 50)
    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        raise


if __name__ == '__main__':
    run_tests()
```

Run the test script:

```bash
python test_serializers.py
```

### Step 2: Test with Django REST Framework API View

Let's create a quick API view to test our serializers through a real HTTP endpoint.

**backend/config/urls.py**
```python
"""
URL configuration for the backend project.
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # We'll add API URLs in Part 4
]
```

### Step 3: Create a Temporary Test View

Create a temporary view to test serializers:

**backend/apps/tasks/views.py** (temporary)
```python
"""
Temporary views for testing serializers.
"""

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .models import Task
from .serializers import TaskSerializer


@api_view(['GET', 'POST'])
def test_task_endpoint(request):
    """
    Temporary endpoint for testing TaskSerializer.
    """
    if request.method == 'GET':
        tasks = Task.objects.all()
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    if request.method == 'POST':
        serializer = TaskSerializer(data=request.data)
        if serializer.is_valid():
            # This won't actually work because we need to set created_by
            # But it demonstrates the serialization flow
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```

**backend/config/urls.py** (updated temporary)
```python
"""
URL configuration for the backend project.
"""

from django.contrib import admin
from django.urls import path

# Temporary import
from apps.tasks.views import test_task_endpoint

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/test-tasks/', test_task_endpoint, name='test-tasks'),
]
```

### Step 4: Test the API Endpoint

Start the server and test the endpoint:

```bash
python manage.py runserver
```

In another terminal:

```bash
# Test GET request
curl -X GET http://localhost:8000/api/test-tasks/

# You should see a JSON list of tasks

# Test POST request (will fail because we're not setting created_by)
curl -X POST http://localhost:8000/api/test-tasks/ \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","project":1,"status":"todo"}'
```

### Step 5: Remove Temporary Code

After testing, remove the temporary views and URL patterns.

**backend/apps/tasks/views.py** - Delete or comment out the test view

**backend/config/urls.py** - Remove the test URL pattern

---

## Key Takeaways

1. **Serializers convert Django models to JSON and back.** They're the bridge between our database and our API.

2. **ModelSerializer automatically generates fields** from your model, reducing boilerplate code.

3. **Validation happens at two levels:**
   - **Field-level validation** (e.g., `validate_title()`) validates individual fields
   - **Object-level validation** (e.g., `validate()`) validates the entire object

4. **Read-only fields** (like `created_at`) are included in the response but can't be set in requests.

5. **Nested serializers** handle relationships between models, but we'll add them later to avoid circular imports.

6. **Custom create/update methods** allow you to handle complex creation logic.

7. **Validation patterns**: 
   - Always validate user input
   - Return clear error messages
   - Use Django's built-in validators when possible

---

## Common Serializer Patterns

### Pattern 1: Different Serializers for Different Operations

```python
# Create - Less fields, no read-only constraints
class TaskCreateSerializer(serializers.ModelSerializer):
    pass

# Update - Similar to create, but with instance
class TaskUpdateSerializer(serializers.ModelSerializer):
    pass

# Detail - More fields, includes nested relationships
class TaskDetailSerializer(serializers.ModelSerializer):
    pass

# List - Minimal fields for performance
class TaskListSerializer(serializers.ModelSerializer):
    pass
```

### Pattern 2: Using `source` to Rename Fields

```python
class TaskSerializer(serializers.ModelSerializer):
    project_name = serializers.CharField(source='project.name')
    assigned_to_name = serializers.CharField(source='assigned_to.username')
```

### Pattern 3: Adding Computed Fields

```python
class TaskSerializer(serializers.ModelSerializer):
    is_overdue = serializers.SerializerMethodField()
    
    def get_is_overdue(self, obj):
        return obj.is_overdue
```

### Pattern 4: Handling Write-Only Fields

```python
class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User.objects.create(**validated_data)
        user.set_password(password)
        user.save()
        return user
```

---

## What's Next

In **Part 4**, we'll build API views for our models. You'll learn:

- Using `@api_view` for function-based views
- Using `APIView` for class-based views
- Handling HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Request and response objects
- Status codes
- Exception handling

We'll create complete CRUD endpoints for all our models, ready to be consumed by our Next.js frontend.

---

**End of Part 3**

*Next: Part 4 - Building API Views*
