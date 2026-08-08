# FastAPI Masterclass: Lab Book

**Hands-On Laboratory Exercises for Building Production-Ready APIs**

---

## How to Use This Lab Book

This lab book contains practical, hands-on exercises that reinforce the concepts taught in the FastAPI Masterclass. Each lab includes:

1. **Learning Objectives** - What you'll accomplish
2. **Prerequisites** - What you need before starting
3. **Step-by-Step Instructions** - Detailed walkthroughs
4. **Code Examples** - Complete, working code
5. **Verification Steps** - How to test your work
6. **Challenge Extensions** - Extra credit exercises
7. **Lab Solutions** - Complete working solutions

---

## Lab 1: Setting Up Your FastAPI Environment

### Learning Objectives
- Set up a Python virtual environment
- Install FastAPI and Uvicorn
- Create a basic FastAPI application
- Understand the development server
- Explore automatic API documentation

### Prerequisites
- Python 3.10+ installed
- A code editor (VS Code recommended)
- Terminal/Command prompt access

### Step 1: Create Project Directory

```bash
# Create and navigate to project directory
mkdir fastapi-lab-1
cd fastapi-lab-1

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip
```

### Step 2: Install Dependencies

```bash
# Install FastAPI and Uvicorn
pip install fastapi uvicorn[standard]

# Verify installation
pip list | grep fastapi
pip list | grep uvicorn
```

### Step 3: Create Your First FastAPI Application

Create a file called `main.py`:

```python
"""
main.py - Your first FastAPI application
"""

from fastapi import FastAPI

# Create the FastAPI app instance
app = FastAPI(
    title="My First FastAPI App",
    description="Learning FastAPI from scratch",
    version="1.0.0"
)

# Root endpoint
@app.get("/")
async def root():
    """
    Root endpoint - returns a welcome message.
    """
    return {"message": "Welcome to FastAPI!"}

# Health check endpoint
@app.get("/health")
async def health_check():
    """
    Health check endpoint for monitoring.
    """
    return {"status": "healthy", "service": "FastAPI Lab"}

# Greeting endpoint with path parameter
@app.get("/greet/{name}")
async def greet(name: str):
    """
    Greet a user by name.
    
    Args:
        name: The name to greet
    """
    return {"message": f"Hello, {name}!"}

# Echo endpoint with query parameters
@app.get("/echo")
async def echo(message: str = "Hello"):
    """
    Echo a message back.
    
    Args:
        message: The message to echo (default: "Hello")
    """
    return {"echo": message}
```

### Step 4: Run the Application

```bash
# Start the development server
uvicorn main:app --reload

# You should see output like:
# INFO:     Uvicorn running on http://127.0.0.1:8000
# INFO:     Application startup complete.
```

### Step 5: Test Your API

**Method 1: Browser**
- Open `http://localhost:8000`
- Open `http://localhost:8000/docs` (Swagger UI)
- Open `http://localhost:8000/redoc` (ReDoc)

**Method 2: Command Line (curl)**
```bash
# Test root endpoint
curl http://localhost:8000/

# Test health endpoint
curl http://localhost:8000/health

# Test greet endpoint
curl http://localhost:8000/greet/John

# Test echo endpoint
curl "http://localhost:8000/echo?message=FastAPI%20is%20awesome"
```

### Step 6: Verify Everything Works

**Expected Outputs:**

Root endpoint:
```json
{"message": "Welcome to FastAPI!"}
```

Health endpoint:
```json
{"status": "healthy", "service": "FastAPI Lab"}
```

Greet endpoint:
```json
{"message": "Hello, John!"}
```

Echo endpoint:
```json
{"echo": "FastAPI is awesome"}
```

### Challenge Extensions

1. Add a new endpoint `/add/{a}/{b}` that returns the sum of two numbers
2. Add a new endpoint `/multiply` with query parameters `a` and `b`
3. Add a `POST` endpoint `/items/` that accepts JSON data
4. Add proper status codes to your endpoints

### Lab Solution

```python
# Enhanced main.py with all challenges

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
from typing import Optional

app = FastAPI(title="My First FastAPI App", version="1.0.0")

class Item(BaseModel):
    name: str
    price: float
    description: Optional[str] = None

@app.get("/")
async def root():
    return {"message": "Welcome to FastAPI!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "FastAPI Lab"}

@app.get("/greet/{name}")
async def greet(name: str):
    return {"message": f"Hello, {name}!"}

@app.get("/echo")
async def echo(message: str = "Hello"):
    return {"echo": message}

# Challenge 1: Add two numbers
@app.get("/add/{a}/{b}")
async def add(a: float, b: float):
    return {"result": a + b, "operation": "addition"}

# Challenge 2: Multiply with query parameters
@app.get("/multiply")
async def multiply(a: float, b: float):
    return {"result": a * b, "operation": "multiplication"}

# Challenge 3: POST endpoint
@app.post("/items/", status_code=status.HTTP_201_CREATED)
async def create_item(item: Item):
    # In a real app, you'd save to a database
    return {"item": item, "status": "created", "id": 1}
```

---

## Lab 2: Pydantic Models and Data Validation

### Learning Objectives
- Create Pydantic models for data validation
- Use Field constraints and validators
- Implement request/response models
- Handle validation errors
- Use nested models

### Prerequisites
- Lab 1 completed
- Understanding of Python type hints

### Step 1: Create User Models

Create a file called `models.py`:

