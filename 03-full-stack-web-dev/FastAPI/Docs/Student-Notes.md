# FastAPI Masterclass: Student Notes

**Comprehensive Course Notes for Building Production-Ready APIs**

---

## How to Use These Notes

These notes are designed to accompany the FastAPI Masterclass video series and workbook. Each section corresponds to a module in the course and contains:

1. **Key Concepts** - Important ideas explained simply
2. **Code Examples** - Working code snippets you can use
3. **Definitions** - Technical terms explained
4. **Best Practices** - Industry standards to follow
5. **Common Pitfalls** - Mistakes to avoid
6. **Quick Reference** - Useful commands and patterns

---

## Part 1: FastAPI Foundations

### 1.1 Introduction to FastAPI

#### What is FastAPI?
- **Definition:** A modern, fast (high-performance) web framework for building APIs with Python
- **Why it's called "Fast":** It's one of the fastest Python frameworks available
- **Built on:** Starlette (web) and Pydantic (validation)

#### Key Features
- **Automatic Documentation:** Interactive API docs at `/docs` (Swagger UI) and `/redoc` (ReDoc)
- **Data Validation:** Automatic request/response validation with Pydantic
- **Async Support:** Built-in async/await support for high performance
- **Type Hints:** Full IDE support with autocomplete

#### ASGI vs WSGI

**Analogy:** "WSGI is like a single-lane road, ASGI is like a multi-lane highway."

| Feature | WSGI | ASGI |
|---------|------|------|
| Synchronous | ✓ | ✓ |
| Asynchronous | ✗ | ✓ |
| WebSocket support | ✗ | ✓ |
| Performance | Slower | Faster |
| Use case | Traditional apps | Modern async apps |

#### Your First FastAPI App

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id: int):
    return {"item_id": item_id}
```

**How to run:** `uvicorn main:app --reload`

#### Common HTTP Methods

| Method | Purpose | Idempotent |
|--------|---------|------------|
| GET | Retrieve data | Yes |
| POST | Create data | No |
| PUT | Update (full) | Yes |
| PATCH | Update (partial) | No |
| DELETE | Delete data | Yes |

---

### 1.2 Request & Response Lifecycle

#### Path Parameters

```python
@app.get("/users/{user_id}")
async def get_user(user_id: int):  # Automatically converted to int
    return {"user_id": user_id}
```

- **Purpose:** Capture values from the URL path
- **Type Conversion:** FastAPI/Pydantic handles type conversion automatically

#### Query Parameters

```python
@app.get("/items/")
async def list_items(
    skip: int = 0,      # Default value, optional in URL
    limit: int = 10,    # Default value, optional in URL
    search: str = None  # Optional parameter
):
    return {"skip": skip, "limit": limit}
```

- **URL Example:** `/items/?skip=10&limit=20&search=test`
- **Default Values:** Used when parameter is omitted

#### Request Body

```python
from pydantic import BaseModel

class ItemCreate(BaseModel):
    name: str
    price: float
    tags: list[str] = []

@app.post("/items/")
async def create_item(item: ItemCreate):
    # item.name, item.price, item.tags
    return item
```

#### Response Models

```python
from pydantic import BaseModel

class ItemResponse(BaseModel):
    id: int
    name: str
    price: float

@app.post("/items/", response_model=ItemResponse)
async def create_item(item: ItemCreate):
    db_item = {"id": 1, "name": item.name, "price": item.price}
    return db_item
```

- **Purpose:** Controls what data is returned to the client
- **Benefit:** Hides sensitive data and ensures consistent responses

#### Status Codes

```python
from fastapi import status

@app.post("/items/", status_code=status.HTTP_201_CREATED)
async def create_item(item: ItemCreate):
    return item
```

**Common Status Codes:**
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success, no content returned
- `400 Bad Request` - Client error
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Not authorized
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation error
- `429 Too Many Requests` - Rate limited
- `500 Internal Server Error` - Server error

---

### 1.3 Pydantic Models & Validation

#### Basic Model

```python
from pydantic import BaseModel, Field

class User(BaseModel):
    name: str
    email: str
    age: int = Field(..., ge=0, le=150)  # Required, between 0 and 150
