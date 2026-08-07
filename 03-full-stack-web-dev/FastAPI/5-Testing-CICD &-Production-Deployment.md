# Part 5: Testing, CI/CD & Production Deployment

Welcome to Part 5 of our FastAPI Masterclass! Now that we have a fully featured, high-performance API with real-time capabilities, it's time to ensure it's production-ready. In this module, we'll write comprehensive tests, set up CI/CD pipelines, containerize our application with Docker, configure Nginx as a reverse proxy, and deploy everything to production with monitoring and logging.

## Learning Objectives

By the end of Part 5, you will be able to:
- Write comprehensive unit, integration, and end-to-end tests with pytest
- Set up GitHub Actions for continuous integration and deployment
- Containerize applications with Docker multi-stage builds
- Configure Nginx as a reverse proxy with SSL termination
- Deploy using Docker Compose for staging environments
- Implement structured logging and error tracking
- Set up monitoring with Prometheus and Grafana
- Create production-ready deployment pipelines

## Key Concepts Before We Begin

### What is CI/CD?
CI/CD is like an automated assembly line for your code. **Continuous Integration** (CI) automatically builds and tests your code whenever you push changes, catching bugs early. **Continuous Deployment** (CD) automatically deploys your tested code to production, ensuring your users always have the latest features.

### What is Docker?
Docker is like a shipping container for your application. It packages your code, dependencies, and runtime environment into a standardized unit that runs consistently anywhere—your laptop, a test server, or the cloud.

### What is Nginx?
Nginx is like a traffic controller for your web applications. It handles incoming requests, serves static files, terminates SSL, and distributes traffic to your application servers.

## Step 1: Comprehensive Testing Setup

### The Target
Set up a robust testing framework with pytest, including fixtures, mocking, and test coverage.

### The Concept
Testing is like having a quality control department for your code. Each test checks a specific aspect of your application—from individual functions to entire user workflows—ensuring everything works correctly before you ship to production.

### The Implementation

**First, ensure testing dependencies are installed:**

```bash
# These should already be in requirements.txt
pip install pytest pytest-asyncio pytest-cov pytest-mock httpx factory-boy faker
```

**Update `pytest.ini`:**

```ini
# pytest.ini
[pytest]
# Test discovery patterns
python_files = test_*.py
python_classes = Test*
python_functions = test_*
testpaths = tests

# Asyncio settings
asyncio_mode = auto

# Coverage settings
addopts = 
    --cov=app
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
    -v

# Markers
markers =
    unit: Unit tests
    integration: Integration tests
    e2e: End-to-end tests
    slow: Slow tests
```

**Create `tests/conftest.py` with comprehensive fixtures:**

```python
"""
tests/conftest.py
Pytest configuration and fixtures for testing.
"""

import pytest
import asyncio
from typing import AsyncGenerator, Generator, Dict, Any
from datetime import datetime, timedelta
import json
import os
from unittest.mock import AsyncMock, MagicMock

from fastapi.testclient import TestClient
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import event
import factory
from faker import Faker

from app.main import app
from app.core.database import Base, get_db, engine as production_engine
from app.core.config import settings
from app.core.security import create_access_token, get_password_hash
from app.models.user import User, UserRole
from app.models.task import Task, TaskStatus, TaskPriority
from app.models.project import Project, ProjectStatus
from app.crud.user import UserRepository
from app.crud.task import TaskRepository
from app.crud.project import ProjectRepository
from app.services.user import UserService

# Initialize faker
fake = Faker()

# Test database URL - use a separate database for testing
TEST_DATABASE_URL = settings.DATABASE_URL.replace("/fastapi_db", "/fastapi_test")


# ────────────────────────────────────────────────────────────────
# Database Fixtures
# ────────────────────────────────────────────────────────────────

@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
async def test_engine():
    """Create test database engine."""
    engine = create_async_engine(
        TEST_DATABASE_URL,
        echo=False,
        future=True,
    )
    
    # Create tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    yield engine
    
    # Cleanup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    
    await engine.dispose()


@pytest.fixture(scope="function")
async def db_session(test_engine) -> AsyncGenerator[AsyncSession, None]:
    """Create a test database session."""
    async_session = sessionmaker(
        test_engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        yield session


@pytest.fixture(scope="function")
async def client(db_session: AsyncSession) -> AsyncGenerator:
    """Create test client with database session."""
    async def override_get_db():
        yield db_session
    
    app.dependency_overrides[get_db] = override_get_db
    
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client
    
    app.dependency_overrides.clear()


# ────────────────────────────────────────────────────────────────
# Factory Fixtures
# ────────────────────────────────────────────────────────────────

class UserFactory:
    """Factory for creating test users."""
    
    @staticmethod
    async def create(
        db: AsyncSession,
        email: str = None,
        username: str = None,
        full_name: str = None,
        password: str = "SecurePass123!",
        role: UserRole = UserRole.DEVELOPER,
        is_active: bool = True,
        is_verified: bool = True,
        is_superuser: bool = False,
    ) -> User:
        """Create a test user."""
        email = email or fake.email()
        username = username or fake.user_name()
        full_name = full_name or fake.name()
        
        user_data = {
            "email": email,
            "username": username,
            "full_name": full_name,
            "hashed_password": get_password_hash(password),
            "role": role,
            "is_active": is_active,
            "is_verified": is_verified,
            "is_superuser": is_superuser,
        }
        
        user = User(**user_data)
        db.add(user)
        await db.commit()
        await db.refresh(user)
        return user
    
    @staticmethod
    async def create_admin(db: AsyncSession) -> User:
        """Create an admin user."""
        return await UserFactory.create(
            db,
            email="admin@example.com",
            username="admin",
            full_name="Admin User",
            role=UserRole.ADMIN,
            is_superuser=True,
        )
    
    @staticmethod
    async def create_manager(db: AsyncSession) -> User:
        """Create a manager user."""
        return await UserFactory.create(
            db,
            email="manager@example.com",
            username="manager",
            full_name="Manager User",
            role=UserRole.MANAGER,
        )
    
    @staticmethod
    async def create_developer(db: AsyncSession) -> User:
        """Create a developer user."""
        return await UserFactory.create(
            db,
            email="developer@example.com",
            username="developer",
            full_name="Developer User",
            role=UserRole.DEVELOPER,
        )
    
    @staticmethod
    async def create_viewer(db: AsyncSession) -> User:
        """Create a viewer user."""
        return await UserFactory.create(
            db,
            email="viewer@example.com",
            username="viewer",
            full_name="Viewer User",
            role=UserRole.VIEWER,
        )


class ProjectFactory:
    """Factory for creating test projects."""
    
    @staticmethod
    async def create(
        db: AsyncSession,
        name: str = None,
        description: str = None,
        owner_id: int = None,
        status: ProjectStatus = ProjectStatus.ACTIVE,
        is_public: bool = False,
    ) -> Project:
        """Create a test project."""
        name = name or fake.company()
        description = description or fake.text(max_nb_chars=200)
        
        project = Project(
            name=name,
            description=description,
            owner_id=owner_id,
            status=status,
            is_public=is_public,
        )
        db.add(project)
        await db.commit()
        await db.refresh(project)
        return project


class TaskFactory:
    """Factory for creating test tasks."""
    
    @staticmethod
    async def create(
        db: AsyncSession,
        title: str = None,
        description: str = None,
        status: TaskStatus = TaskStatus.TODO,
        priority: TaskPriority = TaskPriority.MEDIUM,
        created_by_id: int = None,
        assignee_id: int = None,
        project_id: int = None,
        due_date: datetime = None,
        tags: list = None,
    ) -> Task:
        """Create a test task."""
        title = title or fake.sentence(nb_words=6)
        description = description or fake.text(max_nb_chars=500)
        tags = tags or [fake.word() for _ in range(3)]
        
        task = Task(
            title=title,
            description=description,
            status=status,
            priority=priority,
            created_by_id=created_by_id,
            assignee_id=assignee_id,
            project_id=project_id,
            due_date=due_date or datetime.utcnow() + timedelta(days=7),
            tags=tags,
            estimated_hours=fake.random_number(digits=2),
        )
        db.add(task)
        await db.commit()
        await db.refresh(task)
        return task


# ────────────────────────────────────────────────────────────────
# Authentication Fixtures
# ────────────────────────────────────────────────────────────────

@pytest.fixture(scope="function")
async def auth_headers(db_session: AsyncSession) -> Dict[str, str]:
    """
    Get authentication headers for a test user.
    """
    user = await UserFactory.create(db_session)
    token = create_access_token({"sub": user.id, "role": user.role.value})
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(scope="function")
async def admin_auth_headers(db_session: AsyncSession) -> Dict[str, str]:
    """
    Get authentication headers for an admin user.
    """
    admin = await UserFactory.create_admin(db_session)
    token = create_access_token({"sub": admin.id, "role": admin.role.value})
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(scope="function")
async def test_user(db_session: AsyncSession) -> User:
    """Create a test user."""
    return await UserFactory.create(db_session)


@pytest.fixture(scope="function")
async def test_admin(db_session: AsyncSession) -> User:
    """Create a test admin."""
    return await UserFactory.create_admin(db_session)


@pytest.fixture(scope="function")
async def test_task(db_session: AsyncSession, test_user: User) -> Task:
    """Create a test task."""
    return await TaskFactory.create(
        db_session,
        created_by_id=test_user.id,
        assignee_id=test_user.id,
    )


@pytest.fixture(scope="function")
async def test_project(db_session: AsyncSession, test_user: User) -> Project:
    """Create a test project."""
    return await ProjectFactory.create(
        db_session,
        owner_id=test_user.id,
    )


# ────────────────────────────────────────────────────────────────
# Mock Fixtures
# ────────────────────────────────────────────────────────────────

@pytest.fixture
def mock_redis():
    """Mock Redis client."""
    mock = AsyncMock()
    mock.ping = AsyncMock(return_value=True)
    mock.get = AsyncMock(return_value=None)
    mock.set = AsyncMock(return_value=True)
    mock.delete = AsyncMock(return_value=1)
    mock.exists = AsyncMock(return_value=0)
    mock.incr = AsyncMock(return_value=1)
    mock.expire = AsyncMock(return_value=True)
    return mock


@pytest.fixture
def mock_email_service():
    """Mock email service."""
    mock = AsyncMock()
    mock.send_email = AsyncMock(return_value=True)
    mock.send_welcome_email = AsyncMock(return_value=True)
    mock.send_password_reset_email = AsyncMock(return_value=True)
    return mock


# ────────────────────────────────────────────────────────────────
# Cleanup Fixtures
# ────────────────────────────────────────────────────────────────

@pytest.fixture(autouse=True)
async def cleanup_db(db_session: AsyncSession):
    """Clean up database after each test."""
    yield
    # Rollback any pending transactions
    await db_session.rollback()
```