```python
"""
models.py - Pydantic models for data validation
"""

from pydantic import BaseModel, Field, EmailStr, field_validator, model_validator
from typing import Optional, List
from datetime import datetime
import re

# ────────────────────────────────────────────────────────────────
# 1. Basic User Model
# ────────────────────────────────────────────────────────────────

class UserBase(BaseModel):
    """Base user model with common fields."""
    username: str = Field(
        ...,
        min_length=3,
        max_length=50,
        pattern=r'^[a-zA-Z0-9_]+$',
        description="Username (3-50 chars, alphanumeric and underscore)"
    )
    email: EmailStr = Field(
        ...,
        description="Valid email address"
    )
    full_name: str = Field(
        ...,
        min_length=1,
        max_length=100,
        description="User's full name"
    )

# ────────────────────────────────────────────────────────────────
# 2. User Creation Model (with password)
# ────────────────────────────────────────────────────────────────

class UserCreate(UserBase):
    """Model for creating a new user."""
    password: str = Field(
        ...,
        min_length=8,
        description="Password (min 8 chars)"
    )
    confirm_password: str = Field(
        ...,
        description="Confirm password"
    )
    
    @field_validator('password')
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        """Validate password strength."""
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one number')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError('Password must contain at least one special character')
        return v
    
    @model_validator(mode='after')
    def validate_passwords_match(self) -> 'UserCreate':
        """Ensure passwords match."""
        if self.password != self.confirm_password:
            raise ValueError('Passwords do not match')
        return self

# ────────────────────────────────────────────────────────────────
# 3. User Response Model
# ────────────────────────────────────────────────────────────────

class UserResponse(UserBase):
    """Model for user responses (excludes sensitive data)."""
    id: int = Field(..., description="User ID")
    is_active: bool = Field(True, description="Account status")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")

# ────────────────────────────────────────────────────────────────
# 4. User Update Model
# ────────────────────────────────────────────────────────────────

class UserUpdate(BaseModel):
    """Model for updating a user (all fields optional)."""
    username: Optional[str] = Field(
        None,
        min_length=3,
        max_length=50,
        pattern=r'^[a-zA-Z0-9_]+$'
    )
    email: Optional[EmailStr] = None
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)
    is_active: Optional[bool] = None

# ────────────────────────────────────────────────────────────────
# 5. Nested Models
# ────────────────────────────────────────────────────────────────

class Address(BaseModel):
    """Address model."""
    street: str = Field(..., min_length=1)
    city: str = Field(..., min_length=1)
    state: str = Field(..., min_length=2)
    zip_code: str = Field(..., pattern=r'^\d{5}(-\d{4})?$')
    country: str = Field(default="USA")

class UserProfile(BaseModel):
    """User profile with nested address."""
    user: UserResponse
    address: Optional[Address] = None
    bio: Optional[str] = Field(None, max_length=500)
    phone_number: Optional[str] = Field(None, pattern=r'^\+?1?\d{9,15}$')

# ────────────────────────────────────────────────────────────────
# 6. Generic Response Models
# ────────────────────────────────────────────────────────────────

from typing import Generic, TypeVar

T = TypeVar('T')

class APIResponse(BaseModel, Generic[T]):
    """Generic API response wrapper."""
    success: bool = Field(True)
    message: str = "Success"
    data: Optional[T] = None
    errors: Optional[List[str]] = None

class PaginatedResponse(BaseModel, Generic[T]):
    """Generic paginated response."""
    items: List[T]
    total: int
    page: int
    size: int
    pages: int
```

### Step 2: Create the API Endpoints

Create a file called `main.py`:

```python
"""
main.py - API with Pydantic validation
"""

from fastapi import FastAPI, HTTPException, status
from typing import List
from datetime import datetime
import uuid

from models import (
    UserCreate,
    UserResponse,
    UserUpdate,
    UserProfile,
    Address,
    APIResponse,
    PaginatedResponse
)

app = FastAPI(
    title="Pydantic Validation Lab",
    description="Learning Pydantic data validation",
    version="1.0.0"
)

# Mock database
users_db = {}
user_counter = 1

# ────────────────────────────────────────────────────────────────
# 1. Create User Endpoint
# ────────────────────────────────────────────────────────────────

@app.post(
    "/users/",
    response_model=APIResponse[UserResponse],
    status_code=status.HTTP_201_CREATED
)
async def create_user(user_data: UserCreate):
    """
    Create a new user with validation.
    """
    global user_counter
    
    # Check if username already exists
    for user in users_db.values():
        if user["username"] == user_data.username:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already taken"
            )
        if user["email"] == user_data.email:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered"
            )
    
    # Create user
    user_id = user_counter
    user_counter += 1
    
    user = {
        "id": user_id,
        "username": user_data.username,
        "email": user_data.email,
        "full_name": user_data.full_name,
        "is_active": True,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    users_db[user_id] = user
    
    return APIResponse(
        success=True,
        message="User created successfully",
        data=UserResponse(**user)
    )

# ────────────────────────────────────────────────────────────────
# 2. Get Users List (Paginated)
# ────────────────────────────────────────────────────────────────

@app.get("/users/", response_model=APIResponse[PaginatedResponse[UserResponse]])
async def list_users(page: int = 1, size: int = 10):
    """
    Get a paginated list of users.
    """
    users = list(users_db.values())
    total = len(users)
    
    start = (page - 1) * size
    end = start + size
    
    paginated_users = users[start:end]
    
    response_data = PaginatedResponse(
        items=[UserResponse(**user) for user in paginated_users],
        total=total,
        page=page,
        size=size,
        pages=(total + size - 1) // size
    )
    
    return APIResponse(data=response_data)

# ────────────────────────────────────────────────────────────────
# 3. Get User by ID
# ────────────────────────────────────────────────────────────────

@app.get("/users/{user_id}", response_model=APIResponse[UserResponse])
async def get_user(user_id: int):
    """
    Get a user by ID.
    """
    user = users_db.get(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return APIResponse(data=UserResponse(**user))

# ────────────────────────────────────────────────────────────────
# 4. Update User
# ────────────────────────────────────────────────────────────────

@app.put("/users/{user_id}", response_model=APIResponse[UserResponse])
async def update_user(user_id: int, update_data: UserUpdate):
    """
    Update a user.
    """
    user = users_db.get(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    update_dict = update_data.model_dump(exclude_unset=True)
    
    # Check for username conflicts
    if "username" in update_dict:
        for existing_user in users_db.values():
            if (existing_user["username"] == update_dict["username"] and 
                existing_user["id"] != user_id):
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Username already taken"
                )
    
    # Update user fields
    for key, value in update_dict.items():
        user[key] = value
    
    user["updated_at"] = datetime.utcnow()
    
    return APIResponse(
        success=True,
        message="User updated successfully",
        data=UserResponse(**user)
    )

# ────────────────────────────────────────────────────────────────
# 5. Delete User
# ────────────────────────────────────────────────────────────────

@app.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int):
    """
    Delete a user.
    """
    if user_id not in users_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    del users_db[user_id]
    return None

# ────────────────────────────────────────────────────────────────
# 6. User Profile (with nested models)
# ────────────────────────────────────────────────────────────────

@app.post("/users/{user_id}/profile", response_model=APIResponse[UserProfile])
async def create_user_profile(user_id: int, address: Address, bio: str = None):
    """
    Create a user profile with nested address.
    """
    user = users_db.get(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    profile = UserProfile(
        user=UserResponse(**user),
        address=address,
        bio=bio
    )
    
    return APIResponse(
        success=True,
        message="Profile created successfully",
        data=profile
    )
```

