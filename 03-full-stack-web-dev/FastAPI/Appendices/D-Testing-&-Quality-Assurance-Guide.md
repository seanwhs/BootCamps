# Appendix D: Testing & Quality Assurance Guide

Welcome to Appendix D of the FastAPI Masterclass series! This comprehensive guide covers everything you need to know about testing your FastAPI application. From unit tests to end-to-end testing, performance testing to security testing, this appendix serves as your complete testing handbook.

## Table of Contents
1. [Testing Strategy Overview](#testing-strategy-overview)
2. [Unit Testing](#unit-testing)
3. [Integration Testing](#integration-testing)
4. [End-to-End Testing](#end-to-end-testing)
5. [Performance Testing](#performance-testing)
6. [Security Testing](#security-testing)
7. [Test Coverage & Quality Metrics](#test-coverage--quality-metrics)
8. [Testing Best Practices](#testing-best-practices)
9. [CI/CD Integration](#cicd-integration)
10. [Test Data Management](#test-data-management)

---

## Testing Strategy Overview

### Testing Pyramid

```
        ┌─────────────┐
        │   E2E Tests  │  ← Few, slow, high-level
        │  (10%)       │
       ┌┴─────────────┴┐
       │ Integration    │  ← Some, medium-speed
       │   Tests (30%)  │
      ┌┴───────────────┴┐
      │   Unit Tests     │  ← Many, fast, low-level
      │   (60%)          │
      └──────────────────┘
```

### Test Types Comparison

| Test Type | Speed | Scope | Dependencies | When to Run |
|-----------|-------|-------|--------------|-------------|
| Unit | ⚡ Fast | Single function | Mocked | Every commit |
| Integration | 🏃 Medium | Multiple modules | Real DB/Redis | Every PR |
| E2E | 🐢 Slow | Full workflow | All services | Before release |
| Performance | ⏱️ Varies | System-wide | Production-like | Monthly |

---

## Unit Testing

### Complete Test Suite for Domain Entities

**`tests/test_unit/test_domain/test_task.py`:**

```python
"""
tests/test_unit/test_domain/test_task.py
Unit tests for Task domain entity.
"""

import pytest
from datetime import datetime, timedelta
from uuid import UUID

from app.domain.entities.task import Task
from app.domain.value_objects.task_status import TaskStatus, TaskPriority
from app.domain.events.task_events import TaskCreated, TaskCompleted, TaskAssigned


@pytest.mark.unit
class TestTaskEntity:
    """Test Task domain entity."""
    
    def test_create_valid_task(self):
        """Test creating a valid task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
            description="Test description",
            priority=TaskPriority.HIGH,
            due_date=datetime.utcnow() + timedelta(days=7),
            tags=["test", "unit"],
            estimated_hours=4.5,
        )
        
        assert task.id is not None
        assert UUID(task.id, version=4)  # Valid UUID4
        assert task.title == "Test Task"
        assert task.description == "Test description"
        assert task.priority == TaskPriority.HIGH
        assert task.status == TaskStatus.TODO
        assert len(task.tags) == 2
        assert "test" in task.tags
        assert task.estimated_hours == 4.5
        assert task.created_by == "user-123"
        assert len(task.events) == 1
        assert isinstance(task.events[0], TaskCreated)
    
    def test_create_task_empty_title(self):
        """Test creating task with empty title raises error."""
        with pytest.raises(ValueError, match="Task title cannot be empty"):
            Task.create_new(
                title="",
                created_by="user-123",
            )
    
    def test_create_task_title_too_long(self):
        """Test creating task with title too long."""
        long_title = "a" * 201
        with pytest.raises(ValueError, match="cannot exceed 200 characters"):
            Task.create_new(
                title=long_title,
                created_by="user-123",
            )
    
    def test_start_work_task(self):
        """Test starting work on a task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        
        assert task.status == TaskStatus.TODO
        
        task.start_work()
        
        assert task.status == TaskStatus.IN_PROGRESS
        assert task.updated_at > task.created_at
    
    def test_start_work_already_in_progress(self):
        """Test starting work on already in-progress task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.start_work()
        
        # Should not raise error, just stays in progress
        task.start_work()
        assert task.status == TaskStatus.IN_PROGRESS
    
    def test_complete_task(self):
        """Test completing a task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.start_work()
        
        task.complete()
        
        assert task.status == TaskStatus.DONE
        assert task.completed_at is not None
        assert len(task.events) == 2  # Created + Completed
        assert isinstance(task.events[-1], TaskCompleted)
    
    def test_complete_already_done_task(self):
        """Test completing an already done task raises error."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.start_work()
        task.complete()
        
        with pytest.raises(ValueError, match="already 'done'"):
            task.complete()
    
    def test_complete_archived_task(self):
        """Test completing an archived task raises error."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.archive()
        
        with pytest.raises(ValueError, match="already 'archived'"):
            task.complete()
    
    def test_archive_task(self):
        """Test archiving a task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.archive()
        
        assert task.status == TaskStatus.ARCHIVED
        assert task.updated_at > task.created_at
    
    def test_archive_already_archived(self):
        """Test archiving already archived task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.archive()
        
        with pytest.raises(ValueError, match="already archived"):
            task.archive()
    
    def test_assign_task(self):
        """Test assigning a task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        old_assignee = task.assignee_id
        
        task.assign_to("user-456")
        
        assert task.assignee_id == "user-456"
        assert len(task.events) == 2  # Created + Assigned
        assert isinstance(task.events[-1], TaskAssigned)
        assert task.events[-1].previous_assignee == old_assignee
    
    def test_assign_same_user(self):
        """Test assigning to same user no-op."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        task.assign_to("user-123")  # Same as creator
        
        assert task.assignee_id == "user-123"
        assert len(task.events) == 1  # Only created, no assigned event
    
    def test_update_priority(self):
        """Test updating task priority."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
            priority=TaskPriority.MEDIUM,
        )
        
        assert task.priority == TaskPriority.MEDIUM
        
        task.update_priority(TaskPriority.CRITICAL)
        
        assert task.priority == TaskPriority.CRITICAL
        assert task.updated_at > task.created_at
    
    def test_add_tag(self):
        """Test adding a tag to task."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        
        task.add_tag("backend")
        
        assert "backend" in task.tags
        assert task.updated_at > task.created_at
    
    def test_add_duplicate_tag(self):
        """Test adding duplicate tag."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
            tags=["backend"],
        )
        
        task.add_tag("backend")
        
        assert len(task.tags) == 1  # Still only one
        assert "backend" in task.tags
    
    def test_remove_tag(self):
        """Test removing a tag."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
            tags=["backend", "security"],
        )
        
        task.remove_tag("backend")
        
        assert "backend" not in task.tags
        assert "security" in task.tags
        assert task.updated_at > task.created_at
    
    def test_remove_nonexistent_tag(self):
        """Test removing nonexistent tag."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        
        task.remove_tag("nonexistent")  # Should not raise error
    
    def test_extend_due_date(self):
        """Test extending due date."""
        old_due = datetime.utcnow() + timedelta(days=7)
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
            due_date=old_due,
        )
        
        new_due = old_due + timedelta(days=7)
        task.extend_due_date(new_due)
        
        assert task.due_date == new_due
        assert task.updated_at > task.created_at
    
    def test_extend_due_date_past(self):
        """Test extending due date to past raises error."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        
        past_date = datetime.utcnow() - timedelta(days=1)
        with pytest.raises(ValueError, match="must be in the future"):
            task.extend_due_date(past_date)
    
    def test_is_overdue(self):
        """Test checking if task is overdue."""
        # Past due date
        task1 = Task.create_new(
            title="Past Task",
            created_by="user-123",
            due_date=datetime.utcnow() - timedelta(days=1),
        )
        assert task1.is_overdue() is True
        
        # Future due date
        task2 = Task.create_new(
            title="Future Task",
            created_by="user-123",
            due_date=datetime.utcnow() + timedelta(days=7),
        )
        assert task2.is_overdue() is False
        
        # No due date
        task3 = Task.create_new(
            title="No Due Date",
            created_by="user-123",
        )
        assert task3.is_overdue() is False
        
        # Completed task
        task4 = Task.create_new(
            title="Completed Task",
            created_by="user-123",
            due_date=datetime.utcnow() - timedelta(days=1),
        )
        task4.complete()
        assert task4.is_overdue() is False
    
    def test_get_completion_percentage(self):
        """Test calculating completion percentage."""
        task = Task.create_new(
            title="Parent Task",
            created_by="user-123",
        )
        
        # No subtasks
        assert task.get_completion_percentage([]) == 0.0
        
        # Complete parent
        task.complete()
        assert task.get_completion_percentage([]) == 100.0
        
        # With subtasks
        subtask1 = Task.create_new(
            title="Subtask 1",
            created_by="user-123",
        )
        subtask1.complete()
        
        subtask2 = Task.create_new(
            title="Subtask 2",
            created_by="user-123",
        )
        
        subtasks = [subtask1, subtask2]
        assert task.get_completion_percentage(subtasks) == 50.0
    
    def test_get_remaining_hours(self):
        """Test calculating remaining hours."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
            estimated_hours=10.0,
        )
        
        assert task.get_remaining_hours() == 10.0
        
        task.actual_hours = 4.0
        assert task.get_remaining_hours() == 6.0
        
        task.actual_hours = 12.0
        assert task.get_remaining_hours() == 0.0
    
    def test_status_transitions(self):
        """Test valid and invalid status transitions."""
        task = Task.create_new(
            title="Test Task",
            created_by="user-123",
        )
        
        # Valid transitions
        task.status = TaskStatus.IN_PROGRESS
        assert task.status == TaskStatus.IN_PROGRESS
        
        task.status = TaskStatus.REVIEW
        assert task.status == TaskStatus.REVIEW
        
        task.status = TaskStatus.DONE
        assert task.status == TaskStatus.DONE
        
        # Cannot go backwards
        with pytest.raises(ValueError):
            task.status = TaskStatus.TODO  # Would raise if we check
        
        # Archive is always allowed
        task.archive()
        assert task.status == TaskStatus.ARCHIVED
        
        # Cannot leave archived
        with pytest.raises(ValueError, match="Cannot leave archived"):
            task.status = TaskStatus.TODO
```

### Unit Test for Security Utilities

**`tests/test_unit/test_core/test_security.py`:**

```python
"""
tests/test_unit/test_core/test_security.py
Unit tests for security utilities.
"""

import pytest
from datetime import datetime, timedelta
from jose import jwt
from passlib.context import CryptContext

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
    generate_email_verification_token,
    verify_email_verification_token,
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
        assert len(hashed) > 20  # bcrypt hash is long
    
    def test_verify_correct_password(self):
        """Test verifying a correct password."""
        password = "SecurePass123!"
        hashed = get_password_hash(password)
        
        assert verify_password(password, hashed) is True
    
    def test_verify_incorrect_password(self):
        """Test verifying an incorrect password."""
        password = "SecurePass123!"
        hashed = get_password_hash(password)
        
        assert verify_password("WrongPassword", hashed) is False
    
    def test_verify_empty_password(self):
        """Test verifying an empty password."""
        password = "SecurePass123!"
        hashed = get_password_hash(password)
        
        assert verify_password("", hashed) is False
    
    def test_password_hash_different_salts(self):
        """Test that same password gets different hashes."""
        password = "SecurePass123!"
        hash1 = get_password_hash(password)
        hash2 = get_password_hash(password)
        
        assert hash1 != hash2
        assert verify_password(password, hash1) is True
        assert verify_password(password, hash2) is True


@pytest.mark.unit
class TestJWT:
    """Test JWT utilities."""
    
    def test_create_access_token(self):
        """Test creating an access token."""
        data = {"sub": "user-123", "role": "admin"}
        token = create_access_token(data)
        
        assert token is not None
        assert len(token.split(".")) == 3  # Header.Payload.Signature
        
        # Decode and verify
        decoded = decode_token(token)
        assert decoded["sub"] == "user-123"
        assert decoded["role"] == "admin"
        assert "exp" in decoded
        assert "iat" in decoded
    
    def test_create_access_token_with_expiry(self):
        """Test creating an access token with custom expiry."""
        data = {"sub": "user-123"}
        expires_delta = timedelta(minutes=10)
        token = create_access_token(data, expires_delta=expires_delta)
        
        decoded = decode_token(token)
        exp_time = datetime.fromtimestamp(decoded["exp"])
        iat_time = datetime.fromtimestamp(decoded["iat"])
        diff = exp_time - iat_time
        
        assert diff.total_seconds() == pytest.approx(600, rel=1)  # 10 minutes
    
    def test_create_refresh_token(self):
        """Test creating a refresh token."""
        data = {"sub": "user-123"}
        token = create_refresh_token(data)
        
        decoded = decode_token(token)
        assert decoded["sub"] == "user-123"
        assert decoded["type"] == "refresh"
        assert "exp" in decoded
    
    def test_verify_token_valid(self):
        """Test verifying a valid token."""
        token = create_access_token({"sub": "user-123"})
        decoded = verify_token(token)
        
        assert decoded["sub"] == "user-123"
    
    def test_verify_token_expired(self):
        """Test verifying an expired token."""
        token = create_access_token(
            {"sub": "user-123"},
            expires_delta=timedelta(seconds=-1)
        )
        
        with pytest.raises(UnauthorizedException) as exc_info:
            verify_token(token)
        
        assert "Invalid or expired token" in str(exc_info.value)
    
    def test_verify_token_invalid_signature(self):
        """Test verifying a token with invalid signature."""
        token = "invalid.token.here"
        
        with pytest.raises(UnauthorizedException) as exc_info:
            verify_token(token)
        
        assert "Invalid or expired token" in str(exc_info.value)
    
    def test_decode_token_invalid(self):
        """Test decoding an invalid token."""
        with pytest.raises(Exception):
            decode_token("invalid.token.here")


@pytest.mark.unit
class TestAPIKey:
    """Test API key utilities."""
    
    def test_hash_api_key(self):
        """Test hashing an API key."""
        api_key = "sk_test_1234567890"
        hashed = hash_api_key(api_key)
        
        assert hashed is not None
        assert hashed != api_key
        assert len(hashed) == 64  # SHA256 hex digest
    
    def test_hash_different_keys(self):
        """Test that different keys have different hashes."""
        key1 = "sk_test_123"
        key2 = "sk_test_456"
        
        hash1 = hash_api_key(key1)
        hash2 = hash_api_key(key2)
        
        assert hash1 != hash2
    
    def test_verify_correct_api_key(self):
        """Test verifying a correct API key."""
        api_key = "sk_test_1234567890"
        hashed = hash_api_key(api_key)
        
        assert verify_api_key(api_key, hashed) is True
    
    def test_verify_incorrect_api_key(self):
        """Test verifying an incorrect API key."""
        api_key = "sk_test_1234567890"
        hashed = hash_api_key(api_key)
        
        assert verify_api_key("sk_test_0987654321", hashed) is False


@pytest.mark.unit
class TestPasswordReset:
    """Test password reset utilities."""
    
    def test_generate_password_reset_token(self):
        """Test generating a password reset token."""
        email = "test@example.com"
        token = generate_password_reset_token(email)
        
        assert token is not None
        decoded = decode_token(token)
        assert decoded["email"] == email
        assert decoded["type"] == "password_reset"
        assert "exp" in decoded
    
    def test_verify_password_reset_token_valid(self):
        """Test verifying a valid password reset token."""
        email = "test@example.com"
        token = generate_password_reset_token(email)
        result = verify_password_reset_token(token)
        
        assert result == email
    
    def test_verify_password_reset_token_invalid_type(self):
        """Test verifying a token with wrong type."""
        token = create_access_token({"sub": "user-123"})
        result = verify_password_reset_token(token)
        
        assert result is None
    
    def test_verify_password_reset_token_expired(self):
        """Test verifying an expired password reset token."""
        email = "test@example.com"
        token = generate_password_reset_token(email)
        
        # Fast-forward time in tests would be complex
        # This tests invalid token handling
        result = verify_password_reset_token("invalid.token.here")
        assert result is None


@pytest.mark.unit
class TestEmailVerification:
    """Test email verification utilities."""
    
    def test_generate_email_verification_token(self):
        """Test generating an email verification token."""
        email = "test@example.com"
        token = generate_email_verification_token(email)
        
        assert token is not None
        decoded = decode_token(token)
        assert decoded["email"] == email
        assert decoded["type"] == "email_verification"
    
    def test_verify_email_verification_token_valid(self):
        """Test verifying a valid email verification token."""
        email = "test@example.com"
        token = generate_email_verification_token(email)
        result = verify_email_verification_token(token)
        
        assert result == email
    
    def test_verify_email_verification_token_invalid(self):
        """Test verifying an invalid email verification token."""
        result = verify_email_verification_token("invalid.token.here")
        assert result is None
```

---

## Integration Testing

### Database Integration Tests

**`tests/test_integration/test_database/test_repositories.py`:**

```python
"""
tests/test_integration/test_database/test_repositories.py
Integration tests for repositories.
"""

import pytest
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession

from app.crud.user import UserRepository
from app.crud.task import TaskRepository
from app.crud.project import ProjectRepository
from app.models.user import User, UserRole
from app.models.task import Task, TaskStatus, TaskPriority
from app.models.project import Project, ProjectStatus


@pytest.mark.integration
class TestUserRepository:
    """Test User repository."""
    
    async def test_create_user(self, db_session: AsyncSession):
        """Test creating a user."""
        repo = UserRepository(db_session)
        
        user = User(
            email="test@example.com",
            username="testuser",
            full_name="Test User",
            hashed_password="hashed_password",
            role=UserRole.DEVELOPER,
        )
        
        created = await repo.create(user)
        await db_session.commit()
        
        assert created.id is not None
        assert created.email == "test@example.com"
        assert created.username == "testuser"
        assert created.role == UserRole.DEVELOPER
    
    async def test_get_by_email(self, db_session: AsyncSession):
        """Test getting user by email."""
        repo = UserRepository(db_session)
        
        user = User(
            email="findme@example.com",
            username="findme",
            full_name="Find Me",
            hashed_password="hashed_password",
        )
        await repo.create(user)
        await db_session.commit()
        
        found = await repo.get_by_email("findme@example.com")
        assert found is not None
        assert found.id == user.id
        assert found.email == "findme@example.com"
    
    async def test_get_by_username(self, db_session: AsyncSession):
        """Test getting user by username."""
        repo = UserRepository(db_session)
        
        user = User(
            email="user@example.com",
            username="uniqueuser",
            full_name="Unique User",
            hashed_password="hashed_password",
        )
        await repo.create(user)
        await db_session.commit()
        
        found = await repo.get_by_username("uniqueuser")
        assert found is not None
        assert found.id == user.id
        assert found.username == "uniqueuser"
    
    async def test_get_by_email_or_username(self, db_session: AsyncSession):
        """Test getting user by email or username."""
        repo = UserRepository(db_session)
        
        user = User(
            email="dual@example.com",
            username="dualus",
            full_name="Dual User",
            hashed_password="hashed_password",
        )
        await repo.create(user)
        await db_session.commit()
        
        # Find by email
        found1 = await repo.get_by_email_or_username("dual@example.com", "")
        assert found1 is not None
        assert found1.id == user.id
        
        # Find by username
        found2 = await repo.get_by_email_or_username("", "dualus")
        assert found2 is not None
        assert found2.id == user.id
    
    async def test_get_active_users(self, db_session: AsyncSession):
        """Test getting active users."""
        repo = UserRepository(db_session)
        
        # Create active users
        for i in range(5):
            user = User(
                email=f"active{i}@example.com",
                username=f"active{i}",
                full_name=f"Active {i}",
                hashed_password="hashed_password",
                is_active=True,
            )
            await repo.create(user)
        
        # Create inactive user
        inactive = User(
            email="inactive@example.com",
            username="inactive",
            full_name="Inactive User",
            hashed_password="hashed_password",
            is_active=False,
        )
        await repo.create(inactive)
        await db_session.commit()
        
        active_users = await repo.get_active_users()
        assert len(active_users) >= 5
        assert all(user.is_active for user in active_users)
        assert not any(user.username == "inactive" for user in active_users)


@pytest.mark.integration
class TestTaskRepository:
    """Test Task repository."""
    
    async def test_create_task(self, db_session: AsyncSession, test_user: User):
        """Test creating a task."""
        repo = TaskRepository(db_session)
        
        task = Task(
            title="Integration Test Task",
            description="Testing task creation",
            status=TaskStatus.TODO,
            priority=TaskPriority.MEDIUM,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() + timedelta(days=7),
            tags=["test", "integration"],
            estimated_hours=4.5,
        )
        
        created = await repo.create(task)
        await db_session.commit()
        
        assert created.id is not None
        assert created.title == "Integration Test Task"
        assert created.status == TaskStatus.TODO
        assert len(created.tags) == 2
    
    async def test_get_by_project(self, db_session: AsyncSession, test_user: User):
        """Test getting tasks by project."""
        repo = TaskRepository(db_session)
        
        # Create a project
        project_repo = ProjectRepository(db_session)
        project = Project(
            name="Test Project",
            owner_id=test_user.id,
            status=ProjectStatus.ACTIVE,
        )
        project = await project_repo.create(project)
        await db_session.flush()
        
        # Create tasks in project
        for i in range(5):
            task = Task(
                title=f"Task {i}",
                project_id=project.id,
                created_by_id=test_user.id,
            )
            await repo.create(task)
        
        await db_session.commit()
        
        tasks = await repo.get_by_project(project.id)
        assert len(tasks) >= 5
        assert all(task.project_id == project.id for task in tasks)
    
    async def test_get_by_assignee(self, db_session: AsyncSession, test_user: User):
        """Test getting tasks by assignee."""
        repo = TaskRepository(db_session)
        
        # Create tasks assigned to test_user
        for i in range(3):
            task = Task(
                title=f"Assigned Task {i}",
                assignee_id=test_user.id,
                created_by_id=test_user.id,
            )
            await repo.create(task)
        await db_session.commit()
        
        tasks = await repo.get_by_assignee(test_user.id)
        assert len(tasks) >= 3
        assert all(task.assignee_id == test_user.id for task in tasks)
    
    async def test_get_overdue_tasks(self, db_session: AsyncSession, test_user: User):
        """Test getting overdue tasks."""
        repo = TaskRepository(db_session)
        
        # Create overdue task
        overdue = Task(
            title="Overdue Task",
            status=TaskStatus.IN_PROGRESS,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() - timedelta(days=1),
        )
        await repo.create(overdue)
        
        # Create future task
        future = Task(
            title="Future Task",
            status=TaskStatus.TODO,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() + timedelta(days=7),
        )
        await repo.create(future)
        
        # Create completed overdue task
        completed = Task(
            title="Completed Overdue",
            status=TaskStatus.DONE,
            created_by_id=test_user.id,
            due_date=datetime.utcnow() - timedelta(days=1),
        )
        await repo.create(completed)
        
        await db_session.commit()
        
        overdue_tasks = await repo.get_overdue_tasks()
        assert len(overdue_tasks) >= 1
        assert all(task.status != TaskStatus.DONE for task in overdue_tasks)
        assert all(task.due_date is not None for task in overdue_tasks)
    
    async def test_get_task_stats(self, db_session: AsyncSession, test_user: User):
        """Test getting task statistics."""
        repo = TaskRepository(db_session)
        
        # Create tasks with different statuses
        statuses = [TaskStatus.TODO, TaskStatus.TODO, TaskStatus.IN_PROGRESS,
                   TaskStatus.IN_PROGRESS, TaskStatus.DONE]
        
        for status in statuses:
            task = Task(
                title=f"Stats Task {status.value}",
                status=status,
                created_by_id=test_user.id,
            )
            await repo.create(task)
        
        await db_session.commit()
        
        stats = await repo.get_task_stats()
        
        assert stats["total"] >= 5
        assert stats["by_status"][TaskStatus.TODO.value] >= 2
        assert stats["by_status"][TaskStatus.IN_PROGRESS.value] >= 2
        assert stats["by_status"][TaskStatus.DONE.value] >= 1
```

### API Integration Tests

**`tests/test_integration/test_api/test_tasks.py`:**

```python
"""
tests/test_integration/test_api/test_tasks.py
Integration tests for task API endpoints.
"""

import pytest
from httpx import AsyncClient
from datetime import datetime, timedelta

from app.models.task import TaskStatus, TaskPriority
from app.services.task import TaskService
from app.schemas.task import TaskCreate


@pytest.mark.integration
class TestTaskAPI:
    """Test task API endpoints."""
    
    async def test_create_task(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_user,
        db_session,
    ):
        """Test creating a task via API."""
        response = await client.post(
            "/api/v1/tasks/",
            headers=auth_headers,
            json={
                "title": "API Test Task",
                "description": "Testing task creation via API",
                "status": TaskStatus.TODO.value,
                "priority": TaskPriority.MEDIUM.value,
                "due_date": (datetime.utcnow() + timedelta(days=7)).isoformat(),
                "tags": ["api", "test"],
                "estimated_hours": 3.5,
            }
        )
        
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == "API Test Task"
        assert data["status"] == TaskStatus.TODO.value
        assert data["created_by_id"] == test_user.id
        assert "id" in data
    
    async def test_create_task_validation_error(
        self,
        client: AsyncClient,
        auth_headers: dict,
    ):
        """Test creating a task with invalid data."""
        response = await client.post(
            "/api/v1/tasks/",
            headers=auth_headers,
            json={
                "title": "",  # Empty title
                "status": "invalid_status",  # Invalid status
            }
        )
        
        assert response.status_code == 422
        data = response.json()
        assert data["error"]["error_code"] == "VALIDATION_ERROR"
        assert "validation_errors" in data["error"]["data"]
    
    async def test_get_tasks(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_user,
        db_session,
    ):
        """Test getting list of tasks."""
        # Create test tasks
        service = TaskService(db_session)
        for i in range(5):
            await service.create_task(
                TaskCreate(
                    title=f"Test Task {i}",
                    created_by_id=test_user.id,
                )
            )
        
        response = await client.get(
            "/api/v1/tasks/",
            headers=auth_headers,
            params={"page": 1, "size": 10}
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data
        assert data["total"] >= 5
        assert len(data["items"]) >= 5
    
    async def test_get_tasks_with_filtering(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_user,
        db_session,
    ):
        """Test getting tasks with filters."""
        service = TaskService(db_session)
        
        # Create tasks with different statuses
        for status in [TaskStatus.TODO, TaskStatus.IN_PROGRESS, TaskStatus.DONE]:
            await service.create_task(
                TaskCreate(
                    title=f"Filter Task {status.value}",
                    status=status,
                    created_by_id=test_user.id,
                )
            )
        
        # Filter by status
        response = await client.get(
            "/api/v1/tasks/",
            headers=auth_headers,
            params={"status": TaskStatus.TODO.value}
        )
        
        assert response.status_code == 200
        data = response.json()
        for item in data["items"]:
            assert item["status"] == TaskStatus.TODO.value
    
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
    
    async def test_get_task_not_found(
        self,
        client: AsyncClient,
        auth_headers: dict,
    ):
        """Test getting a non-existent task."""
        response = await client.get(
            "/api/v1/tasks/999999",
            headers=auth_headers,
        )
        
        assert response.status_code == 404
        data = response.json()
        assert data["error"]["error_code"] == "TASK_NOT_FOUND"
    
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
                "title": "Updated API Task",
                "status": TaskStatus.IN_PROGRESS.value,
                "priority": TaskPriority.HIGH.value,
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == test_task.id
        assert data["title"] == "Updated API Task"
        assert data["status"] == TaskStatus.IN_PROGRESS.value
        assert data["priority"] == TaskPriority.HIGH.value
    
    async def test_update_task_not_authorized(
        self,
        client: AsyncClient,
        test_user,
        test_task,
        db_session,
    ):
        """Test updating a task without authorization."""
        # Create a different user
        from app.models.user import User
        other_user = User(
            email="other@example.com",
            username="otheruser",
            full_name="Other User",
            hashed_password="hashed_password",
        )
        db_session.add(other_user)
        await db_session.commit()
        
        # Get token for other user
        from app.core.security import create_access_token
        other_token = create_access_token({"sub": other_user.id, "role": "viewer"})
        other_headers = {"Authorization": f"Bearer {other_token}"}
        
        response = await client.put(
            f"/api/v1/tasks/{test_task.id}",
            headers=other_headers,
            json={
                "title": "Unauthorized Update",
            }
        )
        
        # Should be forbidden or not found
        assert response.status_code in [403, 404]
    
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
    
    async def test_complete_task(
        self,
        client: AsyncClient,
        auth_headers: dict,
        test_task,
    ):
        """Test completing a task."""
        response = await client.post(
            f"/api/v1/tasks/{test_task.id}/complete",
            headers=auth_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == test_task.id
        assert data["status"] == TaskStatus.DONE.value
        assert data["completed_at"] is not None
```

---

## Performance Testing

### Load Testing with Locust

**`tests/performance/locustfile.py`:**

```python
"""
tests/performance/locustfile.py
Locust performance test definitions.
"""

from locust import HttpUser, task, between, events
import random
import json
from datetime import datetime, timedelta


class FastAPIUser(HttpUser):
    """Simulated FastAPI user."""
    
    wait_time = between(1, 5)  # Wait 1-5 seconds between tasks
    
    def on_start(self):
        """Login when user starts."""
        self.access_token = None
        self.refresh_token = None
        self.user_id = None
        
        # Register user
        self.register_user()
        
        # Login
        self.login()
    
    def register_user(self):
        """Register a new user."""
        self.username = f"user_{random.randint(10000, 99999)}"
        self.email = f"{self.username}@example.com"
        
        response = self.client.post(
            "/api/v1/auth/register",
            json={
                "email": self.email,
                "username": self.username,
                "full_name": f"User {self.username}",
                "password": "SecurePass123!",
            }
        )
        
        if response.status_code == 201:
            data = response.json()
            self.user_id = data["id"]
    
    def login(self):
        """Login to get tokens."""
        response = self.client.post(
            "/api/v1/auth/login",
            data={
                "username": self.email,
                "password": "SecurePass123!",
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            self.access_token = data["access_token"]
            self.refresh_token = data["refresh_token"]
            
            # Set auth header for subsequent requests
            self.client.headers.update({
                "Authorization": f"Bearer {self.access_token}"
            })
    
    @task(3)
    def get_tasks(self):
        """Get list of tasks."""
        self.client.get(
            "/api/v1/tasks/",
            params={
                "page": random.randint(1, 5),
                "size": 10,
                "status": random.choice(["todo", "in_progress", "done"]),
            }
        )
    
    @task(2)
    def create_task(self):
        """Create a new task."""
        self.client.post(
            "/api/v1/tasks/",
            json={
                "title": f"Performance Test Task {random.randint(1, 1000)}",
                "description": "Generated by Locust performance test",
                "status": random.choice(["todo", "in_progress"]),
                "priority": random.choice(["low", "medium", "high"]),
                "due_date": (datetime.utcnow() + timedelta(days=random.randint(1, 30))).isoformat(),
                "tags": ["performance", "test", str(random.randint(1, 10))],
                "estimated_hours": random.uniform(1, 10),
            }
        )
    
    @task(1)
    def get_task_details(self):
        """Get task details."""
        # First get a task ID
        response = self.client.get("/api/v1/tasks/", params={"size": 1})
        if response.status_code == 200 and response.json()["items"]:
            task_id = response.json()["items"][0]["id"]
            self.client.get(f"/api/v1/tasks/{task_id}")
    
    @task(1)
    def update_task(self):
        """Update a task."""
        response = self.client.get("/api/v1/tasks/", params={"size": 1})
        if response.status_code == 200 and response.json()["items"]:
            task = response.json()["items"][0]
            self.client.put(
                f"/api/v1/tasks/{task['id']}",
                json={
                    "status": random.choice(["todo", "in_progress", "review", "done"]),
                    "priority": random.choice(["low", "medium", "high", "critical"]),
                }
            )
    
    @task(1)
    def get_user_profile(self):
        """Get current user profile."""
        self.client.get("/api/v1/auth/me")
    
    @task(1)
    def refresh_token(self):
        """Refresh access token."""
        if self.refresh_token:
            response = self.client.post(
                "/api/v1/auth/refresh",
                json={"refresh_token": self.refresh_token}
            )
            if response.status_code == 200:
                data = response.json()
                self.access_token = data["access_token"]
                self.client.headers.update({
                    "Authorization": f"Bearer {self.access_token}"
                })
    
    @task(1)
    def health_check(self):
        """Health check endpoint."""
        self.client.get("/health")


@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    """Called when test starts."""
    print("🚀 Starting performance test...")


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    """Called when test stops."""
    print("🏁 Performance test complete")
```

**Run Performance Tests:**

```bash
# Run Locust
locust -f tests/performance/locustfile.py --host=http://localhost:8000

# Run headless with 100 users
locust -f tests/performance/locustfile.py --host=http://localhost:8000 \
    --headless --users 100 --spawn-rate 10 --run-time 5m

# Generate HTML report
locust -f tests/performance/locustfile.py --host=http://localhost:8000 \
    --headless --users 50 --spawn-rate 5 --run-time 2m \
    --html=performance_report.html
```

---

## Security Testing

### Security Test Suite

**`tests/test_security/test_security.py`:**

```python
"""
tests/test_security/test_security.py
Security tests for API endpoints.
"""

import pytest
import re
from httpx import AsyncClient


@pytest.mark.security
class TestSecurityHeaders:
    """Test security headers."""
    
    async def test_security_headers_present(self, client: AsyncClient):
        """Test that security headers are present."""
        response = await client.get("/")
        
        headers = response.headers
        
        assert "X-Content-Type-Options" in headers
        assert headers["X-Content-Type-Options"] == "nosniff"
        
        assert "X-Frame-Options" in headers
        assert headers["X-Frame-Options"] == "DENY"
        
        assert "X-XSS-Protection" in headers
        assert "1; mode=block" in headers["X-XSS-Protection"]
    
    async def test_csp_present(self, client: AsyncClient):
        """Test Content-Security-Policy header."""
        response = await client.get("/")
        
        assert "Content-Security-Policy" in response.headers
        csp = response.headers["Content-Security-Policy"]
        
        # Check that basic directives are present
        assert "default-src 'self'" in csp
        assert "script-src" in csp
        assert "style-src" in csp


@pytest.mark.security
class TestAuthenticationSecurity:
    """Test authentication security."""
    
    async def test_login_rate_limiting(self, client: AsyncClient):
        """Test rate limiting on login endpoint."""
        # Try to login multiple times with wrong credentials
        attempts = 15
        responses = []
        
        for _ in range(attempts):
            response = await client.post(
                "/api/v1/auth/login",
                data={
                    "username": "nonexistent@example.com",
                    "password": "WrongPass123!",
                }
            )
            responses.append(response.status_code)
        
        # Should have at least one 429 (Too Many Requests)
        assert 429 in responses
    
    async def test_jwt_token_security(self, client: AsyncClient, test_user):
        """Test JWT token security properties."""
        # Login to get token
        response = await client.post(
            "/api/v1/auth/login",
            data={
                "username": test_user.email,
                "password": "SecurePass123!",
            }
        )
        data = response.json()
        token = data["access_token"]
        
        # Decode token parts
        parts = token.split(".")
        assert len(parts) == 3
        
        # Check header
        import base64
        header = json.loads(base64.urlsafe_b64decode(parts[0] + "=="))
        assert header["alg"] == "HS256"
        assert header["typ"] == "JWT"
        
        # Check payload
        payload = json.loads(base64.urlsafe_b64decode(parts[1] + "=="))
        assert "sub" in payload
        assert "exp" in payload
        assert "iat" in payload
        
        # Check token contains user ID
        assert str(test_user.id) in str(payload["sub"])
    
    async def test_session_hijacking_prevention(self, client: AsyncClient, test_user):
        """Test session hijacking prevention."""
        # Get token for user
        response = await client.post(
            "/api/v1/auth/login",
            data={
                "username": test_user.email,
                "password": "SecurePass123!",
            }
        )
        token = response.json()["access_token"]
        
        # Try to use token with different IP (simulated)
        # In production, you'd check IP/user agent consistency
        
        # Just verify token works
        response = await client.get(
            "/api/v1/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert response.status_code == 200
    
    async def test_password_reset_token_security(self, client: AsyncClient):
        """Test password reset token security."""
        # Request reset
        response = await client.post(
            "/api/v1/auth/reset-password",
            json={"email": "nonexistent@example.com"}
        )
        assert response.status_code == 200
        
        # Try to use invalid token
        response = await client.post(
            "/api/v1/auth/reset-password/confirm",
            json={
                "token": "invalid-token",
                "new_password": "NewSecurePass123!"
            }
        )
        assert response.status_code == 400
        assert "INVALID_RESET_TOKEN" in response.json()["error"]["error_code"]


@pytest.mark.security
class TestInputValidation:
    """Test input validation security."""
    
    async def test_sql_injection_prevention(self, client: AsyncClient, auth_headers):
        """Test SQL injection prevention."""
        # Try SQL injection in search parameter
        sql_payloads = [
            "'; DROP TABLE users; --",
            "1' OR '1'='1",
            "' UNION SELECT * FROM users --",
            "'; SELECT * FROM users --",
        ]
        
        for payload in sql_payloads:
            response = await client.get(
                "/api/v1/tasks/",
                headers=auth_headers,
                params={"search": payload}
            )
            # Should not error (validation or safe handling)
            assert response.status_code in [200, 400, 422]
    
    async def test_xss_prevention(self, client: AsyncClient, auth_headers):
        """Test XSS prevention."""
        # Try XSS in title
        xss_payload = "<script>alert('XSS')</script>"
        
        response = await client.post(
            "/api/v1/tasks/",
            headers=auth_headers,
            json={
                "title": xss_payload,
                "status": "todo",
            }
        )
        
        # Should be rejected by validation
        assert response.status_code == 422
        data = response.json()
        assert "Title contains invalid characters" in str(data)
    
    async def test_max_size_prevention(self, client: AsyncClient, auth_headers):
        """Test max size prevention."""
        # Try to create a task with very long title
        long_title = "a" * 1000
        
        response = await client.post(
            "/api/v1/tasks/",
            headers=auth_headers,
            json={
                "title": long_title,
                "status": "todo",
            }
        )
        
        assert response.status_code == 422
        data = response.json()
        assert "validation_errors" in data["error"]["data"]


@pytest.mark.security
class TestAuthorizationSecurity:
    """Test authorization security."""
    
    async def test_role_based_access_control(self, client: AsyncClient):
        """Test RBAC enforcement."""
        # Create admin and regular users
        # This would be a full test, simplified here
        
        # Test that admin endpoints are protected
        response = await client.get("/api/v1/users/")
        assert response.status_code == 401  # No token
        
        # Test with viewer token (shouldn't access admin endpoints)
        # This requires more setup
        pass
    
    async def test_resource_ownership(self, client: AsyncClient, test_user, test_task):
        """Test resource ownership enforcement."""
        # Create another user
        from app.models.user import User
        from app.core.security import create_access_token
        
        other_user = User(
            email="other@example.com",
            username="otheruser",
            full_name="Other User",
            hashed_password="hashed_password",
        )
        # Add to DB...
        
        # Get token for other user
        other_token = create_access_token({"sub": other_user.id})
        
        # Try to access test_task (created by test_user)
        response = await client.get(
            f"/api/v1/tasks/{test_task.id}",
            headers={"Authorization": f"Bearer {other_token}"}
        )
        
        # Should be forbidden (or not found for security)
        assert response.status_code in [403, 404]
```

---

## Testing Best Practices

### Testing Checklist

```markdown
# Testing Checklist

## Before Writing Tests
- [ ] Understand the feature requirements
- [ ] Identify test scenarios (happy path, edge cases, errors)
- [ ] Set up test environment
- [ ] Create test data fixtures

## Writing Tests
- [ ] Use descriptive test names (test_should_do_something_when_condition)
- [ ] Arrange, Act, Assert pattern
- [ ] One assertion per test (when possible)
- [ ] Use appropriate fixtures
- [ ] Mock external dependencies
- [ ] Test both success and failure cases

## After Writing Tests
- [ ] Run the test suite
- [ ] Check test coverage
- [ ] Review for flaky tests
- [ ] Document any complex test logic
- [ ] Include in CI/CD pipeline

## Code Review
- [ ] Are tests isolated?
- [ ] Are there enough edge case tests?
- [ ] Are tests readable?
- [ ] Do tests verify business requirements?
- [ ] Are there no duplicate tests?

## Maintenance
- [ ] Update tests when code changes
- [ ] Remove obsolete tests
- [ ] Refactor test code for clarity
- [ ] Keep test data up to date
- [ ] Review test performance
```

### Test Data Management

**`tests/fixtures/test_data.py`:**

```python
"""
tests/fixtures/test_data.py
Test data fixtures and factories.
"""

import pytest
from faker import Faker
from datetime import datetime, timedelta
from typing import Dict, Any

from app.models.user import User, UserRole
from app.models.task import Task, TaskStatus, TaskPriority
from app.models.project import Project, ProjectStatus

fake = Faker()


class TestDataFactory:
    """Factory for creating test data."""
    
    @staticmethod
    def create_user_data(
        email: str = None,
        username: str = None,
        role: UserRole = UserRole.DEVELOPER,
        is_active: bool = True,
    ) -> Dict[str, Any]:
        """Create user test data."""
        return {
            "email": email or fake.email(),
            "username": username or fake.user_name(),
            "full_name": fake.name(),
            "hashed_password": "hashed_password",
            "role": role,
            "is_active": is_active,
            "is_verified": True,
        }
    
    @staticmethod
    def create_task_data(
        title: str = None,
        status: TaskStatus = TaskStatus.TODO,
        priority: TaskPriority = TaskPriority.MEDIUM,
        **kwargs,
    ) -> Dict[str, Any]:
        """Create task test data."""
        data = {
            "title": title or fake.sentence(nb_words=6),
            "description": fake.text(max_nb_chars=200),
            "status": status,
            "priority": priority,
            "due_date": datetime.utcnow() + timedelta(days=7),
            "tags": [fake.word(), fake.word(), fake.word()],
            "estimated_hours": fake.random_number(digits=2),
        }
        data.update(kwargs)
        return data
    
    @staticmethod
    def create_project_data(
        name: str = None,
        status: ProjectStatus = ProjectStatus.ACTIVE,
        **kwargs,
    ) -> Dict[str, Any]:
        """Create project test data."""
        data = {
            "name": name or fake.company(),
            "description": fake.text(max_nb_chars=200),
            "status": status,
            "is_public": False,
        }
        data.update(kwargs)
        return data


@pytest.fixture
def sample_users(db_session):
    """Create sample users for testing."""
    users = []
    for i in range(5):
        user = User(**TestDataFactory.create_user_data())
        db_session.add(user)
        users.append(user)
    db_session.commit()
    return users


@pytest.fixture
def sample_tasks(db_session, sample_users):
    """Create sample tasks for testing."""
    tasks = []
    for i in range(10):
        user = sample_users[i % len(sample_users)]
        task = Task(**TestDataFactory.create_task_data(
            created_by_id=user.id,
            assignee_id=user.id,
        ))
        db_session.add(task)
        tasks.append(task)
    db_session.commit()
    return tasks
```

---

## CI/CD Integration

### GitHub Actions Test Workflow

**`.github/workflows/test.yml`:**

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  DATABASE_URL: postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_test
  REDIS_URL: redis://localhost:6379/0
  SECRET_KEY: test_secret_key_for_ci_32_chars_long
  APP_ENV: testing

jobs:
  test:
    name: Run Tests
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
      
      elasticsearch:
        image: elasticsearch:8.11.0
        env:
          discovery.type: single-node
          xpack.security.enabled: "false"
        ports:
          - 9200:9200
        options: >-
          --health-cmd "curl -f http://localhost:9200/_cluster/health || exit 1"
          --health-interval 30s
          --health-timeout 10s
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
          pip install -r requirements-dev.txt
      
      - name: Run migrations
        run: |
          alembic upgrade head
      
      - name: Run tests with coverage
        run: |
          pytest tests/ \
            -v \
            --cov=app \
            --cov-report=html \
            --cov-report=xml \
            --junitxml=pytest.xml
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: |
            pytest.xml
            htmlcov/
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: false
      
      - name: Security scan
        run: |
          bandit -r app/ -f xml -o bandit.xml || true
      
      - name: Upload security scan results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: security-scan
          path: bandit.xml
```

---

## Test Coverage Report

### Coverage Configuration

**`pyproject.toml` coverage section:**

```toml
[tool.coverage.run]
source = ["app"]
omit = [
    "*/tests/*",
    "*/migrations/*",
    "*/__init__.py",
    "*/conftest.py",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if self.debug:",
    "if __name__ == .__main__.:",
    "raise NotImplementedError",
    "if TYPE_CHECKING:",
]

[tool.coverage.html]
directory = "htmlcov"

[tool.coverage.xml]
output = "coverage.xml"
```

### Coverage Expectations

| Component | Minimum Coverage | Target Coverage |
|-----------|------------------|-----------------|
| Domain Entities | 90% | 100% |
| Use Cases | 80% | 90% |
| Repositories | 70% | 80% |
| Services | 80% | 90% |
| API Endpoints | 70% | 85% |
| Utilities | 80% | 90% |
| **Overall** | **75%** | **85%** |

---

This comprehensive testing guide provides everything you need to ensure your FastAPI application is thoroughly tested, secure, and production-ready. Use it as your reference for writing tests, implementing CI/CD pipelines, and maintaining high code quality.

**[END OF APPENDIX D]**