## Step 2: Writing Tests

### The Target
Write comprehensive unit, integration, and end-to-end tests for all components.

### The Implementation

**Create `tests/test_unit/test_models.py`:**

```python
"""
tests/test_unit/test_models.py
Unit tests for database models.
"""

import pytest
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User, UserRole
from app.models.task import Task, TaskStatus, TaskPriority
from app.models.project import Project, ProjectStatus
from app.models.comment import Comment


@pytest.mark.unit
class TestUserModel:
    """Test User model."""
    
    async def test_create_user(self, db_session: AsyncSession):
        """Test creating a user."""
        user = User(
            email="test@example.com",
            username="testuser",
            full_name="Test User",
            hashed_password="hashed_password",
            role=UserRole.DEVELOPER,
        )
        db_session.add(user)
        await db_session.commit()
        await db_session.refresh(user)
        
        assert user.id is not None
        assert user.email == "test@example.com"
        assert user.username == "testuser"
        assert user.full_name == "Test User"
        assert user.role == UserRole.DEVELOPER
        assert user.is_active is True
        assert user.created_at is not None
    
    async def test_user_soft_delete(self, db_session: AsyncSession):
        """Test user soft delete."""
        user = User(
            email="delete@example.com",
            username="deleteuser",
            full_name="Delete User",
            hashed_password="hashed_password",
        )
        db_session.add(user)
        await db_session.commit()
        await db_session.refresh(user)
        
        # Soft delete
        user.soft_delete()
        await db_session.commit()
        
        assert user.is_deleted is True
        assert user.deleted_at is not None
    
    async def test_user_update_last_login(self, db_session: AsyncSession):
        """Test updating last login."""
        user = User(
            email="login@example.com",
            username="loginuser",
            full_name="Login User",
            hashed_password="hashed_password",
        )
        db_session.add(user)
        await db_session.commit()
        await db_session.refresh(user)
        
        previous_login_count = user.login_count
        user.update_last_login()
        await db_session.commit()
        
        assert user.last_login is not None
        assert user.login_count == previous_login_count + 1


@pytest.mark.unit
class TestTaskModel:
    """Test Task model."""
    
    async def test_create_task(self, db_session: AsyncSession, test_user: User):
        """Test creating a task."""
        task = Task(
            title="Test Task",
            description="This is a test task",
            status=TaskStatus.TODO,
            priority=TaskPriority.HIGH,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() + timedelta(days=7),
            tags=["test", "unit"],
            estimated_hours=4.5,
        )
        db_session.add(task)
        await db_session.commit()
        await db_session.refresh(task)
        
        assert task.id is not None
        assert task.title == "Test Task"
        assert task.status == TaskStatus.TODO
        assert task.priority == TaskPriority.HIGH
        assert len(task.tags) == 2
        assert "test" in task.tags
    
    async def test_task_is_overdue(self, db_session: AsyncSession, test_user: User):
        """Test task overdue check."""
        # Past due date
        task = Task(
            title="Overdue Task",
            status=TaskStatus.IN_PROGRESS,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() - timedelta(days=1),
        )
        db_session.add(task)
        await db_session.commit()
        
        assert task.is_overdue is True
        
        # Future due date
        task2 = Task(
            title="Future Task",
            status=TaskStatus.TODO,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() + timedelta(days=7),
        )
        db_session.add(task2)
        await db_session.commit()
        
        assert task2.is_overdue is False
    
    async def test_task_completion(self, db_session: AsyncSession, test_user: User):
        """Test marking task as complete."""
        task = Task(
            title="Complete Me",
            status=TaskStatus.IN_PROGRESS,
            created_by_id=test_user.id,
        )
        db_session.add(task)
        await db_session.commit()
        
        task.complete()
        await db_session.commit()
        
        assert task.status == TaskStatus.DONE
        assert task.completed_at is not None


@pytest.mark.unit
class TestProjectModel:
    """Test Project model."""
    
    async def test_create_project(self, db_session: AsyncSession, test_user: User):
        """Test creating a project."""
        project = Project(
            name="Test Project",
            description="This is a test project",
            owner_id=test_user.id,
            status=ProjectStatus.ACTIVE,
        )
        db_session.add(project)
        await db_session.commit()
        await db_session.refresh(project)
        
        assert project.id is not None
        assert project.name == "Test Project"
        assert project.status == ProjectStatus.ACTIVE
        assert project.owner_id == test_user.id
```

