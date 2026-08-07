# Part 2: Database Integration & Data Persistence

Welcome to Part 2 of our FastAPI Masterclass! Now that we have a solid foundation with our API structure, configuration, and validation, it's time to add the backbone of any real application: a database. In this module, we'll integrate PostgreSQL with SQLAlchemy 2.0, design our database schema, implement the Repository pattern for clean data access, and set up Alembic for migrations.

## Learning Objectives

By the end of Part 2, you will be able to:
- Set up SQLAlchemy 2.0 with async PostgreSQL support
- Design database models with relationships, constraints, and indexes
- Implement Alembic migrations for schema versioning
- Build the Repository pattern for abstracted data access
- Create Service layers with business logic
- Implement pagination, filtering, and sorting
- Write database tests with pytest

## Key Concepts Before We Begin

### What is SQLAlchemy?
Think of SQLAlchemy as a translator between your Python code and your database. Instead of writing raw SQL like `SELECT * FROM users WHERE id = 1`, you write Python code like `db.query(User).filter(User.id == 1).first()`. SQLAlchemy handles converting this to the appropriate SQL for your database.

### ORM vs Core
SQLAlchemy 2.0 offers two main approaches:
- **ORM (Object Relational Mapper)**: Maps Python classes to database tables. This is what we'll use—it's the most intuitive and productive way to work with databases.
- **Core**: A lower-level SQL abstraction layer. More flexible but requires more SQL knowledge.

### Async Database Access
FastAPI supports asynchronous operations, and we'll use `asyncpg` to talk to PostgreSQL asynchronously. This means our database operations won't block the event loop, allowing our API to handle more concurrent requests.

## Step 1: Database Setup & Connection

### The Target
Set up PostgreSQL, install required dependencies, and create the database connection with SQLAlchemy 2.0.

### The Concept
Think of the database connection pool as a team of translators. Instead of hiring a new translator (opening a new connection) for every request, we have a pool of translators ready to work. When a request comes in, we assign an available translator, and when they're done, they return to the pool to help with the next request.

### The Implementation

**First, install additional dependencies:**

```bash
# Add these to your requirements.txt
echo "psycopg2-binary==2.9.9" >> requirements.txt
echo "alembic==1.12.1" >> requirements.txt

# Install them
pip install -r requirements.txt
```

**Update your `.env` file with database credentials:**

```env
# Update your .env file
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_db
DATABASE_POOL_SIZE=10
DATABASE_MAX_OVERFLOW=20
DATABASE_ECHO=False
```

**Create `app/core/database.py`:**

```python
"""
app/core/database.py
Database connection and session management using SQLAlchemy 2.0.
"""

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
    AsyncEngine
)
from sqlalchemy.orm import declarative_base, declared_attr
from sqlalchemy import MetaData, text, event
from typing import AsyncGenerator, Optional
import logging

from app.core.config import settings

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────────────────────
# Database Configuration
# ────────────────────────────────────────────────────────────────

# Naming convention for constraints and indexes
# This ensures consistent naming across all tables
convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

metadata = MetaData(naming_convention=convention)


class CustomBase:
    """
    Custom base class for all models.
    
    Provides automatic table naming and common columns.
    """
    
    @declared_attr
    def __tablename__(cls):
        """
        Automatically generate table name from class name.
        
        Converts CamelCase to snake_case and pluralizes.
        Example: UserProfile -> user_profiles
        """
        import re
        name = re.sub(r'(?<!^)(?=[A-Z])', '_', cls.__name__).lower()
        # Pluralize (simple rule - add 's')
        return f"{name}s"
    
    # Common columns will be added in each model
    # We'll use mixins for shared columns


# Create base class with our custom base
Base = declarative_base(cls=CustomBase, metadata=metadata)


# ────────────────────────────────────────────────────────────────
# Database Engine
# ────────────────────────────────────────────────────────────────

def create_database_engine() -> AsyncEngine:
    """
    Create async database engine with connection pooling.
    
    Returns:
        AsyncEngine: Configured database engine
    """
    engine = create_async_engine(
        settings.DATABASE_URL,
        echo=settings.DATABASE_ECHO,
        pool_size=settings.DATABASE_POOL_SIZE,
        max_overflow=settings.DATABASE_MAX_OVERFLOW,
        pool_pre_ping=True,  # Verify connections before using
        pool_recycle=3600,   # Recycle connections after 1 hour
        pool_timeout=30,     # Timeout for getting connection from pool
        # Additional SQLAlchemy 2.0 settings
        future=True,         # Use SQLAlchemy 2.0 style
        # For asyncpg specific configuration
        connect_args={
            "server_settings": {
                "application_name": "fastapi_app",
                "timezone": "UTC",
            }
        },
    )
    
    logger.info(f"✅ Database engine created for {settings.APP_ENV}")
    return engine


# Create the engine instance
engine = create_database_engine()

# Create async session factory
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,  # Don't expire objects after commit
    autocommit=False,
    autoflush=False,
)


# ────────────────────────────────────────────────────────────────
# Session Management
# ────────────────────────────────────────────────────────────────

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency for getting database session.
    
    Yields:
        AsyncSession: Database session for the request
        
    Example:
        @app.get("/users")
        async def get_users(db: AsyncSession = Depends(get_db)):
            ...
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            # Commit will be handled by the caller
        except Exception:
            # Rollback on exception
            await session.rollback()
            raise
        finally:
            # Session will be closed automatically by the context manager
            pass


# ────────────────────────────────────────────────────────────────
# Database Initialization
# ────────────────────────────────────────────────────────────────

async def init_db() -> None:
    """
    Initialize database - create all tables.
    
    This should only be used in development/testing.
    In production, use Alembic migrations.
    """
    if settings.APP_ENV == "production":
        logger.warning("⚠️  init_db() called in production! Use Alembic instead.")
        return
    
    logger.info("📦 Creating database tables...")
    
    async with engine.begin() as conn:
        # Create all tables
        await conn.run_sync(Base.metadata.create_all)
        
        # Enable UUID extension if needed
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""))
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\""))
    
    logger.info("✅ Database tables created successfully")


async def drop_db() -> None:
    """
    Drop all tables.
    
    DANGER: This will delete all data!
    Only use in testing.
    """
    if settings.APP_ENV == "production":
        logger.warning("⚠️  drop_db() called in production! Aborting.")
        return
    
    logger.warning("🗑️  Dropping all database tables...")
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    
    logger.warning("✅ All tables dropped")


async def check_db_connection() -> bool:
    """
    Check if database connection is healthy.
    
    Returns:
        bool: True if connection is healthy, False otherwise
    """
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return True
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return False
```

## Step 2: Database Models

### The Target
Create SQLAlchemy models for Users, Projects, Tasks, and Comments with relationships, constraints, and indexes.

### The Concept
Database models are like blueprints for your data. They define what fields each record has, what type of data they store, and how different records relate to each other. Think of it as designing the structure of a filing cabinet before you start putting files in it.

### The Implementation

**Create `app/models/base.py`** (common model mixins):

```python
"""
app/models/base.py
Base model mixins with common fields and functionality.
"""

from sqlalchemy import Column, DateTime, Integer, func, Index
from sqlalchemy.ext.declarative import declared_attr
from datetime import datetime
from typing import Any, Dict

from app.core.database import Base


class TimestampMixin:
    """
    Mixin that adds created_at and updated_at timestamp fields.
    
    Automatically updates updated_at when the record is modified.
    """
    
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        doc="Creation timestamp",
    )
    
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
        doc="Last update timestamp",
    )


class SoftDeleteMixin:
    """
    Mixin that adds soft delete functionality.
    
    Instead of permanently deleting records, we mark them as deleted.
    """
    
    deleted_at = Column(
        DateTime(timezone=True),
        nullable=True,
        default=None,
        doc="Soft delete timestamp (NULL means not deleted)",
    )
    
    @property
    def is_deleted(self) -> bool:
        """Check if the record is soft-deleted."""
        return self.deleted_at is not None
    
    def soft_delete(self):
        """Mark the record as deleted."""
        self.deleted_at = datetime.utcnow()


class IDMixin:
    """
    Mixin that adds an auto-incrementing primary key.
    """
    
    id = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
        doc="Unique identifier",
    )


class DictMixin:
    """
    Mixin that provides to_dict() method for serialization.
    """
    
    def to_dict(self, exclude: set = None) -> Dict[str, Any]:
        """
        Convert model to dictionary.
        
        Args:
            exclude: Set of field names to exclude
            
        Returns:
            Dict: Model data as dictionary
        """
        exclude = exclude or set()
        exclude.add("_sa_instance_state")  # Exclude SQLAlchemy internal state
        
        result = {}
        for column in self.__table__.columns:
            if column.name in exclude:
                continue
            value = getattr(self, column.name)
            # Convert datetime to ISO format
            if isinstance(value, datetime):
                value = value.isoformat()
            result[column.name] = value
        return result


class BaseModel(Base, IDMixin, TimestampMixin, SoftDeleteMixin, DictMixin):
    """
    Base model that combines all mixins.
    
    All models should inherit from this.
    """
    
    __abstract__ = True  # This is an abstract base class
    
    # Add an index on created_at for efficient sorting
    __table_args__ = (
        Index("ix_created_at", "created_at"),
    )
```