### Step 3: Test Your API

```bash
# Start the server
uvicorn main:app --reload

# In a new terminal, test the endpoints

# 1. Create a user
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "full_name": "John Doe",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!"
  }'

# 2. Get user list
curl http://localhost:8000/users/

# 3. Get user by ID
curl http://localhost:8000/users/1

# 4. Update user
curl -X PUT http://localhost:8000/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Johnathan Doe",
    "is_active": false
  }'

# 5. Create user profile
curl -X POST http://localhost:8000/users/1/profile \
  -H "Content-Type: application/json" \
  -d '{
    "address": {
      "street": "123 Main St",
      "city": "Boston",
      "state": "MA",
      "zip_code": "02101",
      "country": "USA"
    },
    "bio": "Software engineer"
  }'

# 6. Test validation errors
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "invalid username with spaces",
    "email": "not-an-email",
    "full_name": "",
    "password": "weak",
    "confirm_password": "different"
  }'
```

### Verification Steps

1. **Create User**: Should return 201 with user data
2. **Get Users**: Should return paginated list
3. **Get User**: Should return user data or 404 if not found
4. **Update User**: Should return updated user data
5. **Delete User**: Should return 204 No Content
6. **Validation Errors**: Should return 422 with detailed error messages

### Challenge Extensions

1. Add email verification to the user model
2. Implement age validation (must be 18+)
3. Add phone number validation with country codes
4. Create a search endpoint with multiple filters
5. Add rate limiting to prevent abuse

### Lab Solution

Complete solution is shown in the code above. Key takeaways:

1. **Field Validation**: Use `Field()` with constraints
2. **Custom Validators**: Use `@field_validator` for specific fields
3. **Model Validation**: Use `@model_validator` for cross-field validation
4. **Nested Models**: Use models as field types
5. **Generic Models**: Use `Generic[T]` for reusable responses

---

## Lab 3: Database Integration with SQLAlchemy

### Learning Objectives
- Set up SQLAlchemy with async PostgreSQL
- Create database models
- Implement CRUD operations
- Use Alembic migrations
- Build a repository pattern

### Prerequisites
- PostgreSQL installed or Docker
- Lab 1 and 2 completed

### Step 1: Install Dependencies

```bash
# Install SQLAlchemy and related packages
pip install sqlalchemy alembic asyncpg psycopg2-binary

# Install additional packages
pip install python-dotenv
```

### Step 2: Setup Database Configuration

Create a file called `app/core/database.py`:

```python
"""
app/core/database.py - Database configuration
"""

from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    async_sessionmaker
)
from sqlalchemy.orm import declarative_base, declared_attr
from sqlalchemy import Column, Integer, DateTime, func, MetaData
from typing import AsyncGenerator
import os
from dotenv import load_dotenv

load_dotenv()

# Database URL
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://postgres:postgres@localhost:5432/fastapi_lab"
)

# Engine
engine = create_async_engine(
    DATABASE_URL,
    echo=True,
    pool_size=10,
    max_overflow=20
)

# Session factory
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Naming convention for constraints
convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

# Base class
class CustomBase:
    @declared_attr
    def __tablename__(cls):
        import re
        name = re.sub(r'(?<!^)(?=[A-Z])', '_', cls.__name__).lower()
        return f"{name}s"

Base = declarative_base(
    cls=CustomBase,
    metadata=MetaData(naming_convention=convention)
)

# ────────────────────────────────────────────────────────────────
# Database Session Dependency
# ────────────────────────────────────────────────────────────────

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Get database session for dependency injection.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

# ────────────────────────────────────────────────────────────────
# Database Initialization
# ────────────────────────────────────────────────────────────────

async def init_db():
    """
    Initialize database tables.
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def drop_db():
    """
    Drop all tables.
    """
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
```

### Step 3: Create Database Models

Create `app/models/user.py`:

```python
"""
app/models/user.py - User database model
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base

class User(Base):
    """
    User model for database.
    """
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    full_name = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_superuser = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, onupdate=func.now())
    
    # Relationships
    tasks = relationship("Task", back_populates="user")
    
    def __repr__(self):
        return f"<User(id={self.id}, username='{self.username}')>"
```

Create `app/models/task.py`:

```python
"""
app/models/task.py - Task database model
"""

from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.core.database import Base

class Task(Base):
    """
    Task model for database.
    """
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(20), nullable=False, default="todo")
    priority = Column(String(20), nullable=False, default="medium")
    is_completed = Column(Boolean, default=False)
    due_date = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, onupdate=func.now())
    
    # Foreign keys
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="tasks")
    
    def __repr__(self):
        return f"<Task(id={self.id}, title='{self.title[:30]}')>"
```

### Step 4: Setup Alembic

```bash
# Initialize Alembic
alembic init alembic

# Update alembic.ini with database URL
# Edit alembic/env.py to import models
```

Update `alembic/env.py`:

```python
import sys
from pathlib import Path

# Add project root to path
sys.path.append(str(Path(__file__).parent.parent))

from app.core.database import Base
from app.models.user import User
from app.models.task import Task
from app.core.config import settings

# Set database URL
config.set_main_option("sqlalchemy.url", DATABASE_URL)

# Target metadata
target_metadata = Base.metadata
```

### Step 5: Create Repository Pattern

Create `app/repositories/base.py`:

```python
"""
app/repositories/base.py - Base repository
"""

from typing import TypeVar, Generic, Type, Optional, List, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.sql import Select

ModelType = TypeVar("ModelType")

class BaseRepository(Generic[ModelType]):
    """
    Base repository with common CRUD operations.
    """
    
    def __init__(self, model: Type[ModelType], session: AsyncSession):
        self.model = model
        self.session = session
    
    async def create(self, **kwargs) -> ModelType:
        """Create a new record."""
        obj = self.model(**kwargs)
        self.session.add(obj)
        await self.session.flush()
        return obj
    
    async def get(self, id: int) -> Optional[ModelType]:
        """Get a record by ID."""
        result = await self.session.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()
    
    async def get_all(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None,
        order_by: Optional[str] = None,
        descending: bool = False
    ) -> List[ModelType]:
        """Get all records with pagination."""
        query = select(self.model)
        
        if filters:
            for key, value in filters.items():
                if hasattr(self.model, key) and value is not None:
                    query = query.where(getattr(self.model, key) == value)
        
        if order_by and hasattr(self.model, order_by):
            column = getattr(self.model, order_by)
            if descending:
                column = column.desc()
            query = query.order_by(column)
        
        query = query.offset(skip).limit(limit)
        result = await self.session.execute(query)
        return result.scalars().all()
    
    async def update(self, id: int, **kwargs) -> Optional[ModelType]:
        """Update a record."""
        obj = await self.get(id)
        if obj:
            for key, value in kwargs.items():
                if hasattr(obj, key):
                    setattr(obj, key, value)
            await self.session.flush()
        return obj
    
    async def delete(self, id: int) -> bool:
        """Delete a record."""
        obj = await self.get(id)
        if obj:
            await self.session.delete(obj)
            await self.session.flush()
            return True
        return False
    
    async def count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """Count records with optional filters."""
        query = select(func.count()).select_from(self.model)
        
        if filters:
            for key, value in filters.items():
                if hasattr(self.model, key) and value is not None:
                    query = query.where(getattr(self.model, key) == value)
        
        result = await self.session.execute(query)
        return result.scalar()
```