**Create `tests/test_unit/test_security.py`:**

```python
"""
tests/test_unit/test_security.py
Unit tests for security utilities.
"""

import pytest
from datetime import datetime, timedelta
from jose import jwt

from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    decode_token,
    verify_token,
    hash_api_key,
    verify_api_key,
    generate_password_reset_token,
    verify_password_reset_token,
)
from app.core.config import settings
from app.core.exceptions import UnauthorizedException


@pytest.mark.unit
class TestPasswordHashing:
    """Test password hashing utilities."""
    
    def test_hash_password(self):
        """Test hashing a password."""
        password = "SecurePass123!"
        hashed = get_password_hash(password)
        
        assert hashed is not None
        assert hashed != password
        assert verify_password(password, hashed) is True
    
    def test_verify_password(self):
        """Test verifying a password."""
        password = "TestPass456!"
        hashed = get_password_hash(password)
        
        assert verify_password(password, hashed) is True
        assert verify_password("WrongPassword", hashed) is False


@pytest.mark.unit
class TestJWT:
    """Test JWT utilities."""
    
    def test_create_access_token(self):
        """Test creating an access token."""
        data = {"sub": 1, "role": "admin"}
        token = create_access_token(data)
        
        assert token is not None
        
        # Decode and verify
        decoded = decode_token(token)
        assert decoded["sub"] == 1
        assert decoded["role"] == "admin"
        assert "exp" in decoded
        assert "iat" in decoded
    
    def test_create_refresh_token(self):
        """Test creating a refresh token."""
        data = {"sub": 1}
        token = create_refresh_token(data)
        
        assert token is not None
        
        decoded = decode_token(token)
        assert decoded["sub"] == 1
        assert decoded["type"] == "refresh"
    
    def test_verify_token_valid(self):
        """Test verifying a valid token."""
        data = {"sub": 1}
        token = create_access_token(data)
        decoded = verify_token(token)
        
        assert decoded["sub"] == 1
    
    def test_verify_token_expired(self):
        """Test verifying an expired token."""
        data = {"sub": 1}
        token = create_access_token(data, expires_delta=timedelta(seconds=-1))
        
        with pytest.raises(UnauthorizedException):
            verify_token(token)


@pytest.mark.unit
class TestAPIKey:
    """Test API key utilities."""
    
    def test_hash_api_key(self):
        """Test hashing an API key."""
        api_key = "test-api-key-12345"
        hashed = hash_api_key(api_key)
        
        assert hashed is not None
        assert hashed != api_key
        assert verify_api_key(api_key, hashed) is True
    
    def test_verify_api_key(self):
        """Test verifying an API key."""
        api_key = "test-key-67890"
        hashed = hash_api_key(api_key)
        
        assert verify_api_key(api_key, hashed) is True
        assert verify_api_key("wrong-key", hashed) is False


@pytest.mark.unit
class TestPasswordReset:
    """Test password reset utilities."""
    
    def test_generate_reset_token(self):
        """Test generating a password reset token."""
        email = "test@example.com"
        token = generate_password_reset_token(email)
        
        assert token is not None
        
        # Verify token
        decoded = decode_token(token)
        assert decoded["email"] == email
        assert decoded["type"] == "password_reset"
    
    def test_verify_reset_token_valid(self):
        """Test verifying a valid reset token."""
        email = "test@example.com"
        token = generate_password_reset_token(email)
        result = verify_password_reset_token(token)
        
        assert result == email
    
    def test_verify_reset_token_invalid(self):
        """Test verifying an invalid reset token."""
        result = verify_password_reset_token("invalid.token.here")
        assert result is None
```

**Create `tests/test_integration/test_api.py`:**