**Create `app/models/user.py`:**

```python
"""
app/models/user.py
User model for authentication and authorization.
"""

from sqlalchemy import Column, String, Boolean, DateTime, Integer, Enum, Text, Index
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
import enum

from app.models.base import BaseModel


class UserRole(str, enum.Enum):
    """User roles for RBAC."""
    ADMIN = "admin"
    MANAGER = "manager"
    DEVELOPER = "developer"
    VIEWER = "viewer"


class User(BaseModel):
    """
    User model representing system users.
    
    Attributes:
        email: Unique email address (used for login)
        username: Unique username (used for display)
        hashed_password: bcrypt hashed password
        full_name: User's full name
        role: User role for authorization
        is_active: Whether the user account is active
        is_verified: Whether the email has been verified
        last_login: Timestamp of last login
        phone_number: Optional phone number
        avatar_url: URL to profile picture
        bio: User bio/description
    """
    
    __tablename__ = "users"
    
    # ──────────────── Core Fields ────────────────
    email = Column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
        doc="User's email address (used for login)",
    )
    
    username = Column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
        doc="Unique username for display",
    )
    
    hashed_password = Column(
        String(255),
        nullable=False,
        doc="bcrypt hashed password",
    )
    
    full_name = Column(
        String(100),
        nullable=False,
        doc="User's full name",
    )
    
    # ──────────────── Roles & Permissions ────────────────
    role = Column(
        Enum(UserRole),
        nullable=False,
        default=UserRole.VIEWER,
        doc="User role for RBAC",
    )
    
    is_active = Column(
        Boolean,
        nullable=False,
        default=True,
        doc="Whether the user account is active",
    )
    
    is_verified = Column(
        Boolean,
        nullable=False,
        default=False,
        doc="Whether the email has been verified",
    )
    
    is_superuser = Column(
        Boolean,
        nullable=False,
        default=False,
        doc="Whether the user has superuser privileges",
    )
    
    # ──────────────── Profile Information ────────────────
    phone_number = Column(
        String(20),
        nullable=True,
        doc="Contact phone number",
    )
    
    avatar_url = Column(
        String(500),
        nullable=True,
        doc="URL to profile picture",
    )
    
    bio = Column(
        Text,
        nullable=True,
        doc="User biography",
    )
    
    # ──────────────── Activity Tracking ────────────────
    last_login = Column(
        DateTime(timezone=True),
        nullable=True,
        doc="Timestamp of last login",
    )
    
    login_count = Column(
        Integer,
        nullable=False,
        default=0,
        doc="Number of times user has logged in",
    )
    
    # ──────────────── Relationships ────────────────
    
    # Tasks created by this user
    created_tasks = relationship(
        "Task",
        foreign_keys="Task.created_by_id",
        back_populates="creator",
        lazy="select",
        cascade="all, delete-orphan",
        doc="Tasks created by this user",
    )
    
    # Tasks assigned to this user
    assigned_tasks = relationship(
        "Task",
        foreign_keys="Task.assignee_id",
        back_populates="assignee",
        lazy="select",
        doc="Tasks assigned to this user",
    )
    
    # Projects this user is a member of
    projects = relationship(
        "ProjectMember",
        back_populates="user",
        lazy="select",
        cascade="all, delete-orphan",
        doc="Projects this user is a member of",
    )
    
    # Comments by this user
    comments = relationship(
        "Comment",
        back_populates="author",
        lazy="select",
        cascade="all, delete-orphan",
        doc="Comments by this user",
    )
    
    # ──────────────── Indexes ────────────────
    __table_args__ = (
        Index("ix_users_email_username", "email", "username"),
        Index("ix_users_role", "role"),
        Index("ix_users_is_active", "is_active"),
    )
    
    def __repr__(self) -> str:
        """String representation of the user."""
        return f"<User(id={self.id}, username='{self.username}', email='{self.email}')>"
    
    @property
    def display_name(self) -> str:
        """Display name (full name or username)."""
        return self.full_name or self.username
    
    def update_last_login(self):
        """Update last login timestamp and increment login count."""
        self.last_login = datetime.utcnow()
        self.login_count += 1
```

**Create `app/models/project.py`:**

```python
"""
app/models/project.py
Project model for organizing tasks.
"""

from sqlalchemy import Column, String, Text, Boolean, Integer, Enum, ForeignKey, UniqueConstraint, Index
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from app.models.base import BaseModel
from app.models.user import User


class ProjectStatus(str, enum.Enum):
    """Project status enumeration."""
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    ARCHIVED = "archived"


class Project(BaseModel):
    """
    Project model representing a collection of tasks.
    
    Attributes:
        name: Project name
        description: Project description
        status: Current project status
        is_public: Whether the project is publicly visible
        owner_id: User ID of the project owner
    """
    
    __tablename__ = "projects"
    
    # ──────────────── Core Fields ────────────────
    name = Column(
        String(200),
        nullable=False,
        doc="Project name",
    )
    
    description = Column(
        Text,
        nullable=True,
        doc="Project description",
    )
    
    status = Column(
        Enum(ProjectStatus),
        nullable=False,
        default=ProjectStatus.ACTIVE,
        doc="Current project status",
    )
    
    is_public = Column(
        Boolean,
        nullable=False,
        default=False,
        doc="Whether the project is publicly visible",
    )
    
    # ──────────────── Ownership ────────────────
    owner_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        doc="User ID of the project owner",
    )
    
    # ──────────────── Relationships ────────────────
    
    # Project owner
    owner = relationship(
        "User",
        foreign_keys=[owner_id],
        doc="Project owner",
    )
    
    # Tasks in this project
    tasks = relationship(
        "Task",
        back_populates="project",
        lazy="select",
        cascade="all, delete-orphan",
        doc="Tasks belonging to this project",
    )
    
    # Project members
    members = relationship(
        "ProjectMember",
        back_populates="project",
        lazy="select",
        cascade="all, delete-orphan",
        doc="Members of this project",
    )
    
    # ──────────────── Indexes ────────────────
    __table_args__ = (
        Index("ix_projects_name", "name"),
        Index("ix_projects_status", "status"),
        Index("ix_projects_owner_id", "owner_id"),
        Index("ix_projects_status_owner", "status", "owner_id"),
    )
    
    def __repr__(self) -> str:
        """String representation of the project."""
        return f"<Project(id={self.id}, name='{self.name}', status='{self.status}')>"


class ProjectMember(BaseModel):
    """
    Project membership model.
    
    Links users to projects with specific roles.
    """
    
    __tablename__ = "project_members"
    
    # ──────────────── Relationships ────────────────
    project_id = Column(
        Integer,
        ForeignKey("projects.id", ondelete="CASCADE"),
        nullable=False,
        doc="Project ID",
    )
    
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        doc="User ID",
    )
    
    # ──────────────── Role ────────────────
    role = Column(
        String(50),
        nullable=False,
        default="member",
        doc="Member role in the project",
    )
    
    # ──────────────── Relationships ────────────────
    project = relationship(
        "Project",
        back_populates="members",
        doc="Project this membership belongs to",
    )
    
    user = relationship(
        "User",
        back_populates="projects",
        doc="User who is a member",
    )
    
    # ──────────────── Constraints ────────────────
    __table_args__ = (
        # Ensure a user can only be a member of a project once
        UniqueConstraint("project_id", "user_id", name="uq_project_member"),
        Index("ix_project_members_project", "project_id"),
        Index("ix_project_members_user", "user_id"),
    )
    
    def __repr__(self) -> str:
        """String representation of the membership."""
        return f"<ProjectMember(project_id={self.project_id}, user_id={self.user_id}, role='{self.role}')>"
```

**Create `app/models/task.py`:**