Create `app/repositories/user.py`:

```python
"""
app/repositories/user.py - User repository
"""

from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_

from app.repositories.base import BaseRepository
from app.models.user import User

class UserRepository(BaseRepository[User]):
    """
    User repository with additional user-specific methods.
    """
    
    def __init__(self, session: AsyncSession):
        super().__init__(User, session)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        result = await self.session.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def get_by_username(self, username: str) -> Optional[User]:
        """Get user by username."""
        result = await self.session.execute(
            select(User).where(User.username == username)
        )
        return result.scalar_one_or_none()
    
    async def get_by_email_or_username(
        self,
        email: str,
        username: str
    ) -> Optional[User]:
        """Get user by email or username."""
        result = await self.session.execute(
            select(User).where(
                or_(User.email == email, User.username == username)
            )
        )
        return result.scalar_one_or_none()
    
    async def get_active_users(self, skip: int = 0, limit: int = 100):
        """Get active users only."""
        return await self.get_all(
            skip=skip,
            limit=limit,
            filters={"is_active": True}
        )
```

### Step 6: Create Service Layer

Create `app/services/user.py`:

```python
"""
app/services/user.py - User service
"""

from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from passlib.context import CryptContext

from app.repositories.user import UserRepository
from app.models.user import User

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserService:
    """
    User service with business logic.
    """
    
    def __init__(self, session: AsyncSession):
        self.session = session
        self.repository = UserRepository(session)
    
    async def create_user(
        self,
        username: str,
        email: str,
        full_name: str,
        password: str
    ) -> User:
        """Create a new user with hashed password."""
        # Check if user exists
        existing = await self.repository.get_by_email_or_username(email, username)
        if existing:
            raise ValueError("User with this email or username already exists")
        
        # Hash password
        hashed_password = pwd_context.hash(password)
        
        # Create user
        user = await self.repository.create(
            username=username,
            email=email,
            full_name=full_name,
            hashed_password=hashed_password
        )
        
        await self.session.commit()
        await self.session.refresh(user)
        return user
    
    async def authenticate(self, email: str, password: str) -> Optional[User]:
        """Authenticate a user."""
        user = await self.repository.get_by_email(email)
        
        if not user:
            return None
        
        if not user.is_active:
            return None
        
        if not pwd_context.verify(password, user.hashed_password):
            return None
        
        return user
    
    async def get_user(self, user_id: int) -> Optional[User]:
        """Get user by ID."""
        return await self.repository.get(user_id)
    
    async def update_user(self, user_id: int, **kwargs) -> Optional[User]:
        """Update a user."""
        user = await self.repository.update(user_id, **kwargs)
        if user:
            await self.session.commit()
            await self.session.refresh(user)
        return user
    
    async def deactivate_user(self, user_id: int) -> Optional[User]:
        """Deactivate a user."""
        return await self.update_user(user_id, is_active=False)
```

### Step 7: Create API Endpoints

Create `app/main.py`:

```python
"""
app/main.py - Main FastAPI application
"""

from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from datetime import datetime

from app.core.database import get_db, init_db
from app.services.user import UserService
from app.schemas.user import UserCreate, UserResponse, UserUpdate

app = FastAPI(
    title="Database Integration Lab",
    description="FastAPI with SQLAlchemy and PostgreSQL",
    version="1.0.0"
)

# ────────────────────────────────────────────────────────────────
# Startup Event
# ────────────────────────────────────────────────────────────────

@app.on_event("startup")
async def startup():
    """Initialize database on startup."""
    await init_db()
    print("Database initialized")

# ────────────────────────────────────────────────────────────────
# Health Check
# ────────────────────────────────────────────────────────────────

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "Database Lab"}

# ────────────────────────────────────────────────────────────────
# User Endpoints
# ────────────────────────────────────────────────────────────────

@app.post("/users/", response_model=UserResponse, status_code=201)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new user.
    """
    try:
        service = UserService(db)
        user = await service.create_user(
            username=user_data.username,
            email=user_data.email,
            full_name=user_data.full_name,
            password=user_data.password
        )
        return UserResponse.from_orm(user)
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))

@app.get("/users/", response_model=List[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = False,
    db: AsyncSession = Depends(get_db)
):
    """
    Get list of users.
    """
    service = UserService(db)
    
    if active_only:
        users = await service.repository.get_active_users(skip=skip, limit=limit)
    else:
        users = await service.repository.get_all(skip=skip, limit=limit)
    
    return [UserResponse.from_orm(user) for user in users]

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get a user by ID.
    """
    service = UserService(db)
    user = await service.get_user(user_id)
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse.from_orm(user)

@app.put("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: AsyncSession = Depends(get_db)
):
    """
    Update a user.
    """
    service = UserService(db)
    
    # Check if user exists
    user = await service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update user
    update_dict = user_data.model_dump(exclude_unset=True)
    updated = await service.update_user(user_id, **update_dict)
    
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse.from_orm(updated)

@app.delete("/users/{user_id}", status_code=204)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Delete a user.
    """
    service = UserService(db)
    
    deleted = await service.repository.delete(user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")
    
    await db.commit()
    return None
```

### Step 8: Create Schemas

Create `app/schemas/user.py`:

