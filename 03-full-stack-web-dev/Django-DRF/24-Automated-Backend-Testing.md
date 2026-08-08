# Part 24: Automated Backend Testing

## Building a Comprehensive Test Suite

Welcome to **Part 24** of the Django REST Framework & Next.js 16 masterclass. Now that our application is optimized, it's time to ensure it works correctly through comprehensive testing. We'll build a complete test suite covering models, serializers, views, permissions, and integrations.

In this part, we'll:
- Set up pytest and pytest-django
- Write model tests
- Create serializer tests
- Build API view tests
- Test permissions and authentication
- Implement integration tests
- Generate coverage reports

Think of tests as your **safety net**. Just as a trapeze artist practices with a net below, your tests catch bugs before they reach production, ensuring your application works as expected.

---

## The Target

We'll build a comprehensive test suite:

```
backend/tests/
├── conftest.py                 # pytest fixtures
├── test_models/
│   ├── test_user.py
│   ├── test_project.py
│   ├── test_task.py
│   └── test_comment.py
├── test_serializers/
│   ├── test_user_serializer.py
│   ├── test_project_serializer.py
│   ├── test_task_serializer.py
│   └── test_comment_serializer.py
├── test_views/
│   ├── test_user_views.py
│   ├── test_project_views.py
│   ├── test_task_views.py
│   └── test_comment_views.py
├── test_permissions/
│   ├── test_project_permissions.py
│   └── test_task_permissions.py
└── test_integration/
    └── test_api_flow.py
```

---

## The Concept

### Testing Pyramid

```
┌─────────────────────────────────────────────────────────────┐
│                     Testing Pyramid                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│                  ┌──────────┐                                │
│                  │  E2E     │  Few                           │
│                  │  Tests   │  Slow, comprehensive          │
│               ┌──┴──────────┴──┐                            │
│               │  Integration   │  Some                       │
│               │  Tests         │  Medium speed               │
│            ┌──┴────────────────┴──┐                         │
│            │     Unit Tests       │  Many                    │
│            │                      │  Fast, focused          │
│            └──────────────────────┘                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Test Types

| Type | Purpose | Tools |
|------|---------|-------|
| **Unit Tests** | Test individual components | pytest, unittest |
| **Integration Tests** | Test component interactions | pytest, DRF APIClient |
| **API Tests** | Test endpoints | DRF APIClient |
| **E2E Tests** | Test full user flows | Playwright, Cypress |

### Test Fixtures

Fixtures provide reusable test data:

```python
@pytest.fixture
def user():
    return User.objects.create_user(
        email='test@example.com',
        username='testuser',
        password='testpass123'
    )

@pytest.fixture
def api_client(user):
    client = APIClient()
    client.force_authenticate(user=user)
    return client
```

---

## The Implementation

### Step 1: Install Testing Dependencies

```bash
cd backend
source venv/bin/activate
pip install pytest pytest-django pytest-cov factory-boy faker
pip install django-extensions

echo "pytest>=8.0.0" >> requirements/development.txt
echo "pytest-django>=4.8.0" >> requirements/development.txt
echo "pytest-cov>=4.0.0" >> requirements/development.txt
echo "factory-boy>=3.3.0" >> requirements/development.txt
echo "faker>=20.0.0" >> requirements/development.txt
```

### Step 2: Configure pytest

**backend/pytest.ini** (create)

```ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = test_*.py *_test.py
testpaths = tests
addopts = 
    --verbose
    --cov=apps
    --cov-report=html
    --cov-report=term
    --cov-fail-under=70
    -p no:warnings
```

### Step 3: Create Conftest with Fixtures

**backend/tests/conftest.py** (create)

```python
"""
pytest fixtures for all tests.
"""

import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from django.core.cache import cache
from rest_framework_simplejwt.tokens import RefreshToken

from apps.projects.models import Project
from apps.tasks.models import Task
from apps.comments.models import Comment

User = get_user_model()


@pytest.fixture
def user():
    """Create a regular user."""
    return User.objects.create_user(
        email='user@example.com',
        username='testuser',
        first_name='Test',
        last_name='User',
        password='testpass123'
    )


@pytest.fixture
def admin_user():
    """Create an admin user."""
    return User.objects.create_superuser(
        email='admin@example.com',
        username='admin',
        password='adminpass123'
    )


@pytest.fixture
def manager_user():
    """Create a manager user."""
    return User.objects.create_user(
        email='manager@example.com',
        username='manager',
        first_name='Manager',
        last_name='User',
        password='managerpass123',
        role='manager'
    )


@pytest.fixture
def api_client():
    """Return an unauthenticated API client."""
    return APIClient()