```python
"""
app/models/task.py
Task model for tracking work items.
"""

from sqlalchemy import Column, String, Text, Integer, Float, DateTime, Enum, ForeignKey, ARRAY, Index, CheckConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import ARRAY as PG_ARRAY
import enum

from app.models.base import BaseModel


class TaskStatus(str, enum.Enum):
    """Task status enumeration."""
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    REVIEW = "review"
    DONE = "done"
    ARCHIVED = "archived"


class TaskPriority(str, enum.Enum):
    """Task priority enumeration."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class Task(BaseModel):
    """
    Task model representing a work item.
    
    Attributes:
        title: Task title
        description: Task description
        status: Current task status
        priority: Task priority level
        due_date: Optional due date
        tags: List of tags for categorization
        estimated_hours: Estimated time to complete
        actual_hours: Actual time spent
        project_id: Optional project ID
        created_by_id: User who created the task
        assignee_id: User assigned to the task
        completed_at: Timestamp when task was completed
        parent_task_id: Optional parent task ID for subtasks
    """
    
    __tablename__ = "tasks"
    
    # ──────────────── Core Fields ────────────────
    title = Column(
        String(200),
        nullable=False,
        doc="Task title",
    )
    
    description = Column(
        Text,
        nullable=True,
        doc="Task description",
    )
    
    status = Column(
        Enum(TaskStatus),
        nullable=False,
        default=TaskStatus.TODO,
        doc="Current task status",
    )
    
    priority = Column(
        Enum(TaskPriority),
        nullable=False,
        default=TaskPriority.MEDIUM,
        doc="Task priority level",
    )
    
    # ──────────────── Dates ────────────────
    due_date = Column(
        DateTime(timezone=True),
        nullable=True,
        doc="Due date for the task",
    )
    
    completed_at = Column(
        DateTime(timezone=True),
        nullable=True,
        doc="Timestamp when task was completed",
    )
    
    # ──────────────── Tracking ────────────────
    tags = Column(
        PG_ARRAY(String(50)),
        nullable=True,
        doc="Array of tags for categorization",
    )
    
    estimated_hours = Column(
        Float,
        nullable=True,
        doc="Estimated hours to complete",
    )
    
    actual_hours = Column(
        Float,
        nullable=True,
        doc="Actual hours spent",
    )
    
    # ──────────────── Relationships ────────────────
    project_id = Column(
        Integer,
        ForeignKey("projects.id", ondelete="SET NULL"),
        nullable=True,
        doc="Project ID this task belongs to",
    )
    
    created_by_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        doc="User who created the task",
    )
    
    assignee_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        doc="User assigned to the task",
    )
    
    # ──────────────── Subtasks ────────────────
    parent_task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="CASCADE"),
        nullable=True,
        doc="Parent task ID for subtasks",
    )
    
    # ──────────────── Relationships ────────────────
    project = relationship(
        "Project",
        back_populates="tasks",
        doc="Project this task belongs to",
    )
    
    creator = relationship(
        "User",
        foreign_keys=[created_by_id],
        back_populates="created_tasks",
        doc="User who created this task",
    )
    
    assignee = relationship(
        "User",
        foreign_keys=[assignee_id],
        back_populates="assigned_tasks",
        doc="User assigned to this task",
    )
    
    # Self-referential relationship for subtasks
    parent_task = relationship(
        "Task",
        remote_side=[id],
        backref="subtasks",
        lazy="select",
        doc="Parent task for subtasks",
    )
    
    # Comments on this task
    comments = relationship(
        "Comment",
        back_populates="task",
        lazy="select",
        cascade="all, delete-orphan",
        doc="Comments on this task",
    )
    
    # ──────────────── Indexes ────────────────
    __table_args__ = (
        Index("ix_tasks_title", "title"),
        Index("ix_tasks_status", "status"),
        Index("ix_tasks_priority", "priority"),
        Index("ix_tasks_project_id", "project_id"),
        Index("ix_tasks_assignee_id", "assignee_id"),
        Index("ix_tasks_created_by_id", "created_by_id"),
        Index("ix_tasks_due_date", "due_date"),
        Index("ix_tasks_status_assignee", "status", "assignee_id"),
        Index("ix_tasks_project_status", "project_id", "status"),
        # Ensure due_date is in the future when set
        CheckConstraint(
            "due_date IS NULL OR due_date > CURRENT_TIMESTAMP",
            name="ck_task_due_date_future"
        ),
        # Ensure actual_hours is not negative
        CheckConstraint(
            "actual_hours IS NULL OR actual_hours >= 0",
            name="ck_task_actual_hours_positive"
        ),
        # Ensure estimated_hours is not negative
        CheckConstraint(
            "estimated_hours IS NULL OR estimated_hours >= 0",
            name="ck_task_estimated_hours_positive"
        ),
    )
    
    def __repr__(self) -> str:
        """String representation of the task."""
        return f"<Task(id={self.id}, title='{self.title[:30]}...', status='{self.status}')>"
    
    @property
    def is_overdue(self) -> bool:
        """Check if the task is overdue."""
        if not self.due_date:
            return False
        from datetime import datetime
        return self.due_date < datetime.utcnow() and self.status not in [TaskStatus.DONE, TaskStatus.ARCHIVED]
    
    @property
    def completion_percentage(self) -> float:
        """Calculate completion percentage based on subtasks if any."""
        if not self.subtasks:
            return 100.0 if self.status == TaskStatus.DONE else 0.0
        
        completed = sum(1 for subtask in self.subtasks if subtask.status == TaskStatus.DONE)
        total = len(self.subtasks)
        return (completed / total * 100) if total > 0 else 0.0
    
    def complete(self):
        """Mark the task as completed."""
        self.status = TaskStatus.DONE
        self.completed_at = datetime.utcnow()
```

**Create `app/models/comment.py`:**

```python
"""
app/models/comment.py
Comment model for task discussions.
"""

from sqlalchemy import Column, Text, Integer, ForeignKey, Index
from sqlalchemy.orm import relationship

from app.models.base import BaseModel


class Comment(BaseModel):
    """
    Comment model for task discussions.
    
    Attributes:
        content: Comment text
        task_id: Task this comment belongs to
        author_id: User who wrote the comment
        parent_comment_id: Optional parent for threaded comments
    """
    
    __tablename__ = "comments"
    
    # ──────────────── Content ────────────────
    content = Column(
        Text,
        nullable=False,
        doc="Comment content",
    )
    
    # ──────────────── Relationships ────────────────
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="CASCADE"),
        nullable=False,
        doc="Task this comment belongs to",
    )
    
    author_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
        doc="User who wrote the comment",
    )
    
    # For threaded comments
    parent_comment_id = Column(
        Integer,
        ForeignKey("comments.id", ondelete="CASCADE"),
        nullable=True,
        doc="Parent comment for threaded replies",
    )
    
    # ──────────────── Relationships ────────────────
    task = relationship(
        "Task",
        back_populates="comments",
        doc="Task this comment belongs to",
    )
    
    author = relationship(
        "User",
        back_populates="comments",
        doc="User who wrote the comment",
    )
    
    # Self-referential for threaded comments
    parent_comment = relationship(
        "Comment",
        remote_side=[id],
        backref="replies",
        lazy="select",
        doc="Parent comment",
    )
    
    # ──────────────── Indexes ────────────────
    __table_args__ = (
        Index("ix_comments_task_id", "task_id"),
        Index("ix_comments_author_id", "author_id"),
        Index("ix_comments_parent", "parent_comment_id"),
        Index("ix_comments_created_at", "created_at"),
    )
    
    def __repr__(self) -> str:
        """String representation of the comment."""
        return f"<Comment(id={self.id}, task_id={self.task_id}, author_id={self.author_id})>"
```

**Create `app/models/__init__.py`:**

```python
"""
app/models/__init__.py
Database models package.
"""

from app.models.user import User, UserRole
from app.models.project import Project, ProjectMember, ProjectStatus
from app.models.task import Task, TaskStatus, TaskPriority
from app.models.comment import Comment
from app.models.base import BaseModel, TimestampMixin, SoftDeleteMixin, IDMixin

__all__ = [
    "User",
    "UserRole",
    "Project",
    "ProjectMember",
    "ProjectStatus",
    "Task",
    "TaskStatus",
    "TaskPriority",
    "Comment",
    "BaseModel",
    "TimestampMixin",
    "SoftDeleteMixin",
    "IDMixin",
]
```

## Step 3: Alembic Migrations

### The Target
Set up Alembic for database schema migrations to evolve our database schema safely.

### The Concept
Alembic is like a version control system for your database schema. When you need to add a new column or table, you create a migration file that describes the change. Alembic tracks which migrations have been applied and can upgrade or downgrade your database schema.

### The Implementation

**Initialize Alembic:**

```bash
# Initialize alembic
alembic init -t async alembic

# This creates:
# alembic/
#   ├── versions/
#   ├── env.py
#   └── script.py.mako
# alembic.ini
```

**Update `alembic.ini`:**