```python
"""
app/schemas/user.py - User Pydantic schemas
"""

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator
from typing import Optional
from datetime import datetime
import re

class UserBase(BaseModel):
    """Base user schema."""
    username: str = Field(
        ...,
        min_length=3,
        max_length=50,
        pattern=r'^[a-zA-Z0-9_]+$'
    )
    email: EmailStr
    full_name: str = Field(..., min_length=1, max_length=100)

class UserCreate(UserBase):
    """Schema for creating a user."""
    password: str = Field(..., min_length=8)
    confirm_password: str
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain an uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain a lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain a number')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError('Password must contain a special character')
        return v
    
    @model_validator(mode='after')
    def validate_passwords_match(self) -> 'UserCreate':
        if self.password != self.confirm_password:
            raise ValueError('Passwords do not match')
        return self

class UserUpdate(BaseModel):
    """Schema for updating a user."""
    username: Optional[str] = Field(
        None,
        min_length=3,
        max_length=50,
        pattern=r'^[a-zA-Z0-9_]+$'
    )
    email: Optional[EmailStr] = None
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    """Schema for user responses."""
    id: int
    is_active: bool
    is_superuser: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
```

### Step 9: Run Migrations

```bash
# Create migration
alembic revision --autogenerate -m "Initial migration"

# Apply migration
alembic upgrade head
```

### Step 10: Test the Application

```bash
# Run the application
uvicorn app.main:app --reload

# In another terminal, test the endpoints

# 1. Create a user
curl -X POST http://localhost:8000/users/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "full_name": "John Doe",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!"
  }'

# 2. Get all users
curl http://localhost:8000/users/

# 3. Get a specific user
curl http://localhost:8000/users/1

# 4. Update a user
curl -X PUT http://localhost:8000/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Johnathan Doe",
    "is_active": false
  }'

# 5. Delete a user
curl -X DELETE http://localhost:8000/users/1
```

### Challenge Extensions

1. Add Task CRUD operations
2. Implement filtering and sorting for list endpoints
3. Add pagination metadata to responses
4. Implement soft delete with a `deleted_at` field
5. Create a search endpoint with full-text search

---

## Lab 4: Authentication & Security

### Learning Objectives
- Implement JWT authentication
- Add password hashing
- Create login/register endpoints
- Implement role-based access control
- Secure API endpoints

### Step 1: Install Security Dependencies

```bash
pip install python-jose[cryptography] passlib[bcrypt] python-multipart
```

### Step 2: Create Security Utilities

Create `app/core/security.py`:

```python
"""
app/core/security.py - Security utilities
"""

from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any
import os

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT settings
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-this-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plain password against a hashed password."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)

def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_refresh_token(data: Dict[str, Any]) -> str:
    """Create a JWT refresh token."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_token(token: str) -> Dict[str, Any]:
    """Decode and verify a JWT token."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise ValueError("Invalid token")
```

### Step 3: Create Authentication Endpoints

Create `app/api/auth.py`:

```python
"""
app/api/auth.py - Authentication endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import timedelta

from app.core.database import get_db
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    verify_password,
    get_password_hash,
    ACCESS_TOKEN_EXPIRE_MINUTES
)
from app.services.user import UserService
from app.schemas.auth import TokenResponse, RegisterRequest, RefreshTokenRequest
from app.schemas.user import UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])

# OAuth2 scheme
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

# ────────────────────────────────────────────────────────────────
# Register Endpoint
# ────────────────────────────────────────────────────────────────

@router.post("/register", response_model=UserResponse, status_code=201)
async def register(
    user_data: RegisterRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Register a new user.
    """
    service = UserService(db)
    
    try:
        user = await service.create_user(
            username=user_data.username,
            email=user_data.email,
            full_name=user_data.full_name,
            password=user_data.password
        )
        return UserResponse.from_orm(user)
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))

# ────────────────────────────────────────────────────────────────
# Login Endpoint
# ────────────────────────────────────────────────────────────────

@router.post("/login", response_model=TokenResponse)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncSession = Depends(get_db)
):
    """
    Login and get access token.
    """
    service = UserService(db)
    
    # Authenticate user
    user = await service.authenticate(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    # Create tokens
    access_token = create_access_token({"sub": user.id, "role": "user"})
    refresh_token = create_refresh_token({"sub": user.id})
    
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60
    )

# ────────────────────────────────────────────────────────────────
# Refresh Token Endpoint
# ────────────────────────────────────────────────────────────────

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    refresh_request: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Refresh access token using refresh token.
    """
    try:
        payload = decode_token(refresh_request.refresh_token)
        
        # Check token type
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")
        
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Check if user exists and is active
        service = UserService(db)
        user = await service.get_user(user_id)
        if not user or not user.is_active:
            raise HTTPException(status_code=401, detail="User not found or inactive")
        
        # Create new tokens
        access_token = create_access_token({"sub": user.id, "role": "user"})
        refresh_token = create_refresh_token({"sub": user.id})
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60
        )
        
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

# ────────────────────────────────────────────────────────────────
# Logout Endpoint
# ────────────────────────────────────────────────────────────────

@router.post("/logout", status_code=204)
async def logout(
    token: str = Depends(oauth2_scheme)
):
    """
    Logout and invalidate token.
    """
    # In production, you'd add the token to a blacklist
    # For now, just return success
    return None
```

### Step 4: Create Authentication Schemas

Create `app/schemas/auth.py`:

```python
"""
app/schemas/auth.py - Authentication schemas
"""

from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional
import re

class RegisterRequest(BaseModel):
    """Register request schema."""
    username: str = Field(..., min_length=3, max_length=50, pattern=r'^[a-zA-Z0-9_]+$')
    email: EmailStr
    full_name: str = Field(..., min_length=1, max_length=100)
    password: str = Field(..., min_length=8)
    
    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'\d', v):
            raise ValueError('Password must contain at least one number')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError('Password must contain at least one special character')
        return v

class TokenResponse(BaseModel):
    """Token response schema."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int

class RefreshTokenRequest(BaseModel):
    """Refresh token request schema."""
    refresh_token: str
```

### Step 5: Create Authentication Middleware

Create `app/core/dependencies.py`:

```python
"""
app/core/dependencies.py - Authentication dependencies
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.security import decode_token
from app.services.user import UserService

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
):
    """
    Get current authenticated user.
    """
    try:
        payload = decode_token(token)
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Check token type
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="Invalid token type")
        
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    service = UserService(db)
    user = await service.get_user(user_id)
    
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
    
    if not user.is_active:
        raise HTTPException(status_code=401, detail="User is inactive")
    
    return user

async def get_current_active_user(
    current_user = Depends(get_current_user)
):
    """
    Get current active user (verified and active).
    """
    if not current_user.is_active:
        raise HTTPException(status_code=401, detail="User is inactive")
    return current_user

async def get_current_superuser(
    current_user = Depends(get_current_active_user)
):
    """
    Get current superuser.
    """
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Superuser privileges required"
        )
    return current_user

class RoleChecker:
    """
    Role-based access control checker.
    """
    def __init__(self, allowed_roles: list):
        self.allowed_roles = allowed_roles
    
    async def __call__(self, current_user = Depends(get_current_active_user)):
        if current_user.role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        return current_user
```