```python
"""
tests/test_integration/test_api.py
Integration tests for API endpoints.
"""

import pytest
from httpx import AsyncClient
from datetime import datetime, timedelta

from app.models.user import UserRole
from app.schemas.task import TaskStatus, TaskPriority


@pytest.mark.integration
class TestAuthEndpoints:
    """Test authentication endpoints."""
    
    async def test_register_user(self, client: AsyncClient):
        """Test user registration."""
        response = await client.post(
            "/api/v1/auth/register",
            json={
                "email": "newuser@example.com",
                "username": "newuser",
                "full_name": "New User",
                "password": "SecurePass123!",
            }
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "newuser@example.com"
        assert data["username"] == "newuser"
        assert data["full_name"] == "New User"
        assert "id" in data
    
    async def test_login_success(self, client: AsyncClient, db_session):
        """Test successful login."""
        # Create user
        from app.services.user import UserService
        from app.schemas.auth import RegisterRequest
        
        user_service = UserService(db_session)
        await user_service.create_user(
            RegisterRequest(
                email="login@example.com",
                username="loginuser",
                full_name="Login User",
                password="SecurePass123!",
            )
        )
        
        # Login
        response = await client.post(
            "/api/v1/auth/login",
            data={
                "username": "login@example.com",
                "password": "SecurePass123!",
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
    
    async def test_login_invalid_credentials(self, client: AsyncClient):
        """Test login with invalid credentials."""
        response = await client.post(
            "/api/v1/auth/login",
            data={
                "username": "nonexistent@example.com",
                "password": "WrongPass123!",
            }
        )
        
        assert response.status_code == 401
        data = response.json()
        assert data["error"]["error_code"] == "INVALID_CREDENTIALS"


@pytest.mark.integration
class TestTaskEndpoints:
    """Test task endpoints."""
    
    async def test_create_task(
        self, 
        client: AsyncClient, 
        auth_headers: dict,
        db_session,
    ):
        """Test creating a task."""
        response = await client.post(
            "/api/v1/tasks/",
            headers=auth_headers,
            json={
                "title": "Integration Test Task",
                "description": "This is a test task from integration tests",
                "status": TaskStatus.TODO.value,
                "priority": TaskPriority.HIGH.value,
                "due_date": (datetime.utcnow() + timedelta(days=7)).isoformat(),
                "tags": ["test", "integration"],
                "estimated_hours": 4.5,
            }
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == "Integration Test Task"
        assert data["status"] == TaskStatus.TODO.value
        assert data["priority"] == TaskPriority.HIGH.value
    
    async def test_get_tasks(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_task,
    ):
        """Test getting list of tasks."""
        response = await client.get(
            "/api/v1/tasks/",
            headers=auth_headers,
            params={"page": 1, "size": 10}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data
        assert "page" in data
        assert "size" in data
    
    async def test_get_task_by_id(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_task,
    ):
        """Test getting a task by ID."""
        response = await client.get(
            f"/api/v1/tasks/{test_task.id}",
            headers=auth_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == test_task.id
        assert data["title"] == test_task.title
    
    async def test_update_task(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_task,
    ):
        """Test updating a task."""
        response = await client.put(
            f"/api/v1/tasks/{test_task.id}",
            headers=auth_headers,
            json={
                "title": "Updated Task Title",
                "status": TaskStatus.IN_PROGRESS.value,
                "priority": TaskPriority.CRITICAL.value,
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == test_task.id
        assert data["title"] == "Updated Task Title"
        assert data["status"] == TaskStatus.IN_PROGRESS.value
        assert data["priority"] == TaskPriority.CRITICAL.value
    
    async def test_delete_task(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_task,
    ):
        """Test deleting a task."""
        response = await client.delete(
            f"/api/v1/tasks/{test_task.id}",
            headers=auth_headers,
        )
        
        assert response.status_code == 204
        
        # Verify task is deleted
        get_response = await client.get(
            f"/api/v1/tasks/{test_task.id}",
            headers=auth_headers,
        )
        assert get_response.status_code == 404


@pytest.mark.integration
class TestProtectedEndpoints:
    """Test protected endpoints."""
    
    async def test_protected_without_token(self, client: AsyncClient):
        """Test accessing protected endpoint without token."""
        response = await client.get("/api/v1/auth/me")
        
        assert response.status_code == 401
        data = response.json()
        assert data["error"]["error_code"] == "NO_TOKEN"
    
    async def test_protected_with_invalid_token(self, client: AsyncClient):
        """Test accessing protected endpoint with invalid token."""
        response = await client.get(
            "/api/v1/auth/me",
            headers={"Authorization": "Bearer invalid_token"}
        )
        
        assert response.status_code == 401
        data = response.json()
        assert data["error"]["error_code"] == "INVALID_TOKEN"
    
    async def test_protected_with_valid_token(
        self,
        client: AsyncClient,
        auth_headers: dict,
    ):
        """Test accessing protected endpoint with valid token."""
        response = await client.get(
            "/api/v1/auth/me",
            headers=auth_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "email" in data
        assert "username" in data
```

**Create `tests/test_e2e/test_workflows.py`:**

```python
"""
tests/test_e2e/test_workflows.py
End-to-end tests for complete user workflows.
"""

import pytest
from httpx import AsyncClient
from datetime import datetime, timedelta

from app.schemas.task import TaskStatus, TaskPriority


@pytest.mark.e2e
class TestUserWorkflow:
    """Test complete user workflow."""
    
    async def test_complete_task_workflow(self, client: AsyncClient, db_session):
        """
        Test complete task workflow:
        1. Register
        2. Login
        3. Create task
        4. Update task
        5. Complete task
        6. Delete task
        """
        # 1. Register
        register_response = await client.post(
            "/api/v1/auth/register",
            json={
                "email": "workflow@example.com",
                "username": "workflowuser",
                "full_name": "Workflow User",
                "password": "SecurePass123!",
            }
        )
        assert register_response.status_code == 201
        
        # 2. Login
        login_response = await client.post(
            "/api/v1/auth/login",
            data={
                "username": "workflow@example.com",
                "password": "SecurePass123!",
            }
        )
        assert login_response.status_code == 200
        token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        
        # 3. Create task
        create_response = await client.post(
            "/api/v1/tasks/",
            headers=headers,
            json={
                "title": "E2E Test Task",
                "description": "This task tests the complete workflow",
                "status": TaskStatus.TODO.value,
                "priority": TaskPriority.MEDIUM.value,
                "due_date": (datetime.utcnow() + timedelta(days=7)).isoformat(),
                "tags": ["e2e", "workflow"],
                "estimated_hours": 3.0,
            }
        )
        assert create_response.status_code == 201
        task_data = create_response.json()
        task_id = task_data["id"]
        
        # 4. Update task
        update_response = await client.put(
            f"/api/v1/tasks/{task_id}",
            headers=headers,
            json={
                "title": "Updated E2E Task",
                "status": TaskStatus.IN_PROGRESS.value,
                "priority": TaskPriority.HIGH.value,
            }
        )
        assert update_response.status_code == 200
        updated_data = update_response.json()
        assert updated_data["title"] == "Updated E2E Task"
        assert updated_data["status"] == TaskStatus.IN_PROGRESS.value
        
        # 5. Complete task
        complete_response = await client.put(
            f"/api/v1/tasks/{task_id}",
            headers=headers,
            json={
                "status": TaskStatus.DONE.value,
            }
        )
        assert complete_response.status_code == 200
        completed_data = complete_response.json()
        assert completed_data["status"] == TaskStatus.DONE.value
        
        # 6. Delete task
        delete_response = await client.delete(
            f"/api/v1/tasks/{task_id}",
            headers=headers,
        )
        assert delete_response.status_code == 204
    
    async def test_user_role_workflow(self, client: AsyncClient, db_session):
        """
        Test role-based access control workflow:
        1. Create admin and regular user
        2. Admin creates a task
        3. Regular user tries to create task (should succeed)
        4. Regular user tries to delete admin's task (should fail)
        """
        # Create admin user
        from app.services.user import UserService
        from app.schemas.auth import RegisterRequest
        
        user_service = UserService(db_session)
        
        # Create admin
        admin = await user_service.create_user(
            RegisterRequest(
                email="admin@example.com",
                username="adminuser",
                full_name="Admin User",
                password="SecurePass123!",
            )
        )
        admin.is_superuser = True
        await db_session.commit()
        
        # Create regular user
        regular = await user_service.create_user(
            RegisterRequest(
                email="regular@example.com",
                username="regularuser",
                full_name="Regular User",
                password="SecurePass123!",
            )
        )
        
        # Login as admin
        admin_login = await client.post(
            "/api/v1/auth/login",
            data={
                "username": "admin@example.com",
                "password": "SecurePass123!",
            }
        )
        admin_token = admin_login.json()["access_token"]
        admin_headers = {"Authorization": f"Bearer {admin_token}"}
        
        # Login as regular user
        regular_login = await client.post(
            "/api/v1/auth/login",
            data={
                "username": "regular@example.com",
                "password": "SecurePass123!",
            }
        )
        regular_token = regular_login.json()["access_token"]
        regular_headers = {"Authorization": f"Bearer {regular_token}"}
        
        # Admin creates a task
        admin_create = await client.post(
            "/api/v1/tasks/",
            headers=admin_headers,
            json={
                "title": "Admin's Task",
                "status": TaskStatus.TODO.value,
                "priority": TaskPriority.HIGH.value,
            }
        )
        assert admin_create.status_code == 201
        task_id = admin_create.json()["id"]
        
        # Regular user tries to delete admin's task
        regular_delete = await client.delete(
            f"/api/v1/tasks/{task_id}",
            headers=regular_headers,
        )
        
        # Should fail (403 Forbidden or 404 Not Found)
        assert regular_delete.status_code in [403, 404]
```