```ini
# alembic.ini
[alembic]
# path to migration scripts
script_location = alembic
prepend_sys_path = .
version_path_separator = os
sqlalchemy.url = postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_db

[post_write_hooks]
hooks = black
black.type = console_scripts
black.entrypoint = black
black.options = -l 88

# Logging configuration
[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

**Update `alembic/env.py` for async support:**

```python
"""
alembic/env.py
Alembic environment configuration.
"""

import asyncio
from logging.config import fileConfig
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import async_engine_from_config
from alembic import context

import sys
from pathlib import Path

# Add the project root to the Python path
sys.path.append(str(Path(__file__).parent.parent))

from app.core.database import Base
from app.core.config import settings
from app.models import *  # Import all models to register them

# This is the Alembic Config object
config = context.config

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Set the database URL from settings
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

# Target metadata for 'autogenerate' support
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode.
    
    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well. By skipping the Engine creation
    we don't even need a DBAPI to be available.
    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    """
    Run migrations with a connection.
    
    Args:
        connection: SQLAlchemy connection
    """
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """
    Run migrations in 'online' mode using async engine.
    """
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()


def run_migrations_online() -> None:
    """
    Run migrations in 'online' mode.
    
    In this scenario we need to create an Engine
    and associate a connection with the context.
    """
    asyncio.run(run_async_migrations())


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

**Create the initial migration:**

```bash
# Generate initial migration
alembic revision --autogenerate -m "Initial database schema"

# This creates a file like: alembic/versions/xxxx_initial_database_schema.py
```

**Apply the migration:**

```bash
# Apply the migration to the database
alembic upgrade head
```

## Step 4: Repository Pattern

### The Target
Implement the Repository pattern to abstract database operations and keep our code clean and testable.

### The Concept
The Repository pattern is like a library catalog system. Instead of searching through the entire library (database) directly, you go to the catalog (repository) which knows how to find books (records) efficiently. This keeps your business logic separate from your database logic.

### The Implementation

**Create `app/crud/base.py`:**

```python
"""
app/crud/base.py
Base repository with common CRUD operations.
"""

from typing import Any, Dict, Generic, List, Optional, Type, TypeVar, Union
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, desc, asc, Select
from sqlalchemy.sql import ColumnElement
from pydantic import BaseModel

from app.core.database import Base
from app.core.exceptions import NotFoundException

# Type variables for generic repository
ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class BaseRepository(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    """
    Base repository with common CRUD operations.
    
    Provides generic methods for creating, reading, updating,
    and deleting records.
    
    Attributes:
        model: The SQLAlchemy model class
        session: Async SQLAlchemy session
    """
    
    def __init__(self, model: Type[ModelType], session: AsyncSession):
        """
        Initialize the repository.
        
        Args:
            model: SQLAlchemy model class
            session: Async database session
        """
        self.model = model
        self.session = session
    
    # ────────────────────────────────────────────────────────────────
    # Create Operations
    # ────────────────────────────────────────────────────────────────
    
    async def create(self, obj_in: CreateSchemaType) -> ModelType:
        """
        Create a new record.
        
        Args:
            obj_in: Data for creating the record
            
        Returns:
            ModelType: Created record
        """
        obj_data = obj_in.model_dump(exclude_unset=True)
        db_obj = self.model(**obj_data)
        self.session.add(db_obj)
        await self.session.flush()  # Flush to get the ID
        return db_obj
    
    async def create_many(self, objs_in: List[CreateSchemaType]) -> List[ModelType]:
        """
        Create multiple records.
        
        Args:
            objs_in: List of creation data
            
        Returns:
            List[ModelType]: Created records
        """
        db_objs = []
        for obj_in in objs_in:
            obj_data = obj_in.model_dump(exclude_unset=True)
            db_obj = self.model(**obj_data)
            self.session.add(db_obj)
            db_objs.append(db_obj)
        await self.session.flush()
        return db_objs
    
    # ────────────────────────────────────────────────────────────────
    # Read Operations
    # ────────────────────────────────────────────────────────────────
    
    async def get(self, id: int) -> Optional[ModelType]:
        """
        Get a record by ID.
        
        Args:
            id: Record ID
            
        Returns:
            Optional[ModelType]: Record if found, None otherwise
        """
        query = select(self.model).where(self.model.id == id)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()
    
    async def get_or_raise(self, id: int, error_msg: str = None) -> ModelType:
        """
        Get a record by ID or raise an exception.
        
        Args:
            id: Record ID
            error_msg: Custom error message
            
        Returns:
            ModelType: Record if found
            
        Raises:
            NotFoundException: If record not found
        """
        obj = await self.get(id)
        if not obj:
            error_msg = error_msg or f"{self.model.__name__} with ID {id} not found"
            raise NotFoundException(detail=error_msg, error_code="RESOURCE_NOT_FOUND")
        return obj
    
    async def get_all(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None,
        sort_by: Optional[str] = None,
        sort_desc: bool = False,
    ) -> List[ModelType]:
        """
        Get all records with pagination and filtering.
        
        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return
            filters: Dictionary of field-value filters
            sort_by: Field to sort by
            sort_desc: Whether to sort in descending order
            
        Returns:
            List[ModelType]: List of records
        """
        query = select(self.model)
        
        # Apply filters
        if filters:
            for field, value in filters.items():
                if hasattr(self.model, field) and value is not None:
                    query = query.where(getattr(self.model, field) == value)
        
        # Apply sorting
        if sort_by and hasattr(self.model, sort_by):
            order_by = getattr(self.model, sort_by)
            if sort_desc:
                order_by = desc(order_by)
            query = query.order_by(order_by)
        else:
            # Default sort by created_at descending
            query = query.order_by(desc(self.model.created_at))
        
        # Apply pagination
        query = query.offset(skip).limit(limit)
        
        result = await self.session.execute(query)
        return result.scalars().all()
    
    async def get_count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """
        Get total count of records with optional filters.
        
        Args:
            filters: Dictionary of field-value filters
            
        Returns:
            int: Total count
        """
        query = select(func.count()).select_from(self.model)
        
        if filters:
            for field, value in filters.items():
                if hasattr(self.model, field) and value is not None:
                    query = query.where(getattr(self.model, field) == value)
        
        result = await self.session.execute(query)
        return result.scalar()
    
    async def exists(self, id: int) -> bool:
        """
        Check if a record exists.
        
        Args:
            id: Record ID
            
        Returns:
            bool: True if record exists, False otherwise
        """
        query = select(func.count()).select_from(self.model).where(self.model.id == id)
        result = await self.session.execute(query)
        return result.scalar() > 0
    
    # ────────────────────────────────────────────────────────────────
    # Update Operations
    # ────────────────────────────────────────────────────────────────
    
    async def update(
        self,
        db_obj: ModelType,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]]
    ) -> ModelType:
        """
        Update a record.
        
        Args:
            db_obj: Existing record
            obj_in: Update data (schema or dict)
            
        Returns:
            ModelType: Updated record
        """
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.model_dump(exclude_unset=True)
        
        for field, value in update_data.items():
            if hasattr(db_obj, field):
                setattr(db_obj, field, value)
        
        await self.session.flush()
        return db_obj
    
    async def update_by_id(
        self,
        id: int,
        obj_in: Union[UpdateSchemaType, Dict[str, Any]]
    ) -> ModelType:
        """
        Update a record by ID.
        
        Args:
            id: Record ID
            obj_in: Update data
            
        Returns:
            ModelType: Updated record
            
        Raises:
            NotFoundException: If record not found
        """
        db_obj = await self.get_or_raise(id)
        return await self.update(db_obj, obj_in)
    
    # ────────────────────────────────────────────────────────────────
    # Delete Operations
    # ────────────────────────────────────────────────────────────────
    
    async def delete(self, db_obj: ModelType) -> None:
        """
        Delete a record.
        
        Args:
            db_obj: Record to delete
        """
        await self.session.delete(db_obj)
        await self.session.flush()
    
    async def delete_by_id(self, id: int) -> None:
        """
        Delete a record by ID.
        
        Args:
            id: Record ID
            
        Raises:
            NotFoundException: If record not found
        """
        db_obj = await self.get_or_raise(id)
        await self.delete(db_obj)
    
    async def delete_many(self, ids: List[int]) -> int:
        """
        Delete multiple records.
        
        Args:
            ids: List of record IDs
            
        Returns:
            int: Number of records deleted
        """
        query = select(self.model).where(self.model.id.in_(ids))
        result = await self.session.execute(query)
        objs = result.scalars().all()
        
        for obj in objs:
            await self.session.delete(obj)
        
        await self.session.flush()
        return len(objs)
    
    # ────────────────────────────────────────────────────────────────
    # Search Operations
    # ────────────────────────────────────────────────────────────────
    
    async def search(
        self,
        search_term: str,
        fields: List[str],
        skip: int = 0,
        limit: int = 100
    ) -> List[ModelType]:
        """
        Search records across multiple fields.
        
        Args:
            search_term: Search term
            fields: List of field names to search in
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List[ModelType]: Matching records
        """
        if not search_term or not fields:
            return await self.get_all(skip=skip, limit=limit)
        
        # Build search conditions
        conditions = []
        for field in fields:
            if hasattr(self.model, field):
                column = getattr(self.model, field)
                conditions.append(column.ilike(f"%{search_term}%"))
        
        if not conditions:
            return await self.get_all(skip=skip, limit=limit)
        
        query = select(self.model).where(or_(*conditions))
        query = query.offset(skip).limit(limit)
        
        result = await self.session.execute(query)
        return result.scalars().all()
    
    # ────────────────────────────────────────────────────────────────
    # Utility Methods
    # ────────────────────────────────────────────────────────────────
    
    def _build_filter_conditions(
        self,
        filters: Dict[str, Any],
        valid_fields: List[str]
    ) -> List[ColumnElement]:
        """
        Build filter conditions for queries.
        
        Args:
            filters: Dictionary of field-value filters
            valid_fields: List of valid field names
            
        Returns:
            List[ColumnElement]: List of filter conditions
        """
        conditions = []
        for field, value in filters.items():
            if field in valid_fields and value is not None:
                column = getattr(self.model, field)
                if isinstance(value, (list, tuple)):
                    # IN clause for lists
                    conditions.append(column.in_(value))
                elif isinstance(value, str) and "%" in value:
                    # LIKE for strings with wildcards
                    conditions.append(column.ilike(value))
                else:
                    # Equality for simple values
                    conditions.append(column == value)
        return conditions
```