```

#### Field Validation

```python
class Product(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    price: float = Field(..., gt=0, decimal_places=2)
    tags: list[str] = Field(default_factory=list, max_length=10)
    is_active: bool = True
```

**Common Field Constraints:**
- `min_length` / `max_length` - String length
- `gt` / `ge` - Greater than / greater than or equal
- `lt` / `le` - Less than / less than or equal
- `pattern` - Regex pattern
- `decimal_places` - Number of decimal places

#### Custom Validators

```python
from pydantic import field_validator

class UserCreate(BaseModel):
    username: str
    password: str
    confirm_password: str
    
    @field_validator('username')
    @classmethod
    def validate_username(cls, v: str) -> str:
        if not re.match(r'^[a-zA-Z0-9_]+$', v):
            raise ValueError('Username can only contain letters, numbers, underscores')
        return v.lower()
```

#### Model Validators (Cross-Field)

```python
from pydantic import model_validator

class UserCreate(BaseModel):
    password: str
    confirm_password: str
    
    @model_validator(mode='after')
    def validate_passwords_match(self) -> 'UserCreate':
        if self.password != self.confirm_password:
            raise ValueError('Passwords do not match')
        return self
```

#### Nested Models

```python
class Address(BaseModel):
    street: str
    city: str
    country: str

class User(BaseModel):
    name: str
    address: Address  # Nested model
```

#### Generic Models

```python
from typing import Generic, TypeVar

T = TypeVar('T')

class Response(BaseModel, Generic[T]):
    success: bool
    data: T

user_response = Response[User](
    success=True,
    data=User(name="John", email="john@example.com")
)
```

---

### 1.4 Dependency Injection

#### What is Dependency Injection?

**Analogy:** "A coffee shop where you order a coffee and the barista makes it. You don't need to know how the coffee machine works."

**Benefits:**
- **Testability:** Easy to mock dependencies
- **Reusability:** Dependencies can be reused across endpoints
- **Readability:** Cleaner code

#### Simple Dependency

```python
from fastapi import Depends

def common_parameters(q: str = None, skip: int = 0, limit: int = 100):
    return {"q": q, "skip": skip, "limit": limit}

@app.get("/items/")
async def read_items(commons: dict = Depends(common_parameters)):
    return commons
```

#### Database Session Dependency

```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        yield session

@app.get("/users/")
async def get_users(db: AsyncSession = Depends(get_db)):
    # Use db session
    return users
```

#### Authentication Dependency

```python
from fastapi import Depends, HTTPException

async def get_current_user(token: str = Depends(oauth2_scheme)):
    user = await validate_token(token)
    if not user:
        raise HTTPException(status_code=401)
    return user

@app.get("/profile/")
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user
```

#### Dependency with Class

```python
class PermissionChecker:
    def __init__(self, allowed_roles: list):
        self.allowed_roles = allowed_roles
    
    async def __call__(self, current_user: User = Depends(get_current_user)):
        if current_user.role not in self.allowed_roles:
            raise HTTPException(status_code=403)
        return current_user

@app.post("/admin/")
async def admin_endpoint(admin: User = Depends(PermissionChecker(["admin"]))):
    return {"message": "Admin access granted"}
```

---

### 1.5 Error Handling

#### HTTP Exceptions

```python
from fastapi import HTTPException

@app.get("/items/{item_id}")
async def get_item(item_id: int):
    item = await db.get_item(item_id)
    if not item:
        raise HTTPException(
            status_code=404,
            detail="Item not found",
            headers={"X-Error": "Not Found"}
        )
    return item
```

#### Custom Exception Class

```python
class APIException(Exception):
    def __init__(self, status_code: int, detail: str, error_code: str = None):
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code

# Exception handler
@app.exception_handler(APIException)
async def api_exception_handler(request: Request, exc: APIException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "code": exc.error_code}
    )
```

#### Validation Error Handling

```python
from fastapi.exceptions import RequestValidationError

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    errors = []
    for error in exc.errors():
        field = ".".join(str(loc) for loc in error["loc"])
        errors.append({"field": field, "message": error["msg"]})
    
    return JSONResponse(
        status_code=422,
        content={"detail": "Validation error", "errors": errors}
    )
