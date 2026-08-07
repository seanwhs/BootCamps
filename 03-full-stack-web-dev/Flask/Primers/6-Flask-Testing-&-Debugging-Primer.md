# Primer 6: Flask Testing & Debugging Primer

Welcome to Primer 6! This foundational primer is designed for beginners who want to understand how to test and debug their Flask applications. Building on the basics from Primers 1-5, you'll learn how to write tests that ensure your application works correctly and how to debug issues when they arise.

---

## Table of Contents

1. [Why Testing Matters](#1-why-testing-matters)
2. [Understanding Test Types](#2-understanding-test-types)
3. [Setting Up Testing](#3-setting-up-testing)
4. [Writing Unit Tests](#4-writing-unit-tests)
5. [Testing Routes & Views](#5-testing-routes--views)
6. [Testing Databases](#6-testing-databases)
7. [Testing APIs](#7-testing-apis)
8. [Test Coverage](#8-test-coverage)
9. [Debugging Techniques](#9-debugging-techniques)
10. [Continuous Testing](#10-continuous-testing)

---

## 1. Why Testing Matters

### The Problem: Manual Testing

```python
# Without automated tests, you have to:

# 1. Run the app
python app.py

# 2. Open browser
# 3. Click around
# 4. Try different inputs
# 5. Check database manually
# 6. Repeat for every change

# This is:
# - Time-consuming
# - Error-prone
# - Not repeatable
# - Hard to catch edge cases
```

### The Solution: Automated Testing

```python
# With automated tests, you just:

# 1. Run the test suite
pytest

# 2. Get results instantly
# ====================== 5 passed, 0 failed ======================

# Benefits:
# - Fast (seconds instead of minutes)
# - Repeatable (same results every time)
# - Comprehensive (tests all cases)
# - Catches bugs early
# - Documentation (tests show how code should work)
```

### The Testing Pyramid

```
          ┌─────────────┐
          │   E2E Tests │   ← Few (slow, comprehensive)
         ┌┴─────────────┴┐
         │ Integration   │   ← Some (medium speed)
        ┌┴───────────────┴┐
        │   Unit Tests     │   ← Many (fast, focused)
        └──────────────────┘

Unit Tests: Test individual functions
Integration Tests: Test components together
End-to-End Tests: Test full user workflows
```

### The Confidence Factor

```python
def add(a, b):
    return a + b

# How do you know it works?
print(add(2, 3))  # Manual test - you check once

# With tests:
def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

# Now you KNOW it works forever!
# When you change code, run tests to ensure nothing broke
```

---

## 2. Understanding Test Types

### Unit Tests

```python
# Unit Test: Tests a single unit of code
# Example: Testing a function

def get_full_name(first, last):
    return f"{first} {last}"

def test_get_full_name():
    assert get_full_name("John", "Doe") == "John Doe"
    assert get_full_name("", "Smith") == " Smith"
    assert get_full_name("Jane", "") == "Jane "
```

### Integration Tests

```python
# Integration Test: Tests how components work together
# Example: Testing a function that uses a database

def create_user(username, email):
    user = User(username=username, email=email)
    db.session.add(user)
    db.session.commit()
    return user

def test_create_user(test_db):
    user = create_user("john", "john@example.com")
    
    # Test that user was created in database
    saved_user = User.query.filter_by(username="john").first()
    assert saved_user is not None
    assert saved_user.email == "john@example.com"
```

### Functional Tests

```python
# Functional Test: Tests a complete feature
# Example: Testing a user registration workflow

def test_user_registration(client):
    # 1. Visit registration page
    response = client.get('/register')
    assert response.status_code == 200
    
    # 2. Submit registration form
    response = client.post('/register', data={
        'username': 'john',
        'email': 'john@example.com',
        'password': 'SecurePass123!'
    })
    
    # 3. Verify user was created
    user = User.query.filter_by(username='john').first()
    assert user is not None
    
    # 4. Verify redirect to login
    assert response.status_code == 302
    assert '/login' in response.headers['Location']
```

### End-to-End Tests

```python
# End-to-End Test: Tests complete user journey
# Example: Register → Login → Create Task → Logout

def test_complete_user_flow(client):
    # 1. Register
    client.post('/register', data={
        'username': 'john',
        'email': 'john@example.com',
        'password': 'SecurePass123!'
    })
    
    # 2. Login
    client.post('/login', data={
        'email': 'john@example.com',
        'password': 'SecurePass123!'
    })
    
    # 3. Create task
    client.post('/tasks/create', data={
        'title': 'Test Task',
        'description': 'This is a test'
    })
    
    # 4. Verify task exists
    task = Task.query.filter_by(title='Test Task').first()
    assert task is not None
    
    # 5. Logout
    client.get('/logout')
    
    # 6. Try to access protected page
    response = client.get('/dashboard')
    assert response.status_code == 302  # Redirected to login
```

---

## 3. Setting Up Testing

### Installing Testing Tools

```bash
# Install testing packages
pip install pytest pytest-cov factory-boy faker

# Install Flask testing helpers
pip install flask-testing
```

### Creating Test Structure

```
project/
├── app/
│   └── ... (your application)
├── tests/
│   ├── __init__.py
│   ├── conftest.py      # Pytest fixtures
│   ├── test_models.py   # Model tests
│   ├── test_routes.py   # Route tests
│   ├── test_forms.py    # Form tests
│   ├── test_api.py      # API tests
│   ├── unit/            # Unit tests
│   │   └── test_utils.py
│   └── integration/     # Integration tests
│       └── test_database.py
├── pytest.ini           # Pytest configuration
└── .coveragerc          # Coverage configuration
```

### Pytest Configuration

```ini
# pytest.ini

[pytest]
minversion = 7.0
addopts = -ra -q --strict-markers --tb=short
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*

markers =
    unit: Unit tests (fast, isolated)
    integration: Integration tests (require database)
    functional: Functional tests (full application)
    slow: Slow tests (skip during quick test runs)

filterwarnings =
    ignore::DeprecationWarning
```

### Test Fixtures with conftest.py

```python
# tests/conftest.py

import pytest
from app import create_app
from app.extensions import db
from app.models.user import User
from app.models.task import Task

@pytest.fixture
def app():
    """Create application for testing."""
    app = create_app('testing')
    
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()

@pytest.fixture
def runner(app):
    """Create CLI runner."""
    return app.test_cli_runner()

@pytest.fixture
def db_session(app):
    """Create database session."""
    with app.app_context():
        yield db.session

@pytest.fixture
def test_user(db_session):
    """Create test user."""
    user = User(
        username='testuser',
        email='test@example.com'
    )
    user.set_password('password123')
    db_session.add(user)
    db_session.commit()
    return user

@pytest.fixture
def auth_client(client, test_user):
    """Create authenticated client."""
    client.post('/auth/login', data={
        'email': 'test@example.com',
        'password': 'password123'
    }, follow_redirects=True)
    return client

@pytest.fixture
def test_task(db_session, test_user):
    """Create test task."""
    task = Task(
        title='Test Task',
        description='Test description',
        user_id=test_user.id
    )
    db_session.add(task)
    db_session.commit()
    return task

@pytest.fixture
def faker():
    """Faker instance for test data."""
    from faker import Faker
    return Faker()
```

---

## 4. Writing Unit Tests

### Testing Models

```python
# tests/test_models.py

import pytest
from app.models.user import User
from app.models.task import Task
from datetime import datetime

class TestUserModel:
    """Tests for User model."""
    
    def test_create_user(self, db_session):
        """Test creating a user."""
        user = User(
            username='john',
            email='john@example.com'
        )
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.username == 'john'
        assert user.email == 'john@example.com'
        assert user.check_password('password123') is True
    
    def test_password_hashing(self, db_session):
        """Test password hashing."""
        user = User(username='test')
        user.set_password('mypassword')
        
        assert user.password_hash != 'mypassword'  # Hash should be different
        assert user.check_password('mypassword') is True
        assert user.check_password('wrong') is False
    
    def test_user_relationship(self, db_session, test_user):
        """Test user-tasks relationship."""
        task = Task(
            title='Test Task',
            user_id=test_user.id
        )
        db_session.add(task)
        db_session.commit()
        
        assert test_user.tasks.count() == 1
        assert test_user.tasks.first().title == 'Test Task'

class TestTaskModel:
    """Tests for Task model."""
    
    def test_create_task(self, db_session, test_user):
        """Test creating a task."""
        task = Task(
            title='Test Task',
            description='Task description',
            status='pending',
            user_id=test_user.id
        )
        db_session.add(task)
        db_session.commit()
        
        assert task.id is not None
        assert task.title == 'Test Task'
        assert task.status == 'pending'
    
    def test_task_complete(self, db_session, test_task):
        """Test completing a task."""
        assert test_task.status == 'pending'
        
        test_task.status = 'completed'
        test_task.completed_at = datetime.utcnow()
        db_session.commit()
        
        assert test_task.status == 'completed'
        assert test_task.completed_at is not None
```

### Testing Forms

```python
# tests/test_forms.py

from app.forms.auth import LoginForm, RegistrationForm
from app.forms.task import TaskForm

class TestAuthForms:
    """Tests for authentication forms."""
    
    def test_login_form_valid(self):
        """Test valid login form."""
        form = LoginForm(
            email='test@example.com',
            password='password123',
            remember=True
        )
        assert form.validate() is True
    
    def test_login_form_invalid_email(self):
        """Test invalid email in login form."""
        form = LoginForm(
            email='not-an-email',
            password='password123'
        )
        assert form.validate() is False
        assert 'email' in form.errors
    
    def test_login_form_missing_password(self):
        """Test missing password."""
        form = LoginForm(
            email='test@example.com',
            password=''
        )
        assert form.validate() is False
        assert 'password' in form.errors
    
    def test_registration_form_valid(self, db_session):
        """Test valid registration."""
        form = RegistrationForm(
            username='newuser',
            email='new@example.com',
            password='Password123!',
            confirm_password='Password123!',
            accept_terms=True
        )
        assert form.validate() is True
    
    def test_registration_password_mismatch(self):
        """Test password mismatch."""
        form = RegistrationForm(
            username='newuser',
            email='new@example.com',
            password='Password123!',
            confirm_password='Different!',
            accept_terms=True
        )
        assert form.validate() is False
        assert 'confirm_password' in form.errors

class TestTaskForms:
    """Tests for task forms."""
    
    def test_task_form_valid(self):
        """Test valid task form."""
        form = TaskForm(
            title='Test Task',
            description='Task description',
            priority='high',
            status='pending'
        )
        assert form.validate() is True
    
    def test_task_form_missing_title(self):
        """Test missing title."""
        form = TaskForm(
            title='',
            description='Description'
        )
        assert form.validate() is False
        assert 'title' in form.errors
```

### Testing Utilities

```python
# tests/unit/test_utils.py

from app.utils import validate_email, slugify, generate_token

class TestUtils:
    """Tests for utility functions."""
    
    def test_validate_email(self):
        """Test email validation."""
        assert validate_email('test@example.com') is True
        assert validate_email('invalid-email') is False
        assert validate_email('test@.com') is False
        assert validate_email('test@example') is False
    
    def test_slugify(self):
        """Test slugify function."""
        assert slugify('Hello World') == 'hello-world'
        assert slugify('Hello  World!') == 'hello-world'
        assert slugify('A-B-C') == 'a-b-c'
        assert slugify('') == ''
    
    def test_generate_token(self):
        """Test token generation."""
        token = generate_token()
        assert len(token) > 20
        assert token.isalnum() or '-' in token
        assert token != generate_token()  # Should be unique
```

---

## 5. Testing Routes & Views

### Testing Public Routes

```python
# tests/test_routes.py

class TestPublicRoutes:
    """Tests for public routes."""
    
    def test_home_page(self, client):
        """Test home page loads."""
        response = client.get('/')
        assert response.status_code == 200
        assert b'Welcome' in response.data
    
    def test_about_page(self, client):
        """Test about page loads."""
        response = client.get('/about')
        assert response.status_code == 200
        assert b'About' in response.data
    
    def test_404_page(self, client):
        """Test 404 error page."""
        response = client.get('/non-existent-page')
        assert response.status_code == 404
        assert b'Not Found' in response.data

class TestAuthRoutes:
    """Tests for authentication routes."""
    
    def test_login_page(self, client):
        """Test login page loads."""
        response = client.get('/login')
        assert response.status_code == 200
        assert b'Login' in response.data
    
    def test_login_success(self, client, test_user):
        """Test successful login."""
        response = client.post('/login', data={
            'email': 'test@example.com',
            'password': 'password123'
        }, follow_redirects=True)
        
        assert response.status_code == 200
        assert b'Dashboard' in response.data
    
    def test_login_failure(self, client):
        """Test failed login."""
        response = client.post('/login', data={
            'email': 'wrong@example.com',
            'password': 'wrongpassword'
        })
        
        assert response.status_code == 200
        assert b'Invalid' in response.data
    
    def test_register_page(self, client):
        """Test registration page loads."""
        response = client.get('/register')
        assert response.status_code == 200
        assert b'Register' in response.data
    
    def test_register_success(self, client, db_session):
        """Test successful registration."""
        response = client.post('/register', data={
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'Password123!',
            'confirm_password': 'Password123!',
            'accept_terms': True
        }, follow_redirects=True)
        
        assert response.status_code == 200
        assert b'Registration successful' in response.data
        
        # Verify user was created
        user = User.query.filter_by(username='newuser').first()
        assert user is not None
        assert user.email == 'new@example.com'
```

### Testing Protected Routes

```python
class TestProtectedRoutes:
    """Tests for authenticated routes."""
    
    def test_dashboard_requires_login(self, client):
        """Test dashboard requires authentication."""
        response = client.get('/dashboard')
        assert response.status_code == 302  # Redirect to login
        assert '/login' in response.headers['Location']
    
    def test_dashboard_authenticated(self, auth_client):
        """Test dashboard with authenticated user."""
        response = auth_client.get('/dashboard')
        assert response.status_code == 200
        assert b'Dashboard' in response.data
    
    def test_task_crud_authenticated(self, auth_client, test_user):
        """Test task CRUD with authenticated user."""
        # Create task
        response = auth_client.post('/tasks/create', data={
            'title': 'Test Task',
            'description': 'Test description'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Task created' in response.data
        
        # Get task
        task = Task.query.filter_by(title='Test Task').first()
        assert task is not None
        
        # View task
        response = auth_client.get(f'/tasks/{task.id}')
        assert response.status_code == 200
        assert b'Test Task' in response.data
        
        # Update task
        response = auth_client.post(f'/tasks/{task.id}/edit', data={
            'title': 'Updated Task',
            'description': 'Updated description',
            'status': 'completed'
        }, follow_redirects=True)
        assert response.status_code == 200
        assert b'Task updated' in response.data
        
        # Delete task
        response = auth_client.post(f'/tasks/{task.id}/delete', 
                                     follow_redirects=True)
        assert response.status_code == 200
        assert b'Task deleted' in response.data
    
    def test_task_ownership(self, auth_client, test_user, db_session):
        """Test task ownership checks."""
        # Create another user
        other_user = User(username='other', email='other@example.com')
        other_user.set_password('password123')
        db_session.add(other_user)
        db_session.commit()
        
        # Create task for other user
        task = Task(title='Other Task', user_id=other_user.id)
        db_session.add(task)
        db_session.commit()
        
        # Try to edit other user's task
        response = auth_client.get(f'/tasks/{task.id}/edit')
        assert response.status_code == 403  # Forbidden
```

---

## 6. Testing Databases

### Database Test Setup

```python
# tests/conftest.py (continued)

@pytest.fixture
def test_db(app):
    """Database fixture for integration tests."""
    with app.app_context():
        db.create_all()
        yield db
        db.drop_all()

@pytest.fixture
def db_session(test_db):
    """Database session for tests."""
    yield test_db.session
    test_db.session.rollback()
```

### Testing Database Operations

```python
# tests/integration/test_database.py

import pytest
from app.models.user import User
from app.models.task import Task
from app.services import UserService, TaskService

class TestDatabaseOperations:
    """Tests for database operations."""
    
    def test_create_user(self, db_session):
        """Test user creation in database."""
        user = User(
            username='john',
            email='john@example.com'
        )
        user.set_password('password123')
        db_session.add(user)
        db_session.commit()
        
        saved = User.query.filter_by(username='john').first()
        assert saved is not None
        assert saved.email == 'john@example.com'
    
    def test_user_relationships(self, db_session, test_user):
        """Test user relationships."""
        task1 = Task(title='Task 1', user_id=test_user.id)
        task2 = Task(title='Task 2', user_id=test_user.id)
        db_session.add_all([task1, task2])
        db_session.commit()
        
        tasks = test_user.tasks.all()
        assert len(tasks) == 2
        assert tasks[0].title in ['Task 1', 'Task 2']
    
    def test_cascade_delete(self, db_session, test_user):
        """Test cascade delete."""
        task = Task(title='Task', user_id=test_user.id)
        db_session.add(task)
        db_session.commit()
        
        # Delete user should delete tasks
        db_session.delete(test_user)
        db_session.commit()
        
        task_check = Task.query.get(task.id)
        assert task_check is None
    
    def test_transaction_rollback(self, db_session):
        """Test transaction rollback."""
        try:
            user = User(username='test')
            db_session.add(user)
            db_session.commit()
            
            # Simulate error
            raise Exception("Database error")
        except Exception:
            db_session.rollback()
        
        # User should not exist
        user = User.query.filter_by(username='test').first()
        assert user is None
```

### Testing with Factories

```python
# tests/factories.py

import factory
from faker import Faker
from app.models.user import User
from app.models.task import Task

fake = Faker()

class UserFactory(factory.Factory):
    class Meta:
        model = User
    
    username = factory.LazyAttribute(lambda _: fake.user_name())
    email = factory.LazyAttribute(lambda _: fake.email())
    
    @factory.post_generation
    def set_password(self, create, extracted, **kwargs):
        self.set_password('password123')

class TaskFactory(factory.Factory):
    class Meta:
        model = Task
    
    title = factory.LazyAttribute(lambda _: fake.sentence())
    description = factory.LazyAttribute(lambda _: fake.paragraph())
    status = 'pending'
    user_id = None

# Usage in tests
def test_with_factories(db_session):
    user = UserFactory()
    db_session.add(user)
    db_session.commit()
    
    task = TaskFactory(user_id=user.id)
    db_session.add(task)
    db_session.commit()
    
    assert user.tasks.count() == 1
    assert task.user_id == user.id
```

---

## 7. Testing APIs

### API Test Setup

```python
# tests/test_api.py

import json

class TestAPI:
    """Tests for API endpoints."""
    
    def test_api_root(self, client):
        """Test API root endpoint."""
        response = client.get('/api')
        assert response.status_code == 200
        data = response.json
        assert 'version' in data
        assert 'endpoints' in data
    
    def test_api_tasks_get(self, auth_client, test_task):
        """Test getting tasks via API."""
        response = auth_client.get('/api/tasks')
        assert response.status_code == 200
        data = response.json
        assert isinstance(data, list)
        assert len(data) >= 1
        assert data[0]['title'] == 'Test Task'
    
    def test_api_task_create(self, auth_client):
        """Test creating task via API."""
        response = auth_client.post('/api/tasks', 
            json={'title': 'API Task', 'description': 'Created via API'}
        )
        assert response.status_code == 201
        data = response.json
        assert data['title'] == 'API Task'
        assert 'id' in data
        
        # Verify in database
        task = Task.query.get(data['id'])
        assert task is not None
        assert task.title == 'API Task'
    
    def test_api_task_get(self, auth_client, test_task):
        """Test getting specific task via API."""
        response = auth_client.get(f'/api/tasks/{test_task.id}')
        assert response.status_code == 200
        data = response.json
        assert data['id'] == test_task.id
        assert data['title'] == test_task.title
    
    def test_api_task_update(self, auth_client, test_task):
        """Test updating task via API."""
        response = auth_client.put(f'/api/tasks/{test_task.id}',
            json={'title': 'Updated Task', 'status': 'completed'}
        )
        assert response.status_code == 200
        data = response.json
        assert data['title'] == 'Updated Task'
        assert data['status'] == 'completed'
        
        # Verify in database
        task = Task.query.get(test_task.id)
        assert task.title == 'Updated Task'
        assert task.status == 'completed'
    
    def test_api_task_delete(self, auth_client, test_task):
        """Test deleting task via API."""
        response = auth_client.delete(f'/api/tasks/{test_task.id}')
        assert response.status_code == 204
        
        # Verify deleted
        task = Task.query.get(test_task.id)
        assert task is None
    
    def test_api_task_not_found(self, auth_client):
        """Test getting non-existent task."""
        response = auth_client.get('/api/tasks/999')
        assert response.status_code == 404
        assert 'not found' in response.json.get('error', '').lower()
```

### API Authentication Tests

```python
class TestAPIAuth:
    """Tests for API authentication."""
    
    def test_api_login_success(self, client, test_user):
        """Test successful API login."""
        response = client.post('/api/login', json={
            'email': 'test@example.com',
            'password': 'password123'
        })
        assert response.status_code == 200
        data = response.json
        assert 'token' in data
        assert data['token'] is not None
    
    def test_api_login_failure(self, client):
        """Test failed API login."""
        response = client.post('/api/login', json={
            'email': 'wrong@example.com',
            'password': 'wrongpassword'
        })
        assert response.status_code == 401
    
    def test_api_token_required(self, client):
        """Test API token required."""
        response = client.get('/api/protected')
        assert response.status_code == 401
        assert 'token required' in response.json.get('error', '').lower()
    
    def test_api_token_valid(self, client, test_user):
        """Test valid API token."""
        # Login to get token
        login_response = client.post('/api/login', json={
            'email': 'test@example.com',
            'password': 'password123'
        })
        token = login_response.json['token']
        
        # Use token
        response = client.get('/api/protected', 
            headers={'Authorization': f'Bearer {token}'}
        )
        assert response.status_code == 200
        assert 'You have access' in response.json.get('message', '')
```

---

## 8. Test Coverage

### Setting Up Coverage

```bash
# Install coverage
pip install pytest-cov

# Run tests with coverage
pytest --cov=app --cov-report=html --cov-report=term

# View coverage report
open htmlcov/index.html
```

### Coverage Configuration

```ini
# .coveragerc

[run]
source = app
omit = 
    app/__init__.py
    app/extensions.py
    */migrations/*
    */tests/*
    */venv/*
    */instance/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    def __str__
    if __name__ == .__main__.:
    raise NotImplementedError
    if TYPE_CHECKING:

show_missing = True
fail_under = 80
```

### Coverage in CI/CD

```yaml
# .github/workflows/ci.yml

- name: Run tests with coverage
  run: |
    pytest --cov=app --cov-report=xml

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    file: ./coverage.xml
    flags: unittests
    fail_ci_if_error: true
```

---

## 9. Debugging Techniques

### Print Debugging

```python
# Simple print debugging
def complex_function(data):
    print(f"DEBUG: data = {data}")
    result = process(data)
    print(f"DEBUG: result = {result}")
    return result

# Better: Use logging
import logging
logging.basicConfig(level=logging.DEBUG)

def complex_function(data):
    app.logger.debug(f"Processing data: {data}")
    result = process(data)
    app.logger.debug(f"Result: {result}")
    return result
```

### Using the Flask Debugger

```python
# Enable debug mode
if __name__ == '__main__':
    app.run(debug=True)

# When error occurs:
# - Flask shows interactive debugger in browser
# - You can inspect variables, execute code
# - Great for development, NEVER use in production!
```

### Using pdb (Python Debugger)

```python
# Add breakpoint in code
import pdb

def complex_function(data):
    pdb.set_trace()  # Execution stops here
    result = process(data)
    return result

# Commands in pdb:
# n (next) - execute next line
# s (step) - step into function
# c (continue) - continue execution
# p variable - print variable value
# l (list) - show code around current line
# q (quit) - quit debugger
```

### Using the Werkzeug Debugger

```python
from werkzeug.debug import DebuggedApplication

# Wrap application with debugger
app.wsgi_app = DebuggedApplication(app.wsgi_app, True)

# When error occurs:
# - Shows interactive debugger with stack trace
# - Can execute code in browser
# - Provides console access
```

### Debugging Database Queries

```python
# Enable SQL logging
import logging
logging.basicConfig()
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Or in Flask config
app.config['SQLALCHEMY_ECHO'] = True

# Use explain to analyze queries
def analyze_query(query):
    sql = str(query.compile(compile_kwargs={"literal_binds": True}))
    result = db.session.execute(f"EXPLAIN ANALYZE {sql}")
    return result.fetchall()
```

### Common Debugging Patterns

```python
# 1. Check request data
@app.before_request
def log_request_info():
    app.logger.debug(f"Headers: {request.headers}")
    app.logger.debug(f"Args: {request.args}")
    app.logger.debug(f"Form: {request.form}")
    app.logger.debug(f"JSON: {request.json}")

# 2. Check database state
def debug_db():
    app.logger.debug(f"Database URL: {app.config['SQLALCHEMY_DATABASE_URI']}")
    app.logger.debug(f"Pool size: {db.engine.pool.size()}")
    app.logger.debug(f"Checked out: {db.engine.pool.checkedout()}")

# 3. Check session data
@app.before_request
def log_session():
    app.logger.debug(f"Session: {dict(session)}")

# 4. Check template context
@app.context_processor
def debug_context():
    return {'debug': lambda x: print(x)}
```

---

## 10. Continuous Testing

### Running Tests in CI/CD

```yaml
# .github/workflows/ci.yml

name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Run tests
      run: |
        pytest --cov=app --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml

repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black

  - repo: https://github.com/charliermarsh/ruff-pre-commit
    rev: v0.0.276
    hooks:
      - id: ruff

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.4.1
    hooks:
      - id: mypy
```

### Test-Driven Development (TDD)

```python
# TDD Process:
# 1. Write a test (it fails)
def test_add_function():
    assert add(2, 3) == 5

# 2. Write minimal code to pass test
def add(a, b):
    return a + b

# 3. Refactor code
def add(a, b):
    return sum([a, b])

# 4. Write more tests
def test_add_negative():
    assert add(-1, 1) == 0
    assert add(-5, -3) == -8

# 5. Repeat...
```

---

## Summary

This primer has introduced you to testing and debugging Flask applications:

1. **Testing Matters**: Confidence, catches bugs early
2. **Test Types**: Unit, Integration, Functional, E2E
3. **Setup**: Pytest, fixtures, configuration
4. **Unit Tests**: Models, forms, utilities
5. **Route Tests**: Public, protected, API routes
6. **Database Tests**: Operations, relationships, transactions
7. **API Tests**: Endpoints, authentication, error handling
8. **Coverage**: Measuring test completeness
9. **Debugging**: Print, pdb, debugger, logging
10. **Continuous Testing**: CI/CD, pre-commit hooks

### Testing Quick Reference

```python
# Basic test structure
def test_something():
    # Arrange (setup)
    data = prepare_test_data()
    
    # Act (execute)
    result = function_being_tested(data)
    
    # Assert (verify)
    assert result == expected

# Common assertions
assert value == expected
assert value != expected
assert value is True
assert value is False
assert value in collection
assert value not in collection
assert len(collection) == expected

# Test markers
@pytest.mark.unit
def test_unit(): ...

@pytest.mark.integration
def test_integration(): ...

# Skip tests
@pytest.mark.skip(reason="Not implemented yet")
def test_skipped(): ...

# Expected exceptions
def test_exception():
    with pytest.raises(ValueError):
        function_that_raises()
```

**Next Steps**:
- Write tests for your application
- Set up CI/CD pipeline
- Use coverage to find gaps
- Practice TDD
- Debug issues systematically