**Create `app/crud/user.py`** (specific repository for Users):

```python
"""
app/crud/user.py
User repository with user-specific operations.
"""

from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_

from app.crud.base import BaseRepository
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate


class UserRepository(BaseRepository[User, UserCreate, UserUpdate]):
    """
    Repository for User model with additional user-specific methods.
    """
    
    def __init__(self, session: AsyncSession):
        super().__init__(User, session)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        """
        Get user by email.
        
        Args:
            email: User email
            
        Returns:
            Optional[User]: User if found, None otherwise
        """
        query = select(User).where(User.email == email)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()
    
    async def get_by_username(self, username: str) -> Optional[User]:
        """
        Get user by username.
        
        Args:
            username: User username
            
        Returns:
            Optional[User]: User if found, None otherwise
        """
        query = select(User).where(User.username == username)
        result = await self.session.execute(query)
        return result.scalar_one_or_none()
    
    async def get_by_email_or_username(
        self,
        email: str,
        username: str
    ) -> Optional[User]:
        """
        Get user by email or username.
        
        Args:
            email: User email
            username: User username
            
        Returns:
            Optional[User]: User if found, None otherwise
        """
        query = select(User).where(
            or_(User.email == email, User.username == username)
        )
        result = await self.session.execute(query)
        return result.scalar_one_or_none()
    
    async def get_active_users(
        self,
        skip: int = 0,
        limit: int = 100
    ) -> List[User]:
        """
        Get all active users.
        
        Args:
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List[User]: List of active users
        """
        return await self.get_all(
            skip=skip,
            limit=limit,
            filters={"is_active": True}
        )
    
    async def get_by_role(
        self,
        role: str,
        skip: int = 0,
        limit: int = 100
    ) -> List[User]:
        """
        Get users by role.
        
        Args:
            role: User role
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List[User]: List of users with the role
        """
        return await self.get_all(
            skip=skip,
            limit=limit,
            filters={"role": role, "is_active": True}
        )
```

**Create `app/crud/task.py`** (specific repository for Tasks):

```python
"""
app/crud/task.py
Task repository with task-specific operations.
"""

from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, desc, func

from app.crud.base import BaseRepository
from app.models.task import Task, TaskStatus, TaskPriority
from app.schemas.task import TaskCreate, TaskUpdate


class TaskRepository(BaseRepository[Task, TaskCreate, TaskUpdate]):
    """
    Repository for Task model with additional task-specific methods.
    """
    
    def __init__(self, session: AsyncSession):
        super().__init__(Task, session)
    
    async def get_by_project(
        self,
        project_id: int,
        skip: int = 0,
        limit: int = 100,
        include_archived: bool = False
    ) -> List[Task]:
        """
        Get tasks by project ID.
        
        Args:
            project_id: Project ID
            skip: Number of records to skip
            limit: Maximum number of records to return
            include_archived: Whether to include archived tasks
            
        Returns:
            List[Task]: List of tasks in the project
        """
        filters = {"project_id": project_id}
        if not include_archived:
            filters["status"] = TaskStatus.ARCHIVED
        return await self.get_all(skip=skip, limit=limit, filters=filters)
    
    async def get_by_assignee(
        self,
        assignee_id: int,
        status: Optional[TaskStatus] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Task]:
        """
        Get tasks assigned to a user.
        
        Args:
            assignee_id: User ID
            status: Optional status filter
            skip: Number of records to skip
            limit: Maximum number of records to return
            
        Returns:
            List[Task]: List of assigned tasks
        """
        filters = {"assignee_id": assignee_id}
        if status:
            filters["status"] = status
        return await self.get_all(skip=skip, limit=limit, filters=filters)
    
    async def get_overdue_tasks(self) -> List[Task]:
        """
        Get all overdue tasks.
        
        Returns:
            List[Task]: List of overdue tasks
        """
        query = select(Task).where(
            and_(
                Task.due_date.is_not(None),
                Task.due_date < datetime.utcnow(),
                Task.status.notin_([TaskStatus.DONE, TaskStatus.ARCHIVED])
            )
        )
        result = await self.session.execute(query)
        return result.scalars().all()
    
    async def get_upcoming_tasks(
        self,
        days: int = 7
    ) -> List[Task]:
        """
        Get tasks due in the next N days.
        
        Args:
            days: Number of days to look ahead
            
        Returns:
            List[Task]: List of upcoming tasks
        """
        now = datetime.utcnow()
        future = now + timedelta(days=days)
        
        query = select(Task).where(
            and_(
                Task.due_date.is_not(None),
                Task.due_date.between(now, future),
                Task.status.notin_([TaskStatus.DONE, TaskStatus.ARCHIVED])
            )
        ).order_by(Task.due_date)
        
        result = await self.session.execute(query)
        return result.scalars().all()
    
    async def get_task_stats(
        self,
        project_id: Optional[int] = None,
        assignee_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Get task statistics.
        
        Args:
            project_id: Optional project filter
            assignee_id: Optional assignee filter
            
        Returns:
            Dict: Task statistics
        """
        query = select(
            Task.status,
            func.count(Task.id).label("count")
        )
        
        # Build filters
        conditions = []
        if project_id:
            conditions.append(Task.project_id == project_id)
        if assignee_id:
            conditions.append(Task.assignee_id == assignee_id)
        
        if conditions:
            query = query.where(and_(*conditions))
        
        query = query.group_by(Task.status)
        
        result = await self.session.execute(query)
        rows = result.all()
        
        # Build statistics
        stats = {
            "total": 0,
            "by_status": {},
            "overdue": 0,
            "completed_today": 0,
        }
        
        for row in rows:
            status = row[0]
            count = row[1]
            stats["total"] += count
            stats["by_status"][status] = count
        
        # Get overdue count
        overdue_conditions = [
            Task.due_date < datetime.utcnow(),
            Task.status.notin_([TaskStatus.DONE, TaskStatus.ARCHIVED])
        ]
        if project_id:
            overdue_conditions.append(Task.project_id == project_id)
        if assignee_id:
            overdue_conditions.append(Task.assignee_id == assignee_id)
        
        overdue_query = select(func.count()).select_from(Task).where(
            and_(*overdue_conditions)
        )
        overdue_result = await self.session.execute(overdue_query)
        stats["overdue"] = overdue_result.scalar() or 0
        
        # Get completed today
        today = datetime.utcnow().date()
        start_of_day = datetime(today.year, today.month, today.day)
        end_of_day = start_of_day + timedelta(days=1)
        
        completed_conditions = [
            Task.status == TaskStatus.DONE,
            Task.completed_at.between(start_of_day, end_of_day)
        ]
        if project_id:
            completed_conditions.append(Task.project_id == project_id)
        if assignee_id:
            completed_conditions.append(Task.assignee_id == assignee_id)
        
        completed_query = select(func.count()).select_from(Task).where(
            and_(*completed_conditions)
        )
        completed_result = await self.session.execute(completed_query)
        stats["completed_today"] = completed_result.scalar() or 0
        
        return stats
```