```

#### Standardized Error Response

```json
{
    "success": false,
    "error": {
        "status_code": 404,
        "detail": "Item not found",
        "error_code": "NOT_FOUND",
        "data": {
            "resource": "item",
            "id": 123
        }
    },
    "meta": {
        "timestamp": "2024-01-15T10:30:00Z",
        "request_id": "abc-123-def"
    }
}
```

---

## Part 2: Database Integration

### 2.1 SQLAlchemy 2.0 Basics

#### What is SQLAlchemy?
- **Definition:** An ORM (Object-Relational Mapper) that maps Python classes to database tables
- **Analogy:** "SQLAlchemy is a translator between your Python code and your database"

#### Core Components

```
┌─────────────────────┐
│     Engine          │ ← Connection to database
├─────────────────────┤
│     Session         │ ← Unit of work
├─────────────────────┤
│     Model           │ ← Python class mapping to table
└─────────────────────┘
```

#### Async Setup

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base

# Engine
DATABASE_URL = "postgresql+asyncpg://user:pass@localhost:5432/db"
engine = create_async_engine(DATABASE_URL, echo=True)

# Session factory
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

# Base class
Base = declarative_base()
```

#### Defining Models (SQLAlchemy 2.0 Style)

```python
from sqlalchemy import Column, Integer, String, DateTime, func
from app.core.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
```

#### SQLAlchemy 2.0 with Type Hints

```python
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional

class User(Base):
    __tablename__ = "users"
    
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True)
    email: Mapped[str] = mapped_column(String(255), unique=True)
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    is_active: Mapped[bool] = mapped_column(default=True)
```

#### Common Column Types

| Type | SQLAlchemy | Description |
|------|------------|-------------|
| Integer | `Integer()` | Whole numbers |
| String | `String(length)` | Text with length limit |
| Text | `Text()` | Unlimited text |
| Boolean | `Boolean()` | True/False |
| DateTime | `DateTime()` | Date and time |
| Float | `Float()` | Decimal numbers |
| JSON | `JSON()` | JSON data (PostgreSQL) |
| UUID | `UUID()` | UUID values |

---

### 2.2 Relationships

#### One-to-Many Relationship

```python
class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50))
    
    # One-to-many: User has many Tasks
    tasks: Mapped[List["Task"]] = relationship(back_populates="user")

class Task(Base):
    __tablename__ = "tasks"
    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    
    # Many-to-one: Task belongs to one User
    user: Mapped[User] = relationship(back_populates="tasks")
```

#### Many-to-Many Relationship

```python
# Association table
user_role_association = Table(
    "user_roles",
    Base.metadata,
    Column("user_id", Integer, ForeignKey("users.id")),
    Column("role_id", Integer, ForeignKey("roles.id")),
)

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    roles: Mapped[List["Role"]] = relationship(
        secondary=user_role_association,
        back_populates="users",
        lazy="selectin"
    )

class Role(Base):
    __tablename__ = "roles"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(50))
    users: Mapped[List[User]] = relationship(
        secondary=user_role_association,
        back_populates="roles"
    )
```

#### Relationship Loading Strategies

| Strategy | Description | Use Case |
|----------|-------------|----------|
| `lazy="select"` | Load when accessed (default) | Small datasets |
| `lazy="selectin"` | Load with IN query | Recommended, avoids N+1 |
| `lazy="joined"` | Load with JOIN | One-to-one relationships |
| `lazy="dynamic"` | Returns query object | Large collections |

**Best Practice:** Use `lazy="selectin"` for most relationships.

---

### 2.3 CRUD & Repository Pattern

#### Repository Pattern

**Analogy:** "A library catalog system where you don't need to know how the books are organized."

```
┌─────────────────────────────────┐
│         API Endpoint            │
├─────────────────────────────────┤
│          Service Layer          │ ← Business logic
├─────────────────────────────────┤
│       Repository Layer          │ ← Database operations
├─────────────────────────────────┤
│         Database                │
└─────────────────────────────────┘
```

#### Base Repository