### Step 6: Update User Model

Update `app/models/user.py` to include role:

```python
"""
app/models/user.py - User model with role
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum
from sqlalchemy.sql import func
import enum

from app.core.database import Base

class UserRole(str, enum.Enum):
    """User roles for RBAC."""
    ADMIN = "admin"
    MANAGER = "manager"
    DEVELOPER = "developer"
    VIEWER = "viewer"

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    full_name = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(Enum(UserRole), default=UserRole.VIEWER, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_superuser = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, onupdate=func.now())
    
    tasks = relationship("Task", back_populates="user")
```

### Step 7: Create Protected Endpoints

Update `app/main.py`:

```python
"""
app/main.py - Main application with authentication
"""

from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.core.database import get_db, init_db
from app.core.dependencies import get_current_user, get_current_superuser, RoleChecker
from app.api import auth
from app.services.user import UserService
from app.schemas.user import UserResponse, UserUpdate

app = FastAPI(
    title="Authentication & Security Lab",
    description="FastAPI with JWT authentication and RBAC",
    version="1.0.0"
)

# Include auth router
app.include_router(auth.router)

# ────────────────────────────────────────────────────────────────
# Protected User Endpoints
# ────────────────────────────────────────────────────────────────

@app.get("/users/me", response_model=UserResponse)
async def get_current_user_info(
    current_user = Depends(get_current_user)
):
    """
    Get current user information.
    """
    return UserResponse.from_orm(current_user)

@app.put("/users/me", response_model=UserResponse)
async def update_current_user(
    user_data: UserUpdate,
    current_user = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Update current user.
    """
    service = UserService(db)
    
    update_dict = user_data.model_dump(exclude_unset=True)
    updated = await service.update_user(current_user.id, **update_dict)
    
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse.from_orm(updated)

@app.get("/users/", response_model=List[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = 100,
    current_user = Depends(RoleChecker(["admin", "manager"])),
    db: AsyncSession = Depends(get_db)
):
    """
    List users (admin/manager only).
    """
    service = UserService(db)
    users = await service.repository.get_all(skip=skip, limit=limit)
    return [UserResponse.from_orm(user) for user in users]

@app.delete("/users/{user_id}", status_code=204)
async def delete_user(
    user_id: int,
    current_user = Depends(get_current_superuser),
    db: AsyncSession = Depends(get_db)
):
    """
    Delete a user (superuser only).
    """
    service = UserService(db)
    
    if user_id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot delete yourself")
    
    deleted = await service.repository.delete(user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")
    
    await db.commit()
    return None

@app.post("/users/{user_id}/deactivate", response_model=UserResponse)
async def deactivate_user(
    user_id: int,
    current_user = Depends(RoleChecker(["admin", "manager"])),
    db: AsyncSession = Depends(get_db)
):
    """
    Deactivate a user (admin/manager only).
    """
    service = UserService(db)
    
    user = await service.deactivate_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse.from_orm(user)
```

### Step 8: Create Alembic Migration

```bash
# Create migration for role field
alembic revision --autogenerate -m "Add role and superuser fields"

# Apply migration
alembic upgrade head
```

### Step 9: Test Authentication

```bash
# Run the application
uvicorn app.main:app --reload

# 1. Register a user
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "full_name": "Test User",
    "password": "SecurePass123!"
  }'

# 2. Login to get token
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=SecurePass123!"

# Save the access_token from the response

# 3. Access protected endpoint
curl -X GET http://localhost:8000/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 4. Access admin-only endpoint (should fail for regular user)
curl -X GET http://localhost:8000/users/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 5. Refresh token
curl -X POST http://localhost:8000/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "YOUR_REFRESH_TOKEN"}'
```

### Challenge Extensions

1. Implement token blacklisting for logout
2. Add refresh token rotation
3. Implement password reset flow
4. Add 2-factor authentication
5. Create permission-based access control

---

## Lab 5: Advanced Features

### Learning Objectives
- Implement WebSocket connections
- Add Celery for background tasks
- Set up Redis caching
- Implement rate limiting
- Create WebSocket chat application

### Step 1: Install Additional Dependencies

```bash
pip install celery redis aioredis websockets
```

### Step 2: WebSocket Chat Implementation

Create `app/websocket/manager.py`:

```python
"""
app/websocket/manager.py - WebSocket connection manager
"""

from typing import Dict, Set, List
from fastapi import WebSocket, WebSocketDisconnect
import json
import asyncio
from datetime import datetime

class ConnectionManager:
    """
    Manage WebSocket connections and rooms.
    """
    
    def __init__(self):
        self.active_connections: Dict[str, Set[WebSocket]] = {}
        self.user_rooms: Dict[int, str] = {}
        self.room_histories: Dict[str, List[Dict]] = {}
        self.MAX_HISTORY = 100
    
    async def connect(self, websocket: WebSocket, room: str, user_id: int):
        """Connect a user to a room."""
        await websocket.accept()
        
        if room not in self.active_connections:
            self.active_connections[room] = set()
        self.active_connections[room].add(websocket)
        
        self.user_rooms[user_id] = room
        
        # Send join message
        await self.broadcast_to_room({
            "type": "user_joined",
            "user_id": user_id,
            "timestamp": datetime.utcnow().isoformat()
        }, room)
    
    def disconnect(self, websocket: WebSocket, user_id: int):
        """Disconnect a user from a room."""
        room = self.user_rooms.get(user_id)
        if room and room in self.active_connections:
            self.active_connections[room].discard(websocket)
            
            # Broadcast leave message
            asyncio.create_task(self.broadcast_to_room({
                "type": "user_left",
                "user_id": user_id,
                "timestamp": datetime.utcnow().isoformat()
            }, room))
    
    async def broadcast_to_room(self, message: dict, room: str):
        """Broadcast a message to all users in a room."""
        if room not in self.active_connections:
            return
        
        for connection in self.active_connections[room]:
            try:
                await connection.send_text(json.dumps(message))
            except:
                pass
    
    async def send_personal_message(self, message: dict, user_id: int):
        """Send a personal message to a user."""
        room = self.user_rooms.get(user_id)
        if room and room in self.active_connections:
            for connection in self.active_connections[room]:
                try:
                    await connection.send_text(json.dumps(message))
                except:
                    pass
    
    async def store_message(self, room: str, message: dict):
        """Store message in history."""
        if room not in self.room_histories:
            self.room_histories[room] = []
        
        self.room_histories[room].append(message)
        
        # Keep history limited
        if len(self.room_histories[room]) > self.MAX_HISTORY:
            self.room_histories[room] = self.room_histories[room][-self.MAX_HISTORY:]
    
    def get_history(self, room: str) -> List[Dict]:
        """Get message history for a room."""
        return self.room_histories.get(room, [])

# Global manager instance
manager = ConnectionManager()
```