@pytest.fixture
def auth_client(user):
    """Return an authenticated API client."""
    client = APIClient()
    client.force_authenticate(user=user)
    return client


@pytest.fixture
def admin_client(admin_user):
    """Return an admin authenticated API client."""
    client = APIClient()
    client.force_authenticate(user=admin_user)
    return client


@pytest.fixture
def manager_client(manager_user):
    """Return a manager authenticated API client."""
    client = APIClient()
    client.force_authenticate(user=manager_user)
    return client


@pytest.fixture
def jwt_token(user):
    """Get JWT token for user."""
    refresh = RefreshToken.for_user(user)
    return {
        'access': str(refresh.access_token),
        'refresh': str(refresh),
    }


@pytest.fixture
def project(user):
    """Create a project."""
    return Project.objects.create(
        name='Test Project',
        description='Test project description',
        created_by=user
    )


@pytest.fixture
def task(user, project):
    """Create a task."""
    return Task.objects.create(
        title='Test Task',
        description='Test task description',
        status='todo',
        priority='high',
        project=project,
        created_by=user,
        assigned_to=user
    )


@pytest.fixture
def comment(user, task):
    """Create a comment."""
    return Comment.objects.create(
        content='Test comment',
        task=task,
        author=user
    )


@pytest.fixture(autouse=True)
def clear_cache():
    """Clear cache before each test."""
    cache.clear()
    yield


@pytest.fixture
def sample_data(user):
    """Create sample data for integration tests."""
    projects = []
    for i in range(3):
        project = Project.objects.create(
            name=f'Project {i}',
            description=f'Description {i}',
            created_by=user
        )
        projects.append(project)
        
        for j in range(3):
            Task.objects.create(
                title=f'Task {i}-{j}',
                description=f'Task description {i}-{j}',
                status='todo',
                priority='medium',
                project=project,
                created_by=user,
                assigned_to=user
            )
    
    return {'projects': projects}
```

### Step 4: Create Model Tests

**backend/tests/test_models/test_user.py** (create)

```python
"""
Tests for User model.
"""

import pytest
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError

User = get_user_model()


@pytest.mark.django_db
class TestUserModel:
    def test_create_user(self):
        """Test creating a regular user."""
        user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='testpass123'
        )
        assert user.email == 'test@example.com'
        assert user.username == 'testuser'
        assert user.is_active
        assert not user.is_staff
        assert not user.is_superuser
        assert user.role == 'member'

    def test_create_superuser(self):
        """Test creating a superuser."""
        admin = User.objects.create_superuser(
            email='admin@example.com',
            username='admin',
            password='adminpass123'
        )
        assert admin.is_superuser
        assert admin.is_staff
        assert admin.role == 'admin'

    def test_user_str(self):
        """Test string representation."""
        user = User.objects.create_user(
            email='test@example.com',
            username='testuser'
        )
        assert str(user) == 'test@example.com'

    def test_get_full_name(self):
        """Test getting full name."""
        user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            first_name='Test',
            last_name='User'
        )
        assert user.get_full_name() == 'Test User'
        
        user.first_name = ''
        user.last_name = ''
        assert user.get_full_name() == 'test@example.com'

    def test_is_admin_property(self):
        """Test is_admin property."""
        admin = User.objects.create_superuser(
            email='admin@example.com',
            username='admin',
            password='adminpass123'
        )
        assert admin.is_admin
        
        user = User.objects.create_user(
            email='user@example.com',
            username='user',
            password='pass123'
        )
        assert not user.is_admin

    def test_has_project_access(self, user, project):
        """Test project access check."""
        # User created the project
        assert user.has_project_access(project)
        
        # Another user doesn't have access
        other_user = User.objects.create_user(
            email='other@example.com',
            username='otheruser',
            password='pass123'
        )
        assert not other_user.has_project_access(project)
        
        # Assign other_user to a task in the project
        from apps.tasks.models import Task
        Task.objects.create(
            title='Task',
            project=project,
            created_by=user,
            assigned_to=other_user
        )
        assert other_user.has_project_access(project)
```

**backend/tests/test_models/test_task.py** (create)

```python
"""
Tests for Task model.
"""

import pytest
from django.utils import timezone
from datetime import timedelta
from apps.tasks.models import Task