## Step 3: Docker Containerization

### The Target
Create Docker containers for our application, database, Redis, and Celery workers.

### The Implementation

**Create `Dockerfile`:**

```dockerfile
# Dockerfile - Multi-stage build for production

# ──────────────── BUILD STAGE ────────────────
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Install system dependencies for Python packages
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ──────────────── DEVELOPMENT STAGE ────────────────
FROM python:3.11-slim as development

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY . .

# Ensure scripts are executable
RUN chmod +x /app/scripts/*.sh

# Set environment variables
ENV PYTHONPATH=/app
ENV PATH=/root/.local/bin:$PATH

# Expose port
EXPOSE 8000

# Development command
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ──────────────── PRODUCTION STAGE ────────────────
FROM development as production

# Set production environment
ENV APP_ENV=production
ENV DEBUG=False

# Remove development dependencies
RUN pip uninstall -y pytest pytest-asyncio pytest-cov || true

# Use gunicorn with uvicorn workers
CMD ["gunicorn", "app.main:app", "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--workers", "4", "--bind", "0.0.0.0:8000", "--timeout", "120"]

# ──────────────── CELERY WORKER STAGE ────────────────
FROM development as celery_worker

# Celery worker command
CMD ["celery", "-A", "app.core.celery_app", "worker", "--loglevel=info"]

# ──────────────── CELERY BEAT STAGE ────────────────
FROM development as celery_beat

# Celery beat command
CMD ["celery", "-A", "app.core.celery_app", "beat", "--loglevel=info"]
```

**Create `.dockerignore`:**

```dockerignore
# .dockerignore
__pycache__
*.pyc
*.pyo
*.pyd
.Python
env
venv
ENV
dist
build
*.egg-info
.pytest_cache
.coverage
htmlcov
.tox
.mypy_cache
.dmypy.json
dmypy.json
.vscode
.idea
*.swp
*.swo
*~
.DS_Store
*.db
*.sqlite
*.sqlite3
*.log
logs/
node_modules/
.env
.env.local
.env.*.local
alembic/versions/*.py
!alembic/versions/.gitkeep
.git
.gitignore
README.md
Makefile
docker-compose.yml
.dockerignore
```

**Create `docker-compose.yml`:**

```yaml
# docker-compose.yml
version: '3.8'

services:
  # ──────────────── POSTGRES DATABASE ────────────────
  postgres:
    image: postgres:15-alpine
    container_name: fastapi_postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: fastapi_db
      POSTGRES_INITDB_ARGS: "--data-checksums"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - fastapi_network

  # ──────────────── REDIS CACHE ────────────────
  redis:
    image: redis:7-alpine
    container_name: fastapi_redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --requirepass redispass
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - fastapi_network

  # ──────────────── FASTAPI APPLICATION ────────────────
  app:
    build:
      context: .
      target: development
    container_name: fastapi_app
    environment:
      DATABASE_URL: postgresql+asyncpg://postgres:postgres@postgres:5432/fastapi_db
      REDIS_URL: redis://:redispass@redis:6379/0
      APP_ENV: development
      DEBUG: "true"
      SECRET_KEY: ${SECRET_KEY:-dev_secret_key_change_in_production}
    ports:
      - "8000:8000"
    volumes:
      - ./app:/app/app
      - ./alembic:/app/alembic
      - ./tests:/app/tests
      - ./uploads:/app/uploads
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - fastapi_network
    command: >
      sh -c "
        alembic upgrade head &&
        uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
      "

  # ──────────────── CELERY WORKER ────────────────
  celery_worker:
    build:
      context: .
      target: celery_worker
    container_name: fastapi_celery_worker
    environment:
      DATABASE_URL: postgresql+asyncpg://postgres:postgres@postgres:5432/fastapi_db
      REDIS_URL: redis://:redispass@redis:6379/0
      APP_ENV: development
      SECRET_KEY: ${SECRET_KEY:-dev_secret_key_change_in_production}
    volumes:
      - ./app:/app/app
      - ./alembic:/app/alembic
    depends_on:
      - postgres
      - redis
      - app
    networks:
      - fastapi_network

  # ──────────────── CELERY BEAT ────────────────
  celery_beat:
    build:
      context: .
      target: celery_beat
    container_name: fastapi_celery_beat
    environment:
      DATABASE_URL: postgresql+asyncpg://postgres:postgres@postgres:5432/fastapi_db
      REDIS_URL: redis://:redispass@redis:6379/0
      APP_ENV: development
      SECRET_KEY: ${SECRET_KEY:-dev_secret_key_change_in_production}
    volumes:
      - ./app:/app/app
    depends_on:
      - postgres
      - redis
      - app
    networks:
      - fastapi_network

  # ──────────────── NGINX REVERSE PROXY ────────────────
  nginx:
    image: nginx:alpine
    container_name: fastapi_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./static:/usr/share/nginx/html/static:ro
    depends_on:
      - app
    networks:
      - fastapi_network

  # ──────────────── PROMETHEUS MONITORING ────────────────
  prometheus:
    image: prom/prometheus:latest
    container_name: fastapi_prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - fastapi_network

  # ──────────────── GRAFANA DASHBOARD ────────────────
  grafana:
    image: grafana/grafana:latest
    container_name: fastapi_grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ./grafana/datasources:/etc/grafana/provisioning/datasources:ro
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    depends_on:
      - prometheus
    networks:
      - fastapi_network

# ──────────────── NETWORKS ────────────────
networks:
  fastapi_network:
    driver: bridge

# ──────────────── VOLUMES ────────────────
volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:
```

**Create `nginx/nginx.conf`:**

```nginx
# nginx/nginx.conf
events {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}

http {
    # Basic settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 50M;

    # MIME types
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript
               application/json application/javascript application/xml+rss
               application/rss+xml application/atom+xml
               image/svg+xml;

    # Include server configurations
    include /etc/nginx/conf.d/*.conf;
}
```