Create `app/api/websocket.py`:

```python
"""
app/api/websocket.py - WebSocket endpoints
"""

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.websocket.manager import manager
from app.core.dependencies import get_current_user
from datetime import datetime
import json

router = APIRouter()

@router.websocket("/ws/{room}")
async def websocket_endpoint(
    websocket: WebSocket,
    room: str,
    user_id: int  # In production, get from auth
):
    """
    WebSocket endpoint for real-time communication.
    """
    await manager.connect(websocket, room, user_id)
    
    try:
        # Send history
        history = manager.get_history(room)
        await websocket.send_text(json.dumps({
            "type": "history",
            "messages": history
        }))
        
        while True:
            # Receive message
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # Create message object
            message_obj = {
                "type": "message",
                "user_id": user_id,
                "content": message.get("content", ""),
                "timestamp": datetime.utcnow().isoformat()
            }
            
            # Store in history
            await manager.store_message(room, message_obj)
            
            # Broadcast to room
            await manager.broadcast_to_room(message_obj, room)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
    except Exception as e:
        print(f"WebSocket error: {e}")
```

### Step 3: Celery Setup

Create `app/core/celery_app.py`:

```python
"""
app/core/celery_app.py - Celery configuration
"""

from celery import Celery
import os

# Redis URL
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

# Create Celery app
celery_app = Celery(
    "fastapi_lab",
    broker=REDIS_URL,
    backend=REDIS_URL
)

# Configure Celery
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,
    task_soft_time_limit=25 * 60,
)

# Auto-discover tasks
celery_app.autodiscover_tasks(["app.tasks"])
```

Create `app/tasks/email.py`:

```python
"""
app/tasks/email.py - Email tasks
"""

from app.core.celery_app import celery_app
import asyncio
import logging

logger = logging.getLogger(__name__)

@celery_app.task(name="send_welcome_email")
def send_welcome_email(email: str, name: str):
    """
    Send welcome email to new user.
    """
    try:
        # Simulate email sending
        logger.info(f"Sending welcome email to {email} ({name})")
        
        # In production, use actual email sending
        # await send_email(...)
        
        return {"status": "sent", "email": email}
    except Exception as e:
        logger.error(f"Failed to send email: {e}")
        return {"status": "failed", "email": email, "error": str(e)}

@celery_app.task(name="send_task_notification")
def send_task_notification(email: str, task_title: str):
    """
    Send task notification email.
    """
    try:
        logger.info(f"Sending task notification to {email}: {task_title}")
        return {"status": "sent", "email": email}
    except Exception as e:
        logger.error(f"Failed to send notification: {e}")
        return {"status": "failed", "email": email, "error": str(e)}
```

### Step 4: Redis Caching

Create `app/core/cache.py`:

```python
"""
app/core/cache.py - Redis caching
"""

import redis.asyncio as redis
import json
from functools import wraps
from typing import Optional, Any
import hashlib

class RedisCache:
    """
    Redis caching service.
    """
    
    def __init__(self, redis_url: str = "redis://localhost:6379/0"):
        self.redis_url = redis_url
        self.client = None
        self._connected = False
    
    async def connect(self):
        """Connect to Redis."""
        if not self._connected:
            self.client = redis.from_url(self.redis_url)
            self._connected = True
    
    async def get(self, key: str) -> Optional[Any]:
        """Get value from cache."""
        await self.connect()
        data = await self.client.get(key)
        if data:
            return json.loads(data)
        return None
    
    async def set(self, key: str, value: Any, ttl: int = 300) -> bool:
        """Set value in cache with TTL."""
        await self.connect()
        try:
            await self.client.setex(key, ttl, json.dumps(value))
            return True
        except Exception:
            return False
    
    async def delete(self, key: str) -> bool:
        """Delete value from cache."""
        await self.connect()
        try:
            await self.client.delete(key)
            return True
        except Exception:
            return False
    
    async def delete_pattern(self, pattern: str) -> int:
        """Delete all keys matching pattern."""
        await self.connect()
        try:
            keys = await self.client.keys(pattern)
            if keys:
                return await self.client.delete(*keys)
            return 0
        except Exception:
            return 0

# Global cache instance
_cache = None

def get_cache() -> RedisCache:
    """Get global cache instance."""
    global _cache
    if _cache is None:
        _cache = RedisCache()
    return _cache

def cached(ttl: int = 300, prefix: str = ""):
    """
    Cache decorator for async functions.
    """
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            cache = get_cache()
            
            # Generate key
            key_data = f"{prefix}:{func.__name__}:{str(args)}{str(kwargs)}"
            key = hashlib.md5(key_data.encode()).hexdigest()
            
            # Try cache
            cached_value = await cache.get(key)
            if cached_value is not None:
                return cached_value
            
            # Execute and cache
            result = await func(*args, **kwargs)
            await cache.set(key, result, ttl)
            return result
        return wrapper
    return decorator
```

### Step 5: Rate Limiting

Create `app/middleware/rate_limit.py`:

```python
"""
app/middleware/rate_limit.py - Rate limiting middleware
"""

from fastapi import Request, HTTPException, status
from fastapi.middleware.base import BaseHTTPMiddleware
from typing import Dict, Tuple
import time
from collections import defaultdict

class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Rate limiting middleware using in-memory storage.
    """
    
    def __init__(self, app, requests_per_minute: int = 60):
        super().__init__(app)
        self.requests_per_minute = requests_per_minute
        self.requests: Dict[str, list] = defaultdict(list)
        self.window = 60  # 1 minute
    
    async def dispatch(self, request: Request, call_next):
        # Get client IP
        client_ip = request.client.host if request.client else "unknown"
        
        # Check rate limit
        if not self.is_allowed(client_ip):
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Rate limit exceeded. Maximum {self.requests_per_minute} requests per minute."
            )
        
        response = await call_next(request)
        
        # Add rate limit headers
        response.headers["X-RateLimit-Limit"] = str(self.requests_per_minute)
        response.headers["X-RateLimit-Remaining"] = str(
            self.requests_per_minute - len(self.requests[client_ip])
        )
        
        return response
    
    def is_allowed(self, client_ip: str) -> bool:
        """Check if request is allowed under rate limit."""
        now = time.time()
        
        # Clean old requests
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if now - req_time < self.window
        ]
        
        # Check limit
        if len(self.requests[client_ip]) >= self.requests_per_minute:
            return False
        
        # Add current request
        self.requests[client_ip].append(now)
        return True
```