@pytest.mark.django_db
class TestTaskModel:
    def test_create_task(self, user, project):
        """Test creating a task."""
        task = Task.objects.create(
            title='Test Task',
            description='Test description',
            status='todo',
            priority='high',
            project=project,
            created_by=user,
            assigned_to=user
        )
        assert task.title == 'Test Task'
        assert task.status == 'todo'
        assert task.priority == 'high'
        assert task.created_by == user
        assert task.assigned_to == user

    def test_task_str(self, task):
        """Test string representation."""
        assert str(task) == f"{task.title} ({task.project.name})"

    def test_is_overdue(self, user, project):
        """Test is_overdue property."""
        # Past due date
        past_due = Task.objects.create(
            title='Past Due Task',
            project=project,
            created_by=user,
            due_date=timezone.now() - timedelta(days=1),
            status='todo'
        )
        assert past_due.is_overdue
        
        # Future due date
        future_due = Task.objects.create(
            title='Future Due Task',
            project=project,
            created_by=user,
            due_date=timezone.now() + timedelta(days=1),
            status='todo'
        )
        assert not future_due.is_overdue
        
        # Completed task shouldn't be overdue even if past due
        completed = Task.objects.create(
            title='Completed Task',
            project=project,
            created_by=user,
            due_date=timezone.now() - timedelta(days=1),
            status='done'
        )
        assert not completed.is_overdue

    def test_comment_count(self, task, user):
        """Test comment_count property."""
        assert task.comment_count == 0
        
        from apps.comments.models import Comment
        Comment.objects.create(
            content='Test comment',
            task=task,
            author=user
        )
        assert task.comment_count == 1
```

### Step 5: Create Serializer Tests

**backend/tests/test_serializers/test_task_serializer.py** (create)

```python
"""
Tests for Task serializers.
"""

import pytest
from django.utils import timezone
from datetime import timedelta
from apps.tasks.serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskUpdateSerializer,
    TaskStatusUpdateSerializer,
)
from apps.tasks.models import Task


@pytest.mark.django_db
class TestTaskSerializer:
    def test_task_serializer_fields(self, task):
        """Test TaskSerializer fields."""
        serializer = TaskSerializer(task)
        data = serializer.data
        
        expected_fields = [
            'id', 'title', 'description', 'status', 'status_display',
            'priority', 'priority_display', 'due_date', 'is_overdue',
            'project', 'project_name', 'assigned_to', 'assigned_to_username',
            'created_by', 'created_by_username', 'comment_count',
            'created_at', 'updated_at'
        ]
        for field in expected_fields:
            assert field in data

    def test_task_create_serializer_valid_data(self, user, project):
        """Test TaskCreateSerializer with valid data."""
        data = {
            'title': 'New Task',
            'description': 'New task description',
            'status': 'todo',
            'priority': 'high',
            'project': project.id,
            'assigned_to': user.id,
        }
        serializer = TaskCreateSerializer(data=data)
        assert serializer.is_valid()
        
        task = serializer.save(created_by=user)
        assert task.title == 'New Task'
        assert task.created_by == user

    def test_task_create_serializer_invalid_title(self, user, project):
        """Test TaskCreateSerializer with invalid title."""
        data = {
            'title': '',
            'project': project.id,
        }
        serializer = TaskCreateSerializer(data=data)
        assert not serializer.is_valid()
        assert 'title' in serializer.errors

    def test_task_update_serializer(self, task, user):
        """Test TaskUpdateSerializer."""
        data = {
            'title': 'Updated Title',
            'status': 'in_progress',
        }
        serializer = TaskUpdateSerializer(task, data=data, partial=True)
        assert serializer.is_valid()
        
        updated_task = serializer.save()
        assert updated_task.title == 'Updated Title'
        assert updated_task.status == 'in_progress'

    def test_task_status_update_serializer(self, task):
        """Test TaskStatusUpdateSerializer."""
        data = {'status': 'done'}
        serializer = TaskStatusUpdateSerializer(task, data=data)
        assert serializer.is_valid()
        
        updated_task = serializer.save()
        assert updated_task.status == 'done'
        
        # Invalid status
        data = {'status': 'invalid'}
        serializer = TaskStatusUpdateSerializer(task, data=data)
        assert not serializer.is_valid()
```

### Step 6: Create View Tests

**backend/tests/test_views/test_task_views.py** (create)

```python
"""
Tests for Task API views.
"""

import pytest
from django.urls import reverse
from rest_framework import status
from apps.tasks.models import Task