**Create `nginx/conf.d/fastapi.conf`:**

```nginx
# nginx/conf.d/fastapi.conf
server {
    listen 80;
    server_name localhost;
    
    # Return 301 to HTTPS in production
    # return 301 https://$server_name$request_uri;
    
    # Root path
    root /usr/share/nginx/html;
    
    # Health checks
    location /health {
        proxy_pass http://app:8000/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        access_log off;
    }
    
    location /ready {
        proxy_pass http://app:8000/ready;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        access_log off;
    }
    
    # API endpoints
    location /api/ {
        proxy_pass http://app:8000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffering
        proxy_buffering on;
        proxy_buffer_size 8k;
        proxy_buffers 8 8k;
        proxy_busy_buffers_size 16k;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # WebSocket endpoints
    location /ws/ {
        proxy_pass http://app:8000/ws/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket specific
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
    
    # Documentation
    location /docs {
        proxy_pass http://app:8000/docs;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /redoc {
        proxy_pass http://app:8000/redoc;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static files
    location /static/ {
        alias /usr/share/nginx/html/static/;
        expires 1d;
        add_header Cache-Control "public, immutable";
    }
    
    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}

# HTTPS server (uncomment for production)
# server {
#     listen 443 ssl http2;
#     server_name your-domain.com;
#     
#     ssl_certificate /etc/nginx/ssl/cert.pem;
#     ssl_certificate_key /etc/nginx/ssl/key.pem;
#     
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_ciphers HIGH:!aNULL:!MD5;
#     ssl_prefer_server_ciphers on;
#     ssl_session_cache shared:SSL:10m;
#     ssl_session_timeout 10m;
#     
#     # Same locations as above...
# }
```

## Step 4: CI/CD Pipeline with GitHub Actions

### The Target
Set up a GitHub Actions workflow for continuous integration and deployment.

### The Implementation

**Create `.github/workflows/ci-cd.yml`:**

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  release:
    types: [ published ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # ──────────────────── LINT & TEST ────────────────────
  lint-and-test:
    name: Lint & Test
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: fastapi_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      
      - name: Lint with flake8
        run: |
          flake8 app tests --count --show-source --statistics --max-line-length=100
      
      - name: Check formatting with black
        run: |
          black --check app tests
      
      - name: Check imports with isort
        run: |
          isort --check-only --profile black app tests
      
      - name: Type check with mypy
        run: |
          mypy app --ignore-missing-imports
      
      - name: Run tests with pytest
        env:
          DATABASE_URL: postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_test
          REDIS_URL: redis://localhost:6379/0
          SECRET_KEY: test_secret_key_for_ci
          APP_ENV: testing
        run: |
          pytest tests/ -v --cov=app --cov-report=xml
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: false

  # ──────────────────── BUILD IMAGE ────────────────────
  build-image:
    name: Build Docker Image
    needs: lint-and-test
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop')
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,format=short
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          target: production
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ──────────────────── DEPLOY TO STAGING ────────────────────
  deploy-staging:
    name: Deploy to Staging
    needs: build-image
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.your-domain.com
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Install SSH key
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.STAGING_SSH_PRIVATE_KEY }}
      
      - name: Deploy to staging server
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.STAGING_USER }}@${{ secrets.STAGING_HOST }} '
            cd /opt/fastapi-app
            docker-compose pull
            docker-compose up -d --remove-orphans
            docker system prune -f
          '

  # ──────────────────── DEPLOY TO PRODUCTION ────────────────────
  deploy-production:
    name: Deploy to Production
    needs: build-image
    if: github.event_name == 'release' && github.event.action == 'published'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://your-domain.com
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Install SSH key
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.PRODUCTION_SSH_PRIVATE_KEY }}
      
      - name: Deploy to production server
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.PRODUCTION_USER }}@${{ secrets.PRODUCTION_HOST }} '
            cd /opt/fastapi-app
            docker-compose pull
            docker-compose up -d --remove-orphans
            docker system prune -f
          '
      
      - name: Send deployment notification
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          fields: repo,message,commit,author,action,eventName,ref,workflow
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        if: always()
```

## Step 5: Monitoring with Prometheus and Grafana

### The Target
Set up Prometheus for metrics collection and Grafana for visualization.

### The Implementation

**Create `prometheus/prometheus.yml`:**

```yaml
# prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files:
  - "alerts.yml"

scrape_configs:
  - job_name: 'fastapi_app'
    static_configs:
      - targets: ['app:8000']
    metrics_path: '/metrics'
    scrape_interval: 10s
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
    
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
    
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

**Create `app/middleware/metrics.py`:**

```python
"""
app/middleware/metrics.py
Prometheus metrics for monitoring.
"""

from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from fastapi import Request, Response
from fastapi.middleware.base import BaseHTTPMiddleware
import time

# ────────────────────────────────────────────────────────────────
# Metrics Definitions
# ────────────────────────────────────────────────────────────────

# HTTP request counter
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

# HTTP request duration histogram
REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10)
)

# Active requests gauge
ACTIVE_REQUESTS = Gauge(
    'http_requests_active',
    'Active HTTP requests'
)

# Error counter
ERROR_COUNT = Counter(
    'http_errors_total',
    'Total HTTP errors',
    ['method', 'endpoint', 'error_type']
)

# Database query counter
DB_QUERY_COUNT = Counter(
    'db_queries_total',
    'Total database queries',
    ['operation']
)

# Database query duration
DB_QUERY_DURATION = Histogram(
    'db_query_duration_seconds',
    'Database query duration in seconds',
    ['operation'],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5)
)

# Cache metrics
CACHE_HIT_COUNT = Counter(
    'cache_hits_total',
    'Total cache hits',
    ['cache_type']
)

CACHE_MISS_COUNT = Counter(
    'cache_misses_total',
    'Total cache misses',
    ['cache_type']
)


# ────────────────────────────────────────────────────────────────
# Metrics Middleware
# ────────────────────────────────────────────────────────────────

class PrometheusMiddleware(BaseHTTPMiddleware):
    """
    Middleware for collecting Prometheus metrics.
    """
    
    async def dispatch(self, request: Request, call_next):
        # Track active requests
        ACTIVE_REQUESTS.inc()
        
        start_time = time.time()
        
        # Process request
        try:
            response = await call_next(request)
            
            # Record metrics
            endpoint = request.url.path
            method = request.method
            
            REQUEST_COUNT.labels(
                method=method,
                endpoint=endpoint,
                status_code=response.status_code
            ).inc()
            
            duration = time.time() - start_time
            REQUEST_DURATION.labels(
                method=method,
                endpoint=endpoint
            ).observe(duration)
            
            return response
            
        except Exception as e:
            # Record error
            endpoint = request.url.path
            method = request.method
            error_type = type(e).__name__
            
            ERROR_COUNT.labels(
                method=method,
                endpoint=endpoint,
                error_type=error_type
            ).inc()
            
            raise
        finally:
            ACTIVE_REQUESTS.dec()


# ────────────────────────────────────────────────────────────────
# Metrics Endpoint
# ────────────────────────────────────────────────────────────────

async def metrics_endpoint(request: Request) -> Response:
    """
    Endpoint for Prometheus to scrape metrics.
    """
    return Response(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST
    )


# ────────────────────────────────────────────────────────────────
# Utility Functions
# ────────────────────────────────────────────────────────────────

def record_db_query(operation: str, duration: float):
    """
    Record a database query metric.
    
    Args:
        operation: Operation type (select, insert, update, delete)
        duration: Query duration in seconds
    """
    DB_QUERY_COUNT.labels(operation=operation).inc()
    DB_QUERY_DURATION.labels(operation=operation).observe(duration)


def record_cache_hit(cache_type: str = "redis"):
    """
    Record a cache hit.
    
    Args:
        cache_type: Type of cache (redis, memory)
    """
    CACHE_HIT_COUNT.labels(cache_type=cache_type).inc()


def record_cache_miss(cache_type: str = "redis"):
    """
    Record a cache miss.
    
    Args:
        cache_type: Type of cache (redis, memory)
    """
    CACHE_MISS_COUNT.labels(cache_type=cache_type).inc()
```