```python
from typing import TypeVar, Generic, Type, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

ModelType = TypeVar("ModelType")

class BaseRepository(Generic[ModelType]):
    def __init__(self, model: Type[ModelType], session: AsyncSession):
        self.model = model
        self.session = session
    
    async def create(self, **kwargs) -> ModelType:
        obj = self.model(**kwargs)
        self.session.add(obj)
        await self.session.flush()
        return obj
    
    async def get(self, id: int) -> Optional[ModelType]:
        result = await self.session.execute(
            select(self.model).where(self.model.id == id)
        )
        return result.scalar_one_or_none()
    
    async def get_all(self, skip: int = 0, limit: int = 100) -> list[ModelType]:
        result = await self.session.execute(
            select(self.model).offset(skip).limit(limit)
        )
        return result.scalars().all()
    
    async def update(self, id: int, **kwargs) -> ModelType:
        obj = await self.get(id)
        if obj:
            for key, value in kwargs.items():
                setattr(obj, key, value)
            await self.session.flush()
        return obj
    
    async def delete(self, id: int) -> bool:
        obj = await self.get(id)
        if obj:
            await self.session.delete(obj)
            await self.session.flush()
            return True
        return False
```

#### User Repository

```python
class UserRepository(BaseRepository[User]):
    def __init__(self, session: AsyncSession):
        super().__init__(User, session)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.session.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()
    
    async def get_by_username(self, username: str) -> Optional[User]:
        result = await self.session.execute(
            select(User).where(User.username == username)
        )
        return result.scalar_one_or_none()
```

#### Service Layer

```python
class UserService:
    def __init__(self, session: AsyncSession):
        self.repository = UserRepository(session)
        self.session = session
    
    async def create_user(self, data: UserCreate) -> User:
        # Validate
        if await self.repository.get_by_email(data.email):
            raise ValueError("Email already exists")
        
        # Hash password
        hashed_password = get_password_hash(data.password)
        
        # Create
        user = await self.repository.create(
            username=data.username,
            email=data.email,
            hashed_password=hashed_password
        )
        
        await self.session.commit()
        return user
```

---

### 2.4 Alembic Migrations

#### What is Alembic?
- **Definition:** Database migration tool for SQLAlchemy
- **Purpose:** Version control for your database schema

#### Setup

```bash
# Initialize Alembic
alembic init alembic

# Configure alembic.ini with database URL
# Update env.py to use your models
```

#### Common Commands

```bash
# Create migration
alembic revision --autogenerate -m "Add users table"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1

# Check current version
alembic current

# View history
alembic history
```

#### Migration Example

```python
def upgrade():
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('username', sa.String(length=50), nullable=False),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.text('now()')),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('email'),
        sa.UniqueConstraint('username'),
    )

def downgrade():
    op.drop_table('users')
```

---

## Part 3: Authentication & Security

### 3.1 JWT Authentication

#### OAuth2 Password Flow

```
1. Client sends username/password
2. Server validates credentials
3. Server returns JWT access token
4. Client uses token in Authorization header
5. Server validates token on each request
```

#### JWT Structure

```
Header.Payload.Signature
```

**Header:** Algorithm and token type
**Payload:** Data (user ID, expiration)
**Signature:** Cryptographic signature

#### Implementation

```python
from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

# JWT
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

#### Login Endpoint

```python
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

@app.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token({"sub": user.id, "role": user.role})
    return {"access_token": access_token, "token_type": "bearer"}
```

#### Current User Dependency

```python
async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = decode_token(token)
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401)
    except:
        raise HTTPException(status_code=401)
    
    user = await get_user_by_id(user_id)
    if user is None:
        raise HTTPException(status_code=401)
    return user

@app.get("/profile")
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user
```

---

### 3.2 Role-Based Access Control (RBAC)

#### Roles and Permissions

```
Admin     → Can do anything
Manager   → Can create, read, update, delete (own department)
Developer → Can create, read, update (own tasks)
Viewer    → Can read only
```

#### Implementation

```python
from enum import Enum

class UserRole(str, Enum):
    ADMIN = "admin"
    MANAGER = "manager"
    DEVELOPER = "developer"
    VIEWER = "viewer"

class PermissionChecker:
    def __init__(self, allowed_roles: list, allow_superuser: bool = True):
        self.allowed_roles = allowed_roles
        self.allow_superuser = allow_superuser
    
    async def __call__(self, current_user: User = Depends(get_current_user)):
        if self.allow_superuser and current_user.is_superuser:
            return current_user
        
        if current_user.role not in self.allowed_roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        
        return current_user