@pytest.mark.django_db
class TestTaskViews:
    def test_list_tasks_unauthenticated(self, api_client):
        """Test that unauthenticated users cannot list tasks."""
        url = reverse('task-list')
        response = api_client.get(url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_list_tasks_authenticated(self, auth_client, task):
        """Test that authenticated users can list tasks."""
        url = reverse('task-list')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) >= 1

    def test_create_task(self, auth_client, user, project):
        """Test creating a task."""
        url = reverse('task-list')
        data = {
            'title': 'New Test Task',
            'description': 'Test description',
            'status': 'todo',
            'priority': 'high',
            'project': project.id,
            'assigned_to': user.id,
        }
        response = auth_client.post(url, data)
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['title'] == 'New Test Task'
        assert response.data['created_by_username'] == user.username

    def test_retrieve_task(self, auth_client, task):
        """Test retrieving a single task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['id'] == task.id
        assert response.data['title'] == task.title

    def test_update_task(self, auth_client, task):
        """Test updating a task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated Task Title'}
        response = auth_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['title'] == 'Updated Task Title'

    def test_delete_task(self, auth_client, task):
        """Test deleting a task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        response = auth_client.delete(url)
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Task should be deleted
        assert not Task.objects.filter(id=task.id).exists()

    def test_update_task_status(self, auth_client, task):
        """Test updating task status via custom endpoint."""
        url = reverse('task-status', kwargs={'pk': task.id})
        data = {'status': 'in_progress'}
        response = auth_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['status'] == 'in_progress'

    def test_task_stats(self, auth_client, task):
        """Test task statistics endpoint."""
        url = reverse('task-stats')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert 'total' in response.data
        assert 'todo' in response.data
        assert 'in_progress' in response.data
        assert 'done' in response.data
```

### Step 7: Create Permission Tests

**backend/tests/test_permissions/test_task_permissions.py** (create)

```python
"""
Tests for Task permissions.
"""

import pytest
from django.urls import reverse
from rest_framework import status
from apps.tasks.models import Task


@pytest.mark.django_db
class TestTaskPermissions:
    def test_owner_can_edit_task(self, auth_client, task):
        """Test that task owner can edit their task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated by Owner'}
        response = auth_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK

    def test_non_owner_cannot_edit_task(self, user, task):
        """Test that non-owner cannot edit a task."""
        from rest_framework.test import APIClient
        other_client = APIClient()
        other_client.force_authenticate(user=user)
        
        # Task is owned by a different user
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Attempted Update'}
        response = other_client.patch(url, data)
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_owner_can_delete_task(self, auth_client, task):
        """Test that task owner can delete their task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        response = auth_client.delete(url)
        assert response.status_code == status.HTTP_204_NO_CONTENT

    def test_admin_can_edit_any_task(self, admin_client, task):
        """Test that admin can edit any task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated by Admin'}
        response = admin_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK

    def test_assignee_can_edit_task(self, user, task):
        """Test that task assignee can edit the task."""
        # Assign another user to the task
        from rest_framework.test import APIClient
        another_user = User.objects.create_user(
            email='assignee@example.com',
            username='assignee',
            password='pass123'
        )
        task.assigned_to = another_user
        task.save()
        
        assignee_client = APIClient()
        assignee_client.force_authenticate(user=another_user)
        
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated by Assignee'}
        response = assignee_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK
```

### Step 8: Create Integration Tests

**backend/tests/test_integration/test_api_flow.py** (create)

```python
"""
Integration tests for complete API flows.
"""

import pytest
from django.urls import reverse
from rest_framework import status
from apps.projects.models import Project
from apps.tasks.models import Task
from apps.comments.models import Comment