**Update `app/main.py` to include metrics:**

```python
# Add this to app/main.py
from app.middleware.metrics import PrometheusMiddleware, metrics_endpoint

def create_application() -> FastAPI:
    # ... existing code ...
    
    # Add Prometheus middleware
    app.add_middleware(PrometheusMiddleware)
    
    # Add metrics endpoint
    @app.get("/metrics", tags=["monitoring"])
    async def metrics(request: Request):
        return await metrics_endpoint(request)
    
    # ... rest of code ...
```

## Step 6: Logging and Error Tracking

### The Target
Implement structured logging with Loguru and error tracking with Sentry.

### The Implementation

**Update `app/core/logging.py`:**

```python
"""
app/core/logging.py
Structured logging configuration.
"""

from loguru import logger
import sys
import json
from datetime import datetime
from typing import Dict, Any
import logging

from app.core.config import settings


class JSONFormatter:
    """
    Custom JSON formatter for structured logging.
    """
    
    def __call__(self, record: Dict[str, Any]) -> str:
        """
        Format log record as JSON.
        
        Args:
            record: Log record
            
        Returns:
            str: JSON formatted log
        """
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record["level"].name,
            "message": record["message"],
            "module": record["name"],
            "function": record["function"],
            "line": record["line"],
        }
        
        # Add extra fields
        if "extra" in record:
            for key, value in record["extra"].items():
                if key not in log_entry:
                    log_entry[key] = value
        
        return json.dumps(log_entry) + "\n"


def setup_logging():
    """
    Configure structured logging.
    """
    # Remove default handler
    logger.remove()
    
    # Get log level
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), "INFO")
    
    # Configure based on environment
    if settings.APP_ENV == "production":
        # JSON format for production
        logger.add(
            sys.stdout,
            format=JSONFormatter(),
            level=log_level,
            serialize=True,
        )
        
        # Also log to file
        logger.add(
            "/var/log/app.log",
            rotation="100 MB",
            retention="30 days",
            compression="gz",
            format=JSONFormatter(),
            level=log_level,
            serialize=True,
        )
    else:
        # Human-readable format for development
        logger.add(
            sys.stdout,
            format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
            level=log_level,
            colorize=True,
        )
    
    # Add correlation ID to logs
    def add_correlation_id(record):
        """Add correlation ID to log records."""
        if hasattr(logger, "correlation_id"):
            record["extra"]["correlation_id"] = logger.correlation_id
        return True
    
    logger.configure(patcher=add_correlation_id)
    
    # Replace standard logging with loguru
    logging.basicConfig(handlers=[InterceptHandler()], level=0)
    
    logger.info(f"✅ Logging configured (level: {settings.LOG_LEVEL})")


class InterceptHandler(logging.Handler):
    """
    Intercept standard logging and redirect to loguru.
    """
    
    def emit(self, record):
        # Get corresponding Loguru level
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno
    
        # Find caller from where the logged message originated
        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1
    
        logger.opt(depth=depth, exception=record.exc_info).log(
            level, record.getMessage()
        )


# Create correlation ID context
class CorrelationIdContext:
    """
    Context manager for setting correlation ID.
    """
    
    def __init__(self, correlation_id: str):
        self.correlation_id = correlation_id
        self.old_id = None
    
    def __enter__(self):
        self.old_id = getattr(logger, "correlation_id", None)
        logger.correlation_id = self.correlation_id
        return self
    
    def __exit__(self, *args):
        logger.correlation_id = self.old_id


# ────────────────────────────────────────────────────────────────
# Sentry Integration
# ────────────────────────────────────────────────────────────────

def setup_sentry():
    """
    Set up Sentry for error tracking.
    """
    if settings.APP_ENV == "production":
        import sentry_sdk
        from sentry_sdk.integrations.asgi import ASGIIntegration
        from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration
        from sentry_sdk.integrations.redis import RedisIntegration
        
        sentry_sdk.init(
            dsn=settings.SENTRY_DSN,
            environment=settings.APP_ENV,
            release=settings.APP_VERSION,
            integrations=[
                ASGIIntegration(),
                SqlalchemyIntegration(),
                RedisIntegration(),
            ],
            traces_sample_rate=0.1,
            send_default_pii=False,
        )
        
        logger.info("✅ Sentry configured")


# ────────────────────────────────────────────────────────────────
# Logging Helper Functions
# ────────────────────────────────────────────────────────────────

def log_request(request, **kwargs):
    """
    Log an HTTP request.
    
    Args:
        request: FastAPI request
        **kwargs: Additional context
    """
    logger.info(
        f"Request: {request.method} {request.url.path}",
        extra={
            "method": request.method,
            "path": request.url.path,
            "query": str(request.query_params),
            "client_ip": request.client.host if request.client else None,
            **kwargs,
        }
    )


def log_response(response, duration: float, **kwargs):
    """
    Log an HTTP response.
    
    Args:
        response: FastAPI response
        duration: Response duration in seconds
        **kwargs: Additional context
    """
    logger.info(
        f"Response: {response.status_code} ({duration:.3f}s)",
        extra={
            "status_code": response.status_code,
            "duration": duration,
            **kwargs,
        }
    )


def log_error(error, request=None, **kwargs):
    """
    Log an error.
    
    Args:
        error: Exception
        request: Optional request
        **kwargs: Additional context
    """
    logger.error(
        f"Error: {str(error)}",
        extra={
            "error_type": type(error).__name__,
            "error_message": str(error),
            "path": request.url.path if request else None,
            "method": request.method if request else None,
            **kwargs,
        },
        exc_info=True,
    )
```

## Step 7: Production Deployment Checklist

### The Target
Create a comprehensive production deployment checklist and health check script.

