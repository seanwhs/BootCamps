# Primer 2: SQLAlchemy 2.0 Deep Dive

Welcome to the second primer in our FastAPI Masterclass series! This comprehensive guide dives deep into SQLAlchemy 2.0, the powerful ORM we use throughout the main series. Whether you're coming from raw SQL or other ORMs, this primer will give you a thorough understanding of SQLAlchemy's core concepts, advanced features, and best practices for async operations.

## Table of Contents
1. [SQLAlchemy Overview](#sqlalchemy-overview)
2. [Core Concepts](#core-concepts)
3. [Declarative Models](#declarative-models)
4. [Relationships](#relationships)
5. [Querying Data](#querying-data)
6. [Advanced Querying](#advanced-querying)
7. [Async Operations](#async-operations)
8. [Alembic Migrations](#alembic-migrations)
9. [Performance Optimization](#performance-optimization)
10. [Best Practices](#best-practices)

---

## SQLAlchemy Overview

### What is SQLAlchemy?

SQLAlchemy is the most powerful and flexible ORM (Object-Relational Mapper) for Python. Think of it as a translator between your Python objects and your database tables.

**Three Levels of SQLAlchemy:**

```
┌─────────────────────────────────────────┐
│  1. ORM (Object Relational Mapper)      │  ← Highest level (what we use)
│     - Work with Python objects          │
│     - Automatic SQL generation          │
│     - Relationship management           │
├─────────────────────────────────────────┤
│  2. SQL Expression Language             │  ← Middle level
│     - Build SQL programmatically        │
│     - More control than ORM             │
│     - Less abstraction                  │
├─────────────────────────────────────────┤
│  3. Core (Raw Connection)               │  ← Lowest level
│     - Execute raw SQL                   │
│     - Maximum control                   │
│     - No abstraction                    │
└─────────────────────────────────────────┘
```

### SQLAlchemy 2.0 Key Features

```python
"""
SQLAlchemy 2.0 highlights
"""

from typing import Optional, List
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import declarative_base, relationship, Mapped, mapped_column
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import select

# ────────────────────────────────────────────────────────────────
# 1. Type Annotations (SQLAlchemy 2.0 Feature)
# ────────────────────────────────────────────────────────────────

Base = declarative_base()

class User(Base):
    """User model using SQLAlchemy 2.0's Mapped syntax."""
    __tablename__ = "users"
    
    # SQLAlchemy 2.0 uses Mapped with mapped_column
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50), unique=True)
    email: Mapped[str] = mapped_column(String(255), unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    
    # Relationships are also typed
    tasks: Mapped[List["Task"]] = relationship(back_populates="user")

# ────────────────────────────────────────────────────────────────
# 2. Async Support
# ────────────────────────────────────────────────────────────────

async def async_example():
    """SQLAlchemy 2.0 async example."""
    # Async engine
    engine = create_async_engine("postgresql+asyncpg://user:pass@localhost/db")
    
    # Async session
    async with AsyncSession(engine) as session:
        # Async queries
        result = await session.execute(select(User).where(User.is_active == True))
        users = result.scalars().all()
        
        # Async commit
        session.add(User(username="new_user", email="new@example.com"))
        await session.commit()

# ────────────────────────────────────────────────────────────────
# 3. Better Type Checking
# ────────────────────────────────────────────────────────────────

def get_user_name(user: User) -> str:
    """Type checker knows user has username attribute."""
    return user.username  # Type safe!

# ────────────────────────────────────────────────────────────────
# 4. Improved Relationship Handling
# ────────────────────────────────────────────────────────────────

class Task(Base):
    """Task model with relationships."""
    __tablename__ = "tasks"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    
    # Back reference
    user: Mapped[User] = relationship(back_populates="tasks")
```

---

## Core Concepts

### Declarative Base

```python
"""
Understanding SQLAlchemy's declarative base
"""

from sqlalchemy.orm import declarative_base, declared_attr
from sqlalchemy import Column, Integer, String, DateTime, func
from datetime import datetime

# ────────────────────────────────────────────────────────────────
# 1. Creating the Base
# ────────────────────────────────────────────────────────────────

# Base class - all models inherit from this
Base = declarative_base()

# ────────────────────────────────────────────────────────────────
# 2. Custom Base with Common Fields
# ────────────────────────────────────────────────────────────────

class CustomBase:
    """
    Custom base with common functionality.
    All models will inherit these fields and methods.
    """
    
    # Common fields
    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
    
    @declared_attr
    def __tablename__(cls):
        """Automatically generate table name from class name."""
        return cls.__name__.lower() + "s"

# Use custom base
class BaseModel(Base, CustomBase):
    __abstract__ = True  # Don't create a table for this class

# ────────────────────────────────────────────────────────────────
# 3. Model Inheritance
# ────────────────────────────────────────────────────────────────

# Abstract Base (no table)
class TimestampMixin:
    """Mixin for timestamp fields."""
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())

class SoftDeleteMixin:
    """Mixin for soft delete."""
    deleted_at = Column(DateTime, nullable=True)
    
    def soft_delete(self):
        self.deleted_at = datetime.utcnow()
    
    @property
    def is_deleted(self):
        return self.deleted_at is not None

# Concrete model with mixins
class User(Base, TimestampMixin, SoftDeleteMixin):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True)
    email = Column(String(255), unique=True)

# ────────────────────────────────────────────────────────────────
# 4. Table Configuration
# ────────────────────────────────────────────────────────────────

class Product(Base):
    __tablename__ = "products"
    __table_args__ = (
        # Indexes
        Index("idx_products_name", "name"),
        Index("idx_products_category", "category"),
        # Constraints
        CheckConstraint("price >= 0", name="ck_price_positive"),
        # Table options
        {"schema": "app", "comment": "Product catalog"},
    )
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    category = Column(String(50))
    price = Column(Numeric(10, 2))

# ────────────────────────────────────────────────────────────────
# 5. Column Types
# ────────────────────────────────────────────────────────────────

from sqlalchemy import (
    String, Integer, Float, Boolean, DateTime, 
    Date, Time, Text, JSON, Numeric, LargeBinary,
    Enum, ARRAY, UUID
)

class CompleteUser(Base):
    __tablename__ = "complete_users"
    
    # Basic types
    id = Column(Integer, primary_key=True)
    username = Column(String(50), nullable=False, unique=True)
    age = Column(Integer)
    height = Column(Float)
    is_admin = Column(Boolean, default=False)
    
    # Date/time
    birthday = Column(Date)
    wake_time = Column(Time)
    created_at = Column(DateTime, server_default=func.now())
    
    # Text
    bio = Column(Text)
    
    # JSON
    preferences = Column(JSON, default={})
    
    # Numeric with precision
    salary = Column(Numeric(10, 2))
    
    # Binary
    avatar = Column(LargeBinary)
    
    # Enum
    status = Column(Enum("active", "inactive", "suspended", name="user_status"))
    
    # Array (PostgreSQL)
    tags = Column(ARRAY(String))
    
    # UUID
    public_id = Column(UUID, server_default=func.uuid_generate_v4())
```

### Column Options & Constraints

```python
"""
Column options and constraints
"""

from sqlalchemy import Column, Integer, String, Boolean, CheckConstraint, UniqueConstraint
from sqlalchemy.schema import ForeignKey, Index

class Product(Base):
    __tablename__ = "products"
    
    # ────────────────────────────────────────────────────────────────
    # Column Options
    # ────────────────────────────────────────────────────────────────
    
    id = Column(
        Integer,
        primary_key=True,              # Primary key
        index=True,                    # Create index
        nullable=False,                # Not null
        autoincrement=True,            # Auto increment
        doc="Unique product identifier", # Documentation
        server_default="nextval('products_id_seq')",  # Server default
    )
    
    name = Column(
        String(200),
        nullable=False,
        unique=True,                   # Unique constraint
        comment="Product name",       # SQL comment
        index=True,                    # Index for faster queries
    )
    
    price = Column(
        Numeric(10, 2),
        nullable=False,
        server_default="0.00",
    )
    
    is_active = Column(
        Boolean,
        nullable=False,
        server_default="true",
    )
    
    # ────────────────────────────────────────────────────────────────
    # Foreign Keys
    # ────────────────────────────────────────────────────────────────
    
    category_id = Column(
        Integer,
        ForeignKey(
            "categories.id",
            ondelete="SET NULL",       # What happens when parent is deleted
            onupdate="CASCADE",        # What happens when parent is updated
            deferrable=True,           # Can defer constraint checking
            initially="DEFERRED",      # Check at commit time
        ),
        nullable=True,
    )
    
    # ────────────────────────────────────────────────────────────────
    # Multi-column Constraints
    # ────────────────────────────────────────────────────────────────
    
    __table_args__ = (
        # Unique constraint on multiple columns
        UniqueConstraint("sku", "store_id", name="uq_product_sku_store"),
        
        # Check constraint
        CheckConstraint(
            "price >= 0 AND price < 1000000",
            name="ck_price_range"
        ),
        
        # Multiple indexes
        Index("idx_products_name_price", "name", "price"),
        Index("idx_products_category_active", "category_id", "is_active"),
        
        # Table-level options
        {"comment": "Product catalog table"},
    )
```

---

## Relationships

### One-to-Many Relationships

```python
"""
One-to-many relationships
"""

from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship, Mapped, mapped_column, Session
from sqlalchemy.sql import func
from typing import List, Optional

from app.models.base import Base

# ────────────────────────────────────────────────────────────────
# 1. Basic One-to-Many
# ────────────────────────────────────────────────────────────────

class User(Base):
    """User model - the 'one' side."""
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50), unique=True)
    
    # Relationship to tasks
    # A user has many tasks
    tasks: Mapped[List["Task"]] = relationship(
        back_populates="user",      # The back reference name
        lazy="select",              # Loading strategy
        cascade="all, delete-orphan", # What happens to tasks when user is deleted
        order_by="Task.created_at.desc()",  # Default ordering
    )

class Task(Base):
    """Task model - the 'many' side."""
    __tablename__ = "tasks"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    
    # Relationship back to user
    user: Mapped[User] = relationship(back_populates="tasks")

# ────────────────────────────────────────────────────────────────
# 2. Using the Relationship
# ────────────────────────────────────────────────────────────────

def relationship_usage(session: Session):
    """Demonstrate relationship usage."""
    
    # Create user with tasks
    user = User(username="john_doe")
    
    # Add tasks - relationship handles the foreign key
    user.tasks.append(Task(title="Task 1"))
    user.tasks.append(Task(title="Task 2"))
    user.tasks.append(Task(title="Task 3"))
    
    session.add(user)
    session.commit()
    
    # Access tasks from user
    # Tasks are loaded lazily by default
    for task in user.tasks:
        print(f"Task: {task.title}")
    
    # Access user from task
    task = user.tasks[0]
    print(f"User: {task.user.username}")
    
    # Delete user - cascade deletes tasks
    session.delete(user)
    session.commit()

# ────────────────────────────────────────────────────────────────
# 3. Cascade Options Explained
# ────────────────────────────────────────────────────────────────

class Parent(Base):
    __tablename__ = "parents"
    
    id = Column(Integer, primary_key=True)
    children = relationship(
        "Child",
        back_populates="parent",
        cascade="all, delete-orphan",  # Full cascade
        # cascade options:
        #   - save-update: Save when parent is saved
        #   - merge: Merge when parent is merged
        #   - refresh-expire: Refresh when parent is refreshed
        #   - expunge: Remove from session when parent is expunged
        #   - delete: Delete when parent is deleted
        #   - delete-orphan: Delete orphans
        #   - all: All of the above
    )

# ────────────────────────────────────────────────────────────────
# 4. Loading Strategies
# ────────────────────────────────────────────────────────────────

class UserWithStrategies(Base):
    __tablename__ = "users_strategies"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    
    # Different loading strategies
    posts = relationship(
        "Post",
        lazy="select",          # Default - load when accessed
        # lazy="joined",        # Load with eager join
        # lazy="subquery",      # Load with subquery
        # lazy="selectin",      # Load with IN query (recommended)
        # lazy="dynamic",       # Returns a query object
    )
    
    # Using selectinload in a query
    @classmethod
    def get_with_posts(cls, session):
        from sqlalchemy.orm import selectinload
        return session.query(cls).options(
            selectinload(cls.posts)
        ).all()

# ────────────────────────────────────────────────────────────────
# 5. Self-Referential Relationships
# ────────────────────────────────────────────────────────────────

class Employee(Base):
    __tablename__ = "employees"
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100))
    manager_id = Column(Integer, ForeignKey("employees.id"))
    
    # Self-referential relationship
    manager = relationship(
        "Employee",
        remote_side=[id],          # The remote side of the relationship
        backref="subordinates",     # Back reference
        lazy="select",
    )
    
    # Example: Finding a manager's subordinates
    def get_all_subordinates(self, session):
        """Recursively get all subordinates."""
        def get_subordinates(emp):
            result = list(emp.subordinates)
            for sub in emp.subordinates:
                result.extend(get_subordinates(sub))
            return result
        return get_subordinates(self)
```

### Many-to-Many Relationships

```python
"""
Many-to-many relationships
"""

from sqlalchemy import Column, Integer, String, Table, ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column
from typing import List, Optional

from app.models.base import Base

# ────────────────────────────────────────────────────────────────
# 1. Basic Many-to-Many with Association Table
# ────────────────────────────────────────────────────────────────

# Association table - links users and roles
user_role_association = Table(
    "user_roles",
    Base.metadata,
    Column("user_id", Integer, ForeignKey("users.id")),
    Column("role_id", Integer, ForeignKey("roles.id")),
)

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50), unique=True)
    
    # Many-to-many relationship via association table
    roles: Mapped[List["Role"]] = relationship(
        secondary=user_role_association,
        back_populates="users",
        lazy="selectin",  # Recommended for many-to-many
    )

class Role(Base):
    __tablename__ = "roles"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50), unique=True)
    
    users: Mapped[List[User]] = relationship(
        secondary=user_role_association,
        back_populates="roles",
    )

# ────────────────────────────────────────────────────────────────
# 2. Many-to-Many with Extra Fields (Association Object)
# ────────────────────────────────────────────────────────────────

# When you need extra data on the association
class UserProjectAssociation(Base):
    __tablename__ = "user_projects"
    
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("projects.id"), primary_key=True)
    
    # Extra fields on the association
    role: Mapped[str] = mapped_column(String(50))  # e.g., "admin", "member"
    joined_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.now())
    
    # Relationships
    user: Mapped["User"] = relationship(back_populates="project_associations")
    project: Mapped["Project"] = relationship(back_populates="user_associations")

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50))
    
    # Use the association object
    project_associations: Mapped[List[UserProjectAssociation]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )
    
    # Convenience property to get projects directly
    @property
    def projects(self):
        return [assoc.project for assoc in self.project_associations]

class Project(Base):
    __tablename__ = "projects"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    
    user_associations: Mapped[List[UserProjectAssociation]] = relationship(
        back_populates="project",
        cascade="all, delete-orphan",
    )

# ────────────────────────────────────────────────────────────────
# 3. Using Many-to-Many Relationships
# ────────────────────────────────────────────────────────────────

def many_to_many_usage(session: Session):
    """Demonstrate many-to-many usage."""
    
    # Create roles
    admin = Role(name="admin")
    viewer = Role(name="viewer")
    
    # Create user
    user = User(username="john_doe")
    
    # Add roles to user
    user.roles.append(admin)
    user.roles.append(viewer)
    
    session.add(user)
    session.commit()
    
    # Query users with roles
    users = session.query(User).options(
        selectinload(User.roles)
    ).all()
    
    for user in users:
        print(f"User: {user.username}")
        for role in user.roles:
            print(f"  Role: {role.name}")
    
    # Remove a role
    user.roles.remove(viewer)
    session.commit()

# ────────────────────────────────────────────────────────────────
# 4. Complex Many-to-Many with Association Proxy
# ────────────────────────────────────────────────────────────────

from sqlalchemy.ext.associationproxy import association_proxy

class UserWithProxy(Base):
    __tablename__ = "users_proxy"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
    
    # Association objects
    memberships: Mapped[List["Membership"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )
    
    # Association proxy to access groups directly
    groups = association_proxy("memberships", "group")
    
    # Add a membership
    def join_group(self, group, role="member"):
        self.memberships.append(Membership(group=group, role=role))

class Group(Base):
    __tablename__ = "groups"
    
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
    
    memberships: Mapped[List["Membership"]] = relationship(
        back_populates="group",
        cascade="all, delete-orphan",
    )
    
    # Proxy to users
    users = association_proxy("memberships", "user")

class Membership(Base):
    __tablename__ = "memberships"
    
    user_id: Mapped[int] = mapped_column(ForeignKey("users_proxy.id"), primary_key=True)
    group_id: Mapped[int] = mapped_column(ForeignKey("groups.id"), primary_key=True)
    role: Mapped[str] = mapped_column(String(50))
    
    user: Mapped[UserWithProxy] = relationship(back_populates="memberships")
    group: Mapped[Group] = relationship(back_populates="memberships")
```

---

## Querying Data

### Basic Queries

```python
"""
Basic SQLAlchemy queries
"""

from sqlalchemy import select, and_, or_, not_, desc, asc, func
from sqlalchemy.orm import Session, joinedload, selectinload
from typing import List, Optional

# ────────────────────────────────────────────────────────────────
# 1. SELECT Queries
# ────────────────────────────────────────────────────────────────

def basic_select_queries(session: Session):
    """Demonstrate basic SELECT queries."""
    
    # Get all users
    users = session.query(User).all()
    
    # Get first user
    user = session.query(User).first()
    
    # Get one by ID
    user = session.query(User).get(1)
    
    # Get count
    count = session.query(User).count()
    
    # Filter by condition
    active_users = session.query(User).filter(User.is_active == True).all()
    
    # Filter by multiple conditions
    users = session.query(User).filter(
        User.is_active == True,
        User.age >= 18
    ).all()
    
    # Filter with AND/OR
    from sqlalchemy import and_, or_
    users = session.query(User).filter(
        and_(
            User.is_active == True,
            or_(
                User.age >= 18,
                User.role == "admin"
            )
        )
    ).all()
    
    # Select specific columns
    results = session.query(User.username, User.email).all()
    
    # Order by
    users = session.query(User).order_by(User.created_at.desc()).all()
    
    # Limit and offset (pagination)
    users = session.query(User).offset(10).limit(20).all()
    
    # Distinct
    roles = session.query(User.role).distinct().all()

# ────────────────────────────────────────────────────────────────
# 2. WHERE Clause Conditions
# ────────────────────────────────────────────────────────────────

def where_clause_examples(session: Session):
    """Demonstrate WHERE clause conditions."""
    
    # Equality
    users = session.query(User).filter(User.username == "john_doe").all()
    
    # Inequality
    users = session.query(User).filter(User.age != 18).all()
    
    # IN
    users = session.query(User).filter(User.role.in_(["admin", "manager"])).all()
    
    # NOT IN
    users = session.query(User).filter(~User.role.in_(["admin", "manager"])).all()
    
    # LIKE
    users = session.query(User).filter(User.username.like("john%")).all()
    
    # ILIKE (case-insensitive, PostgreSQL)
    users = session.query(User).filter(User.username.ilike("%doe%")).all()
    
    # BETWEEN
    users = session.query(User).filter(User.age.between(18, 65)).all()
    
    # IS NULL
    users = session.query(User).filter(User.email.is_(None)).all()
    
    # IS NOT NULL
    users = session.query(User).filter(User.email.isnot(None)).all()
    
    # Contains (array operations)
    from sqlalchemy import literal
    users = session.query(User).filter(User.tags.contains(["python"])).all()
    
    # Any (array operations)
    users = session.query(User).filter(User.tags.any("python")).all()

# ────────────────────────────────────────────────────────────────
# 3. Sorting and Pagination
# ────────────────────────────────────────────────────────────────

def sorting_and_pagination(session: Session):
    """Demonstrate sorting and pagination."""
    
    # Single column sort
    users = session.query(User).order_by(User.username.asc()).all()
    users = session.query(User).order_by(User.username.desc()).all()
    
    # Multiple column sort
    users = session.query(User).order_by(
        User.role.asc(),
        User.username.desc()
    ).all()
    
    # Pagination helper
    def paginate(query, page: int = 1, per_page: int = 20):
        """Paginate a query."""
        return query.offset((page - 1) * per_page).limit(per_page)
    
    users = paginate(session.query(User), page=2, per_page=10).all()

# ────────────────────────────────────────────────────────────────
# 4. Joins
# ────────────────────────────────────────────────────────────────

def join_examples(session: Session):
    """Demonstrate various JOIN types."""
    
    # Inner Join
    results = session.query(User, Task).join(Task, User.id == Task.user_id).all()
    
    # Left Outer Join
    results = session.query(User).outerjoin(Task).all()
    
    # Join with conditions
    results = session.query(User).join(
        Task, 
        and_(User.id == Task.user_id, Task.status == "done")
    ).all()
    
    # Join with relationship
    results = session.query(User).join(User.tasks).all()
    
    # Multiple joins
    results = session.query(User).join(User.projects).join(Project.members).all()
    
    # Select specific fields from joined tables
    results = session.query(
        User.username,
        Task.title,
        Task.status
    ).join(Task).all()

# ────────────────────────────────────────────────────────────────
# 5. Aggregations and Group By
# ────────────────────────────────────────────────────────────────

def aggregation_examples(session: Session):
    """Demonstrate aggregations and GROUP BY."""
    
    from sqlalchemy import func
    
    # Count
    count = session.query(func.count(User.id)).scalar()
    
    # Sum
    total = session.query(func.sum(Task.estimated_hours)).scalar()
    
    # Average
    avg = session.query(func.avg(Task.actual_hours)).scalar()
    
    # Min/Max
    min_age = session.query(func.min(User.age)).scalar()
    max_age = session.query(func.max(User.age)).scalar()
    
    # Group By
    results = session.query(
        User.role,
        func.count(User.id).label("count")
    ).group_by(User.role).all()
    
    # Group By with Having
    results = session.query(
        User.role,
        func.count(User.id).label("count")
    ).group_by(User.role).having(
        func.count(User.id) > 10
    ).all()
    
    # Multiple aggregates
    results = session.query(
        User.role,
        func.count(User.id).label("user_count"),
        func.avg(User.age).label("avg_age"),
        func.min(User.created_at).label("oldest")
    ).group_by(User.role).all()
```

### Advanced Querying

```python
"""
Advanced SQLAlchemy queries
"""

from sqlalchemy import select, and_, or_, not_, func, text, union, intersect, except_
from sqlalchemy.orm import Session, aliased, subqueryload, selectinload, joinedload
from typing import List, Optional, Dict, Any

# ────────────────────────────────────────────────────────────────
# 1. Subqueries
# ────────────────────────────────────────────────────────────────

def subquery_examples(session: Session):
    """Demonstrate subqueries."""
    
    # Subquery in WHERE
    subquery = session.query(func.avg(Task.estimated_hours)).scalar_subquery()
    tasks = session.query(Task).filter(Task.estimated_hours > subquery).all()
    
    # Subquery in FROM
    subquery = session.query(
        User.id,
        func.count(Task.id).label("task_count")
    ).join(Task).group_by(User.id).subquery()
    
    users = session.query(User, subquery.c.task_count).join(
        subquery, User.id == subquery.c.id
    ).all()
    
    # Correlated subquery
    subquery = session.query(
        func.count(Task.id)
    ).filter(Task.user_id == User.id).scalar_subquery()
    
    users = session.query(
        User,
        subquery.label("task_count")
    ).all()

# ────────────────────────────────────────────────────────────────
# 2. Common Table Expressions (CTE)
# ────────────────────────────────────────────────────────────────

def cte_examples(session: Session):
    """Demonstrate Common Table Expressions."""
    
    # Recursive CTE (for hierarchical data)
    from sqlalchemy import select, union_all
    
    # Find all subordinates (including nested)
    employee_alias = aliased(Employee)
    
    # Base case: direct subordinates
    base = select(employee_alias).where(employee_alias.manager_id == 1)
    
    # Recursive case: subordinates of subordinates
    recursive = union_all(
        base,
        select(employee_alias).join(
            base.cte,
            base.cte.c.id == employee_alias.manager_id
        )
    )
    
    # Full CTE
    cte = recursive.cte(name="subordinates", recursive=True)
    
    # Query the CTE
    results = session.execute(select(cte)).all()

# ────────────────────────────────────────────────────────────────
# 3. Window Functions
# ────────────────────────────────────────────────────────────────

def window_function_examples(session: Session):
    """Demonstrate window functions."""
    
    from sqlalchemy import func
    
    # Row number
    query = session.query(
        User.username,
        User.created_at,
        func.row_number().over(
            order_by=User.created_at
        ).label("row_num")
    )
    
    # Rank
    query = session.query(
        User.username,
        User.score,
        func.rank().over(
            order_by=User.score.desc()
        ).label("rank")
    )
    
    # Partition by
    query = session.query(
        User.username,
        User.role,
        User.score,
        func.rank().over(
            partition_by=User.role,
            order_by=User.score.desc()
        ).label("rank_in_role")
    )
    
    # Running total
    query = session.query(
        User.username,
        User.created_at,
        func.sum(User.id).over(
            order_by=User.created_at
        ).label("running_total")
    )

# ────────────────────────────────────────────────────────────────
# 4. Eager Loading
# ────────────────────────────────────────────────────────────────

def eager_loading_examples(session: Session):
    """Demonstrate eager loading strategies."""
    
    from sqlalchemy.orm import selectinload, joinedload, subqueryload
    
    # ────────────────────────────────────────────────────────────────
    # selectinload (Recommended for most cases)
    # ────────────────────────────────────────────────────────────────
    users = session.query(User).options(
        selectinload(User.tasks),
        selectinload(User.projects)
    ).all()
    # Fires: 1 query for users, 1 query for tasks (IN), 1 query for projects
    
    # ────────────────────────────────────────────────────────────────
    # joinedload (Good for one-to-one relationships)
    # ────────────────────────────────────────────────────────────────
    users = session.query(User).options(
        joinedload(User.profile)
    ).all()
    # Fires: 1 query with LEFT JOIN
    
    # ────────────────────────────────────────────────────────────────
    # subqueryload (Good for large collections)
    # ────────────────────────────────────────────────────────────────
    users = session.query(User).options(
        subqueryload(User.tasks)
    ).all()
    # Fires: 1 query for users, 1 subquery for tasks
    
    # ────────────────────────────────────────────────────────────────
    # Nested eager loading
    # ────────────────────────────────────────────────────────────────
    from sqlalchemy.orm import selectinload
    
    users = session.query(User).options(
        selectinload(User.tasks).selectinload(Task.comments),
        selectinload(User.projects).selectinload(Project.members)
    ).all()
    
    # ────────────────────────────────────────────────────────────────
    # Dynamic loading strategy
    # ────────────────────────────────────────────────────────────────
    # Instead of defining at model level, apply at query time
    class User(Base):
        __tablename__ = "users"
        id = Column(Integer, primary_key=True)
        # Don't define lazy on relationship
        tasks = relationship("Task", lazy="raise")  # Raises if not loaded
    
    # Then use options to load
    users = session.query(User).options(
        selectinload(User.tasks)  # Override the lazy strategy
    ).all()

# ────────────────────────────────────────────────────────────────
# 5. Raw SQL Execution
# ────────────────────────────────────────────────────────────────

def raw_sql_examples(session: Session):
    """Demonstrate raw SQL execution."""
    
    from sqlalchemy import text
    
    # Execute raw SQL
    result = session.execute(text("SELECT * FROM users WHERE is_active = true"))
    users = result.fetchall()
    
    # With parameters
    result = session.execute(
        text("SELECT * FROM users WHERE age > :min_age AND role = :role"),
        {"min_age": 18, "role": "admin"}
    )
    
    # Multiple statements
    result = session.execute(text("""
        BEGIN;
        UPDATE users SET is_active = false WHERE last_login < NOW() - INTERVAL '1 year';
        DELETE FROM sessions WHERE user_id NOT IN (SELECT id FROM users WHERE is_active = true);
        COMMIT;
    """))
    
    # Using SQLAlchemy's text() with ORM
    users = session.query(User).from_statement(
        text("SELECT * FROM users WHERE is_active = true")
    ).all()
    
    # Hybrid: ORM with raw SQL
    from sqlalchemy import func
    users = session.query(User).filter(
        text("EXTRACT(YEAR FROM created_at) = 2024")
    ).all()
```

---

## Async Operations

### Async Session Management

```python
"""
Async session management with SQLAlchemy 2.0
"""

from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    AsyncEngine,
    async_sessionmaker,
)
from sqlalchemy.orm import declarative_base
from sqlalchemy import select, text
from typing import AsyncGenerator, Optional
import logging

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────────────────────
# 1. Async Engine Configuration
# ────────────────────────────────────────────────────────────────

def create_async_engine_from_config(
    database_url: str,
    pool_size: int = 10,
    max_overflow: int = 20,
    pool_recycle: int = 3600,
    pool_pre_ping: bool = True,
    echo: bool = False,
) -> AsyncEngine:
    """
    Create an async engine with proper configuration.
    
    Args:
        database_url: PostgreSQL async URL (postgresql+asyncpg://...)
        pool_size: Connection pool size
        max_overflow: Maximum overflow connections
        pool_recycle: Recycle connections after this many seconds
        pool_pre_ping: Test connections before using
        echo: Echo SQL statements
        
    Returns:
        AsyncEngine: Configured async engine
    """
    engine = create_async_engine(
        database_url,
        pool_size=pool_size,
        max_overflow=max_overflow,
        pool_recycle=pool_recycle,
        pool_pre_ping=pool_pre_ping,
        echo=echo,
        # Additional asyncpg settings
        connect_args={
            "server_settings": {
                "application_name": "fastapi_app",
                "timezone": "UTC",
                "statement_timeout": "30000",  # 30 seconds
            },
            "timeout": 30,
        },
    )
    
    logger.info(f"Async engine created with pool size {pool_size}")
    return engine

# ────────────────────────────────────────────────────────────────
# 2. Async Session Factory
# ────────────────────────────────────────────────────────────────

async def get_async_session(
    engine: AsyncEngine
) -> AsyncGenerator[AsyncSession, None]:
    """
    Get an async session.
    
    This is used as a dependency in FastAPI:
        async def get_db():
            async with get_async_session(engine) as session:
                yield session
    
    Args:
        engine: Async engine
        
    Yields:
        AsyncSession: Async session
    """
    async_session_maker = async_sessionmaker(
        engine,
        class_=AsyncSession,
        expire_on_commit=False,
        autocommit=False,
        autoflush=False,
    )
    
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

# ────────────────────────────────────────────────────────────────
# 3. Async CRUD Operations
# ────────────────────────────────────────────────────────────────

class AsyncCRUD:
    """Async CRUD operations."""
    
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def create(self, model) -> model:
        """Create a record."""
        self.session.add(model)
        await self.session.flush()
        return model
    
    async def get_by_id(self, model, id: int):
        """Get a record by ID."""
        result = await self.session.get(model, id)
        return result
    
    async def get_all(self, model, skip: int = 0, limit: int = 100):
        """Get all records with pagination."""
        query = select(model).offset(skip).limit(limit)
        result = await self.session.execute(query)
        return result.scalars().all()
    
    async def update(self, model):
        """Update a record."""
        await self.session.flush()
        return model
    
    async def delete(self, model):
        """Delete a record."""
        await self.session.delete(model)
        await self.session.flush()
        return model
    
    async def execute(self, query):
        """Execute a custom query."""
        result = await self.session.execute(query)
        return result

# ────────────────────────────────────────────────────────────────
# 4. Async Query Examples
# ────────────────────────────────────────────────────────────────

async def async_query_examples(session: AsyncSession):
    """Demonstrate async queries."""
    
    # ────────────────────────────────────────────────────────────────
    # Basic SELECT
    # ────────────────────────────────────────────────────────────────
    # Get all
    result = await session.execute(select(User))
    users = result.scalars().all()
    
    # Get first
    result = await session.execute(select(User).limit(1))
    user = result.scalar_one_or_none()
    
    # Filter
    result = await session.execute(
        select(User).where(User.is_active == True)
    )
    active_users = result.scalars().all()
    
    # ────────────────────────────────────────────────────────────────
    # SELECT with multiple conditions
    # ────────────────────────────────────────────────────────────────
    result = await session.execute(
        select(User).where(
            User.is_active == True,
            User.age >= 18,
            User.role.in_(["admin", "manager"])
        )
    )
    
    # ────────────────────────────────────────────────────────────────
    # SELECT with ordering and pagination
    # ────────────────────────────────────────────────────────────────
    result = await session.execute(
        select(User)
        .order_by(User.created_at.desc())
        .offset(10)
        .limit(20)
    )
    
    # ────────────────────────────────────────────────────────────────
    # SELECT with JOIN
    # ────────────────────────────────────────────────────────────────
    result = await session.execute(
        select(User, Task)
        .join(Task, User.id == Task.user_id)
    )
    
    # ────────────────────────────────────────────────────────────────
    # SELECT with eager loading
    # ────────────────────────────────────────────────────────────────
    from sqlalchemy.orm import selectinload
    
    result = await session.execute(
        select(User)
        .options(selectinload(User.tasks))
        .where(User.id == 1)
    )
    user_with_tasks = result.scalar_one_or_none()
    
    # ────────────────────────────────────────────────────────────────
    # Aggregations
    # ────────────────────────────────────────────────────────────────
    from sqlalchemy import func
    
    result = await session.execute(
        select(
            func.count(User.id),
            func.avg(User.age),
        )
    )
    count, avg_age = result.first()
    
    # ────────────────────────────────────────────────────────────────
    # Group By
    # ────────────────────────────────────────────────────────────────
    result = await session.execute(
        select(
            User.role,
            func.count(User.id).label("count")
        )
        .group_by(User.role)
    )
    role_counts = result.all()

# ────────────────────────────────────────────────────────────────
# 5. Async Transaction Management
# ────────────────────────────────────────────────────────────────

async def async_transaction_examples(session: AsyncSession):
    """Demonstrate async transactions."""
    
    # ────────────────────────────────────────────────────────────────
    # Simple transaction
    # ────────────────────────────────────────────────────────────────
    try:
        # Operations are in a transaction
        user = User(username="test_user")
        session.add(user)
        
        task = Task(title="Test task", user=user)
        session.add(task)
        
        # Commit all changes
        await session.commit()
    except Exception:
        # Rollback on error
        await session.rollback()
        raise
    
    # ────────────────────────────────────────────────────────────────
    # Explicit transaction management
    # ────────────────────────────────────────────────────────────────
    async with session.begin():
        # All operations here are in a transaction
        user = User(username="another_user")
        session.add(user)
        
        task = Task(title="Another task", user=user)
        session.add(task)
        
        # Auto-commit on successful exit
        # Auto-rollback on exception
    
    # ────────────────────────────────────────────────────────────────
    # Nested transactions (savepoints)
    # ────────────────────────────────────────────────────────────────
    async with session.begin():
        user = User(username="outer_user")
        session.add(user)
        
        async with session.begin_nested():
            # This is a savepoint
            task = Task(title="inner_task", user=user)
            session.add(task)
            # If this fails, only inner transaction rolls back
        
        # Outer transaction continues

# ────────────────────────────────────────────────────────────────
# 6. Async Connection Pool Monitoring
# ────────────────────────────────────────────────────────────────

async def monitor_connection_pool(engine: AsyncEngine):
    """Monitor connection pool statistics."""
    
    # Get connection pool status
    pool = engine.sync_engine.pool
    
    stats = {
        "size": pool.size(),
        "checkedin": pool.checkedin(),
        "checkedout": pool.checkedout(),
        "overflow": pool.overflow(),
        "total": pool.size() + pool.overflow(),
    }
    
    logger.info(f"Connection pool stats: {stats}")
    
    # Wait for connections if needed
    if stats["checkedout"] == stats["total"]:
        logger.warning("Connection pool exhausted!")
    
    return stats
```

---

## Alembic Migrations

### Migration Management

```python
"""
Alembic migration management
"""

# ────────────────────────────────────────────────────────────────
# 1. Alembic Configuration (alembic.ini)
# ────────────────────────────────────────────────────────────────

# alembic.ini
"""
[alembic]
script_location = alembic
prepend_sys_path = .
version_path_separator = os
sqlalchemy.url = postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_db

[post_write_hooks]
hooks = black
black.type = console_scripts
black.entrypoint = black
black.options = -l 88

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
"""

# ────────────────────────────────────────────────────────────────
# 2. Alembic Environment (alembic/env.py)
# ────────────────────────────────────────────────────────────────

# alembic/env.py
"""
import asyncio
from logging.config import fileConfig
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import async_engine_from_config
from alembic import context

import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))

from app.core.database import Base
from app.core.config import settings
from app.models import *

config = context.config

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

target_metadata = Base.metadata

def run_migrations_offline() -> None:
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
    context.configure(
        connection=connection,
        target_metadata=target_metadata,
        compare_type=True,
        compare_server_default=True,
    )

    with context.begin_transaction():
        context.run_migrations()

async def run_async_migrations() -> None:
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

    await connectable.dispose()

def run_migrations_online() -> None:
    asyncio.run(run_async_migrations())

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
"""

# ────────────────────────────────────────────────────────────────
# 3. Migration Script Example
# ────────────────────────────────────────────────────────────────

# alembic/versions/xxxx_initial_migration.py
"""
from alembic import op
import sqlalchemy as sa

revision = 'xxxx'
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    # Create users table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('username', sa.String(length=50), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('full_name', sa.String(length=100), nullable=False),
        sa.Column('role', sa.Enum('admin', 'manager', 'developer', 'viewer', name='userrole'), nullable=False),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.text('now()'), nullable=False),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email'),
        sa.UniqueConstraint('username'),
    )
    op.create_index('ix_users_email', 'users', ['email'])
    op.create_index('ix_users_username', 'users', ['username'])
    op.create_index('ix_users_role', 'users', ['role'])

    # Create tasks table
    op.create_table(
        'tasks',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('title', sa.String(length=200), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('status', sa.Enum('todo', 'in_progress', 'review', 'done', 'archived', name='taskstatus'), nullable=False),
        sa.Column('priority', sa.Enum('low', 'medium', 'high', 'critical', name='taskpriority'), nullable=False),
        sa.Column('due_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.text('now()'), nullable=False),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
        sa.Column('project_id', sa.Integer(), nullable=True),
        sa.Column('created_by_id', sa.Integer(), nullable=True),
        sa.Column('assignee_id', sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(['assignee_id'], ['users.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['created_by_id'], ['users.id'], ondelete='SET NULL'),
        sa.ForeignKeyConstraint(['project_id'], ['projects.id'], ondelete='SET NULL'),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index('ix_tasks_title', 'tasks', ['title'])
    op.create_index('ix_tasks_status', 'tasks', ['status'])
    op.create_index('ix_tasks_assignee_id', 'tasks', ['assignee_id'])
    op.create_index('ix_tasks_created_by_id', 'tasks', ['created_by_id'])
    op.create_index('ix_tasks_project_id', 'tasks', ['project_id'])
    op.create_index('ix_tasks_status_assignee', 'tasks', ['status', 'assignee_id'])
    op.create_index('ix_tasks_project_status', 'tasks', ['project_id', 'status'])

def downgrade() -> None:
    op.drop_index('ix_tasks_project_status', table_name='tasks')
    op.drop_index('ix_tasks_status_assignee', table_name='tasks')
    op.drop_index('ix_tasks_project_id', table_name='tasks')
    op.drop_index('ix_tasks_created_by_id', table_name='tasks')
    op.drop_index('ix_tasks_assignee_id', table_name='tasks')
    op.drop_index('ix_tasks_status', table_name='tasks')
    op.drop_index('ix_tasks_title', table_name='tasks')
    op.drop_table('tasks')
    
    op.drop_index('ix_users_role', table_name='users')
    op.drop_index('ix_users_username', table_name='users')
    op.drop_index('ix_users_email', table_name='users')
    op.drop_table('users')
    
    op.execute('DROP TYPE IF EXISTS userrole')
    op.execute('DROP TYPE IF EXISTS taskpriority')
    op.execute('DROP TYPE IF EXISTS taskstatus')
"""

# ────────────────────────────────────────────────────────────────
# 4. Migration Commands
# ────────────────────────────────────────────────────────────────

"""
# Create a new migration
alembic revision --autogenerate -m "Add new table"

# Upgrade to latest
alembic upgrade head

# Downgrade by one
alembic downgrade -1

# Upgrade to specific revision
alembic upgrade <revision_id>

# View current revision
alembic current

# View migration history
alembic history

# Check for pending migrations
alembic stamp head  # Mark as current without running migrations
"""
```

---

## Performance Optimization

### Query Optimization

```python
"""
SQLAlchemy performance optimization
"""

from sqlalchemy import select, text
from sqlalchemy.orm import Session, selectinload, joinedload
from typing import List, Optional
import time
import logging

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────────────────────
# 1. N+1 Query Problem and Solution
# ────────────────────────────────────────────────────────────────

class NPlusOneProblem:
    """Demonstrate and fix the N+1 query problem."""
    
    # ────────────────────────────────────────────────────────────────
    # BAD: N+1 queries
    # ────────────────────────────────────────────────────────────────
    @staticmethod
    def bad_query(session: Session):
        """Causes N+1 queries."""
        # 1 query for users
        users = session.query(User).all()
        
        # N queries for tasks (one per user)
        for user in users:
            tasks = user.tasks  # Triggers query
            print(f"User {user.username} has {len(tasks)} tasks")
    
    # ────────────────────────────────────────────────────────────────
    # GOOD: Eager loading
    # ────────────────────────────────────────────────────────────────
    @staticmethod
    def good_query_selectin(session: Session):
        """Uses selectinload to avoid N+1."""
        # 2 queries total (1 for users, 1 for tasks)
        users = session.query(User).options(
            selectinload(User.tasks)
        ).all()
        
        for user in users:
            tasks = user.tasks  # Already loaded
            print(f"User {user.username} has {len(tasks)} tasks")
    
    @staticmethod
    def good_query_joined(session: Session):
        """Uses joinedload to avoid N+1."""
        # 1 query with JOIN
        users = session.query(User).options(
            joinedload(User.tasks)
        ).all()
        
        for user in users:
            tasks = user.tasks  # Already loaded
            print(f"User {user.username} has {len(tasks)} tasks")

# ────────────────────────────────────────────────────────────────
# 2. Bulk Operations
# ────────────────────────────────────────────────────────────────

def bulk_operations(session: Session):
    """Demonstrate bulk operations for performance."""
    
    # ────────────────────────────────────────────────────────────────
    # BAD: Individual inserts
    # ────────────────────────────────────────────────────────────────
    def bad_bulk_insert():
        users = []
        for i in range(1000):
            user = User(username=f"user_{i}", email=f"user_{i}@example.com")
            session.add(user)
            users.append(user)
        session.commit()  # 1000 individual INSERT statements
    
    # ────────────────────────────────────────────────────────────────
    # GOOD: Bulk insert
    # ────────────────────────────────────────────────────────────────
    def good_bulk_insert():
        users = [
            User(username=f"user_{i}", email=f"user_{i}@example.com")
            for i in range(1000)
        ]
        session.bulk_insert_mappings(User, [
            {"username": f"user_{i}", "email": f"user_{i}@example.com"}
            for i in range(1000)
        ])
        session.commit()  # Single INSERT with multiple rows
    
    # ────────────────────────────────────────────────────────────────
    # Bulk update
    # ────────────────────────────────────────────────────────────────
    def bulk_update():
        # Update all users
        session.bulk_update_mappings(User, [
            {"id": user.id, "is_active": False}
            for user in session.query(User).all()
        ])
        session.commit()
    
    # ────────────────────────────────────────────────────────────────
    # Bulk delete
    # ────────────────────────────────────────────────────────────────
    def bulk_delete():
        # Delete all inactive users
        session.query(User).filter(User.is_active == False).delete()
        session.commit()

# ────────────────────────────────────────────────────────────────
# 3. Index Selection
# ────────────────────────────────────────────────────────────────

class IndexStrategy:
    """Choose the right indexes for queries."""
    
    # ────────────────────────────────────────────────────────────────
    # Query: Find tasks by assignee and status
    # ────────────────────────────────────────────────────────────────
    # CREATE INDEX idx_tasks_assignee_status ON tasks(assignee_id, status)
    # WHERE status NOT IN ('done', 'archived');
    
    @staticmethod
    def get_assigned_tasks(session: Session, user_id: int):
        """Uses composite index."""
        return session.query(Task).filter(
            Task.assignee_id == user_id,
            Task.status.in_(['todo', 'in_progress', 'review'])
        ).all()
    
    # ────────────────────────────────────────────────────────────────
    # Query: Find tasks by project and due date
    # ────────────────────────────────────────────────────────────────
    # CREATE INDEX idx_tasks_project_due ON tasks(project_id, due_date)
    # WHERE due_date IS NOT NULL AND status NOT IN ('done', 'archived');
    
    @staticmethod
    def get_upcoming_tasks(session: Session, project_id: int):
        """Uses composite index."""
        from datetime import datetime, timedelta
        
        return session.query(Task).filter(
            Task.project_id == project_id,
            Task.due_date.between(
                datetime.utcnow(),
                datetime.utcnow() + timedelta(days=7)
            ),
            Task.status.notin_(['done', 'archived'])
        ).all()
    
    # ────────────────────────────────────────────────────────────────
    # Query: Text search in tasks
    # ────────────────────────────────────────────────────────────────
    # CREATE INDEX idx_tasks_search ON tasks
    # USING gin(to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(description, '')));
    
    @staticmethod
    def search_tasks(session: Session, search_term: str):
        """Uses full-text search index."""
        from sqlalchemy import func
        
        return session.query(Task).filter(
            func.to_tsvector(
                'english',
                func.coalesce(Task.title, '') + ' ' + func.coalesce(Task.description, '')
            ).match(search_term)
        ).all()

# ────────────────────────────────────────────────────────────────
# 4. Query Profiling
# ────────────────────────────────────────────────────────────────

class QueryProfiler:
    """Profile SQLAlchemy queries."""
    
    def __init__(self, session: Session):
        self.session = session
    
    def profile_query(self, query):
        """
        Profile a query using EXPLAIN ANALYZE.
        
        Args:
            query: SQLAlchemy query
            
        Returns:
            dict: Query execution plan and timing
        """
        # Get the SQL string
        sql = str(query.statement.compile(
            compile_kwargs={"literal_binds": True}
        ))
        
        # Run EXPLAIN
        from sqlalchemy import text
        result = self.session.execute(
            text(f"EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) {sql}")
        )
        plan = result.fetchall()
        
        return {
            "sql": sql,
            "plan": plan,
            "query": query,
        }
    
    def find_slow_queries(self, threshold_ms: int = 100):
        """
        Find slow queries using pg_stat_statements.
        
        Args:
            threshold_ms: Minimum execution time in milliseconds
            
        Returns:
            list: Slow queries
        """
        from sqlalchemy import text
        
        result = self.session.execute(
            text("""
                SELECT 
                    query,
                    calls,
                    total_time / calls AS avg_time_ms,
                    max_time,
                    rows
                FROM pg_stat_statements
                WHERE calls > 10
                AND total_time / calls > :threshold
                ORDER BY total_time / calls DESC
                LIMIT 20
            """),
            {"threshold": threshold_ms}
        )
        
        return result.all()
```

---

## Best Practices

### SQLAlchemy Best Practices Guide

```python
"""
SQLAlchemy best practices
"""

# ────────────────────────────────────────────────────────────────
# 1. Model Design
# ────────────────────────────────────────────────────────────────

class BestPracticeModel(Base):
    """
    Example of a well-designed model.
    """
    
    __tablename__ = "best_practice_models"
    
    # Use explicit type hints (SQLAlchemy 2.0)
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    
    # Use meaningful column names
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    
    # Use appropriate types
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        server_default=func.now(),
        nullable=False
    )
    
    # Use server defaults when possible
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        server_default="true",
        nullable=False
    )
    
    # Define relationships with back_populates
    posts: Mapped[List["Post"]] = relationship(
        back_populates="author",
        cascade="all, delete-orphan",
        lazy="selectin"  # Use selectinload by default
    )
    
    # Add __table_args__ for indexes and constraints
    __table_args__ = (
        Index("idx_username_active", "username", "is_active"),
        CheckConstraint(
            "age >= 0 AND age <= 150",
            name="ck_valid_age"
        ),
    )

# ────────────────────────────────────────────────────────────────
# 2. Query Best Practices
# ────────────────────────────────────────────────────────────────

class QueryBestPractices:
    """Best practices for queries."""
    
    @staticmethod
    def use_selectin_load(session: Session):
        """Use selectinload for relationships."""
        # Good
        users = session.query(User).options(
            selectinload(User.posts),
            selectinload(User.profile)
        ).all()
        
        # Avoid
        # users = session.query(User).options(
        #     joinedload(User.posts),  # Can cause cartesian product
        # ).all()
    
    @staticmethod
    def use_pagination(session: Session, page: int = 1, per_page: int = 20):
        """Always use pagination for list queries."""
        return session.query(User).offset(
            (page - 1) * per_page
        ).limit(per_page).all()
    
    @staticmethod
    def use_column_lists(session: Session):
        """Select only needed columns."""
        # Good
        users = session.query(User.id, User.username).all()
        
        # Avoid
        # users = session.query(User).all()  # Selects all columns
    
    @staticmethod
    def use_indexes(session: Session, user_id: int):
        """Use indexed fields in WHERE clauses."""
        # Good - indexed field
        return session.query(Task).filter(Task.assignee_id == user_id).all()
        
        # Avoid
        # return session.query(Task).filter(Task.title.like("%test%")).all()

# ────────────────────────────────────────────────────────────────
# 3. Session Management Best Practices
# ────────────────────────────────────────────────────────────────

class SessionBestPractices:
    """Best practices for session management."""
    
    @staticmethod
    def use_context_manager():
        """Always use session as context manager."""
        # Good
        with Session(engine) as session:
            user = session.query(User).first()
            session.commit()
        
        # Avoid
        # session = Session(engine)
        # try:
        #     user = session.query(User).first()
        #     session.commit()
        # finally:
        #     session.close()
    
    @staticmethod
    def expire_on_commit():
        """Configure sessions appropriately."""
        # For read-only operations
        session = Session(engine, expire_on_commit=False)
        
        # For write operations (default)
        session = Session(engine, expire_on_commit=True)
    
    @staticmethod
    def refresh_after_commit():
        """Refresh objects after commit if needed."""
        session = Session(engine)
        user = session.query(User).first()
        user.username = "new_username"
        session.commit()
        
        # If you need updated values from triggers or defaults
        session.refresh(user)

# ────────────────────────────────────────────────────────────────
# 4. Performance Anti-Patterns to Avoid
# ────────────────────────────────────────────────────────────────

class AntiPatterns:
    """Common performance anti-patterns to avoid."""
    
    @staticmethod
    def avoid_n_plus_one(session: Session):
        """Avoid the N+1 query problem."""
        # BAD
        users = session.query(User).all()
        for user in users:
            print(len(user.posts))  # Triggers N additional queries
        
        # GOOD
        users = session.query(User).options(selectinload(User.posts)).all()
        for user in users:
            print(len(user.posts))  # Already loaded
    
    @staticmethod
    def avoid_large_results(session: Session):
        """Avoid fetching large result sets."""
        # BAD
        all_users = session.query(User).all()  # Could be millions
        
        # GOOD
        for user in session.query(User).yield_per(1000):
            process_user(user)
    
    @staticmethod
    def avoid_serialized_transactions(session: Session):
        """Avoid long-running transactions."""
        # BAD
        # Start transaction
        user = session.query(User).first()
        # Do lots of work...
        time.sleep(60)  # Transaction held open
        user.username = "new"
        session.commit()
        
        # GOOD
        user = session.query(User).first()
        user.username = "new"
        # Do quick work...
        session.commit()
        # Do heavy work outside transaction
    
    @staticmethod
    def avoid_overfetching(session: Session):
        """Avoid fetching data you don't need."""
        # BAD
        all_data = session.query(Post).all()  # Fetches all columns
        
        # GOOD
        titles = session.query(Post.id, Post.title).all()  # Only needed columns
```

---

This primer has provided a comprehensive deep dive into SQLAlchemy 2.0. You should now understand:

1. **Core Concepts**: Declarative base, models, and column types
2. **Relationships**: One-to-many, many-to-many, and self-referential
3. **Querying**: Basic SELECT, filters, joins, and advanced queries
4. **Async Operations**: Async sessions, queries, and transaction management
5. **Alembic Migrations**: Creating and managing database migrations
6. **Performance Optimization**: Eager loading, bulk operations, and indexes
7. **Best Practices**: Model design, query optimization, and anti-patterns

These concepts are essential for building robust, scalable FastAPI applications with SQLAlchemy. Practice these patterns and refer back to this primer whenever you need to understand database operations in your applications.

**[END OF PRIMER 2]**