@pytest.mark.django_db
class TestAPIWorkflow:
    def test_complete_workflow(self, auth_client, user):
        """
        Test a complete workflow:
        1. Create project
        2. Create task in project
        3. Add comment to task
        4. Update task status
        5. Delete task
        """
        # 1. Create project
        project_url = reverse('project-list')
        project_data = {
            'name': 'Workflow Test Project',
            'description': 'Testing complete workflow',
        }
        response = auth_client.post(project_url, project_data)
        assert response.status_code == status.HTTP_201_CREATED
        project_id = response.data['id']
        
        # 2. Create task in project
        task_url = reverse('task-list')
        task_data = {
            'title': 'Workflow Test Task',
            'description': 'Task for workflow testing',
            'status': 'todo',
            'priority': 'high',
            'project': project_id,
            'assigned_to': user.id,
        }
        response = auth_client.post(task_url, task_data)
        assert response.status_code == status.HTTP_201_CREATED
        task_id = response.data['id']
        
        # Verify task was created
        task = Task.objects.get(id=task_id)
        assert task.title == 'Workflow Test Task'
        assert task.project.id == project_id
        
        # 3. Add comment to task
        comment_url = reverse('comment-list')
        comment_data = {
            'content': 'Test comment on workflow task',
            'task': task_id,
        }
        response = auth_client.post(comment_url, comment_data)
        assert response.status_code == status.HTTP_201_CREATED
        
        # Verify comment was created
        comment = Comment.objects.get(task_id=task_id)
        assert comment.content == 'Test comment on workflow task'
        assert comment.author == user
        
        # 4. Update task status
        status_url = reverse('task-status', kwargs={'pk': task_id})
        status_data = {'status': 'in_progress'}
        response = auth_client.patch(status_url, status_data)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['status'] == 'in_progress'
        
        # 5. Delete task
        detail_url = reverse('task-detail', kwargs={'pk': task_id})
        response = auth_client.delete(detail_url)
        assert response.status_code == status.HTTP_204_NO_CONTENT
        
        # Verify task is deleted
        assert not Task.objects.filter(id=task_id).exists()

    def test_comment_on_task_flow(self, auth_client, user, project):
        """
        Test the comment flow:
        1. Create task
        2. Add multiple comments
        3. Retrieve task with comments
        """
        # Create task
        task = Task.objects.create(
            title='Comment Test Task',
            project=project,
            created_by=user
        )
        
        # Add multiple comments
        comments = ['Comment 1', 'Comment 2', 'Comment 3']
        for content in comments:
            response = auth_client.post(
                reverse('comment-list'),
                {'content': content, 'task': task.id}
            )
            assert response.status_code == status.HTTP_201_CREATED
        
        # Get task comments
        url = reverse('task-comments', kwargs={'pk': task.id})
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['count'] == 3
        assert len(response.data['results']) == 3
        assert response.data['results'][0]['content'] in comments
```

### Step 9: Create Factory Boy Factories

**backend/tests/factories.py** (create)

```python
"""
Factory Boy factories for test data generation.
"""

import factory
from factory.django import DjangoModelFactory
from django.contrib.auth import get_user_model
from apps.projects.models import Project
from apps.tasks.models import Task
from apps.comments.models import Comment
from faker import Faker

fake = Faker()

User = get_user_model()


class UserFactory(DjangoModelFactory):
    class Meta:
        model = User
    
    email = factory.LazyAttribute(lambda x: fake.email())
    username = factory.LazyAttribute(lambda x: fake.user_name())
    first_name = factory.LazyAttribute(lambda x: fake.first_name())
    last_name = factory.LazyAttribute(lambda x: fake.last_name())
    password = factory.PostGenerationMethodCall('set_password', 'testpass123')
    role = 'member'
    is_active = True


class AdminFactory(UserFactory):
    role = 'admin'
    is_staff = True
    is_superuser = True


class ManagerFactory(UserFactory):
    role = 'manager'
    is_staff = True


class ProjectFactory(DjangoModelFactory):
    class Meta:
        model = Project
    
    name = factory.LazyAttribute(lambda x: fake.catch_phrase())
    description = factory.LazyAttribute(lambda x: fake.text())
    created_by = factory.SubFactory(UserFactory)


class TaskFactory(DjangoModelFactory):
    class Meta:
        model = Task
    
    title = factory.LazyAttribute(lambda x: fake.sentence())
    description = factory.LazyAttribute(lambda x: fake.text())
    status = 'todo'
    priority = 'medium'
    project = factory.SubFactory(ProjectFactory)
    created_by = factory.SubFactory(UserFactory)
    assigned_to = factory.SubFactory(UserFactory)


class CommentFactory(DjangoModelFactory):
    class Meta:
        model = Comment
    
    content = factory.LazyAttribute(lambda x: fake.sentence())
    task = factory.SubFactory(TaskFactory)
    author = factory.SubFactory(UserFactory)
```

---

## The Verification

### Step 1: Run All Tests

```bash
cd backend
source venv/bin/activate
pytest
```

### Step 2: Run with Coverage

```bash
pytest --cov=apps --cov-report=html
```

### Step 3: Run Specific Test File

```bash
pytest tests/test_views/test_task_views.py -v
```

### Step 4: Run with Verbose Output

```bash
pytest -v --tb=short
```

### Step 5: View Coverage Report

```bash
# Open the coverage report in browser
open htmlcov/index.html
```

---

## Key Takeaways

1. **Unit tests** ensure individual components work correctly.

2. **Integration tests** verify component interactions.

3. **API tests** ensure endpoints behave as expected.

4. **Permission tests** validate access control.

5. **Test fixtures** provide reusable test data.

6. **Coverage reports** identify untested code.

7. **CI integration** ensures tests run on every commit.

---

## What's Next

In **Part 25**, we'll implement frontend testing:

- Component testing
- Form testing
- API mocking
- E2E testing

---

**End of Part 24**

*Next: Part 25 - Frontend Testing*