## Step 5: Service Layer

### The Target
Implement the Service layer to encapsulate business logic and coordinate between repositories and endpoints.

### The Concept
The Service layer is like a restaurant kitchen—it takes orders (API requests), coordinates the preparation (business logic), and ensures everything comes together properly before serving (responding to the client). It keeps the kitchen organized and the food consistent.

### The Implementation

**Create `app/services/base.py`:**

```python
"""
app/services/base.py
Base service with common service methods.
"""

from typing import Generic, TypeVar, Type, Optional, List, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession

from app.crud.base import BaseRepository
from app.models.base import Base
from pydantic import BaseModel

# Type variables
ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class BaseService(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    """
    Base service with common business logic.
    
    Services handle business logic and coordinate
    between repositories and API endpoints.
    """
    
    def __init__(
        self,
        session: AsyncSession,
        repository_class: Type[BaseRepository]
    ):
        """
        Initialize the service.
        
        Args:
            session: Database session
            repository_class: Repository class for this service
        """
        self.session = session
        self.repository = repository_class(session)
    
    # ────────────────────────────────────────────────────────────────
    # CRUD Operations
    # ────────────────────────────────────────────────────────────────
    
    async def create(self, obj_in: CreateSchemaType) -> ModelType:
        """
        Create a new record.
        
        Args:
            obj_in: Creation data
            
        Returns:
            ModelType: Created record
        """
        return await self.repository.create(obj_in)
    
    async def get(self, id: int) -> Optional[ModelType]:
        """
        Get a record by ID.
        
        Args:
            id: Record ID
            
        Returns:
            Optional[ModelType]: Record if found
        """
        return await self.repository.get(id)
    
    async def get_or_raise(self, id: int, error_msg: str = None) -> ModelType:
        """
        Get a record by ID or raise an exception.
        
        Args:
            id: Record ID
            error_msg: Custom error message
            
        Returns:
            ModelType: Record if found
        """
        return await self.repository.get_or_raise(id, error_msg)
    
    async def get_all(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None,
        sort_by: Optional[str] = None,
        sort_desc: bool = False,
    ) -> List[ModelType]:
        """
        Get all records with pagination.
        
        Args:
            skip: Number of records to skip
            limit: Maximum number of records
            filters: Field-value filters
            sort_by: Field to sort by
            sort_desc: Sort descending
            
        Returns:
            List[ModelType]: List of records
        """
        return await self.repository.get_all(
            skip=skip,
            limit=limit,
            filters=filters,
            sort_by=sort_by,
            sort_desc=sort_desc,
        )
    
    async def update(
        self,
        id: int,
        obj_in: UpdateSchemaType
    ) -> ModelType:
        """
        Update a record.
        
        Args:
            id: Record ID
            obj_in: Update data
            
        Returns:
            ModelType: Updated record
        """
        return await self.repository.update_by_id(id, obj_in)
    
    async def delete(self, id: int) -> None:
        """
        Delete a record.
        
        Args:
            id: Record ID
        """
        await self.repository.delete_by_id(id)
    
    # ────────────────────────────────────────────────────────────────
    # Utility Methods
    # ────────────────────────────────────────────────────────────────
    
    async def exists(self, id: int) -> bool:
        """
        Check if a record exists.
        
        Args:
            id: Record ID
            
        Returns:
            bool: True if exists
        """
        return await self.repository.exists(id)
    
    async def count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """
        Count records with optional filters.
        
        Args:
            filters: Field-value filters
            
        Returns:
            int: Total count
        """
        return await self.repository.get_count(filters)
    
    async def commit(self) -> None:
        """Commit the current transaction."""
        await self.session.commit()
    
    async def rollback(self) -> None:
        """Rollback the current transaction."""
        await self.session.rollback()
```

**Create `app/services/user.py`:**

```python
"""
app/services/user.py
User service with business logic for user management.
"""

from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
import re

from app.services.base import BaseService
from app.crud.user import UserRepository
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate, UserInDB
from app.core.security import get_password_hash, verify_password
from app.core.exceptions import BadRequestException, ConflictException, NotFoundException


class UserService(BaseService[User, UserCreate, UserUpdate]):
    """
    Service for user operations.
    
    Handles user creation, authentication, profile management,
    and user-related business logic.
    """
    
    def __init__(self, session: AsyncSession):
        """
        Initialize the user service.
        
        Args:
            session: Database session
        """
        super().__init__(session, UserRepository)
    
    # ────────────────────────────────────────────────────────────────
    # User Management
    # ────────────────────────────────────────────────────────────────
    
    async def create_user(self, user_data: UserCreate) -> User:
        """
        Create a new user with validation and password hashing.
        
        Args:
            user_data: User creation data
            
        Returns:
            User: Created user
            
        Raises:
            ConflictException: If email or username already exists
            BadRequestException: If validation fails
        """
        # Check if user already exists
        existing = await self.repository.get_by_email_or_username(
            user_data.email,
            user_data.username
        )
        
        if existing:
            if existing.email == user_data.email:
                raise ConflictException(
                    detail="User with this email already exists",
                    error_code="EMAIL_TAKEN"
                )
            if existing.username == user_data.username:
                raise ConflictException(
                    detail="User with this username already exists",
                    error_code="USERNAME_TAKEN"
                )
        
        # Validate password strength
        self._validate_password_strength(user_data.password)
        
        # Create user with hashed password
        user_dict = user_data.model_dump(exclude={"password"})
        user_dict["hashed_password"] = get_password_hash(user_data.password)
        
        # Create repository and session will handle it
        user = await self.repository.create(
            UserCreate(**user_dict)  # Use the same schema without password
        )
        
        await self.session.commit()
        await self.session.refresh(user)
        
        return user
    
    async def authenticate(self, email: str, password: str) -> Optional[User]:
        """
        Authenticate a user by email and password.
        
        Args:
            email: User email
            password: User password
            
        Returns:
            Optional[User]: Authenticated user or None
        """
        user = await self.repository.get_by_email(email)
        
        if not user:
            return None
        
        if not user.is_active:
            return None
        
        if not verify_password(password, user.hashed_password):
            return None
        
        # Update last login
        user.update_last_login()
        await self.session.commit()
        await self.session.refresh(user)
        
        return user
    
    async def update_user(
        self,
        user_id: int,
        update_data: UserUpdate,
        current_user: Optional[User] = None
    ) -> User:
        """
        Update a user's profile.
        
        Args:
            user_id: User ID to update
            update_data: Update data
            current_user: Currently authenticated user
            
        Returns:
            User: Updated user
            
        Raises:
            NotFoundException: If user not found
            ForbiddenException: If unauthorized
            ConflictException: If email/username is taken
        """
        # Get user
        user = await self.repository.get_or_raise(user_id)
        
        # Check if username is being updated and is already taken
        if update_data.username and update_data.username != user.username:
            existing = await self.repository.get_by_username(update_data.username)
            if existing:
                raise ConflictException(
                    detail="Username already taken",
                    error_code="USERNAME_TAKEN"
                )
        
        # Check if email is being updated and is already taken
        if update_data.email and update_data.email != user.email:
            existing = await self.repository.get_by_email(update_data.email)
            if existing:
                raise ConflictException(
                    detail="Email already taken",
                    error_code="EMAIL_TAKEN"
                )
        
        # Update user
        updated = await self.repository.update(user, update_data)
        await self.session.commit()
        await self.session.refresh(updated)
        
        return updated
    
    async def change_password(
        self,
        user_id: int,
        current_password: str,
        new_password: str
    ) -> User:
        """
        Change a user's password.
        
        Args:
            user_id: User ID
            current_password: Current password
            new_password: New password
            
        Returns:
            User: Updated user
            
        Raises:
            BadRequestException: If current password is incorrect
        """
        user = await self.repository.get_or_raise(user_id)
        
        # Verify current password
        if not verify_password(current_password, user.hashed_password):
            raise BadRequestException(
                detail="Current password is incorrect",
                error_code="INCORRECT_PASSWORD"
            )
        
        # Validate new password strength
        self._validate_password_strength(new_password)
        
        # Update password
        user.hashed_password = get_password_hash(new_password)
        await self.session.commit()
        await self.session.refresh(user)
        
        return user
    
    async def deactivate_user(self, user_id: int) -> User:
        """
        Deactivate a user account.
        
        Args:
            user_id: User ID
            
        Returns:
            User: Deactivated user
        """
        user = await self.repository.get_or_raise(user_id)
        user.is_active = False
        await self.session.commit()
        await self.session.refresh(user)
        return user
    
    async def activate_user(self, user_id: int) -> User:
        """
        Activate a user account.
        
        Args:
            user_id: User ID
            
        Returns:
            User: Activated user
        """
        user = await self.repository.get_or_raise(user_id)
        user.is_active = True
        await self.session.commit()
        await self.session.refresh(user)
        return user
    
    # ────────────────────────────────────────────────────────────────
    # User Search
    # ────────────────────────────────────────────────────────────────
    
    async def search_users(
        self,
        query: str,
        skip: int = 0,
        limit: int = 100
    ) -> list[User]:
        """
        Search users by name, email, or username.
        
        Args:
            query: Search query
            skip: Number of records to skip
            limit: Maximum number of records
            
        Returns:
            list[User]: Matching users
        """
        return await self.repository.search(
            search_term=query,
            fields=["username", "email", "full_name"],
            skip=skip,
            limit=limit
        )
    
    async def get_by_role(
        self,
        role: str,
        skip: int = 0,
        limit: int = 100
    ) -> list[User]:
        """
        Get users by role.
        
        Args:
            role: User role
            skip: Number of records to skip
            limit: Maximum number of records
            
        Returns:
            list[User]: Users with the role
        """
        return await self.repository.get_by_role(role, skip, limit)
    
    # ────────────────────────────────────────────────────────────────
    # Validation Methods
    # ────────────────────────────────────────────────────────────────
    
    def _validate_password_strength(self, password: str) -> None:
        """
        Validate password strength.
        
        Args:
            password: Password to validate
            
        Raises:
            BadRequestException: If password doesn't meet requirements
        """
        if len(password) < 8:
            raise BadRequestException(
                detail="Password must be at least 8 characters long",
                error_code="WEAK_PASSWORD"
            )
        
        if not re.search(r"[A-Z]", password):
            raise BadRequestException(
                detail="Password must contain at least one uppercase letter",
                error_code="WEAK_PASSWORD"
            )
        
        if not re.search(r"[a-z]", password):
            raise BadRequestException(
                detail="Password must contain at least one lowercase letter",
                error_code="WEAK_PASSWORD"
            )
        
        if not re.search(r"\d", password):
            raise BadRequestException(
                detail="Password must contain at least one number",
                error_code="WEAK_PASSWORD"
            )
        
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", password):
            raise BadRequestException(
                detail="Password must contain at least one special character",
                error_code="WEAK_PASSWORD"
            )
```