# Usage
require_admin = PermissionChecker([UserRole.ADMIN])
require_manager = PermissionChecker([UserRole.ADMIN, UserRole.MANAGER])
require_developer = PermissionChecker([UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER])
require_viewer = PermissionChecker([UserRole.ADMIN, UserRole.MANAGER, UserRole.DEVELOPER, UserRole.VIEWER])
```

#### Endpoint Protection

```python
@router.post("/tasks/", dependencies=[Depends(require_developer)])
async def create_task(...):
    pass

@router.delete("/tasks/{task_id}", dependencies=[Depends(require_manager)])
async def delete_task(...):
    pass

@router.get("/users/", dependencies=[Depends(require_admin)])
async def list_users(...):
    pass
```

---

## Part 4: Advanced Features

### 4.1 Async Programming

#### Understanding Async/Await

**Analogy:** "A restaurant where the chef can work on multiple orders while waiting for food to cook."

```python
import asyncio

async def task(name: str, delay: float):
    print(f"{name}: Starting")
    await asyncio.sleep(delay)  # Non-blocking wait
    print(f"{name}: Done")
    return f"{name} result"

# Run concurrently
async def main():
    results = await asyncio.gather(
        task("A", 2),
        task("B", 1),
        task("C", 3),
    )
    print(results)
```

#### Common Async Patterns

**1. Concurrent Execution:**
```python
results = await asyncio.gather(*[fetch_item(i) for i in range(10)])
```

**2. Timeout:**
```python
try:
    result = await asyncio.wait_for(slow_operation(), timeout=5.0)
except asyncio.TimeoutError:
    print("Operation timed out")
```

**3. Rate Limiting:**
```python
semaphore = asyncio.Semaphore(10)

async def limited_task():
    async with semaphore:
        return await expensive_operation()
```

---

### 4.2 Background Tasks

#### FastAPI BackgroundTasks

```python
from fastapi import BackgroundTasks

async def send_email(email: str, subject: str, body: str):
    # Simulate slow operation
    await asyncio.sleep(2)
    print(f"Email sent to {email}")

@app.post("/register/")
async def register_user(data: UserCreate, background_tasks: BackgroundTasks):
    user = await create_user(data)
    background_tasks.add_task(
        send_email,
        user.email,
        "Welcome!",
        "Thank you for registering"
    )
    return {"message": "User created, welcome email sent in background"}
```

#### Celery Integration

```python
from celery import Celery

celery_app = Celery(
    "tasks",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/0"
)

@celery_app.task
def process_image(image_path: str):
    # Heavy processing
    return {"status": "processed", "path": image_path}

@app.post("/upload/")
async def upload_image(file: UploadFile):
    file_path = await save_file(file)
    task = process_image.delay(file_path)
    return {"task_id": task.id, "status": "processing"}

@app.get("/task/{task_id}")
async def get_task_status(task_id: str):
    result = celery_app.AsyncResult(task_id)
    return {"status": result.status, "result": result.result if result.ready() else None}
```

**When to use:**
- `BackgroundTasks`: Simple, short operations
- `Celery`: Long-running, distributed, persistent tasks

---

### 4.3 WebSockets

#### What are WebSockets?
- **Definition:** Full-duplex communication channel between client and server
- **Analogy:** "A telephone call instead of sending letters"

#### Connection Manager

```python
from typing import Dict, Set
from fastapi import WebSocket, WebSocketDisconnect

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, Set[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)
    
    def disconnect(self, websocket: WebSocket, user_id: int):
        if user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)
    
    async def send_personal_message(self, message: str, user_id: int):
        if user_id in self.active_connections:
            for websocket in self.active_connections[user_id]:
                await websocket.send_text(message)
    
    async def broadcast(self, message: str):
        for connections in self.active_connections.values():
            for websocket in connections:
                await websocket.send_text(message)