### The Implementation

**Create `scripts/deploy.sh`:**

```bash
#!/bin/bash
# scripts/deploy.sh
# Production deployment script

set -e

echo "🚀 Starting deployment..."

# ──────────────── Environment Setup ────────────────
echo "📋 Loading environment variables..."
export $(cat .env.production | xargs)

# ──────────────── Database Migrations ────────────────
echo "📦 Running database migrations..."
alembic upgrade head

# ──────────────── Build Docker Images ────────────────
echo "🐳 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

# ──────────────── Start Services ────────────────
echo "🚀 Starting services..."
docker-compose -f docker-compose.prod.yml up -d

# ──────────────── Wait for Services ────────────────
echo "⏳ Waiting for services to be ready..."
sleep 10

# ──────────────── Health Check ────────────────
echo "🏥 Running health checks..."
curl -f http://localhost:8000/health || exit 1
curl -f http://localhost:8000/ready || exit 1

echo "✅ Deployment complete!"
```

**Create `scripts/health_check.py`:**

```python
#!/usr/bin/env python
# scripts/health_check.py
# Comprehensive health check script

import asyncio
import aiohttp
import sys
from typing import Dict, List
import json


async def check_endpoint(session: aiohttp.ClientSession, url: str, name: str) -> Dict:
    """
    Check a single endpoint.
    
    Args:
        session: HTTP session
        url: Endpoint URL
        name: Endpoint name
        
    Returns:
        Dict: Check result
    """
    try:
        async with session.get(url, timeout=5) as response:
            return {
                "name": name,
                "url": url,
                "status": "OK" if response.status == 200 else "FAILED",
                "status_code": response.status,
                "response_time": response.headers.get("X-Response-Time", "N/A"),
            }
    except Exception as e:
        return {
            "name": name,
            "url": url,
            "status": "FAILED",
            "error": str(e),
        }


async def main():
    """Run health checks."""
    base_url = "http://localhost:8000"
    
    endpoints = [
        ("Root", f"{base_url}/"),
        ("Health", f"{base_url}/health"),
        ("Readiness", f"{base_url}/ready"),
        ("Docs", f"{base_url}/docs"),
        ("API", f"{base_url}/api/v1/health/ping"),
    ]
    
    print("🔍 Running health checks...")
    print("-" * 50)
    
    async with aiohttp.ClientSession() as session:
        tasks = [check_endpoint(session, url, name) for name, url in endpoints]
        results = await asyncio.gather(*tasks)
    
    failed = False
    for result in results:
        status_icon = "✅" if result["status"] == "OK" else "❌"
        print(f"{status_icon} {result['name']}: {result['status']}")
        if result["status"] == "FAILED":
            failed = True
            print(f"   Error: {result.get('error', 'Unknown error')}")
    
    print("-" * 50)
    
    if failed:
        print("❌ Some health checks failed!")
        sys.exit(1)
    else:
        print("✅ All health checks passed!")
        sys.exit(0)


if __name__ == "__main__":
    asyncio.run(main())
```

**Create `scripts/init-db.sql`:**

```sql
-- scripts/init-db.sql
-- Database initialization script

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS app;

-- Set search path
SET search_path TO app, public;

-- Create function for updating updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create function for checking JSON validity
CREATE OR REPLACE FUNCTION is_json_valid(json_string text)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN json_string IS NULL OR json_string::json IS NOT NULL;
EXCEPTION
    WHEN others THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE fastapi_db TO postgres;
```

## The Verification

Let's test our deployment setup:

```bash
# 1. Build and run with Docker Compose
docker-compose up -d

# 2. Check services are running
docker-compose ps

# 3. Run health checks
python scripts/health_check.py

# 4. Check logs
docker-compose logs -f app

# 5. Test API
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/health/ping

# 6. Check Prometheus metrics
curl http://localhost:8000/metrics

# 7. Access Grafana
# Open http://localhost:3000
# Login: admin/admin

# 8. Run CI/CD locally (simulate GitHub Actions)
act -j lint-and-test

# 9. Test production build
docker build --target production -t fastapi-prod .
docker run -p 8000:8000 fastapi-prod

# 10. Run database migrations in production
docker-compose -f docker-compose.prod.yml run app alembic upgrade head
```

## Deep Dive: Production Best Practices

### Environment Configuration

```python
# app/core/config.py
class ProductionSettings(Settings):
    """Production-specific settings."""
    
    APP_ENV: str = "production"
    DEBUG: bool = False
    
    # Production database
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 40
    
    # Production logging
    LOG_LEVEL: str = "WARNING"
    LOG_FORMAT: str = "json"
    
    # Security
    CORS_ORIGINS: List[str] = ["https://your-domain.com"]
    ALLOWED_HOSTS: List[str] = ["your-domain.com"]
    
    # Rate limiting
    RATE_LIMIT_REQUESTS: int = 50  # More restrictive in production
    RATE_LIMIT_PERIOD: int = 60
    
    # Session
    SESSION_COOKIE_SECURE: bool = True
    SESSION_COOKIE_HTTPONLY: bool = True
    SESSION_COOKIE_SAMESITE: str = "strict"
```

### SSL/TLS Configuration

```nginx
# nginx/conf.d/fastapi-ssl.conf
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    # SSL certificates
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;
    
    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self';" always;
    
    # Same locations as HTTP config...
}
```

## What We Accomplished

✅ Set up comprehensive testing with pytest (unit, integration, e2e)
✅ Created test factories and fixtures for efficient testing
✅ Implemented test coverage reporting
✅ Containerized application with Docker multi-stage builds
✅ Set up Docker Compose for local development
✅ Configured Nginx as reverse proxy with SSL support
✅ Implemented GitHub Actions CI/CD pipeline
✅ Set up Prometheus metrics collection
✅ Configured Grafana for visualization
✅ Implemented structured logging with Loguru
✅ Added Sentry integration for error tracking
✅ Created production deployment scripts
✅ Added health checks and monitoring

## Key Takeaways

1. **Testing**: Comprehensive tests catch bugs early and give confidence in your code
2. **Containerization**: Docker ensures consistency across environments
3. **CI/CD**: Automate testing and deployment for faster, more reliable releases
4. **Monitoring**: Prometheus and Grafana provide visibility into application health
5. **Logging**: Structured logs make debugging and analysis easier
6. **Security**: Always use HTTPS, security headers, and proper secrets management
7. **Deployment**: Use staged deployments (development → staging → production)
8. **Health Checks**: Implement health and readiness checks for monitoring

## What's Next?

In **[Part 6: Building Enterprise APIs]** , we'll:
- Apply Clean Architecture and DDD principles
- Implement event-driven architecture with RabbitMQ
- Add file uploads with AWS S3 integration
- Implement full-text search with Elasticsearch
- Set up multi-tenancy for SaaS applications
- Deploy to Kubernetes for production
- Implement feature flags and canary deployments
- Build the capstone projects