## Step 6: Updating the Main Application

### The Target
Update the main application to initialize the database and integrate the service layer.

### The Implementation

**Update `app/main.py` to initialize database:**

```python
"""
app/main.py
Main FastAPI application entry point.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
import uuid
import logging
from datetime import datetime
import time

from app.core.config import settings
from app.core.exceptions import setup_exception_handlers
from app.api.v1.api import api_router
from app.core.database import engine, AsyncSessionLocal, check_db_connection
from app.models import *  # Import all models

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# ... [previous middleware and other code remains the same] ...

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager.
    
    Handles startup and shutdown events.
    """
    # ──────────────── STARTUP ────────────────
    logger.info("🚀 Starting FastAPI application...")
    logger.info(f"📝 Application: {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"🌍 Environment: {settings.APP_ENV}")
    logger.info(f"🐛 Debug mode: {settings.DEBUG}")
    
    # Check database connection
    logger.info("🔌 Checking database connection...")
    if await check_db_connection():
        logger.info("✅ Database connection established")
    else:
        logger.error("❌ Failed to connect to database")
        if settings.APP_ENV == "production":
            raise RuntimeError("Cannot start application without database connection")
    
    # Initialize database tables in development
    if settings.APP_ENV in ["development", "testing"]:
        logger.info("📦 Initializing database schema...")
        from app.core.database import init_db
        await init_db()
    
    logger.info("🚀 Application startup complete")
    logger.info(f"📚 API Documentation: /docs")
    
    yield  # Application runs here
    
    # ───────────────── SHUTDOWN ──────────────
    logger.info("🛑 Shutting down FastAPI application...")
    
    # Close database connections
    await engine.dispose()
    logger.info("✅ Database connections closed")

# ... [rest of the file remains the same] ...
```

**Create user schemas for the service:**

```python
# app/schemas/user.py
"""
app/schemas/user.py
Pydantic schemas for user data validation.
"""

from pydantic import BaseModel, Field, EmailStr, field_validator, ConfigDict
from datetime import datetime
from typing import Optional, List
import re

from app.models.user import UserRole


class UserBase(BaseModel):
    """
    Base user schema with common fields.
    """
    
    email: EmailStr = Field(
        ...,
        description="User's email address",
        examples=["john.doe@example.com"]
    )
    
    username: str = Field(
        ...,
        min_length=3,
        max_length=50,
        pattern=r"^[a-zA-Z0-9_]+$",
        description="Unique username (3-50 characters, alphanumeric and underscore only)",
        examples=["john_doe"]
    )
    
    full_name: str = Field(
        ...,
        min_length=1,
        max_length=100,
        description="User's full name",
        examples=["John Doe"]
    )
    
    role: UserRole = Field(
        default=UserRole.VIEWER,
        description="User role for RBAC"
    )
    
    bio: Optional[str] = Field(
        default=None,
        max_length=500,
        description="User bio (max 500 characters)"
    )
    
    phone_number: Optional[str] = Field(
        default=None,
        max_length=20,
        description="Contact phone number"
    )
    
    avatar_url: Optional[str] = Field(
        default=None,
        max_length=500,
        description="URL to profile picture"
    )


class UserCreate(UserBase):
    """
    Schema for creating a new user.
    """
    
    password: str = Field(
        ...,
        min_length=8,
        description="User password (must meet strength requirements)"
    )
    
    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        """Validate password strength."""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one number")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError("Password must contain at least one special character")
        return v


class UserUpdate(BaseModel):
    """
    Schema for updating a user.
    
    All fields are optional for partial updates.
    """
    
    email: Optional[EmailStr] = Field(
        default=None,
        description="User's email address"
    )
    
    username: Optional[str] = Field(
        default=None,
        min_length=3,
        max_length=50,
        pattern=r"^[a-zA-Z0-9_]+$",
        description="Unique username"
    )
    
    full_name: Optional[str] = Field(
        default=None,
        min_length=1,
        max_length=100,
        description="User's full name"
    )
    
    role: Optional[UserRole] = Field(
        default=None,
        description="User role for RBAC"
    )
    
    bio: Optional[str] = Field(
        default=None,
        max_length=500,
        description="User bio"
    )
    
    phone_number: Optional[str] = Field(
        default=None,
        max_length=20,
        description="Contact phone number"
    )
    
    avatar_url: Optional[str] = Field(
        default=None,
        max_length=500,
        description="URL to profile picture"
    )
    
    is_active: Optional[bool] = Field(
        default=None,
        description="Whether the user account is active"
    )


class UserInDB(UserBase):
    """
    User schema for database representation.
    Includes all fields stored in the database.
    """
    
    id: int = Field(..., description="User ID")
    hashed_password: str = Field(..., description="Hashed password (bcrypt)")
    is_active: bool = Field(True, description="Whether the user account is active")
    is_verified: bool = Field(False, description="Whether the email has been verified")
    is_superuser: bool = Field(False, description="Whether the user has superuser privileges")
    last_login: Optional[datetime] = Field(None, description="Last login timestamp")
    login_count: int = Field(0, description="Number of times user has logged in")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    
    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": 1,
                "email": "john.doe@example.com",
                "username": "john_doe",
                "full_name": "John Doe",
                "role": "developer",
                "bio": "Senior software engineer passionate about Python",
                "phone_number": "+1-555-123-4567",
                "avatar_url": "https://example.com/avatars/john.jpg",
                "is_active": True,
                "is_verified": True,
                "is_superuser": False,
                "last_login": "2024-01-15T10:00:00Z",
                "login_count": 42,
                "created_at": "2024-01-01T00:00:00Z",
                "updated_at": "2024-01-15T10:30:00Z",
            }
        }
    )


class UserResponse(UserInDB):
    """
    User response schema (excludes sensitive fields).
    """
    
    # Exclude hashed_password from response
    hashed_password: str = Field(
        default="",
        exclude=True
    )
    
    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": 1,
                "email": "john.doe@example.com",
                "username": "john_doe",
                "full_name": "John Doe",
                "role": "developer",
                "bio": "Senior software engineer passionate about Python",
                "phone_number": "+1-555-123-4567",
                "avatar_url": "https://example.com/avatars/john.jpg",
                "is_active": True,
                "is_verified": True,
                "is_superuser": False,
                "last_login": "2024-01-15T10:00:00Z",
                "login_count": 42,
                "created_at": "2024-01-01T00:00:00Z",
                "updated_at": "2024-01-15T10:30:00Z",
            }
        }
    )


class UserListResponse(BaseModel):
    """
    Paginated user list response.
    """
    
    items: List[UserResponse] = Field(..., description="List of users")
    total: int = Field(..., description="Total number of users")
    page: int = Field(1, description="Current page number")
    size: int = Field(10, description="Number of items per page")
    pages: int = Field(1, description="Total number of pages")


class PasswordChangeRequest(BaseModel):
    """
    Schema for password change request.
    """
    
    current_password: str = Field(
        ...,
        min_length=1,
        description="Current password"
    )
    
    new_password: str = Field(
        ...,
        min_length=8,
        description="New password (must meet strength requirements)"
    )
    
    @field_validator("new_password")
    @classmethod
    def validate_new_password(cls, v: str) -> str:
        """Validate new password strength."""
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain at least one lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain at least one number")
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError("Password must contain at least one special character")
        return v
```