manager = ConnectionManager()
```

#### WebSocket Endpoint

```python
@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Echo back
            await websocket.send_text(f"Message received: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
        await manager.broadcast(f"User {user_id} disconnected")
```

---

### 4.4 Caching with Redis

#### What is Redis?
- **Definition:** In-memory data store used for caching
- **Analogy:** "A sticky note on your desk for quick access"

#### Implementation

```python
import redis.asyncio as redis
import json
from functools import wraps

class RedisCache:
    def __init__(self, redis_url: str):
        self.client = redis.from_url(redis_url)
    
    async def get(self, key: str):
        return await self.client.get(key)
    
    async def set(self, key: str, value: str, ttl: int = 300):
        await self.client.setex(key, ttl, value)
    
    async def delete(self, key: str):
        await self.client.delete(key)

# Cache decorator
def cached(ttl: int = 300, prefix: str = ""):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            cache = get_cache_service()
            
            # Generate key
            key = f"{prefix}:{func.__name__}:{hash(str(args))}"
            
            # Try cache
            cached_value = await cache.get(key)
            if cached_value:
                return json.loads(cached_value)
            
            # Execute and cache
            result = await func(*args, **kwargs)
            await cache.set(key, json.dumps(result), ttl)
            return result
        return wrapper
    return decorator

# Usage
@cached(ttl=60, prefix="user")
async def get_user_profile(user_id: int):
    return await db.fetch_user_profile(user_id)
```

#### Cache Invalidation

```python
async def invalidate_user_cache(user_id: int):
    cache = get_cache_service()
    await cache.delete(f"user:get_user_profile:{user_id}")
    await cache.delete(f"user:get_user_tasks:{user_id}")
```

---

## Part 5: Testing & Deployment

### 5.1 Testing with pytest

#### Test Setup

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient
from app.main import app
from app.core.database import get_db

@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client

@pytest.fixture
async def db_session():
    # Setup test database
    async with AsyncSessionLocal() as session:
        yield session
    # Teardown
```

#### Unit Tests

```python
# tests/test_services.py
import pytest
from app.services.user import UserService

@pytest.mark.asyncio
async def test_create_user(db_session):
    service = UserService(db_session)
    user = await service.create_user(
        username="testuser",
        email="test@example.com",
        password="SecurePass123!"
    )
    assert user.id is not None
    assert user.username == "testuser"
```

#### API Tests

```python
# tests/test_api.py
@pytest.mark.asyncio
async def test_create_user(client):
    response = await client.post(
        "/api/v1/users/",
        json={
            "username": "testuser",
            "email": "test@example.com",
            "password": "SecurePass123!"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["username"] == "testuser"
```

#### Authentication Tests

```python
@pytest.mark.asyncio
async def test_login(client):
    # Register user
    await client.post("/api/v1/auth/register", json={...})
    
    # Login
    response = await client.post(
        "/api/v1/auth/login",
        data={"username": "test@example.com", "password": "SecurePass123!"}
    )
    assert response.status_code == 200
    assert "access_token" in response.json()
```

#### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific file
pytest tests/test_api.py

# Run with verbosity
pytest -v
```

---

### 5.2 Docker & Containerization

#### Dockerfile

```dockerfile
# Multi-stage build
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .

ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Docker Compose

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/app
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=app
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

#### Common Docker Commands

```bash
# Build and run
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop
docker-compose down

# Remove volumes
docker-compose down -v

# Enter container
docker exec -it fastapi_app /bin/bash
```

---

### 5.3 CI/CD Pipeline

#### GitHub Actions Workflow

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run migrations        run: alembic upgrade head
        
      - name: Run tests
        run: pytest --cov=app
  
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          ssh user@server 'cd /app && docker-compose pull && docker-compose up -d'
```

---

## Part 6: Enterprise Architecture

### 6.1 Clean Architecture

#### Architecture Layers

```
┌─────────────────────────────────────────┐
│           Interface Layer               │  ← FastAPI Routes
│         (API Controllers)               │
├─────────────────────────────────────────┤
│        Application Layer                │  ← Use Cases
│        (Use Cases / Services)           │
├─────────────────────────────────────────┤
│          Domain Layer                   │  ← Business Logic
│         (Entities / Value Objects)      │  ← Independent of frameworks
├─────────────────────────────────────────┤
│       Infrastructure Layer              │  ← Database, External APIs
│      (Repositories / Adapters)          │
└─────────────────────────────────────────┘
```

#### Dependency Rule: Dependencies point inward

#### Domain Entities

```python
# app/domain/entities/task.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional

@dataclass
class Task:
    id: str
    title: str
    description: Optional[str] = None
    status: str = "todo"
    created_at: datetime = datetime.utcnow()
    
    def complete(self):
        if self.status == "done":
            raise ValueError("Task already completed")
        self.status = "done"
```

#### Use Cases

```python
# app/application/use_cases/task_use_cases.py
class CreateTaskUseCase:
    def __init__(self, task_repo: TaskRepository):
        self.task_repo = task_repo
    
    async def execute(self, dto: CreateTaskDTO) -> Task:
        task = Task.create_new(
            title=dto.title,
            description=dto.description,
            created_by=dto.created_by
        )
        await self.task_repo.save(task)
        return task
```

#### Repository Interface

```python
# app/application/interfaces/repositories.py
from abc import ABC, abstractmethod

class TaskRepository(ABC):
    @abstractmethod
    async def save(self, task: Task) -> None:
        pass
    
    @abstractmethod
    async def get_by_id(self, task_id: str) -> Optional[Task]:
        pass
```

#### Infrastructure Implementation

```python
# app/infrastructure/repositories/task_repository.py
class PostgreSQLTaskRepository(TaskRepository):
    def __init__(self, session: AsyncSession):
        self.session = session
    
    async def save(self, task: Task) -> None:
        db_task = TaskModel.from_domain(task)
        self.session.add(db_task)
        await self.session.flush()
    
    async def get_by_id(self, task_id: str) -> Optional[Task]:
        result = await self.session.execute(
            select(TaskModel).where(TaskModel.id == task_id)
        )
        db_task = result.scalar_one_or_none()
        return db_task.to_domain() if db_task else None
```

#### Dependency Injection Wiring

```python
# app/dependencies.py
async def get_task_repository(db: AsyncSession = Depends(get_db)) -> TaskRepository:
    return PostgreSQLTaskRepository(db)

async def get_create_task_use_case(
    repo: TaskRepository = Depends(get_task_repository)
) -> CreateTaskUseCase:
    return CreateTaskUseCase(repo)

@router.post("/tasks/")
async def create_task(
    dto: CreateTaskDTO,
    use_case: CreateTaskUseCase = Depends(get_create_task_use_case)
):
    task = await use_case.execute(dto)
    return TaskResponse.from_domain(task)
```

---

### 6.2 Event-Driven Architecture

#### Domain Events

```python
# app/domain/events/task_events.py
from dataclasses import dataclass

@dataclass
class TaskCompleted:
    task_id: str
    completed_by: str
    completed_at: datetime

@dataclass
class TaskAssigned:
    task_id: str
    assignee_id: str
    assigned_by: str
```

#### Event Handlers

```python
# app/application/handlers/notification_handler.py
class NotificationHandler:
    def __init__(self, notification_service: NotificationService):
        self.notification_service = notification_service
    
    async def handle_task_completed(self, event: TaskCompleted):
        await self.notification_service.send_notification(
            user_id=event.completed_by,
            message=f"Task {event.task_id} completed"
        )
    
    async def handle_task_assigned(self, event: TaskAssigned):
        await self.notification_service.send_notification(
            user_id=event.assignee_id,
            message=f"You have been assigned to task {event.task_id}"
        )
```

#### Message Bus

```python
# app/infrastructure/message_bus/rabbitmq.py
class RabbitMQMessageBus:
    def __init__(self, connection_url: str):
        self.connection_url = connection_url
    
    async def publish(self, event: DomainEvent):
        message = json.dumps(event.__dict__)
        await self.channel.basic_publish(
            exchange="events",
            routing_key=event.__class__.__name__,
            body=message.encode()
        )
    
    async def subscribe(self, event_type: str, handler: Callable):
        queue = await self.channel.declare_queue(f"handler_{event_type}")
        await queue.consume(
            lambda msg: self._handle(msg, handler),
            no_ack=True
        )
```

#### Publishing Events

```python
class CompleteTaskUseCase:
    def __init__(self, task_repo: TaskRepository, message_bus: MessageBus):
        self.task_repo = task_repo
        self.message_bus = message_bus
    
    async def execute(self, task_id: str, user_id: str) -> Task:
        task = await self.task_repo.get_by_id(task_id)
        task.complete()
        await self.task_repo.save(task)
        
        # Publish event
        await self.message_bus.publish(
            TaskCompleted(task_id=task_id, completed_by=user_id)
        )
        
        return task
```

---

### 6.3 Kubernetes Deployment

#### Kubernetes Components

| Component | Purpose |
|-----------|---------|
| Pod | Smallest deployable unit (container) |
| Deployment | Manages replica set, rolling updates |
| Service | Exposes pods to network |
| Ingress | Routes external traffic to services |
| ConfigMap | External configuration |
| Secret | Sensitive data |
| PersistentVolume | Storage |

#### Deployment Manifest

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
  namespace: fastapi-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastapi-app
  template:
    metadata:
      labels:
        app: fastapi-app
    spec:
      containers:
        - name: fastapi-app
          image: ghcr.io/username/fastapi-app:latest
          ports:
            - containerPort: 8000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
          readinessProbe:
            httpGet:
              path: /ready
              port: 8000
```

#### Service Manifest

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: fastapi-service
  namespace: fastapi-app
spec:
  selector:
    app: fastapi-app
  ports:
    - port: 80
      targetPort: 8000
  type: LoadBalancer
```

#### Ingress Manifest

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastapi-ingress
  namespace: fastapi-app
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
    - hosts:
        - api.your-domain.com
      secretName: tls-secret
  rules:
    - host: api.your-domain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: fastapi-service
                port:
                  number: 80
```

#### Common Kubernetes Commands

```bash
# Apply manifests
kubectl apply -f k8s/

# Check pods
kubectl get pods -n fastapi-app

# Check services
kubectl get services -n fastapi-app

# View logs
kubectl logs -f deployment/fastapi-app -n fastapi-app

# Scale deployment
kubectl scale deployment fastapi-app -n fastapi-app --replicas=5

# Port forwarding
kubectl port-forward service/fastapi-service 8000:80 -n fastapi-app

# Delete resources
kubectl delete -f k8s/
```

---

## Quick Reference Cards

### FastAPI Quick Reference

| Task | Code |
|------|------|
| Create app | `app = FastAPI()` |
| GET endpoint | `@app.get("/path")` |
| POST endpoint | `@app.post("/path")` |
| Path param | `@app.get("/items/{id}")` |
| Query param | `def endpoint(q: str = None)` |
| Request body | `def endpoint(data: Item)` |
| Response model | `@app.get("/", response_model=Item)` |
| Status code | `@app.post("/", status_code=201)` |
| Dependency | `def endpoint(db: Session = Depends(get_db))` |
| Exception | `raise HTTPException(404, detail="Not found")` |

### SQLAlchemy Quick Reference

| Task | Code |
|------|------|
| Create model | `class User(Base): __tablename__ = "users"` |
| Column | `id = Column(Integer, primary_key=True)` |
| Relationship | `tasks = relationship("Task")` |
| Create session | `async with AsyncSessionLocal() as session:` |
| Execute query | `await session.execute(select(User))` |
| Add object | `session.add(obj)` |
| Commit | `await session.commit()` |
| Filter | `select(User).where(User.id == 1)` |
| Join | `select(User).join(Task)` |

### Pydantic Quick Reference

| Task | Code |
|------|------|
| Create model | `class User(BaseModel):` |
| Field | `name: str = Field(..., min_length=1)` |
| Optional | `name: Optional[str] = None` |
| Default factory | `items: list[str] = Field(default_factory=list)` |
| Field validator | `@field_validator('field')` |
| Model validator | `@model_validator(mode='after')` |

---

## Glossary of Terms

| Term | Definition |
|------|------------|
| **ASGI** | Asynchronous Server Gateway Interface |
| **CI/CD** | Continuous Integration / Continuous Deployment |
| **CORS** | Cross-Origin Resource Sharing |
| **CRUD** | Create, Read, Update, Delete |
| **DDD** | Domain-Driven Design |
| **DI** | Dependency Injection |
| **HTTP** | Hypertext Transfer Protocol |
| **JWT** | JSON Web Token |
| **ORM** | Object-Relational Mapping |
| **OAuth2** | Open Authorization 2.0 |
| **RBAC** | Role-Based Access Control |
| **REST** | Representational State Transfer |
| **SQL** | Structured Query Language |
| **WSGI** | Web Server Gateway Interface |

---

**End of Student Notes**