### Step 6: Update Main Application

Update `app/main.py`:

```python
"""
app/main.py - Main application with advanced features
"""

from fastapi import FastAPI, BackgroundTasks, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db, init_db
from app.core.cache import get_cache, cached
from app.core.dependencies import get_current_user
from app.middleware.rate_limit import RateLimitMiddleware
from app.api import auth, websocket
from app.tasks.email import send_welcome_email, send_task_notification
from app.models.user import User

app = FastAPI(
    title="Advanced Features Lab",
    description="FastAPI with WebSockets, Celery, Redis, and Rate Limiting",
    version="1.0.0"
)

# Add CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add rate limiting
app.add_middleware(RateLimitMiddleware, requests_per_minute=60)

# Include routers
app.include_router(auth.router)
app.include_router(websocket.router)

# ────────────────────────────────────────────────────────────────
# Startup Event
# ────────────────────────────────────────────────────────────────

@app.on_event("startup")
async def startup():
    """Initialize services on startup."""
    await init_db()
    await get_cache().connect()
    print("Services initialized")

# ────────────────────────────────────────────────────────────────
# Background Tasks Endpoint
# ────────────────────────────────────────────────────────────────

@app.post("/send-email/")
async def send_email(
    email: str,
    name: str,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user)
):
    """
    Send email using BackgroundTasks.
    """
    background_tasks.add_task(send_welcome_email, email, name)
    return {"message": "Email queued for sending"}

@app.post("/send-notification/")
async def send_notification(
    email: str,
    task_title: str,
    current_user: User = Depends(get_current_user)
):
    """
    Send notification using Celery.
    """
    task = send_task_notification.delay(email, task_title)
    return {"task_id": task.id, "status": "queued"}

# ────────────────────────────────────────────────────────────────
# Cached Endpoint
# ────────────────────────────────────────────────────────────────

@cached(ttl=60, prefix="user")
async def get_user_profile(user_id: int, db: AsyncSession):
    """Get user profile with caching."""
    # Simulate slow database query
    import asyncio
    await asyncio.sleep(0.5)
    
    service = UserService(db)
    return await service.get_user(user_id)

@app.get("/users/{user_id}/profile")
async def get_profile(
    user_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get user profile with caching.
    """
    profile = await get_user_profile(user_id, db)
    if not profile:
        raise HTTPException(status_code=404, detail="User not found")
    return profile
```

### Step 7: Test Advanced Features

```bash
# Start Redis
redis-server

# Start Celery worker
celery -A app.core.celery_app worker --loglevel=info

# Start the application
uvicorn app.main:app --reload

# Test WebSocket using a client
# Using wscat: npm install -g wscat
wscat -c ws://localhost:8000/ws/room1

# Send a message
# {"content": "Hello, room!"}

# Test caching
curl http://localhost:8000/users/1/profile
# First request will be slow, subsequent requests will be fast

# Test background tasks
curl -X POST http://localhost:8000/send-email/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "name": "Test User"}'

# Test rate limiting
for i in {1..70}; do
  curl -s http://localhost:8000/health
done
```

### Challenge Extensions

1. Add message persistence to database
2. Implement WebSocket authentication
3. Add Celery task monitoring with Flower
4. Implement distributed rate limiting with Redis
5. Add file upload with progress tracking

---

## Lab Solutions Summary

### Complete Lab 5 Solution

All code for Lab 5 is included in the step-by-step instructions above. The key components are:

1. **WebSocket Manager**: Manages connections and rooms
2. **Celery Setup**: Distributed task processing
3. **Redis Cache**: In-memory caching with TTL
4. **Rate Limiting**: In-memory rate limiter
5. **WebSocket Endpoints**: Real-time chat functionality

---

## Final Project: Complete Task Management System

### Project Requirements

Build a complete task management system with:

1. **Authentication**: JWT with role-based access (Admin, Manager, Developer, Viewer)
2. **Users**: Registration, profile management, email verification
3. **Projects**: Create, read, update, delete, with team members
4. **Tasks**: CRUD operations, status workflow, assignment, comments
5. **Real-Time**: WebSocket notifications for task updates
6. **Background**: Email notifications with Celery
7. **Caching**: Redis caching for user profiles and task lists
8. **Testing**: Unit and integration tests
9. **Deployment**: Docker containerization

### Project Structure

```
fastapi-project/
├── app/
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── tasks.py
│   │   ├── projects.py
│   │   └── websocket.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── database.py
│   │   ├── security.py
│   │   ├── dependencies.py
│   │   ├── cache.py
│   │   └── celery_app.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── project.py
│   │   └── comment.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── task.py
│   │   ├── project.py
│   │   └── comment.py
│   ├── services/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── task.py
│   │   └── project.py
│   ├── repositories/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── user.py
│   │   ├── task.py
│   │   └── project.py
│   ├── tasks/
│   │   ├── __init__.py
│   │   └── email.py
│   ├── middleware/
│   │   ├── __init__.py
│   │   └── rate_limit.py
│   ├── websocket/
│   │   ├── __init__.py
│   │   └── manager.py
│   └── main.py
├── alembic/
├── tests/
│   ├── __init__.py
│   ├── test_auth.py
│   ├── test_users.py
│   └── test_tasks.py
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .env
└── README.md
```

### Implementation Steps

1. **Setup**: Create project structure, install dependencies
2. **Database**: Configure SQLAlchemy, create models
3. **Auth**: Implement JWT, register/login endpoints
4. **CRUD**: Implement repositories and services
5. **API**: Create endpoints for users, tasks, projects
6. **WebSockets**: Implement real-time notifications
7. **Celery**: Add background email tasks
8. **Caching**: Add Redis caching
9. **Testing**: Write unit and integration tests
10. **Docker**: Containerize the application

---

**End of Lab Book**