## Step 7: Testing the Database Integration

### The Target
Write tests for our database models, repositories, and services.

### The Implementation

**Create `tests/conftest.py` for test configuration:**

```python
"""
tests/conftest.py
Pytest configuration and fixtures.
"""

import pytest
import asyncio
from typing import AsyncGenerator, Generator
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
import os

from app.main import app
from app.core.database import Base, get_db
from app.core.config import settings

# Use a test database
TEST_DATABASE_URL = settings.DATABASE_URL.replace("/fastapi_db", "/fastapi_test")


@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    """
    Create a test database session.
    
    Creates tables, yields session, and cleans up.
    """
    # Create test engine
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    
    # Create tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Create session
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        yield session
    
    # Cleanup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    
    await engine.dispose()


@pytest.fixture(scope="function")
async def client(db_session: AsyncSession) -> AsyncGenerator:
    """
    Create test client with database session dependency.
    """
    async def override_get_db():
        yield db_session
    
    app.dependency_overrides[get_db] = override_get_db
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()
```

**Create `tests/test_repository.py`:**

```python
"""
tests/test_repository.py
Tests for repository pattern.
"""

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.crud.user import UserRepository
from app.crud.task import TaskRepository
from app.schemas.user import UserCreate
from app.schemas.task import TaskCreate
from app.models.task import TaskStatus, TaskPriority


@pytest.mark.asyncio
async def test_user_repository_create(db_session: AsyncSession):
    """Test user creation."""
    repo = UserRepository(db_session)
    
    user_data = UserCreate(
        email="test@example.com",
        username="testuser",
        full_name="Test User",
        password="TestPass123!"
    )
    
    # Remove password from dict for creation
    user_dict = user_data.model_dump(exclude={"password"})
    user_dict["hashed_password"] = "hashed_password_here"
    
    # Create user
    user = await repo.create(UserCreate(**user_dict))
    
    assert user.id is not None
    assert user.email == "test@example.com"
    assert user.username == "testuser"
    assert user.full_name == "Test User"
    assert user.is_active is True


@pytest.mark.asyncio
async def test_user_repository_get_by_email(db_session: AsyncSession):
    """Test getting user by email."""
    repo = UserRepository(db_session)
    
    # Create user first
    user_dict = {
        "email": "find@example.com",
        "username": "finduser",
        "full_name": "Find User",
        "hashed_password": "hashed_password",
    }
    created = await repo.create(UserCreate(**user_dict))
    await db_session.commit()
    
    # Find by email
    found = await repo.get_by_email("find@example.com")
    assert found is not None
    assert found.id == created.id
    assert found.email == "find@example.com"


@pytest.mark.asyncio
async def test_task_repository_get_by_project(db_session: AsyncSession):
    """Test getting tasks by project ID."""
    # Create a project first (simplified for test)
    # In real tests, you'd create Project via repository
    
    task_repo = TaskRepository(db_session)
    
    # Create multiple tasks
    task_data_1 = TaskCreate(
        title="Task 1",
        description="First task",
        status=TaskStatus.TODO,
        priority=TaskPriority.MEDIUM,
    )
    task_data_2 = TaskCreate(
        title="Task 2",
        description="Second task",
        status=TaskStatus.IN_PROGRESS,
        priority=TaskPriority.HIGH,
    )
    
    # In a real test, you'd set project_id
    # task_data_1.project_id = 1
    # task_data_2.project_id = 1
    
    await task_repo.create(task_data_1)
    await task_repo.create(task_data_2)
    await db_session.commit()
    
    # Get tasks by project (mock project_id)
    # tasks = await task_repo.get_by_project(1)
    # assert len(tasks) == 2
    pass  # Placeholder for actual implementation


@pytest.mark.asyncio
async def test_task_repository_get_overdue(db_session: AsyncSession):
    """Test getting overdue tasks."""
    from datetime import datetime, timedelta
    
    task_repo = TaskRepository(db_session)
    
    # Create overdue task
    # overdue_task = TaskCreate(
    #     title="Overdue Task",
    #     status=TaskStatus.IN_PROGRESS,
    #     due_date=datetime.utcnow() - timedelta(days=1),
    # )
    # await task_repo.create(overdue_task)
    
    # overdue = await task_repo.get_overdue_tasks()
    # assert len(overdue) >= 1
    pass  # Placeholder for actual implementation
```

## The Verification

Let's test our database integration:

```bash
# 1. Ensure PostgreSQL is running
# On macOS with Homebrew:
brew services start postgresql
# On Linux:
sudo systemctl start postgresql
# On Windows: Start PostgreSQL from services

# 2. Create the database
psql -U postgres -c "CREATE DATABASE fastapi_db;"

# 3. Run the initial migration
alembic upgrade head

# 4. Run the application
uvicorn app.main:app --reload

# 5. Create a test user (will be implemented in Part 3)
curl -X POST http://localhost:8000/api/v1/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "full_name": "Test User",
    "password": "TestPass123!"
  }'

# 6. Check database tables
psql -U postgres -d fastapi_db -c "\dt"

# 7. Check the user was created
psql -U postgres -d fastapi_db -c "SELECT id, email, username, full_name FROM users;"

# 8. Run tests
pytest tests/ -v
```

## Deep Dive: SQLAlchemy 2.0 Async Patterns

### Async Session Management

```python
# Correct async session usage
async with AsyncSessionLocal() as session:
    # Work with session
    user = await session.get(User, 1)
    # Session is automatically closed when exiting context
    
# Correct pattern for repositories
class UserRepository:
    async def create(self, data):
        db_obj = self.model(**data)
        self.session.add(db_obj)
        await self.session.flush()  # Get ID without committing
        return db_obj
        
# Committing in service layer
class UserService:
    async def create_user(self, data):
        user = await self.repository.create(data)
        await self.session.commit()  # Save to database
        await self.session.refresh(user)  # Get latest data
        return user
```

### Relationship Loading Strategies

```python
# Lazy loading (default) - loads only when accessed
tasks = await session.execute(select(Project))
for project in tasks.scalars():
    tasks_list = project.tasks  # Queries database here

# Eager loading - loads relationships in one query
from sqlalchemy.orm import selectinload
query = select(Project).options(selectinload(Project.tasks))
result = await session.execute(query)

# Joined loading - uses SQL JOIN
from sqlalchemy.orm import joinedload
query = select(Project).options(joinedload(Project.tasks))
```

### Transaction Management

```python
# Using transactions
async with session.begin():
    # All operations in this block are in a transaction
    user = await repository.create(data)
    project = await project_repository.create(project_data)
    # Transaction commits automatically if no exception

# Manual transaction
try:
    await session.add(user)
    await session.flush()
    # Do more work...
    await session.commit()
except Exception:
    await session.rollback()
    raise
```

## What We Accomplished

✅ Set up PostgreSQL with SQLAlchemy 2.0 async support
✅ Created comprehensive database models with relationships
✅ Implemented Alembic migrations for schema management
✅ Built the Repository pattern for data abstraction
✅ Created Service layer for business logic
✅ Implemented user and task repositories with specific methods
✅ Added transaction management and error handling
✅ Set up testing infrastructure

## Key Takeaways

1. **Async Database**: SQLAlchemy 2.0 supports async/await for non-blocking database operations
2. **Models**: Design models with relationships, constraints, and indexes
3. **Migrations**: Alembic provides version control for your database schema
4. **Repository Pattern**: Abstracts database operations for testable code
5. **Service Layer**: Encapsulates business logic and orchestrates repositories
6. **Testing**: Always test database operations with a dedicated test database

## What's Next?

In **[Part 3: Authentication, Authorization & Security]** , we'll:
- Implement OAuth2 with JWT for user authentication
- Add password hashing with bcrypt
- Create role-based access control (RBAC)
- Implement refresh tokens and token rotation
- Add security middleware and headers
